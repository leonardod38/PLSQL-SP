Prompt Package CST_REL_ACCOUNT_SAP_JDE_CPROC;
--
-- CST_REL_ACCOUNT_SAP_JDE_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE cst_rel_account_sap_jde_cproc
IS
    -- AUTOR    : Jorge Oliveira
    -- DATA     : CRIADA EM 01/Feb/2020
    -- DESCRIÇÃO: PROJETO GEOSSA

    musuario usuario_empresa.cod_usuario%TYPE;

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
                      , p_cod_empresa VARCHAR2 )
        RETURN INTEGER;
END cst_rel_account_sap_jde_cproc;
/
SHOW ERRORS;
