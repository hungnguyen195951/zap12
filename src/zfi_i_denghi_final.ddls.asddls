//*----------------------------------------------------------------------*
//* Citek JSC.
//* (C) Copyright Citek JSC.
//* All Rights Reserved
//*----------------------------------------------------------------------*
//* Application : DNTT - DNTU - Final for UI
//* Creation Date: 21.11.2023
//* Created by: NganNM
//*----------------------------------------------------------------------*
// 1 HD - 1 NCC
@AccessControl.authorizationCheck: #CHECK
@Metadata.ignorePropagatedAnnotations: true
@EndUserText.label: 'Đề nghị thanh toán/ đề nghị tạm ứng'
@Metadata.allowExtensions: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZFI_I_DENGHI_FINAL
  with parameters
    @Environment.systemField: #SYSTEM_DATE
    P_KeyDate : vdm_v_key_date,
    @Consumption.valueHelpDefinition: [{ entity: { name: 'ZFI_I_CTDENGHI', element: 'value_low' } }]
    p_ctu     : zde_ctdenghi
  //    @Consumption.valueHelpDefinition: [{ entity: { name: 'I_BusinessPartner', element: 'BusinessPartner' } }]
  //    p_partner : lifnr
  as select from    zfi_i_denghi( P_KeyDate: $parameters.P_KeyDate, p_ctu : $parameters.p_ctu )
    left outer join zfi_i_sotiendadenghi                             on  zfi_i_sotiendadenghi.accountingcompanycode  = zfi_i_denghi.CompanyCode
                                                                     and zfi_i_sotiendadenghi.accountingdocument     = zfi_i_denghi.AccountingDocument
                                                                     and zfi_i_sotiendadenghi.accountingdocumentyear = zfi_i_denghi.FiscalYear
    left outer join I_BusinessPartner                                on I_BusinessPartner.BusinessPartner = zfi_i_denghi.BusinessPartner
    left outer join ZFI_I_AR_DNTU(P_KeyDate : $parameters.P_KeyDate) on  ZFI_I_AR_DNTU.CompanyCode         = zfi_i_denghi.CompanyCode
                                                                     and ZFI_I_AR_DNTU.Supplier            = zfi_i_denghi.Supplier
                                                                     and ZFI_I_AR_DNTU.TransactionCurrency = zfi_i_denghi.TransactionCurrency
    left outer join ZCORE_I_PROFILE_COMPANYCODE                      on ZCORE_I_PROFILE_COMPANYCODE.CompanyCode = zfi_i_denghi.CompanyCode
  association [0..1] to I_CompanyCode         as _CompanyCode         on _CompanyCode.CompanyCode = zfi_i_denghi.CompanyCode
  association [0..*] to I_BusinessPartnerBank as _BusinessPartnerBank on _BusinessPartnerBank.BusinessPartner = zfi_i_denghi.BusinessPartner
{
            @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CompanyCode', element: 'CompanyCode' } }]
  key       zfi_i_denghi.CompanyCode,
  key       zfi_i_denghi.AccountingDocument,
  key       zfi_i_denghi.FiscalYear,
  key       zfi_i_denghi.TransactionCurrency,
  key       zfi_i_denghi.DueCalculationBaseDate,
            zfi_i_denghi.AccountingDocumentType,
            zfi_i_denghi.AccountingDocumentHeaderText,
            @Consumption.valueHelpDefinition: [{ entity: { name: 'ZCORE_I_USER', element: 'UserID' } }]
            zfi_i_denghi.AccountingDocCreatedByUser,
            zfi_i_denghi.DocumentItemText,
            zfi_i_denghi.DocumentReferenceID,
            zfi_i_denghi.PostingDate,
            zfi_i_denghi.DocumentDate,
            zfi_i_denghi.Customer,
            zfi_i_denghi.Supplier,
            zfi_i_denghi.AssignmentReference,
            zfi_i_denghi.FinancialAccountType,
            zfi_i_denghi.DocItemType,
            @Semantics.amount.currencyCode: 'TransactionCurrency'
            abs( ZFI_I_AR_DNTU.AmountInTransactionCurrency )                                                                                 as soDuCongNoTamUng,
            @Semantics.amount.currencyCode: 'TransactionCurrency'
            case when zfi_i_sotiendadenghi.sotientruocthue is null then zfi_i_denghi.soTienTruocThue
                 else zfi_i_denghi.soTienTruocThue - zfi_i_sotiendadenghi.sotientruocthue
            end                                                                                                                              as soTienTruocThue,
            @Semantics.amount.currencyCode: 'TransactionCurrency'
            zfi_i_denghi.soTienTruocThue                                                                                                     as soTienTruocThueDoc,

            @Semantics.amount.currencyCode: 'TransactionCurrency'
            case when zfi_i_sotiendadenghi.vat is null then  zfi_i_denghi.VAT
                 else zfi_i_denghi.VAT  - zfi_i_sotiendadenghi.vat
            end                                                                                                                              as VAT,
            @Semantics.amount.currencyCode: 'TransactionCurrency'
            zfi_i_denghi.VAT                                                                                                                 as VATDoc,

            @Semantics.amount.currencyCode: 'TransactionCurrency'
            case when zfi_i_sotiendadenghi.sotiendenghi is null then zfi_i_denghi.soTienDeNghi // abs( zfi_i_denghi.soTienDeNghi )
                 else zfi_i_denghi.soTienDeNghi - zfi_i_sotiendadenghi.sotiendenghi //abs( zfi_i_denghi.soTienDeNghi ) - zfi_i_sotiendadenghi.sotiendenghi
            end                                                                                                                              as soTienDeNghi,
            @Semantics.amount.currencyCode: 'TransactionCurrency'
            abs( zfi_i_denghi.soTienTamUng )                                                                                                 as soTienTamUng,
            @Semantics.amount.currencyCode: 'TransactionCurrency'
            zfi_i_denghi.soTienDeNghi                                                                                                        as soTienDeNghiDoc,
            @Consumption.valueHelpDefinition: [{ entity: { name: 'I_BusinessPartner', element: 'BusinessPartner' } }]
            zfi_i_denghi.BusinessPartner,
            concat_with_space(_CompanyCode._OrgAddressDefaultRprstn.AddresseeName1, _CompanyCode._OrgAddressDefaultRprstn.AddresseeName2, 1) as CompanyCodeName,
            concat_with_space(_CompanyCode._OrgAddressDefaultRprstn.StreetName,
            concat_with_space(_CompanyCode._OrgAddressDefaultRprstn.StreetPrefixName1,
            concat_with_space(_CompanyCode._OrgAddressDefaultRprstn.StreetPrefixName2,
            _CompanyCode._OrgAddressDefaultRprstn.StreetSuffixName1,1),1),1)                                                                 as CompanyCodeAddress,
            _CompanyCode._OrgAddressDefaultRprstn._CurrentDfltLandlinePhoneNmbr.PhoneAreaCodeSubscriberNumber                                as CompanyCodePhoneNumber,
            _CompanyCode._OrgAddressDefaultRprstn._CurrentDfltEmailAddress.EmailAddress                                                      as CompanyCodeEmailAddress,
            _CompanyCode._OrgAddressDefaultRprstn._MainWebsiteURL.UniformResourceIdentifier                                                  as CompanyCodeWebsite,
            _CompanyCode._OrgAddressDefaultRprstn._CurrentDfltFaxNumber.FaxAreaCodeSubscriberNumber                                          as CompanyCodeFax,
            case when zfi_i_denghi.DocumentItemText is not initial
                 then zfi_i_denghi.DocumentItemText
                 else zfi_i_denghi.AccountingDocumentHeaderText end                                                                          as DienGiai,
            case when zfi_i_sotiendadenghi.sotiendenghi = zfi_i_denghi.soTienDeNghi  then 3 //complete
                 when zfi_i_sotiendadenghi.accountingdocument is null then 1 // not process
                 when zfi_i_sotiendadenghi.accountingdocument is not null then 2
                 else 1 // not complete
            end                                                                                                                              as StatusCritical,
            case when zfi_i_sotiendadenghi.sotiendenghi = zfi_i_denghi.soTienDeNghi then 'Complete' //complete
                 when zfi_i_sotiendadenghi.accountingdocument is null then 'Not been processed' // not process
                 when zfi_i_sotiendadenghi.accountingdocument is not null then 'Not completed'
                 else  'Not been processed'// not complete
            end                                                                                                                              as Status,
            zfi_i_denghi.Account,
            //      defaultPartnerBank.BankName,
            //      defaultPartnerBank.BankAccount,
            //      defaultPartnerBank.BankAccountHolderName,
            case when ( I_BusinessPartner.OrganizationBPName2 is initial and I_BusinessPartner.OrganizationBPName3 is initial and I_BusinessPartner.OrganizationBPName4 is initial )
                  and I_BusinessPartner.OrganizationBPName1 is not initial then I_BusinessPartner.OrganizationBPName1
                 when ( I_BusinessPartner.OrganizationBPName2 is initial and I_BusinessPartner.OrganizationBPName3 is initial and I_BusinessPartner.OrganizationBPName4 is initial )
                  and I_BusinessPartner.OrganizationBPName1 is initial then I_BusinessPartner.BusinessPartnerFullName
                 else concat_with_space( I_BusinessPartner.OrganizationBPName2,
                      concat_with_space( I_BusinessPartner.OrganizationBPName3, I_BusinessPartner.OrganizationBPName4, 1 ), 1 ) end          as AccountName,
            cast( case when $parameters.p_ctu = 'B' then '-'
                 else 'X' end as abap_boolean preserving type )                                                                              as TamUngVisible,

            _BusinessPartnerBank
}
where
  (
       zfi_i_sotiendadenghi.sotiendenghi       <> zfi_i_denghi.soTienDeNghi
    or zfi_i_sotiendadenghi.accountingdocument is null
  )
