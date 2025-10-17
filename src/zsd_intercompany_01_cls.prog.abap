*&---------------------------------------------------------------------*
*& Include          ZSD_INTERCOMPANY_01_CLS
*&---------------------------------------------------------------------*

CLASS gcl_class DEFINITION.

  PUBLIC SECTION.

    CLASS-DATA : mo_instance TYPE REF TO gcl_class.
    CLASS-DATA : mt_out      TYPE STANDARD TABLE OF zintcomp_s_alv_header.
    CLASS-DATA : mt_out_tesl TYPE STANDARD TABLE OF zintcomp_s_teslimat.
    CLASS-DATA : mt_masraf   TYPE STANDARD TABLE OF zintcomp_s_alv_masraf.
    CLASS-DATA : mt_masraf_tmp TYPE STANDARD TABLE OF zintcomp_s_alv_masraf.
    CLASS-DATA : mt_pop_tesl TYPE STANDARD TABLE OF zintcomp_s_teslimat_secim.
    CLASS-DATA : mt_akis     TYPE STANDARD TABLE OF zintcomp_s_akis.
    CLASS-DATA : mo_grid  TYPE REF TO cl_gui_alv_grid,
                 mo_cutom TYPE REF TO cl_gui_custom_container.
    CLASS-DATA : mo_grid_tesl  TYPE REF TO cl_gui_alv_grid,
                 mo_cutom_tesl TYPE REF TO cl_gui_custom_container.
    CLASS-DATA : mo_grid_tesl_pop  TYPE REF TO cl_gui_alv_grid,
                 mo_cutom_tesl_pop TYPE REF TO cl_gui_custom_container.
    CLASS-DATA : mo_grid_akis  TYPE REF TO cl_gui_alv_grid,
                 mo_cutom_akis TYPE REF TO cl_gui_custom_container.
    CLASS-DATA : mo_grid_masraf  TYPE REF TO cl_gui_alv_grid,
                 mo_cutom_masraf TYPE REF TO cl_gui_custom_container.
    CLASS-DATA : mv_teslimat TYPE vbeln_vl.
    CLASS-DATA : mt_kostl    TYPE zsd_bakimlar_3.
    CLASS-DATA : mo_object   TYPE REF TO zcl_intercompany_us.


    CONSTANTS : mc_container     TYPE char20        VALUE 'CC1',
                mc_cont_tesl     TYPE char20        VALUE 'CC2',
                mc_cont_masr     TYPE char20        VALUE 'CC3',
                mc_cont_akıs     TYPE char20        VALUE 'CC4',
                mc_cont_popup    TYPE char20        VALUE 'CC5',
                mc_cont_masraf   TYPE char20        VALUE 'CC6',
                mc_structure     TYPE dd02l-tabname VALUE 'ZINTCOMP_S_ALV_HEADER',
                mc_strc_tesl     TYPE dd02l-tabname VALUE 'ZINTCOMP_S_TESLIMAT',
                mc_strc_masraf   TYPE dd02l-tabname VALUE 'ZINTCOMP_S_ALV_MASRAF',
                mc_strc_tesl_pop TYPE dd02l-tabname VALUE 'ZINTCOMP_S_TESLIMAT_SECIM',
                mc_strc_akis     TYPE dd02l-tabname VALUE 'ZINTCOMP_S_AKIS',
                mc_strc_masr     TYPE dd02l-tabname VALUE 'ZZZ',
                mc_selmod        TYPE char1         VALUE 'A',
                mc_back          TYPE char10        VALUE 'BACK',
                mc_leave         TYPE char10        VALUE 'LEAVE',
                mc_exit          TYPE char10        VALUE 'EXIT',
                mc_ym_kyt        TYPE char100       VALUE 'YM_KAYIT',
                mc_masraf        TYPE char100       VALUE 'MASRAF',
                mc_masraf_kayıt  TYPE char100       VALUE 'MASRAF_KAYIT',
                mc_masraf_sim    TYPE char100       VALUE 'MASRAF_SIM',
                mc_masraf_tk     TYPE char100       VALUE 'MASRAF_TK',
                mc_ym_tk         TYPE char100       VALUE 'YM_TK',
                mc_smm_tk        TYPE char100       VALUE 'SMM_TK',
                mc_smm_kayit     TYPE char100       VALUE 'SMM_KAYIT',
                mc_tes_kapat     TYPE char100       VALUE 'TES_KAPAT',
                mc_oto_kayit     TYPE char100       VALUE 'OTO_KAYIT',
                mc_line_clr      TYPE char100       VALUE 'C310'
                .


    DATA : ms_layout  TYPE lvc_s_layo,
           ms_variant TYPE disvariant.

    DATA : mt_fieldcat TYPE lvc_t_fcat.
    DATA : mt_masraf_pop TYPE zif_intercompany=>tt_log.



    CLASS-METHODS:
      class_constructor,
      get_instance RETURNING VALUE(ro_instance) TYPE REF TO gcl_class.

    METHODS:

      get_data
        RETURNING VALUE(r_error) TYPE char1,
      "    display_alv
      "     IMPORTING
      "        it_data TYPE STANDARD TABLE,


      display_alv
        IMPORTING
          iv_table_name       TYPE char100
          VALUE(it_data)      TYPE STANDARD TABLE
          VALUE(iv_structure) TYPE dd02l-tabname
          VALUE(iv_container) TYPE char20
          VALUE(iv_variant)   TYPE char20
          iv_top_page         TYPE char1 OPTIONAL
          iv_data_change      TYPE char1 OPTIONAL
          iv_toolbar          TYPE char1 OPTIONAL
          iv_stylefname       TYPE lvc_fname OPTIONAL
        CHANGING
          VALUE(co_grid)      TYPE REF TO cl_gui_alv_grid
          VALUE(co_cutom)     TYPE REF TO cl_gui_custom_container
        ,

      run,

      handle_hotspot_click
            FOR EVENT hotspot_click OF cl_gui_alv_grid
        IMPORTING
            e_row_id
            e_column_id
            es_row_no
            sender,


      double_click
                    FOR EVENT double_click OF cl_gui_alv_grid
        IMPORTING e_row
                    e_column ,

      handle_toolbar_set
            FOR EVENT toolbar OF cl_gui_alv_grid
        IMPORTING
            e_object
            e_interactive,

      handle_toolbar_masraf
            FOR EVENT toolbar OF cl_gui_alv_grid
        IMPORTING
            e_object
            e_interactive,

      handle_user_command
            FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING
            e_ucomm,
      handle_data_changed
                    FOR EVENT data_changed OF cl_gui_alv_grid
        IMPORTING er_data_changed,

      initialization,

      refresh_alv
        IMPORTING
          io_grid TYPE REF TO cl_gui_alv_grid,

      post_masraf,

      set_action
        IMPORTING
