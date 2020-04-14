Prompt Package CONF_NF_ENTR_CPROC;
--
-- CONF_NF_ENTR_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE conf_nf_entr_cproc
IS
    /* Declaração de Variáveis Públicas */
    w_cod_emp estabelecimento.cod_empresa%TYPE;
    w_cod_estab estabelecimento.cod_estab%TYPE;
    w_razao estabelecimento.razao_social%TYPE;
    w_usuario VARCHAR2 ( 20 );

    /* VARIÁVEIS DE CONTROLE DE CABEÇALHO DE RELATÓRIO */
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

    FUNCTION executar ( p_cod_estab VARCHAR2
                      , p_periodo_ini DATE
                      , p_periodo_fim DATE
                      , p_tipo_rel VARCHAR2
                      , p_cod_grp_incent VARCHAR2 )
        RETURN INTEGER;
END conf_nf_entr_cproc;
/
SHOW ERRORS;
