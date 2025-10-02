tableextension 78001 "PRV G/L Entry" extends "G/L Entry"
{
    fields
    {
        field(78000; "PRV Deductible %"; Decimal)
        {
            CalcFormula = lookup("VAT Entry"."Deductible %" where("Document Type" = field("Document Type"),
                                                                   "Document No." = field("Document No."),
                                                                   "VAT Bus. Posting Group" = field("VAT Bus. Posting Group"),
                                                                   "VAT Prod. Posting Group" = field("VAT Prod. Posting Group"),
                                                                   "Transaction No." = field("Transaction No.")));
            Caption = 'Deductible %';
            FieldClass = FlowField;
            Editable = false;
        }
    }
}
