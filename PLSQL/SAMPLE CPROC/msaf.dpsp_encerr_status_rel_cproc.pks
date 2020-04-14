Prompt Package DPSP_ENCERR_STATUS_REL_CPROC;
--
-- DPSP_ENCERR_STATUS_REL_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dpsp_encerr_status_rel_cproc
IS
    -- Author  : Lucas Manarte - Accenture
    -- Created : 26/09/2018
    -- Purpose : Utilizar nas melhorias FIN275 e FIN276
    -- Encerramento de Status para Relatórios

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
                      , pcd_cproc VARCHAR2
                      , pcod_estado VARCHAR2
                      , flg_acao CHAR
                      , pstatus VARCHAR2
                      , flg_arquivo CHAR
                      , pcod_estab lib_proc.vartab )
        RETURN INTEGER;

    PROCEDURE loga ( p_i_texto IN VARCHAR2
                   , p_i_dttm IN BOOLEAN DEFAULT TRUE );

    PROCEDURE cabecalho ( pnm_empresa VARCHAR2
                        , pcnpj VARCHAR2
                        , v_data_hora_ini VARCHAR2
                        , pnm_cproc VARCHAR2
                        , pnm_tipo VARCHAR2 );

    PROCEDURE imprimir ( pdt_periodo NUMBER
                       , pcod_estab VARCHAR2
                       , pcd_cproc VARCHAR2 );

    PROCEDURE gerar_arquivo ( pdt_periodo NUMBER
                            , pcod_estab VARCHAR2
                            , pcd_cproc VARCHAR2 );
END dpsp_encerr_status_rel_cproc;
/
SHOW ERRORS;
