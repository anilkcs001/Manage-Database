table 92009 "MDB Template"
{
    DataClassification = CustomerContent;
    Caption = 'Managed Database Template';
    LookupPageId = "MDB Template List";

    fields
    {
        field(1; Code; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Code';
        }
        field(2; Description; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
        field(10; "Source Document No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Source Document No.';
            TableRelation = "MDB Header";
        }
        field(20; "Table ID"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Table ID';
        }
        field(21; "Table Name"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Table Name';
        }
        field(30; "Created By"; Code[50])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Created By';
            Editable = false;
        }
        field(31; "Created Date Time"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Created Date Time';
            Editable = false;
        }
        field(40; "Times Used"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Times Used';
            Editable = false;
        }
    }

    keys
    {
        key(PK; Code) { Clustered = true; }
    }

    trigger OnInsert()
    begin
        "Created By" := CopyStr(UserId, 1, MaxStrLen("Created By"));
        "Created Date Time" := CurrentDateTime;
    end;
}