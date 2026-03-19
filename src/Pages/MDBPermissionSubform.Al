page 92010 "MDB Permission Subform"
{
    PageType = ListPart;
    SourceTable = "MDB Permission";
    Caption = 'Access Control';
    AutoSplitKey = true;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'The user this permission applies to.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        UserMgt: Codeunit "User Management";
                    begin
                        UserMgt.LookupUserID(Rec."User ID");
                        exit(true);
                    end;
                }
                field("Can Execute"; Rec."Can Execute")
                {
                    ApplicationArea = All;
                    ToolTip = 'Allow this user to run the bulk update.';
                }
                field("Can Rollback"; Rec."Can Rollback")
                {
                    ApplicationArea = All;
                    ToolTip = 'Allow this user to rollback the last batch.';
                }
                field("Can Modify Setup"; Rec."Can Modify Setup")
                {
                    ApplicationArea = All;
                    ToolTip = 'Allow this user to change filters, fields, and relations.';
                }
                field("Granted By"; Rec."Granted By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Who granted this permission.';
                }
                field("Granted Date Time"; Rec."Granted Date Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'When this permission was granted.';
                }
            }
        }
    }
}