*          is_out    TYPE zintcomp_s_alv_header
          iv_action TYPE string,

      display_simulation
        IMPORTING
          is_acdoc  TYPE zcl_intercompany_us=>t_bapiacc
          it_header TYPE table OPTIONAL
          it_item   TYPE table OPTIONAL
          iv_sim    TYPE char1 OPTIONAL

        .

  PRIVATE SECTION.

    METHODS:
      fill_data,
      create_fieldcat
        IMPORTING
          iv_structure_name TYPE dd02l-tabname
          it_data           TYPE STANDARD TABLE OPTIONAL
        EXPORTING
          et_fieldcat       TYPE lvc_t_fcat,

      create_object
        IMPORTING
          iv_container    TYPE c
        EXPORTING
          er_grid         TYPE REF TO cl_gui_alv_grid
        CHANGING
          VALUE(co_cutom) TYPE REF TO cl_gui_custom_container,

      set_layout
        IMPORTING
          iv_zebra      TYPE char1 OPTIONAL
          iv_edit       TYPE char1 OPTIONAL
          iv_sel        TYPE char1 OPTIONAL
          iv_toll_b     TYPE char1 OPTIONAL
          iv_cwidth     TYPE char1 OPTIONAL
          iv_stylefname TYPE lvc_fname OPTIONAL
        CHANGING
          cs_layout     TYPE lvc_s_layo,

      set_handler
        IMPORTING
          ir_grid    TYPE REF TO cl_gui_alv_grid
          iv_toolbar TYPE char1 OPTIONAL,

      set_detay
        IMPORTING
          is_out      TYPE zintcomp_s_alv_header
          e_column_id TYPE string OPTIONAL,

      set_masraf_belge
        IMPORTING
          is_out      TYPE zintcomp_s_alv_header
          e_column_id TYPE string OPTIONAL,

      exp_col
        CHANGING
          is_out TYPE zintcomp_s_alv_masraf,

      set_popup,

      set_masraf_detay.

ENDCLASS.

CLASS lcl_event_handler DEFINITION.
  PUBLIC SECTION.
    METHODS on_double_click
                  FOR EVENT double_click OF cl_salv_events_table
      IMPORTING row column.
ENDCLASS.

CLASS gcl_class IMPLEMENTATION.
  METHOD class_constructor.

    IF mo_instance IS NOT BOUND.
      mo_instance = NEW #( ).
    ENDIF.

  ENDMETHOD.


  METHOD run.

    DATA(lv_err) = me->get_data( ).
*    CHECK lv_err IS INITIAL.
    me->fill_data( ).

    CALL SCREEN 0100.

  ENDMETHOD.

  METHOD get_instance.

    ro_instance = mo_instance.

  ENDMETHOD.

  METHOD get_data.

    DATA : lr_vbelnv TYPE RANGE OF lips-vbeln.

    AUTHORITY-CHECK OBJECT 'ZBUKRS' ID 'BUKRS' FIELD p_bukrs.
    IF sy-subrc <> 0.
      MESSAGE e009(zintcompany) WITH p_bukrs.
    ENDIF.

    IF p_bukrs = '8200'.
      mo_object = NEW zcl_intercompany_us( iv_bukrs  = p_bukrs iv_bukrsz = p_bukrsz ).
    ELSEIF p_bukrs = '8000'.
      mo_object = NEW zcl_intercompany_it( iv_bukrs  = p_bukrs iv_bukrsz = p_bukrsz ).
    ENDIF.

    mo_object->gs_parameters-bukrs      = p_bukrs.
    mo_object->gs_parameters-s_vbeln_vl = s_vbelnv[].
    mo_object->gs_parameters-s_vbeln    = s_vbeln[].

    mo_object->zif_intercompany~get_data(
      IMPORTING
        et_table = mt_out
    ).

    IF mt_out IS INITIAL.
      r_error = abap_true.
    ENDIF.

  ENDMETHOD.

  METHOD fill_data.


  ENDMETHOD.

  METHOD create_fieldcat.
    DATA: lt_ddic TYPE TABLE OF dfies.

    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
*       I_BUFFER_ACTIVE        = 'X'
        i_structure_name       = iv_structure_name
