Prompt Package DPSP_PERDAS_CD_CPROC;
--
-- DPSP_PERDAS_CD_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dpsp_perdas_cd_cproc
IS
    -- AUTOR    : ACCENTURE - GUILHERME SILVA
    -- DATA     : V01 VERSAO CRIADA EM 23/JAN/2019
    -- DESCRIÇÃO: NOVO PROCESSAMENTO PARA RELATORIO DE PERDAS - CD

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

    FUNCTION executar ( p_periodo DATE
                      , p_carga VARCHAR2
                      , p_lojas lib_proc.vartab )
        RETURN INTEGER;
END dpsp_perdas_cd_cproc;
/
SHOW ERRORS;
