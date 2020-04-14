Prompt Package Body DPSP_FIN42_REL_INCINE_CPROC;
--
-- DPSP_FIN42_REL_INCINE_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_fin42_rel_incine_cproc
IS
    FUNCTION parametros
        RETURN VARCHAR2
    IS
        --MPROC_ID    INTEGER;
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
                             pstr
                           , 'CDs'
                           , --P_CDS
                            'VARCHAR2'
                           , 'MULTISELECT'
                           , 'S'
                           , NULL
                           , NULL
                           ,    'SELECT A.COD_ESTAB, A.COD_ESTAB || '' - '' || B.COD_ESTADO || '' - '' || A.CGC || '' - '' || INITCAP(A.BAIRRO) || '' / '' || INITCAP(A.CIDADE) FROM ESTABELECIMENTO A, ESTADO B, MSAFI.DSP_ESTABELECIMENTO C WHERE A.COD_EMPRESA  = '''
                             || mcod_empresa
                             || ''' AND B.IDENT_ESTADO = A.IDENT_ESTADO AND A.COD_EMPRESA = C.COD_EMPRESA AND A.COD_ESTAB = C.COD_ESTAB AND C.TIPO = ''C'' ORDER BY B.COD_ESTADO, A.COD_ESTAB'
        );

        RETURN pstr;
    END; --FUNCTION PARAMETROS RETURN VARCHAR2 IS

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Relatório Ressarcimento de ST para NF de Incineração';
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
        RETURN 'Emitir Relatório de Ressarcimento de ST para NF de Incineração';
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
    --MSAFI.DSP_CONTROL.WRITELOG('INCINE',P_I_TEXTO);
    ---> Para acompanhar processamento usar SELECT abaixo
    --SELECT * FROM DSP_LOG
    --WHERE LOG_TYPE = 'INTER'
    --ORDER BY 3 DESC, 2 DESC
    ---
    END;

    FUNCTION moeda ( v_conteudo NUMBER )
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN TRIM ( TO_CHAR ( v_conteudo
                              , '9g999g999g990d0000' ) );
    END;

    /*******************************************************************************INICIO - GERA EXCEL INCINERAÇÃO*******************************************************************************/
    PROCEDURE load_incineracao ( vp_proc_instance IN VARCHAR
                               , v_data_inicial IN DATE
                               , v_data_final IN DATE
                               , p_cod_estab IN VARCHAR
                               , vp_mproc_id IN NUMBER
                               , v_id_arq IN NUMBER )
    IS
        v_sql VARCHAR2 ( 5000 );
        v_text01 VARCHAR2 ( 4000 );
        v_class VARCHAR2 ( 1 ) := 'a';
        c_incineracao SYS_REFCURSOR;

        TYPE cur_tab_incineracao IS RECORD
        (
            cod_empresa VARCHAR2 ( 3 )
          , cod_estab VARCHAR2 ( 6 )
          , num_docfis VARCHAR2 ( 12 )
          , num_controle_docto VARCHAR2 ( 12 )
          , num_item NUMBER ( 5 )
          , cod_produto VARCHAR2 ( 35 )
          , descr_item VARCHAR2 ( 50 )
          , data_fiscal DATE
          , uf_origem VARCHAR2 ( 2 )
          , uf_destino VARCHAR2 ( 2 )
          , cod_fis_jur VARCHAR2 ( 14 )
          , cnpj VARCHAR2 ( 14 )
          , razao_social VARCHAR2 ( 70 )
          , serie_docfis VARCHAR2 ( 3 )
          , cfop VARCHAR2 ( 5 )
          , finalidade VARCHAR2 ( 3 )
          , nbm VARCHAR2 ( 10 )
          , num_autentic_nfe VARCHAR2 ( 80 )
          , quantidade NUMBER ( 17, 6 )
          , vlr_unit NUMBER ( 19, 4 )
          , vlr_item NUMBER ( 17, 2 )
          , vlr_base_icms NUMBER ( 17, 2 )
          , vlr_icms NUMBER ( 17, 2 )
          , aliq_icms NUMBER ( 5, 2 )
          , listaproduto VARCHAR2 ( 20 )
          , cod_estab_e VARCHAR2 ( 6 )
          , data_fiscal_e DATE
          , num_controle_docto_e VARCHAR2 ( 12 )
          , num_docfis_e VARCHAR2 ( 12 )
          , serie_docfis_e VARCHAR2 ( 3 )
          , sub_serie_docfis VARCHAR2 ( 2 )
          , discri_item VARCHAR2 ( 46 )
          , cod_fis_jur_e VARCHAR2 ( 14 )
          , cpf_cgc VARCHAR2 ( 14 )
          , razao_social_e VARCHAR2 ( 70 )
          , cod_nbm VARCHAR2 ( 10 )
          , cod_cfo VARCHAR2 ( 4 )
          , cod_natureza_op VARCHAR2 ( 3 )
          , vlr_contab_item NUMBER ( 17, 2 )
          , quantidade_e NUMBER ( 12, 4 )
          , vlr_unit_e NUMBER ( 17, 2 )
          , cod_situacao_a VARCHAR2 ( 2 )
          , cod_situacao_b VARCHAR2 ( 2 )
          , cod_estado VARCHAR2 ( 2 )
          , num_autentic_nfe_e VARCHAR2 ( 80 )
          , cfop_forn VARCHAR2 ( 5 )
          , vlr_base_icms_e NUMBER ( 17, 2 )
          , vlr_icms_e NUMBER ( 17, 2 )
          , aliq_reducao NUMBER ( 5, 2 )
          , vlr_base_icms_st NUMBER ( 17, 2 )
          , vlr_icms_st NUMBER ( 17, 2 )
          , vlr_base_icmsst_ret NUMBER ( 17, 2 )
          , vlr_icmsst_ret NUMBER ( 17, 2 )
          , --CLASSIFICACAO         NUMBER(1),
            aliq_interna NUMBER ( 5, 2 )
          , vlr_antecip_ist NUMBER ( 17, 2 )
          , vlr_antecip_rev NUMBER ( 17, 2 )
          , excluir_campo1 NUMBER ( 17, 2 )
          , -- VLR_ICMS_CALCULADO    NUMBER(17,2),
            --VLR_ICMS_RESSARC      NUMBER(17,4),
            --VLR_ICMSST_RESSARC    NUMBER(17,4),
            ressarc_icms_st_ret NUMBER ( 17, 4 )
          , ressarc_icms_st NUMBER ( 17, 4 )
          , --VLR_ICMS_ANT_RES      NUMBER(17,4),
            ressarc_icms_st_antecip NUMBER ( 17, 4 )
          , --
            vlr_pis_unit NUMBER ( 17, 2 )
          , vlr_cofins_unit NUMBER ( 17, 2 )
          , vlr_total_estorno_pis NUMBER ( 17, 2 )
          , vlr_total_estorno_cofins NUMBER ( 17, 2 )
        /*ESTORNO_PIS_E         NUMBER(17,2),
                                                                                               ESTORNO_COFINS_E      NUMBER(17,2),
                                                                                               ESTORNO_PIS_S         NUMBER(17,2),
                                                                                               ESTORNO_COFINS_S      NUMBER(17,2)*/
         );

        TYPE c_tab_incineracao IS TABLE OF cur_tab_incineracao;

        tab_e c_tab_incineracao;
    BEGIN
        v_sql := ' SELECT DISTINCT COD_EMPRESA,  ';
        v_sql := v_sql || ' COD_ESTAB,   ';
        v_sql := v_sql || ' NUM_DOCFIS,  ';
        v_sql := v_sql || ' NUM_CONTROLE_DOCTO, ';
        v_sql := v_sql || ' NUM_ITEM,  ';
        v_sql := v_sql || ' COD_PRODUTO, ';
        v_sql := v_sql || ' DESCR_ITEM, ';
        v_sql := v_sql || ' DATA_FISCAL, ';
        v_sql := v_sql || ' UF_ORIGEM, ';
        v_sql := v_sql || ' UF_DESTINO,  ';
        v_sql := v_sql || ' COD_FIS_JUR,  ';
        v_sql := v_sql || ' CNPJ, ';
        v_sql := v_sql || ' RAZAO_SOCIAL,  ';
        v_sql := v_sql || ' SERIE_DOCFIS,  ';
        v_sql := v_sql || ' CFOP,  ';
        v_sql := v_sql || ' FINALIDADE, ';
        v_sql := v_sql || ' NBM, ';
        v_sql := v_sql || ' NUM_AUTENTIC_NFE, ';
        v_sql := v_sql || ' QUANTIDADE, ';
        v_sql := v_sql || ' VLR_UNIT, ';
        v_sql := v_sql || ' VLR_ITEM, ';
        v_sql := v_sql || ' VLR_BASE_ICMS, ';
        v_sql := v_sql || ' VLR_ICMS,  ';
        v_sql := v_sql || ' ALIQ_ICMS,';
        v_sql := v_sql || ' LISTAPRODUTO,  ';
        v_sql := v_sql || ' COD_ESTAB_E, ';
        v_sql := v_sql || ' DATA_FISCAL_E, ';
        v_sql := v_sql || ' NUM_CONTROLE_DOCTO_E, ';
        v_sql := v_sql || ' NUM_DOCFIS_E, ';
        v_sql := v_sql || ' SERIE_DOCFIS_E, ';
        v_sql := v_sql || ' SUB_SERIE_DOCFIS,  ';
        v_sql := v_sql || ' DISCRI_ITEM, ';
        v_sql := v_sql || ' COD_FIS_JUR_E, ';
        v_sql := v_sql || ' CPF_CGC,  ';
        v_sql := v_sql || ' RAZAO_SOCIAL_E,  ';
        v_sql := v_sql || ' COD_NBM,  ';
        v_sql := v_sql || ' COD_CFO,  ';
        v_sql := v_sql || ' COD_NATUREZA_OP,';
        v_sql := v_sql || ' VLR_CONTAB_ITEM, ';
        v_sql := v_sql || ' QUANTIDADE_E,   ';
        v_sql := v_sql || ' VLR_UNIT_E,   ';
        v_sql := v_sql || ' COD_SITUACAO_A,  ';
        v_sql := v_sql || ' COD_SITUACAO_B,  ';
        v_sql := v_sql || ' COD_ESTADO, ';
        v_sql := v_sql || ' NUM_AUTENTIC_NFE_E, ';
        v_sql := v_sql || ' CFOP_FORN,  ';
        v_sql := v_sql || ' VLR_BASE_ICMS_E,  ';
        v_sql := v_sql || ' VLR_ICMS_E,  ';
        v_sql := v_sql || ' ALIQ_REDUCAO,  ';
        v_sql := v_sql || ' VLR_BASE_ICMS_ST, ';
        v_sql := v_sql || ' VLR_ICMS_ST,   ';
        v_sql := v_sql || ' VLR_BASE_ICMSST_RET,  ';
        v_sql := v_sql || ' VLR_ICMSST_RET,  ';
        --V_SQL := V_SQL || ' CLASSIFICACAO,  ';
        v_sql := v_sql || ' ALIQ_INTERNA,  ';
        v_sql := v_sql || ' VLR_ANTECIP_IST, ';
        v_sql := v_sql || ' VLR_ANTECIP_REV,  ';
        --V_SQL := V_SQL || ' VLR_ICMS_CALCULADO, ';
        --V_SQL := V_SQL || ' VLR_ICMS_RESSARC, ';
        --V_SQL := V_SQL || ' VLR_ICMSST_RESSARC, ';

        --V_SQL := V_SQL || ' VLR_ICMS_RESSARC, ';
        --V_SQL := V_SQL || ' VLR_ICMSST_RESSARC, ';
        --V_SQL := V_SQL || ' VLR_ICMS_ANT_RES, ';

        v_sql := v_sql || ' EXCLUIR_CAMPO1, ';
        v_sql := v_sql || ' RESSARC_ICMS_ST_RET, ';
        v_sql := v_sql || ' RESSARC_ICMS_ST, ';
        v_sql := v_sql || ' RESSARC_ICMS_ST_ANTECIP, ';

        --
        v_sql := v_sql || ' VLR_PIS_UNIT, ';
        v_sql := v_sql || ' VLR_COFINS_UNIT, ';
        v_sql := v_sql || ' VLR_TOTAL_ESTORNO_PIS, ';
        v_sql := v_sql || ' VLR_TOTAL_ESTORNO_COFINS  ';
        /*V_SQL := V_SQL || ' ESTORNO_PIS_E, ';
        V_SQL := V_SQL || ' ESTORNO_COFINS_E, ';
        V_SQL := V_SQL || ' ESTORNO_PIS_S, ';
        V_SQL := V_SQL || ' ESTORNO_COFINS_S  '; */
        v_sql := v_sql || ' FROM MSAFI.DPSP_MASF_INCINERACAO ';
        v_sql := v_sql || ' WHERE DATA_FISCAL BETWEEN 	''' || v_data_inicial || ''' AND ''' || v_data_final || ''' ';
        v_sql := v_sql || ' AND COD_ESTAB = ''' || p_cod_estab || ''' ';

        loga ( '>>> Inicio Relatório Incineração ' || vp_proc_instance
             , FALSE );

        lib_proc.add_tipo ( vp_mproc_id
                          , v_id_arq
                          , p_cod_estab || '_REL_RES_ST_NF_INCINERAÇÃO.XLS'
                          , 2 );

        lib_proc.add ( dsp_planilha.header
                     , ptipo => v_id_arq );
        lib_proc.add ( dsp_planilha.tabela_inicio
                     , ptipo => v_id_arq );

        lib_proc.add ( dsp_planilha.linha ( p_conteudo =>    dsp_planilha.campo ( 'SAIDAS' )
                                                          || --
                                                            dsp_planilha.campo ( '' )
                                                          || --
                                                            dsp_planilha.campo ( '' )
                                                          || --
                                                            dsp_planilha.campo ( '' )
                                                          || --
                                                            dsp_planilha.campo ( '' )
                                                          || --
                                                            dsp_planilha.campo ( '' )
                                                          || --
                                                            dsp_planilha.campo ( '' )
                                                          || --
                                                            dsp_planilha.campo ( '' )
                                                          || --
                                                            dsp_planilha.campo ( '' )
                                                          || --
                                                            dsp_planilha.campo ( '' )
                                                          || --
                                                            dsp_planilha.campo ( '' )
                                                          || --
                                                            dsp_planilha.campo ( '' )
                                                          || --
                                                            dsp_planilha.campo ( '' )
                                                          || --
                                                            dsp_planilha.campo ( '' )
                                                          || --
                                                            dsp_planilha.campo ( '' )
                                                          || --
                                                            dsp_planilha.campo ( '' )
                                                          || --
                                                            dsp_planilha.campo ( '' )
                                                          || --
                                                            dsp_planilha.campo ( '' )
                                                          || --
                                                            dsp_planilha.campo ( '' )
                                                          || --
                                                            dsp_planilha.campo ( '' )
                                                          || --
                                                            dsp_planilha.campo ( '' )
                                                          || --
                                                            dsp_planilha.campo ( '' )
                                                          || --
                                                            dsp_planilha.campo ( '' )
                                                          || --
                                                            dsp_planilha.campo ( '' )
                                                          || --
                                                            dsp_planilha.campo ( '' )
                                                          || --
                                                            dsp_planilha.campo ( 'ENTRADAS'
                                                                               , p_custom => 'BGCOLOR=blue' )
                                                          || --
                                                            dsp_planilha.campo ( ''
                                                                               , p_custom => 'BGCOLOR=blue' )
                                                          || --
                                                            dsp_planilha.campo ( ''
                                                                               , p_custom => 'BGCOLOR=blue' )
                                                          || --
                                                            dsp_planilha.campo ( ''
                                                                               , p_custom => 'BGCOLOR=blue' )
                                                          || --
                                                            dsp_planilha.campo ( ''
                                                                               , p_custom => 'BGCOLOR=blue' )
                                                          || --
                                                            dsp_planilha.campo ( ''
                                                                               , p_custom => 'BGCOLOR=blue' )
                                                          || --
                                                            dsp_planilha.campo ( ''
                                                                               , p_custom => 'BGCOLOR=blue' )
                                                          || --
                                                            dsp_planilha.campo ( ''
                                                                               , p_custom => 'BGCOLOR=blue' )
                                                          || --
                                                            dsp_planilha.campo ( ''
                                                                               , p_custom => 'BGCOLOR=blue' )
                                                          || --
                                                            dsp_planilha.campo ( ''
                                                                               , p_custom => 'BGCOLOR=blue' )
                                                          || --
                                                            dsp_planilha.campo ( ''
                                                                               , p_custom => 'BGCOLOR=blue' )
                                                          || --
                                                            dsp_planilha.campo ( ''
                                                                               , p_custom => 'BGCOLOR=blue' )
                                                          || --
                                                            dsp_planilha.campo ( ''
                                                                               , p_custom => 'BGCOLOR=blue' )
                                                          || --
                                                            dsp_planilha.campo ( ''
                                                                               , p_custom => 'BGCOLOR=blue' )
                                                          || --
                                                            dsp_planilha.campo ( ''
                                                                               , p_custom => 'BGCOLOR=blue' )
                                                          || --
                                                            dsp_planilha.campo ( ''
                                                                               , p_custom => 'BGCOLOR=blue' )
                                                          || --
                                                            dsp_planilha.campo ( ''
                                                                               , p_custom => 'BGCOLOR=blue' )
                                                          || --
                                                            dsp_planilha.campo ( ''
                                                                               , p_custom => 'BGCOLOR=blue' )
                                                          || --
                                                            dsp_planilha.campo ( ''
                                                                               , p_custom => 'BGCOLOR=blue' )
                                                          || --
                                                            dsp_planilha.campo ( ''
                                                                               , p_custom => 'BGCOLOR=blue' )
                                                          || --
                                                            dsp_planilha.campo ( ''
                                                                               , p_custom => 'BGCOLOR=blue' )
                                                          || --
                                                            dsp_planilha.campo ( ''
                                                                               , p_custom => 'BGCOLOR=blue' )
                                                          || --
                                                            dsp_planilha.campo ( ''
                                                                               , p_custom => 'BGCOLOR=blue' )
                                                          || --
                                                            dsp_planilha.campo ( ''
                                                                               , p_custom => 'BGCOLOR=blue' )
                                                          || --
                                                            dsp_planilha.campo ( ''
                                                                               , p_custom => 'BGCOLOR=blue' )
                                                          || --
                                                            dsp_planilha.campo ( ''
                                                                               , p_custom => 'BGCOLOR=blue' )
                                                          || --
                                                            dsp_planilha.campo ( ''
                                                                               , p_custom => 'BGCOLOR=blue' )
                                                          || --
                                                            dsp_planilha.campo ( ''
                                                                               , p_custom => 'BGCOLOR=blue' )
                                                          || --
                                                            dsp_planilha.campo ( ''
                                                                               , p_custom => 'BGCOLOR=blue' )
                                                          || --
                                                            dsp_planilha.campo ( ''
                                                                               , p_custom => 'BGCOLOR=blue' )
                                                          || --
                                                            dsp_planilha.campo ( 'CALCULADO'
                                                                               , p_custom => 'BGCOLOR=green' )
                                                          || --
                                                             -- DSP_PLANILHA.CAMPO('',P_CUSTOM=>'BGCOLOR=green') || --
                                                             dsp_planilha.campo ( ''
                                                                                , p_custom => 'BGCOLOR=green' )
                                                          || --
                                                            dsp_planilha.campo ( ''
                                                                               , p_custom => 'BGCOLOR=green' )
                                                          || --
                                                            dsp_planilha.campo ( ''
                                                                               , p_custom => 'BGCOLOR=green' )
                                                          || --
                                                            dsp_planilha.campo ( ''
                                                                               , p_custom => 'BGCOLOR=green' )
                                                          || --
                                                            dsp_planilha.campo ( ''
                                                                               , p_custom => 'BGCOLOR=green' )
                                                          || --
                                                            dsp_planilha.campo ( ''
                                                                               , p_custom => 'BGCOLOR=green' )
                                          , p_class => 'h' )
                     , ptipo => v_id_arq );

        lib_proc.add ( dsp_planilha.linha ( p_conteudo =>    dsp_planilha.campo ( 'COD_EMPRESA' )
                                                          || -- , COD_EMPRESA
                                                            dsp_planilha.campo ( 'COD_ESTAB' )
                                                          || -- , COD_ESTAB
                                                            dsp_planilha.campo ( 'NUM_DOCFIS' )
                                                          || -- , NUM_DOCFIS
                                                            dsp_planilha.campo ( 'ID_PEOPLE' )
                                                          || -- , NUM_CONTROLE_DOCTO
                                                            dsp_planilha.campo ( 'NUM_ITEM' )
                                                          || -- , NUM_ITEM
                                                            dsp_planilha.campo ( 'COD_PRODUTO' )
                                                          || -- , COD_PRODUTO
                                                            dsp_planilha.campo ( 'DESCR_ITEM' )
                                                          || -- , DESCR_ITEM
                                                            dsp_planilha.campo ( 'DATA_FISCAL' )
                                                          || -- , DATA_FISCAL
                                                            dsp_planilha.campo ( 'UF_ORIGEM' )
                                                          || -- , UF_ORIGEM
                                                            dsp_planilha.campo ( 'UF_DESTINO' )
                                                          || -- , UF_DESTINO
                                                            dsp_planilha.campo ( 'COD_FIS_JUR' )
                                                          || -- , COD_FIS_JUR
                                                            dsp_planilha.campo ( 'CNPJ' )
                                                          || -- , CNPJ
                                                            dsp_planilha.campo ( 'RAZAO_SOCIAL' )
                                                          || -- , RAZAO_SOCIAL
                                                            dsp_planilha.campo ( 'SERIE_DOCFIS' )
                                                          || -- , SERIE_DOCFIS
                                                            dsp_planilha.campo ( 'CFOP' )
                                                          || -- , CFOP
                                                            dsp_planilha.campo ( 'FINALIDADE' )
                                                          || -- , FINALIDADE
                                                            dsp_planilha.campo ( 'NBM' )
                                                          || -- , NBM
                                                            dsp_planilha.campo ( 'CHAVE_DE_ACESSO' )
                                                          || -- , NUM_AUTENTIC_NFE
                                                            dsp_planilha.campo ( 'QUANTIDADE' )
                                                          || -- , QUANTIDADE
                                                            dsp_planilha.campo ( 'VLR_UNIT' )
                                                          || -- , VLR_UNIT
                                                            dsp_planilha.campo ( 'VLR_ITEM' )
                                                          || -- , VLR_ITEM
                                                            dsp_planilha.campo ( 'VLR_BASE_ICMS' )
                                                          || -- , VLR_BASE_ICMS
                                                            dsp_planilha.campo ( 'VLR_ICMS' )
                                                          || -- , VLR_ICMS
                                                            dsp_planilha.campo ( 'ALIQ_ICMS' )
                                                          || -- , ALIQ_ICMS
                                                            dsp_planilha.campo ( 'LISTAPRODUTO' )
                                                          || -- , LISTAPRODUTO
                                                            dsp_planilha.campo ( 'COD_ESTAB_E'
                                                                               , p_custom => 'BGCOLOR=blue' )
                                                          || -- , COD_ESTAB_E
                                                            dsp_planilha.campo ( 'DATA_FISCAL_E'
                                                                               , p_custom => 'BGCOLOR=blue' )
                                                          || -- , DATA_FISCAL_E
                                                            dsp_planilha.campo ( 'NUM_CONTROLE_DOCTO_E'
                                                                               , p_custom => 'BGCOLOR=blue' )
                                                          || -- , NUM_CONTROLE_DOCTO_E
                                                            dsp_planilha.campo ( 'NUM_DOCFIS_E'
                                                                               , p_custom => 'BGCOLOR=blue' )
                                                          || -- , NUM_DOCFIS_E
                                                            dsp_planilha.campo ( 'SERIE_DOCFIS_E'
                                                                               , p_custom => 'BGCOLOR=blue' )
                                                          || -- , SERIE_DOCFIS_E
                                                            dsp_planilha.campo ( 'SUB_SERIE_DOCFIS'
                                                                               , p_custom => 'BGCOLOR=blue' )
                                                          || -- , SUB_SERIE_DOCFIS
                                                            dsp_planilha.campo ( 'DISCRI_ITEM'
                                                                               , p_custom => 'BGCOLOR=blue' )
                                                          || -- , DISCRI_ITEM
                                                            dsp_planilha.campo ( 'COD_FIS_JUR_E'
                                                                               , p_custom => 'BGCOLOR=blue' )
                                                          || -- , COD_FIS_JUR_E
                                                            dsp_planilha.campo ( 'CPF_CGC'
                                                                               , p_custom => 'BGCOLOR=blue' )
                                                          || -- , CPF_CGC
                                                            dsp_planilha.campo ( 'RAZAO_SOCIAL_E'
                                                                               , p_custom => 'BGCOLOR=blue' )
                                                          || -- , RAZAO_SOCIAL
                                                            dsp_planilha.campo ( 'COD_NBM'
                                                                               , p_custom => 'BGCOLOR=blue' )
                                                          || -- , COD_NBM
                                                            dsp_planilha.campo ( 'COD_CFO'
                                                                               , p_custom => 'BGCOLOR=blue' )
                                                          || -- , COD_CFO
                                                             --DSP_PLANILHA.CAMPO('COD_NATUREZA_OP') ||       -- , COD_NATUREZA_OP
                                                             dsp_planilha.campo ( 'VLR_CONTAB_ITEM'
                                                                                , p_custom => 'BGCOLOR=blue' )
                                                          || -- , VLR_CONTAB_ITEM
                                                            dsp_planilha.campo ( 'QUANTIDADE_E'
                                                                               , p_custom => 'BGCOLOR=blue' )
                                                          || -- , QUANTIDADE_E
                                                            dsp_planilha.campo ( 'VLR_UNIT_E'
                                                                               , p_custom => 'BGCOLOR=blue' )
                                                          || -- , VLR_UNIT_E
                                                            dsp_planilha.campo ( 'CST_A'
                                                                               , p_custom => 'BGCOLOR=blue' )
                                                          || -- , COD_SITUACAO_A
                                                            dsp_planilha.campo ( 'CST_B'
                                                                               , p_custom => 'BGCOLOR=blue' )
                                                          || -- , COD_SITUACAO_B
                                                            dsp_planilha.campo ( 'UF'
                                                                               , p_custom => 'BGCOLOR=blue' )
                                                          || -- , COD_ESTADO
                                                            dsp_planilha.campo ( 'CHAVE_ACESSO_E'
                                                                               , p_custom => 'BGCOLOR=blue' )
                                                          || -- , NUM_AUTENTIC_NFE_E
                                                            dsp_planilha.campo ( 'CFOP_FORN'
                                                                               , p_custom => 'BGCOLOR=blue' )
                                                          || -- , CFOP_FORN
                                                            dsp_planilha.campo ( 'VLR_BASE_ICMS_E'
                                                                               , p_custom => 'BGCOLOR=blue' )
                                                          || -- , VLR_BASE_ICMS_E
                                                            dsp_planilha.campo ( 'VLR_ICMS_E'
                                                                               , p_custom => 'BGCOLOR=blue' )
                                                          || -- , VLR_ICMS_E
                                                            dsp_planilha.campo ( 'ALIQ_REDUCAO'
                                                                               , p_custom => 'BGCOLOR=blue' )
                                                          || -- , ALIQ_REDUCAO
                                                            dsp_planilha.campo ( 'VLR_BASE_ICMS_ST'
                                                                               , p_custom => 'BGCOLOR=blue' )
                                                          || -- , VLR_BASE_ICMS_ST
                                                            dsp_planilha.campo ( 'VLR_ICMS_ST'
                                                                               , p_custom => 'BGCOLOR=blue' )
                                                          || -- , VLR_ICMS_ST
                                                            dsp_planilha.campo ( 'VLR_BASE_ICMSST_RET'
                                                                               , p_custom => 'BGCOLOR=blue' )
                                                          || -- ,  VLR_BASE_ICMSST_RET
                                                            dsp_planilha.campo ( 'VLR_ICMSST_RET'
                                                                               , p_custom => 'BGCOLOR=blue' )
                                                          || -- , VLR_ICMSST_RET
                                                             --DSP_PLANILHA.CAMPO('CENARIO',P_CUSTOM=>'BGCOLOR=blue') ||         -- , CLASSIFICACAO
                                                             dsp_planilha.campo ( 'ALIQ_INTERNA'
                                                                                , p_custom => 'BGCOLOR=blue' )
                                                          || -- ,  ALIQ_INTERNA
                                                            dsp_planilha.campo ( 'VLR_ANTECIP_IST'
                                                                               , p_custom => 'BGCOLOR=blue' )
                                                          || -- , VLR_ANTECIP_IST
                                                            dsp_planilha.campo ( 'VLR_ANTECIP_REV'
                                                                               , p_custom => 'BGCOLOR=blue' )
                                                          || -- , VLR_ANTECIP_REV
                                                             --
                                                             --DSP_PLANILHA.CAMPO('VLR_ICMS_CALCULADO',P_CUSTOM=>'BGCOLOR=green') ||    -- , VLR_ICMS_CALCULADO
                                                             --DSP_PLANILHA.CAMPO('VLR_ICMS_RESSARC',P_CUSTOM=>'BGCOLOR=green') ||      -- , VLR_ICMS_RESSARC
                                                             --DSP_PLANILHA.CAMPO('VLR_ICMSST_RESSARC',P_CUSTOM=>'BGCOLOR=green') ||    -- , VLR_ICMSST_RESSARC
                                                             dsp_planilha.campo ( 'RESSARC_ICMS_ST_RET'
                                                                                , p_custom => 'BGCOLOR=green' )
                                                          || -- , RESSARC_ICMS_ST_RET
                                                            dsp_planilha.campo ( 'RESSARC_ICMS_ST'
                                                                               , p_custom => 'BGCOLOR=green' )
                                                          || -- , RESSARC_ICMS_ST
                                                            dsp_planilha.campo ( 'RESSARC_ICMS_ST_ANTECIP'
                                                                               , p_custom => 'BGCOLOR=green' )
                                                          || -- ,    RESSARC_ICMS_ST_ANTECIP
                                                             --
                                                             dsp_planilha.campo ( 'VLR_PIS_UNIT'
                                                                                , p_custom => 'BGCOLOR=green' )
                                                          || -- , VLR_PIS_UNIT
                                                            dsp_planilha.campo ( 'VLR_COFINS_UNIT'
                                                                               , p_custom => 'BGCOLOR=green' )
                                                          || -- , VLR_COFINS_UNIT
                                                            dsp_planilha.campo ( 'VLR_TOTAL_ESTORNO_PIS'
                                                                               , p_custom => 'BGCOLOR=green' )
                                                          || -- , VLR_TOTAL_ESTORNO_PIS
                                                            dsp_planilha.campo ( 'VLR_TOTAL_ESTORNO_COFINS'
                                                                               , p_custom => 'BGCOLOR=green' ) -- , VLR_TOTAL_ESTORNO_COFINS
                                          --DSP_PLANILHA.CAMPO('ESTORNO_PIS_E') || -- , ESTORNO_PIS_E
                                          --DSP_PLANILHA.CAMPO('ESTORNO_COFINS_E') || -- , ESTORNO_COFINS_E
                                          --DSP_PLANILHA.CAMPO('ESTORNO_PIS_S') || -- , ESTORNO_PIS_S
                                          --DSP_PLANILHA.CAMPO('ESTORNO_COFINS_S') -- , ESTORNO_COFINS_S
                                          , p_class => 'h' )
                     , ptipo => v_id_arq );

        BEGIN
            OPEN c_incineracao FOR v_sql;
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
                                        , '!ERRO SELECT INCINERAÇÃO!' );
        END;

        LOOP
            FETCH c_incineracao
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
                                                       || dsp_planilha.campo ( tab_e ( i ).cod_estab )
                                                       || dsp_planilha.campo (
                                                                               dsp_planilha.texto (
                                                                                                    tab_e ( i ).num_docfis
                                                                               )
                                                          )
                                                       || dsp_planilha.campo (
                                                                               dsp_planilha.texto (
                                                                                                    tab_e ( i ).num_controle_docto
                                                                               )
                                                          )
                                                       || dsp_planilha.campo ( tab_e ( i ).num_item )
                                                       || dsp_planilha.campo ( tab_e ( i ).cod_produto )
                                                       || dsp_planilha.campo ( tab_e ( i ).descr_item )
                                                       || dsp_planilha.campo ( tab_e ( i ).data_fiscal )
                                                       || dsp_planilha.campo ( tab_e ( i ).uf_origem )
                                                       || dsp_planilha.campo ( tab_e ( i ).uf_destino )
                                                       || dsp_planilha.campo ( tab_e ( i ).cod_fis_jur )
                                                       || dsp_planilha.campo (
                                                                               dsp_planilha.texto ( tab_e ( i ).cnpj )
                                                          )
                                                       || dsp_planilha.campo ( tab_e ( i ).razao_social )
                                                       || dsp_planilha.campo ( tab_e ( i ).serie_docfis )
                                                       || dsp_planilha.campo ( tab_e ( i ).cfop )
                                                       || dsp_planilha.campo ( tab_e ( i ).finalidade )
                                                       || dsp_planilha.campo ( tab_e ( i ).nbm )
                                                       || dsp_planilha.campo (
                                                                               dsp_planilha.texto (
                                                                                                    tab_e ( i ).num_autentic_nfe
                                                                               )
                                                          )
                                                       || dsp_planilha.campo ( tab_e ( i ).quantidade )
                                                       || dsp_planilha.campo ( tab_e ( i ).vlr_unit )
                                                       || dsp_planilha.campo ( tab_e ( i ).vlr_item )
                                                       || dsp_planilha.campo ( tab_e ( i ).vlr_base_icms )
                                                       || dsp_planilha.campo ( tab_e ( i ).vlr_icms )
                                                       || dsp_planilha.campo ( tab_e ( i ).aliq_icms )
                                                       || dsp_planilha.campo ( tab_e ( i ).listaproduto )
                                                       || dsp_planilha.campo ( tab_e ( i ).cod_estab_e )
                                                       || dsp_planilha.campo ( tab_e ( i ).data_fiscal_e )
                                                       || dsp_planilha.campo (
                                                                               dsp_planilha.texto (
                                                                                                    tab_e ( i ).num_controle_docto_e
                                                                               )
                                                          )
                                                       || dsp_planilha.campo (
                                                                               dsp_planilha.texto (
                                                                                                    tab_e ( i ).num_docfis_e
                                                                               )
                                                          )
                                                       || dsp_planilha.campo ( tab_e ( i ).serie_docfis_e )
                                                       || dsp_planilha.campo ( tab_e ( i ).sub_serie_docfis )
                                                       || dsp_planilha.campo ( tab_e ( i ).discri_item )
                                                       || dsp_planilha.campo ( tab_e ( i ).cod_fis_jur_e )
                                                       || dsp_planilha.campo (
                                                                               dsp_planilha.texto (
                                                                                                    tab_e ( i ).cpf_cgc
                                                                               )
                                                          )
                                                       || dsp_planilha.campo ( tab_e ( i ).razao_social_e )
                                                       || dsp_planilha.campo ( tab_e ( i ).cod_nbm )
                                                       || dsp_planilha.campo ( tab_e ( i ).cod_cfo )
                                                       || --DSP_PLANILHA.CAMPO(TAB_E(I).COD_NATUREZA_OP    ) ||
                                                          dsp_planilha.campo ( tab_e ( i ).vlr_contab_item )
                                                       || dsp_planilha.campo ( tab_e ( i ).quantidade_e )
                                                       || dsp_planilha.campo ( tab_e ( i ).vlr_unit_e )
                                                       || dsp_planilha.campo ( tab_e ( i ).cod_situacao_a )
                                                       || dsp_planilha.campo ( tab_e ( i ).cod_situacao_b )
                                                       || dsp_planilha.campo ( tab_e ( i ).cod_estado )
                                                       || dsp_planilha.campo (
                                                                               dsp_planilha.texto (
                                                                                                    tab_e ( i ).num_autentic_nfe_e
                                                                               )
                                                          )
                                                       || dsp_planilha.campo ( tab_e ( i ).cfop_forn )
                                                       || dsp_planilha.campo ( tab_e ( i ).vlr_base_icms_e )
                                                       || dsp_planilha.campo ( tab_e ( i ).vlr_icms_e )
                                                       || dsp_planilha.campo ( tab_e ( i ).aliq_reducao )
                                                       || dsp_planilha.campo ( tab_e ( i ).vlr_base_icms_st )
                                                       || dsp_planilha.campo ( tab_e ( i ).vlr_icms_st )
                                                       || dsp_planilha.campo ( tab_e ( i ).vlr_base_icmsst_ret )
                                                       || dsp_planilha.campo ( tab_e ( i ).vlr_icmsst_ret )
                                                       || --DSP_PLANILHA.CAMPO(TAB_E(I).CLASSIFICACAO      ) ||
                                                          dsp_planilha.campo ( tab_e ( i ).aliq_interna )
                                                       || dsp_planilha.campo ( tab_e ( i ).vlr_antecip_ist )
                                                       || dsp_planilha.campo ( tab_e ( i ).vlr_antecip_rev )
                                                       || -- DSP_PLANILHA.CAMPO(TAB_E(I).VLR_ICMS_CALCULADO ) ||
                                                          -- DSP_PLANILHA.CAMPO(TAB_E(I).VLR_ICMS_RESSARC   ) ||
                                                          -- DSP_PLANILHA.CAMPO(TAB_E(I).VLR_ICMSST_RESSARC ) ||
                                                          --DSP_PLANILHA.CAMPO(TAB_E(I).EXCLUIR_CAMPO1   ) ||
                                                          dsp_planilha.campo ( tab_e ( i ).ressarc_icms_st_ret )
                                                       || dsp_planilha.campo ( tab_e ( i ).ressarc_icms_st )
                                                       || --DSP_PLANILHA.CAMPO(TAB_E(I).VLR_ICMS_ANT_RES  ) ||
                                                          dsp_planilha.campo ( tab_e ( i ).ressarc_icms_st_antecip )
                                                       || --
                                                          dsp_planilha.campo ( tab_e ( i ).vlr_pis_unit )
                                                       || dsp_planilha.campo ( tab_e ( i ).vlr_cofins_unit )
                                                       || dsp_planilha.campo ( tab_e ( i ).vlr_total_estorno_pis )
                                                       || dsp_planilha.campo ( tab_e ( i ).vlr_total_estorno_cofins )
                                       --DSP_PLANILHA.CAMPO(TAB_E(I).ESTORNO_PIS_E      ) ||
                                       --DSP_PLANILHA.CAMPO(TAB_E(I).ESTORNO_COFINS_E   ) ||
                                       --DSP_PLANILHA.CAMPO(TAB_E(I).ESTORNO_PIS_S      ) ||
                                       --DSP_PLANILHA.CAMPO(TAB_E(I).ESTORNO_COFINS_S   )
                                       , p_class => v_class
                    );
                lib_proc.add ( v_text01
                             , ptipo => v_id_arq );
            END LOOP;

            tab_e.delete;

            EXIT WHEN c_incineracao%NOTFOUND;
        END LOOP;

        COMMIT;

        CLOSE c_incineracao;

        lib_proc.add ( dsp_planilha.tabela_fim
                     , ptipo => v_id_arq );
    END load_incineracao;

    /******************************************************************************FIM - GERA EXCEL INCINERAÇÃO***********************************************************************************/
    /****************************************************************************INICIO - GERA SINTÉTICO EXCEL INCINERAÇÃO***********************************************************************************/

    PROCEDURE load_sintetico ( vp_proc_instance IN VARCHAR
                             , v_data_inicial IN DATE
                             , v_data_final IN DATE
                             , p_cod_estab IN VARCHAR
                             , vp_mproc_id IN NUMBER
                             , v_id_arq IN NUMBER )
    IS
        v_sql VARCHAR2 ( 4000 );
        v_text01 VARCHAR2 ( 3000 );
        v_class VARCHAR2 ( 1 ) := 'a';
        c_sintetic SYS_REFCURSOR;

        TYPE cur_tab_sintetic IS RECORD
        (
            cod_estado VARCHAR2 ( 6 )
          , cod_estab VARCHAR2 ( 6 )
          , data_fiscal VARCHAR2 ( 8 )
          , ressarc_icms_st_ret NUMBER ( 17, 4 )
          , ressarc_icms_st NUMBER ( 17, 4 )
          , ressarc_icms_st_antecip NUMBER ( 17, 4 )
          , --
            vlr_pis_unit NUMBER ( 17, 2 )
          , vlr_cofins_unit NUMBER ( 17, 2 )
          , vlr_total_estorno_pis NUMBER ( 17, 2 )
          , vlr_total_estorno_cofins NUMBER ( 17, 2 )
        );

        /*ESTORNO_PIS_E      NUMBER(17,2),
        ESTORNO_COFINS_E   NUMBER(17,2),
        ESTORNO_PIS_S      NUMBER(17,2),
        ESTORNO_COFINS_S   NUMBER(17,2)) ;*/

        TYPE c_tab_sintetic IS TABLE OF cur_tab_sintetic;

        tab_e c_tab_sintetic;
    BEGIN
        v_sql := ' SELECT DISTINCT UF_ORIGEM AS COD_ESTADO, ';
        v_sql := v_sql || ' COD_ESTAB, ';
        v_sql := v_sql || ' TO_CHAR(DATA_FISCAL, ''MM/YYYY''), ';
        v_sql := v_sql || ' SUM(RESSARC_ICMS_ST_RET) AS RESSARC_ICMS_ST_RET, ';
        v_sql := v_sql || ' SUM(RESSARC_ICMS_ST) AS RESSARC_ICMS_ST, ';
        v_sql := v_sql || ' SUM(RESSARC_ICMS_ST_ANTECIP) AS RESSARC_ICMS_ST_ANTECIP, ';
        v_sql := v_sql || ' SUM(VLR_PIS_UNIT) AS VLR_PIS_UNIT, ';
        v_sql := v_sql || ' SUM(VLR_COFINS_UNIT) AS VLR_COFINS_UNIT, ';
        v_sql := v_sql || ' SUM(VLR_TOTAL_ESTORNO_PIS) AS VLR_TOTAL_ESTORNO_PIS, ';
        v_sql := v_sql || ' SUM(VLR_TOTAL_ESTORNO_COFINS) AS VLR_TOTAL_ESTORNO_COFINS ';
        v_sql := v_sql || ' FROM MSAFI.DPSP_MASF_INCINERACAO  ';
        v_sql := v_sql || ' WHERE DATA_FISCAL BETWEEN 	''' || v_data_inicial || ''' AND ''' || v_data_final || ''' ';
        v_sql := v_sql || ' AND COD_ESTAB = ''' || p_cod_estab || ''' ';
        v_sql := v_sql || ' GROUP BY UF_ORIGEM, COD_ESTAB,TO_CHAR(DATA_FISCAL, ''MM/YYYY'') ';

        loga ( '>>> Inicio Sintetico ' || vp_proc_instance
             , FALSE );

        lib_proc.add_tipo ( vp_mproc_id
                          , v_id_arq
                          , p_cod_estab || '_REL_RES_SINTETICO_INCINERAÇÃO.XLS'
                          , 2 );

        lib_proc.add ( dsp_planilha.header
                     , ptipo => v_id_arq );
        lib_proc.add ( dsp_planilha.tabela_inicio
                     , ptipo => v_id_arq );

        lib_proc.add ( dsp_planilha.linha (
                                            p_conteudo =>    dsp_planilha.campo ( 'COD_ESTADO' )
                                                          || -- , UF_ORIGEM
                                                            dsp_planilha.campo ( 'COD_ESTAB' )
                                                          || -- , COD_ESTAB
                                                            dsp_planilha.campo ( 'DATA_FISCAL' )
                                                          || -- , DATA_FISCAL
                                                            dsp_planilha.campo ( 'RESSARC_ICMS_ST_RET' )
                                                          || -- , RESSARC_ICMS_ST_RET
                                                            dsp_planilha.campo ( 'RESSARC_ICMS_ST' )
                                                          || -- , RESSARC_ICMS_ST
                                                            dsp_planilha.campo ( 'RESSARC_ICMS_ST_ANTECIP' )
                                                          || -- , RESSARC_ICMS_ST_ANTECIP
                                                             --    DSP_PLANILHA.CAMPO('VLR_PIS_UNIT') ||         -- , VLR_PIS_UNIT
                                                             --    DSP_PLANILHA.CAMPO('VLR_COFINS_UNIT') ||      -- , VLR_COFINS_UNIT
                                                             dsp_planilha.campo ( 'VLR_TOTAL_ESTORNO_PIS' )
                                                          || -- , VLR_TOTAL_ESTORNO_PIS
                                                            dsp_planilha.campo ( 'VLR_TOTAL_ESTORNO_COFINS' ) -- , VLR_TOTAL_ESTORNO_COFINS
                                          , p_class => 'h'
                       )
                     , ptipo => v_id_arq );

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
                              , 3072 )
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

                v_text01 :=
                    dsp_planilha.linha (
                                         p_conteudo =>    dsp_planilha.campo ( tab_e ( i ).cod_estado )
                                                       || dsp_planilha.campo ( tab_e ( i ).cod_estab )
                                                       || dsp_planilha.campo ( tab_e ( i ).data_fiscal )
                                                       || dsp_planilha.campo ( tab_e ( i ).ressarc_icms_st_ret )
                                                       || dsp_planilha.campo ( tab_e ( i ).ressarc_icms_st )
                                                       || dsp_planilha.campo ( tab_e ( i ).ressarc_icms_st_antecip )
                                                       || --        DSP_PLANILHA.CAMPO(TAB_E(I).VLR_PIS_UNIT  ) ||
                                                          --        DSP_PLANILHA.CAMPO(TAB_E(I).VLR_COFINS_UNIT  ) ||
                                                          dsp_planilha.campo ( tab_e ( i ).vlr_total_estorno_pis )
                                                       || dsp_planilha.campo ( tab_e ( i ).vlr_total_estorno_cofins )
                                       , p_class => v_class
                    );

                lib_proc.add ( v_text01
                             , ptipo => v_id_arq );
            END LOOP;

            tab_e.delete;

            EXIT WHEN c_sintetic%NOTFOUND;
        END LOOP;

        COMMIT;

        CLOSE c_sintetic;

        lib_proc.add ( dsp_planilha.tabela_fim
                     , ptipo => v_id_arq );
    END load_sintetico;

    /******************************************************************************FIM - GERA EXCEL SINTÉTICO***********************************************************************************/

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
    END; --PROCEDURE DELETE_TEMP_TBL

    FUNCTION executar ( p_data_ini DATE
                      , p_data_fim DATE
                      , p_cod_estab lib_proc.vartab )
        RETURN INTEGER
    IS
        mproc_id INTEGER;
        i1 INTEGER;

        --V_PROC_STATUS           NUMBER  := 0;
        v_validar_status INTEGER := 0;
        v_qtde_inc NUMBER := 0;
        v_qtd INTEGER;

        v_id_arq NUMBER := 90;

        TYPE a_estabs_t IS TABLE OF VARCHAR2 ( 6 );

        a_estabs a_estabs_t := a_estabs_t ( );

        --TABELAS TEMP
        --V_NOME_TABELA_ALIQ    VARCHAR2(30);
        --V_TAB_ENTRADA_C       VARCHAR2(30);
        --DPSP_DEV_PMCMVA       VARCHAR2(30);
        --V_TAB_DEV_PMC     VARCHAR2(30);
        ---
        --V_SQL_RESULTADO       VARCHAR2(4000);
        v_sql VARCHAR2 ( 4000 );
        --V_INSERT        VARCHAR2(5000);
        vp_proc_instance VARCHAR2 ( 30 );
        --VP_COUNT_SAIDA      NUMBER;
        --V_QTDE_TMP        NUMBER := 0;
        --VP_DATA_HORA_INI      VARCHAR2(20);

        ------------------------------------------------------------------------------------------------------------------------------------------------------
        --RANGE DE DATAS PARA BUSCAR VENDAS
        v_data_inicial DATE := p_data_ini; -- DATA INICIAL
        v_data_final DATE := p_data_fim; -- DATA FINAL
    ------------------------------------------------------------------------------------------------------------------------------------------------------

    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS='',.'' ';

        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        musuario := lib_parametros.recuperar ( 'USUARIO' );

        mproc_id :=
            lib_proc.new ( 'DPSP_FIN42_REL_INCINE_CPROC'
                         , 48
                         , 150 );

        lib_proc.add_tipo ( mproc_id
                          , 1
                          ,    TO_CHAR ( SYSDATE
                                       , 'YYYYMMDDHH24MISS' )
                            || '_REL_INCINERACAO'
                          , 1 );

        --MARCAR INCIO DA EXECUCAO
        --VP_DATA_HORA_INI := TO_CHAR(SYSDATE,'DD/MM/YYYY HH24:MI.SS');

        lib_proc.add_header ( 'Executar processamento do Relatório de Incineração'
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

        loga ( '---INI DO PROCESSAMENTO---'
             , FALSE );
        loga ( '<< PERIODO DE: ' || v_data_inicial || ' A ' || v_data_final || ' >>'
             , FALSE );

        --PREPARAR COD_ESTAB
        IF ( p_cod_estab.COUNT > 0 ) THEN
            i1 := p_cod_estab.FIRST;

            WHILE i1 IS NOT NULL LOOP
                a_estabs.EXTEND ( );
                a_estabs ( a_estabs.LAST ) := p_cod_estab ( i1 );
                i1 := p_cod_estab.NEXT ( i1 );
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

            --=================================================================================
            -- VALIDAR STATUS DE RELATÓRIOS ENCERRADOS
            --=================================================================================
            -- IGUAL À ZERO:      PARA PROCESSOS ABERTOS - AÇÃO: CARREGAR TABELA DEV MERC ST
            -- DIFERENTE DE ZERO: PARA PROCESSOS ENCERRADOS - AÇÃO: CONSULTAR TABELA DEV MERC ST
            ---------------------

            v_validar_status :=
                msaf.dpsp_suporte_cproc_process.validar_status_rel ( mcod_empresa
                                                                   , a_estabs ( est )
                                                                   , TO_NUMBER ( TO_CHAR ( v_data_inicial
                                                                                         , 'YYYYMM' ) )
                                                                   , $$plsql_unit );

            --=================================================================================
            -- CARREGAR TABELA Devolução Mercadoria ST em periodos Abertos
            --=================================================================================
            IF v_validar_status = 0 THEN
                loga ( '>> INICIO CD: ' || a_estabs ( est ) || ' PROC INSERT ' || vp_proc_instance
                     , FALSE );

                v_sql := 'SELECT COUNT(*) AS V_QTDE_INC ';
                v_sql := v_sql || 'FROM MSAFI.DPSP_MASF_INCINERACAO ';
                v_sql := v_sql || 'WHERE COD_EMPRESA = ''' || mcod_empresa || ''' ';
                v_sql := v_sql || 'AND COD_ESTAB = ''' || a_estabs ( est ) || ''' ';
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

                IF v_qtd <> 0 THEN
                    loga ( 'PERIODO JÁ PROCESSADO' );

                    ---------------------
                    v_id_arq := v_id_arq + 1;

                    --CARREGAR INCINERAÇÃO
                    load_incineracao ( vp_proc_instance
                                     , v_data_inicial
                                     , v_data_final
                                     , a_estabs ( est )
                                     , mproc_id
                                     , v_id_arq );

                    v_id_arq := v_id_arq + 1;

                    load_sintetico ( vp_proc_instance
                                   , v_data_inicial
                                   , v_data_final
                                   , a_estabs ( est )
                                   , mproc_id
                                   , v_id_arq );
                ELSE
                    loga ( 'PERIODO AINDA NÃO PROCESSADO - SEM DADOS DE ORIGEM!' );
                END IF;
            END IF;

            v_qtd := 0;
            v_retorno_status := '';
        END LOOP; --(1)

        delete_temp_tbl ( vp_proc_instance );

        loga ( '---FIM DO PROCESSAMENTO [SUCESSO]---'
             , FALSE );

        --ENVIAR EMAIL DE SUCESSO----------------------------------------
        --ENVIA_EMAIL(MCOD_EMPRESA, V_DATA_INICIAL, V_DATA_FINAL, '', 'S', VP_DATA_HORA_INI);
        -----------------------------------------------------------------

        lib_proc.add ( 'FIM DO PROCESSAMENTO [SUCESSO]' );
        lib_proc.add ( 'Favor verificar LOG para detalhes.' );
        lib_proc.close;
        COMMIT;
        RETURN mproc_id;
    EXCEPTION
        WHEN OTHERS THEN
            --MSAFI.DSP_CONTROL.LOG_CHECKPOINT(SQLERRM,'Erro não tratado, executador de interfaces');
            loga ( 'SQLERRM: ' || SQLERRM
                 , FALSE );

            lib_proc.add_log ( 'Erro não tratado: ' || dbms_utility.format_error_backtrace
                             , 1 );
            lib_proc.add_log ( 'SQLERRM: ' || SQLERRM
                             , 1 );
            lib_proc.add ( 'ERRO!' );
            lib_proc.add ( dbms_utility.format_error_backtrace );

            --ENVIAR EMAIL DE ERRO-------------------------------------------
            --ENVIA_EMAIL(MCOD_EMPRESA, V_DATA_INICIAL, V_DATA_FINAL, SQLERRM, 'E', V_DATA_HORA_INI);
            -----------------------------------------------------------------

            lib_proc.close;
            COMMIT;
            RETURN mproc_id;
    END; /* FUNCTION EXECUTAR */
END dpsp_fin42_rel_incine_cproc;
/
SHOW ERRORS;
