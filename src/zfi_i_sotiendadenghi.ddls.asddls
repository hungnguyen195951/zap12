//*----------------------------------------------------------------------*
//* Citek JSC.
//* (C) Copyright Citek JSC.
//* All Rights Reserved
//*----------------------------------------------------------------------*
//* Application : Số tiền đã đề nghị
//* Creation Date: 24.11.2023
//* Created by: NganNM
//*----------------------------------------------------------------------*
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Số tiền đã đề nghị'
define view entity zfi_i_sotiendadenghi
  as select from zfi_tb_denghi_i
  inner join zfi_tb_denghi on zfi_tb_denghi.zdenghi = zfi_tb_denghi_i.zdenghi
                          and zfi_tb_denghi.gjahr = zfi_tb_denghi_i.gjahr
{
  key zfi_tb_denghi_i.accountingdocumentyear,
  key zfi_tb_denghi_i.accountingcompanycode,
  key zfi_tb_denghi_i.accountingdocument,
  zfi_tb_denghi_i.transactioncurrency,
  @Semantics.amount.currencyCode : 'transactioncurrency'
  sum(zfi_tb_denghi_i.vat) as vat,
  @Semantics.amount.currencyCode : 'transactioncurrency'
  sum(zfi_tb_denghi_i.sotiendenghi) as sotiendenghi,
  @Semantics.amount.currencyCode : 'transactioncurrency'
  sum(zfi_tb_denghi_i.sotientruocthue) as sotientruocthue
}
where zfi_tb_denghi.is_del is initial
group by zfi_tb_denghi_i.accountingdocumentyear,
         zfi_tb_denghi_i.accountingcompanycode,
         zfi_tb_denghi_i.accountingdocument,
         zfi_tb_denghi_i.transactioncurrency
