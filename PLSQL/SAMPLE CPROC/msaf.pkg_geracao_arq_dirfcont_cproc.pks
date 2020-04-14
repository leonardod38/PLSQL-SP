Prompt Package PKG_GERACAO_ARQ_DIRFCONT_CPROC;
--
-- PKG_GERACAO_ARQ_DIRFCONT_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE pkg_geracao_arq_dirfcont_cproc
IS --package specification
    out_file utl_file.file_type;

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

    FUNCTION executar ( par_empresa VARCHAR2
                      , par_ano_base VARCHAR2
                      , par_data_emissao DATE
                      , par_diretorio VARCHAR2
                      , par_arquivo VARCHAR2
                      , par_codigo1 VARCHAR2
                      , par_codigo2 VARCHAR2
                      , par_codigo3 VARCHAR2
                      , par_codigo4 VARCHAR2
                      , par_codigo5 VARCHAR2
                      , par_codigo6 VARCHAR2
                      , par_codigo7 VARCHAR2
                      , par_codigo8 VARCHAR2
                      , par_codigo9 VARCHAR2
                      , par_codigo10 VARCHAR2 )
        RETURN INTEGER;



    PROCEDURE sp_geracao_arquivo_dirf_cont ( p_empresa IN CHAR
                                           , p_ano_base IN NUMBER
                                           , p_data_emissao DATE
                                           , p_diretorio IN CHAR
                                           , p_arquivo IN CHAR
                                           , p_codigo1 IN CHAR
                                           , p_codigo2 IN CHAR
                                           , p_codigo3 IN CHAR
                                           , p_codigo4 IN CHAR
                                           , p_codigo5 IN CHAR
                                           , p_codigo6 IN CHAR
                                           , p_codigo7 IN CHAR
                                           , p_codigo8 IN CHAR
                                           , p_codigo9 IN CHAR
                                           , p_codigo10 IN CHAR );
END pkg_geracao_arq_dirfcont_cproc;
/
SHOW ERRORS;
