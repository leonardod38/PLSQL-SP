Prompt Package MSAF_PIN_SINAL4_CPROC;
--
-- MSAF_PIN_SINAL4_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE msaf_pin_sinal4_cproc
IS
    ---------------------------------------------------------------------------------------------------------
    -- Autor         : Valdir Stropa - DW Consulting - MasterSaf
    -- Created       : 11/04/2008
    -- Purpose       : Controle do Pin-Sinal. Permite ao usuario efetuar manutencao
    --                 dos codigos PIN para cada um dos lotes.
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

    FUNCTION executar ( --                    PLOTEP     VARCHAR2,
                        plotee VARCHAR2
                      , ppin VARCHAR2
                      , pnf lib_proc.vartab )
        RETURN INTEGER;
END msaf_pin_sinal4_cproc;
/
SHOW ERRORS;
