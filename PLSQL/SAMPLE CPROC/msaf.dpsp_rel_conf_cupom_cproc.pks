Prompt Package DPSP_REL_CONF_CUPOM_CPROC;
--
-- DPSP_REL_CONF_CUPOM_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dpsp_rel_conf_cupom_cproc
IS
    -- AUTOR    : DSP - REBELLO
    -- DATA     : 09/05/2017
    -- DESCRIÇÃO: Relatório de Confronto e Carga de Cupons

    -- AUTOR DA ATUALIZAÇÃO : Douglas Oliveira
    -- DATA     : 22/01/2019
    -- DESCRIÇÃO: Atualização nos valores contabeis, chamado: 2000892

    -- AUTOR  DA ATUALIZAÇÃO : Accenture - Lucas Manarte
    -- DATA     : 17/01/2020
    -- DESCRIÇÃO: Configurar layout do Relatório para apoio do Time de Sustentação

    --Variaveis (aqui nao podem ser constantes) para as funções REGEXP_LIKE encontrarem DSP9xx, Depósitos, Lojas e Estabelecimentos
    c_proc_9xx VARCHAR2 ( 30 ); --C_PROC_9XX   := '^' || MCOD_EMPRESA || '9[0-9]{2}$';
    c_proc_dep VARCHAR2 ( 30 ); --C_PROC_DEP   := '^' || MCOD_EMPRESA || '9[0-9][1-9]$';
    c_proc_loj VARCHAR2 ( 30 ); --C_PROC_LOJ   := '^' || MCOD_EMPRESA || '[0-8][0-9]{' || TO_CHAR(5-LENGTH(MCOD_EMPRESA),'FM9') || '}$';
    c_proc_est VARCHAR2 ( 30 ); --C_PROC_EST   := '^' || MCOD_EMPRESA || '[0-9]{3,' || TO_CHAR(6-LENGTH(MCOD_EMPRESA),'FM9') || '}$';
    c_proc_estvd VARCHAR2 ( 30 ); --C_PROC_ESTVD := '^VD[0-9]{3,' || TO_CHAR(6-LENGTH(MCOD_EMPRESA),'FM9') || '}$';

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

    PROCEDURE loga ( p_i_texto IN VARCHAR2
                   , p_i_dttm IN BOOLEAN DEFAULT TRUE );

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

    PROCEDURE delete_cupom ( p_i_data_ini IN DATE
                           , p_i_data_fim IN DATE
                           , p_i_cod_empresa IN VARCHAR2
                           , p_i_cod_estab IN VARCHAR2
                           , p_i_delete_log IN VARCHAR2 );

    FUNCTION executar ( p_data_ini DATE
                      , p_data_fim DATE
                      , p_cod_estado VARCHAR2
                      , p_carga_cupom VARCHAR2
                      , p_diferenca VARCHAR2
                      , p_delete VARCHAR2
                      , p_delete_log VARCHAR2
                      , p_ext_carga VARCHAR2
                      , p_ext_csi VARCHAR2
                      , p_ext_dif VARCHAR2
                      , p_ind_ext VARCHAR2
                      , p_cod_estab lib_proc.vartab )
        RETURN INTEGER;
END dpsp_rel_conf_cupom_cproc;
/
SHOW ERRORS;
