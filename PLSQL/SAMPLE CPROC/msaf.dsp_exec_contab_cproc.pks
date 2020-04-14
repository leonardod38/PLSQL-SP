Prompt Package DSP_EXEC_CONTAB_CPROC;
--
-- DSP_EXEC_CONTAB_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dsp_exec_contab_cproc
IS
    -- AUTOR    : DSP - REBELLO
    -- DATA     : 27/ABR/2015
    -- DESCRIÇÃO: Executador de interfaces contábeis

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

    FUNCTION executar ( p_data_ini DATE
                      , p_data_fim DATE
                      , p_cria_job VARCHAR2
                      , p_safx2002 VARCHAR2
                      , p_safx2003 VARCHAR2
                      , p_safx2101 VARCHAR2
                      , p_safx01 VARCHAR2
                      , p_safx02 VARCHAR2
                      , p_safx80 VARCHAR2
                      , p_safx53 VARCHAR2
                      , p_codestab lib_proc.vartab )
        RETURN INTEGER;
END dsp_exec_contab_cproc;
/
SHOW ERRORS;
