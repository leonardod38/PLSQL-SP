Prompt Package MSAF_DW_SPED_CONFERE_CPROC;
--
-- MSAF_DW_SPED_CONFERE_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE "MSAF_DW_SPED_CONFERE_CPROC"
IS
    -- AUTOR   : TIAGO CERVANTES - ADEJO
    -- CREATED : 15/03/2018
    -- PURPOSE : CONFERÊNCIA DOS VALORES DA X01/X02 PRO SPED CONTÁBIL

    /* VARIÁVEIS DE CONTROLE DE CABEÇALHO DE RELATÓRIO */
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

    FUNCTION executar ( ps_estab VARCHAR2
                      , pd_periodo DATE
                      , ps_conta VARCHAR2
                      , ps_reduzida VARCHAR2 )
        RETURN INTEGER;

    PROCEDURE cabecalho ( ps_estab VARCHAR2
                        , prel VARCHAR2 );
END msaf_dw_sped_confere_cproc;
/
SHOW ERRORS;
