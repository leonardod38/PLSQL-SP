Prompt Package DPSP_EXEC_CARTOES_CPROC;
--
-- DPSP_EXEC_CARTOES_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dpsp_exec_cartoes_cproc
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
                      , p_lote NUMBER )
        RETURN INTEGER;
END;
/
SHOW ERRORS;
