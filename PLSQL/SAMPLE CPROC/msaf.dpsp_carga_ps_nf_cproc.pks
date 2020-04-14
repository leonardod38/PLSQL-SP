Prompt Package DPSP_CARGA_PS_NF_CPROC;
--
-- DPSP_CARGA_PS_NF_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dpsp_carga_ps_nf_cproc
IS
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

    PROCEDURE loga ( p_i_texto IN VARCHAR2
                   , p_i_dttm IN BOOLEAN DEFAULT TRUE );

    PROCEDURE exec_nf_parallel ( v_proc IN VARCHAR2
                               , p_lote IN INTEGER
                               , pdt_ini IN DATE
                               , pdt_fim IN DATE
                               , flg_nf_ent CHAR
                               , flg_nf_sai CHAR
                               , p_tab_partition IN VARCHAR2
                               , v_data_exec IN DATE );

    PROCEDURE exec_nf_ent ( p_part_ini INTEGER
                          , p_part_fim INTEGER
                          , p_proc_instance VARCHAR2
                          , pcod_empresa VARCHAR2
                          , pdt_ini DATE
                          , pdt_fim DATE
                          , p_tab_partition IN VARCHAR2
                          , v_data_exec IN DATE
                          , p_carga_po IN VARCHAR2
                          , p_carga_auditoria IN VARCHAR2
                          , v_c_safx07 IN VARCHAR2
                          , v_c_safx08 IN VARCHAR2
                          , v_c_safx03 IN VARCHAR2
                          , v_c_safx301 IN VARCHAR2
                          , v_c_safx112 IN VARCHAR2 );

    PROCEDURE exec_nf_sai ( p_part_ini INTEGER
                          , p_part_fim INTEGER
                          , p_proc_instance VARCHAR2
                          , pcod_empresa VARCHAR2
                          , pdt_ini DATE
                          , pdt_fim DATE
                          , p_tab_partition IN VARCHAR2
                          , v_data_exec IN DATE
                          , p_uso_consumo VARCHAR2
                          , p_cagadas VARCHAR2
                          , p_vira_ignora_ps VARCHAR2
                          , p_carga_auditoria VARCHAR2
                          , v_c_safx07 VARCHAR2
                          , v_c_safx08 VARCHAR2
                          , v_c_safx112 VARCHAR2
                          , v_c_safx116 VARCHAR2
                          , v_c_safx117 VARCHAR2
                          , v_c_safx119 VARCHAR2 );

    PROCEDURE arq_log_erro ( pcod_empresa VARCHAR2
                           , pdt_ini DATE
                           , v_proc VARCHAR2
                           , v_cd_arquivo INTEGER
                           , v_data_exec DATE );

    FUNCTION create_tab_partition ( vp_proc_id IN VARCHAR2
                                  , vp_cod_estab IN lib_proc.vartab )
        RETURN VARCHAR2;

    FUNCTION executar ( pcod_empresa VARCHAR2
                      , pdt_ini DATE
                      , pdt_fim DATE
                      , pthread VARCHAR2
                      , flg_nf_ent CHAR
                      , flg_nf_sai CHAR
                      , pcod_estado VARCHAR2
                      , pcod_estab lib_proc.vartab )
        RETURN INTEGER;
END dpsp_carga_ps_nf_cproc;
/
SHOW ERRORS;
