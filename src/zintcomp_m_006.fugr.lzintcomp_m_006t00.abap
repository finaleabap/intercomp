*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZINTCOMP_M_006..................................*
DATA:  BEGIN OF STATUS_ZINTCOMP_M_006                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZINTCOMP_M_006                .
CONTROLS: TCTRL_ZINTCOMP_M_006
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZINTCOMP_M_006                .
TABLES: ZINTCOMP_M_006                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
