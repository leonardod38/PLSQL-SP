Prompt Table TT;
--
--  FIN4816_REINF_2010_GTT  (Table) 
--
CREATE TABLE MSAFI.FIN4816_REINF_2010_GTT
(
  COD_EMPRESA_PK                 VARCHAR2(3 BYTE) NOT NULL,
  COD_ESTAB_PK                   VARCHAR2(6 BYTE) NOT NULL,
  DAT_FISCAL_PK                  DATE,
  DAT_EMISSAO_PK                 DATE,
  IDEN_FIS_JUR_PK                NUMBER(12)     NOT NULL,
  NUM_DOCFIS_PK                  VARCHAR2(15 BYTE) NOT NULL,
  "Codigo Empresa"               VARCHAR2(3 BYTE),
  "Razão Social Drogaria"        VARCHAR2(100 BYTE),
  "Razão Social Cliente"         VARCHAR2(70 BYTE),
  "Número da Nota Fiscal"        VARCHAR2(15 BYTE),
  "Data de Emissão da NF"        DATE,
  "Data Fiscal"                  DATE,
  "Valor do Tributo"             NUMBER(17,2),
  "observacao"                   VARCHAR2(250 BYTE),
  "Tipo de Serviço E-social"     NUMBER(9),
  "Vlr. Base de Calc. Retenção"  NUMBER(17,2),
  "Valor da Retenção"            NUMBER(17,2),
  PROC_ID                        NUMBER(12),
  IND_STATUS                     CHAR(1 BYTE),
  CNPJ_PRESTADOR                 VARCHAR2(14 BYTE) NOT NULL,
  IND_OBRA                       CHAR(1 BYTE),
  TP_INSCRICAO                   CHAR(1 BYTE)   NOT NULL,
  NR_INSCRICAO                   VARCHAR2(14 BYTE) NOT NULL,
  NUM_RECIBO                     VARCHAR2(52 BYTE),
  IND_TP_AMB                     CHAR(1 BYTE),
  VLR_BRUTO                      NUMBER(17,2),
  VLR_BASE_RET                   NUMBER(17,2),
  VLR_RET_PRINC                  NUMBER(17,2),
  VLR_RET_ADIC                   NUMBER(17,2),
  VLR_N_RET_PRINC                NUMBER(17,2),
  VLR_N_RET_ADIC                 NUMBER(17,2),
  IND_CPRB                       CHAR(1 BYTE),
  COD_VERSAO_PROC                VARCHAR2(20 BYTE),
  COD_VERSAO_LAYOUT              VARCHAR2(10 BYTE),
  IND_PROC_EMISSAO               CHAR(1 BYTE),
  ID_EVENTO                      VARCHAR2(36 BYTE),
  IND_OPER                       CHAR(1 BYTE),
  COD_EMPRESA                    VARCHAR2(3 BYTE) NOT NULL,
  COD_ESTAB                      VARCHAR2(6 BYTE) NOT NULL,
  DAT_OCORRENCIA                 DATE           NOT NULL,
  CGC                            VARCHAR2(14 BYTE),
  RAZAO_SOCIAL                   VARCHAR2(70 BYTE),
  X04_RAZAO_SOCIAL               VARCHAR2(70 BYTE),
  ID_R2010_OC                    NUMBER(12)     NOT NULL,
  NUM_DOCTO                      VARCHAR2(15 BYTE) NOT NULL,
  SERIE                          VARCHAR2(3 BYTE) NOT NULL,
  DAT_EMISSAO_NF                 DATE,
  DATA_FISCAL                    DATE,
  RNF_VLR_BRUTO                  NUMBER(17,2),
  OBSERVACAO                     VARCHAR2(250 BYTE),
  ID_R2010_NF                    NUMBER(12)     NOT NULL,
  IND_TP_PROC_ADJ_ADIC           CHAR(1 BYTE),
  NUM_PROC_ADJ_ADIC              VARCHAR2(21 BYTE),
  COD_SUSP_ADIC                  VARCHAR2(14 BYTE),
  RADIC_VLR_N_RET_ADIC           NUMBER(17,2),
  IND_TP_PROC_ADJ_PRINC          CHAR(1 BYTE),
  NUM_PROC_ADJ_PRINC             VARCHAR2(21 BYTE),
  COD_SUSP_PRINC                 VARCHAR2(14 BYTE),
  RPRINC_VLR_N_RET_PRINC         NUMBER(17,2),
  TP_SERVICO                     NUMBER(9),
  RSERV_VLR_BASE_RET             NUMBER(17,2),
  VLR_RETENCAO                   NUMBER(17,2),
  VLR_RET_SUB                    NUMBER(17,2),
  RSERV_VLR_N_RET_PRINC          NUMBER(17,2),
  VLR_SERVICOS_15                NUMBER(17,2),
  VLR_SERVICOS_20                NUMBER(17,2),
  VLR_SERVICOS_25                NUMBER(17,2),
  RSERV_VLR_RET_ADIC             NUMBER(17,2),
  RSERV_VLR_N_RET_ADIC           NUMBER(17,2)
)
LOGGING 
ROW STORE COMPRESS BASIC
NOCACHE
MONITORING
/


Prompt Index IDX_TT;
--
-- IDX_TT  (Index) 
--
CREATE UNIQUE INDEX IDX_2010 ON MSAFI.FIN4816_REINF_2010_GTT
(COD_EMPRESA_PK, COD_ESTAB_PK, DAT_FISCAL_PK, DAT_EMISSAO_PK, IDEN_FIS_JUR_PK, 
NUM_DOCFIS_PK)
LOGGING
/

-- 
-- Non Foreign Key Constraints for Table TT 
-- 
Prompt Non-Foreign Key Constraints on Table TT;
ALTER TABLE MSAFI.FIN4816_REINF_2010_GTT ADD (
  CONSTRAINT IDX_2010
  PRIMARY KEY
  (COD_EMPRESA_PK, COD_ESTAB_PK, DAT_FISCAL_PK, DAT_EMISSAO_PK, IDEN_FIS_JUR_PK, NUM_DOCFIS_PK)
  USING INDEX IDX_2010
  ENABLE VALIDATE)
/
