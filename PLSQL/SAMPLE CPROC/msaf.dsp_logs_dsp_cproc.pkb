Prompt Package Body DSP_LOGS_DSP_CPROC;
--
-- DSP_LOGS_DSP_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dsp_logs_dsp_cproc
IS
    mcod_empresa empresa.cod_empresa%TYPE;
    mcod_estab estabelecimento.cod_estab%TYPE;
    musuario usuario_empresa.cod_usuario%TYPE;

    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );
    BEGIN
        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        mcod_estab := lib_parametros.recuperar ( 'ESTABELECIMENTO' );
        musuario := lib_parametros.recuperar ( 'USUARIO' );

        -- PPARAM:      STRING PASSADA POR REFERÊNCIA;
        -- PTITULO:     TÍTULO DO PARÂMETRO MOSTRADO NA JANELA;
        -- PTIPO:       VARCHAR2, DATE, INTEGER;
        -- PCONTROLE:   MULTIPROC, TEXT, TEXTBOX, COMBOBOX, LISTBOX OU RADIOBUTTON;
        -- PMANDATORIO: S OU N, INDICANDO SE A INFORMAÇÃO DO PARÂMETRO É OBRIGATÓRIA;
        -- PDEFAULT:    VALOR PREENCHIDO AUTOMATICAMENTE NA ABERTURA DA JANELA;
        -- PMASCARA:    MÁSCARA PARA DIGITAÇÃO (EX: DD/MM/YYYY, 999999 OU ######);
        -- PVALORES:    SELECT (COMBOBOX OU MULTIPROC) OU COD1=DESC1,COD2=DESC2...
        -- PAPRESENTA:  S OU N, INDICANDO SE O PARÂMETRO DEVE SER MOSTRADO NA LISTAGEM DOS PROCESSOS;

        lib_proc.add_param ( pstr
                           , 'ACAO'
                           , --P_ACAO
                            'VARCHAR2'
                           , 'COMBOBOX'
                           , 'S'
                           , '1'
                           , NULL
                           , '
                            SELECT 1,''Visualizar logs'' FROM DUAL
                      UNION SELECT 2,''Calcular estatisticas - todos'' FROM DUAL
                      UNION SELECT 3,''Limpar log especifico'' FROM DUAL
                      UNION SELECT 4,''Limpar logs - todos, manter apenas ultimos 30 dias'' FROM DUAL
                      UNION SELECT 5,''Marcar logs EM PROCESSO como ERRO'' FROM DUAL
                      ORDER BY 1
                           '  );

        lib_proc.add_param (
                             pstr
                           , 'Processos'
                           , --P_PROC
                            'VARCHAR2'
                           , 'MULTISELECT'
                           , 'N'
                           , NULL
                           , NULL
                           , '
                           SELECT PROCESS_INSTANCE, PROCESS_DATE || '' - '' || PROCESS_INSTANCE
                           || '' - '' || USER_ID || '' - '' || PROCESS_ID || '' - '' || DESCR || '' - '' || STATUS
                           FROM (SELECT * FROM MSAFI.DSP_PROCESS_INFO WHERE PROCESS_DATE >= SYSDATE-15 ORDER BY PROCESS_INSTANCE DESC)
                           WHERE ROWNUM <= 1500
                           ORDER BY PROCESS_INSTANCE DESC
                           '
        );

        RETURN pstr;
    END; --FUNCTION PARAMETROS RETURN VARCHAR2 IS

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Gerenciamento de Logs DSP';
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
        RETURN 'VERSAO 1.0';
    END;

    FUNCTION descricao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Gerenciar e visualisar logs de cargas, scripts e processos customizados';
    END;

    FUNCTION modulo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'PROCESSOS CUSTOMIZADOS';
    END;

    FUNCTION classificacao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'PROCESSOS CUSTOMIZADOS';
    END;

    FUNCTION orientacaopapel
        RETURN VARCHAR2
    IS
    BEGIN
        -- orientação do papel
        RETURN 'landscape';
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
        msafi.dsp_control.writelog ( 'INFO'
                                   , p_i_texto );
    END;


    FUNCTION executar ( p_acao VARCHAR2
                      , p_proc lib_proc.vartab )
        RETURN INTEGER
    IS
        mproc_id INTEGER;
        iproc INTEGER;

        v_proc_status NUMBER := 0;
        v_s_proc_status VARCHAR2 ( 16 );

        --Variaveis especificas
        v_proci VARCHAR2 ( 8 );
        v_procd VARCHAR2 ( 21 );
        v_user VARCHAR2 ( 64 );
        v_procid VARCHAR2 ( 16 );
        v_status VARCHAR2 ( 16 );
        v_descr VARCHAR2 ( 64 );
        v_data_ini VARCHAR2 ( 10 );
        v_data_fim VARCHAR2 ( 10 );
        v_detalhes1 VARCHAR2 ( 32 );
        v_detalhes2 VARCHAR2 ( 32 );
        v_detalhes3 VARCHAR2 ( 32 );
        v_detalhes4 VARCHAR2 ( 32 );


        --Variaveis genericas
        v_longlog VARCHAR2 ( 1024 );
    BEGIN
        mproc_id :=
            lib_proc.new ( 'DSP_LOGS_DSP_CPROC'
                         , 48
                         , 150 );
        lib_proc.add_tipo ( mproc_id
                          , 1
                          , 'Processo'
                          , 1 );

        ----------------------------------------------------------------------------------------------------------
        IF p_acao = '1' THEN --SELECT 1,''Visualizar logs'' FROM DUAL
            IF p_proc.COUNT <= 0 THEN
                loga ( 'Escolha ao menos um processo para visualizar!' );
                lib_proc.close;
                RETURN mproc_id;
            END IF;

            iproc := p_proc.FIRST;
            lib_proc.add_header ( 'Imprimir Logs DSP'
                                , 1
                                , 1 );

            WHILE iproc IS NOT NULL LOOP
                SELECT LPAD ( TO_CHAR ( process_instance
                                      , 'FM99999999' )
                            , 8
                            , ' ' )
                     , TO_CHAR ( process_date
                               , 'DD/MM/YYYY HH24:MI:SS' )
                     , user_id
                     , process_id
                     , status
                     , descr
                     , TO_CHAR ( data_ini
                               , 'DD/MM/YYYY' )
                     , TO_CHAR ( data_fim
                               , 'DD/MM/YYYY' )
                     , detalhes1
                     , detalhes2
                     , detalhes3
                     , detalhes4
                  INTO v_proci
                     , v_procd
                     , v_user
                     , v_procid
                     , v_status
                     , v_descr
                     , v_data_ini
                     , v_data_fim
                     , v_detalhes1
                     , v_detalhes2
                     , v_detalhes3
                     , v_detalhes4
                  FROM msafi.dsp_process_info
                 WHERE process_instance = p_proc ( iproc );

                v_longlog :=
                       '|'
                    || LPAD ( 'USER'
                            , LENGTH ( NVL ( v_user, 'USER' ) )
                            , ' ' );
                v_longlog :=
                       v_longlog
                    || '|'
                    || LPAD ( 'PROCESS_ID'
                            , LENGTH ( NVL ( v_procid, 'PROCESS_ID' ) )
                            , ' ' );
                v_longlog :=
                       v_longlog
                    || '|'
                    || LPAD ( 'STATUS'
                            , LENGTH ( NVL ( v_status, 'STATUS' ) )
                            , ' ' );
                v_longlog :=
                       v_longlog
                    || '|'
                    || LPAD ( 'DESCR'
                            , LENGTH ( NVL ( v_descr, 'DESCR' ) )
                            , ' ' );
                v_longlog :=
                       v_longlog
                    || '|'
                    || LPAD ( 'DATA_INI'
                            , LENGTH ( NVL ( v_data_ini, 'DATA_INI' ) )
                            , ' ' );
                v_longlog :=
                       v_longlog
                    || '|'
                    || LPAD ( 'DATA_FIM'
                            , LENGTH ( NVL ( v_data_fim, 'DATA_FIM' ) )
                            , ' ' );

                lib_proc.add ( 'PROCINST|       DATA E HORA ' || v_longlog );
                v_longlog :=
                       '|'
                    || LPAD ( NVL ( v_user, ' ' )
                            , LENGTH ( NVL ( v_user, 'USER' ) )
                            , ' ' );
                v_longlog :=
                       v_longlog
                    || '|'
                    || LPAD ( NVL ( v_procid, ' ' )
                            , LENGTH ( NVL ( v_procid, 'PROCESS_ID' ) )
                            , ' ' );
                v_longlog :=
                       v_longlog
                    || '|'
                    || LPAD ( NVL ( v_status, ' ' )
                            , LENGTH ( NVL ( v_status, 'STATUS' ) )
                            , ' ' );
                v_longlog :=
                       v_longlog
                    || '|'
                    || LPAD ( NVL ( v_descr, ' ' )
                            , LENGTH ( NVL ( v_descr, 'DESCR' ) )
                            , ' ' );
                v_longlog :=
                       v_longlog
                    || '|'
                    || LPAD ( NVL ( v_data_ini, ' ' )
                            , LENGTH ( NVL ( v_data_ini, 'DATA_INI' ) )
                            , ' ' );
                v_longlog :=
                       v_longlog
                    || '|'
                    || LPAD ( NVL ( v_data_fim, ' ' )
                            , LENGTH ( NVL ( v_data_fim, 'DATA_FIM' ) )
                            , ' ' );
                lib_proc.add ( v_proci || '|' || v_procd || v_longlog );

                IF TRIM ( v_detalhes1 || v_detalhes2 || v_detalhes3 || v_detalhes4 ) IS NOT NULL THEN
                    v_longlog :=
                           '|'
                        || LPAD ( 'DETALHES1'
                                , LENGTH ( NVL ( v_detalhes1, 'DETALHES1' ) )
                                , ' ' );
                    v_longlog :=
                           v_longlog
                        || '|'
                        || LPAD ( 'DETALHES2'
                                , LENGTH ( NVL ( v_detalhes2, 'DETALHES2' ) )
                                , ' ' );
                    v_longlog :=
                           v_longlog
                        || '|'
                        || LPAD ( 'DETALHES3'
                                , LENGTH ( NVL ( v_detalhes3, 'DETALHES3' ) )
                                , ' ' );
                    v_longlog :=
                           v_longlog
                        || '|'
                        || LPAD ( 'DETALHES4'
                                , LENGTH ( NVL ( v_detalhes4, 'DETALHES4' ) )
                                , ' ' );
                    lib_proc.add ( 'Detalhes: ' || v_longlog );
                    v_longlog :=
                           '|'
                        || LPAD ( NVL ( v_detalhes1, ' ' )
                                , LENGTH ( NVL ( v_detalhes1, 'DETALHES1' ) )
                                , ' ' );
                    v_longlog :=
                           v_longlog
                        || '|'
                        || LPAD ( NVL ( v_detalhes2, ' ' )
                                , LENGTH ( NVL ( v_detalhes2, 'DETALHES2' ) )
                                , ' ' );
                    v_longlog :=
                           v_longlog
                        || '|'
                        || LPAD ( NVL ( v_detalhes3, ' ' )
                                , LENGTH ( NVL ( v_detalhes3, 'DETALHES3' ) )
                                , ' ' );
                    v_longlog :=
                           v_longlog
                        || '|'
                        || LPAD ( NVL ( v_detalhes4, ' ' )
                                , LENGTH ( NVL ( v_detalhes4, 'DETALHES4' ) )
                                , ' ' );
                    lib_proc.add ( '          ' || v_longlog );
                END IF;

                lib_proc.add ( ' ' );
                lib_proc.add ( 'LOG_SEQ|         DATA E HORA |   TIPO |Texto + dados' );
                lib_proc.add (
                               '-------|---------------------|--------|----------------------------------------------------------------------------------------------------'
                );

                FOR c1 IN c_log_01 ( p_proc ( iproc ) ) LOOP
                    v_longlog :=
                        LPAD ( TO_CHAR ( c1.log_seq
                                       , 'FM9999999' )
                             , 7
                             , ' ' );
                    v_longlog :=
                           v_longlog
                        || '|'
                        || LPAD ( NVL ( TO_CHAR ( c1.log_dttm
                                                , 'DD/MM/YYYY HH24:MI:SS' )
                                      , ' ' )
                                , 21
                                , ' ' );
                    v_longlog :=
                           v_longlog
                        || '|'
                        || LPAD ( NVL ( c1.log_type, ' ' )
                                , 8
                                , ' ' );
                    v_longlog :=
                           v_longlog
                        || '|'
                        || NVL ( SUBSTR ( c1.log_text
                                        , 1
                                        , 700 )
                               , ' ' );

                    IF (    c1.log_data1
                         || c1.log_data2
                         || c1.log_data3
                         || c1.log_data4
                         || c1.log_data5
                         || c1.log_data6
                         || c1.log_data7
                         || c1.log_data8
                         || c1.log_data9
                         || c1.log_dataa
                         || c1.log_datab
                         || c1.log_datac
                         || c1.log_datad
                         || c1.log_datae
                         || c1.log_dataf )
                           IS NOT NULL THEN
                        v_longlog := v_longlog || '|' || NVL ( c1.log_data1, ' ' );

                        IF (    c1.log_data2
                             || c1.log_data3
                             || c1.log_data4
                             || c1.log_data5
                             || c1.log_data6
                             || c1.log_data7
                             || c1.log_data8
                             || c1.log_data9
                             || c1.log_dataa
                             || c1.log_datab
                             || c1.log_datac
                             || c1.log_datad
                             || c1.log_datae
                             || c1.log_dataf )
                               IS NOT NULL THEN
                            v_longlog := v_longlog || '|' || NVL ( c1.log_data2, ' ' );

                            IF (    c1.log_data3
                                 || c1.log_data4
                                 || c1.log_data5
                                 || c1.log_data6
                                 || c1.log_data7
                                 || c1.log_data8
                                 || c1.log_data9
                                 || c1.log_dataa
                                 || c1.log_datab
                                 || c1.log_datac
                                 || c1.log_datad
                                 || c1.log_datae
                                 || c1.log_dataf )
                                   IS NOT NULL THEN
                                v_longlog := v_longlog || '|' || NVL ( c1.log_data3, ' ' );

                                IF (    c1.log_data4
                                     || c1.log_data5
                                     || c1.log_data6
                                     || c1.log_data7
                                     || c1.log_data8
                                     || c1.log_data9
                                     || c1.log_dataa
                                     || c1.log_datab
                                     || c1.log_datac
                                     || c1.log_datad
                                     || c1.log_datae
                                     || c1.log_dataf )
                                       IS NOT NULL THEN
                                    v_longlog := v_longlog || '|' || NVL ( c1.log_data4, ' ' );

                                    IF (    c1.log_data5
                                         || c1.log_data6
                                         || c1.log_data7
                                         || c1.log_data8
                                         || c1.log_data9
                                         || c1.log_dataa
                                         || c1.log_datab
                                         || c1.log_datac
                                         || c1.log_datad
                                         || c1.log_datae
                                         || c1.log_dataf )
                                           IS NOT NULL THEN
                                        v_longlog := v_longlog || '|' || NVL ( c1.log_data5, ' ' );

                                        IF (    c1.log_data6
                                             || c1.log_data7
                                             || c1.log_data8
                                             || c1.log_data9
                                             || c1.log_dataa
                                             || c1.log_datab
                                             || c1.log_datac
                                             || c1.log_datad
                                             || c1.log_datae
                                             || c1.log_dataf )
                                               IS NOT NULL THEN
                                            v_longlog := v_longlog || '|' || NVL ( c1.log_data6, ' ' );

                                            IF (    c1.log_data7
                                                 || c1.log_data8
                                                 || c1.log_data9
                                                 || c1.log_dataa
                                                 || c1.log_datab
                                                 || c1.log_datac
                                                 || c1.log_datad
                                                 || c1.log_datae
                                                 || c1.log_dataf )
                                                   IS NOT NULL THEN
                                                v_longlog :=
                                                    SUBSTR ( v_longlog || '|' || NVL ( c1.log_data7, ' ' )
                                                           , 1
                                                           , 1024 );

                                                IF (    c1.log_data8
                                                     || c1.log_data9
                                                     || c1.log_dataa
                                                     || c1.log_datab
                                                     || c1.log_datac
                                                     || c1.log_datad
                                                     || c1.log_datae
                                                     || c1.log_dataf )
                                                       IS NOT NULL THEN
                                                    v_longlog :=
                                                        SUBSTR ( v_longlog || '|' || NVL ( c1.log_data8, ' ' )
                                                               , 1
                                                               , 1024 );

                                                    IF (    c1.log_data9
                                                         || c1.log_dataa
                                                         || c1.log_datab
                                                         || c1.log_datac
                                                         || c1.log_datad
                                                         || c1.log_datae
                                                         || c1.log_dataf )
                                                           IS NOT NULL THEN
                                                        v_longlog :=
                                                            SUBSTR ( v_longlog || '|' || NVL ( c1.log_data9, ' ' )
                                                                   , 1
                                                                   , 1024 );

                                                        IF (    c1.log_dataa
                                                             || c1.log_datab
                                                             || c1.log_datac
                                                             || c1.log_datad
                                                             || c1.log_datae
                                                             || c1.log_dataf )
                                                               IS NOT NULL THEN
                                                            v_longlog :=
                                                                SUBSTR ( v_longlog || '|' || NVL ( c1.log_dataa, ' ' )
                                                                       , 1
                                                                       , 1024 );

                                                            IF (    c1.log_datab
                                                                 || c1.log_datac
                                                                 || c1.log_datad
                                                                 || c1.log_datae
                                                                 || c1.log_dataf )
                                                                   IS NOT NULL THEN
                                                                v_longlog :=
                                                                    SUBSTR (
                                                                                v_longlog
                                                                             || '|'
                                                                             || NVL ( c1.log_datab, ' ' )
                                                                           , 1
                                                                           , 1024
                                                                    );

                                                                IF (    c1.log_datac
                                                                     || c1.log_datad
                                                                     || c1.log_datae
                                                                     || c1.log_dataf )
                                                                       IS NOT NULL THEN
                                                                    v_longlog :=
                                                                        SUBSTR (
                                                                                    v_longlog
                                                                                 || '|'
                                                                                 || NVL ( c1.log_datac, ' ' )
                                                                               , 1
                                                                               , 1024
                                                                        );

                                                                    IF ( c1.log_datad || c1.log_datae || c1.log_dataf )
                                                                           IS NOT NULL THEN
                                                                        v_longlog :=
                                                                            SUBSTR (
                                                                                        v_longlog
                                                                                     || '|'
                                                                                     || NVL ( c1.log_datad, ' ' )
                                                                                   , 1
                                                                                   , 1024
                                                                            );

                                                                        IF ( c1.log_datae || c1.log_dataf ) IS NOT NULL THEN
                                                                            v_longlog :=
                                                                                SUBSTR (
                                                                                            v_longlog
                                                                                         || '|'
                                                                                         || NVL ( c1.log_datae, ' ' )
                                                                                       , 1
                                                                                       , 1024
                                                                                );

                                                                            IF ( c1.log_dataf ) IS NOT NULL THEN
                                                                                v_longlog :=
                                                                                    SUBSTR (
                                                                                                v_longlog
                                                                                             || '|'
                                                                                             || NVL ( c1.log_dataf
                                                                                                    , ' ' )
                                                                                           , 1
                                                                                           , 1024
                                                                                    );
                                                                            END IF; --V_LONGLOG := SUBSTR(V_LONGLOG || '|' || NVL(C1.LOG_DATAF,' ') ,1,1024);
                                                                        END IF; --V_LONGLOG := SUBSTR(V_LONGLOG || '|' || NVL(C1.LOG_DATAE,' ') ,1,1024);
                                                                    END IF; --V_LONGLOG := SUBSTR(V_LONGLOG || '|' || NVL(C1.LOG_DATAD,' ') ,1,1024);
                                                                END IF; --V_LONGLOG := SUBSTR(V_LONGLOG || '|' || NVL(C1.LOG_DATAC,' ') ,1,1024);
                                                            END IF; --V_LONGLOG := SUBSTR(V_LONGLOG || '|' || NVL(C1.LOG_DATAB,' ') ,1,1024);
                                                        END IF; --V_LONGLOG := SUBSTR(V_LONGLOG || '|' || NVL(C1.LOG_DATAA,' ') ,1,1024);
                                                    END IF; --V_LONGLOG := SUBSTR(V_LONGLOG || '|' || NVL(C1.LOG_DATA9,' ') ,1,1024);
                                                END IF; --V_LONGLOG := SUBSTR(V_LONGLOG || '|' || NVL(C1.LOG_DATA8,' ') ,1,1024);
                                            END IF; --V_LONGLOG := SUBSTR(V_LONGLOG || '|' || NVL(C1.LOG_DATA7,' ') ,1,1024);
                                        END IF; --V_LONGLOG :=        V_LONGLOG || '|' || NVL(C1.LOG_DATA6,' ');
                                    END IF; --V_LONGLOG :=        V_LONGLOG || '|' || NVL(C1.LOG_DATA5,' ');
                                END IF; --V_LONGLOG :=        V_LONGLOG || '|' || NVL(C1.LOG_DATA4,' ');
                            END IF; --V_LONGLOG :=        V_LONGLOG || '|' || NVL(C1.LOG_DATA3,' ');
                        END IF; --V_LONGLOG :=        V_LONGLOG || '|' || NVL(C1.LOG_DATA2,' ');
                    END IF; --V_LONGLOG :=        V_LONGLOG || '|' || NVL(C1.LOG_DATA1,' ');

                    lib_proc.add ( v_longlog );
                END LOOP;

                iproc := p_proc.NEXT ( iproc );
                lib_proc.new_page ( );
            END LOOP;

            v_proc_status := 2; --SUCESSO
        ----------------------------------------------------------------------------------------------------------
        ELSIF p_acao = '2' THEN --UNION SELECT 2,''Calcular estatisticas - todos'' FROM DUAL
            loga ( 'Calculando estatisticas das tabelas de LOG' );
            msafi.dsp_control.calcstats ( );
            loga ( 'Fim do cálculo' );
            v_proc_status := 2; --SUCESSO
        ----------------------------------------------------------------------------------------------------------
        ELSIF p_acao = '3' THEN --UNION SELECT 3,''Limpar log especifico'' FROM DUAL
            IF p_proc.COUNT <= 0 THEN
                loga ( 'Escolha ao menos um processo para limpar!' );
                lib_proc.close;
                RETURN mproc_id;
            END IF;

            iproc := p_proc.FIRST;
            loga (    'Limpando logs, processos: ['
                   || TO_CHAR ( p_proc.COUNT
                              , 'fm99999' )
                   || ']' );

            WHILE iproc IS NOT NULL LOOP
                DELETE FROM msafi.dsp_log
                      WHERE process_instance = p_proc ( iproc );

                loga (    'Limpando logs do processo: ['
                       || TO_CHAR ( p_proc ( iproc )
                                  , 'fm99999' )
                       || '] linhas excluídas: ['
                       || TO_CHAR ( SQL%ROWCOUNT
                                  , 'fm9999999999' )
                       || ']' );
                COMMIT;
                iproc := p_proc.NEXT ( iproc );
            END LOOP;

            v_proc_status := 2; --SUCESSO
        ----------------------------------------------------------------------------------------------------------
        ELSIF p_acao = '4' THEN --UNION SELECT 4,''Limpar logs - todos, manter apenas ultimos 30 dias'' FROM DUAL
            loga ( 'Limpando LOGs mais antigos que 30 dias' );
            msafi.dsp_control.limpalogs ( );
            loga ( 'Fim da limpeza' );
            v_proc_status := 2; --SUCESSO
        ----------------------------------------------------------------------------------------------------------
        ELSIF p_acao = '5' THEN --UNION SELECT 5,''Marcar logs EM PROCESSO como ERRO'' FROM DUAL
            loga ( 'Marcar como ERRO' );

            IF p_proc.COUNT <= 0 THEN
                loga ( 'Escolha ao menos um processo para marcar como erro!' );
                lib_proc.close;
                RETURN mproc_id;
            END IF;

            iproc := p_proc.FIRST;
            loga (    'Marcando logs como erro, processos: ['
                   || TO_CHAR ( p_proc.COUNT
                              , 'fm99999' )
                   || ']' );

            WHILE iproc IS NOT NULL LOOP
                UPDATE msafi.dsp_process_info
                   SET status = 'ERRO'
                 WHERE process_instance = p_proc ( iproc )
                   AND status = 'EM PROCESSO';

                loga (    'Marcando log como erro, processo: ['
                       || TO_CHAR ( p_proc ( iproc )
                                  , 'fm99999' )
                       || '] linhas atualizadas: ['
                       || TO_CHAR ( SQL%ROWCOUNT
                                  , 'fm9999999999' )
                       || ']' );
                COMMIT;
                iproc := p_proc.NEXT ( iproc );
            END LOOP;

            loga ( 'Fim do processamento' );
            v_proc_status := 2; --SUCESSO
        ----------------------------------------------------------------------------------------------------------
        END IF; --IF P_RELATORIO 1 THEN ... ELSIF ...


        v_s_proc_status :=
            CASE v_proc_status
                WHEN 0 THEN 'ERROI#0' --NUNCA DEVE SER 0, POIS JÁ VIRA 1 NO INÍCIO!
                WHEN 1 THEN 'ERROI#1' --AINDA ESTÁ EM PROCESSO!??!? ERRO NO PROCESSO!
                WHEN 2 THEN 'SUCESSO'
                WHEN 3 THEN 'AVISOS'
                WHEN 4 THEN 'ERRO'
                ELSE 'ERROI#' || v_proc_status
            END;

        loga ( 'FIM DO PROCESSAMENTO, STATUS FINAL: [' || v_s_proc_status || ']' );
        lib_proc.close ( );

        COMMIT;
        RETURN mproc_id;
    /*    EXCEPTION
            WHEN OTHERS THEN
                LIB_PROC.add_log('Erro não tratado: ' || SQLERRM, 1);
                LIB_PROC.CLOSE;
                COMMIT;
                RETURN MPROC_ID;*/
    END; /* FUNCTION EXECUTAR */
END dsp_logs_dsp_cproc;
/
SHOW ERRORS;
