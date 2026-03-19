page 92009 "MDB Template List"
{
    PageType = List;
    SourceTable = "MDB Template";
    Caption = 'Managed Database Templates';
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Template code.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Template description.';
                }
                field("Table Name"; Rec."Table Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Target table this template was built for.';
                }
                field("Times Used"; Rec."Times Used")
                {
                    ApplicationArea = All;
                    ToolTip = 'How many times this template has been used.';
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Who created this template.';
                }
                field("Created Date Time"; Rec."Created Date Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'When this template was created.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CreateFromTemplate)
            {
                ApplicationArea = All;
                Caption = 'New Document from Template';
                Image = NewDocument;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Create a new managed database document based on this template.';

                trigger OnAction()
                var
                    MDBTemplateMgmt: Codeunit "MDB Template Mgmt";
                    MDBHeader: Record "MDB Header";
                begin
                    MDBTemplateMgmt.LoadFromTemplate(MDBHeader, Rec.Code);
                    Page.Run(Page::"MDB Workspace", MDBHeader);
                end;
            }
        }
    }
}