*       I_CLIENT_NEVER_DISPLAY = 'X'
*       I_BYPASSING_BUFFER     = 'X'
      CHANGING
        ct_fieldcat            = et_fieldcat[]
      EXCEPTIONS
        inconsistent_interface = 1
        program_error          = 2
        OTHERS                 = 3.

    IF sy-langu NE 'T'.

      CALL FUNCTION 'DDIF_FIELDINFO_GET'
        EXPORTING
          tabname        = iv_structure_name
          langu          = sy-langu
        TABLES
          dfies_tab      = lt_ddic
        EXCEPTIONS
          not_found      = 1
          internal_error = 2
          OTHERS         = 3.

      LOOP AT et_fieldcat ASSIGNING FIELD-SYMBOL(<fs_fcat>) WHERE reptext IS INITIAL.
        READ TABLE lt_ddic INTO DATA(ls_ddic) WITH KEY fieldname = <fs_fcat>-fieldname.
        IF sy-subrc = 0.
          SELECT SINGLE reptext FROM dd04t
            INTO @<fs_fcat>-reptext
            WHERE rollname   = @ls_ddic-rollname
              AND ddlanguage = @sy-langu.
        ENDIF.
      ENDLOOP.
    ENDIF.

    READ TABLE et_fieldcat ASSIGNING <fs_fcat> WITH KEY fieldname = 'INTERCOMP_NUM'.
    IF sy-subrc = 0.
      <fs_fcat>-no_out = 'X'.
    ENDIF.
    READ TABLE et_fieldcat ASSIGNING <fs_fcat> WITH KEY fieldname =  'SEL'.
    IF sy-subrc = 0.
      <fs_fcat>-hotspot = 'X'.
    ENDIF.
    READ TABLE et_fieldcat ASSIGNING <fs_fcat> WITH KEY fieldname =  'EXP_COL'.
    IF sy-subrc = 0.
      <fs_fcat>-hotspot = 'X'.
    ENDIF.
    READ TABLE et_fieldcat ASSIGNING <fs_fcat> WITH KEY fieldname =  'MASRAF_BELGELER'.
    IF sy-subrc = 0.
      <fs_fcat>-hotspot = 'X'.
    ENDIF.
    READ TABLE et_fieldcat ASSIGNING <fs_fcat> WITH KEY fieldname = 'SECIM'.
    IF sy-subrc = 0.
      <fs_fcat>-edit = 'X'.
      <fs_fcat>-checkbox = 'X'.
      <fs_fcat>-just = 'C'.
      <fs_fcat>-fix_column = 'X'.
    ENDIF.

  ENDMETHOD.

  METHOD display_alv.
    DATA : ls_stable TYPE lvc_s_stbl .
    DATA : lt_fieldcat TYPE lvc_t_fcat.
    DATA : ls_variant TYPE disvariant.
    DATA : ls_layout TYPE lvc_s_layo.
    FIELD-SYMBOLS : <fs_data> TYPE ANY TABLE.

    ASSIGN (iv_table_name) TO <fs_data>.

    IF co_cutom IS INITIAL.

      me->create_fieldcat(
        EXPORTING
          iv_structure_name = iv_structure
          it_data           = it_data
        IMPORTING
          et_fieldcat       = lt_fieldcat
      ).

      me->create_object(
        EXPORTING
          iv_container = iv_container
        IMPORTING
          er_grid      = co_grid
       CHANGING
         co_cutom      = co_cutom
      ).

      me->set_layout(
        EXPORTING
          iv_zebra  = abap_true
*          iv_edit   = abap_true
          iv_sel    = mc_selmod
*          iv_toll_b = abap_true
*          iv_cwidth = abap_true
          iv_stylefname = iv_stylefname
        CHANGING
          cs_layout = ls_layout
      ).

      ls_variant-report   = sy-repid.
      ls_variant-username = sy-uname.
      ls_variant-variant  = iv_variant.

      me->set_handler(
        EXPORTING
          ir_grid    = co_grid
          iv_toolbar = iv_toolbar
      ).

      CALL METHOD co_grid->set_table_for_first_display
        EXPORTING
          i_save                        = 'A'
          i_default                     = 'X'
          is_layout                     = ls_layout
          is_variant                    = ls_variant
*         it_toolbar_excluding          = lt_exclude
        CHANGING
          it_outtab                     = <fs_data>[]
          it_fieldcatalog               = lt_fieldcat[]
*         it_sort                       = t_sort
        EXCEPTIONS
          invalid_parameter_combination = 1
          program_error                 = 2
          too_many_lines                = 3
          OTHERS                        = 4.

      "    if iv_top_page = abap_true.
      "
      "      call method co_grid->list_processing_events
      "        exporting
      "          i_event_name = 'TOP_OF_PAGE'
      "          i_dyndoc_id  = go_docu.
      "
      "     endif.

      IF iv_data_change = abap_true.

        CALL METHOD co_grid->register_edit_event
          EXPORTING
            i_event_id = cl_gui_alv_grid=>mc_evt_enter
          EXCEPTIONS
            error      = 1
            OTHERS     = 2.

        CALL METHOD co_grid->register_edit_event
          EXPORTING
            i_event_id = cl_gui_alv_grid=>mc_evt_modified
          EXCEPTIONS
            error      = 1
            OTHERS     = 2.

      ENDIF.

    ELSE.

      me->refresh_alv( co_grid ).

    ENDIF.


  ENDMETHOD.

  METHOD set_layout.

    cs_layout-zebra      = iv_zebra.
    cs_layout-edit       = iv_edit.
    cs_layout-sel_mode   = iv_sel.
    cs_layout-no_toolbar = iv_toll_b.
    cs_layout-cwidth_opt = iv_cwidth.
    cs_layout-no_rowmark = abap_true.
    cs_layout-stylefname = iv_stylefname     .
    cs_layout-info_fname = 'LINE_COLOR'.


  ENDMETHOD.


  METHOD handle_hotspot_click.
    DATA: ls_col_id   TYPE lvc_s_col.
    DATA :  cell_table    TYPE lvc_t_scol.

    LOOP AT mt_out ASSIGNING FIELD-SYMBOL(<fs_out>).
      CLEAR : <fs_out>-line_color.
    ENDLOOP.

    READ TABLE mt_out ASSIGNING <fs_out> INDEX e_row_id-index.
    READ TABLE mt_masraf ASSIGNING FIELD-SYMBOL(<fs_masraf>) INDEX e_row_id-index.

    IF e_column_id =  'MASRAF_BELGELER'.
      set_masraf_belge( is_out = <fs_out> ).
      me->refresh_alv( io_grid = mo_grid_akis  ).
    ELSEIF e_column_id =  'EXP_COL'.
      exp_col( CHANGING is_out = <fs_masraf>  ).
      me->refresh_alv( io_grid = mo_grid_masraf  ).
    ELSEIF e_column_id =  'SEL'.
      <fs_out>-line_color = mc_line_clr.
      mv_teslimat = <fs_out>-vbeln_vl.
      set_detay( is_out = <fs_out> ).
      cl_gui_cfw=>set_new_ok_code( new_code = 'REFR' ) .
    ENDIF.

