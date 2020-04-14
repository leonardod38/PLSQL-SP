Prompt Package DPSP_FIN2662_PAR_REG_DUB_CPROC;
--
-- DPSP_FIN2662_PAR_REG_DUB_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dpsp_fin2662_par_reg_dub_cproc
IS
    -- AUTOR    : Accenture - Guilherme Silva
    -- DATA     : V4 CRIADA EM 11/DEZEMBRO/2019
    -- DESCRIÇÃO: Projeto FIN 1952 - Relatório Conciliação Mastersaf Saídas x Entradas -- Paremetrização


    mcod_empresa empresa.cod_empresa%TYPE;
    mcod_usuario usuario_empresa.cod_usuario%TYPE;

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

    FUNCTION executar ( p_consulta VARCHAR2
                      , p_convenio VARCHAR2
                      , p_data_ini DATE
                      , p_data_fim DATE
                      , p_regra_calc VARCHAR2
                      , p_cst VARCHAR2
                      , p_item_sub VARCHAR2
                      , p_exclui VARCHAR2
                      , p_cfo lib_proc.vartab )
        RETURN INTEGER;
END dpsp_fin2662_par_reg_dub_cproc;
/
SHOW ERRORS;
