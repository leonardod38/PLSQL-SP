CREATE OR REPLACE PACKAGE MSAF.dpsp_fin4816_prev_cproc
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

    FUNCTION executar ( pdata_inicial DATE
                      , pdata_final DATE
                      -- , pcod_estado VARCHAR2
                      , pcod_estab lib_proc.vartab )
        RETURN INTEGER;
        
        
--   PROCEDURE prc_reinf_conf_retencao (  p_cod_empresa IN VARCHAR2
--                                      , p_cod_estab IN VARCHAR2 DEFAULT NULL
--                                      , p_tipo_selec IN VARCHAR2
--                                      , p_data_inicial IN DATE
--                                      , p_data_final IN DATE
--                                      , p_cod_usuario IN VARCHAR2
--                                      , p_entrada_saida IN VARCHAR2
--                                      , p_status   OUT NUMBER
--                                      , p_proc_id IN VARCHAR2 DEFAULT NULL );
                                      

    PROCEDURE carga ( pnr_particao INTEGER
                    , pnr_particao2 INTEGER
                    , p_data_ini DATE
                    , p_data_fim DATE
                    , p_proc_id VARCHAR2
                    , p_nm_empresa VARCHAR2
                    , p_nm_usuario VARCHAR2 );
                    
--    PROCEDURE carga1 ( pnr_particao INTEGER
--                    , pnr_particao2 INTEGER
--                    , p_data_ini DATE
--                    , p_data_fim DATE
--                    , p_proc_id VARCHAR2
--                    , p_nm_empresa VARCHAR2
--                    , p_nm_usuario VARCHAR2 );

--FUNCTION moeda(v_conteudo NUMBER) RETURN VARCHAR2 ;
END dpsp_fin4816_prev_cproc;
/