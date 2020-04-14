Prompt Package MSAF_PIN_SINAL2_CPROC;
--
-- MSAF_PIN_SINAL2_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE msaf_pin_sinal2_cproc
IS
    ---------------------------------------------------------------------------------------------------------
    -- Autor         : Valdir Stropa - DW Consulting - MasterSaf
    -- Created       : 10/04/2008
    -- Purpose       : Meio magnetico xml Pin-Sinal
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

    FUNCTION executar ( --                    PNF       VARCHAR2,
                        pdata DATE
                      , plote lib_proc.vartab )
        RETURN INTEGER;
END msaf_pin_sinal2_cproc;
/
SHOW ERRORS;
