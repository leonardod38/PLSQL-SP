Prompt Package MSAF_PIN_SINAL1_CPROC;
--
-- MSAF_PIN_SINAL1_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE msaf_pin_sinal1_cproc
IS
    ---------------------------------------------------------------------------------------------------------
    -- Autor         : Valdir Stropa - DW Consulting - MasterSaf
    -- Created       : 10/04/2008
    -- Purpose       : Manutencao Pin-Sinal. Permite ao usuario efetuar manutencao
    --                 das NF que devem compor os lotes.
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

    FUNCTION executar ( pnf VARCHAR2
                      , plote VARCHAR2
                      , pnnota lib_proc.vartab )
        RETURN INTEGER;
END msaf_pin_sinal1_cproc;
/
SHOW ERRORS;
