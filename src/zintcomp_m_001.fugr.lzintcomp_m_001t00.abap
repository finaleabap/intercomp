*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZINTCOMP_M_001..................................*
DATA:  BEGIN OF STATUS_ZINTCOMP_M_001                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZINTCOMP_M_001                .
CONTROLS: TCTRL_ZINTCOMP_M_001
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZINTCOMP_M_001                .
TABLES: ZINTCOMP_M_001                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
