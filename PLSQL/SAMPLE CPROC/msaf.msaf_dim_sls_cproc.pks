Prompt Package MSAF_DIM_SLS_CPROC;
--
-- MSAF_DIM_SLS_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE msaf_dim_sls_cproc
IS
    -- Autor         : Leandro Pavan
    -- Created       : 27/09/2005
    -- Purpose       : Gera��o do arquivo para entrega da DIM - S�o Luis, conforme layout fornecido pela prefeitura

    /* VARI�VEIS DE CONTROLE DE CABE�ALHO DE RELAT�RIO */

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

    FUNCTION executar ( pcd_estab VARCHAR2
                      , pdt_inicio DATE
                      , pdt_final DATE )
        RETURN INTEGER;
END msaf_dim_sls_cproc;
/
SHOW ERRORS;
