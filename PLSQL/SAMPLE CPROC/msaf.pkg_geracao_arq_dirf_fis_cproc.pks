Prompt Package PKG_GERACAO_ARQ_DIRF_FIS_CPROC;
--
-- PKG_GERACAO_ARQ_DIRF_FIS_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE pkg_geracao_arq_dirf_fis_cproc
IS
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
                      , par_arquivo VARCHAR2 )
        RETURN INTEGER;



    PROCEDURE sp_geracao_arquivo_dirf_fis ( p_empresa IN CHAR
                                          , p_ano_base IN NUMBER
                                          , p_data_emissao DATE
                                          , p_diretorio IN CHAR
                                          , p_arquivo IN CHAR );
END pkg_geracao_arq_dirf_fis_cproc;
/
SHOW ERRORS;
