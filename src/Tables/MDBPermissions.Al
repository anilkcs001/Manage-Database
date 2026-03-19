table 92010 "MDB Permission"
{
    DataClassification = CustomerContent;
    Caption = 'Managed Database Permission';

    fields
    {
        field(1; "Document No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Document No.';
            TableRelation = "MDB Header";
        }
        field(2; "User ID"; Code[50])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'User ID';
        }
        field(10; "Can Execute"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Can Execute';
        }
        field(11; "Can Rollback"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Can Rollback';
        }
        field(12; "Can Modify Setup"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Can Modify Setup';
        }
        field(20; "Granted By"; Code[50])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Granted By';
            Editable = false;
        }
        field(21; "Granted Date Time"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Granted Date Time';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Document No.", "User ID") { Clustered = true; }
    }

    trigger OnInsert()
    begin
        "Granted By" := CopyStr(UserId, 1, MaxStrLen("Granted By"));
        "Granted Date Time" := CurrentDateTime;
    end;
}