Prompt Package Body DSP_RELATORIOS_01_CPROC;
--
-- DSP_RELATORIOS_01_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dsp_relatorios_01_cproc
IS
    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    -- AJ0001 - Rodolfo S Carvalhal                           30/06/2017
    -- Ajuste cursor do relatório 009
    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    -- AJ0002 - Rodolfo S Carvalhal                           30/06/2017
    -- Formatação do relatório 009
    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    -- AJ0003 - Rodolfo S Carvalhal                           30/06/2017
    -- Recuperar código de empresa na execução
    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    -- AJ0004 - Rodolfo S Carvalhal                           14/08/2017
    -- Adicionar campos e alterar relatorio para xlsx
    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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

        lib_proc.add_param (
                             pstr
                           , 'RELATORIO'
                           , --P_RELATORIO
                            'VARCHAR2'
                           , 'COMBOBOX'
                           , 'S'
                           , NULL
                           , NULL
                           , '
                            SELECT ''001'',''001 - Cupom - Incoerência de datas entre X991 e X993/X994'' FROM DUAL
                      UNION SELECT ''002'',''002 - Documentos fiscais com data futura'' FROM DUAL
                      UNION SELECT ''003'',''003 - Resumo por CFOP por tabela X - relatorio LENTO'' FROM DUAL
                      UNION SELECT ''004'',''004 - Divergência de Devolução das lojas para CDs'' FROM DUAL
                      UNION SELECT ''005'',''005 - NFs potencialmente problematicas'' FROM DUAL
                      UNION SELECT ''006'',''006 - NFs alteradas fora de periodo no PS'' FROM DUAL
                      UNION SELECT ''007'',''007 - Validação de Chave de Acesso'' FROM DUAL
                      UNION SELECT ''008'',''008 - Relatório de diferenças de ICMS x alíquota'' FROM DUAL
                      UNION SELECT ''009'',''009 - Relatório de Fechamento Fiscal (RC)'' FROM DUAL
                      UNION SELECT ''010'',''010 - Relatório por Finalidade IST - Depósitos'' FROM DUAL
                      UNION SELECT ''011'',''011 - Relatório Controle de Apuração de ICMS'' FROM DUAL
                      UNION SELECT ''012'',''012 - Notas Fiscais de Entrada Duplicadas'' FROM DUAL
                      UNION SELECT ''101'',''101 - P2K - Dif. P2K_FECHAMENTO e P2K_TRIB_FECH'' FROM DUAL
                      UNION SELECT ''102'',''102 - P2K - Dif. P2K_TRIB_FECH e P2K_CAB_TRANSACAO - VENDA LIQUIDA'' FROM DUAL
                      UNION SELECT ''103'',''103 - P2K - Dif. P2K_TRIB_FECH e P2K_ITEM_TRANSACAO - VENDA LIQUIDA'' FROM DUAL
                      UNION SELECT ''012'',''012 - Relatório Análise de Saldos da CAT17'' FROM DUAL
                           '
        );

        lib_proc.add_param ( pstr
                           , 'DATA INICIAL'
                           , --P_DATA_INI
                            'DATE'
                           , 'TEXTBOX'
                           , 'N'
                           , NULL
                           , 'DD/MM/YYYY' );

        lib_proc.add_param ( pstr
                           , 'DATA FINAL'
                           , --P_DATA_FIM
                            'DATE'
                           , 'TEXTBOX'
                           , 'N'
                           , NULL
                           , 'DD/MM/YYYY' );

        --        LIB_PROC.ADD_PARAM(PSTR,
        --                           'Separador', --P_SEP
        --                           'VARCHAR2',
        --                           'COMBOBOX',
        --                           'S',
        --                           NULL,
        --                           NULL,
        --                           '
        --                            SELECT ''|'',''Pipe |'' FROM DUAL
        --                      /*UNION SELECT CHR(9),''<TAB>'' FROM DUAL ....o MSAF converte para espaço*/
        --                           '
        --                           );

        lib_proc.add_param ( pstr
                           , 'Fixo todos estabs (ALL)'
                           , --P_EXEC_ALL
                            'VARCHAR2'
                           , 'CHECKBOX'
                           , 'N'
                           , NULL
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
                           , 'ESTABELECIMENTO '
                           , --P_CODESTAB
                            'VARCHAR2'
                           , 'MULTISELECT'
                           , 'N'
                           , NULL
                           , NULL
                           ,    'SELECT A.COD_ESTAB, A.COD_ESTAB || '' - '' || B.COD_ESTADO || '' - '' || A.CGC || '' - '' || INITCAP(A.BAIRRO) || '' / '' || INITCAP(A.CIDADE) FROM ESTABELECIMENTO A, ESTADO B, MSAFI.DSP_ESTABELECIMENTO C WHERE A.COD_EMPRESA  = '''
                             || mcod_empresa
                             || ''' AND B.IDENT_ESTADO = A.IDENT_ESTADO AND A.COD_EMPRESA = C.COD_EMPRESA AND A.COD_ESTAB = C.COD_ESTAB AND B.COD_ESTADO LIKE :5 ORDER BY B.COD_ESTADO, A.COD_ESTAB'
        );

        RETURN pstr;
    END; --FUNCTION PARAMETROS RETURN VARCHAR2 IS

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'RELATÓRIOS CUSTOMIZADOS 01';
    END;

    FUNCTION tipo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Relatorio';
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
        RETURN 'RELATÓRIOS DIVERSOS';
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

    FUNCTION orientacaopapel
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'landscape';
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
        msafi.dsp_control.writelog ( 'INFO'
                                   , p_i_texto );
    END;

    FUNCTION moeda ( v_conteudo NUMBER )
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN TRIM ( TO_CHAR ( v_conteudo
                              , '9g999g999g990d00' ) );
    END;

    FUNCTION fazcampo ( p_i_campo IN VARCHAR2
                      , p_i_fill IN VARCHAR2
                      , p_i_size IN NUMBER )
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN LPAD ( NVL ( p_i_campo, ' ' )
                    , p_i_size
                    , p_i_fill );
    END;

    FUNCTION fazcampo ( p_i_campo IN NUMBER
                      , p_i_format IN VARCHAR2
                      , p_i_fill IN VARCHAR2
                      , p_i_size IN NUMBER )
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN LPAD ( NVL ( TO_CHAR ( p_i_campo
                                    , p_i_format )
                          , ' ' )
                    , p_i_size
                    , p_i_fill );
    END;

    FUNCTION fazcampo ( p_i_campo IN DATE
                      , p_i_format IN VARCHAR2
                      , p_i_fill IN VARCHAR2
                      , p_i_size IN NUMBER )
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN LPAD ( NVL ( TO_CHAR ( p_i_campo
                                    , p_i_format )
                          , ' ' )
                    , p_i_size
                    , p_i_fill );
    END;

    -- Refactored procedure GERA_RELATORIO_009
    PROCEDURE gera_relatorio_009 ( p_data_ini IN DATE
                                 , p_data_fim IN DATE
                                 , v_exec_all IN OUT CHAR )
    IS
        -- AJ0004
        v_quebra_arq NUMBER ( 7 ) := 1000000;
        v_contr_plan NUMBER ( 7 );
        v_cont_arq INT;
        v_text01 VARCHAR2 ( 1000 );
        v_class CHAR ( 1 ) := 'a';
        v_sql VARCHAR2 ( 4000 );
        ---
        v_cod_estab VARCHAR2 ( 6 );
        v_uf_estab VARCHAR2 ( 2 );
        v_forn_cli VARCHAR2 ( 14 );
        v_uf_forn_cli VARCHAR2 ( 2 );
        v_data_fiscal DATE;
        v_data_emissao DATE;
        v_numero_nf VARCHAR2 ( 10 );
        v_serie VARCHAR2 ( 4 );
        v_id_people VARCHAR2 ( 14 );
        v_cod_docto VARCHAR2 ( 6 );
        v_modelo_doc VARCHAR2 ( 8 );
        v_fin VARCHAR2 ( 6 );
        v_cfop VARCHAR2 ( 6 );
        v_cst VARCHAR2 ( 4 );
        v_vlr_contabil NUMBER ( 17, 2 );
        v_base_trib NUMBER ( 17, 2 );
        v_aliq_icms NUMBER ( 7, 4 );
        v_vlr_icms NUMBER ( 17, 2 );
        v_base_isent NUMBER ( 17, 2 );
        v_base_outras NUMBER ( 17, 2 );
        v_base_red NUMBER ( 17, 2 );
        v_vlr_icms_st NUMBER ( 17, 2 );
        v_vlr_ipi NUMBER ( 17, 2 );
        v_dif_bases NUMBER ( 17, 2 );
        ---
        cr_009 SYS_REFCURSOR;
    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS='',.''';

        v_contr_plan := 0;
        v_cont_arq := 0;

        v_sql := 'SELECT CAPA.COD_ESTAB ';
        v_sql := v_sql || '     ,EST1.COD_ESTADO              UF_ESTAB ';
        v_sql := v_sql || '     ,X04.COD_FIS_JUR              FORN_CLI ';
        v_sql := v_sql || '     ,EST.COD_ESTADO               UF_FORN_CLI ';
        v_sql := v_sql || '     ,CAPA.DATA_FISCAL             DATA_FISCAL ';
        v_sql := v_sql || '     ,CAPA.DATA_EMISSAO            DATA_EMISSAO ';
        v_sql := v_sql || '     ,CAPA.NUM_DOCFIS              NUMERO_NF ';
        v_sql := v_sql || '     ,CAPA.SERIE_DOCFIS            SERIE ';
        v_sql := v_sql || '     ,CAPA.NUM_CONTROLE_DOCTO      ID_PEOPLE '; -- AJ0004
        v_sql := v_sql || '     ,TIPO.COD_DOCTO               COD_DOCTO ';
        v_sql := v_sql || '     ,MOD.COD_MODELO               MODELO_DOC ';
        v_sql := v_sql || '     ,FIN.COD_NATUREZA_OP          FIN '; -- AJ0004
        v_sql := v_sql || '     ,CFO.COD_CFO                  CFOP ';
        v_sql := v_sql || '     ,CST.COD_SITUACAO_B           CST ';
        v_sql := v_sql || '     ,SUM(ITENS.VLR_CONTAB_ITEM)   VLR_CONTABIL ';
        v_sql := v_sql || '     ,SUM(ITENS.VLR_BASE_ICMS_1)   BASE_TRIB ';
        v_sql := v_sql || '     ,ITENS.ALIQ_TRIBUTO_ICMS      ALIQ_ICMS '; -- AJ0004
        v_sql := v_sql || '     ,SUM(ITENS.VLR_TRIBUTO_ICMS)  VLR_ICMS ';
        v_sql := v_sql || '     ,SUM(ITENS.VLR_BASE_ICMS_2)   BASE_ISENT ';
        v_sql := v_sql || '     ,SUM(ITENS.VLR_BASE_ICMS_3)   BASE_OUTRAS ';
        v_sql := v_sql || '     ,SUM(ITENS.VLR_BASE_ICMS_4)   BASE_RED ';
        v_sql := v_sql || '     ,SUM(ITENS.VLR_TRIBUTO_ICMSS) VLR_ICMS_ST ';
        v_sql := v_sql || '     ,SUM(ITENS.VLR_IPI_NDESTAC)   VLR_IPI ';
        v_sql :=
               v_sql
            || '     ,SUM(ITENS.VLR_CONTAB_ITEM)-SUM(ITENS.VLR_OUTRAS)-SUM(ITENS.VLR_BASE_ICMS_1)-SUM(ITENS.VLR_BASE_ICMS_2)-SUM(ITENS.VLR_BASE_ICMS_3)-SUM(ITENS.VLR_BASE_ICMS_4)-SUM(ITENS.VLR_TRIBUTO_ICMSS)-SUM(ITENS.VLR_IPI_NDESTAC) DIF_BASES ';

        v_sql := v_sql || ' FROM MSAF.DWT_DOCTO_FISCAL       CAPA, ';
        v_sql := v_sql || '      MSAF.DWT_ITENS_MERC        ITENS, ';
        v_sql := v_sql || '      MSAF.X04_PESSOA_FIS_JUR      X04, ';
        v_sql := v_sql || '      MSAF.X2012_COD_FISCAL        CFO, ';
        v_sql := v_sql || '      MSAF.Y2026_SIT_TRB_UF_B      CST, ';
        v_sql := v_sql || '      MSAF.X2006_NATUREZA_OP       FIN, ';
        v_sql := v_sql || '      MSAF.ESTADO                  EST, ';
        v_sql := v_sql || '      MSAF.ESTADO                  EST1, ';
        v_sql := v_sql || '      MSAF.ESTABELECIMENTO         ESTAB, ';
        v_sql := v_sql || '      MSAF.X2005_TIPO_DOCTO        TIPO, ';
        v_sql := v_sql || '      MSAF.X2024_MODELO_DOCTO      MOD ';

        IF ( v_exec_all <> 'Y' ) THEN
            ---COD_ESTABs ESPECIFICOS
            v_sql := v_sql || ' ,MSAFI.DSP_PROC_ESTABS TMP ';
        END IF;

        v_sql := v_sql || ' WHERE CAPA.COD_EMPRESA        = ITENS.COD_EMPRESA ';
        v_sql := v_sql || ' AND   CAPA.COD_ESTAB          = ITENS.COD_ESTAB ';
        v_sql := v_sql || ' AND   CAPA.DATA_FISCAL        = ITENS.DATA_FISCAL ';
        v_sql := v_sql || ' AND   CAPA.MOVTO_E_S          = ITENS.MOVTO_E_S ';
        v_sql := v_sql || ' AND   CAPA.NORM_DEV           = ITENS.NORM_DEV ';
        v_sql := v_sql || ' AND   CAPA.IDENT_DOCTO        = ITENS.IDENT_DOCTO ';
        v_sql := v_sql || ' AND   CAPA.IDENT_FIS_JUR      = ITENS.IDENT_FIS_JUR ';
        v_sql := v_sql || ' AND   CAPA.NUM_DOCFIS         = ITENS.NUM_DOCFIS ';
        v_sql := v_sql || ' AND   CAPA.SERIE_DOCFIS       = ITENS.SERIE_DOCFIS ';
        v_sql := v_sql || ' AND   CAPA.SUB_SERIE_DOCFIS   = ITENS.SUB_SERIE_DOCFIS ';

        IF ( v_exec_all <> 'Y' ) THEN
            ---COD_ESTABs ESPECIFICOS
            v_sql := v_sql || ' AND TMP.COD_ESTAB = CAPA.COD_ESTAB ';
        END IF;

        v_sql := v_sql || ' AND   CAPA.IDENT_FIS_JUR      = X04.IDENT_FIS_JUR ';
        v_sql := v_sql || ' AND   ITENS.IDENT_CFO         = CFO.IDENT_CFO ';
        v_sql := v_sql || ' AND   ITENS.IDENT_SITUACAO_B  = CST.IDENT_SITUACAO_B ';
        v_sql := v_sql || ' AND   ITENS.IDENT_NATUREZA_OP = FIN.IDENT_NATUREZA_OP(+)';
        v_sql := v_sql || ' AND   X04.IDENT_ESTADO        = EST.IDENT_ESTADO ';
        v_sql := v_sql || ' AND   EST1.IDENT_ESTADO       = ESTAB.IDENT_ESTADO ';
        v_sql := v_sql || ' AND   CAPA.IDENT_DOCTO        = TIPO.IDENT_DOCTO ';
        v_sql := v_sql || ' AND   CAPA.IDENT_MODELO       = MOD.IDENT_MODELO ';
        v_sql := v_sql || ' AND   CAPA.COD_ESTAB          = ESTAB.COD_ESTAB ';
        v_sql := v_sql || ' AND   CAPA.COD_EMPRESA        = MSAFI.DPSP.EMPRESA ';
        v_sql := v_sql || ' AND   CAPA.SITUACAO           = ''N'' ';
        v_sql := v_sql || ' AND   COD_DOCTO NOT IN (''CF'',''CF-E'',''SAT'') '; -- AJ0004
        v_sql :=
               v_sql
            || ' AND   ITENS.DATA_FISCAL BETWEEN TO_DATE('''
            || TO_CHAR ( p_data_ini
                       , 'DDMMYYYY' )
            || ''',''DDMMYYYY'') AND TO_DATE('''
            || TO_CHAR ( p_data_fim
                       , 'DDMMYYYY' )
            || ''',''DDMMYYYY'') ';
        v_sql := v_sql || ' GROUP BY CAPA.COD_ESTAB ';
        v_sql := v_sql || '     ,EST1.COD_ESTADO ';
        v_sql := v_sql || '     ,X04.COD_FIS_JUR ';
        v_sql := v_sql || '     ,EST.COD_ESTADO ';
        v_sql := v_sql || '     ,CAPA.DATA_FISCAL ';
        v_sql := v_sql || '     ,CAPA.DATA_EMISSAO ';
        v_sql := v_sql || '     ,CAPA.NUM_DOCFIS ';
        v_sql := v_sql || '     ,CAPA.SERIE_DOCFIS ';
        v_sql := v_sql || '     ,TIPO.COD_DOCTO ';
        v_sql := v_sql || '     ,MOD.COD_MODELO ';
        v_sql := v_sql || '     ,CFO.COD_CFO ';
        v_sql := v_sql || '     ,CST.COD_SITUACAO_B ';
        v_sql := v_sql || '     ,FIN.COD_NATUREZA_OP ';
        v_sql := v_sql || '     ,ITENS.ALIQ_TRIBUTO_ICMS ';
        v_sql := v_sql || '     ,CAPA.NUM_CONTROLE_DOCTO ';

        BEGIN
            OPEN cr_009 FOR v_sql;
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
                                        , '!ERRO OPEN REL 009!' );
        END;

        LOOP
            FETCH cr_009
                INTO v_cod_estab
                   , v_uf_estab
                   , v_forn_cli
                   , v_uf_forn_cli
                   , v_data_fiscal
                   , v_data_emissao
                   , v_numero_nf
                   , v_serie
                   , v_id_people
                   , v_cod_docto
                   , v_modelo_doc
                   , v_fin
                   , v_cfop
                   , v_cst
                   , v_vlr_contabil
                   , v_base_trib
                   , v_aliq_icms
                   , v_vlr_icms
                   , v_base_isent
                   , v_base_outras
                   , v_base_red
                   , v_vlr_icms_st
                   , v_vlr_ipi
                   , v_dif_bases;

            EXIT WHEN cr_009%NOTFOUND;

            IF v_contr_plan < 1 THEN
                v_contr_plan := v_quebra_arq;
                v_cont_arq := v_cont_arq + 1;
                -- CRIA PROCESSO
                lib_proc.add_tipo ( mproc_id
                                  , v_cont_arq + 1
                                  ,    'FECHAMENTO_'
                                    || TO_CHAR ( p_data_ini
                                               , 'YYYYMMDD' )
                                    || '_'
                                    || TO_CHAR ( p_data_fim
                                               , 'YYYYMMDD' )
                                    || '_'
                                    || LPAD ( v_cont_arq
                                            , 2
                                            , '0' )
                                    || '.XLS'
                                  , 2 );
                -- ADICIONA CABECALHO
                lib_proc.add ( dsp_planilha.header ( )
                             , --
                              ptipo => v_cont_arq + 1 );
                lib_proc.add ( dsp_planilha.tabela_inicio ( )
                             , ptipo => v_cont_arq + 1 );
                v_text01 := dsp_planilha.campo ( p_conteudo => 'COD_ESTAB' );
                v_text01 := v_text01 || --
                                       dsp_planilha.campo ( p_conteudo => 'UF_ESTAB' );
                v_text01 := v_text01 || --
                                       dsp_planilha.campo ( p_conteudo => 'UF_FORN_CLI' );
                v_text01 := v_text01 || --
                                       dsp_planilha.campo ( p_conteudo => 'DATA_FISCAL' );
                v_text01 := v_text01 || --
                                       dsp_planilha.campo ( p_conteudo => 'NUMERO_NF' );
                v_text01 := v_text01 || --
                                       dsp_planilha.campo ( p_conteudo => 'SERIE' );
                v_text01 := v_text01 || --
                                       dsp_planilha.campo ( p_conteudo => 'ID_PEOPLE' );
                v_text01 := v_text01 || --
                                       dsp_planilha.campo ( p_conteudo => 'COD_DOCTO' );
                v_text01 := v_text01 || --
                                       dsp_planilha.campo ( p_conteudo => 'MODELO_DOC' );
                v_text01 := v_text01 || --
                                       dsp_planilha.campo ( p_conteudo => 'FIN' );
                v_text01 := v_text01 || --
                                       dsp_planilha.campo ( p_conteudo => 'CFOP' );
                v_text01 := v_text01 || --
                                       dsp_planilha.campo ( p_conteudo => 'CST' );
                v_text01 := v_text01 || --
                                       dsp_planilha.campo ( p_conteudo => 'VLR_CONTABIL' );
                v_text01 := v_text01 || --
                                       dsp_planilha.campo ( p_conteudo => 'BASE_TRIB' );
                v_text01 := v_text01 || --
                                       dsp_planilha.campo ( p_conteudo => 'ALIQ_ICMS' );
                v_text01 := v_text01 || --
                                       dsp_planilha.campo ( p_conteudo => 'VLR_ICMS' );
                v_text01 := v_text01 || --
                                       dsp_planilha.campo ( p_conteudo => 'BASE_ISENT' );
                v_text01 := v_text01 || --
                                       dsp_planilha.campo ( p_conteudo => 'BASE_OUTRAS' );
                v_text01 := v_text01 || --
                                       dsp_planilha.campo ( p_conteudo => 'BASE_RED' );
                v_text01 := v_text01 || --
                                       dsp_planilha.campo ( p_conteudo => 'VLR_ICMS_ST' );
                v_text01 := v_text01 || --
                                       dsp_planilha.campo ( p_conteudo => 'VLR_IPI' );
                v_text01 := v_text01 || --
                                       dsp_planilha.campo ( p_conteudo => 'DIF_BASES' );

                lib_proc.add ( dsp_planilha.linha ( p_conteudo => v_text01
                                                  , p_class => 'h' )
                             , ptipo => v_cont_arq + 1 );
            END IF;

            IF v_class = 'a' THEN
                v_class := 'b';
            ELSE
                v_class := 'a';
            END IF;

            -- ADICIONA LINHA
            v_text01 := dsp_planilha.campo ( p_conteudo => v_cod_estab );
            v_text01 := v_text01 || --
                                   dsp_planilha.campo ( p_conteudo => v_uf_estab );
            v_text01 := v_text01 || --
                                   dsp_planilha.campo ( p_conteudo => v_uf_forn_cli );
            v_text01 := v_text01 || --
                                   dsp_planilha.campo ( p_conteudo => v_data_fiscal );
            v_text01 := v_text01 || --
                                   dsp_planilha.campo ( p_conteudo => dsp_planilha.texto ( v_numero_nf ) );
            v_text01 := v_text01 || --
                                   dsp_planilha.campo ( p_conteudo => dsp_planilha.texto ( v_serie ) );
            v_text01 := v_text01 || --
                                   dsp_planilha.campo ( p_conteudo => dsp_planilha.texto ( v_id_people ) );
            v_text01 := v_text01 || --
                                   dsp_planilha.campo ( p_conteudo => v_cod_docto );
            v_text01 := v_text01 || --
                                   dsp_planilha.campo ( p_conteudo => dsp_planilha.texto ( v_modelo_doc ) );
            v_text01 := v_text01 || --
                                   dsp_planilha.campo ( p_conteudo => v_fin );
            v_text01 := v_text01 || --
                                   dsp_planilha.campo ( p_conteudo => v_cfop );
            v_text01 := v_text01 || --
                                   dsp_planilha.campo ( p_conteudo => dsp_planilha.texto ( v_cst ) );
            v_text01 :=
                   v_text01
                || --
                  dsp_planilha.campo ( p_conteudo => TO_CHAR ( v_vlr_contabil
                                                             , 'FM999G999G990D00' ) );
            v_text01 :=
                   v_text01
                || --
                  dsp_planilha.campo ( p_conteudo => TO_CHAR ( v_base_trib
                                                             , 'FM999G999G990D00' ) );
            v_text01 :=
                   v_text01
                || --
                  dsp_planilha.campo ( p_conteudo => TO_CHAR ( v_aliq_icms
                                                             , 'FM990D00' ) );
            v_text01 :=
                   v_text01
                || --
                  dsp_planilha.campo ( p_conteudo => TO_CHAR ( v_vlr_icms
                                                             , 'FM999G999G990D00' ) );
            v_text01 :=
                   v_text01
                || --
                  dsp_planilha.campo ( p_conteudo => TO_CHAR ( v_base_isent
                                                             , 'FM999G999G990D00' ) );
            v_text01 :=
                   v_text01
                || --
                  dsp_planilha.campo ( p_conteudo => TO_CHAR ( v_base_outras
                                                             , 'FM999G999G990D00' ) );
            v_text01 :=
                   v_text01
                || --
                  dsp_planilha.campo ( p_conteudo => TO_CHAR ( v_base_red
                                                             , 'FM999G999G990D00' ) );
            v_text01 :=
                   v_text01
                || --
                  dsp_planilha.campo ( p_conteudo => TO_CHAR ( v_vlr_icms_st
                                                             , 'FM999G999G990D00' ) );
            v_text01 :=
                   v_text01
                || --
                  dsp_planilha.campo ( p_conteudo => TO_CHAR ( v_vlr_ipi
                                                             , 'FM999G999G990D00' ) );
            v_text01 :=
                   v_text01
                || --
                  dsp_planilha.campo ( p_conteudo => TO_CHAR ( v_dif_bases
                                                             , 'FM999G999G990D00' ) );
            lib_proc.add ( dsp_planilha.linha ( p_conteudo => v_text01
                                              , p_class => v_class )
                         , ptipo => v_cont_arq + 1 );

            v_contr_plan := v_contr_plan - 1;
        --EXIT WHEN Cr_009%NOTFOUND;
        END LOOP;

        CLOSE cr_009;

        -- IMPRIME RESUMO
        lib_proc.add ( 'Arquivos gerados:'
                     , ptipo => 1 );
        lib_proc.add ( ' '
                     , ptipo => 1 );

        FOR c IN 1 .. v_cont_arq LOOP
            v_text01 :=
                   'Fechamento-'
                || TO_CHAR ( p_data_ini
                           , 'YYYYMMDD' )
                || '-'
                || TO_CHAR ( p_data_fim
                           , 'YYYYMMDD' )
                || '-'
                || LPAD ( c
                        , 2
                        , '0' )
                || '.XLS';

            IF c = v_cont_arq THEN
                v_text01 :=
                       v_text01
                    || ' => '
                    || LPAD ( TO_CHAR ( v_quebra_arq - v_contr_plan
                                      , '9G999G990' )
                            , 11
                            , ' ' )
                    || ' REGISTROS.';
            ELSE
                v_text01 :=
                       v_text01
                    || ' => '
                    || LPAD ( TO_CHAR ( v_quebra_arq
                                      , '9G999G990' )
                            , 11
                            , ' ' )
                    || ' REGISTROS.';
            END IF;

            --
            lib_proc.add ( v_text01
                         , ptipo => 1 );
        END LOOP;
    END gera_relatorio_009;

    FUNCTION executar ( p_relatorio VARCHAR2
                      , p_data_ini DATE
                      , p_data_fim DATE
                      --                     , P_SEP        VARCHAR2
                      , p_exec_all VARCHAR2
                      , p_uf VARCHAR2
                      , p_codestab lib_proc.vartab )
        RETURN INTEGER
    IS
        iestab INTEGER;

        v_sep VARCHAR2 ( 1 );

        v_proc_status NUMBER := 0;
        v_s_proc_status VARCHAR2 ( 16 );
        v_exec_all CHAR ( 1 );

        TYPE rc IS REF CURSOR;

        cr02 rc;

        TYPE cr02_rec IS RECORD
        (
            cod_empresa VARCHAR2 ( 3 )
          , cod_estab VARCHAR2 ( 6 )
          , data_fiscal DATE
          , movto_e_s CHAR ( 1 )
          , num_docfis VARCHAR2 ( 9 )
          , data_emissao DATE
          , dat_operacao DATE
          , usuario VARCHAR2 ( 40 )
        );

        c2 cr02_rec;

        cr03 rc;

        TYPE cr03_rec IS RECORD
        (
            cod_estab VARCHAR2 ( 6 )
          , data_fiscal DATE
          , num_docfis VARCHAR2 ( 9 )
          , serie_docfis VARCHAR2 ( 3 )
          , cod_fis_jur VARCHAR2 ( 14 )
          , cod_cfo VARCHAR2 ( 4 )
          , cod_tributacao NUMBER ( 1, 0 )
          , valor_item NUMBER ( 17, 2 )
          , base_icms NUMBER ( 17, 2 )
          , valor_icms NUMBER ( 17, 2 )
        );

        c003 cr03_rec;

        --        TYPE CR004_REC IS RECORD
        --        (
        --            COD_ESTAB          VARCHAR2(6),
        --            DATA_FISCAL        DATE,
        --            NUM_DOCFIS         VARCHAR2(9),
        --            COD_FIS_JUR        VARCHAR2(14),
        --            VLR_CONTAB_1209    NUMBER,
        --            VLR_CONTAB_5209    NUMBER,
        --            BASE_TRIB_1209     NUMBER,
        --            BASE_TRIB_5209     NUMBER,
        --            BASE_ISEN_1209     NUMBER,
        --            BASE_ISEN_5209     NUMBER,
        --            BASE_OUTRAS_1209   NUMBER,
        --            BASE_OUTRAS_5209   NUMBER,
        --            LINHAS_ENTRADA     NUMBER,
        --            LINHAS_SAIDA       NUMBER
        --        );
        --        C004       CR004_REC;
        c004 c_relatorio_004%ROWTYPE;

        --        TYPE CR005_REC IS RECORD
        --        (
        --            COD_MODELO          VARCHAR2(2),
        --            COD_DOCTO           VARCHAR2(5),
        --            COD_CLASS_DOC_FIS   VARCHAR2(1),
        --            COD_CFO             VARCHAR2(4),
        --            NUM_LINHAS          NUMBER,
        --            TOTAL_ITEM_SEM_CFOP NUMBER,
        --            menor_item_sem_cfop NUMBER,
        --            MAIOR_ITEM_SEM_CFOP NUMBER,
        --            COD_FIS_JUR         VARCHAR2(14),
        --            COD_ESTAB           VARCHAR2(6),
        --            DATA_FISCAL         DATE,
        --            NUM_DOCFIS          VARCHAR2(9)
        --        );
        --        C005       CR005_REC;
        c005 c_relatorio_005%ROWTYPE;
        c006 c_relatorio_006%ROWTYPE;

        TYPE cr101_rec IS RECORD
        (
            codigo_loja NUMBER
          , data_transacao DATE
          , numero_componente NUMBER
          , venda_bruta NUMBER
          , total_canc NUMBER
          , total_descontos NUMBER
          , pfc_liq NUMBER
          , val_liquido NUMBER
        );

        c101 cr101_rec;

        TYPE cr102_rec IS RECORD
        (
            codigo_loja NUMBER
          , data_transacao DATE
          , numero_componente NUMBER
          , ptf_val_bruto NUMBER
          , pct_valor_total_venda NUMBER
          , dif NUMBER
        );

        c102 cr102_rec;

        --Variaveis genericas
        v_bool01 BOOLEAN;
        v_text01 VARCHAR2 ( 256 );
        v_text02 VARCHAR2 ( 256 );
        v_qtde_entrada NUMBER;
        v_qtde_saida NUMBER;
        v_diferenca NUMBER;
        v_class VARCHAR2 ( 1 ) := 'a';
        v_count INTEGER DEFAULT 0;
    BEGIN
        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' ); -- AJ0003

        msafi.dsp_aux.truncatabela_msafi ( 'DSP_PROC_ESTABS' );
        msafi.dsp_aux.truncatabela_msafi ( 'DSP_REL_FIS_01_TMP01' );

        c_proc_9xx := '^' || mcod_empresa || '9[0-9]{2}$';
        c_proc_dep := '^' || mcod_empresa || '9[0-9][1-9]$';
        c_proc_loj :=
               '^'
            || mcod_empresa
            || '[0-8][0-9]{'
            || TO_CHAR ( 5 - LENGTH ( mcod_empresa )
                       , 'FM9' )
            || '}$';
        c_proc_est :=
               '^'
            || mcod_empresa
            || '[0-9]{3,'
            || TO_CHAR ( 6 - LENGTH ( mcod_empresa )
                       , 'FM9' )
            || '}$';
        c_proc_estvd :=
               '^VD[0-9]{3,'
            || TO_CHAR ( 6 - LENGTH ( mcod_empresa )
                       , 'FM9' )
            || '}$';

        v_exec_all := NVL ( p_exec_all, 'N' );

        --V_SEP := P_SEP;
        v_sep := '|';

        mproc_id :=
            lib_proc.new ( 'DSP_RELATORIOS_01_CPROC'
                         , 48
                         , 150 );
        lib_proc.add_tipo ( mproc_id
                          , 1
                          , 'Processo'
                          , 1 );

        IF mcod_empresa IS NULL THEN
            lib_proc.add_log ( 'Código da empresa deve ser informado como parâmetro global.'
                             , 0 );
            lib_proc.close;
            RETURN mproc_id;
        ELSIF v_exec_all = 'N'
          AND p_codestab.COUNT <= 0
          AND p_relatorio <> '004' --Não precisa de estabelecimento para o relatório 4
                                  THEN
            lib_proc.add_log ( 'Estabelecimento é obrigatório'
                             , 0 );
            lib_proc.close;
            RETURN mproc_id;
        ELSIF v_exec_all <> 'N'
          AND p_codestab.COUNT > 0 THEN
            lib_proc.add_log (
                               'Não pode marcar a opção "Fixo todos estabs" e escolher estabelecimentos ao mesmo tempo'
                             , 0
            );
            lib_proc.add_log ( 'Desmarque a opção "Fixo todos estabs" ou os estabelecimentos escolhidos'
                             , 0 );
            lib_proc.close;
            RETURN mproc_id;
        ELSIF p_relatorio IN ( '101'
                             , '102'
                             , '103' )
          AND TO_NUMBER ( TO_CHAR ( SYSDATE
                                  , 'HH24MI' ) ) BETWEEN 500
                                                     AND 1529 THEN
            lib_proc.add_log (
                               'Relatórios que buscam dados diretamente do DataHub só podem executar antes das 05:00 e após as 15:30'
                             , 0
            );
            lib_proc.add_log (    'Favor aguardar o horário válido. Horário atual no servidor: ('
                               || TO_CHAR ( SYSDATE
                                          , 'HH24:MI:SS' )
                               || ')'
                             , 0 );
            lib_proc.close;
            RETURN mproc_id;
        END IF;

        msafi.dsp_control.createprocess ( 'CUST_RELFIS01' --P_I_PROCID            IN VARCHAR2             , --VARCHAR2(16)
                                        , 'CUSTOMIZADO MASTERSAF: RELATORIO FISCAL 01' --P_I_PROC_DESCR        IN VARCHAR2             , --VARCHAR2(64)
                                        , p_data_ini --P_I_DATA_INI          IN DATE     DEFAULT NULL,
                                        , p_data_fim --P_I_DATA_FIM          IN DATE     DEFAULT NULL,
                                        , p_relatorio --P_I_DETALHES1         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , p_codestab.COUNT --P_I_DETALHES2         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , NULL --P_I_DETALHES3         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , NULL --P_I_DETALHES4         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , musuario --P_I_USER              IN VARCHAR2 DEFAULT NULL  --VARCHAR2(64)
                                                   );
        v_proc_status := 1; --EM PROCESSO

        IF v_exec_all = 'N'
       AND p_codestab.COUNT > 0 THEN
            iestab := p_codestab.FIRST;

            WHILE iestab IS NOT NULL LOOP
                INSERT INTO msafi.dsp_proc_estabs
                     VALUES ( p_codestab ( iestab ) );

                iestab := p_codestab.NEXT ( iestab );
            END LOOP;

            COMMIT;
        ELSIF v_exec_all <> 'N' THEN
            INSERT INTO msafi.dsp_proc_estabs
                SELECT cod_estab
                  FROM estabelecimento
                 WHERE cod_empresa = mcod_empresa;

            COMMIT;
        END IF;

        ----------------------------------------------------------------------------------------------------------
        IF p_relatorio = '001' THEN
            --001 - Cupom - Incoerência de datas entre X991 e X993/X994
            loga ( 'Inicio do relatório; Incoerência de datas entre X991 e X993/X994' );

            loga ( 'Iniciando INSERT [' || v_exec_all || ']' );

            IF ( v_exec_all = 'N' ) THEN
                INSERT INTO msafi.dsp_rel_fis_01_tmp01
                    SELECT x2087.cod_empresa
                         , x2087.cod_estab
                         , x2087.cod_caixa_ecf
                         , x991.num_crz
                         , x991.data_fiscal
                         , x991.num_cro
                         , x991.num_coo_ini
                         , x991.num_coo_fim
                         , x993.num_coo
                         , x993.data_emissao
                         , x993.hora_emissao_fim
                      FROM x991_capa_reducao_ecf x991
                         , x993_capa_cupom_ecf x993
                         , x2087_equipamento_ecf x2087
                         , msafi.dsp_proc_estabs dpe
                     WHERE x991.cod_empresa = mcod_empresa
                       AND x991.cod_estab = dpe.cod_estab
                       AND x991.data_fiscal BETWEEN p_data_ini AND p_data_fim
                       AND x991.ident_caixa_ecf = x2087.ident_caixa_ecf
                       AND x993.cod_empresa = x991.cod_empresa
                       AND x993.cod_estab = x991.cod_estab
                       AND x993.ident_caixa_ecf = x991.ident_caixa_ecf
                       AND x993.data_emissao BETWEEN p_data_ini - 3 AND p_data_fim + 3
                       AND ( ( x993.data_emissao <> x991.data_fiscal
                          AND ( ( x991.num_coo_ini <= x991.num_coo_fim
                             AND x993.num_coo BETWEEN x991.num_coo_ini AND x991.num_coo_fim )
                            OR ( x991.num_coo_ini > x991.num_coo_fim
                            AND x2087.num_coo_fim_rei IS NOT NULL
                            AND ( x993.num_coo BETWEEN x991.num_coo_ini AND x2087.num_coo_fim_rei
                              OR x993.num_coo BETWEEN '000000' AND x991.num_coo_fim ) ) ) )
                         OR ( x993.data_emissao = x991.data_fiscal
                         AND NOT ( ( x991.num_coo_ini <= x991.num_coo_fim
                                AND x993.num_coo BETWEEN x991.num_coo_ini AND x991.num_coo_fim )
                               OR ( x991.num_coo_ini > x991.num_coo_fim
                               AND x2087.num_coo_fim_rei IS NOT NULL
                               AND ( x993.num_coo BETWEEN x991.num_coo_ini AND x2087.num_coo_fim_rei
                                 OR x993.num_coo BETWEEN '000000' AND x991.num_coo_fim ) ) ) ) )
                    UNION
                    SELECT x2087.cod_empresa
                         , x2087.cod_estab
                         , x2087.cod_caixa_ecf
                         , x991.num_crz
                         , x991.data_fiscal
                         , x991.num_cro
                         , x991.num_coo_ini
                         , x991.num_coo_fim
                         , x993.num_coo
                         , x993.data_emissao
                         , x993.hora_emissao_fim
                      FROM x991_capa_reducao_ecf x991
                         , x993_capa_cupom_ecf x993
                         , x2087_equipamento_ecf x2087
                         , msafi.dsp_proc_estabs dpe
                     WHERE x991.cod_empresa = mcod_empresa
                       AND x991.cod_estab = dpe.cod_estab
                       AND x991.data_fiscal BETWEEN p_data_ini AND p_data_fim
                       AND x991.ident_caixa_ecf = x2087.ident_caixa_ecf
                       AND x993.cod_empresa = x991.cod_empresa
                       AND x993.cod_estab = x991.cod_estab
                       AND x993.ident_caixa_ecf = x991.ident_caixa_ecf
                       AND x993.data_emissao BETWEEN p_data_ini - 3 AND p_data_fim + 3
                       AND x993.data_emissao = x991.data_fiscal
                       AND NVL ( x991.num_coo_ini, 999999 ) > NVL ( x991.num_coo_fim, -1 );
            ELSE --IF (V_EXEC_ALL = 'N') THEN
                INSERT INTO msafi.dsp_rel_fis_01_tmp01
                    SELECT x2087.cod_empresa
                         , x2087.cod_estab
                         , x2087.cod_caixa_ecf
                         , x991.num_crz
                         , x991.data_fiscal
                         , x991.num_cro
                         , x991.num_coo_ini
                         , x991.num_coo_fim
                         , x993.num_coo
                         , x993.data_emissao
                         , x993.hora_emissao_fim
                      FROM x991_capa_reducao_ecf x991
                         , x993_capa_cupom_ecf x993
                         , x2087_equipamento_ecf x2087
                     WHERE x991.cod_empresa = mcod_empresa
                       AND x991.data_fiscal BETWEEN p_data_ini AND p_data_fim
                       AND x991.ident_caixa_ecf = x2087.ident_caixa_ecf
                       AND x993.cod_empresa = x991.cod_empresa
                       AND x993.cod_estab = x991.cod_estab
                       AND x993.ident_caixa_ecf = x991.ident_caixa_ecf
                       AND x993.data_emissao BETWEEN p_data_ini - 3 AND p_data_fim + 3
                       AND ( ( x993.data_emissao <> x991.data_fiscal
                          AND ( ( x991.num_coo_ini <= x991.num_coo_fim
                             AND x993.num_coo BETWEEN x991.num_coo_ini AND x991.num_coo_fim )
                            OR ( x991.num_coo_ini > x991.num_coo_fim
                            AND x2087.num_coo_fim_rei IS NOT NULL
                            AND ( x993.num_coo BETWEEN x991.num_coo_ini AND x2087.num_coo_fim_rei
                              OR x993.num_coo BETWEEN '000000' AND x991.num_coo_fim ) ) ) )
                         OR ( x993.data_emissao = x991.data_fiscal
                         AND NOT ( ( x991.num_coo_ini <= x991.num_coo_fim
                                AND x993.num_coo BETWEEN x991.num_coo_ini AND x991.num_coo_fim )
                               OR ( x991.num_coo_ini > x991.num_coo_fim
                               AND x2087.num_coo_fim_rei IS NOT NULL
                               AND ( x993.num_coo BETWEEN x991.num_coo_ini AND x2087.num_coo_fim_rei
                                 OR x993.num_coo BETWEEN '000000' AND x991.num_coo_fim ) ) ) ) )
                    UNION
                    SELECT x2087.cod_empresa
                         , x2087.cod_estab
                         , x2087.cod_caixa_ecf
                         , x991.num_crz
                         , x991.data_fiscal
                         , x991.num_cro
                         , x991.num_coo_ini
                         , x991.num_coo_fim
                         , x993.num_coo
                         , x993.data_emissao
                         , x993.hora_emissao_fim
                      FROM x991_capa_reducao_ecf x991
                         , x993_capa_cupom_ecf x993
                         , x2087_equipamento_ecf x2087
                     WHERE x991.cod_empresa = mcod_empresa
                       AND x991.data_fiscal BETWEEN p_data_ini AND p_data_fim
                       AND x991.ident_caixa_ecf = x2087.ident_caixa_ecf
                       AND x993.cod_empresa = x991.cod_empresa
                       AND x993.cod_estab = x991.cod_estab
                       AND x993.ident_caixa_ecf = x991.ident_caixa_ecf
                       AND x993.data_emissao BETWEEN p_data_ini - 3 AND p_data_fim + 3
                       AND x993.data_emissao = x991.data_fiscal
                       AND NVL ( x991.num_coo_ini, 999999 ) > NVL ( x991.num_coo_fim, -1 );
            END IF; --IF (V_EXEC_ALL = 'N') THEN ... else ...

            IF SQL%ROWCOUNT > 0 THEN
                v_bool01 := TRUE;
                loga ( 'Fim do INSERT, [' || SQL%ROWCOUNT || ']' );
            ELSE
                v_bool01 := FALSE;
                loga ( 'Fim do INSERT - 0 linhas!' );
            END IF;

            COMMIT;

            IF NOT v_bool01 THEN
                v_proc_status := 3; --AVISOS
            ELSE
                loga ( 'Imprimindo relatório' );
                lib_proc.add_header ( '001 - Cupom - Incoerência de datas entre X991 e X993/X994'
                                    , 1
                                    , 1 );
                lib_proc.add_header ( ' ' );
                lib_proc.add (
                               '         X2087|    Dados da redução Z             X991|    Dados dos cupons fiscais                        X993|'
                );
                lib_proc.add (
                               'EMP| ESTAB| CX|NUM RZ|DATA FISCAL|   CRO|COOINI|COOFIM|MIN COO|MAX COO|MIN DATA CUPOM|MAX DATA CUPOM|NUM CUPONS|'
                );
                lib_proc.add (
                               '---|------|---|------|-----------|------|------|------|-------|-------|--------------|--------------|----------|'
                );

                --                            DSP|DSP004|  1|123456|12/12/2012 |     2|000123|000321| 000400| 000500|    12/12/2012|    12/12/2012|       100

                FOR c1 IN c_relatorio_01 LOOP
                    v_text01 :=
                        LPAD ( c1.cod_empresa
                             , 3
                             , ' ' );
                    v_text01 :=
                           v_text01
                        || v_sep
                        || NVL ( LPAD ( c1.cod_estab
                                      , 6
                                      , ' ' )
                               , '      ' );
                    v_text01 :=
                           v_text01
                        || v_sep
                        || NVL ( LPAD ( c1.cod_caixa_ecf
                                      , 3
                                      , ' ' )
                               , '   ' );
                    v_text01 :=
                           v_text01
                        || v_sep
                        || NVL ( LPAD ( c1.num_crz
                                      , 6
                                      , ' ' )
                               , '      ' );
                    v_text01 :=
                           v_text01
                        || v_sep
                        || NVL ( LPAD ( TO_CHAR ( c1.data_fiscal
                                                , 'DD/MM/YYYY' )
                                      , 11
                                      , ' ' )
                               , '           ' );
                    v_text01 :=
                           v_text01
                        || v_sep
                        || NVL ( LPAD ( c1.num_cro
                                      , 6
                                      , ' ' )
                               , '      ' );
                    v_text01 :=
                           v_text01
                        || v_sep
                        || NVL ( LPAD ( c1.num_coo_ini
                                      , 6
                                      , ' ' )
                               , '      ' );
                    v_text01 :=
                           v_text01
                        || v_sep
                        || NVL ( LPAD ( c1.num_coo_fim
                                      , 6
                                      , ' ' )
                               , '      ' );
                    v_text01 :=
                           v_text01
                        || v_sep
                        || NVL ( LPAD ( c1.menor_num_cupom
                                      , 7
                                      , ' ' )
                               , '       ' );
                    v_text01 :=
                           v_text01
                        || v_sep
                        || NVL ( LPAD ( c1.maior_num_cupom
                                      , 7
                                      , ' ' )
                               , '       ' );
                    v_text01 :=
                           v_text01
                        || v_sep
                        || NVL ( LPAD ( TO_CHAR ( c1.menor_data_cupom
                                                , 'DD/MM/YYYY' )
                                      , 14
                                      , ' ' )
                               , '              ' );
                    v_text01 :=
                           v_text01
                        || v_sep
                        || NVL ( LPAD ( TO_CHAR ( c1.maior_data_cupom
                                                , 'DD/MM/YYYY' )
                                      , 14
                                      , ' ' )
                               , '              ' );
                    v_text01 :=
                           v_text01
                        || v_sep
                        || NVL ( LPAD ( TO_CHAR ( c1.num_cupons
                                                , 'FM999999' )
                                      , 10
                                      , ' ' )
                               , '          ' );
                    v_text01 := v_text01 || v_sep;
                    lib_proc.add ( v_text01 );
                END LOOP;

                loga ( 'Fim do relatório, limpando temporária' );
                msafi.dsp_aux.truncatabela_msafi ( 'DSP_REL_FIS_01_TMP01' );
                COMMIT;
                v_proc_status := 2; --SUCESSO
            END IF; --IF not V_BOOL01 THEN
        ----------------------------------------------------------------------------------------------------------
        ELSIF p_relatorio = '002' THEN
            --002 - Documentos fiscais com data futura
            IF v_exec_all = 'N'
           AND p_codestab.COUNT > 0 THEN
                loga ( 'Abrindo cursor A [' || v_exec_all || '][' || p_codestab.COUNT || ']' );

                --Abre o cursor para determinados estabelecimentos
                OPEN cr02 FOR
                    SELECT a.cod_empresa
                         , a.cod_estab
                         , a.data_fiscal
                         , a.movto_e_s
                         , a.num_docfis
                         , a.data_emissao
                         , a.dat_operacao
                         , a.usuario
                      FROM x07_docto_fiscal a
                         , msafi.dsp_proc_estabs b
                     WHERE a.cod_empresa = mcod_empresa
                       AND a.cod_estab = b.cod_estab
                       AND a.data_fiscal > SYSDATE;
            ELSE
                loga ( 'Abrindo cursor B [' || v_exec_all || '][' || p_codestab.COUNT || ']' );

                --Abre o cursor sem critério de estabelecimentos
                OPEN cr02 FOR
                    SELECT a.cod_empresa
                         , a.cod_estab
                         , a.data_fiscal
                         , a.movto_e_s
                         , a.num_docfis
                         , a.data_emissao
                         , a.dat_operacao
                         , a.usuario
                      FROM x07_docto_fiscal a
                     WHERE a.cod_empresa = mcod_empresa
                       AND a.data_fiscal > SYSDATE;
            END IF; --IF V_EXEC_ALL = 'N' AND P_CODESTAB.COUNT > 0 THEN


            loga ( 'Imprimindo relatório' );
            lib_proc.add_header ( '002 - Documentos fiscais com data futura'
                                , 1
                                , 1 );
            lib_proc.add_header ( ' ' );
            lib_proc.add ( 'EMP| ESTAB|DATA FISCAL|E/S| NUM DOC |DT  EMISSAO|DT OPERACAO|USUARIO' );
            lib_proc.add ( '---|------|-----------|---|---------|-----------|-----------|-----------------------' );

            --                        DSP|DSP004|12/12/2012 |  1|000000123|12/12/2012 |12/12/2012 |

            LOOP
                FETCH cr02
                    INTO c2;

                EXIT WHEN cr02%NOTFOUND;
                v_text01 :=
                    LPAD ( c2.cod_empresa
                         , 3
                         , ' ' );
                v_text01 :=
                       v_text01
                    || v_sep
                    || NVL ( LPAD ( c2.cod_estab
                                  , 6
                                  , ' ' )
                           , '      ' );
                v_text01 :=
                       v_text01
                    || v_sep
                    || NVL ( LPAD ( TO_CHAR ( c2.data_fiscal
                                            , 'DD/MM/YYYY' )
                                  , 11
                                  , ' ' )
                           , '           ' );
                v_text01 :=
                       v_text01
                    || v_sep
                    || NVL ( LPAD ( c2.movto_e_s
                                  , 3
                                  , ' ' )
                           , '   ' );
                v_text01 :=
                       v_text01
                    || v_sep
                    || NVL ( LPAD ( c2.num_docfis
                                  , 9
                                  , ' ' )
                           , '         ' );
                v_text01 :=
                       v_text01
                    || v_sep
                    || NVL ( LPAD ( TO_CHAR ( c2.data_emissao
                                            , 'DD/MM/YYYY' )
                                  , 11
                                  , ' ' )
                           , '           ' );
                v_text01 :=
                       v_text01
                    || v_sep
                    || NVL ( LPAD ( TO_CHAR ( c2.dat_operacao
                                            , 'DD/MM/YYYY' )
                                  , 11
                                  , ' ' )
                           , '           ' );
                v_text01 := v_text01 || v_sep || NVL ( c2.usuario, ' ' );
                --V_TEXT01 := V_TEXT01 || V_SEP;
                lib_proc.add ( v_text01 );
            END LOOP;

            CLOSE cr02;

            loga ( 'Fim' );
            v_proc_status := 2; --SUCESSO
        ----------------------------------------------------------------------------------------------------------
        ELSIF p_relatorio = '003' THEN
            --003 - Resumo por CFOP por tabela X - relatorio LENTO
            --Resumo por CFOP por tabela X - relatorio LENTO
            IF v_exec_all = 'N'
           AND p_codestab.COUNT > 0 THEN
                loga ( 'Abrindo cursor A [' || v_exec_all || '][' || p_codestab.COUNT || ']' );

                --Abre o cursor para determinados estabelecimentos
                OPEN cr03 FOR
                    SELECT   a.cod_estab
                           , a.data_fiscal
                           , a.num_docfis
                           , a.serie_docfis
                           , d.cod_fis_jur
                           , c.cod_cfo
                           , b.cod_tributacao
                           , SUM ( a.vlr_item ) valor_item
                           , SUM ( b.vlr_base ) base_icms
                           , SUM ( e.vlr_tributo ) valor_icms
                        FROM x08_itens_merc a
                           , x08_base_merc b
                           , x2012_cod_fiscal c
                           , x04_pessoa_fis_jur d
                           , x08_trib_merc e
                           , msafi.dsp_proc_estabs dpe
                       WHERE a.cod_empresa = mcod_empresa
                         AND a.cod_estab = dpe.cod_estab
                         AND a.cod_estab NOT LIKE mcod_empresa || '9%'
                         AND a.data_fiscal BETWEEN p_data_ini AND p_data_fim
                         AND a.cod_empresa = b.cod_empresa
                         AND a.cod_empresa = e.cod_empresa
                         AND a.cod_estab = b.cod_estab
                         AND a.cod_estab = e.cod_estab
                         AND a.data_fiscal = b.data_fiscal
                         AND a.data_fiscal = e.data_fiscal
                         AND a.movto_e_s = b.movto_e_s
                         AND a.movto_e_s = e.movto_e_s
                         AND a.norm_dev = b.norm_dev
                         AND a.norm_dev = e.norm_dev
                         AND a.ident_docto = b.ident_docto
                         AND a.ident_docto = e.ident_docto
                         AND a.ident_fis_jur = b.ident_fis_jur
                         AND a.ident_fis_jur = e.ident_fis_jur
                         AND a.num_docfis = b.num_docfis
                         AND a.num_docfis = e.num_docfis
                         AND a.serie_docfis = b.serie_docfis
                         AND a.serie_docfis = e.serie_docfis
                         AND a.sub_serie_docfis = b.sub_serie_docfis
                         AND a.sub_serie_docfis = e.sub_serie_docfis
                         AND a.discri_item = b.discri_item
                         AND a.discri_item = e.discri_item
                         AND a.ident_fis_jur = e.ident_fis_jur
                         AND a.ident_cfo = c.ident_cfo
                         AND a.ident_fis_jur = d.ident_fis_jur
                         AND c.cod_cfo = 1409
                         AND b.vlr_base > 0
                         AND b.cod_tributo = 'ICMS'
                         AND e.cod_tributo = 'ICMS'
                    GROUP BY a.cod_estab
                           , a.data_fiscal
                           , a.num_docfis
                           , a.serie_docfis
                           , d.cod_fis_jur
                           , cod_cfo
                           , b.cod_tributacao
                    ORDER BY a.cod_estab
                           , a.data_fiscal;
            ELSE
                loga ( 'Abrindo cursor B [' || v_exec_all || '][' || p_codestab.COUNT || ']' );

                --Abre o cursor sem critério de estabelecimentos
                OPEN cr03 FOR
                    SELECT   a.cod_estab
                           , a.data_fiscal
                           , a.num_docfis
                           , a.serie_docfis
                           , d.cod_fis_jur
                           , c.cod_cfo
                           , b.cod_tributacao
                           , SUM ( a.vlr_item ) valor_item
                           , SUM ( b.vlr_base ) base_icms
                           , SUM ( e.vlr_tributo ) valor_icms
                        FROM x08_itens_merc a
                           , x08_base_merc b
                           , x2012_cod_fiscal c
                           , x04_pessoa_fis_jur d
                           , x08_trib_merc e
                       WHERE a.cod_empresa = mcod_empresa
                         AND a.cod_estab NOT LIKE mcod_empresa || '9%'
                         AND a.data_fiscal BETWEEN p_data_ini AND p_data_fim
                         AND a.cod_empresa = b.cod_empresa
                         AND a.cod_empresa = e.cod_empresa
                         AND a.cod_estab = b.cod_estab
                         AND a.cod_estab = e.cod_estab
                         AND a.data_fiscal = b.data_fiscal
                         AND a.data_fiscal = e.data_fiscal
                         AND a.movto_e_s = b.movto_e_s
                         AND a.movto_e_s = e.movto_e_s
                         AND a.norm_dev = b.norm_dev
                         AND a.norm_dev = e.norm_dev
                         AND a.ident_docto = b.ident_docto
                         AND a.ident_docto = e.ident_docto
                         AND a.ident_fis_jur = b.ident_fis_jur
                         AND a.ident_fis_jur = e.ident_fis_jur
                         AND a.num_docfis = b.num_docfis
                         AND a.num_docfis = e.num_docfis
                         AND a.serie_docfis = b.serie_docfis
                         AND a.serie_docfis = e.serie_docfis
                         AND a.sub_serie_docfis = b.sub_serie_docfis
                         AND a.sub_serie_docfis = e.sub_serie_docfis
                         AND a.discri_item = b.discri_item
                         AND a.discri_item = e.discri_item
                         AND a.ident_fis_jur = e.ident_fis_jur
                         AND a.ident_cfo = c.ident_cfo
                         AND a.ident_fis_jur = d.ident_fis_jur
                         AND c.cod_cfo = 1409
                         AND b.vlr_base > 0
                         AND b.cod_tributo = 'ICMS'
                         AND e.cod_tributo = 'ICMS'
                    GROUP BY a.cod_estab
                           , a.data_fiscal
                           , a.num_docfis
                           , a.serie_docfis
                           , d.cod_fis_jur
                           , cod_cfo
                           , b.cod_tributacao
                    ORDER BY a.cod_estab
                           , a.data_fiscal;
            END IF; --IF V_EXEC_ALL = 'N' AND P_CODESTAB.COUNT > 0 THEN


            loga ( 'Imprimindo relatório' );
            lib_proc.add_header ( '003 - Resumo por CFOP por tabela X - relatorio LENTO'
                                , 1
                                , 1 );
            lib_proc.add_header ( ' ' );
            lib_proc.add (
                           ' ESTAB|DATA FISCAL| NUM DOC | SR|   COD_FIS_JUR|CFOP|TRIB|   VLR ITEM|BASE ICMS| VLR ICMS'
            );
            lib_proc.add (
                           '------|-----------|---------|---|--------------|----|----|-----------|---------|---------'
            );

            --                        DSP004|12/12/2012 |000000123|  1|F00000000004-1|1234|   1|12345678,01|123456,89|123456,89

            LOOP
                FETCH cr03
                    INTO c003;

                EXIT WHEN cr03%NOTFOUND;
                v_text01 :=
                    NVL ( LPAD ( c003.cod_estab
                               , 6
                               , ' ' )
                        , '      ' );
                v_text01 :=
                       v_text01
                    || v_sep
                    || NVL ( LPAD ( TO_CHAR ( c003.data_fiscal
                                            , 'DD/MM/YYYY' )
                                  , 11
                                  , ' ' )
                           , '           ' );
                v_text01 :=
                       v_text01
                    || v_sep
                    || NVL ( LPAD ( c003.num_docfis
                                  , 9
                                  , ' ' )
                           , '         ' );
                v_text01 :=
                       v_text01
                    || v_sep
                    || NVL ( LPAD ( c003.serie_docfis
                                  , 3
                                  , ' ' )
                           , '   ' );
                v_text01 :=
                       v_text01
                    || v_sep
                    || NVL ( LPAD ( c003.cod_fis_jur
                                  , 14
                                  , ' ' )
                           , '              ' );
                v_text01 :=
                       v_text01
                    || v_sep
                    || NVL ( LPAD ( c003.cod_cfo
                                  , 4
                                  , ' ' )
                           , '    ' );
                v_text01 :=
                       v_text01
                    || v_sep
                    || NVL ( LPAD ( c003.cod_tributacao
                                  , 4
                                  , ' ' )
                           , '    ' );
                v_text01 :=
                       v_text01
                    || v_sep
                    || NVL ( LPAD ( c003.valor_item
                                  , 11
                                  , ' ' )
                           , '           ' );
                v_text01 :=
                       v_text01
                    || v_sep
                    || NVL ( LPAD ( c003.base_icms
                                  , 9
                                  , ' ' )
                           , '         ' );
                v_text01 :=
                       v_text01
                    || v_sep
                    || NVL ( LPAD ( c003.valor_icms
                                  , 9
                                  , ' ' )
                           , '         ' );
                --V_TEXT01 := V_TEXT01 || V_SEP;
                lib_proc.add ( v_text01 );
            END LOOP;

            loga ( 'Fim' );
            v_proc_status := 2; --SUCESSO
        ----------------------------------------------------------------------------------------------------------
        ELSIF p_relatorio = '004' THEN
            --004 - Divergência de Devolução das lojas para CDs
            loga ( 'Imprimindo relatório' );
            lib_proc.add_header ( '004 - Divergência de Devolução das lojas para CDs (CFOPs 1209,2209 / 5209,6209)'
                                , 1
                                , 1 );
            lib_proc.add_header ( ' ' );
            lib_proc.add (
                           '                  CAMPOS CHAVE            |       Valores       |       DIFERENÇAS DE BASES      | # LINHAS|'
            );
            lib_proc.add (
                           ' ESTAB|      DATA|NUM DOCTO|   COD FIS JUR|   ENTRADA|     SAIDA|    BASE 1|    BASE 2|    BASE 3|ENTR|SAID|'
            );
            lib_proc.add (
                           '------|----------|---------|--------------|----------|----------|----------|----------|----------|----|----|'
            );
            --                        DSP901|01/01/2012|555123456|        DSP004|1234567,89|1234567,89|1234567,89|1234567,89|1234567,89| 350| 350|

            loga ( 'Abrindo cursor' );
            loga ( 'Este relatório ignora parâmetros de estabelecimentos' );

            --relatorio para estabelecimentos específicos
            OPEN c_relatorio_004 ( mcod_empresa
                                 , p_data_ini
                                 , p_data_fim );

            LOOP
                FETCH c_relatorio_004
                    INTO c004;

                EXIT WHEN c_relatorio_004%NOTFOUND;

                loga (
                          'EXEC MSAFI.PRC_MSAF_PS_NF_SAIDA('
                       || ',P_CARGAS=>0,P_VIRA_NF_SP=>1,P_VIRA_CAGADAS=>1,P_VIRA_IGNORA_PS=>1'
                       || ',P_COD_ESTAB=>'''
                       || c004.cod_estab_saida
                       || ''',P_NF_BRL_ID=>'''
                       || c004.num_controle_docto_saida
                       || '''); --'
                     , FALSE
                );
                --LOGA('FETCH');

                v_text01 :=
                    fazcampo ( c004.cod_estab
                             , ' '
                             , 6 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( c004.data_fiscal
                                , 'DD/MM/YYYY'
                                , ' '
                                , 10 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( c004.num_docfis
                                , ' '
                                , 9 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( c004.cod_fis_jur
                                , ' '
                                , 14 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( c004.vlr_contab_1209
                                , 'FM9999990D00'
                                , ' '
                                , 10 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( c004.vlr_contab_5209
                                , 'FM9999990D00'
                                , ' '
                                , 10 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( c004.base_trib_5209 - c004.base_trib_1209
                                , 'FM9999990D00'
                                , ' '
                                , 10 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( c004.base_isen_5209 - c004.base_isen_1209
                                , 'FM9999990D00'
                                , ' '
                                , 10 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( c004.base_outras_5209 - c004.base_outras_1209
                                , 'FM9999990D00'
                                , ' '
                                , 10 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( c004.linhas_entrada
                                , 'FM9990'
                                , ' '
                                , 4 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( c004.linhas_saida
                                , 'FM9990'
                                , ' '
                                , 4 );
                v_text01 := v_text01 || v_sep;
                lib_proc.add ( v_text01 );
            END LOOP;

            loga ( 'Fim do relatório!' );
            loga ( 'CLOSE' );

            CLOSE c_relatorio_004;

            v_proc_status := 2; --SUCESSO
        ----------------------------------------------------------------------------------------------------------
        ELSIF p_relatorio = '005' THEN
            --005 - NFs potencialmente problematicas
            loga ( 'Imprimindo relatório' );
            lib_proc.add_header ( '005 - NFs potencialmente problematicas'
                                , 1
                                , 1 );
            lib_proc.add_header ( ' ' );
            lib_proc.add (
                           '                  CAMPOS CHAVE            |    Campos da capa                  |  Linhas     | Item sem CFOP'
            );
            lib_proc.add (
                           ' ESTAB|      DATA|NUM DOCTO|   COD FIS JUR|COD_MODELO|COD_DOCTO|ClasDocFis|CFOP|Total|SemCFOP|Menor|Maior'
            );
            lib_proc.add (
                           '------|----------|---------|--------------|----------|---------|----------|----|-----|-------|-----|-----'
            );
            --                        DSP901|01/01/2012|555123456|        DSP004|        55|      NFF|         1|    |  300|      2|   15|  145|

            loga ( 'Abrindo cursor' );
            loga ( 'Este relatório ignora parâmetros de estabelecimentos' );

            --relatorio para estabelecimentos específicos
            OPEN c_relatorio_005 ( p_data_ini
                                 , p_data_fim );

            LOOP
                FETCH c_relatorio_005
                    INTO c005;

                --LOGA('FETCH');
                EXIT WHEN c_relatorio_005%NOTFOUND;

                v_text01 :=
                    fazcampo ( c005.cod_estab
                             , ' '
                             , 6 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( c005.data_fiscal
                                , 'DD/MM/YYYY'
                                , ' '
                                , 10 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( c005.num_docfis
                                , ' '
                                , 9 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( c005.cod_fis_jur
                                , ' '
                                , 14 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( c005.cod_modelo
                                , ' '
                                , 10 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( c005.cod_docto
                                , ' '
                                , 9 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( c005.cod_class_doc_fis
                                , ' '
                                , 10 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( c005.cod_cfo
                                , ' '
                                , 4 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( c005.num_linhas
                                , 'FM99999'
                                , ' '
                                , 5 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( c005.total_item_sem_cfop
                                , 'FM9999999'
                                , ' '
                                , 7 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( c005.menor_item_sem_cfop
                                , 'FM99999'
                                , ' '
                                , 5 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( c005.maior_item_sem_cfop
                                , 'FM99999'
                                , ' '
                                , 5 );
                v_text01 := v_text01 || v_sep;
                lib_proc.add ( v_text01 );
            END LOOP;

            loga ( 'Fim do relatório!' );
            loga ( 'CLOSE' );

            CLOSE c_relatorio_005;

            v_proc_status := 2; --SUCESSO
        ----------------------------------------------------------------------------------------------------------
        ELSIF p_relatorio = '006' THEN
            --006 - NFs alteradas fora de periodo no PS
            loga ( 'Imprimindo relatório' );
            lib_proc.add_header ( '006 - NFs alteradas fora de periodo no PS'
                                , 1
                                , 1 );
            lib_proc.add_header ( ' ' );
            lib_proc.add ( ' ESTAB| DT FISCAL| DT ALTER |   NUM NF|   COD FIS JUR|     VALOR|   BU| ID PEOPLE|STATUS' );
            lib_proc.add ( '------|----------|----------|---------|--------------|----------|-----|----------|------' );
            --                        DSP901|01/01/2012|01/01/2012|001234567|        DSP004|1234567,89|VD903|0000012457|  CNFM

            loga ( 'Abrindo cursor' );
            loga ( 'Este relatório ignora parâmetros de estabelecimentos' );

            --relatorio para estabelecimentos específicos
            OPEN c_relatorio_006 ( p_data_ini
                                 , p_data_fim );

            LOOP
                FETCH c_relatorio_006
                    INTO c006;

                --LOGA('FETCH');
                EXIT WHEN c_relatorio_006%NOTFOUND;

                v_text01 :=
                    fazcampo ( c006.cod_estab
                             , ' '
                             , 6 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( c006.data_fiscal
                                , 'DD/MM/YYYY'
                                , ' '
                                , 10 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( c006.data_alteracao
                                , 'DD/MM/YYYY'
                                , ' '
                                , 10 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( c006.num_docfis
                                , ' '
                                , 9 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( c006.cod_fis_jur
                                , ' '
                                , 14 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( c006.x07_vlr_tot_nota
                                , 'FM9999990D00'
                                , ' '
                                , 10 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( c006.business_unit
                                , ' '
                                , 5 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( c006.nf_brl_id
                                , ' '
                                , 10 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( c006.nf_status_bbl
                                , ' '
                                , 6 );
                v_text01 := v_text01 || v_sep;
                lib_proc.add ( v_text01 );
            END LOOP;

            loga ( 'Fim do relatório!' );
            loga ( 'CLOSE' );

            CLOSE c_relatorio_006;

            v_proc_status := 2; --SUCESSO
        ----------------------------------------------------------------------------------------------------------
        ELSIF p_relatorio = '007' THEN
            --UNION SELECT ''007'',''007 - Validação de Chave de Acesso'' FROM DUAL
            loga ( 'Imprimindo relatório' );
            loga ( 'Os valores possíveis para a coluna de VALCHAVE (validação da Chave de Acesso da NFe) são:' );
            loga ( 'OK' );
            loga ( '(BRANCO) - chave de acesso não preenchida' );
            loga ( 'Inv(??) - Chave Inválida(Motivo); motivos:' );
            loga ( 'TM - Tamanho da chave - deve ter 44 dígitos' );
            loga ( 'UF - Estado - código do estado de emissão (código do IBGE)  (posição:  1, tamanho:  2)' );
            loga ( 'DT - Data de emissão                                        (posição:  3, tamanho:  4)' );
            loga ( 'CJ - CNPJ do emitente                                       (posição:  7, tamanho: 14)' );
            loga ( 'MD - Código do modelo da NF                                 (posição: 21, tamanho:  2)' );
            loga ( 'SR - Série da NF                                            (posição: 23, tamanho:  3)' );
            loga ( 'NM - Número da NF                                           (posição: 26, tamanho:  9)' );
            loga ( 'Forma de emissão da NF não é validada                       (posição: 35, tamanho:  1)' );
            loga ( 'Código numérico que compõe a Chave de Acesso não é validada (posição: 36, tamanho:  8)' );
            loga ( 'DV - Dígito verificador da NF                               (posição: 44, tamanho:  1)' );

            --MPROC_ID := LIB_PROC.new('DPSP_VALIDACAO_CHAVE ACESSO', 48, 150);



            lib_proc.add_tipo ( mproc_id
                              , 99
                              ,    mcod_empresa
                                || '_'
                                || TO_CHAR ( p_data_fim
                                           , 'YYYYMM' )
                                || '_VALIDACAO_CHAVE_DE_ACESSO.XLS'
                              , 2 );

            lib_proc.add ( dsp_planilha.header
                         , ptipo => 99 );
            lib_proc.add ( dsp_planilha.tabela_inicio
                         , ptipo => 99 );

            lib_proc.add ( dsp_planilha.linha ( p_conteudo => dsp_planilha.campo ( '001 - VALIDAÇÃO CHAVE DE ACESSO'
                                                                                 , p_custom => 'COLSPAN=10' )
                                              , p_class => 'h' )
                         , ptipo => 99 );
            lib_proc.add ( dsp_planilha.linha (
                                                p_conteudo =>    dsp_planilha.campo ( 'ESTAB' )
                                                              || dsp_planilha.campo ( 'UF_ESTAB' )
                                                              || dsp_planilha.campo ( 'DATA' )
                                                              || dsp_planilha.campo ( 'E/S' )
                                                              || dsp_planilha.campo ( 'DOC FIS' )
                                                              || dsp_planilha.campo ( 'SER' )
                                                              || dsp_planilha.campo ( 'COD FIS JUR' )
                                                              || dsp_planilha.campo ( 'UF_FISJUR' )
                                                              || dsp_planilha.campo ( 'ID PEOPLESOFT' )
                                                              || dsp_planilha.campo ( 'VALIDAÇÂO CHAVE DE ACESSO' )
                                                              || dsp_planilha.campo ( 'CHAVE DE ACESSO' )
                                              , p_class => 'h'
                           )
                         , ptipo => 99 );

            loga ( 'Abrindo cursor' );

            FOR cr_007 IN c_relatorio_007 ( p_data_ini
                                          , p_data_fim
                                          , v_exec_all ) LOOP
                IF v_class = 'a' THEN
                    v_class := 'b';
                ELSE
                    v_class := 'a';
                END IF;

                ---
                IF UPPER ( SUBSTR ( cr_007.chave_acesso_ok
                                  , 1
                                  , 3 ) ) = 'INV' THEN
                    v_text02 :=
                           SUBSTR ( cr_007.chave_acesso_ok
                                  , 1
                                  , LENGTH ( cr_007.chave_acesso_ok ) - 1 )
                        || ')';
                ELSE
                    v_text02 := cr_007.chave_acesso_ok;
                END IF;

                v_text01 :=
                    dsp_planilha.linha (
                                         p_conteudo =>    dsp_planilha.campo ( cr_007.cod_estab )
                                                       || dsp_planilha.campo ( cr_007.cod_estado )
                                                       || dsp_planilha.campo ( cr_007.data_fiscal )
                                                       || dsp_planilha.campo ( cr_007.movto_e_s )
                                                       || dsp_planilha.campo (
                                                                               dsp_planilha.texto ( cr_007.num_docfis )
                                                          )
                                                       || dsp_planilha.campo ( cr_007.serie_docfis )
                                                       || dsp_planilha.campo ( cr_007.forne_cliente )
                                                       || dsp_planilha.campo ( cr_007.uf_fisjur )
                                                       || dsp_planilha.campo (
                                                                               dsp_planilha.texto (
                                                                                                    cr_007.num_controle_docto
                                                                               )
                                                          )
                                                       || dsp_planilha.campo ( dsp_planilha.texto ( v_text02 ) )
                                                       || dsp_planilha.campo (
                                                                               dsp_planilha.texto (
                                                                                                    cr_007.chave_de_acesso
                                                                               )
                                                          )
                                       , p_class => v_class
                    );

                lib_proc.add ( v_text01
                             , ptipo => 99 );
            END LOOP; --FOR CR_007 IN C_RELATORIO_007(P_DATA_INI,P_DATA_FIM,V_EXEC_ALL)

            lib_proc.add ( dsp_planilha.tabela_fim
                         , ptipo => 99 );

            loga ( 'Fim do relatório!' );
            v_proc_status := 2; --SUCESSO
        ----------------------------------------------------------------------------------------------------------
        ELSIF p_relatorio = '008' THEN
            --UNION SELECT ''008'',''008 - Relatório de diferenças de ICMS x alíquota'' FROM DUAL
            loga ( 'Imprimindo relatório - 008 - Relatório de diferenças de ICMS x alíquota' );
            loga ( ' ' );

            lib_proc.add_header ( '001 - Validação de Chave de Acesso'
                                , 1
                                , 1 );
            lib_proc.add_header ( ' ' );
            lib_proc.add (
                           ' ESTAB|       DATA|E/S| DOC FIS |Ser|CFOP|   COD FIS JUR|ValorTot NF| ID PeopleSoft|V Contab It|Trib ICMS|Aliq|  Base1  |  Base2  |  Base3  |  Base4  |Razao Social'
            );
            lib_proc.add (
                           '------| ----------|---|---------|---|----|--------------|-----------|--------------|-----------|---------|----|---------|---------|---------|---------|------------'
            );
            --                        DSP900| 01/01/2012|  1|000123456|  1|1409|06191540000186|12312312.45| VA01234567890|12312312.45|312312.45|  12|312312.45|312312.45|312312.45|312312.45|Fulano de tal
            loga ( 'Abrindo cursor' );

            FOR cr_008 IN c_relatorio_008 ( p_data_ini
                                          , p_data_fim
                                          , v_exec_all ) LOOP
                v_text01 :=
                    fazcampo ( cr_008.cod_estab
                             , ' '
                             , 6 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_008.data_fiscal
                                , 'DD/MM/YYYY'
                                , ' '
                                , 11 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_008.movto_e_s
                                , ' '
                                , 3 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_008.num_docfis
                                , ' '
                                , 9 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_008.serie_docfis
                                , ' '
                                , 3 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_008.cod_cfo
                                , ' '
                                , 4 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_008.cod_fis_jur
                                , ' '
                                , 14 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_008.vlr_tot_nota
                                , 'FM99999990D00'
                                , ' '
                                , 11 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_008.num_controle_docto
                                , ' '
                                , 14 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_008.vlr_contab_item
                                , 'FM99999990D00'
                                , ' '
                                , 11 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_008.vlr_tributo_icms
                                , 'FM999990D00'
                                , ' '
                                , 9 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( RTRIM ( TO_CHAR ( cr_008.aliq_tributo_icms
                                                  , 'FM99D99' )
                                        , '.,' )
                                , ' '
                                , 4 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_008.vlr_base_icms_1
                                , 'FM999990D00'
                                , ' '
                                , 9 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_008.vlr_base_icms_2
                                , 'FM999990D00'
                                , ' '
                                , 9 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_008.vlr_base_icms_3
                                , 'FM999990D00'
                                , ' '
                                , 9 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_008.vlr_base_icms_4
                                , 'FM999990D00'
                                , ' '
                                , 9 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_008.razao_social
                                , ' '
                                , 40 );
                lib_proc.add ( v_text01 );
            END LOOP; --FOR CR_008 IN C_RELATORIO_008(P_DATA_INI,P_DATA_FIM,V_EXEC_ALL)

            lib_proc.add (
                           '------| ----------|---|---------|---|----|--------------|-----------|--------------|-----------|---------|----|---------|---------|---------|---------|------------'
            );
            lib_proc.add ( ' ' );
            lib_proc.add ( 'Fim do relatório' );

            loga ( 'Fim do relatório!' );
            v_proc_status := 2; --SUCESSO
        ----------------------------------------------------------------------------------------------------------
        ELSIF p_relatorio = '009' THEN
            --UNION SELECT ''009'',''009 - Relatório de Fechamento Fiscal'' FROM DUAL
            loga ( 'Imprimindo relatório - 009 - Relatório de Fechamento Fiscal' );
            loga ( ' ' );
            gera_relatorio_009 ( p_data_ini
                               , p_data_fim
                               , v_exec_all ); -- AJ0004
            --lib_proc.add(' ');
            --lib_proc.add('Fim do relatório');

            loga ( 'Fim do relatório!' );
            v_proc_status := 2; --SUCESSO
        ----------------------------------------------------------------------------------------------------------

        ELSIF p_relatorio = '010' THEN
            -- RELATORIO: SELECT ''010'',''010 - Relatório por Finalidade IST - Depósitos'' FROM DUAL
            loga ( 'Imprimindo relatório - 010 - Relatório por Finalidade IST - Depósitos' );
            loga ( ' ' );
            lib_proc.add (
                           ' ESTAB| DT FISCAL|   NUM NF|E/S|CFOP|    COD PRODUTO|     NBM|FIN|    BASE TRIB|ALIQ ICMS|   VALOR ICMS|'
            );
            lib_proc.add (
                           '------|----------|---------|---|----|---------------|--------|---|-------------|---------|-------------|'
            );
            --            DSP900|01/08/2014|000402419|  9|1403|      123456789|12345678|IST|12.345.678,10|12.345,10|12.345.678,10|
            loga ( 'Abrindo cursor' );

            FOR cr_010 IN c_relatorio_010 ( p_data_ini
                                          , p_data_fim
                                          , v_exec_all ) LOOP
                v_text01 :=
                    fazcampo ( cr_010.cod_estab
                             , ' '
                             , 6 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_010.data_fiscal
                                , 'DD/MM/YYYY'
                                , ' '
                                , 10 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_010.numero_nf
                                , ' '
                                , 9 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_010.saida_entrada
                                , ' '
                                , 3 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_010.cfop
                                , ' '
                                , 4 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_010.produto
                                , ' '
                                , 15 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_010.nbm
                                , ' '
                                , 8 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_010.finalidade
                                , ' '
                                , 3 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_010.base_tributada
                                , 'FM99999990D00'
                                , ' '
                                , 13 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_010.aliq_tributo_icms
                                , 'FM999990D00'
                                , ' '
                                , 7 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_010.valor_icms
                                , 'FM99999990D00'
                                , ' '
                                , 13 );
                lib_proc.add ( v_text01 );
            END LOOP;

            lib_proc.add (
                           '------|----------|---------|---|----|---------------|--------|---|-------------|---------|-------------|'
            );
            lib_proc.add ( ' ' );
            lib_proc.add ( 'Fim do relatório' );

            loga ( 'Fim do relatório!' );
            v_proc_status := 2; --SUCESSO
        ----------------------------------------------------------------------------------------------------------
        ELSIF p_relatorio = '011' THEN
            -- RELATORIO: SELECT ''011'',''011 - Relatório Controle de Apuração de ICMS'' FROM DUAL
            loga ( 'Imprimindo relatório - 011 - Relatório Controle de Apuração de ICMS' );
            loga ( ' ' );
            lib_proc.add (
                           ' ESTAB|SALD ANTERIOR| CRED IMPOSTO|  OUTROS CRED|  ESTORNO DEB|     DEDUCOES|TOTAL CREDITO|  DEB IMPOSTO|   OUTROS DEB| ESTORNO CRED| TOTAL DEBITO|SALD CRED DEB|'
            );
            lib_proc.add (
                           '------|-------------|-------------|-------------|-------------|-------------|-------------|-------------|-------------|-------------|-------------|-------------|'
            );
            --            DSP900|12.345.678,10|12.345.678,10|12.345.678,10|12.345.678,10|12.345.678,10|12.345.678,10|12.345.678,10|12.345.678,10|12.345.678,10|12.345.678,10|12.345.678,10|
            loga ( 'Abrindo cursor' );

            FOR cr_011 IN c_relatorio_011 ( p_data_ini
                                          , p_data_fim
                                          , v_exec_all ) LOOP
                v_text01 :=
                    fazcampo ( cr_011.estabelecimento
                             , ' '
                             , 6 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_011.saldo_period_ant
                                , 'FM99999990D00'
                                , ' '
                                , 13 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_011.cred_imposto
                                , 'FM99999990D00'
                                , ' '
                                , 13 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_011.outros_creditos
                                , 'FM99999990D00'
                                , ' '
                                , 13 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_011.estorno_debito
                                , 'FM99999990D00'
                                , ' '
                                , 13 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_011.deducoes
                                , 'FM99999990D00'
                                , ' '
                                , 13 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_011.total_credito
                                , 'FM99999990D00'
                                , ' '
                                , 13 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_011.debito_imposto
                                , 'FM99999990D00'
                                , ' '
                                , 13 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_011.outros_debitos
                                , 'FM99999990D00'
                                , ' '
                                , 13 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_011.estorno_credito
                                , 'FM99999990D00'
                                , ' '
                                , 13 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_011.total_debito
                                , 'FM99999990D00'
                                , ' '
                                , 13 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_011.saldo_period_cred_deb
                                , 'FM99999990D00'
                                , ' '
                                , 13 );
                lib_proc.add ( v_text01 );
            END LOOP;

            lib_proc.add (
                           '------|-------------|-------------|-------------|-------------|-------------|-------------|-------------|-------------|-------------|-------------|-------------|'
            );
            lib_proc.add ( ' ' );
            lib_proc.add ( 'Fim do relatório' );

            loga ( 'Fim do relatório!' );
            v_proc_status := 2; --SUCESSO
        ----------------------------------------------------------------------------------------------------------
        ELSIF p_relatorio = '012' THEN
            --012 - Notas Fiscais de Entrada Duplicadas

            loga ( 'Imprimindo relatório' );
            loga ( ' ' );
            loga ( 'Este relatório exibe as NFs de entrada duplicadas dentro do período equalizado' );
            loga ( ' ' );
            loga ( 'O relatório utiliza todas as NFs de entrada dentro do período informado e' );
            loga ( 'pesquisa por NFs duplicadas dentro de todo o período equalizado no DataMart' );

            -- MPROC_IDB := LIB_PROC.new('DPSP_NOTAS_DUPLICADAS', 48, 150);

            lib_proc.add_tipo ( mproc_id
                              , 121212
                              ,    mcod_empresa
                                || '_'
                                || TO_CHAR ( p_data_fim
                                           , 'YYYYMM' )
                                || '_NOTAS_ENTRADA_DUPLICADAS.XLS'
                              , 2 );

            lib_proc.add ( dsp_planilha.header
                         , ptipo => 121212 );

            lib_proc.add ( dsp_planilha.tabela_inicio
                         , ptipo => 121212 );

            lib_proc.add ( dsp_planilha.linha ( p_conteudo => dsp_planilha.campo ( '004 - Notas de Entrada Duplicadas'
                                                                                 , p_custom => 'COLSPAN=16' )
                                              , p_class => 'h' )
                         , ptipo => 121212 );

            lib_proc.add ( dsp_planilha.linha ( p_conteudo =>    dsp_planilha.campo ( 'COD_ESTAB' )
                                                              || dsp_planilha.campo ( 'COD_ESTAB_B' )
                                                              || dsp_planilha.campo ( 'NUM_DOCFIS' )
                                                              || dsp_planilha.campo ( 'SERIE_DOCFIS' )
                                                              || dsp_planilha.campo ( 'CPF_CGC' )
                                                              || dsp_planilha.campo ( 'DATA_FISCAL_A' )
                                                              || dsp_planilha.campo ( 'COD_FIS_JUR_A' )
                                                              || dsp_planilha.campo ( 'RAZAO_SOCIAL_A' )
                                                              || dsp_planilha.campo ( 'VLR_TOT_NOTA_A' )
                                                              || dsp_planilha.campo ( 'DATA_FISCAL_B' )
                                                              || dsp_planilha.campo ( 'COD_FIS_JUR_B' )
                                                              || dsp_planilha.campo ( 'RAZAO_SOCIAL_B' )
                                                              || dsp_planilha.campo ( 'VLR_TOT_NOTA_B' )
                                                              || dsp_planilha.campo ( 'IDENT_DOCTO_FISCAL_A' )
                                                              || dsp_planilha.campo ( 'IDENT_DOCTO_FISCAL_B' )
                                                              || dsp_planilha.campo ( 'CHAVE_ACESSO_A'
                                                                                    , p_width => 280 )
                                              , p_class => 'h' )
                         , ptipo => 121212 );

            loga ( 'Abrindo cursor' );

            IF v_exec_all = 'N'
           AND p_codestab.COUNT > 0 THEN
                FOR cr_012 IN c_relatorio_012_estab ( p_data_ini
                                                    , p_data_fim ) LOOP
                    IF v_class = 'a' THEN
                        v_class := 'b';
                    ELSE
                        v_class := 'a';
                    END IF;

                    ---
                    v_count := v_count + 1;
                    dbms_application_info.set_module ( 'NF_DUPLICADAS'
                                                     , '[' || v_count || ']' );

                    v_text01 :=
                        dsp_planilha.linha (
                                             p_conteudo =>    dsp_planilha.campo ( cr_012.cod_estab )
                                                           || dsp_planilha.campo ( cr_012.cod_estab_b )
                                                           || dsp_planilha.campo (
                                                                                   dsp_planilha.texto (
                                                                                                        cr_012.num_docfis
                                                                                   )
                                                              )
                                                           || dsp_planilha.campo (
                                                                                   dsp_planilha.texto (
                                                                                                        cr_012.serie_docfis
                                                                                   )
                                                              )
                                                           || dsp_planilha.campo (
                                                                                   dsp_planilha.texto (
                                                                                                        cr_012.cpf_cgc
                                                                                   )
                                                              )
                                                           || dsp_planilha.campo ( cr_012.data_fiscal_a )
                                                           || dsp_planilha.campo (
                                                                                   dsp_planilha.texto (
                                                                                                        cr_012.cod_fis_jur_a
                                                                                   )
                                                              )
                                                           || dsp_planilha.campo ( cr_012.razao_social_a )
                                                           || dsp_planilha.campo ( moeda ( cr_012.vlr_tot_nota_a ) )
                                                           || dsp_planilha.campo ( cr_012.data_fiscal_b )
                                                           || dsp_planilha.campo (
                                                                                   dsp_planilha.texto (
                                                                                                        cr_012.cod_fis_jur_b
                                                                                   )
                                                              )
                                                           || dsp_planilha.campo ( cr_012.razao_social_b )
                                                           || dsp_planilha.campo ( moeda ( cr_012.vlr_tot_nota_b ) )
                                                           || dsp_planilha.campo (
                                                                                   dsp_planilha.texto (
                                                                                                        cr_012.ident_docto_fiscal_a
                                                                                   )
                                                              )
                                                           || dsp_planilha.campo (
                                                                                   dsp_planilha.texto (
                                                                                                        cr_012.ident_docto_fiscal_b
                                                                                   )
                                                              )
                                                           || dsp_planilha.campo (
                                                                                   dsp_planilha.texto (
                                                                                                        cr_012.chave_acesso_a
                                                                                   )
                                                              )
                                           , p_class => v_class
                        );

                    lib_proc.add ( v_text01
                                 , ptipo => 121212 );
                END LOOP; --FOR CR_004 IN C_RELATORIO_02_004(P_DATA_INI,P_DATA_FIM)
            ELSE
                FOR cr_012 IN c_relatorio_012_all ( p_data_ini
                                                  , p_data_fim ) LOOP
                    IF v_class = 'a' THEN
                        v_class := 'b';
                    ELSE
                        v_class := 'a';
                    END IF;

                    ---
                    v_count := v_count + 1;
                    dbms_application_info.set_module ( 'NF_DUPLICADAS'
                                                     , '[' || v_count || ']' );

                    v_text01 :=
                        dsp_planilha.linha (
                                             p_conteudo =>    dsp_planilha.campo ( cr_012.cod_estab )
                                                           || dsp_planilha.campo ( cr_012.cod_estab_b )
                                                           || dsp_planilha.campo (
                                                                                   dsp_planilha.texto (
                                                                                                        cr_012.num_docfis
                                                                                   )
                                                              )
                                                           || dsp_planilha.campo (
                                                                                   dsp_planilha.texto (
                                                                                                        cr_012.serie_docfis
                                                                                   )
                                                              )
                                                           || dsp_planilha.campo (
                                                                                   dsp_planilha.texto (
                                                                                                        cr_012.cpf_cgc
                                                                                   )
                                                              )
                                                           || dsp_planilha.campo ( cr_012.data_fiscal_a )
                                                           || dsp_planilha.campo (
                                                                                   dsp_planilha.texto (
                                                                                                        cr_012.cod_fis_jur_a
                                                                                   )
                                                              )
                                                           || dsp_planilha.campo ( cr_012.razao_social_a )
                                                           || dsp_planilha.campo ( moeda ( cr_012.vlr_tot_nota_a ) )
                                                           || dsp_planilha.campo ( cr_012.data_fiscal_b )
                                                           || dsp_planilha.campo (
                                                                                   dsp_planilha.texto (
                                                                                                        cr_012.cod_fis_jur_b
                                                                                   )
                                                              )
                                                           || dsp_planilha.campo ( cr_012.razao_social_b )
                                                           || dsp_planilha.campo ( moeda ( cr_012.vlr_tot_nota_b ) )
                                                           || dsp_planilha.campo (
                                                                                   dsp_planilha.texto (
                                                                                                        cr_012.ident_docto_fiscal_a
                                                                                   )
                                                              )
                                                           || dsp_planilha.campo (
                                                                                   dsp_planilha.texto (
                                                                                                        cr_012.ident_docto_fiscal_b
                                                                                   )
                                                              )
                                                           || dsp_planilha.campo (
                                                                                   dsp_planilha.texto (
                                                                                                        cr_012.chave_acesso_a
                                                                                   )
                                                              )
                                           , p_class => v_class
                        );

                    lib_proc.add ( v_text01
                                 , ptipo => 121212 );
                END LOOP; --FOR CR_004 IN C_RELATORIO_02_004(P_DATA_INI,P_DATA_FIM)
            END IF;

            lib_proc.add ( dsp_planilha.tabela_fim
                         , ptipo => 121212 );

            loga ( 'Fim do relatório!' );

            v_proc_status := 2; --SUCESSO
        ----------------------------------------------------------------------------------------------------------

        ELSIF p_relatorio = '101' THEN
            --101 - P2K - Dif. P2K_FECHAMENTO e P2K_TRIB_FECH
            loga ( 'Imprimindo relatório' );
            lib_proc.add_header ( '101 - P2K - Dif. P2K_FECHAMENTO e P2K_TRIB_FECH'
                                , 1
                                , 1 );
            lib_proc.add_header ( ' ' );
            lib_proc.add ( '                  P2K_FECHAMENTO                                 |P2K_TRIB_FECH' );
            lib_proc.add ( 'LOJA|       DATA| CX|VENDA BRUTA|CANCELADO| DESCONTO|TOT. LIQUIDO|TOT. LIQUIDO' );
            lib_proc.add ( '----|-----------|---|-----------|---------|---------|------------|------------' );
            --                         123| 01/01/2012|  1|  123456,78|  1234,56|  1234,56|    12345,67|    23456,78

            loga ( 'Abrindo cursor' );

            IF v_exec_all = 'N'
           AND p_codestab.COUNT > 0 THEN
                loga ( 'relatorio para estabelecimentos específicos' );

                --relatorio para estabelecimentos específicos
                OPEN c_relatorio_101b ( TO_CHAR ( p_data_ini
                                                , 'YYYYMMDD' )
                                      , TO_CHAR ( p_data_fim
                                                , 'YYYYMMDD' ) );
            ELSE
                loga ( 'relatório para todos os estabelecimentos' );

                --relatório para todos os estabelecimentos
                OPEN c_relatorio_101a ( TO_CHAR ( p_data_ini
                                                , 'YYYYMMDD' )
                                      , TO_CHAR ( p_data_fim
                                                , 'YYYYMMDD' ) );
            END IF;

            LOOP
                IF v_exec_all = 'N'
               AND p_codestab.COUNT > 0 THEN
                    --relatorio para estabelecimentos específicos
                    FETCH c_relatorio_101b
                        INTO c101;

                    --LOGA('FETCH B');
                    EXIT WHEN c_relatorio_101b%NOTFOUND;
                ELSE
                    --relatório para todos os estabelecimentos
                    FETCH c_relatorio_101a
                        INTO c101;

                    --LOGA('FETCH A');
                    EXIT WHEN c_relatorio_101a%NOTFOUND;
                END IF;

                v_text01 :=
                    fazcampo ( c101.codigo_loja
                             , 'FM9999'
                             , ' '
                             , 4 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( c101.data_transacao
                                , 'DD/MM/YYYY'
                                , ' '
                                , 11 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( c101.numero_componente
                                , 'FM999'
                                , ' '
                                , 3 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( c101.venda_bruta
                                , 'FM99999990D00'
                                , ' '
                                , 11 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( c101.total_canc
                                , 'FM999990D00'
                                , ' '
                                , 9 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( c101.total_descontos
                                , 'FM999990D00'
                                , ' '
                                , 9 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( c101.pfc_liq
                                , 'FM999999990D00'
                                , ' '
                                , 12 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( c101.val_liquido
                                , 'FM999999990D00'
                                , ' '
                                , 12 );
                v_text01 := v_text01 || v_sep;
                lib_proc.add ( v_text01 );
            END LOOP;

            loga ( 'Fim do relatório!' );

            IF v_exec_all = 'N'
           AND p_codestab.COUNT > 0 THEN
                loga ( 'CLOSE B' );

                CLOSE c_relatorio_101b;
            ELSE
                loga ( 'CLOSE A' );

                CLOSE c_relatorio_101a;
            END IF;

            v_proc_status := 2; --SUCESSO
        ----------------------------------------------------------------------------------------------------------
        ELSIF p_relatorio = '102' THEN
            --102 - P2K - Dif. P2K_TRIB_FECH e P2K_CAB_TRANSACAO - VENDA LIQUIDA
            loga ( 'Imprimindo relatório' );
            lib_proc.add_header ( 'Diferenças entre P2K_TRIB_FECH e P2K_CAB_TRANSACAO - VENDA LIQUIDA'
                                , 1
                                , 1 );
            lib_proc.add_header ( ' ' );
            lib_proc.add ( '         P2K_TRIB_FECH          |P2K_CAB_TRANSACAO|           |' );
            lib_proc.add ( 'LOJA|       DATA| CX|TOTAL VENDA|TOTAL VENDA|     |DIFERENÇA  |' );
            lib_proc.add ( '----|-----------|---|-----------|-----------|     |-----------|' );
            --                         123| 01/01/2012|  1|  123456,78|  123456,78|     |  123456,78|

            loga ( 'Abrindo cursor' );

            IF v_exec_all = 'N'
           AND p_codestab.COUNT > 0 THEN
                loga ( 'relatorio para estabelecimentos específicos' );

                --relatorio para estabelecimentos específicos
                OPEN c_relatorio_102b ( TO_CHAR ( p_data_ini
                                                , 'YYYYMMDD' )
                                      , TO_CHAR ( p_data_fim
                                                , 'YYYYMMDD' ) );
            ELSE
                loga ( 'relatório para todos os estabelecimentos' );

                --relatório para todos os estabelecimentos
                OPEN c_relatorio_102a ( TO_CHAR ( p_data_ini
                                                , 'YYYYMMDD' )
                                      , TO_CHAR ( p_data_fim
                                                , 'YYYYMMDD' ) );
            END IF;

            LOOP
                IF v_exec_all = 'N'
               AND p_codestab.COUNT > 0 THEN
                    --relatorio para estabelecimentos específicos
                    FETCH c_relatorio_102b
                        INTO c102;

                    --LOGA('FETCH B');
                    EXIT WHEN c_relatorio_102b%NOTFOUND;
                ELSE
                    --relatório para todos os estabelecimentos
                    FETCH c_relatorio_102a
                        INTO c102;

                    --LOGA('FETCH A');
                    EXIT WHEN c_relatorio_102a%NOTFOUND;
                END IF;

                v_text01 :=
                    fazcampo ( c102.codigo_loja
                             , 'FM9999'
                             , ' '
                             , 4 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( c102.data_transacao
                                , 'DD/MM/YYYY'
                                , ' '
                                , 11 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( c102.numero_componente
                                , 'FM999'
                                , ' '
                                , 3 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( c102.ptf_val_bruto
                                , 'FM99999990D00'
                                , ' '
                                , 11 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( c102.pct_valor_total_venda
                                , 'FM99999990D00'
                                , ' '
                                , 11 );
                v_text01 := v_text01 || v_sep || '     ';
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( c102.dif
                                , 'FM99999990D00'
                                , ' '
                                , 11 );
                v_text01 := v_text01 || v_sep;
                lib_proc.add ( v_text01 );
            END LOOP;

            loga ( 'Fim do relatório!' );

            IF v_exec_all = 'N'
           AND p_codestab.COUNT > 0 THEN
                loga ( 'CLOSE B' );

                CLOSE c_relatorio_102b;
            ELSE
                loga ( 'CLOSE A' );

                CLOSE c_relatorio_102a;
            END IF;

            v_proc_status := 2; --SUCESSO
        ----------------------------------------------------------------------------------------------------------
        ELSIF p_relatorio = '103' THEN
            --103 - P2K - Dif. P2K_TRIB_FECH e P2K_ITEM_TRANSACAO - VENDA LIQUIDA
            loga ( 'Imprimindo relatório' );
            lib_proc.add_header ( '103 - Diferenças entre P2K_TRIB_FECH e P2K_ITEM_TRANSACAO - VENDA LIQUIDA'
                                , 1
                                , 1 );
            lib_proc.add_header ( ' ' );
            lib_proc.add ( '          P2K_TRIB_FECH               |P2K_ITEM_TRANSACAO|           |' );
            lib_proc.add ( 'LOJA|       DATA| CX| TRIB|TOTAL VENDA|TOTAL VENDA|      |DIFERENÇA  |' );
            lib_proc.add ( '----|-----------|---|-----|-----------|-----------|      |-----------|' );
            --                         123| 01/01/2012|  1|   T9|  123456,78|  123456,78|      |  123456,78|

            loga ( 'Abrindo cursor' );

            FOR c1 IN c_estabs LOOP
                loga ( 'Estab: [' || c1.cod_estab || ']' );

                FOR c2 IN c_datas ( p_data_ini
                                  , p_data_fim ) LOOP
                    --LOGA('Data: [' || C2.DATA_SAFX || ']'); --debug
                    FOR c103 IN c_relatorio_103 ( c1.codigo_loja
                                                , c2.data_safx
                                                , c2.data_safx ) LOOP
                        v_text01 :=
                            fazcampo ( c103.codigo_loja
                                     , 'FM9999'
                                     , ' '
                                     , 4 );
                        v_text01 :=
                               v_text01
                            || v_sep
                            || fazcampo ( c103.data_transacao
                                        , 'DD/MM/YYYY'
                                        , ' '
                                        , 11 );
                        v_text01 :=
                               v_text01
                            || v_sep
                            || fazcampo ( c103.numero_componente
                                        , 'FM999'
                                        , ' '
                                        , 3 );
                        v_text01 :=
                               v_text01
                            || v_sep
                            || fazcampo ( c103.ptf_codigo_trib
                                        , ' '
                                        , 5 );
                        v_text01 :=
                               v_text01
                            || v_sep
                            || fazcampo ( c103.ptf_val_bruto
                                        , 'FM99999990D00'
                                        , ' '
                                        , 11 );
                        v_text01 :=
                               v_text01
                            || v_sep
                            || fazcampo ( c103.pit_valor_liquido
                                        , 'FM99999990D00'
                                        , ' '
                                        , 11 );
                        v_text01 := v_text01 || v_sep || '      ';
                        v_text01 :=
                               v_text01
                            || v_sep
                            || fazcampo ( c103.dif
                                        , 'FM99999990D00'
                                        , ' '
                                        , 11 );
                        v_text01 := v_text01 || v_sep;
                        lib_proc.add ( v_text01 );
                    END LOOP; --FOR C103 IN C_RELATORIO_103(C1.CODIGO_LOJA, C2.DATA_SAFX,C2.DATA_SAFX)
                END LOOP; --FOR C2 IN C_DATAS(P_DATA_INI,P_DATA_FIM)
            END LOOP; --FOR C1 IN C_ESTABS

            loga ( 'Fim do relatório!' );
            v_proc_status := 2; --SUCESSO
        ----------------------------------------------------------------------------------------------------------
        ELSIF p_relatorio = '012' THEN
            -- RELATORIO: SELECT ''012'',''012 - Relatório Análise de Saldo da CAT17'' FROM DUAL
            loga ( 'Imprimindo relatório' );
            lib_proc.add_header ( '012 - Relatório Análise de Saldo da CAT17'
                                , 1
                                , 1 );
            lib_proc.add_header ( ' ' );
            lib_proc.add (
                           '                                      |       INICIAL        |             MOVIMENTO             |         FINAL        |'
            );
            lib_proc.add (
                           '------|--------|----------------------|----------|-----------|-----------|-----------|-----------|----------|-----------|'
            );
            lib_proc.add (
                           'ESTAB | PRODUTO|             DESCRICAO|DATA SALDO|      SALDO|QTD ENTRADA|  QTD_SAIDA|  DIFERENÇA|DATA SALDO|      SALDO|'
            );
            lib_proc.add (
                           '------|--------|----------------------|----------|-----------|-----------|-----------|-----------|----------|-----------|'
            );

            --                        DSP910|12345678|OLEO TRAT.PROF.42M ARG|01/01/1900| 1234567,89| 1234567,89| 1234567,89| 1234567,89|01/01/1900| 1234567,89|

            FOR c1 IN c_estabs LOOP
                loga ( 'Estab: [' || c1.cod_estab || ']' );

                FOR c012 IN c_relatorio_012 ( c1.cod_estab
                                            , p_data_fim ) LOOP
                    -- buscar MOVIMENTOS
                    SELECT NVL ( SUM ( CASE WHEN a.movto_e_s <> '9' THEN a.qtd_e_s ELSE 0 END ), 0 ) AS qtde_entrada
                         , ( -1 ) * NVL ( SUM ( CASE WHEN movto_e_s = '9' THEN a.qtd_e_s ELSE 0 END ), 0 )
                               AS qtde_saida
                         ,   NVL ( SUM ( CASE WHEN a.movto_e_s <> '9' THEN a.qtd_e_s ELSE 0 END ), 0 )
                           - NVL ( SUM ( CASE WHEN movto_e_s = '9' THEN a.qtd_e_s ELSE 0 END ), 0 )
                               AS diferenca
                      INTO v_qtde_entrada
                         , v_qtde_saida
                         , v_diferenca
                      FROM msaf.x27_mov_est_st a
                     WHERE a.cod_empresa = mcod_empresa
                       AND a.cod_estab = c1.cod_estab
                       AND a.ident_produto = c012.ident_produto
                       AND a.data_fiscal BETWEEN p_data_ini AND p_data_fim;

                    ------------------

                    v_text01 :=
                        fazcampo ( c012.cod_estab
                                 , ' '
                                 , 6 );
                    v_text01 :=
                           v_text01
                        || v_sep
                        || fazcampo ( c012.cod_produto
                                    , ' '
                                    , 8 );
                    v_text01 :=
                           v_text01
                        || v_sep
                        || fazcampo ( c012.descricao
                                    , ' '
                                    , 22 );
                    v_text01 :=
                           v_text01
                        || v_sep
                        || fazcampo ( c012.data_saldo_inicial
                                    , ' '
                                    , 10 );
                    v_text01 :=
                           v_text01
                        || v_sep
                        || fazcampo ( c012.saldo_inicial
                                    , 'FM99999990D00'
                                    , ' '
                                    , 11 );
                    v_text01 :=
                           v_text01
                        || v_sep
                        || fazcampo ( v_qtde_entrada
                                    , 'FM99999990D00'
                                    , ' '
                                    , 11 );
                    v_text01 :=
                           v_text01
                        || v_sep
                        || fazcampo ( v_qtde_saida
                                    , 'FM99999990D00'
                                    , ' '
                                    , 11 );
                    v_text01 :=
                           v_text01
                        || v_sep
                        || fazcampo ( v_diferenca
                                    , 'FM99999990D00'
                                    , ' '
                                    , 11 );
                    v_text01 :=
                           v_text01
                        || v_sep
                        || fazcampo ( c012.data_saldo_final
                                    , ' '
                                    , 10 );
                    v_text01 :=
                           v_text01
                        || v_sep
                        || fazcampo ( c012.saldo_final
                                    , 'FM99999990D00'
                                    , ' '
                                    , 11 );

                    IF ( c012.saldo_inicial + v_diferenca <> c012.saldo_final ) THEN
                        v_text01 :=
                               v_text01
                            || v_sep
                            || fazcampo ( '*ERR*'
                                        , ' '
                                        , 5 );
                    END IF;

                    v_text01 := v_text01 || v_sep;
                    lib_proc.add ( v_text01 );
                END LOOP;
            END LOOP;

            lib_proc.add (
                           '------|--------|----------------------|----------|-----------|-----------|-----------|-----------|----------|-----------|'
            );
            lib_proc.add ( ' ' );
            lib_proc.add ( 'Fim do relatório' );

            loga ( 'Fim do relatório!' );
            v_proc_status := 2; --SUCESSO
        ----------------------------------------------------------------------------------------------------------
        END IF; --IF P_RELATORIO '1' THEN ... ELSIF ...

        loga ( 'Fim do processo, limpando temporária de estabelecimentos' );
        msafi.dsp_aux.truncatabela_msafi ( 'DSP_PROC_ESTABS' );
        COMMIT;

        v_s_proc_status :=
            CASE v_proc_status
                WHEN 0 THEN 'ERROI#0' --NUNCA DEVE SER 0, POIS JÁ VIRA 1 NO INÍCIO!
                WHEN 1 THEN 'ERROI#1' --AINDA ESTÁ EM PROCESSO!??!? ERRO NO PROCESSO!
                WHEN 2 THEN 'SUCESSO'
                WHEN 3 THEN 'AVISOS'
                WHEN 4 THEN 'ERRO'
                ELSE 'ERROI#' || v_proc_status
            END;

        loga ( 'FIM DO PROCESSAMENTO, STATUS FINAL: [' || v_s_proc_status || ']' );
        msafi.dsp_control.updateprocess ( v_s_proc_status );
        lib_proc.close ( );

        COMMIT;
        RETURN mproc_id;
    EXCEPTION
        WHEN OTHERS THEN
            --MSAFI.DSP_CONTROL.LOG_CHECKPOINT(SQLERRM,'Erro não tratado, relatórios customizados');
            lib_proc.add_log ( 'Erro não tratado: ' || SQLERRM
                             , 1 );
            loga ( 'Abortando execução' );
            lib_proc.close;
            COMMIT;
            RETURN mproc_id;
    END; /* FUNCTION EXECUTAR */
END dsp_relatorios_01_cproc;
/
SHOW ERRORS;
