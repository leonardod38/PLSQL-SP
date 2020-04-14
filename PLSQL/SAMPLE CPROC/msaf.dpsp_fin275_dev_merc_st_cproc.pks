Prompt Package DPSP_FIN275_DEV_MERC_ST_CPROC;
--
-- DPSP_FIN275_DEV_MERC_ST_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dpsp_fin275_dev_merc_st_cproc
IS
    -- Author  : Lucas Manarte - Accenture
    -- Created : 24/09/2018
    -- Purpose : Melhoria FIN275:
    -- Processamento para geração do Relatório de Devolução de Mercadorias com ICMS-ST

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

    FUNCTION executar ( pdt_ini DATE
                      , pdt_fim DATE
                      , pcod_cd VARCHAR2
                      , pcod_estado VARCHAR2
                      , pcod_filial lib_proc.vartab )
        RETURN INTEGER;

    PROCEDURE loga ( p_i_texto IN VARCHAR2
                   , p_i_dttm IN BOOLEAN DEFAULT TRUE );

    PROCEDURE envia_email ( vp_cod_empresa IN VARCHAR2
                          , vp_data_ini IN DATE
                          , vp_data_fim IN DATE
                          , vp_msg_oracle IN VARCHAR2
                          , vp_tipo IN VARCHAR2
                          , vp_data_hora_ini IN VARCHAR2 );

    PROCEDURE cabecalho ( pnm_empresa VARCHAR2
                        , pcnpj VARCHAR2
                        , v_data_hora_ini VARCHAR2
                        , mnm_cproc VARCHAR2
                        , pdt_ini DATE
                        , pdt_fim DATE
                        , pcod_cd VARCHAR2
                        , pcod_estado VARCHAR2 );

    FUNCTION carregar_dev_merc ( pdt_ini DATE
                               , pdt_fim DATE
                               , pcod_estab VARCHAR2
                               , v_data_hora_ini VARCHAR2 )
        RETURN INTEGER;

    PROCEDURE arquivo_analitico ( pcod_estab VARCHAR2
                                , pdt_ini DATE
                                , pdt_fim DATE
                                , v_cd_arquivo INTEGER );

    PROCEDURE arquivo_sintetico ( pcod_estab VARCHAR2
                                , pdt_ini DATE
                                , pdt_fim DATE
                                , v_cd_arquivo INTEGER );
END dpsp_fin275_dev_merc_st_cproc;
/
SHOW ERRORS;
