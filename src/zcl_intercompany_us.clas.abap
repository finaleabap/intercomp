class ZCL_INTERCOMPANY_US definition
  public
  create public .

public section.

  interfaces ZIF_INTERCOMPANY .

  types:
    BEGIN OF ts_masraf_kaydi,
        tt_masraf_header TYPE TABLE OF  zintcomp_s_alv_masraf_header WITH EMPTY KEY,
        tt_masraf_kaydi  TYPE TABLE OF  zintcomp_s_alv_masraf WITH EMPTY KEY,
      END OF ts_masraf_kaydi .
  types:
    tt_02 TYPE TABLE OF zintcomp_m_002 WITH DEFAULT KEY .
  types T_BAPIACC type ZIF_INTERCOMPANY~T_BAPIACC .
  types:
    tt_03 TYPE TABLE OF zintcomp_m_003 WITH DEFAULT KEY .
  types:
    tt_teslimat TYPE TABLE OF zintcomp_s_teslimat_secim WITH DEFAULT KEY .
  types:
    BEGIN OF ts_genel_params .
    TYPES : t_01          TYPE zintcomp_m_001.
    TYPES : table_02      TYPE tt_02.
    TYPES : table_03      TYPE tt_03.
    TYPES : END OF ts_genel_params .
  types:
    BEGIN OF ts_kayit .
    TYPES : t_teslimat    TYPE tt_teslimat.
    TYPES : key           TYPE zintcomp_s_key .
    TYPES : bukrs         TYPE bukrs .
    TYPES : kunnr         TYPE kunnr .
    TYPES : lifnr         TYPE lifnr .
    TYPES : mwskz         TYPE mwskz .
    TYPES : budat         TYPE budat .
    TYPES : bldat         TYPE bldat .
    TYPES : xblnr         TYPE xblnr .
    TYPES : zterm         TYPE dzterm .
    TYPES : function_name TYPE char100.
    TYPES : commit        TYPE char1.
    TYPES : kayit_tur     TYPE char50.
    TYPES : hesap_alan    TYPE char50.
    TYPES : ref_belge	    TYPE zintcom_de_ref_belge.
    TYPES : masraf_tutar  TYPE wrbtr.
    TYPES : masraf_tip    TYPE zintcom_de_masraf_tip.
    TYPES : dagitim_tipi  TYPE zintcomp_de_dagitim_tipi.
    TYPES : ara_hesap     TYPE char1.
    TYPES : ters_kayit    TYPE char1.
    TYPES : karakteristik TYPE char1.
    TYPES : kostl         TYPE kostl.
    TYPES : END OF ts_kayit .
  types:
    BEGIN OF ts_parameters ,
        bukrs      TYPE bukrs,
        bukrsz     TYPE bukrs_sender,
        s_vbeln_vl TYPE RANGE OF vbeln_vl,
        s_vbeln    TYPE RANGE OF vbeln,
      END OF ts_parameters .

  data GS_PARAMETERS type TS_PARAMETERS .
  data GS_KAYIT type TS_KAYIT .
  data GV_TESLIMAT type VBELN_VL .
  data GV_FATURA type VBELN_VF .
  data GV_MUS_FATURA type VBELN_VF .
  data GS_GENEL type TS_GENEL_PARAMS .
  class-data GS_MASRAF_KAYDI type TS_MASRAF_KAYDI .
  data GS_HEADER type ZINTCOMP_S_ALV_HEADER .

  methods CONSTRUCTOR
    importing
      !IV_BUKRS type BUKRS
      !IV_BUKRSZ type BUKRS_SENDER .
  methods PREPARE_MK
    returning
      value(RT_ACDOCUMENT) type T_BAPIACC .
protected section.

  methods POST_FI
    returning
      value(ET_RETURN) type ZIF_INTERCOMPANY~T_RETURN .
  methods GET_MASRAF_DETAY .
  methods SET_CRETERIA .
private section.

  types:
    BEGIN OF ts_reverse ,
           belnr   TYPE belnr_d,
           bukrs   TYPE bukrs,
           gjahr   TYPE gjahr,
           bapiret TYPE bapireturn_t,
         END OF ts_reverse .

*  TYPES tt_masraf_kaydi TYPE STANDARD TABLE OF  zintcomp_s_alv_masraf WITH DEFAULT KEY.
  class-data GS_ACDOCUMENT type T_BAPIACC .
  class-data GV_KAYIT_TUR type TXT50 .
  class-data GV_HESAP_ALAN type TXT50 .
  class-data GS_TERS_KAYIT type TS_REVERSE .

  methods KAYIT_KONTROL
    returning
      value(RT_MESSAGE) type ZIF_INTERCOMPANY=>T_RETURN .
  methods PREPARE_OK
    importing
      !IV_BELNR type BELNR_D optional
      !IV_GJAHR type GJAHR optional .
ENDCLASS.



CLASS ZCL_INTERCOMPANY_US IMPLEMENTATION.


  METHOD constructor.

    SELECT SINGLE * FROM zintcomp_m_001
             INTO gs_genel-t_01
            WHERE bukrs  = iv_bukrs
              AND bukrsz = iv_bukrsz.

    SELECT * FROM zintcomp_m_002
       INTO TABLE gs_genel-table_02
            WHERE bukrs = iv_bukrs
              AND bukrsz = gs_genel-t_01-bukrsz.

    SELECT * FROM zintcomp_m_003
       INTO TABLE gs_genel-table_03
            WHERE bukrs = iv_bukrs
              AND bukrsz = gs_genel-t_01-bukrsz.

    gs_acdocument-function_name = 'BAPI_ACC_DOCUMENT_POST'.
  ENDMETHOD.


  METHOD get_masraf_detay.

    DATA : lt_header TYPE TABLE OF zintcomp_s_alv_masraf_header.

    lt_header = gs_masraf_kaydi-tt_masraf_header.

    SELECT FROM @lt_header AS itab
     INNER JOIN bkpf
             ON bkpf~belnr EQ itab~belnr
            AND bkpf~gjahr EQ itab~gjahr
            AND bkpf~bukrs EQ itab~bukrs
      LEFT JOIN dd07t
             ON dd07t~domname EQ 'ZINTCOMP_DM_KAYIT_TUR'
            AND dd07t~ddlanguage EQ 'T'
            AND dd07t~domvalue_l EQ itab~kayit_tur
         FIELDS itab~*, bkpf~bktxt AS text, bkpf~budat, bkpf~usnam,
                ddtext AS kayit_tur_tanim
       ORDER BY bkpf~bukrs, bkpf~gjahr, bkpf~belnr
      INTO CORRESPONDING FIELDS OF TABLE @gs_masraf_kaydi-tt_masraf_header.

    lt_header = gs_masraf_kaydi-tt_masraf_header.

    SELECT FROM @lt_header AS itab
     INNER JOIN bseg
             ON bseg~belnr EQ itab~belnr
            AND bseg~gjahr EQ itab~gjahr
            AND bseg~bukrs EQ itab~bukrs
     INNER JOIN bkpf
             ON bkpf~belnr EQ itab~belnr
            AND bkpf~gjahr EQ itab~gjahr
            AND bkpf~bukrs EQ itab~bukrs
