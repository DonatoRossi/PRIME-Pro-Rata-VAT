tableextension 78000 "PRV General Ledger Setup" extends "General Ledger Setup"
{
    fields
    {
        field(78000; "PRV % Pro-Rata"; Decimal)
        {
            Caption = '% Pro-Rata';
            DataClassification = CustomerContent;
            MaxValue = 100;
            MinValue = 0;
        }
        field(78001; "PRV Pro-Rata Account"; Code[20])
        {
            Caption = 'Pro-Rata Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account"."No." where("Account Type" = const(Posting));
        }
    }
}
