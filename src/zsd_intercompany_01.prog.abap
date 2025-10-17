*&--------------------------------------------------------------------*
*& Report ZSD_INTERCOMPANY_01
*---------------------------------------------------------------------*
* Title     : Intercompany Kokpit
* Object ID :
*---------------------------------------------------------------------*
* Programmer: Ömer Faruk Uray #OFU#
*---------------------------------------------------------------------*
* Description:
*---------------------------------------------------------------------*
***********************************************************************
*             H I S T O R Y   O F   R E V I S I O N S
***********************************************************************
*       Date          Programmer     Consultant         Description
*  ---------------  ----------------- -------------    ---------------*
*  24.09.2025        OFU             Ömer Faruk URAY   New Development
*
*--------------------------------------------------------------------*
REPORT zsd_intercompany_01.

INCLUDE zsd_intercompany_01_top.
INCLUDE zsd_intercompany_01_cls.
INCLUDE zsd_intercompany_01_mdl.
INCLUDE zsd_intercompany_01_frm.


INITIALIZATION.
  go_ctrl = gcl_class=>get_instance( ).
  go_ctrl->initialization( ).

START-OF-SELECTION .
  go_ctrl->run( ).
