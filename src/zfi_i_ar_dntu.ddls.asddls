@EndUserText.label: 'Công nợ tạm ứng'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define view entity ZFI_I_AR_DNTU
  with parameters
    @Environment.systemField: #SYSTEM_DATE
    P_KeyDate : vdm_v_key_date
  as select from I_OperationalAcctgDocItem

{
  key I_OperationalAcctgDocItem.CompanyCode,
  key I_OperationalAcctgDocItem.Supplier,
  key I_OperationalAcctgDocItem.TransactionCurrency,

      @Semantics.amount.currencyCode: 'TransactionCurrency'
      sum( I_OperationalAcctgDocItem.AmountInTransactionCurrency ) as AmountInTransactionCurrency
}
where
  (
         I_OperationalAcctgDocItem.PostingDate              <= $parameters.P_KeyDate
    and(
         I_OperationalAcctgDocItem.ClearingDate             is initial
      or I_OperationalAcctgDocItem.ClearingDate             > $parameters.P_KeyDate
    )
  )
  and    I_OperationalAcctgDocItem.FinancialAccountType     =    'K' //Supplier
  and    I_OperationalAcctgDocItem.SpecialGLTransactionType is not initial
  and    I_OperationalAcctgDocItem.SpecialGLCode            =    'A'
  and    I_OperationalAcctgDocItem.GLAccount                like '00141*'
group by
  I_OperationalAcctgDocItem.CompanyCode,
  I_OperationalAcctgDocItem.Supplier,
  I_OperationalAcctgDocItem.TransactionCurrency
