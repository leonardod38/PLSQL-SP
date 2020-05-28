CREATE OR REPLACE PACKAGE MSAF.dpsp_v4_fin4816_prev_cproc
IS
    -- =======================================
    -- Type  fiscal / reinf . r-2010
    -- =======================================
    TYPE array_fiscal IS TABLE OF msafi.tb_fin4816_report_fiscal_gtt%ROWTYPE;
    l_data_fiscal array_fiscal;

    TYPE array_reinf IS TABLE OF msafi.tb_fin4816_reinf_prev_gtt%ROWTYPE;
    l_data_reinf array_reinf;

    TYPE array_r2010 IS TABLE OF msafi.tb_fin4816_reinf_2010_gtt%ROWTYPE;
    l_data_r2010 array_r2010;

    TYPE array_apoio IS TABLE OF msafi.tb_fin4816_rel_apoio_fiscal%ROWTYPE;
    l_data_rel_apoio array_apoio;


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


--    PROCEDURE carga ( pnr_particao INTEGER
--                    , pnr_particao2 INTEGER
--                    , p_data_ini DATE
--                    , p_data_fim DATE
--                    , p_proc_id VARCHAR2
--                    , p_nm_empresa VARCHAR2
--                    , p_nm_usuario VARCHAR2 );

END dpsp_v4_fin4816_prev_cproc;
/