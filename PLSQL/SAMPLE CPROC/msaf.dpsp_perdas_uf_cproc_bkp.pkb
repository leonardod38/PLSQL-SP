Prompt Package Body DPSP_PERDAS_UF_CPROC_BKP;
--
-- DPSP_PERDAS_UF_CPROC_BKP  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_perdas_uf_cproc_bkp
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
                           , 'Período'
                           , --P_PERIODO
                            'DATE'
                           , 'TEXTBOX'
                           , 'S'
                           , ADD_MONTHS ( SYSDATE
                                        , -1 )
                           , 'MM/YYYY' );

        lib_proc.add_param ( pstr
                           , 'Origem Entrada CD1'
                           , --P_ORIGEM1
                            'VARCHAR2'
                           , 'RADIOBUTTON'
                           , 'N'
                           , NULL
                           , NULL
                           , '1=Filial (Transferência),2=CD (Compra)' );

        lib_proc.add_param (
                             pstr
                           , 'Checar Entradas CD1'
                           , --P_CD1
                            'VARCHAR2'
                           , 'COMBOBOX'
                           , 'N'
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
                              AND C.TIPO         = ''C''
                            ORDER BY A.COD_ESTAB DESC
                           '
        );

        lib_proc.add_param ( pstr
                           , 'Origem Entrada CD2'
                           , --P_ORIGEM2
                            'VARCHAR2'
                           , 'RADIOBUTTON'
                           , 'N'
                           , NULL
                           , NULL
                           , '1=Filial (Transferência),2=CD (Compra)' );

        lib_proc.add_param (
                             pstr
                           , 'Checar Entradas CD2'
                           , --P_CD2
                            'VARCHAR2'
                           , 'COMBOBOX'
                           , 'N'
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
                              AND C.TIPO         = ''C''
                            ORDER BY A.COD_ESTAB DESC
                           '
        );

        lib_proc.add_param ( pstr
                           , 'Origem Entrada CD3'
                           , --P_ORIGEM3
                            'VARCHAR2'
                           , 'RADIOBUTTON'
                           , 'N'
                           , NULL
                           , NULL
                           , '1=Filial (Transferência),2=CD (Compra)' );

        lib_proc.add_param (
                             pstr
                           , 'Checar Entradas CD3'
                           , --P_CD3
                            'VARCHAR2'
                           , 'COMBOBOX'
                           , 'N'
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
                              AND C.TIPO         = ''C''
                            ORDER BY A.COD_ESTAB DESC
                           '
        );

        lib_proc.add_param ( pstr
                           , 'Origem Entrada CD4'
                           , --P_ORIGEM4
                            'VARCHAR2'
                           , 'RADIOBUTTON'
                           , 'N'
                           , NULL
                           , NULL
                           , '1=Filial (Transferência),2=CD (Compra)' );

        lib_proc.add_param ( pstr
                           , 'Checar Entradas CD4'
                           , --P_CD4
                            'VARCHAR2'
                           , 'TEXTBOX'
                           , 'N'
                           , NULL
                           , '######' );

        lib_proc.add_param ( pstr
                           , 'Procurar por Compra Direta'
                           , --P_COMPRA_DIRETA
                            'VARCHAR2'
                           , 'CHECKBOX'
                           , 'N'
                           , 'N'
                           , NULL );

        lib_proc.add_param ( pstr
                           , 'Procurar por Transferências entre Filiais (Mesma UF)'
                           , --P_FILIAIS
                            'VARCHAR2'
                           , 'CHECKBOX'
                           , 'N'
                           , 'N'
                           , NULL );

        lib_proc.add_param ( pstr
                           , 'Atualizar Dados de Inventário das Lojas - origem ERP'
                           , --P_INVENTARIO
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
        RETURN 'Processar Dados de PERDAS - Outras UFs';
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
        RETURN 'Processar Carga de Dados para Relatorio de Perdas Outras UFs';
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
        COMMIT;
    END;

    FUNCTION moeda ( v_conteudo NUMBER )
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN TRIM ( TO_CHAR ( v_conteudo
                              , '9g999g999g990d00' ) );
    END;

    PROCEDURE get_psft_inv ( vp_cod_estab IN VARCHAR2
                           , vp_data_inicial IN VARCHAR2
                           , vp_data_final IN VARCHAR2
                           , vp_inventario IN VARCHAR2
                           , vp_proc_id IN VARCHAR2
                           , v_qtde_inv   OUT NUMBER )
    IS
        v_sql VARCHAR2 ( 3000 );
        v_bugl VARCHAR2 ( 6 );
    BEGIN
        SELECT bu_gl
          INTO v_bugl
          FROM msafi.dsp_interface_setup
         WHERE cod_empresa = msafi.dpsp.empresa;

        --CHECK DADOS DE INVENTARIO PARA A FILIAL
        BEGIN
            SELECT COUNT ( * )
              INTO v_qtde_inv
              FROM msafi.dpsp_msaf_perdas_inv
             WHERE cod_estab = vp_cod_estab
               AND data_inv BETWEEN TO_DATE ( vp_data_inicial
                                            , 'DD/MM/YYYY' )
                                AND TO_DATE ( vp_data_final
                                            , 'DD/MM/YYYY' );
        EXCEPTION
            WHEN OTHERS THEN
                v_qtde_inv := 0;
        END;

        IF ( v_qtde_inv > 0 ) THEN
            IF ( vp_inventario = 'S' ) THEN
                --SOBREPOR DADOS DE INVENTARIO
                --EXCLUIR EXISTENTES
                DELETE msafi.dpsp_msaf_perdas_inv
                 WHERE cod_estab = vp_cod_estab
                   AND data_inv BETWEEN TO_DATE ( vp_data_inicial
                                                , 'DD/MM/YYYY' )
                                    AND TO_DATE ( vp_data_final
                                                , 'DD/MM/YYYY' );

                loga ( '[DEL INV]:' || SQL%ROWCOUNT
                     , FALSE );
                COMMIT;

                v_sql := 'INSERT /*+APPEND*/ INTO MSAFI.DPSP_MSAF_PERDAS_INV ';
                v_sql :=
                       v_sql
                    || ' SELECT /*+DRIVING_SITE(PSFT)*/ '
                    || SUBSTR ( vp_proc_id
                              , 1
                              , 10 )
                    || ', REPLACE(REPLACE(PSFT.LOJA,''VD'',''DSP''),''L'',''DP''), ';
                v_sql := v_sql || ' PSFT.ITEM, PSFT.DATA_INV, PSFT.SALDO, 0, PSFT.AJUSTE, PSFT.CUSTO ';
                v_sql := v_sql || ' FROM ( ';
                v_sql := v_sql || ' SELECT A.BUSINESS_UNIT AS LOJA, ';
                v_sql := v_sql || '        A.INV_ITEM_ID AS ITEM, ';
                v_sql := v_sql || '        TO_CHAR(A.DSP_DT_REFER,''DD/MM/YYYY'') AS DATA_INV, ';
                v_sql := v_sql || '        SUM(A.DSP_QTD_SLD_LOG) AS SALDO, ';
                v_sql := v_sql || '        SUM(A.DSP_DIF_QTD_NUM) AS AJUSTE, ';
                v_sql := v_sql || '        MAX(A.PRICE_VNDR) AS CUSTO ';
                v_sql := v_sql || '   FROM MSAFI.PS_DSP_CONTBAL_HST A, ';
                v_sql := v_sql || '        MSAFI.PS_BUS_UNIT_TBL_IN B ';
                v_sql :=
                    v_sql || '   WHERE DSP_DT_REFER      >= TO_DATE(''' || vp_data_inicial || ''',''DD/MM/YYYY'') ';
                v_sql := v_sql || '     AND DSP_DT_REFER      <= TO_DATE(''' || vp_data_final || ''',''DD/MM/YYYY'') ';
                v_sql := v_sql || '     AND A.BUSINESS_UNIT = B.BUSINESS_UNIT ';
                v_sql := v_sql || '     AND B.BUSINESS_UNIT_GL = ''' || v_bugl || ''' ';
                v_sql :=
                       v_sql
                    || '     AND LTRIM(REGEXP_REPLACE(A.BUSINESS_UNIT,''V|D|L'',''''),''0'') = LTRIM(REGEXP_REPLACE('''
                    || vp_cod_estab
                    || ''',''D|S|P'',''''),''0'') ';
                v_sql := v_sql || '   GROUP BY A.BUSINESS_UNIT  , ';
                v_sql := v_sql || '            A.INV_ITEM_ID  , ';
                v_sql := v_sql || '            TO_CHAR(A.DSP_DT_REFER,''DD/MM/YYYY'')) PSFT ';

                BEGIN
                    EXECUTE IMMEDIATE v_sql;

                    v_qtde_inv := SQL%ROWCOUNT;
                    loga ( '[SOBR INV]:' || v_qtde_inv
                         , FALSE );
                EXCEPTION
                    WHEN OTHERS THEN
                        v_qtde_inv := 0;
                END;

                COMMIT;
            END IF;
        ELSE
            --OBTER DADOS DE INVENTARIO DO ERP
            v_sql := 'INSERT /*+APPEND*/ INTO MSAFI.DPSP_MSAF_PERDAS_INV ';
            v_sql :=
                   v_sql
                || ' SELECT /*+DRIVING_SITE(PSFT)*/ '
                || SUBSTR ( vp_proc_id
                          , 1
                          , 10 )
                || ', REPLACE(REPLACE(PSFT.LOJA,''VD'',''DSP''),''L'',''DP''), ';
            v_sql := v_sql || ' PSFT.ITEM, PSFT.DATA_INV, PSFT.SALDO, 0, PSFT.AJUSTE, PSFT.CUSTO ';
            v_sql := v_sql || ' FROM ( ';
            v_sql := v_sql || ' SELECT A.BUSINESS_UNIT AS LOJA, ';
            v_sql := v_sql || '        A.INV_ITEM_ID AS ITEM, ';
            v_sql := v_sql || '        TO_CHAR(A.DSP_DT_REFER,''DD/MM/YYYY'') AS DATA_INV, ';
            v_sql := v_sql || '        SUM(A.DSP_QTD_SLD_LOG) AS SALDO, ';
            v_sql := v_sql || '        SUM(A.DSP_DIF_QTD_NUM) AS AJUSTE, ';
            v_sql := v_sql || '        MAX(A.PRICE_VNDR) AS CUSTO ';
            v_sql := v_sql || '   FROM MSAFI.PS_DSP_CONTBAL_HST A, ';
            v_sql := v_sql || '        MSAFI.PS_BUS_UNIT_TBL_IN B ';
            v_sql := v_sql || '   WHERE DSP_DT_REFER      >= TO_DATE(''' || vp_data_inicial || ''',''DD/MM/YYYY'') ';
            v_sql := v_sql || '     AND DSP_DT_REFER      <= TO_DATE(''' || vp_data_final || ''',''DD/MM/YYYY'') ';
            v_sql := v_sql || '     AND A.BUSINESS_UNIT = B.BUSINESS_UNIT ';
            v_sql := v_sql || '     AND B.BUSINESS_UNIT_GL = ''' || v_bugl || ''' ';
            v_sql :=
                   v_sql
                || '     AND LTRIM(REGEXP_REPLACE(A.BUSINESS_UNIT,''V|D|L'',''''),''0'') = LTRIM(REGEXP_REPLACE('''
                || vp_cod_estab
                || ''',''D|S|P'',''''),''0'') ';
            v_sql := v_sql || '   GROUP BY A.BUSINESS_UNIT  , ';
            v_sql := v_sql || '            A.INV_ITEM_ID  , ';
            v_sql := v_sql || '            TO_CHAR(A.DSP_DT_REFER,''DD/MM/YYYY'')) PSFT ';

            BEGIN
                EXECUTE IMMEDIATE v_sql;

                v_qtde_inv := SQL%ROWCOUNT;
                loga ( '[INS INV]:' || v_qtde_inv
                     , FALSE );
            EXCEPTION
                WHEN OTHERS THEN
                    v_qtde_inv := 0;
            END;

            COMMIT;
        END IF;
    END;

    PROCEDURE save_tmp_control ( vp_proc_instance IN NUMBER
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
        INSERT /*+APPEND*/
              INTO  msafi.dpsp_msaf_tmp_control
             VALUES ( vp_proc_instance
                    , vp_table_name
                    , SYSDATE
                    , musuario
                    , v_sid );

        COMMIT;
    END;

    PROCEDURE del_tmp_control ( vp_proc_instance IN NUMBER
                              , vp_table_name IN VARCHAR2 )
    IS
    BEGIN
        DELETE msafi.dpsp_msaf_tmp_control
         WHERE proc_id = vp_proc_instance
           AND table_name = vp_table_name;

        COMMIT;
    END;

    PROCEDURE create_perdas_inv_tmp ( vp_proc_instance IN VARCHAR2
                                    , vp_tab_perdas_inv   OUT VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 1000 );
    BEGIN
        vp_tab_perdas_inv := 'DPSP_P_INV_' || vp_proc_instance;

        v_sql := 'CREATE TABLE ' || vp_tab_perdas_inv || ' ';
        v_sql := v_sql || '( ';
        v_sql := v_sql || '  PROC_ID     NUMBER(30), ';
        v_sql := v_sql || '  COD_ESTAB   VARCHAR2(6), ';
        v_sql := v_sql || '  COD_PRODUTO VARCHAR2(25), ';
        v_sql := v_sql || '  DATA_INV    DATE, ';
        v_sql := v_sql || '  QTD_AJUSTE  NUMBER(15,2) ';
        v_sql := v_sql || ') ';
        v_sql := v_sql || 'PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        ---
        save_tmp_control ( vp_proc_instance
                         , vp_tab_perdas_inv );
    END;

    PROCEDURE load_inv_dados ( vp_proc_instance IN VARCHAR2
                             , vp_cod_estab IN VARCHAR2
                             , vp_data_ini IN DATE
                             , vp_data_fim IN DATE
                             , vp_tab_perdas_inv IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 4000 );
    BEGIN
        v_sql := 'INSERT /*+APPEND*/ INTO ' || vp_tab_perdas_inv || ' ';
        v_sql :=
            v_sql || ' (SELECT ' || vp_proc_instance || ', COD_ESTAB, COD_PRODUTO, MAX(DATA_INV), SUM(QTD_AJUSTE) ';
        v_sql := v_sql || '  FROM MSAFI.DPSP_MSAF_PERDAS_INV ';
        v_sql := v_sql || '  WHERE COD_ESTAB = ''' || vp_cod_estab || ''' ';
        v_sql :=
               v_sql
            || '    AND DATA_INV BETWEEN TO_DATE('''
            || TO_CHAR ( vp_data_ini
                       , 'DDMMYYYY' )
            || ''',''DDMMYYYY'') AND TO_DATE('''
            || TO_CHAR ( vp_data_fim
                       , 'DDMMYYYY' )
            || ''',''DDMMYYYY'') ';
        v_sql := v_sql || '  GROUP BY COD_ESTAB, COD_PRODUTO ';
        v_sql := v_sql || '  HAVING SUM(QTD_AJUSTE) < 0 ) ';

        BEGIN
            EXECUTE IMMEDIATE v_sql;

            COMMIT;
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
                ---
                raise_application_error ( -20003
                                        , '!ERRO LOAD_INV_DADOS!' );
        END;
    END;

    PROCEDURE create_perdas_inv_tmp_idx ( vp_proc_instance IN VARCHAR2
                                        , vp_tab_perdas_inv IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 2000 );
        v_qtde NUMBER;
    BEGIN
        v_sql := 'CREATE UNIQUE INDEX PK_PINV_' || vp_proc_instance || ' ON ' || vp_tab_perdas_inv || ' ';
        v_sql := v_sql || '( ';
        v_sql := v_sql || ' PROC_ID    ASC, ';
        v_sql := v_sql || ' COD_ESTAB   ASC, ';
        v_sql := v_sql || ' COD_PRODUTO  ASC ';
        v_sql := v_sql || ') ';
        v_sql := v_sql || '  PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX1_PINV_' || vp_proc_instance || ' ON ' || vp_tab_perdas_inv || ' ';
        v_sql := v_sql || '( ';
        v_sql := v_sql || ' PROC_ID    ASC, ';
        v_sql := v_sql || ' COD_ESTAB   ASC, ';
        v_sql := v_sql || ' COD_PRODUTO  ASC, ';
        v_sql := v_sql || ' DATA_INV ASC ';
        v_sql := v_sql || ') ';
        v_sql := v_sql || '  PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_tab_perdas_inv );

        EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || vp_tab_perdas_inv            INTO v_qtde;

        loga ( '[' || vp_tab_perdas_inv || ']:' || v_qtde
             , FALSE );
    END;

    PROCEDURE create_tab_entrada ( vp_proc_instance IN NUMBER
                                 , vp_tab_entrada_c   OUT VARCHAR2
                                 , vp_tab_perdas_ent_f   OUT VARCHAR2
                                 , vp_tab_perdas_ent_d   OUT VARCHAR2
                                 , vp_tab_perdas_ent_m   OUT VARCHAR2 )
    IS
        v_sql1 VARCHAR2 ( 300 );
        v_sql VARCHAR2 ( 4000 );
    BEGIN
        v_sql := ' PROC_ID               NUMBER(30), ';
        v_sql := v_sql || ' COD_EMPRESA_E         VARCHAR2(6 BYTE), ';
        v_sql := v_sql || ' COD_ESTAB_E           VARCHAR2(6 BYTE), ';
        v_sql := v_sql || ' DATA_FISCAL_E         DATE, ';
        v_sql := v_sql || ' DATA_INV_S            DATE, ';
        v_sql := v_sql || ' MOVTO_E_S_E           VARCHAR2(1 BYTE), ';
        v_sql := v_sql || ' NORM_DEV_E            VARCHAR2(1 BYTE), ';
        v_sql := v_sql || ' IDENT_DOCTO_E         VARCHAR2(12 BYTE), ';
        v_sql := v_sql || ' IDENT_FIS_JUR_E       VARCHAR2(12 BYTE), ';
        v_sql := v_sql || ' SERIE_DOCFIS_E        VARCHAR2(3 BYTE), ';
        v_sql := v_sql || ' SUB_SERIE_DOCFIS_E    VARCHAR2(2 BYTE), ';
        v_sql := v_sql || ' DISCRI_ITEM_E         VARCHAR2(46 BYTE), ';
        v_sql := v_sql || ' NUM_ITEM_E            NUMBER(5), ';
        v_sql := v_sql || ' DATA_EMISSAO_E        DATE, ';
        v_sql := v_sql || ' NUM_DOCFIS_E          VARCHAR2(12 BYTE), ';
        v_sql := v_sql || ' COD_FIS_JUR_E         VARCHAR2(14 BYTE), ';
        v_sql := v_sql || ' CPF_CGC_E             VARCHAR2(14 BYTE), ';
        v_sql := v_sql || ' RAZAO_SOCIAL_E        VARCHAR2(100), ';
        v_sql := v_sql || ' COD_NBM_E             VARCHAR2(10 BYTE), ';
        v_sql := v_sql || ' COD_CFO_E             VARCHAR2(4 BYTE), ';
        v_sql := v_sql || ' COD_NATUREZA_OP_E     VARCHAR2(3 BYTE), ';
        v_sql := v_sql || ' COD_PRODUTO_E         VARCHAR2(35 BYTE), ';
        v_sql := v_sql || ' DESCRICAO             VARCHAR2(50), ';
        v_sql := v_sql || ' VLR_CONTAB_ITEM_E     NUMBER(15,4), ';
        v_sql := v_sql || ' QUANTIDADE_E          NUMBER(15,4), ';
        v_sql := v_sql || ' VLR_UNIT_E            NUMBER(15,4), ';
        v_sql := v_sql || ' COD_SITUACAO_A_E      VARCHAR2(2 BYTE), ';
        v_sql := v_sql || ' COD_SITUACAO_B_E      VARCHAR2(2 BYTE), ';
        v_sql := v_sql || ' COD_ESTADO_E          VARCHAR2(2 BYTE), ';
        v_sql := v_sql || ' NUM_CONTROLE_DOCTO_E  VARCHAR2(12 BYTE), ';
        v_sql := v_sql || ' NUM_AUTENTIC_NFE_E    VARCHAR2(80 BYTE), ';
        v_sql := v_sql || ' BASE_ICMS_UNIT_E      NUMBER(15,4), ';
        v_sql := v_sql || ' VLR_ICMS_UNIT_E       NUMBER(15,4), ';
        v_sql := v_sql || ' ALIQ_ICMS_E           NUMBER(15,4), ';
        v_sql := v_sql || ' BASE_ST_UNIT_E        NUMBER(15,4), ';
        v_sql := v_sql || ' VLR_ICMS_ST_UNIT_E    NUMBER(15,4), ';
        v_sql := v_sql || ' STAT_LIBER_CNTR       VARCHAR2(10 BYTE), ';
        v_sql := v_sql || ' ID_ALIQ_ST            VARCHAR2(10 BYTE), ';
        v_sql := v_sql || ' VLR_PMC               NUMBER(15,4), ';
        v_sql := v_sql || ' TOTAL_ICMS            NUMBER(15,4), ';
        v_sql := v_sql || ' TOTAL_ICMS_ST         NUMBER(15,4), ';
        v_sql := v_sql || ' LISTA_PRODUTO         VARCHAR2(10), ';
        v_sql := v_sql || ' CST_PIS               VARCHAR2(2), ';
        v_sql := v_sql || ' CST_COFINS            VARCHAR2(2), ';
        v_sql := v_sql || ' ESTORNO_PIS_E         NUMBER(12,4), ';
        v_sql := v_sql || ' ESTORNO_COFINS_E      NUMBER(12,4), ';
        v_sql := v_sql || ' ESTORNO_PIS_S         NUMBER(12,4), ';
        v_sql := v_sql || ' ESTORNO_COFINS_S      NUMBER(12,4) ) ';
        v_sql := v_sql || ' PCTFREE     10 ';

        ---CRIAR TEMP DE ENTRADA
        vp_tab_entrada_c := 'DPSP_ENT_CD_' || vp_proc_instance;
        vp_tab_perdas_ent_f := 'DPSP_ENT_FI_' || vp_proc_instance;
        vp_tab_perdas_ent_d := 'DPSP_ENT_CO_' || vp_proc_instance;
        vp_tab_perdas_ent_m := 'DPSP_ENT_MU_' || vp_proc_instance;

        v_sql1 := 'CREATE TABLE ' || vp_tab_entrada_c || ' ( ';

        EXECUTE IMMEDIATE v_sql1 || v_sql;

        save_tmp_control ( vp_proc_instance
                         , vp_tab_entrada_c );

        v_sql1 := 'CREATE TABLE ' || vp_tab_perdas_ent_f || ' ( ';

        EXECUTE IMMEDIATE v_sql1 || v_sql;

        save_tmp_control ( vp_proc_instance
                         , vp_tab_perdas_ent_f );

        v_sql1 := 'CREATE TABLE ' || vp_tab_perdas_ent_d || ' ( ';

        EXECUTE IMMEDIATE v_sql1 || v_sql;

        save_tmp_control ( vp_proc_instance
                         , vp_tab_perdas_ent_d );

        v_sql1 := 'CREATE TABLE ' || vp_tab_perdas_ent_m || ' ( ';

        EXECUTE IMMEDIATE v_sql1 || v_sql;

        save_tmp_control ( vp_proc_instance
                         , vp_tab_perdas_ent_m );
    END;

    PROCEDURE create_tab_entrada_cd_idx ( vp_proc_instance IN NUMBER
                                        , vp_tab_entrada_cd IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 2000 );
    BEGIN
        v_sql := 'CREATE UNIQUE INDEX PK_P_E_C_' || vp_proc_instance || ' ON ' || vp_tab_entrada_cd || ' ';
        v_sql := v_sql || '( ';
        v_sql := v_sql || ' PROC_ID            ASC, ';
        v_sql := v_sql || ' COD_EMPRESA_E      ASC, ';
        v_sql := v_sql || ' COD_ESTAB_E        ASC, ';
        v_sql := v_sql || ' DATA_FISCAL_E      ASC, ';
        v_sql := v_sql || ' DATA_INV_S         ASC, ';
        v_sql := v_sql || ' NUM_DOCFIS_E       ASC, ';
        v_sql := v_sql || ' MOVTO_E_S_E        ASC, ';
        v_sql := v_sql || ' NORM_DEV_E         ASC, ';
        v_sql := v_sql || ' IDENT_DOCTO_E      ASC, ';
        v_sql := v_sql || ' IDENT_FIS_JUR_E    ASC, ';
        v_sql := v_sql || ' SERIE_DOCFIS_E     ASC, ';
        v_sql := v_sql || ' SUB_SERIE_DOCFIS_E ASC, ';
        v_sql := v_sql || ' DISCRI_ITEM_E      ASC, ';
        v_sql := v_sql || ' NUM_ITEM_E         ASC ';
        v_sql := v_sql || ') ';
        v_sql := v_sql || ' PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX1_P_E_C_' || vp_proc_instance || ' ON ' || vp_tab_entrada_cd || ' ';
        v_sql := v_sql || '( ';
        v_sql := v_sql || ' COD_PRODUTO_E ASC, ';
        v_sql := v_sql || ' DATA_FISCAL_E ASC ';
        v_sql := v_sql || ' ) PCTFREE 10 ';

        EXECUTE IMMEDIATE v_sql;

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_tab_entrada_cd );
        loga ( '[' || vp_tab_entrada_cd || '][LOAD END]'
             , FALSE );
    END;

    PROCEDURE create_tab_ent_filial_idx ( vp_proc_instance IN NUMBER
                                        , vp_tab_entrada_f IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 1000 );
    BEGIN
        v_sql := 'CREATE UNIQUE INDEX PK_P_E_F_' || vp_proc_instance || ' ON ' || vp_tab_entrada_f || ' ';
        v_sql := v_sql || '( ';
        v_sql := v_sql || ' PROC_ID            ASC, ';
        v_sql := v_sql || ' COD_EMPRESA_E      ASC, ';
        v_sql := v_sql || ' COD_ESTAB_E        ASC, ';
        v_sql := v_sql || ' DATA_FISCAL_E      ASC, ';
        v_sql := v_sql || ' DATA_INV_S         ASC, ';
        v_sql := v_sql || ' NUM_DOCFIS_E       ASC, ';
        v_sql := v_sql || ' MOVTO_E_S_E        ASC, ';
        v_sql := v_sql || ' NORM_DEV_E         ASC, ';
        v_sql := v_sql || ' IDENT_DOCTO_E      ASC, ';
        v_sql := v_sql || ' IDENT_FIS_JUR_E    ASC, ';
        v_sql := v_sql || ' SERIE_DOCFIS_E     ASC, ';
        v_sql := v_sql || ' SUB_SERIE_DOCFIS_E ASC, ';
        v_sql := v_sql || ' DISCRI_ITEM_E      ASC, ';
        v_sql := v_sql || ' NUM_ITEM_E         ASC ';
        v_sql := v_sql || ') ';
        v_sql := v_sql || ' PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX1_P_E_F_' || vp_proc_instance || ' ON ' || vp_tab_entrada_f || ' ';
        v_sql := v_sql || '( ';
        v_sql := v_sql || ' COD_PRODUTO_E ASC, ';
        v_sql := v_sql || ' DATA_FISCAL_E ASC ';
        v_sql := v_sql || ' ) PCTFREE 10 ';

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX2_P_E_F_' || vp_proc_instance || ' ON ' || vp_tab_entrada_f || ' ';
        v_sql := v_sql || '( ';
        v_sql := v_sql || ' NUM_AUTENTIC_NFE_E ASC ';
        v_sql := v_sql || ' ) PCTFREE 10 ';

        EXECUTE IMMEDIATE v_sql;

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_tab_entrada_f );
        loga ( '[' || vp_tab_entrada_f || '][LOAD END]'
             , FALSE );
    END;

    PROCEDURE create_tab_ent_cdireta_idx ( vp_proc_instance IN NUMBER
                                         , vp_tab_entrada_d IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 1000 );
    BEGIN
        v_sql := 'CREATE UNIQUE INDEX PK_P_E_D_' || vp_proc_instance || ' ON ' || vp_tab_entrada_d || ' ';
        v_sql := v_sql || '( ';
        v_sql := v_sql || ' PROC_ID            ASC, ';
        v_sql := v_sql || ' COD_EMPRESA_E      ASC, ';
        v_sql := v_sql || ' COD_ESTAB_E        ASC, ';
        v_sql := v_sql || ' DATA_FISCAL_E      ASC, ';
        v_sql := v_sql || ' DATA_INV_S         ASC, ';
        v_sql := v_sql || ' NUM_DOCFIS_E       ASC, ';
        v_sql := v_sql || ' MOVTO_E_S_E        ASC, ';
        v_sql := v_sql || ' NORM_DEV_E         ASC, ';
        v_sql := v_sql || ' IDENT_DOCTO_E      ASC, ';
        v_sql := v_sql || ' IDENT_FIS_JUR_E    ASC, ';
        v_sql := v_sql || ' SERIE_DOCFIS_E     ASC, ';
        v_sql := v_sql || ' SUB_SERIE_DOCFIS_E ASC, ';
        v_sql := v_sql || ' DISCRI_ITEM_E      ASC, ';
        v_sql := v_sql || ' NUM_ITEM_E         ASC ';
        v_sql := v_sql || ') ';
        v_sql := v_sql || ' PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX1_P_E_D_' || vp_proc_instance || ' ON ' || vp_tab_entrada_d || ' ';
        v_sql := v_sql || '( ';
        v_sql := v_sql || ' COD_PRODUTO_E ASC, ';
        v_sql := v_sql || ' DATA_FISCAL_E ASC ';
        v_sql := v_sql || ' ) PCTFREE 10 ';

        EXECUTE IMMEDIATE v_sql;

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_tab_entrada_d );
        loga ( '[' || vp_tab_entrada_d || '][LOAD END]'
             , FALSE );
    END;

    PROCEDURE create_tab_ent_mesma_uf_idx ( vp_proc_instance IN NUMBER
                                          , vp_tab_entrada_m IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 1000 );
    BEGIN
        v_sql := 'CREATE UNIQUE INDEX PK_P_E_M_' || vp_proc_instance || ' ON ' || vp_tab_entrada_m || ' ';
        v_sql := v_sql || '( ';
        v_sql := v_sql || ' PROC_ID            ASC, ';
        v_sql := v_sql || ' COD_EMPRESA_E      ASC, ';
        v_sql := v_sql || ' COD_ESTAB_E        ASC, ';
        v_sql := v_sql || ' DATA_FISCAL_E      ASC, ';
        v_sql := v_sql || ' DATA_INV_S         ASC, ';
        v_sql := v_sql || ' NUM_DOCFIS_E       ASC, ';
        v_sql := v_sql || ' MOVTO_E_S_E        ASC, ';
        v_sql := v_sql || ' NORM_DEV_E         ASC, ';
        v_sql := v_sql || ' IDENT_DOCTO_E      ASC, ';
        v_sql := v_sql || ' IDENT_FIS_JUR_E    ASC, ';
        v_sql := v_sql || ' SERIE_DOCFIS_E     ASC, ';
        v_sql := v_sql || ' SUB_SERIE_DOCFIS_E ASC, ';
        v_sql := v_sql || ' DISCRI_ITEM_E      ASC, ';
        v_sql := v_sql || ' NUM_ITEM_E         ASC ';
        v_sql := v_sql || ') ';
        v_sql := v_sql || ' PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX1_P_E_M_' || vp_proc_instance || ' ON ' || vp_tab_entrada_m || ' ';
        v_sql := v_sql || '( ';
        v_sql := v_sql || ' COD_PRODUTO_E ASC, ';
        v_sql := v_sql || ' DATA_FISCAL_E ASC ';
        v_sql := v_sql || ' ) PCTFREE 10 ';

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX2_P_E_M_' || vp_proc_instance || ' ON ' || vp_tab_entrada_m || ' ';
        v_sql := v_sql || '( ';
        v_sql := v_sql || ' PROC_ID ASC, ';
        v_sql := v_sql || ' COD_ESTAB_E ASC, ';
        v_sql := v_sql || ' COD_PRODUTO_E ASC, ';
        v_sql := v_sql || ' DATA_INV_S ASC ';
        v_sql := v_sql || ' ) PCTFREE 10 ';

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX3_P_E_M_' || vp_proc_instance || ' ON ' || vp_tab_entrada_m || ' ';
        v_sql := v_sql || '( ';
        v_sql := v_sql || ' COD_ESTAB_E ASC, ';
        v_sql := v_sql || ' COD_PRODUTO_E ASC, ';
        v_sql := v_sql || ' DATA_INV_S ASC ';
        v_sql := v_sql || ' ) PCTFREE 10 ';

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX4_P_E_M_' || vp_proc_instance || ' ON ' || vp_tab_entrada_m || ' ';
        v_sql := v_sql || '( ';
        v_sql := v_sql || ' NUM_AUTENTIC_NFE_E ASC ';
        v_sql := v_sql || ' ) PCTFREE 10 ';

        EXECUTE IMMEDIATE v_sql;

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_tab_entrada_m );
        loga ( '[' || vp_tab_entrada_m || '][LOAD END]'
             , FALSE );
    END;

    PROCEDURE load_entradas ( vp_proc_instance IN VARCHAR2
                            , vp_cod_estab IN VARCHAR2
                            , vp_dt_inicial IN DATE
                            , vp_dt_final IN DATE
                            , vp_origem IN VARCHAR2
                            , vp_tabela_entrada IN VARCHAR2
                            , vp_tab_perdas_inv IN VARCHAR2
                            , vp_cd IN VARCHAR2
                            , vp_tab_perdas_ent_f IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 8000 );
        v_task VARCHAR2 ( 30 );
        v_try NUMBER;
        v_status NUMBER;
        v_size INTEGER;
        v_qtde NUMBER;
        ---
        c_part SYS_REFCURSOR;

        TYPE cur_tab_part IS RECORD
        (
            x07_partition_name VARCHAR2 ( 100 )
          , x08_partition_name VARCHAR2 ( 100 )
          , inicio_particao DATE
          , final_particao DATE
        );

        TYPE c_tab_part IS TABLE OF cur_tab_part;

        tab_part c_tab_part;
        v_limit INTEGER;
        v_tab_aux VARCHAR2 ( 30 );
        v_partition_x08 VARCHAR2 ( 100 );
    BEGIN
        IF ( vp_origem = 'C' ) THEN --CD
            --TAB AUXILIAR
            v_tab_aux := 'T$_' || vp_cod_estab || vp_proc_instance;
            v_sql := 'CREATE TABLE ' || v_tab_aux || ' AS ';
            v_sql := v_sql || ' SELECT DISTINCT COD_PRODUTO, DATA_INV FROM ' || vp_tab_perdas_inv;

            EXECUTE IMMEDIATE v_sql;

            save_tmp_control ( vp_proc_instance
                             , v_tab_aux );
            v_sql := 'CREATE UNIQUE INDEX PK_' || vp_cod_estab || vp_proc_instance || ' ON ' || v_tab_aux;
            v_sql := v_sql || ' ( ';
            v_sql := v_sql || ' COD_PRODUTO   ASC, ';
            v_sql := v_sql || ' DATA_INV      ASC  ';
            v_sql := v_sql || ' ) PCTFREE 10 NOLOGGING ';

            EXECUTE IMMEDIATE v_sql;

            dbms_stats.gather_table_stats ( 'MSAF'
                                          , v_tab_aux );
            --

            v_sql := 'INSERT /*+APPEND*/ INTO ' || vp_tabela_entrada || ' ( ';
            v_sql := v_sql || 'SELECT DISTINCT ';
            v_sql := v_sql || '    ' || vp_proc_instance || ', ';
            v_sql := v_sql || '    A.COD_EMPRESA, ';
            v_sql := v_sql || '    A.COD_ESTAB, ';
            v_sql := v_sql || '    A.DATA_FISCAL, ';
            v_sql := v_sql || '    A.DATA_INV, ';
            v_sql := v_sql || '    A.MOVTO_E_S, ';
            v_sql := v_sql || '    A.NORM_DEV, ';
            v_sql := v_sql || '    A.IDENT_DOCTO, ';
            v_sql := v_sql || '    A.IDENT_FIS_JUR, ';
            v_sql := v_sql || '    A.SERIE_DOCFIS, ';
            v_sql := v_sql || '    A.SUB_SERIE_DOCFIS, ';
            v_sql := v_sql || '    A.DISCRI_ITEM, ';
            v_sql := v_sql || '    A.NUM_ITEM, ';
            v_sql := v_sql || '    A.DATA_EMISSAO, ';
            v_sql := v_sql || '    A.NUM_DOCFIS, ';
            v_sql := v_sql || '    A.COD_FIS_JUR, ';
            v_sql := v_sql || '    A.CPF_CGC, ';
            v_sql := v_sql || '    A.RAZAO_SOCIAL, ';
            v_sql := v_sql || '    A.COD_NBM, ';
            v_sql := v_sql || '    A.COD_CFO, ';
            v_sql := v_sql || '    A.COD_NATUREZA_OP, ';
            v_sql := v_sql || '    A.COD_PRODUTO, ';
            v_sql := v_sql || '    A.DESCRICAO, ';
            v_sql := v_sql || '    A.VLR_CONTAB_ITEM, ';
            v_sql := v_sql || '    A.QUANTIDADE, ';
            v_sql := v_sql || '    A.VLR_UNIT, ';
            v_sql := v_sql || '    A.COD_SITUACAO_A, ';
            v_sql := v_sql || '    A.COD_SITUACAO_B, ';
            v_sql := v_sql || '    A.COD_ESTADO, ';
            v_sql := v_sql || '    A.NUM_CONTROLE_DOCTO, ';
            v_sql := v_sql || '    A.NUM_AUTENTIC_NFE, ';
            v_sql := v_sql || '    A.BASE_ICMS_UNIT_E, ';
            v_sql := v_sql || '    A.VLR_ICMS_UNIT_E, ';
            v_sql := v_sql || '    A.ALIQ_ICMS_E, ';
            v_sql := v_sql || '    A.BASE_ST_UNIT_E, ';
            v_sql := v_sql || '    A.VLR_ICMS_ST_UNIT_E, ';
            v_sql := v_sql || '    A.STAT_LIBER_CNTR, ';
            v_sql := v_sql || '    A.ID_ALIQ_ST, ';
            v_sql := v_sql || '    A.VLR_PMC, ';
            v_sql := v_sql || '    A.TOTAL_ICMS, ';
            v_sql := v_sql || '    A.TOTAL_ICMS_ST, ';
            v_sql := v_sql || '    A.LISTA_PRODUTO, ';
            v_sql := v_sql || '    A.CST_PIS, ';
            v_sql := v_sql || '    A.CST_COFINS, ';
            v_sql := v_sql || '    A.ESTORNO_PIS_E, ';
            v_sql := v_sql || '    A.ESTORNO_COFINS_E, ';
            v_sql := v_sql || '    A.ESTORNO_PIS_S, ';
            v_sql := v_sql || '    A.ESTORNO_COFINS_S ';
            v_sql := v_sql || 'FROM ( ';
            v_sql := v_sql || '      SELECT /*+PARALLEL(4)*/ ';
            v_sql := v_sql || '        X08.COD_EMPRESA, ';
            v_sql := v_sql || '        X08.COD_ESTAB, ';
            v_sql := v_sql || '        X08.DATA_FISCAL, ';
            v_sql := v_sql || '        P.DATA_INV, ';
            v_sql := v_sql || '        X08.MOVTO_E_S, ';
            v_sql := v_sql || '        X08.NORM_DEV, ';
            v_sql := v_sql || '        X08.IDENT_DOCTO, ';
            v_sql := v_sql || '        X08.IDENT_FIS_JUR, ';
            v_sql := v_sql || '        X08.NUM_DOCFIS, ';
            v_sql := v_sql || '        X08.SERIE_DOCFIS, ';
            v_sql := v_sql || '        X08.SUB_SERIE_DOCFIS, ';
            v_sql := v_sql || '        X08.DISCRI_ITEM, ';
            v_sql := v_sql || '        X08.NUM_ITEM, ';
            v_sql := v_sql || '        G.COD_FIS_JUR, ';
            v_sql := v_sql || '        G.CPF_CGC, ';
            v_sql := v_sql || '        A.COD_NBM, ';
            v_sql := v_sql || '        B.COD_CFO, ';
            v_sql := v_sql || '        C.COD_NATUREZA_OP, ';
            v_sql := v_sql || '        D.COD_PRODUTO, ';
            v_sql := v_sql || '        D.DESCRICAO, ';
            v_sql := v_sql || '        X08.VLR_CONTAB_ITEM, ';
            v_sql := v_sql || '        X08.QUANTIDADE, ';
            v_sql := v_sql || '        TRUNC((X08.VLR_ITEM-X08.VLR_DESCONTO)/X08.QUANTIDADE,4) AS VLR_UNIT, ';
            v_sql := v_sql || '        E.COD_SITUACAO_B, ';
            v_sql := v_sql || '        X07.DATA_EMISSAO, ';
            v_sql := v_sql || '        H.COD_ESTADO, ';
            v_sql := v_sql || '        X07.NUM_CONTROLE_DOCTO, ';
            v_sql := v_sql || '        X07.NUM_AUTENTIC_NFE AS NUM_AUTENTIC_NFE, ';
            v_sql := v_sql || '        G.RAZAO_SOCIAL, ';
            v_sql := v_sql || '        I.COD_SITUACAO_A, ';
            v_sql := v_sql || '        0 AS BASE_ICMS_UNIT_E, ';
            v_sql := v_sql || '        0 AS VLR_ICMS_UNIT_E, ';
            v_sql := v_sql || '        0 AS ALIQ_ICMS_E, ';
            v_sql := v_sql || '        0 AS BASE_ST_UNIT_E, ';
            v_sql := v_sql || '        0 AS VLR_ICMS_ST_UNIT_E, ';
            v_sql := v_sql || '        '' '' AS STAT_LIBER_CNTR, ';
            v_sql := v_sql || '        '' '' AS ID_ALIQ_ST, ';
            v_sql := v_sql || '        0 AS VLR_PMC, ';
            v_sql := v_sql || '        0 AS TOTAL_ICMS, ';
            v_sql := v_sql || '        0 AS TOTAL_ICMS_ST, ';
            v_sql := v_sql || '        '' '' AS LISTA_PRODUTO, ';
            v_sql := v_sql || '        X08.COD_SITUACAO_PIS AS CST_PIS, ';
            v_sql := v_sql || '        X08.COD_SITUACAO_COFINS AS CST_COFINS, ';
            v_sql :=
                   v_sql
                || '        TRUNC(TRUNC((X08.VLR_ITEM-X08.VLR_DESCONTO)/X08.QUANTIDADE,4)*0.0165,4) AS ESTORNO_PIS_E, ';
            v_sql :=
                   v_sql
                || '        TRUNC(TRUNC((X08.VLR_ITEM-X08.VLR_DESCONTO)/X08.QUANTIDADE,4)*0.076,4) AS ESTORNO_COFINS_E, ';
            v_sql := v_sql || '        X08.VLR_PIS AS ESTORNO_PIS_S, ';
            v_sql := v_sql || '        X08.VLR_COFINS AS ESTORNO_COFINS_S, ';
            v_sql := v_sql || '        RANK() OVER( ';
            v_sql := v_sql || '          PARTITION BY X08.COD_ESTAB, D.COD_PRODUTO ';
            v_sql := v_sql || '              ORDER BY X08.DATA_FISCAL DESC, ';
            v_sql := v_sql || '                       X07.DATA_EMISSAO DESC, ';
            v_sql := v_sql || '                       X08.NUM_DOCFIS DESC, ';
            v_sql := v_sql || '                       X08.DISCRI_ITEM DESC) RANK ';
            v_sql := v_sql || '    FROM X08_ITENS_MERC X08, ';
            v_sql := v_sql || '         X07_DOCTO_FISCAL X07, ';
            v_sql := v_sql || '         X2013_PRODUTO D, ';
            v_sql := v_sql || '         X04_PESSOA_FIS_JUR G, ';
            ---
            v_sql := v_sql || '         ' || v_tab_aux || ' P, ';
            ---
            v_sql := v_sql || '         X2043_COD_NBM A, ';
            v_sql := v_sql || '         X2012_COD_FISCAL B, ';
            v_sql := v_sql || '         X2006_NATUREZA_OP C, ';
            v_sql := v_sql || '         Y2026_SIT_TRB_UF_B E, ';
            v_sql := v_sql || '         ESTADO H,  ';
            v_sql := v_sql || '         Y2025_SIT_TRB_UF_A I ';
            v_sql := v_sql || '    WHERE X07.MOVTO_E_S    <> ''9'' ';
            v_sql := v_sql || '      AND X07.SERIE_DOCFIS <> ''GNR'' ';
            v_sql := v_sql || '      AND X07.SITUACAO      = ''N'' ';
            v_sql := v_sql || '      AND X07.COD_EMPRESA   = ''' || mcod_empresa || ''' ';
            v_sql := v_sql || '      AND X07.COD_ESTAB     = ''' || vp_cod_estab || ''' ';
            ---
            v_sql := v_sql || '      AND X08.IDENT_NBM         = A.IDENT_NBM ';
            v_sql := v_sql || '      AND X08.IDENT_CFO         = B.IDENT_CFO ';
            v_sql :=
                v_sql || '      AND B.COD_CFO             IN (''1102'',''2102'',''1403'',''2403'',''1910'',''2910'') ';
            v_sql := v_sql || '      AND C.COD_NATUREZA_OP    <> ''ISE'' ';
            v_sql := v_sql || '      AND X08.IDENT_NATUREZA_OP = C.IDENT_NATUREZA_OP ';
            v_sql := v_sql || '      AND X08.IDENT_SITUACAO_B  = E.IDENT_SITUACAO_B ';
            v_sql := v_sql || '      AND X08.IDENT_SITUACAO_A  = I.IDENT_SITUACAO_A ';
            v_sql := v_sql || '      AND X07.VLR_PRODUTO       > 0.01 ';
            v_sql := v_sql || '      AND X08.IDENT_PRODUTO     = D.IDENT_PRODUTO ';
            ---
            v_sql := v_sql || '      AND P.COD_PRODUTO    =  D.COD_PRODUTO ';
            v_sql := v_sql || '      AND P.DATA_INV       >  X07.DATA_FISCAL ';
            v_sql := v_sql || '      AND X07.DATA_FISCAL  >= ADD_MONTHS(P.DATA_INV,-24) '; --ULTIMOS 2 ANOS
            ---
            v_sql := v_sql || '      AND X07.IDENT_FIS_JUR = G.IDENT_FIS_JUR ';
            v_sql := v_sql || '      AND G.IDENT_ESTADO    = H.IDENT_ESTADO ';
            ---
            v_sql := v_sql || '      AND X07.COD_EMPRESA      = X08.COD_EMPRESA ';
            v_sql := v_sql || '      AND X07.COD_ESTAB        = X08.COD_ESTAB ';
            v_sql := v_sql || '      AND X07.DATA_FISCAL      = X08.DATA_FISCAL ';
            v_sql := v_sql || '      AND X07.MOVTO_E_S        = X08.MOVTO_E_S ';
            v_sql := v_sql || '      AND X07.NORM_DEV         = X08.NORM_DEV ';
            v_sql := v_sql || '      AND X07.IDENT_DOCTO      = X08.IDENT_DOCTO ';
            v_sql := v_sql || '      AND X07.IDENT_FIS_JUR    = X08.IDENT_FIS_JUR ';
            v_sql := v_sql || '      AND X07.NUM_DOCFIS       = X08.NUM_DOCFIS ';
            v_sql := v_sql || '      AND X07.SERIE_DOCFIS     = X08.SERIE_DOCFIS ';
            v_sql := v_sql || '      AND X07.SUB_SERIE_DOCFIS = X08.SUB_SERIE_DOCFIS ';
            v_sql := v_sql || '     ) A ';
            v_sql := v_sql || 'WHERE A.RANK = 1 )';

            BEGIN
                EXECUTE IMMEDIATE v_sql;

                COMMIT;
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
                    ---
                    raise_application_error ( -20003
                                            , '!ERRO INSERT LOAD ENTRADAS CD!' );
            END;
        ELSIF ( vp_origem = 'F' ) THEN --FILIAL
            v_sql := 'INSERT /*+APPEND*/ INTO ' || vp_tabela_entrada || ' ( ';
            v_sql := v_sql || 'SELECT DISTINCT ';
            v_sql := v_sql || ' ' || vp_proc_instance || ', ';
            v_sql := v_sql || '    A.COD_EMPRESA, ';
            v_sql := v_sql || '    A.COD_ESTAB, ';
            v_sql := v_sql || '    A.DATA_FISCAL, ';
            v_sql := v_sql || '    A.DATA_INV, ';
            v_sql := v_sql || '    A.MOVTO_E_S, ';
            v_sql := v_sql || '    A.NORM_DEV, ';
            v_sql := v_sql || '    A.IDENT_DOCTO, ';
            v_sql := v_sql || '    A.IDENT_FIS_JUR, ';
            v_sql := v_sql || '    A.SERIE_DOCFIS, ';
            v_sql := v_sql || '    A.SUB_SERIE_DOCFIS, ';
            v_sql := v_sql || '    A.DISCRI_ITEM, ';
            v_sql := v_sql || '    A.NUM_ITEM, ';
            v_sql := v_sql || '    A.DATA_EMISSAO, ';
            v_sql := v_sql || '    A.NUM_DOCFIS, ';
            v_sql := v_sql || '    A.COD_FIS_JUR, ';
            v_sql := v_sql || '    A.CPF_CGC, ';
            v_sql := v_sql || '    A.RAZAO_SOCIAL, ';
            v_sql := v_sql || '    A.COD_NBM, ';
            v_sql := v_sql || '    A.COD_CFO, ';
            v_sql := v_sql || '    A.COD_NATUREZA_OP, ';
            v_sql := v_sql || '    A.COD_PRODUTO, ';
            v_sql := v_sql || '    A.DESCRICAO, ';
            v_sql := v_sql || '    A.VLR_CONTAB_ITEM, ';
            v_sql := v_sql || '    A.QUANTIDADE, ';
            v_sql := v_sql || '    A.VLR_UNIT, ';
            v_sql := v_sql || '    A.COD_SITUACAO_A, ';
            v_sql := v_sql || '    A.COD_SITUACAO_B, ';
            v_sql := v_sql || '    A.COD_ESTADO, ';
            v_sql := v_sql || '    A.NUM_CONTROLE_DOCTO, ';
            v_sql := v_sql || '    A.NUM_AUTENTIC_NFE, ';
            v_sql := v_sql || '    A.BASE_ICMS_UNIT_E, ';
            v_sql := v_sql || '    A.VLR_ICMS_UNIT_E, ';
            v_sql := v_sql || '    A.ALIQ_ICMS_E, ';
            v_sql := v_sql || '    A.BASE_ST_UNIT_E, ';
            v_sql := v_sql || '    A.VLR_ICMS_ST_UNIT_E, ';
            v_sql := v_sql || '    A.STAT_LIBER_CNTR, ';
            v_sql := v_sql || '    A.ID_ALIQ_ST, ';
            v_sql := v_sql || '    A.VLR_PMC, ';
            v_sql := v_sql || '    A.TOTAL_ICMS, ';
            v_sql := v_sql || '    A.TOTAL_ICMS_ST, ';
            v_sql := v_sql || '    A.LISTA_PRODUTO, ';
            v_sql := v_sql || '    A.CST_PIS, ';
            v_sql := v_sql || '    A.CST_COFINS, ';
            v_sql := v_sql || '    A.ESTORNO_PIS_E, ';
            v_sql := v_sql || '    A.ESTORNO_COFINS_E, ';
            v_sql := v_sql || '    A.ESTORNO_PIS_S, ';
            v_sql := v_sql || '    A.ESTORNO_COFINS_S ';
            v_sql := v_sql || 'FROM ( ';
            v_sql := v_sql || '      SELECT /*+PARALLEL(4)*/ ';
            v_sql := v_sql || '        X08.COD_EMPRESA, ';
            v_sql := v_sql || '        X08.COD_ESTAB, ';
            v_sql := v_sql || '        X08.DATA_FISCAL, ';
            v_sql := v_sql || '        P.DATA_INV, ';
            v_sql := v_sql || '        X08.MOVTO_E_S, ';
            v_sql := v_sql || '        X08.NORM_DEV, ';
            v_sql := v_sql || '        X08.IDENT_DOCTO, ';
            v_sql := v_sql || '        X08.IDENT_FIS_JUR, ';
            v_sql := v_sql || '        X08.NUM_DOCFIS, ';
            v_sql := v_sql || '        X08.SERIE_DOCFIS, ';
            v_sql := v_sql || '        X08.SUB_SERIE_DOCFIS, ';
            v_sql := v_sql || '        X08.DISCRI_ITEM, ';
            v_sql := v_sql || '        X08.NUM_ITEM, ';
            v_sql := v_sql || '        G.COD_FIS_JUR, ';
            v_sql := v_sql || '        G.CPF_CGC, ';
            v_sql := v_sql || '        A.COD_NBM, ';
            v_sql := v_sql || '        B.COD_CFO, ';
            v_sql := v_sql || '        C.COD_NATUREZA_OP, ';
            v_sql := v_sql || '        D.COD_PRODUTO, ';
            v_sql := v_sql || '        D.DESCRICAO, ';
            v_sql := v_sql || '        X08.VLR_CONTAB_ITEM, ';
            v_sql := v_sql || '        X08.QUANTIDADE, ';
            v_sql := v_sql || '        TRUNC((X08.VLR_ITEM-X08.VLR_DESCONTO)/X08.QUANTIDADE,4) AS VLR_UNIT, ';
            v_sql := v_sql || '        E.COD_SITUACAO_B, ';
            v_sql := v_sql || '        X07.DATA_EMISSAO, ';
            v_sql := v_sql || '        H.COD_ESTADO, ';
            v_sql := v_sql || '        X07.NUM_CONTROLE_DOCTO, ';
            v_sql := v_sql || '        X07.NUM_AUTENTIC_NFE AS NUM_AUTENTIC_NFE, ';
            v_sql := v_sql || '        G.RAZAO_SOCIAL, ';
            v_sql := v_sql || '        I.COD_SITUACAO_A, ';
            v_sql := v_sql || '        0 AS BASE_ICMS_UNIT_E, ';
            v_sql := v_sql || '        0 AS VLR_ICMS_UNIT_E, ';
            v_sql := v_sql || '        0 AS ALIQ_ICMS_E, ';
            v_sql := v_sql || '        0 AS BASE_ST_UNIT_E, ';
            v_sql := v_sql || '        0 AS VLR_ICMS_ST_UNIT_E, ';
            v_sql := v_sql || '        '' '' AS STAT_LIBER_CNTR, ';
            v_sql := v_sql || '        '' '' AS ID_ALIQ_ST, ';
            v_sql := v_sql || '        0 AS VLR_PMC, ';
            v_sql := v_sql || '        0 AS TOTAL_ICMS, ';
            v_sql := v_sql || '        0 AS TOTAL_ICMS_ST, ';
            v_sql := v_sql || '        '' '' AS LISTA_PRODUTO, ';
            v_sql := v_sql || '        X08.COD_SITUACAO_PIS AS CST_PIS, ';
            v_sql := v_sql || '        X08.COD_SITUACAO_COFINS AS CST_COFINS, ';
            v_sql :=
                   v_sql
                || '        TRUNC(TRUNC((X08.VLR_ITEM-X08.VLR_DESCONTO)/X08.QUANTIDADE,4)*0.0165,4) AS ESTORNO_PIS_E, ';
            v_sql :=
                   v_sql
                || '        TRUNC(TRUNC((X08.VLR_ITEM-X08.VLR_DESCONTO)/X08.QUANTIDADE,4)*0.076,4) AS ESTORNO_COFINS_E, ';
            v_sql := v_sql || '        X08.VLR_PIS AS ESTORNO_PIS_S, ';
            v_sql := v_sql || '        X08.VLR_COFINS AS ESTORNO_COFINS_S, ';
            v_sql := v_sql || '        RANK() OVER( ';
            v_sql := v_sql || '          PARTITION BY X08.COD_ESTAB, D.COD_PRODUTO ';
            v_sql := v_sql || '              ORDER BY X08.DATA_FISCAL DESC, ';
            v_sql := v_sql || '                       X07.DATA_EMISSAO DESC, ';
            v_sql := v_sql || '                       X08.NUM_DOCFIS DESC, ';
            v_sql := v_sql || '                       X08.DISCRI_ITEM DESC) RANK ';
            v_sql := v_sql || '    FROM X08_ITENS_MERC X08, ';
            v_sql := v_sql || '         X07_DOCTO_FISCAL X07, ';
            v_sql := v_sql || '         X2013_PRODUTO D, ';
            v_sql := v_sql || '         X04_PESSOA_FIS_JUR G, ';
            v_sql := v_sql || '         ' || vp_tab_perdas_inv || ' P, ';
            v_sql := v_sql || '         X2043_COD_NBM A, ';
            v_sql := v_sql || '         X2012_COD_FISCAL B, ';
            v_sql := v_sql || '         X2006_NATUREZA_OP C, ';
            v_sql := v_sql || '         Y2026_SIT_TRB_UF_B E, ';
            v_sql := v_sql || '         ESTADO H, ';
            v_sql := v_sql || '         Y2025_SIT_TRB_UF_A I ';
            v_sql := v_sql || '    WHERE X07.MOVTO_E_S   <> ''9'' ';
            v_sql := v_sql || '      AND X07.SITUACAO    = ''N'' ';
            v_sql := v_sql || '      AND X07.COD_EMPRESA = ''' || mcod_empresa || ''' ';
            v_sql := v_sql || '      AND X07.COD_ESTAB   = ''' || vp_cod_estab || ''' ';
            v_sql := v_sql || '      AND G.COD_FIS_JUR   = ''' || vp_cd || ''' ';
            ---
            v_sql := v_sql || '      AND X08.IDENT_NBM         = A.IDENT_NBM ';
            v_sql := v_sql || '      AND X08.IDENT_CFO         = B.IDENT_CFO ';
            v_sql := v_sql || '      AND B.COD_CFO             IN (''1152'',''2152'',''1409'',''2409'') ';
            v_sql := v_sql || '      AND C.COD_NATUREZA_OP    <> ''ISE'' ';
            v_sql := v_sql || '      AND X08.IDENT_NATUREZA_OP = C.IDENT_NATUREZA_OP ';
            v_sql := v_sql || '      AND X08.IDENT_SITUACAO_B  = E.IDENT_SITUACAO_B ';
            v_sql := v_sql || '      AND X08.IDENT_SITUACAO_A  = I.IDENT_SITUACAO_A ';
            v_sql := v_sql || '      AND X07.VLR_PRODUTO       <> 0 ';
            v_sql := v_sql || '      AND X08.IDENT_PRODUTO     = D.IDENT_PRODUTO ';
            ---
            v_sql := v_sql || '      AND P.PROC_ID       = ' || vp_proc_instance || ' ';
            v_sql := v_sql || '      AND P.COD_ESTAB     = X07.COD_ESTAB ';
            v_sql := v_sql || '      AND P.COD_PRODUTO   = D.COD_PRODUTO ';
            v_sql := v_sql || '      AND P.DATA_INV      > X07.DATA_FISCAL ';
            v_sql := v_sql || '      AND X07.DATA_FISCAL >= ADD_MONTHS(P.DATA_INV,-12) '; --ULTIMOS 2 ANOS
            ---
            v_sql := v_sql || '      AND X07.IDENT_FIS_JUR = G.IDENT_FIS_JUR ';
            v_sql := v_sql || '      AND G.IDENT_ESTADO    = H.IDENT_ESTADO ';
            ---
            v_sql := v_sql || '      AND X07.COD_EMPRESA      = X08.COD_EMPRESA ';
            v_sql := v_sql || '      AND X07.COD_ESTAB        = X08.COD_ESTAB ';
            v_sql := v_sql || '      AND X07.DATA_FISCAL      = X08.DATA_FISCAL ';
            v_sql := v_sql || '      AND X07.MOVTO_E_S        = X08.MOVTO_E_S ';
            v_sql := v_sql || '      AND X07.NORM_DEV         = X08.NORM_DEV ';
            v_sql := v_sql || '      AND X07.IDENT_DOCTO      = X08.IDENT_DOCTO ';
            v_sql := v_sql || '      AND X07.IDENT_FIS_JUR    = X08.IDENT_FIS_JUR ';
            v_sql := v_sql || '      AND X07.NUM_DOCFIS       = X08.NUM_DOCFIS ';
            v_sql := v_sql || '      AND X07.SERIE_DOCFIS     = X08.SERIE_DOCFIS ';
            v_sql := v_sql || '      AND X07.SUB_SERIE_DOCFIS = X08.SUB_SERIE_DOCFIS ';
            v_sql := v_sql || '     ) A ';
            v_sql := v_sql || 'WHERE A.RANK = 1 ) ';

            BEGIN
                EXECUTE IMMEDIATE v_sql;

                COMMIT;
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
                    ---
                    raise_application_error ( -20004
                                            , '!ERRO INSERT LOAD ENTRADAS FILIAL!' );
            END;
        ELSIF ( vp_origem = 'CO' ) THEN --COMPRA DIRETA
            v_sql := 'INSERT /*+APPEND*/ INTO ' || vp_tabela_entrada || ' ( ';
            v_sql := v_sql || 'SELECT DISTINCT ';
            v_sql := v_sql || '    ' || vp_proc_instance || ', ';
            v_sql := v_sql || '    A.COD_EMPRESA, ';
            v_sql := v_sql || '    A.COD_ESTAB, ';
            v_sql := v_sql || '    A.DATA_FISCAL, ';
            v_sql := v_sql || '    A.DATA_INV, ';
            v_sql := v_sql || '    A.MOVTO_E_S, ';
            v_sql := v_sql || '    A.NORM_DEV, ';
            v_sql := v_sql || '    A.IDENT_DOCTO, ';
            v_sql := v_sql || '    A.IDENT_FIS_JUR, ';
            v_sql := v_sql || '    A.SERIE_DOCFIS, ';
            v_sql := v_sql || '    A.SUB_SERIE_DOCFIS, ';
            v_sql := v_sql || '    A.DISCRI_ITEM, ';
            v_sql := v_sql || '    A.NUM_ITEM, ';
            v_sql := v_sql || '    A.DATA_EMISSAO, ';
            v_sql := v_sql || '    A.NUM_DOCFIS, ';
            v_sql := v_sql || '    A.COD_FIS_JUR, ';
            v_sql := v_sql || '    A.CPF_CGC, ';
            v_sql := v_sql || '    A.RAZAO_SOCIAL, ';
            v_sql := v_sql || '    A.COD_NBM, ';
            v_sql := v_sql || '    A.COD_CFO, ';
            v_sql := v_sql || '    A.COD_NATUREZA_OP, ';
            v_sql := v_sql || '    A.COD_PRODUTO, ';
            v_sql := v_sql || '    A.DESCRICAO, ';
            v_sql := v_sql || '    A.VLR_CONTAB_ITEM, ';
            v_sql := v_sql || '    A.QUANTIDADE, ';
            v_sql := v_sql || '    A.VLR_UNIT, ';
            v_sql := v_sql || '    A.COD_SITUACAO_A, ';
            v_sql := v_sql || '    A.COD_SITUACAO_B, ';
            v_sql := v_sql || '    A.COD_ESTADO, ';
            v_sql := v_sql || '    A.NUM_CONTROLE_DOCTO, ';
            v_sql := v_sql || '    A.NUM_AUTENTIC_NFE, ';
            v_sql := v_sql || '    A.BASE_ICMS_UNIT_E, ';
            v_sql := v_sql || '    A.VLR_ICMS_UNIT_E, ';
            v_sql := v_sql || '    A.ALIQ_ICMS_E, ';
            v_sql := v_sql || '    A.BASE_ST_UNIT_E, ';
            v_sql := v_sql || '    A.VLR_ICMS_ST_UNIT_E, ';
            v_sql := v_sql || '    A.STAT_LIBER_CNTR, ';
            v_sql := v_sql || '    A.ID_ALIQ_ST, ';
            v_sql := v_sql || '    A.VLR_PMC, ';
            v_sql := v_sql || '    A.TOTAL_ICMS, ';
            v_sql := v_sql || '    A.TOTAL_ICMS_ST, ';
            v_sql := v_sql || '    A.LISTA_PRODUTO, ';
            v_sql := v_sql || '    A.CST_PIS, ';
            v_sql := v_sql || '    A.CST_COFINS, ';
            v_sql := v_sql || '    A.ESTORNO_PIS_E, ';
            v_sql := v_sql || '    A.ESTORNO_COFINS_E, ';
            v_sql := v_sql || '    A.ESTORNO_PIS_S, ';
            v_sql := v_sql || '    A.ESTORNO_COFINS_S ';
            v_sql := v_sql || 'FROM ( ';
            v_sql := v_sql || '      SELECT /*+PARALLEL(4)*/ ';
            v_sql := v_sql || '        X08.COD_EMPRESA, ';
            v_sql := v_sql || '        X08.COD_ESTAB, ';
            v_sql := v_sql || '        X08.DATA_FISCAL, ';
            v_sql := v_sql || '        P.DATA_INV, ';
            v_sql := v_sql || '        X08.MOVTO_E_S, ';
            v_sql := v_sql || '        X08.NORM_DEV, ';
            v_sql := v_sql || '        X08.IDENT_DOCTO, ';
            v_sql := v_sql || '        X08.IDENT_FIS_JUR, ';
            v_sql := v_sql || '        X08.NUM_DOCFIS, ';
            v_sql := v_sql || '        X08.SERIE_DOCFIS, ';
            v_sql := v_sql || '        X08.SUB_SERIE_DOCFIS, ';
            v_sql := v_sql || '        X08.DISCRI_ITEM, ';
            v_sql := v_sql || '        X08.NUM_ITEM, ';
            v_sql := v_sql || '        G.COD_FIS_JUR, ';
            v_sql := v_sql || '        G.CPF_CGC, ';
            v_sql := v_sql || '        A.COD_NBM, ';
            v_sql := v_sql || '        B.COD_CFO, ';
            v_sql := v_sql || '        C.COD_NATUREZA_OP, ';
            v_sql := v_sql || '        D.COD_PRODUTO, ';
            v_sql := v_sql || '        D.DESCRICAO, ';
            v_sql := v_sql || '        X08.VLR_CONTAB_ITEM, ';
            v_sql := v_sql || '        X08.QUANTIDADE, ';
            v_sql := v_sql || '        TRUNC((X08.VLR_ITEM-X08.VLR_DESCONTO)/X08.QUANTIDADE,4) AS VLR_UNIT, ';
            v_sql := v_sql || '        E.COD_SITUACAO_B, ';
            v_sql := v_sql || '        X07.DATA_EMISSAO, ';
            v_sql := v_sql || '        H.COD_ESTADO, ';
            v_sql := v_sql || '        X07.NUM_CONTROLE_DOCTO, ';
            v_sql := v_sql || '        X07.NUM_AUTENTIC_NFE AS NUM_AUTENTIC_NFE, ';
            v_sql := v_sql || '        G.RAZAO_SOCIAL, ';
            v_sql := v_sql || '        I.COD_SITUACAO_A, ';
            v_sql := v_sql || '        0 AS BASE_ICMS_UNIT_E, ';
            v_sql := v_sql || '        0 AS VLR_ICMS_UNIT_E, ';
            v_sql := v_sql || '        0 AS ALIQ_ICMS_E, ';
            v_sql := v_sql || '        0 AS BASE_ST_UNIT_E, ';
            v_sql := v_sql || '        0 AS VLR_ICMS_ST_UNIT_E, ';
            v_sql := v_sql || '        '' '' AS STAT_LIBER_CNTR, ';
            v_sql := v_sql || '        '' '' AS ID_ALIQ_ST, ';
            v_sql := v_sql || '        0 AS VLR_PMC, ';
            v_sql := v_sql || '        0 AS TOTAL_ICMS, ';
            v_sql := v_sql || '        0 AS TOTAL_ICMS_ST, ';
            v_sql := v_sql || '        '' '' AS LISTA_PRODUTO, ';
            v_sql := v_sql || '        X08.COD_SITUACAO_PIS AS CST_PIS, ';
            v_sql := v_sql || '        X08.COD_SITUACAO_COFINS AS CST_COFINS, ';
            v_sql :=
                   v_sql
                || '        TRUNC(TRUNC((X08.VLR_ITEM-X08.VLR_DESCONTO)/X08.QUANTIDADE,4)*0.0165,4) AS ESTORNO_PIS_E, ';
            v_sql :=
                   v_sql
                || '        TRUNC(TRUNC((X08.VLR_ITEM-X08.VLR_DESCONTO)/X08.QUANTIDADE,4)*0.076,4) AS ESTORNO_COFINS_E, ';
            v_sql := v_sql || '        X08.VLR_PIS AS ESTORNO_PIS_S, ';
            v_sql := v_sql || '        X08.VLR_COFINS AS ESTORNO_COFINS_S, ';
            v_sql := v_sql || '        RANK() OVER( ';
            v_sql := v_sql || '          PARTITION BY X08.COD_ESTAB, D.COD_PRODUTO ';
            v_sql := v_sql || '              ORDER BY X08.DATA_FISCAL DESC, ';
            v_sql := v_sql || '                       X07.DATA_EMISSAO DESC, ';
            v_sql := v_sql || '                       X08.NUM_DOCFIS DESC, ';
            v_sql := v_sql || '                       X08.DISCRI_ITEM DESC) RANK ';
            v_sql := v_sql || '    FROM X08_ITENS_MERC X08, ';
            v_sql := v_sql || '         X07_DOCTO_FISCAL X07, ';
            v_sql := v_sql || '         X2013_PRODUTO D, ';
            v_sql := v_sql || '         X04_PESSOA_FIS_JUR G, ';
            v_sql := v_sql || '         ' || vp_tab_perdas_inv || ' P, ';
            v_sql := v_sql || '         X2043_COD_NBM A, ';
            v_sql := v_sql || '         X2012_COD_FISCAL B, ';
            v_sql := v_sql || '         X2006_NATUREZA_OP C, ';
            v_sql := v_sql || '         Y2026_SIT_TRB_UF_B E, ';
            v_sql := v_sql || '         ESTADO H,  ';
            v_sql := v_sql || '         Y2025_SIT_TRB_UF_A I ';
            v_sql := v_sql || '    WHERE X07.MOVTO_E_S   <> ''9'' ';
            v_sql := v_sql || '      AND X07.SITUACAO    = ''N'' ';
            v_sql := v_sql || '      AND X07.COD_EMPRESA = ''' || mcod_empresa || ''' ';
            v_sql := v_sql || '      AND X07.COD_ESTAB   = ''' || vp_cod_estab || ''' ';
            ---
            v_sql := v_sql || '      AND X08.IDENT_NBM = A.IDENT_NBM ';
            v_sql := v_sql || '      AND X08.IDENT_CFO = B.IDENT_CFO ';
            v_sql := v_sql || '      AND B.COD_CFO     IN (''1102'',''2102'',''1403'',''2403'',''1910'',''2910'') ';
            v_sql := v_sql || '      AND ((G.CPF_CGC NOT LIKE ''61412110%'' AND X08.COD_EMPRESA = ''DSP'') ';
            v_sql := v_sql || '            OR  (G.CPF_CGC NOT LIKE ''334382500%'' AND X08.COD_EMPRESA = ''DP'')) ';
            v_sql := v_sql || '      AND X07.NUM_CONTROLE_DOCTO  NOT LIKE ''C%''  ';
            v_sql := v_sql || '      AND X08.IDENT_NATUREZA_OP   = C.IDENT_NATUREZA_OP ';
            v_sql := v_sql || '      AND X08.IDENT_SITUACAO_B    = E.IDENT_SITUACAO_B ';
            v_sql := v_sql || '      AND X08.IDENT_SITUACAO_A    = I.IDENT_SITUACAO_A ';
            v_sql := v_sql || '      AND X07.VLR_PRODUTO        <> 0 ';
            v_sql := v_sql || '      AND C.COD_NATUREZA_OP      <> ''ISE'' ';
            v_sql := v_sql || '      AND X08.IDENT_PRODUTO       = D.IDENT_PRODUTO ';
            ---
            v_sql := v_sql || '      AND P.PROC_ID          = ' || vp_proc_instance || ' ';
            ---
            v_sql := v_sql || '      AND P.COD_ESTAB      = X08.COD_ESTAB ';
            v_sql := v_sql || '      AND P.COD_PRODUTO    = D.COD_PRODUTO ';
            v_sql := v_sql || '      AND P.DATA_INV       > X07.DATA_FISCAL ';
            v_sql := v_sql || '      AND X07.DATA_FISCAL  >= ADD_MONTHS(P.DATA_INV,-12) '; --ULTIMOS 2 ANOS
            ---
            v_sql := v_sql || '      AND X07.IDENT_FIS_JUR = G.IDENT_FIS_JUR ';
            v_sql := v_sql || '      AND G.IDENT_ESTADO    = H.IDENT_ESTADO ';
            ---
            v_sql := v_sql || '      AND X07.COD_EMPRESA      = X08.COD_EMPRESA ';
            v_sql := v_sql || '      AND X07.COD_ESTAB        = X08.COD_ESTAB ';
            v_sql := v_sql || '      AND X07.DATA_FISCAL      = X08.DATA_FISCAL ';
            v_sql := v_sql || '      AND X07.MOVTO_E_S        = X08.MOVTO_E_S ';
            v_sql := v_sql || '      AND X07.NORM_DEV         = X08.NORM_DEV ';
            v_sql := v_sql || '      AND X07.IDENT_DOCTO      = X08.IDENT_DOCTO ';
            v_sql := v_sql || '      AND X07.IDENT_FIS_JUR    = X08.IDENT_FIS_JUR ';
            v_sql := v_sql || '      AND X07.NUM_DOCFIS       = X08.NUM_DOCFIS ';
            v_sql := v_sql || '      AND X07.SERIE_DOCFIS     = X08.SERIE_DOCFIS ';
            v_sql := v_sql || '      AND X07.SUB_SERIE_DOCFIS = X08.SUB_SERIE_DOCFIS ';
            v_sql := v_sql || '     ) A ';
            v_sql := v_sql || 'WHERE A.RANK = 1 ) ';

            BEGIN
                EXECUTE IMMEDIATE v_sql;

                COMMIT;
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
                    ---
                    raise_application_error ( -20005
                                            , '!ERRO INSERT LOAD ENTRADAS CDIRETA!' );
            END;
        ELSIF ( vp_origem = 'E' ) THEN --FILIAL DE OUTRA FILIAL MESMA UF
            --TAB AUXILIAR
            v_tab_aux := 'T$_' || vp_cod_estab || vp_proc_instance;
            v_sql := 'CREATE TABLE ' || v_tab_aux || ' AS ';
            v_sql :=
                v_sql || ' SELECT * FROM ' || vp_tab_perdas_inv || ' WHERE COD_ESTAB = ''' || vp_cod_estab || ''' ';

            EXECUTE IMMEDIATE v_sql;

            save_tmp_control ( vp_proc_instance
                             , v_tab_aux );
            v_sql := 'CREATE UNIQUE INDEX PK_' || vp_cod_estab || vp_proc_instance || ' ON ' || v_tab_aux;
            v_sql := v_sql || ' ( ';
            v_sql := v_sql || ' PROC_ID       ASC, ';
            v_sql := v_sql || ' COD_ESTAB     ASC, ';
            v_sql := v_sql || ' COD_PRODUTO   ASC, ';
            v_sql := v_sql || ' DATA_INV      ASC  ';
            v_sql := v_sql || ' ) PCTFREE 10 ';

            EXECUTE IMMEDIATE v_sql;

            dbms_stats.gather_table_stats ( 'MSAF'
                                          , v_tab_aux );
            --

            --APAGAR LINHAS JA CARREGADAS NA TAB DE ENTRADA NA FILIAL COM ORIGEM NO CD
            v_sql := 'DELETE ' || v_tab_aux || ' A ';
            v_sql := v_sql || ' WHERE EXISTS (SELECT ''Y'' ';
            v_sql := v_sql || '               FROM ' || vp_tab_perdas_ent_f || ' E ';
            v_sql := v_sql || '               WHERE E.COD_ESTAB_E   = A.COD_ESTAB ';
            v_sql := v_sql || '                 AND E.COD_PRODUTO_E = A.COD_PRODUTO ';
            v_sql := v_sql || '                 AND E.DATA_INV_S    = A.DATA_INV ) ';

            EXECUTE IMMEDIATE v_sql;

            loga ( '[LIMPEZA MUF][' || SQL%ROWCOUNT || ']'
                 , FALSE );
            COMMIT;

            --OBTER PARTICAO DA X07 e X08--INI------------------------------------
            v_sql :=
                'SELECT X07.PARTITION_NAME AS X07_PARTITION_NAME, NVL(X08.PARTITION_NAME,''NAO_EXISTE'') AS X08_PARTITION_NAME, X07.PARTITION_INI AS INICIO_PARTICAO, ';
            v_sql := v_sql || '  NVL(X08.PARTITION_FIM, X07.PARTITION_FIM) AS FINAL_PARTICAO ';
            v_sql := v_sql || 'FROM ';
            v_sql := v_sql || '( ';
            v_sql := v_sql || 'SELECT B.OWNER, B.TABLE_NAME, B.PARTITION_NAME,  ';
            v_sql :=
                   v_sql
                || '  NVL(LEAD(B.PARTITION_FIM,1) OVER (ORDER BY B.PARTITION_FIM DESC)+1, TO_DATE(''01'' || TO_CHAR(B.PARTITION_FIM,''MMYYYY''),''DDMMYYYY'') ) AS PARTITION_INI, B.PARTITION_FIM  ';
            v_sql := v_sql || 'FROM ( ';
            v_sql :=
                   v_sql
                || 'SELECT A.OWNER, A.TABLE_NAME, A.PARTITION_NAME, TO_DATE(A.PARTITION_FIM,''DD/MM/YYYY'') AS PARTITION_FIM  ';
            ---V_SQL := V_SQL || 'SELECT A.OWNER, A.TABLE_NAME, A.PARTITION_NAME, TO_DATE(A.HIGH_VALUE,''DD/MM/YYYY'') AS PARTITION_FIM  ';
            v_sql := v_sql || 'FROM TABLE(MSAFI.DPSP_RECUPERA_PARTICAO(''MSAF'',  ';
            v_sql := v_sql || '          ''X07_DOCTO_FISCAL'',  ';
            v_sql := v_sql || '          TO_DATE(''20130101'',''YYYYMMDD''), ';
            v_sql :=
                   v_sql
                || '          TO_DATE('''
                || TO_CHAR ( vp_dt_final
                           , 'YYYYMMDD' )
                || ''',''YYYYMMDD''))) A ';
            v_sql := v_sql || 'ORDER BY TO_DATE(A.PARTITION_FIM,''DD/MM/YYYY'')  ';
            ---V_SQL := V_SQL || 'ORDER BY TO_DATE(A.HIGH_VALUE,''DD/MM/YYYY'')  ';
            v_sql := v_sql || ') B ) X07, ';
            v_sql := v_sql || '( ';
            v_sql := v_sql || 'SELECT B.OWNER, B.TABLE_NAME, B.PARTITION_NAME,  ';
            v_sql :=
                   v_sql
                || '  NVL(LEAD(B.PARTITION_FIM,1) OVER (ORDER BY B.PARTITION_FIM DESC)+1, TO_DATE(''01'' || TO_CHAR(B.PARTITION_FIM,''MMYYYY''),''DDMMYYYY'') ) AS PARTITION_INI, B.PARTITION_FIM  ';
            v_sql := v_sql || 'FROM ( ';
            ---V_SQL := V_SQL || 'SELECT A.OWNER, A.TABLE_NAME, A.PARTITION_NAME, TO_DATE(A.HIGH_VALUE,''DD/MM/YYYY'') AS PARTITION_FIM  ';
            v_sql :=
                   v_sql
                || 'SELECT A.OWNER, A.TABLE_NAME, A.PARTITION_NAME, TO_DATE(A.PARTITION_FIM,''DD/MM/YYYY'') AS PARTITION_FIM  ';
            v_sql := v_sql || 'FROM TABLE(MSAFI.DPSP_RECUPERA_PARTICAO(''MSAF'', ';
            v_sql := v_sql || '          ''X08_ITENS_MERC'', ';
            v_sql := v_sql || '          TO_DATE(''20130101'',''YYYYMMDD''), ';
            v_sql :=
                   v_sql
                || '          TO_DATE('''
                || TO_CHAR ( vp_dt_final
                           , 'YYYYMMDD' )
                || ''',''YYYYMMDD''))) A ';
            v_sql := v_sql || 'ORDER BY TO_DATE(A.PARTITION_FIM,''DD/MM/YYYY'')  ';
            ---V_SQL := V_SQL || 'ORDER BY TO_DATE(A.HIGH_VALUE,''DD/MM/YYYY'') ';
            v_sql := v_sql || ') B ) X08 ';
            v_sql := v_sql || 'WHERE X07.PARTITION_FIM = X08.PARTITION_FIM (+) ';
            v_sql := v_sql || 'ORDER BY X07.PARTITION_FIM DESC ';
            --OBTER PARTICAO DA X07 e X08--FIM------------------------------------

            v_limit := 0;
            v_partition_x08 := '';

            OPEN c_part FOR v_sql;

            LOOP
                FETCH c_part
                    BULK COLLECT INTO tab_part;

                FOR i IN 1 .. tab_part.COUNT LOOP
                    v_limit := v_limit + 1;

                    IF ( tab_part ( i ).x08_partition_name <> 'NAO_EXISTE' ) THEN
                        v_partition_x08 := ' PARTITION ( ' || tab_part ( i ).x08_partition_name || ') ';
                    END IF;

                    v_sql := 'INSERT /*+APPEND*/ INTO ' || vp_tabela_entrada || ' ( ';
                    v_sql := v_sql || 'SELECT ';
                    v_sql := v_sql || ' ' || vp_proc_instance || ', ';
                    v_sql := v_sql || '    A.COD_EMPRESA, ';
                    v_sql := v_sql || '    A.COD_ESTAB, ';
                    v_sql := v_sql || '    A.DATA_FISCAL, ';
                    v_sql := v_sql || '    A.DATA_INV, ';
                    v_sql := v_sql || '    A.MOVTO_E_S, ';
                    v_sql := v_sql || '    A.NORM_DEV, ';
                    v_sql := v_sql || '    A.IDENT_DOCTO, ';
                    v_sql := v_sql || '    A.IDENT_FIS_JUR, ';
                    v_sql := v_sql || '    A.SERIE_DOCFIS, ';
                    v_sql := v_sql || '    A.SUB_SERIE_DOCFIS, ';
                    v_sql := v_sql || '    A.DISCRI_ITEM, ';
                    v_sql := v_sql || '    A.NUM_ITEM, ';
                    v_sql := v_sql || '    A.DATA_EMISSAO, ';
                    v_sql := v_sql || '    A.NUM_DOCFIS, ';
                    v_sql := v_sql || '    A.COD_FIS_JUR, ';
                    v_sql := v_sql || '    A.CPF_CGC, ';
                    v_sql := v_sql || '    A.RAZAO_SOCIAL, ';
                    v_sql := v_sql || '    A.COD_NBM, ';
                    v_sql := v_sql || '    A.COD_CFO, ';
                    v_sql := v_sql || '    A.COD_NATUREZA_OP, ';
                    v_sql := v_sql || '    A.COD_PRODUTO, ';
                    v_sql := v_sql || '    A.DESCRICAO, ';
                    v_sql := v_sql || '    A.VLR_CONTAB_ITEM, ';
                    v_sql := v_sql || '    A.QUANTIDADE, ';
                    v_sql := v_sql || '    A.VLR_UNIT, ';
                    v_sql := v_sql || '    A.COD_SITUACAO_A, ';
                    v_sql := v_sql || '    A.COD_SITUACAO_B, ';
                    v_sql := v_sql || '    A.COD_ESTADO, ';
                    v_sql := v_sql || '    A.NUM_CONTROLE_DOCTO, ';
                    v_sql := v_sql || '    A.NUM_AUTENTIC_NFE, ';
                    v_sql := v_sql || '    A.BASE_ICMS_UNIT_E, ';
                    v_sql := v_sql || '    A.VLR_ICMS_UNIT_E, ';
                    v_sql := v_sql || '    A.ALIQ_ICMS_E, ';
                    v_sql := v_sql || '    A.BASE_ST_UNIT_E, ';
                    v_sql := v_sql || '    A.VLR_ICMS_ST_UNIT_E, ';
                    v_sql := v_sql || '    A.STAT_LIBER_CNTR, ';
                    v_sql := v_sql || '    A.ID_ALIQ_ST, ';
                    v_sql := v_sql || '    A.VLR_PMC, ';
                    v_sql := v_sql || '    A.TOTAL_ICMS, ';
                    v_sql := v_sql || '    A.TOTAL_ICMS_ST, ';
                    v_sql := v_sql || '    A.LISTA_PRODUTO, ';
                    v_sql := v_sql || '    A.CST_PIS, ';
                    v_sql := v_sql || '    A.CST_COFINS, ';
                    v_sql := v_sql || '    A.ESTORNO_PIS_E, ';
                    v_sql := v_sql || '    A.ESTORNO_COFINS_E, ';
                    v_sql := v_sql || '    A.ESTORNO_PIS_S, ';
                    v_sql := v_sql || '    A.ESTORNO_COFINS_S ';
                    v_sql := v_sql || 'FROM ( ';
                    v_sql := v_sql || '      SELECT ';
                    v_sql := v_sql || '        X08.COD_EMPRESA, ';
                    v_sql := v_sql || '        X08.COD_ESTAB, ';
                    v_sql := v_sql || '        X08.DATA_FISCAL, ';
                    v_sql := v_sql || '        P.DATA_INV, ';
                    v_sql := v_sql || '        X08.MOVTO_E_S, ';
                    v_sql := v_sql || '        X08.NORM_DEV, ';
                    v_sql := v_sql || '        X08.IDENT_DOCTO, ';
                    v_sql := v_sql || '        X08.IDENT_FIS_JUR, ';
                    v_sql := v_sql || '        X08.NUM_DOCFIS, ';
                    v_sql := v_sql || '        X08.SERIE_DOCFIS, ';
                    v_sql := v_sql || '        X08.SUB_SERIE_DOCFIS, ';
                    v_sql := v_sql || '        X08.DISCRI_ITEM, ';
                    v_sql := v_sql || '        X08.NUM_ITEM, ';
                    v_sql := v_sql || '        G.COD_FIS_JUR, ';
                    v_sql := v_sql || '        G.CPF_CGC, ';
                    v_sql := v_sql || '        A.COD_NBM, ';
                    v_sql := v_sql || '        B.COD_CFO, ';
                    v_sql := v_sql || '        C.COD_NATUREZA_OP, ';
                    v_sql := v_sql || '        D.COD_PRODUTO, ';
                    v_sql := v_sql || '        D.DESCRICAO, ';
                    v_sql := v_sql || '        X08.VLR_CONTAB_ITEM, ';
                    v_sql := v_sql || '        X08.QUANTIDADE, ';
                    v_sql := v_sql || '        TRUNC((X08.VLR_ITEM-X08.VLR_DESCONTO)/X08.QUANTIDADE,4) AS VLR_UNIT, ';
                    v_sql := v_sql || '        E.COD_SITUACAO_B, ';
                    v_sql := v_sql || '        X07.DATA_EMISSAO, ';
                    v_sql := v_sql || '        H.COD_ESTADO, ';
                    v_sql := v_sql || '        X07.NUM_CONTROLE_DOCTO, ';
                    v_sql := v_sql || '        X07.NUM_AUTENTIC_NFE AS NUM_AUTENTIC_NFE, ';
                    v_sql := v_sql || '        G.RAZAO_SOCIAL, ';
                    v_sql := v_sql || '        I.COD_SITUACAO_A, ';
                    v_sql := v_sql || '        0 AS BASE_ICMS_UNIT_E, ';
                    v_sql := v_sql || '        0 AS VLR_ICMS_UNIT_E, ';
                    v_sql := v_sql || '        0 AS ALIQ_ICMS_E, ';
                    v_sql := v_sql || '        0 AS BASE_ST_UNIT_E, ';
                    v_sql := v_sql || '        0 AS VLR_ICMS_ST_UNIT_E, ';
                    v_sql := v_sql || '        '' '' AS STAT_LIBER_CNTR, ';
                    v_sql := v_sql || '        '' '' AS ID_ALIQ_ST, ';
                    v_sql := v_sql || '        0 AS VLR_PMC, ';
                    v_sql := v_sql || '        0 AS TOTAL_ICMS, ';
                    v_sql := v_sql || '        0 AS TOTAL_ICMS_ST, ';
                    v_sql := v_sql || '        '' '' AS LISTA_PRODUTO, ';
                    v_sql := v_sql || '        X08.COD_SITUACAO_PIS AS CST_PIS, ';
                    v_sql := v_sql || '        X08.COD_SITUACAO_COFINS AS CST_COFINS, ';
                    v_sql :=
                           v_sql
                        || '        TRUNC(TRUNC((X08.VLR_ITEM-X08.VLR_DESCONTO)/X08.QUANTIDADE,4)*0.0165,4) AS ESTORNO_PIS_E, ';
                    v_sql :=
                           v_sql
                        || '        TRUNC(TRUNC((X08.VLR_ITEM-X08.VLR_DESCONTO)/X08.QUANTIDADE,4)*0.076,4) AS ESTORNO_COFINS_E, ';
                    v_sql := v_sql || '        X08.VLR_PIS AS ESTORNO_PIS_S, ';
                    v_sql := v_sql || '        X08.VLR_COFINS AS ESTORNO_COFINS_S, ';
                    v_sql := v_sql || '        RANK() OVER( ';
                    v_sql := v_sql || '          PARTITION BY X08.COD_ESTAB, D.COD_PRODUTO ';
                    v_sql := v_sql || '              ORDER BY X08.DATA_FISCAL DESC, ';
                    v_sql := v_sql || '                       X07.DATA_EMISSAO DESC, ';
                    v_sql := v_sql || '                       X08.NUM_DOCFIS DESC, ';
                    v_sql := v_sql || '                       X08.DISCRI_ITEM DESC) RANK ';
                    v_sql := v_sql || '    FROM X08_ITENS_MERC ' || v_partition_x08 || ' X08, ';
                    v_sql :=
                           v_sql
                        || '         X07_DOCTO_FISCAL PARTITION ('
                        || tab_part ( i ).x07_partition_name
                        || ') X07, ';
                    v_sql := v_sql || '         X2013_PRODUTO D, ';
                    v_sql := v_sql || '         X04_PESSOA_FIS_JUR G, ';
                    v_sql := v_sql || '         ' || v_tab_aux || ' P, ';
                    v_sql := v_sql || '         X2043_COD_NBM A, ';
                    v_sql := v_sql || '         X2012_COD_FISCAL B, ';
                    v_sql := v_sql || '         X2006_NATUREZA_OP C, ';
                    v_sql := v_sql || '         Y2026_SIT_TRB_UF_B E, ';
                    v_sql := v_sql || '         ESTADO H, ';
                    v_sql := v_sql || '         Y2025_SIT_TRB_UF_A I, ';
                    v_sql := v_sql || '         MSAFI.DSP_ESTABELECIMENTO ES, ';
                    v_sql := v_sql || '         MSAFI.DSP_ESTABELECIMENTO ES2 ';
                    v_sql := v_sql || '    WHERE X07.MOVTO_E_S   <> ''9'' ';
                    v_sql := v_sql || '      AND P.ROWID BETWEEN :start_id AND :end_id '; ---FOR DBMS_PARALLEL_EXECUTE
                    v_sql := v_sql || '      AND X07.SITUACAO    = ''N'' ';
                    v_sql := v_sql || '      AND X07.COD_EMPRESA = ''' || mcod_empresa || ''' ';
                    v_sql := v_sql || '      AND X07.COD_ESTAB   = ''' || vp_cod_estab || ''' ';
                    v_sql := v_sql || '      AND ES.COD_ESTAB    = P.COD_ESTAB ';
                    v_sql := v_sql || '      AND ES.COD_ESTADO   = H.COD_ESTADO ';
                    v_sql := v_sql || '      AND ES2.COD_EMPRESA = X07.COD_EMPRESA ';
                    v_sql := v_sql || '      AND ES2.COD_ESTAB   = G.COD_FIS_JUR ';
                    v_sql := v_sql || '      AND ES2.TIPO        = ''L'' ';
                    ---
                    v_sql := v_sql || '      AND X08.IDENT_NBM         = A.IDENT_NBM ';
                    v_sql := v_sql || '      AND X08.IDENT_CFO         = B.IDENT_CFO ';
                    v_sql := v_sql || '      AND B.COD_CFO             IN (''1152'',''2152'',''1409'',''2409'') ';
                    v_sql := v_sql || '      AND C.COD_NATUREZA_OP    <> ''ISE'' ';
                    v_sql := v_sql || '      AND X08.IDENT_NATUREZA_OP = C.IDENT_NATUREZA_OP ';
                    v_sql := v_sql || '      AND X08.IDENT_SITUACAO_B  = E.IDENT_SITUACAO_B ';
                    v_sql := v_sql || '      AND X08.IDENT_SITUACAO_A  = I.IDENT_SITUACAO_A ';
                    v_sql := v_sql || '      AND X07.VLR_PRODUTO       <> 0 ';
                    v_sql := v_sql || '      AND X08.IDENT_PRODUTO     = D.IDENT_PRODUTO ';
                    ---
                    v_sql := v_sql || '      AND P.PROC_ID       = ' || vp_proc_instance || ' ';
                    v_sql := v_sql || '      AND P.COD_ESTAB     = X07.COD_ESTAB ';
                    v_sql := v_sql || '      AND P.COD_PRODUTO   = D.COD_PRODUTO ';
                    v_sql := v_sql || '      AND P.DATA_INV      > X07.DATA_FISCAL ';
                    v_sql :=
                           v_sql
                        || '      AND X07.DATA_FISCAL BETWEEN TO_DATE('''
                        || TO_CHAR ( tab_part ( i ).inicio_particao
                                   , 'DDMMYYYY' )
                        || ''',''DDMMYYYY'') AND TO_DATE('''
                        || TO_CHAR ( tab_part ( i ).final_particao
                                   , 'DDMMYYYY' )
                        || ''',''DDMMYYYY'') ';
                    v_sql :=
                           v_sql
                        || '      AND X08.DATA_FISCAL BETWEEN TO_DATE('''
                        || TO_CHAR ( tab_part ( i ).inicio_particao
                                   , 'DDMMYYYY' )
                        || ''',''DDMMYYYY'') AND TO_DATE('''
                        || TO_CHAR ( tab_part ( i ).final_particao
                                   , 'DDMMYYYY' )
                        || ''',''DDMMYYYY'') ';
                    ---
                    v_sql := v_sql || '      AND X07.IDENT_FIS_JUR = G.IDENT_FIS_JUR ';
                    v_sql := v_sql || '      AND G.IDENT_ESTADO    = H.IDENT_ESTADO ';
                    ---
                    v_sql := v_sql || '      AND X07.COD_EMPRESA      = X08.COD_EMPRESA ';
                    v_sql := v_sql || '      AND X07.COD_ESTAB        = X08.COD_ESTAB ';
                    v_sql := v_sql || '      AND X07.DATA_FISCAL      = X08.DATA_FISCAL ';
                    v_sql := v_sql || '      AND X07.MOVTO_E_S        = X08.MOVTO_E_S ';
                    v_sql := v_sql || '      AND X07.NORM_DEV         = X08.NORM_DEV ';
                    v_sql := v_sql || '      AND X07.IDENT_DOCTO      = X08.IDENT_DOCTO ';
                    v_sql := v_sql || '      AND X07.IDENT_FIS_JUR    = X08.IDENT_FIS_JUR ';
                    v_sql := v_sql || '      AND X07.NUM_DOCFIS       = X08.NUM_DOCFIS ';
                    v_sql := v_sql || '      AND X07.SERIE_DOCFIS     = X08.SERIE_DOCFIS ';
                    v_sql := v_sql || '      AND X07.SUB_SERIE_DOCFIS = X08.SUB_SERIE_DOCFIS ';
                    v_sql := v_sql || '     ) A ';
                    v_sql := v_sql || 'WHERE A.RANK = 1 ) ';

                    ---LOGA(SUBSTR(V_SQL, 1, 1024), FALSE);
                    ---LOGA(SUBSTR(V_SQL, 1024, 1024), FALSE);
                    ---LOGA(SUBSTR(V_SQL, 2048, 1024), FALSE);
                    ---LOGA(SUBSTR(V_SQL, 3072, 1024), FALSE);
                    ---LOGA(SUBSTR(V_SQL, 4096), FALSE);

                    --- CREATE PARALLEL PROCESS -----------
                    EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || v_tab_aux            INTO v_qtde;

                    IF ( v_qtde > 0 ) THEN
                        v_size :=
                            ROUND ( v_qtde / 10
                                  , 0 );

                        IF ( v_size < 1 ) THEN
                            v_size := 1;
                        END IF;

                        loga ( '[' || vp_cod_estab || '][' || v_qtde || ']'
                             , FALSE );

                        v_task := 'TASK_' || vp_proc_instance;
                        dbms_parallel_execute.create_task ( task_name => v_task );

                        dbms_parallel_execute.create_chunks_by_rowid ( task_name => v_task
                                                                     , table_owner => 'MSAF'
                                                                     , table_name => v_tab_aux
                                                                     , by_row => TRUE
                                                                     , chunk_size => v_size );

                        dbms_parallel_execute.run_task ( task_name => v_task
                                                       , sql_stmt => v_sql
                                                       , language_flag => dbms_sql.native
                                                       , parallel_level => 10 );

                        v_try := 0;
                        v_status := dbms_parallel_execute.task_status ( v_task );

                        --- IF THERE IS ERROR, RESUME IT FOR AT MOST 2 TIMES
                        WHILE ( v_try < 2
                           AND v_status != dbms_parallel_execute.finished ) LOOP
                            v_try := v_try + 1;
                            dbms_parallel_execute.resume_task ( v_task );
                            v_status := dbms_parallel_execute.task_status ( v_task );
                        END LOOP;

                        dbms_parallel_execute.drop_task ( v_task );
                        COMMIT;
                    END IF; ---IF (V_QTDE > 0) THEN

                    --- END PARALLEL PROCESS --------------

                    --APAGAR LINHAS JA CARREGADAS NA TAB DE ENTRADA
                    v_sql := 'DELETE ' || v_tab_aux || ' A ';
                    v_sql := v_sql || ' WHERE EXISTS (SELECT ''Y'' ';
                    v_sql := v_sql || '               FROM ' || vp_tabela_entrada || ' E ';
                    v_sql := v_sql || '               WHERE E.COD_ESTAB_E   = A.COD_ESTAB ';
                    v_sql := v_sql || '                 AND E.COD_PRODUTO_E = A.COD_PRODUTO ';
                    v_sql := v_sql || '                 AND E.DATA_INV_S    = A.DATA_INV ) ';

                    EXECUTE IMMEDIATE v_sql;

                    loga ( '[AUX DEL][' || SQL%ROWCOUNT || ']'
                         , FALSE );
                    COMMIT;

                    BEGIN
                        EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || v_tab_aux            INTO v_qtde;

                        loga (
                                  '[BUSCA '
                               || i
                               || ']['
                               || v_qtde
                               || ']['
                               || v_partition_x08
                               || ']['
                               || tab_part ( i ).inicio_particao
                               || ']['
                               || tab_part ( i ).final_particao
                               || ']'
                             , FALSE
                        );
                    EXCEPTION
                        WHEN OTHERS THEN
                            v_qtde := 0;
                    END;

                    IF ( v_limit = 12
                     OR v_qtde = 0 ) THEN
                        --VOLTAR 2 ANOS
                        EXIT;
                    END IF;
                END LOOP; --FOR I IN 1..TAB_PART.COUNT

                EXIT WHEN c_part%NOTFOUND;
            END LOOP; --OPEN C_PART FOR V_SQL;

            CLOSE c_part;
        END IF;
    END; --PROCEDURE LOAD_ENTRADAS

    --PROCEDURE PARA CRIAR TABELAS TEMP DE ALIQ E PMC
    PROCEDURE load_aliq_pmc ( vp_proc_id IN NUMBER
                            , vp_nome_tabela_aliq   OUT VARCHAR2
                            , vp_nome_tabela_pmc   OUT VARCHAR2
                            , vp_tab_perdas_inv IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 2000 );
        c_aliq_st SYS_REFCURSOR;

        TYPE cur_tab_aliq IS RECORD
        (
            proc_id NUMBER ( 30 )
          , cod_produto VARCHAR2 ( 25 )
          , aliq_st VARCHAR2 ( 4 )
        );

        TYPE c_tab_aliq IS TABLE OF cur_tab_aliq;

        tab_aliq c_tab_aliq;
    BEGIN
        vp_nome_tabela_aliq := 'DPSP_MSAF_ALIQ_' || vp_proc_id;

        v_sql := 'CREATE TABLE ' || vp_nome_tabela_aliq;
        v_sql := v_sql || ' (';
        v_sql := v_sql || 'PROC_ID     NUMBER(30),';
        v_sql := v_sql || 'COD_PRODUTO VARCHAR2(25),';
        v_sql := v_sql || 'ALIQ_ST     VARCHAR2(4)';
        v_sql := v_sql || ' )';

        EXECUTE IMMEDIATE v_sql;

        ---
        save_tmp_control ( vp_proc_id
                         , vp_nome_tabela_aliq );

        v_sql := 'SELECT DISTINCT ' || vp_proc_id || ' AS PROC_ID, A.COD_PRODUTO AS COD_PRODUTO, A.ALIQ_ST AS ALIQ_ST ';
        v_sql := v_sql || 'FROM (SELECT A.COD_PRODUTO AS COD_PRODUTO, B.XLATLONGNAME AS ALIQ_ST ';
        v_sql := v_sql || '       FROM ' || vp_tab_perdas_inv || ' A, ';
        v_sql := v_sql || '       MSAFI.PS_MSAF_PERDAS_VW  B, ';
        v_sql := v_sql || '       MSAFI.DSP_ESTABELECIMENTO D ';
        v_sql := v_sql || '       WHERE A.PROC_ID     = ' || vp_proc_id || ' ';
        v_sql := v_sql || '         AND B.SETID       = ''GERAL'' ';
        v_sql := v_sql || '         AND B.INV_ITEM_ID = A.COD_PRODUTO ';
        v_sql := v_sql || '         AND D.COD_EMPRESA = MSAFI.DPSP.EMPRESA ';
        v_sql := v_sql || '         AND D.COD_ESTAB   = A.COD_ESTAB ';
        v_sql := v_sql || '         AND B.CRIT_STATE_TO_PBL = D.COD_ESTADO ';
        v_sql := v_sql || '         AND B.CRIT_STATE_FR_PBL = D.COD_ESTADO) A ';

        OPEN c_aliq_st FOR v_sql;

        LOOP
            FETCH c_aliq_st
                BULK COLLECT INTO tab_aliq
                LIMIT 100;

            FOR i IN 1 .. tab_aliq.COUNT LOOP
                EXECUTE IMMEDIATE
                       'INSERT /*+APPEND*/ INTO '
                    || vp_nome_tabela_aliq
                    || ' VALUES ('
                    || tab_aliq ( i ).proc_id
                    || ','''
                    || tab_aliq ( i ).cod_produto
                    || ''','''
                    || tab_aliq ( i ).aliq_st
                    || ''')';
            END LOOP;

            tab_aliq.delete;

            EXIT WHEN c_aliq_st%NOTFOUND;
        END LOOP;

        COMMIT;

        CLOSE c_aliq_st;

        v_sql := 'CREATE INDEX PK_ALIQ_' || vp_proc_id || ' ON ' || vp_nome_tabela_aliq;
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || '   PROC_ID     ASC,';
        v_sql := v_sql || '   COD_PRODUTO ASC ';
        v_sql := v_sql || ' ) ';
        v_sql := v_sql || ' PCTFREE 10 ';

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX1_ALIQ_' || vp_proc_id || ' ON ' || vp_nome_tabela_aliq;
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || '   PROC_ID     ASC,';
        v_sql := v_sql || '   COD_PRODUTO ASC, ';
        v_sql := v_sql || '   ALIQ_ST     ASC ';
        v_sql := v_sql || ' ) ';
        v_sql := v_sql || ' PCTFREE 10 ';

        EXECUTE IMMEDIATE v_sql;

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_nome_tabela_aliq );
        loga ( '[' || vp_nome_tabela_aliq || '][LOAD END]'
             , FALSE );

        -------------------------------------------------------------------------------------
        vp_nome_tabela_pmc := 'DPSP_MSAF_PMC_' || vp_proc_id;

        v_sql := 'CREATE TABLE ' || vp_nome_tabela_pmc || ' AS ';
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || 'SELECT  /*+DRIVING_SITE(A)*/ ';
        v_sql := v_sql || '        B.PROC_ID, A.INV_ITEM_ID AS COD_PRODUTO, A.DSP_PMC AS VLR_PMC ';
        v_sql :=
            v_sql || 'FROM (SELECT A.SETID, A.INV_ITEM_ID, A.DSP_ALIQ_ICMS_ID, A.UNIT_OF_MEASURE, A.EFFDT, A.DSP_PMC ';
        v_sql := v_sql || '      FROM (';
        v_sql :=
               v_sql
            || '             SELECT A.SETID, A.INV_ITEM_ID, A.DSP_ALIQ_ICMS_ID, A.UNIT_OF_MEASURE, A.EFFDT, A.DSP_PMC, ';
        v_sql :=
               v_sql
            || '                    RANK() OVER( PARTITION BY A.SETID, A.INV_ITEM_ID, A.DSP_ALIQ_ICMS_ID, A.UNIT_OF_MEASURE ';
        v_sql := v_sql || '                                 ORDER BY A.EFFDT DESC) RANK ';
        v_sql := v_sql || '             FROM MSAFI.PS_DSP_PRECO_ITEM A ';
        v_sql := v_sql || '            ) A ';
        v_sql := v_sql || '      WHERE A.RANK = 1) A, ';
        v_sql := v_sql || vp_nome_tabela_aliq || ' B ';
        v_sql := v_sql || ' WHERE A.SETID            = ''GERAL'' ';
        v_sql := v_sql || '   AND B.PROC_ID          = ' || vp_proc_id;
        v_sql := v_sql || '   AND A.INV_ITEM_ID      = B.COD_PRODUTO ';
        v_sql := v_sql || '   AND A.DSP_ALIQ_ICMS_ID = B.ALIQ_ST ';
        v_sql := v_sql || '   AND A.UNIT_OF_MEASURE  = ''UN'' ) ';

        EXECUTE IMMEDIATE v_sql;

        COMMIT;

        v_sql := 'CREATE INDEX PK_PMC_' || vp_proc_id || ' ON ' || vp_nome_tabela_pmc;
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || '   PROC_ID     ASC, ';
        v_sql := v_sql || '   COD_PRODUTO ASC ';
        v_sql := v_sql || ' ) ';
        v_sql := v_sql || ' PCTFREE 10 ';

        EXECUTE IMMEDIATE v_sql;

        COMMIT;

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_nome_tabela_pmc );
        save_tmp_control ( vp_proc_id
                         , vp_nome_tabela_pmc );
        loga ( '[' || vp_nome_tabela_pmc || '][LOAD END]'
             , FALSE );
    END;

    PROCEDURE create_perdas_tmp_tbl ( vp_proc_instance IN NUMBER
                                    , vp_tab_perdas_tmp   OUT VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 4000 );
    BEGIN
        vp_tab_perdas_tmp := 'DPSP_PERDAS_' || vp_proc_instance;

        v_sql := 'CREATE TABLE ' || vp_tab_perdas_tmp || ' ( ';
        v_sql := v_sql || 'COD_EMPRESA           VARCHAR2(3 BYTE), ';
        v_sql := v_sql || 'COD_ESTAB             VARCHAR2(6 BYTE), ';
        v_sql := v_sql || 'DATA_INV              DATE, ';
        v_sql := v_sql || 'COD_PRODUTO           VARCHAR2(35 BYTE), ';
        v_sql := v_sql || 'DESCRICAO             VARCHAR2(50), ';
        v_sql := v_sql || 'QTD_AJUSTE            NUMBER(15,2), ';
        v_sql := v_sql || 'CNPJ_EMITENTE         VARCHAR2(14), ';
        v_sql := v_sql || 'RAZAO_SOCIAL_EMI      VARCHAR2(100), ';
        ---
        v_sql := v_sql || 'COD_ESTAB_E           VARCHAR2(6 BYTE), ';
        v_sql := v_sql || 'DATA_FISCAL_E         DATE, ';
        v_sql := v_sql || 'MOVTO_E_S_E           VARCHAR2(1 BYTE), ';
        v_sql := v_sql || 'NORM_DEV_E            VARCHAR2(1 BYTE), ';
        v_sql := v_sql || 'IDENT_DOCTO_E         VARCHAR2(12 BYTE), ';
        v_sql := v_sql || 'IDENT_FIS_JUR_E       VARCHAR2(12 BYTE), ';
        v_sql := v_sql || 'SUB_SERIE_DOCFIS_E    VARCHAR2(2 BYTE), ';
        v_sql := v_sql || 'DISCRI_ITEM_E         VARCHAR2(46 BYTE), ';
        v_sql := v_sql || 'DATA_EMISSAO_E        DATE, ';
        v_sql := v_sql || 'NUM_DOCFIS_E          VARCHAR2(12 BYTE), ';
        v_sql := v_sql || 'SERIE_DOCFIS_E        VARCHAR2(3 BYTE), ';
        v_sql := v_sql || 'NUM_ITEM_E            NUMBER(5), ';
        v_sql := v_sql || 'COD_FIS_JUR_E         VARCHAR2(14 BYTE), ';
        v_sql := v_sql || 'CPF_CGC_E             VARCHAR2(14 BYTE), ';
        v_sql := v_sql || 'RAZAO_SOCIAL_E        VARCHAR2(100), ';
        v_sql := v_sql || 'COD_NBM_E             VARCHAR2(10 BYTE), ';
        v_sql := v_sql || 'COD_CFO_E             VARCHAR2(4 BYTE), ';
        v_sql := v_sql || 'COD_NATUREZA_OP_E     VARCHAR2(3 BYTE), ';
        v_sql := v_sql || 'COD_PRODUTO_E         VARCHAR2(35 BYTE), ';
        v_sql := v_sql || 'VLR_CONTAB_ITEM_E     NUMBER(17,4), ';
        v_sql := v_sql || 'QUANTIDADE_E          NUMBER(12,4), ';
        v_sql := v_sql || 'VLR_UNIT_E            NUMBER(17,4), ';
        v_sql := v_sql || 'COD_SITUACAO_A_E      VARCHAR2(2 BYTE), ';
        v_sql := v_sql || 'COD_SITUACAO_B_E      VARCHAR2(2 BYTE), ';
        v_sql := v_sql || 'COD_ESTADO_E          VARCHAR2(2 BYTE), ';
        v_sql := v_sql || 'NUM_CONTROLE_DOCTO_E  VARCHAR2(12 BYTE), ';
        v_sql := v_sql || 'NUM_AUTENTIC_NFE_E    VARCHAR2(80 BYTE), ';
        v_sql := v_sql || 'BASE_ICMS_UNIT_E      NUMBER(17,4), ';
        v_sql := v_sql || 'VLR_ICMS_UNIT_E       NUMBER(17,4), ';
        v_sql := v_sql || 'ALIQ_ICMS_E           NUMBER(17,4), ';
        v_sql := v_sql || 'BASE_ST_UNIT_E        NUMBER(17,4), ';
        v_sql := v_sql || 'VLR_ICMS_ST_UNIT_E    NUMBER(17,4), ';
        v_sql := v_sql || 'STAT_LIBER_CNTR       VARCHAR2(10 BYTE), ';
        v_sql := v_sql || 'ID_ALIQ_ST            VARCHAR2(10 BYTE), ';
        v_sql := v_sql || 'VLR_PMC               NUMBER(17,4), ';
        v_sql := v_sql || 'TOTAL_ICMS            NUMBER(17,4), ';
        v_sql := v_sql || 'TOTAL_ICMS_ST         NUMBER(17,4), ';
        v_sql := v_sql || 'LISTA_PRODUTO         VARCHAR2(10), ';
        v_sql := v_sql || 'CST_PIS               VARCHAR2(2), ';
        v_sql := v_sql || 'CST_COFINS            VARCHAR2(2), ';
        v_sql := v_sql || 'ESTORNO_PIS_E         NUMBER(12,4), ';
        v_sql := v_sql || 'ESTORNO_COFINS_E      NUMBER(12,4), ';
        v_sql := v_sql || 'ESTORNO_PIS_S         NUMBER(12,4), ';
        v_sql := v_sql || 'ESTORNO_COFINS_S      NUMBER(12,4) ) ';
        v_sql := v_sql || 'PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE UNIQUE INDEX PK_PERDAS_' || vp_proc_instance || ' ON ' || vp_tab_perdas_tmp || ' ';
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || ' COD_EMPRESA ASC, ';
        v_sql := v_sql || ' COD_ESTAB   ASC, ';
        v_sql := v_sql || ' DATA_INV    ASC, ';
        v_sql := v_sql || ' COD_PRODUTO ASC ';
        v_sql := v_sql || ' ) ';
        v_sql := v_sql || 'PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        ---
        save_tmp_control ( vp_proc_instance
                         , vp_tab_perdas_tmp );
    END;

    PROCEDURE get_entradas_cd ( vp_proc_id IN NUMBER
                              , vp_filial IN VARCHAR2
                              , vp_cd IN VARCHAR2
                              , vp_data_ini IN DATE
                              , vp_data_fim IN DATE
                              , vp_tab_perdas_ent_c IN VARCHAR2
                              , vp_tab_perdas_inv IN VARCHAR2
                              , vp_tab_perdas_tmp IN VARCHAR2 )
    IS
        v_sql VARCHAR ( 4000 );
    BEGIN
        v_sql := 'INSERT /*+APPEND*/ INTO ' || vp_tab_perdas_tmp || ' ( ';
        v_sql := v_sql || ' SELECT /*+DRIVING_SITE(PS)*/ ';
        v_sql := v_sql || ' ''' || mcod_empresa || ''', ';
        v_sql := v_sql || ' A.COD_ESTAB   , ';
        v_sql := v_sql || ' A.DATA_INV    , ';
        v_sql := v_sql || ' A.COD_PRODUTO , ';
        v_sql := v_sql || ' B.DESCRICAO   , ';
        v_sql := v_sql || ' A.QTD_AJUSTE  , ';
        v_sql := v_sql || ' C.CGC         , ';
        v_sql := v_sql || ' C.RAZAO_SOCIAL, ';
        ---
        v_sql := v_sql || ' B.COD_ESTAB_E         , ';
        v_sql := v_sql || ' B.DATA_FISCAL_E       , ';
        v_sql := v_sql || ' B.MOVTO_E_S_E         , ';
        v_sql := v_sql || ' B.NORM_DEV_E          , ';
        v_sql := v_sql || ' B.IDENT_DOCTO_E       , ';
        v_sql := v_sql || ' B.IDENT_FIS_JUR_E     , ';
        v_sql := v_sql || ' B.SUB_SERIE_DOCFIS_E  , ';
        v_sql := v_sql || ' B.DISCRI_ITEM_E       , ';
        v_sql := v_sql || ' B.DATA_EMISSAO_E      , ';
        v_sql := v_sql || ' B.NUM_DOCFIS_E        , ';
        v_sql := v_sql || ' B.SERIE_DOCFIS_E      , ';
        v_sql := v_sql || ' B.NUM_ITEM_E          , ';
        v_sql := v_sql || ' B.COD_FIS_JUR_E       , ';
        v_sql := v_sql || ' B.CPF_CGC_E           , ';
        v_sql := v_sql || ' B.RAZAO_SOCIAL_E      , ';
        v_sql := v_sql || ' B.COD_NBM_E           , ';
        v_sql := v_sql || ' B.COD_CFO_E           , ';
        v_sql := v_sql || ' B.COD_NATUREZA_OP_E   , ';
        v_sql := v_sql || ' B.COD_PRODUTO_E       , ';
        v_sql := v_sql || ' B.VLR_CONTAB_ITEM_E   , ';
        v_sql := v_sql || ' B.QUANTIDADE_E        , ';
        v_sql := v_sql || ' B.VLR_UNIT_E          , ';
        v_sql := v_sql || ' B.COD_SITUACAO_A_E    , ';
        v_sql := v_sql || ' B.COD_SITUACAO_B_E    , ';
        v_sql := v_sql || ' B.COD_ESTADO_E        , ';
        v_sql := v_sql || ' B.NUM_CONTROLE_DOCTO_E, ';
        v_sql := v_sql || ' B.NUM_AUTENTIC_NFE_E  , ';
        v_sql := v_sql || ' TRUNC(B.BASE_ICMS_UNIT_E/B.QUANTIDADE_E,4) AS BASE_ICMS_UNIT_E, ';
        v_sql := v_sql || ' TRUNC(B.VLR_ICMS_UNIT_E/B.QUANTIDADE_E,4) AS VLR_ICMS_UNIT_E, ';
        v_sql := v_sql || ' B.ALIQ_ICMS_E         , ';
        v_sql := v_sql || ' TRUNC(B.BASE_ST_UNIT_E/B.QUANTIDADE_E,4) AS BASE_ST_UNIT_E, ';
        v_sql := v_sql || ' TRUNC(B.VLR_ICMS_ST_UNIT_E/B.QUANTIDADE_E,4) AS VLR_ICMS_ST_UNIT_E, ';
        v_sql := v_sql || ' DECODE(PS.LIBER_CNTR_DSP,''C'',''CONTROLADO'',''L'',''LIBERADO'',''OUTRO''), ';
        v_sql := v_sql || ' B.ID_ALIQ_ST          , ';
        v_sql := v_sql || ' B.VLR_PMC             , ';
        v_sql :=
               v_sql
            || ' DECODE(B.COD_NATUREZA_OP_E, ''REV'', (-1)*TRUNC(TRUNC(B.VLR_ICMS_UNIT_E/B.QUANTIDADE_E,4)*A.QTD_AJUSTE,4), 0), ';
        v_sql := v_sql || ' (-1)*TRUNC(TRUNC(B.VLR_ICMS_ST_UNIT_E/B.QUANTIDADE_E,4)*A.QTD_AJUSTE,4), ';
        v_sql := v_sql || ' DECODE(LI.LISTA,''P'',''POSITIVA'',''N'',''NEGATIVA'',''O'',''NEUTRA'',''-''), ';
        v_sql := v_sql || ' B.CST_PIS             , ';
        v_sql := v_sql || ' B.CST_COFINS          , ';
        v_sql := v_sql || ' DECODE(LI.LISTA, ''O'', B.ESTORNO_PIS_E, 0),    ';
        v_sql := v_sql || ' DECODE(LI.LISTA, ''O'', B.ESTORNO_COFINS_E, 0), ';
        v_sql := v_sql || ' DECODE(LI.LISTA, ''O'', (-1)*TRUNC(A.QTD_AJUSTE*B.ESTORNO_PIS_E,4), 0), ';
        v_sql := v_sql || ' DECODE(LI.LISTA, ''O'', (-1)*TRUNC(A.QTD_AJUSTE*B.ESTORNO_COFINS_E,4), 0) ';
        ---
        v_sql := v_sql || ' FROM ' || vp_tab_perdas_inv || ' A, ';
        v_sql := v_sql || '      ' || vp_tab_perdas_ent_c || ' B, ';
        v_sql := v_sql || '      ESTABELECIMENTO C, ';
        v_sql :=
               v_sql
            || '      (SELECT SETID, INV_ITEM_ID, LIBER_CNTR_DSP FROM MSAFI.PS_ATRB_OPER_DSP WHERE SETID = ''GERAL'') PS, ';
        v_sql := v_sql || '      MSAF.DPSP_PS_LISTA LI ';
        ---
        v_sql := v_sql || ' WHERE A.COD_PRODUTO      = B.COD_PRODUTO_E ';
        v_sql := v_sql || '   AND A.DATA_INV         = B.DATA_INV_S ';
        v_sql := v_sql || '   AND A.COD_ESTAB        = C.COD_ESTAB ';
        v_sql := v_sql || '   AND MSAFI.DPSP.EMPRESA = C.COD_EMPRESA ';
        v_sql := v_sql || '   AND A.COD_PRODUTO      = PS.INV_ITEM_ID (+) ';
        v_sql := v_sql || '   AND A.PROC_ID          = ' || vp_proc_id || ' ';
        v_sql := v_sql || '   AND B.COD_ESTAB_E      = ''' || vp_cd || ''' ';
        v_sql := v_sql || '   AND A.COD_ESTAB        = ''' || vp_filial || ''' ';
        v_sql := v_sql || '   AND LI.COD_PRODUTO     = B.COD_PRODUTO_E ';
        v_sql := v_sql || '   AND LI.EFFDT           = (SELECT MAX(LI2.EFFDT) ';
        v_sql := v_sql || '                             FROM MSAF.DPSP_PS_LISTA LI2 ';
        v_sql := v_sql || '                             WHERE LI2.COD_PRODUTO = LI.COD_PRODUTO ';
        v_sql := v_sql || '                               AND LI2.EFFDT <= B.DATA_FISCAL_E) ';
        v_sql := v_sql || '   AND NOT EXISTS (SELECT ''Y'' ';
        v_sql := v_sql || '              FROM ' || vp_tab_perdas_tmp || ' C ';
        v_sql := v_sql || '              WHERE C.COD_EMPRESA  = ''' || mcod_empresa || ''' ';
        v_sql := v_sql || '              AND C.COD_ESTAB    = A.COD_ESTAB ';
        v_sql := v_sql || '              AND C.COD_PRODUTO  = A.COD_PRODUTO ';
        v_sql := v_sql || '              AND C.DATA_INV     = A.DATA_INV) ) ';

        BEGIN
            EXECUTE IMMEDIATE v_sql;

            COMMIT;
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
                ---
                raise_application_error ( -20007
                                        , '!ERRO INSERT GET_ENTRADAS_CD!' );
        END;

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_tab_perdas_tmp );
        loga ( '[ENT CD][' || vp_cd || ']-[FILIAL][' || vp_filial || ']'
             , FALSE );
    END; --GET_ENTRADAS_CD

    PROCEDURE get_entradas_filial ( vp_proc_id IN NUMBER
                                  , vp_filial IN VARCHAR2
                                  , vp_cd IN VARCHAR2
                                  , vp_data_ini IN DATE
                                  , vp_data_fim IN DATE
                                  , vp_tab_perdas_ent_f IN VARCHAR2
                                  , vp_tab_perdas_inv IN VARCHAR2
                                  , vp_tab_perdas_tmp IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 4000 );
    BEGIN
        v_sql := 'INSERT /*+APPEND*/ INTO ' || vp_tab_perdas_tmp || ' ( ';
        v_sql := v_sql || ' SELECT /*+DRIVING_SITE(PS)*/ ';
        v_sql := v_sql || ' ''' || mcod_empresa || ''', ';
        v_sql := v_sql || ' A.COD_ESTAB   , ';
        v_sql := v_sql || ' A.DATA_INV    , ';
        v_sql := v_sql || ' A.COD_PRODUTO , ';
        v_sql := v_sql || ' B.DESCRICAO   , ';
        v_sql := v_sql || ' A.QTD_AJUSTE  , ';
        v_sql := v_sql || ' C.CGC         , ';
        v_sql := v_sql || ' C.RAZAO_SOCIAL, ';
        ---
        v_sql := v_sql || ' B.COD_ESTAB_E         , ';
        v_sql := v_sql || ' B.DATA_FISCAL_E       , ';
        v_sql := v_sql || ' B.MOVTO_E_S_E         , ';
        v_sql := v_sql || ' B.NORM_DEV_E          , ';
        v_sql := v_sql || ' B.IDENT_DOCTO_E       , ';
        v_sql := v_sql || ' B.IDENT_FIS_JUR_E     , ';
        v_sql := v_sql || ' B.SUB_SERIE_DOCFIS_E  , ';
        v_sql := v_sql || ' B.DISCRI_ITEM_E       , ';
        v_sql := v_sql || ' B.DATA_EMISSAO_E      , ';
        v_sql := v_sql || ' B.NUM_DOCFIS_E        , ';
        v_sql := v_sql || ' B.SERIE_DOCFIS_E      , ';
        v_sql := v_sql || ' B.NUM_ITEM_E          , ';
        v_sql := v_sql || ' B.COD_FIS_JUR_E       , ';
        v_sql := v_sql || ' B.CPF_CGC_E           , ';
        v_sql := v_sql || ' B.RAZAO_SOCIAL_E      , ';
        v_sql := v_sql || ' B.COD_NBM_E           , ';
        v_sql := v_sql || ' B.COD_CFO_E           , ';
        v_sql := v_sql || ' B.COD_NATUREZA_OP_E   , ';
        v_sql := v_sql || ' B.COD_PRODUTO_E       , ';
        v_sql := v_sql || ' B.VLR_CONTAB_ITEM_E   , ';
        v_sql := v_sql || ' B.QUANTIDADE_E        , ';
        v_sql := v_sql || ' B.VLR_UNIT_E          , ';
        v_sql := v_sql || ' B.COD_SITUACAO_A_E    , ';
        v_sql := v_sql || ' B.COD_SITUACAO_B_E    , ';
        v_sql := v_sql || ' B.COD_ESTADO_E        , ';
        v_sql := v_sql || ' B.NUM_CONTROLE_DOCTO_E, ';
        v_sql := v_sql || ' B.NUM_AUTENTIC_NFE_E  , ';
        v_sql := v_sql || ' TRUNC(B.BASE_ICMS_UNIT_E/B.QUANTIDADE_E,4) AS BASE_ICMS_UNIT_E, ';
        v_sql := v_sql || ' TRUNC(B.VLR_ICMS_UNIT_E/B.QUANTIDADE_E,4) AS VLR_ICMS_UNIT_E, ';
        v_sql := v_sql || ' B.ALIQ_ICMS_E         , ';
        v_sql := v_sql || ' TRUNC(B.BASE_ST_UNIT_E/B.QUANTIDADE_E,4) AS BASE_ST_UNIT_E, ';
        v_sql := v_sql || ' TRUNC(B.VLR_ICMS_ST_UNIT_E/B.QUANTIDADE_E,4) AS VLR_ICMS_ST_UNIT_E, ';
        v_sql := v_sql || ' DECODE(PS.LIBER_CNTR_DSP,''C'',''CONTROLADO'',''L'',''LIBERADO'',''OUTRO''), ';
        v_sql := v_sql || ' B.ID_ALIQ_ST          , ';
        v_sql := v_sql || ' B.VLR_PMC             , ';
        v_sql :=
               v_sql
            || ' DECODE(B.COD_NATUREZA_OP_E, ''REV'', (-1)*TRUNC(TRUNC(B.VLR_ICMS_UNIT_E/B.QUANTIDADE_E,4)*A.QTD_AJUSTE,4), 0), ';
        v_sql := v_sql || ' (-1)*TRUNC(TRUNC(B.VLR_ICMS_ST_UNIT_E/B.QUANTIDADE_E,4)*A.QTD_AJUSTE,4), ';
        v_sql := v_sql || ' DECODE(LI.LISTA,''P'',''POSITIVA'',''N'',''NEGATIVA'',''O'',''NEUTRA'',''-''), ';
        v_sql := v_sql || ' B.CST_PIS             , ';
        v_sql := v_sql || ' B.CST_COFINS          , ';
        v_sql := v_sql || ' DECODE(LI.LISTA, ''O'', B.ESTORNO_PIS_E, 0),    ';
        v_sql := v_sql || ' DECODE(LI.LISTA, ''O'', B.ESTORNO_COFINS_E, 0), ';
        v_sql := v_sql || ' DECODE(LI.LISTA, ''O'', (-1)*TRUNC(A.QTD_AJUSTE*B.ESTORNO_PIS_E,4), 0), ';
        v_sql := v_sql || ' DECODE(LI.LISTA, ''O'', (-1)*TRUNC(A.QTD_AJUSTE*B.ESTORNO_COFINS_E,4), 0) ';
        ---
        v_sql := v_sql || ' FROM ' || vp_tab_perdas_inv || ' A, ';
        v_sql := v_sql || '      ' || vp_tab_perdas_ent_f || ' B, ';
        v_sql := v_sql || '      ESTABELECIMENTO C, ';
        v_sql :=
               v_sql
            || '      (SELECT SETID, INV_ITEM_ID, LIBER_CNTR_DSP FROM MSAFI.PS_ATRB_OPER_DSP WHERE SETID = ''GERAL'') PS, ';
        v_sql := v_sql || '      MSAF.DPSP_PS_LISTA LI ';
        ---
        v_sql := v_sql || ' WHERE A.COD_PRODUTO      = B.COD_PRODUTO_E ';
        v_sql := v_sql || '   AND A.DATA_INV         = B.DATA_INV_S ';
        v_sql := v_sql || '   AND A.COD_ESTAB        = C.COD_ESTAB ';
        v_sql := v_sql || '   AND MSAFI.DPSP.EMPRESA = C.COD_EMPRESA ';
        v_sql := v_sql || '   AND A.COD_PRODUTO      = PS.INV_ITEM_ID (+) ';
        v_sql := v_sql || '   AND A.PROC_ID          = ' || vp_proc_id || ' ';
        v_sql := v_sql || '   AND A.COD_ESTAB        = B.COD_ESTAB_E ';
        v_sql := v_sql || '   AND A.COD_ESTAB        = ''' || vp_filial || ''' ';
        v_sql := v_sql || '   AND B.COD_FIS_JUR_E    = ''' || vp_cd || ''' ';
        v_sql := v_sql || '   AND LI.COD_PRODUTO     = B.COD_PRODUTO_E ';
        v_sql := v_sql || '   AND LI.EFFDT           = (SELECT MAX(LI2.EFFDT) ';
        v_sql := v_sql || '                             FROM MSAF.DPSP_PS_LISTA LI2 ';
        v_sql := v_sql || '                             WHERE LI2.COD_PRODUTO = LI.COD_PRODUTO ';
        v_sql := v_sql || '                               AND LI2.EFFDT <= B.DATA_FISCAL_E) ';
        v_sql := v_sql || '   AND NOT EXISTS (SELECT ''Y'' ';
        v_sql := v_sql || '              FROM ' || vp_tab_perdas_tmp || ' C ';
        v_sql := v_sql || '              WHERE C.COD_EMPRESA  = ''' || mcod_empresa || ''' ';
        v_sql := v_sql || '              AND C.COD_ESTAB    = A.COD_ESTAB ';
        v_sql := v_sql || '              AND C.COD_PRODUTO  = A.COD_PRODUTO ';
        v_sql := v_sql || '              AND C.DATA_INV     = A.DATA_INV) ) ';

        BEGIN
            EXECUTE IMMEDIATE v_sql;

            COMMIT;
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
                ---
                raise_application_error ( -20006
                                        , '!ERRO INSERT GET_ENTRADAS_FILIAL!' );
        END;

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_tab_perdas_tmp );
        loga ( '[ENT FILIAL][' || vp_filial || '] << [CD][' || vp_cd || ']'
             , FALSE );
    END; --GET_ENTRADAS_FILIAL

    PROCEDURE get_compra_direta ( vp_proc_id IN NUMBER
                                , vp_filial IN VARCHAR2
                                , vp_data_ini IN DATE
                                , vp_data_fim IN DATE
                                , vp_tab_perdas_ent_d IN VARCHAR2
                                , vp_tab_perdas_inv IN VARCHAR
                                , vp_tab_perdas_tmp IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 4000 );
    BEGIN
        v_sql := 'INSERT /*+APPEND*/ INTO ' || vp_tab_perdas_tmp || ' ( ';
        v_sql := v_sql || ' SELECT /*+DRIVING_SITE(PS)*/ ';
        v_sql := v_sql || ' ''' || mcod_empresa || ''', ';
        v_sql := v_sql || ' A.COD_ESTAB   , ';
        v_sql := v_sql || ' A.DATA_INV    , ';
        v_sql := v_sql || ' A.COD_PRODUTO , ';
        v_sql := v_sql || ' B.DESCRICAO   , ';
        v_sql := v_sql || ' A.QTD_AJUSTE  , ';
        v_sql := v_sql || ' C.CGC         , ';
        v_sql := v_sql || ' C.RAZAO_SOCIAL, ';
        ---
        v_sql := v_sql || ' B.COD_ESTAB_E         , ';
        v_sql := v_sql || ' B.DATA_FISCAL_E       , ';
        v_sql := v_sql || ' B.MOVTO_E_S_E         , ';
        v_sql := v_sql || ' B.NORM_DEV_E          , ';
        v_sql := v_sql || ' B.IDENT_DOCTO_E       , ';
        v_sql := v_sql || ' B.IDENT_FIS_JUR_E     , ';
        v_sql := v_sql || ' B.SUB_SERIE_DOCFIS_E  , ';
        v_sql := v_sql || ' B.DISCRI_ITEM_E       , ';
        v_sql := v_sql || ' B.DATA_EMISSAO_E      , ';
        v_sql := v_sql || ' B.NUM_DOCFIS_E        , ';
        v_sql := v_sql || ' B.SERIE_DOCFIS_E      , ';
        v_sql := v_sql || ' B.NUM_ITEM_E          , ';
        v_sql := v_sql || ' B.COD_FIS_JUR_E       , ';
        v_sql := v_sql || ' B.CPF_CGC_E           , ';
        v_sql := v_sql || ' B.RAZAO_SOCIAL_E      , ';
        v_sql := v_sql || ' B.COD_NBM_E           , ';
        v_sql := v_sql || ' B.COD_CFO_E           , ';
        v_sql := v_sql || ' B.COD_NATUREZA_OP_E   , ';
        v_sql := v_sql || ' B.COD_PRODUTO_E       , ';
        v_sql := v_sql || ' B.VLR_CONTAB_ITEM_E   , ';
        v_sql := v_sql || ' B.QUANTIDADE_E        , ';
        v_sql := v_sql || ' B.VLR_UNIT_E          , ';
        v_sql := v_sql || ' B.COD_SITUACAO_A_E    , ';
        v_sql := v_sql || ' B.COD_SITUACAO_B_E    , ';
        v_sql := v_sql || ' B.COD_ESTADO_E        , ';
        v_sql := v_sql || ' B.NUM_CONTROLE_DOCTO_E, ';
        v_sql := v_sql || ' B.NUM_AUTENTIC_NFE_E  , ';
        v_sql := v_sql || ' TRUNC(B.BASE_ICMS_UNIT_E/B.QUANTIDADE_E,4) AS BASE_ICMS_UNIT_E, ';
        v_sql := v_sql || ' TRUNC(B.VLR_ICMS_UNIT_E/B.QUANTIDADE_E,4) AS VLR_ICMS_UNIT_E, ';
        v_sql := v_sql || ' B.ALIQ_ICMS_E         , ';
        v_sql := v_sql || ' TRUNC(B.BASE_ST_UNIT_E/B.QUANTIDADE_E,4) AS BASE_ST_UNIT_E, ';
        v_sql := v_sql || ' TRUNC(B.VLR_ICMS_ST_UNIT_E/B.QUANTIDADE_E,4) AS VLR_ICMS_ST_UNIT_E, ';
        v_sql := v_sql || ' DECODE(PS.LIBER_CNTR_DSP,''C'',''CONTROLADO'',''L'',''LIBERADO'',''OUTRO''), ';
        v_sql := v_sql || ' B.ID_ALIQ_ST          , ';
        v_sql := v_sql || ' B.VLR_PMC             , ';
        v_sql :=
               v_sql
            || ' DECODE(B.COD_NATUREZA_OP_E, ''REV'', (-1)*TRUNC(TRUNC(B.VLR_ICMS_UNIT_E/B.QUANTIDADE_E,4)*A.QTD_AJUSTE,4), 0), ';
        v_sql := v_sql || ' (-1)*TRUNC(TRUNC(B.VLR_ICMS_ST_UNIT_E/B.QUANTIDADE_E,4)*A.QTD_AJUSTE,4), ';
        v_sql := v_sql || ' DECODE(LI.LISTA,''P'',''POSITIVA'',''N'',''NEGATIVA'',''O'',''NEUTRA'',''-''), ';
        v_sql := v_sql || ' B.CST_PIS             , ';
        v_sql := v_sql || ' B.CST_COFINS          , ';
        v_sql := v_sql || ' DECODE(LI.LISTA, ''O'', B.ESTORNO_PIS_E, 0),    ';
        v_sql := v_sql || ' DECODE(LI.LISTA, ''O'', B.ESTORNO_COFINS_E, 0), ';
        v_sql := v_sql || ' DECODE(LI.LISTA, ''O'', (-1)*TRUNC(A.QTD_AJUSTE*B.ESTORNO_PIS_E,4), 0), ';
        v_sql := v_sql || ' DECODE(LI.LISTA, ''O'', (-1)*TRUNC(A.QTD_AJUSTE*B.ESTORNO_COFINS_E,4), 0) ';
        ---
        v_sql := v_sql || ' FROM ' || vp_tab_perdas_inv || ' A, ';
        v_sql := v_sql || '      ' || vp_tab_perdas_ent_d || ' B, ';
        v_sql := v_sql || '      ESTABELECIMENTO C, ';
        v_sql :=
               v_sql
            || '      (SELECT SETID, INV_ITEM_ID, LIBER_CNTR_DSP FROM MSAFI.PS_ATRB_OPER_DSP WHERE SETID = ''GERAL'') PS, ';
        v_sql := v_sql || '      MSAF.DPSP_PS_LISTA LI ';
        ---
        v_sql := v_sql || ' WHERE A.COD_PRODUTO      = B.COD_PRODUTO_E ';
        v_sql := v_sql || '   AND A.DATA_INV         = B.DATA_INV_S ';
        v_sql := v_sql || '   AND A.COD_ESTAB        = C.COD_ESTAB ';
        v_sql := v_sql || '   AND MSAFI.DPSP.EMPRESA = C.COD_EMPRESA ';
        v_sql := v_sql || '   AND A.COD_PRODUTO      = PS.INV_ITEM_ID (+) ';
        v_sql := v_sql || '   AND A.PROC_ID          = ' || vp_proc_id || ' ';
        v_sql := v_sql || '   AND A.COD_ESTAB        = B.COD_ESTAB_E ';
        v_sql := v_sql || '   AND A.COD_ESTAB        = ''' || vp_filial || ''' ';
        v_sql := v_sql || '   AND LI.COD_PRODUTO     = B.COD_PRODUTO_E ';
        v_sql := v_sql || '   AND LI.EFFDT           = (SELECT MAX(LI2.EFFDT) ';
        v_sql := v_sql || '                             FROM MSAF.DPSP_PS_LISTA LI2 ';
        v_sql := v_sql || '                             WHERE LI2.COD_PRODUTO = LI.COD_PRODUTO ';
        v_sql := v_sql || '                               AND LI2.EFFDT <= B.DATA_FISCAL_E) ';
        v_sql := v_sql || '   AND NOT EXISTS (SELECT ''Y'' ';
        v_sql := v_sql || '              FROM ' || vp_tab_perdas_tmp || ' C ';
        v_sql := v_sql || '              WHERE C.COD_EMPRESA  = ''' || mcod_empresa || ''' ';
        v_sql := v_sql || '              AND C.COD_ESTAB    = A.COD_ESTAB ';
        v_sql := v_sql || '              AND C.COD_PRODUTO  = A.COD_PRODUTO ';
        v_sql := v_sql || '              AND C.DATA_INV     = A.DATA_INV) ) ';

        BEGIN
            EXECUTE IMMEDIATE v_sql;

            COMMIT;
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
                ---
                raise_application_error ( -20007
                                        , '!ERRO INSERT GET_COMPRA_DIRETA!' );
        END;

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_tab_perdas_tmp );
        loga ( '[C DIRETA][' || vp_filial || ']'
             , FALSE );
    END; --GET_COMPRA_DIRETA

    PROCEDURE get_entradas_filial_uf ( vp_proc_id IN NUMBER
                                     , vp_filial IN VARCHAR2
                                     , vp_data_ini IN DATE
                                     , vp_data_fim IN DATE
                                     , vp_tab_perdas_ent_m IN VARCHAR2
                                     , vp_tab_perdas_inv IN VARCHAR2
                                     , vp_tab_perdas_tmp IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 4000 );
    BEGIN
        v_sql := 'INSERT /*+APPEND*/ INTO ' || vp_tab_perdas_tmp || ' ( ';
        v_sql := v_sql || ' SELECT /*+DRIVING_SITE(PS)*/ ';
        v_sql := v_sql || ' ''' || mcod_empresa || ''', ';
        v_sql := v_sql || ' A.COD_ESTAB   , ';
        v_sql := v_sql || ' A.DATA_INV    , ';
        v_sql := v_sql || ' A.COD_PRODUTO , ';
        v_sql := v_sql || ' B.DESCRICAO   , ';
        v_sql := v_sql || ' A.QTD_AJUSTE  , ';
        v_sql := v_sql || ' C.CGC         , ';
        v_sql := v_sql || ' C.RAZAO_SOCIAL, ';
        ---
        v_sql := v_sql || ' B.COD_ESTAB_E         , ';
        v_sql := v_sql || ' B.DATA_FISCAL_E       , ';
        v_sql := v_sql || ' B.MOVTO_E_S_E         , ';
        v_sql := v_sql || ' B.NORM_DEV_E          , ';
        v_sql := v_sql || ' B.IDENT_DOCTO_E       , ';
        v_sql := v_sql || ' B.IDENT_FIS_JUR_E     , ';
        v_sql := v_sql || ' B.SUB_SERIE_DOCFIS_E  , ';
        v_sql := v_sql || ' B.DISCRI_ITEM_E       , ';
        v_sql := v_sql || ' B.DATA_EMISSAO_E      , ';
        v_sql := v_sql || ' B.NUM_DOCFIS_E        , ';
        v_sql := v_sql || ' B.SERIE_DOCFIS_E      , ';
        v_sql := v_sql || ' B.NUM_ITEM_E          , ';
        v_sql := v_sql || ' B.COD_FIS_JUR_E       , ';
        v_sql := v_sql || ' B.CPF_CGC_E           , ';
        v_sql := v_sql || ' B.RAZAO_SOCIAL_E      , ';
        v_sql := v_sql || ' B.COD_NBM_E           , ';
        v_sql := v_sql || ' B.COD_CFO_E           , ';
        v_sql := v_sql || ' B.COD_NATUREZA_OP_E   , ';
        v_sql := v_sql || ' B.COD_PRODUTO_E       , ';
        v_sql := v_sql || ' B.VLR_CONTAB_ITEM_E   , ';
        v_sql := v_sql || ' B.QUANTIDADE_E        , ';
        v_sql := v_sql || ' B.VLR_UNIT_E          , ';
        v_sql := v_sql || ' B.COD_SITUACAO_A_E    , ';
        v_sql := v_sql || ' B.COD_SITUACAO_B_E    , ';
        v_sql := v_sql || ' B.COD_ESTADO_E        , ';
        v_sql := v_sql || ' B.NUM_CONTROLE_DOCTO_E, ';
        v_sql := v_sql || ' B.NUM_AUTENTIC_NFE_E  , ';
        v_sql := v_sql || ' TRUNC(B.BASE_ICMS_UNIT_E/B.QUANTIDADE_E,4) AS BASE_ICMS_UNIT_E, ';
        v_sql := v_sql || ' TRUNC(B.VLR_ICMS_UNIT_E/B.QUANTIDADE_E,4) AS VLR_ICMS_UNIT_E, ';
        v_sql := v_sql || ' B.ALIQ_ICMS_E         , ';
        v_sql := v_sql || ' TRUNC(B.BASE_ST_UNIT_E/B.QUANTIDADE_E,4) AS BASE_ST_UNIT_E, ';
        v_sql := v_sql || ' TRUNC(B.VLR_ICMS_ST_UNIT_E/B.QUANTIDADE_E,4) AS VLR_ICMS_ST_UNIT_E, ';
        v_sql := v_sql || ' DECODE(PS.LIBER_CNTR_DSP,''C'',''CONTROLADO'',''L'',''LIBERADO'',''OUTRO''), ';
        v_sql := v_sql || ' B.ID_ALIQ_ST          , ';
        v_sql := v_sql || ' B.VLR_PMC             , ';
        v_sql :=
               v_sql
            || ' DECODE(B.COD_NATUREZA_OP_E, ''REV'', (-1)*TRUNC(TRUNC(B.VLR_ICMS_UNIT_E/B.QUANTIDADE_E,4)*A.QTD_AJUSTE,4), 0), ';
        v_sql := v_sql || ' (-1)*TRUNC(TRUNC(B.VLR_ICMS_ST_UNIT_E/B.QUANTIDADE_E,4)*A.QTD_AJUSTE,4), ';
        v_sql := v_sql || ' DECODE(LI.LISTA,''P'',''POSITIVA'',''N'',''NEGATIVA'',''O'',''NEUTRA'',''-''), ';
        v_sql := v_sql || ' B.CST_PIS             , ';
        v_sql := v_sql || ' B.CST_COFINS          , ';
        v_sql := v_sql || ' DECODE(LI.LISTA, ''O'', B.ESTORNO_PIS_E, 0),    ';
        v_sql := v_sql || ' DECODE(LI.LISTA, ''O'', B.ESTORNO_COFINS_E, 0), ';
        v_sql := v_sql || ' DECODE(LI.LISTA, ''O'', (-1)*TRUNC(A.QTD_AJUSTE*B.ESTORNO_PIS_E,4), 0), ';
        v_sql := v_sql || ' DECODE(LI.LISTA, ''O'', (-1)*TRUNC(A.QTD_AJUSTE*B.ESTORNO_COFINS_E,4), 0) ';
        ---
        v_sql := v_sql || ' FROM ' || vp_tab_perdas_inv || ' A, ';
        v_sql := v_sql || '      ' || vp_tab_perdas_ent_m || ' B, ';
        v_sql := v_sql || '      ESTABELECIMENTO C, ';
        v_sql :=
               v_sql
            || '      (SELECT SETID, INV_ITEM_ID, LIBER_CNTR_DSP FROM MSAFI.PS_ATRB_OPER_DSP WHERE SETID = ''GERAL'') PS, ';
        v_sql := v_sql || '      MSAF.DPSP_PS_LISTA LI ';
        ---
        v_sql := v_sql || ' WHERE A.COD_PRODUTO      = B.COD_PRODUTO_E ';
        v_sql := v_sql || '   AND A.DATA_INV         = B.DATA_INV_S ';
        v_sql := v_sql || '   AND A.COD_ESTAB        = B.COD_ESTAB_E ';
        v_sql := v_sql || '   AND A.COD_ESTAB        = C.COD_ESTAB ';
        v_sql := v_sql || '   AND MSAFI.DPSP.EMPRESA = C.COD_EMPRESA ';
        v_sql := v_sql || '   AND A.COD_PRODUTO      = PS.INV_ITEM_ID (+) ';
        v_sql := v_sql || '   AND A.PROC_ID          = ' || vp_proc_id || ' ';
        v_sql := v_sql || '   AND A.COD_ESTAB        = ''' || vp_filial || ''' ';
        v_sql := v_sql || '   AND LI.COD_PRODUTO     = B.COD_PRODUTO_E ';
        v_sql := v_sql || '   AND LI.EFFDT           = (SELECT MAX(LI2.EFFDT) ';
        v_sql := v_sql || '                             FROM MSAF.DPSP_PS_LISTA LI2 ';
        v_sql := v_sql || '                             WHERE LI2.COD_PRODUTO = LI.COD_PRODUTO ';
        v_sql := v_sql || '                               AND LI2.EFFDT <= B.DATA_FISCAL_E) ';
        v_sql := v_sql || '   AND NOT EXISTS (SELECT ''Y'' ';
        v_sql := v_sql || '              FROM ' || vp_tab_perdas_tmp || ' C ';
        v_sql := v_sql || '              WHERE C.COD_EMPRESA  = ''' || mcod_empresa || ''' ';
        v_sql := v_sql || '              AND C.COD_ESTAB    = A.COD_ESTAB ';
        v_sql := v_sql || '              AND C.COD_PRODUTO  = A.COD_PRODUTO ';
        v_sql := v_sql || '              AND C.DATA_INV     = A.DATA_INV) ) ';

        BEGIN
            EXECUTE IMMEDIATE v_sql;

            COMMIT;
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
                ---
                raise_application_error ( -20006
                                        , '!ERRO INSERT GET_ENTRADAS_FILIAL_UF!' );
        END;

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_tab_perdas_tmp );
        loga ( '[ENT FILIAL UF][' || vp_filial || ']'
             , FALSE );
    END; --GET_ENTRADAS_FILIAL_UF

    PROCEDURE get_sem_entrada ( vp_proc_id IN NUMBER
                              , vp_filial IN VARCHAR2
                              , vp_data_ini IN DATE
                              , vp_data_fim IN DATE
                              , vp_tab_perdas_inv IN VARCHAR2
                              , vp_tab_perdas_tmp IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 4000 );
    BEGIN
        v_sql := 'INSERT /*+APPEND*/ INTO ' || vp_tab_perdas_tmp || ' ( ';
        v_sql := v_sql || ' SELECT /*+DRIVING_SITE(PS)*/ ';
        v_sql := v_sql || ' ''' || mcod_empresa || ''', ';
        v_sql := v_sql || ' A.COD_ESTAB   , ';
        v_sql := v_sql || ' A.DATA_INV    , ';
        v_sql := v_sql || ' A.COD_PRODUTO , ';
        v_sql := v_sql || ' P.DESCRICAO   , '; ---B.DESCRICAO   , ';
        v_sql := v_sql || ' A.QTD_AJUSTE  , ';
        v_sql := v_sql || ' C.CGC         , ';
        v_sql := v_sql || ' C.RAZAO_SOCIAL, ';
        ---
        v_sql := v_sql || ' NULL, '; ---B.COD_ESTAB_E         , ';
        v_sql := v_sql || ' NULL, '; ---B.DATA_FISCAL_E       , ';
        v_sql := v_sql || ' NULL, '; ---B.MOVTO_E_S_E         , ';
        v_sql := v_sql || ' NULL, '; ---B.NORM_DEV_E          , ';
        v_sql := v_sql || ' NULL, '; ---B.IDENT_DOCTO_E       , ';
        v_sql := v_sql || ' NULL, '; ---B.IDENT_FIS_JUR_E     , ';
        v_sql := v_sql || ' NULL, '; ---B.SERIE_DOCFIS_E      , ';
        v_sql := v_sql || ' NULL, '; ---B.SUB_SERIE_DOCFIS_E  , ';
        v_sql := v_sql || ' NULL, '; ---B.DISCRI_ITEM_E       , ';
        v_sql := v_sql || ' NULL, '; ---B.NUM_ITEM_E          , ';
        v_sql := v_sql || ' NULL, '; ---B.DATA_EMISSAO_E      , ';
        v_sql := v_sql || ' NULL, '; ---B.NUM_DOCFIS_E        , ';
        v_sql := v_sql || ' NULL, '; ---B.COD_FIS_JUR_E       , ';
        v_sql := v_sql || ' NULL, '; ---B.CPF_CGC_E           , ';
        v_sql := v_sql || ' NULL, '; ---B.RAZAO_SOCIAL_E      , ';
        v_sql := v_sql || ' NULL, '; ---B.COD_NBM_E           , ';
        v_sql := v_sql || ' NULL, '; ---B.COD_CFO_E           , ';
        v_sql := v_sql || ' NULL, '; ---B.COD_NATUREZA_OP_E   , ';
        v_sql := v_sql || ' NULL, '; ---B.COD_PRODUTO_E       , ';
        v_sql := v_sql || ' NULL, '; ---B.VLR_CONTAB_ITEM_E   , ';
        v_sql := v_sql || ' NULL, '; ---B.QUANTIDADE_E        , ';
        v_sql := v_sql || ' NULL, '; ---B.VLR_UNIT_E          , ';
        v_sql := v_sql || ' NULL, '; ---B.COD_SITUACAO_A_E    , ';
        v_sql := v_sql || ' NULL, '; ---B.COD_SITUACAO_B_E    , ';
        v_sql := v_sql || ' NULL, '; ---B.COD_ESTADO_E        , ';
        v_sql := v_sql || ' NULL, '; ---B.NUM_CONTROLE_DOCTO_E, ';
        v_sql := v_sql || ' NULL, '; ---B.NUM_AUTENTIC_NFE_E  , ';
        v_sql := v_sql || ' NULL, '; ---B.BASE_ICMS_UNIT_E    , ';
        v_sql := v_sql || ' NULL, '; ---B.VLR_ICMS_UNIT_E     , ';
        v_sql := v_sql || ' NULL, '; ---B.ALIQ_ICMS_E         , ';
        v_sql := v_sql || ' NULL, '; ---B.BASE_ST_UNIT_E      , ';
        v_sql := v_sql || ' NULL, '; ---B.VLR_ICMS_ST_UNIT_E  , ';
        v_sql := v_sql || ' DECODE(PS.LIBER_CNTR_DSP,''C'',''CONTROLADO'',''L'',''LIBERADO'',''OUTRO''), ';
        v_sql := v_sql || ' NULL, '; ---B.ID_ALIQ_ST          , ';
        v_sql := v_sql || ' NULL, '; ---B.VLR_PMC             , ';
        v_sql := v_sql || ' NULL, '; ---B.TOTAL_ICMS          , ';
        v_sql := v_sql || ' NULL, '; ---B.TOTAL_ICMS_ST       , ';
        v_sql := v_sql || ' NULL, '; ---B.LISTA_PRODUTO       , ';
        v_sql := v_sql || ' NULL, '; ---B.CST_PIS             , ';
        v_sql := v_sql || ' NULL, '; ---B.CST_COFINS          , ';
        v_sql := v_sql || ' NULL, '; ---B.ESTORNO_PIS_E       , ';
        v_sql := v_sql || ' NULL, '; ---B.ESTORNO_COFINS_E    , ';
        v_sql := v_sql || ' NULL, '; ---B.ESTORNO_PIS_S       , ';
        v_sql := v_sql || ' NULL '; ---B.ESTORNO_COFINS_S      ';
        ---
        v_sql := v_sql || ' FROM ' || vp_tab_perdas_inv || ' A, ';
        v_sql := v_sql || '      ESTABELECIMENTO C, ';
        v_sql :=
               v_sql
            || '      (SELECT SETID, INV_ITEM_ID, LIBER_CNTR_DSP FROM MSAFI.PS_ATRB_OPER_DSP WHERE SETID = ''GERAL'') PS, ';
        v_sql := v_sql || '      MSAF.X2013_PRODUTO P ';
        ---
        v_sql := v_sql || ' WHERE A.COD_ESTAB        = C.COD_ESTAB ';
        v_sql := v_sql || '   AND MSAFI.DPSP.EMPRESA = C.COD_EMPRESA ';
        v_sql := v_sql || '   AND A.COD_PRODUTO      = PS.INV_ITEM_ID (+) ';
        v_sql := v_sql || '   AND A.PROC_ID       = ' || vp_proc_id || ' ';
        v_sql := v_sql || '   AND A.COD_ESTAB        = ''' || vp_filial || ''' ';
        v_sql := v_sql || '   AND P.COD_PRODUTO  = A.COD_PRODUTO ';
        v_sql := v_sql || '   AND P.VALID_PRODUTO = (SELECT MAX(PP.VALID_PRODUTO) ';
        v_sql := v_sql || '                          FROM MSAF.X2013_PRODUTO PP ';
        v_sql := v_sql || '                          WHERE PP.COD_PRODUTO = P.COD_PRODUTO ';
        v_sql := v_sql || '                            AND PP.VALID_PRODUTO <= A.DATA_INV) ';
        v_sql := v_sql || '   AND NOT EXISTS (SELECT ''Y'' ';
        v_sql := v_sql || '              FROM ' || vp_tab_perdas_tmp || ' C ';
        v_sql := v_sql || '              WHERE C.COD_EMPRESA  = ''' || mcod_empresa || ''' ';
        v_sql := v_sql || '              AND C.COD_ESTAB    = A.COD_ESTAB ';
        v_sql := v_sql || '              AND C.COD_PRODUTO  = A.COD_PRODUTO ';
        v_sql := v_sql || '              AND C.DATA_INV     = A.DATA_INV) ) ';

        BEGIN
            EXECUTE IMMEDIATE v_sql;

            COMMIT;
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
                ---
                raise_application_error ( -20007
                                        , '!ERRO INSERT GET_SEM_ENTRADA!' );
        END;

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_tab_perdas_tmp );
        loga ( '[SEM ENT][' || vp_filial || ']'
             , FALSE );
    END; --GET_SEM_ENTRADA

    PROCEDURE delete_tbl ( p_i_cod_estab IN VARCHAR2
                         , p_i_data_ini IN DATE
                         , p_i_data_fim IN DATE )
    IS
        v_sql VARCHAR2 ( 1000 );
    BEGIN
        v_sql := 'DELETE MSAFI.DPSP_MSAF_PERDAS_UF ';
        v_sql := v_sql || 'WHERE COD_EMPRESA  = ''' || mcod_empresa || ''' ';
        v_sql := v_sql || '  AND COD_ESTAB    = ''' || p_i_cod_estab || ''' ';
        v_sql :=
               v_sql
            || '  AND DATA_INV     BETWEEN TO_DATE('''
            || TO_CHAR ( p_i_data_ini
                       , 'DDMMYYYY' )
            || ''',''DDMMYYYY'') AND TO_DATE('''
            || TO_CHAR ( p_i_data_fim
                       , 'DDMMYYYY' )
            || ''',''DDMMYYYY'') ';

        EXECUTE IMMEDIATE v_sql;

        loga ( '[DEL PERDAS]:' || SQL%ROWCOUNT
             , FALSE );
        COMMIT;
    END;

    PROCEDURE merge_pmc_aliq ( vp_proc_id IN VARCHAR2
                             , v_tab_perdas_ent_c IN VARCHAR2
                             , v_tab_perdas_ent_f IN VARCHAR2
                             , v_tab_perdas_ent_d IN VARCHAR2
                             , v_tab_perdas_ent_m IN VARCHAR2
                             , v_nome_tabela_aliq IN VARCHAR2
                             , v_nome_tabela_pmc IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 3000 );
        v_sql1 VARCHAR2 ( 100 );
    BEGIN
        v_sql := 'USING ( ';
        v_sql := v_sql || '  SELECT AL.PROC_ID, AL.COD_PRODUTO, AL.ALIQ_ST, NVL(PM.VLR_PMC,0) AS VLR_PMC ';
        v_sql := v_sql || '  FROM ' || v_nome_tabela_aliq || ' AL, ';
        v_sql := v_sql || '       ' || v_nome_tabela_pmc || ' PM ';
        v_sql := v_sql || '  WHERE AL.PROC_ID = PM.PROC_ID (+) ';
        v_sql := v_sql || '    AND AL.COD_PRODUTO = PM.COD_PRODUTO (+) ';
        v_sql := v_sql || ') B ';
        v_sql := v_sql || 'ON ( ';
        v_sql := v_sql || '  A.PROC_ID = B.PROC_ID ';
        v_sql := v_sql || '  AND A.COD_PRODUTO_E = B.COD_PRODUTO ';
        v_sql := v_sql || ') WHEN MATCHED THEN ';
        v_sql := v_sql || '  UPDATE SET A.ID_ALIQ_ST = B.ALIQ_ST, ';
        v_sql := v_sql || '             A.VLR_PMC = B.VLR_PMC ';

        v_sql1 := 'MERGE INTO ' || v_tab_perdas_ent_c || ' A ';

        EXECUTE IMMEDIATE v_sql1 || v_sql;

        COMMIT;

        v_sql1 := 'MERGE INTO ' || v_tab_perdas_ent_f || ' A ';

        EXECUTE IMMEDIATE v_sql1 || v_sql;

        COMMIT;

        v_sql1 := 'MERGE INTO ' || v_tab_perdas_ent_d || ' A ';

        EXECUTE IMMEDIATE v_sql1 || v_sql;

        COMMIT;

        v_sql1 := 'MERGE INTO ' || v_tab_perdas_ent_m || ' A ';

        EXECUTE IMMEDIATE v_sql1 || v_sql;

        COMMIT;

        loga ( '[MERGE ENT][END]'
             , FALSE );
    END;

    PROCEDURE drop_old_tmp ( vp_proc_instance IN NUMBER )
    IS
        CURSOR c_old_tmp
        IS
            SELECT table_name
              FROM msafi.dpsp_msaf_tmp_control
             WHERE TRUNC ( ( ( ( 86400 * ( SYSDATE - dttm_created ) ) / 60 ) / 60 ) / 24 ) >= 2;

        l_table_name VARCHAR2 ( 30 );
    BEGIN
        ---> Dropar tabelas TMP que tiveram processo interrompido a mais de 2 dias
        OPEN c_old_tmp;

        LOOP
            FETCH c_old_tmp
                INTO l_table_name;

            BEGIN
                EXECUTE IMMEDIATE 'DROP TABLE ' || l_table_name;
            EXCEPTION
                WHEN OTHERS THEN
                    NULL;
            END;

            ---
            DELETE msafi.dpsp_msaf_tmp_control
             WHERE table_name = l_table_name;

            COMMIT;

            EXIT WHEN c_old_tmp%NOTFOUND;
        END LOOP;

        COMMIT;

        CLOSE c_old_tmp;
    END;

    PROCEDURE delete_temp_tbl ( vp_proc_id IN NUMBER )
    IS
    BEGIN
        FOR temp_table IN ( SELECT table_name
                              FROM msafi.dpsp_msaf_tmp_control
                             WHERE proc_id = vp_proc_id ) LOOP
            BEGIN
                EXECUTE IMMEDIATE 'DROP TABLE ' || temp_table.table_name;
            EXCEPTION
                WHEN OTHERS THEN
                    loga ( temp_table.table_name || ' <'
                         , FALSE );
            END;

            DELETE msafi.dpsp_msaf_tmp_control
             WHERE proc_id = vp_proc_id
               AND table_name = temp_table.table_name;

            COMMIT;
        END LOOP;

        --- checar TMPs de processos interrompidos e dropar
        drop_old_tmp ( vp_proc_id );
    END; --PROCEDURE DELETE_TEMP_TBL

    PROCEDURE merge_lista ( v_tab_perdas_ent_c IN VARCHAR2
                          , v_tab_perdas_ent_f IN VARCHAR2
                          , v_tab_perdas_ent_d IN VARCHAR2
                          , v_tab_perdas_ent_m IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 4000 );
        v_sql1 VARCHAR2 ( 100 );
    BEGIN
        v_sql := 'USING ( ';
        v_sql := v_sql || '  SELECT LI.COD_PRODUTO, LI.LISTA, LI.EFFDT ';
        v_sql := v_sql || '  FROM MSAF.DPSP_PS_LISTA LI ';
        v_sql := v_sql || ') B ';
        v_sql := v_sql || 'ON ( ';
        v_sql := v_sql || '  A.COD_PRODUTO_E = B.COD_PRODUTO ';
        v_sql := v_sql || '  AND B.EFFDT = (SELECT MAX(BB.EFFDT) ';
        v_sql := v_sql || '                 FROM MSAF.DPSP_PS_LISTA BB ';
        v_sql := v_sql || '                 WHERE BB.COD_PRODUTO = B.COD_PRODUTO ';
        v_sql := v_sql || '                   AND BB.EFFDT <= A.DATA_FISCAL_E) ';
        v_sql := v_sql || ') WHEN MATCHED THEN ';
        v_sql :=
               v_sql
            || '  UPDATE SET A.LISTA_PRODUTO = DECODE(B.LISTA,''P'',''POSITIVA'',''N'',''NEGATIVA'',''O'',''NEUTRA'',''-'') ';

        v_sql1 := 'MERGE INTO ' || v_tab_perdas_ent_c || ' A ';

        EXECUTE IMMEDIATE v_sql1 || v_sql;

        COMMIT;
        loga ( '[MERGE LISTA CD][END]'
             , FALSE );

        v_sql1 := 'MERGE INTO ' || v_tab_perdas_ent_f || ' A ';

        EXECUTE IMMEDIATE v_sql1 || v_sql;

        COMMIT;
        loga ( '[MERGE LISTA FI][END]'
             , FALSE );

        v_sql1 := 'MERGE INTO ' || v_tab_perdas_ent_d || ' A ';

        EXECUTE IMMEDIATE v_sql1 || v_sql;

        COMMIT;
        loga ( '[MERGE LISTA COM][END]'
             , FALSE );

        v_sql1 := 'MERGE INTO ' || v_tab_perdas_ent_m || ' A ';

        EXECUTE IMMEDIATE v_sql1 || v_sql;

        COMMIT;
        loga ( '[MERGE LISTA UF][END]'
             , FALSE );
    END;

    PROCEDURE merge_xml ( vp_proc_id IN VARCHAR2
                        , v_tab_perdas_ent_c IN VARCHAR2
                        , v_tab_perdas_ent_f IN VARCHAR2
                        , v_tab_perdas_ent_d IN VARCHAR2
                        , v_tab_perdas_ent_m IN VARCHAR2
                        , vp_filiais IN VARCHAR2
                        , vp_origem1 IN VARCHAR2
                        , vp_origem2 IN VARCHAR2
                        , vp_origem3 IN VARCHAR2
                        , vp_origem4 IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 4000 );
        v_sql1 VARCHAR2 ( 100 );
        v_tab_xml VARCHAR2 ( 30 );
        v_tab_hist1 VARCHAR2 ( 30 );
        v_tab_hist2 VARCHAR2 ( 30 );
        v_tab_hist3 VARCHAR2 ( 30 );
        v_qtde INTEGER;
        v_tab_hist4 VARCHAR2 ( 30 );
        v_tab_hist5 VARCHAR2 ( 30 );
        v_tab_hist6 VARCHAR2 ( 30 );
    BEGIN
        ---TAB ENTRADA CD + COMPRA DIRETA - XML FORN - REFUGO 1
        v_sql := 'USING ( ';
        v_sql := v_sql || '  SELECT SUM(VLR_BASE_ICMS) AS VLR_BASE_ICMS, ';
        v_sql := v_sql || '         SUM(VLR_ICMS) AS VLR_ICMS, ';
        v_sql :=
               v_sql
            || '         SUM(DECODE(VLR_BASE_ICMS_ST,0,VLR_BASE_ICMSST_RET,VLR_BASE_ICMS_ST)) AS VLR_BASE_ICMS_ST, ';
        v_sql := v_sql || '         SUM(DECODE(VLR_ICMS_ST,0,VLR_ICMSST_RET,VLR_ICMS_ST)) AS VLR_ICMS_ST, ';
        v_sql := v_sql || '         SUM(QTY_NF_BRL) AS QTY_NF_BRL, ';
        v_sql := v_sql || '         NFE_VERIF_CODE_PBL AS CHAVE_ACESSO, ';
        v_sql := v_sql || '         INV_ITEM_ID AS COD_PRODUTO ';
        v_sql := v_sql || '  FROM MSAFI.PS_XML_FORN WHERE QTY_NF_BRL > 0 ';
        v_sql := v_sql || '  GROUP BY NFE_VERIF_CODE_PBL, INV_ITEM_ID ';
        v_sql := v_sql || ') B ';
        v_sql := v_sql || 'ON ( ';
        v_sql := v_sql || '  A.NUM_AUTENTIC_NFE_E      = B.CHAVE_ACESSO ';
        v_sql := v_sql || '  AND TRIM(A.COD_PRODUTO_E) = TRIM(B.COD_PRODUTO) ';
        v_sql := v_sql || '  AND A.QUANTIDADE_E        = QTY_NF_BRL ';
        v_sql := v_sql || ') WHEN MATCHED THEN ';
        v_sql := v_sql || '  UPDATE SET A.BASE_ICMS_UNIT_E = B.VLR_BASE_ICMS, ';
        v_sql := v_sql || '             A.VLR_ICMS_UNIT_E = B.VLR_ICMS, ';
        v_sql := v_sql || '             A.BASE_ST_UNIT_E = B.VLR_BASE_ICMS_ST, ';
        v_sql := v_sql || '             A.VLR_ICMS_ST_UNIT_E = B.VLR_ICMS_ST ';

        v_sql1 := 'MERGE INTO ' || v_tab_perdas_ent_c || ' A ';

        EXECUTE IMMEDIATE v_sql1 || v_sql;

        loga ( '[MERGE FORN REFUGO1 CD][END][' || SQL%ROWCOUNT || ']'
             , FALSE );
        COMMIT;

        v_sql1 := 'MERGE INTO ' || v_tab_perdas_ent_d || ' A ';

        EXECUTE IMMEDIATE v_sql1 || v_sql;

        loga ( '[MERGE FORN REFUGO1 COM][END][' || SQL%ROWCOUNT || ']'
             , FALSE );
        COMMIT;

        ---TAB ENTRADA CD + COMPRA DIRETA - XML FORN
        v_sql := 'USING ( ';
        v_sql := v_sql || '  SELECT VLR_BASE_ICMS AS VLR_BASE_ICMS, ';
        v_sql := v_sql || '         VLR_ICMS AS VLR_ICMS, ';
        v_sql :=
            v_sql || '         DECODE(VLR_BASE_ICMS_ST,0,VLR_BASE_ICMSST_RET,VLR_BASE_ICMS_ST) AS VLR_BASE_ICMS_ST, ';
        v_sql := v_sql || '         DECODE(VLR_ICMS_ST,0,VLR_ICMSST_RET,VLR_ICMS_ST) AS VLR_ICMS_ST, ';
        v_sql := v_sql || '         NFE_VERIF_CODE_PBL AS CHAVE_ACESSO, ';
        v_sql := v_sql || '         NF_BRL_LINE_NUM AS NUM_ITEM, ';
        v_sql := v_sql || '         INV_ITEM_ID AS COD_PRODUTO ';
        v_sql := v_sql || '  FROM MSAFI.PS_XML_FORN WHERE QTY_NF_BRL > 0 ';
        v_sql := v_sql || ') B ';
        v_sql := v_sql || 'ON ( ';
        v_sql := v_sql || '  A.NUM_AUTENTIC_NFE_E = B.CHAVE_ACESSO ';
        v_sql := v_sql || '  AND A.NUM_ITEM_E     = B.NUM_ITEM ';
        v_sql := v_sql || '  AND A.COD_PRODUTO_E  = B.COD_PRODUTO ';
        v_sql := v_sql || ') WHEN MATCHED THEN ';
        v_sql := v_sql || '  UPDATE SET A.BASE_ICMS_UNIT_E = B.VLR_BASE_ICMS, ';
        v_sql := v_sql || '             A.VLR_ICMS_UNIT_E = B.VLR_ICMS, ';
        v_sql := v_sql || '             A.BASE_ST_UNIT_E = B.VLR_BASE_ICMS_ST, ';
        v_sql := v_sql || '             A.VLR_ICMS_ST_UNIT_E = B.VLR_ICMS_ST ';

        v_sql1 := 'MERGE INTO ' || v_tab_perdas_ent_c || ' A ';

        EXECUTE IMMEDIATE v_sql1 || v_sql;

        loga ( '[MERGE FORN CD][END][' || SQL%ROWCOUNT || ']'
             , FALSE );
        COMMIT;

        v_sql1 := 'MERGE INTO ' || v_tab_perdas_ent_d || ' A ';

        EXECUTE IMMEDIATE v_sql1 || v_sql;

        loga ( '[MERGE FORN COM][END][' || SQL%ROWCOUNT || ']'
             , FALSE );
        COMMIT;

        ---TAB ENTRADA CD + COMPRA DIRETA - XML FORN - REFUGO 2
        v_sql := 'USING ( ';
        v_sql := v_sql || '  SELECT VLR_BASE_ICMS AS VLR_BASE_ICMS, ';
        v_sql := v_sql || '         VLR_ICMS AS VLR_ICMS, ';
        v_sql :=
            v_sql || '         DECODE(VLR_BASE_ICMS_ST,0,VLR_BASE_ICMSST_RET,VLR_BASE_ICMS_ST) AS VLR_BASE_ICMS_ST, ';
        v_sql := v_sql || '         DECODE(VLR_ICMS_ST,0,VLR_ICMSST_RET,VLR_ICMS_ST) AS VLR_ICMS_ST, ';
        v_sql := v_sql || '         QTY_NF_BRL, ';
        v_sql := v_sql || '         NFE_VERIF_CODE_PBL AS CHAVE_ACESSO, ';
        v_sql := v_sql || '         NF_BRL_LINE_NUM AS NUM_ITEM, ';
        v_sql := v_sql || '         INV_ITEM_ID AS COD_PRODUTO ';
        v_sql := v_sql || '  FROM MSAFI.PS_XML_FORN WHERE QTY_NF_BRL > 0 ';
        v_sql := v_sql || ') B ';
        v_sql := v_sql || 'ON ( ';
        v_sql := v_sql || '  A.NUM_AUTENTIC_NFE_E = B.CHAVE_ACESSO ';
        v_sql := v_sql || '  AND A.NUM_ITEM_E     = B.NUM_ITEM ';
        v_sql := v_sql || '  AND A.QUANTIDADE_E   = B.QTY_NF_BRL ';
        v_sql := v_sql || '  AND B.COD_PRODUTO    = '' '' ';
        v_sql := v_sql || ') WHEN MATCHED THEN ';
        v_sql := v_sql || '  UPDATE SET A.BASE_ICMS_UNIT_E = B.VLR_BASE_ICMS, ';
        v_sql := v_sql || '             A.VLR_ICMS_UNIT_E = B.VLR_ICMS, ';
        v_sql := v_sql || '             A.BASE_ST_UNIT_E = B.VLR_BASE_ICMS_ST, ';
        v_sql := v_sql || '             A.VLR_ICMS_ST_UNIT_E = B.VLR_ICMS_ST ';

        v_sql1 := 'MERGE INTO ' || v_tab_perdas_ent_c || ' A ';

        EXECUTE IMMEDIATE v_sql1 || v_sql;

        loga ( '[MERGE FORN REFUGO2 CD][END][' || SQL%ROWCOUNT || ']'
             , FALSE );
        COMMIT;

        v_sql1 := 'MERGE INTO ' || v_tab_perdas_ent_d || ' A ';

        EXECUTE IMMEDIATE v_sql1 || v_sql;

        loga ( '[MERGE FORN REFUGO2 COM][END][' || SQL%ROWCOUNT || ']'
             , FALSE );
        COMMIT;

        ---TAB ENTRADA FILIAL - XML INTERNO - BASE PRD PSFT
        v_tab_xml := 'DPSP_XMLI_' || vp_proc_id;

        v_sql := 'CREATE TABLE ' || v_tab_xml || ' AS ';
        v_sql :=
               v_sql
            || 'SELECT /*+DRIVING_SITE(X)*/ DISTINCT '
            || vp_proc_id
            || ' AS PROC_ID, X.NF_BRL_ID, X.CHAVE_ACESSO, X.NF_BRL_LINE_NUM, X.INV_ITEM_ID, X.CFOP_SAIDA, ';
        v_sql := v_sql || 'X.QUANTIDADE, X.VLR_BASE_ICMS, X.VLR_ICMS, X.ALIQ_REDUCAO, X.VLR_BASE_ICMS_ST, ';
        v_sql := v_sql || 'X.VLR_ICMS_ST, X.VLR_BASE_ICMSST_RET, X.VLR_ICMSST_RET ';
        v_sql := v_sql || 'FROM ( ';
        v_sql := v_sql || '        SELECT LN.NF_BRL_ID, ';
        v_sql := v_sql || '              CHAVE.NFEE_KEY_BBL AS CHAVE_ACESSO, ';
        v_sql := v_sql || '              LN.NF_BRL_LINE_NUM, ';
        v_sql := v_sql || '              LN.INV_ITEM_ID, ';
        v_sql := v_sql || '              LN.QTY_NF_BRL AS QUANTIDADE, ';
        v_sql := v_sql || '              LN.CFO_BRL_CD AS CFOP_SAIDA, ';
        v_sql := v_sql || '              NVL((SELECT IMP.TAX_BRL_BSE ';
        v_sql := v_sql || '                   FROM MSAFI.PS_AR_IMP_BBL IMP ';
        v_sql := v_sql || '                   WHERE IMP.BUSINESS_UNIT = LN.BUSINESS_UNIT ';
        v_sql := v_sql || '                     AND IMP.NF_BRL_ID = LN.NF_BRL_ID ';
        v_sql := v_sql || '                     AND IMP.NF_BRL_LINE_NUM = LN.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                     AND IMP.TAX_ID_BBL = ''ICMS''),0) AS VLR_BASE_ICMS, ';
        v_sql := v_sql || '              NVL((SELECT IMP.TAX_BRL_AMT ';
        v_sql := v_sql || '                     FROM MSAFI.PS_AR_IMP_BBL IMP ';
        v_sql := v_sql || '                   WHERE IMP.BUSINESS_UNIT = LN.BUSINESS_UNIT ';
        v_sql := v_sql || '                     AND IMP.NF_BRL_ID = LN.NF_BRL_ID ';
        v_sql := v_sql || '                     AND IMP.NF_BRL_LINE_NUM = LN.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                     AND IMP.TAX_ID_BBL = ''ICMS''),0) AS VLR_ICMS, ';
        v_sql := v_sql || '              0 AS ALIQ_REDUCAO, ';
        v_sql := v_sql || '              NVL((SELECT IMP.TAX_BRL_BSE ';
        v_sql := v_sql || '                    FROM MSAFI.PS_AR_IMP_BBL IMP ';
        v_sql := v_sql || '                   WHERE IMP.BUSINESS_UNIT = LN.BUSINESS_UNIT ';
        v_sql := v_sql || '                     AND IMP.NF_BRL_ID = LN.NF_BRL_ID ';
        v_sql := v_sql || '                     AND IMP.NF_BRL_LINE_NUM = LN.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                     AND IMP.TAX_ID_BBL = ''ICMST''),0) AS VLR_BASE_ICMS_ST, ';
        v_sql := v_sql || '              NVL((SELECT IMP.TAX_BRL_AMT ';
        v_sql := v_sql || '                    FROM MSAFI.PS_AR_IMP_BBL IMP ';
        v_sql := v_sql || '                   WHERE IMP.BUSINESS_UNIT = LN.BUSINESS_UNIT ';
        v_sql := v_sql || '                     AND IMP.NF_BRL_ID = LN.NF_BRL_ID ';
        v_sql := v_sql || '                     AND IMP.NF_BRL_LINE_NUM = LN.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '                     AND IMP.TAX_ID_BBL = ''ICMST''),0) AS VLR_ICMS_ST, ';
        v_sql := v_sql || '              0 AS VLR_BASE_ICMSST_RET, ';
        v_sql := v_sql || '              0 AS VLR_ICMSST_RET ';
        v_sql := v_sql || '        FROM MSAFI.PS_AR_NFRET_BBL CHAVE, ';
        v_sql := v_sql || '             MSAFI.PS_AR_ITENS_NF_BBL LN ';
        v_sql := v_sql || '        WHERE CHAVE.BUSINESS_UNIT = LN.BUSINESS_UNIT ';
        v_sql := v_sql || '          AND CHAVE.NF_BRL_ID = LN.NF_BRL_ID ) X ';
        v_sql := v_sql || 'WHERE EXISTS (SELECT ''Y'' FROM ' || v_tab_perdas_ent_f || ' E ';
        v_sql := v_sql || '               WHERE E.NUM_AUTENTIC_NFE_E = X.CHAVE_ACESSO) ';

        EXECUTE IMMEDIATE v_sql;

        save_tmp_control ( vp_proc_id
                         , v_tab_xml );

        v_sql := 'CREATE UNIQUE INDEX PK_X_' || vp_proc_id || ' ON ' || v_tab_xml;
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || ' PROC_ID ASC, ';
        v_sql := v_sql || ' NF_BRL_ID ASC, ';
        v_sql := v_sql || ' CHAVE_ACESSO ASC, ';
        v_sql := v_sql || ' NF_BRL_LINE_NUM ASC, ';
        v_sql := v_sql || ' INV_ITEM_ID ASC ';
        v_sql := v_sql || ' ) PCTFREE 10 NOLOGGING ';

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX1_X_' || vp_proc_id || ' ON ' || v_tab_xml;
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || ' CHAVE_ACESSO ASC ';
        v_sql := v_sql || ' ) PCTFREE 10 NOLOGGING ';

        EXECUTE IMMEDIATE v_sql;

        ---

        IF ( vp_filiais = 'S' ) THEN
            v_sql := 'INSERT /*+APPEND*/ INTO ' || v_tab_xml || ' ( ';
            v_sql :=
                   v_sql
                || 'SELECT /*+DRIVING_SITE(X)*/ '
                || vp_proc_id
                || ' AS PROC_ID, X.NF_BRL_ID, X.CHAVE_ACESSO, X.NF_BRL_LINE_NUM, X.INV_ITEM_ID, X.CFOP_SAIDA, ';
            v_sql := v_sql || 'X.QUANTIDADE, X.VLR_BASE_ICMS, X.VLR_ICMS, X.ALIQ_REDUCAO, X.VLR_BASE_ICMS_ST, ';
            v_sql := v_sql || 'X.VLR_ICMS_ST, X.VLR_BASE_ICMSST_RET, X.VLR_ICMSST_RET ';
            v_sql := v_sql || 'FROM ( ';
            v_sql := v_sql || '        SELECT LN.NF_BRL_ID, ';
            v_sql := v_sql || '              CHAVE.NFEE_KEY_BBL AS CHAVE_ACESSO, ';
            v_sql := v_sql || '              LN.NF_BRL_LINE_NUM, ';
            v_sql := v_sql || '              LN.INV_ITEM_ID, ';
            v_sql := v_sql || '              LN.QTY_NF_BRL AS QUANTIDADE, ';
            v_sql := v_sql || '              LN.CFO_BRL_CD AS CFOP_SAIDA, ';
            v_sql := v_sql || '              NVL((SELECT IMP.TAX_BRL_BSE ';
            v_sql := v_sql || '                   FROM MSAFI.PS_AR_IMP_BBL IMP ';
            v_sql := v_sql || '                   WHERE IMP.BUSINESS_UNIT = LN.BUSINESS_UNIT ';
            v_sql := v_sql || '                     AND IMP.NF_BRL_ID = LN.NF_BRL_ID ';
            v_sql := v_sql || '                     AND IMP.NF_BRL_LINE_NUM = LN.NF_BRL_LINE_NUM ';
            v_sql := v_sql || '                     AND IMP.TAX_ID_BBL = ''ICMS''),0) AS VLR_BASE_ICMS, ';
            v_sql := v_sql || '              NVL((SELECT IMP.TAX_BRL_AMT ';
            v_sql := v_sql || '                     FROM MSAFI.PS_AR_IMP_BBL IMP ';
            v_sql := v_sql || '                   WHERE IMP.BUSINESS_UNIT = LN.BUSINESS_UNIT ';
            v_sql := v_sql || '                     AND IMP.NF_BRL_ID = LN.NF_BRL_ID ';
            v_sql := v_sql || '                     AND IMP.NF_BRL_LINE_NUM = LN.NF_BRL_LINE_NUM ';
            v_sql := v_sql || '                     AND IMP.TAX_ID_BBL = ''ICMS''),0) AS VLR_ICMS, ';
            v_sql := v_sql || '              0 AS ALIQ_REDUCAO, ';
            v_sql := v_sql || '              NVL((SELECT IMP.TAX_BRL_BSE ';
            v_sql := v_sql || '                    FROM MSAFI.PS_AR_IMP_BBL IMP ';
            v_sql := v_sql || '                   WHERE IMP.BUSINESS_UNIT = LN.BUSINESS_UNIT ';
            v_sql := v_sql || '                     AND IMP.NF_BRL_ID = LN.NF_BRL_ID ';
            v_sql := v_sql || '                     AND IMP.NF_BRL_LINE_NUM = LN.NF_BRL_LINE_NUM ';
            v_sql := v_sql || '                     AND IMP.TAX_ID_BBL = ''ICMST''),0) AS VLR_BASE_ICMS_ST, ';
            v_sql := v_sql || '              NVL((SELECT IMP.TAX_BRL_AMT ';
            v_sql := v_sql || '                    FROM MSAFI.PS_AR_IMP_BBL IMP ';
            v_sql := v_sql || '                   WHERE IMP.BUSINESS_UNIT = LN.BUSINESS_UNIT ';
            v_sql := v_sql || '                     AND IMP.NF_BRL_ID = LN.NF_BRL_ID ';
            v_sql := v_sql || '                     AND IMP.NF_BRL_LINE_NUM = LN.NF_BRL_LINE_NUM ';
            v_sql := v_sql || '                     AND IMP.TAX_ID_BBL = ''ICMST''),0) AS VLR_ICMS_ST, ';
            v_sql := v_sql || '              0 AS VLR_BASE_ICMSST_RET, ';
            v_sql := v_sql || '              0 AS VLR_ICMSST_RET ';
            v_sql := v_sql || '        FROM MSAFI.PS_AR_NFRET_BBL CHAVE, ';
            v_sql := v_sql || '             MSAFI.PS_AR_ITENS_NF_BBL LN ';
            v_sql := v_sql || '        WHERE CHAVE.BUSINESS_UNIT = LN.BUSINESS_UNIT ';
            v_sql := v_sql || '          AND CHAVE.NF_BRL_ID = LN.NF_BRL_ID ) X ';
            v_sql := v_sql || 'WHERE EXISTS (SELECT ''Y'' FROM ' || v_tab_perdas_ent_m || ' E ';
            v_sql := v_sql || '               WHERE E.NUM_AUTENTIC_NFE_E = X.CHAVE_ACESSO) ';
            v_sql := v_sql || '  AND NOT EXISTS (SELECT ''Y'' FROM ' || v_tab_xml || ' TABX ';
            v_sql := v_sql || '                   WHERE TABX.CHAVE_ACESSO = X.CHAVE_ACESSO) ';
            v_sql := v_sql || ' ) ';

            EXECUTE IMMEDIATE v_sql;

            COMMIT;
        END IF;

        loga ( '[END XML INTERNO PSFT PRD]'
             , FALSE );

        IF ( vp_origem1 = '1'
         OR vp_origem2 = '1'
         OR vp_origem3 = '1'
         OR vp_origem4 = '1' ) THEN
            ---OBTER TEMP1 DA HISTORICA
            v_tab_hist1 := 'DPSP_X1$_' || vp_proc_id;

            v_sql := 'CREATE TABLE ' || v_tab_hist1 || ' AS ';
            v_sql := v_sql || 'SELECT /*+DRIVING_SITE(H)*/ DISTINCT H.NFEE_KEY_BBL, H.BUSINESS_UNIT, H.NF_BRL_ID ';
            v_sql := v_sql || 'FROM ( ';
            v_sql := v_sql || 'SELECT NFEE_KEY_BBL, BUSINESS_UNIT, NF_BRL_ID ';
            v_sql := v_sql || 'FROM FDSPPRD.PS_AR_NFRET_BBL_BKP_NOV2016@DBLINK_DBPSTHST H1, ';
            v_sql := v_sql || '    ' || v_tab_perdas_ent_f || ' F ';
            v_sql := v_sql || 'WHERE F.NUM_AUTENTIC_NFE_E = H1.NFEE_KEY_BBL ) H ';

            EXECUTE IMMEDIATE v_sql;

            save_tmp_control ( vp_proc_id
                             , v_tab_hist1 );

            v_sql := 'CREATE UNIQUE INDEX PK_H1_' || vp_proc_id || ' ON ' || v_tab_hist1;
            v_sql := v_sql || ' ( ';
            v_sql := v_sql || ' BUSINESS_UNIT ASC, ';
            v_sql := v_sql || ' NF_BRL_ID ASC ';
            v_sql := v_sql || ' ) PCTFREE 10 NOLOGGING ';

            EXECUTE IMMEDIATE v_sql;

            v_sql := 'CREATE INDEX IDX1_H1_' || vp_proc_id || ' ON ' || v_tab_hist1;
            v_sql := v_sql || ' ( ';
            v_sql := v_sql || ' NFEE_KEY_BBL ASC ';
            v_sql := v_sql || ' ) PCTFREE 10 NOLOGGING ';

            EXECUTE IMMEDIATE v_sql;

            dbms_stats.gather_table_stats ( 'MSAF'
                                          , v_tab_hist1 );

            EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || v_tab_hist1            INTO v_qtde;

            loga ( '[HIST1][OK][' || v_qtde || ']'
                 , FALSE );

            IF ( v_qtde > 0 ) THEN --(1)
                ---OBTER TEMP2 DA HISTORICA
                v_tab_hist2 := 'DPSP_X2$_' || vp_proc_id;

                v_sql := 'CREATE TABLE ' || v_tab_hist2 || ' AS ';
                v_sql := v_sql || 'SELECT H.NFEE_KEY_BBL, H.BUSINESS_UNIT, H.NF_BRL_ID, H.NF_BRL_LINE_NUM, ';
                v_sql := v_sql || '       H.INV_ITEM_ID, H.QUANTIDADE, H.CFOP_SAIDA ';
                v_sql := v_sql || 'FROM ( ';
                v_sql :=
                       v_sql
                    || 'SELECT /*+DRIVING_SITE(H2)*/ H1.NFEE_KEY_BBL, H2.BUSINESS_UNIT, H2.NF_BRL_ID, H2.NF_BRL_LINE_NUM, H2.INV_ITEM_ID, H2.QTY_NF_BRL AS QUANTIDADE, H2.CFO_BRL_CD AS CFOP_SAIDA ';
                v_sql := v_sql || 'FROM FDSPPRD.PS_AR_ITENS_NF_BBL_BKP_NOV2016@DBLINK_DBPSTHST H2, ';
                v_sql := v_sql || '    ' || v_tab_hist1 || ' H1 ';
                v_sql := v_sql || 'WHERE H1.BUSINESS_UNIT = H2.BUSINESS_UNIT ';
                v_sql := v_sql || '  AND H1.NF_BRL_ID = H2.NF_BRL_ID ) H ';

                EXECUTE IMMEDIATE v_sql;

                save_tmp_control ( vp_proc_id
                                 , v_tab_hist2 );
                loga ( '[HIST2][OK]'
                     , FALSE );

                v_sql := 'CREATE UNIQUE INDEX PK_H2_' || vp_proc_id || ' ON ' || v_tab_hist2;
                v_sql := v_sql || ' ( ';
                v_sql := v_sql || ' BUSINESS_UNIT ASC, ';
                v_sql := v_sql || ' NF_BRL_ID ASC, ';
                v_sql := v_sql || ' NF_BRL_LINE_NUM ASC ';
                v_sql := v_sql || ' ) PCTFREE 10 NOLOGGING ';

                EXECUTE IMMEDIATE v_sql;

                dbms_stats.gather_table_stats ( 'MSAF'
                                              , v_tab_hist2 );

                ---OBTER TEMP3 DA HISTORICA
                v_tab_hist3 := 'DPSP_X3$_' || vp_proc_id;

                v_sql := 'CREATE TABLE ' || v_tab_hist3 || ' AS ';
                v_sql :=
                       v_sql
                    || 'SELECT H.BUSINESS_UNIT, H.NF_BRL_ID, H.NF_BRL_LINE_NUM, H.TAX_ID_BBL, H.TAX_BRL_BSE, H.TAX_BRL_AMT ';
                v_sql := v_sql || 'FROM ( ';
                v_sql :=
                       v_sql
                    || 'SELECT /*+DRIVING_SITE(H3)*/ H3.BUSINESS_UNIT, H3.NF_BRL_ID, H3.NF_BRL_LINE_NUM, H3.TAX_ID_BBL, H3.TAX_BRL_BSE, H3.TAX_BRL_AMT ';
                v_sql := v_sql || 'FROM FDSPPRD.PS_AR_IMP_BBL_BKP_NOV2016@DBLINK_DBPSTHST  H3, ';
                v_sql := v_sql || '    ' || v_tab_hist2 || ' H2 ';
                v_sql := v_sql || 'WHERE H2.BUSINESS_UNIT = H3.BUSINESS_UNIT ';
                v_sql := v_sql || '  AND H2.NF_BRL_ID = H3.NF_BRL_ID ';
                v_sql := v_sql || '  AND H2.NF_BRL_LINE_NUM = H3.NF_BRL_LINE_NUM ';
                v_sql := v_sql || '  AND H3.TAX_ID_BBL IN (''ICMS'',''ICMST'') ) H ';

                EXECUTE IMMEDIATE v_sql;

                save_tmp_control ( vp_proc_id
                                 , v_tab_hist3 );
                loga ( '[HIST3][OK]'
                     , FALSE );

                v_sql := 'CREATE UNIQUE INDEX PK_H3_' || vp_proc_id || ' ON ' || v_tab_hist3;
                v_sql := v_sql || ' ( ';
                v_sql := v_sql || ' BUSINESS_UNIT ASC, ';
                v_sql := v_sql || ' NF_BRL_ID ASC, ';
                v_sql := v_sql || ' NF_BRL_LINE_NUM ASC, ';
                v_sql := v_sql || ' TAX_ID_BBL ASC ';
                v_sql := v_sql || ' ) PCTFREE 10 NOLOGGING ';

                EXECUTE IMMEDIATE v_sql;

                dbms_stats.gather_table_stats ( 'MSAF'
                                              , v_tab_hist3 );

                ---TAB ENTRADA FILIAL - XML INTERNO - BASE HIST PSFT
                v_sql := 'INSERT /*+APPEND*/ INTO ' || v_tab_xml || ' ( ';
                v_sql :=
                       v_sql
                    || 'SELECT '
                    || vp_proc_id
                    || ' AS PROC_ID, X.NF_BRL_ID, X.CHAVE_ACESSO, X.NF_BRL_LINE_NUM, X.INV_ITEM_ID, X.CFOP_SAIDA, ';
                v_sql := v_sql || 'X.QUANTIDADE, X.VLR_BASE_ICMS, X.VLR_ICMS, X.ALIQ_REDUCAO, X.VLR_BASE_ICMS_ST, ';
                v_sql := v_sql || 'X.VLR_ICMS_ST, X.VLR_BASE_ICMSST_RET, X.VLR_ICMSST_RET ';
                v_sql := v_sql || 'FROM ( ';
                v_sql := v_sql || '        SELECT LN.NF_BRL_ID, ';
                v_sql := v_sql || '              LN.NFEE_KEY_BBL AS CHAVE_ACESSO, ';
                v_sql := v_sql || '              LN.NF_BRL_LINE_NUM, ';
                v_sql := v_sql || '              LN.INV_ITEM_ID, ';
                v_sql := v_sql || '              LN.QUANTIDADE, ';
                v_sql := v_sql || '              LN.CFOP_SAIDA, ';
                v_sql := v_sql || '              NVL((SELECT IMP.TAX_BRL_BSE ';
                v_sql := v_sql || '                   FROM ' || v_tab_hist3 || ' IMP ';
                v_sql := v_sql || '                   WHERE IMP.BUSINESS_UNIT = LN.BUSINESS_UNIT ';
                v_sql := v_sql || '                     AND IMP.NF_BRL_ID = LN.NF_BRL_ID ';
                v_sql := v_sql || '                     AND IMP.NF_BRL_LINE_NUM = LN.NF_BRL_LINE_NUM ';
                v_sql := v_sql || '                     AND IMP.TAX_ID_BBL = ''ICMS''),0) AS VLR_BASE_ICMS, ';
                v_sql := v_sql || '              NVL((SELECT IMP.TAX_BRL_AMT ';
                v_sql := v_sql || '                     FROM ' || v_tab_hist3 || ' IMP ';
                v_sql := v_sql || '                   WHERE IMP.BUSINESS_UNIT = LN.BUSINESS_UNIT ';
                v_sql := v_sql || '                     AND IMP.NF_BRL_ID = LN.NF_BRL_ID ';
                v_sql := v_sql || '                     AND IMP.NF_BRL_LINE_NUM = LN.NF_BRL_LINE_NUM ';
                v_sql := v_sql || '                     AND IMP.TAX_ID_BBL = ''ICMS''),0) AS VLR_ICMS, ';
                v_sql := v_sql || '              0 AS ALIQ_REDUCAO, ';
                v_sql := v_sql || '              NVL((SELECT IMP.TAX_BRL_BSE ';
                v_sql := v_sql || '                    FROM ' || v_tab_hist3 || ' IMP ';
                v_sql := v_sql || '                   WHERE IMP.BUSINESS_UNIT = LN.BUSINESS_UNIT ';
                v_sql := v_sql || '                     AND IMP.NF_BRL_ID = LN.NF_BRL_ID ';
                v_sql := v_sql || '                     AND IMP.NF_BRL_LINE_NUM = LN.NF_BRL_LINE_NUM ';
                v_sql := v_sql || '                     AND IMP.TAX_ID_BBL = ''ICMST''),0) AS VLR_BASE_ICMS_ST, ';
                v_sql := v_sql || '              NVL((SELECT IMP.TAX_BRL_AMT ';
                v_sql := v_sql || '                    FROM ' || v_tab_hist3 || ' IMP ';
                v_sql := v_sql || '                   WHERE IMP.BUSINESS_UNIT = LN.BUSINESS_UNIT ';
                v_sql := v_sql || '                     AND IMP.NF_BRL_ID = LN.NF_BRL_ID ';
                v_sql := v_sql || '                     AND IMP.NF_BRL_LINE_NUM = LN.NF_BRL_LINE_NUM ';
                v_sql := v_sql || '                     AND IMP.TAX_ID_BBL = ''ICMST''),0) AS VLR_ICMS_ST, ';
                v_sql := v_sql || '              0 AS VLR_BASE_ICMSST_RET, ';
                v_sql := v_sql || '              0 AS VLR_ICMSST_RET ';
                v_sql := v_sql || '        FROM ' || v_tab_hist2 || ' LN ';
                v_sql := v_sql || '        WHERE NOT EXISTS (SELECT ''Y'' FROM ' || v_tab_xml || ' TABX ';
                v_sql := v_sql || '                     WHERE TABX.CHAVE_ACESSO = LN.NFEE_KEY_BBL) ) X ';
                v_sql := v_sql || ' ) ';

                EXECUTE IMMEDIATE v_sql;

                COMMIT;
            END IF; --(1)
        END IF;

        IF ( vp_filiais = 'S' ) THEN
            ---OBTER TEMP4 DA HISTORICA
            v_tab_hist4 := 'DPSP_X4$_' || vp_proc_id;

            v_sql := 'CREATE TABLE ' || v_tab_hist4 || ' AS ';
            v_sql := v_sql || 'SELECT /*+DRIVING_SITE(H)*/ DISTINCT H.NFEE_KEY_BBL, H.BUSINESS_UNIT, H.NF_BRL_ID ';
            v_sql := v_sql || 'FROM ( ';
            v_sql := v_sql || 'SELECT NFEE_KEY_BBL, BUSINESS_UNIT, NF_BRL_ID ';
            v_sql := v_sql || 'FROM FDSPPRD.PS_AR_NFRET_BBL_BKP_NOV2016@DBLINK_DBPSTHST H1, ';
            v_sql := v_sql || '    ' || v_tab_perdas_ent_m || ' F ';
            v_sql := v_sql || 'WHERE F.NUM_AUTENTIC_NFE_E = H1.NFEE_KEY_BBL ) H ';

            EXECUTE IMMEDIATE v_sql;

            save_tmp_control ( vp_proc_id
                             , v_tab_hist4 );

            v_sql := 'CREATE UNIQUE INDEX PK_H4_' || vp_proc_id || ' ON ' || v_tab_hist4;
            v_sql := v_sql || ' ( ';
            v_sql := v_sql || ' BUSINESS_UNIT ASC, ';
            v_sql := v_sql || ' NF_BRL_ID ASC ';
            v_sql := v_sql || ' ) PCTFREE 10 NOLOGGING ';

            EXECUTE IMMEDIATE v_sql;

            v_sql := 'CREATE INDEX IDX1_H4_' || vp_proc_id || ' ON ' || v_tab_hist4;
            v_sql := v_sql || ' ( ';
            v_sql := v_sql || ' NFEE_KEY_BBL ASC ';
            v_sql := v_sql || ' ) PCTFREE 10 NOLOGGING ';

            EXECUTE IMMEDIATE v_sql;

            dbms_stats.gather_table_stats ( 'MSAF'
                                          , v_tab_hist4 );

            v_qtde := 0;

            EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || v_tab_hist4            INTO v_qtde;

            loga ( '[HIST4][OK][' || v_qtde || ']'
                 , FALSE );

            IF ( v_qtde > 0 ) THEN --(1)
                ---OBTER TEMP2 DA HISTORICA
                v_tab_hist5 := 'DPSP_X5$_' || vp_proc_id;

                v_sql := 'CREATE TABLE ' || v_tab_hist5 || ' AS ';
                v_sql := v_sql || 'SELECT H.NFEE_KEY_BBL, H.BUSINESS_UNIT, H.NF_BRL_ID, H.NF_BRL_LINE_NUM, ';
                v_sql := v_sql || '       H.INV_ITEM_ID, H.QUANTIDADE, H.CFOP_SAIDA ';
                v_sql := v_sql || 'FROM ( ';
                v_sql :=
                       v_sql
                    || 'SELECT /*+DRIVING_SITE(H2)*/ H1.NFEE_KEY_BBL, H2.BUSINESS_UNIT, H2.NF_BRL_ID, H2.NF_BRL_LINE_NUM, H2.INV_ITEM_ID, H2.QTY_NF_BRL AS QUANTIDADE, H2.CFO_BRL_CD AS CFOP_SAIDA ';
                v_sql := v_sql || 'FROM FDSPPRD.PS_AR_ITENS_NF_BBL_BKP_NOV2016@DBLINK_DBPSTHST H2, ';
                v_sql := v_sql || '    ' || v_tab_hist4 || ' H1 ';
                v_sql := v_sql || 'WHERE H1.BUSINESS_UNIT = H2.BUSINESS_UNIT ';
                v_sql := v_sql || '  AND H1.NF_BRL_ID = H2.NF_BRL_ID ) H ';

                EXECUTE IMMEDIATE v_sql;

                save_tmp_control ( vp_proc_id
                                 , v_tab_hist5 );
                loga ( '[HIST5][OK]'
                     , FALSE );

                v_sql := 'CREATE UNIQUE INDEX PK_H5_' || vp_proc_id || ' ON ' || v_tab_hist5;
                v_sql := v_sql || ' ( ';
                v_sql := v_sql || ' BUSINESS_UNIT ASC, ';
                v_sql := v_sql || ' NF_BRL_ID ASC, ';
                v_sql := v_sql || ' NF_BRL_LINE_NUM ASC ';
                v_sql := v_sql || ' ) PCTFREE 10 NOLOGGING ';

                EXECUTE IMMEDIATE v_sql;

                dbms_stats.gather_table_stats ( 'MSAF'
                                              , v_tab_hist5 );

                ---OBTER TEMP3 DA HISTORICA
                v_tab_hist6 := 'DPSP_X6$_' || vp_proc_id;

                v_sql := 'CREATE TABLE ' || v_tab_hist6 || ' AS ';
                v_sql :=
                       v_sql
                    || 'SELECT H.BUSINESS_UNIT, H.NF_BRL_ID, H.NF_BRL_LINE_NUM, H.TAX_ID_BBL, H.TAX_BRL_BSE, H.TAX_BRL_AMT ';
                v_sql := v_sql || 'FROM ( ';
                v_sql :=
                       v_sql
                    || 'SELECT /*+DRIVING_SITE(H3)*/ H3.BUSINESS_UNIT, H3.NF_BRL_ID, H3.NF_BRL_LINE_NUM, H3.TAX_ID_BBL, H3.TAX_BRL_BSE, H3.TAX_BRL_AMT ';
                v_sql := v_sql || 'FROM FDSPPRD.PS_AR_IMP_BBL_BKP_NOV2016@DBLINK_DBPSTHST H3, ';
                v_sql := v_sql || '    ' || v_tab_hist5 || ' H2 ';
                v_sql := v_sql || 'WHERE H2.BUSINESS_UNIT = H3.BUSINESS_UNIT ';
                v_sql := v_sql || '  AND H2.NF_BRL_ID = H3.NF_BRL_ID ';
                v_sql := v_sql || '  AND H2.NF_BRL_LINE_NUM = H3.NF_BRL_LINE_NUM ';
                v_sql := v_sql || '  AND H3.TAX_ID_BBL IN (''ICMS'',''ICMST'') ) H ';

                EXECUTE IMMEDIATE v_sql;

                save_tmp_control ( vp_proc_id
                                 , v_tab_hist6 );
                loga ( '[HIST6][OK]'
                     , FALSE );

                v_sql := 'CREATE UNIQUE INDEX PK_H6_' || vp_proc_id || ' ON ' || v_tab_hist6;
                v_sql := v_sql || ' ( ';
                v_sql := v_sql || ' BUSINESS_UNIT ASC, ';
                v_sql := v_sql || ' NF_BRL_ID ASC, ';
                v_sql := v_sql || ' NF_BRL_LINE_NUM ASC, ';
                v_sql := v_sql || ' TAX_ID_BBL ASC ';
                v_sql := v_sql || ' ) PCTFREE 10 NOLOGGING ';

                EXECUTE IMMEDIATE v_sql;

                dbms_stats.gather_table_stats ( 'MSAF'
                                              , v_tab_hist6 );

                ---TAB ENTRADA FILIAL - XML INTERNO - BASE HIST PSFT
                v_sql := 'INSERT /*+APPEND*/ INTO ' || v_tab_xml || ' ( ';
                v_sql :=
                       v_sql
                    || 'SELECT '
                    || vp_proc_id
                    || ' AS PROC_ID, X.NF_BRL_ID, X.CHAVE_ACESSO, X.NF_BRL_LINE_NUM, X.INV_ITEM_ID, X.CFOP_SAIDA, ';
                v_sql := v_sql || 'X.QUANTIDADE, X.VLR_BASE_ICMS, X.VLR_ICMS, X.ALIQ_REDUCAO, X.VLR_BASE_ICMS_ST, ';
                v_sql := v_sql || 'X.VLR_ICMS_ST, X.VLR_BASE_ICMSST_RET, X.VLR_ICMSST_RET ';
                v_sql := v_sql || 'FROM ( ';
                v_sql := v_sql || '        SELECT LN.NF_BRL_ID, ';
                v_sql := v_sql || '              LN.NFEE_KEY_BBL AS CHAVE_ACESSO, ';
                v_sql := v_sql || '              LN.NF_BRL_LINE_NUM, ';
                v_sql := v_sql || '              LN.INV_ITEM_ID, ';
                v_sql := v_sql || '              LN.QUANTIDADE, ';
                v_sql := v_sql || '              LN.CFOP_SAIDA, ';
                v_sql := v_sql || '              NVL((SELECT IMP.TAX_BRL_BSE ';
                v_sql := v_sql || '                   FROM ' || v_tab_hist6 || ' IMP ';
                v_sql := v_sql || '                   WHERE IMP.BUSINESS_UNIT = LN.BUSINESS_UNIT ';
                v_sql := v_sql || '                     AND IMP.NF_BRL_ID = LN.NF_BRL_ID ';
                v_sql := v_sql || '                     AND IMP.NF_BRL_LINE_NUM = LN.NF_BRL_LINE_NUM ';
                v_sql := v_sql || '                     AND IMP.TAX_ID_BBL = ''ICMS''),0) AS VLR_BASE_ICMS, ';
                v_sql := v_sql || '              NVL((SELECT IMP.TAX_BRL_AMT ';
                v_sql := v_sql || '                     FROM ' || v_tab_hist6 || ' IMP ';
                v_sql := v_sql || '                   WHERE IMP.BUSINESS_UNIT = LN.BUSINESS_UNIT ';
                v_sql := v_sql || '                     AND IMP.NF_BRL_ID = LN.NF_BRL_ID ';
                v_sql := v_sql || '                     AND IMP.NF_BRL_LINE_NUM = LN.NF_BRL_LINE_NUM ';
                v_sql := v_sql || '                     AND IMP.TAX_ID_BBL = ''ICMS''),0) AS VLR_ICMS, ';
                v_sql := v_sql || '              0 AS ALIQ_REDUCAO, ';
                v_sql := v_sql || '              NVL((SELECT IMP.TAX_BRL_BSE ';
                v_sql := v_sql || '                    FROM ' || v_tab_hist6 || ' IMP ';
                v_sql := v_sql || '                   WHERE IMP.BUSINESS_UNIT = LN.BUSINESS_UNIT ';
                v_sql := v_sql || '                     AND IMP.NF_BRL_ID = LN.NF_BRL_ID ';
                v_sql := v_sql || '                     AND IMP.NF_BRL_LINE_NUM = LN.NF_BRL_LINE_NUM ';
                v_sql := v_sql || '                     AND IMP.TAX_ID_BBL = ''ICMST''),0) AS VLR_BASE_ICMS_ST, ';
                v_sql := v_sql || '              NVL((SELECT IMP.TAX_BRL_AMT ';
                v_sql := v_sql || '                    FROM ' || v_tab_hist6 || ' IMP ';
                v_sql := v_sql || '                   WHERE IMP.BUSINESS_UNIT = LN.BUSINESS_UNIT ';
                v_sql := v_sql || '                     AND IMP.NF_BRL_ID = LN.NF_BRL_ID ';
                v_sql := v_sql || '                     AND IMP.NF_BRL_LINE_NUM = LN.NF_BRL_LINE_NUM ';
                v_sql := v_sql || '                     AND IMP.TAX_ID_BBL = ''ICMST''),0) AS VLR_ICMS_ST, ';
                v_sql := v_sql || '              0 AS VLR_BASE_ICMSST_RET, ';
                v_sql := v_sql || '              0 AS VLR_ICMSST_RET ';
                v_sql := v_sql || '        FROM ' || v_tab_hist5 || ' LN ';
                v_sql := v_sql || '        WHERE NOT EXISTS (SELECT ''Y'' FROM ' || v_tab_xml || ' TABX ';
                v_sql := v_sql || '                     WHERE TABX.CHAVE_ACESSO = LN.NFEE_KEY_BBL) ) X ';
                v_sql := v_sql || ' ) ';

                EXECUTE IMMEDIATE v_sql;

                COMMIT;
            END IF; --(1)
        END IF;

        loga ( '[END XML INTERNO PSFT HIST]'
             , FALSE );
        dbms_stats.gather_table_stats ( 'MSAF'
                                      , v_tab_xml );

        ---TAB ENTRADA FILIAL - XML INTERNO REFUGO 2
        v_sql := 'USING ( ';
        v_sql := v_sql || '  SELECT SUM(VLR_BASE_ICMS) AS VLR_BASE_ICMS, ';
        v_sql := v_sql || '         SUM(VLR_ICMS) AS VLR_ICMS, ';
        v_sql :=
               v_sql
            || '         SUM(DECODE(VLR_BASE_ICMS_ST,0,VLR_BASE_ICMSST_RET,VLR_BASE_ICMS_ST)) AS VLR_BASE_ICMS_ST, ';
        v_sql := v_sql || '         SUM(DECODE(VLR_ICMS_ST,0,VLR_ICMSST_RET,VLR_ICMS_ST)) AS VLR_ICMS_ST, ';
        v_sql := v_sql || '         SUM(QUANTIDADE) AS QUANTIDADE, ';
        v_sql := v_sql || '         CHAVE_ACESSO, ';
        v_sql := v_sql || '         INV_ITEM_ID AS COD_PRODUTO ';
        v_sql := v_sql || '  FROM ' || v_tab_xml || ' WHERE QUANTIDADE > 0 ';
        v_sql := v_sql || '  GROUP BY CHAVE_ACESSO, INV_ITEM_ID ';
        v_sql := v_sql || ') B ';
        v_sql := v_sql || 'ON ( ';
        v_sql := v_sql || '  A.NUM_AUTENTIC_NFE_E = B.CHAVE_ACESSO ';
        v_sql := v_sql || '  AND A.QUANTIDADE_E   = B.QUANTIDADE ';
        v_sql := v_sql || '  AND A.COD_PRODUTO_E  = B.COD_PRODUTO ';
        v_sql := v_sql || ') WHEN MATCHED THEN ';
        v_sql := v_sql || '  UPDATE SET A.BASE_ICMS_UNIT_E = B.VLR_BASE_ICMS, ';
        v_sql := v_sql || '             A.VLR_ICMS_UNIT_E = B.VLR_ICMS, ';
        v_sql := v_sql || '             A.BASE_ST_UNIT_E = B.VLR_BASE_ICMS_ST, ';
        v_sql := v_sql || '             A.VLR_ICMS_ST_UNIT_E = B.VLR_ICMS_ST ';

        v_sql1 := 'MERGE INTO ' || v_tab_perdas_ent_f || ' A ';

        EXECUTE IMMEDIATE v_sql1 || v_sql;

        loga ( '[MERGE DSP XML REFUGO2 FI][END][' || SQL%ROWCOUNT || ']'
             , FALSE );
        COMMIT;

        IF ( vp_filiais = 'S' ) THEN
            v_sql1 := 'MERGE INTO ' || v_tab_perdas_ent_m || ' A ';

            EXECUTE IMMEDIATE v_sql1 || v_sql;

            loga ( '[MERGE DSP XML REFUGO2 MU][END][' || SQL%ROWCOUNT || ']'
                 , FALSE );
            COMMIT;
        END IF;

        ---TAB ENTRADA FILIAL - XML INTERNO
        v_sql := 'USING ( ';
        v_sql := v_sql || '  SELECT VLR_BASE_ICMS AS VLR_BASE_ICMS, ';
        v_sql := v_sql || '         VLR_ICMS AS VLR_ICMS, ';
        v_sql :=
            v_sql || '         DECODE(VLR_BASE_ICMS_ST,0,VLR_BASE_ICMSST_RET,VLR_BASE_ICMS_ST) AS VLR_BASE_ICMS_ST, ';
        v_sql := v_sql || '         DECODE(VLR_ICMS_ST,0,VLR_ICMSST_RET,VLR_ICMS_ST) AS VLR_ICMS_ST, ';
        v_sql := v_sql || '         QUANTIDADE, ';
        v_sql := v_sql || '         CHAVE_ACESSO, ';
        v_sql := v_sql || '         NF_BRL_LINE_NUM AS NUM_ITEM, ';
        v_sql := v_sql || '         INV_ITEM_ID AS COD_PRODUTO ';
        v_sql := v_sql || '  FROM ' || v_tab_xml || ' WHERE QUANTIDADE > 0 ';
        v_sql := v_sql || ') B ';
        v_sql := v_sql || 'ON ( ';
        v_sql := v_sql || '  A.NUM_AUTENTIC_NFE_E = B.CHAVE_ACESSO ';
        v_sql := v_sql || '  AND A.NUM_ITEM_E     = B.NUM_ITEM ';
        v_sql := v_sql || '  AND A.COD_PRODUTO_E  = B.COD_PRODUTO ';
        v_sql := v_sql || ') WHEN MATCHED THEN ';
        v_sql := v_sql || '  UPDATE SET A.BASE_ICMS_UNIT_E = B.VLR_BASE_ICMS, ';
        v_sql := v_sql || '             A.VLR_ICMS_UNIT_E = B.VLR_ICMS, ';
        v_sql := v_sql || '             A.BASE_ST_UNIT_E = B.VLR_BASE_ICMS_ST, ';
        v_sql := v_sql || '             A.VLR_ICMS_ST_UNIT_E = B.VLR_ICMS_ST ';

        v_sql1 := 'MERGE INTO ' || v_tab_perdas_ent_f || ' A ';

        EXECUTE IMMEDIATE v_sql1 || v_sql;

        loga ( '[MERGE DSP XML FI][END][' || SQL%ROWCOUNT || ']'
             , FALSE );
        COMMIT;

        IF ( vp_filiais = 'S' ) THEN
            v_sql1 := 'MERGE INTO ' || v_tab_perdas_ent_m || ' A ';

            EXECUTE IMMEDIATE v_sql1 || v_sql;

            loga ( '[MERGE DSP XML MU][END][' || SQL%ROWCOUNT || ']'
                 , FALSE );
            COMMIT;
        END IF;

        ---TAB ENTRADA FILIAL - XML INTERNO REFUGO 1
        v_sql := 'USING ( ';
        v_sql := v_sql || '  SELECT VLR_BASE_ICMS AS VLR_BASE_ICMS, ';
        v_sql := v_sql || '         VLR_ICMS AS VLR_ICMS, ';
        v_sql :=
            v_sql || '         DECODE(VLR_BASE_ICMS_ST,0,VLR_BASE_ICMSST_RET,VLR_BASE_ICMS_ST) AS VLR_BASE_ICMS_ST, ';
        v_sql := v_sql || '         DECODE(VLR_ICMS_ST,0,VLR_ICMSST_RET,VLR_ICMS_ST) AS VLR_ICMS_ST, ';
        v_sql := v_sql || '         QUANTIDADE, ';
        v_sql := v_sql || '         CHAVE_ACESSO, ';
        v_sql := v_sql || '         NF_BRL_LINE_NUM AS NUM_ITEM, ';
        v_sql := v_sql || '         INV_ITEM_ID AS COD_PRODUTO ';
        v_sql := v_sql || '  FROM ' || v_tab_xml || ' WHERE QUANTIDADE > 0 ';
        v_sql := v_sql || ') B ';
        v_sql := v_sql || 'ON ( ';
        v_sql := v_sql || '  A.NUM_AUTENTIC_NFE_E = B.CHAVE_ACESSO ';
        v_sql := v_sql || '  AND A.NUM_ITEM_E     = B.NUM_ITEM ';
        v_sql := v_sql || '  AND B.COD_PRODUTO    = '' '' ';
        v_sql := v_sql || ') WHEN MATCHED THEN ';
        v_sql := v_sql || '  UPDATE SET A.BASE_ICMS_UNIT_E = B.VLR_BASE_ICMS, ';
        v_sql := v_sql || '             A.VLR_ICMS_UNIT_E = B.VLR_ICMS, ';
        v_sql := v_sql || '             A.BASE_ST_UNIT_E = B.VLR_BASE_ICMS_ST, ';
        v_sql := v_sql || '             A.VLR_ICMS_ST_UNIT_E = B.VLR_ICMS_ST ';

        v_sql1 := 'MERGE INTO ' || v_tab_perdas_ent_f || ' A ';

        EXECUTE IMMEDIATE v_sql1 || v_sql;

        loga ( '[MERGE DSP XML REFUGO1 FI][END][' || SQL%ROWCOUNT || ']'
             , FALSE );
        COMMIT;

        IF ( vp_filiais = 'S' ) THEN
            v_sql1 := 'MERGE INTO ' || v_tab_perdas_ent_m || ' A ';

            EXECUTE IMMEDIATE v_sql1 || v_sql;

            loga ( '[MERGE DSP XML REFUGO1 MU][END][' || SQL%ROWCOUNT || ']'
                 , FALSE );
            COMMIT;
        END IF;
    END;

    PROCEDURE get_antecipacao ( vp_proc_id IN VARCHAR2
                              , v_tab_perdas_ent_c IN VARCHAR2
                              , v_tab_perdas_ent_f IN VARCHAR2
                              , v_tab_perdas_ent_d IN VARCHAR2
                              , v_tab_perdas_ent_m IN VARCHAR2 )
    IS
        v_tab_aux VARCHAR2 ( 30 );
        v_sql VARCHAR2 ( 3000 );
    BEGIN
        v_tab_aux := 'DPSP_ANT_' || vp_proc_id;

        v_sql := 'CREATE TABLE ' || v_tab_aux || ' AS ';
        v_sql :=
               v_sql
            || ' SELECT DISTINCT COD_ESTAB_E AS COD_ESTAB, NUM_CONTROLE_DOCTO_E AS NUM_CONTROLE_DOCTO, NUM_ITEM_E AS NUM_ITEM ';
        v_sql := v_sql || ' FROM ' || v_tab_perdas_ent_c || ' ';
        v_sql := v_sql || ' WHERE BASE_ST_UNIT_E = 0 AND VLR_ICMS_ST_UNIT_E = 0 ';
        v_sql := v_sql || ' UNION ALL ';
        v_sql :=
               v_sql
            || ' SELECT DISTINCT COD_ESTAB_E AS COD_ESTAB, NUM_CONTROLE_DOCTO_E AS NUM_CONTROLE_DOCTO, NUM_ITEM_E AS NUM_ITEM ';
        v_sql := v_sql || ' FROM ' || v_tab_perdas_ent_d || ' ';
        v_sql := v_sql || ' WHERE BASE_ST_UNIT_E = 0 AND VLR_ICMS_ST_UNIT_E = 0 ';

        --V_SQL := V_SQL || ' UNION ALL ';
        --V_SQL := V_SQL || ' SELECT DISTINCT COD_ESTAB_E, NUM_CONTROLE_DOCTO_E, NUM_ITEM_E ';
        --V_SQL := V_SQL || ' FROM ' || V_TAB_PERDAS_ENT_F || ' ';
        --V_SQL := V_SQL || ' WHERE BASE_ST_UNIT_E = 0 AND VLR_ICMS_ST_UNIT_E = 0 ';
        EXECUTE IMMEDIATE v_sql;

        loga ( '[GET ANTECIP][END][' || SQL%ROWCOUNT || ']'
             , FALSE );
        save_tmp_control ( vp_proc_id
                         , v_tab_aux );

        --ATUALIZAR ANTECIPACAO
        msafi.dpsp_get_antecipacao ( 'MSAF.' || v_tab_aux );
    END;

    PROCEDURE merge_antecipacao ( v_tab_perdas_tmp IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 3000 );
    BEGIN
        v_sql := 'MERGE INTO ' || v_tab_perdas_tmp || ' A ';
        v_sql := v_sql || ' USING ( ';
        v_sql := v_sql || ' SELECT * FROM MSAFI.DPSP_MSAF_ANTECIPACAO ';
        v_sql := v_sql || ' ) B ';
        v_sql := v_sql || ' ON ( ';
        v_sql := v_sql || ' A.COD_ESTAB_E = B.COD_ESTAB ';
        v_sql := v_sql || ' AND A.NUM_CONTROLE_DOCTO_E = B.NUM_CONTROLE_DOCTO ';
        v_sql := v_sql || ' AND A.NUM_ITEM_E = B.NUM_ITEM ';
        v_sql := v_sql || ' AND A.BASE_ST_UNIT_E = 0 ';
        v_sql := v_sql || ' ) WHEN MATCHED THEN ';
        v_sql := v_sql || '  UPDATE SET A.VLR_ICMS_ST_UNIT_E = B.VLR_ANTECIP_IST, ';
        v_sql := v_sql || '             A.TOTAL_ICMS_ST      = TRUNC((-1)*(B.VLR_ANTECIP_IST*A.QTD_AJUSTE),4) ';

        EXECUTE IMMEDIATE v_sql;

        loga ( '[MERGE ANTECIP][END][' || SQL%ROWCOUNT || ']'
             , FALSE );
        COMMIT;
    END;

    FUNCTION executar ( p_periodo DATE
                      , p_origem1 VARCHAR2
                      , p_cd1 VARCHAR2
                      , p_origem2 VARCHAR2
                      , p_cd2 VARCHAR2
                      , p_origem3 VARCHAR2
                      , p_cd3 VARCHAR2
                      , p_origem4 VARCHAR2
                      , p_cd4 VARCHAR2
                      , p_compra_direta VARCHAR2
                      , p_filiais VARCHAR2
                      , p_inventario VARCHAR2
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
        a_estabs_full a_estabs_t := a_estabs_t ( );

        --Variaveis genericas
        v_text01 VARCHAR2 ( 6000 );
        v_sep VARCHAR2 ( 1 ) := CHR ( 9 );
        p_proc_instance VARCHAR2 ( 30 );

        --
        TYPE cur_typ IS REF CURSOR;

        cr_cup cur_typ;
        --
        v_aliq_st VARCHAR2 ( 5 ) := '';
        v_pmc NUMBER := 0;
        --TABELAS TEMP
        v_nome_tabela_aliq VARCHAR2 ( 30 );
        v_nome_tabela_pmc VARCHAR2 ( 30 );
        v_tab_perdas_inv VARCHAR2 ( 30 );
        v_tab_perdas_ent_c VARCHAR2 ( 30 );
        v_tab_perdas_ent_f VARCHAR2 ( 30 );
        v_tab_perdas_ent_d VARCHAR2 ( 30 );
        v_tab_perdas_ent_m VARCHAR2 ( 30 );
        v_tab_perdas_tmp VARCHAR2 ( 30 );
        ---
        v_sql_resultado VARCHAR2 ( 2000 );
        v_qtde_inv NUMBER := 0;
        v_qtde_check NUMBER := 0;
        ---
        v_quant_empresas INTEGER := 50; --QUEBRA
        v_parametro VARCHAR2 ( 100 );
        v_data_hora_ini VARCHAR2 ( 20 );

        ------------------------------------------------------------------------------------------------------------------------------------------------------
        --RANGE DE DATAS PARA BUSCAR VENDAS
        v_data_inicial DATE
            := TO_DATE (    '01'
                         || TO_CHAR ( p_periodo
                                    , 'MMYYYY' )
                       , 'DDMMYYYY' ); -- DATA INICIAL
        v_data_final DATE := LAST_DAY ( p_periodo ); -- DATA FINAL

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

        t_idx NUMBER := 0;
    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS='',.'' ';

        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        musuario := lib_parametros.recuperar ( 'USUARIO' );

        --MARCAR INCIO DA EXECUCAO
        v_data_hora_ini :=
            TO_CHAR ( SYSDATE
                    , 'DD/MM/YYYY HH24:MI.SS' );

        mproc_id :=
            lib_proc.new ( 'DPSP_PERDAS_UF_CPROC'
                         , 48
                         , 150 );
        lib_proc.add_tipo ( mproc_id
                          , 1
                          ,    TO_CHAR ( SYSDATE
                                       , 'YYYYMMDDHH24MISS' )
                            || '_CPROC_PERDAS_UF'
                          , 1 );
        lib_proc.add_header ( 'Executar processamento do relatorio de Perdas'
                            , 1
                            , 1 );
        lib_proc.add ( ' ' );

        IF mcod_empresa IS NULL THEN
            lib_proc.add_log ( 'Código da empresa deve ser informado como parâmetro global.'
                             , 0 );
            lib_proc.add ( 'ERRO' );
            lib_proc.add ( 'CÓDIGO DA EMPRESA DEVE SER INFORMADO COMO PARÂMETRO GLOBAL.' );
            lib_proc.close;
            RETURN mproc_id;
        END IF;

        --GERAR CHAVE PROC_ID
        SELECT ROUND ( dbms_random.VALUE ( 10000000000000
                                         , 999999999999999 ) )
          INTO p_proc_instance
          FROM DUAL;

        ---------------------

        loga ( '>>> Inicio do processamento...' || p_proc_instance
             , FALSE );
        loga ( '>> DT INICIAL: ' || v_data_inicial
             , FALSE );
        loga ( '>> DT FINAL: ' || v_data_final
             , FALSE );

        ---CHECAR BLOQUEIO DE PROCESSAMENTO
        IF msafi.get_trava_info ( 'PERDAS_UF'
                                , TO_CHAR ( v_data_inicial
                                          , 'YYYY/MM' ) ) = 'S' THEN
            loga ( '<< PERIODO BLOQUEADO PARA REPROCESSAMENTO >>'
                 , FALSE );
            raise_application_error ( -20001
                                    ,    'PERIODO '
                                      || TO_CHAR ( v_data_inicial
                                                 , 'YYYY/MM' )
                                      || ' BLOQUEADO PARA REPROCESSAMENTO' );

            lib_proc.close;
            COMMIT;
            RETURN mproc_id;
        END IF;

        v_parametro :=
               '['
            || p_periodo
            || ']-['
            || p_origem1
            || ']['
            || p_cd1
            || ']-['
            || p_origem2
            || ']['
            || p_cd2
            || ']-['
            || p_origem3
            || ']['
            || p_cd3
            || ']-['
            || p_origem4
            || ']['
            || p_cd4
            || ']-[CO]['
            || p_compra_direta
            || ']-[MUF]['
            || p_filiais
            || ']-[UF]['
            || p_uf
            || ']';

        --PREPARAR LOJAS
        IF ( p_lojas.COUNT > 0 ) THEN
            i1 := p_lojas.FIRST;

            WHILE i1 IS NOT NULL LOOP
                a_estabs_full.EXTEND ( );
                a_estabs_full ( a_estabs_full.LAST ) := p_lojas ( i1 );
                i1 := p_lojas.NEXT ( i1 );
            END LOOP;
        ELSE
            FOR c1 IN ( SELECT cod_estab
                          FROM msafi.dsp_estabelecimento
                         WHERE cod_empresa = mcod_empresa
                           AND tipo = 'L' ) LOOP
                a_estabs_full.EXTEND ( );
                a_estabs_full ( a_estabs_full.LAST ) := c1.cod_estab;
            END LOOP;
        END IF;

        ----------------------------------------------------------------------------------
        --EXECUTAR FILIAIS POR QUEBRA-----------------------------------------------------
        i1 := 0;

        FOR est IN a_estabs_full.FIRST .. a_estabs_full.COUNT --(99)
                                                             LOOP
            i1 := i1 + 1;
            a_estabs.EXTEND ( );
            a_estabs ( i1 ) := a_estabs_full ( est );

            loga ( '[FILIAL][' || a_estabs ( i1 ) || ']'
                 , FALSE );

            IF MOD ( a_estabs.COUNT
                   , v_quant_empresas ) = 0
            OR ( est = a_estabs_full.COUNT ) --(88)
                                            THEN
                i1 := 0;
                ----------------------------------------------------------------------------------
                ----------------------------------------------------------------------------------

                --CRIAR TABELA TEMP DO INVENTARIO
                create_perdas_inv_tmp ( p_proc_instance
                                      , v_tab_perdas_inv );

                FOR i IN 1 .. a_estabs.COUNT LOOP
                    --OBTER DADOS DE INVENTARIO DO PSFT
                    v_qtde_inv := 0;
                    get_psft_inv ( a_estabs ( i )
                                 , v_data_inicial
                                 , v_data_final
                                 , p_inventario
                                 , p_proc_instance
                                 , v_qtde_inv );

                    IF ( v_qtde_inv > 0 ) THEN
                        load_inv_dados ( p_proc_instance
                                       , a_estabs ( i )
                                       , v_data_inicial
                                       , v_data_final
                                       , v_tab_perdas_inv );
                    END IF;
                END LOOP;

                --

                --CRIAR INDICES DA TEMP DO INVENTARIO
                create_perdas_inv_tmp_idx ( p_proc_instance
                                          , v_tab_perdas_inv );

                --CRIAR E CARREGAR TABELAS TEMP DE ALIQ E PMC DO PEOPLESOFT
                load_aliq_pmc ( p_proc_instance
                              , v_nome_tabela_aliq
                              , v_nome_tabela_pmc
                              , v_tab_perdas_inv );

                --CRIAR TABELA TMP DE ENTRADA
                create_tab_entrada ( p_proc_instance
                                   , v_tab_perdas_ent_c
                                   , v_tab_perdas_ent_f
                                   , v_tab_perdas_ent_d
                                   , v_tab_perdas_ent_m );

                --CARREGAR DADOS DE ORIGEM CD
                IF ( p_origem1 = '2'
                AND p_cd1 IS NOT NULL )
                OR ( p_origem2 = '2'
                AND p_cd2 IS NOT NULL )
                OR ( p_origem3 = '2'
                AND p_cd3 IS NOT NULL )
                OR ( p_origem4 = '2'
                AND p_cd4 IS NOT NULL ) THEN
                    IF ( p_origem1 = '2' ) THEN
                        --CARREGAR TEMPORARIAS ENTRADA NOS CDs
                        load_entradas ( p_proc_instance
                                      , p_cd1
                                      , v_data_inicial
                                      , v_data_final
                                      , 'C'
                                      , v_tab_perdas_ent_c
                                      , v_tab_perdas_inv
                                      , p_cd1
                                      , '' );
                    END IF;

                    IF ( p_origem2 = '2'
                    AND p_cd2 <> p_cd1 ) THEN
                        --CARREGAR TEMPORARIAS ENTRADA NOS CDs
                        load_entradas ( p_proc_instance
                                      , p_cd2
                                      , v_data_inicial
                                      , v_data_final
                                      , 'C'
                                      , v_tab_perdas_ent_c
                                      , v_tab_perdas_inv
                                      , p_cd2
                                      , '' );
                    END IF;

                    IF ( p_origem3 = '2'
                    AND p_cd3 <> p_cd2
                    AND p_cd3 <> p_cd1 ) THEN
                        --CARREGAR TEMPORARIAS ENTRADA NOS CDs
                        load_entradas ( p_proc_instance
                                      , p_cd3
                                      , v_data_inicial
                                      , v_data_final
                                      , 'C'
                                      , v_tab_perdas_ent_c
                                      , v_tab_perdas_inv
                                      , p_cd3
                                      , '' );
                    END IF;

                    IF ( p_origem4 = '2'
                    AND p_cd4 <> p_cd3
                    AND p_cd4 <> p_cd2
                    AND p_cd4 <> p_cd1 ) THEN
                        --CARREGAR TEMPORARIAS ENTRADA NOS CDs
                        load_entradas ( p_proc_instance
                                      , p_cd4
                                      , v_data_inicial
                                      , v_data_final
                                      , 'C'
                                      , v_tab_perdas_ent_c
                                      , v_tab_perdas_inv
                                      , p_cd4
                                      , '' );
                    END IF;

                    --CRIAR INDICES DA TEMP DE ENTRADA CD
                    create_tab_entrada_cd_idx ( p_proc_instance
                                              , v_tab_perdas_ent_c );
                    loga ( '[ENTRADA CD][END]'
                         , FALSE );
                END IF;

                --CARREGAR DADOS ENTRADA EM FILIAIS - TRANSFERENCIA
                IF ( p_origem1 = '1' )
                OR ( p_origem2 = '1' )
                OR ( p_origem3 = '1' )
                OR ( p_origem4 = '1' ) THEN
                    FOR i IN 1 .. a_estabs.COUNT LOOP
                        --CARREGAR TEMPORARIAS ENTRADA NAS FILIAIS
                        EXECUTE IMMEDIATE
                               'SELECT COUNT(*) FROM '
                            || v_tab_perdas_inv
                            || ' WHERE COD_ESTAB = '''
                            || a_estabs ( i )
                            || ''' '
                                       INTO v_qtde_check;

                        IF ( v_qtde_check > 0 ) THEN
                            IF ( p_cd1 IS NOT NULL
                            AND p_origem1 = '1' ) THEN
                                load_entradas ( p_proc_instance
                                              , a_estabs ( i )
                                              , v_data_inicial
                                              , v_data_final
                                              , 'F'
                                              , v_tab_perdas_ent_f
                                              , v_tab_perdas_inv
                                              , p_cd1
                                              , '' );
                            END IF;

                            IF ( p_cd2 IS NOT NULL
                            AND p_origem2 = '1'
                            AND p_cd1 <> p_cd2 ) THEN
                                load_entradas ( p_proc_instance
                                              , a_estabs ( i )
                                              , v_data_inicial
                                              , v_data_final
                                              , 'F'
                                              , v_tab_perdas_ent_f
                                              , v_tab_perdas_inv
                                              , p_cd2
                                              , '' );
                            END IF;

                            IF ( p_cd3 IS NOT NULL
                            AND p_origem3 = '1'
                            AND p_cd3 <> p_cd1
                            AND p_cd3 <> p_cd2 ) THEN
                                load_entradas ( p_proc_instance
                                              , a_estabs ( i )
                                              , v_data_inicial
                                              , v_data_final
                                              , 'F'
                                              , v_tab_perdas_ent_f
                                              , v_tab_perdas_inv
                                              , p_cd3
                                              , '' );
                            END IF;

                            IF ( p_cd4 IS NOT NULL
                            AND p_origem4 = '1'
                            AND p_cd4 <> p_cd1
                            AND p_cd4 <> p_cd2
                            AND p_cd4 <> p_cd3 ) THEN
                                load_entradas ( p_proc_instance
                                              , a_estabs ( i )
                                              , v_data_inicial
                                              , v_data_final
                                              , 'F'
                                              , v_tab_perdas_ent_f
                                              , v_tab_perdas_inv
                                              , p_cd4
                                              , '' );
                            END IF;
                        END IF;
                    END LOOP; --FOR i IN 1..A_ESTABS.COUNT

                    create_tab_ent_filial_idx ( p_proc_instance
                                              , v_tab_perdas_ent_f );
                    loga ( '[ENTRADA FILIAL][END]'
                         , FALSE );
                END IF; --IF (P_ORIGEM1 = '1') OR (P_ORIGEM2 = '1') OR (P_ORIGEM3 = '1') OR (P_ORIGEM4 = '1') THEN

                --CARREGAR DADOS ENTRADA COMPRA DIRETA
                IF ( p_compra_direta = 'S' ) THEN
                    FOR i IN 1 .. a_estabs.COUNT LOOP
                        EXECUTE IMMEDIATE
                               'SELECT COUNT(*) FROM '
                            || v_tab_perdas_inv
                            || ' WHERE COD_ESTAB = '''
                            || a_estabs ( i )
                            || ''' '
                                       INTO v_qtde_check;

                        IF ( v_qtde_check > 0 ) THEN
                            --CARREGAR TEMPORARIAS ENTRADA NAS FILIAIS COMPRA DIRETA
                            load_entradas ( p_proc_instance
                                          , a_estabs ( i )
                                          , v_data_inicial
                                          , v_data_final
                                          , 'CO'
                                          , v_tab_perdas_ent_d
                                          , v_tab_perdas_inv
                                          , ''
                                          , '' );
                        END IF;
                    END LOOP; --FOR i IN 1..A_ESTABS.COUNT

                    create_tab_ent_cdireta_idx ( p_proc_instance
                                               , v_tab_perdas_ent_d );
                    loga ( '[ENTRADA CDIRETA][END]'
                         , FALSE );
                END IF;

                --CARREGAR DADOS ENTRADA FILIAL MESMA UF
                IF ( p_filiais = 'S' ) THEN
                    FOR i IN 1 .. a_estabs.COUNT LOOP
                        EXECUTE IMMEDIATE
                               'SELECT COUNT(*) FROM '
                            || v_tab_perdas_inv
                            || ' WHERE COD_ESTAB = '''
                            || a_estabs ( i )
                            || ''' '
                                       INTO v_qtde_check;

                        IF ( v_qtde_check > 0 ) THEN
                            --CARREGAR TEMPORARIAS ENTRADA NAS FILIAIS MESMA UF
                            load_entradas ( p_proc_instance
                                          , a_estabs ( i )
                                          , v_data_inicial
                                          , v_data_final
                                          , 'E'
                                          , v_tab_perdas_ent_m
                                          , v_tab_perdas_inv
                                          , ''
                                          , v_tab_perdas_ent_f );
                        END IF;
                    END LOOP; --FOR i IN 1..A_ESTABS.COUNT

                    create_tab_ent_mesma_uf_idx ( p_proc_instance
                                                , v_tab_perdas_ent_m );
                    loga ( '[ENTRADA MESMA FILIAL][END]'
                         , FALSE );
                END IF;

                --

                --XREF ENTRADAS COM PMC E ALIQ
                merge_pmc_aliq ( p_proc_instance
                               , v_tab_perdas_ent_c
                               , v_tab_perdas_ent_f
                               , v_tab_perdas_ent_d
                               , v_tab_perdas_ent_m
                               , v_nome_tabela_aliq
                               , v_nome_tabela_pmc );

                --OBTER LISTA DO PRODUTO
                msafi.atualiza_lista;
                loga ( '[LISTA ATUALIZADA]'
                     , FALSE );
                ---MERGE_LISTA(V_TAB_PERDAS_ENT_C, V_TAB_PERDAS_ENT_F, V_TAB_PERDAS_ENT_D, V_TAB_PERDAS_ENT_M);

                --XML-----------------------
                merge_xml ( p_proc_instance
                          , v_tab_perdas_ent_c
                          , v_tab_perdas_ent_f
                          , v_tab_perdas_ent_d
                          , v_tab_perdas_ent_m
                          , p_filiais
                          , p_origem1
                          , p_origem2
                          , p_origem3
                          , p_origem4 );

                --ANTECIPACAO---------------
                get_antecipacao ( p_proc_instance
                                , v_tab_perdas_ent_c
                                , v_tab_perdas_ent_f
                                , v_tab_perdas_ent_d
                                , v_tab_perdas_ent_m );

                --CRIAR TABELA TEMPORARIA COM O RESULTADO
                create_perdas_tmp_tbl ( p_proc_instance
                                      , v_tab_perdas_tmp );

                --LOOP PARA CADA FILIAL-INI--------------------------------------------------------------------------------------
                FOR i IN 1 .. a_estabs.COUNT LOOP
                    --ASSOCIAR SAIDAS COM SUAS ULTIMAS ENTRADAS
                    IF ( p_cd1 IS NOT NULL ) THEN
                        IF ( p_origem1 = '1' ) THEN
                            --ENTRADA NAS FILIAIS
                            get_entradas_filial ( p_proc_instance
                                                , a_estabs ( i )
                                                , p_cd1
                                                , v_data_inicial
                                                , v_data_final
                                                , v_tab_perdas_ent_f
                                                , v_tab_perdas_inv
                                                , v_tab_perdas_tmp );
                        ELSIF ( p_origem1 = '2' ) THEN
                            --ENTRADA NOS CDs
                            get_entradas_cd ( p_proc_instance
                                            , a_estabs ( i )
                                            , p_cd1
                                            , v_data_inicial
                                            , v_data_final
                                            , v_tab_perdas_ent_c
                                            , v_tab_perdas_inv
                                            , v_tab_perdas_tmp );
                        END IF;
                    END IF;

                    IF ( p_cd2 IS NOT NULL ) THEN
                        IF ( p_origem2 = '1' ) THEN
                            --ENTRADA NAS FILIAIS
                            get_entradas_filial ( p_proc_instance
                                                , a_estabs ( i )
                                                , p_cd2
                                                , v_data_inicial
                                                , v_data_final
                                                , v_tab_perdas_ent_f
                                                , v_tab_perdas_inv
                                                , v_tab_perdas_tmp );
                        ELSIF ( p_origem2 = '2' ) THEN
                            --ENTRADA NOS CDs
                            get_entradas_cd ( p_proc_instance
                                            , a_estabs ( i )
                                            , p_cd2
                                            , v_data_inicial
                                            , v_data_final
                                            , v_tab_perdas_ent_c
                                            , v_tab_perdas_inv
                                            , v_tab_perdas_tmp );
                        END IF;
                    END IF;

                    IF ( p_cd3 IS NOT NULL ) THEN
                        IF ( p_origem3 = '1' ) THEN
                            --ENTRADA NAS FILIAIS
                            get_entradas_filial ( p_proc_instance
                                                , a_estabs ( i )
                                                , p_cd3
                                                , v_data_inicial
                                                , v_data_final
                                                , v_tab_perdas_ent_f
                                                , v_tab_perdas_inv
                                                , v_tab_perdas_tmp );
                        ELSIF ( p_origem3 = '2' ) THEN
                            --ENTRADA NOS CDs
                            get_entradas_cd ( p_proc_instance
                                            , a_estabs ( i )
                                            , p_cd3
                                            , v_data_inicial
                                            , v_data_final
                                            , v_tab_perdas_ent_c
                                            , v_tab_perdas_inv
                                            , v_tab_perdas_tmp );
                        END IF;
                    END IF;

                    IF ( p_cd4 IS NOT NULL ) THEN
                        IF ( p_origem4 = '1' ) THEN
                            --ENTRADA NAS FILIAIS
                            get_entradas_filial ( p_proc_instance
                                                , a_estabs ( i )
                                                , p_cd4
                                                , v_data_inicial
                                                , v_data_final
                                                , v_tab_perdas_ent_f
                                                , v_tab_perdas_inv
                                                , v_tab_perdas_tmp );
                        ELSIF ( p_origem4 = '2' ) THEN
                            --ENTRADA NOS CDs
                            get_entradas_cd ( p_proc_instance
                                            , a_estabs ( i )
                                            , p_cd4
                                            , v_data_inicial
                                            , v_data_final
                                            , v_tab_perdas_ent_c
                                            , v_tab_perdas_inv
                                            , v_tab_perdas_tmp );
                        END IF;
                    END IF;

                    IF ( p_compra_direta = 'S' ) THEN
                        get_compra_direta ( p_proc_instance
                                          , a_estabs ( i )
                                          , v_data_inicial
                                          , v_data_final
                                          , v_tab_perdas_ent_d
                                          , v_tab_perdas_inv
                                          , v_tab_perdas_tmp );
                    END IF;

                    IF ( p_filiais = 'S' ) THEN
                        get_entradas_filial_uf ( p_proc_instance
                                               , a_estabs ( i )
                                               , v_data_inicial
                                               , v_data_final
                                               , v_tab_perdas_ent_m
                                               , v_tab_perdas_inv
                                               , v_tab_perdas_tmp );
                    END IF;

                    --SE NAO ACHOU ENTRADA, GRAVAR NA TABELA RESULTADO APENAS A SAIDA
                    get_sem_entrada ( p_proc_instance
                                    , a_estabs ( i )
                                    , v_data_inicial
                                    , v_data_final
                                    , v_tab_perdas_inv
                                    , v_tab_perdas_tmp );
                END LOOP; --FOR i IN 1..A_ESTABS.COUNT

                --LOOP PARA CADA FILIAL-FIM--------------------------------------------------------------------------------------

                --MERGE TAB FINAL COM ANTECIPACAO
                merge_antecipacao ( v_tab_perdas_tmp );

                --LIMPAR DADOS DA TABELA FINAL - SOBREPOR
                FOR i IN 1 .. a_estabs.COUNT LOOP
                    delete_tbl ( a_estabs ( i )
                               , v_data_inicial
                               , v_data_final );
                END LOOP;

                --INSERIR DADOS-INI-------------------------------------------------------------------------------------------
                loga ( '[RESULTADO][INI]' );

                ---INSERIR RESULTADO
                v_sql_resultado := 'INSERT /*+APPEND*/ INTO MSAFI.DPSP_MSAF_PERDAS_UF ( ';
                v_sql_resultado := v_sql_resultado || 'SELECT A.* ';
                v_sql_resultado := v_sql_resultado || ',''' || musuario || ''' ';
                v_sql_resultado := v_sql_resultado || ',SYSDATE FROM ' || v_tab_perdas_tmp || ' A ) ';

                BEGIN
                    EXECUTE IMMEDIATE v_sql_resultado;

                    COMMIT;
                EXCEPTION
                    WHEN OTHERS THEN
                        loga ( 'SQLERRM: ' || SQLERRM
                             , FALSE );
                        loga ( SUBSTR ( v_sql_resultado
                                      , 1
                                      , 1024 )
                             , FALSE );
                        loga ( SUBSTR ( v_sql_resultado
                                      , 1024
                                      , 1024 )
                             , FALSE );
                        loga ( SUBSTR ( v_sql_resultado
                                      , 2048
                                      , 1024 )
                             , FALSE );
                        loga ( SUBSTR ( v_sql_resultado
                                      , 3072 )
                             , FALSE );
                        ---
                        raise_application_error ( -20003
                                                , '!ERRO INSERT RESULTADO FINAL!' );
                END;

                loga ( '[RESULTADO PARCIAL][FIM]' );
                --INSERIR DADOS-FIM-------------------------------------------------------------------------------------------

                ----------------------------------------------------------------------------------
                --EXECUTAR FILIAIS POR QUEBRA-FIM-------------------------------------------------
                delete_temp_tbl ( p_proc_instance );

                a_estabs := a_estabs_t ( );
            END IF;
        END LOOP;

        ----------------------------------------------------------------------------------
        ----------------------------------------------------------------------------------

        --DISPONIBILIZAR PERIODO PROCESSADO PARA TRAVA DE REPROCESSAMENTO
        msafi.add_trava_info ( 'PERDAS_UF'
                             , TO_CHAR ( v_data_inicial
                                       , 'YYYY/MM' ) );

        --ENVIAR EMAIL DE SUCESSO----------------------------------------
        dpsp_envia_email ( mcod_empresa
                         , v_data_inicial
                         , v_data_final
                         , ''
                         , 'S'
                         , v_data_hora_ini
                         , v_parametro
                         , musuario
                         , 'DPSP_PERDAS_UF_CPROC' );
        -----------------------------------------------------------------

        loga ( '<<FIM DO PROCESSAMENTO>>'
             , FALSE );
        lib_proc.close ( );

        COMMIT;
        RETURN mproc_id;
    EXCEPTION
        WHEN OTHERS THEN
            loga ( 'SQLERRM: ' || SQLERRM
                 , FALSE );

            --ENVIAR EMAIL DE ERRO-------------------------------------------
            dpsp_envia_email ( mcod_empresa
                             , v_data_inicial
                             , v_data_final
                             , SQLERRM
                             , 'E'
                             , v_data_hora_ini
                             , v_parametro
                             , musuario
                             , 'DPSP_PERDAS_UF_CPROC' );
            -----------------------------------------------------------------

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
END dpsp_perdas_uf_cproc_bkp;
/
SHOW ERRORS;
