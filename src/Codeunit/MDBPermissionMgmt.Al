codeunit 92002 "MDB Permission Mgmt"
{
    procedure CheckCanExecute(MDBHeader: Record "MDB Header")
    var
        MDBPermission: Record "MDB Permission";
    begin
        if not HasAnyPermissionRecord(MDBHeader."Document No.") then
            exit;
        MDBPermission.SetRange("Document No.", MDBHeader."Document No.");
        MDBPermission.SetRange("User ID", CopyStr(UserId, 1, 50));
        MDBPermission.SetRange("Can Execute", true);
        if MDBPermission.IsEmpty then
            Error('You do not have permission to execute this managed database document.');
    end;

    procedure CheckCanRollback(MDBHeader: Record "MDB Header")
    var
        MDBPermission: Record "MDB Permission";
    begin
        if not HasAnyPermissionRecord(MDBHeader."Document No.") then
            exit;
        MDBPermission.SetRange("Document No.", MDBHeader."Document No.");
        MDBPermission.SetRange("User ID", CopyStr(UserId, 1, 50));
        MDBPermission.SetRange("Can Rollback", true);
        if MDBPermission.IsEmpty then
            Error('You do not have permission to rollback this managed database document.');
    end;

    procedure CheckCanModifySetup(MDBHeader: Record "MDB Header")
    var
        MDBPermission: Record "MDB Permission";
    begin
        if not HasAnyPermissionRecord(MDBHeader."Document No.") then
            exit;
        MDBPermission.SetRange("Document No.", MDBHeader."Document No.");
        MDBPermission.SetRange("User ID", CopyStr(UserId, 1, 50));
        MDBPermission.SetRange("Can Modify Setup", true);
        if MDBPermission.IsEmpty then
            Error('You do not have permission to modify the setup of this managed database document.');
    end;

    local procedure HasAnyPermissionRecord(DocumentNo: Code[20]): Boolean
    var
        MDBPermission: Record "MDB Permission";
    begin
        MDBPermission.SetRange("Document No.", DocumentNo);
        exit(not MDBPermission.IsEmpty);
    end;
}