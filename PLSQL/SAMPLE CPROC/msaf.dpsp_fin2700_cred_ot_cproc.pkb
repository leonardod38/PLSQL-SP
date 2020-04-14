Prompt Package Body DPSP_FIN2700_CRED_OT_CPROC;
--
-- DPSP_FIN2700_CRED_OT_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_fin2700_cred_ot_cproc
IS
    v_sel_data_fim VARCHAR2 ( 260 )
        := ' SELECT TRUNC( TO_DATE( :1 ,''DD/MM/YYYY'') + ROWNUM - 1) AS DATA_FIM, TRUNC( TO_DATE( :1 ,''DD/MM/YYYY'') + ROWNUM - 1) AS DATA_FIM FROM DUAL CONNECT BY ROWNUM <= LAST_DAY( TO_DATE( :1 ,''DD/MM/YYYY'') ) - TO_DATE( :1 ,''DD/MM/YYYY'') + 1 ORDER BY 1 DESC ';
    v_tab_footer VARCHAR2 ( 100 )
        := ' STORAGE (BUFFER_POOL KEEP) PCTFREE 10 NOLOGGING NOCOMPRESS CACHE TABLESPACE MSAF_WORK_TABLES ';
    mlinha VARCHAR2 ( 4000 );
    mpagina NUMBER := 0;

    mproc_id INTEGER;

    --Tipo, Nome e Descrição do Customizado
    mnm_tipo VARCHAR2 ( 100 ) := 'Ressarcimento';
    mnm_cproc VARCHAR2 ( 100 ) := 'Processar Crédito Outorgado/Débito PROTEGE/Limitação CD GO ';
    mds_cproc VARCHAR2 ( 100 )
        := 'Processamento do Relatório da Apuração crédito outorgado/débito PROTEGE/limitação crédito - GO';

    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );
    BEGIN
        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        mcod_usuario := lib_parametros.recuperar ( 'USUARIO' );

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
                           , ' '
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
                           , LPAD ( '-'
                                  , 120
                                  , '-' )
                           , 'VARCHAR2'
                           , 'TEXT'
                           , NULL
                           , NULL
                           , NULL
                           , '' );

        lib_proc.add_param ( pstr
                           , 'Percentual MEDICAMENTO'
                           , --P_IND_MEDI
                            'VARCHAR2'
                           , 'RADIOBUTTON'
                           , 'S'
                           , '1'
                           , NULL
                           , '1=3% ,2=4%' );

        /* LIB_PROC.ADD_PARAM(PSTR,
                              'Percentual PROTEGE', -- P_PCT_PROTEGE
                              'VARCHAR2',
                              'COMBOBOX',
                              'S',
                              NULL,
                              '######',
                              'SELECT TO_CHAR(TO_cHAR(rownum/100,''90.00'')), TO_CHAR(TO_cHAR(rownum/100,''90.00'')) AS NUMERO  FROM DUAL CONNECT BY ROWNUM <= 15*100');
        */

        lib_proc.add_param ( pstr
                           , 'Percentual PROTEGE'
                           , -- P_PCT_PROTEGE
                            'VARCHAR2'
                           , 'TEXTBOX'
                           , 'S'
                           , NULL
                           , '90.00'
                           , NULL );

        lib_proc.add_param ( pstr
                           ,    LPAD ( ' '
                                     , 28
                                     , ' ' )
                             || '(0.01% à 15.00%)'
                           , 'VARCHAR2'
                           , 'TEXT'
                           , NULL
                           , NULL
                           , NULL
                           , '' );

        lib_proc.add_param ( pstr
                           , LPAD ( '-'
                                  , 120
                                  , '-' )
                           , 'VARCHAR2'
                           , 'TEXT'
                           , NULL
                           , NULL
                           , NULL
                           , '' );

        lib_proc.add_param (
                             pstr
                           , 'Estabelecimentos'
                           , --P_COD_ESTAB
                            'VARCHAR2'
                           , 'MULTISELECT'
                           , 'S'
                           , NULL
                           , NULL
                           , ' SELECT COD_ESTAB , COD_ESTAB FROM MSAFI.DSP_ESTABELECIMENTO WHERE COD_ESTADO = ''GO'' AND TIPO = ''C'' '
        );

        RETURN pstr;
    END;

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

    PROCEDURE envia_email ( vp_cod_empresa IN VARCHAR2
                          , vp_data_ini IN DATE
                          , vp_data_fim IN DATE
                          , vp_msg_oracle IN VARCHAR2
                          , vp_tipo IN VARCHAR2
                          , vp_data_hora_ini IN DATE )
    IS
        vp_data_hora_fim DATE;
        v_diferenca_exec VARCHAR2 ( 50 );
        v_tempo_exec VARCHAR2 ( 50 );

        v_txt_email VARCHAR2 ( 2000 ) := '';
        v_assunto VARCHAR2 ( 2000 ) := '';

        v_nm_tipo VARCHAR2 ( 100 );
        v_nm_cproc VARCHAR2 ( 100 );
    BEGIN
        loga ( '>> Envia Email [' || vp_tipo || ']'
             , FALSE );

        SELECT TRANSLATE (
                           mnm_tipo
                         , 'ÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÜÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÜáçéíóúàèìòùâêîôûãõëüáçéíóúàèìòùâêîôûãõëü'
                         , 'ACEIOUAEIOUAEIOUAOEUACEIOUAEIOUAEIOUAOEUaceiouaeiouaeiouaoeuaceiouaeiouaeiouaoeu'
               )
          INTO v_nm_tipo
          FROM DUAL;

        SELECT TRANSLATE (
                           mnm_cproc
                         , 'ÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÜÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÜáçéíóúàèìòùâêîôûãõëüáçéíóúàèìòùâêîôûãõëü'
                         , 'ACEIOUAEIOUAEIOUAOEUACEIOUAEIOUAEIOUAOEUaceiouaeiouaeiouaoeuaceiouaeiouaeiouaoeu'
               )
          INTO v_nm_cproc
          FROM DUAL;

        vp_data_hora_fim := SYSDATE;

        ---------------------------------------------------------------------
        --CALCULAR TEMPO DE EXECUCAO DO RELATORIO
        SELECT b.diferenca
             ,    TRUNC ( MOD ( b.diferenca * 24
                              , 60 ) )
               || ':'
               || TRUNC ( MOD ( b.diferenca * 24 * 60
                              , 60 ) )
               || ':'
               || TRUNC ( MOD ( b.diferenca * 24 * 60 * 60
                              , 60 ) )
                   tempo
          INTO v_diferenca_exec
             , v_tempo_exec
          FROM (SELECT a.data_final - a.data_inicial AS diferenca
                  FROM (SELECT vp_data_hora_ini AS data_inicial
                             , vp_data_hora_fim AS data_final
                          FROM DUAL) a) b;

        ---------------------------------------------------------------------

        loga ( '[TEMPO EXECUÇÃO: ' || TRIM ( v_tempo_exec ) || ']'
             , FALSE );

        IF ( vp_tipo = 'E' ) THEN
            v_txt_email := v_txt_email || CHR ( 13 ) || '[ERRO] ';
        ELSE
            v_txt_email := 'Processo ' || v_nm_cproc || ' finalizado com SUCESSO.';
        END IF;

        v_txt_email :=
               v_txt_email
            || CHR ( 13 )
            || LPAD ( '-'
                    , 50
                    , '-' );
        v_txt_email := v_txt_email || CHR ( 13 ) || ' - Assunto: ' || v_nm_tipo;
        v_txt_email := v_txt_email || CHR ( 13 ) || ' - Processo: ' || v_nm_cproc;

        v_txt_email := v_txt_email || CHR ( 13 ) || ' - Num Processo: ' || mproc_id;
        v_txt_email := v_txt_email || CHR ( 13 ) || ' - Package: ' || $$plsql_unit;

        v_txt_email :=
               v_txt_email
            || CHR ( 13 )
            || LPAD ( '-'
                    , 50
                    , '-' );
        v_txt_email := v_txt_email || CHR ( 13 ) || ' ';

        v_txt_email := v_txt_email || CHR ( 13 ) || '>> Parâmetros: ';
        v_txt_email := v_txt_email || CHR ( 13 ) || ' - Empresa: ' || vp_cod_empresa;
        v_txt_email :=
               v_txt_email
            || CHR ( 13 )
            || ' - Data Início: '
            || TO_CHAR ( vp_data_ini
                       , 'DD/MM/YYYY' );
        v_txt_email :=
               v_txt_email
            || CHR ( 13 )
            || ' - Data Fim: '
            || TO_CHAR ( vp_data_fim
                       , 'DD/MM/YYYY' );
        v_txt_email := v_txt_email || CHR ( 13 ) || ' ';
        v_txt_email := v_txt_email || CHR ( 13 ) || '>> LOG: ';
        v_txt_email := v_txt_email || CHR ( 13 ) || ' - Executado por: ' || mcod_usuario;
        v_txt_email :=
               v_txt_email
            || CHR ( 13 )
            || ' - Hora Início: '
            || TO_CHAR ( vp_data_hora_ini
                       , 'DD/MM/YYYY HH24:MI.SS' );
        v_txt_email :=
               v_txt_email
            || CHR ( 13 )
            || ' - Hora Término: '
            || TO_CHAR ( SYSDATE
                       , 'DD/MM/YYYY HH24:MI.SS' );
        v_txt_email := v_txt_email || CHR ( 13 ) || ' - Tempo Execução: ' || TRIM ( v_tempo_exec );

        IF ( vp_tipo = 'E' ) THEN
            v_txt_email := v_txt_email || CHR ( 13 ) || ' ';
            v_txt_email := v_txt_email || CHR ( 13 ) || '<< ERRO >> ' || CHR ( 13 ) || vp_msg_oracle;
        END IF;

        --TIRAR ACENTOS
        SELECT TRANSLATE (
                           v_txt_email
                         , 'ÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÜÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÜáçéíóúàèìòùâêîôûãõëüáçéíóúàèìòùâêîôûãõëü'
                         , 'ACEIOUAEIOUAEIOUAOEUACEIOUAEIOUAEIOUAOEUaceiouaeiouaeiouaoeuaceiouaeiouaeiouaoeu'
               )
          INTO v_txt_email
          FROM DUAL;

        SELECT TRANSLATE (
                           v_assunto
                         , 'ÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÜÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÜáçéíóúàèìòùâêîôûãõëüáçéíóúàèìòùâêîôûãõëü'
                         , 'ACEIOUAEIOUAEIOUAOEUACEIOUAEIOUAEIOUAOEUaceiouaeiouaeiouaoeuaceiouaeiouaeiouaoeu'
               )
          INTO v_assunto
          FROM DUAL;

        IF ( vp_tipo = 'E' ) THEN
            v_assunto := 'Mastersaf - ' || v_nm_tipo || ' - ' || v_nm_cproc || ' apresentou ERRO';
            notifica ( ''
                     , 'S'
                     , v_assunto
                     , v_txt_email
                     , $$plsql_unit );
        ELSE
            v_assunto := 'Mastersaf - ' || v_nm_tipo || ' - ' || v_nm_cproc || ' Concluido';
            notifica ( 'S'
                     , ''
                     , v_assunto
                     , v_txt_email
                     , $$plsql_unit );
        END IF;
    END;

    PROCEDURE cabecalho ( v_nm_empresa VARCHAR2
                        , v_cnpj VARCHAR2
                        , v_data_hora_ini VARCHAR2
                        , v_data_inicial DATE
                        , v_data_final DATE )
    IS
    BEGIN
        --=================================================================================
        -- Cabeçalho do DW
        --=================================================================================
        mlinha := NULL;
        mlinha :=
            lib_str.w ( mlinha
                      , 'Empresa: ' || mcod_empresa || ' - ' || v_nm_empresa
                      , 1 );
        lib_proc.add ( mlinha
                     , NULL
                     , NULL
                     , 1 );

        mlinha := NULL;
        mlinha :=
            lib_str.w ( mlinha
                      , 'CNPJ: ' || v_cnpj
                      , 1 );
        lib_proc.add ( mlinha
                     , NULL
                     , NULL
                     , 1 );

        mlinha := NULL;
        mlinha :=
            lib_str.w ( mlinha
                      , 'Data de Processamento : ' || v_data_hora_ini
                      , 1 );
        lib_proc.add ( mlinha
                     , NULL
                     , NULL
                     , 1 );

        mlinha := NULL;
        mlinha :=
            lib_str.w ( mlinha
                      , LPAD ( '-'
                             , 150
                             , '-' )
                      , 1 );
        lib_proc.add ( mlinha
                     , NULL
                     , NULL
                     , 1 );

        mlinha := NULL;
        mlinha := mnm_cproc;
        lib_proc.add ( mlinha
                     , NULL
                     , NULL
                     , 1 );

        mlinha := NULL;
        mlinha := 'Data Inicial: ' || v_data_inicial;
        lib_proc.add ( mlinha
                     , NULL
                     , NULL
                     , 1 );

        mlinha := NULL;
        mlinha := 'Data Final: ' || v_data_final;
        lib_proc.add ( mlinha
                     , NULL
                     , NULL
                     , 1 );

        mlinha := NULL;
        mlinha :=
            lib_str.w ( mlinha
                      , LPAD ( '-'
                             , 150
                             , '-' )
                      , 1 );
        lib_proc.add ( mlinha
                     , NULL
                     , NULL
                     , 1 );

        mlinha := NULL;
        mlinha :=
            lib_str.w ( mlinha
                      , LPAD ( '-'
                             , 150
                             , '-' )
                      , 1 );
        lib_proc.add ( mlinha
                     , NULL
                     , NULL
                     , 1 );

        mlinha := NULL;
        mlinha :=
            lib_str.w ( mlinha
                      , ' '
                      , 1 );
        lib_proc.add ( mlinha
                     , NULL
                     , NULL
                     , 1 );
    END cabecalho;

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

    ------------------------------------------------------------------------------------------------------------------------------------------------------
    PROCEDURE create_saida ( vp_mproc_id IN NUMBER
                           , v_tab_aux   OUT VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 10000 );
        v_idx_prop VARCHAR2 ( 50 ) := ' PCTFREE 10 NOLOGGING';
    BEGIN
        loga ( '[INICIO CREATE SAIDA] '
             , TRUE );

        v_tab_aux := 'DPSP_CRED_' || vp_mproc_id;

        v_sql := 'CREATE TABLE ' || v_tab_aux;
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || ' COD_EMPRESA         VARCHAR2(3),   ';
        v_sql := v_sql || ' COD_ESTAB           VARCHAR2(6),   ';
        v_sql := v_sql || ' DATA_FISCAL         DATE,          ';
        v_sql := v_sql || ' MOVTO_E_S           VARCHAR2(1),   ';
        v_sql := v_sql || ' NORM_DEV            VARCHAR2(1),   ';
        v_sql := v_sql || ' IDENT_DOCTO         NUMBER(12),    ';
        v_sql := v_sql || ' IDENT_FIS_JUR       NUMBER(12),    ';
        v_sql := v_sql || ' NUM_DOCFIS          VARCHAR2(12),  ';
        v_sql := v_sql || ' SERIE_DOCFIS        VARCHAR2(3),   ';
        v_sql := v_sql || ' SUB_SERIE_DOCFIS    VARCHAR2(2),   ';
        v_sql := v_sql || ' DISCRI_ITEM         VARCHAR2(46),  ';
        v_sql := v_sql || ' NUM_ITEM            NUMBER(5),     ';
        v_sql := v_sql || ' INV_PROD_FAM_CD     VARCHAR2(10),  ';
        v_sql := v_sql || ' IDENT_NBM           NUMBER(12),    ';
        v_sql := v_sql || ' VLR_CONTAB_ITEM     NUMBER(17,2),  ';
        v_sql := v_sql || ' COD_FIS_JUR         VARCHAR2(14),  ';
        v_sql := v_sql || ' CPF_CGC             VARCHAR2(14),  ';
        --
        v_sql := v_sql || ' GRUPO_SITUACAO_B    VARCHAR2(9),   ';
        v_sql := v_sql || ' COD_NATUREZA_OP     VARCHAR2(3),   ';
        --
        v_sql := v_sql || ' NUM_CONTROLE_DOCTO  VARCHAR2(12),  ';
        v_sql := v_sql || ' NUM_AUTENTIC_NFE    VARCHAR2(80),  ';
        v_sql := v_sql || ' COD_CFO             VARCHAR2(4),   ';
        v_sql := v_sql || ' COD_PRODUTO         VARCHAR2(35),  ';
        v_sql := v_sql || ' DESCR_PRODUTO       VARCHAR2(50),  ';
        v_sql := v_sql || ' VLR_UNIT            NUMBER(19,4),  ';
        v_sql := v_sql || ' QUANTIDADE          NUMBER(17,6),  ';
        v_sql := v_sql || ' COD_GRUPO_PROD      VARCHAR2(5),   ';
        v_sql := v_sql || ' COD_NBM             VARCHAR2(10),  ';
        v_sql := v_sql || ' BASE_CALCULO        NUMBER(17,2),  ';
        v_sql := v_sql || ' ICMS                NUMBER(17,2),   ';
        v_sql := v_sql || ' ALIQ_INTERNA        NUMBER(5,2)   ';
        v_sql := v_sql || ' ) ' || v_tab_footer;

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE UNIQUE INDEX PKC_' || vp_mproc_id || ' ON ' || v_tab_aux;
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || ' COD_EMPRESA    ASC, ';
        v_sql := v_sql || ' COD_ESTAB      ASC, ';
        v_sql := v_sql || ' DATA_FISCAL    ASC, ';
        v_sql := v_sql || ' MOVTO_E_S      ASC, ';
        v_sql := v_sql || ' NORM_DEV       ASC,  ';
        v_sql := v_sql || ' IDENT_DOCTO    ASC,  ';
        v_sql := v_sql || ' IDENT_FIS_JUR    ASC , ';
        v_sql := v_sql || ' NUM_DOCFIS    ASC,  ';
        v_sql := v_sql || ' SERIE_DOCFIS    ASC,  ';
        v_sql := v_sql || ' SUB_SERIE_DOCFIS    ASC,  ';
        v_sql := v_sql || ' DISCRI_ITEM    ASC  ';
        v_sql := v_sql || ' ) ' || v_idx_prop;

        EXECUTE IMMEDIATE v_sql;

        ----------------------------

        save_tmp_control ( vp_mproc_id
                         , v_tab_aux );

        loga ( '[FIM CREATE SAIDA] '
             , TRUE );
    END;

    --------------------------------------------------------------------------------------------------------------------------------------

    PROCEDURE load_saidas ( v_tab_aux IN VARCHAR
                          , p_proc_instance IN VARCHAR
                          , v_data_inicial IN DATE
                          , v_data_final IN DATE
                          , p_cod_estab IN VARCHAR )
    IS
        v_sql VARCHAR2 ( 8000 );
    --
    BEGIN
        loga ( '[INICIO LOAD_SAIDAS] '
             , TRUE );

        --
        v_sql := 'BEGIN INSERT INTO ' || v_tab_aux;

        v_sql := v_sql || ' SELECT X.* FROM (';
        v_sql := v_sql || ' SELECT /*+DRIVING_SITE(I)*/ ';
        v_sql := v_sql || '  A.COD_EMPRESA, ';
        v_sql := v_sql || '  A.COD_ESTAB, ';
        v_sql := v_sql || '  A.DATA_FISCAL, ';
        v_sql := v_sql || '  A.MOVTO_E_S, ';
        v_sql := v_sql || '  A.NORM_DEV, ';
        v_sql := v_sql || '  A.IDENT_DOCTO, ';
        v_sql := v_sql || '  A.IDENT_FIS_JUR, ';
        v_sql := v_sql || '  A.NUM_DOCFIS, ';
        v_sql := v_sql || '  A.SERIE_DOCFIS, ';
        v_sql := v_sql || '  A.SUB_SERIE_DOCFIS, ';
        v_sql := v_sql || '  B.DISCRI_ITEM, ';
        v_sql := v_sql || '  B.NUM_ITEM, ';
        v_sql := v_sql || '  G.COD_GRUPO_PROD AS INV_PROD_FAM_CD ,  ';
        v_sql := v_sql || '  B.IDENT_NBM, ';
        v_sql := v_sql || '  B.VLR_CONTAB_ITEM,  ';
        v_sql := v_sql || '  E.COD_FIS_JUR, ';
        v_sql := v_sql || '  E.CPF_CGC, ';
        --
        v_sql := v_sql || '  I.COD_SITUACAO_B, ';
        v_sql := v_sql || '  J.COD_NATUREZA_OP, ';
        --
        v_sql := v_sql || '  A.NUM_CONTROLE_DOCTO, ';
        v_sql := v_sql || '  A.NUM_AUTENTIC_NFE, ';
        v_sql := v_sql || '  C.COD_CFO, ';
        v_sql := v_sql || '  F.COD_PRODUTO, ';
        v_sql := v_sql || '  F.DESCRICAO, ';
        v_sql := v_sql || '  B.VLR_UNIT, ';
        v_sql := v_sql || '  B.QUANTIDADE, ';
        v_sql := v_sql || '  G.COD_GRUPO_PROD, ';
        v_sql := v_sql || '  H.COD_NBM, ';
        ----BASE_CALCULO------
        v_sql := v_sql || '  NVL((SELECT VLR_BASE      ';
        v_sql := v_sql || '  FROM MSAF.X08_BASE_MERC G   ';
        v_sql := v_sql || '  WHERE G.COD_EMPRESA = B.COD_EMPRESA   ';
        v_sql := v_sql || '  AND G.COD_ESTAB = B.COD_ESTAB       ';
        v_sql := v_sql || '  AND G.DATA_FISCAL = B.DATA_FISCAL   ';
        v_sql := v_sql || '  AND G.MOVTO_E_S = B.MOVTO_E_S       ';
        v_sql := v_sql || '  AND G.NORM_DEV = B.NORM_DEV         ';
        v_sql := v_sql || '  AND G.IDENT_DOCTO = B.IDENT_DOCTO   ';
        v_sql := v_sql || '  AND G.IDENT_FIS_JUR = B.IDENT_FIS_JUR ';
        v_sql := v_sql || '  AND G.NUM_DOCFIS = B.NUM_DOCFIS  ';
        v_sql := v_sql || '  AND G.SERIE_DOCFIS = B.SERIE_DOCFIS    ';
        v_sql := v_sql || '  AND G.SUB_SERIE_DOCFIS = B.SUB_SERIE_DOCFIS  ';
        v_sql := v_sql || '  AND G.DISCRI_ITEM = B.DISCRI_ITEM      ';
        v_sql := v_sql || '  AND G.COD_TRIBUTACAO = ''1''       ';
        v_sql := v_sql || '  AND G.COD_TRIBUTO = ''ICMS''),0) ';
        v_sql := v_sql || ' AS BASE_CALCULO,   ';
        -----------------------
        ---------ICMS----------
        v_sql := v_sql || '  NVL((SELECT VLR_TRIBUTO     ';
        v_sql := v_sql || '  FROM MSAF.X08_TRIB_MERC IT    ';
        v_sql := v_sql || '  WHERE B.COD_EMPRESA = IT.COD_EMPRESA   ';
        v_sql := v_sql || '  AND B.COD_ESTAB = IT.COD_ESTAB       ';
        v_sql := v_sql || '  AND B.DATA_FISCAL = IT.DATA_FISCAL   ';
        v_sql := v_sql || '  AND B.MOVTO_E_S = IT.MOVTO_E_S       ';
        v_sql := v_sql || '  AND B.NORM_DEV = IT.NORM_DEV         ';
        v_sql := v_sql || '  AND B.IDENT_DOCTO = IT.IDENT_DOCTO   ';
        v_sql := v_sql || '  AND B.IDENT_FIS_JUR = IT.IDENT_FIS_JUR  ';
        v_sql := v_sql || '  AND B.NUM_DOCFIS = IT.NUM_DOCFIS    ';
        v_sql := v_sql || '  AND B.SERIE_DOCFIS = IT.SERIE_DOCFIS  ';
        v_sql := v_sql || '  AND B.SUB_SERIE_DOCFIS = IT.SUB_SERIE_DOCFIS ';
        v_sql := v_sql || '  AND B.DISCRI_ITEM = IT.DISCRI_ITEM   ';
        v_sql := v_sql || '  AND IT.COD_TRIBUTO = ''ICMS''),0) AS ICMS,  ';
        -----------------------
        -----ALIQ_INTERNA------
        v_sql := v_sql || '  NVL((SELECT ALIQ_TRIBUTO ';
        v_sql := v_sql || '  FROM MSAF.X08_TRIB_MERC IT  ';
        v_sql := v_sql || '  WHERE B.COD_EMPRESA = IT.COD_EMPRESA  ';
        v_sql := v_sql || '  AND B.COD_ESTAB = IT.COD_ESTAB  ';
        v_sql := v_sql || '  AND B.DATA_FISCAL = IT.DATA_FISCAL ';
        v_sql := v_sql || '  AND B.MOVTO_E_S = IT.MOVTO_E_S  ';
        v_sql := v_sql || '  AND B.NORM_DEV = IT.NORM_DEV  ';
        v_sql := v_sql || '  AND B.IDENT_DOCTO = IT.IDENT_DOCTO  ';
        v_sql := v_sql || '  AND B.IDENT_FIS_JUR = IT.IDENT_FIS_JUR ';
        v_sql := v_sql || '  AND B.NUM_DOCFIS = IT.NUM_DOCFIS  ';
        v_sql := v_sql || '  AND B.SERIE_DOCFIS = IT.SERIE_DOCFIS ';
        v_sql := v_sql || '  AND B.SUB_SERIE_DOCFIS = IT.SUB_SERIE_DOCFIS ';
        v_sql := v_sql || '  AND B.DISCRI_ITEM = IT.DISCRI_ITEM ';
        v_sql := v_sql || '  AND IT.COD_TRIBUTO = ''ICMS''),0) ';
        v_sql := v_sql || '  AS ALIQ_INTERNA   ';
        ----------------------
        v_sql := v_sql || ' FROM ';
        v_sql := v_sql || ' MSAF.X07_DOCTO_FISCAL     A, ';
        v_sql := v_sql || ' MSAF.X08_ITENS_MERC       B,  ';
        ----TABELA CFOPS-----
        v_sql := v_sql || ' (SELECT A.* FROM ';
        v_sql := v_sql || '         (SELECT * FROM X2012_COD_FISCAL ';
        v_sql := v_sql || '          WHERE  COD_CFO LIKE ''6%'') A ';
        v_sql := v_sql || ' WHERE A.COD_CFO NOT IN ';
        v_sql :=
               v_sql
            || ' (''6551'',''6552'',''6553'',''6554'',''6555'',''6556'',''6557'',''6411'',''6209'',''6202'')) C ,  ';
        ---------------------
        v_sql := v_sql || '  MSAFI.DSP_ESTABELECIMENTO D, ';
        v_sql := v_sql || '  MSAF.X04_PESSOA_FIS_JUR   E, ';
        v_sql := v_sql || '  MSAF.X2013_PRODUTO        F, ';
        v_sql := v_sql || '  MSAF.GRUPO_PRODUTO        G, ';
        v_sql := v_sql || '  MSAF.X2043_COD_NBM        H, ';
        v_sql := v_sql || '  MSAF.Y2026_SIT_TRB_UF_B   I, ';
        v_sql := v_sql || '  MSAF.X2006_NATUREZA_OP    J  ';
        v_sql := v_sql || ' WHERE 1=1 ';
        v_sql := v_sql || '  AND A.COD_EMPRESA = msafi.dpsp.empresa ';
        v_sql := v_sql || '  AND A.COD_EMPRESA  = B.COD_EMPRESA  ';
        v_sql := v_sql || '  AND A.COD_ESTAB    = B.COD_ESTAB    ';
        v_sql := v_sql || '  AND A.DATA_FISCAL  = B.DATA_FISCAL      ';
        v_sql := v_sql || '  AND A.MOVTO_E_S    = B.MOVTO_E_S    ';
        v_sql := v_sql || '  AND A.NORM_DEV = B.NORM_DEV     ';
        v_sql := v_sql || '  AND A.IDENT_DOCTO  = B.IDENT_DOCTO      ';
        v_sql := v_sql || '  AND A.IDENT_FIS_JUR         = B.IDENT_FIS_JUR ';
        v_sql := v_sql || '  AND A.NUM_DOCFIS   = B.NUM_DOCFIS   ';
        v_sql := v_sql || '  AND A.SERIE_DOCFIS = B.SERIE_DOCFIS     ';
        v_sql := v_sql || '  AND A.SUB_SERIE_DOCFIS   = B.SUB_SERIE_DOCFIS ';
        v_sql := v_sql || '  AND B.IDENT_CFO    = C.IDENT_CFO    ';
        v_sql := v_sql || '  AND A.COD_EMPRESA  = D.COD_EMPRESA      ';
        v_sql := v_sql || '  AND A.COD_ESTAB    = D.COD_ESTAB    ';
        v_sql := v_sql || '  AND A.IDENT_FIS_JUR   = E.IDENT_FIS_JUR ';
        v_sql := v_sql || '  AND B.IDENT_PRODUTO         = F.IDENT_PRODUTO ';
        v_sql := v_sql || '  AND F.IDENT_GRUPO_PROD = G.IDENT_GRUPO_PROD(+) ';
        v_sql := v_sql || '  AND B.IDENT_NBM    = H.IDENT_NBM ';
        --
        v_sql := v_sql || '  AND B.IDENT_SITUACAO_B = I.IDENT_SITUACAO_B ';
        v_sql := v_sql || '  AND B.IDENT_NATUREZA_OP = J.IDENT_NATUREZA_OP ';
        --
        v_sql := v_sql || '  AND A.COD_ESTAB = ''' || p_cod_estab || '''  ';
        v_sql := v_sql || '  AND A.DATA_FISCAL ';
        v_sql := v_sql || '  BETWEEN ''' || v_data_inicial || ''' AND ''' || v_data_final || ''' ';
        v_sql := v_sql || '  AND   A.MOVTO_E_S =''9'' ';
        v_sql := v_sql || '  AND   A.NORM_DEV =''1''  ';
        v_sql := v_sql || '  AND   A.SITUACAO = ''N'' ';
        v_sql := v_sql || ' )X ';
        --NÃO CONSIDERAR PRODUTOS COM ALÍQUOTA DE 4% (PRODUTOS IMPORTADOS)--
        v_sql := v_sql || ' WHERE X.ALIQ_INTERNA <> ''4'' ';
        --------------------------------------------------------------------
        v_sql := v_sql || ' ;  ';
        v_sql := v_sql || ' COMMIT; ';
        v_sql := v_sql || ' END; ';

        EXECUTE IMMEDIATE v_sql;

        loga ( '[FIM LOAD_SAIDAS] '
             , TRUE );
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
                          , 5120
                          , 1024 )
                 , FALSE );
            loga ( SUBSTR ( v_sql
                          , 6144 )
                 , FALSE );
            ---
            raise_application_error ( -20003
                                    , '!ERRO INSERT LOAD SAIDAS! [' || p_cod_estab || ']' );

            lib_proc.add ( dbms_utility.format_error_backtrace
                         , 1 );
    END load_saidas;

    -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    --PROCEDURE PARA CRIAR TABELAS TEMP DE ALIQ E PMC
    PROCEDURE load_aliq_interna ( p_proc_instance IN NUMBER
                                , vp_nome_tabela_aliq   OUT VARCHAR2
                                , v_tab_aux IN VARCHAR2
                                , v_data_inicial IN DATE
                                , v_data_final IN DATE )
    IS
        v_sql VARCHAR2 ( 2000 );
        c_aliq_interna SYS_REFCURSOR;

        TYPE cur_tab_aliq IS RECORD
        (
            proc_id NUMBER ( 30 )
          , cod_produto VARCHAR2 ( 25 )
          , aliq_interna VARCHAR2 ( 4 )
        );

        TYPE c_tab_aliq IS TABLE OF cur_tab_aliq;

        tab_aliq c_tab_aliq;

        dml_errors EXCEPTION;
    BEGIN
        loga ( '[INICIO LOAD_ALIQ_INTERNA] '
             , TRUE );

        vp_nome_tabela_aliq := 'DPSP_ALIQ_' || p_proc_instance;

        v_sql := 'CREATE TABLE ' || vp_nome_tabela_aliq;
        v_sql := v_sql || ' (';
        v_sql := v_sql || 'PROC_ID      NUMBER(30),';
        v_sql := v_sql || 'COD_PRODUTO  VARCHAR2(25),';
        v_sql := v_sql || 'ALIQ_INTERNA VARCHAR2(4)';
        v_sql := v_sql || ' )';

        EXECUTE IMMEDIATE v_sql;

        ---
        save_tmp_control ( p_proc_instance
                         , vp_nome_tabela_aliq );

        v_sql := ' SELECT DISTINCT ';
        v_sql := v_sql || '        ' || p_proc_instance || ', ';
        v_sql := v_sql || '        A.COD_PRODUTO, ';
        v_sql := v_sql || '        A.ALIQ_INTERNA ';
        v_sql := v_sql || ' FROM ( ';
        v_sql := v_sql || '   SELECT A.COD_PRODUTO AS COD_PRODUTO, ';
        v_sql := v_sql || '          REPLACE(B.XLATLONGNAME,''%'','''') AS ALIQ_INTERNA ';
        v_sql := v_sql || '    FROM ' || v_tab_aux || ' A, ';
        v_sql :=
               v_sql
            || '         (SELECT B.SETID, B.INV_ITEM_ID, B.CRIT_STATE_TO_PBL, B.CRIT_STATE_FR_PBL, B.EFFDT, B.XLATLONGNAME ';
        v_sql := v_sql || '          FROM ( ';
        v_sql :=
               v_sql
            || '          SELECT /*+DRIVING_SITE(B)*/  B.SETID, B.INV_ITEM_ID, B.CRIT_STATE_TO_PBL, B.CRIT_STATE_FR_PBL, B.EFFDT, C.XLATLONGNAME, ';
        v_sql :=
               v_sql
            || '                 RANK() OVER( PARTITION BY B.SETID, B.INV_ITEM_ID, B.CRIT_STATE_TO_PBL, B.CRIT_STATE_FR_PBL ';
        v_sql := v_sql || '        ORDER BY B.EFFDT DESC) RANK ';
        v_sql := v_sql || '          FROM MSAFI.PS_DSP_ITEM_LN_MVA B, ';
        v_sql := v_sql || '               MSAFI.PSXLATITEM C ';
        v_sql := v_sql || '          WHERE C.FIELDNAME  = ''DSP_ALIQ_ICMS'' ';
        v_sql := v_sql || '            AND C.FIELDVALUE = B.DSP_ALIQ_ICMS ';
        v_sql := v_sql || '            AND C.EFFDT = (SELECT MAX(CC.EFFDT) ';
        v_sql := v_sql || '          FROM MSAFI.PSXLATITEM CC ';
        v_sql := v_sql || '          WHERE CC.FIELDNAME  = C.FIELDNAME ';
        v_sql := v_sql || '            AND CC.FIELDVALUE = C.FIELDVALUE ';
        v_sql := v_sql || '            AND CC.EFFDT     <= SYSDATE) ';
        v_sql := v_sql || '            ) B ';
        v_sql := v_sql || '           WHERE B.RANK = 1 ';
        v_sql := v_sql || '          ) B, ';
        v_sql := v_sql || '         MSAFI.DSP_ESTABELECIMENTO D ';
        v_sql := v_sql || '      WHERE B.SETID       = ''GERAL'' ';
        v_sql := v_sql || '      AND B.INV_ITEM_ID = A.COD_PRODUTO ';
        v_sql := v_sql || '      AND D.COD_EMPRESA = ''' || mcod_empresa || ''' ';
        v_sql := v_sql || '      AND D.COD_ESTAB   = A.COD_ESTAB ';
        v_sql := v_sql || '      AND B.CRIT_STATE_TO_PBL = D.COD_ESTADO ';
        v_sql := v_sql || '      AND B.CRIT_STATE_FR_PBL = D.COD_ESTADO ) A ';

        OPEN c_aliq_interna FOR v_sql;

        LOOP
            FETCH c_aliq_interna
                BULK COLLECT INTO tab_aliq
                LIMIT 100;

            BEGIN
                FORALL i IN tab_aliq.FIRST .. tab_aliq.LAST
                    EXECUTE IMMEDIATE
                        'INSERT /*+APPEND_VALUES*/ INTO ' || vp_nome_tabela_aliq || ' VALUES (:1, :2, :3) '
                        USING tab_aliq ( i ).proc_id
                            , tab_aliq ( i ).cod_produto
                            , tab_aliq ( i ).aliq_interna;
            EXCEPTION
                WHEN OTHERS THEN
                    loga ( 'SQLERRM: ' || SQLERRM
                         , FALSE );
                    raise_application_error ( -20004
                                            , '!ERRO LOAD_ALIQ_INTERNA!' );
            END;

            COMMIT;
            tab_aliq.delete;

            EXIT WHEN c_aliq_interna%NOTFOUND;
        END LOOP;

        COMMIT;

        CLOSE c_aliq_interna;

        v_sql := 'CREATE INDEX PK_ALIQ_' || p_proc_instance || ' ON ' || vp_nome_tabela_aliq;
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || '   PROC_ID     ASC,';
        v_sql := v_sql || '   COD_PRODUTO ASC ';
        v_sql := v_sql || ' ) ';
        v_sql := v_sql || ' PCTFREE 10 ';

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX1_ALIQ_' || p_proc_instance || ' ON ' || vp_nome_tabela_aliq;
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || '   PROC_ID     ASC,';
        v_sql := v_sql || '   COD_PRODUTO ASC, ';
        v_sql := v_sql || '   ALIQ_INTERNA ASC ';
        v_sql := v_sql || ' ) ';
        v_sql := v_sql || ' PCTFREE 10 ';

        EXECUTE IMMEDIATE v_sql;

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_nome_tabela_aliq );
        loga ( '>> TABELA CRIADA: ' || vp_nome_tabela_aliq
             , FALSE );

        loga ( '[FIM LOAD_ALIQ_INTERNA] '
             , TRUE );
    END;

    ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    --CRIA E CARREGA TABELA AUXILIAR PARA OBTER AS ENTRADAS

    PROCEDURE create_busca_en ( vp_mproc_id IN NUMBER
                              , v_tab_aux IN VARCHAR2
                              , v_tab_busca_e   OUT VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 10000 );
        v_idx_prop VARCHAR2 ( 50 ) := ' PCTFREE 10 NOLOGGING';
    BEGIN
        loga ( '[INICIO CREATE_BUSCA_EN] '
             , TRUE );

        v_tab_busca_e := 'DPSP_BUS_' || vp_mproc_id;

        v_sql := 'CREATE TABLE ' || v_tab_busca_e;
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || ' COD_ESTAB           VARCHAR2(6),   ';
        v_sql := v_sql || ' COD_PRODUTO         VARCHAR2(35)  ';
        v_sql := v_sql || ' ) ' || v_tab_footer;

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE UNIQUE INDEX PKC3_' || vp_mproc_id || ' ON ' || v_tab_busca_e;
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || ' COD_ESTAB    ASC, ';
        v_sql := v_sql || ' COD_PRODUTO      ASC ';
        v_sql := v_sql || ' ) ' || v_idx_prop;

        EXECUTE IMMEDIATE v_sql;

        ----------------------------

        v_sql :=
            ' INSERT INTO ' || v_tab_busca_e || ' SELECT DISTINCT COD_ESTAB, COD_PRODUTO FROM ' || v_tab_aux || ' ';

        EXECUTE IMMEDIATE v_sql;

        ----------------------------

        loga ( '>> CRIADA TABELA AUXILIAR SAIDAS'
             , FALSE );

        save_tmp_control ( vp_mproc_id
                         , v_tab_busca_e );

        loga ( '[FIM CREATE_BUSCA_EN] '
             , TRUE );
    END;

    ---------------------------------------------------------------------------------------------------------------------------------------------------------------
    --CRIA TABELA DE ENTRADA

    PROCEDURE create_entrada ( vp_mproc_id IN NUMBER
                             , v_tab_entrada   OUT VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 10000 );
        v_idx_prop VARCHAR2 ( 50 ) := ' PCTFREE 10 NOLOGGING';
    BEGIN
        loga ( '[INICIO CREATE_ENTRADA] '
             , TRUE );

        v_tab_entrada := 'DPSP_ENT_' || vp_mproc_id;

        v_sql := 'CREATE TABLE ' || v_tab_entrada;
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || ' COD_EMPRESA         VARCHAR2(3),  ';
        v_sql := v_sql || ' COD_ESTAB           VARCHAR2(6),  ';
        v_sql := v_sql || ' DATA_FISCAL         DATE,         ';
        v_sql := v_sql || ' MOVTO_E_S           CHAR(1),      ';
        v_sql := v_sql || ' NORM_DEV            CHAR(1),      ';
        v_sql := v_sql || ' IDENT_DOCTO         NUMBER(12),   ';
        v_sql := v_sql || ' IDENT_FIS_JUR       NUMBER(12),   ';
        v_sql := v_sql || ' NUM_DOCFIS          VARCHAR2(12), ';
        v_sql := v_sql || ' SERIE_DOCFIS        VARCHAR2(3),  ';
        v_sql := v_sql || ' SUB_SERIE_DOCFIS    VARCHAR2(2),  ';
        v_sql := v_sql || ' DISCRI_ITEM         VARCHAR2(46), ';
        v_sql := v_sql || ' NUM_ITEM            NUMBER(5),    ';
        v_sql := v_sql || ' COD_FIS_JUR         VARCHAR2(14), ';
        v_sql := v_sql || ' CPF_CGC             VARCHAR2(14), ';
        v_sql := v_sql || ' COD_NBM             VARCHAR2(10), ';
        v_sql := v_sql || ' COD_CFO             VARCHAR2(4),  ';
        v_sql := v_sql || ' COD_NATUREZA_OP     VARCHAR2(3),  ';
        v_sql := v_sql || ' COD_PRODUTO         VARCHAR2(35), ';
        v_sql := v_sql || ' VLR_CONTAB_ITEM     NUMBER(17,2), ';
        v_sql := v_sql || ' QUANTIDADE          NUMBER(17,6), ';
        v_sql := v_sql || ' VLR_UNIT            NUMBER(19,4), ';
        v_sql := v_sql || ' VLR_ICMSS_N_ESCRIT  NUMBER(17,2), ';
        v_sql := v_sql || ' COD_SITUACAO_B      VARCHAR2(2),  ';
        v_sql := v_sql || ' DATA_EMISSAO        DATE,         ';
        v_sql := v_sql || ' COD_ESTADO          VARCHAR2(2),  ';
        v_sql := v_sql || ' NUM_CONTROLE_DOCTO  VARCHAR2(12), ';
        v_sql := v_sql || ' NUM_AUTENTIC_NFE    VARCHAR2(80), ';
        v_sql := v_sql || ' VLR_BASE_ICMS       NUMBER(17,2), ';
        v_sql := v_sql || ' VLR_ICMS            NUMBER(17,2), ';
        v_sql := v_sql || ' VLR_BASE_ICMSS      NUMBER(17,2), ';
        v_sql := v_sql || ' VLR_ICMSS           NUMBER(17,2), ';
        v_sql := v_sql || ' VLR_ITEM            NUMBER(17,2), ';
        v_sql := v_sql || ' VLR_OUTRAS          NUMBER(17,2), ';
        v_sql := v_sql || ' VLR_DESCONTO        NUMBER(17,2), ';
        v_sql := v_sql || ' CST_PIS             NUMBER(2),    ';
        v_sql := v_sql || ' VLR_BASE_PIS        NUMBER(17,2), ';
        v_sql := v_sql || ' VLR_ALIQ_PIS        NUMBER(7,4),  ';
        v_sql := v_sql || ' VLR_PIS             NUMBER(17,2), ';
        v_sql := v_sql || ' CST_COFINS          NUMBER(2),    ';
        v_sql := v_sql || ' VLR_BASE_COFINS     NUMBER(17,2), ';
        v_sql := v_sql || ' VLR_ALIQ_COFINS     NUMBER(7,4),  ';
        v_sql := v_sql || ' VLR_COFINS          NUMBER(17,2), ';
        v_sql := v_sql || ' ALIQ_ICMS           VARCHAR2(4), ';
        v_sql := v_sql || ' DT_INCLUSAO         DATE,         ';
        v_sql := v_sql || ' SITUACAO            VARCHAR(1)	  ';
        v_sql := v_sql || ' ) ' || v_tab_footer;

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE UNIQUE INDEX PKCE_' || vp_mproc_id || ' ON ' || v_tab_entrada;
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || ' COD_EMPRESA    ASC, ';
        v_sql := v_sql || ' COD_ESTAB      ASC, ';
        v_sql := v_sql || ' DATA_FISCAL    ASC, ';
        v_sql := v_sql || ' MOVTO_E_S      ASC, ';
        v_sql := v_sql || ' NORM_DEV       ASC,  ';
        v_sql := v_sql || ' IDENT_DOCTO    ASC,  ';
        v_sql := v_sql || ' IDENT_FIS_JUR    ASC , ';
        v_sql := v_sql || ' NUM_DOCFIS    ASC,  ';
        v_sql := v_sql || ' SERIE_DOCFIS    ASC,  ';
        v_sql := v_sql || ' SUB_SERIE_DOCFIS    ASC,  ';
        v_sql := v_sql || ' DISCRI_ITEM    ASC , ';
        v_sql := v_sql || ' COD_PRODUTO    ASC  ';
        v_sql := v_sql || ' ) ' || v_idx_prop;

        EXECUTE IMMEDIATE v_sql;

        ----------------------------REFUGO
        v_sql := 'CREATE UNIQUE INDEX PKDCE_' || vp_mproc_id || ' ON ' || v_tab_entrada;
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || ' NUM_AUTENTIC_NFE    ASC, ';
        v_sql := v_sql || ' NUM_ITEM      ASC, ';
        v_sql := v_sql || ' ALIQ_ICMS    ASC ';
        v_sql := v_sql || ' ) ' || v_idx_prop;

        EXECUTE IMMEDIATE v_sql;

        save_tmp_control ( vp_mproc_id
                         , v_tab_entrada );

        loga ( '[FIM CREATE_ENTRADA] '
             , TRUE );
    END;

    --------------------------------------------------------------------------------------------------------------------------------------------------------------

    PROCEDURE load_entrada ( v_mproc_id IN NUMBER
                           , v_tab_busca_e IN VARCHAR2
                           , v_tab_entrada IN VARCHAR2
                           , v_data_inicial IN DATE
                           , v_data_final IN DATE
                           , p_cod_estab IN VARCHAR )
    IS
        v_sql VARCHAR2 ( 8000 ) := '';
        ---
        v_limit INTEGER;
        c_est SYS_REFCURSOR;
        t_start NUMBER;
        ---
        v_i_nfe_particao VARCHAR2 ( 128 );
        v_i_ini_particao DATE;
        v_i_fim_particao DATE;
        v_dt_part_fim DATE := LAST_DAY ( v_data_final );

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
                FROM TABLE ( msafi.dpsp_recupera_particao ( 'MSAFI'
                                                          , 'DPSP_NF_ENTRADA'
                                                          , ADD_MONTHS ( TO_DATE ( p_i_data_final
                                                                                 , 'DD/MM/YYYY' )
                                                                       , -1 )
                                                          , p_i_data_final ) )
            ORDER BY 2 DESC;

        --Primeiro dia do mês para a partição
        v_dt_first DATE
            :=   TRUNC ( v_data_inicial )
               - (   TO_NUMBER ( TO_CHAR ( v_data_inicial
                                         , 'DD' ) )
                   - 1 );
    BEGIN
        loga ( '[INICIO LOAD_ENTRADA] '
             , TRUE );

        OPEN c_partition ( v_dt_part_fim );

        LOOP
            FETCH c_partition
                INTO v_i_nfe_particao
                   , v_i_ini_particao
                   , v_i_fim_particao;

            EXIT WHEN c_partition%NOTFOUND;

            v_sql := ' BEGIN ';
            v_sql := v_sql || '  INSERT INTO ' || v_tab_entrada || ' ';
            v_sql := v_sql || '  SELECT ';
            v_sql := v_sql || '  X08.COD_EMPRESA, ';
            v_sql := v_sql || '  X08.COD_ESTAB, ';
            v_sql := v_sql || '  X08.DATA_FISCAL, ';
            v_sql := v_sql || '  X08.MOVTO_E_S, ';
            v_sql := v_sql || '  X08.NORM_DEV, ';
            v_sql := v_sql || '  X08.IDENT_DOCTO, ';
            v_sql := v_sql || '  X08.IDENT_FIS_JUR, ';
            v_sql := v_sql || '  X08.NUM_DOCFIS, ';
            v_sql := v_sql || '  X08.SERIE_DOCFIS, ';
            v_sql := v_sql || '  X08.SUB_SERIE_DOCFIS, ';
            v_sql := v_sql || '  X08.DISCRI_ITEM, ';
            v_sql := v_sql || '  X08.NUM_ITEM, ';
            v_sql := v_sql || '  G.COD_FIS_JUR, ';
            v_sql := v_sql || '  G.CPF_CGC, ';
            v_sql := v_sql || '  A.COD_NBM, ';
            v_sql := v_sql || '  B.COD_CFO, ';
            v_sql := v_sql || '  C.COD_NATUREZA_OP, ';
            v_sql := v_sql || '  D.COD_PRODUTO, ';
            v_sql := v_sql || '  X08.VLR_CONTAB_ITEM, ';
            v_sql := v_sql || '  X08.QUANTIDADE, ';
            v_sql := v_sql || '  X08.VLR_UNIT, ';
            v_sql := v_sql || '  X08.VLR_ICMSS_N_ESCRIT, ';
            v_sql := v_sql || '  E.COD_SITUACAO_B, ';
            v_sql := v_sql || '  X07.DATA_EMISSAO, ';
            v_sql := v_sql || '  H.COD_ESTADO, ';
            v_sql := v_sql || '  X07.NUM_CONTROLE_DOCTO, ';
            v_sql := v_sql || '  X07.NUM_AUTENTIC_NFE AS NUM_AUTENTIC_NFE, ';
            ----VLR_BASE_ICMS---
            v_sql := v_sql || ' NVL((SELECT VLR_BASE ';
            v_sql := v_sql || ' FROM MSAF.X08_BASE_MERC IT ';
            v_sql := v_sql || ' WHERE X08.COD_EMPRESA = IT.COD_EMPRESA ';
            v_sql := v_sql || ' AND X08.COD_ESTAB = IT.COD_ESTAB ';
            v_sql := v_sql || ' AND X08.DATA_FISCAL = IT.DATA_FISCAL ';
            v_sql := v_sql || ' AND X08.MOVTO_E_S = IT.MOVTO_E_S ';
            v_sql := v_sql || ' AND X08.NORM_DEV = IT.NORM_DEV ';
            v_sql := v_sql || ' AND X08.IDENT_DOCTO = IT.IDENT_DOCTO ';
            v_sql := v_sql || ' AND X08.IDENT_FIS_JUR = IT.IDENT_FIS_JUR ';
            v_sql := v_sql || ' AND X08.NUM_DOCFIS = IT.NUM_DOCFIS ';
            v_sql := v_sql || ' AND X08.SERIE_DOCFIS = IT.SERIE_DOCFIS ';
            v_sql := v_sql || ' AND X08.SUB_SERIE_DOCFIS = IT.SUB_SERIE_DOCFIS ';
            v_sql := v_sql || ' AND X08.DISCRI_ITEM = IT.DISCRI_ITEM ';
            v_sql := v_sql || ' AND IT.COD_TRIBUTO = ''ICMS'' ';
            v_sql := v_sql || ' AND IT.COD_TRIBUTACAO = ''1''), ';
            v_sql := v_sql || ' 0) VLR_BASE_ICMS, ';
            ---------------------
            ------VLR_ICMS-------
            v_sql := v_sql || ' NVL((SELECT VLR_TRIBUTO ';
            v_sql := v_sql || ' FROM MSAF.X08_TRIB_MERC IT ';
            v_sql := v_sql || ' WHERE X08.COD_EMPRESA = IT.COD_EMPRESA ';
            v_sql := v_sql || ' AND X08.COD_ESTAB = IT.COD_ESTAB ';
            v_sql := v_sql || ' AND X08.DATA_FISCAL = IT.DATA_FISCAL ';
            v_sql := v_sql || ' AND X08.MOVTO_E_S = IT.MOVTO_E_S ';
            v_sql := v_sql || ' AND X08.NORM_DEV = IT.NORM_DEV ';
            v_sql := v_sql || ' AND X08.IDENT_DOCTO = IT.IDENT_DOCTO ';
            v_sql := v_sql || ' AND X08.IDENT_FIS_JUR = IT.IDENT_FIS_JUR ';
            v_sql := v_sql || ' AND X08.NUM_DOCFIS = IT.NUM_DOCFIS ';
            v_sql := v_sql || ' AND X08.SERIE_DOCFIS = IT.SERIE_DOCFIS ';
            v_sql := v_sql || ' AND X08.SUB_SERIE_DOCFIS = IT.SUB_SERIE_DOCFIS ';
            v_sql := v_sql || ' AND X08.DISCRI_ITEM = IT.DISCRI_ITEM ';
            v_sql := v_sql || ' AND IT.COD_TRIBUTO = ''ICMS''),0) VLR_ICMS, ';
            ---------------------
            ---VLR_BASE_ICMSS----
            v_sql := v_sql || ' NVL((SELECT VLR_BASE ';
            v_sql := v_sql || ' FROM MSAF.X08_BASE_MERC IT ';
            v_sql := v_sql || ' WHERE X08.COD_EMPRESA = IT.COD_EMPRESA ';
            v_sql := v_sql || ' AND X08.COD_ESTAB = IT.COD_ESTAB ';
            v_sql := v_sql || ' AND X08.DATA_FISCAL = IT.DATA_FISCAL ';
            v_sql := v_sql || ' AND X08.MOVTO_E_S = IT.MOVTO_E_S ';
            v_sql := v_sql || ' AND X08.NORM_DEV = IT.NORM_DEV ';
            v_sql := v_sql || ' AND X08.IDENT_DOCTO = IT.IDENT_DOCTO ';
            v_sql := v_sql || ' AND X08.IDENT_FIS_JUR = IT.IDENT_FIS_JUR ';
            v_sql := v_sql || ' AND X08.NUM_DOCFIS = IT.NUM_DOCFIS ';
            v_sql := v_sql || ' AND X08.SERIE_DOCFIS = IT.SERIE_DOCFIS ';
            v_sql := v_sql || ' AND X08.SUB_SERIE_DOCFIS = IT.SUB_SERIE_DOCFIS ';
            v_sql := v_sql || ' AND X08.DISCRI_ITEM = IT.DISCRI_ITEM ';
            v_sql := v_sql || ' AND IT.COD_TRIBUTO = ''ICMS-S'' ';
            v_sql := v_sql || ' AND IT.COD_TRIBUTACAO = ''1''), ';
            v_sql := v_sql || ' 0) VLR_BASE_ICMSS, ';
            ---------------------
            ------VLR_ICMSS------
            v_sql := v_sql || ' NVL((SELECT VLR_TRIBUTO ';
            v_sql := v_sql || ' FROM MSAF.X08_TRIB_MERC IT ';
            v_sql := v_sql || ' WHERE X08.COD_EMPRESA = IT.COD_EMPRESA ';
            v_sql := v_sql || ' AND X08.COD_ESTAB = IT.COD_ESTAB ';
            v_sql := v_sql || ' AND X08.DATA_FISCAL = IT.DATA_FISCAL ';
            v_sql := v_sql || ' AND X08.MOVTO_E_S = IT.MOVTO_E_S ';
            v_sql := v_sql || ' AND X08.NORM_DEV = IT.NORM_DEV ';
            v_sql := v_sql || ' AND X08.IDENT_DOCTO = IT.IDENT_DOCTO ';
            v_sql := v_sql || ' AND X08.IDENT_FIS_JUR = IT.IDENT_FIS_JUR ';
            v_sql := v_sql || ' AND X08.NUM_DOCFIS = IT.NUM_DOCFIS ';
            v_sql := v_sql || ' AND X08.SERIE_DOCFIS = IT.SERIE_DOCFIS ';
            v_sql := v_sql || ' AND X08.SUB_SERIE_DOCFIS = IT.SUB_SERIE_DOCFIS ';
            v_sql := v_sql || ' AND X08.DISCRI_ITEM = IT.DISCRI_ITEM ';
            v_sql := v_sql || ' AND IT.COD_TRIBUTO = ''ICMS-S''),0) VLR_ICMSS, ';
            ---------------------
            v_sql := v_sql || '  X08.VLR_ITEM, ';
            v_sql := v_sql || '  X08.VLR_OUTRAS, ';
            v_sql := v_sql || '  X08.VLR_DESCONTO, ';
            v_sql := v_sql || '  X08.COD_SITUACAO_PIS AS CST_PIS, ';
            v_sql := v_sql || '  X08.VLR_BASE_PIS, ';
            v_sql := v_sql || '  X08.VLR_ALIQ_PIS, ';
            v_sql := v_sql || '  X08.VLR_PIS, ';
            v_sql := v_sql || '  X08.COD_SITUACAO_COFINS AS CST_COFINS, ';
            v_sql := v_sql || '  X08.VLR_BASE_COFINS, ';
            v_sql := v_sql || '  X08.VLR_ALIQ_COFINS, ';
            v_sql := v_sql || '  X08.VLR_COFINS, ';
            v_sql := v_sql || '  '''' AS ALIQ_ICMS, ';
            v_sql := v_sql || '  SYSDATE AS DT_INCLUSAO, ';
            v_sql := v_sql || '  x07.SITUACAO ';
            ---------FROM---------
            v_sql := v_sql || ' FROM ';
            v_sql := v_sql || '' || v_tab_busca_e || ' TEMP,       ';
            v_sql := v_sql || ' MSAF.X08_ITENS_MERC  ';
            v_sql := v_sql || ' PARTITION FOR(''' || v_dt_first || ''')  X08,';
            v_sql := v_sql || ' MSAF.X07_DOCTO_FISCAL  ';
            v_sql := v_sql || ' PARTITION FOR(''' || v_dt_first || ''')  X07,';
            v_sql := v_sql || ' MSAF.X2013_PRODUTO D,  ';
            v_sql := v_sql || ' MSAF.X04_PESSOA_FIS_JUR G,  ';
            v_sql := v_sql || ' MSAF.X2043_COD_NBM A,  ';
            v_sql := v_sql || ' MSAF.X2012_COD_FISCAL B,  ';
            v_sql := v_sql || ' MSAF.X2006_NATUREZA_OP C,  ';
            v_sql := v_sql || ' MSAF.Y2026_SIT_TRB_UF_B E,  ';
            v_sql := v_sql || ' ESTADO H ';
            ------------------------
            v_sql := v_sql || ' WHERE 1 = 1 ';
            v_sql := v_sql || ' AND X07.COD_EMPRESA = ''' || mcod_empresa || ''' ';
            v_sql := v_sql || ' AND X07.COD_ESTAB = ''' || p_cod_estab || ''' ';

            v_sql := v_sql || ' AND X07.DATA_FISCAL BETWEEN ';
            v_sql :=
                   v_sql
                || ' TO_DATE('''
                || TO_CHAR ( v_i_ini_particao
                           , 'DDMMYYYY' )
                || ''',''DDMMYYYY'') ';
            v_sql :=
                   v_sql
                || ' AND TO_DATE('''
                || TO_CHAR ( v_i_fim_particao
                           , 'DDMMYYYY' )
                || ''',''DDMMYYYY'') ';

            v_sql := v_sql || ' AND X08.IDENT_NBM = A.IDENT_NBM(+) ';
            v_sql := v_sql || ' AND X08.IDENT_CFO = B.IDENT_CFO(+) ';
            v_sql := v_sql || ' AND X08.IDENT_NATUREZA_OP = ';
            v_sql := v_sql || '     C.IDENT_NATUREZA_OP(+) ';
            v_sql := v_sql || ' AND X08.IDENT_SITUACAO_B = ';
            v_sql := v_sql || '     E.IDENT_SITUACAO_B(+) ';
            v_sql := v_sql || ' AND X08.IDENT_PRODUTO = D.IDENT_PRODUTO(+) ';
            v_sql := v_sql || ' AND X07.IDENT_FIS_JUR = G.IDENT_FIS_JUR(+) ';
            v_sql := v_sql || ' AND G.IDENT_ESTADO = H.IDENT_ESTADO(+) ';
            v_sql := v_sql || ' AND X07.COD_EMPRESA = X08.COD_EMPRESA ';
            v_sql := v_sql || ' AND X07.COD_ESTAB = X08.COD_ESTAB ';
            v_sql := v_sql || ' AND X07.DATA_FISCAL = X08.DATA_FISCAL ';
            v_sql := v_sql || ' AND X07.MOVTO_E_S = X08.MOVTO_E_S ';
            v_sql := v_sql || ' AND X07.NORM_DEV = X08.NORM_DEV ';
            v_sql := v_sql || ' AND X07.IDENT_DOCTO = X08.IDENT_DOCTO ';
            v_sql := v_sql || ' AND X07.IDENT_FIS_JUR = X08.IDENT_FIS_JUR ';
            v_sql := v_sql || ' AND X07.NUM_DOCFIS = X08.NUM_DOCFIS ';
            v_sql := v_sql || ' AND X07.SERIE_DOCFIS = X08.SERIE_DOCFIS ';
            v_sql := v_sql || ' AND X07.SUB_SERIE_DOCFIS = ';
            v_sql := v_sql || '     X08.SUB_SERIE_DOCFIS ';
            v_sql := v_sql || ' AND X07.COD_ESTAB = TEMP.COD_ESTAB';
            v_sql := v_sql || ' AND D.COD_PRODUTO = TEMP.COD_PRODUTO';

            v_sql := v_sql || ' AND X07.MOVTO_E_S <> ''9'' ';
            ----ENTRADAS INTERNAS E INTERESTADUAIS----
            v_sql := v_sql || ' AND SUBSTR(B.COD_CFO,1,1) IN (''1'',''2'') ';
            ------------------------------------------
            v_sql := v_sql || ' ;';
            v_sql := v_sql || ' COMMIT; ';

            v_sql := v_sql || ' DELETE ' || v_tab_busca_e || ' W ';
            v_sql := v_sql || ' WHERE 1=1 ';
            v_sql := v_sql || ' AND EXISTS (SELECT ''X'' ';
            v_sql := v_sql || ' FROM ' || v_tab_entrada || ' N ';
            v_sql := v_sql || ' WHERE 1=1 ';
            v_sql := v_sql || ' AND W.COD_PRODUTO = N.COD_PRODUTO ';
            v_sql := v_sql || ' );';
            v_sql := v_sql || ' COMMIT;';

            v_sql := v_sql || 'END; ';

            EXECUTE IMMEDIATE v_sql;

            loga ( '>> PARTIÇÃO ENTRADA - [' || v_i_ini_particao || '] CARREGADA!' );
        END LOOP;

        loga ( '[FIM LOAD_ENTRADA] '
             , TRUE );
    --
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
                          , 5120
                          , 1024 )
                 , FALSE );
            loga ( SUBSTR ( v_sql
                          , 6144 )
                 , FALSE );
            ---
            raise_application_error ( -20003
                                    , '!ERRO LOAD_ENTRADA!' );

            lib_proc.add ( dbms_utility.format_error_backtrace
                         , 1 );
    END;

    -------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    PROCEDURE refugo_xml ( p_proc_instance IN VARCHAR
                         , v_tab_entrada IN VARCHAR )
    IS
        v_sql VARCHAR2 ( 20000 );
    BEGIN
        loga ( '[INICIO REFUGO_XML] '
             , TRUE );

        --REFUGO1
        v_sql := 'MERGE INTO ' || v_tab_entrada || ' A ';
        v_sql := v_sql || 'USING (SELECT NFE_VERIF_CODE_PBL, INV_ITEM_ID, NF_BRL_LINE_NUM , ALIQ_ICMS ';
        v_sql := v_sql || '   FROM MSAFI.PS_XML_FORN) B ';
        v_sql := v_sql || 'ON (A.NUM_AUTENTIC_NFE = B.NFE_VERIF_CODE_PBL ';
        v_sql := v_sql || 'AND A.NUM_ITEM     = B.NF_BRL_LINE_NUM ';
        v_sql := v_sql || 'AND A.COD_PRODUTO  = B.INV_ITEM_ID) ';
        v_sql := v_sql || 'WHEN MATCHED THEN ';
        v_sql := v_sql || 'UPDATE SET A.ALIQ_ICMS = B.ALIQ_ICMS ';

        EXECUTE IMMEDIATE v_sql;

        COMMIT;
        loga ( 'REFUGO 1' );

        v_sql := 'MERGE INTO ' || v_tab_entrada || ' A ';
        v_sql := v_sql || ' USING(SELECT A.INV_ITEM_ID , A.NFE_VERIF_CODE_PBL,  A.ALIQ_ICMS FROM ( ';
        v_sql :=
               v_sql
            || ' SELECT NFE_VERIF_CODE_PBL , INV_ITEM_ID ,ALIQ_ICMS, SUM(NF_BRL_LINE_NUM), SUM(CFOP_FORN) , SUM(QTY_NF_BRL), SUM(VLR_BASE_ICMS), SUM(VLR_ICMS), SUM(ALIQ_REDUCAO), ';
        v_sql := v_sql || ' SUM(VLR_BASE_ICMS_ST), SUM (VLR_ICMS_ST), SUM(VLR_BASE_ICMSST_RET), SUM(VLR_ICMSST_RET) ';
        v_sql :=
               v_sql
            || ' FROM  MSAFI.PS_XML_FORN GROUP BY NFE_VERIF_CODE_PBL , INV_ITEM_ID, ALIQ_ICMS) A , '
            || v_tab_entrada
            || ' B ';
        v_sql :=
               v_sql
            || ' WHERE A.INV_ITEM_ID = B.COD_PRODUTO AND A.NFE_VERIF_CODE_PBL = B.NUM_AUTENTIC_NFE AND B.ALIQ_ICMS = '' '') B ';
        v_sql := v_sql || ' ON (A.NUM_AUTENTIC_NFE = B.NFE_VERIF_CODE_PBL   ';
        v_sql := v_sql || ' AND A.COD_PRODUTO  = B.INV_ITEM_ID) ';
        v_sql := v_sql || ' WHEN MATCHED THEN ';
        v_sql := v_sql || ' UPDATE SET A.ALIQ_ICMS = B.ALIQ_ICMS  ';

        EXECUTE IMMEDIATE v_sql;

        COMMIT;
        loga ( 'REFUGO 2' );

        v_sql := 'MERGE INTO ' || v_tab_entrada || ' A ';
        v_sql := v_sql || '  USING(SELECT A.NFE_VERIF_CODE_PBL, A.NF_BRL_LINE_NUM, A.ALIQ_ICMS FROM ( ';
        v_sql :=
               v_sql
            || '  SELECT NFE_VERIF_CODE_PBL , NF_BRL_LINE_NUM , ALIQ_ICMS, SUM(NF_BRL_LINE_NUM), SUM(CFOP_FORN) , SUM(QTY_NF_BRL), SUM(VLR_BASE_ICMS), ';
        v_sql :=
               v_sql
            || '  SUM(VLR_ICMS), SUM(ALIQ_REDUCAO), SUM(VLR_BASE_ICMS_ST), SUM (VLR_ICMS_ST), SUM(VLR_BASE_ICMSST_RET), SUM(VLR_ICMSST_RET)  ';
        v_sql := v_sql || '  FROM  MSAFI.PS_XML_FORN ';
        v_sql := v_sql || '  GROUP BY NFE_VERIF_CODE_PBL,NF_BRL_LINE_NUM, ALIQ_ICMS) A , ' || v_tab_entrada || ' B ';
        v_sql :=
               v_sql
            || '  WHERE A.NFE_VERIF_CODE_PBL = B.NUM_AUTENTIC_NFE AND B.NUM_ITEM = A.NF_BRL_LINE_NUM AND B.ALIQ_ICMS =  '' '') B ';
        v_sql := v_sql || '  ON (A.NUM_AUTENTIC_NFE = B.NFE_VERIF_CODE_PBL ';
        v_sql := v_sql || '  AND A.NUM_ITEM = B.NF_BRL_LINE_NUM) ';
        v_sql := v_sql || '  WHEN MATCHED THEN ';
        v_sql := v_sql || '  UPDATE SET A.ALIQ_ICMS = B.ALIQ_ICMS  ';

        EXECUTE IMMEDIATE v_sql;

        COMMIT;
        loga ( 'REFUGO 3 ' );

        v_sql := ' UPDATE ' || v_tab_entrada || ' ';
        v_sql := v_sql || ' SET  ALIQ_ICMS = (CASE WHEN ROUND(VLR_ICMS/VLR_BASE_ICMS*100) <=  ''5,5'' THEN ''4'' ';
        v_sql := v_sql || ' WHEN ROUND(VLR_ICMS/VLR_BASE_ICMS*100) BETWEEN ''5,6'' AND ''9,5'' THEN ''7'' ';
        v_sql := v_sql || ' WHEN ROUND(VLR_ICMS/VLR_BASE_ICMS*100) > ''9,6''  THEN ''12'' END )  ';
        v_sql := v_sql || ' WHERE ALIQ_ICMS IN ('' '',''0'')  ';
        v_sql := v_sql || ' AND NVL(VLR_ICMS, 0) <> ''0'' ';

        EXECUTE IMMEDIATE v_sql;

        COMMIT;

        loga ( '[FIM REFUGO_XML] '
             , TRUE );
    --
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
                          , 5120
                          , 1024 )
                 , FALSE );
            loga ( SUBSTR ( v_sql
                          , 6144 )
                 , FALSE );
            ---
            raise_application_error ( -20003
                                    , '!ERRO REFUGO_XML!' );

            lib_proc.add ( dbms_utility.format_error_backtrace
                         , 1 );
    END;

    -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    PROCEDURE load_tab_final ( v_mproc_id IN NUMBER
                             , v_tab_aux IN VARCHAR
                             , v_tab_entrada IN VARCHAR
                             , vp_nome_tabela_aliq IN VARCHAR
                             , v_pct_medi IN VARCHAR
                             , v_pct_protege IN VARCHAR
                             , v_data_inicial IN DATE
                             , v_data_final IN DATE )
    IS
        v_sql VARCHAR2 ( 20000 ) := '';

        v_vlr_contab_aliq_int NUMBER;
        v_vlr_contab_ent NUMBER;
        v_percent_medio NUMBER;
    BEGIN
        loga ( '[INICIO LOAD_TAB_FINAL] '
             , TRUE );

        loga ( '>> V_TAB_ENTRADA: ' || v_tab_entrada
             , FALSE );

        v_sql := '';

        --==== VALOR DO ESTORNO DE CRÉDITO =================================================
        --Valor contábil das operações de entradas interestaduais com alíquota de 12%
        EXECUTE IMMEDIATE
               ' SELECT NVL(SUM(VLR_CONTAB_ITEM),0) AS VLR_CONTAB_ITEM FROM '
            || v_tab_entrada
            || ' WHERE ALIQ_ICMS >= 12 AND SUBSTR(COD_CFO,1,1) = ''2'' '
                       INTO v_vlr_contab_aliq_int;

        v_sql := '>> Valor Contábil das Entradas Internas com Aliq 12%: ' || v_vlr_contab_aliq_int;

        lib_proc.add ( v_sql
                     , NULL
                     , NULL
                     , 1 );
        loga ( v_sql
             , FALSE );

        --Valor contábil de todas as operações de entradas (internas e interestaduais) do período
        EXECUTE IMMEDIATE ' SELECT NVL(SUM(VLR_CONTAB_ITEM),0)  AS VLR_CONTAB_ITEM FROM ' || v_tab_entrada
                       INTO v_vlr_contab_ent;

        v_sql := '>> Valor Contábil de todas as Entradas Internas e Interestaduais: ' || v_vlr_contab_ent;

        lib_proc.add ( v_sql
                     , NULL
                     , NULL
                     , 1 );
        loga ( v_sql
             , FALSE );

        IF v_vlr_contab_aliq_int = 0
        OR v_vlr_contab_ent = 0 THEN
            v_percent_medio := 0;
        ELSE
            v_percent_medio := NVL ( v_vlr_contab_aliq_int / v_vlr_contab_ent, 0 );
        END IF;

        v_sql := '>> Percentual Médio: ' || TO_CHAR ( v_percent_medio );

        lib_proc.add ( v_sql
                     , NULL
                     , NULL
                     , 1 );
        loga ( v_sql
             , FALSE );

        --==================================================================================

        v_sql := '';
        v_sql := v_sql || 'BEGIN ';
        v_sql := v_sql || ' INSERT INTO MSAFI.DPSP_OUTORGADO_CD_DO (';
        v_sql := v_sql || '  ESTAB_ORIGEM ';
        v_sql := v_sql || ' ,ESTAB_DESTINO ';
        v_sql := v_sql || ' ,DATA_FISCAL ';
        v_sql := v_sql || ' ,NUM_NF_SAIDA ';
        v_sql := v_sql || ' ,ID_NOTA_FISCAL ';
        v_sql := v_sql || ' ,CFOP ';
        v_sql := v_sql || ' ,ITEM ';
        v_sql := v_sql || ' ,NUM_ITEM ';
        v_sql := v_sql || ' ,DESCRICAO_ITEM ';
        v_sql := v_sql || ' ,VLR_UNIT ';
        v_sql := v_sql || ' ,QUANTIDADE ';
        v_sql := v_sql || ' ,SUBCLASSIFICACAO ';
        v_sql := v_sql || ' ,NBM ';
        v_sql := v_sql || ' ,GRUPO_SITUACAO_B ';
        v_sql := v_sql || ' ,COD_NATUREZA_OP ';
        v_sql := v_sql || ' ,VLR_CONTABIL ';
        v_sql := v_sql || ' ,BASE_CALCULO ';
        v_sql := v_sql || ' ,ICMS ';
        v_sql := v_sql || ' ,ALIQ ';
        v_sql := v_sql || ' ,PCT_MEDI ';
        v_sql := v_sql || ' ,PCT_PROTEGE ';
        v_sql := v_sql || ' ,VLR_ENTRADAS_ALIQ ';
        v_sql := v_sql || ' ,VLR_TOTAL_ENTRADAS ';
        v_sql := v_sql || ' ,PCT_MEDIO ';
        v_sql := v_sql || ' ,CRED_OUTORGADO ';
        v_sql := v_sql || ' ,PROTEGE ';
        v_sql := v_sql || ' ,ESTORNO_CRED ';
        v_sql := v_sql || ' ,PROC_ID ';
        v_sql := v_sql || ' ,USUARIO ';
        v_sql := v_sql || ' ,DATA_GRAVACAO ';
        v_sql := v_sql || ' ) ';

        v_sql := v_sql || ' SELECT ';
        v_sql := v_sql || '  X.ESTAB_ORIGEM, ';
        v_sql := v_sql || '  X.ESTAB_DESTINO, ';
        v_sql := v_sql || '  X.DATA_FISCAL, ';
        v_sql := v_sql || '  X.NUM_NF_SAIDA, ';
        v_sql := v_sql || '  X.ID_NOTA_FISCAL, ';
        v_sql := v_sql || '  X.CFOP, ';
        v_sql := v_sql || '  X.ITEM, ';
        v_sql := v_sql || '  X.NUM_ITEM, ';
        v_sql := v_sql || '  X.DESCRICAO_ITEM, ';
        v_sql := v_sql || '  X.VLR_UNIT, ';
        v_sql := v_sql || '  X.QUANTIDADE, ';
        v_sql := v_sql || '  X.SUBCLASSIFICACAO, ';
        v_sql := v_sql || '  X.NBM, ';
        v_sql := v_sql || '  X.GRUPO_SITUACAO_B, ';
        v_sql := v_sql || '  X.COD_NATUREZA_OP, ';
        v_sql := v_sql || '  X.VLR_CONTABIL, ';
        v_sql := v_sql || '  X.BASE_CALCULO, ';
        v_sql := v_sql || '  X.ICMS, ';
        v_sql := v_sql || '  X.ALIQ, ';
        -------------PARÂMETROS & PERCENTUAIS------------
        --V_SQL := V_SQL || '  ''' || V_PCT_MEDI || ''' AS PCT_MEDI, ';
        v_sql := v_sql || '   CASE WHEN TRIM(X.SUBCLASSIFICACAO) = ''MEDI'' ';
        v_sql := v_sql || '   THEN (''' || v_pct_medi || ''')';
        v_sql := v_sql || '   ELSE ('''') ';
        v_sql := v_sql || '   END AS PCT_MEDI,  ';
        --
        v_sql := v_sql || '  ''' || v_pct_protege || ''' AS PCT_PROTEGE, ';
        v_sql := v_sql || '  ''' || v_vlr_contab_aliq_int || ''' AS VLR_ENTRADAS_ALIQ, ';
        v_sql := v_sql || '  ''' || v_vlr_contab_ent || ''' AS VLR_TOTAL_ENTRADAS, ';
        v_sql := v_sql || '  ''' || v_percent_medio || ''' AS PCT_MEDIO, ';

        v_sql := v_sql || '  X.CRED_OUTORGADO, ';
        ---------------PERCENTUAL DO PROTEGE--------------
        v_sql := v_sql || ' (X.CRED_OUTORGADO * (''' || v_pct_protege || ''' / 100)) ';
        v_sql := v_sql || ' AS PROTEGE, ';
        --------------------------------------------------
        v_sql := v_sql || ' (X.CRED_OUTORGADO * (''' || v_percent_medio || ''' ) ) ';
        v_sql := v_sql || ' AS ESTORNO_CRED, ';
        --------------------------------------------------
        v_sql := v_sql || ' ''' || v_mproc_id || ''' AS PROC_ID,';
        v_sql := v_sql || ' ''' || mcod_usuario || ''' AS USUARIO,';
        v_sql := v_sql || ' SYSDATE AS DATA_GRAVACAO';

        v_sql := v_sql || '  FROM ';
        v_sql := v_sql || ' (SELECT A.COD_ESTAB AS ESTAB_ORIGEM, ';
        v_sql := v_sql || '    A.COD_FIS_JUR AS ESTAB_DESTINO, ';
        v_sql := v_sql || '    A.DATA_FISCAL, ';
        v_sql := v_sql || '    A.NUM_DOCFIS AS NUM_NF_SAIDA, ';
        v_sql := v_sql || '    A.NUM_AUTENTIC_NFE AS ID_NOTA_FISCAL, ';
        v_sql := v_sql || '    A.COD_CFO AS CFOP, ';
        v_sql := v_sql || '    A.COD_PRODUTO AS ITEM, ';
        v_sql := v_sql || '    A.NUM_ITEM, ';
        v_sql := v_sql || '    A.DESCR_PRODUTO AS DESCRICAO_ITEM, ';
        v_sql := v_sql || '    A.VLR_UNIT, ';
        v_sql := v_sql || '    A.QUANTIDADE, ';
        v_sql := v_sql || '    TRIM(A.COD_GRUPO_PROD) AS SUBCLASSIFICACAO, ';
        v_sql := v_sql || '    A.COD_NBM AS NBM, ';
        v_sql := v_sql || '    A.GRUPO_SITUACAO_B, ';
        v_sql := v_sql || '    A.COD_NATUREZA_OP, ';
        v_sql := v_sql || '    A.BASE_CALCULO AS VLR_CONTABIL, ';
        v_sql := v_sql || '    A.BASE_CALCULO, ';
        v_sql := v_sql || '    A.ICMS, ';
        v_sql := v_sql || '    A.ALIQ_INTERNA AS ALIQ, ';
        --------------PERCENTUAL DE REDUÇÃO--------------
        v_sql := v_sql || '   CASE WHEN TRIM(A.COD_GRUPO_PROD) = ''MEDI'' ';
        v_sql := v_sql || '   THEN (A.BASE_CALCULO * (''' || v_pct_medi || ''') / 100)   ';
        v_sql := v_sql || '   ELSE (A.BASE_CALCULO * ''0,03'') ';
        v_sql := v_sql || '   END AS CRED_OUTORGADO  ';
        --------------------------------------------------
        v_sql := v_sql || '    FROM MSAF.' || v_tab_aux || ' A) X ';
        v_sql := v_sql || '; ';
        v_sql := v_sql || 'COMMIT; ';
        v_sql := v_sql || 'END; ';

        EXECUTE IMMEDIATE v_sql;

        loga ( '>> TABELA FINAL CARREGADA!' );

        loga ( '[FIM LOAD_TAB_FINAL] '
             , TRUE );
    --
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
                          , 5120
                          , 1024 )
                 , FALSE );
            loga ( SUBSTR ( v_sql
                          , 6144 )
                 , FALSE );
            ---
            raise_application_error ( -20003
                                    , '!ERRO LOAD_TAB_FINAL!' );

            lib_proc.add ( dbms_utility.format_error_backtrace
                         , 1 );
    END;

    -----------------------------------------------------------------------------INICIO - ANALITICO--------------------------------------------------------------------------
    --EXCEL
    PROCEDURE load_excel ( v_data_inicial IN DATE
                         , v_data_final IN DATE
                         , p_cod_estab IN VARCHAR2
                         , v_id_arq IN NUMBER )
    IS
        v_class VARCHAR2 ( 1 ) := 'A';
        v_text01 VARCHAR2 ( 20000 );
    BEGIN
        loga ( '[INICIO LOAD_EXCEL] '
             , TRUE );

        loga ( '>> Inicio Outorgado - Proc_id: ' || mproc_id
             , FALSE );

        lib_proc.add_tipo ( mproc_id
                          , v_id_arq
                          ,    mcod_empresa
                            || '_REL_OUTORGADO_'
                            || TO_CHAR ( v_data_inicial
                                       , 'MM_YYYY' )
                            || '_'
                            || p_cod_estab
                            || '.XLS'
                          , 2 );

        lib_proc.add ( dsp_planilha.header
                     , ptipo => v_id_arq );
        lib_proc.add ( dsp_planilha.tabela_inicio
                     , ptipo => v_id_arq );

        lib_proc.add ( dsp_planilha.linha ( p_conteudo =>    dsp_planilha.campo ( 'ANALITICO'
                                                                                , p_custom => 'COLSPAN=19' )
                                                          || --
                                                            dsp_planilha.campo (
                                                                                 'PERCENTUAL'
                                                                               , p_custom => 'COLSPAN=5 BGCOLOR=#000086'
                                                             )
                                                          || --
                                                            dsp_planilha.campo (
                                                                                 'CALCULOS'
                                                                               , p_custom => 'COLSPAN=4 BGCOLOR=GREEN'
                                                             )
                                          , p_class => 'h' )
                     , ptipo => v_id_arq );

        lib_proc.add ( dsp_planilha.linha ( p_conteudo =>    dsp_planilha.campo ( 'ESTAB_ORIGEM' )
                                                          || dsp_planilha.campo ( 'ESTAB_DESTINO' )
                                                          || dsp_planilha.campo ( 'DATA_FISCAL' )
                                                          || dsp_planilha.campo ( 'NUM_NF_SAIDA' )
                                                          || dsp_planilha.campo ( 'ID_NOTA_FISCAL' )
                                                          || dsp_planilha.campo ( 'CFOP' )
                                                          || dsp_planilha.campo ( 'ITEM' )
                                                          || dsp_planilha.campo ( 'NUM_ITEM' )
                                                          || dsp_planilha.campo ( 'DESCRICAO_ITEM' )
                                                          || dsp_planilha.campo ( 'VLR_UNIT' )
                                                          || dsp_planilha.campo ( 'QUANTIDADE' )
                                                          || dsp_planilha.campo ( 'SUBCLASSIFICACAO' )
                                                          || dsp_planilha.campo ( 'NBM' )
                                                          || dsp_planilha.campo ( 'CST' )
                                                          || dsp_planilha.campo ( 'FINALIDADE' )
                                                          || dsp_planilha.campo ( 'VLR_CONTABIL' )
                                                          || dsp_planilha.campo ( 'BASE_CALCULO' )
                                                          || dsp_planilha.campo ( 'ICMS' )
                                                          || dsp_planilha.campo ( 'ALIQ' )
                                                          || --
                                                             dsp_planilha.campo ( 'MEDICAMENTO (%)'
                                                                                , p_custom => 'BGCOLOR=#000086' )
                                                          || dsp_planilha.campo ( 'PROTEGE (%)'
                                                                                , p_custom => 'BGCOLOR=#000086' )
                                                          || dsp_planilha.campo ( 'Vlr Contab. Entradas Aliq 12%'
                                                                                , p_custom => 'BGCOLOR=#000086' )
                                                          || dsp_planilha.campo ( 'Vlr Contab. Entradas'
                                                                                , p_custom => 'BGCOLOR=#000086' )
                                                          || dsp_planilha.campo ( 'PERCENTUAL MEDIO'
                                                                                , p_custom => 'BGCOLOR=#000086' )
                                                          || --
                                                             dsp_planilha.campo ( 'CRED_OUTORGADO'
                                                                                , p_custom => 'BGCOLOR=GREEN' )
                                                          || --
                                                            dsp_planilha.campo ( 'PROTEGE'
                                                                               , p_custom => 'BGCOLOR=GREEN' )
                                                          || --
                                                            dsp_planilha.campo ( 'ESTORNO_CRED'
                                                                               , p_custom => 'BGCOLOR=GREEN' )
                                                          || --
                                                            dsp_planilha.campo ( 'VLR_LIQUIDO'
                                                                               , p_custom => 'BGCOLOR=GREEN' ) --
                                          , p_class => 'h' )
                     , ptipo => v_id_arq );

        FOR c IN ( SELECT   rel.estab_origem
                          , rel.estab_destino
                          , rel.data_fiscal
                          , rel.num_nf_saida
                          , rel.id_nota_fiscal
                          , rel.cfop
                          , rel.item
                          , rel.num_item
                          , rel.descricao_item
                          , rel.vlr_unit
                          , rel.quantidade
                          , rel.subclassificacao
                          , rel.nbm
                          , rel.grupo_situacao_b
                          , rel.cod_natureza_op
                          , rel.vlr_contabil
                          , rel.base_calculo
                          , rel.icms
                          , rel.aliq
                          , rel.pct_medi
                          , rel.pct_protege
                          , rel.vlr_entradas_aliq
                          , rel.vlr_total_entradas
                          , rel.pct_medio
                          , ROUND ( rel.cred_outorgado
                                  , 2 )
                                AS cred_outorgado
                          , ROUND ( rel.protege
                                  , 2 )
                                AS protege
                          , ROUND ( rel.estorno_cred
                                  , 2 )
                                AS estorno_cred
                          ,   --
                               ( ROUND ( rel.cred_outorgado
                                       , 2 ) )
                            - ( ROUND ( rel.estorno_cred
                                      , 2 ) )
                                AS vlr_liquido
                       FROM msafi.dpsp_outorgado_cd_do rel
                      WHERE 1 = 1
                        AND rel.estab_origem = p_cod_estab
                        AND rel.data_fiscal BETWEEN v_data_inicial AND v_data_final
                        AND rel.proc_id = mproc_id
                   ORDER BY rel.data_fiscal
                          , rel.num_nf_saida DESC ) LOOP
            IF v_class = 'A' THEN
                v_class := 'B';
            ELSE
                v_class := 'A';
            END IF;

            v_text01 :=
                dsp_planilha.linha (
                                     p_conteudo =>    dsp_planilha.campo ( c.estab_origem )
                                                   || dsp_planilha.campo ( c.estab_destino )
                                                   || dsp_planilha.campo ( c.data_fiscal )
                                                   || dsp_planilha.campo ( dsp_planilha.texto ( c.num_nf_saida ) )
                                                   || dsp_planilha.campo ( dsp_planilha.texto ( c.id_nota_fiscal ) )
                                                   || dsp_planilha.campo ( dsp_planilha.texto ( c.cfop ) )
                                                   || dsp_planilha.campo ( c.item )
                                                   || dsp_planilha.campo ( c.num_item )
                                                   || dsp_planilha.campo ( dsp_planilha.texto ( c.descricao_item ) )
                                                   || dsp_planilha.campo ( c.vlr_unit )
                                                   || dsp_planilha.campo ( c.quantidade )
                                                   || dsp_planilha.campo ( dsp_planilha.texto ( c.subclassificacao ) )
                                                   || dsp_planilha.campo ( dsp_planilha.texto ( c.nbm ) )
                                                   || dsp_planilha.campo ( dsp_planilha.texto ( c.grupo_situacao_b ) )
                                                   || dsp_planilha.campo ( dsp_planilha.texto ( c.cod_natureza_op ) )
                                                   || dsp_planilha.campo ( c.vlr_contabil )
                                                   || dsp_planilha.campo ( c.base_calculo )
                                                   || dsp_planilha.campo ( c.icms )
                                                   || dsp_planilha.campo ( c.aliq )
                                                   || dsp_planilha.campo ( c.pct_medi )
                                                   || dsp_planilha.campo ( c.pct_protege )
                                                   || dsp_planilha.campo ( c.vlr_entradas_aliq )
                                                   || dsp_planilha.campo ( c.vlr_total_entradas )
                                                   || dsp_planilha.campo ( c.pct_medio )
                                                   || dsp_planilha.campo ( c.cred_outorgado )
                                                   || dsp_planilha.campo ( c.protege )
                                                   || dsp_planilha.campo ( c.estorno_cred )
                                                   || dsp_planilha.campo ( c.vlr_liquido ) --
                                   , p_class => v_class
                );
            lib_proc.add ( v_text01
                         , ptipo => v_id_arq );
        END LOOP;

        lib_proc.add ( dsp_planilha.tabela_fim
                     , ptipo => v_id_arq );

        loga ( '[FIM LOAD_EXCEL] '
             , TRUE );
    END load_excel;

    ------------------------------------------------------------------------------ FIM - ANALITICO ----------------------------------------------------------------------------
    ----------------------------------------------------------------------------- INICIO - SINTETICO --------------------------------------------------------------------------
    --EXCEL
    PROCEDURE load_excel_sint ( v_data_inicial IN DATE
                              , v_data_final IN DATE
                              , p_cod_estab IN VARCHAR2
                              , v_id_arq IN NUMBER )
    IS
        v_sql VARCHAR2 ( 20000 );
        v_text01 VARCHAR2 ( 20000 );
        v_class VARCHAR2 ( 1 ) := 'A';
    BEGIN
        loga ( '[INICIO LOAD_EXCEL_SINT] '
             , TRUE );

        loga ( '>> Inicio Outorgado Sintético - Proc Id: ' || mproc_id
             , FALSE );

        lib_proc.add_tipo ( mproc_id
                          , v_id_arq
                          ,    mcod_empresa
                            || '_REL_OUTORGADO_SINTETICO_'
                            || TO_CHAR ( v_data_inicial
                                       , 'MM_YYYY' )
                            || '_'
                            || p_cod_estab
                            || '.XLS'
                          , 2 );

        lib_proc.add ( dsp_planilha.header
                     , ptipo => v_id_arq );
        lib_proc.add ( dsp_planilha.tabela_inicio
                     , ptipo => v_id_arq );

        lib_proc.add ( dsp_planilha.linha ( p_conteudo => dsp_planilha.campo ( 'SINTETICO'
                                                                             , p_custom => 'COLSPAN=6' )
                                          , p_class => 'h' )
                     , ptipo => v_id_arq );

        lib_proc.add ( dsp_planilha.linha (
                                            p_conteudo =>    dsp_planilha.campo ( 'PERIODO' )
                                                          || --
                                                            dsp_planilha.campo ( 'CATEGORIA' )
                                                          || --
                                                            dsp_planilha.campo ( 'CRED_OUTORGADO' )
                                                          || --
                                                            dsp_planilha.campo ( 'PROTEGE' )
                                                          || --
                                                            dsp_planilha.campo ( 'ESTORNO_LIMITACAO' )
                                                          || --
                                                            dsp_planilha.campo ( 'VLR_LIQUIDO' ) --
                                          , p_class => 'h'
                       )
                     , ptipo => v_id_arq );

        FOR c IN ( SELECT  TO_CHAR ( rel.data_fiscal
                                   , 'MM/YYYY' )
                               AS periodo
                         , subclassificacao AS categoria
                         , SUM ( ROUND ( rel.cred_outorgado
                                       , 2 ) )
                               AS cred_outorgado
                         , SUM ( ROUND ( rel.protege
                                       , 2 ) )
                               AS protege
                         , SUM ( ROUND ( rel.estorno_cred
                                       , 2 ) )
                               AS estorno_limitacao
                         , --
                            (   SUM ( ROUND ( rel.cred_outorgado
                                            , 2 ) )
                              - SUM ( ROUND ( rel.estorno_cred
                                            , 2 ) ) )
                               AS vlr_liquido
                      FROM msafi.dpsp_outorgado_cd_do rel
                     WHERE 1 = 1
                       AND data_fiscal BETWEEN v_data_inicial AND v_data_final
                       AND proc_id = mproc_id
                       AND NVL ( subclassificacao, '@' ) = 'MEDI'
                  GROUP BY TO_CHAR ( data_fiscal
                                   , 'MM/YYYY' )
                         , subclassificacao
                  UNION ALL
                  SELECT   TO_CHAR ( rel.data_fiscal
                                   , 'MM/YYYY' )
                               AS periodo
                         , 'OUTROS' AS categoria
                         , SUM ( ROUND ( rel.cred_outorgado
                                       , 2 ) )
                               AS cred_outorgado
                         , SUM ( ROUND ( rel.protege
                                       , 2 ) )
                               AS protege
                         , SUM ( ROUND ( rel.estorno_cred
                                       , 2 ) )
                               AS estorno_limitacao
                         , --
                            (   SUM ( ROUND ( rel.cred_outorgado
                                            , 2 ) )
                              - SUM ( ROUND ( rel.estorno_cred
                                            , 2 ) ) )
                               AS vlr_liquido
                      FROM msafi.dpsp_outorgado_cd_do rel
                     WHERE 1 = 1
                       AND data_fiscal BETWEEN v_data_inicial AND v_data_final
                       AND proc_id = mproc_id
                       AND NVL ( subclassificacao, '@' ) <> 'MEDI'
                  GROUP BY TO_CHAR ( data_fiscal
                                   , 'MM/YYYY' ) ) LOOP
            IF v_class = 'A' THEN
                v_class := 'B';
            ELSE
                v_class := 'A';
            END IF;

            v_text01 :=
                dsp_planilha.linha (
                                     p_conteudo =>    dsp_planilha.campo ( c.periodo )
                                                   || dsp_planilha.campo ( c.categoria )
                                                   || dsp_planilha.campo ( c.cred_outorgado )
                                                   || dsp_planilha.campo ( c.protege )
                                                   || dsp_planilha.campo ( c.estorno_limitacao )
                                                   || dsp_planilha.campo ( c.vlr_liquido )
                                   , p_class => v_class
                );
            lib_proc.add ( v_text01
                         , ptipo => v_id_arq );
        END LOOP;

        COMMIT;

        lib_proc.add ( dsp_planilha.tabela_fim
                     , ptipo => v_id_arq );

        loga ( '[FIM LOAD_EXCEL_SINT] '
             , TRUE );
    END load_excel_sint;

    ---------------------------------------------------------------------------------- FIM - SINTETICO ----------------------------------------------------------------------------

    PROCEDURE drop_old_tmp ( vp_mproc_id IN NUMBER )
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

            COMMIT;

            EXIT WHEN c_old_tmp%NOTFOUND;
        END LOOP;

        COMMIT;

        CLOSE c_old_tmp;
    END;

    PROCEDURE delete_temp_tbl ( vp_mproc_id IN NUMBER )
    IS
    BEGIN
        FOR temp_table IN ( SELECT table_name
                              FROM msafi.dpsp_msaf_tmp_control
                             WHERE proc_id = vp_mproc_id ) LOOP
            BEGIN
                EXECUTE IMMEDIATE 'DROP TABLE ' || temp_table.table_name;

                loga ( temp_table.table_name || ' <<'
                     , FALSE );
            EXCEPTION
                WHEN OTHERS THEN
                    loga ( temp_table.table_name || ' <<'
                         , FALSE );
            END;

            DELETE msafi.dpsp_msaf_tmp_control
             WHERE proc_id = vp_mproc_id
               AND table_name = temp_table.table_name;

            COMMIT;
        END LOOP;

        --- checar TMPs de processos interrompidos e dropar
        drop_old_tmp ( vp_mproc_id );
    END;

    ---------------------------------------------------------------------------------------------------------------------------------------------------------------
    PROCEDURE limpeza
    IS
        v_count NUMBER;
    BEGIN
        loga ( '>> Limpeza'
             , FALSE );

        --Apagar registros com execução maior do que 3 dias
        FOR c IN ( SELECT ROWID AS tmp_id
                     FROM msafi.dpsp_outorgado_cd_do
                    WHERE TO_DATE ( SUBSTR ( data_gravacao
                                           , 1
                                           , 10 )
                                  , 'DD/MM/YYYY' ) < TO_DATE ( SYSDATE - 3
                                                             , 'DD/MM/YYYY' ) ) LOOP
            DELETE FROM msafi.dpsp_outorgado_cd_do
                  WHERE ROWID = c.tmp_id;

            v_count := v_count + 1;

            IF v_count > 10000 THEN
                COMMIT;
                v_count := 0;
            END IF;
        END LOOP;
    END;

    ---------------------------------------------------------------------------------------------------------------------------------------------------------------
    FUNCTION executar ( p_data_ini DATE
                      , p_data_fim DATE
                      , p_ind_medi VARCHAR2
                      , p_pct_protege VARCHAR2
                      , p_lojas lib_proc.vartab )
        RETURN INTEGER
    IS
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
        vp_proc_instance VARCHAR2 ( 30 );

        v_count NUMBER;

        --
        TYPE cur_typ IS REF CURSOR;

        cr_cup cur_typ;

        ---
        v_data_hora_ini VARCHAR2 ( 20 );
        v_data_exec DATE;
        v_tab_aux VARCHAR2 ( 30 );
        vp_nome_tabela_aliq VARCHAR2 ( 30 );
        v_tab_busca_e VARCHAR2 ( 30 );
        v_tab_entrada VARCHAR2 ( 30 );

        v_pct_medi NUMBER;
        v_pct_protege NUMBER;

        v_id_arq NUMBER := 90;

        ------------------------------------------------------------------------------------------------
        --RANGE DE DATAS PARA BUSCAR VENDAS
        v_data_inicial DATE := p_data_ini; -- DATA INICIAL
        v_data_final DATE := p_data_fim; -- DATA FINAL
    ------------------------------------------------------------------------------------------------

    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS= '',.'' ';

        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_LANGUAGE = ''Portuguese'' ';

        --Recuperar a empresa para o plano de execução caso não esteja sendo executado pelo
        --diretamente na tela do Mastersaf
        lib_parametros.salvar ( 'EMPRESA'
                              , NVL ( mcod_empresa, msafi.dpsp.v_empresa ) );

        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        mcod_usuario := lib_parametros.recuperar ( 'USUARIO' );

        IF mcod_usuario IS NULL THEN
            lib_parametros.salvar ( 'USUARIO'
                                  , 'AUTOMATICO' );
            mcod_usuario := lib_parametros.recuperar ( 'USUARIO' );
        END IF;

        v_count := p_lojas.COUNT;

        mproc_id :=
            lib_proc.new ( $$plsql_unit
                         , 48
                         , 150 );

        lib_proc.add_tipo ( mproc_id
                          , 1
                          ,    TO_CHAR ( SYSDATE
                                       , 'YYYYMMDDHH24MISS' )
                            || '_OUTORGADO'
                          , 1 );

        --MARCAR INCIO DA EXECUCAO
        v_data_exec := SYSDATE;

        v_data_hora_ini :=
            TO_CHAR ( v_data_exec
                    , 'DD/MM/YYYY HH24:MI.SS' );

        FOR c_dados_emp IN ( SELECT cod_empresa
                                  , razao_social
                                  , DECODE ( cnpj
                                           , NULL, NULL
                                           , REPLACE ( REPLACE ( REPLACE ( TO_CHAR ( LPAD ( REPLACE ( cnpj
                                                                                                    , '' )
                                                                                          , 14
                                                                                          , '0' )
                                                                                   , '00,000,000,0000,00' )
                                                                         , ','
                                                                         , '.' )
                                                               , ' ' )
                                                     ,    '.'
                                                       || TRIM ( TO_CHAR ( TRUNC (   MOD ( LPAD ( cnpj
                                                                                                , 14
                                                                                                , '0' )
                                                                                         , 1000000 )
                                                                                   / 100 )
                                                                         , '0000' ) )
                                                       || '.'
                                                     ,    '/'
                                                       || TRIM ( TO_CHAR ( TRUNC (   MOD ( LPAD ( cnpj
                                                                                                , 14
                                                                                                , '0' )
                                                                                         , 1000000 )
                                                                                   / 100 )
                                                                         , '0000' ) )
                                                       || '-' ) )
                                        AS cnpj
                               FROM empresa
                              WHERE cod_empresa = mcod_empresa ) LOOP
            cabecalho ( c_dados_emp.razao_social
                      , c_dados_emp.cnpj
                      , v_data_hora_ini
                      , v_data_inicial
                      , v_data_final );
        END LOOP;

        loga ( '<<' || mnm_cproc || '>>'
             , FALSE );
        loga ( '---INICIO DO PROCESSAMENTO---'
             , FALSE );

        --TRATAR PERCENTUAL MEDICAMENTO--
        v_pct_medi := ( CASE WHEN p_ind_medi = '1' THEN '3' WHEN p_ind_medi = '2' THEN '4' END );
        --------------------------------

        --TRATAR PERCENTUAL DO PRODEPE--
        v_pct_protege :=
            TO_NUMBER ( REPLACE ( p_pct_protege
                                , '.'
                                , ',' ) );
        --------------------------------

        dbms_application_info.set_module ( $$plsql_unit
                                         , 'PROC_ID: ' || mproc_id );

        loga ( 'Data execução: ' || v_data_hora_ini
             , FALSE );

        loga ( 'Usuário: ' || mcod_usuario
             , FALSE );
        loga ( 'Empresa: ' || mcod_empresa
             , FALSE );
        loga ( 'Data Inicial: ' || v_data_inicial
             , FALSE );
        loga ( 'Data Final: ' || v_data_final
             , FALSE );
        loga (    'Percentual MEDICAMENTO: '
               || TRIM ( TO_CHAR ( v_pct_medi
                                 , '90.00' ) )
               || '%'
             , FALSE );
        loga (    'Percentual PROTEGE: '
               || TRIM ( TO_CHAR ( v_pct_protege
                                 , '90.00' ) )
               || '%'
             , FALSE );
        loga ( 'Qtde Estabs: ' || v_count
             , FALSE );

        --GERAR CHAVE PROC_ID
        SELECT ROUND ( dbms_random.VALUE ( 10000000000000
                                         , 999999999999999 ) )
          INTO vp_proc_instance
          FROM DUAL;

        loga ( '----------------------------------------'
             , FALSE );
        loga ( '>> PROC INSERT: ' || vp_proc_instance
             , FALSE );
        loga ( '----------------------------------------'
             , FALSE );

        --LIMPAR REGISTROS ANTIGOS DA TABELA FINAL
        limpeza;

        drop_old_tmp ( vp_proc_instance );

        IF v_pct_protege < '0,5'
        OR v_pct_protege > '15' THEN
            v_text01 := 'Valor do Percentual PRODEPE inválido!';
            lib_proc.add ( v_text01
                         , NULL
                         , NULL
                         , 1 );
            loga ( v_text01
                 , FALSE );

            v_text01 := 'Somente é permitido valores de 0.01% à 15.00%, favor verificar os parâmetros.';
            lib_proc.add ( v_text01
                         , NULL
                         , NULL
                         , 1 );
            loga ( v_text01
                 , FALSE );

            v_text01 := 'Percentual PRODEPE informado: ' || p_pct_protege || '%';
            lib_proc.add ( v_text01
                         , NULL
                         , NULL
                         , 1 );
            loga ( v_text01
                 , FALSE );

            lib_proc.add ( ' '
                         , 1 );
            lib_proc.add ( 'FIM DO PROCESSAMENTO, STATUS FINAL: [ERRO]'
                         , 1 );

            loga ( '---FIM DO PROCESSAMENTO---'
                 , FALSE );

            --ENVIAR EMAIL DE ERRO-------------------------------------------
            envia_email (
                          mcod_empresa
                        , v_data_inicial
                        , v_data_final
                        ,    'Valor do Percentual PRODEPE inválido!'
                          || CHR ( 13 )
                          || 'Favor verificar os parâmetros informados.'
                        , 'E'
                        , SYSDATE
            );
        -----------------------------------------------------------------

        ELSE
            --PREPARAR LOJAS SP
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
                             WHERE cod_empresa = mcod_empresa ) LOOP
                    a_estabs.EXTEND ( );
                    a_estabs ( a_estabs.LAST ) := c1.cod_estab;
                END LOOP;
            END IF;

            --DISPONIBILIZAR PERIODO PROCESSADO PARA TRAVA DE REPROCESSAMENTO
            create_saida ( vp_proc_instance
                         , v_tab_aux );
            create_entrada ( vp_proc_instance
                           , v_tab_entrada );

            --EXECUTAR UM P_COD_ESTAB POR VEZ
            FOR est IN a_estabs.FIRST .. a_estabs.LAST --(1)
                                                      LOOP
                loga ( '----------------------------------------'
                     , FALSE );
                loga ( '>> ESTAB: ' || a_estabs ( est )
                     , FALSE );
                loga ( '----------------------------------------'
                     , FALSE );

                load_saidas ( v_tab_aux
                            , vp_proc_instance
                            , v_data_inicial
                            , v_data_final
                            , a_estabs ( est ) );
                --
                load_aliq_interna ( vp_proc_instance
                                  , vp_nome_tabela_aliq
                                  , v_tab_aux
                                  , v_data_inicial
                                  , v_data_final );
                --
                create_busca_en ( vp_proc_instance
                                , v_tab_aux
                                , v_tab_busca_e );
                --
                load_entrada ( vp_proc_instance
                             , v_tab_busca_e
                             , v_tab_entrada
                             , v_data_inicial
                             , v_data_final
                             , a_estabs ( est ) );
                --
                refugo_xml ( vp_proc_instance
                           , v_tab_entrada );
                --
                load_tab_final ( mproc_id
                               , v_tab_aux
                               , v_tab_entrada
                               , vp_nome_tabela_aliq
                               , v_pct_medi
                               , v_pct_protege
                               , v_data_inicial
                               , v_data_final );
                --
                v_id_arq := v_id_arq + 1;

                load_excel ( v_data_inicial
                           , v_data_final
                           , a_estabs ( est )
                           , v_id_arq );
                --
                v_id_arq := v_id_arq + 1;

                load_excel_sint ( v_data_inicial
                                , v_data_final
                                , a_estabs ( est )
                                , v_id_arq );
            --

            END LOOP;

            delete_temp_tbl ( vp_proc_instance );

            lib_proc.add ( ' '
                         , 1 );
            lib_proc.add ( 'FIM DO PROCESSAMENTO, STATUS FINAL: [SUCESSO]'
                         , 1 );

            loga ( '---FIM DO PROCESSAMENTO---'
                 , FALSE );

            --ENVIAR EMAIL DE SUCESSO ----------------------------------------------------------------------
            envia_email ( mcod_empresa
                        , v_data_inicial
                        , v_data_final
                        , ''
                        , 'S'
                        , v_data_exec );
        ------------------------------------------------------------------------------------------------

        END IF; --VALIDAR V_PCT_PROTEGE

        lib_proc.close ( );
        COMMIT;
        RETURN mproc_id;
    EXCEPTION
        WHEN OTHERS THEN
            loga ( 'SQLERRM: ' || SQLERRM
                 , FALSE );
            lib_proc.add_log ( 'ERRO NÃO TRATADO: ' || dbms_utility.format_error_backtrace
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
                        , SYSDATE );
            -----------------------------------------------------------------

            lib_proc.close;
            COMMIT;
            RETURN mproc_id;
    END;
END dpsp_fin2700_cred_ot_cproc;
/
SHOW ERRORS;
