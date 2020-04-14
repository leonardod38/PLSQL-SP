Prompt Package Body DPSP_REL_CARTOES_PF_CPROC;
--
-- DPSP_REL_CARTOES_PF_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_rel_cartoes_pf_cproc
IS
    mnm_tipo VARCHAR2 ( 100 ) := 'Ressarcimento [Performance]';
    mnm_cproc VARCHAR2 ( 100 ) := 'Relatório de Crédito dos Cartões [Performance]';
    mds_cproc VARCHAR2 ( 100 ) := 'Emitir relatório de crédito para vendas com cartão de crédito / débito';

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

        lib_proc.add_param (
                             pstr
                           ,    '                                   '
                             || '____________________________________________________'
                           , 'VARCHAR2'
                           , 'TEXT'
        );
        lib_proc.add_param ( pstr
                           , 'Relatório para Conferência de Processamento'
                           , --P_CONF
                            'VARCHAR2'
                           , 'CHECKBOX'
                           , 'N'
                           , 'N'
                           , NULL );

        lib_proc.add_param (
                             pstr
                           , 'Filiais'
                           , --P_LOJAS
                            'VARCHAR2'
                           , 'MULTISELECT'
                           , 'S'
                           , NULL
                           , NULL
                           ,    '
                            SELECT A.COD_ESTAB, A.COD_ESTAB || '' - '' || B.COD_ESTADO || '' - '' || A.CGC || '' - '' || INITCAP(A.BAIRRO) || '' / '' || INITCAP(A.CIDADE)
                            FROM ESTABELECIMENTO A, ESTADO B, MSAFI.DSP_ESTABELECIMENTO C
                            WHERE A.COD_EMPRESA  = '''
                             || mcod_empresa
                             || '''
                              AND B.IDENT_ESTADO = A.IDENT_ESTADO
                              AND A.COD_EMPRESA  = C.COD_EMPRESA
                              AND A.COD_ESTAB    = C.COD_ESTAB
                              AND C.TIPO         = ''L''
                              AND C.COD_ESTADO   = ''SP'' --- LOJAS SP APENAS
                            ORDER BY B.COD_ESTADO, A.COD_ESTAB
                           '
        );

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
        msafi.dsp_control.writelog ( 'CARTOESR'
                                   , p_i_texto );
    ---> Para acompanhar processamento usar SELECT abaixo
    --SELECT * FROM DSP_LOG
    --WHERE LOG_TYPE = 'CARTOESR'
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

    FUNCTION executar ( p_data_ini DATE
                      , p_data_fim DATE
                      , p_sintetico VARCHAR2
                      , p_analitico VARCHAR2
                      , p_conf VARCHAR2
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

        --
        TYPE cur_typ IS REF CURSOR;

        cr_cup cur_typ;
        --
        v_class VARCHAR2 ( 1 ) := 'a';

        --Variaveis para relatorio de conferencia
        TYPE curtype IS REF CURSOR;

        src_cur curtype;
        c_curid NUMBER;
        v_desctab dbms_sql.desc_tab;
        v_colcnt NUMBER;
        v_namevar VARCHAR2 ( 50 );
        v_numvar NUMBER;
        v_datevar DATE;
        v_color VARCHAR2 ( 100 );

        ------------------------------------------------------------------------------------------------------------------------------------------------------
        --RANGE DE DATAS PARA BUSCAR VENDAS
        v_data_inicial DATE := p_data_ini; -- DATA INICIAL
        v_data_final DATE := p_data_fim; -- DATA FINAL

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
            lib_proc.new ( 'DPSP_REL_CARTOES_PF_CPROC'
                         , 48
                         , 150 );

        IF mcod_empresa IS NULL THEN
            lib_proc.add_log ( 'Código da empresa deve ser informado como parâmetro global.'
                             , 0 );
            lib_proc.add ( 'ERRO' );
            lib_proc.add ( 'CÓDIGO DA EMPRESA DEVE SER INFORMADO COMO PARÂMETRO GLOBAL.' );
            lib_proc.close ( );
            RETURN mproc_id;
        END IF;

        msafi.dsp_control.createprocess ( 'DPSP_R_CARTOES' --P_I_PROCID            IN VARCHAR2             , --VARCHAR2(16)
                                        , 'DPSP_REL_CARTOES' --P_I_PROC_DESCR        IN VARCHAR2             , --VARCHAR2(64)
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
                           AND tipo = 'L'
                           AND cod_estado = 'SP' ) LOOP
                a_estabs.EXTEND ( );
                a_estabs ( a_estabs.LAST ) := c1.cod_estab;
            END LOOP;
        END IF;

        ---

        IF ( p_sintetico = 'S' ) THEN
            lib_proc.add_tipo ( mproc_id
                              , 1
                              ,    mcod_empresa
                                || '_SINTETICO_'
                                || TO_CHAR ( p_data_ini
                                           , 'MMYYYY' )
                                || '_REL_CARTOES.XLS'
                              , 2 );

            lib_proc.add ( dsp_planilha.header
                         , ptipo => 1 );
            lib_proc.add ( dsp_planilha.tabela_inicio
                         , ptipo => 1 );

            lib_proc.add ( dsp_planilha.linha ( p_conteudo => dsp_planilha.campo (    'RELATÓRIO SINTÉTICO '
                                                                                   || TO_CHAR ( p_data_ini
                                                                                              , 'MM/YYYY' )
                                                                                 , p_custom => 'COLSPAN=4' )
                                              , p_class => 'h' )
                         , ptipo => 1 );

            lib_proc.add ( dsp_planilha.linha (
                                                p_conteudo =>    dsp_planilha.campo ( 'EMPRESA' )
                                                              || --      COD_EMPRESA
                                                                dsp_planilha.campo ( 'ESTAB' )
                                                              || --     ,COD_ESTAB
                                                                dsp_planilha.campo ( 'UF' )
                                                              || --     ,UF_ESTAB
                                                                dsp_planilha.campo ( 'TOTAL CRÉDITO' )
                                              , p_class => 'h'
                           )
                         , ptipo => 1 );

            FOR i IN 1 .. a_estabs.COUNT LOOP
                FOR cr_r IN load_sintetico ( a_estabs ( i )
                                           , v_data_inicial
                                           , v_data_final ) LOOP
                    IF v_class = 'a' THEN
                        v_class := 'b';
                    ELSE
                        v_class := 'a';
                    END IF;

                    v_text01 :=
                        dsp_planilha.linha (
                                             p_conteudo =>    dsp_planilha.campo ( cr_r.cod_empresa )
                                                           || --      COD_EMPRESA
                                                             dsp_planilha.campo ( cr_r.cod_estab )
                                                           || --     ,COD_ESTAB
                                                             dsp_planilha.campo ( cr_r.uf_estab )
                                                           || --     ,UF_ESTAB
                                                             dsp_planilha.campo ( moeda ( cr_r.total_credito ) ) --   ,TOTAL_CREDITO
                                           , p_class => v_class
                        );

                    lib_proc.add ( v_text01
                                 , ptipo => 1 );
                END LOOP; --FOR CR_R IN LOAD_SINTETICO(V_DATA_INICIAL, V_DATA_FINAL)
            END LOOP; --FOR i IN 1..A_ESTABS.COUNT

            lib_proc.add ( dsp_planilha.tabela_fim
                         , ptipo => 1 );
        END IF; --IF (P_SINTETICO = 'S') THEN

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
                                    || '_REL_CARTOES.XLS'
                                  , 2 );

                lib_proc.add ( dsp_planilha.header
                             , ptipo => i );
                lib_proc.add ( dsp_planilha.tabela_inicio
                             , ptipo => i );

                lib_proc.add ( dsp_planilha.linha ( p_conteudo =>    dsp_planilha.campo ( 'SAÍDA'
                                                                                        , p_custom => 'COLSPAN=21' )
                                                                  || dsp_planilha.campo (
                                                                                          'DADOS CARTÃO'
                                                                                        , p_custom => 'COLSPAN=8 BGCOLOR=#000086'
                                                                     )
                                                                  || dsp_planilha.campo (
                                                                                          'ENTRADA'
                                                                                        , p_custom => 'COLSPAN=26 BGCOLOR=#007100'
                                                                     )
                                                                  || dsp_planilha.campo (
                                                                                          'CAMPOS CALCULADOS'
                                                                                        , p_custom => 'COLSPAN=5 BGCOLOR=#cb9d00'
                                                                     )
                                                  , p_class => 'h' )
                             , ptipo => i );

                lib_proc.add ( dsp_planilha.linha ( p_conteudo =>    dsp_planilha.campo ( 'EMPRESA' )
                                                                  || --      COD_EMPRESA
                                                                    dsp_planilha.campo ( 'ESTAB' )
                                                                  || --     ,COD_ESTAB
                                                                    dsp_planilha.campo ( 'UF' )
                                                                  || --     ,UF_ESTAB
                                                                    dsp_planilha.campo ( 'DOCTO' )
                                                                  || --     ,DOCTO
                                                                    dsp_planilha.campo ( 'COD PRODUTO' )
                                                                  || --     ,COD_PRODUTO
                                                                    dsp_planilha.campo ( 'NUM ITEM' )
                                                                  || --     ,NUM_ITEM
                                                                    dsp_planilha.campo ( 'DESCRICAO' )
                                                                  || --     ,DESCR_ITEM
                                                                    dsp_planilha.campo ( 'DOC FISCAL' )
                                                                  || --     ,NUM_DOCFIS
                                                                    dsp_planilha.campo ( 'DATA FISCAL' )
                                                                  || --     ,DATA_FISCAL
                                                                    dsp_planilha.campo ( 'SERIE' )
                                                                  || --     ,SERIE_DOCFIS
                                                                    dsp_planilha.campo ( 'QUANTIDADE' )
                                                                  || --     ,QUANTIDADE
                                                                    dsp_planilha.campo ( 'NBM' )
                                                                  || --     ,COD_NBM
                                                                    dsp_planilha.campo ( 'CFOP' )
                                                                  || --     ,COD_CFO
                                                                    dsp_planilha.campo ( 'GRUPO PRODUTO' )
                                                                  || --     ,GRUPO_PRODUTO
                                                                    dsp_planilha.campo ( 'VLR DESCONTO' )
                                                                  || --     ,VLR_DESCONTO
                                                                    dsp_planilha.campo ( 'VLR CONTABIL' )
                                                                  || --     ,VLR_CONTABIL
                                                                    dsp_planilha.campo ( 'CHAVE NFE' )
                                                                  || --     ,NUM_AUTENTIC_NFE
                                                                    dsp_planilha.campo ( 'VLR BASE ICMS' )
                                                                  || --     ,VLR_BASE_ICMS
                                                                    dsp_planilha.campo ( 'ALIQ ICMS' )
                                                                  || --     ,VLR_ALIQ_ICMS
                                                                    dsp_planilha.campo ( 'VLR ICMS' )
                                                                  || --     ,VLR_ICMS
                                                                    dsp_planilha.campo ( 'TOTALIZADOR' )
                                                                  || --     ,DESCR_TOT
                                                                    dsp_planilha.campo (
                                                                                         'AUTORIZADORA'
                                                                                       , p_custom => 'BGCOLOR=#000086'
                                                                     )
                                                                  || --     ,AUTORIZADORA
                                                                    dsp_planilha.campo (
                                                                                         'NOME DA VAN'
                                                                                       , p_custom => 'BGCOLOR=#000086'
                                                                     )
                                                                  || --     ,NOME_VAN
                                                                    dsp_planilha.campo (
                                                                                         'VLR PAGO CARTAO'
                                                                                       , p_custom => 'BGCOLOR=#000086'
                                                                     )
                                                                  || --     ,VLR_PAGO_CARTAO
                                                                    dsp_planilha.campo (
                                                                                         'FORMA PAGTO'
                                                                                       , p_custom => 'BGCOLOR=#000086'
                                                                     )
                                                                  || --     ,FORMA_PAGTO
                                                                    dsp_planilha.campo (
                                                                                         'NUM PARCELAS'
                                                                                       , p_custom => 'BGCOLOR=#000086'
                                                                     )
                                                                  || --     ,NUM_PARCELAS
                                                                    dsp_planilha.campo (
                                                                                         'CODIGO APROVACAO'
                                                                                       , p_custom => 'BGCOLOR=#000086'
                                                                     )
                                                                  || --     ,CODIGO_APROVACAO
                                                                    dsp_planilha.campo (
                                                                                         'TAXA CARTÃO %'
                                                                                       , p_custom => 'BGCOLOR=#000086'
                                                                     )
                                                                  || --     ,TAXA_CARTAO (B)
                                                                    dsp_planilha.campo (
                                                                                         'VLR PAGTO TARIFA'
                                                                                       , p_custom => 'BGCOLOR=#000086'
                                                                     )
                                                                  || --     ,VLR_PAGTO_TARIFA
                                                                     ---
                                                                     dsp_planilha.campo (
                                                                                          'ESTAB'
                                                                                        , p_custom => 'BGCOLOR=#007100'
                                                                     )
                                                                  || --     ,COD_ESTAB_E
                                                                    dsp_planilha.campo (
                                                                                         'DATA FISCAL'
                                                                                       , p_custom => 'BGCOLOR=#007100'
                                                                     )
                                                                  || --     ,DATA_FISCAL_E
                                                                    dsp_planilha.campo (
                                                                                         'DATA EMISSAO'
                                                                                       , p_custom => 'BGCOLOR=#007100'
                                                                     )
                                                                  || --     ,DATA_EMISSAO_E
                                                                    dsp_planilha.campo (
                                                                                         'DOC FISCAL'
                                                                                       , p_custom => 'BGCOLOR=#007100'
                                                                     )
                                                                  || --     ,NUM_DOCFIS_E
                                                                    dsp_planilha.campo (
                                                                                         'SERIE'
                                                                                       , p_custom => 'BGCOLOR=#007100'
                                                                     )
                                                                  || --   ,SERIE_DOCFIS_E
                                                                    dsp_planilha.campo (
                                                                                         'NUM ITEM'
                                                                                       , p_custom => 'BGCOLOR=#007100'
                                                                     )
                                                                  || --     ,NUM_ITEM_E
                                                                    dsp_planilha.campo (
                                                                                         'COD FIS JUR'
                                                                                       , p_custom => 'BGCOLOR=#007100'
                                                                     )
                                                                  || --     ,COD_FIS_JUR_E
                                                                    dsp_planilha.campo (
                                                                                         'CNPJ'
                                                                                       , p_custom => 'BGCOLOR=#007100'
                                                                     )
                                                                  || --     ,CPF_CGC_E
                                                                    dsp_planilha.campo (
                                                                                         'NBM'
                                                                                       , p_custom => 'BGCOLOR=#007100'
                                                                     )
                                                                  || --     ,COD_NBM_E
                                                                    dsp_planilha.campo (
                                                                                         'CFOP'
                                                                                       , p_custom => 'BGCOLOR=#007100'
                                                                     )
                                                                  || --     ,COD_CFO_E
                                                                    dsp_planilha.campo (
                                                                                         'FINALIDADE'
                                                                                       , p_custom => 'BGCOLOR=#007100'
                                                                     )
                                                                  || --     ,COD_NATUREZA_OP_E
                                                                    dsp_planilha.campo (
                                                                                         'COD_PRODUTO'
                                                                                       , p_custom => 'BGCOLOR=#007100'
                                                                     )
                                                                  || --     ,COD_PRODUTO_E
                                                                    dsp_planilha.campo (
                                                                                         'VLR CONTABIL'
                                                                                       , p_custom => 'BGCOLOR=#007100'
                                                                     )
                                                                  || --     ,VLR_CONTAB_ITEM_E
                                                                    dsp_planilha.campo (
                                                                                         'QUANTIDADE'
                                                                                       , p_custom => 'BGCOLOR=#007100'
                                                                     )
                                                                  || --     ,QUANTIDADE_E
                                                                    dsp_planilha.campo (
                                                                                         'VLR UNIT'
                                                                                       , p_custom => 'BGCOLOR=#007100'
                                                                     )
                                                                  || --     ,VLR_UNIT_E
                                                                    dsp_planilha.campo (
                                                                                         'CST'
                                                                                       , p_custom => 'BGCOLOR=#007100'
                                                                     )
                                                                  || --     ,COD_SITUACAO_B_E
                                                                    dsp_planilha.campo (
                                                                                         'UF'
                                                                                       , p_custom => 'BGCOLOR=#007100'
                                                                     )
                                                                  || --     ,COD_ESTADO_E
                                                                    dsp_planilha.campo (
                                                                                         'ID PEOPLESOFT'
                                                                                       , p_custom => 'BGCOLOR=#007100'
                                                                     )
                                                                  || --     ,NUM_CONTROLE_DOCTO_E
                                                                    dsp_planilha.campo (
                                                                                         'CHAVE NFE ENTRADA'
                                                                                       , p_custom => 'BGCOLOR=#007100'
                                                                     )
                                                                  || --     ,NUM_AUTENTIC_NFE_E
                                                                    dsp_planilha.campo (
                                                                                         'VLR BASE ICMS UNIT'
                                                                                       , p_custom => 'BGCOLOR=#007100'
                                                                     )
                                                                  || --     ,BASE_ICMS_UNIT
                                                                    dsp_planilha.campo (
                                                                                         'VLR ICMS UNIT'
                                                                                       , p_custom => 'BGCOLOR=#007100'
                                                                     )
                                                                  || --     ,VLR_ICMS_UNIT
                                                                    dsp_planilha.campo (
                                                                                         'ALIQ ICMS'
                                                                                       , p_custom => 'BGCOLOR=#007100'
                                                                     )
                                                                  || --     ,ALIQ_ICMS
                                                                    dsp_planilha.campo (
                                                                                         'BASE ICMS ST UNIT'
                                                                                       , p_custom => 'BGCOLOR=#007100'
                                                                     )
                                                                  || --     ,BASE_ST_UNIT
                                                                    dsp_planilha.campo (
                                                                                         'VLR ICMS ST UNIT'
                                                                                       , p_custom => 'BGCOLOR=#007100'
                                                                     )
                                                                  || --     ,VLR_ICMS_ST_UNIT
                                                                    dsp_planilha.campo (
                                                                                         'ALIQ ST'
                                                                                       , p_custom => 'BGCOLOR=#007100'
                                                                     )
                                                                  || --     ,ID_ALIQ_ST
                                                                    dsp_planilha.campo (
                                                                                         'LIB CONTROL'
                                                                                       , p_custom => 'BGCOLOR=#007100'
                                                                     )
                                                                  || --   ,STAT_LIBER_CNTR
                                                                     ---
                                                                     dsp_planilha.campo (
                                                                                          'BASE X CARTAO'
                                                                                        , p_custom => 'BGCOLOR=#cb9d00'
                                                                     )
                                                                  || --   ,BASEST_X_CARTAO
                                                                    dsp_planilha.campo (
                                                                                         'NOVA BASE   '
                                                                                       , p_custom => 'BGCOLOR=#cb9d00'
                                                                     )
                                                                  || --    ,NOVA_BASE
                                                                    dsp_planilha.campo (
                                                                                         'NOVO IMPOSTO'
                                                                                       , p_custom => 'BGCOLOR=#cb9d00'
                                                                     )
                                                                  || --    ,NOVO_IMPOSTO
                                                                    dsp_planilha.campo (
                                                                                         'DIF ST X NOVO ST'
                                                                                       , p_custom => 'BGCOLOR=#cb9d00'
                                                                     )
                                                                  || --    ,DIF_ST_X_NOVO
                                                                    dsp_planilha.campo (
                                                                                         'TOTAL CREDITO'
                                                                                       , p_custom => 'BGCOLOR=#cb9d00'
                                                                     ) --    ,TOTAL_CREDITO
                                                  , p_class => 'h' )
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
                                             p_conteudo =>    dsp_planilha.campo ( cr_r.cod_empresa )
                                                           || --      COD_EMPRESA
                                                             dsp_planilha.campo ( cr_r.cod_estab )
                                                           || --     ,COD_ESTAB
                                                             dsp_planilha.campo ( cr_r.uf_estab )
                                                           || --     ,UF_ESTAB
                                                             dsp_planilha.campo ( cr_r.docto )
                                                           || --     ,DOCTO
                                                             dsp_planilha.campo ( cr_r.cod_produto )
                                                           || --     ,COD_PRODUTO
                                                             dsp_planilha.campo ( cr_r.num_item )
                                                           || --     ,NUM_ITEM
                                                             dsp_planilha.campo ( cr_r.descr_item )
                                                           || --     ,DESCR_ITEM
                                                             dsp_planilha.campo ( cr_r.num_docfis )
                                                           || --     ,NUM_DOCFIS
                                                             dsp_planilha.campo ( cr_r.data_fiscal )
                                                           || --     ,DATA_FISCAL
                                                             dsp_planilha.campo ( cr_r.serie_docfis )
                                                           || --     ,SERIE_DOCFIS
                                                             dsp_planilha.campo ( moeda ( cr_r.quantidade ) )
                                                           || --     ,QUANTIDADE
                                                             dsp_planilha.campo ( cr_r.cod_nbm )
                                                           || --     ,COD_NBM
                                                             dsp_planilha.campo ( cr_r.cod_cfo )
                                                           || --     ,COD_CFO
                                                             dsp_planilha.campo ( cr_r.grupo_produto )
                                                           || --     ,GRUPO_PRODUTO
                                                             dsp_planilha.campo ( moeda ( cr_r.vlr_desconto ) )
                                                           || --     ,VLR_DESCONTO
                                                             dsp_planilha.campo ( moeda ( cr_r.vlr_contabil ) )
                                                           || --     ,VLR_CONTABIL
                                                             dsp_planilha.campo (
                                                                                  dsp_planilha.texto (
                                                                                                       cr_r.num_autentic_nfe
                                                                                  )
                                                              )
                                                           || --     ,NUM_AUTENTIC_NFE
                                                             dsp_planilha.campo ( moeda ( cr_r.vlr_base_icms ) )
                                                           || --     ,VLR_BASE_ICMS
                                                             dsp_planilha.campo ( moeda ( cr_r.vlr_aliq_icms ) )
                                                           || --     ,VLR_ALIQ_ICMS
                                                             dsp_planilha.campo ( moeda ( cr_r.vlr_icms ) )
                                                           || --     ,VLR_ICMS
                                                             dsp_planilha.campo ( cr_r.descr_tot )
                                                           || --     ,DESCR_TOT
                                                             dsp_planilha.campo ( cr_r.autorizadora )
                                                           || --     ,AUTORIZADORA
                                                             dsp_planilha.campo ( cr_r.nome_van )
                                                           || --     ,NOME_VAN
                                                             dsp_planilha.campo ( moeda ( cr_r.vlr_pago_cartao ) )
                                                           || --     ,VLR_PAGO_CARTAO
                                                             dsp_planilha.campo ( cr_r.forma_pagto )
                                                           || --     ,FORMA_PAGTO
                                                             dsp_planilha.campo ( cr_r.num_parcelas )
                                                           || --     ,NUM_PARCELAS
                                                             dsp_planilha.campo ( cr_r.codigo_aprovacao )
                                                           || --     ,CODIGO_APROVACAO
                                                             dsp_planilha.campo ( cr_r.taxa_cartao )
                                                           || --     ,TAXA_CARTAO (B)
                                                             dsp_planilha.campo ( cr_r.vlr_pagto_tarifa )
                                                           || --     ,VLR_PAGTO_TARIFA
                                                              ---
                                                              dsp_planilha.campo ( cr_r.cod_estab_e )
                                                           || --   ,COD_ESTAB_E
                                                             dsp_planilha.campo ( cr_r.data_fiscal_e )
                                                           || --   ,DATA_FISCAL_E
                                                             dsp_planilha.campo ( cr_r.data_emissao_e )
                                                           || --   ,DATA_EMISSAO_E
                                                             dsp_planilha.campo ( cr_r.num_docfis_e )
                                                           || --   ,NUM_DOCFIS_E
                                                             dsp_planilha.campo ( cr_r.serie_docfis_e )
                                                           || --  ,SERIE_DOCFIS_E
                                                             dsp_planilha.campo ( cr_r.num_item_e )
                                                           || --   ,NUM_ITEM_E
                                                             dsp_planilha.campo ( cr_r.cod_fis_jur_e )
                                                           || --   ,COD_FIS_JUR_E
                                                             dsp_planilha.campo (
                                                                                  dsp_planilha.texto (
                                                                                                       cr_r.cpf_cgc_e
                                                                                  )
                                                              )
                                                           || --   ,CPF_CGC_E
                                                             dsp_planilha.campo ( cr_r.cod_nbm_e )
                                                           || --   ,COD_NBM_E
                                                             dsp_planilha.campo ( cr_r.cod_cfo_e )
                                                           || --   ,COD_CFO_E
                                                             dsp_planilha.campo ( cr_r.cod_natureza_op_e )
                                                           || --   ,COD_NATUREZA_OP_E
                                                             dsp_planilha.campo ( cr_r.cod_produto_e )
                                                           || --   ,COD_PRODUTO_E
                                                             dsp_planilha.campo ( moeda ( cr_r.vlr_contab_item_e ) )
                                                           || --   ,VLR_CONTAB_ITEM_E
                                                             dsp_planilha.campo ( moeda ( cr_r.quantidade_e ) )
                                                           || --   ,QUANTIDADE_E
                                                             dsp_planilha.campo ( moeda ( cr_r.vlr_unit_e ) )
                                                           || --   ,VLR_UNIT_E
                                                             dsp_planilha.campo ( cr_r.cod_situacao_b_e )
                                                           || --   ,COD_SITUACAO_B_E
                                                             dsp_planilha.campo ( cr_r.cod_estado_e )
                                                           || --   ,COD_ESTADO_E
                                                             dsp_planilha.campo ( cr_r.num_controle_docto_e )
                                                           || --   ,NUM_CONTROLE_DOCTO_E
                                                             dsp_planilha.campo (
                                                                                  dsp_planilha.texto (
                                                                                                       cr_r.num_autentic_nfe_e
                                                                                  )
                                                              )
                                                           || --   ,NUM_AUTENTIC_NFE_E
                                                             dsp_planilha.campo ( moeda ( cr_r.base_icms_unit ) )
                                                           || --   ,BASE_ICMS_UNIT
                                                             dsp_planilha.campo ( moeda ( cr_r.vlr_icms_unit ) )
                                                           || --   ,VLR_ICMS_UNIT
                                                             dsp_planilha.campo ( moeda ( cr_r.aliq_icms ) )
                                                           || --   ,ALIQ_ICMS
                                                             dsp_planilha.campo ( moeda ( cr_r.base_st_unit ) )
                                                           || --   ,BASE_ST_UNIT
                                                             dsp_planilha.campo ( moeda ( cr_r.vlr_icms_st_unit ) )
                                                           || --   ,VLR_ICMS_ST_UNIT
                                                             dsp_planilha.campo ( cr_r.id_aliq_st )
                                                           || --   ,ID_ALIQ_ST
                                                             dsp_planilha.campo ( cr_r.stat_liber_cntr )
                                                           || --   ,STAT_LIBER_CNTR
                                                              ---
                                                              dsp_planilha.campo ( moeda ( cr_r.basest_x_cartao ) )
                                                           || --   ,BASEST_X_CARTAO
                                                             dsp_planilha.campo ( moeda ( cr_r.nova_base ) )
                                                           || --   ,NOVA_BASE_ST
                                                             dsp_planilha.campo ( moeda ( cr_r.novo_imposto ) )
                                                           || --   ,NOVO_IMPOSTO
                                                             dsp_planilha.campo ( moeda ( cr_r.dif_st_x_novo ) )
                                                           || --   ,DIF_ST_X_NOVO
                                                             dsp_planilha.campo ( moeda ( cr_r.total_credito ) ) --   ,TOTAL_CREDITO
                                           , p_class => v_class
                        );

                    lib_proc.add ( v_text01
                                 , ptipo => i );
                END LOOP; --FOR CR_R IN LOAD_ANALITICO(A_ESTABS(i), V_DATA_INICIAL, V_DATA_FINAL)

                lib_proc.add ( dsp_planilha.tabela_fim
                             , ptipo => i );
            END LOOP;
        END IF; --IF (P_SINTETICO = 'S') THEN

        ---MONTAR RELATORIO ANALITICO-FIM--------------------------------------------------------------------------------

        ---MONTAR RELATORIO DE CONFERENCIA-INI---------------------------------------------------------------------------
        IF ( p_conf = 'S' ) THEN --(1)
            --MONTAR HEADER - INI
            lib_proc.add_tipo ( mproc_id
                              , 200
                              ,    mcod_empresa
                                || '_CONFERENCIA_'
                                || TO_CHAR ( p_data_ini
                                           , 'MMYYYY' )
                                || '_REL_CARTOES.XLS'
                              , 2 );

            lib_proc.add ( dsp_planilha.header
                         , ptipo => 200 );
            lib_proc.add ( dsp_planilha.tabela_inicio
                         , ptipo => 200 );

            --------------
            lib_proc.add ( dsp_planilha.linha_inicio ( p_class => 'h' )
                         , ptipo => 200 );
            lib_proc.add ( dsp_planilha.campo ( p_conteudo => 'LINHAS DE CUPONS POR DIA'
                                              , p_custom => 'COLSPAN=4' )
                         , ptipo => 200 );
            lib_proc.add ( dsp_planilha.linha_fim
                         , ptipo => 200 );
            --------------

            lib_proc.add ( dsp_planilha.linha_inicio ( p_class => 'h' )
                         , ptipo => 200 );

            lib_proc.add ( dsp_planilha.campo ( p_conteudo => 'LOJAS' )
                         , ptipo => 200 );
            lib_proc.add ( dsp_planilha.campo ( p_conteudo => 'UF' )
                         , ptipo => 200 );

            FOR c_d IN c_dias ( v_data_inicial
                              , v_data_final ) --(2)
                                              LOOP
                IF ( v_color = 'BGCOLOR=#000086' ) THEN
                    v_color := ' ';
                ELSE
                    v_color := 'BGCOLOR=#000086';
                END IF;

                lib_proc.add ( dsp_planilha.campo ( p_conteudo => 'DIA_' || c_d.dia
                                                  , p_custom => v_color )
                             , ptipo => 200 );
            END LOOP; --(2)

            lib_proc.add ( dsp_planilha.linha_fim
                         , ptipo => 200 );

            --MONTAR HEADER - FIM

            --MONTAR LINHAS - INI -------------------------------------------------------------------------------------------
            FOR i IN 1 .. a_estabs.COUNT --(5)
                                        LOOP
                IF v_class = 'a' THEN
                    v_class := 'b';
                ELSE
                    v_class := 'a';
                END IF;

                lib_proc.add ( dsp_planilha.linha_inicio ( p_class => v_class )
                             , ptipo => 200 );

                v_text01 := 'SELECT LOJA, UF';

                FOR c_d IN c_dias ( v_data_inicial
                                  , v_data_final ) --(2.1)
                                                  LOOP
                    v_text01 := v_text01 || ', D' || c_d.dia;
                END LOOP; --(2.1)

                v_text01 := v_text01 || ' FROM ';
                v_text01 := v_text01 || '( ';
                v_text01 :=
                       v_text01
                    || '  SELECT B.COD_ESTAB AS LOJA, B.COD_ESTADO AS UF, TO_CHAR(A.DATA_FISCAL,''DDMMYYYY'') AS DATA_FISCAL ';
                v_text01 := v_text01 || '  FROM MSAFI.DPSP_MSAF_CARTOES_jj A, MSAFI.DSP_ESTABELECIMENTO B ';
                v_text01 :=
                       v_text01
                    || '  WHERE A.DATA_FISCAL (+) BETWEEN TO_DATE('''
                    || TO_CHAR ( p_data_ini
                               , 'DDMMYYYY' )
                    || ''',''DDMMYYYY'') AND TO_DATE('''
                    || TO_CHAR ( p_data_fim
                               , 'DDMMYYYY' )
                    || ''',''DDMMYYYY'') ';
                v_text01 := v_text01 || '    AND A.COD_EMPRESA (+) = B.COD_EMPRESA ';
                v_text01 := v_text01 || '    AND A.COD_ESTAB (+)   = B.COD_ESTAB ';
                v_text01 := v_text01 || '    AND B.COD_ESTAB       = ''' || a_estabs ( i ) || ''' ';
                v_text01 := v_text01 || ') ';
                v_text01 := v_text01 || 'PIVOT ';
                v_text01 := v_text01 || '( ';
                v_text01 := v_text01 || '  COUNT(*) ';
                v_text01 := v_text01 || '  FOR DATA_FISCAL IN (';

                FOR c_d IN c_dias ( v_data_inicial
                                  , v_data_final ) --(2.2)
                                                  LOOP
                    v_text01 := v_text01 || '''' || c_d.dia || ''' AS D' || c_d.dia || ',';
                END LOOP; --(2.2)

                v_text01 :=
                    SUBSTR ( v_text01
                           , 1
                           , LENGTH ( v_text01 ) - 1 );

                v_text01 := v_text01 || ') ) ';
                v_text01 := v_text01 || 'ORDER BY UF, LOJA ';

                --LOGA(SUBSTR(V_TEXT01, 1, 1024), FALSE);
                --LOGA(SUBSTR(V_TEXT01, 1024, 1024), FALSE);

                BEGIN
                    OPEN src_cur FOR v_text01;

                    --TRANSFORMAR UM DYNAMIC SQL NATIVO NO PAKAGE 'DBMS_SQL'
                    --NECESSARIO USAR O DBMS_SQL PORQUE NAO SE SABE O NUMERO DE COLUNAS OU SEUS NOMES, JA QUE SAO CRIADOS A PARTIR DOS PARAMETROS
                    c_curid := dbms_sql.to_cursor_number ( src_cur );
                    dbms_sql.describe_columns ( c_curid
                                              , v_colcnt
                                              , v_desctab );

                    --DEFINIR COLUNAS
                    FOR i IN 1 .. v_colcnt LOOP
                        IF v_desctab ( i ).col_type = 2 THEN
                            dbms_sql.define_column ( c_curid
                                                   , i
                                                   , v_numvar );
                        ELSIF v_desctab ( i ).col_type = 12 THEN
                            dbms_sql.define_column ( c_curid
                                                   , i
                                                   , v_datevar );
                        ELSE
                            dbms_sql.define_column ( c_curid
                                                   , i
                                                   , v_namevar
                                                   , 50 );
                        END IF;
                    END LOOP;

                    --BUSCAR LINHAS
                    WHILE dbms_sql.fetch_rows ( c_curid ) > 0 LOOP
                        FOR i IN 1 .. v_colcnt LOOP
                            IF ( v_desctab ( i ).col_type = 1 ) THEN
                                dbms_sql.COLUMN_VALUE ( c_curid
                                                      , i
                                                      , v_namevar );
                                lib_proc.add ( dsp_planilha.campo ( p_conteudo => v_namevar )
                                             , ptipo => 200 );
                            ELSIF ( v_desctab ( i ).col_type = 2 ) THEN
                                dbms_sql.COLUMN_VALUE ( c_curid
                                                      , i
                                                      , v_numvar );
                                lib_proc.add ( dsp_planilha.campo ( p_conteudo => v_numvar )
                                             , ptipo => 200 );
                            ELSIF ( v_desctab ( i ).col_type = 12 ) THEN
                                dbms_sql.COLUMN_VALUE ( c_curid
                                                      , i
                                                      , v_datevar );
                                lib_proc.add ( dsp_planilha.campo ( p_conteudo => v_datevar )
                                             , ptipo => 200 );
                            END IF;
                        END LOOP;
                    END LOOP;

                    dbms_sql.close_cursor ( c_curid );
                END;

                lib_proc.add ( dsp_planilha.linha_fim
                             , ptipo => 200 );
            END LOOP; --(5)

            --MONTAR LINHAS - FIM -------------------------------------------------------------------------------------------

            lib_proc.add ( dsp_planilha.tabela_fim
                         , ptipo => 200 );
        END IF; --(1)

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
END dpsp_rel_cartoes_pf_cproc;
/
SHOW ERRORS;
