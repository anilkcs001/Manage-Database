table 92000 "MDB Header"
{
    DataClassification = CustomerContent;
    Caption = 'Managed Database Header';
    LookupPageId = "MDB List";
    DrillDownPageId = "MDB List";

    fields
    {
        field(1; "Document No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Document No.';
        }
        field(5; Description; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
        field(10; "Table ID"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Table ID';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));

            trigger OnValidate()
            begin
                UpdateTableName();
                ClearLines();
                ClearRelations();
                ClearCondition();
                "Record Count" := 0;
            end;
        }
        field(11; "Table Name"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Table Name';
            Editable = false;
        }
        field(12; "Page ID"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Page ID';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Page));

            trigger OnValidate()
            var
                PageMetadata: Record "Page Metadata";
            begin
                if PageMetadata.Get(Rec."Page ID") then
                    Rec."Page Name" := PageMetadata.Caption
                else
                    Rec."Page Name" := '';
            end;
        }
        field(13; "Page Name"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Page Name';
            Editable = false;
        }
        field(20; Condition; Blob)
        {
            DataClassification = CustomerContent;
            Caption = 'Condition';
        }
        field(30; "Record Count"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Record Count';
            Editable = false;
        }
        field(40; Status; Enum "MDB Status")
        {
            DataClassification = CustomerContent;
            Caption = 'Status';
        }
        field(45; "Dry Run Mode"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Dry Run Mode';
            ToolTip = 'When enabled, simulates the update without saving any changes.';
        }
        field(50; "Template Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Template Code';
            TableRelation = "MDB Template".Code;
        }
        field(60; "Created By"; Code[50])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Created By';
            Editable = false;
        }
        field(61; "Created Date Time"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Created Date Time';
            Editable = false;
        }
        field(70; "Processed By"; Code[50])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Processed By';
            Editable = false;
        }
        field(71; "Processed Date Time"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Processed Date Time';
            Editable = false;
        }
        field(80; "Batch ID"; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Batch ID';
        }
        field(90; "Rollback Available"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Rollback Available';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Document No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        if "Document No." = '' then
            "Document No." := GetNextDocumentNo();
        "Created By" := CopyStr(UserId, 1, MaxStrLen("Created By"));
        "Created Date Time" := CurrentDateTime;
        Status := Status::Open;
    end;

    trigger OnDelete()
    begin
        ClearLines();
        ClearRelations();
    end;

    local procedure UpdateTableName()
    var
        RecRef: RecordRef;
    begin
        if "Table ID" = 0 then begin
            "Table Name" := '';
            exit;
        end;
        RecRef.Open("Table ID");
        "Table Name" := RecRef.Caption;
        RecRef.Close();
    end;

    local procedure ClearLines()
    var
        MDBLine: Record "MDB Update Line";
    begin
        MDBLine.SetRange("Document No.", "Document No.");
        MDBLine.DeleteAll();
    end;

    local procedure ClearRelations()
    var
        MDBRelation: Record "MDB Relation";
    begin
        MDBRelation.SetRange("Document No.", "Document No.");
        MDBRelation.DeleteAll(true);
    end;

    procedure ClearCondition()
    var
        OutStr: OutStream;
    begin
        Rec.Condition.CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.Write('');
    end;

    procedure SetCondition(Filters: Text)
    var
        OutStr: OutStream;
    begin
        Rec.Condition.CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.Write(Filters);
        Rec.Modify(true);
    end;

    procedure GetCondition() Filters: Text
    var
        InStr: InStream;
    begin
        if Rec.Condition.HasValue() then begin
            Rec.CalcFields(Condition);
            Rec.Condition.CreateInStream(InStr, TextEncoding::UTF8);
            InStr.Read(Filters);
        end;
    end;

    local procedure GetNextDocumentNo(): Code[20]
    var
        MDBHeader: Record "MDB Header";
    begin
        MDBHeader.SetCurrentKey("Document No.");
        if MDBHeader.FindLast() then
            exit(IncStr(MDBHeader."Document No."));
        exit('MDB000001');
    end;
}