Prompt Package Body DPSP_PERDAS_UF_CPROC;
--
-- DPSP_PERDAS_UF_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_perdas_uf_cproc
IS
    TYPE a_vd_table IS RECORD
    (
        empresa VARCHAR2 ( 3 )
      , dblink VARCHAR2 ( 20 )
      , business_unit VARCHAR2 ( 5 )
      , cnpj VARCHAR2 ( 20 )
    );

    TYPE c_tab_cd IS TABLE OF a_vd_table
        INDEX BY VARCHAR2 ( 7 );

    a_cod_empresa c_tab_cd;

    --VAR PARA TABLES-------------
    v_tab_global_flag VARCHAR2 ( 1 ) := 'N'; --Y SE FOR GERAR TABS GLOBAL TEMP
    v_tab_type VARCHAR2 ( 30 ) := ' ';
    --V_TAB_TYPE        VARCHAR2(30) := ' GLOBAL TEMPORARY ';
    v_tab_footer VARCHAR2 ( 100 )
        := ' STORAGE (BUFFER_POOL KEEP) PCTFREE 10 NOLOGGING NOCOMPRESS CACHE TABLESPACE MSAF_WORK_TABLES ';
    --V_TAB_FOOTER      VARCHAR2(100) := ' STORAGE (BUFFER_POOL KEEP) PCTFREE 10 NOLOGGING NOCOMPRESS CACHE TABLESPACE MSAF_WORK_TABLES ';
    --V_TAB_FOOTER      VARCHAR2(100) := ' ON COMMIT PRESERVE ROWS ';
    ----
    v_audit_pga VARCHAR2 ( 1 ) := 'Y'; --Y GRAVAR DADOS DE UTILIZACAO DA PGA NA ULTIMA ENTRADA

    TYPE t_tab_audit IS TABLE OF msafi.dpsp_audit_resource%ROWTYPE;

    tab_audit t_tab_audit := t_tab_audit ( );

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

        lib_proc.add_param ( pstr
                           , 'Checar Entradas CD1'
                           , --P_CD1
                            'VARCHAR2'
                           , 'TEXTBOX'
                           , 'N'
                           , NULL
                           , '######' );

        lib_proc.add_param ( pstr
                           , 'Origem Entrada CD2'
                           , --P_ORIGEM2
                            'VARCHAR2'
                           , 'RADIOBUTTON'
                           , 'N'
                           , NULL
                           , NULL
                           , '1=Filial (Transferência),2=CD (Compra)' );

        lib_proc.add_param ( pstr
                           , 'Checar Entradas CD2'
                           , --P_CD2
                            'VARCHAR2'
                           , 'TEXTBOX'
                           , 'N'
                           , NULL
                           , '######' );

        lib_proc.add_param ( pstr
                           , 'Origem Entrada CD3'
                           , --P_ORIGEM3
                            'VARCHAR2'
                           , 'RADIOBUTTON'
                           , 'N'
                           , NULL
                           , NULL
                           , '1=Filial (Transferência),2=CD (Compra)' );

        lib_proc.add_param ( pstr
                           , 'Checar Entradas CD3'
                           , --P_CD3
                            'VARCHAR2'
                           , 'TEXTBOX'
                           , 'N'
                           , NULL
                           , '######' );

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

        lib_proc.add_param ( pstr
                           , 'Carregar SOMENTE Dados de Inventário origem ERP SEM Processar o Relatório'
                           , --P_CARGA
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
                             || ''' AND B.IDENT_ESTADO = A.IDENT_ESTADO AND A.COD_EMPRESA = C.COD_EMPRESA AND A.COD_ESTAB = C.COD_ESTAB AND B.COD_ESTADO LIKE :14 AND C.TIPO = ''L'' ORDER BY B.COD_ESTADO, A.COD_ESTAB'
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

    PROCEDURE get_psft_inv ( vp_cod_estab IN VARCHAR2
                           , vp_data_inicial IN VARCHAR2
                           , vp_data_final IN VARCHAR2
                           , vp_inventario IN VARCHAR2
                           , vp_proc_id IN VARCHAR2
                           , v_qtde_inv   OUT NUMBER )
    IS
        v_sql VARCHAR2 ( 3000 );
        v_bugl VARCHAR2 ( 6 );

        TYPE cur_tab_psinv IS RECORD
        (
            loja VARCHAR2 ( 6 )
          , item VARCHAR2 ( 12 )
          , data_inv VARCHAR2 ( 10 )
          , saldo NUMBER ( 12, 4 )
          , ajuste NUMBER ( 12, 4 )
          , custo NUMBER ( 12, 4 )
        );

        TYPE c_tab_ps_inv IS TABLE OF cur_tab_psinv;

        tab_ps_inv c_tab_ps_inv;

        CURSOR c_ps_inv ( p_i_data_ini IN DATE
                        , p_i_data_fim IN DATE
                        , p_i_bu_gl IN VARCHAR2
                        , p_i_cod_estab IN VARCHAR2 )
        IS
            SELECT /*+DRIVING_SITE(DB_PS)*/
                  est.cod_estab
                   , NVL ( db_ps.item, ' ' )
                   , NVL ( db_ps.data_inv
                         , TO_CHAR ( p_i_data_fim
                                   , 'DD/MM/YYYY' ) )
                   , NVL ( SUM ( db_ps.saldo ), 0 ) AS saldo
                   , NVL ( SUM ( db_ps.ajuste ), 0 ) AS ajuste
                   , NVL ( MAX ( db_ps.custo ), 0 ) AS custo
                FROM (SELECT a.business_unit AS loja
                           , a.inv_item_id AS item
                           , TO_CHAR ( a.dsp_dt_refer
                                     , 'DD/MM/YYYY' )
                                 AS data_inv
                           , a.dsp_qtd_sld_log AS saldo
                           , a.dsp_dif_qtd_num AS ajuste
                           , a.price_vndr AS custo
                        FROM msafi.ps_dsp_contbal_hst a
                           , msafi.ps_bus_unit_tbl_in b
                       WHERE dsp_dt_refer BETWEEN p_i_data_ini AND p_i_data_fim
                         AND a.business_unit = b.business_unit
                         AND b.business_unit_gl = p_i_bu_gl
                         AND LTRIM ( REGEXP_REPLACE ( a.business_unit
                                                    , 'V|D|L'
                                                    , '' )
                                   , '0' ) = LTRIM ( REGEXP_REPLACE ( p_i_cod_estab
                                                                    , 'D|S|P'
                                                                    , '' )
                                                   , '0' )) db_ps
                   , msafi.dsp_estabelecimento est
               WHERE est.cod_empresa = msafi.dpsp.empresa
                 AND est.cod_estab = p_i_cod_estab
                 AND LTRIM ( REGEXP_REPLACE ( est.cod_estab
                                            , 'D|S|P'
                                            , '' )
                           , '0' ) = LTRIM ( REGEXP_REPLACE ( db_ps.loja(+)
                                                            , 'V|D|L'
                                                            , '' )
                                           , '0' )
            GROUP BY est.cod_estab
                   , db_ps.item
                   , db_ps.data_inv;
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
                BEGIN
                    SELECT COUNT ( * )
                      INTO v_qtde_inv
                      FROM msafi.dpsp_msaf_perdas_inv
                     WHERE cod_estab = vp_cod_estab
                       AND cod_produto = ' ' ---SEM MOVIMENTO
                       AND data_inv BETWEEN TO_DATE ( vp_data_inicial
                                                    , 'DD/MM/YYYY' )
                                        AND TO_DATE ( vp_data_final
                                                    , 'DD/MM/YYYY' );
                EXCEPTION
                    WHEN OTHERS THEN
                        v_qtde_inv := 0;
                END;
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

                loga ( '[' || vp_cod_estab || '][DEL INV]:' || SQL%ROWCOUNT
                     , FALSE );
                COMMIT;

                OPEN c_ps_inv ( vp_data_inicial
                              , vp_data_final
                              , v_bugl
                              , vp_cod_estab );

                LOOP
                    FETCH c_ps_inv
                        BULK COLLECT INTO tab_ps_inv
                        LIMIT 100;

                    EXIT WHEN c_ps_inv%NOTFOUND;

                    FORALL i IN tab_ps_inv.FIRST .. tab_ps_inv.LAST
                        INSERT /*+APPEND_VALUES*/
                              INTO  msafi.dpsp_msaf_perdas_inv
                             VALUES ( SUBSTR ( vp_proc_id
                                             , 1
                                             , 10 )
                                    , REPLACE ( REPLACE ( tab_ps_inv ( i ).loja
                                                        , 'VD'
                                                        , 'DSP' )
                                              , 'L'
                                              , 'DP' )
                                    , tab_ps_inv ( i ).item
                                    , tab_ps_inv ( i ).data_inv
                                    , tab_ps_inv ( i ).saldo
                                    , 0
                                    , tab_ps_inv ( i ).ajuste
                                    , tab_ps_inv ( i ).custo
                                    , 'N' );

                    COMMIT;
                END LOOP;

                COMMIT;

                loga ( '[SOBREPOR ' || vp_cod_estab || ']'
                     , FALSE );
            ELSE ---JA EXISTE
                loga ( '[EXISTE INV ' || vp_cod_estab || ']:' || v_qtde_inv
                     , FALSE );
            END IF;
        ELSE
            --OBTER DADOS DE INVENTARIO DO ERP
            OPEN c_ps_inv ( vp_data_inicial
                          , vp_data_final
                          , v_bugl
                          , vp_cod_estab );

            LOOP
                FETCH c_ps_inv
                    BULK COLLECT INTO tab_ps_inv
                    LIMIT 100;

                FORALL i IN tab_ps_inv.FIRST .. tab_ps_inv.LAST
                    INSERT /*+APPEND_VALUES*/
                          INTO  msafi.dpsp_msaf_perdas_inv
                         VALUES ( SUBSTR ( vp_proc_id
                                         , 1
                                         , 10 )
                                , REPLACE ( REPLACE ( tab_ps_inv ( i ).loja
                                                    , 'VD'
                                                    , 'DSP' )
                                          , 'L'
                                          , 'DP' )
                                , tab_ps_inv ( i ).item
                                , tab_ps_inv ( i ).data_inv
                                , tab_ps_inv ( i ).saldo
                                , 0
                                , tab_ps_inv ( i ).ajuste
                                , tab_ps_inv ( i ).custo
                                , 'N' );

                COMMIT;
                EXIT WHEN c_ps_inv%NOTFOUND;
            END LOOP;

            COMMIT;

            loga ( '[INSERT ' || vp_cod_estab || ']'
                 , FALSE );
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

    FUNCTION create_perdas_inv_tmp ( vp_proc_instance IN VARCHAR2
                                   , v_tab_global_flag IN VARCHAR2
                                   , v_tab_type IN VARCHAR2
                                   , v_tab_footer IN VARCHAR2 )
        RETURN VARCHAR2
    IS
        v_sql VARCHAR2 ( 1000 );
        vp_tab_perdas_inv VARCHAR2 ( 30 );
        v_qtde INTEGER;
    BEGIN
        vp_tab_perdas_inv := 'DPSP_P_INV_' || vp_proc_instance;

        v_sql := 'CREATE ' || v_tab_type || ' TABLE ' || vp_tab_perdas_inv || ' ';
        v_sql := v_sql || '( ';
        v_sql := v_sql || '  PROC_ID     NUMBER(30), ';
        v_sql := v_sql || '  COD_ESTAB   VARCHAR2(6), ';
        v_sql := v_sql || '  COD_PRODUTO VARCHAR2(25), ';
        v_sql := v_sql || '  DATA_INV    DATE, ';
        v_sql := v_sql || '  QTD_AJUSTE  NUMBER(15,2) ';
        v_sql := v_sql || ') ';
        v_sql := v_sql || v_tab_footer;

        EXECUTE IMMEDIATE v_sql;

        ---

        save_tmp_control ( vp_proc_instance
                         , vp_tab_perdas_inv );

        IF ( v_tab_global_flag = 'Y' ) THEN --SE GLOBAL TEMP
            v_sql := 'CREATE UNIQUE INDEX PK_PINV_' || vp_proc_instance || ' ON ' || vp_tab_perdas_inv || ' ';
            v_sql := v_sql || '( ';
            v_sql := v_sql || ' PROC_ID    ASC, ';
            v_sql := v_sql || ' COD_ESTAB   ASC, ';
            v_sql := v_sql || ' COD_PRODUTO  ASC ';
            v_sql := v_sql || ') ';

            EXECUTE IMMEDIATE v_sql;

            v_sql := 'CREATE INDEX IDX1_PINV_' || vp_proc_instance || ' ON ' || vp_tab_perdas_inv || ' ';
            v_sql := v_sql || '( ';
            v_sql := v_sql || ' PROC_ID    ASC, ';
            v_sql := v_sql || ' COD_ESTAB   ASC, ';
            v_sql := v_sql || ' COD_PRODUTO  ASC, ';
            v_sql := v_sql || ' DATA_INV ASC ';
            v_sql := v_sql || ') ';

            EXECUTE IMMEDIATE v_sql;

            dbms_stats.gather_table_stats ( 'MSAF'
                                          , vp_tab_perdas_inv );

            EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || vp_tab_perdas_inv            INTO v_qtde;

            loga ( '[' || vp_tab_perdas_inv || ' G]:' || v_qtde
                 , FALSE );
        END IF;

        RETURN vp_tab_perdas_inv;
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
        v_sql := v_sql || '  PCTFREE 10 NOLOGGING ';

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX1_PINV_' || vp_proc_instance || ' ON ' || vp_tab_perdas_inv || ' ';
        v_sql := v_sql || '( ';
        v_sql := v_sql || ' PROC_ID    ASC, ';
        v_sql := v_sql || ' COD_ESTAB   ASC, ';
        v_sql := v_sql || ' COD_PRODUTO  ASC, ';
        v_sql := v_sql || ' DATA_INV ASC ';
        v_sql := v_sql || ') ';
        v_sql := v_sql || '  PCTFREE 10 NOLOGGING ';

        EXECUTE IMMEDIATE v_sql;

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_tab_perdas_inv );

        EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || vp_tab_perdas_inv            INTO v_qtde;

        loga ( '[' || vp_tab_perdas_inv || ']:' || v_qtde
             , FALSE );
    END;

    PROCEDURE create_tab_entrada_cd_idx ( vp_proc_instance IN NUMBER
                                        , vp_tab_entrada_cd IN VARCHAR2
                                        , v_tab_global_flag IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 2000 );
        v_idx_footer VARCHAR2 ( 100 ) := ' ';
        v_qtde NUMBER;
    BEGIN
        IF ( v_tab_global_flag = 'N' ) THEN
            v_idx_footer := ' PCTFREE 10 NOLOGGING TABLESPACE MSAF_WORK_INDEXES ';
        --V_IDX_FOOTER := ' PCTFREE 10 NOLOGGING TABLESPACE MSAFI_G_INDEXES ';
        END IF;

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
        v_sql := v_sql || ') ' || v_idx_footer;

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX1_P_E_C_' || vp_proc_instance || ' ON ' || vp_tab_entrada_cd || ' ';
        v_sql := v_sql || '( ';
        v_sql := v_sql || ' COD_PRODUTO_E ASC, ';
        v_sql := v_sql || ' DATA_FISCAL_E ASC ';
        v_sql := v_sql || ' ) ' || v_idx_footer;

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX2_P_E_C_' || vp_proc_instance || ' ON ' || vp_tab_entrada_cd || ' ';
        v_sql := v_sql || '( ';
        v_sql := v_sql || ' NUM_AUTENTIC_NFE_E ASC, ';
        v_sql := v_sql || ' COD_PRODUTO_E ASC, ';
        v_sql := v_sql || ' QUANTIDADE_E ASC ';
        v_sql := v_sql || ') ' || v_idx_footer;

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX3_P_E_C_' || vp_proc_instance || ' ON ' || vp_tab_entrada_cd || ' ';
        v_sql := v_sql || '( ';
        v_sql := v_sql || ' NUM_AUTENTIC_NFE_E ASC, ';
        v_sql := v_sql || ' NUM_ITEM_E ASC, ';
        v_sql := v_sql || ' COD_PRODUTO_E ASC ';
        v_sql := v_sql || ') ' || v_idx_footer;

        EXECUTE IMMEDIATE v_sql;

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_tab_entrada_cd );

        EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || vp_tab_entrada_cd            INTO v_qtde;

        loga ( '[' || vp_tab_entrada_cd || '][LOAD END][' || v_qtde || ']'
             , FALSE );
    END;

    PROCEDURE create_tab_ent_filial_idx ( vp_proc_instance IN NUMBER
                                        , vp_tab_entrada_f IN VARCHAR2
                                        , v_tab_global_flag IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 1000 );
        v_idx_footer VARCHAR2 ( 100 ) := ' ';
        v_qtde NUMBER;
    BEGIN
        IF ( v_tab_global_flag = 'N' ) THEN
            v_idx_footer := ' PCTFREE 10 NOLOGGING TABLESPACE MSAF_WORK_INDEXES ';
        --V_IDX_FOOTER := ' PCTFREE 10 NOLOGGING TABLESPACE MSAFI_G_INDEXES ';
        END IF;

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
        v_sql := v_sql || ') ' || v_idx_footer;

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX1_P_E_F_' || vp_proc_instance || ' ON ' || vp_tab_entrada_f || ' ';
        v_sql := v_sql || '( ';
        v_sql := v_sql || ' COD_PRODUTO_E ASC, ';
        v_sql := v_sql || ' DATA_FISCAL_E ASC ';
        v_sql := v_sql || ' ) ' || v_idx_footer;

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX2_P_E_F_' || vp_proc_instance || ' ON ' || vp_tab_entrada_f || ' ';
        v_sql := v_sql || '( ';
        v_sql := v_sql || ' NUM_AUTENTIC_NFE_E ASC ';
        v_sql := v_sql || ' ) ' || v_idx_footer;

        EXECUTE IMMEDIATE v_sql;

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_tab_entrada_f );

        EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || vp_tab_entrada_f            INTO v_qtde;

        loga ( '[' || vp_tab_entrada_f || '][LOAD END][' || v_qtde || ']'
             , FALSE );
    END;

    PROCEDURE create_tab_ent_cdireta_idx ( vp_proc_instance IN NUMBER
                                         , vp_tab_entrada_d IN VARCHAR2
                                         , v_tab_global_flag IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 1000 );
        v_idx_footer VARCHAR2 ( 100 ) := ' ';
    BEGIN
        IF ( v_tab_global_flag = 'N' ) THEN
            v_idx_footer := ' PCTFREE 10 NOLOGGING TABLESPACE MSAF_WORK_INDEXES ';
        --V_IDX_FOOTER := ' PCTFREE 10 NOLOGGING TABLESPACE MSAFI_G_INDEXES ';
        END IF;

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
        v_sql := v_sql || ') ' || v_idx_footer;

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX1_P_E_D_' || vp_proc_instance || ' ON ' || vp_tab_entrada_d || ' ';
        v_sql := v_sql || '( ';
        v_sql := v_sql || ' COD_PRODUTO_E ASC, ';
        v_sql := v_sql || ' DATA_FISCAL_E ASC ';
        v_sql := v_sql || ' ) ' || v_idx_footer;

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX2_P_E_D_' || vp_proc_instance || ' ON ' || vp_tab_entrada_d || ' ';
        v_sql := v_sql || '( ';
        v_sql := v_sql || ' NUM_AUTENTIC_NFE_E ASC, ';
        v_sql := v_sql || ' COD_PRODUTO_E ASC, ';
        v_sql := v_sql || ' QUANTIDADE_E ASC ';
        v_sql := v_sql || ') ' || v_idx_footer;

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX3_P_E_D_' || vp_proc_instance || ' ON ' || vp_tab_entrada_d || ' ';
        v_sql := v_sql || '( ';
        v_sql := v_sql || ' NUM_AUTENTIC_NFE_E ASC, ';
        v_sql := v_sql || ' NUM_ITEM_E ASC, ';
        v_sql := v_sql || ' COD_PRODUTO_E ASC ';
        v_sql := v_sql || ') ' || v_idx_footer;

        EXECUTE IMMEDIATE v_sql;

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_tab_entrada_d );
        loga ( '[' || vp_tab_entrada_d || '][LOAD END]'
             , FALSE );
    END;

    PROCEDURE create_tab_ent_mesma_uf_idx ( vp_proc_instance IN NUMBER
                                          , vp_tab_entrada_m IN VARCHAR2
                                          , v_tab_global_flag IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 1000 );
        v_idx_footer VARCHAR2 ( 100 ) := ' ';
    BEGIN
        IF ( v_tab_global_flag = 'N' ) THEN
            v_idx_footer := ' PCTFREE 10 NOLOGGING TABLESPACE MSAF_WORK_INDEXES ';
        --V_IDX_FOOTER := ' PCTFREE 10 NOLOGGING TABLESPACE MSAFI_G_INDEXES ';
        END IF;

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
        v_sql := v_sql || ') ' || v_idx_footer;

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX1_P_E_M_' || vp_proc_instance || ' ON ' || vp_tab_entrada_m || ' ';
        v_sql := v_sql || '( ';
        v_sql := v_sql || ' COD_PRODUTO_E ASC, ';
        v_sql := v_sql || ' DATA_FISCAL_E ASC ';
        v_sql := v_sql || ' ) ' || v_idx_footer;

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX2_P_E_M_' || vp_proc_instance || ' ON ' || vp_tab_entrada_m || ' ';
        v_sql := v_sql || '( ';
        v_sql := v_sql || ' PROC_ID ASC, ';
        v_sql := v_sql || ' COD_ESTAB_E ASC, ';
        v_sql := v_sql || ' COD_PRODUTO_E ASC, ';
        v_sql := v_sql || ' DATA_INV_S ASC ';
        v_sql := v_sql || ' ) ' || v_idx_footer;

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX3_P_E_M_' || vp_proc_instance || ' ON ' || vp_tab_entrada_m || ' ';
        v_sql := v_sql || '( ';
        v_sql := v_sql || ' COD_ESTAB_E ASC, ';
        v_sql := v_sql || ' COD_PRODUTO_E ASC, ';
        v_sql := v_sql || ' DATA_INV_S ASC ';
        v_sql := v_sql || ' ) ' || v_idx_footer;

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX4_P_E_M_' || vp_proc_instance || ' ON ' || vp_tab_entrada_m || ' ';
        v_sql := v_sql || '( ';
        v_sql := v_sql || ' NUM_AUTENTIC_NFE_E ASC ';
        v_sql := v_sql || ' ) ' || v_idx_footer;

        EXECUTE IMMEDIATE v_sql;

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_tab_entrada_m );
        loga ( '[' || vp_tab_entrada_m || '][LOAD END]'
             , FALSE );
    END;

    PROCEDURE create_tab_entrada ( vp_proc_instance IN NUMBER
                                 , vp_tab_entrada_c   OUT VARCHAR2
                                 , vp_tab_perdas_ent_f   OUT VARCHAR2
                                 , vp_tab_perdas_ent_d   OUT VARCHAR2
                                 , vp_tab_perdas_ent_m   OUT VARCHAR2
                                 , v_tab_global_flag IN VARCHAR2
                                 , v_tab_type IN VARCHAR2
                                 , v_tab_footer IN VARCHAR2 )
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
        v_sql := v_sql || ' BUSINESS_UNIT         VARCHAR2(5), ';
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
        v_sql := v_sql || v_tab_footer;

        ---CRIAR TEMP DE ENTRADA
        vp_tab_entrada_c := 'DPSP_ENT_CD_' || vp_proc_instance;
        vp_tab_perdas_ent_f := 'DPSP_ENT_FI_' || vp_proc_instance;
        vp_tab_perdas_ent_d := 'DPSP_ENT_CO_' || vp_proc_instance;
        vp_tab_perdas_ent_m := 'DPSP_ENT_MU_' || vp_proc_instance;

        v_sql1 := 'CREATE ' || v_tab_type || ' TABLE ' || vp_tab_entrada_c || ' ( ';

        EXECUTE IMMEDIATE v_sql1 || v_sql;

        save_tmp_control ( vp_proc_instance
                         , vp_tab_entrada_c );

        IF ( v_tab_global_flag = 'Y' ) THEN
            create_tab_entrada_cd_idx ( vp_proc_instance
                                      , vp_tab_entrada_c
                                      , v_tab_global_flag );
        END IF;

        v_sql1 := 'CREATE ' || v_tab_type || ' TABLE ' || vp_tab_perdas_ent_f || ' ( ';

        EXECUTE IMMEDIATE v_sql1 || v_sql;

        save_tmp_control ( vp_proc_instance
                         , vp_tab_perdas_ent_f );

        IF ( v_tab_global_flag = 'Y' ) THEN
            create_tab_ent_filial_idx ( vp_proc_instance
                                      , vp_tab_perdas_ent_f
                                      , v_tab_global_flag );
        END IF;

        v_sql1 := 'CREATE ' || v_tab_type || ' TABLE ' || vp_tab_perdas_ent_d || ' ( ';

        EXECUTE IMMEDIATE v_sql1 || v_sql;

        save_tmp_control ( vp_proc_instance
                         , vp_tab_perdas_ent_d );

        IF ( v_tab_global_flag = 'Y' ) THEN
            create_tab_ent_cdireta_idx ( vp_proc_instance
                                       , vp_tab_perdas_ent_d
                                       , v_tab_global_flag );
        END IF;

        v_sql1 := 'CREATE ' || v_tab_type || ' TABLE ' || vp_tab_perdas_ent_m || ' ( ';

        EXECUTE IMMEDIATE v_sql1 || v_sql;

        save_tmp_control ( vp_proc_instance
                         , vp_tab_perdas_ent_m );

        IF ( v_tab_global_flag = 'Y' ) THEN
            create_tab_ent_mesma_uf_idx ( vp_proc_instance
                                        , vp_tab_perdas_ent_m
                                        , v_tab_global_flag );
        END IF;
    END;

    PROCEDURE create_tab_ent_x ( vp_proc_id IN NUMBER
                               , v_tab_x07   OUT VARCHAR2
                               , v_tab_x08   OUT VARCHAR2
                               , v_tab_global_flag IN VARCHAR2
                               , v_tab_type IN VARCHAR2
                               , v_tab_footer IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 5000 );
        v_idx_footer VARCHAR2 ( 100 );
    BEGIN
        IF ( v_tab_global_flag = 'N' ) THEN
            v_idx_footer := ' PCTFREE 10 NOLOGGING TABLESPACE MSAF_WORK_INDEXES ';
        --V_IDX_FOOTER := ' PCTFREE 10 NOLOGGING TABLESPACE MSAFI_G_INDEXES ';
        END IF;

        v_tab_x07 := 'DP$P_X07_' || vp_proc_id;
        v_tab_x08 := 'DP$P_X08_' || vp_proc_id;

        v_sql := 'CREATE ' || v_tab_type || ' TABLE ' || v_tab_x07;
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || ' COD_EMPRESA          VARCHAR2(3 BYTE), ';
        v_sql := v_sql || ' COD_ESTAB            VARCHAR2(6 BYTE), ';
        v_sql := v_sql || ' DATA_FISCAL          DATE, ';
        v_sql := v_sql || ' MOVTO_E_S            CHAR(1 BYTE), ';
        v_sql := v_sql || ' NORM_DEV             CHAR(1 BYTE), ';
        v_sql := v_sql || ' IDENT_DOCTO          NUMBER(12), ';
        v_sql := v_sql || ' IDENT_FIS_JUR        NUMBER(12), ';
        v_sql := v_sql || ' NUM_DOCFIS           VARCHAR2(12 BYTE), ';
        v_sql := v_sql || ' SERIE_DOCFIS         VARCHAR2(3 BYTE), ';
        v_sql := v_sql || ' SUB_SERIE_DOCFIS     VARCHAR2(2 BYTE), ';
        v_sql := v_sql || ' VLR_PRODUTO          NUMBER(17,2), ';
        v_sql := v_sql || ' DATA_EMISSAO         DATE, ';
        v_sql := v_sql || ' NUM_CONTROLE_DOCTO   VARCHAR2(12), ';
        v_sql := v_sql || ' NUM_AUTENTIC_NFE     VARCHAR2(80) ) ';
        v_sql := v_sql || v_tab_footer;

        EXECUTE IMMEDIATE v_sql;

        save_tmp_control ( vp_proc_id
                         , v_tab_x07 );

        v_sql := 'CREATE ' || v_tab_type || ' TABLE ' || v_tab_x08;
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || ' COD_EMPRESA          VARCHAR2(3 BYTE), ';
        v_sql := v_sql || ' COD_ESTAB            VARCHAR2(6 BYTE), ';
        v_sql := v_sql || ' DATA_FISCAL          DATE, ';
        v_sql := v_sql || ' MOVTO_E_S            CHAR(1 BYTE), ';
        v_sql := v_sql || ' NORM_DEV             CHAR(1 BYTE), ';
        v_sql := v_sql || ' IDENT_DOCTO          NUMBER(12), ';
        v_sql := v_sql || ' IDENT_FIS_JUR        NUMBER(12), ';
        v_sql := v_sql || ' NUM_DOCFIS           VARCHAR2(12 BYTE), ';
        v_sql := v_sql || ' SERIE_DOCFIS         VARCHAR2(3 BYTE), ';
        v_sql := v_sql || ' SUB_SERIE_DOCFIS     VARCHAR2(2 BYTE), ';
        v_sql := v_sql || ' DISCRI_ITEM          VARCHAR2(46 BYTE), ';
        v_sql := v_sql || ' NUM_ITEM             NUMBER(5), ';
        v_sql := v_sql || ' IDENT_NBM            NUMBER(12), ';
        v_sql := v_sql || ' IDENT_CFO            NUMBER(12), ';
        v_sql := v_sql || ' IDENT_NATUREZA_OP    NUMBER(12), ';
        v_sql := v_sql || ' IDENT_PRODUTO        NUMBER(12), ';
        v_sql := v_sql || ' VLR_CONTAB_ITEM      NUMBER(17,2), ';
        v_sql := v_sql || ' QUANTIDADE           NUMBER(17,6), ';
        v_sql := v_sql || ' VLR_UNIT             NUMBER, ';
        v_sql := v_sql || ' IDENT_SITUACAO_B     NUMBER(12), ';
        v_sql := v_sql || ' IDENT_SITUACAO_A     NUMBER(12), ';
        v_sql := v_sql || ' COD_SITUACAO_PIS     NUMBER(2), ';
        v_sql := v_sql || ' COD_SITUACAO_COFINS  NUMBER(2), ';
        v_sql := v_sql || ' ESTORNO_PIS_E        NUMBER, ';
        v_sql := v_sql || ' ESTORNO_COFINS_E     NUMBER, ';
        v_sql := v_sql || ' VLR_PIS              NUMBER(17,2), ';
        v_sql := v_sql || ' VLR_COFINS           NUMBER(17,2) ) ';
        v_sql := v_sql || v_tab_footer;

        EXECUTE IMMEDIATE v_sql;

        save_tmp_control ( vp_proc_id
                         , v_tab_x08 );

        ---INDEX
        v_sql := 'CREATE UNIQUE INDEX PK_CX07_' || vp_proc_id || ' ON ' || v_tab_x07;
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || ' COD_EMPRESA      ASC, ';
        v_sql := v_sql || ' COD_ESTAB        ASC, ';
        v_sql := v_sql || ' DATA_FISCAL      ASC, ';
        v_sql := v_sql || ' MOVTO_E_S        ASC, ';
        v_sql := v_sql || ' NORM_DEV         ASC, ';
        v_sql := v_sql || ' IDENT_DOCTO      ASC, ';
        v_sql := v_sql || ' IDENT_FIS_JUR    ASC, ';
        v_sql := v_sql || ' NUM_DOCFIS       ASC, ';
        v_sql := v_sql || ' SERIE_DOCFIS     ASC, ';
        v_sql := v_sql || ' SUB_SERIE_DOCFIS ASC ) ';

        EXECUTE IMMEDIATE v_sql || v_idx_footer;

        v_sql := 'CREATE INDEX IDX1_CX07_' || vp_proc_id || ' ON ' || v_tab_x07;
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || ' COD_EMPRESA      ASC, ';
        v_sql := v_sql || ' VLR_PRODUTO      ASC, ';
        v_sql := v_sql || ' COD_ESTAB        ASC, ';
        v_sql := v_sql || ' DATA_FISCAL      ASC, ';
        v_sql := v_sql || ' IDENT_FIS_JUR    ASC ) ';

        EXECUTE IMMEDIATE v_sql || v_idx_footer;

        v_sql := 'CREATE UNIQUE INDEX PK_CX08_' || vp_proc_id || ' ON ' || v_tab_x08;
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || ' COD_EMPRESA      ASC, ';
        v_sql := v_sql || ' COD_ESTAB        ASC, ';
        v_sql := v_sql || ' DATA_FISCAL      ASC, ';
        v_sql := v_sql || ' MOVTO_E_S        ASC, ';
        v_sql := v_sql || ' NORM_DEV         ASC, ';
        v_sql := v_sql || ' IDENT_DOCTO      ASC, ';
        v_sql := v_sql || ' IDENT_FIS_JUR    ASC, ';
        v_sql := v_sql || ' NUM_DOCFIS       ASC, ';
        v_sql := v_sql || ' SERIE_DOCFIS     ASC, ';
        v_sql := v_sql || ' SUB_SERIE_DOCFIS ASC, ';
        v_sql := v_sql || ' DISCRI_ITEM      ASC ) ';

        EXECUTE IMMEDIATE v_sql || v_idx_footer;
    END;

    --PROCEDURE PARA CRIAR TABELAS TEMP DE ALIQ E PMC
    PROCEDURE load_aliq_pmc ( vp_proc_id IN NUMBER
                            , vp_nome_tabela_aliq   OUT VARCHAR2
                            , vp_nome_tabela_pmc   OUT VARCHAR2
                            , vp_tab_perdas_inv IN VARCHAR2
                            , v_tab_global_flag IN VARCHAR2
                            , v_tab_type IN VARCHAR2
                            , v_tab_footer IN VARCHAR2 )
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

        v_sql := 'CREATE ' || v_tab_type || ' TABLE ' || vp_nome_tabela_aliq;
        v_sql := v_sql || ' (';
        v_sql := v_sql || 'PROC_ID     NUMBER(30),';
        v_sql := v_sql || 'COD_PRODUTO VARCHAR2(25),';
        v_sql := v_sql || 'ALIQ_ST     VARCHAR2(4) )';
        v_sql := v_sql || v_tab_footer;

        EXECUTE IMMEDIATE v_sql;

        ---
        save_tmp_control ( vp_proc_id
                         , vp_nome_tabela_aliq );

        v_sql := 'CREATE INDEX PK_ALIQ_' || vp_proc_id || ' ON ' || vp_nome_tabela_aliq;
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || '   PROC_ID     ASC,';
        v_sql := v_sql || '   COD_PRODUTO ASC ';
        v_sql := v_sql || ' ) ';

        IF ( v_tab_global_flag = 'N' ) THEN
            v_sql := v_sql || ' PCTFREE 10 NOLOGGING';
        END IF;

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX1_ALIQ_' || vp_proc_id || ' ON ' || vp_nome_tabela_aliq;
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || '   PROC_ID     ASC,';
        v_sql := v_sql || '   COD_PRODUTO ASC, ';
        v_sql := v_sql || '   ALIQ_ST     ASC ';
        v_sql := v_sql || ' ) ';

        IF ( v_tab_global_flag = 'N' ) THEN
            v_sql := v_sql || ' PCTFREE 10 NOLOGGING';
        END IF;

        EXECUTE IMMEDIATE v_sql;

        -------------
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
                       'INSERT INTO '
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

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_nome_tabela_aliq );
        loga ( '[' || vp_nome_tabela_aliq || '][LOAD END]'
             , FALSE );

        -------------------------------------------------------------------------------------
        vp_nome_tabela_pmc := 'DPSP_MSAF_PMC_' || vp_proc_id;

        v_sql := 'CREATE ' || v_tab_type || ' TABLE ' || vp_nome_tabela_pmc || v_tab_footer || ' AS ';
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

        save_tmp_control ( vp_proc_id
                         , vp_nome_tabela_pmc );

        IF ( v_tab_global_flag = 'N' ) THEN
            v_sql := 'CREATE INDEX PK_PMC_' || vp_proc_id || ' ON ' || vp_nome_tabela_pmc;
            v_sql := v_sql || ' ( ';
            v_sql := v_sql || '   PROC_ID     ASC, ';
            v_sql := v_sql || '   COD_PRODUTO ASC ';
            v_sql := v_sql || ' ) ';
            v_sql := v_sql || ' PCTFREE 10 NOLOGGING';

            EXECUTE IMMEDIATE v_sql;
        END IF;

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_nome_tabela_pmc );
        loga ( '[' || vp_nome_tabela_pmc || '][LOAD END]'
             , FALSE );
    END;

    PROCEDURE create_perdas_tmp_tbl ( vp_proc_instance IN NUMBER
                                    , vp_tab_perdas_tmp   OUT VARCHAR2
                                    , v_tab_global_flag IN VARCHAR2
                                    , v_tab_type IN VARCHAR2
                                    , v_tab_footer IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 4000 );
    BEGIN
        vp_tab_perdas_tmp := 'DPSP_PERDAS_' || vp_proc_instance;

        v_sql := 'CREATE ' || v_tab_type || ' TABLE ' || vp_tab_perdas_tmp || ' ( ';
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
        v_sql := v_sql || v_tab_footer;

        EXECUTE IMMEDIATE v_sql;

        save_tmp_control ( vp_proc_instance
                         , vp_tab_perdas_tmp );

        v_sql := 'CREATE UNIQUE INDEX PK_PERDAS_' || vp_proc_instance || ' ON ' || vp_tab_perdas_tmp || ' ';
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || ' COD_EMPRESA ASC, ';
        v_sql := v_sql || ' COD_ESTAB   ASC, ';
        v_sql := v_sql || ' DATA_INV    ASC, ';
        v_sql := v_sql || ' COD_PRODUTO ASC ';
        v_sql := v_sql || ' ) ';

        IF ( v_tab_global_flag = 'N' ) THEN
            v_sql := v_sql || 'PCTFREE 10 NOLOGGING';
        END IF;

        EXECUTE IMMEDIATE v_sql;
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
    --LOGA('[ENT CD][' || VP_CD || ']-[FILIAL][' || VP_FILIAL || ']', FALSE);

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
        v_sql := v_sql || '   AND B.CPF_CGC_E        = ''' || a_cod_empresa ( vp_cd ).cnpj || ''' ';
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
    ---LOGA('[ENT FILIAL][' || VP_FILIAL || '] << [CD][' || VP_CD || ']', FALSE);

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
    ---LOGA('[C DIRETA][' || VP_FILIAL || ']', FALSE);

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
    ---LOGA('[ENT FILIAL UF][' || VP_FILIAL || ']', FALSE);

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
        v_sql := v_sql || '   AND P.IDENT_PRODUTO = (SELECT MAX(PP.IDENT_PRODUTO) ';
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
    ---LOGA('[SEM ENT][' || VP_FILIAL || ']', FALSE);

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
                        , vp_origem4 IN VARCHAR2
                        , v_tab_global_flag IN VARCHAR2
                        , v_tab_type IN VARCHAR2
                        , v_tab_footer IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 4000 );
        v_sql1 VARCHAR2 ( 100 );
        v_tab_xml VARCHAR2 ( 30 );
        v_tab_hist1 VARCHAR2 ( 30 );
        v_tab_hist2 VARCHAR2 ( 30 );
        v_tab_hist3 VARCHAR2 ( 30 );
        v_qtde INTEGER;
        ---
        v_tab_prd1 VARCHAR2 ( 30 );
        v_tab_prd2 VARCHAR2 ( 30 );
        v_tab_prd3 VARCHAR2 ( 30 );
        ---
        c_h3 SYS_REFCURSOR;

        TYPE cur_tab_h3 IS RECORD
        (
            business_unit VARCHAR2 ( 8 )
          , nf_brl_id VARCHAR2 ( 10 )
          , nf_brl_line_num NUMBER
          , tax_id_bbl VARCHAR2 ( 10 )
          , tax_brl_bse NUMBER ( 15, 4 )
          , tax_brl_amt NUMBER ( 15, 4 )
        );

        TYPE c_tab_h3 IS TABLE OF cur_tab_h3;

        tab_h3 c_tab_h3;
        ---
        v_idx_footer VARCHAR2 ( 100 ) := ' ';
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
        v_sql := v_sql || '  AND A.QUANTIDADE_E        = B.QTY_NF_BRL ';
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

        ---TAB ENTRADA FILIAL - XML INTERNO - BASE PRD PSFT---------------------------
        v_tab_xml := 'DPSP_XMLI_' || vp_proc_id;

        v_sql := 'CREATE ' || v_tab_type || ' TABLE ' || v_tab_xml || '  ';
        v_sql := v_sql || '( ';
        v_sql := v_sql || ' PROC_ID         NUMBER(30), ';
        v_sql := v_sql || ' NF_BRL_ID       VARCHAR2(10), ';
        v_sql := v_sql || ' CHAVE_ACESSO    VARCHAR2(44),';
        v_sql := v_sql || ' NF_BRL_LINE_NUM INTEGER,';
        v_sql := v_sql || ' INV_ITEM_ID     VARCHAR2(18),';
        v_sql := v_sql || ' CFOP_SAIDA      VARCHAR2(6),';
        v_sql := v_sql || ' QUANTIDADE      NUMBER(12,4),';
        v_sql := v_sql || ' VLR_BASE_ICMS   NUMBER(15,4),';
        v_sql := v_sql || ' VLR_ICMS        NUMBER(15,4),';
        v_sql := v_sql || ' ALIQ_REDUCAO    NUMBER(3,2),';
        v_sql := v_sql || ' VLR_BASE_ICMS_ST    NUMBER(15,4),';
        v_sql := v_sql || ' VLR_ICMS_ST         NUMBER(15,4),';
        v_sql := v_sql || ' VLR_BASE_ICMSST_RET NUMBER(15,4),';
        v_sql := v_sql || ' VLR_ICMSST_RET      NUMBER(15,4) ';
        v_sql := v_sql || ') ' || v_tab_footer;

        EXECUTE IMMEDIATE v_sql;

        save_tmp_control ( vp_proc_id
                         , v_tab_xml );

        IF ( v_tab_global_flag = 'N' ) THEN
            v_sql := 'CREATE UNIQUE INDEX PK_X_' || vp_proc_id || ' ON ' || v_tab_xml;
            v_sql := v_sql || ' ( ';
            v_sql := v_sql || ' PROC_ID ASC, ';
            v_sql := v_sql || ' NF_BRL_ID ASC, ';
            v_sql := v_sql || ' CHAVE_ACESSO ASC, ';
            v_sql := v_sql || ' NF_BRL_LINE_NUM ASC, ';
            v_sql := v_sql || ' INV_ITEM_ID ASC ';
            v_sql := v_sql || ' ) ' || v_idx_footer;

            EXECUTE IMMEDIATE v_sql;

            v_sql := 'CREATE INDEX IDX1_X_' || vp_proc_id || ' ON ' || v_tab_xml;
            v_sql := v_sql || ' ( ';
            v_sql := v_sql || ' CHAVE_ACESSO ASC ';
            v_sql := v_sql || ' ) ' || v_idx_footer;

            EXECUTE IMMEDIATE v_sql;
        END IF;

        ----------------------------------------------------------------------------

        ---OBTER TEMP1 DA PRD
        v_tab_prd1 := 'DPSP_XA$_' || vp_proc_id;

        v_sql := 'CREATE ' || v_tab_type || ' TABLE ' || v_tab_prd1 || '  ';
        v_sql := v_sql || '( ';
        v_sql := v_sql || '  NFEE_KEY_BBL    VARCHAR2(44) not null,';
        v_sql := v_sql || '  BUSINESS_UNIT   VARCHAR2(5) not null,';
        v_sql := v_sql || '  NF_BRL_ID       VARCHAR2(10) not null';
        v_sql := v_sql || ') ' || v_tab_footer;

        EXECUTE IMMEDIATE v_sql;

        save_tmp_control ( vp_proc_id
                         , v_tab_prd1 );

        v_sql := 'BEGIN FOR C IN (SELECT DISTINCT ';
        v_sql := v_sql || '                   H.NFEE_KEY_BBL,';
        v_sql := v_sql || '                   H.BUSINESS_UNIT,';
        v_sql := v_sql || '                   H.NF_BRL_ID';
        v_sql := v_sql || '              FROM (SELECT /*+DRIVING_SITE(H1)*/';
        v_sql := v_sql || '                     H1.NFEE_KEY_BBL,';
        v_sql := v_sql || '                     H1.BUSINESS_UNIT,';
        v_sql := v_sql || '                     H1.NF_BRL_ID';
        v_sql := v_sql || '              FROM MSAFI.PS_AR_NFRET_BBL H1, ';
        v_sql := v_sql || '              ' || v_tab_perdas_ent_f || ' F ';
        v_sql := v_sql || '              WHERE F.NUM_AUTENTIC_NFE_E = H1.NFEE_KEY_BBL ) H ';
        v_sql := v_sql || '       ) LOOP ';
        v_sql := v_sql || '           INSERT ';
        v_sql := v_sql || '           INTO ' || v_tab_prd1;
        v_sql := v_sql || '           VALUES';
        v_sql := v_sql || '           (C.NFEE_KEY_BBL,';
        v_sql := v_sql || '            C.BUSINESS_UNIT,';
        v_sql := v_sql || '            C.NF_BRL_ID);';
        v_sql := v_sql || '       END LOOP;';
        v_sql := v_sql || '       COMMIT;';
        v_sql := v_sql || '  END;';

        EXECUTE IMMEDIATE v_sql;

        IF ( vp_filiais = 'S' ) THEN
            --FLAG DE ENTRADA NA FILIAL DE MESMA UF MARCADA
            v_sql := 'BEGIN FOR C IN (SELECT DISTINCT ';
            v_sql := v_sql || '                   H.NFEE_KEY_BBL,';
            v_sql := v_sql || '                   H.BUSINESS_UNIT,';
            v_sql := v_sql || '                   H.NF_BRL_ID';
            v_sql := v_sql || '              FROM (SELECT /*+DRIVING_SITE(H1)*/';
            v_sql := v_sql || '                     H1.NFEE_KEY_BBL,';
            v_sql := v_sql || '                     H1.BUSINESS_UNIT,';
            v_sql := v_sql || '                     H1.NF_BRL_ID';
            v_sql := v_sql || '              FROM MSAFI.PS_AR_NFRET_BBL H1, ';
            v_sql := v_sql || '              ' || v_tab_perdas_ent_m || ' F ';
            v_sql := v_sql || '              WHERE F.NUM_AUTENTIC_NFE_E = H1.NFEE_KEY_BBL ) H ';
            v_sql := v_sql || '       ) LOOP ';
            v_sql := v_sql || '           INSERT ';
            v_sql := v_sql || '           INTO ' || v_tab_prd1;
            v_sql := v_sql || '           VALUES';
            v_sql := v_sql || '           (C.NFEE_KEY_BBL,';
            v_sql := v_sql || '            C.BUSINESS_UNIT,';
            v_sql := v_sql || '            C.NF_BRL_ID);';
            v_sql := v_sql || '       END LOOP;';
            v_sql := v_sql || '       COMMIT;';
            v_sql := v_sql || '  END;';

            EXECUTE IMMEDIATE v_sql;
        END IF;

        IF ( v_tab_global_flag = 'N' ) THEN
            v_sql := 'CREATE UNIQUE INDEX PK_PA_' || vp_proc_id || ' ON ' || v_tab_prd1;
            v_sql := v_sql || ' ( ';
            v_sql := v_sql || ' BUSINESS_UNIT ASC, ';
            v_sql := v_sql || ' NF_BRL_ID ASC ';
            v_sql := v_sql || ' ) ' || v_idx_footer;

            EXECUTE IMMEDIATE v_sql;

            v_sql := 'CREATE INDEX IDX1_PA_' || vp_proc_id || ' ON ' || v_tab_prd1;
            v_sql := v_sql || ' ( ';
            v_sql := v_sql || ' NFEE_KEY_BBL ASC ';
            v_sql := v_sql || ' ) ' || v_idx_footer;

            EXECUTE IMMEDIATE v_sql;
        END IF;

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , v_tab_prd1 );

        EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || v_tab_prd1            INTO v_qtde;

        loga ( '[PRD1][OK][' || v_qtde || ']'
             , FALSE );

        IF ( v_qtde > 0 ) THEN --(1)
            ---OBTER TEMP2 DA PRODUCAO
            v_tab_prd2 := 'DPSP_XB$_' || vp_proc_id;

            v_sql := 'CREATE ' || v_tab_type || ' TABLE ' || v_tab_prd2 || '  ';
            v_sql := v_sql || '( NFEE_KEY_BBL    VARCHAR2(44) NOT NULL,';
            v_sql := v_sql || '  BUSINESS_UNIT   VARCHAR2(5) NOT NULL,';
            v_sql := v_sql || '  NF_BRL_ID       VARCHAR2(10) NOT NULL,';
            v_sql := v_sql || '  NF_BRL_LINE_NUM INTEGER NOT NULL,';
            v_sql := v_sql || '  INV_ITEM_ID     VARCHAR2(18) NOT NULL,';
            v_sql := v_sql || '  QUANTIDADE      NUMBER(15,4) NOT NULL,';
            v_sql := v_sql || '  CFOP_SAIDA      VARCHAR2(6) NOT NULL';
            v_sql := v_sql || ') ' || v_tab_footer;

            EXECUTE IMMEDIATE v_sql;

            save_tmp_control ( vp_proc_id
                             , v_tab_prd2 );

            v_sql := 'BEGIN  FOR C IN (SELECT H.NFEE_KEY_BBL,';
            v_sql := v_sql || '                   H.BUSINESS_UNIT,';
            v_sql := v_sql || '                   H.NF_BRL_ID,';
            v_sql := v_sql || '                   H.NF_BRL_LINE_NUM,';
            v_sql := v_sql || '                   H.INV_ITEM_ID,';
            v_sql := v_sql || '                   H.QUANTIDADE,';
            v_sql := v_sql || '                   H.CFOP_SAIDA';
            v_sql := v_sql || '              FROM (SELECT /*+DRIVING_SITE(H2)*/';
            v_sql := v_sql || '                     H1.NFEE_KEY_BBL,';
            v_sql := v_sql || '                     H2.BUSINESS_UNIT,';
            v_sql := v_sql || '                     H2.NF_BRL_ID,';
            v_sql := v_sql || '                     H2.NF_BRL_LINE_NUM,';
            v_sql := v_sql || '                     H2.INV_ITEM_ID,';
            v_sql := v_sql || '                     H2.QTY_NF_BRL AS QUANTIDADE,';
            v_sql := v_sql || '                     H2.CFO_BRL_CD AS CFOP_SAIDA';
            v_sql := v_sql || '                      FROM MSAFI.PS_AR_ITENS_NF_BBL H2,'; --
            v_sql := v_sql || '                           ' || v_tab_prd1 || '     H1'; --
            v_sql := v_sql || '                     WHERE H1.BUSINESS_UNIT = H2.BUSINESS_UNIT'; --
            v_sql := v_sql || '                       AND H1.NF_BRL_ID = H2.NF_BRL_ID) H) LOOP'; --
            v_sql := v_sql || '  ';
            v_sql := v_sql || '    INSERT ';
            v_sql := v_sql || '    INTO ' || v_tab_prd2;
            v_sql := v_sql || '    VALUES';
            v_sql := v_sql || '      (C.NFEE_KEY_BBL,';
            v_sql := v_sql || '       C.BUSINESS_UNIT,';
            v_sql := v_sql || '       C.NF_BRL_ID,';
            v_sql := v_sql || '       C.NF_BRL_LINE_NUM,';
            v_sql := v_sql || '       C.INV_ITEM_ID,';
            v_sql := v_sql || '       C.QUANTIDADE,';
            v_sql := v_sql || '       C.CFOP_SAIDA);';
            v_sql := v_sql || '  ';
            v_sql := v_sql || '  ';
            v_sql := v_sql || '  END LOOP;';
            v_sql := v_sql || '  COMMIT;';
            v_sql := v_sql || '  END;';

            EXECUTE IMMEDIATE v_sql;

            loga ( '[PRD2][OK]'
                 , FALSE );

            IF ( v_tab_global_flag = 'N' ) THEN
                v_sql := 'CREATE UNIQUE INDEX PK_PB_' || vp_proc_id || ' ON ' || v_tab_prd2;
                v_sql := v_sql || ' ( ';
                v_sql := v_sql || ' BUSINESS_UNIT ASC, ';
                v_sql := v_sql || ' NF_BRL_ID ASC, ';
                v_sql := v_sql || ' NF_BRL_LINE_NUM ASC ';
                v_sql := v_sql || ' ) ' || v_idx_footer;

                EXECUTE IMMEDIATE v_sql;
            END IF;

            dbms_stats.gather_table_stats ( 'MSAF'
                                          , v_tab_prd2 );

            ---OBTER TEMP3 DA PRODUCAO
            v_tab_prd3 := 'DPSP_XC$_' || vp_proc_id;

            v_sql := 'CREATE ' || v_tab_type || ' TABLE ' || v_tab_prd3 || '  ';
            v_sql := v_sql || '( ';
            v_sql := v_sql || '  BUSINESS_UNIT   VARCHAR2(5) NOT NULL,';
            v_sql := v_sql || '  NF_BRL_ID       VARCHAR2(10) NOT NULL,';
            v_sql := v_sql || '  NF_BRL_LINE_NUM INTEGER NOT NULL,';
            v_sql := v_sql || '  TAX_ID_BBL      VARCHAR2(10) NOT NULL,';
            v_sql := v_sql || '  TAX_BRL_BSE     NUMBER(26,3) NOT NULL,';
            v_sql := v_sql || '  TAX_BRL_AMT     NUMBER(26,3) NOT NULL';
            v_sql := v_sql || ') ' || v_tab_footer;

            EXECUTE IMMEDIATE v_sql;

            save_tmp_control ( vp_proc_id
                             , v_tab_prd3 );

            v_sql := 'BEGIN  FOR C IN (SELECT H.BUSINESS_UNIT,';
            v_sql := v_sql || '                   H.NF_BRL_ID,';
            v_sql := v_sql || '                   H.NF_BRL_LINE_NUM,';
            v_sql := v_sql || '                   H.TAX_ID_BBL,';
            v_sql := v_sql || '                   H.TAX_BRL_BSE,';
            v_sql := v_sql || '                   H.TAX_BRL_AMT';
            v_sql := v_sql || '              FROM (SELECT /*+DRIVING_SITE(H3)*/';
            v_sql := v_sql || '                     H3.BUSINESS_UNIT,';
            v_sql := v_sql || '                     H3.NF_BRL_ID,';
            v_sql := v_sql || '                     H3.NF_BRL_LINE_NUM,';
            v_sql := v_sql || '                     H3.TAX_ID_BBL,';
            v_sql := v_sql || '                     H3.TAX_BRL_BSE,';
            v_sql := v_sql || '                     H3.TAX_BRL_AMT';
            v_sql := v_sql || '                      FROM MSAFI.PS_AR_IMP_BBL  H3, '; --
            v_sql := v_sql || '                           ' || v_tab_prd2 || ' H2'; --
            v_sql := v_sql || '               WHERE H2.BUSINESS_UNIT = H3.BUSINESS_UNIT ';
            v_sql := v_sql || '                 AND H2.NF_BRL_ID = H3.NF_BRL_ID ';
            v_sql := v_sql || '                 AND H2.NF_BRL_LINE_NUM = H3.NF_BRL_LINE_NUM ';
            v_sql := v_sql || '                 AND H3.TAX_ID_BBL IN (''ICMS'',''ICMST'') ) H ';
            v_sql := v_sql || '   ) LOOP ';
            v_sql := v_sql || '    INSERT INTO ' || v_tab_prd3;
            v_sql := v_sql || '    VALUES';
            v_sql := v_sql || '      (C.BUSINESS_UNIT,';
            v_sql := v_sql || '       C.NF_BRL_ID,';
            v_sql := v_sql || '       C.NF_BRL_LINE_NUM,';
            v_sql := v_sql || '       C.TAX_ID_BBL,';
            v_sql := v_sql || '       C.TAX_BRL_BSE,';
            v_sql := v_sql || '       C.TAX_BRL_AMT);';
            v_sql := v_sql || '  ';
            v_sql := v_sql || '  END LOOP;';
            v_sql := v_sql || '  COMMIT;';
            v_sql := v_sql || '  END;';

            EXECUTE IMMEDIATE v_sql;

            loga ( '[PRD3][OK]'
                 , FALSE );

            IF ( v_tab_global_flag = 'N' ) THEN
                v_sql := 'CREATE UNIQUE INDEX PK_PC_' || vp_proc_id || ' ON ' || v_tab_prd3;
                v_sql := v_sql || ' ( ';
                v_sql := v_sql || ' BUSINESS_UNIT ASC, ';
                v_sql := v_sql || ' NF_BRL_ID ASC, ';
                v_sql := v_sql || ' NF_BRL_LINE_NUM ASC, ';
                v_sql := v_sql || ' TAX_ID_BBL ASC ';
                v_sql := v_sql || ' ) ' || v_idx_footer;

                EXECUTE IMMEDIATE v_sql;
            END IF;

            dbms_stats.gather_table_stats ( 'MSAF'
                                          , v_tab_prd3 );

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
            v_sql := v_sql || '		SELECT LN.NF_BRL_ID, ';
            v_sql := v_sql || '			  LN.NFEE_KEY_BBL AS CHAVE_ACESSO, ';
            v_sql := v_sql || '			  LN.NF_BRL_LINE_NUM, ';
            v_sql := v_sql || '			  LN.INV_ITEM_ID, ';
            v_sql := v_sql || '			  LN.QUANTIDADE, ';
            v_sql := v_sql || '			  LN.CFOP_SAIDA, ';
            v_sql := v_sql || '			  NVL((SELECT IMP.TAX_BRL_BSE ';
            v_sql := v_sql || '		           FROM ' || v_tab_prd3 || ' IMP ';
            v_sql := v_sql || '		           WHERE IMP.BUSINESS_UNIT = LN.BUSINESS_UNIT ';
            v_sql := v_sql || '		             AND IMP.NF_BRL_ID = LN.NF_BRL_ID ';
            v_sql := v_sql || '		             AND IMP.NF_BRL_LINE_NUM = LN.NF_BRL_LINE_NUM ';
            v_sql := v_sql || '		             AND IMP.TAX_ID_BBL = ''ICMS''),0) AS VLR_BASE_ICMS, ';
            v_sql := v_sql || '		      NVL((SELECT IMP.TAX_BRL_AMT ';
            v_sql := v_sql || '		       	  FROM ' || v_tab_prd3 || ' IMP ';
            v_sql := v_sql || '		           WHERE IMP.BUSINESS_UNIT = LN.BUSINESS_UNIT ';
            v_sql := v_sql || '		             AND IMP.NF_BRL_ID = LN.NF_BRL_ID ';
            v_sql := v_sql || '		             AND IMP.NF_BRL_LINE_NUM = LN.NF_BRL_LINE_NUM ';
            v_sql := v_sql || '		             AND IMP.TAX_ID_BBL = ''ICMS''),0) AS VLR_ICMS, ';
            v_sql := v_sql || '		      0 AS ALIQ_REDUCAO, ';
            v_sql := v_sql || '		      NVL((SELECT IMP.TAX_BRL_BSE ';
            v_sql := v_sql || '		      	  FROM ' || v_tab_prd3 || ' IMP ';
            v_sql := v_sql || '		           WHERE IMP.BUSINESS_UNIT = LN.BUSINESS_UNIT ';
            v_sql := v_sql || '		             AND IMP.NF_BRL_ID = LN.NF_BRL_ID ';
            v_sql := v_sql || '		             AND IMP.NF_BRL_LINE_NUM = LN.NF_BRL_LINE_NUM ';
            v_sql := v_sql || '		             AND IMP.TAX_ID_BBL = ''ICMST''),0) AS VLR_BASE_ICMS_ST, ';
            v_sql := v_sql || '		      NVL((SELECT IMP.TAX_BRL_AMT ';
            v_sql := v_sql || '		      	  FROM ' || v_tab_prd3 || ' IMP ';
            v_sql := v_sql || '		           WHERE IMP.BUSINESS_UNIT = LN.BUSINESS_UNIT ';
            v_sql := v_sql || '		             AND IMP.NF_BRL_ID = LN.NF_BRL_ID ';
            v_sql := v_sql || '		             AND IMP.NF_BRL_LINE_NUM = LN.NF_BRL_LINE_NUM ';
            v_sql := v_sql || '		             AND IMP.TAX_ID_BBL = ''ICMST''),0) AS VLR_ICMS_ST, ';
            v_sql := v_sql || '		      0 AS VLR_BASE_ICMSST_RET, ';
            v_sql := v_sql || '		      0 AS VLR_ICMSST_RET ';
            v_sql := v_sql || '		FROM ' || v_tab_prd2 || ' LN ) X ';
            v_sql := v_sql || ' ) ';

            EXECUTE IMMEDIATE v_sql;

            COMMIT;
        END IF; --(1)

        ---
        loga ( '[END XML INTERNO PSFT PRD]'
             , FALSE );

        IF ( vp_origem1 = 'L'
         OR vp_origem2 = 'L'
         OR vp_origem3 = 'L'
         OR vp_origem4 = 'L'
         OR vp_filiais = 'S' ) THEN
            ---OBTER TEMP1 DA HISTORICA
            v_tab_hist1 := 'DPSP_X1$_' || vp_proc_id;

            v_sql := 'CREATE ' || v_tab_type || ' TABLE ' || v_tab_hist1 || '  ';
            v_sql := v_sql || '( ';
            v_sql := v_sql || '  NFEE_KEY_BBL    VARCHAR2(44) not null,';
            v_sql := v_sql || '  BUSINESS_UNIT   VARCHAR2(5) not null,';
            v_sql := v_sql || '  NF_BRL_ID       VARCHAR2(10) not null';
            v_sql := v_sql || ') ' || v_tab_footer;

            EXECUTE IMMEDIATE v_sql;

            save_tmp_control ( vp_proc_id
                             , v_tab_hist1 );

            v_sql := 'BEGIN FOR C IN (SELECT DISTINCT ';
            v_sql := v_sql || '                   H.NFEE_KEY_BBL,';
            v_sql := v_sql || '                   H.BUSINESS_UNIT,';
            v_sql := v_sql || '                   H.NF_BRL_ID';
            v_sql := v_sql || '              FROM (SELECT /*+DRIVING_SITE(H1)*/';
            v_sql := v_sql || '                     H1.NFEE_KEY_BBL,';
            v_sql := v_sql || '                     H1.BUSINESS_UNIT,';
            v_sql := v_sql || '                     H1.NF_BRL_ID';
            v_sql := v_sql || '              FROM FDSPPRD.PS_AR_NFRET_BBL_BKP_NOV2016@DBLINK_DBPSTHST H1, ';
            v_sql := v_sql || '              ' || v_tab_perdas_ent_f || ' F ';
            v_sql := v_sql || '              WHERE F.NUM_AUTENTIC_NFE_E = H1.NFEE_KEY_BBL ) H ';
            v_sql := v_sql || '       ) LOOP ';
            v_sql := v_sql || '           INSERT ';
            v_sql := v_sql || '           INTO ' || v_tab_hist1;
            v_sql := v_sql || '           VALUES';
            v_sql := v_sql || '           (C.NFEE_KEY_BBL,';
            v_sql := v_sql || '            C.BUSINESS_UNIT,';
            v_sql := v_sql || '            C.NF_BRL_ID);';
            v_sql := v_sql || '       END LOOP;';
            v_sql := v_sql || '       COMMIT;';
            v_sql := v_sql || '  END;';

            EXECUTE IMMEDIATE v_sql;

            IF ( v_tab_global_flag = 'N' ) THEN
                v_sql := 'CREATE UNIQUE INDEX PK_H1_' || vp_proc_id || ' ON ' || v_tab_hist1;
                v_sql := v_sql || ' ( ';
                v_sql := v_sql || ' BUSINESS_UNIT ASC, ';
                v_sql := v_sql || ' NF_BRL_ID ASC ';
                v_sql := v_sql || ' ) ' || v_idx_footer;

                EXECUTE IMMEDIATE v_sql;

                v_sql := 'CREATE INDEX IDX1_H1_' || vp_proc_id || ' ON ' || v_tab_hist1;
                v_sql := v_sql || ' ( ';
                v_sql := v_sql || ' NFEE_KEY_BBL ASC ';
                v_sql := v_sql || ' ) ' || v_idx_footer;

                EXECUTE IMMEDIATE v_sql;
            END IF;

            IF ( vp_filiais = 'S' ) THEN
                v_sql := 'BEGIN  FOR C IN (SELECT DISTINCT ';
                v_sql := v_sql || '                   H.NFEE_KEY_BBL,';
                v_sql := v_sql || '                   H.BUSINESS_UNIT,';
                v_sql := v_sql || '                   H.NF_BRL_ID';
                v_sql := v_sql || '              FROM (SELECT /*+DRIVING_SITE(H4)*/';
                v_sql := v_sql || '                     H4.NFEE_KEY_BBL,';
                v_sql := v_sql || '                     H4.BUSINESS_UNIT,';
                v_sql := v_sql || '                     H4.NF_BRL_ID';
                v_sql := v_sql || ' FROM FDSPPRD.PS_AR_NFRET_BBL_BKP_NOV2016@DBLINK_DBPSTHST H4, ';
                v_sql := v_sql || '    ' || v_tab_perdas_ent_m || ' F ';
                v_sql := v_sql || '  WHERE F.NUM_AUTENTIC_NFE_E = H4.NFEE_KEY_BBL ) H ';
                v_sql := v_sql || '   ) LOOP ';
                v_sql := v_sql || '    INSERT INTO ' || v_tab_hist1;
                v_sql := v_sql || '    VALUES';
                v_sql := v_sql || '      (C.NFEE_KEY_BBL,';
                v_sql := v_sql || '       C.BUSINESS_UNIT,';
                v_sql := v_sql || '       C.NF_BRL_ID);';
                v_sql := v_sql || '  ';
                v_sql := v_sql || '  ';
                v_sql := v_sql || '  END LOOP;';
                v_sql := v_sql || '  COMMIT;';
                v_sql := v_sql || '  END;';

                EXECUTE IMMEDIATE v_sql;
            END IF;

            dbms_stats.gather_table_stats ( 'MSAF'
                                          , v_tab_hist1 );

            EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || v_tab_hist1            INTO v_qtde;

            loga ( '[HIST1][OK][' || v_qtde || ']'
                 , FALSE );

            IF ( v_qtde > 0 ) THEN --(1)
                ---OBTER TEMP2 DA HISTORICA
                v_tab_hist2 := 'DPSP_X2$_' || vp_proc_id;

                v_sql := 'CREATE ' || v_tab_type || ' TABLE ' || v_tab_hist2 || '  ';
                v_sql := v_sql || '( NFEE_KEY_BBL    VARCHAR2(44) NOT NULL,';
                v_sql := v_sql || '  BUSINESS_UNIT   VARCHAR2(5) NOT NULL,';
                v_sql := v_sql || '  NF_BRL_ID       VARCHAR2(10) NOT NULL,';
                v_sql := v_sql || '  NF_BRL_LINE_NUM INTEGER NOT NULL,';
                v_sql := v_sql || '  INV_ITEM_ID     VARCHAR2(18) NOT NULL,';
                v_sql := v_sql || '  QUANTIDADE      NUMBER(15,4) NOT NULL,';
                v_sql := v_sql || '  CFOP_SAIDA      VARCHAR2(6) NOT NULL';
                v_sql := v_sql || ') ' || v_tab_footer;

                EXECUTE IMMEDIATE v_sql;

                save_tmp_control ( vp_proc_id
                                 , v_tab_hist2 );

                v_sql := 'BEGIN  FOR C IN (SELECT H.NFEE_KEY_BBL,';
                v_sql := v_sql || '                   H.BUSINESS_UNIT,';
                v_sql := v_sql || '                   H.NF_BRL_ID,';
                v_sql := v_sql || '                   H.NF_BRL_LINE_NUM,';
                v_sql := v_sql || '                   H.INV_ITEM_ID,';
                v_sql := v_sql || '                   H.QUANTIDADE,';
                v_sql := v_sql || '                   H.CFOP_SAIDA';
                v_sql := v_sql || '              FROM (SELECT /*+DRIVING_SITE(H2)*/';
                v_sql := v_sql || '                     H1.NFEE_KEY_BBL,';
                v_sql := v_sql || '                     H2.BUSINESS_UNIT,';
                v_sql := v_sql || '                     H2.NF_BRL_ID,';
                v_sql := v_sql || '                     H2.NF_BRL_LINE_NUM,';
                v_sql := v_sql || '                     H2.INV_ITEM_ID,';
                v_sql := v_sql || '                     H2.QTY_NF_BRL AS QUANTIDADE,';
                v_sql := v_sql || '                     H2.CFO_BRL_CD AS CFOP_SAIDA';
                v_sql :=
                    v_sql || '                      FROM FDSPPRD.PS_AR_ITENS_NF_BBL_BKP_NOV2016@DBLINK_DBPSTHST H2,'; --
                v_sql := v_sql || '                           ' || v_tab_hist1 || '                          H1'; --
                v_sql := v_sql || '                     WHERE H1.BUSINESS_UNIT = H2.BUSINESS_UNIT'; --
                v_sql := v_sql || '                       AND H1.NF_BRL_ID = H2.NF_BRL_ID) H) LOOP'; --
                v_sql := v_sql || '  ';
                v_sql := v_sql || '    INSERT ';
                v_sql := v_sql || '    INTO ' || v_tab_hist2;
                v_sql := v_sql || '    VALUES';
                v_sql := v_sql || '      (C.NFEE_KEY_BBL,';
                v_sql := v_sql || '       C.BUSINESS_UNIT,';
                v_sql := v_sql || '       C.NF_BRL_ID,';
                v_sql := v_sql || '       C.NF_BRL_LINE_NUM,';
                v_sql := v_sql || '       C.INV_ITEM_ID,';
                v_sql := v_sql || '       C.QUANTIDADE,';
                v_sql := v_sql || '       C.CFOP_SAIDA);';
                v_sql := v_sql || '  ';
                v_sql := v_sql || '  ';
                v_sql := v_sql || '  END LOOP;';
                v_sql := v_sql || '  COMMIT;';
                v_sql := v_sql || '  END;';

                EXECUTE IMMEDIATE v_sql;

                loga ( '[HIST2][OK]'
                     , FALSE );

                IF ( v_tab_global_flag = 'N' ) THEN
                    v_sql := 'CREATE UNIQUE INDEX PK_H2_' || vp_proc_id || ' ON ' || v_tab_hist2;
                    v_sql := v_sql || ' ( ';
                    v_sql := v_sql || ' BUSINESS_UNIT ASC, ';
                    v_sql := v_sql || ' NF_BRL_ID ASC, ';
                    v_sql := v_sql || ' NF_BRL_LINE_NUM ASC ';
                    v_sql := v_sql || ' ) ' || v_idx_footer;

                    EXECUTE IMMEDIATE v_sql;
                END IF;

                dbms_stats.gather_table_stats ( 'MSAF'
                                              , v_tab_hist2 );

                ---OBTER TEMP3 DA HISTORICA
                v_tab_hist3 := 'DPSP_X3$_' || vp_proc_id;

                v_sql := 'CREATE ' || v_tab_type || ' TABLE ' || v_tab_hist3 || '  ';
                v_sql := v_sql || '( ';
                v_sql := v_sql || '  BUSINESS_UNIT   VARCHAR2(5) NOT NULL,';
                v_sql := v_sql || '  NF_BRL_ID       VARCHAR2(10) NOT NULL,';
                v_sql := v_sql || '  NF_BRL_LINE_NUM INTEGER NOT NULL,';
                v_sql := v_sql || '  TAX_ID_BBL      VARCHAR2(10) NOT NULL,';
                v_sql := v_sql || '  TAX_BRL_BSE     NUMBER(26,3) NOT NULL,';
                v_sql := v_sql || '  TAX_BRL_AMT     NUMBER(26,3) NOT NULL';
                v_sql := v_sql || ') ' || v_tab_footer;

                EXECUTE IMMEDIATE v_sql;

                save_tmp_control ( vp_proc_id
                                 , v_tab_hist3 );

                v_sql := 'DECLARE ';
                v_sql := v_sql || '  V_COUNT INTEGER := 0; ';
                v_sql := v_sql || 'BEGIN ';
                ---
                v_sql := v_sql || '  FOR C IN (SELECT A.* ';
                v_sql := v_sql || '              FROM ' || v_tab_hist2 || ' A, ' || v_tab_hist3 || ' H3 ';
                v_sql := v_sql || '            WHERE A.BUSINESS_UNIT   = H3.BUSINESS_UNIT (+) ';
                v_sql := v_sql || '              AND A.NF_BRL_ID       = H3.NF_BRL_ID (+) ';
                v_sql := v_sql || '              AND A.NF_BRL_LINE_NUM = H3.NF_BRL_LINE_NUM (+) ';
                v_sql := v_sql || '              AND H3.TAX_ID_BBL(+) IN (''ICMS'', ''ICMST'') ';
                v_sql := v_sql || '              AND H3.ROWID IS NULL) LOOP ';
                ---
                v_sql := v_sql || '    V_COUNT := V_COUNT + 1; ';
                v_sql := v_sql || '    DBMS_APPLICATION_INFO.SET_MODULE(''PS_HIST'', V_COUNT); ';
                ---
                v_sql := v_sql || '    FOR D IN (SELECT /*+DRIVING_SITE(H3)*/ H3.BUSINESS_UNIT, ';
                v_sql := v_sql || '                    H3.NF_BRL_ID, ';
                v_sql := v_sql || '                    H3.NF_BRL_LINE_NUM, ';
                v_sql := v_sql || '                    H3.TAX_ID_BBL, ';
                v_sql := v_sql || '                    H3.TAX_BRL_BSE, ';
                v_sql := v_sql || '                    H3.TAX_BRL_AMT ';
                v_sql := v_sql || '                FROM FDSPPRD.PS_AR_IMP_BBL_BKP_NOV2016@DBLINK_DBPSTHST H3 ';
                v_sql := v_sql || '                WHERE C.BUSINESS_UNIT   = H3.BUSINESS_UNIT ';
                v_sql := v_sql || '                  AND C.NF_BRL_ID       = H3.NF_BRL_ID ';
                v_sql := v_sql || '                  AND C.NF_BRL_LINE_NUM = H3.NF_BRL_LINE_NUM ';
                v_sql := v_sql || '                  AND H3.TAX_ID_BBL IN (''ICMS'', ''ICMST'') ';
                ---
                v_sql := v_sql || '              ) LOOP ';
                ---
                v_sql := v_sql || '      INSERT INTO ' || v_tab_hist3 || ' ';
                v_sql := v_sql || '      VALUES ';
                v_sql := v_sql || '        (D.BUSINESS_UNIT, ';
                v_sql := v_sql || '        D.NF_BRL_ID, ';
                v_sql := v_sql || '        D.NF_BRL_LINE_NUM, ';
                v_sql := v_sql || '        D.TAX_ID_BBL, ';
                v_sql := v_sql || '        D.TAX_BRL_BSE, ';
                v_sql := v_sql || '        D.TAX_BRL_AMT); ';
                ---
                v_sql := v_sql || '    END LOOP; ';
                v_sql := v_sql || '    COMMIT; ';
                v_sql := v_sql || '  END LOOP; ';
                v_sql := v_sql || 'END; ';

                EXECUTE IMMEDIATE v_sql;

                loga ( '[HIST3][OK]'
                     , FALSE );

                IF ( v_tab_global_flag = 'N' ) THEN
                    v_sql := 'CREATE UNIQUE INDEX PK_H3_' || vp_proc_id || ' ON ' || v_tab_hist3;
                    v_sql := v_sql || ' ( ';
                    v_sql := v_sql || ' BUSINESS_UNIT ASC, ';
                    v_sql := v_sql || ' NF_BRL_ID ASC, ';
                    v_sql := v_sql || ' NF_BRL_LINE_NUM ASC, ';
                    v_sql := v_sql || ' TAX_ID_BBL ASC ';
                    v_sql := v_sql || ' ) ' || v_idx_footer;

                    EXECUTE IMMEDIATE v_sql;
                END IF;

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
                v_sql := v_sql || '		SELECT LN.NF_BRL_ID, ';
                v_sql := v_sql || '			  LN.NFEE_KEY_BBL AS CHAVE_ACESSO, ';
                v_sql := v_sql || '			  LN.NF_BRL_LINE_NUM, ';
                v_sql := v_sql || '			  LN.INV_ITEM_ID, ';
                v_sql := v_sql || '			  LN.QUANTIDADE, ';
                v_sql := v_sql || '			  LN.CFOP_SAIDA, ';
                v_sql := v_sql || '			  NVL((SELECT IMP.TAX_BRL_BSE ';
                v_sql := v_sql || '		           FROM ' || v_tab_hist3 || ' IMP ';
                v_sql := v_sql || '		           WHERE IMP.BUSINESS_UNIT = LN.BUSINESS_UNIT ';
                v_sql := v_sql || '		             AND IMP.NF_BRL_ID = LN.NF_BRL_ID ';
                v_sql := v_sql || '		             AND IMP.NF_BRL_LINE_NUM = LN.NF_BRL_LINE_NUM ';
                v_sql := v_sql || '		             AND IMP.TAX_ID_BBL = ''ICMS''),0) AS VLR_BASE_ICMS, ';
                v_sql := v_sql || '		      NVL((SELECT IMP.TAX_BRL_AMT ';
                v_sql := v_sql || '		       	  FROM ' || v_tab_hist3 || ' IMP ';
                v_sql := v_sql || '		           WHERE IMP.BUSINESS_UNIT = LN.BUSINESS_UNIT ';
                v_sql := v_sql || '		             AND IMP.NF_BRL_ID = LN.NF_BRL_ID ';
                v_sql := v_sql || '		             AND IMP.NF_BRL_LINE_NUM = LN.NF_BRL_LINE_NUM ';
                v_sql := v_sql || '		             AND IMP.TAX_ID_BBL = ''ICMS''),0) AS VLR_ICMS, ';
                v_sql := v_sql || '		      0 AS ALIQ_REDUCAO, ';
                v_sql := v_sql || '		      NVL((SELECT IMP.TAX_BRL_BSE ';
                v_sql := v_sql || '		      	  FROM ' || v_tab_hist3 || ' IMP ';
                v_sql := v_sql || '		           WHERE IMP.BUSINESS_UNIT = LN.BUSINESS_UNIT ';
                v_sql := v_sql || '		             AND IMP.NF_BRL_ID = LN.NF_BRL_ID ';
                v_sql := v_sql || '		             AND IMP.NF_BRL_LINE_NUM = LN.NF_BRL_LINE_NUM ';
                v_sql := v_sql || '		             AND IMP.TAX_ID_BBL = ''ICMST''),0) AS VLR_BASE_ICMS_ST, ';
                v_sql := v_sql || '		      NVL((SELECT IMP.TAX_BRL_AMT ';
                v_sql := v_sql || '		      	  FROM ' || v_tab_hist3 || ' IMP ';
                v_sql := v_sql || '		           WHERE IMP.BUSINESS_UNIT = LN.BUSINESS_UNIT ';
                v_sql := v_sql || '		             AND IMP.NF_BRL_ID = LN.NF_BRL_ID ';
                v_sql := v_sql || '		             AND IMP.NF_BRL_LINE_NUM = LN.NF_BRL_LINE_NUM ';
                v_sql := v_sql || '		             AND IMP.TAX_ID_BBL = ''ICMST''),0) AS VLR_ICMS_ST, ';
                v_sql := v_sql || '		      0 AS VLR_BASE_ICMSST_RET, ';
                v_sql := v_sql || '		      0 AS VLR_ICMSST_RET ';
                v_sql := v_sql || '		FROM ' || v_tab_hist2 || ' LN ';
                v_sql := v_sql || '		WHERE NOT EXISTS (SELECT ''Y'' FROM ' || v_tab_xml || ' TABX ';
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
                              , v_tab_perdas_ent_m IN VARCHAR2
                              , v_tab_global_flag IN VARCHAR2
                              , v_tab_type IN VARCHAR2
                              , v_tab_footer IN VARCHAR2 )
    IS
        v_tab_aux VARCHAR2 ( 30 );
        v_sql VARCHAR2 ( 3000 );
    BEGIN
        v_tab_aux := 'DPSP_ANT_' || vp_proc_id;

        v_sql := 'CREATE ' || v_tab_type || ' TABLE ' || v_tab_aux || v_tab_footer || ' AS ';
        v_sql :=
               v_sql
            || ' SELECT DISTINCT BUSINESS_UNIT, COD_ESTAB_E AS COD_ESTAB, NUM_CONTROLE_DOCTO_E AS NUM_CONTROLE_DOCTO, NUM_ITEM_E AS NUM_ITEM ';
        v_sql := v_sql || ' FROM ' || v_tab_perdas_ent_c || ' ';
        v_sql := v_sql || ' WHERE BASE_ST_UNIT_E = 0 AND VLR_ICMS_ST_UNIT_E = 0 ';
        v_sql := v_sql || ' UNION ALL ';
        v_sql :=
               v_sql
            || ' SELECT DISTINCT BUSINESS_UNIT, COD_ESTAB_E AS COD_ESTAB, NUM_CONTROLE_DOCTO_E AS NUM_CONTROLE_DOCTO, NUM_ITEM_E AS NUM_ITEM ';
        v_sql := v_sql || ' FROM ' || v_tab_perdas_ent_d || ' ';
        v_sql := v_sql || ' WHERE BASE_ST_UNIT_E = 0 AND VLR_ICMS_ST_UNIT_E = 0 ';

        --V_SQL := V_SQL || ' UNION ALL ';
        --V_SQL := V_SQL || ' SELECT DISTINCT COD_ESTAB_E, NUM_CONTROLE_DOCTO_E, NUM_ITEM_E ';
        --V_SQL := V_SQL || ' FROM ' || V_TAB_PERDAS_ENT_F || ' ';
        --V_SQL := V_SQL || ' WHERE BASE_ST_UNIT_E = 0 AND VLR_ICMS_ST_UNIT_E = 0 ';
        EXECUTE IMMEDIATE v_sql;

        save_tmp_control ( vp_proc_id
                         , v_tab_aux );

        --ATUALIZAR ANTECIPACAO
        msafi.dpsp_get_antecipacao ( 'MSAF.' || v_tab_aux );
        loga ( '[GET ANTECIP][END][' || SQL%ROWCOUNT || ']'
             , FALSE );
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

        v_sql := 'UPDATE ' || v_tab_perdas_tmp;
        v_sql := v_sql || ' SET TOTAL_ICMS_ST = 0 ';
        v_sql := v_sql || ' WHERE VLR_ICMS_ST_UNIT_E > VLR_CONTAB_ITEM_E '; --EVITAR VALORES INCORRETOS NO XML
        v_sql := v_sql || '   AND TOTAL_ICMS_ST > 0 ';

        EXECUTE IMMEDIATE v_sql;

        loga ( '[TRAVA ST][' || SQL%ROWCOUNT || ']'
             , FALSE );
        COMMIT;
    END;

    PROCEDURE audit_resources ( v_mproc_id IN NUMBER
                              , v_tab_name IN VARCHAR2
                              , v_partition_name IN VARCHAR2
                              , v_date_begin IN DATE
                              , v_date_end IN DATE
                              , v_pga_ini IN NUMBER
                              , v_pga_end IN NUMBER
                              , v_cpu_time IN NUMBER
                              , v_bulk_limit IN NUMBER
                              , v_qtd_lines IN NUMBER
                              , v_function_name IN VARCHAR2
                              , v_limit IN NUMBER
                              , v_uga_ini IN NUMBER
                              , v_uga_end IN NUMBER )
    IS
        i NUMBER;
        v_i_pga_limit NUMBER;
        v_i_pga_target NUMBER;
        v_i_sga_max NUMBER;
        v_i_sga_target NUMBER;
        v_i_log_use NUMBER;
    BEGIN
        IF ( v_limit = 1
        AND v_tab_name = 'X07_DOCTO_FISCAL' ) THEN
            tab_audit.delete;
        END IF;

        --OBTER PARAMETROS DO BD NO MOMENTO DA EXECUCAO
        BEGIN
            SELECT ROUND (   ( SELECT VALUE
                                 FROM v$parameter
                                WHERE name = 'pga_aggregate_limit' )
                           / 1024
                           / 1024
                         , 2 )
                       AS pga_limit
                 , ROUND (   ( SELECT VALUE
                                 FROM v$parameter
                                WHERE name = 'pga_aggregate_target' )
                           / 1024
                           / 1024
                         , 2 )
                       AS pga_target
                 , ROUND (   ( SELECT VALUE
                                 FROM v$parameter
                                WHERE name = 'sga_max_size' )
                           / 1024
                           / 1024
                         , 2 )
                       AS sga_max
                 , ROUND (   ( SELECT VALUE
                                 FROM v$parameter
                                WHERE name = 'sga_target' )
                           / 1024
                           / 1024
                         , 2 )
                       AS sga_target
              INTO v_i_pga_limit
                 , v_i_pga_target
                 , v_i_sga_max
                 , v_i_sga_target
              FROM DUAL;
        EXCEPTION
            WHEN OTHERS THEN
                v_i_pga_limit := 0;
                v_i_pga_target := 0;
                v_i_sga_max := 0;
                v_i_sga_target := 0;
        END;

        ---OBTER USO DE REDO LOG FILES
        BEGIN
            SELECT NVL ( SUM ( DECODE ( SUBSTR ( TO_CHAR ( first_time
                                                         , 'HH24' )
                                               , 1
                                               , 2 )
                                      , SUBSTR ( TO_CHAR ( SYSDATE
                                                         , 'HH24' )
                                               , 1
                                               , 2 ), 1
                                      , 0 ) )
                       , 0 )
                       AS logs
              INTO v_i_log_use
              FROM v$log_history
             WHERE SUBSTR ( TO_CHAR ( first_time
                                    , 'DDMMYYYY' )
                          , 1
                          , 8 ) = SUBSTR ( TO_CHAR ( SYSDATE
                                                   , 'DDMMYYYY' )
                                         , 1
                                         , 8 );
        EXCEPTION
            WHEN OTHERS THEN
                v_i_log_use := 0;
        END;

        tab_audit.EXTEND ( );
        i := tab_audit.LAST;
        tab_audit ( i ).proc_id := v_mproc_id;
        tab_audit ( i ).seq_num := v_limit;
        tab_audit ( i ).user_sid := USERENV ( 'SID' );
        tab_audit ( i ).dttm_execucao := SYSDATE;
        tab_audit ( i ).table_name := v_tab_name;
        tab_audit ( i ).partition_name := v_partition_name;
        tab_audit ( i ).date_begin := v_date_begin;
        tab_audit ( i ).date_end := v_date_end;
        tab_audit ( i ).pga_aggregate_limit := v_i_pga_limit; --MB
        tab_audit ( i ).pga_aggregate_target := v_i_pga_target; --MB
        tab_audit ( i ).pga_used_ini := v_pga_ini; --MB
        tab_audit ( i ).pga_used_end := v_pga_end; --MB
        tab_audit ( i ).pga_used := v_pga_end - v_pga_ini; --MB
        tab_audit ( i ).cpu_time := v_cpu_time;
        tab_audit ( i ).bulk_limit := v_bulk_limit;
        tab_audit ( i ).sga_max_size := v_i_sga_max; --MB
        tab_audit ( i ).sga_target := v_i_sga_target; --MB
        tab_audit ( i ).username := musuario;
        tab_audit ( i ).process_name := $$plsql_unit;
        tab_audit ( i ).qtd_lines_processed := v_qtd_lines;
        tab_audit ( i ).function_name := v_function_name;
        tab_audit ( i ).log_use := v_i_log_use;
        tab_audit ( i ).uga_used_ini := v_uga_ini; --MB
        tab_audit ( i ).uga_used_end := v_uga_end; --MB
        tab_audit ( i ).uga_used := v_uga_end - v_uga_ini; --MB
    END;

    PROCEDURE save_audit
    IS
    BEGIN
        BEGIN
            FORALL i IN tab_audit.FIRST .. tab_audit.LAST
                INSERT /*+APPEND*/
                      INTO  msafi.dpsp_audit_resource
                VALUES tab_audit ( i );

            COMMIT;
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
        END;
    END;

    PROCEDURE load_entradas ( vp_proc_instance IN VARCHAR2
                            , vp_cod_estab IN VARCHAR2
                            , vp_dt_inicial IN DATE
                            , vp_dt_final IN DATE
                            , vp_origem IN VARCHAR2
                            , vp_tabela_entrada IN VARCHAR2
                            , vp_tab_perdas_inv IN VARCHAR2
                            , vp_cd IN VARCHAR2
                            , vp_tab_perdas_ent_f IN VARCHAR2
                            , vp_tab_perdas_ent_d IN VARCHAR2
                            , vp_tab_perdas_ent_c IN VARCHAR2
                            , v_tab_x07 IN VARCHAR2
                            , v_tab_x08 IN VARCHAR2
                            , v_tab_type IN VARCHAR2
                            , v_tab_footer IN VARCHAR2
                            , v_mproc_id IN NUMBER )
    IS
        v_sql VARCHAR2 ( 8000 );
        v_sql_part VARCHAR2 ( 8000 );
        v_qtde NUMBER;
        v_idx_prop VARCHAR2 ( 50 ) := '';
        ---
        v_limit INTEGER;
        v_tab_aux VARCHAR2 ( 30 );
        v_partition_x08 VARCHAR2 ( 100 );
        v_estabs VARCHAR2 ( 5000 );
        v_cod_estab VARCHAR2 ( 6 );
        c_est SYS_REFCURSOR;
        t_start NUMBER;
        ---
        v_i_x07_particao VARCHAR2 ( 128 );
        v_i_x08_particao VARCHAR2 ( 128 );
        v_i_ini_particao DATE;
        v_i_fim_particao DATE;

        ---
        CURSOR c_partition ( p_i_data_final IN DATE )
        IS
            SELECT   x07.partition_name AS x07_partition_name
                   , NVL ( x08.partition_name, 'NAO_EXISTE' ) AS x08_partition_name
                   , x07.partition_ini AS inicio_particao
                   , NVL ( x08.partition_fim, x07.partition_fim ) AS final_particao
                FROM (SELECT b.owner
                           , b.table_name
                           , b.partition_name
                           , NVL (   LEAD ( b.partition_fim
                                          , 1 )
                                     OVER (ORDER BY b.partition_fim DESC)
                                   + 1
                                 , TO_DATE (    '01'
                                             || TO_CHAR ( b.partition_fim
                                                        , 'MMYYYY' )
                                           , 'DDMMYYYY' ) )
                                 AS partition_ini
                           , b.partition_fim
                        FROM (SELECT   a.owner
                                     , a.table_name
                                     , a.partition_name
                                     , TO_DATE ( a.partition_fim
                                               , 'DD/MM/YYYY' )
                                           AS partition_fim
                                  /*SELECT A.OWNER, A.TABLE_NAME, A.PARTITION_NAME, TO_DATE(A.HIGH_VALUE,'DD/MM/YYYY') AS PARTITION_FIM*/
                                  FROM TABLE ( msafi.dpsp_recupera_particao ( 'MSAF'
                                                                            , 'X07_DOCTO_FISCAL'
                                                                            , TO_DATE ( '20130101'
                                                                                      , 'YYYYMMDD' )
                                                                            , p_i_data_final ) ) a
                              ORDER BY TO_DATE ( a.partition_fim
                                               , 'DD/MM/YYYY' )/*ORDER BY TO_DATE(A.HIGH_VALUE,'DD/MM/YYYY')*/
                                                               ) b) x07
                   , (SELECT b.owner
                           , b.table_name
                           , b.partition_name
                           , NVL (   LEAD ( b.partition_fim
                                          , 1 )
                                     OVER (ORDER BY b.partition_fim DESC)
                                   + 1
                                 , TO_DATE (    '01'
                                             || TO_CHAR ( b.partition_fim
                                                        , 'MMYYYY' )
                                           , 'DDMMYYYY' ) )
                                 AS partition_ini
                           , b.partition_fim
                        FROM (/*SELECT A.OWNER, A.TABLE_NAME, A.PARTITION_NAME, TO_DATE(A.HIGH_VALUE,'DD/MM/YYYY') AS PARTITION_FIM*/
                              SELECT   a.owner
                                     , a.table_name
                                     , a.partition_name
                                     , TO_DATE ( a.partition_fim
                                               , 'DD/MM/YYYY' )
                                           AS partition_fim
                                  FROM TABLE ( msafi.dpsp_recupera_particao ( 'MSAF'
                                                                            , 'X08_ITENS_MERC'
                                                                            , TO_DATE ( '20130101'
                                                                                      , 'YYYYMMDD' )
                                                                            , p_i_data_final ) ) a
                              ORDER BY TO_DATE ( a.partition_fim
                                               , 'DD/MM/YYYY' )/*ORDER BY TO_DATE(A.HIGH_VALUE,'DD/MM/YYYY')*/
                                                               ) b) x08
               WHERE x07.partition_fim = x08.partition_fim(+)
            ORDER BY x07.partition_fim DESC;

        ---
        CURSOR c_partition_dblink ( p_i_data_final IN DATE
                                  , p_i_dblink IN VARCHAR2 )
        IS
            SELECT   x07.partition_name AS x07_partition_name
                   , NVL ( x08.partition_name, 'NAO_EXISTE' ) AS x08_partition_name
                   , x07.partition_ini AS inicio_particao
                   , NVL ( x08.partition_fim, x07.partition_fim ) AS final_particao
                FROM (SELECT b.owner
                           , b.table_name
                           , b.partition_name
                           , NVL (   LEAD ( b.partition_fim
                                          , 1 )
                                     OVER (ORDER BY b.partition_fim DESC)
                                   + 1
                                 , TO_DATE (    '01'
                                             || TO_CHAR ( b.partition_fim
                                                        , 'MMYYYY' )
                                           , 'DDMMYYYY' ) )
                                 AS partition_ini
                           , b.partition_fim
                        FROM (SELECT   a.owner
                                     , a.table_name
                                     , a.partition_name
                                     , TO_DATE ( a.partition_fim
                                               , 'DD/MM/YYYY' )
                                           AS partition_fim
                                  /*SELECT A.OWNER, A.TABLE_NAME, A.PARTITION_NAME, TO_DATE(A.HIGH_VALUE,'DD/MM/YYYY') AS PARTITION_FIM*/
                                  FROM TABLE ( msafi.dpsp_recupera_particao_dblink ( 'MSAF'
                                                                                   , 'X07_DOCTO_FISCAL'
                                                                                   , TO_DATE ( '20130101'
                                                                                             , 'YYYYMMDD' )
                                                                                   , p_i_data_final
                                                                                   , p_i_dblink ) ) a
                              ORDER BY TO_DATE ( a.partition_fim
                                               , 'DD/MM/YYYY' )/*ORDER BY TO_DATE(A.HIGH_VALUE,'DD/MM/YYYY')*/
                                                               ) b) x07
                   , (SELECT b.owner
                           , b.table_name
                           , b.partition_name
                           , NVL (   LEAD ( b.partition_fim
                                          , 1 )
                                     OVER (ORDER BY b.partition_fim DESC)
                                   + 1
                                 , TO_DATE (    '01'
                                             || TO_CHAR ( b.partition_fim
                                                        , 'MMYYYY' )
                                           , 'DDMMYYYY' ) )
                                 AS partition_ini
                           , b.partition_fim
                        FROM (SELECT   a.owner
                                     , a.table_name
                                     , a.partition_name
                                     , TO_DATE ( a.partition_fim
                                               , 'DD/MM/YYYY' )
                                           AS partition_fim
                                  /*SELECT A.OWNER, A.TABLE_NAME, A.PARTITION_NAME, TO_DATE(A.HIGH_VALUE,'DD/MM/YYYY') AS PARTITION_FIM*/
                                  FROM TABLE ( msafi.dpsp_recupera_particao_dblink ( 'MSAF'
                                                                                   , 'X08_ITENS_MERC'
                                                                                   , TO_DATE ( '20130101'
                                                                                             , 'YYYYMMDD' )
                                                                                   , p_i_data_final
                                                                                   , p_i_dblink ) ) a
                              ORDER BY TO_DATE ( a.partition_fim
                                               , 'DD/MM/YYYY' )/*ORDER BY TO_DATE(A.HIGH_VALUE,'DD/MM/YYYY')*/
                                                               ) b) x08
               WHERE x07.partition_fim = x08.partition_fim(+)
            ORDER BY x07.partition_fim DESC;

        ---
        --- VAR PARA AUDITORIA DE PGA
        v_cpu_time_start NUMBER;
        v_cpu_time NUMBER;
        v_pga_ini NUMBER;
        v_pga_end NUMBER;
        v_uga_ini NUMBER;
        v_uga_end NUMBER;
        v_qtd_lines NUMBER;
    ----------------------------

    BEGIN
        IF ( v_tab_global_flag = 'N' ) THEN
            v_idx_prop := ' PCTFREE 10 NOLOGGING';
        END IF;

        IF ( vp_origem = 'C' ) THEN --CD
            --TAB AUXILIAR
            v_tab_aux := 'TC$_' || vp_cod_estab || vp_proc_instance;
            v_sql := 'CREATE ' || v_tab_type || ' TABLE ' || v_tab_aux;
            v_sql := v_sql || ' ( ';
            v_sql := v_sql || ' COD_ESTAB VARCHAR2(6), ';
            v_sql := v_sql || ' COD_PRODUTO VARCHAR2(12), ';
            v_sql := v_sql || ' DATA_INV DATE ';
            v_sql := v_sql || ' ) ' || v_tab_footer;

            EXECUTE IMMEDIATE v_sql;

            save_tmp_control ( vp_proc_instance
                             , v_tab_aux );

            v_sql := 'CREATE UNIQUE INDEX PKC_' || vp_cod_estab || vp_proc_instance || ' ON ' || v_tab_aux;
            v_sql := v_sql || ' ( ';
            v_sql := v_sql || ' COD_ESTAB ASC, ';
            v_sql := v_sql || ' COD_PRODUTO   ASC, ';
            v_sql := v_sql || ' DATA_INV      ASC  ';
            v_sql := v_sql || ' ) ' || v_idx_prop;

            EXECUTE IMMEDIATE v_sql;

            v_sql := 'CREATE INDEX IDX1C_' || vp_cod_estab || vp_proc_instance || ' ON ' || v_tab_aux;
            v_sql := v_sql || ' ( ';
            v_sql := v_sql || ' COD_PRODUTO   ASC, ';
            v_sql := v_sql || ' DATA_INV      ASC  ';
            v_sql := v_sql || ' ) ' || v_idx_prop;

            EXECUTE IMMEDIATE v_sql;

            v_sql := 'INSERT INTO ' || v_tab_aux;
            v_sql :=
                   v_sql
                || ' SELECT DISTINCT '''
                || vp_cod_estab
                || ''' AS COD_ESTAB, COD_PRODUTO, DATA_INV FROM '
                || vp_tab_perdas_inv;

            EXECUTE IMMEDIATE v_sql;

            loga ( '[TOTAL AUX][' || SQL%ROWCOUNT || ']'
                 , FALSE );
            COMMIT;

            --APAGAR LINHAS JA CARREGADAS NAs TABs DE ENTRADA ANTERIORES
            v_sql := 'DELETE ' || v_tab_aux || ' A ';
            v_sql := v_sql || ' WHERE EXISTS (SELECT ''Y'' ';
            v_sql := v_sql || '               FROM ' || vp_tab_perdas_ent_f || ' E ';
            v_sql := v_sql || '               WHERE E.COD_ESTAB_E   = A.COD_ESTAB ';
            v_sql := v_sql || '                 AND E.COD_PRODUTO_E = A.COD_PRODUTO ';
            v_sql := v_sql || '                 AND E.DATA_INV_S    = A.DATA_INV ) ';

            EXECUTE IMMEDIATE v_sql;

            loga ( '[LIMPEZA CD F][' || SQL%ROWCOUNT || ']'
                 , FALSE );
            COMMIT;

            v_sql := 'DELETE ' || v_tab_aux || ' A ';
            v_sql := v_sql || ' WHERE EXISTS (SELECT ''Y'' ';
            v_sql := v_sql || '               FROM ' || vp_tab_perdas_ent_c || ' E ';
            v_sql := v_sql || '               WHERE E.COD_PRODUTO_E = A.COD_PRODUTO ';
            v_sql := v_sql || '                 AND E.DATA_INV_S    = A.DATA_INV ) ';

            EXECUTE IMMEDIATE v_sql;

            loga ( '[LIMPEZA CD C][' || SQL%ROWCOUNT || ']'
                 , FALSE );
            COMMIT;

            dbms_stats.gather_table_stats ( 'MSAF'
                                          , v_tab_aux );

            --APENAS CONTINUA SE HOUVEREM LINHAS PARA QUERY
            EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || v_tab_aux            INTO v_qtde;

            IF ( v_qtde > 0 ) THEN --**
                v_limit := 0;
                v_partition_x08 := '';
                v_qtde := 0;

                IF ( a_cod_empresa ( vp_cod_estab ).empresa = msafi.dpsp.empresa ) THEN
                    OPEN c_partition ( vp_dt_final );
                ELSE
                    OPEN c_partition_dblink ( vp_dt_final
                                            , REPLACE ( a_cod_empresa ( vp_cod_estab ).dblink
                                                      , '@'
                                                      , '' ) );
                END IF;

                LOOP
                    IF ( a_cod_empresa ( vp_cod_estab ).empresa = msafi.dpsp.empresa ) THEN
                        FETCH c_partition
                            INTO v_i_x07_particao
                               , v_i_x08_particao
                               , v_i_ini_particao
                               , v_i_fim_particao;
                    ELSE
                        FETCH c_partition_dblink
                            INTO v_i_x07_particao
                               , v_i_x08_particao
                               , v_i_ini_particao
                               , v_i_fim_particao;
                    END IF;

                    IF ( a_cod_empresa ( vp_cod_estab ).empresa = msafi.dpsp.empresa ) THEN
                        EXIT WHEN c_partition%NOTFOUND;
                    ELSE
                        EXIT WHEN c_partition_dblink%NOTFOUND;
                    END IF;

                    v_limit := v_limit + 1;
                    t_start := dbms_utility.get_time;

                    IF ( v_i_x08_particao <> 'NAO_EXISTE'
                    AND a_cod_empresa ( vp_cod_estab ).dblink = 'LOCAL' ) THEN
                        --NAO E POSSIVEL CONSULTAR UMA PARTICAO USANDO DBLINK ORA-14100
                        v_partition_x08 := ' PARTITION ( ' || v_i_x08_particao || ') ';
                    END IF;

                    --LOAD X07 TEMP-INI--------------------------------------------------------
                    v_sql := 'DECLARE TYPE T_BULK_COLLECT_TAB07 IS TABLE OF ' || v_tab_x07 || '%ROWTYPE; ';
                    v_sql := v_sql || '        X07_TAB T_BULK_COLLECT_TAB07 := T_BULK_COLLECT_TAB07(); ';
                    v_sql := v_sql || 'BEGIN ';
                    ---
                    v_sql := v_sql || 'SELECT /*+RESULT_CACHE*/ ';
                    v_sql := v_sql || ' COD_EMPRESA        , ';
                    v_sql := v_sql || ' COD_ESTAB          , ';
                    v_sql := v_sql || ' DATA_FISCAL        , ';
                    v_sql := v_sql || ' MOVTO_E_S          , ';
                    v_sql := v_sql || ' NORM_DEV           , ';
                    v_sql := v_sql || ' IDENT_DOCTO        , ';
                    v_sql := v_sql || ' IDENT_FIS_JUR      , ';
                    v_sql := v_sql || ' NUM_DOCFIS         , ';
                    v_sql := v_sql || ' SERIE_DOCFIS       , ';
                    v_sql := v_sql || ' SUB_SERIE_DOCFIS   , ';
                    v_sql := v_sql || ' VLR_PRODUTO        , ';
                    v_sql := v_sql || ' DATA_EMISSAO       , ';
                    v_sql := v_sql || ' NUM_CONTROLE_DOCTO , ';
                    v_sql := v_sql || ' NUM_AUTENTIC_NFE     ';
                    v_sql := v_sql || 'BULK COLLECT INTO X07_TAB ';

                    IF ( a_cod_empresa ( vp_cod_estab ).dblink = 'LOCAL' ) THEN
                        v_sql := v_sql || 'FROM MSAF.X07_DOCTO_FISCAL PARTITION ( ' || v_i_x07_particao || ') ';
                    ELSE
                        v_sql := v_sql || 'FROM MSAF.X07_DOCTO_FISCAL' || a_cod_empresa ( vp_cod_estab ).dblink || ' ';
                    END IF;

                    v_sql := v_sql || 'WHERE COD_EMPRESA   = ''' || a_cod_empresa ( vp_cod_estab ).empresa || ''' ';
                    v_sql := v_sql || '  AND MOVTO_E_S    <> ''9'' ';
                    v_sql := v_sql || '  AND SITUACAO      = ''N'' ';
                    v_sql := v_sql || '  AND SERIE_DOCFIS <> ''GNR'' ';
                    v_sql :=
                           v_sql
                        || '  AND DATA_FISCAL BETWEEN TO_DATE('''
                        || TO_CHAR ( v_i_ini_particao
                                   , 'DDMMYYYY' )
                        || ''',''DDMMYYYY'') AND TO_DATE('''
                        || TO_CHAR ( v_i_fim_particao
                                   , 'DDMMYYYY' )
                        || ''',''DDMMYYYY'') ';
                    v_sql := v_sql || '  AND COD_ESTAB     = ''' || vp_cod_estab || '''; ';
                    ---
                    v_sql := v_sql || 'FORALL I IN X07_TAB.FIRST .. X07_TAB.LAST ';
                    v_sql := v_sql || ' INSERT INTO ' || v_tab_x07 || ' VALUES X07_TAB(I); ';
                    v_sql := v_sql || 'COMMIT; ';
                    ---
                    v_sql := v_sql || 'END; ';

                    ---AUDIT DE RECURSOS LIGADO--INI
                    IF ( v_audit_pga = 'Y' ) THEN
                        msafi.get_pga_memory ( USERENV ( 'SESSIONID' )
                                             , v_pga_ini
                                             , v_uga_ini );
                        v_cpu_time_start := dbms_utility.get_cpu_time;
                    END IF;

                    ---AUDIT DE RECURSOS LIGADO--FIM

                    EXECUTE IMMEDIATE v_sql;

                    ---AUDIT DE RECURSOS LIGADO--INI
                    IF ( v_audit_pga = 'Y' ) THEN
                        v_cpu_time := dbms_utility.get_cpu_time - v_cpu_time_start;
                        msafi.get_pga_memory ( USERENV ( 'SESSIONID' )
                                             , v_pga_end
                                             , v_uga_end );

                        EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || v_tab_x07            INTO v_qtd_lines;

                        audit_resources ( v_mproc_id
                                        , 'X07_DOCTO_FISCAL'
                                        , v_i_x07_particao
                                        , v_i_ini_particao
                                        , v_i_fim_particao
                                        , v_pga_ini
                                        , v_pga_end
                                        , v_cpu_time
                                        , 0
                                        , v_qtd_lines
                                        , 'LOAD_ENTRADA CD ' || vp_cod_estab
                                        , v_limit
                                        , v_uga_ini
                                        , v_uga_end );
                    END IF;

                    ---AUDIT DE RECURSOS LIGADO--FIM

                    --LOAD X07 TEMP-FIM--------------------------------------------------------

                    --LOAD X08 TEMP-INI--------------------------------------------------------
                    t_start := dbms_utility.get_time;
                    v_sql := 'DECLARE TYPE T_BULK_COLLECT_TAB08 IS TABLE OF ' || v_tab_x08 || '%ROWTYPE; ';
                    v_sql := v_sql || '        X08_TAB T_BULK_COLLECT_TAB08 := T_BULK_COLLECT_TAB08(); ';
                    v_sql := v_sql || 'BEGIN ';
                    ---
                    v_sql := v_sql || 'SELECT /*+RESULT_CACHE*/ COD_EMPRESA,';
                    v_sql := v_sql || '       COD_ESTAB,';
                    v_sql := v_sql || '       DATA_FISCAL,';
                    v_sql := v_sql || '       MOVTO_E_S,    ';
                    v_sql := v_sql || '       NORM_DEV,       ';
                    v_sql := v_sql || '       IDENT_DOCTO,  ';
                    v_sql := v_sql || '       IDENT_FIS_JUR,  ';
                    v_sql := v_sql || '       NUM_DOCFIS, ';
                    v_sql := v_sql || '       SERIE_DOCFIS, ';
                    v_sql := v_sql || '       SUB_SERIE_DOCFIS, ';
                    v_sql := v_sql || '       DISCRI_ITEM, ';
                    v_sql := v_sql || '       NUM_ITEM, ';
                    v_sql := v_sql || '       IDENT_NBM,  ';
                    v_sql := v_sql || '       IDENT_CFO,  ';
                    v_sql := v_sql || '       IDENT_NATUREZA_OP,';
                    v_sql := v_sql || '       IDENT_PRODUTO, ';
                    v_sql := v_sql || '       VLR_CONTAB_ITEM, ';
                    v_sql := v_sql || '       QUANTIDADE,  ';
                    v_sql :=
                           v_sql
                        || '       DECODE(QUANTIDADE, 0, 0, TRUNC((VLR_ITEM-VLR_DESCONTO)/QUANTIDADE,4)) AS VLR_UNIT,';
                    v_sql := v_sql || '       IDENT_SITUACAO_B, ';
                    v_sql := v_sql || '       IDENT_SITUACAO_A,  ';
                    v_sql := v_sql || '       COD_SITUACAO_PIS, ';
                    v_sql := v_sql || '       COD_SITUACAO_COFINS,';
                    v_sql :=
                           v_sql
                        || '       DECODE(QUANTIDADE, 0, 0, TRUNC(TRUNC((VLR_ITEM-VLR_DESCONTO)/QUANTIDADE,4)*0.0165,4)) AS ESTORNO_PIS_E,';
                    v_sql :=
                           v_sql
                        || '       DECODE(QUANTIDADE, 0, 0, TRUNC(TRUNC((VLR_ITEM-VLR_DESCONTO)/QUANTIDADE,4)*0.076,4)) AS ESTORNO_COFINS_E,';
                    v_sql := v_sql || '       VLR_PIS, ';
                    v_sql := v_sql || '       VLR_COFINS';
                    v_sql := v_sql || ' BULK COLLECT INTO X08_TAB ';

                    IF ( a_cod_empresa ( vp_cod_estab ).dblink = 'LOCAL' ) THEN
                        v_sql := v_sql || ' FROM MSAF.X08_ITENS_MERC ' || v_partition_x08 || ' ';
                    ELSE
                        v_sql := v_sql || ' FROM MSAF.X08_ITENS_MERC' || a_cod_empresa ( vp_cod_estab ).dblink || ' ';
                    END IF;

                    v_sql := v_sql || ' WHERE COD_EMPRESA = ''' || a_cod_empresa ( vp_cod_estab ).empresa || ''' ';
                    v_sql := v_sql || ' AND MOVTO_E_S    <> ''9'' ';
                    v_sql :=
                           v_sql
                        || ' AND DATA_FISCAL BETWEEN TO_DATE('''
                        || TO_CHAR ( v_i_ini_particao
                                   , 'DDMMYYYY' )
                        || ''',''DDMMYYYY'') AND TO_DATE('''
                        || TO_CHAR ( v_i_fim_particao
                                   , 'DDMMYYYY' )
                        || ''',''DDMMYYYY'') ';
                    v_sql := v_sql || ' AND COD_ESTAB     = ''' || vp_cod_estab || '''; ';
                    ---
                    v_sql := v_sql || 'FORALL I IN X08_TAB.FIRST .. X08_TAB.LAST ';
                    v_sql := v_sql || ' INSERT INTO ' || v_tab_x08 || ' VALUES X08_TAB(I); ';
                    v_sql := v_sql || 'COMMIT; ';
                    ---
                    v_sql := v_sql || 'END; ';

                    ---AUDIT DE RECURSOS LIGADO--INI
                    IF ( v_audit_pga = 'Y' ) THEN
                        msafi.get_pga_memory ( USERENV ( 'SESSIONID' )
                                             , v_pga_ini
                                             , v_uga_ini );
                        v_cpu_time_start := dbms_utility.get_cpu_time;
                    END IF;

                    ---AUDIT DE RECURSOS LIGADO--FIM

                    EXECUTE IMMEDIATE v_sql;

                    ---AUDIT DE RECURSOS LIGADO--INI
                    IF ( v_audit_pga = 'Y' ) THEN
                        v_cpu_time := dbms_utility.get_cpu_time - v_cpu_time_start;
                        msafi.get_pga_memory ( USERENV ( 'SESSIONID' )
                                             , v_pga_end
                                             , v_uga_end );

                        EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || v_tab_x08            INTO v_qtd_lines;

                        audit_resources ( v_mproc_id
                                        , 'X08_ITENS_MERC'
                                        , v_i_x08_particao
                                        , v_i_ini_particao
                                        , v_i_fim_particao
                                        , v_pga_ini
                                        , v_pga_end
                                        , v_cpu_time
                                        , 0
                                        , v_qtd_lines
                                        , 'LOAD_ENTRADA CD ' || vp_cod_estab
                                        , v_limit
                                        , v_uga_ini
                                        , v_uga_end );
                    END IF;

                    ---AUDIT DE RECURSOS LIGADO--FIM

                    dbms_stats.gather_table_stats ( 'MSAF'
                                                  , v_tab_x07 );
                    dbms_stats.gather_table_stats ( 'MSAF'
                                                  , v_tab_x08 );

                    --LOAD X08 TEMP-FIM--------------------------------------------------------

                    v_sql := 'DECLARE TYPE T_BULK_COLLECT_TAB_E IS TABLE OF ' || vp_tabela_entrada || '%ROWTYPE; ';
                    v_sql := v_sql || '        TAB_E T_BULK_COLLECT_TAB_E := T_BULK_COLLECT_TAB_E(); ';
                    v_sql := v_sql || 'BEGIN ';
                    ---
                    v_sql := v_sql || 'SELECT DISTINCT ';
                    v_sql := v_sql || '    ' || vp_proc_instance || ' AS PROC_ID, ';
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
                    v_sql :=
                        v_sql || '    ''' || a_cod_empresa ( vp_cod_estab ).business_unit || ''' AS BUSINESS_UNIT, '; ---BUSINESS_UNIT
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
                    v_sql := v_sql || ' BULK COLLECT INTO TAB_E ';
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
                    v_sql := v_sql || '        X08.VLR_UNIT, ';
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
                    v_sql := v_sql || '        X08.ESTORNO_PIS_E, ';
                    v_sql := v_sql || '        X08.ESTORNO_COFINS_E, ';
                    v_sql := v_sql || '        X08.VLR_PIS AS ESTORNO_PIS_S, ';
                    v_sql := v_sql || '        X08.VLR_COFINS AS ESTORNO_COFINS_S, ';
                    v_sql := v_sql || '        RANK() OVER( ';
                    v_sql := v_sql || '          PARTITION BY X08.COD_ESTAB, D.COD_PRODUTO ';
                    v_sql := v_sql || '              ORDER BY X08.DATA_FISCAL DESC, ';
                    v_sql := v_sql || '                       X07.DATA_EMISSAO DESC, ';
                    v_sql := v_sql || '                       X08.NUM_DOCFIS DESC, ';
                    v_sql := v_sql || '                       X08.DISCRI_ITEM DESC, ';
                    v_sql := v_sql || '                       X08.SERIE_DOCFIS ) RANK ';

                    ---
                    IF ( a_cod_empresa ( vp_cod_estab ).dblink = 'LOCAL' ) THEN
                        ---LOCAL
                        v_sql := v_sql || '    FROM ' || v_tab_x08 || ' X08, ';
                        v_sql := v_sql || '         ' || v_tab_x07 || ' X07, ';
                        v_sql := v_sql || '         MSAF.X2013_PRODUTO D, ';
                        v_sql := v_sql || '         MSAF.X04_PESSOA_FIS_JUR G, ';
                        v_sql := v_sql || '         MSAF.X2043_COD_NBM A, ';
                        v_sql := v_sql || '         MSAF.X2012_COD_FISCAL B, ';
                        v_sql := v_sql || '         MSAF.X2006_NATUREZA_OP C, ';
                        v_sql := v_sql || '         MSAF.Y2026_SIT_TRB_UF_B E, ';
                        v_sql := v_sql || '         MSAF.ESTADO H,  ';
                        v_sql := v_sql || '         MSAF.Y2025_SIT_TRB_UF_A I, ';
                    ELSE
                        ---DBLINK
                        v_sql := v_sql || '    FROM ' || v_tab_x08 || ' X08, ';
                        v_sql := v_sql || '         ' || v_tab_x07 || ' X07, ';
                        v_sql :=
                            v_sql || '         MSAF.X2013_PRODUTO' || a_cod_empresa ( vp_cod_estab ).dblink || ' D, ';
                        v_sql :=
                               v_sql
                            || '         MSAF.X04_PESSOA_FIS_JUR'
                            || a_cod_empresa ( vp_cod_estab ).dblink
                            || ' G, ';
                        v_sql :=
                            v_sql || '         MSAF.X2043_COD_NBM' || a_cod_empresa ( vp_cod_estab ).dblink || ' A, ';
                        v_sql :=
                               v_sql
                            || '         MSAF.X2012_COD_FISCAL'
                            || a_cod_empresa ( vp_cod_estab ).dblink
                            || ' B, ';
                        v_sql :=
                               v_sql
                            || '         MSAF.X2006_NATUREZA_OP'
                            || a_cod_empresa ( vp_cod_estab ).dblink
                            || ' C, ';
                        v_sql :=
                               v_sql
                            || '         MSAF.Y2026_SIT_TRB_UF_B'
                            || a_cod_empresa ( vp_cod_estab ).dblink
                            || ' E, ';
                        v_sql := v_sql || '         MSAF.ESTADO' || a_cod_empresa ( vp_cod_estab ).dblink || ' H,  ';
                        v_sql :=
                               v_sql
                            || '         MSAF.Y2025_SIT_TRB_UF_A'
                            || a_cod_empresa ( vp_cod_estab ).dblink
                            || ' I, ';
                    END IF;

                    ---
                    v_sql := v_sql || '         ' || v_tab_aux || ' P ';
                    ---
                    v_sql :=
                        v_sql || '    WHERE X07.COD_EMPRESA   = ''' || a_cod_empresa ( vp_cod_estab ).empresa || ''' ';
                    v_sql := v_sql || '      AND X07.COD_ESTAB     = ''' || vp_cod_estab || ''' ';
                    ---
                    v_sql := v_sql || '      AND X08.IDENT_NBM         = A.IDENT_NBM ';
                    v_sql := v_sql || '      AND X08.IDENT_CFO         = B.IDENT_CFO ';
                    v_sql :=
                           v_sql
                        || '      AND B.COD_CFO             IN (''1102'',''2102'',''1403'',''2403'',''1910'',''2910'') ';
                    v_sql := v_sql || '      AND C.COD_NATUREZA_OP    <> ''ISE'' ';
                    v_sql := v_sql || '      AND X08.IDENT_NATUREZA_OP = C.IDENT_NATUREZA_OP ';
                    v_sql := v_sql || '      AND X08.IDENT_SITUACAO_B  = E.IDENT_SITUACAO_B ';
                    v_sql := v_sql || '      AND X08.IDENT_SITUACAO_A  = I.IDENT_SITUACAO_A ';
                    v_sql := v_sql || '      AND X07.VLR_PRODUTO       > 0.01 ';
                    v_sql := v_sql || '      AND X08.IDENT_PRODUTO     = D.IDENT_PRODUTO ';
                    ---
                    v_sql := v_sql || '      AND P.COD_PRODUTO    =  D.COD_PRODUTO ';
                    v_sql := v_sql || '      AND P.DATA_INV       >  X07.DATA_FISCAL ';
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
                    v_sql := v_sql || 'WHERE A.RANK = 1; ';
                    ---
                    v_sql := v_sql || 'FORALL I IN TAB_E.FIRST .. TAB_E.LAST ';
                    v_sql := v_sql || ' INSERT INTO ' || vp_tabela_entrada || ' VALUES TAB_E(I); ';
                    v_sql := v_sql || 'COMMIT; ';
                    ---
                    v_sql := v_sql || 'END; ';

                    ---AUDIT DE RECURSOS LIGADO--INI
                    IF ( v_audit_pga = 'Y' ) THEN
                        msafi.get_pga_memory ( USERENV ( 'SESSIONID' )
                                             , v_pga_ini
                                             , v_uga_ini );
                        v_cpu_time_start := dbms_utility.get_cpu_time;
                    END IF;

                    ---AUDIT DE RECURSOS LIGADO--FIM

                    BEGIN
                        EXECUTE IMMEDIATE v_sql;
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
                                          , 3072
                                          , 1024 )
                                 , FALSE );
                            loga ( SUBSTR ( v_sql
                                          , 4096
                                          , 1024 )
                                 , FALSE );
                            loga ( SUBSTR ( v_sql
                                          , 5120 )
                                 , FALSE );
                            ---
                            raise_application_error ( -20003
                                                    , '!ERRO INSERT LOAD ENTRADAS CD!' );
                    END;

                    ---AUDIT DE RECURSOS LIGADO--INI
                    IF ( v_audit_pga = 'Y' ) THEN
                        v_cpu_time := dbms_utility.get_cpu_time - v_cpu_time_start;
                        msafi.get_pga_memory ( USERENV ( 'SESSIONID' )
                                             , v_pga_end
                                             , v_uga_end );

                        EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || vp_tabela_entrada            INTO v_qtd_lines;

                        audit_resources ( v_mproc_id
                                        , 'QUERY ULT ENTRADA'
                                        , NULL
                                        , v_i_ini_particao
                                        , v_i_fim_particao
                                        , v_pga_ini
                                        , v_pga_end
                                        , v_cpu_time
                                        , 0
                                        , v_qtd_lines
                                        , 'LOAD_ENTRADA CD ' || vp_cod_estab
                                        , v_limit
                                        , v_uga_ini
                                        , v_uga_end );
                    END IF;

                    ---AUDIT DE RECURSOS LIGADO--FIM

                    --APAGAR LINHAS JA CARREGADAS NA TAB DE ENTRADA
                    v_sql := 'DELETE ' || v_tab_aux || ' A ';
                    v_sql := v_sql || ' WHERE EXISTS (SELECT ''Y'' ';
                    v_sql := v_sql || '               FROM ' || vp_tabela_entrada || ' E ';
                    v_sql := v_sql || '               WHERE E.COD_ESTAB_E   = A.COD_ESTAB ';
                    v_sql := v_sql || '                 AND E.COD_PRODUTO_E = A.COD_PRODUTO ';
                    v_sql := v_sql || '                 AND E.DATA_INV_S    = A.DATA_INV ) ';

                    EXECUTE IMMEDIATE v_sql;

                    --LOGA('[AUX DEL][' || SQL%ROWCOUNT || ']',FALSE);
                    COMMIT;

                    BEGIN
                        EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || v_tab_aux            INTO v_qtde;
                    --LOGA('[' || VP_COD_ESTAB || '][BUSCA ' || V_LIMIT || '][' || V_QTDE || '][' || V_PARTITION_X08 || '][' || V_I_INI_PARTICAO || '][' || V_I_FIM_PARTICAO || ']',FALSE);
                    EXCEPTION
                        WHEN OTHERS THEN
                            v_qtde := 0;
                    END;

                    EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || v_tab_x08;

                    EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || v_tab_x07;

                    IF ( v_limit = 24
                     OR v_qtde = 0 ) THEN
                        --VOLTAR 2 ANOS
                        loga ( '[EXIT]'
                             , FALSE );
                        EXIT;
                    END IF;
                END LOOP;

                ---AUDIT DE RECURSOS LIGADO--INI
                IF ( v_audit_pga = 'Y' ) THEN
                    save_audit;
                END IF;
            ---AUDIT DE RECURSOS LIGADO--FIM

            END IF; --**
        ELSIF ( vp_origem = 'F' ) THEN --FILIAL
            --TAB AUXILIAR
            v_tab_aux := 'TF$_' || vp_cd || vp_proc_instance;
            v_sql := 'CREATE ' || v_tab_type || ' TABLE ' || v_tab_aux;
            v_sql := v_sql || ' ( ';
            v_sql := v_sql || ' COD_ESTAB VARCHAR2(6), ';
            v_sql := v_sql || ' COD_PRODUTO VARCHAR2(12), ';
            v_sql := v_sql || ' DATA_INV DATE ';
            v_sql := v_sql || ' ) ' || v_tab_footer;

            EXECUTE IMMEDIATE v_sql;

            save_tmp_control ( vp_proc_instance
                             , v_tab_aux );

            v_sql := 'CREATE UNIQUE INDEX PKF_' || vp_cd || vp_proc_instance || ' ON ' || v_tab_aux;
            v_sql := v_sql || ' ( ';
            v_sql := v_sql || ' COD_ESTAB     ASC, ';
            v_sql := v_sql || ' COD_PRODUTO   ASC, ';
            v_sql := v_sql || ' DATA_INV      ASC  ';
            v_sql := v_sql || ' ) ' || v_idx_prop;

            EXECUTE IMMEDIATE v_sql;

            v_sql := 'INSERT INTO ' || v_tab_aux;
            v_sql := v_sql || ' SELECT DISTINCT COD_ESTAB, COD_PRODUTO, DATA_INV FROM ' || vp_tab_perdas_inv;

            EXECUTE IMMEDIATE v_sql;

            loga ( '[TOTAL AUX][' || SQL%ROWCOUNT || ']'
                 , FALSE );
            COMMIT;

            --APAGAR LINHAS JA CARREGADAS NAs TABs DE ENTRADA ANTERIORES
            v_sql := 'DELETE ' || v_tab_aux || ' A ';
            v_sql := v_sql || ' WHERE EXISTS (SELECT ''Y'' ';
            v_sql := v_sql || '               FROM ' || vp_tab_perdas_ent_f || ' E ';
            v_sql := v_sql || '               WHERE E.COD_ESTAB_E   = A.COD_ESTAB ';
            v_sql := v_sql || '                 AND E.COD_PRODUTO_E = A.COD_PRODUTO ';
            v_sql := v_sql || '                 AND E.DATA_INV_S    = A.DATA_INV ) ';

            EXECUTE IMMEDIATE v_sql;

            loga ( '[LIMPEZA FIL F][' || SQL%ROWCOUNT || ']'
                 , FALSE );
            COMMIT;

            v_sql := 'DELETE ' || v_tab_aux || ' A ';
            v_sql := v_sql || ' WHERE EXISTS (SELECT ''Y'' ';
            v_sql := v_sql || '               FROM ' || vp_tab_perdas_ent_c || ' E ';
            v_sql := v_sql || '               WHERE E.COD_PRODUTO_E = A.COD_PRODUTO ';
            v_sql := v_sql || '                 AND E.DATA_INV_S    = A.DATA_INV ) ';

            EXECUTE IMMEDIATE v_sql;

            loga ( '[LIMPEZA FIL C][' || SQL%ROWCOUNT || ']'
                 , FALSE );
            COMMIT;

            dbms_stats.gather_table_stats ( 'MSAF'
                                          , v_tab_aux );

            --APENAS CONTINUA SE HOUVEREM LINHAS PARA QUERY
            EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || v_tab_aux            INTO v_qtde;

            IF ( v_qtde > 0 ) THEN --**
                v_limit := 0;
                v_partition_x08 := '';
                v_qtde := 0;

                FOR c_part IN c_partition ( vp_dt_final ) LOOP
                    v_estabs := ' ';

                    OPEN c_est FOR 'SELECT DISTINCT COD_ESTAB FROM ' || v_tab_aux;

                    LOOP
                        FETCH c_est
                            INTO v_cod_estab;

                        EXIT WHEN c_est%NOTFOUND;
                        v_estabs := v_estabs || '''' || v_cod_estab || ''',';
                    END LOOP;

                    v_estabs :=
                        SUBSTR ( v_estabs
                               , 1
                               , LENGTH ( v_estabs ) - 1 );

                    ---
                    IF ( c_part.x08_partition_name <> 'NAO_EXISTE' ) THEN
                        v_partition_x08 := ' PARTITION ( ' || c_part.x08_partition_name || ') ';
                    END IF;

                    t_start := dbms_utility.get_time;
                    v_limit := v_limit + 1;
                    dbms_application_info.set_module ( $$plsql_unit
                                                     , 'ENTRADA FILIAIS CD ' || vp_cd || ' [' || v_limit || ']' );

                    --LOAD X07 TEMP-INI--------------------------------------------------------
                    v_sql := 'DECLARE TYPE T_BULK_COLLECT_TAB07 IS TABLE OF ' || v_tab_x07 || '%ROWTYPE; ';
                    v_sql := v_sql || '        X07_TAB T_BULK_COLLECT_TAB07 := T_BULK_COLLECT_TAB07(); ';
                    v_sql := v_sql || 'BEGIN ';
                    ---
                    v_sql := v_sql || 'SELECT /*+RESULT_CACHE*/ ';
                    v_sql := v_sql || ' COD_EMPRESA        , ';
                    v_sql := v_sql || ' COD_ESTAB          , ';
                    v_sql := v_sql || ' DATA_FISCAL        , ';
                    v_sql := v_sql || ' MOVTO_E_S          , ';
                    v_sql := v_sql || ' NORM_DEV           , ';
                    v_sql := v_sql || ' IDENT_DOCTO        , ';
                    v_sql := v_sql || ' IDENT_FIS_JUR      , ';
                    v_sql := v_sql || ' NUM_DOCFIS         , ';
                    v_sql := v_sql || ' SERIE_DOCFIS       , ';
                    v_sql := v_sql || ' SUB_SERIE_DOCFIS   , ';
                    v_sql := v_sql || ' VLR_PRODUTO        , ';
                    v_sql := v_sql || ' DATA_EMISSAO       , ';
                    v_sql := v_sql || ' NUM_CONTROLE_DOCTO , ';
                    v_sql := v_sql || ' NUM_AUTENTIC_NFE     ';
                    v_sql := v_sql || 'BULK COLLECT INTO X07_TAB ';
                    v_sql := v_sql || 'FROM MSAF.X07_DOCTO_FISCAL PARTITION ( ' || c_part.x07_partition_name || ') ';
                    v_sql := v_sql || 'WHERE COD_EMPRESA = MSAFI.DPSP.EMPRESA ';
                    v_sql := v_sql || '  AND MOVTO_E_S <> ''9'' ';
                    v_sql := v_sql || '  AND SITUACAO   = ''N'' ';
                    v_sql :=
                           v_sql
                        || '  AND DATA_FISCAL BETWEEN TO_DATE('''
                        || TO_CHAR ( c_part.inicio_particao
                                   , 'DDMMYYYY' )
                        || ''',''DDMMYYYY'') AND TO_DATE('''
                        || TO_CHAR ( c_part.final_particao
                                   , 'DDMMYYYY' )
                        || ''',''DDMMYYYY'') ';
                    v_sql := v_sql || '  AND COD_ESTAB IN (' || v_estabs || '); ';
                    ---
                    v_sql := v_sql || 'FORALL I IN X07_TAB.FIRST .. X07_TAB.LAST ';
                    v_sql := v_sql || ' INSERT INTO ' || v_tab_x07 || ' VALUES X07_TAB(I); ';
                    v_sql := v_sql || 'COMMIT; ';
                    ---
                    v_sql := v_sql || 'END; ';

                    ---AUDIT DE RECURSOS LIGADO--INI
                    IF ( v_audit_pga = 'Y' ) THEN
                        msafi.get_pga_memory ( USERENV ( 'SESSIONID' )
                                             , v_pga_ini
                                             , v_uga_ini );
                        v_cpu_time_start := dbms_utility.get_cpu_time;
                    END IF;

                    ---AUDIT DE RECURSOS LIGADO--FIM

                    EXECUTE IMMEDIATE v_sql;

                    ---AUDIT DE RECURSOS LIGADO--INI
                    IF ( v_audit_pga = 'Y' ) THEN
                        v_cpu_time := dbms_utility.get_cpu_time - v_cpu_time_start;
                        msafi.get_pga_memory ( USERENV ( 'SESSIONID' )
                                             , v_pga_end
                                             , v_uga_end );

                        EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || v_tab_x07            INTO v_qtd_lines;

                        audit_resources ( v_mproc_id
                                        , 'X07_DOCTO_FISCAL'
                                        , v_i_x07_particao
                                        , v_i_ini_particao
                                        , v_i_fim_particao
                                        , v_pga_ini
                                        , v_pga_end
                                        , v_cpu_time
                                        , 0
                                        , v_qtd_lines
                                        , 'LOAD_ENTRADA FILIAL ' || vp_cd
                                        , v_limit
                                        , v_uga_ini
                                        , v_uga_end );
                    END IF;

                    ---AUDIT DE RECURSOS LIGADO--FIM

                    --LOAD X07 TEMP-FIM--------------------------------------------------------

                    --LOAD X08 TEMP-INI--------------------------------------------------------
                    t_start := dbms_utility.get_time;
                    v_sql := 'DECLARE TYPE T_BULK_COLLECT_TAB08 IS TABLE OF ' || v_tab_x08 || '%ROWTYPE; ';
                    v_sql := v_sql || '        X08_TAB T_BULK_COLLECT_TAB08 := T_BULK_COLLECT_TAB08(); ';
                    v_sql := v_sql || 'BEGIN ';
                    ---
                    v_sql := v_sql || 'SELECT /*+RESULT_CACHE*/ COD_EMPRESA,';
                    v_sql := v_sql || '       COD_ESTAB,';
                    v_sql := v_sql || '       DATA_FISCAL,';
                    v_sql := v_sql || '       MOVTO_E_S,    ';
                    v_sql := v_sql || '       NORM_DEV,       ';
                    v_sql := v_sql || '       IDENT_DOCTO,  ';
                    v_sql := v_sql || '       IDENT_FIS_JUR,  ';
                    v_sql := v_sql || '       NUM_DOCFIS, ';
                    v_sql := v_sql || '       SERIE_DOCFIS, ';
                    v_sql := v_sql || '       SUB_SERIE_DOCFIS, ';
                    v_sql := v_sql || '       DISCRI_ITEM, ';
                    v_sql := v_sql || '       NUM_ITEM, ';
                    v_sql := v_sql || '       IDENT_NBM,  ';
                    v_sql := v_sql || '       IDENT_CFO,  ';
                    v_sql := v_sql || '       IDENT_NATUREZA_OP,';
                    v_sql := v_sql || '       IDENT_PRODUTO, ';
                    v_sql := v_sql || '       VLR_CONTAB_ITEM, ';
                    v_sql := v_sql || '       QUANTIDADE,  ';
                    v_sql :=
                           v_sql
                        || '       DECODE(QUANTIDADE, 0, 0, TRUNC((VLR_ITEM-VLR_DESCONTO)/QUANTIDADE,4)) AS VLR_UNIT,';
                    v_sql := v_sql || '       IDENT_SITUACAO_B, ';
                    v_sql := v_sql || '       IDENT_SITUACAO_A,  ';
                    v_sql := v_sql || '       COD_SITUACAO_PIS, ';
                    v_sql := v_sql || '       COD_SITUACAO_COFINS,';
                    v_sql :=
                           v_sql
                        || '       DECODE(QUANTIDADE, 0, 0, TRUNC(TRUNC((VLR_ITEM-VLR_DESCONTO)/QUANTIDADE,4)*0.0165,4)) AS ESTORNO_PIS_E,';
                    v_sql :=
                           v_sql
                        || '       DECODE(QUANTIDADE, 0, 0, TRUNC(TRUNC((VLR_ITEM-VLR_DESCONTO)/QUANTIDADE,4)*0.076,4)) AS ESTORNO_COFINS_E,';
                    v_sql := v_sql || '       VLR_PIS, ';
                    v_sql := v_sql || '       VLR_COFINS';
                    v_sql := v_sql || ' BULK COLLECT INTO X08_TAB ';
                    v_sql := v_sql || ' FROM MSAF.X08_ITENS_MERC ' || v_partition_x08 || ' ';
                    v_sql := v_sql || ' WHERE COD_EMPRESA = MSAFI.DPSP.EMPRESA ';
                    v_sql := v_sql || ' AND MOVTO_E_S <> ''9'' ';
                    v_sql :=
                           v_sql
                        || ' AND DATA_FISCAL BETWEEN TO_DATE('''
                        || TO_CHAR ( c_part.inicio_particao
                                   , 'DDMMYYYY' )
                        || ''',''DDMMYYYY'') AND TO_DATE('''
                        || TO_CHAR ( c_part.final_particao
                                   , 'DDMMYYYY' )
                        || ''',''DDMMYYYY'') ';
                    v_sql := v_sql || ' AND COD_ESTAB IN (' || v_estabs || '); ';
                    ---
                    v_sql := v_sql || 'FORALL I IN X08_TAB.FIRST .. X08_TAB.LAST ';
                    v_sql := v_sql || ' INSERT INTO ' || v_tab_x08 || ' VALUES X08_TAB(I); ';
                    v_sql := v_sql || 'COMMIT; ';
                    ---
                    v_sql := v_sql || 'END; ';

                    ---AUDIT DE RECURSOS LIGADO--INI
                    IF ( v_audit_pga = 'Y' ) THEN
                        msafi.get_pga_memory ( USERENV ( 'SESSIONID' )
                                             , v_pga_ini
                                             , v_uga_ini );
                        v_cpu_time_start := dbms_utility.get_cpu_time;
                    END IF;

                    ---AUDIT DE RECURSOS LIGADO--FIM

                    EXECUTE IMMEDIATE v_sql;

                    ---AUDIT DE RECURSOS LIGADO--INI
                    IF ( v_audit_pga = 'Y' ) THEN
                        v_cpu_time := dbms_utility.get_cpu_time - v_cpu_time_start;
                        msafi.get_pga_memory ( USERENV ( 'SESSIONID' )
                                             , v_pga_end
                                             , v_uga_end );

                        EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || v_tab_x08            INTO v_qtd_lines;

                        audit_resources ( v_mproc_id
                                        , 'X08_ITENS_MERC'
                                        , v_i_x08_particao
                                        , v_i_ini_particao
                                        , v_i_fim_particao
                                        , v_pga_ini
                                        , v_pga_end
                                        , v_cpu_time
                                        , 0
                                        , v_qtd_lines
                                        , 'LOAD_ENTRADA FILIAL ' || vp_cd
                                        , v_limit
                                        , v_uga_ini
                                        , v_uga_end );
                    END IF;

                    ---AUDIT DE RECURSOS LIGADO--FIM

                    dbms_stats.gather_table_stats ( 'MSAF'
                                                  , v_tab_x07 );
                    dbms_stats.gather_table_stats ( 'MSAF'
                                                  , v_tab_x08 );
                    --LOAD X08 TEMP-FIM--------------------------------------------------------

                    t_start := dbms_utility.get_time;
                    v_sql := 'DECLARE TYPE T_BULK_COLLECT_TAB_E IS TABLE OF ' || vp_tabela_entrada || '%ROWTYPE; ';
                    v_sql := v_sql || '        TAB_E T_BULK_COLLECT_TAB_E := T_BULK_COLLECT_TAB_E(); ';
                    v_sql := v_sql || 'BEGIN ';
                    ---
                    v_sql := v_sql || 'SELECT DISTINCT ';
                    v_sql := v_sql || ' ' || vp_proc_instance || ' AS PROC_ID, ';
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
                    v_sql := v_sql || '    ''' || a_cod_empresa ( 'DEFAULT' ).business_unit || ''' AS BUSINESS_UNIT, '; ---BUSINESS_UNIT
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
                    v_sql := v_sql || ' BULK COLLECT INTO TAB_E ';
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
                    v_sql := v_sql || '        X08.VLR_UNIT, ';
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
                    v_sql := v_sql || '        X08.ESTORNO_PIS_E, ';
                    v_sql := v_sql || '        X08.ESTORNO_COFINS_E, ';
                    v_sql := v_sql || '        X08.VLR_PIS AS ESTORNO_PIS_S, ';
                    v_sql := v_sql || '        X08.VLR_COFINS AS ESTORNO_COFINS_S, ';
                    v_sql := v_sql || '        RANK() OVER( ';
                    v_sql := v_sql || '          PARTITION BY X08.COD_ESTAB, D.COD_PRODUTO ';
                    v_sql := v_sql || '              ORDER BY X08.DATA_FISCAL DESC, ';
                    v_sql := v_sql || '                       X07.DATA_EMISSAO DESC, ';
                    v_sql := v_sql || '                       X08.NUM_DOCFIS DESC, ';
                    v_sql := v_sql || '                       X08.DISCRI_ITEM DESC, ';
                    v_sql := v_sql || '                       X08.SERIE_DOCFIS) RANK ';
                    v_sql := v_sql || '    FROM ' || v_tab_x08 || ' X08, ';
                    v_sql := v_sql || '         ' || v_tab_x07 || ' X07, ';
                    v_sql := v_sql || '         X2013_PRODUTO D, ';
                    v_sql := v_sql || '         X04_PESSOA_FIS_JUR G, ';
                    v_sql := v_sql || '         ' || v_tab_aux || ' P, ';
                    v_sql := v_sql || '         X2043_COD_NBM A, ';
                    v_sql := v_sql || '         X2012_COD_FISCAL B, ';
                    v_sql := v_sql || '         X2006_NATUREZA_OP C, ';
                    v_sql := v_sql || '         Y2026_SIT_TRB_UF_B E, ';
                    v_sql := v_sql || '         ESTADO H, ';
                    v_sql := v_sql || '         Y2025_SIT_TRB_UF_A I ';
                    v_sql := v_sql || '    WHERE X07.COD_EMPRESA = MSAFI.DPSP.EMPRESA ';
                    v_sql := v_sql || '      AND G.CPF_CGC       = ''' || a_cod_empresa ( vp_cd ).cnpj || ''' ';
                    ---
                    v_sql := v_sql || '      AND X08.IDENT_NBM         = A.IDENT_NBM ';
                    v_sql := v_sql || '      AND X08.IDENT_CFO         = B.IDENT_CFO ';
                    v_sql :=
                           v_sql
                        || '      AND B.COD_CFO             IN (''1152'',''2152'',''1409'',''2409'',''1403'',''2403'') ';
                    v_sql := v_sql || '      AND C.COD_NATUREZA_OP    <> ''ISE'' ';
                    v_sql := v_sql || '      AND X08.IDENT_NATUREZA_OP = C.IDENT_NATUREZA_OP ';
                    v_sql := v_sql || '      AND X08.IDENT_SITUACAO_B  = E.IDENT_SITUACAO_B ';
                    v_sql := v_sql || '      AND X08.IDENT_SITUACAO_A  = I.IDENT_SITUACAO_A ';
                    v_sql := v_sql || '      AND X07.VLR_PRODUTO       <> 0 ';
                    v_sql := v_sql || '      AND X08.IDENT_PRODUTO     = D.IDENT_PRODUTO ';
                    ---
                    v_sql := v_sql || '      AND P.COD_ESTAB     = X07.COD_ESTAB ';
                    v_sql := v_sql || '      AND P.COD_PRODUTO   = D.COD_PRODUTO ';
                    v_sql := v_sql || '      AND P.DATA_INV      > X07.DATA_FISCAL ';
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
                    v_sql := v_sql || 'WHERE A.RANK = 1;  ';
                    ---
                    v_sql := v_sql || 'FORALL I IN TAB_E.FIRST .. TAB_E.LAST ';
                    v_sql := v_sql || ' INSERT INTO ' || vp_tabela_entrada || ' VALUES TAB_E(I); ';
                    v_sql := v_sql || 'COMMIT; ';
                    ---
                    v_sql := v_sql || 'END; ';

                    ---AUDIT DE RECURSOS LIGADO--INI
                    IF ( v_audit_pga = 'Y' ) THEN
                        msafi.get_pga_memory ( USERENV ( 'SESSIONID' )
                                             , v_pga_ini
                                             , v_uga_ini );
                        v_cpu_time_start := dbms_utility.get_cpu_time;
                    END IF;

                    ---AUDIT DE RECURSOS LIGADO--FIM

                    BEGIN
                        EXECUTE IMMEDIATE v_sql;
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

                    ---AUDIT DE RECURSOS LIGADO--INI
                    IF ( v_audit_pga = 'Y' ) THEN
                        v_cpu_time := dbms_utility.get_cpu_time - v_cpu_time_start;
                        msafi.get_pga_memory ( USERENV ( 'SESSIONID' )
                                             , v_pga_end
                                             , v_uga_end );

                        EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || vp_tabela_entrada            INTO v_qtd_lines;

                        audit_resources ( v_mproc_id
                                        , 'QUERY ULT ENTRADA'
                                        , NULL
                                        , v_i_ini_particao
                                        , v_i_fim_particao
                                        , v_pga_ini
                                        , v_pga_end
                                        , v_cpu_time
                                        , 0
                                        , v_qtd_lines
                                        , 'LOAD_ENTRADA FILIAL ' || vp_cd
                                        , v_limit
                                        , v_uga_ini
                                        , v_uga_end );
                    END IF;

                    ---AUDIT DE RECURSOS LIGADO--FIM

                    --APAGAR LINHAS JA CARREGADAS NA TAB DE ENTRADA
                    v_sql := 'DELETE ' || v_tab_aux || ' A ';
                    v_sql := v_sql || ' WHERE EXISTS (SELECT ''Y'' ';
                    v_sql := v_sql || '               FROM ' || vp_tabela_entrada || ' E ';
                    v_sql := v_sql || '               WHERE E.COD_ESTAB_E   = A.COD_ESTAB ';
                    v_sql := v_sql || '                 AND E.COD_PRODUTO_E = A.COD_PRODUTO ';
                    v_sql := v_sql || '                 AND E.DATA_INV_S    = A.DATA_INV ) ';

                    EXECUTE IMMEDIATE v_sql;

                    ---LOGA('[AUX DEL][' || SQL%ROWCOUNT || ']',FALSE);
                    COMMIT;

                    BEGIN
                        EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || v_tab_aux            INTO v_qtde;
                    --LOGA('[ENTRADA FILIAL][BUSCA ' || V_LIMIT || '][' || V_QTDE || '][' || V_PARTITION_X08 || '][' || C_PART.INICIO_PARTICAO || '][' || C_PART.FINAL_PARTICAO || ']',FALSE);
                    EXCEPTION
                        WHEN OTHERS THEN
                            v_qtde := 0;
                    END;

                    EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || v_tab_x08;

                    EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || v_tab_x07;

                    IF ( v_limit = 24
                     OR v_qtde = 0 ) THEN
                        --VOLTAR 2 ANOS
                        loga ( '[EXIT]'
                             , FALSE );
                        EXIT;
                    END IF;
                END LOOP;

                ---AUDIT DE RECURSOS LIGADO--INI
                IF ( v_audit_pga = 'Y' ) THEN
                    save_audit;
                END IF;
            ---AUDIT DE RECURSOS LIGADO--FIM

            END IF; --**
        ELSIF ( vp_origem = 'CO' ) THEN --COMPRA DIRETA
            --TAB AUXILIAR
            v_tab_aux := 'TO$_' || vp_cod_estab || vp_proc_instance;
            v_sql := 'CREATE ' || v_tab_type || ' TABLE ' || v_tab_aux;
            v_sql := v_sql || ' ( ';
            v_sql := v_sql || ' COD_ESTAB VARCHAR2(6), ';
            v_sql := v_sql || ' COD_PRODUTO VARCHAR2(12), ';
            v_sql := v_sql || ' DATA_INV DATE ';
            v_sql := v_sql || ' ) ' || v_tab_footer;

            EXECUTE IMMEDIATE v_sql;

            save_tmp_control ( vp_proc_instance
                             , v_tab_aux );

            v_sql := 'CREATE UNIQUE INDEX PKO_' || vp_proc_instance || ' ON ' || v_tab_aux;
            v_sql := v_sql || ' ( ';
            v_sql := v_sql || ' COD_ESTAB     ASC, ';
            v_sql := v_sql || ' COD_PRODUTO   ASC, ';
            v_sql := v_sql || ' DATA_INV      ASC  ';
            v_sql := v_sql || ' ) ' || v_idx_prop;

            EXECUTE IMMEDIATE v_sql;

            v_sql := 'INSERT INTO ' || v_tab_aux;
            v_sql := v_sql || ' SELECT COD_ESTAB, COD_PRODUTO, DATA_INV FROM ' || vp_tab_perdas_inv;

            EXECUTE IMMEDIATE v_sql;

            loga ( '[TOTAL AUX][' || SQL%ROWCOUNT || ']'
                 , FALSE );
            COMMIT;

            --APAGAR LINHAS JA CARREGADAS NAs TABs DE ENTRADA ANTERIORES
            v_sql := 'DELETE ' || v_tab_aux || ' A ';
            v_sql := v_sql || ' WHERE EXISTS (SELECT ''Y'' ';
            v_sql := v_sql || '               FROM ' || vp_tab_perdas_ent_f || ' E ';
            v_sql := v_sql || '               WHERE E.COD_ESTAB_E   = A.COD_ESTAB ';
            v_sql := v_sql || '                 AND E.COD_PRODUTO_E = A.COD_PRODUTO ';
            v_sql := v_sql || '                 AND E.DATA_INV_S    = A.DATA_INV ) ';

            EXECUTE IMMEDIATE v_sql;

            loga ( '[LIMPEZA CO F][' || SQL%ROWCOUNT || ']'
                 , FALSE );
            COMMIT;

            v_sql := 'DELETE ' || v_tab_aux || ' A ';
            v_sql := v_sql || ' WHERE EXISTS (SELECT ''Y'' ';
            v_sql := v_sql || '               FROM ' || vp_tab_perdas_ent_c || ' E ';
            v_sql := v_sql || '               WHERE E.COD_PRODUTO_E = A.COD_PRODUTO ';
            v_sql := v_sql || '                 AND E.DATA_INV_S    = A.DATA_INV ) ';

            EXECUTE IMMEDIATE v_sql;

            loga ( '[LIMPEZA CO C][' || SQL%ROWCOUNT || ']'
                 , FALSE );
            COMMIT;

            dbms_stats.gather_table_stats ( 'MSAF'
                                          , v_tab_aux );

            --APENAS CONTINUA SE HOUVEREM LINHAS PARA QUERY
            EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || v_tab_aux            INTO v_qtde;

            IF ( v_qtde > 0 ) THEN --**
                v_limit := 0;
                v_partition_x08 := '';
                v_qtde := 0;

                FOR c_part IN c_partition ( vp_dt_final ) LOOP
                    v_estabs := ' ';

                    OPEN c_est FOR 'SELECT DISTINCT COD_ESTAB FROM ' || v_tab_aux;

                    LOOP
                        FETCH c_est
                            INTO v_cod_estab;

                        EXIT WHEN c_est%NOTFOUND;
                        v_estabs := v_estabs || '''' || v_cod_estab || ''',';
                    END LOOP;

                    v_estabs :=
                        SUBSTR ( v_estabs
                               , 1
                               , LENGTH ( v_estabs ) - 1 );

                    ---
                    IF ( c_part.x08_partition_name <> 'NAO_EXISTE' ) THEN
                        v_partition_x08 := ' PARTITION ( ' || c_part.x08_partition_name || ') ';
                    END IF;

                    v_limit := v_limit + 1;
                    t_start := dbms_utility.get_time;
                    dbms_application_info.set_module ( $$plsql_unit
                                                     , '8 COMPRA DIRETA [' || v_limit || ']' );

                    --LOAD X07 TEMP-INI--------------------------------------------------------
                    v_sql := 'DECLARE TYPE T_BULK_COLLECT_TAB07 IS TABLE OF ' || v_tab_x07 || '%ROWTYPE; ';
                    v_sql := v_sql || '        X07_TAB T_BULK_COLLECT_TAB07 := T_BULK_COLLECT_TAB07(); ';
                    v_sql := v_sql || 'BEGIN ';
                    ---
                    v_sql := v_sql || 'SELECT /*+RESULT_CACHE*/ ';
                    v_sql := v_sql || ' COD_EMPRESA        , ';
                    v_sql := v_sql || ' COD_ESTAB          , ';
                    v_sql := v_sql || ' DATA_FISCAL        , ';
                    v_sql := v_sql || ' MOVTO_E_S          , ';
                    v_sql := v_sql || ' NORM_DEV           , ';
                    v_sql := v_sql || ' IDENT_DOCTO        , ';
                    v_sql := v_sql || ' IDENT_FIS_JUR      , ';
                    v_sql := v_sql || ' NUM_DOCFIS         , ';
                    v_sql := v_sql || ' SERIE_DOCFIS       , ';
                    v_sql := v_sql || ' SUB_SERIE_DOCFIS   , ';
                    v_sql := v_sql || ' VLR_PRODUTO        , ';
                    v_sql := v_sql || ' DATA_EMISSAO       , ';
                    v_sql := v_sql || ' NUM_CONTROLE_DOCTO , ';
                    v_sql := v_sql || ' NUM_AUTENTIC_NFE     ';
                    v_sql := v_sql || 'BULK COLLECT INTO X07_TAB ';
                    v_sql := v_sql || 'FROM MSAF.X07_DOCTO_FISCAL PARTITION ( ' || c_part.x07_partition_name || ') ';
                    v_sql := v_sql || 'WHERE COD_EMPRESA = MSAFI.DPSP.EMPRESA ';
                    v_sql := v_sql || '  AND MOVTO_E_S <> ''9'' ';
                    v_sql := v_sql || '  AND SITUACAO   = ''N'' ';
                    v_sql :=
                           v_sql
                        || '  AND DATA_FISCAL BETWEEN TO_DATE('''
                        || TO_CHAR ( c_part.inicio_particao
                                   , 'DDMMYYYY' )
                        || ''',''DDMMYYYY'') AND TO_DATE('''
                        || TO_CHAR ( c_part.final_particao
                                   , 'DDMMYYYY' )
                        || ''',''DDMMYYYY'') ';
                    v_sql := v_sql || '  AND COD_ESTAB IN (' || v_estabs || '); ';
                    ---
                    v_sql := v_sql || 'FORALL I IN X07_TAB.FIRST .. X07_TAB.LAST ';
                    v_sql := v_sql || ' INSERT INTO ' || v_tab_x07 || ' VALUES X07_TAB(I); ';
                    v_sql := v_sql || 'COMMIT; ';
                    ---
                    v_sql := v_sql || 'END; ';

                    ---AUDIT DE RECURSOS LIGADO--INI
                    IF ( v_audit_pga = 'Y' ) THEN
                        msafi.get_pga_memory ( USERENV ( 'SESSIONID' )
                                             , v_pga_ini
                                             , v_uga_ini );
                        v_cpu_time_start := dbms_utility.get_cpu_time;
                    END IF;

                    ---AUDIT DE RECURSOS LIGADO--FIM

                    EXECUTE IMMEDIATE v_sql;

                    ---AUDIT DE RECURSOS LIGADO--INI
                    IF ( v_audit_pga = 'Y' ) THEN
                        v_cpu_time := dbms_utility.get_cpu_time - v_cpu_time_start;
                        msafi.get_pga_memory ( USERENV ( 'SESSIONID' )
                                             , v_pga_end
                                             , v_uga_end );

                        EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || v_tab_x07            INTO v_qtd_lines;

                        audit_resources ( v_mproc_id
                                        , 'X07_DOCTO_FISCAL'
                                        , v_i_x07_particao
                                        , v_i_ini_particao
                                        , v_i_fim_particao
                                        , v_pga_ini
                                        , v_pga_end
                                        , v_cpu_time
                                        , 0
                                        , v_qtd_lines
                                        , 'LOAD_ENTRADA CDIRETA '
                                        , v_limit
                                        , v_uga_ini
                                        , v_uga_end );
                    END IF;

                    ---AUDIT DE RECURSOS LIGADO--FIM

                    --LOAD X07 TEMP-FIM--------------------------------------------------------

                    --LOAD X08 TEMP-INI--------------------------------------------------------
                    t_start := dbms_utility.get_time;
                    v_sql := 'DECLARE TYPE T_BULK_COLLECT_TAB08 IS TABLE OF ' || v_tab_x08 || '%ROWTYPE; ';
                    v_sql := v_sql || '        X08_TAB T_BULK_COLLECT_TAB08 := T_BULK_COLLECT_TAB08(); ';
                    v_sql := v_sql || 'BEGIN ';
                    ---
                    v_sql := v_sql || 'SELECT /*+RESULT_CACHE*/ COD_EMPRESA,';
                    v_sql := v_sql || '       COD_ESTAB,';
                    v_sql := v_sql || '       DATA_FISCAL,';
                    v_sql := v_sql || '       MOVTO_E_S,    ';
                    v_sql := v_sql || '       NORM_DEV,       ';
                    v_sql := v_sql || '       IDENT_DOCTO,  ';
                    v_sql := v_sql || '       IDENT_FIS_JUR,  ';
                    v_sql := v_sql || '       NUM_DOCFIS, ';
                    v_sql := v_sql || '       SERIE_DOCFIS, ';
                    v_sql := v_sql || '       SUB_SERIE_DOCFIS, ';
                    v_sql := v_sql || '       DISCRI_ITEM, ';
                    v_sql := v_sql || '       NUM_ITEM, ';
                    v_sql := v_sql || '       IDENT_NBM,  ';
                    v_sql := v_sql || '       IDENT_CFO,  ';
                    v_sql := v_sql || '       IDENT_NATUREZA_OP,';
                    v_sql := v_sql || '       IDENT_PRODUTO, ';
                    v_sql := v_sql || '       VLR_CONTAB_ITEM, ';
                    v_sql := v_sql || '       QUANTIDADE,  ';
                    v_sql :=
                           v_sql
                        || '       DECODE(QUANTIDADE, 0, 0, TRUNC((VLR_ITEM-VLR_DESCONTO)/QUANTIDADE,4)) AS VLR_UNIT,';
                    v_sql := v_sql || '       IDENT_SITUACAO_B, ';
                    v_sql := v_sql || '       IDENT_SITUACAO_A,  ';
                    v_sql := v_sql || '       COD_SITUACAO_PIS, ';
                    v_sql := v_sql || '       COD_SITUACAO_COFINS,';
                    v_sql :=
                           v_sql
                        || '       DECODE(QUANTIDADE, 0, 0, TRUNC(TRUNC((VLR_ITEM-VLR_DESCONTO)/QUANTIDADE,4)*0.0165,4)) AS ESTORNO_PIS_E,';
                    v_sql :=
                           v_sql
                        || '       DECODE(QUANTIDADE, 0, 0, TRUNC(TRUNC((VLR_ITEM-VLR_DESCONTO)/QUANTIDADE,4)*0.076,4)) AS ESTORNO_COFINS_E,';
                    v_sql := v_sql || '       VLR_PIS, ';
                    v_sql := v_sql || '       VLR_COFINS';
                    v_sql := v_sql || ' BULK COLLECT INTO X08_TAB ';
                    v_sql := v_sql || ' FROM MSAF.X08_ITENS_MERC ' || v_partition_x08 || ' ';
                    v_sql := v_sql || ' WHERE COD_EMPRESA = MSAFI.DPSP.EMPRESA ';
                    v_sql := v_sql || ' AND MOVTO_E_S <> ''9'' ';
                    v_sql :=
                           v_sql
                        || ' AND DATA_FISCAL BETWEEN TO_DATE('''
                        || TO_CHAR ( c_part.inicio_particao
                                   , 'DDMMYYYY' )
                        || ''',''DDMMYYYY'') AND TO_DATE('''
                        || TO_CHAR ( c_part.final_particao
                                   , 'DDMMYYYY' )
                        || ''',''DDMMYYYY'') ';
                    v_sql := v_sql || ' AND COD_ESTAB IN (' || v_estabs || '); ';
                    ---
                    v_sql := v_sql || 'FORALL I IN X08_TAB.FIRST .. X08_TAB.LAST ';
                    v_sql := v_sql || ' INSERT INTO ' || v_tab_x08 || ' VALUES X08_TAB(I); ';
                    v_sql := v_sql || 'COMMIT; ';
                    ---
                    v_sql := v_sql || 'END; ';

                    ---AUDIT DE RECURSOS LIGADO--INI
                    IF ( v_audit_pga = 'Y' ) THEN
                        msafi.get_pga_memory ( USERENV ( 'SESSIONID' )
                                             , v_pga_ini
                                             , v_uga_ini );
                        v_cpu_time_start := dbms_utility.get_cpu_time;
                    END IF;

                    ---AUDIT DE RECURSOS LIGADO--FIM

                    EXECUTE IMMEDIATE v_sql;

                    ---AUDIT DE RECURSOS LIGADO--INI
                    IF ( v_audit_pga = 'Y' ) THEN
                        v_cpu_time := dbms_utility.get_cpu_time - v_cpu_time_start;
                        msafi.get_pga_memory ( USERENV ( 'SESSIONID' )
                                             , v_pga_end
                                             , v_uga_end );

                        EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || v_tab_x08            INTO v_qtd_lines;

                        audit_resources ( v_mproc_id
                                        , 'X08_ITENS_MERC'
                                        , v_i_x08_particao
                                        , v_i_ini_particao
                                        , v_i_fim_particao
                                        , v_pga_ini
                                        , v_pga_end
                                        , v_cpu_time
                                        , 0
                                        , v_qtd_lines
                                        , 'LOAD_ENTRADA CDIRETA'
                                        , v_limit
                                        , v_uga_ini
                                        , v_uga_end );
                    END IF;

                    ---AUDIT DE RECURSOS LIGADO--FIM

                    dbms_stats.gather_table_stats ( 'MSAF'
                                                  , v_tab_x07 );
                    dbms_stats.gather_table_stats ( 'MSAF'
                                                  , v_tab_x08 );
                    --LOAD X08 TEMP-FIM--------------------------------------------------------

                    v_sql := 'DECLARE TYPE T_BULK_COLLECT_TAB_E IS TABLE OF ' || vp_tabela_entrada || '%ROWTYPE; ';
                    v_sql := v_sql || '        TAB_E T_BULK_COLLECT_TAB_E := T_BULK_COLLECT_TAB_E(); ';
                    v_sql := v_sql || 'BEGIN ';
                    ---
                    v_sql := v_sql || 'SELECT DISTINCT ';
                    v_sql := v_sql || '    ' || vp_proc_instance || ' AS PROC_ID, ';
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
                    v_sql := v_sql || '    ''' || a_cod_empresa ( 'DEFAULT' ).business_unit || ''', '; ---BUSINESS_UNIT
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
                    v_sql := v_sql || ' BULK COLLECT INTO TAB_E ';
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
                    v_sql := v_sql || '        X08.VLR_UNIT, ';
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
                    v_sql := v_sql || '        X08.ESTORNO_PIS_E, ';
                    v_sql := v_sql || '        X08.ESTORNO_COFINS_E, ';
                    v_sql := v_sql || '        X08.VLR_PIS AS ESTORNO_PIS_S, ';
                    v_sql := v_sql || '        X08.VLR_COFINS AS ESTORNO_COFINS_S, ';
                    v_sql := v_sql || '        RANK() OVER( ';
                    v_sql := v_sql || '          PARTITION BY X08.COD_ESTAB, D.COD_PRODUTO ';
                    v_sql := v_sql || '              ORDER BY X08.DATA_FISCAL DESC, ';
                    v_sql := v_sql || '                       X07.DATA_EMISSAO DESC, ';
                    v_sql := v_sql || '                       X08.NUM_DOCFIS DESC, ';
                    v_sql := v_sql || '                       X08.DISCRI_ITEM DESC, ';
                    v_sql := v_sql || '                       X08.SERIE_DOCFIS) RANK ';
                    v_sql := v_sql || '    FROM ' || v_tab_x08 || ' X08, ';
                    v_sql := v_sql || '         ' || v_tab_x07 || ' X07, ';
                    v_sql := v_sql || '         X2013_PRODUTO D, ';
                    v_sql := v_sql || '         X04_PESSOA_FIS_JUR G, ';
                    v_sql := v_sql || '         ' || v_tab_aux || ' P, ';
                    v_sql := v_sql || '         X2043_COD_NBM A, ';
                    v_sql := v_sql || '         X2012_COD_FISCAL B, ';
                    v_sql := v_sql || '         X2006_NATUREZA_OP C, ';
                    v_sql := v_sql || '         Y2026_SIT_TRB_UF_B E, ';
                    v_sql := v_sql || '         ESTADO H,  ';
                    v_sql := v_sql || '         Y2025_SIT_TRB_UF_A I ';
                    ---
                    v_sql := v_sql || '    WHERE X07.COD_EMPRESA = MSAFI.DPSP.EMPRESA ';
                    ---
                    v_sql := v_sql || '      AND P.COD_ESTAB      = X07.COD_ESTAB ';
                    v_sql := v_sql || '      AND P.COD_PRODUTO    = D.COD_PRODUTO ';
                    v_sql := v_sql || '      AND P.DATA_INV       > X07.DATA_FISCAL ';
                    ---
                    v_sql := v_sql || '      AND X08.IDENT_NBM = A.IDENT_NBM ';
                    v_sql := v_sql || '      AND X08.IDENT_CFO = B.IDENT_CFO ';
                    v_sql :=
                        v_sql || '      AND B.COD_CFO     IN (''1102'',''2102'',''1403'',''2403'',''1910'',''2910'') ';
                    v_sql := v_sql || '      AND G.CPF_CGC NOT LIKE ''61412110%'' '; --FORNECEDOR DSP
                    v_sql := v_sql || '      AND G.CPF_CGC NOT LIKE ''334382500%'' '; --FORNECEDOR DP
                    v_sql := v_sql || '      AND X07.NUM_CONTROLE_DOCTO  NOT LIKE ''C%''  ';
                    v_sql := v_sql || '      AND X08.IDENT_NATUREZA_OP   = C.IDENT_NATUREZA_OP ';
                    v_sql := v_sql || '      AND X08.IDENT_SITUACAO_B    = E.IDENT_SITUACAO_B ';
                    v_sql := v_sql || '      AND X08.IDENT_SITUACAO_A    = I.IDENT_SITUACAO_A ';
                    v_sql := v_sql || '      AND X07.VLR_PRODUTO         > 0 ';
                    v_sql := v_sql || '      AND C.COD_NATUREZA_OP      <> ''ISE'' ';
                    v_sql := v_sql || '      AND X08.IDENT_PRODUTO       = D.IDENT_PRODUTO ';
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
                    v_sql := v_sql || 'WHERE A.RANK = 1;  ';
                    ---
                    v_sql := v_sql || 'FORALL I IN TAB_E.FIRST .. TAB_E.LAST ';
                    v_sql := v_sql || ' INSERT INTO ' || vp_tabela_entrada || ' VALUES TAB_E(I); ';
                    v_sql := v_sql || 'COMMIT; ';
                    ---
                    v_sql := v_sql || 'END; ';

                    ---AUDIT DE RECURSOS LIGADO--INI
                    IF ( v_audit_pga = 'Y' ) THEN
                        msafi.get_pga_memory ( USERENV ( 'SESSIONID' )
                                             , v_pga_ini
                                             , v_uga_ini );
                        v_cpu_time_start := dbms_utility.get_cpu_time;
                    END IF;

                    ---AUDIT DE RECURSOS LIGADO--FIM

                    BEGIN
                        EXECUTE IMMEDIATE v_sql;
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

                    ---AUDIT DE RECURSOS LIGADO--INI
                    IF ( v_audit_pga = 'Y' ) THEN
                        v_cpu_time := dbms_utility.get_cpu_time - v_cpu_time_start;
                        msafi.get_pga_memory ( USERENV ( 'SESSIONID' )
                                             , v_pga_end
                                             , v_uga_end );

                        EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || vp_tabela_entrada            INTO v_qtd_lines;

                        audit_resources ( v_mproc_id
                                        , 'QUERY ULT ENTRADA'
                                        , NULL
                                        , v_i_ini_particao
                                        , v_i_fim_particao
                                        , v_pga_ini
                                        , v_pga_end
                                        , v_cpu_time
                                        , 0
                                        , v_qtd_lines
                                        , 'LOAD_ENTRADA CDIRETA'
                                        , v_limit
                                        , v_uga_ini
                                        , v_uga_end );
                    END IF;

                    ---AUDIT DE RECURSOS LIGADO--FIM

                    --APAGAR LINHAS JA CARREGADAS NA TAB DE ENTRADA
                    v_sql := 'DELETE ' || v_tab_aux || ' A ';
                    v_sql := v_sql || ' WHERE EXISTS (SELECT ''Y'' ';
                    v_sql := v_sql || '               FROM ' || vp_tabela_entrada || ' E ';
                    v_sql := v_sql || '               WHERE E.COD_ESTAB_E   = A.COD_ESTAB ';
                    v_sql := v_sql || '                 AND E.COD_PRODUTO_E = A.COD_PRODUTO ';
                    v_sql := v_sql || '                 AND E.DATA_INV_S    = A.DATA_INV ) ';

                    EXECUTE IMMEDIATE v_sql;

                    ---LOGA('[AUX DEL][' || SQL%ROWCOUNT || ']',FALSE);
                    COMMIT;

                    BEGIN
                        EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || v_tab_aux            INTO v_qtde;
                    --LOGA('[ENTRADA CDIRETA][BUSCA ' || V_LIMIT || '][' || V_QTDE || '][' || V_PARTITION_X08 || '][' || C_PART.INICIO_PARTICAO || '][' || C_PART.FINAL_PARTICAO || ']',FALSE);
                    EXCEPTION
                        WHEN OTHERS THEN
                            v_qtde := 0;
                    END;

                    EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || v_tab_x08;

                    EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || v_tab_x07;

                    IF ( v_limit = 24
                     OR v_qtde = 0 ) THEN
                        --VOLTAR 2 ANOS
                        loga ( '[EXIT]'
                             , FALSE );
                        EXIT;
                    END IF;
                END LOOP;

                ---AUDIT DE RECURSOS LIGADO--INI
                IF ( v_audit_pga = 'Y' ) THEN
                    save_audit;
                END IF;
            ---AUDIT DE RECURSOS LIGADO--FIM

            END IF; --**
        ELSIF ( vp_origem = 'E' ) THEN --FILIAL DE OUTRA FILIAL MESMA UF
            --TAB AUXILIAR
            v_tab_aux := 'TM$_' || vp_proc_instance;
            v_sql := 'CREATE ' || v_tab_type || ' TABLE ' || v_tab_aux;
            v_sql := v_sql || ' ( ';
            v_sql := v_sql || ' COD_ESTAB VARCHAR2(6), ';
            v_sql := v_sql || ' COD_PRODUTO VARCHAR2(12), ';
            v_sql := v_sql || ' DATA_INV DATE, ';
            v_sql := v_sql || ' COD_ESTADO VARCHAR2(2) ';
            v_sql := v_sql || ' ) ' || v_tab_footer;

            EXECUTE IMMEDIATE v_sql;

            save_tmp_control ( vp_proc_instance
                             , v_tab_aux );

            v_sql := 'CREATE UNIQUE INDEX PKM_' || vp_proc_instance || ' ON ' || v_tab_aux;
            v_sql := v_sql || ' ( ';
            v_sql := v_sql || ' COD_ESTAB     ASC, ';
            v_sql := v_sql || ' COD_PRODUTO   ASC, ';
            v_sql := v_sql || ' DATA_INV      ASC  ';
            v_sql := v_sql || ' ) ' || v_idx_prop;

            EXECUTE IMMEDIATE v_sql;

            v_sql := 'CREATE INDEX IDX1M_' || vp_proc_instance || ' ON ' || v_tab_aux;
            v_sql := v_sql || ' ( ';
            v_sql := v_sql || ' COD_ESTAB     ASC ';
            v_sql := v_sql || ' ) ' || v_idx_prop;

            EXECUTE IMMEDIATE v_sql;

            v_sql := 'CREATE INDEX IDX2M_' || vp_proc_instance || ' ON ' || v_tab_aux;
            v_sql := v_sql || ' ( ';
            v_sql := v_sql || ' COD_ESTAB     ASC, ';
            v_sql := v_sql || ' COD_PRODUTO   ASC ';
            v_sql := v_sql || ' ) ' || v_idx_prop;

            EXECUTE IMMEDIATE v_sql;

            v_sql := 'INSERT INTO ' || v_tab_aux;
            v_sql := v_sql || ' SELECT A.COD_ESTAB, A.COD_PRODUTO, A.DATA_INV, EST.COD_ESTADO ';
            v_sql := v_sql || ' FROM ' || vp_tab_perdas_inv || ' A, ';
            v_sql := v_sql || '      MSAFI.DSP_ESTABELECIMENTO EST ';
            v_sql := v_sql || ' WHERE EST.COD_EMPRESA = MSAFI.DPSP.EMPRESA ';
            v_sql := v_sql || '   AND EST.COD_ESTAB   = A.COD_ESTAB ';

            EXECUTE IMMEDIATE v_sql;

            loga ( '[TOTAL AUX][' || SQL%ROWCOUNT || ']'
                 , FALSE );
            COMMIT;

            --APAGAR LINHAS JA CARREGADAS NAs TABs DE ENTRADA ANTERIORES
            v_sql := 'DELETE ' || v_tab_aux || ' A ';
            v_sql := v_sql || ' WHERE EXISTS (SELECT ''Y'' ';
            v_sql := v_sql || '               FROM ' || vp_tab_perdas_ent_f || ' E ';
            v_sql := v_sql || '               WHERE E.COD_ESTAB_E   = A.COD_ESTAB ';
            v_sql := v_sql || '                 AND E.COD_PRODUTO_E = A.COD_PRODUTO ';
            v_sql := v_sql || '                 AND E.DATA_INV_S    = A.DATA_INV ) ';

            EXECUTE IMMEDIATE v_sql;

            loga ( '[LIMPEZA MUF F][' || SQL%ROWCOUNT || ']'
                 , FALSE );
            COMMIT;

            v_sql := 'DELETE ' || v_tab_aux || ' A ';
            v_sql := v_sql || ' WHERE EXISTS (SELECT ''Y'' ';
            v_sql := v_sql || '               FROM ' || vp_tab_perdas_ent_c || ' E ';
            v_sql := v_sql || '               WHERE E.COD_PRODUTO_E = A.COD_PRODUTO ';
            v_sql := v_sql || '                 AND E.DATA_INV_S    = A.DATA_INV ) ';

            EXECUTE IMMEDIATE v_sql;

            loga ( '[LIMPEZA MUF C][' || SQL%ROWCOUNT || ']'
                 , FALSE );
            COMMIT;

            v_sql := 'DELETE ' || v_tab_aux || ' A ';
            v_sql := v_sql || ' WHERE EXISTS (SELECT ''Y'' ';
            v_sql := v_sql || '               FROM ' || vp_tab_perdas_ent_d || ' E ';
            v_sql := v_sql || '               WHERE E.COD_ESTAB_E   = A.COD_ESTAB ';
            v_sql := v_sql || '                 AND E.COD_PRODUTO_E = A.COD_PRODUTO ';
            v_sql := v_sql || '                 AND E.DATA_INV_S    = A.DATA_INV ) ';

            EXECUTE IMMEDIATE v_sql;

            loga ( '[LIMPEZA MUF CO][' || SQL%ROWCOUNT || ']'
                 , FALSE );
            COMMIT;

            dbms_stats.gather_table_stats ( 'MSAF'
                                          , v_tab_aux );

            --APENAS CONTINUA SE HOUVEREM LINHAS PARA QUERY
            EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || v_tab_aux            INTO v_qtde;

            IF ( v_qtde > 0 ) THEN --**
                v_limit := 0;
                v_partition_x08 := '';
                v_qtde := 0;

                FOR c_part IN c_partition ( vp_dt_final ) LOOP
                    v_estabs := ' ';

                    OPEN c_est FOR 'SELECT DISTINCT COD_ESTAB FROM ' || v_tab_aux;

                    LOOP
                        FETCH c_est
                            INTO v_cod_estab;

                        EXIT WHEN c_est%NOTFOUND;
                        v_estabs := v_estabs || '''' || v_cod_estab || ''',';
                    END LOOP;

                    v_estabs :=
                        SUBSTR ( v_estabs
                               , 1
                               , LENGTH ( v_estabs ) - 1 );

                    ---
                    IF ( c_part.x08_partition_name <> 'NAO_EXISTE' ) THEN
                        v_partition_x08 := ' PARTITION ( ' || c_part.x08_partition_name || ') ';
                    END IF;

                    v_limit := v_limit + 1;
                    dbms_application_info.set_module ( $$plsql_unit
                                                     , '9 ENTRADA FILIAL MESMA UF [' || v_limit || ']' );
                    t_start := dbms_utility.get_time;

                    --LOAD X07 TEMP-INI--------------------------------------------------------
                    v_sql := 'DECLARE TYPE T_BULK_COLLECT_TAB07 IS TABLE OF ' || v_tab_x07 || '%ROWTYPE; ';
                    v_sql := v_sql || '        X07_TAB T_BULK_COLLECT_TAB07 := T_BULK_COLLECT_TAB07(); ';
                    v_sql := v_sql || 'BEGIN ';
                    ---
                    v_sql := v_sql || 'SELECT /*+RESULT_CACHE*/ ';
                    v_sql := v_sql || ' COD_EMPRESA        , ';
                    v_sql := v_sql || ' COD_ESTAB          , ';
                    v_sql := v_sql || ' DATA_FISCAL        , ';
                    v_sql := v_sql || ' MOVTO_E_S          , ';
                    v_sql := v_sql || ' NORM_DEV           , ';
                    v_sql := v_sql || ' IDENT_DOCTO        , ';
                    v_sql := v_sql || ' IDENT_FIS_JUR      , ';
                    v_sql := v_sql || ' NUM_DOCFIS         , ';
                    v_sql := v_sql || ' SERIE_DOCFIS       , ';
                    v_sql := v_sql || ' SUB_SERIE_DOCFIS   , ';
                    v_sql := v_sql || ' VLR_PRODUTO        , ';
                    v_sql := v_sql || ' DATA_EMISSAO       , ';
                    v_sql := v_sql || ' NUM_CONTROLE_DOCTO , ';
                    v_sql := v_sql || ' NUM_AUTENTIC_NFE     ';
                    v_sql := v_sql || 'BULK COLLECT INTO X07_TAB ';
                    v_sql := v_sql || 'FROM MSAF.X07_DOCTO_FISCAL PARTITION ( ' || c_part.x07_partition_name || ') ';
                    v_sql := v_sql || 'WHERE COD_EMPRESA = MSAFI.DPSP.EMPRESA ';
                    v_sql := v_sql || '  AND MOVTO_E_S <> ''9'' ';
                    v_sql := v_sql || '  AND SITUACAO   = ''N'' ';
                    v_sql :=
                           v_sql
                        || '  AND DATA_FISCAL BETWEEN TO_DATE('''
                        || TO_CHAR ( c_part.inicio_particao
                                   , 'DDMMYYYY' )
                        || ''',''DDMMYYYY'') AND TO_DATE('''
                        || TO_CHAR ( c_part.final_particao
                                   , 'DDMMYYYY' )
                        || ''',''DDMMYYYY'') ';
                    v_sql := v_sql || '  AND COD_ESTAB IN (' || v_estabs || '); ';
                    ---
                    v_sql := v_sql || 'FORALL I IN X07_TAB.FIRST .. X07_TAB.LAST ';
                    v_sql := v_sql || ' INSERT INTO ' || v_tab_x07 || ' VALUES X07_TAB(I); ';
                    v_sql := v_sql || 'COMMIT; ';
                    ---
                    v_sql := v_sql || 'END; ';

                    ---AUDIT DE RECURSOS LIGADO--INI
                    IF ( v_audit_pga = 'Y' ) THEN
                        msafi.get_pga_memory ( USERENV ( 'SESSIONID' )
                                             , v_pga_ini
                                             , v_uga_ini );
                        v_cpu_time_start := dbms_utility.get_cpu_time;
                    END IF;

                    ---AUDIT DE RECURSOS LIGADO--FIM

                    EXECUTE IMMEDIATE v_sql;

                    ---AUDIT DE RECURSOS LIGADO--INI
                    IF ( v_audit_pga = 'Y' ) THEN
                        v_cpu_time := dbms_utility.get_cpu_time - v_cpu_time_start;
                        msafi.get_pga_memory ( USERENV ( 'SESSIONID' )
                                             , v_pga_end
                                             , v_uga_end );

                        EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || v_tab_x07            INTO v_qtd_lines;

                        audit_resources ( v_mproc_id
                                        , 'X07_DOCTO_FISCAL'
                                        , v_i_x07_particao
                                        , v_i_ini_particao
                                        , v_i_fim_particao
                                        , v_pga_ini
                                        , v_pga_end
                                        , v_cpu_time
                                        , 0
                                        , v_qtd_lines
                                        , 'LOAD_ENTRADA MUF'
                                        , v_limit
                                        , v_uga_ini
                                        , v_uga_end );
                    END IF;

                    ---AUDIT DE RECURSOS LIGADO--FIM

                    --LOAD X07 TEMP-FIM--------------------------------------------------------

                    --LOAD X08 TEMP-INI--------------------------------------------------------
                    t_start := dbms_utility.get_time;
                    v_sql := 'DECLARE TYPE T_BULK_COLLECT_TAB08 IS TABLE OF ' || v_tab_x08 || '%ROWTYPE; ';
                    v_sql := v_sql || '        X08_TAB T_BULK_COLLECT_TAB08 := T_BULK_COLLECT_TAB08(); ';
                    v_sql := v_sql || 'BEGIN ';
                    ---
                    v_sql := v_sql || 'SELECT /*+RESULT_CACHE*/ COD_EMPRESA,';
                    v_sql := v_sql || '       COD_ESTAB,';
                    v_sql := v_sql || '       DATA_FISCAL,';
                    v_sql := v_sql || '       MOVTO_E_S,    ';
                    v_sql := v_sql || '       NORM_DEV,       ';
                    v_sql := v_sql || '       IDENT_DOCTO,  ';
                    v_sql := v_sql || '       IDENT_FIS_JUR,  ';
                    v_sql := v_sql || '       NUM_DOCFIS, ';
                    v_sql := v_sql || '       SERIE_DOCFIS, ';
                    v_sql := v_sql || '       SUB_SERIE_DOCFIS, ';
                    v_sql := v_sql || '       DISCRI_ITEM, ';
                    v_sql := v_sql || '       NUM_ITEM, ';
                    v_sql := v_sql || '       IDENT_NBM,  ';
                    v_sql := v_sql || '       IDENT_CFO,  ';
                    v_sql := v_sql || '       IDENT_NATUREZA_OP,';
                    v_sql := v_sql || '       IDENT_PRODUTO, ';
                    v_sql := v_sql || '       VLR_CONTAB_ITEM, ';
                    v_sql := v_sql || '       QUANTIDADE,  ';
                    v_sql :=
                           v_sql
                        || '       DECODE(QUANTIDADE, 0, 0, TRUNC((VLR_ITEM-VLR_DESCONTO)/QUANTIDADE,4)) AS VLR_UNIT,';
                    v_sql := v_sql || '       IDENT_SITUACAO_B, ';
                    v_sql := v_sql || '       IDENT_SITUACAO_A,  ';
                    v_sql := v_sql || '       COD_SITUACAO_PIS, ';
                    v_sql := v_sql || '       COD_SITUACAO_COFINS,';
                    v_sql :=
                           v_sql
                        || '       DECODE(QUANTIDADE, 0, 0, TRUNC(TRUNC((VLR_ITEM-VLR_DESCONTO)/QUANTIDADE,4)*0.0165,4)) AS ESTORNO_PIS_E,';
                    v_sql :=
                           v_sql
                        || '       DECODE(QUANTIDADE, 0, 0, TRUNC(TRUNC((VLR_ITEM-VLR_DESCONTO)/QUANTIDADE,4)*0.076,4)) AS ESTORNO_COFINS_E,';
                    v_sql := v_sql || '       VLR_PIS, ';
                    v_sql := v_sql || '       VLR_COFINS';
                    v_sql := v_sql || ' BULK COLLECT INTO X08_TAB ';
                    v_sql := v_sql || ' FROM MSAF.X08_ITENS_MERC ' || v_partition_x08 || ' ';
                    v_sql := v_sql || ' WHERE COD_EMPRESA = MSAFI.DPSP.EMPRESA ';
                    v_sql := v_sql || ' AND MOVTO_E_S <> ''9'' ';
                    v_sql :=
                           v_sql
                        || ' AND DATA_FISCAL BETWEEN TO_DATE('''
                        || TO_CHAR ( c_part.inicio_particao
                                   , 'DDMMYYYY' )
                        || ''',''DDMMYYYY'') AND TO_DATE('''
                        || TO_CHAR ( c_part.final_particao
                                   , 'DDMMYYYY' )
                        || ''',''DDMMYYYY'') ';
                    v_sql := v_sql || ' AND COD_ESTAB IN (' || v_estabs || '); ';
                    ---
                    v_sql := v_sql || 'FORALL I IN X08_TAB.FIRST .. X08_TAB.LAST ';
                    v_sql := v_sql || ' INSERT INTO ' || v_tab_x08 || ' VALUES X08_TAB(I); ';
                    v_sql := v_sql || 'COMMIT; ';
                    ---
                    v_sql := v_sql || 'END; ';

                    ---AUDIT DE RECURSOS LIGADO--INI
                    IF ( v_audit_pga = 'Y' ) THEN
                        msafi.get_pga_memory ( USERENV ( 'SESSIONID' )
                                             , v_pga_ini
                                             , v_uga_ini );
                        v_cpu_time_start := dbms_utility.get_cpu_time;
                    END IF;

                    ---AUDIT DE RECURSOS LIGADO--FIM

                    EXECUTE IMMEDIATE v_sql;

                    ---AUDIT DE RECURSOS LIGADO--INI
                    IF ( v_audit_pga = 'Y' ) THEN
                        v_cpu_time := dbms_utility.get_cpu_time - v_cpu_time_start;
                        msafi.get_pga_memory ( USERENV ( 'SESSIONID' )
                                             , v_pga_end
                                             , v_uga_end );

                        EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || v_tab_x08            INTO v_qtd_lines;

                        audit_resources ( v_mproc_id
                                        , 'X08_ITENS_MERC'
                                        , v_i_x08_particao
                                        , v_i_ini_particao
                                        , v_i_fim_particao
                                        , v_pga_ini
                                        , v_pga_end
                                        , v_cpu_time
                                        , 0
                                        , v_qtd_lines
                                        , 'LOAD_ENTRADA MUF'
                                        , v_limit
                                        , v_uga_ini
                                        , v_uga_end );
                    END IF;

                    ---AUDIT DE RECURSOS LIGADO--FIM

                    dbms_stats.gather_table_stats ( 'MSAF'
                                                  , v_tab_x07 );
                    dbms_stats.gather_table_stats ( 'MSAF'
                                                  , v_tab_x08 );
                    --LOAD X08 TEMP-FIM--------------------------------------------------------

                    v_sql := 'DECLARE TYPE T_BULK_COLLECT_TAB_E IS TABLE OF ' || vp_tabela_entrada || '%ROWTYPE; ';
                    v_sql := v_sql || '        TAB_E T_BULK_COLLECT_TAB_E := T_BULK_COLLECT_TAB_E(); ';
                    v_sql := v_sql || 'BEGIN ';
                    ---
                    v_sql := v_sql || 'SELECT ';
                    v_sql := v_sql || ' ' || vp_proc_instance || ' AS PROC_ID , ';
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
                    v_sql := v_sql || '    ''' || a_cod_empresa ( 'DEFAULT' ).business_unit || ''' AS BUSINESS_UNIT, '; ---BUSINESS_UNIT
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
                    v_sql := v_sql || ' BULK COLLECT INTO TAB_E ';
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
                    v_sql := v_sql || '        X08.VLR_UNIT, ';
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
                    v_sql := v_sql || '        X08.ESTORNO_PIS_E, ';
                    v_sql := v_sql || '        X08.ESTORNO_COFINS_E, ';
                    v_sql := v_sql || '        X08.VLR_PIS AS ESTORNO_PIS_S, ';
                    v_sql := v_sql || '        X08.VLR_COFINS AS ESTORNO_COFINS_S, ';
                    v_sql := v_sql || '        RANK() OVER( ';
                    v_sql := v_sql || '          PARTITION BY X08.COD_ESTAB, D.COD_PRODUTO ';
                    v_sql := v_sql || '              ORDER BY X08.DATA_FISCAL DESC, ';
                    v_sql := v_sql || '                       X07.DATA_EMISSAO DESC, ';
                    v_sql := v_sql || '                       X08.NUM_DOCFIS DESC, ';
                    v_sql := v_sql || '                       X08.DISCRI_ITEM DESC, ';
                    v_sql := v_sql || '                       X08.SERIE_DOCFIS ) RANK ';
                    v_sql := v_sql || '    FROM ' || v_tab_x08 || ' X08, ';
                    v_sql := v_sql || '         ' || v_tab_x07 || ' X07, ';
                    v_sql := v_sql || '         X2013_PRODUTO D, ';
                    v_sql := v_sql || '         X04_PESSOA_FIS_JUR G, ';
                    v_sql := v_sql || '         ' || v_tab_aux || ' P, ';
                    v_sql := v_sql || '         X2043_COD_NBM A, ';
                    v_sql := v_sql || '         X2012_COD_FISCAL B, ';
                    v_sql := v_sql || '         X2006_NATUREZA_OP C, ';
                    v_sql := v_sql || '         Y2026_SIT_TRB_UF_B E, ';
                    v_sql := v_sql || '         ESTADO H, ';
                    v_sql := v_sql || '         Y2025_SIT_TRB_UF_A I ';
                    ---
                    v_sql := v_sql || '    WHERE X07.COD_EMPRESA = MSAFI.DPSP.EMPRESA ';
                    ---
                    v_sql := v_sql || '      AND P.COD_ESTAB     = X07.COD_ESTAB ';
                    v_sql := v_sql || '      AND P.COD_PRODUTO   = D.COD_PRODUTO ';
                    v_sql := v_sql || '      AND P.DATA_INV      > X07.DATA_FISCAL ';
                    v_sql := v_sql || '      AND P.COD_ESTADO    = H.COD_ESTADO ';
                    v_sql := v_sql || '      AND G.COD_FIS_JUR IN (SELECT LOJ.COD_ESTAB ';
                    v_sql := v_sql || '                            FROM MSAFI.DSP_ESTABELECIMENTO LOJ ';
                    v_sql := v_sql || '                            WHERE LOJ.COD_EMPRESA = MSAFI.DPSP.EMPRESA ';
                    v_sql := v_sql || '                              AND LOJ.TIPO = ''L'' ) ';
                    ---
                    v_sql := v_sql || '      AND X08.IDENT_NBM         = A.IDENT_NBM ';
                    v_sql := v_sql || '      AND X08.IDENT_CFO         = B.IDENT_CFO ';
                    v_sql := v_sql || '      AND B.COD_CFO             IN (''1152'',''2152'',''1409'',''2409'') ';
                    v_sql := v_sql || '      AND C.COD_NATUREZA_OP    <> ''ISE'' ';
                    v_sql := v_sql || '      AND X08.IDENT_NATUREZA_OP = C.IDENT_NATUREZA_OP ';
                    v_sql := v_sql || '      AND X08.IDENT_SITUACAO_B  = E.IDENT_SITUACAO_B ';
                    v_sql := v_sql || '      AND X08.IDENT_SITUACAO_A  = I.IDENT_SITUACAO_A ';
                    v_sql := v_sql || '      AND X07.VLR_PRODUTO       > 0 ';
                    v_sql := v_sql || '      AND X08.IDENT_PRODUTO     = D.IDENT_PRODUTO ';
                    v_sql := v_sql || '      AND X07.IDENT_FIS_JUR     = G.IDENT_FIS_JUR ';
                    v_sql := v_sql || '      AND G.IDENT_ESTADO        = H.IDENT_ESTADO ';
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
                    v_sql := v_sql || 'WHERE A.RANK = 1; ';
                    ---
                    v_sql := v_sql || 'FORALL I IN TAB_E.FIRST .. TAB_E.LAST ';
                    v_sql := v_sql || ' INSERT INTO ' || vp_tabela_entrada || ' VALUES TAB_E(I); ';
                    v_sql := v_sql || 'COMMIT; ';
                    ---
                    v_sql := v_sql || 'END; ';

                    ---AUDIT DE RECURSOS LIGADO--INI
                    IF ( v_audit_pga = 'Y' ) THEN
                        msafi.get_pga_memory ( USERENV ( 'SESSIONID' )
                                             , v_pga_ini
                                             , v_uga_ini );
                        v_cpu_time_start := dbms_utility.get_cpu_time;
                    END IF;

                    ---AUDIT DE RECURSOS LIGADO--FIM

                    EXECUTE IMMEDIATE v_sql;

                    ---AUDIT DE RECURSOS LIGADO--INI
                    IF ( v_audit_pga = 'Y' ) THEN
                        v_cpu_time := dbms_utility.get_cpu_time - v_cpu_time_start;
                        msafi.get_pga_memory ( USERENV ( 'SESSIONID' )
                                             , v_pga_end
                                             , v_uga_end );

                        EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || vp_tabela_entrada            INTO v_qtd_lines;

                        audit_resources ( v_mproc_id
                                        , 'QUERY ULT ENTRADA'
                                        , NULL
                                        , v_i_ini_particao
                                        , v_i_fim_particao
                                        , v_pga_ini
                                        , v_pga_end
                                        , v_cpu_time
                                        , 0
                                        , v_qtd_lines
                                        , 'LOAD_ENTRADA MUF'
                                        , v_limit
                                        , v_uga_ini
                                        , v_uga_end );
                    END IF;

                    ---AUDIT DE RECURSOS LIGADO--FIM

                    --APAGAR LINHAS JA CARREGADAS NA TAB DE ENTRADA
                    v_sql := 'DELETE ' || v_tab_aux || ' A ';
                    v_sql := v_sql || ' WHERE EXISTS (SELECT ''Y'' ';
                    v_sql := v_sql || '               FROM ' || vp_tabela_entrada || ' E ';
                    v_sql := v_sql || '               WHERE E.COD_ESTAB_E   = A.COD_ESTAB ';
                    v_sql := v_sql || '                 AND E.COD_PRODUTO_E = A.COD_PRODUTO ';
                    v_sql := v_sql || '                 AND E.DATA_INV_S    = A.DATA_INV ) ';

                    EXECUTE IMMEDIATE v_sql;

                    ---LOGA('[AUX DEL][' || SQL%ROWCOUNT || ']',FALSE);
                    COMMIT;

                    BEGIN
                        EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || v_tab_aux            INTO v_qtde;
                    ---LOGA('[' || VP_COD_ESTAB || '][BUSCA ' || I || '][' || V_QTDE || '][' || V_PARTITION_X08 || '][' || TAB_PART(I).INICIO_PARTICAO || '][' || TAB_PART(I).FINAL_PARTICAO || ']',FALSE);
                    EXCEPTION
                        WHEN OTHERS THEN
                            v_qtde := 0;
                    END;

                    EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || v_tab_x08;

                    EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || v_tab_x07;

                    IF ( v_limit = 24
                     OR v_qtde = 0 ) THEN
                        --VOLTAR 2 ANOS
                        loga ( '[EXIT]'
                             , FALSE );
                        EXIT;
                    END IF;
                END LOOP;

                ---AUDIT DE RECURSOS LIGADO--INI
                IF ( v_audit_pga = 'Y' ) THEN
                    save_audit;
                END IF;
            ---AUDIT DE RECURSOS LIGADO--FIM

            END IF; --**
        END IF;
    END; --PROCEDURE LOAD_ENTRADAS

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
                      , p_carga VARCHAR2
                      , p_uf VARCHAR2
                      , p_lojas lib_proc.vartab )
        RETURN INTEGER
    IS
        mproc_id INTEGER;
        i1 INTEGER;

        v_proc_status NUMBER := 0;
        v_s_proc_status VARCHAR2 ( 16 );

        v_txt_temp VARCHAR2 ( 1024 ) := '';

        TYPE a_estabs_t IS TABLE OF VARCHAR2 ( 6 );

        a_estabs a_estabs_t := a_estabs_t ( );
        a_estabs_full a_estabs_t := a_estabs_t ( );

        p_proc_instance VARCHAR2 ( 30 );
        --
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
        v_tab_x07 VARCHAR2 ( 30 );
        v_tab_x08 VARCHAR2 ( 30 );
        ---
        v_sql_resultado VARCHAR2 ( 2000 );
        v_qtde_inv NUMBER := 0;
        v_qtde_check NUMBER := 0;
        ---
        v_quant_empresas INTEGER := 50; --QUEBRA
        v_parametro VARCHAR2 ( 100 );
        v_data_hora_ini VARCHAR2 ( 20 );
        ---

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

        v_module VARCHAR2 ( 32 );
        t_idx NUMBER := 0;

        --VAR PARA DBLINKS------------
        --V_DSP_DBLINK VARCHAR2(20) := '@DBLINK_DBMSPHOM';
        --V_DP_DBLINK  VARCHAR2(20) := '@DBLINK_DBMRJHOM';
        v_dsp_dblink VARCHAR2 ( 20 ) := '@DBLINK_DBMSPPRD';
        v_dp_dblink VARCHAR2 ( 20 ) := '@DBLINK_DBMRJPRD';
    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS='',.'' ';

        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        musuario := lib_parametros.recuperar ( 'USUARIO' );

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

        --MARCAR INCIO DA EXECUCAO
        v_data_hora_ini :=
            TO_CHAR ( SYSDATE
                    , 'DD/MM/YYYY HH24:MI.SS' );
        v_module := $$plsql_unit || '_' || mproc_id;

        IF mcod_empresa IS NULL THEN
            lib_proc.add_log ( 'Código da empresa deve ser informado como parâmetro global.'
                             , 0 );
            lib_proc.add ( 'ERRO' );
            lib_proc.add ( 'CÓDIGO DA EMPRESA DEVE SER INFORMADO COMO PARÂMETRO GLOBAL.' );
            lib_proc.close;
            RETURN mproc_id;
        END IF;

        --CHECAR SE CDs SAO VALIDOS-INI-------------------------------------------
        FOR est IN ( SELECT p_cd1 AS cd
                          , 'CD1' AS fieldname
                       FROM DUAL
                    UNION ALL
                    SELECT p_cd2 AS cd
                         , 'CD2' AS fieldname
                      FROM DUAL
                    UNION ALL
                    SELECT p_cd3 AS cd
                         , 'CD3' AS fieldname
                      FROM DUAL
                    UNION ALL
                    SELECT p_cd4 AS cd
                         , 'CD4' AS fieldname
                      FROM DUAL ) LOOP
            IF ( est.cd IS NOT NULL ) THEN
                BEGIN
                    SELECT cgc
                      INTO a_cod_empresa ( est.cd ).cnpj
                      FROM msaf.estabelecimento
                     WHERE cod_empresa = msafi.dpsp.empresa
                       AND cod_estab = est.cd;

                    a_cod_empresa ( est.cd ).empresa := msafi.dpsp.empresa;
                    a_cod_empresa ( est.cd ).dblink := 'LOCAL';

                    SELECT bu_po1
                      INTO a_cod_empresa ( est.cd ).business_unit
                      FROM msafi.dsp_interface_setup
                     WHERE cod_empresa = msafi.dpsp.empresa;
                EXCEPTION
                    WHEN OTHERS THEN
                        BEGIN
                            IF ( msafi.dpsp.empresa = 'DSP' ) THEN
                                v_txt_temp :=
                                       'SELECT CGC FROM MSAF.ESTABELECIMENTO'
                                    || v_dp_dblink
                                    || ' WHERE COD_EMPRESA = ''DP'' AND COD_ESTAB = '''
                                    || est.cd
                                    || ''' ';
                                a_cod_empresa ( est.cd ).empresa := 'DP';
                                a_cod_empresa ( est.cd ).dblink := v_dp_dblink;

                                EXECUTE IMMEDIATE
                                       'SELECT BU_PO1 FROM MSAFI.DSP_INTERFACE_SETUP'
                                    || v_dp_dblink
                                    || ' WHERE COD_EMPRESA = ''DP'' '
                                               INTO a_cod_empresa ( est.cd ).business_unit;
                            ELSE
                                v_txt_temp :=
                                       'SELECT CGC FROM MSAF.ESTABELECIMENTO'
                                    || v_dsp_dblink
                                    || ' WHERE COD_EMPRESA = ''DSP'' AND COD_ESTAB = '''
                                    || est.cd
                                    || ''' ';
                                a_cod_empresa ( est.cd ).empresa := 'DSP';
                                a_cod_empresa ( est.cd ).dblink := v_dsp_dblink;

                                EXECUTE IMMEDIATE
                                       'SELECT BU_PO1 FROM MSAFI.DSP_INTERFACE_SETUP'
                                    || v_dsp_dblink
                                    || ' WHERE COD_EMPRESA = ''DSP'' '
                                               INTO a_cod_empresa ( est.cd ).business_unit;
                            END IF;

                            EXECUTE IMMEDIATE v_txt_temp            INTO a_cod_empresa ( est.cd ).cnpj;
                        EXCEPTION
                            WHEN OTHERS THEN
                                --LOGA(SQLERRM, FALSE);
                                lib_proc.add_log (
                                                      'Código inválido de estabelecimento informado em '
                                                   || est.fieldname
                                                   || '.['
                                                   || est.cd
                                                   || ']'
                                                 , 0
                                );
                                lib_proc.add ( 'ERRO' );
                                lib_proc.add (
                                                  'CÓDIGO INVÁLIDO DE ESTABELECIMENTO INFORMADO EM '
                                               || est.fieldname
                                               || '.['
                                               || est.cd
                                               || ']'
                                );
                                --LIB_PROC.ADD(V_TXT_TEMP);
                                lib_proc.close;
                                RETURN mproc_id;
                        END;
                END;
            END IF;
        END LOOP;

        SELECT bu_po1
          INTO a_cod_empresa ( 'DEFAULT' ).business_unit
          FROM msafi.dsp_interface_setup
         WHERE cod_empresa = msafi.dpsp.empresa;

        --CHECAR SE CDs SAO VALIDOS-FIM-------------------------------------------

        --GERAR CHAVE PROC_ID
        SELECT ROUND ( dbms_random.VALUE ( 10000000000000
                                         , 999999999999999 ) )
          INTO p_proc_instance
          FROM DUAL;

        ---------------------

        loga ( '[>>INICIO DO PROCESSAMENTO...:' || p_proc_instance || '<<]'
             , FALSE );
        loga ( '[DT INICIAL][' || v_data_inicial || '][DT FINAL][' || v_data_final || '][UF][' || p_uf || ']'
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
               '[PROC]['
            || mproc_id
            || ']-['
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
        loga ( v_parametro
             , FALSE );

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

        --CHECAR E CARREGAR INICIALMENTE TODOS OS DADOS DE INVENTARIO DO ERP--INI---------------------------------
        dbms_application_info.set_module ( v_module
                                         , '1 GET PS INV' );

        FOR i IN 1 .. a_estabs_full.COUNT LOOP
            get_psft_inv ( a_estabs_full ( i )
                         , v_data_inicial
                         , v_data_final
                         , p_inventario
                         , p_proc_instance
                         , v_qtde_inv );
        END LOOP;

        loga ( '[VERIFICACAO DE INVENTARIO][END]'
             , FALSE );
        --CHECAR E CARREGAR INICIALMENTE TODOS OS DADOS DE INVENTARIO DO ERP--FIM---------------------------------

        ----------------------------------------------------------------------------------
        --EXECUTAR FILIAIS POR QUEBRA-----------------------------------------------------
        i1 := 0;
        v_qtde_inv := 0;

        FOR est IN a_estabs_full.FIRST .. a_estabs_full.COUNT --(99)
                                                             LOOP
            --CHECK DADOS DE INVENTARIO PARA A FILIAL
            IF ( p_carga <> 'S' ) THEN
                BEGIN
                    SELECT COUNT ( * )
                      INTO v_qtde_inv
                      FROM msafi.dpsp_msaf_perdas_inv
                     WHERE cod_estab = a_estabs_full ( est )
                       AND cod_produto <> ' ' ---SEM MOVIMENTO
                       AND data_inv BETWEEN TO_DATE ( v_data_inicial
                                                    , 'DD/MM/YYYY' )
                                        AND TO_DATE ( v_data_final
                                                    , 'DD/MM/YYYY' );
                EXCEPTION
                    WHEN OTHERS THEN
                        v_qtde_inv := 0;
                END;
            END IF;

            IF ( v_qtde_inv > 0 ) THEN
                i1 := i1 + 1;
                a_estabs.EXTEND ( );
                a_estabs ( i1 ) := a_estabs_full ( est );
                loga ( '[' || a_estabs ( i1 ) || '][' || i1 || ']'
                     , FALSE );
            ELSIF ( p_carga <> 'S' ) THEN
                ---INSERE LINHA EM BRANCO NA TABELA FINAL
                delete_tbl ( a_estabs_full ( est )
                           , v_data_inicial
                           , v_data_final );

                INSERT INTO msafi.dpsp_msaf_perdas_uf ( cod_empresa
                                                      , cod_estab
                                                      , data_inv
                                                      , usuario
                                                      , dat_operacao )
                     VALUES ( mcod_empresa
                            , a_estabs_full ( est )
                            , TO_DATE ( v_data_final
                                      , 'DD/MM/YYYY' )
                            , musuario
                            , SYSDATE );

                COMMIT;
            END IF;

            IF ( ( a_estabs.COUNT > 0
              AND MOD ( a_estabs.COUNT
                      , v_quant_empresas ) = 0 )
             OR ( est = a_estabs_full.COUNT ) )
           AND p_carga <> 'S' --(88)
                             THEN
                i1 := 0;
                ----------------------------------------------------------------------------------
                ----------------------------------------------------------------------------------

                --CRIAR TABELA TEMP DO INVENTARIO
                v_tab_perdas_inv :=
                    create_perdas_inv_tmp ( p_proc_instance
                                          , v_tab_global_flag
                                          , v_tab_type
                                          , v_tab_footer );

                dbms_application_info.set_module ( v_module
                                                 , '2 LOAD INV DADOS' );

                FOR i IN 1 .. a_estabs.COUNT LOOP
                    load_inv_dados ( p_proc_instance
                                   , a_estabs ( i )
                                   , v_data_inicial
                                   , v_data_final
                                   , v_tab_perdas_inv );
                END LOOP;

                IF ( v_tab_global_flag = 'N' ) THEN
                    --CRIAR INDICES DA TEMP DO INVENTARIO
                    create_perdas_inv_tmp_idx ( p_proc_instance
                                              , v_tab_perdas_inv );
                END IF;

                EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || v_tab_perdas_inv            INTO v_qtde_check;

                IF ( v_qtde_check > 0 ) THEN --(999)
                    v_qtde_check := 0;

                    --CRIAR E CARREGAR TABELAS TEMP DE ALIQ E PMC DO PEOPLESOFT
                    dbms_application_info.set_module ( v_module
                                                     , '3 LOAD ALIQ PMC' );
                    load_aliq_pmc ( p_proc_instance
                                  , v_nome_tabela_aliq
                                  , v_nome_tabela_pmc
                                  , v_tab_perdas_inv
                                  , v_tab_global_flag
                                  , v_tab_type
                                  , v_tab_footer );

                    --CRIAR TABELA TMP DE ENTRADA
                    create_tab_entrada ( p_proc_instance
                                       , v_tab_perdas_ent_c
                                       , v_tab_perdas_ent_f
                                       , v_tab_perdas_ent_d
                                       , v_tab_perdas_ent_m
                                       , v_tab_global_flag
                                       , v_tab_type
                                       , v_tab_footer );
                    create_tab_ent_x ( p_proc_instance
                                     , v_tab_x07
                                     , v_tab_x08
                                     , v_tab_global_flag
                                     , v_tab_type
                                     , v_tab_footer );

                    --CARREGAR DADOS DE ENTRADA-----------------------------------------------------------
                    IF ( p_cd1 IS NOT NULL ) THEN
                        IF ( p_origem1 = 'L' ) THEN
                            ---ENTRADA NA FILIAL ORIGEM CD
                            dbms_application_info.set_module ( v_module
                                                             , '4 ENTRADA FILIAIS CD ' || p_cd1 );
                            load_entradas ( p_proc_instance
                                          , ''
                                          , v_data_inicial
                                          , v_data_final
                                          , 'F'
                                          , v_tab_perdas_ent_f
                                          , v_tab_perdas_inv
                                          , p_cd1
                                          , v_tab_perdas_ent_f
                                          , ''
                                          , v_tab_perdas_ent_c
                                          , v_tab_x07
                                          , v_tab_x08
                                          , v_tab_type
                                          , v_tab_footer
                                          , mproc_id );
                        ELSIF ( p_origem1 = 'C' ) THEN
                            ---ENTRADA NO CD
                            dbms_application_info.set_module ( v_module
                                                             , '4 ENTRADA CD ' || p_cd1 );
                            load_entradas ( p_proc_instance
                                          , p_cd1
                                          , v_data_inicial
                                          , v_data_final
                                          , 'C'
                                          , v_tab_perdas_ent_c
                                          , v_tab_perdas_inv
                                          , p_cd1
                                          , v_tab_perdas_ent_f
                                          , ''
                                          , v_tab_perdas_ent_c
                                          , v_tab_x07
                                          , v_tab_x08
                                          , v_tab_type
                                          , v_tab_footer
                                          , mproc_id );
                        END IF;

                        loga ( '[ENTRADA CD / FILIAL 1][END]'
                             , FALSE );
                    END IF;

                    ---
                    IF ( ( p_cd2 IS NOT NULL
                      AND p_origem1 <> p_origem2
                      AND p_cd1 = p_cd2 )
                     OR ( p_cd2 IS NOT NULL
                     AND p_cd1 <> p_cd2 ) ) THEN
                        IF ( p_origem2 = 'L' ) THEN
                            ---ENTRADA NA FILIAL ORIGEM CD
                            dbms_application_info.set_module ( v_module
                                                             , '5 ENTRADA FILIAIS CD ' || p_cd2 );
                            load_entradas ( p_proc_instance
                                          , ''
                                          , v_data_inicial
                                          , v_data_final
                                          , 'F'
                                          , v_tab_perdas_ent_f
                                          , v_tab_perdas_inv
                                          , p_cd2
                                          , v_tab_perdas_ent_f
                                          , ''
                                          , v_tab_perdas_ent_c
                                          , v_tab_x07
                                          , v_tab_x08
                                          , v_tab_type
                                          , v_tab_footer
                                          , mproc_id );
                        ELSIF ( p_origem2 = 'C' ) THEN
                            ---ENTRADA NO CD
                            dbms_application_info.set_module ( v_module
                                                             , '5 ENTRADA CD ' || p_cd2 );
                            load_entradas ( p_proc_instance
                                          , p_cd2
                                          , v_data_inicial
                                          , v_data_final
                                          , 'C'
                                          , v_tab_perdas_ent_c
                                          , v_tab_perdas_inv
                                          , p_cd2
                                          , v_tab_perdas_ent_f
                                          , ''
                                          , v_tab_perdas_ent_c
                                          , v_tab_x07
                                          , v_tab_x08
                                          , v_tab_type
                                          , v_tab_footer
                                          , mproc_id );
                        END IF;

                        loga ( '[ENTRADA CD / FILIAL 2][END]'
                             , FALSE );
                    END IF;

                    ---
                    IF ( ( p_cd3 IS NOT NULL
                      AND p_cd3 <> p_cd2
                      AND p_cd3 <> p_cd1 )
                     OR ( p_cd3 IS NOT NULL
                     AND p_cd3 = p_cd2
                     AND p_origem3 <> p_origem2
                     AND p_cd3 <> p_cd1 )
                     OR ( p_cd3 IS NOT NULL
                     AND p_cd3 = p_cd1
                     AND p_origem3 <> p_origem1
                     AND p_cd3 <> p_cd2 ) ) THEN
                        IF ( p_origem3 = 'L' ) THEN
                            ---ENTRADA NA FILIAL ORIGEM CD
                            dbms_application_info.set_module ( v_module
                                                             , '6 ENTRADA FILIAIS CD ' || p_cd3 );
                            load_entradas ( p_proc_instance
                                          , ''
                                          , v_data_inicial
                                          , v_data_final
                                          , 'F'
                                          , v_tab_perdas_ent_f
                                          , v_tab_perdas_inv
                                          , p_cd3
                                          , v_tab_perdas_ent_f
                                          , ''
                                          , v_tab_perdas_ent_c
                                          , v_tab_x07
                                          , v_tab_x08
                                          , v_tab_type
                                          , v_tab_footer
                                          , mproc_id );
                        ELSIF ( p_origem3 = 'C' ) THEN
                            ---ENTRADA NO CD
                            dbms_application_info.set_module ( v_module
                                                             , '6 ENTRADA CD ' || p_cd3 );
                            load_entradas ( p_proc_instance
                                          , p_cd3
                                          , v_data_inicial
                                          , v_data_final
                                          , 'C'
                                          , v_tab_perdas_ent_c
                                          , v_tab_perdas_inv
                                          , p_cd3
                                          , v_tab_perdas_ent_f
                                          , ''
                                          , v_tab_perdas_ent_c
                                          , v_tab_x07
                                          , v_tab_x08
                                          , v_tab_type
                                          , v_tab_footer
                                          , mproc_id );
                        END IF;

                        loga ( '[ENTRADA CD / FILIAL 3][END]'
                             , FALSE );
                    END IF;

                    ---
                    IF ( ( p_cd4 IS NOT NULL
                      AND p_cd4 <> p_cd3
                      AND p_cd4 <> p_cd2
                      AND p_cd4 <> p_cd1 )
                     OR ( p_cd4 IS NOT NULL
                     AND p_cd4 = p_cd3
                     AND p_origem4 <> p_origem3
                     AND p_cd4 <> p_cd2
                     AND p_cd4 <> p_cd1 )
                     OR ( p_cd4 IS NOT NULL
                     AND p_cd4 = p_cd2
                     AND p_origem4 <> p_origem2
                     AND p_cd4 <> p_cd3
                     AND p_cd4 <> p_cd1 )
                     OR ( p_cd4 IS NOT NULL
                     AND p_cd4 = p_cd1
                     AND p_origem4 <> p_origem1
                     AND p_cd4 <> p_cd3
                     AND p_cd4 <> p_cd2 ) ) THEN
                        IF ( p_origem4 = 'L' ) THEN
                            ---ENTRADA NA FILIAL ORIGEM CD
                            dbms_application_info.set_module ( v_module
                                                             , '7 ENTRADA FILIAIS CD ' || p_cd4 );
                            load_entradas ( p_proc_instance
                                          , ''
                                          , v_data_inicial
                                          , v_data_final
                                          , 'F'
                                          , v_tab_perdas_ent_f
                                          , v_tab_perdas_inv
                                          , p_cd4
                                          , v_tab_perdas_ent_f
                                          , ''
                                          , v_tab_perdas_ent_c
                                          , v_tab_x07
                                          , v_tab_x08
                                          , v_tab_type
                                          , v_tab_footer
                                          , mproc_id );
                        ELSIF ( p_origem4 = 'C' ) THEN
                            ---ENTRADA NO CD
                            dbms_application_info.set_module ( v_module
                                                             , '7 ENTRADA CD ' || p_cd4 );
                            load_entradas ( p_proc_instance
                                          , p_cd4
                                          , v_data_inicial
                                          , v_data_final
                                          , 'C'
                                          , v_tab_perdas_ent_c
                                          , v_tab_perdas_inv
                                          , p_cd4
                                          , v_tab_perdas_ent_f
                                          , ''
                                          , v_tab_perdas_ent_c
                                          , v_tab_x07
                                          , v_tab_x08
                                          , v_tab_type
                                          , v_tab_footer
                                          , mproc_id );
                        END IF;

                        loga ( '[ENTRADA CD / FILIAL 4][END]'
                             , FALSE );
                    END IF;

                    --CRIAR INDICES DA TEMP DE ENTRADA
                    IF ( v_tab_global_flag = 'N' ) THEN
                        create_tab_entrada_cd_idx ( p_proc_instance
                                                  , v_tab_perdas_ent_c
                                                  , v_tab_global_flag );
                        create_tab_ent_filial_idx ( p_proc_instance
                                                  , v_tab_perdas_ent_f
                                                  , v_tab_global_flag );
                    END IF;

                    --CARREGAR DADOS ENTRADA COMPRA DIRETA
                    IF ( p_compra_direta = 'S' ) THEN
                        EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || v_tab_perdas_inv            INTO v_qtde_check;

                        IF ( v_qtde_check > 0 ) THEN
                            --CARREGAR TEMPORARIAS ENTRADA NAS FILIAIS COMPRA DIRETA
                            dbms_application_info.set_module ( v_module
                                                             , '8 COMPRA DIRETA' );
                            load_entradas ( p_proc_instance
                                          , ''
                                          , v_data_inicial
                                          , v_data_final
                                          , 'CO'
                                          , v_tab_perdas_ent_d
                                          , v_tab_perdas_inv
                                          , ''
                                          , v_tab_perdas_ent_f
                                          , ''
                                          , v_tab_perdas_ent_c
                                          , v_tab_x07
                                          , v_tab_x08
                                          , v_tab_type
                                          , v_tab_footer
                                          , mproc_id );
                        END IF;

                        IF ( v_tab_global_flag = 'N' ) THEN
                            create_tab_ent_cdireta_idx ( p_proc_instance
                                                       , v_tab_perdas_ent_d
                                                       , v_tab_global_flag );
                        END IF;

                        loga ( '[ENTRADA CDIRETA][END]'
                             , FALSE );
                    END IF;

                    --CARREGAR DADOS ENTRADA FILIAL MESMA UF
                    IF ( p_filiais = 'S' ) THEN
                        EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || v_tab_perdas_inv            INTO v_qtde_check;

                        IF ( v_qtde_check > 0 ) THEN
                            --CARREGAR TEMPORARIAS ENTRADA NAS FILIAIS MESMA UF
                            dbms_application_info.set_module ( v_module
                                                             , '9 ENTRADA FILIAL MESMA UF' );
                            load_entradas ( p_proc_instance
                                          , ''
                                          , v_data_inicial
                                          , v_data_final
                                          , 'E'
                                          , v_tab_perdas_ent_m
                                          , v_tab_perdas_inv
                                          , ''
                                          , v_tab_perdas_ent_f
                                          , v_tab_perdas_ent_d
                                          , v_tab_perdas_ent_c
                                          , v_tab_x07
                                          , v_tab_x08
                                          , v_tab_type
                                          , v_tab_footer
                                          , mproc_id );
                        END IF;

                        IF ( v_tab_global_flag = 'N' ) THEN
                            create_tab_ent_mesma_uf_idx ( p_proc_instance
                                                        , v_tab_perdas_ent_m
                                                        , v_tab_global_flag );
                        END IF;

                        loga ( '[ENTRADA MESMA FILIAL][END]'
                             , FALSE );
                    END IF;

                    -------------------------------------------------------------------------------------

                    --XREF ENTRADAS COM PMC E ALIQ
                    dbms_application_info.set_module ( v_module
                                                     , '10 MERGE PMC ALIQ' );
                    merge_pmc_aliq ( p_proc_instance
                                   , v_tab_perdas_ent_c
                                   , v_tab_perdas_ent_f
                                   , v_tab_perdas_ent_d
                                   , v_tab_perdas_ent_m
                                   , v_nome_tabela_aliq
                                   , v_nome_tabela_pmc );

                    --OBTER LISTA DO PRODUTO
                    dbms_application_info.set_module ( v_module
                                                     , '11 UPD LISTA' );
                    msafi.atualiza_lista;
                    loga ( '[LISTA ATUALIZADA]'
                         , FALSE );
                    ---MERGE_LISTA(V_TAB_PERDAS_ENT_C, V_TAB_PERDAS_ENT_F, V_TAB_PERDAS_ENT_D, V_TAB_PERDAS_ENT_M);

                    --XML-----------------------
                    dbms_application_info.set_module ( v_module
                                                     , '12 MERGE XML' );
                    merge_xml ( p_proc_instance
                              , v_tab_perdas_ent_c
                              , v_tab_perdas_ent_f
                              , v_tab_perdas_ent_d
                              , v_tab_perdas_ent_m
                              , p_filiais
                              , p_origem1
                              , p_origem2
                              , p_origem3
                              , p_origem4
                              , v_tab_global_flag
                              , v_tab_type
                              , v_tab_footer );

                    --ANTECIPACAO---------------
                    dbms_application_info.set_module ( v_module
                                                     , '13 GET ANTECIPACAO' );
                    get_antecipacao ( p_proc_instance
                                    , v_tab_perdas_ent_c
                                    , v_tab_perdas_ent_f
                                    , v_tab_perdas_ent_d
                                    , v_tab_perdas_ent_m
                                    , v_tab_global_flag
                                    , v_tab_type
                                    , v_tab_footer );

                    --CRIAR TABELA TEMPORARIA COM O RESULTADO
                    create_perdas_tmp_tbl ( p_proc_instance
                                          , v_tab_perdas_tmp
                                          , v_tab_global_flag
                                          , v_tab_type
                                          , v_tab_footer );

                    --LOOP PARA CADA FILIAL-INI--------------------------------------------------------------------------------------
                    dbms_application_info.set_module ( v_module
                                                     , '14 XREF INV COM ENTRADAS' );

                    FOR i IN 1 .. a_estabs.COUNT LOOP
                        --ASSOCIAR SAIDAS COM SUAS ULTIMAS ENTRADAS
                        IF ( p_cd1 IS NOT NULL ) THEN
                            IF ( p_origem1 = 'L' ) THEN
                                --ENTRADA NAS FILIAIS
                                get_entradas_filial ( p_proc_instance
                                                    , a_estabs ( i )
                                                    , p_cd1
                                                    , v_data_inicial
                                                    , v_data_final
                                                    , v_tab_perdas_ent_f
                                                    , v_tab_perdas_inv
                                                    , v_tab_perdas_tmp );
                            ELSIF ( p_origem1 = 'C' ) THEN
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
                            IF ( p_origem2 = 'L' ) THEN
                                --ENTRADA NAS FILIAIS
                                get_entradas_filial ( p_proc_instance
                                                    , a_estabs ( i )
                                                    , p_cd2
                                                    , v_data_inicial
                                                    , v_data_final
                                                    , v_tab_perdas_ent_f
                                                    , v_tab_perdas_inv
                                                    , v_tab_perdas_tmp );
                            ELSIF ( p_origem2 = 'C' ) THEN
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
                            IF ( p_origem3 = 'L' ) THEN
                                --ENTRADA NAS FILIAIS
                                get_entradas_filial ( p_proc_instance
                                                    , a_estabs ( i )
                                                    , p_cd3
                                                    , v_data_inicial
                                                    , v_data_final
                                                    , v_tab_perdas_ent_f
                                                    , v_tab_perdas_inv
                                                    , v_tab_perdas_tmp );
                            ELSIF ( p_origem3 = 'C' ) THEN
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
                            IF ( p_origem4 = 'L' ) THEN
                                --ENTRADA NAS FILIAIS
                                get_entradas_filial ( p_proc_instance
                                                    , a_estabs ( i )
                                                    , p_cd4
                                                    , v_data_inicial
                                                    , v_data_final
                                                    , v_tab_perdas_ent_f
                                                    , v_tab_perdas_inv
                                                    , v_tab_perdas_tmp );
                            ELSIF ( p_origem4 = 'C' ) THEN
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
                    dbms_application_info.set_module ( v_module
                                                     , '15 MERGE ANTECIPACAO' );
                    merge_antecipacao ( v_tab_perdas_tmp );

                    --LIMPAR DADOS DA TABELA FINAL - SOBREPOR
                    dbms_application_info.set_module ( v_module
                                                     , '16 DELETE TBL FINAL' );

                    FOR i IN 1 .. a_estabs.COUNT LOOP
                        delete_tbl ( a_estabs ( i )
                                   , v_data_inicial
                                   , v_data_final );
                    END LOOP;

                    --INSERIR DADOS-INI-------------------------------------------------------------------------------------------
                    loga ( '[RESULTADO][INI]' );

                    ---INSERIR RESULTADO
                    dbms_application_info.set_module ( v_module
                                                     , '17 INSERT FINAL' );
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
                --INSERIR DADOS-FIM-------------------------------------------------------------------------------------------

                END IF; --(999) EXECUTAR PROCESSO APENAS SE EXISTIREM DADOS DE PERDAS

                ----------------------------------------------------------------------------------
                --EXECUTAR FILIAIS POR QUEBRA-FIM-------------------------------------------------
                loga ( '[RESULTADO PARCIAL][FIM]' );
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
END dpsp_perdas_uf_cproc;
/
SHOW ERRORS;
