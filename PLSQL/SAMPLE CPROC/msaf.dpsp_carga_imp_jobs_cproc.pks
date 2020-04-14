Prompt Package DPSP_CARGA_IMP_JOBS_CPROC;
--
-- DPSP_CARGA_IMP_JOBS_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dpsp_carga_imp_jobs_cproc
IS
    -- Author  : Lucas Manarte
    -- Created : 20/09/2019
    -- Purpose : Consultar Jobs da Automatização da Carga e Importação

    -- Public function and procedure declarations
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

    FUNCTION orientacao
        RETURN VARCHAR2;

    PROCEDURE loga ( p_i_texto IN VARCHAR2
                   , p_i_dttm IN BOOLEAN DEFAULT TRUE );

    PROCEDURE arquivo_scheduler ( pcod_job VARCHAR2
                                , v_id_arq INTEGER );

    PROCEDURE arquivo_log ( pcod_job VARCHAR2
                          , v_id_arq INTEGER );

    FUNCTION executar ( flg_processo CHAR
                      , pcod_job lib_proc.vartab )
        RETURN INTEGER;
END dpsp_carga_imp_jobs_cproc;
/
SHOW ERRORS;
