*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZINTCOMP_MV_006.................................*
TABLES: ZINTCOMP_MV_006, *ZINTCOMP_MV_006. "view work areas
CONTROLS: TCTRL_ZINTCOMP_MV_006
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_ZINTCOMP_MV_006. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZINTCOMP_MV_006.
* Table for entries selected to show on screen
DATA: BEGIN OF ZINTCOMP_MV_006_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZINTCOMP_MV_006.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZINTCOMP_MV_006_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZINTCOMP_MV_006_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZINTCOMP_MV_006.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZINTCOMP_MV_006_TOTAL.

*.........table declarations:.................................*
TABLES: ZINTCOMP_M_006                 .
