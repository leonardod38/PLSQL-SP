Prompt Package DPSP_CARTOES_PF_CPROC;
--
-- DPSP_CARTOES_PF_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dpsp_cartoes_pf_cproc
IS
    -- AUTOR    : Accenture - Lucas Manarte
    -- DATA     : V5 CRIADA EM 21/01/2019
    -- DESCRIÇÃO: FIN-1934 - Relatório de Cartão de Créditos - CR - Ajuste em Código para Performance

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

    PROCEDURE executar_lote ( p_data_ini DATE
                            , p_data_fim DATE
                            , p_origem1 VARCHAR2
                            , p_cd1 VARCHAR2
                            , p_origem2 VARCHAR2
                            , p_cd2 VARCHAR2
                            , p_origem3 VARCHAR2
                            , p_cd3 VARCHAR2
                            , p_origem4 VARCHAR2
                            , p_cd4 VARCHAR2
                            , p_uf VARCHAR2
                            , p_empresa VARCHAR2
                            , p_usuario VARCHAR2
                            , p_procorig VARCHAR2
                            , p_lojas lib_proc.vartab );

    FUNCTION executar ( p_data_ini DATE
                      , p_data_fim DATE
                      , p_origem1 VARCHAR2
                      , p_cd1 VARCHAR2
                      , p_origem2 VARCHAR2
                      , p_cd2 VARCHAR2
                      , p_origem3 VARCHAR2
                      , p_cd3 VARCHAR2
                      , p_origem4 VARCHAR2
                      , p_cd4 VARCHAR2
                      , p_uf VARCHAR2
                      , p_lojas lib_proc.vartab )
        RETURN INTEGER;
/*PROCEDURE LOAD_SAIDAS(PNR_PARTICAO     IN INTEGER,
                        PNR_PARTICAO2    IN INTEGER,
                        VP_PROC_INSTANCE IN VARCHAR2,
                        VP_COD_EMPRESA   IN VARCHAR2,
                        VP_DATA_INI      IN DATE,
                        VP_DATA_FIM      IN DATE,
                        VP_TABELA_SAIDA  IN VARCHAR2,
                        VP_TAB_ESTAB     IN VARCHAR2,
                        PPROC_ID         IN INTEGER,
                        VP_DATA_HORA_INI IN VARCHAR2);*/

END dpsp_cartoes_pf_cproc;
/
SHOW ERRORS;