*      LEFT JOIN dd07t
*             ON dd07t~domname EQ 'ZINTCOMP_DM_DAGITIM_TIPI'
*            AND dd07t~ddlanguage EQ 'T'
*            AND dd07t~domvalue_l EQ itab~kayit_tur
         FIELDS itab~*, bseg~sgtxt AS text, bseg~matnr, bkpf~waers,
                bseg~buzei AS kayit_tur_tanim, bseg~hkont,
                case when bseg~shkzg = 'H' then bseg~wrbtr * -1
                     else bseg~wrbtr end as wrbtr
       ORDER BY bkpf~bukrs, bkpf~gjahr, bkpf~belnr
     INTO CORRESPONDING FIELDS OF TABLE @gs_masraf_kaydi-tt_masraf_kaydi.


  ENDMETHOD.


  METHOD kayit_kontrol.

    DATA : lv_name TYPE string.
    FIELD-SYMBOLS : <fs_val> TYPE any.

    DATA(lt_log) = me->zif_intercompany~get_log_list( ).

    DELETE lt_log WHERE stblg <> ''.
    rt_message-return_type = 'S'.

    SELECT * FROM zintcomp_m_006
               INTO TABLE @DATA(lt_006)
                   WHERE bukrs      = @gs_parameters-bukrs
                     AND kayit_tur  = @gs_kayit-kayit_tur
                     AND ters_kayit = @gs_kayit-ters_kayit
                     and bukrsz     = @gs_genel-t_01-bukrsz.

    SELECT  * FROM zintcomp_m_007
              INTO TABLE @DATA(lt_007)
             WHERE bukrs     = @gs_parameters-bukrs
               AND kayit_tur = @gs_kayit-kayit_tur
               AND ters_kayit = @gs_kayit-ters_kayit
               and bukrsz     = @gs_genel-t_01-bukrsz.

    READ TABLE lt_log TRANSPORTING NO FIELDS WITH KEY kayit_tur = 'TK'.
    IF sy-subrc = 0.
      APPEND VALUE bapiret2( type = 'E' id = 'ZINTCOMPANY' number = '005' ) TO rt_message-t_bapiret.
      rt_message-return_type = 'E'.
    ENDIF.

    LOOP AT lt_006 INTO DATA(ls_006).

      IF ls_006-kayit_adet = '1'.
        DATA(tmp_log) = lt_log[].
        DELETE tmp_log WHERE kayit_tur NE gs_kayit-kayit_tur.
        IF lines( tmp_log ) > 0.
          APPEND VALUE bapiret2( type = 'E' id = 'ZINTCOMPANY' number = '002' ) TO rt_message-t_bapiret.
          rt_message-return_type = 'E'.
        ENDIF.
      ENDIF.


      DATA(lv_subrc) = COND syst-subrc( WHEN ls_006-onc_belge_kontrol = 'X' THEN 4
                                        ELSE 0 ).

      READ TABLE lt_log TRANSPORTING NO FIELDS WITH KEY kayit_tur = ls_006-onceki_belge.
      IF sy-subrc = lv_subrc.
        APPEND VALUE bapiret2( type = 'E' id = 'ZINTCOMPANY' number = ls_006-msgno message_v1 = ls_006-onceki_belge  ) TO rt_message-t_bapiret.
        rt_message-return_type = 'E'.
      ENDIF.

    ENDLOOP.


    LOOP AT lt_007 INTO DATA(ls_007) WHERE dolu_kontrol = 'X'.
      UNASSIGN <fs_val>.
      lv_name = |{ ls_007-structure }-{ ls_007-alan }|.
      ASSIGN (lv_name) TO <fs_val>.
      IF <fs_val> IS ASSIGNED AND <fs_val> IS INITIAL.
        APPEND VALUE bapiret2( type = 'E' id = 'ZINTCOMPANY' number = '004' message_v1 = ls_007-alan ) TO rt_message-t_bapiret.
        rt_message-return_type = 'E'.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD POST_FI.
    DATA : lv_obj_key TYPE bapiache09-obj_key.

    IF gs_acdocument-function_name IS INITIAL.
      gs_acdocument-function_name = 'BAPI_ACC_DOCUMENT_POST'.
    ENDIF.

    CALL FUNCTION gs_acdocument-function_name
      EXPORTING
        documentheader    = gs_acdocument-documentheader
      IMPORTING
        obj_key           = gs_acdocument-obj_key
      TABLES
        accountgl         = gs_acdocument-accountgl
        accountreceivable = gs_acdocument-accountreceivable
        accountpayable    = gs_acdocument-accountpayable
        accounttax        = gs_acdocument-accounttax
        currencyamount    = gs_acdocument-currencyamount
        criteria          = gs_acdocument-criteria
        return            = et_return-t_bapiret.

    LOOP AT et_return-t_bapiret TRANSPORTING NO FIELDS WHERE type CA 'EAX'.
      EXIT.
    ENDLOOP.
    IF sy-subrc = 0.
      et_return-return_type = 'E'.
    ELSE.
      et_return-return_type = 'S'.
      IF gs_acdocument-commit = abap_true.
        et_return-obj_key = gs_acdocument-obj_key.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.
      ENDIF.
    ENDIF.

    MOVE-CORRESPONDING et_return TO gs_acdocument.


  ENDMETHOD.


  METHOD prepare_mk.

    DATA : lv_oran TYPE p DECIMALS 4.
    DATA : lv_toplam TYPE wrbtr.

    IF gs_kayit-masraf_tutar <> 0.
      DATA(lv_teslimat_ttr) = REDUCE wrbtr( INIT x = CONV wrbtr( 0 ) FOR teslimat IN gs_kayit-t_teslimat
            WHERE (  secim EQ 'X' ) NEXT x = x + COND #( WHEN gs_kayit-dagitim_tipi = 'T' THEN teslimat-netwr
                                                         WHEN gs_kayit-dagitim_tipi = 'M' THEN teslimat-lfimg ) ).

      CHECK lv_teslimat_ttr IS NOT INITIAL.
      lv_oran = gs_kayit-masraf_tutar / lv_teslimat_ttr.
    ENDIF.

    LOOP AT gs_kayit-t_teslimat ASSIGNING FIELD-SYMBOL(<fs_teslimat>) WHERE secim = 'X'.

      IF gs_kayit-dagitim_tipi = 'T'.
        <fs_teslimat>-netwr = <fs_teslimat>-netwr * lv_oran.
      ELSEIF gs_kayit-dagitim_tipi = 'M'.
        <fs_teslimat>-netwr = <fs_teslimat>-lfimg * lv_oran.
      ELSE.
        <fs_teslimat>-netwr = 0.
      ENDIF.
      ADD <fs_teslimat>-netwr TO lv_toplam.

    ENDLOOP.

    IF lv_toplam <> gs_kayit-masraf_tutar.
      READ TABLE gs_kayit-t_teslimat ASSIGNING <fs_teslimat> INDEX lines( gs_kayit-t_teslimat ).
      <fs_teslimat>-netwr = <fs_teslimat>-netwr + ( gs_kayit-masraf_tutar - lv_toplam ).
    ENDIF.


    IF gs_kayit-kayit_tur  IS INITIAL.
      gs_kayit-kayit_tur  = 'MK'.
    ENDIF.
    IF gs_kayit-hesap_alan  IS INITIAL.
      gs_kayit-hesap_alan = 'LS_02-MASRAF_HESAP'.
      gs_kayit-karakteristik = gs_genel-t_01-mk_karakter.
    ENDIF.
    IF gs_kayit-ara_hesap = 'X' AND gs_genel-t_01-masraf_arahesap = 'X'.
      gs_kayit-hesap_alan = 'LS_02-ARA_HESAP'.
      gs_kayit-kayit_tur  = 'AH'.
      gs_kayit-karakteristik = gs_genel-t_01-ah_karakter.
    ENDIF.

    SELECT * FROM zintcomp_m_005
       INTO TABLE @DATA(lt_005)
            WHERE bukrs      = @gs_parameters-bukrs
              AND masraf_tip = @gs_kayit-masraf_tip
              AND bukrsz     = @gs_genel-t_01-bukrsz.

    LOOP AT lt_005 INTO DATA(ls_005).
      READ TABLE gs_genel-table_02 ASSIGNING FIELD-SYMBOL(<fs_02>) WITH KEY bklas = ls_005-bklas.
      IF sy-subrc = 0.
        <fs_02>-masraf_hesap = ls_005-masraf_hesap.
        <fs_02>-ara_hesap    = ls_005-ara_hesap.
        <fs_02>-kostl        = ls_005-kostl.
      ENDIF.
    ENDLOOP.


    DATA(lt_return) = me->zif_intercompany~check_and_map(  ).


    rt_acdocument = gs_acdocument.
    rt_acdocument-t_bapiret  = lt_return-t_bapiret.
    rt_acdocument-return_type = lt_return-return_type.


    SELECT SINGLE @abap_true
             FROM bkpf
       INNER JOIN bseg
               ON bkpf~belnr EQ bseg~belnr
              AND bkpf~bukrs EQ bseg~bukrs
              AND bkpf~gjahr EQ bseg~gjahr
            WHERE bkpf~bukrs = @gs_parameters-bukrs
              AND bkpf~xblnr = @gs_kayit-xblnr
              AND bkpf~stblg = ''
              AND bseg~lifnr = @gs_kayit-lifnr
       INTO @DATA(lv_cift_fatura).

    IF lv_cift_fatura = 'X'.
      rt_acdocument-return_type = 'E'.
      APPEND VALUE bapiret2( type = 'E' id = 'ZINTCOMPANY' number = '008' message_v1 = gs_kayit-xblnr message_v2 = gs_kayit-lifnr ) TO rt_acdocument-t_bapiret.
    ENDIF.



  ENDMETHOD.


  METHOD prepare_ok.

    SELECT SINGLE * FROM bkpf
             INTO @DATA(ls_bkpf)
            WHERE bukrs = @gs_kayit-bukrs
              AND belnr = @iv_belnr
              AND gjahr = @iv_gjahr.


    SELECT * FROM bseg
       INTO TABLE @DATA(lt_bseg)
            WHERE bukrs = @gs_kayit-bukrs
              AND belnr = @iv_belnr
              AND gjahr = @iv_gjahr
              AND koart = 'S'.

    DATA(tmp_teslimat) = gs_kayit-t_teslimat.
    DELETE tmp_teslimat WHERE secim = ''.

    CLEAR: gs_acdocument.

    gs_acdocument-commit        = gs_kayit-commit.
    gs_acdocument-function_name = gs_kayit-function_name.

    SELECT SINGLE * FROM zintcomp_m_003
                    INTO @DATA(ls_003)
                   WHERE bukrs     = @gs_parameters-bukrs
                     AND kayit_tur = @gs_kayit-kayit_tur
                     and bukrsz     = @gs_genel-t_01-bukrsz.

    gs_acdocument-documentheader-comp_code   = gs_kayit-bukrs.
    gs_acdocument-documentheader-doc_type    = ls_003-blart. " Bakım tablosuna bağlanacak " Hesap bakım tablosu oluşturmak lazım
    gs_acdocument-documentheader-doc_date    = sy-datum.
    gs_acdocument-documentheader-pstng_date  = sy-datum.
    gs_acdocument-documentheader-username    = sy-uname.
    gs_acdocument-documentheader-header_txt  = ls_003-bktxt.

    LOOP AT lt_bseg INTO DATA(ls_bseg).
      READ TABLE gs_kayit-t_teslimat INTO DATA(ls_teslimat) INDEX sy-tabix.
      READ TABLE gs_genel-table_02 INTO DATA(ls_02) WITH KEY bklas = ls_teslimat-bklas.

      APPEND INITIAL LINE TO gs_acdocument-accountgl ASSIGNING FIELD-SYMBOL(<fs_accountgl>).
      <fs_accountgl>-itemno_acc = lines(  gs_acdocument-accountgl ).
      <fs_accountgl>-gl_account = ls_02-masraf_hesap.
      <fs_accountgl>-material   = ls_bseg-matnr.
      <fs_accountgl>-item_text  = ls_bseg-sgtxt.
      <fs_accountgl>-costcenter = ls_02-kostl.
      <fs_accountgl>-ref_key_1  = ls_bseg-paobjnr.

      APPEND INITIAL LINE TO gs_acdocument-currencyamount ASSIGNING FIELD-SYMBOL(<fs_amount>).
      <fs_amount>-itemno_acc = lines(  gs_acdocument-currencyamount ).
      <fs_amount>-amt_doccur = ls_bseg-wrbtr.
      <fs_amount>-currency   = ls_bkpf-waers.

    ENDLOOP.

    LOOP AT lt_bseg INTO ls_bseg.

      APPEND INITIAL LINE TO gs_acdocument-accountgl ASSIGNING <fs_accountgl>.
      <fs_accountgl>-itemno_acc = lines(  gs_acdocument-accountgl ).
      <fs_accountgl>-gl_account = ls_bseg-hkont.
      <fs_accountgl>-material   = ls_bseg-matnr.
      <fs_accountgl>-item_text  = ls_bseg-sgtxt.
      <fs_accountgl>-costcenter = ls_bseg-kostl.
