@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Đề nghị (item)'
@Metadata.allowExtensions: true
define view entity zfi_i_denghi_i_log
  as select from zfi_tb_denghi_i

{
  key zdenghi,
  key gjahr,
  key item,
      accountingdocumentyear,
      accountingcompanycode,
      accountingdocument,
      accountingdocumentitem,
      transactioncurrency,
      accountingdocumenttype,
      supplierinvoice,
      @Semantics.amount.currencyCode: 'transactioncurrency'
      vat,
      @Semantics.amount.currencyCode: 'transactioncurrency'
      sotiendenghi,
      @Semantics.amount.currencyCode: 'transactioncurrency'
      sotientruocthue,
      supplier,
      customer,
      sohoadon,
      ngayhoadon,
      diengiai
}
