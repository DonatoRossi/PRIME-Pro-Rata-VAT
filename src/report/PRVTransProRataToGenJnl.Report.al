report 78000 "PRV Trans. ProRata to Gen.Jnl."
{
    Caption = 'Trans. Pro-Rata to Gen. Jnl.';
    ProcessingOnly = true;
    ApplicationArea = All;
    UsageCategory = None;

    dataset
    {
        dataitem("Integer"; "Integer")
        {
            DataItemTableView = WHERE(Number = CONST(1));
            dataitem("G/L Entry"; "G/L Entry")
            {

                trigger OnAfterGetRecord()
                var
                    SourceCodeSetup: Record "Source Code Setup";
                    DocumentNoTxt: Label 'PR%1-%2', Locked = true;
                begin
                    "G/L Entry".CalcFields("PRV Deductible %");
                    GenJnlLine.Init();
                    GenJnlLine."Line No." := GenJnlLine."Line No." + 10000;
                    GenJnlLine.Validate("Posting Date", CalcDate('<CM>', "G/L Entry"."Posting Date"));
                    SourceCodeSetup.Get();
                    GenJnlLine."Source Code" := SourceCodeSetup."Trans. Bank Rec. to Gen. Jnl.";

                    GenJnlLine."Document No." := StrSubstNo(DocumentNoTxt, Date2DMY(GenJnlLine."Posting Date", 3), Date2DMY(GenJnlLine."Posting Date", 2));
                    GenJnlLine.Validate("Account Type", GenJnlLine."Account Type"::"G/L Account");
                    GenJnlLine.Validate("Account No.", "G/L Entry"."G/L Account No.");

                    GenJnlLine.Validate(Amount, Round("G/L Entry"."VAT Amount" * GLSetup."PRV % Pro-Rata" / 100 * "G/L Entry"."PRV Deductible %" / 100, 0.01, '>'));
                    GenJnlLine.Validate("Bal. Account Type", GenJnlLine."Account Type"::"G/L Account");
                    GenJnlLine.Validate("Bal. Account No.", GLSetup."PRV Pro-Rata Account");

                    GenJnlLine."Shortcut Dimension 1 Code" := "G/L Entry"."Global Dimension 1 Code";
                    GenJnlLine."Shortcut Dimension 2 Code" := "G/L Entry"."Global Dimension 2 Code";
                    GenJnlLine."Dimension Set ID" := "G/L Entry"."Dimension Set ID";

                    GenJnlLine.Description := Description;
                    GenJnlLine.Insert();
                end;

                trigger OnPreDataItem()
                begin
                    GenJnlTemplate.Get(GenJnlLine."Journal Template Name");
                    GenJnlBatch.Get(GenJnlLine."Journal Template Name", GenJnlLine."Journal Batch Name");
                    GenJnlLine.SetRange("Journal Template Name", GenJnlBatch."Journal Template Name");
                    if GenJnlBatch.Name <> '' then
                        GenJnlLine.SetRange("Journal Batch Name", GenJnlBatch.Name)
                    else
                        GenJnlLine.SetRange("Journal Batch Name", '');

                    GenJnlLine.LockTable();
                    if GenJnlLine.FindLast() then;

                    "G/L Entry" := GlEntry;

                    GLSetup.Get();

                    "G/L Entry".SetFilter("Posting Date", '%1..%2', CalcDate('<-1M-CM>', WorkDate()), CalcDate('<-1M+CM>', WorkDate()));
                    "G/L Entry".SetRange("Source Code", 'ACQUISTI');
                    "G/L Entry".SetFilter("VAT Amount", '<>%1', 0);
                    "G/L Entry".SetFilter("Document Type", '%1|%2', "G/L Entry"."Document Type"::Invoice, "G/L Entry"."Document Type"::"Credit Memo");
                    "G/L Entry".SetFilter("PRV Deductible %", '<>%1', 0);
                end;
            }
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Opzioni)
                {
                    Caption = 'Options';
                    field("GenJnlLine.Journal Template Name"; GenJnlLine."Journal Template Name")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Gen. Journal Template';
                        NotBlank = true;
                        TableRelation = "Gen. Journal Template";
                        ToolTip = 'Specifies the general journal template that the entries are placed in.';
                    }
                    field("GenJnlLine.Journal Batch Name"; GenJnlLine."Journal Batch Name")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Gen. Journal Batch';
                        Lookup = true;
                        NotBlank = true;
                        ToolTip = 'Specifies the general journal batch that the entries are placed in.';

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            GenJnlLine.TestField("Journal Template Name");
                            GenJnlTemplate.Get(GenJnlLine."Journal Template Name");
                            GenJnlBatch.FilterGroup(2);
                            GenJnlBatch.SetRange("Journal Template Name", GenJnlLine."Journal Template Name");
                            GenJnlBatch.FilterGroup(0);
                            GenJnlBatch.Name := GenJnlLine."Journal Batch Name";
                            if GenJnlBatch.Find('=><') then;
                            if PAGE.RunModal(0, GenJnlBatch) = ACTION::LookupOK then begin
                                Text := GenJnlBatch.Name;
                                exit(true);
                            end;
                        end;

                        trigger OnValidate()
                        begin
                            GenJnlLine.TestField("Journal Template Name");
                            GenJnlBatch.Get(GenJnlLine."Journal Template Name", GenJnlLine."Journal Batch Name");
                        end;
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPostReport()
    begin
        GenJnlManagement.TemplateSelectionFromBatch(GenJnlBatch);
    end;

    var
        GLSetup: Record "General Ledger Setup";
        GenJnlTemplate: Record "Gen. Journal Template";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        GlEntry: Record "G/L Entry";
        GenJnlManagement: Codeunit GenJnlManagement;

    procedure SetBankAccRecon(var UseGlEntry: Record "G/L Entry")
    begin
        GlEntry := UseGlEntry;
    end;

    procedure InitializeRequest(GenJnlTemplateName: Code[10]; GenJnlBatchName: Code[10])
    begin
        GenJnlLine."Journal Template Name" := GenJnlTemplateName;
        GenJnlLine."Journal Batch Name" := GenJnlBatchName;
    end;
}

