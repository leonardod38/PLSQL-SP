Prompt Package SAF_GIA_PE_ANUAL_CPROC;
--
-- SAF_GIA_PE_ANUAL_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE saf_gia_pe_anual_cproc
IS
    -- Author  : MASANTOS
    -- Created : 09/06/2005
    -- OS1812

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

    FUNCTION f_usuario
        RETURN VARCHAR2;

    FUNCTION classificacao
        RETURN VARCHAR2;

    FUNCTION orientacao
        RETURN VARCHAR2;

    FUNCTION executar ( pexercicio IN NUMBER
                      , porigsubst IN CHAR
                      , pcodresp IN VARCHAR2
                      , pcodestab IN VARCHAR2 )
        RETURN INTEGER;

    --  PROCEDURE teste;

    PRAGMA RESTRICT_REFERENCES ( nome
                               , WNDS );
    PRAGMA RESTRICT_REFERENCES ( parametros
                               , WNDS );
END saf_gia_pe_anual_cproc;
/
SHOW ERRORS;
