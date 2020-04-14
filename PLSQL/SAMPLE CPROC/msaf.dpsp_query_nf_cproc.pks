Prompt Package DPSP_QUERY_NF_CPROC;
--
-- DPSP_QUERY_NF_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dpsp_query_nf_cproc
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
                      , p_movto_e_s VARCHAR2
                      , p_capa VARCHAR2
                      , p_separa VARCHAR2
                      , p_livre VARCHAR2
                      , p_cfop VARCHAR2
                      , p_fin VARCHAR2
                      , p_cst VARCHAR2
                      , p_uf_destino VARCHAR2
                      , p_uf VARCHAR2
                      , p_cod_estab lib_proc.vartab )
        RETURN INTEGER;
END;
/
SHOW ERRORS;
