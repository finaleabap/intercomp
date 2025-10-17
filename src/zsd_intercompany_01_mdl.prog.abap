*&---------------------------------------------------------------------*
*& Include          ZSD_INTERCOMPANY_01_MDL
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'PF_STATUS_0100'.
  IF sy-langu eq 'T'.
    SET TITLEBAR 'TITLEBAR_0100' WITH go_ctrl->mv_teslimat.
  ELSE.
    SET TITLEBAR 'TITLEBAR_0101' WITH go_ctrl->mv_teslimat.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE sy-ucomm.
    WHEN go_ctrl->mc_back OR go_ctrl->mc_leave OR go_ctrl->mc_exit.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module DISPLAY_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE display_0100 OUTPUT.

  go_ctrl->display_alv(
    EXPORTING
      iv_table_name  = 'MT_OUT'
      it_data        = go_ctrl->mt_out
      iv_structure   = go_ctrl->mc_structure
      iv_container   = go_ctrl->mc_container
      iv_variant     = '/HEADER'
      iv_top_page    = abap_true
      iv_data_change = abap_true
      iv_toolbar     = abap_true
    CHANGING
      co_grid        = go_ctrl->mo_grid
      co_cutom       = go_ctrl->mo_cutom
    ).

ENDMODULE.


*&SPWIZARD: OUTPUT MODULE FOR TS 'TAB_CONTROL'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: SETS ACTIVE TAB
MODULE tab_control_active_tab_set OUTPUT.
  tab_control-activetab = g_tab_control-pressed_tab.
  CASE g_tab_control-pressed_tab.
    WHEN c_tab_control-tab1.
      g_tab_control-subscreen = '0101'.
    WHEN c_tab_control-tab2.
      g_tab_control-subscreen = '0102'.
    WHEN c_tab_control-tab3.
      g_tab_control-subscreen = '0103'.
    WHEN OTHERS.
*&SPWIZARD:      DO NOTHING
  ENDCASE.
ENDMODULE.

*&SPWIZARD: INPUT MODULE FOR TS 'TAB_CONTROL'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: GETS ACTIVE TAB
MODULE tab_control_active_tab_get INPUT.
  ok_code = sy-ucomm.
  CASE ok_code.
    WHEN c_tab_control-tab1.
      g_tab_control-pressed_tab = c_tab_control-tab1.
    WHEN c_tab_control-tab2.
      g_tab_control-pressed_tab = c_tab_control-tab2.
    WHEN c_tab_control-tab3.
      g_tab_control-pressed_tab = c_tab_control-tab3.
    WHEN OTHERS.
*&SPWIZARD:      DO NOTHING
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0110 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0101 OUTPUT.

  go_ctrl->display_alv(
    EXPORTING
      iv_table_name  = 'MT_OUT_TESL'
      it_data        = go_ctrl->mt_out_tesl
      iv_structure   = go_ctrl->mc_strc_tesl
      iv_container   = go_ctrl->mc_cont_tesl
      iv_variant     = '/TESLIMAT'
      iv_top_page    = abap_true
      iv_data_change = abap_true
    CHANGING
      co_grid        = go_ctrl->mo_grid_tesl
      co_cutom       = go_ctrl->mo_cutom_tesl
    ).

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0110  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0101 INPUT.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0102 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0102 OUTPUT.

  go_ctrl->display_alv(
    EXPORTING
      iv_table_name  = 'MT_MASRAF'
      it_data        = go_ctrl->mt_masraf
      iv_structure   = go_ctrl->mc_strc_masraf
      iv_container   = go_ctrl->mc_cont_masraf
      iv_variant     = '/MASRAF'
      iv_top_page    = abap_true
      iv_data_change = abap_true
      iv_stylefname  = 'CELLTAB'
      iv_toolbar     = 'M'
    CHANGING
      co_grid        = go_ctrl->mo_grid_masraf
      co_cutom       = go_ctrl->mo_cutom_masraf
      ).

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0102  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0102 INPUT.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0103 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0103 OUTPUT.


  go_ctrl->mt_akis =
  go_ctrl->mo_object->zif_intercompany~get_log_list( ).

  go_ctrl->display_alv(
    EXPORTING
      iv_table_name  = 'MT_AKIS'
      it_data        = go_ctrl->mt_akis
      iv_structure   = go_ctrl->mc_strc_akis
      iv_container   = go_ctrl->mc_cont_akis
      iv_variant     = '/AKIS'
      iv_top_page    = abap_true
      iv_data_change = abap_true
    CHANGING
      co_grid        = go_ctrl->mo_grid_akis
      co_cutom       = go_ctrl->mo_cutom_akis
      ).

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0103  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0103 INPUT.

ENDMODULE.

*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
  SET PF-STATUS 'PF_0200'.
* SET TITLEBAR 'xxx'.
  SELECT SINGLE masraf_tip_tanim dagitim_tipi FROM zintcomp_m_004
                                 INTO (
   zintcomp_s_masraf_header-masraf_tip_tanim,
                                 zintcomp_s_masraf_header-dagitim_tipi )
                                WHERE masraf_tip =
                                zintcomp_s_masraf_header-masraf_tip.

  go_ctrl->display_alv(
    EXPORTING
      iv_table_name  = 'MT_POP_TESL'
      it_data        = go_ctrl->mt_pop_tesl
      iv_structure   = go_ctrl->mc_strc_tesl_pop
      iv_container   = go_ctrl->mc_cont_popup
      iv_variant     = '/TESL_POP'
      iv_top_page    = abap_true
      iv_data_change = abap_true
      iv_stylefname  = 'CELLTAB'
    CHANGING
      co_grid        = go_ctrl->mo_grid_tesl_pop
      co_cutom       = go_ctrl->mo_cutom_tesl_pop
      ).

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.

  CASE sy-ucomm.
    WHEN go_ctrl->mc_back OR go_ctrl->mc_leave OR go_ctrl->mc_exit.
      LEAVE TO SCREEN 0.
    WHEN 'KAYDET'.
      go_ctrl->set_action( iv_action = CONV #( go_ctrl->mc_masraf_kayit ) ).
      CLEAR : zintcomp_s_masraf_header.
      LEAVE TO SCREEN 0.
    WHEN 'SIMULE'.
      go_ctrl->set_action( iv_action = CONV #( go_ctrl->mc_masraf_sim )
      ).
  ENDCASE.

ENDMODULE.
