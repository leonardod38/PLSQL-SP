Prompt Package DSP_TESTE_CPROC;
--
-- DSP_TESTE_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dsp_teste_cproc
IS
    -- AUTOR    : DSP - LFM
    -- DATA     : 23/09/2013
    -- DESCRIÇÃO: Mini boas práticas

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

    PROCEDURE loga ( p_texto VARCHAR2 );

    FUNCTION executar ( p_valida_tabs VARCHAR2 DEFAULT 'S'
                      , p_exec_cadastros VARCHAR2 DEFAULT 'S'
                      , p_exec_auto_audit_nf VARCHAR2 DEFAULT 'S'
                      , p_limpa_log_simples VARCHAR2 DEFAULT 'S'
                      , p_limpa_log_pesado VARCHAR2 DEFAULT 'S'
                      , p_lista_data_mart VARCHAR2 DEFAULT 'S'
                      , p_lista_usuarios_mm VARCHAR2 DEFAULT 'S'
                      , p_lista_nfs_videntes VARCHAR2 DEFAULT 'S'
                      , p_calc_stats VARCHAR2 DEFAULT 'S'
                      , p_job NUMBER DEFAULT 0 )
        RETURN INTEGER;

    PROCEDURE execjob;
END dsp_teste_cproc;
/
SHOW ERRORS;
