Prompt Package Body CST_CRG_CONF_SAP_CPROC;
--
-- CST_CRG_CONF_SAP_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY cst_crg_conf_sap_cproc
IS
    mcod_empresa empresa.cod_empresa%TYPE;
    mcod_estab estabelecimento.cod_estab%TYPE;
    mcod_usuario usuario_empresa.cod_usuario%TYPE;
    macesso_full VARCHAR2 ( 5 );
    mproc_id NUMBER;

    --Tipo, Nome e Descrição do Customizado
    mnm_tipo VARCHAR2 ( 100 ) := 'Conferência';
    mnm_cproc VARCHAR2 ( 100 ) := '01-Carga Arquivo Confronto SAP x MSAF';
    mds_cproc VARCHAR2 ( 100 ) := 'Carga Arquivo para Emitir relatório de confronto de NFs SAP x Mastersaf';

    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );

        v_sel_data_fim VARCHAR2 ( 260 )
            := ' SELECT TRUNC( TO_DATE( :4 ,''DD/MM/YYYY'') + ROWNUM - 1) AS DATA_FIM, TRUNC( TO_DATE( :4 ,''DD/MM/YYYY'') + ROWNUM - 1) AS DATA_FIM FROM DUAL CONNECT BY ROWNUM <= LAST_DAY( TO_DATE( :4 ,''DD/MM/YYYY'') ) - TO_DATE( :4 ,''DD/MM/YYYY'') + 1 ORDER BY 1 DESC ';
    BEGIN
        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        mcod_estab := lib_parametros.recuperar ( 'ESTABELECIMENTO' );
        mcod_usuario := lib_parametros.recuperar ( 'USUARIO' );

        --VALIDAR ACESSO DO USUÁRIO
        SELECT ( CASE WHEN qtd = 0 THEN 'N' ELSE 'S' END )
          INTO macesso_full
          FROM (SELECT COUNT ( 1 ) qtd
                  FROM pl_grp_usr rol
                     , pl_grp grp
                     , pl_usr usr
                 WHERE 1 = 1
                   AND rol.grp_key = grp.grp_key
                   AND rol.usr_key = usr.usr_key
                   AND grp_name IN ( 'DEVELOPER'
                                   , 'DEVELOPER_DP' )
                   AND TRIM ( UPPER ( usr.usr_login ) ) = TRIM ( UPPER ( mcod_usuario ) ));

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
                           , LPAD ( '-'
                                  , 200
                                  , '-' )
                           , 'VARCHAR2'
                           , 'TEXT'
                           , 'N'
                           , '1'
                           , NULL
                           , ''
                           , 'N' );

        lib_proc.add_param ( pstr
                           , '> ATENÇÃO! A execução destes relatórios é de uso exclusivo do Suporte Mastersaf'
                           , 'VARCHAR2'
                           , 'TEXT'
                           , 'N'
                           , '1'
                           , NULL
                           , ''
                           , 'N' );

        lib_proc.add_param ( pstr
                           , LPAD ( '-'
                                  , 200
                                  , '-' )
                           , 'VARCHAR2'
                           , 'TEXT'
                           , 'N'
                           , '1'
                           , NULL
                           , ''
                           , 'N' );

        lib_proc.add_param ( pstr
                           , 'Data Inicial'
                           , --PDT_INI
                            'DATE'
                           , 'TEXTBOX'
                           , 'S'
                           , NULL
                           , 'DD/MM/YYYY' );

        lib_proc.add_param ( pstr
                           , 'Data Final'
                           , --PDT_FIM
                            'VARCHAR2'
                           , 'COMBOBOX'
                           , 'S'
                           , NULL
                           , '##########'
                           , v_sel_data_fim );

        lib_proc.add_param (
                             pparam => pstr
                           , --PDIRETORY
                            ptitulo => 'Diretório'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'TEXTBOX'
                           , pmandatorio => 'S'
                           , pdefault => 'MSAFIMP'
                           , pmascara => NULL
                           , pvalores => 'SELECT DIRECTORY_NAME, DIRECTORY_PATH FROM ALL_DIRECTORIES WHERE DIRECTORY_NAME = ''MSAFIMP'' '
                           , phabilita => NULL
        );

        lib_proc.add_param ( pparam => pstr
                           , -- PFILE_ARCHIVE
                            ptitulo => 'Arquivo SAP (.txt)'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'TEXTBOX'
                           , pmandatorio => 'S'
                           , pdefault => '.txt'
                           , pmascara => NULL
                           , pvalores => NULL
                           , phabilita => NULL );

        /*lib_proc.add_param(pstr,
                           'UF', --PCOD_ESTADO
                           'VARCHAR2',
                           'COMBOBOX',
                           'S',
                           '%',
                           '##########',
                           'SELECT A.COD_ESTADO, A.COD_ESTADO FROM ESTADO A UNION ALL SELECT ''%'', ''Todas as UFs'' FROM DUAL ORDER BY 1');

        lib_proc.add_param(pstr,
                           'Estabelecimento', --PCOD_ESTAB
                           'VARCHAR2',
                           'MULTISELECT',
                           'S',
                           'S',
                           NULL,
                           ' SELECT A.COD_ESTAB,A.COD_ESTAB || '' - '' || B.COD_ESTADO || '' - '' || A.CGC || '' - '' || INITCAP(A.BAIRRO) || '' / '' || INITCAP(A.CIDADE) ' ||
                           ' FROM ESTABELECIMENTO A, ESTADO B, MSAFI.DSP_ESTABELECIMENTO C ' ||
                           ' WHERE 1=1 ' || --
                           ' AND A.COD_EMPRESA  = ''' || mcod_empresa || '''' ||
                           ' AND B.IDENT_ESTADO = A.IDENT_ESTADO ' ||
                           ' AND A.COD_EMPRESA  = C.COD_EMPRESA ' ||
                           ' AND A.COD_ESTAB    = C.COD_ESTAB ' ||
                           ' AND B.COD_ESTADO   LIKE :8 ' ||
                           ' ORDER BY A.COD_ESTAB  ');*/

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

    ------------------------------------------------------------------------------------------------------------------------------------------------------

    FUNCTION split ( v_texto VARCHAR2
                   , v_coluna INTEGER
                   , v_separador VARCHAR2 )
        RETURN VARCHAR2
    IS
        v_result VARCHAR2 ( 2000 );
        v_posicao1 INTEGER := 0;
        v_posicao2 INTEGER := 0;
    BEGIN
        FOR i IN 1 .. v_coluna LOOP
            v_posicao1 := v_posicao2;
            v_posicao2 :=
                INSTR ( v_texto
                      , v_separador
                      , v_posicao1 + 1 );

            IF NVL ( v_posicao2, 0 ) = 0
           AND v_coluna = i THEN
                v_posicao2 := 99999999;
                EXIT;
            ELSIF NVL ( v_posicao2, 0 ) = 0
              AND v_coluna >= i THEN
                EXIT;
            END IF;
        END LOOP;

        v_result :=
            TRIM ( SUBSTR ( v_texto
                          , v_posicao1 + 1
                          , v_posicao2 - v_posicao1 - 1 ) );


        RETURN v_result;
    END;

    ------------------------------------------------------------------------------------------------------------------------------------------------------
    PROCEDURE limpeza_tmp
    IS
        v_count INTEGER := 0;
    BEGIN
        loga ( '[INICIO] LIMPEZA TMPs'
             , TRUE );

        FOR c IN ( SELECT ROWID AS tmp_id
                     FROM msafi.cst_doctofis_sap_msaf
                    WHERE zzchave < TO_CHAR ( TRUNC ( SYSDATE ) - 3
                                            , 'yyyymmddhh24miss' ) ) LOOP
            DELETE FROM msafi.cst_doctofis_sap_msaf
                  WHERE ROWID = c.tmp_id;

            v_count := v_count + 1;

            IF v_count > 10000 THEN
                COMMIT;
                v_count := 0;
            END IF;
        END LOOP;

        loga ( '[FIM] LIMPEZA TMPs'
             , TRUE );
    END;

    ------------------------------------------------------------------------------------------------------------------------------------------------------

    PROCEDURE load_archive ( p_diretory VARCHAR2
                           , v_file_archive VARCHAR2
                           , v_data_exec DATE )
    IS
        l_vdir VARCHAR2 ( 10000 );
        l_farquivo utl_file.file_type;
        l_vline VARCHAR2 ( 32767 );
        v_count NUMBER := 1;
    BEGIN
        BEGIN
            l_vdir := p_diretory;
            l_vline := '';

            loga ( '[INICIO] LOAD_ARCHIVE 1'
                 , TRUE );

            BEGIN
                l_farquivo :=
                    utl_file.fopen ( l_vdir
                                   , v_file_archive
                                   , 'R'
                                   , 32767 );
            EXCEPTION
                WHEN OTHERS THEN
                    utl_file.fclose ( l_farquivo );
                    loga ( 'ARQUIVO NÃO LOCALIZADO!!! [ERRO LOAD_ARCHIVE 1]' );
                    loga ( 'SQLERRM: ' || SQLERRM );
            END;

            LOOP
                utl_file.get_line ( l_farquivo
                                  , l_vline );

                INSERT INTO msafi.cst_rel_conf_sap_arq ( ordem
                                                       , texto
                                                       , proc_id
                                                       , data_execucao
                                                       , usr_login )
                     VALUES ( v_count
                            , l_vline
                            , mproc_id
                            , v_data_exec
                            , mcod_usuario );

                v_count := v_count + 1;
            END LOOP;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                utl_file.fclose ( l_farquivo );
        END;

        loga ( '>> TOTAL DE LINHAS: ' || v_count
             , FALSE );

        loga ( '[FIM] LOAD_ARCHIVE 1'
             , TRUE );

        COMMIT;
    END;

    ---------------------------------------------------------------------------------------------------------------------------------------------------------

    PROCEDURE load_tmp_layout ( v_proc_id NUMBER )
    IS
        v_count NUMBER DEFAULT 1;
        v_count_total NUMBER DEFAULT 1;
    BEGIN
        loga ( '[INICIO] LOAD TMPs'
             , TRUE );

        FOR c IN ( SELECT split ( texto
                                , 2
                                , CHR ( 9 ) )
                              zzdocnum
                        , split ( texto
                                , 3
                                , CHR ( 9 ) )
                              zzbukrs
                        , split ( texto
                                , 4
                                , CHR ( 9 ) )
                              zzbranch
                        , split ( texto
                                , 5
                                , CHR ( 9 ) )
                              zzcodemp
                        , split ( texto
                                , 6
                                , CHR ( 9 ) )
                              zzcodfil
                        , split ( texto
                                , 7
                                , CHR ( 9 ) )
                              zzmovtoes
                        , split ( texto
                                , 8
                                , CHR ( 9 ) )
                              zzdocdat
                        , split ( texto
                                , 9
                                , CHR ( 9 ) )
                              zzpstdat
                        , split ( texto
                                , 10
                                , CHR ( 9 ) )
                              zzcredat
                        , split ( texto
                                , 11
                                , CHR ( 9 ) )
                              zzcretim
                        , split ( texto
                                , 12
                                , CHR ( 9 ) )
                              zzcrenam
                        , split ( texto
                                , 13
                                , CHR ( 9 ) )
                              zzseries
                        , split ( texto
                                , 14
                                , CHR ( 9 ) )
                              zznfenum
                        , split ( texto
                                , 15
                                , CHR ( 9 ) )
                              zznfe
                        , split ( texto
                                , 16
                                , CHR ( 9 ) )
                              zzparid
                        , split ( texto
                                , 17
                                , CHR ( 9 ) )
                              zzindfisjur
                        , split ( texto
                                , 18
                                , CHR ( 9 ) )
                              zzcodfisjur
                        , split ( texto
                                , 19
                                , CHR ( 9 ) )
                              zzcancel
                        , split ( texto
                                , 20
                                , CHR ( 9 ) )
                              zzcandat
                        , split ( texto
                                , 21
                                , CHR ( 9 ) )
                              zztotalwtax
                        , split ( texto
                                , 22
                                , CHR ( 9 ) )
                              zznfesrv
                        , split ( texto
                                , 23
                                , CHR ( 9 ) )
                              zzitmnum
                        , split ( texto
                                , 24
                                , CHR ( 9 ) )
                              zzmatnr
                        , split ( texto
                                , 25
                                , CHR ( 9 ) )
                              zzcodmat
                        , split ( texto
                                , 26
                                , CHR ( 9 ) )
                              zzindprod
                        , split ( texto
                                , 27
                                , CHR ( 9 ) )
                              zzmaktx
                        , split ( texto
                                , 28
                                , CHR ( 9 ) )
                              zzcfop
                        , split ( texto
                                , 29
                                , CHR ( 9 ) )
                              zzquantity
                        , split ( texto
                                , 30
                                , CHR ( 9 ) )
                              zztotalval
                        , split ( texto
                                , 31
                                , CHR ( 9 ) )
                              zzvalitem
                        , split ( texto
                                , 32
                                , CHR ( 9 ) )
                              zzchave
                        , split ( texto
                                , 33
                                , CHR ( 9 ) )
                              zzuserexec
                     FROM msafi.cst_rel_conf_sap_arq a
                    WHERE 1 = 1
                      AND NVL ( LENGTH ( TRIM ( TRANSLATE ( split ( texto
                                                                  , 2
                                                                  , CHR ( 9 ) )
                                                          , '0123456789'
                                                          , '         ' ) ) )
                              , 0 ) = 0
                      AND a.proc_id = v_proc_id ) LOOP
            INSERT INTO msafi.cst_doctofis_sap_msaf ( zzdocnum
                                                    , zzbukrs
                                                    , zzbranch
                                                    , zzcodemp
                                                    , zzcodfil
                                                    , zzmovtoes
                                                    , zzdocdat
                                                    , zzpstdat
                                                    , zzcredat
                                                    , zzcretim
                                                    , zzcrenam
                                                    , zzseries
                                                    , zznfenum
                                                    , zznfe
                                                    , zzparid
                                                    , zzindfisjur
                                                    , zzcodfisjur
                                                    , zzcancel
                                                    , zzcandat
                                                    , zztotalwtax
                                                    , zznfesrv
                                                    , zzitmnum
                                                    , zzmatnr
                                                    , zzcodmat
                                                    , zzindprod
                                                    , zzmaktx
                                                    , zzcfop
                                                    , zzquantity
                                                    , zztotalval
                                                    , zzvalitem
                                                    , zzchave
                                                    , zzuserexec )
                 VALUES ( c.zzdocnum
                        , c.zzbukrs
                        , c.zzbranch
                        , c.zzcodemp
                        , c.zzcodfil
                        , c.zzmovtoes
                        , c.zzdocdat
                        , c.zzpstdat
                        , c.zzcredat
                        , c.zzcretim
                        , c.zzcrenam
                        , c.zzseries
                        , c.zznfenum
                        , c.zznfe
                        , c.zzparid
                        , c.zzindfisjur
                        , c.zzcodfisjur
                        , c.zzcancel
                        , c.zzcandat
                        , c.zztotalwtax
                        , c.zznfesrv
                        , c.zzitmnum
                        , c.zzmatnr
                        , c.zzcodmat
                        , c.zzindprod
                        , c.zzmaktx
                        , c.zzcfop
                        , c.zzquantity
                        , c.zztotalval
                        , c.zzvalitem
                        , c.zzchave
                        , c.zzuserexec );

            v_count := v_count + 1;
            v_count_total := v_count_total + 1;

            IF v_count >= 1000 THEN
                COMMIT;
                v_count := 0;
            END IF;
        END LOOP;

        loga ( '>> TOTAL DE LINHAS: ' || v_count_total
             , FALSE );

        loga ( '[FIM] LOAD TMPs'
             , TRUE );
    END;

    ---------------------------------------------------------------------------------------------------------------------------------------------------------

    FUNCTION executar ( pdt_ini DATE
                      , pdt_fim DATE
                      , pdiretory VARCHAR2
                      , pfile_archive VARCHAR2 )
        RETURN INTEGER
    IS
        mdesc VARCHAR2 ( 4000 );
        v_data_exec DATE;
        v_dir_path VARCHAR2 ( 100 );

        v_id_arq NUMBER := 99;
    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS= '',.'' ';

        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_LANGUAGE = ''Portuguese'' ';

        --Performar em caso de códigos repetitivos no mesmo plano de execução
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING = FORCE';

        --Recuperar a empresa para o plano de execução caso não esteja sendo executado pelo diretamente na tela do Mastersaf
        lib_parametros.salvar ( 'EMPRESA'
                              , NVL ( mcod_empresa, msafi.dpsp.v_empresa ) );

        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        mcod_usuario := lib_parametros.recuperar ( 'USUARIO' );
        mdesc := lib_parametros.recuperar ( 'PDESC' );

        -- Criação: Processo
        mproc_id :=
            lib_proc.new ( psp_nome => $$plsql_unit
                         , pdescricao => mdesc );
        COMMIT;
        v_data_exec := SYSDATE;

        loga ( '<<' || mnm_cproc || '>>'
             , FALSE );
        loga ( '---INICIO DO PROCESSAMENTO---'
             , FALSE );

        dbms_application_info.set_module ( $$plsql_unit
                                         , 'PROC_ID: ' || mproc_id );

        loga (    'Data execução: '
               || TO_CHAR ( v_data_exec
                          , 'DD/MM/YYYY HH24:MI:SS' )
             , FALSE );

        SELECT directory_path
          INTO v_dir_path
          FROM all_directories
         WHERE directory_name = pdiretory;

        loga ( LPAD ( '-'
                    , 62
                    , '-' )
             , FALSE );
        loga ( 'Usuário: ' || mcod_usuario
             , FALSE );
        loga ( 'Empresa: ' || mcod_empresa
             , FALSE );
        loga (    'Período: '
               || TO_CHAR ( pdt_ini
                          , 'DD/MM/YYYY' )
               || ' - '
               || TO_CHAR ( pdt_fim
                          , 'DD/MM/YYYY' )
             , FALSE );

        loga ( 'Diretório: ' || pdiretory
             , FALSE );
        loga ( 'Path: ' || v_dir_path
             , FALSE );
        loga ( 'Arquivo: ' || pfile_archive
             , FALSE );

        lib_proc.add_tipo ( mproc_id
                          , 1
                          ,    TO_CHAR ( SYSDATE
                                       , 'YYYYMMDDHH24MISS' )
                            || '_CONF_SAP'
                          , 1 );

        limpeza_tmp;
        load_archive ( pdiretory
                     , pfile_archive
                     , v_data_exec );

        load_tmp_layout ( mproc_id );

        lib_proc.add_tipo ( mproc_id
                          , v_id_arq
                          , 'REL_CONF_SAP_CPROC.XLS'
                          , 2 );
        lib_proc.add ( dsp_planilha.header
                     , ptipo => v_id_arq );
        lib_proc.add ( dsp_planilha.tabela_inicio
                     , ptipo => v_id_arq );

        lib_proc.add ( dsp_planilha.linha (
                                            p_conteudo =>    dsp_planilha.campo ( 'IND_NF_E_SERV' )
                                                          || --
                                                            dsp_planilha.campo ( 'COD_EMPRESA' )
                                                          || --
                                                            dsp_planilha.campo ( 'COD_ESTAB' )
                                                          || --
                                                            dsp_planilha.campo ( 'NUM_CONTROLE_DOCTO' )
                                                          || --
                                                            dsp_planilha.campo ( 'NUM_DOCFIS' )
                                                          || --
                                                            dsp_planilha.campo ( 'DATA_LANCAMENTO' )
                                                          || --
                                                            dsp_planilha.campo ( 'DATA_EMISSAO' )
                                                          || --
                                                            dsp_planilha.campo ( 'SERIE_DOCFIS' )
                                                          || --
                                                            dsp_planilha.campo ( 'NUM_ITEM' )
                                                          || --
                                                            dsp_planilha.campo ( 'DES_MATERIAL' )
                                                          || --
                                                            dsp_planilha.campo ( 'COD_CFO' )
                                                          || --
                                                            dsp_planilha.campo ( 'COD_SITUACAO_A' )
                                                          || --
                                                            dsp_planilha.campo ( 'COD_SITUACAO_B' )
                                                          || --
                                                            dsp_planilha.campo ( 'COD_FEDERAL' )
                                                          || --
                                                            '' --
                                          , p_class => 'H'
                       )
                     , ptipo => v_id_arq );

        -- RODAPE
        lib_proc.add ( dsp_planilha.tabela_fim
                     , ptipo => 1 );
        COMMIT;
        --

        loga ( 'FIM DO PROCESSAMENTO, STATUS FINAL: [SUCESSO]'
             , FALSE );
        lib_proc.add ( 'FIM DO PROCESSAMENTO, STATUS FINAL: [SUCESSO]' );

        loga ( '---FIM DO PROCESSAMENTO---'
             , FALSE );

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
END cst_crg_conf_sap_cproc;
/
SHOW ERRORS;
