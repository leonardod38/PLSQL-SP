Prompt Package Body DPSP_FIN276_RES_ST_DEV_CPROC;
--
-- DPSP_FIN276_RES_ST_DEV_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_fin276_res_st_dev_cproc
IS
    mproc_id NUMBER;
    vn_linha NUMBER := 0;
    vn_pagina NUMBER := 0;
    mnm_usuario usuario_estab.cod_usuario%TYPE;
    mcod_empresa estabelecimento.cod_empresa%TYPE;
    vs_mlinha VARCHAR2 ( 4000 );

    --Tipo, Nome e Descrição do Customizado
    mnm_tipo VARCHAR2 ( 100 ) := 'Ressarcimento';
    mnm_cproc VARCHAR2 ( 100 ) := 'Relatório de Ressarcimento ICMS-ST sobre Devolução de Fornecedores';
    mds_cproc VARCHAR2 ( 100 ) := 'Emitir Relatório de Ressarcimento ICMS-ST sobre Devolução de Fornecedores';

    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );
    BEGIN
        mnm_usuario := lib_parametros.recuperar ( UPPER ( 'USUARIO' ) );
        mcod_empresa := lib_parametros.recuperar ( UPPER ( 'EMPRESA' ) );

        --PDT_INI
        lib_proc.add_param ( pparam => pstr
                           , ptitulo => 'Data Inicial'
                           , ptipo => 'DATE'
                           , pcontrole => 'textbox'
                           , pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => 'DD/MM/YYYY' );

        --PDT_FIM
        lib_proc.add_param ( pparam => pstr
                           , ptitulo => 'Data Final'
                           , ptipo => 'DATE'
                           , pcontrole => 'textbox'
                           , pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => 'DD/MM/YYYY' );
        --PCOD_ESTADO
        lib_proc.add_param (
                             pstr
                           , 'UF'
                           , 'VARCHAR2'
                           , 'COMBOBOX'
                           , 'S'
                           , '%'
                           , '#########'
                           , 'SELECT A.COD_ESTADO, A.COD_ESTADO FROM ESTADO A UNION ALL SELECT ''%'', ''Todas as UFs'' FROM DUAL ORDER BY 1'
        );
        --PCOD_ESTAB
        lib_proc.add_param (
                             pstr
                           , 'Estabelecimentos'
                           , 'VARCHAR2'
                           , 'MULTISELECT'
                           , 'S'
                           , NULL
                           , NULL
                           ,    'SELECT A.COD_ESTAB, A.COD_ESTAB || '' - '' || B.COD_ESTADO || '' - '' || A.CGC || '' - '' || INITCAP(A.BAIRRO) || '' / '' || INITCAP(A.CIDADE) FROM ESTABELECIMENTO A, ESTADO B, MSAFI.DSP_ESTABELECIMENTO C WHERE A.COD_EMPRESA  = '''
                             || mcod_empresa
                             || ''' AND B.IDENT_ESTADO = A.IDENT_ESTADO AND A.COD_EMPRESA = C.COD_EMPRESA AND A.COD_ESTAB = C.COD_ESTAB AND B.COD_ESTADO LIKE :3 ORDER BY B.COD_ESTADO, A.COD_ESTAB'
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
                      , pcod_estado VARCHAR2
                      , pcod_estab lib_proc.vartab )
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
    BEGIN
        -- Criação: Processo
        mproc_id :=
            lib_proc.new ( psp_nome => 'DPSP_FIN276_RES_ST_DEV_CPROC'
                         , prows => 48
                         , pcols => 200 );

        --Tela DW
        lib_proc.add_tipo ( pproc_id => mproc_id
                          , ptipo => 1
                          , ptitulo =>    TO_CHAR ( SYSDATE
                                                  , 'YYYYMMDDHH24MISS' )
                                       || '_Ressarc_ST_Dev_Forn'
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
                      , pcod_estado );
        END LOOP;

        loga ( '---INI DO PROCESSAMENTO---'
             , FALSE );
        loga ( '<< PERIODO DE: ' || v_data_inicial || ' A ' || v_data_final || ' >>'
             , FALSE );

        --Permitir processo somente para um mês
        IF LAST_DAY ( pdt_ini ) = LAST_DAY ( pdt_fim ) THEN
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
                                                                       , TO_NUMBER ( TO_CHAR ( pdt_ini
                                                                                             , 'YYYYMM' ) )
                                                                       , $$plsql_unit );

                --=================================================================================
                -- CARREGAR TABELA Ressarcimento ST Devolucao Fornecedor
                --=================================================================================
                IF v_validar_status = 0 THEN
                    loga ( '>> INICIO CD: ' || pcod_estab ( v_cod_estab ) || ' PROC INSERT ' || p_proc_instance
                         , FALSE );

                    ---------------------
                    -- LIMPEZA
                    ---------------------
                    --LIMPAR COM MAIS DE 3 DIAS
                    DELETE FROM msafi.dpsp_fin276_temp_prod
                          WHERE cod_empresa = mcod_empresa
                            AND cod_estab_ent = pcod_estab ( v_cod_estab )
                            AND data_fiscal BETWEEN v_data_inicial AND v_data_final;

                    DELETE FROM msafi.dpsp_fin276_res_st_dev_forn
                          WHERE empresa = mcod_empresa
                            AND estabelecimento = pcod_estab ( v_cod_estab )
                            AND data_emissao BETWEEN v_data_inicial AND v_data_final;

                    loga (
                              '::LIMPEZA DOS REGISTROS ANTERIORES (DPSP_FIN276_RES_ST_DEV_FORN), ESTAB: '
                           || pcod_estab ( v_cod_estab )
                           || ' - QTDE '
                           || SQL%ROWCOUNT
                           || '::'
                         , FALSE
                    );

                    COMMIT;

                    --A carga irá executar o periodo inteiro, e depois consultar o periodo informado na tela.
                    --Exemplo: Parametrizado do dia 1 ao 10, então será carregado de 1 a 31, mas consultado de 1 a 10
                    v_qtd :=
                        carregar_res_st_dev ( v_data_inicial
                                            , v_data_final
                                            , pcod_estab ( v_cod_estab )
                                            , v_data_hora_ini );

                    -- Carregar Temporaria de Produtos
                    carregar_temp_prod ( v_data_inicial
                                       , v_data_final
                                       , pcod_estab ( v_cod_estab )
                                       , v_data_hora_ini );


                    --Ultima Entrada para Valor Contabil
                    dbms_application_info.set_module ( $$plsql_unit
                                                     , 'Ultima Entrada - Estab: ' || pcod_estab ( v_cod_estab ) );

                    /* MSAFI.DPSP_FIN276_TAB_UTL_ENTRADA(MPROC_ID,
                                                       PCOD_ESTAB(V_COD_ESTAB),
                                                       PTAB_ENTRADA,
                                                       'DPSP_FIN276_TEMP_PROD');*/

                    --SAVE_TMP_CONTROL(MPROC_ID, PTAB_ENTRADA);

                    /* V_SQL := V_SQL || ' UPDATE MSAFI.DPSP_FIN276_RES_ST_DEV_FORN A ';
                     V_SQL := V_SQL || ' SET A.VLR_CONTABIL_ENT = (SELECT DISTINCT round(NVL(MAX(B.VLR_CONTAB_ITEM / QUANTIDADE) ';
                     V_SQL := V_SQL || '               KEEP(DENSE_RANK LAST ORDER BY ';
                     V_SQL := V_SQL || '                           B.DATA_FISCAL DESC, ' ;
                     V_SQL := V_SQL || '                               B.ROWID), ';
                     V_SQL := V_SQL || '                          0),2) DATA_FISCAL ';
                     V_SQL := V_SQL || '       FROM MSAFI.' || PTAB_ENTRADA || ' B ';
                     V_SQL := V_SQL || '       WHERE B.COD_EMPRESA = A.EMPRESA ';
                     V_SQL := V_SQL || '         AND B.COD_ESTAB = A.ESTABELECIMENTO ';
                     V_SQL := V_SQL || '     AND B.COD_PRODUTO = A.COD_PRD) ';
                     V_SQL := V_SQL || '  WHERE A.EMPRESA = ''' || MCOD_EMPRESA || '''';
                     V_SQL := V_SQL || '  AND A.ESTABELECIMENTO = '''||PCOD_ESTAB(V_COD_ESTAB)||'''' ;
                     V_SQL := V_SQL || '  AND A.DATA_EMISSAO BETWEEN TO_DATE(''' ||  TO_CHAR(V_DATA_INICIAL,'DD/MM/YYYY') || ''',''DD/MM/YYYY'')' ;
                     V_SQL := V_SQL || '  AND TO_DATE(''' ||  TO_CHAR(V_DATA_FINAL,'DD/MM/YYYY') || ''',''DD/MM/YYYY'')';

                      --Para testes:
                     --LIB_PROC.ADD_LOG(V_SQL,1);

                     EXECUTE IMMEDIATE V_SQL;*/

                    drop_old_tmp ( mproc_id );


                    ---------------------
                    -- Informar Filias que retornarem sem dados de origem / select zerado
                    ---------------------
                    IF v_qtd = 0 THEN
                        --Inserir status como Aberto pois não há origem
                        msaf.dpsp_suporte_cproc_process.inserir_status_rel ( mcod_empresa
                                                                           , pcod_estab ( v_cod_estab )
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

                        lib_proc.add ( 'Estab ' || pcod_estab ( v_cod_estab ) || ' sem dados na origem.' );

                        lib_proc.add ( ' ' );
                        loga ( '---ESTAB ' || pcod_estab ( v_cod_estab ) || ' - SEM DADOS DE ORIGEM---'
                             , FALSE );
                        --LOGA('<< SEM DADOS DE ORIGEM >>', FALSE);

                        v_existe_origem := 'N';
                    ELSE
                        ---------------------
                        --Encerrar periodo caso não seja o mês atual e existam registros na origem
                        ---------------------
                        IF LAST_DAY ( pdt_ini ) < LAST_DAY ( SYSDATE ) THEN
                            msaf.dpsp_suporte_cproc_process.inserir_status_rel ( mcod_empresa
                                                                               , pcod_estab ( v_cod_estab )
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
                            lib_proc.add ( 'Estab ' || pcod_estab ( v_cod_estab ) || ' - Período Encerrado' );

                            v_retorno_status :=
                                msaf.dpsp_suporte_cproc_process.retornar_status_rel (
                                                                                      mcod_empresa
                                                                                    , pcod_estab ( v_cod_estab )
                                                                                    , TO_NUMBER (
                                                                                                  TO_CHAR ( pdt_ini
                                                                                                          , 'YYYYMM' )
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
                                                                            , TO_NUMBER ( TO_CHAR ( pdt_ini
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
            -- GERAR ARQUIVO ANALITICO
            --=================================================================================
            lib_proc.add_tipo ( mproc_id
                              , i
                              ,    TO_CHAR ( pdt_ini
                                           , 'YYYYMM' )
                                || '_Ressarc_ST_Dev_Forn_Analitico.xls'
                              , 2 );
            lib_proc.add ( dsp_planilha.header
                         , ptipo => i );
            lib_proc.add ( dsp_planilha.tabela_inicio
                         , ptipo => i );

            lib_proc.add ( dsp_planilha.linha ( p_conteudo =>    dsp_planilha.campo ( 'SAIDAS' )
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
                                                              || --
                                                                dsp_planilha.campo ( '' )
                                                              || --
                                                                dsp_planilha.campo ( '' )
                                                              || --
                                                                dsp_planilha.campo ( '' )
                                                              || --
                                                                dsp_planilha.campo ( '' )
                                                              || --
                                                                dsp_planilha.campo ( 'ENTRADAS'
                                                                                   , p_custom => 'BGCOLOR=blue' )
                                                              || --
                                                                dsp_planilha.campo ( ''
                                                                                   , p_custom => 'BGCOLOR=blue' )
                                                              || --
                                                                dsp_planilha.campo ( ''
                                                                                   , p_custom => 'BGCOLOR=blue' )
                                                              || --
                                                                dsp_planilha.campo ( ''
                                                                                   , p_custom => 'BGCOLOR=blue' )
                                                              || --
                                                                dsp_planilha.campo ( ''
                                                                                   , p_custom => 'BGCOLOR=blue' )
                                                              || --
                                                                dsp_planilha.campo ( ''
                                                                                   , p_custom => 'BGCOLOR=blue' )
                                                              || --
                                                                dsp_planilha.campo ( ''
                                                                                   , p_custom => 'BGCOLOR=blue' )
                                                              || --
                                                                dsp_planilha.campo ( ''
                                                                                   , p_custom => 'BGCOLOR=blue' )
                                                              || --
                                                                dsp_planilha.campo ( ''
                                                                                   , p_custom => 'BGCOLOR=blue' )
                                                              || --
                                                                dsp_planilha.campo ( ''
                                                                                   , p_custom => 'BGCOLOR=blue' )
                                                              || --
                                                                dsp_planilha.campo ( ''
                                                                                   , p_custom => 'BGCOLOR=blue' )
                                                              || --
                                                                dsp_planilha.campo ( ''
                                                                                   , p_custom => 'BGCOLOR=blue' )
                                                              || --
                                                                dsp_planilha.campo ( ''
                                                                                   , p_custom => 'BGCOLOR=blue' )
                                                              || --
                                                                dsp_planilha.campo ( ''
                                                                                   , p_custom => 'BGCOLOR=blue' )
                                                              || --
                                                                dsp_planilha.campo ( ''
                                                                                   , p_custom => 'BGCOLOR=blue' )
                                                              || --
                                                                dsp_planilha.campo ( ''
                                                                                   , p_custom => 'BGCOLOR=blue' )
                                                              || --
                                                                 --DSP_PLANILHA.CAMPO('',P_CUSTOM=>'BGCOLOR=blue') || --
                                                                 --DSP_PLANILHA.CAMPO('',P_CUSTOM=>'BGCOLOR=blue') || --
                                                                 dsp_planilha.campo ( ''
                                                                                    , p_custom => 'BGCOLOR=blue' )
                                                              || --
                                                                dsp_planilha.campo ( ''
                                                                                   , p_custom => 'BGCOLOR=blue' )
                                                              || --
                                                                dsp_planilha.campo ( ''
                                                                                   , p_custom => 'BGCOLOR=blue' )
                                                              || --
                                                                 --DSP_PLANILHA.CAMPO('') || --
                                                                 -- DSP_PLANILHA.CAMPO('') || --
                                                                 dsp_planilha.campo ( 'CALCULADO'
                                                                                    , p_custom => 'BGCOLOR=green' )
                                                              || --
                                                                dsp_planilha.campo ( ''
                                                                                   , p_custom => 'BGCOLOR=green' )
                                              , p_class => 'h' )
                         , ptipo => i );

            FOR v_cod_estab IN pcod_estab.FIRST .. pcod_estab.LAST LOOP
                lib_proc.add ( dsp_planilha.linha ( p_conteudo =>    dsp_planilha.campo ( 'EMPRESA' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'UF' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'ESTABELECIMENTO' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'DATA_EMISSAO' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'NUM_NF' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'ID_PEOPLE' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'CHAVE_DE_ACESSO' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'COD_FORNECEDOR' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'CPF_CGC_FORN' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'RAZAO_SOCIAL_FORN' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'UF_FORN' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'COD_PRD' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'DESCR_PRD' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'QTDE' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'NUM_ITEM' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'VLR_UNIT' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'CFOP' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'FINALIDADE' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'SITUACAO_NF' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'CST_A' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'CST_B' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'VLR_CONTABIL_S' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'BASE_ICMS_TRIB_S' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'ICMS_TRIB_S' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'BASE_ICMS_ISENTO_S' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'ICMS_ST_S' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'ESTAB_ENT'
                                                                                       , p_custom => 'BGCOLOR=blue' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'BU_ENT'
                                                                                       , p_custom => 'BGCOLOR=blue' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'CPF_CGC_FORN_ENT'
                                                                                       , p_custom => 'BGCOLOR=blue' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'RAZAO_SOCIAL_FORN_ENT'
                                                                                       , p_custom => 'BGCOLOR=blue' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'ID_PEOPLE_ENT'
                                                                                       , p_custom => 'BGCOLOR=blue' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'NUM_NF_ENT'
                                                                                       , p_custom => 'BGCOLOR=blue' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'SERIE_ENT'
                                                                                       , p_custom => 'BGCOLOR=blue' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'NUM_ITEM_ENT'
                                                                                       , p_custom => 'BGCOLOR=blue' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'DT_NF_EMISSAO_ENT'
                                                                                       , p_custom => 'BGCOLOR=blue' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'DT_ENTRADA_PSP'
                                                                                       , p_custom => 'BGCOLOR=blue' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'VLR_CONTABIL_ENT'
                                                                                       , p_custom => 'BGCOLOR=blue' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'QTDE_NF_ENT'
                                                                                       , p_custom => 'BGCOLOR=blue' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'VLR_UNIT_ENT'
                                                                                       , p_custom => 'BGCOLOR=blue' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'BASE_ICMS_ENT'
                                                                                       , p_custom => 'BGCOLOR=blue' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'PERCT_REDU_ICMS_ENT'
                                                                                       , p_custom => 'BGCOLOR=blue' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'ALIQ_ICMS'
                                                                                       , p_custom => 'BGCOLOR=blue' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'VLR_ICMS_ENT'
                                                                                       , p_custom => 'BGCOLOR=blue' )
                                                                  || --
                                                                     --DSP_PLANILHA.CAMPO('BASE_ICMSST_ENT',P_CUSTOM=>'BGCOLOR=blue') || --
                                                                     --DSP_PLANILHA.CAMPO('VLR_ICMSST_ENT',P_CUSTOM=>'BGCOLOR=blue') || --
                                                                     dsp_planilha.campo ( 'CHAVE_ACESSO_ENT'
                                                                                        , p_custom => 'BGCOLOR=blue' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'VLR_ANTECIP_IST'
                                                                                       , p_custom => 'BGCOLOR=blue' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'VLR_ANTECIP_UNIT'
                                                                                       , p_custom => 'BGCOLOR=green' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'TOTAL_ICMS_ST_RESSARC'
                                                                                       , p_custom => 'BGCOLOR=green' ) --
                                                  -- DSP_PLANILHA.CAMPO('PERCT_REDU_ICMS_SAI') || --
                                                  --DSP_PLANILHA.CAMPO('ICMS_S_DEV')
                                                  , p_class => 'h' )
                             , ptipo => i );

                FOR cr_r IN ( SELECT empresa
                                   , uf
                                   , estabelecimento
                                   , data_emissao
                                   , num_nf
                                   , id_people
                                   , chave_de_acesso
                                   , cod_fornecedor
                                   , cpf_cgc_forn
                                   , razao_social_forn
                                   , uf_forn
                                   , cod_prd
                                   , descr_prd
                                   , qtde
                                   , num_item
                                   , vlr_unit
                                   , cfop
                                   , finalidade
                                   , situacao_nf
                                   , cst_a
                                   , cst_b
                                   , vlr_contabil_s
                                   , base_icms_trib_s
                                   , icms_trib_s
                                   , base_icms_isento_s
                                   , icms_st_s
                                   , estab_ent
                                   , bu_ent
                                   , cpf_cgc_forn_ent
                                   , razao_social_forn_ent
                                   , id_people_ent
                                   , num_nf_ent
                                   , serie_ent
                                   , num_item_ent
                                   , dt_nf_emissao_ent
                                   , dt_entrada_psp
                                   , vlr_contabil_ent
                                   , qtde_nf_ent
                                   , vlr_unit_ent
                                   , base_icms_ent
                                   , perct_redu_icms_ent
                                   , aliq_icms
                                   , vlr_icms_ent
                                   , base_icmsst_ent
                                   , vlr_icmsst_ent
                                   , chave_acesso_ent
                                   , vlr_antecip_ist
                                   , perct_redu_icms_sai
                                   , icms_s_dev
                                   , vlr_antecip_unit
                                   , total_icms_st_ressarc
                                FROM msafi.dpsp_fin276_res_st_dev_forn
                               WHERE empresa = mcod_empresa
                                 AND estabelecimento = pcod_estab ( v_cod_estab )
                                 AND data_emissao BETWEEN pdt_ini AND pdt_fim ) LOOP
                    IF v_class = 'a' THEN
                        v_class := 'b';
                    ELSE
                        v_class := 'a';
                    END IF;

                    v_text01 :=
                        dsp_planilha.linha (
                                             p_conteudo =>    dsp_planilha.campo ( cr_r.empresa )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.uf )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.estabelecimento )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.data_emissao )
                                                           || --
                                                             dsp_planilha.campo ( dsp_planilha.texto ( cr_r.num_nf ) )
                                                           || dsp_planilha.campo (
                                                                                   dsp_planilha.texto (
                                                                                                        cr_r.id_people
                                                                                   )
                                                              )
                                                           || dsp_planilha.campo (
                                                                                   dsp_planilha.texto (
                                                                                                        cr_r.chave_de_acesso
                                                                                   )
                                                              )
                                                           || dsp_planilha.campo (
                                                                                   dsp_planilha.texto (
                                                                                                        cr_r.cod_fornecedor
                                                                                   )
                                                              )
                                                           || dsp_planilha.campo (
                                                                                   dsp_planilha.texto (
                                                                                                        cr_r.cpf_cgc_forn
                                                                                   )
                                                              )
                                                           || dsp_planilha.campo ( cr_r.razao_social_forn )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.uf_forn )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.cod_prd )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.descr_prd )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.qtde )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.num_item )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.vlr_unit )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.cfop )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.finalidade )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.situacao_nf )
                                                           || --
                                                             dsp_planilha.campo ( dsp_planilha.texto ( cr_r.cst_a ) )
                                                           || dsp_planilha.campo ( dsp_planilha.texto ( cr_r.cst_b ) )
                                                           || dsp_planilha.campo ( cr_r.vlr_contabil_s )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.base_icms_trib_s )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.icms_trib_s )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.base_icms_isento_s )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.icms_st_s )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.estab_ent )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.bu_ent )
                                                           || --
                                                             dsp_planilha.campo (
                                                                                  dsp_planilha.texto (
                                                                                                       cr_r.cpf_cgc_forn_ent
                                                                                  )
                                                              )
                                                           || dsp_planilha.campo ( cr_r.razao_social_forn_ent )
                                                           || --
                                                             dsp_planilha.campo (
                                                                                  dsp_planilha.texto (
                                                                                                       cr_r.id_people_ent
                                                                                  )
                                                              )
                                                           || dsp_planilha.campo (
                                                                                   dsp_planilha.texto (
                                                                                                        cr_r.num_nf_ent
                                                                                   )
                                                              )
                                                           || dsp_planilha.campo ( cr_r.serie_ent )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.num_item_ent )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.dt_nf_emissao_ent )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.dt_entrada_psp )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.vlr_contabil_ent )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.qtde_nf_ent )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.vlr_unit_ent )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.base_icms_ent )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.perct_redu_icms_ent )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.aliq_icms )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.vlr_icms_ent )
                                                           || --
                                                              --DSP_PLANILHA.CAMPO(CR_R.BASE_ICMSST_ENT) || --
                                                              --DSP_PLANILHA.CAMPO(CR_R.VLR_ICMSST_ENT) || --
                                                              dsp_planilha.campo (
                                                                                   dsp_planilha.texto (
                                                                                                        cr_r.chave_acesso_ent
                                                                                   )
                                                              )
                                                           || dsp_planilha.campo ( cr_r.vlr_antecip_ist )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.vlr_antecip_unit )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.total_icms_st_ressarc ) --|| --
                                           --  DSP_PLANILHA.CAMPO(CR_R.PERCT_REDU_ICMS_SAI) || --
                                           -- DSP_PLANILHA.CAMPO(CR_R.ICMS_S_DEV)
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
                                || '_Ressarc_ST_Dev_Forn_Sintetico.xls'
                              , 2 );
            lib_proc.add ( dsp_planilha.header
                         , ptipo => i );
            lib_proc.add ( dsp_planilha.tabela_inicio
                         , ptipo => i );

            FOR v_cod_estab IN pcod_estab.FIRST .. pcod_estab.LAST LOOP
                lib_proc.add ( dsp_planilha.linha (
                                                    p_conteudo =>    dsp_planilha.campo ( 'EMPRESA' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'ESTABELECIMENTO' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'UF' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'PERIODO' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'TOTAL_ICMS_ST_RESSARC' )
                                                  , p_class => 'h'
                               )
                             , ptipo => i );

                FOR cr_r IN ( SELECT   uf
                                     , empresa
                                     , estabelecimento
                                     , TO_CHAR ( data_emissao
                                               , 'mm/yyyy' )
                                           periodo
                                     , SUM ( total_icms_st_ressarc ) AS total_icms_st_ressarc
                                  FROM msafi.dpsp_fin276_res_st_dev_forn
                                 WHERE empresa = mcod_empresa
                                   AND estabelecimento = pcod_estab ( v_cod_estab )
                                   AND data_emissao BETWEEN pdt_ini AND pdt_fim
                              GROUP BY uf
                                     , empresa
                                     , estabelecimento
                                     , TO_CHAR ( data_emissao
                                               , 'mm/yyyy' ) ) LOOP
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
                                                             dsp_planilha.campo (
                                                                                  dsp_planilha.texto ( cr_r.periodo )
                                                              )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.total_icms_st_ressarc )
                                           , p_class => v_class
                        );
                    lib_proc.add ( v_text01
                                 , ptipo => i );
                END LOOP;
            END LOOP;

            lib_proc.add ( dsp_planilha.tabela_fim
                         , ptipo => i );

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

    PROCEDURE save_tmp_control ( vp_proc_instance IN NUMBER
                               , vp_table_name IN VARCHAR2 )
    IS
        v_sid NUMBER;
    BEGIN
        ---> Rotina para armazenar tabelas TEMP criadas, caso programa seja
        ---  interrompido, elas serao excluidas em outros processamentos
        SELECT USERENV ( 'SID' )
          INTO v_sid
          FROM DUAL;

        ---
        INSERT /*+APPEND*/
              INTO  msafi.dpsp_msaf_tmp_control
             VALUES ( vp_proc_instance
                    , vp_table_name
                    , SYSDATE
                    , mnm_usuario
                    , v_sid );

        COMMIT;
    END;

    PROCEDURE del_tmp_control ( vp_proc_instance IN NUMBER
                              , vp_table_name IN VARCHAR2 )
    IS
    BEGIN
        DELETE msafi.dpsp_msaf_tmp_control
         WHERE proc_id = vp_proc_instance
           AND table_name = vp_table_name;

        COMMIT;
    END;

    PROCEDURE drop_old_tmp ( vp_proc_instance IN NUMBER )
    IS
        CURSOR c_old_tmp
        IS
            SELECT table_name
              FROM msafi.dpsp_msaf_tmp_control
             WHERE TRUNC ( ( ( ( 86400 * ( SYSDATE - dttm_created ) ) / 60 ) / 60 ) / 24 ) >= 2;

        l_table_name VARCHAR2 ( 30 );
    BEGIN
        ---> Dropar tabelas TMP que tiveram processo interrompido a mais de 2 dias
        OPEN c_old_tmp;

        LOOP
            FETCH c_old_tmp
                INTO l_table_name;

            BEGIN
                EXECUTE IMMEDIATE 'DROP TABLE ' || l_table_name;
            EXCEPTION
                WHEN OTHERS THEN
                    loga ( '<<TAB OLD NAO ENCONTRADA>> ' || l_table_name
                         , FALSE );
            END;

            ---
            DELETE msafi.dpsp_msaf_tmp_control
             WHERE table_name = l_table_name;

            COMMIT;

            EXIT WHEN c_old_tmp%NOTFOUND;
        END LOOP;

        COMMIT;

        CLOSE c_old_tmp;
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
                     , 'DPSP_FIN276_RES_ST_DEV_CPROC' );
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
                     , 'DPSP_FIN276_RES_ST_DEV_CPROC' );
        END IF;
    END;

    PROCEDURE cabecalho ( pnm_empresa VARCHAR2
                        , pcnpj VARCHAR2
                        , v_data_hora_ini VARCHAR2
                        , mnm_cproc VARCHAR2
                        , pdt_ini DATE
                        , pdt_fim DATE
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

    FUNCTION carregar_res_st_dev ( pdt_ini DATE
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

        CURSOR c_sped
        IS
            SELECT a.*
                 , mproc_id AS proc_id
                 , mnm_usuario AS nm_usuario
                 , v_data_hora_ini AS dt_carga
              FROM ( SELECT   --=========================
                              -- GRUPO SAÍDAS
                              --=========================
                              x07.cod_empresa AS empresa
                            , estab.cod_estado AS uf
                            , x07.cod_estab AS estabelecimento
                            , x07.data_emissao AS data_emissao
                            , x07.num_docfis AS num_nf
                            , x07.num_controle_docto AS id_people
                            , x07.num_autentic_nfe AS chave_de_acesso
                            , x04.cod_fis_jur AS cod_fornecedor
                            , x04.cpf_cgc AS cpf_cgc_forn
                            , x04.razao_social AS razao_social_forn
                            , estado.cod_estado AS uf_forn
                            , x2013.cod_produto AS cod_prd
                            , x2013.descricao AS descr_prd
                            , x08.quantidade AS qtde
                            , x08.num_item AS num_item
                            , x08.vlr_unit AS vlr_unit
                            , x2012.cod_cfo AS cfop
                            , x2006.cod_natureza_op AS finalidade
                            , x07.situacao AS situacao_nf
                            , y2025.cod_situacao_a AS cst_a
                            , y2026.cod_situacao_b AS cst_b
                            , ROUND ( ( SUM ( x08.vlr_contab_item ) / SUM ( x08.quantidade ) )
                                    , 4 )
                                  AS vlr_contabil_s
                            , ROUND ( ( SUM ( x08_base.vlr_base ) / SUM ( x08.quantidade ) )
                                    , 4 )
                                  AS base_icms_trib_s
                            , ROUND ( ( SUM ( x08_trib.vlr_tributo ) / SUM ( x08.quantidade ) )
                                    , 4 )
                                  AS icms_trib_s
                            , --
                              /*SUM((SELECT BB.VLR_BASE
                                    FROM MSAF.X08_BASE_MERC BB
                                   WHERE BB.COD_EMPRESA = X08.COD_EMPRESA
                                     AND BB.COD_ESTAB = X08.COD_ESTAB
                                     AND BB.DATA_FISCAL = X08.DATA_FISCAL
                                     AND BB.MOVTO_E_S = X08.MOVTO_E_S
                                     AND BB.NORM_DEV = X08.NORM_DEV
                                     AND BB.IDENT_DOCTO = X08.IDENT_DOCTO
                                     AND BB.IDENT_FIS_JUR = X08.IDENT_FIS_JUR
                                     AND BB.NUM_DOCFIS = X08.NUM_DOCFIS
                                     AND BB.SERIE_DOCFIS = X08.SERIE_DOCFIS
                                     AND BB.SUB_SERIE_DOCFIS = X08.SUB_SERIE_DOCFIS
                                     AND BB.DISCRI_ITEM = X08.DISCRI_ITEM
                                     AND BB.COD_TRIBUTO = 'ICMS'
                                     AND BB.COD_TRIBUTACAO = 1
                                     AND BB.COD_EMPRESA = X07.COD_EMPRESA
                                     AND BB.COD_ESTAB = X07.COD_ESTAB)) AS BASE_ICMS_TRIB_S,*/
                              --
                              /*SUM((SELECT BT.VLR_TRIBUTO
                                    FROM MSAF.X08_TRIB_MERC BT
                                   WHERE BT.COD_EMPRESA = X08.COD_EMPRESA
                                     AND BT.COD_ESTAB = X08.COD_ESTAB
                                     AND BT.DATA_FISCAL = X08.DATA_FISCAL
                                     AND BT.MOVTO_E_S = X08.MOVTO_E_S
                                     AND BT.NORM_DEV = X08.NORM_DEV
                                     AND BT.IDENT_DOCTO = X08.IDENT_DOCTO
                                     AND BT.IDENT_FIS_JUR = X08.IDENT_FIS_JUR
                                     AND BT.NUM_DOCFIS = X08.NUM_DOCFIS
                                     AND BT.SERIE_DOCFIS = X08.SERIE_DOCFIS
                                     AND BT.SUB_SERIE_DOCFIS = X08.SUB_SERIE_DOCFIS
                                     AND BT.DISCRI_ITEM = X08.DISCRI_ITEM
                                     AND BT.COD_TRIBUTO = X08_BASE.COD_TRIBUTO
                                     AND BT.COD_TRIBUTO = 'ICMS'
                                     AND X08_BASE.COD_TRIBUTACAO = 1
                                     AND BT.COD_EMPRESA = X07.COD_EMPRESA
                                     AND BT.COD_ESTAB = X07.COD_ESTAB)) AS ICMS_TRIB_S,*/
                              --
                              SUM ( ( SELECT bb.vlr_base
                                        FROM msaf.x08_base_merc bb
                                       WHERE bb.cod_empresa = x08.cod_empresa
                                         AND bb.cod_estab = x08.cod_estab
                                         AND bb.data_fiscal = x08.data_fiscal
                                         AND bb.movto_e_s = x08.movto_e_s
                                         AND bb.norm_dev = x08.norm_dev
                                         AND bb.ident_docto = x08.ident_docto
                                         AND bb.ident_fis_jur = x08.ident_fis_jur
                                         AND bb.num_docfis = x08.num_docfis
                                         AND bb.serie_docfis = x08.serie_docfis
                                         AND bb.sub_serie_docfis = x08.sub_serie_docfis
                                         AND bb.discri_item = x08.discri_item
                                         AND bb.cod_tributo = 'ICMS'
                                         AND bb.cod_tributacao = 2
                                         AND bb.cod_empresa = x07.cod_empresa
                                         AND bb.cod_estab = x07.cod_estab ) )
                                  AS base_icms_isento_s
                            , --
                              SUM ( ( SELECT bt.vlr_tributo
                                        FROM msaf.x08_trib_merc bt
                                       WHERE bt.cod_empresa = x08_base.cod_empresa
                                         AND bt.cod_estab = x08_base.cod_estab
                                         AND bt.data_fiscal = x08_base.data_fiscal
                                         AND bt.movto_e_s = x08_base.movto_e_s
                                         AND bt.norm_dev = x08_base.norm_dev
                                         AND bt.ident_docto = x08_base.ident_docto
                                         AND bt.ident_fis_jur = x08_base.ident_fis_jur
                                         AND bt.num_docfis = x08_base.num_docfis
                                         AND bt.serie_docfis = x08_base.serie_docfis
                                         AND bt.sub_serie_docfis = x08_base.sub_serie_docfis
                                         AND bt.discri_item = x08_base.discri_item
                                         AND bt.cod_tributo = 'ICMS-S'
                                         AND bt.cod_empresa = x07.cod_empresa
                                         AND bt.cod_estab = x07.cod_estab ) )
                                  AS icms_st_s
                            , --
                              --=========================
                              -- GRUPO ENTRADAS
                              --=========================
                              REPLACE ( m.business_unit_in
                                      , v_people_de
                                      , v_people_para )
                                  AS estab_ent
                            , m.business_unit_bi AS bu_ent
                            , x04_ent.cpf_cgc AS cpf_cgc_forn_ent
                            , x04_ent.razao_social AS razao_social_forn_ent
                            , m.nf_brl_id_2_bbl AS id_people_ent
                            , m.nf_brl AS num_nf_ent
                            , m.nf_brl_series AS serie_ent
                            , m.nf_line_nbr_pbl AS num_item_ent
                            , m.nf_brl_date AS dt_nf_emissao_ent
                            , o.accounting_dt AS dt_entrada_psp
                            , ROUND (
                                      (   (   SUM ( ant_uf.merchandise_amt )
                                            + SUM ( ant_uf.freight_amt )
                                            + SUM ( ant_uf.otherexp_brl_amt )
                                            + SUM ( ant_uf.icmssub_brl_amt )
                                            + CASE
                                                  WHEN SUM ( ant_uf.ipitax_brl_rcvry ) > 0 THEN
                                                      SUM ( ant_uf.ipitax_brl_rcvry )
                                                  WHEN SUM ( ant_uf.ipitax_brl_bse ) > 0 THEN
                                                      SUM ( ant_uf.ipitax_brl_bse )
                                                  ELSE
                                                      0
                                              END
                                            - ABS ( SUM ( ant_uf.dscnt_amt ) ) )
                                        / SUM ( ant_uf.qty_nf_brl ) )
                                    , 4
                              )
                                  AS vlr_contabil_ent
                            , -- 0 AS VLR_CONTABIL_ENT, -- MERGE APOS O CALCULO DA PROC
                              --
                               ( CASE
                                    WHEN estado_ent.cod_estado = 'RJ'
                                     AND NVL ( ant_rj.dsp_icms_amt_st, 0 ) > 0
                                     AND NVL ( ant_rj.qty_nf_brl, 0 ) > 0 THEN
                                        ant_rj.qty_nf_brl
                                    WHEN --NVL(ANT_UF.DSP_ICMS_AMT_ST, 0) > 0 AND
                                        NVL ( ant_uf.qty_nf_brl, 0 ) > 0 THEN
                                        ant_uf.qty_nf_brl
                                    WHEN NVL ( m.icmssub_brl_amt, 0 ) > 0
                                     AND NVL ( n.qty_nf_brl, 0 ) > 0 THEN
                                        n.qty_nf_brl
                                    WHEN NVL ( m.icmssub_brl_amt, 0 ) > 0
                                     AND NVL ( m.qty_nf_brl, 0 ) > 0 THEN
                                        m.qty_nf_brl
                                END )
                                  AS qtde_nf_ent
                            , --

                              ROUND (   ant_uf.unit_price
                                      - ( CASE
                                             WHEN ant_uf.unit_price > 0
                                              AND ant_uf.dscnt_pct > 0 THEN
                                                 ROUND ( ant_uf.unit_price * ( ant_uf.dscnt_pct / 100 )
                                                       , 5 )
                                             ELSE
                                                 0
                                         END )
                                    , 5 )
                                  AS vlr_unit_ent
                            , /*
                                       M.ICMSTAX_BRL_BSS AS BASE_ICMS_ENT,
                                       M.ICMSTAX_BRL_RED AS PERCT_REDU_ICMS_ENT,
                                       M.ICMSTAX_BRL_PCT AS ALIQ_ICMS,
                                       M.ICMSTAX_BRL_AMT AS VLR_ICMS_ENT,
                                       M.ICMSSUB_BRL_BSS AS BASE_ICMSST_ENT,
                              */

                              ROUND ( SUM ( ant_uf.icmstax_brl_bss / ant_uf.qty_nf_brl )
                                    , 4 )
                                  AS base_icms_ent
                            , ROUND ( MAX ( ant_uf.icmstax_brl_red )
                                    , 4 )
                                  AS perct_redu_icms_ent
                            , ROUND ( MAX ( ant_uf.icmstax_brl_pct )
                                    , 4 )
                                  AS aliq_icms
                            , ROUND ( SUM ( ant_uf.icmstax_brl_amt / ant_uf.qty_nf_brl )
                                    , 4 )
                                  AS vlr_icms_ent
                            , ROUND ( SUM ( ant_uf.icmssub_brl_bss / ant_uf.qty_nf_brl )
                                    , 4 )
                                  AS base_icmsst_ent
                            , ROUND ( SUM ( ant_uf.icmssub_brl_amt / ant_uf.qty_nf_brl )
                                    , 4 )
                                  AS vlr_icmsst_ent
                            , /*( CASE WHEN
                               ---
                               (CASE
                                       WHEN ESTADO_ENT.COD_ESTADO = 'RJ' AND
                                            NVL(ANT_RJ.DSP_ICMS_AMT_ST, 0) > 0 AND
                                            NVL(ANT_RJ.QTY_NF_BRL, 0) > 0 THEN
                                        ANT_RJ.QTY_NF_BRL
                                       WHEN --NVL(ANT_UF.DSP_ICMS_AMT_ST, 0) > 0 AND
                                            NVL(ANT_UF.QTY_NF_BRL, 0) > 0 THEN
                                        ANT_UF.QTY_NF_BRL
                                       WHEN NVL(M.ICMSSUB_BRL_AMT, 0) > 0 AND NVL(N.QTY_NF_BRL, 0) > 0 THEN
                                        N.QTY_NF_BRL
                                       WHEN NVL(M.ICMSSUB_BRL_AMT, 0) > 0 AND NVL(M.QTY_NF_BRL, 0) > 0 THEN
                                        M.QTY_NF_BRL
                                     END) <=0
                               THEN 0
                            ELSE
                               (
                               CASE WHEN  ROUND(DECODE(ESTADO_ENT.COD_ESTADO,
                                             'RJ',
                                             ANT_RJ.DSP_ICMS_AMT_ST,
                                             ANT_UF.DSP_ICMS_AMT_ST),2) > 0 THEN
                                      0
                                    WHEN M.ICMSSUB_BRL_AMT > 0 THEN
                                  M.ICMSSUB_BRL_AMT
                               ELSE 0
                                 END )
                           END)*/
                              --  AS VLR_ICMSST_ENT,
                              --
                              o.nfe_verif_code_pbl AS chave_acesso_ent
                            , --
                              NVL (
                                    DECODE ( estado_ent.cod_estado
                                           , 'RJ', ant_rj.dsp_icms_amt_st
                                           , ant_uf.dsp_icms_amt_st )
                                  , 0
                              )
                                  vlr_antecip_ist
                            , --=========================
                              -- GRUPO CALCULADOS
                              --=========================
                              /*DECODE(X08_RED_SAI.VLR_BASE,
                                       0,
                                       0,
                                       ROUND((SUM(DECODE(ROWNUM,
                                                         1,
                                                         X08_RED_SAI.VLR_BASE,
                                                         -1 * X08_RED_SAI.VLR_BASE)) /
                                             MAX(X08_RED_SAI.VLR_BASE)) * 100,
                                             2)) */
                              NULL AS perct_redu_icms_sai
                            , --
                              /*ROUND( CASE WHEN
                                 ---
                                 (CASE
                                         WHEN ESTADO_ENT.COD_ESTADO = 'RJ' AND
                                              NVL(ANT_RJ.DSP_ICMS_AMT_ST, 0) > 0 AND
                                              NVL(ANT_RJ.QTY_NF_BRL, 0) > 0 THEN
                                          ANT_RJ.QTY_NF_BRL
                                         WHEN --NVL(ANT_UF.DSP_ICMS_AMT_ST, 0) > 0 AND
                                              NVL(ANT_UF.QTY_NF_BRL, 0) > 0 THEN
                                          ANT_UF.QTY_NF_BRL
                                         WHEN NVL(M.ICMSSUB_BRL_AMT, 0) > 0 AND NVL(N.QTY_NF_BRL, 0) > 0 THEN
                                          N.QTY_NF_BRL
                                         WHEN NVL(M.ICMSSUB_BRL_AMT, 0) > 0 AND NVL(M.QTY_NF_BRL, 0) > 0 THEN
                                          M.QTY_NF_BRL
                                       END) <=0
                                 THEN 0
                              ELSE
                                 ROUND((
                                 CASE WHEN  ROUND(DECODE(ESTADO_ENT.COD_ESTADO,
                                               'RJ',
                                               ANT_RJ.DSP_ICMS_AMT_ST,
                                               ANT_UF.DSP_ICMS_AMT_ST),2) > 0 THEN
                                        ROUND(DECODE(ESTADO_ENT.COD_ESTADO,
                                               'RJ',
                                               ANT_RJ.DSP_ICMS_AMT_ST,
                                               ANT_UF.DSP_ICMS_AMT_ST),2)
                                      WHEN M.ICMSSUB_BRL_AMT > 0 THEN
                                    M.ICMSSUB_BRL_AMT
                                 ELSE 0
                                   END ),2) /
                                 ROUND((CASE
                                         WHEN ESTADO_ENT.COD_ESTADO = 'RJ' AND
                                              NVL(ANT_RJ.DSP_ICMS_AMT_ST, 0) > 0 AND
                                              NVL(ANT_RJ.QTY_NF_BRL, 0) > 0 THEN
                                          ANT_RJ.QTY_NF_BRL
                                         WHEN --NVL(ANT_UF.DSP_ICMS_AMT_ST, 0) > 0 AND
                                              NVL(ANT_UF.QTY_NF_BRL, 0) > 0 THEN
                                          ANT_UF.QTY_NF_BRL
                                         WHEN NVL(M.ICMSSUB_BRL_AMT, 0) > 0 AND NVL(N.QTY_NF_BRL, 0) > 0 THEN
                                          N.QTY_NF_BRL
                                         WHEN NVL(M.ICMSSUB_BRL_AMT, 0) > 0 AND NVL(M.QTY_NF_BRL, 0) > 0 THEN
                                          M.QTY_NF_BRL
                                       END),2)

                                        * ROUND(X08.QUANTIDADE,2)
                             END,2)*/
                              NULL AS icms_s_dev
                            , --=========================
                              -- CAMPOS INTERNOS PARA ANÁLISE E SUPORTE DO TIME TÉCNICO
                              --=========================
                              DECODE ( MAX ( x08_red_sai.cod_tributacao ), 4, 'S', 'N' ) AS ind_reducao_sai
                            , -- INDICADOR DA REDUÇÃO DE ICMS SAÍDA
                             estado_ent.cod_estado AS uf_ent
                            , -- UF DE ENTRADA
                              --=========================
                              -- CAMPOS PARA GERAR A ULTIMA ENTRADA NO PROXIMO STEP
                              --=========================
                              x07.data_fiscal AS data_fiscal
                            , x07.ident_fis_jur AS ident_fis_jur_sai
                            , x04_ent.ident_fis_jur AS ident_fis_jur_ent
                            , -- DESCONSIDERAR ESTE CAMPO, O IDENT_FIS_JUR_SAI será utilizado
                             ROUND (
                                       NVL (
                                             DECODE ( estado_ent.cod_estado
                                                    , 'RJ', ant_rj.dsp_icms_amt_st
                                                    , ant_uf.dsp_icms_amt_st )
                                           , 0
                                       )
                                     / ( CASE
                                            WHEN estado_ent.cod_estado = 'RJ'
                                             AND NVL ( ant_rj.dsp_icms_amt_st, 0 ) > 0
                                             AND NVL ( ant_rj.qty_nf_brl, 0 ) > 0 THEN
                                                ant_rj.qty_nf_brl
                                            WHEN --NVL(ANT_UF.DSP_ICMS_AMT_ST, 0) > 0 AND
                                                NVL ( ant_uf.qty_nf_brl, 0 ) > 0 THEN
                                                ant_uf.qty_nf_brl
                                            WHEN NVL ( m.icmssub_brl_amt, 0 ) > 0
                                             AND NVL ( n.qty_nf_brl, 0 ) > 0 THEN
                                                n.qty_nf_brl
                                            WHEN NVL ( m.icmssub_brl_amt, 0 ) > 0
                                             AND NVL ( m.qty_nf_brl, 0 ) > 0 THEN
                                                m.qty_nf_brl
                                        END )
                                   , 4
                              )
                                  AS vlr_antecip_unit
                            , ROUND (
                                        ROUND (
                                                  NVL (
                                                        DECODE ( estado_ent.cod_estado
                                                               , 'RJ', ant_rj.dsp_icms_amt_st
                                                               , ant_uf.dsp_icms_amt_st )
                                                      , 0
                                                  )
                                                / ( CASE
                                                       WHEN estado_ent.cod_estado = 'RJ'
                                                        AND NVL ( ant_rj.dsp_icms_amt_st, 0 ) > 0
                                                        AND NVL ( ant_rj.qty_nf_brl, 0 ) > 0 THEN
                                                           ant_rj.qty_nf_brl
                                                       WHEN --NVL(ANT_UF.DSP_ICMS_AMT_ST, 0) > 0 AND
                                                           NVL ( ant_uf.qty_nf_brl, 0 ) > 0 THEN
                                                           ant_uf.qty_nf_brl
                                                       WHEN NVL ( m.icmssub_brl_amt, 0 ) > 0
                                                        AND NVL ( n.qty_nf_brl, 0 ) > 0 THEN
                                                           n.qty_nf_brl
                                                       WHEN NVL ( m.icmssub_brl_amt, 0 ) > 0
                                                        AND NVL ( m.qty_nf_brl, 0 ) > 0 THEN
                                                           m.qty_nf_brl
                                                   END )
                                              , 4
                                        )
                                      * x08.quantidade
                                    , 4
                              )
                                  AS total_icms_st_ressarc
                         --=========================
                         FROM msaf.x07_docto_fiscal x07
                            , msaf.x08_itens_merc x08
                            , msaf.x08_base_merc x08_base
                            , msaf.x08_trib_merc x08_trib
                            , msaf.x08_base_merc x08_red_sai
                            , -- Base para Redução ICMS de Saída
                             msaf.x2012_cod_fiscal x2012
                            , msaf.x2006_natureza_op x2006
                            , msafi.dsp_estabelecimento estab
                            , msaf.x04_pessoa_fis_jur x04
                            , msaf.estabelecimento forn_ent
                            , msaf.x04_pessoa_fis_jur x04_ent
                            , msaf.estado estado_ent
                            , msaf.y2026_sit_trb_uf_b y2026
                            , msaf.y2025_sit_trb_uf_a y2025
                            , msaf.estado estado
                            , msaf.x2013_produto x2013
                            , (SELECT /* +driving_site(tab) */
                                     *
                                 FROM msafi.ps_dsp_rl_nfor_tbl) m
                            , (SELECT /* +driving_site(tab) */
                                     DISTINCT qty_nf_brl
                                            , business_unit
                                            , nf_brl_line_num
                                            , nf_brl_id
                                            , nf_brl_date
                                 FROM msafi.ps_dsp_obr_po_st_t) n
                            , (SELECT /* +driving_site(tab) */
                                     *
                                 FROM msafi.ps_nf_hdr_brl) o
                            , (SELECT /* +driving_site(tab) */
                                     DISTINCT n.qty_nf_brl
                                            , n.business_unit
                                            , n.nf_brl_line_num
                                            , n.nf_brl_id
                                            , n.nf_brl_date
                                            , n.dsp_icms_amt_st
                                 FROM msafi.ps_dsp_obr_po_st_t n) ant_rj
                            , ---Antecipação do RJ
                             (SELECT /* +driving_site(tab) */
                                    business_unit
                                   , nf_brl_id
                                   , nf_brl_line_num
                                   , merchandise_amt
                                   , freight_amt
                                   , otherexp_brl_amt
                                   , icmssub_brl_amt
                                   , ipitax_brl_rcvry
                                   , ipitax_brl_bse
                                   , dscnt_amt
                                   , dsp_icms_amt_st
                                   , qty_nf_brl
                                   , icmstax_brl_bss
                                   , icmstax_brl_red
                                   , icmstax_brl_pct
                                   , icmstax_brl_amt
                                   , icmssub_brl_bss
                                   , unit_price
                                   , dscnt_pct
                                FROM msafi.ps_nf_ln_brl x) ant_uf -- Antecipação Outras UFs e Proprio
                        WHERE 1 = 1
                          --FILTROS DA FUNCIONAL
                          AND x2012.cod_cfo IN ( '5411'
                                               , '6411'
                                               , '5202'
                                               , '6202' )
                          AND x07.norm_dev = '2'
                          --AND ANT_RJ.DSP_ICMS_AMT_ST(+) > 0 -- NÃO UTILIZAR

                          AND x07.cod_empresa = mcod_empresa
                          AND x07.cod_estab = pcod_estab
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
                          AND x08.cod_empresa = x08_base.cod_empresa(+)
                          AND x08.cod_estab = x08_base.cod_estab(+)
                          AND x08.data_fiscal = x08_base.data_fiscal(+)
                          AND x08.movto_e_s = x08_base.movto_e_s(+)
                          AND x08.norm_dev = x08_base.norm_dev(+)
                          AND x08.ident_docto = x08_base.ident_docto(+)
                          AND x08.ident_fis_jur = x08_base.ident_fis_jur(+)
                          AND x08.num_docfis = x08_base.num_docfis(+)
                          AND x08.serie_docfis = x08_base.serie_docfis(+)
                          AND x08.sub_serie_docfis = x08_base.sub_serie_docfis(+)
                          AND x08.discri_item = x08_base.discri_item(+)
                          AND x08_base.cod_tributo(+) = 'ICMS'
                          AND x08_base.cod_tributacao(+) = 1
                          AND x08.cod_empresa = x08_red_sai.cod_empresa(+)
                          AND x08.cod_estab = x08_red_sai.cod_estab(+)
                          AND x08.data_fiscal = x08_red_sai.data_fiscal(+)
                          AND x08.movto_e_s = x08_red_sai.movto_e_s(+)
                          AND x08.norm_dev = x08_red_sai.norm_dev(+)
                          AND x08.ident_docto = x08_red_sai.ident_docto(+)
                          AND x08.ident_fis_jur = x08_red_sai.ident_fis_jur(+)
                          AND x08.num_docfis = x08_red_sai.num_docfis(+)
                          AND x08.serie_docfis = x08_red_sai.serie_docfis(+)
                          AND x08.sub_serie_docfis = x08_red_sai.sub_serie_docfis(+)
                          AND x08.discri_item = x08_red_sai.discri_item(+)
                          AND x08_red_sai.cod_tributacao(+) = 4 -- IN (1, 4)
                          AND x08_red_sai.cod_tributo(+) = 'ICMS'
                          AND x08.cod_empresa = x08_trib.cod_empresa(+)
                          AND x08.cod_estab = x08_trib.cod_estab(+)
                          AND x08.data_fiscal = x08_trib.data_fiscal(+)
                          AND x08.movto_e_s = x08_trib.movto_e_s(+)
                          AND x08.norm_dev = x08_trib.norm_dev(+)
                          AND x08.ident_docto = x08_trib.ident_docto(+)
                          AND x08.ident_fis_jur = x08_trib.ident_fis_jur(+)
                          AND x08.num_docfis = x08_trib.num_docfis(+)
                          AND x08.serie_docfis = x08_trib.serie_docfis(+)
                          AND x08.sub_serie_docfis = x08_trib.sub_serie_docfis(+)
                          AND x08.discri_item = x08_trib.discri_item(+)
                          AND x08_trib.cod_tributo(+) = 'ICMS'
                          AND estab.cod_empresa = x07.cod_empresa
                          AND estab.cod_estab = x07.cod_estab
                          AND x08.ident_cfo = x2012.ident_cfo
                          AND x08.ident_natureza_op = x2006.ident_natureza_op
                          AND x08.ident_produto = x2013.ident_produto
                          AND y2026.ident_situacao_b = x08.ident_situacao_b
                          AND y2025.ident_situacao_a = x08.ident_situacao_a
                          AND x04.ident_fis_jur = x07.ident_fis_jur
                          AND estado.ident_estado = x04.ident_estado
                          AND forn_ent.cod_estab = REPLACE ( m.business_unit_in
                                                           , v_people_de
                                                           , v_people_para )
                          AND x04_ent.cod_fis_jur = REPLACE ( m.business_unit_in
                                                            , v_people_de
                                                            , v_people_para )
                          AND x04_ent.cpf_cgc = forn_ent.cgc
                          AND x04_ent.ident_estado = estado_ent.ident_estado
                          AND x07.cod_estab = REPLACE ( m.business_unit
                                                      , v_people_de
                                                      , v_people_para )
                          AND x07.num_controle_docto = m.nf_brl_id
                          AND x08.num_item = m.nf_brl_line_num
                          AND m.business_unit = n.business_unit(+)
                          AND m.nf_line_nbr_pbl = n.nf_brl_line_num(+)
                          AND m.nf_brl_id_2_bbl = n.nf_brl_id(+)
                          AND n.nf_brl_date(+) BETWEEN pdt_ini AND pdt_fim
                          AND o.ef_loc_brl = REPLACE ( m.business_unit_in
                                                     , v_people_de
                                                     , v_people_para )
                          AND o.nf_brl_id = m.nf_brl_id_2_bbl
                          AND o.nf_brl_date BETWEEN pdt_ini AND pdt_fim
                          --Antecipação do RJ
                          AND m.business_unit_in = ant_rj.business_unit(+)
                          AND m.nf_line_nbr_pbl = ant_rj.nf_brl_line_num(+)
                          AND m.nf_brl_id_2_bbl = ant_rj.nf_brl_id(+)
                          --Antecipação Outras UFs
                          AND m.business_unit_bi = ant_uf.business_unit(+)
                          AND m.nf_line_nbr_pbl = ant_uf.nf_brl_line_num(+)
                          AND m.nf_brl_id_2_bbl = ant_uf.nf_brl_id(+)
                     GROUP BY x07.cod_empresa
                            , x07.cod_estab
                            , x07.data_emissao
                            , x07.num_docfis
                            , x07.num_controle_docto
                            , x07.num_autentic_nfe
                            , x2012.cod_cfo
                            , x2006.cod_natureza_op
                            , x07.situacao
                            , x04.cod_fis_jur
                            , x04.cpf_cgc
                            , x04.razao_social
                            , x2013.cod_produto
                            , x2013.descricao
                            , x08.quantidade
                            , x08.vlr_unit
                            , estado.cod_estado
                            , estab.cod_estado
                            , y2026.cod_situacao_b
                            , y2025.cod_situacao_a
                            , x08.num_item
                            , REPLACE ( m.business_unit_in
                                      , v_people_de
                                      , v_people_para )
                            , m.business_unit_bi
                            , m.nf_brl_id_2_bbl
                            , m.nf_brl
                            , m.nf_brl_series
                            , m.nf_line_nbr_pbl
                            , x04_ent.cod_fis_jur
                            , x04_ent.cpf_cgc
                            , x04_ent.razao_social
                            , m.qty_nf_brl
                            , ant_rj.qty_nf_brl
                            , n.qty_nf_brl
                            , ant_uf.qty_nf_brl
                            , x08_red_sai.vlr_base
                            , ant_uf.unit_price
                            , ant_uf.dscnt_pct
                            , --M.ICMSTAX_BRL_BSS,
                              --M.ICMSTAX_BRL_AMT,
                              --M.ICMSTAX_BRL_PCT,
                              --M.ICMSTAX_BRL_RED,
                              m.icmssub_brl_amt
                            , --M.ICMSSUB_BRL_BSS,
                              m.nf_brl_date
                            , o.nfe_verif_code_pbl
                            , o.accounting_dt
                            , estado_ent.cod_estado
                            , ant_rj.dsp_icms_amt_st
                            , ant_uf.dsp_icms_amt_st
                            , x07.data_fiscal
                            , x07.ident_fis_jur
                            , x04_ent.ident_fis_jur
                            , x04_ent.cod_fis_jur ) a
             WHERE vlr_antecip_ist > 0;


        --============================================================================

        TYPE tempresa IS TABLE OF msafi.dpsp_fin276_res_st_dev_forn.empresa%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tuf IS TABLE OF msafi.dpsp_fin276_res_st_dev_forn.uf%TYPE
            INDEX BY PLS_INTEGER;

        TYPE testabelecimento IS TABLE OF msafi.dpsp_fin276_res_st_dev_forn.estabelecimento%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tdata_emissao IS TABLE OF msafi.dpsp_fin276_res_st_dev_forn.data_emissao%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tnum_nf IS TABLE OF msafi.dpsp_fin276_res_st_dev_forn.num_nf%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tid_people IS TABLE OF msafi.dpsp_fin276_res_st_dev_forn.id_people%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tchave_de_acesso IS TABLE OF msafi.dpsp_fin276_res_st_dev_forn.chave_de_acesso%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tcod_fornecedor IS TABLE OF msafi.dpsp_fin276_res_st_dev_forn.cod_fornecedor%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tcpf_cgc_forn IS TABLE OF msafi.dpsp_fin276_res_st_dev_forn.cpf_cgc_forn%TYPE
            INDEX BY PLS_INTEGER;

        TYPE trazao_social_forn IS TABLE OF msafi.dpsp_fin276_res_st_dev_forn.razao_social_forn%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tuf_forn IS TABLE OF msafi.dpsp_fin276_res_st_dev_forn.uf_forn%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tcod_prd IS TABLE OF msafi.dpsp_fin276_res_st_dev_forn.cod_prd%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tdescr_prd IS TABLE OF msafi.dpsp_fin276_res_st_dev_forn.descr_prd%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tqtde IS TABLE OF msafi.dpsp_fin276_res_st_dev_forn.qtde%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tnum_item IS TABLE OF msafi.dpsp_fin276_res_st_dev_forn.num_item%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tvlr_unit IS TABLE OF msafi.dpsp_fin276_res_st_dev_forn.vlr_unit%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tcfop IS TABLE OF msafi.dpsp_fin276_res_st_dev_forn.cfop%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tfinalidade IS TABLE OF msafi.dpsp_fin276_res_st_dev_forn.finalidade%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tsituacao_nf IS TABLE OF msafi.dpsp_fin276_res_st_dev_forn.situacao_nf%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tcst_a IS TABLE OF msafi.dpsp_fin276_res_st_dev_forn.cst_a%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tcst_b IS TABLE OF msafi.dpsp_fin276_res_st_dev_forn.cst_b%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tvlr_contabil_s IS TABLE OF msafi.dpsp_fin276_res_st_dev_forn.vlr_contabil_s%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tbase_icms_trib_s IS TABLE OF msafi.dpsp_fin276_res_st_dev_forn.base_icms_trib_s%TYPE
            INDEX BY PLS_INTEGER;

        TYPE ticms_trib_s IS TABLE OF msafi.dpsp_fin276_res_st_dev_forn.icms_trib_s%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tbase_icms_isento_s IS TABLE OF msafi.dpsp_fin276_res_st_dev_forn.base_icms_isento_s%TYPE
            INDEX BY PLS_INTEGER;

        TYPE ticms_st_s IS TABLE OF msafi.dpsp_fin276_res_st_dev_forn.icms_st_s%TYPE
            INDEX BY PLS_INTEGER;

        TYPE testab_ent IS TABLE OF msafi.dpsp_fin276_res_st_dev_forn.estab_ent%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tbu_ent IS TABLE OF msafi.dpsp_fin276_res_st_dev_forn.bu_ent%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tcpf_cgc_forn_ent IS TABLE OF msafi.dpsp_fin276_res_st_dev_forn.cpf_cgc_forn_ent%TYPE
            INDEX BY PLS_INTEGER;

        TYPE trazao_social_forn_ent IS TABLE OF msafi.dpsp_fin276_res_st_dev_forn.razao_social_forn_ent%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tid_people_ent IS TABLE OF msafi.dpsp_fin276_res_st_dev_forn.id_people_ent%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tnum_nf_ent IS TABLE OF msafi.dpsp_fin276_res_st_dev_forn.num_nf_ent%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tserie_ent IS TABLE OF msafi.dpsp_fin276_res_st_dev_forn.serie_ent%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tnum_item_ent IS TABLE OF msafi.dpsp_fin276_res_st_dev_forn.num_item_ent%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tdt_nf_emissao_ent IS TABLE OF msafi.dpsp_fin276_res_st_dev_forn.dt_nf_emissao_ent%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tdt_entrada_psp IS TABLE OF msafi.dpsp_fin276_res_st_dev_forn.dt_entrada_psp%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tvlr_contabil_ent IS TABLE OF msafi.dpsp_fin276_res_st_dev_forn.vlr_contabil_ent%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tqtde_nf_ent IS TABLE OF msafi.dpsp_fin276_res_st_dev_forn.qtde_nf_ent%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tvlr_unit_ent IS TABLE OF msafi.dpsp_fin276_res_st_dev_forn.vlr_unit_ent%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tbase_icms_ent IS TABLE OF msafi.dpsp_fin276_res_st_dev_forn.base_icms_ent%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tperct_redu_icms_ent IS TABLE OF msafi.dpsp_fin276_res_st_dev_forn.perct_redu_icms_ent%TYPE
            INDEX BY PLS_INTEGER;

        TYPE taliq_icms IS TABLE OF msafi.dpsp_fin276_res_st_dev_forn.aliq_icms%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tvlr_icms_ent IS TABLE OF msafi.dpsp_fin276_res_st_dev_forn.vlr_icms_ent%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tbase_icmsst_ent IS TABLE OF msafi.dpsp_fin276_res_st_dev_forn.base_icmsst_ent%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tvlr_icmsst_ent IS TABLE OF msafi.dpsp_fin276_res_st_dev_forn.vlr_icmsst_ent%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tchave_acesso_ent IS TABLE OF msafi.dpsp_fin276_res_st_dev_forn.chave_acesso_ent%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tvlr_antecip_ist IS TABLE OF msafi.dpsp_fin276_res_st_dev_forn.vlr_antecip_ist%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tperct_redu_icms_sai IS TABLE OF msafi.dpsp_fin276_res_st_dev_forn.perct_redu_icms_sai%TYPE
            INDEX BY PLS_INTEGER;

        TYPE ticms_s_dev IS TABLE OF msafi.dpsp_fin276_res_st_dev_forn.icms_s_dev%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tind_reducao_sai IS TABLE OF msafi.dpsp_fin276_res_st_dev_forn.ind_reducao_sai%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tuf_ent IS TABLE OF msafi.dpsp_fin276_res_st_dev_forn.uf_ent%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tdata_fiscal IS TABLE OF msafi.dpsp_fin276_res_st_dev_forn.data_fiscal%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tident_fis_jur_sai IS TABLE OF msafi.dpsp_fin276_res_st_dev_forn.ident_fis_jur_sai%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tident_fis_jur_ent IS TABLE OF msafi.dpsp_fin276_res_st_dev_forn.ident_fis_jur_ent%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tproc_id IS TABLE OF msafi.dpsp_fin276_res_st_dev_forn.proc_id%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tnm_usuario IS TABLE OF msafi.dpsp_fin276_res_st_dev_forn.nm_usuario%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tdt_carga IS TABLE OF msafi.dpsp_fin276_res_st_dev_forn.dt_carga%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tdt_vlr_antecip_unit IS TABLE OF msafi.dpsp_fin276_res_st_dev_forn.vlr_antecip_unit%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tdt_total_icms_st_ressarc IS TABLE OF msafi.dpsp_fin276_res_st_dev_forn.total_icms_st_ressarc%TYPE
            INDEX BY PLS_INTEGER;


        v_empresa tempresa;
        v_uf tuf;
        v_estabelecimento testabelecimento;
        v_data_emissao tdata_emissao;
        v_num_nf tnum_nf;
        v_id_people tid_people;
        v_chave_de_acesso tchave_de_acesso;
        v_cod_fornecedor tcod_fornecedor;
        v_cpf_cgc_forn tcpf_cgc_forn;
        v_razao_social_forn trazao_social_forn;
        v_uf_forn tuf_forn;
        v_cod_prd tcod_prd;
        v_descr_prd tdescr_prd;
        v_qtde tqtde;
        v_num_item tnum_item;
        v_vlr_unit tvlr_unit;
        v_cfop tcfop;
        v_finalidade tfinalidade;
        v_situacao_nf tsituacao_nf;
        v_cst_a tcst_a;
        v_cst_b tcst_b;
        v_vlr_contabil_s tvlr_contabil_s;
        v_base_icms_trib_s tbase_icms_trib_s;
        v_icms_trib_s ticms_trib_s;
        v_base_icms_isento_s tbase_icms_isento_s;
        v_icms_st_s ticms_st_s;
        v_estab_ent testab_ent;
        v_bu_ent tbu_ent;
        v_cpf_cgc_forn_ent tcpf_cgc_forn_ent;
        v_razao_social_forn_ent trazao_social_forn_ent;
        v_id_people_ent tid_people_ent;
        v_num_nf_ent tnum_nf_ent;
        v_serie_ent tserie_ent;
        v_num_item_ent tnum_item_ent;
        v_dt_nf_emissao_ent tdt_nf_emissao_ent;
        v_dt_entrada_psp tdt_entrada_psp;
        v_vlr_contabil_ent tvlr_contabil_ent;
        v_qtde_nf_ent tqtde_nf_ent;
        v_vlr_unit_ent tvlr_unit_ent;
        v_base_icms_ent tbase_icms_ent;
        v_perct_redu_icms_ent tperct_redu_icms_ent;
        v_aliq_icms taliq_icms;
        v_vlr_icms_ent tvlr_icms_ent;
        v_base_icmsst_ent tbase_icmsst_ent;
        v_vlr_icmsst_ent tvlr_icmsst_ent;
        v_chave_acesso_ent tchave_acesso_ent;
        v_vlr_antecip_ist tvlr_antecip_ist;
        v_perct_redu_icms_sai tperct_redu_icms_sai;
        v_icms_s_dev ticms_s_dev;
        v_ind_reducao_sai tind_reducao_sai;
        v_uf_ent tuf_ent;
        v_data_fiscal tdata_fiscal;
        v_ident_fis_jur_sai tident_fis_jur_sai;
        v_ident_fis_jur_ent tident_fis_jur_ent;
        v_proc_id tproc_id;
        v_nm_usuario tnm_usuario;
        v_dt_carga tdt_carga;

        v_vlr_antecip_unit tdt_vlr_antecip_unit;
        v_total_icms_st_ressarc tdt_total_icms_st_ressarc;
    BEGIN
        OPEN c_sped;

        LOOP
            FETCH c_sped
                BULK COLLECT INTO v_empresa
                   , v_uf
                   , v_estabelecimento
                   , v_data_emissao
                   , v_num_nf
                   , v_id_people
                   , v_chave_de_acesso
                   , v_cod_fornecedor
                   , v_cpf_cgc_forn
                   , v_razao_social_forn
                   , v_uf_forn
                   , v_cod_prd
                   , v_descr_prd
                   , v_qtde
                   , v_num_item
                   , v_vlr_unit
                   , v_cfop
                   , v_finalidade
                   , v_situacao_nf
                   , v_cst_a
                   , v_cst_b
                   , v_vlr_contabil_s
                   , v_base_icms_trib_s
                   , v_icms_trib_s
                   , v_base_icms_isento_s
                   , v_icms_st_s
                   , v_estab_ent
                   , v_bu_ent
                   , v_cpf_cgc_forn_ent
                   , v_razao_social_forn_ent
                   , v_id_people_ent
                   , v_num_nf_ent
                   , v_serie_ent
                   , v_num_item_ent
                   , v_dt_nf_emissao_ent
                   , v_dt_entrada_psp
                   , v_vlr_contabil_ent
                   , v_qtde_nf_ent
                   , v_vlr_unit_ent
                   , v_base_icms_ent
                   , v_perct_redu_icms_ent
                   , v_aliq_icms
                   , v_vlr_icms_ent
                   , v_base_icmsst_ent
                   , v_vlr_icmsst_ent
                   , v_chave_acesso_ent
                   , v_vlr_antecip_ist
                   , v_perct_redu_icms_sai
                   , v_icms_s_dev
                   , v_ind_reducao_sai
                   , v_uf_ent
                   , v_data_fiscal
                   , v_ident_fis_jur_sai
                   , v_ident_fis_jur_ent
                   , v_vlr_antecip_unit
                   , v_total_icms_st_ressarc
                   , v_proc_id
                   , v_nm_usuario
                   , v_dt_carga
                LIMIT cc_limit;

            FORALL i IN v_empresa.FIRST .. v_empresa.LAST
                INSERT /*+ APPEND */
                      INTO  msafi.dpsp_fin276_res_st_dev_forn
                     VALUES ( v_empresa ( i )
                            , v_uf ( i )
                            , v_estabelecimento ( i )
                            , v_data_emissao ( i )
                            , v_num_nf ( i )
                            , v_id_people ( i )
                            , v_chave_de_acesso ( i )
                            , v_cod_fornecedor ( i )
                            , v_cpf_cgc_forn ( i )
                            , v_razao_social_forn ( i )
                            , v_uf_forn ( i )
                            , v_cod_prd ( i )
                            , v_descr_prd ( i )
                            , v_qtde ( i )
                            , v_num_item ( i )
                            , v_vlr_unit ( i )
                            , v_cfop ( i )
                            , v_finalidade ( i )
                            , v_situacao_nf ( i )
                            , v_cst_a ( i )
                            , v_cst_b ( i )
                            , v_vlr_contabil_s ( i )
                            , v_base_icms_trib_s ( i )
                            , v_icms_trib_s ( i )
                            , v_base_icms_isento_s ( i )
                            , v_icms_st_s ( i )
                            , v_estab_ent ( i )
                            , v_bu_ent ( i )
                            , v_cpf_cgc_forn_ent ( i )
                            , v_razao_social_forn_ent ( i )
                            , v_id_people_ent ( i )
                            , v_num_nf_ent ( i )
                            , v_serie_ent ( i )
                            , v_num_item_ent ( i )
                            , v_dt_nf_emissao_ent ( i )
                            , v_dt_entrada_psp ( i )
                            , v_vlr_contabil_ent ( i )
                            , v_qtde_nf_ent ( i )
                            , v_vlr_unit_ent ( i )
                            , v_base_icms_ent ( i )
                            , v_perct_redu_icms_ent ( i )
                            , v_aliq_icms ( i )
                            , v_vlr_icms_ent ( i )
                            , v_base_icmsst_ent ( i )
                            , v_vlr_icmsst_ent ( i )
                            , v_chave_acesso_ent ( i )
                            , v_vlr_antecip_ist ( i )
                            , v_perct_redu_icms_sai ( i )
                            , v_icms_s_dev ( i )
                            , v_ind_reducao_sai ( i )
                            , v_uf_ent ( i )
                            , v_data_fiscal ( i )
                            , v_ident_fis_jur_sai ( i )
                            , v_ident_fis_jur_ent ( i )
                            , v_proc_id ( i )
                            , v_nm_usuario ( i )
                            , v_dt_carga ( i )
                            , v_vlr_antecip_unit ( i )
                            , v_total_icms_st_ressarc ( i ) );

            v_count_new := v_count_new + SQL%ROWCOUNT;

            dbms_application_info.set_module ( $$plsql_unit
                                             , 'Estab: ' || pcod_estab || ' Qtd ' || v_count_new );

            COMMIT;

            v_empresa.delete;
            v_uf.delete;
            v_estabelecimento.delete;
            v_data_emissao.delete;
            v_num_nf.delete;
            v_id_people.delete;
            v_chave_de_acesso.delete;
            v_cod_fornecedor.delete;
            v_cpf_cgc_forn.delete;
            v_razao_social_forn.delete;
            v_uf_forn.delete;
            v_cod_prd.delete;
            v_descr_prd.delete;
            v_qtde.delete;
            v_num_item.delete;
            v_vlr_unit.delete;
            v_cfop.delete;
            v_finalidade.delete;
            v_situacao_nf.delete;
            v_cst_a.delete;
            v_cst_b.delete;
            v_vlr_contabil_s.delete;
            v_base_icms_trib_s.delete;
            v_icms_trib_s.delete;
            v_base_icms_isento_s.delete;
            v_icms_st_s.delete;
            v_estab_ent.delete;
            v_bu_ent.delete;
            v_cpf_cgc_forn_ent.delete;
            v_razao_social_forn_ent.delete;
            v_id_people_ent.delete;
            v_num_nf_ent.delete;
            v_serie_ent.delete;
            v_num_item_ent.delete;
            v_dt_nf_emissao_ent.delete;
            v_dt_entrada_psp.delete;
            v_vlr_contabil_ent.delete;
            v_qtde_nf_ent.delete;
            v_vlr_unit_ent.delete;
            v_base_icms_ent.delete;
            v_perct_redu_icms_ent.delete;
            v_aliq_icms.delete;
            v_vlr_icms_ent.delete;
            v_base_icmsst_ent.delete;
            v_vlr_icmsst_ent.delete;
            v_chave_acesso_ent.delete;
            v_vlr_antecip_ist.delete;
            v_perct_redu_icms_sai.delete;
            v_icms_s_dev.delete;
            v_ind_reducao_sai.delete;
            v_uf_ent.delete;
            v_data_fiscal.delete;
            v_ident_fis_jur_sai.delete;
            v_ident_fis_jur_ent.delete;
            v_proc_id.delete;
            v_nm_usuario.delete;
            v_dt_carga.delete;
            v_vlr_antecip_unit.delete;
            v_total_icms_st_ressarc.delete;

            EXIT WHEN c_sped%NOTFOUND;
        END LOOP;

        CLOSE c_sped;

        COMMIT;

        loga (
                  '::QUANTIDADE DE REGISTROS INSERIDOS (DPSP_FIN276_RES_ST_DEV_FORN) , ESTAB: '
               || pcod_estab
               || ' - QTDE '
               || NVL ( v_count_new, 0 )
               || '::'
             , FALSE
        );

        RETURN NVL ( v_count_new, 0 );
    END;

    PROCEDURE carregar_temp_prod ( pdt_ini DATE
                                 , pdt_fim DATE
                                 , pcod_estab VARCHAR2
                                 , v_data_ini_hora VARCHAR2 )
    IS
    BEGIN
        dbms_application_info.set_module ( $$plsql_unit
                                         , 'Temp prod - Estab: ' || pcod_estab );

        INSERT INTO msafi.dpsp_fin276_temp_prod
            SELECT DISTINCT empresa AS cod_empresa
                          , estab_ent AS cod_estab_ent
                          , ident_fis_jur_sai AS ident_fis_jur_ent
                          , data_fiscal
                          , cod_prd AS cod_produto
                          , mproc_id AS proc_id
                          , mnm_usuario AS nm_usuario
                          , v_data_ini_hora dt_carga
              FROM msafi.dpsp_fin276_res_st_dev_forn
             WHERE empresa = mcod_empresa
               AND estabelecimento = pcod_estab
               AND data_fiscal BETWEEN pdt_ini AND pdt_fim
               AND proc_id = mproc_id;

        COMMIT;
    END;
END dpsp_fin276_res_st_dev_cproc;
/
SHOW ERRORS;
