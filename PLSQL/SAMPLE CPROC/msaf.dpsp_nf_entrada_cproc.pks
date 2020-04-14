Prompt Package DPSP_NF_ENTRADA_CPROC;
--
-- DPSP_NF_ENTRADA_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dpsp_nf_entrada_cproc
IS
    -- Author  : Lucas Manarte - Accenture
    -- Created : 11/01/2019
    -- Purpose : Carregar Notas de Entrada

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

    FUNCTION executar ( pperiodo DATE
                      , pcod_estado VARCHAR2
                      , pcod_estab lib_proc.vartab )
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
                        , v_data_inicial DATE
                        , v_data_final DATE
                        , pcod_estado VARCHAR2 );

    FUNCTION carregar_nf_entrada ( v_data_inicial DATE
                                 , v_data_final DATE
                                 , pcod_estab VARCHAR2
                                 , v_data_hora_ini VARCHAR2 )
        RETURN INTEGER;

    PROCEDURE equalizacao_diaria;
END dpsp_nf_entrada_cproc;
/
SHOW ERRORS;
