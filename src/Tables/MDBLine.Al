table 92001 "MDB Update Line"
{
    DataClassification = CustomerContent;
    Caption = 'Managed Database Update Line';

    fields
    {
        field(1; "Document No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Document No.';
            TableRelation = "MDB Header";
        }
        field(2; "Line No."; Integer)
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
        field(13; "Field Class"; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Field Class';
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
    }

    keys
    {
        key(PK; "Document No.", "Line No.")
        {
            Clustered = true;
        }
    }

    local procedure UpdateFieldInfo()
    var
        MDBHeader: Record "MDB Header";
        RecRef: RecordRef;
        FieldRef: FieldRef;
    begin
        if "Field No." = 0 then begin
            "Field Name" := '';
            "Field Type" := '';
            "Field Class" := '';
            exit;
        end;
        if not MDBHeader.Get("Document No.") then
            exit;
        if MDBHeader."Table ID" = 0 then
            exit;
        RecRef.Open(MDBHeader."Table ID");
        if RecRef.FieldExist("Field No.") then begin
            FieldRef := RecRef.Field("Field No.");
            "Field Name" := FieldRef.Caption;
            "Field Type" := Format(FieldRef.Type);
            "Field Class" := Format(FieldRef.Class);
        end;
        RecRef.Close();
    end;
}