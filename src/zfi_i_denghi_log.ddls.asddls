@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Đề nghị'
@Metadata.allowExtensions: true
define root view entity zfi_i_denghi_log
  as select from     zfi_tb_denghi
    inner join       zfi_i_ctdenghi               on zfi_i_ctdenghi.value_low = zfi_tb_denghi.ctdenghi
    right outer join zfi_i_denghi_i_log as itemDN on  itemDN.zdenghi = zfi_tb_denghi.zdenghi
                                                  and itemDN.gjahr   = zfi_tb_denghi.gjahr
    inner join       I_JournalEntry               on  I_JournalEntry.AccountingDocument = itemDN.accountingdocument
                                                  and I_JournalEntry.CompanyCode        = itemDN.accountingcompanycode
                                                  and I_JournalEntry.FiscalYear         = itemDN.accountingdocumentyear
  association [0..*] to ZFI_I_DENGHI_ITEMCUSTOM as _item on _item.idCustom = $projection.idCustom
{
  key concat(itemDN.zdenghi,concat(itemDN.gjahr,itemDN.item)) as idCustom,
      @EndUserText.label: 'Số đề nghị'
      @Consumption.valueHelpDefinition: [
        { entity:  { name:    'zfi_i_denghi_log',
                     element: 'zdenghi' }
        }]
      // ]
  key zfi_tb_denghi.zdenghi,
      @Consumption.valueHelpDefinition: [
      { entity:  { name:    'I_FiscalYearForCompanyCode',
                   element: 'FiscalYear' }
      }]
      // ]
  key zfi_tb_denghi.gjahr,
      @Consumption.valueHelpDefinition: [
        { entity:  { name:    'I_CompanyCodeStdVH',
                     element: 'CompanyCode' }
        }]
      // ]
      zfi_tb_denghi.companycode,
      zfi_i_ctdenghi.text                                     as ctdenghi_text,
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZFI_I_CTDENGHI', element: 'value_low' } }]
      @ObjectModel.text.element:[ 'ctdenghi_text' ]
      zfi_tb_denghi.ctdenghi,
      @EndUserText.label: 'Vendor/Customer'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_BusinessPartner', element: 'BusinessPartner' } }]
      zfi_tb_denghi.account,
      @Consumption.valueHelpDefinition: [
        { entity:  { name:    'ZCORE_I_USER',
                     element: 'UserID' }
        }]
      zfi_tb_denghi.pst_user,
      @EndUserText.label: 'Ngày đề nghị'
      zfi_tb_denghi.pst_date,
      //      zfi_tb_denghi.del_user,
      //      zfi_tb_denghi.del_date,
      //      zfi_tb_denghi.is_del,
      zfi_tb_denghi.nguoidenghi,
      zfi_tb_denghi.donvicongtac,
      zfi_tb_denghi.lydothanhtoan,
      zfi_tb_denghi.nguoinhan,
      zfi_tb_denghi.tennganhang,
      zfi_tb_denghi.sotaikhoannhan,
      zfi_tb_denghi.paymentmethod,
      zfi_tb_denghi.ctkemtheo,
      zfi_tb_denghi.is_del,
      zfi_tb_denghi.del_user,
      zfi_tb_denghi.del_date,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      zfi_tb_denghi.soducongno,
      //      @Semantics.amount.currencyCode: 'TransactionCurrency'
      //      abs( ZFI_I_AR_DNTU.AmountInTransactionCurrency )        as soDuCongNoTamUng,
      // item
      itemDN.accountingdocumentyear,
      itemDN.accountingcompanycode,
      itemDN.accountingdocument,
      itemDN.accountingdocumentitem,
      itemDN.transactioncurrency,
      I_JournalEntry.AccountingDocCreatedByUser,
      @Semantics.amount.currencyCode: 'transactioncurrency'
      itemDN.vat,
      @Semantics.amount.currencyCode: 'transactioncurrency'
      itemDN.sotiendenghi,
      @Semantics.amount.currencyCode: 'transactioncurrency'
      itemDN.sotientruocthue,
      itemDN.supplier,
      itemDN.customer,
      itemDN.sohoadon,
      itemDN.ngayhoadon,
      itemDN.diengiai,
      //      spv.SupplierInvoice,
      _item
}
//where
//  zfi_tb_denghi.is_del is initial
