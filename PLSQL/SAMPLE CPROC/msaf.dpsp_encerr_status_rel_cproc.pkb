Prompt Package Body DPSP_ENCERR_STATUS_REL_CPROC;
--
-- DPSP_ENCERR_STATUS_REL_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_encerr_status_rel_cproc
IS
    mproc_id NUMBER;
    vn_linha NUMBER := 0;
    vn_pagina NUMBER := 0;
    mnm_usuario usuario_estab.cod_usuario%TYPE;
    mcod_empresa estabelecimento.cod_empresa%TYPE;
    vs_mlinha VARCHAR2 ( 4000 );

    --Tipo, Nome e Descrição do Customizado
    mnm_tipo VARCHAR2 ( 100 ) := 'Status';
    mnm_cproc VARCHAR2 ( 100 ) := 'Encerramento de Status de Relatórios';
    mds_cproc VARCHAR2 ( 100 ) := 'Processo para bloquear reprocessamento de Relatórios';

    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );
    BEGIN
        mnm_usuario := lib_parametros.recuperar ( UPPER ( 'USUARIO' ) );
        mcod_empresa := lib_parametros.recuperar ( UPPER ( 'EMPRESA' ) );

        lib_proc.add_param ( pparam => pstr
                           , ptitulo => 'Periodo'
                           , ptipo => 'DATE'
                           , pcontrole => 'textbox'
                           , pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => 'MM/YYYY' );

        lib_proc.add_param (
                             pparam => pstr
                           , ptitulo => 'Relatório'
                           , ptipo => 'Varchar2'
                           , pcontrole => 'Combobox'
                           , pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => NULL
                           , pvalores => 'SELECT DISTINCT CD_CPROC, (NM_CPROC || '' - "'' || NM_TIPO || ''"'') AS DESCRICAO FROM MSAFI.DPSP_MSAF_ENCERR_STATUS_REL A ORDER BY 1'
                           , phabilita => ''
        );

        lib_proc.add_param (
                             pstr
                           , 'UF'
                           , 'VARCHAR2'
                           , 'COMBOBOX'
                           , 'S'
                           , '%'
                           , '#########'
                           , 'SELECT A.COD_ESTADO, A.COD_ESTADO FROM ESTADO A UNION ALL SELECT ''%'', ''Todas as UFs'' FROM DUAL ORDER BY 1'
        );

        lib_proc.add_param ( pparam => pstr
                           , ptitulo => 'Ação'
                           , ptipo => 'Varchar2'
                           , pcontrole => 'Radiobutton'
                           , pmandatorio => 'S'
                           , pdefault => 'C'
                           , pmascara => NULL
                           , pvalores => 'C=Consultar,A=Alterar'
                           , papresenta => 'N' );

        lib_proc.add_param ( pparam => pstr
                           , ptitulo => 'Status'
                           , ptipo => 'Varchar2'
                           , pcontrole => 'listbox'
                           , pmandatorio => 'S'
                           , pdefault => ''
                           , pmascara => NULL
                           , pvalores => '1=Encerrado,0=Aberto'
                           , papresenta => 'N'
                           , phabilita => ' :4 = ''A'' ' );

        lib_proc.add_param ( pparam => pstr
                           , ptitulo => 'Extrair arquivo'
                           , ptipo => 'Varchar2'
                           , pcontrole => 'Checkbox'
                           , pmandatorio => 'S'
                           , pdefault => 'N'
                           , pmascara => NULL
                           , pvalores => 'S=Sim,N=Não'
                           , papresenta => 'N'
                           , phabilita => ' :4 = ''C'' ' );

        lib_proc.add_param (
                             pstr
                           , 'Estabelecimentos'
                           , 'VARCHAR2'
                           , 'MULTISELECT'
                           , 'S'
                           , NULL
                           , NULL
                           ,    'SELECT * FROM (SELECT A.COD_ESTAB, A.COD_ESTAB || '' - '' || B.COD_ESTADO || '' - '' || A.CGC || '' - '' || INITCAP(A.BAIRRO) || '' / '' || INITCAP(A.CIDADE) FROM ESTABELECIMENTO A, ESTADO B, MSAFI.DSP_ESTABELECIMENTO C WHERE A.COD_EMPRESA  = '''
                             || mcod_empresa
                             || ''' AND B.IDENT_ESTADO = A.IDENT_ESTADO AND A.COD_EMPRESA = C.COD_EMPRESA AND A.COD_ESTAB = C.COD_ESTAB  AND B.COD_ESTADO LIKE :3 '
                             || ' UNION ALL SELECT COD_ESTAB, COD_ESTAB || '' - '' || COD_ESTADO || '' - '' || CGC ||'' - ''|| INITCAP(BAIRRO) || '' / '' || INITCAP(CIDADE) FROM ESTAB_INTERCOMPANY_DPSP '
                             || ' WHERE TIPO = ''C'' AND COD_ESTADO LIKE :3 ) ORDER BY 1'
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
        RETURN 'Customizados';
    END;

    FUNCTION classificacao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Customizados';
    END;

    FUNCTION orientacao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'PORTRAIT';
    END;

    FUNCTION executar ( pdt_ini DATE
                      , pcd_cproc VARCHAR2
                      , pcod_estado VARCHAR2
                      , flg_acao CHAR
                      , pstatus VARCHAR2
                      , flg_arquivo CHAR
                      , pcod_estab lib_proc.vartab )
        RETURN INTEGER
    IS
        pdt_fim DATE := LAST_DAY ( pdt_ini );
        pnm_cproc VARCHAR2 ( 100 );
        pnm_tipo VARCHAR2 ( 100 );

        v_data_inicial DATE := pdt_ini;
        v_data_final DATE := pdt_fim;
        pdt_periodo NUMBER ( 6 )
            := TO_NUMBER ( TO_CHAR ( pdt_ini
                                   , 'YYYYMM' ) );
        v_data_hora_ini VARCHAR2 ( 20 );
        p_proc_instance VARCHAR2 ( 30 );
        v_existe_error INTEGER := 0;
        v_count_param INTEGER := 0;
    BEGIN
        -- CRIAÇÃO: PROCESSO
        mproc_id :=
            lib_proc.new ( psp_nome => $$plsql_unit
                         , prows => 48
                         , pcols => 200 );

        --TELA DW
        lib_proc.add_tipo ( pproc_id => mproc_id
                          , ptipo => 1
                          , ptitulo =>    TO_CHAR ( SYSDATE
                                                  , 'YYYYMMDDHH24MISS' )
                                       || '_Encerr_Status_Rel'
                          , ptipo_arq => 1 );

        vn_pagina := 1;
        vn_linha := 48;

        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT="DD/MM/YYYY"';

        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS= '',.'' ';

        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        mnm_usuario := lib_parametros.recuperar ( 'USUARIO' );

        SELECT DISTINCT nm_cproc
          INTO pnm_cproc
          FROM msafi.dpsp_msaf_encerr_status_rel a
         WHERE cd_cproc = pcd_cproc
           AND TO_DATE ( dt_manutencao
                       , 'DD/MM/YYYY HH24:MI:SS' ) = (SELECT MAX ( TO_DATE ( b.dt_manutencao
                                                                           , 'DD/MM/YYYY HH24:MI:SS' ) )
                                                        FROM msafi.dpsp_msaf_encerr_status_rel b
                                                       WHERE b.cd_cproc = a.cd_cproc);

        SELECT DISTINCT nm_tipo
          INTO pnm_tipo
          FROM msafi.dpsp_msaf_encerr_status_rel a
         WHERE cd_cproc = pcd_cproc
           AND TO_DATE ( dt_manutencao
                       , 'DD/MM/YYYY HH24:MI:SS' ) = (SELECT MAX ( TO_DATE ( b.dt_manutencao
                                                                           , 'DD/MM/YYYY HH24:MI:SS' ) )
                                                        FROM msafi.dpsp_msaf_encerr_status_rel b
                                                       WHERE b.cd_cproc = a.cd_cproc);

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
                      , pnm_cproc
                      , pnm_tipo );
        END LOOP;

        loga ( '---INI DO PROCESSAMENTO---'
             , FALSE );
        loga ( '<< PERIODO DE: ' || v_data_inicial || ' A ' || v_data_final || ' >>'
             , FALSE );

        dbms_application_info.set_module ( 'Encerr Status Rel'
                                         , 'CPROC' );

        --=================================================================================
        -- ALTERAR
        --=================================================================================
        -- RECUPERAR ULTIMA DESCRIÇÃO UTILIZADA NO CUSTOMIZADO

        IF flg_acao = 'A' THEN
            -- A ALTERAÇÃO IRÁ INSERIR UM NOVO REGISTRO, QUE SERÁ CONSIDERADO COMO VALIDADE
            -- DO STATUS DO PERIODO ABERTO/ENCERRADO
            FOR v_cod_estab IN pcod_estab.FIRST .. pcod_estab.LAST LOOP
                --PROCEDURE PARA OUTROS CUSTOMIZADOS TAMBÉM ENCERRAREM STATUS
                msaf.dpsp_suporte_cproc_process.inserir_status_rel ( mcod_empresa
                                                                   , pcod_estab ( v_cod_estab )
                                                                   , pdt_periodo
                                                                   , pcd_cproc
                                                                   , pnm_cproc
                                                                   , pnm_tipo
                                                                   , pstatus
                                                                   , -- Status: 1-Encerrado/0-Aberto
                                                                    $$plsql_unit
                                                                   , -- Package atual
                                                                    mproc_id
                                                                   , mnm_usuario
                                                                   , v_data_hora_ini );
            END LOOP;
        END IF;

        --=================================================================================
        -- CONSULTAR
        --=================================================================================
        --O CUSTOMIZADO SEMPRE IRÁ CONSULTAR

        FOR v_cod_estab IN pcod_estab.FIRST .. pcod_estab.LAST LOOP
            imprimir ( pdt_periodo
                     , pcod_estab ( v_cod_estab )
                     , pcd_cproc );
        END LOOP;

        --Arquivo CSV
        IF flg_arquivo = 'S' THEN
            lib_proc.add_tipo ( mproc_id
                              , 2
                              , 'Encerr_Status_Rel_' || pdt_periodo || '.csv'
                              , 2 );

            --Cabeçalho CSV
            vs_mlinha := NULL;
            vs_mlinha := 'COD_EMPRESA;COD_ESTAB;NM_CPROC;NM_TIPO;DT_PERIODO;STATUS;PROC_ID;NM_USUARIO;DT_MANUTENCAO;';
            lib_proc.add ( vs_mlinha
                         , NULL
                         , NULL
                         , 2 );

            FOR v_cod_estab IN pcod_estab.FIRST .. pcod_estab.LAST LOOP
                gerar_arquivo ( pdt_periodo
                              , pcod_estab ( v_cod_estab )
                              , pcd_cproc );
            END LOOP;
        END IF;

        loga ( '---FIM DO PROCESSAMENTO [SUCESSO]---'
             , FALSE );

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
            lib_proc.add ( 'ERRO!' );
            lib_proc.add ( dbms_utility.format_error_backtrace );

            lib_proc.close;
            COMMIT;
            RETURN mproc_id;
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

    PROCEDURE cabecalho ( pnm_empresa VARCHAR2
                        , pcnpj VARCHAR2
                        , v_data_hora_ini VARCHAR2
                        , pnm_cproc VARCHAR2
                        , pnm_tipo VARCHAR2 )
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
                          , 'CNPJ:' || pcnpj
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
            lib_proc.add ( vs_mlinha );
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
                          , 'Processo Customizado (Relatório):'
                          , 1 );
            lib_proc.add ( vs_mlinha
                         , NULL
                         , NULL
                         , 1 );

            vs_mlinha := NULL;
            vs_mlinha :=
                lib_str.w ( vs_mlinha
                          , pnm_tipo
                          , 1 );
            lib_proc.add ( vs_mlinha
                         , NULL
                         , NULL
                         , 1 );

            vs_mlinha := NULL;
            vs_mlinha :=
                lib_str.w ( vs_mlinha
                          , pnm_cproc
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

            vs_mlinha := NULL;
            vs_mlinha :=
                lib_str.w ( vs_mlinha
                          , 'FILIAL'
                          , 2 );
            vs_mlinha :=
                lib_str.w ( vs_mlinha
                          , '|'
                          , 10 );
            vs_mlinha :=
                lib_str.w ( vs_mlinha
                          , 'PERIODO'
                          , 12 );
            vs_mlinha :=
                lib_str.w ( vs_mlinha
                          , '|'
                          , 21 );
            vs_mlinha :=
                lib_str.w ( vs_mlinha
                          , 'STATUS'
                          , 23 );
            vs_mlinha :=
                lib_str.w ( vs_mlinha
                          , '|'
                          , 35 );
            vs_mlinha :=
                lib_str.w ( vs_mlinha
                          , 'USUÁRIO'
                          , 37 );
            vs_mlinha :=
                lib_str.w ( vs_mlinha
                          , '|'
                          , 64 );
            vs_mlinha :=
                lib_str.w ( vs_mlinha
                          , 'DATA DE MANUTENÇÃO'
                          , 66 );
            lib_proc.add ( vs_mlinha
                         , NULL
                         , NULL
                         , 1 );

            vn_linha := vn_linha + 1;

            vs_mlinha := NULL;
            vs_mlinha :=
                lib_str.w ( vs_mlinha
                          , ' '
                          , 1 );
            lib_proc.add ( vs_mlinha
                         , NULL
                         , NULL
                         , 1 );

            vn_linha := vn_linha + 1;
        END IF;

        IF vn_linha >= 48
       AND vn_pagina = 2 THEN
            NULL;
        END IF;
    END cabecalho;

    PROCEDURE imprimir ( pdt_periodo NUMBER
                       , pcod_estab VARCHAR2
                       , pcd_cproc VARCHAR2 )
    IS
        CURSOR c_status
        IS
            SELECT   cod_estab
                   , dt_periodo
                   , status
                   , nm_usuario
                   , dt_manutencao
                FROM msafi.dpsp_msaf_encerr_status_rel
               WHERE cod_empresa = mcod_empresa
                 AND cod_estab = pcod_estab
                 AND dt_periodo = pdt_periodo
                 AND cd_cproc = pcd_cproc
            ORDER BY dt_manutencao DESC
                   , cod_estab;
    BEGIN
        vs_mlinha := NULL;

        FOR c IN c_status LOOP
            vs_mlinha := NULL;
            vs_mlinha :=
                lib_str.w ( vs_mlinha
                          , c.cod_estab
                          , 2 );
            vs_mlinha :=
                lib_str.w ( vs_mlinha
                          , '|'
                          , 10 );
            vs_mlinha :=
                lib_str.w ( vs_mlinha
                          , c.dt_periodo
                          , 12 );
            vs_mlinha :=
                lib_str.w ( vs_mlinha
                          , '|'
                          , 21 );
            vs_mlinha :=
                lib_str.w ( vs_mlinha
                          , SUBSTR ( c.status
                                   , 1
                                   , 37 )
                          , 23 );
            vs_mlinha :=
                lib_str.w ( vs_mlinha
                          , '|'
                          , 35 );
            vs_mlinha :=
                lib_str.w ( vs_mlinha
                          , SUBSTR ( c.nm_usuario
                                   , 1
                                   , 25 )
                          , 37 );
            vs_mlinha :=
                lib_str.w ( vs_mlinha
                          , '|'
                          , 64 );
            vs_mlinha :=
                lib_str.w ( vs_mlinha
                          , c.dt_manutencao
                          , 66 );
            lib_proc.add ( vs_mlinha
                         , NULL
                         , NULL
                         , 1 );

            vn_linha := vn_linha + 1;
        END LOOP;
    END;

    PROCEDURE gerar_arquivo ( pdt_periodo NUMBER
                            , pcod_estab VARCHAR2
                            , pcd_cproc VARCHAR2 )
    IS
        CURSOR c_status
        IS
            SELECT cod_empresa
                 , cod_estab
                 , nm_cproc
                 , nm_tipo
                 , dt_periodo
                 , status
                 , proc_id
                 , nm_usuario
                 , dt_manutencao
              FROM msafi.dpsp_msaf_encerr_status_rel
             WHERE cod_empresa = mcod_empresa
               AND cod_estab = pcod_estab
               AND dt_periodo = pdt_periodo
               AND cd_cproc = pcd_cproc;
    BEGIN
        FOR c IN c_status LOOP
            vs_mlinha := NULL;
            vs_mlinha :=
                   c.cod_empresa
                || ';'
                || c.cod_estab
                || ';'
                || c.nm_cproc
                || ';'
                || c.nm_tipo
                || ';'
                || c.dt_periodo
                || ';'
                || c.status
                || ';'
                || c.proc_id
                || ';'
                || c.nm_usuario
                || ';'
                || c.dt_manutencao;

            lib_proc.add ( vs_mlinha
                         , NULL
                         , NULL
                         , 2 );
        END LOOP;
    END;
END dpsp_encerr_status_rel_cproc;
/
SHOW ERRORS;
