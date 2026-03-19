page 92003 "MDB List"
{
    PageType = List;
    SourceTable = "MDB Header";
    Caption = 'Managed Database List';
    UsageCategory = Lists;
    ApplicationArea = All;
    CardPageId = "MDB Workspace";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Document number.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Description of this operation.';
                }
                field("Table Name"; Rec."Table Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Target table name.';
                }
                field("Record Count"; Rec."Record Count")
                {
                    ApplicationArea = All;
                    ToolTip = 'Number of records to be updated.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    StyleExpr = StatusStyle;
                    ToolTip = 'Current status.';
                }
                field("Dry Run Mode"; Rec."Dry Run Mode")
                {
                    ApplicationArea = All;
                    ToolTip = 'Whether dry run mode is enabled.';
                }
                field("Rollback Available"; Rec."Rollback Available")
                {
                    ApplicationArea = All;
                    Style = Attention;
                    StyleExpr = Rec."Rollback Available";
                    ToolTip = 'Whether rollback data is available.';
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Who created this document.';
                }
                field("Created Date Time"; Rec."Created Date Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'When this document was created.';
                }
                field("Processed By"; Rec."Processed By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Who executed the update.';
                }
                field("Processed Date Time"; Rec."Processed Date Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'When the update was executed.';
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
            action(ViewLog)
            {
                ApplicationArea = All;
                Caption = 'View Log';
                Image = Log;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'View the update log for this document.';

                trigger OnAction()
                var
                    MDBLog: Record "MDB Log";
                begin
                    MDBLog.SetRange("Document No.", Rec."Document No.");
                    Page.Run(Page::"MDB Log List", MDBLog);
                end;
            }
        }
    }

    var
        StatusStyle: Text;

    trigger OnAfterGetRecord()
    begin
        case Rec.Status of
            Rec.Status::Open: StatusStyle := 'Ambiguous';
            Rec.Status::Processed: StatusStyle := 'Favorable';
            Rec.Status::RolledBack: StatusStyle := 'Attention';
            else StatusStyle := 'Standard';
        end;
    end;
}