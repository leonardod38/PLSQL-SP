Prompt Package DSP_INTERF_NF_S_CPROC;
--
-- DSP_INTERF_NF_S_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dsp_interf_nf_s_cproc
IS
    -- AUTOR    : DSP - LFM
    -- DATA     : 30/JUL/2012
    -- DESCRIÇÃO: Executador de interfaces

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
                      , p_uso_consumo VARCHAR2
                      , p_cagadas VARCHAR2
                      , p_vira_ignora_ps VARCHAR2
                      , p_carga_auditoria VARCHAR2
                      , p_codestab VARCHAR2
                      , p_nf_id VARCHAR2
                      , p_safx lib_proc.vartab )
        RETURN INTEGER;
END dsp_interf_nf_s_cproc;
/
SHOW ERRORS;
