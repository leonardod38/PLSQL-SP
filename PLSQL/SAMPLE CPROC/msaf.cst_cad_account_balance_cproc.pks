Prompt Package CST_CAD_ACCOUNT_BALANCE_CPROC;
--
-- CST_CAD_ACCOUNT_BALANCE_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE cst_cad_account_balance_cproc
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
                      , p_cod_conta_exc VARCHAR2
                      , p_cod_conta VARCHAR2
                      , p_descricao VARCHAR2
                      , p_sint_analitico VARCHAR2
                      , p_cod_conta_sint VARCHAR2
                      , p_ordem_apres VARCHAR2 )
        RETURN INTEGER;
END cst_cad_account_balance_cproc;
/
SHOW ERRORS;
