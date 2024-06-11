*----------------------------------------------------------------------*
* Citek JSC.
* (C) Copyright Citek JSC.
* All Rights Reserved
*----------------------------------------------------------------------*
* Application : Tạo chứng từ đề nghị
* Creation Date: 24.11.2023
* Created by: NganNM
*----------------------------------------------------------------------*
class zfi_cl_api_denghi definition
  public
  final
  create public .

  public section.
    interfaces if_http_service_extension .
  protected section.
  private section.
    types:
      begin of ty_request_item,
        stt                    type string,
        ngayhoadon             type string,
        sohoadon               type string,
        diengiai               type string,
        accountingdocumentyear type string,
        accountingdocument     type string,
        accountingcompanycode  type string,
        accountingdocumentitem type string,
        transactioncurrency    type string,
        vat_ui                 type string,
        vat                    type string,

        sotiendenghi_ui        type string,
        sotiendenghi           type string,

        sotientruocthue        type string,
        sotientruocthue_ui     type string,
        supplier               type string,
        customer               type string,


      end of  ty_request_item,
      begin of ty_request,
        companycode            type string,
        ctdenghi               type string,
        account                type string,
        nguoidenghi            type string,
        donvicongtac           type string,
        lydothanhtoan          type string,
        nguoinhan              type string,
        tennganhang            type string,
        sotaikhoannhan         type string,
        paymentmethod          type string,
        ctkemtheo              type string,
        company_code_name      type string,
        company_code_adress    type string,
        company_code_phone     type string,
        company_code_fax       type string,
        company_code_email     type string,
        company_code_web       type string,
        title                  type string,
        sum_tong_cong          type string,
        thoihantamung          type string,
        soducongno             type string,
        soducongno_ui          type string,
        sotientamung           type string,
        sotientamung_ui        type string,
        transactioncurrency    type string,
        accountingdocumentyear type string, "for tạm ứng
        accountingdocument     type string, "for tạm ứng
        accountingcompanycode  type string, "for tạm ứng
        ngaythangnam           type string,
        items                  type standard table of ty_request_item with empty key,
      end of  ty_request,
      begin of ty_data_item,
        item                   type buzei,
        ngayhoadon             type dats,
        sohoadon               type c length 40,
        diengiai               type string,
        accountingdocument     type i_journalentryitem-accountingdocument,
        accountingdocumentyear type i_journalentryitem-fiscalyear,
        accountingcompanycode  type i_journalentryitem-companycode,
        accountingdocumentitem type i_journalentryitem-accountingdocumentitem,
        transactioncurrency    type waers,
        vat                    type i_journalentryitem-amountincompanycodecurrency,
        vat_ui                 type string,

        sotiendenghi           type i_journalentryitem-amountincompanycodecurrency,
        sotiendenghi_ui        type string,

        sotientruocthue        type i_journalentryitem-amountincompanycodecurrency,
        sotientruocthue_ui     type string,
        supplier               type lifnr,
        customer               type lifnr,

      end of ty_data_item,
      begin of ty_data,
        companycode            type bukrs,
        ctdenghi               type zde_ctdenghi,
        account                type lifnr,
        nguoidenghi            type string,
        donvicongtac           type string,
        lydothanhtoan          type string,
        nguoinhan              type string,
        tennganhang            type string,
        sotaikhoannhan         type string,
        paymentmethod          type string,
        ctkemtheo              type string,
        company_code_name      type string,
        company_code_adress    type string,
        company_code_phone     type string,
        company_code_fax       type string,
        company_code_email     type string,
        company_code_web       type string,
        sum_tong_cong          type string,
        title                  type string,
        thoihantamung          type dats,
        soducongno             type i_journalentryitem-amountincompanycodecurrency,
        soducongno_ui          type string,
        sotientamung           type i_journalentryitem-amountincompanycodecurrency,
        sotientamung_ui        type string,
        transactioncurrency    type waers,
        accountingdocument     type i_journalentryitem-accountingdocument, "for tạm ứng
        accountingdocumentyear type i_journalentryitem-fiscalyear, "for tạm ứng
        accountingcompanycode  type i_journalentryitem-companycode, "for tạm ứng
        ngaythangnam           type string,
        items                  type standard table of ty_data_item with empty key,
      end of ty_data,
      begin of ty_response,
        message type string,
        pdf     type string,
        zdenghi type string,
      end of  ty_response.
    data:
      gs_data       type ty_data,
      request_data  type ty_request,
      response_data type ty_response.

    methods :
      check_data_thanhtoan,
      post_data_thanhtoan,

      check_data_tamung,
      post_data_tamung.
