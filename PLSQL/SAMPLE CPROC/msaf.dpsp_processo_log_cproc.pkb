Prompt Package Body DPSP_PROCESSO_LOG_CPROC;
--
-- DPSP_PROCESSO_LOG_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_processo_log_cproc
IS
    mproc_id INTEGER;

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
                           , 'Data Processamento'
                           , --P_DATA_INI
                            'DATE'
                           , 'TEXTBOX'
                           , 'S'
                           , NULL
                           , 'DD/MM/YYYY' );

        lib_proc.add_param ( pstr
                           , 'Hora'
                           , --P_HORA
                            'NUMBER'
                           , 'TEXTBOX'
                           , 'S'
                           , NULL
                           , '00:00' );


        lib_proc.add_param ( pstr
                           , 'Processo'
                           , --P_PROC
                            'VARCHAR2'
                           , 'COMBOBOX'
                           , 'S'
                           , NULL
                           , NULL
                           , '
                            SELECT P.DESCRICAO, D.VALOR
                            FROM FPAR_PARAMETROS P
                            INNER JOIN FPAR_PARAM_DET D
                            ON D.ID_PARAMETRO = P.ID_PARAMETROS
                            WHERE P.NOME_FRAMEWORK = ''DPSP_PARAMETROS_LOG_CPAR''
                           '  );

        lib_proc.add_param ( pparam => pstr
                           , -- P_STATUS
                            ptitulo => 'Status'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'RADIOBUTTON'
                           , pmandatorio => 'S'
                           , pdefault => '1'
                           , pvalores => '1=Em Processamento,' || --
                                                                 '2=Concluido,' || --
                                                                                  '3=Erro' );

        lib_proc.add_param (
                             pstr
                           , 'ID Processo'
                           , --P_ID_PROCESSO
                            'VARCHAR2'
                           , 'COMBOBOX'
                           , 'S'
                           , NULL
                           , ''
                           , 'SELECT D.NU2, to_date(to_char(:1 || '' '' || (CASE WHEN LENGTH(:2 || '''') || '''' = 3 THEN 0 || SUBSTR(:2 || '''',1,1) || '':'' || SUBSTR(:2 || '''',2,3) || '''' ELSE SUBSTR(:2 || '''',1,2) || '':'' || SUBSTR(:2 || '''',3,4) || '''' END) || '''', ''dd/mm/yyyy hh24:mi'') || '''', ''dd/mm/yyyy hh24:mi'') || '''' FROM (SELECT C.NU AS NU2, (CASE WHEN (LENGTH(C.TESTE) || '''') = 3 THEN ''0'' || C.TESTE ELSE C.TESTE END) || '''' AS T2 FROM (SELECT NULL AS NU, :2 || '''' AS TESTE FROM DUAL) C)D UNION ALL SELECT B.PROC_ID, B.PROC_DATA_USUARIO FROM (select DISTINCT A.PROC_ID as PROC_ID, A.PROC_ID || '' - '' || TO_CHAR(A.DATA_INICIO, ''DD/MM/YYYY HH24:MI'') || '' - '' || A.COD_USUARIO AS PROC_DATA_USUARIO from msaf.lib_processo a, msaf.lib_proc_log b where a.sp_nome = :3 and a.data_inicio >= to_date(:1 || '' '' || (CASE WHEN LENGTH(:2 || '''') || '''' = 3 THEN 0 || SUBSTR(:2 || '''',1,1) || '':'' || SUBSTR(:2 || '''',2,3) || '''' ELSE SUBSTR(:2 || '''',1,2) || '':'' || SUBSTR(:2 || '''',3,4) || '''' END) || '''' ,''dd/mm/yyyy hh24:mi'') || '''' and a.situacao = (case when :4 || '''' = 1 then ''inicializado'' when :4 || '''' = 2 then ''encerrado'' else ''ERRO'' end) || '''' and a.proc_id = b.proc_id order BY 2 DESC) B'
        --'SELECT D.NU2, (case when substr(D.T2 || '''',1,2) > 23 then ''------------------HORA INVALIDA------------------'' WHEN substr(D.T2 || '''',3,4) > 59 THEN '' ------------------HORA INVALIDA------------------'' ELSE ''--------------------ATUALIZAR--------------------'' END) || '''' FROM (SELECT C.NU AS NU2, (CASE WHEN (LENGTH(C.TESTE) || '''') = 3 THEN ''0'' || C.TESTE ELSE C.TESTE END) || '''' AS T2 FROM (SELECT NULL AS NU, :2 || '''' AS TESTE FROM DUAL) C)D UNION ALL SELECT B.PROC_ID, B.PROC_DATA_USUARIO FROM (select DISTINCT A.PROC_ID as PROC_ID, A.PROC_ID || '' - '' || TO_CHAR(A.DATA_INICIO, ''DD/MM/YYYY HH24:MI'') || '' - '' || A.COD_USUARIO AS PROC_DATA_USUARIO from msaf.lib_processo a, msaf.lib_proc_log b where a.sp_nome = :3 and a.data_inicio >= (CASE WHEN LENGTH(:2 || '''') || '''' = 3 THEN to_date(:1 || '' '' || 0 || SUBSTR(:2 || '''',1,1) || '':'' || SUBSTR(:2 || '''',3,4) ,''dd/mm/yyyy hh24:mi'') ELSE to_date(:1 || '' '' || SUBSTR(:2 || '''',1,2) || '':'' || SUBSTR(:2 || '''',3,4) ,''dd/mm/yyyy hh24:mi'') END) || '''' and a.situacao = (case when :4 || '''' = 1 then ''inicializado'' when :4 || '''' = 2 then ''encerrado'' else ''ERRO'' end) || '''' and a.proc_id = b.proc_id order BY 2 DESC) B'
         );

        lib_proc.add_param (
                             pstr
                           , 'LOG'
                           , --P_LOG
                            'VARCHAR2'
                           , 'MULTISELECT'
                           , 'N'
                           , NULL
                           , NULL
                           , --'SELECT D.NU2, (case when substr(D.T2 || '''',1,2) > 23 then ''------------------HORA INVALIDA------------------'' WHEN substr(D.T2 || '''',3,4) > 59 THEN '' ------------------HORA INVALIDA------------------'' ELSE ''--------------------ATUALIZAR--------------------'' END) || '''' FROM (SELECT C.NU AS NU2, (CASE WHEN (LENGTH(C.TESTE) || '''') = 3 THEN ''0'' || C.TESTE ELSE C.TESTE END) || '''' AS T2 FROM (SELECT NULL AS NU, :2 || '''' AS TESTE FROM DUAL) C)D UNION ALL SELECT B.PROC_ID, B.PROC_DATA_USUARIO FROM (select DISTINCT A.PROC_ID as PROC_ID, A.PROC_ID || '' - '' || TO_CHAR(A.DATA_INICIO, ''DD/MM/YYYY HH24:MI'') || '' - '' || A.COD_USUARIO AS PROC_DATA_USUARIO from msaf.lib_processo a, msaf.lib_proc_log b where a.sp_nome = :3 and a.data_inicio >= (CASE WHEN LENGTH(:2 || '''') || '''' = 3 THEN to_date(:1 || '' '' || 0 || SUBSTR(:2 || '''',1,1) || '':'' || SUBSTR(:2 || '''',3,4) ,''dd/mm/yyyy hh24:mi'') ELSE to_date(:1 || '' '' || SUBSTR(:2 || '''',1,2) || '':'' || SUBSTR(:2 || '''',3,4) ,''dd/mm/yyyy hh24:mi'') END) || '''' and a.proc_id = b.proc_id order BY 2 DESC) B'
                             'SELECT C.PROC_ID, C.DESCR FROM (SELECT B.PROC_ID AS PROC_ID, (''DATA/HORA: '' || TO_CHAR(B.DATA, ''DD/MM/YYYY HH24:MI:SS'') || ''  ||  '' || B.TEXTO) || '''' AS DESCR FROM msaf.lib_processo a, msaf.lib_proc_log b where a.sp_nome = :3 and a.proc_id = :5 and a.proc_id = b.proc_id ORDER BY b.PROCLOG_ID DESC) C where rownum < 51'
        );

        lib_proc.add_param ( pstr
                           , ' '
                           , 'VARCHAR2'
                           , 'TEXT'
                           , 'N'
                           , 'N'
                           , NULL );

        lib_proc.add_param (
                             pstr
                           , '                                >>>>Clique em EXECUTAR para extrair o Relatorio Completo!<<<<'
                           , 'VARCHAR2'
                           , 'TEXT'
                           , 'N'
                           , 'N'
                           , NULL
        );

        RETURN pstr;
    END; --FUNCTION PARAMETROS RETURN VARCHAR2 IS

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'LOGs de Processos Ressarcimento';
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
        RETURN 'Monitorar Logs de Processos Ressarcimentos';
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
        msafi.dsp_control.writelog ( 'RRESBA'
                                   , p_i_texto );
    ---> Para acompanhar processamento usar SELECT abaixo
    --SELECT * FROM DSP_LOG
    --WHERE LOG_TYPE = 'RRESBA'
    --ORDER BY 3 DESC, 2 DESC
    ---
    END;

    FUNCTION executar ( p_data_ini DATE
                      , p_hora NUMBER
                      , p_proc VARCHAR2
                      , p_status VARCHAR2
                      , p_id_processo VARCHAR2
                      , p_log lib_proc.vartab )
        RETURN INTEGER
    IS
        mproc_id INTEGER;

        v_sql VARCHAR2 ( 10000 );


        v_text01 VARCHAR2 ( 2000 );

        v_class VARCHAR2 ( 1 ) := 'a';

        c_pmc_mva SYS_REFCURSOR;

        TYPE cur_tab_pmc_mva IS RECORD
        (
            proclog_id VARCHAR2 ( 20 )
          , proc_id VARCHAR2 ( 20 )
          , data VARCHAR2 ( 20 )
          , texto VARCHAR2 ( 1000 )
        );

        TYPE c_tab_pmc_mva IS TABLE OF cur_tab_pmc_mva;

        tab_pmc_mva c_tab_pmc_mva;
    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS='',.'' ';

        --LOGA('Incio do processamento!', FALSE);

        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );


        mproc_id :=
            lib_proc.new ( 'DPSP_PROCESSO_LOG_CPROC'
                         , 48
                         , 150 );


        lib_proc.add_tipo ( mproc_id
                          , 1
                          , mcod_empresa || '_LOG_RESSARCIMENTO.XLS'
                          , 2 );

        lib_proc.add ( dsp_planilha.header
                     , ptipo => 1 );

        lib_proc.add ( dsp_planilha.tabela_inicio
                     , ptipo => 1 );

        lib_proc.add ( dsp_planilha.linha ( p_conteudo => dsp_planilha.campo ( 'Logs dos Processos de Ressarcimentos'
                                                                             , p_custom => 'COLSPAN=4' )
                                          , p_class => 'h' )
                     , ptipo => 1 );

        lib_proc.add ( dsp_planilha.linha ( p_conteudo =>    dsp_planilha.campo ( 'PROCLOG_ID' )
                                                          || dsp_planilha.campo ( 'PROC_ID' )
                                                          || dsp_planilha.campo ( 'DATA'
                                                                                , p_width => 110 )
                                                          || dsp_planilha.campo ( 'TEXTO'
                                                                                , p_width => 500 )
                                          , p_class => 'h' )
                     , ptipo => 1 );

        v_sql := 'select b.PROCLOG_ID,';
        v_sql := v_sql || '         b.PROC_ID,';
        v_sql := v_sql || '        ('' '' || (TO_CHAR(b.DATA, ''DD/MM/YYYY HH24:MI:SS'')) || '' '') AS DATA, ';
        v_sql := v_sql || '         b.TEXTO ';
        v_sql := v_sql || '         from msaf.lib_processo a, ';
        v_sql := v_sql || '         msaf.lib_proc_log b ';
        v_sql := v_sql || '         where a.sp_nome = ''' || p_proc || ''' ';
        v_sql := v_sql || '         and a.proc_id = ''' || p_id_processo || ''' ';
        v_sql := v_sql || '         and a.proc_id = b.proc_id ';
        v_sql := v_sql || '         ORDER BY 1 DESC';


        BEGIN
            OPEN c_pmc_mva FOR v_sql;
        EXCEPTION
            WHEN OTHERS THEN
                loga ( 'SQLERRM: ' || SQLERRM
                     , FALSE );
                loga ( SUBSTR ( v_sql
                              , 1
                              , 1024 )
                     , FALSE );
                loga ( SUBSTR ( v_sql
                              , 1024
                              , 1024 )
                     , FALSE );
                loga ( SUBSTR ( v_sql
                              , 2048
                              , 1024 )
                     , FALSE );
                loga ( SUBSTR ( v_sql
                              , 3072 )
                     , FALSE );
        END;

        LOOP
            FETCH c_pmc_mva
                BULK COLLECT INTO tab_pmc_mva
                LIMIT 100;

            FOR i IN 1 .. tab_pmc_mva.COUNT LOOP
                IF v_class = 'a' THEN
                    v_class := 'b';
                ELSE
                    v_class := 'a';
                END IF;

                v_text01 :=
                    dsp_planilha.linha (
                                         p_conteudo =>    dsp_planilha.campo ( tab_pmc_mva ( i ).proclog_id )
                                                       || dsp_planilha.campo ( tab_pmc_mva ( i ).proc_id )
                                                       || dsp_planilha.campo (
                                                                               dsp_planilha.texto (
                                                                                                    tab_pmc_mva ( i ).data
                                                                               )
                                                          )
                                                       || dsp_planilha.campo ( tab_pmc_mva ( i ).texto )
                                       , p_class => v_class
                    );
                lib_proc.add ( v_text01
                             , ptipo => 1 );
            END LOOP;

            tab_pmc_mva.delete;

            EXIT WHEN c_pmc_mva%NOTFOUND;
        END LOOP;

        lib_proc.add ( dsp_planilha.tabela_fim
                     , ptipo => 1 );

        lib_proc.close ( );

        COMMIT;

        RETURN mproc_id;
    --LOGA('Fim do Processamento!', FALSE);

    END;
END dpsp_processo_log_cproc;
/
SHOW ERRORS;
