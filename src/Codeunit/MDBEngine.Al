codeunit 92000 "MDB Engine"
{
    TableNo = "MDB Header";
    Permissions =
        tabledata "MDB Header" = RIM,
        tabledata "MDB Update Line" = RI,
        tabledata "MDB Log" = RI,
        tabledata "MDB Rollback Log" = RI,
        tabledata "MDB Relation" = R,
        tabledata "MDB Relation Join" = R,
        tabledata "MDB Relation Update Line" = R;

    var
        UpdateCompleteMsg: Label 'Managed Database update completed.\Success: %1\Failed: %2\Total: %3';
        DryRunCompleteMsg: Label 'Dry Run complete. No data was changed.\Would update: %1 fields across %2 records.';
        NoRecordsErr: Label 'No records match the filter criteria.';
        NoFieldsErr: Label 'No update fields specified.';
        ProcessingMsg: Label 'Processing record #1#### of #2####...';
        NoPermissionErr: Label 'You do not have permission to execute updates on document %1.';
        RollbackCompleteMsg: Label 'Rollback complete. %1 fields restored to original values.';
        RollbackNotAvailableErr: Label 'No rollback data available for this document.';

    procedure ExecuteBulkUpdate(var MDBHeader: Record "MDB Header")
    var
        MDBLine: Record "MDB Update Line";
        MDBPermMgmt: Codeunit "MDB Permission Mgmt";
        RecRef: RecordRef;
        BatchId: Guid;
        SuccessCount: Integer;
        FailCount: Integer;
        TotalCount: Integer;
        CurrentRecord: Integer;
        Dialog: Dialog;
    begin
        MDBPermMgmt.CheckCanExecute(MDBHeader);

        MDBLine.SetRange("Document No.", MDBHeader."Document No.");
        if MDBLine.IsEmpty then
            Error(NoFieldsErr);

        RecRef := GetFilteredRecordRef(MDBHeader);

        if not RecRef.WritePermission then
            Error(NoPermissionErr, MDBHeader."Document No.");

        TotalCount := RecRef.Count;
        if TotalCount = 0 then
            Error(NoRecordsErr);

        BatchId := CreateGuid();
        MDBHeader."Batch ID" := BatchId;

        Dialog.Open(ProcessingMsg);
        CurrentRecord := 0;

        if RecRef.FindSet(true) then
            repeat
                CurrentRecord += 1;
                Dialog.Update(1, CurrentRecord);
                Dialog.Update(2, TotalCount);

                if ProcessSingleRecord(RecRef, MDBHeader, MDBLine, BatchId, false) then
                    SuccessCount += 1
                else
                    FailCount += 1;

                ProcessRelations(RecRef, MDBHeader, 0, BatchId, false);
            until RecRef.Next() = 0;

        RecRef.Close();
        Dialog.Close();

        MDBHeader.Status := MDBHeader.Status::Processed;
        MDBHeader."Processed By" := CopyStr(UserId, 1, MaxStrLen(MDBHeader."Processed By"));
        MDBHeader."Processed Date Time" := CurrentDateTime;
        MDBHeader."Rollback Available" := true;
        MDBHeader.Modify();

        Commit();
        Message(UpdateCompleteMsg, SuccessCount, FailCount, TotalCount);
    end;

    procedure ExecuteDryRun(var MDBHeader: Record "MDB Header")
    var
        MDBLine: Record "MDB Update Line";
        RecRef: RecordRef;
        BatchId: Guid;
        WouldUpdateFields: Integer;
        WouldUpdateRecords: Integer;
        TotalCount: Integer;
        Dialog: Dialog;
    begin
        MDBLine.SetRange("Document No.", MDBHeader."Document No.");
        if MDBLine.IsEmpty then
            Error(NoFieldsErr);

        RecRef := GetFilteredRecordRef(MDBHeader);
        TotalCount := RecRef.Count;
        if TotalCount = 0 then
            Error(NoRecordsErr);

        BatchId := CreateGuid();
        Dialog.Open(ProcessingMsg);

        if RecRef.FindSet() then
            repeat
                Dialog.Update(1, WouldUpdateRecords + 1);
                Dialog.Update(2, TotalCount);
                if ProcessSingleRecord(RecRef, MDBHeader, MDBLine, BatchId, true) then begin
                    WouldUpdateRecords += 1;
                    MDBLine.Reset();
                    MDBLine.SetRange("Document No.", MDBHeader."Document No.");
                    WouldUpdateFields += MDBLine.Count;
                end;
            until RecRef.Next() = 0;

        RecRef.Close();
        Dialog.Close();

        Message(DryRunCompleteMsg, WouldUpdateFields, WouldUpdateRecords);
    end;

    procedure RollbackBatch(var MDBHeader: Record "MDB Header")
    var
        MDBRollbackLog: Record "MDB Rollback Log";
        MDBPermMgmt: Codeunit "MDB Permission Mgmt";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        RestoredCount: Integer;
    begin
        MDBPermMgmt.CheckCanRollback(MDBHeader);

        if not MDBHeader."Rollback Available" then
            Error(RollbackNotAvailableErr);

        MDBRollbackLog.SetRange("Document No.", MDBHeader."Document No.");
        MDBRollbackLog.SetRange("Batch ID", MDBHeader."Batch ID");
        MDBRollbackLog.SetRange("Rolled Back", false);
        if MDBRollbackLog.IsEmpty then
            Error(RollbackNotAvailableErr);

        if MDBRollbackLog.FindSet() then
            repeat
                RecRef.Open(MDBRollbackLog."Table ID");
                if RecRef.Get(MDBRollbackLog."Record ID") then
                    if RecRef.FieldExist(MDBRollbackLog."Field No.") then begin
                        FieldRef := RecRef.Field(MDBRollbackLog."Field No.");
                        if TrySetFieldValue(FieldRef, MDBRollbackLog."Original Value") then begin
                            RecRef.Modify(false);
                            MDBRollbackLog."Rolled Back" := true;
                            MDBRollbackLog."Rolled Back By" := CopyStr(UserId, 1, MaxStrLen(MDBRollbackLog."Rolled Back By"));
                            MDBRollbackLog."Rolled Back Date Time" := CurrentDateTime;
                            MDBRollbackLog.Modify();
                            RestoredCount += 1;
                        end;
                    end;
                RecRef.Close();
            until MDBRollbackLog.Next() = 0;

        MDBHeader.Status := MDBHeader.Status::RolledBack;
        MDBHeader."Rollback Available" := false;
        MDBHeader.Modify();

        Commit();
        Message(RollbackCompleteMsg, RestoredCount);
    end;

    procedure GetFilteredRecordRef(MDBHeader: Record "MDB Header") RecRef: RecordRef
    var
        MDBFilterHelper: Codeunit "MDB Filter Helper";
    begin
        RecRef.Open(MDBHeader."Table ID");
        MDBFilterHelper.ApplyConditionToRecordRef(MDBHeader, RecRef);
        exit(RecRef);
    end;

    procedure GetFilteredRecordCount(MDBHeader: Record "MDB Header"): Integer
    var
        RecRef: RecordRef;
        RecordCount: Integer;
    begin
        RecRef := GetFilteredRecordRef(MDBHeader);
        RecordCount := RecRef.Count;
        RecRef.Close();
        exit(RecordCount);
    end;

    local procedure ProcessSingleRecord(var RecRef: RecordRef; MDBHeader: Record "MDB Header"; var MDBLine: Record "MDB Update Line"; BatchId: Guid; IsDryRun: Boolean): Boolean
    var
        FieldRef: FieldRef;
        OldValue: Text;
        NewValue: Text;
        AllSuccess: Boolean;
        RecordModified: Boolean;
    begin
        AllSuccess := true;
        RecordModified := false;

        MDBLine.Reset();
        MDBLine.SetRange("Document No.", MDBHeader."Document No.");
        if MDBLine.FindSet() then
            repeat
                if RecRef.FieldExist(MDBLine."Field No.") then begin
                    FieldRef := RecRef.Field(MDBLine."Field No.");
                    OldValue := Format(FieldRef.Value);
                    NewValue := CalculateNewValue(OldValue, MDBLine."Update Mode", MDBLine."New Value");

                    if OldValue <> NewValue then begin
                        if not IsDryRun then begin
                            SaveRollbackEntry(RecRef, MDBHeader, MDBLine."Field No.",
                                MDBLine."Field Name", OldValue, BatchId, 0);
                            if TryUpdateField(FieldRef, NewValue, MDBLine."Field Type", MDBLine.Validate) then begin
                                LogUpdate(RecRef, MDBHeader, MDBLine."Field No.", MDBLine."Field Name",
                                    OldValue, NewValue, BatchId, true, '', 0, false);
                                RecordModified := true;
                            end else begin
                                LogUpdate(RecRef, MDBHeader, MDBLine."Field No.", MDBLine."Field Name",
                                    OldValue, NewValue, BatchId, false, GetLastErrorText(), 0, false);
                                AllSuccess := false;
                            end;
                        end else
                            LogUpdate(RecRef, MDBHeader, MDBLine."Field No.", MDBLine."Field Name",
                                OldValue, NewValue, BatchId, true, '', 0, true);
                    end;
                end;
            until MDBLine.Next() = 0;

        if RecordModified and AllSuccess and not IsDryRun then
            if not RecRef.Modify(true) then
                AllSuccess := false;

        exit(AllSuccess);
    end;

    procedure ProcessRelations(var ParentRecRef: RecordRef; MDBHeader: Record "MDB Header"; ParentRelationNo: Integer; BatchId: Guid; IsDryRun: Boolean)
    var
        MDBRelation: Record "MDB Relation";
        ChildRecRef: RecordRef;
    begin
        MDBRelation.SetRange("Document No.", MDBHeader."Document No.");
        MDBRelation.SetRange("Parent Relation No.", ParentRelationNo);
        MDBRelation.SetRange(Enabled, true);
        if not MDBRelation.FindSet() then
            exit;

        repeat
            ChildRecRef := BuildChildRecordRef(ParentRecRef, MDBRelation);
            if ChildRecRef.FindSet(not IsDryRun) then
                repeat
                    ProcessChildRecord(ChildRecRef, MDBHeader, MDBRelation, BatchId, IsDryRun);
                    ProcessRelations(ChildRecRef, MDBHeader, MDBRelation."Relation No.", BatchId, IsDryRun);
                until ChildRecRef.Next() = 0;
            ChildRecRef.Close();
        until MDBRelation.Next() = 0;
    end;

    local procedure BuildChildRecordRef(var ParentRecRef: RecordRef; MDBRelation: Record "MDB Relation") ChildRecRef: RecordRef
    var
        MDBRelationJoin: Record "MDB Relation Join";
        ParentFieldRef: FieldRef;
        ChildFieldRef: FieldRef;
    begin
        ChildRecRef.Open(MDBRelation."Child Table ID");

        MDBRelationJoin.SetRange("Document No.", MDBRelation."Document No.");
        MDBRelationJoin.SetRange("Relation No.", MDBRelation."Relation No.");
        if MDBRelationJoin.FindSet() then
            repeat
                if ParentRecRef.FieldExist(MDBRelationJoin."Parent Field No.") and
                   ChildRecRef.FieldExist(MDBRelationJoin."Child Field No.") then begin
                    ParentFieldRef := ParentRecRef.Field(MDBRelationJoin."Parent Field No.");
                    ChildFieldRef := ChildRecRef.Field(MDBRelationJoin."Child Field No.");
                    ChildFieldRef.SetRange(Format(ParentFieldRef.Value));
                end;
            until MDBRelationJoin.Next() = 0;

        exit(ChildRecRef);
    end;

    local procedure ProcessChildRecord(var ChildRecRef: RecordRef; MDBHeader: Record "MDB Header"; MDBRelation: Record "MDB Relation"; BatchId: Guid; IsDryRun: Boolean)
    var
        MDBRelationLine: Record "MDB Relation Update Line";
        FieldRef: FieldRef;
        OldValue: Text;
        NewValue: Text;
        RecordModified: Boolean;
    begin
        RecordModified := false;

        MDBRelationLine.SetRange("Document No.", MDBRelation."Document No.");
        MDBRelationLine.SetRange("Relation No.", MDBRelation."Relation No.");
        if not MDBRelationLine.FindSet() then
            exit;

        repeat
            if ChildRecRef.FieldExist(MDBRelationLine."Field No.") then begin
                FieldRef := ChildRecRef.Field(MDBRelationLine."Field No.");
                OldValue := Format(FieldRef.Value);
                NewValue := CalculateNewValue(OldValue, MDBRelationLine."Update Mode", MDBRelationLine."New Value");

                if OldValue <> NewValue then begin
                    if not IsDryRun then begin
                        SaveRollbackEntry(ChildRecRef, MDBHeader, MDBRelationLine."Field No.",
                            MDBRelationLine."Field Name", OldValue, BatchId, MDBRelation.Level);
                        if TryUpdateField(FieldRef, NewValue, MDBRelationLine."Field Type", MDBRelationLine.Validate) then begin
                            LogUpdate(ChildRecRef, MDBHeader, MDBRelationLine."Field No.", MDBRelationLine."Field Name",
                                OldValue, NewValue, BatchId, true, '', MDBRelation.Level, false);
                            RecordModified := true;
                        end else
                            LogUpdate(ChildRecRef, MDBHeader, MDBRelationLine."Field No.", MDBRelationLine."Field Name",
                                OldValue, NewValue, BatchId, false, GetLastErrorText(), MDBRelation.Level, false);
                    end else
                        LogUpdate(ChildRecRef, MDBHeader, MDBRelationLine."Field No.", MDBRelationLine."Field Name",
                            OldValue, NewValue, BatchId, true, '', MDBRelation.Level, true);
                end;
            end;
        until MDBRelationLine.Next() = 0;

        if RecordModified and not IsDryRun then
            ChildRecRef.Modify(true);
    end;

    local procedure SaveRollbackEntry(var RecRef: RecordRef; MDBHeader: Record "MDB Header"; FieldNo: Integer; FieldName: Text[250]; OriginalValue: Text; BatchId: Guid; RelationLevel: Integer)
    var
        MDBRollbackLog: Record "MDB Rollback Log";
        KeyRef: KeyRef;
    begin
        MDBRollbackLog.Init();
        MDBRollbackLog."Document No." := MDBHeader."Document No.";
        MDBRollbackLog."Batch ID" := BatchId;
        MDBRollbackLog."Table ID" := RecRef.Number;
        MDBRollbackLog."Table Name" := RecRef.Caption;
        MDBRollbackLog."Record ID" := RecRef.RecordId;
        MDBRollbackLog."Relation Level" := RelationLevel;
        MDBRollbackLog."Field No." := FieldNo;
        MDBRollbackLog."Field Name" := FieldName;
        MDBRollbackLog."Original Value" := CopyStr(OriginalValue, 1, MaxStrLen(MDBRollbackLog."Original Value"));
        if RecRef.KeyCount > 0 then begin
            KeyRef := RecRef.KeyIndex(1);
            if KeyRef.FieldCount > 0 then
                MDBRollbackLog."Primary Key Value" := CopyStr(Format(KeyRef.FieldIndex(1).Value), 1, MaxStrLen(MDBRollbackLog."Primary Key Value"));
        end;
        MDBRollbackLog.Insert(true);
    end;

    local procedure LogUpdate(var RecRef: RecordRef; MDBHeader: Record "MDB Header"; FieldNo: Integer; FieldName: Text[250]; OldValue: Text; NewValue: Text; BatchId: Guid; Success: Boolean; ErrorMsg: Text; RelationLevel: Integer; IsDryRun: Boolean)
    var
        MDBLog: Record "MDB Log";
        KeyRef: KeyRef;
    begin
        MDBLog.Init();
        MDBLog."Document No." := MDBHeader."Document No.";
        MDBLog."Table ID" := RecRef.Number;
        MDBLog."Table Name" := RecRef.Caption;
        MDBLog."Record ID" := RecRef.RecordId;
        MDBLog."Relation Level" := RelationLevel;
        MDBLog."Is Dry Run" := IsDryRun;
        MDBLog."Field No." := FieldNo;
        MDBLog."Field Name" := FieldName;
        MDBLog."Old Value" := CopyStr(OldValue, 1, MaxStrLen(MDBLog."Old Value"));
        MDBLog."New Value" := CopyStr(NewValue, 1, MaxStrLen(MDBLog."New Value"));
        MDBLog."Updated By" := CopyStr(UserId, 1, MaxStrLen(MDBLog."Updated By"));
        MDBLog."Updated Date Time" := CurrentDateTime;
        MDBLog."Batch ID" := BatchId;
        MDBLog.Success := Success;
        MDBLog."Error Message" := CopyStr(ErrorMsg, 1, MaxStrLen(MDBLog."Error Message"));
        if RecRef.KeyCount > 0 then begin
            KeyRef := RecRef.KeyIndex(1);
            if KeyRef.FieldCount > 0 then
                MDBLog."Primary Key Value" := CopyStr(Format(KeyRef.FieldIndex(1).Value), 1, MaxStrLen(MDBLog."Primary Key Value"));
        end;
        MDBLog.Insert(true);
    end;

    local procedure CalculateNewValue(OldValue: Text; UpdateMode: Enum "MDB Update Mode"; NewValue: Text): Text
    begin
        case UpdateMode of
            UpdateMode::Replace: exit(NewValue);
            UpdateMode::Append: exit(OldValue + NewValue);
            UpdateMode::Prepend: exit(NewValue + OldValue);
            UpdateMode::Clear: exit('');
        end;
    end;

    [TryFunction]
    local procedure TryUpdateField(var FieldRef: FieldRef; NewValue: Text; FieldType: Text; DoValidate: Boolean)
    var
        IntValue: Integer;
        DecValue: Decimal;
        DateValue: Date;
        DateTimeValue: DateTime;
        BoolValue: Boolean;
        TimeValue: Time;
        BigIntValue: BigInteger;
    begin
        case FieldType of
            'Text', 'Code':
                FieldRef.Value := CopyStr(NewValue, 1, FieldRef.Length);
            'Integer', 'Option':
                if Evaluate(IntValue, NewValue) then begin
                    if DoValidate then FieldRef.Validate(IntValue) else FieldRef.Value := IntValue;
                end else
                    Error('Invalid integer: %1', NewValue);
            'BigInteger':
                if Evaluate(BigIntValue, NewValue) then begin
                    if DoValidate then FieldRef.Validate(BigIntValue) else FieldRef.Value := BigIntValue;
                end else
                    Error('Invalid big integer: %1', NewValue);
            'Decimal':
                if Evaluate(DecValue, NewValue) then begin
                    if DoValidate then FieldRef.Validate(DecValue) else FieldRef.Value := DecValue;
                end else
                    Error('Invalid decimal: %1', NewValue);
            'Boolean':
                if Evaluate(BoolValue, NewValue) then begin
                    if DoValidate then FieldRef.Validate(BoolValue) else FieldRef.Value := BoolValue;
                end else
                    Error('Invalid boolean: %1', NewValue);
            'Date':
                if Evaluate(DateValue, NewValue) then begin
                    if DoValidate then FieldRef.Validate(DateValue) else FieldRef.Value := DateValue;
                end else
                    Error('Invalid date: %1', NewValue);
            'DateTime':
                if Evaluate(DateTimeValue, NewValue) then begin
                    if DoValidate then FieldRef.Validate(DateTimeValue) else FieldRef.Value := DateTimeValue;
                end else
                    Error('Invalid datetime: %1', NewValue);
            'Time':
                if Evaluate(TimeValue, NewValue) then begin
                    if DoValidate then FieldRef.Validate(TimeValue) else FieldRef.Value := TimeValue;
                end else
                    Error('Invalid time: %1', NewValue);
            else
                Error('Unsupported field type: %1', FieldType);
        end;
    end;

    [TryFunction]
    local procedure TrySetFieldValue(var FieldRef: FieldRef; Value: Text)
    begin
        FieldRef.Value := CopyStr(Value, 1, FieldRef.Length);
    end;

    procedure OpenTablePage(MDBHeader: Record "MDB Header")
    var
        RecRef: RecordRef;
        RecordRefVariant: Variant;
    begin
        RecRef := GetFilteredRecordRef(MDBHeader);
        if MDBHeader."Page ID" <> 0 then begin
            RecordRefVariant := RecRef;
            Page.Run(MDBHeader."Page ID", RecordRefVariant);
        end;
    end;

    procedure CopyDocument(SourceHeader: Record "MDB Header"): Code[20]
    var
        NewHeader: Record "MDB Header";
        SourceLine: Record "MDB Update Line";
        NewLine: Record "MDB Update Line";
        SourceRelation: Record "MDB Relation";
        NewRelation: Record "MDB Relation";
        SourceJoin: Record "MDB Relation Join";
        NewJoin: Record "MDB Relation Join";
        SourceRelationLine: Record "MDB Relation Update Line";
        NewRelationLine: Record "MDB Relation Update Line";
        ConditionText: Text;
    begin
        NewHeader.Init();
        NewHeader.TransferFields(SourceHeader, false);
        NewHeader."Document No." := '';
        NewHeader.Status := NewHeader.Status::Open;
        NewHeader."Created By" := CopyStr(UserId, 1, MaxStrLen(NewHeader."Created By"));
        NewHeader."Created Date Time" := CurrentDateTime;
        Clear(NewHeader."Processed By");
        Clear(NewHeader."Processed Date Time");
        Clear(NewHeader."Batch ID");
        NewHeader."Rollback Available" := false;
        NewHeader.Insert(true);

        // Copy condition blob
        ConditionText := SourceHeader.GetCondition();
        if ConditionText <> '' then
            NewHeader.SetCondition(ConditionText);

        SourceLine.SetRange("Document No.", SourceHeader."Document No.");
        if SourceLine.FindSet() then
            repeat
                NewLine.Init();
                NewLine.TransferFields(SourceLine, false);
                NewLine."Document No." := NewHeader."Document No.";
                NewLine.Insert(true);
            until SourceLine.Next() = 0;

        SourceRelation.SetRange("Document No.", SourceHeader."Document No.");
        if SourceRelation.FindSet() then
            repeat
                NewRelation.Init();
                NewRelation.TransferFields(SourceRelation, false);
                NewRelation."Document No." := NewHeader."Document No.";
                NewRelation.Insert(true);

                SourceJoin.SetRange("Document No.", SourceHeader."Document No.");
                SourceJoin.SetRange("Relation No.", SourceRelation."Relation No.");
                if SourceJoin.FindSet() then
                    repeat
                        NewJoin.Init();
                        NewJoin.TransferFields(SourceJoin, false);
                        NewJoin."Document No." := NewHeader."Document No.";
                        NewJoin.Insert(true);
                    until SourceJoin.Next() = 0;

                SourceRelationLine.SetRange("Document No.", SourceHeader."Document No.");
                SourceRelationLine.SetRange("Relation No.", SourceRelation."Relation No.");
                if SourceRelationLine.FindSet() then
                    repeat
                        NewRelationLine.Init();
                        NewRelationLine.TransferFields(SourceRelationLine, false);
                        NewRelationLine."Document No." := NewHeader."Document No.";
                        NewRelationLine.Insert(true);
                    until SourceRelationLine.Next() = 0;
            until SourceRelation.Next() = 0;

        exit(NewHeader."Document No.");
    end;
}