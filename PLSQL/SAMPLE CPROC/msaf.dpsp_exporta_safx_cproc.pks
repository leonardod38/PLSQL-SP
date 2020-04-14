Prompt Package DPSP_EXPORTA_SAFX_CPROC;
--
-- DPSP_EXPORTA_SAFX_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dpsp_exporta_safx_cproc
IS
    FUNCTION parametros
        RETURN VARCHAR2;

    FUNCTION nome
        RETURN VARCHAR2;

    FUNCTION tipo
        RETURN VARCHAR2;

    FUNCTION descricao
        RETURN VARCHAR2;

    FUNCTION executar ( p_data_ini DATE
                      , p_data_fim DATE
                      , p_uf VARCHAR2
                      , p_movto_e_s VARCHAR2
                      , p_chave_acesso VARCHAR2
                      , p_safx07 VARCHAR2
                      , p_safx08 VARCHAR2
                      , p_delete VARCHAR2
                      , --     p_safx09     VARCHAR2,
                        p_cod_estab lib_proc.vartab )
        RETURN INTEGER;
END;
/
SHOW ERRORS;
