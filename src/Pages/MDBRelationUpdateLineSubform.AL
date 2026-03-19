page 92008 "MDB Relation Update Line Subform"
{
    PageType = List;
    SourceTable = "MDB Relation Update Line";
    Caption = 'Child Table Field Updates';
    AutoSplitKey = true;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Field No."; Rec."Field No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Field in the child table to update.';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        exit(LookupField());
                    end;
                }
                field("Field Name"; Rec."Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Name of the field.';
                }
                field("Field Type"; Rec."Field Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Data type of the field.';
                }
                field("Update Mode"; Rec."Update Mode")
                {
                    ApplicationArea = All;
                    ToolTip = 'How to apply the update.';
                }
                field(Validate; Rec.Validate)
                {
                    ApplicationArea = All;
                    ToolTip = 'Whether to run field validation.';
                }
                field("New Value"; Rec."New Value")
                {
                    ApplicationArea = All;
                    Enabled = Rec."Inherit From Parent Field No." = 0;
                    ToolTip = 'New value to set. Leave blank if inheriting from parent field.';
                }
                field("Inherit From Parent Field No."; Rec."Inherit From Parent Field No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'If set, copies the value from this field in the parent record instead of using New Value.';
                }
                field("Inherit From Parent Field Name"; Rec."Inherit From Parent Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Name of the parent field to inherit from.';
                }
            }
        }
    }

    local procedure LookupField(): Boolean
    var
        MDBRelation: Record "MDB Relation";
        Field: Record "Field";
        FieldSelection: Page "Fields Lookup";
    begin
        if not MDBRelation.Get(Rec."Document No.", Rec."Relation No.") then
            exit(false);
        if MDBRelation."Child Table ID" = 0 then
            exit(false);

        Field.Reset();
        Field.SetRange(TableNo, MDBRelation."Child Table ID");
        Field.SetRange(Enabled, true);
        Field.SetFilter("No.", '>0');
        FieldSelection.SetTableView(Field);
        FieldSelection.LookupMode(true);
        if FieldSelection.RunModal() = Action::LookupOK then begin
            FieldSelection.GetRecord(Field);
            Rec.Validate("Field No.", Field."No.");
            CurrPage.Update(true);
            exit(true);
        end;
    end;
}