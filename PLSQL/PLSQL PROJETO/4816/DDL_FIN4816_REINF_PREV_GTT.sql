

CREATE TABLE msafi.fin4816_reinf_prev_gtt
(
  COD_EMPRESA              VARCHAR2(3 BYTE)     NOT NULL,
  COD_ESTAB                VARCHAR2(6 BYTE)     NOT NULL,
  DATA_EMISSAO             DATE                 NOT NULL,
  DATA_FISCAL              DATE                 NOT NULL,
  IDENT_FIS_JUR            NUMBER(12)           NOT NULL,
  IDENT_DOCTO              NUMBER(12)           NOT NULL,
  NUM_DOCFIS               VARCHAR2(12 BYTE)    NOT NULL,
  SERIE_DOCFIS             VARCHAR2(3 BYTE)     NOT NULL,
  SUB_SERIE_DOCFIS         VARCHAR2(2 BYTE)     NOT NULL,
  NUM_ITEM                 NUMBER(5)            NOT NULL,
  --  
  COD_USUARIO              VARCHAR2(40 BYTE)            ,
  IDENT_TIPO_SERV_ESOCIAL  NUMBER(12),
  COD_CLASS_DOC_FIS        CHAR(1 BYTE),
  VLR_TOT_NOTA             NUMBER(17,2),
  VLR_CONTAB_COMPL         NUMBER(17,2),
  VLR_BASE_INSS            NUMBER(17,2),
  VLR_ALIQ_INSS            NUMBER(7,4),
  VLR_INSS_RETIDO          NUMBER(17,2),
  IND_TIPO_PROC            CHAR(1 BYTE),
  NUM_PROC_JUR             VARCHAR2(21 BYTE),
  VLR_SERVICO              NUMBER(17,2),
  IND_TP_PROC_ADJ_ADIC     CHAR(1 BYTE),
  NUM_PROC_ADJ_ADIC        VARCHAR2(21 BYTE),
  IDENT_SERVICO            NUMBER(12),
  IDENT_PRODUTO            NUMBER(12),
  COD_PARAM                NUMBER(3)
  );