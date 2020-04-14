Prompt Package Body DSP_VALIDA_FILTRO_CPROC;
--
-- DSP_VALIDA_FILTRO_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dsp_valida_filtro_cproc
IS
    mcod_empresa empresa.cod_empresa%TYPE;
    musuario usuario_empresa.cod_usuario%TYPE;

    /* Create Global Temporary Table dsp_valida_estab(tip varchar2(10), cod_filtro Varchar2(6)) on commit preserve rows ; */
    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );
        v_curs_estab VARCHAR2 ( 1000 )
            :=    'Select Distinct ''LOJ'' cod_estab, '' Todas Lojas '' Descricao'
               || ' From dual union'
               || ' Select COD_ESTAB , ''(''|| TIPO || '') ''||Cod_Estado||'' - ''||COD_ESTAB||'' - ''||Initcap(ENDER)'
               || ' From dsp_estabelecimento_v where (cod_estado = :3 or :3 in (''XX''))  ORDER BY 2';

        v_curs_filtro VARCHAR2 ( 1000 )
            :=    'select rowid , cod_empresa||''-''||'
               || --
                 '  cod_estab||''-''||'
               || --
                 '  cod_estado||''-''||'
               || --
                 '  entrada_saida||''-''||'
               || --
                 '  cod_natureza_op||''-''||'
               || --
                 '  cod_cfo||''-''||'
               || --
                 '  cod_situacao_b||''-''||'
               || --
                 '  bc_icms||''-''||'
               || --
                 '  icms||''-''||'
               || --
                 '  aliq_icms||''-''||'
               || --
                 '  isentas||''-''||'
               || --
                 '  outras||''-''||'
               || --
                 '  reducao '
               || --
                 '  from MSAFI.dsp_auto_valida t '
               || --
                 '  order by 2 ';
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

        lib_proc.add_param ( pparam => pstr
                           , --P_DIRETORY
                            ptitulo => 'Seleção Perfil'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'combobox'
                           , pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => NULL
                           , pvalores => v_curs_filtro
                           , phabilita => ' :1 = ''E'' ' );

        lib_proc.add_param (
                             pparam => pstr
                           , --P_DIRETORY
                            ptitulo => 'Estado'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'combobox'
                           , pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => NULL
                           , -- pvalores    => 'Select cod_estado, Descricao from (SELECT ''CD'' cod_estado, ''Todas as UFs CD'' Descricao from dual union all SELECT ''LOJ'', ''Todas as UFs Lojas'' from dual union all SELECT DISTINCT COD_ESTADO, COD_ESTADO FROM MSAFI.DSP_ESTABELECIMENTO ) ORDER BY decode(COD_ESTADO,''CD'',''AB'',''LOJ'',''AA'',COD_ESTADO) ',
                             pvalores => 'Select cod_estado, Descricao from (SELECT ''XX'' cod_estado, ''Todas as UFs'' Descricao from dual union all SELECT DISTINCT COD_ESTADO, COD_ESTADO FROM MSAFI.DSP_ESTABELECIMENTO ) ORDER BY decode(COD_ESTADO,''XX'',''AA'',COD_ESTADO) '
                           , phabilita => ' :1 = ''I'' '
        );

        lib_proc.add_param ( pstr
                           , 'Grupo/Estabelecimentos'
                           , 'VARCHAR2'
                           , 'combobox'
                           , 'S'
                           , NULL
                           , NULL
                           , v_curs_estab
                           , phabilita => ' :1 = ''I'' ' );

        lib_proc.add_param ( pparam => pstr
                           , --P_DIRETORY
                            ptitulo => 'Entrada/Saida'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'RadioButton'
                           , pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => NULL
                           , pvalores => 'T=Todos,E=Entrada,S=Saida'
                           , phabilita => ' :1 = ''I'' ' );

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
                           , --P_DIRETORY
                            ptitulo => 'Base ICMS'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'RadioButton'
                           , pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => NULL
                           , pvalores => '0=Zero,1=Diferente zero'
                           , phabilita => ' :1 = ''I'' ' );

        lib_proc.add_param ( pparam => pstr
                           , --P_DIRETORY
                            ptitulo => 'Valor ICMS'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'RadioButton'
                           , pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => NULL
                           , pvalores => '0=Zero,1=Diferente zero'
                           , phabilita => ' :1 = ''I'' ' );

        lib_proc.add_param ( pparam => pstr
                           , --P_DIRETORY
                            ptitulo => 'Aliquota ICMS'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'RadioButton'
                           , pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => NULL
                           , pvalores => '0=Zero,1=Diferente zero'
                           , phabilita => ' :1 = ''I'' ' );

        lib_proc.add_param ( pparam => pstr
                           , --P_DIRETORY
                            ptitulo => 'Valor Isento'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'RadioButton'
                           , pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => NULL
                           , pvalores => '0=Zero,1=Diferente zero'
                           , phabilita => ' :1 = ''I'' ' );

        lib_proc.add_param ( pparam => pstr
                           , --P_DIRETORY
                            ptitulo => 'Valor Outras'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'RadioButton'
                           , pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => NULL
                           , pvalores => '0=Zero,1=Diferente zero'
                           , phabilita => ' :1 = ''I'' ' );

        lib_proc.add_param ( pparam => pstr
                           , --P_DIRETORY
                            ptitulo => 'Valor Reducao'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'RadioButton'
                           , pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => NULL
                           , pvalores => '0=Zero,1=Diferente zero'
                           , phabilita => ' :1 = ''I'' ' );

        RETURN pstr;
    END; --FUNCTION PARAMETROS RETURN VARCHAR2 IS

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN '01 - Cadastro de perfil de filtro de Documento Fiscal (Valida)';
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
        RETURN 'Cadastro de perfil de filtro de Documento Fiscal (Valida)';
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

    FUNCTION executar ( p_funcionalidade VARCHAR2
                      , p_perfil VARCHAR2
                      , p_uf VARCHAR2
                      , p_estabelecimento VARCHAR2
                      , p_tipo_mov_e_s VARCHAR2
                      , p_natureza VARCHAR2
                      , p_cfop VARCHAR2
                      , p_cst VARCHAR2
                      , p_base_icms INTEGER
                      , p_valor_icms INTEGER
                      , p_aliquota_icms INTEGER
                      , p_valor_isento INTEGER
                      , p_valor_outras INTEGER
                      , p_valor_reducao INTEGER )
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
              FROM msafi.dsp_auto_valida
             WHERE cod_empresa = msafi.dpsp.v_empresa
               AND cod_estab = p_estabelecimento
               AND cod_estado = p_uf
               AND entrada_saida = p_tipo_mov_e_s
               AND cod_natureza_op = p_natureza
               AND cod_cfo = p_cfop
               AND cod_situacao_b = p_cst
               AND bc_icms = p_base_icms
               AND icms = p_valor_icms
               AND aliq_icms = p_aliquota_icms
               AND isentas = p_valor_isento
               AND outras = p_valor_outras
               AND reducao = p_valor_reducao;

            v_msg :=
                   msafi.dpsp.v_empresa
                || ';'
                || --
                  p_estabelecimento
                || ';'
                || --
                  p_uf
                || ';'
                || --
                  p_tipo_mov_e_s
                || ';'
                || --
                  p_natureza
                || ';'
                || --
                  p_cfop
                || ';'
                || --
                  p_cst
                || ';'
                || --
                  p_base_icms
                || ';'
                || --
                  p_valor_icms
                || ';'
                || --
                  p_aliquota_icms
                || ';'
                || --
                  p_valor_isento
                || ';'
                || --
                  p_valor_outras
                || ';'
                || --
                  p_valor_reducao;

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
                INSERT INTO msafi.dsp_auto_valida ( cod_empresa
                                                  , cod_estab
                                                  , cod_estado
                                                  , entrada_saida
                                                  , cod_natureza_op
                                                  , cod_cfo
                                                  , cod_situacao_b
                                                  , bc_icms
                                                  , icms
                                                  , aliq_icms
                                                  , isentas
                                                  , outras
                                                  , reducao )
                     VALUES ( msafi.dpsp.v_empresa
                            , p_estabelecimento
                            , p_uf
                            , p_tipo_mov_e_s
                            , p_natureza
                            , p_cfop
                            , p_cst
                            , p_base_icms
                            , p_valor_icms
                            , p_aliquota_icms
                            , p_valor_isento
                            , p_valor_outras
                            , p_valor_reducao );

                COMMIT;

                loga ( 'Registro ' || v_msg || ' incluido com sucesso'
                     , TRUE );
            END IF;
        END IF;

        IF p_funcionalidade = 'E' THEN
            SELECT    cod_empresa
                   || ';'
                   || --
                     cod_estab
                   || ';'
                   || --
                     REPLACE ( cod_estado
                             , 'XX'
                             , 'Todos' )
                   || ';'
                   || --
                     entrada_saida
                   || ';'
                   || --
                     cod_natureza_op
                   || ';'
                   || --
                     cod_cfo
                   || ';'
                   || --
                     cod_situacao_b
                   || ';'
                   || --
                     bc_icms
                   || ';'
                   || --
                     icms
                   || ';'
                   || --
                     aliq_icms
                   || ';'
                   || --
                     isentas
                   || ';'
                   || --
                     outras
                   || ';'
                   || --
                     reducao
              INTO v_msg
              FROM msafi.dsp_auto_valida
             WHERE ROWID = p_perfil;

            DELETE FROM msafi.dsp_auto_valida
                  WHERE ROWID = p_perfil;

            COMMIT;

            loga ( 'Registro ' || v_msg || ' excluido com sucesso'
                 , TRUE );
        END IF;

        IF p_funcionalidade = 'C' THEN
            lib_proc.add_tipo ( mproc_id
                              , 1
                              , 'REL_PARAMETROS_FILTRO_VALIDA.xls'
                              , 2 );
            lib_proc.add ( dsp_planilha.header ( )
                         , ptipo => 1 );
            lib_proc.add ( dsp_planilha.tabela_inicio ( )
                         , ptipo => 1 );
            lib_proc.add ( dsp_planilha.linha (
                                                   dsp_planilha.campo ( 'Empresa' )
                                                || dsp_planilha.campo ( 'Estab' )
                                                || dsp_planilha.campo ( 'UF' )
                                                || dsp_planilha.campo ( 'Saida_Entrada' )
                                                || dsp_planilha.campo ( 'Natureza Operacao' )
                                                || dsp_planilha.campo ( 'CFOP' )
                                                || dsp_planilha.campo ( 'CST' )
                                                || dsp_planilha.campo ( 'Base ICMS' )
                                                || dsp_planilha.campo ( 'Valor ICMS' )
                                                || dsp_planilha.campo ( 'Aliquota ICMS' )
                                                || dsp_planilha.campo ( 'Valor Isentas' )
                                                || dsp_planilha.campo ( 'Valor Outras' )
                                                || dsp_planilha.campo ( 'Valor Reducao' )
                                              , --
                                                'h'
                           )
                         , ptipo => 1 );
            COMMIT;

            FOR a IN ( SELECT   cod_empresa
                              , cod_estab
                              , REPLACE ( cod_estado
                                        , 'XX'
                                        , 'Todos' )
                                    cod_estado
                              , entrada_saida
                              , cod_natureza_op
                              , cod_cfo
                              , cod_situacao_b
                              , bc_icms
                              , icms
                              , aliq_icms
                              , isentas
                              , outras
                              , reducao
                           FROM msafi.dsp_auto_valida t
                       ORDER BY 1
                              , 2
                              , 3
                              , 4
                              , 5
                              , 6
                              , 7 ) LOOP
                lib_proc.add ( dsp_planilha.linha (
                                                       dsp_planilha.campo ( a.cod_empresa )
                                                    || dsp_planilha.campo ( a.cod_estab )
                                                    || dsp_planilha.campo ( a.cod_estado )
                                                    || dsp_planilha.campo ( a.entrada_saida )
                                                    || dsp_planilha.campo ( a.cod_natureza_op )
                                                    || dsp_planilha.campo ( a.cod_cfo )
                                                    || dsp_planilha.campo ( a.cod_situacao_b )
                                                    || dsp_planilha.campo ( a.bc_icms )
                                                    || dsp_planilha.campo ( a.icms )
                                                    || dsp_planilha.campo ( a.aliq_icms )
                                                    || dsp_planilha.campo ( a.isentas )
                                                    || dsp_planilha.campo ( a.outras )
                                                    || dsp_planilha.campo ( a.reducao )
                                                  , p_custom => 'height="17"'
                               )
                             , ptipo => 1 );
                COMMIT;
            END LOOP;

            lib_proc.add ( dsp_planilha.tabela_fim ( )
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
END dsp_valida_filtro_cproc;
/
SHOW ERRORS;
