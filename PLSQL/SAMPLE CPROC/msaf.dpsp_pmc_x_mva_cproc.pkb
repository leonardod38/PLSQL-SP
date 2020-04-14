Prompt Package Body DPSP_PMC_X_MVA_CPROC;
--
-- DPSP_PMC_X_MVA_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_pmc_x_mva_cproc
IS
    mproc_id INTEGER;
    v_qtde_default INTEGER := 50; --QTDE DEFAULT
    v_module VARCHAR2 ( 32 );
    v_p_log VARCHAR2 ( 1 );

    --VAR PARA TABLES----------
    v_tab_footer VARCHAR2 ( 100 )
        := ' STORAGE (BUFFER_POOL KEEP) PCTFREE 0 NOLOGGING NOCOMPRESS CACHE TABLESPACE MSAF_WORK_TABLES ';
    v_idx_footer VARCHAR2 ( 100 ) := ' NOLOGGING NOCOMPRESS TABLESPACE MSAF_WORK_INDEXES ';

    v_tab_global_flag VARCHAR2 ( 1 ) := 'N'; --Y SE FOR GERAR TABS GLOBAL TEMP
    v_tab_type VARCHAR2 ( 30 ) := ' ';

    --AUDITORIA DE RECURSOS DO BD NA ENTRADA----------------------
    v_audit_pga VARCHAR2 ( 1 ) := 'N'; --Y GRAVAR DADOS DE UTILIZACAO DA PGA NA ULTIMA ENTRADA

    TYPE t_tab_audit IS TABLE OF msafi.dpsp_audit_resource%ROWTYPE;

    tab_audit t_tab_audit := t_tab_audit ( );

    ---
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

    v_sel_data_fim VARCHAR2 ( 260 )
        := 'SELECT TRUNC( TO_DATE( :1 ,''DD/MM/YYYY'') + ROWNUM - 1) AS DATA_FIM, TRUNC( TO_DATE( :1 ,''DD/MM/YYYY'') + ROWNUM - 1) AS DATA_FIM FROM DUAL CONNECT BY ROWNUM <= LAST_DAY( TO_DATE( :1 ,''DD/MM/YYYY'') ) - TO_DATE( :1 ,''DD/MM/YYYY'') + 1 ORDER BY 1 DESC ';
    v_sel_uf VARCHAR2 ( 115 )
        := 'SELECT DISTINCT COD_ESTADO, COD_ESTADO FROM MSAFI.DPSP_PMC_UF_VW WHERE DATA_VIG_INI <= :1 AND DATA_VIG_FIM >= :2';
    v_sel_perfil VARCHAR2 ( 135 )
        := 'SELECT DISTINCT ID_PARAMETROS, PERFIL FROM MSAFI.DPSP_PMC_PERFIL_VW WHERE DATA_VIG_INI <= :1 AND DATA_VIG_FIM >= :2 AND COD_ESTADO = :3';

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
                            'VARCHAR2'
                           , 'COMBOBOX'
                           , 'S'
                           , NULL
                           , '##########'
                           , v_sel_data_fim );

        lib_proc.add_param ( pstr
                           , 'UF'
                           , --P_UF
                            'VARCHAR2'
                           , 'COMBOBOX'
                           , 'S'
                           , NULL
                           , '##########'
                           , v_sel_uf );

        lib_proc.add_param ( pstr
                           , 'Perfil de Parâmetros'
                           , --P_PERFIL
                            'VARCHAR2'
                           , 'COMBOBOX'
                           , 'S'
                           , NULL
                           , NULL
                           , v_sel_perfil );

        lib_proc.add_param ( pstr
                           , 'Gravar LOG de Erros'
                           , --P_LOG
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
                           ,    'SELECT A.COD_ESTAB, A.COD_ESTAB || '' - '' || B.COD_ESTADO || '' - '' || A.CGC || '' - '' || INITCAP(A.BAIRRO) || '' / '' || INITCAP(A.CIDADE) FROM ESTABELECIMENTO A, ESTADO B, MSAFI.DSP_ESTABELECIMENTO C WHERE A.COD_EMPRESA  = '''
                             || mcod_empresa
                             || ''' AND B.IDENT_ESTADO = A.IDENT_ESTADO AND A.COD_EMPRESA = C.COD_EMPRESA AND A.COD_ESTAB = C.COD_ESTAB AND B.COD_ESTADO = :3 AND C.TIPO = ''L'' ORDER BY B.COD_ESTADO, A.COD_ESTAB'
        );

        RETURN pstr;
    END; --FUNCTION PARAMETROS RETURN VARCHAR2 IS

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Processar Dados PMC x MVA';
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
        RETURN 'Processar Carga de Dados para Ressarcimento PMC x MVA';
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
                    loga ( '<<TAB OLD NAO ENCONTRADA>> ' || l_table_name
                         , FALSE );
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

    PROCEDURE create_tab_pmc_mva ( vp_proc_instance IN VARCHAR2
                                 , vp_tabela_pmc_mva   OUT VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 2000 );
    BEGIN
        vp_tabela_pmc_mva := 'DP$P_PMC_R_' || vp_proc_instance;

        v_sql := 'CREATE TABLE ' || vp_tabela_pmc_mva || ' ( ';
        v_sql := v_sql || 'PROC_ID             NUMBER(30), ';
        v_sql := v_sql || 'COD_EMPRESA         VARCHAR2(3), ';
        v_sql := v_sql || 'COD_ESTAB           VARCHAR2(6), ';
        v_sql := v_sql || 'NUM_DOCFIS          VARCHAR2(12), ';
        v_sql := v_sql || 'DATA_FISCAL         DATE, ';
        v_sql := v_sql || 'SERIE_DOCFIS        VARCHAR2(3), ';
        v_sql := v_sql || 'COD_PRODUTO         VARCHAR2(35), ';
        v_sql := v_sql || 'COD_ESTADO          VARCHAR2(2), ';
        v_sql := v_sql || 'DOCTO               VARCHAR2(5), ';
        v_sql := v_sql || 'NUM_ITEM            NUMBER(5), ';
        v_sql := v_sql || 'DESCR_ITEM          VARCHAR2(50), ';
        v_sql := v_sql || 'QUANTIDADE          NUMBER(12,4), ';
        v_sql := v_sql || 'COD_NBM             VARCHAR2(10), ';
        v_sql := v_sql || 'COD_CFO             VARCHAR2(4), ';
        v_sql := v_sql || 'GRUPO_PRODUTO       VARCHAR2(30), ';
        v_sql := v_sql || 'VLR_DESCONTO        NUMBER(17,2), ';
        v_sql := v_sql || 'VLR_CONTABIL        NUMBER(17,2), ';
        v_sql := v_sql || 'BASE_UNIT_S_VENDA   NUMBER(17,2), ';
        v_sql := v_sql || 'NUM_AUTENTIC_NFE    VARCHAR2(80), ';
        v_sql := v_sql || 'LISTA               VARCHAR2(1), ';
        ---
        v_sql := v_sql || 'COD_ESTAB_E           VARCHAR2(6), ';
        v_sql := v_sql || 'DATA_FISCAL_E         DATE, ';
        v_sql := v_sql || 'MOVTO_E_S_E           VARCHAR2(1), ';
        v_sql := v_sql || 'NORM_DEV_E            VARCHAR2(1), ';
        v_sql := v_sql || 'IDENT_DOCTO_E         VARCHAR2(12), ';
        v_sql := v_sql || 'IDENT_FIS_JUR_E       VARCHAR2(12), ';
        v_sql := v_sql || 'SUB_SERIE_DOCFIS_E    VARCHAR2(2), ';
        v_sql := v_sql || 'DISCRI_ITEM_E         VARCHAR2(46), ';
        v_sql := v_sql || 'DATA_EMISSAO_E        DATE, ';
        v_sql := v_sql || 'NUM_DOCFIS_E          VARCHAR2(12), ';
        v_sql := v_sql || 'SERIE_DOCFIS_E        VARCHAR2(3), ';
        v_sql := v_sql || 'NUM_ITEM_E            NUMBER(5), ';
        v_sql := v_sql || 'COD_FIS_JUR_E         VARCHAR2(14), ';
        v_sql := v_sql || 'CPF_CGC_E             VARCHAR2(14), ';
        v_sql := v_sql || 'COD_NBM_E             VARCHAR2(10), ';
        v_sql := v_sql || 'COD_CFO_E             VARCHAR2(4), ';
        v_sql := v_sql || 'COD_NATUREZA_OP_E     VARCHAR2(3), ';
        v_sql := v_sql || 'COD_PRODUTO_E         VARCHAR2(35), ';
        v_sql := v_sql || 'VLR_CONTAB_ITEM_E     NUMBER(17,2), ';
        v_sql := v_sql || 'QUANTIDADE_E          NUMBER(12,4), ';
        v_sql := v_sql || 'VLR_UNIT_E            NUMBER(17,2), ';
        v_sql := v_sql || 'COD_SITUACAO_B_E      VARCHAR2(2), ';
        v_sql := v_sql || 'COD_ESTADO_E          VARCHAR2(2), ';
        v_sql := v_sql || 'NUM_CONTROLE_DOCTO_E  VARCHAR2(12), ';
        v_sql := v_sql || 'NUM_AUTENTIC_NFE_E    VARCHAR2(80), ';
        v_sql := v_sql || 'BASE_ICMS_UNIT_E      NUMBER(17,2), ';
        v_sql := v_sql || 'VLR_ICMS_UNIT_E       NUMBER(17,2), ';
        v_sql := v_sql || 'ALIQ_ICMS_E           NUMBER(17,2), ';
        v_sql := v_sql || 'BASE_ST_UNIT_E        NUMBER(17,2), ';
        v_sql := v_sql || 'VLR_ICMS_ST_UNIT_E    NUMBER(17,2), ';
        v_sql := v_sql || 'VLR_ICMS_ST_UNIT_AUX  NUMBER(17,2), ';
        v_sql := v_sql || 'STAT_LIBER_CNTR       VARCHAR2(10)) ';
        v_sql := v_sql || v_tab_footer;

        EXECUTE IMMEDIATE v_sql;

        save_tmp_control ( vp_proc_instance
                         , vp_tabela_pmc_mva );

        v_sql := 'CREATE UNIQUE INDEX PK_PMC_R_' || vp_proc_instance || ' ON ' || vp_tabela_pmc_mva || ' ';
        v_sql := v_sql || '  (';
        v_sql := v_sql || '    PROC_ID        ASC,';
        v_sql := v_sql || '    COD_EMPRESA    ASC,';
        v_sql := v_sql || '    COD_ESTAB      ASC,';
        v_sql := v_sql || '    NUM_DOCFIS     ASC,';
        v_sql := v_sql || '    DATA_FISCAL    ASC,';
        v_sql := v_sql || '    SERIE_DOCFIS   ASC,';
        v_sql := v_sql || '    COD_PRODUTO    ASC,';
        v_sql := v_sql || '    COD_ESTADO     ASC,';
        v_sql := v_sql || '    DOCTO          ASC,';
        v_sql := v_sql || '    NUM_ITEM       ASC';
        v_sql := v_sql || '  ) ';
        v_sql := v_sql || v_idx_footer;

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX1_PMC_R_' || vp_proc_instance || ' ON ' || vp_tabela_pmc_mva || ' ';
        v_sql := v_sql || '  (';
        v_sql := v_sql || '    PROC_ID   ,';
        v_sql := v_sql || '    COD_ESTAB  ';
        v_sql := v_sql || '  ) ';
        v_sql := v_sql || v_idx_footer;

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX2_PMC_R_' || vp_proc_instance || ' ON ' || vp_tabela_pmc_mva || ' ';
        v_sql := v_sql || '  (';
        v_sql := v_sql || '    COD_PRODUTO   ,';
        v_sql := v_sql || '    DATA_FISCAL  ';
        v_sql := v_sql || '  ) ';
        v_sql := v_sql || v_idx_footer;

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX3_PMC_R_' || vp_proc_instance || ' ON ' || vp_tabela_pmc_mva || ' ';
        v_sql := v_sql || '  (';
        v_sql := v_sql || '    PROC_ID,';
        v_sql := v_sql || '    COD_ESTAB,  ';
        v_sql := v_sql || '    COD_PRODUTO ';
        v_sql := v_sql || '  ) ';
        v_sql := v_sql || v_idx_footer;

        EXECUTE IMMEDIATE v_sql;
    END;

    PROCEDURE create_tab_saida ( vp_proc_instance IN VARCHAR2
                               , vp_tabela_saida   OUT VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 4000 );
    BEGIN
        vp_tabela_saida := 'DP$P_PMC_SAIDA_' || vp_proc_instance;

        v_sql := 'CREATE TABLE ' || vp_tabela_saida || ' ( ';
        v_sql := v_sql || 'PROC_ID             NUMBER(30), ';
        v_sql := v_sql || 'COD_EMPRESA         VARCHAR2(3), ';
        v_sql := v_sql || 'COD_ESTAB           VARCHAR2(6), ';
        v_sql := v_sql || 'NUM_DOCFIS          VARCHAR2(12), ';
        v_sql := v_sql || 'DATA_FISCAL         DATE, ';
        v_sql := v_sql || 'SERIE_DOCFIS        VARCHAR2(3), ';
        v_sql := v_sql || 'COD_PRODUTO         VARCHAR2(35), ';
        v_sql := v_sql || 'COD_ESTADO          VARCHAR2(2), ';
        v_sql := v_sql || 'DOCTO               VARCHAR2(5), ';
        v_sql := v_sql || 'NUM_ITEM            NUMBER(5), ';
        v_sql := v_sql || 'DESCR_ITEM          VARCHAR2(50), ';
        v_sql := v_sql || 'QUANTIDADE          NUMBER(12,4), ';
        v_sql := v_sql || 'COD_NBM             VARCHAR2(10), ';
        v_sql := v_sql || 'COD_CFO             VARCHAR2(4), ';
        v_sql := v_sql || 'GRUPO_PRODUTO       VARCHAR2(30), ';
        v_sql := v_sql || 'VLR_DESCONTO        NUMBER(17,2), ';
        v_sql := v_sql || 'VLR_CONTABIL        NUMBER(17,2), ';
        v_sql := v_sql || 'BASE_UNIT_S_VENDA   NUMBER(17,2), ';
        v_sql := v_sql || 'NUM_AUTENTIC_NFE    VARCHAR2(80), ';
        v_sql := v_sql || 'LISTA		       VARCHAR2(1)) ';
        v_sql := v_sql || v_tab_footer;

        EXECUTE IMMEDIATE v_sql;

        ---
        save_tmp_control ( vp_proc_instance
                         , vp_tabela_saida );
        ---
        v_sql := 'CREATE UNIQUE INDEX PK_PMC_$_' || vp_proc_instance || ' ON ' || vp_tabela_saida || ' ';
        v_sql := v_sql || '( ';
        v_sql := v_sql || '  PROC_ID     , ';
        v_sql := v_sql || '  COD_EMPRESA , ';
        v_sql := v_sql || '  COD_ESTAB   , ';
        v_sql := v_sql || '  NUM_DOCFIS  , ';
        v_sql := v_sql || '  DATA_FISCAL , ';
        v_sql := v_sql || '  SERIE_DOCFIS, ';
        v_sql := v_sql || '  COD_PRODUTO , ';
        v_sql := v_sql || '  COD_ESTADO  , ';
        v_sql := v_sql || '  DOCTO       , ';
        v_sql := v_sql || '  NUM_ITEM     ';
        v_sql := v_sql || ') ';
        v_sql := v_sql || v_idx_footer;

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX1_PMC_$_' || vp_proc_instance || ' ON ' || vp_tabela_saida || ' ';
        v_sql := v_sql || '( ';
        v_sql := v_sql || '  PROC_ID  , ';
        v_sql := v_sql || '  COD_ESTAB ';
        v_sql := v_sql || ') ';
        v_sql := v_sql || v_idx_footer;

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX2_PMC_$_' || vp_proc_instance || ' ON ' || vp_tabela_saida || ' ';
        v_sql := v_sql || '( ';
        v_sql := v_sql || '  PROC_ID, ';
        v_sql := v_sql || '  COD_EMPRESA, ';
        v_sql := v_sql || '  DATA_FISCAL, ';
        v_sql := v_sql || '  COD_PRODUTO ';
        v_sql := v_sql || ') ';
        v_sql := v_sql || v_idx_footer;

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX3_PMC_$_' || vp_proc_instance || ' ON ' || vp_tabela_saida || ' ';
        v_sql := v_sql || '( ';
        v_sql := v_sql || '  PROC_ID  , ';
        v_sql := v_sql || '  COD_EMPRESA, ';
        v_sql := v_sql || '  COD_ESTAB ';
        v_sql := v_sql || ') ';
        v_sql := v_sql || v_idx_footer;

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX4_PMC_$_' || vp_proc_instance || ' ON ' || vp_tabela_saida || ' ';
        v_sql := v_sql || '( ';
        v_sql := v_sql || '  PROC_ID  , ';
        v_sql := v_sql || '  COD_EMPRESA, ';
        v_sql := v_sql || '  COD_ESTAB, ';
        v_sql := v_sql || '  COD_PRODUTO, ';
        v_sql := v_sql || '  DATA_FISCAL ';
        v_sql := v_sql || ') ';
        v_sql := v_sql || v_idx_footer;

        EXECUTE IMMEDIATE v_sql;
    END;

    PROCEDURE create_tab_entrada_cd ( vp_proc_instance IN NUMBER
                                    , vp_tab_entrada_c   OUT VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 2000 );
    BEGIN
        ---CRIAR TEMP DE ENTRADA EM CD
        vp_tab_entrada_c := 'DP$P_PMC_E_C_' || vp_proc_instance;

        v_sql := 'CREATE TABLE ' || vp_tab_entrada_c || ' ( ';
        v_sql := v_sql || ' PROC_ID             NUMBER(30), ';
        v_sql := v_sql || ' COD_EMPRESA         VARCHAR2(3), ';
        v_sql := v_sql || ' COD_ESTAB           VARCHAR2(6), ';
        v_sql := v_sql || ' DATA_FISCAL         DATE, ';
        v_sql := v_sql || ' MOVTO_E_S           VARCHAR2(1), ';
        v_sql := v_sql || ' NORM_DEV            VARCHAR2(1), ';
        v_sql := v_sql || ' IDENT_DOCTO         VARCHAR2(12), ';
        v_sql := v_sql || ' IDENT_FIS_JUR       VARCHAR2(12), ';
        v_sql := v_sql || ' NUM_DOCFIS          VARCHAR2(12), ';
        v_sql := v_sql || ' SERIE_DOCFIS        VARCHAR2(3), ';
        v_sql := v_sql || ' SUB_SERIE_DOCFIS    VARCHAR2(2), ';
        v_sql := v_sql || ' DISCRI_ITEM         VARCHAR2(46), ';
        v_sql := v_sql || ' DATA_FISCAL_S       DATE, ';
        ---
        v_sql := v_sql || ' NUM_ITEM            NUMBER(5), ';
        v_sql := v_sql || ' COD_FIS_JUR         VARCHAR2(14), ';
        v_sql := v_sql || ' CPF_CGC             VARCHAR2(14), ';
        v_sql := v_sql || ' COD_NBM             VARCHAR2(10), ';
        v_sql := v_sql || ' COD_CFO             VARCHAR2(4), ';
        v_sql := v_sql || ' COD_NATUREZA_OP     VARCHAR2(3), ';
        v_sql := v_sql || ' COD_PRODUTO         VARCHAR2(35), ';
        v_sql := v_sql || ' VLR_CONTAB_ITEM     NUMBER(17,2), ';
        v_sql := v_sql || ' QUANTIDADE          NUMBER(12,4), ';
        v_sql := v_sql || ' VLR_UNIT            NUMBER(17,2), ';
        v_sql := v_sql || ' COD_SITUACAO_B      VARCHAR2(2), ';
        v_sql := v_sql || ' DATA_EMISSAO        DATE, ';
        v_sql := v_sql || ' COD_ESTADO          VARCHAR2(2), ';
        v_sql := v_sql || ' NUM_CONTROLE_DOCTO  VARCHAR2(12), ';
        v_sql := v_sql || ' NUM_AUTENTIC_NFE    VARCHAR2(80), ';
        v_sql := v_sql || ' BUSINESS_UNIT       VARCHAR2(8) ) ';
        v_sql := v_sql || v_tab_footer;

        EXECUTE IMMEDIATE v_sql;

        save_tmp_control ( vp_proc_instance
                         , vp_tab_entrada_c );

        v_sql := 'CREATE UNIQUE INDEX PK_PMC_E_C_' || vp_proc_instance || ' ON ' || vp_tab_entrada_c || ' ';
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || '    PROC_ID         , ';
        v_sql := v_sql || '    COD_EMPRESA     , ';
        v_sql := v_sql || '    COD_ESTAB       , ';
        v_sql := v_sql || '    DATA_FISCAL     , ';
        v_sql := v_sql || '    MOVTO_E_S       , ';
        v_sql := v_sql || '    NORM_DEV        , ';
        v_sql := v_sql || '    IDENT_DOCTO     , ';
        v_sql := v_sql || '    IDENT_FIS_JUR   , ';
        v_sql := v_sql || '    NUM_DOCFIS      , ';
        v_sql := v_sql || '    SERIE_DOCFIS    , ';
        v_sql := v_sql || '    SUB_SERIE_DOCFIS, ';
        v_sql := v_sql || '    DISCRI_ITEM     , ';
        v_sql := v_sql || '    DATA_FISCAL_S    ';
        v_sql := v_sql || '  ) ';
        v_sql := v_sql || v_idx_footer;

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX1_PMC_E_C_' || vp_proc_instance || ' ON ' || vp_tab_entrada_c || ' ';
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || '    PROC_ID           , ';
        v_sql := v_sql || '    COD_EMPRESA       , ';
        v_sql := v_sql || '    COD_ESTAB         , ';
        v_sql := v_sql || '    COD_PRODUTO       , ';
        v_sql := v_sql || '    DATA_FISCAL_S       ';
        v_sql := v_sql || '  ) ';
        v_sql := v_sql || v_idx_footer;

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX2_PMC_E_C_' || vp_proc_instance || ' ON ' || vp_tab_entrada_c || ' ';
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || '    PROC_ID           , ';
        v_sql := v_sql || '    BUSINESS_UNIT     , ';
        v_sql := v_sql || '    NUM_CONTROLE_DOCTO, ';
        v_sql := v_sql || '    NUM_ITEM ';
        v_sql := v_sql || '  ) ';
        v_sql := v_sql || v_idx_footer;

        EXECUTE IMMEDIATE v_sql;
    END;

    PROCEDURE create_tab_entrada_f ( vp_proc_instance IN NUMBER
                                   , vp_tab_entrada_f   OUT VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 2000 );
    BEGIN
        ---CRIAR TEMP DE ENTRADA EM FILIAIS
        vp_tab_entrada_f := 'DP$P_PMC_E_F_' || vp_proc_instance;

        v_sql := 'CREATE TABLE ' || vp_tab_entrada_f || ' ( ';
        v_sql := v_sql || ' PROC_ID             NUMBER(30), ';
        v_sql := v_sql || ' COD_EMPRESA         VARCHAR2(3), ';
        v_sql := v_sql || ' COD_ESTAB           VARCHAR2(6), ';
        v_sql := v_sql || ' DATA_FISCAL         DATE, ';
        v_sql := v_sql || ' MOVTO_E_S           VARCHAR2(1), ';
        v_sql := v_sql || ' NORM_DEV            VARCHAR2(1), ';
        v_sql := v_sql || ' IDENT_DOCTO         VARCHAR2(12), ';
        v_sql := v_sql || ' IDENT_FIS_JUR       VARCHAR2(12), ';
        v_sql := v_sql || ' NUM_DOCFIS          VARCHAR2(12), ';
        v_sql := v_sql || ' SERIE_DOCFIS        VARCHAR2(3), ';
        v_sql := v_sql || ' SUB_SERIE_DOCFIS    VARCHAR2(2), ';
        v_sql := v_sql || ' DISCRI_ITEM         VARCHAR2(46), ';
        v_sql := v_sql || ' DATA_FISCAL_S       DATE, ';
        ---
        v_sql := v_sql || ' NUM_ITEM            NUMBER(5), ';
        v_sql := v_sql || ' COD_FIS_JUR         VARCHAR2(14), ';
        v_sql := v_sql || ' CPF_CGC             VARCHAR2(14), ';
        v_sql := v_sql || ' COD_NBM             VARCHAR2(10), ';
        v_sql := v_sql || ' COD_CFO             VARCHAR2(4), ';
        v_sql := v_sql || ' COD_NATUREZA_OP     VARCHAR2(3), ';
        v_sql := v_sql || ' COD_PRODUTO         VARCHAR2(35), ';
        v_sql := v_sql || ' VLR_CONTAB_ITEM     NUMBER(17,2), ';
        v_sql := v_sql || ' QUANTIDADE          NUMBER(12,4), ';
        v_sql := v_sql || ' VLR_UNIT            NUMBER(17,2), ';
        v_sql := v_sql || ' COD_SITUACAO_B      VARCHAR2(2), ';
        v_sql := v_sql || ' DATA_EMISSAO        DATE, ';
        v_sql := v_sql || ' COD_ESTADO          VARCHAR2(2), ';
        v_sql := v_sql || ' NUM_CONTROLE_DOCTO  VARCHAR2(12), ';
        v_sql := v_sql || ' NUM_AUTENTIC_NFE    VARCHAR2(80), ';
        v_sql := v_sql || ' BUSINESS_UNIT       VARCHAR2(8) ) ';
        v_sql := v_sql || v_tab_footer;

        EXECUTE IMMEDIATE v_sql;

        save_tmp_control ( vp_proc_instance
                         , vp_tab_entrada_f );

        v_sql := 'CREATE UNIQUE INDEX PK_PMC_E_F_' || vp_proc_instance || ' ON ' || vp_tab_entrada_f || ' ';
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || '    PROC_ID             ASC, ';
        v_sql := v_sql || '    COD_EMPRESA         ASC, ';
        v_sql := v_sql || '    COD_ESTAB           ASC, ';
        v_sql := v_sql || '    DATA_FISCAL         ASC, ';
        v_sql := v_sql || '    MOVTO_E_S           ASC, ';
        v_sql := v_sql || '    NORM_DEV            ASC, ';
        v_sql := v_sql || '    IDENT_DOCTO         ASC, ';
        v_sql := v_sql || '    IDENT_FIS_JUR       ASC, ';
        v_sql := v_sql || '    NUM_DOCFIS          ASC, ';
        v_sql := v_sql || '    SERIE_DOCFIS        ASC, ';
        v_sql := v_sql || '    SUB_SERIE_DOCFIS    ASC, ';
        v_sql := v_sql || '    DISCRI_ITEM         ASC, ';
        v_sql := v_sql || '    DATA_FISCAL_S       ASC ';
        v_sql := v_sql || '  ) ';
        v_sql := v_sql || v_idx_footer;

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX1_PMC_E_F_' || vp_proc_instance || ' ON ' || vp_tab_entrada_f || ' ';
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || '    PROC_ID       , ';
        v_sql := v_sql || '    COD_EMPRESA   , ';
        v_sql := v_sql || '    COD_ESTAB     , ';
        v_sql := v_sql || '    COD_PRODUTO   , ';
        v_sql := v_sql || '    DATA_FISCAL_S , ';
        v_sql := v_sql || '    CPF_CGC ';
        v_sql := v_sql || '  ) ';
        v_sql := v_sql || v_idx_footer;

        EXECUTE IMMEDIATE v_sql;
    END;

    PROCEDURE create_tab_entrada_co ( vp_proc_instance IN NUMBER
                                    , vp_tab_entrada_co   OUT VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 2000 );
    BEGIN
        ---CRIAR TEMP DE ENTRADA COMPRA DIRETA
        vp_tab_entrada_co := 'DP$P_PMC_E_CO_' || vp_proc_instance;

        v_sql := 'CREATE TABLE ' || vp_tab_entrada_co || ' ( ';
        v_sql := v_sql || ' PROC_ID             NUMBER(30), ';
        v_sql := v_sql || ' COD_EMPRESA         VARCHAR2(3), ';
        v_sql := v_sql || ' COD_ESTAB           VARCHAR2(6), ';
        v_sql := v_sql || ' DATA_FISCAL         DATE, ';
        v_sql := v_sql || ' MOVTO_E_S           VARCHAR2(1), ';
        v_sql := v_sql || ' NORM_DEV            VARCHAR2(1), ';
        v_sql := v_sql || ' IDENT_DOCTO         VARCHAR2(12), ';
        v_sql := v_sql || ' IDENT_FIS_JUR       VARCHAR2(12), ';
        v_sql := v_sql || ' NUM_DOCFIS          VARCHAR2(12), ';
        v_sql := v_sql || ' SERIE_DOCFIS        VARCHAR2(3), ';
        v_sql := v_sql || ' SUB_SERIE_DOCFIS    VARCHAR2(2), ';
        v_sql := v_sql || ' DISCRI_ITEM         VARCHAR2(46), ';
        v_sql := v_sql || ' DATA_FISCAL_S       DATE, ';
        ---
        v_sql := v_sql || ' NUM_ITEM            NUMBER(5), ';
        v_sql := v_sql || ' COD_FIS_JUR         VARCHAR2(14), ';
        v_sql := v_sql || ' CPF_CGC             VARCHAR2(14), ';
        v_sql := v_sql || ' COD_NBM             VARCHAR2(10), ';
        v_sql := v_sql || ' COD_CFO             VARCHAR2(4), ';
        v_sql := v_sql || ' COD_NATUREZA_OP     VARCHAR2(3), ';
        v_sql := v_sql || ' COD_PRODUTO         VARCHAR2(35), ';
        v_sql := v_sql || ' VLR_CONTAB_ITEM     NUMBER(17,2), ';
        v_sql := v_sql || ' QUANTIDADE          NUMBER(12,4), ';
        v_sql := v_sql || ' VLR_UNIT            NUMBER(17,2), ';
        v_sql := v_sql || ' COD_SITUACAO_B      VARCHAR2(2), ';
        v_sql := v_sql || ' DATA_EMISSAO        DATE, ';
        v_sql := v_sql || ' COD_ESTADO          VARCHAR2(2), ';
        v_sql := v_sql || ' NUM_CONTROLE_DOCTO  VARCHAR2(12), ';
        v_sql := v_sql || ' NUM_AUTENTIC_NFE    VARCHAR2(80), ';
        v_sql := v_sql || ' BUSINESS_UNIT       VARCHAR2(8) ) ';
        v_sql := v_sql || v_tab_footer;

        EXECUTE IMMEDIATE v_sql;

        save_tmp_control ( vp_proc_instance
                         , vp_tab_entrada_co );

        v_sql := 'CREATE UNIQUE INDEX PK_PMC_E_CO_' || vp_proc_instance || ' ON ' || vp_tab_entrada_co || ' ';
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || '    PROC_ID          ASC, ';
        v_sql := v_sql || '    COD_EMPRESA      ASC, ';
        v_sql := v_sql || '    COD_ESTAB        ASC, ';
        v_sql := v_sql || '    DATA_FISCAL      ASC, ';
        v_sql := v_sql || '    MOVTO_E_S        ASC, ';
        v_sql := v_sql || '    NORM_DEV         ASC, ';
        v_sql := v_sql || '    IDENT_DOCTO      ASC, ';
        v_sql := v_sql || '    IDENT_FIS_JUR    ASC, ';
        v_sql := v_sql || '    NUM_DOCFIS       ASC, ';
        v_sql := v_sql || '    SERIE_DOCFIS     ASC, ';
        v_sql := v_sql || '    SUB_SERIE_DOCFIS ASC, ';
        v_sql := v_sql || '    DISCRI_ITEM      ASC, ';
        v_sql := v_sql || '    DATA_FISCAL_S    ASC ';
        v_sql := v_sql || '  ) ';
        v_sql := v_sql || v_idx_footer;

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX1_PMC_E_CO_' || vp_proc_instance || ' ON ' || vp_tab_entrada_co || ' ';
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || '    PROC_ID      , ';
        v_sql := v_sql || '    COD_EMPRESA  , ';
        v_sql := v_sql || '    COD_ESTAB    , ';
        v_sql := v_sql || '    COD_PRODUTO  , ';
        v_sql := v_sql || '    DATA_FISCAL_S  ';
        v_sql := v_sql || '  ) ';
        v_sql := v_sql || v_idx_footer;

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX2_PMC_E_CO_' || vp_proc_instance || ' ON ' || vp_tab_entrada_co || ' ';
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || '    PROC_ID           , ';
        v_sql := v_sql || '    BUSINESS_UNIT     , ';
        v_sql := v_sql || '    NUM_CONTROLE_DOCTO, ';
        v_sql := v_sql || '    NUM_ITEM ';
        v_sql := v_sql || '  ) ';
        v_sql := v_sql || v_idx_footer;

        EXECUTE IMMEDIATE v_sql;
    END;

    PROCEDURE load_saidas ( vp_proc_instance IN VARCHAR2
                          , v_estabs IN VARCHAR2
                          , vp_data_ini IN DATE
                          , vp_data_fim IN DATE
                          , vp_tabela_saida IN VARCHAR2
                          , vp_data_hora_ini IN VARCHAR2 )
    IS
        --RANGE DE DATAS PARA BUSCAR VENDAS
        v_data_inicial DATE := vp_data_ini; -- DATA INICIAL
        v_data_final DATE := vp_data_fim; -- DATA FINAL

        v_dt_part_ini DATE
            := TO_DATE (    '01'
                         || TO_CHAR ( vp_data_ini
                                    , 'MMYYYY' )
                       , 'DDMMYYYY' ); --DATA INICIAL PARA PARTICAO
        v_dt_part_fim DATE := LAST_DAY ( vp_data_fim ); --DATA FINAL PARA PARTICAO

        v_sql VARCHAR2 ( 10000 );
        v_part_x07 VARCHAR2 ( 128 );
        v_part_x08 VARCHAR2 ( 128 );
        v_part_x993 VARCHAR2 ( 128 );
        v_part_x994 VARCHAR2 ( 128 );
        v_qtde_x993 INTEGER;
        v_partition_x08 VARCHAR2 ( 100 );

        v_i_part_x993 VARCHAR2 ( 128 );
        v_i_part_x994 VARCHAR2 ( 128 );
    BEGIN
        --BUSCAR PARTICOES - INI------------------------------------------
        SELECT   x07.partition_name AS x07_partition_name
               , NVL ( x08.partition_name, 'NAO_EXISTE' ) AS x08_partition_name
               , x993.partition_name AS x993_partition_name
               , x994.partition_name AS x994_partition_name
            INTO v_part_x07
               , v_part_x08
               , v_part_x993
               , v_part_x994
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
                              --SELECT A.OWNER, A.TABLE_NAME, A.PARTITION_NAME, TO_DATE(A.HIGH_VALUE,'DD/MM/YYYY') AS PARTITION_FIM
                              FROM TABLE ( msafi.dpsp_recupera_particao ( 'MSAF'
                                                                        , 'X07_DOCTO_FISCAL'
                                                                        , v_dt_part_ini
                                                                        , v_dt_part_fim ) ) a
                          ORDER BY TO_DATE ( a.partition_fim
                                           , 'DD/MM/YYYY' )--ORDER BY TO_DATE(A.HIGH_VALUE,'DD/MM/YYYY')
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
                    FROM (--SELECT A.OWNER, A.TABLE_NAME, A.PARTITION_NAME, TO_DATE(A.HIGH_VALUE,'DD/MM/YYYY') AS PARTITION_FIM
                          SELECT   a.owner
                                 , a.table_name
                                 , a.partition_name
                                 , TO_DATE ( a.partition_fim
                                           , 'DD/MM/YYYY' )
                                       AS partition_fim
                              FROM TABLE ( msafi.dpsp_recupera_particao ( 'MSAF'
                                                                        , 'X08_ITENS_MERC'
                                                                        , v_dt_part_ini
                                                                        , v_dt_part_fim ) ) a
                          ORDER BY TO_DATE ( a.partition_fim
                                           , 'DD/MM/YYYY' )--ORDER BY TO_DATE(A.HIGH_VALUE,'DD/MM/YYYY')
                                                           ) b) x08
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
                    FROM (--SELECT A.OWNER, A.TABLE_NAME, A.PARTITION_NAME, TO_DATE(A.HIGH_VALUE,'DD/MM/YYYY') AS PARTITION_FIM
                          SELECT   a.owner
                                 , a.table_name
                                 , a.partition_name
                                 , TO_DATE ( a.partition_fim
                                           , 'DD/MM/YYYY' )
                                       AS partition_fim
                              FROM TABLE ( msafi.dpsp_recupera_particao ( 'MSAF'
                                                                        , 'X993_CAPA_CUPOM_ECF'
                                                                        , v_dt_part_ini
                                                                        , v_dt_part_fim ) ) a
                          ORDER BY TO_DATE ( a.partition_fim
                                           , 'DD/MM/YYYY' )--ORDER BY TO_DATE(A.HIGH_VALUE,'DD/MM/YYYY')
                                                           ) b) x993
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
                    FROM (--SELECT A.OWNER, A.TABLE_NAME, A.PARTITION_NAME, TO_DATE(A.HIGH_VALUE,'DD/MM/YYYY') AS PARTITION_FIM
                          SELECT   a.owner
                                 , a.table_name
                                 , a.partition_name
                                 , TO_DATE ( a.partition_fim
                                           , 'DD/MM/YYYY' )
                                       AS partition_fim
                              FROM TABLE ( msafi.dpsp_recupera_particao ( 'MSAF'
                                                                        , 'X994_ITEM_CUPOM_ECF'
                                                                        , v_dt_part_ini
                                                                        , v_dt_part_fim ) ) a
                          ORDER BY TO_DATE ( a.partition_fim
                                           , 'DD/MM/YYYY' )--ORDER BY TO_DATE(A.HIGH_VALUE,'DD/MM/YYYY')
                                                           ) b) x994
           WHERE x07.partition_fim = x08.partition_fim(+)
             AND x07.partition_fim = x993.partition_fim(+)
             AND x07.partition_fim = x994.partition_fim(+)
        ORDER BY x07.partition_fim DESC;

        --BUSCAR PARTICOES - FIM------------------------------------------

        dbms_application_info.set_module ( v_module
                                         , '3 LOAD_SAIDAS [X07]' );

        EXECUTE IMMEDIATE 'TRUNCATE TABLE DP$P_PMC_X07';

        v_sql := 'DECLARE TYPE T_TAB_X07 IS TABLE OF DP$P_PMC_X07%ROWTYPE; ';
        v_sql := v_sql || '        TAB_X07 T_TAB_X07 := T_TAB_X07(); ';
        v_sql := v_sql || ' BEGIN ';
        v_sql := v_sql || ' SELECT MSAFI.DPSP.EMPRESA,   ';
        v_sql := v_sql || '        DOC.COD_ESTAB, ';
        v_sql := v_sql || '        DOC.DATA_FISCAL,  ';
        v_sql := v_sql || '        DOC.MOVTO_E_S,  ';
        v_sql := v_sql || '        DOC.NORM_DEV,  ';
        v_sql := v_sql || '        DOC.IDENT_DOCTO,   ';
        v_sql := v_sql || '        DOC.IDENT_FIS_JUR,  ';
        v_sql := v_sql || '        DOC.NUM_DOCFIS,   ';
        v_sql := v_sql || '        DOC.SERIE_DOCFIS,     ';
        v_sql := v_sql || '        DOC.SUB_SERIE_DOCFIS, ';
        v_sql := v_sql || '        TIP.COD_DOCTO, ';
        v_sql := v_sql || '        '''' || DOC.NUM_AUTENTIC_NFE CHAVE_ACESSO ';
        v_sql := v_sql || ' BULK COLLECT INTO TAB_X07 ';
        v_sql := v_sql || ' FROM MSAF.X07_DOCTO_FISCAL PARTITION (' || v_part_x07 || ') DOC,  ';
        v_sql := v_sql || '      MSAF.X2005_TIPO_DOCTO  TIP   ';
        v_sql := v_sql || ' WHERE DOC.COD_EMPRESA = MSAFI.DPSP.EMPRESA  ';
        v_sql := v_sql || '   AND DOC.COD_ESTAB   IN (' || v_estabs || ') ';
        v_sql := v_sql || '   AND DOC.MOVTO_E_S   = ''9''  ';
        v_sql := v_sql || '   AND DOC.SITUACAO    = ''N''  ';
        v_sql :=
               v_sql
            || '   AND DOC.DATA_FISCAL  BETWEEN TO_DATE('''
            || TO_CHAR ( v_data_inicial
                       , 'DD/MM/YYYY' )
            || ''',''DD/MM/YYYY'') AND TO_DATE('''
            || TO_CHAR ( v_data_final
                       , 'DD/MM/YYYY' )
            || ''',''DD/MM/YYYY'') ';
        v_sql := v_sql || '   AND DOC.IDENT_DOCTO = TIP.IDENT_DOCTO  ';
        v_sql := v_sql || '   AND TIP.COD_DOCTO   IN (''CF-E'',''SAT''); ';
        v_sql := v_sql || ' FORALL I IN TAB_X07.FIRST .. TAB_X07.LAST ';
        v_sql := v_sql || '   INSERT INTO DP$P_PMC_X07 VALUES TAB_X07(I); ';
        v_sql := v_sql || ' COMMIT; ';
        v_sql := v_sql || ' END; ';

        EXECUTE IMMEDIATE v_sql;



        dbms_application_info.set_module ( v_module
                                         , '3 LOAD_SAIDAS [X08]' );

        IF ( v_part_x08 <> 'NAO_EXISTE' ) THEN
            v_partition_x08 := ' PARTITION ( ' || v_part_x08 || ') ';
        END IF;

        EXECUTE IMMEDIATE 'TRUNCATE TABLE DP$P_PMC_X08';

        v_sql := 'DECLARE TYPE T_TAB_X08 IS TABLE OF DP$P_PMC_X08%ROWTYPE; ';
        v_sql := v_sql || '        TAB_X08 T_TAB_X08 := T_TAB_X08(); ';
        v_sql := v_sql || ' BEGIN ';
        v_sql := v_sql || ' SELECT MSAFI.DPSP.EMPRESA,   ';
        v_sql := v_sql || '        ITEM.COD_ESTAB, ';
        v_sql := v_sql || '        ITEM.DATA_FISCAL, ';
        v_sql := v_sql || '        ITEM.MOVTO_E_S,  ';
        v_sql := v_sql || '        ITEM.NORM_DEV,  ';
        v_sql := v_sql || '        ITEM.IDENT_DOCTO, ';
        v_sql := v_sql || '        ITEM.IDENT_FIS_JUR, ';
        v_sql := v_sql || '        ITEM.NUM_DOCFIS, ';
        v_sql := v_sql || '        ITEM.SERIE_DOCFIS, ';
        v_sql := v_sql || '        ITEM.SUB_SERIE_DOCFIS, ';
        v_sql := v_sql || '        ITEM.NUM_ITEM, ';
        v_sql := v_sql || '        ITEM.IDENT_PRODUTO, ';
        v_sql := v_sql || '        ITEM.QUANTIDADE, ';
        v_sql := v_sql || '        ITEM.IDENT_NBM, ';
        v_sql := v_sql || '        ITEM.IDENT_CFO, ';
        v_sql := v_sql || '        ITEM.VLR_DESCONTO, ';
        v_sql := v_sql || '        ITEM.VLR_CONTAB_ITEM, ';
        v_sql :=
               v_sql
            || '        CASE WHEN ITEM.QUANTIDADE > 0 THEN TRUNC(ITEM.VLR_CONTAB_ITEM/ITEM.QUANTIDADE, 2) ELSE 0 END ';
        v_sql := v_sql || ' BULK COLLECT INTO TAB_X08 ';
        v_sql := v_sql || '            FROM MSAF.X08_ITENS_MERC ' || v_partition_x08 || ' ITEM  ';
        v_sql := v_sql || '            WHERE ITEM.COD_EMPRESA        = MSAFI.DPSP.EMPRESA  ';
        v_sql := v_sql || '            AND   ITEM.COD_ESTAB   IN (' || v_estabs || ') ';
        v_sql := v_sql || '            AND   ITEM.MOVTO_E_S          = ''9''  ';
        v_sql :=
               v_sql
            || '            AND   ITEM.DATA_FISCAL  BETWEEN TO_DATE('''
            || TO_CHAR ( v_data_inicial
                       , 'DD/MM/YYYY' )
            || ''',''DD/MM/YYYY'') AND TO_DATE('''
            || TO_CHAR ( v_data_final
                       , 'DD/MM/YYYY' )
            || ''',''DD/MM/YYYY''); ';
        v_sql := v_sql || ' FORALL I IN TAB_X08.FIRST .. TAB_X08.LAST ';
        v_sql := v_sql || '   INSERT INTO DP$P_PMC_X08 VALUES TAB_X08(I); ';
        v_sql := v_sql || ' COMMIT; ';
        v_sql := v_sql || ' END; ';

        EXECUTE IMMEDIATE v_sql;

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , 'DP$P_PMC_X07' );
        dbms_stats.gather_table_stats ( 'MSAF'
                                      , 'DP$P_PMC_X08' );

        --CARREGAR INFORMACOES DE VENDAS
        v_sql := 'DECLARE TYPE T_TAB_SAIDA IS TABLE OF ' || vp_tabela_saida || '%ROWTYPE; ';
        v_sql := v_sql || '        TAB_SAIDA T_TAB_SAIDA := T_TAB_SAIDA(); ';
        v_sql := v_sql || ' BEGIN ';
        v_sql := v_sql || ' SELECT ''' || vp_proc_instance || ''', MSAFI.DPSP.EMPRESA, ';
        v_sql := v_sql || ' DOC.COD_ESTAB        NUMERO_ESTAB,';
        v_sql := v_sql || ' DOC.NUM_DOCFIS       NUMERO_CF,';
        v_sql := v_sql || ' DOC.DATA_FISCAL      DATA_FISCAL_CF,';
        v_sql := v_sql || ' DOC.SERIE_DOCFIS     EQUIPAMENTO,';
        v_sql := v_sql || ' PRD.COD_PRODUTO      COD_ITEM,';
        v_sql := v_sql || ' UFEST.COD_ESTADO     UF_ESTAB,';
        v_sql := v_sql || ' DOC.COD_DOCTO        DOCTO,';
        v_sql := v_sql || ' ITEM.NUM_ITEM        NUM_ITEM,';
        v_sql := v_sql || ' PRD.DESCRICAO        DESCR_ITEM,';
        v_sql := v_sql || ' ITEM.QUANTIDADE      QTD_VENDIDA,';
        v_sql := v_sql || ' NCM.COD_NBM          NCM,';
        v_sql := v_sql || ' CFOP.COD_CFO         CFOP,';
        v_sql := v_sql || ' GRP.DESCRICAO        GRUPO_PRD,';
        v_sql := v_sql || ' ITEM.VLR_DESCONTO    VLR_DESCONTO,';
        v_sql := v_sql || ' ITEM.VLR_CONTAB_ITEM VALOR_CONTAB,';
        v_sql := v_sql || ' ITEM.BASE_UNIT_S_VENDA,';
        v_sql := v_sql || ' DOC.NUM_AUTENTIC_NFE CHAVE_ACESSO,';
        v_sql := v_sql || ' '' ''				LISTA ';
        v_sql := v_sql || ' BULK COLLECT INTO TAB_SAIDA ';
        v_sql := v_sql || ' FROM MSAF.DP$P_PMC_X08 ITEM, ';
        v_sql := v_sql || '      MSAF.DP$P_PMC_X07 DOC, ';
        v_sql := v_sql || '      MSAF.X2013_PRODUTO     PRD, ';
        v_sql := v_sql || '      MSAF.ESTABELECIMENTO   EST, ';
        v_sql := v_sql || '      MSAF.ESTADO            UFEST, ';
        v_sql := v_sql || '      MSAF.X2043_COD_NBM     NCM, ';
        v_sql := v_sql || '      MSAF.X2012_COD_FISCAL  CFOP, ';
        v_sql := v_sql || '      MSAF.GRUPO_PRODUTO     GRP ';
        ---
        v_sql := v_sql || ' WHERE   DOC.COD_EMPRESA         = EST.COD_EMPRESA ';
        v_sql := v_sql || '   AND   DOC.COD_ESTAB           = EST.COD_ESTAB ';
        v_sql := v_sql || '   AND   DOC.COD_EMPRESA         = MSAFI.DPSP.EMPRESA ';
        v_sql := v_sql || '   AND   EST.IDENT_ESTADO        = UFEST.IDENT_ESTADO ';
        v_sql := v_sql || '   AND   ITEM.IDENT_PRODUTO      = PRD.IDENT_PRODUTO ';
        v_sql := v_sql || '   AND   PRD.IDENT_NBM           = NCM.IDENT_NBM ';
        v_sql := v_sql || '   AND   ITEM.IDENT_CFO          = CFOP.IDENT_CFO ';
        v_sql := v_sql || '   AND   PRD.IDENT_GRUPO_PROD    = GRP.IDENT_GRUPO_PROD ';
        v_sql := v_sql || '   AND   CFOP.COD_CFO            = ''5405'' ';
        --
        v_sql := v_sql || '   AND   DOC.COD_EMPRESA       = ITEM.COD_EMPRESA ';
        v_sql := v_sql || '   AND   DOC.COD_ESTAB         = ITEM.COD_ESTAB ';
        v_sql := v_sql || '   AND   DOC.DATA_FISCAL       = ITEM.DATA_FISCAL ';
        v_sql := v_sql || '   AND   DOC.MOVTO_E_S         = ITEM.MOVTO_E_S ';
        v_sql := v_sql || '   AND   DOC.NORM_DEV          = ITEM.NORM_DEV ';
        v_sql := v_sql || '   AND   DOC.IDENT_DOCTO       = ITEM.IDENT_DOCTO ';
        v_sql := v_sql || '   AND   DOC.IDENT_FIS_JUR     = ITEM.IDENT_FIS_JUR ';
        v_sql := v_sql || '   AND   DOC.NUM_DOCFIS        = ITEM.NUM_DOCFIS ';
        v_sql := v_sql || '   AND   DOC.SERIE_DOCFIS      = ITEM.SERIE_DOCFIS ';
        v_sql := v_sql || '   AND   DOC.SUB_SERIE_DOCFIS  = ITEM.SUB_SERIE_DOCFIS; ';
        ---
        v_sql := v_sql || ' FORALL I IN TAB_SAIDA.FIRST .. TAB_SAIDA.LAST ';
        v_sql := v_sql || '    INSERT INTO ' || vp_tabela_saida || ' VALUES TAB_SAIDA(I); ';
        v_sql := v_sql || ' COMMIT; ';
        v_sql := v_sql || ' END; ';
        ---

        dbms_application_info.set_module ( v_module
                                         , '3 LOAD_SAIDAS [CFE]' );

        EXECUTE IMMEDIATE v_sql;

        IF ( v_part_x993 IS NOT NULL ) THEN
            v_i_part_x993 := ' PARTITION ( ' || v_part_x993 || ') ';
        END IF;

        EXECUTE IMMEDIATE 'TRUNCATE TABLE DP$P_PMC_X993';

        v_sql := 'DECLARE TYPE T_TAB_X993 IS TABLE OF DP$P_PMC_X993%ROWTYPE; ';
        v_sql := v_sql || '        TAB_X993 T_TAB_X993 := T_TAB_X993(); ';
        v_sql := v_sql || ' BEGIN ';
        v_sql := v_sql || '    SELECT /*+RESULT_CACHE*/ MSAFI.DPSP.EMPRESA,   ';
        v_sql := v_sql || '           X993.COD_ESTAB, ';
        v_sql := v_sql || '           X993.DATA_EMISSAO, ';
        v_sql := v_sql || '           X993.NUM_COO,  ';
        v_sql := v_sql || '           X993.IDENT_CAIXA_ECF  ';
        v_sql := v_sql || '    BULK COLLECT INTO TAB_X993 ';
        v_sql := v_sql || '    FROM MSAF.X993_CAPA_CUPOM_ECF ' || v_i_part_x993 || ' X993  ';
        v_sql := v_sql || '    WHERE X993.COD_EMPRESA        = MSAFI.DPSP.EMPRESA  ';
        v_sql := v_sql || '      AND X993.COD_ESTAB   IN (' || v_estabs || ') ';
        v_sql := v_sql || '      AND X993.IND_SITUACAO_CUPOM = ''1'' ';
        v_sql :=
               v_sql
            || '      AND X993.DATA_EMISSAO BETWEEN TO_DATE('''
            || TO_CHAR ( v_data_inicial
                       , 'DD/MM/YYYY' )
            || ''',''DD/MM/YYYY'') AND TO_DATE('''
            || TO_CHAR ( v_data_final
                       , 'DD/MM/YYYY' )
            || ''',''DD/MM/YYYY''); ';
        v_sql := v_sql || ' FORALL I IN TAB_X993.FIRST .. TAB_X993.LAST ';
        v_sql := v_sql || '   INSERT INTO DP$P_PMC_X993 VALUES TAB_X993(I); ';
        v_sql := v_sql || ' COMMIT; ';
        v_sql := v_sql || ' END; ';

        dbms_application_info.set_module ( v_module
                                         , '3 LOAD_SAIDAS [X993]' );

        EXECUTE IMMEDIATE v_sql;

        BEGIN
            EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM DP$P_PMC_X993 '            INTO v_qtde_x993;
        EXCEPTION
            WHEN OTHERS THEN
                v_qtde_x993 := 0;
        END;

        IF ( v_qtde_x993 > 0 ) THEN
            IF ( v_part_x994 IS NOT NULL ) THEN
                v_i_part_x994 := ' PARTITION ( ' || v_part_x994 || ') ';
            END IF;

            EXECUTE IMMEDIATE 'TRUNCATE TABLE DP$P_PMC_X994';

            v_sql := 'DECLARE TYPE T_TAB_X994 IS TABLE OF DP$P_PMC_X994%ROWTYPE; ';
            v_sql := v_sql || '        TAB_X994 T_TAB_X994 := T_TAB_X994(); ';
            v_sql := v_sql || ' BEGIN ';
            v_sql := v_sql || '    SELECT /*+RESULT_CACHE*/ MSAFI.DPSP.EMPRESA,   ';
            v_sql := v_sql || '           X994.COD_ESTAB, ';
            v_sql := v_sql || '           X994.DATA_EMISSAO, ';
            v_sql := v_sql || '           X994.NUM_COO,  ';
            v_sql := v_sql || '           X994.IDENT_CAIXA_ECF, ';
            v_sql := v_sql || '           X994.NUM_ITEM, ';
            v_sql := v_sql || '           X994.IDENT_PRODUTO, ';
            v_sql := v_sql || '           X994.IDENT_CFO, ';
            v_sql := v_sql || '           X994.QTDE, ';
            v_sql := v_sql || '           X994.VLR_DESC, ';
            v_sql := v_sql || '           X994.VLR_LIQ_ITEM ';
            v_sql := v_sql || '    BULK COLLECT INTO TAB_X994 ';
            v_sql := v_sql || '    FROM MSAF.X994_ITEM_CUPOM_ECF ' || v_i_part_x994 || ' X994  ';
            v_sql := v_sql || '    WHERE X994.COD_EMPRESA        = MSAFI.DPSP.EMPRESA  ';
            v_sql := v_sql || '      AND X994.COD_ESTAB   IN (' || v_estabs || ') ';
            v_sql := v_sql || '      AND X994.IND_SITUACAO_ITEM  = ''1'' ';
            v_sql :=
                   v_sql
                || '      AND X994.DATA_EMISSAO BETWEEN TO_DATE('''
                || TO_CHAR ( v_data_inicial
                           , 'DD/MM/YYYY' )
                || ''',''DD/MM/YYYY'') AND TO_DATE('''
                || TO_CHAR ( v_data_final
                           , 'DD/MM/YYYY' )
                || ''',''DD/MM/YYYY''); ';
            v_sql := v_sql || ' FORALL I IN TAB_X994.FIRST .. TAB_X994.LAST ';
            v_sql := v_sql || '   INSERT INTO DP$P_PMC_X994 VALUES TAB_X994(I); ';
            v_sql := v_sql || ' COMMIT; ';
            v_sql := v_sql || ' END; ';

            dbms_application_info.set_module ( v_module
                                             , '3 LOAD_SAIDAS [X994]' );

            EXECUTE IMMEDIATE v_sql;

            dbms_stats.gather_table_stats ( 'MSAF'
                                          , 'DP$P_PMC_X993' );
            dbms_stats.gather_table_stats ( 'MSAF'
                                          , 'DP$P_PMC_X994' );

            v_sql := 'DECLARE TYPE T_TAB_SAIDA IS TABLE OF ' || vp_tabela_saida || '%ROWTYPE; ';
            v_sql := v_sql || ' TAB_SAIDA T_TAB_SAIDA := T_TAB_SAIDA(); ';
            v_sql := v_sql || ' BEGIN ';
            v_sql := v_sql || ' SELECT  ''' || vp_proc_instance || ''', ';
            v_sql := v_sql || ' MSAFI.DPSP.EMPRESA, ';
            v_sql := v_sql || ' X993.COD_ESTAB      NUMERO_ESTAB, ';
            v_sql := v_sql || ' X993.NUM_COO        NUMERO_CF, ';
            v_sql := v_sql || ' X993.DATA_EMISSAO   DATA_FISCAL_CF, ';
            v_sql := v_sql || ' X2087.COD_CAIXA_ECF EQUIPAMENTO, ';
            v_sql := v_sql || ' X2013.COD_PRODUTO   COD_ITEM, ';
            v_sql := v_sql || ' UF_EST.COD_ESTADO   UF_ESTAB, ';
            v_sql := v_sql || ' ''ECF''             DOCTO, ';
            v_sql := v_sql || ' X994.NUM_ITEM       NUM_ITEM, ';
            v_sql := v_sql || ' X2013.DESCRICAO     DESCR_ITEM, ';
            v_sql := v_sql || ' X994.QTDE           QTD_VENDIDA, ';
            v_sql := v_sql || ' NCM.COD_NBM         NCM, ';
            v_sql := v_sql || ' X2012.COD_CFO       CFOP, ';
            v_sql := v_sql || ' GRP.DESCRICAO       GRUPO_PRD, ';
            v_sql := v_sql || ' X994.VLR_DESC       VLR_DESCONTO, ';
            v_sql := v_sql || ' X994.VLR_LIQ_ITEM   VALOR_CONTAB, ';
            v_sql :=
                   v_sql
                || ' CASE WHEN X994.QTDE > 0 THEN TRUNC(X994.VLR_LIQ_ITEM/X994.QTDE, 2) ELSE 0 END AS BASE_UNIT_S_VENDA,';
            v_sql := v_sql || ' ''-''               CHAVE_ACESSO, ';
            v_sql := v_sql || ' '' ''               LISTA ';
            v_sql := v_sql || ' BULK COLLECT INTO TAB_SAIDA ';
            v_sql := v_sql || '     FROM MSAF.DP$P_PMC_X993 X993 ';
            v_sql := v_sql || '         ,MSAF.DP$P_PMC_X994 X994 ';
            v_sql := v_sql || '         ,MSAF.X2087_EQUIPAMENTO_ECF X2087 ';
            v_sql := v_sql || '         ,MSAF.ESTABELECIMENTO  EST ';
            v_sql := v_sql || '         ,MSAF.ESTADO           UF_EST ';
            v_sql := v_sql || '         ,MSAF.X2013_PRODUTO    X2013 ';
            v_sql := v_sql || '         ,MSAF.X2012_COD_FISCAL X2012 ';
            v_sql := v_sql || '         ,MSAF.X2043_COD_NBM    NCM ';
            v_sql := v_sql || '         ,MSAF.GRUPO_PRODUTO    GRP ';
            v_sql := v_sql || '     WHERE   X994.COD_EMPRESA        = MSAFI.DPSP.EMPRESA ';
            v_sql := v_sql || '       AND   X994.COD_ESTAB          IN (' || v_estabs || ') ';
            v_sql :=
                   v_sql
                || '       AND   X994.DATA_EMISSAO BETWEEN TO_DATE('''
                || TO_CHAR ( v_data_inicial
                           , 'DD/MM/YYYY' )
                || ''',''DD/MM/YYYY'') AND TO_DATE('''
                || TO_CHAR ( v_data_final
                           , 'DD/MM/YYYY' )
                || ''',''DD/MM/YYYY'') ';
            ---
            v_sql := v_sql || '       AND   X993.COD_EMPRESA       = X2087.COD_EMPRESA ';
            v_sql := v_sql || '       AND   X993.COD_ESTAB         = X2087.COD_ESTAB ';
            v_sql := v_sql || '       AND   X993.IDENT_CAIXA_ECF   = X2087.IDENT_CAIXA_ECF ';
            ---
            v_sql := v_sql || '       AND   X994.COD_EMPRESA        = X993.COD_EMPRESA ';
            v_sql := v_sql || '       AND   X994.COD_ESTAB          = X993.COD_ESTAB ';
            v_sql := v_sql || '       AND   X994.IDENT_CAIXA_ECF    = X993.IDENT_CAIXA_ECF ';
            v_sql := v_sql || '       AND   X994.NUM_COO            = X993.NUM_COO ';
            v_sql := v_sql || '       AND   X994.DATA_EMISSAO       = X993.DATA_EMISSAO ';
            ---
            v_sql := v_sql || '       AND   X994.IDENT_PRODUTO      = X2013.IDENT_PRODUTO ';
            v_sql := v_sql || '       AND   X994.IDENT_CFO          = X2012.IDENT_CFO ';
            v_sql := v_sql || '       AND   X993.COD_EMPRESA        = EST.COD_EMPRESA ';
            v_sql := v_sql || '       AND   X993.COD_ESTAB          = EST.COD_ESTAB ';
            v_sql := v_sql || '       AND   X2013.IDENT_NBM         = NCM.IDENT_NBM ';
            v_sql := v_sql || '       AND   X2013.IDENT_GRUPO_PROD  = GRP.IDENT_GRUPO_PROD ';
            v_sql := v_sql || '       AND   EST.IDENT_ESTADO        = UF_EST.IDENT_ESTADO ';
            v_sql := v_sql || '       AND   X2012.COD_CFO           = ''5405'' ; ';
            ---
            v_sql := v_sql || ' FORALL I IN TAB_SAIDA.FIRST .. TAB_SAIDA.LAST ';
            v_sql := v_sql || '    INSERT INTO ' || vp_tabela_saida || ' VALUES TAB_SAIDA(I); ';
            v_sql := v_sql || ' COMMIT; ';
            v_sql := v_sql || ' END; ';

            dbms_application_info.set_module ( v_module
                                             , '3 LOAD_SAIDAS [ECF]' );

            EXECUTE IMMEDIATE v_sql;

            COMMIT;
        END IF;
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
        --BEGIN
        --  SELECT
        --  ROUND((SELECT VALUE FROM V$PARAMETER WHERE NAME = 'pga_aggregate_limit')/1024/1024,2) AS PGA_LIMIT,
        --  ROUND((SELECT VALUE FROM V$PARAMETER WHERE NAME = 'pga_aggregate_target')/1024/1024,2) AS PGA_TARGET,
        --  ROUND((SELECT VALUE FROM V$PARAMETER WHERE NAME = 'sga_max_size')/1024/1024,2) AS SGA_MAX,
        --  ROUND((SELECT VALUE FROM V$PARAMETER WHERE NAME = 'sga_target')/1024/1024,2) AS SGA_TARGET
        --  INTO V_I_PGA_LIMIT, V_I_PGA_TARGET, V_I_SGA_MAX, V_I_SGA_TARGET
        --  FROM DUAL;
        --EXCEPTION
        --  WHEN OTHERS THEN
        --    V_I_PGA_LIMIT   := 0;
        --    V_I_PGA_TARGET  := 0;
        --    V_I_SGA_MAX     := 0;
        --    V_I_SGA_TARGET  := 0;
        --END;

        ---OBTER USO DE REDO LOG FILES
        --BEGIN
        --  SELECT NVL(SUM(DECODE(SUBSTR(TO_CHAR(FIRST_TIME, 'HH24'), 1, 2), SUBSTR(TO_CHAR(SYSDATE,'HH24'),1,2), 1, 0)),0) AS LOGS
        --  INTO V_I_LOG_USE
        --  FROM V$LOG_HISTORY
        --  WHERE SUBSTR(TO_CHAR(FIRST_TIME, 'DDMMYYYY'), 1, 8) = SUBSTR(TO_CHAR(SYSDATE, 'DDMMYYYY'), 1, 8);
        --EXCEPTION
        --  WHEN OTHERS THEN
        --    V_I_LOG_USE := 0;
        --END;

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
                            , vp_tab_saida IN VARCHAR2
                            , vp_cd IN VARCHAR2
                            , vp_tab_ent_f IN VARCHAR2
                            , vp_tab_ent_d IN VARCHAR2
                            , vp_tab_ent_c IN VARCHAR2
                            , v_tab_aux IN VARCHAR2
                            , v_mproc_id IN NUMBER
                            , vp_tab_x07 IN VARCHAR2
                            , vp_tab_x08 IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 8000 );
        v_qtde NUMBER;
        v_tab_x07 VARCHAR2 ( 30 );
        v_tab_x08 VARCHAR2 ( 30 );
        ---
        v_limit INTEGER;
        v_estabs VARCHAR2 ( 5000 );
        v_cod_estab VARCHAR2 ( 6 );
        c_est SYS_REFCURSOR;
        t_start NUMBER;
        ---
        v_i_nfe_particao VARCHAR2 ( 128 );
        v_i_ini_particao DATE;
        v_i_fim_particao DATE;
        v_dt_part_fim DATE := LAST_DAY ( vp_dt_final );

        ---
        CURSOR c_partition ( p_i_data_final IN DATE )
        IS
            SELECT   partition_name AS nfe_partition_name
                   , TO_DATE ( partition_inicio
                             , 'DD/MM/YYYY' )
                         AS inicio_particao
                   , TO_DATE ( partition_fim
                             , 'DD/MM/YYYY' )
                         AS final_particao
                --TO_DATE(HIGH_VALUE,'DD/MM/YYYY') AS FINAL_PARTICAO
                FROM TABLE ( msafi.dpsp_recupera_particao ( 'MSAFI'
                                                          , 'DPSP_NF_ENTRADA'
                                                          , TO_DATE ( '20130101'
                                                                    , 'YYYYMMDD' )
                                                          , p_i_data_final ) )
            ORDER BY 2 DESC;

        ---
        CURSOR c_partition_dblink ( p_i_data_final IN DATE
                                  , p_i_dblink IN VARCHAR2 )
        IS
            SELECT   partition_name AS nfe_partition_name
                   , TO_DATE ( partition_inicio
                             , 'DD/MM/YYYY' )
                         AS inicio_particao
                   , TO_DATE ( partition_fim
                             , 'DD/MM/YYYY' )
                         AS final_particao
                --TO_DATE(HIGH_VALUE,'DD/MM/YYYY') AS FINAL_PARTICAO
                FROM TABLE ( msafi.dpsp_recupera_particao_dblink ( 'MSAFI'
                                                                 , 'DPSP_NF_ENTRADA'
                                                                 , TO_DATE ( '20130101'
                                                                           , 'YYYYMMDD' )
                                                                 , p_i_data_final
                                                                 , p_i_dblink ) )
            ORDER BY 2 DESC;

        ---
        --- VAR PARA AUDITORIA DE PGA
        v_cpu_time_start NUMBER;
        v_cpu_time NUMBER;
        v_pga_ini NUMBER;
        v_pga_end NUMBER;
        v_uga_ini NUMBER;
        v_uga_end NUMBER;
        v_qtd_lines NUMBER;
    BEGIN
        EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || v_tab_aux;

        IF ( vp_origem = 'C' ) THEN --CD
            v_sql := 'INSERT INTO ' || v_tab_aux;
            v_sql :=
                   v_sql
                || ' SELECT DISTINCT '''
                || vp_cod_estab
                || ''' AS COD_ESTAB, COD_PRODUTO, DATA_FISCAL FROM '
                || vp_tab_saida;

            EXECUTE IMMEDIATE v_sql;

            loga ( '[TTL AUX CD][' || SQL%ROWCOUNT || ']'
                 , FALSE );
            COMMIT;

            --APAGAR LINHAS JA CARREGADAS NAs TABs DE ENTRADA ANTERIORES
            v_sql := 'DELETE ' || v_tab_aux || ' A ';
            v_sql := v_sql || ' WHERE EXISTS (SELECT ''Y'' ';
            v_sql := v_sql || '               FROM ' || vp_tab_ent_f || ' E ';
            v_sql := v_sql || '               WHERE E.COD_ESTAB     = A.COD_ESTAB ';
            v_sql := v_sql || '                 AND E.COD_PRODUTO   = A.COD_PRODUTO ';
            v_sql := v_sql || '                 AND E.DATA_FISCAL_S = A.DATA_FISCAL_S ) ';

            EXECUTE IMMEDIATE v_sql;

            loga ( '[LIMPEZA CD F][' || SQL%ROWCOUNT || ']'
                 , FALSE );
            COMMIT;

            v_sql := 'DELETE ' || v_tab_aux || ' A ';
            v_sql := v_sql || ' WHERE EXISTS (SELECT ''Y'' ';
            v_sql := v_sql || '               FROM ' || vp_tab_ent_c || ' E ';
            v_sql := v_sql || '               WHERE E.COD_PRODUTO   = A.COD_PRODUTO ';
            v_sql := v_sql || '                 AND E.DATA_FISCAL_S = A.DATA_FISCAL_S ) ';

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
                v_qtde := 0;

                IF ( a_cod_empresa ( vp_cod_estab ).empresa = msafi.dpsp.empresa ) THEN
                    OPEN c_partition ( v_dt_part_fim );
                ELSE
                    OPEN c_partition_dblink ( v_dt_part_fim
                                            , REPLACE ( a_cod_empresa ( vp_cod_estab ).dblink
                                                      , '@'
                                                      , '' ) );
                END IF;

                LOOP
                    IF ( a_cod_empresa ( vp_cod_estab ).empresa = msafi.dpsp.empresa ) THEN
                        FETCH c_partition
                            INTO v_i_nfe_particao
                               , v_i_ini_particao
                               , v_i_fim_particao;
                    ELSE
                        FETCH c_partition_dblink
                            INTO v_i_nfe_particao
                               , v_i_ini_particao
                               , v_i_fim_particao;
                    END IF;

                    IF ( a_cod_empresa ( vp_cod_estab ).empresa = msafi.dpsp.empresa ) THEN
                        EXIT WHEN c_partition%NOTFOUND;
                    ELSE
                        EXIT WHEN c_partition_dblink%NOTFOUND;
                    END IF;

                    v_limit := v_limit + 1;
                    dbms_application_info.set_module ( $$plsql_unit
                                                     , '7 ENTRADA CD ' || vp_cd || ' [' || v_limit || ']' );

                    t_start := dbms_utility.get_time;

                    v_sql := 'DECLARE TYPE T_BULK_COLLECT_TAB_E IS TABLE OF ' || vp_tabela_entrada || '%ROWTYPE; ';
                    v_sql := v_sql || '        TAB_E T_BULK_COLLECT_TAB_E := T_BULK_COLLECT_TAB_E(); ';
                    v_sql := v_sql || '        ERRORS NUMBER; ';
                    v_sql := v_sql || '        DML_ERRORS EXCEPTION;  ';
                    v_sql := v_sql || '        ERR_IDX INTEGER;  ';
                    v_sql := v_sql || '        ERR_CODE NUMBER;  ';
                    v_sql := v_sql || '        ERR_MSG VARCHAR2(255); ';
                    v_sql := v_sql || 'BEGIN ';
                    ---
                    v_sql := v_sql || 'SELECT ';
                    v_sql := v_sql || '    ' || vp_proc_instance || ' AS PROC_ID, ';
                    v_sql := v_sql || '    A.COD_EMPRESA, ';
                    v_sql := v_sql || '    A.COD_ESTAB, ';
                    v_sql := v_sql || '    A.DATA_FISCAL, ';
                    v_sql := v_sql || '    A.MOVTO_E_S, ';
                    v_sql := v_sql || '    A.NORM_DEV, ';
                    v_sql := v_sql || '    A.IDENT_DOCTO, ';
                    v_sql := v_sql || '    A.IDENT_FIS_JUR, ';
                    v_sql := v_sql || '    A.NUM_DOCFIS, ';
                    v_sql := v_sql || '    A.SERIE_DOCFIS, ';
                    v_sql := v_sql || '    A.SUB_SERIE_DOCFIS, ';
                    v_sql := v_sql || '    A.DISCRI_ITEM, ';
                    v_sql := v_sql || '    A.DATA_FISCAL_S, ';
                    v_sql := v_sql || '    A.NUM_ITEM, ';
                    v_sql := v_sql || '    A.COD_FIS_JUR, ';
                    v_sql := v_sql || '    A.CPF_CGC, ';
                    v_sql := v_sql || '    A.COD_NBM, ';
                    v_sql := v_sql || '    A.COD_CFO, ';
                    v_sql := v_sql || '    A.COD_NATUREZA_OP, ';
                    v_sql := v_sql || '    A.COD_PRODUTO, ';
                    v_sql := v_sql || '    A.VLR_CONTAB_ITEM, ';
                    v_sql := v_sql || '    A.QUANTIDADE, ';
                    v_sql := v_sql || '    A.VLR_UNIT, ';
                    v_sql := v_sql || '    A.COD_SITUACAO_B, ';
                    v_sql := v_sql || '    A.DATA_EMISSAO, ';
                    v_sql := v_sql || '    A.COD_ESTADO, ';
                    v_sql := v_sql || '    A.NUM_CONTROLE_DOCTO, ';
                    v_sql := v_sql || '    A.NUM_AUTENTIC_NFE, ';
                    v_sql :=
                        v_sql || '    ''' || a_cod_empresa ( vp_cod_estab ).business_unit || ''' AS BUSINESS_UNIT '; ---BUSINESS_UNIT
                    v_sql := v_sql || ' BULK COLLECT INTO TAB_E ';
                    v_sql := v_sql || 'FROM ( ';
                    v_sql := v_sql || '      SELECT ';
                    v_sql := v_sql || '        NFE.COD_EMPRESA, ';
                    v_sql := v_sql || '        NFE.COD_ESTAB, ';
                    v_sql := v_sql || '        NFE.DATA_FISCAL, ';
                    v_sql := v_sql || '        P.DATA_FISCAL_S, ';
                    v_sql := v_sql || '        NFE.MOVTO_E_S, ';
                    v_sql := v_sql || '        NFE.NORM_DEV, ';
                    v_sql := v_sql || '        NFE.IDENT_DOCTO, ';
                    v_sql := v_sql || '        NFE.IDENT_FIS_JUR, ';
                    v_sql := v_sql || '        NFE.NUM_DOCFIS, ';
                    v_sql := v_sql || '        NFE.SERIE_DOCFIS, ';
                    v_sql := v_sql || '        NFE.SUB_SERIE_DOCFIS, ';
                    v_sql := v_sql || '        NFE.DISCRI_ITEM, ';
                    v_sql := v_sql || '        NFE.NUM_ITEM, ';
                    v_sql := v_sql || '        G.COD_FIS_JUR, ';
                    v_sql := v_sql || '        G.CPF_CGC, ';
                    v_sql := v_sql || '        NFE.COD_NBM, ';
                    v_sql := v_sql || '        NFE.COD_CFO, ';
                    v_sql := v_sql || '        NFE.COD_NATUREZA_OP, ';
                    v_sql := v_sql || '        NFE.COD_PRODUTO, ';
                    v_sql := v_sql || '        NFE.VLR_CONTAB_ITEM, ';
                    v_sql := v_sql || '        NFE.QUANTIDADE, ';
                    v_sql := v_sql || '        NFE.VLR_UNIT, ';
                    v_sql := v_sql || '        NFE.COD_SITUACAO_B, ';
                    v_sql := v_sql || '        NFE.DATA_EMISSAO, ';
                    v_sql := v_sql || '        NFE.COD_ESTADO, ';
                    v_sql := v_sql || '        NFE.NUM_CONTROLE_DOCTO, ';
                    v_sql := v_sql || '        NFE.NUM_AUTENTIC_NFE AS NUM_AUTENTIC_NFE, ';
                    v_sql := v_sql || '        G.RAZAO_SOCIAL, ';
                    v_sql := v_sql || '        RANK() OVER( ';
                    v_sql := v_sql || '          PARTITION BY NFE.COD_ESTAB, NFE.COD_PRODUTO, P.DATA_FISCAL_S ';
                    v_sql := v_sql || '              ORDER BY NFE.DATA_FISCAL DESC, ';
                    v_sql := v_sql || '                       NFE.DATA_EMISSAO DESC, ';
                    v_sql := v_sql || '                       NFE.NUM_DOCFIS DESC, ';
                    v_sql := v_sql || '                       NFE.DISCRI_ITEM DESC, ';
                    v_sql := v_sql || '                       NFE.SERIE_DOCFIS ) RANK ';

                    ---
                    IF ( a_cod_empresa ( vp_cod_estab ).dblink = 'LOCAL' ) THEN
                        ---LOCAL
                        v_sql := v_sql || '    FROM MSAFI.DPSP_NF_ENTRADA PARTITION (' || v_i_nfe_particao || ') NFE, ';
                        v_sql := v_sql || '         MSAF.X04_PESSOA_FIS_JUR G, ';
                    ELSE
                        ---DBLINK
                        v_sql :=
                               v_sql
                            || '    FROM MSAFI.DPSP_NF_ENTRADA'
                            || a_cod_empresa ( vp_cod_estab ).dblink
                            || ' NFE, ';
                        v_sql :=
                               v_sql
                            || '         MSAF.X04_PESSOA_FIS_JUR'
                            || a_cod_empresa ( vp_cod_estab ).dblink
                            || ' G, ';
                    END IF;

                    ---
                    v_sql := v_sql || '         ' || v_tab_aux || ' P ';
                    ---
                    v_sql :=
                        v_sql || '    WHERE NFE.COD_EMPRESA   = ''' || a_cod_empresa ( vp_cod_estab ).empresa || ''' ';
                    v_sql := v_sql || '      AND NFE.COD_ESTAB     = ''' || vp_cod_estab || ''' ';
                    v_sql :=
                           v_sql
                        || '      AND NFE.DATA_FISCAL BETWEEN TO_DATE('''
                        || TO_CHAR ( v_i_ini_particao
                                   , 'DDMMYYYY' )
                        || ''',''DDMMYYYY'') AND TO_DATE('''
                        || TO_CHAR ( v_i_fim_particao
                                   , 'DDMMYYYY' )
                        || ''',''DDMMYYYY'') ';
                    ---
                    v_sql := v_sql || '      AND NFE.SITUACAO      = ''N'' ';
                    v_sql :=
                           v_sql
                        || '      AND NFE.COD_CFO          IN (''1102'',''2102'',''1403'',''2403'',''1910'',''2910'') ';
                    v_sql := v_sql || '      AND NFE.NUM_CONTROLE_DOCTO  LIKE ''0%''  '; -- incluido no 10749
                    v_sql := v_sql || '      AND NFE.COD_NATUREZA_OP  <> ''ISE'' ';
                    v_sql := v_sql || '      AND NFE.VLR_ITEM         > 0.01 ';
                    v_sql := v_sql || '      AND NFE.IDENT_FIS_JUR    = G.IDENT_FIS_JUR ';
                    ---
                    v_sql := v_sql || '      AND P.COD_PRODUTO    =  NFE.COD_PRODUTO ';
                    v_sql := v_sql || '      AND P.DATA_FISCAL_S  >  NFE.DATA_FISCAL ';
                    ---
                    v_sql := v_sql || '     ) A ';
                    v_sql := v_sql || 'WHERE A.RANK = 1; ';
                    ---
                    v_sql := v_sql || 'BEGIN ';
                    v_sql := v_sql || 'FORALL I IN TAB_E.FIRST .. TAB_E.LAST SAVE EXCEPTIONS';
                    v_sql := v_sql || ' INSERT INTO ' || vp_tabela_entrada || ' VALUES TAB_E(I); ';
                    v_sql := v_sql || 'EXCEPTION ';
                    v_sql := v_sql || 'WHEN OTHERS THEN  ';
                    v_sql := v_sql || '    ERRORS := SQL%BULK_EXCEPTIONS.COUNT;  ';

                    IF ( v_p_log = 'S' ) THEN --GRAVAR LOG
                        v_sql := v_sql || '    FOR I IN 1..ERRORS LOOP  ';
                        v_sql := v_sql || '    ERR_IDX := SQL%BULK_EXCEPTIONS(I).ERROR_INDEX;  ';
                        v_sql := v_sql || '    ERR_CODE := SQL%BULK_EXCEPTIONS(I).ERROR_CODE;  ';
                        v_sql := v_sql || '    ERR_MSG  := SQLERRM(-SQL%BULK_EXCEPTIONS(I).ERROR_CODE);  ';
                        v_sql :=
                               v_sql
                            || '      INSERT INTO MSAFI.LOG_GERAL (ORA_ERR_NUMBER1, ORA_ERR_MESG1, COD_EMPRESA, COD_ESTAB, NUM_DOCFIS, DATA_FISCAL, SERIE_DOCFIS, COL14, COL15,  ';
                        v_sql :=
                               v_sql
                            || '                                  COL16, NUM_ITEM, COL17, COL18, COL19, COL20, COL21, COL22, MOVTO_E_S, NORM_DEV, IDENT_DOCTO, IDENT_FIS_JUR) VALUES  ';
                        v_sql :=
                               v_sql
                            || '                                  (ERR_CODE, ERR_MSG, TAB_E(ERR_IDX).COD_EMPRESA, ';
                        v_sql :=
                               v_sql
                            || '                                  TAB_E(ERR_IDX).COD_ESTAB, TAB_E(ERR_IDX).NUM_DOCFIS, TAB_E(ERR_IDX).DATA_FISCAL, TAB_E(ERR_IDX).SERIE_DOCFIS, ';
                        v_sql :=
                               v_sql
                            || '                                  TAB_E(ERR_IDX).COD_PRODUTO, TAB_E(ERR_IDX).COD_ESTADO, TAB_E(ERR_IDX).DATA_FISCAL_S, TAB_E(ERR_IDX).NUM_ITEM,  ';
                        v_sql :=
                               v_sql
                            || '                                  ''DPSP_PMC_X_MVA_V2_CPROC'', ''LOAD_ENTRADAS_FILIAL'', '''
                            || vp_cod_estab
                            || ''', ''-'',  ';
                        v_sql :=
                               v_sql
                            || '                                  TO_CHAR(SYSDATE,''DD/MM/YYYY HH24:MI.SS''), '''
                            || v_mproc_id
                            || ''', TAB_E(ERR_IDX).MOVTO_E_S, ';
                        v_sql :=
                               v_sql
                            || '                                  TAB_E(ERR_IDX).NORM_DEV, TAB_E(ERR_IDX).IDENT_DOCTO, TAB_E(ERR_IDX).IDENT_FIS_JUR);  ';
                        v_sql := v_sql || '    END LOOP;  ';
                        v_sql := v_sql || '    COMMIT; ';
                    ELSE
                        v_sql := v_sql || '    NULL; ';
                    END IF;

                    v_sql := v_sql || 'END;  ';
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
                    v_sql := v_sql || '               WHERE E.COD_ESTAB     = A.COD_ESTAB ';
                    v_sql := v_sql || '                 AND E.COD_PRODUTO   = A.COD_PRODUTO ';
                    v_sql := v_sql || '                 AND E.DATA_FISCAL_S = A.DATA_FISCAL_S ) ';

                    EXECUTE IMMEDIATE v_sql;

                    COMMIT;
                    dbms_stats.gather_table_stats ( 'MSAF'
                                                  , v_tab_aux );

                    BEGIN
                        EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || v_tab_aux            INTO v_qtde;
                    EXCEPTION
                        WHEN OTHERS THEN
                            v_qtde := 0;
                    END;

                    IF ( v_limit = 24
                     OR v_qtde = 0 ) THEN
                        --VOLTAR 2 ANOS
                        loga ( '[EXIT][' || vp_cod_estab || ']'
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
            v_sql := 'INSERT INTO ' || v_tab_aux;
            v_sql := v_sql || ' SELECT DISTINCT COD_ESTAB, COD_PRODUTO, DATA_FISCAL FROM ' || vp_tab_saida;

            EXECUTE IMMEDIATE v_sql;

            loga ( '[TTL AUX F][' || SQL%ROWCOUNT || ']'
                 , FALSE );
            COMMIT;

            --APAGAR LINHAS JA CARREGADAS NAs TABs DE ENTRADA ANTERIORES
            v_sql := 'DELETE ' || v_tab_aux || ' A ';
            v_sql := v_sql || ' WHERE EXISTS (SELECT ''Y'' ';
            v_sql := v_sql || '               FROM ' || vp_tab_ent_f || ' E ';
            v_sql := v_sql || '               WHERE E.COD_ESTAB   = A.COD_ESTAB ';
            v_sql := v_sql || '                 AND E.COD_PRODUTO   = A.COD_PRODUTO ';
            v_sql := v_sql || '                 AND E.DATA_FISCAL_S = A.DATA_FISCAL_S ) ';

            EXECUTE IMMEDIATE v_sql;

            loga ( '[LIMPEZA FIL F][' || SQL%ROWCOUNT || ']'
                 , FALSE );
            COMMIT;

            v_sql := 'DELETE ' || v_tab_aux || ' A ';
            v_sql := v_sql || ' WHERE EXISTS (SELECT ''Y'' ';
            v_sql := v_sql || '               FROM ' || vp_tab_ent_c || ' E ';
            v_sql := v_sql || '               WHERE E.COD_PRODUTO   = A.COD_PRODUTO ';
            v_sql := v_sql || '                 AND E.DATA_FISCAL_S = A.DATA_FISCAL_S ) ';

            EXECUTE IMMEDIATE v_sql;

            loga ( '[LIMPEZA FIL C][' || SQL%ROWCOUNT || ']'
                 , FALSE );
            COMMIT;

            dbms_stats.gather_table_stats ( 'MSAF'
                                          , v_tab_aux );

            --APENAS CONTINUA SE HOUVEREM LINHAS PARA QUERY
            EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || v_tab_aux            INTO v_qtde;

            IF ( v_qtde > 0 ) THEN --**
                v_qtde := 0;

                OPEN c_est FOR 'SELECT DISTINCT COD_ESTAB FROM ' || v_tab_aux;

                LOOP
                    FETCH c_est
                        INTO v_cod_estab;

                    EXIT WHEN c_est%NOTFOUND;

                    v_limit := 0;

                    FOR c_part IN c_partition ( v_dt_part_fim ) LOOP
                        v_limit := v_limit + 1;
                        dbms_application_info.set_module ( $$plsql_unit
                                                         , 'ENTRADA FILIAIS CD ' || vp_cd || ' [' || v_limit || ']' );

                        ----------------------------------------------------
                        t_start := dbms_utility.get_time;
                        v_sql := 'DECLARE TYPE T_BULK_COLLECT_TAB_E IS TABLE OF ' || vp_tabela_entrada || '%ROWTYPE; ';
                        v_sql := v_sql || '        TAB_E T_BULK_COLLECT_TAB_E := T_BULK_COLLECT_TAB_E(); ';
                        v_sql := v_sql || '        ERRORS NUMBER; ';
                        v_sql := v_sql || '        DML_ERRORS EXCEPTION;  ';
                        v_sql := v_sql || '        ERR_IDX INTEGER;  ';
                        v_sql := v_sql || '        ERR_CODE NUMBER;  ';
                        v_sql := v_sql || '        ERR_MSG VARCHAR2(255); ';
                        v_sql := v_sql || 'BEGIN ';
                        ---
                        v_sql := v_sql || 'SELECT ';
                        v_sql := v_sql || '    ' || vp_proc_instance || ' AS PROC_ID, ';
                        v_sql := v_sql || '    A.COD_EMPRESA, ';
                        v_sql := v_sql || '    A.COD_ESTAB, ';
                        v_sql := v_sql || '    A.DATA_FISCAL, ';
                        v_sql := v_sql || '    A.MOVTO_E_S, ';
                        v_sql := v_sql || '    A.NORM_DEV, ';
                        v_sql := v_sql || '    A.IDENT_DOCTO, ';
                        v_sql := v_sql || '    A.IDENT_FIS_JUR, ';
                        v_sql := v_sql || '    A.NUM_DOCFIS, ';
                        v_sql := v_sql || '    A.SERIE_DOCFIS, ';
                        v_sql := v_sql || '    A.SUB_SERIE_DOCFIS, ';
                        v_sql := v_sql || '    A.DISCRI_ITEM, ';
                        v_sql := v_sql || '    A.DATA_FISCAL_S, ';
                        v_sql := v_sql || '    A.NUM_ITEM, ';
                        v_sql := v_sql || '    A.COD_FIS_JUR, ';
                        v_sql := v_sql || '    A.CPF_CGC, ';
                        v_sql := v_sql || '    A.COD_NBM, ';
                        v_sql := v_sql || '    A.COD_CFO, ';
                        v_sql := v_sql || '    A.COD_NATUREZA_OP, ';
                        v_sql := v_sql || '    A.COD_PRODUTO, ';
                        v_sql := v_sql || '    A.VLR_CONTAB_ITEM, ';
                        v_sql := v_sql || '    A.QUANTIDADE, ';
                        v_sql := v_sql || '    A.VLR_UNIT, ';
                        v_sql := v_sql || '    A.COD_SITUACAO_B, ';
                        v_sql := v_sql || '    A.DATA_EMISSAO, ';
                        v_sql := v_sql || '    A.COD_ESTADO, ';
                        v_sql := v_sql || '    A.NUM_CONTROLE_DOCTO, ';
                        v_sql := v_sql || '    A.NUM_AUTENTIC_NFE, ';
                        v_sql :=
                            v_sql || '    ''' || a_cod_empresa ( 'DEFAULT' ).business_unit || ''' AS BUSINESS_UNIT '; ---BUSINESS_UNIT
                        v_sql := v_sql || '    BULK COLLECT INTO TAB_E ';
                        v_sql := v_sql || 'FROM ( ';
                        v_sql := v_sql || '      SELECT ';
                        v_sql := v_sql || '        NFE.COD_EMPRESA, ';
                        v_sql := v_sql || '        NFE.COD_ESTAB, ';
                        v_sql := v_sql || '        NFE.DATA_FISCAL, ';
                        v_sql := v_sql || '        P.DATA_FISCAL_S, ';
                        v_sql := v_sql || '        NFE.MOVTO_E_S, ';
                        v_sql := v_sql || '        NFE.NORM_DEV, ';
                        v_sql := v_sql || '        NFE.IDENT_DOCTO, ';
                        v_sql := v_sql || '        NFE.IDENT_FIS_JUR, ';
                        v_sql := v_sql || '        NFE.NUM_DOCFIS, ';
                        v_sql := v_sql || '        NFE.SERIE_DOCFIS, ';
                        v_sql := v_sql || '        NFE.SUB_SERIE_DOCFIS, ';
                        v_sql := v_sql || '        NFE.DISCRI_ITEM, ';
                        v_sql := v_sql || '        NFE.NUM_ITEM, ';
                        v_sql := v_sql || '        G.COD_FIS_JUR, ';
                        v_sql := v_sql || '        G.CPF_CGC, ';
                        v_sql := v_sql || '        NFE.COD_NBM, ';
                        v_sql := v_sql || '        NFE.COD_CFO, ';
                        v_sql := v_sql || '        NFE.COD_NATUREZA_OP, ';
                        v_sql := v_sql || '        NFE.COD_PRODUTO, ';
                        v_sql := v_sql || '        NFE.VLR_CONTAB_ITEM, ';
                        v_sql := v_sql || '        NFE.QUANTIDADE, ';
                        v_sql := v_sql || '        NFE.VLR_UNIT, ';
                        v_sql := v_sql || '        NFE.COD_SITUACAO_B, ';
                        v_sql := v_sql || '        NFE.DATA_EMISSAO, ';
                        v_sql := v_sql || '        NFE.COD_ESTADO, ';
                        v_sql := v_sql || '        NFE.NUM_CONTROLE_DOCTO, ';
                        v_sql := v_sql || '        NFE.NUM_AUTENTIC_NFE AS NUM_AUTENTIC_NFE, ';
                        v_sql := v_sql || '        G.RAZAO_SOCIAL, ';
                        v_sql := v_sql || '        RANK() OVER( ';
                        v_sql := v_sql || '          PARTITION BY NFE.COD_ESTAB, NFE.COD_PRODUTO, P.DATA_FISCAL_S ';
                        v_sql := v_sql || '              ORDER BY NFE.DATA_FISCAL DESC, ';
                        v_sql := v_sql || '                       NFE.DATA_EMISSAO DESC, ';
                        v_sql := v_sql || '                       NFE.NUM_DOCFIS DESC, ';
                        v_sql := v_sql || '                       NFE.DISCRI_ITEM DESC, ';
                        v_sql := v_sql || '                       NFE.SERIE_DOCFIS) RANK ';
                        v_sql :=
                               v_sql
                            || '    FROM MSAFI.DPSP_NF_ENTRADA PARTITION ('
                            || c_part.nfe_partition_name
                            || ') NFE, ';
                        v_sql := v_sql || '         X04_PESSOA_FIS_JUR G, ';
                        v_sql := v_sql || '         ' || v_tab_aux || ' P ';
                        v_sql := v_sql || '    WHERE NFE.COD_EMPRESA = MSAFI.DPSP.EMPRESA ';
                        v_sql := v_sql || '      AND G.CPF_CGC     = ''' || a_cod_empresa ( vp_cd ).cnpj || ''' ';
                        v_sql := v_sql || '      AND NFE.COD_ESTAB = ''' || v_cod_estab || ''' ';
                        v_sql :=
                               v_sql
                            || '      AND NFE.DATA_FISCAL BETWEEN TO_DATE('''
                            || TO_CHAR ( c_part.inicio_particao
                                       , 'DDMMYYYY' )
                            || ''',''DDMMYYYY'') AND TO_DATE('''
                            || TO_CHAR ( c_part.final_particao
                                       , 'DDMMYYYY' )
                            || ''',''DDMMYYYY'') ';
                        ---
                        v_sql := v_sql || '      AND NFE.SITUACAO  = ''N'' ';
                        v_sql :=
                               v_sql
                            || '      AND NFE.COD_CFO   IN (''1152'',''2152'',''1409'',''2409'',''1403'',''2403'') ';
                        v_sql := v_sql || '      AND NFE.NUM_CONTROLE_DOCTO  LIKE ''0%''  '; -- incluido no 10749
                        --
                        v_sql := v_sql || '      AND NFE.COD_NATUREZA_OP <> ''ISE'' ';
                        v_sql := v_sql || '      AND NFE.VLR_UNIT        <> 0 ';
                        ---
                        v_sql := v_sql || '      AND P.COD_ESTAB     = NFE.COD_ESTAB ';
                        v_sql := v_sql || '      AND P.COD_PRODUTO   = NFE.COD_PRODUTO ';
                        v_sql := v_sql || '      AND P.DATA_FISCAL_S > NFE.DATA_FISCAL ';
                        ---
                        v_sql := v_sql || '      AND NFE.IDENT_FIS_JUR = G.IDENT_FIS_JUR ';
                        v_sql := v_sql || '     ) A ';
                        v_sql := v_sql || 'WHERE A.RANK = 1; ';
                        ---
                        v_sql := v_sql || 'BEGIN ';
                        v_sql := v_sql || ' FORALL I IN TAB_E.FIRST..TAB_E.LAST SAVE EXCEPTIONS ';
                        v_sql := v_sql || '   INSERT /*+APPEND*/ INTO ' || vp_tabela_entrada || ' VALUES TAB_E(I); ';
                        v_sql := v_sql || 'EXCEPTION ';
                        v_sql := v_sql || 'WHEN OTHERS THEN  ';
                        v_sql := v_sql || '    ERRORS := SQL%BULK_EXCEPTIONS.COUNT;  ';

                        IF ( v_p_log = 'S' ) THEN --GRAVAR LOG
                            v_sql := v_sql || '    FOR I IN 1..ERRORS LOOP  ';
                            v_sql := v_sql || '      ERR_IDX := SQL%BULK_EXCEPTIONS(I).ERROR_INDEX;  ';
                            v_sql := v_sql || '      ERR_CODE := SQL%BULK_EXCEPTIONS(I).ERROR_CODE;  ';
                            v_sql := v_sql || '      ERR_MSG  := SQLERRM(-SQL%BULK_EXCEPTIONS(I).ERROR_CODE);  ';
                            v_sql :=
                                   v_sql
                                || '      INSERT INTO MSAFI.LOG_GERAL (ORA_ERR_NUMBER1, ORA_ERR_MESG1, COD_EMPRESA, COD_ESTAB, NUM_DOCFIS, DATA_FISCAL, SERIE_DOCFIS, COL14, COL15,  ';
                            v_sql :=
                                   v_sql
                                || '                                  COL16, NUM_ITEM, COL17, COL18, COL19, COL20, COL21, COL22, MOVTO_E_S, NORM_DEV, IDENT_DOCTO, IDENT_FIS_JUR) VALUES  ';
                            v_sql :=
                                   v_sql
                                || '                                  (ERR_CODE, ERR_MSG, TAB_E(ERR_IDX).COD_EMPRESA, ';
                            v_sql :=
                                   v_sql
                                || '                                  TAB_E(ERR_IDX).COD_ESTAB, TAB_E(ERR_IDX).NUM_DOCFIS, TAB_E(ERR_IDX).DATA_FISCAL, TAB_E(ERR_IDX).SERIE_DOCFIS, ';
                            v_sql :=
                                   v_sql
                                || '                                  TAB_E(ERR_IDX).COD_PRODUTO, TAB_E(ERR_IDX).COD_ESTADO, TAB_E(ERR_IDX).DATA_FISCAL_S, TAB_E(ERR_IDX).NUM_ITEM,  ';
                            v_sql :=
                                   v_sql
                                || '                                  ''DPSP_PMC_X_MVA_V2_CPROC'', ''LOAD_ENTRADAS_FILIAL'', '''
                                || v_cod_estab
                                || ''', ''-'',  ';
                            v_sql :=
                                   v_sql
                                || '                                  TO_CHAR(SYSDATE,''DD/MM/YYYY HH24:MI.SS''), '''
                                || v_mproc_id
                                || ''', TAB_E(ERR_IDX).MOVTO_E_S, ';
                            v_sql :=
                                   v_sql
                                || '                                  TAB_E(ERR_IDX).NORM_DEV, TAB_E(ERR_IDX).IDENT_DOCTO, TAB_E(ERR_IDX).IDENT_FIS_JUR);  ';
                            v_sql := v_sql || '    END LOOP;  ';
                            v_sql := v_sql || '    COMMIT; ';
                        ELSE
                            v_sql := v_sql || '    NULL; ';
                        END IF;

                        v_sql := v_sql || 'END;  ';
                        v_sql := v_sql || 'COMMIT; ';
                        ---
                        v_sql := v_sql || ' END; ';

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
                        v_sql := v_sql || '               WHERE E.COD_ESTAB   = A.COD_ESTAB ';
                        v_sql := v_sql || '                 AND E.COD_PRODUTO   = A.COD_PRODUTO ';
                        v_sql := v_sql || '                 AND E.DATA_FISCAL_S = A.DATA_FISCAL_S ) ';

                        EXECUTE IMMEDIATE v_sql;

                        COMMIT;
                        dbms_stats.gather_table_stats ( 'MSAF'
                                                      , v_tab_aux );

                        BEGIN
                            EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || v_tab_aux            INTO v_qtde;
                        EXCEPTION
                            WHEN OTHERS THEN
                                v_qtde := 0;
                        END;

                        IF ( v_limit = 24
                         OR v_qtde = 0 ) THEN
                            --VOLTAR 2 ANOS
                            loga ( '[EXIT][' || v_cod_estab || ']'
                                 , FALSE );
                            EXIT;
                        END IF;
                    END LOOP; --LOOP DA PARTICAO
                END LOOP; --LOOP DO COD_ESTAB

                ---AUDIT DE RECURSOS LIGADO--INI
                IF ( v_audit_pga = 'Y' ) THEN
                    save_audit;
                END IF;
            ---AUDIT DE RECURSOS LIGADO--FIM

            END IF; --**
        ELSIF ( vp_origem = 'CO' ) THEN --COMPRA DIRETA
            v_sql := 'INSERT INTO ' || v_tab_aux;
            v_sql := v_sql || ' SELECT DISTINCT COD_ESTAB, COD_PRODUTO, DATA_FISCAL FROM ' || vp_tab_saida;

            EXECUTE IMMEDIATE v_sql;

            loga ( '[TTL AUX CO][' || SQL%ROWCOUNT || ']'
                 , FALSE );
            COMMIT;

            --APAGAR LINHAS JA CARREGADAS NAs TABs DE ENTRADA ANTERIORES
            v_sql := 'DELETE ' || v_tab_aux || ' A ';
            v_sql := v_sql || ' WHERE EXISTS (SELECT ''Y'' ';
            v_sql := v_sql || '               FROM ' || vp_tab_ent_f || ' E ';
            v_sql := v_sql || '               WHERE E.COD_ESTAB     = A.COD_ESTAB ';
            v_sql := v_sql || '                 AND E.COD_PRODUTO   = A.COD_PRODUTO ';
            v_sql := v_sql || '                 AND E.DATA_FISCAL_S = A.DATA_FISCAL_S ) ';

            EXECUTE IMMEDIATE v_sql;

            loga ( '[LIMPEZA CO F][' || SQL%ROWCOUNT || ']'
                 , FALSE );
            COMMIT;

            v_sql := 'DELETE ' || v_tab_aux || ' A ';
            v_sql := v_sql || ' WHERE EXISTS (SELECT ''Y'' ';
            v_sql := v_sql || '               FROM ' || vp_tab_ent_c || ' E ';
            v_sql := v_sql || '               WHERE E.COD_PRODUTO   = A.COD_PRODUTO ';
            v_sql := v_sql || '                 AND E.DATA_FISCAL_S = A.DATA_FISCAL_S ) ';

            EXECUTE IMMEDIATE v_sql;

            loga ( '[LIMPEZA CO C][' || SQL%ROWCOUNT || ']'
                 , FALSE );
            COMMIT;

            dbms_stats.gather_table_stats ( 'MSAF'
                                          , v_tab_aux );

            --APENAS CONTINUA SE HOUVEREM LINHAS PARA QUERY
            EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || v_tab_aux            INTO v_qtde;

            IF ( v_qtde > 0 ) THEN --**
                v_qtde := 0;

                OPEN c_est FOR 'SELECT DISTINCT COD_ESTAB FROM ' || v_tab_aux;

                LOOP
                    FETCH c_est
                        INTO v_cod_estab;

                    EXIT WHEN c_est%NOTFOUND;

                    v_limit := 0;

                    FOR c_part IN c_partition ( v_dt_part_fim ) LOOP
                        v_limit := v_limit + 1;

                        t_start := dbms_utility.get_time;
                        dbms_application_info.set_module ( $$plsql_unit
                                                         , '7 COMPRA DIRETA [' || v_limit || ']' );

                        v_sql := 'DECLARE TYPE T_BULK_COLLECT_TAB_E IS TABLE OF ' || vp_tabela_entrada || '%ROWTYPE; ';
                        v_sql := v_sql || '        TAB_E T_BULK_COLLECT_TAB_E := T_BULK_COLLECT_TAB_E(); ';
                        v_sql := v_sql || '        ERRORS NUMBER; ';
                        v_sql := v_sql || '        DML_ERRORS EXCEPTION;  ';
                        v_sql := v_sql || '        ERR_IDX INTEGER;  ';
                        v_sql := v_sql || '        ERR_CODE NUMBER;  ';
                        v_sql := v_sql || '        ERR_MSG VARCHAR2(255); ';
                        v_sql := v_sql || 'BEGIN ';
                        ---
                        v_sql := v_sql || 'SELECT ';
                        v_sql := v_sql || '    ' || vp_proc_instance || ' AS PROC_ID, ';
                        v_sql := v_sql || '    A.COD_EMPRESA, ';
                        v_sql := v_sql || '    A.COD_ESTAB, ';
                        v_sql := v_sql || '    A.DATA_FISCAL, ';
                        v_sql := v_sql || '    A.MOVTO_E_S, ';
                        v_sql := v_sql || '    A.NORM_DEV, ';
                        v_sql := v_sql || '    A.IDENT_DOCTO, ';
                        v_sql := v_sql || '    A.IDENT_FIS_JUR, ';
                        v_sql := v_sql || '    A.NUM_DOCFIS, ';
                        v_sql := v_sql || '    A.SERIE_DOCFIS, ';
                        v_sql := v_sql || '    A.SUB_SERIE_DOCFIS, ';
                        v_sql := v_sql || '    A.DISCRI_ITEM, ';
                        v_sql := v_sql || '    A.DATA_FISCAL_S, ';
                        v_sql := v_sql || '    A.NUM_ITEM, ';
                        v_sql := v_sql || '    A.COD_FIS_JUR, ';
                        v_sql := v_sql || '    A.CPF_CGC, ';
                        v_sql := v_sql || '    A.COD_NBM, ';
                        v_sql := v_sql || '    A.COD_CFO, ';
                        v_sql := v_sql || '    A.COD_NATUREZA_OP, ';
                        v_sql := v_sql || '    A.COD_PRODUTO, ';
                        v_sql := v_sql || '    A.VLR_CONTAB_ITEM, ';
                        v_sql := v_sql || '    A.QUANTIDADE, ';
                        v_sql := v_sql || '    A.VLR_UNIT, ';
                        v_sql := v_sql || '    A.COD_SITUACAO_B, ';
                        v_sql := v_sql || '    A.DATA_EMISSAO, ';
                        v_sql := v_sql || '    A.COD_ESTADO, ';
                        v_sql := v_sql || '    A.NUM_CONTROLE_DOCTO, ';
                        v_sql := v_sql || '    A.NUM_AUTENTIC_NFE, ';
                        v_sql :=
                            v_sql || '    ''' || a_cod_empresa ( 'DEFAULT' ).business_unit || ''' AS BUSINESS_UNIT '; ---BUSINESS_UNIT
                        v_sql := v_sql || '    BULK COLLECT INTO TAB_E ';
                        v_sql := v_sql || 'FROM ( ';
                        v_sql := v_sql || '      SELECT ';
                        v_sql := v_sql || '        NFE.COD_EMPRESA, ';
                        v_sql := v_sql || '        NFE.COD_ESTAB, ';
                        v_sql := v_sql || '        NFE.DATA_FISCAL, ';
                        v_sql := v_sql || '        P.DATA_FISCAL_S, ';
                        v_sql := v_sql || '        NFE.MOVTO_E_S, ';
                        v_sql := v_sql || '        NFE.NORM_DEV, ';
                        v_sql := v_sql || '        NFE.IDENT_DOCTO, ';
                        v_sql := v_sql || '        NFE.IDENT_FIS_JUR, ';
                        v_sql := v_sql || '        NFE.NUM_DOCFIS, ';
                        v_sql := v_sql || '        NFE.SERIE_DOCFIS, ';
                        v_sql := v_sql || '        NFE.SUB_SERIE_DOCFIS, ';
                        v_sql := v_sql || '        NFE.DISCRI_ITEM, ';
                        v_sql := v_sql || '        NFE.NUM_ITEM, ';
                        v_sql := v_sql || '        G.COD_FIS_JUR, ';
                        v_sql := v_sql || '        G.CPF_CGC, ';
                        v_sql := v_sql || '        NFE.COD_NBM, ';
                        v_sql := v_sql || '        NFE.COD_CFO, ';
                        v_sql := v_sql || '        NFE.COD_NATUREZA_OP, ';
                        v_sql := v_sql || '        NFE.COD_PRODUTO, ';
                        v_sql := v_sql || '        NFE.VLR_CONTAB_ITEM, ';
                        v_sql := v_sql || '        NFE.QUANTIDADE, ';
                        v_sql := v_sql || '        NFE.VLR_UNIT, ';
                        v_sql := v_sql || '        NFE.COD_SITUACAO_B, ';
                        v_sql := v_sql || '        NFE.DATA_EMISSAO, ';
                        v_sql := v_sql || '        NFE.COD_ESTADO, ';
                        v_sql := v_sql || '        NFE.NUM_CONTROLE_DOCTO, ';
                        v_sql := v_sql || '        NFE.NUM_AUTENTIC_NFE AS NUM_AUTENTIC_NFE, ';
                        v_sql := v_sql || '        G.RAZAO_SOCIAL, ';
                        v_sql := v_sql || '        RANK() OVER( ';
                        v_sql := v_sql || '          PARTITION BY NFE.COD_ESTAB, NFE.COD_PRODUTO, P.DATA_FISCAL_S ';
                        v_sql := v_sql || '              ORDER BY NFE.DATA_FISCAL DESC, ';
                        v_sql := v_sql || '                       NFE.DATA_EMISSAO DESC, ';
                        v_sql := v_sql || '                       NFE.NUM_DOCFIS DESC, ';
                        v_sql := v_sql || '                       NFE.DISCRI_ITEM DESC, ';
                        v_sql := v_sql || '                       NFE.SERIE_DOCFIS) RANK ';
                        v_sql :=
                               v_sql
                            || '    FROM MSAFI.DPSP_NF_ENTRADA PARTITION ('
                            || c_part.nfe_partition_name
                            || ') NFE, ';
                        v_sql := v_sql || '         X04_PESSOA_FIS_JUR G, ';
                        v_sql := v_sql || '         ' || v_tab_aux || ' P ';
                        ---
                        v_sql := v_sql || '    WHERE NFE.COD_EMPRESA = MSAFI.DPSP.EMPRESA ';
                        v_sql := v_sql || '      AND NFE.COD_ESTAB = ''' || v_cod_estab || ''' ';
                        v_sql :=
                               v_sql
                            || '      AND NFE.DATA_FISCAL BETWEEN TO_DATE('''
                            || TO_CHAR ( c_part.inicio_particao
                                       , 'DDMMYYYY' )
                            || ''',''DDMMYYYY'') AND TO_DATE('''
                            || TO_CHAR ( c_part.final_particao
                                       , 'DDMMYYYY' )
                            || ''',''DDMMYYYY'') ';
                        ---
                        v_sql := v_sql || '      AND NFE.SITUACAO     = ''N'' ';
                        v_sql := v_sql || '      AND P.COD_ESTAB      = NFE.COD_ESTAB ';
                        v_sql := v_sql || '      AND P.COD_PRODUTO    = NFE.COD_PRODUTO ';
                        v_sql := v_sql || '      AND P.DATA_FISCAL_S  > NFE.DATA_FISCAL ';
                        ---
                        v_sql :=
                               v_sql
                            || '      AND NFE.COD_CFO     IN (''1102'',''2102'',''1403'',''2403'',''1910'',''2910'') ';
                        --V_SQL := V_SQL || '      AND G.CPF_CGC NOT LIKE ''61412110%'' ';  --FORNECEDOR DSP -- comentado na fin 10749
                        v_sql := v_sql || '      AND G.CPF_CGC NOT LIKE ''334382500%'' '; --FORNECEDOR DP
                        --V_SQL := V_SQL || '      AND NFE.NUM_CONTROLE_DOCTO  NOT LIKE ''C%''  '; -- comentado na fin 10749
                        v_sql := v_sql || '      AND NFE.NUM_CONTROLE_DOCTO  LIKE ''0%''  '; -- incluido no 10749
                        v_sql := v_sql || '      AND NFE.VLR_UNIT        > 0 ';
                        v_sql := v_sql || '      AND NFE.COD_NATUREZA_OP <> ''ISE'' ';
                        ---
                        v_sql := v_sql || '      AND NFE.IDENT_FIS_JUR = G.IDENT_FIS_JUR ';
                        ---
                        v_sql := v_sql || '     ) A ';
                        v_sql := v_sql || 'WHERE A.RANK = 1; ';
                        ---
                        v_sql := v_sql || 'BEGIN ';
                        v_sql := v_sql || ' FORALL I IN TAB_E.FIRST..TAB_E.LAST ';
                        v_sql := v_sql || '   INSERT /*+APPEND*/ INTO ' || vp_tabela_entrada || ' VALUES TAB_E(I); ';
                        v_sql := v_sql || 'EXCEPTION ';
                        v_sql := v_sql || 'WHEN OTHERS THEN  ';
                        v_sql := v_sql || '    ERRORS := SQL%BULK_EXCEPTIONS.COUNT;  ';

                        IF ( v_p_log = 'S' ) THEN --GRAVAR LOG
                            v_sql := v_sql || '    FOR I IN 1..ERRORS LOOP  ';
                            v_sql := v_sql || '      ERR_IDX := SQL%BULK_EXCEPTIONS(I).ERROR_INDEX;  ';
                            v_sql := v_sql || '      ERR_CODE := SQL%BULK_EXCEPTIONS(I).ERROR_CODE;  ';
                            v_sql := v_sql || '      ERR_MSG  := SQLERRM(-SQL%BULK_EXCEPTIONS(I).ERROR_CODE);  ';
                            v_sql :=
                                   v_sql
                                || '      INSERT INTO MSAFI.LOG_GERAL (ORA_ERR_NUMBER1, ORA_ERR_MESG1, COD_EMPRESA, COD_ESTAB, NUM_DOCFIS, DATA_FISCAL, SERIE_DOCFIS, COL14, COL15,  ';
                            v_sql :=
                                   v_sql
                                || '                                  COL16, NUM_ITEM, COL17, COL18, COL19, COL20, COL21, COL22, MOVTO_E_S, NORM_DEV, IDENT_DOCTO, IDENT_FIS_JUR) VALUES  ';
                            v_sql :=
                                   v_sql
                                || '                                  (ERR_CODE, ERR_MSG, TAB_E(ERR_IDX).COD_EMPRESA, ';
                            v_sql :=
                                   v_sql
                                || '                                  TAB_E(ERR_IDX).COD_ESTAB, TAB_E(ERR_IDX).NUM_DOCFIS, TAB_E(ERR_IDX).DATA_FISCAL, TAB_E(ERR_IDX).SERIE_DOCFIS, ';
                            v_sql :=
                                   v_sql
                                || '                                  TAB_E(ERR_IDX).COD_PRODUTO, TAB_E(ERR_IDX).COD_ESTADO, TAB_E(ERR_IDX).DATA_FISCAL_S, TAB_E(ERR_IDX).NUM_ITEM,  ';
                            v_sql :=
                                   v_sql
                                || '                                  ''DPSP_PMC_X_MVA_V2_CPROC'', ''LOAD_ENTRADAS_FILIAL'', '''
                                || v_cod_estab
                                || ''', ''-'',  ';
                            v_sql :=
                                   v_sql
                                || '                                  TO_CHAR(SYSDATE,''DD/MM/YYYY HH24:MI.SS''), '''
                                || v_mproc_id
                                || ''', TAB_E(ERR_IDX).MOVTO_E_S, ';
                            v_sql :=
                                   v_sql
                                || '                                  TAB_E(ERR_IDX).NORM_DEV, TAB_E(ERR_IDX).IDENT_DOCTO, TAB_E(ERR_IDX).IDENT_FIS_JUR);  ';
                            v_sql := v_sql || '    END LOOP;  ';
                            v_sql := v_sql || '    COMMIT; ';
                        ELSE
                            v_sql := v_sql || '    NULL; ';
                        END IF;

                        v_sql := v_sql || 'END;  ';
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
                        v_sql := v_sql || '               WHERE E.COD_ESTAB     = A.COD_ESTAB ';
                        v_sql := v_sql || '                 AND E.COD_PRODUTO   = A.COD_PRODUTO ';
                        v_sql := v_sql || '                 AND E.DATA_FISCAL_S = A.DATA_FISCAL_S ) ';

                        EXECUTE IMMEDIATE v_sql;

                        COMMIT;
                        dbms_stats.gather_table_stats ( 'MSAF'
                                                      , v_tab_aux );

                        BEGIN
                            EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || v_tab_aux            INTO v_qtde;
                        EXCEPTION
                            WHEN OTHERS THEN
                                v_qtde := 0;
                        END;

                        IF ( v_limit = 24
                         OR v_qtde = 0 ) THEN
                            --VOLTAR 2 ANOS
                            loga ( '[EXIT][' || v_cod_estab || ']'
                                 , FALSE );
                            EXIT;
                        END IF;
                    END LOOP; --LOOP DA PARTICAO
                END LOOP; --LOOP DO COD_ESTAB

                ---AUDIT DE RECURSOS LIGADO--INI
                IF ( v_audit_pga = 'Y' ) THEN
                    save_audit;
                END IF;
            ---AUDIT DE RECURSOS LIGADO--FIM

            END IF; --**
        END IF;
    END; --PROCEDURE LOAD_ENTRADAS

    --PROCEDURE PARA CRIAR TABELAS TEMP DE ALIQ E PMC
    PROCEDURE load_aliq_pmc ( vp_proc_id IN NUMBER
                            , vp_tabela_saida IN VARCHAR2
                            , vp_uf IN VARCHAR2
                            , vp_data_fim IN DATE )
    IS
        v_sql VARCHAR2 ( 2000 );
        v_qtde INTEGER;
        c_aliq SYS_REFCURSOR;

        TYPE cur_tab_aliq IS RECORD
        (
            cod_produto VARCHAR2 ( 25 )
          , data_fiscal DATE
          , aliq_st VARCHAR2 ( 4 )
        );

        TYPE c_tab_aliq IS TABLE OF cur_tab_aliq;

        tab_aliq c_tab_aliq;
    BEGIN
        EXECUTE IMMEDIATE 'TRUNCATE TABLE DP$P_PMC_SAIDA';

        EXECUTE IMMEDIATE 'TRUNCATE TABLE DP$P_PMC_ALIQ';

        dbms_application_info.set_module ( v_module
                                         , '4 LOAD_ALIQ' );

        msafi.upd_ps_translate ( 'DSP_ALIQ_ICMS' ); --ATUALIZAR TRANSLATES EM TAB LOCAL

        EXECUTE IMMEDIATE
            'INSERT INTO DP$P_PMC_SAIDA (SELECT DISTINCT COD_PRODUTO, DATA_FISCAL FROM ' || vp_tabela_saida || ') ';

        COMMIT;

        v_sql := 'SELECT /*+DRIVING_SITE(PS)*/ PS.INV_ITEM_ID AS COD_PRODUTO, PS.DATA_FISCAL, PS.ALIQ_INTERNA ';
        v_sql := v_sql || 'FROM ( ';
        v_sql :=
               v_sql
            || '                 SELECT T.INV_ITEM_ID, T.EFFDT, MSAFI.PS_TRANSLATE(''DSP_ALIQ_ICMS'',T.DSP_ALIQ_ICMS) AS ALIQ_INTERNA, S.DATA_FISCAL, ';
        v_sql :=
               v_sql
            || '                     RANK() OVER (PARTITION BY T.SETID, T.INV_ITEM_ID, S.DATA_FISCAL ORDER BY T.EFFDT DESC) RANK ';

        IF ( vp_data_fim < TO_DATE ( '01012017'
                                   , 'DDMMYYYY' ) ) THEN --PERIODOS ANTERIORES ESTAO EM OUTRA TABELA
            v_sql := v_sql || '             FROM MSAFI.PS_DSP_LN_MVA_HIS T, ';
        ELSE
            v_sql := v_sql || '             FROM MSAFI.PS_DSP_ITEM_LN_MVA T, ';
        END IF;

        v_sql := v_sql || '                      DP$P_PMC_SAIDA S ';
        v_sql := v_sql || '                 WHERE T.SETID = ''GERAL'' ';
        v_sql := v_sql || '                 AND T.INV_ITEM_ID = S.COD_PRODUTO ';
        v_sql := v_sql || '                 AND T.CRIT_STATE_TO_PBL = T.CRIT_STATE_FR_PBL ';

        v_sql :=
               v_sql
            || '                 and MSAFI.PS_TRANSLATE(''DSP_ALIQ_ICMS'',T.DSP_ALIQ_ICMS) <> ''<VLR INVALIDO>'' ';

        v_sql := v_sql || '                 AND T.CRIT_STATE_TO_PBL = ''' || vp_uf || ''' ';
        v_sql := v_sql || '                 AND T.EFFDT <= S.DATA_FISCAL ';
        v_sql := v_sql || '      ) PS ';
        v_sql := v_sql || 'WHERE PS.RANK = 1 ';

        OPEN c_aliq FOR v_sql;

        LOOP
            FETCH c_aliq
                BULK COLLECT INTO tab_aliq;

            FORALL i IN tab_aliq.FIRST .. tab_aliq.LAST
                INSERT INTO dp$p_pmc_aliq
                VALUES tab_aliq ( i );

            tab_aliq.delete;

            EXIT WHEN c_aliq%NOTFOUND;
        END LOOP;

        COMMIT;

        CLOSE c_aliq;

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , 'DP$P_PMC_ALIQ' );

        SELECT COUNT ( * )
          INTO v_qtde
          FROM dp$p_pmc_aliq; --GTT

        loga ( '[DP$P_PMC_ALIQ][OK][' || v_qtde || ']'
             , FALSE );

        -------------------------------------------------------------------------------------
        dbms_application_info.set_module ( v_module
                                         , '5 LOAD_PMC_VLR' );

        EXECUTE IMMEDIATE 'TRUNCATE TABLE DP$P_PMC_VLR';

        FOR t IN ( SELECT ps.cod_produto
                        , ps.data_fiscal
                        , ps.dsp_pmc AS vlr_pmc
                     FROM (SELECT a.setid
                                , a.inv_item_id AS cod_produto
                                , a.dsp_aliq_icms_id
                                , a.unit_of_measure
                                , a.effdt
                                , a.dsp_pmc
                                , p.data_fiscal
                                , RANK ( )
                                      OVER ( PARTITION BY a.setid
                                                        , a.inv_item_id
                                                        , a.dsp_aliq_icms_id
                                                        , a.unit_of_measure
                                             ORDER BY a.effdt DESC )
                                      RANK
                             FROM msafi.ps_dsp_preco_item a
                                , dp$p_pmc_aliq p
                            WHERE a.setid = 'GERAL'
                              AND a.unit_of_measure = 'UN'
                              AND a.inv_item_id = p.cod_produto
                              AND a.dsp_aliq_icms_id = p.aliq_st
                              AND a.effdt <= p.data_fiscal) ps
                    WHERE ps.RANK = 1 ) LOOP
            INSERT INTO dp$p_pmc_vlr
                 VALUES ( t.cod_produto
                        , t.data_fiscal
                        , t.vlr_pmc );
        END LOOP;

        COMMIT;

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , 'DP$P_PMC_VLR' );

        SELECT COUNT ( * )
          INTO v_qtde
          FROM dp$p_pmc_vlr; --GTT

        loga ( '[DP$P_PMC_VLR][OK][' || v_qtde || ']'
             , FALSE );

        -------------------------------------------------------------------------------------
        EXECUTE IMMEDIATE 'TRUNCATE TABLE DP$P_PMC_STATUS';

        v_sql := 'BEGIN ';
        ---
        v_sql := v_sql || '    FOR T IN (SELECT /*+DRIVING_SITE(PS)*/ PS.INV_ITEM_ID AS COD_PRODUTO, PS.STATUS ';
        v_sql := v_sql || '              FROM ( ';
        v_sql :=
               v_sql
            || '                 SELECT A.INV_ITEM_ID, DECODE(A.LIBER_CNTR_DSP,''C'',''CONTROLADO'',''L'',''LIBERADO'',''OUTRO'') STATUS ';
        v_sql := v_sql || '                 FROM MSAFI.PS_ATRB_OPER_DSP A, ';
        v_sql := v_sql || '                     (SELECT DISTINCT COD_PRODUTO FROM ' || vp_tabela_saida || ') S ';
        v_sql := v_sql || '                 WHERE A.SETID = ''GERAL'' ';
        v_sql := v_sql || '                 AND A.INV_ITEM_ID = S.COD_PRODUTO ';
        v_sql := v_sql || '                   ) PS ) LOOP ';
        ---
        v_sql := v_sql || '        INSERT INTO DP$P_PMC_STATUS VALUES (T.COD_PRODUTO, T.STATUS); ';
        ---
        v_sql := v_sql || '    END LOOP; ';
        ---
        v_sql := v_sql || 'COMMIT; ';
        v_sql := v_sql || 'END; ';
        dbms_application_info.set_module ( v_module
                                         , '6 LOAD_STATUS' );

        EXECUTE IMMEDIATE v_sql;

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , 'DP$P_PMC_STATUS' );

        SELECT COUNT ( * )
          INTO v_qtde
          FROM dp$p_pmc_status; --GTT

        loga ( '[DP$P_PMC_STATUS][OK][' || v_qtde || ']'
             , FALSE );
    END;

    PROCEDURE get_entradas_cd ( vp_proc_id IN NUMBER
                              , vp_filial IN VARCHAR2
                              , vp_cd IN VARCHAR2
                              , vp_data_ini IN VARCHAR2
                              , vp_data_fim IN VARCHAR2
                              , vp_tab_entrada_c IN VARCHAR2
                              , vp_tabela_saida IN VARCHAR2
                              , vp_tabela_pmc_mva IN VARCHAR2
                              , vp_data_hora_ini IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 6000 );
        errors NUMBER;
        dml_errors EXCEPTION;
        err_idx INTEGER;
        err_code NUMBER;
        err_msg VARCHAR2 ( 255 );
        c_pmc SYS_REFCURSOR;

        TYPE t_tab_pmc IS RECORD
        (
            proc_id NUMBER ( 30 )
          , cod_empresa VARCHAR2 ( 3 )
          , cod_estab VARCHAR2 ( 6 )
          , num_docfis VARCHAR2 ( 12 )
          , data_fiscal DATE
          , serie_docfis VARCHAR2 ( 3 )
          , cod_produto VARCHAR2 ( 35 )
          , cod_estado VARCHAR2 ( 2 )
          , docto VARCHAR2 ( 5 )
          , num_item NUMBER ( 5 )
          , descr_item VARCHAR2 ( 50 )
          , quantidade NUMBER ( 12, 4 )
          , cod_nbm VARCHAR2 ( 10 )
          , cod_cfo VARCHAR2 ( 4 )
          , grupo_produto VARCHAR2 ( 30 )
          , vlr_desconto NUMBER ( 17, 2 )
          , vlr_contabil NUMBER ( 17, 2 )
          , base_unit_s_venda NUMBER ( 17, 2 )
          , num_autentic_nfe VARCHAR2 ( 80 )
          , lista VARCHAR2 ( 1 )
          , ---
            cod_estab_e VARCHAR2 ( 6 )
          , data_fiscal_e DATE
          , movto_e_s_e VARCHAR2 ( 1 )
          , norm_dev_e VARCHAR2 ( 1 )
          , ident_docto_e VARCHAR2 ( 12 )
          , ident_fis_jur_e VARCHAR2 ( 12 )
          , sub_serie_docfis_e VARCHAR2 ( 2 )
          , discri_item_e VARCHAR2 ( 46 )
          , data_emissao_e DATE
          , num_docfis_e VARCHAR2 ( 12 )
          , serie_docfis_e VARCHAR2 ( 3 )
          , num_item_e NUMBER ( 5 )
          , cod_fis_jur_e VARCHAR2 ( 14 )
          , cpf_cgc_e VARCHAR2 ( 14 )
          , cod_nbm_e VARCHAR2 ( 10 )
          , cod_cfo_e VARCHAR2 ( 4 )
          , cod_natureza_op_e VARCHAR2 ( 3 )
          , cod_produto_e VARCHAR2 ( 35 )
          , vlr_contab_item_e NUMBER ( 17, 2 )
          , quantidade_e NUMBER ( 12, 4 )
          , vlr_unit_e NUMBER ( 17, 2 )
          , cod_situacao_b_e VARCHAR2 ( 2 )
          , cod_estado_e VARCHAR2 ( 2 )
          , num_controle_docto_e VARCHAR2 ( 12 )
          , num_autentic_nfe_e VARCHAR2 ( 80 )
          , base_icms_unit_e NUMBER ( 17, 2 )
          , vlr_icms_unit_e NUMBER ( 17, 2 )
          , aliq_icms_e NUMBER ( 17, 2 )
          , base_st_unit_e NUMBER ( 17, 2 )
          , vlr_icms_st_unit_e NUMBER ( 17, 2 )
          , vlr_icms_st_unit_aux NUMBER ( 17, 2 )
          , stat_liber_cntr VARCHAR2 ( 10 )
        );

        TYPE c_tab_pmc IS TABLE OF t_tab_pmc;

        tab_pmc c_tab_pmc;
    BEGIN
        v_sql := ' SELECT ';
        v_sql := v_sql || ' ''' || vp_proc_id || ''' AS PROC_ID, ';
        v_sql := v_sql || ' ''' || mcod_empresa || ''' AS COD_EMPRESA, ';
        v_sql := v_sql || ' A.COD_ESTAB, ';
        v_sql := v_sql || ' A.NUM_DOCFIS, ';
        v_sql := v_sql || ' A.DATA_FISCAL, ';
        v_sql := v_sql || ' A.SERIE_DOCFIS, ';
        v_sql := v_sql || ' A.COD_PRODUTO, ';
        v_sql := v_sql || ' A.COD_ESTADO, ';
        v_sql := v_sql || ' A.DOCTO, ';
        v_sql := v_sql || ' A.NUM_ITEM, ';
        v_sql := v_sql || ' A.DESCR_ITEM, ';
        v_sql := v_sql || ' A.QUANTIDADE, ';
        v_sql := v_sql || ' A.COD_NBM, ';
        v_sql := v_sql || ' A.COD_CFO, ';
        v_sql := v_sql || ' A.GRUPO_PRODUTO, ';
        v_sql := v_sql || ' A.VLR_DESCONTO, ';
        v_sql := v_sql || ' A.VLR_CONTABIL, ';
        v_sql := v_sql || ' A.BASE_UNIT_S_VENDA, ';
        v_sql := v_sql || ' A.NUM_AUTENTIC_NFE, ';
        v_sql := v_sql || ' A.LISTA, ';
        ---
        v_sql := v_sql || ' B.COD_ESTAB AS COD_ESTAB_E, ';
        v_sql := v_sql || ' B.DATA_FISCAL AS DATA_FISCAL_E, ';
        v_sql := v_sql || ' B.MOVTO_E_S AS MOVTO_E_S_E, ';
        v_sql := v_sql || ' B.NORM_DEV AS NORM_DEV_E, ';
        v_sql := v_sql || ' B.IDENT_DOCTO AS IDENT_DOCTO_E, ';
        v_sql := v_sql || ' B.IDENT_FIS_JUR AS IDENT_FIS_JUR_E, ';
        v_sql := v_sql || ' B.SUB_SERIE_DOCFIS AS SUB_SERIE_DOCFIS_E, ';
        v_sql := v_sql || ' B.DISCRI_ITEM AS DISCRI_ITEM_E, ';
        v_sql := v_sql || ' B.DATA_EMISSAO AS DATA_EMISSAO_E, ';
        v_sql := v_sql || ' B.NUM_DOCFIS AS NUM_DOCFIS_E, ';
        v_sql := v_sql || ' B.SERIE_DOCFIS AS SERIE_DOCFIS_E, ';
        v_sql := v_sql || ' B.NUM_ITEM AS NUM_ITEM_E, ';
        v_sql := v_sql || ' B.COD_FIS_JUR AS COD_FIS_JUR_E, ';
        v_sql := v_sql || ' B.CPF_CGC AS CPF_CGC_E, ';
        v_sql := v_sql || ' B.COD_NBM AS COD_NBM_E, ';
        v_sql := v_sql || ' B.COD_CFO AS COD_CFO_E, ';
        v_sql := v_sql || ' B.COD_NATUREZA_OP AS COD_NATUREZA_OP_E, ';
        v_sql := v_sql || ' B.COD_PRODUTO AS COD_PRODUTO_E, ';
        v_sql := v_sql || ' B.VLR_CONTAB_ITEM AS VLR_CONTAB_ITEM_E, ';
        v_sql := v_sql || ' B.QUANTIDADE AS QUANTIDADE_E, ';
        v_sql := v_sql || ' B.VLR_UNIT AS VLR_UNIT_E, ';
        v_sql := v_sql || ' B.COD_SITUACAO_B AS COD_SITUACAO_B_E, ';
        v_sql := v_sql || ' B.COD_ESTADO AS COD_ESTADO_E, ';
        v_sql := v_sql || ' B.NUM_CONTROLE_DOCTO AS NUM_CONTROLE_DOCTO_E, ';
        v_sql := v_sql || ' B.NUM_AUTENTIC_NFE AS NUM_AUTENTIC_NFE_E, ';
        ---
        v_sql := v_sql || ' C.BASE_ICMS_UNIT, ';
        v_sql := v_sql || ' C.VLR_ICMS_UNIT, ';
        v_sql := v_sql || ' C.ALIQ_ICMS, ';
        v_sql := v_sql || ' C.BASE_ST_UNIT, ';
        v_sql := v_sql || ' C.VLR_ICMS_ST_UNIT, ';
        v_sql := v_sql || ' C.VLR_ICMS_ST_UNIT_AUX, ';
        ---
        v_sql := v_sql || ' E.STATUS ';
        ---
        v_sql := v_sql || ' FROM ' || vp_tabela_saida || ' A, ';
        v_sql := v_sql || '      ' || vp_tab_entrada_c || ' B, ';
        v_sql := v_sql || '      MSAF.DP$P_PMC_TAX C, ';
        v_sql := v_sql || '      MSAF.DP$P_PMC_STATUS E ';
        v_sql := v_sql || ' WHERE A.PROC_ID       = ''' || vp_proc_id || ''' ';
        --V_SQL := V_SQL || '   AND A.COD_ESTAB     = ''' || VP_FILIAL || ''' ';
        ---
        v_sql := v_sql || '   AND B.PROC_ID       = A.PROC_ID ';
        --V_SQL := V_SQL || '   AND B.COD_EMPRESA   = A.COD_EMPRESA ';
        v_sql := v_sql || '   AND B.DATA_FISCAL_S = A.DATA_FISCAL ';
        v_sql := v_sql || '   AND B.COD_ESTAB     = ''' || vp_cd || ''' ';
        v_sql := v_sql || '   AND B.COD_PRODUTO   = A.COD_PRODUTO ';
        ---
        v_sql := v_sql || '   AND B.PROC_ID            = C.PROC_ID (+) ';
        v_sql := v_sql || '   AND B.BUSINESS_UNIT      = C.BUSINESS_UNIT (+)';
        v_sql := v_sql || '   AND B.NUM_CONTROLE_DOCTO = C.NF_BRL_ID (+)';
        v_sql := v_sql || '   AND B.NUM_ITEM           = C.NF_BRL_LINE_NUM (+)';
        ---
        v_sql := v_sql || '   AND A.COD_PRODUTO = E.COD_PRODUTO (+) ';
        ---
        v_sql := v_sql || '   AND NOT EXISTS (SELECT ''Y'' ';
        v_sql := v_sql || '                   FROM ' || vp_tabela_pmc_mva || ' C ';
        v_sql := v_sql || '                   WHERE C.PROC_ID      = A.PROC_ID ';
        v_sql := v_sql || '                     AND C.COD_EMPRESA  = A.COD_EMPRESA ';
        v_sql := v_sql || '                     AND C.COD_ESTAB    = A.COD_ESTAB ';
        v_sql := v_sql || '                     AND C.NUM_DOCFIS   = A.NUM_DOCFIS ';
        v_sql := v_sql || '                     AND C.DATA_FISCAL  = A.DATA_FISCAL ';
        v_sql := v_sql || '                     AND C.SERIE_DOCFIS = A.SERIE_DOCFIS ';
        v_sql := v_sql || '                     AND C.COD_PRODUTO  = A.COD_PRODUTO ';
        v_sql := v_sql || '                     AND C.COD_ESTADO   = A.COD_ESTADO ';
        v_sql := v_sql || '                     AND C.DOCTO        = A.DOCTO ';
        v_sql := v_sql || '                     AND C.NUM_ITEM     = A.NUM_ITEM)';

        OPEN c_pmc FOR v_sql;

        LOOP
            FETCH c_pmc
                BULK COLLECT INTO tab_pmc;

            BEGIN --(1)
                FORALL i IN tab_pmc.FIRST .. tab_pmc.LAST SAVE EXCEPTIONS
                    EXECUTE IMMEDIATE
                           'INSERT INTO '
                        || vp_tabela_pmc_mva
                        || ' VALUES (:1, :2, :3, :4, :5, :6, :7, :8, :9, :10, '
                        || ' :11, :12, :13, :14, :15, :16, :17, :18, :19, :20, :21, :22, :23, :24, :25, :26, :27, :28, :29, :30, '
                        || ' :31, :32, :33, :34, :35, :36, :37, :38, :39, :40, :41, :42, :43, :44, :45, :46, :47, :48, :49, :50, :51, :52) '
                        USING tab_pmc ( i ).proc_id
                            , tab_pmc ( i ).cod_empresa
                            , tab_pmc ( i ).cod_estab
                            , tab_pmc ( i ).num_docfis
                            , tab_pmc ( i ).data_fiscal
                            , tab_pmc ( i ).serie_docfis
                            , tab_pmc ( i ).cod_produto
                            , tab_pmc ( i ).cod_estado
                            , tab_pmc ( i ).docto
                            , tab_pmc ( i ).num_item
                            , tab_pmc ( i ).descr_item
                            , tab_pmc ( i ).quantidade
                            , tab_pmc ( i ).cod_nbm
                            , tab_pmc ( i ).cod_cfo
                            , tab_pmc ( i ).grupo_produto
                            , tab_pmc ( i ).vlr_desconto
                            , tab_pmc ( i ).vlr_contabil
                            , tab_pmc ( i ).base_unit_s_venda
                            , tab_pmc ( i ).num_autentic_nfe
                            , tab_pmc ( i ).lista
                            , tab_pmc ( i ).cod_estab_e
                            , tab_pmc ( i ).data_fiscal_e
                            , tab_pmc ( i ).movto_e_s_e
                            , tab_pmc ( i ).norm_dev_e
                            , tab_pmc ( i ).ident_docto_e
                            , tab_pmc ( i ).ident_fis_jur_e
                            , tab_pmc ( i ).sub_serie_docfis_e
                            , tab_pmc ( i ).discri_item_e
                            , tab_pmc ( i ).data_emissao_e
                            , tab_pmc ( i ).num_docfis_e
                            , tab_pmc ( i ).serie_docfis_e
                            , tab_pmc ( i ).num_item_e
                            , tab_pmc ( i ).cod_fis_jur_e
                            , tab_pmc ( i ).cpf_cgc_e
                            , tab_pmc ( i ).cod_nbm_e
                            , tab_pmc ( i ).cod_cfo_e
                            , tab_pmc ( i ).cod_natureza_op_e
                            , tab_pmc ( i ).cod_produto_e
                            , tab_pmc ( i ).vlr_contab_item_e
                            , tab_pmc ( i ).quantidade_e
                            , tab_pmc ( i ).vlr_unit_e
                            , tab_pmc ( i ).cod_situacao_b_e
                            , tab_pmc ( i ).cod_estado_e
                            , tab_pmc ( i ).num_controle_docto_e
                            , tab_pmc ( i ).num_autentic_nfe_e
                            , tab_pmc ( i ).base_icms_unit_e
                            , tab_pmc ( i ).vlr_icms_unit_e
                            , tab_pmc ( i ).aliq_icms_e
                            , tab_pmc ( i ).base_st_unit_e
                            , tab_pmc ( i ).vlr_icms_st_unit_e
                            , tab_pmc ( i ).vlr_icms_st_unit_aux
                            , tab_pmc ( i ).stat_liber_cntr;
            EXCEPTION
                WHEN OTHERS THEN
                    errors := SQL%BULK_EXCEPTIONS.COUNT;

                    IF ( v_p_log = 'S' ) THEN --GRAVAR LOG
                        FOR i IN 1 .. errors LOOP
                            err_idx := SQL%BULK_EXCEPTIONS ( i ).ERROR_INDEX;
                            err_code := SQL%BULK_EXCEPTIONS ( i ).ERROR_CODE;
                            err_msg := SQLERRM ( -SQL%BULK_EXCEPTIONS ( i ).ERROR_CODE );

                            INSERT INTO msafi.log_geral ( ora_err_number1
                                                        , ora_err_mesg1
                                                        , cod_empresa
                                                        , cod_estab
                                                        , num_docfis
                                                        , data_fiscal
                                                        , serie_docfis
                                                        , col14
                                                        , col15
                                                        , col16
                                                        , num_item
                                                        , col17
                                                        , col18
                                                        , col19
                                                        , col20
                                                        , col21
                                                        , col22 )
                                 VALUES ( err_code
                                        , err_msg
                                        , tab_pmc ( err_idx ).cod_empresa
                                        , tab_pmc ( err_idx ).cod_estab
                                        , tab_pmc ( err_idx ).num_docfis
                                        , tab_pmc ( err_idx ).data_fiscal
                                        , tab_pmc ( err_idx ).serie_docfis
                                        , tab_pmc ( err_idx ).cod_produto
                                        , tab_pmc ( err_idx ).cod_estado
                                        , tab_pmc ( err_idx ).docto
                                        , tab_pmc ( err_idx ).num_item
                                        , 'DPSP_PMC_X_MVA_V2_CPROC'
                                        , 'GET_ENTRADAS_CD'
                                        , vp_cd
                                        , '-'
                                        , TO_CHAR ( SYSDATE
                                                  , 'DD/MM/YYYY HH24:MI.SS' )
                                        , vp_proc_id );
                        END LOOP;

                        COMMIT;
                    ELSE
                        NULL;
                    END IF;
            END; --(1)

            tab_pmc.delete;

            EXIT WHEN c_pmc%NOTFOUND;
        END LOOP;

        COMMIT;

        CLOSE c_pmc;
    END; --GET_ENTRADAS_CD

    PROCEDURE get_entradas_filial ( vp_proc_id IN NUMBER
                                  , vp_filial IN VARCHAR2
                                  , vp_cd IN VARCHAR2
                                  , vp_data_ini IN VARCHAR2
                                  , vp_data_fim IN VARCHAR2
                                  , vp_tabela_entrada IN VARCHAR2
                                  , vp_tabela_saida IN VARCHAR2
                                  , vp_tabela_pmc_mva IN VARCHAR2
                                  , vp_data_hora_ini IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 6000 );
        errors NUMBER;
        dml_errors EXCEPTION;
        err_idx INTEGER;
        err_code NUMBER;
        err_msg VARCHAR2 ( 255 );
        c_pmc SYS_REFCURSOR;

        TYPE t_tab_pmc IS RECORD
        (
            proc_id NUMBER ( 30 )
          , cod_empresa VARCHAR2 ( 3 )
          , cod_estab VARCHAR2 ( 6 )
          , num_docfis VARCHAR2 ( 12 )
          , data_fiscal DATE
          , serie_docfis VARCHAR2 ( 3 )
          , cod_produto VARCHAR2 ( 35 )
          , cod_estado VARCHAR2 ( 2 )
          , docto VARCHAR2 ( 5 )
          , num_item NUMBER ( 5 )
          , descr_item VARCHAR2 ( 50 )
          , quantidade NUMBER ( 12, 4 )
          , cod_nbm VARCHAR2 ( 10 )
          , cod_cfo VARCHAR2 ( 4 )
          , grupo_produto VARCHAR2 ( 30 )
          , vlr_desconto NUMBER ( 17, 2 )
          , vlr_contabil NUMBER ( 17, 2 )
          , base_unit_s_venda NUMBER ( 17, 2 )
          , num_autentic_nfe VARCHAR2 ( 80 )
          , lista VARCHAR2 ( 1 )
          , ---
            cod_estab_e VARCHAR2 ( 6 )
          , data_fiscal_e DATE
          , movto_e_s_e VARCHAR2 ( 1 )
          , norm_dev_e VARCHAR2 ( 1 )
          , ident_docto_e VARCHAR2 ( 12 )
          , ident_fis_jur_e VARCHAR2 ( 12 )
          , sub_serie_docfis_e VARCHAR2 ( 2 )
          , discri_item_e VARCHAR2 ( 46 )
          , data_emissao_e DATE
          , num_docfis_e VARCHAR2 ( 12 )
          , serie_docfis_e VARCHAR2 ( 3 )
          , num_item_e NUMBER ( 5 )
          , cod_fis_jur_e VARCHAR2 ( 14 )
          , cpf_cgc_e VARCHAR2 ( 14 )
          , cod_nbm_e VARCHAR2 ( 10 )
          , cod_cfo_e VARCHAR2 ( 4 )
          , cod_natureza_op_e VARCHAR2 ( 3 )
          , cod_produto_e VARCHAR2 ( 35 )
          , vlr_contab_item_e NUMBER ( 17, 2 )
          , quantidade_e NUMBER ( 12, 4 )
          , vlr_unit_e NUMBER ( 17, 2 )
          , cod_situacao_b_e VARCHAR2 ( 2 )
          , cod_estado_e VARCHAR2 ( 2 )
          , num_controle_docto_e VARCHAR2 ( 12 )
          , num_autentic_nfe_e VARCHAR2 ( 80 )
          , base_icms_unit_e NUMBER ( 17, 2 )
          , vlr_icms_unit_e NUMBER ( 17, 2 )
          , aliq_icms_e NUMBER ( 17, 2 )
          , base_st_unit_e NUMBER ( 17, 2 )
          , vlr_icms_st_unit_e NUMBER ( 17, 2 )
          , vlr_icms_st_unit_aux NUMBER ( 17, 2 )
          , stat_liber_cntr VARCHAR2 ( 10 )
        );

        TYPE c_tab_pmc IS TABLE OF t_tab_pmc;

        tab_pmc c_tab_pmc;
    BEGIN
        v_sql := ' SELECT ';
        v_sql := v_sql || ' ''' || vp_proc_id || ''' AS PROC_ID, ';
        v_sql := v_sql || ' ''' || mcod_empresa || ''' AS COD_EMPRESA, ';
        v_sql := v_sql || ' A.COD_ESTAB, ';
        v_sql := v_sql || ' A.NUM_DOCFIS, ';
        v_sql := v_sql || ' A.DATA_FISCAL, ';
        v_sql := v_sql || ' A.SERIE_DOCFIS, ';
        v_sql := v_sql || ' A.COD_PRODUTO, ';
        v_sql := v_sql || ' A.COD_ESTADO, ';
        v_sql := v_sql || ' A.DOCTO, ';
        v_sql := v_sql || ' A.NUM_ITEM, ';
        v_sql := v_sql || ' A.DESCR_ITEM, ';
        v_sql := v_sql || ' A.QUANTIDADE, ';
        v_sql := v_sql || ' A.COD_NBM, ';
        v_sql := v_sql || ' A.COD_CFO, ';
        v_sql := v_sql || ' A.GRUPO_PRODUTO, ';
        v_sql := v_sql || ' A.VLR_DESCONTO, ';
        v_sql := v_sql || ' A.VLR_CONTABIL, ';
        v_sql := v_sql || ' A.BASE_UNIT_S_VENDA, ';
        v_sql := v_sql || ' A.NUM_AUTENTIC_NFE, ';
        v_sql := v_sql || ' A.LISTA, ';
        ---
        v_sql := v_sql || ' B.COD_ESTAB AS COD_ESTAB_E, ';
        v_sql := v_sql || ' B.DATA_FISCAL AS DATA_FISCAL_E, ';
        v_sql := v_sql || ' B.MOVTO_E_S AS MOVTO_E_S_E, ';
        v_sql := v_sql || ' B.NORM_DEV AS NORM_DEV_E, ';
        v_sql := v_sql || ' B.IDENT_DOCTO AS IDENT_DOCTO_E, ';
        v_sql := v_sql || ' B.IDENT_FIS_JUR AS IDENT_FIS_JUR_E, ';
        v_sql := v_sql || ' B.SUB_SERIE_DOCFIS AS SUB_SERIE_DOCFIS_E, ';
        v_sql := v_sql || ' B.DISCRI_ITEM AS DISCRI_ITEM_E, ';
        v_sql := v_sql || ' B.DATA_EMISSAO AS DATA_EMISSAO_E, ';
        v_sql := v_sql || ' B.NUM_DOCFIS AS NUM_DOCFIS_E, ';
        v_sql := v_sql || ' B.SERIE_DOCFIS AS SERIE_DOCFIS_E, ';
        v_sql := v_sql || ' B.NUM_ITEM AS NUM_ITEM_E, ';
        v_sql := v_sql || ' B.COD_FIS_JUR AS COD_FIS_JUR_E, ';
        v_sql := v_sql || ' B.CPF_CGC AS CPF_CGC_E, ';
        v_sql := v_sql || ' B.COD_NBM AS COD_NBM_E, ';
        v_sql := v_sql || ' B.COD_CFO AS COD_CFO_E, ';
        v_sql := v_sql || ' B.COD_NATUREZA_OP AS COD_NATUREZA_OP_E, ';
        v_sql := v_sql || ' B.COD_PRODUTO AS COD_PRODUTO_E, ';
        v_sql := v_sql || ' B.VLR_CONTAB_ITEM AS VLR_CONTAB_ITEM_E, ';
        v_sql := v_sql || ' B.QUANTIDADE AS QUANTIDADE_E, ';
        v_sql := v_sql || ' B.VLR_UNIT AS VLR_UNIT_E, ';
        v_sql := v_sql || ' B.COD_SITUACAO_B AS COD_SITUACAO_B_E, ';
        v_sql := v_sql || ' B.COD_ESTADO AS COD_ESTADO_E, ';
        v_sql := v_sql || ' B.NUM_CONTROLE_DOCTO AS NUM_CONTROLE_DOCTO_E, ';
        v_sql := v_sql || ' B.NUM_AUTENTIC_NFE AS NUM_AUTENTIC_NFE_E, ';
        ---
        v_sql := v_sql || ' C.BASE_ICMS_UNIT, ';
        v_sql := v_sql || ' C.VLR_ICMS_UNIT, ';
        v_sql := v_sql || ' C.ALIQ_ICMS, ';
        v_sql := v_sql || ' C.BASE_ST_UNIT, ';
        v_sql := v_sql || ' C.VLR_ICMS_ST_UNIT, ';
        v_sql := v_sql || ' C.VLR_ICMS_ST_UNIT_AUX, ';
        ---
        v_sql := v_sql || ' E.STATUS ';
        ---
        v_sql := v_sql || ' FROM ' || vp_tabela_saida || ' A, ';
        v_sql := v_sql || '      ' || vp_tabela_entrada || ' B, ';
        v_sql := v_sql || '      MSAF.DP$P_PMC_TAX C, ';
        v_sql := v_sql || '      MSAF.DP$P_PMC_STATUS E ';
        v_sql := v_sql || ' WHERE A.PROC_ID       = ''' || vp_proc_id || ''' ';
        v_sql := v_sql || '   AND A.COD_EMPRESA   = ''' || mcod_empresa || ''' ';
        --V_SQL := V_SQL || '   AND A.COD_ESTAB     = ''' || VP_FILIAL || ''' ';
        ---
        v_sql := v_sql || '   AND B.PROC_ID       = A.PROC_ID ';
        v_sql := v_sql || '   AND B.COD_EMPRESA   = A.COD_EMPRESA ';
        v_sql := v_sql || '   AND B.COD_ESTAB     = A.COD_ESTAB ';
        v_sql := v_sql || '   AND B.COD_PRODUTO   = A.COD_PRODUTO ';
        v_sql := v_sql || '   AND B.DATA_FISCAL_S = A.DATA_FISCAL ';
        v_sql := v_sql || '   AND B.CPF_CGC       = ''' || a_cod_empresa ( vp_cd ).cnpj || ''' ';
        ---
        v_sql := v_sql || '   AND B.PROC_ID             = C.PROC_ID (+)';
        v_sql := v_sql || '   AND B.BUSINESS_UNIT       = C.BUSINESS_UNIT (+)';
        v_sql := v_sql || '   AND B.NUM_CONTROLE_DOCTO  = C.NF_BRL_ID (+)';
        v_sql := v_sql || '   AND B.NUM_ITEM            = C.NF_BRL_LINE_NUM (+)';
        ---
        v_sql := v_sql || '   AND E.COD_PRODUTO (+) = A.COD_PRODUTO ';
        ---
        v_sql := v_sql || '   AND NOT EXISTS (SELECT ''Y'' ';
        v_sql := v_sql || '                   FROM ' || vp_tabela_pmc_mva || ' C ';
        v_sql := v_sql || '                   WHERE C.PROC_ID      = A.PROC_ID ';
        v_sql := v_sql || '                     AND C.COD_EMPRESA  = A.COD_EMPRESA ';
        v_sql := v_sql || '                     AND C.COD_ESTAB    = A.COD_ESTAB ';
        v_sql := v_sql || '                     AND C.NUM_DOCFIS   = A.NUM_DOCFIS ';
        v_sql := v_sql || '                     AND C.DATA_FISCAL  = A.DATA_FISCAL ';
        v_sql := v_sql || '                     AND C.SERIE_DOCFIS = A.SERIE_DOCFIS ';
        v_sql := v_sql || '                     AND C.COD_PRODUTO  = A.COD_PRODUTO ';
        v_sql := v_sql || '                     AND C.COD_ESTADO   = A.COD_ESTADO ';
        v_sql := v_sql || '                     AND C.DOCTO        = A.DOCTO ';
        v_sql := v_sql || '                     AND C.NUM_ITEM     = A.NUM_ITEM) ';

        OPEN c_pmc FOR v_sql;

        LOOP
            FETCH c_pmc
                BULK COLLECT INTO tab_pmc;

            BEGIN --(1)
                FORALL i IN tab_pmc.FIRST .. tab_pmc.LAST SAVE EXCEPTIONS
                    EXECUTE IMMEDIATE
                           'INSERT INTO '
                        || vp_tabela_pmc_mva
                        || ' VALUES (:1, :2, :3, :4, :5, :6, :7, :8, :9, :10, '
                        || ' :11, :12, :13, :14, :15, :16, :17, :18, :19, :20, :21, :22, :23, :24, :25, :26, :27, :28, :29, :30, '
                        || ' :31, :32, :33, :34, :35, :36, :37, :38, :39, :40, :41, :42, :43, :44, :45, :46, :47, :48, :49, :50, :51, :52) '
                        USING tab_pmc ( i ).proc_id
                            , tab_pmc ( i ).cod_empresa
                            , tab_pmc ( i ).cod_estab
                            , tab_pmc ( i ).num_docfis
                            , tab_pmc ( i ).data_fiscal
                            , tab_pmc ( i ).serie_docfis
                            , tab_pmc ( i ).cod_produto
                            , tab_pmc ( i ).cod_estado
                            , tab_pmc ( i ).docto
                            , tab_pmc ( i ).num_item
                            , tab_pmc ( i ).descr_item
                            , tab_pmc ( i ).quantidade
                            , tab_pmc ( i ).cod_nbm
                            , tab_pmc ( i ).cod_cfo
                            , tab_pmc ( i ).grupo_produto
                            , tab_pmc ( i ).vlr_desconto
                            , tab_pmc ( i ).vlr_contabil
                            , tab_pmc ( i ).base_unit_s_venda
                            , tab_pmc ( i ).num_autentic_nfe
                            , tab_pmc ( i ).lista
                            , tab_pmc ( i ).cod_estab_e
                            , tab_pmc ( i ).data_fiscal_e
                            , tab_pmc ( i ).movto_e_s_e
                            , tab_pmc ( i ).norm_dev_e
                            , tab_pmc ( i ).ident_docto_e
                            , tab_pmc ( i ).ident_fis_jur_e
                            , tab_pmc ( i ).sub_serie_docfis_e
                            , tab_pmc ( i ).discri_item_e
                            , tab_pmc ( i ).data_emissao_e
                            , tab_pmc ( i ).num_docfis_e
                            , tab_pmc ( i ).serie_docfis_e
                            , tab_pmc ( i ).num_item_e
                            , tab_pmc ( i ).cod_fis_jur_e
                            , tab_pmc ( i ).cpf_cgc_e
                            , tab_pmc ( i ).cod_nbm_e
                            , tab_pmc ( i ).cod_cfo_e
                            , tab_pmc ( i ).cod_natureza_op_e
                            , tab_pmc ( i ).cod_produto_e
                            , tab_pmc ( i ).vlr_contab_item_e
                            , tab_pmc ( i ).quantidade_e
                            , tab_pmc ( i ).vlr_unit_e
                            , tab_pmc ( i ).cod_situacao_b_e
                            , tab_pmc ( i ).cod_estado_e
                            , tab_pmc ( i ).num_controle_docto_e
                            , tab_pmc ( i ).num_autentic_nfe_e
                            , tab_pmc ( i ).base_icms_unit_e
                            , tab_pmc ( i ).vlr_icms_unit_e
                            , tab_pmc ( i ).aliq_icms_e
                            , tab_pmc ( i ).base_st_unit_e
                            , tab_pmc ( i ).vlr_icms_st_unit_e
                            , tab_pmc ( i ).vlr_icms_st_unit_aux
                            , tab_pmc ( i ).stat_liber_cntr;
            EXCEPTION
                WHEN OTHERS THEN
                    errors := SQL%BULK_EXCEPTIONS.COUNT;

                    IF ( v_p_log = 'S' ) THEN --GRAVAR LOG
                        FOR i IN 1 .. errors LOOP
                            err_idx := SQL%BULK_EXCEPTIONS ( i ).ERROR_INDEX;
                            err_code := SQL%BULK_EXCEPTIONS ( i ).ERROR_CODE;
                            err_msg := SQLERRM ( -SQL%BULK_EXCEPTIONS ( i ).ERROR_CODE );

                            INSERT INTO msafi.log_geral ( ora_err_number1
                                                        , ora_err_mesg1
                                                        , cod_empresa
                                                        , cod_estab
                                                        , num_docfis
                                                        , data_fiscal
                                                        , serie_docfis
                                                        , col14
                                                        , col15
                                                        , col16
                                                        , num_item
                                                        , col17
                                                        , col18
                                                        , col19
                                                        , col20
                                                        , col21
                                                        , col22 )
                                 VALUES ( err_code
                                        , err_msg
                                        , tab_pmc ( err_idx ).cod_empresa
                                        , tab_pmc ( err_idx ).cod_estab
                                        , tab_pmc ( err_idx ).num_docfis
                                        , tab_pmc ( err_idx ).data_fiscal
                                        , tab_pmc ( err_idx ).serie_docfis
                                        , tab_pmc ( err_idx ).cod_produto
                                        , tab_pmc ( err_idx ).cod_estado
                                        , tab_pmc ( err_idx ).docto
                                        , tab_pmc ( err_idx ).num_item
                                        , 'DPSP_PMC_X_MVA_V2_CPROC'
                                        , 'GET_ENTRADAS_FILIAL'
                                        , vp_cd
                                        , '-'
                                        , TO_CHAR ( SYSDATE
                                                  , 'DD/MM/YYYY HH24:MI.SS' )
                                        , vp_proc_id );
                        END LOOP;

                        COMMIT;
                    ELSE
                        NULL;
                    END IF;
            END; --(1)

            tab_pmc.delete;

            EXIT WHEN c_pmc%NOTFOUND;
        END LOOP;

        COMMIT;

        CLOSE c_pmc;
    END; --GET_ENTRADAS_FILIAL

    PROCEDURE get_compra_direta ( vp_proc_id IN NUMBER
                                , vp_filial IN VARCHAR2
                                , vp_data_ini IN VARCHAR2
                                , vp_data_fim IN VARCHAR2
                                , vp_tabela_entrada IN VARCHAR2
                                , vp_tabela_saida IN VARCHAR2
                                , vp_tabela_pmc_mva IN VARCHAR2
                                , vp_data_hora_ini IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 6000 );
        errors NUMBER;
        dml_errors EXCEPTION;
        err_idx INTEGER;
        err_code NUMBER;
        err_msg VARCHAR2 ( 255 );
        c_pmc SYS_REFCURSOR;

        TYPE t_tab_pmc IS RECORD
        (
            proc_id NUMBER ( 30 )
          , cod_empresa VARCHAR2 ( 3 )
          , cod_estab VARCHAR2 ( 6 )
          , num_docfis VARCHAR2 ( 12 )
          , data_fiscal DATE
          , serie_docfis VARCHAR2 ( 3 )
          , cod_produto VARCHAR2 ( 35 )
          , cod_estado VARCHAR2 ( 2 )
          , docto VARCHAR2 ( 5 )
          , num_item NUMBER ( 5 )
          , descr_item VARCHAR2 ( 50 )
          , quantidade NUMBER ( 12, 4 )
          , cod_nbm VARCHAR2 ( 10 )
          , cod_cfo VARCHAR2 ( 4 )
          , grupo_produto VARCHAR2 ( 30 )
          , vlr_desconto NUMBER ( 17, 2 )
          , vlr_contabil NUMBER ( 17, 2 )
          , base_unit_s_venda NUMBER ( 17, 2 )
          , num_autentic_nfe VARCHAR2 ( 80 )
          , lista VARCHAR2 ( 1 )
          , ---
            cod_estab_e VARCHAR2 ( 6 )
          , data_fiscal_e DATE
          , movto_e_s_e VARCHAR2 ( 1 )
          , norm_dev_e VARCHAR2 ( 1 )
          , ident_docto_e VARCHAR2 ( 12 )
          , ident_fis_jur_e VARCHAR2 ( 12 )
          , sub_serie_docfis_e VARCHAR2 ( 2 )
          , discri_item_e VARCHAR2 ( 46 )
          , data_emissao_e DATE
          , num_docfis_e VARCHAR2 ( 12 )
          , serie_docfis_e VARCHAR2 ( 3 )
          , num_item_e NUMBER ( 5 )
          , cod_fis_jur_e VARCHAR2 ( 14 )
          , cpf_cgc_e VARCHAR2 ( 14 )
          , cod_nbm_e VARCHAR2 ( 10 )
          , cod_cfo_e VARCHAR2 ( 4 )
          , cod_natureza_op_e VARCHAR2 ( 3 )
          , cod_produto_e VARCHAR2 ( 35 )
          , vlr_contab_item_e NUMBER ( 17, 2 )
          , quantidade_e NUMBER ( 12, 4 )
          , vlr_unit_e NUMBER ( 17, 2 )
          , cod_situacao_b_e VARCHAR2 ( 2 )
          , cod_estado_e VARCHAR2 ( 2 )
          , num_controle_docto_e VARCHAR2 ( 12 )
          , num_autentic_nfe_e VARCHAR2 ( 80 )
          , base_icms_unit_e NUMBER ( 17, 2 )
          , vlr_icms_unit_e NUMBER ( 17, 2 )
          , aliq_icms_e NUMBER ( 17, 2 )
          , base_st_unit_e NUMBER ( 17, 2 )
          , vlr_icms_st_unit_e NUMBER ( 17, 2 )
          , vlr_icms_st_unit_aux NUMBER ( 17, 2 )
          , stat_liber_cntr VARCHAR2 ( 10 )
        );

        TYPE c_tab_pmc IS TABLE OF t_tab_pmc;

        tab_pmc c_tab_pmc;
    BEGIN
        v_sql := ' SELECT ';
        v_sql := v_sql || ' ''' || vp_proc_id || ''' AS PROC_ID, ';
        v_sql := v_sql || ' ''' || mcod_empresa || ''' AS COD_EMPRESA, ';
        v_sql := v_sql || ' A.COD_ESTAB, ';
        v_sql := v_sql || ' A.NUM_DOCFIS, ';
        v_sql := v_sql || ' A.DATA_FISCAL, ';
        v_sql := v_sql || ' A.SERIE_DOCFIS, ';
        v_sql := v_sql || ' A.COD_PRODUTO, ';
        v_sql := v_sql || ' A.COD_ESTADO, ';
        v_sql := v_sql || ' A.DOCTO, ';
        v_sql := v_sql || ' A.NUM_ITEM, ';
        v_sql := v_sql || ' A.DESCR_ITEM, ';
        v_sql := v_sql || ' A.QUANTIDADE, ';
        v_sql := v_sql || ' A.COD_NBM, ';
        v_sql := v_sql || ' A.COD_CFO, ';
        v_sql := v_sql || ' A.GRUPO_PRODUTO, ';
        v_sql := v_sql || ' A.VLR_DESCONTO, ';
        v_sql := v_sql || ' A.VLR_CONTABIL, ';
        v_sql := v_sql || ' A.BASE_UNIT_S_VENDA, ';
        v_sql := v_sql || ' A.NUM_AUTENTIC_NFE, ';
        v_sql := v_sql || ' A.LISTA, ';
        ---
        v_sql := v_sql || ' B.COD_ESTAB, ';
        v_sql := v_sql || ' B.DATA_FISCAL, ';
        v_sql := v_sql || ' B.MOVTO_E_S, ';
        v_sql := v_sql || ' B.NORM_DEV, ';
        v_sql := v_sql || ' B.IDENT_DOCTO, ';
        v_sql := v_sql || ' B.IDENT_FIS_JUR, ';
        v_sql := v_sql || ' B.SUB_SERIE_DOCFIS, ';
        v_sql := v_sql || ' B.DISCRI_ITEM, ';
        v_sql := v_sql || ' B.DATA_EMISSAO, ';
        v_sql := v_sql || ' B.NUM_DOCFIS, ';
        v_sql := v_sql || ' B.SERIE_DOCFIS, ';
        v_sql := v_sql || ' B.NUM_ITEM, ';
        v_sql := v_sql || ' B.COD_FIS_JUR, ';
        v_sql := v_sql || ' B.CPF_CGC, ';
        v_sql := v_sql || ' B.COD_NBM, ';
        v_sql := v_sql || ' B.COD_CFO, ';
        v_sql := v_sql || ' B.COD_NATUREZA_OP, ';
        v_sql := v_sql || ' B.COD_PRODUTO, ';
        v_sql := v_sql || ' B.VLR_CONTAB_ITEM, ';
        v_sql := v_sql || ' B.QUANTIDADE, ';
        v_sql := v_sql || ' B.VLR_UNIT, ';
        v_sql := v_sql || ' B.COD_SITUACAO_B, ';
        v_sql := v_sql || ' B.COD_ESTADO, ';
        v_sql := v_sql || ' B.NUM_CONTROLE_DOCTO, ';
        v_sql := v_sql || ' B.NUM_AUTENTIC_NFE, ';
        ---
        v_sql := v_sql || ' C.BASE_ICMS_UNIT, ';
        v_sql := v_sql || ' C.VLR_ICMS_UNIT, ';
        v_sql := v_sql || ' C.ALIQ_ICMS, ';
        v_sql := v_sql || ' C.BASE_ST_UNIT, ';
        v_sql := v_sql || ' C.VLR_ICMS_ST_UNIT, ';
        v_sql := v_sql || ' C.VLR_ICMS_ST_UNIT_AUX, ';
        ---
        v_sql := v_sql || ' E.STATUS ';
        ---
        v_sql := v_sql || ' FROM ' || vp_tabela_saida || ' A, ';
        v_sql := v_sql || '      ' || vp_tabela_entrada || ' B, ';
        v_sql := v_sql || '      MSAF.DP$P_PMC_TAX C, ';
        v_sql := v_sql || '      MSAF.DP$P_PMC_STATUS E ';
        v_sql := v_sql || ' WHERE A.PROC_ID       = ''' || vp_proc_id || ''' ';
        v_sql := v_sql || '   AND A.COD_EMPRESA   = ''' || mcod_empresa || ''' ';
        --V_SQL := V_SQL || '   AND A.COD_ESTAB     = ''' || VP_FILIAL || ''' ';
        ---
        v_sql := v_sql || '   AND A.PROC_ID     = B.PROC_ID ';
        v_sql := v_sql || '   AND A.COD_EMPRESA = B.COD_EMPRESA ';
        v_sql := v_sql || '   AND A.COD_ESTAB   = B.COD_ESTAB ';
        v_sql := v_sql || '   AND A.COD_PRODUTO = B.COD_PRODUTO ';
        v_sql := v_sql || '   AND A.DATA_FISCAL = B.DATA_FISCAL_S ';
        ---
        v_sql := v_sql || '   AND B.PROC_ID            = C.PROC_ID (+)';
        v_sql := v_sql || '   AND B.BUSINESS_UNIT      = C.BUSINESS_UNIT (+)';
        v_sql := v_sql || '   AND B.NUM_CONTROLE_DOCTO = C.NF_BRL_ID (+)';
        v_sql := v_sql || '   AND B.NUM_ITEM           = C.NF_BRL_LINE_NUM (+)';
        ---
        v_sql := v_sql || '   AND E.COD_PRODUTO (+) = A.COD_PRODUTO ';
        ---
        v_sql := v_sql || '   AND NOT EXISTS (SELECT ''Y'' ';
        v_sql := v_sql || '                     FROM ' || vp_tabela_pmc_mva || ' C ';
        v_sql := v_sql || '                    WHERE C.PROC_ID      = A.PROC_ID ';
        v_sql := v_sql || '                      AND C.COD_EMPRESA  = A.COD_EMPRESA ';
        v_sql := v_sql || '                      AND C.COD_ESTAB    = A.COD_ESTAB ';
        v_sql := v_sql || '                      AND C.NUM_DOCFIS   = A.NUM_DOCFIS ';
        v_sql := v_sql || '                      AND C.DATA_FISCAL  = A.DATA_FISCAL ';
        v_sql := v_sql || '                      AND C.SERIE_DOCFIS = A.SERIE_DOCFIS ';
        v_sql := v_sql || '                      AND C.COD_PRODUTO  = A.COD_PRODUTO ';
        v_sql := v_sql || '                      AND C.COD_ESTADO   = A.COD_ESTADO ';
        v_sql := v_sql || '                      AND C.DOCTO        = A.DOCTO ';
        v_sql := v_sql || '                      AND C.NUM_ITEM     = A.NUM_ITEM) ';

        OPEN c_pmc FOR v_sql;

        LOOP
            FETCH c_pmc
                BULK COLLECT INTO tab_pmc;

            BEGIN --(1)
                FORALL i IN tab_pmc.FIRST .. tab_pmc.LAST SAVE EXCEPTIONS
                    EXECUTE IMMEDIATE
                           'INSERT INTO '
                        || vp_tabela_pmc_mva
                        || ' VALUES (:1, :2, :3, :4, :5, :6, :7, :8, :9, :10, '
                        || ' :11, :12, :13, :14, :15, :16, :17, :18, :19, :20, :21, :22, :23, :24, :25, :26, :27, :28, :29, :30, '
                        || ' :31, :32, :33, :34, :35, :36, :37, :38, :39, :40, :41, :42, :43, :44, :45, :46, :47, :48, :49, :50, :51, :52) '
                        USING tab_pmc ( i ).proc_id
                            , tab_pmc ( i ).cod_empresa
                            , tab_pmc ( i ).cod_estab
                            , tab_pmc ( i ).num_docfis
                            , tab_pmc ( i ).data_fiscal
                            , tab_pmc ( i ).serie_docfis
                            , tab_pmc ( i ).cod_produto
                            , tab_pmc ( i ).cod_estado
                            , tab_pmc ( i ).docto
                            , tab_pmc ( i ).num_item
                            , tab_pmc ( i ).descr_item
                            , tab_pmc ( i ).quantidade
                            , tab_pmc ( i ).cod_nbm
                            , tab_pmc ( i ).cod_cfo
                            , tab_pmc ( i ).grupo_produto
                            , tab_pmc ( i ).vlr_desconto
                            , tab_pmc ( i ).vlr_contabil
                            , tab_pmc ( i ).base_unit_s_venda
                            , tab_pmc ( i ).num_autentic_nfe
                            , tab_pmc ( i ).lista
                            , tab_pmc ( i ).cod_estab_e
                            , tab_pmc ( i ).data_fiscal_e
                            , tab_pmc ( i ).movto_e_s_e
                            , tab_pmc ( i ).norm_dev_e
                            , tab_pmc ( i ).ident_docto_e
                            , tab_pmc ( i ).ident_fis_jur_e
                            , tab_pmc ( i ).sub_serie_docfis_e
                            , tab_pmc ( i ).discri_item_e
                            , tab_pmc ( i ).data_emissao_e
                            , tab_pmc ( i ).num_docfis_e
                            , tab_pmc ( i ).serie_docfis_e
                            , tab_pmc ( i ).num_item_e
                            , tab_pmc ( i ).cod_fis_jur_e
                            , tab_pmc ( i ).cpf_cgc_e
                            , tab_pmc ( i ).cod_nbm_e
                            , tab_pmc ( i ).cod_cfo_e
                            , tab_pmc ( i ).cod_natureza_op_e
                            , tab_pmc ( i ).cod_produto_e
                            , tab_pmc ( i ).vlr_contab_item_e
                            , tab_pmc ( i ).quantidade_e
                            , tab_pmc ( i ).vlr_unit_e
                            , tab_pmc ( i ).cod_situacao_b_e
                            , tab_pmc ( i ).cod_estado_e
                            , tab_pmc ( i ).num_controle_docto_e
                            , tab_pmc ( i ).num_autentic_nfe_e
                            , tab_pmc ( i ).base_icms_unit_e
                            , tab_pmc ( i ).vlr_icms_unit_e
                            , tab_pmc ( i ).aliq_icms_e
                            , tab_pmc ( i ).base_st_unit_e
                            , tab_pmc ( i ).vlr_icms_st_unit_e
                            , tab_pmc ( i ).vlr_icms_st_unit_aux
                            , tab_pmc ( i ).stat_liber_cntr;
            EXCEPTION
                WHEN OTHERS THEN
                    errors := SQL%BULK_EXCEPTIONS.COUNT;

                    IF ( v_p_log = 'S' ) THEN --GRAVAR LOG
                        FOR i IN 1 .. errors LOOP
                            err_idx := SQL%BULK_EXCEPTIONS ( i ).ERROR_INDEX;
                            err_code := SQL%BULK_EXCEPTIONS ( i ).ERROR_CODE;
                            err_msg := SQLERRM ( -SQL%BULK_EXCEPTIONS ( i ).ERROR_CODE );

                            INSERT INTO msafi.log_geral ( ora_err_number1
                                                        , ora_err_mesg1
                                                        , cod_empresa
                                                        , cod_estab
                                                        , num_docfis
                                                        , data_fiscal
                                                        , serie_docfis
                                                        , col14
                                                        , col15
                                                        , col16
                                                        , num_item
                                                        , col17
                                                        , col18
                                                        , col19
                                                        , col20
                                                        , col21
                                                        , col22 )
                                 VALUES ( err_code
                                        , err_msg
                                        , tab_pmc ( err_idx ).cod_empresa
                                        , tab_pmc ( err_idx ).cod_estab
                                        , tab_pmc ( err_idx ).num_docfis
                                        , tab_pmc ( err_idx ).data_fiscal
                                        , tab_pmc ( err_idx ).serie_docfis
                                        , tab_pmc ( err_idx ).cod_produto
                                        , tab_pmc ( err_idx ).cod_estado
                                        , tab_pmc ( err_idx ).docto
                                        , tab_pmc ( err_idx ).num_item
                                        , 'DPSP_PMC_X_MVA_V2_CPROC'
                                        , 'GET_COMPRA_DIRETA'
                                        , '-'
                                        , '-'
                                        , TO_CHAR ( SYSDATE
                                                  , 'DD/MM/YYYY HH24:MI.SS' )
                                        , vp_proc_id );
                        END LOOP;

                        COMMIT;
                    ELSE
                        NULL;
                    END IF;
            END; --(1)

            tab_pmc.delete;

            EXIT WHEN c_pmc%NOTFOUND;
        END LOOP;

        COMMIT;

        CLOSE c_pmc;
    END; --GET_COMPRA_DIRETA

    PROCEDURE get_sem_entrada ( vp_proc_id IN NUMBER
                              , vp_filial IN VARCHAR2
                              , vp_data_ini IN VARCHAR2
                              , vp_data_fim IN VARCHAR2
                              , vp_tabela_saida IN VARCHAR2
                              , vp_tabela_pmc_mva IN VARCHAR2
                              , vp_data_hora_ini IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 4000 );
    BEGIN
        v_sql := 'INSERT /*+APPEND*/ INTO ' || vp_tabela_pmc_mva || ' ( ';
        ---
        v_sql := v_sql || ' SELECT ';
        v_sql := v_sql || '  ''' || vp_proc_id || ''', ';
        v_sql := v_sql || '  ''' || mcod_empresa || ''', ';
        v_sql := v_sql || '  A.COD_ESTAB,';
        v_sql := v_sql || '  A.NUM_DOCFIS,';
        v_sql := v_sql || '  A.DATA_FISCAL,';
        v_sql := v_sql || '  A.SERIE_DOCFIS,';
        v_sql := v_sql || '  A.COD_PRODUTO,';
        v_sql := v_sql || '  A.COD_ESTADO,';
        v_sql := v_sql || '  A.DOCTO,';
        v_sql := v_sql || '  A.NUM_ITEM,';
        v_sql := v_sql || '  A.DESCR_ITEM,';
        v_sql := v_sql || '  A.QUANTIDADE,';
        v_sql := v_sql || '  A.COD_NBM,';
        v_sql := v_sql || '  A.COD_CFO,';
        v_sql := v_sql || '  A.GRUPO_PRODUTO,';
        v_sql := v_sql || '  A.VLR_DESCONTO,';
        v_sql := v_sql || '  A.VLR_CONTABIL,';
        v_sql := v_sql || '  A.BASE_UNIT_S_VENDA,';
        v_sql := v_sql || '  A.NUM_AUTENTIC_NFE,';
        v_sql := v_sql || '  A.LISTA,';
        v_sql := v_sql || '  '''','; --B.COD_ESTAB,
        v_sql := v_sql || '  NULL,'; --B.DATA_FISCAL,
        v_sql := v_sql || '  '''','; --B.MOVTO_E_S,
        v_sql := v_sql || '  '''','; --B.NORM_DEV,
        v_sql := v_sql || '  '''','; --B.IDENT_DOCTO,
        v_sql := v_sql || '  '''','; --B.IDENT_FIS_JUR,
        v_sql := v_sql || '  '''','; --B.SUB_SERIE_DOCFIS,
        v_sql := v_sql || '  '''','; --B.DISCRI_ITEM,
        v_sql := v_sql || '  NULL,'; --B.DATA_EMISSAO,
        v_sql := v_sql || '  '''','; --B.NUM_DOCFIS,
        v_sql := v_sql || '  '''','; --B.SERIE_DOCFIS,
        v_sql := v_sql || '  0,   '; --B.NUM_ITEM,
        v_sql := v_sql || '  '''','; --B.COD_FIS_JUR,
        v_sql := v_sql || '  '''','; --B.CPF_CGC,
        v_sql := v_sql || '  '''','; --B.COD_NBM,
        v_sql := v_sql || '  '''','; --B.COD_CFO,
        v_sql := v_sql || '  '''','; --B.COD_NATUREZA_OP,
        v_sql := v_sql || '  '''','; --B.COD_PRODUTO,
        v_sql := v_sql || '  0,   '; --B.VLR_CONTAB_ITEM,
        v_sql := v_sql || '  0,   '; --B.QUANTIDADE,
        v_sql := v_sql || '  0,   '; --B.VLR_UNIT,
        v_sql := v_sql || '  '''','; --B.COD_SITUACAO_B,
        v_sql := v_sql || '  '''','; --B.COD_ESTADO,
        v_sql := v_sql || '  '''','; --B.NUM_CONTROLE_DOCTO,
        v_sql := v_sql || '  '''','; --B.NUM_AUTENTIC_NFE,
        v_sql := v_sql || '  0,   '; --BASE_ICMS_UNIT,
        v_sql := v_sql || '  0,   '; --VLR_ICMS_UNIT,
        v_sql := v_sql || '  0,   '; --ALIQ_ICMS,
        v_sql := v_sql || '  0,   '; --BASE_ST_UNIT,
        v_sql := v_sql || '  0,   '; --VLR_ICMS_ST_UNIT
        v_sql := v_sql || '  0,   '; --VLR_ICMS_ST_UNIT_AUX
        v_sql := v_sql || '  '''' '; --STAT_LIBER_CNTR
        v_sql := v_sql || ' FROM ' || vp_tabela_saida || ' A ';
        v_sql := v_sql || ' WHERE A.PROC_ID        = ''' || vp_proc_id || ''' ';
        v_sql := v_sql || '   AND A.COD_EMPRESA = ''' || mcod_empresa || ''' ';
        --V_SQL := V_SQL || '   AND A.COD_ESTAB   = ''' || VP_FILIAL || ''' ';
        v_sql :=
               v_sql
            || '   AND A.DATA_FISCAL BETWEEN TO_DATE('''
            || vp_data_ini
            || ''',''DD/MM/YYYY'') AND TO_DATE('''
            || vp_data_fim
            || ''',''DD/MM/YYYY'') ';
        ---
        v_sql := v_sql || '   AND NOT EXISTS (SELECT ''Y'' ';
        v_sql := v_sql || '                 FROM ' || vp_tabela_pmc_mva || ' C ';
        v_sql := v_sql || '                 WHERE C.PROC_ID      = A.PROC_ID';
        v_sql := v_sql || '                   AND C.COD_EMPRESA  = A.COD_EMPRESA';
        v_sql := v_sql || '                   AND C.COD_ESTAB    = A.COD_ESTAB';
        v_sql := v_sql || '                   AND C.NUM_DOCFIS   = A.NUM_DOCFIS';
        v_sql := v_sql || '                   AND C.DATA_FISCAL  = A.DATA_FISCAL';
        v_sql := v_sql || '                   AND C.SERIE_DOCFIS = A.SERIE_DOCFIS';
        v_sql := v_sql || '                   AND C.COD_PRODUTO  = A.COD_PRODUTO';
        v_sql := v_sql || '                   AND C.COD_ESTADO   = A.COD_ESTADO';
        v_sql := v_sql || '                   AND C.DOCTO        = A.DOCTO';
        v_sql := v_sql || '                   AND C.NUM_ITEM     = A.NUM_ITEM)) ';

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
                raise_application_error ( -20007
                                        , '!ERRO INSERT GET_SEM_ENTRADA!' );
        END;
    END; --GET_SEM_ENTRADA

    PROCEDURE load_nf_people ( vp_proc_id IN VARCHAR2
                             , vp_tab_entrada_c IN VARCHAR2
                             , vp_tab_entrada_f IN VARCHAR2
                             , vp_tab_entrada_co IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 4000 );
        v_qtde INTEGER;
        c_nf SYS_REFCURSOR;

        TYPE cur_tab_nf IS RECORD
        (
            proc_id NUMBER ( 30 )
          , business_unit VARCHAR2 ( 6 )
          , nf_brl_id VARCHAR2 ( 12 )
          , nf_brl_line_num NUMBER ( 3 )
          , base_icms_unit NUMBER ( 17, 2 )
          , vlr_icms_unit NUMBER ( 17, 2 )
          , aliq_icms NUMBER ( 17, 2 )
          , base_st_unit NUMBER ( 17, 2 )
          , vlr_icms_st_unit NUMBER ( 17, 2 )
          , vlr_icms_st_unit_aux NUMBER ( 17, 2 )
        );

        TYPE c_tab_nf IS TABLE OF cur_tab_nf;

        tab_nf c_tab_nf;
    BEGIN
        EXECUTE IMMEDIATE 'TRUNCATE TABLE DP$P_PMC_NF'; --GTT

        loga ( '[NF PEOPLE][TMP NF]'
             , FALSE );

        v_sql := 'INSERT INTO DP$P_PMC_NF ( ';
        v_sql := v_sql || ' SELECT DISTINCT A.BUSINESS_UNIT, A.NUM_CONTROLE_DOCTO, A.NUM_ITEM ';
        v_sql := v_sql || ' FROM ( ';
        v_sql := v_sql || '    SELECT BUSINESS_UNIT, NUM_CONTROLE_DOCTO, NUM_ITEM FROM ' || vp_tab_entrada_c || ' ';
        v_sql := v_sql || '    UNION ALL ';
        v_sql := v_sql || '    SELECT BUSINESS_UNIT, NUM_CONTROLE_DOCTO, NUM_ITEM FROM ' || vp_tab_entrada_f || ' ';
        v_sql := v_sql || '    UNION ALL ';
        v_sql := v_sql || '    SELECT BUSINESS_UNIT, NUM_CONTROLE_DOCTO, NUM_ITEM FROM ' || vp_tab_entrada_co || ' ';
        v_sql := v_sql || '      ) A ';
        v_sql := v_sql || ' ) ';

        EXECUTE IMMEDIATE v_sql;

        COMMIT;

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , 'DP$P_PMC_NF' );

        SELECT COUNT ( * )
          INTO v_qtde
          FROM msaf.dp$p_pmc_nf;

        loga ( '[NF PEOPLE][INI][' || v_qtde || ']'
             , FALSE );

        EXECUTE IMMEDIATE 'TRUNCATE TABLE DP$P_PMC_TAX'; --GTT

        v_sql := 'SELECT /*+NOPARALLEL DRIVING_SITE(PS)*/ ' || vp_proc_id || ' AS PROC_ID, ';
        v_sql := v_sql || '      PS.BUSINESS_UNIT, ';
        v_sql := v_sql || '      PS.NF_BRL_ID, ';
        v_sql := v_sql || '      PS.NF_BRL_LINE_NUM, ';
        v_sql := v_sql || '      PS.BASE_ICMS_UNIT, ';
        v_sql := v_sql || '      PS.VLR_ICMS_UNIT, ';
        v_sql := v_sql || '      PS.ALIQ_ICMS, ';
        v_sql := v_sql || '      PS.BASE_ST_UNIT, ';
        v_sql := v_sql || '      PS.VLR_ICMS_ST_UNIT, ';
        v_sql := v_sql || '      PS.VLR_ICMS_ST_UNIT_AUX ';
        v_sql := v_sql || 'FROM ( ';
        v_sql := v_sql || '          SELECT C.BUSINESS_UNIT, ';
        v_sql := v_sql || '              C.NF_BRL_ID, ';
        v_sql := v_sql || '              C.NF_BRL_LINE_NUM, ';
        v_sql := v_sql || '              NVL(TRUNC(C.ICMSTAX_BRL_BSS/C.QTY_NF_BRL, 2), 0) AS BASE_ICMS_UNIT, ';
        v_sql := v_sql || '              NVL(TRUNC(C.ICMSTAX_BRL_AMT/C.QTY_NF_BRL, 2), 0) AS VLR_ICMS_UNIT, ';
        v_sql := v_sql || '              NVL(C.ICMSTAX_BRL_PCT, 0) AS ALIQ_ICMS, ';
        v_sql :=
               v_sql
            || '              TRUNC(DECODE(NVL(C.DSP_ICMS_BSS_ST, 0), 0, NVL(C.DSP_ICMSSUBBRL_BSS, 0), NVL(C.DSP_ICMS_BSS_ST, 0))/C.QTY_NF_BRL, 2) AS BASE_ST_UNIT,  ';
        v_sql :=
               v_sql
            || '              TRUNC(DECODE(NVL(C.DSP_ICMS_AMT_ST, 0), 0, NVL(C.DSP_ICMSSUBBRL_AMT, 0), NVL(C.DSP_ICMS_AMT_ST, 0))/C.QTY_NF_BRL, 2) AS VLR_ICMS_ST_UNIT,  ';
        v_sql := v_sql || '              TRUNC(NVL(C.ICMSSUB_BRL_AMT,0)/C.QTY_NF_BRL, 2) AS VLR_ICMS_ST_UNIT_AUX  ';
        v_sql := v_sql || '          FROM MSAFI.PS_NF_LN_BRL C ';
        v_sql := v_sql || '     ) PS, ';
        v_sql := v_sql || '     MSAF.DP$P_PMC_NF E ';
        v_sql := v_sql || 'WHERE PS.BUSINESS_UNIT = E.BUSINESS_UNIT ';
        v_sql := v_sql || 'AND PS.NF_BRL_ID       = E.NUM_CONTROLE_DOCTO ';
        v_sql := v_sql || 'AND PS.NF_BRL_LINE_NUM = E.NUM_ITEM ';

        OPEN c_nf FOR v_sql;

        LOOP
            FETCH c_nf
                BULK COLLECT INTO tab_nf;

            FORALL i IN tab_nf.FIRST .. tab_nf.LAST
                INSERT INTO dp$p_pmc_tax
                VALUES tab_nf ( i );

            tab_nf.delete;

            EXIT WHEN c_nf%NOTFOUND;
        END LOOP;

        COMMIT;

        CLOSE c_nf;

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , 'DP$P_PMC_TAX' );

        SELECT COUNT ( * )
          INTO v_qtde
          FROM msaf.dp$p_pmc_tax;

        loga ( '[NF PEOPLE][FIM][' || v_qtde || ']'
             , FALSE );
    END;

    PROCEDURE delete_tbl ( p_i_cod_estab IN VARCHAR2
                         , p_i_data_ini IN DATE
                         , p_i_data_fim IN DATE )
    IS
    BEGIN
        DELETE msafi.dpsp_msaf_pmc_mva
         WHERE cod_empresa = mcod_empresa
           AND cod_estab = p_i_cod_estab
           AND data_fiscal BETWEEN p_i_data_ini AND p_i_data_fim;

        COMMIT;
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

    --PROC PARA DIMINUIR O VOLUME DE PESQUISA DE ULTIMA ENTRADA
    PROCEDURE limpa_tab_saida_sintetico_cd ( vp_cd IN VARCHAR2
                                           , vp_tab_entrada_cd IN VARCHAR2
                                           , vp_qtde_saida_s1 IN OUT NUMBER
                                           , vp_tabela_saida_s1 IN VARCHAR2 )
    IS
        v_qtde_ini1 NUMBER := 0;
    BEGIN
        IF ( vp_tab_entrada_cd <> ' ' ) THEN
            EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || vp_tabela_saida_s1            INTO v_qtde_ini1;

            EXECUTE IMMEDIATE
                   'DELETE '
                || vp_tabela_saida_s1
                || ' S WHERE EXISTS (SELECT ''Y'' '
                || ' FROM '
                || vp_tab_entrada_cd
                || ' E '
                || ' WHERE E.COD_PRODUTO 	 = S.COD_PRODUTO '
                || '   AND E.DATA_FISCAL_S = S.DATA_FISCAL_S '
                || '   AND E.COD_ESTAB     = '''
                || vp_cd
                || ''') ';

            COMMIT;

            dbms_stats.gather_table_stats ( 'MSAF'
                                          , vp_tabela_saida_s1 );

            EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || vp_tabela_saida_s1            INTO vp_qtde_saida_s1;

            ----
            loga ( 'S1 INI: ' || v_qtde_ini1 || ' FIM: ' || vp_qtde_saida_s1
                 , FALSE );
        END IF;
    END;

    --PROC PARA DIMINUIR O VOLUME DE PESQUISA DE ULTIMA ENTRADA
    PROCEDURE limpa_tab_saida_sintetico_fil ( vp_cod_estab IN VARCHAR2
                                            , vp_tab_entrada_f IN VARCHAR2
                                            , vp_tabela_saida_s2 IN VARCHAR2 )
    IS
    BEGIN
        IF ( vp_tab_entrada_f <> ' ' ) THEN
            EXECUTE IMMEDIATE
                   'DELETE '
                || vp_tabela_saida_s2
                || ' S WHERE S.COD_ESTAB = '''
                || vp_cod_estab
                || ''' AND EXISTS (SELECT ''Y'' '
                || ' FROM '
                || vp_tab_entrada_f
                || ' E '
                || ' WHERE E.COD_PRODUTO   = S.COD_PRODUTO '
                || '   AND E.DATA_FISCAL_S = S.DATA_FISCAL_S '
                || '   AND E.COD_ESTAB     = S.COD_ESTAB) ';

            COMMIT;

            dbms_stats.gather_table_stats ( 'MSAF'
                                          , vp_tabela_saida_s2 );
        END IF;
    END;

    PROCEDURE get_param_perfil ( p_perfil IN VARCHAR2
                               , p_i_compra_direta   OUT VARCHAR2
                               , p_i_origem1   OUT VARCHAR2
                               , p_i_cd1   OUT VARCHAR2
                               , p_i_origem2   OUT VARCHAR2
                               , p_i_cd2   OUT VARCHAR2
                               , p_i_origem3   OUT VARCHAR2
                               , p_i_cd3   OUT VARCHAR2
                               , p_i_origem4   OUT VARCHAR2
                               , p_i_cd4   OUT VARCHAR2 )
    IS
    BEGIN
        FOR p IN ( SELECT nome_param
                        , valor
                     FROM fpar_parametros p INNER JOIN fpar_param_det d ON d.id_parametro = p.id_parametros
                    WHERE p.nome_framework = 'DPSP_PERFIL_PMC_CPAR'
                      AND p.id_parametros = p_perfil
                      AND valor IS NOT NULL ) LOOP
            CASE p.nome_param
                WHEN '1DIRETA' THEN
                    p_i_compra_direta := p.valor;
                WHEN '2OPERACAO' THEN
                    p_i_origem1 := p.valor;
                WHEN '2ORIGEM' THEN
                    p_i_cd1 := p.valor;
                WHEN '3OPERACAO' THEN
                    p_i_origem2 := p.valor;
                WHEN '3ORIGEM' THEN
                    p_i_cd2 := p.valor;
                WHEN '4OPERACAO' THEN
                    p_i_origem3 := p.valor;
                WHEN '4ORIGEM' THEN
                    p_i_cd3 := p.valor;
                WHEN '5OPERACAO' THEN
                    p_i_origem4 := p.valor;
                WHEN '5ORIGEM' THEN
                    p_i_cd4 := p.valor;
                ELSE
                    loga ( '[GET_PARAM_PERFIL ' || p.nome_param || '][NOT FOUND]'
                         , FALSE );
            END CASE;
        END LOOP;
    END;

    FUNCTION get_param_quebra ( p_perfil IN VARCHAR2
                              , p_i_quebra_default IN INTEGER )
        RETURN INTEGER
    AS
        v_i_quebra INTEGER;
    BEGIN
        BEGIN
            SELECT valor
              INTO v_i_quebra
              FROM fpar_parametros p INNER JOIN fpar_param_det d ON d.id_parametro = p.id_parametros
             WHERE p.nome_framework = 'DPSP_PERFIL_PMC_CPAR'
               AND p.id_parametros = p_perfil
               AND nome_param = '6QUEBRA'
               AND valor IS NOT NULL;
        EXCEPTION
            WHEN OTHERS THEN
                v_i_quebra := p_i_quebra_default;
        END;

        RETURN v_i_quebra;
    END;

    PROCEDURE get_antecipacao ( vp_proc_id IN VARCHAR2
                              , v_tab_entrada_ent_c IN VARCHAR2
                              , v_tab_entrada_ent_f IN VARCHAR2
                              , v_tab_entrada_ent_d IN VARCHAR2
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
            || ' SELECT DISTINCT COD_EMPRESA, COD_ESTAB AS COD_ESTAB, NUM_CONTROLE_DOCTO AS NUM_CONTROLE_DOCTO, NUM_ITEM AS NUM_ITEM ';
        v_sql := v_sql || ' FROM ' || v_tab_entrada_ent_c || ' ';
        -- V_SQL := V_SQL || ' WHERE BASE_ST_UNIT_E = 0 AND VLR_ICMS_ST_UNIT_E = 0 ';
        v_sql := v_sql || ' UNION ALL ';
        v_sql :=
               v_sql
            || ' SELECT DISTINCT COD_EMPRESA, COD_ESTAB AS COD_ESTAB, NUM_CONTROLE_DOCTO AS NUM_CONTROLE_DOCTO, NUM_ITEM AS NUM_ITEM ';
        v_sql := v_sql || ' FROM ' || v_tab_entrada_ent_d || ' ';
        -- V_SQL := V_SQL || ' WHERE BASE_ST_UNIT_E = 0 AND VLR_ICMS_ST_UNIT_E = 0 ';
        v_sql := v_sql || ' UNION ALL ';
        v_sql :=
               v_sql
            || ' SELECT DISTINCT COD_EMPRESA, COD_ESTAB AS COD_ESTAB, NUM_CONTROLE_DOCTO AS NUM_CONTROLE_DOCTO, NUM_ITEM AS NUM_ITEM ';
        v_sql := v_sql || ' FROM ' || v_tab_entrada_ent_f || ' ';

        -- V_SQL := V_SQL || ' WHERE BASE_ST_UNIT_E = 0 AND VLR_ICMS_ST_UNIT_E = 0 ';

        EXECUTE IMMEDIATE v_sql;

        save_tmp_control ( vp_proc_id
                         , v_tab_aux );

        --ATUALIZAR ANTECIPACAO
        msafi.dpsp_get_antecipacao ( 'MSAF.' || v_tab_aux );
        loga ( '[GET ANTECIP][END][' || SQL%ROWCOUNT || ']'
             , FALSE );

        EXECUTE IMMEDIATE ( 'drop table ' || v_tab_aux );
    EXCEPTION
        WHEN OTHERS THEN
            BEGIN
                msafi.dpsp_get_antecipacao ( 'MSAF.' || v_tab_aux );
                loga ( '[GET ANTECIP2][END][' || SQL%ROWCOUNT || ']'
                     , FALSE );

                EXECUTE IMMEDIATE ( 'drop table ' || v_tab_aux );
            EXCEPTION
                WHEN OTHERS THEN
                    BEGIN
                        msafi.dpsp_get_antecipacao ( 'MSAF.' || v_tab_aux );
                        loga ( '[GET ANTECIP3][END][' || SQL%ROWCOUNT || ']'
                             , FALSE );

                        EXECUTE IMMEDIATE ( 'drop table ' || v_tab_aux );
                    EXCEPTION
                        WHEN OTHERS THEN
                            loga ( '[GET ANTECIP4][CANCEL]' );

                            EXECUTE IMMEDIATE ( 'drop table ' || v_tab_aux );
                    END;
            END;
    END;


    PROCEDURE load_tab_pmc ( vp_proc_instance IN NUMBER
                           , vp_cod_estab IN VARCHAR2
                           , vp_tabela_pmc_mva IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 20000 );
    BEGIN
        ---INSERIR RESULTADO
        v_sql := 'INSERT /*+APPEND*/ INTO MSAFI.DPSP_MSAF_PMC_MVA ';
        --
        v_sql := v_sql || 'SELECT cod_empresa,					 ';
        v_sql := v_sql || '       cod_estab,                     ';
        v_sql := v_sql || '       num_docfis,                    ';
        v_sql := v_sql || '       data_fiscal,                   ';
        v_sql := v_sql || '       cod_produto,                   ';
        v_sql := v_sql || '       cod_estado,                    ';
        v_sql := v_sql || '       docto,                         ';
        v_sql := v_sql || '       num_item,                      ';
        v_sql := v_sql || '       descr_item,                    ';
        v_sql := v_sql || '       quantidade,                    ';
        v_sql := v_sql || '       cod_nbm,                       ';
        v_sql := v_sql || '       cod_cfo,                       ';
        v_sql := v_sql || '       grupo_produto,                 ';
        v_sql := v_sql || '       vlr_desconto,                  ';
        v_sql := v_sql || '       vlr_contabil,                  ';
        v_sql := v_sql || '       base_unit_s_venda,             ';
        v_sql := v_sql || '       num_autentic_nfe,              ';
        v_sql := v_sql || '       cod_estab_e,                   ';
        v_sql := v_sql || '       data_fiscal_e,                 ';
        v_sql := v_sql || '       movto_e_s_e,                   ';
        v_sql := v_sql || '       norm_dev_e,                    ';
        v_sql := v_sql || '       ident_docto_e,                 ';
        v_sql := v_sql || '       ident_fis_jur_e,               ';
        v_sql := v_sql || '       sub_serie_docfis_e,            ';
        v_sql := v_sql || '       discri_item_e,                 ';
        v_sql := v_sql || '       data_emissao_e,                ';
        v_sql := v_sql || '       num_docfis_e,                  ';
        v_sql := v_sql || '       serie_docfis_e,                ';
        v_sql := v_sql || '       num_item_e,                    ';
        v_sql := v_sql || '       cod_fis_jur_e,                 ';
        v_sql := v_sql || '       cpf_cgc_e,                     ';
        v_sql := v_sql || '       cod_nbm_e,                     ';
        v_sql := v_sql || '       cod_cfo_e,                     ';
        v_sql := v_sql || '       cod_natureza_op_e,             ';
        v_sql := v_sql || '       cod_produto_e,                 ';
        v_sql := v_sql || '       vlr_contab_item_e,             ';
        v_sql := v_sql || '       quantidade_e,                  ';
        v_sql := v_sql || '       vlr_unit_e,                    ';
        v_sql := v_sql || '       cod_situacao_b_e,              ';
        v_sql := v_sql || '       cod_estado_e,                  ';
        v_sql := v_sql || '       num_controle_docto_e,          ';
        v_sql := v_sql || '       num_autentic_nfe_e,            ';
        v_sql := v_sql || '       base_icms_unit_e,              ';
        v_sql := v_sql || '       vlr_icms_unit_e,               ';
        v_sql := v_sql || '       aliq_icms_e,                   ';
        v_sql := v_sql || '       base_st_unit_e,                ';
        v_sql := v_sql || '       vlr_icms_st_unit_e,            ';
        v_sql := v_sql || '       stat_liber_cntr,               ';
        v_sql := v_sql || '       id_aliq_st,                    ';
        v_sql := v_sql || '       vlr_pmc,                       ';
        v_sql := v_sql || '       vlr_icms_aux,                  ';
        v_sql := v_sql || '       vlr_icms_bruto,                ';
        v_sql := v_sql || '       vlr_icms_s_venda,              ';
        v_sql := v_sql || '       vlr_dif_qtde,                  ';
        v_sql := v_sql || '       deb_cred,                      ';
        v_sql := v_sql || '       usuario,                       ';
        v_sql := v_sql || '       dat_operacao,                  ';
        v_sql := v_sql || '       serie_docfis,                  ';
        v_sql := v_sql || '       vlr_icms_st_unit_aux,          ';
        v_sql := v_sql || '       lista,                         ';
        v_sql := v_sql || '       vlr_antecip_unit,              ';
        v_sql := v_sql || '       vlr_base_icms_xml_unit,        ';
        v_sql := v_sql || '       vlr_icms_xml_unit,             ';
        v_sql := v_sql || '       vlr_base_icms_st_xml_unit,     ';
        v_sql := v_sql || '       vlr_icms_st_xml_unit,          ';
        v_sql := v_sql || '       vlr_fcst_xml_unit,             ';
        v_sql := v_sql || '       vlr_fcrt_xml_unit,             ';
        v_sql := v_sql || '       vlr_fcp_xml_unit,              ';
        v_sql := v_sql || '       trunc((case when vlr_icms_st_xml_unit = 0 and vlr_base_icms_st_xml_unit > 0   ';
        v_sql :=
               v_sql
            || '             then trunc((vlr_base_icms_st_xml_unit*(to_number(REPLACE(id_aliq_st, ''%'', '''')) / 100)-vlr_icms_xml_unit),2)  ';
        v_sql := v_sql || '             else vlr_icms_st_xml_unit  end),2)  vlr_icms_st_xml_unit_calc,   ';
        v_sql := v_sql || '       trunc(                                                                 ';
        v_sql := v_sql || '       (((                                                                    ';
        v_sql :=
               v_sql
            || '       trunc((case when vlr_icms_st_xml_unit = 0 and vlr_base_icms_st_xml_unit > 0                                                    ';
        v_sql :=
               v_sql
            || '             then trunc((vlr_base_icms_st_xml_unit*(to_number(REPLACE(id_aliq_st, ''%'', '''')) / 100)-vlr_icms_xml_unit),2)  ';
        v_sql := v_sql || '             else vlr_icms_st_xml_unit  end),2)           ';
        v_sql := v_sql || '           +(vlr_antecip_unit) + (vlr_fcst_xml_unit) +    ';
        v_sql := v_sql || '             (vlr_fcrt_xml_unit)) -                       ';
        v_sql := v_sql || '             trunc(trunc(base_unit_s_venda *              ';
        v_sql := v_sql || '                           (to_number(REPLACE(id_aliq_st, ''%'', '''')) / 100),  ';
        v_sql := v_sql || '                           2) -                                                          ';
        v_sql := v_sql || '               (case when vlr_icms_xml_unit = 0 and vlr_antecip_unit > 0             ';
        v_sql := v_sql || '                     then vlr_icms_unit_e                                            ';
        v_sql := v_sql || '                   else                                                              ';
        v_sql := v_sql || '                   (vlr_icms_xml_unit + (vlr_fcp_xml_unit))                          ';
        v_sql := v_sql || '                   end),                                                             ';
        v_sql := v_sql || '                     2)                                                              ';
        v_sql := v_sql || '              ) * quantidade),                                                       ';
        v_sql :=
               v_sql
            || '             2) vlr_dif_qtde_xml                                                                                                      ';
        v_sql := v_sql || '  FROM (   ';
        --
        v_sql := v_sql || 'SELECT DISTINCT ';
        v_sql := v_sql || ' A.COD_EMPRESA ';
        v_sql := v_sql || ',A.COD_ESTAB ';
        v_sql := v_sql || ',A.NUM_DOCFIS ';
        v_sql := v_sql || ',A.DATA_FISCAL ';
        v_sql := v_sql || ',A.COD_PRODUTO ';
        v_sql := v_sql || ',A.COD_ESTADO ';
        v_sql := v_sql || ',A.DOCTO ';
        v_sql := v_sql || ',A.NUM_ITEM ';
        v_sql := v_sql || ',A.DESCR_ITEM ';
        v_sql := v_sql || ',A.QUANTIDADE ';
        v_sql := v_sql || ',A.COD_NBM ';
        v_sql := v_sql || ',A.COD_CFO ';
        v_sql := v_sql || ',A.GRUPO_PRODUTO ';
        v_sql := v_sql || ',A.VLR_DESCONTO ';
        v_sql := v_sql || ',A.VLR_CONTABIL ';
        v_sql := v_sql || ',A.BASE_UNIT_S_VENDA ';
        v_sql := v_sql || ',A.NUM_AUTENTIC_NFE ';
        ---
        v_sql := v_sql || ',A.COD_ESTAB_E ';
        v_sql := v_sql || ',A.DATA_FISCAL_E ';
        v_sql := v_sql || ',A.MOVTO_E_S_E ';
        v_sql := v_sql || ',A.NORM_DEV_E ';
        v_sql := v_sql || ',A.IDENT_DOCTO_E ';
        v_sql := v_sql || ',A.IDENT_FIS_JUR_E ';
        v_sql := v_sql || ',A.SUB_SERIE_DOCFIS_E ';
        v_sql := v_sql || ',A.DISCRI_ITEM_E ';
        v_sql := v_sql || ',A.DATA_EMISSAO_E ';
        v_sql := v_sql || ',A.NUM_DOCFIS_E ';
        v_sql := v_sql || ',A.SERIE_DOCFIS_E ';
        v_sql := v_sql || ',A.NUM_ITEM_E ';
        v_sql := v_sql || ',A.COD_FIS_JUR_E ';
        v_sql := v_sql || ',A.CPF_CGC_E ';
        v_sql := v_sql || ',A.COD_NBM_E ';
        v_sql := v_sql || ',A.COD_CFO_E ';
        v_sql := v_sql || ',A.COD_NATUREZA_OP_E ';
        v_sql := v_sql || ',A.COD_PRODUTO_E ';
        v_sql := v_sql || ',A.VLR_CONTAB_ITEM_E ';
        v_sql := v_sql || ',A.QUANTIDADE_E ';
        v_sql := v_sql || ',A.VLR_UNIT_E ';
        v_sql := v_sql || ',A.COD_SITUACAO_B_E ';
        v_sql := v_sql || ',A.COD_ESTADO_E ';
        v_sql := v_sql || ',A.NUM_CONTROLE_DOCTO_E ';
        v_sql := v_sql || ',A.NUM_AUTENTIC_NFE_E ';
        v_sql := v_sql || ',A.BASE_ICMS_UNIT_E ';
        v_sql := v_sql || ',A.VLR_ICMS_UNIT_E ';
        v_sql := v_sql || ',A.ALIQ_ICMS_E ';
        v_sql := v_sql || ',A.BASE_ST_UNIT_E ';
        v_sql :=
               v_sql
            || ',DECODE(A.VLR_ICMS_ST_UNIT_E, 0, A.VLR_ICMS_ST_UNIT_AUX, A.VLR_ICMS_ST_UNIT_E) VLR_ICMS_ST_UNIT_E '; --VLR_ICMS_ST_UNIT_E
        v_sql := v_sql || ',A.STAT_LIBER_CNTR ';
        v_sql := v_sql || ',C.ALIQ_ST id_aliq_st ';
        v_sql := v_sql || ',D.VLR_PMC ';
        v_sql :=
               v_sql
            || ',TRUNC((A.BASE_ST_UNIT_E*(TO_NUMBER(REPLACE(C.ALIQ_ST,''%'', '''' ))/100))-DECODE(A.VLR_ICMS_ST_UNIT_E, 0, A.VLR_ICMS_ST_UNIT_AUX, A.VLR_ICMS_ST_UNIT_E), 2) VLR_ICMS_AUX'; --VLR_ICMS_AUX
        v_sql :=
            v_sql || ',TRUNC(A.BASE_UNIT_S_VENDA*(TO_NUMBER(REPLACE(C.ALIQ_ST,''%'', '''' ))/100), 2) VLR_ICMS_BRUTO'; --VLR_ICMS_BRUTO
        v_sql :=
               v_sql
            || ',(CASE WHEN (A.VLR_ICMS_UNIT_E = 0 OR A.VLR_ICMS_UNIT_E IS NULL) THEN TRUNC(TRUNC(A.BASE_UNIT_S_VENDA*(TO_NUMBER(REPLACE(C.ALIQ_ST,''%'',''''))/100), 2)-TRUNC((A.BASE_ST_UNIT_E*(TO_NUMBER(REPLACE(C.ALIQ_ST,''%'',''''))/100))-DECODE(A.VLR_ICMS_ST_UNIT_E, 0, A.VLR_ICMS_ST_UNIT_AUX, A.VLR_ICMS_ST_UNIT_E), 2), 2) ELSE TRUNC(TRUNC(A.BASE_UNIT_S_VENDA*(TO_NUMBER(REPLACE(C.ALIQ_ST,''%'',''''))/100), 2)-A.VLR_ICMS_UNIT_E, 2) END) VLR_ICMS_S_VENDA '; --VLR_ICMS_S_VENDA
        v_sql :=
               v_sql
            || ',TRUNC((A.VLR_ICMS_ST_UNIT_E-CASE WHEN (A.VLR_ICMS_UNIT_E = 0 OR A.VLR_ICMS_UNIT_E IS NULL) THEN TRUNC(TRUNC(A.BASE_UNIT_S_VENDA*(TO_NUMBER(REPLACE(C.ALIQ_ST,''%'',''''))/100), 2)-TRUNC((A.BASE_ST_UNIT_E*(TO_NUMBER(REPLACE(C.ALIQ_ST,''%'',''''))/100))-DECODE(A.VLR_ICMS_ST_UNIT_E, 0, A.VLR_ICMS_ST_UNIT_AUX, A.VLR_ICMS_ST_UNIT_E), 2), 2) ELSE TRUNC(TRUNC(A.BASE_UNIT_S_VENDA*(TO_NUMBER(REPLACE(C.ALIQ_ST,''%'',''''))/100), 2)-A.VLR_ICMS_UNIT_E, 2) END)*A.QUANTIDADE, 2) vlr_dif_qtde '; --VLR_DIF_QTDE
        v_sql := v_sql || ',CASE ';
        v_sql := v_sql || '    WHEN ( ';
        v_sql := v_sql || '          TRUNC((A.VLR_ICMS_ST_UNIT_E- ';
        v_sql :=
               v_sql
            || '          CASE WHEN (A.VLR_ICMS_UNIT_E = 0 OR A.VLR_ICMS_UNIT_E IS NULL) THEN TRUNC(TRUNC(A.BASE_UNIT_S_VENDA*(TO_NUMBER(REPLACE(C.ALIQ_ST,''%'',''''))/100), 2)-TRUNC((A.BASE_ST_UNIT_E*(TO_NUMBER(REPLACE(C.ALIQ_ST,''%'',''''))/100))-DECODE(A.VLR_ICMS_ST_UNIT_E, 0, A.VLR_ICMS_ST_UNIT_AUX, A.VLR_ICMS_ST_UNIT_E), 2), 2) ';
        v_sql :=
               v_sql
            || '          ELSE TRUNC(TRUNC(A.BASE_UNIT_S_VENDA*(TO_NUMBER(REPLACE(C.ALIQ_ST,''%'',''''))/100), 2)-A.VLR_ICMS_UNIT_E, 2) ';
        v_sql := v_sql || '          END)*A.QUANTIDADE, 2) ';
        v_sql := v_sql || '          ) > 0 THEN ''CRÉDITO'' ';
        v_sql := v_sql || '    WHEN ( ';
        v_sql := v_sql || '          TRUNC((A.VLR_ICMS_ST_UNIT_E- ';
        v_sql :=
               v_sql
            || '          CASE WHEN (A.VLR_ICMS_UNIT_E = 0 OR A.VLR_ICMS_UNIT_E IS NULL) THEN TRUNC(TRUNC(A.BASE_UNIT_S_VENDA*(TO_NUMBER(REPLACE(C.ALIQ_ST,''%'',''''))/100), 2)-TRUNC((A.BASE_ST_UNIT_E*(TO_NUMBER(REPLACE(C.ALIQ_ST,''%'',''''))/100))-DECODE(A.VLR_ICMS_ST_UNIT_E,0,A.VLR_ICMS_ST_UNIT_AUX, A.VLR_ICMS_ST_UNIT_E), 2), 2) ';
        v_sql :=
               v_sql
            || '          ELSE TRUNC(TRUNC(A.BASE_UNIT_S_VENDA*(TO_NUMBER(REPLACE(C.ALIQ_ST,''%'',''''))/100), 2)-A.VLR_ICMS_UNIT_E, 2) ';
        v_sql := v_sql || '          END)*A.QUANTIDADE, 2) ';
        v_sql := v_sql || '         ) < 0 THEN ''DÉBITO'' ';
        v_sql := v_sql || '    ELSE ''-'' END deb_cred ';
        v_sql := v_sql || ',''' || musuario || ''' usuario ';
        v_sql := v_sql || ',SYSDATE dat_operacao ';
        v_sql := v_sql || ',A.SERIE_DOCFIS ';
        v_sql := v_sql || ',A.VLR_ICMS_ST_UNIT_AUX ';
        v_sql := v_sql || ',LIS.LISTA ';
        -- ANTECIPACAO
        v_sql := v_sql || ',TRUNC(NVL(ANT.VLR_ANTECIP_IST,0) + NVL(ANT.VLR_ANTECIP_REV,0),2) VLR_ANTECIP_UNIT,';
        -- XML                                                                                                ';
        v_sql := v_sql || ' (CASE                                                                             ';
        v_sql := v_sql || '   WHEN A.QUANTIDADE_E > 0 THEN                                                    ';
        v_sql := v_sql || '    ROUND((NVL(XML.VLR_BASE_ICMS_TP, 0) / A.QUANTIDADE_E), 2)                         ';
        v_sql := v_sql || '   ELSE                                                                            ';
        v_sql := v_sql || '    0                                                                              ';
        v_sql := v_sql || ' END) VLR_BASE_ICMS_XML_UNIT,                                                      ';
        v_sql := v_sql || ' (CASE                                                                             ';
        v_sql := v_sql || '   WHEN A.QUANTIDADE_E > 0 THEN                                                    ';
        v_sql := v_sql || '    ROUND((NVL(XML.VLR_ICMS_TP, 0) / A.QUANTIDADE_E), 2)                              ';
        v_sql := v_sql || '   ELSE                                                                            ';
        v_sql := v_sql || '    0                                                                              ';
        v_sql := v_sql || ' END) VLR_ICMS_XML_UNIT,                                                           ';
        v_sql := v_sql || ' (CASE                                                                             ';
        v_sql := v_sql || '   WHEN A.QUANTIDADE_E > 0 THEN                                                    ';
        v_sql := v_sql || '    ROUND(((NVL(XML.VLR_ICMS_ST_TP, 0) +                                              ';
        v_sql := v_sql || '          NVL(XML.VLR_ICMSST_RET_TP, 0)) / A.QUANTIDADE_E),                           ';
        v_sql := v_sql || '          2)                                                                       ';
        v_sql := v_sql || '   ELSE                                                                            ';
        v_sql := v_sql || '    0                                                                              ';
        v_sql := v_sql || ' END) VLR_ICMS_ST_XML_UNIT,                                                        ';
        v_sql := v_sql || ' (CASE                                                                             ';
        v_sql := v_sql || '   WHEN A.QUANTIDADE_E > 0 THEN                                                    ';
        v_sql := v_sql || '    ROUND(((NVL(XML.VLR_BASE_ICMS_ST_TP, 0) +                                         ';
        v_sql := v_sql || '          NVL(XML.VLR_BASE_ICMSST_RET_TP, 0)) / A.QUANTIDADE_E),                      ';
        v_sql := v_sql || '          2)                                                                       ';
        v_sql := v_sql || '   ELSE                                                                            ';
        v_sql := v_sql || '    0                                                                              ';
        v_sql := v_sql || ' END) VLR_BASE_ICMS_ST_XML_UNIT,                                                   ';
        v_sql := v_sql || ' TRUNC(NVL(XML.VLR_FCP_TP/A.QUANTIDADE_E,0),2) VLR_FCP_XML_UNIT,                      ';
        v_sql := v_sql || ' TRUNC(NVL(XML.VLR_FCST_TP/A.QUANTIDADE_E,0),2) VLR_FCST_XML_UNIT,                    ';
        v_sql := v_sql || ' TRUNC(NVL(XML.VLR_FCRT_TP/A.QUANTIDADE_E,0),2) VLR_FCRT_XML_UNIT                     ';
        ---
        v_sql := v_sql || 'FROM ' || vp_tabela_pmc_mva || ' A, ';
        v_sql := v_sql || '     MSAF.DP$P_PMC_ALIQ C, '; --GTT
        v_sql := v_sql || '     MSAF.DP$P_PMC_VLR D, '; --GTT
        v_sql := v_sql || '     MSAF.DPSP_PS_LISTA LIS ,';
        v_sql := v_sql || '     MSAFI.PS_XML_FORN_TP  XML,';
        v_sql := v_sql || '     MSAFI.DPSP_MSAF_ANTECIPACAO ANT ';
        ---
        v_sql := v_sql || 'WHERE A.PROC_ID     = ' || vp_proc_instance;
        v_sql := v_sql || '  AND A.COD_ESTAB   = ''' || vp_cod_estab || ''' ';
        v_sql := v_sql || '  AND A.COD_PRODUTO = LIS.COD_PRODUTO ';
        v_sql := v_sql || '  AND LIS.EFFDT = (SELECT MAX(LL.EFFDT) ';
        v_sql := v_sql || '                   FROM MSAF.DPSP_PS_LISTA LL ';
        v_sql := v_sql || '                   WHERE LL.COD_PRODUTO = LIS.COD_PRODUTO ';
        v_sql := v_sql || '                     AND LL.EFFDT <= A.DATA_FISCAL) ';
        ---
        v_sql := v_sql || '  AND A.DATA_FISCAL = C.DATA_FISCAL (+) ';
        v_sql := v_sql || '  AND A.COD_PRODUTO = C.COD_PRODUTO (+) ';
        ---
        v_sql := v_sql || '  AND A.NUM_AUTENTIC_NFE_E = XML.NFE_VERIF_CODE_PBL(+) ';
        v_sql := v_sql || '  AND A.COD_PRODUTO_E = XML.INV_ITEM_ID(+) ';
        --    V_SQL := V_SQL || '  AND A.NUM_ITEM_E = XML.NF_BRL_LINE_NUM(+) ';

        v_sql := v_sql || '  AND A.COD_ESTAB_E = ANT.COD_ESTAB(+) ';
        v_sql := v_sql || '  AND A.NUM_CONTROLE_DOCTO_E = ANT.NUM_CONTROLE_DOCTO(+) ';
        v_sql := v_sql || '  AND A.NUM_ITEM_E = ANT.NUM_ITEM(+) ';
        ---
        v_sql := v_sql || '  AND A.DATA_FISCAL = D.DATA_FISCAL (+) ';
        v_sql := v_sql || '  AND A.COD_PRODUTO = D.COD_PRODUTO (+) ';
        v_sql := v_sql || '  ) ';

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
                raise_application_error ( -20004
                                        , '!ERRO INSERT RESULTADO!' );
        END;
    END;

    PROCEDURE truncate_temp_tbl ( vp_proc_id IN NUMBER )
    IS
    BEGIN
        FOR temp_table IN ( SELECT table_name
                              FROM msafi.dpsp_msaf_tmp_control
                             WHERE proc_id = vp_proc_id ) LOOP
            BEGIN
                EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || temp_table.table_name;
            EXCEPTION
                WHEN OTHERS THEN
                    loga ( '[NAO FOI POSSIVEL TRUNCATE][' || temp_table.table_name || ']'
                         , FALSE );
            END;
        END LOOP;
    END; --PROCEDURE TRUNCATE_TEMP_TBL

    PROCEDURE create_tab_aux ( vp_proc_instance IN NUMBER
                             , vp_tab_aux_c   OUT VARCHAR2
                             , vp_tab_aux_f   OUT VARCHAR2
                             , vp_tab_aux_co   OUT VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 5000 );
    BEGIN
        --TAB AUXILIAR CD
        vp_tab_aux_c := 'DP$P_PMC_AUXC' || vp_proc_instance;
        v_sql := 'CREATE TABLE ' || vp_tab_aux_c;
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || ' COD_ESTAB VARCHAR2(6), ';
        v_sql := v_sql || ' COD_PRODUTO VARCHAR2(12), ';
        v_sql := v_sql || ' DATA_FISCAL_S DATE ';
        v_sql := v_sql || ' ) ' || v_tab_footer;

        EXECUTE IMMEDIATE v_sql;

        save_tmp_control ( vp_proc_instance
                         , vp_tab_aux_c );

        v_sql := 'CREATE UNIQUE INDEX PKC_PMC_' || vp_proc_instance || ' ON ' || vp_tab_aux_c;
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || ' COD_ESTAB, ';
        v_sql := v_sql || ' COD_PRODUTO, ';
        v_sql := v_sql || ' DATA_FISCAL_S ';
        v_sql := v_sql || ' ) ' || v_idx_footer;

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX1C_PMC_' || vp_proc_instance || ' ON ' || vp_tab_aux_c;
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || ' COD_PRODUTO, ';
        v_sql := v_sql || ' DATA_FISCAL_S ';
        v_sql := v_sql || ' ) ' || v_idx_footer;

        EXECUTE IMMEDIATE v_sql;

        --TAB AUXILIAR FILIAL
        vp_tab_aux_f := 'DP$P_PMC_AUXF' || vp_proc_instance;
        v_sql := 'CREATE TABLE ' || vp_tab_aux_f;
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || ' COD_ESTAB VARCHAR2(6), ';
        v_sql := v_sql || ' COD_PRODUTO VARCHAR2(12), ';
        v_sql := v_sql || ' DATA_FISCAL_S DATE ';
        v_sql := v_sql || ' ) ' || v_tab_footer;

        EXECUTE IMMEDIATE v_sql;

        save_tmp_control ( vp_proc_instance
                         , vp_tab_aux_f );

        v_sql := 'CREATE UNIQUE INDEX PKF_PMC_' || vp_proc_instance || ' ON ' || vp_tab_aux_f;
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || ' COD_ESTAB, ';
        v_sql := v_sql || ' COD_PRODUTO, ';
        v_sql := v_sql || ' DATA_FISCAL_S ';
        v_sql := v_sql || ' ) ' || v_idx_footer;

        EXECUTE IMMEDIATE v_sql;

        --TAB AUXILIAR CDIRETA
        vp_tab_aux_co := 'DP$P_PMC_AUXCO' || vp_proc_instance;
        v_sql := 'CREATE TABLE ' || vp_tab_aux_co;
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || ' COD_ESTAB VARCHAR2(6), ';
        v_sql := v_sql || ' COD_PRODUTO VARCHAR2(12), ';
        v_sql := v_sql || ' DATA_FISCAL_S DATE ';
        v_sql := v_sql || ' ) ' || v_tab_footer;

        EXECUTE IMMEDIATE v_sql;

        save_tmp_control ( vp_proc_instance
                         , vp_tab_aux_co );

        v_sql := 'CREATE UNIQUE INDEX PKO_' || vp_proc_instance || ' ON ' || vp_tab_aux_co;
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || ' COD_ESTAB, ';
        v_sql := v_sql || ' COD_PRODUTO, ';
        v_sql := v_sql || ' DATA_FISCAL_S ';
        v_sql := v_sql || ' ) ' || v_idx_footer;

        EXECUTE IMMEDIATE v_sql;
    END;

    PROCEDURE executar_lote ( p_data_ini DATE
                            , p_data_fim DATE
                            , p_rel VARCHAR2
                            , p_uf VARCHAR2
                            , p_perfil VARCHAR2
                            , p_empresa VARCHAR2
                            , p_usuario VARCHAR2
                            , p_procorig VARCHAR2
                            , p_lojas lib_proc.vartab )
    IS
        mproc_id INTEGER;
    BEGIN
        lib_parametros.salvar ( 'EMPRESA'
                              , p_empresa );
        lib_parametros.salvar ( 'USUARIO'
                              , p_usuario );
        lib_parametros.salvar ( 'PROCORIG'
                              , p_procorig );
        lib_parametros.salvar ( 'PDESC'
                              , 'Processamento PMC em LOTE' || CHR ( 10 ) );

        mproc_id :=
            executar ( p_data_ini
                     , p_data_fim
                     , p_uf
                     , p_perfil
                     , 'N'
                     , p_lojas );
    END;

    FUNCTION executar ( p_data_ini DATE
                      , p_data_fim DATE
                      , p_uf VARCHAR2
                      , p_perfil VARCHAR2
                      , p_log VARCHAR2
                      , p_lojas lib_proc.vartab )
        RETURN INTEGER
    IS
        mproc_id INTEGER;
        i1 INTEGER;

        TYPE a_estabs_t IS TABLE OF VARCHAR2 ( 6 );

        a_estabs a_estabs_t := a_estabs_t ( );
        a_estab_part a_estabs_t := a_estabs_t ( );

        p_proc_instance VARCHAR2 ( 30 );
        --
        --TABELAS TEMP
        v_tab_entrada_c VARCHAR2 ( 30 ) := '';
        v_tab_entrada_f VARCHAR2 ( 30 ) := '';
        v_tab_entrada_co VARCHAR2 ( 30 ) := '';
        v_tabela_saida VARCHAR2 ( 30 );
        v_tabela_pmc_mva VARCHAR2 ( 30 );
        v_tab_aux_c VARCHAR2 ( 30 );
        v_tab_aux_f VARCHAR2 ( 30 );
        v_tab_aux_co VARCHAR2 ( 30 );
        v_tab_x07 VARCHAR2 ( 30 );
        v_tab_x08 VARCHAR2 ( 30 );
        ---
        v_sql VARCHAR2 ( 4000 );
        v_insert VARCHAR2 ( 5000 );
        v_data_hora_ini VARCHAR2 ( 20 );
        v_qtde_saida NUMBER := 0;
        v_txt_temp VARCHAR2 ( 1024 ) := '';
        v_qtde INTEGER := 0;

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

        ---VAR PARA PERFIL---------
        p_origem1 VARCHAR2 ( 1 );
        p_origem2 VARCHAR2 ( 1 );
        p_origem3 VARCHAR2 ( 1 );
        p_origem4 VARCHAR2 ( 1 );
        p_compra_direta VARCHAR2 ( 1 );
        p_cd1 VARCHAR2 ( 6 );
        p_cd2 VARCHAR2 ( 6 );
        p_cd3 VARCHAR2 ( 6 );
        p_cd4 VARCHAR2 ( 6 );
        v_quebra_atual INTEGER;
        v_parametro VARCHAR2 ( 200 );
        v_estabs VARCHAR2 ( 5000 );

        --VAR PARA DBLINKS------------
        --V_DSP_DBLINK VARCHAR2(20) := '@DBLINK_DBMSPHOM';
        --V_DP_DBLINK  VARCHAR2(20) := '@DBLINK_DBMRJHOM';
        v_dsp_dblink VARCHAR2 ( 20 ) := '@DBLINK_DBMSPPRD';
        v_dp_dblink VARCHAR2 ( 20 ) := '@DBLINK_DBMRJPRD';
    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET TEMP_UNDO_ENABLED=FALSE '; --EVITAR PROBLEMAS DE GRAVACAO NAS GTTs

        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS='',.'' ';

        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        musuario := lib_parametros.recuperar ( 'USUARIO' );

        mproc_id :=
            lib_proc.new ( 'DPSP_PMC_X_MVA_CPROC'
                         , 48
                         , 150 );
        lib_proc.add_tipo ( mproc_id
                          , 1
                          ,    TO_CHAR ( SYSDATE
                                       , 'YYYYMMDDHH24MISS' )
                            || '_RESSARCIMENTO_PMC_x_MVA'
                          , 1 );

        --MARCAR INCIO DA EXECUCAO
        v_data_hora_ini :=
            TO_CHAR ( SYSDATE
                    , 'DD/MM/YYYY HH24:MI.SS' );
        v_module := $$plsql_unit || '_' || mproc_id;
        v_p_log := p_log; --GRAVAR LOG SE 'S'

        lib_proc.add_header ( 'Executar processamento do ressarcimento PMC x MVA'
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

        ---GERAR CHAVE PROC_ID
        p_proc_instance := mproc_id;
        ---------------------
        loga ( '[::INICIO DO PROCESSAMENTO::][' || p_proc_instance || ']'
             , FALSE );
        loga ( '[PERIODO][' || v_data_inicial || '][' || v_data_final || ']'
             , FALSE );

        ---
        IF msafi.get_trava_info ( 'PMC_MVA'
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

        --PREPARAR LOJAS
        IF ( p_lojas.COUNT > 0 ) THEN
            i1 := p_lojas.FIRST;

            WHILE i1 IS NOT NULL LOOP
                a_estabs.EXTEND ( );
                a_estabs ( a_estabs.LAST ) := p_lojas ( i1 );
                i1 := p_lojas.NEXT ( i1 );
            END LOOP;
        END IF;

        --ATUALIZAR LISTA DE MEDICAMENTOS
        dbms_application_info.set_module ( v_module
                                         , '1 ATUALIZA_LISTA' );
        msafi.atualiza_lista;
        loga ( '[ATUALIZA_LISTA][OK]'
             , FALSE );

        --OBTER PARAMETROS DO PERFIL SELECIONADO
        dbms_application_info.set_module ( v_module
                                         , '2 GET_PARAM_PERFIL' );
        get_param_perfil ( p_perfil
                         , p_compra_direta
                         , p_origem1
                         , p_cd1
                         , p_origem2
                         , p_cd2
                         , p_origem3
                         , p_cd3
                         , p_origem4
                         , p_cd4 );
        loga ( '[GET_PARAM_PERFIL][OK]'
             , FALSE );

        --OBTER VALOR PADRAO PARA QUEBRA DE PROCESSAMENTO
        v_quebra_atual :=
            get_param_quebra ( p_perfil
                             , v_qtde_default );

        v_parametro :=
               '[PROC]['
            || mproc_id
            || ']-['
            || p_data_ini
            || ' A '
            || p_data_fim
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
            || ']-[UF]['
            || p_uf
            || ']-[PERFIL]['
            || p_perfil
            || ']';
        loga ( v_parametro
             , FALSE );

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

        --CRIAR TABELAs TMP FISICAS
        create_tab_saida ( p_proc_instance
                         , v_tabela_saida );
        create_tab_entrada_cd ( p_proc_instance
                              , v_tab_entrada_c );
        create_tab_entrada_f ( p_proc_instance
                             , v_tab_entrada_f );
        create_tab_entrada_co ( p_proc_instance
                              , v_tab_entrada_co );
        create_tab_pmc_mva ( p_proc_instance
                           , v_tabela_pmc_mva );
        create_tab_aux ( p_proc_instance
                       , v_tab_aux_c
                       , v_tab_aux_f
                       , v_tab_aux_co );
        loga ( '[TABs TEMP][OK]'
             , FALSE );

        --EXECUTAR FILIAIS POR QUEBRA
        i1 := 0;

        FOR est IN a_estabs.FIRST .. a_estabs.COUNT --(99)
                                                   LOOP
            i1 := i1 + 1;
            a_estab_part.EXTEND ( );
            a_estab_part ( i1 ) := a_estabs ( est );

            IF MOD ( a_estab_part.COUNT
                   , v_quebra_atual ) = 0
            OR ( est = a_estabs.COUNT ) --(88)
                                       THEN
                i1 := 0;

                --CARREGAR SAIDAS INI-------------
                dbms_application_info.set_module ( v_module
                                                 , '3 LOAD_SAIDAS [' || a_estab_part.COUNT || ']' );
                v_estabs := ' ';

                FOR i IN 1 .. a_estab_part.COUNT LOOP
                    v_estabs := v_estabs || '''' || a_estab_part ( i ) || ''',';
                    loga ( '>> ESTAB: ' || a_estab_part ( i )
                         , FALSE ); ---COMENTARIO PARA LOG DA EXECUCAO EM LOTE
                END LOOP;

                v_estabs :=
                    SUBSTR ( v_estabs
                           , 1
                           , LENGTH ( v_estabs ) - 1 );
                ---
                load_saidas ( p_proc_instance
                            , v_estabs
                            , p_data_ini
                            , p_data_fim
                            , v_tabela_saida
                            , v_data_hora_ini );
                dbms_stats.gather_table_stats ( 'MSAF'
                                              , v_tabela_saida );

                EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || v_tabela_saida            INTO v_qtde_saida;

                loga ( '[LOAD_SAIDAS][OK][' || v_qtde_saida || ']'
                     , FALSE );

                --CARREGAR SAIDAS FIM-------------

                IF ( v_qtde_saida > 0 ) THEN --SE NAO HOUVER SAIDA, ENCERRA
                    --CRIAR E CARREGAR TABELAS TEMP DE ALIQ E PMC DO PEOPLESOFT
                    load_aliq_pmc ( p_proc_instance
                                  , v_tabela_saida
                                  , p_uf
                                  , p_data_fim );

                    --CARREGAR DADOS DE ENTRADA-INI----------------------------------------------------------
                    --CARREGAR DADOS ENTRADA COMPRA DIRETA NO INICIO
                    IF ( p_compra_direta = 'I' ) THEN
                        EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || v_tabela_saida            INTO v_qtde;

                        IF ( v_qtde > 0 ) THEN
                            --CARREGAR TEMPORARIAS ENTRADA NAS FILIAIS COMPRA DIRETA
                            dbms_application_info.set_module ( v_module
                                                             , '7 COMPRA DIRETA' );
                            load_entradas ( p_proc_instance
                                          , ''
                                          , v_data_inicial
                                          , v_data_final
                                          , 'CO'
                                          , v_tab_entrada_co
                                          , v_tabela_saida
                                          , ''
                                          , v_tab_entrada_f
                                          , ''
                                          , v_tab_entrada_c
                                          , v_tab_aux_co
                                          , mproc_id
                                          , v_tab_x07
                                          , v_tab_x08 );
                        END IF;

                        loga ( '[ENTRADA CDIRETA][END]'
                             , FALSE );
                    END IF;

                    ---
                    IF ( p_cd1 IS NOT NULL ) THEN
                        IF ( p_origem1 = 'L' ) THEN
                            ---ENTRADA NA FILIAL ORIGEM CD
                            dbms_application_info.set_module ( v_module
                                                             , '7 ENTRADA FILIAIS CD ' || p_cd1 );
                            load_entradas ( p_proc_instance
                                          , ''
                                          , v_data_inicial
                                          , v_data_final
                                          , 'F'
                                          , v_tab_entrada_f
                                          , v_tabela_saida
                                          , p_cd1
                                          , v_tab_entrada_f
                                          , ''
                                          , v_tab_entrada_c
                                          , v_tab_aux_f
                                          , mproc_id
                                          , v_tab_x07
                                          , v_tab_x08 );
                        ELSIF ( p_origem1 = 'C' ) THEN
                            ---ENTRADA NO CD
                            dbms_application_info.set_module ( v_module
                                                             , '7 ENTRADA CD ' || p_cd1 );
                            load_entradas ( p_proc_instance
                                          , p_cd1
                                          , v_data_inicial
                                          , v_data_final
                                          , 'C'
                                          , v_tab_entrada_c
                                          , v_tabela_saida
                                          , p_cd1
                                          , v_tab_entrada_f
                                          , ''
                                          , v_tab_entrada_c
                                          , v_tab_aux_c
                                          , mproc_id
                                          , v_tab_x07
                                          , v_tab_x08 );
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
                                                             , '7 ENTRADA FILIAIS CD ' || p_cd2 );
                            load_entradas ( p_proc_instance
                                          , ''
                                          , v_data_inicial
                                          , v_data_final
                                          , 'F'
                                          , v_tab_entrada_f
                                          , v_tabela_saida
                                          , p_cd2
                                          , v_tab_entrada_f
                                          , ''
                                          , v_tab_entrada_c
                                          , v_tab_aux_f
                                          , mproc_id
                                          , v_tab_x07
                                          , v_tab_x08 );
                        ELSIF ( p_origem2 = 'C' ) THEN
                            ---ENTRADA NO CD
                            dbms_application_info.set_module ( v_module
                                                             , '7 ENTRADA CD ' || p_cd2 );
                            load_entradas ( p_proc_instance
                                          , p_cd2
                                          , v_data_inicial
                                          , v_data_final
                                          , 'C'
                                          , v_tab_entrada_c
                                          , v_tabela_saida
                                          , p_cd2
                                          , v_tab_entrada_f
                                          , ''
                                          , v_tab_entrada_c
                                          , v_tab_aux_c
                                          , mproc_id
                                          , v_tab_x07
                                          , v_tab_x08 );
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
                                                             , '7 ENTRADA FILIAIS CD ' || p_cd3 );
                            load_entradas ( p_proc_instance
                                          , ''
                                          , v_data_inicial
                                          , v_data_final
                                          , 'F'
                                          , v_tab_entrada_f
                                          , v_tabela_saida
                                          , p_cd3
                                          , v_tab_entrada_f
                                          , ''
                                          , v_tab_entrada_c
                                          , v_tab_aux_f
                                          , mproc_id
                                          , v_tab_x07
                                          , v_tab_x08 );
                        ELSIF ( p_origem3 = 'C' ) THEN
                            ---ENTRADA NO CD
                            dbms_application_info.set_module ( v_module
                                                             , '7 ENTRADA CD ' || p_cd3 );
                            load_entradas ( p_proc_instance
                                          , p_cd3
                                          , v_data_inicial
                                          , v_data_final
                                          , 'C'
                                          , v_tab_entrada_c
                                          , v_tabela_saida
                                          , p_cd3
                                          , v_tab_entrada_f
                                          , ''
                                          , v_tab_entrada_c
                                          , v_tab_aux_c
                                          , mproc_id
                                          , v_tab_x07
                                          , v_tab_x08 );
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
                                          , v_tab_entrada_f
                                          , v_tabela_saida
                                          , p_cd4
                                          , v_tab_entrada_f
                                          , ''
                                          , v_tab_entrada_c
                                          , v_tab_aux_f
                                          , mproc_id
                                          , v_tab_x07
                                          , v_tab_x08 );
                        ELSIF ( p_origem4 = 'C' ) THEN
                            ---ENTRADA NO CD
                            dbms_application_info.set_module ( v_module
                                                             , '7 ENTRADA CD ' || p_cd4 );
                            load_entradas ( p_proc_instance
                                          , p_cd4
                                          , v_data_inicial
                                          , v_data_final
                                          , 'C'
                                          , v_tab_entrada_c
                                          , v_tabela_saida
                                          , p_cd4
                                          , v_tab_entrada_f
                                          , ''
                                          , v_tab_entrada_c
                                          , v_tab_aux_c
                                          , mproc_id
                                          , v_tab_x07
                                          , v_tab_x08 );
                        END IF;

                        loga ( '[ENTRADA CD / FILIAL 4][END]'
                             , FALSE );
                    END IF;

                    --CARREGAR DADOS ENTRADA COMPRA DIRETA NO FINAL
                    IF ( p_compra_direta = 'F' ) THEN
                        EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || v_tabela_saida            INTO v_qtde;

                        IF ( v_qtde > 0 ) THEN
                            --CARREGAR TEMPORARIAS ENTRADA NAS FILIAIS COMPRA DIRETA
                            dbms_application_info.set_module ( v_module
                                                             , '7 COMPRA DIRETA' );
                            load_entradas ( p_proc_instance
                                          , ''
                                          , v_data_inicial
                                          , v_data_final
                                          , 'CO'
                                          , v_tab_entrada_co
                                          , v_tabela_saida
                                          , ''
                                          , v_tab_entrada_f
                                          , ''
                                          , v_tab_entrada_c
                                          , v_tab_aux_co
                                          , mproc_id
                                          , v_tab_x07
                                          , v_tab_x08 );
                        END IF;

                        loga ( '[ENTRADA CDIRETA][END]'
                             , FALSE );
                    END IF;

                    --CARREGAR DADOS DE ENTRADA-FIM----------------------------------------------------------

                    --STATS DAS TABELAS DE ENTRADA-INI
                    dbms_stats.gather_table_stats ( 'MSAF'
                                                  , v_tab_entrada_c );
                    dbms_stats.gather_table_stats ( 'MSAF'
                                                  , v_tab_entrada_f );
                    dbms_stats.gather_table_stats ( 'MSAF'
                                                  , v_tab_entrada_co );

                    EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || v_tab_entrada_c            INTO v_qtde;

                    loga ( '[ENTRADA CD][OK][' || v_qtde || ']'
                         , FALSE );

                    EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || v_tab_entrada_f            INTO v_qtde;

                    loga ( '[ENTRADA FILIAL][OK][' || v_qtde || ']'
                         , FALSE );

                    EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || v_tab_entrada_co            INTO v_qtde;

                    loga ( '[ENTRADA CDIRETA][OK][' || v_qtde || ']'
                         , FALSE );
                    --STATS DAS TABELAS DE ENTRADA-FIM

                    --CARREGAR NFs DO PEOPLE
                    dbms_application_info.set_module ( v_module
                                                     , '8 LOAD_NF_PEOPLE' );
                    load_nf_people ( p_proc_instance
                                   , v_tab_entrada_c
                                   , v_tab_entrada_f
                                   , v_tab_entrada_co );

                    --LOOP PARA CADA FILIAL-INI--------------------------------------------------------------------------------------
                    --FOR i IN A_ESTAB_PART.FIRST .. A_ESTAB_PART.LAST
                    --LOOP
                    --ASSOCIAR SAIDAS COM SUAS ULTIMAS ENTRADAS
                    IF ( p_compra_direta = 'I' ) THEN
                        dbms_application_info.set_module ( v_module
                                                         , '9 SAIDAS XREF ENTRADAS CDIRETA' );
                        get_compra_direta ( p_proc_instance
                                          , ''
                                          , v_data_inicial
                                          , v_data_final
                                          , v_tab_entrada_co
                                          , v_tabela_saida
                                          , v_tabela_pmc_mva
                                          , v_data_hora_ini );
                    END IF;

                    ---
                    IF ( p_cd1 IS NOT NULL ) THEN
                        dbms_application_info.set_module ( v_module
                                                         , '9 SAIDAS XREF ENTRADAS CD1' );

                        IF ( p_origem1 = 'L' ) THEN
                            --ENTRADA NAS FILIAIS
                            get_entradas_filial ( p_proc_instance
                                                , ''
                                                , p_cd1
                                                , v_data_inicial
                                                , v_data_final
                                                , v_tab_entrada_f
                                                , v_tabela_saida
                                                , v_tabela_pmc_mva
                                                , v_data_hora_ini );
                        ELSIF ( p_origem1 = 'C' ) THEN
                            --ENTRADA NOS CDs
                            get_entradas_cd ( p_proc_instance
                                            , ''
                                            , p_cd1
                                            , v_data_inicial
                                            , v_data_final
                                            , v_tab_entrada_c
                                            , v_tabela_saida
                                            , v_tabela_pmc_mva
                                            , v_data_hora_ini );
                        END IF;
                    END IF;

                    IF ( p_cd2 IS NOT NULL ) THEN
                        dbms_application_info.set_module ( v_module
                                                         , '9 SAIDAS XREF ENTRADAS CD2' );

                        IF ( p_origem2 = 'L' ) THEN
                            --ENTRADA NAS FILIAIS
                            get_entradas_filial ( p_proc_instance
                                                , ''
                                                , p_cd2
                                                , v_data_inicial
                                                , v_data_final
                                                , v_tab_entrada_f
                                                , v_tabela_saida
                                                , v_tabela_pmc_mva
                                                , v_data_hora_ini );
                        ELSIF ( p_origem2 = 'C' ) THEN
                            --ENTRADA NOS CDs
                            get_entradas_cd ( p_proc_instance
                                            , ''
                                            , p_cd2
                                            , v_data_inicial
                                            , v_data_final
                                            , v_tab_entrada_c
                                            , v_tabela_saida
                                            , v_tabela_pmc_mva
                                            , v_data_hora_ini );
                        END IF;
                    END IF;

                    IF ( p_cd3 IS NOT NULL ) THEN
                        dbms_application_info.set_module ( v_module
                                                         , '9 SAIDAS XREF ENTRADAS CD3' );

                        IF ( p_origem3 = 'L' ) THEN
                            --ENTRADA NAS FILIAIS
                            get_entradas_filial ( p_proc_instance
                                                , ''
                                                , p_cd3
                                                , v_data_inicial
                                                , v_data_final
                                                , v_tab_entrada_f
                                                , v_tabela_saida
                                                , v_tabela_pmc_mva
                                                , v_data_hora_ini );
                        ELSIF ( p_origem3 = 'C' ) THEN
                            --ENTRADA NOS CDs
                            get_entradas_cd ( p_proc_instance
                                            , ''
                                            , p_cd3
                                            , v_data_inicial
                                            , v_data_final
                                            , v_tab_entrada_c
                                            , v_tabela_saida
                                            , v_tabela_pmc_mva
                                            , v_data_hora_ini );
                        END IF;
                    END IF;

                    IF ( p_cd4 IS NOT NULL ) THEN
                        dbms_application_info.set_module ( v_module
                                                         , '9 SAIDAS XREF ENTRADAS CD4' );

                        IF ( p_origem4 = 'L' ) THEN
                            --ENTRADA NAS FILIAIS
                            get_entradas_filial ( p_proc_instance
                                                , ''
                                                , p_cd4
                                                , v_data_inicial
                                                , v_data_final
                                                , v_tab_entrada_f
                                                , v_tabela_saida
                                                , v_tabela_pmc_mva
                                                , v_data_hora_ini );
                        ELSIF ( p_origem4 = 'C' ) THEN
                            --ENTRADA NOS CDs
                            get_entradas_cd ( p_proc_instance
                                            , ''
                                            , p_cd4
                                            , v_data_inicial
                                            , v_data_final
                                            , v_tab_entrada_c
                                            , v_tabela_saida
                                            , v_tabela_pmc_mva
                                            , v_data_hora_ini );
                        END IF;
                    END IF;

                    ---
                    IF ( p_compra_direta = 'F' ) THEN
                        dbms_application_info.set_module ( v_module
                                                         , '9 SAIDAS XREF ENTRADAS CDIRETA' );
                        get_compra_direta ( p_proc_instance
                                          , ''
                                          , v_data_inicial
                                          , v_data_final
                                          , v_tab_entrada_co
                                          , v_tabela_saida
                                          , v_tabela_pmc_mva
                                          , v_data_hora_ini );
                    END IF;

                    --SE NAO ACHOU ENTRADA, GRAVAR NA TABELA RESULTADO APENAS A SAIDA
                    dbms_application_info.set_module ( v_module
                                                     , '9 SAIDAS XREF SEM ENTRADAS' );
                    get_sem_entrada ( p_proc_instance
                                    , ''
                                    , v_data_inicial
                                    , v_data_final
                                    , v_tabela_saida
                                    , v_tabela_pmc_mva
                                    , v_data_hora_ini );

                    --LOGA('GET_ENTRADAS-FIM-' || A_ESTAB_PART(i), FALSE);

                    --END LOOP; --FOR i IN 1..A_ESTABS_PART.COUNT
                    dbms_stats.gather_table_stats ( 'MSAF'
                                                  , v_tabela_pmc_mva );
                    --LOOP PARA CADA FILIAL-FIM--------------------------------------------------------------------------------------

                    --ANTECIPACAO---------------
                    dbms_application_info.set_module ( v_module
                                                     , '13 GET ANTECIPACAO' );
                    get_antecipacao ( p_proc_instance
                                    , v_tab_entrada_c
                                    , v_tab_entrada_f
                                    , v_tab_entrada_co
                                    , v_tab_global_flag
                                    , v_tab_type
                                    , v_tab_footer );

                    --INSERIR DADOS-INI-------------------------------------------------------------------------------------------
                    dbms_application_info.set_module ( v_module
                                                     , '10 LOAD TAB PMC' );
                    loga ( '[INSERINDO RESULTADO][INI]'
                         , FALSE );

                    FOR i IN a_estab_part.FIRST .. a_estab_part.LAST LOOP
                        --LIMPAR DADOS DA TABELA FINAL DO PMC
                        delete_tbl ( a_estab_part ( i )
                                   , v_data_inicial
                                   , v_data_final );
                        ---GRAVAR DADOS FINAIS DO PMC
                        load_tab_pmc ( p_proc_instance
                                     , a_estab_part ( i )
                                     , v_tabela_pmc_mva );
                        loga ( '[INSERINDO RESULTADO][' || a_estab_part ( i ) || ']'
                             , FALSE );
                    END LOOP;

                    loga ( '[RESULTADO GRAVADO][FIM]'
                         , FALSE );
                --INSERIR DADOS-FIM-------------------------------------------------------------------------------------------

                END IF;

                --OBTER VALOR PADRAO PARA QUEBRA DE PROCESSAMENTO DINAMICAMENTE
                v_quebra_atual :=
                    get_param_quebra ( p_perfil
                                     , v_qtde_default );

                truncate_temp_tbl ( p_proc_instance );
                loga ( '[[FIM PARCIAL]]'
                     , FALSE );

                a_estab_part := a_estabs_t ( );
            END IF; --(88)
        END LOOP; --(99)

        --APAGAR TABELAS TEMPORARIAS
        delete_temp_tbl ( p_proc_instance );

        --DISPONIBILIZAR PERIODO PROCESSADO PARA TRAVA DE REPROCESSAMENTO
        msafi.add_trava_info ( 'PMC_MVA'
                             , TO_CHAR ( v_data_inicial
                                       , 'YYYY/MM' ) );

        loga ( '[FIM DO PROCESSAMENTO]'
             , FALSE );
        COMMIT;

        --ENVIAR EMAIL DE SUCESSO----------------------------------------
        dpsp_envia_email ( mcod_empresa
                         , v_data_inicial
                         , v_data_final
                         , ''
                         , 'S'
                         , v_data_hora_ini
                         , v_parametro
                         , musuario
                         , 'DPSP_PMC_X_MVA_CPROC' );
        -----------------------------------------------------------------

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

            --ENVIAR EMAIL DE ERRO-------------------------------------------
            dpsp_envia_email ( mcod_empresa
                             , v_data_inicial
                             , v_data_final
                             , SQLERRM
                             , 'E'
                             , v_data_hora_ini
                             , v_parametro
                             , musuario
                             , 'DPSP_PMC_X_MVA_CPROC' );
            -----------------------------------------------------------------

            lib_proc.close;
            COMMIT;
            RETURN mproc_id;
    END; /* FUNCTION EXECUTAR */
END dpsp_pmc_x_mva_cproc;
/
SHOW ERRORS;
