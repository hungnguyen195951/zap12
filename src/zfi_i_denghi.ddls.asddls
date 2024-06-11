//*----------------------------------------------------------------------*
//* Citek JSC.
//* (C) Copyright Citek JSC.
//* All Rights Reserved
//*----------------------------------------------------------------------*
//* Application : DNTT - DNTU
//* Creation Date: 21.11.2023
//* Created by: NganNM
//*----------------------------------------------------------------------*
// 1 HD - 1 NCC
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true
@EndUserText.label: 'Đề nghị thanh toán/ đề nghị tạm ứng'
@ObjectModel.supportedCapabilities: [#CDS_MODELING_ASSOCIATION_TARGET, #CDS_MODELING_DATA_SOURCE, #SQL_DATA_SOURCE,
                                      #EXTRACTION_DATA_SOURCE]
@Metadata.allowExtensions: true
define view entity zfi_i_denghi
  with parameters
    @Environment.systemField: #SYSTEM_DATE
    P_KeyDate : vdm_v_key_date,
    @Consumption.valueHelpDefinition: [{ entity: { name: 'ZFI_I_CTDENGHI', element: 'value_low' } }]
    p_ctu     : zde_ctdenghi
  //    p_partner : lifnr
  as select distinct from I_JournalEntry
    inner join            I_OperationalAcctgDocItem                                                       on  I_OperationalAcctgDocItem.AccountingDocument = I_JournalEntry.AccountingDocument
                                                                                                          and I_OperationalAcctgDocItem.CompanyCode        = I_JournalEntry.CompanyCode
                                                                                                          and I_OperationalAcctgDocItem.FiscalYear         = I_JournalEntry.FiscalYear
    left outer join       zfi_i_taxitem                                                                   on  zfi_i_taxitem.AccountingDocument = I_JournalEntry.AccountingDocument
                                                                                                          and zfi_i_taxitem.CompanyCode        = I_JournalEntry.CompanyCode
                                                                                                          and zfi_i_taxitem.FiscalYear         = I_JournalEntry.FiscalYear
    left outer join       zfi_i_denghi_amt( P_KeyDate: $parameters.P_KeyDate, p_ctu : $parameters.p_ctu ) on  zfi_i_denghi_amt.AccountingDocument = I_JournalEntry.AccountingDocument
                                                                                                          and zfi_i_denghi_amt.CompanyCode        = I_JournalEntry.CompanyCode
                                                                                                          and zfi_i_denghi_amt.FiscalYear         = I_JournalEntry.FiscalYear
    left outer join       I_CustomerToBusinessPartner                                                     on I_CustomerToBusinessPartner.Customer = I_OperationalAcctgDocItem.Customer
    left outer join       I_BusinessPartner as CustomerBP                                                 on CustomerBP.BusinessPartnerUUID = I_CustomerToBusinessPartner.BusinessPartnerUUID
    left outer join       I_SupplierToBusinessPartner                                                     on I_SupplierToBusinessPartner.Supplier = I_OperationalAcctgDocItem.Supplier
    left outer join       I_BusinessPartner as SupplierBP                                                 on SupplierBP.BusinessPartnerUUID = I_SupplierToBusinessPartner.BusinessPartnerUUID

{
  key I_JournalEntry.CompanyCode,
  key I_JournalEntry.AccountingDocument,
  key I_JournalEntry.FiscalYear,
      I_JournalEntry.AccountingDocumentHeaderText,
      I_JournalEntry.AccountingDocCreatedByUser,
      zfi_i_denghi_amt.DocumentItemText,
      I_JournalEntry.AccountingDocumentType,
      I_JournalEntry.DocumentReferenceID,
      case when I_JournalEntry.AccountingDocumentType = 'RE'
          then substring( I_JournalEntry.OriginalReferenceDocument, 1, 10 )
          else '' end                                            as SupplierInvoice,
      case when I_JournalEntry.AccountingDocumentType = 'RE'
          then substring( I_JournalEntry.OriginalReferenceDocument,11, 4 )
          else '' end                                            as SupplierInvoiceYear,
      I_JournalEntry.PostingDate,
      I_JournalEntry.DocumentDate,
      I_OperationalAcctgDocItem.Customer,
      I_OperationalAcctgDocItem.DueCalculationBaseDate,
      I_OperationalAcctgDocItem.Supplier,
      cast( case when I_OperationalAcctgDocItem.Customer is not initial then I_OperationalAcctgDocItem.Customer
      when I_OperationalAcctgDocItem.Supplier is not initial then I_OperationalAcctgDocItem.Supplier
      end as lifnr )                                             as Account,
      cast( case when I_OperationalAcctgDocItem.Customer is not initial then CustomerBP.BusinessPartner
      when I_OperationalAcctgDocItem.Supplier is not initial then SupplierBP.BusinessPartner
      end as abap.char(10) )                                     as BusinessPartner,
      I_OperationalAcctgDocItem.AssignmentReference,
      I_OperationalAcctgDocItem.FinancialAccountType,
      case I_OperationalAcctgDocItem.AccountingDocumentCategory
          when 'S' then //Noted items
              'Note items'
          when 'V' then //Parked document
              'Parked items'
          when 'W' then //Parked document with change of document ID
              'Parked items'
          else          //Normal Document
              case when I_OperationalAcctgDocItem.SpecialGLCode = '' then
                  'Normal Items'
              else
                  'Special GL Items'
              end
      end                                                        as DocItemType,
      I_OperationalAcctgDocItem.TransactionCurrency,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      case when zfi_i_taxitem.AccountingDocument is not null or zfi_i_taxitem.AccountingDocument is not initial
           then zfi_i_taxitem.TaxBaseAmountInTransCrcy
           else zfi_i_denghi_amt.AmountInTransactionCurrency end as soTienTruocThue,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      case when zfi_i_taxitem.AccountingDocument is not null or zfi_i_taxitem.AccountingDocument is not initial
           then zfi_i_taxitem.AmountInTransactionCurrency
           else cast( 0 as abap.curr( 23, 2 ) ) end              as VAT,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      ( $projection.soTienTruocThue + $projection.VAT )          as soTienDeNghi,
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      zfi_i_denghi_amt.AmountInTransactionCurrency               as soTienTamUng
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
  and(
              I_OperationalAcctgDocItem.PostingDate                <= $parameters.P_KeyDate
    and(
              I_OperationalAcctgDocItem.ClearingDate               is initial
      or      I_OperationalAcctgDocItem.ClearingDate               > $parameters.P_KeyDate
    )
  )
  //Type
  and         I_OperationalAcctgDocItem.AccountingDocumentCategory <>   'D'
  and         I_OperationalAcctgDocItem.AccountingDocumentCategory <>   'M'
  and         I_JournalEntry.IsReversed                            is initial
  and         I_JournalEntry.IsReversal                            is initial
  and(
              I_OperationalAcctgDocItem.FinancialAccountType       =    'D'
    or        I_OperationalAcctgDocItem.FinancialAccountType       =    'K'
  )
union all select distinct from I_ParkedOplAcctgDocument
  inner join                   I_ParkedOplAcctgDocItem                                                          on  I_ParkedOplAcctgDocItem.SourceCompanyCode        = I_ParkedOplAcctgDocument.SourceCompanyCode
                                                                                                                and I_ParkedOplAcctgDocItem.SourceFiscalYear         = I_ParkedOplAcctgDocument.SourceFiscalYear
                                                                                                                and I_ParkedOplAcctgDocItem.SourceAccountingDocument = I_ParkedOplAcctgDocument.SourceAccountingDocument
  left outer join              zfi_i_taxitem                                                                    on  zfi_i_taxitem.AccountingDocument = I_ParkedOplAcctgDocument.SourceAccountingDocument
                                                                                                                and zfi_i_taxitem.CompanyCode        = I_ParkedOplAcctgDocument.SourceCompanyCode
                                                                                                                and zfi_i_taxitem.FiscalYear         = I_ParkedOplAcctgDocument.SourceFiscalYear
  left outer join              zfi_i_denghi_amt( P_KeyDate: $parameters.P_KeyDate, p_ctu : $parameters.p_ctu  ) on  zfi_i_denghi_amt.AccountingDocument = I_ParkedOplAcctgDocument.SourceAccountingDocument
                                                                                                                and zfi_i_denghi_amt.CompanyCode        = I_ParkedOplAcctgDocument.SourceCompanyCode
                                                                                                                and zfi_i_denghi_amt.FiscalYear         = I_ParkedOplAcctgDocument.SourceFiscalYear
  left outer join              I_CustomerToBusinessPartner                                                      on I_CustomerToBusinessPartner.Customer = I_ParkedOplAcctgDocItem.Customer
  left outer join              I_BusinessPartner as CustomerBP                                                  on CustomerBP.BusinessPartnerUUID = I_CustomerToBusinessPartner.BusinessPartnerUUID
  left outer join              I_SupplierToBusinessPartner                                                      on I_SupplierToBusinessPartner.Supplier = I_ParkedOplAcctgDocItem.Supplier
  left outer join              I_BusinessPartner as SupplierBP                                                  on SupplierBP.BusinessPartnerUUID = I_SupplierToBusinessPartner.BusinessPartnerUUID
{
  key I_ParkedOplAcctgDocument.SourceCompanyCode                 as CompanyCode,
  key I_ParkedOplAcctgDocument.SourceAccountingDocument          as AccountingDocument,
  key I_ParkedOplAcctgDocument.SourceFiscalYear                  as FiscalYear,
      I_ParkedOplAcctgDocument.AccountingDocumentHeaderText,
      I_ParkedOplAcctgDocument.AccountingDocCreatedByUser,
      zfi_i_denghi_amt.DocumentItemText,
      I_ParkedOplAcctgDocument.AccountingDocumentType,
      I_ParkedOplAcctgDocument.DocumentReferenceID,
      case when I_ParkedOplAcctgDocument.AccountingDocumentType = 'RE'
          then substring( I_ParkedOplAcctgDocument.OriginalReferenceDocument, 1, 10 )
          else '' end                                            as SupplierInvoice,
      case when I_ParkedOplAcctgDocument.AccountingDocumentType = 'RE'
          then substring( I_ParkedOplAcctgDocument.OriginalReferenceDocument,11, 4 )
          else '' end                                            as SupplierInvoiceYear,
      I_ParkedOplAcctgDocItem.PostingDate,
      I_ParkedOplAcctgDocItem.DocumentDate,
      I_ParkedOplAcctgDocItem.Customer,
      I_ParkedOplAcctgDocItem.DueCalculationBaseDate,
      I_ParkedOplAcctgDocItem.Supplier,
      cast( case when I_ParkedOplAcctgDocItem.Customer is not initial then I_ParkedOplAcctgDocItem.Customer
      when I_ParkedOplAcctgDocItem.Supplier is not initial then I_ParkedOplAcctgDocItem.Supplier
      end as lifnr )                                             as Account,
      cast( case when I_ParkedOplAcctgDocItem.Customer is not initial then CustomerBP.BusinessPartner
      when I_ParkedOplAcctgDocItem.Supplier is not initial then SupplierBP.BusinessPartner
      end as abap.char(10) )                                     as BusinessPartner,
      I_ParkedOplAcctgDocItem.AssignmentReference,
      I_ParkedOplAcctgDocItem.FinancialAccountType,
      case I_ParkedOplAcctgDocItem.AccountingDocumentCategory
          when 'S' then //Noted items
              'Note items (parked)'
          when 'V' then //Parked document
              'Parked items (parked)'
          when 'W' then //Parked document with change of document ID
              'Parked items (parked)'
          else          //Normal Document
              case when I_ParkedOplAcctgDocItem.SpecialGLCode = '' then
                  'Normal items (parked)'
              else
                  'Special GL Items (parked)'
              end
      end                                                        as DocItemType,
      I_ParkedOplAcctgDocItem.TransactionCurrency,
      case when zfi_i_taxitem.AccountingDocument is not null or zfi_i_taxitem.AccountingDocument is not initial
           then zfi_i_taxitem.TaxBaseAmountInTransCrcy
           else zfi_i_denghi_amt.AmountInTransactionCurrency end as soTienTruocThue,

      case when zfi_i_taxitem.AccountingDocument is not null or zfi_i_taxitem.AccountingDocument is not initial
           then zfi_i_taxitem.AmountInTransactionCurrency
           else cast( 0 as abap.curr( 23, 2 ) ) end              as VAT,
      ( $projection.soTienTruocThue + $projection.VAT )          as soTienDeNghi,
      zfi_i_denghi_amt.AmountInTransactionCurrency               as soTienTamUng
}
where
  //AR - AP Line items
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
          //          and I_ParkedOplAcctgDocItem.DebitCreditCode            =    'H'//NganNM : lên hoá đơn điều chỉnh công nợ
        )
      )
    )
    or(
              $parameters.p_ctu                                  =    'B'
      and     I_ParkedOplAcctgDocItem.FinancialAccountType       =    'K'
      and     I_ParkedOplAcctgDocItem.GLAccount                  like '00141%'
    )
  )
  and         I_ParkedOplAcctgDocItem.PostingDate                <= $parameters.P_KeyDate
  and         I_ParkedOplAcctgDocItem.AccountingDocumentCategory <>   'D'
  and         I_ParkedOplAcctgDocItem.AccountingDocumentCategory <>   'M'
  and(
              //              I_ParkedOplAcctgDocItem.Customer                   = $parameters.p_partner and
              I_ParkedOplAcctgDocItem.FinancialAccountType       =    'D'
    or        I_ParkedOplAcctgDocItem.FinancialAccountType       =    'K'
    //    and
  )
