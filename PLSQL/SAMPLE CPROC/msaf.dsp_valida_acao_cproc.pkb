Prompt Package Body DSP_VALIDA_ACAO_CPROC;
--
-- DSP_VALIDA_ACAO_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dsp_valida_acao_cproc
IS
    mcod_empresa empresa.cod_empresa%TYPE;
    musuario usuario_empresa.cod_usuario%TYPE;

    /* Create Global Temporary Table dsp_valida_estab(tip varchar2(10), cod_filtro Varchar2(6)) on commit preserve rows ; */
    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );

        v_curs_lista VARCHAR2 ( 1000 )
            :=    'SELECT DISTINCT seq_lista Grupo , '
               || --
                 ' ''Grupo: '' || seq_lista ||'
               || --
                 ' '' UF: ''|| uf_estab ||'
               || --
                 ' '' E/S: ''  || saida_entrada ||'
               || --
                 ' '' Fin:''  || finalidade ||'
               || --
                 ' '' CFO:''  || cfop ||'
               || --
                 ' '' CST:''  || cst ||'
               || --
                 ' '' QTDE:'' || COUNT(1)  '
               || --
                 '  FROM msafi.dpsp_valida_filtro t'
               || --
                 ' WHERE proc_id = :2 '
               || --
                 ' group by seq_lista,uf_estab,saida_entrada,finalidade, cfop,cst '
               || --
                 ' ORDER BY seq_lista ';
    BEGIN
        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        musuario := lib_parametros.recuperar ( 'USUARIO' );

        lib_proc.add_param ( pstr
                           , 'Periodo'
                           , 'DATE'
                           , 'TEXTBOX'
                           , 'S'
                           , NULL
                           , 'MM/YYYY' );

        lib_proc.add_param (
                             pparam => pstr
                           , --P_DIRETORY
                            ptitulo => 'Numero da Lista'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'combobox'
                           , pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => NULL
                           , pvalores =>    'SELECT DISTINCT proc_id  ,'
                                         || --
                                           '                ''Lista ''||proc_id||'' Criado: ''|| to_char(t.data_criacao,''dd/mm/yyyy hh24:mi:ss'') ||'' Usuário:''||t.cod_usuario'
                                         || --
                                           '  FROM MSAFI.dpsp_valida_filtro t'
                                         || --
                                           ' WHERE trunc(data_fiscal,''MM'') = to_date( :1 , ''dd/mm/yyyy'') '
                                         || --
                                           ' ORDER BY 1'
        );

        lib_proc.add_param ( pparam => pstr
                           , --P_DIRETORY
                            ptitulo => 'Ação'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'combobox'
                           , pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => NULL
                           , pvalores => 'select 1 cod_acao, ''TESTE'' descricao from dual'
                           , phabilita => NULL );

        lib_proc.add_param (
                             pparam => pstr
                           , --P_DIRETORY
                            ptitulo => 'Natureza Operação (Finalidade)'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'Textbox'
                           , pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => NULL
                           , pvalores => 'SELECT DISTINCT COD_NATUREZA_OP, COD_NATUREZA_OP||''-''||DESCRICAO FROM MSAF.X2006_NATUREZA_OP ORDER BY COD_NATUREZA_OP '
                           , phabilita => ' :1 = ''I'' '
        );

        lib_proc.add_param (
                             pparam => pstr
                           , --P_DIRETORY
                            ptitulo => 'CFOP'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'Textbox'
                           , pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => NULL
                           , pvalores => 'SELECT DISTINCT COD_CFO, COD_CFO||''-''||DESCRICAO FROM MSAF.X2012_COD_FISCAL ORDER BY COD_CFO '
                           , phabilita => ' :1 = ''I'' '
        );

        lib_proc.add_param (
                             pparam => pstr
                           , --P_DIRETORY
                            ptitulo => 'CST'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'combobox'
                           , pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => NULL
                           , pvalores => 'SELECT COD_SITUACAO_B, COD_SITUACAO_B||''-''||DESCRICAO FROM MSAF.Y2026_SIT_TRB_UF_B ORDER BY COD_SITUACAO_B '
                           , phabilita => ' :1 = ''I'' '
        );

        lib_proc.add_param ( pparam => pstr
                           , ptitulo => 'Grupo da Lista:'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'MULTISELECT'
                           , pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => NULL
                           , pvalores => v_curs_lista );

        RETURN pstr;
    END; --FUNCTION PARAMETROS RETURN VARCHAR2 IS

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN '04 - Processa ação no Documento Fiscal (Valida)';
    END;

    FUNCTION tipo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Valida';
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
        RETURN 'Processa ação no Documento Fiscal (Valida)';
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

    FUNCTION executar ( p_acao VARCHAR2
                      , p_lista VARCHAR2
                      , p_natureza VARCHAR2
                      , p_cfop VARCHAR2
                      , p_cst VARCHAR2 )
        RETURN INTEGER
    IS
        mproc_id INTEGER;
    BEGIN
        -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        mproc_id := lib_proc.new ( $$plsql_unit );

        COMMIT;

        IF p_acao = 1 THEN
            NULL;
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
END dsp_valida_acao_cproc;
/
SHOW ERRORS;