*    BREAK-POINT.
  ENDMETHOD.                    "handle_hotspot_click

  METHOD double_click.
    DATA : lv_name TYPE string.
    FIELD-SYMBOLS : <fs_val> TYPE any.

    READ TABLE mt_out INTO DATA(ls_out) INDEX e_row-index.
    CASE e_column-fieldname.
      WHEN 'YOL_MAL_BELGE' OR 'SMM_BELGE'.
        UNASSIGN <fs_val>.
        lv_name = |LS_OUT-{ e_column-fieldname }|.
        ASSIGN (lv_name) TO <fs_val>.
        CHECK <fs_val> IS ASSIGNED.

        SET PARAMETER ID 'BLN' FIELD <fs_val>.
        SET PARAMETER ID 'BUK' FIELD ls_out-bukrs.
        SET PARAMETER ID 'GJR' FIELD ls_out-gjahr.
        CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.

      WHEN 'INTERCOMP_FATURA' OR 'MUSTERI_FATURA'.
        UNASSIGN <fs_val>.
        lv_name = |LS_OUT-{ e_column-fieldname }|.
        ASSIGN (lv_name) TO <fs_val>.
        CHECK <fs_val> IS ASSIGNED.

        SET PARAMETER ID 'VF' FIELD <fs_val>.
        CALL TRANSACTION 'VF03' AND SKIP FIRST SCREEN.

      WHEN 'VBELN_VL' .
        UNASSIGN <fs_val>.
        lv_name = |LS_OUT-{ e_column-fieldname }|.
        ASSIGN (lv_name) TO <fs_val>.
        CHECK <fs_val> IS ASSIGNED.

        SET PARAMETER ID 'VL' FIELD <fs_val>.
        CALL TRANSACTION 'VF03' AND SKIP FIRST SCREEN.

    ENDCASE.

    me->refresh_alv( mo_grid ).


  ENDMETHOD.

  METHOD handle_toolbar_set.
    DATA:  ty_toolbar      TYPE stb_button.

    CLEAR ty_toolbar.
    CLEAR ty_toolbar.
    "  · ekrana buton ekleme

    CLEAR ty_toolbar.
    MOVE 3 TO ty_toolbar-butn_type. "separator
    APPEND ty_toolbar TO e_object->mt_toolbar.



    ty_toolbar-function = mc_ym_kyt. "name of btn to  catch click
    ty_toolbar-butn_type = 0.
    MOVE icon_system_save  TO ty_toolbar-icon.
    ty_toolbar-text = TEXT-001.
    APPEND ty_toolbar  TO e_object->mt_toolbar.


    ty_toolbar-function = mc_ym_tk. "name of btn to  catch click
    ty_toolbar-butn_type = 0.
    MOVE icon_system_redo  TO ty_toolbar-icon.
    ty_toolbar-text = TEXT-002.
    APPEND ty_toolbar  TO e_object->mt_toolbar.
*

    CLEAR ty_toolbar.
    MOVE 3 TO ty_toolbar-butn_type. "separator
    APPEND ty_toolbar TO e_object->mt_toolbar.


    ty_toolbar-function = mc_smm_kayit. "name of btn to  catch click
    ty_toolbar-butn_type = 0.
    MOVE icon_system_save  TO ty_toolbar-icon.
    ty_toolbar-text = TEXT-003.
    APPEND ty_toolbar  TO e_object->mt_toolbar.


    ty_toolbar-function = mc_smm_tk. "name of btn to  catch click
    ty_toolbar-butn_type = 0.
    MOVE icon_system_redo  TO ty_toolbar-icon.
    ty_toolbar-text = TEXT-004.
    APPEND ty_toolbar  TO e_object->mt_toolbar.
