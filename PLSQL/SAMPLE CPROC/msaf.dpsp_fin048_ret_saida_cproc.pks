Prompt Package DPSP_FIN048_RET_SAIDA_CPROC;
--
-- DPSP_FIN048_RET_SAIDA_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dpsp_fin048_ret_saida_cproc
IS
    -- Author  : Lucas Manarte - Accenture
    -- Created : 03/10/2018
    -- Purpose : Melhoria FIN048:
    -- Retifica��o da apura��o do ICMS ES
    -- Relat�rio de Notas Fiscais de Sa�da para retificacao apura��o ICMS (ES)

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
                      , pcod_estab VARCHAR2 )
        RETURN INTEGER;

    PROCEDURE loga ( p_i_texto IN VARCHAR2
                   , p_i_dttm IN BOOLEAN DEFAULT TRUE );

    PROCEDURE envia_email ( vp_cod_empresa IN VARCHAR2
                          , vp_data_ini IN DATE
                          , vp_data_fim IN DATE
                          , vp_msg_oracle IN VARCHAR2
                          , vp_tipo IN VARCHAR2
                          , vp_data_hora_ini IN VARCHAR2 );
--  FUNCTION CARREGAR_NF_ENTRADA(PDT_INI         DATE,
--                               PDT_FIM         DATE,
--                               PCOD_ESTAB      VARCHAR2,
--                               V_DATA_HORA_INI VARCHAR2) RETURN INTEGER;

END dpsp_fin048_ret_saida_cproc;
/
SHOW ERRORS;
