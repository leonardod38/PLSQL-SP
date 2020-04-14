Prompt Package ADEJO_RET_CRED_CIAP_CPROC;
--
-- ADEJO_RET_CRED_CIAP_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE adejo_ret_cred_ciap_cproc
IS
    -- Autor   : Erick P. Alcantara
    -- Created : 19/01/2018
    -- Purpose : Projeto CIAP - Geragco do arquivo TXT e XLSX


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

    PROCEDURE geraarquivo ( pcod_empresa VARCHAR2
                          , pcod_estab VARCHAR2
                          , pdat_ini DATE
                          , pdat_fim DATE );

    PROCEDURE geraexcel ( pcod_empresa VARCHAR2
                        , pcod_estab VARCHAR2
                        , pdat_ini DATE
                        , pdat_fim DATE );

    FUNCTION executar ( pcod_empresa VARCHAR2
                      , pcod_estab VARCHAR2
                      , pdata_ini DATE
                      , pdata_fim DATE )
        RETURN INTEGER;
END adejo_ret_cred_ciap_cproc;
/
SHOW ERRORS;
