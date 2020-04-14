Prompt Package Body DPSP_BLOCO_FIN034_CPROC;
--
-- DPSP_BLOCO_FIN034_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_bloco_fin034_cproc
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
        RETURN 'Processar Dados Bloco 1600';
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
        RETURN 'Processar Carga de Dados Relatório de apoio Bloco SPED 1600 Cartão de Crédito/Débito';
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
        msafi.dsp_control.writelog ( 'BLOCO'
                                   , p_i_texto );
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

    PROCEDURE load_dados_cartoes ( vp_cod_estab IN VARCHAR2
                                 , vp_data_inicial IN DATE
                                 , vp_data_final IN DATE
                                 , vp_data_hora_ini IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 2000 );
        v_existe VARCHAR2 ( 1 );

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
        FOR cd IN c_data_saida ( vp_data_inicial
                               , vp_data_final ) LOOP
            --ARMAZENAR DADOS DE PAGTO DE CARTAO, POIS O DH UTILIZA APENAS OS ULTIMOS 60 DIAS EM PRD
            BEGIN
                SELECT DISTINCT 'Y'
                  INTO v_existe
                  FROM msafi.dpsp_msaf_pagto_cartoes
                 WHERE cod_empresa = msafi.dpsp.empresa
                   AND cod_estab = vp_cod_estab
                   AND data_transacao = cd.data_normal;
            EXCEPTION
                WHEN OTHERS THEN
                    v_existe := 'N';
            END;

            IF ( v_existe <> 'Y' ) THEN
                v_sql := 'INSERT /*+APPEND*/ INTO MSAFI.DPSP_MSAF_PAGTO_CARTOES ( ';
                v_sql :=
                       v_sql
                    || ' SELECT '''
                    || msafi.dpsp.empresa
                    || ''', '''
                    || vp_cod_estab
                    || ''', CF.NUMERO_CUPOM, CT.NUMERO_COMPONENTE, TO_DATE(CT.DATA_TRANSACAO,''YYYYMMDD''), ';
                v_sql :=
                       v_sql
                    || '      CT.NOME_AUTORIZADORA, CT.NOME_VAN, CC.CODIGO_FORMA, CT.NUMERO_PARCELAS, CT.VALOR_TOTAL, SUBSTR(TRIM(NVL(CT.CODIGO_APROVACAO, 0)) || ''|'' || CT.ROWID, 1, 30) ';
                v_sql := v_sql || ' FROM MSAFI.P2K_CAB_TRANSACAO CF, ';
                v_sql := v_sql || '      MSAFI.P2K_RECB_CARTAO   CT, ';
                v_sql := v_sql || '      MSAFI.P2K_RECB_TRANSACAO CC ';
                v_sql := v_sql || ' WHERE CF.CODIGO_LOJA       = CT.CODIGO_LOJA ';
                v_sql := v_sql || '   AND CF.DATA_TRANSACAO    = CT.DATA_TRANSACAO ';
                v_sql := v_sql || '   AND CF.NUMERO_COMPONENTE = CT.NUMERO_COMPONENTE ';
                v_sql := v_sql || '   AND CF.NSU_TRANSACAO     = CT.NSU_TRANSACAO ';
                v_sql := v_sql || '   AND CC.CODIGO_LOJA       = CT.CODIGO_LOJA ';
                v_sql := v_sql || '   AND CC.DATA_TRANSACAO    = CT.DATA_TRANSACAO ';
                v_sql := v_sql || '   AND CC.NUMERO_COMPONENTE = CT.NUMERO_COMPONENTE ';
                v_sql := v_sql || '   AND CC.NSU_TRANSACAO     = CT.NSU_TRANSACAO ';
                v_sql := v_sql || '   AND CC.NUM_SEQ_FORMA     = CT.NUM_SEQ_FORMA ';
                v_sql :=
                       v_sql
                    || '   AND CF.CODIGO_LOJA       = TO_NUMBER(REGEXP_REPLACE('''
                    || vp_cod_estab
                    || ''',''A|B|C|D|E|F|G|H|I|J|K|L|M|N|O|P|Q|R|S|T|U|V|W|X|Y|Z'','''')) ';
                v_sql :=
                       v_sql
                    || '   AND CT.DATA_TRANSACAO    = '''
                    || TO_CHAR ( cd.data_normal
                               , 'YYYYMMDD' )
                    || ''' ) ';

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
                                                , '!ERRO INSERT LOAD PAGTO CARTOES!' );
                END;
            END IF;
        END LOOP;

        loga ( 'LOAD_PAGTO_CARTOES-FIM-' || vp_cod_estab
             , FALSE );
    END;

    PROCEDURE load_safx ( vp_cod_estab IN VARCHAR2
                        , vp_data_inicial IN DATE
                        , vp_data_final IN DATE
                        , vp_data_hora_ini IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 2000 );
        v_existe VARCHAR2 ( 1 );

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
        FOR cd IN c_data_saida ( vp_data_inicial
                               , vp_data_final ) LOOP
            v_sql := 'INSERT INTO SAFX126 ';
            v_sql := v_sql || 'SELECT COD_EMPRESA   ,  ';
            v_sql := v_sql || '  COD_ESTAB   , ';
            v_sql := v_sql || '  TO_CHAR(DATA_TRANSACAO,''YYYYMMDD'') AS DATA_MOVTO  ,  ';
            v_sql := v_sql || '  SUBSTR(VALOR,1,1) AS IND_FIS_JUR ,  ';
            v_sql := v_sql || '  SUBSTR(VALOR,3) AS COD_FIS_JUR,  ';
            v_sql := v_sql || '  REPLACE(TO_CHAR(LPAD((VLR_TOT_CRED*100), 17,  0)),'','','''') VLR_TOT_CRED,  ';
            v_sql := v_sql || '  REPLACE(TO_CHAR(LPAD((VLR_TOT_DEB*100), 17,  0)),'','','''') VLR_TOT_DEB , ';
            v_sql := v_sql || '  SYSDATE DAT_GRAVACAO, ';
            v_sql := v_sql || '  0 VLR_FAT_ICMS,   ';
            v_sql := v_sql || '  0 VLR_EST_ICMS,  ';
            v_sql := v_sql || '  0 VLR_FAT_ISS ,  ';
            v_sql := v_sql || '  0 VLR_EST_ISS FROM ( ';
            v_sql := v_sql || 'SELECT A.COD_EMPRESA,  ';
            v_sql := v_sql || 'A.COD_ESTAB,        ';
            v_sql := v_sql || 'A.DATA_TRANSACAO,   ';
            v_sql := v_sql || 'B.VALOR,      ';
            v_sql := v_sql || 'SUM(CASE WHEN A.CODIGO_FORMA = ''11'' THEN A.VALOR_TOTAL ELSE 0 END) AS VLR_TOT_CRED,  ';
            v_sql := v_sql || 'SUM(CASE WHEN A.CODIGO_FORMA = ''9'' THEN  A.VALOR_TOTAL ELSE 0 END) AS VLR_TOT_DEB  ';
            v_sql := v_sql || 'FROM MSAFI.DPSP_MSAF_PAGTO_CARTOES A, FPAR_PARAM_DET b, FPAR_PARAMETROS C   ';
            v_sql := v_sql || 'WHERE B.descricao = RTRIM(a.nome_van) ';
            v_sql := v_sql || 'AND A.COD_ESTAB =  ''' || vp_cod_estab || ''' ';
            v_sql := v_sql || 'AND C.NOME_FRAMEWORK = ''DPSP_CARTOES_IDENT_CPAR'' ';
            v_sql := v_sql || 'AND C.ID_PARAMETROS = B.ID_PARAMETRO ';
            v_sql :=
                   v_sql
                || 'AND A.DATA_TRANSACAO = '''
                || TO_CHAR ( cd.data_normal
                           , 'DDMMYYYY' )
                || ''' ';
            v_sql := v_sql || 'GROUP BY A.COD_EMPRESA,  ';
            v_sql := v_sql || 'A.COD_ESTAB,  ';
            v_sql := v_sql || 'A.DATA_TRANSACAO, B.VALOR, B.VALOR) ';

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

                    raise_application_error ( -20004
                                            , '!ERRO INSERT LOAD SAFX!' );
            END;
        END LOOP;

        loga ( 'LOAD_SAFX-FIM-' || vp_cod_estab
             , FALSE );
    END;

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

        TYPE a_estabs_t IS TABLE OF VARCHAR2 ( 6 );

        a_estabs a_estabs_t := a_estabs_t ( );

        --Variaveis genericas
        v_text01 VARCHAR2 ( 6000 );
        v_sep VARCHAR2 ( 1 ) := CHR ( 9 );
        p_proc_instance VARCHAR2 ( 30 );

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
            lib_proc.new ( 'DPSP_BLOCO_FIN034_CPROC'
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

        --BUSCAR ID PARAMETRO DO PERFIL
        --   GET_ID_PARAM(V_ID_PARAM, V_DATA_FINAL);

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

        --CARREGAR SAIDAS
        FOR i IN 1 .. a_estabs.COUNT LOOP
            load_dados_cartoes ( a_estabs ( i )
                               , v_data_inicial
                               , v_data_final
                               , v_data_hora_ini );

            load_safx ( a_estabs ( i )
                      , v_data_inicial
                      , v_data_final
                      , v_data_hora_ini );
        END LOOP;

        loga ( 'RESULTADO INSERIDO - FIM' );
        --INSERIR DADOS-FIM-------------------------------------------------------------------------------------------
        --DISPONIBILIZAR PERIODO PROCESSADO PARA TRAVA DE REPROCESSAMENTO
        msafi.add_trava_info ( 'CARTOES'
                             , TO_CHAR ( v_data_inicial
                                       , 'YYYY/MM' ) );

        loga ( 'FIM DO PROCESSAMENTO, STATUS FINAL: [SUCESSO]'
             , FALSE );
        lib_proc.add ( 'FIM DO PROCESSAMENTO, STATUS FINAL: [SUCESSO]' );
        lib_proc.add ( 'Favor verificar LOG para detalhes.' );
        msafi.dsp_control.updateprocess ( v_s_proc_status );

        lib_proc.close ( );

        COMMIT;
        RETURN mproc_id;
    EXCEPTION
        WHEN OTHERS THEN
            msafi.dsp_control.log_checkpoint ( SQLERRM
                                             , 'Erro não tratado, executador de interfaces' );
            msafi.dsp_control.updateprocess ( 4 );
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
END dpsp_bloco_fin034_cproc;
/
SHOW ERRORS;
