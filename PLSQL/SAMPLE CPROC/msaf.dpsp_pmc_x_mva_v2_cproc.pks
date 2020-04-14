Prompt Package DPSP_PMC_X_MVA_V2_CPROC;
--
-- DPSP_PMC_X_MVA_V2_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dpsp_pmc_x_mva_v2_cproc
IS
    -- AUTOR    : ACCENTURE - REBELLO
    -- DATA     : NOVA VERSAO V1 CRIADA EM 12/FEV/2019
    -- DESCRIÇÃO: Processamento PMC x MVA - Melhoria Performance
    -- TABELAS PEOPLESOFT UTILIZADAS:
    --> PS_DSP_ITEM_LN_MVA / PSXLATITEM / PS_DSP_PRECO_ITEM / PS_ATRB_OPER_DSP / PS_NF_LN_BRL / PS_ATRB_OP_EFF_DSP

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

    PROCEDURE executar_lote ( p_data_ini DATE
                            , p_data_fim DATE
                            , p_rel VARCHAR2
                            , p_uf VARCHAR2
                            , p_perfil VARCHAR2
                            , p_empresa VARCHAR2
                            , p_usuario VARCHAR2
                            , p_procorig VARCHAR2
                            , p_lojas lib_proc.vartab );

    FUNCTION executar ( p_data_ini DATE
                      , p_data_fim DATE
                      , p_uf VARCHAR2
                      , p_perfil VARCHAR2
                      , p_log VARCHAR2
                      , p_lojas lib_proc.vartab )
        RETURN INTEGER;
END dpsp_pmc_x_mva_v2_cproc;
/
SHOW ERRORS;
