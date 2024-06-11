@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Calculation for item line'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity zfi_i_denghi_amt
  with parameters
    P_KeyDate : vdm_v_key_date,
    p_ctu     : zde_ctdenghi
  //    p_partner : lifnr
  as select from I_JournalEntry
    inner join   I_OperationalAcctgDocItem on  I_OperationalAcctgDocItem.AccountingDocument = I_JournalEntry.AccountingDocument
                                           and I_OperationalAcctgDocItem.CompanyCode        = I_JournalEntry.CompanyCode
                                           and I_OperationalAcctgDocItem.FiscalYear         = I_JournalEntry.FiscalYear
{
  key I_JournalEntry.CompanyCode,
  key I_JournalEntry.AccountingDocument,
  key I_JournalEntry.FiscalYear,
      I_OperationalAcctgDocItem.DocumentItemText,
      //key I_OperationalAcctgDocItem.AccountingDocumentItem,
      I_OperationalAcctgDocItem.TransactionCurrency,
      @Semantics.amount.currencyCode: 'TransactionCurrency' 
      sum(  I_OperationalAcctgDocItem.AmountInTransactionCurrency * -1 ) as AmountInTransactionCurrency //NganNM : lên hoá đơn điều chỉnh công nợ
}
where
  (
    (
              $parameters.p_ctu                                    =    'A'
      and(
        (
              I_OperationalAcctgDocItem.FinancialAccountType       =    'D'
          and I_OperationalAcctgDocItem.DebitCreditCode            =    'H'
        )
        or(
              I_OperationalAcctgDocItem.FinancialAccountType       =    'K'
          //          and I_OperationalAcctgDocItem.DebitCreditCode            =    'H' //NganNM : lên hoá đơn điều chỉnh công nợ
        )
      )
    )
    or(
              $parameters.p_ctu                                    =    'B'
      and     I_OperationalAcctgDocItem.FinancialAccountType       =    'K'
      and     I_OperationalAcctgDocItem.GLAccount                  like '00141%'
    )
  )
  // Check for open items
  and(
              I_OperationalAcctgDocItem.PostingDate                <= $parameters.P_KeyDate
    and(
              I_OperationalAcctgDocItem.ClearingDate               is initial
      or      I_OperationalAcctgDocItem.ClearingDate               > $parameters.P_KeyDate
    )
  )
  //Type
  and(
              I_OperationalAcctgDocItem.AccountingDocumentCategory <>   'D'
    and       I_OperationalAcctgDocItem.AccountingDocumentCategory <>   'M'
  )
  and(
              I_OperationalAcctgDocItem.FinancialAccountType       =    'D'
    or        I_OperationalAcctgDocItem.FinancialAccountType       =    'K'
  )
//  and ( ( I_OperationalAcctgDocItem.Customer  = $parameters.p_partner and  I_OperationalAcctgDocItem.FinancialAccountType = 'D' )
//    or ( I_OperationalAcctgDocItem.Supplier = $parameters.p_partner and  I_OperationalAcctgDocItem.FinancialAccountType = 'K' )
group by
  I_JournalEntry.CompanyCode,
  I_JournalEntry.AccountingDocument,
  I_JournalEntry.FiscalYear,
  I_OperationalAcctgDocItem.TransactionCurrency,
  I_OperationalAcctgDocItem.DocumentItemText
union all select from I_ParkedOplAcctgDocument
  inner join          I_ParkedOplAcctgDocItem on  I_ParkedOplAcctgDocItem.SourceCompanyCode        = I_ParkedOplAcctgDocument.SourceCompanyCode
                                              and I_ParkedOplAcctgDocItem.SourceFiscalYear         = I_ParkedOplAcctgDocument.SourceFiscalYear
                                              and I_ParkedOplAcctgDocItem.SourceAccountingDocument = I_ParkedOplAcctgDocument.SourceAccountingDocument
{
  key I_ParkedOplAcctgDocument.SourceCompanyCode                 as CompanyCode,
  key I_ParkedOplAcctgDocument.SourceAccountingDocument          as AccountingDocument,
  key I_ParkedOplAcctgDocument.SourceFiscalYear                  as FiscalYear,
      I_ParkedOplAcctgDocItem.DocumentItemText,
      I_ParkedOplAcctgDocItem.TransactionCurrency,
      sum( I_ParkedOplAcctgDocItem.AmountInTransactionCurrency * -1 ) as AmountInTransactionCurrency  //NganNM : lên hoá đơn điều chỉnh công nợ
}
where
  (
    (
              $parameters.p_ctu                                  =    'A'
      and(
        (
              I_ParkedOplAcctgDocItem.FinancialAccountType       =    'D'
          and I_ParkedOplAcctgDocItem.DebitCreditCode            =    'H'
        )
        or(
              I_ParkedOplAcctgDocItem.FinancialAccountType       =    'K'
          //          and I_ParkedOplAcctgDocItem.DebitCreditCode            =    'H' //NganNM : lên hoá đơn điều chỉnh công nợ
        )
      )
    )
    or(
              $parameters.p_ctu                                  =    'B'
      and     I_ParkedOplAcctgDocItem.FinancialAccountType       =    'K'
      and     I_ParkedOplAcctgDocItem.GLAccount                  like '00141%'
    )
  )
  // Check for open items
  and(
              I_ParkedOplAcctgDocItem.PostingDate                <= $parameters.P_KeyDate
  )
  //Type
  and(
              I_ParkedOplAcctgDocItem.AccountingDocumentCategory <>   'D'
    and       I_ParkedOplAcctgDocItem.AccountingDocumentCategory <>   'M'
  )
  and(
              I_ParkedOplAcctgDocItem.FinancialAccountType       =    'D'
    or        I_ParkedOplAcctgDocItem.FinancialAccountType       =    'K'
  )
//  and (
//            (  I_ParkedOplAcctgDocItem.Customer                 = $parameters.p_partner
//    and       I_ParkedOplAcctgDocItem.FinancialAccountType     =    'D' )
//    or      (  I_ParkedOplAcctgDocItem.Supplier                 = $parameters.p_partner
//    and       I_ParkedOplAcctgDocItem.FinancialAccountType     =    'K' )
//  )
group by
  I_ParkedOplAcctgDocument.SourceCompanyCode,
  I_ParkedOplAcctgDocument.SourceAccountingDocument,
  I_ParkedOplAcctgDocument.SourceFiscalYear,
  I_ParkedOplAcctgDocItem.TransactionCurrency,
  I_ParkedOplAcctgDocItem.DocumentItemText
