Prompt Package DSP_INTERF_NF_C_CPROC;
--
-- DSP_INTERF_NF_C_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dsp_interf_nf_c_cproc
IS
    -- AUTOR    : DSP - LFM
    -- DATA     : 21/MAR/2014
    -- DESCRIÇÃO: Executador de interfaces de NFs da célula

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

    PROCEDURE loga ( p_i_texto IN VARCHAR2
                   , p_i_dttm IN BOOLEAN DEFAULT TRUE );

    FUNCTION executar ( p_data_ini DATE
                      , p_data_fim DATE
                      , p_cria_job VARCHAR2
                      , p_safx lib_proc.vartab )
        RETURN INTEGER;
END dsp_interf_nf_c_cproc;
/
SHOW ERRORS;
