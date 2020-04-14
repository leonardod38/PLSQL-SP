Prompt Package DSP_INTERF_CUPOM_CPROC;
--
-- DSP_INTERF_CUPOM_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dsp_interf_cupom_cproc
IS
    -- AUTOR    : DSP - LFM
    -- DATA     : 26/DEZ/2013
    -- DESCRIÇÃO: Executador de interfaces de cupom fiscal

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
                      , p_safx07 VARCHAR2
                      , p_safx08 VARCHAR2
                      , p_safx2087 VARCHAR2
                      , p_safx2099 VARCHAR2
                      , p_safx28 VARCHAR2
                      , p_safx29 VARCHAR2
                      , p_safx991 VARCHAR2
                      , p_safx992 VARCHAR2
                      , p_safx993 VARCHAR2
                      , p_safx994 VARCHAR2
                      , p_safx281 VARCHAR2
                      , p_calc VARCHAR2
                      , p_codestab lib_proc.vartab )
        RETURN INTEGER;
END dsp_interf_cupom_cproc;
/
SHOW ERRORS;
