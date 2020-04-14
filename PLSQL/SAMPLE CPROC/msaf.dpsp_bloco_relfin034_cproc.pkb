Prompt Package Body DPSP_BLOCO_RELFIN034_CPROC;
--
-- DPSP_BLOCO_RELFIN034_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_bloco_relfin034_cproc
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

        lib_proc.add_param (
                             pparam => pstr
                           , ptitulo => 'UF'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'COMBOBOX'
                           , pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => '####################'
                           , pvalores =>    'SELECT COD_ESTADO, COD_ESTADO || '' - '' || DESCRICAO TXT FROM ESTADO '
                                         || ' WHERE COD_ESTADO IN (SELECT COD_ESTADO FROM DSP_ESTABELECIMENTO_V) '
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
                             || ''' and cod_estado like :3  ORDER BY Tipo, 2'
        );

        RETURN pstr;
    END; --FUNCTION PARAMETROS RETURN VARCHAR2 IS

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Processar Relatório Bloco 1600';
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
        RETURN 'Processar Relatório de apoio Bloco SPED 1600 Cartão de Crédito/Débito';
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
        --MSAFI.DSP_CONTROL.WRITELOG('BLOCO',P_I_TEXTO);
        COMMIT;
    ---> Para acompanhar processamento usar SELECT abaixo
    --SELECT * FROM DSP_LOG
    --WHERE LOG_TYPE = 'CARTOES'
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

    ---------------------------------------------------------------------------------------------------------------------------------------------------------

    PROCEDURE load_bloco ( p_proc_instance IN VARCHAR
                         , v_data_inicial IN DATE
                         , v_data_final IN DATE
                         , p_cod_estab IN VARCHAR
                         , vp_mproc_id IN NUMBER )
    IS
        v_sql VARCHAR2 ( 5000 );
        v_text01 VARCHAR2 ( 4000 );
        v_class VARCHAR2 ( 1 ) := 'a';
        c_bloco SYS_REFCURSOR;
        tipo INTEGER;

        TYPE cur_tab_bloco IS RECORD
        (
            cod_empresa VARCHAR2 ( 3 )
          , cod_estab VARCHAR2 ( 6 )
          , razao_social VARCHAR2 ( 70 )
          , data_movto VARCHAR2 ( 8 )
          , ind_fis_jur VARCHAR2 ( 1 )
          , cod_fis_jur VARCHAR2 ( 148 )
          , vlr_tot_cred VARCHAR2 ( 17 )
          , vlr_tot_deb VARCHAR2 ( 17 )
          , vlr_fat_icms NUMBER ( 8 )
          , vlr_est_icms NUMBER ( 8 )
          , vlr_fat_iss NUMBER ( 8 )
          , vlr_est_iss NUMBER ( 8 )
        );

        TYPE c_tab_bloco IS TABLE OF cur_tab_bloco;

        tab_e c_tab_bloco;
    BEGIN
        v_sql := 'SELECT COD_EMPRESA   ,   ';
        v_sql := v_sql || ' COD_ESTAB   ,    ';
        v_sql := v_sql || ' D.RAZAO_SOCIAL ,';
        v_sql := v_sql || '   TO_CHAR(DATA_TRANSACAO,''YYYYMMDD'') AS DATA_MOVTO  ,      ';
        v_sql := v_sql || '   SUBSTR(VALOR,1,1) AS IND_FIS_JUR ,    ';
        v_sql := v_sql || '   SUBSTR(VALOR,3) AS COD_FIS_JUR,  ';
        v_sql := v_sql || '  VLR_TOT_CRED,       ';
        v_sql := v_sql || '  VLR_TOT_DEB ,  ';
        v_sql := v_sql || '  0 VLR_FAT_ICMS,   ';
        v_sql := v_sql || '  0 VLR_EST_ICMS, ';
        v_sql := v_sql || '  0 VLR_FAT_ISS ,  ';
        v_sql := v_sql || '  0 VLR_EST_ISS FROM (  ';
        v_sql := v_sql || 'SELECT A.COD_EMPRESA,  ';
        v_sql := v_sql || 'A.COD_ESTAB,   ';
        v_sql := v_sql || 'A.DATA_TRANSACAO,   ';
        v_sql := v_sql || 'B.VALOR,   ';
        v_sql := v_sql || '(CASE WHEN A.CODIGO_FORMA = ''11'' THEN A.VALOR_TOTAL ELSE 0 END) AS VLR_TOT_CRED,  ';
        v_sql := v_sql || '(CASE WHEN A.CODIGO_FORMA = ''9'' THEN  A.VALOR_TOTAL ELSE 0 END) AS VLR_TOT_DEB   ';
        v_sql := v_sql || 'FROM MSAFI.DPSP_MSAF_PAGTO_CARTOES A, FPAR_PARAM_DET b, FPAR_PARAMETROS C      ';
        v_sql := v_sql || 'WHERE B.descricao = RTRIM(a.nome_van)   ';
        v_sql := v_sql || 'AND A.COD_ESTAB =  ''' || p_cod_estab || '''     ';
        v_sql := v_sql || 'AND C.NOME_FRAMEWORK = ''DPSP_CARTOES_IDENT_CPAR''   ';
        v_sql := v_sql || 'AND C.ID_PARAMETROS = B.ID_PARAMETRO  ';
        v_sql :=
               v_sql
            || 'AND A.DATA_TRANSACAO BETWEEN '''
            || TO_CHAR ( v_data_inicial
                       , 'DDMMYYYY' )
            || ''' AND '''
            || TO_CHAR ( v_data_final
                       , 'DDMMYYYY' )
            || ''' ) A , X04_PESSOA_FIS_JUR D ';
        v_sql := v_sql || 'WHERE SUBSTR (A.VALOR, 3) = D.COD_FIS_JUR AND SUBSTR (A.VALOR, 1, 1)  = D.IND_FIS_JUR ';
        v_sql :=
               v_sql
            || '  AND D.VALID_FIS_JUR = (SELECT MAX(D1.VALID_FIS_JUR) FROM X04_PESSOA_FIS_JUR D1 WHERE D1.IND_FIS_JUR = IND_FIS_JUR    ';
        v_sql := v_sql || '  AND D1.COD_FIS_JUR = D.COD_FIS_JUR)    ';
        v_sql := v_sql || '  ORDER BY 1,2,3,4    ';

        loga ( '>>> Inicio Relatório Bloco 1600 ' || p_proc_instance
             , FALSE );

        -- INICIO DO AJUSTE 10/04/2019 - SUSTENTAÇÃO
        -- ERRO QUANDO O ESTABELECIMENTO CONTÉM DS OU ST POR EXEMPLO
        /*SELECT REPLACE(REPLACE(P_COD_ESTAB,'DSP',''),'DP','')
        INTO TIPO
        FROM DUAL;*/
        -- NOVA CONVERSÃO
        SELECT TRIM ( TRANSLATE ( p_cod_estab
                                , TRANSLATE ( p_cod_estab
                                            , '1234567890'
                                            , ' ' )
                                , ' ' ) )
                   so_numeros
          INTO tipo
          FROM DUAL;

        -- FM DO AJUSTE 10/04/2019 - SUSTENTAÇÃO

        loga ( tipo );

        lib_proc.add_tipo ( vp_mproc_id
                          , tipo
                          , mcod_empresa || '_' || p_cod_estab || '_REL_BLOCO1600.XLS'
                          , 2 );

        lib_proc.add ( dsp_planilha.header
                     , ptipo => tipo );
        lib_proc.add ( dsp_planilha.tabela_inicio
                     , ptipo => tipo );
        lib_proc.add ( dsp_planilha.linha (
                                            p_conteudo =>    dsp_planilha.campo ( 'COD_EMPRESA' )
                                                          || -- , COD_EMPRESA
                                                            dsp_planilha.campo ( 'COD_ESTAB' )
                                                          || -- , COD_ESTAB
                                                            dsp_planilha.campo ( 'RAZAO_SOCIAL' )
                                                          || -- , RAZAO_SOCIAL
                                                            dsp_planilha.campo ( 'DATA_MOVTO' )
                                                          || -- , DATA_MOVTO
                                                            dsp_planilha.campo ( 'IND_FIS_JUR' )
                                                          || -- , IND_FIS_JUR
                                                            dsp_planilha.campo ( 'COD_FIS_JUR' )
                                                          || -- , COD_FIS_JUR
                                                            dsp_planilha.campo ( 'VLR_TOT_CRED' )
                                                          || -- , VLR_TOT_CRED
                                                            dsp_planilha.campo ( 'VLR_TOT_DEB' )
                                                          || -- , VLR_TOT_DEB
                                                            dsp_planilha.campo ( 'VLR_FAT_ICMS' )
                                                          || -- , VLR_FAT_ICMS
                                                            dsp_planilha.campo ( 'VLR_EST_ICMS' )
                                                          || -- , VLR_EST_ICMS
                                                            dsp_planilha.campo ( 'VLR_FAT_ISS' )
                                                          || -- , VLR_FAT_ISS
                                                            dsp_planilha.campo ( 'VLR_EST_ISS' ) -- , VLR_EST_ISS
                                          , p_class => 'h'
                       )
                     , ptipo => tipo );


        BEGIN
            OPEN c_bloco FOR v_sql;
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
                                        , '!ERRO SELECT BLOCO!' );
        END;

        LOOP
            FETCH c_bloco
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
                                         p_conteudo =>    dsp_planilha.campo ( tab_e ( i ).cod_empresa )
                                                       || -- , COD_EMPRESA
                                                         dsp_planilha.campo ( tab_e ( i ).cod_estab )
                                                       || -- , COD_ESTAB
                                                         dsp_planilha.campo (
                                                                              dsp_planilha.texto (
                                                                                                   tab_e ( i ).razao_social
                                                                              )
                                                          )
                                                       || --RAZAO_SOCIAL
                                                         dsp_planilha.campo ( tab_e ( i ).data_movto )
                                                       || -- , DATA_MOVTO
                                                         dsp_planilha.campo ( tab_e ( i ).ind_fis_jur )
                                                       || -- , IND_FIS_JUR
                                                         dsp_planilha.campo ( tab_e ( i ).cod_fis_jur )
                                                       || -- , COD_FIS_JUR
                                                         dsp_planilha.campo ( tab_e ( i ).vlr_tot_cred )
                                                       || -- , VLR_TOT_CRED
                                                         dsp_planilha.campo ( tab_e ( i ).vlr_tot_deb )
                                                       || -- , VLR_TOT_DEB
                                                         dsp_planilha.campo ( tab_e ( i ).vlr_fat_icms )
                                                       || -- , VLR_FAT_ICMS
                                                         dsp_planilha.campo ( tab_e ( i ).vlr_est_icms )
                                                       || -- , VLR_EST_ICMS
                                                         dsp_planilha.campo ( tab_e ( i ).vlr_fat_iss )
                                                       || -- , VLR_FAT_ISS
                                                         dsp_planilha.campo ( tab_e ( i ).vlr_est_iss ) -- , VLR_EST_ISS
                                       , p_class => v_class
                    );
                lib_proc.add ( v_text01
                             , ptipo => tipo );
            END LOOP;

            tab_e.delete;

            EXIT WHEN c_bloco%NOTFOUND;
        END LOOP;

        COMMIT;

        CLOSE c_bloco;

        lib_proc.add ( dsp_planilha.tabela_fim
                     , ptipo => tipo );
    END load_bloco;

    PROCEDURE load_sintetico ( p_proc_instance IN VARCHAR
                             , v_data_inicial IN DATE
                             , v_data_final IN DATE
                             , p_cod_estab IN VARCHAR
                             , vp_mproc_id IN NUMBER )
    IS
        v_sql VARCHAR2 ( 4000 );
        v_text01 VARCHAR2 ( 3000 );
        v_class VARCHAR2 ( 1 ) := 'a';
        v_vlr_tot_cred_2 VARCHAR2 ( 17 ) := '';
        v_vlr_tot_deb_2 VARCHAR2 ( 17 ) := '';
        c_sintetic SYS_REFCURSOR;
        tipo_0 INTEGER;

        TYPE cur_tab_sintetic IS RECORD
        (
            cod_empresa VARCHAR2 ( 3 )
          , cod_estab VARCHAR2 ( 6 )
          , razao_social VARCHAR2 ( 70 )
          , data_movto VARCHAR2 ( 8 )
          , ind_fis_jur VARCHAR2 ( 1 )
          , cod_fis_jur VARCHAR2 ( 148 )
          , vlr_tot_cred VARCHAR2 ( 17 )
          , vlr_tot_deb VARCHAR2 ( 17 )
          , vlr_tot_cred_1 VARCHAR2 ( 17 )
          , vlr_tot_deb_1 VARCHAR2 ( 17 )
          , vlr_tot_cred_2 VARCHAR2 ( 17 )
          , vlr_tot_deb_2 VARCHAR2 ( 17 )
        );


        TYPE c_tab_sintetic IS TABLE OF cur_tab_sintetic;

        tab_e c_tab_sintetic;
    BEGIN
        v_sql := 'SELECT COD_EMPRESA,     ';
        v_sql := v_sql || '       COD_ESTAB,   ';
        v_sql := v_sql || '       D.RAZAO_SOCIAL,    ';
        v_sql := v_sql || '       TO_CHAR (DATA_TRANSACAO, ''YYYYMMDD'')   AS DATA_MOVTO,  ';
        v_sql := v_sql || '       SUBSTR (VALOR, 1, 1)  AS IND_FIS_JUR, ';
        v_sql := v_sql || '       SUBSTR (VALOR, 3)   AS COD_FIS_JUR,  ';
        v_sql := v_sql || '       VLR_TOT_CRED AS  VLR_TOT_CRED, ';
        v_sql :=
               v_sql
            || '       VLR_TOT_DEB AS  VLR_TOT_DEB, VLR_TOT_CRED_1, VLR_TOT_DEB_1 , '' '' AS VLR_TOT_CRED_2, '' '' AS VLR_TOT_DEB_2   ';
        v_sql := v_sql || '  FROM (SELECT A.COD_EMPRESA,   ';
        v_sql := v_sql || '               A.COD_ESTAB,    ';
        v_sql := v_sql || '               A.DATA_TRANSACAO, ';
        v_sql := v_sql || '               B.VALOR,       ';
        v_sql := v_sql || '               SUM(CASE WHEN A.CODIGO_FORMA = ''11'' THEN A.VALOR_TOTAL ELSE 0 END)       ';
        v_sql := v_sql || '                   AS VLR_TOT_CRED_1,                                                  ';
        v_sql := v_sql || '               SUM(CASE WHEN A.CODIGO_FORMA = ''9'' THEN A.VALOR_TOTAL ELSE 0 END)  ';
        v_sql := v_sql || '                   AS VLR_TOT_DEB_1  ';
        v_sql := v_sql || '          FROM MSAFI.DPSP_MSAF_PAGTO_CARTOES  A,  ';
        v_sql := v_sql || '               FPAR_PARAM_DET                 b,  ';
        v_sql := v_sql || '               FPAR_PARAMETROS                C   ';
        v_sql := v_sql || '         WHERE B.descricao = RTRIM (a.nome_van)    ';
        v_sql := v_sql || '               AND A.COD_ESTAB = ''' || p_cod_estab || ''' ';
        v_sql := v_sql || '               AND C.NOME_FRAMEWORK = ''DPSP_CARTOES_IDENT_CPAR'' ';
        v_sql := v_sql || '               AND C.ID_PARAMETROS = B.ID_PARAMETRO      ';
        v_sql :=
               v_sql
            || '               AND A.DATA_TRANSACAO BETWEEN '''
            || TO_CHAR ( v_data_inicial
                       , 'DDMMYYYY' )
            || ''' AND '''
            || TO_CHAR ( v_data_final
                       , 'DDMMYYYY' )
            || '''  ';
        v_sql := v_sql || '               GROUP BY A.COD_EMPRESA,	';
        v_sql := v_sql || '               A.COD_ESTAB,  ';
        v_sql := v_sql || '               A.DATA_TRANSACAO, ';
        v_sql := v_sql || '               B.VALOR) A , X04_PESSOA_FIS_JUR D , ';
        v_sql :=
               v_sql
            || '               (SELECT DATA_MOVTO, '''
            || p_cod_estab
            || ''',  SUBSTR (VALOR, 1, 1)  AS IND_FIS_JUR,    ';
        v_sql := v_sql || '       SUBSTR (VALOR, 3)  AS COD_FIS_JUR, VLR_TOT_CRED, VLR_TOT_DEB                       ';
        v_sql := v_sql || 'FROM (SELECT  TO_DATE(CT.DATA_TRANSACAO,''YYYYMMDD'') AS DATA_MOVTO,   ';
        v_sql := v_sql || 'CF.CODIGO_LOJA, VALOR,                                                 ';
        v_sql := v_sql || 'SUM(CASE WHEN CC.CODIGO_FORMA = ''11'' THEN CT.VALOR_TOTAL ELSE 0 END) ';
        v_sql := v_sql || '                   AS VLR_TOT_CRED,        ';
        v_sql := v_sql || 'SUM(CASE WHEN CC.CODIGO_FORMA = ''9'' THEN CT.VALOR_TOTAL ELSE 0 END) ';
        v_sql := v_sql || '                   AS VLR_TOT_DEB    ';
        v_sql := v_sql || 'FROM MSAFI.P2K_CAB_TRANSACAO CF, ';
        v_sql := v_sql || '     MSAFI.P2K_RECB_CARTAO   CT, ';
        v_sql := v_sql || '     MSAFI.P2K_RECB_TRANSACAO CC,                ';
        v_sql := v_sql || '               FPAR_PARAM_DET       b, ';
        v_sql := v_sql || '               FPAR_PARAMETROS    C  ';
        v_sql := v_sql || 'WHERE B.descricao = RTRIM (nome_van)             ';
        v_sql := v_sql || '               AND C.NOME_FRAMEWORK = ''DPSP_CARTOES_IDENT_CPAR'' ';
        v_sql := v_sql || '               AND C.ID_PARAMETROS = B.ID_PARAMETRO               ';
        v_sql := v_sql || 'AND CF.CODIGO_LOJA = CT.CODIGO_LOJA   ';
        v_sql := v_sql || '  AND CF.DATA_TRANSACAO    = CT.DATA_TRANSACAO        ';
        v_sql := v_sql || '  AND CF.NUMERO_COMPONENTE = CT.NUMERO_COMPONENTE     ';
        v_sql := v_sql || '  AND CF.NSU_TRANSACAO     = CT.NSU_TRANSACAO         ';
        v_sql := v_sql || '  AND CC.CODIGO_LOJA       = CT.CODIGO_LOJA           ';
        v_sql := v_sql || '  AND CC.DATA_TRANSACAO    = CT.DATA_TRANSACAO        ';
        v_sql := v_sql || '  AND CC.NUMERO_COMPONENTE = CT.NUMERO_COMPONENTE     ';
        v_sql := v_sql || '  AND CC.NSU_TRANSACAO     = CT.NSU_TRANSACAO         ';
        v_sql := v_sql || '  AND CC.NUM_SEQ_FORMA     = CT.NUM_SEQ_FORMA         ';
        v_sql :=
               v_sql
            || '  AND CF.CODIGO_LOJA       = TO_NUMBER(REGEXP_REPLACE('''
            || p_cod_estab
            || ''',''A|B|C|D|E|F|G|H|I|J|K|L|M|N|O|P|Q|R|S|T|U|V|W|X|Y|Z'',''''))     ';
        v_sql :=
               v_sql
            || '  AND CT.DATA_TRANSACAO    BETWEEN '''
            || TO_CHAR ( v_data_inicial
                       , 'YYYYMMDD' )
            || ''' AND '''
            || TO_CHAR ( v_data_final
                       , 'YYYYMMDD' )
            || '''    ';
        v_sql := v_sql || '  GROUP BY TO_DATE(CT.DATA_TRANSACAO,''YYYYMMDD''),    ';
        v_sql := v_sql || 'CF.CODIGO_LOJA, VALOR)) DH       ';
        v_sql :=
               v_sql
            || '               WHERE SUBSTR (A.VALOR, 3) = D.COD_FIS_JUR AND SUBSTR (A.VALOR, 1, 1)  = D.IND_FIS_JUR AND DH.DATA_MOVTO = DATA_TRANSACAO    ';
        v_sql :=
               v_sql
            || '               AND DH.IND_FIS_JUR = SUBSTR (A.VALOR, 1, 1) AND DH.COD_FIS_JUR = SUBSTR (A.VALOR, 3) AND COD_ESTAB = '''
            || p_cod_estab
            || '''    ';
        v_sql :=
               v_sql
            || '               AND D.VALID_FIS_JUR = (SELECT MAX(D1.VALID_FIS_JUR) FROM X04_PESSOA_FIS_JUR D1 WHERE D1.IND_FIS_JUR = IND_FIS_JUR    ';
        v_sql := v_sql || '                 AND D1.COD_FIS_JUR = D.COD_FIS_JUR)    ';
        v_sql := v_sql || '                ORDER BY 1,2,3,4    ';

        --V_SQL := V_SQL || '               AND D.VALID_FIS_JUR = (SELECT MAX(D1.VALID_FIS_JUR) FROM X04_PESSOA_FIS_JUR D1 WHERE D1.IDENT_FIS_JUR = IDENT_FIS_JUR    ';
        --V_SQL := V_SQL || '               AND D1.GRUPO_FIS_JUR = D.GRUPO_FIS_JUR AND D1.IND_FIS_JUR = D.IND_FIS_JUR AND D1.COD_FIS_JUR = D.COD_FIS_JUR)    ';


        loga ( '>>> Inicio Sintetico' || p_proc_instance
             , FALSE );


        -- INICIO DO AJUSTE 10/04/2019 - SUSTENTAÇÃO
        -- ERRO QUANDO O ESTABELECIMENTO CONTÉM DS OU ST POR EXEMPLO
        -- NOVA CONVERSÃO
        -- SELECT REPLACE(REPLACE(P_COD_ESTAB,'DSP',''),'DP','') + 1000
        -- INTO TIPO_0
        -- FROM DUAL;

        SELECT   TRIM ( TRANSLATE ( p_cod_estab
                                  , TRANSLATE ( p_cod_estab
                                              , '1234567890'
                                              , ' ' )
                                  , ' ' ) )
               + 1000
                   so_numeros
          INTO tipo_0
          FROM DUAL;

        -- FM DO AJUSTE 10/04/2019 - SUSTENTAÇÃO

        loga ( tipo_0 );


        lib_proc.add_tipo ( vp_mproc_id
                          , tipo_0
                          , mcod_empresa || '_' || p_cod_estab || '_REL_SINTETICO_BLOCO1600.XLS'
                          , 2 );

        lib_proc.add ( dsp_planilha.header
                     , ptipo => tipo_0 );
        lib_proc.add ( dsp_planilha.tabela_inicio
                     , ptipo => tipo_0 );

        lib_proc.add ( dsp_planilha.linha (
                                            p_conteudo =>    dsp_planilha.campo ( 'COD_EMPRESA' )
                                                          || -- , COD_EMPRESA
                                                            dsp_planilha.campo ( 'COD_ESTAB' )
                                                          || -- , COD_ESTAB
                                                            dsp_planilha.campo ( 'RAZAO_SOCIAL' )
                                                          || -- , RAZAO_SOCIAL
                                                            dsp_planilha.campo ( 'DATA_MOVTO' )
                                                          || -- , DATA_MOVTO
                                                            dsp_planilha.campo ( 'IND_FIS_JUR' )
                                                          || -- , IND_FIS_JUR
                                                            dsp_planilha.campo ( 'COD_FIS_JUR' )
                                                          || -- , COD_FIS_JUR
                                                            dsp_planilha.campo ( 'VLR_CREDITO_MSAF' )
                                                          || -- , VLR_TOT_DEB
                                                            dsp_planilha.campo ( 'VLR_DEBITO_MSAF' )
                                                          || -- , VLR_TOT_CRED
                                                            dsp_planilha.campo ( 'VLR_CREDITO_HUB' )
                                                          || -- , VLR_TOT_DEB_1
                                                            dsp_planilha.campo ( 'VLR_DEBITO_HUB' )
                                                          || -- , VLR_TOT_CRED_1
                                                            dsp_planilha.campo ( 'CHECK_DEBITO' )
                                                          || -- , VLR_TOT_CRED_2
                                                            dsp_planilha.campo ( 'CHECK_CREDITO' ) -- , VLR_TOT_DEB_2
                                          , p_class => 'h'
                       )
                     , ptipo => tipo_0 );

        BEGIN
            OPEN c_sintetic FOR v_sql;
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
                              , 4096 )
                     , FALSE );
                raise_application_error ( -20007
                                        , '!ERRO SELECT SINTETICO!' );
        END;

        LOOP
            FETCH c_sintetic
                BULK COLLECT INTO tab_e
                LIMIT 100;

            FOR i IN 1 .. tab_e.COUNT LOOP
                IF v_class = 'a' THEN
                    v_class := 'b';
                ELSE
                    v_class := 'a';
                END IF;

                v_vlr_tot_cred_2 := ( tab_e ( i ).vlr_tot_cred - tab_e ( i ).vlr_tot_cred_1 );
                v_vlr_tot_deb_2 := ( tab_e ( i ).vlr_tot_deb - tab_e ( i ).vlr_tot_deb_1 );

                v_text01 :=
                    dsp_planilha.linha (
                                         p_conteudo =>    dsp_planilha.campo ( tab_e ( i ).cod_empresa )
                                                       || -- , COD_EMPRESA
                                                         dsp_planilha.campo ( tab_e ( i ).cod_estab )
                                                       || -- , COD_ESTAB
                                                         dsp_planilha.campo (
                                                                              dsp_planilha.texto (
                                                                                                   tab_e ( i ).razao_social
                                                                              )
                                                          )
                                                       || --RAZAO_SOCIAL
                                                         dsp_planilha.campo ( tab_e ( i ).data_movto )
                                                       || -- , DATA_MOVTO
                                                         dsp_planilha.campo ( tab_e ( i ).ind_fis_jur )
                                                       || -- , IND_FIS_JUR
                                                         dsp_planilha.campo ( tab_e ( i ).cod_fis_jur )
                                                       || -- , COD_FIS_JUR
                                                         dsp_planilha.campo ( tab_e ( i ).vlr_tot_cred )
                                                       || -- , VLR_TOT_CRED
                                                         dsp_planilha.campo ( tab_e ( i ).vlr_tot_deb )
                                                       || -- , VLR_TOT_DEB
                                                         dsp_planilha.campo ( tab_e ( i ).vlr_tot_cred_1 )
                                                       || -- , VLR_FAT_ICMS
                                                         dsp_planilha.campo ( tab_e ( i ).vlr_tot_deb_1 )
                                                       || -- , VLR_EST_ICMS
                                                         dsp_planilha.campo ( v_vlr_tot_cred_2 )
                                                       || -- , VLR_FAT_ISS
                                                         dsp_planilha.campo ( v_vlr_tot_deb_2 ) -- , VLR_EST_ISS
                                       , p_class => v_class
                    );

                lib_proc.add ( v_text01
                             , ptipo => tipo_0 );
            END LOOP;

            tab_e.delete;

            EXIT WHEN c_sintetic%NOTFOUND;
        END LOOP;

        COMMIT;

        CLOSE c_sintetic;

        lib_proc.add ( dsp_planilha.tabela_fim
                     , ptipo => tipo_0 );
    END load_sintetico;

    ---------------------------------------------------------------------------------------------------------------------------------------------------------

    FUNCTION executar ( p_data_ini DATE
                      , p_data_fim DATE
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

        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        musuario := lib_parametros.recuperar ( 'USUARIO' );

        mproc_id :=
            lib_proc.new ( 'DPSP_BLOCO_RELFIN034_CPROC'
                         , 48
                         , 150 );
        lib_proc.add_tipo ( mproc_id
                          , 1
                          ,    TO_CHAR ( SYSDATE
                                       , 'YYYYMMDDHH24MISS' )
                            || '_BLOCO_1600'
                          , 1 );

        --MARCAR INCIO DA EXECUCAO
        v_data_hora_ini :=
            TO_CHAR ( SYSDATE
                    , 'DD/MM/YYYY HH24:MI.SS' );

        lib_proc.add_header ( 'Executar processamento do bloco 1600'
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

        IF msafi.get_trava_info ( 'BLOCO'
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
                         WHERE cod_empresa = mcod_empresa
                           AND tipo = 'L'
                           AND cod_estado = 'SP' ) LOOP
                a_estabs.EXTEND ( );
                a_estabs ( a_estabs.LAST ) := c1.cod_estab;
            END LOOP;
        END IF;

        --GERAR CHAVE PROC_ID
        SELECT ROUND ( dbms_random.VALUE ( 10000000000000
                                         , 999999999999999 ) )
          INTO vp_proc_instance
          FROM DUAL;

        ---------------------
        --EXECUTAR UM P_COD_ESTAB POR VEZ
        FOR est IN a_estabs.FIRST .. a_estabs.COUNT --(1)
                                                   LOOP
            loga ( '>> CDs: ' || a_estabs ( est ) || ' PROC INST: ' || vp_proc_instance
                 , FALSE );

            load_bloco ( p_proc_instance
                       , v_data_inicial
                       , v_data_final
                       , a_estabs ( est )
                       , mproc_id );
            load_sintetico ( p_proc_instance
                           , v_data_inicial
                           , v_data_final
                           , a_estabs ( est )
                           , mproc_id );
        END LOOP; --(1)

        loga ( 'RESULTADO EXCEL - FIM' );
        --INSERIR DADOS-FIM-------------------------------------------------------------------------------------------
        --DISPONIBILIZAR PERIODO PROCESSADO PARA TRAVA DE REPROCESSAMENT

        loga ( 'FIM DO PROCESSAMENTO, STATUS FINAL: [SUCESSO]'
             , FALSE );
        lib_proc.add ( 'FIM DO PROCESSAMENTO, STATUS FINAL: [SUCESSO]' );


        lib_proc.close ( );

        COMMIT;
        RETURN mproc_id;
    EXCEPTION
        WHEN OTHERS THEN
            --MSAFI.DSP_CONTROL.LOG_CHECKPOINT(SQLERRM,'Erro não tratado, executador de interfaces');
            --MSAFI.DSP_CONTROL.UPDATEPROCESS(4);
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
END dpsp_bloco_relfin034_cproc;
/
SHOW ERRORS;
