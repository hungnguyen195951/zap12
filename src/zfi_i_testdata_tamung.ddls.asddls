@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'test data tam ung'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZFI_I_TESTDATA_TAMUNG
  as select from zfi_tb_denghi as dn
{
  key zdenghi             as Zdenghi,
  key gjahr               as Gjahr,
      companycode         as Companycode,
      ctdenghi            as Ctdenghi,
      account             as Account,
      pst_user            as PstUser,
      pst_date            as PstDate,
      del_user            as DelUser,
      del_date            as DelDate,
      is_del              as IsDel,
      nguoidenghi         as Nguoidenghi,
      donvicongtac        as Donvicongtac,
      lydothanhtoan       as Lydothanhtoan,
      nguoinhan           as Nguoinhan,
      tennganhang         as Tennganhang,
      sotaikhoannhan      as Sotaikhoannhan,
      nguoithanhtoan      as Nguoithanhtoan,
      paymentmethod       as Paymentmethod,
      ctkemtheo           as Ctkemtheo,
      currency            as Currency,
      @Semantics.amount.currencyCode: 'Currency'
      sotientamungkytruoc as Sotientamungkytruoc,
      @Semantics.amount.currencyCode: 'Currency'
      sotientamung        as Sotientamung,
      @Semantics.amount.currencyCode: 'Currency'
      soducongno          as Soducongno,
      @Semantics.amount.currencyCode: 'Currency'
      sotienco            as Sotienco,
      @Semantics.amount.currencyCode: 'Currency'
      sotienno            as Sotienno,
      @Semantics.amount.currencyCode: 'Currency'
      sumsotiendachi      as Sumsotiendachi
}
