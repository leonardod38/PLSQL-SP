Prompt Package DSP_INTERFACES_CPROC;
--
-- DSP_INTERFACES_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dsp_interfaces_cproc
IS
    -- AUTOR    : DSP - LFM
    -- DATA     : 30/JUL/2012
    -- DESCRIÇÃO: Executador de interfaces

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

    FUNCTION executar ( p_grupo VARCHAR2
                      , p_data_ini DATE
                      , p_data_fim DATE
                      , p_cria_job VARCHAR2
                      , p_exec_all VARCHAR2
                      , p_codestab lib_proc.vartab )
        RETURN INTEGER;

    -----------CREATE TABLE DSP_GRP_INTERFACES
    -----------(ID_GRUPO NUMBER(3)
    -----------,SEQ_EXECUCAO NUMBER(6)
    -----------,ID_INTERFACE NUMBER(3)
    -----------,TIPO_DATA_INICIAL NUMBER(1) --0 ou NULL=parametro 1=primeiro dia do mes da data inicial informada 2=01/01/1900 3=N dias antes da data inicial
    -----------,N_DIAS_DATA_INICIAL NUMBER(3) --Somente utilizado quando TIPO_DATA_INICIAL = 3
    -----------,TIPO_ESTAB NUMBER(1) --0 ou NULL=parametro 1=DSP900 fixo  2=ALL fixo
    -----------,TIPO_DATA_FINAL NUMBER(1) --0 ou NULL = parametro 1=ultimo dia do mes da data final 2=01/01/1900  3=data fixa
    -----------,DATA_FINAL_FIXA DATE --Somente utilizado quanto TIPO_DATA_FINAL = 3
    -----------);
    -----------CREATE TABLE DSP_INTERFACES
    -----------(ID_INTERFACE NUMBER
    -----------,NOME_PROC VARCHAR2(30)
    -----------,DESCRICAO VARCHAR2(64)
    -----------,NUM_PARAMETROS NUMBER(1) --0=sem parametros | 2=data inicial e final | 3=data ini, fim e empresa | 4=data_ini,data_fim,empresa,estab
    -----------,SUPORTA_ALL VARCHAR2(1)
    -----------,NOME_SAFX VARCHAR2(30)
    -----------);
    CURSOR exec_interfaces ( p_i_id_grupo IN NUMBER )
    IS
        SELECT   dgi.tipo_data_inicial
               , dgi.n_dias_data_inicial
               , dgi.tipo_estab
               , dgi.tipo_data_final
               , dgi.data_final_fixa
               , dif.nome_proc
               , dif.descricao
               , dif.num_parametros
               , dif.suporta_all
               , dif.nome_safx
            FROM msafi.dsp_grp_interfaces dgi
               , msafi.dsp_interfaces dif
           WHERE dgi.id_grupo = p_i_id_grupo
             AND dif.id_interface = dgi.id_interface
        ORDER BY dgi.seq_execucao;
END dsp_interfaces_cproc;
/
SHOW ERRORS;
