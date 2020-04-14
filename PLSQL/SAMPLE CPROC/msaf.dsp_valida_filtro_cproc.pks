Prompt Package DSP_VALIDA_FILTRO_CPROC;
--
-- DSP_VALIDA_FILTRO_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dsp_valida_filtro_cproc
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

    FUNCTION executar ( p_funcionalidade VARCHAR2
                      , p_perfil VARCHAR2
                      , p_uf VARCHAR2
                      , p_estabelecimento VARCHAR2
                      , p_tipo_mov_e_s VARCHAR2
                      , p_natureza VARCHAR2
                      , p_cfop VARCHAR2
                      , p_cst VARCHAR2
                      , p_base_icms INTEGER
                      , p_valor_icms INTEGER
                      , p_aliquota_icms INTEGER
                      , p_valor_isento INTEGER
                      , p_valor_outras INTEGER
                      , p_valor_reducao INTEGER )
        RETURN INTEGER;
END dsp_valida_filtro_cproc;
/
SHOW ERRORS;
