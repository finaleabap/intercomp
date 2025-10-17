interface ZIF_INTERCOMPANY
  public .


  types:
    BEGIN OF t_bapiacc,
      documentheader    TYPE bapiache09,
      accountgl         TYPE STANDARD TABLE OF bapiacgl09 WITH DEFAULT KEY,
      accountreceivable TYPE STANDARD TABLE OF bapiacar09 WITH DEFAULT KEY,
      accountpayable    TYPE STANDARD TABLE OF bapiacap09 WITH DEFAULT KEY,
      accounttax        TYPE STANDARD TABLE OF bapiactx09 WITH DEFAULT KEY,
      currencyamount    TYPE STANDARD TABLE OF bapiaccr09 WITH DEFAULT KEY,
      criteria          TYPE STANDARD TABLE OF bapiackec9 WITH DEFAULT KEY,
      t_bapiret         TYPE STANDARD TABLE OF bapiret2  WITH DEFAULT KEY,
      function_name     TYPE char100,
      commit            TYPE char1,
      return_type       TYPE char1,
      obj_key           TYPE  bapiache09-obj_key,
    END OF t_bapiacc .
  types:
    tt_log TYPE STANDARD TABLE OF zintcomp_s_akis WITH DEFAULT KEY .
  types:
    BEGIN OF t_return .
  TYPES : t_bapiret   TYPE STANDARD TABLE OF bapiret2 WITH DEFAULT KEY.
  TYPES : return_type TYPE char1,
          obj_key     TYPE bapiache09-obj_key.
  TYPES : t_acdoc     TYPE t_bapiacc.
  TYPES: END OF t_return .

  constants C_FATYOK type ICON_D value '@1A@' ##NO_TEXT.
  constants C_KAYITBEK type ICON_D value '@09@' ##NO_TEXT.
  constants C_KAYITHAT type ICON_D value '@0A@' ##NO_TEXT.
  constants C_KAYITTMM type ICON_D value '@08@' ##NO_TEXT.
  constants C_SECIM type ICON_D value '@9T@' ##NO_TEXT.
  constants C_CHECK_BAPI type CHAR50 value 'BAPI_ACC_DOCUMENT_CHECK' ##NO_TEXT.
  constants C_BELGEGECMIS type ICON_D value '@96@' ##NO_TEXT.
  constants C_EXPAND type ICON_D value '@3S@' ##NO_TEXT.
  constants C_COLLAPSE type ICON_D value '@3T@' ##NO_TEXT.

  class-methods CHECK_STATUS
    importing
      !IV_VBELN_VL type VBELN_VL
    returning
      value(EV_ERR) type CHAR1 .
  methods GET_DATA
    exporting
      !ET_TABLE type TABLE .
  methods POST_YM
    returning
      value(RT_MESSAGE) type T_RETURN .
  methods REVERSE_YM
    returning
      value(RT_MESSAGE) type T_RETURN .
  methods POST_SMM
    returning
      value(RT_MESSAGE) type T_RETURN .
  methods REVERSE_SMM
    returning
      value(RT_MESSAGE) type T_RETURN .
  methods POST_MK
    returning
      value(RT_MESSAGE) type T_RETURN .
  methods REVERSE_MK
    returning
      value(RT_MESSAGE) type T_RETURN .
  methods REVERSE
    returning
      value(RT_MESSAGE) type T_RETURN .
  methods GET_TESLIMAT
    exporting
      !ET_TABLE type TABLE .
  methods CHECK_AND_MAP
    returning
      value(RT_MESSAGE) type T_RETURN .
  methods SET_LOG
    returning
      value(RV_OK) type CHAR1 .
  methods GET_LOG
    returning
      value(RS_LOG) type ZINTCOMP_T_003 .
  methods GET_LOG_LIST
    returning
      value(RT_LOG) type TT_LOG .
  methods GET_MK
    exporting
      value(ET_TABLE) type TABLE .
  methods TES_KAPAT
    returning
      value(RT_MESSAGE) type T_RETURN .
  methods OTOMATIK_KAYIT
    returning
      value(RT_MESSAGE) type T_RETURN .
endinterface.
