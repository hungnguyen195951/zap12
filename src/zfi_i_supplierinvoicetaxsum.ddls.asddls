@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sum supplier invoice tax'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZFI_I_SUPPLIERINVOICETAXSUM
  as select from I_SupplierInvoiceTaxAPI01
    inner join   I_SupplierInvoiceAPI01 on  I_SupplierInvoiceTaxAPI01.SupplierInvoice = I_SupplierInvoiceAPI01.SupplierInvoice
                                        and I_SupplierInvoiceTaxAPI01.FiscalYear      = I_SupplierInvoiceAPI01.FiscalYear
{
  key I_SupplierInvoiceTaxAPI01.SupplierInvoice,
  key I_SupplierInvoiceTaxAPI01.FiscalYear,
      I_SupplierInvoiceTaxAPI01.DocumentCurrency,
      @Semantics.amount.currencyCode: 'DocumentCurrency'
      sum( I_SupplierInvoiceTaxAPI01.TaxAmount ) as TaxAmount
}
group by
  I_SupplierInvoiceTaxAPI01.SupplierInvoice,
  I_SupplierInvoiceTaxAPI01.FiscalYear,
  I_SupplierInvoiceTaxAPI01.DocumentCurrency
