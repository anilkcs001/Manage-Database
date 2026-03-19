table 92002 "MDB Log"
{
    DataClassification = CustomerContent;
    Caption = 'Managed Database Log';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(5; "Document No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Document No.';
        }
        field(7; "Relation Level"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Relation Level';
            ToolTip = '0 = main table, 1+ = child levels';
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
        field(12; "Is Dry Run"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Is Dry Run';
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
        field(40; "Old Value"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Old Value';
        }
        field(41; "New Value"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'New Value';
        }
        field(50; "Updated By"; Code[50])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Updated By';
        }
        field(51; "Updated Date Time"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Updated Date Time';
        }
        field(60; "Batch ID"; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Batch ID';
        }
        field(70; Success; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Success';
        }
        field(71; "Error Message"; Text[500])
        {
            DataClassification = CustomerContent;
            Caption = 'Error Message';
        }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(BatchKey; "Batch ID", "Updated Date Time") { }
        key(DocumentKey; "Document No.", "Updated Date Time") { }
        key(TableKey; "Table ID", "Updated Date Time") { }
        key(DryRunKey; "Document No.", "Is Dry Run") { }
    }
}