Prompt Package DSP_VALIDA_ACAO_CPROC;
--
-- DSP_VALIDA_ACAO_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dsp_valida_acao_cproc
IS
    -- DATA       : CRIADA EM 16/AGO/2017
    -- V2 CRIADA EM 03/08/2018: REBELLO - MELHORIA DE PERFORMANCE

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

    FUNCTION executar ( p_acao VARCHAR2
                      , p_lista VARCHAR2
                      , p_natureza VARCHAR2
                      , p_cfop VARCHAR2
                      , p_cst VARCHAR2 )
        RETURN INTEGER;
END dsp_valida_acao_cproc;
/
SHOW ERRORS;
