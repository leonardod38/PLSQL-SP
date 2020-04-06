DROP TABLE msafi.fin4816_report_fiscal_gtt;

CREATE TABLE msafi.fin4816_report_fiscal_gtt
(
    cod_empresa VARCHAR2 ( 3 BYTE ) NOT NULL
  , cod_estab VARCHAR2 ( 6 BYTE ) NOT NULL
  , data_fiscal DATE NOT NULL
  , movto_e_s CHAR ( 1 BYTE ) NOT NULL
  , norm_dev CHAR ( 1 BYTE ) NOT NULL
  , ident_docto NUMBER ( 12 ) NOT NULL
  , ident_fis_jur NUMBER ( 12 ) NOT NULL
  , num_docfis VARCHAR2 ( 12 BYTE ) NOT NULL
  , serie_docfis VARCHAR2 ( 3 BYTE ) NOT NULL
  , sub_serie_docfis VARCHAR2 ( 2 BYTE ) NOT NULL
  , ident_servico NUMBER ( 12 ) NOT NULL
  , num_item NUMBER ( 5 ) NOT NULL
  , periodo_emissao VARCHAR2 ( 14 BYTE )
  , cgc VARCHAR2 ( 14 BYTE )
  , num_docto VARCHAR2 ( 12 BYTE )
  , tipo_docto VARCHAR2 ( 5 BYTE )
  , data_emissao DATE
  , cgc_fornecedor VARCHAR2 ( 50 BYTE )
  , uf VARCHAR2 ( 5 BYTE )
  , valor_total NUMBER ( 17, 2 )
  , vlr_base_inss NUMBER ( 17, 2 )
  , vlr_inss NUMBER ( 17, 2 )
  , codigo_fisjur VARCHAR2 ( 14 BYTE )
  , razao_social VARCHAR2 ( 120 BYTE )
  , municipio_prestador VARCHAR2 ( 50 BYTE )
  , cod_servico VARCHAR2 ( 14 BYTE )
);




Prompt Index IDX_4818_RPF;
--
-- IDX_4818_RPF  (Index) 
--
CREATE UNIQUE INDEX IDX_4818_RPF ON FIN4816_REPORT_FISCAL_GTT
(COD_EMPRESA, COD_ESTAB, DATA_FISCAL, MOVTO_E_S, NORM_DEV, 
IDENT_DOCTO, IDENT_FIS_JUR, NUM_DOCFIS, SERIE_DOCFIS, SUB_SERIE_DOCFIS, 
IDENT_SERVICO, NUM_ITEM)
LOGGING
/

-- 
-- Non Foreign Key Constraints for Table FIN4816_REPORT_FISCAL_GTT 
-- 
Prompt Non-Foreign Key Constraints on Table FIN4816_REPORT_FISCAL_GTT;
ALTER TABLE FIN4816_REPORT_FISCAL_GTT ADD (
  CONSTRAINT IDX_4818_RPF
  PRIMARY KEY
  (COD_EMPRESA, COD_ESTAB, DATA_FISCAL, MOVTO_E_S, NORM_DEV, IDENT_DOCTO, IDENT_FIS_JUR, NUM_DOCFIS, SERIE_DOCFIS, SUB_SERIE_DOCFIS, IDENT_SERVICO, NUM_ITEM)
  USING INDEX IDX_4818_RPF
  ENABLE VALIDATE)
/