ENDCLASS.



CLASS ZFI_CL_API_DENGHI IMPLEMENTATION.


  method check_data_tamung.
    gs_data = corresponding #( request_data except items ).
    if  gs_data-transactioncurrency = 'VND'.
      gs_data-sotientamung = gs_data-sotientamung / 100.
      gs_data-soducongno = gs_data-soducongno / 100.
    endif.
  endmethod.


  method check_data_thanhtoan.
    gs_data    = corresponding #( request_data except items ).
    gs_data-account       = |{ request_data-account alpha = in }|.
    loop at request_data-items reference into data(ls_item).
      append value #(
          item                   = |{ ls_item->stt                    alpha = in }|
          ngayhoadon             = |{ ls_item->ngayhoadon+6(4) }{ ls_item->ngayhoadon+3(2) }{ ls_item->ngayhoadon(2) }| "dd/mm/yyyy
          sohoadon               = ls_item->sohoadon
          diengiai               = ls_item->diengiai
          accountingdocument     = |{ ls_item->accountingdocument     alpha = in }|
          accountingcompanycode  = ls_item->accountingcompanycode
          accountingdocumentyear = ls_item->accountingdocumentyear
          accountingdocumentitem = |{ ls_item->accountingdocumentitem alpha = in }|
          transactioncurrency    = ls_item->transactioncurrency
          vat                    = ls_item->vat
          vat_ui                 = ls_item->vat_ui
          sotiendenghi_ui        = ls_item->sotiendenghi_ui
          sotiendenghi           = ls_item->sotiendenghi
          sotientruocthue        = ls_item->sotientruocthue
          sotientruocthue_ui     = ls_item->sotientruocthue_ui
          supplier               = |{ ls_item->supplier               alpha = in }|
          customer               = |{ ls_item->customer               alpha = in }|
      ) to gs_data-items.
    endloop.


  endmethod.


  method if_http_service_extension~handle_request.
*$-----------------------------------------------------------$
* Handle request
*$-----------------------------------------------------------$
    data:
      request_method type string,
      request_body   type string,
      response_body  type string.

    request_method = request->get_header_field( i_name = '~request_method' ).
    request_body = request->get_text( ).
    case request_method.
      when 'POST'.
