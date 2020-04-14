Prompt Package Body DPSP_NF_ENTRADA_REL_CPROC;
--
-- DPSP_NF_ENTRADA_REL_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_nf_entrada_rel_cproc
IS
    mproc_id NUMBER;
    vn_linha NUMBER := 0;
    vn_pagina NUMBER := 0;
    mnm_usuario usuario_estab.cod_usuario%TYPE;
    mcod_empresa estabelecimento.cod_empresa%TYPE;
    vs_mlinha VARCHAR2 ( 4000 );

    --Tipo, Nome e Descrição do Customizado
    mnm_tipo VARCHAR2 ( 100 ) := 'Equalização';
    mnm_cproc VARCHAR2 ( 100 ) := 'Relatorio de Notas de Entrada - verifica quantidade';
    mds_cproc VARCHAR2 ( 100 )
        := 'Processo para verificar quantidade de registros de Notas de Entrada na tabela auxiliar';

    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );
    BEGIN
        mnm_usuario := lib_parametros.recuperar ( UPPER ( 'USUARIO' ) );
        mcod_empresa := lib_parametros.recuperar ( UPPER ( 'EMPRESA' ) );

        --PPERIODO
        lib_proc.add_param ( pparam => pstr
                           , ptitulo => 'Periodo'
                           , ptipo => 'DATE'
                           , pcontrole => 'textbox'
                           , pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => 'MM/YYYY' );

        lib_proc.add_param ( pparam => pstr
                           , ptitulo => 'Processar checagem'
                           , ptipo => 'Varchar2'
                           , pcontrole => 'Checkbox'
                           , pmandatorio => 'S'
                           , pdefault => 'S'
                           , pmascara => NULL
                           , pvalores => 'S=Sim,N=Não'
                           , papresenta => 'N' );

        lib_proc.add_param ( pparam => pstr
                           , ptitulo => 'Extrair Relatorio'
                           , ptipo => 'Varchar2'
                           , pcontrole => 'Checkbox'
                           , pmandatorio => 'S'
                           , pdefault => 'S'
                           , pmascara => NULL
                           , pvalores => 'S=Sim,N=Não'
                           , papresenta => 'N' );

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

            v_txt_email := 'ERRO no ' || mnm_cproc || '!';
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
                     , $$plsql_unit );
        ELSE
            v_txt_email := 'Processo ' || mnm_cproc || ' com SUCESSO.';
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
                     , $$plsql_unit );
        END IF;
    END;

    PROCEDURE load_excel ( pperiodo DATE )
    IS
        v_sql VARCHAR2 ( 10000 );
        v_text01 VARCHAR2 ( 10000 );
        v_class VARCHAR2 ( 1 ) := 'a';
        c_conc SYS_REFCURSOR;

        TYPE cur_tab_conc IS RECORD
        (
            cod_estado VARCHAR2 ( 2 )
          , cod_estab VARCHAR2 ( 6 )
          , num_controle_docto VARCHAR2 ( 14 )
          , num_docfis VARCHAR2 ( 14 )
          , num_autentic_nfe VARCHAR2 ( 80 )
          , serie_docfis VARCHAR2 ( 3 )
          , data_emissao DATE
          , data_fiscal DATE
          , vlr_tot_nota NUMBER ( 17, 2 )
          , cod_estado_ent VARCHAR2 ( 6 )
          , cod_fis_jur VARCHAR2 ( 14 )
          , check_entrada VARCHAR2 ( 3 )
          , data_fiscal_ent DATE
          , num_controle_docto_ent VARCHAR2 ( 14 )
        );

        TYPE c_tab_conc IS TABLE OF cur_tab_conc;

        tab_e c_tab_conc;
    BEGIN
        loga ( '>>> Inicio '
             , FALSE );

        lib_proc.add_tipo ( mproc_id
                          , 99
                          ,    'REL_BATIMENTO_'
                            || mcod_empresa
                            || '_'
                            || TO_CHAR ( pperiodo
                                       , 'YYYYMM' )
                            || '_NF_ENTRADA.XLS'
                          , 2 );

        lib_proc.add ( dsp_planilha.header
                     , ptipo => 99 );
        lib_proc.add ( dsp_planilha.tabela_inicio
                     , ptipo => 99 );

        lib_proc.add ( dsp_planilha.linha ( p_conteudo => dsp_planilha.campo (
                                                                               'BATIMENTO DE QUANTIDADE ENTRE TABELA DEFINITIVA E TABELA AUXILIAR DE ENTRADA'
                                                                             , p_custom => 'COLSPAN=7 BGCOLOR=BLUE'
                                                         ) --
                                          , p_class => 'h' )
                     , ptipo => 99 );

        lib_proc.add ( dsp_planilha.linha (
                                            p_conteudo =>    dsp_planilha.campo ( 'PERIODO' )
                                                          || --
                                                            dsp_planilha.campo ( 'COD_ESTAB' )
                                                          || --
                                                            dsp_planilha.campo ( 'NORM_DEV' )
                                                          || --
                                                            dsp_planilha.campo ( 'SITUACAO' )
                                                          || --
                                                            dsp_planilha.campo ( 'QTDE_REGISTROS_X' )
                                                          || --
                                                            dsp_planilha.campo ( 'QTDE_REGISTROS_EQUALIZADA' )
                                                          || --
                                                            dsp_planilha.campo ( 'DIFERENCA' ) --
                                          , p_class => 'h'
                       )
                     , ptipo => 99 );

        FOR c IN ( SELECT a.*
                     FROM (SELECT NVL ( x.periodo, nf.periodo ) periodo
                                , NVL ( x.cod_estab, nf.cod_estab ) cod_estab
                                , NVL ( x.norm_dev, nf.norm_dev ) norm_dev
                                , NVL ( x.situacao, nf.situacao ) situacao
                                , NVL ( x.qtde_registros, 0 ) qtde_registros_x
                                , NVL ( nf.qtde_registros, 0 ) qtde_registros_equalizada
                                , ( NVL ( x.qtde_registros, 0 ) - NVL ( nf.qtde_registros, 0 ) ) diferenca
                             FROM msafi.dpsp_nf_entrada_total x
                                , msafi.dpsp_nf_entrada_total nf
                            WHERE 1 = 1
                              AND x.cod_estab = nf.cod_estab(+)
                              AND x.norm_dev = nf.norm_dev(+)
                              AND x.situacao = nf.situacao(+)
                              AND x.periodo = nf.periodo(+)
                              AND x.cod_origem = 1
                              AND nf.cod_origem(+) = 2
                           UNION ALL
                           SELECT NVL ( x.periodo, nf.periodo ) periodo
                                , NVL ( x.cod_estab, nf.cod_estab ) cod_estab
                                , NVL ( x.norm_dev, nf.norm_dev ) norm_dev
                                , NVL ( x.situacao, nf.situacao ) situacao
                                , NVL ( x.qtde_registros, 0 ) qtde_registros_x
                                , NVL ( nf.qtde_registros, 0 ) qtde_registros_equalizada
                                , ( NVL ( x.qtde_registros, 0 ) - NVL ( nf.qtde_registros, 0 ) ) diferenca
                             FROM msafi.dpsp_nf_entrada_total x
                                , msafi.dpsp_nf_entrada_total nf
                            WHERE 1 = 1
                              AND x.cod_estab(+) = nf.cod_estab
                              AND x.norm_dev(+) = nf.norm_dev
                              AND x.situacao(+) = nf.situacao
                              AND x.periodo(+) = nf.periodo
                              AND x.cod_origem(+) = 1
                              AND nf.cod_origem = 2
                              AND x.proc_id IS NULL) a
                    WHERE 1 = 1
                      AND periodo = TO_CHAR ( pperiodo
                                            , 'YYYYMM' )--and diferenca <>0
                                                         ) LOOP
            IF v_class = 'a' THEN
                v_class := 'b';
            ELSE
                v_class := 'a';
            END IF;

            v_text01 :=
                dsp_planilha.linha (
                                     p_conteudo =>    dsp_planilha.campo ( c.periodo )
                                                   || --
                                                     dsp_planilha.campo ( c.cod_estab )
                                                   || --
                                                     dsp_planilha.campo ( c.norm_dev )
                                                   || --
                                                     dsp_planilha.campo ( c.situacao )
                                                   || --
                                                     dsp_planilha.campo ( c.qtde_registros_x )
                                                   || --
                                                     dsp_planilha.campo ( c.qtde_registros_equalizada )
                                                   || --
                                                     dsp_planilha.campo ( c.diferenca ) --
                                   , p_class => v_class
                );
            lib_proc.add ( v_text01
                         , ptipo => 99 );
        END LOOP;

        COMMIT;

        lib_proc.add ( dsp_planilha.tabela_fim
                     , ptipo => 99 );
    END load_excel;

    PROCEDURE carregar_contagem ( pperiodo DATE )
    IS
        v_sql VARCHAR2 ( 4000 );
    BEGIN
        loga ( 'CARREGAR_CONTAGEM_REL-INI'
             , FALSE );

        EXECUTE IMMEDIATE ( 'ALTER SESSION SET CURSOR_SHARING = FORCE' );

        -- REGISTRA O ANDAMENTO DO PROCESSO NA V$SESSION
        dbms_application_info.set_module ( $$plsql_unit
                                         , 'Inicio' );

        dbms_output.put_line (    TRUNC ( pperiodo
                                        , 'MM' )
                               || ';'
                               || LAST_DAY ( pperiodo ) );

        loga ( 'LIMPEZA'
             , FALSE );

        DELETE msafi.dpsp_nf_entrada_total
         WHERE periodo = TO_CHAR ( pperiodo
                                 , 'YYYYMM' );

        COMMIT;


        loga (    TO_CHAR ( pperiodo
                          , 'YYYYMM' )
               || ' - '
               || TO_CHAR ( pperiodo
                          , 'YYYYMMDD' )
               || ' - '
               || TO_CHAR ( TRUNC ( pperiodo
                                  , 'MM' )
                          , 'YYYYMMDD' )
               || ' - '
               || TO_CHAR ( LAST_DAY ( pperiodo )
                          , 'YYYYMMDD' )
             , FALSE );

        loga ( 'TABELA DEFINITIVA'
             , FALSE );

        -- DELETE
        v_sql := '';
        v_sql := v_sql || ' insert /*+append*/ into MSAFI.DPSP_NF_ENTRADA_total';
        v_sql := v_sql || ' SELECT ';
        v_sql :=
               v_sql
            || TO_CHAR ( pperiodo
                       , 'YYYYMM' )
            || ',';
        v_sql := v_sql || '   1 cod_origem, ';
        v_sql := v_sql || '   x07.cod_estab, ';
        v_sql := v_sql || '   x07.norm_dev, ';
        v_sql := v_sql || '   x07.situacao, ';
        v_sql := v_sql || '   COUNT(1) qtde_registros, ';
        v_sql := v_sql || mproc_id || ' proc_id, ';
        v_sql := v_sql || '   sysdate dt_criacao ';
        v_sql := v_sql || '   FROM msaf.x08_itens_merc PARTITION ';
        v_sql := v_sql || ' FOR(TO_DATE(''';
        v_sql :=
               v_sql
            || TO_CHAR ( pperiodo
                       , 'YYYYMMDD' );
        v_sql := v_sql || ''',''YYYYMMDD'')) ';
        v_sql := v_sql || '   x08, ';
        v_sql := v_sql || '        msaf.x07_docto_fiscal PARTITION ';
        v_sql := v_sql || ' FOR(TO_DATE(''';
        v_sql :=
               v_sql
            || TO_CHAR ( pperiodo
                       , 'YYYYMMDD' );
        v_sql := v_sql || ''',''YYYYMMDD'')) ';
        v_sql := v_sql || ' x07 ';
        v_sql := v_sql || '  WHERE x07.cod_empresa = x08.cod_empresa ';
        v_sql := v_sql || '    AND x07.cod_estab = x08.cod_estab ';
        v_sql := v_sql || '    AND x07.data_fiscal = x08.data_fiscal ';
        v_sql := v_sql || '    AND x07.movto_e_s = x08.movto_e_s ';
        v_sql := v_sql || '    AND x07.norm_dev = x08.norm_dev ';
        v_sql := v_sql || '    AND x07.ident_docto = x08.ident_docto ';
        v_sql := v_sql || '    AND x07.ident_fis_jur = x08.ident_fis_jur ';
        v_sql := v_sql || '    AND x07.num_docfis = x08.num_docfis ';
        v_sql := v_sql || '    AND x07.serie_docfis = x08.serie_docfis ';
        v_sql := v_sql || '    AND x07.sub_serie_docfis = x08.sub_serie_docfis ';
        v_sql := v_sql || '    AND x07.movto_e_s <> ''9'' ';
        v_sql := v_sql || '    AND x07.data_fiscal between ';
        v_sql := v_sql || ' TO_DATE(''';
        v_sql :=
               v_sql
            || TO_CHAR ( TRUNC ( pperiodo
                               , 'MM' )
                       , 'YYYYMMDD' );
        v_sql := v_sql || ''',''YYYYMMDD'') ';
        v_sql := v_sql || ' and TO_DATE(''';
        v_sql :=
               v_sql
            || TO_CHAR ( LAST_DAY ( pperiodo )
                       , 'YYYYMMDD' );
        v_sql := v_sql || ''',''YYYYMMDD'') ';
        v_sql := v_sql || '  GROUP BY x07.cod_estab, x07.norm_dev, x07.situacao ';

        EXECUTE IMMEDIATE ( v_sql );



        COMMIT;

        loga ( 'TABELA AUXILIAR'
             , FALSE );

        v_sql := '';
        v_sql := v_sql || ' insert /*+append*/ into MSAFI.DPSP_NF_ENTRADA_total';
        v_sql := v_sql || ' SELECT ';
        v_sql :=
               v_sql
            || TO_CHAR ( pperiodo
                       , 'YYYYMM' )
            || ',';
        v_sql := v_sql || '   2 cod_origem, ';
        v_sql := v_sql || '   cod_estab, ';
        v_sql := v_sql || '   norm_dev, ';
        v_sql := v_sql || '   situacao, ';
        v_sql := v_sql || '   COUNT(1) qtde_registros, ';
        v_sql := v_sql || mproc_id || ' proc_id, ';
        v_sql := v_sql || '   sysdate dt_criacao ';
        v_sql := v_sql || '   FROM MSAFI.DPSP_NF_ENTRADA PARTITION ';
        v_sql := v_sql || ' FOR(TO_DATE(''';
        v_sql :=
               v_sql
            || TO_CHAR ( pperiodo
                       , 'YYYYMMDD' );
        v_sql := v_sql || ''',''YYYYMMDD'')) ';
        v_sql := v_sql || '   NF ';
        v_sql := v_sql || '  GROUP BY cod_estab, norm_dev, situacao ';

        EXECUTE IMMEDIATE ( v_sql );


        COMMIT;

        loga ( 'CARREGAR_CONTGEM_REL-FIM'
             , FALSE );
    END;

    FUNCTION executar ( pperiodo DATE
                      , pprocessar VARCHAR2
                      , prelatorio VARCHAR2 )
        RETURN INTEGER
    IS
        v_qtd INTEGER;
        v_validar_status INTEGER := 0;
        v_existe_origem CHAR := 'S';

        v_data_inicial DATE
            :=   TRUNC ( pperiodo )
               - (   TO_NUMBER ( TO_CHAR ( pperiodo
                                         , 'DD' ) )
                   - 1 );
        v_data_final DATE := LAST_DAY ( pperiodo );
        v_data_hora_ini VARCHAR2 ( 20 );
        p_proc_instance VARCHAR2 ( 30 );

        --PTAB_ENTRADA     VARCHAR2(50);
        v_sql VARCHAR2 ( 4000 );
        v_retorno_status VARCHAR2 ( 4000 );

        --Variaveis genericas
        v_descricao VARCHAR2 ( 4000 );
    BEGIN
        v_descricao :=
               'Periodo:'
            || TO_CHAR ( pperiodo
                       , 'mm/yyyy' );

        -- Criação: Processo
        mproc_id :=
            lib_proc.new ( psp_nome => $$plsql_unit
                         , --  prows    => 48,
                           --  pcols    => 200,
                           pdescricao => v_descricao );

        --Tela DW
        lib_proc.add_tipo ( pproc_id => mproc_id
                          , ptipo => 1
                          , ptitulo =>    TO_CHAR ( SYSDATE
                                                  , 'YYYYMMDDHH24MISS' )
                                       || '_NF_ENTRADA_REL'
                          , ptipo_arq => 1 );

        vn_pagina := 1;
        vn_linha := 48;

        --EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT="DD/MM/YYYY"';
        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT="YYYYMMDD"';

        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS= '',.'' ';

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


        loga ( '---INI DO PROCESSAMENTO---'
             , FALSE );
        loga ( '<< PERIODO DE: ' || v_data_inicial || ' A ' || v_data_final || ' >>'
             , FALSE );

        IF pprocessar = 'S' THEN
            carregar_contagem ( pperiodo );
        END IF;

        IF prelatorio = 'S' THEN
            load_excel ( pperiodo );
        END IF;

        lib_proc.add ( 'Favor verificar LOG para detalhes.'
                     , 1 );
        lib_proc.add ( ' '
                     , 1 );

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
            lib_proc.add ( 'ERRO!'
                         , 1 );
            lib_proc.add ( ' '
                         , 1 );
            lib_proc.add ( dbms_utility.format_error_backtrace
                         , 1 );

            --ENVIAR EMAIL DE ERRO-------------------------------------------
            envia_email ( mcod_empresa
                        , v_data_inicial
                        , v_data_final
                        , SQLERRM
                        , 'E'
                        , v_data_hora_ini );
            -----------------------------------------------------------------

            lib_proc.close;
            COMMIT;
            RETURN mproc_id;
    END;
END dpsp_nf_entrada_rel_cproc;
/
SHOW ERRORS;
