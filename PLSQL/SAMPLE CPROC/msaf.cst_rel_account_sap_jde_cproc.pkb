Prompt Package Body CST_REL_ACCOUNT_SAP_JDE_CPROC;
--
-- CST_REL_ACCOUNT_SAP_JDE_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY cst_rel_account_sap_jde_cproc
IS
    mcod_empresa empresa.cod_empresa%TYPE;
    mproc_id INTEGER;

    v_class VARCHAR2 ( 1 ) := 'A';
    v_text01 VARCHAR2 ( 10000 );

    v_sel_data_fim VARCHAR2 ( 260 )
        := ' SELECT TRUNC( TO_DATE( :1 ,''DD/MM/YYYY'') + ROWNUM - 1) AS DATA_FIM, TRUNC( TO_DATE( :1 ,''DD/MM/YYYY'') + ROWNUM - 1) AS DATA_FIM FROM DUAL CONNECT BY ROWNUM <= LAST_DAY( TO_DATE( :1 ,''DD/MM/YYYY'') ) - TO_DATE( :1 ,''DD/MM/YYYY'') + 1 ORDER BY 1 DESC ';

    --Tipo, Nome e Descrição do Customizado
    mnm_tipo VARCHAR2 ( 100 ) := 'Conferencia';
    mnm_cproc VARCHAR2 ( 100 ) := 'Relatorio de valor lancamentos contabeis por conta SAP x JDE';
    mds_cproc VARCHAR2 ( 100 ) := mnm_cproc;

    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );
    BEGIN
        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        --1
        msaf.lib_proc.add_param ( pstr
                                , 'Data Inicial'
                                , --P_DATA_INI
                                 'DATE'
                                , 'TEXTBOX'
                                , 'S'
                                , NULL
                                , 'DD/MM/YYYY' );

        --2
        lib_proc.add_param ( pparam => pstr
                           , ptitulo => 'Data Final'
                           , --P_DT_FIM
                            ptipo => 'VARCHAR2'
                           , pcontrole => 'COMBOBOX'
                           , pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => '##########'
                           , pvalores => v_sel_data_fim );

        --3
        lib_proc.add_param (
                             pparam => pstr
                           , ptitulo => 'Empresa'
                           , -- P_UF
                            ptipo => 'VARCHAR2'
                           , pcontrole => 'COMBOBOX'
                           , pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => '####################'
                           , pvalores =>    'SELECT COD_EMPRESA, COD_EMPRESA || '' - '' || RAZAO_SOCIAL TXT FROM EMPRESA '
                                         || '  ORDER BY 1'
                           , phabilita => 'S'
        );

        RETURN pstr;
    END; --FUNCTION PARAMETROS RETURN VARCHAR2 IS

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
        RETURN 'CONFERENCIA';
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
        dbms_output.put_line ( p_i_texto );

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

    --PROCEDURE DELETE_TEMP_TBL

    PROCEDURE grava ( p_texto VARCHAR2
                    , p_tipo VARCHAR2 DEFAULT '1' )
    IS
    BEGIN
        lib_proc.add ( p_texto
                     , ptipo => p_tipo );
    END;

    PROCEDURE cabecalho_analitico ( p_cod_empresa VARCHAR2
                                  , p_tipo VARCHAR2 DEFAULT '1' )
    IS
        v_cl_02 VARCHAR2 ( 6 ) := '55AA55';
    BEGIN
        grava ( acc_planilha.linha (    acc_planilha.campo ( 'Movimentação Contábil Origem SAP '
                                                           , p_custom => 'COLSPAN=4' )
                                     || --
                                       ''
                                   , p_class => 'B' )
              , p_tipo );

        grava ( acc_planilha.linha (    acc_planilha.campo ( ''
                                                           , p_custom => 'COLSPAN=4' )
                                     || --
                                       ''
                                   , p_class => 'B' )
              , p_tipo );

        grava ( acc_planilha.linha (    acc_planilha.campo ( 'Empresa: ' || p_cod_empresa
                                                           , p_custom => 'COLSPAN=4' )
                                     || --
                                       ''
                                   , p_class => 'B' )
              , p_tipo );

        grava ( acc_planilha.linha (    acc_planilha.campo ( ''
                                                           , p_custom => 'COLSPAN=4' )
                                     || --
                                       ''
                                   , p_class => 'B' )
              , p_tipo );

        grava ( acc_planilha.linha (    acc_planilha.campo ( 'CONTA SAP'
                                                           , p_custom => 'BGCOLOR="#' || v_cl_02 || '"' )
                                     || --
                                       acc_planilha.campo ( 'CONTA JDE'
                                                          , p_custom => 'BGCOLOR="#' || v_cl_02 || '"' )
                                     || --
                                       acc_planilha.campo ( 'VALOR DEBITO'
                                                          , p_custom => 'BGCOLOR="#' || v_cl_02 || '"' )
                                     || --
                                       acc_planilha.campo ( 'VALOR CREDITO'
                                                          , p_custom => 'BGCOLOR="#' || v_cl_02 || '"' )
                                     || --
                                       ''
                                   , p_class => 'H' )
              , p_tipo );
    END;

    PROCEDURE grava_analitico ( vp_data_ini DATE
                              , vp_data_fim DATE
                              , p_cod_empresa VARCHAR2
                              , p_tipo VARCHAR2 DEFAULT '1' )
    IS
    BEGIN
        lib_proc.add_tipo ( mproc_id
                          , p_tipo
                          ,    'REL_ACCOUNT_SAP_JDE_'
                            || p_cod_empresa
                            || '_'
                            || TO_CHAR ( vp_data_ini
                                       , 'YYYYMM' )
                            || '.XLS'
                          , 2 );

        grava ( acc_planilha.header
              , p_tipo );
        grava ( acc_planilha.tabela_inicio
              , p_tipo );
        cabecalho_analitico ( p_cod_empresa
                            , p_tipo );

        --=========================================================
        loga ( '>> Montando relatorio'
             , FALSE );

        --=========================================================

        FOR c IN ( SELECT   *
                       FROM (SELECT   1 linha
                                    , TRIM ( SUBSTR ( x01.dsc_reservado4
                                                    , 1
                                                    ,   INSTR ( x01.dsc_reservado4
                                                              , '-' )
                                                      - 1 ) )
                                          conta_sap
                                    , x2002.cod_conta conta_jde
                                    , SUM ( CASE WHEN x01.ind_deb_cre = 'C' THEN x01.vlr_lancto ELSE 0 END ) vlr_credito
                                    , SUM ( CASE WHEN x01.ind_deb_cre = 'D' THEN x01.vlr_lancto ELSE 0 END ) vlr_debito
                                 FROM msaf.x01_contabil x01
                                    , x2002_plano_contas x2002
                                WHERE 1 = 1
                                  AND x01.ident_conta = x2002.ident_conta
                                  AND x01.cod_empresa = p_cod_empresa
                                  AND x01.data_lancto BETWEEN vp_data_ini AND vp_data_fim
                                  AND x01.cod_sistema_orig = 'SAP'
                             GROUP BY TRIM ( SUBSTR ( x01.dsc_reservado4
                                                    , 1
                                                    ,   INSTR ( x01.dsc_reservado4
                                                              , '-' )
                                                      - 1 ) )
                                    , x2002.cod_conta
                             UNION ALL
                             SELECT   2 linha
                                    , TRIM ( SUBSTR ( x01.dsc_reservado4
                                                    , 1
                                                    ,   INSTR ( x01.dsc_reservado4
                                                              , '-' )
                                                      - 1 ) )
                                          conta_sap
                                    , NULL conta_jde
                                    , SUM ( CASE WHEN x01.ind_deb_cre = 'C' THEN x01.vlr_lancto ELSE 0 END ) vlr_credito
                                    , SUM ( CASE WHEN x01.ind_deb_cre = 'D' THEN x01.vlr_lancto ELSE 0 END ) vlr_debito
                                 FROM msaf.x01_contabil x01
                                    , x2002_plano_contas x2002
                                WHERE 1 = 1
                                  AND x01.ident_conta = x2002.ident_conta
                                  AND x01.cod_empresa = p_cod_empresa
                                  AND x01.data_lancto BETWEEN vp_data_ini AND vp_data_fim
                                  AND x01.cod_sistema_orig = 'SAP'
                             GROUP BY TRIM ( SUBSTR ( x01.dsc_reservado4
                                                    , 1
                                                    ,   INSTR ( x01.dsc_reservado4
                                                              , '-' )
                                                      - 1 ) ))
                   ORDER BY conta_sap
                          , conta_jde ) LOOP
            IF v_class = 'A' THEN
                v_class := 'B';
            ELSE
                v_class := 'A';
            END IF;

            v_text01 :=
                acc_planilha.linha (
                                     p_conteudo =>    acc_planilha.campo ( c.conta_sap )
                                                   || --
                                                     acc_planilha.campo ( c.conta_jde )
                                                   || --
                                                     acc_planilha.campo ( c.vlr_credito )
                                                   || --
                                                     acc_planilha.campo ( c.vlr_debito )
                                                   || --
                                                     ''
                                   , p_class => v_class
                );

            lib_proc.add ( v_text01
                         , ptipo => p_tipo );

            COMMIT;
        END LOOP;

        grava ( acc_planilha.tabela_fim
              , p_tipo );
    END;

    FUNCTION executar ( p_data_ini DATE
                      , p_data_fim DATE
                      , p_cod_empresa VARCHAR2 )
        RETURN INTEGER
    IS
        p_tipo INTEGER := 1;
    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS='',.'' ';

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING = FORCE';

        mproc_id := lib_proc.new ( psp_nome => $$plsql_unit );

        dbms_application_info.set_module ( $$plsql_unit
                                         , 'PROC_ID: ' || mproc_id );

        loga (    'Data execução: '
               || TO_CHAR ( SYSDATE
                          , 'dd/mm/yyyy hh24:mi:ss' )
             , FALSE );
        loga ( 'Usuário: ' || musuario
             , FALSE );
        loga ( 'Empresa: ' || mcod_empresa
             , FALSE );
        loga ( 'Período: ' || p_data_ini || ' a ' || p_data_fim
             , FALSE );
        loga ( '----------------------------------------'
             , FALSE );

        grava_analitico ( p_data_ini
                        , p_data_fim
                        , p_cod_empresa
                        , p_tipo );

        lib_proc.close;
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
            COMMIT;

            lib_proc.close ( );

            RETURN mproc_id;
    END; /* FUNCTION EXECUTAR */
END cst_rel_account_sap_jde_cproc;
/
SHOW ERRORS;
