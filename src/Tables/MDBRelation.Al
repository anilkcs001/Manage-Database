table 92006 "MDB Relation"
{
    DataClassification = CustomerContent;
    Caption = 'Managed Database Relation';

    fields
    {
        field(1; "Document No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Document No.';
            TableRelation = "MDB Header";
        }
        field(2; "Relation No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Relation No.';
        }
        field(5; "Parent Relation No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Parent Relation No.';
            ToolTip = '0 = linked to main table. >0 = linked to another child relation (recursive).';
        }
        field(6; Level; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Level';
            Editable = false;
            ToolTip = 'Depth level — 1 = direct child of main table.';
        }
        field(10; "Child Table ID"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Child Table ID';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));

            trigger OnValidate()
            begin
                UpdateChildTableName();
            end;
        }
        field(11; "Child Table Name"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Child Table Name';
            Editable = false;
        }
        field(15; "Child Page ID"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Child Page ID';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Page));
        }
        field(20; Description; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
        field(30; Enabled; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Enabled';
            InitValue = true;
        }
    }

    keys
    {
        key(PK; "Document No.", "Relation No.") { Clustered = true; }
        key(LevelKey; "Document No.", Level) { }
    }

    trigger OnDelete()
    begin
        DeleteJoins();
        DeleteUpdateLines();
        DeleteChildRelations();
    end;

    local procedure UpdateChildTableName()
    var
        RecRef: RecordRef;
    begin
        if "Child Table ID" = 0 then begin
            "Child Table Name" := '';
            exit;
        end;
        RecRef.Open("Child Table ID");
        "Child Table Name" := RecRef.Caption;
        RecRef.Close();
    end;

    local procedure DeleteJoins()
    var
        MDBRelationJoin: Record "MDB Relation Join";
    begin
        MDBRelationJoin.SetRange("Document No.", "Document No.");
        MDBRelationJoin.SetRange("Relation No.", "Relation No.");
        MDBRelationJoin.DeleteAll();
    end;

    local procedure DeleteUpdateLines()
    var
        MDBRelationLine: Record "MDB Relation Update Line";
    begin
        MDBRelationLine.SetRange("Document No.", "Document No.");
        MDBRelationLine.SetRange("Relation No.", "Relation No.");
        MDBRelationLine.DeleteAll();
    end;

    local procedure DeleteChildRelations()
    var
        ChildRelation: Record "MDB Relation";
    begin
        ChildRelation.SetRange("Document No.", "Document No.");
        ChildRelation.SetRange("Parent Relation No.", "Relation No.");
        if ChildRelation.FindSet() then
            repeat
                ChildRelation.Delete(true);
            until ChildRelation.Next() = 0;
    end;
}