*      <fs_accountgl>-ref_key_1  = ls_bseg-paobjnr.

      APPEND INITIAL LINE TO gs_acdocument-currencyamount ASSIGNING <fs_amount>.
      <fs_amount>-itemno_acc = lines(  gs_acdocument-currencyamount ).
      <fs_amount>-amt_doccur = ls_bseg-wrbtr * -1.
      <fs_amount>-currency   = ls_bkpf-waers.

    ENDLOOP.

    set_creteria( ).

  ENDMETHOD.


  METHOD set_creteria.

    DATA : lv_name TYPE string.
    FIELD-SYMBOLS : <fs_val> TYPE any.
    FIELD-SYMBOLS : <fs_val2> TYPE any.

*    CHECK gs_kayit-kayit_tur NE 'AH' .
    CHECK gs_kayit-karakteristik = 'X' .

    SELECT * FROM dd03l
       INTO TABLE @DATA(lt_dd03l)
            WHERE tabname   EQ 'CE41000_ACCT'
              AND NOT ( fieldname EQ 'MATKL' AND
                        fieldname EQ 'MANDT' ) .

    DATA(lt_teslimat) = gs_kayit-t_teslimat.
    DELETE lt_teslimat WHERE secim NE 'X'.

    SELECT lips~* FROM @lt_teslimat AS itab
            INNER JOIN lips
                    ON lips~vbeln EQ itab~vbeln
                   AND lips~posnr EQ itab~posnr
            INTO TABLE @DATA(lt_lips).

    SELECT SINGLE likp~* FROM @lt_teslimat AS itab
            INNER JOIN likp
                    ON likp~vbeln EQ itab~vbeln
                  INTO @DATA(likp).

    SELECT vbrp~* FROM @lt_teslimat AS itab
            INNER JOIN vbrp
                    ON vbrp~vbeln EQ itab~vbeln_vf
                   AND vbrp~posnr EQ itab~posnr_vf
            INTO TABLE @DATA(lt_vbrp).

    SELECT SINGLE vbrk~* FROM @lt_teslimat AS itab
            INNER JOIN vbrk
                    ON vbrk~vbeln EQ itab~vbeln_vf
                  INTO @DATA(vbrk).

    SELECT * FROM zintcomp_m_008
       INTO TABLE @DATA(lt_008)
            WHERE bukrs  = @gs_parameters-bukrs
              AND bukrsz = @gs_genel-t_01-bukrsz.


    SELECT ce~*, itab~itemno_acc FROM ce41000_acct AS ce
          INNER JOIN @gs_acdocument-accountgl AS itab
                  ON ce~paobjnr EQ itab~ref_key_1
          INTO TABLE @DATA(lt_acct).

    LOOP AT lt_acct INTO DATA(ls_acct).
      READ TABLE lt_teslimat INTO DATA(ls_teslimat) INDEX sy-tabix.
      READ TABLE lt_lips INTO DATA(lips) WITH KEY posnr = ls_teslimat-posnr.
      READ TABLE lt_vbrp INTO DATA(vbrp) WITH KEY posnr = ls_teslimat-posnr_vf.

      LOOP AT lt_dd03l INTO DATA(ls_dd03l).

        lv_name = |LS_ACCT-CE-{ ls_dd03l-fieldname }|.
        UNASSIGN <fs_val>.
        ASSIGN (lv_name) TO <fs_val>.
        IF <fs_val> IS ASSIGNED.
          APPEND INITIAL LINE TO gs_acdocument-criteria ASSIGNING FIELD-SYMBOL(<fs_criteria>).
          DATA(lv_lines) = sy-tabix.
          <fs_criteria>-itemno_acc = ls_acct-itemno_acc.
          <fs_criteria>-fieldname  = ls_dd03l-fieldname.

          "$. Region~OFURAY Bakım tablosundaki karakterisik bakımı 06.10.2025 14:04:48

          READ TABLE lt_008 INTO DATA(ls_008) WITH KEY bklas = ls_teslimat-bklas
                                                       alan  = ls_dd03l-fieldname.
          IF sy-subrc = 0.
            CASE ls_008-deger_tip.
              WHEN 'MF'.
                SELECT SINGLE (ls_dd03l-fieldname) FROM ce41000_acct
                                                 INTO <fs_criteria>-character
                                                WHERE paobjnr EQ ls_teslimat-paobjnr_mus.
              WHEN 'FT'.
                <fs_criteria>-character  = <fs_val>.
              WHEN 'ST'.
                <fs_criteria>-character = ls_008-deger.
              WHEN 'DN'.
                UNASSIGN <fs_val2>.
                ASSIGN (ls_008-deger) TO <fs_val2>.
                IF <fs_val2> IS ASSIGNED.
                  <fs_criteria>-character  = <fs_val2>.
                ENDIF.
              WHEN 'SL'.
                DELETE gs_acdocument-criteria INDEX lv_lines.
                CONTINUE.
            ENDCASE.

            "$. Endregion~OFURAY Bakım tablosundaki karakterisik bakımı

          ELSE.
            <fs_criteria>-character  = <fs_val>.
          ENDIF.
        ENDIF.

      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.


  METHOD zif_intercompany~check_and_map.
    DATA : lt_mwdat TYPE TABLE OF rtax1u15.
    FIELD-SYMBOLS : <fs_val> TYPE any.
    DATA : lv_karsilik TYPE wrbtr.

    CLEAR: gs_acdocument.

    gs_acdocument-commit        = gs_kayit-commit.
    gs_acdocument-function_name = gs_kayit-function_name.

    SELECT SINGLE * FROM zintcomp_m_003
                    INTO @DATA(ls_003)
                   WHERE bukrs     = @gs_parameters-bukrs
                     AND kayit_tur = @gs_kayit-kayit_tur
                     AND bukrsz    = @gs_genel-t_01-bukrsz.

    gs_acdocument-documentheader-comp_code   = gs_kayit-bukrs.
    gs_acdocument-documentheader-doc_type    = ls_003-blart. " Bakım tablosuna bağlanacak " Hesap bakım tablosu oluşturmak lazım
    gs_acdocument-documentheader-doc_date    = sy-datum.
    gs_acdocument-documentheader-pstng_date  = sy-datum.
    gs_acdocument-documentheader-username    = sy-uname.
    gs_acdocument-documentheader-header_txt  = ls_003-bktxt.
    gs_acdocument-documentheader-ref_doc_no  = gs_kayit-xblnr.
    IF gs_kayit-budat IS NOT INITIAL.
      gs_acdocument-documentheader-pstng_date = gs_kayit-budat.
    ENDIF.
    IF gs_kayit-bldat IS NOT INITIAL.
      gs_acdocument-documentheader-doc_date = gs_kayit-bldat.
    ENDIF.


    LOOP AT gs_kayit-t_teslimat INTO DATA(ls_teslimat) WHERE secim = 'X'.
      IF ls_003-shkzg = 'H'.
        ls_teslimat-netwr = ls_teslimat-netwr * -1.
      ENDIF.
      READ TABLE gs_genel-table_02 INTO DATA(ls_02) WITH KEY bklas = ls_teslimat-bklas.
      UNASSIGN <fs_val>.
      ASSIGN (gs_kayit-hesap_alan) TO <fs_val>.
      IF <fs_val> IS ASSIGNED.
        ADD ls_teslimat-netwr TO lv_karsilik.

        APPEND INITIAL LINE TO gs_acdocument-accountgl ASSIGNING FIELD-SYMBOL(<fs_accountgl>).
        <fs_accountgl>-itemno_acc = lines(  gs_acdocument-accountgl ).
        <fs_accountgl>-gl_account = <fs_val>.
        <fs_accountgl>-material   = ls_teslimat-matnr.
        <fs_accountgl>-item_text  = ls_teslimat-maktx.
        <fs_accountgl>-ref_key_1  = ls_teslimat-paobjnr.

        SELECT SINGLE @abap_true FROM ska1
                                 INTO @DATA(lv_bilanco_kontrol)
                                WHERE saknr = @<fs_accountgl>-gl_account
                                  AND xbilk = @space.
        IF lv_bilanco_kontrol = abap_true.
