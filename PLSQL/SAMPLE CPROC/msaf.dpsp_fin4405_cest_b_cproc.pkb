Prompt Package Body DPSP_FIN4405_CEST_B_CPROC;
--
-- DPSP_FIN4405_CEST_B_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_fin4405_cest_b_cproc
IS
    mproc_id INTEGER;

    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );
    BEGIN
        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        mcod_estab := lib_parametros.recuperar ( 'ESTABELECIMENTO' );
        -- MUSUARIO     := LIB_PARAMETROS.RECUPERAR('USUARIO');

        -- PPARAM:      STRING PASSADA POR REFERÊNCIA;
        -- PTITULO:     TÍTULO DO PARÂMETRO MOSTRADO NA JANELA;
        -- PTIPO:       VARCHAR2, DATE, INTEGER;
        -- PCONTROLE:   MULTIPROC, TEXT, TEXTBOX, COMBOBOX, LISTBOX OU RADIOBUTTON;
        -- PMANDATORIO: S OU N, INDICANDO SE A INFORMAÇÃO DO PARÂMETRO É OBRIGATÓRIA;
        -- PDEFAULT:    VALOR PREENCHIDO AUTOMATICAMENTE NA ABERTURA DA JANELA;
        -- PMASCARA:    MÁSCARA PARA DIGITAÇÃO (EX: DD/MM/YYYY, 999999 OU ######);
        -- PVALORES:    SELECT (COMBOBOX OU MULTIPROC) OU COD1=DESC1,COD2=DESC2...
        -- PAPRESENTA:  S OU N, INDICANDO SE O PARÂMETRO DEVE SER MOSTRADO NA LISTAGEM DOS PROCESSOS;

        lib_proc.add_param (
                             pparam => pstr
                           , --P_DIRETORY
                            ptitulo => 'DIRETÓRIO'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'TEXTBOX'
                           , pmandatorio => 'S'
                           , pdefault => 'MSAFIMP'
                           , pmascara => NULL
                           , pvalores => 'SELECT DIRECTORY_NAME, DIRECTORY_PATH FROM ALL_DIRECTORIES WHERE DIRECTORY_NAME = ''MSAFIMP'' '
                           , phabilita => NULL
        );


        lib_proc.add_param ( pparam => pstr
                           , --V_FILE_ARCHIVE
                            ptitulo => 'ARQUIVO (.csv)'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'TEXTBOX'
                           , pmandatorio => 'S'
                           , pdefault => '.csv'
                           , pmascara => NULL
                           , pvalores => NULL
                           , phabilita => NULL );

        RETURN pstr;
    END; --FUNCTION PARAMETROS RETURN VARCHAR2 IS

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'UPLOAD Produtos Cesta Básica';
    END;

    FUNCTION tipo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Processos - Fiscal ';
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
        RETURN 'Upload Produtos Cesta Básica';
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
                    , musuario
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


    ------------------------------------------------------------------------------------------------------------------------------------------------------

    PROCEDURE load_archive ( p_diretory VARCHAR2
                           , v_file_archive VARCHAR2 )
    IS
        l_vdir VARCHAR2 ( 10000 );
        l_farquivo utl_file.file_type;
        l_vline VARCHAR2 ( 32767 );
        v_count NUMBER DEFAULT 1;
        p_val DATE;
    BEGIN
        l_vdir := p_diretory;
        l_vline := '';

        BEGIN
            l_farquivo :=
                utl_file.fopen ( l_vdir
                               , v_file_archive
                               , 'R'
                               , 32767 );
        EXCEPTION
            WHEN OTHERS THEN
                utl_file.fclose ( l_farquivo );
                loga ( 'ARQUIVO NÃO LOCALIZADO!!!' );
        END;

        EXECUTE IMMEDIATE 'TRUNCATE TABLE MSAFI.DPSP_AUX_CEST';

        --------------------------------------------------
        LOOP
            utl_file.get_line ( l_farquivo
                              , l_vline );

            --   insert into  msafi.dsp_log (LOG_TEXT) values(l_vline);

            IF TRIM ( REGEXP_SUBSTR ( ';' || l_vline
                                    , ';([^;]*)'
                                    , 1
                                    , 1
                                    , NULL
                                    , '1' ) ) <> 'PERIODO'
           AND REGEXP_SUBSTR ( ';' || l_vline
                             , ';([^;]*)'
                             , 1
                             , 2
                             , NULL
                             , '1' ) <> 'COD_PRODUTO'
           AND TRIM ( REGEXP_SUBSTR ( ';' || l_vline
                                    , ';([^;]*)'
                                    , 1
                                    , 3
                                    , NULL
                                    , '1' ) ) <> 'DESCRICAO' THEN
                INSERT INTO msafi.dpsp_aux_cest
                     VALUES ( TRIM ( REGEXP_SUBSTR ( ';' || l_vline
                                                   , ';([^;]*)'
                                                   , 1
                                                   , 1
                                                   , NULL
                                                   , '1' ) )
                            , REGEXP_SUBSTR ( ';' || l_vline
                                            , ';([^;]*)'
                                            , 1
                                            , 2
                                            , NULL
                                            , '1' )
                            , TRIM ( REGEXP_SUBSTR ( ';' || l_vline
                                                   , ';([^;]*)'
                                                   , 1
                                                   , 3
                                                   , NULL
                                                   , '1' ) ) );


                v_count := v_count + 1;

                COMMIT;
            END IF;

            loga ( 'INSERINDO NA TEMPORÁRIA' );
        END LOOP;

        --------------------------------------------------

        loga ( 'Total de linhas: ' || v_count
             , FALSE );
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            utl_file.fclose ( l_farquivo );
            utl_file.fclose ( l_farquivo );
    END;


    ------------------------
    PROCEDURE delete_fim ( vp_proc_instance IN NUMBER )
    IS
    BEGIN
        loga ( 'LIMPANDO REGISTROS IGUAIS !' );

        DELETE msafi.dpsp_fin4405_cest_arquivo a
         WHERE EXISTS
                   (SELECT 'X'
                      FROM msafi.dpsp_aux_cest b
                     WHERE 1 = 1
                       AND    SUBSTR ( a.periodo
                                     , 1
                                     , 2 )
                           || '/'
                           || SUBSTR ( a.periodo
                                     , 3
                                     , 6 ) =    SUBSTR ( b.periodo
                                                       , 1
                                                       , 2 )
                                             || '/'
                                             || SUBSTR ( b.periodo
                                                       , 3
                                                       , 6 )
                       AND a.cod_produto = b.cod_produto
                       AND a.descricao = b.descricao);

        COMMIT;
    END;

    ---------------------------------------------------------------------------------------------------------------------------------------------------------

    PROCEDURE load_final ( p_diretory VARCHAR2
                         , v_file_archive VARCHAR2 )
    IS
        v_count NUMBER DEFAULT 1;
    BEGIN
        delete_fim ( 1 );

        loga ( 'INSERINDO NA TABELA FINAL!' );

        --------------------------------------------------
        INSERT INTO msafi.dpsp_fin4405_cest_arquivo
            SELECT    SUBSTR ( a.periodo
                             , 1
                             , 2 )
                   || '/'
                   || SUBSTR ( a.periodo
                             , 3
                             , 6 )
                 , a.cod_produto
                 , a.descricao
              FROM msafi.dpsp_aux_cest a
             WHERE NOT EXISTS
                       (SELECT 'X'
                          FROM msafi.dpsp_fin4405_cest_arquivo b
                         WHERE 1 = 1
                           AND    SUBSTR ( a.periodo
                                         , 1
                                         , 2 )
                               || '/'
                               || SUBSTR ( a.periodo
                                         , 3
                                         , 6 ) =    SUBSTR ( b.periodo
                                                           , 1
                                                           , 2 )
                                                 || '/'
                                                 || SUBSTR ( b.periodo
                                                           , 3
                                                           , 6 )
                           AND a.cod_produto = b.cod_produto
                           AND a.descricao = b.descricao);


        COMMIT;
    --------------------------------------------------

    END;

    ---------------------------------------------------------------------------------------------------------------------------------------------------------
    FUNCTION executar ( p_diretory VARCHAR2
                      , v_file_archive VARCHAR2 )
        RETURN INTEGER
    IS
        mproc_id INTEGER;
        i1 INTEGER;

        v_proc_status NUMBER := 0;
        v_s_proc_status VARCHAR2 ( 16 );

        v_txt_temp VARCHAR2 ( 1024 ) := '';
        v_txt_basico VARCHAR2 ( 256 ) := '';

        TYPE a_estabs_t IS TABLE OF VARCHAR2 ( 6 );

        a_estabs a_estabs_t := a_estabs_t ( );

        --Variaveis genericas
        v_text01 VARCHAR2 ( 6000 );
        v_sep VARCHAR2 ( 1 ) := CHR ( 9 );
        p_proc_instance VARCHAR2 ( 30 );
        vp_proc_instance VARCHAR2 ( 30 );

        --
        TYPE cur_typ IS REF CURSOR;

        cr_cup cur_typ;
    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS='',.'' ';

        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        musuario := lib_parametros.recuperar ( 'USUARIO' );

        mproc_id :=
            lib_proc.new ( 'DPSP_FIN4405_CEST_B_CPROC'
                         , 48
                         , 150 );
        lib_proc.add_tipo ( mproc_id
                          , 1
                          ,    TO_CHAR ( SYSDATE
                                       , 'YYYYMMDDHH24MISS' )
                            || '_CESTA_BASICA'
                          , 1 );

        --MARCAR INCIO DA EXECUCAO

        lib_proc.add_header ( 'Executar upload '
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

        --GERAR CHAVE PROC_ID
        SELECT ROUND ( dbms_random.VALUE ( 10000000000000
                                         , 999999999999999 ) )
          INTO p_proc_instance
          FROM DUAL;


        --GERAR CHAVE PROC_ID
        SELECT ROUND ( dbms_random.VALUE ( 10000000000000
                                         , 999999999999999 ) )
          INTO vp_proc_instance
          FROM DUAL;

        load_archive ( p_diretory
                     , v_file_archive );
        load_final ( p_diretory
                   , v_file_archive );

        --ENVIAR EMAIL DE SUCESSO----------------------------------------
        --ENVIA_EMAIL(MCOD_EMPRESA, P_DATA_INICIAL, P_DATA_FINAL, '', 'S', V_DATA_HORA_INI);
        -----------------------------------------------------------------
        loga ( 'FIM DO PROCESSAMENTO, STATUS FINAL: [SUCESSO]'
             , FALSE );
        lib_proc.add ( 'FIM DO PROCESSAMENTO, STATUS FINAL: [SUCESSO]' );


        lib_proc.close ( );

        COMMIT;
        RETURN mproc_id;
    EXCEPTION
        WHEN OTHERS THEN
            loga ( 'SQLERRM: ' || SQLERRM
                 , FALSE );

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
END dpsp_fin4405_cest_b_cproc;
/
SHOW ERRORS;
