Prompt Package Body DPSP_FIN275_DEV_MERC_ST_CPROC;
--
-- DPSP_FIN275_DEV_MERC_ST_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_fin275_dev_merc_st_cproc
IS
    mproc_id NUMBER;
    vn_linha NUMBER := 0;
    vn_pagina NUMBER := 0;
    mnm_usuario usuario_estab.cod_usuario%TYPE;
    mcod_empresa estabelecimento.cod_empresa%TYPE;
    vs_mlinha VARCHAR2 ( 4000 );

    --Tipo, Nome e Descrição do Customizado
    --Melhoria FIN275
    mnm_tipo VARCHAR2 ( 100 ) := 'Ressarcimento';
    mnm_cproc VARCHAR2 ( 100 ) := 'Relatório de Devolução de Mercadorias com ICMS-ST';
    mds_cproc VARCHAR2 ( 100 ) := 'Emitir Relatório de Devolução de Mercadorias com ICMS-ST';

    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );
    BEGIN
        mnm_usuario := lib_parametros.recuperar ( UPPER ( 'USUARIO' ) );
        mcod_empresa := lib_parametros.recuperar ( UPPER ( 'EMPRESA' ) );

        -- PPARAM:      STRING PASSADA POR REFERÊNCIA;
        -- PTITULO:     TÍTULO DO PARÂMETRO MOSTRADO NA JANELA;
        -- PTIPO:       VARCHAR2, DATE, INTEGER;
        -- PCONTROLE:   MULTIPROC, TEXT, TEXTBOX, COMBOBOX, LISTBOX OU RADIOBUTTON;
        -- PMANDATORIO: S OU N, INDICANDO SE A INFORMAÇÃO DO PARÂMETRO É OBRIGATÓRIA;
        -- PDEFAULT:    VALOR PREENCHIDO AUTOMATICAMENTE NA ABERTURA DA JANELA;
        -- PMASCARA:    MÁSCARA PARA DIGITAÇÃO (EX: DD/MM/YYYY, 999999 OU ######);
        -- PVALORES:    SELECT (COMBOBOX OU MULTIPROC) OU COD1=DESC1,COD2=DESC2...
        -- PAPRESENTA:  S OU N, INDICANDO SE O PARÂMETRO DEVE SER MOSTRADO NA LISTAGEM DOS PROCESSOS;

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
                             || ''' AND B.IDENT_ESTADO = A.IDENT_ESTADO AND A.COD_EMPRESA = C.COD_EMPRESA AND A.COD_ESTAB = C.COD_ESTAB AND C.TIPO = ''C'' '
                             || ' UNION ALL SELECT COD_ESTAB, COD_ESTAB || '' - '' || COD_ESTADO || '' - '' || CGC ||'' - ''|| INITCAP(BAIRRO) || '' / '' || INITCAP(CIDADE) AS DESCRICAO FROM ESTAB_INTERCOMPANY_DPSP '
                             || ' WHERE TIPO = ''C'''
        );

        lib_proc.add_param (
                             pstr
                           , 'UF'
                           , --P_UF
                            'VARCHAR2'
                           , 'COMBOBOX'
                           , 'S'
                           , '%'
                           , '#########'
                           , 'SELECT A.COD_ESTADO, A.COD_ESTADO FROM ESTADO A UNION ALL SELECT ''%'', ''Todas as UFs'' FROM DUAL ORDER BY 1'
        );

        lib_proc.add_param (
                             pstr
                           , 'Filiais'
                           , --P_LOJAS
                            'VARCHAR2'
                           , 'MULTISELECT'
                           , 'S'
                           , NULL
                           , NULL
                           ,    'SELECT A.COD_ESTAB, A.COD_ESTAB || '' - '' || B.COD_ESTADO || '' - '' || A.CGC || '' - '' || INITCAP(A.BAIRRO) || '' / '' || INITCAP(A.CIDADE) FROM ESTABELECIMENTO A, ESTADO B, MSAFI.DSP_ESTABELECIMENTO C WHERE A.COD_EMPRESA  = '''
                             || mcod_empresa
                             || ''' AND B.IDENT_ESTADO = A.IDENT_ESTADO AND A.COD_EMPRESA = C.COD_EMPRESA AND A.COD_ESTAB = C.COD_ESTAB AND B.COD_ESTADO LIKE :4 AND C.TIPO = ''L'' ORDER BY B.COD_ESTADO, A.COD_ESTAB'
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
                      , pcod_cd VARCHAR2
                      , pcod_estado VARCHAR2
                      , pcod_filial lib_proc.vartab )
        RETURN INTEGER
    IS
        v_qtd INTEGER;
        v_existe_origem CHAR := 'S';
        v_validar_status INTEGER := 0;

        v_data_inicial DATE
            :=   TRUNC ( pdt_ini )
               - (   TO_NUMBER ( TO_CHAR ( pdt_ini
                                         , 'DD' ) )
                   - 1 );
        v_data_final DATE := LAST_DAY ( pdt_fim );
        v_data_hora_ini VARCHAR2 ( 20 );
        p_proc_instance VARCHAR2 ( 30 );

        v_retorno_status VARCHAR2 ( 4000 );

        v_cd_arquivo INTEGER := 2; -- ARQUIVO

        CURSOR c_cds
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
               AND a.cod_estab = (CASE WHEN pcod_cd = 'TODOS' THEN a.cod_estab ELSE pcod_cd END)
            UNION ALL
            SELECT cod_estab
              FROM estab_intercompany_dpsp
             WHERE tipo = 'C'
               AND cod_estab = (CASE WHEN pcod_cd = 'TODOS' THEN cod_estab ELSE pcod_cd END);
    BEGIN
        -- Criação: Processo
        mproc_id :=
            lib_proc.new ( psp_nome => 'DPSP_FIN275_DEV_MERC_ST_CPROC'
                         , prows => 48
                         , pcols => 200 );

        --Tela DW
        lib_proc.add_tipo ( pproc_id => mproc_id
                          , ptipo => 1
                          , ptitulo =>    TO_CHAR ( SYSDATE
                                                  , 'YYYYMMDDHH24MISS' )
                                       || '_Devolucao_Merc_ST'
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
                      , pcod_cd
                      , pcod_estado );
        END LOOP;

        loga ( '---INI DO PROCESSAMENTO---'
             , FALSE );
        loga ( '<< PERIODO DE: ' || v_data_inicial || ' A ' || v_data_final || ' >>'
             , FALSE );

        --Permitir processo somente para um mês
        IF LAST_DAY ( pdt_ini ) = LAST_DAY ( pdt_fim ) THEN
            --=================================================================================
            -- Carregar Temporaria para extrair Filias selecionadas
            --=================================================================================
            --Limpeza registros da tabela 1 dia atrás
            DELETE FROM msafi.dpsp_fin275_tab_filial
                  WHERE TO_DATE ( SUBSTR ( dt_carga
                                         , 1
                                         , 10 )
                                , 'DD/MM/YYYY' ) < TO_DATE ( SYSDATE - 1
                                                           , 'DD/MM/YYYY' );

            COMMIT;

            FOR v_cod_filial IN pcod_filial.FIRST .. pcod_filial.LAST LOOP
                FOR f IN ( SELECT a.cod_estab
                                , b.cod_estado
                             FROM estabelecimento a
                                , estado b
                                , msafi.dsp_estabelecimento c
                            WHERE b.ident_estado = a.ident_estado
                              AND a.cod_empresa = c.cod_empresa
                              AND a.cod_estab = c.cod_estab
                              AND c.tipo = 'L'
                              AND b.cod_estado = (CASE WHEN pcod_estado = '%' THEN b.cod_estado ELSE pcod_estado END)
                              AND a.cod_empresa = mcod_empresa
                              AND a.cod_estab = pcod_filial ( v_cod_filial ) ) LOOP
                    INSERT INTO msafi.dpsp_fin275_tab_filial ( cod_empresa
                                                             , cod_estab
                                                             , cod_estado
                                                             , proc_id
                                                             , nm_usuario
                                                             , dt_carga )
                         VALUES ( mcod_empresa
                                , f.cod_estab
                                , f.cod_estado
                                , mproc_id
                                , mnm_usuario
                                , v_data_hora_ini );
                END LOOP;
            END LOOP;

            COMMIT;

            --=================================================================================
            -- INICIO
            --=================================================================================
            -- Um CD por Vez
            FOR cd IN c_cds LOOP
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
                -- IGUAL À ZERO:      PARA PROCESSOS ABERTOS - AÇÃO: CARREGAR TABELA DEV MERC ST
                -- DIFERENTE DE ZERO: PARA PROCESSOS ENCERRADOS - AÇÃO: CONSULTAR TABELA DEV MERC ST
                ---------------------

                v_validar_status :=
                    msaf.dpsp_suporte_cproc_process.validar_status_rel ( mcod_empresa
                                                                       , cd.cod_estab
                                                                       , TO_NUMBER ( TO_CHAR ( pdt_ini
                                                                                             , 'YYYYMM' ) )
                                                                       , $$plsql_unit );

                --=================================================================================
                -- CARREGAR TABELA Devolução Mercadoria ST em periodos Abertos
                --=================================================================================
                IF v_validar_status = 0 THEN
                    loga ( '>> INICIO CD: ' || cd.cod_estab || ' PROC INSERT ' || p_proc_instance
                         , FALSE );

                    ---------------------
                    -- LIMPEZA
                    ---------------------
                    DELETE FROM msafi.dpsp_fin275_dev_merc_st
                          WHERE empresa = mcod_empresa
                            AND cd_destino = cd.cod_estab
                            AND data_fiscal BETWEEN v_data_inicial AND v_data_final;

                    loga (
                              '::LIMPEZA DOS REGISTROS ANTERIORES (DPSP_FIN275_DEV_MERC_ST), CD: '
                           || cd.cod_estab
                           || ' - QTDE '
                           || SQL%ROWCOUNT
                           || '::'
                         , FALSE
                    );

                    COMMIT;

                    --A carga irá executar o periodo inteiro, e depois consultar o periodo informado na tela.
                    --Exemplo: Parametrizado do dia 5 ao 10, então será carregado de 1 a 31, mas consultado de 5 a 10
                    v_qtd :=
                        carregar_dev_merc ( v_data_inicial
                                          , v_data_final
                                          , cd.cod_estab
                                          , v_data_hora_ini );

                    ---------------------
                    -- Informar Filias que retornarem sem dados de origem / select zerado
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
                            loga ( '---CD ' || cd.cod_estab || ' - PERIODO ENCERRADO: ' || v_retorno_status || '---'
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

                v_qtd := 0;
                v_retorno_status := '';
            END LOOP;

            --=================================================================================
            -- GERAR ARQUIVOS: ANALITICO E SINTETICO
            --=================================================================================
            FOR cd IN c_cds LOOP
                SELECT COUNT ( 1 )
                  INTO v_qtd
                  FROM msafi.dpsp_fin275_dev_merc_st a
                 WHERE 1 = 1
                   AND a.empresa = mcod_empresa
                   AND a.cd_destino = cd.cod_estab
                   AND a.data_fiscal BETWEEN v_data_inicial AND v_data_final
                   AND ROWNUM = 1;

                IF v_qtd > 0 THEN
                    arquivo_analitico ( cd.cod_estab
                                      , pdt_ini
                                      , pdt_fim
                                      , v_cd_arquivo );
                    v_cd_arquivo := v_cd_arquivo + 1;

                    arquivo_sintetico ( cd.cod_estab
                                      , pdt_ini
                                      , pdt_fim
                                      , v_cd_arquivo );
                    v_cd_arquivo := v_cd_arquivo + 1;
                END IF;
            END LOOP;

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

            loga ( '---FIM DO PROCESSAMENTO---'
                 , FALSE );
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

        lib_proc.add ( 'Favor verificar LOG para detalhes.'
                     , 1 );
        lib_proc.add ( ' '
                     , 1 );

        loga ( '>>> Fim do relatório!'
             , FALSE );

        lib_proc.close;
        RETURN mproc_id;
    EXCEPTION
        WHEN OTHERS THEN
            loga ( 'SQLERRM: ' || SQLERRM
                 , FALSE );
            lib_proc.add_log ( 'Erro não tratado: ' || dbms_utility.format_error_backtrace
                             , 1 );
            lib_proc.add_log ( 'SQLERRM: ' || SQLERRM
                             , 1 );
            lib_proc.add ( 'ERRO!'
                         , 1 );
            lib_proc.add ( ' '
                         , 1 );
            lib_proc.add ( dbms_utility.format_error_backtrace
                         , 1 );

            --ENVIAR EMAIL DE ERRO-------------------------------------------
            envia_email ( mcod_empresa
                        , v_data_inicial
                        , v_data_final
                        , SQLERRM
                        , 'E'
                        , v_data_hora_ini );
            -----------------------------------------------------------------

            lib_proc.close;
            COMMIT;
            RETURN mproc_id;
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
                     , 'DPSP_FIN275_DEV_MERC_ST_CPROC' );
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
                     , 'DPSP_FIN275_DEV_MERC_ST_CPROC' );
        END IF;
    END;

    PROCEDURE cabecalho ( pnm_empresa VARCHAR2
                        , pcnpj VARCHAR2
                        , v_data_hora_ini VARCHAR2
                        , mnm_cproc VARCHAR2
                        , pdt_ini DATE
                        , pdt_fim DATE
                        , pcod_cd VARCHAR2
                        , pcod_estado VARCHAR2 )
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
        vs_mlinha := 'CD: ' || pcod_cd;
        lib_proc.add ( vs_mlinha
                     , NULL
                     , NULL
                     , 1 );

        vs_mlinha := NULL;
        vs_mlinha := 'UF: ' || ( CASE WHEN pcod_estado = '%' THEN 'Todas as UFs' ELSE pcod_estado END );
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

    FUNCTION carregar_dev_merc ( pdt_ini DATE
                               , pdt_fim DATE
                               , pcod_estab VARCHAR2
                               , v_data_hora_ini VARCHAR2 )
        RETURN INTEGER
    IS
        v_count_new INTEGER := 0;

        cc_limit NUMBER ( 7 ) := 1000;

        CURSOR c_sped
        IS
            SELECT   x07.cod_empresa AS empresa
                   , x07.cod_estab AS estabelecimento
                   , est.cod_estado AS uf
                   , x07.data_fiscal AS data_fiscal
                   , x07.num_docfis AS num_nf
                   , x07.num_controle_docto AS id_people
                   , x07.num_autentic_nfe AS chave_de_acesso
                   , x07.situacao AS situacao_nf
                   , x04.cod_fis_jur AS cod_fornecedor
                   , x04.cpf_cgc AS cpf_cgc
                   , x04.razao_social AS razao_social
                   , x2006.cod_natureza_op AS fin
                   , x2012.cod_cfo AS cfop
                   , y2025.cod_situacao_a AS cst_a
                   , y2026.cod_situacao_b AS cst_b
                   , SUM ( x08.vlr_contab_item ) AS vlr_contabil
                   , SUM ( ( SELECT x08_bm.vlr_base
                               FROM msaf.x08_base_merc x08_bm
                              WHERE x08_bm.cod_empresa = x08.cod_empresa
                                AND x08_bm.cod_estab = x08.cod_estab
                                AND x08_bm.data_fiscal = x08.data_fiscal
                                AND x08_bm.movto_e_s = x08.movto_e_s
                                AND x08_bm.norm_dev = x08.norm_dev
                                AND x08_bm.ident_docto = x08.ident_docto
                                AND x08_bm.ident_fis_jur = x08.ident_fis_jur
                                AND x08_bm.num_docfis = x08.num_docfis
                                AND x08_bm.serie_docfis = x08.serie_docfis
                                AND x08_bm.sub_serie_docfis = x08.sub_serie_docfis
                                AND x08_bm.discri_item = x08.discri_item
                                AND x08_bm.cod_tributo = 'ICMS'
                                AND x08_bm.cod_tributacao = 1
                                AND x08_bm.cod_empresa = x07.cod_empresa
                                AND x08_bm.cod_estab = x07.cod_estab ) )
                         AS base_icms
                   , SUM ( ( SELECT x08_tm.vlr_tributo
                               FROM msaf.x08_trib_merc x08_tm
                              WHERE x08_tm.cod_empresa = x08.cod_empresa
                                AND x08_tm.cod_estab = x08.cod_estab
                                AND x08_tm.data_fiscal = x08.data_fiscal
                                AND x08_tm.movto_e_s = x08.movto_e_s
                                AND x08_tm.norm_dev = x08.norm_dev
                                AND x08_tm.ident_docto = x08.ident_docto
                                AND x08_tm.ident_fis_jur = x08.ident_fis_jur
                                AND x08_tm.num_docfis = x08.num_docfis
                                AND x08_tm.serie_docfis = x08.serie_docfis
                                AND x08_tm.sub_serie_docfis = x08.sub_serie_docfis
                                AND x08_tm.discri_item = x08.discri_item
                                AND x08_tm.cod_tributo = x08_base.cod_tributo
                                AND x08_tm.cod_tributo = 'ICMS'
                                AND x08_base.cod_tributacao = 1
                                AND x08_tm.cod_empresa = x07.cod_empresa
                                AND x08_tm.cod_estab = x07.cod_estab ) )
                         AS icms
                   , SUM ( ( SELECT x08_bm.vlr_base
                               FROM msaf.x08_base_merc x08_bm
                              WHERE x08_bm.cod_empresa = x08.cod_empresa
                                AND x08_bm.cod_estab = x08.cod_estab
                                AND x08_bm.data_fiscal = x08.data_fiscal
                                AND x08_bm.movto_e_s = x08.movto_e_s
                                AND x08_bm.norm_dev = x08.norm_dev
                                AND x08_bm.ident_docto = x08.ident_docto
                                AND x08_bm.ident_fis_jur = x08.ident_fis_jur
                                AND x08_bm.num_docfis = x08.num_docfis
                                AND x08_bm.serie_docfis = x08.serie_docfis
                                AND x08_bm.sub_serie_docfis = x08.sub_serie_docfis
                                AND x08_bm.discri_item = x08.discri_item
                                AND x08_bm.cod_tributo = 'ICMS'
                                AND x08_bm.cod_tributacao = 2
                                AND x08.ident_situacao_b IN ( 17
                                                            , 18 )
                                AND x08_bm.cod_empresa = x07.cod_empresa
                                AND x08_bm.cod_estab = x07.cod_estab ) )
                         AS base_isenta
                   , SUM ( ( SELECT x08_bm.vlr_base
                               FROM msaf.x08_base_merc x08_bm
                              WHERE x08_bm.cod_empresa = x08.cod_empresa
                                AND x08_bm.cod_estab = x08.cod_estab
                                AND x08_bm.data_fiscal = x08.data_fiscal
                                AND x08_bm.movto_e_s = x08.movto_e_s
                                AND x08_bm.norm_dev = x08.norm_dev
                                AND x08_bm.ident_docto = x08.ident_docto
                                AND x08_bm.ident_fis_jur = x08.ident_fis_jur
                                AND x08_bm.num_docfis = x08.num_docfis
                                AND x08_bm.serie_docfis = x08.serie_docfis
                                AND x08_bm.sub_serie_docfis = x08.sub_serie_docfis
                                AND x08_bm.discri_item = x08.discri_item
                                AND x08_bm.cod_tributo = 'ICMS'
                                AND x08_bm.cod_tributacao = 3
                                AND x08_bm.cod_empresa = x07.cod_empresa
                                AND x08_bm.cod_estab = x07.cod_estab ) )
                         base_outras
                   , SUM ( ( SELECT x08_bm.vlr_base
                               FROM msaf.x08_base_merc x08_bm
                              WHERE x08_bm.cod_empresa = x08.cod_empresa
                                AND x08_bm.cod_estab = x08.cod_estab
                                AND x08_bm.data_fiscal = x08.data_fiscal
                                AND x08_bm.movto_e_s = x08.movto_e_s
                                AND x08_bm.norm_dev = x08.norm_dev
                                AND x08_bm.ident_docto = x08.ident_docto
                                AND x08_bm.ident_fis_jur = x08.ident_fis_jur
                                AND x08_bm.num_docfis = x08.num_docfis
                                AND x08_bm.serie_docfis = x08.serie_docfis
                                AND x08_bm.sub_serie_docfis = x08.sub_serie_docfis
                                AND x08_bm.discri_item = x08.discri_item
                                AND x08_bm.cod_tributo = 'ICMS-S'
                                AND x08_bm.cod_tributacao = 1
                                AND x08_bm.cod_empresa = x07.cod_empresa
                                AND x08_bm.cod_estab = x07.cod_estab ) )
                         base_icms_st
                   , SUM ( ( SELECT x08_tm.vlr_tributo
                               FROM msaf.x08_trib_merc x08_tm
                              WHERE x08_tm.cod_empresa = x08_base.cod_empresa
                                AND x08_tm.cod_estab = x08_base.cod_estab
                                AND x08_tm.data_fiscal = x08_base.data_fiscal
                                AND x08_tm.movto_e_s = x08_base.movto_e_s
                                AND x08_tm.norm_dev = x08_base.norm_dev
                                AND x08_tm.ident_docto = x08_base.ident_docto
                                AND x08_tm.ident_fis_jur = x08_base.ident_fis_jur
                                AND x08_tm.num_docfis = x08_base.num_docfis
                                AND x08_tm.serie_docfis = x08_base.serie_docfis
                                AND x08_tm.sub_serie_docfis = x08_base.sub_serie_docfis
                                AND x08_tm.discri_item = x08_base.discri_item
                                AND x08_tm.cod_tributo = 'ICMS-S'
                                AND x08_tm.cod_empresa = x07.cod_empresa
                                AND x08_tm.cod_estab = x07.cod_estab ) )
                         AS icms_st
                   , --Campos Internos
                     cd_dest.cod_estab AS cd_destino
                   , mproc_id AS proc_id
                   , mnm_usuario AS nm_usuario
                   , v_data_hora_ini AS dt_carga
                FROM msaf.estabelecimento estab
                   , msaf.estado est
                   , msaf.x07_docto_fiscal x07
                   , msaf.x08_itens_merc x08
                   , msaf.x08_base_merc x08_base
                   , msaf.x08_trib_merc x08_trib
                   , msaf.x2012_cod_fiscal x2012
                   , msaf.x04_pessoa_fis_jur x04
                   , (SELECT DISTINCT *
                        FROM (SELECT a.cod_estab
                                   , a.cgc
                                FROM estabelecimento a
                                   , estado b
                                   , msafi.dsp_estabelecimento c
                               WHERE b.ident_estado = a.ident_estado
                                 AND a.cod_empresa = c.cod_empresa
                                 AND a.cod_estab = c.cod_estab
                                 AND c.tipo = 'C'
                                 AND a.cod_empresa = mcod_empresa
                                 AND a.cod_estab = pcod_estab
                              UNION ALL
                              SELECT cod_estab
                                   , cgc
                                FROM estab_intercompany_dpsp
                               WHERE tipo = 'C'
                                 AND cod_estab = pcod_estab)) cd_dest
                   , msaf.y2026_sit_trb_uf_b y2026
                   , msaf.y2025_sit_trb_uf_a y2025
                   , msaf.x2006_natureza_op x2006
               WHERE 1 = 1
                 --CD DE DESTINO
                 AND x07.ident_fis_jur = x04.ident_fis_jur
                 AND x04.cpf_cgc = cd_dest.cgc
                 --FILTROS CONFORME LAYOUT
                 AND x2012.cod_cfo IN ( 5209
                                      , 6209
                                      , 5411
                                      , 6411 )
                 AND x07.situacao = 'N'
                 AND x2006.cod_natureza_op = 'IST'
                 AND x08.norm_dev = '2'
                 AND x07.cod_empresa = mcod_empresa
                 AND x07.data_fiscal BETWEEN pdt_ini AND pdt_fim
                 AND x07.cod_empresa = x08.cod_empresa
                 AND x07.cod_estab = x08.cod_estab
                 AND x07.data_fiscal = x08.data_fiscal
                 AND x07.movto_e_s = x08.movto_e_s
                 AND x07.norm_dev = x08.norm_dev
                 AND x07.ident_docto = x08.ident_docto
                 AND x07.ident_fis_jur = x08.ident_fis_jur
                 AND x07.num_docfis = x08.num_docfis
                 AND x07.serie_docfis = x08.serie_docfis
                 AND x07.sub_serie_docfis = x08.sub_serie_docfis
                 AND x08.cod_empresa = x08_base.cod_empresa
                 AND x08.cod_estab = x08_base.cod_estab
                 AND x08.data_fiscal = x08_base.data_fiscal
                 AND x08.movto_e_s = x08_base.movto_e_s
                 AND x08.norm_dev = x08_base.norm_dev
                 AND x08.ident_docto = x08_base.ident_docto
                 AND x08.ident_fis_jur = x08_base.ident_fis_jur
                 AND x08.num_docfis = x08_base.num_docfis
                 AND x08.serie_docfis = x08_base.serie_docfis
                 AND x08.sub_serie_docfis = x08_base.sub_serie_docfis
                 AND x08.discri_item = x08_base.discri_item
                 AND x08.cod_empresa = x08_trib.cod_empresa
                 AND x08.cod_estab = x08_trib.cod_estab
                 AND x08.data_fiscal = x08_trib.data_fiscal
                 AND x08.movto_e_s = x08_trib.movto_e_s
                 AND x08.norm_dev = x08_trib.norm_dev
                 AND x08.ident_docto = x08_trib.ident_docto
                 AND x08.ident_fis_jur = x08_trib.ident_fis_jur
                 AND x08.num_docfis = x08_trib.num_docfis
                 AND x08.serie_docfis = x08_trib.serie_docfis
                 AND x08.sub_serie_docfis = x08_trib.sub_serie_docfis
                 AND x08_base.discri_item = x08_trib.discri_item
                 AND x08_base.cod_tributo = x08_trib.cod_tributo
                 AND x08.ident_cfo = x2012.ident_cfo
                 AND x08.ident_situacao_b = y2026.ident_situacao_b
                 AND x08.ident_situacao_a = y2025.ident_situacao_a
                 AND x08.ident_natureza_op = x2006.ident_natureza_op
                 AND x08_base.cod_tributo = 'ICMS'
                 AND x08_base.cod_tributacao = '1'
                 AND estab.cod_empresa = x07.cod_empresa
                 AND estab.cod_estab = x07.cod_estab
                 AND estab.ident_estado = est.ident_estado
            GROUP BY x07.cod_empresa
                   , x07.cod_estab
                   , est.cod_estado
                   , x07.data_fiscal
                   , x07.num_docfis
                   , x07.num_controle_docto
                   , x07.num_autentic_nfe
                   , x07.situacao
                   , x04.cod_fis_jur
                   , x04.cpf_cgc
                   , x04.razao_social
                   , x2006.cod_natureza_op
                   , x2012.cod_cfo
                   , y2025.cod_situacao_a
                   , y2026.cod_situacao_b
                   , cd_dest.cod_estab
                   , mproc_id
                   , mnm_usuario
                   , v_data_hora_ini;

        --============================================================================

        TYPE tempresa IS TABLE OF msafi.dpsp_fin275_dev_merc_st.empresa%TYPE
            INDEX BY PLS_INTEGER;

        TYPE testabelecimento IS TABLE OF msafi.dpsp_fin275_dev_merc_st.estabelecimento%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tuf IS TABLE OF msafi.dpsp_fin275_dev_merc_st.uf%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tdata_fiscal IS TABLE OF msafi.dpsp_fin275_dev_merc_st.data_fiscal%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tnum_nf IS TABLE OF msafi.dpsp_fin275_dev_merc_st.num_nf%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tid_people IS TABLE OF msafi.dpsp_fin275_dev_merc_st.id_people%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tchave_de_acesso IS TABLE OF msafi.dpsp_fin275_dev_merc_st.chave_de_acesso%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tsituacao_nf IS TABLE OF msafi.dpsp_fin275_dev_merc_st.situacao_nf%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tcod_fornecedor IS TABLE OF msafi.dpsp_fin275_dev_merc_st.cod_fornecedor%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tcpf_cgc IS TABLE OF msafi.dpsp_fin275_dev_merc_st.cpf_cgc%TYPE
            INDEX BY PLS_INTEGER;

        TYPE trazao_social IS TABLE OF msafi.dpsp_fin275_dev_merc_st.razao_social%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tfin IS TABLE OF msafi.dpsp_fin275_dev_merc_st.fin%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tcfop IS TABLE OF msafi.dpsp_fin275_dev_merc_st.cfop%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tcst_a IS TABLE OF msafi.dpsp_fin275_dev_merc_st.cst_a%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tcst_b IS TABLE OF msafi.dpsp_fin275_dev_merc_st.cst_b%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tvlr_contabil IS TABLE OF msafi.dpsp_fin275_dev_merc_st.vlr_contabil%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tbase_icms IS TABLE OF msafi.dpsp_fin275_dev_merc_st.base_icms%TYPE
            INDEX BY PLS_INTEGER;

        TYPE ticms IS TABLE OF msafi.dpsp_fin275_dev_merc_st.icms%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tbase_isenta IS TABLE OF msafi.dpsp_fin275_dev_merc_st.base_isenta%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tbase_outras IS TABLE OF msafi.dpsp_fin275_dev_merc_st.base_outras%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tbase_icms_st IS TABLE OF msafi.dpsp_fin275_dev_merc_st.base_icms_st%TYPE
            INDEX BY PLS_INTEGER;

        TYPE ticms_st IS TABLE OF msafi.dpsp_fin275_dev_merc_st.icms_st%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tcd_destino IS TABLE OF msafi.dpsp_fin275_dev_merc_st.cd_destino%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tproc_id IS TABLE OF msafi.dpsp_fin275_dev_merc_st.proc_id%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tnm_usuario IS TABLE OF msafi.dpsp_fin275_dev_merc_st.nm_usuario%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tdt_carga IS TABLE OF msafi.dpsp_fin275_dev_merc_st.dt_carga%TYPE
            INDEX BY PLS_INTEGER;

        v_empresa tempresa;
        v_estabelecimento testabelecimento;
        v_uf tuf;
        v_data_fiscal tdata_fiscal;
        v_num_nf tnum_nf;
        v_id_people tid_people;
        v_chave_de_acesso tchave_de_acesso;
        v_situacao_nf tsituacao_nf;
        v_cod_fornecedor tcod_fornecedor;
        v_cpf_cgc tcpf_cgc;
        v_razao_social trazao_social;
        v_fin tfin;
        v_cfop tcfop;
        v_cst_a tcst_a;
        v_cst_b tcst_b;
        v_vlr_contabil tvlr_contabil;
        v_base_icms tbase_icms;
        v_icms ticms;
        v_base_isenta tbase_isenta;
        v_base_outras tbase_outras;
        v_base_icms_st tbase_icms_st;
        v_icms_st ticms_st;
        v_cd_destino tcd_destino;
        v_proc_id tproc_id;
        v_nm_usuario tnm_usuario;
        v_dt_carga tdt_carga;
    BEGIN
        dbms_application_info.set_module ( $$plsql_unit
                                         , 'Estab ' || pcod_estab || ' - Carregar' );

        BEGIN
            OPEN c_sped;
        EXCEPTION
            WHEN OTHERS THEN
                loga ( 'SQLERRM: ' || SQLERRM
                     , FALSE );
                loga ( 'Erro não tratado: ' || dbms_utility.format_error_backtrace
                     , FALSE );
                loga ( 'SQLERRM: ' || SQLERRM
                     , FALSE );
                loga ( 'ERRO!'
                     , FALSE );
                loga ( dbms_utility.format_error_backtrace
                     , FALSE );
                --ENVIAR EMAIL DE ERRO-------------------------------------------
                envia_email ( mcod_empresa
                            , pdt_ini
                            , pdt_fim
                            , SQLERRM
                            , 'E'
                            , v_data_hora_ini );
                -----------------------------------------------------------------
                raise_application_error ( -20007
                                        , '!ERRO SELECT DADOS XML REFUGO!' );
        END;

        LOOP
            FETCH c_sped
                BULK COLLECT INTO v_empresa
                   , v_estabelecimento
                   , v_uf
                   , v_data_fiscal
                   , v_num_nf
                   , v_id_people
                   , v_chave_de_acesso
                   , v_situacao_nf
                   , v_cod_fornecedor
                   , v_cpf_cgc
                   , v_razao_social
                   , v_fin
                   , v_cfop
                   , v_cst_a
                   , v_cst_b
                   , v_vlr_contabil
                   , v_base_icms
                   , v_icms
                   , v_base_isenta
                   , v_base_outras
                   , v_base_icms_st
                   , v_icms_st
                   , v_cd_destino
                   , v_proc_id
                   , v_nm_usuario
                   , v_dt_carga
                LIMIT cc_limit;

            FORALL i IN v_empresa.FIRST .. v_empresa.LAST SAVE EXCEPTIONS
                INSERT /*+ APPEND */
                      INTO  msafi.dpsp_fin275_dev_merc_st ( empresa
                                                          , estabelecimento
                                                          , uf
                                                          , data_fiscal
                                                          , num_nf
                                                          , id_people
                                                          , chave_de_acesso
                                                          , situacao_nf
                                                          , cod_fornecedor
                                                          , cpf_cgc
                                                          , razao_social
                                                          , fin
                                                          , cfop
                                                          , cst_a
                                                          , cst_b
                                                          , vlr_contabil
                                                          , base_icms
                                                          , icms
                                                          , base_isenta
                                                          , base_outras
                                                          , base_icms_st
                                                          , icms_st
                                                          , cd_destino
                                                          , proc_id
                                                          , nm_usuario
                                                          , dt_carga )
                     VALUES ( v_empresa ( i )
                            , v_estabelecimento ( i )
                            , v_uf ( i )
                            , v_data_fiscal ( i )
                            , v_num_nf ( i )
                            , v_id_people ( i )
                            , v_chave_de_acesso ( i )
                            , v_situacao_nf ( i )
                            , v_cod_fornecedor ( i )
                            , v_cpf_cgc ( i )
                            , v_razao_social ( i )
                            , v_fin ( i )
                            , v_cfop ( i )
                            , v_cst_a ( i )
                            , v_cst_b ( i )
                            , v_vlr_contabil ( i )
                            , v_base_icms ( i )
                            , v_icms ( i )
                            , v_base_isenta ( i )
                            , v_base_outras ( i )
                            , v_base_icms_st ( i )
                            , v_icms_st ( i )
                            , v_cd_destino ( i )
                            , v_proc_id ( i )
                            , v_nm_usuario ( i )
                            , v_dt_carga ( i ) );

            v_count_new := v_count_new + SQL%ROWCOUNT;

            dbms_application_info.set_module ( $$plsql_unit
                                             , 'Estab ' || pcod_estab || ' - Qtd ' || v_count_new );

            COMMIT;

            v_empresa.delete;
            v_estabelecimento.delete;
            v_uf.delete;
            v_data_fiscal.delete;
            v_num_nf.delete;
            v_id_people.delete;
            v_chave_de_acesso.delete;
            v_situacao_nf.delete;
            v_cod_fornecedor.delete;
            v_cpf_cgc.delete;
            v_razao_social.delete;
            v_fin.delete;
            v_cfop.delete;
            v_cst_a.delete;
            v_cst_b.delete;
            v_vlr_contabil.delete;
            v_base_icms.delete;
            v_icms.delete;
            v_base_isenta.delete;
            v_base_outras.delete;
            v_base_icms_st.delete;
            v_icms_st.delete;
            v_cd_destino.delete;
            v_proc_id.delete;
            v_nm_usuario.delete;
            v_dt_carga.delete;

            EXIT WHEN c_sped%NOTFOUND;
        END LOOP;

        CLOSE c_sped;

        COMMIT;

        loga (
                  '::QUANTIDADE DE REGISTROS INSERIDOS (DPSP_FIN275_DEV_MERC_ST) , CD '
               || pcod_estab
               || ' - QTDE '
               || NVL ( v_count_new, 0 )
               || '::'
             , FALSE
        );

        RETURN NVL ( v_count_new, 0 );
    END;

    PROCEDURE arquivo_analitico ( pcod_estab VARCHAR2
                                , pdt_ini DATE
                                , pdt_fim DATE
                                , v_cd_arquivo INTEGER )
    IS
        i INTEGER := v_cd_arquivo;
        --Variaveis genericas
        v_text01 VARCHAR2 ( 6000 );
        v_sep VARCHAR2 ( 1 ) := CHR ( 9 );
        v_class VARCHAR2 ( 1 ) := 'a';
    BEGIN
        --Arquivo Analitico
        lib_proc.add_tipo ( mproc_id
                          , i
                          ,    pcod_estab
                            || '_'
                            || TO_CHAR ( pdt_ini
                                       , 'YYYYMM' )
                            || '_Devolucao_Merc_ST_Analitico.xls'
                          , 2 );

        lib_proc.add ( dsp_planilha.header
                     , ptipo => i );
        lib_proc.add ( dsp_planilha.tabela_inicio
                     , ptipo => i );

        /*LIB_PROC.ADD(DSP_PLANILHA.LINHA(P_CONTEUDO => DSP_PLANILHA.CAMPO('') || --
                                         DSP_PLANILHA.CAMPO('') || --
                                         DSP_PLANILHA.CAMPO('') || --
                                         DSP_PLANILHA.CAMPO('') || --
                                         DSP_PLANILHA.CAMPO('') || --
                                         DSP_PLANILHA.CAMPO('') || --
                                         DSP_PLANILHA.CAMPO('') || --
                                         DSP_PLANILHA.CAMPO('') || --
                                         DSP_PLANILHA.CAMPO('') || --
                                         DSP_PLANILHA.CAMPO('') || --
                                         DSP_PLANILHA.CAMPO('') || --
                                         DSP_PLANILHA.CAMPO('') || --
                                         DSP_PLANILHA.CAMPO('') || --
                                         DSP_PLANILHA.CAMPO('') || --
                                         DSP_PLANILHA.CAMPO('') || --
                                         DSP_PLANILHA.CAMPO('') || --
                                         DSP_PLANILHA.CAMPO('') || --
                                         DSP_PLANILHA.CAMPO('') || --
                                         DSP_PLANILHA.CAMPO('') || --
                                         DSP_PLANILHA.CAMPO('') || --
                                         DSP_PLANILHA.CAMPO('') || --
                                         DSP_PLANILHA.CAMPO('') || --
                                         DSP_PLANILHA.CAMPO('') || --
                                         DSP_PLANILHA.CAMPO('') || --
                                         DSP_PLANILHA.CAMPO('') || --
                                         DSP_PLANILHA.CAMPO(''),
                           P_CLASS    => 'h'),
        PTIPO => i);
        */

        lib_proc.add ( dsp_planilha.linha (
                                            p_conteudo =>    dsp_planilha.campo ( 'EMPRESA' )
                                                          || --
                                                            dsp_planilha.campo ( 'ESTABELECIMENTO' )
                                                          || --
                                                            dsp_planilha.campo ( 'UF' )
                                                          || --
                                                            dsp_planilha.campo ( 'DATA_FISCAL' )
                                                          || --
                                                            dsp_planilha.campo ( 'NUM_NF' )
                                                          || --
                                                            dsp_planilha.campo ( 'ID_PEOPLE' )
                                                          || --
                                                            dsp_planilha.campo ( 'CHAVE_DE_ACESSO' )
                                                          || --
                                                            dsp_planilha.campo ( 'SITUACAO_NF' )
                                                          || --
                                                            dsp_planilha.campo ( 'COD_FORNECEDOR' )
                                                          || --
                                                            dsp_planilha.campo ( 'CPF_CGC' )
                                                          || --
                                                            dsp_planilha.campo ( 'RAZAO_SOCIAL' )
                                                          || --
                                                            dsp_planilha.campo ( 'FIN' )
                                                          || --
                                                            dsp_planilha.campo ( 'CFOP' )
                                                          || --
                                                            dsp_planilha.campo ( 'CST_A' )
                                                          || --
                                                            dsp_planilha.campo ( 'CST_B' )
                                                          || --
                                                            dsp_planilha.campo ( 'VLR_CONTABIL' )
                                                          || --
                                                            dsp_planilha.campo ( 'BASE_ICMS' )
                                                          || --
                                                            dsp_planilha.campo ( 'ICMS' )
                                                          || --
                                                            dsp_planilha.campo ( 'BASE_ISENTA' )
                                                          || --
                                                            dsp_planilha.campo ( 'BASE_OUTRAS' )
                                                          || --
                                                            dsp_planilha.campo ( 'BASE_ICMS_ST' )
                                                          || --
                                                            dsp_planilha.campo ( 'ICMS_ST' )
                                          , p_class => 'h'
                       )
                     , ptipo => i );

        FOR cr_r IN ( SELECT a.empresa
                           , a.estabelecimento
                           , a.uf
                           , a.data_fiscal
                           , a.num_nf
                           , a.id_people
                           , a.chave_de_acesso
                           , a.situacao_nf
                           , a.cod_fornecedor
                           , a.cpf_cgc
                           , a.razao_social
                           , a.fin
                           , a.cfop
                           , a.cst_a
                           , a.cst_b
                           , a.vlr_contabil
                           , a.base_icms
                           , a.icms
                           , a.base_isenta
                           , a.base_outras
                           , a.base_icms_st
                           , a.icms_st
                        FROM msafi.dpsp_fin275_dev_merc_st a
                           , msafi.dpsp_fin275_tab_filial filial_orig
                       WHERE 1 = 1
                         AND filial_orig.cod_empresa = mcod_empresa
                         AND a.empresa = mcod_empresa
                         AND filial_orig.cod_empresa = a.empresa
                         AND filial_orig.cod_estab = a.estabelecimento
                         AND filial_orig.proc_id = mproc_id
                         AND a.cd_destino = pcod_estab
                         AND a.data_fiscal BETWEEN pdt_ini AND pdt_fim ) LOOP
            IF v_class = 'a' THEN
                v_class := 'b';
            ELSE
                v_class := 'a';
            END IF;

            v_text01 :=
                dsp_planilha.linha (
                                     p_conteudo =>    dsp_planilha.campo ( cr_r.empresa )
                                                   || --
                                                     dsp_planilha.campo ( cr_r.estabelecimento )
                                                   || --
                                                     dsp_planilha.campo ( cr_r.uf )
                                                   || --
                                                     dsp_planilha.campo ( cr_r.data_fiscal )
                                                   || --
                                                     dsp_planilha.campo ( cr_r.num_nf )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( cr_r.id_people ) )
                                                   || dsp_planilha.campo (
                                                                           dsp_planilha.texto ( cr_r.chave_de_acesso )
                                                      )
                                                   || dsp_planilha.campo ( cr_r.situacao_nf )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( cr_r.cod_fornecedor ) )
                                                   || dsp_planilha.campo ( dsp_planilha.texto ( cr_r.cpf_cgc ) )
                                                   || dsp_planilha.campo ( cr_r.razao_social )
                                                   || --
                                                     dsp_planilha.campo ( cr_r.fin )
                                                   || --
                                                     dsp_planilha.campo ( cr_r.cfop )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( cr_r.cst_a ) )
                                                   || dsp_planilha.campo ( dsp_planilha.texto ( cr_r.cst_b ) )
                                                   || dsp_planilha.campo ( cr_r.vlr_contabil )
                                                   || --
                                                     dsp_planilha.campo ( cr_r.base_icms )
                                                   || --
                                                     dsp_planilha.campo ( cr_r.icms )
                                                   || --
                                                     dsp_planilha.campo ( cr_r.base_isenta )
                                                   || --
                                                     dsp_planilha.campo ( cr_r.base_outras )
                                                   || --
                                                     dsp_planilha.campo ( cr_r.base_icms_st )
                                                   || --
                                                     dsp_planilha.campo ( cr_r.icms_st )
                                   , p_class => v_class
                );
            lib_proc.add ( v_text01
                         , ptipo => i );
        END LOOP;

        lib_proc.add ( dsp_planilha.tabela_fim
                     , ptipo => i );
    END;

    PROCEDURE arquivo_sintetico ( pcod_estab VARCHAR2
                                , pdt_ini DATE
                                , pdt_fim DATE
                                , v_cd_arquivo INTEGER )
    IS
        i INTEGER := v_cd_arquivo;
        --Variaveis genericas
        v_text01 VARCHAR2 ( 6000 );
        v_sep VARCHAR2 ( 1 ) := CHR ( 9 );
        v_class VARCHAR2 ( 1 ) := 'a';
    BEGIN
        --Arquivo Analitico
        lib_proc.add_tipo ( mproc_id
                          , i
                          ,    pcod_estab
                            || '_'
                            || TO_CHAR ( pdt_ini
                                       , 'YYYYMM' )
                            || '_Devolucao_Merc_ST_Sintetico.xls'
                          , 2 );

        lib_proc.add ( dsp_planilha.header
                     , ptipo => i );
        lib_proc.add ( dsp_planilha.tabela_inicio
                     , ptipo => i );

        lib_proc.add ( dsp_planilha.linha (
                                            p_conteudo =>    dsp_planilha.campo ( 'EMPRESA' )
                                                          || --
                                                            dsp_planilha.campo ( 'ESTABELECIMENTO' )
                                                          || --
                                                            dsp_planilha.campo ( 'UF' )
                                                          || --
                                                            dsp_planilha.campo ( 'TOTAL_ICMS_ESTORNO' )
                                          , p_class => 'h'
                       )
                     , ptipo => i );

        FOR cr_r IN ( SELECT   a.empresa
                             , a.estabelecimento
                             , a.uf
                             , SUM ( a.icms ) AS total_icms_estorno
                          FROM msafi.dpsp_fin275_dev_merc_st a
                             , msafi.dpsp_fin275_tab_filial filial_orig
                         WHERE 1 = 1
                           AND filial_orig.cod_empresa = mcod_empresa
                           AND a.empresa = mcod_empresa
                           AND filial_orig.cod_empresa = a.empresa
                           AND filial_orig.cod_estab = a.estabelecimento
                           AND filial_orig.proc_id = mproc_id
                           AND a.cd_destino = pcod_estab
                           AND a.data_fiscal BETWEEN pdt_ini AND pdt_fim
                      GROUP BY a.empresa
                             , a.estabelecimento
                             , a.uf ) LOOP
            IF v_class = 'a' THEN
                v_class := 'b';
            ELSE
                v_class := 'a';
            END IF;

            v_text01 :=
                dsp_planilha.linha (
                                     p_conteudo =>    dsp_planilha.campo ( cr_r.empresa )
                                                   || --
                                                     dsp_planilha.campo ( cr_r.estabelecimento )
                                                   || --
                                                     dsp_planilha.campo ( cr_r.uf )
                                                   || --
                                                     dsp_planilha.campo ( cr_r.total_icms_estorno )
                                   , p_class => v_class
                );
            lib_proc.add ( v_text01
                         , ptipo => i );
        END LOOP;

        lib_proc.add ( dsp_planilha.tabela_fim
                     , ptipo => i );
    END;
END dpsp_fin275_dev_merc_st_cproc;
/
SHOW ERRORS;