*          <fs_accountgl>-costcenter = ls_02-kostl.
          <fs_accountgl>-costcenter = gs_kayit-kostl.
        ENDIF.
        CLEAR lv_bilanco_kontrol.

        APPEND INITIAL LINE TO gs_acdocument-currencyamount ASSIGNING FIELD-SYMBOL(<fs_amount>).
        <fs_amount>-itemno_acc = lines(  gs_acdocument-currencyamount ).
        <fs_amount>-amt_doccur = ls_teslimat-netwr.
        <fs_amount>-currency   = ls_teslimat-waerk.

      ENDIF.
    ENDLOOP.

    IF gs_kayit-mwskz IS NOT INITIAL.
      lv_karsilik = lv_karsilik * -1 .

      CALL FUNCTION 'CALCULATE_TAX_FROM_GROSSAMOUNT'
        EXPORTING
          i_bukrs = gs_kayit-bukrs "ev_bukrs
          i_mwskz = gs_kayit-mwskz
          i_waers = ls_teslimat-waerk
          i_wrbtr = lv_karsilik
        TABLES
          t_mwdat = lt_mwdat.

      READ TABLE lt_mwdat INTO DATA(s_mwdat) INDEX 1.

      APPEND INITIAL LINE TO gs_acdocument-currencyamount ASSIGNING <fs_amount>.
      <fs_amount>-itemno_acc = lines(  gs_acdocument-currencyamount )..
      <fs_amount>-currency   = ls_teslimat-waerk.
      <fs_amount>-amt_doccur = s_mwdat-wmwst.
      <fs_amount>-amt_base   = s_mwdat-kawrt.

      APPEND INITIAL LINE TO gs_acdocument-accounttax ASSIGNING FIELD-SYMBOL(<fs_accounttax>).
      "ACCOUNTTAX
      <fs_accounttax>-itemno_acc = lines(  gs_acdocument-currencyamount ).
      <fs_accounttax>-gl_account = s_mwdat-hkont.
      <fs_accounttax>-tax_code   = gs_kayit-mwskz.
      <fs_accounttax>-tax_rate   = s_mwdat-kbetr.
      <fs_accounttax>-acct_key   = s_mwdat-ktosl .
      <fs_accounttax>-cond_key   = s_mwdat-kschl .

      lv_karsilik = s_mwdat-kawrt * -1.

    ENDIF.


    IF gs_kayit-kayit_tur = 'SMM'.

      LOOP AT gs_kayit-t_teslimat INTO ls_teslimat WHERE secim = 'X'.
        IF ls_003-shkzg = 'H'.
          ls_teslimat-netwr = ls_teslimat-netwr * -1.
        ENDIF.
        READ TABLE gs_genel-table_02 INTO ls_02 WITH KEY bklas = ls_teslimat-bklas.
        UNASSIGN <fs_val>.
        ASSIGN (gs_kayit-hesap_alan) TO <fs_val>.
        IF <fs_val> IS ASSIGNED.
          ADD ls_teslimat-netwr TO lv_karsilik.

          APPEND INITIAL LINE TO gs_acdocument-accountgl ASSIGNING <fs_accountgl>.
          <fs_accountgl>-itemno_acc = lines(  gs_acdocument-accountgl ).
          <fs_accountgl>-gl_account = ls_02-ym_hesap.
          <fs_accountgl>-material   = ls_teslimat-matnr.
          <fs_accountgl>-item_text  = ls_teslimat-maktx.
