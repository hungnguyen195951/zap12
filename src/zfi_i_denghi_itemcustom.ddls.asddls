@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Item custom'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZFI_I_DENGHI_ITEMCUSTOM
  as select from    ZFI_I_DENGHI_IDCUSTOM as CT
    left outer join zfi_i_denghi_i_log    as item on  item.gjahr   = CT.gjahr
                                                  and item.zdenghi = CT.zdenghi
{
  key CT.idCustom,
  key item.zdenghi,
  key item.gjahr,
  key item.item,
      item.accountingdocumentyear,
      item.accountingcompanycode,
      item.accountingdocument,
      item.accountingdocumentitem,
      item.transactioncurrency,
      item.accountingdocumenttype,
      item.supplierinvoice,
      @Semantics.amount.currencyCode: 'transactioncurrency'
      item.vat,
      @Semantics.amount.currencyCode: 'transactioncurrency'
      item.sotiendenghi,
      @Semantics.amount.currencyCode: 'transactioncurrency'
      item.sotientruocthue,
      item.supplier,
      item.customer,
      item.sohoadon,
      item.ngayhoadon,
      item.diengiai

}
