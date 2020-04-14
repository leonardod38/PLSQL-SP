Prompt Package DPSP_PMC_X_MVA_NEW_CPROC;
--
-- DPSP_PMC_X_MVA_NEW_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dpsp_pmc_x_mva_new_cproc
IS
    -- AUTOR    : DSP - REBELLO
    -- DATA     : V11 CRIADA EM 03/MAI/2018
    -- DESCRIÇÃO: Processamento PMC x MVA - melhoria de performance

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
                      , p_origem1 VARCHAR2
                      , p_cd1 VARCHAR2
                      , p_origem2 VARCHAR2
                      , p_cd2 VARCHAR2
                      , p_origem3 VARCHAR2
                      , p_cd3 VARCHAR2
                      , p_origem4 VARCHAR2
                      , p_cd4 VARCHAR2
                      , p_compra_direta VARCHAR2
                      , p_uf VARCHAR2
                      , p_lojas lib_proc.vartab )
        RETURN INTEGER;
END dpsp_pmc_x_mva_new_cproc;
/
SHOW ERRORS;
