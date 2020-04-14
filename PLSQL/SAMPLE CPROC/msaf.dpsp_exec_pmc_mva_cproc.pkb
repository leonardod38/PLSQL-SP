Prompt Package Body DPSP_EXEC_PMC_MVA_CPROC;
--
-- DPSP_EXEC_PMC_MVA_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_exec_pmc_mva_cproc
IS
    vs_mlinha VARCHAR2 ( 4000 );

    vn_linha NUMBER := 0;
    vn_pagina NUMBER := 0;

    mnm_usuario usuario_estab.cod_usuario%TYPE;
    mcod_empresa estabelecimento.cod_empresa%TYPE;

    mnm_tipo VARCHAR2 ( 100 ) := 'Ressarcimento';
    mnm_cproc VARCHAR2 ( 100 ) := 'Processar Dados PMC x MVA em LOTE';
    mds_cproc VARCHAR2 ( 100 ) := 'Processar em LOTE as carga de dados do PMC MVA';

    v_sel_data_fim VARCHAR2 ( 260 )
        := 'SELECT TRUNC( TO_DATE( :1 ,''DD/MM/YYYY'') + ROWNUM - 1) AS DATA_FIM, TRUNC( TO_DATE( :1 ,''DD/MM/YYYY'') + ROWNUM - 1) AS DATA_FIM FROM DUAL CONNECT BY ROWNUM <= LAST_DAY( TO_DATE( :1 ,''DD/MM/YYYY'') ) - TO_DATE( :1 ,''DD/MM/YYYY'') + 1 ORDER BY 1 DESC ';

    /*  V_SEL_UFPERFIL VARCHAR2(1000) := 'SELECT DISTINCT UF || ID_PARAMETROS, UF || '' - '' || PERFIL ' ||
                                       'FROM ( ' ||
                                       'SELECT DISTINCT P.ID_PARAMETROS, P.DESCRICAO || '' ('' || P.ID_PARAMETROS || '')'' AS PERFIL, ' ||
                                       '(SELECT TO_DATE(NVL(TRIM(INI.VALOR),''01/01/1900''),''DD/MM/YYYY'') ' ||
                                       'FROM FPAR_PARAM_DET INI ' ||
                                       'WHERE INI.ID_PARAMETRO = P.ID_PARAMETROS ' ||
                                       'AND INI.NOME_PARAM = ''7DTINIV'') AS DT_INI, ' ||
                                       '(SELECT TO_DATE(NVL(TRIM(INI.VALOR),''31/12/2099''),''DD/MM/YYYY'') ' ||
                                       'FROM FPAR_PARAM_DET INI ' ||
                                       'WHERE INI.ID_PARAMETRO = P.ID_PARAMETROS ' ||
                                       'AND INI.NOME_PARAM = ''8DTFIMV'') AS DT_FIM, ' ||
                                       '(SELECT UF.VALOR ' ||
                                       'FROM FPAR_PARAM_DET UF ' ||
                                       'WHERE UF.ID_PARAMETRO = P.ID_PARAMETROS ' ||
                                       'AND UF.NOME_PARAM = ''9UF'') AS UF ' ||
                                       'FROM FPAR_PARAMETROS P ' ||
                                       'WHERE P.NOME_FRAMEWORK = ''DPSP_PERFIL_PMC_CPAR'' ' ||
                                       ')  ' ||
                                       'WHERE DT_INI <= :1 ' ||
                                       'AND DT_FIM >= :2 ' ||
                                       'ORDER BY 1 ';*/


    v_sel_ufperfil VARCHAR2 ( 1000 )
        :=    'SELECT DISTINCT uf || id_parametros, uf || '' - '' || perfil '
           || 'FROM  msafi.vw_DPSP_perfil_PMC_X_MVA '
           || 'WHERE DT_INI <= :1 '
           || 'AND DT_FIM >= :2 '
           || 'ORDER BY 1 ';

    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 1000 );
    BEGIN
        mnm_usuario := lib_parametros.recuperar ( UPPER ( 'USUARIO' ) );
        mcod_empresa := lib_parametros.recuperar ( UPPER ( 'EMPRESA' ) );



        lib_proc.add_param ( pstr
                           , 'Data Inicial'
                           , --P_DATA_INI
                            'DATE'
                           , 'TEXTBOX'
                           , 'S'
                           , NULL
                           , 'DD/MM/YYYY' );

        /*    LIB_PROC.ADD_PARAM(PSTR,
                               'Data Final', --P_DATA_FIM
                               'DATE',
                               'TEXTBOX',
                               'S',
                               NULL,
                               'DD/MM/YYYY');*/


        lib_proc.add_param ( pstr
                           , 'Data Final'
                           , --P_DATA_FIM
                            'VARCHAR2'
                           , 'COMBOBOX'
                           , 'S'
                           , NULL
                           , '##########'
                           , v_sel_data_fim );

        lib_proc.add_param ( pstr
                           , 'Qtde de Execuções em Paralelo'
                           , --P_LOTE
                            'NUMBER'
                           , 'TEXTBOX'
                           , 'S'
                           , '20'
                           , '####' );

        lib_proc.add_param ( pstr
                           , 'UF - Perfil'
                           , --P_PERFIL
                            'VARCHAR2'
                           , 'MULTISELECT'
                           , 'S'
                           , NULL
                           , NULL
                           , v_sel_ufperfil );

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

    PROCEDURE cabecalho ( pnm_empresa VARCHAR2
                        , pcnpj VARCHAR2
                        , v_data_hora_ini VARCHAR2
                        , mnm_cproc VARCHAR2
                        , pdt_ini DATE
                        , pdt_fim DATE )
    IS
    BEGIN
        --=================================================================================
        -- CABEÇALHO DO DW
        --=================================================================================
        vs_mlinha := NULL;
        vs_mlinha :=
            lib_str.w ( vs_mlinha
                      , 'EMPRESA: ' || mcod_empresa || ' - ' || pnm_empresa
                      , 1 );
        vs_mlinha :=
            lib_str.w ( vs_mlinha
                      ,    'PÁGINA : '
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
                      , 'DATA DE PROCESSAMENTO : ' || v_data_hora_ini
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
        vs_mlinha := mnm_cproc;
        lib_proc.add ( vs_mlinha
                     , NULL
                     , NULL
                     , 1 );

        vs_mlinha := NULL;
        vs_mlinha := 'DATA INICIAL: ' || pdt_ini;
        lib_proc.add ( vs_mlinha
                     , NULL
                     , NULL
                     , 1 );

        vs_mlinha := NULL;
        vs_mlinha := 'DATA FINAL: ' || pdt_fim;
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
    END cabecalho;

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

    PROCEDURE save_tmp_control ( vp_proc_instance IN NUMBER
                               , vp_table_name IN VARCHAR2 )
    IS
    BEGIN
        ---> ROTINA PARA ARMAZENAR TABELAS TEMP CRIADAS, CASO PROGRAMA SEJA
        ---  INTERROMPIDO, ELAS SERAO EXCLUIDAS EM OUTROS PROCESSAMENTOS
        INSERT /*+APPEND*/
              INTO  msafi.dpsp_msaf_tmp_control
             VALUES ( vp_proc_instance
                    , vp_table_name
                    , SYSDATE
                    , lib_parametros.recuperar ( 'USUARIO' )
                    , USERENV ( 'SID' ) );

        COMMIT;
    END;

    PROCEDURE create_tab_prog ( vp_proc_instance IN VARCHAR2
                              , vp_tabela_prod_saida   OUT VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 10000 );
    BEGIN
        vp_tabela_prod_saida := 'DP$P_PMC_PART_' || vp_proc_instance;

        v_sql := 'CREATE TABLE ' || vp_tabela_prod_saida || ' ( ';
        v_sql := v_sql || 'COD_ESTAB    VARCHAR2(6), ';
        v_sql := v_sql || 'ID_PARAMETRO INTEGER, ';
        v_sql := v_sql || 'LINHA        INTEGER ';
        v_sql := v_sql || ' ) ';
        v_sql :=
            v_sql || ' STORAGE (BUFFER_POOL KEEP) PCTFREE 0 NOLOGGING NOCOMPRESS CACHE TABLESPACE MSAF_WORK_TABLES ';

        EXECUTE IMMEDIATE v_sql;
    END;

    PROCEDURE carga ( pnr_particao INTEGER
                    , pnr_particao2 INTEGER
                    , p_data_ini DATE
                    , p_data_fim DATE
                    , p_nm_tabela VARCHAR2
                    , p_proc_id VARCHAR2
                    , p_nm_empresa VARCHAR2
                    , p_nm_usuario VARCHAR2 )
    IS
        v_estab VARCHAR2 ( 6 );
        v_sql VARCHAR2 ( 10000 );
        v_uf VARCHAR2 ( 2 );
        v_id_parametro INTEGER;

        mproc_id INTEGER;

        p_lojas msaf.lib_proc.vartab;
    BEGIN
        v_sql := '';
        v_sql := v_sql || ' SELECT COD_ESTAB, ID_PARAMETRO ';
        v_sql := v_sql || ' FROM ' || p_nm_tabela;
        v_sql := v_sql || ' WHERE LINHA = ' || pnr_particao;

        EXECUTE IMMEDIATE ( v_sql )
                       INTO v_estab
                          , v_id_parametro;

        SELECT cod_estado
          INTO v_uf
          FROM msaf.dsp_estabelecimento_v
         WHERE cod_estab = v_estab;

        p_lojas ( 0 ) := v_estab;

        dpsp_pmc_x_mva_cproc.executar_lote ( p_data_ini => p_data_ini
                                           , p_data_fim => p_data_fim
                                           , p_rel => 1
                                           , p_uf => v_uf
                                           , p_perfil => v_id_parametro
                                           , p_empresa => p_nm_empresa
                                           , p_usuario => p_nm_usuario
                                           , p_procorig => p_proc_id
                                           , p_lojas => p_lojas );

        p_lojas.delete;
    END;

    FUNCTION executar ( p_data_ini DATE
                      , p_data_fim DATE
                      , p_lote INTEGER
                      , p_perfil lib_proc.vartab )
        RETURN INTEGER
    IS
        v_cont INTEGER := 0;
        v_proc INTEGER;
        v_lote NUMBER := 0;

        v_qt_grupos INTEGER := 0;
        v_qt_grupos_paralelos INTEGER := 20;

        v_nm_tabela VARCHAR2 ( 30 );

        p_task VARCHAR2 ( 50 );
        v_sql VARCHAR2 ( 10000 );

        v_data_hora_ini VARCHAR2 ( 20 );
        ---
        v_uf VARCHAR2 ( 2 ) := '';
        v_uf_ant VARCHAR2 ( 2 ) := '';
        v_id_param INTEGER;
    BEGIN
        --MARCAR INCIO DA EXECUCAO
        v_data_hora_ini :=
            TO_CHAR ( SYSDATE
                    , 'DD/MM/YYYY HH24:MI.SS' );

        -- CRIAÇÃO: PROCESSO
        v_proc := lib_proc.new ( 'DPSP_EXEC_PMC_MVA_CPROC' );

        -- CRIAÇÃO RELATÓRIO (01)
        lib_proc.add_tipo ( pproc_id => v_proc
                          , ptipo => 1
                          , ptitulo => 'DADOS PMC EM LOTE'
                          , ptipo_arq => 1 );

        mnm_usuario := lib_parametros.recuperar ( UPPER ( 'USUARIO' ) );
        mcod_empresa := lib_parametros.recuperar ( UPPER ( 'EMPRESA' ) );

        FOR c_dados_emp IN ( SELECT cod_empresa
                                  , razao_social
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
            cabecalho ( c_dados_emp.razao_social
                      , c_dados_emp.cnpj
                      , v_data_hora_ini
                      , mnm_cproc
                      , p_data_ini
                      , p_data_fim );
        END LOOP;

        create_tab_prog ( v_proc
                        , v_nm_tabela );
        save_tmp_control ( v_proc
                         , v_nm_tabela );

        --============================================
        --LOOP DE ESTABELECIMENTOS
        --============================================
        FOR v_perfil IN p_perfil.FIRST .. p_perfil.LAST LOOP
            v_uf :=
                SUBSTR ( p_perfil ( v_perfil )
                       , 1
                       , 2 );
            v_id_param :=
                SUBSTR ( p_perfil ( v_perfil )
                       , 3 );

            IF ( v_uf = v_uf_ant ) THEN
                --NAO PERMITIR 2 UFs IGUAIS NO MESMO PROCESSAMENTO, DEVIDO A PERFIS DIFERENTES
                loga ( '<< NÃO É PERMITIDO UFs IGUAIS NO MESMO PROCESSAMENTO >>'
                     , FALSE );
                raise_application_error ( -20001
                                        , 'NÃO É PERMITIDO UFs IGUAIS NO MESMO PROCESSAMENTO!' );
                ---
                lib_proc.close;
                COMMIT;
                RETURN v_proc;
            END IF;

            v_sql := '';
            v_sql := v_sql || ' INSERT INTO ' || v_nm_tabela;
            v_sql := v_sql || '   SELECT COD_ESTAB, ' || v_id_param || ', ROWNUM + ' || v_qt_grupos || ' LINHA';
            v_sql := v_sql || ' FROM MSAF.DSP_ESTABELECIMENTO_V';
            v_sql := v_sql || ' WHERE 1=1 ';
            --V_SQL := V_SQL || ' AND ROWNUM < 3 '; -- TESTE
            v_sql := v_sql || ' AND COD_ESTADO = ''' || v_uf || '''';
            v_sql := v_sql || ' AND TIPO = ''L'' '; --APENAS LOJAS
            v_sql := v_sql || ' ORDER BY COD_ESTAB ';

            EXECUTE IMMEDIATE ( v_sql );

            v_qt_grupos := v_qt_grupos + SQL%ROWCOUNT;
            v_uf_ant := v_uf;
        END LOOP;

        p_task := 'PROC_PMC_' || v_proc;

        --===================================
        --QUANTIDADE DE PROCESSOS EM PARALELO
        --===================================

        IF NVL ( p_lote, 0 ) < 1 THEN
            v_qt_grupos_paralelos := 20;
        ELSIF NVL ( p_lote, 0 ) > 100 THEN
            v_qt_grupos_paralelos := 100;
        ELSE
            v_qt_grupos_paralelos := p_lote;
        END IF;

        loga ( 'QUANTIDADE EM PARALELO: ' || v_qt_grupos_paralelos
             , FALSE );
        loga ( ' '
             , FALSE );

        --===================================
        -- CHUNK
        --===================================
        dpsp_chunk_parallel.exec_parallel ( v_proc
                                          , 'DPSP_EXEC_PMC_MVA_CPROC.CARGA'
                                          , v_qt_grupos
                                          , v_qt_grupos_paralelos
                                          , p_task
                                          , -- 'PROCESSAR_EXCLUSAO',
                                           'TO_DATE('''
                                            || TO_CHAR ( p_data_ini
                                                       , 'DDMMYYYY' )
                                            || ''',''DDMMYYYY''),'
                                            || 'TO_DATE('''
                                            || TO_CHAR ( p_data_fim
                                                       , 'DDMMYYYY' )
                                            || ''',''DDMMYYYY''),'''
                                            || v_nm_tabela
                                            || ''','
                                            || v_proc
                                            || ','''
                                            || mcod_empresa
                                            || ''','
                                            || ''''
                                            || mnm_usuario
                                            || '''' );

        dbms_parallel_execute.drop_task ( p_task );

        --========================================
        -- INICIO - VERIFICAR PROCESSOS DO LOTE QUE TIVERAM ERRO
        --========================================
        loga ( ' '
             , FALSE );
        loga ( 'ESTABELECIMENTOS PROCESSADOS '
             , FALSE );
        loga ( ' '
             , FALSE );

        --========================================
        -- FIM - VERIFICAR PROCESSOS DO LOTE QUE TIVERAM ERRO
        --========================================
        FOR g IN ( SELECT   estab.proc_id
                          , REPLACE ( estab.texto
                                    , '>> ESTAB: '
                                    , '' )
                                AS cod_estab
                       FROM lib_proc_log estab
                      WHERE 1 = 1
                        AND proc_id IN ( SELECT orig.proc_id
                                           FROM lib_processo orig
                                          WHERE orig.proc_id_orig = v_proc )
                        AND estab.texto LIKE '%>> ESTAB: %' --DESCRIÇÃO QUE É POSSÍVEL COLETAR O ESTABELECIMENTO
                   ORDER BY 1
                          , 2 ) LOOP
            loga ( g.cod_estab
                 , FALSE );
        END LOOP;

        --========================================
        -- INICIO - VERIFICAR PROCESSOS DO LOTE QUE TIVERAM ERRO
        --========================================
        FOR e IN ( SELECT   estab.proc_id
                          , REPLACE ( estab.texto
                                    , '>> ESTAB: '
                                    , '' )
                                AS cod_estab
                       FROM (SELECT DISTINCT proc_id
                               FROM lib_proc_log er
                              WHERE er.proc_id IN ( SELECT orig.proc_id
                                                      FROM lib_processo orig
                                                     WHERE orig.proc_id_orig = v_proc )
                                AND UPPER ( texto ) LIKE '%ERR%') a
                          , lib_proc_log estab
                      WHERE 1 = 1
                        AND a.proc_id = estab.proc_id
                        AND estab.texto LIKE '%>> ESTAB: %' --DESCRIÇÃO QUE É POSSÍVEL COLETAR O ESTABELECIMENTO
                   ORDER BY 1
                          , 2 ) LOOP
            lib_proc.add ( 'OCORRERAM ERROS NO Nº PROCESSO: ' || e.proc_id || ' - ESTAB: ' || e.cod_estab
                         , NULL
                         , NULL
                         , 1 );
        END LOOP;

        --========================================
        -- FIM - VERIFICAR PROCESSOS DO LOTE QUE TIVERAM ERRO
        --========================================
        lib_proc.add ( ' '
                     , NULL
                     , NULL
                     , 1 );
        lib_proc.add ( 'PROCESSO FINALIZADO'
                     , NULL
                     , NULL
                     , 1 );

        lib_proc.close ( );

        RETURN v_proc;
    END;
END;
/
SHOW ERRORS;
