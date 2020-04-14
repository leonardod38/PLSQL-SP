Prompt Package Body DPSP_FIN1952_SAFX104_CPROC;
--
-- DPSP_FIN1952_SAFX104_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_fin1952_safx104_cproc
IS
    v_tab_footer VARCHAR2 ( 100 )
        := ' STORAGE (BUFFER_POOL KEEP) PCTFREE 10 NOLOGGING NOCOMPRESS CACHE TABLESPACE MSAF_WORK_TABLES ';
    vp_tab_safx VARCHAR2 ( 30 );
    vp_tab_x2013 VARCHAR2 ( 30 );
    vp_tab_aux1 VARCHAR2 ( 30 );

    mcod_empresa estabelecimento.cod_empresa%TYPE;
    mcod_usuario usuario_estab.cod_usuario%TYPE;
    mproc_id NUMBER;

    --Tipo, Nome e Descrição do Customizado
    mnm_tipo VARCHAR2 ( 100 ) := 'Ressarcimento';
    mnm_cproc VARCHAR2 ( 100 ) := 'Processar Carga SAFX104';
    mds_cproc VARCHAR2 ( 100 ) := 'Carregar tabela SAFX104';

    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );
    BEGIN
        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        mcod_usuario := lib_parametros.recuperar ( 'USUARIO' );

        lib_parametros.salvar ( 'EMPRESA'
                              , NVL ( mcod_empresa, msafi.dpsp.v_empresa ) );

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
                           , '01/01/1900'
                           , 'DD/MM/YYYY' );

        lib_proc.add_param ( pstr
                           , 'Data Final'
                           , --P_DATA_FIM
                            'DATE'
                           , 'TEXTBOX'
                           , 'S'
                           , SYSDATE - 1
                           , 'DD/MM/YYYY' );

        lib_proc.add_param ( pstr
                           , 'Código do Produto'
                           , --P_DATA_PAR
                            'VARCHAR2'
                           , 'TEXTBOX'
                           , 'S'
                           , '%'
                           , '##########' );

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
        COMMIT;
    ---
    END;

    FUNCTION moeda ( v_conteudo NUMBER )
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN TRIM ( TO_CHAR ( v_conteudo
                              , '9g999g999g990d00' ) );
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
                    , mcod_usuario
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

    ----------------------------------------------------------------------------ENVIA E-MAIL----------------------------------------------------------------------

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

            v_txt_email := 'ERRO no Processo de Carga SAFX2014 !';
            v_txt_email := v_txt_email || CHR ( 13 ) || '>> Parâmetros: ';
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Empresa : ' || vp_cod_empresa;
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Data Início : ' || vp_data_ini;
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Data Fim : ' || vp_data_fim;
            v_txt_email := v_txt_email || CHR ( 13 ) || '>> LOG: ';
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Executado por : ' || mcod_usuario;
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Hora Início : ' || vp_data_hora_ini;
            v_txt_email :=
                   v_txt_email
                || CHR ( 13 )
                || ' - Hora Término : '
                || TO_CHAR ( SYSDATE
                           , 'DD/MM/YYYY HH24:MI.SS' );
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Tempo Execução	: ' || v_tempo_exec;
            v_txt_email := v_txt_email || CHR ( 13 ) || '<< ERRO >> ' || vp_msg_oracle;
            v_assunto := 'Mastersaf - Relatório Processo de Carga SAFX2014 - ERRO';
        -- NOTIFICA('', 'S', V_ASSUNTO, V_TXT_EMAIL, 'DPSP_COMP_PAVU_CPROC');

        ELSE
            v_txt_email := 'Processo Processo de Carga SAFX2014 - com SUCESSO.';
            v_txt_email := v_txt_email || CHR ( 13 ) || '>> Parâmetros: ';
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Empresa : ' || vp_cod_empresa;
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Data Início : ' || vp_data_ini;
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Data Fim : ' || vp_data_fim;
            v_txt_email := v_txt_email || CHR ( 13 ) || '>> LOG: ';
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Executado por : ' || mcod_usuario;
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Hora Início : ' || vp_data_hora_ini;
            v_txt_email :=
                   v_txt_email
                || CHR ( 13 )
                || ' - Hora Término : '
                || TO_CHAR ( SYSDATE
                           , 'DD/MM/YYYY HH24:MI.SS' );
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Tempo Execução : ' || v_tempo_exec;
            v_assunto := 'Mastersaf - Relatório Comparativo de Abastecimento Pacheco - Concluído';
        --NOTIFICA('S', '', V_ASSUNTO, V_TXT_EMAIL, 'DPSP_COMP_PAVU_CPROC');

        END IF;
    END;

    ------------------------------------------------------------------------------------------------------------------------------------------------------

    PROCEDURE load_tmp ( vp_proc_instance IN NUMBER
                       , vp_data_ini IN DATE
                       , vp_data_fim IN DATE
                       , vp_produto IN VARCHAR2
                       , vp_tab_safx   OUT VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 5000 );
    BEGIN
        --- Cria tabela de produtos
        vp_tab_safx :=
            msaf.dpsp_create_tab_tmp ( vp_proc_instance
                                     , vp_proc_instance
                                     , 'TB_SAFX104'
                                     , mcod_usuario );

        IF ( vp_tab_safx = 'ERRO' ) THEN
            raise_application_error ( -20001
                                    , '!ERRO CREATE_SAFX_TABLE!' );
        END IF;

        loga ( vp_tab_safx );
        ---- Carrega Tabela de produtos

        v_sql := '   INSERT INTO ' || vp_tab_safx || ' ';
        v_sql := v_sql || '  SELECT  X.COD_PRODUTO ,      ';
        v_sql :=
               v_sql
            || '       REPLACE(REPLACE(MSAFI.PS_TRANSLATE(''DSP_ALIQ_ICMS'', X.ALIQ_INTERNA_ATUAL),''%'',''''),''<VLR INVALIDO>'','''') AS ALIQ_INTERNA,    ';
        v_sql := v_sql || '       X.REGIME_ST_DT_INI,     ';
        v_sql := v_sql || '       X.REGIME_ST_DT_FIM,      ';
        v_sql := v_sql || '       X.REGIME_ST_DT_INI AS ALIQUOTA_DT_INI,  ';
        v_sql := v_sql || '       X.REGIME_ST_DT_FIM AS ALIQUOTA_DT_FIM   ';
        v_sql := v_sql || 'FROM (  ';
        v_sql := v_sql || 'SELECT /*+driving_site(tab)*/ TAB.COD_PRODUTO, TAB.DATA_ATUAL AS REGIME_ST_DT_INI,   ';
        v_sql :=
               v_sql
            || '       LEAD(TAB.DATA_ATUAL,1,NULL) OVER (PARTITION BY TAB.COD_PRODUTO ORDER BY TAB.DATA_ATUAL) AS REGIME_ST_DT_FIM,  ';
        v_sql := v_sql || '       TAB.FINALIDADE_ATUAL, TAB.FINALIDADE_ANTERIOR,    ';
        v_sql := v_sql || '       TAB.ALIQ_INTERNA_ATUAL, TAB.ALIQ_INTERNA_ANTERIOR,   ';
        v_sql := v_sql || '       TAB.METODOLOGIA_ST    ';
        v_sql := v_sql || 'FROM (   ';
        v_sql := v_sql || 'SELECT A.INV_ITEM_ID AS COD_PRODUTO, A.EFFDT AS DATA_ATUAL,   ';
        v_sql := v_sql || '       A.PURCH_PROP_BRL AS FINALIDADE_ATUAL,    ';
        v_sql :=
               v_sql
            || '       LAG(A.PURCH_PROP_BRL,1,''-'') OVER (PARTITION BY A.INV_ITEM_ID ORDER BY A.EFFDT) AS FINALIDADE_ANTERIOR,  ';
        v_sql := v_sql || '       A.DSP_ALIQ_ICMS AS ALIQ_INTERNA_ATUAL,   ';
        v_sql :=
               v_sql
            || '       LAG(A.DSP_ALIQ_ICMS,1,''-'') OVER (PARTITION BY A.INV_ITEM_ID ORDER BY A.EFFDT) AS ALIQ_INTERNA_ANTERIOR,  ';
        v_sql := v_sql || '       A.DSP_TP_CALC_ST AS METODOLOGIA_ST  ';
        v_sql := v_sql || 'FROM MSAFI.PS_DSP_ITEM_LN_MVA A  ';
        v_sql := v_sql || 'WHERE A.SETID = ''GERAL''  ';

        IF vp_produto <> '%' THEN
            v_sql := v_sql || '  AND A.INV_ITEM_ID = ''' || vp_produto || ''' ';
        END IF;

        v_sql := v_sql || '  AND A.CRIT_STATE_TO_PBL = ''SP''  ';
        v_sql := v_sql || '  AND A.CRIT_STATE_FR_PBL = ''SP''  ';
        v_sql := v_sql || ') TAB  ';
        v_sql := v_sql || 'WHERE (TAB.FINALIDADE_ATUAL  <> TAB.FINALIDADE_ANTERIOR  ';
        v_sql := v_sql || '   OR TAB.ALIQ_INTERNA_ATUAL <> TAB.ALIQ_INTERNA_ANTERIOR)) X ';
        v_sql := v_sql || 'WHERE X.FINALIDADE_ATUAL = ''IST'' ';

        dbms_output.put_line ( '[SAFX]:' || SQL%ROWCOUNT );

        EXECUTE IMMEDIATE v_sql;

        COMMIT;
    END;

    -------------------------------------------------------------------------------------------------------------------------------------------------------------
    PROCEDURE load_x2013 ( vp_proc_instance IN NUMBER
                         , vp_data_ini IN DATE
                         , vp_data_fim IN DATE
                         , vp_produto IN VARCHAR2
                         , vp_tab_x2013   OUT VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 5000 );
    BEGIN
        --- Cria tabela de produtos
        vp_tab_x2013 :=
            msaf.dpsp_create_tab_tmp ( vp_proc_instance
                                     , vp_proc_instance
                                     , 'TB_X2013'
                                     , mcod_usuario );

        IF ( vp_tab_x2013 = 'ERRO' ) THEN
            raise_application_error ( -20001
                                    , '!ERRO CREATE_X2013_TABLE!' );
        END IF;

        loga ( vp_tab_x2013 );
        ---- Carrega Tabela de produtos

        v_sql := '   INSERT INTO ' || vp_tab_x2013 || ' ';
        v_sql :=
               v_sql
            || 'SELECT DECODE(B.CLASS_ITEM_DSP,''NL'',''1'',''RV'',''1'',''Y'',''1'' ,''UC'',''4'' ,''AF'',''5'',''AG'',''5'',''BR'',''5'',''PR'',''5'',''SV'',''5'' ,''5''  ) IDENT_PRODUTO, ';
        v_sql := v_sql || ' GRUPO_PRODUTO, IND_PRODUTO, COD_PRODUTO FROM X2013_PRODUTO A,  PS_ATRB_OPER_DSP B ';
        v_sql := v_sql || 'WHERE A.VALID_PRODUTO BETWEEN ''' || vp_data_ini || ''' AND ''' || vp_data_fim || ''' ';
        v_sql := v_sql || 'AND A.IND_PRODUTO = ''1'' ';

        IF vp_produto <> '%' THEN
            v_sql := v_sql || '  AND A.COD_PRODUTO = ''' || vp_produto || ''' ';
        END IF;

        v_sql := v_sql || ' AND B.SETID = ''GERAL'' ';
        v_sql := v_sql || ' AND B.INV_ITEM_ID = A.COD_PRODUTO(+)';
        v_sql := v_sql || 'AND A.VALID_PRODUTO = (SELECT MAX (A1.VALID_PRODUTO) ';
        v_sql := v_sql || '                       FROM MSAF.X2013_PRODUTO A1  ';
        v_sql := v_sql || '                       WHERE A1.COD_PRODUTO = A.COD_PRODUTO   ';
        v_sql := v_sql || '                       AND A1.IND_PRODUTO = A.IND_PRODUTO     ';
        v_sql := v_sql || '                       AND A1.VALID_PRODUTO <= SYSDATE) ';

        dbms_output.put_line ( '[X2013]:' || SQL%ROWCOUNT );

        EXECUTE IMMEDIATE v_sql;

        COMMIT;
    END;

    -------------------------------------------------------------------------------------------------------------------------------------------------------------
    PROCEDURE load_aux1 ( vp_proc_instance IN NUMBER
                        , vp_tab_safx IN VARCHAR2
                        , vp_tab_x2013 IN VARCHAR2
                        , vp_tab_aux1   OUT VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 5000 );
    BEGIN
        --- Cria tabela de produtos
        vp_tab_aux1 :=
            msaf.dpsp_create_tab_tmp ( vp_proc_instance
                                     , vp_proc_instance
                                     , 'TB_AUX1'
                                     , mcod_usuario );

        IF ( vp_tab_aux1 = 'ERRO' ) THEN
            raise_application_error ( -20001
                                    , '!ERRO CREATE_AUX1_TABLE!' );
        END IF;

        loga ( vp_tab_aux1 );
        ---- Carrega Tabela de produtos

        v_sql := '   INSERT INTO ' || vp_tab_aux1 || ' ';
        v_sql := v_sql || 'SELECT * FROM ' || vp_tab_safx || ' A ';
        v_sql := v_sql || 'WHERE EXISTS (SELECT ''X'' FROM  ';
        v_sql := v_sql || '' || vp_tab_x2013 || ' B ';
        v_sql := v_sql || 'WHERE A.COD_PRODUTO = B.COD_PRODUTO) ';

        dbms_output.put_line ( '[AUX1]:' || SQL%ROWCOUNT );

        EXECUTE IMMEDIATE v_sql;

        COMMIT;
    END;

    PROCEDURE load_aux_tab ( vp_proc_instance IN NUMBER
                           , vp_tab_aux1 IN VARCHAR2
                           , vp_produto IN VARCHAR2
                           , vp_tab_safx IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 5000 );
    BEGIN
        v_sql := 'INSERT INTO ' || vp_tab_aux1 || ' SELECT  ';
        v_sql :=
               v_sql
            || 'A.COD_PRODUTO, A.ALIQ_INTERNA, VALID_INICIAL AS REGIME_ST_DT_INI, VALID_FINAL AS REGIME_ST_DT_FIM,  VALID_INICIAL AS ALIQUOTA_DT_INI, VALID_FINAL AS ALIQUOTA_DT_FIM ';
        v_sql := v_sql || 'FROM ESP_SP_PROD_ST A  ';

        IF vp_produto <> '%' THEN
            v_sql :=
                   v_sql
                || 'WHERE A.COD_PRODUTO = '''
                || vp_produto
                || ''' AND NOT EXISTS (SELECT ''X'' FROM '
                || vp_tab_safx
                || ' B WHERE A.COD_PRODUTO = B.COD_PRODUTO ';
            v_sql :=
                   v_sql
                || 'AND A.ALIQ_INTERNA = B.ALIQ_INTERNA AND A.VALID_INICIAL = B.REGIME_ST_DT_INI AND VALID_FINAL IS NULL)  ';
        ELSE
            v_sql :=
                   v_sql
                || 'WHERE NOT EXISTS (SELECT ''X'' FROM '
                || vp_tab_safx
                || ' B WHERE A.COD_PRODUTO = B.COD_PRODUTO ';
            v_sql :=
                   v_sql
                || 'AND A.ALIQ_INTERNA = B.ALIQ_INTERNA AND A.VALID_INICIAL = B.REGIME_ST_DT_INI AND VALID_FINAL IS NULL)  ';
        END IF;

        --V_SQL := V_SQL ||'AND A.VALID_FINAL IS NULL ';
        v_sql := v_sql || 'ORDER BY A.COD_PRODUTO, A.ALIQ_INTERNA, A.VALID_INICIAL ASC  ';

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
                                    , '!ERRO INSERT LOAD_AUX_TAB!' );

            lib_proc.add ( dbms_utility.format_error_backtrace
                         , 1 );

            COMMIT;
    END;

    -------------------------------------------------------------------------------------------------------------------------------------------------------------
    PROCEDURE load_final ( vp_proc_instance IN NUMBER
                         , vp_tab_aux1 IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 5000 );
        v_count INTEGER;
    BEGIN
        SELECT COUNT ( * )
          INTO v_count
          FROM safx104;

        v_sql := ' BEGIN FOR C IN (SELECT A.COD_PRODUTO,   ';
        v_sql := v_sql || ' A.ALIQ_INTERNA, A.REGIME_ST_DT_INI, ';
        v_sql :=
               v_sql
            || ' CASE WHEN A.REGIME_ST_DT_fim >= lead(A.REGIME_ST_DT_ini,1,NULL) OVER (PARTITION BY A.COD_PRODUTO ORDER BY A.REGIME_ST_DT_FIM) THEN to_char(lead(A.REGIME_ST_DT_ini-1,1,NULL) OVER (PARTITION BY A.COD_PRODUTO ORDER BY A.REGIME_ST_DT_FIM) ,''YYYYMMDD'') ';
        v_sql :=
               v_sql
            || '      WHEN A.REGIME_ST_DT_INI < LEAD(A.REGIME_ST_DT_ini,1,NULL) OVER (PARTITION BY A.COD_PRODUTO ORDER BY A.REGIME_ST_DT_INI) THEN TO_CHAR(LEAD(A.REGIME_ST_DT_ini-1,1,NULL) OVER (PARTITION BY A.COD_PRODUTO ORDER BY A.REGIME_ST_DT_INI)  ,''YYYYMMDD'' ) ';
        v_sql := v_sql || '      ELSE TO_CHAR(A.REGIME_ST_DT_FIM,''YYYYMMDD'') END  AS REGIME_ST_DT_FIM ,   ';
        v_sql := v_sql || ' A.ALIQUOTA_DT_INI, A.ALIQUOTA_DT_FIM   ';
        v_sql := v_sql || ' FROM ' || vp_tab_aux1 || ' A   ';
        v_sql := v_sql || ' WHERE NOT EXISTS (SELECT ''X'' FROM ESP_SP_PROD_ST B WHERE A.COD_PRODUTO = B.COD_PRODUTO  ';
        v_sql := v_sql || ' AND A.ALIQ_INTERNA = B.ALIQ_INTERNA   ';
        v_sql := v_sql || ' AND (A.REGIME_ST_DT_INI = VALID_INICIAL  ';
        v_sql := v_sql || ' AND REGIME_ST_DT_FIM = B.VALID_INICIAL   ';
        v_sql := v_sql || ' OR A.ALIQUOTA_DT_INI = VALID_INICIAL     ';
        v_sql := v_sql || ' AND ALIQUOTA_DT_FIM = B.VALID_INICIAL))  ';
        v_sql := v_sql || ' ORDER BY A.COD_PRODUTO, A.REGIME_ST_DT_INI ASC ) LOOP  ';
        v_sql :=
               v_sql
            || ' INSERT INTO SAFX104 (TIPO_REGISTRO,	COD_ESTADO,	IND_PRODUTO,	COD_PRODUTO,	VALID_INICIAL,	ALIQ_INTERNA,	IND_PRODUTO_ASS,	COD_PRODUTO_ASS,	MODELO_LIVRO,	VALID_FINAL,	PRC_REDUCAO_BC,	RESERVADO1,	RESERVADO2,	RESERVADO3,	RESERVADO4,	RESERVADO5,	RESERVADO6,	RESERVADO7,	RESERVADO8)';
        v_sql := v_sql || ' SELECT ''1'' AS TIPO_REGISTRO,  ';
        v_sql := v_sql || ' ''SP'' AS COD_ESTADO ,  ';
        v_sql := v_sql || ' ''1''AS IND_PRODUTO,  ';
        v_sql := v_sql || ' C.COD_PRODUTO,  ';
        v_sql := v_sql || ' TO_CHAR(C.REGIME_ST_DT_INI,''YYYYMMDD'') AS VALID_INICIAL,  ';
        v_sql :=
               v_sql
            || ' RPAD(LPAD(C.ALIQ_INTERNA,3,0),7,0) ALIQ_INTERNA, ''@'' AS IND_PRODUTO_ASS, ''@'' AS COD_PRODUTO_ASS,''3'' AS MODELO_LIVRO,    ';
        v_sql := v_sql || '  C.REGIME_ST_DT_FIM AS VALID_FINAL   ';
        v_sql := v_sql || ' , ''@'' ,''@'' ,''@'' ,''@'' ,''@'' ,''@'' ,''@'' ,''@'' ,''@''   ';
        v_sql := v_sql || '  FROM DUAL ORDER BY 5 DESC; ';

        IF v_count = '500' THEN
            v_sql := v_sql || ' COMMIT;  ';
            v_count := 0;
        END IF;

        v_sql := v_sql || ' END LOOP; ';
        v_sql := v_sql || ' END; ';

        BEGIN
            EXECUTE IMMEDIATE v_sql;

            loga ( 'Tabela final - SAFX104 - Carregada com Sucesso' );
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
                                        , '!ERRO INSERT LOAD_FINAL!' );

                lib_proc.add ( dbms_utility.format_error_backtrace
                             , 1 );

                COMMIT;
        END;
    END;

    --------------------------------------------------------------------------------------------------------------------------------------------------------------

    FUNCTION executar ( p_data_ini DATE
                      , p_data_fim DATE
                      , p_produto VARCHAR2 )
        RETURN INTEGER
    IS
        mproc_id INTEGER;
        i1 INTEGER;

        v_proc_status NUMBER := 0;
        v_s_proc_status VARCHAR2 ( 16 );

        v_txt_temp VARCHAR2 ( 1024 ) := '';
        v_txt_basico VARCHAR2 ( 256 ) := '';
        v_vlr_tot_cred_2 VARCHAR2 ( 17 ) := '';
        v_vlr_tot_deb_2 VARCHAR2 ( 17 ) := '';

        TYPE a_estabs_t IS TABLE OF VARCHAR2 ( 6 );

        a_estabs a_estabs_t := a_estabs_t ( );

        --Variaveis genericas
        v_text01 VARCHAR2 ( 6000 );
        v_sep VARCHAR2 ( 1 ) := CHR ( 9 );
        p_proc_instance VARCHAR2 ( 30 );
        vp_proc_instance VARCHAR2 ( 30 );

        --
        TYPE cur_typ IS REF CURSOR;

        cr_cup cur_typ;

        ---
        v_sql_resultado VARCHAR2 ( 4000 );
        v_id_param NUMBER;
        v_data_hora_ini VARCHAR2 ( 20 );

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
        t_idx NUMBER := 0;
    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS='',.'' ';

        --Recuperar a empresa para o plano de execução caso não esteja sendo executado pelo diretamente na tela do Mastersaf
        lib_parametros.salvar ( 'EMPRESA'
                              , NVL ( mcod_empresa, msafi.dpsp.v_empresa ) );

        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        mcod_usuario := lib_parametros.recuperar ( 'USUARIO' );

        mproc_id :=
            lib_proc.new ( 'DPSP_FIN1952_SAFX104_CPROC'
                         , 48
                         , 150 );

        lib_proc.add_tipo ( mproc_id
                          , 1
                          ,    TO_CHAR ( SYSDATE
                                       , 'YYYYMMDDHH24MISS' )
                            || '_SAFX104'
                          , 1 );

        --MARCAR INCIO DA EXECUCAO
        v_data_hora_ini :=
            TO_CHAR ( SYSDATE
                    , 'DD/MM/YYYY HH24:MI.SS' );

        lib_proc.add_header ( 'Executar processamento do Carga da SAFX104'
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

        loga ( '<<' || mnm_cproc || '>>'
             , FALSE );
        loga ( '---INICIO DO PROCESSAMENTO---'
             , FALSE );

        dbms_application_info.set_module ( $$plsql_unit
                                         , 'PROC_ID: ' || mproc_id );

        loga ( 'Data execução: ' || v_data_hora_ini
             , FALSE );

        loga ( 'Usuário: ' || mcod_usuario
             , FALSE );
        loga ( 'Empresa: ' || mcod_empresa
             , FALSE );
        loga ( 'Período: ' || v_data_inicial || ' - ' || v_data_final
             , FALSE );
        loga ( 'Produto: ' || ( CASE WHEN p_produto = '%' THEN 'Todos os Produtos' ELSE p_produto END )
             , FALSE );

        --GERAR CHAVE PROC_ID
        SELECT ROUND ( dbms_random.VALUE ( 10000000000000
                                         , 999999999999999 ) )
          INTO vp_proc_instance
          FROM DUAL;

        loga ( '----------------------------------------'
             , FALSE );
        loga ( '>> PROC INSTANCE: ' || vp_proc_instance
             , FALSE );
        loga ( '----------------------------------------'
             , FALSE );

        load_tmp ( vp_proc_instance
                 , p_data_ini
                 , p_data_fim
                 , p_produto
                 , vp_tab_safx );
        --
        load_x2013 ( vp_proc_instance
                   , p_data_ini
                   , p_data_fim
                   , p_produto
                   , vp_tab_x2013 );
        --
        load_aux1 ( vp_proc_instance
                  , vp_tab_safx
                  , vp_tab_x2013
                  , vp_tab_aux1 );
        --
        load_aux_tab ( vp_proc_instance
                     , vp_tab_aux1
                     , p_produto
                     , vp_tab_safx );
        --
        load_final ( vp_proc_instance
                   , vp_tab_aux1 );

        -- DELETE_TEMP_TBL(VP_PROC_INSTANCE);
        --INSERIR DADOS-FIM-------------------------------------------------------------------------------------------
        --DISPONIBILIZAR PERIODO PROCESSADO PARA TRAVA DE REPROCESSAMENTO

        --ENVIAR EMAIL DE SUCESSO----------------------------------------
        --ENVIA_EMAIL(MCOD_EMPRESA, P_DATA_INICIAL, P_DATA_FINAL, '', 'S', V_DATA_HORA_INI);
        -----------------------------------------------------------------
        loga ( 'FIM DO PROCESSAMENTO, STATUS FINAL: [SUCESSO]'
             , FALSE );
        lib_proc.add ( 'FIM DO PROCESSAMENTO, STATUS FINAL: [SUCESSO]' );

        lib_proc.close ( );

        COMMIT;
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
    END; /* FUNCTION EXECUTAR */
END dpsp_fin1952_safx104_cproc;
/
SHOW ERRORS;
