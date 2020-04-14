Prompt Package DSP_INTERF_CUPOM_E_CPROC;
--
-- DSP_INTERF_CUPOM_E_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dsp_interf_cupom_e_cproc
IS
    -- AUTOR    : DSP - REBELLO
    -- DATA     : 05/AGO/2015
    -- DESCRIÇÃO: Executador de interfaces de cupom fiscal eletrônico

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

    FUNCTION executar ( p_data_ini DATE
                      , p_data_fim DATE
                      , p_cria_job VARCHAR2
                      , p_safx07_e VARCHAR2
                      , p_safx08_e VARCHAR2
                      , p_safx201_e VARCHAR2
                      , p_safx202_e VARCHAR2
                      , p_codestab lib_proc.vartab )
        RETURN INTEGER;
END dsp_interf_cupom_e_cproc;
/
SHOW ERRORS;
