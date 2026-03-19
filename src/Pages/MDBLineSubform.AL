page 92002 "MDB Line Subform"
{
    PageType = ListPart;
    SourceTable = "MDB Update Line";
    Caption = 'Field Updates';
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
                    ToolTip = 'Field to update. Click to select.';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        exit(LookupField());
                    end;
                }
                field("Field Name"; Rec."Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Name of the field to update.';
                }
                field("Field Type"; Rec."Field Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Data type of the field.';
                }
                field("Update Mode"; Rec."Update Mode")
                {
                    ApplicationArea = All;
                    ToolTip = 'Replace: set new value. Append: add to end. Prepend: add to start. Clear: empty the field.';
                }
                field(Validate; Rec.Validate)
                {
                    ApplicationArea = All;
                    ToolTip = 'Whether to run field validation when updating.';
                }
                field("New Value"; Rec."New Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'The new value to set.';
                    Enabled = Rec."Update Mode" <> Rec."Update Mode"::Clear;
                }
            }
        }
    }

    local procedure LookupField(): Boolean
    var
        MDBHeader: Record "MDB Header";
        Field: Record "Field";
        FieldSelection: Page "Fields Lookup";
    begin
        if not MDBHeader.Get(Rec."Document No.") then
            exit(false);
        if MDBHeader."Table ID" = 0 then begin
            Message('Please select a table first.');
            exit(false);
        end;
        Field.Reset();
        Field.SetRange(TableNo, MDBHeader."Table ID");
        Field.SetRange(Enabled, true);
        Field.SetRange(Class, Field.Class::Normal);
        Field.SetFilter("No.", '>0');
        Field.SetFilter(ObsoleteState, '<>%1', Field.ObsoleteState::Removed);
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