*          <fs_accountgl>-costcenter = ls_02-kostl.
          SELECT SINGLE @abap_true FROM ska1
                                   INTO @lv_bilanco_kontrol
                                  WHERE saknr = @<fs_accountgl>-gl_account
                                    AND xbilk = @space.
          IF lv_bilanco_kontrol = abap_true.
            <fs_accountgl>-costcenter = gs_kayit-kostl.
          ENDIF.
          CLEAR lv_bilanco_kontrol.
*          <fs_accountgl>-ref_key_1  = ls_teslimat-paobjnr.

          APPEND INITIAL LINE TO gs_acdocument-currencyamount ASSIGNING <fs_amount>.
          <fs_amount>-itemno_acc = lines(  gs_acdocument-currencyamount ).
          <fs_amount>-amt_doccur = ls_teslimat-netwr * -1.
          <fs_amount>-currency   = ls_teslimat-waerk.

        ENDIF.
      ENDLOOP.

*      APPEND INITIAL LINE TO gs_acdocument-accountreceivable ASSIGNING FIELD-SYMBOL(<fs_accountreceivable>).
*      <fs_accountreceivable>-itemno_acc = lines(  gs_acdocument-currencyamount )..
*      <fs_accountreceivable>-customer   = gs_kayit-kunnr.
*      <fs_accountreceivable>-item_text  = ls_003-bktxt.
*      <fs_accountreceivable>-tax_code   = gs_kayit-mwskz.

    ELSEIF gs_kayit-kayit_tur = 'YM'.

      APPEND INITIAL LINE TO gs_acdocument-currencyamount ASSIGNING <fs_amount>.
      <fs_amount>-itemno_acc = lines(  gs_acdocument-currencyamount ).
      <fs_amount>-amt_doccur = lv_karsilik * -1.
      <fs_amount>-currency   = ls_teslimat-waerk.

      APPEND INITIAL LINE TO gs_acdocument-accountpayable ASSIGNING FIELD-SYMBOL(<fs_accountpayable>).
      <fs_accountpayable>-itemno_acc = lines(  gs_acdocument-currencyamount )..
      <fs_accountpayable>-vendor_no  = gs_genel-t_01-lifnr.
      <fs_accountpayable>-item_text  = ls_003-bktxt.
      <fs_accountpayable>-tax_code   = gs_kayit-mwskz.

    ELSEIF gs_kayit-kayit_tur = 'MK' OR gs_kayit-kayit_tur = 'AH'.


      APPEND INITIAL LINE TO gs_acdocument-currencyamount ASSIGNING <fs_amount>.
      <fs_amount>-itemno_acc = lines(  gs_acdocument-currencyamount ).
      <fs_amount>-amt_doccur = lv_karsilik * -1.
      <fs_amount>-currency   = ls_teslimat-waerk.

      APPEND INITIAL LINE TO gs_acdocument-accountpayable ASSIGNING <fs_accountpayable>.
      <fs_accountpayable>-itemno_acc = lines(  gs_acdocument-currencyamount )..
      <fs_accountpayable>-vendor_no  = gs_kayit-lifnr.
      <fs_accountpayable>-item_text  = ls_003-bktxt.
      <fs_accountpayable>-tax_code   = gs_kayit-mwskz.
      <fs_accountpayable>-pmnttrms   = gs_kayit-zterm.

    ENDIF.