*

    CLEAR ty_toolbar.
    MOVE 3 TO ty_toolbar-butn_type. "separator
    APPEND ty_toolbar TO e_object->mt_toolbar.

    ty_toolbar-function = mc_masraf. "name of btn to  catch click
    ty_toolbar-butn_type = 0.
    MOVE icon_cost_components  TO ty_toolbar-icon.
    ty_toolbar-text = TEXT-005.
    APPEND ty_toolbar  TO e_object->mt_toolbar.

    CLEAR ty_toolbar.
    MOVE 3 TO ty_toolbar-butn_type. "separator
    APPEND ty_toolbar TO e_object->mt_toolbar.

    ty_toolbar-function = mc_oto_kayit. "name of btn to  catch click
    ty_toolbar-butn_type = 0.
    MOVE icon_release  TO ty_toolbar-icon.
    ty_toolbar-text = TEXT-006.
    APPEND ty_toolbar  TO e_object->mt_toolbar.


    CLEAR ty_toolbar.
    MOVE 3 TO ty_toolbar-butn_type. "separator
    APPEND ty_toolbar TO e_object->mt_toolbar.

    ty_toolbar-function = mc_tes_kapat. "name of btn to  catch click
    ty_toolbar-butn_type = 0.
    MOVE icon_close_object  TO ty_toolbar-icon.
    ty_toolbar-text = TEXT-007.
    APPEND ty_toolbar  TO e_object->mt_toolbar.


    DELETE e_object->mt_toolbar
       WHERE function EQ '&DETAIL'
          OR function EQ '&&SEP00'
          OR function EQ '&CHECK'
          OR function EQ '&REFRESH'
          OR function EQ '&&SEP01'
          OR function EQ '&LOCAL&CUT'
          OR function EQ '&LOCAL&COPY'
          OR function EQ '&LOCAL&PASTE'
          OR function EQ '&LOCAL&UNDO'
          OR function EQ '&&SEP02'
          OR function EQ '&LOCAL&APPEND'
          OR function EQ '&LOCAL&INSERT_ROW'
          OR function EQ '&LOCAL&DELETE_ROW'
          OR function EQ '&LOCAL&COPY_ROW'
          OR function EQ '&&SEP03'
          OR function EQ '&&SEP06'
          OR function EQ '&GRAPH'
          OR function EQ '&&SEP07'
          OR function EQ '&INFO'.

  ENDMETHOD.                    "handle_toolbar_set

  METHOD handle_toolbar_masraf.
    DATA:  ty_toolbar      TYPE stb_button.

    CLEAR ty_toolbar.
    CLEAR ty_toolbar.
    "  · ekrana buton ekleme

    DELETE e_object->mt_toolbar WHERE function NE ''.

    ty_toolbar-function = mc_masraf_tk. "name of btn to  catch click
    ty_toolbar-butn_type = 0.
    MOVE icon_system_redo  TO ty_toolbar-icon.
    ty_toolbar-text = TEXT-008.
    APPEND ty_toolbar  TO e_object->mt_toolbar.

  ENDMETHOD.


  METHOD handle_user_command.
    DATA: index_rows TYPE lvc_t_row,
          index      LIKE LINE OF index_rows.

    CLEAR index_rows. REFRESH index_rows.

    CALL METHOD mo_grid->get_selected_rows
      IMPORTING
        et_index_rows = index_rows.

    DATA: wr_data_changed TYPE REF TO cl_alv_changed_data_protocol.
    DATA: lt_rows  TYPE lvc_t_row,
          lt_index TYPE  lvc_s_row-index.

    DATA : gi_index_rows TYPE lvc_t_row .
    DATA : wa_index_rows TYPE LINE OF lvc_t_row .

    READ TABLE mt_out TRANSPORTING NO FIELDS WITH KEY line_color = mc_line_clr.
    CHECK sy-subrc = 0.
    IF sy-subrc <> 0.
      MESSAGE s007(zintcompany) DISPLAY LIKE 'R'.
      RETURN.
    ENDIF.

    set_action( iv_action = CONV #( e_ucomm ) ).

    me->refresh_alv( mo_grid ).
    me->refresh_alv( mo_grid_akis ).
    me->refresh_alv( mo_grid_tesl ).
    me->refresh_alv( mo_grid_tesl_pop ).
    me->refresh_alv( mo_grid_masraf ).

  ENDMETHOD.                    "handle_user_command



  METHOD handle_data_changed.
    DATA: ls_good      TYPE lvc_s_modi,
          ls_sflight   TYPE sflight,
          ls_good_cost TYPE lvc_s_modi.

    DATA: ls_modi TYPE lvc_s_modi.
    DATA: ls_stbl TYPE lvc_s_stbl.

    FIELD-SYMBOLS : <fs_table> TYPE ANY TABLE.


    ASSIGN er_data_changed->mp_mod_rows->* TO
    FIELD-SYMBOL(<fs_mod_rows>).
    ASSIGN er_data_changed->mt_mod_cells TO FIELD-SYMBOL(<fs_cells>).

    LOOP AT er_data_changed->mt_good_cells INTO ls_good.

      DATA(lv_name) = '<FS_MOD_ROWS>'.
      ASSIGN (lv_name) TO <fs_table>.
      LOOP AT <fs_table> ASSIGNING FIELD-SYMBOL(<fs_tab>).
*        ls_table = <fs_tab>.
*READ TABLE gt_table ASSIGNING FIELD-SYMBOL(<fs_line_table>) index .
        CASE ls_good-fieldname.
          WHEN 'ALIS_TUTAR' OR 'MARK_UP'.

          WHEN 'URUN'.

          WHEN 'VADE_AYI'.

        ENDCASE.

      ENDLOOP.
    ENDLOOP.

    me->refresh_alv( mo_grid ).

  ENDMETHOD. "handle_data_changed

  METHOD set_handler.

    CREATE OBJECT go_ctrl.

    SET HANDLER go_ctrl->double_click         FOR ir_grid.
    SET HANDLER go_ctrl->handle_data_changed  FOR ir_grid.
    SET HANDLER go_ctrl->handle_hotspot_click FOR ir_grid.
    SET HANDLER go_ctrl->handle_user_command  FOR ir_grid.

    IF iv_toolbar = 'X'.
      SET HANDLER go_ctrl->handle_toolbar_set   FOR ir_grid.
    ELSEIF iv_toolbar = 'M'.
      SET HANDLER go_ctrl->handle_toolbar_masraf   FOR ir_grid.
    ENDIF.


  ENDMETHOD.

  METHOD initialization.

  ENDMETHOD.

  METHOD refresh_alv.

    CHECK io_grid IS BOUND.
    DATA : ls_stable TYPE lvc_s_stbl .
    ls_stable-col = abap_true.
    ls_stable-row = abap_true.

    CALL METHOD io_grid->refresh_table_display
      EXPORTING
        is_stable = ls_stable
      EXCEPTIONS
        finished  = 1
        OTHERS    = 2.

  ENDMETHOD.

  METHOD create_object.

    FREE co_cutom.

    CREATE OBJECT co_cutom
      EXPORTING
        container_name = iv_container.

    CREATE OBJECT er_grid
      EXPORTING
        i_parent = co_cutom.

  ENDMETHOD.

  METHOD set_detay.

    mo_object->gv_teslimat   = is_out-vbeln_vl.
    mo_object->gv_fatura     = is_out-intercomp_fatura.
    mo_object->gv_mus_fatura = is_out-musteri_fatura.

    mo_object->zif_intercompany~get_teslimat(
      IMPORTING
        et_table = mt_out_tesl
    ).

    mt_akis = mo_object->zif_intercompany~get_log_list( ).

    me->set_masraf_detay( ).

  ENDMETHOD.

  METHOD set_masraf_belge.
    DATA alv TYPE REF TO cl_salv_table.
    DATA lo_event TYPE REF TO cl_salv_events_table.
    DATA message TYPE REF TO cx_salv_msg.
**********COlumns Operation***********
    DATA columns TYPE REF TO cl_salv_columns_table.
    DATA column  TYPE REF TO cl_salv_column.
    DATA gr_display TYPE REF TO cl_salv_display_settings.
    DATA : lt_masraf TYPE zif_intercompany=>tt_log.
    DATA not_found TYPE REF TO cx_salv_not_found.

    mo_object->gv_teslimat = is_out-vbeln_vl.
    mo_object->gv_fatura   = is_out-intercomp_fatura.

    mt_masraf_pop = mo_object->zif_intercompany~get_log_list( ).
    DELETE mt_masraf_pop WHERE kayit_tur NE 'MK' AND kayit_tur NE 'AH' AND kayit_tur NE 'OK'.

    TRY.
        cl_salv_table=>factory(
          IMPORTING
            r_salv_table = alv
          CHANGING
            t_table      = mt_masraf_pop ).
      CATCH cx_salv_msg INTO message.
        " error handling
    ENDTRY.

    DATA(lo_handler) = NEW lcl_event_handler( ).
    lo_event  = alv->get_event( ).
    SET HANDLER lo_handler->on_double_click FOR lo_event.

    columns = alv->get_columns( ).
    columns->set_optimize( ).

    TRY.
        column = columns->get_column( 'MANDT' ).
        column->set_visible( if_salv_c_bool_sap=>false ).
      CATCH cx_salv_not_found INTO not_found.
        " error handling
    ENDTRY.

    TRY.
        column = columns->get_column( 'INTERCOMP_NUM' ).
        column->set_visible( if_salv_c_bool_sap=>false ).
      CATCH cx_salv_not_found INTO not_found.
        " error handling
    ENDTRY.

    TRY.
        column = columns->get_column( 'MASRAF_TIP' ).
        column->set_visible( if_salv_c_bool_sap=>false ).
      CATCH cx_salv_not_found INTO not_found.
        " error handling
    ENDTRY.



    alv->set_screen_popup(
        start_column = 10
        end_column   = 100
        start_line   = 10
        end_line     = 30 ).

    alv->display( ).

  ENDMETHOD.

  METHOD set_action.
    DATA : lt_teslimat TYPE TABLE OF zintcomp_s_teslimat_secim.
    DATA : ls_celltab  TYPE lvc_s_styl.
    DATA : lt_celltab  TYPE lvc_t_styl.
    DATA : returncode.
    DATA : ivals TYPE TABLE OF sval,
           xvals TYPE sval.

    CLEAR: xvals, ivals[].
    xvals-tabname   = 'BKPF'.
    xvals-fieldname = 'BUDAT'.
    xvals-value     = sy-datum.
    APPEND xvals TO ivals.

    CLEAR: mo_object->gs_kayit.
    MOVE-CORRESPONDING mt_out_tesl TO lt_teslimat.

    LOOP AT lt_teslimat ASSIGNING FIELD-SYMBOL(<fs_teslimat>).
      DATA(lv_tabix) = sy-tabix.
      CLEAR : lt_celltab.
      IF <fs_teslimat>-netwr <> 0.
        <fs_teslimat>-secim = 'X'.
        CLEAR : <fs_teslimat>-celltab.
        IF mo_object->gs_genel-t_01-teslimat_secim = 'X'.
        ENDIF.

        ls_celltab-fieldname = 'SECIM'.
        ls_celltab-style = COND #( WHEN
        mo_object->gs_genel-t_01-teslimat_secim = 'X' THEN
                  cl_gui_alv_grid=>mc_style_disabled
                      ELSE  cl_gui_alv_grid=>mc_style_enabled ).
        APPEND ls_celltab TO lt_celltab.
        <fs_teslimat>-celltab = lt_celltab.
      ELSE.
