Prompt Package MSAF_REL_SUBC_CPROC;
--
-- MSAF_REL_SUBC_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE msaf_rel_subc_cproc
IS
    -- Author  : AASANTOS
    -- Created : 13/10/2008 17:14:38
    -- Purpose : Novo Relatório de Substancias Controladas

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
END msaf_rel_subc_cproc;
/
SHOW ERRORS;
