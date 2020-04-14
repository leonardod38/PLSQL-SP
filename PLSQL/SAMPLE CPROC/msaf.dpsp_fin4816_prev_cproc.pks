Prompt Package DPSP_FIN4816_PREV_CPROC;
--
-- DPSP_FIN4816_PREV_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dpsp_fin4816_prev_cproc
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

    PROCEDURE carga ( pnr_particao INTEGER
                    , pnr_particao2 INTEGER
                    , p_data_ini DATE
                    , p_data_fim DATE
                    , p_proc_id VARCHAR2
                    , p_nm_empresa VARCHAR2
                    , p_nm_usuario VARCHAR2 );
--FUNCTION moeda(v_conteudo NUMBER) RETURN VARCHAR2 ;
END dpsp_fin4816_prev_cproc;
/
SHOW ERRORS;
