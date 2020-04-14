Prompt Package Body DPSP_FIN2662_PAR_CON_DUB_CPROC;
--
-- DPSP_FIN2662_PAR_CON_DUB_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_fin2662_par_con_dub_cproc
IS
    v_sel_data_fim VARCHAR2 ( 260 )
        := ' SELECT TRUNC( TO_DATE( :1 ,''DD/MM/YYYY'') + ROWNUM - 1) AS DATA_FIM, TRUNC( TO_DATE( :1 ,''DD/MM/YYYY'') + ROWNUM - 1) AS DATA_FIM FROM DUAL CONNECT BY ROWNUM <= LAST_DAY( TO_DATE( :1 ,''DD/MM/YYYY'') ) - TO_DATE( :1 ,''DD/MM/YYYY'') + 1 ORDER BY 1 DESC ';
    v_tab_footer VARCHAR2 ( 100 )
        := ' STORAGE (BUFFER_POOL KEEP) PCTFREE 10 NOLOGGING NOCOMPRESS CACHE TABLESPACE MSAF_WORK_TABLES ';
    mlinha VARCHAR2 ( 4000 );
    mpagina NUMBER := 0;
    p_seq NUMBER := 0;

    mproc_id INTEGER;

    --Tipo, Nome e Descrição do Customizado
    mnm_tipo VARCHAR2 ( 100 ) := 'Obrigação Estadual';
    mnm_cproc VARCHAR2 ( 100 ) := 'Parâmetro Convênio DUB-RJ ';
    mds_cproc VARCHAR2 ( 100 ) := 'Tela de parâmetros para execução do cálculo';

    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );
    BEGIN
        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        mcod_usuario := lib_parametros.recuperar ( 'USUARIO' );

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
                           , --P_ACAO
                            'Ação'
                           , 'VARCHAR2'
                           , 'RADIOBUTTON'
                           , 'S'
                           , 'I'
                           , NULL
                           , 'C=Consultar,I=Incluir,E=Excluir' );

        lib_proc.add_param ( pparam => pstr
                           , --P_CONVENIO
                            ptitulo => 'Novo Convênio'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'TEXTBOX'
                           , pmandatorio => 'N'
                           , pdefault => NULL
                           , pmascara => NULL
                           , pvalores => NULL
                           , phabilita => ' :1 = ''I'' ' );

        lib_proc.add_param (
                             pparam => pstr
                           , --P_EXCLUI
                            ptitulo => 'Excluir Convênio'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'COMBOBOX'
                           , pmandatorio => 'N'
                           , pdefault => NULL
                           , pmascara => NULL
                           , pvalores =>    'SELECT COD_CONVENIO,  COD_CONVENIO || '' - '' || DES_CONVENIO '
                                         || ' FROM MSAFI.DPSP_FIN2662_PAR_CON_DUB ORDER BY COD_CONVENIO '
                           , phabilita => ' :1 = ''E'' '
        );

        lib_proc.add_param ( pparam => pstr
                           , --P_DEPENDENCIA
                            ptitulo => 'Excluir dependências'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'CHECKBOX'
                           , pmandatorio => 'N'
                           , pdefault => 'S'
                           , pmascara => NULL
                           , pvalores => 'S=SIM'
                           , phabilita => ' :1 = ''E'' ' );

        RETURN pstr;
    END;

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
        COMMIT;
    ---
    END;

    ---------------------------------------------------------------------------------------------------------------------------------------------------------------
    PROCEDURE load_excel ( mproc_id IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 20000 );
        v_text01 VARCHAR2 ( 20000 );
        v_class VARCHAR2 ( 1 ) := 'a';
        c_conc SYS_REFCURSOR;


        TYPE cur_tab_conc IS RECORD
        (
            cod_convenio NUMBER
          , des_convenio VARCHAR2 ( 400 )
          , proc_id NUMBER
          , dat_execucao DATE
          , usr_login VARCHAR2 ( 30 )
        );

        TYPE c_tab_conc IS TABLE OF cur_tab_conc;

        tab_e c_tab_conc;
    BEGIN
        v_sql := ' SELECT ';
        v_sql := v_sql || ' COD_CONVENIO      ,  ';
        v_sql := v_sql || ' DES_CONVENIO      ,  ';
        v_sql := v_sql || ' PROC_ID           ,  ';
        v_sql := v_sql || ' DAT_EXECUCAO      ,  ';
        v_sql := v_sql || ' USR_LOGIN         ';
        v_sql := v_sql || ' FROM MSAFI.DPSP_FIN2662_PAR_CON_DUB ORDER BY 1 DESC ';


        loga ( '>>> Inicio de Consulta' || mproc_id
             , FALSE );

        lib_proc.add_tipo ( mproc_id
                          , 999
                          , mcod_empresa || '_REL_CONSULTA_PARAMETROS.XLS'
                          , 2 );

        lib_proc.add ( dsp_planilha.header
                     , ptipo => 999 );
        lib_proc.add ( dsp_planilha.tabela_inicio
                     , ptipo => 999 );

        lib_proc.add ( dsp_planilha.linha ( p_conteudo => dsp_planilha.campo ( 'PARAMETROS CADASTRADOS'
                                                                             , p_custom => 'COLSPAN=5' )
                                          , p_class => 'h' )
                     , ptipo => 999 );

        lib_proc.add ( dsp_planilha.linha (
                                            p_conteudo =>    dsp_planilha.campo ( 'COD_CONVENIO' )
                                                          || --
                                                            dsp_planilha.campo ( 'DES_CONVENIO' )
                                                          || --
                                                            dsp_planilha.campo ( 'PROC_ID' )
                                                          || --
                                                            dsp_planilha.campo ( 'DAT_EXECUCAO' )
                                                          || --
                                                            dsp_planilha.campo ( 'USR_LOGIN' )
                                          , p_class => 'h'
                       )
                     , ptipo => 999 );

        BEGIN
            OPEN c_conc FOR v_sql;
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
                raise_application_error ( -20007
                                        , '!ERRO SELECT!' );
        END;

        LOOP
            FETCH c_conc
                BULK COLLECT INTO tab_e
                LIMIT 100;

            FOR i IN 1 .. tab_e.COUNT LOOP
                IF v_class = 'a' THEN
                    v_class := 'b';
                ELSE
                    v_class := 'a';
                END IF;

                v_text01 :=
                    dsp_planilha.linha (
                                         p_conteudo =>    dsp_planilha.campo ( tab_e ( i ).cod_convenio )
                                                       || dsp_planilha.campo ( tab_e ( i ).des_convenio )
                                                       || dsp_planilha.campo ( tab_e ( i ).proc_id )
                                                       || dsp_planilha.campo ( tab_e ( i ).dat_execucao )
                                                       || dsp_planilha.campo ( tab_e ( i ).usr_login )
                                       , p_class => v_class
                    );
                lib_proc.add ( v_text01
                             , ptipo => 999 );
            END LOOP;

            tab_e.delete;

            EXIT WHEN c_conc%NOTFOUND;
        END LOOP;

        COMMIT;

        CLOSE c_conc;

        lib_proc.add ( dsp_planilha.tabela_fim
                     , ptipo => 999 );
    END load_excel;

    ---------------------------------------------------------------------------------------------------------------------------------------------------------------
    PROCEDURE insere_final ( p_acao IN VARCHAR2
                           , p_exclui IN VARCHAR2
                           , p_convenio IN VARCHAR2
                           , mproc_id IN VARCHAR2
                           , musuario IN VARCHAR2 )
    IS
    BEGIN
        IF p_acao = 'I' THEN
            SELECT MAX ( cod_convenio )
              INTO p_seq
              FROM msafi.dpsp_fin2662_par_con_dub;

            INSERT INTO msafi.dpsp_fin2662_par_con_dub
                 VALUES ( p_seq + 1
                        , p_convenio
                        , mproc_id
                        , SYSDATE
                        , musuario );

            loga ( 'REGISTRO INSERIDO!' );
            COMMIT;
        END IF;

        IF p_acao = 'E' THEN
            loga ( p_exclui );

            DELETE msafi.dpsp_fin2662_par_con_dub
             WHERE cod_convenio = p_exclui;

            loga ( 'REGISTRO DELETADO!' );
            COMMIT;
        END IF;

        IF p_acao = 'C' THEN
            load_excel ( mproc_id );
        END IF;
    END insere_final;

    ---------------------------------------------------------------------------------------------------------------------------------------------------------------
    FUNCTION executar ( p_acao VARCHAR2
                      , p_convenio VARCHAR2
                      , p_exclui VARCHAR2
                      , p_dependencia VARCHAR2 )
        RETURN INTEGER
    IS
        i1 INTEGER;

        v_proc_status NUMBER := 0;
        v_s_proc_status VARCHAR2 ( 16 );

        v_txt_temp VARCHAR2 ( 1024 ) := '';
        v_txt_basico VARCHAR2 ( 256 ) := '';

        --Variaveis genericas
        v_text01 VARCHAR2 ( 6000 );
        v_sep VARCHAR2 ( 1 ) := CHR ( 9 );
        vp_proc_instance VARCHAR2 ( 30 );

        v_count NUMBER;

        --
        TYPE cur_typ IS REF CURSOR;

        cr_cup cur_typ;

        ---
        v_data_hora_ini VARCHAR2 ( 20 );
        v_data_exec DATE;

        v_pct_medi NUMBER;
        v_pct_protege NUMBER;

        v_id_arq NUMBER := 90;
    BEGIN
        --Recuperar a empresa para o plano de execução caso não esteja sendo executado pelo
        --diretamente na tela do Mastersaf
        lib_parametros.salvar ( 'EMPRESA'
                              , NVL ( mcod_empresa, msafi.dpsp.v_empresa ) );

        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        mcod_usuario := lib_parametros.recuperar ( 'USUARIO' );

        IF mcod_usuario IS NULL THEN
            lib_parametros.salvar ( 'USUARIO'
                                  , 'AUTOMATICO' );
            mcod_usuario := lib_parametros.recuperar ( 'USUARIO' );
        END IF;

        mproc_id :=
            lib_proc.new ( $$plsql_unit
                         , 48
                         , 150 );

        lib_proc.add_tipo ( mproc_id
                          , 1
                          ,    TO_CHAR ( SYSDATE
                                       , 'YYYYMMDDHH24MISS' )
                            || '_PARAMETROS'
                          , 1 );

        --MARCAR INCIO DA EXECUCAO
        v_data_exec := SYSDATE;

        --  V_DATA_HORA_INI := TO_CHAR(V_DATA_EXEC, 'DD/MM/YYYY HH24:MI.SS');


        loga ( '<<' || mnm_cproc || '>>'
             , FALSE );
        loga ( '---INICIO DO PROCESSAMENTO---'
             , FALSE );

        insere_final ( p_acao
                     , p_exclui
                     , p_convenio
                     , mproc_id
                     , mcod_usuario );

        dbms_application_info.set_module ( $$plsql_unit
                                         , 'PROC_ID: ' || mproc_id );


        --GERAR CHAVE PROC_ID
        SELECT ROUND ( dbms_random.VALUE ( 10000000000000
                                         , 999999999999999 ) )
          INTO vp_proc_instance
          FROM DUAL;

        --   LOGA('---FIM DO PROCESSAMENTO---', FALSE);


        lib_proc.add ( ' '
                     , 1 );
        lib_proc.add ( 'FIM DO PROCESSAMENTO, STATUS FINAL: [SUCESSO]'
                     , 1 );


        --  END IF; --VALIDAR V_PCT_PROTEGE

        lib_proc.close ( );
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
            lib_proc.add ( 'ERRO!'
                         , 1 );
            lib_proc.add ( ' '
                         , 1 );
            lib_proc.add ( dbms_utility.format_error_backtrace
                         , 1 );


            lib_proc.close;
            COMMIT;
            RETURN mproc_id;
    END;
END dpsp_fin2662_par_con_dub_cproc;
/
SHOW ERRORS;
