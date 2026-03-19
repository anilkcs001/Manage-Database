codeunit 92001 "MDB Template Mgmt"
{
    procedure SaveAsTemplate(MDBHeader: Record "MDB Header"; TemplateCode: Code[20]; TemplateDescription: Text[100])
    var
        MDBTemplate: Record "MDB Template";
    begin
        if MDBTemplate.Get(TemplateCode) then begin
            if not Confirm('Template %1 already exists. Overwrite?', false, TemplateCode) then
                exit;
        end else begin
            MDBTemplate.Init();
            MDBTemplate.Code := TemplateCode;
            MDBTemplate.Insert(true);
        end;
        MDBTemplate.Description := TemplateDescription;
        MDBTemplate."Source Document No." := MDBHeader."Document No.";
        MDBTemplate."Table ID" := MDBHeader."Table ID";
        MDBTemplate."Table Name" := MDBHeader."Table Name";
        MDBTemplate.Modify();
        Message('Template %1 saved successfully.', TemplateCode);
    end;

    procedure LoadFromTemplate(var MDBHeader: Record "MDB Header"; TemplateCode: Code[20])
    var
        MDBTemplate: Record "MDB Template";
        MDBEngine: Codeunit "MDB Engine";
        SourceHeader: Record "MDB Header";
        NewDocNo: Code[20];
    begin
        if not MDBTemplate.Get(TemplateCode) then
            Error('Template %1 not found.', TemplateCode);
        if not SourceHeader.Get(MDBTemplate."Source Document No.") then
            Error('Source document for template %1 no longer exists.', TemplateCode);
        NewDocNo := MDBEngine.CopyDocument(SourceHeader);
        MDBHeader.Get(NewDocNo);
        MDBTemplate."Times Used" += 1;
        MDBTemplate.Modify();
        Message('Document %1 created from template %2.', NewDocNo, TemplateCode);
    end;
}