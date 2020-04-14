Prompt Package DPSP_BLOCO_FIN034_CPROC;
--
-- DPSP_BLOCO_FIN034_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dpsp_bloco_fin034_cproc
IS
    -- AUTOR    : Accenture - Guilherme Silva
    -- DATA     : V4 CRIADA EM 04/JAN/2019
    -- DESCRIÇÃO: Projeto FIN 34 - Bloco 1600 Sped fiscal

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
                      , p_uf VARCHAR2
                      , p_lojas lib_proc.vartab )
        RETURN INTEGER;
END dpsp_bloco_fin034_cproc;
/
SHOW ERRORS;
