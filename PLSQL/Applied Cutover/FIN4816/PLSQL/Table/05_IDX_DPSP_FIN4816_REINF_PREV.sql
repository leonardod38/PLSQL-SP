PROMPT Index IDX_PREV;
--
-- IDX_DPSP_FIN4816_REINF_PREV  (Index)
--


CREATE UNIQUE  INDEX pk_fin4816_reinf_prev
    ON msafi.tb_fin4816_reinf_prev_gtt ( "Codigo Empresa"
                                            , "Codigo Estabelecimento"
                                            , "Data Fiscal"
                                            , ident_fis_jur
                                            , ident_docto
                                            , "Número da Nota Fiscal"
                                            , serie_docfis
                                            , sub_serie_docfis
                                            , num_item )
--
-- Non Foreign Key Constraints for Table DPSP_TB_FIN4816_REINF_PREV_GTT
--

Prompt Non-Foreign Key Constraints on Table IDX_DPSP_FIN4816_REINF_PREV;


ALTER TABLE msafi.tb_fin4816_reinf_prev_gtt ADD (
  CONSTRAINT pk_fin4816_reinf_prev
  PRIMARY KEY
  ("Codigo Empresa", "Codigo Estabelecimento", "Data Fiscal", ident_fis_jur, ident_docto, "Número da Nota Fiscal", serie_docfis, sub_serie_docfis, num_item)
  USING INDEX pk_fin4816_reinf_prev
  ENABLE VALIDATE)
/