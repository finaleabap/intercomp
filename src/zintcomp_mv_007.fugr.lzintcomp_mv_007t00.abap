*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZINTCOMP_MV_007.................................*
TABLES: ZINTCOMP_MV_007, *ZINTCOMP_MV_007. "view work areas
CONTROLS: TCTRL_ZINTCOMP_MV_007
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_ZINTCOMP_MV_007. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZINTCOMP_MV_007.
* Table for entries selected to show on screen
DATA: BEGIN OF ZINTCOMP_MV_007_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZINTCOMP_MV_007.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZINTCOMP_MV_007_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZINTCOMP_MV_007_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZINTCOMP_MV_007.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZINTCOMP_MV_007_TOTAL.

*.........table declarations:.................................*
TABLES: ZINTCOMP_M_007                 .
