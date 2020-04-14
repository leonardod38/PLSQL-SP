Prompt Package DPSP_EX_PIS_COFINS_CPROC;
--
-- DPSP_EX_PIS_COFINS_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dpsp_ex_pis_cofins_cproc
IS
    -- AUTOR    : DSP - RODOLFO
    -- DATA     : CRIADA EM 29/NOV/2017
    -- DESCRIÇÃO: PROJETO 930

    -- V9 CRIADA EM 12/12/2018: REBELLO - VERSAO ATUAL NA PRD EM 12/12/2018
    -- V10 CRIADA EM 21/01/2019: Lucas Manarte - FIN-1647 - Relatório de Exclusão ICMS da base do PISCOFINS (2008 a 2014)
    -- V11 CRIADA EM 02/09/2019: Lucas Manarte - Ajuste na performance da extração do Relatório analítico.
    -- V12 CRIADA EM 16/09/2019: Lucas Manarte - Ajuste da Trava do Período.
    -- V13 CRIADA EM 21/01/2020: Jorge Oliveira - Ajuste de calculo e melhoria de perfomance - FIN9458

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
                            , p_empresa VARCHAR2
                            , p_usuario VARCHAR2
                            , p_procorig VARCHAR2
                            , p_lojas lib_proc.vartab );

    FUNCTION executar ( p_data_ini DATE
                      , p_data_fim DATE
                      , p_uf VARCHAR2
                      , p_lojas lib_proc.vartab )
        RETURN INTEGER;

    PROCEDURE load_saidas ( pnr_particao INTEGER
                          , vp_proc_instance IN VARCHAR2
                          , vp_data_ini IN DATE
                          , vp_data_fim IN DATE
                          , vp_tabela_saida IN VARCHAR2
                          , vp_proc_id INTEGER
                          , pcod_empresa VARCHAR2 );

    PROCEDURE load_entradas ( pnr_particao INTEGER
                            , vp_proc_instance IN VARCHAR2
                            , vp_origem IN VARCHAR2
                            , vp_cod_cd IN VARCHAR2
                            , vp_tabela_entrada IN VARCHAR2
                            , vp_tabela_saida IN VARCHAR2
                            , vp_data_inicio IN VARCHAR2
                            , vp_data_fim IN VARCHAR2
                            , vp_proc_id INTEGER
                            , pcod_empresa VARCHAR2 );

    PROCEDURE load_get_entrada ( pnr_particao INTEGER
                               , p_proc_instance IN VARCHAR2
                               , v_data_inicial IN DATE
                               , v_data_final IN DATE
                               , p_cd1 IN VARCHAR2
                               , p_origem1 IN VARCHAR2
                               , p_cd2 IN VARCHAR2
                               , p_origem2 IN VARCHAR2
                               , p_cd3 IN VARCHAR2
                               , p_origem3 IN VARCHAR2
                               , p_cd4 IN VARCHAR2
                               , p_origem4 IN VARCHAR2
                               , p_cd5 IN VARCHAR2
                               , p_origem5 IN VARCHAR2
                               , p_direta IN VARCHAR2
                               , v_tab_entrada_f IN VARCHAR2
                               , v_tab_entrada_c IN VARCHAR2
                               , v_tab_entrada_co IN VARCHAR2
                               , v_tabela_saida IN VARCHAR2
                               , v_tabela_nf IN VARCHAR2
                               , v_tabela_ult_entrada IN VARCHAR2
                               , vp_proc_id INTEGER
                               , pcod_empresa VARCHAR2 );
END dpsp_ex_pis_cofins_cproc;
/
SHOW ERRORS;
