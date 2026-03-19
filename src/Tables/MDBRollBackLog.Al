table 92011 "MDB Rollback Log"
{
    DataClassification = CustomerContent;
    Caption = 'Managed Database Rollback Log';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(5; "Batch ID"; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Batch ID';
        }
        field(6; "Document No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Document No.';
        }
        field(10; "Table ID"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Table ID';
        }
        field(11; "Table Name"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Table Name';
        }
        field(15; "Relation Level"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Relation Level';
        }
        field(20; "Record ID"; RecordId)
        {
            DataClassification = CustomerContent;
            Caption = 'Record ID';
        }
        field(21; "Primary Key Value"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Primary Key Value';
        }
        field(30; "Field No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Field No.';
        }
        field(31; "Field Name"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Field Name';
        }
        field(40; "Original Value"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Original Value';
        }
        field(50; "Rolled Back"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Rolled Back';
        }
        field(51; "Rolled Back By"; Code[50])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Rolled Back By';
        }
        field(52; "Rolled Back Date Time"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Rolled Back Date Time';
        }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(BatchKey; "Batch ID") { }
        key(DocumentKey; "Document No.", "Batch ID") { }
    }
}