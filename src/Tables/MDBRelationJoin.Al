table 92007 "MDB Relation Join"
{
    DataClassification = CustomerContent;
    Caption = 'Managed Database Relation Join';

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
        field(3; "Join Line No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Join Line No.';
        }
        field(10; "Parent Field No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Parent Field No.';

            trigger OnValidate()
            begin
                UpdateParentFieldName();
            end;
        }
        field(11; "Parent Field Name"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Parent Field Name';
            Editable = false;
        }
        field(20; "Child Field No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Child Field No.';

            trigger OnValidate()
            begin
                UpdateChildFieldName();
            end;
        }
        field(21; "Child Field Name"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Child Field Name';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Document No.", "Relation No.", "Join Line No.") { Clustered = true; }
    }

    local procedure UpdateParentFieldName()
    var
        MDBRelation: Record "MDB Relation";
        MDBHeader: Record "MDB Header";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        ParentTableID: Integer;
    begin
        if "Parent Field No." = 0 then begin
            "Parent Field Name" := '';
            exit;
        end;
        if not MDBRelation.Get("Document No.", "Relation No.") then
            exit;
        if MDBRelation."Parent Relation No." = 0 then begin
            if not MDBHeader.Get("Document No.") then
                exit;
            ParentTableID := MDBHeader."Table ID";
        end else begin
            if not MDBRelation.Get("Document No.", MDBRelation."Parent Relation No.") then
                exit;
            ParentTableID := MDBRelation."Child Table ID";
        end;
        if ParentTableID = 0 then
            exit;
        RecRef.Open(ParentTableID);
        if RecRef.FieldExist("Parent Field No.") then begin
            FieldRef := RecRef.Field("Parent Field No.");
            "Parent Field Name" := FieldRef.Caption;
        end;
        RecRef.Close();
    end;

    local procedure UpdateChildFieldName()
    var
        MDBRelation: Record "MDB Relation";
        RecRef: RecordRef;
        FieldRef: FieldRef;
    begin
        if "Child Field No." = 0 then begin
            "Child Field Name" := '';
            exit;
        end;
        if not MDBRelation.Get("Document No.", "Relation No.") then
            exit;
        if MDBRelation."Child Table ID" = 0 then
            exit;
        RecRef.Open(MDBRelation."Child Table ID");
        if RecRef.FieldExist("Child Field No.") then begin
            FieldRef := RecRef.Field("Child Field No.");
            "Child Field Name" := FieldRef.Caption;
        end;
        RecRef.Close();
    end;
}