Prompt Package MSAF_PIN_SINAL_CPROC;
--
-- MSAF_PIN_SINAL_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE msaf_pin_sinal_cproc
IS
    ---------------------------------------------------------------------------------------------------------
    -- Autor         : Valdir Stropa - DW Consulting - MasterSaf
    -- Created       : 09/04/2008
    -- Purpose       : Geracao xml Pin-Sinal
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

    FUNCTION executar ( ptipo_docto VARCHAR2
                      , pdata_ini DATE
                      , pdata_fim DATE
                      , puf lib_proc.vartab
                      , pestab VARCHAR2 )
        RETURN INTEGER;
END msaf_pin_sinal_cproc;
/
SHOW ERRORS;
