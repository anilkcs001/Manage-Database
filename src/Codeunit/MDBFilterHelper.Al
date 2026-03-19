codeunit 92003 "MDB Filter Helper"
{
    // Wraps the FilterPageBuilder pattern using Request Page Parameters Helper.
    // Same approach as AK Approval Workflow (Custom Request Page Parameters codeunit).

    procedure ShowFilterDialog(
        var NewFilters: Text;
        ExistingFilters: Text;
        TableID: Integer;
        PageCaption: Text): Boolean
    var
        ReqPageHelper: Codeunit "Request Page Parameters Helper";
        FilterPageBuilder: FilterPageBuilder;
        EntityName: Code[20];
        RecRef: RecordRef;
    begin
        if TableID = 0 then
            exit(false);

        RecRef.Open(TableID);
        EntityName := CopyStr(RecRef.Caption, 1, 20);
        RecRef.Close();

        if not ReqPageHelper.BuildDynamicRequestPage(FilterPageBuilder, EntityName, TableID) then
            exit(false);

        if ExistingFilters <> '' then
            ReqPageHelper.SetViewOnDynamicRequestPage(FilterPageBuilder, ExistingFilters, EntityName, TableID);

        FilterPageBuilder.PageCaption := PageCaption;

        if not FilterPageBuilder.RunModal() then
            exit(false);

        NewFilters := ReqPageHelper.GetViewFromDynamicRequestPage(FilterPageBuilder, EntityName, TableID);
        exit(true);
    end;

    procedure GetFilterDisplayText(MDBHeader: Record "MDB Header"): Text
    var
        ReqPageHelper: Codeunit "Request Page Parameters Helper";
        TempBlob: Codeunit "Temp Blob";
        RecRef: RecordRef;
    begin
        if MDBHeader."Table ID" = 0 then
            exit('');

        TempBlob.FromRecord(MDBHeader, MDBHeader.FieldNo(Condition));
        RecRef.Open(MDBHeader."Table ID", true);
        ReqPageHelper.ConvertParametersToFilters(RecRef, TempBlob, TextEncoding::UTF8);
        exit(RecRef.GetFilters());
    end;

    procedure ApplyConditionToRecordRef(MDBHeader: Record "MDB Header"; var RecRef: RecordRef)
    var
        ReqPageHelper: Codeunit "Request Page Parameters Helper";
        TempBlob: Codeunit "Temp Blob";
    begin
        if not MDBHeader.Condition.HasValue() then
            exit;

        MDBHeader.CalcFields(Condition);
        TempBlob.FromRecord(MDBHeader, MDBHeader.FieldNo(Condition));
        ReqPageHelper.ConvertParametersToFilters(RecRef, TempBlob, TextEncoding::UTF8);
    end;

    procedure CreateDefaultFilters(TableID: Integer): Text
    var
        ReqPageHelper: Codeunit "Request Page Parameters Helper";
        FilterPageBuilder: FilterPageBuilder;
        EntityName: Code[20];
        RecRef: RecordRef;
    begin
        if TableID = 0 then
            exit('');

        RecRef.Open(TableID);
        EntityName := CopyStr(RecRef.Caption, 1, 20);
        RecRef.Close();

        if not ReqPageHelper.BuildDynamicRequestPage(FilterPageBuilder, EntityName, TableID) then
            exit('');

        exit(ReqPageHelper.GetViewFromDynamicRequestPage(FilterPageBuilder, EntityName, TableID));
    end;
}