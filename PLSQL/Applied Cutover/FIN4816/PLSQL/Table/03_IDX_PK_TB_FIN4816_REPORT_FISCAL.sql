
ALTER TABLE MSAFI.TB_FIN4816_REPORT_FISCAL_GTT ADD (
  CONSTRAINT IDX_TB_FIN4816_REPORT_FISCAL
  PRIMARY KEY
  (COD_EMPRESA, COD_ESTAB, DATA_FISCAL, MOVTO_E_S, NORM_DEV, IDENT_DOCTO, IDENT_FIS_JUR, NUM_DOCFIS, SERIE_DOCFIS, SUB_SERIE_DOCFIS, IDENT_SERVICO, NUM_ITEM)
  USING INDEX IDX_TB_FIN4816_REPORT_FISCAL
  ENABLE VALIDATE)