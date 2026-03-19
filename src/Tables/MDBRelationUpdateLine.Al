table 92008 "MDB Relation Update Line"
{
    DataClassification = CustomerContent;
    Caption = 'Managed Database Relation Update Line';

    fields
    {
        field(1; "Document No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Document No.';
        }
        field(2; "Relation No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Relation No.';
        }
        field(3; "Line No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Line No.';
        }
        field(10; "Field No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Field No.';

            trigger OnValidate()
            begin
                UpdateFieldInfo();
            end;
        }
        field(11; "Field Name"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Field Name';
            Editable = false;
        }
        field(12; "Field Type"; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Field Type';
            Editable = false;
        }
        field(20; "New Value"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'New Value';
        }
        field(21; Validate; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Validate';
        }
        field(30; "Update Mode"; Enum "MDB Update Mode")
        {
            DataClassification = CustomerContent;
            Caption = 'Update Mode';
            InitValue = Replace;
        }
        field(40; "Inherit From Parent Field No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Inherit From Parent Field No.';
            ToolTip = 'If set, copies the value from this field in the parent record instead of using New Value.';
        }
        field(41; "Inherit From Parent Field Name"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Inherit From Parent Field Name';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Document No.", "Relation No.", "Line No.") { Clustered = true; }
    }

    local procedure UpdateFieldInfo()
    var
        MDBRelation: Record "MDB Relation";
        RecRef: RecordRef;
        FieldRef: FieldRef;
    begin
        if "Field No." = 0 then begin
            "Field Name" := '';
            "Field Type" := '';
            exit;
        end;
        if not MDBRelation.Get("Document No.", "Relation No.") then
            exit;
        if MDBRelation."Child Table ID" = 0 then
            exit;
        RecRef.Open(MDBRelation."Child Table ID");
        if RecRef.FieldExist("Field No.") then begin
            FieldRef := RecRef.Field("Field No.");
            "Field Name" := FieldRef.Caption;
            "Field Type" := Format(FieldRef.Type);
        end;
        RecRef.Close();
    end;
}