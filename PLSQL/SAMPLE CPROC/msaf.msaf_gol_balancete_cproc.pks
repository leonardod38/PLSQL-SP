Prompt Package MSAF_GOL_BALANCETE_CPROC;
--
-- MSAF_GOL_BALANCETE_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE msaf_gol_balancete_cproc
IS
    -- Autor   : Fabio Freitas
    -- Created : 31/03/2006
    -- Purpose : Balancete Contábil

    /* Declaração de Variáveis Públicas */
    cgc_estab_p estabelecimento.cgc%TYPE;
    w_cod_emp estabelecimento.cod_empresa%TYPE;
    w_cod_estab estabelecimento.cod_estab%TYPE;
    w_razao estabelecimento.razao_social%TYPE;


    usuario_p VARCHAR2 ( 20 );

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
                      , pdataini DATE
                      , pdatafim DATE )
        RETURN INTEGER;

    PROCEDURE cabecalho ( p_cgc VARCHAR2
                        , p_razao_social VARCHAR2
                        , p_dat_ini DATE
                        , p_dat_fim DATE
                        , p_pagina VARCHAR2 );
END msaf_gol_balancete_cproc;
/
SHOW ERRORS;
