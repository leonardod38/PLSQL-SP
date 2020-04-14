Prompt Package Body CRIA_DADOS_CHAMADO_CPROC;
--
-- CRIA_DADOS_CHAMADO_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY cria_dados_chamado_cproc
IS
    mcod_empresa empresa.cod_empresa%TYPE;

    mcod_estab estabelecimento.cod_estab%TYPE;

    musuario usuario_empresa.cod_usuario%TYPE;



    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );
    BEGIN
        --MCOD_EMPRESA := LIB_PARAMETROS.RECUPERAR('EMPRESA');
        --MCOD_ESTAB   := LIB_PARAMETROS.RECUPERAR('ESTABELECIMENTO');
        --MUSUARIO     := LIB_PARAMETROS.RECUPERAR('USUARIO');

        lib_proc.add_param ( pstr
                           , 'Cod. Estabelecimento'
                           , 'Varchar2'
                           , 'Textbox'
                           , 'N'
                           , pmascara => '######' );


        lib_proc.add_param (
                             pstr
                           , 'Cod. Estado'
                           , 'Varchar2'
                           , 'listbox'
                           , 'S'
                           , ''
                           , ''
                           , 'AC=AC,AL=AL,AM=AM,AP=AP,BA=BA,CE=CE,DF=DF,ES=ES,EX=EX,GO=GO,MA=MA,MG=MG,MS=MS,MT=MT,PA=PA,PB=PB,PE=PE,PI=PI,PR=PR,RJ=RJ,RN=RN,RO=RO,RR=RR,RS=RS,SC=SC,SE=SE,SP=SP,TO=TO'
        );

        lib_proc.add_param ( pstr
                           , 'Cod. Mod. CIAP'
                           , 'Varchar2'
                           , 'listbox'
                           , 'S'
                           , ''
                           , ''
                           , 'A=A,B=B,C=C,D=D' );


        RETURN pstr;
    END;



    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'CRIA DADOS CHAMADO';
    END;

    FUNCTION tipo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Processo';
    END;

    FUNCTION versao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN '1.0';
    END;

    FUNCTION descricao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Cria Dados Chamado';
    END;

    FUNCTION modulo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN '';
    END;

    FUNCTION classificacao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Utilitarios';
    END;

    FUNCTION orientacaopapel
        RETURN VARCHAR2
    IS
    BEGIN
        -- orientação do papel
        RETURN 'landscape';
    END;



    -- ------------------------------------------------------------------
    --  PROCEDURE PRINCIPAL
    -- ------------------------------------------------------------------

    FUNCTION executar ( pcodestab VARCHAR2
                      , pcodestado VARCHAR2
                      , pcodmodelociap VARCHAR2 )
        RETURN INTEGER
    IS
        mproc_id INTEGER;

        w_query VARCHAR2 ( 5000 );
        w_query_aux VARCHAR2 ( 5000 );
        w_expressao VARCHAR2 ( 5000 );
        w_nome_coluna VARCHAR2 ( 50 );
        w_nome_coluna2 VARCHAR2 ( 50 );

        ident_estado_w NUMBER ( 12 ) := 0;
        cnpj_w VARCHAR2 ( 14 ) := '';
        ie_w VARCHAR2 ( 14 ) := '';



        w_rownum NUMBER;

        TYPE t_reg_tabela IS TABLE OF VARCHAR2 ( 200 )
            INDEX BY BINARY_INTEGER;

        w_reg_tabela t_reg_tabela;
    BEGIN
        mcod_empresa := lib_parametros.recuperar ( 'empresa' );

        -- Cria Processo
        mproc_id :=
            lib_proc.new ( 'CRIA_DADOS_CHAMADO_CPROC'
                         , 48
                         , 150 );
        lib_proc.add_tipo ( mproc_id
                          , 1
                          , 'Processo'
                          , 1 );


        IF mcod_empresa IS NULL THEN
            lib_proc.add_log ( 'código da empresa deve ser informado como parâmetro global.'
                             , 0 );
            lib_proc.close;
            RETURN mproc_id;
        END IF;


        -----------------------------------------------------
        --- INICIO DO BLOCO ---------------------------------
        -----------------------------------------------------

        BEGIN
            SELECT ident_estado
              INTO ident_estado_w
              FROM estado
             WHERE cod_estado = pcodestado;
        EXCEPTION
            WHEN OTHERS THEN
                lib_proc.add_log ( 'ERRO NA RECUPERAÇÃO DO ESTADO'
                                 , 0 );
        END;

        rec_cnpj_ie ( pcodestado
                    , cnpj_w
                    , ie_w );


        -- INSERE ESTABELECIMENTO --
        BEGIN
            INSERT INTO estabelecimento ( cod_empresa
                                        , cod_estab
                                        , ind_matriz_filial
                                        , cod_classe
                                        , cgc
                                        , cod_atividade
                                        , insc_municipal
                                        , insc_suframa
                                        , razao_social
                                        , nome_fantasia
                                        , endereco
                                        , num_endereco
                                        , compl_endereco
                                        , bairro
                                        , cidade
                                        , distrito
                                        , sub_distrito
                                        , ident_estado
                                        , cep
                                        , ddd
                                        , telefone
                                        , fax
                                        , cod_municipio
                                        , ind_venda_amb
                                        , ind_dirf_central
                                        , tp_logradouro
                                        , itens_nota
                                        , imprime
                                        , mult_serie_s
                                        , num_ppvi_sn
                                        , seq_unico
                                        , codigo_contabil
                                        , cod_produto
                                        , ind_produto
                                        , ind_st_ncontrib
                                        , margem_st_ncontrib
                                        , cod_munic_iss
                                        , cod_tp_recolh
                                        , ind_forma_abat
                                        , ind_numeracao
                                        , email
                                        , ind_nbm_iest
                                        , ind_contrib_ipi
                                        , ind_contrib_sub
                                        , dat_ini_atividade
                                        , ind_aprovador
                                        , insc_df
                                        , ind_imune
                                        , ind_isento
                                        , ind_escr_contab
                                        , data_jucemat
                                        , data_sefaz
                                        , ind_secundario
                                        , ind_ipi_sj
                                        , ind_ipisj_regra_rb
                                        , dt_encerramento
                                        , cei_port63
                                        , insc_port63
                                        , num_threads_mmag )
                 VALUES ( '081'
                        , pcodestab
                        , 'F'
                        , 1
                        , cnpj_w
                        , 111202
                        , NULL
                        , NULL
                        , 'Chamado ' || pcodestab
                        , 'Estabelecimento Chamado ' || pcodestab
                        , NULL
                        , NULL
                        , NULL
                        , NULL
                        , NULL
                        , NULL
                        , NULL
                        , ident_estado_w
                        , NULL
                        , NULL
                        , NULL
                        , NULL
                        , NULL
                        , NULL
                        , NULL
                        , NULL
                        , NULL
                        , NULL
                        , NULL
                        , NULL
                        , NULL
                        , NULL
                        , NULL
                        , NULL
                        , NULL
                        , NULL
                        , NULL
                        , NULL
                        , NULL
                        , NULL
                        , NULL
                        , 'N'
                        , 'N'
                        , 'N'
                        , NULL
                        , NULL
                        , NULL
                        , 'N'
                        , 'N'
                        , 'N'
                        , NULL
                        , NULL
                        , 'N'
                        , 'N'
                        , 'N'
                        , NULL
                        , NULL
                        , NULL
                        , NULL );

            lib_proc.add_log ( 'ESTABELECIMENTO INSERIDO'
                             , 0 );
        EXCEPTION
            WHEN OTHERS THEN
                lib_proc.add_log ( 'ERRO INSERÇÃO ESTABELECIMENTO ' || SQLERRM
                                 , 0 );
        END;


        -- INSERE ISNC ESTADUAL --
        BEGIN
            INSERT INTO registro_estadual ( cod_empresa
                                          , cod_estab
                                          , ident_estado
                                          , inscricao_estadual )
                 VALUES ( '081'
                        , pcodestab
                        , ident_estado_w
                        , ie_w );

            lib_proc.add_log ( 'INSCRICAO INSERIDA'
                             , 0 );
        EXCEPTION
            WHEN OTHERS THEN
                lib_proc.add_log ( 'ERRO INSERÇÃO INSCRICAO ' || SQLERRM
                                 , 0 );
        END;



        --- INSERE TABELA RELAC TAB GRUPO --

        INSERT INTO relac_tab_grupo ( cod_empresa
                                    , cod_estab
                                    , cod_tabela
                                    , valid_inicial
                                    , grupo_estab )
             VALUES ( '081'
                    , pcodestab
                    , 2021
                    , TO_DATE ( '01-01-2005'
                              , 'dd-mm-yyyy' )
                    , 'GRP01' );

        INSERT INTO relac_tab_grupo ( cod_empresa
                                    , cod_estab
                                    , cod_tabela
                                    , valid_inicial
                                    , grupo_estab )
             VALUES ( '081'
                    , pcodestab
                    , 2003
                    , TO_DATE ( '01-01-2005'
                              , 'dd-mm-yyyy' )
                    , 'GRP01' );

        INSERT INTO relac_tab_grupo ( cod_empresa
                                    , cod_estab
                                    , cod_tabela
                                    , valid_inicial
                                    , grupo_estab )
             VALUES ( '081'
                    , pcodestab
                    , 2004
                    , TO_DATE ( '01-01-2005'
                              , 'dd-mm-yyyy' )
                    , 'GRP01' );

        INSERT INTO relac_tab_grupo ( cod_empresa
                                    , cod_estab
                                    , cod_tabela
                                    , valid_inicial
                                    , grupo_estab )
             VALUES ( '081'
                    , pcodestab
                    , 2029
                    , TO_DATE ( '01-01-2005'
                              , 'dd-mm-yyyy' )
                    , 'GRP01' );

        INSERT INTO relac_tab_grupo ( cod_empresa
                                    , cod_estab
                                    , cod_tabela
                                    , valid_inicial
                                    , grupo_estab )
             VALUES ( '081'
                    , pcodestab
                    , 2019
                    , TO_DATE ( '01-01-2005'
                              , 'dd-mm-yyyy' )
                    , 'GRP01' );

        INSERT INTO relac_tab_grupo ( cod_empresa
                                    , cod_estab
                                    , cod_tabela
                                    , valid_inicial
                                    , grupo_estab )
             VALUES ( '081'
                    , pcodestab
                    , 2082
                    , TO_DATE ( '01-01-2005'
                              , 'dd-mm-yyyy' )
                    , 'GRP01' );

        INSERT INTO relac_tab_grupo ( cod_empresa
                                    , cod_estab
                                    , cod_tabela
                                    , valid_inicial
                                    , grupo_estab )
             VALUES ( '081'
                    , pcodestab
                    , 2042
                    , TO_DATE ( '01-01-2005'
                              , 'dd-mm-yyyy' )
                    , 'GRP01' );

        INSERT INTO relac_tab_grupo ( cod_empresa
                                    , cod_estab
                                    , cod_tabela
                                    , valid_inicial
                                    , grupo_estab )
             VALUES ( '081'
                    , pcodestab
                    , 2033
                    , TO_DATE ( '01-01-2005'
                              , 'dd-mm-yyyy' )
                    , 'GRP01' );

        INSERT INTO relac_tab_grupo ( cod_empresa
                                    , cod_estab
                                    , cod_tabela
                                    , valid_inicial
                                    , grupo_estab )
             VALUES ( '081'
                    , pcodestab
                    , 2036
                    , TO_DATE ( '01-01-2005'
                              , 'dd-mm-yyyy' )
                    , 'GRP01' );

        INSERT INTO relac_tab_grupo ( cod_empresa
                                    , cod_estab
                                    , cod_tabela
                                    , valid_inicial
                                    , grupo_estab )
             VALUES ( '081'
                    , pcodestab
                    , 2020
                    , TO_DATE ( '01-01-2005'
                              , 'dd-mm-yyyy' )
                    , 'GRP01' );

        INSERT INTO relac_tab_grupo ( cod_empresa
                                    , cod_estab
                                    , cod_tabela
                                    , valid_inicial
                                    , grupo_estab )
             VALUES ( '081'
                    , pcodestab
                    , 2007
                    , TO_DATE ( '01-01-2005'
                              , 'dd-mm-yyyy' )
                    , 'GRP01' );

        INSERT INTO relac_tab_grupo ( cod_empresa
                                    , cod_estab
                                    , cod_tabela
                                    , valid_inicial
                                    , grupo_estab )
             VALUES ( '081'
                    , pcodestab
                    , 2024
                    , TO_DATE ( '01-01-2005'
                              , 'dd-mm-yyyy' )
                    , 'GRP01' );

        INSERT INTO relac_tab_grupo ( cod_empresa
                                    , cod_estab
                                    , cod_tabela
                                    , valid_inicial
                                    , grupo_estab )
             VALUES ( '081'
                    , pcodestab
                    , 2006
                    , TO_DATE ( '01-01-2005'
                              , 'dd-mm-yyyy' )
                    , 'GRP01' );

        INSERT INTO relac_tab_grupo ( cod_empresa
                                    , cod_estab
                                    , cod_tabela
                                    , valid_inicial
                                    , grupo_estab )
             VALUES ( '081'
                    , pcodestab
                    , 2010
                    , TO_DATE ( '01-01-2005'
                              , 'dd-mm-yyyy' )
                    , 'GRP01' );

        INSERT INTO relac_tab_grupo ( cod_empresa
                                    , cod_estab
                                    , cod_tabela
                                    , valid_inicial
                                    , grupo_estab )
             VALUES ( '081'
                    , pcodestab
                    , 2001
                    , TO_DATE ( '01-01-2005'
                              , 'dd-mm-yyyy' )
                    , 'GRP01' );

        INSERT INTO relac_tab_grupo ( cod_empresa
                                    , cod_estab
                                    , cod_tabela
                                    , valid_inicial
                                    , grupo_estab )
             VALUES ( '081'
                    , pcodestab
                    , 1008
                    , TO_DATE ( '01-01-2005'
                              , 'dd-mm-yyyy' )
                    , 'GRP01' );

        INSERT INTO relac_tab_grupo ( cod_empresa
                                    , cod_estab
                                    , cod_tabela
                                    , valid_inicial
                                    , grupo_estab )
             VALUES ( '081'
                    , pcodestab
                    , 2002
                    , TO_DATE ( '01-01-2005'
                              , 'dd-mm-yyyy' )
                    , 'GRP01' );

        INSERT INTO relac_tab_grupo ( cod_empresa
                                    , cod_estab
                                    , cod_tabela
                                    , valid_inicial
                                    , grupo_estab )
             VALUES ( '081'
                    , pcodestab
                    , 2013
                    , TO_DATE ( '01-01-2005'
                              , 'dd-mm-yyyy' )
                    , 'GRP01' );

        INSERT INTO relac_tab_grupo ( cod_empresa
                                    , cod_estab
                                    , cod_tabela
                                    , valid_inicial
                                    , grupo_estab )
             VALUES ( '081'
                    , pcodestab
                    , 2018
                    , TO_DATE ( '01-01-2005'
                              , 'dd-mm-yyyy' )
                    , 'GRP01' );

        INSERT INTO relac_tab_grupo ( cod_empresa
                                    , cod_estab
                                    , cod_tabela
                                    , valid_inicial
                                    , grupo_estab )
             VALUES ( '081'
                    , pcodestab
                    , 2037
                    , TO_DATE ( '01-01-2005'
                              , 'dd-mm-yyyy' )
                    , 'GRP01' );

        INSERT INTO relac_tab_grupo ( cod_empresa
                                    , cod_estab
                                    , cod_tabela
                                    , valid_inicial
                                    , grupo_estab )
             VALUES ( '081'
                    , pcodestab
                    , 2048
                    , TO_DATE ( '01-01-2005'
                              , 'dd-mm-yyyy' )
                    , 'GRP01' );

        INSERT INTO relac_tab_grupo ( cod_empresa
                                    , cod_estab
                                    , cod_tabela
                                    , valid_inicial
                                    , grupo_estab )
             VALUES ( '081'
                    , pcodestab
                    , 2011
                    , TO_DATE ( '01-01-2005'
                              , 'dd-mm-yyyy' )
                    , 'GRP01' );

        INSERT INTO relac_tab_grupo ( cod_empresa
                                    , cod_estab
                                    , cod_tabela
                                    , valid_inicial
                                    , grupo_estab )
             VALUES ( '081'
                    , pcodestab
                    , 2025
                    , TO_DATE ( '01-01-2005'
                              , 'dd-mm-yyyy' )
                    , 'GRP01' );

        INSERT INTO relac_tab_grupo ( cod_empresa
                                    , cod_estab
                                    , cod_tabela
                                    , valid_inicial
                                    , grupo_estab )
             VALUES ( '081'
                    , pcodestab
                    , 2026
                    , TO_DATE ( '01-01-2005'
                              , 'dd-mm-yyyy' )
                    , 'GRP01' );

        INSERT INTO relac_tab_grupo ( cod_empresa
                                    , cod_estab
                                    , cod_tabela
                                    , valid_inicial
                                    , grupo_estab )
             VALUES ( '081'
                    , pcodestab
                    , 2044
                    , TO_DATE ( '01-01-2005'
                              , 'dd-mm-yyyy' )
                    , 'GRP01' );

        INSERT INTO relac_tab_grupo ( cod_empresa
                                    , cod_estab
                                    , cod_tabela
                                    , valid_inicial
                                    , grupo_estab )
             VALUES ( '081'
                    , pcodestab
                    , 2027
                    , TO_DATE ( '01-01-2005'
                              , 'dd-mm-yyyy' )
                    , 'GRP01' );

        INSERT INTO relac_tab_grupo ( cod_empresa
                                    , cod_estab
                                    , cod_tabela
                                    , valid_inicial
                                    , grupo_estab )
             VALUES ( '081'
                    , pcodestab
                    , 2035
                    , TO_DATE ( '01-01-2005'
                              , 'dd-mm-yyyy' )
                    , 'GRP01' );

        INSERT INTO relac_tab_grupo ( cod_empresa
                                    , cod_estab
                                    , cod_tabela
                                    , valid_inicial
                                    , grupo_estab )
             VALUES ( '081'
                    , pcodestab
                    , 2005
                    , TO_DATE ( '01-01-2005'
                              , 'dd-mm-yyyy' )
                    , 'GRP01' );

        INSERT INTO relac_tab_grupo ( cod_empresa
                                    , cod_estab
                                    , cod_tabela
                                    , valid_inicial
                                    , grupo_estab )
             VALUES ( '081'
                    , pcodestab
                    , 2031
                    , TO_DATE ( '01-01-2005'
                              , 'dd-mm-yyyy' )
                    , 'GRP01' );

        INSERT INTO relac_tab_grupo ( cod_empresa
                                    , cod_estab
                                    , cod_tabela
                                    , valid_inicial
                                    , grupo_estab )
             VALUES ( '081'
                    , pcodestab
                    , 1009
                    , TO_DATE ( '01-01-2005'
                              , 'dd-mm-yyyy' )
                    , 'GRP01' );

        INSERT INTO relac_tab_grupo ( cod_empresa
                                    , cod_estab
                                    , cod_tabela
                                    , valid_inicial
                                    , grupo_estab )
             VALUES ( '081'
                    , pcodestab
                    , 2032
                    , TO_DATE ( '01-01-2005'
                              , 'dd-mm-yyyy' )
                    , 'GRP01' );

        INSERT INTO relac_tab_grupo ( cod_empresa
                                    , cod_estab
                                    , cod_tabela
                                    , valid_inicial
                                    , grupo_estab )
             VALUES ( '081'
                    , pcodestab
                    , 2085
                    , TO_DATE ( '01-01-2005'
                              , 'dd-mm-yyyy' )
                    , 'GRP01' );

        INSERT INTO relac_tab_grupo ( cod_empresa
                                    , cod_estab
                                    , cod_tabela
                                    , valid_inicial
                                    , grupo_estab )
             VALUES ( '081'
                    , pcodestab
                    , 2017
                    , TO_DATE ( '01-01-2005'
                              , 'dd-mm-yyyy' )
                    , 'GRP01' );

        INSERT INTO relac_tab_grupo ( cod_empresa
                                    , cod_estab
                                    , cod_tabela
                                    , valid_inicial
                                    , grupo_estab )
             VALUES ( '081'
                    , pcodestab
                    , 2047
                    , TO_DATE ( '01-01-2005'
                              , 'dd-mm-yyyy' )
                    , 'GRP01' );

        INSERT INTO relac_tab_grupo ( cod_empresa
                                    , cod_estab
                                    , cod_tabela
                                    , valid_inicial
                                    , grupo_estab )
             VALUES ( '081'
                    , pcodestab
                    , 2030
                    , TO_DATE ( '01-01-2005'
                              , 'dd-mm-yyyy' )
                    , 'GRP01' );

        INSERT INTO relac_tab_grupo ( cod_empresa
                                    , cod_estab
                                    , cod_tabela
                                    , valid_inicial
                                    , grupo_estab )
             VALUES ( '081'
                    , pcodestab
                    , 2098
                    , TO_DATE ( '01-01-2005'
                              , 'dd-mm-yyyy' )
                    , 'GRP01' );

        INSERT INTO relac_tab_grupo ( cod_empresa
                                    , cod_estab
                                    , cod_tabela
                                    , valid_inicial
                                    , grupo_estab )
             VALUES ( '081'
                    , pcodestab
                    , 2096
                    , TO_DATE ( '01-01-2005'
                              , 'dd-mm-yyyy' )
                    , 'GRP01' );

        INSERT INTO relac_tab_grupo ( cod_empresa
                                    , cod_estab
                                    , cod_tabela
                                    , valid_inicial
                                    , grupo_estab )
             VALUES ( '081'
                    , pcodestab
                    , 37
                    , TO_DATE ( '01-01-2005'
                              , 'dd-mm-yyyy' )
                    , 'GRP01' );

        INSERT INTO relac_tab_grupo ( cod_empresa
                                    , cod_estab
                                    , cod_tabela
                                    , valid_inicial
                                    , grupo_estab )
             VALUES ( '081'
                    , pcodestab
                    , 2028
                    , TO_DATE ( '01-01-2005'
                              , 'dd-mm-yyyy' )
                    , 'GRP01' );

        INSERT INTO relac_tab_grupo ( cod_empresa
                                    , cod_estab
                                    , cod_tabela
                                    , valid_inicial
                                    , grupo_estab )
             VALUES ( '081'
                    , pcodestab
                    , 2094
                    , TO_DATE ( '01-01-2005'
                              , 'dd-mm-yyyy' )
                    , 'GRP01' );

        INSERT INTO relac_tab_grupo ( cod_empresa
                                    , cod_estab
                                    , cod_tabela
                                    , valid_inicial
                                    , grupo_estab )
             VALUES ( '081'
                    , pcodestab
                    , 2080
                    , TO_DATE ( '01-01-2005'
                              , 'dd-mm-yyyy' )
                    , 'GRP01' );

        INSERT INTO relac_tab_grupo ( cod_empresa
                                    , cod_estab
                                    , cod_tabela
                                    , valid_inicial
                                    , grupo_estab )
             VALUES ( '081'
                    , pcodestab
                    , 1010
                    , TO_DATE ( '01-01-2005'
                              , 'dd-mm-yyyy' )
                    , 'GRP01' );

        INSERT INTO relac_tab_grupo ( cod_empresa
                                    , cod_estab
                                    , cod_tabela
                                    , valid_inicial
                                    , grupo_estab )
             VALUES ( '081'
                    , pcodestab
                    , 2034
                    , TO_DATE ( '01-01-2005'
                              , 'dd-mm-yyyy' )
                    , 'GRP01' );

        INSERT INTO relac_tab_grupo ( cod_empresa
                                    , cod_estab
                                    , cod_tabela
                                    , valid_inicial
                                    , grupo_estab )
             VALUES ( '081'
                    , pcodestab
                    , 2015
                    , TO_DATE ( '01-01-2005'
                              , 'dd-mm-yyyy' )
                    , 'GRP01' );

        INSERT INTO relac_tab_grupo ( cod_empresa
                                    , cod_estab
                                    , cod_tabela
                                    , valid_inicial
                                    , grupo_estab )
             VALUES ( '081'
                    , pcodestab
                    , 2016
                    , TO_DATE ( '01-01-2005'
                              , 'dd-mm-yyyy' )
                    , 'GRP01' );

        INSERT INTO relac_tab_grupo ( cod_empresa
                                    , cod_estab
                                    , cod_tabela
                                    , valid_inicial
                                    , grupo_estab )
             VALUES ( '081'
                    , pcodestab
                    , 23
                    , TO_DATE ( '01-01-2005'
                              , 'dd-mm-yyyy' )
                    , 'GRP01' );

        INSERT INTO relac_tab_grupo ( cod_empresa
                                    , cod_estab
                                    , cod_tabela
                                    , valid_inicial
                                    , grupo_estab )
             VALUES ( '081'
                    , pcodestab
                    , 2014
                    , TO_DATE ( '01-01-2005'
                              , 'dd-mm-yyyy' )
                    , 'GRP01' );

        INSERT INTO relac_tab_grupo ( cod_empresa
                                    , cod_estab
                                    , cod_tabela
                                    , valid_inicial
                                    , grupo_estab )
             VALUES ( '081'
                    , pcodestab
                    , 24
                    , TO_DATE ( '01-01-2005'
                              , 'dd-mm-yyyy' )
                    , 'GRP01' );

        INSERT INTO relac_tab_grupo ( cod_empresa
                                    , cod_estab
                                    , cod_tabela
                                    , valid_inicial
                                    , grupo_estab )
             VALUES ( '081'
                    , pcodestab
                    , 1003
                    , TO_DATE ( '01-01-2005'
                              , 'dd-mm-yyyy' )
                    , 'GRP01' );

        INSERT INTO relac_tab_grupo ( cod_empresa
                                    , cod_estab
                                    , cod_tabela
                                    , valid_inicial
                                    , grupo_estab )
             VALUES ( '081'
                    , pcodestab
                    , 38
                    , TO_DATE ( '01-01-2005'
                              , 'dd-mm-yyyy' )
                    , 'GRP01' );

        INSERT INTO relac_tab_grupo ( cod_empresa
                                    , cod_estab
                                    , cod_tabela
                                    , valid_inicial
                                    , grupo_estab )
             VALUES ( '081'
                    , pcodestab
                    , 58
                    , TO_DATE ( '01-01-2005'
                              , 'dd-mm-yyyy' )
                    , 'GRP01' );

        INSERT INTO relac_tab_grupo ( cod_empresa
                                    , cod_estab
                                    , cod_tabela
                                    , valid_inicial
                                    , grupo_estab )
             VALUES ( '081'
                    , pcodestab
                    , 2008
                    , TO_DATE ( '01-01-2005'
                              , 'dd-mm-yyyy' )
                    , 'GRP01' );

        INSERT INTO relac_tab_grupo ( cod_empresa
                                    , cod_estab
                                    , cod_tabela
                                    , valid_inicial
                                    , grupo_estab )
             VALUES ( '081'
                    , pcodestab
                    , 1007
                    , TO_DATE ( '01-01-2005'
                              , 'dd-mm-yyyy' )
                    , 'GRP01' );

        INSERT INTO relac_tab_grupo ( cod_empresa
                                    , cod_estab
                                    , cod_tabela
                                    , valid_inicial
                                    , grupo_estab )
             VALUES ( '081'
                    , pcodestab
                    , 2088
                    , TO_DATE ( '01-01-2005'
                              , 'dd-mm-yyyy' )
                    , 'GRP01' );

        INSERT INTO relac_tab_grupo ( cod_empresa
                                    , cod_estab
                                    , cod_tabela
                                    , valid_inicial
                                    , grupo_estab )
             VALUES ( '081'
                    , pcodestab
                    , 2022
                    , TO_DATE ( '01-01-2005'
                              , 'dd-mm-yyyy' )
                    , 'GRP01' );

        INSERT INTO relac_tab_grupo ( cod_empresa
                                    , cod_estab
                                    , cod_tabela
                                    , valid_inicial
                                    , grupo_estab )
             VALUES ( '081'
                    , pcodestab
                    , 2095
                    , TO_DATE ( '01-01-2005'
                              , 'dd-mm-yyyy' )
                    , 'GRP01' );

        INSERT INTO relac_tab_grupo ( cod_empresa
                                    , cod_estab
                                    , cod_tabela
                                    , valid_inicial
                                    , grupo_estab )
             VALUES ( '081'
                    , pcodestab
                    , 2023
                    , TO_DATE ( '01-01-2005'
                              , 'dd-mm-yyyy' )
                    , 'GRP01' );

        COMMIT;

        lib_proc.add_log ( 'RELACIONAMENTO REALIZADO'
                         , 0 );



        --- INSERE OBRIGAÇÃO FISCAL --

        INSERT INTO obrigacao_fiscal ( cod_empresa
                                     , cod_estab
                                     , cod_tipo_livro
                                     , ind_periodicidade
                                     , max_prazo_emissao
                                     , max_praz_apres
                                     , ind_ter_abe_fec
                                     , ind_enfeixamento
                                     , max_osc_permite
                                     , num_protocolo
                                     , dat_lib_prot
                                     , n_meses
                                     , iniciar
                                     , max_cont
                                     , livro_i
                                     , pagina_i
                                     , desloc_i
                                     , ind_livro_unico
                                     , vlr_lim_pagina
                                     , complemento_termo
                                     , titulo_livro )
             VALUES ( '081'
                    , pcodestab
                    , '501'
                    , 'ME'
                    , 5
                    , 5
                    , 'S'
                    , 'L'
                    , 0
                    , '10000'
                    , TO_DATE ( '01-01-2004'
                              , 'dd-mm-yyyy' )
                    , 0
                    , 'S'
                    , 1000000
                    , 1
                    , 1
                    , 0
                    , 'S'
                    , 9999
                    , NULL
                    , NULL );

        INSERT INTO obrigacao_fiscal ( cod_empresa
                                     , cod_estab
                                     , cod_tipo_livro
                                     , ind_periodicidade
                                     , max_prazo_emissao
                                     , max_praz_apres
                                     , ind_ter_abe_fec
                                     , ind_enfeixamento
                                     , max_osc_permite
                                     , num_protocolo
                                     , dat_lib_prot
                                     , n_meses
                                     , iniciar
                                     , max_cont
                                     , livro_i
                                     , pagina_i
                                     , desloc_i
                                     , ind_livro_unico
                                     , vlr_lim_pagina
                                     , complemento_termo
                                     , titulo_livro )
             VALUES ( '081'
                    , pcodestab
                    , '502'
                    , 'ME'
                    , 5
                    , 5
                    , 'S'
                    , 'L'
                    , 0
                    , '000213456578989'
                    , TO_DATE ( '01-01-2004'
                              , 'dd-mm-yyyy' )
                    , 1
                    , 'N'
                    , 1000000
                    , 1
                    , 1
                    , 0
                    , 'N'
                    , 500
                    , NULL
                    , NULL );

        INSERT INTO obrigacao_fiscal ( cod_empresa
                                     , cod_estab
                                     , cod_tipo_livro
                                     , ind_periodicidade
                                     , max_prazo_emissao
                                     , max_praz_apres
                                     , ind_ter_abe_fec
                                     , ind_enfeixamento
                                     , max_osc_permite
                                     , num_protocolo
                                     , dat_lib_prot
                                     , n_meses
                                     , iniciar
                                     , max_cont
                                     , livro_i
                                     , pagina_i
                                     , desloc_i
                                     , ind_livro_unico
                                     , vlr_lim_pagina
                                     , complemento_termo
                                     , titulo_livro )
             VALUES ( '081'
                    , pcodestab
                    , '503'
                    , 'ME'
                    , 2
                    , 4
                    , 'S'
                    , 'L'
                    , 0
                    , '100'
                    , TO_DATE ( '01-01-2000'
                              , 'dd-mm-yyyy' )
                    , 0
                    , 'S'
                    , 1000000
                    , 1
                    , 1
                    , 0
                    , 'S'
                    , 9999
                    , NULL
                    , NULL );

        COMMIT;

        lib_proc.add_log ( 'OBRIGAÇÕES MUNICIPAIS CADASTRADAS'
                         , 0 );


        --- INSERE OBRIGAÇÃO ESTADUAL --
        INSERT INTO obrigacao_fiscal ( cod_empresa
                                     , cod_estab
                                     , cod_tipo_livro
                                     , ind_periodicidade
                                     , max_prazo_emissao
                                     , max_praz_apres
                                     , ind_ter_abe_fec
                                     , ind_enfeixamento
                                     , max_osc_permite
                                     , num_protocolo
                                     , dat_lib_prot
                                     , n_meses
                                     , iniciar
                                     , max_cont
                                     , livro_i
                                     , pagina_i
                                     , desloc_i
                                     , ind_livro_unico
                                     , vlr_lim_pagina
                                     , complemento_termo
                                     , titulo_livro )
             VALUES ( '081'
                    , pcodestab
                    , '108'
                    , 'ME'
                    , 5
                    , 5
                    , 'S'
                    , 'L'
                    , 0
                    , '10000'
                    , TO_DATE ( '01-01-2004'
                              , 'dd-mm-yyyy' )
                    , 0
                    , 'S'
                    , 1000000
                    , 1
                    , 1
                    , 0
                    , 'S'
                    , 9999
                    , NULL
                    , NULL );

        lib_proc.add_log ( 'OBRIGAÇÕES ESTADUAIS CADASTRADAS'
                         , 0 );


        --- INSERE DADOS DE CIAP --
        INSERT INTO apt_estab ( cod_empresa
                              , cod_estab
                              , modelo
                              , ind_fracao_mensal
                              , pagina_modelo_a
                              , item_apuracao
                              , item_apuracao_te
                              , item_apuracao_ts
                              , descr_item_1
                              , descr_item_1_te
                              , descr_item_1_ts
                              , descr_item_2
                              , descr_item_2_te
                              , descr_item_2_ts
                              , cod_tipo_livro
                              , cod_classe_1
                              , cod_classe_te
                              , cod_classe_ts
                              , ind_lei
                              , ind_periodic_102
                              , cod_tp_lvr_102
                              , item_ap_102
                              , item_ap_te_102
                              , item_ap_ts_102
                              , descr_item_102
                              , descr_item_te_102
                              , desc_item_ts_102
                              , cod_classe_102
                              , cod_classe_ts_102
                              , cod_classe_te_102
                              , grupo_produto
                              , ind_produto
                              , cod_produto
                              , grupo_obs_livro
                              , cod_obs_livro
                              , cod_trib_int
                              , modelo_102
                              , pagina_modelo_c
                              , cod_indice
                              , apropria_dif_aliq
                              , grupo_natureza_op
                              , cod_natureza_op
                              , cod_amp_leg
                              , cod_sub_oco
                              , cod_amp_leg_te
                              , cod_sub_oco_te
                              , cod_amp_leg_ts
                              , cod_sub_oco_ts
                              , cod_amp_leg_102
                              , cod_sub_oco_102
                              , cod_amp_leg_te_102
                              , cod_sub_oco_te_102
                              , cod_amp_leg_ts_102
                              , cod_sub_oco_ts_102
                              , ident_estado
                              , ind_cred_mes_baixa
                              , tipo_mov
                              , tipo_modelo_102
                              , insc_estadual
                              , cod_cfo
                              , ind_local_bem )
             VALUES ( '081'
                    , pcodestab
                    , NULL
                    , 'M'
                    , NULL
                    , NULL
                    , NULL
                    , NULL
                    , NULL
                    , NULL
                    , NULL
                    , NULL
                    , NULL
                    , NULL
                    , NULL
                    , NULL
                    , NULL
                    , NULL
                    , '2'
                    , 'M'
                    , '108'
                    , NULL
                    , NULL
                    , NULL
                    , NULL
                    , NULL
                    , NULL
                    , NULL
                    , NULL
                    , NULL
                    , NULL
                    , NULL
                    , NULL
                    , NULL
                    , NULL
                    , NULL
                    , pcodmodelociap
                    , 3
                    , NULL
                    , '3'
                    , NULL
                    , NULL
                    , NULL
                    , NULL
                    , NULL
                    , NULL
                    , NULL
                    , NULL
                    , NULL
                    , NULL
                    , NULL
                    , NULL
                    , NULL
                    , NULL
                    , 76
                    , 'N'
                    , '003'
                    , '1'
                    , NULL
                    , NULL
                    , 'N' );

        COMMIT;

        INSERT INTO apt_ident_ciap ( cod_empresa
                                   , cod_estab
                                   , num_ciap )
             VALUES ( '081'
                    , pcodestab
                    , 1 );

        COMMIT;

        INSERT INTO apt_cfo_oper ( cod_empresa
                                 , cod_estab
                                 , cod_cfo
                                 , tipo_mov )
             VALUES ( '081'
                    , pcodestab
                    , '3551'
                    , '001' );

        COMMIT;

        lib_proc.add_log ( 'OBRIGAÇÃO DO CIAP CADASTRADA'
                         , 0 );

        -- INSERE AQUISIÇÃO --
        INSERT INTO apt_aquisicao ( cod_empresa
                                  , cod_estab
                                  , num_ciap
                                  , ano_registro
                                  , dat_oper
                                  , num_docfis
                                  , serie_docfis
                                  , sub_serie_docfis
                                  , dat_fiscal
                                  , ident_fis_jur
                                  , ident_cfo
                                  , ident_natureza_op
                                  , descr_bem
                                  , compl_descr_bem
                                  , modelo_bem
                                  , serie_bem
                                  , plaqueta_bem
                                  , vlr_aquis
                                  , vlr_cred_icms
                                  , num_lre
                                  , pag_lre
                                  , cod_bem
                                  , cod_inc
                                  , st_ativo
                                  , tipo_mov
                                  , ident_custo
                                  , ind_geracao
                                  , quantidade
                                  , ind_aquis_trib
                                  , num_oficial_ciap
                                  , num_meses_estorno
                                  , qtd_bens_alienados
                                  , num_controle_docto
                                  , num_processo
                                  , ind_gravacao
                                  , ind_lei
                                  , vlr_cred_dif_aliq
                                  , vlr_cred_mes1
                                  , vlr_cred_icms_conv
                                  , vlr_crdifaliq_conv
                                  , vlr_cred_mes1_conv
                                  , movto_e_s
                                  , norm_dev
                                  , ident_docto
                                  , num_docfis_ref
                                  , serie_docfis_ref
                                  , s_ser_docfis_ref
                                  , ident_projeto
                                  , ind_baixa_auto
                                  , vlr_icms_frete
                                  , vlr_difal_frete
                                  , vlr_icms_frete_cv
                                  , vlr_difal_frete_cv
                                  , dat_intern_am
                                  , local_bem )
             VALUES ( '081'
                    , pcodestab
                    , 1
                    , 2001
                    , TO_DATE ( '01-01-2005'
                              , 'dd-mm-yyyy' )
                    , '169895'
                    , ' '
                    , ' '
                    , TO_DATE ( '01-01-2005'
                              , 'dd-mm-yyyy' )
                    , 21196
                    , 1534
                    , NULL
                    , NULL
                    , 'VIDE NOTA FISCAL'
                    , NULL
                    , NULL
                    , NULL
                    , 55225.17
                    , 6627
                    , NULL
                    , NULL
                    , NULL
                    , NULL
                    , 'E'
                    , '001'
                    , NULL
                    , 'N'
                    , 1
                    , 'S'
                    , '2'
                    , 48
                    , NULL
                    , NULL
                    , 0
                    , '4'
                    , '2'
                    , NULL
                    , NULL
                    , NULL
                    , NULL
                    , NULL
                    , '1'
                    , '1'
                    , 355
                    , NULL
                    , NULL
                    , NULL
                    , NULL
                    , 'S'
                    , NULL
                    , NULL
                    , NULL
                    , NULL
                    , NULL
                    , NULL );

        COMMIT;

        lib_proc.add_log ( 'INSERIDO 1 REGISTRO DE AQUISIÇÃO'
                         , 0 );

        INSERT INTO apt_alienacao ( cod_empresa
                                  , cod_estab
                                  , num_ciap
                                  , dat_oper
                                  , tipo_mov
                                  , ano_registro
                                  , num_docfis
                                  , serie_docfis
                                  , sub_serie_docfis
                                  , modelo_docfis
                                  , dat_fiscal
                                  , dat_saida_bem
                                  , ident_fis_jur
                                  , ident_cfo
                                  , ident_natureza_op
                                  , vlr_alienacao
                                  , vlr_estorno_icms
                                  , vlr_cred_aprop
                                  , ident_custo
                                  , vlr_base_trib
                                  , vlr_base_isentas
                                  , cod_bem
                                  , cod_inc
                                  , qtd_bens_alienados
                                  , num_processo
                                  , ind_gravacao
                                  , ind_lei
                                  , tipo_baixa
                                  , vlr_icms_bx
                                  , vlr_difal_bx
                                  , vlr_icms_frete_bx
                                  , vlr_difal_frete_bx )
             VALUES ( '081'
                    , pcodestab
                    , 1
                    , TO_DATE ( '31-12-2008'
                              , 'dd-mm-yyyy' )
                    , '003'
                    , 2008
                    , ' '
                    , ' '
                    , ' '
                    , NULL
                    , TO_DATE ( '31-12-2008'
                              , 'dd-mm-yyyy' )
                    , TO_DATE ( '31-12-2008'
                              , 'dd-mm-yyyy' )
                    , NULL
                    , NULL
                    , NULL
                    , NULL
                    , NULL
                    , NULL
                    , NULL
                    , NULL
                    , NULL
                    , NULL
                    , NULL
                    , 1
                    , 822226
                    , '6'
                    , '2'
                    , '1'
                    , 6627
                    , 0
                    , 0
                    , 0 );

        COMMIT;

        lib_proc.add_log ( 'INSERIDO 1 REGISTRO DE ALIENAÇÃO POR DEPRECIAÇÃO'
                         , 0 );

        lib_proc.add_log ( 'FINALIZADO COM SUCESSO'
                         , 0 );


        --- FIM DO BLOCO ---



        lib_proc.add_log (    'Termino da Geração de Dados para Chamado: '
                           || TO_CHAR ( SYSDATE
                                      , 'DD/MM/YYYY HH24:MI:SS' )
                         , 2 );


        --fecho o processo
        lib_proc.close;

        COMMIT;
        RETURN mproc_id;
    EXCEPTION
        WHEN OTHERS THEN
            lib_proc.add_log ( 'Erro não tratado: ' || SQLERRM
                             , 1 );
            lib_proc.close;
            COMMIT;
            RETURN mproc_id;
    END;



    PROCEDURE rec_cnpj_ie ( p_cod_estado IN VARCHAR2
                          , p_cnpj   OUT VARCHAR2
                          , p_ie   OUT VARCHAR2 )
    IS
    BEGIN
        IF p_cod_estado = 'AC' THEN
            p_cnpj := '04566444000140';
            p_ie := '0100323500125';
        ELSIF p_cod_estado = 'AL' THEN
            p_cnpj := '08486938000175';
            p_ie := '240667948';
        ELSIF p_cod_estado = 'AP' THEN
            p_cnpj := '33193939000500';
            p_ie := '030060341';
        ELSIF p_cod_estado = 'AM' THEN
            p_cnpj := '84136969000184';
            p_ie := '041193270';
        ELSIF p_cod_estado = 'BA' THEN
            p_cnpj := '77623163001712';
            p_ie := '46302997';
        ELSIF p_cod_estado = 'CE' THEN
            p_cnpj := '02316187000162';
            p_ie := '68922582';
        ELSIF p_cod_estado = 'DF' THEN
            p_cnpj := '02606648000131';
            p_ie := '0733103800108';
        ELSIF p_cod_estado = 'ES' THEN
            p_cnpj := '32459448000164';
            p_ie := '081349114';
        ELSIF p_cod_estado = 'GO' THEN
            p_cnpj := '023292171000175';
            p_ie := '101595590';
        ELSIF p_cod_estado = 'MA' THEN
            p_cnpj := '00738686000112';
            p_ie := '121441016';
        ELSIF p_cod_estado = 'MT' THEN
            p_cnpj := '24722647000195';
            p_ie := '130612014';
        ELSIF p_cod_estado = 'MS' THEN
            p_cnpj := '03736691000184';
            p_ie := '280906030';
        ELSIF p_cod_estado = 'MG' THEN
            p_cnpj := '19784248000119';
            p_ie := '0622900530031';
        ELSIF p_cod_estado = 'PA' THEN
            p_cnpj := '77623163002956';
            p_ie := '151106355';
        ELSIF p_cod_estado = 'PB' THEN
            p_cnpj := '00853493000102';
            p_ie := '161096573';
        ELSIF p_cod_estado = 'PR' THEN
            p_cnpj := '77623163000317';
            p_ie := '1100002511';
        ELSIF p_cod_estado = 'PE' THEN
            p_cnpj := '77623163003847';
            p_ie := '18100101093962';
        ELSIF p_cod_estado = 'PI' THEN
            p_cnpj := '06862627000138';
            p_ie := '194009696';
        ELSIF p_cod_estado = 'RJ' THEN
            p_cnpj := '77623163004223';
            p_ie := '83312149';
        ELSIF p_cod_estado = 'RN' THEN
            p_cnpj := '08471666000130';
            p_ie := '200347721';
        ELSIF p_cod_estado = 'RS' THEN
            p_cnpj := '77623163001208';
            p_ie := '0960636447';
        ELSIF p_cod_estado = 'RO' THEN
            p_cnpj := '05934112000133';
            p_ie := '101113441';
        ELSIF p_cod_estado = 'RR' THEN
            p_cnpj := '00348003010183';
            p_ie := '240006224';
        ELSIF p_cod_estado = 'SE' THEN
            p_cnpj := '77623163004495';
            p_ie := '251874109';
        ELSIF p_cod_estado = 'SP' THEN
            p_cnpj := '61064911000177';
            p_ie := '535054653118';
        ELSIF p_cod_estado = 'TO' THEN
            p_cnpj := '01128149000113';
            p_ie := ' ';
        END IF;
    END;



    PROCEDURE teste
    IS
        mproc_id INTEGER;
    BEGIN
        lib_parametros.salvar ( 'empresa'
                              , '081' );
        mproc_id :=
            executar ( 'CH2007'
                     , 'RJ'
                     , 'C' );
        lib_proc.list_output ( mproc_id
                             , 1 );
        dbms_output.put_line ( '' );
        -- DBMS_OUTPUT.PUT_LINE('---arquivo magnetico----');
        dbms_output.put_line ( '' );
        lib_proc.list_output ( mproc_id
                             , 2 );
    END;
END;
/
SHOW ERRORS;
