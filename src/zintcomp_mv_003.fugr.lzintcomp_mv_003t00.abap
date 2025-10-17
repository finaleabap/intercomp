*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZINTCOMP_MV_003.................................*
TABLES: ZINTCOMP_MV_003, *ZINTCOMP_MV_003. "view work areas
CONTROLS: TCTRL_ZINTCOMP_MV_003
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_ZINTCOMP_MV_003. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZINTCOMP_MV_003.
* Table for entries selected to show on screen
DATA: BEGIN OF ZINTCOMP_MV_003_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZINTCOMP_MV_003.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZINTCOMP_MV_003_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZINTCOMP_MV_003_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZINTCOMP_MV_003.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZINTCOMP_MV_003_TOTAL.

*.........table declarations:.................................*
TABLES: ZINTCOMP_M_003                 .
