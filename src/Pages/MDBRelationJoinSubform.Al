page 92007 "MDB Relation Join Subform"
{
    PageType = List;
    SourceTable = "MDB Relation Join";
    Caption = 'Join Conditions';
    AutoSplitKey = true;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Join Line No."; Rec."Join Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Line number for this join condition.';
                }
                field("Parent Field No."; Rec."Parent Field No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Field in the parent table to join on.';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        exit(LookupParentField());
                    end;
                }
                field("Parent Field Name"; Rec."Parent Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Name of the parent field.';
                }
                field("Child Field No."; Rec."Child Field No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Matching field in the child table.';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        exit(LookupChildField());
                    end;
                }
                field("Child Field Name"; Rec."Child Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Name of the child field.';
                }
            }
        }
    }

    local procedure LookupParentField(): Boolean
    var
        MDBRelation: Record "MDB Relation";
        MDBHeader: Record "MDB Header";
        Field: Record "Field";
        FieldSelection: Page "Fields Lookup";
        ParentTableID: Integer;
    begin
        if not MDBRelation.Get(Rec."Document No.", Rec."Relation No.") then
            exit(false);

        if MDBRelation."Parent Relation No." = 0 then begin
            if not MDBHeader.Get(Rec."Document No.") then
                exit(false);
            ParentTableID := MDBHeader."Table ID";
        end else begin
            if not MDBRelation.Get(Rec."Document No.", MDBRelation."Parent Relation No.") then
                exit(false);
            ParentTableID := MDBRelation."Child Table ID";
        end;

        if ParentTableID = 0 then
            exit(false);

        Field.Reset();
        Field.SetRange(TableNo, ParentTableID);
        Field.SetRange(Enabled, true);
        Field.SetFilter("No.", '>0');
        FieldSelection.SetTableView(Field);
        FieldSelection.LookupMode(true);
        if FieldSelection.RunModal() = Action::LookupOK then begin
            FieldSelection.GetRecord(Field);
            Rec.Validate("Parent Field No.", Field."No.");
            CurrPage.Update(true);
            exit(true);
        end;
    end;

    local procedure LookupChildField(): Boolean
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
            Rec.Validate("Child Field No.", Field."No.");
            CurrPage.Update(true);
            exit(true);
        end;
    end;
}