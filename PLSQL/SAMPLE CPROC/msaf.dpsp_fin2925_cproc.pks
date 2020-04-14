Prompt Package DPSP_FIN2925_CPROC;
--
-- DPSP_FIN2925_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dpsp_fin2925_cproc
IS
    -------------------------------------------------------------------------
    -- AUTOR    : DSP/DP - Guilherme Silva
    -- DATA     : CRIADA EM 07/Agosto/2018
    -- DESCRIÇÃO: Processamento Relatório de Ressarcimento de ST para NF de Incineração
    -------------------------------------------------------------------------


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
                      , p_data_fim DATE
                      , p_uf VARCHAR2
                      , p_cod_estab lib_proc.vartab )
        RETURN INTEGER;
END dpsp_fin2925_cproc;
/
SHOW ERRORS;
