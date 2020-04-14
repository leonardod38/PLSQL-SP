Prompt Package DPSP_FIN2700_CRED_OT_CPROC;
--
-- DPSP_FIN2700_CRED_OT_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dpsp_fin2700_cred_ot_cproc
IS
    -- AUTOR    : Accenture - Guilherme Silva
    -- DATA     : V4 CRIADA EM 18/ABRIL/2019
    -- DESCRI��O: Projeto FIN 1952 - Relat�rio Concilia��o Mastersaf Sa�das x Entradas
    ------------------------------------------------------------------------------------------------
    -- AUTOR    : Accenture - Lucas Manarte
    -- DATA     : V5-6 CRIADA EM 23/OUTUBRO/2019
    -- DESCRI��O: Altera��o do VALOR DO ESTORNO DE CR�DITO
    ------------------------------------------------------------------------------------------------
    -- AUTOR    : Accenture - Lucas Manarte
    -- DATA     : V7-V8 CRIADA EM 14/NOVEMBRO/2019
    -- DESCRI��O: Percentual PROTEGE, novos CFOPs de exce��o em casos de sa�das interestaduais e
    -- altera��o do c�lculo do Valor L�quido
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
