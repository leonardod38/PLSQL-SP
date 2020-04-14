Prompt Package Body DPSP_MSAF_CAT42_265_CPROC;
--
-- DPSP_MSAF_CAT42_265_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_msaf_cat42_265_cproc
IS
    vs_mcod_empresa estabelecimento.cod_empresa%TYPE;
    vs_mcod_usuario usuario_estab.cod_usuario%TYPE;
    vs_mproc_id NUMBER;

    --TIPO, NOME E DESCRIÇÃO DO CUSTOMIZADO
    mnm_tipo VARCHAR2 ( 100 ) := 'CAT 42';
    mnm_cproc VARCHAR2 ( 100 ) := 'CAT42 - Carga da SAFX265';
    mds_cproc VARCHAR2 ( 100 ) := 'Carregar SAFX265 origem arquivo TXT';

    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );
    BEGIN
        vs_mcod_usuario := lib_parametros.recuperar ( 'USUARIO' );
        vs_mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );

        lib_parametros.salvar ( 'EMPRESA'
                              , NVL ( vs_mcod_empresa, msafi.dpsp.v_empresa ) );

        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS= '',.'' ';

        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT="DD/MM/YYYY"';

        --P_DIR
        lib_proc.add_param ( pparam => pstr
                           , ptitulo => 'Diretório'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'COMBOBOX'
                           , pmandatorio => 'S'
                           , pdefault => 'MSAFIMP'
                           , pmascara => NULL
                           , pvalores => 'SELECT DIRECTORY_NAME, DIRECTORY_PATH FROM ALL_DIRECTORIES'
                           , phabilita => NULL );

        --P_FILE
        lib_proc.add_param ( pparam => pstr
                           , ptitulo => 'Máscara Arquivo (.txt)'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'TEXTBOX'
                           , pmandatorio => 'S'
                           , pdefault => 'CAT42_%%CNPJ%%_052017.txt'
                           , pmascara => NULL
                           , pvalores => NULL
                           , phabilita => NULL );

        lib_proc.add_param (
                             pparam => pstr
                           , ptitulo => 'Estabelecimentos'
                           , --P_LOJAS
                            ptipo => 'VARCHAR2'
                           , pcontrole => 'MULTISELECT'
                           , pmandatorio => ' :3 = ''N'''
                           , pdefault => NULL
                           , pmascara => NULL
                           , pvalores =>    ' SELECT COD_ESTAB COD , COD_ESTADO||'' - ''||COD_ESTAB||'' - ''||INITCAP(ENDER) ||'' ''||(CASE WHEN TIPO = ''C'' THEN ''(CD)'' END) LOJA'
                                         || --
                                           ' FROM MSAF.DSP_ESTABELECIMENTO_V WHERE 1=1 '
                                         || ' AND COD_EMPRESA = '''
                                         || vs_mcod_empresa
                                         || ''' AND COD_ESTADO = ''SP'' ORDER BY TIPO, COD_ESTAB'
        );

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
        RETURN '1.0';
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
    END;

    PROCEDURE load_archive ( vp_dir VARCHAR2
                           , vp_file VARCHAR2
                           , vp_cod_estab lib_proc.vartab )
    IS
        l_vdir VARCHAR2 ( 10000 );
        l_farquivo utl_file.file_type;
        l_vline VARCHAR2 ( 32767 );
        v_count NUMBER DEFAULT 1;
        v_rank INTEGER := 0;
        v_data_saldo VARCHAR2 ( 8 );
        v_sqlerrm VARCHAR2 ( 256 );
        v_qtd_saldo NUMBER ( 17, 3 );
        v_vlr_unit NUMBER ( 19, 6 );
        v_cnpj VARCHAR2 ( 14 );
        ---
        v_file_name VARCHAR2 ( 500 );

        ---
        TYPE t_tab_safx265 IS RECORD
        (
            cod_empresa VARCHAR2 ( 3 )
          , cod_estab VARCHAR2 ( 6 )
          , data_saldo VARCHAR2 ( 8 )
          , ind_produto VARCHAR2 ( 1 )
          , cod_produto VARCHAR2 ( 35 )
          , qtd_saldo VARCHAR2 ( 17 )
          , --17,3
           vlr_tot VARCHAR2 ( 17 )
          , --17,2
           vlr_unit VARCHAR2 ( 19 )
          , --19,6
           dat_gravacao DATE
          , pst_id NUMBER ( 10 )
        );

        TYPE t_tabx265 IS TABLE OF t_tab_safx265;

        tabx265 t_tabx265;
    BEGIN
        l_vdir := vp_dir;
        l_vline := '';
        tabx265 := t_tabx265 ( );

        --------------------------------------------------
        FOR i IN vp_cod_estab.FIRST .. vp_cod_estab.LAST LOOP
            ---OBTER CNPJ DA FILIAL
            SELECT cgc
              INTO v_cnpj
              FROM msaf.estabelecimento
             WHERE cod_empresa = msafi.dpsp.empresa
               AND cod_estab = vp_cod_estab ( i );

            ---MASCARA DEFAULT
            v_file_name :=
                REPLACE ( vp_file
                        , '%%ESTAB%%'
                        , vp_cod_estab ( i ) );
            v_file_name :=
                REPLACE ( v_file_name
                        , '%%CNPJ%%'
                        , v_cnpj );

            BEGIN
                --ABRIR ARQUIVO
                l_farquivo :=
                    utl_file.fopen ( l_vdir
                                   , v_file_name
                                   , 'R'
                                   , 32767 );

                --LER ARQUIVO
                LOOP
                    utl_file.get_line ( l_farquivo
                                      , l_vline );

                    IF ( v_count = 1
                    AND SUBSTR ( l_vline
                               , 1
                               , 4 ) = '0000' ) THEN
                        --PRIMEIRA LINHA - INFO DO BLOCO 0000
                        v_data_saldo :=
                            TO_CHAR ( LAST_DAY ( TO_DATE (    '01'
                                                           || SUBSTR ( l_vline
                                                                     , 6
                                                                     , 6 )
                                                         , 'DDMMYYYY' ) )
                                    , 'YYYYMMDD' );
                    END IF;

                    IF SUBSTR ( l_vline
                              , 1
                              , 4 ) = '1050' THEN
                        tabx265.EXTEND;
                        tabx265 ( tabx265.COUNT ).cod_empresa := msafi.dpsp.empresa;
                        tabx265 ( tabx265.COUNT ).cod_estab := vp_cod_estab ( i );
                        tabx265 ( tabx265.COUNT ).data_saldo := v_data_saldo;
                        ---
                        tabx265 ( tabx265.COUNT ).ind_produto := '1';
                        tabx265 ( tabx265.COUNT ).cod_produto :=
                            SUBSTR ( l_vline
                                   ,   INSTR ( l_vline
                                             , '|'
                                             , 1
                                             , 1 )
                                     + 1
                                   ,   INSTR ( l_vline
                                             , '|'
                                             , 1
                                             , 2 )
                                     - INSTR ( l_vline
                                             , '|'
                                             , 1
                                             , 1 )
                                     - 1 );

                        v_qtd_saldo :=
                            TO_NUMBER ( SUBSTR ( l_vline
                                               ,   INSTR ( l_vline
                                                         , '|'
                                                         , 1
                                                         , 4 )
                                                 + 1
                                               ,   INSTR ( l_vline
                                                         , '|'
                                                         , 1
                                                         , 5 )
                                                 - INSTR ( l_vline
                                                         , '|'
                                                         , 1
                                                         , 4 )
                                                 - 1 ) );

                        tabx265 ( tabx265.COUNT ).qtd_saldo :=
                            msaf.lib_format.format ( p_valor => v_qtd_saldo
                                                   , p_tipo_dados => 4
                                                   , p_tamanho => 17
                                                   , p_alinhamento => 'E'
                                                   , p_casas_decimais => 3 );

                        v_vlr_unit :=
                            TO_NUMBER ( REPLACE ( REPLACE ( SUBSTR ( l_vline
                                                                   ,   INSTR ( l_vline
                                                                             , '|'
                                                                             , 1
                                                                             , 5 )
                                                                     + 1 )
                                                          , CHR ( 13 )
                                                          , '' )
                                                , CHR ( 10 )
                                                , '' ) );

                        IF v_qtd_saldo > 0 THEN
                            v_vlr_unit :=
                                ROUND ( v_vlr_unit / v_qtd_saldo
                                      , 2 );
                        ELSE
                            v_vlr_unit := 0;
                        END IF;

                        tabx265 ( tabx265.COUNT ).vlr_unit :=
                            msaf.lib_format.format ( p_valor => v_vlr_unit
                                                   , p_tipo_dados => 4
                                                   , p_tamanho => 19
                                                   , p_alinhamento => 'E'
                                                   , p_casas_decimais => 6 );

                        tabx265 ( tabx265.COUNT ).vlr_tot :=
                            msaf.lib_format.format ( p_valor => TRUNC ( v_vlr_unit * v_qtd_saldo
                                                                      , 2 )
                                                   , p_tipo_dados => 4
                                                   , p_tamanho => 17
                                                   , p_alinhamento => 'E'
                                                   , p_casas_decimais => 2 );
                        tabx265 ( tabx265.COUNT ).dat_gravacao := SYSDATE;
                        tabx265 ( tabx265.COUNT ).pst_id := '1';
                        v_rank := v_rank + 1;
                    END IF;

                    v_count := v_count + 1;
                END LOOP;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    utl_file.fclose ( l_farquivo );

                    IF ( tabx265.COUNT > 0 ) THEN
                        FORALL i IN tabx265.FIRST .. tabx265.LAST
                            INSERT INTO safx265
                            VALUES tabx265 ( i );

                        COMMIT;
                    END IF;

                    tabx265.delete;

                    loga ( v_file_name || ' [TTL LINHAS 1050]: ' || v_rank || ' [TTL LINHAS]: ' || v_count
                         , FALSE );
                WHEN OTHERS THEN
                    v_sqlerrm := SQLERRM;

                    IF ( v_sqlerrm NOT LIKE '%ORA-29283%' ) THEN
                        loga ( '<!> NAO FOI POSSIVEL ABRIR ARQUIVO: ' || v_file_name || ' ' || SQLERRM
                             , FALSE );
                    ELSE
                        loga ( '<!> NAO FOI POSSIVEL ABRIR ARQUIVO: ' || v_file_name
                             , FALSE );
                    END IF;
            END;
        END LOOP;
    -------------------------------------------------

    END;

    FUNCTION executar ( p_dir VARCHAR2
                      , p_file VARCHAR2
                      , p_cod_estab lib_proc.vartab )
        RETURN INTEGER
    IS
        v_data_exec DATE;
    BEGIN
        vs_mcod_usuario := lib_parametros.recuperar ( 'USUARIO' );

        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT="DD/MM/YYYY"';

        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS='',.'' ';

        -- CRIAÇÃO: PROCESSO
        vs_mproc_id :=
            lib_proc.new ( psp_nome => $$plsql_unit
                         , prows => 48
                         , pcols => 200 );
        COMMIT;

        v_data_exec := SYSDATE;

        loga ( '---INICIO DO PROCESSAMENTO---'
             , FALSE );

        dbms_application_info.set_module ( $$plsql_unit
                                         , 'INICIO' );

        --=================================================
        loga ( '>> STEP 1: LENDO ARQUIVO'
             , FALSE );

        load_archive ( p_dir
                     , p_file
                     , p_cod_estab );

        loga ( '<< FIM DO STEP 1: LENDO ARQUIVO'
             , FALSE );
        --=================================================

        loga ( '---FIM DO PROCESSAMENTO---'
             , FALSE );

        COMMIT;
        lib_proc.close ( );
        RETURN vs_mproc_id;
    END;
END dpsp_msaf_cat42_265_cproc;
/
SHOW ERRORS;
