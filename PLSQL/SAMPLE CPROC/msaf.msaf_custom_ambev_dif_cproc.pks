Prompt Package MSAF_CUSTOM_AMBEV_DIF_CPROC;
--
-- MSAF_CUSTOM_AMBEV_DIF_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE msaf_custom_ambev_dif_cproc
IS
    -- Autor   : Pedro A. Puerta
    -- Created : 03/12/2007
    -- Purpose : Diferencial de Aliquota

    /* Declarac?o de Variaveis Publicas */
    cod_empresa_p estabelecimento.cod_empresa%TYPE;
    cod_estab_p estabelecimento.cod_estab%TYPE;
    nome_estab_p estabelecimento.razao_social%TYPE;
    cgc_estab_p estabelecimento.cgc%TYPE;
    inscricao_estadual_p registro_estadual.inscricao_estadual%TYPE;
    nome_empresa_p empresa.razao_social%TYPE;

    usuario_p VARCHAR2 ( 20 );
    total_estab_p NUMBER ( 4 );
    pfolha NUMBER := 0;
    mlinha VARCHAR2 ( 200 );
    conta NUMBER := 0;
    w_razao VARCHAR2 ( 100 );
    mcod_empresa estabelecimento.cod_empresa%TYPE;
    mcod_estab estabelecimento.cod_estab%TYPE;
    musuario VARCHAR2 ( 100 );
    temp empresa.razao_social%TYPE;
    tnome estabelecimento.razao_social%TYPE;
    tend estabelecimento.endereco%TYPE;
    tbai estabelecimento.bairro%TYPE;
    tmun estabelecimento.cidade%TYPE;
    tinscest VARCHAR2 ( 20 );
    tcpnj VARCHAR2 ( 20 );
    tccm estabelecimento.insc_municipal%TYPE;
    vlinha CHAR ( 1 ) := '*';
    vsep CHAR ( 1 ) := '|';
    pprinta BOOLEAN := FALSE;
    wori NUMBER;
    wdest NUMBER;

    /* VARIAVEIS DE CONTROLE DE CABECALHO DE RELATORIO */

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

    FUNCTION executar ( pestab VARCHAR2
                      , pperini DATE
                      , pperfim DATE
                      , pperfil VARCHAR2 )
        RETURN INTEGER;

    PROCEDURE teste;

    PROCEDURE cabecalho ( pini DATE
                        , pfim DATE );
END msaf_custom_ambev_dif_cproc;
/
SHOW ERRORS;
