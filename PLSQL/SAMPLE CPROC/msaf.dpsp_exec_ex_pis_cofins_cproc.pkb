Prompt Package Body DPSP_EXEC_EX_PIS_COFINS_CPROC;
--
-- DPSP_EXEC_EX_PIS_COFINS_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_exec_ex_pis_cofins_cproc
IS
    vs_mlinha VARCHAR2 ( 4000 );

    vn_linha NUMBER := 0;
    vn_pagina NUMBER := 0;

    mnm_usuario usuario_estab.cod_usuario%TYPE;
    mcod_empresa estabelecimento.cod_empresa%TYPE;

    mnm_tipo VARCHAR2 ( 100 ) := 'Ressarcimento';
    mnm_cproc VARCHAR2 ( 100 ) := 'Processar Dados Exclusao de ICMS da BC PIS/Cofins em LOTE';
    mds_cproc VARCHAR2 ( 100 ) := 'Processar em LOTE a Carga de Dados Exclusao de ICMS da BC PIS/Cofins';

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

        lib_proc.add_param ( pstr
                           , 'Data Final'
                           , --P_DATA_FIM
                            'DATE'
                           , 'TEXTBOX'
                           , 'S'
                           , NULL
                           , 'DD/MM/YYYY' );

        lib_proc.add_param ( pparam => pstr
                           , ptitulo =>    LPAD ( ' '
                                                , 20
                                                , ' ' )
                                        || LPAD ( '_'
                                                , 50
                                                , '_' )
                           , ptipo => 'Varchar2'
                           , pcontrole => 'Text'
                           , pmandatorio => 'N'
                           , pdefault => 'N'
                           , pmascara => NULL
                           , pvalores => NULL
                           , papresenta => 'N' );

        lib_proc.add_param ( pparam => pstr
                           , ptitulo =>    LPAD ( ' '
                                                , 40
                                                , ' ' )
                                        || 'Quantidade de lojas executadas'
                           , ptipo => 'Varchar2'
                           , pcontrole => 'Text'
                           , pmandatorio => 'N'
                           , pdefault => 'N'
                           , pmascara => NULL
                           , pvalores => NULL
                           , papresenta => 'N' );

        lib_proc.add_param ( pstr
                           , 'em paralelo'
                           , --P_LOTE
                            'NUMBER'
                           , 'TEXTBOX'
                           , 'S'
                           , '20'
                           , '####' );

        lib_proc.add_param (
                             pparam => pstr
                           , ptitulo => 'UF'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'MULTISELECT'
                           , pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => '####################'
                           , pvalores =>    'SELECT COD_ESTADO, COD_ESTADO || '' - '' || DESCRICAO TXT FROM ESTADO '
                                         || ' WHERE COD_ESTADO IN (SELECT COD_ESTADO FROM DSP_ESTABELECIMENTO_V) '
                                         || '  ORDER BY 1'
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
        -- Cabeçalho do DW
        --=================================================================================
        vs_mlinha := NULL;
        vs_mlinha :=
            lib_str.w ( vs_mlinha
                      , 'Empresa: ' || mcod_empresa || ' - ' || pnm_empresa
                      , 1 );
        vs_mlinha :=
            lib_str.w ( vs_mlinha
                      ,    'Página : '
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
                      , 'Data de Processamento : ' || v_data_hora_ini
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
        vs_mlinha := 'Data Inicial: ' || pdt_ini;
        lib_proc.add ( vs_mlinha
                     , NULL
                     , NULL
                     , 1 );

        vs_mlinha := NULL;
        vs_mlinha := 'Data Final: ' || pdt_fim;
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
        vp_tabela_prod_saida := 'DPSP_PART_' || vp_proc_instance;

        v_sql := 'CREATE TABLE ' || vp_tabela_prod_saida || ' ( ';
        v_sql := v_sql || 'COD_ESTAB  VARCHAR2(6), ';
        v_sql := v_sql || 'LINHA      INTEGER ';
        v_sql := v_sql || ' ) ';
        v_sql := v_sql || 'PCTFREE     10 ';

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

        mproc_id INTEGER;

        p_lojas msaf.lib_proc.vartab;
    BEGIN
        v_sql := '';
        v_sql := v_sql || ' SELECT COD_ESTAB ';
        v_sql := v_sql || ' FROM ' || p_nm_tabela;
        v_sql := v_sql || ' WHERE LINHA = ' || pnr_particao;

        EXECUTE IMMEDIATE ( v_sql )            INTO v_estab;

        SELECT cod_estado
          INTO v_uf
          FROM msaf.dsp_estabelecimento_v
         WHERE cod_estab = v_estab;

        p_lojas ( 0 ) := v_estab;

        dpsp_ex_pis_cofins_cproc.executar_lote ( p_data_ini => p_data_ini
                                               , p_data_fim => p_data_fim
                                               , p_rel => 1
                                               , p_uf => v_uf
                                               , p_empresa => p_nm_empresa
                                               , p_usuario => p_nm_usuario
                                               , p_procorig => p_proc_id
                                               , p_lojas => p_lojas );

        p_lojas.delete;
    END;

    FUNCTION executar ( p_data_ini DATE
                      , p_data_fim DATE
                      , p_lote INTEGER
                      , p_uf lib_proc.vartab )
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
    BEGIN
        --MARCAR INCIO DA EXECUCAO
        v_data_hora_ini :=
            TO_CHAR ( SYSDATE
                    , 'DD/MM/YYYY HH24:MI.SS' );

        -- Criação: Processo
        v_proc := lib_proc.new ( 'DPSP_EXEC_EX_PIS_COFINS_CPROC' );

        -- Criação Relatório (01)
        lib_proc.add_tipo ( pproc_id => v_proc
                          , ptipo => 1
                          , ptitulo => 'Dados Exclusao em LOTE'
                          , ptipo_arq => 1 );

        mnm_usuario := lib_parametros.recuperar ( UPPER ( 'USUARIO' ) );
        mcod_empresa := lib_parametros.recuperar ( UPPER ( 'EMPRESA' ) );



        INSERT INTO msaf.fpar_param_det ( id_parametro
                                        , nome_param
                                        , conteudo
                                        , valor
                                        , descricao )
            SELECT p.id_parametros
                 , 'INTERF' nome_param
                 ,    'EXCLUSAO-'
                   || TO_CHAR ( p_data_ini
                              , 'YYYY/MM' )
                       conteudo
                 , 'N' valor
                 , 'FINALIZADO' descricao
              FROM msaf.fpar_parametros p
             WHERE p.nome_framework = 'DPSP_LOCK_REPROCESSO_CPAR'
               AND NOT EXISTS
                       (SELECT 1
                          FROM msaf.fpar_parametros p
                               INNER JOIN msaf.fpar_param_det d ON d.id_parametro = p.id_parametros
                         WHERE p.nome_framework = 'DPSP_LOCK_REPROCESSO_CPAR'
                           AND d.nome_param = 'INTERF'
                           AND d.conteudo =    'EXCLUSAO-'
                                            || TO_CHAR ( p_data_ini
                                                       , 'YYYY/MM' ));

        COMMIT;


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
        --LIMPEZA DA TEMP QUANDO EXISTIREM REGISTROS MAIS ANTIGOS QUE 5 DIAS
        --============================================
        DELETE FROM msafi.dpsp_exclusao_estab_tmp
              WHERE TO_DATE ( SUBSTR ( dt_carga
                                     , 1
                                     , 10 )
                            , 'DD/MM/YYYY' ) < TO_DATE ( SYSDATE - 5
                                                       , 'DD/MM/YYYY' );

        COMMIT;

        --============================================
        --LOOP de Estabelecimentos
        --============================================
        FOR v_uf IN p_uf.FIRST .. p_uf.LAST LOOP
            v_sql := '';
            v_sql := v_sql || ' INSERT INTO ' || v_nm_tabela;
            v_sql := v_sql || '   SELECT COD_ESTAB, ' || v_qt_grupos || '+ROWNUM LINHA';
            v_sql := v_sql || ' FROM MSAF.DSP_ESTABELECIMENTO_V';
            v_sql := v_sql || ' WHERE 1=1 ';
            v_sql := v_sql || ' AND COD_ESTADO = ''' || p_uf ( v_uf ) || '''';
            v_sql := v_sql || ' ORDER BY COD_ESTAB ';

            EXECUTE IMMEDIATE ( v_sql );

            v_qt_grupos := v_qt_grupos + SQL%ROWCOUNT;
        END LOOP;

        p_task := 'PROC_EXCL_' || v_proc;

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

        loga ( 'Quantidade em paralelo: ' || v_qt_grupos_paralelos
             , FALSE );
        loga ( ' '
             , FALSE );

        --===================================
        -- CHUNK
        --===================================
        msaf.dpsp_chunk_parallel.exec_parallel ( v_proc
                                               , 'DPSP_EXEC_EX_PIS_COFINS_CPROC.CARGA'
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
        loga ( 'Estabelecimentos processados '
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
                                AND UPPER ( texto ) LIKE '%ERR%'
                                AND UPPER ( texto ) NOT LIKE '%[ERRO]%') a
                          , lib_proc_log estab
                      WHERE 1 = 1
                        AND a.proc_id = estab.proc_id
                        AND estab.texto LIKE '%>> ESTAB: %' --DESCRIÇÃO QUE É POSSÍVEL COLETAR O ESTABELECIMENTO
                   ORDER BY 1
                          , 2 ) LOOP
            lib_proc.add ( 'Ocorreram erros no Nº Processo: ' || e.proc_id || ' - Estab: ' || e.cod_estab
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
        lib_proc.add ( 'Processo finalizado'
                     , NULL
                     , NULL
                     , 1 );

        lib_proc.close ( );

        RETURN v_proc;
    END;
END;
/
SHOW ERRORS;
