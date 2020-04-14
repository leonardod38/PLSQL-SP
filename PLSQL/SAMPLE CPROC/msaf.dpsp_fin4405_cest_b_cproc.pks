Prompt Package DPSP_FIN4405_CEST_B_CPROC;
--
-- DPSP_FIN4405_CEST_B_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dpsp_fin4405_cest_b_cproc
IS
    -- AUTOR    : Accenture - Guilherme Silva
    -- DATA     : V4 CRIADA EM 22/Outubro/2019
    -- DESCRIÇÃO: Projeto FIN 4005 - Relatório Escrituração NF Cesta Básica

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

    FUNCTION executar ( p_diretory VARCHAR2
                      , v_file_archive VARCHAR2 )
        RETURN INTEGER;
END dpsp_fin4405_cest_b_cproc;
/
SHOW ERRORS;
