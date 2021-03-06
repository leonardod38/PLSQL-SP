Prompt Package DPSP_PERDAS_UF_CPROC_BKP;
--
-- DPSP_PERDAS_UF_CPROC_BKP  (Package) 
--
CREATE OR REPLACE PACKAGE dpsp_perdas_uf_cproc_bkp
IS
    -- AUTOR    : ACCENTURE - REBELLO
    -- DATA     : V7 NOVA VERSAO CRIADA EM 19/OUT/2018
    -- DESCRI��O: NOVO PROCESSAMENTO PARA RELATORIO DE PERDAS - AJUSTES DE PERFORMANCE XML BASE HIST

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
                      , p_origem1 VARCHAR2
                      , p_cd1 VARCHAR2
                      , p_origem2 VARCHAR2
                      , p_cd2 VARCHAR2
                      , p_origem3 VARCHAR2
                      , p_cd3 VARCHAR2
                      , p_origem4 VARCHAR2
                      , p_cd4 VARCHAR2
                      , p_compra_direta VARCHAR2
                      , p_filiais VARCHAR2
                      , p_inventario VARCHAR2
                      , p_uf VARCHAR2
                      , p_lojas lib_proc.vartab )
        RETURN INTEGER;
END dpsp_perdas_uf_cproc_bkp;
/
SHOW ERRORS;
