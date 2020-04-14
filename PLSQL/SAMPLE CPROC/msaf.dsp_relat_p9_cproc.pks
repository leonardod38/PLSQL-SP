Prompt Package DSP_RELAT_P9_CPROC;
--
-- DSP_RELAT_P9_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dsp_relat_p9_cproc
IS
    FUNCTION parametros
        RETURN VARCHAR2;

    FUNCTION nome
        RETURN VARCHAR2;

    FUNCTION descricao
        RETURN VARCHAR2;

    FUNCTION tipo
        RETURN VARCHAR2;

    FUNCTION versao
        RETURN VARCHAR2;

    FUNCTION executar ( p_periodo DATE
                      , p_per_fim DATE DEFAULT NULL
                      , p_cod_estab lib_proc.vartab )
        RETURN INTEGER;

    --
    PROCEDURE teste;
END;
/
SHOW ERRORS;
