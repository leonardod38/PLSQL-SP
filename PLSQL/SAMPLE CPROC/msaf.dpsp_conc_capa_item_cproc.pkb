Prompt Package Body DPSP_CONC_CAPA_ITEM_CPROC;
--
-- DPSP_CONC_CAPA_ITEM_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_conc_capa_item_cproc
IS
    mproc_id NUMBER;
    vn_linha NUMBER := 0;
    vn_pagina NUMBER := 0;
    mnm_usuario usuario_estab.cod_usuario%TYPE;
    mcod_empresa estabelecimento.cod_empresa%TYPE;
    v_class VARCHAR2 ( 1 ) := 'a';

    --Tipo, Nome e Descrição do Customizado
    mnm_tipo VARCHAR2 ( 100 ) := 'Equalização';
    mnm_cproc VARCHAR2 ( 100 ) := 'Relatorio de conciliação de capa com item';
    mds_cproc VARCHAR2 ( 100 ) := 'Processo para verificar conciliacao de dados de capa com item';

    v_sel_data_fim VARCHAR2 ( 260 )
        := ' SELECT TRUNC( TO_DATE( :1 ,''DD/MM/YYYY'') + ROWNUM - 1) AS DATA_FIM, TRUNC( TO_DATE( :1 ,''DD/MM/YYYY'') + ROWNUM - 1) AS DATA_FIM FROM DUAL CONNECT BY ROWNUM <= LAST_DAY( TO_DATE( :1 ,''DD/MM/YYYY'') ) - TO_DATE( :1 ,''DD/MM/YYYY'') + 1 ORDER BY 1 DESC ';

    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );
    BEGIN
        mnm_usuario := lib_parametros.recuperar ( UPPER ( 'USUARIO' ) );
        mcod_empresa := lib_parametros.recuperar ( UPPER ( 'EMPRESA' ) );

        --PPERIODO
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
                            'VARCHAR2'
                           , 'COMBOBOX'
                           , 'S'
                           , NULL
                           , '##########'
                           , v_sel_data_fim );

        lib_proc.add_param (
                             pparam => pstr
                           , ptitulo => 'Movimento'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'COMBOBOX'
                           , pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => '####################'
                           , pvalores => 'SELECT 1, ''1-Entrada/Saida'' from dual union all SELECT 1, ''2-Entrada'' from dual union all SELECT 1, ''3-Saida'' from dual  ORDER BY 1'
        );

        lib_proc.add_param (
                             pparam => pstr
                           , ptitulo => 'UF'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'COMBOBOX'
                           , pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => '####################'
                           , pvalores =>    'SELECT COD_ESTADO, COD_ESTADO || '' - '' || DESCRICAO TXT FROM ESTADO '
                                         || ' WHERE COD_ESTADO IN (SELECT COD_ESTADO FROM DSP_ESTABELECIMENTO_V) UNION ALL SELECT ''%'', ''Todas as UFs'' FROM DUAL'
                                         || '  ORDER BY 1'
        );
        lib_proc.add_param (
                             pstr
                           , 'Estabelecimentos'
                           , --P_LOJAS
                            'VARCHAR2'
                           , 'MULTISELECT'
                           , 'S'
                           , NULL
                           , NULL
                           ,    ' Select COD_ESTAB cod , Cod_Estado||'' - ''||COD_ESTAB||'' - ''||Initcap(ENDER) ||'' ''||(case when Tipo = ''C'' then ''(CD)'' end) loja'
                             || --
                               ' From dsp_estabelecimento_v Where 1=1 '
                             || ' and cod_empresa = '''
                             || mcod_empresa
                             || ''' and cod_estado like :4  ORDER BY Tipo, 2'
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

    PROCEDURE load_excel ( p_periodo DATE
                         , p_movto_e_s VARCHAR2
                         , p_cod_estab VARCHAR2 )
    IS
        v_text01 VARCHAR2 ( 10000 );
    BEGIN
        FOR c IN ( SELECT cod_empresa
                        , cod_estab
                        , data_fiscal
                        , movto_e_s
                        , cod_fis_jur
                        , num_docfis
                        , serie_docfis
                        , valor_item
                        , valor_capa
                        , id
                     FROM (SELECT a.cod_empresa
                                , a.cod_estab
                                , a.data_fiscal
                                , a.movto_e_s
                                , b.cod_fis_jur
                                , a.num_docfis
                                , a.serie_docfis
                                , ( SELECT SUM ( b.vlr_contab_item )
                                      FROM msaf.x08_itens_merc b
                                     WHERE b.cod_empresa = a.cod_empresa
                                       AND b.cod_estab = a.cod_estab
                                       AND b.data_fiscal = a.data_fiscal
                                       AND b.movto_e_s = a.movto_e_s
                                       AND b.norm_dev = a.norm_dev
                                       AND b.ident_docto = a.ident_docto
                                       AND b.ident_fis_jur = a.ident_fis_jur
                                       AND b.num_docfis = a.num_docfis
                                       AND b.serie_docfis = a.serie_docfis
                                       AND b.sub_serie_docfis = a.sub_serie_docfis )
                                      valor_item
                                , a.vlr_tot_nota AS valor_capa
                                , a.num_controle_docto id
                                , DECODE ( a.movto_e_s, '9', 2, 3 ) nf_es
                             FROM msaf.x07_docto_fiscal a
                                , msaf.x04_pessoa_fis_jur b
                            WHERE a.cod_empresa = mcod_empresa
                              AND a.cod_estab = p_cod_estab
                              AND a.ident_fis_jur = b.ident_fis_jur
                              AND a.cod_class_doc_fis = '1'
                              AND a.situacao <> 'S'
                              AND a.data_fiscal = p_periodo) aux
                    WHERE 1 = 1
                      AND valor_capa <> valor_item
                      AND nf_es = DECODE ( p_movto_e_s,  '1', nf_es,  '2', 2,  '3', 3 ) ) LOOP
            IF v_class = 'a' THEN
                v_class := 'b';
            ELSE
                v_class := 'a';
            END IF;

            v_text01 :=
                dsp_planilha.linha ( p_conteudo =>    dsp_planilha.campo ( c.cod_empresa )
                                                   || --
                                                     dsp_planilha.campo ( c.cod_estab )
                                                   || --
                                                     dsp_planilha.campo ( TO_CHAR ( c.data_fiscal
                                                                                  , 'dd/mm/yyyy' ) )
                                                   || --
                                                     dsp_planilha.campo ( c.movto_e_s )
                                                   || --
                                                     dsp_planilha.campo ( c.cod_fis_jur )
                                                   || --
                                                     dsp_planilha.campo ( c.num_docfis )
                                                   || --
                                                     dsp_planilha.campo ( c.serie_docfis )
                                                   || --
                                                     dsp_planilha.campo ( c.valor_item )
                                                   || --
                                                     dsp_planilha.campo ( c.valor_capa )
                                                   || --
                                                     dsp_planilha.campo ( c.id ) --
                                   , p_class => v_class );
            lib_proc.add ( v_text01
                         , ptipo => 99 );
        END LOOP;

        COMMIT;
    END load_excel;

    FUNCTION executar ( p_dt_inicio DATE
                      , p_dt_fim DATE
                      , p_movto_e_s VARCHAR2
                      , p_uf VARCHAR2
                      , p_lojas lib_proc.vartab )
        RETURN INTEGER
    IS
    BEGIN
        -- Criação: Processo
        mproc_id := lib_proc.new ( psp_nome => $$plsql_unit );
        COMMIT;

        /*    --Tela DW
        lib_proc.add_tipo(pproc_id  => mproc_id,
                          ptipo     => 1,
                          ptitulo   => to_char(SYSDATE, 'YYYYMMDDHH24MISS') ||
                                       '_CONC_CAPA_ITEM_REL',
                          ptipo_arq => 1);*/

        vn_pagina := 1;
        vn_linha := 48;

        --EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT="DD/MM/YYYY"';
        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT="YYYYMMDD"';

        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS= '',.'' ';

        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        mnm_usuario := lib_parametros.recuperar ( 'USUARIO' );

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
        loga ( '<< PERIODO DE: ' || p_dt_inicio || ' A ' || p_dt_fim || ' >>'
             , FALSE );
        loga ( '<< UF:' || p_uf || ' >>'
             , FALSE );

        -- RELATORIO
        -- cabecalho
        loga ( '>>> Inicio '
             , FALSE );

        lib_proc.add_tipo ( mproc_id
                          , 99
                          , 'REL_CONCILIACAO_CAPA_ITEM_NF.XLS'
                          , 2 );

        lib_proc.add ( dsp_planilha.header
                     , ptipo => 99 );
        lib_proc.add ( dsp_planilha.tabela_inicio
                     , ptipo => 99 );

        lib_proc.add ( dsp_planilha.linha ( p_conteudo => dsp_planilha.campo (
                                                                               'Conciliação de dados entre capa e item'
                                                                             , p_custom => 'COLSPAN=10 BGCOLOR=BLUE'
                                                         ) --
                                          , p_class => 'h' )
                     , ptipo => 99 );

        lib_proc.add ( dsp_planilha.linha (
                                            p_conteudo =>    dsp_planilha.campo ( 'COD_EMPRESA' )
                                                          || --
                                                            dsp_planilha.campo ( 'COD_ESTAB' )
                                                          || --
                                                            dsp_planilha.campo ( 'DATA_FISCAL' )
                                                          || --
                                                            dsp_planilha.campo ( 'NORM_DEV' )
                                                          || --
                                                            dsp_planilha.campo ( 'COD_FIS_JUR' )
                                                          || --
                                                            dsp_planilha.campo ( 'NUM_DOCFIS' )
                                                          || --
                                                            dsp_planilha.campo ( 'SERIE_DOCFIS' )
                                                          || --
                                                            dsp_planilha.campo ( 'VALOR_TOTAL_ITEM' )
                                                          || --
                                                            dsp_planilha.campo ( 'VALOR_CAPA' )
                                                          || --
                                                            dsp_planilha.campo ( 'ID' ) --
                                          , p_class => 'h'
                       )
                     , ptipo => 99 );

        -- corpo

        FOR c IN ( SELECT     p_dt_inicio + ROWNUM - 1 AS data_par
                         FROM DUAL
                   CONNECT BY ROWNUM <= p_dt_fim - p_dt_inicio + 1
                     ORDER BY 1 ) LOOP
            loga ( 'Dia:' || c.data_par
                 , FALSE );

            FOR est IN p_lojas.FIRST .. p_lojas.LAST --(1)
                                                    LOOP
                dbms_application_info.set_module ( $$plsql_unit
                                                 , 'Dia:' || c.data_par || ' Loja:' || p_lojas ( est ) );

                load_excel ( c.data_par
                           , p_movto_e_s
                           , p_lojas ( est ) );

                COMMIT;
            END LOOP;

            COMMIT;
        END LOOP;

        loga ( 'Fim'
             , FALSE );
        -- rodape
        lib_proc.add ( dsp_planilha.tabela_fim
                     , ptipo => 99 );
        COMMIT;
        --

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
                        , p_dt_inicio
                        , p_dt_fim
                        , SQLERRM
                        , 'E'
                        , TO_CHAR ( SYSDATE
                                  , 'DD/MM/YYYY HH24:MI:SS' ) );
            -----------------------------------------------------------------

            lib_proc.close;
            COMMIT;
            RETURN mproc_id;
    END;
END dpsp_conc_capa_item_cproc;
/
SHOW ERRORS;
