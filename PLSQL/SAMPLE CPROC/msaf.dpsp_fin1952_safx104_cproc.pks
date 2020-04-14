Prompt Package DPSP_FIN1952_SAFX104_CPROC;
--
-- DPSP_FIN1952_SAFX104_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dpsp_fin1952_safx104_cproc
IS
    -- AUTOR    : Accenture - Guilherme Silva
    -- DATA     : V4 CRIADA EM 18/ABRIL/2019
    -- DESCRIÇÃO: Projeto FIN 1952 - Relatório Conciliação Mastersaf Saídas x Entradas

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
                      , p_produto VARCHAR2 )
        RETURN INTEGER;
END dpsp_fin1952_safx104_cproc;
/
SHOW ERRORS;
