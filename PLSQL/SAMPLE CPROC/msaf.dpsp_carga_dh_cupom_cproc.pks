Prompt Package DPSP_CARGA_DH_CUPOM_CPROC;
--
-- DPSP_CARGA_DH_CUPOM_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dpsp_carga_dh_cupom_cproc
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

    PROCEDURE exec_cupom_parallel ( v_proc IN VARCHAR2
                                  , p_lote IN INTEGER
                                  , pdt_ini IN DATE
                                  , pdt_fim IN DATE
                                  , flg_cupom CHAR
                                  , flg_cupom_e CHAR
                                  , p_tab_partition IN VARCHAR2
                                  , v_data_exec IN DATE );

    PROCEDURE exec_cupom ( p_part_ini INTEGER
                         , p_part_fim INTEGER
                         , p_proc_instance VARCHAR2
                         , pcod_empresa VARCHAR2
                         , pdt_ini DATE
                         , pdt_fim DATE
                         , p_tab_partition IN VARCHAR2 );

    PROCEDURE exec_cupom_e ( p_part_ini INTEGER
                           , p_part_fim INTEGER
                           , p_proc_instance VARCHAR2
                           , pcod_empresa VARCHAR2
                           , pdt_ini DATE
                           , pdt_fim DATE
                           , p_data_exec DATE
                           , p_tab_partition IN VARCHAR2 );

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
                      , flg_cupom CHAR
                      , flg_cupom_e CHAR
                      , pcod_estado VARCHAR2
                      , pcod_estab lib_proc.vartab )
        RETURN INTEGER;
END dpsp_carga_dh_cupom_cproc;
/
SHOW ERRORS;