**
    rt_message = me->kayit_kontrol( ).


    set_creteria( ).


  ENDMETHOD.


  method ZIF_INTERCOMPANY~CHECK_STATUS.
  endmethod.


  METHOD zif_intercompany~get_data.

    DATA : lt_header TYPE TABLE OF zintcomp_s_alv_header.

    SELECT DISTINCT vbfa~vbelv AS vbeln_vl, vbfa~vbeln AS vbeln_int, vbak~vkorg, vbak~vkbur,
                    vbak~bukrs_vf, vbak~kunnr AS kunnr, vbrk~bukrs AS karsit_sirket
             FROM vbfa
       INNER JOIN vbrk
               ON vbrk~vbeln EQ vbfa~vbeln
       INNER JOIN vbrp
               ON vbrp~vbeln EQ vbrk~vbeln
       INNER JOIN vbak
               ON vbak~vbeln EQ vbrp~aubel
       INTO TABLE @DATA(lt_vbfa_int)
            WHERE vbfa~vbelv     IN @gs_parameters-s_vbeln_vl
              AND vbfa~vbtyp_v   EQ 'J'
              AND vbfa~vbtyp_n   EQ @gs_genel-t_01-int_bel_tip
              AND vbrk~fkart     EQ @gs_genel-t_01-fkart
              AND vbak~bukrs_vf  EQ @gs_parameters-bukrs
              AND vbrk~bukrs     EQ @gs_genel-t_01-bukrsz
              AND vbrk~fkdat     GE @gs_genel-t_01-bas_tarih
       .


    SELECT DISTINCT vbfa~vbelv AS vbeln_vl, vbfa~vbeln AS vbeln_mus, vbrk~fkdat
             FROM vbfa
       INNER JOIN vbrk
               ON vbrk~vbeln EQ vbfa~vbeln
       INNER JOIN @lt_vbfa_int AS itab
               ON vbfa~vbelv EQ itab~vbeln_vl
            WHERE vbfa~vbelv   IN @gs_parameters-s_vbeln_vl
              AND vbfa~vbtyp_v EQ 'J'
              AND vbfa~vbtyp_n EQ @gs_genel-t_01-mus_bel_tip
*              AND vbrk~fkart   EQ @gs_genel-t_01-fkart
       INTO TABLE @DATA(lt_vbfa_mus).

    SELECT 03~intercomp_num, 03~vbeln_vl, 03~kayit_tur, 03~sira,
           03~bukrs, 03~belnr, 03~gjahr,
           bkpf~stblg
          FROM zintcomp_t_003 AS 03
    INNER JOIN @lt_vbfa_int AS itab
            ON itab~vbeln_vl      EQ 03~vbeln_vl
     LEFT JOIN bkpf
            ON bkpf~belnr EQ 03~belnr
           AND bkpf~gjahr EQ 03~gjahr
           AND bkpf~bukrs EQ 03~bukrs
    INTO TABLE @DATA(lt_log).

    DELETE lt_log WHERE stblg <> ''.

    SORT lt_vbfa_int BY vbeln_vl .
    SORT lt_vbfa_mus BY vbeln_vl .
*    SORT lt_siparis  BY vbeln .

    LOOP AT lt_vbfa_int INTO DATA(ls_vbfa_int).
      APPEND INITIAL LINE TO lt_header ASSIGNING FIELD-SYMBOL(<fs_header>).
      <fs_header>-intercomp_fatura = ls_vbfa_int-vbeln_int.
      <fs_header>-vbeln_vl         = ls_vbfa_int-vbeln_vl.
      <fs_header>-bukrs            = ls_vbfa_int-bukrs_vf.
      <fs_header>-kunnr            = ls_vbfa_int-kunnr.
      <fs_header>-karsit_sirket    = ls_vbfa_int-karsit_sirket.
      <fs_header>-vkorg            = ls_vbfa_int-vkorg.
      <fs_header>-vkbur            = ls_vbfa_int-vkbur.

      <fs_header>-sel           = zif_intercompany~c_secim.
      <fs_header>-yol_mal_durum = zif_intercompany~c_kayitbek.
      <fs_header>-smm_durum     = zif_intercompany~c_fatyok.

      READ TABLE lt_vbfa_mus INTO DATA(ls_vbfa_mus) WITH KEY vbeln_vl = ls_vbfa_int-vbeln_vl
                                                    BINARY SEARCH.
      IF sy-subrc = 0.
        <fs_header>-musteri_fatura = ls_vbfa_mus-vbeln_mus.
        <fs_header>-fkdat          = ls_vbfa_mus-fkdat.
        <fs_header>-smm_durum      = zif_intercompany~c_kayitbek.
      ENDIF.

      READ TABLE lt_log INTO DATA(ls_log) WITH KEY vbeln_vl = ls_vbfa_int-vbeln_vl
                                                   kayit_tur = 'YM'.
      IF sy-subrc = 0.
        <fs_header>-yol_mal_belge = ls_log-belnr.
        <fs_header>-gjahr         = ls_log-gjahr.
        <fs_header>-yol_mal_durum = me->zif_intercompany~c_kayittmm.
      ENDIF.
      READ TABLE lt_log INTO ls_log WITH KEY vbeln_vl = ls_vbfa_int-vbeln_vl
                                              kayit_tur = 'SMM'.
      IF sy-subrc = 0.
        <fs_header>-smm_belge = ls_log-belnr.
        <fs_header>-gjahr     = ls_log-gjahr.
        <fs_header>-smm_durum = me->zif_intercompany~c_kayittmm.
      ENDIF.

      READ TABLE lt_log INTO ls_log WITH KEY vbeln_vl = ls_vbfa_int-vbeln_vl
                                             kayit_tur = 'TK'.
      IF sy-subrc = 0.
        <fs_header>-teslimat_kapat = abap_true.
      ENDIF.
      <fs_header>-masraf_belgeler = me->zif_intercompany~c_belgegecmis.

    ENDLOOP.

    MOVE-CORRESPONDING lt_header[] TO et_table[].

  ENDMETHOD.


  METHOD zif_intercompany~get_log.

    SELECT SINGLE * FROM zintcomp_t_003
                    INTO rs_log
                   WHERE intercomp_num = gs_kayit-key-intercomp_num
                     AND vbeln_vl      = gs_kayit-key-vbeln_vl
                     AND kayit_tur     = gs_kayit-kayit_tur
                     AND sira = ( SELECT MAX( sira ) FROM  zintcomp_t_003
                                                    WHERE intercomp_num = gs_kayit-key-intercomp_num
                                                      AND vbeln_vl      = gs_kayit-key-vbeln_vl
                                                      AND kayit_tur     = gs_kayit-kayit_tur ).


  ENDMETHOD.


  METHOD zif_intercompany~get_log_list.

    SELECT 03~intercomp_num, 03~vbeln_vl, 03~kayit_tur, 03~sira, 03~bukrs,
           03~belnr, 03~gjahr, 03~kullanici, 03~tarih, 03~saat, 03~ref_belge,
           bkpf~stblg
          FROM zintcomp_t_003 AS 03
     LEFT JOIN bkpf
            ON bkpf~belnr EQ 03~belnr
           AND bkpf~gjahr EQ 03~gjahr
           AND bkpf~bukrs EQ 03~bukrs
         WHERE 03~vbeln_vl EQ @gv_teslimat
    INTO TABLE @DATA(lt_log).

