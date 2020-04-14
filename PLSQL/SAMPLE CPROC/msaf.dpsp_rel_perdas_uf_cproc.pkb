Prompt Package Body DPSP_REL_PERDAS_UF_CPROC;
--
-- DPSP_REL_PERDAS_UF_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_rel_perdas_uf_cproc
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
                           , 'Data Inicial '
                           , --P_PERIODO
                            'DATE'
                           , 'TEXTBOX'
                           , 'S'
                           , NULL
                           , 'DD/MM/YYYY' );


        lib_proc.add_param ( pstr
                           , 'Data Final'
                           , --P_PERIODO
                            'DATE'
                           , 'TEXTBOX'
                           , 'S'
                           , NULL
                           , 'DD/MM/YYYY' );



        lib_proc.add_param ( pstr
                           , 'Imprimir Relatório Sintético'
                           , --P_SINTETICO
                            'VARCHAR2'
                           , 'CHECKBOX'
                           , 'N'
                           , 'S'
                           , NULL );

        lib_proc.add_param ( pstr
                           , 'Imprimir Relatório Analítico'
                           , --P_ANALITICO
                            'VARCHAR2'
                           , 'CHECKBOX'
                           , 'N'
                           , 'N'
                           , NULL );

        lib_proc.add_param ( pstr
                           , 'Imprimir Mapa de Conferência'
                           , --P_MAPA
                            'VARCHAR2'
                           , 'CHECKBOX'
                           , 'N'
                           , 'N'
                           , NULL );

        lib_proc.add_param (
                             pstr
                           , 'UF'
                           , --P_UF
                            'VARCHAR2'
                           , 'COMBOBOX'
                           , 'S'
                           , '%'
                           , '#########'
                           , 'SELECT A.COD_ESTADO, A.COD_ESTADO FROM ESTADO A UNION ALL SELECT ''%'', ''--TODAS--'' FROM DUAL ORDER BY 1'
        );

        lib_proc.add_param (
                             pstr
                           , 'Filiais'
                           , --P_LOJAS
                            'VARCHAR2'
                           , 'MULTISELECT'
                           , 'S'
                           , NULL
                           , NULL
                           ,    'SELECT A.COD_ESTAB, A.COD_ESTAB 
                           || '' - '' || B.COD_ESTADO || '' - '' 
                           || A.CGC || '' - '' 
                           || INITCAP(A.BAIRRO) || '' / '' 
                           || INITCAP(A.CIDADE) FROM ESTABELECIMENTO A, ESTADO B, MSAFI.DSP_ESTABELECIMENTO C WHERE A.COD_EMPRESA  = '''
                             || mcod_empresa
                             || ''' AND B.IDENT_ESTADO = A.IDENT_ESTADO AND A.COD_EMPRESA = C.COD_EMPRESA AND A.COD_ESTAB = C.COD_ESTAB AND B.COD_ESTADO LIKE :6 ORDER BY B.COD_ESTADO, A.COD_ESTAB'
        );

        RETURN pstr;
    END; --FUNCTION PARAMETROS RETURN VARCHAR2 IS

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Relatório de PERDAS Outras UFs';
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
        RETURN 'Relatório de Ressarcimento sobre Perdas Outras UFs (Sintético, Analítico e Mapa)';
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
        msafi.dsp_control.writelog ( 'PERDASR'
                                   , p_i_texto );
    ---> Para acompanhar processamento usar SELECT abaixo
    --SELECT * FROM DSP_LOG
    --WHERE LOG_TYPE = 'PMCxMVA'
    --ORDER BY 3 DESC, 2 DESC
    ---
    END;

    FUNCTION moeda ( v_conteudo NUMBER )
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN TRIM ( TO_CHAR ( v_conteudo
                              , '9g999g999g990d00' ) );
    END;

    FUNCTION fazcampo ( p_i_campo IN VARCHAR2
                      , p_i_fill IN VARCHAR2
                      , p_i_size IN NUMBER )
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN LPAD ( NVL ( p_i_campo, ' ' )
                    , p_i_size
                    , p_i_fill );
    END;

    FUNCTION fazcampo ( p_i_campo IN NUMBER
                      , p_i_format IN VARCHAR2
                      , p_i_fill IN VARCHAR2
                      , p_i_size IN NUMBER )
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN LPAD ( NVL ( TO_CHAR ( p_i_campo
                                    , p_i_format )
                          , ' ' )
                    , p_i_size
                    , p_i_fill );
    END;

    FUNCTION fazcampo ( p_i_campo IN DATE
                      , p_i_format IN VARCHAR2
                      , p_i_fill IN VARCHAR2
                      , p_i_size IN NUMBER )
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN LPAD ( NVL ( TO_CHAR ( p_i_campo
                                    , p_i_format )
                          , ' ' )
                    , p_i_size
                    , p_i_fill );
    END;

    FUNCTION executar ( p_data_inicial DATE
                      , p_data_final DATE
                      , p_sintetico VARCHAR2
                      , p_analitico VARCHAR2
                      , p_mapa VARCHAR2
                      , p_uf VARCHAR2
                      , p_lojas lib_proc.vartab )
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
        v_color VARCHAR2 ( 100 );

        --
        TYPE cur_typ IS REF CURSOR;

        cr_cup cur_typ;
        --
        v_class VARCHAR2 ( 1 ) := 'a';
        v_uf VARCHAR2 ( 2 );

        --Variaveis para relatorio de conferencia
        TYPE curtype IS REF CURSOR;

        src_cur curtype;
        c_curid NUMBER;
        v_desctab dbms_sql.desc_tab;
        v_colcnt NUMBER;
        v_namevar VARCHAR2 ( 50 );
        v_numvar NUMBER;
        v_datevar DATE;


        ------------------------------------------------------------------------------------------------------------------------------------------------------
        --RANGE DE DATAS PARA BUSCAR VENDAS
        --     V_DATA_INICIAL    DATE := TO_DATE('01' || TO_CHAR(P_PERIODO,'MMYYYY'),'DDMMYYYY');  -- DATA INICIAL
        --     V_DATA_FINAL      DATE := LAST_DAY(P_PERIODO);                                      -- DATA FINAL
        --
        v_data_inicial DATE := p_data_inicial;
        v_data_final DATE := p_data_final;
        --
        p_periodo DATE
            := TO_DATE (    '01'
                         || TO_CHAR ( v_data_inicial
                                    , 'MMYYYY' )
                       , 'DDMMYYYY' );

        ------------------------------------------------------------------------------------------------------------------------------------------------------

        --CURSOR AUXILIAR

        CURSOR c_datas ( p_i_data_inicial IN DATE
                       , p_i_data_final IN DATE )
        IS
            SELECT   b.data_fiscal AS data_normal
                FROM (SELECT p_i_data_inicial + ( ROWNUM - 1 ) AS data_fiscal
                        FROM all_objects
                       WHERE ROWNUM <= (p_i_data_final - p_i_data_inicial + 1)) b
            ORDER BY b.data_fiscal;

        --

        --CURSOR DE DIAS PARA REL CONF
        CURSOR c_dias ( p_i_data_inicial IN DATE
                      , p_i_data_final IN DATE )
        IS
            SELECT   TO_CHAR ( data_fiscal
                             , 'DDMMYYYY' )
                         AS dia
                   , data_fiscal
                   , MIN ( data_fiscal ) AS data_ini
                   , MAX ( data_fiscal ) AS data_fim
                FROM (SELECT p_i_data_inicial + ( ROWNUM - 1 ) AS data_fiscal
                        FROM all_objects
                       WHERE ROWNUM <= (p_i_data_final - p_i_data_inicial + 1)) b
            GROUP BY TO_CHAR ( data_fiscal
                             , 'DDMMYYYY' )
                   , data_fiscal
            ORDER BY data_fiscal;
    --

    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS='',.'' ';

        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        mproc_id :=
            lib_proc.new ( 'DPSP_REL_PERDAS_UF_CPROC'
                         , 48
                         , 150 );

        IF mcod_empresa IS NULL THEN
            lib_proc.add_log ( 'Código da empresa deve ser informado como parâmetro global.'
                             , 0 );
            lib_proc.add ( 'ERRO' );
            lib_proc.add ( 'CÓDIGO DA EMPRESA DEVE SER INFORMADO COMO PARÂMETRO GLOBAL.' );
            lib_proc.close ( );
            RETURN mproc_id;
        ELSIF ( p_sintetico <> 'S'
           AND p_analitico <> 'S' ) THEN
            lib_proc.add_log ( 'Escolha ao menos uma opção de impressão de relatório, sintético ou analítico.'
                             , 0 );
            lib_proc.add ( 'ERRO' );
            lib_proc.add ( 'ESCOLHA AO MENOS UMA OPÇÃO DE IMPRESSÃO DE RELATÓRIO, SINTÉTICO OU ANALÍTICO.' );
            lib_proc.close ( );
            RETURN mproc_id;
        END IF;

        loga ( '>>> Inicio do relatório...' || p_proc_instance
             , FALSE );
        loga ( '>> DT INICIAL: ' || v_data_inicial
             , FALSE );
        loga ( '>> DT FINAL: ' || v_data_final
             , FALSE );

        --

        --PREPARAR LOJAS
        IF ( p_lojas.COUNT > 0 ) THEN
            i1 := p_lojas.FIRST;

            WHILE i1 IS NOT NULL LOOP
                a_estabs.EXTEND ( );
                a_estabs ( a_estabs.LAST ) := p_lojas ( i1 );
                i1 := p_lojas.NEXT ( i1 );
            END LOOP;
        ELSE
            FOR c1 IN ( SELECT cod_estab
                          FROM msafi.dsp_estabelecimento
                         WHERE cod_empresa = mcod_empresa
                           AND tipo = 'L' ) LOOP
                a_estabs.EXTEND ( );
                a_estabs ( a_estabs.LAST ) := c1.cod_estab;
            END LOOP;
        END IF;

        ---

        IF ( p_sintetico = 'S' ) THEN
            ---MONTAR RELATORIO SINTETICO-INI--------------------------------------------------------------------------------
            lib_proc.add_tipo ( mproc_id
                              , 9999
                              ,    mcod_empresa
                                || '_SINTETICO_'
                                || TO_CHAR ( p_periodo
                                           , 'MMYYYY' )
                                || '_REL_PERDAS_UF.XLS'
                              , 2 );

            lib_proc.add ( dsp_planilha.header
                         , ptipo => 9999 );
            lib_proc.add ( dsp_planilha.tabela_inicio
                         , ptipo => 9999 );

            lib_proc.add ( dsp_planilha.linha (
                                                p_conteudo =>    dsp_planilha.campo ( 'UF' )
                                                              || --
                                                                dsp_planilha.campo ( 'ESTAB' )
                                                              || --
                                                                dsp_planilha.campo ( 'PERIODO' )
                                                              || --
                                                                dsp_planilha.campo ( 'TOTAL ESTORNO ICMS' )
                                                              || --
                                                                dsp_planilha.campo ( 'TOTAL RESSARCIMENTO ICMS ST' )
                                                              || --
                                                                dsp_planilha.campo ( 'TOTAL ESTORNO PIS' )
                                                              || --
                                                                dsp_planilha.campo ( 'TOTAL ESTORNO COFINS' ) --
                                              , p_class => 'h'
                           )
                         , ptipo => 9999 );

            FOR i IN 1 .. a_estabs.COUNT LOOP
                FOR cr_s IN load_sintetico ( a_estabs ( i )
                                           , v_data_inicial
                                           , v_data_final ) LOOP
                    IF v_class = 'a' THEN
                        v_class := 'b';
                    ELSE
                        v_class := 'a';
                    END IF;

                    v_text01 :=
                        dsp_planilha.linha (
                                             p_conteudo =>    dsp_planilha.campo ( cr_s.cod_estado )
                                                           || --
                                                             dsp_planilha.campo ( cr_s.cod_estab )
                                                           || --
                                                             dsp_planilha.campo ( cr_s.periodo )
                                                           || --
                                                             dsp_planilha.campo ( moeda ( cr_s.total_icms ) )
                                                           || --
                                                             dsp_planilha.campo ( moeda ( cr_s.total_icms_st ) )
                                                           || --
                                                             dsp_planilha.campo ( moeda ( cr_s.estorno_pis_s ) )
                                                           || --
                                                             dsp_planilha.campo ( moeda ( cr_s.estorno_cofins_s ) ) --
                                           , p_class => v_class
                        );
                    lib_proc.add ( v_text01
                                 , ptipo => 9999 );
                END LOOP; --FOR CR_R IN LOAD_ANALITICO(A_ESTABS(i), V_DATA_INICIAL, V_DATA_FINAL)
            END LOOP; --FOR i IN 1..A_ESTABS.COUNT

            lib_proc.add ( dsp_planilha.tabela_fim
                         , ptipo => 9999 );
        ---MONTAR RELATORIO SINTETICO-FIM--------------------------------------------------------------------------------
        END IF; --IF (P_SINTETICO = 'S') THEN

        IF ( p_analitico = 'S' ) THEN
            ---MONTAR RELATORIO ANALITICO-INI--------------------------------------------------------------------------------
            FOR i IN 1 .. a_estabs.COUNT LOOP
                --BUSCAR UF DO COD_ESTAB
                SELECT cod_estado
                  INTO v_uf
                  FROM msafi.dsp_estabelecimento
                 WHERE cod_empresa = mcod_empresa
                   AND cod_estab = a_estabs ( i );

                ---

                lib_proc.add_tipo ( mproc_id
                                  , i
                                  ,    mcod_empresa
                                    || '_'
                                    || v_uf
                                    || '_'
                                    || a_estabs ( i )
                                    || '_'
                                    || TO_CHAR ( p_periodo
                                               , 'MMYYYY' )
                                    || '_REL_PERDAS_UF.XLS'
                                  , 2 );

                lib_proc.add ( dsp_planilha.header
                             , ptipo => i );
                lib_proc.add ( dsp_planilha.tabela_inicio
                             , ptipo => i );

                lib_proc.add ( dsp_planilha.linha ( p_conteudo =>    dsp_planilha.campo (
                                                                                          'INVENTÁRIO'
                                                                                        , p_custom => 'COLSPAN=7 BGCOLOR=#000086'
                                                                     )
                                                                  || dsp_planilha.campo ( 'ENTRADA'
                                                                                        , p_custom => 'COLSPAN=36' )
                                                  , p_class => 'h' )
                             , ptipo => i );

                lib_proc.add ( dsp_planilha.linha (
                                                    p_conteudo =>    dsp_planilha.campo (
                                                                                          'ESTAB'
                                                                                        , p_custom => 'BGCOLOR=#000086'
                                                                     )
                                                                  || --
                                                                    dsp_planilha.campo (
                                                                                         'DATA INVENTÁRIO'
                                                                                       , p_custom => 'BGCOLOR=#000086'
                                                                     )
                                                                  || --
                                                                    dsp_planilha.campo (
                                                                                         'PRODUTO'
                                                                                       , p_custom => 'BGCOLOR=#000086'
                                                                     )
                                                                  || --
                                                                    dsp_planilha.campo (
                                                                                         'DESCRICAO'
                                                                                       , p_custom => 'BGCOLOR=#000086'
                                                                     )
                                                                  || --
                                                                    dsp_planilha.campo (
                                                                                         'QTDE AJUSTE'
                                                                                       , p_custom => 'BGCOLOR=#000086'
                                                                     )
                                                                  || ---
                                                                    dsp_planilha.campo (
                                                                                         'CNPJ EMITENTE'
                                                                                       , p_custom => 'BGCOLOR=#000086'
                                                                     )
                                                                  || --
                                                                    dsp_planilha.campo (
                                                                                         'RAZAO SOCIAL'
                                                                                       , p_custom => 'BGCOLOR=#000086'
                                                                     )
                                                                  || --
                                                                     ---
                                                                     dsp_planilha.campo ( 'COD ESTAB' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'DATA FISCAL' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'DATA EMISSAO' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'NUM DOC FIS' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'SERIE' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'LINHA' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'ID FORNECEDOR' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'CNPJ' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'RAZAO SOCIAL' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'NBM' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'CFOP' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'FINALIDADE' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'VLR CONTABIL' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'QUANTIDADE' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'VLR UNIT' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'CST A' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'CST B' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'UF' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'ID PEOPLESOFT' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'CHAVE ACESSO' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'VLR BASE ICMS UNIT' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'VLR ICMS UNIT' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'VLR BASE ICMS ST UNIT' )
                                                                  || dsp_planilha.campo ( 'VLR ICMS ST UNIT' )
                                                                  || dsp_planilha.campo ( 'LIBER / CONTR' )
                                                                  || dsp_planilha.campo ( 'ALIQ ST' )
                                                                  || dsp_planilha.campo ( 'VLR PMC' )
                                                                  || dsp_planilha.campo ( 'VLR TOTAL ESTORNO ICMS' )
                                                                  || dsp_planilha.campo (
                                                                                          'VLR TOTAL RESSARCIMENTO ICMS ST'
                                                                     )
                                                                  || dsp_planilha.campo ( 'LISTA PRODUTO' )
                                                                  || dsp_planilha.campo ( 'CST PIS' )
                                                                  || dsp_planilha.campo ( 'CST COFINS' )
                                                                  || dsp_planilha.campo ( 'VLR PIS UNIT' )
                                                                  || dsp_planilha.campo ( 'VLR COFINS UNIT' )
                                                                  || dsp_planilha.campo ( 'VLR TOTAL ESTORNO PIS' )
                                                                  || dsp_planilha.campo ( 'VLR TOTAL ESTORNO COFINS' )
                                                  , p_class => 'h'
                               )
                             , ptipo => i );

                FOR cr_r IN load_analitico ( a_estabs ( i )
                                           , v_data_inicial
                                           , v_data_final ) LOOP
                    IF v_class = 'a' THEN
                        v_class := 'b';
                    ELSE
                        v_class := 'a';
                    END IF;

                    v_text01 :=
                        dsp_planilha.linha (
                                             p_conteudo =>    dsp_planilha.campo ( cr_r.cod_estab )
                                                           || dsp_planilha.campo ( cr_r.data_inv )
                                                           || dsp_planilha.campo ( cr_r.cod_produto )
                                                           || dsp_planilha.campo ( cr_r.descricao )
                                                           || dsp_planilha.campo ( cr_r.qtd_ajuste )
                                                           || dsp_planilha.campo (
                                                                                   dsp_planilha.texto (
                                                                                                        cr_r.cnpj_emitente
                                                                                   )
                                                              )
                                                           || dsp_planilha.campo ( cr_r.razao_social_emi )
                                                           || ---
                                                              dsp_planilha.campo ( cr_r.cod_estab_e )
                                                           || dsp_planilha.campo ( cr_r.data_fiscal_e )
                                                           || dsp_planilha.campo ( cr_r.data_emissao_e )
                                                           || dsp_planilha.campo ( cr_r.num_docfis_e )
                                                           || dsp_planilha.campo ( cr_r.serie_docfis_e )
                                                           || dsp_planilha.campo ( cr_r.num_item_e )
                                                           || dsp_planilha.campo ( cr_r.cod_fis_jur_e )
                                                           || dsp_planilha.campo (
                                                                                   dsp_planilha.texto (
                                                                                                        cr_r.cpf_cgc_e
                                                                                   )
                                                              )
                                                           || dsp_planilha.campo ( cr_r.razao_social_e )
                                                           || dsp_planilha.campo ( cr_r.cod_nbm_e )
                                                           || dsp_planilha.campo ( cr_r.cod_cfo_e )
                                                           || dsp_planilha.campo ( cr_r.cod_natureza_op_e )
                                                           || dsp_planilha.campo ( cr_r.vlr_contab_item_e )
                                                           || dsp_planilha.campo ( cr_r.quantidade_e )
                                                           || dsp_planilha.campo ( cr_r.vlr_unit_e )
                                                           || dsp_planilha.campo ( cr_r.cod_situacao_a_e )
                                                           || dsp_planilha.campo ( cr_r.cod_situacao_b_e )
                                                           || dsp_planilha.campo ( cr_r.cod_estado_e )
                                                           || dsp_planilha.campo (
                                                                                   dsp_planilha.texto (
                                                                                                        cr_r.num_controle_docto_e
                                                                                   )
                                                              )
                                                           || dsp_planilha.campo (
                                                                                   dsp_planilha.texto (
                                                                                                        cr_r.num_autentic_nfe_e
                                                                                   )
                                                              )
                                                           || dsp_planilha.campo ( cr_r.base_icms_unit_e )
                                                           || dsp_planilha.campo ( cr_r.vlr_icms_unit_e )
                                                           || dsp_planilha.campo ( cr_r.base_st_unit_e )
                                                           || dsp_planilha.campo ( cr_r.vlr_icms_st_unit_e )
                                                           || dsp_planilha.campo ( cr_r.stat_liber_cntr )
                                                           || dsp_planilha.campo ( cr_r.id_aliq_st )
                                                           || dsp_planilha.campo ( cr_r.vlr_pmc )
                                                           || dsp_planilha.campo ( cr_r.total_icms )
                                                           || dsp_planilha.campo ( cr_r.total_icms_st )
                                                           || dsp_planilha.campo ( cr_r.lista_produto )
                                                           || dsp_planilha.campo ( cr_r.cst_pis )
                                                           || dsp_planilha.campo ( cr_r.cst_cofins )
                                                           || dsp_planilha.campo ( cr_r.estorno_pis_e )
                                                           || dsp_planilha.campo ( cr_r.estorno_cofins_e )
                                                           || dsp_planilha.campo ( cr_r.estorno_pis_s )
                                                           || dsp_planilha.campo ( cr_r.estorno_cofins_s )
                                           , p_class => v_class
                        );
                    lib_proc.add ( v_text01
                                 , ptipo => i );
                END LOOP; --FOR CR_R IN LOAD_ANALITICO(A_ESTABS(i), V_DATA_INICIAL, V_DATA_FINAL)

                lib_proc.add ( dsp_planilha.tabela_fim
                             , ptipo => i );
            END LOOP; --FOR i IN 1..A_ESTABS.COUNT
        ---MONTAR RELATORIO ANALITICO-FIM--------------------------------------------------------------------------------
        END IF; --IF (P_ANALITICO = 'S') THEN

        IF ( p_mapa = 'S' ) THEN
            ---
            lib_proc.add_tipo ( mproc_id
                              , 9998
                              ,    mcod_empresa
                                || '_CONFERENCIA_'
                                || TO_CHAR ( p_periodo
                                           , 'MMYYYY' )
                                || '_REL_PERDAS_UF.XLS'
                              , 2 );

            lib_proc.add ( dsp_planilha.header
                         , ptipo => 9998 );
            lib_proc.add ( dsp_planilha.tabela_inicio
                         , ptipo => 9998 );

            lib_proc.add ( dsp_planilha.linha (
                                                p_conteudo =>    dsp_planilha.campo ( 'ESTAB' )
                                                              || --
                                                                dsp_planilha.campo ( 'UF' )
                                                              || --
                                                                dsp_planilha.campo ( 'QTDE AJUSTES' )
                                              , p_class => 'h'
                           )
                         , ptipo => 9998 );

            FOR i IN 1 .. a_estabs.COUNT LOOP
                FOR cr_m IN load_mapa ( a_estabs ( i )
                                      , v_data_inicial
                                      , v_data_final ) LOOP
                    IF v_class = 'a' THEN
                        v_class := 'b';
                    ELSE
                        v_class := 'a';
                    END IF;

                    v_text01 :=
                        dsp_planilha.linha (
                                             p_conteudo =>    dsp_planilha.campo ( cr_m.cod_estab )
                                                           || --
                                                             dsp_planilha.campo ( cr_m.cod_estado )
                                                           || --
                                                             dsp_planilha.campo ( cr_m.qtde_ajustes )
                                           , p_class => v_class
                        );
                    lib_proc.add ( v_text01
                                 , ptipo => 9998 );
                END LOOP; --FOR CR_R IN LOAD_ANALITICO(A_ESTABS(i), V_DATA_INICIAL, V_DATA_FINAL)
            END LOOP; --FOR i IN 1..A_ESTABS.COUNT

            lib_proc.add ( dsp_planilha.tabela_fim
                         , ptipo => 9998 );
        ---
        END IF;

        loga ( '>>> FIM DO RELATÓRIO!'
             , FALSE );

        lib_proc.close ( );

        COMMIT;
        RETURN mproc_id;
    EXCEPTION
        WHEN OTHERS THEN
            msafi.dsp_control.log_checkpoint ( SQLERRM
                                             , 'Erro não tratado, executador de interfaces' );
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
END dpsp_rel_perdas_uf_cproc;
/
SHOW ERRORS;
