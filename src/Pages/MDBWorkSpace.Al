page 92000 "MDB Workspace"
{
    PageType = Document;
    SourceTable = "MDB Header";
    Caption = 'Managed Database Workspace';
    UsageCategory = Tasks;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Unique document number for this managed database operation.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Describe what this operation does.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    StyleExpr = StatusStyle;
                    ToolTip = 'Current status of this operation.';
                }
                field("Dry Run Mode"; Rec."Dry Run Mode")
                {
                    ApplicationArea = All;
                    ToolTip = 'Simulate the update without saving. Review results in the log before executing for real.';
                }
                field("Rollback Available"; Rec."Rollback Available")
                {
                    ApplicationArea = All;
                    Style = Attention;
                    StyleExpr = Rec."Rollback Available";
                    ToolTip = 'Indicates whether a rollback to previous values is available.';
                }
            }

            group(TableSelection)
            {
                Caption = 'Target Table';

                field("Table ID"; Rec."Table ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'The table you want to update.';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        exit(LookupTable());
                    end;
                }
                field("Table Name"; Rec."Table Name")
                {
                    ApplicationArea = All;
                    Style = StrongAccent;
                    StyleExpr = true;
                    ToolTip = 'Name of the selected table.';
                }
                field("Page ID"; Rec."Page ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Page to open when previewing filtered records.';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        exit(LookupPage());
                    end;
                }
                field("Page Name"; Rec."Page Name")
                {
                    ApplicationArea = All;
                    Style = StrongAccent;
                    StyleExpr = true;
                    ToolTip = 'Name of the selected page.';
                }
            }

            group(FilterGroup)
            {
                Caption = 'Filters';
                Visible = Rec."Table ID" <> 0;

                field(FilterConditionText; FilterConditionText)
                {
                    ApplicationArea = All;
                    Caption = 'Filter Condition';
                    Editable = false;
                    DrillDown = true;
                    ToolTip = 'Click to set filters using the standard BC filter dialog.';

                    trigger OnDrillDown()
                    begin
                        OpenFilterDialog();
                    end;
                }
                field("Record Count"; Rec."Record Count")
                {
                    ApplicationArea = All;
                    Style = Attention;
                    StyleExpr = Rec."Record Count" > 0;
                    ToolTip = 'Number of records matching the current filters.';
                }
            }

            group(FieldUpdates)
            {
                Caption = 'Field Updates (Main Table)';
                Visible = Rec."Table ID" <> 0;

                part(Lines; "MDB Line Subform")
                {
                    ApplicationArea = All;
                    SubPageLink = "Document No." = field("Document No.");
                    UpdatePropagation = Both;
                }
            }

            group(RelationsGroup)
            {
                Caption = 'Related Tables (Cascade)';
                Visible = Rec."Table ID" <> 0;

                part(Relations; "MDB Relation Subform")
                {
                    ApplicationArea = All;
                    SubPageLink = "Document No." = field("Document No.");
                    UpdatePropagation = Both;
                }
            }

            group(PermissionsGroup)
            {
                Caption = 'Access Control';

                part(Permissions; "MDB Permission Subform")
                {
                    ApplicationArea = All;
                    SubPageLink = "Document No." = field("Document No.");
                    UpdatePropagation = Both;
                }
            }
        }

        area(FactBoxes)
        {
            part(LogFactBox; "MDB Log FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "Document No." = field("Document No.");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SetFilters)
            {
                ApplicationArea = All;
                Caption = 'Set Filters';
                Image = FilterLines;
                ToolTip = 'Open the filter dialog to define which records to update.';

                trigger OnAction()
                begin
                    OpenFilterDialog();
                end;
            }

            action(CalculateRecords)
            {
                ApplicationArea = All;
                Caption = 'Calculate Record Count';
                Image = Calculate;
                ToolTip = 'Count how many records match the current filters.';

                trigger OnAction()
                begin
                    CalculateRecordCount();
                end;
            }

            action(PreviewRecords)
            {
                ApplicationArea = All;
                Caption = 'Preview Records';
                Image = View;
                ToolTip = 'Open the page showing records that match the filters.';

                trigger OnAction()
                var
                    MDBEngine: Codeunit "MDB Engine";
                begin
                    if Rec."Table ID" = 0 then
                        Error('Please select a table first.');
                    MDBEngine.OpenTablePage(Rec);
                end;
            }

            action(DryRun)
            {
                ApplicationArea = All;
                Caption = 'Dry Run (Simulate)';
                Image = Simulate;
                Enabled = Rec.Status = Rec.Status::Open;
                ToolTip = 'Simulate the update without saving. Results are logged for review.';

                trigger OnAction()
                var
                    MDBEngine: Codeunit "MDB Engine";
                begin
                    if Rec."Table ID" = 0 then
                        Error('Please select a table first.');
                    if not HasUpdateLines() then
                        Error('Please specify at least one field to update.');
                    MDBEngine.ExecuteDryRun(Rec);
                    CurrPage.Update(false);
                end;
            }

            action(ExecuteUpdate)
            {
                ApplicationArea = All;
                Caption = 'Execute Update';
                Image = UpdateDescription;
                Enabled = Rec.Status = Rec.Status::Open;
                ToolTip = 'Execute the update on all matching records.';

                trigger OnAction()
                var
                    MDBEngine: Codeunit "MDB Engine";
                begin
                    if Rec."Record Count" = 0 then
                        Error('No records match the filters. Calculate record count first.');
                    if not HasUpdateLines() then
                        Error('Please specify at least one field to update.');
                    if Confirm('Execute update for %1 records?\This will modify live data.', false, Rec."Record Count") then begin
                        MDBEngine.ExecuteBulkUpdate(Rec);
                        CurrPage.Update(false);
                    end;
                end;
            }

            action(Rollback)
            {
                ApplicationArea = All;
                Caption = 'Rollback Last Batch';
                Image = Undo;
                Enabled = Rec."Rollback Available";
                ToolTip = 'Restore all records to their values before the last execution.';

                trigger OnAction()
                var
                    MDBEngine: Codeunit "MDB Engine";
                begin
                    if Confirm('Rollback all changes from document %1?', false, Rec."Document No.") then begin
                        MDBEngine.RollbackBatch(Rec);
                        CurrPage.Update(false);
                    end;
                end;
            }

            action(SaveTemplate)
            {
                ApplicationArea = All;
                Caption = 'Save as Template';
                Image = Save;
                ToolTip = 'Save this document as a reusable template.';

                trigger OnAction()
                var
                    MDBTemplateMgmt: Codeunit "MDB Template Mgmt";
                    TemplateCode: Code[20];
                begin
                    TemplateCode := CopyStr(Rec."Document No.", 1, 20);
                    MDBTemplateMgmt.SaveAsTemplate(Rec, TemplateCode, Rec.Description);
                end;
            }

            action(CopyDocument)
            {
                ApplicationArea = All;
                Caption = 'Copy Document';
                Image = Copy;
                ToolTip = 'Create a copy of this document.';

                trigger OnAction()
                var
                    MDBEngine: Codeunit "MDB Engine";
                    NewDocNo: Code[20];
                begin
                    NewDocNo := MDBEngine.CopyDocument(Rec);
                    if NewDocNo <> '' then begin
                        Message('Document copied to %1', NewDocNo);
                        if Confirm('Open the new document?', true) then begin
                            Rec.Get(NewDocNo);
                            CurrPage.Update(false);
                        end;
                    end;
                end;
            }
        }

        area(Navigation)
        {
            action(ViewLog)
            {
                ApplicationArea = All;
                Caption = 'View Log';
                Image = Log;
                ToolTip = 'View the full update log for this document.';

                trigger OnAction()
                var
                    MDBLog: Record "MDB Log";
                begin
                    MDBLog.SetRange("Document No.", Rec."Document No.");
                    Page.Run(Page::"MDB Log List", MDBLog);
                end;
            }

            action(ViewTemplates)
            {
                ApplicationArea = All;
                Caption = 'Templates';
                Image = Template;
                ToolTip = 'View and manage saved templates.';

                trigger OnAction()
                begin
                    Page.Run(Page::"MDB Template List");
                end;
            }
        }

        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(SetFilters_Ref; SetFilters) { }
                actionref(CalculateRecords_Ref; CalculateRecords) { }
                actionref(PreviewRecords_Ref; PreviewRecords) { }
                actionref(DryRun_Ref; DryRun) { }
                actionref(ExecuteUpdate_Ref; ExecuteUpdate) { }
                actionref(Rollback_Ref; Rollback) { }
                actionref(SaveTemplate_Ref; SaveTemplate) { }
                actionref(CopyDocument_Ref; CopyDocument) { }
            }
            group(Category_Navigate)
            {
                actionref(ViewLog_Ref; ViewLog) { }
                actionref(ViewTemplates_Ref; ViewTemplates) { }
            }
        }
    }

    var
        StatusStyle: Text;
        FilterConditionText: Text;

    trigger OnAfterGetRecord()
    begin
        RefreshFilterText();
        SetStatusStyle();
    end;

    trigger OnOpenPage()
    begin
        RefreshFilterText();
    end;

    local procedure RefreshFilterText()
    var
        MDBFilterHelper: Codeunit "MDB Filter Helper";
    begin
        Clear(FilterConditionText);
        if Rec."Table ID" <> 0 then
            FilterConditionText := MDBFilterHelper.GetFilterDisplayText(Rec);
    end;

    local procedure OpenFilterDialog()
    var
        MDBFilterHelper: Codeunit "MDB Filter Helper";
        CurrentFilter: Text;
        NewFilter: Text;
    begin
        if Rec."Table ID" = 0 then
            Error('Please select a table first.');

        CurrentFilter := Rec.GetCondition();

        if MDBFilterHelper.ShowFilterDialog(
            NewFilter,
            CurrentFilter,
            Rec."Table ID",
            'Filters: ' + Rec."Table Name")
        then begin
            if NewFilter <> CurrentFilter then begin
                if NewFilter = MDBFilterHelper.CreateDefaultFilters(Rec."Table ID") then
                    Rec.SetCondition('')
                else
                    Rec.SetCondition(NewFilter);
                Rec."Record Count" := 0;
                Rec.Modify();
                RefreshFilterText();
                CurrPage.Update(false);
            end;
        end;
    end;

    local procedure SetStatusStyle()
    begin
        case Rec.Status of
            Rec.Status::Open: StatusStyle := 'Ambiguous';
            Rec.Status::Processed: StatusStyle := 'Favorable';
            Rec.Status::RolledBack: StatusStyle := 'Attention';
            else StatusStyle := 'Standard';
        end;
    end;

    local procedure LookupTable(): Boolean
    var
        AllObjWithCaption: Record AllObjWithCaption;
        Objects: Page Objects;
    begin
        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Table);
        Objects.SetTableView(AllObjWithCaption);
        Objects.LookupMode(true);
        if Objects.RunModal() = Action::LookupOK then begin
            Objects.GetRecord(AllObjWithCaption);
            Rec.Validate("Table ID", AllObjWithCaption."Object ID");
            exit(true);
        end;
    end;

    local procedure LookupPage(): Boolean
    var
        AllObjWithCaption: Record AllObjWithCaption;
        Objects: Page Objects;
    begin
        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Page);
        Objects.SetTableView(AllObjWithCaption);
        Objects.LookupMode(true);
        if Objects.RunModal() = Action::LookupOK then begin
            Objects.GetRecord(AllObjWithCaption);
            Rec.Validate("Page ID", AllObjWithCaption."Object ID");
            exit(true);
        end;
    end;

    local procedure CalculateRecordCount()
    var
        MDBEngine: Codeunit "MDB Engine";
    begin
        if Rec."Table ID" = 0 then
            Error('Please select a table first.');
        Rec."Record Count" := MDBEngine.GetFilteredRecordCount(Rec);
        Rec.Modify();
        CurrPage.Update(false);
        Message('%1 records match the current filters.', Rec."Record Count");
    end;

    local procedure HasUpdateLines(): Boolean
    var
        MDBLine: Record "MDB Update Line";
    begin
        MDBLine.SetRange("Document No.", Rec."Document No.");
        exit(not MDBLine.IsEmpty);
    end;
}