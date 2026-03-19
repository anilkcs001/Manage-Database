enum 92000 "MDB Status"
{
    Extensible = true;
    Caption = 'MDB Status';

    value(0; Open) { Caption = 'Open'; }
    value(1; Released) { Caption = 'Released'; }
    value(2; Processed) { Caption = 'Processed'; }
    value(3; RolledBack) { Caption = 'Rolled Back'; }
}