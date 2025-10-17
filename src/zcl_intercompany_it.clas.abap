class ZCL_INTERCOMPANY_IT definition
  public
  inheriting from ZCL_INTERCOMPANY_US
  final
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !IV_BUKRS type BUKRS
      !IV_BUKRSZ type BUKRS_SENDER .
protected section.
private section.
ENDCLASS.



CLASS ZCL_INTERCOMPANY_IT IMPLEMENTATION.


  METHOD constructor.

    super->constructor(
      EXPORTING
        iv_bukrs  = iv_bukrs     " Şirket kodu
        iv_bukrsz = iv_bukrsz    " Gönderen sistemde şirket kodu
    ).

    SELECT SINGLE * FROM zintcomp_m_001
         INTO gs_genel-t_01
        WHERE bukrs  = iv_bukrs
          AND bukrsz = iv_bukrsz.

    SELECT * FROM zintcomp_m_002
       INTO TABLE gs_genel-table_02
            WHERE bukrs = iv_bukrs
              AND bukrsz = gs_genel-t_01-bukrsz.

    SELECT * FROM zintcomp_m_003
       INTO TABLE gs_genel-table_03
            WHERE bukrs = iv_bukrs
              AND bukrsz = gs_genel-t_01-bukrsz.

*    gs_acdocument-function_name = 'BAPI_ACC_DOCUMENT_POST'.

  ENDMETHOD.
ENDCLASS.
