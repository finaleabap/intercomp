*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZINTCOMP_M_004..................................*
DATA:  BEGIN OF STATUS_ZINTCOMP_M_004                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZINTCOMP_M_004                .
CONTROLS: TCTRL_ZINTCOMP_M_004
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZINTCOMP_M_004                .
TABLES: ZINTCOMP_M_004                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
