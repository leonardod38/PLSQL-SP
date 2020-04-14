Prompt Package CST_DEPARA_ACCOUNT_CPROC;
--
-- CST_DEPARA_ACCOUNT_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE cst_depara_account_cproc
IS
    -- AUTOR    : Jorge Oliveira
    -- DATA     : CRIADA EM 07/mar/2020
    -- DESCRIÇÃO: PROJETO GEOS

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

    FUNCTION executar ( p_funcionalidade VARCHAR2
                      , p_dat_valid_ini DATE
                      , p_cod_conta_fc VARCHAR2
                      , p_lista lib_proc.vartab )
        RETURN INTEGER;
END cst_depara_account_cproc;
/
SHOW ERRORS;
