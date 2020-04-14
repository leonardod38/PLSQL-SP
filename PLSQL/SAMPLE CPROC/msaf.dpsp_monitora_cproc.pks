Prompt Package DPSP_MONITORA_CPROC;
--
-- DPSP_MONITORA_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dpsp_monitora_cproc
IS
    FUNCTION parametros
        RETURN VARCHAR2;

    FUNCTION nome
        RETURN VARCHAR2;

    FUNCTION tipo
        RETURN VARCHAR2;

    FUNCTION versao
        RETURN VARCHAR2;

    FUNCTION descricao
        RETURN VARCHAR2;

    FUNCTION modulo
        RETURN VARCHAR2;

    FUNCTION classificacao
        RETURN VARCHAR2;

    FUNCTION orientacao
        RETURN VARCHAR2;

    p_null_lojas lib_proc.vartab;

    FUNCTION executar
        RETURN INTEGER;

    PROCEDURE loga ( p_i_texto IN VARCHAR2
                   , p_i_dttm IN BOOLEAN DEFAULT TRUE );


    PROCEDURE executar_job;
END dpsp_monitora_cproc;
/
SHOW ERRORS;
