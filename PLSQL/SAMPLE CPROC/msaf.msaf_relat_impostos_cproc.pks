Prompt Package MSAF_RELAT_IMPOSTOS_CPROC;
--
-- MSAF_RELAT_IMPOSTOS_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE msaf_relat_impostos_cproc
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

    FUNCTION executar ( vs_mcod_empresa VARCHAR2
                      , vs_cod_estab VARCHAR2
                      , vd_dt_inicio DATE
                      , vd_dt_final DATE
                      , vs_escopo VARCHAR2
                      , vs_movto_e_s VARCHAR2 )
        RETURN INTEGER;

    FUNCTION formata_valor ( p_valor IN NUMBER
                           , p_tamanho IN INTEGER )
        RETURN VARCHAR2;

    PROCEDURE cabecalho_csv ( vs_tp_rel NUMBER );
END msaf_relat_impostos_cproc;
/
SHOW ERRORS;
