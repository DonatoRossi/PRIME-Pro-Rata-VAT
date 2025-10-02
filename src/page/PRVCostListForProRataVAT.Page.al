page 78000 "PRV Cost List For Pro-Rata VAT"
{
    Caption = 'Cost List For Pro-Rata VAT';
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "G/L Entry";
    SourceTableView = where("Source Code" = const('ACQUISTI'),
                            "VAT Amount" = filter(<> 0),
                            "Document Type" = filter(Invoice | "Credit Memo"),
                            "PRV Deductible %" = filter(<> 0));
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                }
                field("G/L Account No."; Rec."G/L Account No.")
                {
                    ApplicationArea = All;
                }
                field("G/L Account Name"; Rec."G/L Account Name")
                {
                    ApplicationArea = All;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("VAT Amount"; Rec."VAT Amount")
                {
                    ApplicationArea = All;
                }
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ApplicationArea = All;
                }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {
                    ApplicationArea = All;
                }
                field("PRV Deductible %"; Rec."PRV Deductible %")
                {
                    ApplicationArea = All;
                }
                field("PRV Pro-Rata %"; GLSetup."PRV % Pro-Rata")
                {
                    Caption = '% Pro-Rata';
                    ApplicationArea = All;
                }
                field("Pro-Rata Amount"; ProRata)
                {
                    Caption = 'Importo Pro-Rata';
                    ApplicationArea = All;
                }
                field("Official Date"; Rec."Official Date")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("&Navigate")
            {
                Caption = 'Find entries...';
                Image = Navigate;
                ToolTip = 'View the number and type of entries that have the same document number or posting date.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ApplicationArea = All;

                trigger OnAction()
                var
                    Navigate: Page Navigate;
                begin
                    Navigate.SetDoc(Rec."Posting Date", Rec."Document No.");
                    Navigate.Run();
                end;
            }
            action("Trasferisci a registrazioni COGE")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Transfer to General Journal';
                Ellipsis = true;
                Image = TransferToGeneralJournal;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Transfer the lines from the current window to the general journal.';

                trigger OnAction()
                var
                    GlToTransfer: Record "G/L Entry";
                    TransferToGLJnl: Report "PRV Trans. ProRata to Gen.Jnl.";
                begin
                    GlToTransfer.CopyFilters(Rec);
                    TransferToGLJnl.SetBankAccRecon(GlToTransfer);
                    TransferToGLJnl.Run();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        ProRata := Round(Rec."VAT Amount" * GLSetup."PRV % Pro-Rata" / 100 * Rec."PRV Deductible %" / 100, 0.01, '>');
    end;

    trigger OnOpenPage()
    begin
        GLSetup.Get();
        Rec.SetFilter("Posting Date", '%1..%2', CalcDate('<-1M-CM>', WorkDate()), CalcDate('<-1M+CM>', WorkDate()));
    end;

    var
        GLSetup: Record "General Ledger Setup";
        ProRata: Decimal;
}

