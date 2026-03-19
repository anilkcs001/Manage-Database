page 92006 "MDB Relation Subform"
{
    PageType = ListPart;
    SourceTable = "MDB Relation";
    Caption = 'Related Tables';
    AutoSplitKey = true;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Relation No."; Rec."Relation No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Unique number for this relation.';
                }
                field("Parent Relation No."; Rec."Parent Relation No.")
                {
                    ApplicationArea = All;
                    ToolTip = '0 = child of main table. Enter another Relation No. to nest deeper (recursive).';
                }
                field(Level; Rec.Level)
                {
                    ApplicationArea = All;
                    ToolTip = 'Depth level — calculated automatically from Parent Relation No.';
                }
                field("Child Table ID"; Rec."Child Table ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'The related table to cascade updates into.';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        exit(LookupChildTable());
                    end;
                }
                field("Child Table Name"; Rec."Child Table Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Name of the related table.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Describe this relation, e.g. Purchase Invoice to GL Entries.';
                }
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Enable or disable this relation during execution.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ManageJoins)
            {
                ApplicationArea = All;
                Caption = 'Join Conditions';
                Image = LinkWithExisting;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Define which fields link the parent table to this child table.';

                trigger OnAction()
                var
                    MDBRelationJoin: Record "MDB Relation Join";
                begin
                    MDBRelationJoin.SetRange("Document No.", Rec."Document No.");
                    MDBRelationJoin.SetRange("Relation No.", Rec."Relation No.");
                    Page.Run(Page::"MDB Relation Join Subform", MDBRelationJoin);
                end;
            }

            action(ManageUpdateLines)
            {
                ApplicationArea = All;
                Caption = 'Fields to Update';
                Image = EditLines;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Define which fields in this child table should be updated.';

                trigger OnAction()
                var
                    MDBRelationLine: Record "MDB Relation Update Line";
                begin
                    MDBRelationLine.SetRange("Document No.", Rec."Document No.");
                    MDBRelationLine.SetRange("Relation No.", Rec."Relation No.");
                    Page.Run(Page::"MDB Relation Update Line Subform", MDBRelationLine);
                end;
            }
        }
    }

    local procedure LookupChildTable(): Boolean
    var
        AllObjWithCaption: Record AllObjWithCaption;
        Objects: Page Objects;
    begin
        AllObjWithCaption.SetRange("Object Type", AllObjWithCaption."Object Type"::Table);
        Objects.SetTableView(AllObjWithCaption);
        Objects.LookupMode(true);
        if Objects.RunModal() = Action::LookupOK then begin
            Objects.GetRecord(AllObjWithCaption);
            Rec.Validate("Child Table ID", AllObjWithCaption."Object ID");
            exit(true);
        end;
    end;
}