Prompt Table FIN4816_REPORT_FISCAL_GTT;
--
-- FIN4816_REPORT_FISCAL_GTT  (Table) 
--  dpsp_tb_fin4816_reinf_prev_gtt

CREATE GLOBAL TEMPORARY TABLE MSAFI.TB_FIN4816_REPORT_FISCAL_GTT
(
  COD_EMPRESA          VARCHAR2(3 BYTE)         NOT NULL,
  COD_ESTAB            VARCHAR2(6 BYTE)         NOT NULL,
  DATA_FISCAL          DATE                     NOT NULL,
  MOVTO_E_S            CHAR(1 BYTE)             NOT NULL,
  NORM_DEV             CHAR(1 BYTE)             NOT NULL,
  IDENT_DOCTO          NUMBER(12)               NOT NULL,
  IDENT_FIS_JUR        NUMBER(12)               NOT NULL,
  NUM_DOCFIS           VARCHAR2(12 BYTE)        NOT NULL,
  SERIE_DOCFIS         VARCHAR2(3 BYTE)         NOT NULL,
  SUB_SERIE_DOCFIS     VARCHAR2(2 BYTE)         NOT NULL,
  IDENT_SERVICO        NUMBER(12)               NOT NULL,
  NUM_ITEM             NUMBER(5)                NOT NULL,
  PERIODO_EMISSAO      VARCHAR2(14 BYTE),
  CGC                  VARCHAR2(14 BYTE),
  NUM_DOCTO            VARCHAR2(12 BYTE),
  TIPO_DOCTO           VARCHAR2(5 BYTE),
  DATA_EMISSAO         DATE,
  CGC_FORNECEDOR       VARCHAR2(50 BYTE),
  UF                   VARCHAR2(5 BYTE),
  VALOR_TOTAL          NUMBER(17,2),
  VLR_BASE_INSS        NUMBER(17,2),
  VLR_INSS             NUMBER(17,2),
  CODIGO_FISJUR        VARCHAR2(14 BYTE),
  RAZAO_SOCIAL         VARCHAR2(120 BYTE),
  MUNICIPIO_PRESTADOR  VARCHAR2(50 BYTE),
  COD_SERVICO          VARCHAR2(14 BYTE),
  COD_CEI              VARCHAR2(15 BYTE),
  EQUALIZACAO          VARCHAR2(1 BYTE)
)
ON COMMIT PRESERVE ROWS
NOCACHE;