*APPEND INITIAL LINE TO lt_celltab ASSIGNING FIELD-SYMBOL(<fs_celltab>).
        DELETE lt_teslimat INDEX lv_tabix.
        CONTINUE.
        ls_celltab-fieldname = 'SECIM'.
        ls_celltab-style = cl_gui_alv_grid=>mc_style_disabled.
        APPEND ls_celltab TO lt_celltab.
        <fs_teslimat>-celltab = lt_celltab.
      ENDIF.
    ENDLOOP.


    READ TABLE mt_out ASSIGNING FIELD-SYMBOL(<fs_out>) WITH KEY line_color = mc_line_clr.
    CHECK sy-subrc = 0.
*    IF sy-subrc <> 0.
*      MESSAGE s007(zintcompany) DISPLAY LIKE 'R'.
*      RETURN.
*    ENDIF.
    mo_object->gs_kayit-t_teslimat        = lt_teslimat.
    mo_object->gs_kayit-key-intercomp_num = <fs_out>-intercomp_num.
    mo_object->gs_kayit-key-vbeln_vl      = <fs_out>-vbeln_vl.
    mo_object->gs_kayit-kunnr             = <fs_out>-kunnr.
    mo_object->gs_kayit-bukrs             = <fs_out>-bukrs.
    SELECT SINGLE kostl FROM zsd_bakimlar_3 INTO mo_object->gs_kayit-kostl
                       WHERE vkorg = <fs_out>-vkorg AND vkbur = <fs_out>-vkbur.

    CASE iv_action.
      WHEN mc_ym_kyt.
        CALL FUNCTION 'POPUP_GET_VALUES'
          EXPORTING
            popup_title     = 'Kayıt parametreleri'
          IMPORTING
            returncode      = returncode
          TABLES
            fields          = ivals
          EXCEPTIONS
            error_in_fields = 1
            OTHERS          = 2.
        READ TABLE ivals INTO xvals WITH KEY fieldname = 'BUDAT'.
        IF sy-subrc  = 0.
          CONDENSE xvals-value.
          mo_object->gs_kayit-budat = xvals-value.
        ENDIF.
        mo_object->gs_kayit-commit    = abap_true.
        mo_object->gs_kayit-ref_belge = <fs_out>-intercomp_fatura.

        DATA(ls_return) =  mo_object->zif_intercompany~post_ym( ).
        cl_rmsl_message=>display( ls_return-t_bapiret ).
        IF ls_return-return_type = 'S'.
          <fs_out>-yol_mal_belge    = ls_return-obj_key(10).
          <fs_out>-gjahr            = ls_return-obj_key+14(4).
          <fs_out>-yol_mal_durum    =  mo_object->zif_intercompany~c_kayittmm.
        ELSE.
          <fs_out>-yol_mal_durum    =  mo_object->zif_intercompany~c_kayithat.
        ENDIF.

      WHEN mc_smm_kayit.

        mo_object->gs_kayit-commit    = abap_true.
        mo_object->gs_kayit-ref_belge = <fs_out>-musteri_fatura.
        mo_object->gs_kayit-budat     = <fs_out>-fkdat.
