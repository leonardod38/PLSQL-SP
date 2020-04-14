Prompt Package RELATORIO_LOG_IMPORTACAO_CPROC;
--
-- RELATORIO_LOG_IMPORTACAO_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE relatorio_log_importacao_cproc
IS
    -- Autor   : Pedro A. Puerta
    -- Created : 03/12/2007
    -- Purpose : Diferencial de Aliquota

    /* Declarac?o de Variaveis Publicas */
    cod_empresa_p estabelecimento.cod_empresa%TYPE;
    cod_estab_p estabelecimento.cod_estab%TYPE;
    nome_estab_p estabelecimento.razao_social%TYPE;
    cgc_estab_p estabelecimento.cgc%TYPE;
    inscricao_estadual_p registro_estadual.inscricao_estadual%TYPE;
    nome_empresa_p empresa.razao_social%TYPE;

    usuario_p VARCHAR2 ( 20 );
    total_estab_p NUMBER ( 4 );
    pfolha NUMBER := 0;
    mlinha VARCHAR2 ( 4000 );
    conta NUMBER := 0;
    w_razao VARCHAR2 ( 100 );
    mcod_empresa estabelecimento.cod_empresa%TYPE;
    mcod_estab estabelecimento.cod_estab%TYPE;
    musuario VARCHAR2 ( 100 );

    /* VARIAVEIS DE CONTROLE DE CABECALHO DE RELATORIO */

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

    FUNCTION executar ( pnum_processo IN NUMBER )
        RETURN INTEGER;

    PROCEDURE teste;
END relatorio_log_importacao_cproc;
/
SHOW ERRORS;
