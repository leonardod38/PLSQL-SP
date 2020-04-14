Prompt Package DPSP_CONF_MSAF_SAP_CPROC;
--
-- DPSP_CONF_MSAF_SAP_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dpsp_conf_msaf_sap_cproc
IS
    -----------------------------------------
    -- BY ANDRE REBELLO (ACCENTURE)- JUL/2019
    -- PROJETO 1952 CAT42 MODULO MSAF
    -- CARGA SAFX265 ORIGEM ARQUIVO TXT
    -----------------------------------------

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

    FUNCTION recupera_campo ( v_texto VARCHAR2
                            , v_campo_desejado INTEGER )
        RETURN VARCHAR2;

    FUNCTION executar ( p_dir VARCHAR2
                      , p_file VARCHAR2
                      , p_data_inicio DATE
                      , p_data_fim DATE
                      , p_cod_estab lib_proc.vartab )
        RETURN INTEGER;
END dpsp_conf_msaf_sap_cproc;
/
SHOW ERRORS;
