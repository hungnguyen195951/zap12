@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Custom id'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZFI_I_DENGHI_IDCUSTOM
  as select from     zfi_tb_denghi
    inner join       zfi_i_ctdenghi               on zfi_i_ctdenghi.value_low = zfi_tb_denghi.ctdenghi
    right outer join zfi_i_denghi_i_log as itemDN on  itemDN.zdenghi = zfi_tb_denghi.zdenghi
                                                  and itemDN.gjahr   = zfi_tb_denghi.gjahr
{
  key concat(zfi_tb_denghi.zdenghi,concat(zfi_tb_denghi.gjahr,itemDN.item)) as idCustom,
  key zfi_tb_denghi.zdenghi,
  key zfi_tb_denghi.gjahr
}
