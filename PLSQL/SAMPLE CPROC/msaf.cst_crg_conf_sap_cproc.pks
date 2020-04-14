Prompt Package CST_CRG_CONF_SAP_CPROC;
--
-- CST_CRG_CONF_SAP_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE cst_crg_conf_sap_cproc
IS
    -- AUTOR    : Accenture - Lucas Manarte
    -- DATA     : V1 CRIADA EM 11/02/2020
    -- DESCRIÇÃO: Relatório de confronto de NFs do SAP x Mastersaf DW

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

    FUNCTION split ( v_texto VARCHAR2
                   , v_coluna INTEGER
                   , v_separador VARCHAR2 )
        RETURN VARCHAR2;

    PROCEDURE load_tmp_layout ( v_proc_id NUMBER );

    FUNCTION executar ( pdt_ini DATE
                      , pdt_fim DATE
                      , pdiretory VARCHAR2
                      , pfile_archive VARCHAR2 )
        RETURN INTEGER;
END cst_crg_conf_sap_cproc;
/
SHOW ERRORS;
