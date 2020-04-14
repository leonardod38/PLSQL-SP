Prompt Package DPSP_FIN42_REL_INCINE_CPROC;
--
-- DPSP_FIN42_REL_INCINE_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dpsp_fin42_rel_incine_cproc
IS
    -------------------------------------------------------------------------
    -- AUTOR    : DSP - GUILHERME SILVA
    -- DATA     : V1 CRIADA EM 26/SET/2018
    -- DESCRI��O: Relat�rio de Ressarcimento de ST para NF de Incinera��o
    -------------------------------------------------------------------------

    mcod_empresa empresa.cod_empresa%TYPE;
    mcod_estab estabelecimento.cod_estab%TYPE;
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
                      , p_cod_estab lib_proc.vartab )
        RETURN INTEGER;

    v_retorno_status VARCHAR2 ( 4000 );
END dpsp_fin42_rel_incine_cproc;
/
SHOW ERRORS;
