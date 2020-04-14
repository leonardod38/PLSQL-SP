Prompt Package Body DPSP_FIN048_RET_COMPETE_CPROC;
--
-- DPSP_FIN048_RET_COMPETE_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_fin048_ret_compete_cproc
IS
    mproc_id NUMBER;
    vn_linha NUMBER := 0;
    vn_pagina NUMBER := 0;
    mnm_usuario usuario_estab.cod_usuario%TYPE;
    mcod_empresa estabelecimento.cod_empresa%TYPE;
    vs_mlinha VARCHAR2 ( 4000 );

    --Tipo, Nome e Descrição do Customizado
    --Melhoria FIN048
    mnm_tipo VARCHAR2 ( 100 ) := 'Retificação ICMS ES';
    mnm_cproc VARCHAR2 ( 100 ) := '3. Gerar cálculos COMPETE e FEEF';
    mds_cproc VARCHAR2 ( 100 ) := 'Gerar cálculo conforme os Relatórios de Retificação';

    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );
    BEGIN
        mnm_usuario := lib_parametros.recuperar ( UPPER ( 'USUARIO' ) );
        mcod_empresa := lib_parametros.recuperar ( UPPER ( 'EMPRESA' ) );

        lib_proc.add_param ( pparam => pstr
                           , ptitulo => 'Data Inicial'
                           , ptipo => 'DATE'
                           , pcontrole => 'textbox'
                           , pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => 'DD/MM/YYYY' );

        lib_proc.add_param ( pparam => pstr
                           , ptitulo => 'Data Final'
                           , ptipo => 'DATE'
                           , pcontrole => 'textbox'
                           , pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => 'DD/MM/YYYY' );

        lib_proc.add_param (
                             pstr
                           , 'CDs'
                           , 'VARCHAR2'
                           , 'COMBOBOX'
                           , 'S'
                           , NULL
                           , NULL
                           ,    ' SELECT ''TODOS'' AS COD_ESTAB, ''Todos os CDs'' FROM DUAL UNION ALL '
                             || 'SELECT A.COD_ESTAB, A.COD_ESTAB || '' - '' || B.COD_ESTADO || '' - '' || A.CGC || '' - '' || INITCAP(A.BAIRRO) || '' / '' || INITCAP(A.CIDADE) FROM ESTABELECIMENTO A, ESTADO B, MSAFI.DSP_ESTABELECIMENTO C WHERE A.COD_EMPRESA  = '''
                             || mcod_empresa
                             || ''' AND B.IDENT_ESTADO = A.IDENT_ESTADO AND A.COD_EMPRESA = C.COD_EMPRESA AND A.COD_ESTAB = C.COD_ESTAB AND C.TIPO = ''C'' AND B.COD_ESTADO = ''ES'' '
        );

        RETURN pstr;
    END;

    FUNCTION tipo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN mnm_tipo;
    END;

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN mnm_cproc;
    END;

    FUNCTION descricao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN mds_cproc;
    END;

    FUNCTION versao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN '1.0';
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
        RETURN 'PORTRAIT';
    END;

    FUNCTION executar ( pdt_ini DATE
                      , pdt_fim DATE
                      , pcod_estab VARCHAR2 )
        RETURN INTEGER
    IS
        v_qtd INTEGER;
        v_validar_status INTEGER := 0;
        v_existe_origem CHAR := 'S';

        v_data_inicial DATE
            :=   TRUNC ( pdt_ini )
               - (   TO_NUMBER ( TO_CHAR ( pdt_ini
                                         , 'DD' ) )
                   - 1 );
        v_data_final DATE := LAST_DAY ( pdt_fim );
        v_data_hora_ini VARCHAR2 ( 20 );
        p_proc_instance VARCHAR2 ( 30 );

        --PTAB_ENTRADA     VARCHAR2(50);
        v_sql VARCHAR2 ( 4000 );
        v_retorno_status VARCHAR2 ( 4000 );

        i INTEGER := 2;
        --Variaveis genericas
        v_text01 VARCHAR2 ( 6000 );
        v_class VARCHAR2 ( 1 ) := 'a';

        CURSOR lista_cds
        IS
            SELECT a.cod_estab
              FROM estabelecimento a
                 , estado b
                 , msafi.dsp_estabelecimento c
             WHERE b.ident_estado = a.ident_estado
               AND a.cod_empresa = c.cod_empresa
               AND a.cod_estab = c.cod_estab
               AND c.tipo = 'C'
               AND a.cod_empresa = mcod_empresa
               AND a.cod_estab = (CASE WHEN pcod_estab = 'TODOS' THEN a.cod_estab ELSE pcod_estab END);
    BEGIN
        -- Criação: Processo
        mproc_id :=
            lib_proc.new ( psp_nome => $$plsql_unit
                         , -- Package
                          prows => 48
                         , pcols => 200 );

        --Tela DW
        lib_proc.add_tipo ( pproc_id => mproc_id
                          , ptipo => 1
                          , ptitulo =>    TO_CHAR ( SYSDATE
                                                  , 'YYYYMMDDHH24MISS' )
                                       || '_Ret_ICMS_ES_Entradas'
                          , ptipo_arq => 1 );

        vn_pagina := 1;
        vn_linha := 48;

        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT="DD/MM/YYYY"';

        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS= '',.'' ';

        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        mnm_usuario := lib_parametros.recuperar ( 'USUARIO' );

        --MARCAR INCIO DA EXECUCAO
        v_data_hora_ini :=
            TO_CHAR ( SYSDATE
                    , 'DD/MM/YYYY HH24:MI.SS' );

        IF mcod_empresa IS NULL THEN
            lib_proc.add_log ( 'Código da empresa deve ser informado como parâmetro global.'
                             , 0 );
            lib_proc.add ( 'ERRO' );
            lib_proc.add ( 'CÓDIGO DA EMPRESA DEVE SER INFORMADO COMO PARÂMETRO GLOBAL.' );
            lib_proc.close;
            RETURN mproc_id;
        END IF;

        FOR c_dados_emp IN ( SELECT cod_empresa
                                  , razao_social
                                  , DECODE ( cnpj
                                           , NULL, NULL
                                           , REPLACE ( REPLACE ( REPLACE ( TO_CHAR ( LPAD ( REPLACE ( cnpj
                                                                                                    , '' )
                                                                                          , 14
                                                                                          , '0' )
                                                                                   , '00,000,000,0000,00' )
                                                                         , ','
                                                                         , '.' )
                                                               , ' ' )
                                                     ,    '.'
                                                       || TRIM ( TO_CHAR ( TRUNC (   MOD ( LPAD ( cnpj
                                                                                                , 14
                                                                                                , '0' )
                                                                                         , 1000000 )
                                                                                   / 100 )
                                                                         , '0000' ) )
                                                       || '.'
                                                     ,    '/'
                                                       || TRIM ( TO_CHAR ( TRUNC (   MOD ( LPAD ( cnpj
                                                                                                , 14
                                                                                                , '0' )
                                                                                         , 1000000 )
                                                                                   / 100 )
                                                                         , '0000' ) )
                                                       || '-' ) )
                                        AS cnpj
                               FROM empresa
                              WHERE cod_empresa = mcod_empresa ) LOOP
            cabecalho ( c_dados_emp.razao_social
                      , c_dados_emp.cnpj
                      , v_data_hora_ini
                      , mnm_cproc
                      , pdt_ini
                      , pdt_fim
                      , pcod_estab );
        END LOOP;

        loga ( '---INI DO PROCESSAMENTO---'
             , FALSE );
        loga ( '<< PERIODO DE: ' || v_data_inicial || ' A ' || v_data_final || ' >>'
             , FALSE );

        --=================================================================================
        -- INICIO
        --=================================================================================
        --Permitir processo somente para um mês
        IF LAST_DAY ( pdt_ini ) = LAST_DAY ( pdt_fim ) THEN
            --=================================================================================
            -- INICIO
            --=================================================================================
            -- Um CD por Vez
            FOR cd IN lista_cds LOOP
                dbms_application_info.set_module ( $$plsql_unit
                                                 , 'Estab: ' || cd.cod_estab );

                --GERAR CHAVE PROC_ID
                SELECT ROUND ( dbms_random.VALUE ( 10000000000000
                                                 , 999999999999999 ) )
                  INTO p_proc_instance
                  FROM DUAL;

                --=================================================================================
                -- VALIDAR STATUS DE RELATÓRIOS ENCERRADOS
                --=================================================================================
                -- IGUAL À ZERO:      PARA PROCESSOS ABERTOS - AÇÃO: CARREGAR TABELA RETIFICACAO NFS DE ENTRADA
                -- DIFERENTE DE ZERO: PARA PROCESSOS ENCERRADOS - AÇÃO: CONSULTAR TABELA RETIFICACAO NFS DE ENTRADA
                ---------------------

                v_validar_status :=
                    msaf.dpsp_suporte_cproc_process.validar_status_rel ( mcod_empresa
                                                                       , cd.cod_estab
                                                                       , TO_NUMBER ( TO_CHAR ( pdt_ini
                                                                                             , 'YYYYMM' ) )
                                                                       , $$plsql_unit );

                --=================================================================================
                -- CARREGAR TABELA DE NOTAS DE ENTRADA
                --=================================================================================
                IF v_validar_status = 0 THEN
                    loga ( '>> INICIO CD: ' || cd.cod_estab || ' PROC INSERT ' || p_proc_instance
                         , FALSE );

                    ---------------------
                    -- LIMPEZA
                    ---------------------
                    DELETE FROM msafi.dpsp_fin048_ret_compete
                          WHERE 1 = 1 --COD_EMPRESA = MCOD_EMPRESA
                            AND cod_estab = cd.cod_estab
                            AND data_fiscal BETWEEN v_data_inicial AND v_data_final;

                    loga (
                              '::LIMPEZA DOS REGISTROS ANTERIORES (DPSP_FIN048_RET_NF_ENT), CD: '
                           || cd.cod_estab
                           || ' - QTDE '
                           || SQL%ROWCOUNT
                           || '::'
                         , FALSE
                    );

                    COMMIT;

                    --A carga irá executar o periodo inteiro, e depois consultar o periodo informado na tela.
                    --Exemplo: Parametrizado do dia 1 ao 10, então será carregado de 1 a 31, mas consultado de 1 a 10
                    v_qtd :=
                        carregar_nf_entrada ( v_data_inicial
                                            , v_data_final
                                            , cd.cod_estab
                                            , v_data_hora_ini );

                    ---------------------
                    -- Informar CDs que retornarem sem dados de origem / select zerado
                    ---------------------
                    IF v_qtd = 0 THEN
                        --Inserir status como Aberto pois não há origem
                        msaf.dpsp_suporte_cproc_process.inserir_status_rel ( mcod_empresa
                                                                           , cd.cod_estab
                                                                           , TO_NUMBER ( TO_CHAR ( pdt_ini
                                                                                                 , 'YYYYMM' ) )
                                                                           , $$plsql_unit
                                                                           , mnm_cproc
                                                                           , mnm_tipo
                                                                           , 0
                                                                           , --Aberto
                                                                            $$plsql_unit
                                                                           , mproc_id
                                                                           , mnm_usuario
                                                                           , v_data_hora_ini );

                        lib_proc.add ( 'CD ' || cd.cod_estab || ' sem dados na origem.' );

                        lib_proc.add ( ' ' );
                        loga ( '---CD ' || cd.cod_estab || ' - SEM DADOS DE ORIGEM---'
                             , FALSE );
                        --LOGA('<< SEM DADOS DE ORIGEM >>', FALSE);

                        v_existe_origem := 'N';
                    ELSE
                        ---------------------
                        --Encerrar periodo caso não seja o mês atual e existam registros na origem
                        ---------------------
                        IF LAST_DAY ( pdt_ini ) < LAST_DAY ( SYSDATE ) THEN
                            msaf.dpsp_suporte_cproc_process.inserir_status_rel ( mcod_empresa
                                                                               , cd.cod_estab
                                                                               , TO_NUMBER ( TO_CHAR ( pdt_ini
                                                                                                     , 'YYYYMM' ) )
                                                                               , $$plsql_unit
                                                                               , mnm_cproc
                                                                               , mnm_tipo
                                                                               , 1
                                                                               , --Encerrado
                                                                                $$plsql_unit
                                                                               , mproc_id
                                                                               , mnm_usuario
                                                                               , v_data_hora_ini );
                            lib_proc.add ( 'CD ' || cd.cod_estab || ' - Período Encerrado' );

                            v_retorno_status :=
                                msaf.dpsp_suporte_cproc_process.retornar_status_rel (
                                                                                      mcod_empresa
                                                                                    , cd.cod_estab
                                                                                    , TO_NUMBER (
                                                                                                  TO_CHAR ( pdt_ini
                                                                                                          , 'YYYYMM' )
                                                                                      )
                                                                                    , $$plsql_unit
                                );
                            lib_proc.add ( 'Data de Encerramento: ' || v_retorno_status );

                            lib_proc.add ( ' ' );
                            loga ( '---ESTAB ' || cd.cod_estab || ' - PERIODO ENCERRADO: ' || v_retorno_status || '---'
                                 , FALSE );
                        ELSE
                            msaf.dpsp_suporte_cproc_process.inserir_status_rel ( mcod_empresa
                                                                               , cd.cod_estab
                                                                               , TO_NUMBER ( TO_CHAR ( pdt_ini
                                                                                                     , 'YYYYMM' ) )
                                                                               , $$plsql_unit
                                                                               , mnm_cproc
                                                                               , mnm_tipo
                                                                               , 0
                                                                               , --Aberto
                                                                                $$plsql_unit
                                                                               , mproc_id
                                                                               , mnm_usuario
                                                                               , v_data_hora_ini );

                            lib_proc.add ( 'CD ' || cd.cod_estab || ' - PERIODO EM ABERTO,'
                                         , 1 );
                            lib_proc.add ( 'Os registros gerados são temporários.'
                                         , 1 );

                            lib_proc.add ( ' '
                                         , 1 );
                            loga ( '---CD ' || cd.cod_estab || ' - PERIODO EM ABERTO---'
                                 , FALSE );
                        END IF;
                    END IF;
                --PERIODO JÁ ENCERRADO
                ELSE
                    lib_proc.add ( 'CD ' || cd.cod_estab || ' - Período já processado e encerrado' );

                    v_retorno_status :=
                        msaf.dpsp_suporte_cproc_process.retornar_status_rel ( mcod_empresa
                                                                            , cd.cod_estab
                                                                            , TO_NUMBER ( TO_CHAR ( pdt_ini
                                                                                                  , 'YYYYMM' ) )
                                                                            , $$plsql_unit );
                    lib_proc.add ( 'Data de Encerramento: ' || v_retorno_status );

                    lib_proc.add ( ' ' );
                    loga (
                              '---CD '
                           || cd.cod_estab
                           || ' - PERIODO JÁ PROCESSADO E ENCERRADO: '
                           || v_retorno_status
                           || '---'
                         , FALSE
                    );
                END IF;

                --Limpar variaveis para proximo estab
                v_qtd := 0;
                v_retorno_status := '';
                v_sql := '';
            END LOOP;

            --=================================================================================
            -- GERAR ARQUIVO ANALITICO
            --=================================================================================
            lib_proc.add_tipo ( mproc_id
                              , i
                              ,    TO_CHAR ( pdt_ini
                                           , 'YYYYMM' )
                                || '_Ret_ICMS_ES_Compete.xls'
                              , 2 );
            lib_proc.add ( dsp_planilha.header
                         , ptipo => i );
            lib_proc.add ( dsp_planilha.tabela_inicio
                         , ptipo => i );

            lib_proc.add ( dsp_planilha.linha (
                                                p_conteudo =>    dsp_planilha.campo ( 'SAIDAS' )
                                                              || --
                                                                dsp_planilha.campo ( '' )
                                                              || --
                                                                dsp_planilha.campo ( '' )
                                                              || --
                                                                dsp_planilha.campo ( '' )
                                                              || --
                                                                dsp_planilha.campo ( '' )
                                                              || --
                                                                dsp_planilha.campo ( '' )
                                                              || --
                                                                dsp_planilha.campo ( '' )
                                                              || --
                                                                dsp_planilha.campo ( '' )
                                                              || --
                                                                dsp_planilha.campo ( '' )
                                                              || --
                                                                dsp_planilha.campo ( '' )
                                                              || --
                                                                dsp_planilha.campo ( '' )
                                                              || --
                                                                dsp_planilha.campo ( '' )
                                                              || --
                                                                dsp_planilha.campo ( '' )
                                                              || --
                                                                dsp_planilha.campo ( '' )
                                                              || --
                                                                dsp_planilha.campo ( '' )
                                                              || --
                                                                dsp_planilha.campo ( '' )
                                                              || --
                                                                dsp_planilha.campo ( '' )
                                                              || --
                                                                dsp_planilha.campo ( '' )
                                                              || --
                                                                dsp_planilha.campo ( '' )
                                                              || --
                                                                dsp_planilha.campo ( '' )
                                                              || --
                                                                dsp_planilha.campo ( '' )
                                                              || --
                                                                dsp_planilha.campo ( '' )
                                              , p_class => 'h'
                           )
                         , ptipo => i );

            FOR cd IN lista_cds LOOP
                lib_proc.add ( dsp_planilha.linha (
                                                    p_conteudo =>    dsp_planilha.campo ( 'COD_ESTAB' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'UF_ESTAB' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'UF_FORN_CLI' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'DATA_FISCAL' )
                                                                  || --
                                                                    dsp_planilha.campo (
                                                                                         dsp_planilha.texto (
                                                                                                              'NUMERO_NF'
                                                                                         )
                                                                     )
                                                                  || --
                                                                    dsp_planilha.campo (
                                                                                         dsp_planilha.texto (
                                                                                                              'SERIE'
                                                                                         )
                                                                     )
                                                                  || --
                                                                    dsp_planilha.campo (
                                                                                         dsp_planilha.texto (
                                                                                                              'ID_PEOPLE'
                                                                                         )
                                                                     )
                                                                  || --
                                                                    dsp_planilha.campo (
                                                                                         dsp_planilha.texto (
                                                                                                              'COD_DOCTO'
                                                                                         )
                                                                     )
                                                                  || --
                                                                    dsp_planilha.campo (
                                                                                         dsp_planilha.texto (
                                                                                                              'COD_MODELO'
                                                                                         )
                                                                     )
                                                                  || --
                                                                    dsp_planilha.campo (
                                                                                         dsp_planilha.texto ( 'FIN' )
                                                                     )
                                                                  || --
                                                                    dsp_planilha.campo (
                                                                                         dsp_planilha.texto (
                                                                                                              'COD_CFO'
                                                                                         )
                                                                     )
                                                                  || --
                                                                    dsp_planilha.campo (
                                                                                         dsp_planilha.texto ( 'CST' )
                                                                     )
                                                                  || --
                                                                    dsp_planilha.campo ( 'VLR_CONTABIL' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'BASE_TRIB' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'ALIQ_TRIBUTO_ICMS' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'VLR_ICMS' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'BASE_ISENT' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'BASE_OUTRAS' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'BASE_RED' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'VLR_ICMS_ST' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'VLR_IPI' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'DIF_BASES' )
                                                  , p_class => 'h'
                               )
                             , ptipo => i );

                FOR cr_r IN ( SELECT cod_estab
                                   , uf_estab
                                   , uf_forn_cli
                                   , data_fiscal
                                   , numero_nf
                                   , serie
                                   , id_people
                                   , cod_docto
                                   , cod_modelo
                                   , fin
                                   , cod_cfo
                                   , cst
                                   , vlr_contabil
                                   , base_trib
                                   , aliq_tributo_icms
                                   , vlr_icms
                                   , base_isent
                                   , base_outras
                                   , base_red
                                   , vlr_icms_st
                                   , vlr_ipi
                                   , dif_bases
                                FROM msafi.dpsp_fin048_ret_compete
                               WHERE 1 = 1 --UF_ESTAB = MCOD_EMPRESA
                                 AND cod_estab = cd.cod_estab
                                 AND data_fiscal BETWEEN pdt_ini AND pdt_fim ) LOOP
                    IF v_class = 'a' THEN
                        v_class := 'b';
                    ELSE
                        v_class := 'a';
                    END IF;

                    v_text01 :=
                        dsp_planilha.linha (
                                             p_conteudo =>    dsp_planilha.campo ( cr_r.cod_estab )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.uf_estab )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.uf_forn_cli )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.data_fiscal )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.numero_nf )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.serie )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.id_people )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.cod_docto )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.cod_modelo )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.fin )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.cod_cfo )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.cst )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.vlr_contabil )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.base_trib )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.aliq_tributo_icms )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.vlr_icms )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.base_isent )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.base_outras )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.base_red )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.vlr_icms_st )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.vlr_ipi )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.dif_bases )
                                           , p_class => v_class
                        );
                    lib_proc.add ( v_text01
                                 , ptipo => i );
                END LOOP;
            END LOOP;

            lib_proc.add ( dsp_planilha.tabela_fim
                         , ptipo => i );

            i := i + 1;

            --=================================================================================
            -- GERAR ARQUIVO SINTETICO
            --=================================================================================
            lib_proc.add_tipo ( mproc_id
                              , i
                              ,    TO_CHAR ( pdt_ini
                                           , 'YYYYMM' )
                                || '_Ret_ICMS_ES_Compete_Sintetico.xls'
                              , 2 );
            lib_proc.add ( dsp_planilha.header
                         , ptipo => i );
            lib_proc.add ( dsp_planilha.tabela_inicio
                         , ptipo => i );

            FOR cd IN lista_cds LOOP
                lib_proc.add ( dsp_planilha.linha (
                                                    p_conteudo =>    dsp_planilha.campo ( 'CFO' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'VLR_CONTABIL' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'BASE_TRIB' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'VLR_ICMS' )
                                                  , p_class => 'h'
                               )
                             , ptipo => i );

                FOR cr_r IN ( SELECT   cod_cfo cfo
                                     , SUM ( vlr_contabil ) vlr_contabil
                                     , SUM ( base_trib ) AS base_trib
                                     , SUM ( vlr_icms ) AS vlr_icms
                                  FROM msafi.dpsp_fin048_ret_compete
                                 WHERE 1 = 1 --COD_EMPRESA = MCOD_EMPRESA
                                   AND cod_estab = cd.cod_estab
                                   AND data_fiscal BETWEEN pdt_ini AND pdt_fim
                              GROUP BY cod_cfo ) LOOP
                    IF v_class = 'a' THEN
                        v_class := 'b';
                    ELSE
                        v_class := 'a';
                    END IF;

                    v_text01 :=
                        dsp_planilha.linha (
                                             p_conteudo =>    dsp_planilha.campo ( cr_r.cfo )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.vlr_contabil )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.base_trib )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.vlr_icms )
                                           , p_class => v_class
                        );
                    lib_proc.add ( v_text01
                                 , ptipo => i );
                END LOOP;
            END LOOP;

            lib_proc.add ( dsp_planilha.tabela_fim
                         , ptipo => i );

            loga ( '---FIM DO PROCESSAMENTO [SUCESSO]---'
                 , FALSE );

            --=================================================================================
            -- FIM
            --=================================================================================
            --ENVIAR EMAIL DE SUCESSO----------------------------------------
            envia_email ( mcod_empresa
                        , v_data_inicial
                        , v_data_final
                        , ''
                        , 'S'
                        , v_data_hora_ini );

            -----------------------------------------------------------------
            IF v_existe_origem = 'N' THEN
                lib_proc.add ( 'Há CDs sem dados de origem.' );
                lib_proc.add ( ' ' );
            END IF;
        --Em casos de meses diferentes
        ELSE
            lib_proc.add ( 'Processo não permitido:'
                         , 1 );
            lib_proc.add ( 'Favor informar somente um único mês entre a Data Inicial e Data Final'
                         , 1 );
            lib_proc.add ( ' '
                         , 1 );

            loga ( ' '
                 , FALSE );
            loga ( '<< PROCESSO NÃO PERMITIDO >>'
                 , FALSE );
            loga ( 'NÃO É PERMITIDO O PROCESSAMENTO DE MESES DIFERENTES'
                 , FALSE );
            loga ( ' '
                 , FALSE );

            loga ( '---FIM DO PROCESSAMENTO [ERRO]---'
                 , FALSE );
        END IF;

        lib_proc.add ( 'Favor verificar LOG para detalhes.' );
        lib_proc.add ( ' ' );

        lib_proc.close;
        RETURN mproc_id;
    /*WHEN OTHERS THEN

      LOGA('SQLERRM: ' || SQLERRM, FALSE);
      LIB_PROC.add_log('Erro não tratado: ' ||
                       DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                       1);
      LIB_PROC.add_log('SQLERRM: ' || SQLERRM, 1);
      LIB_PROC.ADD('ERRO!');
      LIB_PROC.ADD(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);

      --ENVIAR EMAIL DE ERRO-------------------------------------------
      ENVIA_EMAIL(MCOD_EMPRESA,
                  V_DATA_INICIAL,
                  V_DATA_FINAL,
                  SQLERRM,
                  'E',
                  V_DATA_HORA_INI);
      -----------------------------------------------------------------

    LIB_PROC.CLOSE;
    COMMIT;
    RETURN MPROC_ID;*/

    END;

    PROCEDURE loga ( p_i_texto IN VARCHAR2
                   , p_i_dttm IN BOOLEAN DEFAULT TRUE )
    IS
        vtexto VARCHAR2 ( 1024 );
    BEGIN
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
    END;

    PROCEDURE envia_email ( vp_cod_empresa IN VARCHAR2
                          , vp_data_ini IN DATE
                          , vp_data_fim IN DATE
                          , vp_msg_oracle IN VARCHAR2
                          , vp_tipo IN VARCHAR2
                          , vp_data_hora_ini IN VARCHAR2 )
    IS
        v_txt_email VARCHAR2 ( 2000 ) := '';
        v_assunto VARCHAR2 ( 100 ) := '';
        v_horas NUMBER;
        v_minutos NUMBER;
        v_segundos NUMBER;
        v_tempo_exec VARCHAR2 ( 50 );
    BEGIN
        --CALCULAR TEMPO DE EXECUCAO DO RELATORIO
        SELECT   TRUNC (   (   (   86400
                                 * (   SYSDATE
                                     - TO_DATE ( vp_data_hora_ini
                                               , 'DD/MM/YYYY HH24:MI.SS' ) ) )
                             / 60 )
                         / 60 )
               -   24
                 * ( TRUNC (   (   (   (   86400
                                         * (   SYSDATE
                                             - TO_DATE ( vp_data_hora_ini
                                                       , 'DD/MM/YYYY HH24:MI.SS' ) ) )
                                     / 60 )
                                 / 60 )
                             / 24 ) )
             ,   TRUNC (   (   86400
                             * (   SYSDATE
                                 - TO_DATE ( vp_data_hora_ini
                                           , 'DD/MM/YYYY HH24:MI.SS' ) ) )
                         / 60 )
               -   60
                 * ( TRUNC (   (   (   86400
                                     * (   SYSDATE
                                         - TO_DATE ( vp_data_hora_ini
                                                   , 'DD/MM/YYYY HH24:MI.SS' ) ) )
                                 / 60 )
                             / 60 ) )
             ,   TRUNC (   86400
                         * (   SYSDATE
                             - TO_DATE ( vp_data_hora_ini
                                       , 'DD/MM/YYYY HH24:MI.SS' ) ) )
               -   60
                 * ( TRUNC (   (   86400
                                 * (   SYSDATE
                                     - TO_DATE ( vp_data_hora_ini
                                               , 'DD/MM/YYYY HH24:MI.SS' ) ) )
                             / 60 ) )
          INTO v_horas
             , v_minutos
             , v_segundos
          FROM DUAL;

        v_tempo_exec := v_horas || ':' || v_minutos || '.' || v_segundos;

        IF ( vp_tipo = 'E' ) THEN
            --VP_TIPO = 'E' (ERRO) OU 'S' (SUCESSO)

            v_txt_email := 'ERRO no Relatório de Devolução de Mercadorias com ICMS-ST!';
            v_txt_email := v_txt_email || CHR ( 13 ) || '>> Parâmetros: ';
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Empresa : ' || vp_cod_empresa;
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Data Início : ' || vp_data_ini;
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Data Fim : ' || vp_data_fim;
            v_txt_email := v_txt_email || CHR ( 13 ) || '>> LOG: ';
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Executado por : ' || mnm_usuario;
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Hora Início : ' || vp_data_hora_ini;
            v_txt_email :=
                   v_txt_email
                || CHR ( 13 )
                || ' - Hora Término : '
                || TO_CHAR ( SYSDATE
                           , 'DD/MM/YYYY HH24:MI.SS' );
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Tempo Execução	: ' || v_tempo_exec;
            v_txt_email := v_txt_email || CHR ( 13 ) || '<< ERRO >> ' || vp_msg_oracle;
            v_assunto := 'Mastersaf - Relatório de Devolução de Mercadorias com ICMS-ST apresentou ERRO';
            notifica ( ''
                     , 'S'
                     , v_assunto
                     , v_txt_email
                     , 'DPSP_FIN048_RET_COMPETE_CPROC' );
        ELSE
            v_txt_email := 'Processo Relatório de Devolução de Mercadorias com ICMS-ST finalizado com SUCESSO.';
            v_txt_email := v_txt_email || CHR ( 13 ) || '>> Parâmetros: ';
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Empresa : ' || vp_cod_empresa;
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Data Início : ' || vp_data_ini;
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Data Fim : ' || vp_data_fim;
            v_txt_email := v_txt_email || CHR ( 13 ) || '>> LOG: ';
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Executado por : ' || mnm_usuario;
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Hora Início : ' || vp_data_hora_ini;
            v_txt_email :=
                   v_txt_email
                || CHR ( 13 )
                || ' - Hora Término : '
                || TO_CHAR ( SYSDATE
                           , 'DD/MM/YYYY HH24:MI.SS' );
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Tempo Execução : ' || v_tempo_exec;
            v_assunto := 'Mastersaf - Relatório de Devolução de Mercadorias com ICMS-ST Concluído';
            notifica ( 'S'
                     , ''
                     , v_assunto
                     , v_txt_email
                     , 'DPSP_FIN048_RET_COMPETE_CPROC' );
        END IF;
    END;

    PROCEDURE cabecalho ( pnm_empresa VARCHAR2
                        , pcnpj VARCHAR2
                        , v_data_hora_ini VARCHAR2
                        , mnm_cproc VARCHAR2
                        , pdt_ini DATE
                        , pdt_fim DATE
                        , pcod_estab VARCHAR2 )
    IS
    BEGIN
        --=================================================================================
        -- Cabeçalho do DW
        --=================================================================================
        vs_mlinha := NULL;
        vs_mlinha :=
            lib_str.w ( vs_mlinha
                      , 'Empresa: ' || mcod_empresa || ' - ' || pnm_empresa
                      , 1 );
        vs_mlinha :=
            lib_str.w ( vs_mlinha
                      ,    'Página : '
                        || LPAD ( vn_pagina
                                , 5
                                , '0' )
                      , 136 );
        lib_proc.add ( vs_mlinha
                     , NULL
                     , NULL
                     , 1 );

        vs_mlinha := NULL;
        vs_mlinha :=
            lib_str.w ( vs_mlinha
                      , 'CNPJ: ' || pcnpj
                      , 1 );
        lib_proc.add ( vs_mlinha
                     , NULL
                     , NULL
                     , 1 );

        vs_mlinha := NULL;
        vs_mlinha :=
            lib_str.w ( vs_mlinha
                      , 'Data de Processamento : ' || v_data_hora_ini
                      , 1 );
        lib_proc.add ( vs_mlinha
                     , NULL
                     , NULL
                     , 1 );

        vs_mlinha := NULL;
        vs_mlinha :=
            lib_str.w ( vs_mlinha
                      , LPAD ( '-'
                             , 150
                             , '-' )
                      , 1 );
        lib_proc.add ( vs_mlinha
                     , NULL
                     , NULL
                     , 1 );

        vs_mlinha := NULL;
        vs_mlinha := mnm_cproc;
        lib_proc.add ( vs_mlinha
                     , NULL
                     , NULL
                     , 1 );

        vs_mlinha := NULL;
        vs_mlinha := 'Data Inicial: ' || pdt_ini;
        lib_proc.add ( vs_mlinha
                     , NULL
                     , NULL
                     , 1 );

        vs_mlinha := NULL;
        vs_mlinha := 'Data Final: ' || pdt_fim;
        lib_proc.add ( vs_mlinha
                     , NULL
                     , NULL
                     , 1 );

        vs_mlinha := NULL;
        vs_mlinha :=
               'Período para Encerramento: '
            || TO_CHAR ( pdt_ini
                       , 'MM/YYYY' );
        lib_proc.add ( vs_mlinha
                     , NULL
                     , NULL
                     , 1 );

        vs_mlinha := NULL;
        vs_mlinha :=
            lib_str.w ( vs_mlinha
                      , LPAD ( '-'
                             , 150
                             , '-' )
                      , 1 );
        lib_proc.add ( vs_mlinha
                     , NULL
                     , NULL
                     , 1 );

        vs_mlinha := NULL;
        vs_mlinha :=
            lib_str.w ( vs_mlinha
                      , LPAD ( '-'
                             , 150
                             , '-' )
                      , 1 );
        lib_proc.add ( vs_mlinha
                     , NULL
                     , NULL
                     , 1 );

        vs_mlinha := NULL;
        vs_mlinha :=
            lib_str.w ( vs_mlinha
                      , ' '
                      , 1 );
        lib_proc.add ( vs_mlinha
                     , NULL
                     , NULL
                     , 1 );
    END cabecalho;

    FUNCTION carregar_nf_entrada ( pdt_ini DATE
                                 , pdt_fim DATE
                                 , pcod_estab VARCHAR2
                                 , v_data_hora_ini VARCHAR2 )
        RETURN INTEGER
    IS
        cc_limit NUMBER ( 7 ) := 1000;
        v_count_new INTEGER := 0;
        v_people_de VARCHAR2 ( 5 )
            := ( CASE
                    WHEN SUBSTR ( pcod_estab
                                , 1
                                , 2 ) = 'ST' THEN
                        'ST'
                    ELSE
                        'VD'
                END );
        v_people_para VARCHAR2 ( 5 ) := mcod_empresa; -- DP ou DSP

        CURSOR c
        IS
            SELECT *
              FROM ( SELECT   capa.cod_estab
                            , est1.cod_estado uf_estab
                            , --X04.COD_FIS_JUR FORN_CLI,
                              est.cod_estado uf_forn_cli
                            , capa.data_fiscal data_fiscal
                            , --CAPA.DATA_EMISSAO DATA_EMISSAO,
                              capa.num_docfis numero_nf
                            , capa.serie_docfis serie
                            , capa.num_controle_docto id_people
                            , tipo.cod_docto cod_docto
                            , modelo.cod_modelo AS cod_modelo
                            , fin.cod_natureza_op fin
                            , cfo.cod_cfo cod_cfo
                            , cst.cod_situacao_b cst
                            , SUM ( itens.vlr_contab_item ) vlr_contabil
                            , SUM ( itens.vlr_base_icms_1 ) base_trib
                            , itens.aliq_tributo_icms aliq_tributo_icms
                            , SUM ( itens.vlr_tributo_icms ) vlr_icms
                            , SUM ( itens.vlr_base_icms_2 ) base_isent
                            , SUM ( itens.vlr_base_icms_3 ) base_outras
                            , SUM ( itens.vlr_base_icms_4 ) base_red
                            , SUM ( itens.vlr_tributo_icmss ) vlr_icms_st
                            , SUM ( itens.vlr_ipi_ndestac ) vlr_ipi
                            ,   --
                                SUM ( itens.vlr_contab_item )
                              - SUM ( itens.vlr_base_icms_1 )
                              - SUM ( itens.vlr_base_icms_2 )
                              - SUM ( itens.vlr_base_icms_3 )
                              - SUM ( itens.vlr_base_icms_4 )
                              - SUM ( itens.vlr_tributo_icmss )
                              - SUM ( itens.vlr_ipi_ndestac )
                                  dif_bases
                            , mproc_id AS proc_id
                            , mnm_usuario AS nm_usuario
                            , v_data_hora_ini AS dt_carga
                         FROM msaf.dwt_docto_fiscal capa
                            , msaf.dwt_itens_merc itens
                            , msaf.x04_pessoa_fis_jur x04
                            , msaf.x2012_cod_fiscal cfo
                            , msaf.y2026_sit_trb_uf_b cst
                            , msaf.x2006_natureza_op fin
                            , msaf.estado est
                            , msaf.estado est1
                            , msaf.estabelecimento estab
                            , msaf.x2005_tipo_docto tipo
                            , msaf.x2024_modelo_docto modelo
                        WHERE 1 = 1
                          AND capa.cod_empresa = mcod_empresa
                          AND capa.cod_estab = pcod_estab
                          AND capa.data_fiscal BETWEEN pdt_ini AND pdt_fim
                          AND capa.cod_empresa = itens.cod_empresa
                          AND capa.cod_estab = itens.cod_estab
                          AND capa.data_fiscal = itens.data_fiscal
                          AND capa.movto_e_s = itens.movto_e_s
                          AND capa.norm_dev = itens.norm_dev
                          AND capa.ident_docto = itens.ident_docto
                          AND capa.ident_fis_jur = itens.ident_fis_jur
                          AND capa.num_docfis = itens.num_docfis
                          AND capa.serie_docfis = itens.serie_docfis
                          AND capa.sub_serie_docfis = itens.sub_serie_docfis
                          AND capa.ident_fis_jur = x04.ident_fis_jur
                          AND itens.ident_cfo = cfo.ident_cfo
                          AND itens.ident_situacao_b = cst.ident_situacao_b
                          AND itens.ident_natureza_op = fin.ident_natureza_op
                          AND x04.ident_estado = est.ident_estado
                          AND est1.ident_estado = estab.ident_estado
                          AND capa.ident_docto = tipo.ident_docto
                          AND capa.ident_modelo = modelo.ident_modelo
                          AND capa.cod_estab = estab.cod_estab
                          AND capa.cod_empresa = msafi.dpsp.empresa
                          AND cfo.cod_cfo != '5409'
                          AND capa.situacao = 'N'
                          AND cod_docto NOT IN ( 'CF'
                                               , 'CF-E' )
                     GROUP BY capa.cod_estab
                            , est1.cod_estado
                            , x04.cod_fis_jur
                            , est.cod_estado
                            , capa.data_fiscal
                            , capa.data_emissao
                            , capa.num_docfis
                            , capa.serie_docfis
                            , tipo.cod_docto
                            , modelo.cod_modelo
                            , cfo.cod_cfo
                            , cst.cod_situacao_b
                            , fin.cod_natureza_op
                            , itens.aliq_tributo_icms
                            , capa.num_controle_docto
                            , mproc_id
                            , mnm_usuario
                            , v_data_hora_ini )
            UNION ALL
            SELECT   fin048.cod_estab AS cod_estab
                   , est1.cod_estado AS uf_estab
                   , est.cod_estado AS uf_forn_cli
                   , fin048.data_fiscal AS data_fiscal
                   , fin048.num_docfis AS numero_nf
                   , fin048.serie_docfis AS serie --  NOK
                   , fin048.num_controle_docto AS id_people
                   , fin048.cod_docto AS cod_docto
                   , fin048.cod_modelo AS cod_modelo
                   , fin048.cod_natureza_op AS cod_natureza_op -- NOK
                   , fin048.cod_cfo AS cod_cfo
                   , fin048.cst AS cst
                   , SUM ( NVL ( fin048.vlr_contabil_item, 0 ) ) AS vlr_contabil
                   , SUM ( NVL ( fin048.vlr_base_icms_3, 0 ) ) AS base_trib
                   , fin048.aliq_tributo_icms AS aliq_tributo_icms
                   , SUM ( fin048.icms_proprio ) AS vlr_icms
                   , SUM ( NVL ( fin048.vlr_base_icms_2, 0 ) ) AS base_isent
                   , SUM ( NVL ( fin048.vlr_base_icms_1, 0 ) ) AS base_outras
                   , SUM ( NVL ( fin048.vlr_base_icms_4, 0 ) ) AS base_red
                   , SUM ( NVL ( fin048.vlr_icms_st, 0 ) ) AS vlr_tributo_icmss --OK
                   , SUM ( NVL ( fin048.vlr_ipi_ndestac, 0 ) ) AS vlr_ipi
                   , (   SUM ( NVL ( fin048.vlr_contabil_item, 0 ) )
                       - SUM ( NVL ( fin048.vlr_base_icms_1, 0 ) )
                       - SUM ( NVL ( fin048.vlr_base_icms_2, 0 ) )
                       - SUM ( NVL ( fin048.vlr_base_icms_3, 0 ) )
                       - SUM ( NVL ( fin048.vlr_base_icms_4, 0 ) )
                       - SUM ( NVL ( fin048.vlr_icms_st, 0 ) )
                       - SUM ( NVL ( fin048.vlr_ipi_ndestac, 0 ) ) )
                         dif_bases
                   , --
                     mproc_id AS proc_id
                   , mnm_usuario AS nm_usuario
                   , v_data_hora_ini AS dt_carga
                FROM msafi.dpsp_fin048_ret_nf_sai fin048
                   , estabelecimento estab
                   , estado est
                   , estado est1
                   , x04_pessoa_fis_jur x04
               WHERE fin048.cod_empresa = mcod_empresa
                 AND fin048.cod_estab = pcod_estab
                 AND fin048.data_fiscal BETWEEN pdt_ini AND pdt_fim
                 AND fin048.cod_estab = estab.cod_estab
                 AND x04.ident_estado = est.ident_estado
                 AND est1.ident_estado = estab.ident_estado
                 AND fin048.cod_fis_jur = x04.cod_fis_jur
            GROUP BY fin048.cod_estab
                   , est1.cod_estado
                   , est.cod_estado
                   , fin048.data_fiscal
                   , fin048.num_docfis
                   , fin048.serie_docfis -- SERIE      --  NOK
                   , fin048.num_controle_docto
                   , fin048.cod_docto
                   , fin048.cod_modelo
                   , fin048.cod_natureza_op --  COD_NATUREZA_OP  -- NOK
                   , fin048.cod_cfo
                   , fin048.cst
                   , fin048.aliq_tributo_icms;

        TYPE tcod_estab IS TABLE OF msafi.dpsp_fin048_ret_compete.cod_estab%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tuf_estab IS TABLE OF msafi.dpsp_fin048_ret_compete.uf_estab%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tuf_forn_cli IS TABLE OF msafi.dpsp_fin048_ret_compete.uf_forn_cli%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tdata_fiscal IS TABLE OF msafi.dpsp_fin048_ret_compete.data_fiscal%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tnumero_nf IS TABLE OF msafi.dpsp_fin048_ret_compete.numero_nf%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tserie IS TABLE OF msafi.dpsp_fin048_ret_compete.serie%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tid_people IS TABLE OF msafi.dpsp_fin048_ret_compete.id_people%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tcod_docto IS TABLE OF msafi.dpsp_fin048_ret_compete.cod_docto%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tcod_modelo IS TABLE OF msafi.dpsp_fin048_ret_compete.cod_modelo%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tfin IS TABLE OF msafi.dpsp_fin048_ret_compete.fin%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tcod_cfo IS TABLE OF msafi.dpsp_fin048_ret_compete.cod_cfo%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tcst IS TABLE OF msafi.dpsp_fin048_ret_compete.cst%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tvlr_contabil IS TABLE OF msafi.dpsp_fin048_ret_compete.vlr_contabil%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tbase_trib IS TABLE OF msafi.dpsp_fin048_ret_compete.base_trib%TYPE
            INDEX BY PLS_INTEGER;

        TYPE taliq_tributo_icms IS TABLE OF msafi.dpsp_fin048_ret_compete.aliq_tributo_icms%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tvlr_icms IS TABLE OF msafi.dpsp_fin048_ret_compete.vlr_icms%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tbase_isent IS TABLE OF msafi.dpsp_fin048_ret_compete.base_isent%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tbase_outras IS TABLE OF msafi.dpsp_fin048_ret_compete.base_outras%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tbase_red IS TABLE OF msafi.dpsp_fin048_ret_compete.base_red%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tvlr_icms_st IS TABLE OF msafi.dpsp_fin048_ret_compete.vlr_icms_st%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tvlr_ipi IS TABLE OF msafi.dpsp_fin048_ret_compete.vlr_ipi%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tdif_bases IS TABLE OF msafi.dpsp_fin048_ret_compete.dif_bases%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tproc_id IS TABLE OF msafi.dpsp_fin048_ret_compete.proc_id%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tnm_usuario IS TABLE OF msafi.dpsp_fin048_ret_compete.nm_usuario%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tdt_carga IS TABLE OF msafi.dpsp_fin048_ret_compete.dt_carga%TYPE
            INDEX BY PLS_INTEGER;

        v_cod_estab tcod_estab;
        v_uf_estab tuf_estab;
        v_uf_forn_cli tuf_forn_cli;
        v_data_fiscal tdata_fiscal;
        v_numero_nf tnumero_nf;
        v_serie tserie;
        v_id_people tid_people;
        v_cod_docto tcod_docto;
        v_cod_modelo tcod_modelo;
        v_fin tfin;
        v_cod_cfo tcod_cfo;
        v_cst tcst;
        v_vlr_contabil tvlr_contabil;
        v_base_trib tbase_trib;
        v_aliq_tributo_icms taliq_tributo_icms;
        v_vlr_icms tvlr_icms;
        v_base_isent tbase_isent;
        v_base_outras tbase_outras;
        v_base_red tbase_red;
        v_vlr_icms_st tvlr_icms_st;
        v_vlr_ipi tvlr_ipi;
        v_dif_bases tdif_bases;
        v_proc_id tproc_id;
        v_nm_usuario tnm_usuario;
        v_dt_carga tdt_carga;
    BEGIN
        OPEN c;

        LOOP
            FETCH c
                BULK COLLECT INTO v_cod_estab
                   , v_uf_estab
                   , v_uf_forn_cli
                   , v_data_fiscal
                   , v_numero_nf
                   , v_serie
                   , v_id_people
                   , v_cod_docto
                   , v_cod_modelo
                   , v_fin
                   , v_cod_cfo
                   , v_cst
                   , v_vlr_contabil
                   , v_base_trib
                   , v_aliq_tributo_icms
                   , v_vlr_icms
                   , v_base_isent
                   , v_base_outras
                   , v_base_red
                   , v_vlr_icms_st
                   , v_vlr_ipi
                   , v_dif_bases
                   , v_proc_id
                   , v_nm_usuario
                   , v_dt_carga
                LIMIT cc_limit;

            FORALL i IN v_cod_estab.FIRST .. v_cod_estab.LAST
                INSERT /*+ APPEND */
                      INTO  msafi.dpsp_fin048_ret_compete
                     VALUES ( v_cod_estab ( i )
                            , v_uf_estab ( i )
                            , v_uf_forn_cli ( i )
                            , v_data_fiscal ( i )
                            , v_numero_nf ( i )
                            , v_serie ( i )
                            , v_id_people ( i )
                            , v_cod_docto ( i )
                            , v_cod_modelo ( i )
                            , v_fin ( i )
                            , v_cod_cfo ( i )
                            , v_cst ( i )
                            , v_vlr_contabil ( i )
                            , v_base_trib ( i )
                            , v_aliq_tributo_icms ( i )
                            , v_vlr_icms ( i )
                            , v_base_isent ( i )
                            , v_base_outras ( i )
                            , v_base_red ( i )
                            , v_vlr_icms_st ( i )
                            , v_vlr_ipi ( i )
                            , v_dif_bases ( i )
                            , v_proc_id ( i )
                            , v_nm_usuario ( i )
                            , v_dt_carga ( i ) );

            v_count_new := v_count_new + SQL%ROWCOUNT;

            dbms_application_info.set_module ( $$plsql_unit
                                             , 'Estab: ' || pcod_estab || ' Qtd ' || v_count_new );

            COMMIT;

            v_cod_estab.delete;
            v_uf_estab.delete;
            v_uf_forn_cli.delete;
            v_data_fiscal.delete;
            v_numero_nf.delete;
            v_serie.delete;
            v_id_people.delete;
            v_cod_docto.delete;
            v_cod_modelo.delete;
            v_fin.delete;
            v_cod_cfo.delete;
            v_cst.delete;
            v_vlr_contabil.delete;
            v_base_trib.delete;
            v_aliq_tributo_icms.delete;
            v_vlr_icms.delete;
            v_base_isent.delete;
            v_base_outras.delete;
            v_base_red.delete;
            v_vlr_icms_st.delete;
            v_vlr_ipi.delete;
            v_dif_bases.delete;
            v_proc_id.delete;
            v_nm_usuario.delete;
            v_dt_carga.delete;

            EXIT WHEN c%NOTFOUND;
        END LOOP;

        CLOSE c;

        COMMIT;

        loga (
                  '::QUANTIDADE DE REGISTROS INSERIDOS (DPSP_FIN048_RET_NF_ENT) , CD: '
               || pcod_estab
               || ' - QTDE '
               || NVL ( v_count_new, 0 )
               || '::'
             , FALSE
        );

        RETURN NVL ( v_count_new, 0 );
    END;
END dpsp_fin048_ret_compete_cproc;
/
SHOW ERRORS;
