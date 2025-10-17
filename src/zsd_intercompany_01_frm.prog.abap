*&---------------------------------------------------------------------*
*& Include          ZSD_INTERCOMPANY_01_FRM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form DISPLAY_SIMULATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_ACDOC
*&      --> P_
*&---------------------------------------------------------------------*
FORM display_simulation
      USING is_acdoc TYPE zif_intercompany=>t_return
                          iv_sim.

  DATA : lt_fcat     TYPE slis_t_fieldcat_alv,
         lt_fcat_all TYPE slis_t_fieldcat_alv,
         ls_layo     TYPE slis_layout_alv,
         ls_vari     TYPE disvariant.


  FIELD-SYMBOLS : <fs_fcat> TYPE slis_fieldcat_alv.
  DATA : ls_fcat TYPE slis_fieldcat_alv.
  DATA : ls_keyinfo  TYPE slis_keyinfo_alv.
  DATA : lt_sort TYPE slis_t_sortinfo_alv.
  DATA : ls_sort TYPE slis_sortinfo_alv.
  DATA : lv_belnr TYPE belnr_d.

  DATA: lv_w  TYPE i VALUE 200,   "genişlik (kolon)
        lv_h  TYPE i VALUE 30,   "yükseklik (satır)
        lv_x  TYPE i,
        lv_y  TYPE i,
        lv_x2 TYPE i,
        lv_y2 TYPE i.

  "sy-scols: mevcut pencerenin kolon sayısı, sy-srows: satır sayısı
  lv_x  = ( sy-scols - lv_w ) / 2.
  lv_y  = ( sy-srows - lv_h ) / 2.
  lv_x2 = lv_x + lv_w.
  lv_y2 = lv_y + lv_h.

  CHECK iv_sim EQ abap_true.

  CLEAR : gt_head[],gt_items[].

  lv_belnr = |${ 1 }|.
  LOOP AT is_acdoc-t_acdoc-accountgl INTO DATA(ls_accountgl).
    READ TABLE is_acdoc-t_acdoc-currencyamount INTO DATA(ls_currencyamount)
    WITH KEY itemno_acc = ls_accountgl-itemno_acc.
    MOVE-CORRESPONDING ls_accountgl TO gt_items.
    MOVE-CORRESPONDING ls_currencyamount TO gt_items.
    gt_items-belnr = lv_belnr.
    APPEND gt_items TO gt_items.
  ENDLOOP.

  LOOP AT is_acdoc-t_acdoc-accounttax
    INTO DATA(ls_accounttax).

    READ TABLE is_acdoc-t_acdoc-currencyamount INTO ls_currencyamount
    WITH KEY  itemno_acc = ls_accounttax-itemno_acc.
    MOVE-CORRESPONDING ls_accounttax TO gt_items.
    MOVE-CORRESPONDING ls_currencyamount TO gt_items.
    gt_items-belnr = lv_belnr.
    APPEND gt_items TO gt_items.
  ENDLOOP.

  LOOP AT is_acdoc-t_acdoc-accountpayable
    INTO DATA(ls_accountpayable).
    READ TABLE is_acdoc-t_acdoc-currencyamount INTO ls_currencyamount
     WITH KEY  itemno_acc = ls_accountpayable-itemno_acc.
    MOVE-CORRESPONDING ls_accountpayable TO gt_items.
    MOVE-CORRESPONDING ls_currencyamount TO gt_items.
    gt_items-belnr = lv_belnr.
    APPEND gt_items TO gt_items.
  ENDLOOP.

  LOOP AT is_acdoc-t_acdoc-accountreceivable
    INTO DATA(ls_accountreceivable).
    READ TABLE is_acdoc-t_acdoc-currencyamount INTO ls_currencyamount
    WITH KEY  itemno_acc = ls_accountreceivable-itemno_acc.
    MOVE-CORRESPONDING ls_accountreceivable TO gt_items.
    MOVE-CORRESPONDING ls_currencyamount TO gt_items.
    gt_items-belnr = lv_belnr.
    APPEND gt_items TO gt_items.
  ENDLOOP.


  MOVE-CORRESPONDING is_acdoc-t_acdoc-documentheader TO gt_head.
  gt_head-belnr = lv_belnr.
  gt_head-icon = COND #( WHEN is_acdoc-return_type = 'S' THEN zif_intercompany=>c_kayittmm
                          ELSE zif_intercompany=>c_kayithat ).
  gt_head-durum = VALUE #( is_acdoc-t_bapiret[ 1 ]-message OPTIONAL ).
  APPEND gt_head TO gt_head.

  ls_layo-zebra = 'X'.
*  ls_layo-colwidth_optimize = 'X'.

  ls_layo-expand_fieldname = 'EXPAND'.
  ls_layo-expand_all       = 'X'.
  ls_vari-handle = 'D2'.
  ls_vari-username = sy-uname.
  ls_vari-report = sy-repid.


  REFRESH lt_fcat.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_internal_tabname     = 'GT_HEAD'
      i_inclname             = sy-repid
      i_bypassing_buffer     = 'X'
    CHANGING
      ct_fieldcat            = lt_fcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
  LOOP AT lt_fcat INTO ls_fcat.
    CLEAR ls_fcat-key.
    CASE ls_fcat-fieldname.
      WHEN 'EXPAND'.
        ls_fcat-tech = 'X'.
      WHEN OTHERS.
    ENDCASE.
    MODIFY lt_fcat FROM ls_fcat.
  ENDLOOP.
  APPEND LINES OF lt_fcat TO lt_fcat_all.

  REFRESH lt_fcat.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_internal_tabname     = 'GT_ITEMS'
      i_inclname             = sy-repid
      i_bypassing_buffer     = 'X'
    CHANGING
      ct_fieldcat            = lt_fcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  LOOP AT lt_fcat INTO ls_fcat.
    CLEAR ls_fcat-key.
    CASE ls_fcat-fieldname.
      WHEN 'LGICN'.
        ls_fcat-hotspot = 'X'.
      WHEN 'BELNR' OR 'BUKRS' OR 'LIFNR' OR 'XBLNR'.
        ls_fcat-tech = 'X'.
      WHEN OTHERS.
    ENDCASE.
    MODIFY lt_fcat FROM ls_fcat.
  ENDLOOP.
  APPEND LINES OF lt_fcat TO lt_fcat_all.

  ls_keyinfo-header01 = 'BELNR'.
  ls_keyinfo-item01   = 'BELNR'.


  CLEAR ls_sort.
  ls_sort-tabname = 'GT_HEAD'.
  ls_sort-fieldname = 'BELNR'.
  ls_sort-up = 'X'.
  ls_sort-spos = 1.
  APPEND ls_sort TO lt_sort.


  CALL FUNCTION 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
    EXPORTING
      i_callback_program      = sy-repid
      i_callback_user_command = 'USER_COMMAND_DETAIL'
      is_layout               = ls_layo
      it_fieldcat             = lt_fcat_all
      i_default               = 'X'
      i_save                  = 'U'
      is_variant              = ls_vari
      i_tabname_header        = 'GT_HEAD'
      i_tabname_item          = 'GT_ITEMS'
      it_sort                 = lt_sort
      is_keyinfo              = ls_keyinfo
      i_screen_start_column   = lv_x
      i_screen_start_line     = lv_y
      i_screen_end_column     = lv_x2
      i_screen_end_line       = lv_y2
    TABLES
      t_outtab_header         = gt_head
      t_outtab_item           = gt_items
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.
ENDFORM.
