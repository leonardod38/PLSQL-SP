Prompt Package DPSP_FIN151_CAT42_FICHAS_CPROC;
--
-- DPSP_FIN151_CAT42_FICHAS_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dpsp_fin151_cat42_fichas_cproc
IS
    -- AUTHOR  : LUCAS MANARTE - ACCENTURE
    -- CREATED : 17/09/2018
    -- PURPOSE : MELHORIA FIN151:
    -- PROCESSAMENTO DOS DOCUMENTOS NECESSÁRIOS PARA A CAT 42
    -- CHANGE: ADIÇÂO DE THREADS PARA OTIMIZAR PROCESSAMENTO - REBELLO / ACCENTURE - 14/03/2019

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

    FUNCTION orientacao
        RETURN VARCHAR2;

    FUNCTION executar ( flg_arq CHAR
                      , pdt_ini DATE
                      , p_thread VARCHAR2
                      , flg_dw CHAR
                      , flg_utl CHAR
                      , pdiretorio VARCHAR2
                      , flg_audit CHAR
                      , p_extrair CHAR
                      , ptipo CHAR
                      , pcod_estado VARCHAR2
                      , pcod_estab lib_proc.vartab )
        RETURN INTEGER;

    PROCEDURE save_tmp_control ( vp_proc_id IN INTEGER
                               , vp_proc_instance IN NUMBER
                               , vp_table_name IN VARCHAR2 );

    PROCEDURE drop_old_tmp ( vp_proc_instance IN NUMBER );

    PROCEDURE delete_temp_tbl ( vp_proc_id IN NUMBER );

    PROCEDURE loga ( p_i_texto IN VARCHAR2
                   , p_i_dttm IN BOOLEAN DEFAULT TRUE );

    PROCEDURE cabecalho ( pnm_empresa VARCHAR2
                        , pcnpj VARCHAR2
                        , flg_arq CHAR
                        , pdt_ini DATE
                        , pcod_estado VARCHAR2
                        , v_data_hora_ini VARCHAR2 );

    PROCEDURE envia_email ( vp_cod_empresa IN VARCHAR2
                          , vp_data_ini IN DATE
                          , vp_data_fim IN DATE
                          , vp_msg_oracle IN VARCHAR2
                          , vp_tipo IN VARCHAR2
                          , vp_data_hora_ini IN VARCHAR2 );

    PROCEDURE loga_directory_path ( pdesc VARCHAR2
                                  , pdiretorio VARCHAR2
                                  , parquivo VARCHAR2 );

    PROCEDURE ficha1_verificar ( pcod_estab VARCHAR2
                               , pdt_ini DATE
                               , pdt_fim DATE
                               , pdt_periodo INTEGER
                               , v_data_hora_ini VARCHAR2 );

    PROCEDURE ficha1_gerar ( pdt_ini DATE
                           , pdt_fim DATE
                           , pdt_periodo INTEGER
                           , v_data_hora_ini VARCHAR2 );

    PROCEDURE ficha1_extrair ( flg_dw CHAR
                             , flg_utl CHAR
                             , pdiretorio VARCHAR2
                             , parquivo VARCHAR2
                             , pdt_periodo INTEGER );

    PROCEDURE ficha2_gerar ( p_proc_instance VARCHAR2
                           , pcod_estab lib_proc.vartab
                           , ptipo CHAR
                           , pdt_ini DATE
                           , pdt_fim DATE
                           , pdt_periodo INTEGER
                           , v_data_hora_ini VARCHAR2 );

    PROCEDURE ficha2_carregar ( pdt_ini DATE
                              , pdt_fim DATE
                              , pdt_periodo INTEGER
                              , v_data_hora_ini VARCHAR2
                              , p_i_tipo VARCHAR2
                              , p_i_cod_estab lib_proc.vartab );

    PROCEDURE ficha2_create_tables ( vp_proc_instance IN VARCHAR2
                                   , vp_tab_estabs   OUT VARCHAR2
                                   , vp_tab_entrada_ini   OUT VARCHAR2
                                   , vp_tab_produtos   OUT VARCHAR2 );

    PROCEDURE ficha2_load_entradas ( pcod_estab IN VARCHAR2
                                   , vp_tab_entrada_ini IN VARCHAR2
                                   , vp_tab_estabs IN VARCHAR
                                   , vp_data_ini IN DATE
                                   , vp_data_fim IN DATE
                                   , vp_data_hora_ini IN VARCHAR2
                                   , pproc_id IN INTEGER );

    PROCEDURE ficha2_load_produtos ( vp_proc_instance IN VARCHAR2
                                   , vp_tab_produtos IN VARCHAR2
                                   , vp_tab_entrada_ini IN VARCHAR2
                                   , vp_data_ini IN DATE
                                   , vp_data_fim IN DATE
                                   , vp_data_hora_ini IN VARCHAR2 );

    PROCEDURE ficha2_extrair ( flg_dw CHAR
                             , flg_utl CHAR
                             , pdiretorio VARCHAR2
                             , parquivo VARCHAR2
                             , pdt_periodo INTEGER );

    PROCEDURE ficha3_gerar ( p_proc_instance VARCHAR2
                           , pcod_estab VARCHAR2
                           , pdt_ini DATE
                           , pdt_fim DATE
                           , pdt_periodo INTEGER
                           , v_data_hora_ini VARCHAR2 );

    PROCEDURE ficha3_load_entradas ( vp_proc_instance IN VARCHAR2
                                   , vp_tab_entrada_ini IN VARCHAR2
                                   , vp_data_ini IN DATE
                                   , vp_data_fim IN DATE
                                   , vp_data_hora_ini IN VARCHAR2
                                   , pcod_estab IN VARCHAR2 );

    PROCEDURE ficha3_load_produtos ( vp_proc_instance IN VARCHAR2
                                   , vp_tab_produtos IN VARCHAR2
                                   , vp_tab_entrada_ini IN VARCHAR2
                                   , vp_data_ini IN DATE
                                   , vp_data_fim IN DATE
                                   , vp_data_hora_ini IN VARCHAR2
                                   , pcod_estab IN VARCHAR2
                                   , v_qtde_prod   OUT INTEGER );

    PROCEDURE ficha3_extrair ( flg_dw CHAR
                             , flg_utl CHAR
                             , pdiretorio VARCHAR2
                             , parquivo VARCHAR2
                             , pdt_periodo INTEGER );

    PROCEDURE ficha4_gerar ( p_part_ini INTEGER
                           , p_part_fim INTEGER
                           , p_proc_instance VARCHAR2
                           , flg_audit CHAR
                           , pdt_ini DATE
                           , pdt_fim DATE
                           , pdt_periodo INTEGER
                           , v_data_hora_ini VARCHAR2
                           , p_tab_produtos VARCHAR2
                           , p_tab_nfret VARCHAR2
                           , p_tab_partition VARCHAR2
                           , p_user VARCHAR2 );

    PROCEDURE ficha4_mov ( v_cod_estab VARCHAR2
                         , pdt_ini DATE
                         , pdt_fim DATE
                         , pdt_periodo INTEGER
                         , v_data_hora_ini VARCHAR2
                         , p_proc_id INTEGER
                         , p_user VARCHAR2
                         , v_tipo VARCHAR2
                         , v_tab_mov VARCHAR2 );

    PROCEDURE ult_entrada_vero ( p_cod_estab VARCHAR2
                               , pdt_periodo INTEGER
                               , p_tab_mov VARCHAR2 );

    PROCEDURE ult_entrada_people ( vp_proc_id IN VARCHAR2
                                 , pcod_estab IN VARCHAR2
                                 , pdt_periodo IN INTEGER
                                 , v_tab_nfret IN VARCHAR2
                                 , vp_tipo IN VARCHAR2
                                 , vp_tab_nf IN VARCHAR2
                                 , p_tab_mov IN VARCHAR2 );

    PROCEDURE ficha4_extrair ( flg_dw CHAR
                             , flg_utl CHAR
                             , pdiretorio VARCHAR2
                             , parquivo VARCHAR2
                             , pdt_periodo INTEGER
                             , pid_arquivo INTEGER
                             , pcod_estab VARCHAR2
                             , flg_cd VARCHAR2
                             , p_proc_id INTEGER );

    PROCEDURE ficha4_auditoria ( flg_dw CHAR
                               , flg_utl CHAR
                               , pdiretorio VARCHAR2
                               , parquivo VARCHAR2
                               , pdt_periodo INTEGER
                               , pid_arquivo INTEGER
                               , pcod_estab VARCHAR2
                               , flg_cd VARCHAR2
                               , p_proc_id INTEGER );

    PROCEDURE ficha5_gerar ( pcod_estab VARCHAR2
                           , pdt_ini DATE
                           , pdt_fim DATE
                           , pdt_periodo INTEGER
                           , v_data_hora_ini VARCHAR2
                           , v_tipo VARCHAR2 );

    PROCEDURE ficha5_extrair ( flg_dw CHAR
                             , flg_utl CHAR
                             , pdiretorio VARCHAR2
                             , parquivo VARCHAR2
                             , pdt_periodo INTEGER
                             , p_cod_estab VARCHAR2 );

    FUNCTION create_tab_partition ( vp_proc_id IN VARCHAR2
                                  , vp_cod_estab IN lib_proc.vartab )
        RETURN VARCHAR2;

    FUNCTION create_tab_produto ( vp_proc_id IN VARCHAR2 )
        RETURN VARCHAR2;

    FUNCTION create_tab_nfret ( vp_proc_id IN VARCHAR2 )
        RETURN VARCHAR2;

    PROCEDURE exec_ficha4_parallel ( v_proc IN VARCHAR2
                                   , p_lote IN INTEGER
                                   , v_nm_tabela IN VARCHAR2
                                   , flg_audit IN VARCHAR2
                                   , pdt_ini IN DATE
                                   , pdt_fim IN DATE
                                   , pdt_periodo IN INTEGER
                                   , v_data_hora_ini IN VARCHAR2
                                   , p_tab_produtos IN VARCHAR2
                                   , p_tab_nfret IN VARCHAR2
                                   , p_tab_partition IN VARCHAR2 );

    PROCEDURE get_anvisa_info ( vp_proc_id IN INTEGER
                              , v_tab_anvisa IN VARCHAR2
                              , v_tab_produtos IN VARCHAR2 );

    PROCEDURE upd_vlr_pmc ( vp_proc_id IN INTEGER
                          , p_cod_estab IN VARCHAR2
                          , p_periodo IN INTEGER
                          , vp_tab_pmc IN VARCHAR2
                          , p_tab_mov IN VARCHAR2 );

    PROCEDURE get_cd_to_loja_xml ( p_cod_estab IN VARCHAR2
                                 , pdt_periodo IN INTEGER
                                 , p_tab_mov IN VARCHAR2 );

    PROCEDURE get_loja_loja_ult ( p_cod_estab IN VARCHAR2
                                , p_periodo IN INTEGER
                                , p_tab_mov IN VARCHAR2 );
END dpsp_fin151_cat42_fichas_cproc;
/
SHOW ERRORS;
