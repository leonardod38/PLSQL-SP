Prompt Table DPSP_TB_FIN4816_REINF_PREV_GTT;
--
-- MSAFI.TB_DPSP_FIN4816_REINF_PREV_GTT  (Table) 
--


CREATE GLOBAL TEMPORARY TABLE  MSAFI.TB_FIN4816_REINF_PREV_GTT
(
  TIPO                             CHAR(7 BYTE),
  "Codigo Empresa"                 VARCHAR2(3 BYTE),
  "Codigo Estabelecimento"         VARCHAR2(6 BYTE),
  "Data Emissão"                   DATE,
  "Data Fiscal"                    DATE,
  IDENT_FIS_JUR                    NUMBER(12)   NOT NULL,
  IDENT_DOCTO                      NUMBER(12)   NOT NULL,
  "Número da Nota Fiscal"          VARCHAR2(12 BYTE),
  "Docto/Série"                    VARCHAR2(16 BYTE),
  "Emissão"                        DATE,
  SERIE_DOCFIS                     VARCHAR2(3 BYTE) NOT NULL,
  SUB_SERIE_DOCFIS                 VARCHAR2(2 BYTE) NOT NULL,
  NUM_ITEM                         NUMBER(5)    NOT NULL,
  COD_USUARIO                      VARCHAR2(40 BYTE) NOT NULL,
  "Codigo Pessoa Fisica/Juridica"  VARCHAR2(14 BYTE),
  "Razão Social Cliente"           VARCHAR2(70 BYTE),
  IND_FIS_JUR                      CHAR(1 BYTE),
  "CNPJ Cliente"                   VARCHAR2(14 BYTE),
  COD_CLASS_DOC_FIS                CHAR(1 BYTE),
  VLR_TOT_NOTA                     NUMBER(17,2),
  "Vlr Base Calc. Retenção"        NUMBER(17,2),
  VLR_ALIQ_INSS                    NUMBER(7,4),
  "Vlr.Trib INSS RETIDO"           NUMBER(17,2),
  "Valor da Retenção"              NUMBER(17,2),
  VLR_CONTAB_COMPL                 NUMBER(17,2),
  IND_TIPO_PROC                    CHAR(1 BYTE),
  NUM_PROC_JUR                     VARCHAR2(21 BYTE),
  RAZAO_SOCIAL                     VARCHAR2(100 BYTE),
  CGC                              VARCHAR2(14 BYTE),
  "Documento"                      VARCHAR2(50 BYTE),
  "Tipo de Serviço E-social"       VARCHAR2(9 BYTE),
  DSC_TIPO_SERV_ESOCIAL            VARCHAR2(100 BYTE),
  "Razão Social Drogaria"          VARCHAR2(70 BYTE),
  "Valor do Servico"               NUMBER(17,2),
  NUM_PROC_ADJ_ADIC                VARCHAR2(21 BYTE),
  IND_TP_PROC_ADJ_ADIC             CHAR(1 BYTE),
  CODIGO_SERV_PROD                 VARCHAR2(4 BYTE),
  DESC_SERV_PROD                   VARCHAR2(50 BYTE),
  COD_DOCTO                        VARCHAR2(5 BYTE),
  "Observação"                     VARCHAR2(50 BYTE),
  DSC_PARAM                        VARCHAR2(50 BYTE)
)
ON COMMIT PRESERVE ROWS NOCACHE;



