Prompt Package DPSP_CARGA_DASH_CPROC;
--
-- DPSP_CARGA_DASH_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dpsp_carga_dash_cproc
IS
    -- AUTOR    : DSP - REBELLO
    -- DATA     : 06/04/2017
    -- DESCRIÇÃO: Carga para Dashboard do VALIDA Acc

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

    FUNCTION fazcampo ( p_i_campo IN VARCHAR2
                      , p_i_fill IN VARCHAR2
                      , p_i_size IN NUMBER )
        RETURN VARCHAR2;

    FUNCTION fazcampo ( p_i_campo IN NUMBER
                      , p_i_format IN VARCHAR2
                      , p_i_fill IN VARCHAR2
                      , p_i_size IN NUMBER )
        RETURN VARCHAR2;

    FUNCTION fazcampo ( p_i_campo IN DATE
                      , p_i_format IN VARCHAR2
                      , p_i_fill IN VARCHAR2
                      , p_i_size IN NUMBER )
        RETURN VARCHAR2;

    FUNCTION executar ( p_periodo DATE
                      , p_indicador VARCHAR2 )
        RETURN INTEGER;
END dpsp_carga_dash_cproc;
/
SHOW ERRORS;
