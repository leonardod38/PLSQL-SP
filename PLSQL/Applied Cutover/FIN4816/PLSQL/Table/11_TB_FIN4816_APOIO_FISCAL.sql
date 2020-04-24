Prompt Table TB_FIN4816_REL_APOIO_FISCAL;
--
-- TB_FIN4816_REL_APOIO_FISCAL  (Table) 
--
CREATE TABLE MSAFI.TB_FIN4816_REL_APOIO_FISCAL
(
  "Codigo da Empresa"              VARCHAR2(3 BYTE),
  "Codigo do Estabelecimento"      VARCHAR2(6 BYTE),
  "Periodo de Emissão"             VARCHAR2(7 BYTE),
  "CNPJ Drogaria"                  VARCHAR2(14 BYTE),
  "Numero da Nota Fiscal"          VARCHAR2(12 BYTE),
  "Tipo de Documento"              VARCHAR2(5 BYTE),
  "Data Emissão"                   DATE,
  "CNPJ Fonecedor"                 VARCHAR2(50 BYTE),
  UF                               VARCHAR2(5 BYTE),
  "Valor Total da Nota"            NUMBER(17,2),
  "Base de Calculo INSS"           NUMBER(17,2),
  "Valor do INSS"                  NUMBER(17,2),
  "Codigo Pessoa Fisica/juridica"  VARCHAR2(14 BYTE),
  "Razão Social"                   VARCHAR2(120 BYTE),
  "Municipio Prestador"            VARCHAR2(50 BYTE),
  "Codigo de Serviço"              VARCHAR2(14 BYTE),
  "Codigo CEI"                     VARCHAR2(15 BYTE),
  DWT                              VARCHAR2(1 BYTE),
  EMPRESA                          VARCHAR2(6 BYTE),
  "Codigo Estabelecimento"         VARCHAR2(6 BYTE),
  COD_PESSOA_FIS_JUR               VARCHAR2(14 BYTE),
  "Razão Social Cliente"           VARCHAR2(70 BYTE),
  "CNPJ Cliente"                   VARCHAR2(14 BYTE),
  "Nro. Nota Fiscal"               VARCHAR2(12 BYTE),
  "Dt. Emissao"                    DATE,
  "Dt. Fiscal"                     DATE,
  "Vlr. Total da Nota"             NUMBER,
  "Vlr Base Calc. Retenção"        NUMBER,
  "Vlr. Aliquota INSS"             NUMBER,
  "Vlr.Trib INSS RETIDO"           NUMBER,
  "Razão Social Drogaria"          VARCHAR2(70 BYTE),
  "CNPJ Drogarias"                 VARCHAR2(14 BYTE),
  "Descr. Tp. Documento"           VARCHAR2(5 BYTE),
  "Tp.Serv. E-social"              VARCHAR2(9 BYTE),
  "Descr. Tp. Serv E-social"       VARCHAR2(100 BYTE),
  "Vlr. do Servico"                NUMBER,
  "Cod. Serv. Mastersaf"           VARCHAR2(4 BYTE),
  "Descr. Serv. Mastersaf"         VARCHAR2(50 BYTE),
  "Codigo Empresa"                 VARCHAR2(3 BYTE),
  "Razão Social Drogaria."         VARCHAR2(100 BYTE),
  "Razão Social Cliente."          VARCHAR2(70 BYTE),
  "Número da Nota Fiscal."         VARCHAR2(15 BYTE),
  "Data de Emissão da NF."         DATE,
  "Data Fiscal."                   DATE,
  "Valor do Tributo."              NUMBER,
  "Observação."                    VARCHAR2(250 BYTE),
  "Tipo de Serviço E-social."      VARCHAR2(40 BYTE),
  "Vlr. Base de Calc. Retenção."   NUMBER,
  "Valor da Retenção."             NUMBER
)
LOGGING 
ROW STORE COMPRESS BASIC
NOCACHE
MONITORING
/