*---$ Get request
        xco_cp_json=>data->from_string( request_body )->apply( value #(
      ( xco_cp_json=>transformation->camel_case_to_underscore ) ) )->write_to( ref #( request_data ) ).

        if request_data-ctdenghi = 'A'.
          check_data_thanhtoan(  ).
          post_data_thanhtoan(  ).
        elseif request_data-ctdenghi = 'B'.
          check_data_tamung(  ).
          post_data_tamung(  ).
        endif.
        response_body = xco_cp_json=>data->from_abap( response_data )->apply( value #(
               ( xco_cp_json=>transformation->underscore_to_camel_case )
        ) )->to_string( ).
        response->set_text( i_text = response_body ).
    endcase.
  endmethod.


  method post_data_tamung.
    data:
      lv_number  type cl_numberrange_runtime=>nr_number,
      lv_zdenghi type zde_denghi,
      xmldata    type string.
    try.
        call method cl_numberrange_runtime=>number_get
          exporting
            nr_range_nr = '02'
            object      = 'ZNR_DENGHI'
            quantity    = 1
            toyear      = |{ sy-datum(4) }|
          importing
            number      = lv_number.
      catch cx_nr_object_not_found.
      catch cx_number_ranges.
    endtry.
    lv_zdenghi = |{ lv_number alpha = in }|.

    data:
      ls_fi_tb_denghi   type zfi_tb_denghi,
      ls_fi_tb_denghi_i type zfi_tb_denghi_i.
    ls_fi_tb_denghi = corresponding #( gs_data ).
    ls_fi_tb_denghi-zdenghi = lv_zdenghi.
    ls_fi_tb_denghi-gjahr = sy-datum(4).
    ls_fi_tb_denghi-pst_user = sy-uname.
    ls_fi_tb_denghi-pst_date = sy-datum.
    modify zfi_tb_denghi from @ls_fi_tb_denghi.

    ls_fi_tb_denghi_i = corresponding #( gs_data ).
    ls_fi_tb_denghi_i-zdenghi = lv_zdenghi.
    ls_fi_tb_denghi_i-gjahr = sy-datum(4).
    ls_fi_tb_denghi_i-item = 1.
    ls_fi_tb_denghi_i-sotiendenghi = ls_fi_tb_denghi-sotientamung.
    modify zfi_tb_denghi_i from @ls_fi_tb_denghi_i.

    commit work and wait.
    data(lv_sotientamung) = gs_data-sotientamung.
    lv_sotientamung = lv_sotientamung * 100.
    data(lv_amt_in_word) = zcore_cl_amount_in_words=>read_amount( i_amount = lv_sotientamung i_waers = gs_data-transactioncurrency i_lang = 'VI' ).
    xmldata = |<?xml version="1.0" encoding="UTF-8"?>| &&
              |<form1>| &&
              |<MAIN>| &&
              |<Heading>| &&
              |<companyCodeName><![CDATA[{ gs_data-company_code_name }]]></companyCodeName>|         &&
              |<companyCodeAdress>{ gs_data-company_code_adress }</companyCodeAdress>|               &&
              |<Tel_Fax>|                                                                            &&
              |<companyCodePhone>Tel: { gs_data-company_code_phone }</companyCodePhone>|             &&
              |<companyCodeFax>Fax: { gs_data-company_code_fax }</companyCodeFax>|                   &&
              |</Tel_Fax>|                                                                           &&
              |<Email_Web>|                                                                          &&
              |<companyCodeEmail>Email: { gs_data-company_code_email }</companyCodeEmail>|           &&
              |<companyCodeWeb><![CDATA[Website: { gs_data-company_code_web }]]></companyCodeWeb>|   &&
              |</Email_Web>|                                                                         &&
              |</Heading>|                                                                           &&
              |</MAIN>|                                                                              &&
              |<kinhGui>| &&
              |<title>{ gs_data-title }</title>| &&
              |<date>Ngày { sy-datum+6(2) } tháng { sy-datum+4(2) } năm { sy-datum(4) }</date>| &&
              |</kinhGui>| &&
              |<HeaderInfo>| &&
              |<So>{ lv_zdenghi }</So>| &&
              |<ToiTen>{ gs_data-nguoidenghi }</ToiTen>| &&
              |<DonViCongTac>{ gs_data-donvicongtac }</DonViCongTac>| &&
              |<DeNghiChoTamUng>{ gs_data-sotientamung_ui }</DeNghiChoTamUng>| &&
              |<BangChu>{ lv_amt_in_word }</BangChu>| &&
              |<NoiDungTamUng><![CDATA[{ gs_data-lydothanhtoan }]]></NoiDungTamUng>| &&
              |<ThoiHanThanhToan>{ request_data-thoihantamung }</ThoiHanThanhToan>| &&
              |<SoDuCongNo>{ gs_data-soducongno_ui }</SoDuCongNo>| &&
              |<HinhThucTamUng>{ gs_data-paymentmethod }</HinhThucTamUng>| &&
              |<TenTaiKhoan>{ gs_data-nguoinhan }</TenTaiKhoan>| &&
              |<SoTaiKhoan>{ gs_data-sotaikhoannhan }</SoTaiKhoan>| &&
              |<NganHang>{ gs_data-tennganhang }</NganHang>| &&
              |</HeaderInfo>| &&
              |<Sign/>| &&
              |</form1>|.

    data :
      xmldata_utf8   type string,
      xmldata_binary type xstring,
      xmldata_base64 type string.
    xmldata_binary = cl_abap_conv_codepage=>create_out( )->convert( xmldata ).
    xmldata_base64 = cl_web_http_utility=>encode_x_base64( unencoded = xmldata_binary ).

    data: lo_api_adobe     type ref to zcl_api_adobe,
          ls_request_pdf   type zcl_api_adobe=>ty_request,
          pdf_file_contant type string,
          adobe_response   type string.
    lo_api_adobe = new #(  ).
    ls_request_pdf-xdp_template = 'TAMUNG/TAMUNG'.
    ls_request_pdf-zxml_data = xmldata_base64.
    ls_request_pdf-report = 'TAMUNG'.
    ls_request_pdf-id = |{ lv_zdenghi }{ sy-datum(4) }|.

    lo_api_adobe->get_pdf( exporting request = ls_request_pdf importing pdf64 = pdf_file_contant response = adobe_response ).
    response_data-message = adobe_response.
    response_data-pdf = pdf_file_contant.
    response_data-zdenghi = lv_zdenghi.
  endmethod.


  method post_data_thanhtoan.
    data:
      lv_number   type cl_numberrange_runtime=>nr_number,
      lv_zdenghi  type zde_denghi,
      xmldata     type string,
      xmldataitem type string.
    try.
        call method cl_numberrange_runtime=>number_get
          exporting
            nr_range_nr = '01'
            object      = 'ZNR_DENGHI'
            quantity    = 1
            toyear      = |{ sy-datum(4) }|
          importing
            number      = lv_number.
      catch cx_nr_object_not_found.
      catch cx_number_ranges.
    endtry.


    "better bring it to the zfi_denghi_final and pass value down from front-end, but I have no time :)

    "mong người đến sau sẽ có thời gian đem field invoice lên zfi_denghi_final và truyền từ front-end xún để tăng perfomrmance, xin lũi vì quá bận
    select
        item~accountingdocument,
        item~accountingdocumentyear,
        item~accountingcompanycode,
        accountingdocumenttype,
        substring( i_journalentry~originalreferencedocument, 1 , 10 )  as supplierinvoice,
        substring( i_journalentry~originalreferencedocument, 11, 4 ) as supplierinvoiceyear
     from i_journalentry
     inner join @gs_data-items as item on item~accountingdocument     = i_journalentry~accountingdocument
                                      and item~accountingdocumentyear = i_journalentry~fiscalyear
                                      and item~accountingcompanycode  = i_journalentry~companycode
    where i_journalentry~accountingdocumenttype = 'RE'
    order by item~accountingdocument,
            item~accountingdocumentyear,
            item~accountingcompanycode
    into table @data(lt_invoicenum).

    lv_zdenghi = |{ lv_number alpha = in }|.

    data:
      ls_fi_tb_denghi   type zfi_tb_denghi,
      ls_fi_tb_denghi_i type zfi_tb_denghi_i.
    ls_fi_tb_denghi = corresponding #( gs_data ).
    ls_fi_tb_denghi-zdenghi = lv_zdenghi.
    ls_fi_tb_denghi-gjahr = sy-datum(4).
    ls_fi_tb_denghi-pst_user = sy-uname.
    ls_fi_tb_denghi-pst_date = sy-datum.
    modify zfi_tb_denghi from @ls_fi_tb_denghi.

    data: lv_sum type fins_vwcur12.
    loop at gs_data-items reference into data(ls_item).

      lv_sum = lv_sum +  ls_item->sotiendenghi.
      if ls_item->transactioncurrency = 'VND'.
        ls_item->vat              = ls_item->vat             / 100      .
        ls_item->sotiendenghi     = ls_item->sotiendenghi    / 100      .
        ls_item->sotientruocthue  = ls_item->sotientruocthue / 100.
      endif.


      clear ls_fi_tb_denghi_i.
      ls_fi_tb_denghi_i = corresponding #( ls_item->* ).
      ls_fi_tb_denghi_i-zdenghi         = lv_zdenghi.
      ls_fi_tb_denghi_i-gjahr = sy-datum(4).

      read table lt_invoicenum reference into data(ls_invoicenum)
      with key accountingcompanycode = ls_item->accountingcompanycode
               accountingdocument = ls_item->accountingdocument
               accountingdocumentyear = ls_item->accountingdocumentyear binary search.
      if   sy-subrc = 0 .
        ls_fi_tb_denghi_i-supplierinvoice = ls_invoicenum->supplierinvoice.
        ls_fi_tb_denghi_i-supplierinvoiceyear = ls_invoicenum->supplierinvoiceyear.
        ls_fi_tb_denghi_i-accountingdocumenttype = ls_invoicenum->accountingdocumenttype.
      endif.
      modify zfi_tb_denghi_i from @ls_fi_tb_denghi_i.


      xmldataitem = xmldataitem && | <Data>|
                  && |<STT>{ ls_item->item alpha = out }</STT>|
                  && |<SoHoaDon>{ ls_item->sohoadon }</SoHoaDon>|
                  && |<NgayHoaDon>{ ls_item->ngayhoadon+6(2) }/{ ls_item->ngayhoadon+4(2) }/{ ls_item->ngayhoadon(4) }</NgayHoaDon>|
                  && |<DocumentNumber>{ cond #( when ls_fi_tb_denghi_i-accountingdocumenttype = 'RE' and ls_fi_tb_denghi_i-supplierinvoice is not initial then |{ ls_fi_tb_denghi_i-supplierinvoice alpha = in }|
                                                else |{ ls_item->accountingdocument alpha = in }|  ) }</DocumentNumber>|
                  && |<DienGiai><![CDATA[{ ls_item->diengiai }]]></DienGiai>|
                  && |<TriGia>{ ls_item->sotientruocthue_ui }</TriGia>|
                  && |<VAT>{ ls_item->vat_ui }</VAT>|
                  && |<TongCong>{ ls_item->sotiendenghi_ui }</TongCong>|
                  && |</Data> |.

    endloop.

    commit work and wait.
    data(lv_amt_in_word) = zcore_cl_amount_in_words=>read_amount( i_amount = lv_sum i_waers = ls_item->transactioncurrency i_lang = 'VI' ).
    xmldata = |<?xml version="1.0" encoding="UTF-8"?>|
            && |<form1>|
                && |<MAIN>|
                    && |<Subform1>|
                        && |<Heading>|
                            && |<companyCodeName><![CDATA[{ gs_data-company_code_name }]]></companyCodeName>|
                            && |<companyCodeAdress>{ gs_data-company_code_adress }</companyCodeAdress>|
                            && |<Tel_Fax>|
                                && |<companyCodePhone>Tel: { gs_data-company_code_phone }</companyCodePhone>|
                                && |<companyCodeFax>Fax: { gs_data-company_code_fax }</companyCodeFax>|
                            && |</Tel_Fax>|
                            && |<Email_Web>|
                                && |<companyCodeEmail>Email: { gs_data-company_code_email }</companyCodeEmail>|
                                && |<companyCodeWeb><![CDATA[Website: { gs_data-company_code_web }]]></companyCodeWeb>|
                            && |</Email_Web>|
                        && |</Heading>|
                    && |</Subform1>|
                    && |<kinhGui>|
                        && |<title>{ gs_data-title }</title>|
                        && |<So>{ lv_zdenghi alpha = out }</So>|
                    && |</kinhGui>|
                    && |<HeaderInfo>|
                        && |<ToiTen><![CDATA[{ gs_data-nguoidenghi }]]></ToiTen>|
                        && |<DonViCongTac><![CDATA[{ gs_data-donvicongtac  }]]></DonViCongTac>|
                        && |<LyDoThanhToan><![CDATA[{ gs_data-lydothanhtoan }]]></LyDoThanhToan>|
                    && |</HeaderInfo>|
                    && |<DataSubForm>|
                        && |<DataTable>|
                            && |<HeaderRow/>|
                            && |{ xmldataitem }|
                            && |<Sum>|
                                && |<SumTongCong>{ gs_data-sum_tong_cong }</SumTongCong>|
                            && |</Sum>|
                        && |</DataTable>|
                    && |</DataSubForm>|
                    && |<FooterInfomation>|
                        && |<SoTienBangChu><![CDATA[{ lv_amt_in_word }]]></SoTienBangChu>|
                        && |<ChungTuKemTheo><![CDATA[{ gs_data-ctkemtheo }]]></ChungTuKemTheo>|
                        && |<HinhThucThanhToan><![CDATA[{ gs_data-paymentmethod }]]></HinhThucThanhToan>|
                        && |<NguoiThuHuong><![CDATA[{ gs_data-nguoinhan }]]></NguoiThuHuong>|
                        && |<NganHangThuHuong><![CDATA[{ gs_data-tennganhang }]]></NganHangThuHuong>|
                        && |<SoTaiKhoan><![CDATA[{ gs_data-sotaikhoannhan }]]></SoTaiKhoan>|
                    && |</FooterInfomation>|
                    && |<Sign><NgayThangNam><![CDATA[{ gs_data-ngaythangnam }]]></NgayThangNam></Sign>|
                && |</MAIN>|
            && |</form1>|.

    data :
      xmldata_utf8   type string,
      xmldata_binary type xstring,
      xmldata_base64 type string.
    xmldata_binary = cl_abap_conv_codepage=>create_out( )->convert( xmldata ).
    xmldata_base64 = cl_web_http_utility=>encode_x_base64( unencoded = xmldata_binary ).

    data: lo_api_adobe     type ref to zcl_api_adobe,
          ls_request_pdf   type zcl_api_adobe=>ty_request,
          pdf_file_contant type string,
          adobe_response   type string.
    lo_api_adobe = new #(  ).
    ls_request_pdf-xdp_template = 'DENGHI/DENGHI'.
    ls_request_pdf-zxml_data = xmldata_base64.
    ls_request_pdf-report = 'DENGHI'.
    ls_request_pdf-id = |{ lv_zdenghi }{ sy-datum(4) }|.

    lo_api_adobe->get_pdf( exporting request = ls_request_pdf importing pdf64 = pdf_file_contant response = adobe_response ).
    response_data-message = adobe_response.
    response_data-pdf = pdf_file_contant.
    response_data-zdenghi = lv_zdenghi.
  endmethod.
ENDCLASS.
