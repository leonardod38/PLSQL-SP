Prompt Package DPSP_FIN048_RET_ENTRADA_CPROC;
--
-- DPSP_FIN048_RET_ENTRADA_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dpsp_fin048_ret_entrada_cproc
IS
    -- Author  : Lucas Manarte - Accenture
    -- Created : 03/10/2018
    -- Purpose : Melhoria FIN048:
    -- Retificação da apuração do ICMS ES
    -- Relatório de Notas Fiscais de Entrada para retificacao apuração ICMS (ES).
    -- Primeira parte para o Processo 1 da EF

    -- AUTHOR  : LUCAS MANARTE - ACCENTURE
    -- CREATED : 03/10/2018
    -- PURPOSE : MELHORIA FIN048:
    -- RETIFICAÇÃO DA APURAÇÃO DO ICMS ES
    -- RELATÓRIO DE NOTAS FISCAIS DE ENTRADA PARA RETIFICACAO APURAÇÃO ICMS (ES).
    -- PRIMEIRA PARTE PARA O PROCESSO 1 DA EF

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
                      , pcod_estab VARCHAR2
                      , p_radio VARCHAR2 )
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
                        , pcod_estab VARCHAR2 );

    --PROCEDURE carrega_gtt(pdt_ini DATE, pdt_fim DATE, pcod_estab VARCHAR2);

    FUNCTION carregar_nf_entrada ( pdt_ini DATE
                                 , pdt_fim DATE
                                 , pcod_estab VARCHAR2
                                 , v_data_hora_ini VARCHAR2 )
        RETURN INTEGER;
END dpsp_fin048_ret_entrada_cproc;
/
SHOW ERRORS;
