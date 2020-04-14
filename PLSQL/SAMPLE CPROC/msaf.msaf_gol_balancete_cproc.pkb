Prompt Package Body MSAF_GOL_BALANCETE_CPROC;
--
-- MSAF_GOL_BALANCETE_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY msaf_gol_balancete_cproc
IS
    --variáveis de status

    mcod_estab estabelecimento.cod_estab%TYPE;
    mcod_empresa empresa.cod_empresa%TYPE;
    mcod_usuario usuario_estab.cod_usuario%TYPE;

    mlinha VARCHAR2 ( 4000 );

    v_estab VARCHAR2 ( 20 );
    v_cgc VARCHAR2 ( 20 );
    v_razao_social VARCHAR2 ( 100 );

    v_linha NUMBER ( 20 ) := 0;
    v_folha NUMBER ( 6 ) := 1;

    v_saldo_anterior_deb NUMBER := 0;
    v_saldo_anterior_cred NUMBER := 0;
    v_saldo_anterior VARCHAR2 ( 30 ) := 0;
    --  V_IND_INI             char(1)          := '@';

    v_saldo_final_deb NUMBER := 0;
    v_saldo_final_cred NUMBER := 0;
    v_saldo_final VARCHAR2 ( 30 ) := 0;
    --  V_IND_FIM             char(1)          := '@';

    --w_ultlancto   varchar2(10);
    v_descricao VARCHAR2 ( 100 ) := '@';


    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );
    BEGIN
        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        mcod_estab := NVL ( lib_parametros.recuperar ( 'ESTABELECIMENTO' ), '' );
        mcod_usuario := lib_parametros.recuperar ( 'Usuario' );

        lib_proc.add_param (
                             pstr
                           , 'Estabelecimento'
                           , 'Varchar2'
                           , 'Combobox'
                           , 'S'
                           , NULL
                           , NULL
                           ,    'SELECT DISTINCT cod_estab, cod_estab||'' - ''||razao_social '
                             || 'FROM estabelecimento WHERE COD_EMPRESA = '''
                             || mcod_empresa
                             || ''' and cod_estab = nvl('''
                             || mcod_estab
                             || ''', cod_estab) ORDER BY 1'
        );
        lib_proc.add_param ( pstr
                           , 'Data Inicial'
                           , 'Date'
                           , 'textbox'
                           , 'S'
                           , NULL
                           , 'DD/MM/YYYY' );
        lib_proc.add_param ( pstr
                           , 'Data Final'
                           , 'Date'
                           , 'textbox'
                           , 'S'
                           , NULL
                           , 'DD/MM/YYYY' );

        RETURN pstr;
    END;

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Balancete Customizado';
    END;

    FUNCTION tipo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Balancete Customizado';
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
        RETURN 'Balancete Customizado';
    END;

    FUNCTION modulo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Customizados';
    END;

    FUNCTION classificacao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Customizados';
    END;

    FUNCTION orientacao
        RETURN VARCHAR2
    IS
    BEGIN
        /* Orientação do Papel. */
        RETURN 'LANDSCAPE';
    END;


    FUNCTION executar ( pcod_estab VARCHAR2
                      , pdataini DATE
                      , pdatafim DATE )
        RETURN INTEGER
    IS
        /* Variaveis de Trabalho */
        mproc_id INTEGER;
        mlinha VARCHAR2 ( 160 );
    BEGIN
        -- Cria Processo / Procedure

        DECLARE
            -- Inicio Cr01
            CURSOR cur_c ( ccd_estab VARCHAR2
                         , pdataini DATE
                         , pdatafim DATE )
            IS
                SELECT   x02.cod_empresa AS cod_empresa
                       , x02.cod_estab AS cod_estab
                       , SUBSTR ( x2002.cod_conta
                                , 15
                                , 10 )
                             AS conta_contabil
                       , --           X2002.DESCRICAO                    AS  DESCRICAO,
                         --           X02.VLR_SALDO_INI                  AS  SALDO_ANTERIOR,
                         --           X02.IND_SALDO_INI                  AS  IND_SALDO_ANT,
                         SUM ( x02.vlr_tot_cre ) AS vlr_credito
                       , SUM ( x02.vlr_tot_deb ) AS vlr_debito --,
                    --           X02.VLR_SALDO_FIM                  AS  SALDO_ATUAL,
                    --           X02.IND_SALDO_FIM                  AS  IND_SALDO_FIM
                    FROM x02_saldos x02
                       , x2002_plano_contas x2002
                   WHERE x02.ident_conta = x2002.ident_conta
                     AND x02.cod_empresa = mcod_empresa
                     AND x02.cod_estab = DECODE ( pcod_estab, 'TODOS', x02.cod_estab, pcod_estab )
                     AND x02.data_saldo BETWEEN pdataini AND pdatafim
                     AND x02.data_saldo >= '01/02/2004'
                /*  AND    X02.VLR_SALDO_INI     > 0
                    AND    X02.VLR_SALDO_FIM     > 0
                    AND    X02.VLR_TOT_CRE       > 0
                    AND    X02.VLR_TOT_DEB       > 0    */
                GROUP BY x02.cod_empresa
                       , x02.cod_estab
                       , SUBSTR ( x2002.cod_conta
                                , 15
                                , 10 ) --,
                --             X2002.DESCRICAO--, X02.VLR_TOT_CRE, X02.VLR_TOT_DEB
                UNION ALL
                SELECT   x02.cod_empresa AS cod_empresa
                       , x02.cod_estab AS cod_estab
                       , x2002.cod_conta AS conta_contabil
                       , --           X2002.DESCRICAO                    AS  DESCRICAO,
                         --           X02.VLR_SALDO_INI                  AS  SALDO_ANTERIOR,
                         --           X02.IND_SALDO_INI                  AS  IND_SALDO_ANT,
                         SUM ( x02.vlr_tot_cre ) AS vlr_credito
                       , SUM ( x02.vlr_tot_deb ) AS vlr_debito --,
                    --           X02.VLR_SALDO_FIM                  AS  SALDO_ATUAL,
                    --           X02.IND_SALDO_FIM                  AS  IND_SALDO_FIM
                    FROM x02_saldos x02
                       , x2002_plano_contas x2002
                   WHERE x02.ident_conta = x2002.ident_conta
                     AND LENGTH ( x2002.cod_conta ) <= 10
                     AND x02.cod_empresa = mcod_empresa
                     AND x02.cod_estab = DECODE ( pcod_estab, 'TODOS', x02.cod_estab, pcod_estab )
                     AND x02.data_saldo BETWEEN pdataini AND pdatafim
                --AND    X2002.COD_CONTA       = '1101030023'
                /*  AND    X02.VLR_SALDO_INI     > 0
                    AND    X02.VLR_SALDO_FIM     > 0
                    AND    X02.VLR_TOT_CRE       > 0
                    AND    X02.VLR_TOT_DEB       > 0    */
                GROUP BY x02.cod_empresa
                       , x02.cod_estab
                       , x2002.cod_conta;
        --             X2002.DESCRICAO--, X02.VLR_TOT_CRE, X02.VLR_TOT_DEB
        -- ORDER BY 3;
        --fim Cr01


        BEGIN
            -- Cria Processo / Procedure
            mproc_id :=
                lib_proc.new ( 'MSAF_GOL_BALANCETE_CPROC'
                             , 47
                             , 160 );

            lib_proc.add_tipo ( mproc_id
                              , 1
                              , 'Balancete GOL'
                              , 1 );

            mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
            mcod_estab := NVL ( lib_parametros.recuperar ( 'ESTABELECIMENTO' ), '' );
            mcod_usuario := lib_parametros.recuperar ( 'Usuario' );

            --localiza os campos para geração do cabeçalho
            BEGIN
                SELECT est.cod_estab AS cod_estab
                     , est.cgc AS cnpj
                     , est.razao_social AS razao_social
                  INTO v_estab
                     , v_cgc
                     , v_razao_social
                  FROM estabelecimento est
                 WHERE est.cod_empresa = mcod_empresa
                   AND est.cod_estab = DECODE ( pcod_estab, 'TODOS', est.cod_estab, pcod_estab );
            EXCEPTION
                WHEN OTHERS THEN
                    v_estab := '@';
                    v_cgc := '@';
                    v_razao_social := '@';
            END;

            --monta o cabeçalho
            cabecalho ( v_cgc
                      , v_estab || ' - ' || v_razao_social
                      , pdataini
                      , pdatafim
                      , v_folha );

            v_folha := v_folha + 1;
            v_linha := v_linha + 8;

            --inicia o processamento do relatório.
            FOR mreg IN cur_c ( pcod_estab
                              , pdataini
                              , pdatafim ) LOOP
                -- calcula o saldo inicial
                BEGIN
                    SELECT SUM ( x02.vlr_saldo_ini ) AS saldo_anterior_deb
                      INTO v_saldo_anterior_deb
                      FROM x02_saldos x02
                         , x2002_plano_contas x2002
                     WHERE x02.ind_saldo_ini = 'D'
                       AND x02.ident_conta = x2002.ident_conta
                       AND ( SUBSTR ( LTRIM ( RTRIM ( x2002.cod_conta ) )
                                    , 15
                                    , 10 ) = mreg.conta_contabil
                         OR LTRIM ( RTRIM ( x2002.cod_conta ) ) = mreg.conta_contabil )
                       AND x02.cod_empresa = mcod_empresa
                       AND x02.cod_estab = DECODE ( pcod_estab, 'TODOS', x02.cod_estab, pcod_estab )
                       AND x02.data_saldo BETWEEN pdataini AND pdatafim;
                EXCEPTION
                    WHEN OTHERS THEN
                        v_saldo_anterior_deb := 0;
                END;

                BEGIN
                    SELECT SUM ( x02.vlr_saldo_ini * -1 ) AS saldo_anterior_cred
                      INTO v_saldo_anterior_cred
                      FROM x02_saldos x02
                         , x2002_plano_contas x2002
                     WHERE x02.ind_saldo_ini = 'C'
                       AND x02.ident_conta = x2002.ident_conta
                       AND ( SUBSTR ( LTRIM ( RTRIM ( x2002.cod_conta ) )
                                    , 15
                                    , 10 ) = mreg.conta_contabil
                         OR LTRIM ( RTRIM ( x2002.cod_conta ) ) = mreg.conta_contabil )
                       AND x02.cod_empresa = mcod_empresa
                       AND x02.cod_estab = DECODE ( pcod_estab, 'TODOS', x02.cod_estab, pcod_estab )
                       AND x02.data_saldo BETWEEN pdataini AND pdatafim;
                EXCEPTION
                    WHEN OTHERS THEN
                        v_saldo_anterior_cred := 0;
                END;

                v_saldo_anterior := NVL ( v_saldo_anterior_deb, 0 ) + NVL ( v_saldo_anterior_cred, 0 );

                -- define o indicador do saldo inicial
                IF v_saldo_anterior < 0 THEN
                    v_saldo_anterior :=
                           '('
                        || REPLACE ( REPLACE ( REPLACE ( LTRIM ( RTRIM ( TO_CHAR ( ABS ( v_saldo_anterior )
                                                                                 , '999,999,999,999,999.99' ) ) )
                                                       , '.'
                                                       , '-' )
                                             , ','
                                             , '.' )
                                   , '-'
                                   , ',' )
                        || ')';
                ELSE
                    v_saldo_anterior :=
                        REPLACE ( REPLACE ( REPLACE ( LTRIM ( RTRIM ( TO_CHAR ( ABS ( v_saldo_anterior )
                                                                              , '999,999,999,999,999.99' ) ) )
                                                    , '.'
                                                    , '-' )
                                          , ','
                                          , '.' )
                                , '-'
                                , ',' );
                END IF;

                -- calcula o saldo final
                BEGIN
                    SELECT SUM ( x02.vlr_saldo_fim ) AS saldo_final_deb
                      INTO v_saldo_final_deb
                      FROM x02_saldos x02
                         , x2002_plano_contas x2002
                     WHERE x02.ind_saldo_fim = 'D'
                       AND x02.ident_conta = x2002.ident_conta
                       AND ( SUBSTR ( LTRIM ( RTRIM ( x2002.cod_conta ) )
                                    , 15
                                    , 10 ) = mreg.conta_contabil
                         OR LTRIM ( RTRIM ( x2002.cod_conta ) ) = mreg.conta_contabil )
                       AND x02.cod_empresa = mcod_empresa
                       AND x02.cod_estab = DECODE ( pcod_estab, 'TODOS', x02.cod_estab, pcod_estab )
                       AND x02.data_saldo BETWEEN pdataini AND pdatafim;
                EXCEPTION
                    WHEN OTHERS THEN
                        v_saldo_final_deb := 0;
                END;

                BEGIN
                    SELECT SUM ( x02.vlr_saldo_fim * -1 ) AS saldo_final_cred
                      INTO v_saldo_final_cred
                      FROM x02_saldos x02
                         , x2002_plano_contas x2002
                     WHERE x02.ind_saldo_fim = 'C'
                       AND x02.ident_conta = x2002.ident_conta
                       AND ( SUBSTR ( LTRIM ( RTRIM ( x2002.cod_conta ) )
                                    , 15
                                    , 10 ) = mreg.conta_contabil
                         OR LTRIM ( RTRIM ( x2002.cod_conta ) ) = mreg.conta_contabil )
                       AND x02.cod_empresa = mcod_empresa
                       AND x02.cod_estab = DECODE ( pcod_estab, 'TODOS', x02.cod_estab, pcod_estab )
                       AND x02.data_saldo BETWEEN pdataini AND pdatafim;
                EXCEPTION
                    WHEN OTHERS THEN
                        v_saldo_final_cred := 0;
                END;

                v_saldo_final := NVL ( v_saldo_final_deb, 0 ) + NVL ( v_saldo_final_cred, 0 );

                -- define o indicador do saldo inicial
                IF v_saldo_final < 0 THEN
                    v_saldo_final :=
                           '('
                        || REPLACE ( REPLACE ( REPLACE ( LTRIM ( RTRIM ( TO_CHAR ( ABS ( v_saldo_final )
                                                                                 , '999,999,999,999,999.99' ) ) )
                                                       , '.'
                                                       , '-' )
                                             , ','
                                             , '.' )
                                   , '-'
                                   , ',' )
                        || ')';
                ELSE
                    v_saldo_final :=
                        REPLACE ( REPLACE ( REPLACE ( LTRIM ( RTRIM ( TO_CHAR ( ABS ( v_saldo_final )
                                                                              , '999,999,999,999,999.99' ) ) )
                                                    , '.'
                                                    , '-' )
                                          , ','
                                          , '.' )
                                , '-'
                                , ',' );
                END IF;

                -- BUSCA DESCRICAO DA CONTA
                BEGIN
                    SELECT DISTINCT descricao
                      INTO v_descricao
                      FROM x2002_plano_contas x2002
                     WHERE ( SUBSTR ( x2002.cod_conta
                                    , 15
                                    , 10 ) = mreg.conta_contabil
                         OR x2002.cod_conta = mreg.conta_contabil )
                       AND ROWNUM = 1
                       AND x2002.grupo_conta = '001';
                EXCEPTION
                    WHEN OTHERS THEN
                        v_descricao := '@';
                END;

                --insere linha

                mlinha :=
                    lib_str.w ( mlinha
                              , mreg.conta_contabil
                              , 2 );
                mlinha :=
                    lib_str.w ( mlinha
                              , '|'
                              , 18 );
                mlinha :=
                    lib_str.w ( mlinha
                              , SUBSTR ( v_descricao
                                       , 1
                                       , 30 )
                              , 20 );
                mlinha :=
                    lib_str.w ( mlinha
                              , '|'
                              , 57 );

                mlinha :=
                    lib_str.w ( mlinha
                              , v_saldo_anterior
                              , 60 );
                mlinha :=
                    lib_str.w ( mlinha
                              , '|'
                              , 80 );
                mlinha :=
                    lib_str.w ( mlinha
                              , REPLACE ( REPLACE ( REPLACE ( LTRIM ( RTRIM ( TO_CHAR ( mreg.vlr_debito
                                                                                      , '999,999,999,999,999.99' ) ) )
                                                            , '.'
                                                            , '-' )
                                                  , ','
                                                  , '.' )
                                        , '-'
                                        , ',' )
                              , 103 );
                mlinha :=
                    lib_str.w ( mlinha
                              , '|'
                              , 100 );
                mlinha :=
                    lib_str.w ( mlinha
                              , REPLACE ( REPLACE ( REPLACE ( LTRIM ( RTRIM ( TO_CHAR ( mreg.vlr_credito
                                                                                      , '999,999,999,999,999.99' ) ) )
                                                            , '.'
                                                            , '-' )
                                                  , ','
                                                  , '.' )
                                        , '-'
                                        , ',' )
                              , 83 );
                mlinha :=
                    lib_str.w ( mlinha
                              , '|'
                              , 120 );
                mlinha :=
                    lib_str.w ( mlinha
                              , v_saldo_final
                              , 125 );


                lib_proc.add ( mlinha );

                v_linha := v_linha + 1;

                IF v_linha >= 43 THEN
                    lib_proc.new_page ( );
                    cabecalho ( v_cgc
                              , v_estab || ' - ' || v_razao_social
                              , pdataini
                              , pdatafim
                              , v_folha );

                    v_folha := v_folha + 1;
                    v_linha := 0;

                    -- Quantidade de linhas suficientes para a montagem do cabeçalho
                    v_linha := v_linha + 8;
                END IF;

                mlinha :=
                    lib_str.w ( ''
                              , ' '
                              , 1 );
                mlinha :=
                    lib_str.w ( mlinha
                              ,    LPAD ( ' '
                                        , 158
                                        , ' ' )
                                || ' '
                              , 2 );
                lib_proc.add ( mlinha );

                v_linha := v_linha + 1;
            END LOOP;
        END;

        lib_proc.close ( );

        RETURN mproc_id;
    END;

    PROCEDURE cabecalho ( p_cgc VARCHAR2
                        , p_razao_social VARCHAR2
                        , p_dat_ini DATE
                        , p_dat_fim DATE
                        , p_pagina VARCHAR2 )
    IS
        mlinha VARCHAR2 ( 160 );
    BEGIN
        mlinha :=
            lib_str.w ( ''
                      , ' '
                      , 1 );
        mlinha :=
            lib_str.w ( mlinha
                      ,    LPAD ( ' '
                                , 158
                                , ' ' )
                        || ' '
                      , 2 );
        lib_proc.add ( mlinha );

        mlinha :=
            lib_str.w ( ''
                      , ' '
                      , 1 );
        mlinha :=
            lib_str.w ( mlinha
                      , 'EMPRESA: ' || p_razao_social
                      , 2 );
        mlinha :=
            lib_str.w ( mlinha
                      , 'C.N.P.J.:  ' || p_cgc
                      , 120 );
        mlinha :=
            lib_str.w ( mlinha
                      , ' '
                      , 160 );
        lib_proc.add ( mlinha );

        mlinha :=
            lib_str.w ( ''
                      , ' '
                      , 1 );
        mlinha :=
            lib_str.w ( mlinha
                      ,    'Data Geração: '
                        || TO_CHAR ( SYSDATE
                                   , 'dd/mm/rrrr hh24:mi' )
                      , 2 );
        mlinha :=
            lib_str.w ( mlinha
                      , 'Período : ' || p_dat_ini || ' a ' || p_dat_fim
                      , 120 );
        lib_proc.add ( mlinha );

        mlinha :=
            lib_str.w ( ''
                      , ' '
                      , 1 );
        mlinha :=
            lib_str.w ( mlinha
                      ,    'Pagina  : '
                        || LPAD ( p_pagina
                                , 4
                                , 0 )
                      , 120 );
        lib_proc.add ( mlinha );
        --

        mlinha :=
            lib_str.w ( ''
                      , ' '
                      , 1 );
        mlinha :=
            lib_str.wcenter ( mlinha
                            , 'B A L A N C E T E   A N A L I T I C O   D E   V E R I F I C A C Ã O'
                            , 150 );
        lib_proc.add ( mlinha );

        mlinha :=
            lib_str.w ( mlinha
                      ,    RPAD ( '='
                                , 150
                                , '=' )
                        || ' '
                      , 1 );
        lib_proc.add ( mlinha );

        mlinha := NULL;

        mlinha :=
            lib_str.w ( mlinha
                      , 'CONTA CONTABIL'
                      , 2 );

        mlinha :=
            lib_str.w ( mlinha
                      , '|'
                      , 18 );
        mlinha :=
            lib_str.w ( mlinha
                      , 'DESCRIÇÃO'
                      , 30 );

        mlinha :=
            lib_str.w ( mlinha
                      , '|'
                      , 57 );
        mlinha :=
            lib_str.w ( mlinha
                      , 'SALDO ANTERIOR'
                      , 61 );

        mlinha :=
            lib_str.w ( mlinha
                      , '|'
                      , 80 );
        mlinha :=
            lib_str.w ( mlinha
                      , 'TOTAL CREDITO'
                      , 84 );

        mlinha :=
            lib_str.w ( mlinha
                      , '|'
                      , 100 );
        mlinha :=
            lib_str.w ( mlinha
                      , 'TOTAL DEBITO'
                      , 104 );

        mlinha :=
            lib_str.w ( mlinha
                      , '|'
                      , 120 );
        mlinha :=
            lib_str.w ( mlinha
                      , 'SALDO ATUAL'
                      , 129 );

        lib_proc.add ( mlinha );
        mlinha :=
            lib_str.w ( mlinha
                      ,    RPAD ( '='
                                , 150
                                , '=' )
                        || ' '
                      , 1 );
        lib_proc.add ( mlinha );

        v_linha := v_linha + 1;
    END;
END msaf_gol_balancete_cproc;
/
SHOW ERRORS;
