Prompt Package Body DPSP_FIN2662_PAR_REG_DUB_CPROC;
--
-- DPSP_FIN2662_PAR_REG_DUB_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_fin2662_par_reg_dub_cproc
IS
    v_sel_data_fim VARCHAR2 ( 260 )
        := ' SELECT TRUNC( TO_DATE( :1 ,''DD/MM/YYYY'') + ROWNUM - 1) AS DATA_FIM, TRUNC( TO_DATE( :1 ,''DD/MM/YYYY'') + ROWNUM - 1) AS DATA_FIM FROM DUAL CONNECT BY ROWNUM <= LAST_DAY( TO_DATE( :1 ,''DD/MM/YYYY'') ) - TO_DATE( :1 ,''DD/MM/YYYY'') + 1 ORDER BY 1 DESC ';
    v_tab_footer VARCHAR2 ( 100 )
        := ' STORAGE (BUFFER_POOL KEEP) PCTFREE 10 NOLOGGING NOCOMPRESS CACHE TABLESPACE MSAF_WORK_TABLES ';
    mlinha VARCHAR2 ( 4000 );
    mpagina NUMBER := 0;

    mproc_id INTEGER;

    --Tipo, Nome e Descrição do Customizado
    mnm_tipo VARCHAR2 ( 100 ) := 'Obrigação Estadual';
    mnm_cproc VARCHAR2 ( 100 ) := 'Tela de cálculo DUB-RJ ';
    mds_cproc VARCHAR2 ( 100 ) := 'Tela de parâmetros para execução do cálculo';

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

        lib_proc.add_param ( pparam => pstr
                           , --P_CONSULTA
                            ptitulo => 'Ação'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'RADIOBUTTON'
                           , pmandatorio => 'S'
                           , pdefault => 'I'
                           , pmascara => NULL
                           , pvalores => 'C=Consultar,I=Incluir,E=Excluir' );

        --PCOD_EMPRESA
        lib_proc.add_param (
                             pparam => pstr
                           , --P_CONVENIO
                            ptitulo => 'Convênio'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'COMBOBOX'
                           , pmandatorio => 'N'
                           , pdefault => '%'
                           , pmascara => NULL
                           , pvalores =>    ' SELECT ''%'' AS COD_CONVENIO, ''Todos os Convênios'' AS DESCRICAO FROM DUAL '
                                         || ' WHERE :1 = ''C'' '
                                         || ' UNION ALL '
                                         || --
                                           ' SELECT TO_CHAR(COD_CONVENIO) AS COD_CONVENIO,  COD_CONVENIO || '' - '' || DES_CONVENIO AS DESCRICAO '
                                         || --
                                           ' FROM MSAFI.DPSP_FIN2662_PAR_CON_DUB '
        );

        lib_proc.add_param ( pparam => pstr
                           , --P_
                            ptitulo => 'Data Inicial'
                           , --PDT_INI
                            ptipo => 'DATE'
                           , pcontrole => 'TEXTBOX'
                           , pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => 'DD/MM/YYYY'
                           , pvalores => NULL
                           , phabilita => ' :1 = ''I'' ' );

        lib_proc.add_param ( pparam => pstr
                           , ptitulo => 'Data Final'
                           , --PDT_FIM
                            ptipo => 'DATE'
                           , pcontrole => 'TEXTBOX'
                           , pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => 'DD/MM/YYYY'
                           , pvalores => NULL
                           , phabilita => ' :1 = ''I'' ' );

        lib_proc.add_param (
                             pparam => pstr
                           , --P_REGRA_CALC
                            ptitulo => 'Regra de Cálculo'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'COMBOBOX'
                           , pmandatorio => 'N'
                           , pdefault => NULL
                           , pmascara => NULL
                           , pvalores =>    'SELECT COD_REG_CALC, COD_REG_CALC || '' - '' || DES_REG_CALC AS DESCRICAO '
                                         || ' FROM MSAFI.DPSP_FIN2662_REG_CALC_DUB ORDER BY COD_REG_CALC'
                           , phabilita => ' :1 = ''I'' '
        );

        lib_proc.add_param (
                             pparam => pstr
                           , --P_CST
                            ptitulo => 'CST'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'COMBOBOX'
                           , pmandatorio => 'N'
                           , pdefault => NULL
                           , pmascara => NULL
                           , pvalores =>    'SELECT COD_SITUACAO_B, COD_SITUACAO_B || '' - '' || DESCRICAO AS DESCRICAO '
                                         || ' FROM MSAF.Y2026_SIT_TRB_UF_B ORDER BY COD_SITUACAO_B'
                           , phabilita => ' :1 = ''I'' '
        );

        lib_proc.add_param (
                             pparam => pstr
                           , --P_ITEM_SUB
                            ptitulo => 'Item Subclassificação'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'COMBOBOX'
                           , pmandatorio => 'N'
                           , pdefault => NULL
                           , pmascara => NULL
                           , pvalores =>    ' SELECT ORDEM, DESCRICAO FROM ( '
                                         || ' SELECT 2 AS ORDEM, ''Não aplicáveis'' AS DESCRICAO FROM DUAL UNION ALL '
                                         || ' SELECT 1,''PSV''  FROM DUAL UNION ALL '
                                         || ' SELECT 1,''ONCO'' FROM DUAL UNION ALL '
                                         || ' SELECT 1,''ORTO'' FROM DUAL UNION ALL '
                                         || ' SELECT 1,''AIDS'' FROM DUAL) '
                                         || ' ORDER BY ORDEM, DESCRICAO '
                           , phabilita => ' :1 = ''I'' '
        );

        lib_proc.add_param (
                             pparam => pstr
                           , --P_EXCLUI
                            ptitulo => 'Excluir Regra'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'COMBOBOX'
                           , pmandatorio => 'N'
                           , pdefault => NULL
                           , pmascara => NULL
                           , pvalores =>    ' SELECT TIPO_REGISTRO,	COD_ESTADO,	IND_PRODUTO,	COD_PRODUTO,	VALID_INICIAL,	ALIQ_INTERNA,	IND_PRODUTO_ASS,	COD_PRODUTO_ASS,	MODELO_LIVRO,	VALID_FINAL,	PRC_REDUCAO_BC '
                                         || ' FROM MSAFI.DPSP_FIN2662_PAR_REG_DUB '
                           , phabilita => ' :1 = ''E'' '
        );

        lib_proc.add_param (
                             pparam => pstr
                           , --P_CFO
                            ptitulo => 'CFOPs de Saída'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'MULTISELECT'
                           , pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => NULL
                           , pvalores =>    ' SELECT COD_CFO, COD_CFO || '' - '' || DESCRICAO AS DESCRICAO '
                                         || --
                                           '  FROM MSAF.X2012_COD_FISCAL '
                                         || --
                                           ' WHERE LENGTH(COD_CFO) = 4 '
                                         || --
                                           '   AND (COD_CFO LIKE ''5%'' OR COD_CFO LIKE ''6%'') '
                                         || -- SOMENTE SÁIDAS
                                           '   AND COD_CFO NOT IN (''5411'',''6411'') '
                                         || -- DESCONSIDERAR CFOPs DE DEVOLUÇÃO
                                           '   AND :1 = ''I'' '
                                         || --
                                           ' ORDER BY COD_CFO '
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

    ---------------------------------------------------------------------------------------------------------------------------------------------------------------
    FUNCTION executar ( p_consulta VARCHAR2
                      , p_convenio VARCHAR2
                      , p_data_ini DATE
                      , p_data_fim DATE
                      , p_regra_calc VARCHAR2
                      , p_cst VARCHAR2
                      , p_item_sub VARCHAR2
                      , p_exclui VARCHAR2
                      , p_cfo lib_proc.vartab )
        RETURN INTEGER
    IS
        i1 INTEGER;

        v_proc_status NUMBER := 0;
        v_s_proc_status VARCHAR2 ( 16 );

        v_txt_temp VARCHAR2 ( 1024 ) := '';
        v_txt_basico VARCHAR2 ( 256 ) := '';

        --  TYPE A_ESTABS_T IS TABLE OF VARCHAR2(6);
        -- A_ESTABS A_ESTABS_T := A_ESTABS_T();

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

        v_pct_medi NUMBER;
        v_pct_protege NUMBER;

        v_id_arq NUMBER := 90;

        ------------------------------------------------------------------------------------------------
        --RANGE DE DATAS PARA BUSCAR VENDAS
        v_data_inicial DATE := p_data_ini; -- DATA INICIAL
        v_data_final DATE := p_data_fim; -- DATA FINAL
    ------------------------------------------------------------------------------------------------

    BEGIN
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


        loga ( '<<' || mnm_cproc || '>>'
             , FALSE );
        loga ( '---INICIO DO PROCESSAMENTO---'
             , FALSE );



        dbms_application_info.set_module ( $$plsql_unit
                                         , 'PROC_ID: ' || mproc_id );


        --GERAR CHAVE PROC_ID
        SELECT ROUND ( dbms_random.VALUE ( 10000000000000
                                         , 999999999999999 ) )
          INTO vp_proc_instance
          FROM DUAL;

        loga ( '---------------------------------------------------'
             , FALSE );
        loga ( '>> PROC INSERT: ' || vp_proc_instance
             , FALSE );
        loga ( '---------------------------------------------------'
             , FALSE );

        --LIMPAR REGISTROS ANTIGOS DA TABELA FINAL
        --    IF V_PCT_PROTEGE < '0,5' OR V_PCT_PROTEGE > '15' THEN

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

        --  V_TEXT01 := 'Percentual PRODEPE informado: ' || P_PCT_PROTEGE || '%';
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

        -- ELSE

        --PREPARAR LOJAS S

        --DELETE_TEMP_TBL(VP_PROC_INSTANCE);

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

        --  END IF; --VALIDAR V_PCT_PROTEGE

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
END dpsp_fin2662_par_reg_dub_cproc;
/
SHOW ERRORS;
