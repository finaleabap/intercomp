*&---------------------------------------------------------------------*
*& Include          ZSD_INTERCOMPANY_01_TOP
*&---------------------------------------------------------------------*

TABLES : lips, zintcomp_s_masraf_header.
CLASS gcl_class DEFINITION DEFERRED.

DATA: go_ctrl     TYPE REF TO gcl_class,
      go_ctrl_log TYPE REF TO gcl_class.

DATA : BEGIN OF gt_head OCCURS 0.
    INCLUDE STRUCTURE zintcomp_s_simulasyon_header.
DATA: expand ,
      message  LIKE bapiret2-message,
      messages TYPE bapiret2_tab,
      END OF gt_head.
DATA : BEGIN OF gt_items OCCURS 0.
    INCLUDE STRUCTURE zintcomp_s_simulasyon_item.
DATA: END OF gt_items.

*&SPWIZARD: FUNCTION CODES FOR TABSTRIP 'TAB_CONTROL'
CONSTANTS: BEGIN OF c_tab_control,
             tab1 LIKE sy-ucomm VALUE 'TAB_CONT_TES',
             tab2 LIKE sy-ucomm VALUE 'TAB_CONT_MAS',
             tab3 LIKE sy-ucomm VALUE 'TAB_CONT_AKS',
           END OF c_tab_control.
*&SPWIZARD: DATA FOR TABSTRIP 'TAB_CONTROL'
CONTROLS:  tab_control TYPE TABSTRIP.
DATA: BEGIN OF g_tab_control,
        subscreen   LIKE sy-dynnr,
        prog        LIKE sy-repid VALUE 'ZSD_INTERCOMPANY_01',
        pressed_tab LIKE sy-ucomm VALUE c_tab_control-tab1,
      END OF g_tab_control.
DATA:      ok_code LIKE sy-ucomm.


SELECTION-SCREEN : BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-001.
PARAMETERS : p_bukrs TYPE bukrsz DEFAULT '8200'.
PARAMETERS : p_bukrsz  TYPE BUKRS_SENDER DEFAULT '1000'.
SELECT-OPTIONS : s_vbelnv FOR lips-vbeln.
SELECT-OPTIONS : s_vbeln  FOR lips-kdauf.
*SELECT-OPTIONS : s_kunnr FOR bseg-kunnr.
SELECTION-SCREEN : END OF BLOCK bl1.


*at selection-screen output.
*
*  loop at screen.
*
*
*    modify screen.
*  endloop.
