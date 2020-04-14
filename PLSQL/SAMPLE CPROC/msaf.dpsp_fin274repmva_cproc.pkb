Prompt Package Body DPSP_FIN274REPMVA_CPROC;
--
-- DPSP_FIN274REPMVA_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_fin274repmva_cproc
IS
    mproc_id INTEGER;
    v_lib_tipo INTEGER;


    --Tipo, Nome e Descrição do Customizado
    --Melhoria FIN274
    mnm_tipo VARCHAR2 ( 100 ) := 'Ressarcimento';
    mnm_cproc VARCHAR2 ( 100 ) := 'Relatório de PMC x MVA Fornecedor Substituído';
    mds_cproc VARCHAR2 ( 100 ) := 'Relatório de Ressarcimento PMC x MVA - Fornecedor Substituído';

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
    --MSAFI.DSP_CONTROL.WRITELOG('RPMCxMVA', P_I_TEXTO);
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

    PROCEDURE insere_final ( p_i_cod_estab IN VARCHAR2
                           , p_i_data_ini IN DATE
                           , p_i_data_fim IN DATE )
    IS
        v_sql VARCHAR2 ( 10000 );
        v_particao_dpsp_msaf_pmc_mva VARCHAR2 ( 50 );
        v_particao_x07_docto_fiscal VARCHAR2 ( 50 );
    BEGIN
        SELECT NVL2 ( MAX ( partition_name ), 'PARTITION (  ' || MAX ( partition_name ) || ')', '' )
          INTO v_particao_dpsp_msaf_pmc_mva
          FROM TABLE ( msafi.dpsp_recupera_particao ( 'MSAFI'
                                                    , 'DPSP_MSAF_PMC_MVA'
                                                    , p_i_data_ini
                                                    , p_i_data_fim ) );


        SELECT NVL2 ( MAX ( partition_name ), 'PARTITION (  ' || MAX ( partition_name ) || ')', '' )
          INTO v_particao_x07_docto_fiscal
          FROM TABLE ( msafi.dpsp_recupera_particao ( 'MSAFI'
                                                    , 'X07_DOCTO_FISCAL'
                                                    , p_i_data_ini
                                                    , p_i_data_fim ) );


        v_sql := 'BEGIN  for c in (';
        v_sql := v_sql || 'SELECT /*+ driving_site(B)  */ DISTINCT A.COD_EMPRESA             , ';
        v_sql := v_sql || 'A.COD_ESTAB               ,  ';
        v_sql := v_sql || 'A.NUM_DOCFIS              ,  ';
        v_sql := v_sql || 'A.DATA_FISCAL             ,  ';
        v_sql := v_sql || 'A.COD_PRODUTO             ,  ';
        v_sql := v_sql || 'A.COD_ESTADO              ,  ';
        v_sql := v_sql || 'A.DOCTO                   ,  ';
        v_sql := v_sql || 'A.NUM_ITEM                ,  ';
        v_sql := v_sql || 'A.DESCR_ITEM              ,  ';
        v_sql := v_sql || 'A.QUANTIDADE              ,  ';
        v_sql := v_sql || 'A.COD_NBM                 ,  ';
        v_sql := v_sql || 'A.COD_CFO                 ,  ';
        v_sql := v_sql || 'A.GRUPO_PRODUTO           ,  ';
        v_sql := v_sql || 'A.VLR_DESCONTO            ,  ';
        v_sql := v_sql || 'A.VLR_CONTABIL            ,  ';
        v_sql := v_sql || 'A.BASE_UNIT_S_VENDA       ,  ';
        v_sql := v_sql || 'A.NUM_AUTENTIC_NFE        ,  ';
        v_sql := v_sql || 'A.COD_ESTAB_E             ,  ';
        v_sql := v_sql || 'A.DATA_FISCAL_E           ,  ';
        v_sql := v_sql || 'A.MOVTO_E_S_E             ,  ';
        v_sql := v_sql || 'A.NORM_DEV_E              ,  ';
        v_sql := v_sql || 'A.IDENT_DOCTO_E           ,  ';
        v_sql := v_sql || 'A.IDENT_FIS_JUR_E         ,  ';
        v_sql := v_sql || 'A.SUB_SERIE_DOCFIS_E      ,  ';
        v_sql := v_sql || 'A.DATA_EMISSAO_E          ,  ';
        v_sql := v_sql || 'A.NUM_DOCFIS_E            ,  ';
        v_sql := v_sql || 'A.SERIE_DOCFIS_E          ,  ';
        v_sql := v_sql || 'A.NUM_ITEM_E              ,  ';
        v_sql := v_sql || 'A.COD_FIS_JUR_E           ,  ';
        v_sql := v_sql || 'A.CPF_CGC_E               ,  ';
        v_sql := v_sql || 'A.COD_NBM_E               ,  ';
        v_sql := v_sql || 'A.COD_CFO_E               ,  ';
        v_sql := v_sql || 'A.COD_NATUREZA_OP_E       ,  ';
        v_sql := v_sql || 'A.COD_PRODUTO_E           ,  ';
        v_sql := v_sql || 'A.VLR_CONTAB_ITEM_E       ,  ';
        v_sql := v_sql || 'A.QUANTIDADE_E            ,  ';
        v_sql := v_sql || 'A.VLR_UNIT_E              ,  ';
        v_sql := v_sql || 'A.COD_SITUACAO_B_E        ,  ';
        v_sql := v_sql || 'A.COD_ESTADO_E            ,  ';
        v_sql := v_sql || 'A.NUM_CONTROLE_DOCTO_E    ,  ';
        v_sql := v_sql || 'A.NUM_AUTENTIC_NFE_E      ,  ';
        v_sql := v_sql || 'A.BASE_ICMS_UNIT_E        ,  ';
        v_sql := v_sql || 'A.VLR_ICMS_UNIT_E         ,  ';
        v_sql := v_sql || 'A.ALIQ_ICMS_E             ,  ';
        v_sql := v_sql || 'A.BASE_ST_UNIT_E          ,  ';
        v_sql := v_sql || 'A.VLR_ICMS_ST_UNIT_E      ,  ';
        v_sql := v_sql || 'A.STAT_LIBER_CNTR         ,  ';
        v_sql := v_sql || 'A.ID_ALIQ_ST              ,  ';
        v_sql := v_sql || 'A.VLR_PMC                 ,  ';
        v_sql := v_sql || 'A.VLR_ICMS_AUX            ,  ';
        v_sql := v_sql || 'A.VLR_ICMS_BRUTO          ,  ';
        v_sql := v_sql || 'A.VLR_ICMS_S_VENDA        ,  ';
        v_sql := v_sql || 'A.VLR_DIF_QTDE            ,  ';
        v_sql := v_sql || 'A.DEB_CRED                ,  ';
        v_sql := v_sql || 'A.SERIE_DOCFIS AS SERIE_DOCFIS_XML ,  ';
        v_sql := v_sql || 'A.VLR_ICMS_ST_UNIT_AUX  AS VLR_ICMS_ST_UNIT_AUX_XML, ';
        v_sql := v_sql || 'A.LISTA AS LISTA_XML,  ';
        v_sql := v_sql || 'B.NF_BRL_LINE_NUM AS NF_BRL_LINE_NUM_XML, ';
        v_sql := v_sql || 'B.INV_ITEM_ID AS INV_ITEM_ID_XML, ';
        v_sql := v_sql || 'B.NFE_VERIF_CODE_PBL AS NFE_VERIF_CODE_PBL_XML,  ';
        v_sql := v_sql || 'B.CFOP_FORN AS CFOP_FORN_XML, ';
        v_sql := v_sql || 'B.DESCR AS   DESCR_XML,  ';

        --
        v_sql := v_sql || 'B.VLR_BASE_ICMS AS VLR_BASE_ICMS_XML, ';
        v_sql := v_sql || 'B.QTY_NF_BRL AS QTD_XML, ';
        v_sql := v_sql || 'B.VLR_ICMS AS VLR_ICMS_XML, ';
        v_sql := v_sql || 'B.ALIQ_REDUCAO AS ALIQ_REDUCAO_XML, ';
        v_sql := v_sql || 'B.VLR_BASE_ICMS_ST AS  VLR_BASE_ICMS_ST_XML, ';
        v_sql := v_sql || 'B.VLR_ICMS_ST AS    VLR_ICMS_ST_XML ,  ';
        v_sql := v_sql || 'B.VLR_BASE_ICMSST_RET AS VLR_BASE_ICMSST_RET_XML,   ';
        v_sql := v_sql || 'B.VLR_ICMSST_RET AS VLR_ICMSST_RET_XML, ';

        v_sql :=
               v_sql
            || ' round((((VLR_BASE_ICMSST_RET*(replace(ID_ALIQ_ST,''%'','''')/100))  / QUANTIDADE_E)*QUANTIDADE ),2) ST_ENTRADA,  ';

        v_sql :=
               v_sql
            || ' CASE WHEN ((nvl(VLR_BASE_ICMSST_RET,0) + nvl(VLR_ICMSST_RET,0) <> 0 AND CFOP_FORN = ''5405'')) THEN ';
        v_sql :=
               v_sql
            || ' round(greatest(0,((BASE_UNIT_S_VENDA*replace(ID_ALIQ_ST,''%'','''')/100))*quantidade),2) WHEN ((nvl(VLR_BASE_ICMSST_RET,0) + nvl(VLR_ICMSST_RET,0) <> 0 AND CFOP_FORN <> ''5405'')) THEN round(greatest(0,((BASE_UNIT_S_VENDA*replace(ID_ALIQ_ST,''%'','''')/100))*quantidade),2) ELSE 0 END ST_SAIDA, ';

        v_sql :=
               v_sql
            || ' CASE WHEN ((nvl(B.VLR_BASE_ICMSST_RET,0) + nvl(B.VLR_ICMSST_RET,0) > 0 AND CFOP_FORN = ''5405'')) THEN (( ';
        v_sql :=
               v_sql
            || ' round((((VLR_BASE_ICMSST_RET*(replace(ID_ALIQ_ST,''%'','''')/100))  / QUANTIDADE_E)*QUANTIDADE ),2)  - ';
        v_sql :=
               v_sql
            || ' round(greatest(0,((BASE_UNIT_S_VENDA*replace(ID_ALIQ_ST,''%'','''')/100))*quantidade),2))) WHEN ((nvl(VLR_BASE_ICMSST_RET,0) + nvl(VLR_ICMSST_RET,0) <> 0 AND B.CFOP_FORN <>''5405'')) THEN ((round((((VLR_BASE_ICMSST_RET*(replace(ID_ALIQ_ST,''%'','''')/100))  / QUANTIDADE_E)*QUANTIDADE ),2)  -   round(greatest(0,((BASE_UNIT_S_VENDA*replace(ID_ALIQ_ST,''%'','''')/100))*quantidade),2))) ELSE 0 END  AS CREDITO_SUBSTITUIDO,  '; --   V_SQL := V_SQL || 'CASE WHEN greatest(( ';
        v_sql :=
               v_sql
            || '(CASE WHEN (CASE WHEN ((nvl(VLR_BASE_ICMSST_RET,0) + nvl(VLR_ICMSST_RET,0) <> 0 AND CFOP_FORN = ''5405'')) THEN ((  ';
        v_sql :=
               v_sql
            || ' round((((VLR_BASE_ICMSST_RET*(replace(ID_ALIQ_ST,''%'','''')/100))  / QUANTIDADE_E)*QUANTIDADE ),2)  - ';
        v_sql :=
               v_sql
            || ' round(greatest(0,((BASE_UNIT_S_VENDA*replace(ID_ALIQ_ST,''%'','''')/100))*quantidade),2))) WHEN ((nvl(VLR_BASE_ICMSST_RET,0) + nvl(VLR_ICMSST_RET,0) <> 0 AND CFOP_FORN <> ''5405'')) THEN ((round((((VLR_BASE_ICMSST_RET*(replace(ID_ALIQ_ST,''%'','''')/100))  / QUANTIDADE_E)*QUANTIDADE ),2)  - round(greatest(0,((BASE_UNIT_S_VENDA*replace(ID_ALIQ_ST,''%'','''')/100))*quantidade),2)))  ELSE 0 END) < 0 THEN  ''DÉBITO'' ELSE ''CRÉDITO''  END) AS DEB_CRED_SUBSTITUIDO, ';

        v_sql :=
               v_sql
            || ' CASE WHEN B.VLR_ICMSST_RET > A.VLR_CONTAB_ITEM_E THEN 0 ELSE B.VLR_BASE_ICMSST_RET END AS V_VLR_BASE_ICMSST_RET_XML , ';
        v_sql :=
               v_sql
            || ' CASE WHEN B.VLR_ICMSST_RET > A.VLR_CONTAB_ITEM_E THEN 0 ELSE B.VLR_ICMSST_RET  END AS V_VLR_ICMSST_RET_XML , ';
        v_sql :=
               v_sql
            || ' CASE WHEN B.VLR_ICMSST_RET > A.VLR_CONTAB_ITEM_E THEN 0 ELSE (CASE WHEN ((nvl(B.VLR_BASE_ICMSST_RET,0) + nvl(B.VLR_ICMSST_RET,0) > 0 AND CFOP_FORN = ''5405'')) THEN (( round((((VLR_BASE_ICMSST_RET*(replace(ID_ALIQ_ST,''%'','''')/100))  / QUANTIDADE_E)*QUANTIDADE ),2) - round(greatest(0,((BASE_UNIT_S_VENDA*replace(ID_ALIQ_ST,''%'','''')/100))*quantidade),2))) WHEN ((nvl(VLR_BASE_ICMSST_RET,0) + nvl(VLR_ICMSST_RET,0) <> 0 AND B.CFOP_FORN <>''5405'')) THEN ((round((((VLR_BASE_ICMSST_RET*(replace(ID_ALIQ_ST,''%'','''')/100))  / QUANTIDADE_E)*QUANTIDADE ),2)  -   round(greatest(0,((BASE_UNIT_S_VENDA*replace(ID_ALIQ_ST,''%'','''')/100))*quantidade),2))) ELSE 0 END) END AS V_CREDITO_SUBSTITUIDO , ';
        v_sql :=
               v_sql
            || ' CASE WHEN B.VLR_ICMSST_RET > A.VLR_CONTAB_ITEM_E THEN ''-'' ELSE (CASE WHEN (CASE WHEN ((nvl(VLR_BASE_ICMSST_RET,0) + nvl(VLR_ICMSST_RET,0) <> 0 AND CFOP_FORN = ''5405'')) THEN (( round((((VLR_BASE_ICMSST_RET*(replace(ID_ALIQ_ST,''%'','''')/100))  / QUANTIDADE_E)*QUANTIDADE ),2) - round(greatest(0,((BASE_UNIT_S_VENDA*replace(ID_ALIQ_ST,''%'','''')/100))*quantidade),2))) WHEN ((nvl(VLR_BASE_ICMSST_RET,0) + nvl(VLR_ICMSST_RET,0) <> 0 AND CFOP_FORN <> ''5405'')) THEN ((round((((VLR_BASE_ICMSST_RET*(replace(ID_ALIQ_ST,''%'','''')/100))  / QUANTIDADE_E)*QUANTIDADE ),2)  - round(greatest(0,((BASE_UNIT_S_VENDA*replace(ID_ALIQ_ST,''%'','''')/100))*quantidade),2)))  ELSE 0 END) < 0 THEN  ''DÉBITO'' ELSE ''CRÉDITO'' END) END AS V_DEB_CRED_SUBSTITUIDO ';

        v_sql :=
               v_sql
            || '  FROM MSAFI.DPSP_MSAF_PMC_MVA '
            || v_particao_dpsp_msaf_pmc_mva
            || ' A, MSAFI.PS_XML_FORN B, MSAF.X07_DOCTO_FISCAL '
            || v_particao_x07_docto_fiscal
            || ' C  ';
        v_sql := v_sql || ' WHERE replace(A.NUM_AUTENTIC_NFE_E,'''''''','''') = B.Nfe_Verif_Code_Pbl(+) ';
        v_sql := v_sql || '   AND A.NUM_ITEM_E = B.NF_BRL_LINE_NUM(+)  ';
        v_sql := v_sql || '   AND A.COD_PRODUTO_E = B.INV_ITEM_ID(+) ';
        v_sql := v_sql || '   AND A.COD_EMPRESA = MSAFI.DPSP.EMPRESA  ';
        v_sql := v_sql || '   AND A.COD_ESTAB =  ''' || p_i_cod_estab || '''  ';
        v_sql := v_sql || '   AND A.DATA_FISCAL BETWEEN ''' || p_i_data_ini || ''' AND ''' || p_i_data_fim || '''  ';
        v_sql :=
               v_sql
            || '   AND (((NVL(B.VLR_BASE_ICMSST_RET,0) + NVL(B.VLR_ICMSST_RET,0)) > 0) OR B.CFOP_FORN = ''5405'')  ';
        v_sql := v_sql || '   AND A.DEB_CRED <> ''CRÉDITO'' ';
        v_sql := v_sql || '   AND C.COD_EMPRESA = A.COD_EMPRESA ';
        v_sql := v_sql || '   AND C.COD_ESTAB = A.COD_ESTAB_E  ';
        v_sql := v_sql || '   AND C.DATA_FISCAL = A.DATA_FISCAL_E  ';
        v_sql := v_sql || '   AND C.MOVTO_E_S = A.MOVTO_E_S_E   ';
        v_sql := v_sql || '   AND C.NORM_DEV = A.NORM_DEV_E   ';
        v_sql := v_sql || '   AND C.NUM_AUTENTIC_NFE = B.Nfe_Verif_Code_Pbl ';
        v_sql := v_sql || '   AND C.IDENT_DOCTO = A.IDENT_DOCTO_E  ';
        v_sql := v_sql || '   AND C.IDENT_FIS_JUR = A.IDENT_FIS_JUR_E ';
        v_sql := v_sql || '   AND C.NUM_DOCFIS = A.NUM_DOCFIS_E  ';
        v_sql := v_sql || '   AND C.SERIE_DOCFIS = A.SERIE_DOCFIS_E   ';
        v_sql := v_sql || '   AND C.NORM_DEV = ''1'' ';
        v_sql := v_sql || '   AND C.SITUACAO = ''N'' ';
        v_sql := v_sql || '   ) loop ';
        v_sql := v_sql || '    insert /*+APPEND*/ ';
        v_sql := v_sql || '    into MSAFI.DPSP_MSAF_PMC_MVA_SUB';
        v_sql := v_sql || '    values';
        v_sql := v_sql || '      (';
        v_sql := v_sql || '  c.cod_empresa,            ';
        v_sql := v_sql || '  c.cod_estab,              ';
        v_sql := v_sql || '  c.num_docfis,             ';
        v_sql := v_sql || '  c.data_fiscal,            ';
        v_sql := v_sql || '  c.cod_produto,            ';
        v_sql := v_sql || '  c.cod_estado,             ';
        v_sql := v_sql || '  c.docto,                  ';
        v_sql := v_sql || '  c.num_item,               ';
        v_sql := v_sql || '  c.descr_item,             ';
        v_sql := v_sql || '  c.quantidade,             ';
        v_sql := v_sql || '  c.cod_nbm,                ';
        v_sql := v_sql || '  c.cod_cfo,                ';
        v_sql := v_sql || '  c.grupo_produto,          ';
        v_sql := v_sql || '  c.vlr_desconto,           ';
        v_sql := v_sql || '  c.vlr_contabil,           ';
        v_sql := v_sql || '  c.base_unit_s_venda,      ';
        v_sql := v_sql || '  c.num_autentic_nfe,       ';
        v_sql := v_sql || '  c.cod_estab_e,            ';
        v_sql := v_sql || '  c.data_fiscal_e,          ';
        v_sql := v_sql || '  c.movto_e_s_e,            ';
        v_sql := v_sql || '  c.norm_dev_e,             ';
        v_sql := v_sql || '  c.ident_docto_e,          ';
        v_sql := v_sql || '  c.ident_fis_jur_e,        ';
        v_sql := v_sql || '  c.sub_serie_docfis_e,     ';
        v_sql := v_sql || '  c.data_emissao_e,         ';
        v_sql := v_sql || '  c.num_docfis_e,           ';
        v_sql := v_sql || '  c.serie_docfis_e,         ';
        v_sql := v_sql || '  c.num_item_e,             ';
        v_sql := v_sql || '  c.cod_fis_jur_e,          ';
        v_sql := v_sql || '  c.cpf_cgc_e,              ';
        v_sql := v_sql || '  c.cod_nbm_e,              ';
        v_sql := v_sql || '  c.cod_cfo_e,              ';
        v_sql := v_sql || '  c.cod_natureza_op_e,      ';
        v_sql := v_sql || '  c.cod_produto_e,          ';
        v_sql := v_sql || '  c.vlr_contab_item_e,      ';
        v_sql := v_sql || '  c.quantidade_e,           ';
        v_sql := v_sql || '  c.vlr_unit_e,             ';
        v_sql := v_sql || '  c.cod_situacao_b_e,       ';
        v_sql := v_sql || '  c.cod_estado_e,           ';
        v_sql := v_sql || '  c.num_controle_docto_e,   ';
        v_sql := v_sql || '  c.num_autentic_nfe_e,     ';
        v_sql := v_sql || '  c.base_icms_unit_e,       ';
        v_sql := v_sql || '  c.vlr_icms_unit_e,        ';
        v_sql := v_sql || '  c.aliq_icms_e,            ';
        v_sql := v_sql || '  c.base_st_unit_e,         ';
        v_sql := v_sql || '  c.vlr_icms_st_unit_e,     ';
        v_sql := v_sql || '  c.stat_liber_cntr,        ';
        v_sql := v_sql || '  c.id_aliq_st,             ';
        v_sql := v_sql || '  c.vlr_pmc,                ';
        v_sql := v_sql || '  c.vlr_icms_aux,           ';
        v_sql := v_sql || '  c.vlr_icms_bruto,         ';
        v_sql := v_sql || '  c.vlr_icms_s_venda,       ';
        v_sql := v_sql || '  c.vlr_dif_qtde,           ';
        v_sql := v_sql || '  c.deb_cred,               ';
        v_sql := v_sql || '  c.serie_docfis_xml,       ';
        v_sql := v_sql || '  c.vlr_icms_st_unit_aux_xml,';
        v_sql := v_sql || '  c.lista_xml,              ';
        v_sql := v_sql || '  c.nf_brl_line_num_xml,    ';
        v_sql := v_sql || '  c.inv_item_id_xml,        ';
        v_sql := v_sql || '  c.nfe_verif_code_pbl_xml, ';
        v_sql := v_sql || '  c.cfop_forn_xml,          ';
        v_sql := v_sql || '  c.descr_xml,              ';
        v_sql := v_sql || '  c.vlr_base_icms_xml,      ';
        v_sql := v_sql || '  c.qtd_xml,                ';
        v_sql := v_sql || '  c.vlr_icms_xml,           ';
        v_sql := v_sql || '  c.aliq_reducao_xml,       ';
        v_sql := v_sql || '  c.vlr_base_icms_st_xml,   ';
        v_sql := v_sql || '  c.vlr_icms_st_xml,        ';
        v_sql := v_sql || '  c.vlr_base_icmsst_ret_xml,';
        v_sql := v_sql || '  c.vlr_icmsst_ret_xml,     ';
        v_sql := v_sql || '  c.st_entrada,             ';
        v_sql := v_sql || '  c.st_saida,               ';
        v_sql := v_sql || '  c.credito_substituido,    ';
        v_sql := v_sql || '  c.deb_cred_substituido,   ';
        v_sql := v_sql || '  c.V_VLR_BASE_ICMSST_RET_XML, ';
        v_sql := v_sql || '  c.V_VLR_ICMSST_RET_XML, ';
        v_sql := v_sql || '  c.V_CREDITO_SUBSTITUIDO, ';
        v_sql := v_sql || '  c.V_DEB_CRED_SUBSTITUIDO ';

        v_sql := v_sql || '       );';
        v_sql := v_sql || '  ';
        v_sql := v_sql || '  end loop;';
        v_sql := v_sql || '  commit;';
        v_sql := v_sql || '  end;';

        BEGIN
            EXECUTE IMMEDIATE v_sql;

            COMMIT;
        END;

        loga ( 'LOAD_TAB_sub-FIM-' || p_i_cod_estab
             , FALSE );
    END;

    PROCEDURE delete_pmc ( p_i_cod_estab IN VARCHAR2
                         , p_i_data_ini IN DATE
                         , p_i_data_fim IN DATE )
    IS
    BEGIN
        DELETE msafi.dpsp_msaf_pmc_mva_sub
         WHERE cod_empresa = mcod_empresa
           AND cod_estab = p_i_cod_estab
           AND data_fiscal BETWEEN TRUNC ( p_i_data_ini
                                         , 'MM' )
                               AND LAST_DAY ( p_i_data_fim );

        COMMIT;
        loga ( 'DEL-FIM '
             , FALSE );

        loga ( 'DELETE_TAB_SUB-FIM-' || p_i_cod_estab
             , FALSE );
    END;

    FUNCTION executar_data ( p_data_ini DATE
                           , p_data_fim DATE
                           , p_sintetico VARCHAR2
                           , p_sintetico_apurado VARCHAR2
                           , p_sintetico_filtro VARCHAR2
                           , p_analitico VARCHAR2
                           , p_analitico_filtro VARCHAR2
                           , p_mapa VARCHAR2
                           , p_conf VARCHAR2
                           , p_uf VARCHAR2
                           , -- apenas utilizado para filtrar as logas na carga do parametro P_LOJAS
                            p_lojas lib_proc.vartab )
        RETURN INTEGER
    IS
        v_format_data VARCHAR2 ( 10 );
        i1 INTEGER;

        v_validar_status INTEGER := 0;
        v_proc_status NUMBER := 0;
        v_s_proc_status VARCHAR2 ( 16 );
        v_qtde_inc INTEGER;
        v_qtd INTEGER;
        v_vlr_base_icmsst_ret_xml NUMBER := 0;
        v_vlr_icmsst_ret_xml NUMBER := 0;
        v_credito_substituido NUMBER := 0;
        v_deb_cred_substituido VARCHAR2 ( 12 );

        TYPE a_estabs_t IS TABLE OF VARCHAR2 ( 6 );

        a_estabs a_estabs_t := a_estabs_t ( );

        --Variaveis genericas
        v_text01 VARCHAR2 ( 6000 );
        v_show VARCHAR2 ( 1 );
        v_color VARCHAR2 ( 100 );
        --
        p_proc_instance VARCHAR2 ( 30 );
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
        v_sql VARCHAR2 ( 10000 );
        v_data_hora_ini VARCHAR2 ( 20 );
        v_existe_origem CHAR := 'S';
        bloc INTEGER ( 1 );

        ------------------------------------------------------------------------------------------------------------------------------------------------------
        --RANGE DE DATAS PARA BUSCAR VENDAS

        v_data_inicial DATE
            :=   TRUNC ( p_data_ini )
               - (   TO_NUMBER ( TO_CHAR ( p_data_ini
                                         , 'DD' ) )
                   - 1 ); -- DATA INICIAL
        v_data_final DATE := LAST_DAY ( p_data_fim ); -- DATA FINAL

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
                FROM (SELECT     p_i_data_inicial + ( ROWNUM - 1 ) AS data_fiscal
                            FROM DUAL
                      CONNECT BY ROWNUM <= (p_i_data_final - p_i_data_inicial + 1)) b
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
                FROM (SELECT     p_i_data_inicial + ( ROWNUM - 1 ) AS data_fiscal
                            FROM DUAL
                      CONNECT BY ROWNUM <= (p_i_data_final - p_i_data_inicial + 1)) b
            GROUP BY TO_CHAR ( data_fiscal
                             , 'DDMMYYYY' )
                   , data_fiscal
            ORDER BY data_fiscal;
    --

    BEGIN
        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        mproc_id :=
            lib_proc.new ( 'DPSP_FIN274REPMVA_CPROC'
                         , 48
                         , 150 );
        musuario := lib_parametros.recuperar ( 'USUARIO' );

        v_lib_tipo := v_lib_tipo + 1;

        --Tela DW
        lib_proc.add_tipo ( pproc_id => mproc_id
                          , ptipo => v_lib_tipo
                          , ptitulo =>    TO_CHAR ( SYSDATE
                                                  , 'YYYYMMDDHH24MISS' )
                                       || '_Substituido'
                          , ptipo_arq => 1 );

        EXECUTE IMMEDIATE ( 'ALTER SESSION SET CURSOR_SHARING = FORCE' );

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

        dbms_application_info.set_module ( $$plsql_unit
                                         , 'Inicio' );

        loga ( '>>> Inicio do relatório...' || p_proc_instance
             , FALSE );
        loga ( '>> DT INICIAL: ' || v_data_inicial
             , FALSE );
        loga ( '>> DT FINAL: ' || v_data_final
             , FALSE );

        --

        --Permitir processo somente para um mês
        IF LAST_DAY ( v_data_inicial ) = LAST_DAY ( v_data_final ) THEN
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

            dbms_application_info.set_module ( $$plsql_unit
                                             , 'COUNT DPSP_MSAF_PMC_MVA_SUB' );


            FOR i IN 1 .. a_estabs.COUNT --(5)
                                        LOOP
                dbms_application_info.set_module ( $$plsql_unit
                                                 , 'Estab ' || a_estabs ( i ) || ' - INSERE FINAL' );

                --=================================================================================
                -- VALIDAR STATUS DE RELATÓRIOS ENCERRADOS
                --=================================================================================
                -- IGUAL À ZERO:      PARA PROCESSOS ABERTOS - AÇÃO: CARREGAR TABELA DEV MERC ST
                -- DIFERENTE DE ZERO: PARA PROCESSOS ENCERRADOS - AÇÃO: CONSULTAR TABELA DEV MERC ST
                ---------------------

                v_validar_status :=
                    msaf.dpsp_suporte_cproc_process.validar_status_rel ( mcod_empresa
                                                                       , a_estabs ( i )
                                                                       , TO_NUMBER ( TO_CHAR ( v_data_inicial
                                                                                             , 'YYYYMM' ) )
                                                                       , $$plsql_unit );

                --=================================================================================
                -- CARREGAR TABELA Devolução Mercadoria ST em periodos Abertos
                --=================================================================================
                IF v_validar_status = 0 THEN --(1)
                    loga ( '>> INICIO CD: ' || a_estabs ( i ) || ' PROC INSERT ' || p_proc_instance
                         , FALSE );

                    v_sql := 'SELECT COUNT(*) AS V_QTDE_INC ';
                    v_sql := v_sql || 'FROM MSAFI.DPSP_MSAF_PMC_MVA_SUB ';
                    v_sql := v_sql || 'WHERE COD_EMPRESA = ''' || mcod_empresa || ''' ';
                    v_sql := v_sql || 'AND COD_ESTAB = ''' || a_estabs ( i ) || ''' ';
                    v_sql :=
                           v_sql
                        || 'AND DATA_FISCAL BETWEEN '''
                        || v_data_inicial
                        || ''' AND '''
                        || LAST_DAY ( v_data_final )
                        || ''' ';

                    EXECUTE IMMEDIATE v_sql            INTO v_qtde_inc;

                    loga ( 'TOTAL  ' || v_qtde_inc || ' LINHAS'
                         , FALSE );



                    v_qtd := v_qtde_inc;

                    ---------------------
                    -- Informar Filias que retornarem sem dados de origem / select zerado
                    ---------------------
                    IF v_qtd = 0 THEN --(3)
                        --Inserir status como Aberto pois não há origem
                        msaf.dpsp_suporte_cproc_process.inserir_status_rel ( mcod_empresa
                                                                           , a_estabs ( i )
                                                                           , TO_NUMBER ( TO_CHAR ( v_data_inicial
                                                                                                 , 'YYYYMM' ) )
                                                                           , $$plsql_unit
                                                                           , mnm_cproc
                                                                           , mnm_tipo
                                                                           , 0
                                                                           , --Aberto
                                                                            $$plsql_unit
                                                                           , mproc_id
                                                                           , musuario
                                                                           , v_data_hora_ini );

                        lib_proc.add ( 'Loja ' || a_estabs ( i ) || ' sem dados na origem.' );

                        bloc := 0;

                        lib_proc.add ( ' ' );
                        loga ( '---Loja ' || a_estabs ( i ) || ' - SEM DADOS DE ORIGEM---'
                             , FALSE );
                        --LOGA('<< SEM DADOS DE ORIGEM >>', FALSE);

                        v_existe_origem := 'N';
                    ELSE
                        lib_proc.add ( 'Loja ' || a_estabs ( i ) || ' - Período já processado e encerrado' );

                        v_retorno_status :=
                            msaf.dpsp_suporte_cproc_process.retornar_status_rel ( mcod_empresa
                                                                                , a_estabs ( i )
                                                                                , TO_NUMBER ( TO_CHAR ( v_data_inicial
                                                                                                      , 'YYYYMM' ) )
                                                                                , $$plsql_unit );
                        lib_proc.add ( 'Data de Encerramento: ' || v_retorno_status );

                        bloc := 1;

                        lib_proc.add ( ' ' );
                        loga (
                                  '---Loja '
                               || a_estabs ( i )
                               || ' - PERIODO JÁ PROCESSADO E ENCERRADO: '
                               || v_retorno_status
                               || '---'
                             , FALSE
                        );

                        ---------------------
                        --Encerrar periodo caso não seja o mês atual e existam registros na origem
                        ---------------------
                        IF LAST_DAY ( v_data_inicial ) < LAST_DAY ( SYSDATE ) THEN
                            msaf.dpsp_suporte_cproc_process.inserir_status_rel ( mcod_empresa
                                                                               , a_estabs ( i )
                                                                               , TO_NUMBER ( TO_CHAR ( v_data_inicial
                                                                                                     , 'YYYYMM' ) )
                                                                               , $$plsql_unit
                                                                               , mnm_cproc
                                                                               , mnm_tipo
                                                                               , 1
                                                                               , --Encerrado
                                                                                $$plsql_unit
                                                                               , mproc_id
                                                                               , musuario
                                                                               , v_data_hora_ini );
                            lib_proc.add ( 'CD ' || a_estabs ( i ) || ' - Período Encerrado' );

                            v_retorno_status :=
                                msaf.dpsp_suporte_cproc_process.retornar_status_rel (
                                                                                      mcod_empresa
                                                                                    , a_estabs ( i )
                                                                                    , TO_NUMBER (
                                                                                                  TO_CHAR (
                                                                                                            v_data_inicial
                                                                                                          , 'YYYYMM'
                                                                                                  )
                                                                                      )
                                                                                    , $$plsql_unit
                                );
                            lib_proc.add ( 'Data de Encerramento: ' || v_retorno_status );

                            bloc := 1;

                            lib_proc.add ( ' ' );
                            loga ( '---CD ' || a_estabs ( i ) || ' - PERIODO ENCERRADO: ' || v_retorno_status || '---'
                                 , FALSE );
                        ELSE
                            msaf.dpsp_suporte_cproc_process.inserir_status_rel ( mcod_empresa
                                                                               , a_estabs ( i )
                                                                               , TO_NUMBER ( TO_CHAR ( v_data_inicial
                                                                                                     , 'YYYYMM' ) )
                                                                               , $$plsql_unit
                                                                               , mnm_cproc
                                                                               , mnm_tipo
                                                                               , 0
                                                                               , --Aberto
                                                                                $$plsql_unit
                                                                               , mproc_id
                                                                               , musuario
                                                                               , v_data_hora_ini );

                            lib_proc.add ( 'CD ' || a_estabs ( i ) || ' - PERIODO EM ABERTO,'
                                         , 1 );
                            lib_proc.add ( 'Os registros gerados são temporários.'
                                         , 1 );

                            bloc := 0;

                            lib_proc.add ( ' '
                                         , 1 );
                            loga ( '---CD ' || a_estabs ( i ) || ' - PERIODO EM ABERTO---'
                                 , FALSE );
                        END IF;
                    END IF; --(1)
                END IF; --(3)

                IF bloc = 0 THEN --(2)
                    insere_final ( a_estabs ( i )
                                 , v_data_inicial
                                 , v_data_final );
                    loga ( 'ESTAB: ' || a_estabs ( i ) || ' - Processo "INSERE/DELETE FINAL"'
                         , FALSE );
                END IF; --(2)
            --END IF;



            END LOOP;

            dbms_application_info.set_module ( $$plsql_unit
                                             , 'Arquivos' );

            IF ( p_conf = 'S' ) THEN
                --(1)

                v_lib_tipo := v_lib_tipo + 1;

                v_class := 'a';

                --MONTAR HEADER - INI
                lib_proc.add_tipo ( mproc_id
                                  , v_lib_tipo
                                  ,    mcod_empresa
                                    || '_CONFERENCIA_'
                                    || TO_CHAR ( p_data_ini
                                               , 'MMYYYY' )
                                    || '_REL_PMC_x_MVA.XLS'
                                  , 2 );

                lib_proc.add ( dsp_planilha.header
                             , ptipo => v_lib_tipo );
                lib_proc.add ( dsp_planilha.tabela_inicio
                             , ptipo => v_lib_tipo );

                --------------
                lib_proc.add ( dsp_planilha.linha_inicio ( p_class => 'h' )
                             , ptipo => v_lib_tipo );
                lib_proc.add ( dsp_planilha.campo ( p_conteudo => 'LINHAS DE CUPONS POR DIA'
                                                  , p_custom => 'COLSPAN=4' )
                             , ptipo => v_lib_tipo );
                lib_proc.add ( dsp_planilha.linha_fim
                             , ptipo => v_lib_tipo );
                --------------

                lib_proc.add ( dsp_planilha.linha_inicio ( p_class => 'h' )
                             , ptipo => v_lib_tipo );

                lib_proc.add ( dsp_planilha.campo ( p_conteudo => 'LOJAS' )
                             , ptipo => v_lib_tipo );
                lib_proc.add ( dsp_planilha.campo ( p_conteudo => 'UF' )
                             , ptipo => v_lib_tipo );

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
                                 , ptipo => v_lib_tipo );
                END LOOP; --(2)

                lib_proc.add ( dsp_planilha.linha_fim
                             , ptipo => v_lib_tipo );

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
                                 , ptipo => v_lib_tipo );

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
                    v_text01 := v_text01 || '  FROM MSAFI.DPSP_MSAF_PMC_MVA_SUB A, MSAFI.DSP_ESTABELECIMENTO B ';
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
                                                 , ptipo => v_lib_tipo );
                                ELSIF ( v_desctab ( i ).col_type = 2 ) THEN
                                    dbms_sql.COLUMN_VALUE ( c_curid
                                                          , i
                                                          , v_numvar );
                                    lib_proc.add ( dsp_planilha.campo ( p_conteudo => v_numvar )
                                                 , ptipo => v_lib_tipo );
                                ELSIF ( v_desctab ( i ).col_type = 12 ) THEN
                                    dbms_sql.COLUMN_VALUE ( c_curid
                                                          , i
                                                          , v_datevar );
                                    lib_proc.add ( dsp_planilha.campo ( p_conteudo => v_datevar )
                                                 , ptipo => v_lib_tipo );
                                END IF;
                            END LOOP;
                        END LOOP;

                        dbms_sql.close_cursor ( c_curid );
                    END;

                    lib_proc.add ( dsp_planilha.linha_fim
                                 , ptipo => v_lib_tipo );
                END LOOP; --(5)

                --MONTAR LINHAS - FIM -------------------------------------------------------------------------------------------

                lib_proc.add ( dsp_planilha.tabela_fim
                             , ptipo => v_lib_tipo );
            END IF; --(1)

            IF ( p_mapa = 'S' ) THEN
                --(1)

                v_lib_tipo := v_lib_tipo + 1;
                v_class := 'a';

                --MONTAR HEADER - INI
                lib_proc.add_tipo ( mproc_id
                                  , v_lib_tipo
                                  ,    mcod_empresa
                                    || '_MAPA_SINTETICO_SUB_'
                                    || TO_CHAR ( p_data_ini
                                               , 'MMYYYY' )
                                    || '_REL_PMC_x_MVA.XLS'
                                  , 2 );

                lib_proc.add ( dsp_planilha.header
                             , ptipo => v_lib_tipo );
                lib_proc.add ( dsp_planilha.tabela_inicio
                             , ptipo => v_lib_tipo );

                lib_proc.add ( dsp_planilha.linha_inicio ( p_class => 'h' )
                             , ptipo => v_lib_tipo );

                lib_proc.add ( dsp_planilha.campo ( p_conteudo => ' ' )
                             , ptipo => v_lib_tipo );
                lib_proc.add ( dsp_planilha.campo ( p_conteudo => ' ' )
                             , ptipo => v_lib_tipo );

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
                                 , ptipo => v_lib_tipo );
                    lib_proc.add ( dsp_planilha.campo ( p_conteudo => c_dt.titulo
                                                      , p_custom => v_color )
                                 , ptipo => v_lib_tipo );
                    lib_proc.add ( dsp_planilha.campo ( p_conteudo => ' '
                                                      , p_custom => v_color )
                                 , ptipo => v_lib_tipo );
                END LOOP; --(2)

                lib_proc.add ( dsp_planilha.linha_fim
                             , ptipo => v_lib_tipo );
                lib_proc.add ( dsp_planilha.linha_inicio ( p_class => 'h' )
                             , ptipo => v_lib_tipo );

                lib_proc.add ( dsp_planilha.campo ( p_conteudo => ' ' )
                             , ptipo => v_lib_tipo );
                lib_proc.add ( dsp_planilha.campo ( p_conteudo => ' ' )
                             , ptipo => v_lib_tipo );

                v_color := ' ';

                FOR c_dt IN c_datas ( v_data_inicial
                                    , v_data_final ) --(2)
                                                    LOOP
                    IF ( v_color = 'BGCOLOR=#000086' ) THEN
                        v_color := ' ';
                    ELSE
                        v_color := 'BGCOLOR=#000086';
                    END IF;

                    lib_proc.add ( dsp_planilha.campo ( p_conteudo => 'PMC'
                                                      , p_custom => v_color )
                                 , ptipo => v_lib_tipo );
                    lib_proc.add ( dsp_planilha.campo ( p_conteudo => 'MVA'
                                                      , p_custom => v_color )
                                 , ptipo => v_lib_tipo );
                    lib_proc.add ( dsp_planilha.campo ( p_conteudo => 'TOTAL'
                                                      , p_custom => v_color )
                                 , ptipo => v_lib_tipo );
                END LOOP; --(2)

                lib_proc.add ( dsp_planilha.linha_fim
                             , ptipo => v_lib_tipo );

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
                                 , ptipo => v_lib_tipo );
                    v_show := 'Y'; --MOSTRAR COD ESTAB E UF APENAS 1 VEZ

                    FOR c_dt IN c_datas ( v_data_inicial
                                        , v_data_final ) --(4)
                                                        LOOP
                        FOR cr_s IN load_sintetico_pmc ( a_estabs ( i )
                                                       , c_dt.data_ini
                                                       , c_dt.data_fim ) --(5)
                                                                        LOOP
                            IF ( v_show = 'Y' ) THEN
                                lib_proc.add ( dsp_planilha.campo ( p_conteudo => cr_s.cod_estab )
                                             , ptipo => v_lib_tipo );
                                lib_proc.add ( dsp_planilha.campo ( p_conteudo => cr_s.cod_estado )
                                             , ptipo => v_lib_tipo );
                                v_show := 'N';
                            END IF;

                            lib_proc.add ( dsp_planilha.campo ( p_conteudo => moeda ( cr_s.vlr_pmc ) )
                                         , ptipo => v_lib_tipo );
                            lib_proc.add ( dsp_planilha.campo ( p_conteudo => moeda ( cr_s.vlr_mva ) )
                                         , ptipo => v_lib_tipo );
                            lib_proc.add ( dsp_planilha.campo ( p_conteudo => moeda ( cr_s.vlr_total ) )
                                         , ptipo => v_lib_tipo );
                        END LOOP; --(5)
                    END LOOP; --(4)

                    lib_proc.add ( dsp_planilha.linha_fim
                                 , ptipo => v_lib_tipo );
                END LOOP; --(3)

                --MONTAR LINHAS - FIM -------------------------------------------------------------------------------------------

                lib_proc.add ( dsp_planilha.tabela_fim
                             , ptipo => v_lib_tipo );
            END IF; --(1)

            IF ( p_sintetico = 'S' ) THEN
                ---MONTAR RELATORIO SINTETICO-INI--------------------------------------------------------------------------------

                v_lib_tipo := v_lib_tipo + 1;
                v_class := 'a';

                lib_proc.add_tipo ( mproc_id
                                  , v_lib_tipo
                                  ,    mcod_empresa
                                    || '_SINTETICO_'
                                    || TO_CHAR ( p_data_ini
                                               , 'MMYYYY' )
                                    || '_REL_PMC_x_MVA.XLS'
                                  , 2 );

                lib_proc.add ( dsp_planilha.header
                             , ptipo => v_lib_tipo );
                lib_proc.add ( dsp_planilha.tabela_inicio
                             , ptipo => v_lib_tipo );

                lib_proc.add ( dsp_planilha.linha (
                                                    p_conteudo =>    dsp_planilha.campo ( 'ESTAB' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'UF' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'PMC' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'MVA' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'TOTAL' ) --
                                                  , p_class => 'h'
                               )
                             , ptipo => v_lib_tipo );

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
                                                                 dsp_planilha.campo ( moeda ( cr_s.vlr_pmc ) )
                                                               || --
                                                                 dsp_planilha.campo ( moeda ( cr_s.vlr_mva ) )
                                                               || --
                                                                 dsp_planilha.campo ( moeda ( cr_s.vlr_total ) ) --
                                               , p_class => v_class
                            );
                        lib_proc.add ( v_text01
                                     , ptipo => v_lib_tipo );
                    END LOOP; --FOR CR_R IN LOAD_ANALITICO(A_ESTABS(i), V_DATA_INICIAL, V_DATA_FINAL)
                END LOOP; --FOR i IN 1..A_ESTABS.COUNT

                lib_proc.add ( dsp_planilha.tabela_fim
                             , ptipo => v_lib_tipo );
            ---MONTAR RELATORIO SINTETICO-FIM--------------------------------------------------------------------------------
            END IF; --IF (P_SINTETICO = 'S') THEN

            IF ( p_sintetico_apurado = 'S' ) THEN
                ---MONTAR RELATORIO SINTETICO APURADO-INI--------------------------------------------------------------------------------

                v_lib_tipo := v_lib_tipo + 1;
                v_class := 'a';

                lib_proc.add_tipo ( mproc_id
                                  , v_lib_tipo
                                  ,    mcod_empresa
                                    || '_SINTETICO_VLR_APURADO_'
                                    || TO_CHAR ( p_data_ini
                                               , 'MMYYYY' )
                                    || '_REL_SUB_PMC_x_MVA.XLS'
                                  , 2 );

                lib_proc.add ( dsp_planilha.header
                             , ptipo => v_lib_tipo );
                lib_proc.add ( dsp_planilha.tabela_inicio
                             , ptipo => v_lib_tipo );

                lib_proc.add ( dsp_planilha.linha (
                                                    p_conteudo =>    dsp_planilha.campo ( 'ESTAB' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'UF' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'PERIODO' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'TOTAL APURADO' ) --
                                                  , p_class => 'h'
                               )
                             , ptipo => v_lib_tipo );

                FOR i IN 1 .. a_estabs.COUNT LOOP
                    FOR cr_sa IN load_sintetico_apurado ( a_estabs ( i )
                                                        , v_data_inicial
                                                        , v_data_final
                                                        , p_sintetico_filtro ) LOOP
                        IF v_class = 'a' THEN
                            v_class := 'b';
                        ELSE
                            v_class := 'a';
                        END IF;

                        v_format_data :=
                            TO_CHAR ( cr_sa.periodo
                                    , 'MM/YYYY' );

                        v_text01 :=
                            dsp_planilha.linha (
                                                 p_conteudo =>    dsp_planilha.campo ( cr_sa.cod_estab )
                                                               || --
                                                                 dsp_planilha.campo ( cr_sa.cod_estado )
                                                               || --
                                                                 dsp_planilha.campo (
                                                                                      dsp_planilha.texto (
                                                                                                           v_format_data
                                                                                      )
                                                                  )
                                                               || --
                                                                 dsp_planilha.campo ( moeda ( cr_sa.vlr_apurado ) ) --
                                               , p_class => v_class
                            );
                        lib_proc.add ( v_text01
                                     , ptipo => v_lib_tipo );
                    END LOOP; --FOR CR_R IN LOAD_ANALITICO_APURADO(A_ESTABS(i), V_DATA_INICIAL, V_DATA_FINAL, P_SINTETICO_FILTRO)
                END LOOP; --FOR i IN 1..A_ESTABS.COUNT

                lib_proc.add ( dsp_planilha.tabela_fim
                             , ptipo => v_lib_tipo );
            ---MONTAR RELATORIO SINTETICO APURADO-FIM--------------------------------------------------------------------------------
            END IF; --IF (P_SINTETICO_APURADO = 'S') THEN

            IF ( p_analitico = 'S' ) THEN
                ---MONTAR RELATORIO ANALITICO-INI--------------------------------------------------------------------------------

                dbms_application_info.set_module ( $$plsql_unit
                                                 , 'Arquivo Analitico' );


                FOR i IN 1 .. a_estabs.COUNT LOOP
                    v_lib_tipo := v_lib_tipo + 1;
                    v_class := 'a';

                    SELECT cod_estado
                      INTO v_uf
                      FROM msafi.dsp_estabelecimento
                     WHERE cod_empresa = mcod_empresa
                       AND cod_estab = a_estabs ( i );

                    lib_proc.add_tipo ( mproc_id
                                      , v_lib_tipo
                                      ,    mcod_empresa
                                        || '_'
                                        || v_uf
                                        || '_'
                                        || a_estabs ( i )
                                        || '_'
                                        || TO_CHAR ( p_data_ini
                                                   , 'MMYYYY' )
                                        || '_REL_SUB_PMC_x_MVA.XLS'
                                      , 2 );

                    lib_proc.add ( dsp_planilha.header
                                 , ptipo => v_lib_tipo );
                    lib_proc.add ( dsp_planilha.tabela_inicio
                                 , ptipo => v_lib_tipo );

                    lib_proc.add ( dsp_planilha.linha ( p_conteudo =>    dsp_planilha.campo (
                                                                                              'GRUPO SAÍDA'
                                                                                            , p_custom => 'COLSPAN=17'
                                                                         )
                                                                      || --
                                                                        dsp_planilha.campo (
                                                                                             'GRUPO ENTRADA'
                                                                                           , p_custom => 'COLSPAN=38 BGCOLOR=BLUE'
                                                                         )
                                                                      || --
                                                                        dsp_planilha.campo (
                                                                                             'GRUPO XML'
                                                                                           , p_custom => 'COLSPAN=13 BGCOLOR=GRAY'
                                                                         )
                                                                      || --
                                                                        dsp_planilha.campo (
                                                                                             'GRUPO CALCULADO'
                                                                                           , p_custom => 'COLSPAN=4 BGCOLOR=GREEN'
                                                                         ) --                                      --
                                                      , p_class => 'h' )
                                 , ptipo => v_lib_tipo );

                    lib_proc.add ( dsp_planilha.linha ( p_conteudo =>    dsp_planilha.campo ( 'COD_EMPRESA' )
                                                                      || --                                                                               DSP_PLANILHA.CAMPO('COD_ESTAB') || --
                                                                        dsp_planilha.campo ( 'COD_ESTAB' )
                                                                      || --
                                                                        dsp_planilha.campo ( 'NUM_DOCFIS' )
                                                                      || --
                                                                        dsp_planilha.campo ( 'DATA_FISCAL' )
                                                                      || --
                                                                        dsp_planilha.campo ( 'COD_PRODUTO' )
                                                                      || --
                                                                        dsp_planilha.campo ( 'COD_ESTADO' )
                                                                      || --
                                                                        dsp_planilha.campo ( 'DOCTO' )
                                                                      || --
                                                                        dsp_planilha.campo ( 'NUM_ITEM' )
                                                                      || --
                                                                        dsp_planilha.campo ( 'DESCR_ITEM' )
                                                                      || --
                                                                        dsp_planilha.campo ( 'QUANTIDADE_S' )
                                                                      || --
                                                                        dsp_planilha.campo ( 'COD_NBM' )
                                                                      || --
                                                                        dsp_planilha.campo ( 'COD_CFO' )
                                                                      || --
                                                                        dsp_planilha.campo ( 'GRUPO_PRODUTO' )
                                                                      || --
                                                                        dsp_planilha.campo ( 'VLR_DESCONTO' )
                                                                      || --
                                                                        dsp_planilha.campo ( 'VLR_CONTABIL' )
                                                                      || --
                                                                        dsp_planilha.campo ( 'BASE_UNIT_S_VENDA' )
                                                                      || --
                                                                        dsp_planilha.campo ( 'NUM_AUTENTIC_NFE' )
                                                                      || --
                                                                        dsp_planilha.campo (
                                                                                             'COD_ESTAB_E'
                                                                                           , p_custom => 'BGCOLOR=BLUE'
                                                                         )
                                                                      || --
                                                                        dsp_planilha.campo (
                                                                                             'DATA_FISCAL_E'
                                                                                           , p_custom => 'BGCOLOR=BLUE'
                                                                         )
                                                                      || --
                                                                        dsp_planilha.campo (
                                                                                             'MOVTO_E_S_E'
                                                                                           , p_custom => 'BGCOLOR=BLUE'
                                                                         )
                                                                      || --
                                                                        dsp_planilha.campo (
                                                                                             'NORM_DEV_E'
                                                                                           , p_custom => 'BGCOLOR=BLUE'
                                                                         )
                                                                      || --
                                                                        dsp_planilha.campo (
                                                                                             'IDENT_DOCTO_E'
                                                                                           , p_custom => 'BGCOLOR=BLUE'
                                                                         )
                                                                      || --
                                                                        dsp_planilha.campo (
                                                                                             'IDENT_FIS_JUR_E'
                                                                                           , p_custom => 'BGCOLOR=BLUE'
                                                                         )
                                                                      || --
                                                                        dsp_planilha.campo (
                                                                                             'SUB_SERIE_DOCFIS_E'
                                                                                           , p_custom => 'BGCOLOR=BLUE'
                                                                         )
                                                                      || --
                                                                        dsp_planilha.campo (
                                                                                             'DATA_EMISSAO_E'
                                                                                           , p_custom => 'BGCOLOR=BLUE'
                                                                         )
                                                                      || --
                                                                        dsp_planilha.campo (
                                                                                             'NUM_DOCFIS_E'
                                                                                           , p_custom => 'BGCOLOR=BLUE'
                                                                         )
                                                                      || --
                                                                        dsp_planilha.campo (
                                                                                             'SERIE_DOCFIS_E'
                                                                                           , p_custom => 'BGCOLOR=BLUE'
                                                                         )
                                                                      || --
                                                                        dsp_planilha.campo (
                                                                                             'NUM_ITEM_E'
                                                                                           , p_custom => 'BGCOLOR=BLUE'
                                                                         )
                                                                      || --
                                                                        dsp_planilha.campo (
                                                                                             'COD_FIS_JUR_E'
                                                                                           , p_custom => 'BGCOLOR=BLUE'
                                                                         )
                                                                      || --
                                                                        dsp_planilha.campo (
                                                                                             'CPF_CGC_E'
                                                                                           , p_custom => 'BGCOLOR=BLUE'
                                                                         )
                                                                      || --
                                                                        dsp_planilha.campo (
                                                                                             'COD_NBM_E'
                                                                                           , p_custom => 'BGCOLOR=BLUE'
                                                                         )
                                                                      || --
                                                                        dsp_planilha.campo (
                                                                                             'COD_CFO_E'
                                                                                           , p_custom => 'BGCOLOR=BLUE'
                                                                         )
                                                                      || --
                                                                        dsp_planilha.campo (
                                                                                             'COD_NATUREZA_OP_E'
                                                                                           , p_custom => 'BGCOLOR=BLUE'
                                                                         )
                                                                      || --
                                                                        dsp_planilha.campo (
                                                                                             'COD_PRODUTO_E'
                                                                                           , p_custom => 'BGCOLOR=BLUE'
                                                                         )
                                                                      || --
                                                                        dsp_planilha.campo (
                                                                                             'VLR_CONTAB_ITEM_E'
                                                                                           , p_custom => 'BGCOLOR=BLUE'
                                                                         )
                                                                      || --
                                                                        dsp_planilha.campo (
                                                                                             'QUANTIDADE_E'
                                                                                           , p_custom => 'BGCOLOR=BLUE'
                                                                         )
                                                                      || --
                                                                        dsp_planilha.campo (
                                                                                             'VLR_UNIT_E'
                                                                                           , p_custom => 'BGCOLOR=BLUE'
                                                                         )
                                                                      || --
                                                                        dsp_planilha.campo (
                                                                                             'COD_SITUACAO_B_E'
                                                                                           , p_custom => 'BGCOLOR=BLUE'
                                                                         )
                                                                      || --
                                                                        dsp_planilha.campo (
                                                                                             'COD_ESTADO_E'
                                                                                           , p_custom => 'BGCOLOR=BLUE'
                                                                         )
                                                                      || --
                                                                        dsp_planilha.campo (
                                                                                             'NUM_CONTROLE_DOCTO_E'
                                                                                           , p_custom => 'BGCOLOR=BLUE'
                                                                         )
                                                                      || --
                                                                        dsp_planilha.campo (
                                                                                             'NUM_AUTENTIC_NFE_E'
                                                                                           , p_custom => 'BGCOLOR=BLUE'
                                                                         )
                                                                      || --
                                                                        dsp_planilha.campo (
                                                                                             'BASE_ICMS_UNIT_E'
                                                                                           , p_custom => 'BGCOLOR=BLUE'
                                                                         )
                                                                      || --
                                                                        dsp_planilha.campo (
                                                                                             'VLR_ICMS_UNIT_E'
                                                                                           , p_custom => 'BGCOLOR=BLUE'
                                                                         )
                                                                      || --
                                                                        dsp_planilha.campo (
                                                                                             'ALIQ_ICMS_E'
                                                                                           , p_custom => 'BGCOLOR=BLUE'
                                                                         )
                                                                      || --
                                                                        dsp_planilha.campo (
                                                                                             'BASE_ST_UNIT_E'
                                                                                           , p_custom => 'BGCOLOR=BLUE'
                                                                         )
                                                                      || --
                                                                        dsp_planilha.campo (
                                                                                             'VLR_ICMS_ST_UNIT_E'
                                                                                           , p_custom => 'BGCOLOR=BLUE'
                                                                         )
                                                                      || --
                                                                        dsp_planilha.campo (
                                                                                             'STAT_LIBER_CNTR'
                                                                                           , p_custom => 'BGCOLOR=BLUE'
                                                                         )
                                                                      || --
                                                                        dsp_planilha.campo (
                                                                                             'ID_ALIQ_ST'
                                                                                           , p_custom => 'BGCOLOR=BLUE'
                                                                         )
                                                                      || --
                                                                        dsp_planilha.campo (
                                                                                             'VLR_PMC'
                                                                                           , p_custom => 'BGCOLOR=BLUE'
                                                                         )
                                                                      || --
                                                                        dsp_planilha.campo (
                                                                                             'VLR_ICMS_AUX'
                                                                                           , p_custom => 'BGCOLOR=BLUE'
                                                                         )
                                                                      || --
                                                                        dsp_planilha.campo (
                                                                                             'VLR_ICMS_BRUTO'
                                                                                           , p_custom => 'BGCOLOR=BLUE'
                                                                         )
                                                                      || --
                                                                        dsp_planilha.campo (
                                                                                             'VLR_ICMS_S_VENDA'
                                                                                           , p_custom => 'BGCOLOR=BLUE'
                                                                         )
                                                                      || --
                                                                        dsp_planilha.campo (
                                                                                             'VLR_DIF_QTDE'
                                                                                           , p_custom => 'BGCOLOR=BLUE'
                                                                         )
                                                                      || --
                                                                        dsp_planilha.campo (
                                                                                             'DEB_CRED'
                                                                                           , p_custom => 'BGCOLOR=BLUE'
                                                                         )
                                                                      || --
                                                                        dsp_planilha.campo (
                                                                                             'LISTA_XML'
                                                                                           , p_custom => 'BGCOLOR=BLUE'
                                                                         )
                                                                      || --
                                                                        dsp_planilha.campo (
                                                                                             'NF_BRL_LINE_NUM_XML'
                                                                                           , p_custom => 'BGCOLOR=GRAY'
                                                                         )
                                                                      || --
                                                                        dsp_planilha.campo (
                                                                                             'INV_ITEM_ID_XML'
                                                                                           , p_custom => 'BGCOLOR=GRAY'
                                                                         )
                                                                      || --
                                                                        dsp_planilha.campo (
                                                                                             'NFE_VERIF_CODE_PBL_XML'
                                                                                           , p_custom => 'BGCOLOR=GRAY'
                                                                         )
                                                                      || --
                                                                        dsp_planilha.campo (
                                                                                             'CFOP_FORN_XML'
                                                                                           , p_custom => 'BGCOLOR=GRAY'
                                                                         )
                                                                      || --
                                                                        dsp_planilha.campo (
                                                                                             'DESCR_XML'
                                                                                           , p_custom => 'BGCOLOR=GRAY'
                                                                         )
                                                                      || --
                                                                        dsp_planilha.campo (
                                                                                             'VLR_BASE_ICMS_XML'
                                                                                           , p_custom => 'BGCOLOR=GRAY'
                                                                         )
                                                                      || --
                                                                        dsp_planilha.campo (
                                                                                             'QTD_XML'
                                                                                           , p_custom => 'BGCOLOR=GRAY'
                                                                         )
                                                                      || --
                                                                        dsp_planilha.campo (
                                                                                             'VLR_ICMS_XML'
                                                                                           , p_custom => 'BGCOLOR=GRAY'
                                                                         )
                                                                      || --
                                                                        dsp_planilha.campo (
                                                                                             'ALIQ_REDUCAO_XML'
                                                                                           , p_custom => 'BGCOLOR=GRAY'
                                                                         )
                                                                      || --
                                                                        dsp_planilha.campo (
                                                                                             'VLR_BASE_ICMS_ST_XML'
                                                                                           , p_custom => 'BGCOLOR=GRAY'
                                                                         )
                                                                      || --
                                                                        dsp_planilha.campo (
                                                                                             'VLR_ICMS_ST_XML'
                                                                                           , p_custom => 'BGCOLOR=GRAY'
                                                                         )
                                                                      || --
                                                                        dsp_planilha.campo (
                                                                                             'VLR_BASE_ICMSST_RET_XML'
                                                                                           , p_custom => 'BGCOLOR=GRAY'
                                                                         )
                                                                      || --
                                                                        dsp_planilha.campo (
                                                                                             'VLR_ICMSST_RET_XML'
                                                                                           , p_custom => 'BGCOLOR=GRAY'
                                                                         )
                                                                      || --
                                                                        dsp_planilha.campo (
                                                                                             'ST_ENTRADA'
                                                                                           , p_custom => 'BGCOLOR=GREEN'
                                                                         )
                                                                      || --
                                                                        dsp_planilha.campo (
                                                                                             'ST_SAIDA'
                                                                                           , p_custom => 'BGCOLOR=GREEN'
                                                                         )
                                                                      || --
                                                                        dsp_planilha.campo (
                                                                                             'CREDITO_SUBSTITUIDO'
                                                                                           , p_custom => 'BGCOLOR=GREEN'
                                                                         )
                                                                      || --
                                                                        dsp_planilha.campo (
                                                                                             'DEB_CRED_SUBSTITUIDO'
                                                                                           , p_custom => 'BGCOLOR=GREEN'
                                                                         )
                                                      , p_class => 'h' )
                                 , ptipo => v_lib_tipo );

                    FOR cr_r IN load_analitico ( a_estabs ( i )
                                               , v_data_inicial
                                               , v_data_final ) LOOP
                        IF ( NVL ( p_analitico_filtro, '1' ) = '1' )
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

                            --Nova Regra Fernanda

                            IF ( cr_r.vlr_icmsst_ret_xml > cr_r.vlr_contab_item_e ) THEN
                                v_vlr_base_icmsst_ret_xml := 0;
                                v_vlr_icmsst_ret_xml := 0;
                                v_credito_substituido := 0;
                                v_deb_cred_substituido := '-';
                            ELSE
                                v_vlr_base_icmsst_ret_xml := cr_r.vlr_base_icmsst_ret_xml;
                                v_vlr_icmsst_ret_xml := cr_r.vlr_icmsst_ret_xml;
                                v_credito_substituido := cr_r.credito_substituido;
                                v_deb_cred_substituido := cr_r.deb_cred_substituido;
                            END IF;


                            v_text01 :=
                                dsp_planilha.linha (
                                                     p_conteudo =>    dsp_planilha.campo ( cr_r.cod_empresa )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.cod_estab )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.num_docfis )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.data_fiscal )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.cod_produto )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.cod_estado )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.docto )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.num_item )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.descr_item )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.quantidade )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.cod_nbm )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.cod_cfo )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.grupo_produto )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.vlr_desconto )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.vlr_contabil )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.base_unit_s_venda )
                                                                   || --
                                                                     dsp_planilha.campo (
                                                                                          dsp_planilha.texto (
                                                                                                               cr_r.num_autentic_nfe
                                                                                          )
                                                                      )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.cod_estab_e )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.data_fiscal_e )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.movto_e_s_e )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.norm_dev_e )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.ident_docto_e )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.ident_fis_jur_e )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.sub_serie_docfis_e )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.data_emissao_e )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.num_docfis_e )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.serie_docfis_e )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.num_item_e )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.cod_fis_jur_e )
                                                                   || --
                                                                     dsp_planilha.campo (
                                                                                          dsp_planilha.texto (
                                                                                                               cr_r.cpf_cgc_e
                                                                                          )
                                                                      )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.cod_nbm_e )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.cod_cfo_e )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.cod_natureza_op_e )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.cod_produto_e )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.vlr_contab_item_e )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.quantidade_e )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.vlr_unit_e )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.cod_situacao_b_e )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.cod_estado_e )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.num_controle_docto_e )
                                                                   || --
                                                                     dsp_planilha.campo (
                                                                                          dsp_planilha.texto (
                                                                                                               cr_r.num_autentic_nfe_e
                                                                                          )
                                                                      )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.base_icms_unit_e )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.vlr_icms_unit_e )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.aliq_icms_e )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.base_st_unit_e )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.vlr_icms_st_unit_e )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.stat_liber_cntr )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.id_aliq_st )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.vlr_pmc )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.vlr_icms_aux )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.vlr_icms_bruto )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.vlr_icms_s_venda )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.vlr_dif_qtde )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.deb_cred )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.lista_xml )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.nf_brl_line_num_xml )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.inv_item_id_xml )
                                                                   || --
                                                                     dsp_planilha.campo (
                                                                                          dsp_planilha.texto (
                                                                                                               cr_r.nfe_verif_code_pbl_xml
                                                                                          )
                                                                      )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.cfop_forn_xml )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.descr_xml )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.vlr_base_icms_xml )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.qtd_xml )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.vlr_icms_xml )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.aliq_reducao_xml )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.vlr_base_icms_st_xml )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.vlr_icms_st_xml )
                                                                   || --
                                                                     dsp_planilha.campo ( v_vlr_base_icmsst_ret_xml )
                                                                   || --
                                                                     dsp_planilha.campo ( v_vlr_icmsst_ret_xml )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.st_entrada )
                                                                   || --
                                                                     dsp_planilha.campo ( cr_r.st_saida )
                                                                   || --
                                                                     dsp_planilha.campo ( v_credito_substituido )
                                                                   || --
                                                                     dsp_planilha.campo ( v_deb_cred_substituido )
                                                   , p_class => v_class
                                );
                            lib_proc.add ( v_text01
                                         , ptipo => v_lib_tipo );
                        END IF; --(1)
                    END LOOP; --FOR CR_R IN LOAD_ANALITICO(A_ESTABS(i), V_DATA_INICIAL, V_DATA_FINAL)

                    lib_proc.add ( dsp_planilha.linha_fim
                                 , ptipo => v_lib_tipo );
                END LOOP; --FOR i IN 1..A_ESTABS.COUNT
            ---MONTAR RELATORIO ANALITICO-FIM--------------------------------------------------------------------------------
            END IF; --IF (P_ANALITICO = 'S') THEN


            dbms_application_info.set_module ( $$plsql_unit
                                             , 'Fim' );


            v_lib_tipo := v_lib_tipo + 1;
            v_class := 'a';
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
        --Em casos de meses diferentes
        ELSE
            lib_proc.add ( 'Processo não permitido:'
                         , 1 );
            lib_proc.add ( 'Favor informar somente um único mês entre a Data Inicial e Data Final'
                         , 1 );
            lib_proc.add ( ' '
                         , 1 );

            loga ( ' '
                 , FALSE );
            loga ( '<< PROCESSO NÃO PERMITIDO >>'
                 , FALSE );
            loga ( 'NÃO É PERMITIDO O PROCESSAMENTO DE MESES DIFERENTES'
                 , FALSE );
            loga ( ' '
                 , FALSE );

            loga ( '---FIM DO PROCESSAMENTO [ERRO]---'
                 , FALSE );
        END IF;
    END; /* FUNCTION EXECUTAR */

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
                      , -- apenas utilizado para filtrar as logas na carga do parametro P_LOJAS
                       p_lojas lib_proc.vartab )
        RETURN INTEGER
    IS
        v_integer INTEGER;
    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS='',.'' ';

        v_lib_tipo := 0;

        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        mproc_id :=
            lib_proc.new ( 'DPSP_FIN274REPMVA_CPROC'
                         , 48
                         , 150 );


        dbms_application_info.set_module ( $$plsql_unit
                                         , 'Relatório de PMC x MVA Fornecedor Substituído' );

        FOR c IN ( SELECT   MIN ( data_fiscal ) AS data_ini
                          , MAX ( data_fiscal ) AS data_fim
                       FROM (SELECT     p_data_ini + ( ROWNUM - 1 ) AS data_fiscal
                                   FROM DUAL
                             CONNECT BY ROWNUM <= (p_data_fim - p_data_ini + 1)) b
                   GROUP BY TO_CHAR ( data_fiscal
                                    , 'MM/YYYY' )
                   ORDER BY 2 ) LOOP
            v_integer :=
                executar_data ( c.data_ini
                              , c.data_fim
                              , p_sintetico
                              , p_sintetico_apurado
                              , p_sintetico_filtro
                              , p_analitico
                              , p_analitico_filtro
                              , p_mapa
                              , p_conf
                              , p_uf
                              , -- apenas utilizado para filtrar as logas na carga do parametro P_LOJAS
                               p_lojas );
        END LOOP;

        RETURN mproc_id;
    END;
END dpsp_fin274repmva_cproc;
/
SHOW ERRORS;
