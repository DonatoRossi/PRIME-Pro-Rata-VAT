pageextension 78000 "PRV General Ledger Setup" extends "General Ledger Setup"
{
    layout
    {
        addlast(General)
        {
            field("PRV % Pro-Rata"; Rec."PRV % Pro-Rata")
            {
                ApplicationArea = All;
            }
            field("PRV Pro-Rata Account"; Rec."PRV Pro-Rata Account")
            {
                ApplicationArea = All;
            }
        }
    }
}
