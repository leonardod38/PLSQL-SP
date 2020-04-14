Prompt Package Body DPSP_FIN4405_CEST_REL_CPROC;
--
-- DPSP_FIN4405_CEST_REL_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_fin4405_cest_rel_cproc
IS
    v_sel_data_fim VARCHAR2 ( 260 )
        := ' SELECT TRUNC( TO_DATE( :1 ,''DD/MM/YYYY'') + ROWNUM - 1) AS DATA_FIM, TRUNC( TO_DATE( :1 ,''DD/MM/YYYY'') + ROWNUM - 1) AS DATA_FIM FROM DUAL CONNECT BY ROWNUM <= LAST_DAY( TO_DATE( :1 ,''DD/MM/YYYY'') ) - TO_DATE( :1 ,''DD/MM/YYYY'') + 1 ORDER BY 1 DESC ';
    v_tab_footer VARCHAR2 ( 100 )
        := ' STORAGE (BUFFER_POOL KEEP) PCTFREE 10 NOLOGGING NOCOMPRESS CACHE TABLESPACE MSAF_WORK_TABLES ';
    vp_tab_safx VARCHAR2 ( 30 );
    vp_tab_x2013 VARCHAR2 ( 30 );
    vp_tab_aux1 VARCHAR2 ( 30 );
    mproc_id INTEGER;

    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );
    BEGIN
        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        mcod_estab := lib_parametros.recuperar ( 'ESTABELECIMENTO' );
        -- MUSUARIO     := LIB_PARAMETROS.RECUPERAR('USUARIO');

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
                           , 'Período'
                           , --P_PERIODO
                            'DATE'
                           , 'TEXTBOX'
                           , 'S'
                           ,   TRUNC ( SYSDATE
                                     , 'MM' )
                             - 1
                           , 'MM/YYYY' ); -- R001

        lib_proc.add_param ( pstr
                           , -- R001
                            ' '
                           , --
                            'VARCHAR2'
                           , 'TEXT' );
        lib_proc.add_param ( pstr
                           , -- R001
                            '___________________________________________________________'
                           , --
                            'VARCHAR2'
                           , 'TEXT' );
        lib_proc.add_param ( pstr
                           , -- R001
                            'Gerou o Livro?'
                           , --P_VERIFICOU
                            'VARCHAR2'
                           , 'RADIOBUTTON'
                           , 'S'
                           , 'NAO'
                           , NULL
                           , 'NAO=Não,SIM=Sim' );
        lib_proc.add_param ( pstr
                           , -- R001
                            '___________________________________________________________'
                           , --
                            'VARCHAR2'
                           , 'TEXT' );

        lib_proc.add_param (
                             pstr
                           , 'Estabelecimentos'
                           , --P_LOJAS
                            'VARCHAR2'
                           , 'MULTISELECT'
                           , 'S'
                           , NULL
                           , NULL
                           , ' SELECT COD_ESTAB , COD_ESTAB FROM MSAFI.DSP_ESTABELECIMENTO WHERE COD_ESTADO = ''RJ'' ORDER BY 1 ASC '
        );

        RETURN pstr;
    END; --FUNCTION PARAMETROS RETURN VARCHAR2 IS

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Relatório de Estorno Cesta Básica - RJ';
    END;

    FUNCTION tipo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Processos - Fiscal';
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
        RETURN 'Processamento do Relatório de Estorno Cesta Básica - RJ';
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

    PROCEDURE limpa_item_apurac ( p_lojas IN OUT VARCHAR2
                                , v_data_ini IN OUT DATE
                                , v_data_fim IN OUT DATE )
    IS
    BEGIN
        DELETE FROM msaf.item_apurac_discr iad
              WHERE iad.cod_empresa = mcod_empresa
                AND iad.cod_estab = p_lojas
                AND iad.dat_apuracao BETWEEN v_data_ini AND v_data_fim
                AND iad.cod_oper_apur IN ( '003'
                                         , '007' )
                AND ( iad.val_item_discrim = 0
                  OR iad.dsc_item_apuracao IN
                         (    'Estorno de Débito - VR. REF. PROD. CESTA BASICA CONFORME DECRETO 46.543/2018  REF. '
                           || TO_CHAR ( v_data_fim
                                      , 'MM/YYYY' )
                           || ' '
                         ,    'Estorno de Crédito - VR. REF. PROD. CESTA BASICA CONFORME DECRETO 46.543/2018  REF. '
                           || TO_CHAR ( v_data_fim
                                      , 'MM/YYYY' )
                           || ' ' ) )
                AND EXISTS
                        (SELECT 'Y'
                           FROM msafi.dsp_estabelecimento est1
                          WHERE est1.cod_empresa = iad.cod_empresa
                            AND est1.cod_estab = iad.cod_estab);

        COMMIT;
    END limpa_item_apurac;

    ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    PROCEDURE load_tab_gtt ( p_lojas IN OUT VARCHAR2
                           , v_data_ini IN OUT DATE
                           , v_data_fim IN OUT DATE
                           , p_periodo IN VARCHAR2 )
    IS
    BEGIN
        ---  LOGA(TO_CHAR(P_PERIODO,'MM/YYYY'));
        INSERT INTO msafi.dpsp_cesta_basica_gtt
            SELECT   a.cod_empresa
                   , a.cod_estab
                   , a.movto_e_s
                   , a.data_fiscal
                   , a.num_docfis
                   , a.num_controle_docto
                   , a.cod_cfo
                   , a.cod_produto
                   , a.descricao
                   , a.cod_natureza_op
                   , a.cod_situacao_b
                   , a.cod_nbm
                   , a.quantidade
                   , a.vlr_unit
                   , a.vlr_item
                   , a.vlr_contab_item
                   , a.base_icms
                   , a.aliq_tributo_icms
                   , a.icms
                   , a.base_isento
                   , a.base_outras
                   , a.base_reduz
                   , a.base_ipi
                   , a.valor_ipi
                   , a.base_icmss
                   , a.vlr_icmss
                   , a.frete
                   , a.despesas
                   , ( a.aliq_tributo_icms - 7 ) AS perc_estorno
                   , ROUND (
                             CASE
                                 WHEN a.base_reduz > 0 THEN 0
                                 ELSE ( a.base_icms * ( ( a.aliq_tributo_icms - 7 ) / 100 ) )
                             END
                           , 2
                     )
                         AS valor_estorno
                   , DECODE ( a.movto_e_s, '9', 'D', 'C' ) AS estorno_credito_debito
                   , NVL ( ( SELECT DISTINCT 'S'
                               FROM msaf.apuracao ap
                              WHERE ap.cod_empresa = a.cod_empresa
                                AND ap.cod_estab = a.cod_estab
                                AND ap.cod_tipo_livro = '108'
                                AND ap.dat_apuracao = LAST_DAY ( v_data_fim ) )
                         , 'N' )
                         apuracao
                FROM (SELECT x07.cod_empresa
                           , x07.cod_estab
                           , x07.data_fiscal
                           , x07.num_docfis
                           , x07.num_controle_docto
                           , x2012.cod_cfo
                           , x07.movto_e_s
                           , x2013.cod_produto
                           , x2013.descricao
                           , x2006.cod_natureza_op
                           , y2026.cod_situacao_b
                           , x2043.cod_nbm
                           , x08.quantidade
                           , x08.vlr_unit
                           , x08.vlr_item
                           , x08.vlr_contab_item
                           , NVL ( ( SELECT vlr_base
                                       FROM msaf.x08_base_merc g
                                      WHERE g.cod_empresa = x08.cod_empresa
                                        AND g.cod_estab = x08.cod_estab
                                        AND g.data_fiscal = x08.data_fiscal
                                        AND g.movto_e_s = x08.movto_e_s
                                        AND g.norm_dev = x08.norm_dev
                                        AND g.ident_docto = x08.ident_docto
                                        AND g.ident_fis_jur = x08.ident_fis_jur
                                        AND g.num_docfis = x08.num_docfis
                                        AND g.serie_docfis = x08.serie_docfis
                                        AND g.sub_serie_docfis = x08.sub_serie_docfis
                                        AND g.discri_item = x08.discri_item
                                        AND g.cod_tributacao = '1'
                                        AND g.cod_tributo = 'ICMS' )
                                 , 0 )
                                 AS base_icms
                           , NVL ( ( SELECT g.aliq_tributo
                                       FROM msaf.x08_trib_merc g
                                      WHERE g.cod_empresa = x08.cod_empresa
                                        AND g.cod_estab = x08.cod_estab
                                        AND g.data_fiscal = x08.data_fiscal
                                        AND g.movto_e_s = x08.movto_e_s
                                        AND g.norm_dev = x08.norm_dev
                                        AND g.ident_docto = x08.ident_docto
                                        AND g.ident_fis_jur = x08.ident_fis_jur
                                        AND g.num_docfis = x08.num_docfis
                                        AND g.serie_docfis = x08.serie_docfis
                                        AND g.sub_serie_docfis = x08.sub_serie_docfis
                                        AND g.discri_item = x08.discri_item
                                        AND g.cod_tributo = 'ICMS' )
                                 , 0 )
                                 AS aliq_tributo_icms
                           , NVL ( ( SELECT g.vlr_tributo
                                       FROM msaf.x08_trib_merc g
                                      WHERE g.cod_empresa = x08.cod_empresa
                                        AND g.cod_estab = x08.cod_estab
                                        AND g.data_fiscal = x08.data_fiscal
                                        AND g.movto_e_s = x08.movto_e_s
                                        AND g.norm_dev = x08.norm_dev
                                        AND g.ident_docto = x08.ident_docto
                                        AND g.ident_fis_jur = x08.ident_fis_jur
                                        AND g.num_docfis = x08.num_docfis
                                        AND g.serie_docfis = x08.serie_docfis
                                        AND g.sub_serie_docfis = x08.sub_serie_docfis
                                        AND g.discri_item = x08.discri_item
                                        AND g.cod_tributo = 'ICMS' )
                                 , 0 )
                                 AS icms
                           , NVL ( ( SELECT vlr_base
                                       FROM msaf.x08_base_merc g
                                      WHERE g.cod_empresa = x08.cod_empresa
                                        AND g.cod_estab = x08.cod_estab
                                        AND g.data_fiscal = x08.data_fiscal
                                        AND g.movto_e_s = x08.movto_e_s
                                        AND g.norm_dev = x08.norm_dev
                                        AND g.ident_docto = x08.ident_docto
                                        AND g.ident_fis_jur = x08.ident_fis_jur
                                        AND g.num_docfis = x08.num_docfis
                                        AND g.serie_docfis = x08.serie_docfis
                                        AND g.sub_serie_docfis = x08.sub_serie_docfis
                                        AND g.discri_item = x08.discri_item
                                        AND g.cod_tributacao = '2'
                                        AND g.cod_tributo = 'ICMS' )
                                 , 0 )
                                 AS base_isento
                           , x08.vlr_outras base_outras
                           , NVL ( ( SELECT vlr_base
                                       FROM msaf.x08_base_merc g
                                      WHERE g.cod_empresa = x08.cod_empresa
                                        AND g.cod_estab = x08.cod_estab
                                        AND g.data_fiscal = x08.data_fiscal
                                        AND g.movto_e_s = x08.movto_e_s
                                        AND g.norm_dev = x08.norm_dev
                                        AND g.ident_docto = x08.ident_docto
                                        AND g.ident_fis_jur = x08.ident_fis_jur
                                        AND g.num_docfis = x08.num_docfis
                                        AND g.serie_docfis = x08.serie_docfis
                                        AND g.sub_serie_docfis = x08.sub_serie_docfis
                                        AND g.discri_item = x08.discri_item
                                        AND g.cod_tributacao = '4'
                                        AND g.cod_tributo = 'ICMS' )
                                 , 0 )
                                 base_reduz
                           , NVL ( ( SELECT vlr_base
                                       FROM msaf.x08_base_merc g
                                      WHERE g.cod_empresa = x08.cod_empresa
                                        AND g.cod_estab = x08.cod_estab
                                        AND g.data_fiscal = x08.data_fiscal
                                        AND g.movto_e_s = x08.movto_e_s
                                        AND g.norm_dev = x08.norm_dev
                                        AND g.ident_docto = x08.ident_docto
                                        AND g.ident_fis_jur = x08.ident_fis_jur
                                        AND g.num_docfis = x08.num_docfis
                                        AND g.serie_docfis = x08.serie_docfis
                                        AND g.sub_serie_docfis = x08.sub_serie_docfis
                                        AND g.discri_item = x08.discri_item
                                        AND g.cod_tributacao = '1'
                                        AND g.cod_tributo = 'IPI' )
                                 , 0 )
                                 base_ipi
                           , NVL ( ( SELECT g.vlr_tributo
                                       FROM msaf.x08_trib_merc g
                                      WHERE g.cod_empresa = x08.cod_empresa
                                        AND g.cod_estab = x08.cod_estab
                                        AND g.data_fiscal = x08.data_fiscal
                                        AND g.movto_e_s = x08.movto_e_s
                                        AND g.norm_dev = x08.norm_dev
                                        AND g.ident_docto = x08.ident_docto
                                        AND g.ident_fis_jur = x08.ident_fis_jur
                                        AND g.num_docfis = x08.num_docfis
                                        AND g.serie_docfis = x08.serie_docfis
                                        AND g.sub_serie_docfis = x08.sub_serie_docfis
                                        AND g.discri_item = x08.discri_item
                                        AND g.cod_tributo = 'IPI' )
                                 , 0 )
                                 AS valor_ipi
                           , NVL ( ( SELECT vlr_base
                                       FROM msaf.x08_base_merc g
                                      WHERE g.cod_empresa = x08.cod_empresa
                                        AND g.cod_estab = x08.cod_estab
                                        AND g.data_fiscal = x08.data_fiscal
                                        AND g.movto_e_s = x08.movto_e_s
                                        AND g.norm_dev = x08.norm_dev
                                        AND g.ident_docto = x08.ident_docto
                                        AND g.ident_fis_jur = x08.ident_fis_jur
                                        AND g.num_docfis = x08.num_docfis
                                        AND g.serie_docfis = x08.serie_docfis
                                        AND g.sub_serie_docfis = x08.sub_serie_docfis
                                        AND g.discri_item = x08.discri_item
                                        AND g.cod_tributacao = '1'
                                        AND g.cod_tributo = 'ICMS-S' )
                                 , 0 )
                                 base_icmss
                           , NVL ( ( SELECT g.vlr_tributo
                                       FROM msaf.x08_trib_merc g
                                      WHERE g.cod_empresa = x08.cod_empresa
                                        AND g.cod_estab = x08.cod_estab
                                        AND g.data_fiscal = x08.data_fiscal
                                        AND g.movto_e_s = x08.movto_e_s
                                        AND g.norm_dev = x08.norm_dev
                                        AND g.ident_docto = x08.ident_docto
                                        AND g.ident_fis_jur = x08.ident_fis_jur
                                        AND g.num_docfis = x08.num_docfis
                                        AND g.serie_docfis = x08.serie_docfis
                                        AND g.sub_serie_docfis = x08.sub_serie_docfis
                                        AND g.discri_item = x08.discri_item
                                        AND g.cod_tributo = 'ICMS-S' )
                                 , 0 )
                                 AS vlr_icmss
                           , x08.vlr_frete AS frete
                           , x08.vlr_outras AS despesas
                        FROM msaf.x07_docto_fiscal x07
                           , msaf.x08_itens_merc x08
                           , msaf.x2013_produto x2013
                           , msaf.x2006_natureza_op x2006
                           , msaf.y2026_sit_trb_uf_b y2026
                           , msaf.x2012_cod_fiscal x2012
                           , --X2043.COD_CFO
                            msaf.x2043_cod_nbm x2043
                           , msafi.dpsp_fin4405_cest_arquivo@dblink_dbmspprd prd
                           , (SELECT cod_estab
                                FROM msafi.dsp_estabelecimento
                               WHERE cod_estado = 'RJ') est
                       WHERE 1 = 1
                         AND x08.data_fiscal BETWEEN v_data_ini AND v_data_fim
                         AND x07.cod_estab = p_lojas
                         AND x07.situacao = 'N'
                         AND x07.cod_empresa = x08.cod_empresa
                         AND x07.cod_estab = x08.cod_estab
                         AND x07.data_fiscal = x08.data_fiscal
                         AND x07.movto_e_s = x08.movto_e_s
                         AND x07.norm_dev = x08.norm_dev
                         AND x07.ident_docto = x08.ident_docto
                         AND x07.ident_fis_jur = x08.ident_fis_jur
                         AND x07.num_docfis = x08.num_docfis
                         AND x07.serie_docfis = x08.serie_docfis
                         AND x07.sub_serie_docfis = x08.sub_serie_docfis
                         AND x2013.ident_produto = x08.ident_produto
                         AND x07.cod_estab = est.cod_estab
                         AND x2012.ident_cfo = x08.ident_cfo
                         AND x2043.ident_nbm = x08.ident_nbm
                         AND prd.cod_produto = x2013.cod_produto
                         AND prd.periodo = p_periodo
                         AND x2006.ident_natureza_op = x08.ident_natureza_op
                         AND y2026.ident_situacao_b = x08.ident_situacao_b) a
               WHERE a.aliq_tributo_icms > 7
            ORDER BY a.cod_estab
                   , a.movto_e_s
                   , a.data_fiscal;

        COMMIT;
    END;

    ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    PROCEDURE load_excel_analitico_lj ( p_proc_instance IN VARCHAR
                                      , v_data_ini IN OUT DATE
                                      , v_data_fim IN OUT DATE )
    IS
        v_sql VARCHAR2 ( 20000 );
        v_text01 VARCHAR2 ( 20000 );
        v_class VARCHAR2 ( 1 ) := 'a';
        c_conc SYS_REFCURSOR;
        v_data_inicial_p VARCHAR2 ( 30 );


        TYPE cur_tab_conc IS RECORD
        (
            cod_empresa VARCHAR2 ( 3 )
          , cod_estab VARCHAR2 ( 6 )
          , movto_e_s CHAR ( 1 )
          , data_fiscal DATE
          , num_docfis VARCHAR2 ( 12 )
          , num_controle_docto VARCHAR2 ( 12 )
          , cod_cfo VARCHAR2 ( 4 )
          , cod_produto VARCHAR2 ( 35 )
          , descricao VARCHAR2 ( 50 )
          , cod_natureza_op VARCHAR2 ( 3 )
          , cod_situacao_b VARCHAR2 ( 2 )
          , cod_nbm VARCHAR2 ( 10 )
          , quantidade NUMBER ( 17, 6 )
          , vlr_unit NUMBER ( 19, 4 )
          , vlr_item NUMBER ( 17, 2 )
          , vlr_contab_item NUMBER ( 17, 2 )
          , base_icms NUMBER ( 17, 2 )
          , aliq_tributo_icms NUMBER ( 17, 2 )
          , icms NUMBER ( 17, 2 )
          , base_isento NUMBER ( 17, 2 )
          , base_outras NUMBER ( 17, 2 )
          , base_reduz NUMBER ( 17, 2 )
          , base_ipi NUMBER ( 17, 2 )
          , valor_ipi NUMBER ( 17, 2 )
          , base_icmss NUMBER ( 17, 2 )
          , vlr_icmss NUMBER ( 17, 2 )
          , frete NUMBER ( 17, 2 )
          , despesas NUMBER ( 17, 2 )
          , perc_estorno NUMBER ( 17, 2 )
          , valor_estorno NUMBER ( 17, 2 )
          , estorno_credito_debito VARCHAR2 ( 1 )
        );


        TYPE c_tab_conc IS TABLE OF cur_tab_conc;

        tab_e c_tab_conc;
    BEGIN
        v_sql := ' SELECT ';
        v_sql := v_sql || '  A.COD_EMPRESA               ';
        v_sql := v_sql || ' ,A.COD_ESTAB                 ';
        v_sql := v_sql || ' ,A.MOVTO_E_S                 ';
        v_sql := v_sql || ' ,A.DATA_FISCAL               ';
        v_sql := v_sql || ' ,A.NUM_DOCFIS                ';
        v_sql := v_sql || ' ,A.NUM_CONTROLE_DOCTO        ';
        v_sql := v_sql || ' ,A.COD_CFO                   ';
        v_sql := v_sql || ' ,A.COD_PRODUTO               ';
        v_sql := v_sql || ' ,A.DESCRICAO                 ';
        v_sql := v_sql || ' ,A.COD_NATUREZA_OP           ';
        v_sql := v_sql || ' ,A.COD_SITUACAO_B            ';
        v_sql := v_sql || ' ,A.COD_NBM                   ';
        v_sql := v_sql || ' ,A.QUANTIDADE                ';
        v_sql := v_sql || ' ,A.VLR_UNIT                  ';
        v_sql := v_sql || ' ,A.VLR_ITEM                  ';
        v_sql := v_sql || ' ,A.VLR_CONTAB_ITEM           ';
        v_sql := v_sql || ' ,A.BASE_ICMS                 ';
        v_sql := v_sql || ' ,A.ALIQ_TRIBUTO_ICMS         ';
        v_sql := v_sql || ' ,A.ICMS                      ';
        v_sql := v_sql || ' ,A.BASE_ISENTO               ';
        v_sql := v_sql || ' ,A.BASE_OUTRAS               ';
        v_sql := v_sql || ' ,A.BASE_REDUZ                ';
        v_sql := v_sql || ' ,A.BASE_IPI                  ';
        v_sql := v_sql || ' ,A.VALOR_IPI                 ';
        v_sql := v_sql || ' ,A.BASE_ICMSS                ';
        v_sql := v_sql || ' ,A.VLR_ICMSS                 ';
        v_sql := v_sql || ' ,A.FRETE                     ';
        v_sql := v_sql || ' ,A.DESPESAS                  ';
        v_sql := v_sql || ' ,A.PERC_ESTORNO              ';
        v_sql := v_sql || ' ,A.VALOR_ESTORNO             ';
        v_sql := v_sql || ' ,A.ESTORNO_CREDITO_DEBITO    ';
        v_sql := v_sql || ' FROM MSAFI.DPSP_CESTA_BASICA_GTT A ';
        v_sql :=
               v_sql
            || ' WHERE A.COD_ESTAB IN (SELECT COD_ESTAB FROM MSAFI.DSP_ESTABELECIMENTO WHERE COD_ESTADO = ''RJ'' AND TIPO = ''L'') ';
        v_sql := v_sql || ' ORDER BY A.COD_ESTAB ASC ';

        loga ( '>>> Inicio Analitico - Lojas ' || p_proc_instance
             , FALSE );

        v_data_inicial_p :=
            TO_CHAR ( v_data_ini
                    , 'MM-YYYY' );

        lib_proc.add_tipo ( p_proc_instance
                          , 99
                          , mcod_empresa || '_REL_ANALITICO_LJ_CESTA_BASICA_' || v_data_inicial_p || '.XLS'
                          , 2 );

        lib_proc.add ( dsp_planilha.header
                     , ptipo => 99 );
        lib_proc.add ( dsp_planilha.tabela_inicio
                     , ptipo => 99 );

        lib_proc.add ( dsp_planilha.linha ( p_conteudo => dsp_planilha.campo ( 'LOJAS'
                                                                             , p_custom => 'COLSPAN=29' )
                                          , p_class => 'h' )
                     , ptipo => 99 );

        lib_proc.add ( dsp_planilha.linha (
                                            p_conteudo =>    dsp_planilha.campo ( 'COD_EMPRESA' )
                                                          || --
                                                            dsp_planilha.campo ( 'COD_ESTAB' )
                                                          || --
                                                            dsp_planilha.campo ( 'MOVTO_E_S' )
                                                          || --
                                                            dsp_planilha.campo ( 'DATA_FISCAL' )
                                                          || --
                                                            dsp_planilha.campo ( 'NUM_DOCFIS' )
                                                          || --
                                                            dsp_planilha.campo ( 'NUM_CONTROLE_DOCTO' )
                                                          || --
                                                            dsp_planilha.campo ( 'COD_CFO' )
                                                          || --
                                                            dsp_planilha.campo ( 'COD_PRODUTO' )
                                                          || --
                                                            dsp_planilha.campo ( 'DESCRICAO' )
                                                          || --
                                                            dsp_planilha.campo ( 'COD_NATUREZA_OP' )
                                                          || --
                                                            dsp_planilha.campo ( 'COD_SITUACAO_B' )
                                                          || --
                                                            dsp_planilha.campo ( 'COD_NBM' )
                                                          || --
                                                            dsp_planilha.campo ( 'QUANTIDADE' )
                                                          || --
                                                            dsp_planilha.campo ( 'VLR_UNIT' )
                                                          || --
                                                            dsp_planilha.campo ( 'VLR_ITEM' )
                                                          || --
                                                            dsp_planilha.campo ( 'VLR_CONTAB_ITEM' )
                                                          || --
                                                            dsp_planilha.campo ( 'BASE_ICMS' )
                                                          || --
                                                            dsp_planilha.campo ( 'ALIQ_TRIBUTO_ICMS' )
                                                          || --
                                                            dsp_planilha.campo ( 'ICMS' )
                                                          || --
                                                            dsp_planilha.campo ( 'BASE_ISENTO' )
                                                          || --
                                                            dsp_planilha.campo ( 'BASE_OUTRAS' )
                                                          || --
                                                            dsp_planilha.campo ( 'BASE_REDUZ' )
                                                          || --
                                                            dsp_planilha.campo ( 'BASE_IPI' )
                                                          || --
                                                            dsp_planilha.campo ( 'VALOR_IPI' )
                                                          || --
                                                            dsp_planilha.campo ( 'BASE_ICMSS' )
                                                          || --
                                                            dsp_planilha.campo ( 'VLR_ICMSS' )
                                                          || --
                                                            dsp_planilha.campo ( 'FRETE' )
                                                          || --
                                                            dsp_planilha.campo ( 'DESPESAS' )
                                                          || dsp_planilha.campo ( 'PERC_ESTORNO' )
                                                          || --
                                                            dsp_planilha.campo ( 'VALOR_ESTORNO' )
                                                          || --
                                                            dsp_planilha.campo ( 'ESTORNO_CREDITO_DEBITO' )
                                          --
                                          , p_class => 'h'
                       )
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
                                        , '!ERRO SELECT CESTA BASICA!' );
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
                                         p_conteudo =>    dsp_planilha.campo ( tab_e ( i ).cod_empresa )
                                                       || --COD_EMPRESA
                                                         dsp_planilha.campo ( tab_e ( i ).cod_estab )
                                                       || --COD_ESTAB
                                                         dsp_planilha.campo ( tab_e ( i ).movto_e_s )
                                                       || --MOVTO_E_S
                                                         dsp_planilha.campo ( tab_e ( i ).data_fiscal )
                                                       || --DATA_FISCAL
                                                         dsp_planilha.campo (
                                                                              dsp_planilha.texto (
                                                                                                   tab_e ( i ).num_docfis
                                                                              )
                                                          )
                                                       || --NUM_DOCFIS
                                                         dsp_planilha.campo (
                                                                              dsp_planilha.texto (
                                                                                                   tab_e ( i ).num_controle_docto
                                                                              )
                                                          )
                                                       || --NUM_CONTROLE_DOCTO
                                                         dsp_planilha.campo ( tab_e ( i ).cod_cfo )
                                                       || --COD_CFO
                                                         dsp_planilha.campo ( tab_e ( i ).cod_produto )
                                                       || --COD_PRODUTO
                                                         dsp_planilha.campo (
                                                                              dsp_planilha.texto (
                                                                                                   tab_e ( i ).descricao
                                                                              )
                                                          )
                                                       || --DESCRICAO
                                                         dsp_planilha.campo ( tab_e ( i ).cod_natureza_op )
                                                       || --COD_NATUREZA_OP
                                                         dsp_planilha.campo (
                                                                              dsp_planilha.texto (
                                                                                                   tab_e ( i ).cod_situacao_b
                                                                              )
                                                          )
                                                       || --COD_SITUACAO_B
                                                         dsp_planilha.campo ( tab_e ( i ).cod_nbm )
                                                       || --COD_NBM
                                                         dsp_planilha.campo ( tab_e ( i ).quantidade )
                                                       || --QUANTIDADE
                                                         dsp_planilha.campo ( tab_e ( i ).vlr_unit )
                                                       || --VLR_UNIT
                                                         dsp_planilha.campo ( tab_e ( i ).vlr_item )
                                                       || --VLR_ITEM
                                                         dsp_planilha.campo ( tab_e ( i ).vlr_contab_item )
                                                       || --VLR_CONTAB_ITEM
                                                         dsp_planilha.campo ( tab_e ( i ).base_icms )
                                                       || --BASE_ICMS
                                                         dsp_planilha.campo ( tab_e ( i ).aliq_tributo_icms )
                                                       || --ALIQ_TRIBUTO_ICMS
                                                         dsp_planilha.campo ( tab_e ( i ).icms )
                                                       || --ICMS
                                                         dsp_planilha.campo ( tab_e ( i ).base_isento )
                                                       || --BASE_ISENTO
                                                         dsp_planilha.campo ( tab_e ( i ).base_outras )
                                                       || --BASE_OUTRAS
                                                         dsp_planilha.campo (
                                                                              dsp_planilha.texto (
                                                                                                   tab_e ( i ).base_reduz
                                                                              )
                                                          )
                                                       || --BASE_REDUZ
                                                         dsp_planilha.campo ( tab_e ( i ).base_ipi )
                                                       || --BASE_IPI
                                                         dsp_planilha.campo ( tab_e ( i ).valor_ipi )
                                                       || --VALOR_IPI
                                                         dsp_planilha.campo ( tab_e ( i ).base_icmss )
                                                       || --BASE_ICMSS
                                                         dsp_planilha.campo (
                                                                              dsp_planilha.texto (
                                                                                                   tab_e ( i ).vlr_icmss
                                                                              )
                                                          )
                                                       || --VLR_ICMSS
                                                         dsp_planilha.campo ( tab_e ( i ).frete )
                                                       || --FRETE
                                                         dsp_planilha.campo ( tab_e ( i ).despesas )
                                                       || --DESPESAS
                                                         dsp_planilha.campo ( tab_e ( i ).perc_estorno )
                                                       || --PERC_ESTORNO
                                                         dsp_planilha.campo ( tab_e ( i ).valor_estorno )
                                                       || --VALOR_ESTORNO
                                                         dsp_planilha.campo ( tab_e ( i ).estorno_credito_debito ) --ESTORNO_CREDITO_DEBITO
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
    END load_excel_analitico_lj;

    ------------------------------------------------------------------------------FIM - ANALITICO----------------------------------------------------------------------------
    ----------------------------------------------------------------------------INICIO - SINTETICO----------------------------------------------------------------------------
    PROCEDURE load_excel_sintetico_lj ( p_proc_instance IN VARCHAR
                                      , v_data_ini IN OUT DATE
                                      , v_data_fim IN OUT DATE )
    IS
        v_sql VARCHAR2 ( 20000 );
        v_text01 VARCHAR2 ( 20000 );
        v_class VARCHAR2 ( 1 ) := 'a';
        c_conc SYS_REFCURSOR;
        v_data_inicial_p VARCHAR2 ( 30 );


        TYPE cur_tab_conc IS RECORD
        (
            periodo VARCHAR2 ( 10 )
          , cod_estab VARCHAR2 ( 6 )
          , estorno_credito NUMBER ( 17, 2 )
          , estorno_debito NUMBER ( 17, 2 )
        );

        TYPE c_tab_conc IS TABLE OF cur_tab_conc;

        tab_e c_tab_conc;
    BEGIN
        v_sql := ' SELECT ';
        v_sql := v_sql || ' TO_CHAR(B.DATA_FISCAL,''MM/YYYY'') PERIODO,               ';
        v_sql := v_sql || ' B.COD_ESTAB,                                              ';
        v_sql :=
               v_sql
            || ' SUM(CASE WHEN B.ESTORNO_CREDITO_DEBITO = ''C'' THEN B.VALOR_ESTORNO ELSE 0 END) AS ESTORNO_CREDITO,                 ';
        v_sql :=
               v_sql
            || ' SUM(CASE WHEN B.ESTORNO_CREDITO_DEBITO = ''D'' THEN B.VALOR_ESTORNO ELSE 0 END) AS ESTORNO_DEBITO                   ';
        v_sql := v_sql || ' FROM MSAFI.DPSP_CESTA_BASICA_GTT B                ';
        v_sql := v_sql || ' GROUP BY TO_CHAR(B.DATA_FISCAL,''MM/YYYY'') , B.COD_ESTAB ';
        v_sql := v_sql || ' ORDER BY B.COD_ESTAB ASC ';


        loga ( '>>> Inicio Sintético - Lojas ' || p_proc_instance
             , FALSE );

        v_data_inicial_p :=
            TO_CHAR ( v_data_ini
                    , 'MM-YYYY' );

        lib_proc.add_tipo ( p_proc_instance
                          , 2
                          , mcod_empresa || '_REL_SINTETICO_LJ_CESTA_BASICA_' || v_data_inicial_p || '.XLS'
                          , 2 );

        lib_proc.add ( dsp_planilha.header
                     , ptipo => 2 );
        lib_proc.add ( dsp_planilha.tabela_inicio
                     , ptipo => 2 );

        lib_proc.add ( dsp_planilha.linha ( p_conteudo => dsp_planilha.campo ( 'LOJAS - SINTÉTICO'
                                                                             , p_custom => 'COLSPAN=4' )
                                          , p_class => 'h' )
                     , ptipo => 2 );

        lib_proc.add ( dsp_planilha.linha (
                                            p_conteudo =>    dsp_planilha.campo ( 'PERIODO' )
                                                          || dsp_planilha.campo ( 'COD_ESTAB' )
                                                          || dsp_planilha.campo ( 'ESTORNO_CREDITO' )
                                                          || dsp_planilha.campo ( 'ESTORNO_DEBITO' ) --
                                          , p_class => 'h'
                       )
                     , ptipo => 2 );

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
                                        , '!ERRO SELECT CESTA BASICA!' );
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
                                         p_conteudo =>    dsp_planilha.campo ( tab_e ( i ).periodo )
                                                       || dsp_planilha.campo ( tab_e ( i ).cod_estab )
                                                       || dsp_planilha.campo ( tab_e ( i ).estorno_credito )
                                                       || dsp_planilha.campo ( tab_e ( i ).estorno_debito )
                                       , p_class => v_class
                    );
                lib_proc.add ( v_text01
                             , ptipo => 2 );
            END LOOP;

            tab_e.delete;

            EXIT WHEN c_conc%NOTFOUND;
        END LOOP;

        COMMIT;

        CLOSE c_conc;

        lib_proc.add ( dsp_planilha.tabela_fim
                     , ptipo => 2 );
    END load_excel_sintetico_lj;

    -----------------------------------------------------------------------------------------------------------------------------------------------------------------------

    PROCEDURE load_excel_analitico_cd ( p_proc_instance IN VARCHAR
                                      , v_data_ini IN OUT DATE
                                      , v_data_fim IN OUT DATE )
    IS
        v_sql VARCHAR2 ( 20000 );
        v_text01 VARCHAR2 ( 20000 );
        v_class VARCHAR2 ( 1 ) := 'a';
        c_conc SYS_REFCURSOR;
        v_data_inicial_p VARCHAR2 ( 30 );


        TYPE cur_tab_conc IS RECORD
        (
            cod_empresa VARCHAR2 ( 3 )
          , cod_estab VARCHAR2 ( 6 )
          , movto_e_s CHAR ( 1 )
          , data_fiscal DATE
          , num_docfis VARCHAR2 ( 12 )
          , num_controle_docto VARCHAR2 ( 12 )
          , cod_cfo VARCHAR2 ( 4 )
          , cod_produto VARCHAR2 ( 35 )
          , descricao VARCHAR2 ( 50 )
          , cod_natureza_op VARCHAR2 ( 3 )
          , cod_situacao_b VARCHAR2 ( 2 )
          , cod_nbm VARCHAR2 ( 10 )
          , quantidade NUMBER ( 17, 6 )
          , vlr_unit NUMBER ( 19, 4 )
          , vlr_item NUMBER ( 17, 2 )
          , vlr_contab_item NUMBER ( 17, 2 )
          , base_icms NUMBER ( 17, 2 )
          , aliq_tributo_icms NUMBER ( 17, 2 )
          , icms NUMBER ( 17, 2 )
          , base_isento NUMBER ( 17, 2 )
          , base_outras NUMBER ( 17, 2 )
          , base_reduz NUMBER ( 17, 2 )
          , base_ipi NUMBER ( 17, 2 )
          , valor_ipi NUMBER ( 17, 2 )
          , base_icmss NUMBER ( 17, 2 )
          , vlr_icmss NUMBER ( 17, 2 )
          , frete NUMBER ( 17, 2 )
          , despesas NUMBER ( 17, 2 )
          , perc_estorno NUMBER ( 17, 2 )
          , valor_estorno NUMBER ( 17, 2 )
          , estorno_credito_debito VARCHAR2 ( 1 )
        );


        TYPE c_tab_conc IS TABLE OF cur_tab_conc;

        tab_e c_tab_conc;
    BEGIN
        v_sql := ' SELECT ';
        v_sql := v_sql || '  A.COD_EMPRESA               ';
        v_sql := v_sql || ' ,A.COD_ESTAB                 ';
        v_sql := v_sql || ' ,A.MOVTO_E_S                 ';
        v_sql := v_sql || ' ,A.DATA_FISCAL               ';
        v_sql := v_sql || ' ,A.NUM_DOCFIS                ';
        v_sql := v_sql || ' ,A.NUM_CONTROLE_DOCTO        ';
        v_sql := v_sql || ' ,A.COD_CFO                   ';
        v_sql := v_sql || ' ,A.COD_PRODUTO               ';
        v_sql := v_sql || ' ,A.DESCRICAO                 ';
        v_sql := v_sql || ' ,A.COD_NATUREZA_OP           ';
        v_sql := v_sql || ' ,A.COD_SITUACAO_B            ';
        v_sql := v_sql || ' ,A.COD_NBM                   ';
        v_sql := v_sql || ' ,A.QUANTIDADE                ';
        v_sql := v_sql || ' ,A.VLR_UNIT                  ';
        v_sql := v_sql || ' ,A.VLR_ITEM                  ';
        v_sql := v_sql || ' ,A.VLR_CONTAB_ITEM           ';
        v_sql := v_sql || ' ,A.BASE_ICMS                 ';
        v_sql := v_sql || ' ,A.ALIQ_TRIBUTO_ICMS         ';
        v_sql := v_sql || ' ,A.ICMS                      ';
        v_sql := v_sql || ' ,A.BASE_ISENTO               ';
        v_sql := v_sql || ' ,A.BASE_OUTRAS               ';
        v_sql := v_sql || ' ,A.BASE_REDUZ                ';
        v_sql := v_sql || ' ,A.BASE_IPI                  ';
        v_sql := v_sql || ' ,A.VALOR_IPI                 ';
        v_sql := v_sql || ' ,A.BASE_ICMSS                ';
        v_sql := v_sql || ' ,A.VLR_ICMSS                 ';
        v_sql := v_sql || ' ,A.FRETE                     ';
        v_sql := v_sql || ' ,A.DESPESAS                  ';
        v_sql := v_sql || ' ,A.PERC_ESTORNO              ';
        v_sql := v_sql || ' ,A.VALOR_ESTORNO             ';
        v_sql := v_sql || ' ,A.ESTORNO_CREDITO_DEBITO    ';
        v_sql := v_sql || ' FROM MSAFI.DPSP_CESTA_BASICA_GTT A ';
        v_sql :=
               v_sql
            || ' WHERE A.COD_ESTAB IN (SELECT COD_ESTAB FROM MSAFI.DSP_ESTABELECIMENTO WHERE COD_ESTADO = ''RJ'' AND TIPO = ''C'') ';
        v_sql := v_sql || ' ORDER BY A.COD_ESTAB DESC ';

        loga ( '>>> Inicio Analitico - CDs ' || p_proc_instance
             , FALSE );

        v_data_inicial_p :=
            TO_CHAR ( v_data_ini
                    , 'MM-YYYY' );

        lib_proc.add_tipo ( p_proc_instance
                          , 999
                          , mcod_empresa || '_REL_ANALITICO_CD_CESTA_BASICA_' || v_data_inicial_p || '.XLS'
                          , 2 );

        lib_proc.add ( dsp_planilha.header
                     , ptipo => 999 );
        lib_proc.add ( dsp_planilha.tabela_inicio
                     , ptipo => 999 );

        lib_proc.add ( dsp_planilha.linha ( p_conteudo => dsp_planilha.campo ( 'CDS'
                                                                             , p_custom => 'COLSPAN=29' )
                                          , p_class => 'h' )
                     , ptipo => 999 );

        lib_proc.add ( dsp_planilha.linha (
                                            p_conteudo =>    dsp_planilha.campo ( 'COD_EMPRESA' )
                                                          || --
                                                            dsp_planilha.campo ( 'COD_ESTAB' )
                                                          || --
                                                            dsp_planilha.campo ( 'MOVTO_E_S' )
                                                          || --
                                                            dsp_planilha.campo ( 'DATA_FISCAL' )
                                                          || --
                                                            dsp_planilha.campo ( 'NUM_DOCFIS' )
                                                          || --
                                                            dsp_planilha.campo ( 'NUM_CONTROLE_DOCTO' )
                                                          || --
                                                            dsp_planilha.campo ( 'COD_CFO' )
                                                          || --
                                                            dsp_planilha.campo ( 'COD_PRODUTO' )
                                                          || --
                                                            dsp_planilha.campo ( 'DESCRICAO' )
                                                          || --
                                                            dsp_planilha.campo ( 'COD_NATUREZA_OP' )
                                                          || --
                                                            dsp_planilha.campo ( 'COD_SITUACAO_B' )
                                                          || --
                                                            dsp_planilha.campo ( 'COD_NBM' )
                                                          || --
                                                            dsp_planilha.campo ( 'QUANTIDADE' )
                                                          || --
                                                            dsp_planilha.campo ( 'VLR_UNIT' )
                                                          || --
                                                            dsp_planilha.campo ( 'VLR_ITEM' )
                                                          || --
                                                            dsp_planilha.campo ( 'VLR_CONTAB_ITEM' )
                                                          || --
                                                            dsp_planilha.campo ( 'BASE_ICMS' )
                                                          || --
                                                            dsp_planilha.campo ( 'ALIQ_TRIBUTO_ICMS' )
                                                          || --
                                                            dsp_planilha.campo ( 'ICMS' )
                                                          || --
                                                            dsp_planilha.campo ( 'BASE_ISENTO' )
                                                          || --
                                                            dsp_planilha.campo ( 'BASE_OUTRAS' )
                                                          || --
                                                            dsp_planilha.campo ( 'BASE_REDUZ' )
                                                          || --
                                                            dsp_planilha.campo ( 'BASE_IPI' )
                                                          || --
                                                            dsp_planilha.campo ( 'VALOR_IPI' )
                                                          || --
                                                            dsp_planilha.campo ( 'BASE_ICMSS' )
                                                          || --
                                                            dsp_planilha.campo ( 'VLR_ICMSS' )
                                                          || --
                                                            dsp_planilha.campo ( 'FRETE' )
                                                          || --
                                                            dsp_planilha.campo ( 'DESPESAS' )
                                                          || dsp_planilha.campo ( 'PERC_ESTORNO' )
                                                          || --
                                                            dsp_planilha.campo ( 'VALOR_ESTORNO' )
                                                          || --
                                                            dsp_planilha.campo ( 'ESTORNO_CREDITO_DEBITO' )
                                          --
                                          , p_class => 'h'
                       )
                     , ptipo => 999 );

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
                                        , '!ERRO SELECT CESTA BASICA!' );
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
                                         p_conteudo =>    dsp_planilha.campo ( tab_e ( i ).cod_empresa )
                                                       || --COD_EMPRESA
                                                         dsp_planilha.campo ( tab_e ( i ).cod_estab )
                                                       || --COD_ESTAB
                                                         dsp_planilha.campo ( tab_e ( i ).movto_e_s )
                                                       || --MOVTO_E_S
                                                         dsp_planilha.campo ( tab_e ( i ).data_fiscal )
                                                       || --DATA_FISCAL
                                                         dsp_planilha.campo (
                                                                              dsp_planilha.texto (
                                                                                                   tab_e ( i ).num_docfis
                                                                              )
                                                          )
                                                       || --NUM_DOCFIS
                                                         dsp_planilha.campo (
                                                                              dsp_planilha.texto (
                                                                                                   tab_e ( i ).num_controle_docto
                                                                              )
                                                          )
                                                       || --NUM_CONTROLE_DOCTO
                                                         dsp_planilha.campo ( tab_e ( i ).cod_cfo )
                                                       || --COD_CFO
                                                         dsp_planilha.campo ( tab_e ( i ).cod_produto )
                                                       || --COD_PRODUTO
                                                         dsp_planilha.campo (
                                                                              dsp_planilha.texto (
                                                                                                   tab_e ( i ).descricao
                                                                              )
                                                          )
                                                       || --DESCRICAO
                                                         dsp_planilha.campo ( tab_e ( i ).cod_natureza_op )
                                                       || dsp_planilha.campo (
                                                                               dsp_planilha.texto (
                                                                                                    tab_e ( i ).cod_situacao_b
                                                                               )
                                                          )
                                                       || dsp_planilha.campo ( tab_e ( i ).cod_situacao_b )
                                                       || --COD_SITUACAO_B
                                                         dsp_planilha.campo ( tab_e ( i ).cod_nbm )
                                                       || --COD_NBM
                                                         dsp_planilha.campo ( tab_e ( i ).quantidade )
                                                       || --QUANTIDADE
                                                         dsp_planilha.campo ( tab_e ( i ).vlr_unit )
                                                       || --VLR_UNIT
                                                         dsp_planilha.campo ( tab_e ( i ).vlr_item )
                                                       || --VLR_ITEM
                                                         dsp_planilha.campo ( tab_e ( i ).vlr_contab_item )
                                                       || --VLR_CONTAB_ITEM
                                                         dsp_planilha.campo ( tab_e ( i ).base_icms )
                                                       || --BASE_ICMS
                                                         dsp_planilha.campo ( tab_e ( i ).aliq_tributo_icms )
                                                       || --ALIQ_TRIBUTO_ICMS
                                                         dsp_planilha.campo ( tab_e ( i ).icms )
                                                       || --ICMS
                                                         dsp_planilha.campo ( tab_e ( i ).base_isento )
                                                       || --BASE_ISENTO
                                                         dsp_planilha.campo ( tab_e ( i ).base_outras )
                                                       || --BASE_OUTRAS
                                                         dsp_planilha.campo (
                                                                              dsp_planilha.texto (
                                                                                                   tab_e ( i ).base_reduz
                                                                              )
                                                          )
                                                       || --BASE_REDUZ
                                                         dsp_planilha.campo ( tab_e ( i ).base_ipi )
                                                       || --BASE_IPI
                                                         dsp_planilha.campo ( tab_e ( i ).valor_ipi )
                                                       || --VALOR_IPI
                                                         dsp_planilha.campo ( tab_e ( i ).base_icmss )
                                                       || --BASE_ICMSS
                                                         dsp_planilha.campo (
                                                                              dsp_planilha.texto (
                                                                                                   tab_e ( i ).vlr_icmss
                                                                              )
                                                          )
                                                       || --VLR_ICMSS
                                                         dsp_planilha.campo ( tab_e ( i ).frete )
                                                       || --FRETE
                                                         dsp_planilha.campo ( tab_e ( i ).despesas )
                                                       || --DESPESAS
                                                         dsp_planilha.campo ( tab_e ( i ).perc_estorno )
                                                       || --PERC_ESTORNO
                                                         dsp_planilha.campo (
                                                                                 moeda ( tab_e ( i ).valor_estorno )
                                                                              || dsp_planilha.campo (
                                                                                                      tab_e ( i ).estorno_credito_debito
                                                                                 )
                                                          ) --ESTORNO_CREDITO_DEBITO
                                       , p_class => v_class
                    );
                lib_proc.add ( v_text01
                             , ptipo => 999 );
            END LOOP;

            tab_e.delete;

            EXIT WHEN c_conc%NOTFOUND;
        END LOOP;

        COMMIT;

        CLOSE c_conc;

        lib_proc.add ( dsp_planilha.tabela_fim
                     , ptipo => 999 );
    END load_excel_analitico_cd;

    ------------------------------------------------------------------------------FIM - ANALITICO----------------------------------------------------------------------------
    ----------------------------------------------------------------------------INICIO - SINTETICO----------------------------------------------------------------------------
    PROCEDURE load_excel_sintetico_cd ( p_proc_instance IN VARCHAR
                                      , v_data_ini IN OUT DATE
                                      , v_data_fim IN OUT DATE )
    IS
        v_sql VARCHAR2 ( 20000 );
        v_text01 VARCHAR2 ( 20000 );
        v_class VARCHAR2 ( 1 ) := 'a';
        c_conc SYS_REFCURSOR;
        v_data_inicial_p VARCHAR2 ( 30 );


        TYPE cur_tab_conc IS RECORD
        (
            periodo VARCHAR2 ( 10 )
          , cod_estab VARCHAR2 ( 6 )
          , estorno_credito NUMBER ( 17, 6 )
          , estorno_debito NUMBER ( 17, 2 )
        );

        TYPE c_tab_conc IS TABLE OF cur_tab_conc;

        tab_e c_tab_conc;
    BEGIN
        v_sql := ' SELECT ';
        v_sql := v_sql || ' TO_CHAR(B.DATA_FISCAL,''MM/YYYY'') PERIODO,               ';
        v_sql := v_sql || ' B.COD_ESTAB,                                              ';
        v_sql :=
               v_sql
            || ' SUM(CASE WHEN B.ESTORNO_CREDITO_DEBITO = ''C'' THEN B.VALOR_ESTORNO ELSE 0 END) AS ESTORNO_CREDITO,                 ';
        v_sql :=
               v_sql
            || ' SUM(CASE WHEN B.ESTORNO_CREDITO_DEBITO = ''D'' THEN B.VALOR_ESTORNO ELSE 0 END) AS ESTORNO_DEBITO                   ';
        v_sql := v_sql || ' FROM MSAFI.DPSP_CESTA_BASICA_GTT B                ';
        v_sql :=
               v_sql
            || ' WHERE B.COD_ESTAB IN (SELECT COD_ESTAB FROM MSAFI.DSP_ESTABELECIMENTO WHERE COD_ESTADO = ''RJ'' AND TIPO = ''C'') ';
        v_sql := v_sql || ' GROUP BY TO_CHAR(B.DATA_FISCAL,''MM/YYYY'') , B.COD_ESTAB ';
        v_sql := v_sql || ' ORDER BY B.COD_ESTAB DESC ';


        loga ( '>>> Inicio Sintético - CDs ' || p_proc_instance
             , FALSE );

        v_data_inicial_p :=
            TO_CHAR ( v_data_ini
                    , 'MM-YYYY' );

        lib_proc.add_tipo ( p_proc_instance
                          , 88
                          , mcod_empresa || '_REL_SINTETICO_CD_CESTA_BASICA_' || v_data_inicial_p || '.XLS'
                          , 2 );

        lib_proc.add ( dsp_planilha.header
                     , ptipo => 88 );
        lib_proc.add ( dsp_planilha.tabela_inicio
                     , ptipo => 88 );

        lib_proc.add ( dsp_planilha.linha ( p_conteudo => dsp_planilha.campo ( 'CD - SINTÉTICO'
                                                                             , p_custom => 'COLSPAN=4' )
                                          , p_class => 'h' )
                     , ptipo => 88 );

        lib_proc.add ( dsp_planilha.linha (
                                            p_conteudo =>    dsp_planilha.campo ( 'PERIODO' )
                                                          || dsp_planilha.campo ( 'COD_ESTAB' )
                                                          || dsp_planilha.campo ( 'ESTORNO_CREDITO' )
                                                          || dsp_planilha.campo ( 'ESTORNO_DEBITO' ) --
                                          , p_class => 'h'
                       )
                     , ptipo => 88 );

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
                                        , '!ERRO SELECT CESTA BASICA!' );
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
                                         p_conteudo =>    dsp_planilha.campo ( tab_e ( i ).periodo )
                                                       || dsp_planilha.campo ( tab_e ( i ).cod_estab )
                                                       || dsp_planilha.campo ( moeda ( tab_e ( i ).estorno_credito ) )
                                                       || dsp_planilha.campo ( moeda ( tab_e ( i ).estorno_debito ) )
                                       , p_class => v_class
                    );
                lib_proc.add ( v_text01
                             , ptipo => 88 );
            END LOOP;

            tab_e.delete;

            EXIT WHEN c_conc%NOTFOUND;
        END LOOP;

        COMMIT;

        CLOSE c_conc;

        lib_proc.add ( dsp_planilha.tabela_fim
                     , ptipo => 88 );
    END load_excel_sintetico_cd;


    FUNCTION credito_cesta_basica ( p_lojas IN OUT VARCHAR2
                                  , mproc_id IN OUT INTEGER
                                  , p_data1 IN OUT DATE
                                  , p_data2 IN OUT DATE
                                  , p_periodo IN VARCHAR2 )
        RETURN NUMBER
    IS
        v_chave VARCHAR2 ( 100 ) := NULL;
        v_class CHAR ( 1 ) := 'A';
        v_item_apurac item_apurac_discr%ROWTYPE;
        v_cont NUMBER;
        p_periodos VARCHAR2 ( 8 );


        CURSOR crs_estab ( v_cod_empresa VARCHAR2 )
        IS
            SELECT   *
                FROM msafi.dsp_estabelecimento
               WHERE cod_empresa = v_cod_empresa
                 AND cod_estab = p_lojas
            ORDER BY cod_estab;

        rs_itens crs_itens%ROWTYPE;
    BEGIN
        v_cont := 0;
        v_chave := NULL;
        p_periodos := p_periodo;

        FOR est IN crs_estab ( mcod_empresa ) LOOP
            OPEN crs_itens ( mcod_empresa
                           , est.cod_estab
                           , p_data1
                           , p_data2
                           , p_periodos );

            v_item_apurac.cod_empresa := mcod_empresa;
            v_item_apurac.cod_estab := est.cod_estab;
            v_item_apurac.cod_tipo_livro := '108';
            v_item_apurac.dat_apuracao := p_data2;

            v_item_apurac.ind_dig_calculado := '1';
            v_item_apurac.ind_est_deb_conv := 'N';
            v_item_apurac.val_item_discrim := 0;

            LOOP
                FETCH crs_itens
                    INTO rs_itens;

                EXIT WHEN crs_itens%NOTFOUND;

                v_item_apurac.val_item_discrim := rs_itens.valor_estorno;

                IF NVL ( v_chave, ' ' ) <>
                       rs_itens.cod_empresa || '|' || rs_itens.cod_estab || '|' || rs_itens.movto_e_s THEN
                    IF rs_itens.movto_e_s = '9' THEN
                        v_item_apurac.cod_oper_apur := '007';
                        v_item_apurac.cod_amparo_legal := 'N089999';
                        v_item_apurac.cod_sub_item_ocorr := '01';
                        v_item_apurac.cod_ajuste_icms := 'RJ039999';
                    ELSE
                        v_item_apurac.cod_oper_apur := '003';
                        v_item_apurac.cod_amparo_legal := 'N030005';
                        v_item_apurac.cod_sub_item_ocorr := '';
                        v_item_apurac.cod_ajuste_icms := 'RJ010005';
                    END IF;

                    IF rs_itens.movto_e_s = '9' THEN
                        v_item_apurac.dsc_item_apuracao :=
                               'Estorno de Débito - VR. REF. PROD. CESTA BASICA CONFORME DECRETO 46.543/2018  REF. '
                            || TO_CHAR ( p_data2
                                       , 'MM/YYYY' )
                            || ' ';
                    ELSE
                        v_item_apurac.dsc_item_apuracao :=
                               'Estorno de Crédito - VR. REF. PROD. CESTA BASICA CONFORME DECRETO 46.543/2018  REF. '
                            || TO_CHAR ( p_data2
                                       , 'MM/YYYY' )
                            || ' ';
                    END IF;

                    IF v_item_apurac.val_item_discrim > 0 THEN
                        IF rs_itens.apuracao = 'N' THEN
                            lib_proc.add ( 'ERRO: NÃO FOI POSSÍVEL INSERIR REGISTROS, VERIFIQUE APURAÇÃO:' );
                            lib_proc.add (
                                              ' - ESTABELECIMENTO: '
                                           || v_item_apurac.cod_estab
                                           || '    | LIVRO: '
                                           || v_item_apurac.cod_tipo_livro
                                           || '    | DATA APURAÇÃO: '
                                           || v_item_apurac.dat_apuracao
                                           || '    | COD_OPER_APUR: '
                                           || v_item_apurac.cod_oper_apur
                            );
                        ELSE
                            SELECT NVL ( ( SELECT MAX ( num_discriminacao ) + 1
                                             FROM msaf.item_apurac_discr siad
                                            WHERE siad.cod_empresa = rs_itens.cod_empresa
                                              AND siad.cod_estab = v_item_apurac.cod_estab
                                              AND siad.cod_tipo_livro = v_item_apurac.cod_tipo_livro
                                              AND siad.dat_apuracao = v_item_apurac.dat_apuracao
                                              AND siad.cod_oper_apur = v_item_apurac.cod_oper_apur )
                                       , 1 )
                              INTO v_item_apurac.num_discriminacao -- NUM_DISCRIMINACAO
                              FROM DUAL;

                            v_item_apurac.val_item_discrim := rs_itens.valor_estorno;

                            v_chave := rs_itens.cod_empresa || '|' || rs_itens.cod_estab || '|' || rs_itens.movto_e_s;

                            INSERT INTO item_apurac_discr
                            VALUES v_item_apurac;

                            v_cont := v_cont + 1;
                        END IF;
                    END IF;
                END IF;


                IF v_class = 'A' THEN
                    v_class := 'B';
                ELSE
                    v_class := 'A';
                END IF;
            --
            END LOOP;

            CLOSE crs_itens;
        END LOOP;


        RETURN v_cont;
    END credito_cesta_basica;

    ------------------------------------------------------------------------------------------------------------------------------------------------------
    FUNCTION executar ( p_periodo DATE
                      , p_verificou VARCHAR2
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
        vp_proc_instance VARCHAR2 ( 30 );
        --Data periodo
        p_data1 DATE;
        p_data2 DATE;

        p_mes NUMBER; -- R001
        p_ano NUMBER; -- R001

        --
        TYPE cur_typ IS REF CURSOR;

        cr_cup cur_typ;

        ---
        v_sql_resultado VARCHAR2 ( 4000 );
        v_id_param NUMBER;
        v_data_hora_ini VARCHAR2 ( 20 );
        p_periodos VARCHAR2 ( 8 );
    BEGIN
        p_mes :=
            TO_NUMBER ( TO_CHAR ( p_periodo
                                , 'MM' ) ); -- R001
        p_ano :=
            TO_NUMBER ( TO_CHAR ( p_periodo
                                , 'YYYY' ) ); -- R001

        EXECUTE IMMEDIATE 'ALTER SESSION SET TEMP_UNDO_ENABLED=FALSE '; --EVITAR PROBLEMAS

        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS='',.'' ';

        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        musuario := lib_parametros.recuperar ( 'USUARIO' );

        mproc_id :=
            lib_proc.new ( 'DPSP_FIN4405_CEST_REL_CPROC'
                         , 48
                         , 150 );
        lib_proc.add_tipo ( mproc_id
                          , 1
                          ,    TO_CHAR ( SYSDATE
                                       , 'YYYYMMDDHH24MISS' )
                            || '_CESTA_BASICA'
                          , 1 );

        --MARCAR INCIO DA EXECUCAO
        v_data_hora_ini :=
            TO_CHAR ( SYSDATE
                    , 'DD/MM/YYYY HH24:MI.SS' );

        lib_proc.add_header ( 'Executar processamento do Relatório de Estorno de Cesta Básica '
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

        IF p_verificou <> 'SIM' THEN
            lib_proc.add_log (
                               'VOCÊ DEVE GERAR A APURAÇÃO! (CASO TENHA GERADO, RESPONDA SIM NA PERGUNTA "GEROU O LIVRO?" NA TELA INICIAL)'
                             , 0
            );
            lib_proc.add ( 'ERRO! VERIFIQUE O LOG!' );
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

        --GERAR CHAVE PROC_ID
        SELECT ROUND ( dbms_random.VALUE ( 10000000000000
                                         , 999999999999999 ) )
          INTO vp_proc_instance
          FROM DUAL;

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


        -- DBG_LINE_ERROR:=$$PLSQL_LINE;
        p_data2 :=
            LAST_DAY ( TO_DATE (    '01'
                                 || TO_CHAR ( p_mes
                                            , 'FM00' )
                                 || TO_CHAR ( p_ano
                                            , 'FM0000' )
                               , 'DDMMYYYY' ) );
        p_data1 :=
            TO_DATE (    '01'
                      || TO_CHAR ( p_mes
                                 , 'FM00' )
                      || TO_CHAR ( p_ano
                                 , 'FM0000' )
                    , 'DDMMYYYY' );

        loga ( ' ' );
        loga (    'DATA INICIAL     (SIM, OBRIGATÓRIO): '
               || TO_CHAR ( p_data1
                          , 'DD/MM/YYYY' ) );
        loga (    'DATA FINAL       (SIM, OBRIGATÓRIO): '
               || TO_CHAR ( p_data2
                          , 'DD/MM/YYYY' ) );
        loga ( 'EXCLUINDO VALORES EXISTENTES NO LIVRO' );


        --EXECUTAR UM P_COD_ESTAB POR VEZ
        FOR est IN a_estabs.FIRST .. a_estabs.LAST --(1)
                                                  LOOP
            limpa_item_apurac ( a_estabs ( est )
                              , p_data1
                              , p_data2 );
            p_periodos :=
                TO_CHAR ( p_periodo
                        , 'MM/YYYY' );
            load_tab_gtt ( a_estabs ( est )
                         , p_data1
                         , p_data2
                         , p_periodos );
            loga (    'VALORES INSERIDOS NO LIVRO: ['
                   || credito_cesta_basica ( a_estabs ( est )
                                           , mproc_id
                                           , p_data1
                                           , p_data2
                                           , p_periodos )
                   || '] - Filial = '
                   || a_estabs ( est ) );
        --
        END LOOP;

        load_excel_analitico_lj ( mproc_id
                                , p_data1
                                , p_data2 );
        load_excel_sintetico_lj ( mproc_id
                                , p_data1
                                , p_data2 );
        load_excel_analitico_cd ( mproc_id
                                , p_data1
                                , p_data2 );
        load_excel_sintetico_cd ( mproc_id
                                , p_data1
                                , p_data2 );

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
END dpsp_fin4405_cest_rel_cproc;
/
SHOW ERRORS;
