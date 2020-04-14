Prompt Package DPSP_FIN628_PERDAS_CD_CPROC;
--
-- DPSP_FIN628_PERDAS_CD_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dpsp_fin628_perdas_cd_cproc
IS
    -------------------------------------------------------------------------
    -- AUTOR    : DSP - Guilherme Silva
    -- DATA     : V7 CRIADA EM 10/Dezembro/2018
    -- DESCRIÇÃO: Processamento do Relatório de Perdas - Projeto FIN 628
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
END dpsp_fin628_perdas_cd_cproc;
/
SHOW ERRORS;