*    DELETE lt_log WHERE stblg <> ''.
    MOVE-CORRESPONDING lt_log TO rt_log.

  ENDMETHOD.


  METHOD zif_intercompany~get_mk.
    DATA : lt_data TYPE TABLE OF zintcomp_s_alv_masraf.
    DATA : lv_index TYPE sy-tabix.
    DATA : lt_style TYPE lvc_t_styl.

    DATA(lt_log) =  me->zif_intercompany~get_log_list( ).

    DELETE lt_log WHERE stblg     NE ''.
    DELETE lt_log WHERE kayit_tur NE 'MK' AND kayit_tur NE 'AH' AND kayit_tur NE 'OK' .

    MOVE-CORRESPONDING lt_log TO gs_masraf_kaydi-tt_masraf_header.

    me->get_masraf_detay( ).

    APPEND VALUE lvc_s_styl( fieldname = 'SECIM'
                             style = cl_gui_alv_grid=>mc_style_disabled ) TO lt_style.

    LOOP AT gs_masraf_kaydi-tt_masraf_header INTO DATA(ls_header).
      ADD 1 TO lv_index.

      APPEND INITIAL LINE TO lt_data ASSIGNING FIELD-SYMBOL(<fs_data_head>).
      MOVE-CORRESPONDING ls_header TO <fs_data_head>.
      <fs_data_head>-exp_col = zif_intercompany~c_expand..
      <fs_data_head>-sira    = lv_index.

      LOOP AT gs_masraf_kaydi-tt_masraf_kaydi INTO DATA(ls_item) WHERE bukrs = ls_header-bukrs
                                                                   AND gjahr = ls_header-gjahr
                                                                   AND belnr = ls_header-belnr.

        APPEND INITIAL LINE TO lt_data ASSIGNING FIELD-SYMBOL(<fs_data_item>).
        MOVE-CORRESPONDING ls_item TO <fs_data_item>.
        ADD 1 TO lv_index.
        <fs_data_item>-sira    = lv_index.
        <fs_data_item>-note    = <fs_data_head>-sira.CONDENSE <fs_data_item>-note.
        <fs_data_item>-celltab = lt_style.

      ENDLOOP.

    ENDLOOP.

    MOVE-CORRESPONDING lt_data TO et_table.


  ENDMETHOD.


  METHOD zif_intercompany~get_teslimat.

    DATA : lt_teslimat TYPE TABLE OF zintcomp_s_teslimat.

    SELECT lips~*,  makt~maktx, vbrp~*, mbew~*,
           vbrp~vbeln AS vbeln_vf, vbrp~posnr AS posnr_vf,
           vbrp_mus~paobjnr AS paobjnr_mus
             FROM lips
       INNER JOIN makt
               ON lips~matnr EQ makt~matnr
       INNER JOIN mbew
               ON mbew~matnr EQ lips~matnr
              AND mbew~bwkey EQ @gs_genel-t_01-bwkey
        LEFT JOIN vbrp
               ON vbrp~vgbel EQ lips~vbeln
              AND vbrp~vgpos EQ lips~posnr
              AND vbrp~vbeln EQ @gv_fatura
        LEFT JOIN vbrp AS vbrp_mus
               ON vbrp_mus~vgbel EQ lips~vbeln
              AND vbrp_mus~vgpos EQ lips~posnr
              AND vbrp_mus~vbeln EQ @gv_mus_fatura
      INTO CORRESPONDING FIELDS OF TABLE @lt_teslimat
            WHERE lips~vbeln = @gv_teslimat
              AND makt~spras = @sy-langu.

    LOOP AT lt_teslimat ASSIGNING FIELD-SYMBOL(<fs_teslimat>).
      <fs_teslimat>-vbeln = gv_teslimat.
    ENDLOOP.

    MOVE-CORRESPONDING lt_teslimat[] TO et_table[].

  ENDMETHOD.


  METHOD zif_intercompany~otomatik_kayit.

    DATA(lt_log) = me->zif_intercompany~get_log_list( ).

    DELETE lt_log WHERE stblg <> ''.
    DATA(tmp_log) = lt_log[].

    DELETE lt_log WHERE kayit_tur <> 'AH'.


    gs_kayit-kayit_tur = 'OK'.
    gs_kayit-commit    = 'X'.

    SELECT * FROM zintcomp_m_005
       INTO TABLE @DATA(lt_005)
            WHERE bukrs      = @gs_parameters-bukrs
              and bukrsz     = @gs_genel-t_01-bukrsz.
*              AND masraf_tip = @gs_kayit-masraf_tip.


    LOOP AT lt_log INTO DATA(ls_log).
      READ TABLE tmp_log TRANSPORTING NO FIELDS WITH KEY ref_belge = ls_log-belnr.
      CHECK sy-subrc <> 0.
      gs_kayit-ref_belge = ls_log-belnr.
      gs_kayit-karakteristik = gs_genel-t_01-mk_karakter.
      gs_kayit-masraf_tip = ls_log-masraf_tip.

      LOOP AT lt_005 INTO DATA(ls_005) where masraf_tip = ls_log-masraf_tip.
        READ TABLE gs_genel-table_02 ASSIGNING FIELD-SYMBOL(<fs_02>) WITH KEY bklas      = ls_005-bklas.
        IF sy-subrc = 0.
          <fs_02>-masraf_hesap = ls_005-masraf_hesap.
          <fs_02>-ara_hesap    = ls_005-ara_hesap.
          <fs_02>-kostl        = ls_005-kostl.
        ENDIF.
      ENDLOOP.

      me->prepare_ok(
        EXPORTING
          iv_belnr = ls_log-belnr  " Muhasebe belgesinin belge numarası
          iv_gjahr = ls_log-gjahr  " Mali yıl
      ).

      DATA(lt_message) = kayit_kontrol( ).
      IF lt_message-return_type = 'S'.
