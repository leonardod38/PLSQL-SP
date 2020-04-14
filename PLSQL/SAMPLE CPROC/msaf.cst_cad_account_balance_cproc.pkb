Prompt Package Body CST_CAD_ACCOUNT_BALANCE_CPROC;
--
-- CST_CAD_ACCOUNT_BALANCE_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY cst_cad_account_balance_cproc
IS
    mcod_empresa empresa.cod_empresa%TYPE;
    musuario usuario_empresa.cod_usuario%TYPE;

    --Tipo, Nome e Descrição do Customizado
    mnm_tipo VARCHAR2 ( 100 ) := 'Conferencia Conta FC';
    mnm_cproc VARCHAR2 ( 100 ) := '01-Cadastro contas contabeis FC';
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
                           , --P_DIRETORY
                            ptitulo => 'Funcionalidade'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'RadioButton'
                           , pmandatorio => 'S'
                           , pdefault => 'I'
                           , pmascara => NULL
                           , pvalores => 'I=Inclusao,E=Exclusao,C=Consulta'
                           , phabilita => NULL );

        lib_proc.add_param (
                             pparam => pstr
                           , --P_DIRETORY
                            ptitulo => 'Seleção Conta FC'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'combobox'
                           , pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => NULL
                           , pvalores => 'SELECT COD_CONTA_FC, COD_CONTA_FC ||''-''||DESCRICAO FROM msafi.CST_CONTA_FC order by lpad(cod_conta_FC,20,''0'') '
                           , phabilita => ' :1 = ''E'' '
        );

        msaf.lib_proc.add_param ( pstr
                                , 'Código Conta FC'
                                , --P_DATA_INI
                                 'VARCHAR2'
                                , 'TEXTBOX'
                                , 'S'
                                , NULL
                                , LPAD ( ' '
                                       , 10
                                       , ' ' )
                                , phabilita => ' :1 = ''I'' ' );

        msaf.lib_proc.add_param ( pstr
                                , 'Descrição Conta FC'
                                , --P_DATA_INI
                                 'VARCHAR2'
                                , 'TEXTBOX'
                                , 'S'
                                , NULL
                                , LPAD ( ' '
                                       , 40
                                       , ' ' )
                                , phabilita => ' :1 = ''I'' ' );

        msaf.lib_proc.add_param ( pstr
                                , 'Tipo Conta'
                                , --P_DATA_INI
                                 'VARCHAR2'
                                , 'RADIOBUTTON'
                                , 'S'
                                , NULL
                                , NULL
                                , 'A=A Analitico,S=S Sintetico'
                                , phabilita => ' :1 = ''I'' ' );

        msaf.lib_proc.add_param (
                                  pstr
                                , 'Conta de Agrupamento'
                                , --P_DATA_INI
                                 'VARCHAR2'
                                , 'COMBOBOX'
                                , 'S'
                                , NULL
                                , pvalores => 'SELECT COD_CONTA_FC , COD_CONTA_FC||''-''||DESCRICAO FROM msafi.cst_conta_fc WHERE IND_SINTETICO_ANALITICO = ''S'' ORDER BY lpad(COD_CONTA_FC,20,''0'') '
                                , phabilita => ' :1 = ''I'' AND :5 = ''A'' '
        );

        msaf.lib_proc.add_param ( pstr
                                , 'Ordem Apresentacao'
                                , --P_DATA_INI
                                 'VARCHAR2'
                                , 'TEXTBOX'
                                , 'S'
                                , NULL
                                , '               '
                                , phabilita => ' :1 = ''I''  ' );

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
                      , p_cod_conta_exc VARCHAR2
                      , p_cod_conta VARCHAR2
                      , p_descricao VARCHAR2
                      , p_sint_analitico VARCHAR2
                      , p_cod_conta_sint VARCHAR2
                      , p_ordem_apres VARCHAR2 )
        RETURN INTEGER
    IS
        mproc_id INTEGER;
        v_msg VARCHAR2 ( 4000 );
        v_existe INTEGER := 0;
    BEGIN
        -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        mproc_id := lib_proc.new ( $$plsql_unit );

        COMMIT;

        IF p_funcionalidade = 'I' THEN
            SELECT NVL ( MAX ( 1 ), 0 )
              INTO v_existe
              FROM msafi.cst_conta_fc
             WHERE cod_conta_fc = p_cod_conta;

            v_msg := p_cod_conta || ';' || --
                                          p_descricao;

            IF v_existe = 1 THEN
                loga ( 'Registro ja existe: ' || v_msg
                     , TRUE );
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
            ELSE
                INSERT INTO msafi.cst_conta_fc ( cod_conta_fc
                                               , descricao
                                               , ind_sintetico_analitico
                                               , cod_conta_fc_agrupadora
                                               , num_ordem
                                               , cod_usuario
                                               , data_criacao )
                     VALUES ( p_cod_conta
                            , p_descricao
                            , p_sint_analitico
                            , p_cod_conta_sint
                            , p_ordem_apres
                            , musuario
                            , SYSDATE );

                COMMIT;

                loga ( 'Registro ' || v_msg || ' incluido com sucesso'
                     , TRUE );
            END IF;
        END IF;

        IF p_funcionalidade = 'E' THEN
            SELECT   cod_conta_fc || '-' || --
                                           descricao --
                INTO v_msg
                FROM msafi.cst_conta_fc
               WHERE cod_conta_fc = p_cod_conta_exc
            ORDER BY LPAD ( cod_conta_fc
                          , 20
                          , '0' );

            DELETE FROM msafi.cst_conta_fc
                  WHERE cod_conta_fc = p_cod_conta_exc;

            COMMIT;

            loga ( 'Registro ' || v_msg || ' excluido com sucesso'
                 , TRUE );
        END IF;

        IF p_funcionalidade = 'C' THEN
            lib_proc.add_tipo ( mproc_id
                              , 1
                              , 'REL_PARAMETROS_CONTA_FC.xls'
                              , 2 );
            lib_proc.add ( acc_planilha.header ( )
                         , ptipo => 1 );
            lib_proc.add ( acc_planilha.tabela_inicio ( )
                         , ptipo => 1 );
            lib_proc.add ( acc_planilha.linha (
                                                   acc_planilha.campo ( 'Codigo Conta FC' )
                                                || acc_planilha.campo ( 'Descricao' )
                                                || acc_planilha.campo ( 'S/A' )
                                                || acc_planilha.campo ( 'Conta Aglutinadora' )
                                                || acc_planilha.campo ( 'Ordem Apresentacao' )
                                              , --
                                                'h'
                           )
                         , ptipo => 1 );
            COMMIT;

            FOR a IN ( -- SELECT cod_conta_fc,
                       --        descricao,
                       --        t.ind_sintetico_analitico,
                       --        t.cod_conta_fc_agrupadora,
                       --        t.num_ordem
                       --   FROM msafi.cst_conta_fc t
                       --  ORDER BY 1

                       SELECT   a.cod_conta_fc
                              , a.descricao
                              , a.ind_sintetico_analitico
                              , a.cod_conta_fc_agrupadora
                              , NVL ( a.num_ordem, b.num_ordem ) num_ordem
                           FROM msafi.cst_conta_fc a
                              , msafi.cst_conta_fc b
                          WHERE a.cod_conta_fc_agrupadora = b.cod_conta_fc(+)
                       ORDER BY num_ordem
                              , NVL ( b.num_ordem, 0 )
                              , a.cod_conta_fc ) LOOP
                lib_proc.add ( acc_planilha.linha (
                                                       acc_planilha.campo ( a.cod_conta_fc )
                                                    || acc_planilha.campo ( a.descricao )
                                                    || acc_planilha.campo ( a.ind_sintetico_analitico )
                                                    || acc_planilha.campo ( a.cod_conta_fc_agrupadora )
                                                    || acc_planilha.campo ( a.num_ordem )
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
END cst_cad_account_balance_cproc;
/
SHOW ERRORS;
