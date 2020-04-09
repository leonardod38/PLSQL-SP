Prompt Table X07_DOCTO_FISCAL_LOG;
--
-- X07_DOCTO_FISCAL_LOG  (Table) 
--
CREATE TABLE MSAFI.X07_DOCTO_FISCAL_LOG
(
  COD_EMPRESA       VARCHAR2(3 BYTE)            NOT NULL,
  COD_ESTAB         VARCHAR2(6 BYTE)            NOT NULL,
  DATA_FISCAL       DATE                        NOT NULL,
  MOVTO_E_S         CHAR(1 BYTE)                NOT NULL,
  NORM_DEV          CHAR(1 BYTE)                NOT NULL,
  IDENT_DOCTO       NUMBER(12)                  NOT NULL,
  IDENT_FIS_JUR     NUMBER(12)                  NOT NULL,
  NUM_DOCFIS        VARCHAR2(12 BYTE)           NOT NULL,
  SERIE_DOCFIS      VARCHAR2(3 BYTE)            NOT NULL,
  SUB_SERIE_DOCFIS  VARCHAR2(2 BYTE)            NOT NULL,
  NUM_ITEM          NUMBER,
  LOG_FIN48         VARCHAR2(3000 BYTE)
)
LOGGING 
ROW STORE COMPRESS BASIC
NOCACHE
MONITORING
/