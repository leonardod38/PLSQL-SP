Prompt Package ROD_DELNF_CPROC;
--
-- ROD_DELNF_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE rod_delnf_cproc
IS
    -- Author  : AFONSO NOGUEIRA
    -- Created : 23/12/2008 - 06:40
    -- Purpose : Exclui Notas das Tabelas X's

    /* Declaração de Variáveis Públicas */
    cod_empresa_p estabelecimento.cod_empresa%TYPE;
    cod_estab_p estabelecimento.cod_estab%TYPE;
    nome_estab_p estabelecimento.razao_social%TYPE;
    cgc_estab_p estabelecimento.cgc%TYPE;
    inscricao_estadual_p registro_estadual.inscricao_estadual%TYPE;
    nome_empresa_p empresa.razao_social%TYPE;

    usuario_p VARCHAR2 ( 20 );
    total_estab_p NUMBER ( 4 );
    v_empresa_v VARCHAR2 ( 3 );
    v_ano VARCHAR2 ( 4 );
    v_mes VARCHAR2 ( 2 );
    v_dtfim DATE;
    v_dtini DATE;
    v_estab VARCHAR2 ( 4 );
    v_empre VARCHAR2 ( 3 );
    v_file VARCHAR2 ( 15 );



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

    FUNCTION executar ( pcod_estab VARCHAR2
                      , pdata_inicio DATE
                      , pdata_fim DATE )
        RETURN INTEGER;

    PROCEDURE teste;
END rod_delnf_cproc;
/
SHOW ERRORS;
