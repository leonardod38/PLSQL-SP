Prompt Package DPSP_RES_INTER_CPROC;
--
-- DPSP_RES_INTER_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dpsp_res_inter_cproc
IS
    -------------------------------------------------------------------------
    -- AUTOR    : DSP - REBELLO
    -- DATA     : V7 CRIADA EM 04/JUN/2018
    -- DESCRIÇÃO: Processamento do Ressarcimento Interestadual - Projeto 1007
    -------------------------------------------------------------------------
    -- UPDATE: Criação de rotina LOAD_GARE_REFUGO para cenario 0 (zero)
    -------------------------------------------------------------------------
    -- RELATÓRIOS PEOPLESOFT:
    --> PS_DSP_ITEM_LN_MVA / PSXLATITEM / PS_AR_IMP_BBL / PS_AR_NFRET_BBL / PS_AR_ITENS_NF_BBL / PS_DSP_OBR_PO_ST_T / PS_NF_LN_BRL

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
                      , p_cds lib_proc.vartab )
        RETURN INTEGER;
END dpsp_res_inter_cproc;
/
SHOW ERRORS;
