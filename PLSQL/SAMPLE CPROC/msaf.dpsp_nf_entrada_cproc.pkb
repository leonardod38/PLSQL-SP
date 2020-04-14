Prompt Package Body DPSP_NF_ENTRADA_CPROC;
--
-- DPSP_NF_ENTRADA_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_nf_entrada_cproc
IS
    mproc_id NUMBER;
    vn_linha NUMBER := 0;
    vn_pagina NUMBER := 0;
    mnm_usuario usuario_estab.cod_usuario%TYPE;
    mcod_empresa estabelecimento.cod_empresa%TYPE;
    vs_mlinha VARCHAR2 ( 4000 );

    --Tipo, Nome e Descrição do Customizado
    mnm_tipo VARCHAR2 ( 100 ) := 'Equalização';
    mnm_cproc VARCHAR2 ( 100 ) := 'Carregar Notas de Entrada';
    mds_cproc VARCHAR2 ( 100 ) := 'Processo para carregar Notas de Entrada na tabela auxiliar';

    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );
    BEGIN
        mnm_usuario := lib_parametros.recuperar ( UPPER ( 'USUARIO' ) );
        mcod_empresa := lib_parametros.recuperar ( UPPER ( 'EMPRESA' ) );

        --PPERIODO
        lib_proc.add_param ( pparam => pstr
                           , ptitulo => 'Periodo'
                           , ptipo => 'DATE'
                           , pcontrole => 'textbox'
                           , pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => 'MM/YYYY' );

        --PCOD_ESTADO
        lib_proc.add_param (
                             pparam => pstr
                           , ptitulo => 'UF'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'COMBOBOX'
                           , pmandatorio => 'S'
                           , --pdefault    => 'RJ',
                             pdefault => '%'
                           , pmascara => '#########'
                           , pvalores => 'SELECT A.COD_ESTADO, A.COD_ESTADO FROM ESTADO A UNION ALL SELECT ''%'', ''Todas as UFs'' FROM DUAL ORDER BY 1'
                           , papresenta => 'N'
        );

        --PCOD_ESTAB
        lib_proc.add_param (
                             pparam => pstr
                           , ptitulo => 'Selecionar'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'MULTISELECT'
                           , pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => NULL
                           , pvalores =>    'SELECT A.COD_ESTAB, A.COD_ESTAB || '' - '' || B.COD_ESTADO || '' - '' || A.CGC || '' - '' || INITCAP(A.BAIRRO) || '' / '' || INITCAP(A.CIDADE) FROM ESTABELECIMENTO A, ESTADO B, MSAFI.DSP_ESTABELECIMENTO C WHERE A.COD_EMPRESA  = '''
                                         || mcod_empresa
                                         || ''' AND B.IDENT_ESTADO = A.IDENT_ESTADO AND A.COD_EMPRESA = C.COD_EMPRESA(+) AND A.COD_ESTAB = C.COD_ESTAB(+) AND B.COD_ESTADO LIKE :2 ORDER BY B.COD_ESTADO, A.COD_ESTAB'
                           , papresenta => 'N'
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

    FUNCTION executar ( pperiodo DATE
                      , pcod_estado VARCHAR2
                      , pcod_estab lib_proc.vartab )
        RETURN INTEGER
    IS
        v_qtd INTEGER;
        v_validar_status INTEGER := 0;
        v_existe_origem CHAR := 'S';

        v_data_inicial DATE
            :=   TRUNC ( pperiodo )
               - (   TO_NUMBER ( TO_CHAR ( pperiodo
                                         , 'DD' ) )
                   - 1 );
        v_data_final DATE := LAST_DAY ( pperiodo );
        v_data_hora_ini VARCHAR2 ( 20 );
        p_proc_instance VARCHAR2 ( 30 );

        --PTAB_ENTRADA     VARCHAR2(50);
        v_sql VARCHAR2 ( 4000 );
        v_retorno_status VARCHAR2 ( 4000 );

        --Variaveis genericas
        v_descricao VARCHAR2 ( 4000 );
    BEGIN
        v_descricao :=
               'Periodo:'
            || TO_CHAR ( pperiodo
                       , 'mm/yyyy' );
        v_descricao := v_descricao || CHR ( 10 ) || 'Estado:';
        v_descricao :=
               v_descricao
            || REPLACE ( pcod_estado
                       , '%'
                       , 'Todos' );

        /*    FOR EST IN PCOD_ESTAB.FIRST .. PCOD_ESTAB.COUNT LOOP
            v_descricao := v_descricao||chr(10)|| PCOD_ESTAB(EST);
        END LOOP;*/

        -- Criação: Processo
        mproc_id :=
            lib_proc.new ( psp_nome => $$plsql_unit
                         , --  prows    => 48,
                           --  pcols    => 200,
                           pdescricao => v_descricao );

        --Tela DW
        lib_proc.add_tipo ( pproc_id => mproc_id
                          , ptipo => 1
                          , ptitulo =>    TO_CHAR ( SYSDATE
                                                  , 'YYYYMMDDHH24MISS' )
                                       || '_NF_Entrada'
                          , ptipo_arq => 1 );

        vn_pagina := 1;
        vn_linha := 48;

        --EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT="DD/MM/YYYY"';
        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT="YYYYMMDD"';

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
                      , v_data_inicial
                      , v_data_final
                      , pcod_estado );
        END LOOP;

        loga ( '---INI DO PROCESSAMENTO---'
             , FALSE );
        loga ( '<< PERIODO DE: ' || v_data_inicial || ' A ' || v_data_final || ' >>'
             , FALSE );

        --Permitir processo somente para um mês
        IF LAST_DAY ( v_data_inicial ) = LAST_DAY ( v_data_final ) THEN
            --=================================================================================
            -- INICIO
            --=================================================================================
            -- Um CD por Vez
            FOR v_cod_estab IN pcod_estab.FIRST .. pcod_estab.LAST LOOP
                dbms_application_info.set_module ( $$plsql_unit
                                                 , 'Estab: ' || pcod_estab ( v_cod_estab ) );

                --GERAR CHAVE PROC_ID
                SELECT ROUND ( dbms_random.VALUE ( 10000000000000
                                                 , 999999999999999 ) )
                  INTO p_proc_instance
                  FROM DUAL;

                --=================================================================================
                -- VALIDAR STATUS DE RELATÓRIOS ENCERRADOS
                --=================================================================================
                -- IGUAL À ZERO:      PARA PROCESSOS ABERTOS - AÇÃO: CARREGAR TABELA RES ST DEV FORN
                -- DIFERENTE DE ZERO: PARA PROCESSOS ENCERRADOS - AÇÃO: CONSULTAR TABELA RES ST DEV FORN
                ---------------------

                v_validar_status :=
                    msaf.dpsp_suporte_cproc_process.validar_status_rel ( mcod_empresa
                                                                       , pcod_estab ( v_cod_estab )
                                                                       , TO_NUMBER ( TO_CHAR ( v_data_inicial
                                                                                             , 'YYYYMM' ) )
                                                                       , $$plsql_unit );

                --=================================================================================
                -- CARREGAR TABELA Ressarcimento ST Devolucao Fornecedor
                --=================================================================================
                IF v_validar_status = 0 THEN
                    loga ( '>> ESTAB: ' || pcod_estab ( v_cod_estab )
                         , FALSE );
                    loga ( '>> PROC INSERT ' || p_proc_instance
                         , FALSE );

                    --A carga irá executar o periodo inteiro, e depois consultar o periodo informado na tela.
                    --Exemplo: Parametrizado do dia 1 ao 10, então será carregado de 1 a 31, mas consultado de 1 a 10
                    v_qtd :=
                        carregar_nf_entrada ( v_data_inicial
                                            , v_data_final
                                            , pcod_estab ( v_cod_estab )
                                            , v_data_hora_ini );

                    --DROP_OLD_TMP(MPROC_ID);

                    ---------------------
                    -- Informar Filias que retornarem sem dados de origem / select zerado
                    ---------------------
                    IF v_qtd = 0 THEN
                        --Inserir status como Aberto pois não há origem
                        msaf.dpsp_suporte_cproc_process.inserir_status_rel ( mcod_empresa
                                                                           , pcod_estab ( v_cod_estab )
                                                                           , TO_NUMBER ( TO_CHAR ( v_data_inicial
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

                        lib_proc.add ( 'Estab ' || pcod_estab ( v_cod_estab ) || ' sem dados na origem.' );

                        lib_proc.add ( ' ' );
                        loga ( '---ESTAB ' || pcod_estab ( v_cod_estab ) || ' - SEM DADOS DE ORIGEM---'
                             , FALSE );

                        v_existe_origem := 'N';
                    ELSE
                        ---------------------
                        --Encerrar periodo caso não seja o mês atual e existam registros na origem
                        ---------------------
                        IF LAST_DAY ( v_data_inicial ) < LAST_DAY ( SYSDATE )
                       AND LAST_DAY ( v_data_inicial ) + 5 <= TRUNC ( SYSDATE ) THEN
                            msaf.dpsp_suporte_cproc_process.inserir_status_rel ( mcod_empresa
                                                                               , pcod_estab ( v_cod_estab )
                                                                               , TO_NUMBER ( TO_CHAR ( v_data_inicial
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
                            lib_proc.add ( 'Estab ' || pcod_estab ( v_cod_estab ) || ' - Período Encerrado' );

                            v_retorno_status :=
                                msaf.dpsp_suporte_cproc_process.retornar_status_rel (
                                                                                      mcod_empresa
                                                                                    , pcod_estab ( v_cod_estab )
                                                                                    , TO_NUMBER (
                                                                                                  TO_CHAR (
                                                                                                            v_data_inicial
                                                                                                          , 'YYYYMM'
                                                                                                  )
                                                                                      )
                                                                                    , $$plsql_unit
                                );
                            lib_proc.add ( 'Data de Encerramento: ' || v_retorno_status );

                            lib_proc.add ( ' ' );
                            loga (
                                      '---ESTAB '
                                   || pcod_estab ( v_cod_estab )
                                   || ' - PERIODO ENCERRADO: '
                                   || v_retorno_status
                                   || '---'
                                 , FALSE
                            );
                        ELSE
                            msaf.dpsp_suporte_cproc_process.inserir_status_rel ( mcod_empresa
                                                                               , pcod_estab ( v_cod_estab )
                                                                               , TO_NUMBER ( TO_CHAR ( v_data_inicial
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

                            lib_proc.add ( 'ESTAB ' || pcod_estab ( v_cod_estab ) || ' - PERIODO EM ABERTO,'
                                         , 1 );
                            lib_proc.add ( 'Os registros gerados são temporários.'
                                         , 1 );

                            lib_proc.add ( ' '
                                         , 1 );
                            loga ( '---ESTAB ' || pcod_estab ( v_cod_estab ) || ' - PERIODO EM ABERTO---'
                                 , FALSE );
                        END IF;
                    END IF;
                --PERIODO JÁ ENCERRADO
                ELSE
                    lib_proc.add ( 'Estab ' || pcod_estab ( v_cod_estab ) || ' - Período já processado e encerrado' );

                    v_retorno_status :=
                        msaf.dpsp_suporte_cproc_process.retornar_status_rel ( mcod_empresa
                                                                            , pcod_estab ( v_cod_estab )
                                                                            , TO_NUMBER ( TO_CHAR ( v_data_inicial
                                                                                                  , 'YYYYMM' ) )
                                                                            , $$plsql_unit );
                    lib_proc.add ( 'Data de Encerramento: ' || v_retorno_status );

                    lib_proc.add ( ' ' );
                    loga (
                              '---ESTAB '
                           || pcod_estab ( v_cod_estab )
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
                lib_proc.add ( 'Há estabelecimentos sem dados de origem.' );
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

            v_txt_email := 'ERRO no ' || mnm_cproc || '!';
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
            v_assunto := 'Mastersaf - ' || mnm_cproc || ' apresentou ERRO';
            notifica ( ''
                     , 'S'
                     , v_assunto
                     , v_txt_email
                     , $$plsql_unit );
        ELSE
            v_txt_email := 'Processo ' || mnm_cproc || ' com SUCESSO.';
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
            v_assunto := 'Mastersaf - ' || mnm_cproc || ' Concluído';
            notifica ( 'S'
                     , ''
                     , v_assunto
                     , v_txt_email
                     , $$plsql_unit );
        END IF;
    END;

    PROCEDURE cabecalho ( pnm_empresa VARCHAR2
                        , pcnpj VARCHAR2
                        , v_data_hora_ini VARCHAR2
                        , mnm_cproc VARCHAR2
                        , v_data_inicial DATE
                        , v_data_final DATE
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
        vs_mlinha := 'Data Inicial: ' || v_data_inicial;
        lib_proc.add ( vs_mlinha
                     , NULL
                     , NULL
                     , 1 );

        vs_mlinha := NULL;
        vs_mlinha := 'Data Final: ' || v_data_final;
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
            || TO_CHAR ( v_data_inicial
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

    FUNCTION carregar_nf_entrada ( v_data_inicial DATE
                                 , v_data_final DATE
                                 , pcod_estab VARCHAR2
                                 , v_data_hora_ini VARCHAR2 )
        RETURN INTEGER
    IS
        v_sql VARCHAR2 ( 10000 );
        v_qtde_delete INTEGER;
        v_dt_inclusao DATE := SYSDATE;

        cc_limit NUMBER ( 7 ) := 10000;
        vn_count_new NUMBER := 0;

        -- =======================================
        -- VARIÁVEIS DO CURSOR
        -- =======================================
        TYPE typ_cod_empresa IS TABLE OF msafi.dpsp_nf_entrada.cod_empresa%TYPE
            INDEX BY PLS_INTEGER;

        TYPE typ_cod_estab IS TABLE OF msafi.dpsp_nf_entrada.cod_estab%TYPE
            INDEX BY PLS_INTEGER;

        TYPE typ_data_fiscal IS TABLE OF msafi.dpsp_nf_entrada.data_fiscal%TYPE
            INDEX BY PLS_INTEGER;

        TYPE typ_movto_e_s IS TABLE OF msafi.dpsp_nf_entrada.movto_e_s%TYPE
            INDEX BY PLS_INTEGER;

        TYPE typ_norm_dev IS TABLE OF msafi.dpsp_nf_entrada.norm_dev%TYPE
            INDEX BY PLS_INTEGER;

        TYPE typ_ident_docto IS TABLE OF msafi.dpsp_nf_entrada.ident_docto%TYPE
            INDEX BY PLS_INTEGER;

        TYPE typ_ident_fis_jur IS TABLE OF msafi.dpsp_nf_entrada.ident_fis_jur%TYPE
            INDEX BY PLS_INTEGER;

        TYPE typ_num_docfis IS TABLE OF msafi.dpsp_nf_entrada.num_docfis%TYPE
            INDEX BY PLS_INTEGER;

        TYPE typ_serie_docfis IS TABLE OF msafi.dpsp_nf_entrada.serie_docfis%TYPE
            INDEX BY PLS_INTEGER;

        TYPE typ_sub_serie_docfis IS TABLE OF msafi.dpsp_nf_entrada.sub_serie_docfis%TYPE
            INDEX BY PLS_INTEGER;

        TYPE typ_discri_item IS TABLE OF msafi.dpsp_nf_entrada.discri_item%TYPE
            INDEX BY PLS_INTEGER;

        TYPE typ_num_item IS TABLE OF msafi.dpsp_nf_entrada.num_item%TYPE
            INDEX BY PLS_INTEGER;

        TYPE typ_cod_fis_jur IS TABLE OF msafi.dpsp_nf_entrada.cod_fis_jur%TYPE
            INDEX BY PLS_INTEGER;

        TYPE typ_cpf_cgc IS TABLE OF msafi.dpsp_nf_entrada.cpf_cgc%TYPE
            INDEX BY PLS_INTEGER;

        TYPE typ_cod_nbm IS TABLE OF msafi.dpsp_nf_entrada.cod_nbm%TYPE
            INDEX BY PLS_INTEGER;

        TYPE typ_cod_cfo IS TABLE OF msafi.dpsp_nf_entrada.cod_cfo%TYPE
            INDEX BY PLS_INTEGER;

        TYPE typ_cod_natureza_op IS TABLE OF msafi.dpsp_nf_entrada.cod_natureza_op%TYPE
            INDEX BY PLS_INTEGER;

        TYPE typ_cod_produto IS TABLE OF msafi.dpsp_nf_entrada.cod_produto%TYPE
            INDEX BY PLS_INTEGER;

        TYPE typ_vlr_contab_item IS TABLE OF msafi.dpsp_nf_entrada.vlr_contab_item%TYPE
            INDEX BY PLS_INTEGER;

        TYPE typ_quantidade IS TABLE OF msafi.dpsp_nf_entrada.quantidade%TYPE
            INDEX BY PLS_INTEGER;

        TYPE typ_vlr_unit IS TABLE OF msafi.dpsp_nf_entrada.vlr_unit%TYPE
            INDEX BY PLS_INTEGER;

        TYPE typ_vlr_icmss_n_escrit IS TABLE OF msafi.dpsp_nf_entrada.vlr_icmss_n_escrit%TYPE
            INDEX BY PLS_INTEGER;

        TYPE typ_cod_situacao_b IS TABLE OF msafi.dpsp_nf_entrada.cod_situacao_b%TYPE
            INDEX BY PLS_INTEGER;

        TYPE typ_data_emissao IS TABLE OF msafi.dpsp_nf_entrada.data_emissao%TYPE
            INDEX BY PLS_INTEGER;

        TYPE typ_cod_estado IS TABLE OF msafi.dpsp_nf_entrada.cod_estado%TYPE
            INDEX BY PLS_INTEGER;

        TYPE typ_num_controle_docto IS TABLE OF msafi.dpsp_nf_entrada.num_controle_docto%TYPE
            INDEX BY PLS_INTEGER;

        TYPE typ_num_autentic_nfe IS TABLE OF msafi.dpsp_nf_entrada.num_autentic_nfe%TYPE
            INDEX BY PLS_INTEGER;

        TYPE typ_vlr_base_icms IS TABLE OF msafi.dpsp_nf_entrada.vlr_base_icms%TYPE
            INDEX BY PLS_INTEGER;

        TYPE typ_vlr_icms IS TABLE OF msafi.dpsp_nf_entrada.vlr_icms%TYPE
            INDEX BY PLS_INTEGER;

        TYPE typ_vlr_base_icmss IS TABLE OF msafi.dpsp_nf_entrada.vlr_base_icmss%TYPE
            INDEX BY PLS_INTEGER;

        TYPE typ_vlr_icmss IS TABLE OF msafi.dpsp_nf_entrada.vlr_icmss%TYPE
            INDEX BY PLS_INTEGER;

        TYPE typ_vlr_item IS TABLE OF msafi.dpsp_nf_entrada.vlr_item%TYPE
            INDEX BY PLS_INTEGER;

        TYPE typ_vlr_outras IS TABLE OF msafi.dpsp_nf_entrada.vlr_outras%TYPE
            INDEX BY PLS_INTEGER;

        TYPE typ_vlr_desconto IS TABLE OF msafi.dpsp_nf_entrada.vlr_desconto%TYPE
            INDEX BY PLS_INTEGER;

        TYPE typ_cst_pis IS TABLE OF msafi.dpsp_nf_entrada.cst_pis%TYPE
            INDEX BY PLS_INTEGER;

        TYPE typ_vlr_base_pis IS TABLE OF msafi.dpsp_nf_entrada.vlr_base_pis%TYPE
            INDEX BY PLS_INTEGER;

        TYPE typ_vlr_aliq_pis IS TABLE OF msafi.dpsp_nf_entrada.vlr_aliq_pis%TYPE
            INDEX BY PLS_INTEGER;

        TYPE typ_vlr_pis IS TABLE OF msafi.dpsp_nf_entrada.vlr_pis%TYPE
            INDEX BY PLS_INTEGER;

        TYPE typ_cst_cofins IS TABLE OF msafi.dpsp_nf_entrada.cst_cofins%TYPE
            INDEX BY PLS_INTEGER;

        TYPE typ_vlr_base_cofins IS TABLE OF msafi.dpsp_nf_entrada.vlr_base_cofins%TYPE
            INDEX BY PLS_INTEGER;

        TYPE typ_vlr_aliq_cofins IS TABLE OF msafi.dpsp_nf_entrada.vlr_aliq_cofins%TYPE
            INDEX BY PLS_INTEGER;

        TYPE typ_vlr_cofins IS TABLE OF msafi.dpsp_nf_entrada.vlr_cofins%TYPE
            INDEX BY PLS_INTEGER;

        TYPE typ_situacao IS TABLE OF msafi.dpsp_nf_entrada.situacao%TYPE
            INDEX BY PLS_INTEGER;

        TYPE typ_vlr_icmss_ndestac IS TABLE OF msafi.dpsp_nf_entrada.vlr_icmss_ndestac%TYPE
            INDEX BY PLS_INTEGER;

        v_cod_empresa typ_cod_empresa;
        v_cod_estab typ_cod_estab;
        v_data_fiscal typ_data_fiscal;
        v_movto_e_s typ_movto_e_s;
        v_norm_dev typ_norm_dev;
        v_ident_docto typ_ident_docto;
        v_ident_fis_jur typ_ident_fis_jur;
        v_num_docfis typ_num_docfis;
        v_serie_docfis typ_serie_docfis;
        v_sub_serie_docfis typ_sub_serie_docfis;
        v_discri_item typ_discri_item;
        v_num_item typ_num_item;
        v_cod_fis_jur typ_cod_fis_jur;
        v_cpf_cgc typ_cpf_cgc;
        v_cod_nbm typ_cod_nbm;
        v_cod_cfo typ_cod_cfo;
        v_cod_natureza_op typ_cod_natureza_op;
        v_cod_produto typ_cod_produto;
        v_vlr_contab_item typ_vlr_contab_item;
        v_quantidade typ_quantidade;
        v_vlr_unit typ_vlr_unit;
        v_vlr_icmss_n_escrit typ_vlr_icmss_n_escrit;
        v_cod_situacao_b typ_cod_situacao_b;
        v_data_emissao typ_data_emissao;
        v_cod_estado typ_cod_estado;
        v_num_controle_docto typ_num_controle_docto;
        v_num_autentic_nfe typ_num_autentic_nfe;
        v_vlr_base_icms typ_vlr_base_icms;
        v_vlr_icms typ_vlr_icms;
        v_vlr_base_icmss typ_vlr_base_icmss;
        v_vlr_icmss typ_vlr_icmss;
        v_vlr_item typ_vlr_item;
        v_vlr_outras typ_vlr_outras;
        v_vlr_desconto typ_vlr_desconto;
        v_cst_pis typ_cst_pis;
        v_vlr_base_pis typ_vlr_base_pis;
        v_vlr_aliq_pis typ_vlr_aliq_pis;
        v_vlr_pis typ_vlr_pis;
        v_cst_cofins typ_cst_cofins;
        v_vlr_base_cofins typ_vlr_base_cofins;
        v_vlr_aliq_cofins typ_vlr_aliq_cofins;
        v_vlr_cofins typ_vlr_cofins;
        v_situacao typ_situacao;
        v_vlr_icmss_ndestac typ_vlr_icmss_ndestac;

        -- =======================================
        -- CURSORS DECLARATION
        -- =======================================

        CURSOR cur_s_ext ( data_normal DATE )
        IS
            SELECT   x08.cod_empresa
                   , x08.cod_estab
                   , x08.data_fiscal
                   , x08.movto_e_s
                   , x08.norm_dev
                   , x08.ident_docto
                   , x08.ident_fis_jur
                   , x08.num_docfis
                   , x08.serie_docfis
                   , x08.sub_serie_docfis
                   , x08.discri_item
                   , x08.num_item
                   , g.cod_fis_jur
                   , g.cpf_cgc
                   , a.cod_nbm
                   , b.cod_cfo
                   , c.cod_natureza_op
                   , d.cod_produto
                   , x08.vlr_contab_item
                   , x08.quantidade
                   , x08.vlr_unit
                   , x08.vlr_icmss_n_escrit
                   , e.cod_situacao_b
                   , x07.data_emissao
                   , h.cod_estado
                   , x07.num_controle_docto
                   , x07.num_autentic_nfe AS num_autentic_nfe
                   , NVL ( ( SELECT vlr_base
                               FROM x08_base_merc it
                              WHERE x08.cod_empresa = it.cod_empresa
                                AND x08.cod_estab = it.cod_estab
                                AND x08.data_fiscal = it.data_fiscal
                                AND x08.movto_e_s = it.movto_e_s
                                AND x08.norm_dev = it.norm_dev
                                AND x08.ident_docto = it.ident_docto
                                AND x08.ident_fis_jur = it.ident_fis_jur
                                AND x08.num_docfis = it.num_docfis
                                AND x08.serie_docfis = it.serie_docfis
                                AND x08.sub_serie_docfis = it.sub_serie_docfis
                                AND x08.discri_item = it.discri_item
                                AND it.cod_tributo = 'ICMS'
                                AND it.cod_tributacao = '1' )
                         , 0 )
                         vlr_base_icms
                   , ( SELECT vlr_tributo
                         FROM x08_trib_merc it
                        WHERE x08.cod_empresa = it.cod_empresa
                          AND x08.cod_estab = it.cod_estab
                          AND x08.data_fiscal = it.data_fiscal
                          AND x08.movto_e_s = it.movto_e_s
                          AND x08.norm_dev = it.norm_dev
                          AND x08.ident_docto = it.ident_docto
                          AND x08.ident_fis_jur = it.ident_fis_jur
                          AND x08.num_docfis = it.num_docfis
                          AND x08.serie_docfis = it.serie_docfis
                          AND x08.sub_serie_docfis = it.sub_serie_docfis
                          AND x08.discri_item = it.discri_item
                          AND it.cod_tributo = 'ICMS' )
                         vlr_icms
                   , NVL ( ( SELECT vlr_base
                               FROM x08_base_merc it
                              WHERE x08.cod_empresa = it.cod_empresa
                                AND x08.cod_estab = it.cod_estab
                                AND x08.data_fiscal = it.data_fiscal
                                AND x08.movto_e_s = it.movto_e_s
                                AND x08.norm_dev = it.norm_dev
                                AND x08.ident_docto = it.ident_docto
                                AND x08.ident_fis_jur = it.ident_fis_jur
                                AND x08.num_docfis = it.num_docfis
                                AND x08.serie_docfis = it.serie_docfis
                                AND x08.sub_serie_docfis = it.sub_serie_docfis
                                AND x08.discri_item = it.discri_item
                                AND it.cod_tributo = 'ICMS-S'
                                AND it.cod_tributacao = '1' )
                         , 0 )
                         vlr_base_icmss
                   , ( SELECT vlr_tributo
                         FROM x08_trib_merc it
                        WHERE x08.cod_empresa = it.cod_empresa
                          AND x08.cod_estab = it.cod_estab
                          AND x08.data_fiscal = it.data_fiscal
                          AND x08.movto_e_s = it.movto_e_s
                          AND x08.norm_dev = it.norm_dev
                          AND x08.ident_docto = it.ident_docto
                          AND x08.ident_fis_jur = it.ident_fis_jur
                          AND x08.num_docfis = it.num_docfis
                          AND x08.serie_docfis = it.serie_docfis
                          AND x08.sub_serie_docfis = it.sub_serie_docfis
                          AND x08.discri_item = it.discri_item
                          AND it.cod_tributo = 'ICMS-S' )
                         vlr_icmss
                   , x08.vlr_item
                   , x08.vlr_outras
                   , x08.vlr_desconto
                   , x08.cod_situacao_pis cst_pis
                   , x08.vlr_base_pis
                   , x08.vlr_aliq_pis
                   , x08.vlr_pis
                   , x08.cod_situacao_cofins cst_cofins
                   , x08.vlr_base_cofins
                   , x08.vlr_aliq_cofins
                   , x08.vlr_cofins
                   , x07.situacao
                   , x08.vlr_icmss_ndestac
                FROM x08_itens_merc x08
                   , x07_docto_fiscal x07
                   , x2013_produto d
                   , x04_pessoa_fis_jur g
                   , x2043_cod_nbm a
                   , x2012_cod_fiscal b
                   , x2006_natureza_op c
                   , y2026_sit_trb_uf_b e
                   , estado h
               WHERE x08.ident_nbm = a.ident_nbm(+)
                 AND x08.ident_cfo = b.ident_cfo(+)
                 AND x08.ident_natureza_op = c.ident_natureza_op(+)
                 AND x08.ident_situacao_b = e.ident_situacao_b(+)
                 AND x08.ident_produto = d.ident_produto(+)
                 AND x07.ident_fis_jur = g.ident_fis_jur(+)
                 AND g.ident_estado = h.ident_estado(+)
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
                 AND x07.movto_e_s <> '9'
                 -- FIN9023
                 AND x07.ident_docto NOT IN ( SELECT ident_docto
                                                FROM msaf.x2005_tipo_docto
                                               WHERE cod_docto = 'NCV' )
                 --AND X07.NORM_DEV = '1'
                 --AND X07.SITUACAO = 'N'
                 AND x07.cod_empresa = mcod_empresa
                 AND x07.cod_estab = pcod_estab
                 AND x07.data_fiscal = data_normal
            ORDER BY cod_empresa
                   , cod_estab
                   , cod_produto
                   , data_fiscal DESC;
    BEGIN
        loga ( 'CARREGAR_NF_ENTRADA-INI'
             , FALSE );

        EXECUTE IMMEDIATE ( 'ALTER SESSION SET CURSOR_SHARING = FORCE' );

        -- REGISTRA O ANDAMENTO DO PROCESSO NA V$SESSION
        dbms_application_info.set_module ( $$plsql_unit
                                         , 'N:' || vn_count_new );

        v_dt_inclusao := SYSDATE;

        vn_count_new := 0;
        v_qtde_delete := 0;

        -- DELETE
        v_sql := '';
        v_sql := v_sql || ' SELECT COUNT(1) ';
        v_sql := v_sql || ' FROM MSAFI.DPSP_NF_ENTRADA PARTITION ';
        v_sql := v_sql || ' FOR(TO_DATE(''';
        v_sql :=
               v_sql
            || TO_CHAR ( v_data_final
                       , 'YYYYMMDD' );
        v_sql := v_sql || ''',''YYYYMMDD'')) ';
        v_sql := v_sql || ' WHERE COD_ESTAB = ''';
        v_sql := v_sql || pcod_estab || '''';

        BEGIN
            EXECUTE IMMEDIATE ( v_sql )            INTO v_qtde_delete;
        EXCEPTION
            WHEN OTHERS THEN
                loga ( 'V_SQL [1]:' || v_sql
                     , FALSE );
                loga ( 'SQLERRM: ' || SQLERRM
                     , FALSE );
                --ENVIAR EMAIL DE ERRO-------------------------------------------
                envia_email ( mcod_empresa
                            , v_data_inicial
                            , v_data_final
                            , SQLERRM
                            , 'E'
                            , v_data_hora_ini );
                -----------------------------------------------------------------
                raise_application_error ( -20007
                                        , '!ERRO DELETE [1]!' );
        END;

        IF v_qtde_delete > 0 THEN
            v_sql := '';
            v_sql := v_sql || ' DELETE ';
            v_sql := v_sql || ' FROM MSAFI.DPSP_NF_ENTRADA PARTITION ';
            v_sql := v_sql || ' FOR(TO_DATE(''';
            v_sql :=
                   v_sql
                || TO_CHAR ( v_data_final
                           , 'YYYYMMDD' );
            v_sql := v_sql || ''',''YYYYMMDD'')) ';
            v_sql := v_sql || ' WHERE COD_ESTAB = ''';
            v_sql := v_sql || pcod_estab || '''';

            BEGIN
                EXECUTE IMMEDIATE ( v_sql );

                loga (
                          '::QUANTIDADE DE REGISTROS LIMPOS (MSAFI.DPSP_NF_ENTRADA) , ESTAB: '
                       || pcod_estab
                       || ' - QTDE '
                       || NVL ( v_qtde_delete, 0 )
                       || '::'
                     , FALSE
                );
            EXCEPTION
                WHEN OTHERS THEN
                    loga ( 'V_SQL [2]:' || v_sql
                         , FALSE );
                    loga ( 'SQLERRM: ' || SQLERRM
                         , FALSE );
                    --ENVIAR EMAIL DE ERRO-------------------------------------------
                    envia_email ( mcod_empresa
                                , v_data_inicial
                                , v_data_final
                                , SQLERRM
                                , 'E'
                                , v_data_hora_ini );
                    -----------------------------------------------------------------
                    raise_application_error ( -20007
                                            , '!ERRO DELETE [2]!' );
            END;
        END IF;

        --===============================================
        -- INICIO DO CURSOR
        --===============================================
        loga ( 'EXECUTANDO O FETCH...'
             , FALSE );

        FOR c_dt IN ( SELECT   b.data_fiscal AS data_normal
                          FROM (SELECT v_data_inicial + ( ROWNUM - 1 ) AS data_fiscal
                                  FROM all_objects
                                 WHERE ROWNUM <= (v_data_final - v_data_inicial + 1)) b
                      ORDER BY b.data_fiscal ) LOOP
            /* LOGA('NF ENT - ESTAB ' || PCOD_ESTAB || ' - DIA ' ||
            C_DT.DATA_NORMAL,
            FALSE);*/

            OPEN cur_s_ext ( c_dt.data_normal );

            LOOP
                FETCH cur_s_ext
                    BULK COLLECT INTO v_cod_empresa
                       , v_cod_estab
                       , v_data_fiscal
                       , v_movto_e_s
                       , v_norm_dev
                       , v_ident_docto
                       , v_ident_fis_jur
                       , v_num_docfis
                       , v_serie_docfis
                       , v_sub_serie_docfis
                       , v_discri_item
                       , v_num_item
                       , v_cod_fis_jur
                       , v_cpf_cgc
                       , v_cod_nbm
                       , v_cod_cfo
                       , v_cod_natureza_op
                       , v_cod_produto
                       , v_vlr_contab_item
                       , v_quantidade
                       , v_vlr_unit
                       , v_vlr_icmss_n_escrit
                       , v_cod_situacao_b
                       , v_data_emissao
                       , v_cod_estado
                       , v_num_controle_docto
                       , v_num_autentic_nfe
                       , v_vlr_base_icms
                       , v_vlr_icms
                       , v_vlr_base_icmss
                       , v_vlr_icmss
                       , v_vlr_item
                       , v_vlr_outras
                       , v_vlr_desconto
                       , v_cst_pis
                       , v_vlr_base_pis
                       , v_vlr_aliq_pis
                       , v_vlr_pis
                       , v_cst_cofins
                       , v_vlr_base_cofins
                       , v_vlr_aliq_cofins
                       , v_vlr_cofins
                       , v_situacao
                       , v_vlr_icmss_ndestac
                    LIMIT cc_limit;

                -- INICIA O CURSOR
                FORALL i IN v_cod_empresa.FIRST .. v_cod_empresa.LAST
                    INSERT /*+ APPEND */
                          INTO  msafi.dpsp_nf_entrada ( cod_empresa
                                                      , cod_estab
                                                      , data_fiscal
                                                      , movto_e_s
                                                      , norm_dev
                                                      , ident_docto
                                                      , ident_fis_jur
                                                      , num_docfis
                                                      , serie_docfis
                                                      , sub_serie_docfis
                                                      , discri_item
                                                      , num_item
                                                      , cod_fis_jur
                                                      , cpf_cgc
                                                      , cod_nbm
                                                      , cod_cfo
                                                      , cod_natureza_op
                                                      , cod_produto
                                                      , vlr_contab_item
                                                      , quantidade
                                                      , vlr_unit
                                                      , vlr_icmss_n_escrit
                                                      , cod_situacao_b
                                                      , data_emissao
                                                      , cod_estado
                                                      , num_controle_docto
                                                      , num_autentic_nfe
                                                      , vlr_base_icms
                                                      , vlr_icms
                                                      , vlr_base_icmss
                                                      , vlr_icmss
                                                      , vlr_item
                                                      , vlr_outras
                                                      , vlr_desconto
                                                      , cst_pis
                                                      , vlr_base_pis
                                                      , vlr_aliq_pis
                                                      , vlr_pis
                                                      , cst_cofins
                                                      , vlr_base_cofins
                                                      , vlr_aliq_cofins
                                                      , vlr_cofins
                                                      , dt_inclusao
                                                      , situacao
                                                      , vlr_icmss_ndestac )
                         VALUES ( v_cod_empresa ( i )
                                , v_cod_estab ( i )
                                , v_data_fiscal ( i )
                                , v_movto_e_s ( i )
                                , v_norm_dev ( i )
                                , v_ident_docto ( i )
                                , v_ident_fis_jur ( i )
                                , v_num_docfis ( i )
                                , v_serie_docfis ( i )
                                , v_sub_serie_docfis ( i )
                                , v_discri_item ( i )
                                , v_num_item ( i )
                                , v_cod_fis_jur ( i )
                                , v_cpf_cgc ( i )
                                , v_cod_nbm ( i )
                                , v_cod_cfo ( i )
                                , v_cod_natureza_op ( i )
                                , v_cod_produto ( i )
                                , v_vlr_contab_item ( i )
                                , v_quantidade ( i )
                                , v_vlr_unit ( i )
                                , v_vlr_icmss_n_escrit ( i )
                                , v_cod_situacao_b ( i )
                                , v_data_emissao ( i )
                                , v_cod_estado ( i )
                                , v_num_controle_docto ( i )
                                , v_num_autentic_nfe ( i )
                                , v_vlr_base_icms ( i )
                                , v_vlr_icms ( i )
                                , v_vlr_base_icmss ( i )
                                , v_vlr_icmss ( i )
                                , v_vlr_item ( i )
                                , v_vlr_outras ( i )
                                , v_vlr_desconto ( i )
                                , v_cst_pis ( i )
                                , v_vlr_base_pis ( i )
                                , v_vlr_aliq_pis ( i )
                                , v_vlr_pis ( i )
                                , v_cst_cofins ( i )
                                , v_vlr_base_cofins ( i )
                                , v_vlr_aliq_cofins ( i )
                                , v_vlr_cofins ( i )
                                , v_dt_inclusao
                                , v_situacao ( i )
                                , v_vlr_icmss_ndestac ( i ) );

                vn_count_new := vn_count_new + SQL%ROWCOUNT;
                COMMIT;

                dbms_application_info.set_module ( $$plsql_unit
                                                 , pcod_estab || ' - N:' || vn_count_new );

                dbms_application_info.set_client_info ( TO_CHAR ( SYSDATE
                                                                , 'DD-MM-YYYY HH24:MI:SS' ) );

                v_cod_empresa.delete;
                v_cod_estab.delete;
                v_data_fiscal.delete;
                v_movto_e_s.delete;
                v_norm_dev.delete;
                v_ident_docto.delete;
                v_ident_fis_jur.delete;
                v_num_docfis.delete;
                v_serie_docfis.delete;
                v_sub_serie_docfis.delete;
                v_discri_item.delete;
                v_num_item.delete;
                v_cod_fis_jur.delete;
                v_cpf_cgc.delete;
                v_cod_nbm.delete;
                v_cod_cfo.delete;
                v_cod_natureza_op.delete;
                v_cod_produto.delete;
                v_vlr_contab_item.delete;
                v_quantidade.delete;
                v_vlr_unit.delete;
                v_vlr_icmss_n_escrit.delete;
                v_cod_situacao_b.delete;
                v_data_emissao.delete;
                v_cod_estado.delete;
                v_num_controle_docto.delete;
                v_num_autentic_nfe.delete;
                v_vlr_base_icms.delete;
                v_vlr_icms.delete;
                v_vlr_base_icmss.delete;
                v_vlr_icmss.delete;
                v_vlr_item.delete;
                v_vlr_outras.delete;
                v_vlr_desconto.delete;
                v_cst_pis.delete;
                v_vlr_base_pis.delete;
                v_vlr_aliq_pis.delete;
                v_vlr_pis.delete;
                v_cst_cofins.delete;
                v_vlr_base_cofins.delete;
                v_vlr_aliq_cofins.delete;
                v_vlr_cofins.delete;
                v_situacao.delete;
                v_vlr_icmss_ndestac.delete;

                EXIT WHEN cur_s_ext%NOTFOUND;
            END LOOP;

            COMMIT;

            CLOSE cur_s_ext;

            COMMIT;
        --END LOOP;

        END LOOP;

        dbms_application_info.set_module ( $$plsql_unit
                                         , pcod_estab || 'END: ' || vn_count_new );

        loga (
                  '::QUANTIDADE DE REGISTROS INSERIDOS (MSAFI.DPSP_NF_ENTRADA) , ESTAB: '
               || pcod_estab
               || ' - QTDE '
               || NVL ( vn_count_new, 0 )
               || '::'
             , FALSE
        );

        loga ( 'CARREGAR_NF_ENTRADA-FIM'
             , FALSE );

        RETURN NVL ( vn_count_new, 0 );
    END;

    PROCEDURE equalizacao_diaria
    IS
        -- Non-scalar parameters require additional processing
        pcod_estab lib_proc.vartab;
        i INTEGER := 0;
        --pperiodo    DATE := to_date('20160531', 'yyyymmdd');
        pperiodo DATE := TRUNC ( SYSDATE );
        pcod_estado VARCHAR2 ( 10 ) := '%';
        mproc_id INTEGER;
    BEGIN
        FOR c1 IN ( SELECT cod_estab
                      FROM msafi.dsp_estabelecimento ) LOOP
            i := i + 1;
            pcod_estab ( i ) := c1.cod_estab;
        END LOOP;

        lib_parametros.salvar ( UPPER ( 'USUARIO' )
                              , 'AUTOMATICO' );
        lib_parametros.salvar ( UPPER ( 'EMPRESA' )
                              , msafi.dpsp.v_empresa );

        -- Atualiza mes anterior
        pperiodo :=
            TRUNC ( SYSDATE
                  , 'MM' );

        mproc_id :=
            dpsp_nf_entrada_cproc.executar ( pperiodo => pperiodo
                                           , pcod_estado => pcod_estado
                                           , pcod_estab => pcod_estab );

        -- Atualiza mes atual
        pperiodo :=
            TRUNC ( ADD_MONTHS ( SYSDATE
                               , -1 )
                  , 'MM' );

        mproc_id :=
            dpsp_nf_entrada_cproc.executar ( pperiodo => pperiodo
                                           , pcod_estado => pcod_estado
                                           , pcod_estab => pcod_estab );
    END;
END dpsp_nf_entrada_cproc;
/
SHOW ERRORS;
