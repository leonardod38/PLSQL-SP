Prompt Package Body DPSP_FIN151_CAT42_FICHAS_CPROC;
--
-- DPSP_FIN151_CAT42_FICHAS_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_fin151_cat42_fichas_cproc
IS
    mproc_id NUMBER;
    vn_linha NUMBER := 0;
    vn_pagina NUMBER := 0;
    vs_mlinha VARCHAR2 ( 4000 );
    mnm_usuario usuario_estab.cod_usuario%TYPE;
    mcod_empresa estabelecimento.cod_empresa%TYPE;

    vg_partition_name VARCHAR2 ( 60 ) := '';
    vg_module VARCHAR2 ( 60 ) := '';
    --Tipo, Nome e Descrição do Customizado
    --Melhoria FIN151 - CAT42 - Processar documentos necessários para a CAT 42

    mnm_tipo VARCHAR2 ( 100 ) := 'CAT 42';
    mnm_cproc VARCHAR2 ( 100 ) := 'Geração dos Arquivos';
    mds_cproc VARCHAR2 ( 100 ) := 'Processar documentos necessários para a CAT 42';

    ---
    TYPE r_tab_error IS RECORD
    (
        cod_estab VARCHAR2 ( 8 )
      , status VARCHAR2 ( 2 )
      , error_msg VARCHAR2 ( 255 )
    );

    TYPE t_tab_error IS TABLE OF r_tab_error;

    tab_error t_tab_error := t_tab_error ( );

    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );
    BEGIN
        mnm_usuario := lib_parametros.recuperar ( UPPER ( 'USUARIO' ) );
        mcod_empresa := lib_parametros.recuperar ( UPPER ( 'EMPRESA' ) );

        lib_proc.add_param ( pparam => pstr
                           , ptitulo =>    LPAD ( '-'
                                                , 60
                                                , '-' )
                                        || 'Gerar Arquivo CAT42'
                                        || LPAD ( '-'
                                                , 60
                                                , '-' )
                           , ptipo => 'Varchar2'
                           , pcontrole => 'Text'
                           , pmandatorio => 'N'
                           , pdefault => 'N'
                           , pmascara => NULL
                           , pvalores => NULL
                           , papresenta => 'N' );

        lib_proc.add_param (
                             pparam => pstr
                           , ptitulo => 'Ficha'
                           , ptipo => 'Varchar2'
                           , pcontrole => 'Listbox'
                           , pmandatorio => 'S'
                           , pdefault => 4
                           , pmascara => NULL
                           , pvalores => '1=1. Dados da Empresa,2=2. Produtos,3=3. Inventário,4=4. Movimentação,5=5. Perdas'
                           , papresenta => 'N'
        );

        lib_proc.add_param ( pparam => pstr
                           , ptitulo => 'Periodo'
                           , ptipo => 'DATE'
                           , pcontrole => 'textbox'
                           , pmandatorio => 'S'
                           , pdefault => '01/01/2018'
                           , pmascara => 'MM/YYYY' );

        lib_proc.add_param ( pstr
                           , 'Qtde de Execuções em Paralelo'
                           , --P_THREAD
                            'NUMBER'
                           , 'TEXTBOX'
                           , 'S'
                           , '20'
                           , '####' );

        lib_proc.add_param ( pparam => pstr
                           , ptitulo =>    LPAD ( '-'
                                                , 65
                                                , '-' )
                                        || 'Extrair Arquivo'
                                        || LPAD ( '-'
                                                , 65
                                                , '-' )
                           , ptipo => 'Varchar2'
                           , pcontrole => 'Text'
                           , pmandatorio => 'N'
                           , pdefault => 'N'
                           , pmascara => NULL
                           , pvalores => NULL
                           , papresenta => 'N' );

        lib_proc.add_param ( pparam => pstr
                           , ptitulo => 'via Mastersaf DW'
                           , ptipo => 'Varchar2'
                           , pcontrole => 'Checkbox'
                           , pmandatorio => 'S'
                           , pdefault => 'N'
                           , pmascara => NULL
                           , pvalores => 'S=Sim,N=Não'
                           , papresenta => 'N' );

        lib_proc.add_param ( pparam => pstr
                           , ptitulo => 'via diretório no servidor'
                           , ptipo => 'Varchar2'
                           , pcontrole => 'Checkbox'
                           , pmandatorio => 'S'
                           , pdefault => 'S'
                           , pmascara => NULL
                           , pvalores => 'S=Sim,N=Não'
                           , papresenta => 'N' );

        lib_proc.add_param ( pparam => pstr
                           , ptitulo => 'Diretório'
                           , ptipo => 'Varchar2'
                           , pcontrole => 'Textbox'
                           , pmandatorio => 'S'
                           , pdefault => 'MSAFIMP'
                           , pmascara => NULL
                           , pvalores => 'SELECT directory_name,directory_path FROM MSAF.PRT_DIRETORIOS_SERVIDOR'
                           , papresenta => 'N'
                           , phabilita => ' :6 = ''S'' ' );

        lib_proc.add_param ( pparam => pstr
                           , ptitulo => 'Arquivo de Auditoria (Ficha 4)'
                           , ptipo => 'Varchar2'
                           , pcontrole => 'Checkbox'
                           , pmandatorio => 'S'
                           , pdefault => 'N'
                           , pmascara => NULL
                           , pvalores => 'S=Sim,N=Não'
                           , papresenta => 'N'
                           , phabilita => ' :2 = ''4'' ' );

        lib_proc.add_param ( pparam => pstr
                           , --P_EXTRAIR
                            ptitulo => 'Extrair arquivo SEM processamento'
                           , ptipo => 'Varchar2'
                           , pcontrole => 'Checkbox'
                           , pmandatorio => 'S'
                           , pdefault => 'N'
                           , pmascara => NULL
                           , pvalores => 'S=Sim,N=Não'
                           , papresenta => 'N' );

        lib_proc.add_param ( pparam => pstr
                           , ptitulo =>    LPAD ( '-'
                                                , 65
                                                , '-' )
                                        || 'Estabelecimentos'
                                        || LPAD ( '-'
                                                , 65
                                                , '-' )
                           , ptipo => 'Varchar2'
                           , pcontrole => 'Text'
                           , pmandatorio => 'N'
                           , pdefault => 'N'
                           , pmascara => NULL
                           , pvalores => NULL
                           , papresenta => 'N' );

        --PTIPO
        lib_proc.add_param ( pparam => pstr
                           , ptitulo => 'Tipo'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'listbox'
                           , pmandatorio => 'S'
                           , pdefault => 'L'
                           , --pdefault    => '%',
                             pmascara => '#########'
                           , pvalores => '%=Todos os Estabelecimentos,C=CD,L=Filial'
                           , papresenta => 'N' );

        --PCOD_ESTADO
        lib_proc.add_param (
                             pparam => pstr
                           , ptitulo => 'UF'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'COMBOBOX'
                           , pmandatorio => 'S'
                           , pdefault => 'SP'
                           , --pdefault    => '%',
                             pmascara => '#########'
                           , pvalores => 'SELECT A.COD_ESTADO, A.COD_ESTADO FROM ESTADO A UNION ALL SELECT ''%'', ''Todas as UFs'' FROM DUAL ORDER BY 1'
                           , papresenta => 'N'
        );

        --PCOD_ESTAB
        lib_proc.add_param (
                             pparam => pstr
                           , ptitulo => 'Selecionar'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'MULTISELECT'
                           , pmandatorio => 'S'
                           , pdefault => 'N'
                           , pmascara => NULL
                           , pvalores =>    'SELECT A.COD_ESTAB, A.COD_ESTAB || '' - '' || B.COD_ESTADO || '' - '' || A.CGC || '' - '' || INITCAP(A.BAIRRO) || '' / '' || INITCAP(A.CIDADE) FROM ESTABELECIMENTO A, ESTADO B, MSAFI.DSP_ESTABELECIMENTO C WHERE A.COD_EMPRESA  = '''
                                         || mcod_empresa
                                         || ''' AND B.IDENT_ESTADO = A.IDENT_ESTADO AND A.COD_EMPRESA = C.COD_EMPRESA AND A.COD_ESTAB = C.COD_ESTAB AND B.COD_ESTADO LIKE :13 AND TIPO LIKE :12 ORDER BY B.COD_ESTADO, A.COD_ESTAB'
                           , papresenta => 'N'
        );

        RETURN pstr;
    END;

    FUNCTION tipo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN mnm_tipo;
    END;

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN mnm_cproc;
    END;

    FUNCTION descricao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN mds_cproc;
    END;

    FUNCTION versao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN '1.0';
    END;

    FUNCTION modulo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'CUSTOMIZADOS';
    END;

    FUNCTION classificacao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'CUSTOMIZADOS';
    END;

    FUNCTION orientacao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'PORTRAIT';
    END;

    FUNCTION executar ( flg_arq CHAR
                      , pdt_ini DATE
                      , p_thread VARCHAR2
                      , flg_dw CHAR
                      , flg_utl CHAR
                      , pdiretorio VARCHAR2
                      , flg_audit CHAR
                      , p_extrair CHAR
                      , ptipo CHAR
                      , pcod_estado VARCHAR2
                      , pcod_estab lib_proc.vartab )
        RETURN INTEGER
    IS
        i VARCHAR2 ( 200 );
        pdt_fim DATE := LAST_DAY ( pdt_ini );
        pdt_periodo INTEGER
            := TO_NUMBER ( TO_CHAR ( pdt_ini
                                   , 'YYYYMM' ) );
        v_data_hora_ini VARCHAR2 ( 20 );
        p_proc_instance VARCHAR2 ( 30 );

        v_qtd INTEGER := 0;
        v_cds INTEGER := 0;
        v_filiais INTEGER := 0;
        pid_arquivo INTEGER := 2;

        parquivo VARCHAR2 ( 100 );

        pcnpj INTEGER;
        ---
        v_tab_part VARCHAR2 ( 30 );
        p_tab_produtos VARCHAR2 ( 30 );
        p_tab_nfret VARCHAR2 ( 30 );

        --VAR PARA FICHA 4
        TYPE tt_tab_mov IS RECORD
        (
            ROWID VARCHAR2 ( 20 )
        );

        TYPE t_tab_mov IS TABLE OF tt_tab_mov;

        tab_mov t_tab_mov;
        tab_mov_del t_tab_mov;
        ---
        v_error_line VARCHAR2 ( 70 );
        v_count_line INTEGER := 0;
        v_sql VARCHAR2 ( 2000 );
        c_errors SYS_REFCURSOR;
        c_mov SYS_REFCURSOR;
        v_cod_estab_e VARCHAR2 ( 6 );
        v_status_e VARCHAR2 ( 2 );
        v_titulo_erro INTEGER := 0;
        v_cgc VARCHAR2 ( 20 );
        ---
        v_chunk_del INTEGER DEFAULT 0;
        v_task VARCHAR2 ( 30 );
        v_try NUMBER;
        v_status NUMBER;
        ---
        v_cnpj VARCHAR2 ( 20 );
    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT="DD/MM/YYYY"';

        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS= '',.'' ';

        mproc_id :=
            lib_proc.new ( psp_nome => 'DPSP_FIN151_CAT42_FICHAS_CPROC'
                         , prows => 48
                         , pcols => 200 );

        lib_proc.add_tipo ( pproc_id => mproc_id
                          , ptipo => 1
                          , ptitulo =>    TO_CHAR ( SYSDATE
                                                  , 'YYYYMMDDHH24MISS' )
                                       || '_CAT42'
                          , ptipo_arq => 1 );

        dbms_application_info.set_module ( $$plsql_unit
                                         , 'CAT42 ARQUIVOS EY' );

        vn_pagina := 1;
        vn_linha := 48;

        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        mnm_usuario := lib_parametros.recuperar ( 'USUARIO' );

        --MARCAR INCIO DA EXECUCAO
        v_data_hora_ini :=
            TO_CHAR ( SYSDATE
                    , 'DD/MM/YYYY HH24:MI.SS' );

        IF mcod_empresa IS NULL THEN
            lib_proc.add_log ( 'Código da empresa deve ser informado como parâmetro global.'
                             , 0 );
            lib_proc.add ( 'ERRO' );
            lib_proc.add ( 'CÓDIGO DA EMPRESA DEVE SER INFORMADO COMO PARÂMETRO GLOBAL.' );
            lib_proc.close;
            RETURN mproc_id;
        END IF;

        FOR c_dados_emp IN ( SELECT cod_empresa
                                  , razao_social
                                  , cnpj AS cod_cnpj
                                  , DECODE ( cnpj
                                           , NULL, NULL
                                           , REPLACE ( REPLACE ( REPLACE ( TO_CHAR ( LPAD ( REPLACE ( cnpj
                                                                                                    , '' )
                                                                                          , 14
                                                                                          , '0' )
                                                                                   , '00,000,000,0000,00' )
                                                                         , ','
                                                                         , '.' )
                                                               , ' ' )
                                                     ,    '.'
                                                       || TRIM ( TO_CHAR ( TRUNC (   MOD ( LPAD ( cnpj
                                                                                                , 14
                                                                                                , '0' )
                                                                                         , 1000000 )
                                                                                   / 100 )
                                                                         , '0000' ) )
                                                       || '.'
                                                     ,    '/'
                                                       || TRIM ( TO_CHAR ( TRUNC (   MOD ( LPAD ( cnpj
                                                                                                , 14
                                                                                                , '0' )
                                                                                         , 1000000 )
                                                                                   / 100 )
                                                                         , '0000' ) )
                                                       || '-' ) )
                                        AS cnpj
                               FROM empresa
                              WHERE cod_empresa = mcod_empresa ) LOOP
            pcnpj := c_dados_emp.cod_cnpj;

            cabecalho ( c_dados_emp.razao_social
                      , c_dados_emp.cnpj
                      , flg_arq
                      , pdt_ini
                      , pcod_estado
                      , v_data_hora_ini );
        END LOOP;

        loga ( '---INICIO DO PROCESSAMENTO---'
             , FALSE );
        loga ( '<< PERIODO DE: ' || pdt_periodo || ' >>'
             , FALSE );

        drop_old_tmp ( mproc_id );

        --=================================================================================
        -- Ficha 1. Arquivos Complementares
        --=================================================================================
        IF flg_arq = '1' THEN
            loga ( LPAD ( '-'
                        , 150
                        , '-' )
                 , FALSE );
            loga ( '---INICIO - FICHA 1: DADOS EMPRESA---'
                 , FALSE );
            -----------------------

            loga ( 'VERIFICAR_ESTABs-INI'
                 , FALSE );

            FOR v_cod_estab IN pcod_estab.FIRST .. pcod_estab.LAST LOOP
                DELETE FROM msafi.dpsp_fin151_cat42_ide
                      WHERE cod_filial = pcod_estab ( v_cod_estab )
                        AND periodo = pdt_periodo;

                COMMIT;

                dbms_application_info.set_module ( $$plsql_unit
                                                 , 'F1 Estab: ' || pcod_estab ( v_cod_estab ) );

                parquivo :=
                       'IDE_'
                    || pcnpj
                    || '_'
                    || TO_CHAR ( pdt_ini
                               , 'MMYYYY' )
                    || '.TXT';

                --VERIFICAR SE O ESTABELECIMENTO APRESENTA MOVIMENTO NO PERIODO
                ficha1_verificar ( pcod_estab ( v_cod_estab )
                                 , pdt_ini
                                 , pdt_fim
                                 , pdt_periodo
                                 , v_data_hora_ini );
            END LOOP;

            loga ( 'VERIFICAR_ESTABs-FIM'
                 , FALSE );

            -----------------------
            loga ( 'GERAR_FICHA1-INI'
                 , FALSE );

            ficha1_gerar ( pdt_ini
                         , pdt_fim
                         , pdt_periodo
                         , v_data_hora_ini );

            loga ( 'GERAR_FICHA1-FIM'
                 , FALSE );

            SELECT COUNT ( 1 )
              INTO v_qtd
              FROM msafi.dpsp_fin151_cat42_ide
             WHERE 1 = 1
               AND linha_auxiliar = 'N'
               AND proc_id = mproc_id
               AND periodo = pdt_periodo;

            loga ( '::REGISTROS INSERIDOS (DPSP_FIN151_CAT42_IDE) - QTDE ' || v_qtd || '::'
                 , FALSE );

            -----------------------
            --Extrair arquivos
            -----------------------
            loga ( 'EXTRAINDO ARQUIVOS-INI'
                 , FALSE );

            ficha1_extrair ( flg_dw
                           , flg_utl
                           , pdiretorio
                           , parquivo
                           , pdt_periodo );

            IF flg_utl = 'S' THEN
                loga_directory_path ( 'Dados da Empresa'
                                    , pdiretorio
                                    , parquivo );
            END IF;

            loga ( 'EXTRAINDO ARQUIVOS-FIM'
                 , FALSE );

            loga ( '---FIM - FICHA 1: DADOS EMPRESA---'
                 , FALSE );
        --=================================================================================
        -- Ficha 2. Produtos
        --=================================================================================
        ELSIF flg_arq = '2' THEN
            loga ( LPAD ( '-'
                        , 150
                        , '-' )
                 , FALSE );
            loga ( '---INICIO - FICHA 2: PRODUTOS---'
                 , FALSE );

            SELECT ROUND ( dbms_random.VALUE ( 10000000000000
                                             , 999999999999999 ) )
              INTO p_proc_instance
              FROM DUAL;

            ---------------------
            loga ( '>> PROC INSERT ' || p_proc_instance
                 , FALSE );

            --=========================
            -- Limpeza FICHA 2
            --=========================
            loga ( 'LIMPEZA-INI'
                 , FALSE );
            v_qtd := 0;

            FOR l IN ( SELECT ROWID
                         FROM msafi.dpsp_fin151_cat42_prod
                        WHERE periodo = pdt_periodo ) LOOP
                DELETE FROM msafi.dpsp_fin151_cat42_prod
                      WHERE ROWID = l.ROWID;

                v_qtd := v_qtd + 1;

                IF v_qtd > 10000 THEN
                    COMMIT;
                END IF;
            END LOOP;

            COMMIT;
            loga ( 'LIMPEZA-FIM'
                 , FALSE );
            --=========================

            dbms_application_info.set_module ( $$plsql_unit
                                             , 'F2' );

            parquivo :=
                   'PRD_'
                || pcnpj
                || '_'
                || TO_CHAR ( pdt_ini
                           , 'MMYYYY' )
                || '.TXT';

            ficha2_gerar ( p_proc_instance
                         , pcod_estab
                         , ptipo
                         , pdt_ini
                         , pdt_fim
                         , pdt_periodo
                         , v_data_hora_ini );

            -----------------------
            SELECT COUNT ( 1 )
              INTO v_qtd
              FROM msafi.dpsp_fin151_cat42_prod
             WHERE proc_id = mproc_id
               AND periodo = pdt_periodo;

            loga ( '::REGISTROS INSERIDOS (DPSP_FIN151_CAT42_PROD) - QTDE ' || v_qtd || '::'
                 , FALSE );

            -----------------------
            --Extrair arquivos
            -----------------------
            loga ( 'EXTRAINDO ARQUIVOS-INI'
                 , FALSE );

            ficha2_extrair ( flg_dw
                           , flg_utl
                           , pdiretorio
                           , parquivo
                           , pdt_periodo );

            IF flg_utl = 'S' THEN
                loga_directory_path ( 'Produtos'
                                    , pdiretorio
                                    , parquivo );
            END IF;

            loga ( 'EXTRAINDO ARQUIVOS-FIM'
                 , FALSE );

            loga ( '---FIM - FICHA 2: PRODUTOS---'
                 , FALSE );
        --=================================================================================
        -- Ficha 3. Inventario
        --=================================================================================
        ELSIF flg_arq = '3' THEN
            loga ( LPAD ( '-'
                        , 150
                        , '-' )
                 , FALSE );
            loga ( '---INICIO - FICHA 3: INVENTARIO---'
                 , FALSE );

            FOR v_cod_estab IN pcod_estab.FIRST .. pcod_estab.LAST LOOP
                SELECT ROUND ( dbms_random.VALUE ( 10000000000000
                                                 , 999999999999999 ) )
                  INTO p_proc_instance
                  FROM DUAL;

                ---------------------
                loga ( '>> INICIO ESTAB: ' || pcod_estab ( v_cod_estab ) || ' PROC INSERT ' || p_proc_instance
                     , FALSE );

                DELETE FROM msafi.dpsp_fin151_cat42_inv
                      WHERE cod_filial = pcod_estab ( v_cod_estab )
                        AND periodo = pdt_periodo;

                COMMIT;

                dbms_application_info.set_module ( $$plsql_unit
                                                 , 'F3 Estab: ' || pcod_estab ( v_cod_estab ) );

                parquivo :=
                       'INV_'
                    || pcnpj
                    || '_'
                    || TO_CHAR ( pdt_ini
                               , 'MMYYYY' )
                    || '.TXT';

                ficha3_gerar ( p_proc_instance
                             , pcod_estab ( v_cod_estab )
                             , pdt_ini
                             , pdt_fim
                             , pdt_periodo
                             , v_data_hora_ini );
            END LOOP;

            -----------------------
            SELECT COUNT ( 1 )
              INTO v_qtd
              FROM msafi.dpsp_fin151_cat42_inv
             WHERE proc_id = mproc_id
               AND periodo = pdt_periodo;

            loga ( '::REGISTROS INSERIDOS (DPSP_FIN151_CAT42_INV) - QTDE ' || v_qtd || '::'
                 , FALSE );

            -----------------------
            --Extrair arquivos
            -----------------------
            loga ( 'EXTRAINDO ARQUIVOS-INI'
                 , FALSE );

            ficha3_extrair ( flg_dw
                           , flg_utl
                           , pdiretorio
                           , parquivo
                           , pdt_periodo );

            IF flg_utl = 'S' THEN
                loga_directory_path ( 'Produtos'
                                    , pdiretorio
                                    , parquivo );
            END IF;

            loga ( 'EXTRAINDO ARQUIVOS-FIM'
                 , FALSE );

            loga ( '---FIM - FICHA 3: INVENTARIO---'
                 , FALSE );
        --=================================================================================
        -- Ficha 4. Movimentação
        --=================================================================================
        ELSIF flg_arq = '4' THEN
            loga ( LPAD ( '-'
                        , 150
                        , '-' )
                 , FALSE );
            loga ( '---INICIO - FICHA 4: MOVIMENTACAO---'
                 , FALSE );
            p_proc_instance := mproc_id;

            IF ( p_extrair <> 'S' ) THEN --EXTRAIR ARQUIVO SEM PROCESSAMENTO --(1)
                dbms_application_info.set_module ( $$plsql_unit
                                                 , 'F4 INICIO MOV' );

                --OBTER NOME DA PARTICAO-INI
                BEGIN
                    SELECT ' PARTITION (' || a.partition_name || ') '
                      INTO vg_partition_name
                      FROM TABLE ( msafi.dpsp_recupera_particao ( 'MSAFI'
                                                                , 'DPSP_FIN151_CAT42_MOV'
                                                                , pdt_ini
                                                                , pdt_fim ) ) a;
                EXCEPTION
                    WHEN OTHERS THEN
                        vg_partition_name := ' ';
                END;

                --OBTER NOME DA PARTICAO-FIM

                v_tab_part :=
                    create_tab_partition ( p_proc_instance
                                         , pcod_estab );
                p_tab_produtos := create_tab_produto ( p_proc_instance );
                p_tab_nfret := create_tab_nfret ( p_proc_instance );

                --ATUALIZAR LISTA DE MEDICAMENTOS
                msafi.atualiza_lista;

                --EXECUTAR THREADS
                dbms_application_info.set_module ( $$plsql_unit
                                                 , 'F4 THREADS EM EXECUCAO...' );
                exec_ficha4_parallel ( p_proc_instance
                                     , p_thread
                                     , v_tab_part
                                     , flg_audit
                                     , pdt_ini
                                     , pdt_fim
                                     , pdt_periodo
                                     , v_data_hora_ini
                                     , p_tab_produtos
                                     , p_tab_nfret
                                     , v_tab_part );
            -----------------------

            --IF (VG_PARTITION_NAME <> ' ') THEN
            --
            --  DBMS_APPLICATION_INFO.SET_MODULE($$PLSQL_UNIT, 'F4 STATS PARTITION MOV');
            --  VG_PARTITION_NAME := SUBSTR(VG_PARTITION_NAME,
            --                              INSTR(VG_PARTITION_NAME,'(',1,1)+1,
            --                              INSTR(VG_PARTITION_NAME,')',1,1)-INSTR(VG_PARTITION_NAME,'(',1,1)-1
            --                             );
            --
            --  DBMS_STATS.GATHER_TABLE_STATS (
            --                                   OwnName           => 'MSAFI'
            --                                  ,TabName           => 'DPSP_FIN151_CAT42_MOV'
            --                                  ,Partname          => VG_PARTITION_NAME
            --                                  ,Degree            => 8
            --                                );
            --END IF;
            --ELSE
            --  DBMS_STATS.GATHER_TABLE_STATS('MSAFI', 'DPSP_FIN151_CAT42_MOV');
            --END IF;

            END IF; --(1)

            v_qtd := 0;

            SELECT COUNT ( 1 )
              INTO v_qtd
              FROM msafi.dpsp_fin151_cat42_mov
             WHERE data BETWEEN pdt_ini AND pdt_fim;

            loga ( '::LINHAS EXISTENTES PARA O PERIODO (DPSP_FIN151_CAT42_ARQ_MOV): ' || v_qtd || '::'
                 , FALSE );

            --=========================
            -- Para a FICHA 4 é necessário um arquivo para todas as Filiais e arquivos separados
            -- correspondentes aos CDs
            --=========================
            --Verificar se foi listado um CD
            v_qtd := 0;
            v_cds := 0;

            FOR v_cod_estab IN pcod_estab.FIRST .. pcod_estab.LAST LOOP
                SELECT COUNT ( 1 )
                  INTO v_qtd
                  FROM msafi.dsp_estabelecimento
                 WHERE cod_estab = pcod_estab ( v_cod_estab )
                   AND tipo = 'C';

                v_cds := v_cds + v_qtd;
            END LOOP;

            --==============================
            -- FICHA 4 - Extrair arquivo de Filiais
            --==============================
            v_qtd := 0;
            v_filiais := 0;

            IF ptipo = 'L' THEN --LOJAS
                loga ( 'EXTRAINDO ARQUIVOS-INI'
                     , FALSE );
                dbms_application_info.set_module ( $$plsql_unit
                                                 , 'F4 GERANDO ARQUIVOS' );
                loga ( 'FILIAIS'
                     , FALSE );

                FOR v_cod_estab IN pcod_estab.FIRST .. pcod_estab.LAST LOOP
                    SELECT cgc
                      INTO v_cgc
                      FROM msaf.estabelecimento
                     WHERE cod_estab = pcod_estab ( v_cod_estab )
                       AND cod_empresa = msafi.dpsp.empresa;

                    parquivo :=
                           'MOV_'
                        || v_cgc
                        || '_'
                        || TO_CHAR ( pdt_ini
                                   , 'YYYYMM' )
                        || '.TXT';

                    ficha4_extrair ( flg_dw
                                   , flg_utl
                                   , pdiretorio
                                   , parquivo
                                   , pdt_periodo
                                   , pid_arquivo
                                   , pcod_estab ( v_cod_estab )
                                   , 'L'
                                   , -- FILIAL
                                    p_proc_instance );

                    IF flg_utl = 'S' THEN
                        loga_directory_path ( 'Movimentação (Filiais)'
                                            , pdiretorio
                                            , parquivo );
                    END IF;

                    lib_proc.add ( 'Documento de Movimentação (Filiais) - "' || parquivo || '"'
                                 , 1 );
                    lib_proc.add ( ' '
                                 , 1 );
                END LOOP;
            END IF;

            --==============================
            -- FICHA 4 - Extrair arquivos dos CDs
            --==============================
            IF v_cds <> 0 THEN
                v_qtd := 0;

                FOR v_cod_estab IN pcod_estab.FIRST .. pcod_estab.LAST LOOP
                    SELECT COUNT ( 1 )
                      INTO v_qtd
                      FROM msafi.dsp_estabelecimento
                     WHERE cod_estab = pcod_estab ( v_cod_estab )
                       AND tipo = 'C';

                    IF v_qtd <> 0 THEN
                        pid_arquivo := pid_arquivo + 1;

                        loga ( 'CD ' || pcod_estab ( v_cod_estab )
                             , FALSE );

                        SELECT cpf_cgc
                          INTO pcnpj
                          FROM x04_pessoa_fis_jur a
                         WHERE cod_fis_jur = pcod_estab ( v_cod_estab )
                           AND valid_fis_jur = (SELECT MAX ( valid_fis_jur )
                                                  FROM x04_pessoa_fis_jur b
                                                 WHERE a.cod_fis_jur = b.cod_fis_jur);

                        parquivo :=
                               'MOV_'
                            || pcnpj
                            || '_'
                            || TO_CHAR ( pdt_ini
                                       , 'YYYYMM' )
                            || '.TXT';

                        ficha4_extrair ( flg_dw
                                       , flg_utl
                                       , pdiretorio
                                       , parquivo
                                       , pdt_periodo
                                       , pid_arquivo
                                       , pcod_estab ( v_cod_estab )
                                       , 'C'
                                       , -- CD
                                        p_proc_instance );

                        IF flg_utl = 'S' THEN
                            loga_directory_path ( 'Movimentação (CD ' || pcod_estab ( v_cod_estab ) || ')'
                                                , pdiretorio
                                                , parquivo );
                        END IF;

                        lib_proc.add (
                                          'Documento de Movimentação (CD '
                                       || pcod_estab ( v_cod_estab )
                                       || ') - "'
                                       || parquivo
                                       || '"'
                                     , 1
                        );
                        lib_proc.add ( ' '
                                     , 1 );
                    END IF;
                END LOOP;
            END IF;

            loga ( 'EXTRAINDO ARQUIVOS-FIM'
                 , FALSE );

            --==============================
            -- FICHA 4 - Extrair arquivo de Auditoria
            --==============================

            IF flg_audit = 'S' THEN
                loga ( 'EXTRAINDO ARQUIVO AUDITORIA-INI '
                     , FALSE );
                dbms_application_info.set_module ( $$plsql_unit
                                                 , 'F4 CRIANDO ARQUIVOS AUDIT' );

                pid_arquivo := pid_arquivo + 1;

                parquivo :=
                       'AUDITORIA_MOV_'
                    || pcnpj
                    || '_'
                    || TO_CHAR ( pdt_ini
                               , 'YYYYMM' )
                    || '.TXT';

                ficha4_auditoria ( flg_dw
                                 , flg_utl
                                 , pdiretorio
                                 , parquivo
                                 , pdt_periodo
                                 , pid_arquivo
                                 , ''
                                 , --NÃO É NECESSÁRIO INFORMAR ESTAB, POIS SERÃO TODAS AS FILIAIS
                                  'L'
                                 , -- FILIAL
                                  mproc_id );

                IF flg_utl = 'S' THEN
                    loga_directory_path ( 'Auditoria para a Movimentação (Filiais)'
                                        , pdiretorio
                                        , parquivo );
                END IF;

                lib_proc.add ( 'Documento de Auditoria para a Movimentação (Filiais) - "' || parquivo || '"'
                             , 1 );
                lib_proc.add ( ' '
                             , 1 );

                loga ( 'EXTRAINDO ARQUIVO AUDITORIA-FIM '
                     , FALSE );
            END IF;

            ---LOG DE ERROS---
            dbms_application_info.set_module ( $$plsql_unit
                                             , 'F4 LOG DE ERROS' );
            v_sql := 'SELECT COD_ESTAB, STATUS FROM ' || v_tab_part || ' WHERE STATUS <> ''Y'' ';

            BEGIN
                OPEN c_errors FOR v_sql;

                LOOP
                    FETCH c_errors
                        INTO v_cod_estab_e
                           , v_status_e;

                    EXIT WHEN c_errors%NOTFOUND;

                    IF ( v_titulo_erro = 0 ) THEN
                        v_titulo_erro := 1;
                        lib_proc.add ( '- LOG de ERROs: '
                                     , 1 );
                        lib_proc.add ( '----------------------------------------------------------------'
                                     , 1 );
                    END IF;

                    v_count_line := v_count_line + 1;
                    v_error_line :=
                           v_error_line
                        || LPAD ( ' '
                                , 10 )
                        || v_cod_estab_e
                        || ' ('
                        || v_status_e
                        || ')';

                    IF ( v_count_line = 4 ) THEN
                        lib_proc.add ( v_error_line
                                     , 1 );
                        v_count_line := 0;
                        v_error_line := '';
                    END IF;
                END LOOP;

                IF v_count_line > 0 THEN
                    lib_proc.add ( v_error_line
                                 , 1 );
                END IF;
            EXCEPTION
                WHEN OTHERS THEN
                    NULL;
            END;

            lib_proc.add ( ' '
                         , 1 );

            ---
            IF tab_error.COUNT > 0 THEN
                lib_proc.add ( '- LOG de ERROs: '
                             , 1 );
                lib_proc.add ( '----------------------------------------------------------------'
                             , 1 );

                FOR e IN tab_error.FIRST .. tab_error.LAST LOOP
                    lib_proc.add (
                                      '> '
                                   || tab_error ( e ).cod_estab
                                   || ' - '
                                   || tab_error ( e ).status
                                   || ' - '
                                   || tab_error ( e ).error_msg
                                 , 1
                    );
                END LOOP;
            END IF;

            dbms_session.free_unused_user_memory;

            BEGIN
                dbms_session.close_database_link ( 'DBLINK_DBPSTHST' );
            EXCEPTION
                WHEN OTHERS THEN
                    NULL;
            END;

            delete_temp_tbl ( p_proc_instance );
            loga ( '---FIM - FICHA 4: MOVIMENTACAO---'
                 , FALSE );
        --=================================================================================
        -- Ficha 5. Perdas
        --=================================================================================
        ELSIF flg_arq = '5' THEN
            loga ( LPAD ( '-'
                        , 150
                        , '-' )
                 , FALSE );
            loga ( '---INICIO - FICHA 5: PERDAS---'
                 , FALSE );

            FOR v_cod_estab IN pcod_estab.FIRST .. pcod_estab.LAST LOOP
                SELECT ROUND ( dbms_random.VALUE ( 10000000000000
                                                 , 999999999999999 ) )
                  INTO p_proc_instance
                  FROM DUAL;

                ---------------------
                loga ( '>> INICIO ESTAB: ' || pcod_estab ( v_cod_estab ) || ' PROC INSERT ' || p_proc_instance
                     , FALSE );

                DELETE FROM msafi.dpsp_fin151_cat42_ide
                      WHERE cod_filial = pcod_estab ( v_cod_estab )
                        AND periodo = pdt_periodo;

                COMMIT;

                dbms_application_info.set_module ( $$plsql_unit
                                                 , 'F5 Estab: ' || pcod_estab ( v_cod_estab ) );

                parquivo :=
                       'PER_'
                    || pcnpj
                    || '_'
                    || TO_CHAR ( pdt_ini
                               , 'MMYYYY' )
                    || '.TXT';

                ficha5_gerar ( pcod_estab ( v_cod_estab )
                             , pdt_ini
                             , pdt_fim
                             , pdt_periodo
                             , v_data_hora_ini
                             , ptipo );
            END LOOP;

            -----------------------
            SELECT COUNT ( 1 )
              INTO v_qtd
              FROM msafi.dpsp_fin151_cat42_perdas
             WHERE proc_id = mproc_id
               AND periodo = pdt_periodo;

            loga ( '::REGISTROS INSERIDOS (DPSP_FIN151_CAT42_PERDAS) - QTDE ' || v_qtd || '::'
                 , FALSE );

            -----------------------
            --Extrair arquivos
            -----------------------
            loga ( 'EXTRAINDO ARQUIVOS-INI'
                 , FALSE );

            FOR v_cod_estab IN pcod_estab.FIRST .. pcod_estab.LAST LOOP
                SELECT cgc
                  INTO v_cnpj
                  FROM msaf.estabelecimento
                 WHERE cod_empresa = msafi.dpsp.empresa
                   AND cod_estab = pcod_estab ( v_cod_estab );

                parquivo :=
                       'PER_'
                    || v_cnpj
                    || '_'
                    || TO_CHAR ( pdt_ini
                               , 'YYYYMM' )
                    || '.TXT';

                ficha5_extrair ( flg_dw
                               , flg_utl
                               , pdiretorio
                               , parquivo
                               , pdt_periodo
                               , pcod_estab ( v_cod_estab ) );

                IF flg_utl = 'S' THEN
                    loga_directory_path ( 'Produtos'
                                        , pdiretorio
                                        , parquivo );
                END IF;
            END LOOP;

            loga ( 'EXTRAINDO ARQUIVOS-FIM'
                 , FALSE );

            loga ( '---FIM - FICHA 5: PERDAS---'
                 , FALSE );
        END IF;

        --=================================================================================
        -- FIM
        --=================================================================================
        loga ( LPAD ( '-'
                    , 150
                    , '-' )
             , FALSE );
        loga ( '---FIM DO PROCESSAMENTO [SUCESSO]---'
             , FALSE );

        --ENVIAR EMAIL DE SUCESSO----------------------------------------
        --ENVIA_EMAIL(MCOD_EMPRESA, PDT_INI, PDT_FIM, '', 'S', V_DATA_HORA_INI);
        -----------------------------------------------------------------

        lib_proc.add ( 'FIM DO PROCESSAMENTO [SUCESSO]' );
        lib_proc.add ( ' ' );
        lib_proc.add ( 'Favor verificar LOG para detalhes.' );
        lib_proc.close;
        RETURN mproc_id;
    EXCEPTION
        WHEN OTHERS THEN
            loga ( 'SQLERRM: ' || SQLERRM
                 , FALSE );
            lib_proc.add_log ( 'Erro não tratado: ' || dbms_utility.format_error_backtrace
                             , 1 );
            lib_proc.add_log ( 'SQLERRM: ' || SQLERRM
                             , 1 );
            lib_proc.add ( 'ERRO !' );
            lib_proc.add ( dbms_utility.format_error_backtrace );

            --ENVIAR EMAIL DE ERRO-------------------------------------------
            --ENVIA_EMAIL(MCOD_EMPRESA,
            --            PDT_INI,
            --            PDT_FIM,
            --            SQLERRM,
            --            'E',
            --            V_DATA_HORA_INI);
            -----------------------------------------------------------------

            lib_proc.close;
            COMMIT;
            RETURN mproc_id;
    END;

    PROCEDURE save_tmp_control ( vp_proc_id IN INTEGER
                               , vp_proc_instance IN NUMBER
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
        INSERT INTO msafi.dpsp_msaf_tmp_control
             VALUES ( mproc_id
                    , vp_table_name
                    , SYSDATE
                    , mnm_usuario
                    , v_sid );

        COMMIT;
    END;

    PROCEDURE drop_old_tmp ( vp_proc_instance IN NUMBER )
    IS
        CURSOR c_old_tmp
        IS
            SELECT tabs.owner || '.' || ctrl.table_name AS table_name
                 , ctrl.table_name AS table_for_delete
                 , ctrl.proc_id
              FROM msafi.dpsp_msaf_tmp_control ctrl
                 , all_tables tabs
             WHERE ctrl.table_name = tabs.table_name
               AND TRUNC ( ( ( ( 86400 * ( SYSDATE - dttm_created ) ) / 60 ) / 60 ) / 24 ) >= 2;

        l_table_name VARCHAR2 ( 30 );
    BEGIN
        loga ( 'DROP_OLD_TMP'
             , FALSE );

        ---> Dropar tabelas TMP que tiveram processo interrompido a mais de 2 dias
        FOR c IN c_old_tmp LOOP
            --
            BEGIN
                EXECUTE IMMEDIATE 'DROP TABLE ' || c.table_name;
            EXCEPTION
                WHEN OTHERS THEN
                    NULL;
            END;

            ---
            DELETE msafi.dpsp_msaf_tmp_control
             WHERE table_name = c.table_for_delete
               AND proc_id = c.proc_id;

            COMMIT;
        END LOOP;
    END;

    PROCEDURE delete_temp_tbl ( vp_proc_id IN NUMBER )
    IS
    BEGIN
        FOR temp_table IN ( SELECT tabs.owner || '.' || ctrl.table_name AS table_name
                                 , ctrl.table_name AS table_for_delete
                              FROM msafi.dpsp_msaf_tmp_control ctrl
                                 , all_tables tabs
                             WHERE ctrl.table_name = tabs.table_name
                               AND proc_id = vp_proc_id ) LOOP
            BEGIN
                ---
                EXECUTE IMMEDIATE 'DROP TABLE ' || temp_table.table_name;
            --
            END;

            DELETE msafi.dpsp_msaf_tmp_control
             WHERE proc_id = vp_proc_id
               AND table_name = temp_table.table_for_delete;

            COMMIT;
        END LOOP;

        --- checar TMPs de processos interrompidos e dropar
        drop_old_tmp ( vp_proc_id );
    END; --PROCEDURE DELETE_TEMP_TBL

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

    PROCEDURE cabecalho ( pnm_empresa VARCHAR2
                        , pcnpj VARCHAR2
                        , flg_arq CHAR
                        , pdt_ini DATE
                        , pcod_estado VARCHAR2
                        , v_data_hora_ini VARCHAR2 )
    IS
    BEGIN
        IF vn_linha >= 48
       AND vn_pagina = 1 THEN
            /* Imprime - Cabeçalho do Relatório */
            vs_mlinha := NULL;
            vs_mlinha :=
                lib_str.w ( vs_mlinha
                          , 'Empresa: ' || mcod_empresa || ' - ' || pnm_empresa
                          , 1 );

            vs_mlinha :=
                lib_str.w ( vs_mlinha
                          ,    'Página: '
                            || LPAD ( vn_pagina
                                    , 5
                                    , '0' )
                          , 136 );
            lib_proc.add ( vs_mlinha
                         , NULL
                         , NULL
                         , 1 );

            vs_mlinha := NULL;
            vs_mlinha :=
                lib_str.w ( vs_mlinha
                          , 'CNPJ: ' || pcnpj
                          , 1 );
            lib_proc.add ( vs_mlinha
                         , NULL
                         , NULL
                         , 1 );

            vs_mlinha := NULL;
            vs_mlinha :=
                lib_str.w ( vs_mlinha
                          , 'Data de Processamento: ' || v_data_hora_ini
                          , 1 );
            lib_proc.add ( vs_mlinha );
            vs_mlinha := NULL;

            vs_mlinha := NULL;
            vs_mlinha :=
                lib_str.w ( vs_mlinha
                          , LPAD ( '-'
                                 , 150
                                 , '-' )
                          , 1 );
            lib_proc.add ( vs_mlinha
                         , NULL
                         , NULL
                         , 1 );

            vs_mlinha := NULL;
            vs_mlinha := mnm_tipo || ' - ' || mnm_cproc;
            lib_proc.add ( vs_mlinha
                         , NULL
                         , NULL
                         , 1 );

            vs_mlinha := NULL;
            vs_mlinha :=
                   'Ficha '
                || ( CASE
                        WHEN flg_arq = 1 THEN '1. Dados da Empresa'
                        WHEN flg_arq = 2 THEN '2. Produtos'
                        WHEN flg_arq = 3 THEN '3. Inventário'
                        WHEN flg_arq = 4 THEN '4. Movimentação'
                        WHEN flg_arq = 5 THEN '5. Perdas'
                    END );
            lib_proc.add ( vs_mlinha
                         , NULL
                         , NULL
                         , 1 );

            vs_mlinha := NULL;
            vs_mlinha :=
                   'Periodo: '
                || TO_CHAR ( pdt_ini
                           , 'MM/YYYY' );
            lib_proc.add ( vs_mlinha
                         , NULL
                         , NULL
                         , 1 );

            vs_mlinha := NULL;
            vs_mlinha := 'UF: ' || ( CASE WHEN pcod_estado = '%' THEN 'Todas as UFs' ELSE pcod_estado END );
            lib_proc.add ( vs_mlinha
                         , NULL
                         , NULL
                         , 1 );

            vs_mlinha :=
                lib_str.w ( vs_mlinha
                          , LPAD ( '-'
                                 , 150
                                 , '-' )
                          , 1 );
            lib_proc.add ( vs_mlinha
                         , NULL
                         , NULL
                         , 1 );

            vs_mlinha := NULL;
            vs_mlinha :=
                lib_str.w ( vs_mlinha
                          , LPAD ( '-'
                                 , 150
                                 , '-' )
                          , 1 );
            lib_proc.add ( vs_mlinha
                         , NULL
                         , NULL
                         , 1 );

            vs_mlinha := NULL;
            vs_mlinha :=
                lib_str.w ( vs_mlinha
                          , ' '
                          , 1 );
            lib_proc.add ( vs_mlinha
                         , NULL
                         , NULL
                         , 1 );
        END IF;

        IF vn_linha >= 48
       AND vn_pagina = 2 THEN
            NULL;
        END IF;
    END cabecalho;

    PROCEDURE envia_email ( vp_cod_empresa IN VARCHAR2
                          , vp_data_ini IN DATE
                          , vp_data_fim IN DATE
                          , vp_msg_oracle IN VARCHAR2
                          , vp_tipo IN VARCHAR2
                          , vp_data_hora_ini IN VARCHAR2 )
    IS
        v_txt_email VARCHAR2 ( 2000 ) := '';
        v_assunto VARCHAR2 ( 100 ) := '';
        v_horas NUMBER;
        v_minutos NUMBER;
        v_segundos NUMBER;
        v_tempo_exec VARCHAR2 ( 50 );
    BEGIN
        --CALCULAR TEMPO DE EXECUCAO DO RELATORIO
        SELECT   TRUNC (   (   (   86400
                                 * (   SYSDATE
                                     - TO_DATE ( vp_data_hora_ini
                                               , 'DD/MM/YYYY HH24:MI.SS' ) ) )
                             / 60 )
                         / 60 )
               -   24
                 * ( TRUNC (   (   (   (   86400
                                         * (   SYSDATE
                                             - TO_DATE ( vp_data_hora_ini
                                                       , 'DD/MM/YYYY HH24:MI.SS' ) ) )
                                     / 60 )
                                 / 60 )
                             / 24 ) )
             ,   TRUNC (   (   86400
                             * (   SYSDATE
                                 - TO_DATE ( vp_data_hora_ini
                                           , 'DD/MM/YYYY HH24:MI.SS' ) ) )
                         / 60 )
               -   60
                 * ( TRUNC (   (   (   86400
                                     * (   SYSDATE
                                         - TO_DATE ( vp_data_hora_ini
                                                   , 'DD/MM/YYYY HH24:MI.SS' ) ) )
                                 / 60 )
                             / 60 ) )
             ,   TRUNC (   86400
                         * (   SYSDATE
                             - TO_DATE ( vp_data_hora_ini
                                       , 'DD/MM/YYYY HH24:MI.SS' ) ) )
               -   60
                 * ( TRUNC (   (   86400
                                 * (   SYSDATE
                                     - TO_DATE ( vp_data_hora_ini
                                               , 'DD/MM/YYYY HH24:MI.SS' ) ) )
                             / 60 ) )
          INTO v_horas
             , v_minutos
             , v_segundos
          FROM DUAL;

        v_tempo_exec := v_horas || ':' || v_minutos || '.' || v_segundos;

        IF ( vp_tipo = 'E' ) THEN
            --VP_TIPO = 'E' (ERRO) OU 'S' (SUCESSO)

            v_txt_email := 'ERRO geração dos arquivos da CAT42 - ' || mnm_cproc || '!';
            v_txt_email := v_txt_email || CHR ( 13 ) || '>> Parâmetros: ';
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Empresa : ' || vp_cod_empresa;
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Data Início : ' || vp_data_ini;
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Data Fim : ' || vp_data_fim;
            v_txt_email := v_txt_email || CHR ( 13 ) || '>> LOG: ';
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Executado por : ' || mnm_usuario;
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Hora Início : ' || vp_data_hora_ini;
            v_txt_email :=
                   v_txt_email
                || CHR ( 13 )
                || ' - Hora Término : '
                || TO_CHAR ( SYSDATE
                           , 'DD/MM/YYYY HH24:MI.SS' );
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Tempo Execução	: ' || v_tempo_exec;
            v_txt_email := v_txt_email || CHR ( 13 ) || '<< ERRO >> ' || vp_msg_oracle;
            v_assunto := 'Mastersaf - ' || mnm_cproc || ' apresentou ERRO';
            notifica ( ''
                     , 'S'
                     , v_assunto
                     , v_txt_email
                     , '$$PLSQL_UNIT' );
        ELSE
            v_txt_email := 'Processo geração ' || mnm_cproc || ' com SUCESSO.';
            v_txt_email := v_txt_email || CHR ( 13 ) || '>> Parâmetros: ';
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Empresa : ' || vp_cod_empresa;
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Data Início : ' || vp_data_ini;
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Data Fim : ' || vp_data_fim;
            v_txt_email := v_txt_email || CHR ( 13 ) || '>> LOG: ';
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Executado por : ' || mnm_usuario;
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Hora Início : ' || vp_data_hora_ini;
            v_txt_email :=
                   v_txt_email
                || CHR ( 13 )
                || ' - Hora Término : '
                || TO_CHAR ( SYSDATE
                           , 'DD/MM/YYYY HH24:MI.SS' );
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Tempo Execução : ' || v_tempo_exec;
            v_assunto := 'Mastersaf - ' || mnm_cproc || ' Concluído';
            notifica ( 'S'
                     , ''
                     , v_assunto
                     , v_txt_email
                     , '$$PLSQL_UNIT' );
        END IF;
    END;

    PROCEDURE loga_directory_path ( pdesc VARCHAR2
                                  , pdiretorio VARCHAR2
                                  , parquivo VARCHAR2 )
    IS
        ppath VARCHAR2 ( 100 );
    BEGIN
        SELECT directory_path
          INTO ppath
          FROM all_directories
         WHERE directory_name = pdiretorio;

        loga ( ' '
             , FALSE );
        loga (
                  'Processo finalizado com sucesso: '
               || CHR ( 13 )
               || ''
               || CHR ( 13 )
               || 'Documento "'
               || pdesc
               || '"  salvo em '
               || ppath
               || ' como '
               || parquivo
               || CHR ( 13 )
               || ''
             , FALSE
        );
        loga ( ' '
             , FALSE );

        lib_proc.add ( 'Documento "' || pdesc || '"  salvo em ' || ppath || ' como ' || parquivo
                     , 1 );
        lib_proc.add ( ' '
                     , 1 );
    END;

    PROCEDURE ult_entrada_vero ( p_cod_estab VARCHAR2
                               , pdt_periodo INTEGER
                               , p_tab_mov VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 12000 );
    BEGIN
        ---ENTRADA LOJAS SP ORIGEM ST910
        dbms_application_info.set_module ( vg_module
                                         , 'F4 ENT LOJA <- ORIGEM ST910' );
        v_sql := 'BEGIN ';
        v_sql := v_sql || 'FOR C IN (SELECT /*+ DRIVING_SITE(A) */ ';
        v_sql := v_sql || '           C.ROWID, C.COD_PART, A.NF_BRL_ID, B.NF_BRL_LINE_NUM, ';
        v_sql := v_sql || '           REPLACE(B.CFO_BRL_CD,''.'','''') AS CFO_BRL_CD ';
        v_sql := v_sql || '            FROM MSAFI.PS_AR_NFRET_BBL       A, ';
        v_sql := v_sql || '                 MSAFI.PS_AR_ITENS_NF_BBL    B, ';
        v_sql := v_sql || '                 MSAFI.' || p_tab_mov || ' C ';
        v_sql := v_sql || '           WHERE A.BUSINESS_UNIT = B.BUSINESS_UNIT ';
        v_sql := v_sql || '             AND A.NF_BRL_ID = B.NF_BRL_ID ';
        v_sql := v_sql || '             AND C.CHV_DOC   = A.NFEE_KEY_BBL ';
        v_sql := v_sql || '             AND C.COD_ITEM = B.INV_ITEM_ID ';
        v_sql := v_sql || '             AND C.NUM_ITEM = B.NF_BRL_LINE_NUM ';
        ---
        v_sql := v_sql || '             AND C.COD_PART = A.BUSINESS_UNIT '; --SAIDAS DO ST910 PARA LOJAS
        ---
        v_sql := v_sql || '             AND C.COD_PART   = ''ST910'' ';
        v_sql := v_sql || '             AND C.COD_FILIAL = ''' || p_cod_estab || ''' ';
        v_sql := v_sql || '             AND C.PERIODO    = ' || pdt_periodo || ' ';
        v_sql := v_sql || '             AND C.MOVTO_E_S <> ''9'' ';
        ---
        v_sql := v_sql || '          ) LOOP ';
        ---
        v_sql := v_sql || '  UPDATE MSAFI.' || p_tab_mov || ' D ';
        v_sql := v_sql || '     SET D.VLR_ICMS    = NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.TAX_BRL_AMT ';
        v_sql := v_sql || '                               FROM MSAFI.PS_AR_IMP_BBL TX ';
        v_sql := v_sql || '                              WHERE TX.BUSINESS_UNIT = C.COD_PART ';
        v_sql := v_sql || '                                AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                AND TX.NF_BRL_ID = C.NF_BRL_ID ';
        v_sql := v_sql || '                                AND TX.TAX_ID_BBL = ''ICMS''), ';
        v_sql := v_sql || '                             0), ';
        v_sql := v_sql || '         D.VLR_BASE_ICMS = NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.TAX_BRL_BSE ';
        v_sql := v_sql || '                               FROM MSAFI.PS_AR_IMP_BBL TX ';
        v_sql := v_sql || '                              WHERE TX.BUSINESS_UNIT = C.COD_PART ';
        v_sql := v_sql || '                                AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                AND TX.NF_BRL_ID = C.NF_BRL_ID ';
        v_sql := v_sql || '                                AND TX.TAX_ID_BBL = ''ICMS''), ';
        v_sql := v_sql || '                             0),          ';
        v_sql := v_sql || '         D.ALIQ_ICMS    = NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.TAX_BRL_PCT '; --ALIQUOTA ICMS
        v_sql := v_sql || '                               FROM MSAFI.PS_AR_IMP_BBL TX ';
        v_sql := v_sql || '                              WHERE TX.BUSINESS_UNIT = C.COD_PART ';
        v_sql := v_sql || '                                AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                AND TX.NF_BRL_ID = C.NF_BRL_ID ';
        v_sql := v_sql || '                                AND TX.TAX_ID_BBL = ''ICMS''), ';
        v_sql := v_sql || '                             0),     ';
        v_sql := v_sql || '         D.VLR_ICMS_ST = NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.TAX_BRL_AMT ';
        v_sql := v_sql || '                               FROM MSAFI.PS_AR_IMP_BBL TX ';
        v_sql := v_sql || '                              WHERE TX.BUSINESS_UNIT = C.COD_PART ';
        v_sql := v_sql || '                                AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                AND TX.NF_BRL_ID = C.NF_BRL_ID ';
        v_sql := v_sql || '                                AND TX.TAX_ID_BBL = ''ICMST''), ';
        v_sql := v_sql || '                             0), ';
        v_sql := v_sql || '         D.VLR_BASE_ICMS_ST = NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.TAX_BRL_BSE ';
        v_sql := v_sql || '                                   FROM MSAFI.PS_AR_IMP_BBL TX ';
        v_sql := v_sql || '                                   WHERE TX.BUSINESS_UNIT = C.COD_PART ';
        v_sql := v_sql || '                                     AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                     AND TX.NF_BRL_ID = C.NF_BRL_ID ';
        v_sql := v_sql || '                                     AND TX.TAX_ID_BBL = ''ICMST''), ';
        v_sql := v_sql || '                             0), ';
        v_sql := v_sql || '         D.CFOP_FORN    = C.CFO_BRL_CD, ';
        v_sql := v_sql || '         D.ORIGEM_ICMS  = ''L'', ';
        v_sql := v_sql || '         D.TAX_CONTROLE = ''G'' ';
        v_sql := v_sql || '   WHERE ROWID = C.ROWID; ';
        ---
        v_sql := v_sql || 'COMMIT; ';
        v_sql := v_sql || 'END LOOP; ';
        v_sql := v_sql || 'END; ';

        EXECUTE IMMEDIATE v_sql;

        IF ( pdt_periodo <= 201611 ) THEN --CONSULTAR NA BASE HIST DO PSFT
            ---ENTRADA LOJAS SP ORIGEM ST910
            dbms_application_info.set_module ( vg_module
                                             , 'F4 ENT LOJA <- ORIGEM ST910 HIST' );
            v_sql := 'BEGIN ';
            v_sql := v_sql || 'FOR C IN (SELECT /*+ DRIVING_SITE(A) */ ';
            v_sql := v_sql || '          C.ROWID, C.COD_PART, A.NF_BRL_ID, B.NF_BRL_LINE_NUM, ';
            v_sql := v_sql || '          REPLACE(B.CFO_BRL_CD,''.'','''') AS CFO_BRL_CD ';
            v_sql := v_sql || '            FROM FDSPPRD.PS_AR_NFRET_BBL_BKP_NOV2016@DBLINK_DBPSTHST A, ';
            v_sql := v_sql || '                 FDSPPRD.PS_AR_ITENS_NF_BBL_BKP_NOV2016@DBLINK_DBPSTHST B, ';
            v_sql := v_sql || '                 MSAFI.' || p_tab_mov || ' C ';
            v_sql := v_sql || '          WHERE A.BUSINESS_UNIT = B.BUSINESS_UNIT ';
            v_sql := v_sql || '            AND A.NF_BRL_ID = B.NF_BRL_ID ';
            v_sql := v_sql || '            AND C.CHV_DOC   = A.NFEE_KEY_BBL ';
            v_sql := v_sql || '            AND C.COD_ITEM = B.INV_ITEM_ID ';
            v_sql := v_sql || '            AND C.NUM_ITEM = B.NF_BRL_LINE_NUM ';
            ---
            v_sql := v_sql || '            AND C.COD_PART = A.BUSINESS_UNIT '; --SAIDAS DO ST910 PARA LOJAS
            ---
            v_sql := v_sql || '            AND C.COD_PART   = ''ST910'' ';
            v_sql := v_sql || '            AND C.COD_FILIAL = ''' || p_cod_estab || ''' ';
            v_sql := v_sql || '            AND C.PERIODO    = ' || pdt_periodo || ' ';
            v_sql := v_sql || '            AND C.MOVTO_E_S <> ''9'' ';
            ---
            v_sql := v_sql || '         ) LOOP ';
            ---
            v_sql := v_sql || '  UPDATE MSAFI.' || p_tab_mov || ' D ';
            v_sql := v_sql || '    SET D.VLR_ICMS    = NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.TAX_BRL_AMT ';
            v_sql :=
                v_sql || '                              FROM FDSPPRD.PS_AR_IMP_BBL_BKP_NOV2016@DBLINK_DBPSTHST TX ';
            v_sql := v_sql || '                              WHERE TX.BUSINESS_UNIT = C.COD_PART ';
            v_sql := v_sql || '                                AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
            v_sql := v_sql || '                                AND TX.NF_BRL_ID = C.NF_BRL_ID ';
            v_sql := v_sql || '                                AND TX.TAX_ID_BBL = ''ICMS''), ';
            v_sql := v_sql || '                            0), ';
            v_sql := v_sql || '        D.VLR_BASE_ICMS = NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.TAX_BRL_BSE ';
            v_sql :=
                v_sql || '                              FROM FDSPPRD.PS_AR_IMP_BBL_BKP_NOV2016@DBLINK_DBPSTHST TX ';
            v_sql := v_sql || '                              WHERE TX.BUSINESS_UNIT = C.COD_PART ';
            v_sql := v_sql || '                                AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
            v_sql := v_sql || '                                AND TX.NF_BRL_ID = C.NF_BRL_ID ';
            v_sql := v_sql || '                                AND TX.TAX_ID_BBL = ''ICMS''), ';
            v_sql := v_sql || '                            0),          ';
            v_sql := v_sql || '        D.ALIQ_ICMS    = NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.TAX_BRL_PCT '; --ALIQUOTA ICMS
            v_sql :=
                v_sql || '                              FROM FDSPPRD.PS_AR_IMP_BBL_BKP_NOV2016@DBLINK_DBPSTHST TX ';
            v_sql := v_sql || '                              WHERE TX.BUSINESS_UNIT = C.COD_PART ';
            v_sql := v_sql || '                                AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
            v_sql := v_sql || '                                AND TX.NF_BRL_ID = C.NF_BRL_ID ';
            v_sql := v_sql || '                                AND TX.TAX_ID_BBL = ''ICMS''), ';
            v_sql := v_sql || '                            0),     ';
            v_sql := v_sql || '        D.VLR_ICMS_ST = NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.TAX_BRL_AMT ';
            v_sql :=
                v_sql || '                              FROM FDSPPRD.PS_AR_IMP_BBL_BKP_NOV2016@DBLINK_DBPSTHST TX ';
            v_sql := v_sql || '                              WHERE TX.BUSINESS_UNIT = C.COD_PART ';
            v_sql := v_sql || '                                AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
            v_sql := v_sql || '                                AND TX.NF_BRL_ID = C.NF_BRL_ID ';
            v_sql := v_sql || '                                AND TX.TAX_ID_BBL = ''ICMST''), ';
            v_sql := v_sql || '                            0), ';
            v_sql := v_sql || '        D.VLR_BASE_ICMS_ST = NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.TAX_BRL_BSE ';
            v_sql :=
                v_sql || '                                  FROM FDSPPRD.PS_AR_IMP_BBL_BKP_NOV2016@DBLINK_DBPSTHST TX ';
            v_sql := v_sql || '                                  WHERE TX.BUSINESS_UNIT = C.COD_PART ';
            v_sql := v_sql || '                                    AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
            v_sql := v_sql || '                                    AND TX.NF_BRL_ID = C.NF_BRL_ID ';
            v_sql := v_sql || '                                    AND TX.TAX_ID_BBL = ''ICMST''), ';
            v_sql := v_sql || '                            0), ';
            v_sql := v_sql || '        D.CFOP_FORN    = C.CFO_BRL_CD, ';
            v_sql := v_sql || '        D.ORIGEM_ICMS  = ''L'', ';
            v_sql := v_sql || '        D.TAX_CONTROLE = ''G'' ';
            v_sql := v_sql || '  WHERE ROWID = C.ROWID; ';
            ---
            v_sql := v_sql || 'COMMIT; ';
            v_sql := v_sql || 'END LOOP; ';
            v_sql := v_sql || 'END; ';

            EXECUTE IMMEDIATE v_sql;
        END IF;

        ---SAIDAS LOJAS SP PARA DSP910 OU ST910 - DEVOLUCOES
        dbms_application_info.set_module ( vg_module
                                         , 'F4 SAIDA LOJAS -> CD (DEV)' );
        v_sql := 'BEGIN ';
        v_sql := v_sql || 'FOR C IN (SELECT C.ROWID, C.BUSINESS_UNIT, X07.NUM_CONTROLE_DOCTO AS NF_BRL_ID,  ';
        v_sql := v_sql || '                 C.NUM_ITEM AS NF_BRL_LINE_NUM, C.COD_PART ';
        v_sql := v_sql || '          FROM MSAF.X07_DOCTO_FISCAL X07, ';
        v_sql := v_sql || '                MSAFI.' || p_tab_mov || ' C ';
        v_sql := v_sql || '          WHERE C.COD_PART   IN (''ST910'',''DSP910'',''DSP901'',''DSP902'') ';
        v_sql := v_sql || '            AND C.COD_FILIAL = ''' || p_cod_estab || ''' ';
        v_sql := v_sql || '            AND C.PERIODO    = ' || pdt_periodo || ' ';
        v_sql := v_sql || '            AND C.MOVTO_E_S  = ''9'' ';
        ---
        v_sql := v_sql || '            AND X07.COD_EMPRESA = MSAFI.DPSP.EMPRESA ';
        v_sql := v_sql || '            AND X07.COD_ESTAB = C.COD_FILIAL ';
        v_sql := v_sql || '            AND X07.MOVTO_E_S = ''9'' ';
        v_sql := v_sql || '            AND X07.NUM_AUTENTIC_NFE = C.CHV_DOC ';
        ---
        v_sql := v_sql || '         ) LOOP ';
        ---
        v_sql := v_sql || '  UPDATE MSAFI.' || p_tab_mov || ' D ';
        v_sql := v_sql || '     SET D.VLR_ICMS    = NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.TAX_BRL_AMT ';
        v_sql := v_sql || '                               FROM MSAFI.PS_AR_IMP_BBL TX ';
        v_sql := v_sql || '                              WHERE TX.BUSINESS_UNIT = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                AND TX.NF_BRL_ID = C.NF_BRL_ID ';
        v_sql := v_sql || '                                AND TX.TAX_ID_BBL = ''ICMS''), ';
        v_sql := v_sql || '                             0), ';
        v_sql := v_sql || '         D.VLR_BASE_ICMS = NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.TAX_BRL_BSE ';
        v_sql := v_sql || '                               FROM MSAFI.PS_AR_IMP_BBL TX ';
        v_sql := v_sql || '                              WHERE TX.BUSINESS_UNIT = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                AND TX.NF_BRL_ID = C.NF_BRL_ID ';
        v_sql := v_sql || '                                AND TX.TAX_ID_BBL = ''ICMS''), ';
        v_sql := v_sql || '                             0),          ';
        v_sql := v_sql || '         D.ALIQ_ICMS    = NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.TAX_BRL_PCT  '; --ALIQUOTA ICMS
        v_sql := v_sql || '                               FROM MSAFI.PS_AR_IMP_BBL TX ';
        v_sql := v_sql || '                              WHERE TX.BUSINESS_UNIT = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                AND TX.NF_BRL_ID = C.NF_BRL_ID ';
        v_sql := v_sql || '                                AND TX.TAX_ID_BBL = ''ICMS''), ';
        v_sql := v_sql || '                             0),     ';
        v_sql := v_sql || '         D.VLR_ICMS_ST = DECODE(C.COD_PART,''ST910'', ';
        v_sql := v_sql || '                                  NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.TAX_BRL_AMT ';
        v_sql := v_sql || '                                        FROM MSAFI.PS_AR_IMP_BBL TX ';
        v_sql := v_sql || '                                        WHERE TX.BUSINESS_UNIT = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                          AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                          AND TX.NF_BRL_ID = C.NF_BRL_ID ';
        v_sql := v_sql || '                                          AND TX.TAX_ID_BBL = ''ICMST''), ';
        v_sql := v_sql || '                                      0), ';
        v_sql := v_sql || '                                  NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.DSP_ICMS_AMT_ST ';
        v_sql := v_sql || '                                        FROM MSAFI.PS_NF_LN_BBL_FS TX ';
        v_sql := v_sql || '                                        WHERE TX.BUSINESS_UNIT = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                          AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                          AND TX.NF_BRL_ID = C.NF_BRL_ID), ';
        v_sql := v_sql || '                                      0) ';
        v_sql := v_sql || '                                ),                     ';
        v_sql := v_sql || '         D.VLR_BASE_ICMS_ST = DECODE(C.COD_PART,''ST910'', ';
        v_sql := v_sql || '                                  NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.TAX_BRL_BSE ';
        v_sql := v_sql || '                                      FROM MSAFI.PS_AR_IMP_BBL TX ';
        v_sql := v_sql || '                                      WHERE TX.BUSINESS_UNIT = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                        AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                        AND TX.NF_BRL_ID = C.NF_BRL_ID ';
        v_sql := v_sql || '                                        AND TX.TAX_ID_BBL = ''ICMST''), ';
        v_sql := v_sql || '                                      0), ';
        v_sql := v_sql || '                                  NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.DSP_ICMS_BSS_ST ';
        v_sql := v_sql || '                                        FROM MSAFI.PS_NF_LN_BBL_FS TX ';
        v_sql := v_sql || '                                        WHERE TX.BUSINESS_UNIT = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                          AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                          AND TX.NF_BRL_ID = C.NF_BRL_ID), ';
        v_sql := v_sql || '                                      0) ';
        v_sql := v_sql || '                                ),     ';
        v_sql := v_sql || '         D.ORIGEM_ICMS  = ''L'', ';
        v_sql := v_sql || '         D.TAX_CONTROLE = ''H'' ';
        v_sql := v_sql || '   WHERE ROWID = C.ROWID; ';
        ---
        v_sql := v_sql || 'COMMIT; ';
        v_sql := v_sql || 'END LOOP; ';
        v_sql := v_sql || 'END; ';

        EXECUTE IMMEDIATE v_sql;
    END;

    PROCEDURE ult_entrada_people ( vp_proc_id IN VARCHAR2
                                 , pcod_estab IN VARCHAR2
                                 , pdt_periodo IN INTEGER
                                 , v_tab_nfret IN VARCHAR2
                                 , vp_tipo IN VARCHAR2
                                 , vp_tab_nf IN VARCHAR2
                                 , p_tab_mov IN VARCHAR2 )
    IS
        c_saida_cd SYS_REFCURSOR;
        c_entrada_cd SYS_REFCURSOR;

        TYPE c_tab_nf IS TABLE OF msafi.dpsp_msaf_ps_nf%ROWTYPE;

        tab_nf c_tab_nf;

        v_sql VARCHAR2 ( 5000 );
        v_qtd INTEGER := 0;
        v_commit INTEGER := 0;
        v_partition_ps_nf VARCHAR2 ( 60 );

        v_data_ini DATE
            := TO_DATE ( TO_CHAR ( pdt_periodo ) || '01'
                       , 'YYYYMMDD' );
        v_data_fim DATE
            := LAST_DAY ( TO_DATE ( TO_CHAR ( pdt_periodo ) || '01'
                                  , 'YYYYMMDD' ) );
    BEGIN
        dbms_application_info.set_module ( vg_module
                                         , 'F4 ENTR PSFT SAIDAS' );
        --SAIDAS
        v_sql := 'DECLARE TYPE TT_TAB_NF IS TABLE OF ' || v_tab_nfret || '%ROWTYPE; ';
        v_sql := v_sql || '        TAB_NF TT_TAB_NF := TT_TAB_NF(); ';
        v_sql := v_sql || '        ERRORS NUMBER; ';
        v_sql := v_sql || '        DML_ERRORS EXCEPTION;  ';
        v_sql := v_sql || '        ERR_IDX INTEGER;  ';
        v_sql := v_sql || '        ERR_CODE NUMBER;  ';
        v_sql := v_sql || '        ERR_MSG VARCHAR2(255); ';
        v_sql := v_sql || 'BEGIN ';
        v_sql := v_sql || '  SELECT DISTINCT SAIDA.BUSINESS_UNIT, ';
        v_sql := v_sql || '    SAIDA.NF_BRL_ID, ';
        v_sql := v_sql || '    SAIDA.NFEE_KEY_BBL, ';
        v_sql := v_sql || '    SAIDA.MOVTO_E_S ';
        v_sql := v_sql || '  BULK COLLECT INTO TAB_NF ';
        v_sql := v_sql || '  FROM ( ';
        v_sql := v_sql || '       SELECT /*+DRIVING_SITE(PS)*/ PS.BUSINESS_UNIT, ';
        v_sql := v_sql || '         PS.NF_BRL_ID, ';
        v_sql := v_sql || '         PS.NFEE_KEY_BBL, ';
        v_sql := v_sql || '         MOV.MOVTO_E_S ';
        v_sql := v_sql || '       FROM MSAFI.' || p_tab_mov || ' MOV, ';
        v_sql := v_sql || '            (SELECT /*+CACHE*/ A.BUSINESS_UNIT, A.NF_BRL_ID, A.NFEE_KEY_BBL ';
        v_sql := v_sql || '             FROM MSAFI.PS_AR_NFRET_BBL A) PS ';
        v_sql := v_sql || '       WHERE MOV.CHV_DOC    = PS.NFEE_KEY_BBL ';
        v_sql := v_sql || '         AND MOV.MOVTO_E_S  = ''9'' '; --SAIDAS
        v_sql := v_sql || '         AND MOV.COD_FILIAL = ''' || pcod_estab || ''' ';
        v_sql := v_sql || '         AND MOV.PERIODO    = ' || pdt_periodo || ' ';
        v_sql := v_sql || '    ) SAIDA; ';
        --
        v_sql := v_sql || '  BEGIN ';
        v_sql := v_sql || '     FORALL I IN TAB_NF.FIRST .. TAB_NF.LAST SAVE EXCEPTIONS ';
        v_sql := v_sql || '       INSERT INTO ' || v_tab_nfret || ' VALUES TAB_NF(I); ';
        v_sql := v_sql || '     COMMIT; ';
        v_sql := v_sql || '  EXCEPTION ';
        v_sql := v_sql || '     WHEN OTHERS THEN ';
        v_sql := v_sql || '       ERRORS := SQL%BULK_EXCEPTIONS.COUNT;  ';
        v_sql := v_sql || '       FOR I IN 1..ERRORS LOOP  ';
        v_sql := v_sql || '           ERR_IDX := SQL%BULK_EXCEPTIONS(I).ERROR_INDEX;  ';
        v_sql := v_sql || '           ERR_CODE := SQL%BULK_EXCEPTIONS(I).ERROR_CODE;  ';
        v_sql := v_sql || '           ERR_MSG  := SQLERRM(-SQL%BULK_EXCEPTIONS(I).ERROR_CODE);  ';
        v_sql := v_sql || '           INSERT INTO MSAFI.LOG_GERAL (ORA_ERR_NUMBER1, ORA_ERR_MESG1, COD_EMPRESA, '; --1
        v_sql := v_sql || '                                        COD_ESTAB, NUM_DOCFIS, DATA_FISCAL, ';
        v_sql := v_sql || '                                        SERIE_DOCFIS, COL14, COL15,   ';
        v_sql := v_sql || '                                        COL18, COL19, COL20, ';
        v_sql := v_sql || '                                        COL21, COL22, MOVTO_E_S) ';
        v_sql := v_sql || '                                        VALUES ';
        v_sql := v_sql || '                                         (ERR_CODE, ERR_MSG, MSAFI.DPSP.EMPRESA, '; --1
        v_sql :=
               v_sql
            || '                                         '''
            || pcod_estab
            || ''', TAB_NF(ERR_IDX).BUSINESS_UNIT, TAB_NF(ERR_IDX).NF_BRL_ID, ';
        v_sql :=
               v_sql
            || '                                         TAB_NF(ERR_IDX).NFEE_KEY_BBL, TAB_NF(ERR_IDX).MOVTO_E_S, ''SAIDAS'', ';
        v_sql :=
               v_sql
            || '                                         ''DPSP_FIN151_CAT42_FICHAS_CPROC'', ''ULT_ENTRADA_PEOPLE'', ''CAT42_FICHA4'', ';
        v_sql :=
               v_sql
            || '                                         TO_CHAR(SYSDATE,''DD/MM/YYYY HH24:MI.SS''), '''
            || vp_proc_id
            || ''', '' ''); ';
        v_sql := v_sql || '       END LOOP;  ';
        v_sql := v_sql || '       COMMIT; ';
        v_sql := v_sql || '  END; ';
        --
        v_sql := v_sql || 'END; ';

        BEGIN
            EXECUTE IMMEDIATE v_sql;
        EXCEPTION
            WHEN OTHERS THEN
                dbms_output.put_line ( SQLERRM );
                raise_application_error ( -20001
                                        , '!ERRO ULT_ENTRADA_PEOPLE 1!' );
        END;

        dbms_application_info.set_module ( vg_module
                                         , 'F4 ENTR PSFT ENTRADAS' );
        --ENTRADAS
        v_sql := 'DECLARE TYPE TT_TAB_NF IS TABLE OF ' || v_tab_nfret || '%ROWTYPE; ';
        v_sql := v_sql || '        TAB_NF TT_TAB_NF := TT_TAB_NF(); ';
        v_sql := v_sql || '        ERRORS NUMBER; ';
        v_sql := v_sql || '        DML_ERRORS EXCEPTION;  ';
        v_sql := v_sql || '        ERR_IDX INTEGER;  ';
        v_sql := v_sql || '        ERR_CODE NUMBER;  ';
        v_sql := v_sql || '        ERR_MSG VARCHAR2(255); ';
        v_sql := v_sql || 'BEGIN ';
        v_sql := v_sql || '  SELECT DISTINCT ENTRADA.BUSINESS_UNIT, ';
        v_sql := v_sql || '    ENTRADA.NF_BRL_ID, ';
        v_sql := v_sql || '    ENTRADA.NFEE_KEY_BBL, ';
        v_sql := v_sql || '    ENTRADA.MOVTO_E_S ';
        v_sql := v_sql || '  BULK COLLECT INTO TAB_NF ';
        v_sql := v_sql || '  FROM ( ';
        v_sql := v_sql || '       SELECT /*+DRIVING_SITE(PS)*/ PS.BUSINESS_UNIT, ';
        v_sql := v_sql || '         PS.NF_BRL_ID, ';
        v_sql := v_sql || '         PS.NFEE_KEY_BBL, ';
        v_sql := v_sql || '         MOV.MOVTO_E_S ';
        v_sql := v_sql || '       FROM MSAFI.' || p_tab_mov || ' MOV, ';
        v_sql := v_sql || '            (SELECT /*+CACHE*/ A.BUSINESS_UNIT, A.NF_BRL_ID, A.NFEE_KEY_BBL ';
        v_sql := v_sql || '             FROM MSAFI.PS_AR_NFRET_BBL A) PS ';
        v_sql := v_sql || '       WHERE MOV.CHV_DOC    = PS.NFEE_KEY_BBL '; --CHAVE DE ACESSO IGUAL SAIDA -> ENTRADA
        v_sql := v_sql || '         AND MOV.MOVTO_E_S <> ''9'' '; --ENTRADAS
        v_sql := v_sql || '         AND MOV.COD_FILIAL = ''' || pcod_estab || ''' ';
        v_sql := v_sql || '         AND MOV.PERIODO    = ' || pdt_periodo || ' ';
        v_sql := v_sql || '    ) ENTRADA; ';
        --
        v_sql := v_sql || '  BEGIN ';
        v_sql := v_sql || '     FORALL I IN TAB_NF.FIRST .. TAB_NF.LAST SAVE EXCEPTIONS ';
        v_sql := v_sql || '       INSERT INTO ' || v_tab_nfret || ' VALUES TAB_NF(I); ';
        v_sql := v_sql || '     COMMIT; ';
        v_sql := v_sql || '  EXCEPTION ';
        v_sql := v_sql || '     WHEN OTHERS THEN ';
        v_sql := v_sql || '       ERRORS := SQL%BULK_EXCEPTIONS.COUNT;  ';
        v_sql := v_sql || '       FOR I IN 1..ERRORS LOOP  ';
        v_sql := v_sql || '           ERR_IDX := SQL%BULK_EXCEPTIONS(I).ERROR_INDEX;  ';
        v_sql := v_sql || '           ERR_CODE := SQL%BULK_EXCEPTIONS(I).ERROR_CODE;  ';
        v_sql := v_sql || '           ERR_MSG  := SQLERRM(-SQL%BULK_EXCEPTIONS(I).ERROR_CODE);  ';
        v_sql := v_sql || '           INSERT INTO MSAFI.LOG_GERAL (ORA_ERR_NUMBER1, ORA_ERR_MESG1, COD_EMPRESA, '; --1
        v_sql := v_sql || '                                        COD_ESTAB, NUM_DOCFIS, DATA_FISCAL, ';
        v_sql := v_sql || '                                        SERIE_DOCFIS, COL14, COL15,   ';
        v_sql := v_sql || '                                        COL18, COL19, COL20, ';
        v_sql := v_sql || '                                        COL21, COL22, MOVTO_E_S) ';
        v_sql := v_sql || '                                        VALUES ';
        v_sql := v_sql || '                                         (ERR_CODE, ERR_MSG, MSAFI.DPSP.EMPRESA, '; --1
        v_sql :=
               v_sql
            || '                                         '''
            || pcod_estab
            || ''', TAB_NF(ERR_IDX).BUSINESS_UNIT, TAB_NF(ERR_IDX).NF_BRL_ID, ';
        v_sql :=
               v_sql
            || '                                         TAB_NF(ERR_IDX).NFEE_KEY_BBL, TAB_NF(ERR_IDX).MOVTO_E_S, ''ENTRADAS'', ';
        v_sql :=
               v_sql
            || '                                         ''DPSP_FIN151_CAT42_FICHAS_CPROC'', ''ULT_ENTRADA_PEOPLE'', ''CAT42_FICHA4'', ';
        v_sql :=
               v_sql
            || '                                         TO_CHAR(SYSDATE,''DD/MM/YYYY HH24:MI.SS''), '''
            || vp_proc_id
            || ''', '' ''); ';
        v_sql := v_sql || '       END LOOP;  ';
        v_sql := v_sql || '       COMMIT; ';
        v_sql := v_sql || '  END; ';
        --
        v_sql := v_sql || 'END; ';

        BEGIN
            EXECUTE IMMEDIATE v_sql;
        EXCEPTION
            WHEN OTHERS THEN
                dbms_output.put_line ( SQLERRM );
                raise_application_error ( -20001
                                        , '!ERRO ULT_ENTRADA_PEOPLE 2!' );
        END;

        IF ( vp_tipo = 'L' ) THEN
            dbms_application_info.set_module ( vg_module
                                             , 'F4 ENTR PSFT UPD LOJA' );
            dbms_output.put_line ( 'F4 ENTR PSFT UPD LOJA' );
            --LOJAs
            v_sql := 'BEGIN FOR C IN (SELECT /*+ DRIVING_SITE(B) */ ';
            v_sql :=
                   v_sql
                || '             C.ROWID, C.COD_PART, A.NF_BRL_ID, B.NF_BRL_LINE_NUM, B.INV_ITEM_ID, B.BUSINESS_UNIT, B.CFO_BRL_CD ';
            v_sql := v_sql || '              FROM ' || v_tab_nfret || '       A, ';
            v_sql := v_sql || '                   MSAFI.PS_AR_ITENS_NF_BBL    B, ';
            v_sql := v_sql || '                   MSAFI.' || p_tab_mov || ' C ';
            v_sql := v_sql || '             WHERE A.BUSINESS_UNIT = B.BUSINESS_UNIT ';
            v_sql := v_sql || '               AND A.NF_BRL_ID = B.NF_BRL_ID ';
            v_sql := v_sql || '               AND A.MOVTO_E_S = C.MOVTO_E_S ';
            v_sql := v_sql || '               AND C.CHV_DOC   = A.NFEE_KEY_BBL ';
            v_sql := v_sql || '               AND C.COD_ITEM  = B.INV_ITEM_ID ';
            v_sql := v_sql || '               AND C.NUM_ITEM  = B.NF_BRL_LINE_NUM ';
            v_sql :=
                   v_sql
                || '               AND TO_NUMBER(REGEXP_REPLACE(C.COD_PART,''A|B|C|D|E|F|G|H|I|J|K|L|M|N|O|P|Q|R|S|U|V|W|X|Y|Z'','''')) = TO_NUMBER(REGEXP_REPLACE(B.BUSINESS_UNIT,''A|B|C|D|E|F|G|H|I|J|K|L|M|N|O|P|Q|R|S|U|V|W|X|Y|Z'',''''))  ';
            v_sql := v_sql || '               AND C.COD_PART   IN (''DSP901'',''DSP902'',''DSP910'') ';
            v_sql := v_sql || '               AND C.MOVTO_E_S  = ''9'' ';
            v_sql := v_sql || '               AND C.COD_FILIAL = ''' || pcod_estab || ''' ';
            v_sql := v_sql || '               AND C.PERIODO    = ' || pdt_periodo || ' ';
            ---
            v_sql := v_sql || '                       ) LOOP ';
            ---
            v_sql := v_sql || '    UPDATE MSAFI.' || p_tab_mov || ' D ';
            v_sql := v_sql || '       SET D.VLR_ICMS    = NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.ICMSTAX_BRL_BSE ';
            v_sql := v_sql || '                                 FROM MSAFI.PS_NF_LN_BBL_FS TX ';
            v_sql := v_sql || '                                WHERE TX.BUSINESS_UNIT =  C.BUSINESS_UNIT ';
            v_sql := v_sql || '                                  AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
            v_sql := v_sql || '                                  AND TX.INV_ITEM_ID = C.INV_ITEM_ID ';
            v_sql := v_sql || '                                  AND TX.NF_BRL_ID = C.NF_BRL_ID ';
            v_sql := v_sql || '                                  ), ';
            v_sql := v_sql || '                               0), ';
            v_sql := v_sql || '           D.VLR_BASE_ICMS = NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.ICMSTAX_BRL_BSS ';
            v_sql := v_sql || '                                  FROM MSAFI.PS_NF_LN_BBL_FS TX ';
            v_sql := v_sql || '                                  WHERE TX.BUSINESS_UNIT =  C.BUSINESS_UNIT ';
            v_sql := v_sql || '                                    AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
            v_sql := v_sql || '                                    AND TX.INV_ITEM_ID = C.INV_ITEM_ID ';
            v_sql := v_sql || '                                    AND TX.NF_BRL_ID = C.NF_BRL_ID ';
            v_sql := v_sql || '                                  ), ';
            v_sql := v_sql || '                               0), ';
            v_sql := v_sql || '           D.ALIQ_ICMS    = NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.ICMSTAX_BRL_PCT '; --ALIQUOTA ICMS PROPRIO
            v_sql := v_sql || '                                 FROM MSAFI.PS_NF_LN_BBL_FS TX ';
            v_sql := v_sql || '                                WHERE TX.BUSINESS_UNIT =  C.BUSINESS_UNIT ';
            v_sql := v_sql || '                                  AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
            v_sql := v_sql || '                                  AND TX.INV_ITEM_ID = C.INV_ITEM_ID ';
            v_sql := v_sql || '                                  AND TX.NF_BRL_ID = C.NF_BRL_ID ';
            v_sql := v_sql || '                                  ), ';
            v_sql := v_sql || '                               0), ';
            v_sql := v_sql || '           D.VLR_ICMS_ST = NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.DSP_ICMS_AMT_ST ';
            v_sql := v_sql || '                                 FROM MSAFI.PS_NF_LN_BBL_FS TX ';
            v_sql := v_sql || '                                WHERE TX.BUSINESS_UNIT =  C.BUSINESS_UNIT ';
            v_sql := v_sql || '                                  AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
            v_sql := v_sql || '                                  AND TX.INV_ITEM_ID = C.INV_ITEM_ID ';
            v_sql := v_sql || '                                  AND TX.NF_BRL_ID = C.NF_BRL_ID ';
            v_sql := v_sql || '                                  AND SIT_TRIB_ICMS_BBL = ''60''), ';
            v_sql := v_sql || '                               0), ';
            v_sql := v_sql || '           D.VLR_BASE_ICMS_ST = NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.DSP_ICMS_BSS_ST ';
            v_sql := v_sql || '                                     FROM MSAFI.PS_NF_LN_BBL_FS TX ';
            v_sql := v_sql || '                                     WHERE TX.BUSINESS_UNIT =  C.BUSINESS_UNIT ';
            v_sql := v_sql || '                                       AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
            v_sql := v_sql || '                                       AND TX.INV_ITEM_ID = C.INV_ITEM_ID ';
            v_sql := v_sql || '                                       AND TX.NF_BRL_ID = C.NF_BRL_ID ';
            v_sql := v_sql || '                                       AND SIT_TRIB_ICMS_BBL = ''60''), ';
            v_sql := v_sql || '                               0), ';
            v_sql := v_sql || '           D.CFOP_FORN    = C.CFO_BRL_CD, ';
            v_sql := v_sql || '           D.ORIGEM_ICMS  = ''L'', ';
            v_sql := v_sql || '           D.TAX_CONTROLE = ''I'' ';
            v_sql := v_sql || '     WHERE ROWID        = C.ROWID ';
            v_sql := v_sql || '       AND D.PERIODO    = ' || pdt_periodo || ' ';
            v_sql := v_sql || '       AND D.COD_FILIAL = ''' || pcod_estab || ''' ';
            v_sql := v_sql || '       AND D.MOVTO_E_S  = ''9''; ';
            ---
            v_sql := v_sql || '  COMMIT; ';
            v_sql := v_sql || '  END LOOP; END; ';

            BEGIN
                EXECUTE IMMEDIATE v_sql;
            EXCEPTION
                WHEN OTHERS THEN
                    dbms_output.put_line ( SQLERRM );
                    raise_application_error ( -20001
                                            , '!ERRO ULT_ENTRADA_PEOPLE 3!' );
            END;
        ELSE
            --OBTER NOME DA PARTICAO
            BEGIN
                SELECT ' PARTITION (' || a.partition_name || ') '
                  INTO v_partition_ps_nf
                  FROM TABLE ( msafi.dpsp_recupera_particao ( 'MSAFI'
                                                            , 'DPSP_MSAF_PS_NF'
                                                            , v_data_ini
                                                            , v_data_fim ) ) a;
            EXCEPTION
                WHEN OTHERS THEN
                    v_partition_ps_nf := ' ';
            END;

            dbms_application_info.set_module ( vg_module
                                             , 'F4 CD -> LOJA' );
            dbms_output.put_line ( 'F4 CD -> LOJA' );
            v_qtd := 0;
            --CDs - SAIDA DE CD PARA LOJA - ABASTECIMENTO / TRANSFERENCIA
            --CARREGAR NFs de SAIDA DO CD PARA TABELA LOCAL NO MSAF
            v_sql := 'WITH TAB_MOV AS ';
            v_sql := v_sql || '( ';
            v_sql := v_sql || 'SELECT /*+MATERIALIZE*/ MOV.BUSINESS_UNIT, ';
            v_sql := v_sql || '        MOV.NF_BRL_ID, MOV.NUM_ITEM, ';
            v_sql := v_sql || '        MOV.COD_FILIAL, ';
            v_sql := v_sql || '        MOV.DATA, ';
            v_sql := v_sql || '        MOV.MOVTO_E_S, ';
            v_sql := v_sql || '        MOV.COD_ITEM, ';
            v_sql := v_sql || '        MOV.CFOP, ';
            v_sql := v_sql || '        MSAFI.DPSP.EMPRESA AS COD_EMPRESA, ';
            v_sql := v_sql || '        '''' AS CFOP_FORN, ';
            v_sql := v_sql || '        0 AS VLR_BASE_ST_RET, ';
            v_sql := v_sql || '        0 AS VLR_ST_RET, ';
            v_sql := v_sql || '        MOV.CHV_DOC ';
            v_sql := v_sql || '    FROM MSAFI.' || p_tab_mov || ' MOV ';
            v_sql := v_sql || '    WHERE MOV.COD_FILIAL = ''' || pcod_estab || ''' ';
            v_sql := v_sql || '      AND MOV.PERIODO    = ' || pdt_periodo || ' ';
            v_sql := v_sql || '      AND MOV.MOVTO_E_S  = ''9'' ';
            v_sql := v_sql || '      AND MOV.CFOP       = ''5409'' ';
            v_sql :=
                   v_sql
                || '      AND MOV.COD_PART IN (SELECT COD_ESTAB FROM MSAFI.DSP_ESTABELECIMENTO WHERE COD_EMPRESA = MSAFI.DPSP.EMPRESA AND TIPO = ''L'') ';
            v_sql := v_sql || '      AND NOT EXISTS (SELECT ''Y''  ';
            v_sql := v_sql || '                      FROM MSAFI.DPSP_MSAF_PS_NF ' || v_partition_ps_nf || ' LOC ';
            v_sql := v_sql || '                      WHERE LOC.BUSINESS_UNIT    = MOV.BUSINESS_UNIT ';
            v_sql := v_sql || '                        AND LOC.NF_BRL_ID        = MOV.NF_BRL_ID ';
            v_sql := v_sql || '                        AND LOC.NF_BRL_LINE_NUM  = MOV.NUM_ITEM ';
            v_sql := v_sql || '                        AND LOC.COD_ESTAB        = MOV.COD_FILIAL ';
            v_sql := v_sql || '                        AND LOC.DATA_FISCAL      = MOV.DATA ';
            v_sql := v_sql || '                        AND LOC.MOVTO_E_S        = MOV.MOVTO_E_S ';
            v_sql := v_sql || '                        AND LOC.NUM_AUTENTIC_NFE = MOV.CHV_DOC) ';
            v_sql := v_sql || ') ';
            v_sql := v_sql || 'SELECT /*+DRIVING_SITE(PS)*/ MOV.BUSINESS_UNIT, ';
            v_sql := v_sql || '      MOV.NF_BRL_ID, ';
            v_sql := v_sql || '      MOV.NUM_ITEM, ';
            v_sql := v_sql || '      MOV.COD_EMPRESA, ';
            v_sql := v_sql || '      MOV.COD_FILIAL, ';
            v_sql := v_sql || '      MOV.DATA, ';
            v_sql := v_sql || '      MOV.MOVTO_E_S, ';
            v_sql := v_sql || '      MOV.COD_ITEM, ';
            v_sql := v_sql || '      MOV.CFOP, ';
            v_sql := v_sql || '      MOV.CFOP_FORN, ';
            v_sql := v_sql || '      PS.ICMSTAX_BRL_PCT, ';
            v_sql := v_sql || '      PS.ICMSTAX_BRL_BSS,  ';
            v_sql := v_sql || '      PS.ICMSTAX_BRL_BSE, ';
            v_sql := v_sql || '      PS.DSP_ICMS_BSS_ST, ';
            v_sql := v_sql || '      PS.DSP_ICMS_AMT_ST, ';
            v_sql := v_sql || '      MOV.VLR_BASE_ST_RET, ';
            v_sql := v_sql || '      MOV.VLR_ST_RET, ';
            v_sql := v_sql || '      MOV.CHV_DOC ';
            v_sql := v_sql || 'FROM TAB_MOV MOV, ';
            v_sql := v_sql || '    ( ';
            v_sql := v_sql || '        SELECT  PS.BUSINESS_UNIT, PS.NF_BRL_ID, PS.NF_BRL_LINE_NUM, ';
            v_sql := v_sql || '                          PS.ICMSTAX_BRL_BSE, PS.ICMSTAX_BRL_BSS, ';
            v_sql :=
                   v_sql
                || '                          PS.ICMSTAX_BRL_PCT, DECODE(PS.DSP_ICMS_AMT_ST, 0, PS.ICMSSUB_BRL_AMT, PS.DSP_ICMS_AMT_ST) AS DSP_ICMS_AMT_ST, ';
            v_sql :=
                   v_sql
                || '                          DECODE(PS.DSP_ICMS_BSS_ST, 0, PS.ICMSSUB_BRL_BSS, PS.DSP_ICMS_BSS_ST) AS DSP_ICMS_BSS_ST ';
            v_sql := v_sql || '                  FROM MSAFI.PS_NF_LN_BBL_FS PS ';
            v_sql := v_sql || '    ) PS ';
            v_sql := v_sql || 'WHERE MOV.BUSINESS_UNIT = PS.BUSINESS_UNIT ';
            v_sql := v_sql || '  AND MOV.NF_BRL_ID     = PS.NF_BRL_ID ';
            v_sql := v_sql || '  AND MOV.NUM_ITEM      = PS.NF_BRL_LINE_NUM ';

            OPEN c_saida_cd FOR v_sql;

            LOOP
                FETCH c_saida_cd
                    BULK COLLECT INTO tab_nf
                    LIMIT 1000;

                IF tab_nf.COUNT > 0 THEN
                    FORALL i IN tab_nf.FIRST .. tab_nf.LAST
                        INSERT INTO msafi.dpsp_msaf_ps_nf
                        VALUES tab_nf ( i );

                    v_qtd := v_qtd + SQL%ROWCOUNT;
                    COMMIT;
                END IF;

                dbms_application_info.set_module ( vg_module
                                                 , 'F4 CD -> LOJA [' || v_qtd || ']' );

                EXIT WHEN tab_nf.COUNT = 0;
                tab_nf.delete;
            END LOOP;

            COMMIT;

            CLOSE c_saida_cd;

            --DBMS_STATS.GATHER_TABLE_STATS('MSAFI', 'DPSP_MSAF_PS_NF');

            dbms_application_info.set_module ( vg_module
                                             , 'F4 CD -> LOJA MERGE' );
            dbms_output.put_line ( 'F4 CD -> LOJA MERGE' );
            v_sql := 'MERGE INTO MSAFI.' || p_tab_mov || ' MOV ';
            v_sql := v_sql || 'USING ( ';
            v_sql := v_sql || 'SELECT  BUSINESS_UNIT, ';
            v_sql := v_sql || '        NF_BRL_ID, ';
            v_sql := v_sql || '        NF_BRL_LINE_NUM, ';
            v_sql := v_sql || '        COD_ESTAB, ';
            v_sql := v_sql || '        DATA_FISCAL, ';
            v_sql := v_sql || '        MOVTO_E_S, ';
            v_sql := v_sql || '        NUM_AUTENTIC_NFE, ';
            v_sql := v_sql || '        VLR_BASE_ICMS_ST, ';
            v_sql := v_sql || '        VLR_ICMS_ST ';
            v_sql := v_sql || 'FROM MSAFI.DPSP_MSAF_PS_NF ' || v_partition_ps_nf || ' ';
            v_sql := v_sql || 'WHERE COD_ESTAB = ''' || pcod_estab || ''' ';
            v_sql :=
                   v_sql
                || '  AND DATA_FISCAL BETWEEN TO_DATE('''
                || TO_CHAR ( v_data_ini
                           , 'DDMMYYYY' )
                || ''',''DDMMYYYY'') AND TO_DATE('''
                || TO_CHAR ( v_data_fim
                           , 'DDMMYYYY' )
                || ''',''DDMMYYYY'') ';
            v_sql := v_sql || '  AND MOVTO_E_S = ''9'' ';
            v_sql := v_sql || ') PS ';
            v_sql := v_sql || 'ON ( ';
            v_sql := v_sql || '          PS.BUSINESS_UNIT    = MOV.BUSINESS_UNIT  ';
            v_sql := v_sql || '      AND PS.NF_BRL_ID        = MOV.NF_BRL_ID ';
            v_sql := v_sql || '      AND PS.NF_BRL_LINE_NUM  = MOV.NUM_ITEM  ';
            v_sql := v_sql || '      AND PS.COD_ESTAB        = MOV.COD_FILIAL  ';
            v_sql := v_sql || '      AND PS.DATA_FISCAL      = MOV.DATA  ';
            v_sql := v_sql || '      AND PS.MOVTO_E_S        = MOV.MOVTO_E_S ';
            v_sql := v_sql || '      AND PS.NUM_AUTENTIC_NFE = MOV.CHV_DOC ';
            v_sql := v_sql || '      AND MOV.COD_FILIAL      = ''' || pcod_estab || ''' ';
            v_sql := v_sql || '      AND MOV.PERIODO         = ' || pdt_periodo || ' ';
            v_sql := v_sql || '      AND MOV.MOVTO_E_S       = ''9'' ';
            v_sql := v_sql || '      AND MOV.CFOP            = ''5409'' ';
            v_sql :=
                   v_sql
                || '      AND MOV.COD_PART IN (SELECT COD_ESTAB FROM MSAFI.DSP_ESTABELECIMENTO WHERE COD_EMPRESA = MSAFI.DPSP.EMPRESA AND TIPO = ''L'')  ';
            v_sql := v_sql || '    ) ';
            v_sql := v_sql || 'WHEN MATCHED THEN ';
            v_sql := v_sql || '    UPDATE SET MOV.VLR_BASE_ICMS_ST = 0, '; --PS.VLR_BASE_ICMS_ST, ';
            v_sql := v_sql || '               MOV.VLR_ICMS_ST      = 0, '; --PS.VLR_ICMS_ST, ';
            v_sql := v_sql || '               MOV.ORIGEM_ICMS      = ''L'', ';
            v_sql := v_sql || '               MOV.TAX_CONTROLE     = ''J'' ';

            BEGIN
                EXECUTE IMMEDIATE v_sql;

                COMMIT;
            EXCEPTION
                WHEN OTHERS THEN
                    dbms_output.put_line ( SQLERRM );
                    raise_application_error ( -20001
                                            , '!ERRO ULT_ENTRADA_PEOPLE 4!' );
            END;

            ---------------------------------------------------------------------------------

            dbms_application_info.set_module ( vg_module
                                             , 'F4 LOJA -> CD DEV' );
            dbms_output.put_line ( 'F4 LOJA -> CD DEV' );
            --CDs - ENTRADA NOS CDs ORIGEM LOJA - DEVOLUCAO - BUSCAR IMPOSTOS NA SAIDA DA LOJA
            v_sql := 'WITH TAB_MOV AS ';
            v_sql := v_sql || '( ';
            v_sql := v_sql || 'SELECT /*+MATERIALIZE*/ HDR.BUSINESS_UNIT,  ';
            v_sql := v_sql || '        HDR.NF_BRL_ID,  ';
            v_sql := v_sql || '        MOV.NUM_ITEM, ';
            v_sql := v_sql || '        MOV.COD_FILIAL, ';
            v_sql := v_sql || '        MOV.DATA,  ';
            v_sql := v_sql || '        MOV.MOVTO_E_S,  ';
            v_sql := v_sql || '        MOV.COD_ITEM, ';
            v_sql := v_sql || '        MOV.CFOP,  ';
            v_sql := v_sql || '        MSAFI.DPSP.EMPRESA AS COD_EMPRESA, ';
            v_sql := v_sql || '        '''' AS CFOP_FORN, ';
            v_sql := v_sql || '        0 AS VLR_BASE_ST_RET,  ';
            v_sql := v_sql || '        0 AS VLR_ST_RET,  ';
            v_sql := v_sql || '        MOV.CHV_DOC  ';
            v_sql := v_sql || 'FROM MSAFI.' || p_tab_mov || ' MOV, ';
            v_sql := v_sql || '    (SELECT HDR.BUSINESS_UNIT, HDR.NF_BRL_ID, HDR.NFEE_KEY_BBL ';
            v_sql := v_sql || '      FROM MSAFI.PS_AR_NFRET_BBL HDR ) HDR ';
            v_sql := v_sql || 'WHERE MOV.COD_FILIAL = ''' || pcod_estab || ''' ';
            v_sql := v_sql || 'AND MOV.PERIODO      = ' || pdt_periodo || ' ';
            v_sql := v_sql || 'AND MOV.MOVTO_E_S   <> ''9'' ';
            v_sql :=
                   v_sql
                || 'AND MOV.COD_PART IN (SELECT COD_ESTAB FROM MSAFI.DSP_ESTABELECIMENTO WHERE COD_EMPRESA = MSAFI.DPSP.EMPRESA AND TIPO = ''L'')  ';
            v_sql := v_sql || 'AND MOV.CFOP     IN (''1209'',''2209'') ';
            v_sql := v_sql || 'AND HDR.NFEE_KEY_BBL = MOV.CHV_DOC  ';
            v_sql := v_sql || 'AND NOT EXISTS (SELECT ''Y'' ';
            v_sql := v_sql || '                FROM MSAFI.DPSP_MSAF_PS_NF ' || v_partition_ps_nf || ' LOC ';
            v_sql := v_sql || '                WHERE LOC.BUSINESS_UNIT    = HDR.BUSINESS_UNIT ';
            v_sql := v_sql || '                  AND LOC.NF_BRL_ID        = HDR.NF_BRL_ID  ';
            v_sql := v_sql || '                  AND LOC.NF_BRL_LINE_NUM  = MOV.NUM_ITEM)  ';
            v_sql := v_sql || ') ';
            v_sql := v_sql || 'SELECT /*+DRIVING_SITE(PS)*/ MOV.BUSINESS_UNIT,  ';
            v_sql := v_sql || '      MOV.NF_BRL_ID,  ';
            v_sql := v_sql || '      MOV.NUM_ITEM, ';
            v_sql := v_sql || '      MOV.COD_EMPRESA, ';
            v_sql := v_sql || '      MOV.COD_FILIAL, ';
            v_sql := v_sql || '      MOV.DATA,   ';
            v_sql := v_sql || '      MOV.MOVTO_E_S, ';
            v_sql := v_sql || '      MOV.COD_ITEM,  ';
            v_sql := v_sql || '      MOV.CFOP,   ';
            v_sql := v_sql || '      MOV.CFOP_FORN,  ';
            v_sql := v_sql || '      PS.ICMSTAX_BRL_PCT,  ';
            v_sql := v_sql || '      PS.ICMSTAX_BRL_BSS, ';
            v_sql := v_sql || '      PS.ICMSTAX_BRL_BSE, ';
            v_sql := v_sql || '      PS.DSP_ICMS_BSS_ST, ';
            v_sql := v_sql || '      PS.DSP_ICMS_AMT_ST, ';
            v_sql := v_sql || '      MOV.VLR_BASE_ST_RET, ';
            v_sql := v_sql || '      MOV.VLR_ST_RET,  ';
            v_sql := v_sql || '      MOV.CHV_DOC  ';
            v_sql := v_sql || 'FROM TAB_MOV MOV,  ';
            v_sql := v_sql || '    (   ';
            v_sql := v_sql || '        SELECT  LN.BUSINESS_UNIT, LN.NF_BRL_ID, LN.NF_BRL_LINE_NUM, ';
            v_sql := v_sql || '                          LN.ICMSTAX_BRL_BSE, LN.ICMSTAX_BRL_BSS,   ';
            v_sql := v_sql || '                          LN.ICMSTAX_BRL_PCT, LN.DSP_ICMS_AMT_ST,  ';
            v_sql := v_sql || '                          LN.DSP_ICMS_BSS_ST,  ';
            v_sql := v_sql || '                          LN.INV_ITEM_ID ';
            v_sql := v_sql || '                  FROM MSAFI.PS_NF_LN_BBL_FS LN ';
            v_sql := v_sql || '    ) PS   ';
            v_sql := v_sql || 'WHERE MOV.BUSINESS_UNIT = PS.BUSINESS_UNIT  ';
            v_sql := v_sql || '  AND MOV.NF_BRL_ID     = PS.NF_BRL_ID  ';
            v_sql := v_sql || '  AND MOV.COD_ITEM      = PS.INV_ITEM_ID ';
            v_sql := v_sql || '  AND MOV.NUM_ITEM      = PS.NF_BRL_LINE_NUM ';
            tab_nf.delete;
            v_qtd := 0;

            OPEN c_entrada_cd FOR v_sql;

            LOOP
                FETCH c_entrada_cd
                    BULK COLLECT INTO tab_nf
                    LIMIT 1000;

                IF tab_nf.COUNT > 0 THEN
                    FORALL i IN tab_nf.FIRST .. tab_nf.LAST
                        INSERT INTO msafi.dpsp_msaf_ps_nf
                        VALUES tab_nf ( i );

                    v_qtd := v_qtd + SQL%ROWCOUNT;
                    COMMIT;
                END IF;

                dbms_application_info.set_module ( vg_module
                                                 , 'F4 LOJA -> CD DEV [' || v_qtd || ']' );

                EXIT WHEN tab_nf.COUNT = 0;
                tab_nf.delete;
            END LOOP;

            COMMIT;

            CLOSE c_entrada_cd;

            --DBMS_STATS.GATHER_TABLE_STATS('MSAFI', 'DPSP_MSAF_PS_NF');

            dbms_application_info.set_module ( vg_module
                                             , 'F4 LOJA -> CD DEV MERGE' );
            dbms_output.put_line ( 'F4 LOJA -> CD DEV MERGE' );
            v_sql := 'MERGE INTO MSAFI.' || p_tab_mov || ' MOV ';
            v_sql := v_sql || 'USING ( ';
            v_sql := v_sql || 'SELECT  BUSINESS_UNIT, ';
            v_sql := v_sql || '        NF_BRL_ID, ';
            v_sql := v_sql || '        NF_BRL_LINE_NUM, ';
            v_sql := v_sql || '        COD_ESTAB, ';
            v_sql := v_sql || '        DATA_FISCAL, ';
            v_sql := v_sql || '        MOVTO_E_S, ';
            v_sql := v_sql || '        NUM_AUTENTIC_NFE, ';
            v_sql := v_sql || '        VLR_BASE_ICMS_ST, ';
            v_sql := v_sql || '        VLR_ICMS_ST, ';
            v_sql := v_sql || '        COD_CFOP, ';
            v_sql := v_sql || '        COD_PRODUTO ';
            v_sql := v_sql || 'FROM MSAFI.DPSP_MSAF_PS_NF ' || v_partition_ps_nf || ' ';
            v_sql := v_sql || 'WHERE COD_ESTAB = ''' || pcod_estab || ''' ';
            v_sql :=
                   v_sql
                || '  AND DATA_FISCAL BETWEEN TO_DATE('''
                || TO_CHAR ( v_data_ini
                           , 'DDMMYYYY' )
                || ''',''DDMMYYYY'') AND TO_DATE('''
                || TO_CHAR ( v_data_fim
                           , 'DDMMYYYY' )
                || ''',''DDMMYYYY'') ';
            v_sql := v_sql || '  AND MOVTO_E_S <> ''9'' ';
            v_sql := v_sql || ') PS ';
            v_sql := v_sql || 'ON ( ';
            v_sql := v_sql || '          PS.NF_BRL_LINE_NUM  = MOV.NUM_ITEM  ';
            v_sql := v_sql || '      AND PS.COD_ESTAB        = MOV.COD_FILIAL  ';
            v_sql := v_sql || '      AND PS.DATA_FISCAL      = MOV.DATA  ';
            v_sql := v_sql || '      AND PS.MOVTO_E_S        = MOV.MOVTO_E_S ';
            v_sql := v_sql || '      AND PS.NUM_AUTENTIC_NFE = MOV.CHV_DOC ';
            v_sql := v_sql || '      AND PS.COD_PRODUTO      = MOV.COD_ITEM ';
            v_sql := v_sql || '      AND MOV.COD_FILIAL      = ''' || pcod_estab || ''' ';
            v_sql := v_sql || '      AND MOV.PERIODO         = ' || pdt_periodo || ' ';
            v_sql := v_sql || '      AND MOV.MOVTO_E_S      <> ''9'' ';
            v_sql :=
                   v_sql
                || '      AND MOV.COD_PART IN (SELECT COD_ESTAB FROM MSAFI.DSP_ESTABELECIMENTO WHERE COD_EMPRESA = MSAFI.DPSP.EMPRESA AND TIPO = ''L'')  ';
            v_sql := v_sql || '      AND MOV.CFOP           IN (''1209'',''2209'') ';
            v_sql := v_sql || '    ) ';
            v_sql := v_sql || 'WHEN MATCHED THEN ';
            v_sql := v_sql || '    UPDATE SET MOV.VLR_BASE_ICMS_ST = PS.VLR_BASE_ICMS_ST, ';
            v_sql := v_sql || '               MOV.VLR_ICMS_ST      = PS.VLR_ICMS_ST, ';
            v_sql := v_sql || '               MOV.ORIGEM_ICMS      = ''L'', ';
            v_sql := v_sql || '               MOV.TAX_CONTROLE     = ''K'' ';

            BEGIN
                EXECUTE IMMEDIATE v_sql;

                COMMIT;
            EXCEPTION
                WHEN OTHERS THEN
                    dbms_output.put_line ( SQLERRM );
                    raise_application_error ( -20001
                                            , '!ERRO ULT_ENTRADA_PEOPLE 5!' );
            END;

            ---------------------------------------------------------------------------------

            dbms_application_info.set_module ( vg_module
                                             , 'F4 CD -> FORN DEV' );
            dbms_output.put_line ( 'F4 CD -> FORN DEV' );
            --CDs - SAIDA DE CD PARA FORNECEDOR / DEVOLUCAO
            v_sql := 'BEGIN FOR C IN (SELECT ';
            v_sql :=
                   v_sql
                || '                  C.ROWID, C.COD_PART, A.NF_BRL_ID, B.NF_BRL_LINE_NUM, B.INV_ITEM_ID, B.BUSINESS_UNIT, B.CFO_BRL_CD ';
            v_sql := v_sql || '                FROM ' || v_tab_nfret || '       A, ';
            v_sql := v_sql || '                   MSAFI.PS_AR_ITENS_NF_BBL    B, ';
            v_sql := v_sql || '                   MSAFI.' || p_tab_mov || ' C ';
            v_sql := v_sql || '                WHERE A.BUSINESS_UNIT = B.BUSINESS_UNIT ';
            v_sql := v_sql || '                  AND A.NF_BRL_ID = B.NF_BRL_ID ';
            v_sql := v_sql || '                  AND A.MOVTO_E_S = C.MOVTO_E_S ';
            v_sql := v_sql || '                  AND C.CHV_DOC   = A.NFEE_KEY_BBL ';
            v_sql := v_sql || '                  AND C.COD_ITEM  = B.INV_ITEM_ID ';
            v_sql := v_sql || '                  AND C.NUM_ITEM  = B.NF_BRL_LINE_NUM ';
            v_sql := v_sql || '                  AND C.COD_PART LIKE ''F%'' ';
            v_sql := v_sql || '                  AND C.CFOP IN (''6411'',''5411'') ';
            v_sql := v_sql || '                  AND C.MOVTO_E_S  = ''9'' ';
            v_sql := v_sql || '                  AND C.COD_FILIAL = ''' || pcod_estab || ''' ';
            v_sql := v_sql || '                  AND C.PERIODO    = ' || pdt_periodo || ' ';
            ---
            v_sql := v_sql || '               ) LOOP ';
            ---
            v_sql := v_sql || '    UPDATE MSAFI.' || p_tab_mov || ' D ';
            v_sql := v_sql || '       SET D.ORIGEM_ICMS = ''F'' ';
            v_sql := v_sql || '     WHERE ROWID        = C.ROWID ';
            v_sql := v_sql || '       AND D.PERIODO    = ' || pdt_periodo || ' ';
            v_sql := v_sql || '       AND D.COD_FILIAL = ''' || pcod_estab || ''' ';
            v_sql := v_sql || '       AND D.MOVTO_E_S  = ''9''; ';
            ---
            v_sql := v_sql || '  COMMIT; ';
            v_sql := v_sql || '  END LOOP; END; ';

            BEGIN
                EXECUTE IMMEDIATE v_sql;
            EXCEPTION
                WHEN OTHERS THEN
                    dbms_output.put_line ( SQLERRM );
                    raise_application_error ( -20001
                                            , '!ERRO ULT_ENTRADA_PEOPLE 6!' );
            END;
        END IF;
    END;

    /***************************************************************Fim/correção - Guilherme Silva**********************************************************/


    PROCEDURE ficha1_verificar ( pcod_estab VARCHAR2
                               , pdt_ini DATE
                               , pdt_fim DATE
                               , pdt_periodo INTEGER
                               , v_data_hora_ini VARCHAR2 )
    IS
    BEGIN
        FOR c IN ( SELECT   x07.cod_estab
                          , COUNT ( 1 )
                       FROM x07_docto_fiscal x07
                      WHERE 1 = 1
                        AND x07.cod_empresa = mcod_empresa
                        AND x07.cod_estab = pcod_estab
                        AND x07.data_fiscal BETWEEN pdt_ini AND pdt_fim
                   GROUP BY x07.cod_estab
                     HAVING COUNT ( 1 ) > 0 ) LOOP
            INSERT INTO msafi.dpsp_fin151_cat42_ide ( cod_filial
                                                    , periodo
                                                    , linha_auxiliar
                                                    , proc_id
                                                    , nm_usuario
                                                    , dt_carga )
                 VALUES ( c.cod_estab
                        , pdt_periodo
                        , 'S'
                        , -- INFORMAR COMO 'S' POIS É UM REGISTRS AULIXIAR PARA VERIFICAR SE OCORREU MOVIMENTO, NÃO SENDO EXTRAIDO NO ARQUIVO
                         mproc_id
                        , mnm_usuario
                        , v_data_hora_ini );
        END LOOP;

        COMMIT;
    END; -- FICHA1_VERIFICAR

    PROCEDURE ficha1_gerar ( pdt_ini DATE
                           , pdt_fim DATE
                           , pdt_periodo INTEGER
                           , v_data_hora_ini VARCHAR2 )
    IS
    BEGIN
        FOR c
            IN ( SELECT cod_filial
                      , periodo
                      , SUBSTR ( nome
                               , 1
                               , 100 )
                            AS nome
                      , TO_NUMBER ( cnpj_matriz ) AS cnpj_matriz
                      , TO_NUMBER ( cnpj_filial ) AS cnpj_filial
                      , TO_NUMBER ( ie_filial ) AS ie_filial
                      , TO_NUMBER ( cod_mun ) AS cod_mun
                      , TO_NUMBER ( cod_fin ) AS cod_fin
                      , cnae
                      , SUBSTR ( municipio
                               , 1
                               , 30 )
                            AS municipio
                      , uf
                      , SUBSTR ( logradouro
                               , 1
                               , 34 )
                            AS logradouro
                      , numero
                      , SUBSTR ( complemento
                               , 1
                               , 22 )
                            AS complemento
                      , SUBSTR ( bairro
                               , 1
                               , 15 )
                            AS bairro
                      , TO_NUMBER ( cep ) AS cep
                      , SUBSTR ( nome_contato
                               , 1
                               , 28 )
                            AS nome_contato
                      , TO_NUMBER ( fax ) AS fax
                      , TO_NUMBER ( telefone ) AS telefone
                      , SUBSTR ( email
                               , 1
                               , 50 )
                            AS email
                      , site
                      , dt_ini
                      , dt_fim
                   FROM ( SELECT est.cod_estab AS cod_filial
                               , pdt_periodo AS periodo
                               , est.razao_social AS nome
                               , ( SELECT mat.cgc
                                     FROM msaf.estabelecimento mat
                                    WHERE mat.cod_empresa = mcod_empresa
                                      AND mat.ind_matriz_filial = 'M' )
                                     AS cnpj_matriz
                               , est.cgc AS cnpj_filial
                               , ie.inscricao_estadual AS ie_filial
                               ,    mu.cod_uf
                                 || LPAD ( est.cod_municipio
                                         , 5
                                         , 0 )
                                     AS cod_mun
                               , '00' AS cod_fin
                               , est.cod_atividade AS cnae
                               , est.cidade AS municipio
                               , uf.cod_estado AS uf
                               , est.endereco AS logradouro
                               , est.num_endereco AS numero
                               , est.compl_endereco AS complemento
                               , est.bairro AS bairro
                               , est.cep
                               , 'MIRIAM SERRA' AS nome_contato
                               , est.fax
                               , est.telefone
                               , est.email
                               , 'HTTPS://WWW.GRUPODPSP.COM.BR/' AS site
                               , est.dat_ini_atividade AS dt_ini
                               , est.dt_encerramento AS dt_fim
                            FROM msaf.estabelecimento est
                               , msaf.registro_estadual ie
                               , msaf.estado uf
                               , msaf.municipio mu
                               , msafi.dpsp_fin151_cat42_ide aux
                           WHERE 1 = 1
                             AND est.cod_empresa = mcod_empresa
                             --AND EST.COD_ESTAB = PCOD_ESTAB
                             AND est.cod_empresa = ie.cod_empresa
                             AND est.cod_estab = ie.cod_estab
                             AND est.ident_estado = ie.ident_estado
                             AND uf.ident_estado = est.ident_estado
                             AND est.ident_estado = mu.ident_estado
                             AND est.cod_municipio = mu.cod_municipio
                             --======================
                             -- A TABELA DA FICHA1 APRESENTA A LINHA_AUXILIAR PARA INFORMAR SE
                             -- O ESTABELECIMENTO APRESENTOU MOVIMENTO POIS O CAMPO DT_ENCERRAMENTO
                             -- NÃO ESTÁ SENDO POPULADO PARA TODOS OS ESTABELECIMENTOS ENCERRADOS
                             --======================

                             AND aux.cod_filial = est.cod_estab
                             AND aux.linha_auxiliar = 'S'
                             AND aux.periodo = pdt_periodo
                             AND aux.proc_id = mproc_id
                             -- VERIFICAR DATA DE ENCERRAMENTO DO ESTABELECIMENTO
                             AND pdt_periodo BETWEEN TO_NUMBER (
                                                                 TO_CHAR (
                                                                           TO_DATE (
                                                                                     NVL ( est.dat_ini_atividade
                                                                                         , '01/01/1900' )
                                                                                   , 'DD/MM/YYYY'
                                                                           )
                                                                         , 'YYYYMM'
                                                                 )
                                                     )
                                                 AND TO_NUMBER (
                                                                 TO_CHAR (
                                                                           TO_DATE (
                                                                                     NVL ( est.dt_encerramento
                                                                                         , '31/12/9999' )
                                                                                   , 'DD/MM/YYYY'
                                                                           )
                                                                         , 'YYYYMM'
                                                                 )
                                                     ) ) ) LOOP
            INSERT INTO msafi.dpsp_fin151_cat42_ide
                 VALUES ( c.cod_filial
                        , c.periodo
                        , c.nome
                        , c.cnpj_matriz
                        , c.cnpj_filial
                        , c.ie_filial
                        , c.cod_mun
                        , c.cod_fin
                        , c.cnae
                        , c.municipio
                        , c.uf
                        , c.logradouro
                        , c.numero
                        , c.complemento
                        , c.bairro
                        , c.cep
                        , c.nome_contato
                        , c.fax
                        , c.telefone
                        , c.email
                        , c.site
                        , c.dt_ini
                        , c.dt_fim
                        , 'N'
                        , -- INFORMAR COMO 'N' POIS 'S' É SOMENTE PARA OS REGISTROS AUXILIARES
                         mproc_id
                        , mnm_usuario
                        , v_data_hora_ini );
        END LOOP;

        COMMIT;
    END;

    PROCEDURE ficha1_extrair ( flg_dw CHAR
                             , flg_utl CHAR
                             , pdiretorio VARCHAR2
                             , parquivo VARCHAR2
                             , pdt_periodo INTEGER )
    IS
        l_vdir VARCHAR2 ( 10000 );
        l_farquivo_w utl_file.file_type;
        l_vline VARCHAR2 ( 32767 );
        v_existe INTEGER;
    BEGIN
        IF flg_utl = 'S' THEN
            l_vdir := pdiretorio;
            l_vline := '';
            l_farquivo_w :=
                utl_file.fopen ( l_vdir
                               , parquivo
                               , 'W' );
        END IF;

        IF flg_dw = 'S' THEN
            lib_proc.add_tipo ( mproc_id
                              , 2
                              , parquivo
                              , 2 );
        END IF;

        FOR i IN ( SELECT cod_filial
                        , periodo
                        , nome
                        , cnpj_matriz
                        , cnpj_filial
                        , ie_filial
                        , cod_mun
                        , cod_fin
                        , cnae
                        , municipio
                        , uf
                        , logradouro
                        , numero
                        , complemento
                        , bairro
                        , cep
                        , nome_contato
                        , fax
                        , telefone
                        , email
                        , site
                        , dt_ini
                        , dt_fim
                     FROM msafi.dpsp_fin151_cat42_ide
                    WHERE 1 = 1
                      AND linha_auxiliar = 'N'
                      AND periodo = pdt_periodo
                      AND proc_id = mproc_id ) LOOP
            l_vline :=
                   i.cod_filial
                || '|'
                || i.periodo
                || '|'
                || i.nome
                || '|'
                || i.cnpj_matriz
                || '|'
                || i.cnpj_filial
                || '|'
                || i.ie_filial
                || '|'
                || i.cod_mun
                || '|'
                || i.cod_fin
                || '|'
                || i.cnae
                || '|'
                || i.municipio
                || '|'
                || i.uf
                || '|'
                || i.logradouro
                || '|'
                || i.numero
                || '|'
                || i.complemento
                || '|'
                || i.bairro
                || '|'
                || i.cep
                || '|'
                || i.nome_contato
                || '|'
                || i.fax
                || '|'
                || i.telefone
                || '|'
                || i.email
                || '|'
                || i.site
                || '|'
                || i.dt_ini
                || '|'
                || i.dt_fim;

            IF flg_utl = 'S' THEN
                utl_file.put_line ( l_farquivo_w
                                  , l_vline );
            END IF;

            IF flg_dw = 'S' THEN
                lib_proc.add ( l_vline
                             , NULL
                             , NULL
                             , 2 );
            END IF;
        END LOOP;

        IF flg_utl = 'S' THEN
            utl_file.fclose ( l_farquivo_w );
        END IF;
    END;

    PROCEDURE ficha2_gerar ( p_proc_instance VARCHAR2
                           , pcod_estab lib_proc.vartab
                           , ptipo CHAR
                           , pdt_ini DATE
                           , pdt_fim DATE
                           , pdt_periodo INTEGER
                           , v_data_hora_ini VARCHAR2 )
    IS
        vp_tab_estabs VARCHAR2 ( 50 );
        vp_tab_entrada_ini VARCHAR2 ( 50 );
        vp_tab_produtos VARCHAR2 ( 50 );
        vp_tab_ficha2 VARCHAR2 ( 50 );
        v_sql VARCHAR2 ( 4000 );

        v_qtde_xml INTEGER;
    BEGIN
        --TABELA INICIAL DE ENTRADAS CARREGADA NO PROCESSO LOAD ENTRADAS
        vp_tab_estabs := 'DPSP_F2EST_' || p_proc_instance;
        vp_tab_entrada_ini := 'DPSP_F2ENT_' || p_proc_instance;
        vp_tab_produtos := 'DPSP_F2PRD_' || p_proc_instance;

        loga ( '-------------------------'
             , FALSE );
        loga ( 'FICHA 2'
             , FALSE );
        loga ( 'PERIODO: ' || pdt_periodo
             , FALSE );
        loga ( pdt_ini
             , FALSE );
        loga ( pdt_fim
             , FALSE );
        loga ( '-------------------------'
             , FALSE );

        --===================================================================
        -- STEP 1
        --===================================================================
        loga ( 'FICHA2_CARREGAR-INI '
             , FALSE );
        ficha2_carregar ( pdt_ini
                        , pdt_fim
                        , pdt_periodo
                        , v_data_hora_ini
                        , ptipo
                        , pcod_estab );
        loga ( 'FICHA2_CARREGAR-FIM'
             , FALSE );

        --===================================================================
        -- STEP 2
        --===================================================================
        loga ( 'FICHA2_CREATE_TABLES-INI '
             , FALSE );
        ficha2_create_tables ( p_proc_instance
                             , vp_tab_estabs
                             , vp_tab_entrada_ini
                             , vp_tab_produtos );
        loga ( 'FICHA2_CREATE_TABLES-FIM '
             , FALSE );
        --===================================================================
        -- STEP 3
        --===================================================================
        loga ( 'INSERT_TEMP_PROD-INI '
             , FALSE );
        --FOR V_COD_ESTAB IN PCOD_ESTAB.FIRST .. PCOD_ESTAB.LAST LOOP

        v_sql := ' INSERT INTO ' || vp_tab_estabs;
        v_sql := v_sql || ' SELECT COD_ESTAB, ';
        v_sql := v_sql || ' MOD(DENSE_RANK()  ';
        v_sql := v_sql || ' OVER(ORDER BY COD_EMPRESA, COD_ESTAB), 100) + 1  ';
        v_sql := v_sql || ' AS NR_PARTICAO, ';
        v_sql := v_sql || ' ' || mproc_id || ' AS PROC_ID ';

        v_sql := v_sql || ' FROM MSAFI.DSP_ESTABELECIMENTO ';
        v_sql := v_sql || ' WHERE TIPO LIKE ''' || ptipo || ''' ';

        EXECUTE IMMEDIATE v_sql;

        --END LOOP;

        COMMIT;

        loga ( 'INSERT_TEMP_PROD-FIM '
             , FALSE );
        --===================================================================
        -- STEP 4
        --===================================================================

        dbms_application_info.set_module ( $$plsql_unit
                                         , 'F2 LOAD ENT' );

        loga ( 'LOAD_ENTRADAS-INI '
             , FALSE );

        loga ( '-------------------------'
             , FALSE );
        loga ( 'PARAMETROS LOAD_ENTRADAS:'
             , FALSE );
        loga ( vp_tab_entrada_ini
             , FALSE );
        loga ( vp_tab_estabs
             , FALSE );
        loga ( pdt_ini
             , FALSE );
        loga ( pdt_fim
             , FALSE );
        loga ( v_data_hora_ini
             , FALSE );
        loga ( 'PROC_ID: ' || mproc_id
             , FALSE );
        loga ( '-------------------------'
             , FALSE );

        FOR v_cod_estab IN pcod_estab.FIRST .. pcod_estab.LAST LOOP
            loga ( 'ESTAB: ' || pcod_estab ( v_cod_estab )
                 , FALSE );

            ficha2_load_entradas ( pcod_estab ( v_cod_estab )
                                 , vp_tab_entrada_ini
                                 , vp_tab_estabs
                                 , pdt_fim
                                 , pdt_ini
                                 , v_data_hora_ini
                                 , mproc_id );
        END LOOP;

        v_sql := 'SELECT COUNT(1) QTD FROM ' || vp_tab_entrada_ini;

        EXECUTE IMMEDIATE v_sql            INTO v_qtde_xml;

        COMMIT;

        loga ( 'LOAD_ENTRADAS-FIM QTD ' || v_qtde_xml || ' LINHAS'
             , FALSE );

        --===================================================================
        -- STEP 5
        --===================================================================

        dbms_application_info.set_module ( $$plsql_unit
                                         , 'F2 LOAD PRD' );

        ficha2_load_produtos ( p_proc_instance
                             , vp_tab_produtos
                             , vp_tab_entrada_ini
                             , pdt_ini
                             , pdt_fim
                             , v_data_hora_ini );

        COMMIT;

        --===================================================================
        -- STEP 6
        --===================================================================

        loga ( 'ATUALIZAR FICHA2-INI '
             , FALSE );

        v_sql := 'DECLARE ';
        v_sql := v_sql || '  V_COUNT INTEGER := 0; ';
        v_sql := v_sql || 'BEGIN ';
        v_sql := v_sql || 'FOR P IN ( ';
        v_sql := v_sql || '  SELECT CAT42.ROWID AS ROW_ID ';
        v_sql := v_sql || '  FROM ' || vp_tab_produtos || ' PROD, MSAFI.DPSP_FIN151_CAT42_PROD CAT42 ';
        v_sql := v_sql || '  WHERE CAT42.COD_ITEM = PROD.COD_ITEM ';
        v_sql := v_sql || '    AND CAT42.PROC_ID  = PROD.PROC_ID ';
        v_sql := v_sql || '    AND CAT42.PERIODO  = ' || TO_CHAR ( pdt_periodo ) || ' ';
        v_sql := v_sql || '    AND CAT42.IN_MOVIMENTACAO <> ''S'' ';
        v_sql := v_sql || ') LOOP ';
        v_sql := v_sql || '  UPDATE MSAFI.DPSP_FIN151_CAT42_PROD SET IN_MOVIMENTACAO = ''S'' WHERE ROWID = P.ROW_ID; ';
        v_sql := v_sql || '  V_COUNT := V_COUNT + 1; ';
        v_sql := v_sql || '  IF (V_COUNT = 100) THEN ';
        v_sql := v_sql || '    V_COUNT := 0; ';
        v_sql := v_sql || '    COMMIT; ';
        v_sql := v_sql || '  END IF; ';
        v_sql := v_sql || 'END LOOP; ';
        v_sql := v_sql || 'COMMIT; ';
        v_sql := v_sql || 'END; ';

        EXECUTE IMMEDIATE v_sql;

        loga ( 'ATUALIZAR FICHA2-FIM '
             , FALSE );
    END;

    PROCEDURE ficha2_carregar ( pdt_ini DATE
                              , pdt_fim DATE
                              , pdt_periodo INTEGER
                              , v_data_hora_ini VARCHAR2
                              , p_i_tipo VARCHAR2
                              , p_i_cod_estab lib_proc.vartab )
    IS
        cc_limit INTEGER := 10000;
        v_count INTEGER := 0;

        CURSOR c_prod (
            p_i_cod_produto IN VARCHAR2
          , p_i_valid_produto IN DATE
          , p_i_ident_produto IN NUMBER
        )
        IS
            SELECT DISTINCT
                   cod_filial
                 , periodo
                 , cnpj_filial
                 , cnpj_matriz
                 , ie_filial
                 , cod_item
                 , descr_item
                 , aliquota_interna_icms
                 , regime_st_dt_ini
                 , ( CASE WHEN regime_st_dt_fim <> regime_st_dt_ini THEN regime_st_dt_fim - 1 ELSE regime_st_dt_fim END )
                       AS regime_st_dt_fim
                 , unid_inv
                 , aliquota_dt_ini
                 , ( CASE WHEN aliquota_dt_fim <> aliquota_dt_ini THEN aliquota_dt_fim - 1 ELSE aliquota_dt_fim END )
                       AS aliquota_dt_fim
                 , cod_ncm
                 , cod_barras
                 , cest
                 , metodologia_st
                 , ( CASE WHEN NVL ( cod_barras, 0 ) = 0 THEN 'N' ELSE 'S' END ) in_movimentacao
                 , aliq_reducao
              FROM (SELECT '' AS cod_filial
                         , --E.COD_ESTAB AS COD_FILIAL,
                           pdt_periodo AS periodo
                         , --E.CGC AS CNPJ_FILIAL,
                           '' AS cnpj_filial
                         , ( SELECT mat.cgc
                               FROM msaf.estabelecimento mat
                              WHERE mat.cod_empresa = 'DSP'
                                AND mat.ind_matriz_filial = 'M' )
                               AS cnpj_matriz
                         , --IE.INSCRICAO_ESTADUAL AS IE_FILIAL,
                           '' AS ie_filial
                         , p.cod_produto AS cod_item
                         , p.descricao AS descr_item
                         , NVL ( REPLACE ( REPLACE ( REPLACE ( msafi.ps_translate ( 'DSP_ALIQ_ICMS'
                                                                                  , x.aliq_interna_atual )
                                                             , '<ERRO - VLR NAO LOCALIZADO>'
                                                             , '' )
                                                   , '<VLR INVALIDO>'
                                                   , '' )
                                         , '%'
                                         , '' )
                               , 0 )
                               AS aliquota_interna_icms
                         , x.regime_st_dt_ini
                         , x.regime_st_dt_fim
                         , 'UN' AS unid_inv
                         , x.regime_st_dt_ini AS aliquota_dt_ini
                         , x.regime_st_dt_fim AS aliquota_dt_fim
                         , n.cod_nbm AS cod_ncm
                         , NVL ( p.cod_barras, ps_prod.cod_barras ) AS cod_barras
                         , NVL ( p.cod_cest, ps_prod.cest ) AS cest
                         , REPLACE ( REPLACE ( msafi.ps_translate ( 'DSP_TP_CALC_ST'
                                                                  , x.metodologia_st )
                                             , '<ERRO - VLR NAO LOCALIZADO>'
                                             , '' )
                                   , '<VLR INVALIDO>'
                                   , '' )
                               AS metodologia_st
                         , x.aliq_reducao
                      FROM (SELECT /*+DRIVING_SITE(TAB)*/
                                  tab.cod_produto
                                 , tab.data_atual AS regime_st_dt_ini
                                 , LEAD ( tab.data_atual
                                        , 1
                                        , NULL )
                                   OVER ( PARTITION BY tab.cod_produto
                                          ORDER BY tab.data_atual )
                                       AS regime_st_dt_fim
                                 , tab.finalidade_atual
                                 , tab.finalidade_anterior
                                 , tab.aliq_interna_atual
                                 , tab.aliq_interna_anterior
                                 , tab.metodologia_st
                                 , tab.aliq_reducao
                              FROM (SELECT /*+DRIVING_SITE(A)*/
                                          a.inv_item_id AS cod_produto
                                         , a.effdt AS data_atual
                                         , a.purch_prop_brl AS finalidade_atual
                                         , LAG ( a.purch_prop_brl
                                               , 1
                                               , '-' )
                                           OVER ( PARTITION BY a.inv_item_id
                                                  ORDER BY a.effdt )
                                               AS finalidade_anterior
                                         , a.dsp_aliq_icms AS aliq_interna_atual
                                         , LAG ( a.dsp_aliq_icms
                                               , 1
                                               , '-' )
                                           OVER ( PARTITION BY a.inv_item_id
                                                  ORDER BY a.effdt )
                                               AS aliq_interna_anterior
                                         , a.dsp_tp_calc_st AS metodologia_st
                                         , a.dsp_pct_red_icmsst AS aliq_reducao
                                      FROM msafi.ps_dsp_item_ln_mva a
                                     WHERE a.setid = 'GERAL'
                                       AND a.effdt <= pdt_fim
                                       AND a.crit_state_to_pbl = 'SP'
                                       AND a.crit_state_fr_pbl = 'SP'
                                       AND a.inv_item_id = p_i_cod_produto
                                    UNION ALL
                                    SELECT /*+DRIVING_SITE(A)*/
                                          a.inv_item_id AS cod_produto
                                         , a.effdt AS data_atual
                                         , a.purch_prop_brl AS finalidade_atual
                                         , LAG ( a.purch_prop_brl
                                               , 1
                                               , '-' )
                                           OVER ( PARTITION BY a.inv_item_id
                                                  ORDER BY a.effdt )
                                               AS finalidade_anterior
                                         , a.dsp_aliq_icms AS aliq_interna_atual
                                         , LAG ( a.dsp_aliq_icms
                                               , 1
                                               , '-' )
                                           OVER ( PARTITION BY a.inv_item_id
                                                  ORDER BY a.effdt )
                                               AS aliq_interna_anterior
                                         , a.dsp_tp_calc_st AS metodologia_st
                                         , a.dsp_pct_red_icmsst AS aliq_reducao
                                      FROM msafi.ps_dsp_ln_mva_his a --TAB HISTORICA PSFT
                                     WHERE a.setid = 'GERAL'
                                       AND a.effdt <= pdt_fim
                                       AND a.crit_state_to_pbl = 'SP'
                                       AND a.crit_state_fr_pbl = 'SP'
                                       AND a.inv_item_id = p_i_cod_produto) tab
                             WHERE ( tab.finalidade_atual <> tab.finalidade_anterior
                                 OR tab.aliq_interna_atual <> tab.aliq_interna_anterior )) x
                         , --=======================================================
                           --COD BARRAS NO PEOPLE
                           (SELECT a.inv_item_id AS cod_produto
                                 , NVL ( ( SELECT TRIM ( mfg_itm_id )
                                             FROM msafi.ps_dsp_codbar_um
                                            WHERE setid = b.setid
                                              AND inv_item_id = b.inv_item_id
                                              AND unit_of_measure = b.unit_measure_std
                                              AND preferred_mfg = 'Y'
                                              AND ROWNUM = 1 ) --COD BAR PREFERIDO COM A MESMA UNID. MEDIDA
                                       , NVL ( ( SELECT TRIM ( mfg_itm_id )
                                                   FROM msafi.ps_dsp_codbar_um
                                                  WHERE setid = b.setid
                                                    AND inv_item_id = b.inv_item_id
                                                    AND unit_of_measure = b.unit_measure_std
                                                    AND ROWNUM = 1 ) --COD BAR NAO PREFERIDO COM A MESMA UNID. MEDIDA
                                             , NVL ( ( SELECT TRIM ( mfg_itm_id )
                                                         FROM msafi.ps_dsp_codbar_um
                                                        WHERE setid = b.setid
                                                          AND inv_item_id = b.inv_item_id
                                                          AND preferred_mfg = 'Y'
                                                          AND ROWNUM = 1 ) --COD BAR PREFERIDO COM QUALQUER UNID. MEDIDA
                                                   , NVL ( ( SELECT TRIM ( mfg_itm_id )
                                                               FROM msafi.ps_dsp_codbar_um
                                                              WHERE setid = b.setid
                                                                AND inv_item_id = b.inv_item_id
                                                                AND ROWNUM = 1 ) --COD BAR NAO PREFERIDO COM QUALQUER UNID. MEDIDA
                                                         , ( SELECT TRIM ( mfg_itm_id )
                                                               FROM msafi.ps_item_mfg
                                                              WHERE setid = b.setid
                                                                AND inv_item_id = b.inv_item_id
                                                                AND ROWNUM = 1 ) --COD BAR DA OUTRA TABELA UTILIZADA NA VIEW MSAFI.PS_DSP_CODBAR_VW
                                                                                 ) ) ) )
                                       AS cod_barras
                                 , TRIM ( a.dpsp_cod_cest ) AS cest
                                 , b.unit_measure_std AS unid_inv
                              FROM msafi.ps_inv_items a
                                 , msafi.ps_master_item_tbl b
                             WHERE a.setid = b.setid
                               AND b.setid = 'GERAL'
                               AND b.inv_item_id = p_i_cod_produto
                               AND a.inv_item_id = b.inv_item_id
                               AND a.effdt = (SELECT MAX ( aa.effdt )
                                                FROM msafi.ps_inv_items aa
                                               WHERE aa.setid = a.setid
                                                 AND aa.inv_item_id = a.inv_item_id
                                                 AND aa.effdt <= pdt_fim)) ps_prod
                         , --=======================================================
                           msaf.x2013_produto p
                         , msaf.x2043_cod_nbm n
                         , msafi.dpsp_cat42_f2_prod gtt
                     --,MSAF.ESTABELECIMENTO E,
                     --MSAF.REGISTRO_ESTADUAL IE
                     WHERE 1 = 1
                       ---AND X.FINALIDADE_ATUAL = 'IST'
                       AND p.cod_produto = x.cod_produto(+)
                       AND p.cod_produto = gtt.cod_produto
                       AND p.cod_produto = p_i_cod_produto
                       AND p.valid_produto = p_i_valid_produto
                       AND p.ident_produto = p_i_ident_produto
                       AND p.ident_nbm = n.ident_nbm(+)
                       AND gtt.cod_produto = ps_prod.cod_produto(+)
                       AND gtt.unid_inv = ps_prod.unid_inv(+));

        --AND PDT_PERIODO BETWEEN
        --    TO_NUMBER(TO_CHAR(TO_DATE(NVL(X.REGIME_ST_DT_INI,
        --                                  '01/01/1900'),
        --                              'DD/MM/YYYY'),
        --                      'YYYYMM')) AND
        --    TO_NUMBER(TO_CHAR(TO_DATE(NVL(X.REGIME_ST_DT_FIM,
        --                                  '31/12/9999'),
        --                              'DD/MM/YYYY'),
        --                      'YYYYMM')));
        ---
        TYPE t_tab_prod_audit IS RECORD
        (
            cod_filial VARCHAR2 ( 100 )
          , periodo VARCHAR2 ( 100 )
          , cnpj_filial VARCHAR2 ( 100 )
          , cnpj_matriz VARCHAR2 ( 100 )
          , ie_filial VARCHAR2 ( 100 )
          , cod_item VARCHAR2 ( 100 )
          , descr_item VARCHAR2 ( 100 )
          , aliquota_interna_icms VARCHAR2 ( 100 )
          , regime_st_dt_ini VARCHAR2 ( 100 )
          , regime_st_dt_fim VARCHAR2 ( 100 )
          , unid_inv VARCHAR2 ( 100 )
          , aliquota_dt_ini VARCHAR2 ( 100 )
          , aliquota_dt_fim VARCHAR2 ( 100 )
          , cod_ncm VARCHAR2 ( 100 )
          , cod_barras VARCHAR2 ( 100 )
          , cest VARCHAR2 ( 100 )
          , metodologia_st VARCHAR2 ( 100 )
          , in_movimentacao VARCHAR2 ( 100 )
          , aliq_reducao VARCHAR2 ( 100 )
        );

        TYPE t_tab_p_audit IS TABLE OF t_tab_prod_audit;

        tab_prod t_tab_p_audit;
        ---
        errors NUMBER;
        dml_errors EXCEPTION;
        err_idx INTEGER;
        err_code NUMBER;
        err_msg VARCHAR2 ( 255 );
        ---
        v_code_err VARCHAR2 ( 20 );
        v_msg_err VARCHAR2 ( 254 );
        v_prod_count NUMBER := 0;
        ---
        v_part_mov VARCHAR2 ( 100 );
        v_sql VARCHAR2 ( 4000 );
        c_prod_gtt SYS_REFCURSOR;

        ---
        TYPE r_tab_prod IS RECORD
        (
            cod_item VARCHAR2 ( 20 )
          , unid_inv VARCHAR2 ( 3 )
        );

        TYPE t_tab_prod IS TABLE OF r_tab_prod;

        tab_prod_gtt t_tab_prod;
    BEGIN
        msafi.upd_ps_translate ( 'DSP_ALIQ_ICMS' ); --ATUALIZAR TRANSLATES EM TAB LOCAL
        msafi.upd_ps_translate ( 'DSP_TP_CALC_ST' );

        dbms_application_info.set_module ( $$plsql_unit
                                         , 'F2 PROD GTT' );

        --OBTER NOME DA PARTICAO
        BEGIN
            SELECT ' PARTITION ( ' || a.partition_name || ') '
              INTO v_part_mov
              FROM TABLE ( msafi.dpsp_recupera_particao ( 'MSAFI'
                                                        , 'DPSP_FIN151_CAT42_MOV'
                                                        , pdt_ini
                                                        , pdt_fim ) ) a;
        EXCEPTION
            WHEN OTHERS THEN
                v_part_mov := ' ';
        END;

        ---
        v_sql := 'SELECT /*+PARALLEL(8)*/ DISTINCT COD_ITEM, UNID_INV ';
        v_sql := v_sql || 'FROM MSAFI.DPSP_FIN151_CAT42_MOV ' || v_part_mov || ' ';

        IF ( v_part_mov = ' ' ) THEN
            v_sql :=
                   v_sql
                || 'WHERE DATA BETWEEN TO_DATE('''
                || TO_CHAR ( pdt_ini
                           , 'DDMMYYYY' )
                || ''',''DDMMYYYY'') ';
            v_sql :=
                   v_sql
                || '               AND TO_DATE('''
                || TO_CHAR ( pdt_fim
                           , 'DDMMYYYY' )
                || ''',''DDMMYYYY'') ';
        END IF;

        OPEN c_prod_gtt FOR v_sql;

        LOOP
            FETCH c_prod_gtt
                BULK COLLECT INTO tab_prod_gtt
                LIMIT 100;

            IF tab_prod_gtt.COUNT > 0 THEN
                FOR i IN tab_prod_gtt.FIRST .. tab_prod_gtt.LAST LOOP
                    INSERT INTO msafi.dpsp_cat42_f2_prod
                         VALUES ( tab_prod_gtt ( i ).cod_item
                                , tab_prod_gtt ( i ).unid_inv ); --GTT
                END LOOP;

                COMMIT;
            END IF;

            EXIT WHEN tab_prod_gtt.COUNT = 0;
            tab_prod_gtt.delete;
        END LOOP;

        CLOSE c_prod_gtt;

        dbms_application_info.set_module ( $$plsql_unit
                                         , 'F2 FICHA2_CARREGAR' );

        FOR k IN ( SELECT a.cod_produto
                        , a.valid_produto
                        , a.ident_produto
                     FROM (SELECT x2013.cod_produto
                                , x2013.valid_produto
                                , x2013.ident_produto
                                , RANK ( )
                                      OVER ( PARTITION BY x2013.cod_produto
                                             ORDER BY x2013.valid_produto DESC )
                                      RANK
                             FROM msaf.x2013_produto x2013
                            WHERE x2013.valid_produto <= pdt_fim) a
                    WHERE a.RANK = 1 ) LOOP
            ---------------------------------------------------------
            OPEN c_prod ( k.cod_produto
                        , k.valid_produto
                        , k.ident_produto );

            LOOP
                FETCH c_prod
                    BULK COLLECT INTO tab_prod;

                BEGIN
                    FORALL i IN tab_prod.FIRST .. tab_prod.LAST SAVE EXCEPTIONS
                        INSERT INTO msafi.dpsp_fin151_cat42_prod ( cod_filial
                                                                 , periodo
                                                                 , cnpj_filial
                                                                 , cnpj_matriz
                                                                 , ie_filial
                                                                 , cod_item
                                                                 , descr_item
                                                                 , aliquota_interna_icms
                                                                 , regime_st_dt_ini
                                                                 , regime_st_dt_fim
                                                                 , unid_inv
                                                                 , aliquota_dt_ini
                                                                 , aliquota_dt_fim
                                                                 , cod_ncm
                                                                 , cod_barras
                                                                 , cest
                                                                 , metodologia_st
                                                                 , in_movimentacao
                                                                 , proc_id
                                                                 , nm_usuario
                                                                 , dt_carga
                                                                 , aliq_reducao )
                             VALUES ( tab_prod ( i ).cod_filial
                                    , TO_NUMBER ( tab_prod ( i ).periodo )
                                    , TO_NUMBER ( tab_prod ( i ).cnpj_filial )
                                    , TO_NUMBER ( tab_prod ( i ).cnpj_matriz )
                                    , TO_NUMBER ( tab_prod ( i ).ie_filial )
                                    , tab_prod ( i ).cod_item
                                    , tab_prod ( i ).descr_item
                                    , TO_NUMBER ( tab_prod ( i ).aliquota_interna_icms )
                                    , tab_prod ( i ).regime_st_dt_ini
                                    , tab_prod ( i ).regime_st_dt_fim
                                    , tab_prod ( i ).unid_inv
                                    , tab_prod ( i ).aliquota_dt_ini
                                    , tab_prod ( i ).aliquota_dt_fim
                                    , NVL ( tab_prod ( i ).cod_ncm, '00000000' )
                                    , NVL ( tab_prod ( i ).cod_barras, '000000000000000' )
                                    , NVL ( tab_prod ( i ).cest, '0000000' )
                                    , tab_prod ( i ).metodologia_st
                                    , tab_prod ( i ).in_movimentacao
                                    , mproc_id
                                    , mnm_usuario
                                    , v_data_hora_ini
                                    , NVL ( tab_prod ( i ).aliq_reducao, 0 ) );

                    v_count := v_count + SQL%ROWCOUNT;
                    dbms_application_info.set_module ( $$plsql_unit
                                                     , 'F2 PRD - QTD ' || v_count );
                    COMMIT;
                EXCEPTION
                    WHEN OTHERS THEN
                        errors := SQL%BULK_EXCEPTIONS.COUNT;

                        FOR i IN 1 .. errors LOOP
                            err_idx := SQL%BULK_EXCEPTIONS ( i ).ERROR_INDEX;
                            err_code := SQL%BULK_EXCEPTIONS ( i ).ERROR_CODE;
                            err_msg := SQLERRM ( -SQL%BULK_EXCEPTIONS ( i ).ERROR_CODE );

                            INSERT INTO msafi.log_geral ( ora_err_number1
                                                        , ora_err_mesg1
                                                        , cod_empresa
                                                        , cod_estab
                                                        , num_docfis
                                                        , data_fiscal
                                                        , serie_docfis
                                                        , col14
                                                        , col15
                                                        , col16
                                                        , num_item
                                                        , col17
                                                        , col18
                                                        , col19
                                                        , col20
                                                        , col21
                                                        , col22
                                                        , movto_e_s
                                                        , norm_dev
                                                        , ident_docto
                                                        , ident_fis_jur )
                                 VALUES ( err_code
                                        , err_msg
                                        , msafi.dpsp.empresa
                                        , tab_prod ( err_idx ).cod_filial
                                        , ' '
                                        , ' '
                                        , ' '
                                        , tab_prod ( err_idx ).cod_item
                                        , 'SP'
                                        , tab_prod ( err_idx ).periodo
                                        , ' '
                                        , 'DPSP_FIN151_CAT42_FICHAS_CPROC'
                                        , 'FICHA2_CARREGAR'
                                        , tab_prod ( err_idx ).aliquota_interna_icms
                                        , tab_prod ( err_idx ).in_movimentacao
                                        , TO_CHAR ( SYSDATE
                                                  , 'DD/MM/YYYY HH24:MI.SS' )
                                        , mproc_id
                                        , ' '
                                        , ' '
                                        , ' '
                                        , ' ' );
                        END LOOP;

                        COMMIT;
                END;

                tab_prod.delete;
                EXIT WHEN c_prod%NOTFOUND;
            END LOOP;

            CLOSE c_prod;

            COMMIT;
        -----------------------------------------------------


        END LOOP;

        ---AJUSTE ALIQ REDUCAO VIA EXCECAO PS
        FOR k IN ( SELECT ROWID AS row_id
                     FROM msafi.dpsp_fin151_cat42_prod
                    WHERE periodo = pdt_periodo
                      AND ( aliq_reducao IS NULL
                        OR aliq_reducao = 0 )
                      AND cod_ncm IN ( '04022110'
                                     , '15099090'
                                     , '19011010'
                                     , '04022120' )
                      AND cod_item NOT IN ( '213543'
                                          , '47945'
                                          , '8486'
                                          , '39314'
                                          , '213144'
                                          , '213152'
                                          , '58378'
                                          , '58386'
                                          , '213160'
                                          , '213179'
                                          , '76554'
                                          , '58343'
                                          , '263630'
                                          , '272183'
                                          , '285200'
                                          , '285218'
                                          , '285226'
                                          , '318418'
                                          , '330710'
                                          , '330728'
                                          , '337064'
                                          , '337080'
                                          , '376191'
                                          , '39314'
                                          , '355984'
                                          , '349399'
                                          , '356000'
                                          , '469564'
                                          , '430897' )
                      AND regime_st_dt_ini >= TO_DATE ( '02122013'
                                                      , 'DDMMYYYY' ) ) LOOP
            UPDATE msafi.dpsp_fin151_cat42_prod
               SET aliq_reducao = 61.11
             WHERE periodo = pdt_periodo
               AND ROWID = k.row_id;

            COMMIT;
        END LOOP;
    ---SELECT * FROM FDSPPRD.PS_EXC_RCRT_PBL@DBLINK_DBPSPROD R
    ---WHERE R.SETID = 'GERAL'
    ---AND R.RULE_ID_PBL = '00102'
    ---AND R.EFFDT = (SELECT MAX(RR.EFFDT)
    ---            FROM FDSPPRD.PS_EXC_RCRT_PBL@DBLINK_DBPSPROD RR
    ---            WHERE RR.SETID = R.SETID
    ---              AND RR.RULE_ID_PBL = R.RULE_ID_PBL
    ---              AND RR.EFFDT <= SYSDATE)
    ---ORDER BY 4
    ------
    ---SELECT * FROM FDSPPRD.PS_EXC_RULE_PBL@DBLINK_DBPSPROD
    ---WHERE RULE_TYPE_PBL = 'REDB'
    ---AND SETID = 'GERAL'
    ---AND TAX_TYPE_PBL = 'ICST'
    ---AND EFF_STATUS = 'A'

    END;

    PROCEDURE ficha2_create_tables ( vp_proc_instance IN VARCHAR2
                                   , vp_tab_estabs   OUT VARCHAR2
                                   , vp_tab_entrada_ini   OUT VARCHAR2
                                   , vp_tab_produtos   OUT VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 4000 );
    BEGIN
        vp_tab_estabs :=
            msaf.dpsp_create_tab_tmp ( vp_proc_instance
                                     , vp_proc_instance
                                     , 'TAB_CAT2_F2_PART'
                                     , mnm_usuario );

        IF ( vp_tab_estabs = 'ERRO' ) THEN
            raise_application_error ( -20001
                                    , '!ERRO CREATE VP_TAB_ESTABS' );
        END IF;

        loga ( 'TAB PARA ESTABELECIMENTOS- ' || vp_tab_estabs
             , FALSE );
        --==================================================

        vp_tab_entrada_ini :=
            msaf.dpsp_create_tab_tmp ( vp_proc_instance
                                     , vp_proc_instance
                                     , 'TAB_CAT2_F2_ENT'
                                     , mnm_usuario );

        IF ( vp_tab_entrada_ini = 'ERRO' ) THEN
            raise_application_error ( -20001
                                    , '!ERRO CREATE VP_TAB_ENTRADA_INI' );
        END IF;

        loga ( 'TAB PARA LOAD_ENTRADAS- ' || vp_tab_entrada_ini
             , FALSE );
        --==================================================

        vp_tab_produtos :=
            msaf.dpsp_create_tab_tmp ( vp_proc_instance
                                     , vp_proc_instance
                                     , 'TAB_CAT2_F2_PRD'
                                     , mnm_usuario );

        IF ( vp_tab_produtos = 'ERRO' ) THEN
            raise_application_error ( -20001
                                    , '!ERRO CREATE VP_TAB_PRODUTOS' );
        END IF;

        loga ( 'TAB TEMP DE PRODUTOS- ' || vp_tab_produtos
             , FALSE );
    --==================================================

    END; --FICHA2_CREATE_ENTRADAS

    PROCEDURE ficha2_load_entradas ( pcod_estab IN VARCHAR2
                                   , vp_tab_entrada_ini IN VARCHAR2
                                   , vp_tab_estabs IN VARCHAR
                                   , vp_data_ini IN DATE
                                   , vp_data_fim IN DATE
                                   , vp_data_hora_ini IN VARCHAR2
                                   , pproc_id IN INTEGER )
    IS
        v_sql VARCHAR2 ( 4000 );
    BEGIN
        v_sql := 'DECLARE TYPE T_TAB_E IS TABLE OF MSAF.' || vp_tab_entrada_ini || '%ROWTYPE; ';
        v_sql := v_sql || '        TAB_E T_TAB_E := T_TAB_E(); ';
        v_sql := v_sql || 'BEGIN ';
        ---
        v_sql := v_sql || ' DBMS_APPLICATION_INFO.SET_MODULE(''DPSP_FIN151_CAT42_FICHAS_CPROC'', ''F2 LOAD E''); ';
        v_sql := v_sql || ' SELECT ';
        v_sql := v_sql || '  E.COD_EMPRESA, ';
        v_sql := v_sql || '  E.COD_ESTAB, ';
        v_sql := v_sql || '  E.NUM_CONTROLE_DOCTO, ';
        v_sql := v_sql || '  E.NUM_AUTENTIC_NFE, ';
        v_sql := v_sql || '  E.NUM_DOCFIS, ';
        v_sql := v_sql || '  E.NUM_ITEM, ';
        v_sql := v_sql || '  E.QUANTIDADE, ';
        v_sql := v_sql || '  E.COD_PRODUTO, ';
        v_sql := v_sql || '  E.DATA_FISCAL, ';
        v_sql := v_sql || '  E.COD_FIS_JUR, ';
        v_sql := v_sql || '  E.ROWID AS ROWID_X07, ';
        v_sql := v_sql || '  NULL AS ROWID_X08, ';
        v_sql := v_sql || '  ' || mproc_id || ' AS PROC_ID ';
        v_sql := v_sql || ' BULK COLLECT INTO TAB_E ';
        v_sql := v_sql || ' FROM MSAFI.DPSP_NF_ENTRADA E, ';
        v_sql := v_sql || '      (SELECT DISTINCT COD_ITEM ';
        v_sql := v_sql || '       FROM MSAFI.DPSP_FIN151_CAT42_PROD ';
        v_sql := v_sql || '       WHERE IN_MOVIMENTACAO = ''N'' ';
        v_sql :=
               v_sql
            || '         AND PERIODO = '
            || TO_CHAR ( vp_data_ini
                       , 'YYYYMM' )
            || ' ';
        v_sql := v_sql || '         AND PROC_ID = ' || mproc_id || ' ) CAT42 ';
        v_sql := v_sql || ' WHERE E.COD_ESTAB = ''' || pcod_estab || ''' ';
        --FILTROS
        --ENTRAS DE 24 MESES ATRÁS PARA FINALIDADE IST
        v_sql := v_sql || '   AND E.COD_NATUREZA_OP = ''IST'' ';
        v_sql :=
               v_sql
            || '   AND E.DATA_FISCAL    >= ADD_MONTHS(TO_DATE('''
            || TO_DATE ( vp_data_ini
                       , 'DD/MM/YYYY' )
            || ''', ''DD/MM/YYYY''),-24)  ';
        v_sql :=
               v_sql
            || '   AND E.DATA_FISCAL    <= TO_DATE('''
            || TO_DATE ( vp_data_ini
                       , 'DD/MM/YYYY' )
            || ''', ''DD/MM/YYYY'')  ';
        v_sql := v_sql || '   AND E.SITUACAO        = ''N'' ';
        --SOMENTE VALIDAR PRODUTOS COM CODIGO DE BARRAS NÃO ENCONTRADO
        v_sql := v_sql || '   AND CAT42.COD_ITEM    = E.COD_PRODUTO; ';
        ---
        v_sql := v_sql || 'DBMS_APPLICATION_INFO.SET_MODULE(''DPSP_FIN151_CAT42_FICHAS_CPROC'', ''F2 INSERT E''); ';
        v_sql := v_sql || 'FORALL I IN TAB_E.FIRST .. TAB_E.LAST ';
        v_sql := v_sql || '  INSERT INTO MSAF.' || vp_tab_entrada_ini || ' VALUES TAB_E(I); ';
        v_sql := v_sql || 'COMMIT; ';
        v_sql := v_sql || 'END; ';

        BEGIN
            EXECUTE IMMEDIATE v_sql;
        EXCEPTION
            WHEN OTHERS THEN
                raise_application_error ( -20001
                                        , 'ERRO FICHA2_LOAD_ENTRADAS: ' || SQLERRM );
        END;
    END; -- FICHA2_LOAD_ENTRADAS

    PROCEDURE ficha2_load_produtos ( vp_proc_instance IN VARCHAR2
                                   , vp_tab_produtos IN VARCHAR2
                                   , vp_tab_entrada_ini IN VARCHAR2
                                   , vp_data_ini IN DATE
                                   , vp_data_fim IN DATE
                                   , vp_data_hora_ini IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 4000 );
        v_qtde_xml INTEGER := 0;
    BEGIN
        loga ( 'LOAD_PRODUTOS-INI '
             , FALSE );

        v_sql := '  INSERT INTO MSAF.' || vp_tab_produtos || ' ';
        v_sql := v_sql || '  SELECT DISTINCT ';
        v_sql := v_sql || '  COD_PRODUTO AS COD_ITEM, ';
        v_sql := v_sql || '  PROC_ID ';
        v_sql := v_sql || '  FROM MSAF.' || vp_tab_entrada_ini;
        v_sql := v_sql || '  WHERE PROC_ID = ' || mproc_id || ' ';

        --V_SQL := V_SQL || '  AND COD_ESTAB = ''' || PCOD_ESTAB || '''';

        BEGIN
            EXECUTE IMMEDIATE v_sql;

            save_tmp_control ( mproc_id
                             , vp_proc_instance
                             , vp_tab_produtos );
            loga ( 'LOAD_PRODUTOS- ' || vp_tab_produtos
                 , FALSE );
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
                --ENVIAR EMAIL DE ERRO-------------------------------------------
                envia_email ( mcod_empresa
                            , vp_data_ini
                            , vp_data_fim
                            , SQLERRM
                            , 'E'
                            , vp_data_hora_ini );
                -----------------------------------------------------------------
                raise_application_error ( -20007
                                        , '!ERRO INSERT LOAD PRODUTOS! [1]' );
        END;

        -- V_SQL := 'SELECT COUNT(1) QTD FROM MSAFI.' || VP_TAB_PRODUTOS;
        v_sql := 'SELECT COUNT(1) QTD FROM MSAF.' || vp_tab_produtos;

        EXECUTE IMMEDIATE v_sql            INTO v_qtde_xml;

        loga ( 'LOAD_PRODUTOS-FIM QTD ' || v_qtde_xml || ' LINHAS'
             , FALSE );
    END; -- LOAD_PRODUTOS

    PROCEDURE ficha2_extrair ( flg_dw CHAR
                             , flg_utl CHAR
                             , pdiretorio VARCHAR2
                             , parquivo VARCHAR2
                             , pdt_periodo INTEGER )
    IS
        l_vdir VARCHAR2 ( 10000 );
        l_farquivo_w utl_file.file_type;
        l_vline VARCHAR2 ( 32767 );
        v_existe INTEGER;
    BEGIN
        IF flg_utl = 'S' THEN
            l_vdir := pdiretorio;
            l_vline := '';
            l_farquivo_w :=
                utl_file.fopen ( l_vdir
                               , parquivo
                               , 'W' );
        END IF;

        IF flg_dw = 'S' THEN
            lib_proc.add_tipo ( mproc_id
                              , 2
                              , parquivo
                              , 2 );
        END IF;

        FOR i IN ( SELECT cod_filial
                        , periodo
                        , cnpj_filial
                        , cnpj_matriz
                        , ie_filial
                        , cod_item
                        , descr_item
                        , aliquota_interna_icms
                        , regime_st_dt_ini
                        , regime_st_dt_fim
                        , unid_inv
                        , aliquota_dt_ini
                        , aliquota_dt_fim
                        , cod_ncm
                        , cod_barras
                        , cest
                        , REPLACE ( metodologia_st
                                  , '<ERRO - VLR NAO LOCALIZADO>'
                                  , '' )
                              AS metodologia_st
                        , aliq_reducao
                     FROM msafi.dpsp_fin151_cat42_prod
                    WHERE 1 = 1
                      AND periodo = pdt_periodo
                      AND in_movimentacao = 'S'
                      AND proc_id = mproc_id ) LOOP
            l_vline :=
                   i.cod_filial
                || '|'
                || i.periodo
                || '|'
                || i.cnpj_filial
                || '|'
                || i.cnpj_matriz
                || '|'
                || i.ie_filial
                || '|'
                || i.cod_item
                || '|'
                || i.descr_item
                || '|'
                || i.aliquota_interna_icms
                || '|'
                || i.regime_st_dt_ini
                || '|'
                || i.regime_st_dt_fim
                || '|'
                || i.unid_inv
                || '|'
                || i.aliquota_dt_ini
                || '|'
                || i.aliquota_dt_fim
                || '|'
                || i.cod_ncm
                || '|'
                || i.cod_barras
                || '|'
                || i.cest
                || '|'
                || i.metodologia_st
                || '|'
                || i.aliq_reducao;

            IF flg_utl = 'S' THEN
                utl_file.put_line ( l_farquivo_w
                                  , l_vline );
            END IF;

            IF flg_dw = 'S' THEN
                lib_proc.add ( l_vline
                             , NULL
                             , NULL
                             , 2 );
            END IF;
        END LOOP;

        IF flg_utl = 'S' THEN
            utl_file.fclose ( l_farquivo_w );
        END IF;
    END;

    PROCEDURE ficha3_gerar ( p_proc_instance VARCHAR2
                           , pcod_estab VARCHAR2
                           , pdt_ini DATE
                           , pdt_fim DATE
                           , pdt_periodo INTEGER
                           , v_data_hora_ini VARCHAR2 )
    IS
        vp_tab_entrada_ini VARCHAR2 ( 50 );
        vp_tab_produtos VARCHAR2 ( 50 );
        vp_tab_ficha3 VARCHAR2 ( 50 );
        v_sql VARCHAR2 ( 4000 );
        v_qtde_prod INTEGER := 0;
    BEGIN
        --TABELA INICIAL DE ENTRADAS CARREGADA NO PROCESSO LOAD ENTRADAS
        vp_tab_entrada_ini := 'DPSP_F3ENT_' || p_proc_instance;

        vp_tab_produtos :=
            msaf.dpsp_create_tab_tmp ( p_proc_instance
                                     , p_proc_instance
                                     , 'TAB_X52'
                                     , mnm_usuario );

        IF ( vp_tab_produtos = 'ERRO' ) THEN
            raise_application_error ( -20001
                                    , '!ERRO CREATE TAB X52!' );
        END IF;

        --VP_TAB_FICHA3    <= Irá receber o valor da PROC

        loga ( '-------------------------'
             , FALSE );
        loga ( 'FICHA 3'
             , FALSE );
        loga ( pcod_estab
             , FALSE );
        loga ( pdt_ini
             , FALSE );
        loga ( pdt_fim
             , FALSE );
        loga ( '-------------------------'
             , FALSE );

        --DBMS_APPLICATION_INFO.SET_MODULE($$PLSQL_UNIT, 'F3 LOAD ENT' || ' - ' || PCOD_ESTAB);
        --
        --FICHA3_LOAD_ENTRADAS(P_PROC_INSTANCE,
        --                     VP_TAB_ENTRADA_INI,
        --                     PDT_INI,
        --                     PDT_FIM,
        --                     V_DATA_HORA_INI,
        --                     PCOD_ESTAB);
        --
        --COMMIT;

        dbms_application_info.set_module ( $$plsql_unit
                                         , 'F3 LOAD PRD' || ' - ' || pcod_estab );

        ficha3_load_produtos ( p_proc_instance
                             , vp_tab_produtos
                             , vp_tab_entrada_ini
                             , pdt_ini
                             , pdt_fim
                             , v_data_hora_ini
                             , pcod_estab
                             , v_qtde_prod );

        IF ( v_qtde_prod > 0 ) THEN --(1)
            --============================================================================
            --- INI- COMPOSIÇÃO DAS NOTAS DO INVENTÁRIO
            --============================================================================
            BEGIN
                dbms_application_info.set_module ( $$plsql_unit
                                                 , 'F3 INS INV' || ' - ' || pcod_estab );

                loga ( 'INSERT_INVENTARIO-INI '
                     , FALSE );

                msafi.dpsp_cat42_ficha3 ( p_proc_instance
                                        , vp_tab_produtos
                                        , pcod_estab
                                        , TO_CHAR ( pdt_fim
                                                  , 'YYYYMM' )
                                        , 'Y'
                                        , -- AUDITORIA: PARA NÃO APAGAR A TABELA
                                         'NONE'
                                        , vp_tab_ficha3 );

                save_tmp_control ( mproc_id
                                 , p_proc_instance
                                 , vp_tab_ficha3 );

                EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT="DD/MM/YYYY"';

                loga ( 'INSERT_INVENTARIO - ' || vp_tab_ficha3
                     , FALSE );
                loga ( 'INSERT_INVENTARIO-FIM'
                     , FALSE );
            EXCEPTION
                WHEN OTHERS THEN
                    loga ( 'SQLERRM: ' || SQLERRM
                         , FALSE );
                    --ENVIAR EMAIL DE ERRO-------------------------------------------
                    envia_email ( mcod_empresa
                                , pdt_ini
                                , pdt_ini
                                , SQLERRM
                                , 'E'
                                , v_data_hora_ini );
                    -----------------------------------------------------------------
                    raise_application_error ( -20007
                                            , 'ERRO INSERT_INVENTARIO: ' || SQLERRM );
            END;

            IF vp_tab_ficha3 != '[EMPTY TABLE]' THEN
                v_sql := ' INSERT INTO MSAFI.DPSP_FIN151_CAT42_INV ';
                v_sql := v_sql || ' SELECT ';
                v_sql := v_sql || ' F3.COD_FILIAL, ';
                v_sql := v_sql || ' F3.CNPJ_FILIAL, ';
                v_sql := v_sql || ' F3.IE_FILIAL, ';
                v_sql := v_sql || ' F3.PERIODO, ';
                v_sql := v_sql || ' F3.COD_ITEM, ';
                v_sql := v_sql || ' NVL(F3.QTD_INI,0) AS  QTD_INI, ';
                v_sql := v_sql || ' NVL(F3.ICMS_TOT_INI,0) AS ICMS_OP_MEDIO, ';
                v_sql := v_sql || ' NVL(F3.ICMS_ST_TOT_INI,0) AS ICMS_ST_MEDIO, ';
                v_sql := v_sql || mproc_id || 'AS PROC_ID ,';
                v_sql := v_sql || ' ''' || mnm_usuario || '''  AS NM_USUARIO ,';
                v_sql := v_sql || ' ''' || v_data_hora_ini || '''  AS DT_CARGA ';
                v_sql := v_sql || ' FROM MSAFI.' || vp_tab_ficha3 || ' F3 ';

                BEGIN
                    EXECUTE IMMEDIATE v_sql;

                    COMMIT;
                END;
            END IF;
        --============================================================================
        --- FIM- COMPOSIÇÃO DAS NOTAS DO INVENTÁRIO
        --============================================================================

        ELSE
            loga ( '>>> ATENCAO! NAO EXISTE SALDO DE ESTOQUE (X52) PARA O ESTABELECIMENTO / PERIODO INFORMADO!'
                 , FALSE );
        END IF; --(1)
    END;

    PROCEDURE ficha3_load_entradas ( vp_proc_instance IN VARCHAR2
                                   , vp_tab_entrada_ini IN VARCHAR2
                                   , vp_data_ini IN DATE
                                   , vp_data_fim IN DATE
                                   , vp_data_hora_ini IN VARCHAR2
                                   , pcod_estab IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 4000 );
        v_qtde_xml NUMBER := 0;
        v_nr_particoes INTEGER := 30;
    BEGIN
        loga ( 'LOAD_ENTRADAS-INI '
             , FALSE );

        v_sql := ' CREATE TABLE ' || vp_tab_entrada_ini;
        v_sql := v_sql || ' (COD_EMPRESA       VARCHAR2(3), ';
        v_sql := v_sql || ' COD_ESTAB          VARCHAR2(6), ';
        v_sql := v_sql || ' NUM_CONTROLE_DOCTO VARCHAR2(12), ';
        v_sql := v_sql || ' NUM_AUTENTIC_NFE   VARCHAR2(80), ';
        v_sql := v_sql || ' NUM_DOCFIS         VARCHAR2(12), ';
        v_sql := v_sql || ' NUM_ITEM           NUMBER(5), ';
        v_sql := v_sql || ' QUANTIDADE         NUMBER(17,6), ';
        v_sql := v_sql || ' COD_PRODUTO        VARCHAR2(35), ';
        v_sql := v_sql || ' DATA_FISCAL        DATE not null, ';
        v_sql := v_sql || ' COD_FIS_JUR        VARCHAR2(14), ';
        v_sql := v_sql || ' ROWID_X07          ROWID, ';
        v_sql := v_sql || ' ROWID_X08          ROWID, ';
        v_sql := v_sql || ' PROC_ID            NUMBER, ';
        v_sql := v_sql || ' NR_PARTICAO INTEGER ';
        v_sql := v_sql || ' ) ';
        v_sql := v_sql || ' PARTITION BY LIST (NR_PARTICAO) (';
        v_sql := v_sql || ' PARTITION P_ID01 VALUES(1), ';
        v_sql := v_sql || ' PARTITION P_ID02 VALUES(2), ';
        v_sql := v_sql || ' PARTITION P_ID03 VALUES(3), ';
        v_sql := v_sql || ' PARTITION P_ID04 VALUES(4), ';
        v_sql := v_sql || ' PARTITION P_ID05 VALUES(5), ';
        v_sql := v_sql || ' PARTITION P_ID06 VALUES(6), ';
        v_sql := v_sql || ' PARTITION P_ID07 VALUES(7), ';
        v_sql := v_sql || ' PARTITION P_ID08 VALUES(8), ';
        v_sql := v_sql || ' PARTITION P_ID09 VALUES(9), ';
        v_sql := v_sql || ' PARTITION P_ID10 VALUES(10), ';
        v_sql := v_sql || ' PARTITION P_ID11 VALUES(11), ';
        v_sql := v_sql || ' PARTITION P_ID12 VALUES(12), ';
        v_sql := v_sql || ' PARTITION P_ID13 VALUES(13), ';
        v_sql := v_sql || ' PARTITION P_ID14 VALUES(14), ';
        v_sql := v_sql || ' PARTITION P_ID15 VALUES(15), ';
        v_sql := v_sql || ' PARTITION P_ID16 VALUES(16), ';
        v_sql := v_sql || ' PARTITION P_ID17 VALUES(17), ';
        v_sql := v_sql || ' PARTITION P_ID18 VALUES(18), ';
        v_sql := v_sql || ' PARTITION P_ID19 VALUES(19), ';
        v_sql := v_sql || ' PARTITION P_ID20 VALUES(20), ';
        v_sql := v_sql || ' PARTITION P_ID21 VALUES(21), ';
        v_sql := v_sql || ' PARTITION P_ID22 VALUES(22), ';
        v_sql := v_sql || ' PARTITION P_ID23 VALUES(23), ';
        v_sql := v_sql || ' PARTITION P_ID24 VALUES(24), ';
        v_sql := v_sql || ' PARTITION P_ID25 VALUES(25), ';
        v_sql := v_sql || ' PARTITION P_ID26 VALUES(26), ';
        v_sql := v_sql || ' PARTITION P_ID27 VALUES(27), ';
        v_sql := v_sql || ' PARTITION P_ID28 VALUES(28), ';
        v_sql := v_sql || ' PARTITION P_ID29 VALUES(29), ';
        v_sql := v_sql || ' PARTITION P_ID30 VALUES(30) ';
        v_sql := v_sql || ' ) NOLOGGING ';

        BEGIN
            EXECUTE IMMEDIATE v_sql;

            save_tmp_control ( mproc_id
                             , vp_proc_instance
                             , vp_tab_entrada_ini );
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
                --ENVIAR EMAIL DE ERRO-------------------------------------------
                envia_email ( mcod_empresa
                            , vp_data_ini
                            , vp_data_fim
                            , SQLERRM
                            , 'E'
                            , vp_data_hora_ini );
                -----------------------------------------------------------------
                raise_application_error ( -20007
                                        , '!ERRO INSERT LOAD ENTRADAS! [1]' );
        END;

        v_sql := ' INSERT INTO ' || vp_tab_entrada_ini;
        v_sql := v_sql || ' SELECT /*+PARALLEL(8)*/ ';
        v_sql := v_sql || ' A.COD_EMPRESA, ';
        v_sql := v_sql || ' A.COD_ESTAB, ';
        v_sql := v_sql || ' A.NUM_CONTROLE_DOCTO, ';
        v_sql := v_sql || ' A.NUM_AUTENTIC_NFE, ';
        v_sql := v_sql || ' B.NUM_DOCFIS, ';
        v_sql := v_sql || ' B.NUM_ITEM, ';
        v_sql := v_sql || ' B.QUANTIDADE, ';
        v_sql := v_sql || ' X2013.COD_PRODUTO, ';
        v_sql := v_sql || ' A.DATA_FISCAL, ';
        v_sql := v_sql || ' X04.COD_FIS_JUR, ';
        v_sql := v_sql || ' A.ROWID AS ROWID_X07, ';
        v_sql := v_sql || ' B.ROWID AS ROWID_X08, ';
        v_sql := v_sql || ' ' || mproc_id || ' AS PROC_ID ,';
        --PARTICIONAMENTO
        v_sql :=
               v_sql
            || '  MOD(DENSE_RANK () OVER (ORDER BY A.COD_ESTAB, A.COD_EMPRESA, '
            || mproc_id
            || ', X2013.COD_PRODUTO ),30) +1 AS NR_PARTICAO ';
        v_sql := v_sql || ' FROM X07_DOCTO_FISCAL A, ';
        v_sql := v_sql || ' X08_ITENS_MERC      B, ';
        v_sql := v_sql || ' X04_PESSOA_FIS_JUR  X04, ';
        v_sql := v_sql || ' X2013_PRODUTO       X2013, ';
        v_sql := v_sql || ' X2006_NATUREZA_OP   X2006 ';

        v_sql := v_sql || ' WHERE 1 = 1 ';
        v_sql := v_sql || ' AND A.COD_EMPRESA = B.COD_EMPRESA ';
        v_sql := v_sql || ' AND A.COD_ESTAB = B.COD_ESTAB ';
        v_sql := v_sql || ' AND A.DATA_SAIDA_REC = B.DATA_FISCAL ';
        v_sql := v_sql || ' AND A.MOVTO_E_S = B.MOVTO_E_S ';
        v_sql := v_sql || ' AND A.NORM_DEV = B.NORM_DEV ';
        v_sql := v_sql || ' AND A.IDENT_DOCTO = B.IDENT_DOCTO ';
        v_sql := v_sql || ' AND A.IDENT_FIS_JUR = X04.IDENT_FIS_JUR ';
        v_sql := v_sql || ' AND B.IDENT_PRODUTO = X2013.IDENT_PRODUTO ';
        v_sql := v_sql || ' AND A.NUM_DOCFIS = B.NUM_DOCFIS ';
        v_sql := v_sql || ' AND A.SERIE_DOCFIS = B.SERIE_DOCFIS ';
        v_sql := v_sql || ' AND A.SUB_SERIE_DOCFIS = B.SUB_SERIE_DOCFIS ';
        v_sql := v_sql || ' AND X2006.IDENT_NATUREZA_OP = B.IDENT_NATUREZA_OP ';

        v_sql := v_sql || ' AND A.COD_ESTAB = ''' || pcod_estab || ''' ';
        --FILTROS
        --ENTRAS DE 24 MESES ATRÁS PARA FINALIDADE IST
        v_sql := v_sql || ' AND A.MOVTO_E_S <> ''9'' ';
        v_sql := v_sql || ' AND X2006.COD_NATUREZA_OP = ''IST'' ';

        v_sql :=
               v_sql
            || '    AND A.DATA_FISCAL >= ADD_MONTHS(TO_DATE('''
            || TO_DATE ( vp_data_ini
                       , 'DD/MM/YYYY' )
            || ''', ''DD/MM/YYYY''),-24)  ';
        v_sql :=
               v_sql
            || '    AND A.DATA_FISCAL <= TO_DATE('''
            || TO_DATE ( vp_data_ini
                       , 'DD/MM/YYYY' )
            || ''', ''DD/MM/YYYY'')  ';

        BEGIN
            EXECUTE IMMEDIATE v_sql;
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
                --ENVIAR EMAIL DE ERRO-------------------------------------------
                envia_email ( mcod_empresa
                            , vp_data_ini
                            , vp_data_fim
                            , SQLERRM
                            , 'E'
                            , vp_data_hora_ini );
                -----------------------------------------------------------------
                raise_application_error ( -20007
                                        , '!ERRO INSERT LOAD ENTRADAS! [2]' );
        END;

        v_sql := 'SELECT COUNT(1) QTD FROM ' || vp_tab_entrada_ini;

        EXECUTE IMMEDIATE v_sql            INTO v_qtde_xml;

        loga ( 'LOAD_ENTRADAS- ' || vp_tab_entrada_ini
             , FALSE );
        loga ( 'LOAD_ENTRADAS-FIM QTD ' || v_qtde_xml || ' LINHAS'
             , FALSE );
    END; -- LOAD_ENTRADAS

    PROCEDURE ficha3_load_produtos ( vp_proc_instance IN VARCHAR2
                                   , vp_tab_produtos IN VARCHAR2
                                   , vp_tab_entrada_ini IN VARCHAR2
                                   , vp_data_ini IN DATE
                                   , vp_data_fim IN DATE
                                   , vp_data_hora_ini IN VARCHAR2
                                   , pcod_estab IN VARCHAR2
                                   , v_qtde_prod   OUT INTEGER )
    IS
        v_sql VARCHAR2 ( 4000 );
        v_qtde NUMBER := 0;
    BEGIN
        loga ( 'LOAD_PRODUTOS-INI '
             , FALSE );

        v_sql := 'DECLARE TYPE T_TAB_SALDO IS TABLE OF MSAFI.' || vp_tab_produtos || '%ROWTYPE; ';
        v_sql := v_sql || '        TAB_SALDO T_TAB_SALDO := T_TAB_SALDO(); ';
        ---
        v_sql := v_sql || 'BEGIN ';
        v_sql := v_sql || ' DBMS_APPLICATION_INFO.SET_MODULE(''DPSP_FIN151_CAT42_FICHAS_CPROC'', ''F3 LOAD SALDO''); ';
        v_sql :=
               v_sql
            || ' SELECT MSAFI.DPSP.EMPRESA AS COD_EMPRESA, A.COD_ESTAB, C.COD_PRODUTO, B.COD_MEDIDA, A.QUANTIDADE ';
        v_sql := v_sql || ' BULK COLLECT INTO TAB_SALDO ';
        v_sql := v_sql || ' FROM MSAF.X52_INVENT_PRODUTO A, ';
        v_sql := v_sql || '      MSAF.X2007_MEDIDA B, ';
        v_sql := v_sql || '      MSAF.X2013_PRODUTO C ';
        v_sql := v_sql || ' WHERE COD_EMPRESA     = MSAFI.DPSP.EMPRESA ';
        v_sql := v_sql || '   AND COD_ESTAB       = :1 ';
        v_sql := v_sql || '   AND DATA_INVENTARIO = :2 ';
        v_sql := v_sql || '   AND A.IDENT_MEDIDA  = B.IDENT_MEDIDA ';
        v_sql := v_sql || '   AND A.IDENT_PRODUTO = C.IDENT_PRODUTO; ';
        --
        v_sql :=
            v_sql || ' DBMS_APPLICATION_INFO.SET_MODULE(''DPSP_FIN151_CAT42_FICHAS_CPROC'', ''F3 INSERT SALDO''); ';
        v_sql := v_sql || ' FORALL I IN TAB_SALDO.FIRST .. TAB_SALDO.LAST ';
        v_sql := v_sql || '   INSERT INTO MSAFI.' || vp_tab_produtos || ' VALUES TAB_SALDO(I); ';
        v_sql := v_sql || ' COMMIT; ';
        v_sql := v_sql || 'END; ';

        BEGIN
            EXECUTE IMMEDIATE v_sql
                USING pcod_estab
                    , vp_data_fim;
        EXCEPTION
            WHEN OTHERS THEN
                raise_application_error ( -20001
                                        , 'ERRO FICHA3_LOAD_PRODUTOS: ' || SQLERRM );
        END;

        v_sql := 'SELECT COUNT(1) QTD FROM MSAFI.' || vp_tab_produtos;

        EXECUTE IMMEDIATE v_sql            INTO v_qtde;

        v_qtde_prod := v_qtde;

        loga ( 'LOAD_PRODUTOS-FIM QTD ' || v_qtde || ' LINHAS'
             , FALSE );
    END; -- LOAD_PRODUTOS

    PROCEDURE ficha3_extrair ( flg_dw CHAR
                             , flg_utl CHAR
                             , pdiretorio VARCHAR2
                             , parquivo VARCHAR2
                             , pdt_periodo INTEGER )
    IS
        l_vdir VARCHAR2 ( 10000 );
        l_farquivo_w utl_file.file_type;
        l_vline VARCHAR2 ( 32767 );
        v_existe INTEGER;
    BEGIN
        IF flg_utl = 'S' THEN
            l_vdir := pdiretorio;
            l_vline := '';
            l_farquivo_w :=
                utl_file.fopen ( l_vdir
                               , parquivo
                               , 'W' );
        END IF;

        IF flg_dw = 'S' THEN
            lib_proc.add_tipo ( mproc_id
                              , 2
                              , parquivo
                              , 2 );
        END IF;

        FOR i IN ( SELECT cod_filial
                        , cnpj_filial
                        , ie_filial
                        , periodo
                        , cod_item
                        , REPLACE ( RTRIM ( TO_CHAR ( qtd_ini
                                                    , 'FM999999999999990.999' )
                                          , '.' )
                                  , '.'
                                  , ',' )
                              AS qtd_ini
                        , REPLACE ( RTRIM ( TO_CHAR ( icms_op_medio
                                                    , 'FM999999999999990.99' )
                                          , '.' )
                                  , '.'
                                  , ',' )
                              AS icms_op_medio
                        , REPLACE ( RTRIM ( TO_CHAR ( icms_st_medio
                                                    , 'FM999999999999990.99' )
                                          , '.' )
                                  , '.'
                                  , ',' )
                              AS icms_st_medio
                     FROM msafi.dpsp_fin151_cat42_inv
                    WHERE periodo = pdt_periodo
                      AND proc_id = mproc_id ) LOOP
            l_vline :=
                   i.cod_filial
                || '|'
                || i.cnpj_filial
                || '|'
                || i.ie_filial
                || '|'
                || i.periodo
                || '|'
                || i.cod_item
                || '|'
                || i.qtd_ini
                || '|'
                || i.icms_op_medio
                || '|'
                || i.icms_st_medio;

            IF flg_utl = 'S' THEN
                utl_file.put_line ( l_farquivo_w
                                  , l_vline );
            END IF;

            IF flg_dw = 'S' THEN
                lib_proc.add ( l_vline
                             , NULL
                             , NULL
                             , 2 );
            END IF;
        END LOOP;

        IF flg_utl = 'S' THEN
            utl_file.fclose ( l_farquivo_w );
        END IF;
    END;

    PROCEDURE ficha4_gerar ( p_part_ini INTEGER
                           , p_part_fim INTEGER
                           , p_proc_instance VARCHAR2
                           , flg_audit CHAR
                           , pdt_ini DATE
                           , pdt_fim DATE
                           , pdt_periodo INTEGER
                           , v_data_hora_ini VARCHAR2
                           , p_tab_produtos VARCHAR2
                           , p_tab_nfret VARCHAR2
                           , p_tab_partition VARCHAR2
                           , p_user VARCHAR2 )
    IS
        v_tab_nfret VARCHAR2 ( 30 );
        p_tab_retorno VARCHAR2 ( 50 );
        p_tab_aliq VARCHAR2 ( 30 );
        v_tab_anvisa VARCHAR2 ( 30 );
        v_tab_pmc VARCHAR2 ( 30 );
        v_tab_nf_cd VARCHAR2 ( 30 );
        v_tab_nf VARCHAR2 ( 30 );
        v_tab_mov VARCHAR2 ( 30 );
        v_sql VARCHAR2 ( 12000 );
        v_qtd INTEGER;
        v_cod_estab VARCHAR2 ( 6 );
        v_qtde INTEGER;
        v_tipo VARCHAR2 ( 1 );
        v_msg_erro VARCHAR2 ( 254 ) := '';

        mproc_id INTEGER;
        mnm_usuario VARCHAR2 ( 100 );

        ----
        --VAR PARA FICHA 4
        TYPE tt_tab_mov IS RECORD
        (
            ROWID VARCHAR2 ( 20 )
        );

        TYPE t_tab_mov IS TABLE OF tt_tab_mov;

        tab_mov t_tab_mov;
        ---
        v_commit INTEGER DEFAULT 0;
        v_ttl INTEGER DEFAULT 0;
    BEGIN
        EXECUTE IMMEDIATE 'SELECT COD_ESTAB, TIPO FROM ' || p_tab_partition || ' WHERE ROW_INI = :1 AND ROW_END = :2'
                       INTO v_cod_estab
                          , v_tipo
            USING p_part_ini
                , p_part_fim;

        dbms_output.put_line ( '[COD_ESTAB]:' || v_cod_estab );

        vg_module := 'FIN151_CAT42_F4_' || v_cod_estab;

        --CRIAR TEMP PARA MOVIMENTO
        v_tab_mov :=
            msaf.dpsp_create_tab_tmp ( p_proc_instance
                                     , ( p_proc_instance + p_part_fim )
                                     , 'TAB_CAT42_MOV'
                                     , p_user );

        IF ( v_tab_mov = 'ERRO' ) THEN
            raise_application_error ( -20001
                                    , '!ERRO CREATE TAB MOVIMENTO!' );
        END IF;

        -- LIMPAR AUDIT -------------------------------------------------------
        dbms_application_info.set_module ( vg_module
                                         , 'F4 LIMPA AUDIT [' || v_cod_estab || ']' );

        SELECT ROWID
          BULK COLLECT INTO tab_mov
          FROM msafi.dpsp_fin151_cat42_mov_audit
         WHERE cod_estab = v_cod_estab
           AND periodo = pdt_periodo;

        FORALL i IN tab_mov.FIRST .. tab_mov.LAST
            DELETE msafi.dpsp_fin151_cat42_mov_audit
             WHERE ROWID = tab_mov ( i ).ROWID
               AND cod_empresa = msafi.dpsp.empresa
               AND cod_estab = v_cod_estab
               AND TO_DATE ( data_fiscal_s
                           , 'DD/MM/YYYY' ) BETWEEN pdt_ini
                                                AND pdt_fim;

        COMMIT;
        tab_mov.delete;
        -- LIMPAR AUDIT -------------------------------------------------------

        ficha4_mov ( v_cod_estab
                   , pdt_ini
                   , pdt_fim
                   , pdt_periodo
                   , v_data_hora_ini
                   , p_proc_instance
                   , p_user
                   , v_tipo
                   , v_tab_mov );

        dbms_stats.gather_table_stats ( 'MSAFI'
                                      , v_tab_mov );

        EXECUTE IMMEDIATE 'UPDATE ' || p_tab_partition || ' SET STATUS = ''A'' WHERE ROW_INI = :1 AND ROW_END = :2'
            USING p_part_ini
                , p_part_fim;

        COMMIT;

        --===============================================================
        --CARREGAR TABELA DE PRODUTOS
        --LOGA('CARREGAR PRODUTOS-INI ', FALSE);

        dbms_application_info.set_module ( vg_module
                                         , 'F4 INSERT PROD' );
        v_sql := ' INSERT INTO ' || p_tab_produtos || ' ';
        v_sql := v_sql || ' SELECT DISTINCT ';
        v_sql := v_sql || '   COD_FILIAL AS COD_ESTAB, ';
        v_sql := v_sql || '   COD_ITEM, ';
        v_sql := v_sql || '   DATA AS DATA_FISCAL ';
        v_sql := v_sql || ' FROM MSAFI.' || v_tab_mov || ' ';
        v_sql := v_sql || ' WHERE COD_FILIAL = :1 ';
        v_sql := v_sql || '   AND PERIODO    = :2 ';

        EXECUTE IMMEDIATE v_sql
            USING v_cod_estab
                , TO_CHAR ( pdt_periodo );

        v_qtde := SQL%ROWCOUNT;
        --LOGA('[PRODUTOS][' || V_COD_ESTAB || '][' || SQL%ROWCOUNT || '][FIM]', FALSE);
        COMMIT;

        EXECUTE IMMEDIATE 'UPDATE ' || p_tab_partition || ' SET STATUS = ''B'' WHERE ROW_INI = :1 AND ROW_END = :2'
            USING p_part_ini
                , p_part_fim;

        COMMIT;

        IF ( v_qtde > 0 ) THEN
            dbms_application_info.set_module ( vg_module
                                             , 'F4 GET ANVISA INFO' );

            --CRIAR TEMP PARA INFO ANVISA
            v_tab_anvisa :=
                msaf.dpsp_create_tab_tmp ( p_proc_instance
                                         , ( p_proc_instance + p_part_fim )
                                         , 'TAB_ANVISA'
                                         , p_user );

            IF ( v_tab_anvisa = 'ERRO' ) THEN
                raise_application_error ( -20001
                                        , '!ERRO CREATE TAB ANVISA!' );
            ELSE
                get_anvisa_info ( p_proc_instance
                                , v_tab_anvisa
                                , p_tab_produtos );
            END IF;

            --
            v_tab_nf :=
                msaf.dpsp_create_tab_tmp ( p_proc_instance
                                         , ( p_proc_instance + p_part_fim )
                                         , 'TAB_NF_CAT42'
                                         , p_user );

            IF ( v_tab_nf = 'ERRO' ) THEN
                raise_application_error ( -20001
                                        , '!ERRO CREATE TAB NF2!' );
            END IF;

            EXECUTE IMMEDIATE 'UPDATE ' || p_tab_partition || ' SET STATUS = ''C'' WHERE ROW_INI = :1 AND ROW_END = :2'
                USING p_part_ini
                    , p_part_fim;

            COMMIT;

            --PRODUTOS ENCONTRADOS
            msafi.dpsp_get_ult_entrada_v2 ( p_tab_produtos
                                          , pdt_periodo
                                          , v_cod_estab
                                          , p_proc_instance
                                          , p_tab_retorno
                                          , p_tab_aliq
                                          , v_tipo
                                          , v_tab_mov );

            EXECUTE IMMEDIATE 'UPDATE ' || p_tab_partition || ' SET STATUS = ''D'' WHERE ROW_INI = :1 AND ROW_END = :2'
                USING p_part_ini
                    , p_part_fim;

            COMMIT;

            --===============================================================
            --ATUALIZAR REGISTROS DA FICHA 4

            IF ( v_tipo = 'L' ) THEN --APENAS PARA LOJAS
                get_cd_to_loja_xml ( v_cod_estab
                                   , pdt_periodo
                                   , v_tab_mov ); --BUSCAR IMPOSTOS DA PROPRIA NF

                EXECUTE IMMEDIATE
                    'UPDATE ' || p_tab_partition || ' SET STATUS = ''E'' WHERE ROW_INI = :1 AND ROW_END = :2'
                    USING p_part_ini
                        , p_part_fim;

                COMMIT;
                ---

                -- DSP910 ---------------------------------------------------------------------------------------------------
                dbms_application_info.set_module ( vg_module
                                                 , 'F4 SEL IMPOSTOS DSP910' );
                v_sql := 'DECLARE TYPE T_TAB_ENTRADA IS RECORD ( ';
                v_sql := v_sql || '           COD_ESTAB VARCHAR2(8), ';
                v_sql := v_sql || '           COD_PRODUTO VARCHAR2(16), ';
                v_sql := v_sql || '           DATA_FISCAL_S DATE, ';
                v_sql := v_sql || '           VLR_BASE_ICMS NUMBER(15,4), ';
                v_sql := v_sql || '           VLR_ICMS_UNIT NUMBER(15,4), ';
                v_sql := v_sql || '           VLR_BASE_ICMS_ST NUMBER(15,4), ';
                v_sql := v_sql || '           VLR_ICMS_ST_UNIT NUMBER(15,4), ';
                v_sql := v_sql || '           VLR_BASE_ICMSST_RET NUMBER(15,4), ';
                v_sql := v_sql || '           VLR_ICMSST_RET_UNIT NUMBER(15,4), ';
                v_sql := v_sql || '           ALIQ_INTERNA VARCHAR2(6), ';
                v_sql := v_sql || '           VLR_BASE_ICMS_ST_XML NUMBER(15,4), ';
                v_sql := v_sql || '           VLR_PCT_MVA NUMBER(5,2), ';
                v_sql := v_sql || '           NUM_AUTENTIC_NFE VARCHAR2(80), ';
                v_sql := v_sql || '           DATA_FISCAL DATE, ';
                v_sql := v_sql || '           ALIQ_ICMS NUMBER, ';
                v_sql := v_sql || '           CFOP_FORN VARCHAR2(6), ';
                v_sql := v_sql || '           ROW_ID VARCHAR2(30)); ';
                v_sql := v_sql || '        TYPE T_TAB_E IS TABLE OF T_TAB_ENTRADA; ';
                v_sql := v_sql || '        TAB_E T_TAB_E; ';
                v_sql := v_sql || 'BEGIN ';
                v_sql :=
                       v_sql
                    || '   SELECT ENT.COD_ESTAB, ENT.COD_PRODUTO, ENT.DATA_FISCAL_S, ENT.VLR_BASE_ICMS, ENT.VLR_ICMS_UNIT, ENT.VLR_BASE_ICMS_ST, ';
                v_sql :=
                       v_sql
                    || '          ENT.VLR_ICMS_ST_UNIT, ENT.VLR_BASE_ICMSST_RET, ENT.VLR_ICMSST_RET_UNIT, ENT.ALIQ_INTERNA, ';
                v_sql := v_sql || '          ENT.VLR_BASE_ICMS_ST_XML, ENT.VLR_PCT_MVA, ENT.NUM_AUTENTIC_NFE, ';
                v_sql := v_sql || '          ENT.DATA_FISCAL, ENT.ALIQ_ICMS, ENT.CFOP_FORN, MOV.ROWID ';
                v_sql := v_sql || '   BULK COLLECT INTO TAB_E ';
                v_sql := v_sql || '   FROM MSAFI.' || p_tab_retorno || ' ENT, ';
                v_sql := v_sql || '        MSAFI.' || v_tab_mov || ' MOV ';
                v_sql := v_sql || '   WHERE MOV.COD_FILIAL       = ''' || v_cod_estab || ''' ';
                v_sql := v_sql || '     AND MOV.COD_PART         = ''DSP910'' ';
                v_sql := v_sql || '     AND MOV.COD_PART         NOT IN (''DSP291'',''DSP963'') '; --Regra para lojas inativas
                v_sql := v_sql || '     AND MOV.PERIODO          = ' || TO_CHAR ( pdt_periodo ) || ' ';
                v_sql := v_sql || '     AND MOV.MOVTO_E_S       <> ''9'' '; --APENAS ENTRADAS NAS FILIAIS
                v_sql := v_sql || '     AND MOV.COD_PART         = ENT.COD_ESTAB ';
                v_sql := v_sql || '     AND MOV.COD_ITEM         = ENT.COD_PRODUTO ';
                v_sql := v_sql || '     AND MOV.DATA             = ENT.DATA_FISCAL_S ';
                v_sql := v_sql || '     AND MOV.VLR_BASE_ICMS    = 0 '; --SE NAO ENCONTRAR IMPOSTOS NA NF, OBTER ULTIMA ENTRADA DO PRODUTO
                v_sql := v_sql || '     AND MOV.VLR_ICMS         = 0 ';
                v_sql := v_sql || '     AND MOV.VLR_BASE_ICMS_ST = 0 ';
                v_sql := v_sql || '     AND MOV.VLR_ICMS_ST      = 0; ';
                v_sql :=
                    v_sql || ' DBMS_APPLICATION_INFO.SET_MODULE(''' || vg_module || ''', ''F4 UPD IMPOSTOS DSP910''); ';
                v_sql := v_sql || ' FORALL I IN TAB_E.FIRST .. TAB_E.LAST ';
                v_sql := v_sql || '   UPDATE MSAFI.' || v_tab_mov || ' ';
                v_sql := v_sql || '   SET VLR_BASE_ICMS        = TAB_E(I).VLR_BASE_ICMS*QTDE, ';
                v_sql := v_sql || '       VLR_ICMS             = TAB_E(I).VLR_ICMS_UNIT*QTDE, ';
                v_sql := v_sql || '       VLR_BASE_ICMS_ST     = TAB_E(I).VLR_BASE_ICMS_ST*QTDE, ';
                v_sql := v_sql || '       VLR_ICMS_ST          = TAB_E(I).VLR_ICMS_ST_UNIT*QTDE, ';
                v_sql := v_sql || '       VLR_BASE_ICMSST_RET  = TAB_E(I).VLR_BASE_ICMSST_RET*QTDE, ';
                v_sql := v_sql || '       VLR_ICMSST_RET_UNIT  = TAB_E(I).VLR_ICMSST_RET_UNIT*QTDE, ';
                v_sql := v_sql || '       ALIQ_INTERNA         = TAB_E(I).ALIQ_INTERNA, ';
                v_sql := v_sql || '       VLR_BASE_ICMS_ST_XML = TAB_E(I).VLR_BASE_ICMS_ST_XML*QTDE, ';
                v_sql := v_sql || '       VLR_PCT_MVA          = TAB_E(I).VLR_PCT_MVA, ';
                v_sql := v_sql || '       CHAVE_ACESSO_REF     = TAB_E(I).NUM_AUTENTIC_NFE, ';
                v_sql := v_sql || '       DATA_FISCAL_REF      = TAB_E(I).DATA_FISCAL, ';
                v_sql := v_sql || '       ALIQ_ICMS            = TAB_E(I).ALIQ_ICMS, ';
                v_sql := v_sql || '       CFOP_FORN            = TAB_E(I).CFOP_FORN, ';
                v_sql := v_sql || '       ORIGEM_ICMS          = ''C'', ';
                v_sql := v_sql || '       TAX_CONTROLE         = ''D'' ';
                v_sql := v_sql || '   WHERE ROWID = TAB_E(I).ROW_ID; ';
                v_sql := v_sql || ' COMMIT; ';
                v_sql := v_sql || ' END; ';

                EXECUTE IMMEDIATE v_sql;

                -- DSP901 ---------------------------------------------------------------------------------------------------
                dbms_application_info.set_module ( vg_module
                                                 , 'F4 SEL IMPOSTOS DSP901' );
                v_sql := 'DECLARE TYPE T_TAB_ENTRADA IS RECORD ( ';
                v_sql := v_sql || '           COD_ESTAB VARCHAR2(8), ';
                v_sql := v_sql || '           COD_PRODUTO VARCHAR2(16), ';
                v_sql := v_sql || '           DATA_FISCAL_S DATE, ';
                v_sql := v_sql || '           VLR_BASE_ICMS NUMBER(15,4), ';
                v_sql := v_sql || '           VLR_ICMS_UNIT NUMBER(15,4), ';
                v_sql := v_sql || '           VLR_BASE_ICMS_ST NUMBER(15,4), ';
                v_sql := v_sql || '           VLR_ICMS_ST_UNIT NUMBER(15,4), ';
                v_sql := v_sql || '           VLR_BASE_ICMSST_RET NUMBER(15,4), ';
                v_sql := v_sql || '           VLR_ICMSST_RET_UNIT NUMBER(15,4), ';
                v_sql := v_sql || '           ALIQ_INTERNA VARCHAR2(6), ';
                v_sql := v_sql || '           VLR_BASE_ICMS_ST_XML NUMBER(15,4), ';
                v_sql := v_sql || '           VLR_PCT_MVA NUMBER(5,2), ';
                v_sql := v_sql || '           NUM_AUTENTIC_NFE VARCHAR2(80), ';
                v_sql := v_sql || '           DATA_FISCAL DATE, ';
                v_sql := v_sql || '           ALIQ_ICMS NUMBER, ';
                v_sql := v_sql || '           CFOP_FORN VARCHAR2(6), ';
                v_sql := v_sql || '           ROW_ID VARCHAR2(30)); ';
                v_sql := v_sql || '        TYPE T_TAB_E IS TABLE OF T_TAB_ENTRADA; ';
                v_sql := v_sql || '        TAB_E T_TAB_E; ';
                v_sql := v_sql || 'BEGIN ';
                v_sql :=
                       v_sql
                    || '   SELECT ENT.COD_ESTAB, ENT.COD_PRODUTO, ENT.DATA_FISCAL_S, ENT.VLR_BASE_ICMS, ENT.VLR_ICMS_UNIT, ENT.VLR_BASE_ICMS_ST, ';
                v_sql :=
                       v_sql
                    || '          ENT.VLR_ICMS_ST_UNIT, ENT.VLR_BASE_ICMSST_RET, ENT.VLR_ICMSST_RET_UNIT, ENT.ALIQ_INTERNA, ';
                v_sql := v_sql || '          ENT.VLR_BASE_ICMS_ST_XML, ENT.VLR_PCT_MVA, ENT.NUM_AUTENTIC_NFE, ';
                v_sql := v_sql || '          ENT.DATA_FISCAL, ENT.ALIQ_ICMS, ENT.CFOP_FORN, MOV.ROWID ';
                v_sql := v_sql || '   BULK COLLECT INTO TAB_E ';
                v_sql := v_sql || '   FROM MSAFI.' || p_tab_retorno || ' ENT, ';
                v_sql := v_sql || '        MSAFI.' || v_tab_mov || ' MOV ';
                v_sql := v_sql || '   WHERE MOV.COD_FILIAL       = ''' || v_cod_estab || ''' ';
                v_sql := v_sql || '     AND MOV.COD_PART         = ''DSP901'' ';
                v_sql := v_sql || '     AND MOV.COD_PART         NOT IN (''DSP291'',''DSP963'') '; --Regra para lojas inativas
                v_sql := v_sql || '     AND MOV.PERIODO          = ' || TO_CHAR ( pdt_periodo ) || ' ';
                v_sql := v_sql || '     AND MOV.MOVTO_E_S       <> ''9'' '; --APENAS ENTRADAS NAS FILIAIS
                v_sql := v_sql || '     AND MOV.COD_PART         = ENT.COD_ESTAB ';
                v_sql := v_sql || '     AND MOV.COD_ITEM         = ENT.COD_PRODUTO ';
                v_sql := v_sql || '     AND MOV.DATA             = ENT.DATA_FISCAL_S ';
                v_sql := v_sql || '     AND MOV.VLR_BASE_ICMS    = 0 '; --SE NAO ENCONTRAR IMPOSTOS NA NF, OBTER ULTIMA ENTRADA DO PRODUTO
                v_sql := v_sql || '     AND MOV.VLR_ICMS         = 0 ';
                v_sql := v_sql || '     AND MOV.VLR_BASE_ICMS_ST = 0 ';
                v_sql := v_sql || '     AND MOV.VLR_ICMS_ST      = 0; ';
                v_sql :=
                    v_sql || ' DBMS_APPLICATION_INFO.SET_MODULE(''' || vg_module || ''', ''F4 UPD IMPOSTOS DSP901''); ';
                v_sql := v_sql || ' FORALL I IN TAB_E.FIRST .. TAB_E.LAST ';
                v_sql := v_sql || '   UPDATE MSAFI.' || v_tab_mov || ' ';
                v_sql := v_sql || '   SET VLR_BASE_ICMS        = TAB_E(I).VLR_BASE_ICMS*QTDE, ';
                v_sql := v_sql || '       VLR_ICMS             = TAB_E(I).VLR_ICMS_UNIT*QTDE, ';
                v_sql := v_sql || '       VLR_BASE_ICMS_ST     = TAB_E(I).VLR_BASE_ICMS_ST*QTDE, ';
                v_sql := v_sql || '       VLR_ICMS_ST          = TAB_E(I).VLR_ICMS_ST_UNIT*QTDE, ';
                v_sql := v_sql || '       VLR_BASE_ICMSST_RET  = TAB_E(I).VLR_BASE_ICMSST_RET*QTDE, ';
                v_sql := v_sql || '       VLR_ICMSST_RET_UNIT  = TAB_E(I).VLR_ICMSST_RET_UNIT*QTDE, ';
                v_sql := v_sql || '       ALIQ_INTERNA         = TAB_E(I).ALIQ_INTERNA, ';
                v_sql := v_sql || '       VLR_BASE_ICMS_ST_XML = TAB_E(I).VLR_BASE_ICMS_ST_XML*QTDE, ';
                v_sql := v_sql || '       VLR_PCT_MVA          = TAB_E(I).VLR_PCT_MVA, ';
                v_sql := v_sql || '       CHAVE_ACESSO_REF     = TAB_E(I).NUM_AUTENTIC_NFE, ';
                v_sql := v_sql || '       DATA_FISCAL_REF      = TAB_E(I).DATA_FISCAL, ';
                v_sql := v_sql || '       ALIQ_ICMS            = TAB_E(I).ALIQ_ICMS, ';
                v_sql := v_sql || '       CFOP_FORN            = TAB_E(I).CFOP_FORN, ';
                v_sql := v_sql || '       ORIGEM_ICMS          = ''C'', ';
                v_sql := v_sql || '       TAX_CONTROLE         = ''D'' ';
                v_sql := v_sql || '   WHERE ROWID = TAB_E(I).ROW_ID; ';
                v_sql := v_sql || ' COMMIT; ';
                v_sql := v_sql || ' END; ';

                EXECUTE IMMEDIATE v_sql;

                -- DSP902 ---------------------------------------------------------------------------------------------------
                dbms_application_info.set_module ( vg_module
                                                 , 'F4 SEL IMPOSTOS DSP902' );
                v_sql := 'DECLARE TYPE T_TAB_ENTRADA IS RECORD ( ';
                v_sql := v_sql || '           COD_ESTAB VARCHAR2(8), ';
                v_sql := v_sql || '           COD_PRODUTO VARCHAR2(16), ';
                v_sql := v_sql || '           DATA_FISCAL_S DATE, ';
                v_sql := v_sql || '           VLR_BASE_ICMS NUMBER(15,4), ';
                v_sql := v_sql || '           VLR_ICMS_UNIT NUMBER(15,4), ';
                v_sql := v_sql || '           VLR_BASE_ICMS_ST NUMBER(15,4), ';
                v_sql := v_sql || '           VLR_ICMS_ST_UNIT NUMBER(15,4), ';
                v_sql := v_sql || '           VLR_BASE_ICMSST_RET NUMBER(15,4), ';
                v_sql := v_sql || '           VLR_ICMSST_RET_UNIT NUMBER(15,4), ';
                v_sql := v_sql || '           ALIQ_INTERNA VARCHAR2(6), ';
                v_sql := v_sql || '           VLR_BASE_ICMS_ST_XML NUMBER(15,4), ';
                v_sql := v_sql || '           VLR_PCT_MVA NUMBER(5,2), ';
                v_sql := v_sql || '           NUM_AUTENTIC_NFE VARCHAR2(80), ';
                v_sql := v_sql || '           DATA_FISCAL DATE, ';
                v_sql := v_sql || '           ALIQ_ICMS NUMBER, ';
                v_sql := v_sql || '           CFOP_FORN VARCHAR2(6), ';
                v_sql := v_sql || '           ROW_ID VARCHAR2(30)); ';
                v_sql := v_sql || '        TYPE T_TAB_E IS TABLE OF T_TAB_ENTRADA; ';
                v_sql := v_sql || '        TAB_E T_TAB_E; ';
                v_sql := v_sql || 'BEGIN ';
                v_sql :=
                       v_sql
                    || '   SELECT ENT.COD_ESTAB, ENT.COD_PRODUTO, ENT.DATA_FISCAL_S, ENT.VLR_BASE_ICMS, ENT.VLR_ICMS_UNIT, ENT.VLR_BASE_ICMS_ST, ';
                v_sql :=
                       v_sql
                    || '          ENT.VLR_ICMS_ST_UNIT, ENT.VLR_BASE_ICMSST_RET, ENT.VLR_ICMSST_RET_UNIT, ENT.ALIQ_INTERNA, ';
                v_sql := v_sql || '          ENT.VLR_BASE_ICMS_ST_XML, ENT.VLR_PCT_MVA, ENT.NUM_AUTENTIC_NFE, ';
                v_sql := v_sql || '          ENT.DATA_FISCAL, ENT.ALIQ_ICMS, ENT.CFOP_FORN, MOV.ROWID ';
                v_sql := v_sql || '   BULK COLLECT INTO TAB_E ';
                v_sql := v_sql || '   FROM MSAFI.' || p_tab_retorno || ' ENT, ';
                v_sql := v_sql || '        MSAFI.' || v_tab_mov || ' MOV ';
                v_sql := v_sql || '   WHERE MOV.COD_FILIAL       = ''' || v_cod_estab || ''' ';
                v_sql := v_sql || '     AND MOV.COD_PART         = ''DSP902'' ';
                v_sql := v_sql || '     AND MOV.COD_PART         NOT IN (''DSP291'',''DSP963'') '; --Regra para lojas inativas
                v_sql := v_sql || '     AND MOV.PERIODO          = ' || TO_CHAR ( pdt_periodo ) || ' ';
                v_sql := v_sql || '     AND MOV.MOVTO_E_S       <> ''9'' '; --APENAS ENTRADAS NAS FILIAIS
                v_sql := v_sql || '     AND MOV.COD_PART         = ENT.COD_ESTAB ';
                v_sql := v_sql || '     AND MOV.COD_ITEM         = ENT.COD_PRODUTO ';
                v_sql := v_sql || '     AND MOV.DATA             = ENT.DATA_FISCAL_S ';
                v_sql := v_sql || '     AND MOV.VLR_BASE_ICMS    = 0 '; --SE NAO ENCONTRAR IMPOSTOS NA NF, OBTER ULTIMA ENTRADA DO PRODUTO
                v_sql := v_sql || '     AND MOV.VLR_ICMS         = 0 ';
                v_sql := v_sql || '     AND MOV.VLR_BASE_ICMS_ST = 0 ';
                v_sql := v_sql || '     AND MOV.VLR_ICMS_ST      = 0; ';
                v_sql :=
                    v_sql || ' DBMS_APPLICATION_INFO.SET_MODULE(''' || vg_module || ''', ''F4 UPD IMPOSTOS DSP902''); ';
                v_sql := v_sql || ' FORALL I IN TAB_E.FIRST .. TAB_E.LAST ';
                v_sql := v_sql || '   UPDATE MSAFI.' || v_tab_mov || ' ';
                v_sql := v_sql || '   SET VLR_BASE_ICMS        = TAB_E(I).VLR_BASE_ICMS*QTDE, ';
                v_sql := v_sql || '       VLR_ICMS             = TAB_E(I).VLR_ICMS_UNIT*QTDE, ';
                v_sql := v_sql || '       VLR_BASE_ICMS_ST     = TAB_E(I).VLR_BASE_ICMS_ST*QTDE, ';
                v_sql := v_sql || '       VLR_ICMS_ST          = TAB_E(I).VLR_ICMS_ST_UNIT*QTDE, ';
                v_sql := v_sql || '       VLR_BASE_ICMSST_RET  = TAB_E(I).VLR_BASE_ICMSST_RET*QTDE, ';
                v_sql := v_sql || '       VLR_ICMSST_RET_UNIT  = TAB_E(I).VLR_ICMSST_RET_UNIT*QTDE, ';
                v_sql := v_sql || '       ALIQ_INTERNA         = TAB_E(I).ALIQ_INTERNA, ';
                v_sql := v_sql || '       VLR_BASE_ICMS_ST_XML = TAB_E(I).VLR_BASE_ICMS_ST_XML*QTDE, ';
                v_sql := v_sql || '       VLR_PCT_MVA          = TAB_E(I).VLR_PCT_MVA, ';
                v_sql := v_sql || '       CHAVE_ACESSO_REF     = TAB_E(I).NUM_AUTENTIC_NFE, ';
                v_sql := v_sql || '       DATA_FISCAL_REF      = TAB_E(I).DATA_FISCAL, ';
                v_sql := v_sql || '       ALIQ_ICMS            = TAB_E(I).ALIQ_ICMS, ';
                v_sql := v_sql || '       CFOP_FORN            = TAB_E(I).CFOP_FORN, ';
                v_sql := v_sql || '       ORIGEM_ICMS          = ''C'', ';
                v_sql := v_sql || '       TAX_CONTROLE         = ''D'' ';
                v_sql := v_sql || '   WHERE ROWID = TAB_E(I).ROW_ID; ';
                v_sql := v_sql || ' COMMIT; ';
                v_sql := v_sql || ' END; ';

                EXECUTE IMMEDIATE v_sql;

                --

                -- LOJAS ---------------------------------------------------------------------------------------------------
                dbms_application_info.set_module ( vg_module
                                                 , 'F4 SEL IMPOSTOS LOJAS' );
                v_sql := 'DECLARE TYPE T_TAB_ENTRADA IS RECORD ( ';
                v_sql := v_sql || '           COD_ESTAB VARCHAR2(8), ';
                v_sql := v_sql || '           COD_PRODUTO VARCHAR2(16), ';
                v_sql := v_sql || '           DATA_FISCAL_S DATE, ';
                v_sql := v_sql || '           VLR_BASE_ICMS NUMBER(15,4), ';
                v_sql := v_sql || '           VLR_ICMS_UNIT NUMBER(15,4), ';
                v_sql := v_sql || '           VLR_BASE_ICMS_ST NUMBER(15,4), ';
                v_sql := v_sql || '           VLR_ICMS_ST_UNIT NUMBER(15,4), ';
                v_sql := v_sql || '           VLR_BASE_ICMSST_RET NUMBER(15,4), ';
                v_sql := v_sql || '           VLR_ICMSST_RET_UNIT NUMBER(15,4), ';
                v_sql := v_sql || '           ALIQ_INTERNA VARCHAR2(6), ';
                v_sql := v_sql || '           VLR_BASE_ICMS_ST_XML NUMBER(15,4), ';
                v_sql := v_sql || '           VLR_PCT_MVA NUMBER(5,2), ';
                v_sql := v_sql || '           NUM_AUTENTIC_NFE VARCHAR2(80), ';
                v_sql := v_sql || '           DATA_FISCAL DATE, ';
                v_sql := v_sql || '           ALIQ_ICMS NUMBER, ';
                v_sql := v_sql || '           CFOP_FORN VARCHAR2(6), ';
                v_sql := v_sql || '           ROW_ID VARCHAR2(30)); ';
                v_sql := v_sql || '        TYPE T_TAB_E IS TABLE OF T_TAB_ENTRADA; ';
                v_sql := v_sql || '        TAB_E T_TAB_E; ';
                v_sql := v_sql || 'BEGIN ';
                v_sql :=
                       v_sql
                    || '   SELECT ENT.COD_ESTAB, ENT.COD_PRODUTO, ENT.DATA_FISCAL_S, ENT.VLR_BASE_ICMS, ENT.VLR_ICMS_UNIT, ENT.VLR_BASE_ICMS_ST, ';
                v_sql :=
                       v_sql
                    || '          ENT.VLR_ICMS_ST_UNIT, ENT.VLR_BASE_ICMSST_RET, ENT.VLR_ICMSST_RET_UNIT, ENT.ALIQ_INTERNA, ';
                v_sql := v_sql || '          ENT.VLR_BASE_ICMS_ST_XML, ENT.VLR_PCT_MVA, ENT.NUM_AUTENTIC_NFE, ';
                v_sql := v_sql || '          ENT.DATA_FISCAL, ENT.ALIQ_ICMS, ENT.CFOP_FORN, MOV.ROWID ';
                v_sql := v_sql || '   BULK COLLECT INTO TAB_E ';
                v_sql := v_sql || '   FROM MSAFI.' || p_tab_retorno || ' ENT, ';
                v_sql := v_sql || '        MSAFI.' || v_tab_mov || ' MOV ';
                v_sql := v_sql || '   WHERE MOV.COD_FILIAL  = ''' || v_cod_estab || ''' ';
                v_sql := v_sql || '     AND MOV.PERIODO     = ' || TO_CHAR ( pdt_periodo ) || ' ';
                v_sql :=
                       v_sql
                    || '     AND MOV.COD_PART   IN (SELECT COD_ESTAB FROM MSAFI.DSP_ESTABELECIMENTO WHERE COD_EMPRESA = MSAFI.DPSP.EMPRESA AND TIPO = ''L'' AND COD_ESTADO = ''SP'') ';
                --V_SQL := V_SQL || '     AND MOV.COD_PART = ''DSP004'') ';
                v_sql := v_sql || '     AND MOV.MOVTO_E_S  <> ''9'' '; --APENAS ENTRADAS NAS LOJAS COM ORIGEM LOJAS
                v_sql := v_sql || '     AND MOV.COD_ITEM    = ENT.COD_PRODUTO ';
                v_sql := v_sql || '     AND MOV.COD_PART    NOT IN (''DSP291'',''DSP963'') ';
                v_sql := v_sql || '     AND MOV.DATA        = ENT.DATA_FISCAL_S ';
                v_sql := v_sql || '     AND MOV.VLR_ICMS    = 0 '; --SE NAO ENCONTRAR IMPOSTOS NA NF, OBTER ULTIMA ENTRADA DO PRODUTO
                v_sql := v_sql || '     AND MOV.VLR_ICMS_ST = 0; ';
                v_sql :=
                    v_sql || ' DBMS_APPLICATION_INFO.SET_MODULE(''' || vg_module || ''', ''F4 UPD IMPOSTOS LOJAS''); ';
                v_sql := v_sql || ' FORALL I IN TAB_E.FIRST .. TAB_E.LAST ';
                v_sql := v_sql || '   UPDATE MSAFI.' || v_tab_mov || ' ';
                v_sql := v_sql || '   SET VLR_BASE_ICMS        = TAB_E(I).VLR_BASE_ICMS*QTDE, ';
                v_sql := v_sql || '       VLR_ICMS             = TAB_E(I).VLR_ICMS_UNIT*QTDE, ';
                v_sql :=
                       v_sql
                    || '       VLR_BASE_ICMS_ST     = DECODE(TAB_E(I).VLR_BASE_ICMS_ST, 0, TAB_E(I).VLR_BASE_ICMSST_RET, TAB_E(I).VLR_BASE_ICMS_ST)*QTDE, ';
                v_sql :=
                       v_sql
                    || '       VLR_ICMS_ST          = DECODE(TAB_E(I).VLR_ICMS_ST_UNIT, 0, TAB_E(I).VLR_ICMSST_RET_UNIT, TAB_E(I).VLR_ICMS_ST_UNIT)*QTDE, ';
                v_sql := v_sql || '       VLR_BASE_ICMSST_RET  = TAB_E(I).VLR_BASE_ICMSST_RET*QTDE, ';
                v_sql := v_sql || '       VLR_ICMSST_RET_UNIT  = TAB_E(I).VLR_ICMSST_RET_UNIT*QTDE,';
                v_sql := v_sql || '       ALIQ_INTERNA         = TAB_E(I).ALIQ_INTERNA, ';
                v_sql := v_sql || '       VLR_BASE_ICMS_ST_XML = TAB_E(I).VLR_BASE_ICMS_ST_XML*QTDE, ';
                v_sql := v_sql || '       VLR_PCT_MVA          = TAB_E(I).VLR_PCT_MVA, ';
                v_sql := v_sql || '       ORIGEM_ICMS          = ''C'', ';
                v_sql := v_sql || '       CHAVE_ACESSO_REF     = TAB_E(I).NUM_AUTENTIC_NFE, ';
                v_sql := v_sql || '       DATA_FISCAL_REF      = TAB_E(I).DATA_FISCAL, ';
                v_sql := v_sql || '       ALIQ_ICMS            = TAB_E(I).ALIQ_ICMS, ';
                v_sql := v_sql || '       CFOP_FORN            = TAB_E(I).CFOP_FORN, ';
                v_sql := v_sql || '       TAX_CONTROLE         = ''E'' ';
                v_sql := v_sql || '   WHERE ROWID = TAB_E(I).ROW_ID; ';
                v_sql := v_sql || ' COMMIT; ';
                v_sql := v_sql || 'END; ';

                EXECUTE IMMEDIATE v_sql;

                EXECUTE IMMEDIATE
                    'UPDATE ' || p_tab_partition || ' SET STATUS = ''F'' WHERE ROW_INI = :1 AND ROW_END = :2'
                    USING p_part_ini
                        , p_part_fim;

                COMMIT;
            ELSE
                --PARA CDs
                dbms_application_info.set_module ( vg_module
                                                 , 'F4 UPD IMPOSTOS CD' );

                v_sql := 'DECLARE TYPE T_TAB_ENTRADA IS RECORD ( ';
                v_sql := v_sql || '           COD_PRODUTO VARCHAR2(16), ';
                v_sql := v_sql || '           DATA_FISCAL_S DATE, ';
                v_sql := v_sql || '           VLR_BASE_ICMS NUMBER(15,4), ';
                v_sql := v_sql || '           VLR_ICMS_UNIT NUMBER(15,4), ';
                v_sql := v_sql || '           VLR_BASE_ICMS_ST NUMBER(15,4), ';
                v_sql := v_sql || '           VLR_ICMS_ST_UNIT NUMBER(15,4), ';
                v_sql := v_sql || '           VLR_BASE_ICMSST_RET NUMBER(15,4), ';
                v_sql := v_sql || '           VLR_ICMSST_RET_UNIT NUMBER(15,4), ';
                v_sql := v_sql || '           ALIQ_INTERNA VARCHAR2(6), ';
                v_sql := v_sql || '           VLR_BASE_ICMS_ST_XML NUMBER(15,4), ';
                v_sql := v_sql || '           VLR_PCT_MVA NUMBER(5,2), ';
                v_sql := v_sql || '           NUM_AUTENTIC_NFE VARCHAR2(80), ';
                v_sql := v_sql || '           DATA_FISCAL DATE, ';
                v_sql := v_sql || '           ALIQ_ICMS NUMBER, ';
                v_sql := v_sql || '           QUANTIDADE NUMBER(12,4), ';
                v_sql := v_sql || '           CFOP_FORN VARCHAR2(6), ';
                v_sql := v_sql || '           NUM_ITEM INTEGER); ';
                v_sql := v_sql || '        TYPE T_TAB_E IS TABLE OF T_TAB_ENTRADA; ';
                v_sql := v_sql || '        TAB_E T_TAB_E; ';
                v_sql := v_sql || 'BEGIN ';
                v_sql :=
                    v_sql || '   SELECT COD_PRODUTO, DATA_FISCAL_S, VLR_BASE_ICMS, VLR_ICMS_UNIT, VLR_BASE_ICMS_ST, ';
                v_sql :=
                    v_sql || '          VLR_ICMS_ST_UNIT, VLR_BASE_ICMSST_RET, VLR_ICMSST_RET_UNIT, ALIQ_INTERNA, ';
                v_sql :=
                       v_sql
                    || '          VLR_BASE_ICMS_ST_XML, VLR_PCT_MVA, NUM_AUTENTIC_NFE, DATA_FISCAL, ALIQ_ICMS, QUANTIDADE, CFOP_FORN, ';
                v_sql := v_sql || '          NUM_ITEM ';
                v_sql := v_sql || '   BULK COLLECT INTO TAB_E ';
                v_sql := v_sql || '   FROM MSAFI.' || p_tab_retorno || '; ';
                --
                v_sql := v_sql || ' FORALL I IN TAB_E.FIRST .. TAB_E.LAST ';
                v_sql := v_sql || '   UPDATE MSAFI.' || v_tab_mov || ' ';
                v_sql := v_sql || '   SET VLR_BASE_ICMS       = TRUNC(TAB_E(I).VLR_BASE_ICMS*TAB_E(I).QUANTIDADE,2), ';
                v_sql := v_sql || '       VLR_ICMS            = TRUNC(TAB_E(I).VLR_ICMS_UNIT*TAB_E(I).QUANTIDADE,2), ';
                v_sql :=
                    v_sql || '       VLR_BASE_ICMS_ST    = TRUNC(TAB_E(I).VLR_BASE_ICMS_ST*TAB_E(I).QUANTIDADE,2), ';
                v_sql :=
                    v_sql || '       VLR_ICMS_ST         = TRUNC(TAB_E(I).VLR_ICMS_ST_UNIT*TAB_E(I).QUANTIDADE,2), ';
                v_sql :=
                    v_sql || '       VLR_BASE_ICMSST_RET = TRUNC(TAB_E(I).VLR_BASE_ICMSST_RET*TAB_E(I).QUANTIDADE,2), ';
                v_sql :=
                    v_sql || '       VLR_ICMSST_RET_UNIT = TRUNC(TAB_E(I).VLR_ICMSST_RET_UNIT*TAB_E(I).QUANTIDADE,2),';
                v_sql := v_sql || '       ALIQ_INTERNA        = TAB_E(I).ALIQ_INTERNA, ';
                v_sql :=
                       v_sql
                    || '       VLR_BASE_ICMS_ST_XML = TRUNC(TAB_E(I).VLR_BASE_ICMS_ST_XML*TAB_E(I).QUANTIDADE,2), ';
                v_sql := v_sql || '       VLR_PCT_MVA          = TAB_E(I).VLR_PCT_MVA, ';
                v_sql := v_sql || '       ALIQ_ICMS            = TAB_E(I).ALIQ_ICMS, ';
                v_sql := v_sql || '       CFOP_FORN            = TAB_E(I).CFOP_FORN, ';
                v_sql := v_sql || '       ORIGEM_ICMS          = ''F'', ';
                v_sql := v_sql || '       TAX_CONTROLE         = ''F'' ';
                v_sql := v_sql || '   WHERE COD_ITEM    = TAB_E(I).COD_PRODUTO ';
                v_sql := v_sql || '     AND DATA        = TAB_E(I).DATA_FISCAL_S ';
                v_sql := v_sql || '     AND CHV_DOC     = TAB_E(I).NUM_AUTENTIC_NFE ';
                v_sql := v_sql || '     AND NUM_ITEM    = TAB_E(I).NUM_ITEM ';
                v_sql :=
                       v_sql
                    || '     AND DATA        BETWEEN TO_DATE('''
                    || TO_CHAR ( pdt_ini
                               , 'DDMMYYYY' )
                    || ''',''DDMMYYYY'') AND TO_DATE('''
                    || TO_CHAR ( pdt_fim
                               , 'DDMMYYYY' )
                    || ''',''DDMMYYYY'') ';
                v_sql := v_sql || '     AND COD_FILIAL  = ''' || v_cod_estab || ''' ';
                v_sql := v_sql || '     AND PERIODO     = ' || TO_CHAR ( pdt_periodo ) || ' ';
                --V_SQL := V_SQL || '     AND COD_PART  NOT LIKE ''D%'' '; --APENAS FORNECEDORES
                v_sql := v_sql || '     AND MOVTO_E_S  <> ''9''; '; --APENAS ENTRADAS NOS CDs
                v_sql := v_sql || 'COMMIT; ';
                --
                v_sql := v_sql || 'END; ';

                EXECUTE IMMEDIATE v_sql;
            END IF; --IF (V_TIPO = 'L') THEN --APENAS PARA LOJAS

            EXECUTE IMMEDIATE 'UPDATE ' || p_tab_partition || ' SET STATUS = ''G'' WHERE ROW_INI = :1 AND ROW_END = :2'
                USING p_part_ini
                    , p_part_fim;

            COMMIT;

            dbms_application_info.set_module ( vg_module
                                             , 'F4 UPD CLASS ANVISA' );

            v_sql := 'UPDATE MSAFI.' || v_tab_mov || ' A ';
            v_sql := v_sql || 'SET A.CLASS_ANVISA = (SELECT B.CLASS_ANVISA ';
            v_sql := v_sql || '                      FROM ' || v_tab_anvisa || ' B ';
            v_sql := v_sql || '                      WHERE B.COD_PRODUTO = A.COD_ITEM) ';
            v_sql := v_sql || 'WHERE A.COD_FILIAL = ''' || v_cod_estab || ''' ';
            v_sql := v_sql || '  AND A.PERIODO    = ' || TO_CHAR ( pdt_periodo ) || ' ';

            EXECUTE IMMEDIATE v_sql;

            COMMIT;

            dbms_application_info.set_module ( vg_module
                                             , 'F4 UPD ALIQ INTERNA' );

            v_sql := 'UPDATE MSAFI.' || v_tab_mov || ' A ';
            v_sql := v_sql || 'SET A.ALIQ_INTERNA = (SELECT B.ALIQ_INTERNA ';
            v_sql := v_sql || '                      FROM MSAFI.' || p_tab_aliq || ' B ';
            v_sql := v_sql || '                      WHERE B.COD_PRODUTO = A.COD_ITEM ';
            v_sql := v_sql || '                        AND B.DATA_FISCAL = A.DATA) ';
            v_sql := v_sql || 'WHERE A.COD_FILIAL = ''' || v_cod_estab || ''' ';
            v_sql := v_sql || '  AND A.PERIODO    = ' || TO_CHAR ( pdt_periodo ) || ' ';
            v_sql := v_sql || '  AND (A.ALIQ_INTERNA IS NULL OR A.ALIQ_INTERNA = ''0'') ';

            EXECUTE IMMEDIATE v_sql;

            COMMIT;

            dbms_application_info.set_module ( vg_module
                                             , 'F4 GET VLR PMC' );
            v_sql := 'DECLARE TYPE T_TAB_PMC IS RECORD ( ';
            v_sql := v_sql || '                            COD_PRODUTO VARCHAR2(30), ';
            v_sql := v_sql || '                            DATA_FISCAL DATE, ';
            v_sql := v_sql || '                            VLR_PMC     NUMBER(15,4), ';
            v_sql := v_sql || '                            DSP_ALIQ_ICMS_ID VARCHAR2(4), ';
            v_sql := v_sql || '                            ROW_ID      VARCHAR2(40)); ';
            v_sql := v_sql || '  TYPE TT_TAB_PMC IS TABLE OF T_TAB_PMC; ';
            v_sql := v_sql || '  TAB_PMC TT_TAB_PMC; ';
            v_sql := v_sql || 'BEGIN ';
            v_sql :=
                   v_sql
                || 'SELECT PS.COD_PRODUTO, PS.DATA_FISCAL, PS.DSP_PMC AS VLR_PMC, PS.DSP_ALIQ_ICMS_ID, MOV.ROWID AS ROW_ID ';
            v_sql := v_sql || 'BULK COLLECT INTO TAB_PMC ';
            v_sql := v_sql || 'FROM (  ';
            v_sql := v_sql || '      WITH TAB_TMP AS ( ';
            v_sql := v_sql || '                        SELECT * FROM MSAFI.' || p_tab_aliq || ' ';
            v_sql := v_sql || '                      ) ';
            v_sql := v_sql || '      SELECT A.SETID, A.INV_ITEM_ID AS COD_PRODUTO, A.DSP_ALIQ_ICMS_ID, ';
            v_sql := v_sql || '          A.UNIT_OF_MEASURE, A.EFFDT, A.DSP_PMC, P.DATA_FISCAL, ';
            v_sql :=
                   v_sql
                || '          RANK() OVER( PARTITION BY A.SETID, A.INV_ITEM_ID, A.DSP_ALIQ_ICMS_ID, A.UNIT_OF_MEASURE  ';
            v_sql := v_sql || '                      ORDER BY A.EFFDT DESC) RANK  ';
            v_sql := v_sql || '      FROM MSAFI.PS_DSP_PRECO_ITEM A, ';
            v_sql := v_sql || '           TAB_TMP P ';
            v_sql := v_sql || '      WHERE A.SETID            = ''GERAL''  ';
            v_sql := v_sql || '        AND A.UNIT_OF_MEASURE  = ''UN''  ';
            v_sql := v_sql || '        AND A.INV_ITEM_ID      = P.COD_PRODUTO ';
            v_sql := v_sql || '        AND A.DSP_ALIQ_ICMS_ID = P.ALIQ_INTERNA ';
            v_sql := v_sql || '        AND A.EFFDT           <= P.DATA_FISCAL ';
            v_sql := v_sql || '     ) PS,  ';
            v_sql := v_sql || '     MSAFI.' || v_tab_mov || ' MOV ';
            v_sql := v_sql || 'WHERE PS.RANK = 1 ';
            v_sql := v_sql || '  AND MOV.COD_ITEM     = PS.COD_PRODUTO ';
            v_sql := v_sql || '  AND MOV.DATA         = PS.DATA_FISCAL ';
            v_sql := v_sql || '  AND MOV.ALIQ_INTERNA = PS.DSP_ALIQ_ICMS_ID ';
            v_sql := v_sql || '  AND MOV.COD_FILIAL   = ''' || v_cod_estab || ''' ';
            v_sql := v_sql || '  AND MOV.PERIODO      = ' || TO_CHAR ( pdt_periodo ) || '; ';
            ---
            v_sql := v_sql || 'FORALL I IN TAB_PMC.FIRST .. TAB_PMC.LAST ';
            v_sql := v_sql || '  UPDATE MSAFI.' || v_tab_mov || ' SET VLR_PMC = TAB_PMC(I).VLR_PMC ';
            v_sql := v_sql || '  WHERE ROWID = TAB_PMC(I).ROW_ID; ';
            v_sql := v_sql || 'COMMIT; ';
            v_sql := v_sql || 'END; ';

            EXECUTE IMMEDIATE v_sql;

            EXECUTE IMMEDIATE 'UPDATE ' || p_tab_partition || ' SET STATUS = ''H'' WHERE ROW_INI = :1 AND ROW_END = :2'
                USING p_part_ini
                    , p_part_fim;

            COMMIT;

            dbms_application_info.set_module ( vg_module
                                             , 'F4 GET DESCONTO PMC' );
            v_sql := 'DECLARE TYPE T_TAB_DESC IS RECORD ( ';
            v_sql := v_sql || '                                VLR_DESC_PMC NUMBER(5,2), ';
            v_sql := v_sql || '                                LISTA VARCHAR2(1), ';
            v_sql := v_sql || '                                DSP_TP_MED VARCHAR2(8), ';
            v_sql := v_sql || '                                COD_PRODUTO VARCHAR2(30), ';
            v_sql := v_sql || '                                DATA_FISCAL DATE, ';
            v_sql := v_sql || '                                CLASS_ANVISA VARCHAR2(30), ';
            v_sql := v_sql || '                                ROW_ID VARCHAR2(30) ';
            v_sql := v_sql || '                                  ); ';
            v_sql := v_sql || 'TYPE TT_TAB_DESC IS TABLE OF T_TAB_DESC; ';
            v_sql := v_sql || 'TAB_DESC TT_TAB_DESC; ';
            v_sql := v_sql || 'BEGIN ';
            v_sql :=
                   v_sql
                || 'SELECT DISTINCT PMC.DSP_PERC_ST, PMC.CLASS_PIS_DSP, PMC.DSP_TP_MED, PMC.COD_ITEM, PMC.DATA, PMC.CLASS_ANVISA, PMC.ROW_ID ';
            v_sql := v_sql || 'BULK COLLECT INTO TAB_DESC ';
            v_sql := v_sql || 'FROM ( ';
            v_sql := v_sql || '    WITH TAB_ANVISA AS ( SELECT * FROM ' || v_tab_anvisa || ' ) ';
            v_sql :=
                   v_sql
                || '    SELECT MOV.COD_ITEM, MOV.DATA, A.DSP_PERC_ST, A.CLASS_PIS_DSP, A.DSP_TP_MED, ANV.CLASS_ANVISA, ';
            v_sql :=
                   v_sql
                || '        RANK() OVER (PARTITION BY A.SETID, A.STATE, A.CLASS_PIS_DSP, A.DSP_TP_MED ORDER BY A.EFFDT DESC) RANK, MOV.ROWID AS ROW_ID ';
            v_sql := v_sql || '    FROM MSAFI.PS_DSP_PERC_ST_TBL A, ';
            v_sql := v_sql || '         TAB_ANVISA ANV, ';
            v_sql := v_sql || '         MSAFI.' || v_tab_mov || ' MOV ';
            v_sql := v_sql || '    WHERE A.SETID = ''GERAL'' ';
            v_sql := v_sql || '      AND A.STATE = ''SP'' ';
            v_sql := v_sql || '      AND A.CLASS_PIS_DSP = MOV.LISTA  ';
            v_sql := v_sql || '      AND A.DSP_TP_MED    = ANV.DSP_TP_MED ';
            v_sql := v_sql || '      AND A.EFFDT        <= MOV.DATA ';
            v_sql := v_sql || '      AND MOV.COD_ITEM    = ANV.COD_PRODUTO ';
            v_sql := v_sql || '      AND MOV.COD_FILIAL  = ''' || v_cod_estab || ''' ';
            v_sql := v_sql || '      AND MOV.PERIODO     = ' || TO_CHAR ( pdt_periodo ) || ' ';
            v_sql := v_sql || '    ) PMC ';
            v_sql := v_sql || 'WHERE PMC.RANK = 1; ';
            v_sql := v_sql || 'FORALL I IN TAB_DESC.FIRST .. TAB_DESC.LAST ';
            v_sql := v_sql || '  UPDATE MSAFI.' || v_tab_mov || ' MOV SET VLR_DESC_PMC = TAB_DESC(I).VLR_DESC_PMC ';
            v_sql := v_sql || '  WHERE ROWID = TAB_DESC(I).ROW_ID; ';
            v_sql := v_sql || 'COMMIT; ';
            v_sql := v_sql || 'END; ';

            EXECUTE IMMEDIATE v_sql;

            EXECUTE IMMEDIATE 'UPDATE ' || p_tab_partition || ' SET STATUS = ''I'' WHERE ROW_INI = :1 AND ROW_END = :2'
                USING p_part_ini
                    , p_part_fim;

            COMMIT;

            IF ( v_tipo = 'L' ) THEN --PARA LOJAS
                dbms_application_info.set_module ( vg_module
                                                 , 'F4 ENTR VERO' );
                ult_entrada_vero ( v_cod_estab
                                 , pdt_periodo
                                 , v_tab_mov ); --apenas para ST910 + devolucoes lojas SP para ST910 ou DSP910

                EXECUTE IMMEDIATE
                    'UPDATE ' || p_tab_partition || ' SET STATUS = ''J'' WHERE ROW_INI = :1 AND ROW_END = :2'
                    USING p_part_ini
                        , p_part_fim;

                COMMIT;
                ---
                dbms_application_info.set_module ( vg_module
                                                 , 'F4 LOJA -> LOJA' );
                get_loja_loja_ult ( v_cod_estab
                                  , pdt_periodo
                                  , v_tab_mov );

                EXECUTE IMMEDIATE
                    'UPDATE ' || p_tab_partition || ' SET STATUS = ''O'' WHERE ROW_INI = :1 AND ROW_END = :2'
                    USING p_part_ini
                        , p_part_fim;

                COMMIT;
            END IF;

            dbms_application_info.set_module ( vg_module
                                             , 'F4 ENTR PSFT' );
            ult_entrada_people ( p_proc_instance
                               , v_cod_estab
                               , pdt_periodo
                               , p_tab_nfret
                               , v_tipo
                               , v_tab_nf
                               , v_tab_mov ); --BUSCA IMPOSTOS DO PSFT

            EXECUTE IMMEDIATE 'UPDATE ' || p_tab_partition || ' SET STATUS = ''K'' WHERE ROW_INI = :1 AND ROW_END = :2'
                USING p_part_ini
                    , p_part_fim;

            COMMIT;

            --CRIAR TEMP PARA INFO ANVISA
            v_tab_pmc :=
                msaf.dpsp_create_tab_tmp ( p_proc_instance
                                         , ( p_proc_instance + p_part_fim )
                                         , 'TAB_VLR_PMC'
                                         , p_user );

            IF ( v_tab_pmc = 'ERRO' ) THEN
                raise_application_error ( -20001
                                        , '!ERRO CREATE TAB PMC!' );
            ELSE
                dbms_application_info.set_module ( vg_module
                                                 , 'F4 UPD VLR PMC' );
                upd_vlr_pmc ( p_proc_instance
                            , v_cod_estab
                            , pdt_periodo
                            , v_tab_pmc
                            , v_tab_mov );
            END IF;

            ---

            -- LIMPAR MOV -------------------------------------------------------
            FOR c IN ( SELECT ROWID AS row_id
                         FROM msafi.dpsp_fin151_cat42_mov
                        WHERE cod_filial = v_cod_estab
                          AND periodo = pdt_periodo ) LOOP
                DELETE msafi.dpsp_fin151_cat42_mov
                 WHERE ROWID = c.row_id;

                dbms_application_info.set_module ( $$plsql_unit
                                                 , 'F4 LIMPEZA MOV [' || v_ttl || ']' );
                v_ttl := v_ttl + 1;
                v_commit := v_commit + 1;

                IF ( v_commit = 100 ) THEN
                    v_commit := 0;
                    COMMIT;
                END IF;
            END LOOP;

            COMMIT;

            -- LIMPAR MOV -------------------------------------------------------

            EXECUTE IMMEDIATE 'UPDATE ' || p_tab_partition || ' SET STATUS = ''L'' WHERE ROW_INI = :1 AND ROW_END = :2'
                USING p_part_ini
                    , p_part_fim;

            COMMIT;

            -- INSERT TAB MOV ---------------------------------------------------
            v_sql := 'DECLARE ';
            v_sql := v_sql || '  CURSOR C_MOV IS ';
            v_sql := v_sql || '    SELECT * ';
            v_sql := v_sql || '    FROM MSAFI.' || v_tab_mov || '; ';
            v_sql := v_sql || '  TYPE T_TAB_MOV IS TABLE OF C_MOV%ROWTYPE; ';
            v_sql := v_sql || '  TAB_MOV T_TAB_MOV; ';
            v_sql := v_sql || '  V_COUNTER INTEGER DEFAULT 0; ';
            v_sql := v_sql || '  ERRORS NUMBER; ';
            v_sql := v_sql || '  DML_ERRORS EXCEPTION;  ';
            v_sql := v_sql || '  ERR_IDX INTEGER;  ';
            v_sql := v_sql || '  ERR_CODE NUMBER;  ';
            v_sql := v_sql || '  ERR_MSG VARCHAR2(255); ';
            v_sql := v_sql || 'BEGIN ';
            v_sql := v_sql || '  OPEN C_MOV; ';
            v_sql := v_sql || '  LOOP ';
            v_sql := v_sql || '  FETCH C_MOV BULK COLLECT INTO TAB_MOV LIMIT 100; ';
            v_sql := v_sql || '    V_COUNTER := V_COUNTER + 100; ';
            v_sql :=
                   v_sql
                || '    DBMS_APPLICATION_INFO.SET_MODULE('''
                || vg_module
                || ''', ''F4 INSERT MOV ['' || V_COUNTER || '']''); ';
            ---
            v_sql := v_sql || '    BEGIN ';
            v_sql := v_sql || '      FORALL I IN TAB_MOV.FIRST .. TAB_MOV.LAST SAVE EXCEPTIONS ';
            v_sql := v_sql || '        INSERT INTO MSAFI.DPSP_FIN151_CAT42_MOV VALUES TAB_MOV(I); ';
            v_sql := v_sql || '      COMMIT; ';
            v_sql := v_sql || '    EXCEPTION ';
            v_sql := v_sql || '     WHEN OTHERS THEN ';
            v_sql := v_sql || '       ERRORS := SQL%BULK_EXCEPTIONS.COUNT;  ';
            v_sql := v_sql || '       FOR I IN 1..ERRORS LOOP  ';
            v_sql := v_sql || '           ERR_IDX := SQL%BULK_EXCEPTIONS(I).ERROR_INDEX;  ';
            v_sql := v_sql || '           ERR_CODE := SQL%BULK_EXCEPTIONS(I).ERROR_CODE;  ';
            v_sql := v_sql || '           ERR_MSG  := SQLERRM(-SQL%BULK_EXCEPTIONS(I).ERROR_CODE);  ';
            v_sql := v_sql || '           INSERT INTO MSAFI.LOG_GERAL (ORA_ERR_NUMBER1, ORA_ERR_MESG1, COD_EMPRESA, '; --1
            v_sql := v_sql || '                                        COD_ESTAB, NUM_DOCFIS, DATA_FISCAL, ';
            v_sql := v_sql || '                                        NUM_ITEM, COL14, COL15,   ';
            v_sql := v_sql || '                                        COL18, COL19, COL20, ';
            v_sql := v_sql || '                                        COL21, COL22, MOVTO_E_S) ';
            v_sql := v_sql || '                                        VALUES ';
            v_sql := v_sql || '                                         (ERR_CODE, ERR_MSG, MSAFI.DPSP.EMPRESA, '; --1
            v_sql :=
                   v_sql
                || '                                         '''
                || v_cod_estab
                || ''', TAB_MOV(ERR_IDX).NUM_DOC, TAB_MOV(ERR_IDX).DATA, ';
            v_sql :=
                   v_sql
                || '                                         TAB_MOV(ERR_IDX).NUM_ITEM, TAB_MOV(ERR_IDX).CHV_DOC, '' '', ';
            v_sql :=
                   v_sql
                || '                                         ''DPSP_FIN151_CAT42_FICHAS_CPROC'', ''INSERT_MOV'', ''CAT42_FICHA4'', ';
            v_sql :=
                   v_sql
                || '                                         TO_CHAR(SYSDATE,''DD/MM/YYYY HH24:MI.SS''), '''
                || p_proc_instance
                || ''', '' ''); ';
            v_sql := v_sql || '       END LOOP;  ';
            v_sql := v_sql || '       COMMIT; ';
            v_sql := v_sql || '    END; ';
            ---
            v_sql := v_sql || '    TAB_MOV.DELETE; ';
            v_sql := v_sql || '  EXIT WHEN C_MOV%NOTFOUND; ';
            v_sql := v_sql || '  END LOOP; ';
            v_sql := v_sql || '  CLOSE C_MOV; ';
            v_sql := v_sql || 'END; ';

            BEGIN
                EXECUTE IMMEDIATE v_sql;
            EXCEPTION
                WHEN OTHERS THEN
                    tab_error.EXTEND;
                    tab_error ( tab_error.COUNT ).cod_estab := v_cod_estab;
                    tab_error ( tab_error.COUNT ).status := 'L';
                    tab_error ( tab_error.COUNT ).error_msg :=
                        SUBSTR ( SQLERRM
                               , 1
                               , 255 );
                    ---
                    dbms_output.put_line ( SQLERRM );
                    raise_application_error ( -20001
                                            , '!ERRO INSERT_MOV!' );
            END;

            dbms_application_info.set_module ( vg_module
                                             , 'F4 INSERT MOV [OK]' );

            EXECUTE IMMEDIATE 'UPDATE ' || p_tab_partition || ' SET STATUS = ''M'' WHERE ROW_INI = :1 AND ROW_END = :2'
                USING p_part_ini
                    , p_part_fim;

            COMMIT;

            EXECUTE IMMEDIATE 'TRUNCATE TABLE MSAFI.' || v_tab_mov;

            IF ( flg_audit = 'S' ) THEN
                dbms_application_info.set_module ( vg_module
                                                 , 'F4 GRAVA AUDIT' );
                v_sql := ' INSERT INTO MSAFI.DPSP_FIN151_CAT42_MOV_AUDIT ';
                v_sql := v_sql || ' SELECT DISTINCT ';
                v_sql := v_sql || ' A.COD_EMPRESA, ';
                v_sql := v_sql || ' A.COD_ESTAB, ';
                v_sql := v_sql || ' A.DATA_FISCAL, ';
                v_sql := v_sql || ' A.DATA_FISCAL_S, ';
                v_sql := v_sql || ' A.MOVTO_E_S, ';
                v_sql := v_sql || ' A.IDENT_FIS_JUR, ';
                v_sql := v_sql || ' A.NUM_DOCFIS, ';
                v_sql := v_sql || ' A.SERIE_DOCFIS, ';
                v_sql := v_sql || ' A.NUM_ITEM, ';
                v_sql := v_sql || ' A.COD_PRODUTO, ';
                v_sql := v_sql || ' A.COD_FIS_JUR, ';
                v_sql := v_sql || ' A.QUANTIDADE, ';
                v_sql := v_sql || ' A.NUM_CONTROLE_DOCTO, ';
                v_sql := v_sql || ' A.NUM_AUTENTIC_NFE, ';
                v_sql := v_sql || ' A.UF_ORIGEM, ';
                v_sql := v_sql || ' A.VLR_BASE_ICMS, ';
                v_sql := v_sql || ' A.VLR_ICMS_UNIT, ';
                v_sql := v_sql || ' A.VLR_BASE_ICMS_ST, ';
                v_sql := v_sql || ' A.VLR_ICMS_ST_UNIT, ';
                v_sql := v_sql || ' A.VLR_BASE_ICMSST_RET, ';
                v_sql := v_sql || ' A.VLR_ICMSST_RET_UNIT, ';
                v_sql := v_sql || ' ' || p_proc_instance || ' AS PROC_ID, ';
                v_sql :=
                       v_sql
                    || ' '''
                    || SYS_CONTEXT ( 'USERENV'
                                   , 'OS_USER' )
                    || ''' AS NM_USUARIO, ';
                v_sql := v_sql || ' ''' || v_data_hora_ini || ''' AS DT_CARGA, ';
                v_sql := v_sql || ' ' || TO_CHAR ( pdt_periodo ) || ', ';
                v_sql := v_sql || ' A.ALIQ_ICMS, ';
                v_sql := v_sql || ' A.CFOP_FORN ';
                v_sql := v_sql || ' FROM MSAFI.' || p_tab_retorno || ' A ';

                EXECUTE IMMEDIATE v_sql;

                COMMIT;
            --LOGA('GERANDO ARQUIVO AUDITORIA-INI ', FALSE);
            END IF;

            dbms_output.put_line (
                                      v_cod_estab
                                   || ' PROCESSAMENTO OK '
                                   || pdt_ini
                                   || '-'
                                   || pdt_fim
                                   || '-'
                                   || pdt_periodo
                                   || '-'
                                   || v_data_hora_ini
            );

            EXECUTE IMMEDIATE 'UPDATE ' || p_tab_partition || ' SET STATUS = ''Y'' WHERE ROW_INI = :1 AND ROW_END = :2'
                USING p_part_ini
                    , p_part_fim;

            COMMIT;
        ELSE
            --SEM MOVIMENTO PARA A FILIAL NO PERIODO INFORMADO
            dbms_output.put_line (
                                      v_cod_estab
                                   || ' SEM MOVIMENTO '
                                   || pdt_ini
                                   || '-'
                                   || pdt_fim
                                   || '-'
                                   || pdt_periodo
                                   || '-'
                                   || v_data_hora_ini
            );

            EXECUTE IMMEDIATE 'UPDATE ' || p_tab_partition || ' SET STATUS = ''X'' WHERE ROW_INI = :1 AND ROW_END = :2'
                USING p_part_ini
                    , p_part_fim;

            COMMIT;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            dbms_output.put_line ( 'ERRO FICHA4_GERAR: ' || SQLERRM );
            raise_application_error ( -20001
                                    , 'ERRO FICHA4_GERAR: ' || SQLERRM );
    END;

    PROCEDURE ficha4_mov ( v_cod_estab VARCHAR2
                         , pdt_ini DATE
                         , pdt_fim DATE
                         , pdt_periodo INTEGER
                         , v_data_hora_ini VARCHAR2
                         , p_proc_id INTEGER
                         , p_user VARCHAR2
                         , v_tipo VARCHAR2
                         , v_tab_mov VARCHAR2 )
    IS
        v_count INTEGER := 0;
        v_qt_dias INTEGER := pdt_fim - pdt_ini;
        v_sql VARCHAR2 ( 18000 );
        c_mov SYS_REFCURSOR;

        --
        TYPE tt_tab_mov IS RECORD
        (
            cod_filial VARCHAR2 ( 6 BYTE )
          , cnpj_filial VARCHAR2 ( 14 BYTE )
          , ie_filial VARCHAR2 ( 14 BYTE )
          , periodo VARCHAR2 ( 6 BYTE )
          , cod_part VARCHAR2 ( 60 BYTE )
          , nome_part VARCHAR2 ( 70 BYTE )
          , cod_pais NUMBER ( 5 )
          , cnpj_part VARCHAR2 ( 14 BYTE )
          , cpf_part VARCHAR2 ( 12 BYTE )
          , ie_part VARCHAR2 ( 14 BYTE )
          , cod_mun_part NUMBER ( 7 )
          , cod_item VARCHAR2 ( 60 BYTE )
          , descr_item VARCHAR2 ( 60 BYTE )
          , unid_inv VARCHAR2 ( 6 BYTE )
          , aliq_icms NUMBER
          , data_fiscal DATE
          , chv_doc VARCHAR2 ( 80 BYTE )
          , ecf_fab VARCHAR2 ( 21 BYTE )
          , tipo_doc VARCHAR2 ( 5 BYTE )
          , serie_doc VARCHAR2 ( 3 BYTE )
          , num_doc VARCHAR2 ( 12 BYTE )
          , cfop VARCHAR2 ( 4 BYTE )
          , cst_icms VARCHAR2 ( 2 BYTE )
          , num_item NUMBER ( 5 )
          , qtde NUMBER ( 17, 6 )
          , ind_oper VARCHAR2 ( 1 BYTE )
          , vlr_contabil NUMBER ( 17, 2 )
          , vlr_icms NUMBER
          , vlr_icms_st NUMBER
          , vlr_unit NUMBER ( 19, 4 )
          , vlr_total NUMBER ( 17, 2 )
          , vlr_base_icms NUMBER
          , vlr_base_icms_st_xml NUMBER
          , vlr_base_icmsst_ret NUMBER
          , vlr_icmsst_ret_unit NUMBER
          , tipo_estab VARCHAR2 ( 6 BYTE )
          , nf_brl_id VARCHAR2 ( 12 BYTE )
          , aliq_interna VARCHAR2 ( 8 BYTE )
          , vlr_base_icms_st NUMBER
          , proc_id INTEGER
          , nm_usuario VARCHAR2 ( 50 BYTE )
          , dt_carga VARCHAR2 ( 20 BYTE )
          , uf_part VARCHAR2 ( 2 BYTE )
          , vlr_desconto NUMBER ( 15, 4 )
          , lista VARCHAR2 ( 10 BYTE )
          , vlr_pct_mva NUMBER ( 5, 2 )
          , class_anvisa VARCHAR2 ( 50 BYTE )
          , vlr_pmc NUMBER ( 15, 4 )
          , vlr_desc_pmc NUMBER ( 5, 2 )
          , movto_e_s VARCHAR2 ( 2 BYTE )
          , origem_icms VARCHAR2 ( 1 BYTE )
          , chave_acesso_ref VARCHAR2 ( 80 BYTE )
          , data_fiscal_ref DATE
          , cfop_forn VARCHAR2 ( 8 BYTE )
          , business_unit VARCHAR2 ( 8 BYTE )
          , tax_controle VARCHAR2 ( 2 BYTE )
        );

        TYPE t_tab_mov IS TABLE OF tt_tab_mov;

        tab_mov t_tab_mov;
        --
        v_part_x07 VARCHAR2 ( 60 ) := '';
        v_part_x08 VARCHAR2 ( 60 ) := '';
        v_part_trib_x08 VARCHAR2 ( 60 ) := '';
        v_part_base_x08 VARCHAR2 ( 60 ) := '';
        v_part_x993 VARCHAR2 ( 60 ) := '';
        v_part_x994 VARCHAR2 ( 60 ) := '';
        --
        errors NUMBER;
        dml_errors EXCEPTION;
        err_idx INTEGER;
        err_code NUMBER;
        err_msg VARCHAR2 ( 255 );
    BEGIN
        --OBTER NOME DA PARTICAO
        BEGIN
            SELECT ' PARTITION ( ' || a.partition_name || ') '
              INTO v_part_trib_x08
              FROM TABLE ( msafi.dpsp_recupera_particao ( 'MSAF'
                                                        , 'X08_TRIB_MERC'
                                                        , pdt_ini
                                                        , pdt_fim ) ) a;
        EXCEPTION
            WHEN OTHERS THEN
                v_part_trib_x08 := ' ';
        END;

        --
        BEGIN
            SELECT ' PARTITION ( ' || a.partition_name || ') '
              INTO v_part_base_x08
              FROM TABLE ( msafi.dpsp_recupera_particao ( 'MSAF'
                                                        , 'X08_BASE_MERC'
                                                        , pdt_ini
                                                        , pdt_fim ) ) a;
        EXCEPTION
            WHEN OTHERS THEN
                v_part_base_x08 := ' ';
        END;

        --
        BEGIN
            SELECT ' PARTITION ( ' || a.partition_name || ') '
              INTO v_part_x07
              FROM TABLE ( msafi.dpsp_recupera_particao ( 'MSAF'
                                                        , 'X07_DOCTO_FISCAL'
                                                        , pdt_ini
                                                        , pdt_fim ) ) a;
        EXCEPTION
            WHEN OTHERS THEN
                v_part_x07 := ' ';
        END;

        --
        BEGIN
            SELECT ' PARTITION ( ' || a.partition_name || ') '
              INTO v_part_x08
              FROM TABLE ( msafi.dpsp_recupera_particao ( 'MSAF'
                                                        , 'X08_ITENS_MERC'
                                                        , pdt_ini
                                                        , pdt_fim ) ) a;
        EXCEPTION
            WHEN OTHERS THEN
                v_part_x08 := ' '; --A X08 NAO ESTA PARTICIONADA TOTALMENTE
        END;

        --
        BEGIN
            SELECT ' PARTITION ( ' || a.partition_name || ') '
              INTO v_part_x993
              FROM TABLE ( msafi.dpsp_recupera_particao ( 'MSAF'
                                                        , 'X993_CAPA_CUPOM_ECF'
                                                        , pdt_ini
                                                        , pdt_fim ) ) a;
        EXCEPTION
            WHEN OTHERS THEN
                v_part_x993 := ' ';
        END;

        --
        BEGIN
            SELECT ' PARTITION ( ' || a.partition_name || ') '
              INTO v_part_x994
              FROM TABLE ( msafi.dpsp_recupera_particao ( 'MSAF'
                                                        , 'X994_ITEM_CUPOM_ECF'
                                                        , pdt_ini
                                                        , pdt_fim ) ) a;
        EXCEPTION
            WHEN OTHERS THEN
                v_part_x994 := ' ';
        END;

        FOR c_dt IN ( SELECT   DISTINCT b.data_fiscal AS data_normal
                          FROM (SELECT pdt_ini + ( ROWNUM - 1 ) AS data_fiscal
                                  FROM all_objects
                                 WHERE ROWNUM <= (pdt_fim - pdt_ini + 1)) b
                      ORDER BY b.data_fiscal ) LOOP
            dbms_application_info.set_module ( vg_module
                                             , 'F4 MOV NF ' || v_cod_estab || ' [' || c_dt.data_normal || ']' );

            v_sql := 'SELECT   A.COD_ESTAB AS COD_FILIAL, ';
            v_sql := v_sql || '         D.CGC AS CNPJ_FILIAL, ';
            v_sql := v_sql || '         IE.INSCRICAO_ESTADUAL AS IE_FILIAL, ';
            v_sql := v_sql || '         TO_CHAR(B.DATA_FISCAL, ''YYYYMM'') AS PERIODO, ';
            v_sql := v_sql || '         C.COD_FIS_JUR AS COD_PART, ';
            v_sql := v_sql || '         C.RAZAO_SOCIAL AS NOME_PART, ';
            v_sql := v_sql || '         1058 AS COD_PAIS, ';
            v_sql := v_sql || '         C.CPF_CGC AS CNPJ_PART,  ';
            v_sql := v_sql || '         '''' AS CPF_PART, ';
            v_sql := v_sql || '         C.INSC_ESTADUAL AS IE_PART,  ';
            v_sql := v_sql || '         MU.COD_UF || LPAD(C.COD_MUNICIPIO, 5, 0) AS COD_MUN_PART, ';
            v_sql := v_sql || '         H.COD_PRODUTO AS COD_ITEM, ';
            v_sql := v_sql || '         H.DESCRICAO AS DESCR_ITEM, ';
            v_sql := v_sql || '         N.COD_MEDIDA AS UNID_INV, ';
            --
            v_sql := v_sql || '         NVL((SELECT ALIQ_TRIBUTO  ';
            v_sql := v_sql || '               FROM MSAF.X08_TRIB_MERC ' || v_part_trib_x08 || ' IT ';
            v_sql := v_sql || '              WHERE B.COD_EMPRESA = IT.COD_EMPRESA ';
            v_sql := v_sql || '                AND B.COD_ESTAB = IT.COD_ESTAB  ';
            v_sql := v_sql || '                AND B.DATA_FISCAL = IT.DATA_FISCAL ';
            v_sql := v_sql || '                AND B.MOVTO_E_S = IT.MOVTO_E_S  ';
            v_sql := v_sql || '                AND B.NORM_DEV = IT.NORM_DEV  ';
            v_sql := v_sql || '                AND B.IDENT_DOCTO = IT.IDENT_DOCTO ';
            v_sql := v_sql || '                AND B.IDENT_FIS_JUR = IT.IDENT_FIS_JUR  ';
            v_sql := v_sql || '                AND B.NUM_DOCFIS = IT.NUM_DOCFIS ';
            v_sql := v_sql || '                AND B.SERIE_DOCFIS = IT.SERIE_DOCFIS  ';
            v_sql := v_sql || '                AND B.SUB_SERIE_DOCFIS = IT.SUB_SERIE_DOCFIS ';
            v_sql := v_sql || '                AND B.DISCRI_ITEM = IT.DISCRI_ITEM ';
            v_sql := v_sql || '                AND IT.COD_TRIBUTO = ''ICMS''), ';
            v_sql := v_sql || '             0) AS ALIQ_ICMS,  ';
            --
            v_sql := v_sql || '         A.DATA_FISCAL, ';
            v_sql := v_sql || '         A.NUM_AUTENTIC_NFE AS CHV_DOC, ';
            v_sql := v_sql || '         DECODE(TP.COD_DOCTO, ';
            v_sql := v_sql || '                ''CF'', ';
            v_sql := v_sql || '                SUBSTR(TRIM(A.NUM_AUTENTIC_NFE), 23, 9),  ';
            v_sql := v_sql || '                ''CF-E'',   ';
            v_sql := v_sql || '                SUBSTR(TRIM(A.NUM_AUTENTIC_NFE), 23, 9),  ';
            v_sql := v_sql || '                ''SAT'',   ';
            v_sql := v_sql || '                SUBSTR(TRIM(A.NUM_AUTENTIC_NFE), 23, 9),  ';
            v_sql := v_sql || '                '''') AS ECF_FAB, ';
            v_sql := v_sql || '         J.COD_MODELO AS TIPO_DOC, ';
            v_sql := v_sql || '         A.SERIE_DOCFIS AS SERIE_DOC,  ';
            v_sql := v_sql || '         A.NUM_DOCFIS AS NUM_DOC, ';
            v_sql := v_sql || '         F.COD_CFO AS CFOP,  ';
            v_sql := v_sql || '         G.COD_SITUACAO_B AS CST_ICMS, ';
            v_sql := v_sql || '         B.NUM_ITEM AS NUM_ITEM,  ';
            v_sql := v_sql || '         B.QUANTIDADE AS QTDE,  ';
            v_sql := v_sql || '         DECODE(A.MOVTO_E_S, ''9'', ''1'', ''0'') AS IND_OPER, ';
            v_sql := v_sql || '         B.VLR_CONTAB_ITEM AS VLR_CONTABIL, ';
            v_sql := v_sql || '         NVL((SELECT VLR_TRIBUTO  ';
            v_sql := v_sql || '               FROM MSAF.X08_TRIB_MERC ' || v_part_trib_x08 || ' IT   ';
            v_sql := v_sql || '              WHERE B.COD_EMPRESA = IT.COD_EMPRESA ';
            v_sql := v_sql || '                AND B.COD_ESTAB = IT.COD_ESTAB ';
            v_sql := v_sql || '                AND B.DATA_FISCAL = IT.DATA_FISCAL ';
            v_sql := v_sql || '                AND B.MOVTO_E_S = IT.MOVTO_E_S  ';
            v_sql := v_sql || '                AND B.NORM_DEV = IT.NORM_DEV ';
            v_sql := v_sql || '                AND B.IDENT_DOCTO = IT.IDENT_DOCTO ';
            v_sql := v_sql || '                AND B.IDENT_FIS_JUR = IT.IDENT_FIS_JUR ';
            v_sql := v_sql || '                AND B.NUM_DOCFIS = IT.NUM_DOCFIS ';
            v_sql := v_sql || '                AND B.SERIE_DOCFIS = IT.SERIE_DOCFIS ';
            v_sql := v_sql || '                AND B.SUB_SERIE_DOCFIS = IT.SUB_SERIE_DOCFIS ';
            v_sql := v_sql || '                AND B.DISCRI_ITEM = IT.DISCRI_ITEM ';
            v_sql := v_sql || '                AND IT.COD_TRIBUTO = ''ICMS''), ';
            v_sql := v_sql || '             0) AS VLR_ICMS, ';
            v_sql :=
                   v_sql
                || '         CASE WHEN C.CPF_CGC = ''61412110052384'' AND B.MOVTO_E_S <> ''9'' AND '''
                || v_tipo
                || ''' = ''L'' THEN 0 ELSE '; --SE FOR ENTRADA NA LOJA COM ORIGEM DSP910, ZERAR ST
            v_sql := v_sql || '             NVL((SELECT VLR_TRIBUTO ';
            v_sql := v_sql || '                   FROM MSAF.X08_TRIB_MERC ' || v_part_trib_x08 || ' IT ';
            v_sql := v_sql || '                  WHERE B.COD_EMPRESA = IT.COD_EMPRESA ';
            v_sql := v_sql || '                    AND B.COD_ESTAB = IT.COD_ESTAB  ';
            v_sql := v_sql || '                    AND B.DATA_FISCAL = IT.DATA_FISCAL  ';
            v_sql := v_sql || '                    AND B.MOVTO_E_S = IT.MOVTO_E_S ';
            v_sql := v_sql || '                    AND B.NORM_DEV = IT.NORM_DEV ';
            v_sql := v_sql || '                    AND B.IDENT_DOCTO = IT.IDENT_DOCTO  ';
            v_sql := v_sql || '                    AND B.IDENT_FIS_JUR = IT.IDENT_FIS_JUR ';
            v_sql := v_sql || '                    AND B.NUM_DOCFIS = IT.NUM_DOCFIS ';
            v_sql := v_sql || '                    AND B.SERIE_DOCFIS = IT.SERIE_DOCFIS ';
            v_sql := v_sql || '                    AND B.SUB_SERIE_DOCFIS = IT.SUB_SERIE_DOCFIS ';
            v_sql := v_sql || '                    AND B.DISCRI_ITEM = IT.DISCRI_ITEM ';
            v_sql := v_sql || '                    AND IT.COD_TRIBUTO = ''ICMS-S''), ';
            v_sql := v_sql || '                 0) ';
            v_sql := v_sql || '         END AS VLR_ICMS_ST, ';
            v_sql := v_sql || '         B.VLR_UNIT AS VLR_UNIT, ';
            v_sql := v_sql || '         B.VLR_ITEM AS VLR_TOTAL, ';
            v_sql := v_sql || '         NVL((SELECT VLR_BASE ';
            v_sql := v_sql || '               FROM MSAF.X08_BASE_MERC ' || v_part_base_x08 || ' G ';
            v_sql := v_sql || '              WHERE G.COD_EMPRESA = B.COD_EMPRESA  ';
            v_sql := v_sql || '                AND G.COD_ESTAB = B.COD_ESTAB  ';
            v_sql := v_sql || '                AND G.DATA_FISCAL = B.DATA_FISCAL ';
            v_sql := v_sql || '                AND G.MOVTO_E_S = B.MOVTO_E_S ';
            v_sql := v_sql || '                AND G.NORM_DEV = B.NORM_DEV  ';
            v_sql := v_sql || '                AND G.IDENT_DOCTO = B.IDENT_DOCTO ';
            v_sql := v_sql || '                AND G.IDENT_FIS_JUR = B.IDENT_FIS_JUR  ';
            v_sql := v_sql || '                AND G.NUM_DOCFIS = B.NUM_DOCFIS ';
            v_sql := v_sql || '                AND G.SERIE_DOCFIS = B.SERIE_DOCFIS ';
            v_sql := v_sql || '                AND G.SUB_SERIE_DOCFIS = B.SUB_SERIE_DOCFIS ';
            v_sql := v_sql || '                AND G.DISCRI_ITEM = B.DISCRI_ITEM ';
            v_sql := v_sql || '                AND G.COD_TRIBUTACAO = ''1'' ';
            v_sql := v_sql || '                AND G.COD_TRIBUTO = ''ICMS''), ';
            v_sql := v_sql || '             0) AS VLR_BASE_ICMS, ';
            v_sql :=
                   v_sql
                || '         CASE WHEN C.CPF_CGC = ''61412110052384'' AND B.MOVTO_E_S <> ''9'' AND '''
                || v_tipo
                || ''' = ''L'' THEN 0 ELSE '; --SE FOR ENTRADA NA LOJA COM ORIGEM DSP910, ZERAR ST
            v_sql := v_sql || '             NVL((SELECT VLR_BASE  ';
            v_sql := v_sql || '                   FROM MSAF.X08_BASE_MERC ' || v_part_base_x08 || ' G   ';
            v_sql := v_sql || '                  WHERE G.COD_EMPRESA = B.COD_EMPRESA ';
            v_sql := v_sql || '                    AND G.COD_ESTAB = B.COD_ESTAB  ';
            v_sql := v_sql || '                    AND G.DATA_FISCAL = B.DATA_FISCAL ';
            v_sql := v_sql || '                    AND G.MOVTO_E_S = B.MOVTO_E_S  ';
            v_sql := v_sql || '                    AND G.NORM_DEV = B.NORM_DEV ';
            v_sql := v_sql || '                    AND G.IDENT_DOCTO = B.IDENT_DOCTO  ';
            v_sql := v_sql || '                    AND G.IDENT_FIS_JUR = B.IDENT_FIS_JUR  ';
            v_sql := v_sql || '                    AND G.NUM_DOCFIS = B.NUM_DOCFIS ';
            v_sql := v_sql || '                    AND G.SERIE_DOCFIS = B.SERIE_DOCFIS  ';
            v_sql := v_sql || '                    AND G.SUB_SERIE_DOCFIS = B.SUB_SERIE_DOCFIS ';
            v_sql := v_sql || '                    AND G.DISCRI_ITEM = B.DISCRI_ITEM  ';
            v_sql := v_sql || '                    AND G.COD_TRIBUTACAO = ''1'' ';
            v_sql := v_sql || '                    AND G.COD_TRIBUTO = ''ICMS-S''),  ';
            v_sql := v_sql || '                 0) ';
            v_sql := v_sql || '         END AS VLR_BASE_ICMS_ST, ';
            v_sql := v_sql || '         0 AS VLR_BASE_ICMSST_RET, ';
            v_sql := v_sql || '         0 AS VLR_ICMSST_RET_UNIT,  ';
            --CAMPOS INTERNOS
            v_sql := v_sql || '         TIPO.TIPO       AS TIPO_ESTAB, ';
            v_sql := v_sql || '         A.NUM_CONTROLE_DOCTO AS NF_BRL_ID, ';
            v_sql := v_sql || '         0 AS ALIQ_INTERNA, ';
            v_sql := v_sql || '         0 AS VLR_BASE_ICMS_ST, ';
            v_sql := v_sql || '         ' || p_proc_id || ' AS PROC_ID,  ';
            v_sql := v_sql || '         ''' || p_user || '''  AS NM_USUARIO,   ';
            v_sql := v_sql || '         ''' || v_data_hora_ini || ''' AS DT_CARGA, ';
            --NOVOS CAMPOS EY 21/03/2019
            v_sql := v_sql || '         I.COD_ESTADO AS UF_PART,  ';
            v_sql := v_sql || '         B.VLR_DESCONTO AS VLR_DESCONTO, ';
            v_sql := v_sql || '         LIS.LISTA, ';
            v_sql := v_sql || '         0 AS VLR_PCT_MVA,  ';
            v_sql := v_sql || '         '''' AS CLASS_ANVISA, ';
            v_sql := v_sql || '         0 AS VLR_PMC, ';
            v_sql := v_sql || '         0 AS VLR_DESC_PMC,  ';
            v_sql := v_sql || '         A.MOVTO_E_S, ';
            v_sql := v_sql || '         ''L'' AS ORIGEM_ICMS, ';
            v_sql := v_sql || '         '''' AS CHAVE_ACESSO_REF, ';
            v_sql := v_sql || '         NULL AS DATA_FISCAL_REF, ';
            v_sql := v_sql || '         '''' AS CFOP_FORN, ';
            v_sql := v_sql || '         DECODE(A.IDENTIF_DOCFIS, NULL, ';
            v_sql := v_sql || '           CASE WHEN  TP.COD_DOCTO IN (''CF'',''CF-E'') THEN ';
            v_sql := v_sql || '           '''' ';
            v_sql := v_sql || '           ELSE ';
            v_sql :=
                   v_sql
                || '              DECODE(A.MOVTO_E_S, ''9'', REPLACE(REPLACE(A.COD_ESTAB,''DSP'',''VD''),''DS'',''L''),''POCOM'')  ';
            v_sql := v_sql || '           END,  ';
            v_sql :=
                   v_sql
                || '           SUBSTR(A.IDENTIF_DOCFIS, INSTR(A.IDENTIF_DOCFIS,''|'', 1, 1) + 1, INSTR(A.IDENTIF_DOCFIS,''|'', 1, 2) - INSTR(A.IDENTIF_DOCFIS,''|'', 1, 1) - 1) ';
            v_sql := v_sql || '         ) AS BU, ';
            v_sql := v_sql || '         ''A'' AS TAX_CONTROLE ';
            --
            v_sql := v_sql || '  FROM MSAF.X07_DOCTO_FISCAL ' || v_part_x07 || ' A,  ';
            v_sql := v_sql || '       MSAF.X08_ITENS_MERC ' || v_part_x08 || ' B, ';
            v_sql := v_sql || '       MSAF.X04_PESSOA_FIS_JUR C, ';
            v_sql := v_sql || '       MSAF.ESTABELECIMENTO    D, ';
            v_sql := v_sql || '       MSAF.ESTADO             E, ';
            v_sql := v_sql || '       MSAF.X2012_COD_FISCAL   F, ';
            v_sql := v_sql || '       MSAF.Y2026_SIT_TRB_UF_B G,  ';
            v_sql := v_sql || '       MSAF.X2013_PRODUTO      H,  ';
            v_sql := v_sql || '       MSAF.ESTADO             I, ';
            v_sql := v_sql || '       MSAF.X2024_MODELO_DOCTO J, ';
            v_sql := v_sql || '       MSAF.X2006_NATUREZA_OP  M, ';
            v_sql := v_sql || '       MSAF.X2007_MEDIDA       N, ';
            v_sql := v_sql || '       MSAF.X2005_TIPO_DOCTO   TP, ';
            v_sql := v_sql || '       MSAF.REGISTRO_ESTADUAL     IE, ';
            v_sql := v_sql || '       MSAF.MUNICIPIO             MU, ';
            v_sql := v_sql || '       MSAFI.DSP_ESTABELECIMENTO  TIPO, ';
            v_sql := v_sql || '       MSAF.DPSP_PS_LISTA         LIS ';
            --
            v_sql :=
                   v_sql
                || ' WHERE A.DATA_FISCAL = TO_DATE('''
                || TO_CHAR ( c_dt.data_normal
                           , 'DDMMYYYY' )
                || ''',''DDMMYYYY'') ';

            IF ( v_part_x08 = ' ' ) THEN
                v_sql :=
                       v_sql
                    || '   AND B.DATA_FISCAL BETWEEN TO_DATE('''
                    || TO_CHAR ( pdt_ini
                               , 'DDMMYYYY' )
                    || ''',''DDMMYYYY'') AND TO_DATE('''
                    || TO_CHAR ( pdt_fim
                               , 'DDMMYYYY' )
                    || ''',''DDMMYYYY'') ';
            END IF;

            v_sql := v_sql || '   AND A.COD_EMPRESA = MSAFI.DPSP.EMPRESA ';
            v_sql := v_sql || '   AND A.COD_ESTAB   = ''' || v_cod_estab || ''' ';
            v_sql := v_sql || '   AND A.SITUACAO    = ''N''  '; --NAO CANCELADOS AJUSTE EM 14/03/2019
            v_sql := v_sql || '   AND H.COD_PRODUTO NOT IN (''112046'',''141577'',''605883'',''839922'',''99015'') '; --02/05/2019
            --
            v_sql := v_sql || '   AND A.COD_ESTAB        NOT IN (''DSP291'',''DSP963'') ';
            v_sql := v_sql || '   AND A.COD_EMPRESA      = B.COD_EMPRESA ';
            v_sql := v_sql || '   AND A.COD_ESTAB        = B.COD_ESTAB ';
            v_sql := v_sql || '   AND A.DATA_FISCAL      = B.DATA_FISCAL ';
            v_sql := v_sql || '   AND A.MOVTO_E_S        = B.MOVTO_E_S ';
            v_sql := v_sql || '   AND A.NORM_DEV         = B.NORM_DEV ';
            v_sql := v_sql || '   AND A.IDENT_DOCTO      = B.IDENT_DOCTO ';
            v_sql := v_sql || '   AND A.IDENT_FIS_JUR    = B.IDENT_FIS_JUR ';
            v_sql := v_sql || '   AND A.NUM_DOCFIS       = B.NUM_DOCFIS ';
            v_sql := v_sql || '   AND A.SERIE_DOCFIS     = B.SERIE_DOCFIS ';
            v_sql := v_sql || '   AND A.SUB_SERIE_DOCFIS = B.SUB_SERIE_DOCFIS ';
            --
            v_sql := v_sql || '   AND IE.COD_EMPRESA     = D.COD_EMPRESA ';
            v_sql := v_sql || '   AND IE.COD_ESTAB       = D.COD_ESTAB ';
            v_sql := v_sql || '   AND IE.IDENT_ESTADO    = D.IDENT_ESTADO ';
            --
            v_sql := v_sql || '   AND C.IDENT_ESTADO     = MU.IDENT_ESTADO ';
            v_sql := v_sql || '   AND C.COD_MUNICIPIO    = MU.COD_MUNICIPIO ';
            --
            v_sql := v_sql || '   AND B.IDENT_FIS_JUR    = C.IDENT_FIS_JUR ';
            v_sql := v_sql || '   AND D.COD_EMPRESA      = MSAFI.DPSP.EMPRESA ';
            v_sql := v_sql || '   AND B.COD_ESTAB        = D.COD_ESTAB ';
            v_sql := v_sql || '   AND D.IDENT_ESTADO     = E.IDENT_ESTADO ';
            v_sql := v_sql || '   AND B.IDENT_CFO        = F.IDENT_CFO ';
            v_sql := v_sql || '   AND B.IDENT_SITUACAO_B = G.IDENT_SITUACAO_B ';
            v_sql := v_sql || '   AND B.IDENT_PRODUTO    = H.IDENT_PRODUTO ';
            v_sql := v_sql || '   AND C.IDENT_ESTADO     = I.IDENT_ESTADO ';
            v_sql := v_sql || '   AND A.IDENT_MODELO     = J.IDENT_MODELO ';
            --
            v_sql := v_sql || '   AND B.IDENT_NATUREZA_OP = M.IDENT_NATUREZA_OP ';
            v_sql := v_sql || '   AND M.COD_NATUREZA_OP   = ''IST'' ';
            --
            v_sql := v_sql || '   AND B.IDENT_MEDIDA     = N.IDENT_MEDIDA ';
            v_sql := v_sql || '   AND B.IDENT_DOCTO      = TP.IDENT_DOCTO ';
            --
            v_sql := v_sql || '   AND A.COD_EMPRESA      = TIPO.COD_EMPRESA ';
            v_sql := v_sql || '   AND A.COD_ESTAB        = TIPO.COD_ESTAB ';
            --
            v_sql := v_sql || '   AND H.COD_PRODUTO      = LIS.COD_PRODUTO ';
            v_sql := v_sql || '   AND LIS.EFFDT          = (SELECT MAX(LL.EFFDT) ';
            v_sql := v_sql || '                             FROM MSAF.DPSP_PS_LISTA LL  '; --tabela local
            v_sql := v_sql || '                             WHERE LL.COD_PRODUTO = LIS.COD_PRODUTO  ';
            v_sql := v_sql || '                               AND LL.EFFDT      <= A.DATA_FISCAL) ';

            OPEN c_mov FOR v_sql;

            LOOP
                FETCH c_mov
                    BULK COLLECT INTO tab_mov
                    LIMIT 100;

                BEGIN
                    FORALL i IN tab_mov.FIRST .. tab_mov.LAST SAVE EXCEPTIONS
                        EXECUTE IMMEDIATE
                               'INSERT INTO MSAFI.'
                            || v_tab_mov
                            || ' VALUES (:1, :2, :3, :4, :5, :6, :7, :8, :9, :10, '
                            || ':11, :12, :13, :14, :15, :16, :17, :18, :19, :20, '
                            || ':21, :22, :23, :24, :25, :26, :27, :28, :29, :30, '
                            || ':31, :32, :33, :34, :35, :36, :37, :38, :39, :40, '
                            || ':41, :42, :43, :44, :45, :46, :47, :48, :49, :50, '
                            || ':51, :52, :53, :54, :55, :56 ) '
                            USING tab_mov ( i ).cod_filial
                                , tab_mov ( i ).cnpj_filial
                                , tab_mov ( i ).ie_filial
                                , tab_mov ( i ).periodo
                                , tab_mov ( i ).cod_part
                                , tab_mov ( i ).nome_part
                                , tab_mov ( i ).cod_pais
                                , tab_mov ( i ).cnpj_part
                                , tab_mov ( i ).cpf_part
                                , tab_mov ( i ).ie_part
                                , tab_mov ( i ).cod_mun_part
                                , tab_mov ( i ).cod_item
                                , tab_mov ( i ).descr_item
                                , tab_mov ( i ).unid_inv
                                , tab_mov ( i ).aliq_icms
                                , tab_mov ( i ).data_fiscal
                                , tab_mov ( i ).chv_doc
                                , tab_mov ( i ).ecf_fab
                                , tab_mov ( i ).tipo_doc
                                , tab_mov ( i ).serie_doc
                                , tab_mov ( i ).num_doc
                                , tab_mov ( i ).cfop
                                , tab_mov ( i ).cst_icms
                                , tab_mov ( i ).num_item
                                , tab_mov ( i ).qtde
                                , tab_mov ( i ).ind_oper
                                , tab_mov ( i ).vlr_contabil
                                , tab_mov ( i ).vlr_icms
                                , tab_mov ( i ).vlr_icms_st
                                , tab_mov ( i ).vlr_unit
                                , tab_mov ( i ).vlr_total
                                , tab_mov ( i ).vlr_base_icms
                                , tab_mov ( i ).vlr_base_icms_st_xml
                                , tab_mov ( i ).vlr_base_icmsst_ret
                                , tab_mov ( i ).vlr_icmsst_ret_unit
                                , tab_mov ( i ).tipo_estab
                                , tab_mov ( i ).nf_brl_id
                                , tab_mov ( i ).aliq_interna
                                , tab_mov ( i ).vlr_base_icms_st
                                , tab_mov ( i ).proc_id
                                , tab_mov ( i ).nm_usuario
                                , tab_mov ( i ).dt_carga
                                , tab_mov ( i ).uf_part
                                , tab_mov ( i ).vlr_desconto
                                , tab_mov ( i ).lista
                                , tab_mov ( i ).vlr_pct_mva
                                , tab_mov ( i ).class_anvisa
                                , tab_mov ( i ).vlr_pmc
                                , tab_mov ( i ).vlr_desc_pmc
                                , tab_mov ( i ).movto_e_s
                                , tab_mov ( i ).origem_icms
                                , tab_mov ( i ).chave_acesso_ref
                                , tab_mov ( i ).data_fiscal_ref
                                , tab_mov ( i ).cfop_forn
                                , tab_mov ( i ).business_unit
                                , tab_mov ( i ).tax_controle;
                EXCEPTION
                    WHEN OTHERS THEN
                        errors := SQL%BULK_EXCEPTIONS.COUNT;

                        FOR i IN 1 .. errors LOOP
                            err_idx := SQL%BULK_EXCEPTIONS ( i ).ERROR_INDEX;
                            err_code := SQL%BULK_EXCEPTIONS ( i ).ERROR_CODE;
                            err_msg := SQLERRM ( -SQL%BULK_EXCEPTIONS ( i ).ERROR_CODE );

                            INSERT INTO msafi.log_geral ( ora_err_number1
                                                        , ora_err_mesg1
                                                        , cod_empresa
                                                        , --1
                                                         cod_estab
                                                        , num_docfis
                                                        , data_fiscal
                                                        , serie_docfis
                                                        , col14
                                                        , col15
                                                        , col18
                                                        , col19
                                                        , col20
                                                        , col21
                                                        , col22
                                                        , movto_e_s )
                                 VALUES ( err_code
                                        , err_msg
                                        , msafi.dpsp.empresa
                                        , --1
                                         tab_mov ( err_idx ).cod_filial
                                        , tab_mov ( err_idx ).num_doc
                                        , tab_mov ( err_idx ).data_fiscal
                                        , tab_mov ( err_idx ).num_item
                                        , tab_mov ( err_idx ).cod_item
                                        , 'SP'
                                        , 'DPSP_FIN151_CAT42_FICHAS_CPROC'
                                        , 'FICHA4_MOV'
                                        , p_user
                                        , TO_CHAR ( SYSDATE
                                                  , 'DD/MM/YYYY HH24:MI.SS' )
                                        , p_proc_id
                                        , 'NF | CF-e' );
                        END LOOP;

                        COMMIT;
                END;

                COMMIT;
                tab_mov.delete;
                EXIT WHEN c_mov%NOTFOUND;
            END LOOP;

            COMMIT;

            CLOSE c_mov;

            IF ( v_tipo = 'L' ) THEN --APENAS PARA LOJAS
                -------------------------------------------------------------------------------------------
                dbms_application_info.set_module ( vg_module
                                                 , 'F4 MOV CUPOM ' || v_cod_estab || ' [' || c_dt.data_normal || ']' );

                v_sql := ' SELECT ';
                v_sql := v_sql || ' X993.COD_ESTAB, ';
                v_sql := v_sql || ' EST.CGC, ';
                v_sql := v_sql || ' IE.INSCRICAO_ESTADUAL, ';
                v_sql := v_sql || ' TO_CHAR(X993.DATA_EMISSAO,''YYYYMM'') AS PERIODO, ';
                v_sql := v_sql || ' '' '' AS COD_PART, ';
                v_sql := v_sql || ' X993.NOME_CLIENTE, ';
                v_sql := v_sql || ' 1058 AS COD_PAIS, ';
                v_sql :=
                       v_sql
                    || ' CASE WHEN LENGTH(X993.CPF_CNPJ_CLIENTE) > 11 THEN X993.CPF_CNPJ_CLIENTE ELSE '' '' END AS CNPJ_PART, ';
                v_sql :=
                       v_sql
                    || ' CASE WHEN LENGTH(X993.CPF_CNPJ_CLIENTE) <= 11 THEN X993.CPF_CNPJ_CLIENTE ELSE '' '' END AS CPF_PART, ';
                v_sql := v_sql || ' '' '' AS IE_PART, ';
                v_sql := v_sql || ' 0 AS COD_MUN_PART, ';
                v_sql := v_sql || ' X2013.COD_PRODUTO AS COD_ITEM, ';
                v_sql := v_sql || ' X2013.DESCRICAO AS DESCR_ITEM, ';
                v_sql := v_sql || ' ''UN'' AS UNID_INV, ';
                v_sql := v_sql || ' 0 AS ALIQ_ICMS, ';
                v_sql := v_sql || ' X993.DATA_EMISSAO AS DATA, ';
                v_sql := v_sql || ' '' '' AS CHV_DOC, ';
                v_sql := v_sql || ' X2087.COD_FABRICACAO_ECF AS ECF_FAB, ';
                v_sql := v_sql || ' ''2D'' AS TIPO_DOC, ';
                v_sql := v_sql || ' '' '' AS SERIE_DOC, ';
                v_sql := v_sql || ' X993.NUM_COO AS NUM_DOC, ';
                v_sql := v_sql || ' X2012.COD_CFO AS CFOP, ';
                v_sql := v_sql || ' '' '' AS CST_ICMS, ';
                v_sql := v_sql || ' X994.NUM_ITEM, ';
                v_sql := v_sql || ' X994.QTDE, ';
                v_sql := v_sql || ' ''9'' AS IND_OPER, ';
                v_sql := v_sql || ' X994.VLR_LIQ_ITEM AS VLR_CONTABIL, ';
                v_sql := v_sql || ' X994.VLR_TRIBUTO AS VLR_ICMS, ';
                v_sql := v_sql || ' 0 AS VLR_ICMS_ST, ';
                v_sql := v_sql || ' X994.VLR_UNIT, ';
                v_sql := v_sql || ' X994.VLR_ITEM AS VLR_TOTAL, ';
                v_sql := v_sql || ' X994.VLR_BASE, ';
                v_sql := v_sql || ' 0 AS VLR_BASE_ICMS_ST, ';
                v_sql := v_sql || ' 0 AS VLR_BASE_ICMSST_RET, ';
                v_sql := v_sql || ' 0 AS VLR_ICMSST_RET_UNIT,  ';
                v_sql := v_sql || ' ''L'' AS TIPO_ESTAB, ';
                v_sql := v_sql || ' '' '' AS NF_BRL_ID, ';
                v_sql := v_sql || ' 0 AS ALIQ_INTERNA, ';
                v_sql := v_sql || ' 0 AS VLR_BASE_ICMS_ST, ';
                v_sql := v_sql || ' ' || p_proc_id || ' AS PROC_ID,  ';
                v_sql := v_sql || ' ''' || p_user || '''  AS NM_USUARIO,   ';
                v_sql := v_sql || ' ''' || v_data_hora_ini || ''' AS DT_CARGA, ';
                v_sql := v_sql || ' '' '' AS UF_PART,  ';
                v_sql := v_sql || ' X994.VLR_DESC AS VLR_DESCONTO, ';
                v_sql := v_sql || ' LIS.LISTA, ';
                v_sql := v_sql || ' 0 AS VLR_PCT_MVA,  ';
                v_sql := v_sql || ' '''' AS CLASS_ANVISA, ';
                v_sql := v_sql || ' 0 AS VLR_PMC, ';
                v_sql := v_sql || ' 0 AS VLR_DESC_PMC,  ';
                v_sql := v_sql || ' ''9'' AS MOVTO_E_S, ';
                v_sql := v_sql || ' ''L'' AS ORIGEM_ICMS, ';
                v_sql := v_sql || ' '''' AS CHAVE_ACESSO_REF, ';
                v_sql := v_sql || ' NULL AS DATA_FISCAL_REF, ';
                v_sql := v_sql || ' '''' AS CFOP_FORN, ';
                v_sql := v_sql || ' '' '' AS BU, ';
                v_sql := v_sql || ' ''A'' AS TAX_CONTROLE ';
                v_sql := v_sql || ' FROM MSAF.X993_CAPA_CUPOM_ECF ' || v_part_x993 || ' X993 ';
                v_sql := v_sql || '     ,MSAF.X994_ITEM_CUPOM_ECF ' || v_part_x994 || ' X994 ';
                v_sql := v_sql || '     ,MSAF.X2087_EQUIPAMENTO_ECF X2087 ';
                v_sql := v_sql || '     ,MSAF.ESTABELECIMENTO  EST ';
                v_sql := v_sql || '     ,MSAF.ESTADO           UF_EST ';
                v_sql := v_sql || '     ,MSAF.X2013_PRODUTO    X2013 ';
                v_sql := v_sql || '     ,MSAF.X2012_COD_FISCAL X2012 ';
                v_sql := v_sql || '     ,MSAF.X2043_COD_NBM    NCM ';
                v_sql := v_sql || '     ,MSAF.GRUPO_PRODUTO    GRP ';
                v_sql := v_sql || '     ,MSAF.REGISTRO_ESTADUAL IE ';
                v_sql := v_sql || '     ,MSAF.DPSP_PS_LISTA LIS ';
                v_sql := v_sql || '     ,MSAFI.PS_INV_ITEMS_MVW INV '; --VW MATERIALIZED
                v_sql := v_sql || ' WHERE X993.COD_EMPRESA  = MSAFI.DPSP.EMPRESA ';
                v_sql := v_sql || '   AND X993.COD_ESTAB    = ''' || v_cod_estab || ''' ';
                v_sql :=
                       v_sql
                    || '   AND X993.DATA_EMISSAO = TO_DATE('''
                    || TO_CHAR ( c_dt.data_normal
                               , 'DDMMYYYY' )
                    || ''',''DDMMYYYY'') ';
                v_sql :=
                       v_sql
                    || '   AND X993.DATA_EMISSAO BETWEEN TO_DATE('''
                    || TO_CHAR ( pdt_ini
                               , 'DDMMYYYY' )
                    || ''',''DDMMYYYY'') AND TO_DATE('''
                    || TO_CHAR ( pdt_fim
                               , 'DDMMYYYY' )
                    || ''',''DDMMYYYY'') ';
                v_sql := v_sql || '   AND X993.IND_SITUACAO_CUPOM = ''1'' ';
                v_sql := v_sql || '   AND X994.IND_SITUACAO_ITEM  = ''1'' ';
                ---
                v_sql := v_sql || '   AND X2013.COD_PRODUTO      = INV.INV_ITEM_ID ';
                v_sql := v_sql || '   AND INV.SETID              = ''GERAL'' ';
                v_sql := v_sql || '   AND INV.PURCH_PROP_BRL     = ''IST'' '; --APENAS ITENS FINALIDADE IST
                v_sql := v_sql || '   AND INV.EFFDT              = (SELECT MAX(INV2.EFFDT) ';
                v_sql := v_sql || '                                 FROM MSAFI.PS_INV_ITEMS_MVW INV2 '; --VW MATERIALIZED
                v_sql := v_sql || '                                 WHERE INV2.SETID = INV.SETID ';
                v_sql := v_sql || '                                   AND INV2.INV_ITEM_ID = INV.INV_ITEM_ID ';
                v_sql := v_sql || '                                   AND INV2.EFFDT <= X993.DATA_EMISSAO) ';
                --
                v_sql := v_sql || '   AND IE.COD_EMPRESA         = EST.COD_EMPRESA ';
                v_sql := v_sql || '   AND IE.COD_ESTAB           = EST.COD_ESTAB ';
                v_sql := v_sql || '   AND IE.IDENT_ESTADO        = EST.IDENT_ESTADO ';
                --
                v_sql := v_sql || '   AND X993.COD_EMPRESA       = X2087.COD_EMPRESA ';
                v_sql := v_sql || '   AND X993.COD_ESTAB         = X2087.COD_ESTAB ';
                v_sql := v_sql || '   AND X993.IDENT_CAIXA_ECF   = X2087.IDENT_CAIXA_ECF ';
                ---
                v_sql := v_sql || '   AND X994.COD_EMPRESA       = X993.COD_EMPRESA ';
                v_sql := v_sql || '   AND X994.COD_ESTAB         = X993.COD_ESTAB ';
                v_sql := v_sql || '   AND X994.IDENT_CAIXA_ECF   = X993.IDENT_CAIXA_ECF ';
                v_sql := v_sql || '   AND X994.NUM_COO           = X993.NUM_COO ';
                v_sql := v_sql || '   AND X994.DATA_EMISSAO      = X993.DATA_EMISSAO ';
                v_sql :=
                    v_sql || '   AND X2013.COD_PRODUTO NOT IN (''112046'',''141577'',''605883'',''839922'',''99015'') '; --13/05/2019
                ---
                v_sql := v_sql || '   AND X994.IDENT_PRODUTO     = X2013.IDENT_PRODUTO ';
                v_sql := v_sql || '   AND X994.IDENT_CFO         = X2012.IDENT_CFO ';
                v_sql := v_sql || '   AND X993.COD_EMPRESA       = EST.COD_EMPRESA ';
                v_sql := v_sql || '   AND X993.COD_ESTAB         = EST.COD_ESTAB ';
                v_sql := v_sql || '   AND X2013.IDENT_NBM        = NCM.IDENT_NBM ';
                v_sql := v_sql || '   AND X2013.IDENT_GRUPO_PROD = GRP.IDENT_GRUPO_PROD ';
                v_sql := v_sql || '   AND EST.IDENT_ESTADO       = UF_EST.IDENT_ESTADO ';
                --
                v_sql := v_sql || '   AND X2013.COD_PRODUTO      = LIS.COD_PRODUTO ';
                v_sql := v_sql || '   AND LIS.EFFDT              = (SELECT MAX(LL.EFFDT) ';
                v_sql := v_sql || '                                 FROM MSAF.DPSP_PS_LISTA LL  '; --tabela local
                v_sql := v_sql || '                                 WHERE LL.COD_PRODUTO = LIS.COD_PRODUTO  ';
                v_sql := v_sql || '                                   AND LL.EFFDT      <= X993.DATA_EMISSAO) ';

                OPEN c_mov FOR v_sql;

                LOOP
                    FETCH c_mov
                        BULK COLLECT INTO tab_mov
                        LIMIT 100;

                    BEGIN
                        FORALL i IN tab_mov.FIRST .. tab_mov.LAST SAVE EXCEPTIONS
                            EXECUTE IMMEDIATE
                                   'INSERT INTO MSAFI.'
                                || v_tab_mov
                                || ' VALUES (:1, :2, :3, :4, :5, :6, :7, :8, :9, :10, '
                                || ':11, :12, :13, :14, :15, :16, :17, :18, :19, :20, '
                                || ':21, :22, :23, :24, :25, :26, :27, :28, :29, :30, '
                                || ':31, :32, :33, :34, :35, :36, :37, :38, :39, :40, '
                                || ':41, :42, :43, :44, :45, :46, :47, :48, :49, :50, '
                                || ':51, :52, :53, :54, :55, :56 ) '
                                USING tab_mov ( i ).cod_filial
                                    , tab_mov ( i ).cnpj_filial
                                    , tab_mov ( i ).ie_filial
                                    , tab_mov ( i ).periodo
                                    , tab_mov ( i ).cod_part
                                    , tab_mov ( i ).nome_part
                                    , tab_mov ( i ).cod_pais
                                    , tab_mov ( i ).cnpj_part
                                    , tab_mov ( i ).cpf_part
                                    , tab_mov ( i ).ie_part
                                    , tab_mov ( i ).cod_mun_part
                                    , tab_mov ( i ).cod_item
                                    , tab_mov ( i ).descr_item
                                    , tab_mov ( i ).unid_inv
                                    , tab_mov ( i ).aliq_icms
                                    , tab_mov ( i ).data_fiscal
                                    , tab_mov ( i ).chv_doc
                                    , tab_mov ( i ).ecf_fab
                                    , tab_mov ( i ).tipo_doc
                                    , tab_mov ( i ).serie_doc
                                    , tab_mov ( i ).num_doc
                                    , tab_mov ( i ).cfop
                                    , tab_mov ( i ).cst_icms
                                    , tab_mov ( i ).num_item
                                    , tab_mov ( i ).qtde
                                    , tab_mov ( i ).ind_oper
                                    , tab_mov ( i ).vlr_contabil
                                    , tab_mov ( i ).vlr_icms
                                    , tab_mov ( i ).vlr_icms_st
                                    , tab_mov ( i ).vlr_unit
                                    , tab_mov ( i ).vlr_total
                                    , tab_mov ( i ).vlr_base_icms
                                    , tab_mov ( i ).vlr_base_icms_st_xml
                                    , tab_mov ( i ).vlr_base_icmsst_ret
                                    , tab_mov ( i ).vlr_icmsst_ret_unit
                                    , tab_mov ( i ).tipo_estab
                                    , tab_mov ( i ).nf_brl_id
                                    , tab_mov ( i ).aliq_interna
                                    , tab_mov ( i ).vlr_base_icms_st
                                    , tab_mov ( i ).proc_id
                                    , tab_mov ( i ).nm_usuario
                                    , tab_mov ( i ).dt_carga
                                    , tab_mov ( i ).uf_part
                                    , tab_mov ( i ).vlr_desconto
                                    , tab_mov ( i ).lista
                                    , tab_mov ( i ).vlr_pct_mva
                                    , tab_mov ( i ).class_anvisa
                                    , tab_mov ( i ).vlr_pmc
                                    , tab_mov ( i ).vlr_desc_pmc
                                    , tab_mov ( i ).movto_e_s
                                    , tab_mov ( i ).origem_icms
                                    , tab_mov ( i ).chave_acesso_ref
                                    , tab_mov ( i ).data_fiscal_ref
                                    , tab_mov ( i ).cfop_forn
                                    , tab_mov ( i ).business_unit
                                    , tab_mov ( i ).tax_controle;
                    EXCEPTION
                        WHEN OTHERS THEN
                            errors := SQL%BULK_EXCEPTIONS.COUNT;

                            FOR i IN 1 .. errors LOOP
                                err_idx := SQL%BULK_EXCEPTIONS ( i ).ERROR_INDEX;
                                err_code := SQL%BULK_EXCEPTIONS ( i ).ERROR_CODE;
                                err_msg := SQLERRM ( -SQL%BULK_EXCEPTIONS ( i ).ERROR_CODE );

                                INSERT INTO msafi.log_geral ( ora_err_number1
                                                            , ora_err_mesg1
                                                            , cod_empresa
                                                            , --1
                                                             cod_estab
                                                            , num_docfis
                                                            , data_fiscal
                                                            , serie_docfis
                                                            , col14
                                                            , col15
                                                            , col18
                                                            , col19
                                                            , col20
                                                            , col21
                                                            , col22
                                                            , movto_e_s )
                                     VALUES ( err_code
                                            , err_msg
                                            , msafi.dpsp.empresa
                                            , --1
                                             tab_mov ( err_idx ).cod_filial
                                            , tab_mov ( err_idx ).num_doc
                                            , tab_mov ( err_idx ).data_fiscal
                                            , tab_mov ( err_idx ).num_item
                                            , tab_mov ( err_idx ).cod_item
                                            , 'SP'
                                            , 'DPSP_FIN151_CAT42_FICHAS_CPROC'
                                            , 'FICHA4_MOV'
                                            , p_user
                                            , TO_CHAR ( SYSDATE
                                                      , 'DD/MM/YYYY HH24:MI.SS' )
                                            , p_proc_id
                                            , 'CUPOM 2D' );
                            END LOOP;

                            COMMIT;
                    END;

                    COMMIT;
                    tab_mov.delete;
                    EXIT WHEN c_mov%NOTFOUND;
                END LOOP;

                COMMIT;

                CLOSE c_mov;
            END IF; --IF (V_TIPO = 'L') THEN
        END LOOP;
    EXCEPTION
        WHEN OTHERS THEN
            dbms_output.put_line ( 'ERRO FICHA4_MOV: ' || SQLERRM );
            raise_application_error ( -20001
                                    , 'ERRO FICHA4_MOV: ' || SQLERRM );
    END;

    PROCEDURE ficha4_extrair ( flg_dw CHAR
                             , flg_utl CHAR
                             , pdiretorio VARCHAR2
                             , parquivo VARCHAR2
                             , pdt_periodo INTEGER
                             , pid_arquivo INTEGER
                             , pcod_estab VARCHAR2
                             , flg_cd VARCHAR2
                             , p_proc_id INTEGER )
    IS
        l_vdir VARCHAR2 ( 10000 );
        l_farquivo_w utl_file.file_type;
        l_vline VARCHAR2 ( 32767 );
        v_existe INTEGER;
    BEGIN
        IF flg_utl = 'S' THEN
            l_vdir := pdiretorio;
            l_vline := '';
            l_farquivo_w :=
                utl_file.fopen ( l_vdir
                               , parquivo
                               , 'W' );
        END IF;

        IF flg_dw = 'S' THEN
            lib_proc.add_tipo ( mproc_id
                              , pid_arquivo
                              , parquivo || '.TXT'
                              , 2 );
        END IF;

        FOR i IN ( SELECT cod_filial
                        , cnpj_filial
                        , ie_filial
                        , periodo
                        , cod_part
                        , nome_part
                        , cod_pais
                        , cnpj_part
                        , cpf_part
                        , ie_part
                        , cod_mun_part
                        , cod_item
                        , descr_item
                        , unid_inv
                        , aliq_icms
                        , data
                        , chv_doc
                        , ecf_fab
                        , tipo_doc
                        , serie_doc
                        , num_doc
                        , cfop
                        , cst_icms
                        , num_item
                        , NVL ( REPLACE ( RTRIM ( TO_CHAR ( qtde
                                                          , 'FM999999999999990.999' )
                                                , '.' )
                                        , '.'
                                        , ',' )
                              , 0 )
                              AS qtde
                        , ind_oper
                        , NVL ( REPLACE ( RTRIM ( TO_CHAR ( vlr_contabil
                                                          , 'FM999999999999990.99' )
                                                , '.' )
                                        , '.'
                                        , ',' )
                              , 0 )
                              AS vlr_contabil
                        , NVL ( REPLACE ( RTRIM ( TO_CHAR ( vlr_icms
                                                          , 'FM999999999999990.99' )
                                                , '.' )
                                        , '.'
                                        , ',' )
                              , 0 )
                              AS vlr_icms
                        , CASE
                              WHEN ( origem_icms = 'C'
                                 OR origem_icms = 'F' )
                               AND ( cfop_forn = '5405'
                                 OR cfop_forn = '6405' ) THEN
                                  NVL ( REPLACE ( RTRIM ( TO_CHAR ( vlr_icmsst_ret_unit
                                                                  , 'FM999999999999990.99' )
                                                        , '.' )
                                                , '.'
                                                , ',' )
                                      , 0 )
                              ELSE
                                  NVL ( REPLACE ( RTRIM ( TO_CHAR ( vlr_icms_st
                                                                  , 'FM999999999999990.99' )
                                                        , '.' )
                                                , '.'
                                                , ',' )
                                      , 0 )
                          END
                              AS vlr_icms_st
                        , NVL ( REPLACE ( RTRIM ( TO_CHAR ( vlr_unit
                                                          , 'FM999999999999990.999' )
                                                , '.' )
                                        , '.'
                                        , ',' )
                              , 0 )
                              AS vlr_unit
                        , NVL ( REPLACE ( RTRIM ( TO_CHAR ( vlr_total
                                                          , 'FM999999999999990.99' )
                                                , '.' )
                                        , '.'
                                        , ',' )
                              , 0 )
                              AS vlr_total
                        , NVL ( REPLACE ( RTRIM ( TO_CHAR ( vlr_base_icms
                                                          , 'FM999999999999990.99' )
                                                , '.' )
                                        , '.'
                                        , ',' )
                              , 0 )
                              AS vlr_base_icms
                        , CASE
                              WHEN ( origem_icms = 'C'
                                 OR origem_icms = 'F' )
                               AND ( cfop_forn = '5405'
                                 OR cfop_forn = '6405' ) THEN
                                  NVL ( REPLACE ( RTRIM ( TO_CHAR ( vlr_base_icmsst_ret
                                                                  , 'FM999999999999990.99' )
                                                        , '.' )
                                                , '.'
                                                , ',' )
                                      , 0 )
                              ELSE
                                  DECODE ( NVL ( REPLACE ( RTRIM ( TO_CHAR ( vlr_base_icms_st
                                                                           , 'FM999999999999990.99' )
                                                                 , '.' )
                                                         , '.'
                                                         , ',' )
                                               , 0 )
                                         , 0, NVL ( REPLACE ( RTRIM ( TO_CHAR ( vlr_base_icms_st_xml
                                                                              , 'FM999999999999990.99' )
                                                                    , '.' )
                                                            , '.'
                                                            , ',' )
                                                  , 0 )
                                         , NVL ( REPLACE ( RTRIM ( TO_CHAR ( vlr_base_icms_st
                                                                           , 'FM999999999999990.99' )
                                                                 , '.' )
                                                         , '.'
                                                         , ',' )
                                               , 0 ) )
                          END
                              AS vlr_base_icms_st
                        , NVL ( REPLACE ( RTRIM ( TO_CHAR ( vlr_base_icmsst_ret
                                                          , 'FM999999999999990.99' )
                                                , '.' )
                                        , '.'
                                        , ',' )
                              , 0 )
                              AS vlr_base_icmsst_ret
                        , NVL ( REPLACE ( RTRIM ( TO_CHAR ( vlr_icmsst_ret_unit
                                                          , 'FM999999999999990.99' )
                                                , '.' )
                                        , '.'
                                        , ',' )
                              , 0 )
                              AS vlr_icmsst_ret_unit
                        , uf_part
                        , NVL ( REPLACE ( RTRIM ( TO_CHAR ( vlr_desconto
                                                          , 'FM999999999999990.99' )
                                                , '.' )
                                        , '.'
                                        , ',' )
                              , 0 )
                              AS vlr_desconto
                        , DECODE ( lista,  'P', 'POSITIVA',  'N', 'NEGATIVA',  'O', 'NEUTRA',  ' ' ) AS lista
                        , NVL ( REPLACE ( RTRIM ( TO_CHAR ( vlr_pct_mva
                                                          , 'FM990.99' )
                                                , '.' )
                                        , '.'
                                        , ',' )
                              , 0 )
                              AS vlr_pct_mva
                        , class_anvisa
                        , NVL ( REPLACE ( RTRIM ( TO_CHAR ( vlr_pmc
                                                          , 'FM999999999999990.9999' )
                                                , '.' )
                                        , '.'
                                        , ',' )
                              , 0 )
                              AS vlr_pmc
                        , NVL ( REPLACE ( RTRIM ( TO_CHAR ( vlr_desc_pmc
                                                          , 'FM990.99' )
                                                , '.' )
                                        , '.'
                                        , ',' )
                              , 0 )
                              AS vlr_desc_pmc
                        , origem_icms
                        , NVL ( chave_acesso_ref, '' ) AS chave_acesso_ref
                        , NVL ( data_fiscal_ref, '' ) AS data_fiscal_ref
                     FROM msafi.dpsp_fin151_cat42_mov
                    WHERE periodo = pdt_periodo
                      AND tipo_estab = flg_cd
                      AND cod_filial = pcod_estab ) LOOP
            l_vline :=
                   i.cod_filial
                || '|'
                || i.cnpj_filial
                || '|'
                || i.ie_filial
                || '|'
                || i.periodo
                || '|'
                || i.cod_part
                || '|'
                || i.nome_part
                || '|'
                || i.cod_pais
                || '|'
                || i.cnpj_part
                || '|'
                || i.cpf_part
                || '|'
                || i.ie_part
                || '|'
                || i.cod_mun_part
                || '|'
                || i.uf_part
                || '|'
                || i.cod_item
                || '|'
                || i.descr_item
                || '|'
                || i.unid_inv
                || '|'
                || i.data
                || '|'
                || i.chv_doc
                || '|'
                || i.ecf_fab
                || '|'
                || i.tipo_doc
                || '|'
                || i.serie_doc
                || '|'
                || i.num_doc
                || '|'
                || i.cfop
                || '|'
                || i.cst_icms
                || '|'
                || i.num_item
                || '|'
                || i.qtde
                || '|'
                || i.ind_oper
                || '|'
                || i.vlr_contabil
                || '|'
                || i.vlr_total
                || '|'
                || i.vlr_desconto
                || '|'
                || i.vlr_unit
                || '|'
                || i.vlr_total
                || '|'
                || i.vlr_base_icms
                || '|'
                || i.aliq_icms
                || '|'
                || i.vlr_icms
                || '|'
                || i.vlr_base_icms_st
                || '|'
                || NVL ( i.vlr_icms_st, i.vlr_icmsst_ret_unit )
                || '|'
                || i.vlr_pct_mva
                || '|'
                || i.lista
                || '|'
                || i.class_anvisa
                || '|'
                || i.vlr_pmc
                || '|'
                || i.vlr_desc_pmc
                || '|'
                || i.origem_icms
                || '|'
                || i.chave_acesso_ref
                || '|'
                || i.data_fiscal_ref;

            IF flg_utl = 'S' THEN
                utl_file.put_line ( l_farquivo_w
                                  , l_vline );
            END IF;

            IF flg_dw = 'S' THEN
                lib_proc.add ( l_vline
                             , NULL
                             , NULL
                             , 2 );
            END IF;

            l_vline := '';
        END LOOP;

        IF flg_utl = 'S' THEN
            utl_file.fclose ( l_farquivo_w );
        END IF;
    END;

    PROCEDURE ficha4_auditoria ( flg_dw CHAR
                               , flg_utl CHAR
                               , pdiretorio VARCHAR2
                               , parquivo VARCHAR2
                               , pdt_periodo INTEGER
                               , pid_arquivo INTEGER
                               , pcod_estab VARCHAR2
                               , flg_cd VARCHAR2
                               , p_proc_id INTEGER )
    IS
        l_vdir VARCHAR2 ( 10000 );
        l_farquivo_w utl_file.file_type;
        l_vline VARCHAR2 ( 32767 );
        v_existe INTEGER;

        --Variaveis genericas para o arquivo de Auditoria em XLS
        v_text01 VARCHAR2 ( 6000 );
        v_class VARCHAR2 ( 1 ) := 'a';
    BEGIN
        IF flg_utl = 'S' THEN
            l_vdir := pdiretorio;
            l_vline := '';
            l_farquivo_w :=
                utl_file.fopen ( l_vdir
                               , parquivo
                               , 'W' );
        END IF;

        IF flg_dw = 'S' THEN
            lib_proc.add_tipo ( p_proc_id
                              , pid_arquivo
                              , parquivo || '.XLS'
                              , 2 );

            lib_proc.add ( dsp_planilha.header
                         , ptipo => pid_arquivo );
            lib_proc.add ( dsp_planilha.tabela_inicio
                         , ptipo => pid_arquivo );

            lib_proc.add ( dsp_planilha.linha (
                                                p_conteudo =>    dsp_planilha.campo ( 'COD_EMPRESA' )
                                                              || --
                                                                dsp_planilha.campo ( 'COD_ESTAB' )
                                                              || --
                                                                dsp_planilha.campo ( 'DATA_FISCAL' )
                                                              || --
                                                                dsp_planilha.campo ( 'DATA_FISCAL_S' )
                                                              || --
                                                                dsp_planilha.campo ( 'MOVTO_E_S' )
                                                              || --
                                                                dsp_planilha.campo ( 'IDENT_FIS_JUR' )
                                                              || --
                                                                dsp_planilha.campo ( 'NUM_DOCFIS' )
                                                              || --
                                                                dsp_planilha.campo ( 'SERIE_DOCFIS' )
                                                              || --
                                                                dsp_planilha.campo ( 'NUM_ITEM' )
                                                              || --
                                                                dsp_planilha.campo ( 'COD_PRODUTO' )
                                                              || --
                                                                dsp_planilha.campo ( 'COD_FIS_JUR' )
                                                              || --
                                                                dsp_planilha.campo ( 'QUANTIDADE' )
                                                              || --
                                                                dsp_planilha.campo ( 'NUM_CONTROLE_DOCTO' )
                                                              || --
                                                                dsp_planilha.campo ( 'NUM_AUTENTIC_NFE' )
                                                              || --
                                                                dsp_planilha.campo ( 'UF_ORIGEM' )
                                                              || --
                                                                dsp_planilha.campo ( 'VLR_BASE_ICMS' )
                                                              || --
                                                                dsp_planilha.campo ( 'VLR_ICMS_UNIT' )
                                                              || --
                                                                dsp_planilha.campo ( 'VLR_BASE_ICMS_ST' )
                                                              || --
                                                                dsp_planilha.campo ( 'VLR_ICMS_ST_UNIT' )
                                                              || --
                                                                dsp_planilha.campo ( 'VLR_BASE_ICMSST_RET' )
                                                              || --
                                                                dsp_planilha.campo ( 'VLR_ICMSST_RET_UNIT' )
                                              , p_class => 'h'
                           )
                         , ptipo => pid_arquivo );
        END IF;

        FOR c IN ( SELECT cod_empresa
                        , cod_estab
                        , data_fiscal
                        , data_fiscal_s
                        , movto_e_s
                        , ident_fis_jur
                        , num_docfis
                        , serie_docfis
                        , num_item
                        , cod_produto
                        , cod_fis_jur
                        , quantidade
                        , num_controle_docto
                        , num_autentic_nfe
                        , uf_origem
                        , vlr_base_icms
                        , vlr_icms_unit
                        , vlr_base_icms_st
                        , vlr_icms_st_unit
                        , vlr_base_icmsst_ret
                        , vlr_icmsst_ret_unit
                     FROM msafi.dpsp_fin151_cat42_mov_audit
                    WHERE periodo = pdt_periodo
                      AND proc_id = p_proc_id ) LOOP
            IF v_class = 'a' THEN
                v_class := 'b';
            ELSE
                v_class := 'a';
            END IF;

            l_vline :=
                dsp_planilha.linha (
                                     p_conteudo =>    dsp_planilha.campo ( dsp_planilha.texto ( c.cod_empresa ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( c.cod_estab ) )
                                                   || --
                                                     dsp_planilha.campo ( ( c.data_fiscal ) )
                                                   || --
                                                     dsp_planilha.campo ( ( c.data_fiscal_s ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( c.movto_e_s ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( c.ident_fis_jur ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( c.num_docfis ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( c.serie_docfis ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( c.num_item ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( c.cod_produto ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( c.cod_fis_jur ) )
                                                   || --
                                                     dsp_planilha.campo ( ( c.quantidade ) )
                                                   || --
                                                     dsp_planilha.campo (
                                                                          dsp_planilha.texto ( c.num_controle_docto )
                                                      )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( c.num_autentic_nfe ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( c.uf_origem ) )
                                                   || --
                                                     dsp_planilha.campo ( ( c.vlr_base_icms ) )
                                                   || --
                                                     dsp_planilha.campo ( ( c.vlr_icms_unit ) )
                                                   || --
                                                     dsp_planilha.campo ( ( c.vlr_base_icms_st ) )
                                                   || --
                                                     dsp_planilha.campo ( ( c.vlr_icms_st_unit ) )
                                                   || --
                                                     dsp_planilha.campo ( ( c.vlr_base_icmsst_ret ) )
                                                   || --
                                                     dsp_planilha.campo ( ( c.vlr_icmsst_ret_unit ) )
                                   , p_class => v_class
                );

            IF flg_utl = 'S' THEN
                utl_file.put_line ( l_farquivo_w
                                  , l_vline );
            END IF;

            IF flg_dw = 'S' THEN
                lib_proc.add ( l_vline
                             , NULL
                             , NULL
                             , pid_arquivo );
            END IF;
        END LOOP;

        IF flg_utl = 'S' THEN
            utl_file.fclose ( l_farquivo_w );
        END IF;
    END;

    PROCEDURE ficha5_gerar ( pcod_estab VARCHAR2
                           , pdt_ini DATE
                           , pdt_fim DATE
                           , pdt_periodo INTEGER
                           , v_data_hora_ini VARCHAR2
                           , v_tipo VARCHAR2 )
    IS
        v_count INTEGER := 0;
        cc_limit NUMBER ( 7 ) := 10000;

        CURSOR c_perdas
        IS
            SELECT   perd.cod_filial
                   , perd.cnpj_filial
                   , perd.ie
                   , perd.periodo
                   , perd.cod_item
                   , perd.descricao
                   , SUM ( perd.qtd ) * ( -1 ) AS qtd
                   , perd.proc_id
                   , perd.nm_usuario
                   , perd.dt_carga
                FROM (SELECT DISTINCT est.cod_estab AS cod_filial
                                    , est.cgc AS cnpj_filial
                                    , ie.inscricao_estadual AS ie
                                    , pdt_periodo AS periodo
                                    , perd.cod_produto AS cod_item
                                    , prod.descricao AS descricao
                                    , NVL ( perd.qtd_ajuste, 0 ) AS qtd
                                    , mproc_id AS proc_id
                                    , mnm_usuario AS nm_usuario
                                    , v_data_hora_ini AS dt_carga
                        FROM msafi.dpsp_msaf_perdas_inv perd
                           , msaf.estabelecimento est
                           , msaf.registro_estadual ie
                           , msaf.x2013_produto prod
                       WHERE perd.cod_estab = est.cod_estab
                         AND perd.cod_produto = prod.cod_produto
                         AND perd.data_inv BETWEEN pdt_ini AND pdt_fim
                         AND est.cod_empresa = mcod_empresa
                         AND est.cod_estab = pcod_estab
                         AND est.cod_empresa = ie.cod_empresa
                         AND est.cod_estab = ie.cod_estab
                         AND est.ident_estado = ie.ident_estado
                         AND prod.valid_produto = (SELECT MAX ( prod2.valid_produto )
                                                     FROM msaf.x2013_produto prod2
                                                    WHERE prod2.cod_produto = prod.cod_produto
                                                      AND prod2.valid_produto <= perd.data_inv)) perd
            GROUP BY perd.cod_filial
                   , perd.cnpj_filial
                   , perd.ie
                   , perd.periodo
                   , perd.cod_item
                   , perd.descricao
                   , perd.proc_id
                   , perd.nm_usuario
                   , perd.dt_carga
              HAVING SUM ( perd.qtd ) < 0;

        TYPE tcod_filial IS TABLE OF msafi.dpsp_fin151_cat42_perdas.cod_filial%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tcnpj_filial IS TABLE OF msafi.dpsp_fin151_cat42_perdas.cnpj_filial%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tie_filial IS TABLE OF msafi.dpsp_fin151_cat42_perdas.ie_filial%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tperiodo IS TABLE OF msafi.dpsp_fin151_cat42_perdas.periodo%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tcod_item IS TABLE OF msafi.dpsp_fin151_cat42_perdas.cod_item%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tdescr_item IS TABLE OF msafi.dpsp_fin151_cat42_perdas.descr_item%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tqtd IS TABLE OF msafi.dpsp_fin151_cat42_perdas.qtd%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tproc_id IS TABLE OF msafi.dpsp_fin151_cat42_perdas.proc_id%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tnm_usuario IS TABLE OF msafi.dpsp_fin151_cat42_perdas.nm_usuario%TYPE
            INDEX BY PLS_INTEGER;

        TYPE tdt_carga IS TABLE OF msafi.dpsp_fin151_cat42_perdas.dt_carga%TYPE
            INDEX BY PLS_INTEGER;

        v_cod_filial tcod_filial;
        v_cnpj_filial tcnpj_filial;
        v_ie_filial tie_filial;
        v_periodo tperiodo;
        v_cod_item tcod_item;
        v_descr_item tdescr_item;
        v_qtd tqtd;
        v_proc_id tproc_id;
        v_nm_usuario tnm_usuario;
        v_dt_carga tdt_carga;

        ---
        TYPE t_tab_perda_cd IS TABLE OF msafi.dpsp_fin151_cat42_perdas%ROWTYPE;

        tab_perda_cd t_tab_perda_cd := t_tab_perda_cd ( );
    BEGIN
        IF v_tipo = 'L' THEN --APENAS LOJAS
            OPEN c_perdas;

            LOOP
                FETCH c_perdas
                    BULK COLLECT INTO v_cod_filial
                       , v_cnpj_filial
                       , v_ie_filial
                       , v_periodo
                       , v_cod_item
                       , v_descr_item
                       , v_qtd
                       , v_proc_id
                       , v_nm_usuario
                       , v_dt_carga
                    LIMIT cc_limit;

                BEGIN
                    FORALL i IN v_cod_filial.FIRST .. v_cod_filial.LAST
                        INSERT /*+ APPEND */
                              INTO  msafi.dpsp_fin151_cat42_perdas ( cod_filial
                                                                   , cnpj_filial
                                                                   , ie_filial
                                                                   , periodo
                                                                   , cod_item
                                                                   , descr_item
                                                                   , qtd
                                                                   , proc_id
                                                                   , nm_usuario
                                                                   , dt_carga )
                             VALUES ( v_cod_filial ( i )
                                    , v_cnpj_filial ( i )
                                    , v_ie_filial ( i )
                                    , v_periodo ( i )
                                    , v_cod_item ( i )
                                    , v_descr_item ( i )
                                    , v_qtd ( i )
                                    , v_proc_id ( i )
                                    , v_nm_usuario ( i )
                                    , v_dt_carga ( i ) );

                    v_count := v_count + SQL%ROWCOUNT;

                    COMMIT;
                END loop;

                v_cod_filial.delete;
                v_cnpj_filial.delete;
                v_ie_filial.delete;
                v_periodo.delete;
                v_cod_item.delete;
                v_descr_item.delete;
                v_qtd.delete;
                v_proc_id.delete;
                v_nm_usuario.delete;
                v_dt_carga.delete;

                EXIT WHEN c_perdas%NOTFOUND;
            END LOOP;

            CLOSE c_perdas;

            COMMIT;
        ELSE
            --PARA CDs
            --OBS.: EXECUTAR PRIMEIRO O PROCESSO DE PERDAS CDS, PARA CARREGAR TAB MSAFI.DPSP_MSAF_PERDAS_INV
            SELECT   a.cod_estab
                   , a.cgc
                   , a.inscricao_estadual
                   , a.periodo
                   , a.cod_produto
                   , a.descricao
                   , SUM ( a.qtd_ajuste ) * ( -1 )
                   , a.proc_id
                   , a.usuario
                   , a.data_hora_ini
                BULK COLLECT INTO tab_perda_cd
                FROM (SELECT perd.cod_estab
                           , est.cgc
                           , ie.inscricao_estadual
                           , pdt_periodo AS periodo
                           , perd.cod_produto
                           , prod.descricao
                           , perd.qtd_ajuste
                           , mproc_id AS proc_id
                           , mnm_usuario AS usuario
                           , v_data_hora_ini AS data_hora_ini
                           , prod.valid_produto
                           , RANK ( )
                                 OVER ( PARTITION BY prod.cod_produto
                                        ORDER BY prod.valid_produto DESC )
                                 RANK
                        FROM msafi.dpsp_msaf_perdas_inv perd
                           , msaf.estabelecimento est
                           , msaf.registro_estadual ie
                           , msaf.x2013_produto prod
                       WHERE perd.cod_estab = est.cod_estab
                         AND est.cod_empresa = msafi.dpsp.empresa
                         AND perd.cod_estab = pcod_estab
                         AND perd.data_inv BETWEEN pdt_ini AND pdt_fim
                         AND perd.cod_produto = prod.cod_produto
                         AND est.cod_empresa = ie.cod_empresa
                         AND est.cod_estab = ie.cod_estab
                         AND prod.valid_produto <= perd.data_inv) a
               WHERE a.RANK = 1
            GROUP BY a.cod_estab
                   , a.cgc
                   , a.inscricao_estadual
                   , a.periodo
                   , a.cod_produto
                   , a.descricao
                   , a.proc_id
                   , a.usuario
                   , a.data_hora_ini
              HAVING SUM ( a.qtd_ajuste ) < 0;

            FORALL i IN tab_perda_cd.FIRST .. tab_perda_cd.LAST
                INSERT INTO msafi.dpsp_fin151_cat42_perdas
                VALUES tab_perda_cd ( i );

            COMMIT;

            tab_perda_cd.delete;
        END IF;
    END;

    PROCEDURE ficha5_extrair ( flg_dw CHAR
                             , flg_utl CHAR
                             , pdiretorio VARCHAR2
                             , parquivo VARCHAR2
                             , pdt_periodo INTEGER
                             , p_cod_estab VARCHAR2 )
    IS
        l_vdir VARCHAR2 ( 10000 );
        l_farquivo_w utl_file.file_type;
        l_vline VARCHAR2 ( 32767 );
        v_existe INTEGER;
    BEGIN
        IF flg_utl = 'S' THEN
            l_vdir := pdiretorio;
            l_vline := '';
            l_farquivo_w :=
                utl_file.fopen ( l_vdir
                               , parquivo
                               , 'W' );
        END IF;

        IF flg_dw = 'S' THEN
            lib_proc.add_tipo ( mproc_id
                              , 2
                              , parquivo
                              , 2 );
        END IF;

        FOR i IN ( SELECT   cod_filial
                          , cnpj_filial
                          , ie_filial
                          , periodo
                          , cod_item
                          , descr_item
                          , REPLACE ( RTRIM ( TO_CHAR ( qtd
                                                      , 'FM999999999999990.999' )
                                            , '.' )
                                    , '.'
                                    , ',' )
                                AS qtd
                       FROM msafi.dpsp_fin151_cat42_perdas
                      WHERE periodo = pdt_periodo
                        AND proc_id = mproc_id
                        AND cod_filial = p_cod_estab
                   ORDER BY cod_filial ) LOOP
            l_vline :=
                   i.cod_filial
                || '|'
                || i.cnpj_filial
                || '|'
                || i.ie_filial
                || '|'
                || i.periodo
                || '|'
                || i.cod_item
                || '|'
                || i.descr_item
                || '|'
                || i.qtd;

            IF flg_utl = 'S' THEN
                utl_file.put_line ( l_farquivo_w
                                  , l_vline );
            END IF;

            IF flg_dw = 'S' THEN
                lib_proc.add ( l_vline
                             , NULL
                             , NULL
                             , 2 );
            END IF;
        END LOOP;

        IF flg_utl = 'S' THEN
            utl_file.fclose ( l_farquivo_w );
        END IF;
    END;

    FUNCTION create_tab_partition ( vp_proc_id IN VARCHAR2
                                  , vp_cod_estab IN lib_proc.vartab )
        RETURN VARCHAR2
    IS
        v_sql VARCHAR2 ( 4000 );
        v_tab_part VARCHAR2 ( 30 );
        v_tipo VARCHAR2 ( 1 );
    BEGIN
        v_tab_part :=
            msaf.dpsp_create_tab_tmp ( vp_proc_id
                                     , vp_proc_id
                                     , 'TAB_PART'
                                     , mnm_usuario );

        IF ( v_tab_part = 'ERRO' ) THEN
            raise_application_error ( -20001
                                    , '!ERRO CREATE_TAB_PARTITION!' );
        END IF;

        FOR i IN vp_cod_estab.FIRST .. vp_cod_estab.LAST LOOP
            SELECT tipo
              INTO v_tipo
              FROM msafi.dsp_estabelecimento
             WHERE cod_empresa = msafi.dpsp.empresa
               AND cod_estab = vp_cod_estab ( i );

            EXECUTE IMMEDIATE 'INSERT INTO ' || v_tab_part || ' VALUES (:1, :2, :3, :4, :5)'
                USING vp_cod_estab ( i )
                    , i
                    , i
                    , ''
                    , v_tipo;
        END LOOP;

        COMMIT;

        RETURN v_tab_part;
    END;

    FUNCTION create_tab_produto ( vp_proc_id IN VARCHAR2 )
        RETURN VARCHAR2
    IS
        v_tab_produto VARCHAR2 ( 30 );
    BEGIN
        v_tab_produto :=
            msaf.dpsp_create_tab_tmp ( vp_proc_id
                                     , vp_proc_id
                                     , 'TAB_PROD_CAT42'
                                     , mnm_usuario );

        IF ( v_tab_produto = 'ERRO' ) THEN
            raise_application_error ( -20001
                                    , '!ERRO CREATE_TAB_PRODUTO!' );
        END IF;

        RETURN v_tab_produto;
    END;

    FUNCTION create_tab_nfret ( vp_proc_id IN VARCHAR2 )
        RETURN VARCHAR2
    IS
        v_tab_nfret VARCHAR2 ( 30 );
    BEGIN
        v_tab_nfret :=
            msaf.dpsp_create_tab_tmp ( vp_proc_id
                                     , vp_proc_id
                                     , 'TAB_NFRET_CAT42'
                                     , mnm_usuario );

        IF ( v_tab_nfret = 'ERRO' ) THEN
            raise_application_error ( -20001
                                    , '!ERRO CREATE_TAB_NFRET!' );
        END IF;

        RETURN v_tab_nfret;
    END;

    PROCEDURE exec_ficha4_parallel ( v_proc IN VARCHAR2
                                   , p_lote IN INTEGER
                                   , v_nm_tabela IN VARCHAR2
                                   , flg_audit IN VARCHAR2
                                   , pdt_ini IN DATE
                                   , pdt_fim IN DATE
                                   , pdt_periodo IN INTEGER
                                   , v_data_hora_ini IN VARCHAR2
                                   , p_tab_produtos IN VARCHAR2
                                   , p_tab_nfret IN VARCHAR2
                                   , p_tab_partition IN VARCHAR2 )
    IS
        v_qt_grupos_paralelos INTEGER := 0;
        v_qt_grupos INTEGER := 0;
        p_task VARCHAR2 ( 50 );
        v_parametros VARCHAR2 ( 2000 );
        v_erro NUMBER := 0;
        v_msg_erro VARCHAR2 ( 2000 );
        v_try NUMBER;
        v_status NUMBER;
        v_sql VARCHAR2 ( 2000 );
    BEGIN
        p_task := 'PROC_CAT42_F4_' || v_proc;

        EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || v_nm_tabela            INTO v_qt_grupos;

        loga ( '[INICIAR THREADS FICHA4]' );

        --===================================
        --QUANTIDADE DE PROCESSOS EM PARALELO
        --===================================

        IF NVL ( p_lote, 0 ) < 1 THEN
            v_qt_grupos_paralelos := 20;
        ELSIF NVL ( p_lote, 0 ) > 100 THEN
            v_qt_grupos_paralelos := 100;
        ELSE
            IF NVL ( p_lote, 0 ) > v_qt_grupos THEN
                --SE O NUMERO DE THREADS FOR MAIOR QUE O NUMERO DE ESTABELECIMENTOS, OCORRE ERRO DE 'CRASHED' NA TASK
                v_qt_grupos_paralelos := v_qt_grupos;
            ELSE
                v_qt_grupos_paralelos := p_lote;
            END IF;
        END IF;

        v_parametros :=
               v_proc
            || ', '''
            || flg_audit
            || ''', '''
            || TO_CHAR ( pdt_ini
                       , 'DD/MM/YYYY' )
            || ''', '''
            || TO_CHAR ( pdt_fim
                       , 'DD/MM/YYYY' )
            || ''', '
            || pdt_periodo
            || ', '''
            || v_data_hora_ini
            || ''', '''
            || p_tab_produtos
            || ''', '''
            || p_tab_nfret
            || ''', '''
            || p_tab_partition
            || ''', '''
            || mnm_usuario
            || '''';

        loga ( '[ESTABS][' || v_qt_grupos || '][LOTES][' || v_qt_grupos_paralelos || ']'
             , FALSE );
        --===================================
        -- CHUNK
        --===================================
        dpsp_chunk_parallel.exec_parallel ( v_proc
                                          , 'DPSP_FIN151_CAT42_FICHAS_CPROC.FICHA4_GERAR'
                                          , v_qt_grupos
                                          , --QTDE DE ESTABELECIMENTOS
                                           v_qt_grupos_paralelos
                                          , --QTDE DE THREADS
                                           p_task
                                          , v_parametros );

        dbms_parallel_execute.drop_task ( p_task );
        loga ( '[FIM THREADS FICHA4]' );
    END;

    PROCEDURE get_anvisa_info ( vp_proc_id IN INTEGER
                              , v_tab_anvisa IN VARCHAR2
                              , v_tab_produtos IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 4000 );
    BEGIN
        msafi.upd_ps_translate ( 'DSP_TP_MED' ); --ATUALIZAR TRANSLATES EM TAB LOCAL

        v_sql := 'DECLARE TYPE T_TAB_ANVISA IS TABLE OF ' || v_tab_anvisa || '%ROWTYPE; ';
        v_sql := v_sql || '        TAB_ANVISA T_TAB_ANVISA := T_TAB_ANVISA(); ';
        v_sql := v_sql || 'BEGIN ';
        v_sql := v_sql || '  SELECT /*+DRIVING_SITE(A)*/ A.INV_ITEM_ID AS COD_PRODUTO, ';
        v_sql :=
               v_sql
            || '       REPLACE(MSAFI.PS_TRANSLATE(''DSP_TP_MED'', A.DSP_TP_MED),''<VLR INVALIDO>'','''') AS CLASS_ANVISA, ';
        v_sql := v_sql || '       A.DSP_TP_MED ';
        v_sql := v_sql || '  BULK COLLECT INTO TAB_ANVISA ';
        v_sql := v_sql || '  FROM MSAFI.PS_MASTER_ITEM_TBL A, ';
        v_sql := v_sql || '       (SELECT DISTINCT COD_ITEM FROM ' || v_tab_produtos || ') B ';
        v_sql := v_sql || '  WHERE A.SETID = ''GERAL'' ';
        v_sql := v_sql || '    AND A.INV_ITEM_ID = B.COD_ITEM; ';
        v_sql := v_sql || '  FORALL I IN TAB_ANVISA.FIRST .. TAB_ANVISA.LAST ';
        v_sql := v_sql || '    INSERT INTO ' || v_tab_anvisa || ' VALUES TAB_ANVISA(I); ';
        v_sql := v_sql || '  COMMIT; ';
        v_sql := v_sql || 'END; ';

        EXECUTE IMMEDIATE v_sql;
    END;

    PROCEDURE upd_vlr_pmc ( vp_proc_id IN INTEGER
                          , p_cod_estab IN VARCHAR2
                          , p_periodo IN INTEGER
                          , vp_tab_pmc IN VARCHAR2
                          , p_tab_mov IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 6000 );
        v_msg_erro VARCHAR2 ( 254 );
    BEGIN
        v_sql := 'DECLARE TYPE TT_TAB_MOV IS RECORD ( ';
        v_sql := v_sql || '                                  BUSINESS_UNIT VARCHAR2(8), ';
        v_sql := v_sql || '                                  NF_BRL_ID VARCHAR2(16), ';
        v_sql := v_sql || '                                  NUM_ITEM INTEGER, ';
        v_sql := v_sql || '                                  CHAVE_ACESSO VARCHAR2(80), ';
        v_sql := v_sql || '                                  MOVTO_E_S VARCHAR2(1), ';
        v_sql := v_sql || '                                  ROWID VARCHAR2(20) ';
        v_sql := v_sql || '                                  ); ';
        v_sql := v_sql || '        TYPE T_TAB_MOV IS TABLE OF TT_TAB_MOV; ';
        v_sql := v_sql || '        TAB_MOV T_TAB_MOV; ';
        v_sql := v_sql || '        V_COMMIT INTEGER := 0; ';
        v_sql := v_sql || 'BEGIN ';
        v_sql := v_sql || '  DBMS_APPLICATION_INFO.SET_MODULE(''' || $$plsql_unit || ''', ''F4 UPD VLR PMC 1''); ';
        v_sql := v_sql || '  SELECT B.BU_PO1, A.NF_BRL_ID, A.NUM_ITEM, A.CHV_DOC, A.MOVTO_E_S, A.ROWID ';
        v_sql := v_sql || '  BULK COLLECT INTO TAB_MOV ';
        v_sql := v_sql || '  FROM MSAFI.' || p_tab_mov || ' A, ';
        v_sql := v_sql || '       MSAFI.DSP_INTERFACE_SETUP B ';
        v_sql := v_sql || '  WHERE A.COD_FILIAL = ''' || p_cod_estab || ''' ';
        v_sql := v_sql || '  AND A.PERIODO = ' || TO_CHAR ( p_periodo ) || ' ';
        v_sql := v_sql || '  AND NVL(A.VLR_PMC, 0) = 0 ';
        v_sql := v_sql || '  AND NVL(A.VLR_DESC_PMC, 0) > 0 ';
        v_sql := v_sql || '  AND B.COD_EMPRESA = MSAFI.DPSP.EMPRESA ';
        v_sql := v_sql || '  AND A.ECF_FAB IS NULL; '; --RETIRANDO CUPONS FISCAIS
        ---
        v_sql := v_sql || '  FORALL I IN TAB_MOV.FIRST .. TAB_MOV.LAST ';
        v_sql := v_sql || '     INSERT INTO ' || vp_tab_pmc || ' VALUES TAB_MOV(I); ';
        v_sql := v_sql || '  COMMIT; ';
        v_sql := v_sql || 'END; ';

        BEGIN
            EXECUTE IMMEDIATE v_sql;
        EXCEPTION
            WHEN OTHERS THEN
                v_msg_erro := SQLERRM;

                INSERT INTO msafi.log_geral ( ora_err_number1
                                            , ora_err_mesg1
                                            , cod_empresa
                                            , cod_estab
                                            , num_docfis
                                            , data_fiscal
                                            , serie_docfis
                                            , col14
                                            , col15
                                            , col16
                                            , num_item
                                            , col17
                                            , col18
                                            , col19
                                            , col20
                                            , col21
                                            , col22
                                            , movto_e_s
                                            , norm_dev
                                            , ident_docto
                                            , ident_fis_jur )
                     VALUES ( NULL
                            , v_msg_erro
                            , msafi.dpsp.empresa
                            , p_cod_estab
                            , NULL
                            , NULL
                            , NULL
                            , NULL
                            , 'SP'
                            , TO_CHAR ( p_periodo )
                            , ' '
                            , 'DPSP_FIN151_CAT42_FICHAS_CPROC'
                            , 'UPD_VLR_PMC 1'
                            , NULL
                            , NULL
                            , TO_CHAR ( SYSDATE
                                      , 'DD/MM/YYYY HH24:MI.SS' )
                            , vp_proc_id
                            , NULL
                            , NULL
                            , NULL
                            , NULL );

                COMMIT;
                raise_application_error ( -20042
                                        , 'ERRO UPD_VLR_PMC (A): ' || v_msg_erro );
        END;

        v_sql := 'DECLARE TYPE TT_TAB_PMC IS RECORD ( ';
        v_sql := v_sql || '                                  BUSINESS_UNIT VARCHAR2(8), ';
        v_sql := v_sql || '                                  NF_BRL_ID VARCHAR2(16), ';
        v_sql := v_sql || '                                  NUM_ITEM INTEGER, ';
        v_sql := v_sql || '                                  CHAVE_ACESSO VARCHAR2(80), ';
        v_sql := v_sql || '                                  MOVTO_E_S VARCHAR2(1), ';
        v_sql := v_sql || '                                  ROW_ID VARCHAR2(20), ';
        v_sql := v_sql || '                                  DSP_PMC NUMBER(15,4) ';
        v_sql := v_sql || '                                  ); ';
        v_sql := v_sql || '        TYPE T_TAB_PMC IS TABLE OF TT_TAB_PMC; ';
        v_sql := v_sql || '        TAB_PMC T_TAB_PMC; ';
        v_sql := v_sql || 'BEGIN ';
        v_sql := v_sql || '  DBMS_APPLICATION_INFO.SET_MODULE(''' || $$plsql_unit || ''', ''F4 UPD VLR PMC 2''); ';
        v_sql := v_sql || '  SELECT TMP.BUSINESS_UNIT, TMP.NF_BRL_ID, TMP.NUM_ITEM, ';
        v_sql := v_sql || '         TMP.CHAVE_ACESSO, TMP.MOVTO_E_S, TMP.ROWID, PS.DSP_PMC ';
        v_sql := v_sql || '  BULK COLLECT INTO TAB_PMC ';
        v_sql := v_sql || '  FROM ' || vp_tab_pmc || ' TMP, ';
        v_sql := v_sql || '        MSAFI.PS_NF_LN_BRL PS ';
        v_sql := v_sql || '  WHERE TMP.MOVTO_E_S <> ''9'' ';
        v_sql := v_sql || '    AND TMP.BUSINESS_UNIT = PS.BUSINESS_UNIT ';
        v_sql := v_sql || '    AND TMP.NF_BRL_ID     = PS.NF_BRL_ID ';
        v_sql := v_sql || '    AND TMP.NUM_ITEM      = PS.NF_BRL_LINE_NUM; ';
        --
        v_sql := v_sql || '  FORALL I IN TAB_PMC.FIRST .. TAB_PMC.LAST ';
        v_sql := v_sql || '    UPDATE MSAFI.' || p_tab_mov || ' SET VLR_PMC = TAB_PMC(I).DSP_PMC ';
        v_sql := v_sql || '    WHERE COD_FILIAL = ''' || p_cod_estab || ''' ';
        v_sql := v_sql || '      AND PERIODO = ' || TO_CHAR ( p_periodo ) || ' ';
        v_sql := v_sql || '      AND NVL(VLR_PMC, 0) = 0 ';
        v_sql := v_sql || '      AND NVL(VLR_DESC_PMC, 0) > 0 ';
        v_sql := v_sql || '      AND ECF_FAB IS NULL ';
        v_sql := v_sql || '      AND NF_BRL_ID = TAB_PMC(I).NF_BRL_ID ';
        v_sql := v_sql || '      AND NUM_ITEM  = TAB_PMC(I).NUM_ITEM ';
        v_sql := v_sql || '      AND CHV_DOC   = TAB_PMC(I).CHAVE_ACESSO ';
        v_sql := v_sql || '      AND MOVTO_E_S = TAB_PMC(I).MOVTO_E_S; ';
        v_sql := v_sql || '  COMMIT; ';
        v_sql := v_sql || 'END; ';

        BEGIN
            EXECUTE IMMEDIATE v_sql;
        EXCEPTION
            WHEN OTHERS THEN
                v_msg_erro := SQLERRM;

                INSERT INTO msafi.log_geral ( ora_err_number1
                                            , ora_err_mesg1
                                            , cod_empresa
                                            , cod_estab
                                            , num_docfis
                                            , data_fiscal
                                            , serie_docfis
                                            , col14
                                            , col15
                                            , col16
                                            , num_item
                                            , col17
                                            , col18
                                            , col19
                                            , col20
                                            , col21
                                            , col22
                                            , movto_e_s
                                            , norm_dev
                                            , ident_docto
                                            , ident_fis_jur )
                     VALUES ( NULL
                            , v_msg_erro
                            , msafi.dpsp.empresa
                            , p_cod_estab
                            , NULL
                            , NULL
                            , NULL
                            , NULL
                            , 'SP'
                            , TO_CHAR ( p_periodo )
                            , ' '
                            , 'DPSP_FIN151_CAT42_FICHAS_CPROC'
                            , 'UPD_VLR_PMC 2'
                            , NULL
                            , NULL
                            , TO_CHAR ( SYSDATE
                                      , 'DD/MM/YYYY HH24:MI.SS' )
                            , vp_proc_id
                            , NULL
                            , NULL
                            , NULL
                            , NULL );

                COMMIT;
                raise_application_error ( -20042
                                        , 'ERRO UPD_VLR_PMC (B): ' || v_msg_erro );
        END;

        v_sql := 'DECLARE TYPE TT_TAB_PMC2 IS RECORD ( ';
        v_sql := v_sql || '                                  BUSINESS_UNIT VARCHAR2(8), ';
        v_sql := v_sql || '                                  NF_BRL_ID VARCHAR2(16), ';
        v_sql := v_sql || '                                  NUM_ITEM INTEGER, ';
        v_sql := v_sql || '                                  CHAVE_ACESSO VARCHAR2(80), ';
        v_sql := v_sql || '                                  MOVTO_E_S VARCHAR2(1), ';
        v_sql := v_sql || '                                  ROWID VARCHAR2(20), ';
        v_sql := v_sql || '                                  DSP_PMC NUMBER(15,4) ';
        v_sql := v_sql || '                                  ); ';
        v_sql := v_sql || '        TYPE T_TAB_PMC2 IS TABLE OF TT_TAB_PMC2; ';
        v_sql := v_sql || '        TAB_PMC2 T_TAB_PMC2; ';
        v_sql := v_sql || 'BEGIN ';
        v_sql := v_sql || '  DBMS_APPLICATION_INFO.SET_MODULE(''' || $$plsql_unit || ''', ''F4 GET VLR PMC 3''); ';
        v_sql := v_sql || '  WITH TAB_TMP_PMC AS ( SELECT * FROM ' || vp_tab_pmc || ' ) ';
        v_sql := v_sql || '  SELECT PS.BUSINESS_UNIT, TMP.NF_BRL_ID, TMP.NUM_ITEM, ';
        v_sql := v_sql || '         TMP.CHAVE_ACESSO, TMP.MOVTO_E_S, TMP.ROWID, PS.DSP_PMC ';
        v_sql := v_sql || '  BULK COLLECT INTO TAB_PMC2 ';
        v_sql := v_sql || '  FROM TAB_TMP_PMC TMP, ';
        v_sql := v_sql || '       MSAFI.PS_DSP_NF_LN_BRL PS, ';
        v_sql := v_sql || '       MSAFI.PS_NF_HDR_BBL_FS A ';
        v_sql := v_sql || '  WHERE TMP.MOVTO_E_S      = ''9'' ';
        v_sql :=
               v_sql
            || '    AND PS.BUSINESS_UNIT   = REPLACE(REPLACE('''
            || p_cod_estab
            || ''',''DSP'',''VD''),''DS'',''L'') ';
        v_sql := v_sql || '    AND PS.NF_BRL_ID       = TMP.NF_BRL_ID ';
        v_sql := v_sql || '    AND PS.NF_BRL_LINE_NUM = TMP.NUM_ITEM ';
        v_sql := v_sql || '    AND A.NFEE_KEY_BBL     = TMP.CHAVE_ACESSO ';
        v_sql := v_sql || '    AND A.BUSINESS_UNIT    = PS.BUSINESS_UNIT ';
        v_sql := v_sql || '    AND A.NF_BRL_ID        = PS.NF_BRL_ID; ';
        --
        v_sql := v_sql || '  DBMS_APPLICATION_INFO.SET_MODULE(''' || $$plsql_unit || ''', ''F4 UPD VLR PMC 3''); ';
        v_sql := v_sql || '  FORALL I IN TAB_PMC2.FIRST .. TAB_PMC2.LAST ';
        v_sql := v_sql || '    UPDATE MSAFI.' || p_tab_mov || ' SET VLR_PMC = TAB_PMC2(I).DSP_PMC ';
        v_sql := v_sql || '    WHERE COD_FILIAL = ''' || p_cod_estab || ''' ';
        v_sql := v_sql || '      AND PERIODO = ' || TO_CHAR ( p_periodo ) || ' ';
        v_sql := v_sql || '      AND NVL(VLR_PMC, 0) = 0 ';
        v_sql := v_sql || '      AND NVL(VLR_DESC_PMC, 0) > 0 ';
        v_sql := v_sql || '      AND ECF_FAB IS NULL ';
        v_sql := v_sql || '      AND NF_BRL_ID = TAB_PMC2(I).NF_BRL_ID ';
        v_sql := v_sql || '      AND NUM_ITEM  = TAB_PMC2(I).NUM_ITEM ';
        v_sql := v_sql || '      AND CHV_DOC   = TAB_PMC2(I).CHAVE_ACESSO ';
        v_sql := v_sql || '      AND MOVTO_E_S = TAB_PMC2(I).MOVTO_E_S; ';
        v_sql := v_sql || '  COMMIT; ';
        v_sql := v_sql || 'END; ';

        BEGIN
            EXECUTE IMMEDIATE v_sql;
        EXCEPTION
            WHEN OTHERS THEN
                v_msg_erro := SQLERRM;

                INSERT INTO msafi.log_geral ( ora_err_number1
                                            , ora_err_mesg1
                                            , cod_empresa
                                            , cod_estab
                                            , num_docfis
                                            , data_fiscal
                                            , serie_docfis
                                            , col14
                                            , col15
                                            , col16
                                            , num_item
                                            , col17
                                            , col18
                                            , col19
                                            , col20
                                            , col21
                                            , col22
                                            , movto_e_s
                                            , norm_dev
                                            , ident_docto
                                            , ident_fis_jur )
                     VALUES ( NULL
                            , v_msg_erro
                            , msafi.dpsp.empresa
                            , p_cod_estab
                            , NULL
                            , NULL
                            , NULL
                            , NULL
                            , 'SP'
                            , TO_CHAR ( p_periodo )
                            , ' '
                            , 'DPSP_FIN151_CAT42_FICHAS_CPROC'
                            , 'UPD_VLR_PMC 3'
                            , NULL
                            , NULL
                            , TO_CHAR ( SYSDATE
                                      , 'DD/MM/YYYY HH24:MI.SS' )
                            , vp_proc_id
                            , NULL
                            , NULL
                            , NULL
                            , NULL );

                COMMIT;
                raise_application_error ( -20042
                                        , 'ERRO UPD_VLR_PMC (C): ' || v_msg_erro );
        END;
    END;

    PROCEDURE get_cd_to_loja_xml ( p_cod_estab IN VARCHAR2
                                 , pdt_periodo IN INTEGER
                                 , p_tab_mov IN VARCHAR2 )
    IS
        v_commit INTEGER := 0;
        v_count INTEGER := 0;
        v_sql VARCHAR2 ( 18000 );
        v_msg_erro VARCHAR2 ( 254 );
    BEGIN
        ---ENTRADA LOJAS SP ORIGEM DSP910
        dbms_application_info.set_module ( vg_module
                                         , 'F4 ENT LOJA <- CD910' );
        v_sql := 'DECLARE ';
        v_sql := v_sql || ' V_COUNT  INTEGER DEFAULT 0; ';
        v_sql := v_sql || ' V_COMMIT INTEGER DEFAULT 0; ';
        v_sql := v_sql || 'BEGIN ';
        v_sql := v_sql || 'FOR C IN ( ';
        v_sql := v_sql || '          WITH TAB_MOV AS ( ';
        v_sql :=
               v_sql
            || '                            SELECT C.ROWID, C.COD_PART, REPLACE(C.COD_PART,''DSP'',''VD'') AS BUSINESS_UNIT, ';
        v_sql := v_sql || '                                  C.NUM_ITEM AS NF_BRL_LINE_NUM, C.CHV_DOC ';
        v_sql := v_sql || '                            FROM MSAFI.' || p_tab_mov || ' C ';
        v_sql := v_sql || '                            WHERE C.COD_PART   = ''DSP910'' ';
        v_sql := v_sql || '                              AND C.COD_FILIAL = ''' || p_cod_estab || ''' ';
        v_sql := v_sql || '                              AND C.PERIODO    = ' || pdt_periodo || ' ';
        v_sql := v_sql || '                              AND C.MOVTO_E_S <> ''9'' ';
        v_sql := v_sql || '                          ) ';
        v_sql := v_sql || '            SELECT C.ROWID, C.COD_PART, C.BUSINESS_UNIT, ';
        v_sql := v_sql || '                 C.NF_BRL_LINE_NUM, C.CHV_DOC, X07.NUM_CONTROLE_DOCTO AS NF_BRL_ID ';
        v_sql := v_sql || '            FROM TAB_MOV C, ';
        v_sql := v_sql || '                 MSAF.X07_DOCTO_FISCAL X07 ';
        v_sql := v_sql || '            WHERE X07.COD_EMPRESA    = MSAFI.DPSP.EMPRESA ';
        v_sql := v_sql || '              AND X07.COD_ESTAB        = C.COD_PART ';
        v_sql := v_sql || '              AND X07.NUM_AUTENTIC_NFE = C.CHV_DOC ';
        v_sql := v_sql || '              AND X07.MOVTO_E_S        = ''9'' ';
        v_sql := v_sql || '        ) LOOP ';
        v_sql := v_sql || '   UPDATE MSAFI.' || p_tab_mov || ' D ';
        v_sql := v_sql || '     SET D.VLR_ICMS    = DECODE( ';
        v_sql := v_sql || '                             NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.ICMSTAX_BRL_AMT '; --PRIMEIRO PROCURAR NO PSFT
        v_sql := v_sql || '                                 FROM MSAFI.PS_NF_LN_BBL_FS TX ';
        v_sql := v_sql || '                                 WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_ID       = C.NF_BRL_ID), ';
        v_sql := v_sql || '                               0), ';
        v_sql := v_sql || '                               0, ';
        v_sql := v_sql || '                             NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.TAX_BRL_AMT '; --SEGUNDO PROCURAR NO XML DANFE
        v_sql := v_sql || '                               FROM MSAFI.PS_AR_IMP_BBL TX ';
        v_sql := v_sql || '                               WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                 AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                 AND TX.NF_BRL_ID       = C.NF_BRL_ID ';
        v_sql := v_sql || '                                 AND TX.TAX_ID_BBL      = ''ICMS''), ';
        v_sql := v_sql || '                             0), ';
        v_sql := v_sql || '                             NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.ICMSTAX_BRL_AMT ';
        v_sql := v_sql || '                                 FROM MSAFI.PS_NF_LN_BBL_FS TX ';
        v_sql := v_sql || '                                 WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_ID       = C.NF_BRL_ID), ';
        v_sql := v_sql || '                             0) ';
        v_sql := v_sql || '                         ), ';
        v_sql := v_sql || '         D.VLR_BASE_ICMS = DECODE( ';
        v_sql := v_sql || '                             NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.ICMSTAX_BRL_BSS '; --PRIMEIRO PROCURAR NO PSFT
        v_sql := v_sql || '                                 FROM MSAFI.PS_NF_LN_BBL_FS TX ';
        v_sql := v_sql || '                                 WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_ID       = C.NF_BRL_ID), ';
        v_sql := v_sql || '                               0), ';
        v_sql := v_sql || '                               0, ';
        v_sql := v_sql || '                             NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.TAX_BRL_BSE '; --SEGUNDO PROCURAR NO XML DANFE
        v_sql := v_sql || '                               FROM MSAFI.PS_AR_IMP_BBL TX ';
        v_sql := v_sql || '                               WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                 AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                 AND TX.NF_BRL_ID       = C.NF_BRL_ID ';
        v_sql := v_sql || '                                 AND TX.TAX_ID_BBL      = ''ICMS''), ';
        v_sql := v_sql || '                             0), ';
        v_sql := v_sql || '                             NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.ICMSTAX_BRL_BSS ';
        v_sql := v_sql || '                                 FROM MSAFI.PS_NF_LN_BBL_FS TX ';
        v_sql := v_sql || '                                 WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_ID       = C.NF_BRL_ID), ';
        v_sql := v_sql || '                             0) ';
        v_sql := v_sql || '                           ), ';
        v_sql := v_sql || '         D.ALIQ_ICMS  = DECODE( ';
        v_sql := v_sql || '                             NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.ICMSTAX_BRL_PCT '; --PRIMEIRO PROCURAR NO PSFT
        v_sql := v_sql || '                                 FROM MSAFI.PS_NF_LN_BBL_FS TX ';
        v_sql := v_sql || '                                 WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_ID       = C.NF_BRL_ID), ';
        v_sql := v_sql || '                               0), ';
        v_sql := v_sql || '                               0, ';
        v_sql := v_sql || '                             NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.TAX_BRL_PCT '; --SEGUNDO PROCURAR NO XML DANFE
        v_sql := v_sql || '                               FROM MSAFI.PS_AR_IMP_BBL TX ';
        v_sql := v_sql || '                               WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                 AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                 AND TX.NF_BRL_ID       = C.NF_BRL_ID ';
        v_sql := v_sql || '                                 AND TX.TAX_ID_BBL      = ''ICMS''), ';
        v_sql := v_sql || '                             0), ';
        v_sql := v_sql || '                             NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.ICMSTAX_BRL_PCT ';
        v_sql := v_sql || '                                 FROM MSAFI.PS_NF_LN_BBL_FS TX ';
        v_sql := v_sql || '                                 WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_ID       = C.NF_BRL_ID), ';
        v_sql := v_sql || '                             0) ';
        v_sql := v_sql || '                           ), ';
        v_sql := v_sql || '         D.VLR_ICMS_ST = DECODE( ';
        v_sql := v_sql || '                             NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.DSP_ICMS_AMT_ST '; --PRIMEIRO PROCURAR NO PSFT
        v_sql := v_sql || '                                 FROM MSAFI.PS_NF_LN_BBL_FS TX ';
        v_sql := v_sql || '                                 WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_ID       = C.NF_BRL_ID), ';
        v_sql := v_sql || '                               0), ';
        v_sql := v_sql || '                               0, ';
        v_sql := v_sql || '                             NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.TAX_BRL_AMT '; --SEGUNDO PROCURAR NO XML DANFE
        v_sql := v_sql || '                               FROM MSAFI.PS_AR_IMP_BBL TX ';
        v_sql := v_sql || '                               WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                 AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                 AND TX.NF_BRL_ID       = C.NF_BRL_ID ';
        v_sql := v_sql || '                                 AND TX.TAX_ID_BBL      = ''ICMST''), ';
        v_sql := v_sql || '                             0), ';
        v_sql := v_sql || '                             NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.DSP_ICMS_AMT_ST ';
        v_sql := v_sql || '                                 FROM MSAFI.PS_NF_LN_BBL_FS TX ';
        v_sql := v_sql || '                                 WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_ID       = C.NF_BRL_ID), ';
        v_sql := v_sql || '                             0) ';
        v_sql := v_sql || '                           ), ';
        v_sql := v_sql || '         D.VLR_BASE_ICMS_ST = DECODE( ';
        v_sql := v_sql || '                                   NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.DSP_ICMS_BSS_ST '; --PRIMEIRO PROCURAR NO PSFT
        v_sql := v_sql || '                                         FROM MSAFI.PS_NF_LN_BBL_FS TX ';
        v_sql := v_sql || '                                         WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                           AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                           AND TX.NF_BRL_ID       = C.NF_BRL_ID), ';
        v_sql := v_sql || '                                     0), ';
        v_sql := v_sql || '                                     0, ';
        v_sql := v_sql || '                                   NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.TAX_BRL_BSE '; --SEGUNDO PROCURAR NO XML DANFE
        v_sql := v_sql || '                                       FROM MSAFI.PS_AR_IMP_BBL TX ';
        v_sql := v_sql || '                                     WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                       AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                       AND TX.NF_BRL_ID       = C.NF_BRL_ID ';
        v_sql := v_sql || '                                       AND TX.TAX_ID_BBL      = ''ICMST''), ';
        v_sql := v_sql || '                                     0), ';
        v_sql := v_sql || '                                   NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.DSP_ICMS_BSS_ST ';
        v_sql := v_sql || '                                         FROM MSAFI.PS_NF_LN_BBL_FS TX ';
        v_sql := v_sql || '                                         WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                           AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                           AND TX.NF_BRL_ID       = C.NF_BRL_ID), ';
        v_sql := v_sql || '                                     0) ';
        v_sql := v_sql || '                               ), ';
        v_sql := v_sql || '         D.ORIGEM_ICMS  = ''L'', ';
        v_sql := v_sql || '         D.TAX_CONTROLE = ''B'' ';
        v_sql := v_sql || '   WHERE D.ROWID      = C.ROWID ';
        v_sql := v_sql || '     AND D.COD_FILIAL = ''' || p_cod_estab || ''' ';
        v_sql := v_sql || '     AND D.PERIODO    = ' || pdt_periodo || '; ';
        ---
        v_sql := v_sql || '   V_COMMIT := V_COMMIT + 1; ';
        v_sql := v_sql || '   IF (V_COMMIT = 100) THEN ';
        v_sql := v_sql || '     V_COUNT  := V_COUNT + V_COMMIT; ';
        v_sql := v_sql || '     V_COMMIT := 0; ';
        v_sql :=
               v_sql
            || '     DBMS_APPLICATION_INFO.SET_MODULE('''
            || vg_module
            || ''', ''F4 ENT LOJA <- CD910 ['' || V_COUNT || '']''); ';
        v_sql := v_sql || '     COMMIT; ';
        v_sql := v_sql || '   END IF; ';
        ---
        v_sql := v_sql || 'END LOOP; ';
        v_sql := v_sql || 'COMMIT; ';
        ---
        v_sql := v_sql || 'END; ';

        BEGIN
            EXECUTE IMMEDIATE v_sql;
        EXCEPTION
            WHEN OTHERS THEN
                v_msg_erro := SQLERRM;

                INSERT INTO msafi.log_geral ( ora_err_number1
                                            , ora_err_mesg1
                                            , cod_empresa
                                            , cod_estab
                                            , num_docfis
                                            , data_fiscal
                                            , serie_docfis
                                            , col14
                                            , col15
                                            , col16
                                            , num_item
                                            , col17
                                            , col18
                                            , col19
                                            , col20
                                            , col21
                                            , col22
                                            , movto_e_s
                                            , norm_dev
                                            , ident_docto
                                            , ident_fis_jur )
                     VALUES ( NULL
                            , v_msg_erro
                            , msafi.dpsp.empresa
                            , p_cod_estab
                            , NULL
                            , NULL
                            , NULL
                            , NULL
                            , 'SP'
                            , TO_CHAR ( pdt_periodo )
                            , ' '
                            , 'DPSP_FIN151_CAT42_FICHAS_CPROC'
                            , 'F4 ENT LOJA <- CD910'
                            , NULL
                            , NULL
                            , TO_CHAR ( SYSDATE
                                      , 'DD/MM/YYYY HH24:MI.SS' )
                            , p_tab_mov
                            , NULL
                            , NULL
                            , NULL
                            , NULL );

                COMMIT;
                raise_application_error ( -20040
                                        , 'ERRO F4 ENT LOJA <- CD910: ' || v_msg_erro );
        END;

        ---ENTRADA LOJAS SP ORIGEM DSP902
        dbms_application_info.set_module ( vg_module
                                         , 'F4 ENT LOJA <- CD902' );
        v_sql := 'DECLARE ';
        v_sql := v_sql || ' V_COUNT  INTEGER DEFAULT 0; ';
        v_sql := v_sql || ' V_COMMIT INTEGER DEFAULT 0; ';
        v_sql := v_sql || 'BEGIN ';
        v_sql := v_sql || 'FOR C IN ( ';
        v_sql := v_sql || '          WITH TAB_MOV AS ( ';
        v_sql :=
               v_sql
            || '                            SELECT /*+MATERIALIZE*/ C.ROWID, C.COD_PART, REPLACE(C.COD_PART,''DSP'',''VD'') AS BUSINESS_UNIT, ';
        v_sql := v_sql || '                                  C.NUM_ITEM AS NF_BRL_LINE_NUM, C.CHV_DOC ';
        v_sql := v_sql || '                            FROM MSAFI.' || p_tab_mov || ' C ';
        v_sql := v_sql || '                            WHERE C.COD_PART   = ''DSP902'' ';
        v_sql := v_sql || '                              AND C.COD_FILIAL = ''' || p_cod_estab || ''' ';
        v_sql := v_sql || '                              AND C.PERIODO    = ' || pdt_periodo || ' ';
        v_sql := v_sql || '                              AND C.MOVTO_E_S <> ''9'' ';
        v_sql := v_sql || '                          ) ';
        v_sql := v_sql || '            SELECT C.ROWID, C.COD_PART, C.BUSINESS_UNIT, ';
        v_sql := v_sql || '                 C.NF_BRL_LINE_NUM, C.CHV_DOC, X07.NUM_CONTROLE_DOCTO AS NF_BRL_ID ';
        v_sql := v_sql || '            FROM TAB_MOV C, ';
        v_sql := v_sql || '                 MSAF.X07_DOCTO_FISCAL X07 ';
        v_sql := v_sql || '            WHERE X07.COD_EMPRESA    = MSAFI.DPSP.EMPRESA ';
        v_sql := v_sql || '              AND X07.COD_ESTAB        = C.COD_PART ';
        v_sql := v_sql || '              AND X07.NUM_AUTENTIC_NFE = C.CHV_DOC ';
        v_sql := v_sql || '              AND X07.MOVTO_E_S        = ''9'' ';
        v_sql := v_sql || '        ) LOOP ';
        v_sql := v_sql || '   UPDATE MSAFI.' || p_tab_mov || ' D ';
        v_sql := v_sql || '     SET D.VLR_ICMS    = DECODE( ';
        v_sql := v_sql || '                             NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.ICMSTAX_BRL_AMT '; --PRIMEIRO PROCURAR NO PSFT
        v_sql := v_sql || '                                 FROM MSAFI.PS_NF_LN_BBL_FS TX ';
        v_sql := v_sql || '                                 WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_ID       = C.NF_BRL_ID), ';
        v_sql := v_sql || '                               0), ';
        v_sql := v_sql || '                               0, ';
        v_sql := v_sql || '                             NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.TAX_BRL_AMT '; --SEGUNDO PROCURAR NO XML DANFE
        v_sql := v_sql || '                               FROM MSAFI.PS_AR_IMP_BBL TX ';
        v_sql := v_sql || '                               WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                 AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                 AND TX.NF_BRL_ID       = C.NF_BRL_ID ';
        v_sql := v_sql || '                                 AND TX.TAX_ID_BBL      = ''ICMS''), ';
        v_sql := v_sql || '                             0), ';
        v_sql := v_sql || '                             NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.ICMSTAX_BRL_AMT ';
        v_sql := v_sql || '                                 FROM MSAFI.PS_NF_LN_BBL_FS TX ';
        v_sql := v_sql || '                                 WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_ID       = C.NF_BRL_ID), ';
        v_sql := v_sql || '                             0) ';
        v_sql := v_sql || '                         ), ';
        v_sql := v_sql || '         D.VLR_BASE_ICMS = DECODE( ';
        v_sql := v_sql || '                             NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.ICMSTAX_BRL_BSS '; --PRIMEIRO PROCURAR NO PSFT
        v_sql := v_sql || '                                 FROM MSAFI.PS_NF_LN_BBL_FS TX ';
        v_sql := v_sql || '                                 WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_ID       = C.NF_BRL_ID), ';
        v_sql := v_sql || '                               0), ';
        v_sql := v_sql || '                               0, ';
        v_sql := v_sql || '                             NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.TAX_BRL_BSE '; --SEGUNDO PROCURAR NO XML DANFE
        v_sql := v_sql || '                               FROM MSAFI.PS_AR_IMP_BBL TX ';
        v_sql := v_sql || '                               WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                 AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                 AND TX.NF_BRL_ID       = C.NF_BRL_ID ';
        v_sql := v_sql || '                                 AND TX.TAX_ID_BBL      = ''ICMS''), ';
        v_sql := v_sql || '                             0), ';
        v_sql := v_sql || '                             NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.ICMSTAX_BRL_BSS ';
        v_sql := v_sql || '                                 FROM MSAFI.PS_NF_LN_BBL_FS TX ';
        v_sql := v_sql || '                                 WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_ID       = C.NF_BRL_ID), ';
        v_sql := v_sql || '                             0) ';
        v_sql := v_sql || '                           ), ';
        v_sql := v_sql || '         D.ALIQ_ICMS  = DECODE( ';
        v_sql := v_sql || '                             NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.ICMSTAX_BRL_PCT '; --PRIMEIRO PROCURAR NO PSFT
        v_sql := v_sql || '                                 FROM MSAFI.PS_NF_LN_BBL_FS TX ';
        v_sql := v_sql || '                                 WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_ID       = C.NF_BRL_ID), ';
        v_sql := v_sql || '                               0), ';
        v_sql := v_sql || '                               0, ';
        v_sql := v_sql || '                             NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.TAX_BRL_PCT '; --SEGUNDO PROCURAR NO XML DANFE
        v_sql := v_sql || '                               FROM MSAFI.PS_AR_IMP_BBL TX ';
        v_sql := v_sql || '                               WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                 AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                 AND TX.NF_BRL_ID       = C.NF_BRL_ID ';
        v_sql := v_sql || '                                 AND TX.TAX_ID_BBL      = ''ICMS''), ';
        v_sql := v_sql || '                             0), ';
        v_sql := v_sql || '                             NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.ICMSTAX_BRL_PCT ';
        v_sql := v_sql || '                                 FROM MSAFI.PS_NF_LN_BBL_FS TX ';
        v_sql := v_sql || '                                 WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_ID       = C.NF_BRL_ID), ';
        v_sql := v_sql || '                             0) ';
        v_sql := v_sql || '                           ), ';
        v_sql := v_sql || '         D.VLR_ICMS_ST = DECODE( ';
        v_sql := v_sql || '                             NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.DSP_ICMS_AMT_ST '; --PRIMEIRO PROCURAR NO PSFT
        v_sql := v_sql || '                                 FROM MSAFI.PS_NF_LN_BBL_FS TX ';
        v_sql := v_sql || '                                 WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_ID       = C.NF_BRL_ID), ';
        v_sql := v_sql || '                               0), ';
        v_sql := v_sql || '                               0, ';
        v_sql := v_sql || '                             NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.TAX_BRL_AMT '; --SEGUNDO PROCURAR NO XML DANFE
        v_sql := v_sql || '                               FROM MSAFI.PS_AR_IMP_BBL TX ';
        v_sql := v_sql || '                               WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                 AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                 AND TX.NF_BRL_ID       = C.NF_BRL_ID ';
        v_sql := v_sql || '                                 AND TX.TAX_ID_BBL      = ''ICMST''), ';
        v_sql := v_sql || '                             0), ';
        v_sql := v_sql || '                             NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.DSP_ICMS_AMT_ST ';
        v_sql := v_sql || '                                 FROM MSAFI.PS_NF_LN_BBL_FS TX ';
        v_sql := v_sql || '                                 WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_ID       = C.NF_BRL_ID), ';
        v_sql := v_sql || '                             0) ';
        v_sql := v_sql || '                           ), ';
        v_sql := v_sql || '         D.VLR_BASE_ICMS_ST = DECODE( ';
        v_sql := v_sql || '                                   NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.DSP_ICMS_BSS_ST '; --PRIMEIRO PROCURAR NO PSFT
        v_sql := v_sql || '                                         FROM MSAFI.PS_NF_LN_BBL_FS TX ';
        v_sql := v_sql || '                                         WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                           AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                           AND TX.NF_BRL_ID       = C.NF_BRL_ID), ';
        v_sql := v_sql || '                                     0), ';
        v_sql := v_sql || '                                     0, ';
        v_sql := v_sql || '                                   NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.TAX_BRL_BSE '; --SEGUNDO PROCURAR NO XML DANFE
        v_sql := v_sql || '                                       FROM MSAFI.PS_AR_IMP_BBL TX ';
        v_sql := v_sql || '                                     WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                       AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                       AND TX.NF_BRL_ID       = C.NF_BRL_ID ';
        v_sql := v_sql || '                                       AND TX.TAX_ID_BBL      = ''ICMST''), ';
        v_sql := v_sql || '                                     0), ';
        v_sql := v_sql || '                                   NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.DSP_ICMS_BSS_ST ';
        v_sql := v_sql || '                                         FROM MSAFI.PS_NF_LN_BBL_FS TX ';
        v_sql := v_sql || '                                         WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                           AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                           AND TX.NF_BRL_ID       = C.NF_BRL_ID), ';
        v_sql := v_sql || '                                     0) ';
        v_sql := v_sql || '                               ), ';
        v_sql := v_sql || '         D.ORIGEM_ICMS  = ''L'', ';
        v_sql := v_sql || '         D.TAX_CONTROLE = ''B'' ';
        v_sql := v_sql || '   WHERE D.ROWID      = C.ROWID ';
        v_sql := v_sql || '     AND D.COD_FILIAL = ''' || p_cod_estab || ''' ';
        v_sql := v_sql || '     AND D.PERIODO    = ' || pdt_periodo || '; ';
        ---
        v_sql := v_sql || '   V_COMMIT := V_COMMIT + 1; ';
        v_sql := v_sql || '   IF (V_COMMIT = 100) THEN ';
        v_sql := v_sql || '     V_COUNT  := V_COUNT + V_COMMIT; ';
        v_sql := v_sql || '     V_COMMIT := 0; ';
        v_sql :=
               v_sql
            || '     DBMS_APPLICATION_INFO.SET_MODULE('''
            || vg_module
            || ''', ''F4 ENT LOJA <- CD902 ['' || V_COUNT || '']''); ';
        v_sql := v_sql || '     COMMIT; ';
        v_sql := v_sql || '   END IF; ';
        ---
        v_sql := v_sql || 'END LOOP; ';
        v_sql := v_sql || 'COMMIT; ';
        ---
        v_sql := v_sql || 'END; ';

        BEGIN
            EXECUTE IMMEDIATE v_sql;
        EXCEPTION
            WHEN OTHERS THEN
                v_msg_erro := SQLERRM;

                INSERT INTO msafi.log_geral ( ora_err_number1
                                            , ora_err_mesg1
                                            , cod_empresa
                                            , cod_estab
                                            , num_docfis
                                            , data_fiscal
                                            , serie_docfis
                                            , col14
                                            , col15
                                            , col16
                                            , num_item
                                            , col17
                                            , col18
                                            , col19
                                            , col20
                                            , col21
                                            , col22
                                            , movto_e_s
                                            , norm_dev
                                            , ident_docto
                                            , ident_fis_jur )
                     VALUES ( NULL
                            , v_msg_erro
                            , msafi.dpsp.empresa
                            , p_cod_estab
                            , NULL
                            , NULL
                            , NULL
                            , NULL
                            , 'SP'
                            , TO_CHAR ( pdt_periodo )
                            , ' '
                            , 'DPSP_FIN151_CAT42_FICHAS_CPROC'
                            , 'F4 ENT LOJA <- CD902'
                            , NULL
                            , NULL
                            , TO_CHAR ( SYSDATE
                                      , 'DD/MM/YYYY HH24:MI.SS' )
                            , p_tab_mov
                            , NULL
                            , NULL
                            , NULL
                            , NULL );

                COMMIT;
                raise_application_error ( -20040
                                        , 'ERRO F4 ENT LOJA <- CD902: ' || v_msg_erro );
        END;

        ---ENTRADA LOJAS SP ORIGEM DSP901
        dbms_application_info.set_module ( vg_module
                                         , 'F4 ENT LOJA <- CD901' );
        v_sql := 'DECLARE ';
        v_sql := v_sql || ' V_COUNT  INTEGER DEFAULT 0; ';
        v_sql := v_sql || ' V_COMMIT INTEGER DEFAULT 0; ';
        v_sql := v_sql || 'BEGIN ';
        v_sql := v_sql || 'FOR C IN ( ';
        v_sql := v_sql || '          WITH TAB_MOV AS ( ';
        v_sql :=
               v_sql
            || '                            SELECT /*+MATERIALIZE*/ C.ROWID, C.COD_PART, REPLACE(C.COD_PART,''DSP'',''VD'') AS BUSINESS_UNIT, ';
        v_sql := v_sql || '                                  C.NUM_ITEM AS NF_BRL_LINE_NUM, C.CHV_DOC ';
        v_sql := v_sql || '                            FROM MSAFI.' || p_tab_mov || ' C ';
        v_sql := v_sql || '                            WHERE C.COD_PART   = ''DSP901'' ';
        v_sql := v_sql || '                              AND C.COD_FILIAL = ''' || p_cod_estab || ''' ';
        v_sql := v_sql || '                              AND C.PERIODO    = ' || pdt_periodo || ' ';
        v_sql := v_sql || '                              AND C.MOVTO_E_S <> ''9'' ';
        v_sql := v_sql || '                          ) ';
        v_sql := v_sql || '            SELECT C.ROWID, C.COD_PART, C.BUSINESS_UNIT, ';
        v_sql := v_sql || '                 C.NF_BRL_LINE_NUM, C.CHV_DOC, X07.NUM_CONTROLE_DOCTO AS NF_BRL_ID ';
        v_sql := v_sql || '            FROM TAB_MOV C, ';
        v_sql := v_sql || '                 MSAF.X07_DOCTO_FISCAL X07 ';
        v_sql := v_sql || '            WHERE X07.COD_EMPRESA    = MSAFI.DPSP.EMPRESA ';
        v_sql := v_sql || '              AND X07.COD_ESTAB        = C.COD_PART ';
        v_sql := v_sql || '              AND X07.NUM_AUTENTIC_NFE = C.CHV_DOC ';
        v_sql := v_sql || '              AND X07.MOVTO_E_S        = ''9'' ';
        v_sql := v_sql || '        ) LOOP ';
        v_sql := v_sql || '   UPDATE MSAFI.' || p_tab_mov || ' D ';
        v_sql := v_sql || '     SET D.VLR_ICMS    = DECODE( ';
        v_sql := v_sql || '                             NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.ICMSTAX_BRL_AMT '; --PRIMEIRO PROCURAR NO PSFT
        v_sql := v_sql || '                                 FROM MSAFI.PS_NF_LN_BBL_FS TX ';
        v_sql := v_sql || '                                 WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_ID       = C.NF_BRL_ID), ';
        v_sql := v_sql || '                               0), ';
        v_sql := v_sql || '                               0, ';
        v_sql := v_sql || '                             NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.TAX_BRL_AMT '; --SEGUNDO PROCURAR NO XML DANFE
        v_sql := v_sql || '                               FROM MSAFI.PS_AR_IMP_BBL TX ';
        v_sql := v_sql || '                               WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                 AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                 AND TX.NF_BRL_ID       = C.NF_BRL_ID ';
        v_sql := v_sql || '                                 AND TX.TAX_ID_BBL      = ''ICMS''), ';
        v_sql := v_sql || '                             0), ';
        v_sql := v_sql || '                             NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.ICMSTAX_BRL_AMT ';
        v_sql := v_sql || '                                 FROM MSAFI.PS_NF_LN_BBL_FS TX ';
        v_sql := v_sql || '                                 WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_ID       = C.NF_BRL_ID), ';
        v_sql := v_sql || '                             0) ';
        v_sql := v_sql || '                         ), ';
        v_sql := v_sql || '         D.VLR_BASE_ICMS = DECODE( ';
        v_sql := v_sql || '                             NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.ICMSTAX_BRL_BSS '; --PRIMEIRO PROCURAR NO PSFT
        v_sql := v_sql || '                                 FROM MSAFI.PS_NF_LN_BBL_FS TX ';
        v_sql := v_sql || '                                 WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_ID       = C.NF_BRL_ID), ';
        v_sql := v_sql || '                               0), ';
        v_sql := v_sql || '                               0, ';
        v_sql := v_sql || '                             NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.TAX_BRL_BSE '; --SEGUNDO PROCURAR NO XML DANFE
        v_sql := v_sql || '                               FROM MSAFI.PS_AR_IMP_BBL TX ';
        v_sql := v_sql || '                               WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                 AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                 AND TX.NF_BRL_ID       = C.NF_BRL_ID ';
        v_sql := v_sql || '                                 AND TX.TAX_ID_BBL      = ''ICMS''), ';
        v_sql := v_sql || '                             0), ';
        v_sql := v_sql || '                             NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.ICMSTAX_BRL_BSS ';
        v_sql := v_sql || '                                 FROM MSAFI.PS_NF_LN_BBL_FS TX ';
        v_sql := v_sql || '                                 WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_ID       = C.NF_BRL_ID), ';
        v_sql := v_sql || '                             0) ';
        v_sql := v_sql || '                           ), ';
        v_sql := v_sql || '         D.ALIQ_ICMS  = DECODE( ';
        v_sql := v_sql || '                             NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.ICMSTAX_BRL_PCT '; --PRIMEIRO PROCURAR NO PSFT
        v_sql := v_sql || '                                 FROM MSAFI.PS_NF_LN_BBL_FS TX ';
        v_sql := v_sql || '                                 WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_ID       = C.NF_BRL_ID), ';
        v_sql := v_sql || '                               0), ';
        v_sql := v_sql || '                               0, ';
        v_sql := v_sql || '                             NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.TAX_BRL_PCT '; --SEGUNDO PROCURAR NO XML DANFE
        v_sql := v_sql || '                               FROM MSAFI.PS_AR_IMP_BBL TX ';
        v_sql := v_sql || '                               WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                 AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                 AND TX.NF_BRL_ID       = C.NF_BRL_ID ';
        v_sql := v_sql || '                                 AND TX.TAX_ID_BBL      = ''ICMS''), ';
        v_sql := v_sql || '                             0), ';
        v_sql := v_sql || '                             NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.ICMSTAX_BRL_PCT ';
        v_sql := v_sql || '                                 FROM MSAFI.PS_NF_LN_BBL_FS TX ';
        v_sql := v_sql || '                                 WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_ID       = C.NF_BRL_ID), ';
        v_sql := v_sql || '                             0) ';
        v_sql := v_sql || '                           ), ';
        v_sql := v_sql || '         D.VLR_ICMS_ST = DECODE( ';
        v_sql := v_sql || '                             NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.DSP_ICMS_AMT_ST '; --PRIMEIRO PROCURAR NO PSFT
        v_sql := v_sql || '                                 FROM MSAFI.PS_NF_LN_BBL_FS TX ';
        v_sql := v_sql || '                                 WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_ID       = C.NF_BRL_ID), ';
        v_sql := v_sql || '                               0), ';
        v_sql := v_sql || '                               0, ';
        v_sql := v_sql || '                             NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.TAX_BRL_AMT '; --SEGUNDO PROCURAR NO XML DANFE
        v_sql := v_sql || '                               FROM MSAFI.PS_AR_IMP_BBL TX ';
        v_sql := v_sql || '                               WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                 AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                 AND TX.NF_BRL_ID       = C.NF_BRL_ID ';
        v_sql := v_sql || '                                 AND TX.TAX_ID_BBL      = ''ICMST''), ';
        v_sql := v_sql || '                             0), ';
        v_sql := v_sql || '                             NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.DSP_ICMS_AMT_ST ';
        v_sql := v_sql || '                                 FROM MSAFI.PS_NF_LN_BBL_FS TX ';
        v_sql := v_sql || '                                 WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_ID       = C.NF_BRL_ID), ';
        v_sql := v_sql || '                             0) ';
        v_sql := v_sql || '                           ), ';
        v_sql := v_sql || '         D.VLR_BASE_ICMS_ST = DECODE( ';
        v_sql := v_sql || '                                   NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.DSP_ICMS_BSS_ST '; --PRIMEIRO PROCURAR NO PSFT
        v_sql := v_sql || '                                         FROM MSAFI.PS_NF_LN_BBL_FS TX ';
        v_sql := v_sql || '                                         WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                           AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                           AND TX.NF_BRL_ID       = C.NF_BRL_ID), ';
        v_sql := v_sql || '                                     0), ';
        v_sql := v_sql || '                                     0, ';
        v_sql := v_sql || '                                   NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.TAX_BRL_BSE '; --SEGUNDO PROCURAR NO XML DANFE
        v_sql := v_sql || '                                       FROM MSAFI.PS_AR_IMP_BBL TX ';
        v_sql := v_sql || '                                     WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                       AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                       AND TX.NF_BRL_ID       = C.NF_BRL_ID ';
        v_sql := v_sql || '                                       AND TX.TAX_ID_BBL      = ''ICMST''), ';
        v_sql := v_sql || '                                     0), ';
        v_sql := v_sql || '                                   NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.DSP_ICMS_BSS_ST ';
        v_sql := v_sql || '                                         FROM MSAFI.PS_NF_LN_BBL_FS TX ';
        v_sql := v_sql || '                                         WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                           AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                           AND TX.NF_BRL_ID       = C.NF_BRL_ID), ';
        v_sql := v_sql || '                                     0) ';
        v_sql := v_sql || '                               ), ';
        v_sql := v_sql || '         D.ORIGEM_ICMS  = ''L'', ';
        v_sql := v_sql || '         D.TAX_CONTROLE = ''B'' ';
        v_sql := v_sql || '   WHERE D.ROWID      = C.ROWID ';
        v_sql := v_sql || '     AND D.COD_FILIAL = ''' || p_cod_estab || ''' ';
        v_sql := v_sql || '     AND D.PERIODO    = ' || pdt_periodo || '; ';
        ---
        v_sql := v_sql || '   V_COMMIT := V_COMMIT + 1; ';
        v_sql := v_sql || '   IF (V_COMMIT = 100) THEN ';
        v_sql := v_sql || '     V_COUNT  := V_COUNT + V_COMMIT; ';
        v_sql := v_sql || '     V_COMMIT := 0; ';
        v_sql :=
               v_sql
            || '     DBMS_APPLICATION_INFO.SET_MODULE('''
            || vg_module
            || ''', ''F4 ENT LOJA <- CD901 ['' || V_COUNT || '']''); ';
        v_sql := v_sql || '     COMMIT; ';
        v_sql := v_sql || '   END IF; ';
        ---
        v_sql := v_sql || 'END LOOP; ';
        v_sql := v_sql || 'COMMIT; ';
        ---
        v_sql := v_sql || 'END; ';

        BEGIN
            EXECUTE IMMEDIATE v_sql;
        EXCEPTION
            WHEN OTHERS THEN
                v_msg_erro := SQLERRM;

                INSERT INTO msafi.log_geral ( ora_err_number1
                                            , ora_err_mesg1
                                            , cod_empresa
                                            , cod_estab
                                            , num_docfis
                                            , data_fiscal
                                            , serie_docfis
                                            , col14
                                            , col15
                                            , col16
                                            , num_item
                                            , col17
                                            , col18
                                            , col19
                                            , col20
                                            , col21
                                            , col22
                                            , movto_e_s
                                            , norm_dev
                                            , ident_docto
                                            , ident_fis_jur )
                     VALUES ( NULL
                            , v_msg_erro
                            , msafi.dpsp.empresa
                            , p_cod_estab
                            , NULL
                            , NULL
                            , NULL
                            , NULL
                            , 'SP'
                            , TO_CHAR ( pdt_periodo )
                            , ' '
                            , 'DPSP_FIN151_CAT42_FICHAS_CPROC'
                            , 'F4 ENT LOJA <- CD901'
                            , NULL
                            , NULL
                            , TO_CHAR ( SYSDATE
                                      , 'DD/MM/YYYY HH24:MI.SS' )
                            , p_tab_mov
                            , NULL
                            , NULL
                            , NULL
                            , NULL );

                COMMIT;
                raise_application_error ( -20040
                                        , 'ERRO F4 ENT LOJA <- CD901: ' || v_msg_erro );
        END;

        ------------------------------------------------------------------------------------------------

        ---SAIDA DA LOJA PARA OUTRA LOJA
        dbms_application_info.set_module ( vg_module
                                         , 'F4 SAI LOJA -> LOJA' );
        v_sql := 'DECLARE ';
        v_sql := v_sql || ' V_COUNT  INTEGER DEFAULT 0; ';
        v_sql := v_sql || ' V_COMMIT INTEGER DEFAULT 0; ';
        v_sql := v_sql || 'BEGIN ';
        v_sql := v_sql || 'FOR C IN (SELECT  ';
        v_sql := v_sql || '           C.ROWID, C.BUSINESS_UNIT, C.NF_BRL_ID, C.NUM_ITEM AS NF_BRL_LINE_NUM ';
        v_sql := v_sql || '            FROM MSAFI.' || p_tab_mov || ' C ';
        v_sql :=
               v_sql
            || '           WHERE C.COD_PART   IN (SELECT COD_ESTAB FROM MSAFI.DSP_ESTABELECIMENTO WHERE COD_EMPRESA = MSAFI.DPSP.EMPRESA AND TIPO = ''L'')  ';
        v_sql := v_sql || '             AND C.COD_FILIAL = ''' || p_cod_estab || ''' ';
        v_sql := v_sql || '             AND C.PERIODO    = ' || pdt_periodo || ' ';
        v_sql := v_sql || '             AND C.MOVTO_E_S  = ''9'' ';
        v_sql := v_sql || '             AND CFOP         = ''5409'' ';
        v_sql := v_sql || '          ) LOOP ';
        ---
        v_sql := v_sql || '  UPDATE MSAFI.' || p_tab_mov || ' D ';
        v_sql := v_sql || '     SET D.VLR_ICMS    = DECODE( ';
        v_sql := v_sql || '                            NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.ICMSTAX_BRL_AMT  '; --PRIMEIRO PROCURAR NO PSFT
        v_sql := v_sql || '                                 FROM MSAFI.PS_NF_LN_BBL_FS TX ';
        v_sql := v_sql || '                                 WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_ID       = C.NF_BRL_ID), ';
        v_sql := v_sql || '                              0), ';
        v_sql := v_sql || '                              0, ';
        v_sql := v_sql || '                            NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.TAX_BRL_AMT '; --SEGUNDO PROCURAR NO XML DANFE
        v_sql := v_sql || '                               FROM MSAFI.PS_AR_IMP_BBL TX ';
        v_sql := v_sql || '                              WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                AND TX.NF_BRL_ID       = C.NF_BRL_ID ';
        v_sql := v_sql || '                                AND TX.TAX_ID_BBL      = ''ICMS''), ';
        v_sql := v_sql || '                             0), ';
        v_sql := v_sql || '                            NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.ICMSTAX_BRL_AMT ';
        v_sql := v_sql || '                                 FROM MSAFI.PS_NF_LN_BBL_FS TX ';
        v_sql := v_sql || '                                 WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_ID       = C.NF_BRL_ID), ';
        v_sql := v_sql || '                             0) ';
        v_sql := v_sql || '                        ), ';
        v_sql := v_sql || '         D.VLR_BASE_ICMS = DECODE( ';
        v_sql := v_sql || '                            NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.ICMSTAX_BRL_BSS '; --PRIMEIRO PROCURAR NO PSFT
        v_sql := v_sql || '                                 FROM MSAFI.PS_NF_LN_BBL_FS TX ';
        v_sql := v_sql || '                                 WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_ID       = C.NF_BRL_ID), ';
        v_sql := v_sql || '                              0), ';
        v_sql := v_sql || '                              0, ';
        v_sql := v_sql || '                            NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.TAX_BRL_BSE '; --SEGUNDO PROCURAR NO XML DANFE
        v_sql := v_sql || '                               FROM MSAFI.PS_AR_IMP_BBL TX ';
        v_sql := v_sql || '                              WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                AND TX.NF_BRL_ID       = C.NF_BRL_ID ';
        v_sql := v_sql || '                                AND TX.TAX_ID_BBL      = ''ICMS''), ';
        v_sql := v_sql || '                             0), ';
        v_sql := v_sql || '                            NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.ICMSTAX_BRL_BSS ';
        v_sql := v_sql || '                                 FROM MSAFI.PS_NF_LN_BBL_FS TX ';
        v_sql := v_sql || '                                 WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_ID       = C.NF_BRL_ID), ';
        v_sql := v_sql || '                             0) ';
        v_sql := v_sql || '                          ), ';
        v_sql := v_sql || '         D.ALIQ_ICMS  = DECODE( ';
        v_sql := v_sql || '                            NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.ICMSTAX_BRL_PCT '; --PRIMEIRO PROCURAR NO PSFT
        v_sql := v_sql || '                                 FROM MSAFI.PS_NF_LN_BBL_FS TX ';
        v_sql := v_sql || '                                 WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_ID       = C.NF_BRL_ID), ';
        v_sql := v_sql || '                              0), ';
        v_sql := v_sql || '                              0, ';
        v_sql := v_sql || '                            NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.TAX_BRL_PCT '; --SEGUNDO PROCURAR NO XML DANFE
        v_sql := v_sql || '                               FROM MSAFI.PS_AR_IMP_BBL TX ';
        v_sql := v_sql || '                              WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                AND TX.NF_BRL_ID       = C.NF_BRL_ID ';
        v_sql := v_sql || '                                AND TX.TAX_ID_BBL      = ''ICMS''), ';
        v_sql := v_sql || '                             0), ';
        v_sql := v_sql || '                            NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.ICMSTAX_BRL_PCT ';
        v_sql := v_sql || '                                 FROM MSAFI.PS_NF_LN_BBL_FS TX ';
        v_sql := v_sql || '                                 WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_ID       = C.NF_BRL_ID), ';
        v_sql := v_sql || '                             0) ';
        v_sql := v_sql || '                          ), ';
        v_sql := v_sql || '         D.VLR_ICMS_ST = DECODE( ';
        v_sql := v_sql || '                            NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.DSP_ICMS_AMT_ST '; --PRIMEIRO PROCURAR NO PSFT
        v_sql := v_sql || '                                 FROM MSAFI.PS_NF_LN_BBL_FS TX ';
        v_sql := v_sql || '                                 WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_ID       = C.NF_BRL_ID), ';
        v_sql := v_sql || '                              0), ';
        v_sql := v_sql || '                              0, ';
        v_sql := v_sql || '                            NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.TAX_BRL_AMT '; --SEGUNDO PROCURAR NO XML DANFE
        v_sql := v_sql || '                               FROM MSAFI.PS_AR_IMP_BBL TX ';
        v_sql := v_sql || '                              WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                AND TX.NF_BRL_ID       = C.NF_BRL_ID ';
        v_sql := v_sql || '                                AND TX.TAX_ID_BBL      = ''ICMST''), ';
        v_sql := v_sql || '                             0), ';
        v_sql := v_sql || '                            NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.DSP_ICMS_AMT_ST ';
        v_sql := v_sql || '                                 FROM MSAFI.PS_NF_LN_BBL_FS TX ';
        v_sql := v_sql || '                                 WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                   AND TX.NF_BRL_ID       = C.NF_BRL_ID), ';
        v_sql := v_sql || '                             0) ';
        v_sql := v_sql || '                          ), ';
        v_sql := v_sql || '         D.VLR_BASE_ICMS_ST = DECODE( ';
        v_sql := v_sql || '                                   NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.DSP_ICMS_BSS_ST '; --PRIMEIRO PROCURAR NO PSFT
        v_sql := v_sql || '                                        FROM MSAFI.PS_NF_LN_BBL_FS TX ';
        v_sql := v_sql || '                                        WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                          AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                          AND TX.NF_BRL_ID       = C.NF_BRL_ID), ';
        v_sql := v_sql || '                                     0), ';
        v_sql := v_sql || '                                     0, ';
        v_sql := v_sql || '                                   NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.TAX_BRL_BSE '; --SEGUNDO PROCURAR NO XML DANFE
        v_sql := v_sql || '                                      FROM MSAFI.PS_AR_IMP_BBL TX ';
        v_sql := v_sql || '                                     WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                       AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                       AND TX.NF_BRL_ID       = C.NF_BRL_ID ';
        v_sql := v_sql || '                                       AND TX.TAX_ID_BBL      = ''ICMST''), ';
        v_sql := v_sql || '                                    0), ';
        v_sql := v_sql || '                                   NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.DSP_ICMS_BSS_ST ';
        v_sql := v_sql || '                                        FROM MSAFI.PS_NF_LN_BBL_FS TX ';
        v_sql := v_sql || '                                        WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                          AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                          AND TX.NF_BRL_ID       = C.NF_BRL_ID), ';
        v_sql := v_sql || '                                    0) ';
        v_sql := v_sql || '                              ), ';
        v_sql := v_sql || '         D.ORIGEM_ICMS  = ''L'', ';
        v_sql := v_sql || '         D.TAX_CONTROLE = ''C'' ';
        v_sql := v_sql || '  WHERE ROWID = C.ROWID; ';
        ---
        v_sql := v_sql || '  V_COMMIT := V_COMMIT + 1; ';
        v_sql := v_sql || '  IF (V_COMMIT = 100) THEN ';
        v_sql := v_sql || '    V_COUNT  := V_COUNT + V_COMMIT; ';
        v_sql := v_sql || '    V_COMMIT := 0; ';
        v_sql :=
               v_sql
            || '    DBMS_APPLICATION_INFO.SET_MODULE('''
            || vg_module
            || ''', ''F4 SAI LOJA -> LOJA ['' || V_COUNT || '']''); ';
        v_sql := v_sql || '    COMMIT; ';
        v_sql := v_sql || '  END IF; ';
        ---
        v_sql := v_sql || 'END LOOP; ';
        v_sql := v_sql || 'COMMIT; ';
        v_sql := v_sql || 'END; ';

        BEGIN
            EXECUTE IMMEDIATE v_sql;
        EXCEPTION
            WHEN OTHERS THEN
                v_msg_erro := SQLERRM;

                INSERT INTO msafi.log_geral ( ora_err_number1
                                            , ora_err_mesg1
                                            , cod_empresa
                                            , cod_estab
                                            , num_docfis
                                            , data_fiscal
                                            , serie_docfis
                                            , col14
                                            , col15
                                            , col16
                                            , num_item
                                            , col17
                                            , col18
                                            , col19
                                            , col20
                                            , col21
                                            , col22
                                            , movto_e_s
                                            , norm_dev
                                            , ident_docto
                                            , ident_fis_jur )
                     VALUES ( NULL
                            , v_msg_erro
                            , msafi.dpsp.empresa
                            , p_cod_estab
                            , NULL
                            , NULL
                            , NULL
                            , NULL
                            , 'SP'
                            , TO_CHAR ( pdt_periodo )
                            , ' '
                            , 'DPSP_FIN151_CAT42_FICHAS_CPROC'
                            , 'F4 SAI LOJA -> LOJA'
                            , NULL
                            , NULL
                            , TO_CHAR ( SYSDATE
                                      , 'DD/MM/YYYY HH24:MI.SS' )
                            , p_tab_mov
                            , NULL
                            , NULL
                            , NULL
                            , NULL );

                COMMIT;
                raise_application_error ( -20040
                                        , 'ERRO F4 SAI LOJA -> LOJA: ' || v_msg_erro );
        END;

        ------------------------------------------------------------------------------------------------

        ---ENTRADA LOJAS SP ORIGEM LOJA
        dbms_application_info.set_module ( vg_module
                                         , 'F4 ENT LOJA <- LOJA' );
        v_sql := 'DECLARE ';
        v_sql := v_sql || ' V_COUNT  INTEGER DEFAULT 0; ';
        v_sql := v_sql || ' V_COMMIT INTEGER DEFAULT 0; ';
        v_sql := v_sql || 'BEGIN ';
        v_sql := v_sql || 'FOR C IN (SELECT C.ROWID, C.COD_PART, REPLACE(C.COD_PART,''DSP'',''VD'') AS BUSINESS_UNIT, ';
        v_sql := v_sql || '                 C.NUM_ITEM AS NF_BRL_LINE_NUM, C.CHV_DOC AS CHAVE_ACESSO ';
        v_sql := v_sql || '            FROM MSAFI.' || p_tab_mov || ' C ';
        v_sql :=
               v_sql
            || '           WHERE C.COD_PART   IN (SELECT COD_ESTAB FROM MSAFI.DSP_ESTABELECIMENTO WHERE COD_EMPRESA = MSAFI.DPSP.EMPRESA AND TIPO = ''L'')  ';
        v_sql := v_sql || '             AND C.COD_FILIAL = ''' || p_cod_estab || ''' ';
        v_sql := v_sql || '             AND C.PERIODO    = ' || pdt_periodo || ' ';
        v_sql := v_sql || '             AND C.MOVTO_E_S <> ''9'' ';
        v_sql := v_sql || '             AND C.CFOP       = ''1409'' ';
        v_sql := v_sql || '        ) LOOP ';
        ---
        v_sql := v_sql || '        FOR C_PS IN (SELECT NUM_CONTROLE_DOCTO AS NF_BRL_ID ';
        v_sql := v_sql || '                     FROM MSAF.X07_DOCTO_FISCAL ';
        v_sql := v_sql || '                     WHERE COD_EMPRESA      = MSAFI.DPSP.EMPRESA ';
        v_sql := v_sql || '                       AND COD_ESTAB        = C.COD_PART ';
        v_sql := v_sql || '                       AND NUM_AUTENTIC_NFE = C.CHAVE_ACESSO ';
        v_sql := v_sql || '                       AND MOVTO_E_S        = ''9'') LOOP ';
        ---
        v_sql := v_sql || '          UPDATE MSAFI.' || p_tab_mov || ' D ';
        v_sql := v_sql || '            SET D.VLR_ICMS    = DECODE( ';
        v_sql := v_sql || '                                    NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.ICMSTAX_BRL_AMT '; --PRIMEIRO PROCURAR NO PSFT
        v_sql := v_sql || '                                        FROM MSAFI.PS_NF_LN_BBL_FS TX ';
        v_sql := v_sql || '                                        WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                          AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                          AND TX.NF_BRL_ID       = C_PS.NF_BRL_ID), ';
        v_sql := v_sql || '                                      0), ';
        v_sql := v_sql || '                                      0, ';
        v_sql := v_sql || '                                    NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.TAX_BRL_AMT '; --SEGUNDO PROCURAR NO XML DANFE
        v_sql := v_sql || '                                      FROM MSAFI.PS_AR_IMP_BBL TX ';
        v_sql := v_sql || '                                      WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                        AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                        AND TX.NF_BRL_ID       = C_PS.NF_BRL_ID ';
        v_sql := v_sql || '                                        AND TX.TAX_ID_BBL      = ''ICMS''), ';
        v_sql := v_sql || '                                    0), ';
        v_sql := v_sql || '                                    NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.ICMSTAX_BRL_AMT ';
        v_sql := v_sql || '                                        FROM MSAFI.PS_NF_LN_BBL_FS TX ';
        v_sql := v_sql || '                                        WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                          AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                          AND TX.NF_BRL_ID       = C_PS.NF_BRL_ID), ';
        v_sql := v_sql || '                                    0) ';
        v_sql := v_sql || '                                ), ';
        v_sql := v_sql || '                D.VLR_BASE_ICMS = DECODE( ';
        v_sql := v_sql || '                                    NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.ICMSTAX_BRL_BSS '; --PRIMEIRO PROCURAR NO PSFT
        v_sql := v_sql || '                                        FROM MSAFI.PS_NF_LN_BBL_FS TX ';
        v_sql := v_sql || '                                        WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                          AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                          AND TX.NF_BRL_ID       = C_PS.NF_BRL_ID), ';
        v_sql := v_sql || '                                      0), ';
        v_sql := v_sql || '                                      0, ';
        v_sql := v_sql || '                                    NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.TAX_BRL_BSE '; --SEGUNDO PROCURAR NO XML DANFE
        v_sql := v_sql || '                                      FROM MSAFI.PS_AR_IMP_BBL TX ';
        v_sql := v_sql || '                                      WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                        AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                        AND TX.NF_BRL_ID       = C_PS.NF_BRL_ID ';
        v_sql := v_sql || '                                        AND TX.TAX_ID_BBL      = ''ICMS''), ';
        v_sql := v_sql || '                                    0), ';
        v_sql := v_sql || '                                    NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.ICMSTAX_BRL_BSS ';
        v_sql := v_sql || '                                        FROM MSAFI.PS_NF_LN_BBL_FS TX ';
        v_sql := v_sql || '                                        WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                          AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                          AND TX.NF_BRL_ID       = C_PS.NF_BRL_ID), ';
        v_sql := v_sql || '                                    0) ';
        v_sql := v_sql || '                                  ), ';
        v_sql := v_sql || '                D.ALIQ_ICMS  = DECODE( ';
        v_sql := v_sql || '                                    NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.ICMSTAX_BRL_PCT '; --PRIMEIRO PROCURAR NO PSFT
        v_sql := v_sql || '                                        FROM MSAFI.PS_NF_LN_BBL_FS TX ';
        v_sql := v_sql || '                                        WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                          AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                          AND TX.NF_BRL_ID       = C_PS.NF_BRL_ID), ';
        v_sql := v_sql || '                                      0), ';
        v_sql := v_sql || '                                      0, ';
        v_sql := v_sql || '                                    NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.TAX_BRL_PCT  '; --SEGUNDO PROCURAR NO XML DANFE
        v_sql := v_sql || '                                      FROM MSAFI.PS_AR_IMP_BBL TX ';
        v_sql := v_sql || '                                      WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                        AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                        AND TX.NF_BRL_ID       = C_PS.NF_BRL_ID ';
        v_sql := v_sql || '                                        AND TX.TAX_ID_BBL      = ''ICMS''), ';
        v_sql := v_sql || '                                    0), ';
        v_sql := v_sql || '                                    NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.ICMSTAX_BRL_PCT ';
        v_sql := v_sql || '                                        FROM MSAFI.PS_NF_LN_BBL_FS TX ';
        v_sql := v_sql || '                                        WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                          AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                          AND TX.NF_BRL_ID       = C_PS.NF_BRL_ID), ';
        v_sql := v_sql || '                                    0) ';
        v_sql := v_sql || '                                  ), ';
        v_sql := v_sql || '                D.VLR_ICMS_ST = DECODE( ';
        v_sql := v_sql || '                                    NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.DSP_ICMS_AMT_ST '; --PRIMEIRO PROCURAR NO PSFT
        v_sql := v_sql || '                                        FROM MSAFI.PS_NF_LN_BBL_FS TX ';
        v_sql := v_sql || '                                        WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                          AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                          AND TX.NF_BRL_ID       = C_PS.NF_BRL_ID), ';
        v_sql := v_sql || '                                      0), ';
        v_sql := v_sql || '                                      0, ';
        v_sql := v_sql || '                                    NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.TAX_BRL_AMT  '; --SEGUNDO PROCURAR NO XML DANFE
        v_sql := v_sql || '                                      FROM MSAFI.PS_AR_IMP_BBL TX ';
        v_sql := v_sql || '                                      WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                        AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                        AND TX.NF_BRL_ID       = C_PS.NF_BRL_ID ';
        v_sql := v_sql || '                                        AND TX.TAX_ID_BBL      = ''ICMST''), ';
        v_sql := v_sql || '                                    0), ';
        v_sql := v_sql || '                                    NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.DSP_ICMS_AMT_ST ';
        v_sql := v_sql || '                                        FROM MSAFI.PS_NF_LN_BBL_FS TX ';
        v_sql := v_sql || '                                        WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                          AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                          AND TX.NF_BRL_ID       = C_PS.NF_BRL_ID), ';
        v_sql := v_sql || '                                    0) ';
        v_sql := v_sql || '                                  ), ';
        v_sql := v_sql || '                D.VLR_BASE_ICMS_ST = DECODE( ';
        v_sql :=
               v_sql
            || '                                          NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.DSP_ICMS_BSS_ST '; --PRIMEIRO PROCURAR NO PSFT
        v_sql := v_sql || '                                                FROM MSAFI.PS_NF_LN_BBL_FS TX ';
        v_sql := v_sql || '                                                WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql :=
            v_sql || '                                                  AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql :=
            v_sql || '                                                  AND TX.NF_BRL_ID       = C_PS.NF_BRL_ID), ';
        v_sql := v_sql || '                                            0), ';
        v_sql := v_sql || '                                            0, ';
        v_sql :=
            v_sql || '                                          NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.TAX_BRL_BSE '; --SEGUNDO PROCURAR NO XML DANFE
        v_sql := v_sql || '                                              FROM MSAFI.PS_AR_IMP_BBL TX ';
        v_sql := v_sql || '                                            WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql := v_sql || '                                              AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                                              AND TX.NF_BRL_ID       = C_PS.NF_BRL_ID ';
        v_sql := v_sql || '                                              AND TX.TAX_ID_BBL      = ''ICMST''), ';
        v_sql := v_sql || '                                            0), ';
        v_sql :=
               v_sql
            || '                                          NVL((SELECT /*+ DRIVING_SITE(TX) */ TX.DSP_ICMS_BSS_ST ';
        v_sql := v_sql || '                                                FROM MSAFI.PS_NF_LN_BBL_FS TX ';
        v_sql := v_sql || '                                                WHERE TX.BUSINESS_UNIT   = C.BUSINESS_UNIT ';
        v_sql :=
            v_sql || '                                                  AND TX.NF_BRL_LINE_NUM = C.NF_BRL_LINE_NUM ';
        v_sql :=
            v_sql || '                                                  AND TX.NF_BRL_ID       = C_PS.NF_BRL_ID), ';
        v_sql := v_sql || '                                            0) ';
        v_sql := v_sql || '                                      ), ';
        v_sql := v_sql || '                D.ORIGEM_ICMS  = ''L'', ';
        v_sql := v_sql || '                D.TAX_CONTROLE = ''M'' ';
        v_sql := v_sql || '          WHERE ROWID = C.ROWID ';
        v_sql := v_sql || '            AND D.TAX_CONTROLE <> ''E''; ';
        ---
        v_sql := v_sql || '          V_COMMIT := V_COMMIT + 1; ';
        v_sql := v_sql || '          IF (V_COMMIT = 100) THEN ';
        v_sql := v_sql || '            V_COUNT  := V_COUNT + V_COMMIT; ';
        v_sql := v_sql || '            V_COMMIT := 0; ';
        v_sql :=
               v_sql
            || '            DBMS_APPLICATION_INFO.SET_MODULE('''
            || vg_module
            || ''', ''F4 ENT LOJA <- LOJA ['' || V_COUNT || '']''); ';
        v_sql := v_sql || '            COMMIT; ';
        v_sql := v_sql || '          END IF; ';
        ---
        v_sql := v_sql || '    END LOOP; ';
        v_sql := v_sql || 'END LOOP; ';
        v_sql := v_sql || 'COMMIT; ';
        v_sql := v_sql || 'END; ';

        BEGIN
            EXECUTE IMMEDIATE v_sql;
        EXCEPTION
            WHEN OTHERS THEN
                v_msg_erro := SQLERRM;

                INSERT INTO msafi.log_geral ( ora_err_number1
                                            , ora_err_mesg1
                                            , cod_empresa
                                            , cod_estab
                                            , num_docfis
                                            , data_fiscal
                                            , serie_docfis
                                            , col14
                                            , col15
                                            , col16
                                            , num_item
                                            , col17
                                            , col18
                                            , col19
                                            , col20
                                            , col21
                                            , col22
                                            , movto_e_s
                                            , norm_dev
                                            , ident_docto
                                            , ident_fis_jur )
                     VALUES ( NULL
                            , v_msg_erro
                            , msafi.dpsp.empresa
                            , p_cod_estab
                            , NULL
                            , NULL
                            , NULL
                            , NULL
                            , 'SP'
                            , TO_CHAR ( pdt_periodo )
                            , ' '
                            , 'DPSP_FIN151_CAT42_FICHAS_CPROC'
                            , 'F4 ENT LOJA <- LOJA'
                            , NULL
                            , NULL
                            , TO_CHAR ( SYSDATE
                                      , 'DD/MM/YYYY HH24:MI.SS' )
                            , p_tab_mov
                            , NULL
                            , NULL
                            , NULL
                            , NULL );

                COMMIT;
                raise_application_error ( -20040
                                        , 'ERRO F4 ENT LOJA <- LOJA: ' || v_msg_erro );
        END;
    EXCEPTION
        WHEN OTHERS THEN
            dbms_output.put_line ( 'ERRO GET_CD_TO_LOJA_XML: ' || SQLERRM );
            raise_application_error ( -20040
                                    , 'ERRO GET_CD_TO_LOJA_XML: ' || SQLERRM );
    END;

    PROCEDURE get_loja_loja_ult ( p_cod_estab IN VARCHAR2
                                , p_periodo IN INTEGER
                                , p_tab_mov IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 8000 );
        c_mov SYS_REFCURSOR;

        ---
        TYPE r_tab_mov IS RECORD
        (
            cod_part VARCHAR2 ( 10 )
          , data_fiscal DATE
          , row_id VARCHAR2 ( 30 )
          , cod_item VARCHAR2 ( 30 )
        );

        TYPE t_tab_mov IS TABLE OF r_tab_mov;

        tab_mov t_tab_mov;
        ---
        v_chave_acesso VARCHAR2 ( 60 );
        v_data_fiscal DATE;
        v_vlr_icms NUMBER ( 17, 2 ) := 0;
        v_vlr_base_icms NUMBER ( 17, 2 ) := 0;
        v_vlr_icms_st NUMBER ( 17, 2 ) := 0;
        v_vlr_base_icms_st NUMBER ( 17, 2 ) := 0;
        ---
        v_count NUMBER DEFAULT 0;
    BEGIN
        v_sql := 'SELECT COD_PART, DATA, ROWID AS ROW_ID, ';
        v_sql := v_sql || '       COD_ITEM ';
        v_sql := v_sql || 'FROM MSAFI.' || p_tab_mov || ' ';
        v_sql := v_sql || 'WHERE COD_FILIAL = :1 ';
        v_sql := v_sql || '  AND PERIODO    = :2 ';
        v_sql :=
               v_sql
            || '  AND COD_PART IN (SELECT COD_ESTAB FROM MSAFI.DSP_ESTABELECIMENTO WHERE COD_EMPRESA = MSAFI.DPSP.EMPRESA AND TIPO = ''L'') ';
        v_sql := v_sql || '  AND MOVTO_E_S <> ''9'' ';
        v_sql := v_sql || '  AND CHAVE_ACESSO_REF IS NULL ';
        v_sql := v_sql || '  AND VLR_ICMS_ST = 0 ';
        v_sql := v_sql || '  AND COD_FILIAL <> COD_PART ';

        OPEN c_mov FOR v_sql
            USING p_cod_estab
                , p_periodo;

        LOOP
            FETCH c_mov
                BULK COLLECT INTO tab_mov
                LIMIT 100;

            IF tab_mov.COUNT > 0 THEN
                FOR t IN tab_mov.FIRST .. tab_mov.LAST LOOP
                    BEGIN
                        SELECT num_autentic_nfe
                             , data_fiscal
                             , vlr_base_icms
                             , vlr_icms
                             , vlr_base_icmss
                             , vlr_icmss
                          INTO v_chave_acesso
                             , v_data_fiscal
                             , v_vlr_icms
                             , v_vlr_base_icms
                             , v_vlr_icms_st
                             , v_vlr_base_icms_st
                          FROM (SELECT RANK ( )
                                           OVER ( PARTITION BY e.cod_produto
                                                  ORDER BY
                                                      e.data_fiscal DESC
                                                    , e.num_docfis DESC
                                                    , e.serie_docfis
                                                    , e.num_item )
                                           RANK
                                     , e.num_autentic_nfe
                                     , e.data_fiscal
                                     , TRUNC ( e.vlr_base_icms / e.quantidade
                                             , 4 )
                                           vlr_base_icms
                                     , TRUNC ( e.vlr_icms / e.quantidade
                                             , 4 )
                                           vlr_icms
                                     , TRUNC ( e.vlr_base_icmss / e.quantidade
                                             , 4 )
                                           vlr_base_icmss
                                     , TRUNC ( e.vlr_icmss / e.quantidade
                                             , 4 )
                                           vlr_icmss
                                  FROM msafi.dpsp_nf_entrada e
                                 WHERE e.cod_estab = tab_mov ( t ).cod_part
                                   AND e.cod_empresa = msafi.dpsp.empresa
                                   AND e.data_fiscal < tab_mov ( t ).data_fiscal
                                   AND e.cod_fis_jur = 'ST910'
                                   AND e.cod_produto = tab_mov ( t ).cod_item)
                         WHERE RANK = 1;
                    EXCEPTION
                        WHEN OTHERS THEN
                            v_chave_acesso := 0;
                            v_data_fiscal := NULL;
                            v_vlr_icms := 0;
                            v_vlr_base_icms := 0;
                            v_vlr_icms_st := 0;
                            v_vlr_base_icms_st := 0;
                    END;

                    IF ( v_vlr_icms > 0
                     OR v_vlr_icms_st > 0 ) THEN
                        v_sql := 'UPDATE MSAFI.' || p_tab_mov || ' ';
                        v_sql := v_sql || 'SET ORIGEM_ICMS      = ''C'', ';
                        v_sql := v_sql || '    CHAVE_ACESSO_REF = :1, ';
                        v_sql := v_sql || '    DATA_FISCAL_REF  = :2, ';
                        v_sql := v_sql || '    TAX_CONTROLE     = ''K'', ';
                        v_sql := v_sql || '    VLR_ICMS         = TRUNC( :3 * QTDE,2), ';
                        v_sql := v_sql || '    VLR_BASE_ICMS    = TRUNC( :4 * QTDE,2), ';
                        v_sql := v_sql || '    VLR_ICMS_ST      = TRUNC( :5 * QTDE,2), ';
                        v_sql := v_sql || '    VLR_BASE_ICMS_ST = TRUNC( :6 * QTDE,2) ';
                        v_sql := v_sql || 'WHERE ROWID = :7 ';

                        EXECUTE IMMEDIATE v_sql
                            USING v_chave_acesso
                                , v_data_fiscal
                                , v_vlr_icms
                                , v_vlr_base_icms
                                , v_vlr_icms_st
                                , v_vlr_base_icms_st
                                , tab_mov ( t ).row_id;

                        v_count := v_count + SQL%ROWCOUNT;
                        COMMIT;
                        dbms_application_info.set_module ( vg_module
                                                         , 'F4 LOJA -> LOJA [' || v_count || ']' );
                    END IF;
                END LOOP;
            END IF;

            EXIT WHEN tab_mov.COUNT = 0;
            tab_mov.delete;
        END LOOP;

        CLOSE c_mov;
    EXCEPTION
        WHEN OTHERS THEN
            tab_error.EXTEND;
            tab_error ( tab_error.COUNT ).cod_estab := p_cod_estab;
            tab_error ( tab_error.COUNT ).status := 'O';
            tab_error ( tab_error.COUNT ).error_msg :=
                SUBSTR ( SQLERRM
                       , 1
                       , 255 );
            ---
            dbms_output.put_line ( 'ERRO GET_LOJA_LOJA_ULT: ' || SQLERRM );
            raise_application_error ( -20040
                                    , 'ERRO GET_LOJA_LOJA_ULT: ' || SQLERRM );
    END;
END dpsp_fin151_cat42_fichas_cproc;
/
SHOW ERRORS;