*        select single

        ls_return =  mo_object->zif_intercompany~post_smm( ).
        cl_rmsl_message=>display( ls_return-t_bapiret ).
        IF ls_return-return_type = 'S'.
          <fs_out>-smm_belge     = ls_return-obj_key(10).
          <fs_out>-gjahr         = ls_return-obj_key+14(4).
          <fs_out>-smm_durum     =  mo_object->zif_intercompany~c_kayittmm.
        ELSE.
          <fs_out>-smm_durum     =  mo_object->zif_intercompany~c_kayithat.
        ENDIF.


      WHEN mc_masraf_kayıt.


        mo_object->gs_kayit-commit       = abap_true.
        mo_object->gs_kayit-ref_belge    = COND #( WHEN  <fs_out>-smm_belge IS NOT INITIAL THEN <fs_out>-smm_belge
                                                   ELSE <fs_out>-yol_mal_belge ) .
        mo_object->gs_kayit-ara_hesap    = COND #( WHEN <fs_out>-smm_belge IS INITIAL THEN 'X' ).
        mo_object->gs_kayit-masraf_tip   = zintcomp_s_masraf_header-masraf_tip.
        mo_object->gs_kayit-dagitim_tipi =  zintcomp_s_masraf_header-dagitim_tipi.
        mo_object->gs_kayit-masraf_tutar = zintcomp_s_masraf_header-wrbtr.
        mo_object->gs_kayit-t_teslimat   = mt_pop_tesl.
        mo_object->gs_kayit-lifnr        = zintcomp_s_masraf_header-lifnr.
        mo_object->gs_kayit-mwskz        = zintcomp_s_masraf_header-mwskz.
        mo_object->gs_kayit-bukrs        = zintcomp_s_masraf_header-bukrs.

        mo_object->gs_kayit-budat        = zintcomp_s_masraf_header-budat.
        mo_object->gs_kayit-bldat        = zintcomp_s_masraf_header-bldat.
        mo_object->gs_kayit-mwskz        = zintcomp_s_masraf_header-mwskz.
        mo_object->gs_kayit-xblnr        = zintcomp_s_masraf_header-xblnr.
        mo_object->gs_kayit-zterm        = zintcomp_s_masraf_header-zterm.

        ls_return =  mo_object->zif_intercompany~post_mk( ).
        cl_rmsl_message=>display( ls_return-t_bapiret ).


      WHEN mc_masraf_sim.

        mo_object->gs_kayit-commit        = abap_false.
        mo_object->gs_kayit-function_name = zif_intercompany=>c_check_bapi.
        mo_object->gs_kayit-ref_belge     = COND #( WHEN  <fs_out>-smm_belge IS NOT INITIAL THEN <fs_out>-smm_belge
                                                   ELSE <fs_out>-yol_mal_belge ) .
        mo_object->gs_kayit-ara_hesap     = COND #( WHEN <fs_out>-smm_belge IS INITIAL THEN 'X' ).
        mo_object->gs_kayit-masraf_tip    = zintcomp_s_masraf_header-masraf_tip.
        mo_object->gs_kayit-dagitim_tipi  =  zintcomp_s_masraf_header-dagitim_tipi.
        mo_object->gs_kayit-masraf_tutar  = zintcomp_s_masraf_header-wrbtr.
        mo_object->gs_kayit-t_teslimat    = mt_pop_tesl.
        mo_object->gs_kayit-lifnr         = zintcomp_s_masraf_header-lifnr.
        mo_object->gs_kayit-mwskz         = zintcomp_s_masraf_header-mwskz.
        mo_object->gs_kayit-bukrs         = zintcomp_s_masraf_header-bukrs.

        mo_object->gs_kayit-budat        = zintcomp_s_masraf_header-budat.
        mo_object->gs_kayit-bldat        = zintcomp_s_masraf_header-bldat.
        mo_object->gs_kayit-mwskz        = zintcomp_s_masraf_header-mwskz.
        mo_object->gs_kayit-xblnr        = zintcomp_s_masraf_header-xblnr.
        mo_object->gs_kayit-zterm        = zintcomp_s_masraf_header-zterm.


        ls_return =  mo_object->zif_intercompany~post_mk( ).

        PERFORM display_simulation USING ls_return 'X'.


      WHEN mc_masraf.

        MOVE-CORRESPONDING lt_teslimat TO mt_pop_tesl .
        MOVE-CORRESPONDING <fs_out> TO zintcomp_s_masraf_header .
        zintcomp_s_masraf_header-bukrs = <fs_out>-bukrs.
        me->set_popup( ).

      WHEN mc_oto_kayit.

        mo_object->gs_kayit-commit = abap_true.
        ls_return = mo_object->zif_intercompany~otomatik_kayit( ).
        cl_rmsl_message=>display( ls_return-t_bapiret ).

      WHEN mc_masraf_tk.

        mo_object->gs_masraf_kaydi-tt_masraf_kaydi[] = mt_masraf[].
        ls_return = mo_object->zif_intercompany~reverse_mk( ) .
        cl_rmsl_message=>display( ls_return-t_bapiret ).
        me->set_masraf_detay( ).

      WHEN mc_ym_tk.

        MOVE-CORRESPONDING <fs_out> TO mo_object->gs_header.
        ls_return = mo_object->zif_intercompany~reverse_ym( ).
        cl_rmsl_message=>display( ls_return-t_bapiret ).
        MOVE-CORRESPONDING mo_object->gs_header TO <fs_out> .

      WHEN mc_smm_tk.

        MOVE-CORRESPONDING <fs_out> TO mo_object->gs_header.
        ls_return = mo_object->zif_intercompany~reverse_smm( ).
        cl_rmsl_message=>display( ls_return-t_bapiret ).
        MOVE-CORRESPONDING mo_object->gs_header TO <fs_out> .

      WHEN mc_tes_kapat.

        mo_object->gs_kayit-commit        = abap_true.
        mo_object->gs_kayit-ref_belge     = <fs_out>-smm_belge.
        MOVE-CORRESPONDING <fs_out> TO mo_object->gs_header.
        ls_return = mo_object->zif_intercompany~tes_kapat( ).
        cl_rmsl_message=>display( ls_return-t_bapiret ).
        MOVE-CORRESPONDING mo_object->gs_header TO <fs_out> .

    ENDCASE.

    mt_akis = mo_object->zif_intercompany~get_log_list( ).

    me->set_masraf_detay( ).


  ENDMETHOD.

  METHOD set_popup.
    DATA lt_vall TYPE TABLE OF dd07v .
    DATA: it_listbox TYPE vrm_values,
          wa_listbox LIKE LINE OF it_listbox.

    READ TABLE mt_pop_tesl INTO DATA(ls_tesl) WITH KEY secim = 'X'.

    SELECT masraf_tip AS key, masraf_tip_tanim AS text
         FROM zintcomp_m_004
    INTO TABLE @it_listbox.

    CALL FUNCTION 'VRM_SET_VALUES'
      EXPORTING
        id     = 'ZINTCOMP_S_MASRAF_HEADER-MASRAF_TIP'
        values = it_listbox.

    READ TABLE mo_object->gs_genel-table_03 INTO DATA(ls_03) WITH KEY kayit_tur = 'MK'.

    zintcomp_s_masraf_header-waers = ls_tesl-waerk.
    zintcomp_s_masraf_header-gjahr = sy-datum.
    zintcomp_s_masraf_header-budat = sy-datum.
    zintcomp_s_masraf_header-bldat = sy-datum.
    zintcomp_s_masraf_header-blart = ls_03-blart.
    zintcomp_s_masraf_header-bktxt = ls_03-bktxt.
