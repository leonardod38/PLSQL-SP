Prompt Package Body CST_DEPARA_ACCOUNT_CPROC;
--
-- CST_DEPARA_ACCOUNT_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY cst_depara_account_cproc
IS
    mcod_empresa empresa.cod_empresa%TYPE;
    musuario usuario_empresa.cod_usuario%TYPE;

    --Tipo, Nome e Descrição do Customizado
    mnm_tipo VARCHAR2 ( 100 ) := 'Conferencia Conta FC';
    mnm_cproc VARCHAR2 ( 100 ) := '02-De/Para contas contabeis MSAF - FC';
    mds_cproc VARCHAR2 ( 100 ) := mnm_cproc;

    /* Create Global Temporary Table dsp_valida_estab(tip varchar2(10), cod_filtro Varchar2(6)) on commit preserve rows ; */
    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );
    BEGIN
        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        musuario := lib_parametros.recuperar ( 'USUARIO' );

        lib_proc.add_param ( pparam => pstr
                           , ptitulo => 'Funcionalidade'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'RadioButton'
                           , pmandatorio => 'S'
                           , pdefault => 'C'
                           , pmascara => NULL
                           , pvalores => 'I=Inclusao,E=Exclusao,C=Consulta'
                           , phabilita => NULL );

        lib_proc.add_param ( pstr
                           , 'Validade Inicial'
                           , 'DATE'
                           , 'TEXTBOX'
                           , 'S'
                           , NULL
                           , 'DD/MM/YYYY'
                           , phabilita => ' :1 = ''I'' ' );


        lib_proc.add_param (
                             pparam => pstr
                           , ptitulo => 'Seleção Conta FC'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'combobox'
                           , pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => NULL
                           , pvalores => 'SELECT COD_CONTA_FC, COD_CONTA_FC ||''-''||DESCRICAO FROM CST_CONTA_FC ORDER BY COD_CONTA_FC '
                           , phabilita => ' :1 = ''I'' '
        );

        lib_proc.add_param (
                             pparam => pstr
                           , ptitulo => 'Seleção Conta MSAF ou De/Para'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'multiselect'
                           , pmandatorio => ' :1 <> ''C'' '
                           , pdefault => NULL
                           , pmascara => NULL
                           , pvalores =>    'select DISTINCT COD_CONTA cod_conta, COD_CONTA||''-''||DESCRICAO FROM x2002_plano_contas A '
                                         || --
                                           ' WHERE A.IND_CONTA = ''A'' AND :1 = ''I'' '
                                         || --
                                           ' UNION ALL '
                                         || --
                                           ' SELECT  ROWID|| '''' , '
                                         || --
                                           '                '' Conta MSAF:'' || cod_conta_msaf || '' Conta FC:'' || '
                                         || --
                                           '                cod_conta_fc || '' Data Inicio:'' || '
                                         || --
                                           '                data_valid_inicio  '
                                         || --
                                           '  FROM cst_conta_de_para_msaf_fc a '
                                         || --
                                           ' WHERE :1 = ''E'' '
                                         || --
                                           '  ORDER BY 2 '
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

    FUNCTION executar ( p_funcionalidade VARCHAR2
                      , p_dat_valid_ini DATE
                      , p_cod_conta_fc VARCHAR2
                      , p_lista lib_proc.vartab )
        RETURN INTEGER
    IS
        mproc_id INTEGER;
        v_msg VARCHAR2 ( 4000 );
        v_existe INTEGER := 0;
        v_log_erro INTEGER := 0;
    BEGIN
        -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        mproc_id := lib_proc.new ( $$plsql_unit );

        COMMIT;

        IF p_funcionalidade = 'I' THEN
            v_log_erro := 0;

            FOR x IN p_lista.FIRST .. p_lista.LAST LOOP
                SELECT NVL ( MAX ( 1 ), 0 )
                  INTO v_existe
                  FROM cst_conta_de_para_msaf_fc
                 WHERE cod_conta_msaf = p_lista ( x );

                v_msg := p_dat_valid_ini || ';' || --
                                                  p_cod_conta_fc || ';' || --
                                                                          p_lista ( x );

                IF v_existe = 1 THEN
                    v_log_erro := 1;

                    loga ( 'Registro ja existe: ' || v_msg
                         , TRUE );
                ELSE
                    INSERT INTO cst_conta_de_para_msaf_fc ( data_valid_inicio
                                                          , cod_conta_msaf
                                                          , cod_conta_fc
                                                          , cod_usuario
                                                          , data_criacao )
                         VALUES ( p_dat_valid_ini
                                , p_lista ( x )
                                , p_cod_conta_fc
                                , musuario
                                , SYSDATE );

                    COMMIT;

                    loga ( 'Registro ' || v_msg || ' incluido com sucesso'
                         , TRUE );
                END IF;
            END LOOP;

            IF v_log_erro = 1 THEN
                lib_proc.close ( );

                UPDATE lib_processo
                   SET situacao = 'ERRO'
                 WHERE proc_id = mproc_id;

                UPDATE lib_proc_param
                   SET proc_id = mproc_id
                 WHERE proc_id IN ( SELECT proc_id_orig
                                      FROM lib_processo
                                     WHERE proc_id = mproc_id );

                DELETE lib_processo
                 WHERE proc_id IN ( SELECT proc_id_orig
                                      FROM lib_processo
                                     WHERE proc_id = mproc_id );

                COMMIT;

                RETURN mproc_id;
            END IF;
        END IF;

        IF p_funcionalidade = 'E' THEN
            FOR x IN p_lista.FIRST .. p_lista.LAST LOOP
                SELECT data_valid_inicio || '-' || --
                                                  cod_conta_msaf || '-' || --
                                                                          cod_conta_fc
                  INTO v_msg
                  FROM cst_conta_de_para_msaf_fc
                 WHERE ROWID = p_lista ( x );

                DELETE FROM cst_conta_de_para_msaf_fc
                      WHERE ROWID = p_lista ( x );

                COMMIT;

                loga ( 'Registro ' || v_msg || ' excluido com sucesso'
                     , TRUE );
            END LOOP;
        END IF;

        IF p_funcionalidade = 'C' THEN
            lib_proc.add_tipo ( mproc_id
                              , 1
                              , 'REL_DE_PARA_CONTA_FC.xls'
                              , 2 );
            lib_proc.add ( acc_planilha.header ( )
                         , ptipo => 1 );
            lib_proc.add ( acc_planilha.tabela_inicio ( )
                         , ptipo => 1 );
            lib_proc.add ( acc_planilha.linha (
                                                   acc_planilha.campo ( 'Data validade Inicial' )
                                                || acc_planilha.campo ( 'Conta MSAF' )
                                                || acc_planilha.campo ( 'Conta FC' )
                                              , --
                                                'h'
                           )
                         , ptipo => 1 );
            COMMIT;

            FOR a IN ( SELECT   data_valid_inicio
                              , cod_conta_msaf
                              , cod_conta_fc
                           FROM cst_conta_de_para_msaf_fc t
                       ORDER BY 1 ) LOOP
                lib_proc.add ( acc_planilha.linha (
                                                       acc_planilha.campo ( a.data_valid_inicio )
                                                    || acc_planilha.campo ( acc_planilha.texto ( a.cod_conta_msaf ) )
                                                    || acc_planilha.campo ( acc_planilha.texto ( a.cod_conta_fc ) )
                                                  , p_custom => 'height="17"'
                               )
                             , ptipo => 1 );
                COMMIT;
            END LOOP;

            lib_proc.add ( acc_planilha.tabela_fim ( )
                         , ptipo => 1 );

            COMMIT;
        END IF;

        lib_proc.close ( );

        COMMIT;
        RETURN mproc_id;
    EXCEPTION
        WHEN OTHERS THEN
            lib_proc.add_log ( 'Erro não tratado: ' || dbms_utility.format_error_backtrace
                             , 1 );
            lib_proc.add_log ( 'SQLERRM: ' || SQLERRM
                             , 1 );
            lib_proc.add ( 'ERRO!' );
            lib_proc.add ( dbms_utility.format_error_backtrace );
            lib_proc.close;
            COMMIT;
            RETURN mproc_id;
    END;
END cst_depara_account_cproc;
/
SHOW ERRORS;
