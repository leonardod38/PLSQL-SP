Prompt Package DPSP_MSAF_CAT42_265_CPROC;
--
-- DPSP_MSAF_CAT42_265_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dpsp_msaf_cat42_265_cproc
IS
    -----------------------------------------
    -- BY ANDRE REBELLO (ACCENTURE)- JUL/2019
    -- PROJETO 1952 CAT42 MODULO MSAF
    -- CARGA SAFX265 ORIGEM ARQUIVO TXT
    -----------------------------------------

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

    FUNCTION executar ( p_dir VARCHAR2
                      , p_file VARCHAR2
                      , p_cod_estab lib_proc.vartab )
        RETURN INTEGER;
END dpsp_msaf_cat42_265_cproc;
/
SHOW ERRORS;
