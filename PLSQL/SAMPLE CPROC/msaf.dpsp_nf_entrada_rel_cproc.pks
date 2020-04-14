Prompt Package DPSP_NF_ENTRADA_REL_CPROC;
--
-- DPSP_NF_ENTRADA_REL_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dpsp_nf_entrada_rel_cproc
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
                      , pprocessar VARCHAR2
                      , prelatorio VARCHAR2 )
        RETURN INTEGER;

    PROCEDURE loga ( p_i_texto IN VARCHAR2
                   , p_i_dttm IN BOOLEAN DEFAULT TRUE );

    PROCEDURE envia_email ( vp_cod_empresa IN VARCHAR2
                          , vp_data_ini IN DATE
                          , vp_data_fim IN DATE
                          , vp_msg_oracle IN VARCHAR2
                          , vp_tipo IN VARCHAR2
                          , vp_data_hora_ini IN VARCHAR2 );
END dpsp_nf_entrada_rel_cproc;
/
SHOW ERRORS;
