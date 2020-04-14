Prompt Package DPSP_PROCESSO_LOG_CPROC;
--
-- DPSP_PROCESSO_LOG_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dpsp_processo_log_cproc
IS
    -- AUTOR    : DSP - DOUGLAS OLIVEIRA - SUSTENTAÇÃO
    -- DATA     : V1 CRIADA EM 07/08/2018
    -- DESCRIÇÃO: Relatorio de LOGs dos processamentos

    mcod_empresa empresa.cod_empresa%TYPE;
    mcod_estab estabelecimento.cod_estab%TYPE;
    musuario usuario_empresa.cod_usuario%TYPE;

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
                      , p_hora NUMBER
                      , p_proc VARCHAR2
                      , p_status VARCHAR2
                      , p_id_processo VARCHAR2
                      , p_log lib_proc.vartab )
        RETURN INTEGER;
END dpsp_processo_log_cproc;
/
SHOW ERRORS;
