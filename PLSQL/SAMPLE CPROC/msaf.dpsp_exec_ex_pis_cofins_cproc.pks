Prompt Package DPSP_EXEC_EX_PIS_COFINS_CPROC;
--
-- DPSP_EXEC_EX_PIS_COFINS_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dpsp_exec_ex_pis_cofins_cproc
IS
    FUNCTION parametros
        RETURN VARCHAR2;

    FUNCTION nome
        RETURN VARCHAR2;

    FUNCTION tipo
        RETURN VARCHAR2;

    FUNCTION descricao
        RETURN VARCHAR2;

    PROCEDURE carga ( pnr_particao INTEGER
                    , pnr_particao2 INTEGER
                    , p_data_ini DATE
                    , p_data_fim DATE
                    , p_nm_tabela VARCHAR2
                    , p_proc_id VARCHAR2
                    , p_nm_empresa VARCHAR2
                    , p_nm_usuario VARCHAR2 );

    FUNCTION executar ( p_data_ini DATE
                      , p_data_fim DATE
                      , p_lote INTEGER
                      , p_uf lib_proc.vartab )
        RETURN INTEGER;
END;
/
SHOW ERRORS;
