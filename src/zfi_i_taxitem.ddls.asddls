//*----------------------------------------------------------------------*
//* Citek JSC.
//* (C) Copyright Citek JSC.
//* All Rights Reserved
//*----------------------------------------------------------------------*
//* Application : Get tax for DNTT
//* Creation Date: 21.11.2023
//* Created by: NganNM
//*----------------------------------------------------------------------*
//Sum tax base amnt and tax amount group by document number
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true
@EndUserText.label: 'Tax item'
define view entity zfi_i_taxitem
  as select from I_OperationalAcctgDocItem
{
  key I_OperationalAcctgDocItem.AccountingDocument,
  key I_OperationalAcctgDocItem.CompanyCode,
  key I_OperationalAcctgDocItem.FiscalYear,
      //      I_OperationalAcctgDocItem.TaxType,
      //      I_OperationalAcctgDocItem.TaxCode,
      I_OperationalAcctgDocItem.TransactionCurrency,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      sum( I_OperationalAcctgDocItem.AmountInTransactionCurrency ) as AmountInTransactionCurrency,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      sum( I_OperationalAcctgDocItem.TaxBaseAmountInTransCrcy )    as TaxBaseAmountInTransCrcy,
      '1'                                                          as type_case
}
where
  I_OperationalAcctgDocItem.TaxType is not initial
group by
  I_OperationalAcctgDocItem.AccountingDocument,
  I_OperationalAcctgDocItem.CompanyCode,
  I_OperationalAcctgDocItem.FiscalYear,
  I_OperationalAcctgDocItem.TransactionCurrency
union all select from I_ParkedOplAcctgDocItem
{
  key I_ParkedOplAcctgDocItem.SourceAccountingDocument                as AccountingDocument,
  key I_ParkedOplAcctgDocItem.SourceCompanyCode                       as CompanyCode,
  key I_ParkedOplAcctgDocItem.SourceFiscalYear                        as FiscalYear,
      //      I_OperationalAcctgDocItem.TaxType,
      //      I_OperationalAcctgDocItem.TaxCode,
      I_ParkedOplAcctgDocItem.TransactionCurrency,
      sum( I_ParkedOplAcctgDocItem.AmountInTransactionCurrency * -1 ) as AmountInTransactionCurrency,
      sum( I_ParkedOplAcctgDocItem.TaxBaseAmountInTransCrcy * -1 )    as TaxBaseAmountInTransCrcy,
      '2'                                                             as type_case
}
where
  I_ParkedOplAcctgDocItem.TaxType is not initial
group by
  I_ParkedOplAcctgDocItem.SourceAccountingDocument,
  I_ParkedOplAcctgDocItem.SourceCompanyCode,
  I_ParkedOplAcctgDocItem.SourceFiscalYear,
  I_ParkedOplAcctgDocItem.TransactionCurrency
union all select from I_JournalEntry
  inner join          I_ParkedOplAcctgDocument    on  I_JournalEntry.AccountingDocument = I_ParkedOplAcctgDocument.SourceAccountingDocument
                                                  and I_JournalEntry.CompanyCode        = I_ParkedOplAcctgDocument.CompanyCode
                                                  and I_JournalEntry.FiscalYear         = I_ParkedOplAcctgDocument.SourceFiscalYear
  inner join          ZFI_I_SUPPLIERINVOICETAXSUM on  ZFI_I_SUPPLIERINVOICETAXSUM.SupplierInvoice = substring(
    I_JournalEntry.OriginalReferenceDocument, 1, 10
  )
                                                  and ZFI_I_SUPPLIERINVOICETAXSUM.FiscalYear      = substring(
    I_JournalEntry.OriginalReferenceDocument, 11, 4
  )
  inner join          I_SupplierInvoiceAPI01      on  I_SupplierInvoiceAPI01.SupplierInvoice = substring(
    I_JournalEntry.OriginalReferenceDocument, 1, 10
  )
                                                  and I_SupplierInvoiceAPI01.FiscalYear      = substring(
    I_JournalEntry.OriginalReferenceDocument, 11, 4
  )
{
  key I_JournalEntry.AccountingDocument                       as AccountingDocument,
  key I_JournalEntry.CompanyCode                              as CompanyCode,
  key I_JournalEntry.FiscalYear                               as FiscalYear,
      I_JournalEntry.TransactionCurrency,
      case when I_SupplierInvoiceAPI01.IsInvoice = 'X' then ZFI_I_SUPPLIERINVOICETAXSUM.TaxAmount
      else ZFI_I_SUPPLIERINVOICETAXSUM.TaxAmount     * -1 end as AmountInTransactionCurrency,
      case when I_SupplierInvoiceAPI01.IsInvoice = 'X' then (  I_SupplierInvoiceAPI01.InvoiceGrossAmount  -  ZFI_I_SUPPLIERINVOICETAXSUM.TaxAmount  )
          else ( I_SupplierInvoiceAPI01.InvoiceGrossAmount -  ZFI_I_SUPPLIERINVOICETAXSUM.TaxAmount ) * -1
      end                                                     as TaxBaseAmountInTransCrcy,
      '3'                                                     as type_case
}
//union all select from I_ParkedOplAcctgDocument
//  inner join          I_SupplierInvoiceTaxAPI01 on  I_SupplierInvoiceTaxAPI01.SupplierInvoice = substring(
//    I_ParkedOplAcctgDocument.OriginalReferenceDocument, 1, 10
//  )
//                                                and I_SupplierInvoiceTaxAPI01.FiscalYear      = substring(
//    I_ParkedOplAcctgDocument.OriginalReferenceDocument, 11, 4
//  )
//{
//  key I_ParkedOplAcctgDocument.SourceAccountingDocument         as AccountingDocument,
//  key I_ParkedOplAcctgDocument.SourceCompanyCode                as CompanyCode,
//  key I_ParkedOplAcctgDocument.SourceFiscalYear                 as FiscalYear,
//      I_ParkedOplAcctgDocument.TransactionCurrency,
//      sum( I_SupplierInvoiceTaxAPI01.TaxAmount )                as AmountInTransactionCurrency,
//      sum( I_SupplierInvoiceTaxAPI01.TaxBaseAmountInTransCrcy ) as TaxBaseAmountInTransCrcy,
//      '4'                                                       as type_case
//}
//where
//  I_SupplierInvoiceTaxAPI01.TaxAmount <> 0
//group by
//  I_ParkedOplAcctgDocument.SourceAccountingDocument,
//  I_ParkedOplAcctgDocument.SourceCompanyCode,
//  I_ParkedOplAcctgDocument.SourceFiscalYear,
//  I_ParkedOplAcctgDocument.TransactionCurrency
