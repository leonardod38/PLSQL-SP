Prompt Package MSAF_PIN_SINAL5_CPROC;
--
-- MSAF_PIN_SINAL5_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE msaf_pin_sinal5_cproc
IS
    ---------------------------------------------------------------------------------------------------------
    -- Autor         : Wesley Souza - DW Consulting - MasterSaf
    -- Created       : 11/04/2008
    -- Purpose       : Relatório Pin-Sinal.
    ---------------------------------------------------------------------------------------------------------

    /* Declarac?o de Variaveis Publicas */

    usuario_p VARCHAR2 ( 20 );

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

    FUNCTION executar ( pd_dt_ini DATE
                      , pd_dt_fim DATE
                      , ps_cod_estab lib_proc.vartab )
        RETURN INTEGER;

    PROCEDURE cabecalho_ini ( ps_razao VARCHAR2
                            , ps_cnpj VARCHAR2
                            , pn_folha NUMBER );
END msaf_pin_sinal5_cproc;
/
SHOW ERRORS;
