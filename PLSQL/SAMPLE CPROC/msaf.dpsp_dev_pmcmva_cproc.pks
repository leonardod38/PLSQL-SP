Prompt Package DPSP_DEV_PMCMVA_CPROC;
--
-- DPSP_DEV_PMCMVA_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dpsp_dev_pmcmva_cproc
IS
    -------------------------------------------------------------------------
    -- AUTOR    : DSP - Guilherme Silva
    -- DATA     : V5 CRIADA EM 16/Abril/2018
    -- DESCRIÇÃO: Processamento Relatório de devolução_PMC x MVA
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
END dpsp_dev_pmcmva_cproc;
/
SHOW ERRORS;
