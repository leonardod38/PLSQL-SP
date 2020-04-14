Prompt Package MSAF_PRODEPE_CPROC;
--
-- MSAF_PRODEPE_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE msaf_prodepe_cproc
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
                      , v_processa_rateio VARCHAR2
                      , v_relatotorio_nf_emitidas VARCHAR2
                      , v_relatotorio_analitico_rateio VARCHAR2
                      , v_relatotorio_sintetico_rateio VARCHAR2
                      , pcod_estab VARCHAR2 --lib_proc.vartab
                                            )
        RETURN INTEGER;

    PROCEDURE loga ( p_i_texto IN VARCHAR2
                   , p_i_dttm IN BOOLEAN DEFAULT TRUE );

    PROCEDURE cabecalho ( pcod_estab VARCHAR2
                        , v_data_hora_ini VARCHAR2
                        , v_data_inicial DATE
                        , v_tipo VARCHAR2 );
END msaf_prodepe_cproc;
/
SHOW ERRORS;