*zintcomp_s_masraf_header-dagitim_tipi =
*mo_object->gs_genel-t_01-dagitim_tipi.

    CALL FUNCTION 'DD_DOMVALUES_GET'
      EXPORTING
        domname        = 'ZINTCOMP_DM_DAGITIM_TIPI'
        text           = 'X'
        langu          = sy-langu
        bypass_buffer  = 'X'
      TABLES
        dd07v_tab      = lt_vall
      EXCEPTIONS
        wrong_textflag = 1
        OTHERS         = 2.

    READ TABLE lt_vall INTO DATA(ls_vall) WITH KEY domvalue_l =
    zintcomp_s_masraf_header-dagitim_tipi.
    zintcomp_s_masraf_header-dagitim_tipi_tanim = ls_vall-ddtext.

    DATA: lv_w  TYPE i VALUE 150,   "genişlik (kolon)
          lv_h  TYPE i VALUE 35,   "yükseklik (satır)
          lv_x  TYPE i,
          lv_y  TYPE i,
          lv_x2 TYPE i,
          lv_y2 TYPE i.

    "sy-scols: mevcut pencerenin kolon sayısı, sy-srows: satır sayısı
    lv_x  = ( sy-scols - lv_w ) / 2.
    lv_y  = ( sy-srows - lv_h ) / 2.
    lv_x2 = lv_x + lv_w.
    lv_y2 = lv_y + lv_h.

    CALL SCREEN 0200 STARTING AT lv_x lv_y
                     ENDING AT   lv_x2 lv_y2..

    mt_akis = mo_object->zif_intercompany~get_log_list( ).


  ENDMETHOD.

  METHOD post_masraf.

  ENDMETHOD.

  METHOD display_simulation.


  ENDMETHOD.

  METHOD exp_col.

    DATA(tmp_masraf) = mt_masraf_tmp.
    DELETE tmp_masraf WHERE note NE is_out-sira.

    CASE is_out-exp_col.
      WHEN zif_intercompany=>c_expand.
        is_out-exp_col  = zif_intercompany=>c_collapse.
        APPEND LINES OF tmp_masraf TO mt_masraf.
        READ TABLE mt_masraf ASSIGNING FIELD-SYMBOL(<fs_masraf_tmp>) WITH KEY sira = is_out-sira.
*        <fs_masraf_tmp>-exp_col  = zif_intercompany=>c_collapse.
      WHEN zif_intercompany=>c_collapse.
        is_out-exp_col  = zif_intercompany=>c_expand.
        DELETE mt_masraf WHERE note EQ is_out-sira.
    ENDCASE.

    SORT mt_masraf BY sira.

  ENDMETHOD.

  METHOD set_masraf_detay.

    mo_object->zif_intercompany~get_mk(
      IMPORTING
        et_table = mt_masraf_tmp
    ).

    mt_masraf[] = mt_masraf_tmp[].
    DELETE mt_masraf WHERE note <> ''.


  ENDMETHOD.

ENDCLASS.


CLASS lcl_event_handler IMPLEMENTATION.
  METHOD on_double_click.
    DATA : lv_name TYPE string.
    FIELD-SYMBOLS : <fs_val> TYPE any.

    IF column = 'BELNR' OR column = 'REF_BELGE'.
      READ TABLE go_ctrl->mt_masraf_pop INTO DATA(ls_masraf) INDEX row.
      UNASSIGN <fs_val>.
      lv_name = |LS_MASRAF-{ column }|.
      ASSIGN (lv_name) TO <fs_val>.
      CHECK <fs_val> IS ASSIGNED.
      SET PARAMETER ID 'BLN' FIELD <fs_val>.
      SET PARAMETER ID 'BUK' FIELD ls_masraf-bukrs.
      SET PARAMETER ID 'GJR' FIELD ls_masraf-gjahr.
      CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
