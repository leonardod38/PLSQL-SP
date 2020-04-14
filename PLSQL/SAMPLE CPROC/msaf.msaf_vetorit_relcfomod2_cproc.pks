Prompt Package MSAF_VETORIT_RELCFOMOD2_CPROC;
--
-- MSAF_VETORIT_RELCFOMOD2_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE msaf_vetorit_relcfomod2_cproc
IS
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

    FUNCTION executar ( puf VARCHAR2
                      , pestab VARCHAR2
                      , pdataini DATE
                      , pdatafim DATE
                      , psinief VARCHAR2
                      , pinscrestunica VARCHAR2
                      , pcfop lib_proc.vartab )
        RETURN INTEGER;
END msaf_vetorit_relcfomod2_cproc;
/
SHOW ERRORS;
