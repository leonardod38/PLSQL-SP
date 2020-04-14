Prompt Package DPSP_FIN2700_CRED_OT_CPROC;
--
-- DPSP_FIN2700_CRED_OT_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dpsp_fin2700_cred_ot_cproc
IS
    -- AUTOR    : Accenture - Guilherme Silva
    -- DATA     : V4 CRIADA EM 18/ABRIL/2019
    -- DESCRIÇÃO: Projeto FIN 1952 - Relatório Conciliação Mastersaf Saídas x Entradas
    ------------------------------------------------------------------------------------------------
    -- AUTOR    : Accenture - Lucas Manarte
    -- DATA     : V5-6 CRIADA EM 23/OUTUBRO/2019
    -- DESCRIÇÃO: Alteração do VALOR DO ESTORNO DE CRÉDITO
    ------------------------------------------------------------------------------------------------
    -- AUTOR    : Accenture - Lucas Manarte
    -- DATA     : V7-V8 CRIADA EM 14/NOVEMBRO/2019
    -- DESCRIÇÃO: Percentual PROTEGE, novos CFOPs de exceção em casos de saídas interestaduais e
    -- alteração do cálculo do Valor Líquido
    ------------------------------------------------------------------------------------------------

    mcod_empresa empresa.cod_empresa%TYPE;
    mcod_usuario usuario_empresa.cod_usuario%TYPE;

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
                      , p_ind_medi VARCHAR2
                      , p_pct_protege VARCHAR2
                      , p_lojas lib_proc.vartab )
        RETURN INTEGER;
END dpsp_fin2700_cred_ot_cproc;
/
SHOW ERRORS;
