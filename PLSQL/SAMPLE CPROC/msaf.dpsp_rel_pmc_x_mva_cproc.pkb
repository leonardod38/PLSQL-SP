Prompt Package Body DPSP_REL_PMC_X_MVA_CPROC;
--
-- DPSP_REL_PMC_X_MVA_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_rel_pmc_x_mva_cproc
IS
    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );
        v_sel_data_fim VARCHAR2 ( 260 )
            := 'SELECT TRUNC( TO_DATE( :1 ,''DD/MM/YYYY'') + ROWNUM - 1) AS DATA_FIM, TRUNC( TO_DATE( :1 ,''DD/MM/YYYY'') + ROWNUM - 1) AS DATA_FIM FROM DUAL CONNECT BY ROWNUM <= LAST_DAY( TO_DATE( :1 ,''DD/MM/YYYY'') ) - TO_DATE( :1 ,''DD/MM/YYYY'') + 1 ORDER BY 1 DESC ';
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
                            'VARCHAR2'
                           , 'COMBOBOX'
                           , 'S'
                           , NULL
                           , '##########'
                           , v_sel_data_fim );

        lib_proc.add_param ( pstr
                           , 'Relatório Sintético'
                           , --P_SINTETICO
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
                           , 'Relatório Sintético do Valor Apurado'
                           , --P_SINTETICO_APURADO
                            'VARCHAR2'
                           , 'CHECKBOX'
                           , 'N'
                           , 'N'
                           , NULL );

        lib_proc.add_param ( pstr
                           , 'Opção Sintético Vlr Apurado'
                           , --P_SINTETICO_FILTRO
                            'VARCHAR2'
                           , 'COMBOBOX'
                           , 'N'
                           , NULL
                           , NULL
                           , '
                            SELECT ''1'',''1 - Valores Positivos e Negativos'' FROM DUAL
                      UNION SELECT ''2'',''2 - Apenas Valores Positivos'' FROM DUAL
                      UNION SELECT ''3'',''3 - Apenas Valores Negativos'' FROM DUAL
                           '  );

        lib_proc.add_param (
                             pstr
                           ,    '                                   '
                             || '____________________________________________________'
                           , 'VARCHAR2'
                           , 'TEXT'
        );
        lib_proc.add_param ( pstr
                           , 'Relatório Analítico'
                           , --P_ANALITICO
                            'VARCHAR2'
                           , 'CHECKBOX'
                           , 'N'
                           , 'N'
                           , NULL );

        lib_proc.add_param ( pstr
                           , 'Opção Analítico'
                           , --P_ANALITICO_FILTRO
                            'VARCHAR2'
                           , 'COMBOBOX'
                           , 'N'
                           , NULL
                           , NULL
                           , '
                            SELECT ''1'',''1 - Valores Positivos e Negativos'' FROM DUAL
                      UNION SELECT ''2'',''2 - Apenas Valores Positivos'' FROM DUAL
                      UNION SELECT ''3'',''3 - Apenas Valores Negativos'' FROM DUAL
                           '  );

        lib_proc.add_param (
                             pstr
                           ,    '                                   '
                             || '____________________________________________________'
                           , 'VARCHAR2'
                           , 'TEXT'
        );
        lib_proc.add_param ( pstr
                           , 'Relatório Mapa Sintético'
                           , --P_MAPA
                            'VARCHAR2'
                           , 'CHECKBOX'
                           , 'N'
                           , 'N'
                           , NULL );

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
                           ,    'SELECT A.COD_ESTAB, A.COD_ESTAB || '' - '' || B.COD_ESTADO || '' - '' || A.CGC || '' - '' || INITCAP(A.BAIRRO) || '' / '' || INITCAP(A.CIDADE) FROM ESTABELECIMENTO A, ESTADO B, MSAFI.DSP_ESTABELECIMENTO C WHERE A.COD_EMPRESA  = '''
                             || mcod_empresa
                             || ''' AND B.IDENT_ESTADO = A.IDENT_ESTADO AND A.COD_EMPRESA = C.COD_EMPRESA AND A.COD_ESTAB = C.COD_ESTAB AND B.COD_ESTADO LIKE :13 AND C.TIPO = ''L'' ORDER BY B.COD_ESTADO, A.COD_ESTAB'
        );

        RETURN pstr;
    END; --FUNCTION PARAMETROS RETURN VARCHAR2 IS

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Relatório de PMC x MVA';
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
        RETURN 'Relatório de Ressarcimento PMC x MVA - Sintético e Analítico 2';
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
        msafi.dsp_control.writelog ( 'RPMCxMVA'
                                   , p_i_texto );
    ---> Para acompanhar processamento usar SELECT abaixo
    --SELECT * FROM DSP_LOG
    --WHERE LOG_TYPE = 'RPMCxMVA'
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

    FUNCTION executar ( p_data_ini DATE
                      , p_data_fim DATE
                      , p_sintetico VARCHAR2
                      , p_sintetico_apurado VARCHAR2
                      , p_sintetico_filtro VARCHAR2
                      , p_analitico VARCHAR2
                      , p_analitico_filtro VARCHAR2
                      , p_mapa VARCHAR2
                      , p_conf VARCHAR2
                      , p_uf VARCHAR2
                      , p_lojas lib_proc.vartab )
        RETURN INTEGER
    IS
        mproc_id INTEGER;
        i1 INTEGER;

        v_proc_status NUMBER := 0;
        v_s_proc_status VARCHAR2 ( 16 );

        TYPE a_estabs_t IS TABLE OF VARCHAR2 ( 6 );

        a_estabs a_estabs_t := a_estabs_t ( );

        --Variaveis genericas
        v_text01 VARCHAR2 ( 6000 );
        v_show VARCHAR2 ( 1 );
        v_color VARCHAR2 ( 100 );
        --
        p_proc_instance VARCHAR2 ( 30 );

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
        v_data_inicial DATE := p_data_ini; -- DATA INICIAL
        v_data_final DATE := p_data_fim; -- DATA FINAL

        ------------------------------------------------------------------------------------------------------------------------------------------------------

        --CURSOR AUXILIAR
        CURSOR c_datas ( p_i_data_inicial IN DATE
                       , p_i_data_final IN DATE )
        IS
            SELECT   TO_CHAR ( data_fiscal
                             , 'MM/YYYY' )
                         AS titulo
                   , MIN ( data_fiscal ) AS data_ini
                   , MAX ( data_fiscal ) AS data_fim
                FROM (SELECT p_i_data_inicial + ( ROWNUM - 1 ) AS data_fiscal
                        FROM all_objects
                       WHERE ROWNUM <= (p_i_data_final - p_i_data_inicial + 1)) b
            GROUP BY TO_CHAR ( data_fiscal
                             , 'MM/YYYY' )
            ORDER BY 2;

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
            lib_proc.new ( $$plsql_unit
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
           AND p_sintetico_apurado <> 'S'
           AND p_analitico <> 'S'
           AND p_mapa <> 'S'
           AND p_conf <> 'S' ) THEN
            lib_proc.add_log (
                               'Escolha ao menos uma opção de impressão de relatório, mapa sintético, sintético, sintético do valor apurado ou analítico.'
                             , 0
            );
            lib_proc.add ( 'ERRO' );
            lib_proc.add ( 'ESCOLHA AO MENOS UMA OPÇÃO DE IMPRESSÃO DE RELATÓRIO, SINTÉTICO OU ANALÍTICO.' );
            lib_proc.close ( );
            RETURN mproc_id;
        END IF;

        msafi.dsp_control.createprocess ( 'DPSP_R_PMC_X_MVA' --P_I_PROCID            IN VARCHAR2             , --VARCHAR2(16)
                                        , 'DPSP_REL_PMC_X_MVA' --P_I_PROC_DESCR        IN VARCHAR2             , --VARCHAR2(64)
                                        , NULL --P_I_DATA_INI          IN DATE     DEFAULT NULL,
                                        , NULL --P_I_DATA_FIM          IN DATE     DEFAULT NULL,
                                        , p_analitico --P_I_DETALHES1         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , p_sintetico --P_I_DETALHES2         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
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
                           AND tipo = 'L' ) LOOP
                a_estabs.EXTEND ( );
                a_estabs ( a_estabs.LAST ) := c1.cod_estab;
            END LOOP;
        END IF;

        ---

        IF ( p_conf = 'S' ) THEN
            --(1)

            --MONTAR HEADER - INI
            lib_proc.add_tipo ( mproc_id
                              , 200
                              ,    mcod_empresa
                                || '_CONFERENCIA_'
                                || TO_CHAR ( p_data_ini
                                           , 'MMYYYY' )
                                || '_REL_PMC_x_MVA.XLS'
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
                v_text01 := v_text01 || '  FROM MSAFI.DPSP_MSAF_PMC_MVA A, MSAFI.DSP_ESTABELECIMENTO B ';
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

        IF ( p_mapa = 'S' ) THEN
            --(1)

            --MONTAR HEADER - INI
            lib_proc.add_tipo ( mproc_id
                              , 176
                              ,    mcod_empresa
                                || '_MAPA_SINTETICO_'
                                || TO_CHAR ( p_data_ini
                                           , 'MMYYYY' )
                                || '_REL_PMC_x_MVA.XLS'
                              , 2 );

            lib_proc.add ( dsp_planilha.header
                         , ptipo => 176 );
            lib_proc.add ( dsp_planilha.tabela_inicio
                         , ptipo => 176 );

            lib_proc.add ( dsp_planilha.linha_inicio ( p_class => 'h' )
                         , ptipo => 176 );

            lib_proc.add ( dsp_planilha.campo ( p_conteudo => ' ' )
                         , ptipo => 176 );
            lib_proc.add ( dsp_planilha.campo ( p_conteudo => ' ' )
                         , ptipo => 176 );

            FOR c_dt IN c_datas ( v_data_inicial
                                , v_data_final ) --(2)
                                                LOOP
                IF ( v_color = 'BGCOLOR=#000086' ) THEN
                    v_color := ' ';
                ELSE
                    v_color := 'BGCOLOR=#000086';
                END IF;

                lib_proc.add ( dsp_planilha.campo ( p_conteudo => ' '
                                                  , p_custom => v_color )
                             , ptipo => 176 );
                lib_proc.add ( dsp_planilha.campo ( p_conteudo => c_dt.titulo
                                                  , p_custom => v_color )
                             , ptipo => 176 );
                lib_proc.add ( dsp_planilha.campo ( p_conteudo => ' '
                                                  , p_custom => v_color )
                             , ptipo => 176 );
            END LOOP; --(2)

            lib_proc.add ( dsp_planilha.linha_fim
                         , ptipo => 176 );
            lib_proc.add ( dsp_planilha.linha_inicio ( p_class => 'h' )
                         , ptipo => 176 );

            lib_proc.add ( dsp_planilha.campo ( p_conteudo => ' ' )
                         , ptipo => 176 );
            lib_proc.add ( dsp_planilha.campo ( p_conteudo => ' ' )
                         , ptipo => 176 );
            lib_proc.add ( dsp_planilha.campo ( p_conteudo => ' ' )
                         , ptipo => 176 );
            v_color := ' ';

            FOR c_dt IN c_datas ( v_data_inicial
                                , v_data_final ) --(2)
                                                LOOP
                IF ( v_color = 'BGCOLOR=#000086' ) THEN
                    v_color := ' ';
                ELSE
                    v_color := 'BGCOLOR=#000086';
                END IF;

                lib_proc.add ( dsp_planilha.campo ( p_conteudo => 'VLR_DIF_QTDE'
                                                  , p_custom => v_color )
                             , ptipo => 176 );
                lib_proc.add ( dsp_planilha.campo ( p_conteudo => 'VLR_DIF_QTDE_XML'
                                                  , p_custom => v_color )
                             , ptipo => 176 );
            --   lib_proc.add(dsp_planilha.campo(p_conteudo => 'TOTAL',
            --                                   p_custom   => v_color),
            --                 ptipo => 176);

            END LOOP; --(2)

            lib_proc.add ( dsp_planilha.linha_fim
                         , ptipo => 176 );

            --MONTAR HEADER - FIM

            --MONTAR LINHAS - INI -------------------------------------------------------------------------------------------
            FOR i IN 1 .. a_estabs.COUNT --(3)
                                        LOOP
                IF v_class = 'a' THEN
                    v_class := 'b';
                ELSE
                    v_class := 'a';
                END IF;

                lib_proc.add ( dsp_planilha.linha_inicio ( p_class => v_class )
                             , ptipo => 176 );
                v_show := 'Y'; --MOSTRAR COD ESTAB E UF APENAS 1 VEZ

                FOR c_dt IN c_datas ( v_data_inicial
                                    , v_data_final ) --(4)
                                                    LOOP
                    FOR cr_s IN load_sintetico ( a_estabs ( i )
                                               , c_dt.data_ini
                                               , c_dt.data_fim ) --(5)
                                                                LOOP
                        IF ( v_show = 'Y' ) THEN
                            lib_proc.add ( dsp_planilha.campo ( p_conteudo => cr_s.cod_estab )
                                         , ptipo => 176 );
                            lib_proc.add ( dsp_planilha.campo ( p_conteudo => cr_s.cod_estado )
                                         , ptipo => 176 );
                            lib_proc.add ( dsp_planilha.campo ( p_conteudo => cr_s.periodo )
                                         , ptipo => 176 );
                            v_show := 'N';
                        END IF;

                        lib_proc.add ( dsp_planilha.campo ( p_conteudo => moeda ( cr_s.vlr_dif_qtde ) )
                                     , ptipo => 176 );
                        lib_proc.add ( dsp_planilha.campo ( p_conteudo => moeda ( cr_s.vlr_dif_qtde_xml ) )
                                     , ptipo => 176 );
                    END LOOP; --(5)
                END LOOP; --(4)

                lib_proc.add ( dsp_planilha.linha_fim
                             , ptipo => 176 );
            END LOOP; --(3)

            --MONTAR LINHAS - FIM -------------------------------------------------------------------------------------------

            lib_proc.add ( dsp_planilha.tabela_fim
                         , ptipo => 176 );
        END IF; --(1)

        IF ( p_sintetico = 'S' ) THEN
            ---MONTAR RELATORIO SINTETICO-INI--------------------------------------------------------------------------------
            lib_proc.add_tipo ( mproc_id
                              , 99999
                              ,    mcod_empresa
                                || '_SINTETICO_'
                                || TO_CHAR ( p_data_ini
                                           , 'MMYYYY' )
                                || '_REL_PMC_x_MVA.XLS'
                              , 2 );

            lib_proc.add ( dsp_planilha.header
                         , ptipo => 99999 );
            lib_proc.add ( dsp_planilha.tabela_inicio
                         , ptipo => 99999 );

            lib_proc.add ( dsp_planilha.linha (
                                                p_conteudo =>    dsp_planilha.campo ( 'ESTAB' )
                                                              || --
                                                                dsp_planilha.campo ( 'UF' )
                                                              || --
                                                                dsp_planilha.campo ( 'PERIODO' )
                                                              || --
                                                                dsp_planilha.campo ( 'VLR_DIF_QTDE' )
                                                              || --
                                                                dsp_planilha.campo ( 'VLR_DIF_QTDE_XML' ) --
                                              , p_class => 'h'
                           )
                         , ptipo => 99999 );

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
                                             p_conteudo =>    dsp_planilha.campo ( cr_s.cod_estab )
                                                           || --
                                                             dsp_planilha.campo ( cr_s.cod_estado )
                                                           || --
                                                             dsp_planilha.campo ( cr_s.periodo )
                                                           || --
                                                             dsp_planilha.campo ( moeda ( cr_s.vlr_dif_qtde ) )
                                                           || --
                                                             dsp_planilha.campo ( moeda ( cr_s.vlr_dif_qtde_xml ) ) --
                                           , p_class => v_class
                        );
                    lib_proc.add ( v_text01
                                 , ptipo => 99999 );
                END LOOP; --FOR CR_R IN LOAD_ANALITICO(A_ESTABS(i), V_DATA_INICIAL, V_DATA_FINAL)
            END LOOP; --FOR i IN 1..A_ESTABS.COUNT

            lib_proc.add ( dsp_planilha.tabela_fim
                         , ptipo => 99999 );
        ---MONTAR RELATORIO SINTETICO-FIM--------------------------------------------------------------------------------
        END IF; --IF (P_SINTETICO = 'S') THEN

        IF ( p_sintetico_apurado = 'S' ) THEN
            ---MONTAR RELATORIO SINTETICO APURADO-INI--------------------------------------------------------------------------------
            lib_proc.add_tipo ( mproc_id
                              , 999
                              ,    mcod_empresa
                                || '_SINTETICO_VLR_APURADO_'
                                || TO_CHAR ( p_data_ini
                                           , 'MMYYYY' )
                                || '_REL_PMC_x_MVA.XLS'
                              , 2 );

            lib_proc.add ( dsp_planilha.header
                         , ptipo => 999 );
            lib_proc.add ( dsp_planilha.tabela_inicio
                         , ptipo => 999 );

            lib_proc.add ( dsp_planilha.linha (
                                                p_conteudo =>    dsp_planilha.campo ( 'ESTAB' )
                                                              || --
                                                                dsp_planilha.campo ( 'UF' )
                                                              || --
                                                                dsp_planilha.campo ( 'TOTAL APURADO' )
                                                              || --
                                                                dsp_planilha.campo ( 'TOTAL APURADO XML' ) --
                                              , p_class => 'h'
                           )
                         , ptipo => 999 );

            FOR i IN a_estabs.FIRST .. a_estabs.LAST LOOP
                FOR cr_sa IN load_sintetico_apurado ( a_estabs ( i )
                                                    , v_data_inicial
                                                    , v_data_final
                                                    , p_sintetico_filtro ) LOOP
                    IF v_class = 'a' THEN
                        v_class := 'b';
                    ELSE
                        v_class := 'a';
                    END IF;

                    v_text01 :=
                        dsp_planilha.linha (
                                             p_conteudo =>    dsp_planilha.campo ( cr_sa.cod_estab )
                                                           || --
                                                             dsp_planilha.campo ( cr_sa.cod_estado )
                                                           || --
                                                             dsp_planilha.campo ( moeda ( cr_sa.vlr_apurado ) )
                                                           || --
                                                             dsp_planilha.campo ( moeda ( cr_sa.vlr_apurado_xml ) ) --
                                           , p_class => v_class
                        );
                    lib_proc.add ( v_text01
                                 , ptipo => 999 );
                END LOOP; --FOR CR_R IN LOAD_ANALITICO_APURADO(A_ESTABS(i), V_DATA_INICIAL, V_DATA_FINAL, P_SINTETICO_FILTRO)
            END LOOP; --FOR i IN 1..A_ESTABS.COUNT

            lib_proc.add ( dsp_planilha.tabela_fim
                         , ptipo => 999 );
        ---MONTAR RELATORIO SINTETICO APURADO-FIM--------------------------------------------------------------------------------
        END IF; --IF (P_SINTETICO_APURADO = 'S') THEN

        IF ( p_analitico = 'S' ) THEN
            ---MONTAR RELATORIO ANALITICO-INI--------------------------------------------------------------------------------
            FOR i IN 1 .. a_estabs.COUNT LOOP
                SELECT cod_estado
                  INTO v_uf
                  FROM msafi.dsp_estabelecimento
                 WHERE cod_empresa = mcod_empresa
                   AND cod_estab = a_estabs ( i );

                lib_proc.add_tipo ( mproc_id
                                  , i
                                  ,    mcod_empresa
                                    || '_'
                                    || v_uf
                                    || '_'
                                    || a_estabs ( i )
                                    || '_'
                                    || TO_CHAR ( p_data_ini
                                               , 'MMYYYY' )
                                    || '_REL_PMC_x_MVA.XLS'
                                  , 2 );

                lib_proc.add ( dsp_planilha.header
                             , ptipo => i );
                lib_proc.add ( dsp_planilha.tabela_inicio
                             , ptipo => i );

                lib_proc.add ( dsp_planilha.linha ( p_conteudo =>    dsp_planilha.campo ( 'SAÍDA'
                                                                                        , p_custom => 'COLSPAN=15' )
                                                                  || --
                                                                    dsp_planilha.campo (
                                                                                         'ENTRADA'
                                                                                       , p_custom => 'COLSPAN=26 BGCOLOR=#000086'
                                                                     )
                                                                  || --
                                                                    dsp_planilha.campo (
                                                                                         'CAMPOS AUXILIARES'
                                                                                       , p_custom => 'COLSPAN=11 BGCOLOR=#008000'
                                                                     ) --
                                                  , p_class => 'h' )
                             , ptipo => i );

                lib_proc.add ( dsp_planilha.linha ( p_conteudo =>    dsp_planilha.campo ( 'ESTAB' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'UF' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'DOCTO' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'COD PROD' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'LISTA' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'DESCRICAO' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'NUM CF' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'DT FISCAL CF' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'QTD VENDA' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'NCM' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'CFOP' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'GRUPO' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'DESCONTO' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'VLR CONTAB' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'CHAVE ACESSO SAIDA' )
                                                                  || --
                                                                    dsp_planilha.campo (
                                                                                         'ORIGEM'
                                                                                       , p_custom => 'BGCOLOR=#000086'
                                                                     )
                                                                  || --
                                                                    dsp_planilha.campo (
                                                                                         'DT FISCAL'
                                                                                       , p_custom => 'BGCOLOR=#000086'
                                                                     )
                                                                  || --
                                                                    dsp_planilha.campo (
                                                                                         'NUM DOC FIS'
                                                                                       , p_custom => 'BGCOLOR=#000086'
                                                                     )
                                                                  || --
                                                                    dsp_planilha.campo (
                                                                                         'NCM'
                                                                                       , p_custom => 'BGCOLOR=#000086'
                                                                     )
                                                                  || --
                                                                    dsp_planilha.campo (
                                                                                         'CFOP'
                                                                                       , p_custom => 'BGCOLOR=#000086'
                                                                     )
                                                                  || --
                                                                    dsp_planilha.campo (
                                                                                         'CST'
                                                                                       , p_custom => 'BGCOLOR=#000086'
                                                                     )
                                                                  || --
                                                                    dsp_planilha.campo (
                                                                                         'FIN'
                                                                                       , p_custom => 'BGCOLOR=#000086'
                                                                     )
                                                                  || --
                                                                    dsp_planilha.campo (
                                                                                         'VLR CONTAB'
                                                                                       , p_custom => 'BGCOLOR=#000086'
                                                                     )
                                                                  || --
                                                                    dsp_planilha.campo (
                                                                                         'QTD ENTRADA'
                                                                                       , p_custom => 'BGCOLOR=#000086'
                                                                     )
                                                                  || --
                                                                    dsp_planilha.campo (
                                                                                         'UF'
                                                                                       , p_custom => 'BGCOLOR=#000086'
                                                                     )
                                                                  || --
                                                                    dsp_planilha.campo (
                                                                                         'BASE ICMS UNIT'
                                                                                       , p_custom => 'BGCOLOR=#000086'
                                                                     )
                                                                  || --
                                                                    dsp_planilha.campo (
                                                                                         'VLR ICMS UNIT'
                                                                                       , p_custom => 'BGCOLOR=#000086'
                                                                     )
                                                                  || --
                                                                    dsp_planilha.campo (
                                                                                         'ALIQ ICMS'
                                                                                       , p_custom => 'BGCOLOR=#000086'
                                                                     )
                                                                  || --
                                                                    dsp_planilha.campo (
                                                                                         'BASE ST UNIT'
                                                                                       , p_custom => 'BGCOLOR=#000086'
                                                                     )
                                                                  || --
                                                                    dsp_planilha.campo (
                                                                                         'ICMS ST UNIT'
                                                                                       , p_custom => 'BGCOLOR=#000086'
                                                                     )
                                                                  || --
                                                                    dsp_planilha.campo (
                                                                                         'ICMS ST UNIT AUXILIAR'
                                                                                       , p_custom => 'BGCOLOR=#000086'
                                                                     )
                                                                  || --
                                                                    dsp_planilha.campo (
                                                                                         'LIBER/CNTL'
                                                                                       , p_custom => 'BGCOLOR=#000086'
                                                                     )
                                                                  || --
                                                                    dsp_planilha.campo (
                                                                                         'ALIQ ST'
                                                                                       , p_custom => 'BGCOLOR=#000086'
                                                                     )
                                                                  || --
                                                                    dsp_planilha.campo (
                                                                                         'VALOR PMC'
                                                                                       , p_custom => 'BGCOLOR=#000086'
                                                                     )
                                                                  || --
                                                                    dsp_planilha.campo (
                                                                                         'ICMS AUXILIAR'
                                                                                       , p_custom => 'BGCOLOR=#000086'
                                                                     )
                                                                  || --
                                                                    dsp_planilha.campo (
                                                                                         'BASE UNITÁRIO S/ VENDA'
                                                                                       , p_custom => 'BGCOLOR=#000086'
                                                                     )
                                                                  || --
                                                                    dsp_planilha.campo (
                                                                                         'ICMS ST BRUTO'
                                                                                       , p_custom => 'BGCOLOR=#000086'
                                                                     )
                                                                  || --
                                                                    dsp_planilha.campo (
                                                                                         'ICMS ST S/ VENDA'
                                                                                       , p_custom => 'BGCOLOR=#000086'
                                                                     )
                                                                  || --
                                                                    dsp_planilha.campo (
                                                                                         'VALOR APURADO'
                                                                                       , p_custom => 'BGCOLOR=#000086'
                                                                     )
                                                                  || --
                                                                    dsp_planilha.campo (
                                                                                         'CRED / DEB'
                                                                                       , p_custom => 'BGCOLOR=#000086'
                                                                     )
                                                                  || --
                                                                    dsp_planilha.campo (
                                                                                         'CHAVE ACESSO ENTRADA'
                                                                                       , p_custom => 'BGCOLOR=#000086'
                                                                     )
                                                                  || --
                                                                    dsp_planilha.campo (
                                                                                         'VLR_ANTECIP_UNIT'
                                                                                       , p_custom => 'BGCOLOR=#008000'
                                                                     )
                                                                  || --
                                                                    dsp_planilha.campo (
                                                                                         'VLR_BASE_ICMS_XML_UNIT'
                                                                                       , p_custom => 'BGCOLOR=#008000'
                                                                     )
                                                                  || --
                                                                    dsp_planilha.campo (
                                                                                         'VLR_ICMS_XML_UNIT'
                                                                                       , p_custom => 'BGCOLOR=#008000'
                                                                     )
                                                                  || --
                                                                    dsp_planilha.campo (
                                                                                         'VLR_BASE_ICMS_ST_XML_UNIT'
                                                                                       , p_custom => 'BGCOLOR=#008000'
                                                                     )
                                                                  || --
                                                                    dsp_planilha.campo (
                                                                                         'VLR_ICMS_ST_XML_UNIT'
                                                                                       , p_custom => 'BGCOLOR=#008000'
                                                                     )
                                                                  || --
                                                                    dsp_planilha.campo (
                                                                                         'VLR_FCST_XML_UNIT'
                                                                                       , p_custom => 'BGCOLOR=#008000'
                                                                     )
                                                                  || --
                                                                    dsp_planilha.campo (
                                                                                         'VLR_FCRT_XML_UNIT'
                                                                                       , p_custom => 'BGCOLOR=#008000'
                                                                     )
                                                                  || --
                                                                    dsp_planilha.campo (
                                                                                         'VLR_FCP_XML_UNIT'
                                                                                       , p_custom => 'BGCOLOR=#008000'
                                                                     )
                                                                  || --
                                                                    dsp_planilha.campo (
                                                                                         'VLR_ICMS_ST_XML_UNIT_CALC'
                                                                                       , p_custom => 'BGCOLOR=#008000'
                                                                     )
                                                                  || --
                                                                    dsp_planilha.campo (
                                                                                         'VALOR APURADO XML'
                                                                                       , p_custom => 'BGCOLOR=#008000'
                                                                     )
                                                                  || --
                                                                    dsp_planilha.campo (
                                                                                         'CRED / DEB XML'
                                                                                       , p_custom => 'BGCOLOR=#008000'
                                                                     )
                                                                  || --
                                                                    ''
                                                  , p_class => 'h' )
                             , ptipo => i );

                FOR cr_r IN load_analitico ( a_estabs ( i )
                                           , v_data_inicial
                                           , v_data_final ) LOOP
                    IF ( p_analitico_filtro = '1' )
                    OR ( p_analitico_filtro = '2'
                    AND cr_r.vlr_dif_qtde > 0 )
                    OR ( p_analitico_filtro = '3'
                    AND cr_r.vlr_dif_qtde < 0 ) THEN
                        --(1)

                        IF v_class = 'a' THEN
                            v_class := 'b';
                        ELSE
                            v_class := 'a';
                        END IF;

                        v_text01 :=
                            dsp_planilha.linha (
                                                 p_conteudo =>    dsp_planilha.campo ( cr_r.cod_estab )
                                                               || --
                                                                 dsp_planilha.campo ( cr_r.cod_estado )
                                                               || --
                                                                 dsp_planilha.campo ( cr_r.docto )
                                                               || --
                                                                 dsp_planilha.campo ( cr_r.cod_produto )
                                                               || --
                                                                 dsp_planilha.campo ( cr_r.lista )
                                                               || --
                                                                 dsp_planilha.campo ( cr_r.descr_item )
                                                               || --
                                                                 dsp_planilha.campo ( cr_r.num_docfis )
                                                               || --
                                                                 dsp_planilha.campo ( cr_r.data_fiscal )
                                                               || --
                                                                 dsp_planilha.campo ( moeda ( cr_r.quantidade ) )
                                                               || --
                                                                 dsp_planilha.campo ( cr_r.cod_nbm )
                                                               || --
                                                                 dsp_planilha.campo ( cr_r.cod_cfo )
                                                               || --
                                                                 dsp_planilha.campo ( cr_r.grupo_produto )
                                                               || --
                                                                 dsp_planilha.campo ( moeda ( cr_r.vlr_desconto ) )
                                                               || --
                                                                 dsp_planilha.campo ( moeda ( cr_r.vlr_contabil ) )
                                                               || --
                                                                 dsp_planilha.campo (
                                                                                      dsp_planilha.texto (
                                                                                                           cr_r.num_autentic_nfe
                                                                                      )
                                                                  )
                                                               || --
                                                                  ---
                                                                  dsp_planilha.campo ( cr_r.cod_estab_e )
                                                               || --
                                                                 dsp_planilha.campo ( cr_r.data_fiscal_e )
                                                               || --
                                                                 dsp_planilha.campo ( cr_r.num_docfis_e )
                                                               || --
                                                                 dsp_planilha.campo ( cr_r.cod_nbm_e )
                                                               || --
                                                                 dsp_planilha.campo ( cr_r.cod_cfo_e )
                                                               || --
                                                                 dsp_planilha.campo ( cr_r.cod_situacao_b_e )
                                                               || --
                                                                 dsp_planilha.campo ( cr_r.cod_natureza_op_e )
                                                               || --
                                                                 dsp_planilha.campo (
                                                                                      moeda ( cr_r.vlr_contab_item_e )
                                                                  )
                                                               || --
                                                                 dsp_planilha.campo ( cr_r.quantidade_e )
                                                               || --
                                                                 dsp_planilha.campo ( cr_r.cod_estado_e )
                                                               || --
                                                                 dsp_planilha.campo (
                                                                                      moeda ( cr_r.base_icms_unit_e )
                                                                  )
                                                               || --
                                                                 dsp_planilha.campo ( moeda ( cr_r.vlr_icms_unit_e ) )
                                                               || --
                                                                 dsp_planilha.campo ( moeda ( cr_r.aliq_icms_e ) )
                                                               || --
                                                                 dsp_planilha.campo ( moeda ( cr_r.base_st_unit_e ) )
                                                               || --
                                                                 dsp_planilha.campo (
                                                                                      moeda (
                                                                                              cr_r.vlr_icms_st_unit_e
                                                                                      )
                                                                  )
                                                               || --
                                                                 dsp_planilha.campo (
                                                                                      moeda (
                                                                                              cr_r.vlr_icms_st_unit_aux
                                                                                      )
                                                                  )
                                                               || --
                                                                 dsp_planilha.campo ( cr_r.stat_liber_cntr )
                                                               || --
                                                                 dsp_planilha.campo ( cr_r.id_aliq_st )
                                                               || --
                                                                 dsp_planilha.campo ( moeda ( cr_r.vlr_pmc ) )
                                                               || --
                                                                 dsp_planilha.campo ( moeda ( cr_r.vlr_icms_aux ) )
                                                               || --
                                                                 dsp_planilha.campo (
                                                                                      moeda ( cr_r.base_unit_s_venda )
                                                                  )
                                                               || --
                                                                 dsp_planilha.campo ( moeda ( cr_r.vlr_icms_bruto ) )
                                                               || --
                                                                 dsp_planilha.campo (
                                                                                      moeda ( cr_r.vlr_icms_s_venda )
                                                                  )
                                                               || --
                                                                 dsp_planilha.campo ( moeda ( cr_r.vlr_dif_qtde ) )
                                                               || --
                                                                 dsp_planilha.campo ( cr_r.deb_cred )
                                                               || --
                                                                 dsp_planilha.campo (
                                                                                      dsp_planilha.texto (
                                                                                                           cr_r.num_autentic_nfe_e
                                                                                      )
                                                                  )
                                                               || --
                                                                  --
                                                                  dsp_planilha.campo (
                                                                                       moeda ( cr_r.vlr_antecip_unit )
                                                                  )
                                                               || --
                                                                 dsp_planilha.campo (
                                                                                      moeda (
                                                                                              cr_r.vlr_base_icms_xml_unit
                                                                                      )
                                                                  )
                                                               || --
                                                                 dsp_planilha.campo (
                                                                                      moeda ( cr_r.vlr_icms_xml_unit )
                                                                  )
                                                               || --
                                                                 dsp_planilha.campo (
                                                                                      moeda (
                                                                                              cr_r.vlr_base_icms_st_xml_unit
                                                                                      )
                                                                  )
                                                               || --
                                                                 dsp_planilha.campo (
                                                                                      moeda (
                                                                                              cr_r.vlr_icms_st_xml_unit
                                                                                      )
                                                                  )
                                                               || --
                                                                 dsp_planilha.campo (
                                                                                      moeda ( cr_r.vlr_fcst_xml_unit )
                                                                  )
                                                               || --
                                                                 dsp_planilha.campo (
                                                                                      moeda ( cr_r.vlr_fcrt_xml_unit )
                                                                  )
                                                               || --
                                                                 dsp_planilha.campo (
                                                                                      moeda ( cr_r.vlr_fcp_xml_unit )
                                                                  )
                                                               || --
                                                                 dsp_planilha.campo (
                                                                                      moeda (
                                                                                              cr_r.vlr_icms_st_xml_unit_calc
                                                                                      )
                                                                  )
                                                               || --
                                                                 dsp_planilha.campo (
                                                                                      moeda ( cr_r.vlr_dif_qtde_xml )
                                                                  )
                                                               || --
                                                                 dsp_planilha.campo ( cr_r.deb_cred_xml )
                                                               || --
                                                                 '' --
                                               , p_class => v_class
                            );
                        lib_proc.add ( v_text01
                                     , ptipo => i );
                    END IF; --(1)
                END LOOP; --FOR CR_R IN LOAD_ANALITICO(A_ESTABS(i), V_DATA_INICIAL, V_DATA_FINAL)

                lib_proc.add ( dsp_planilha.tabela_fim
                             , ptipo => i );
            END LOOP; --FOR i IN 1..A_ESTABS.COUNT
        ---MONTAR RELATORIO ANALITICO-FIM--------------------------------------------------------------------------------
        END IF; --IF (P_ANALITICO = 'S') THEN

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
END dpsp_rel_pmc_x_mva_cproc;
/
SHOW ERRORS;
