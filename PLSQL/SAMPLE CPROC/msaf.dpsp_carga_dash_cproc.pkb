Prompt Package Body DPSP_CARGA_DASH_CPROC;
--
-- DPSP_CARGA_DASH_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_carga_dash_cproc
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
                           , 'PERÍODO'
                           , --P_PERIODO
                            'DATE'
                           , 'TEXTBOX'
                           , 'S'
                           , NULL
                           , 'DD/MM/YYYY' );

        lib_proc.add_param ( pstr
                           , 'INDICADOR'
                           , --P_INDICADOR
                            'VARCHAR2'
                           , 'COMBOBOX'
                           , 'S'
                           , NULL
                           , NULL
                           , '
                            SELECT ''001'',''001 - Números Gerais do Fechamento'' FROM DUAL
                           '  );

        RETURN pstr;
    END; --FUNCTION PARAMETROS RETURN VARCHAR2 IS

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Carga para Dashboard do VALIDA Acc';
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
        RETURN 'Executar carga para Dashboard do VALIDA Acc';
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

    PROCEDURE delete_bi_tbl ( p_i_indicador IN VARCHAR2
                            , p_i_periodo IN DATE )
    IS
    BEGIN
        loga ( 'Limpando Tabela do BI...' );

        DELETE msafi.dsp_valida_bi
         WHERE cod_empresa = mcod_empresa
           AND periodo = TO_CHAR ( p_i_periodo
                                 , 'MMYYYY' )
           AND indicador_id = TO_NUMBER ( p_i_indicador );

        COMMIT;
        loga ( 'Tabela do BI Limpa para o Periodo / Indicador' );
    END;

    FUNCTION fazcampo ( p_i_campo IN VARCHAR2
                      , p_i_fill IN VARCHAR2
                      , p_i_size IN NUMBER )
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN LPAD ( NVL ( p_i_campo, ' ' )
                    , p_i_size
                    , p_i_fill );
    END;

    FUNCTION fazcampo ( p_i_campo IN NUMBER
                      , p_i_format IN VARCHAR2
                      , p_i_fill IN VARCHAR2
                      , p_i_size IN NUMBER )
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN LPAD ( NVL ( TO_CHAR ( p_i_campo
                                    , p_i_format )
                          , ' ' )
                    , p_i_size
                    , p_i_fill );
    END;

    FUNCTION fazcampo ( p_i_campo IN DATE
                      , p_i_format IN VARCHAR2
                      , p_i_fill IN VARCHAR2
                      , p_i_size IN NUMBER )
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN LPAD ( NVL ( TO_CHAR ( p_i_campo
                                    , p_i_format )
                          , ' ' )
                    , p_i_size
                    , p_i_fill );
    END;

    FUNCTION executar ( p_periodo DATE
                      , p_indicador VARCHAR2 )
        RETURN INTEGER
    IS
        mproc_id INTEGER;
        i1 INTEGER;

        v_proc_status NUMBER := 0;
        v_s_proc_status VARCHAR2 ( 16 );

        v_txt_temp VARCHAR2 ( 1024 ) := '';
        v_txt_basico VARCHAR2 ( 256 ) := '';

        --Variaveis genericas
        v_text01 VARCHAR2 ( 2000 );
        v_sep VARCHAR2 ( 1 ) := '|';

        --
        TYPE cur_typ IS REF CURSOR;

        cr_aux cur_typ;
        --
        v_ordem VARCHAR2 ( 2 );
        v_tipo VARCHAR2 ( 30 );
        v_movto VARCHAR2 ( 10 );
        v_mes2 VARCHAR2 ( 50 );
        v_mes1 VARCHAR2 ( 50 );
        v_mes VARCHAR2 ( 50 );
    BEGIN
        mproc_id :=
            lib_proc.new ( 'DPSP_CARGA_DASH_CPROC'
                         , 48
                         , 150 );
        lib_proc.add_tipo ( mproc_id
                          , 1
                          , 'Processo'
                          , 1 );
        lib_proc.add_header ( 'Executar Carga para Dashboard do VALIDA Acc'
                            , 1
                            , 1 );
        lib_proc.add ( ' ' );

        IF mcod_empresa IS NULL THEN
            lib_proc.add_log ( 'Código da empresa deve ser informado como parâmetro global.'
                             , 0 );
            lib_proc.add ( 'ERRO' );
            lib_proc.add ( 'CÓDIGO DA EMPRESA DEVE SER INFORMADO COMO PARÂMETRO GLOBAL.' );
            lib_proc.close;
            RETURN mproc_id;
        END IF;

        msafi.dsp_control.createprocess ( 'DPSP_CARGA_DASH' --P_I_PROCID            IN VARCHAR2             , --VARCHAR2(16)
                                        , 'EXEC CARGA DASH' --P_I_PROC_DESCR        IN VARCHAR2             , --VARCHAR2(64)
                                        , NULL --P_I_DATA_INI          IN DATE     DEFAULT NULL,
                                        , NULL --P_I_DATA_FIM          IN DATE     DEFAULT NULL,
                                        , p_indicador --P_I_DETALHES1         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , p_periodo --P_I_DETALHES2         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , NULL --P_I_DETALHES3         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , NULL --P_I_DETALHES4         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , musuario --P_I_USER              IN VARCHAR2 DEFAULT NULL  --VARCHAR2(64)
                                                   );
        v_proc_status := 1; --EM PROCESSO

        ------------------------------------------------------------------------------------------------------
        IF ( p_indicador = '001' ) THEN
            --LIMPAR TABELA DO BI
            delete_bi_tbl ( p_indicador
                          , p_periodo );
            ---
            loga ( '------------------------------------------------------------ CFOP' );

            v_text01 := 'SELECT     ORDEM, ';
            v_text01 := v_text01 || '           TIPO, ';
            v_text01 := v_text01 || '           MOVTO,  ';
            v_text01 := v_text01 || '           NVL(MES2_SOMA_LINHA, 0) AS MES2,  ';
            v_text01 := v_text01 || '           NVL(MES1_SOMA_LINHA, 0) AS MES1,  ';
            v_text01 := v_text01 || '           NVL(MES_SOMA_LINHA, 0) AS MES  ';
            v_text01 :=
                   v_text01
                || '   FROM (SELECT ''1'' AS ORDEM, TO_CHAR(DATA_FISCAL,''MMYYYY'') AS PERIODO, ''CFOP'' AS TIPO, DECODE(MOVTO_E_S, ''9'', ''SAIDA'', ''ENTRADA'') AS MOVTO, 1 AS LINHA  ';
            v_text01 := v_text01 || '           FROM MSAFI.DSP_IDENT_DOCTO_HIST  ';
            v_text01 := v_text01 || '           WHERE LOG_FIELD1 <> '' ''  ';
            v_text01 := v_text01 || '             AND COD_EMPRESA = ''' || mcod_empresa || ''' ';
            v_text01 :=
                   v_text01
                || '             AND DATA_FISCAL BETWEEN ADD_MONTHS(TO_DATE('''
                || p_periodo
                || ''',''DD/MM/YYYY''),-2) AND LAST_DAY(TO_DATE('''
                || p_periodo
                || ''',''DD/MM/YYYY''))  ';
            v_text01 := v_text01 || '        )  ';
            v_text01 :=
                   v_text01
                || '   PIVOT (COUNT(LINHA) AS SOMA_LINHA FOR PERIODO IN (TO_CHAR(ADD_MONTHS(TO_DATE('''
                || p_periodo
                || ''',''DD/MM/YYYY''),-2),''MMYYYY'') AS MES2,  ';
            v_text01 :=
                   v_text01
                || '                                                     TO_CHAR(ADD_MONTHS(TO_DATE('''
                || p_periodo
                || ''',''DD/MM/YYYY''),-1),''MMYYYY'') AS MES1,  ';
            v_text01 :=
                   v_text01
                || '                                                     TO_CHAR(TO_DATE('''
                || p_periodo
                || ''',''DD/MM/YYYY''),''MMYYYY'') AS MES )) ';

            OPEN cr_aux FOR v_text01;

            LOOP
                FETCH cr_aux
                    INTO v_ordem
                       , v_tipo
                       , v_movto
                       , v_mes2
                       , v_mes1
                       , v_mes;

                EXIT WHEN cr_aux%NOTFOUND;
                loga ( 'Inserindo CFOP...' );

                INSERT INTO msafi.dsp_valida_bi ( row_id
                                                , indicador_id
                                                , cod_empresa
                                                , periodo
                                                , field_value1
                                                , field_value2
                                                , field_value3
                                                , field_value4
                                                , field_value5
                                                , field_value6 )
                     VALUES ( ROUND (   dbms_random.VALUE ( 1000000000
                                                          , 9999999999999999 )
                                      + TO_CHAR ( SYSDATE
                                                , 'YYYYMMDDHH24MISS' ) )
                            , TO_NUMBER ( p_indicador )
                            , mcod_empresa
                            , TO_CHAR ( p_periodo
                                      , 'MMYYYY' )
                            , v_tipo
                            , v_movto
                            , v_mes2
                            , v_mes1
                            , v_mes
                            , v_ordem );
            END LOOP;

            COMMIT;

            CLOSE cr_aux;

            loga ( '------------------------------------------------------------ FIN' );

            v_text01 := 'SELECT     ORDEM, ';
            v_text01 := v_text01 || '           TIPO, ';
            v_text01 := v_text01 || '           MOVTO,  ';
            v_text01 := v_text01 || '           NVL(MES2_SOMA_LINHA, 0) AS MES2,  ';
            v_text01 := v_text01 || '           NVL(MES1_SOMA_LINHA, 0) AS MES1,  ';
            v_text01 := v_text01 || '           NVL(MES_SOMA_LINHA, 0) AS MES  ';
            v_text01 :=
                   v_text01
                || '   FROM (SELECT ''2'' AS ORDEM, TO_CHAR(DATA_FISCAL,''MMYYYY'') AS PERIODO, ''FIN'' AS TIPO, DECODE(MOVTO_E_S, ''9'', ''SAIDA'', ''ENTRADA'') AS MOVTO, 1 AS LINHA  ';
            v_text01 := v_text01 || '           FROM MSAFI.DSP_IDENT_DOCTO_HIST  ';
            v_text01 := v_text01 || '           WHERE LOG_FIELD2 <> '' ''  ';
            v_text01 := v_text01 || '             AND COD_EMPRESA = ''' || mcod_empresa || ''' ';
            v_text01 :=
                   v_text01
                || '             AND DATA_FISCAL BETWEEN ADD_MONTHS(TO_DATE('''
                || p_periodo
                || ''',''DD/MM/YYYY''),-2) AND LAST_DAY(TO_DATE('''
                || p_periodo
                || ''',''DD/MM/YYYY''))  ';
            v_text01 := v_text01 || '        )  ';
            v_text01 :=
                   v_text01
                || '   PIVOT (COUNT(LINHA) AS SOMA_LINHA FOR PERIODO IN (TO_CHAR(ADD_MONTHS(TO_DATE('''
                || p_periodo
                || ''',''DD/MM/YYYY''),-2),''MMYYYY'') AS MES2,  ';
            v_text01 :=
                   v_text01
                || '                                                     TO_CHAR(ADD_MONTHS(TO_DATE('''
                || p_periodo
                || ''',''DD/MM/YYYY''),-1),''MMYYYY'') AS MES1,  ';
            v_text01 :=
                   v_text01
                || '                                                     TO_CHAR(TO_DATE('''
                || p_periodo
                || ''',''DD/MM/YYYY''),''MMYYYY'') AS MES )) ';

            OPEN cr_aux FOR v_text01;

            LOOP
                FETCH cr_aux
                    INTO v_ordem
                       , v_tipo
                       , v_movto
                       , v_mes2
                       , v_mes1
                       , v_mes;

                EXIT WHEN cr_aux%NOTFOUND;
                loga ( 'Inserindo FINALIDADE...' );

                INSERT INTO msafi.dsp_valida_bi ( row_id
                                                , indicador_id
                                                , cod_empresa
                                                , periodo
                                                , field_value1
                                                , field_value2
                                                , field_value3
                                                , field_value4
                                                , field_value5
                                                , field_value6 )
                     VALUES ( ROUND (   dbms_random.VALUE ( 1000000000
                                                          , 9999999999999999 )
                                      + TO_CHAR ( SYSDATE
                                                , 'YYYYMMDDHH24MISS' ) )
                            , TO_NUMBER ( p_indicador )
                            , mcod_empresa
                            , TO_CHAR ( p_periodo
                                      , 'MMYYYY' )
                            , v_tipo
                            , v_movto
                            , v_mes2
                            , v_mes1
                            , v_mes
                            , v_ordem );
            END LOOP;

            COMMIT;

            CLOSE cr_aux;

            loga ( '------------------------------------------------------------ CST' );

            v_text01 := 'SELECT     ORDEM, ';
            v_text01 := v_text01 || '           TIPO, ';
            v_text01 := v_text01 || '           MOVTO,  ';
            v_text01 := v_text01 || '           NVL(MES2_SOMA_LINHA, 0) AS MES2,  ';
            v_text01 := v_text01 || '           NVL(MES1_SOMA_LINHA, 0) AS MES1,  ';
            v_text01 := v_text01 || '           NVL(MES_SOMA_LINHA, 0) AS MES  ';
            v_text01 :=
                   v_text01
                || '   FROM (SELECT ''3'' AS ORDEM, TO_CHAR(DATA_FISCAL,''MMYYYY'') AS PERIODO, ''CST'' AS TIPO, DECODE(MOVTO_E_S, ''9'', ''SAIDA'', ''ENTRADA'') AS MOVTO, 1 AS LINHA  ';
            v_text01 := v_text01 || '           FROM MSAFI.DSP_IDENT_DOCTO_HIST  ';
            v_text01 := v_text01 || '           WHERE LOG_FIELD3 <> '' ''  ';
            v_text01 := v_text01 || '             AND COD_EMPRESA = ''' || mcod_empresa || ''' ';
            v_text01 :=
                   v_text01
                || '             AND DATA_FISCAL BETWEEN ADD_MONTHS(TO_DATE('''
                || p_periodo
                || ''',''DD/MM/YYYY''),-2) AND LAST_DAY(TO_DATE('''
                || p_periodo
                || ''',''DD/MM/YYYY''))  ';
            v_text01 := v_text01 || '        )  ';
            v_text01 :=
                   v_text01
                || '   PIVOT (COUNT(LINHA) AS SOMA_LINHA FOR PERIODO IN (TO_CHAR(ADD_MONTHS(TO_DATE('''
                || p_periodo
                || ''',''DD/MM/YYYY''),-2),''MMYYYY'') AS MES2,  ';
            v_text01 :=
                   v_text01
                || '                                                     TO_CHAR(ADD_MONTHS(TO_DATE('''
                || p_periodo
                || ''',''DD/MM/YYYY''),-1),''MMYYYY'') AS MES1,  ';
            v_text01 :=
                   v_text01
                || '                                                     TO_CHAR(TO_DATE('''
                || p_periodo
                || ''',''DD/MM/YYYY''),''MMYYYY'') AS MES )) ';

            OPEN cr_aux FOR v_text01;

            LOOP
                FETCH cr_aux
                    INTO v_ordem
                       , v_tipo
                       , v_movto
                       , v_mes2
                       , v_mes1
                       , v_mes;

                EXIT WHEN cr_aux%NOTFOUND;
                loga ( 'Inserindo CST...' );

                INSERT INTO msafi.dsp_valida_bi ( row_id
                                                , indicador_id
                                                , cod_empresa
                                                , periodo
                                                , field_value1
                                                , field_value2
                                                , field_value3
                                                , field_value4
                                                , field_value5
                                                , field_value6 )
                     VALUES ( ROUND (   dbms_random.VALUE ( 1000000000
                                                          , 9999999999999999 )
                                      + TO_CHAR ( SYSDATE
                                                , 'YYYYMMDDHH24MISS' ) )
                            , TO_NUMBER ( p_indicador )
                            , mcod_empresa
                            , TO_CHAR ( p_periodo
                                      , 'MMYYYY' )
                            , v_tipo
                            , v_movto
                            , v_mes2
                            , v_mes1
                            , v_mes
                            , v_ordem );
            END LOOP;

            COMMIT;

            CLOSE cr_aux;

            loga ( '------------------------------------------------------------ ICMS' );

            v_text01 := 'SELECT     ORDEM, ';
            v_text01 := v_text01 || '           TIPO, ';
            v_text01 := v_text01 || '           MOVTO,  ';
            v_text01 := v_text01 || '           NVL(MES2_SOMA_LINHA, 0) AS MES2,  ';
            v_text01 := v_text01 || '           NVL(MES1_SOMA_LINHA, 0) AS MES1,  ';
            v_text01 := v_text01 || '           NVL(MES_SOMA_LINHA, 0) AS MES  ';
            v_text01 :=
                   v_text01
                || '   FROM (SELECT ''4'' AS ORDEM, TO_CHAR(DATA_FISCAL,''MMYYYY'') AS PERIODO, ''ICMS'' AS TIPO, DECODE(MOVTO_E_S, ''9'', ''SAIDA'', ''ENTRADA'') AS MOVTO, 1 AS LINHA  ';
            v_text01 := v_text01 || '           FROM MSAFI.DSP_IDENT_DOCTO_HIST  ';
            v_text01 := v_text01 || '           WHERE LOG_FIELD4 <> '' ''  ';
            v_text01 := v_text01 || '             AND COD_EMPRESA = ''' || mcod_empresa || ''' ';
            v_text01 :=
                   v_text01
                || '             AND DATA_FISCAL BETWEEN ADD_MONTHS(TO_DATE('''
                || p_periodo
                || ''',''DD/MM/YYYY''),-2) AND LAST_DAY(TO_DATE('''
                || p_periodo
                || ''',''DD/MM/YYYY''))  ';
            v_text01 := v_text01 || '        )  ';
            v_text01 :=
                   v_text01
                || '   PIVOT (COUNT(LINHA) AS SOMA_LINHA FOR PERIODO IN (TO_CHAR(ADD_MONTHS(TO_DATE('''
                || p_periodo
                || ''',''DD/MM/YYYY''),-2),''MMYYYY'') AS MES2,  ';
            v_text01 :=
                   v_text01
                || '                                                     TO_CHAR(ADD_MONTHS(TO_DATE('''
                || p_periodo
                || ''',''DD/MM/YYYY''),-1),''MMYYYY'') AS MES1,  ';
            v_text01 :=
                   v_text01
                || '                                                     TO_CHAR(TO_DATE('''
                || p_periodo
                || ''',''DD/MM/YYYY''),''MMYYYY'') AS MES )) ';

            OPEN cr_aux FOR v_text01;

            LOOP
                FETCH cr_aux
                    INTO v_ordem
                       , v_tipo
                       , v_movto
                       , v_mes2
                       , v_mes1
                       , v_mes;

                EXIT WHEN cr_aux%NOTFOUND;
                loga ( 'Inserindo ICMS...' );

                INSERT INTO msafi.dsp_valida_bi ( row_id
                                                , indicador_id
                                                , cod_empresa
                                                , periodo
                                                , field_value1
                                                , field_value2
                                                , field_value3
                                                , field_value4
                                                , field_value5
                                                , field_value6 )
                     VALUES ( ROUND (   dbms_random.VALUE ( 1000000000
                                                          , 9999999999999999 )
                                      + TO_CHAR ( SYSDATE
                                                , 'YYYYMMDDHH24MISS' ) )
                            , TO_NUMBER ( p_indicador )
                            , mcod_empresa
                            , TO_CHAR ( p_periodo
                                      , 'MMYYYY' )
                            , v_tipo
                            , v_movto
                            , v_mes2
                            , v_mes1
                            , v_mes
                            , v_ordem );
            END LOOP;

            COMMIT;

            CLOSE cr_aux;

            loga ( '------------------------------------------------------------ TOTAL CORRIGIDAS' );

            v_text01 := 'SELECT     ORDEM, ';
            v_text01 := v_text01 || '           TIPO, ';
            v_text01 := v_text01 || '           MOVTO,  ';
            v_text01 := v_text01 || '           NVL(MES2_SOMA_LINHA, 0) AS MES2,  ';
            v_text01 := v_text01 || '           NVL(MES1_SOMA_LINHA, 0) AS MES1,  ';
            v_text01 := v_text01 || '           NVL(MES_SOMA_LINHA, 0) AS MES  ';
            v_text01 :=
                   v_text01
                || '   FROM (SELECT ''5'' AS ORDEM, TO_CHAR(DATA_FISCAL,''MMYYYY'') AS PERIODO, ''TOTAL CORRIGIDAS'' AS TIPO, DECODE(MOVTO_E_S, ''9'', ''SAIDA'', ''ENTRADA'') AS MOVTO, 1 AS LINHA  ';
            v_text01 := v_text01 || '           FROM MSAFI.DSP_IDENT_DOCTO_HIST  ';
            v_text01 := v_text01 || '           WHERE COD_EMPRESA = ''' || mcod_empresa || ''' ';
            v_text01 :=
                   v_text01
                || '             AND DATA_FISCAL BETWEEN ADD_MONTHS(TO_DATE('''
                || p_periodo
                || ''',''DD/MM/YYYY''),-2) AND LAST_DAY(TO_DATE('''
                || p_periodo
                || ''',''DD/MM/YYYY''))  ';
            v_text01 := v_text01 || '        )  ';
            v_text01 :=
                   v_text01
                || '   PIVOT (COUNT(LINHA) AS SOMA_LINHA FOR PERIODO IN (TO_CHAR(ADD_MONTHS(TO_DATE('''
                || p_periodo
                || ''',''DD/MM/YYYY''),-2),''MMYYYY'') AS MES2,  ';
            v_text01 :=
                   v_text01
                || '                                                     TO_CHAR(ADD_MONTHS(TO_DATE('''
                || p_periodo
                || ''',''DD/MM/YYYY''),-1),''MMYYYY'') AS MES1,  ';
            v_text01 :=
                   v_text01
                || '                                                     TO_CHAR(TO_DATE('''
                || p_periodo
                || ''',''DD/MM/YYYY''),''MMYYYY'') AS MES )) ';

            OPEN cr_aux FOR v_text01;

            LOOP
                FETCH cr_aux
                    INTO v_ordem
                       , v_tipo
                       , v_movto
                       , v_mes2
                       , v_mes1
                       , v_mes;

                EXIT WHEN cr_aux%NOTFOUND;
                loga ( 'Inserindo TTL CORRIGIDAS...' );

                INSERT INTO msafi.dsp_valida_bi ( row_id
                                                , indicador_id
                                                , cod_empresa
                                                , periodo
                                                , field_value1
                                                , field_value2
                                                , field_value3
                                                , field_value4
                                                , field_value5
                                                , field_value6 )
                     VALUES ( ROUND (   dbms_random.VALUE ( 1000000000
                                                          , 9999999999999999 )
                                      + TO_CHAR ( SYSDATE
                                                , 'YYYYMMDDHH24MISS' ) )
                            , TO_NUMBER ( p_indicador )
                            , mcod_empresa
                            , TO_CHAR ( p_periodo
                                      , 'MMYYYY' )
                            , v_tipo
                            , v_movto
                            , v_mes2
                            , v_mes1
                            , v_mes
                            , v_ordem );
            END LOOP;

            COMMIT;

            CLOSE cr_aux;

            loga ( '------------------------------------------------------------ TOTAL IMPORTADAS' );

            v_text01 := 'SELECT     ORDEM, ';
            v_text01 := v_text01 || '           TIPO, ';
            v_text01 := v_text01 || '           MOVTO,  ';
            v_text01 := v_text01 || '           NVL(MES2_SOMA_LINHA, 0) AS MES2,  ';
            v_text01 := v_text01 || '           NVL(MES1_SOMA_LINHA, 0) AS MES1,  ';
            v_text01 := v_text01 || '           NVL(MES_SOMA_LINHA, 0) AS MES  ';
            v_text01 :=
                   v_text01
                || '   FROM (SELECT ''6'' AS ORDEM, TO_CHAR(A.DATA_FISCAL,''MMYYYY'') AS PERIODO, ''TOTAL IMPORTADAS'' AS TIPO, DECODE(A.MOVTO_E_S, ''9'', ''SAIDA'', ''ENTRADA'') AS MOVTO, 1 AS LINHA  ';
            v_text01 := v_text01 || '           FROM MSAF.DWT_DOCTO_FISCAL A,  ';
            v_text01 := v_text01 || '                MSAF.DWT_ITENS_MERC B ';
            v_text01 := v_text01 || '           WHERE A.COD_EMPRESA = ''' || mcod_empresa || ''' ';
            v_text01 :=
                   v_text01
                || '             AND A.DATA_FISCAL BETWEEN ADD_MONTHS(TO_DATE('''
                || p_periodo
                || ''',''DD/MM/YYYY''),-2) AND LAST_DAY(TO_DATE('''
                || p_periodo
                || ''',''DD/MM/YYYY''))  ';
            v_text01 :=
                   v_text01
                || '             AND A.IDENT_DOCTO IN (SELECT IDENT_DOCTO FROM MSAF.X2005_TIPO_DOCTO WHERE COD_DOCTO NOT IN (''CF'',''CF-E'',''SAT'')) ';
            v_text01 := v_text01 || '             AND A.IDENT_DOCTO_FISCAL = B.IDENT_DOCTO_FISCAL ';
            v_text01 := v_text01 || '        )  ';
            v_text01 :=
                   v_text01
                || '   PIVOT (COUNT(LINHA) AS SOMA_LINHA FOR PERIODO IN (TO_CHAR(ADD_MONTHS(TO_DATE('''
                || p_periodo
                || ''',''DD/MM/YYYY''),-2),''MMYYYY'') AS MES2,  ';
            v_text01 :=
                   v_text01
                || '                                                     TO_CHAR(ADD_MONTHS(TO_DATE('''
                || p_periodo
                || ''',''DD/MM/YYYY''),-1),''MMYYYY'') AS MES1,  ';
            v_text01 :=
                   v_text01
                || '                                                     TO_CHAR(TO_DATE('''
                || p_periodo
                || ''',''DD/MM/YYYY''),''MMYYYY'') AS MES )) ';

            OPEN cr_aux FOR v_text01;

            LOOP
                FETCH cr_aux
                    INTO v_ordem
                       , v_tipo
                       , v_movto
                       , v_mes2
                       , v_mes1
                       , v_mes;

                EXIT WHEN cr_aux%NOTFOUND;
                loga ( 'Inserindo TTL IMPORTADAS...' );

                INSERT INTO msafi.dsp_valida_bi ( row_id
                                                , indicador_id
                                                , cod_empresa
                                                , periodo
                                                , field_value1
                                                , field_value2
                                                , field_value3
                                                , field_value4
                                                , field_value5
                                                , field_value6 )
                     VALUES ( ROUND (   dbms_random.VALUE ( 1000000000
                                                          , 9999999999999999 )
                                      + TO_CHAR ( SYSDATE
                                                , 'YYYYMMDDHH24MISS' ) )
                            , TO_NUMBER ( p_indicador )
                            , mcod_empresa
                            , TO_CHAR ( p_periodo
                                      , 'MMYYYY' )
                            , v_tipo
                            , v_movto
                            , v_mes2
                            , v_mes1
                            , v_mes
                            , v_ordem );
            END LOOP;

            COMMIT;

            CLOSE cr_aux;
        END IF;

        v_proc_status := 2;

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
        lib_proc.add ( 'FIM DO PROCESSAMENTO, STATUS FINAL: [' || v_s_proc_status || ']' );
        lib_proc.add ( 'Favor verificar LOG para detalhes.' );
        msafi.dsp_control.updateprocess ( v_s_proc_status );

        lib_proc.close ( );

        COMMIT;
        RETURN mproc_id;
    EXCEPTION
        WHEN OTHERS THEN
            msafi.dsp_control.log_checkpoint ( SQLERRM
                                             , 'Erro não tratado, executador de interfaces' );
            lib_proc.add_log ( 'Erro não tratado: ' || dbms_utility.format_error_backtrace
                             , 1 );
            lib_proc.add_log ( 'SQLERRM: ' || SQLERRM
                             , 1 );
            lib_proc.add ( 'ERRO!' );
            lib_proc.add ( dbms_utility.format_error_backtrace );
            lib_proc.close;
            COMMIT;
            RETURN mproc_id;
    END; /* FUNCTION EXECUTAR */
END dpsp_carga_dash_cproc;
/
SHOW ERRORS;
