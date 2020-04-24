CREATE OR REPLACE PACKAGE msaf.dpsp_v3_fin4816_prev_cproc
IS
    -- =======================================
    -- Type  fiscal / reinf . r-2010
    -- =======================================
  


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


END dpsp_v3_fin4816_prev_cproc;
/