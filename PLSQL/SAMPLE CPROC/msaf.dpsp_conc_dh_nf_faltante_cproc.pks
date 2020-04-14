Prompt Package DPSP_CONC_DH_NF_FALTANTE_CPROC;
--
-- DPSP_CONC_DH_NF_FALTANTE_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dpsp_conc_dh_nf_faltante_cproc
IS
    -- AUTOR    : Lucas Manarte - Accenture
    -- DATA     : CRIADO EM 02/09/2019
    -- DESCRIÇÃO: Comparativo / Confronto para notas fiscais faltantes entre Datahub e Mastersaf DW

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

    p_null_lojas lib_proc.vartab;

    PROCEDURE loga ( p_i_texto IN VARCHAR2
                   , p_i_dttm IN BOOLEAN DEFAULT TRUE );

    PROCEDURE envia_email ( vp_cod_empresa IN VARCHAR2
                          , vp_data_ini IN DATE
                          , vp_data_fim IN DATE
                          , vp_msg_oracle IN VARCHAR2
                          , vp_tipo IN VARCHAR2
                          , vp_data_hora_ini IN DATE );

    PROCEDURE load_gtt_dh ( p_cod_empresa VARCHAR2
                          , p_dt_ini DATE
                          , p_cod_estab VARCHAR2 );

    PROCEDURE load_falt_dh ( p_cod_empresa VARCHAR2
                           , v_periodo_dia DATE
                           , v_dt_first DATE
                           , p_cod_estab VARCHAR2
                           , v_proc_id NUMBER
                           , v_data_exec DATE
                           , v_usuario VARCHAR2 );

    PROCEDURE load_excel_dh ( p_cod_empresa VARCHAR2
                            , v_dt_ini DATE
                            , v_dt_fim DATE
                            , v_dt_first DATE
                            , p_cod_estab VARCHAR2
                            , p_carregar VARCHAR2
                            , v_data_exec DATE
                            , v_proc_id NUMBER );

    PROCEDURE exec_nf_parallel ( v_proc IN VARCHAR2
                               , p_flg_thread VARCHAR2
                               , p_lote IN INTEGER
                               , p_tab_partition IN VARCHAR2
                               , p_dt_ini DATE
                               , p_dt_fim DATE
                               , v_data_exec IN DATE );

    PROCEDURE exec_carga_ids ( p_part_ini INTEGER
                             , p_part_fim INTEGER
                             , p_proc_instance VARCHAR2
                             , p_proc_id VARCHAR2
                             , pcod_empresa VARCHAR2
                             , p_dt_ini DATE
                             , p_dt_fim DATE
                             , p_tab_partition IN VARCHAR2
                             , v_data_exec IN DATE );

    PROCEDURE exec_carga_lojas ( p_part_ini INTEGER
                               , p_part_fim INTEGER
                               , p_proc_instance VARCHAR2
                               , p_proc_id VARCHAR2
                               , pcod_empresa VARCHAR2
                               , p_dt_ini DATE
                               , p_dt_fim DATE
                               , p_tab_partition IN VARCHAR2
                               , v_data_exec IN DATE );

    PROCEDURE limpeza_gtts;

    PROCEDURE arq_log_erro ( pcod_empresa VARCHAR2
                           , pdt_ini DATE
                           , v_proc VARCHAR2
                           , v_cd_arquivo INTEGER
                           , v_data_exec DATE );

    FUNCTION create_tab_part_ids ( vp_proc_id IN VARCHAR2 )
        RETURN VARCHAR2;

    FUNCTION create_tab_part_lojas ( vp_proc_id IN VARCHAR2
                                   , vp_cod_estab IN lib_proc.vartab )
        RETURN VARCHAR2;

    FUNCTION executar ( p_dt_ini DATE
                      , p_dt_fim DATE
                      , p_todos_estab VARCHAR2
                      , p_busca VARCHAR2
                      , p_uf VARCHAR2 DEFAULT NULL
                      , p_carregar VARCHAR2
                      , p_flg_thread VARCHAR2
                      , p_num_thread VARCHAR2
                      , p_lojas lib_proc.vartab DEFAULT p_null_lojas )
        RETURN INTEGER;
END dpsp_conc_dh_nf_faltante_cproc;
/
SHOW ERRORS;
