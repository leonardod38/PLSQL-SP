Prompt Package CRIA_DADOS_CHAMADO_CPROC;
--
-- CRIA_DADOS_CHAMADO_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE cria_dados_chamado_cproc
IS
    -- author  : RMARENDA
    -- created : 16/10/03 11:00:00
    -- purpose : cria dados

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

    FUNCTION executar ( pcodestab VARCHAR2
                      , pcodestado VARCHAR2
                      , pcodmodelociap VARCHAR2 )
        RETURN INTEGER;

    PROCEDURE rec_cnpj_ie ( p_cod_estado IN VARCHAR2
                          , p_cnpj   OUT VARCHAR2
                          , p_ie   OUT VARCHAR2 );

    PROCEDURE teste;
END;
/
SHOW ERRORS;
