Prompt Package Body CST_REL_ACCOUNT_BALANCE_CPROC;
--
-- CST_REL_ACCOUNT_BALANCE_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY cst_rel_account_balance_cproc
IS
    mcod_empresa empresa.cod_empresa%TYPE;
    mproc_id INTEGER;
    p_colunas INTEGER := 154;
    v_linha INTEGER := 0;
    p_pagina INTEGER := 0;
    v_text01 VARCHAR2 ( 10000 );

    --Tipo, Nome e Descrição do Customizado
    mnm_tipo VARCHAR2 ( 100 ) := 'Conferencia Conta FC';
    mnm_cproc VARCHAR2 ( 100 ) := '03-Relatorio de valor lancamentos contabeis FC';
    mds_cproc VARCHAR2 ( 100 ) := mnm_cproc;

    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );
    BEGIN
        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        musuario := lib_parametros.recuperar ( 'USUARIO' );

        --1
        lib_proc.add_param ( pstr
                           , 'Data Inicial'
                           , 'DATE'
                           , 'TEXTBOX'
                           , 'S'
                           , NULL
                           , 'MM/YYYY' );

        --3
        lib_proc.add_param (
                             pparam => pstr
                           , ptitulo => 'Empresa'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'COMBOBOX'
                           , pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => '####################'
                           , pvalores =>    'SELECT COD_EMPRESA, COD_EMPRESA || '' - '' || RAZAO_SOCIAL TXT FROM EMPRESA '
                                         || '  ORDER BY 1'
                           , phabilita => 'S'
        );

        RETURN pstr;
    END; --FUNCTION PARAMETROS RETURN VARCHAR2 IS

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN mnm_cproc;
    END;

    FUNCTION tipo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN mnm_tipo;
    END;

    FUNCTION versao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'VERSAO 1.0';
    END;

    FUNCTION descricao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN mds_cproc;
    END;

    FUNCTION modulo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'CONFERENCIA';
    END;

    FUNCTION classificacao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'PROCESSOS CUSTOMIZADOS';
    END;

    FUNCTION alinha ( texto VARCHAR2
                    , tamanho INTEGER )
        RETURN VARCHAR2
    IS
        qtde_caracter INTEGER := LENGTH ( texto );
        texto_alinhado VARCHAR2 ( 5000 );
    BEGIN
        texto_alinhado :=
               RPAD ( ' '
                    , TRUNC ( ( tamanho - qtde_caracter ) / 2 )
                    , ' ' )
            || texto
            || LPAD ( ' '
                    , tamanho - qtde_caracter - TRUNC ( ( tamanho - qtde_caracter ) / 2 )
                    , ' ' );

        RETURN texto_alinhado;
    END;

    PROCEDURE loga ( p_i_texto IN VARCHAR2
                   , p_i_dttm IN BOOLEAN DEFAULT TRUE )
    IS
        vtexto VARCHAR2 ( 1024 );
    BEGIN
        dbms_output.put_line ( p_i_texto );

        IF p_i_dttm THEN
            vtexto :=
                SUBSTR (    TO_CHAR ( SYSDATE
                                    , 'DD/MM/YYYY HH24:MI:SS' )
                         || ' - '
                         || p_i_texto
                       , 1
                       , 1024 );
        ELSE
            vtexto :=
                SUBSTR ( p_i_texto
                       , 1
                       , 1024 );
        END IF;

        lib_proc.add_log ( vtexto
                         , 1 );

        COMMIT;
    ---
    END;

    --PROCEDURE DELETE_TEMP_TBL

    PROCEDURE grava ( p_texto VARCHAR2
                    , p_tipo VARCHAR2 DEFAULT '1' )
    IS
    BEGIN
        lib_proc.add ( p_texto
                     , ptipo => p_tipo );
    END;

    PROCEDURE cabecalho_analitico ( p_cod_empresa VARCHAR2
                                  , p_periodo DATE )
    IS
        v_texto VARCHAR2 ( 2000 );
    BEGIN
        SELECT    razao_social
               || ' - '
               || REGEXP_REPLACE ( LPAD ( cnpj
                                        , 14
                                        , '0' )
                                 , '([0-9]{2})([0-9]{3})([0-9]{3})([0-9]{4})([0-9]{2})'
                                 , '\1.\2.\3/\4-\5' )
                   AS cnpj
          INTO v_texto
          FROM empresa
         WHERE cod_empresa = p_cod_empresa;

        p_pagina := p_pagina + 1;

        v_linha := v_linha + 1;
        lib_proc.add ( LPAD ( '.'
                            , p_colunas
                            , ' ' )
                     , p_pagina
                     , v_linha );

        v_linha := v_linha + 1;
        lib_proc.add (    RPAD ( ' 55BP70'
                               , p_colunas - 16
                               , ' ' )
                       || 'Pagina:'
                       || LPAD ( p_pagina
                               , 16 - 7
                               , ' ' )
                     , p_pagina
                     , v_linha );

        v_linha := v_linha + 1;
        lib_proc.add (    alinha ( 'Balancete Geral Analitico'
                                 , p_colunas - 16 )
                       || 'Data:   '
                       || TO_CHAR ( SYSDATE
                                  , 'DD/MM/YY' )
                     , p_pagina
                     , v_linha );

        v_linha := v_linha + 1;
        lib_proc.add (    ' Periodo - De '
                       || TO_CHAR ( TRUNC ( p_periodo )
                                  , 'DD/MM/YY' )
                       || ' Ate '
                       || TO_CHAR ( LAST_DAY ( p_periodo )
                                  , 'DD/MM/YY' )
                       || SUBSTR ( alinha ( v_texto
                                          , p_colunas - 16 )
                                 , 36 )
                       || 'Data:   '
                       || TO_CHAR ( SYSDATE
                                  , 'HH24:MI:SS' )
                     , p_pagina
                     , v_linha );

        v_linha := v_linha + 1;
        lib_proc.add ( RPAD ( ' '
                            , p_colunas
                            , '-' )
                     , p_pagina
                     , v_linha );

        v_texto :=
               ' '
            || RPAD ( 'Conta'
                    , 14
                    , ' ' ) --
            || RPAD ( 'Descrição'
                    , 40
                    , ' ' ) --
            || alinha ( 'Saldo'
                      , 22 ) --
            || alinha ( 'Movimento do Mes'
                      , 21 ) --
            || alinha ( 'Movimento do Mes'
                      , 23 ) --
            || alinha ( 'Saldo'
                      , 21 ) --
            || alinha ( 'Conta'
                      , 11 ) --
                            ;
        v_linha := v_linha + 1;
        lib_proc.add ( v_texto
                     , p_pagina
                     , v_linha );

        v_texto :=
               ' '
            || LPAD ( ' '
                    , 14
                    , ' ' ) --
            || LPAD ( ' '
                    , 40
                    , ' ' ) --
            || alinha ( 'Anterior'
                      , 22 ) --
            || alinha ( 'Debito'
                      , 21 ) --
            || alinha ( 'Credito'
                      , 23 ) --
            || alinha ( 'Atual'
                      , 21 ) --
            || alinha ( 'FC'
                      , 11 ) --
                            ;
        v_linha := v_linha + 1;
        lib_proc.add ( v_texto
                     , p_pagina
                     , v_linha );

        v_linha := v_linha + 1;
        lib_proc.add ( RPAD ( ' '
                            , p_colunas
                            , '-' )
                     , p_pagina
                     , v_linha );
    END;

    PROCEDURE grava_analitico ( vp_data DATE
                              , p_cod_empresa VARCHAR2
                              , p_tipo VARCHAR2 DEFAULT '1' )
    IS
        v_limite_linhas INTEGER := 70;
    BEGIN
        lib_proc.add_tipo ( mproc_id
                          , p_tipo
                          ,    'CST_REL_ACCOUNT_BALANCE_'
                            || p_cod_empresa
                            || '_'
                            || TO_CHAR ( vp_data
                                       , 'YYYYMM' )
                            || '.TXT'
                          , 2 );

        cabecalho_analitico ( p_cod_empresa
                            , vp_data );

        DELETE cst_account_balance_fc;

        COMMIT;

        -- insert dados analiticos
        INSERT INTO cst_account_balance_fc --
                                           ( cod_conta
                                           , descricao
                                           , ind_saldo_ini
                                           , vlr_saldo_ini
                                           , vlr_tot_deb
                                           , vlr_tot_cre
                                           , ind_saldo_fim
                                           , vlr_saldo_fim
                                           , cod_conta_fc
                                           , nivel
                                           , num_ordem_1
                                           , num_ordem_2 )
            WITH saldo
                 AS (SELECT TO_CHAR ( x2002.cod_conta ) cod_conta
                          , x2002.descricao
                          , x02.ind_saldo_ini
                          , x02.vlr_saldo_ini vlr_saldo_ini
                          , x02.vlr_tot_deb vlr_tot_deb
                          , x02.vlr_tot_cre vlr_tot_cre
                          , x02.ind_saldo_fim
                          , x02.vlr_saldo_fim vlr_saldo_fim
                          , NVL (
                                  ( SELECT MAX ( cod_conta_fc ) KEEP (DENSE_RANK LAST ORDER BY dp.data_valid_inicio)
                                               cod_conta_fc
                                      FROM cst_conta_de_para_msaf_fc dp
                                     WHERE dp.data_valid_inicio <= x02.data_saldo
                                       AND cod_conta_msaf = x2002.cod_conta )
                                , '-1'
                            )
                                cod_conta_fc
                          , 1 nivel
                       FROM x02_saldos x02
                          , x2002_plano_contas x2002
                      WHERE x02.ident_conta = x2002.ident_conta
                        AND x02.cod_empresa = p_cod_empresa
                        AND x02.data_saldo = LAST_DAY ( vp_data ))
               , --
                 conta_fc
                 AS (SELECT a.cod_conta_fc
                          , NVL ( a.num_ordem, b.num_ordem ) num_ordem_1
                          , NVL ( b.num_ordem, 0 ) num_ordem_2
                       FROM cst_conta_fc a
                          , cst_conta_fc b
                      WHERE a.cod_conta_fc_agrupadora = b.cod_conta_fc(+)
                        AND a.ind_sintetico_analitico(+) = 'A')
            -- busca
            SELECT cod_conta
                 , descricao
                 , ind_saldo_ini
                 , vlr_saldo_ini
                 , vlr_tot_deb
                 , vlr_tot_cre
                 , ind_saldo_fim
                 , vlr_saldo_fim
                 , s.cod_conta_fc
                 , nivel
                 , NVL ( c.num_ordem_1, 9999999 ) num_ordem
                 , num_ordem_2
              FROM saldo s
                 , conta_fc c
             WHERE s.cod_conta_fc = c.cod_conta_fc(+);

        COMMIT;

        -- Totaliza dados analiticos
        FOR sint IN ( SELECT '-1' cod_conta_fc
                           , 'Não Informado' descricao
                           , 'A' ind_sintetico_analitico
                           , NULL cod_conta_fc_agrupadora
                           , 9999999 num_ordem_1
                           , NULL num_ordem_2
                        FROM DUAL
                     UNION ALL
                     SELECT a.cod_conta_fc
                          , a.descricao
                          , a.ind_sintetico_analitico
                          , a.cod_conta_fc_agrupadora
                          , NVL ( a.num_ordem, b.num_ordem ) num_ordem_1
                          , NVL ( b.num_ordem, 0 ) num_ordem_2
                       FROM cst_conta_fc a
                          , cst_conta_fc b
                      WHERE a.cod_conta_fc_agrupadora = b.cod_conta_fc(+)
                        AND a.ind_sintetico_analitico = 'A'
                     ORDER BY num_ordem_1
                            , num_ordem_2 ) LOOP
            INSERT INTO cst_account_balance_fc --
                                               ( cod_conta
                                               , descricao
                                               , ind_saldo_ini
                                               , vlr_saldo_ini
                                               , vlr_tot_deb
                                               , vlr_tot_cre
                                               , ind_saldo_fim
                                               , vlr_saldo_fim
                                               , cod_conta_fc
                                               , num_ordem_1
                                               , num_ordem_2
                                               , nivel )
                ( SELECT cod_conta
                       , descricao
                       , ind_saldo_ini
                       , vlr_saldo_ini
                       , vlr_tot_deb
                       , vlr_tot_cre
                       , ind_saldo_fim
                       , vlr_saldo_fim
                       , cod_conta_fc
                       , num_ordem_1
                       , num_ordem_2
                       , nivel
                    FROM ( SELECT sint.cod_conta_fc cod_conta
                                , sint.descricao
                                , ( CASE
                                       WHEN SUM ( vlr_saldo_ini * DECODE ( ind_saldo_ini, 'C', -1, 1 ) ) < 0 THEN 'C'
                                       ELSE 'D'
                                   END )
                                      ind_saldo_ini
                                , SUM ( vlr_saldo_ini * DECODE ( ind_saldo_ini, 'C', -1, 1 ) ) vlr_saldo_ini
                                , SUM ( vlr_tot_deb ) vlr_tot_deb
                                , SUM ( vlr_tot_cre ) vlr_tot_cre
                                , ( CASE
                                       WHEN SUM ( vlr_saldo_fim * DECODE ( ind_saldo_fim, 'C', -1, 1 ) ) < 0 THEN 'C'
                                       ELSE 'D'
                                   END )
                                      ind_saldo_fim
                                , SUM ( vlr_saldo_fim * DECODE ( ind_saldo_fim, 'C', -1, 1 ) ) vlr_saldo_fim
                                , sint.cod_conta_fc_agrupadora cod_conta_fc
                                , sint.num_ordem_1
                                , sint.num_ordem_2
                                , 2 nivel
                                , MAX ( a.ROWID ) v_rowid
                             FROM cst_account_balance_fc a
                            WHERE cod_conta_fc = sint.cod_conta_fc )
                   WHERE v_rowid IS NOT NULL );

            COMMIT;
        END LOOP;

        -- totaliza dados sinteticos
        FOR sint IN ( /*SELECT '-1' cod_conta_fc,
                                             'Não Informado' descricao,
                                             'A' ind_sintetico_analitico,
                                             NULL cod_conta_fc_agrupadora,
                                             9999999 num_ordem_1,
                                             NULL num_ordem_2
                                        FROM dual
                                      UNION ALL*/
                     SELECT    a.cod_conta_fc
                             , a.descricao
                             , a.ind_sintetico_analitico
                             , a.cod_conta_fc_agrupadora
                             , NVL ( a.num_ordem, b.num_ordem ) num_ordem_1
                             , NVL ( b.num_ordem, 0 ) num_ordem_2
                          FROM cst_conta_fc a
                             , cst_conta_fc b
                         WHERE a.cod_conta_fc_agrupadora = b.cod_conta_fc(+)
                           AND a.ind_sintetico_analitico = 'S'
                      ORDER BY num_ordem_1
                             , num_ordem_2 ) LOOP
            INSERT INTO cst_account_balance_fc --
                                               ( cod_conta
                                               , descricao
                                               , ind_saldo_ini
                                               , vlr_saldo_ini
                                               , vlr_tot_deb
                                               , vlr_tot_cre
                                               , ind_saldo_fim
                                               , vlr_saldo_fim
                                               , cod_conta_fc
                                               , num_ordem_1
                                               , num_ordem_2
                                               , nivel )
                ( SELECT cod_conta
                       , descricao
                       , ind_saldo_ini
                       , vlr_saldo_ini
                       , vlr_tot_deb
                       , vlr_tot_cre
                       , ind_saldo_fim
                       , vlr_saldo_fim
                       , cod_conta_fc
                       , num_ordem_1
                       , num_ordem_2
                       , nivel
                    FROM ( SELECT sint.cod_conta_fc cod_conta
                                , sint.descricao
                                , ( CASE
                                       WHEN SUM ( vlr_saldo_ini * DECODE ( ind_saldo_ini, 'C', -1, 1 ) ) < 0 THEN 'C'
                                       ELSE 'D'
                                   END )
                                      ind_saldo_ini
                                , SUM ( vlr_saldo_ini * DECODE ( ind_saldo_ini, 'C', -1, 1 ) ) vlr_saldo_ini
                                , SUM ( vlr_tot_deb ) vlr_tot_deb
                                , SUM ( vlr_tot_cre ) vlr_tot_cre
                                , ( CASE
                                       WHEN SUM ( vlr_saldo_fim * DECODE ( ind_saldo_fim, 'C', -1, 1 ) ) < 0 THEN 'C'
                                       ELSE 'D'
                                   END )
                                      ind_saldo_fim
                                , SUM ( vlr_saldo_fim * DECODE ( ind_saldo_fim, 'C', -1, 1 ) ) vlr_saldo_fim
                                , sint.cod_conta_fc_agrupadora cod_conta_fc
                                , sint.num_ordem_1
                                , sint.num_ordem_2
                                , 2 nivel
                                , MAX ( a.ROWID ) v_rowid
                             FROM cst_account_balance_fc a
                            WHERE cod_conta_fc = sint.cod_conta_fc )
                   WHERE v_rowid IS NOT NULL );

            COMMIT;
        END LOOP;

        --=========================================================
        loga ( '>> Montando relatorio'
             , FALSE );

        --=========================================================

        FOR d
            IN ( SELECT      cod_conta
                          || ';'
                          || descricao
                          || ';'
                          || ind_saldo_ini
                          || ';'
                          || vlr_saldo_ini
                          || ';'
                          || vlr_tot_deb
                          || ';'
                          || vlr_tot_cre
                          || ';'
                          || ind_saldo_fim
                          || ';'
                          || vlr_saldo_fim
                          || ';'
                          || cod_conta_fc
                          || ';'
                          || num_ordem_1
                          || ';'
                          || num_ordem_2
                          || ';'
                          || nivel
                              texto
                     FROM cst_account_balance_fc a
                 ORDER BY a.num_ordem_1
                        , a.num_ordem_2
                        , cod_conta ) LOOP
            loga ( d.texto );
        END LOOP;

        FOR c IN ( SELECT   cod_conta
                          , a.descricao
                          , ( CASE
                                 WHEN vlr_saldo_ini < 0 THEN
                                        TO_CHAR ( vlr_saldo_ini * -1
                                                , '999G999G999G990D00' )
                                     || '-'
                                 ELSE
                                        TO_CHAR ( vlr_saldo_ini
                                                , '999G999G999G990D00' )
                                     || ' '
                             END )
                                vlr_saldo_ini
                          , TO_CHAR ( vlr_tot_deb
                                    , '999G999G999G990D00' )
                                vlr_tot_deb
                          ,    TO_CHAR ( vlr_tot_cre
                                       , '999G999G999G990D00' )
                            || DECODE ( vlr_tot_cre, 0, ' ', '-' )
                                vlr_tot_cre
                          , ( CASE
                                 WHEN vlr_saldo_fim < 0 THEN
                                        TO_CHAR ( vlr_saldo_fim * -1
                                                , '999G999G999G990D00' )
                                     || '-'
                                 ELSE
                                        TO_CHAR ( vlr_saldo_fim
                                                , '999G999G999G990D00' )
                                     || ' '
                             END )
                                vlr_saldo_fim
                          , a.cod_conta_fc
                          , a.nivel
                       FROM cst_account_balance_fc a
                   ORDER BY a.num_ordem_1
                          , a.num_ordem_2
                          , cod_conta ) LOOP
            IF ( ( v_linha + 1 ) / v_limite_linhas ) >= p_pagina THEN
                v_linha := v_linha + 1;
                lib_proc.add ( RPAD ( ' '
                                    , p_colunas
                                    , '=' )
                             , p_pagina
                             , v_linha );

                cabecalho_analitico ( p_cod_empresa
                                    , vp_data );
            END IF;

            IF c.nivel = 2 THEN
                v_linha := v_linha + 1;
                lib_proc.add ( LPAD ( '.'
                                    , p_colunas
                                    , ' ' )
                             , p_pagina
                             , v_linha );

                IF ( ( v_linha + 1 ) / v_limite_linhas ) >= p_pagina THEN
                    v_linha := v_linha + 1;
                    lib_proc.add ( RPAD ( ' '
                                        , p_colunas
                                        , '=' )
                                 , p_pagina
                                 , v_linha );

                    cabecalho_analitico ( p_cod_empresa
                                        , vp_data );
                END IF;
            END IF;

            v_text01 :=
                   ' '
                || RPAD ( NVL ( c.cod_conta, ' ' )
                        , 14
                        , ' ' )
                || RPAD ( NVL ( SUBSTR ( c.descricao
                                       , 1
                                       , 40 )
                              , ' ' )
                        , 40
                        , ' ' )
                || LPAD ( c.vlr_saldo_ini
                        , 22
                        , ' ' )
                || LPAD ( c.vlr_tot_deb
                        , 21
                        , ' ' )
                || LPAD ( c.vlr_tot_cre
                        , 23
                        , ' ' )
                || LPAD ( c.vlr_saldo_fim
                        , 21
                        , ' ' )
                || LPAD ( NVL ( c.cod_conta_fc, ' ' )
                        , 11
                        , ' ' )
                || '';

            v_linha := v_linha + 1;
            lib_proc.add ( v_text01
                         , p_pagina
                         , v_linha );

            COMMIT;

            IF c.nivel = 2 THEN
                v_linha := v_linha + 1;
                lib_proc.add ( RPAD ( ' '
                                    , p_colunas
                                    , '-' )
                             , p_pagina
                             , v_linha );

                IF ( ( v_linha + 1 ) / v_limite_linhas ) >= p_pagina THEN
                    v_linha := v_linha + 1;
                    lib_proc.add ( RPAD ( ' '
                                        , p_colunas
                                        , '=' )
                                 , p_pagina
                                 , v_linha );

                    cabecalho_analitico ( p_cod_empresa
                                        , vp_data );
                END IF;
            END IF;
        END LOOP;
    --   lib_proc.add(lpad(' ', p_colunas, ' '));
    --   lib_proc.add(lpad('-', p_colunas, '-'));

    END;

    FUNCTION executar ( p_data_ini DATE
                      , p_cod_empresa VARCHAR2 )
        RETURN INTEGER
    IS
        p_tipo INTEGER := 1;
    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS='',.'' ';

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING = FORCE';

        mproc_id := lib_proc.new ( psp_nome => $$plsql_unit );

        dbms_application_info.set_module ( $$plsql_unit
                                         , 'PROC_ID: ' || mproc_id );

        loga (    'Data execução: '
               || TO_CHAR ( SYSDATE
                          , 'dd/mm/yyyy hh24:mi:ss' )
             , FALSE );
        loga ( 'Usuário: ' || musuario
             , FALSE );
        loga ( 'Empresa: ' || mcod_empresa
             , FALSE );
        loga (    'Período: '
               || TO_CHAR ( p_data_ini
                          , 'mm/yyyy' ) );
        loga ( '----------------------------------------'
             , FALSE );

        grava_analitico ( p_data_ini
                        , p_cod_empresa
                        , p_tipo );

        lib_proc.close;
        COMMIT;
        RETURN mproc_id;
    EXCEPTION
        WHEN OTHERS THEN
            loga ( 'SQLERRM: ' || SQLERRM
                 , FALSE );

            lib_proc.add_log ( 'ERRO NÃO TRATADO: ' || dbms_utility.format_error_backtrace
                             , 1 );
            lib_proc.add_log ( 'SQLERRM: ' || SQLERRM
                             , 1 );
            COMMIT;

            lib_proc.close ( );

            RETURN mproc_id;
    END; /* FUNCTION EXECUTAR */
END cst_rel_account_balance_cproc;
/
SHOW ERRORS;
