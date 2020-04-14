Prompt Package CST_REL_CONF_SAP_CPROC;
--
-- CST_REL_CONF_SAP_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE cst_rel_conf_sap_cproc
IS
    musuario usuario_empresa.cod_usuario%TYPE;

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

    FUNCTION executar ( p_data_ini DATE
                      , p_data_fim DATE
                      , p_id_processo VARCHAR2 )
        RETURN INTEGER;
END cst_rel_conf_sap_cproc;
/
SHOW ERRORS;
