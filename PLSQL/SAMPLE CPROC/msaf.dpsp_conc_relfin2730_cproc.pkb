Prompt Package Body DPSP_CONC_RELFIN2730_CPROC;
--
-- DPSP_CONC_RELFIN2730_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_conc_relfin2730_cproc
IS
    v_tab_footer VARCHAR2 ( 100 )
        := ' STORAGE (BUFFER_POOL KEEP) PCTFREE 10 NOLOGGING NOCOMPRESS CACHE TABLESPACE MSAF_WORK_TABLES ';
    v_sel_data_fim VARCHAR2 ( 260 )
        := ' SELECT TRUNC( TO_DATE( :1 ,''DD/MM/YYYY'') + ROWNUM - 1) AS DATA_FIM, TRUNC( TO_DATE( :1 ,''DD/MM/YYYY'') + ROWNUM - 1) AS DATA_FIM FROM DUAL CONNECT BY ROWNUM <= LAST_DAY( TO_DATE( :1 ,''DD/MM/YYYY'') ) - TO_DATE( :1 ,''DD/MM/YYYY'') + 1 ORDER BY 1 DESC ';
    v_sel_data_par VARCHAR2 ( 260 )
        := ' SELECT TRUNC(TO_DATE( :1 , ''DD/MM/YYYY'') + ROWNUM - 1) AS P_DATA_PAR, TRUNC (TO_DATE ( :1 , ''DD/MM/YYYY'') + ROWNUM - 1) AS P_DATA_PAR FROM DUAL CONNECT BY ROWNUM <= ADD_MONTHS(TO_DATE( :1 ,''DD/MM/YYYY''),3) - TO_DATE ( :1 , ''DD/MM/YYYY'')+ 1 ORDER BY 1 DESC ';

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
                           , 'Data Busca Ult Entrada'
                           , --P_DATA_PAR
                            'VARCHAR2'
                           , 'COMBOBOX'
                           , 'S'
                           , NULL
                           , '##########'
                           , v_sel_data_par );

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
    END; --FUNCTION PARAMETROS RETURN VARCHAR2 IS

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Processar Relatório Conciliação entre Estabelecimentos';
    END;

    FUNCTION tipo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Fechamento';
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
        RETURN 'Emitir Relatório de confronto de NFs Saidas x Entradas';
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

    ---------------------------------------------------------------------------------------------------------------------------------------------------------

    PROCEDURE create_saida ( vp_mproc_id IN NUMBER
                           , v_tab_aux   OUT VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 10000 );
        v_idx_prop VARCHAR2 ( 50 ) := ' PCTFREE 10 NOLOGGING';
    BEGIN
        --LOGA('>> Create table ' || 'DPSP_SAIDA_' || VP_MPROC_ID , FALSE);

        v_tab_aux := 'DPSP_SAIDA_' || vp_mproc_id;

        v_sql := 'CREATE TABLE ' || v_tab_aux;
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || ' COD_EMPRESA                  VARCHAR2(3),  ';
        v_sql := v_sql || ' COD_ESTAB                    VARCHAR2(6),  ';
        v_sql := v_sql || ' DATA_FISCAL                  DATE        , ';
        v_sql := v_sql || ' MOVTO_E_S                    VARCHAR2(1) , ';
        v_sql := v_sql || ' NORM_DEV                     VARCHAR2(1) , ';
        v_sql := v_sql || ' IDENT_DOCTO                  NUMBER(12),   ';
        v_sql := v_sql || ' IDENT_FIS_JUR                NUMBER(12),   ';
        v_sql := v_sql || ' NUM_DOCFIS                   VARCHAR2(12) ,';
        v_sql := v_sql || ' SERIE_DOCFIS                 VARCHAR2(3) , ';
        v_sql := v_sql || ' SUB_SERIE_DOCFIS             VARCHAR2(2) , ';
        v_sql := v_sql || ' DATA_EMISSAO                 DATE,         ';
        v_sql := v_sql || ' NUM_AUTENTIC_NFE             VARCHAR2(80), ';
        v_sql := v_sql || ' CPF_CGC                      VARCHAR2(14), ';
        v_sql := v_sql || ' COD_FIS_JUR                  VARCHAR2(14), ';
        v_sql := v_sql || ' COD_ESTADO                   VARCHAR2(2),  ';
        v_sql := v_sql || ' VLR_TOT_NOTA                 NUMBER(17,2), ';
        v_sql := v_sql || ' NUM_CONTROLE_DOCTO           VARCHAR2(12),  ';
        v_sql := v_sql || ' BUSINESS_UNIT                VARCHAR2(6),  ';
        v_sql := v_sql || ' NF_BRL_ID                    VARCHAR2(12),  ';
        v_sql := v_sql || ' COD_SISTEMA_ORIG             VARCHAR2(4)  ';
        v_sql := v_sql || ' ) ' || v_tab_footer;

        EXECUTE IMMEDIATE v_sql;

        save_tmp_control ( vp_mproc_id
                         , v_tab_aux );

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
        v_sql := v_sql || ' SUB_SERIE_DOCFIS    ASC  ';
        v_sql := v_sql || ' ) ' || v_idx_prop;

        EXECUTE IMMEDIATE v_sql;
    END;

    --------------------------------------------------------------------------------------------------------------------------------------

    PROCEDURE load_saidas ( v_tab_aux IN VARCHAR
                          , v_data_inicial IN DATE
                          , v_data_final IN DATE
                          , p_cod_estab IN VARCHAR )
    IS
        v_sql VARCHAR2 ( 5000 );
        --
        dblink VARCHAR2 ( 16 );
    --

    --
    BEGIN
        /*IF mcod_empresa = 'DSP'
        THEN
          dblink := '@DBLINK_DBMRJPRD';
        ELSE
          dblink := '@DBLINK_DBMSPPRD';
        END IF;*/

        IF mcod_empresa = 'DSP' THEN
            dblink := '@DBLINK_DBMRJHOM';
        ELSE
            dblink := '@DBLINK_DBMSPHOM';
        END IF;

        ----------------------------
        --
        v_sql := ' INSERT INTO ' || v_tab_aux;
        v_sql :=
               v_sql
            || ' SELECT A.COD_EMPRESA, A.COD_ESTAB, A.DATA_FISCAL, A.MOVTO_E_S, A.NORM_DEV, A.IDENT_DOCTO, A.IDENT_FIS_JUR, A.NUM_DOCFIS, ';
        v_sql :=
               v_sql
            || ' A.SERIE_DOCFIS, A.SUB_SERIE_DOCFIS, A.DATA_EMISSAO, A.NUM_AUTENTIC_NFE, B.CPF_CGC , B.COD_FIS_JUR, E.COD_ESTADO, A.VLR_TOT_NOTA, A.NUM_CONTROLE_DOCTO,  SUBSTR(IDENTIF_DOCFIS,3,5) AS BUSINESS_UNIT, SUBSTR(IDENTIF_DOCFIS,9,10) NF_BRL_ID, A.cod_sistema_orig  ';
        v_sql :=
               v_sql
            || ' FROM X07_DOCTO_FISCAL PARTITION FOR (TO_DATE('''
            || TO_CHAR ( v_data_inicial
                       , 'DDMMYYYY' )
            || ''',''DDMMYYYY'')) A, X04_PESSOA_FIS_JUR B , MSAF.ESTABELECIMENTO C, MSAFI.DSP_ESTABELECIMENTO D, MSAF.ESTADO E  ';
        v_sql := v_sql || ' WHERE A.IDENT_FIS_JUR = B.IDENT_FIS_JUR ';
        v_sql := v_sql || ' AND A.MOVTO_E_S = ''9'' ';
        v_sql := v_sql || ' AND A.SITUACAO = ''N'' ';
        v_sql := v_sql || ' AND B.IDENT_ESTADO = E.IDENT_ESTADO ';
        v_sql := v_sql || ' AND A.COD_EMPRESA = MSAFI.DPSP.EMPRESA ';
        v_sql := v_sql || ' AND A.COD_ESTAB =  ''' || p_cod_estab || ''' ';
        v_sql := v_sql || ' AND C.COD_EMPRESA = A.COD_EMPRESA ';
        v_sql := v_sql || ' AND C.COD_ESTAB = A.COD_ESTAB  ';
        v_sql :=
               v_sql
            || ' AND DATA_FISCAL BETWEEN TO_DATE('''
            || TO_CHAR ( v_data_inicial
                       , 'DDMMYYYY' )
            || ''',''DDMMYYYY'') AND TO_DATE('''
            || TO_CHAR ( v_data_final
                       , 'DDMMYYYY' )
            || ''',''DDMMYYYY'') ';
        v_sql := v_sql || ' AND D.COD_EMPRESA = A.COD_EMPRESA ';
        v_sql := v_sql || ' AND D.COD_ESTAB = A.COD_ESTAB ';
        v_sql := v_sql || ' AND LPAD(B.CPF_CGC,14,''0'') <> LPAD(C.CGC,14,''0'') ';
        v_sql :=
               v_sql
            || ' AND (EXISTS (SELECT 1 FROM  MSAF.ESTABELECIMENTO D WHERE LPAD(D.CGC,14,''0'') = LPAD(B.CPF_CGC,14,''0''))';
        v_sql :=
               v_sql
            || ' OR EXISTS (SELECT 1 FROM  MSAF.ESTABELECIMENTO'
            || dblink
            || ' D WHERE LPAD(D.CGC,14,''0'') = LPAD(B.CPF_CGC,14,''0'')))';

        EXECUTE IMMEDIATE v_sql;
    --LOGA('SAIDAS CARREGADAS!');
    ----------------------------
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
                                    , '!ERRO INSERT LOAD SAIDAS!' );

            lib_proc.add ( dbms_utility.format_error_backtrace
                         , 1 );
    END load_saidas;

    ---------------------------------------------------------------------------------------------------------------------------------------------------------
    PROCEDURE create_entrada ( vp_mproc_id IN NUMBER
                             , v_tab_aux_en   OUT VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 10000 );
        v_idx_prop VARCHAR2 ( 50 ) := ' PCTFREE 10 NOLOGGING';
    BEGIN
        v_tab_aux_en := 'DPSP_ENTRADA_' || vp_mproc_id;
        --
        v_sql := 'CREATE TABLE ' || v_tab_aux_en;
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || ' COD_EMPRESA                  VARCHAR2(3),  ';
        v_sql := v_sql || ' COD_ESTAB                    VARCHAR2(6),  ';
        v_sql := v_sql || ' DATA_FISCAL                  DATE        , ';
        v_sql := v_sql || ' MOVTO_E_S                    VARCHAR2(1) , ';
        v_sql := v_sql || ' NORM_DEV                     VARCHAR2(1) , ';
        v_sql := v_sql || ' IDENT_DOCTO                  NUMBER(12),   ';
        v_sql := v_sql || ' IDENT_FIS_JUR                NUMBER(12),   ';
        v_sql := v_sql || ' NUM_DOCFIS                   VARCHAR2(12) ,';
        v_sql := v_sql || ' SERIE_DOCFIS                 VARCHAR2(3) , ';
        v_sql := v_sql || ' SUB_SERIE_DOCFIS             VARCHAR2(2) , ';
        v_sql := v_sql || ' DATA_EMISSAO                 DATE,         ';
        v_sql := v_sql || ' NUM_AUTENTIC_NFE             VARCHAR2(80), ';
        v_sql := v_sql || ' NUM_CONTROLE_DOCTO           VARCHAR2(12), ';
        v_sql := v_sql || ' CPF_CGC                      VARCHAR2(14), ';
        v_sql := v_sql || ' COD_ESTADO                   VARCHAR2(2)  ';
        v_sql := v_sql || ' ) ' || v_tab_footer;

        EXECUTE IMMEDIATE v_sql;

        save_tmp_control ( vp_mproc_id
                         , v_tab_aux_en );

        v_sql := 'CREATE UNIQUE INDEX PKCE_' || vp_mproc_id || ' ON ' || v_tab_aux_en;
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
        v_sql := v_sql || ' SUB_SERIE_DOCFIS    ASC  ';
        v_sql := v_sql || ' ) ' || v_idx_prop;

        EXECUTE IMMEDIATE v_sql;
    ----------------------------
    END;

    ---------------------------------------------------------------------------------------------------------------------------------------------------------
    PROCEDURE load_entrada ( v_tab_aux_en IN VARCHAR
                           , v_tab_aux IN VARCHAR
                           , v_data_inicial IN DATE
                           , p_data_par IN DATE
                           , p_cod_estab IN VARCHAR )
    IS
        v_sql VARCHAR2 ( 5000 );
        --
        v_i_x07_particao VARCHAR2 ( 128 );
    --

    BEGIN
        --Chamada Cursor

        FOR c IN ( SELECT     DISTINCT TRUNC ( v_data_inicial + ROWNUM - 1
                                             , 'MM' )
                                           AS data_inicio
                                     , LAST_DAY ( v_data_inicial + ROWNUM - 1 ) data_fim
                         FROM DUAL
                   CONNECT BY ROWNUM <= p_data_par - v_data_inicial + 1
                     ORDER BY 1 ) LOOP
            v_sql := 'DECLARE TYPE T_BULK_COLLECT_TAB07 IS TABLE OF ' || v_tab_aux_en || '%ROWTYPE; ';
            v_sql := v_sql || '        X07_TAB T_BULK_COLLECT_TAB07 := T_BULK_COLLECT_TAB07(); ';
            v_sql := v_sql || 'BEGIN ';
            ---
            v_sql := v_sql || 'SELECT /*+RESULT_CACHE*/ ';
            v_sql := v_sql || ' A.COD_EMPRESA        , ';
            v_sql := v_sql || ' A.COD_ESTAB          , ';
            v_sql := v_sql || ' A.DATA_FISCAL        , ';
            v_sql := v_sql || ' A.MOVTO_E_S          , ';
            v_sql := v_sql || ' A.NORM_DEV           , ';
            v_sql := v_sql || ' A.IDENT_DOCTO        , ';
            v_sql := v_sql || ' A.IDENT_FIS_JUR      , ';
            v_sql := v_sql || ' A.NUM_DOCFIS         , ';
            v_sql := v_sql || ' A.SERIE_DOCFIS       , ';
            v_sql := v_sql || ' A.SUB_SERIE_DOCFIS   , ';
            v_sql := v_sql || ' A.DATA_EMISSAO       , ';
            v_sql := v_sql || ' A.NUM_AUTENTIC_NFE     , ';
            v_sql := v_sql || ' A.NUM_CONTROLE_DOCTO   , ';
            v_sql := v_sql || ' B.CGC ,                 ';
            v_sql := v_sql || ' C.COD_ESTADO          ';
            v_sql := v_sql || 'BULK COLLECT INTO X07_TAB ';
            v_sql :=
                   v_sql
                || 'FROM MSAF.X07_DOCTO_FISCAL PARTITION for (TO_DATE('''
                || TO_CHAR ( c.data_inicio
                           , 'DDMMYYYY' )
                || ''',''DDMMYYYY'')) A , ESTABELECIMENTO B , MSAFI.DSP_ESTABELECIMENTO C ';
            v_sql := v_sql || 'WHERE A.COD_EMPRESA   = MSAFI.DPSP.EMPRESA ';
            v_sql := v_sql || ' AND A.COD_EMPRESA = B.COD_EMPRESA AND A.COD_ESTAB = B.COD_ESTAB ';
            v_sql := v_sql || ' AND A.MOVTO_E_S    <> ''9'' ';
            v_sql := v_sql || ' AND A.SITUACAO     <> ''S'' ';
            v_sql :=
                   v_sql
                || ' AND A.DATA_FISCAL BETWEEN TO_DATE('''
                || TO_CHAR ( c.data_inicio
                           , 'DDMMYYYY' )
                || ''',''DDMMYYYY'') AND TO_DATE('''
                || TO_CHAR ( c.data_fim
                           , 'DDMMYYYY' )
                || ''',''DDMMYYYY'') ';
            v_sql := v_sql || ' AND A.DATA_FISCAL <= ''' || p_data_par || '''';
            v_sql :=
                v_sql || ' AND A.COD_ESTAB  IN (SELECT DISTINCT SUBSTR(COD_FIS_JUR,1,6) FROM ' || v_tab_aux || ') ';
            v_sql := v_sql || ' AND C.COD_EMPRESA = A.COD_EMPRESA ';
            v_sql := v_sql || ' AND C.COD_ESTAB = A.COD_ESTAB ';
            --
            v_sql := v_sql || ' AND NOT EXISTS (SELECT ''X'' FROM ' || v_tab_aux_en || ' EN           ';
            v_sql := v_sql || ' WHERE   EN.COD_EMPRESA            = A.COD_EMPRESA            ';
            v_sql := v_sql || ' AND        EN.COD_EMPRESA            = A.COD_EMPRESA         ';
            v_sql := v_sql || ' AND        EN.COD_ESTAB              = A.COD_ESTAB           ';
            v_sql := v_sql || ' AND        EN.DATA_FISCAL            = A.DATA_FISCAL         ';
            v_sql := v_sql || ' AND        EN.MOVTO_E_S              = A.MOVTO_E_S           ';
            v_sql := v_sql || ' AND        EN.NORM_DEV               = A.NORM_DEV            ';
            v_sql := v_sql || ' AND        EN.IDENT_DOCTO            = A.IDENT_DOCTO         ';
            v_sql := v_sql || ' AND        EN.IDENT_FIS_JUR          = A.IDENT_FIS_JUR       ';
            v_sql := v_sql || ' AND        EN.NUM_DOCFIS             = A.NUM_DOCFIS          ';
            v_sql := v_sql || ' AND        EN.SERIE_DOCFIS           = A.SERIE_DOCFIS        ';
            v_sql := v_sql || ' AND        EN.SUB_SERIE_DOCFIS       = A.SUB_SERIE_DOCFIS  ); ';
            ---
            v_sql := v_sql || 'FORALL I IN X07_TAB.FIRST .. X07_TAB.LAST ';
            v_sql := v_sql || ' INSERT INTO ' || v_tab_aux_en || ' VALUES X07_TAB(I); ';
            v_sql := v_sql || 'COMMIT; ';
            ---
            v_sql := v_sql || 'END; ';

            --
            EXECUTE IMMEDIATE v_sql;
        END LOOP;

        loga ( 'ENTRADAS CARREGADAS LOCAL! ' || p_cod_estab || ' - ' || v_i_x07_particao || ' ' );
    ----------------------------
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
                                    , '!ERRO INSERT LOAD ENTRADAS!' );

            lib_proc.add ( dbms_utility.format_error_backtrace
                         , 1 );
    END load_entrada;

    --------------------------------------------------------------------------------------------------------------------------------------------------------------
    PROCEDURE load_entrada_inter ( v_tab_aux_en IN VARCHAR
                                 , v_data_inicial IN DATE
                                 , p_data_par IN DATE )
    IS
        v_sql VARCHAR2 ( 5000 );
        --
        dblink VARCHAR2 ( 16 );
        cod_emp VARCHAR2 ( 3 );
    --*/


    BEGIN
        /*    IF mcod_empresa = 'DSP'
            THEN
              dblink  := '@DBLINK_DBMRJPRD';
              cod_emp := 'DP';
            ELSE
              dblink  := '@DBLINK_DBMSPPRD';
              cod_emp := 'DSP';
            END IF; */

        IF mcod_empresa = 'DSP' THEN
            dblink := '@DBLINK_DBMRJHOM';
            cod_emp := 'DP';
        ELSE
            dblink := '@DBLINK_DBMSPHOM';
            cod_emp := 'DSP';
        END IF;

        FOR c IN ( SELECT     DISTINCT TRUNC ( v_data_inicial + ROWNUM - 1
                                             , 'MM' )
                                           AS data_inicio
                                     , LAST_DAY ( v_data_inicial + ROWNUM - 1 ) data_fim
                         FROM DUAL
                   CONNECT BY ROWNUM <= p_data_par - v_data_inicial + 1
                     ORDER BY 1 ) LOOP
            v_sql := 'DECLARE TYPE T_BULK_COLLECT_TAB07 IS TABLE OF ' || v_tab_aux_en || '%ROWTYPE; ';
            v_sql := v_sql || '        X07_TAB T_BULK_COLLECT_TAB07 := T_BULK_COLLECT_TAB07(); ';
            v_sql := v_sql || 'BEGIN ';
            ---
            v_sql := v_sql || 'SELECT /*+RESULT_CACHE*/ ';
            v_sql := v_sql || ' A.COD_EMPRESA        , ';
            v_sql := v_sql || ' A.COD_ESTAB          , ';
            v_sql := v_sql || ' A.DATA_FISCAL        , ';
            v_sql := v_sql || ' A.MOVTO_E_S          , ';
            v_sql := v_sql || ' A.NORM_DEV           , ';
            v_sql := v_sql || ' A.IDENT_DOCTO        , ';
            v_sql := v_sql || ' A.IDENT_FIS_JUR      , ';
            v_sql := v_sql || ' A.NUM_DOCFIS         , ';
            v_sql := v_sql || ' A.SERIE_DOCFIS       , ';
            v_sql := v_sql || ' A.SUB_SERIE_DOCFIS   , ';
            v_sql := v_sql || ' A.DATA_EMISSAO       , ';
            v_sql := v_sql || ' A.NUM_AUTENTIC_NFE     , ';
            v_sql := v_sql || ' A.NUM_CONTROLE_DOCTO   , ';
            v_sql := v_sql || ' B.CGC ,                 ';
            v_sql := v_sql || ' C.COD_ESTADO          ';
            v_sql := v_sql || 'BULK COLLECT INTO X07_TAB ';
            v_sql :=
                   v_sql
                || 'FROM MSAF.X07_DOCTO_FISCAL'
                || dblink
                || ' A , ESTABELECIMENTO'
                || dblink
                || ' B , MSAFI.DSP_ESTABELECIMENTO'
                || dblink
                || ' C ';
            v_sql := v_sql || 'WHERE A.COD_EMPRESA   = ''' || cod_emp || ''' ';
            v_sql := v_sql || ' AND A.COD_EMPRESA = B.COD_EMPRESA AND A.COD_ESTAB = B.COD_ESTAB ';
            v_sql := v_sql || ' AND A.MOVTO_E_S    <> ''9'' ';
            v_sql := v_sql || ' AND A.SITUACAO     <> ''S'' ';
            v_sql :=
                   v_sql
                || ' AND A.DATA_FISCAL BETWEEN TO_DATE('''
                || TO_CHAR ( c.data_inicio
                           , 'DDMMYYYY' )
                || ''',''DDMMYYYY'') AND TO_DATE('''
                || TO_CHAR ( c.data_fim
                           , 'DDMMYYYY' )
                || ''',''DDMMYYYY'') ';
            v_sql := v_sql || ' AND A.DATA_FISCAL <= ''' || p_data_par || '''';
            v_sql := v_sql || ' AND C.COD_ESTAB = A.COD_ESTAB ';
            --
            v_sql := v_sql || ' AND NOT EXISTS (SELECT ''X'' FROM ' || v_tab_aux_en || ' EN           ';
            v_sql := v_sql || ' WHERE      EN.COD_ESTAB              = A.COD_ESTAB           ';
            v_sql := v_sql || ' AND        EN.DATA_FISCAL            = A.DATA_FISCAL         ';
            v_sql := v_sql || ' AND        EN.MOVTO_E_S              = A.MOVTO_E_S           ';
            v_sql := v_sql || ' AND        EN.NORM_DEV               = A.NORM_DEV            ';
            v_sql := v_sql || ' AND        EN.IDENT_DOCTO            = A.IDENT_DOCTO         ';
            v_sql := v_sql || ' AND        EN.IDENT_FIS_JUR          = A.IDENT_FIS_JUR       ';
            v_sql := v_sql || ' AND        EN.NUM_DOCFIS             = A.NUM_DOCFIS          ';
            v_sql := v_sql || ' AND        EN.SERIE_DOCFIS           = A.SERIE_DOCFIS        ';
            v_sql := v_sql || ' AND        EN.SUB_SERIE_DOCFIS       = A.SUB_SERIE_DOCFIS  ); ';
            ---
            v_sql := v_sql || 'FORALL I IN X07_TAB.FIRST .. X07_TAB.LAST ';
            v_sql := v_sql || ' INSERT INTO ' || v_tab_aux_en || ' VALUES X07_TAB(I); ';
            v_sql := v_sql || 'COMMIT; ';
            ---
            v_sql := v_sql || 'END; ';

            --
            EXECUTE IMMEDIATE v_sql;

            loga ( 'ENTRADAS CARREGADAS DBLINK!' );
        END LOOP;
    ----------------------------
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
                                    , '!ERRO INSERT LOAD ENTRADAS!' );

            lib_proc.add ( dbms_utility.format_error_backtrace
                         , 1 );
    END load_entrada_inter;

    --------------------------------------------------------------------------------------------------------------------------------------------------------------

    PROCEDURE create_tab_aux ( vp_mproc_id IN NUMBER
                             , v_tab_aux_pe   OUT VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 10000 );
        v_idx_prop VARCHAR2 ( 50 ) := ' PCTFREE 10 NOLOGGING';
    BEGIN
        v_tab_aux_pe := 'DPSP_AUX_' || vp_mproc_id;

        v_sql := 'CREATE TABLE ' || v_tab_aux_pe;
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || ' COD_EMPRESA                  VARCHAR2(3),  ';
        v_sql := v_sql || ' COD_ESTAB                    VARCHAR2(6),  ';
        v_sql := v_sql || ' DATA_FISCAL                  DATE        , ';
        v_sql := v_sql || ' MOVTO_E_S                    VARCHAR2(1) , ';
        v_sql := v_sql || ' NORM_DEV                     VARCHAR2(1) , ';
        v_sql := v_sql || ' IDENT_DOCTO                  NUMBER(12),   ';
        v_sql := v_sql || ' IDENT_FIS_JUR                NUMBER(12),   ';
        v_sql := v_sql || ' NUM_DOCFIS                   VARCHAR2(12) ,';
        v_sql := v_sql || ' SERIE_DOCFIS                 VARCHAR2(3) , ';
        v_sql := v_sql || ' SUB_SERIE_DOCFIS             VARCHAR2(2) , ';
        v_sql := v_sql || ' DATA_EMISSAO                 DATE,         ';
        v_sql := v_sql || ' NUM_AUTENTIC_NFE             VARCHAR2(80), ';
        v_sql := v_sql || ' CPF_CGC                      VARCHAR2(14), ';
        v_sql := v_sql || ' COD_FIS_JUR                  VARCHAR2(14), ';
        v_sql := v_sql || ' COD_ESTADO                   VARCHAR2(2),  ';
        v_sql := v_sql || ' VLR_TOT_NOTA                 NUMBER(17,2), ';
        v_sql := v_sql || ' NUM_CONTROLE_DOCTO           VARCHAR2(12),  ';
        v_sql := v_sql || ' COD_SISTEMA_ORIG           VARCHAR2(4),  ';
        v_sql := v_sql || ' BUSINESS_UNIT                VARCHAR2(6), ';
        v_sql := v_sql || ' NF_BRL_ID                    VARCHAR2(12)  ';
        v_sql := v_sql || ' ) ' || v_tab_footer;

        EXECUTE IMMEDIATE v_sql;

        save_tmp_control ( vp_mproc_id
                         , v_tab_aux_pe );

        v_sql := 'CREATE UNIQUE INDEX PKCYE_' || vp_mproc_id || ' ON ' || v_tab_aux_pe;
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
        v_sql := v_sql || ' SUB_SERIE_DOCFIS    ASC  ';
        v_sql := v_sql || ' ) ' || v_idx_prop;

        EXECUTE IMMEDIATE v_sql;

        COMMIT;
    END;

    --------------------------------------------------------------------------------------------------------------------------------------
    PROCEDURE load_tab_aux ( v_tab_aux IN VARCHAR2
                           , p_cod_estab IN VARCHAR
                           , v_tab_aux_en IN VARCHAR2
                           , v_tab_aux_pe IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 10000 );
    BEGIN
        v_sql := ' INSERT INTO ' || v_tab_aux_pe || ' ';
        v_sql :=
               v_sql
            || 'SELECT  COD_EMPRESA, COD_ESTAB, DATA_FISCAL, MOVTO_E_S ,NORM_DEV ,IDENT_DOCTO , IDENT_FIS_JUR , NUM_DOCFIS , SERIE_DOCFIS , SUB_SERIE_DOCFIS , DATA_EMISSAO , NUM_AUTENTIC_NFE , CPF_CGC , COD_FIS_JUR, COD_ESTADO, VLR_TOT_NOTA , NUM_CONTROLE_DOCTO, COD_SISTEMA_ORIG , BUSINESS_UNIT, NF_BRL_ID FROM '
            || v_tab_aux
            || ' A  ';
        v_sql := v_sql || '  WHERE NOT EXISTS                    ';
        v_sql := v_sql || '(SELECT ''X''       ';
        v_sql := v_sql || '   FROM ' || v_tab_aux_en || ' C     ';
        v_sql := v_sql || '  WHERE  A.NUM_DOCFIS = C.NUM_DOCFIS     ';
        v_sql := v_sql || '        AND A.CPF_CGC = C.CPF_CGC   ';
        v_sql := v_sql || '        AND A.SERIE_DOCFIS = C.SERIE_DOCFIS  ';
        v_sql := v_sql || '        AND A.NUM_AUTENTIC_NFE = C.NUM_AUTENTIC_NFE  ';
        v_sql := v_sql || '        AND A.DATA_FISCAL <= C.DATA_FISCAL)  ';
        v_sql := v_sql || '        AND A.COD_ESTAB = ''' || p_cod_estab || '''  ';

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

            raise_application_error ( -20004
                                    , '!ERRO INSERT LOAD TAB AULIAR!' );
    END;

    ---------------------------------------------------------------------------------------------------------------------------------------------------------------
    PROCEDURE create_tab_final ( vp_mproc_id IN NUMBER
                               , v_tab_aux_fim   OUT VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 10000 );
    BEGIN
        v_tab_aux_fim := 'DPSP_FIM_' || vp_mproc_id;

        v_sql := 'CREATE TABLE ' || v_tab_aux_fim;
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || ' COD_ESTADO              VARCHAR2(2), ';
        v_sql := v_sql || ' COD_ESTAB               VARCHAR2(6), ';
        v_sql := v_sql || ' NUM_CONTROLE_DOCTO      VARCHAR2(14),';
        v_sql := v_sql || ' COD_SISTEMA_ORIG        VARCHAR2(4),  ';
        v_sql := v_sql || ' NUM_DOCFIS              VARCHAR2(14),';
        v_sql := v_sql || ' NUM_AUTENTIC_NFE        VARCHAR2(80),';
        v_sql := v_sql || ' SERIE_DOCFIS            VARCHAR2(3), ';
        v_sql := v_sql || ' DATA_EMISSAO            DATE,        ';
        v_sql := v_sql || ' DATA_FISCAL             DATE,        ';
        v_sql := v_sql || ' VLR_TOT_NOTA            NUMBER(17,2),';
        v_sql := v_sql || ' COD_ESTADO_ENT          VARCHAR2(6),';
        v_sql := v_sql || ' COD_FIS_JUR             VARCHAR2(14),';
        v_sql := v_sql || ' DATA_FISCAL_ENT         DATE,        ';
        v_sql := v_sql || ' NUM_CONTROLE_DOCTO_ENT  VARCHAR2(14),';
        v_sql := v_sql || ' NATUREZA_OP             VARCHAR2(50),';
        v_sql := v_sql || ' CHECK_ENTRADA           VARCHAR(3),';
        v_sql := v_sql || ' USUARIO                 VARCHAR2(30),';
        v_sql := v_sql || ' DATA_PROC               DATE,';
        v_sql := v_sql || ' PROC_ID                 VARCHAR2(20)';
        v_sql := v_sql || ' ) ' || v_tab_footer;

        EXECUTE IMMEDIATE v_sql;

        save_tmp_control ( vp_mproc_id
                         , v_tab_aux_fim );
    END;

    ---------------------------------------------------------------------------------------------------------------------------------------------------------------
    PROCEDURE load_tab_final ( vp_mproc_id IN NUMBER
                             , v_tab_aux_pe IN VARCHAR
                             , p_cod_estab IN VARCHAR
                             , v_data_inicial IN DATE
                             , v_data_final IN DATE
                             , v_tab_aux_fim IN VARCHAR )
    IS
        v_sql VARCHAR2 ( 10000 );

        --CURSOR AUXILIAR
        CURSOR c_data_saida ( p_i_data_inicial IN DATE
                            , p_i_data_final IN DATE )
        IS
            SELECT   b.data_fiscal AS data_normal
                FROM (SELECT p_i_data_inicial + ( ROWNUM - 1 ) AS data_fiscal
                        FROM all_objects
                       WHERE ROWNUM <= (p_i_data_final - p_i_data_inicial + 1)) b
            ORDER BY b.data_fiscal;
    --

    BEGIN
        FOR cd IN c_data_saida ( v_data_inicial
                               , v_data_final ) LOOP
            v_sql := ' INSERT INTO ' || v_tab_aux_fim || ' ';
            v_sql := v_sql || 'SELECT D.COD_ESTADO  ,               ';
            v_sql := v_sql || 'A.COD_ESTAB             ,            ';
            v_sql := v_sql || 'A.NUM_CONTROLE_DOCTO    ,            ';
            v_sql := v_sql || 'A.COD_SISTEMA_ORIG      ,            ';
            v_sql := v_sql || 'A.NUM_DOCFIS            ,            ';
            v_sql := v_sql || 'A.NUM_AUTENTIC_NFE      ,            ';
            v_sql := v_sql || 'A.SERIE_DOCFIS          ,            ';
            v_sql := v_sql || 'A.DATA_EMISSAO          ,            ';
            v_sql := v_sql || 'A.DATA_FISCAL           ,            ';
            v_sql := v_sql || 'A.VLR_TOT_NOTA          ,            ';
            v_sql := v_sql || 'A.COD_ESTADO COD_ESTADO_ENT  ,       ';
            v_sql := v_sql || 'A.COD_FIS_JUR           ,            ';
            v_sql := v_sql || 'B.ACCOUNTING_DT DATA_FISCAL_ENT       ,';
            v_sql := v_sql || 'B.NF_BRL_ID NUM_CONTROLE_DOCTO_ENT,  ';
            v_sql := v_sql || 'C.txn_nat_bbl NATUREZA_OP,  ';
            v_sql :=
                v_sql || '(CASE WHEN B.NF_BRL_ID <> '' '' THEN ''Sim'' else ''Não'' END) AS CHECK_ENTRADA   ,      ';
            v_sql := v_sql || ' ''' || musuario || ''' AS USUARIO,    ';
            v_sql := v_sql || 'SYSDATE AS DATA_PROC   , ';
            v_sql := v_sql || '''' || vp_mproc_id || ''' AS PROC_ID    ';
            v_sql :=
                   v_sql
                || 'FROM '
                || v_tab_aux_pe
                || ' A, MSAFI.PS_NF_HDR_BRL B , MSAFI.DSP_ESTABELECIMENTO D , msafi.ps_nf_hdr_bbl_fs C ';
            v_sql := v_sql || 'WHERE B.BUSINESS_UNIT(+) IN (''POCOM'',''POCDP'')  ';
            v_sql := v_sql || 'AND A.COD_ESTAB = ''' || p_cod_estab || ''' ';
            v_sql := v_sql || 'AND A.DATA_FISCAL = ''' || cd.data_normal || ''' ';
            v_sql := v_sql || 'AND A.NUM_AUTENTIC_NFE = B.NFE_VERIF_CODE_PBL(+) ';
            v_sql := v_sql || 'AND A.NUM_DOCFIS = B.NF_BRL(+)    ';
            v_sql := v_sql || 'AND A.COD_FIS_JUR = B.EF_LOC_BRL(+) ';
            v_sql := v_sql || 'AND D.COD_EMPRESA = A.COD_EMPRESA  ';
            v_sql := v_sql || 'AND D.COD_ESTAB = A.COD_ESTAB ';
            v_sql := v_sql || 'AND C.BUSINESS_UNIT(+) = A.BUSINESS_UNIT ';
            v_sql := v_sql || 'AND C.NF_BRL_ID(+) = A.NF_BRL_ID ';

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

                    raise_application_error ( -20004
                                            , '!ERRO INSERT LOAD TAB FINAL!' );
            END;
        END LOOP;

        loga ( 'TAB - FILIAL ' || p_cod_estab || '' );
    -----------------------------------------------------------------
    /*  DELETE MSAFI.DPSP_MSAF_CONCILIACAO_NF
    WHERE COD_ESTAB = P_COD_ESTAB
      AND DATA_FISCAL BETWEEN V_DATA_INICIAL AND V_DATA_FINAL;
    LOGA('TAB - FILIAL '|| P_COD_ESTAB ||' - DEL ' || SQL%ROWCOUNT);
    COMMIT;
    ---
    EXECUTE IMMEDIATE 'INSERT INTO MSAFI.DPSP_MSAF_CONCILIACAO_NF ' ||
                      ' SELECT DISTINCT * FROM ' || V_TAB_AUX_FIM || ' ';
    LOGA('TAB - FILIAL '|| P_COD_ESTAB ||' - FINAL ' || SQL%ROWCOUNT);
    COMMIT;
    ---
    DBMS_STATS.GATHER_TABLE_STATS('MSAFI', 'DPSP_MSAF_CONCILIACAO_NF');*/

    END;

    --------------------------------------------------------------------------------------------------------------------------------------------------------------
    PROCEDURE load_excel ( p_proc_instance IN VARCHAR
                         , p_uf IN VARCHAR
                         , vp_mproc_id IN NUMBER
                         , v_data_inicial IN DATE
                         , v_data_final IN DATE
                         , v_tab_aux_fim IN VARCHAR
                         , total_l IN VARCHAR
                         , p_cod_estab IN VARCHAR )
    IS
        v_sql VARCHAR2 ( 10000 );
        v_text01 VARCHAR2 ( 10000 );
        v_class VARCHAR2 ( 1 ) := 'a';
        c_conc SYS_REFCURSOR;

        TYPE cur_tab_conc IS RECORD
        (
            cod_estado VARCHAR2 ( 2 )
          , cod_estab VARCHAR2 ( 6 )
          , num_controle_docto VARCHAR2 ( 14 )
          , cod_sistema_orig VARCHAR2 ( 4 )
          , natureza_op VARCHAR2 ( 50 )
          , num_docfis VARCHAR2 ( 14 )
          , num_autentic_nfe VARCHAR2 ( 80 )
          , serie_docfis VARCHAR2 ( 3 )
          , data_emissao DATE
          , data_fiscal DATE
          , vlr_tot_nota NUMBER ( 17, 2 )
          , cod_estado_ent VARCHAR2 ( 6 )
          , cod_fis_jur VARCHAR2 ( 14 )
          , check_entrada VARCHAR2 ( 3 )
          , data_fiscal_ent DATE
          , num_controle_docto_ent VARCHAR2 ( 14 )
        );

        TYPE c_tab_conc IS TABLE OF cur_tab_conc;

        tab_e c_tab_conc;
    BEGIN
        v_sql := ' SELECT ';
        v_sql := v_sql || ' A.COD_ESTADO  ,    ';
        v_sql := v_sql || ' A.COD_ESTAB             ,  ';
        v_sql := v_sql || ' A.NUM_CONTROLE_DOCTO    ,  ';
        v_sql := v_sql || ' A.COD_SISTEMA_ORIG        ,  ';
        v_sql := v_sql || ' A.NATUREZA_OP           ,  ';
        v_sql := v_sql || ' A.NUM_DOCFIS            ,  ';
        v_sql := v_sql || ' A.NUM_AUTENTIC_NFE      ,  ';
        v_sql := v_sql || ' A.SERIE_DOCFIS          ,  ';
        v_sql := v_sql || ' A.DATA_EMISSAO          ,  ';
        v_sql := v_sql || ' A.DATA_FISCAL           ,  ';
        v_sql := v_sql || ' A.VLR_TOT_NOTA          ,  ';
        v_sql := v_sql || ' A.COD_ESTADO_ENT        ,  ';
        v_sql := v_sql || ' A.COD_FIS_JUR           ,  ';
        v_sql := v_sql || ' A.CHECK_ENTRADA         ,  ';
        v_sql := v_sql || ' A.DATA_FISCAL_ENT       ,  ';
        v_sql := v_sql || ' A.NUM_CONTROLE_DOCTO_ENT   ';
        v_sql := v_sql || ' FROM ' || v_tab_aux_fim || ' A  ';
        v_sql := v_sql || ' WHERE A.DATA_FISCAL BETWEEN ''' || v_data_inicial || ''' AND  ''' || v_data_final || ''' ';
        v_sql := v_sql || ' AND A.PROC_ID =  ''' || vp_mproc_id || ''' ';

        loga ( '>>> Inicio Conciliação ' || p_proc_instance
             , FALSE );

        IF p_uf = '%'
       AND NVL ( total_l, '' ) <> '1' THEN
            --(1)
            lib_proc.add_tipo ( vp_mproc_id
                              , 99
                              , mcod_empresa || '_REL_CONC_ENTRADAS_X_SAIDAS.XLS'
                              , 2 );
        END IF;

        --
        IF total_l = '1' THEN
            lib_proc.add_tipo ( vp_mproc_id
                              , 99
                              , mcod_empresa || '_REL_CONC_ENTRADAS_' || p_cod_estab || '_SAIDAS.XLS'
                              , 2 );
        END IF;

        --
        IF p_uf <> '%'
       AND total_l <> '1' THEN
            lib_proc.add_tipo ( vp_mproc_id
                              , 99
                              , mcod_empresa || '_REL_CONC_ENTRADAS_' || p_uf || '_SAIDAS.XLS'
                              , 2 );
        END IF; --(1)

        lib_proc.add ( dsp_planilha.header
                     , ptipo => 99 );
        lib_proc.add ( dsp_planilha.tabela_inicio
                     , ptipo => 99 );

        lib_proc.add ( dsp_planilha.linha ( p_conteudo =>    dsp_planilha.campo ( 'SAIDAS'
                                                                                , p_custom => 'COLSPAN=11' )
                                                          || --
                                                            dsp_planilha.campo (
                                                                                 'MASTERSAF - Estab sem o recebimento'
                                                                               , p_custom => 'COLSPAN=2 BGCOLOR=BLUE'
                                                             )
                                                          || --
                                                            dsp_planilha.campo (
                                                                                 'PeopleSoft - Entrada'
                                                                               , p_custom => 'COLSPAN=3 BGCOLOR=GREEN'
                                                             )
                                          , p_class => 'h' )
                     , ptipo => 99 );

        lib_proc.add ( dsp_planilha.linha ( p_conteudo =>    dsp_planilha.campo ( 'UF_ORIGEM' )
                                                          || --
                                                            dsp_planilha.campo ( 'COD_ESTAB_ORIGEM' )
                                                          || --
                                                            dsp_planilha.campo ( 'ID_SISTEMA_ORIGEM' )
                                                          || --
                                                            dsp_planilha.campo ( 'COD_SISTEMA_ORIGEM' )
                                                          || --
                                                            dsp_planilha.campo ( 'NATUREZA_OPERACAO' )
                                                          || --
                                                            dsp_planilha.campo ( 'NUM_NF' )
                                                          || --
                                                            dsp_planilha.campo ( 'CHAVE_DE_ACESSO' )
                                                          || --
                                                            dsp_planilha.campo ( 'SERIE' )
                                                          || --
                                                            dsp_planilha.campo ( 'DATA_EMISSAO_NF' )
                                                          || --
                                                            dsp_planilha.campo ( 'DATA_FISCAL' )
                                                          || --
                                                            dsp_planilha.campo ( 'VALOR_TOTAL_NF' )
                                                          || --
                                                            dsp_planilha.campo ( 'UF_DESTINO'
                                                                               , p_custom => 'BGCOLOR=BLUE' )
                                                          || --
                                                            dsp_planilha.campo ( 'COD_ESTAB_DESTINO'
                                                                               , p_custom => 'BGCOLOR=BLUE' )
                                                          || --
                                                            dsp_planilha.campo ( 'CHECK'
                                                                               , p_custom => 'BGCOLOR=GREEN' )
                                                          || --
                                                            dsp_planilha.campo ( 'DATA_FISCAL_ENT'
                                                                               , p_custom => 'BGCOLOR=GREEN' )
                                                          || --
                                                            dsp_planilha.campo ( 'ID_PEOPLE_ENTRADA'
                                                                               , p_custom => 'BGCOLOR=GREEN' ) --
                                          , p_class => 'h' )
                     , ptipo => 99 );

        BEGIN
            OPEN c_conc FOR v_sql;
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
                                        , '!ERRO SELECT CONCILIAÇÃO!' );
        END;

        LOOP
            FETCH c_conc
                BULK COLLECT INTO tab_e
                LIMIT 100;

            FOR i IN 1 .. tab_e.COUNT LOOP
                IF v_class = 'a' THEN
                    v_class := 'b';
                ELSE
                    v_class := 'a';
                END IF;

                v_text01 :=
                    dsp_planilha.linha (
                                         p_conteudo =>    dsp_planilha.campo ( tab_e ( i ).cod_estado )
                                                       || dsp_planilha.campo ( tab_e ( i ).cod_estab )
                                                       || dsp_planilha.campo (
                                                                               dsp_planilha.texto (
                                                                                                    tab_e ( i ).num_controle_docto
                                                                               )
                                                          )
                                                       || dsp_planilha.campo ( tab_e ( i ).cod_sistema_orig )
                                                       || dsp_planilha.campo ( tab_e ( i ).natureza_op )
                                                       || dsp_planilha.campo (
                                                                               dsp_planilha.texto (
                                                                                                    tab_e ( i ).num_docfis
                                                                               )
                                                          )
                                                       || dsp_planilha.campo (
                                                                               dsp_planilha.texto (
                                                                                                    tab_e ( i ).num_autentic_nfe
                                                                               )
                                                          )
                                                       || dsp_planilha.campo ( tab_e ( i ).serie_docfis )
                                                       || dsp_planilha.campo ( tab_e ( i ).data_emissao )
                                                       || dsp_planilha.campo ( tab_e ( i ).data_fiscal )
                                                       || dsp_planilha.campo ( tab_e ( i ).vlr_tot_nota )
                                                       || dsp_planilha.campo ( tab_e ( i ).cod_estado_ent )
                                                       || dsp_planilha.campo ( tab_e ( i ).cod_fis_jur )
                                                       || dsp_planilha.campo ( tab_e ( i ).check_entrada )
                                                       || dsp_planilha.campo ( tab_e ( i ).data_fiscal_ent )
                                                       || dsp_planilha.campo ( tab_e ( i ).num_controle_docto_ent )
                                       , p_class => v_class
                    );
                lib_proc.add ( v_text01
                             , ptipo => 99 );
            END LOOP;

            tab_e.delete;

            EXIT WHEN c_conc%NOTFOUND;
        END LOOP;

        COMMIT;

        CLOSE c_conc;

        lib_proc.add ( dsp_planilha.tabela_fim
                     , ptipo => 99 );
    END load_excel;

    --------------------------------------------------------------------------------------------------------------------------------------------------------------

    PROCEDURE drop_old_tmp
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

                loga ( temp_table.table_name || ' <'
                     , FALSE );
            EXCEPTION
                WHEN OTHERS THEN
                    loga ( temp_table.table_name || ' <'
                         , FALSE );
            END;

            DELETE msafi.dpsp_msaf_tmp_control
             WHERE proc_id = vp_mproc_id
               AND table_name = temp_table.table_name;

            COMMIT;
        END LOOP;

        --- checar TMPs de processos interrompidos e dropar
        drop_old_tmp;
    END;

    --------------------------------------------------------------------------------------------------------------------------------------------------------------

    FUNCTION executar ( p_data_ini DATE
                      , p_data_fim DATE
                      , p_data_par DATE
                      , p_uf VARCHAR2
                      , p_lojas lib_proc.vartab )
        RETURN INTEGER
    IS
        mproc_id INTEGER;
        i1 INTEGER;

        v_total_lojas INTEGER := 0;
        v_count_lojas INTEGER := 0;

        TYPE a_estabs_t IS TABLE OF VARCHAR2 ( 6 );

        a_estabs a_estabs_t := a_estabs_t ( );

        --Variaveis genericas
        p_proc_instance VARCHAR2 ( 30 );
        v_tab_aux VARCHAR2 ( 30 );
        v_tab_aux_en VARCHAR2 ( 30 );
        v_tab_aux_pe VARCHAR2 ( 30 );
        v_tab_aux_fim VARCHAR2 ( 30 );
        total_l VARCHAR2 ( 30 );
        loja_ex VARCHAR2 ( 6 );
        --

        ---

        ------------------------------------------------------------------------------------------------------------------------------------------------------
        --RANGE DE DATAS PARA BUSCAR VENDAS
        v_data_inicial DATE := p_data_ini; -- DATA INICIAL
        v_data_final DATE := p_data_fim; -- DATA FINAL
    ------------------------------------------------------------------------------------------------------------------------------------------------------


    BEGIN
        EXECUTE IMMEDIATE ( 'ALTER SESSION SET CURSOR_SHARING = FORCE' );

        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS='',.'' ';

        dbms_application_info.set_client_info ( v_count_lojas || '/' || v_total_lojas );

        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        musuario := lib_parametros.recuperar ( 'USUARIO' );

        mproc_id :=
            lib_proc.new ( $$plsql_unit
                         , 48
                         , 150 );
        lib_proc.add_tipo ( mproc_id
                          , 1
                          ,    TO_CHAR ( SYSDATE
                                       , 'YYYYMMDDHH24MISS' )
                            || '_Saida_x_Entrada'
                          , 1 );

        COMMIT;

        lib_proc.add_header ( 'Executar processamento do Conciliação de Saídas x Entradas'
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

        loga ( '>>> Inicio do processamento...' || p_proc_instance
             , FALSE );
        loga ( '>> DT INICIAL: ' || v_data_inicial
             , FALSE );
        loga ( '>> DT FINAL: ' || v_data_final
             , FALSE );

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


        v_total_lojas := p_lojas.COUNT;
        v_count_lojas := 0;
        --GERAR CHAVE PROC_ID
        --   SELECT ROUND(DBMS_RANDOM.VALUE(10000000000000,999999999999999))
        --   INTO VP_PROC_INSTANCE
        --   FROM DUAL;

        loga ( '>> Create table '
             , FALSE );
        create_saida ( mproc_id
                     , v_tab_aux );
        create_entrada ( mproc_id
                       , v_tab_aux_en );
        create_tab_aux ( mproc_id
                       , v_tab_aux_pe );
        create_tab_final ( mproc_id
                         , v_tab_aux_fim );

        ---------------------
        --EXECUTAR UM P_COD_ESTAB POR VEZ
        FOR est IN a_estabs.FIRST .. a_estabs.LAST --(1)
                                                  LOOP
            dbms_application_info.set_module ( $$plsql_unit
                                             , a_estabs ( est ) );

            v_count_lojas := v_count_lojas + 1;
            dbms_application_info.set_client_info ( v_count_lojas || '/' || v_total_lojas );



            loga ( '>> Estab: ' || a_estabs ( est )
                 , FALSE );

            loga ( '>> Saida '
                 , FALSE );

            load_saidas ( v_tab_aux
                        , v_data_inicial
                        , v_data_final
                        , a_estabs ( est ) );
            --
            loga ( '>> Entrada '
                 , FALSE );
            load_entrada ( v_tab_aux_en
                         , v_tab_aux
                         , v_data_inicial
                         , p_data_par
                         , a_estabs ( est ) );
            --
            loga ( '>> Entrada Inter '
                 , FALSE );


            load_entrada_inter ( v_tab_aux_en
                               , v_data_inicial
                               , p_data_par );
            --
            loga ( '>> Auxiliar '
                 , FALSE );
            load_tab_aux ( v_tab_aux
                         , a_estabs ( est )
                         , v_tab_aux_en
                         , v_tab_aux_pe );
            --
            loga ( '>> Final '
                 , FALSE );
            load_tab_final ( mproc_id
                           , v_tab_aux_pe
                           , a_estabs ( est )
                           , v_data_inicial
                           , v_data_final
                           , v_tab_aux_fim );

            total_l := ( a_estabs.COUNT );

            loja_ex := a_estabs ( est );
        --LOGA(TOTAL_L);

        END LOOP; --(1)

        loga ( '>> Qtde Lojas ' || total_l
             , FALSE );
        loga ( '>> Excel '
             , FALSE );

        dbms_application_info.set_module ( $$plsql_unit
                                         , 'LOAD_EXCEL' );

        load_excel ( p_proc_instance
                   , p_uf
                   , mproc_id
                   , v_data_inicial
                   , v_data_final
                   , v_tab_aux_fim
                   , total_l
                   , loja_ex );

        delete_temp_tbl ( mproc_id );
        --INSERIR DADOS-FIM-------------------------------------------------------------------------------------------
        --DISPONIBILIZAR PERIODO PROCESSADO PARA TRAVA DE REPROCESSAMENTO

        loga ( 'FIM DO PROCESSAMENTO, STATUS FINAL: [SUCESSO]'
             , FALSE );
        lib_proc.add ( 'FIM DO PROCESSAMENTO, STATUS FINAL: [SUCESSO]' );

        dbms_application_info.set_module ( $$plsql_unit
                                         , 'FIM' );

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
END dpsp_conc_relfin2730_cproc;
/
SHOW ERRORS;
