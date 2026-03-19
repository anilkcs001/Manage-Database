page 92005 "MDB Log FactBox"
{
    PageType = CardPart;
    SourceTable = "MDB Log";
    Caption = 'Update Statistics';

    layout
    {
        area(Content)
        {
            group(Statistics)
            {
                Caption = 'Statistics';

                field(TotalUpdates; TotalUpdates)
                {
                    ApplicationArea = All;
                    Caption = 'Total Updates';
                    Style = Strong;
                    StyleExpr = true;
                    Editable = false;
                }
                field(SuccessCount; SuccessCount)
                {
                    ApplicationArea = All;
                    Caption = 'Successful';
                    Style = Favorable;
                    StyleExpr = true;
                    Editable = false;
                }
                field(FailCount; FailCount)
                {
                    ApplicationArea = All;
                    Caption = 'Failed';
                    Style = Unfavorable;
                    StyleExpr = FailCount > 0;
                    Editable = false;
                }
                field(DryRunCount; DryRunCount)
                {
                    ApplicationArea = All;
                    Caption = 'Dry Run Entries';
                    Style = Attention;
                    StyleExpr = DryRunCount > 0;
                    Editable = false;
                }
                field(SuccessRate; SuccessRate)
                {
                    ApplicationArea = All;
                    Caption = 'Success Rate %';
                    Editable = false;
                }
            }

            group(LastUpdate)
            {
                Caption = 'Last Update';
                Visible = TotalUpdates > 0;

                field(LastUpdateTime; LastUpdateTime)
                {
                    ApplicationArea = All;
                    Caption = 'Last Update Time';
                    Editable = false;
                }
                field(LastUpdateBy; LastUpdateBy)
                {
                    ApplicationArea = All;
                    Caption = 'Last Updated By';
                    Editable = false;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        CalculateStatistics();
    end;

    var
        TotalUpdates: Integer;
        SuccessCount: Integer;
        FailCount: Integer;
        DryRunCount: Integer;
        SuccessRate: Decimal;
        LastUpdateTime: DateTime;
        LastUpdateBy: Code[50];

    local procedure CalculateStatistics()
    var
        MDBLog: Record "MDB Log";
    begin
        TotalUpdates := 0;
        SuccessCount := 0;
        FailCount := 0;
        DryRunCount := 0;
        SuccessRate := 0;

        MDBLog.CopyFilters(Rec);
        TotalUpdates := MDBLog.Count;

        if TotalUpdates > 0 then begin
            MDBLog.SetRange(Success, true);
            MDBLog.SetRange("Is Dry Run", false);
            SuccessCount := MDBLog.Count;

            MDBLog.SetRange(Success, false);
            MDBLog.SetRange("Is Dry Run", false);
            FailCount := MDBLog.Count;

            MDBLog.SetRange(Success);
            MDBLog.SetRange("Is Dry Run", true);
            DryRunCount := MDBLog.Count;

            if (SuccessCount + FailCount) > 0 then
                SuccessRate := Round((SuccessCount / (SuccessCount + FailCount)) * 100, 0.01);

            MDBLog.Reset();
            MDBLog.CopyFilters(Rec);
            MDBLog.SetRange("Is Dry Run", false);
            if MDBLog.FindLast() then begin
                LastUpdateTime := MDBLog."Updated Date Time";
                LastUpdateBy := MDBLog."Updated By";
            end;
        end;
    end;
}