*        gs_kayit-kayit_tur = 'MK'.
        lt_message = me->post_fi( ).
        me->zif_intercompany~set_log( ).
      ENDIF.

      APPEND LINES OF lt_message-t_bapiret TO rt_message-t_bapiret.
    ENDLOOP.


  ENDMETHOD.


  METHOD zif_intercompany~post_mk.

    DATA(ls_acdoc) = me->prepare_mk( ).
    MOVE-CORRESPONDING ls_acdoc TO rt_message.
    CHECK rt_message-return_type NE 'E'.
    rt_message     = me->post_fi( ).
    DATA(lv_ok) = me->zif_intercompany~set_log( ).
    rt_message-t_acdoc = ls_acdoc.

  ENDMETHOD.


  METHOD zif_intercompany~post_smm.

    CHECK gs_genel-t_01-ym_kayit = 'X'.

    IF gs_kayit-kayit_tur  IS INITIAL.
      gs_kayit-kayit_tur  = 'SMM'.
    ENDIF.
    IF gs_kayit-hesap_alan  IS INITIAL.
      gs_kayit-hesap_alan = 'LS_02-SMM_HESAP'.
    ENDIF.
    gs_kayit-karakteristik = gs_genel-t_01-smm_karakter.

    rt_message = me->zif_intercompany~check_and_map( ).
    CHECK rt_message-return_type NE 'E'.
    rt_message     = me->post_fi( ).
    DATA(lv_ok) = me->zif_intercompany~set_log( ).

    DATA(lt_message) = zif_intercompany~otomatik_kayit( ) .
    APPEND LINES OF lt_message-t_bapiret to rt_message-t_bapiret.

  ENDMETHOD.


  METHOD zif_intercompany~post_ym.

    CHECK gs_genel-t_01-ym_kayit = 'X'.

    IF gs_kayit-kayit_tur  IS INITIAL.
      gs_kayit-kayit_tur  = 'YM'.
    ENDIF.
    IF gs_kayit-hesap_alan  IS INITIAL.
      gs_kayit-hesap_alan = 'LS_02-YM_HESAP'.
    ENDIF.
    gs_kayit-karakteristik = gs_genel-t_01-ym_karakter.

    rt_message = me->zif_intercompany~check_and_map( ).
    CHECK rt_message-return_type NE 'E'.
    rt_message     = me->post_fi( ).
    DATA(lv_ok) = me->zif_intercompany~set_log( ).


  ENDMETHOD.


  METHOD zif_intercompany~reverse.

    rt_message = kayit_kontrol( ).
    CHECK rt_message-return_type = 'S'.

    CALL FUNCTION 'CALL_FB08'
      EXPORTING
        i_bukrs      = gs_ters_kayit-bukrs
        i_belnr      = gs_ters_kayit-belnr
        i_gjahr      = gs_ters_kayit-gjahr
        i_stgrd      = '01'
*       I_BUDAT      =
      EXCEPTIONS
        not_possible = 1
        OTHERS       = 2.
    IF sy-subrc = 0.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.
      rt_message-return_type  = 'S'.
    ELSE.
      rt_message-return_type  = 'E'.
    ENDIF.


  ENDMETHOD.


  METHOD zif_intercompany~reverse_mk.

    gs_kayit-kayit_tur  = 'MK'.
    gs_kayit-ters_kayit = 'X'.

    LOOP AT gs_masraf_kaydi-tt_masraf_kaydi ASSIGNING FIELD-SYMBOL(<fs_masraf>) WHERE secim = 'X'.
      gs_ters_kayit-belnr = <fs_masraf>-belnr.
      gs_ters_kayit-gjahr = <fs_masraf>-gjahr.
      gs_ters_kayit-bukrs = <fs_masraf>-bukrs.
      rt_message = me->zif_intercompany~reverse( ).
      IF rt_message-return_type = 'S'.
        APPEND VALUE bapiret2( type = 'S' id = 'ZINTCOMPANY' number = '001'
                               message_v1 = gs_ters_kayit-belnr ) TO rt_message-t_bapiret.
      ENDIF.
*      CLEAR : lv_ok.
    ENDLOOP.

  ENDMETHOD.


  METHOD zif_intercompany~reverse_smm.

    gs_kayit-kayit_tur  = 'SMM'.
    gs_kayit-ters_kayit = 'X'.
    gs_ters_kayit-bukrs = gs_header-bukrs.
    gs_ters_kayit-gjahr = gs_header-gjahr.
    gs_ters_kayit-belnr = gs_header-smm_belge.


    rt_message = me->zif_intercompany~reverse( ).
    IF rt_message-return_type = 'S'.
      APPEND VALUE bapiret2( type = 'S' id = 'ZINTCOMPANY' number = '001'
                             message_v1 = gs_ters_kayit-belnr ) TO rt_message-t_bapiret.
      gs_header-smm_belge = ''.
      gs_header-smm_durum = zif_intercompany~c_kayitbek.
    ENDIF.


  ENDMETHOD.


  METHOD zif_intercompany~reverse_ym.

    gs_kayit-kayit_tur  = 'YM'.
    gs_kayit-ters_kayit = 'X'.
    gs_ters_kayit-bukrs = gs_header-bukrs.
    gs_ters_kayit-gjahr = gs_header-gjahr.
    gs_ters_kayit-belnr = gs_header-yol_mal_belge.


    rt_message = me->zif_intercompany~reverse( ).
    IF rt_message-return_type = 'S'.
      APPEND VALUE bapiret2( type = 'S' id = 'ZINTCOMPANY' number = '001'
                             message_v1 = gs_ters_kayit-belnr ) TO rt_message-t_bapiret.
      gs_header-yol_mal_belge = ''.
      gs_header-yol_mal_durum = zif_intercompany~c_kayitbek.
    ENDIF.

  ENDMETHOD.


  METHOD zif_intercompany~set_log.

    CHECK gs_acdocument-commit      = 'X'.
    CHECK gs_acdocument-return_type = 'S'.
    DATA(ls_log) = me->zif_intercompany~get_log( ) .

    ls_log-intercomp_num = gs_kayit-key-intercomp_num.
    ls_log-vbeln_vl      = gs_kayit-key-vbeln_vl.
    ls_log-kayit_tur     = gs_kayit-kayit_tur.
    ls_log-sira          = ls_log-sira + 1.
    ls_log-bukrs         = gs_acdocument-obj_key+10(4).
    ls_log-belnr         = gs_acdocument-obj_key(10).
    ls_log-gjahr         = gs_acdocument-obj_key+14(4).
    ls_log-ref_belge     = gs_kayit-ref_belge.
    ls_log-masraf_tip    = gs_kayit-masraf_tip.
    ls_log-kullanici     = sy-uname.
    ls_log-tarih         = sy-datum.
    ls_log-saat          = sy-uzeit.

    MODIFY zintcomp_t_003 FROM ls_log.
    COMMIT WORK.
    rv_ok = abap_true.

  ENDMETHOD.


  METHOD zif_intercompany~tes_kapat.

    gs_kayit-kayit_tur = 'TK'.

    rt_message = kayit_kontrol( ).
    CHECK rt_message-return_type NE 'E'.

    gs_acdocument-commit = gs_kayit-commit.
    zif_intercompany~set_log( ).
    gs_header-teslimat_kapat = abap_true.

  ENDMETHOD.
ENDCLASS.
