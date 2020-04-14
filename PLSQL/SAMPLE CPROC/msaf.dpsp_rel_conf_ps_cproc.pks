Prompt Package DPSP_REL_CONF_PS_CPROC;
--
-- DPSP_REL_CONF_PS_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dpsp_rel_conf_ps_cproc
IS
    -- AUTOR    : DPSP - André Rebello
    -- DATA     : CRIADO EM 27/11/2017
    -- DESCRIÇÃO: Relatorio de Confronto de Notas Fiscais Peoplesoft x Mastersaf

    -- AUTOR    : Accenture - Lucas Manarte
    -- DATA     : ATUALIZADO EM 17/01/2020
    -- DESCRIÇÃO: Configurar layout do Relatório para Sustentação

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

    FUNCTION executar ( p_data_ini DATE
                      , p_data_fim DATE
                      , p_cod_estado VARCHAR2
                      , p_status VARCHAR2
                      , p_tipo VARCHAR2
                      , p_ext_carga VARCHAR2
                      , p_grupo lib_proc.vartab )
        RETURN INTEGER;
END dpsp_rel_conf_ps_cproc;
/
SHOW ERRORS;
