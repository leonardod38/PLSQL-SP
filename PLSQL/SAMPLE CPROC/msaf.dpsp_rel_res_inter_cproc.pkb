Prompt Package Body DPSP_REL_RES_INTER_CPROC;
--
-- DPSP_REL_RES_INTER_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_rel_res_inter_cproc
IS
    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );
    BEGIN
        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        mcod_estab := lib_parametros.recuperar ( 'ESTABELECIMENTO' );
        musuario := lib_parametros.recuperar ( 'USUARIO' );

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

        lib_proc.add_param ( pstr
                           , 'Cenário 1 - tags <ICMS> e <ICST> do XML de Entrada'
                           , --P_CENARIO1
                            'VARCHAR2'
                           , 'CHECKBOX'
                           , 'N'
                           , 'S'
                           , NULL );

        lib_proc.add_param ( pstr
                           , 'Cenário 2 - tag <ICRT> do XML de Entrada (contém Valor ST Ret + Base ST Ret)'
                           , --P_CENARIO2
                            'VARCHAR2'
                           , 'CHECKBOX'
                           , 'N'
                           , 'S'
                           , NULL );

        lib_proc.add_param ( pstr
                           , 'Cenário 3 - tag <ICRT> NÃO contém Valor ST Ret, contém Base ST Ret'
                           , --P_CENARIO3
                            'VARCHAR2'
                           , 'CHECKBOX'
                           , 'N'
                           , 'S'
                           , NULL );

        lib_proc.add_param ( pstr
                           , 'Cenário 4 - tag <ICRT> contém Valor ST Ret, NÃO contém Base ST Ret'
                           , --P_CENARIO4
                            'VARCHAR2'
                           , 'CHECKBOX'
                           , 'N'
                           , 'S'
                           , NULL );

        lib_proc.add_param ( pstr
                           , 'Cenário 5 - referente ao valor de Antecipação (GARE)'
                           , --P_CENARIO5
                            'VARCHAR2'
                           , 'CHECKBOX'
                           , 'N'
                           , 'S'
                           , NULL );

        lib_proc.add_param ( pstr
                           , 'NÃO foi possível determinar Cenário'
                           , --P_CENARIO6
                            'VARCHAR2'
                           , 'CHECKBOX'
                           , 'N'
                           , 'S'
                           , NULL );

        lib_proc.add_param (
                             pstr
                           ,    '                                   '
                             || '____________________________________________________'
                           , 'VARCHAR2'
                           , 'TEXT'
        );
        lib_proc.add_param ( pstr
                           , '1 - Relatório Sintético'
                           , --P_SINTETICO
                            'VARCHAR2'
                           , 'CHECKBOX'
                           , 'N'
                           , 'S'
                           , NULL );

        lib_proc.add_param ( pstr
                           , '2 - Relatório Analítico'
                           , --P_ANALITICO
                            'VARCHAR2'
                           , 'CHECKBOX'
                           , 'N'
                           , 'S'
                           , NULL );

        lib_proc.add_param (
                             pstr
                           ,    '                                   '
                             || '____________________________________________________'
                           , 'VARCHAR2'
                           , 'TEXT'
        );
        lib_proc.add_param (
                             pstr
                           , 'CDs'
                           , --P_CDS
                            'VARCHAR2'
                           , 'MULTISELECT'
                           , 'S'
                           , NULL
                           , NULL
                           ,    'SELECT A.COD_ESTAB, A.COD_ESTAB || '' - '' || B.COD_ESTADO || '' - '' || A.CGC || '' - '' || INITCAP(A.BAIRRO) || '' / '' || INITCAP(A.CIDADE) FROM ESTABELECIMENTO A, ESTADO B, MSAFI.DSP_ESTABELECIMENTO C WHERE A.COD_EMPRESA  = '''
                             || mcod_empresa
                             || ''' AND B.IDENT_ESTADO = A.IDENT_ESTADO AND A.COD_EMPRESA = C.COD_EMPRESA AND A.COD_ESTAB = C.COD_ESTAB AND C.TIPO = ''C'' ORDER BY B.COD_ESTADO, A.COD_ESTAB'
        );

        RETURN pstr;
    END; --FUNCTION PARAMETROS RETURN VARCHAR2 IS

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Relatório Ressarcimento INTERESTADUAL';
    END;

    FUNCTION tipo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Ressarcimento';
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
        RETURN 'Emitir Relatório de Ressarcimento INTERESTADUAL';
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
        msafi.dsp_control.writelog ( 'INTERR'
                                   , p_i_texto );
    ---> Para acompanhar processamento usar SELECT abaixo
    --SELECT * FROM DSP_LOG
    --WHERE LOG_TYPE = 'INTERR'
    --ORDER BY 3 DESC, 2 DESC
    ---
    END;

    FUNCTION moeda ( v_conteudo NUMBER )
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN TRIM ( TO_CHAR ( v_conteudo
                              , '9g999g999g990d0000' ) );
    END;

    FUNCTION executar ( p_data_ini DATE
                      , p_data_fim DATE
                      , p_cenario1 VARCHAR2
                      , p_cenario2 VARCHAR2
                      , p_cenario3 VARCHAR2
                      , p_cenario4 VARCHAR2
                      , p_cenario5 VARCHAR2
                      , p_cenario6 VARCHAR2
                      , p_sintetico VARCHAR2
                      , p_analitico VARCHAR2
                      , p_cds lib_proc.vartab )
        RETURN INTEGER
    IS
        mproc_id INTEGER;
        i1 INTEGER;

        v_proc_status NUMBER := 0;
        v_s_proc_status VARCHAR2 ( 16 );

        v_txt_temp VARCHAR2 ( 1024 ) := '';
        v_txt_basico VARCHAR2 ( 256 ) := '';

        TYPE a_estabs_t IS TABLE OF VARCHAR2 ( 6 );

        a_estabs a_estabs_t := a_estabs_t ( );

        --Variaveis genericas
        v_text01 VARCHAR2 ( 6000 );
        v_sep VARCHAR2 ( 1 ) := CHR ( 9 );
        p_proc_instance VARCHAR2 ( 30 );

        --
        TYPE cur_typ IS REF CURSOR;

        cr_cup cur_typ;
        --
        v_class VARCHAR2 ( 1 ) := 'a';
        v_url_vero_e_pdf VARCHAR2 ( 100 )
            := 'http://172.16.2.183/vero/aspx/handlers/AcoesDFe.ashx?acao=danfeent&chave=';
        v_url_vero_e_xml VARCHAR2 ( 100 ) := 'http://172.16.2.183/vero/aspx/handlers/AcoesDFe.ashx?acao=xmlent&chave=';
        v_url_vero_s_pdf VARCHAR2 ( 100 ) := 'http://172.16.2.183/vero/aspx/handlers/actions.ashx?action=DANFE&key=';
        ---
        v_vlr_icms_ressarc NUMBER := 0;
        v_vlr_icmsst_ressarc NUMBER := 0;
        v_vlr_icms_ant_res NUMBER := 0;
        v_cod_estab VARCHAR2 ( 6 );
        v_periodo VARCHAR2 ( 7 );
        v_total_ressarcir NUMBER := 0;
        ---
        v_sql VARCHAR2 ( 2000 );
        v_in VARCHAR2 ( 200 );
        c_sintetico SYS_REFCURSOR;

        ------------------------------------------------------------------------------------------------------------------------------------------------------
        --RANGE DE DATAS PARA BUSCAR VENDAS
        v_data_inicial DATE := p_data_ini; -- DATA INICIAL
        v_data_final DATE := p_data_fim; -- DATA FINAL
    ------------------------------------------------------------------------------------------------------------------------------------------------------

    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS='',.'' ';

        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        mproc_id :=
            lib_proc.new ( 'DPSP_REL_RES_INTER_CPROC'
                         , 48
                         , 150 );

        msafi.dsp_control.createprocess ( 'DPSP_R_INTER' --P_I_PROCID            IN VARCHAR2             , --VARCHAR2(16)
                                        , 'DPSP_REL_INTER' --P_I_PROC_DESCR        IN VARCHAR2             , --VARCHAR2(64)
                                        , NULL --P_I_DATA_INI          IN DATE     DEFAULT NULL,
                                        , NULL --P_I_DATA_FIM          IN DATE     DEFAULT NULL,
                                        , p_data_ini --P_I_DETALHES1         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , p_data_fim --P_I_DETALHES2         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , NULL --P_I_DETALHES3         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , NULL --P_I_DETALHES4         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , musuario --P_I_USER              IN VARCHAR2 DEFAULT NULL  --VARCHAR2(64)
                                                   );
        v_proc_status := 1; --EM PROCESSO

        loga ( '>>> Inicio do relatório...' || p_proc_instance
             , FALSE );
        loga ( '>> DT INICIAL: ' || v_data_inicial
             , FALSE );
        loga ( '>> DT FINAL: ' || v_data_final
             , FALSE );

        --

        --PREPARAR LOJAS
        IF ( p_cds.COUNT > 0 ) THEN
            i1 := p_cds.FIRST;

            WHILE i1 IS NOT NULL LOOP
                a_estabs.EXTEND ( );
                a_estabs ( a_estabs.LAST ) := p_cds ( i1 );
                i1 := p_cds.NEXT ( i1 );
            END LOOP;
        ELSE
            FOR c1 IN ( SELECT cod_estab
                          FROM msafi.dsp_estabelecimento
                         WHERE cod_empresa = mcod_empresa
                           AND tipo = 'C' ) LOOP
                a_estabs.EXTEND ( );
                a_estabs ( a_estabs.LAST ) := c1.cod_estab;
            END LOOP;
        END IF;

        ---

        IF ( p_sintetico = 'S' ) THEN --(1)
            FOR i IN 1 .. a_estabs.COUNT --(2)
                                        LOOP
                lib_proc.add_tipo ( mproc_id
                                  , i
                                  ,    mcod_empresa
                                    || '_'
                                    || a_estabs ( i )
                                    || '_'
                                    || TO_CHAR ( p_data_ini
                                               , 'MMYYYY' )
                                    || '_REL_RESSARC_INTERESTADUAL_SINTETICO.XLS'
                                  , 2 );

                IF ( p_cenario1 = 'N'
                AND p_cenario2 = 'N'
                AND p_cenario3 = 'N'
                AND p_cenario4 = 'N'
                AND p_cenario5 = 'N'
                AND p_cenario6 = 'N' ) THEN
                    lib_proc.add_log ( 'ATENÇÃO! Selecione ao menos um cenário para a impressão do relatório.'
                                     , 0 );
                    lib_proc.add ( 'ERRO' );
                    lib_proc.add ( 'SELECIONE AO MENOS UM CENÁRIO PARA A IMPRESSÃO DO RELATÓRIO.' );
                    lib_proc.close ( );
                    RETURN mproc_id;
                END IF;

                lib_proc.add ( dsp_planilha.header
                             , ptipo => i );
                lib_proc.add ( dsp_planilha.tabela_inicio
                             , ptipo => i );

                lib_proc.add ( dsp_planilha.linha (
                                                    p_conteudo =>    dsp_planilha.campo ( 'ESTAB' )
                                                                  || dsp_planilha.campo ( 'PERÍODO' )
                                                                  || dsp_planilha.campo ( 'VLR ICMS RESSARC' )
                                                                  || dsp_planilha.campo ( 'VLR ICMS ST RESSARC' )
                                                                  || dsp_planilha.campo ( 'VLR ICMS ANTECIP' )
                                                                  || dsp_planilha.campo ( 'VLR TOTAL' )
                                                  , p_class => 'h'
                               )
                             , ptipo => i );

                IF p_cenario1 = 'S' THEN
                    v_in := ', 1';
                END IF;

                IF p_cenario2 = 'S' THEN
                    v_in := v_in || ', 2';
                END IF;

                IF p_cenario3 = 'S' THEN
                    v_in := v_in || ', 3';
                END IF;

                IF p_cenario4 = 'S' THEN
                    v_in := v_in || ', 4';
                END IF;

                IF p_cenario5 = 'S' THEN
                    v_in := v_in || ', 5';
                END IF;

                IF p_cenario6 = 'S' THEN
                    v_in := v_in || ', 0';
                END IF;

                v_sql := 'SELECT ';
                v_sql := v_sql || ' COD_ESTAB, ';
                v_sql := v_sql || ' TO_CHAR(DATA_FISCAL,''YYYY/MM'') AS PERIODO, ';
                v_sql :=
                       v_sql
                    || ' SUM(CASE WHEN (UF_ORIGEM = ''RJ'' AND FINALIDADE = ''REV'') OR (VLR_ICMSST_RET > VLR_CONTAB_ITEM) THEN 0 ELSE VLR_ICMS_RESSARC END) AS VLR_ICMS_RESSARC, ';
                v_sql :=
                       v_sql
                    || ' SUM(CASE WHEN (UF_ORIGEM = ''RJ'' AND FINALIDADE = ''REV'') OR (VLR_ICMSST_RET > VLR_CONTAB_ITEM) THEN 0 ELSE VLR_ICMSST_RESSARC END) AS VLR_ICMSST_RESSARC, ';
                v_sql :=
                       v_sql
                    || ' SUM(CASE WHEN (UF_ORIGEM = ''RJ'' AND FINALIDADE = ''REV'') OR (VLR_ICMSST_RET > VLR_CONTAB_ITEM) THEN 0 ELSE VLR_ICMS_ANT_RES END) AS VLR_ICMS_ANT_RES, ';
                v_sql :=
                       v_sql
                    || ' SUM(CASE WHEN (UF_ORIGEM = ''RJ'' AND FINALIDADE = ''REV'') OR (VLR_ICMSST_RET > VLR_CONTAB_ITEM) THEN 0 ELSE VLR_ICMS_RESSARC END) + ';
                v_sql :=
                       v_sql
                    || ' SUM(CASE WHEN (UF_ORIGEM = ''RJ'' AND FINALIDADE = ''REV'') OR (VLR_ICMSST_RET > VLR_CONTAB_ITEM) THEN 0 ELSE VLR_ICMSST_RESSARC END) + ';
                v_sql :=
                       v_sql
                    || ' SUM(CASE WHEN (UF_ORIGEM = ''RJ'' AND FINALIDADE = ''REV'') OR (VLR_ICMSST_RET > VLR_CONTAB_ITEM) THEN 0 ELSE VLR_ICMS_ANT_RES END) AS TOTAL_RESSARCIR ';
                v_sql := v_sql || 'FROM MSAFI.DPSP_MSAF_RES_INTER ';
                v_sql := v_sql || 'WHERE COD_ESTAB = ''' || a_estabs ( i ) || ''' ';
                v_sql := v_sql || '  AND CLASSIFICACAO IN (9' || v_in || ') '; --CENARIO 9 NAO EXISTE
                v_sql :=
                       v_sql
                    || '  AND DATA_FISCAL BETWEEN TO_DATE('''
                    || TO_CHAR ( p_data_ini
                               , 'DDMMYYYY' )
                    || ''',''DDMMYYYY'') AND TO_DATE('''
                    || TO_CHAR ( p_data_fim
                               , 'DDMMYYYY' )
                    || ''',''DDMMYYYY'') ';
                v_sql := v_sql || 'GROUP BY COD_ESTAB, TO_CHAR(DATA_FISCAL,''YYYY/MM'') ';
                v_sql := v_sql || 'ORDER BY 1, 2 ';

                OPEN c_sintetico FOR v_sql; --(3)

                LOOP
                    FETCH c_sintetico
                        INTO v_cod_estab
                           , v_periodo
                           , v_vlr_icms_ressarc
                           , v_vlr_icmsst_ressarc
                           , v_vlr_icms_ant_res
                           , v_total_ressarcir;

                    v_text01 :=
                        dsp_planilha.linha (
                                             p_conteudo =>    dsp_planilha.campo ( v_cod_estab )
                                                           || dsp_planilha.campo ( v_periodo )
                                                           || dsp_planilha.campo ( moeda ( v_vlr_icms_ressarc ) )
                                                           || dsp_planilha.campo ( moeda ( v_vlr_icmsst_ressarc ) )
                                                           || dsp_planilha.campo ( moeda ( v_vlr_icms_ant_res ) )
                                                           || dsp_planilha.campo ( moeda ( v_total_ressarcir ) )
                                           , p_class => v_class
                        );

                    lib_proc.add ( v_text01
                                 , ptipo => i );

                    EXIT WHEN c_sintetico%NOTFOUND;
                END LOOP; --(3)

                CLOSE c_sintetico;

                lib_proc.add ( dsp_planilha.tabela_fim
                             , ptipo => i );
            END LOOP; --(2)
        END IF; --(1)

        IF ( p_analitico = 'S' ) THEN
            ---MONTAR RELATORIO ANALITICO-INI--------------------------------------------------------------------------------
            FOR i IN 1 .. a_estabs.COUNT LOOP
                lib_proc.add_tipo ( mproc_id
                                  , i
                                  ,    mcod_empresa
                                    || '_'
                                    || a_estabs ( i )
                                    || '_'
                                    || TO_CHAR ( p_data_ini
                                               , 'MMYYYY' )
                                    || '_REL_RESSARC_INTERESTADUAL.XLS'
                                  , 2 );

                IF ( p_cenario1 = 'N'
                AND p_cenario2 = 'N'
                AND p_cenario3 = 'N'
                AND p_cenario4 = 'N'
                AND p_cenario5 = 'N'
                AND p_cenario6 = 'N' ) THEN
                    lib_proc.add_log ( 'ATENÇÃO! Selecione ao menos um cenário para a impressão do relatório.'
                                     , 0 );
                    lib_proc.add ( 'ERRO' );
                    lib_proc.add ( 'SELECIONE AO MENOS UM CENÁRIO PARA A IMPRESSÃO DO RELATÓRIO.' );
                    lib_proc.close ( );
                    RETURN mproc_id;
                END IF;

                lib_proc.add ( dsp_planilha.header
                             , ptipo => i );
                lib_proc.add ( dsp_planilha.tabela_inicio
                             , ptipo => i );

                lib_proc.add ( dsp_planilha.linha ( p_conteudo =>    dsp_planilha.campo ( 'SAÍDA'
                                                                                        , p_custom => 'COLSPAN=23' )
                                                                  || dsp_planilha.campo (
                                                                                          'ENTRADA'
                                                                                        , p_custom => 'COLSPAN=18 BGCOLOR=#000086'
                                                                     )
                                                                  || dsp_planilha.campo (
                                                                                          'DADOS XML'
                                                                                        , p_custom => 'COLSPAN=13 BGCOLOR=#007100'
                                                                     )
                                                                  || dsp_planilha.campo (
                                                                                          'PEOPLESOFT ANTECIPAÇÃO'
                                                                                        , p_custom => 'COLSPAN=3 BGCOLOR=#cb9d00'
                                                                     )
                                                                  || dsp_planilha.campo ( 'CAMPOS CALCULADOS'
                                                                                        , p_custom => 'COLSPAN=4' )
                                                  , p_class => 'h' )
                             , ptipo => i );

                lib_proc.add ( dsp_planilha.linha ( p_conteudo =>    dsp_planilha.campo ( 'EMPRESA' )
                                                                  || --  COD_EMPRESA
                                                                    dsp_planilha.campo ( 'ESTAB' )
                                                                  || --  ,COD_ESTAB
                                                                    dsp_planilha.campo ( 'DOC FISCAL' )
                                                                  || --  ,NUM_DOCFIS
                                                                    dsp_planilha.campo ( 'ID PEOPLESOFT' )
                                                                  || --  ,NUM_CONTROLE_DOCTO
                                                                    dsp_planilha.campo ( 'LINHA' )
                                                                  || --  ,NUM_ITEM
                                                                    dsp_planilha.campo ( 'COD PRODUTO' )
                                                                  || --  ,COD_PRODUTO
                                                                    dsp_planilha.campo ( 'DESCRICAO' )
                                                                  || --  ,DESCR_ITEM
                                                                    dsp_planilha.campo ( 'DATA FISCAL' )
                                                                  || --  ,DATA_FISCAL
                                                                    dsp_planilha.campo ( 'UF ORIGEM' )
                                                                  || --  ,UF_ORIGEM
                                                                    dsp_planilha.campo ( 'UF DESTINO' )
                                                                  || --  ,UF_DESTINO
                                                                    dsp_planilha.campo ( 'COD DESTINO' )
                                                                  || --  ,COD_FIS_JUR
                                                                    dsp_planilha.campo ( 'CNPJ' )
                                                                  || --  ,CNPJ
                                                                    dsp_planilha.campo ( 'RAZAO SOCIAL' )
                                                                  || --  ,RAZAO_SOCIAL
                                                                    dsp_planilha.campo ( 'SERIE' )
                                                                  || --  ,SERIE_DOCFIS
                                                                    dsp_planilha.campo ( 'FINALIDADE' )
                                                                  || --  ,FINALIDADE
                                                                    dsp_planilha.campo ( 'NBM' )
                                                                  || --  ,NBM
                                                                    dsp_planilha.campo ( 'CHAVE NFE SAIDA' )
                                                                  || --  ,NUM_AUTENTIC_NFE
                                                                    dsp_planilha.campo ( 'PDF' )
                                                                  || dsp_planilha.campo ( 'VLR UNIT' )
                                                                  || --  ,VLR_UNIT
                                                                    dsp_planilha.campo ( 'VLR CONTABIL ITEM' )
                                                                  || --  ,VLR_ITEM
                                                                    dsp_planilha.campo ( 'VLR BASE ICMS' )
                                                                  || --  ,VLR_BASE_ICMS
                                                                    dsp_planilha.campo ( 'VLR ICMS' )
                                                                  || --  ,VLR_ICMS
                                                                    dsp_planilha.campo ( 'ALIQ ICMS' )
                                                                  || --  ,ALIQ_ICMS
                                                                     ---ENTRADA
                                                                     dsp_planilha.campo (
                                                                                          'ESTAB'
                                                                                        , p_custom => 'BGCOLOR=#000086'
                                                                     )
                                                                  || --  ,COD_ESTAB_E
                                                                    dsp_planilha.campo (
                                                                                         'DATA FISCAL'
                                                                                       , p_custom => 'BGCOLOR=#000086'
                                                                     )
                                                                  || --  ,DATA_FISCAL_E
                                                                    dsp_planilha.campo (
                                                                                         'DOC FISCAL'
                                                                                       , p_custom => 'BGCOLOR=#000086'
                                                                     )
                                                                  || --  ,NUM_DOCFIS_E
                                                                    dsp_planilha.campo (
                                                                                         'SERIE'
                                                                                       , p_custom => 'BGCOLOR=#000086'
                                                                     )
                                                                  || --  ,SERIE_DOCFIS_E
                                                                    dsp_planilha.campo (
                                                                                         'LINHA'
                                                                                       , p_custom => 'BGCOLOR=#000086'
                                                                     )
                                                                  || --  ,NUM_ITEM_E
                                                                    dsp_planilha.campo (
                                                                                         'ID FORNECEDOR'
                                                                                       , p_custom => 'BGCOLOR=#000086'
                                                                     )
                                                                  || --  ,COD_FIS_JUR_E
                                                                    dsp_planilha.campo (
                                                                                         'CNPJ'
                                                                                       , p_custom => 'BGCOLOR=#000086'
                                                                     )
                                                                  || --  ,CPF_CGC
                                                                    dsp_planilha.campo (
                                                                                         'NBM'
                                                                                       , p_custom => 'BGCOLOR=#000086'
                                                                     )
                                                                  || --  ,COD_NBM
                                                                    dsp_planilha.campo (
                                                                                         'FINALIDADE'
                                                                                       , p_custom => 'BGCOLOR=#000086'
                                                                     )
                                                                  || --  ,COD_NATUREZA_OP
                                                                    dsp_planilha.campo (
                                                                                         'VLR CONTABIL ITEM'
                                                                                       , p_custom => 'BGCOLOR=#000086'
                                                                     )
                                                                  || --  ,VLR_CONTAB_ITEM
                                                                    dsp_planilha.campo (
                                                                                         'VLR UNIT'
                                                                                       , p_custom => 'BGCOLOR=#000086'
                                                                     )
                                                                  || --  ,VLR_UNIT_E
                                                                    dsp_planilha.campo (
                                                                                         'CST'
                                                                                       , p_custom => 'BGCOLOR=#000086'
                                                                     )
                                                                  || --  ,COD_SITUACAO_B
                                                                    dsp_planilha.campo (
                                                                                         'DATA EMISSAO'
                                                                                       , p_custom => 'BGCOLOR=#000086'
                                                                     )
                                                                  || --  ,DATA_EMISSAO
                                                                    dsp_planilha.campo (
                                                                                         'UF'
                                                                                       , p_custom => 'BGCOLOR=#000086'
                                                                     )
                                                                  || --  ,COD_ESTADO
                                                                    dsp_planilha.campo (
                                                                                         'ID PEOPLESOFT'
                                                                                       , p_custom => 'BGCOLOR=#000086'
                                                                     )
                                                                  || --  ,NUM_CONTROLE_DOCTO_E
                                                                    dsp_planilha.campo (
                                                                                         'CHAVE NFE ENTRADA'
                                                                                       , p_custom => 'BGCOLOR=#000086'
                                                                     )
                                                                  || --  ,NUM_AUTENTIC_NFE_E
                                                                    dsp_planilha.campo (
                                                                                         'PDF'
                                                                                       , p_custom => 'BGCOLOR=#000086'
                                                                     )
                                                                  || dsp_planilha.campo (
                                                                                          'XML'
                                                                                        , p_custom => 'BGCOLOR=#000086'
                                                                     )
                                                                  || ---XML
                                                                     dsp_planilha.campo (
                                                                                          'CFOP SAIDA'
                                                                                        , p_custom => 'BGCOLOR=#007100'
                                                                     )
                                                                  || --  ,CFOP AS CFOP_SAIDA
                                                                    dsp_planilha.campo (
                                                                                         'CFOP ENTRADA'
                                                                                       , p_custom => 'BGCOLOR=#007100'
                                                                     )
                                                                  || --  ,COD_CFO AS CFOP_ENTRADA
                                                                    dsp_planilha.campo (
                                                                                         'CFOP FORNECEDOR'
                                                                                       , p_custom => 'BGCOLOR=#007100'
                                                                     )
                                                                  || --  ,CFOP_FORN AS CFOP_SAIDA_FORN
                                                                    dsp_planilha.campo (
                                                                                         'QTDE SAIDA'
                                                                                       , p_custom => 'BGCOLOR=#007100'
                                                                     )
                                                                  || --  ,QUANTIDADE
                                                                    dsp_planilha.campo (
                                                                                         'QTDE ENTRADA'
                                                                                       , p_custom => 'BGCOLOR=#007100'
                                                                     )
                                                                  || --  ,QUANTIDADE_E
                                                                    dsp_planilha.campo (
                                                                                         'VLR BASE ICMS'
                                                                                       , p_custom => 'BGCOLOR=#007100'
                                                                     )
                                                                  || --  ,VLR_BASE_ICMS_E
                                                                    dsp_planilha.campo (
                                                                                         'VLR ICMS'
                                                                                       , p_custom => 'BGCOLOR=#007100'
                                                                     )
                                                                  || --  ,VLR_ICMS_E
                                                                    dsp_planilha.campo (
                                                                                         'ALIQ REDUCAO'
                                                                                       , p_custom => 'BGCOLOR=#007100'
                                                                     )
                                                                  || --  ,ALIQ_REDUCAO
                                                                    dsp_planilha.campo (
                                                                                         'VLR BASE ST'
                                                                                       , p_custom => 'BGCOLOR=#007100'
                                                                     )
                                                                  || --  ,VLR_BASE_ICMS_ST
                                                                    dsp_planilha.campo (
                                                                                         'VLR ICMS ST'
                                                                                       , p_custom => 'BGCOLOR=#007100'
                                                                     )
                                                                  || --  ,VLR_ICMS_ST
                                                                    dsp_planilha.campo (
                                                                                         'VLR BASE ST RET'
                                                                                       , p_custom => 'BGCOLOR=#007100'
                                                                     )
                                                                  || --  ,VLR_BASE_ICMSST_RET
                                                                    dsp_planilha.campo (
                                                                                         'VLR ICMS ST RET'
                                                                                       , p_custom => 'BGCOLOR=#007100'
                                                                     )
                                                                  || --  ,VLR_ICMSST_RET
                                                                    dsp_planilha.campo (
                                                                                         'CENARIO'
                                                                                       , p_custom => 'BGCOLOR=#007100'
                                                                     )
                                                                  || --  ,CLASSIFICACAO
                                                                     ---PEOPLE ANTECIPACAO
                                                                     dsp_planilha.campo (
                                                                                          'ALIQ INTERNA'
                                                                                        , p_custom => 'BGCOLOR=#cb9d00'
                                                                     )
                                                                  || --  ,ALIQ_INTERNA
                                                                    dsp_planilha.campo (
                                                                                         'VLR ANTECIP IST'
                                                                                       , p_custom => 'BGCOLOR=#cb9d00'
                                                                     )
                                                                  || --  ,VLR_ANTECIP_IST
                                                                    dsp_planilha.campo (
                                                                                         'VLR ANTECIP REV'
                                                                                       , p_custom => 'BGCOLOR=#cb9d00'
                                                                     )
                                                                  || --  ,VLR_ANTECIP_REV
                                                                     ---CAMPOS CALCULADOS
                                                                     dsp_planilha.campo ( 'VLR ICMS PROPRIO CALC' )
                                                                  || --  ,VLR_ICMS_CALCULADO
                                                                    dsp_planilha.campo ( 'VLR ICMS RESSARC' )
                                                                  || --  ,VLR_ICMS_RESSARC
                                                                    dsp_planilha.campo ( 'VLR ST RESSARC' )
                                                                  || --  ,VLR_ICMSST_RESSARC
                                                                    dsp_planilha.campo ( 'VLR ANTECIP RESSARC' ) --  ,VLR_ICMS_ANT_RES
                                                  , p_class => 'h' )
                             , ptipo => i );

                FOR cr_r IN load_analitico ( a_estabs ( i )
                                           , v_data_inicial
                                           , v_data_final ) LOOP
                    IF ( cr_r.classificacao = 1
                    AND p_cenario1 = 'S' )
                    OR ( cr_r.classificacao = 2
                    AND p_cenario2 = 'S' )
                    OR ( cr_r.classificacao = 3
                    AND p_cenario3 = 'S' )
                    OR ( cr_r.classificacao = 4
                    AND p_cenario4 = 'S' )
                    OR ( cr_r.classificacao = 5
                    AND p_cenario5 = 'S' )
                    OR ( cr_r.classificacao = 0
                    AND p_cenario6 = 'S' ) THEN --(1)
                        IF v_class = 'a' THEN
                            v_class := 'b';
                        ELSE
                            v_class := 'a';
                        END IF;

                        --NOVA REGRA ROSELI 12/03/2018 - INI ----------------------------------------------------------------------
                        IF ( cr_r.uf_origem = 'RJ'
                        AND cr_r.finalidade = 'REV' )
                        OR ( cr_r.vlr_icmsst_ret > cr_r.vlr_contab_item ) THEN
                            v_vlr_icms_ressarc := 0;
                            v_vlr_icmsst_ressarc := 0;
                            v_vlr_icms_ant_res := 0;
                        ELSE
                            v_vlr_icms_ressarc := cr_r.vlr_icms_ressarc;
                            v_vlr_icmsst_ressarc := cr_r.vlr_icmsst_ressarc;
                            v_vlr_icms_ant_res := cr_r.vlr_icms_ant_res;
                        END IF;

                        --NOVA REGRA ROSELI 12/03/2018 - FIM ----------------------------------------------------------------------

                        v_text01 :=
                            dsp_planilha.linha (
                                                 p_conteudo =>    dsp_planilha.campo ( cr_r.cod_empresa )
                                                               || -- COD_EMPRESA
                                                                 dsp_planilha.campo ( cr_r.cod_estab )
                                                               || -- ,COD_ESTAB
                                                                 dsp_planilha.campo ( cr_r.num_docfis )
                                                               || -- ,NUM_DOCFIS
                                                                 dsp_planilha.campo ( cr_r.num_controle_docto )
                                                               || -- ,NUM_CONTROLE_DOCTO
                                                                 dsp_planilha.campo ( cr_r.num_item )
                                                               || -- ,NUM_ITEM
                                                                 dsp_planilha.campo ( cr_r.cod_produto )
                                                               || -- ,COD_PRODUTO
                                                                 dsp_planilha.campo ( cr_r.descr_item )
                                                               || -- ,DESCR_ITEM
                                                                 dsp_planilha.campo ( cr_r.data_fiscal )
                                                               || -- ,DATA_FISCAL
                                                                 dsp_planilha.campo ( cr_r.uf_origem )
                                                               || -- ,UF_ORIGEM
                                                                 dsp_planilha.campo ( cr_r.uf_destino )
                                                               || -- ,UF_DESTINO
                                                                 dsp_planilha.campo ( cr_r.cod_fis_jur )
                                                               || -- ,COD_FIS_JUR
                                                                 dsp_planilha.campo (
                                                                                      dsp_planilha.texto ( cr_r.cnpj )
                                                                  )
                                                               || -- ,CNPJ
                                                                 dsp_planilha.campo ( cr_r.razao_social )
                                                               || -- ,RAZAO_SOCIAL
                                                                 dsp_planilha.campo ( cr_r.serie_docfis )
                                                               || -- ,SERIE_DOCFIS
                                                                 dsp_planilha.campo ( cr_r.finalidade )
                                                               || -- ,FINALIDADE
                                                                 dsp_planilha.campo ( cr_r.nbm )
                                                               || -- ,NBM
                                                                 dsp_planilha.campo (
                                                                                      dsp_planilha.texto (
                                                                                                           cr_r.num_autentic_nfe
                                                                                      )
                                                                  )
                                                               || -- ,NUM_AUTENTIC_NFE
                                                                 dsp_planilha.campo (
                                                                                      'PDF'
                                                                                    , p_link =>    v_url_vero_s_pdf
                                                                                                || cr_r.num_autentic_nfe
                                                                  )
                                                               || dsp_planilha.campo ( moeda ( cr_r.vlr_unit ) )
                                                               || -- ,VLR_UNIT
                                                                 dsp_planilha.campo ( moeda ( cr_r.vlr_item ) )
                                                               || -- ,VLR_ITEM
                                                                 dsp_planilha.campo ( moeda ( cr_r.vlr_base_icms ) )
                                                               || -- ,VLR_BASE_ICMS
                                                                 dsp_planilha.campo ( moeda ( cr_r.vlr_icms ) )
                                                               || -- ,VLR_ICMS
                                                                 dsp_planilha.campo ( moeda ( cr_r.aliq_icms ) )
                                                               || -- ,ALIQ_ICMS
                                                                  --
                                                                  dsp_planilha.campo ( cr_r.cod_estab_e )
                                                               || -- ,COD_ESTAB_E
                                                                 dsp_planilha.campo ( cr_r.data_fiscal_e )
                                                               || -- ,DATA_FISCAL_E
                                                                 dsp_planilha.campo ( cr_r.num_docfis_e )
                                                               || -- ,NUM_DOCFIS_E
                                                                 dsp_planilha.campo ( cr_r.serie_docfis_e )
                                                               || -- ,SERIE_DOCFIS_E
                                                                 dsp_planilha.campo ( cr_r.num_item_e )
                                                               || -- ,NUM_ITEM_E
                                                                 dsp_planilha.campo ( cr_r.cod_fis_jur_e )
                                                               || -- ,COD_FIS_JUR_E
                                                                 dsp_planilha.campo (
                                                                                      dsp_planilha.texto (
                                                                                                           cr_r.cpf_cgc
                                                                                      )
                                                                  )
                                                               || -- ,CPF_CGC
                                                                 dsp_planilha.campo ( cr_r.cod_nbm )
                                                               || -- ,COD_NBM
                                                                 dsp_planilha.campo ( cr_r.cod_natureza_op )
                                                               || -- ,COD_NATUREZA_OP
                                                                 dsp_planilha.campo ( moeda ( cr_r.vlr_contab_item ) )
                                                               || -- ,VLR_CONTAB_ITEM
                                                                 dsp_planilha.campo ( moeda ( cr_r.vlr_unit_e ) )
                                                               || -- ,VLR_UNIT_E
                                                                 dsp_planilha.campo ( cr_r.cod_situacao_b )
                                                               || -- ,COD_SITUACAO_B
                                                                 dsp_planilha.campo ( cr_r.data_emissao )
                                                               || -- ,DATA_EMISSAO
                                                                 dsp_planilha.campo ( cr_r.cod_estado )
                                                               || -- ,COD_ESTADO
                                                                 dsp_planilha.campo ( cr_r.num_controle_docto_e )
                                                               || -- ,NUM_CONTROLE_DOCTO_E
                                                                 dsp_planilha.campo (
                                                                                      dsp_planilha.texto (
                                                                                                           cr_r.num_autentic_nfe_e
                                                                                      )
                                                                  )
                                                               || -- ,NUM_AUTENTIC_NFE_E
                                                                 dsp_planilha.campo (
                                                                                      'PDF'
                                                                                    , p_link =>    v_url_vero_e_pdf
                                                                                                || cr_r.num_autentic_nfe_e
                                                                  )
                                                               || dsp_planilha.campo (
                                                                                       'XML'
                                                                                     , p_link =>    v_url_vero_e_xml
                                                                                                 || cr_r.num_autentic_nfe_e
                                                                  )
                                                               || --
                                                                  dsp_planilha.campo ( cr_r.cfop_saida )
                                                               || -- ,CFOP AS CFOP_SAIDA
                                                                 dsp_planilha.campo ( cr_r.cfop_entrada )
                                                               || -- ,COD_CFO AS CFOP_ENTRADA
                                                                 dsp_planilha.campo ( cr_r.cfop_saida_forn )
                                                               || -- ,CFOP_FORN AS CFOP_SAIDA_FORN
                                                                 dsp_planilha.campo ( moeda ( cr_r.quantidade ) )
                                                               || -- ,QUANTIDADE
                                                                 dsp_planilha.campo ( moeda ( cr_r.quantidade_e ) )
                                                               || -- ,QUANTIDADE_E
                                                                 dsp_planilha.campo ( moeda ( cr_r.vlr_base_icms_e ) )
                                                               || -- ,VLR_BASE_ICMS_E
                                                                 dsp_planilha.campo ( moeda ( cr_r.vlr_icms_e ) )
                                                               || -- ,VLR_ICMS_E
                                                                 dsp_planilha.campo ( moeda ( cr_r.aliq_reducao ) )
                                                               || -- ,ALIQ_REDUCAO
                                                                 dsp_planilha.campo (
                                                                                      moeda ( cr_r.vlr_base_icms_st )
                                                                  )
                                                               || -- ,VLR_BASE_ICMS_ST
                                                                 dsp_planilha.campo ( moeda ( cr_r.vlr_icms_st ) )
                                                               || -- ,VLR_ICMS_ST
                                                                 dsp_planilha.campo (
                                                                                      moeda (
                                                                                              cr_r.vlr_base_icmsst_ret
                                                                                      )
                                                                  )
                                                               || -- ,VLR_BASE_ICMSST_RET
                                                                 dsp_planilha.campo ( moeda ( cr_r.vlr_icmsst_ret ) )
                                                               || -- ,VLR_ICMSST_RET
                                                                 dsp_planilha.campo ( cr_r.classificacao )
                                                               || -- ,CLASSIFICACAO
                                                                  --
                                                                  dsp_planilha.campo ( moeda ( cr_r.aliq_interna ) )
                                                               || -- ,ALIQ_INTERNA
                                                                 dsp_planilha.campo ( moeda ( cr_r.vlr_antecip_ist ) )
                                                               || -- ,VLR_ANTECIP_IST
                                                                 dsp_planilha.campo ( moeda ( cr_r.vlr_antecip_rev ) )
                                                               || -- ,VLR_ANTECIP_REV
                                                                  --
                                                                  dsp_planilha.campo (
                                                                                       moeda (
                                                                                               cr_r.vlr_icms_calculado
                                                                                       )
                                                                  )
                                                               || -- ,VLR_ICMS_CALCULADO
                                                                 dsp_planilha.campo ( moeda ( v_vlr_icms_ressarc ) )
                                                               || -- ,VLR_ICMS_RESSARC
                                                                 dsp_planilha.campo ( moeda ( v_vlr_icmsst_ressarc ) )
                                                               || -- ,VLR_ICMSST_RESSARC
                                                                 dsp_planilha.campo ( moeda ( v_vlr_icms_ant_res ) ) -- ,VLR_ICMS_ANT_RES
                                               , p_class => v_class
                            );

                        lib_proc.add ( v_text01
                                     , ptipo => i );
                    END IF; --(1)
                END LOOP; --FOR CR_R IN LOAD_ANALITICO(A_ESTABS(i), V_DATA_INICIAL, V_DATA_FINAL)

                lib_proc.add ( dsp_planilha.tabela_fim
                             , ptipo => i );
            END LOOP;
        END IF; --IF (P_ANALITICO = 'S') THEN

        ---MONTAR RELATORIO ANALITICO-FIM--------------------------------------------------------------------------------

        loga ( '>>> Fim do relatório!'
             , FALSE );
        v_proc_status := 2;

        v_s_proc_status :=
            CASE v_proc_status
                WHEN 0 THEN 'ERROI#0' --NUNCA DEVE SER 0, POIS JÁ VIRA 1 NO INÍCIO!
                WHEN 1 THEN 'ERROI#1' --AINDA ESTÁ EM PROCESSO!??!? ERRO NO PROCESSO!
                WHEN 2 THEN 'SUCESSO'
                WHEN 3 THEN 'AVISOS'
                WHEN 4 THEN 'ERRO'
                ELSE 'ERROI#' || v_proc_status
            END;

        loga ( 'FIM DO PROCESSAMENTO, STATUS FINAL: [' || v_s_proc_status || ']'
             , FALSE );
        msafi.dsp_control.updateprocess ( v_s_proc_status );

        lib_proc.close ( );

        COMMIT;
        RETURN mproc_id;
    END; /* FUNCTION EXECUTAR */
END dpsp_rel_res_inter_cproc;
/
SHOW ERRORS;
