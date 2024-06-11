@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Đề nghị'
@Metadata.allowExtensions: true
define root view entity ZFI_I_DENGHI_LOG_full
  as select from zfi_tb_denghi
    inner join   zfi_i_ctdenghi on zfi_i_ctdenghi.value_low = zfi_tb_denghi.ctdenghi
{

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
      zfi_i_ctdenghi.text as ctdenghi_text,
      @ObjectModel.text.element:[ 'ctdenghi_text' ]
      zfi_tb_denghi.ctdenghi,
      zfi_tb_denghi.account,
      zfi_tb_denghi.pst_user,
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
      zfi_tb_denghi.del_date
}
