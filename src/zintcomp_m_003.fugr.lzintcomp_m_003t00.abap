*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZINTCOMP_M_003..................................*
DATA:  BEGIN OF STATUS_ZINTCOMP_M_003                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZINTCOMP_M_003                .
CONTROLS: TCTRL_ZINTCOMP_M_003
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZINTCOMP_M_003                .
TABLES: ZINTCOMP_M_003                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
