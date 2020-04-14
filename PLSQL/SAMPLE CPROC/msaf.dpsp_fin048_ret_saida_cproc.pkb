Prompt Package Body DPSP_FIN048_RET_SAIDA_CPROC;
--
-- DPSP_FIN048_RET_SAIDA_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_fin048_ret_saida_cproc
IS
    mproc_id NUMBER;
    vn_linha NUMBER := 0;
    vn_pagina NUMBER := 0;
    mnm_usuario usuario_estab.cod_usuario%TYPE;
    mcod_empresa estabelecimento.cod_empresa%TYPE;
    vs_mlinha VARCHAR2 ( 4000 );
    vp_tab_aliq VARCHAR2 ( 30 );
    vp_tab_aux VARCHAR2 ( 30 );
    vp_tab_prod VARCHAR2 ( 30 );

    v_sql VARCHAR2 ( 32767 );
    v_qtde NUMBER := 0;
    v_valor VARCHAR2 ( 30 );
    v_valor_2 VARCHAR2 ( 30 );
    v_valor_3 VARCHAR2 ( 30 );
    --

    --Tipo, Nome e Descrição do Customizado
    --Melhoria FIN048
    mnm_tipo VARCHAR2 ( 100 ) := 'Retificação ICMS ES';
    mnm_cproc VARCHAR2 ( 100 ) := '2. Relatório de Notas Fiscais de Saída para retificacao apuração ICMS (ES)';
    mds_cproc VARCHAR2 ( 100 ) := 'Processo para ajuste de Notas de Saída';

    v_sel_data_fim VARCHAR2 ( 260 )
        := 'SELECT TRUNC( TO_DATE( :1 ,''DD/MM/YYYY'') + ROWNUM - 1) AS DATA_FIM, TRUNC( TO_DATE( :1 ,''DD/MM/YYYY'') + ROWNUM - 1) AS DATA_FIM FROM DUAL CONNECT BY ROWNUM <= LAST_DAY( TO_DATE( :1 ,''DD/MM/YYYY'') ) - TO_DATE( :1 ,''DD/MM/YYYY'') + 1 ORDER BY 1 DESC ';

    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );
    BEGIN
        mnm_usuario := lib_parametros.recuperar ( UPPER ( 'USUARIO' ) );
        mcod_empresa := lib_parametros.recuperar ( UPPER ( 'EMPRESA' ) );

        lib_proc.add_param ( pparam => pstr
                           , ptitulo => 'Data Inicial'
                           , ptipo => 'DATE'
                           , pcontrole => 'textbox'
                           , pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => 'DD/MM/YYYY' );


        lib_proc.add_param ( pstr
                           , 'Data Final'
                           , --P_DATA_FIM
                            'VARCHAR2'
                           , 'COMBOBOX'
                           , 'S'
                           , NULL
                           , '##########'
                           , v_sel_data_fim );

        lib_proc.add_param (
                             pstr
                           , 'CDs'
                           , 'VARCHAR2'
                           , 'COMBOBOX'
                           , 'S'
                           , NULL
                           , NULL
                           ,    ' SELECT ''TODOS'' AS COD_ESTAB, ''Todos os CDs'' FROM DUAL UNION ALL '
                             || 'SELECT A.COD_ESTAB, A.COD_ESTAB || '' - '' || B.COD_ESTADO || '' - '' || A.CGC || '' - '' || INITCAP(A.BAIRRO) || '' / '' || INITCAP(A.CIDADE) FROM ESTABELECIMENTO A, ESTADO B, MSAFI.DSP_ESTABELECIMENTO C WHERE A.COD_EMPRESA  = '''
                             || mcod_empresa
                             || ''' AND B.IDENT_ESTADO = A.IDENT_ESTADO AND A.COD_EMPRESA = C.COD_EMPRESA AND A.COD_ESTAB = C.COD_ESTAB AND C.TIPO = ''C'' AND B.COD_ESTADO = ''ES'' '
        );

        lib_proc.add_param ( pparam => pstr
                           , ptitulo =>    LPAD ( '-'
                                                , 60
                                                , '-' )
                                        || 'Notas de Saída'
                                        || LPAD ( '-'
                                                , 60
                                                , '-' )
                           , ptipo => 'Varchar2'
                           , pcontrole => 'Text'
                           , pmandatorio => 'N'
                           , pdefault => 'N'
                           , pmascara => NULL
                           , pvalores => NULL
                           , papresenta => 'N' );
        --
        lib_proc.add_param ( pparam => pstr
                           , ptitulo => 'Saídas internas no CFOP 5.409'
                           , ptipo => 'Varchar2'
                           , pcontrole => 'Text'
                           , pmandatorio => 'N'
                           , pdefault => 'N'
                           , pmascara => NULL
                           , pvalores => NULL
                           , papresenta => 'N' );

        RETURN pstr;
    END;

    FUNCTION tipo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN mnm_tipo;
    END;

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN mnm_cproc;
    END;

    FUNCTION descricao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN mds_cproc;
    END;

    FUNCTION versao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN '1.0';
    END;

    FUNCTION modulo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Customizados';
    END;

    FUNCTION classificacao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Customizados';
    END;

    FUNCTION orientacao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'PORTRAIT';
    END;

    FUNCTION carregar_nf_saida ( pdt_ini DATE
                               , pdt_fim DATE
                               , pcod_estab VARCHAR2
                               , v_data_hora_ini VARCHAR2 )
        RETURN INTEGER
    IS
        cc_limit NUMBER ( 7 ) := 1000;
        v_count_new INTEGER := 0;
        v_people_de VARCHAR2 ( 5 )
            := ( CASE
                    WHEN SUBSTR ( pcod_estab
                                , 1
                                , 2 ) = 'ST' THEN
                        'ST'
                    ELSE
                        'VD'
                END );
        v_people_para VARCHAR2 ( 5 ) := mcod_empresa; -- DP ou DSP

        -- MSAFI.DPSP_FIN048_RET_NF_SAI

        TYPE fin048_ret_nf_sai_typ IS TABLE OF msafi.dpsp_fin048_ret_nf_sai%ROWTYPE;

        l_tb_fin048_ret_nf_sai fin048_ret_nf_sai_typ := fin048_ret_nf_sai_typ ( );

        forall_failed EXCEPTION;
        PRAGMA EXCEPTION_INIT ( forall_failed
                              , -24381 );

        --  CURSOR CR_FIN48_SAIDA IS

        l_errors NUMBER;
        l_errno NUMBER;
        l_msg VARCHAR2 ( 4000 );
        l_idx NUMBER;

        --
        v_count INTEGER DEFAULT 0;
        c_aux SYS_REFCURSOR;

        -- V_SQL VARCHAR2(8000);

        -- ;

        PROCEDURE proc_upd_saida ( pdt_ini DATE
                                 , pdt_fim DATE
                                 , pcod_estab VARCHAR2 )
        IS
            v_count_new NUMBER;
            v_sql VARCHAR2 ( 5000 );
            icms_st_s NUMBER ( 17, 6 );
        BEGIN
            -- ATUALIZA TRANSALATE
            msafi.upd_ps_translate ( 'DSP_ALIQ_ICMS' );
            msafi.upd_ps_translate ( 'DSP_ST_TRIBUT_ICMS' );
            msafi.upd_ps_translate ( 'DSP_TP_CALC_ST' );

            -- EXECUTE IMMEDIATE  'TRUNCATE TABLE PS_DSP_ITEM_LN_GTT';

            IF TO_CHAR ( pdt_ini
                       , 'YYYY' ) = '2016'
           AND TO_CHAR ( pdt_fim
                       , 'YYYY' ) = '2016' THEN
                FOR i IN ( SELECT f48.ROWID AS f48_rowid
                                , f48.*
                             FROM msafi.dpsp_fin048_ret_nf_sai f48
                            WHERE cod_empresa = 'DP'
                              AND cod_estab = pcod_estab
                              AND data_fiscal BETWEEN pdt_ini AND pdt_fim ) LOOP
                    FOR j
                        IN ( SELECT i.f48_rowid
                                  ---  ICMS_ST
                                  , ( SELECT ROUND (
                                                     ( CASE
                                                          WHEN   ( bc_icms_st * ( aliquota_interna / 100 ) )
                                                               - icms_proprio < 0 THEN
                                                              0
                                                          ELSE
                                                                ( bc_icms_st * ( aliquota_interna / 100 ) )
                                                              - icms_proprio
                                                      END )
                                                   , 2
                                             )
                                        FROM ( SELECT /*+DRIVING_SITE(TAB)*/
                                                      ( CASE
                                                           WHEN NVL ( pmc.pmc_pauta, 0 ) > 0 THEN
                                                                 ( pmc.pmc_pauta * i.quantidade )
                                                               * ( 1 - tab.dsp_pct_red_icmsst / 100 )
                                                           WHEN NVL ( pmc.pmc_pauta, 0 ) = 0 THEN
                                                               (   i.vlr_item
                                                                 * ( 1 + mva_pct_bbl / 100 )
                                                                 * ( 1 - dsp_pct_red_icmsst / 100 ) )
                                                       END )
                                                          AS bc_icms_st
                                                    , (   i.vlr_item
                                                        * REPLACE ( REPLACE ( msafi.ps_translate (
                                                                                                   'DSP_ALIQ_ICMS'
                                                                                                 , NVL (
                                                                                                         TRIM (
                                                                                                                dsp_aliq_icms
                                                                                                         )
                                                                                                       , 0
                                                                                                   )
                                                                              )
                                                                            , '%'
                                                                            , '' )
                                                                  , '<VLR INVALIDO>'
                                                                  , '' / 100 )
                                                        * ( 1 - dsp_pct_red_icmsst / 100 ) )
                                                          AS icms_proprio
                                                    , REPLACE ( REPLACE ( msafi.ps_translate (
                                                                                               'DSP_ALIQ_ICMS'
                                                                                             , NVL (
                                                                                                     TRIM (
                                                                                                            dsp_aliq_icms
                                                                                                     )
                                                                                                   , 0
                                                                                               )
                                                                          )
                                                                        , '%'
                                                                        , '' )
                                                              , '<VLR INVALIDO>'
                                                              , '' )
                                                          AS aliquota_interna
                                                    , RANK ( )
                                                          OVER ( PARTITION BY tab.setid
                                                                            , tab.inv_item_id
                                                                 ORDER BY tab.effdt DESC )
                                                          AS RANK
                                                 FROM msafi.ps_dsp_ln_mva_his tab
                                                    , msafi.dsp_estabelecimento est
                                                    , (SELECT pmc_pauta
                                                            , inv_item_id
                                                            , dsp_aliq_icms_id
                                                         FROM (SELECT /*+DRIVING_SITE(TAB)*/
                                                                     tab.dsp_pmc pmc_pauta
                                                                    , tab.inv_item_id
                                                                    , tab.dsp_aliq_icms_id
                                                                    , RANK ( )
                                                                          OVER ( PARTITION BY tab.setid
                                                                                            , tab.inv_item_id
                                                                                 ORDER BY tab.effdt DESC )
                                                                          AS RANK
                                                                 FROM msafi.ps_dsp_preco_item tab
                                                                WHERE tab.setid = 'GERAL'
                                                                  AND tab.inv_item_id = i.cod_produto
                                                                  AND tab.effdt <= i.data_fiscal
                                                                  AND tab.unit_of_measure = 'UN')
                                                        WHERE RANK = 1) pmc
                                                WHERE tab.setid = 'GERAL'
                                                  AND tab.inv_item_id = i.cod_produto
                                                  AND est.cod_empresa = i.cod_empresa
                                                  AND est.cod_estab = i.cod_estab
                                                  AND pmc.inv_item_id(+) = i.cod_produto
                                                  AND pmc.dsp_aliq_icms_id(+) = REPLACE ( REPLACE ( msafi.ps_translate (
                                                                                                                         'DSP_ALIQ_ICMS'
                                                                                                                       , NVL (
                                                                                                                               TRIM (
                                                                                                                                      dsp_aliq_icms
                                                                                                                               )
                                                                                                                             , 0
                                                                                                                         )
                                                                                                    )
                                                                                                  , ' '
                                                                                                  , '' )
                                                                                        , '<VLR INVALIDO>'
                                                                                        , '' )
                                                  AND tab.crit_state_to_pbl = 'ES'
                                                  AND tab.crit_state_fr_pbl = 'ES'
                                                  AND tab.effdt <= i.data_fiscal )
                                       WHERE RANK = 1 )
                                        AS icms_st
                                  --

                                  , ( SELECT ROUND ( bc_icms_st
                                                   , 2 )
                                        FROM ( SELECT /*+DRIVING_SITE(TAB)*/
                                                      ( CASE
                                                           WHEN NVL ( pmc.pmc_pauta, 0 ) > 0 THEN
                                                                 ( pmc.pmc_pauta * i.quantidade )
                                                               * ( 1 - tab.dsp_pct_red_icmsst / 100 )
                                                           WHEN NVL ( pmc.pmc_pauta, 0 ) = 0 THEN
                                                               (   i.vlr_item
                                                                 * ( 1 + mva_pct_bbl / 100 )
                                                                 * ( 1 - dsp_pct_red_icmsst / 100 ) )
                                                       END )
                                                          bc_icms_st
                                                    , RANK ( )
                                                          OVER ( PARTITION BY tab.setid
                                                                            , tab.inv_item_id
                                                                 ORDER BY tab.effdt DESC )
                                                          AS RANK
                                                 FROM msafi.ps_dsp_ln_mva_his tab
                                                    , msafi.dsp_estabelecimento est
                                                    , (SELECT pmc_pauta
                                                            , inv_item_id
                                                            , dsp_aliq_icms_id
                                                         FROM (SELECT /*+DRIVING_SITE(TAB)*/
                                                                     tab.dsp_pmc pmc_pauta
                                                                    , tab.inv_item_id
                                                                    , tab.dsp_aliq_icms_id
                                                                    , RANK ( )
                                                                          OVER ( PARTITION BY tab.setid
                                                                                            , tab.inv_item_id
                                                                                 ORDER BY tab.effdt DESC )
                                                                          AS RANK
                                                                 FROM msafi.ps_dsp_preco_item tab
                                                                WHERE tab.setid = 'GERAL'
                                                                  AND tab.inv_item_id = i.cod_produto
                                                                  AND tab.effdt <= i.data_fiscal
                                                                  AND tab.unit_of_measure = 'UN')
                                                        WHERE RANK = 1) pmc
                                                WHERE tab.setid = 'GERAL'
                                                  AND tab.inv_item_id = i.cod_produto
                                                  AND est.cod_empresa = i.cod_empresa
                                                  AND est.cod_estab = i.cod_estab
                                                  AND pmc.inv_item_id(+) = i.cod_produto
                                                  AND pmc.dsp_aliq_icms_id(+) = REPLACE ( REPLACE ( msafi.ps_translate (
                                                                                                                         'DSP_ALIQ_ICMS'
                                                                                                                       , NVL (
                                                                                                                               TRIM (
                                                                                                                                      dsp_aliq_icms
                                                                                                                               )
                                                                                                                             , 0
                                                                                                                         )
                                                                                                    )
                                                                                                  , ' '
                                                                                                  , '' )
                                                                                        , '<VLR INVALIDO>'
                                                                                        , '' )
                                                  AND tab.crit_state_to_pbl = est.cod_estado
                                                  AND tab.crit_state_fr_pbl = est.cod_estado
                                                  AND tab.effdt <= i.data_fiscal )
                                       WHERE RANK = 1 )
                                        AS bc_icms_st --39
                                  , ( SELECT icms_proprio / 100
                                        FROM (SELECT /*+DRIVING_SITE(TAB)*/
                                                     ( (   i.vlr_item
                                                         * REPLACE ( REPLACE ( msafi.ps_translate (
                                                                                                    'DSP_ALIQ_ICMS'
                                                                                                  , NVL (
                                                                                                          TRIM (
                                                                                                                 dsp_aliq_icms
                                                                                                          )
                                                                                                        , 0
                                                                                                    )
                                                                               )
                                                                             , '%'
                                                                             , '' )
                                                                   , '<VLR INVALIDO>'
                                                                   , '' / 100 )
                                                         * ( 1 - dsp_pct_red_icmsst / 100 ) ) )
                                                         AS icms_proprio
                                                   --   TAB.DSP_ALIQ_ICMS       AS  ICMS_PROPRIO
                                                   , RANK ( )
                                                         OVER ( PARTITION BY tab.setid
                                                                           , tab.inv_item_id
                                                                ORDER BY tab.effdt DESC )
                                                         AS RANK
                                                FROM msafi.ps_dsp_ln_mva_his tab
                                               WHERE tab.setid = 'GERAL'
                                                 AND tab.inv_item_id = i.cod_produto
                                                 AND tab.crit_state_to_pbl = 'ES'
                                                 AND tab.crit_state_fr_pbl = 'ES'
                                                 AND tab.effdt <= i.data_fiscal)
                                       WHERE RANK = 1 )
                                        AS icms_proprio --38
                                  , ( SELECT aliq_interna
                                        FROM (SELECT /*+DRIVING_SITE(A)*/
                                                    RANK ( )
                                                         OVER ( PARTITION BY setid
                                                                           , inv_item_id
                                                                ORDER BY effdt DESC )
                                                         RANK
                                                   , NVL ( ( REPLACE ( REPLACE ( msafi.ps_translate (
                                                                                                      'DSP_ALIQ_ICMS'
                                                                                                    , NVL (
                                                                                                            TRIM (
                                                                                                                   dsp_aliq_icms
                                                                                                            )
                                                                                                          , 0
                                                                                                      )
                                                                                 )
                                                                               , '%'
                                                                               , '' )
                                                                     , '<VLR INVALIDO>'
                                                                     , '' ) )
                                                         , 0 )
                                                         AS aliq_interna
                                                FROM msafi.ps_dsp_ln_mva_his a
                                               WHERE inv_item_id = i.cod_produto
                                                 AND crit_state_to_pbl = 'ES'
                                                 AND crit_state_fr_pbl = 'ES'
                                                 AND setid = 'GERAL'
                                                 AND effdt <= i.data_fiscal)
                                       WHERE RANK = 1 )
                                        AS aliq_interna --36
                                  , ( SELECT finalidade
                                        FROM (SELECT /*+DRIVING_SITE(TAB)*/
                                                    tab.purch_prop_brl finalidade
                                                   , RANK ( )
                                                         OVER ( PARTITION BY tab.setid
                                                                           , tab.inv_item_id
                                                                ORDER BY tab.effdt DESC )
                                                         AS RANK
                                                FROM msafi.ps_dsp_ln_mva_his tab
                                                   , msafi.dsp_estabelecimento est
                                               WHERE tab.setid = 'GERAL'
                                                 AND tab.inv_item_id = i.cod_produto
                                                 AND est.cod_empresa = i.cod_empresa
                                                 AND est.cod_estab = i.cod_estab
                                                 AND tab.crit_state_to_pbl = est.cod_estado
                                                 AND tab.crit_state_fr_pbl = est.cod_estado
                                                 AND tab.effdt <= i.data_fiscal)
                                       WHERE RANK = 1 )
                                        AS finalidade -- 35
                                  , ( SELECT perc_red_bsst
                                        FROM (SELECT /*+DRIVING_SITE(TAB)*/
                                                    tab.dsp_pct_red_icmsst perc_red_bsst
                                                   , RANK ( )
                                                         OVER ( PARTITION BY tab.setid
                                                                           , tab.inv_item_id
                                                                ORDER BY tab.effdt DESC )
                                                         AS RANK
                                                FROM msafi.ps_dsp_ln_mva_his tab
                                                   , msafi.dsp_estabelecimento est
                                               WHERE tab.setid = 'GERAL'
                                                 AND tab.inv_item_id = i.cod_produto
                                                 AND est.cod_empresa = i.cod_empresa
                                                 AND est.cod_estab = i.cod_estab
                                                 AND tab.crit_state_to_pbl = est.cod_estado
                                                 AND tab.crit_state_fr_pbl = est.cod_estado
                                                 AND tab.effdt <= i.data_fiscal)
                                       WHERE RANK = 1 )
                                        AS perc_red_bsst --34
                                  --
                                  , ( SELECT mva_pct_bbl
                                        FROM (SELECT /*+DRIVING_SITE(TAB)*/
                                                    tab.mva_pct_bbl
                                                   , RANK ( )
                                                         OVER ( PARTITION BY tab.setid
                                                                           , tab.inv_item_id
                                                                ORDER BY tab.effdt DESC )
                                                         AS RANK
                                                FROM msafi.ps_dsp_ln_mva_his tab
                                                   , msafi.dsp_estabelecimento est
                                               WHERE tab.setid = 'GERAL'
                                                 AND tab.inv_item_id = i.cod_produto
                                                 AND est.cod_empresa = i.cod_empresa
                                                 AND est.cod_estab = i.cod_estab
                                                 AND tab.crit_state_to_pbl = est.cod_estado
                                                 AND tab.crit_state_fr_pbl = est.cod_estado
                                                 AND tab.effdt <= i.data_fiscal)
                                       WHERE RANK = 1 )
                                        AS mva -- 30
                                  ---
                                  -- PMC_PAUTA
                                  ---
                                  , ( SELECT NVL ( ( pmc_pauta ), 0 ) pmc_pauta
                                        FROM (SELECT /*+DRIVING_SITE(TAB)*/
                                                    pmc.pmc_pauta pmc_pauta
                                                   , RANK ( )
                                                         OVER ( PARTITION BY tab.setid
                                                                           , tab.inv_item_id
                                                                ORDER BY tab.effdt DESC )
                                                         AS RANK
                                                FROM msafi.ps_dsp_ln_mva_his tab
                                                   , msafi.dsp_estabelecimento est
                                                   , (SELECT pmc_pauta
                                                           , inv_item_id
                                                           , dsp_aliq_icms_id
                                                        FROM (SELECT /*+DRIVING_SITE(TAB)*/
                                                                    NVL ( ( tab.dsp_pmc ), 0 ) pmc_pauta
                                                                   , tab.inv_item_id
                                                                   , tab.dsp_aliq_icms_id
                                                                   , RANK ( )
                                                                         OVER ( PARTITION BY tab.setid
                                                                                           , tab.inv_item_id
                                                                                ORDER BY tab.effdt DESC )
                                                                         AS RANK
                                                                FROM msafi.ps_dsp_preco_item tab
                                                               WHERE tab.setid = 'GERAL'
                                                                 AND tab.inv_item_id = i.cod_produto
                                                                 AND tab.effdt <= i.data_fiscal
                                                                 AND tab.unit_of_measure = 'UN')
                                                       WHERE RANK = 1) pmc
                                               WHERE tab.setid = 'GERAL'
                                                 AND tab.inv_item_id = i.cod_produto
                                                 AND est.cod_empresa = i.cod_empresa
                                                 AND est.cod_estab = i.cod_estab
                                                 AND pmc.inv_item_id(+) = i.cod_produto
                                                 AND pmc.dsp_aliq_icms_id(+) = REPLACE ( msafi.ps_translate (
                                                                                                              'DSP_ALIQ_ICMS'
                                                                                                            , NVL (
                                                                                                                    TRIM (
                                                                                                                           dsp_aliq_icms
                                                                                                                    )
                                                                                                                  , 0
                                                                                                              )
                                                                                         )
                                                                                       , ' '
                                                                                       , '' )
                                                 AND tab.crit_state_to_pbl = est.cod_estado
                                                 AND tab.crit_state_fr_pbl = est.cod_estado
                                                 AND tab.effdt <= i.data_fiscal)
                                       WHERE RANK = 1 )
                                        AS pmc_pauta --- 31
                                  ---
                                  -- TP_CALC
                                  ---
                                  , ( SELECT tp_calc
                                        FROM (SELECT /*+DRIVING_SITE(TAB)*/
                                                    REPLACE ( REPLACE ( msafi.ps_translate (
                                                                                             'DSP_TP_CALC_ST'
                                                                                           , NVL (
                                                                                                   TRIM (
                                                                                                          tab.dsp_tp_calc_st
                                                                                                   )
                                                                                                 , 0
                                                                                             )
                                                                        )
                                                                      , ' '
                                                                      , '' )
                                                            , '<VLR INVALIDO>'
                                                            , '' )
                                                         tp_calc
                                                   , RANK ( )
                                                         OVER ( PARTITION BY tab.setid
                                                                           , tab.inv_item_id
                                                                ORDER BY tab.effdt DESC )
                                                         AS RANK
                                                FROM msafi.ps_dsp_ln_mva_his tab
                                                   , msafi.dsp_estabelecimento est
                                               WHERE tab.setid = 'GERAL'
                                                 AND tab.inv_item_id = i.cod_produto
                                                 AND est.cod_empresa = i.cod_empresa
                                                 AND est.cod_estab = i.cod_estab
                                                 AND tab.crit_state_to_pbl = est.cod_estado
                                                 AND tab.crit_state_fr_pbl = est.cod_estado
                                                 AND tab.effdt <= i.data_fiscal)
                                       WHERE RANK = 1 )
                                        AS tp_calc -- 32
                                  --
                                  -- SIT_TRIB
                                  --
                                  , ( SELECT sit_trib
                                        FROM (SELECT /*+DRIVING_SITE(TAB)*/
                                                    REPLACE ( REPLACE ( msafi.ps_translate (
                                                                                             'DSP_ST_TRIBUT_ICMS'
                                                                                           , NVL (
                                                                                                   TRIM (
                                                                                                          tab.dsp_st_tribut_icms
                                                                                                   )
                                                                                                 , 0
                                                                                             )
                                                                        )
                                                                      , ' '
                                                                      , '' )
                                                            , '<VLR INVALIDO>'
                                                            , '' )
                                                         sit_trib
                                                   , RANK ( )
                                                         OVER ( PARTITION BY tab.setid
                                                                           , tab.inv_item_id
                                                                ORDER BY tab.effdt DESC )
                                                         AS RANK
                                                FROM msafi.ps_dsp_ln_mva_his tab
                                                   , msafi.dsp_estabelecimento est
                                               WHERE tab.setid = 'GERAL'
                                                 AND tab.inv_item_id = i.cod_produto
                                                 AND est.cod_empresa = i.cod_empresa
                                                 AND est.cod_estab = i.cod_estab
                                                 AND tab.crit_state_to_pbl = est.cod_estado
                                                 AND tab.crit_state_fr_pbl = est.cod_estado
                                                 AND tab.effdt <= i.data_fiscal)
                                       WHERE RANK = 1 )
                                        AS sit_trib --  33
                               FROM DUAL ) LOOP
                        BEGIN
                            icms_st_s := ( j.bc_icms_st * ( j.aliq_interna / 100 ) ) - j.icms_proprio;

                            IF icms_st_s > 0 THEN
                                icms_st_s := icms_st_s;
                            ELSE
                                icms_st_s := 0;
                            END IF;


                            UPDATE msafi.dpsp_fin048_ret_nf_sai
                               SET mva = j.mva
                                 , pmc_pauta = j.pmc_pauta
                                 , tp_calc = j.tp_calc
                                 , sit_trib = j.sit_trib
                                 , perc_red_bsst = j.perc_red_bsst
                                 , finalidade = j.finalidade
                                 , aliquota_interna = j.aliq_interna
                                 , icms_proprio = j.icms_proprio
                                 , bc_icms_st = j.bc_icms_st
                                 , --ICMS_ST            = (j.BC_ICMS_ST * (j.ALIQ_INTERNA/100)) - j.ICMS_PROPRIO,
                                   icms_st = icms_st_s
                                 , cod_estado_to = 'ES'
                                 , cod_estado_from = 'ES'
                             WHERE ROWID = j.f48_rowid;

                            v_count_new := v_count_new + 1;

                            COMMIT;
                            dbms_application_info.set_module ( 'ATUALIZANDO - > '
                                                             , v_count_new );
                        -- Rastreio
                        /*INSERT  INTO  MSAFI.LOG_GERAL
                                       (ora_err_number1, ora_err_mesg1, ora_err_optyp1)

                                       VALUES ( j.PMC_PAUTA
                                       , j.ALIQ_INTERNA
                                       , j.BC_ICMS_ST);
                        COMMIT;*/

                        EXCEPTION
                            WHEN OTHERS THEN
                                dbms_output.put_line ( 'Backtrace => ' || dbms_utility.format_error_backtrace );

                                loga ( j.f48_rowid
                                     , FALSE );
                        END;
                    END LOOP;
                END LOOP;

                COMMIT;
            END IF;
        END proc_upd_saida;
    BEGIN
        -- v_valor  VARCHAR2(30);

        --- Cria tabela de produtos
        vp_tab_prod :=
            msaf.dpsp_create_tab_tmp ( mproc_id
                                     , mproc_id
                                     , 'TAB_PROD'
                                     , mnm_usuario );

        IF ( vp_tab_prod = 'ERRO' ) THEN
            raise_application_error ( -20001
                                    , '!ERRO CREATE_PROD_TABLE!' );
        END IF;

        loga ( vp_tab_prod );

        ---- Carrega Tabela de produtos
        BEGIN
            v_sql := '   INSERT INTO ' || vp_tab_prod || ' ';
            v_sql := v_sql || ' SELECT DISTINCT COD_PRODUTO, X07.DATA_FISCAL';
            v_sql := v_sql || ' FROM MSAF.X07_DOCTO_FISCAL        X07, ';
            v_sql := v_sql || '     MSAF.X08_ITENS_MERC          X08, ';
            v_sql := v_sql || '     MSAF.X04_PESSOA_FIS_JUR      X04, ';
            v_sql := v_sql || '        MSAF.ESTADO                  ESTADO, ';
            v_sql := v_sql || '        MSAF.X2005_TIPO_DOCTO        X2005, ';
            v_sql := v_sql || '        MSAF.X2024_MODELO_DOCTO      X2024, ';
            v_sql := v_sql || '        MSAF.X2012_COD_FISCAL        X2012, ';
            v_sql := v_sql || '        MSAF.X2013_PRODUTO           X2013, ';
            v_sql := v_sql || '        MSAF.X2043_COD_NBM           X2043, ';
            v_sql := v_sql || '        MSAF.Y2025_SIT_TRB_UF_A      Y2025, ';
            v_sql := v_sql || '        MSAF.Y2026_SIT_TRB_UF_B      Y2026, ';
            v_sql := v_sql || '        MSAF.X2006_NATUREZA_OP       X2006  ';
            v_sql := v_sql || '  WHERE  X07.COD_EMPRESA         = X08.COD_EMPRESA ';
            v_sql := v_sql || '      AND X07.COD_ESTAB          = X08.COD_ESTAB   ';
            v_sql := v_sql || '      AND X07.DATA_FISCAL        = X08.DATA_FISCAL ';
            v_sql := v_sql || '      AND X07.MOVTO_E_S          = X08.MOVTO_E_S   ';
            v_sql := v_sql || '      AND X07.NORM_DEV           = X08.NORM_DEV    ';
            v_sql := v_sql || '      AND X07.IDENT_DOCTO        = X08.IDENT_DOCTO ';
            v_sql := v_sql || '      AND X07.IDENT_FIS_JUR      = X08.IDENT_FIS_JUR ';
            v_sql := v_sql || '      AND X07.NUM_DOCFIS         = X08.NUM_DOCFIS    ';
            v_sql := v_sql || '      AND X07.SERIE_DOCFIS       = X08.SERIE_DOCFIS  ';
            v_sql := v_sql || '      AND X07.SUB_SERIE_DOCFIS   = X08.SUB_SERIE_DOCFIS  ';
            v_sql := v_sql || '      AND X07.IDENT_MODELO       = X2024.IDENT_MODELO    ';
            v_sql := v_sql || '      AND X07.IDENT_FIS_JUR      = X04.IDENT_FIS_JUR     ';
            v_sql := v_sql || '      AND X07.IDENT_DOCTO        = X2005.IDENT_DOCTO     ';
            v_sql := v_sql || '      AND X04.IDENT_ESTADO       = ESTADO.IDENT_ESTADO   ';
            v_sql := v_sql || '      AND X08.IDENT_CFO          = X2012.IDENT_CFO       ';
            v_sql := v_sql || '      AND X08.IDENT_PRODUTO      = X2013.IDENT_PRODUTO   ';
            v_sql := v_sql || '      AND X2013.IDENT_NBM        = X2043.IDENT_NBM       ';
            v_sql := v_sql || '      AND Y2025.IDENT_SITUACAO_A = X08.IDENT_SITUACAO_A  ';
            v_sql := v_sql || '      AND X08.IDENT_SITUACAO_B   = Y2026.IDENT_SITUACAO_B   ';
            v_sql := v_sql || '      AND X08.IDENT_NATUREZA_OP  = X2006.IDENT_NATUREZA_OP  ';
            v_sql := v_sql || '      AND X07.MOVTO_E_S                  = ''9''              ';
            v_sql := v_sql || '      AND X07.SITUACAO                   = ''N''              ';
            v_sql := v_sql || '      AND X07.COD_EMPRESA                = ''' || mcod_empresa || '''     ';
            v_sql := v_sql || '      AND X07.COD_ESTAB                  = ''' || pcod_estab || '''      ';
            v_sql := v_sql || '      AND  X2012.COD_CFO                 =  ''5409''         ';
            v_sql :=
                v_sql || '      AND X07.DATA_FISCAL BETWEEN ''' || pdt_ini || '''   AND  ''' || pdt_fim || '''     ';

            dbms_output.put_line ( '[PRD]:' || SQL%ROWCOUNT );

            EXECUTE IMMEDIATE v_sql;

            COMMIT;
        END;

        -------
        --- Cria tabela de Aliq
        vp_tab_aliq :=
            msaf.dpsp_create_tab_tmp ( mproc_id
                                     , mproc_id
                                     , 'TAB_ALIQ_M'
                                     , mnm_usuario );

        IF ( vp_tab_aliq = 'ERRO' ) THEN
            raise_application_error ( -20001
                                    , '!ERRO CREATE_ALIQ_TABLE!' );
        END IF;

        ---
        loga ( vp_tab_aliq );

        --- Carrega Tabela de Aliq

        BEGIN
            v_sql := 'INSERT INTO ' || vp_tab_aliq || ' ';
            v_sql :=
                v_sql || 'SELECT /*+DRIVING_SITE(PS)*/ PS.INV_ITEM_ID AS COD_PRODUTO, PS.DATA_FISCAL, PS.ALIQ_INTERNA ';
            v_sql := v_sql || 'FROM ( ';
            v_sql :=
                   v_sql
                || '                 SELECT T.INV_ITEM_ID, T.EFFDT, REPLACE(MSAFI.PS_TRANSLATE(''DSP_ALIQ_ICMS'',T.DSP_ALIQ_ICMS),''<VLR INVALIDO>'','''')  AS ALIQ_INTERNA, S.DATA_FISCAL, ';
            v_sql :=
                   v_sql
                || '                     RANK() OVER (PARTITION BY T.SETID, T.INV_ITEM_ID ORDER BY T.EFFDT DESC) RANK ';

            IF ( pdt_ini < TO_DATE ( '01012017'
                                   , 'DDMMYYYY' ) ) THEN --PERIODOS ANTERIORES ESTAO EM OUTRA TABELA
                v_sql := v_sql || '             FROM MSAFI.PS_DSP_LN_MVA_HIS T, ';
            ELSE
                v_sql := v_sql || '             FROM msafi.PS_DSP_ITEM_LN_MVA T, ';
            END IF;

            v_sql := v_sql || '                 ' || vp_tab_prod || ' S ';
            v_sql := v_sql || '                 WHERE T.SETID = ''GERAL'' ';
            v_sql := v_sql || '                 AND T.INV_ITEM_ID = S.COD_PRODUTO ';
            v_sql := v_sql || '                 AND T.CRIT_STATE_TO_PBL = T.CRIT_STATE_FR_PBL ';
            v_sql := v_sql || '                 AND T.CRIT_STATE_TO_PBL = ''ES'' ';
            v_sql := v_sql || '                 AND T.EFFDT <= S.DATA_FISCAL ';
            v_sql := v_sql || '      ) PS ';
            v_sql := v_sql || 'WHERE PS.RANK = 1 ';

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
                                        , '!ERRO INSERT !' );

                lib_proc.add ( dbms_utility.format_error_backtrace
                             , 1 );


                COMMIT;
        END;

        --- Tabela Auxiliar DSP_PRECO_ITEM

        BEGIN
            EXECUTE IMMEDIATE 'TRUNCATE TABLE MSAFI.DPSP_PRECO_ITEM_GTT'; --GTT

            v_sql := 'INSERT INTO MSAFI.DPSP_PRECO_ITEM_GTT ';
            v_sql := v_sql || 'SELECT /*+DRIVING_SITE(PS)*/ DISTINCT A.* ';
            v_sql := v_sql || ' FROM MSAFI.PS_DSP_PRECO_ITEM A, ' || vp_tab_prod || ' B';
            v_sql := v_sql || ' WHERE A.INV_ITEM_ID = B.COD_PRODUTO AND A.EFFDT <= B.DATA_FISCAL';

            dbms_output.put_line ( '[AUX]:' || SQL%ROWCOUNT );

            EXECUTE IMMEDIATE v_sql;

            SELECT COUNT ( * )
              INTO v_qtde
              FROM msafi.dpsp_preco_item_gtt;

            loga ( '[TABLE GTT][LINHAS][' || v_qtde || ']'
                 , FALSE );


            COMMIT;
        END;

        BEGIN
            --- Tabela Auxiliar DSP_PRECO_ITEM
            ---
            v_sql := ' SELECT COD_EMPRESA           ';
            v_sql := v_sql || CHR ( 10 ) || ' ,COD_ESTAB          ';
            v_sql := v_sql || CHR ( 10 ) || ' ,DATA_FISCAL        ';
            v_sql := v_sql || CHR ( 10 ) || ' ,NUM_DOCFIS         ';
            v_sql := v_sql || CHR ( 10 ) || ' ,NUM_CONTROLE_DOCTO  ';
            v_sql := v_sql || CHR ( 10 ) || ' ,NUM_AUTENTIC_NFE  ';
            v_sql := v_sql || CHR ( 10 ) || ' ,COD_FIS_JUR       ';
            v_sql := v_sql || CHR ( 10 ) || ' ,CPF_CGC           ';
            v_sql := v_sql || CHR ( 10 ) || ' ,COD_DOCTO         ';
            v_sql := v_sql || CHR ( 10 ) || ' ,COD_MODELO        ';
            v_sql := v_sql || CHR ( 10 ) || ' ,COD_CFO           ';
            v_sql := v_sql || CHR ( 10 ) || ' ,COD_PRODUTO       ';
            v_sql := v_sql || CHR ( 10 ) || ' ,DESCRICAO         ';
            v_sql := v_sql || CHR ( 10 ) || ' ,NUM_ITEM          ';
            v_sql := v_sql || CHR ( 10 ) || ' ,VLR_CONTAB_ITEM   ';
            v_sql := v_sql || CHR ( 10 ) || ' ,VLR_ITEM          ';
            v_sql := v_sql || CHR ( 10 ) || ' ,VLR_BASE_ICMS_1   ';
            v_sql := v_sql || CHR ( 10 ) || ' ,VLR_BASE_ICMS_2   ';
            v_sql := v_sql || CHR ( 10 ) || ' ,VLR_BASE_ICMS_3   ';
            v_sql := v_sql || CHR ( 10 ) || ' ,VLR_BASE_ICMS_4   ';
            v_sql := v_sql || CHR ( 10 ) || ' ,VLR_IPI_NDESTAC   ';
            v_sql := v_sql || CHR ( 10 ) || ' ,VLR_DESCONTO      ';
            v_sql := v_sql || CHR ( 10 ) || ' ,ALIQ_TRIBUTO_ICMS ';
            v_sql := v_sql || CHR ( 10 ) || ' ,VLR_ICMS_ST       ';
            v_sql := v_sql || CHR ( 10 ) || ' ,VLR_BASE_ST       ';
            v_sql := v_sql || CHR ( 10 ) || ' ,VLR_ICMS_PROPRIO  ';
            v_sql := v_sql || CHR ( 10 ) || ' ,CST               ';
            v_sql := v_sql || CHR ( 10 ) || ' ,QUANTIDADE        ';
            v_sql := v_sql || CHR ( 10 ) || ' ,NCM               ';
            v_sql := v_sql || CHR ( 10 ) || ' ,MVA               ';
            v_sql := v_sql || CHR ( 10 ) || ' ,PMC_PAUTA         ';
            v_sql := v_sql || CHR ( 10 ) || ' ,TP_CALC           ';
            v_sql := v_sql || CHR ( 10 ) || ' ,SIT_TRIB          ';
            v_sql := v_sql || CHR ( 10 ) || ' ,PERC_RED_BSST     ';
            v_sql := v_sql || CHR ( 10 ) || ' ,FINALIDADE        ';
            v_sql := v_sql || CHR ( 10 ) || ' ,ALIQ_INTERNA      ';
            v_sql := v_sql || CHR ( 10 ) || ' ,VLR_UNIT_ITEM     ';
            v_sql := v_sql || CHR ( 10 ) || ' ,ICMS_PROPRIO      ';
            v_sql := v_sql || CHR ( 10 ) || ' ,BC_ICMS_ST        ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || ' ,CASE WHEN ((BC_ICMS_ST*(ALIQ_INTERNA/100)) - ICMS_PROPRIO) > 0 THEN ((BC_ICMS_ST*(ALIQ_INTERNA/100)) - ICMS_PROPRIO) ';
            v_sql := v_sql || CHR ( 10 ) || ' ELSE 0 END  AS ICMS_ST ';
            v_sql := v_sql || CHR ( 10 ) || ' ,COD_ESTADO_TO     ';
            v_sql := v_sql || CHR ( 10 ) || ' ,COD_ESTADO_FROM   ';
            v_sql := v_sql || CHR ( 10 ) || ' ,PROC_ID           ';
            v_sql := v_sql || CHR ( 10 ) || ' ,NM_USUARIO        ';
            v_sql := v_sql || CHR ( 10 ) || ' ,DT_CARGA          ';
            v_sql := v_sql || CHR ( 10 ) || ' ,SERIE_DOCFIS      ';
            v_sql := v_sql || CHR ( 10 ) || ' ,COD_NATUREZA_OP   ';
            --V_SQL := V_SQL||chr(10) || '         BULK COLLECT INTO   L_TB_FIN048_RET_NF_SAI  ';
            v_sql := v_sql || CHR ( 10 ) || ' FROM (     ';
            v_sql := v_sql || CHR ( 10 ) || '  SELECT ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '             COD_EMPRESA  , COD_ESTAB  , DATA_FISCAL  , NUM_DOCFIS  , NUM_CONTROLE_DOCTO  , NUM_AUTENTIC_NFE  , COD_FIS_JUR  , CPF_CGC  , COD_DOCTO  , COD_MODELO ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '           , COD_CFO  , COD_PRODUTO  , DESCRICAO  , NUM_ITEM  , VLR_CONTAB_ITEM  , VLR_ITEM  , VLR_BASE_ICMS_1  , VLR_BASE_ICMS_2  , VLR_BASE_ICMS_3  , VLR_BASE_ICMS_4 ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '           , VLR_IPI_NDESTAC  , VLR_DESCONTO  , ALIQ_TRIBUTO_ICMS  , VLR_ICMS_ST  , VLR_BASE_ST  , VLR_ICMS_PROPRIO  , CST  , QUANTIDADE  , NCM ';
            v_sql := v_sql || CHR ( 10 ) || '           -- GRUPO TABELÃO  ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '           , MVA  , PMC_PAUTA  , TP_CALC  , SIT_TRIB  , PERC_RED_BSST  , FINALIDADE  , ALIQ_INTERNA  ';
            v_sql := v_sql || CHR ( 10 ) || '           --  GRUPO CALCULADO ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '           , (VLR_ITEM/QUANTIDADE)                                                                       AS  VLR_UNIT_ITEM ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '           , (VLR_ITEM * ALIQ_INTERNA /100) * (1 - PERC_RED_BSST/100)                                  AS  ICMS_PROPRIO      ';
            v_sql := v_sql || CHR ( 10 ) || '       ,  (  CASE ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '                  WHEN  PMC_PAUTA > 0  THEN ( (PMC_PAUTA * QUANTIDADE) * (1 - PERC_RED_BSST/100))        ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '                  WHEN  PMC_PAUTA = 0  THEN (VLR_ITEM * (1+ MVA/100) * (1 - PERC_RED_BSST/100)) END )    AS BC_ICMS_ST   ';
            v_sql := v_sql || CHR ( 10 ) || ' , ( (  CASE ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '                  WHEN  PMC_PAUTA > 0  THEN ( (PMC_PAUTA * QUANTIDADE) * (1 - PERC_RED_BSST/100))        ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '                  WHEN  PMC_PAUTA = 0  THEN (VLR_ITEM * (1+ MVA/100) * (1 - PERC_RED_BSST/100)) END ) * (TO_NUMBER(ALIQ_INTERNA/100)) - ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '                 (VLR_ITEM * ALIQ_INTERNA/100 ) * (1 - PERC_RED_BSST/100)) ICMS_ST ';
            v_sql := v_sql || CHR ( 10 ) || '       , COD_ESTADO_TO ';
            v_sql := v_sql || CHR ( 10 ) || '       , COD_ESTADO_FROM ';
            v_sql := v_sql || CHR ( 10 ) || '       , PROC_ID ';
            v_sql := v_sql || CHR ( 10 ) || '       , NM_USUARIO ';
            v_sql := v_sql || CHR ( 10 ) || '       , DT_CARGA   ';
            v_sql := v_sql || CHR ( 10 ) || '       , SERIE_DOCFIS ';
            v_sql := v_sql || CHR ( 10 ) || '       , COD_NATUREZA_OP ';
            v_sql := v_sql || CHR ( 10 ) || '      FROM ( ';
            v_sql := v_sql || CHR ( 10 ) || '      SELECT   ';
            v_sql := v_sql || CHR ( 10 ) || '         /*+ result_cache */ ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '           X08.COD_EMPRESA                                                       AS COD_EMPRESA                      --  1 ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '         , X08.COD_ESTAB                                                         AS COD_ESTAB                        --  2 ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '         , X08.DATA_FISCAL                                                       AS DATA_FISCAL                      --  3 ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '         , X08.NUM_DOCFIS                                                        AS NUM_DOCFIS                       --  4 ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '         , X07.NUM_CONTROLE_DOCTO                                                AS NUM_CONTROLE_DOCTO               --  5 ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '         , X07.NUM_AUTENTIC_NFE                                                  AS NUM_AUTENTIC_NFE                 --  6 ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '         , X04.COD_FIS_JUR                                                       AS COD_FIS_JUR                      --  7 ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '         , X04.CPF_CGC                                                           AS CPF_CGC                          --  8 ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '         , X2005.COD_DOCTO                                                       AS COD_DOCTO                        --  9 ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '         , X2024.COD_MODELO                                                      AS COD_MODELO                       --  10';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '         , X2012.COD_CFO                                                         AS COD_CFO                          --  11';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '         , X2013.COD_PRODUTO                                                     AS COD_PRODUTO                      --  12';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '         , X2013.DESCRICAO                                                       AS DESCRICAO                        --  13';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '         , X08.NUM_ITEM                                                          AS NUM_ITEM                         --  14';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '         , X08.VLR_CONTAB_ITEM                                                   AS VLR_CONTAB_ITEM                  --  15';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '         , X08.VLR_ITEM                                                          AS VLR_ITEM                         --  16';
            v_sql := v_sql || CHR ( 10 ) || '         --- ';
            v_sql := v_sql || CHR ( 10 ) || '         --   base 1 ';
            v_sql := v_sql || CHR ( 10 ) || '         --- ';
            v_sql := v_sql || CHR ( 10 ) || '        ,( SELECT NVL(X08_BASE.VLR_BASE, 0) ';
            v_sql := v_sql || CHR ( 10 ) || '            FROM  MSAF.X08_BASE_MERC  X08_BASE ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '           WHERE  X08.COD_EMPRESA                = X08_BASE.COD_EMPRESA         ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '            AND    X08.COD_ESTAB                  = X08_BASE.COD_ESTAB          ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '            AND    X08.DATA_FISCAL                = X08_BASE.DATA_FISCAL        ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '            AND    X08.MOVTO_E_S                  = X08_BASE.MOVTO_E_S          ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '            AND    X08.NORM_DEV                   = X08_BASE.NORM_DEV           ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '            AND    X08.IDENT_DOCTO                = X08_BASE.IDENT_DOCTO        ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '            AND    X08.IDENT_FIS_JUR              = X08_BASE.IDENT_FIS_JUR      ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '            AND    X08.NUM_DOCFIS                 = X08_BASE.NUM_DOCFIS         ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '            AND    X08.SERIE_DOCFIS               = X08_BASE.SERIE_DOCFIS       ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '            AND    X08.SUB_SERIE_DOCFIS           = X08_BASE.SUB_SERIE_DOCFIS   ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '            AND    X08.DISCRI_ITEM                = X08_BASE.DISCRI_ITEM        ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '            AND    X08_BASE.COD_TRIBUTO           = ''ICMS''                      ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '            AND    X08_BASE.COD_TRIBUTACAO        = ''1'')                         AS  VLR_BASE_ICMS_1                     -- 17   ';
            v_sql := v_sql || CHR ( 10 ) || '          -- ';
            v_sql := v_sql || CHR ( 10 ) || '          -- base2  ';
            v_sql := v_sql || CHR ( 10 ) || '          --  ';
            v_sql := v_sql || CHR ( 10 ) || '        ,( SELECT NVL(X08_BASE.VLR_BASE, 0) ';
            v_sql := v_sql || CHR ( 10 ) || '            FROM  MSAF.X08_BASE_MERC  X08_BASE ';
            v_sql :=
                v_sql || CHR ( 10 ) || '           WHERE  X08.COD_EMPRESA                 = X08_BASE.COD_EMPRESA      ';
            v_sql :=
                v_sql || CHR ( 10 ) || '              AND    X08.COD_ESTAB                  = X08_BASE.COD_ESTAB      ';
            v_sql :=
                v_sql || CHR ( 10 ) || '              AND    X08.DATA_FISCAL                = X08_BASE.DATA_FISCAL    ';
            v_sql :=
                v_sql || CHR ( 10 ) || '              AND    X08.MOVTO_E_S                  = X08_BASE.MOVTO_E_S      ';
            v_sql :=
                v_sql || CHR ( 10 ) || '              AND    X08.NORM_DEV                   = X08_BASE.NORM_DEV       ';
            v_sql :=
                v_sql || CHR ( 10 ) || '              AND    X08.IDENT_DOCTO                = X08_BASE.IDENT_DOCTO    ';
            v_sql :=
                v_sql || CHR ( 10 ) || '              AND    X08.IDENT_FIS_JUR              = X08_BASE.IDENT_FIS_JUR  ';
            v_sql :=
                v_sql || CHR ( 10 ) || '              AND    X08.NUM_DOCFIS                 = X08_BASE.NUM_DOCFIS     ';
            v_sql :=
                v_sql || CHR ( 10 ) || '              AND    X08.SERIE_DOCFIS               = X08_BASE.SERIE_DOCFIS   ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '              AND    X08.SUB_SERIE_DOCFIS           = X08_BASE.SUB_SERIE_DOCFIS ';
            v_sql :=
                v_sql || CHR ( 10 ) || '              AND    X08.DISCRI_ITEM                = X08_BASE.DISCRI_ITEM ';
            v_sql := v_sql || CHR ( 10 ) || '              AND    X08_BASE.COD_TRIBUTO           = ''ICMS'' ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '              AND    X08_BASE.COD_TRIBUTACAO        = ''2'' )                       AS  VLR_BASE_ICMS_2                      -- 18   ';
            v_sql := v_sql || CHR ( 10 ) || '        ,( SELECT NVL(X08_BASE.VLR_BASE, 0) ';
            v_sql := v_sql || CHR ( 10 ) || '            FROM  MSAF.X08_BASE_MERC  X08_BASE ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '           WHERE  X08.COD_EMPRESA                = X08_BASE.COD_EMPRESA         ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '             AND    X08.COD_ESTAB                  = X08_BASE.COD_ESTAB         ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '             AND    X08.DATA_FISCAL                = X08_BASE.DATA_FISCAL       ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '             AND    X08.MOVTO_E_S                  = X08_BASE.MOVTO_E_S         ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '             AND    X08.NORM_DEV                   = X08_BASE.NORM_DEV          ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '             AND    X08.IDENT_DOCTO                = X08_BASE.IDENT_DOCTO       ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '             AND    X08.IDENT_FIS_JUR              = X08_BASE.IDENT_FIS_JUR     ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '             AND    X08.NUM_DOCFIS                 = X08_BASE.NUM_DOCFIS        ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '             AND    X08.SERIE_DOCFIS               = X08_BASE.SERIE_DOCFIS      ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '             AND    X08.SUB_SERIE_DOCFIS           = X08_BASE.SUB_SERIE_DOCFIS  ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '             AND    X08.DISCRI_ITEM                = X08_BASE.DISCRI_ITEM       ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '             AND    X08_BASE.COD_TRIBUTO           = ''ICMS''                     ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '             AND    X08_BASE.COD_TRIBUTACAO        = ''3'')                        AS  VLR_BASE_ICMS_3                     -- 19  ';
            v_sql := v_sql || CHR ( 10 ) || '          -- ';
            v_sql := v_sql || CHR ( 10 ) || '       ,( SELECT NVL(X08_BASE.VLR_BASE, 0)  ';
            v_sql := v_sql || CHR ( 10 ) || '            FROM  MSAF.X08_BASE_MERC  X08_BASE ';
            v_sql :=
                v_sql || CHR ( 10 ) || '           WHERE  X08.COD_EMPRESA                = X08_BASE.COD_EMPRESA     ';
            v_sql :=
                v_sql || CHR ( 10 ) || '             AND    X08.COD_ESTAB                  = X08_BASE.COD_ESTAB     ';
            v_sql :=
                v_sql || CHR ( 10 ) || '             AND    X08.DATA_FISCAL                = X08_BASE.DATA_FISCAL   ';
            v_sql :=
                v_sql || CHR ( 10 ) || '             AND    X08.MOVTO_E_S                  = X08_BASE.MOVTO_E_S     ';
            v_sql :=
                v_sql || CHR ( 10 ) || '             AND    X08.NORM_DEV                   = X08_BASE.NORM_DEV      ';
            v_sql :=
                v_sql || CHR ( 10 ) || '             AND    X08.IDENT_DOCTO                = X08_BASE.IDENT_DOCTO   ';
            v_sql :=
                v_sql || CHR ( 10 ) || '             AND    X08.IDENT_FIS_JUR              = X08_BASE.IDENT_FIS_JUR ';
            v_sql :=
                v_sql || CHR ( 10 ) || '             AND    X08.NUM_DOCFIS                 = X08_BASE.NUM_DOCFIS    ';
            v_sql :=
                v_sql || CHR ( 10 ) || '             AND    X08.SERIE_DOCFIS               = X08_BASE.SERIE_DOCFIS  ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '             AND    X08.SUB_SERIE_DOCFIS           = X08_BASE.SUB_SERIE_DOCFIS ';
            v_sql :=
                v_sql || CHR ( 10 ) || '             AND    X08.DISCRI_ITEM                = X08_BASE.DISCRI_ITEM ';
            v_sql := v_sql || CHR ( 10 ) || '             AND    X08_BASE.COD_TRIBUTO           = ''ICMS'' ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '             AND    X08_BASE.COD_TRIBUTACAO        = ''4'')                        AS VLR_BASE_ICMS_4                     -- 20   ';
            v_sql := v_sql || CHR ( 10 ) || '          -- ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '        , X08.VLR_IPI_NDESTAC                                                    AS VLR_IPI_NDESTAC                      -- 21  ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '        , X08.VLR_DESCONTO                                                      AS VLR_DESCONTO                         -- 22     ';
            v_sql := v_sql || CHR ( 10 ) || '         ,(SELECT    NVL(X08_BASE_TRIB.ALIQ_TRIBUTO, 0) ';
            v_sql := v_sql || CHR ( 10 ) || '            FROM MSAF.X08_TRIB_MERC  X08_BASE_TRIB ';
            v_sql :=
                v_sql || CHR ( 10 ) || '           WHERE  X08.COD_EMPRESA              = X08_BASE_TRIB.COD_EMPRESA   ';
            v_sql :=
                v_sql || CHR ( 10 ) || '            AND X08.COD_ESTAB                  = X08_BASE_TRIB.COD_ESTAB     ';
            v_sql :=
                v_sql || CHR ( 10 ) || '            AND X08.DATA_FISCAL                = X08_BASE_TRIB.DATA_FISCAL   ';
            v_sql :=
                v_sql || CHR ( 10 ) || '            AND X08.MOVTO_E_S                  = X08_BASE_TRIB.MOVTO_E_S     ';
            v_sql :=
                v_sql || CHR ( 10 ) || '            AND X08.NORM_DEV                   = X08_BASE_TRIB.NORM_DEV      ';
            v_sql :=
                v_sql || CHR ( 10 ) || '            AND X08.IDENT_DOCTO                = X08_BASE_TRIB.IDENT_DOCTO   ';
            v_sql :=
                v_sql || CHR ( 10 ) || '            AND X08.IDENT_FIS_JUR              = X08_BASE_TRIB.IDENT_FIS_JUR ';
            v_sql :=
                v_sql || CHR ( 10 ) || '            AND X08.NUM_DOCFIS                 = X08_BASE_TRIB.NUM_DOCFIS    ';
            v_sql :=
                v_sql || CHR ( 10 ) || '            AND X08.SERIE_DOCFIS               = X08_BASE_TRIB.SERIE_DOCFIS  ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '            AND X08.SUB_SERIE_DOCFIS           = X08_BASE_TRIB.SUB_SERIE_DOCFIS ';
            v_sql :=
                v_sql || CHR ( 10 ) || '            AND X08.DISCRI_ITEM                = X08_BASE_TRIB.DISCRI_ITEM ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '            AND X08_BASE_TRIB.COD_TRIBUTO      = ''ICMS''   )                      AS  ALIQ_TRIBUTO_ICMS                   -- 23    ';
            v_sql := v_sql || CHR ( 10 ) || '             --  ICMS-ST ';
            v_sql := v_sql || CHR ( 10 ) || '         ,(SELECT    NVL(X08_BASE_TRIB.VLR_TRIBUTO, 0) ';
            v_sql := v_sql || CHR ( 10 ) || '            FROM MSAF.X08_TRIB_MERC  X08_BASE_TRIB ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '           WHERE  X08.COD_EMPRESA              = X08_BASE_TRIB.COD_EMPRESA       ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '            AND X08.COD_ESTAB                  = X08_BASE_TRIB.COD_ESTAB         ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '            AND X08.DATA_FISCAL                = X08_BASE_TRIB.DATA_FISCAL       ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '            AND X08.MOVTO_E_S                  = X08_BASE_TRIB.MOVTO_E_S         ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '            AND X08.NORM_DEV                   = X08_BASE_TRIB.NORM_DEV          ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '            AND X08.IDENT_DOCTO                = X08_BASE_TRIB.IDENT_DOCTO       ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '            AND X08.IDENT_FIS_JUR              = X08_BASE_TRIB.IDENT_FIS_JUR     ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '            AND X08.NUM_DOCFIS                 = X08_BASE_TRIB.NUM_DOCFIS        ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '            AND X08.SERIE_DOCFIS               = X08_BASE_TRIB.SERIE_DOCFIS      ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '            AND X08.SUB_SERIE_DOCFIS           = X08_BASE_TRIB.SUB_SERIE_DOCFIS  ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '            AND X08.DISCRI_ITEM                = X08_BASE_TRIB.DISCRI_ITEM       ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '            AND X08_BASE_TRIB.COD_TRIBUTO      = ''ICMS-S''   )                    AS  VLR_ICMS_ST                         -- 24   ';
            v_sql := v_sql || CHR ( 10 ) || '            -- ';
            v_sql := v_sql || CHR ( 10 ) || '        ,( SELECT NVL(X08_BASE.VLR_BASE, 0)  ';
            v_sql := v_sql || CHR ( 10 ) || '            FROM  MSAF.X08_BASE_MERC  X08_BASE ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '           WHERE  X08.COD_EMPRESA                = X08_BASE.COD_EMPRESA         ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '          AND    X08.COD_ESTAB                  = X08_BASE.COD_ESTAB            ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '          AND    X08.DATA_FISCAL                = X08_BASE.DATA_FISCAL          ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '          AND    X08.MOVTO_E_S                  = X08_BASE.MOVTO_E_S            ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '          AND    X08.NORM_DEV                   = X08_BASE.NORM_DEV             ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '          AND    X08.IDENT_DOCTO                = X08_BASE.IDENT_DOCTO          ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '          AND    X08.IDENT_FIS_JUR              = X08_BASE.IDENT_FIS_JUR        ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '          AND    X08.NUM_DOCFIS                 = X08_BASE.NUM_DOCFIS           ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '          AND    X08.SERIE_DOCFIS               = X08_BASE.SERIE_DOCFIS         ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '          AND    X08.SUB_SERIE_DOCFIS           = X08_BASE.SUB_SERIE_DOCFIS     ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '          AND    X08.DISCRI_ITEM                = X08_BASE.DISCRI_ITEM          ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '          AND    X08_BASE.COD_TRIBUTO           = ''ICMS-S''                      ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '          AND    X08_BASE.COD_TRIBUTACAO        = ''1'')                           AS  VLR_BASE_ST                         -- 25  ';
            v_sql := v_sql || CHR ( 10 ) || '             --        ';
            v_sql := v_sql || CHR ( 10 ) || '       ,(SELECT    NVL(X08_BASE_TRIB.VLR_TRIBUTO, 0) ';
            v_sql := v_sql || CHR ( 10 ) || '            FROM MSAF.X08_TRIB_MERC  X08_BASE_TRIB ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '           WHERE  X08.COD_EMPRESA              = X08_BASE_TRIB.COD_EMPRESA        ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '            AND X08.COD_ESTAB                  = X08_BASE_TRIB.COD_ESTAB          ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '            AND X08.DATA_FISCAL                = X08_BASE_TRIB.DATA_FISCAL        ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '            AND X08.MOVTO_E_S                  = X08_BASE_TRIB.MOVTO_E_S          ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '            AND X08.NORM_DEV                   = X08_BASE_TRIB.NORM_DEV           ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '            AND X08.IDENT_DOCTO                = X08_BASE_TRIB.IDENT_DOCTO        ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '            AND X08.IDENT_FIS_JUR              = X08_BASE_TRIB.IDENT_FIS_JUR      ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '            AND X08.NUM_DOCFIS                 = X08_BASE_TRIB.NUM_DOCFIS         ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '            AND X08.SERIE_DOCFIS               = X08_BASE_TRIB.SERIE_DOCFIS       ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '            AND X08.SUB_SERIE_DOCFIS           = X08_BASE_TRIB.SUB_SERIE_DOCFIS   ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '            AND X08.DISCRI_ITEM                = X08_BASE_TRIB.DISCRI_ITEM        ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '            AND X08_BASE_TRIB.COD_TRIBUTO      = ''ICMS''   )                      AS  VLR_ICMS_PROPRIO                    --  26 ';
            v_sql := v_sql || CHR ( 10 ) || '            -- ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '         ,   Y2026.COD_SITUACAO_B                                                AS  CST                                 --  27 ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '         ,   X08.QUANTIDADE                                                      AS  QUANTIDADE                          --  28 ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '         ,   X2043.COD_NBM                                                       AS  NCM                                 --  29 ';
            v_sql := v_sql || CHR ( 10 ) || '         --       ';
            v_sql := v_sql || CHR ( 10 ) || '         --   MVA ';
            v_sql := v_sql || CHR ( 10 ) || '         --       ';
            v_sql := v_sql || CHR ( 10 ) || '         ,( SELECT  MVA_PCT_BBL  ';
            v_sql := v_sql || CHR ( 10 ) || '             FROM ( ';
            v_sql := v_sql || CHR ( 10 ) || '            SELECT /*+DRIVING_SITE(TAB)*/ ';
            v_sql := v_sql || CHR ( 10 ) || '               TAB.MVA_PCT_BBL ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '          , RANK() OVER (PARTITION BY TAB.SETID, TAB.INV_ITEM_ID ORDER BY TAB.EFFDT DESC) AS RANK   ';
            v_sql := v_sql || CHR ( 10 ) || '            FROM msafi.PS_DSP_ITEM_LN_MVA     TAB ';
            v_sql := v_sql || CHR ( 10 ) || '         ,    MSAFI.DSP_ESTABELECIMENTO    EST           ';
            v_sql := v_sql || CHR ( 10 ) || '             WHERE TAB.SETID             = ''GERAL''       ';
            v_sql := v_sql || CHR ( 10 ) || '              AND  TAB.INV_ITEM_ID       = X2013.COD_PRODUTO  ';
            v_sql := v_sql || CHR ( 10 ) || '              AND  EST.COD_EMPRESA       = X07.COD_EMPRESA    ';
            v_sql := v_sql || CHR ( 10 ) || '              AND  EST.COD_ESTAB         = X07.COD_ESTAB      ';
            v_sql := v_sql || CHR ( 10 ) || '              AND  TAB.CRIT_STATE_TO_PBL = EST.COD_ESTADO     ';
            v_sql := v_sql || CHR ( 10 ) || '              AND  TAB.CRIT_STATE_FR_PBL = EST.COD_ESTADO     ';
            v_sql := v_sql || CHR ( 10 ) || '              AND TAB.EFFDT             <= X07.DATA_FISCAL    ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '             )  WHERE RANK = 1 )                                                         AS    MVA      -- 30 ';
            v_sql := v_sql || CHR ( 10 ) || '         ---    ';
            v_sql := v_sql || CHR ( 10 ) || '         -- PMC_PAUTA ';
            v_sql := v_sql || CHR ( 10 ) || '         ---  ';
            v_sql := v_sql || CHR ( 10 ) || '     , NVL(( SELECT DISTINCT PMC_PAUTA  ';
            v_sql := v_sql || CHR ( 10 ) || '         FROM ( ';
            v_sql := v_sql || CHR ( 10 ) || '          SELECT /*+DRIVING_SITE(TAB)*/ ';
            v_sql := v_sql || CHR ( 10 ) || '                 DISTINCT NVL((PMC.DSP_PMC), 0)  PMC_PAUTA ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '        , RANK() OVER (PARTITION BY PMC.SETID, PMC.INV_ITEM_ID, PMC.DSP_ALIQ_ICMS_ID, PMC.UNIT_OF_MEASURE ORDER BY PMC.EFFDT DESC) AS RANK  ';
            v_sql := v_sql || CHR ( 10 ) || '          FROM msafi.PS_DSP_ITEM_LN_MVA     TAB ';
            v_sql := v_sql || CHR ( 10 ) || '          ,    MSAFI.DSP_ESTABELECIMENTO    EST  ';
            v_sql := v_sql || CHR ( 10 ) || '          ,    MSAFI.DPSP_PRECO_ITEM_GTT    PMC  ';
            v_sql := v_sql || CHR ( 10 ) || '          WHERE TAB.SETID             = ''GERAL''  ';
            v_sql := v_sql || CHR ( 10 ) || '           AND TAB.INV_ITEM_ID = PMC.INV_ITEM_ID ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '           AND MSAFI.PS_TRANSLATE(''DSP_ALIQ_ICMS'',TAB.DSP_ALIQ_ICMS) = PMC.DSP_ALIQ_ICMS_ID ';
            v_sql := v_sql || CHR ( 10 ) || '           AND  PMC.UNIT_OF_MEASURE = ''UN'' ';
            v_sql := v_sql || CHR ( 10 ) || '           AND  TAB.INV_ITEM_ID       = X2013.COD_PRODUTO   ';
            v_sql := v_sql || CHR ( 10 ) || '           AND  EST.COD_EMPRESA       = X07.COD_EMPRESA     ';
            v_sql := v_sql || CHR ( 10 ) || '           AND  EST.COD_ESTAB         = X07.COD_ESTAB       ';
            v_sql := v_sql || CHR ( 10 ) || '           AND  TAB.CRIT_STATE_TO_PBL = EST.COD_ESTADO      ';
            v_sql := v_sql || CHR ( 10 ) || '           AND  TAB.CRIT_STATE_FR_PBL = EST.COD_ESTADO      ';
            v_sql := v_sql || CHR ( 10 ) || '           AND TAB.EFFDT             <= X07.DATA_FISCAL     ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '          )  WHERE RANK = 1 ) ,0)                                                            AS    PMC_PAUTA        --- 31  ';
            v_sql := v_sql || CHR ( 10 ) || '       ---  ';
            v_sql := v_sql || CHR ( 10 ) || '       -- TP_CALC ';
            v_sql := v_sql || CHR ( 10 ) || '       --- ';
            v_sql := v_sql || CHR ( 10 ) || '  ,    ( SELECT  TP_CALC  ';
            v_sql := v_sql || CHR ( 10 ) || '         FROM ( ';
            v_sql := v_sql || CHR ( 10 ) || '         SELECT /*+DRIVING_SITE(TAB)*/ ';
            v_sql := v_sql || CHR ( 10 ) || '                TAB.DSP_TP_CALC_ST  TP_CALC ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '       , RANK() OVER (PARTITION BY TAB.SETID, TAB.INV_ITEM_ID ORDER BY TAB.EFFDT DESC) AS RANK   ';
            v_sql := v_sql || CHR ( 10 ) || '         FROM msafi.PS_DSP_ITEM_LN_MVA     TAB ';
            v_sql := v_sql || CHR ( 10 ) || '         ,    MSAFI.DSP_ESTABELECIMENTO    EST     ';
            v_sql := v_sql || CHR ( 10 ) || '         WHERE TAB.SETID             = ''GERAL''   ';
            v_sql := v_sql || CHR ( 10 ) || '          AND  TAB.INV_ITEM_ID       = X2013.COD_PRODUTO    ';
            v_sql := v_sql || CHR ( 10 ) || '          AND  EST.COD_EMPRESA       = X07.COD_EMPRESA       ';
            v_sql := v_sql || CHR ( 10 ) || '          AND  EST.COD_ESTAB         = X07.COD_ESTAB         ';
            v_sql := v_sql || CHR ( 10 ) || '          AND  TAB.CRIT_STATE_TO_PBL = EST.COD_ESTADO        ';
            v_sql := v_sql || CHR ( 10 ) || '          AND  TAB.CRIT_STATE_FR_PBL = EST.COD_ESTADO        ';
            v_sql := v_sql || CHR ( 10 ) || '          AND TAB.EFFDT             <= X07.DATA_FISCAL       ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '         )  WHERE RANK = 1 )                                                              AS    TP_CALC    -- 32  ';
            v_sql := v_sql || CHR ( 10 ) || '       --  ';
            v_sql := v_sql || CHR ( 10 ) || '       -- SIT_TRIB ';
            v_sql := v_sql || CHR ( 10 ) || '       --  ';
            v_sql := v_sql || CHR ( 10 ) || '       ,( SELECT  SIT_TRIB ';
            v_sql := v_sql || CHR ( 10 ) || '         FROM ( ';
            v_sql := v_sql || CHR ( 10 ) || '         SELECT /*+DRIVING_SITE(TAB)*/  ';
            v_sql := v_sql || CHR ( 10 ) || '                TAB.DSP_ST_TRIBUT_ICMS  SIT_TRIB ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '       , RANK() OVER (PARTITION BY TAB.SETID, TAB.INV_ITEM_ID ORDER BY TAB.EFFDT DESC) AS RANK    ';
            v_sql := v_sql || CHR ( 10 ) || '         FROM msafi.PS_DSP_ITEM_LN_MVA     TAB ';
            v_sql := v_sql || CHR ( 10 ) || '         ,    MSAFI.DSP_ESTABELECIMENTO    EST                           ';
            v_sql :=
                v_sql || CHR ( 10 ) || '         WHERE TAB.SETID             = ''GERAL''                           ';
            v_sql := v_sql || CHR ( 10 ) || '          AND  TAB.INV_ITEM_ID       = X2013.COD_PRODUTO                 ';
            v_sql := v_sql || CHR ( 10 ) || '          AND  EST.COD_EMPRESA       = X07.COD_EMPRESA                   ';
            v_sql := v_sql || CHR ( 10 ) || '          AND  EST.COD_ESTAB         = X07.COD_ESTAB                     ';
            v_sql := v_sql || CHR ( 10 ) || '          AND  TAB.CRIT_STATE_TO_PBL = EST.COD_ESTADO                    ';
            v_sql := v_sql || CHR ( 10 ) || '          AND  TAB.CRIT_STATE_FR_PBL = EST.COD_ESTADO                    ';
            v_sql := v_sql || CHR ( 10 ) || '          AND TAB.EFFDT             <= X07.DATA_FISCAL                   ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '         )  WHERE RANK = 1 )                                                             AS    SIT_TRIB    --  33 ';
            v_sql := v_sql || CHR ( 10 ) || '          --- ';
            v_sql := v_sql || CHR ( 10 ) || '         -- PERC_RED_BSST ';
            v_sql := v_sql || CHR ( 10 ) || '         --- ';
            v_sql := v_sql || CHR ( 10 ) || '  ,    ( SELECT  PERC_RED_BSST  ';
            v_sql := v_sql || CHR ( 10 ) || '         FROM ( ';
            v_sql := v_sql || CHR ( 10 ) || '         SELECT /*+DRIVING_SITE(TAB)*/ ';
            v_sql := v_sql || CHR ( 10 ) || '                TAB.DSP_PCT_RED_ICMSST  PERC_RED_BSST ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '       , RANK() OVER (PARTITION BY TAB.SETID, TAB.INV_ITEM_ID ORDER BY TAB.EFFDT DESC) AS RANK   ';
            v_sql := v_sql || CHR ( 10 ) || '         FROM msafi.PS_DSP_ITEM_LN_MVA     TAB ';
            v_sql := v_sql || CHR ( 10 ) || '         ,    MSAFI.DSP_ESTABELECIMENTO    EST  ';
            v_sql := v_sql || CHR ( 10 ) || '         WHERE TAB.SETID             = ''GERAL''   ';
            v_sql := v_sql || CHR ( 10 ) || '          AND  TAB.INV_ITEM_ID       = X2013.COD_PRODUTO  ';
            v_sql := v_sql || CHR ( 10 ) || '          AND  EST.COD_EMPRESA       = X07.COD_EMPRESA    ';
            v_sql := v_sql || CHR ( 10 ) || '          AND  EST.COD_ESTAB         = X07.COD_ESTAB      ';
            v_sql := v_sql || CHR ( 10 ) || '          AND  TAB.CRIT_STATE_TO_PBL = EST.COD_ESTADO     ';
            v_sql := v_sql || CHR ( 10 ) || '          AND  TAB.CRIT_STATE_FR_PBL = EST.COD_ESTADO     ';
            v_sql := v_sql || CHR ( 10 ) || '          AND TAB.EFFDT             <= X07.DATA_FISCAL    ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '         )  WHERE RANK = 1 )                                                         AS    PERC_RED_BSST     --34  ';
            v_sql := v_sql || CHR ( 10 ) || '         --- ';
            v_sql := v_sql || CHR ( 10 ) || '         -- FINALIDADE ';
            v_sql := v_sql || CHR ( 10 ) || '         ---  ';
            v_sql := v_sql || CHR ( 10 ) || '  ,    ( SELECT  trim(FINALIDADE) FINALIDADE   ';
            v_sql := v_sql || CHR ( 10 ) || '         FROM ( ';
            v_sql := v_sql || CHR ( 10 ) || '         SELECT /*+DRIVING_SITE(TAB)*/  ';
            v_sql := v_sql || CHR ( 10 ) || '                TAB.PURCH_PROP_BRL  FINALIDADE  ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '       , RANK() OVER (PARTITION BY TAB.SETID, TAB.INV_ITEM_ID ORDER BY TAB.EFFDT DESC) AS RANK    ';
            v_sql := v_sql || CHR ( 10 ) || '         FROM msafi.PS_DSP_ITEM_LN_MVA     TAB ';
            v_sql := v_sql || CHR ( 10 ) || '         ,    MSAFI.DSP_ESTABELECIMENTO    EST                           ';
            v_sql := v_sql || CHR ( 10 ) || '         WHERE TAB.SETID             = ''GERAL''   ';
            v_sql := v_sql || CHR ( 10 ) || '          AND  TAB.INV_ITEM_ID       = X2013.COD_PRODUTO ';
            v_sql := v_sql || CHR ( 10 ) || '          AND  EST.COD_EMPRESA       = X07.COD_EMPRESA    ';
            v_sql := v_sql || CHR ( 10 ) || '          AND  EST.COD_ESTAB         = X07.COD_ESTAB      ';
            v_sql := v_sql || CHR ( 10 ) || '          AND  TAB.CRIT_STATE_TO_PBL = EST.COD_ESTADO     ';
            v_sql := v_sql || CHR ( 10 ) || '          AND  TAB.CRIT_STATE_FR_PBL = EST.COD_ESTADO     ';
            v_sql := v_sql || CHR ( 10 ) || '          AND TAB.EFFDT             <= X07.DATA_FISCAL    ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '         )  WHERE RANK = 1 )                                                         AS    FINALIDADE     -- 35  ';
            v_sql := v_sql || CHR ( 10 ) || '         ---   ';
            v_sql := v_sql || CHR ( 10 ) || '         -- ALIQ_INTERNA ';
            v_sql := v_sql || CHR ( 10 ) || '        ,         (SELECT trim(ALIQ_INTERNA) ALIQ_INTERNA ';
            v_sql := v_sql || CHR ( 10 ) || '                        FROM ( ';
            v_sql := v_sql || CHR ( 10 ) || '                     SELECT    /*+DRIVING_SITE(A)*/  ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '                        RANK() OVER (PARTITION BY SETID, INV_ITEM_ID ORDER BY EFFDT DESC) RANK, ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '                       TO_NUMBER(REPLACE(REPLACE (MSAFI.PS_TRANSLATE(''DSP_ALIQ_ICMS'',DSP_ALIQ_ICMS), ''%'', ''''), ''<VLR INVALIDO>'', ''0'')) AS ALIQ_INTERNA ';
            v_sql := v_sql || CHR ( 10 ) || '                     FROM MSAFI.PS_DSP_LN_MVA_HIS A ';
            v_sql := v_sql || CHR ( 10 ) || '                      WHERE INV_ITEM_ID       =  X2013.COD_PRODUTO ';
            v_sql := v_sql || CHR ( 10 ) || '                      AND    CRIT_STATE_TO_PBL = ''ES'' ';
            v_sql := v_sql || CHR ( 10 ) || '                      AND    CRIT_STATE_FR_PBL = ''ES'' ';
            v_sql := v_sql || CHR ( 10 ) || '                      AND    SETID             = ''GERAL'' ';
            v_sql := v_sql || CHR ( 10 ) || '                      AND    EFFDT            <= X07.DATA_FISCAL)      ';
            v_sql := v_sql || CHR ( 10 ) || '                      WHERE RANK = 1   )         AS ALIQ_INTERNA  --36 ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '        ,TRUNC( X08.VLR_ITEM/X08.QUANTIDADE,2 )                                     AS VLR_UNIT_ITEM     --37 ';
            v_sql := v_sql || CHR ( 10 ) || '         ---  ';
            v_sql := v_sql || CHR ( 10 ) || '         -- ICMS_PROPRIO     ';
            v_sql := v_sql || CHR ( 10 ) || '         ---';
            v_sql := v_sql || CHR ( 10 ) || '    ,  ( SELECT  ICMS_PROPRIO ';
            v_sql := v_sql || CHR ( 10 ) || '          FROM (  ';
            v_sql := v_sql || CHR ( 10 ) || '         SELECT /*+DRIVING_SITE(TAB)*/  ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '           ((X08.VLR_ITEM * TAB.DSP_ALIQ_ICMS/100) * (1 - DSP_PCT_RED_ICMSST/100 ) )ICMS_PROPRIO ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '       , RANK() OVER (PARTITION BY TAB.SETID, TAB.INV_ITEM_ID ORDER BY TAB.EFFDT DESC) AS RANK   ';
            v_sql := v_sql || CHR ( 10 ) || '         FROM msafi.PS_DSP_ITEM_LN_MVA     TAB ';
            v_sql :=
                v_sql || CHR ( 10 ) || '         ,    MSAFI.DSP_ESTABELECIMENTO    EST                             ';
            v_sql := v_sql || CHR ( 10 ) || '         WHERE TAB.SETID             = ''GERAL''   ';
            v_sql := v_sql || CHR ( 10 ) || '          AND  TAB.INV_ITEM_ID       = X2013.COD_PRODUTO  ';
            v_sql := v_sql || CHR ( 10 ) || '          AND  EST.COD_EMPRESA       = X07.COD_EMPRESA    ';
            v_sql := v_sql || CHR ( 10 ) || '          AND  EST.COD_ESTAB         = X07.COD_ESTAB      ';
            v_sql := v_sql || CHR ( 10 ) || '          AND  TAB.CRIT_STATE_TO_PBL = EST.COD_ESTADO     ';
            v_sql := v_sql || CHR ( 10 ) || '          AND  TAB.CRIT_STATE_FR_PBL = EST.COD_ESTADO     ';
            v_sql := v_sql || CHR ( 10 ) || '          AND TAB.EFFDT             <= X07.DATA_FISCAL    ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '         )  WHERE RANK = 1 )                                                             AS    ICMS_PROPRIO  --38 ';
            v_sql := v_sql || CHR ( 10 ) || '          -- ';
            v_sql := v_sql || CHR ( 10 ) || '          --  BC_ICMS_ST ';
            v_sql := v_sql || CHR ( 10 ) || '          -- ';
            v_sql := v_sql || CHR ( 10 ) || '      ,  ( SELECT  ROUND(BC_ICMS_ST,2) ';
            v_sql := v_sql || CHR ( 10 ) || '            FROM (  ';
            v_sql := v_sql || CHR ( 10 ) || '           SELECT /*+DRIVING_SITE(TAB)*/ ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '              ( CASE WHEN  nvl(TAB.PRICE_ST_BBL, 0) > 0 THEN  (  TAB.MVA_PCT_BBL*X08.QUANTIDADE ) *(  1- TAB.DSP_PCT_RED_ICMSST )      ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '                     WHEN  nvl(TAB.PRICE_ST_BBL,0)  = 0 THEN  ( X08.VLR_ITEM * ( 1 + MVA_PCT_BBL /100) * (1 - DSP_PCT_RED_ICMSST ) )   ';
            v_sql := v_sql || CHR ( 10 ) || '           END) BC_ICMS_ST ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '          , RANK() OVER (PARTITION BY TAB.SETID, TAB.INV_ITEM_ID ORDER BY TAB.EFFDT DESC) AS RANK    ';
            v_sql := v_sql || CHR ( 10 ) || '         FROM msafi.PS_DSP_ITEM_LN_MVA     TAB ';
            v_sql :=
                v_sql || CHR ( 10 ) || '         ,    MSAFI.DSP_ESTABELECIMENTO    EST                             ';
            v_sql := v_sql || CHR ( 10 ) || '         WHERE TAB.SETID             = ''GERAL''   ';
            v_sql := v_sql || CHR ( 10 ) || '          AND  TAB.INV_ITEM_ID       = X2013.COD_PRODUTO ';
            v_sql := v_sql || CHR ( 10 ) || '          AND  EST.COD_EMPRESA       = X07.COD_EMPRESA   ';
            v_sql := v_sql || CHR ( 10 ) || '          AND  EST.COD_ESTAB         = X07.COD_ESTAB     ';
            v_sql := v_sql || CHR ( 10 ) || '          AND  TAB.CRIT_STATE_TO_PBL = EST.COD_ESTADO    ';
            v_sql := v_sql || CHR ( 10 ) || '          AND  TAB.CRIT_STATE_FR_PBL = EST.COD_ESTADO    ';
            v_sql := v_sql || CHR ( 10 ) || '          AND TAB.EFFDT             <= X07.DATA_FISCAL   ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '         )  WHERE RANK = 1 )                                                                     AS    BC_ICMS_ST   --39  ';
            v_sql := v_sql || CHR ( 10 ) || '         -- ';
            v_sql := v_sql || CHR ( 10 ) || '         --  ICMS_ST ';
            v_sql := v_sql || CHR ( 10 ) || '         --- ';
            v_sql := v_sql || CHR ( 10 ) || '       ,  ( SELECT  ';
            v_sql := v_sql || CHR ( 10 ) || '           ROUND  ( (CASE  ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '                 WHEN ( BC_ICMS_ST * (ALIQUOTA_INTERNA/100 )) - ICMS_PROPRIO  < 0 THEN 0 ';
            v_sql :=
                v_sql || CHR ( 10 ) || '                  ELSE ( BC_ICMS_ST * (ALIQUOTA_INTERNA/100 )) - ICMS_PROPRIO ';
            v_sql := v_sql || CHR ( 10 ) || '                  END  ),2)  ';
            v_sql := v_sql || CHR ( 10 ) || '            FROM (  ';
            v_sql := v_sql || CHR ( 10 ) || '           SELECT /*+DRIVING_SITE(TAB)*/ ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '              ( CASE WHEN  nvl(TAB.PRICE_ST_BBL, 0) > 0 THEN  (  TAB.MVA_PCT_BBL*X08.QUANTIDADE ) *( 1- TAB.DSP_PCT_RED_ICMSST ) ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '                     WHEN  nvl(TAB.PRICE_ST_BBL,0)  = 0 THEN  ( X08.VLR_ITEM * ( 1 + MVA_PCT_BBL ) * (1 -DSP_PCT_RED_ICMSST ) )  ';
            v_sql := v_sql || CHR ( 10 ) || '             END) BC_ICMS_ST ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '             ,  ((X08.VLR_ITEM * TAB.DSP_ALIQ_ICMS/100) * (1 - DSP_PCT_RED_ICMSST/100  ) ) ICMS_PROPRIO ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '             ,    (TAB.DSP_ALIQ_ICMS/100)                   AS  ALIQUOTA_INTERNA ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '             , RANK() OVER (PARTITION BY TAB.SETID, TAB.INV_ITEM_ID ORDER BY TAB.EFFDT DESC) AS RANK   ';
            v_sql := v_sql || CHR ( 10 ) || '             FROM msafi.PS_DSP_ITEM_LN_MVA     TAB ';
            v_sql := v_sql || CHR ( 10 ) || '             ,    MSAFI.DSP_ESTABELECIMENTO    EST   ';
            v_sql := v_sql || CHR ( 10 ) || '             WHERE TAB.SETID             = ''GERAL''   ';
            v_sql := v_sql || CHR ( 10 ) || '              AND  TAB.INV_ITEM_ID       = X2013.COD_PRODUTO  ';
            v_sql := v_sql || CHR ( 10 ) || '              AND  EST.COD_EMPRESA       = X07.COD_EMPRESA    ';
            v_sql := v_sql || CHR ( 10 ) || '              AND  EST.COD_ESTAB         = X07.COD_ESTAB      ';
            v_sql := v_sql || CHR ( 10 ) || '              AND  TAB.CRIT_STATE_TO_PBL = EST.COD_ESTADO     ';
            v_sql := v_sql || CHR ( 10 ) || '              AND  TAB.CRIT_STATE_FR_PBL = EST.COD_ESTADO     ';
            v_sql := v_sql || CHR ( 10 ) || '              AND TAB.EFFDT             <= X07.DATA_FISCAL    ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '             )  WHERE RANK = 1 )                                                                      AS ICMS_ST             -- 40 ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '             ,NULL                                                                                    AS COD_ESTADO_TO       -- 41 ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '             ,NULL                                                                                    AS COD_ESTADO_FROM     -- 42 ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '            , '''
                || mproc_id
                || '''                                                                               AS PROC_ID             -- 43 ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '            , '''
                || mnm_usuario
                || '''                                                                             AS NM_USUARIO          -- 44 ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '             ,SYSDATE                                                                                 AS DT_CARGA            -- 45 ';
            v_sql := v_sql || CHR ( 10 ) || '             , X07.SERIE_DOCFIS ';
            v_sql := v_sql || CHR ( 10 ) || '             ,X2006.COD_NATUREZA_OP ';
            v_sql := v_sql || CHR ( 10 ) || '           FROM MSAF.X07_DOCTO_FISCAL        X07,      ';
            v_sql := v_sql || CHR ( 10 ) || '                MSAF.X08_ITENS_MERC          X08,      ';
            v_sql := v_sql || CHR ( 10 ) || '                MSAF.X04_PESSOA_FIS_JUR      X04,      ';
            v_sql := v_sql || CHR ( 10 ) || '                MSAF.ESTADO                  ESTADO,   ';
            v_sql := v_sql || CHR ( 10 ) || '                MSAF.X2005_TIPO_DOCTO        X2005,    ';
            v_sql := v_sql || CHR ( 10 ) || '                MSAF.X2024_MODELO_DOCTO      X2024,    ';
            v_sql := v_sql || CHR ( 10 ) || '                MSAF.X2012_COD_FISCAL        X2012,    ';
            v_sql := v_sql || CHR ( 10 ) || '                MSAF.X2013_PRODUTO           X2013,    ';
            v_sql := v_sql || CHR ( 10 ) || '                MSAF.X2043_COD_NBM           X2043,    ';
            v_sql := v_sql || CHR ( 10 ) || '                MSAF.Y2025_SIT_TRB_UF_A      Y2025,    ';
            v_sql := v_sql || CHR ( 10 ) || '                MSAF.Y2026_SIT_TRB_UF_B      Y2026,    ';
            v_sql := v_sql || CHR ( 10 ) || '                MSAF.X2006_NATUREZA_OP       X2006     ';
            v_sql := v_sql || CHR ( 10 ) || '          WHERE  X07.COD_EMPRESA         = X08.COD_EMPRESA ';
            v_sql := v_sql || CHR ( 10 ) || '              AND X07.COD_ESTAB          = X08.COD_ESTAB   ';
            v_sql := v_sql || CHR ( 10 ) || '              AND X07.DATA_FISCAL        = X08.DATA_FISCAL ';
            v_sql := v_sql || CHR ( 10 ) || '              AND X07.MOVTO_E_S          = X08.MOVTO_E_S   ';
            v_sql := v_sql || CHR ( 10 ) || '              AND X07.NORM_DEV           = X08.NORM_DEV    ';
            v_sql := v_sql || CHR ( 10 ) || '              AND X07.IDENT_DOCTO        = X08.IDENT_DOCTO ';
            v_sql := v_sql || CHR ( 10 ) || '              AND X07.IDENT_FIS_JUR      = X08.IDENT_FIS_JUR    ';
            v_sql := v_sql || CHR ( 10 ) || '              AND X07.NUM_DOCFIS         = X08.NUM_DOCFIS       ';
            v_sql := v_sql || CHR ( 10 ) || '              AND X07.SERIE_DOCFIS       = X08.SERIE_DOCFIS     ';
            v_sql := v_sql || CHR ( 10 ) || '              AND X07.SUB_SERIE_DOCFIS   = X08.SUB_SERIE_DOCFIS ';
            v_sql := v_sql || CHR ( 10 ) || '              AND X07.IDENT_MODELO       = X2024.IDENT_MODELO   ';
            v_sql := v_sql || CHR ( 10 ) || '              AND X07.IDENT_FIS_JUR      = X04.IDENT_FIS_JUR    ';
            v_sql := v_sql || CHR ( 10 ) || '              AND X07.IDENT_DOCTO        = X2005.IDENT_DOCTO    ';
            v_sql := v_sql || CHR ( 10 ) || '              AND X04.IDENT_ESTADO       = ESTADO.IDENT_ESTADO  ';
            v_sql := v_sql || CHR ( 10 ) || '              AND X08.IDENT_CFO          = X2012.IDENT_CFO      ';
            v_sql := v_sql || CHR ( 10 ) || '              AND X08.IDENT_PRODUTO      = X2013.IDENT_PRODUTO  ';
            v_sql := v_sql || CHR ( 10 ) || '              AND X2013.IDENT_NBM        = X2043.IDENT_NBM      ';
            v_sql := v_sql || CHR ( 10 ) || '              AND Y2025.IDENT_SITUACAO_A = X08.IDENT_SITUACAO_A     ';
            v_sql := v_sql || CHR ( 10 ) || '              AND X08.IDENT_SITUACAO_B   = Y2026.IDENT_SITUACAO_B   ';
            v_sql := v_sql || CHR ( 10 ) || '              AND X08.IDENT_NATUREZA_OP  = X2006.IDENT_NATUREZA_OP  ';
            --
            v_sql := v_sql || CHR ( 10 ) || '              AND X07.MOVTO_E_S                  = ''9'' ';
            v_sql := v_sql || CHR ( 10 ) || '              AND X07.SITUACAO                   = ''N'' ';
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '              AND X07.COD_EMPRESA                = '''
                || mcod_empresa
                || '''  ';
            v_sql :=
                v_sql || CHR ( 10 ) || '              AND X07.COD_ESTAB                  = ''' || pcod_estab || ''' ';
            v_sql := v_sql || CHR ( 10 ) || '              AND  X2012.COD_CFO                 =  ''5409'' ';
            --
            v_sql :=
                   v_sql
                || CHR ( 10 )
                || '              AND X07.DATA_FISCAL BETWEEN '''
                || pdt_ini
                || '''  AND  '''
                || pdt_fim
                || ''' )   )   ';



            -- EXECUTE IMMEDIATE V_SQL;
            OPEN c_aux FOR v_sql;

            LOOP
                FETCH c_aux
                    BULK COLLECT INTO l_tb_fin048_ret_nf_sai
                    LIMIT 100;

                v_count := v_count + 100;

                dbms_application_info.set_module ( '48 - SAIDA'
                                                 , '[' || v_count || ']' );

                BEGIN
                    FORALL i IN l_tb_fin048_ret_nf_sai.FIRST .. l_tb_fin048_ret_nf_sai.LAST SAVE EXCEPTIONS
                        INSERT INTO msafi.dpsp_fin048_ret_nf_sai
                        VALUES l_tb_fin048_ret_nf_sai ( i );

                    v_count_new := v_count_new + SQL%ROWCOUNT;
                    COMMIT;
                EXCEPTION
                    WHEN forall_failed THEN
                        l_errors := SQL%BULK_EXCEPTIONS.COUNT;

                        FOR i IN 1 .. l_errors LOOP
                            l_errno := SQL%BULK_EXCEPTIONS ( i ).ERROR_CODE;
                            l_msg := SQLERRM ( -l_errno );
                            l_idx := SQL%BULK_EXCEPTIONS ( i ).ERROR_INDEX;

                            INSERT INTO msafi.log_geral ( ora_err_number1
                                                        , ora_err_mesg1
                                                        , ora_err_optyp1
                                                        , cod_empresa
                                                        , cod_estab
                                                        , data_fiscal
                                                        , num_docfis
                                                        , num_item )
                                 VALUES ( dbms_utility.format_error_backtrace ( )
                                        , l_msg
                                        , l_idx
                                        , l_tb_fin048_ret_nf_sai ( i ).cod_empresa
                                        , l_tb_fin048_ret_nf_sai ( i ).cod_estab
                                        , l_tb_fin048_ret_nf_sai ( i ).data_fiscal
                                        , l_tb_fin048_ret_nf_sai ( i ).num_docfis
                                        , l_tb_fin048_ret_nf_sai ( i ).num_item );

                            COMMIT;
                        END LOOP;
                END;

                EXIT WHEN c_aux%NOTFOUND;
            END LOOP;

            CLOSE c_aux;

            BEGIN
                proc_upd_saida ( pdt_ini
                               , pdt_fim
                               , pcod_estab );

                COMMIT;
            --
            END;
        END;



        RETURN NVL ( v_count_new, 0 );
    END;


    PROCEDURE cabecalho ( pnm_empresa VARCHAR2
                        , pcnpj VARCHAR2
                        , v_data_hora_ini VARCHAR2
                        , mnm_cproc VARCHAR2
                        , pdt_ini DATE
                        , pdt_fim DATE
                        , pcod_estab VARCHAR2 )
    IS
    BEGIN
        --=================================================================================
        -- Cabeçalho do DW
        --=================================================================================
        vs_mlinha := NULL;
        vs_mlinha :=
            lib_str.w ( vs_mlinha
                      , 'Empresa: ' || mcod_empresa || ' - ' || pnm_empresa
                      , 1 );
        vs_mlinha :=
            lib_str.w ( vs_mlinha
                      ,    'Página : '
                        || LPAD ( vn_pagina
                                , 5
                                , '0' )
                      , 136 );
        lib_proc.add ( vs_mlinha
                     , NULL
                     , NULL
                     , 1 );

        vs_mlinha := NULL;
        vs_mlinha :=
            lib_str.w ( vs_mlinha
                      , 'CNPJ: ' || pcnpj
                      , 1 );
        lib_proc.add ( vs_mlinha
                     , NULL
                     , NULL
                     , 1 );

        vs_mlinha := NULL;
        vs_mlinha :=
            lib_str.w ( vs_mlinha
                      , 'Data de Processamento : ' || v_data_hora_ini
                      , 1 );
        lib_proc.add ( vs_mlinha
                     , NULL
                     , NULL
                     , 1 );

        vs_mlinha := NULL;
        vs_mlinha :=
            lib_str.w ( vs_mlinha
                      , LPAD ( '-'
                             , 150
                             , '-' )
                      , 1 );
        lib_proc.add ( vs_mlinha
                     , NULL
                     , NULL
                     , 1 );

        vs_mlinha := NULL;
        vs_mlinha := mnm_cproc;
        lib_proc.add ( vs_mlinha
                     , NULL
                     , NULL
                     , 1 );

        vs_mlinha := NULL;
        vs_mlinha := 'Data Inicial: ' || pdt_ini;
        lib_proc.add ( vs_mlinha
                     , NULL
                     , NULL
                     , 1 );

        vs_mlinha := NULL;
        vs_mlinha := 'Data Final: ' || pdt_fim;
        lib_proc.add ( vs_mlinha
                     , NULL
                     , NULL
                     , 1 );

        vs_mlinha := NULL;
        vs_mlinha :=
               'Período para Encerramento: '
            || TO_CHAR ( pdt_ini
                       , 'MM/YYYY' );
        lib_proc.add ( vs_mlinha
                     , NULL
                     , NULL
                     , 1 );

        vs_mlinha := NULL;
        vs_mlinha :=
            lib_str.w ( vs_mlinha
                      , LPAD ( '-'
                             , 150
                             , '-' )
                      , 1 );
        lib_proc.add ( vs_mlinha
                     , NULL
                     , NULL
                     , 1 );

        vs_mlinha := NULL;
        vs_mlinha :=
            lib_str.w ( vs_mlinha
                      , LPAD ( '-'
                             , 150
                             , '-' )
                      , 1 );
        lib_proc.add ( vs_mlinha
                     , NULL
                     , NULL
                     , 1 );

        vs_mlinha := NULL;
        vs_mlinha :=
            lib_str.w ( vs_mlinha
                      , ' '
                      , 1 );
        lib_proc.add ( vs_mlinha
                     , NULL
                     , NULL
                     , 1 );
    END cabecalho;



    FUNCTION executar ( pdt_ini DATE
                      , pdt_fim DATE
                      , pcod_estab VARCHAR2 )
        RETURN INTEGER
    IS
        v_qtd INTEGER;
        v_validar_status INTEGER := 0;
        v_existe_origem CHAR := 'S';

        v_data_inicial DATE
            :=   TRUNC ( pdt_ini )
               - (   TO_NUMBER ( TO_CHAR ( pdt_ini
                                         , 'DD' ) )
                   - 1 );
        v_data_final DATE := LAST_DAY ( pdt_fim );
        v_data_hora_ini VARCHAR2 ( 20 );
        p_proc_instance VARCHAR2 ( 30 );

        --PTAB_ENTRADA     VARCHAR2(50);
        v_sql VARCHAR2 ( 4000 );
        v_retorno_status VARCHAR2 ( 4000 );

        i INTEGER := 2;
        --Variaveis genericas
        v_text01 VARCHAR2 ( 6000 );
        v_class VARCHAR2 ( 1 ) := 'a';

        CURSOR lista_cds
        IS
            SELECT a.cod_estab
              FROM estabelecimento a
                 , estado b
                 , msafi.dsp_estabelecimento c
             WHERE b.ident_estado = a.ident_estado
               AND a.cod_empresa = c.cod_empresa
               AND a.cod_estab = c.cod_estab
               AND c.tipo = 'C'
               AND a.cod_empresa = mcod_empresa
               AND a.cod_estab = (CASE WHEN pcod_estab = 'TODOS' THEN a.cod_estab ELSE pcod_estab END);
    BEGIN
        -- Criação: Processo
        mproc_id :=
            lib_proc.new ( psp_nome => $$plsql_unit
                         , -- Package
                          prows => 48
                         , pcols => 200 );

        --Tela DW
        lib_proc.add_tipo ( pproc_id => mproc_id
                          , ptipo => 1
                          , ptitulo =>    TO_CHAR ( SYSDATE
                                                  , 'YYYYMMDDHH24MISS' )
                                       || '_Ret_ICMS_ES_Entradas'
                          , ptipo_arq => 1 );

        vn_pagina := 1;
        vn_linha := 48;

        EXECUTE IMMEDIATE 'ALTER SESSION SET TEMP_UNDO_ENABLED=FALSE '; --EVITAR PROBLEMAS DE GRAVACAO NAS GTTs

        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT="DD/MM/YYYY"';

        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS= '',.'' ';

        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        mnm_usuario := lib_parametros.recuperar ( 'USUARIO' );

        --MARCAR INCIO DA EXECUCAO
        v_data_hora_ini :=
            TO_CHAR ( SYSDATE
                    , 'DD/MM/YYYY HH24:MI.SS' );

        IF mcod_empresa IS NULL THEN
            lib_proc.add_log ( 'Código da empresa deve ser informado como parâmetro global.'
                             , 0 );
            lib_proc.add ( 'ERRO' );
            lib_proc.add ( 'CÓDIGO DA EMPRESA DEVE SER INFORMADO COMO PARÂMETRO GLOBAL.' );
            lib_proc.close;
            RETURN mproc_id;
        END IF;

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
                      , mnm_cproc
                      , pdt_ini
                      , pdt_fim
                      , pcod_estab );
        END LOOP;

        loga ( '---INI DO PROCESSAMENTO---'
             , FALSE );
        loga ( '<< PERIODO DE: ' || v_data_inicial || ' A ' || v_data_final || ' >>'
             , FALSE );

        --=================================================================================
        -- INICIO
        --=================================================================================
        --Permitir processo somente para um mês
        IF LAST_DAY ( pdt_ini ) = LAST_DAY ( pdt_fim ) THEN
            --=================================================================================
            -- INICIO
            --=================================================================================
            -- Um CD por Vez
            FOR cd IN lista_cds LOOP
                dbms_application_info.set_module ( $$plsql_unit
                                                 , 'Estab: ' || cd.cod_estab );

                --GERAR CHAVE PROC_ID
                SELECT ROUND ( dbms_random.VALUE ( 10000000000000
                                                 , 999999999999999 ) )
                  INTO p_proc_instance
                  FROM DUAL;

                --=================================================================================
                -- VALIDAR STATUS DE RELATÓRIOS ENCERRADOS
                --=================================================================================
                -- IGUAL À ZERO:      PARA PROCESSOS ABERTOS - AÇÃO: CARREGAR TABELA RETIFICACAO NFS DE ENTRADA
                -- DIFERENTE DE ZERO: PARA PROCESSOS ENCERRADOS - AÇÃO: CONSULTAR TABELA RETIFICACAO NFS DE ENTRADA
                ---------------------

                v_validar_status :=
                    msaf.dpsp_suporte_cproc_process.validar_status_rel ( mcod_empresa
                                                                       , cd.cod_estab
                                                                       , TO_NUMBER ( TO_CHAR ( pdt_ini
                                                                                             , 'YYYYMM' ) )
                                                                       , $$plsql_unit );

                --=================================================================================
                -- CARREGAR TABELA DE NOTAS DE ENTRADA
                --=================================================================================
                IF v_validar_status = 0 THEN
                    loga ( '>> INICIO CD: ' || cd.cod_estab || ' PROC INSERT ' || p_proc_instance
                         , FALSE );

                    ---------------------
                    -- LIMPEZA
                    ---------------------
                    DELETE FROM msafi.dpsp_fin048_ret_nf_sai
                          WHERE cod_empresa = mcod_empresa
                            AND cod_estab = cd.cod_estab
                            AND data_fiscal BETWEEN v_data_inicial AND v_data_final;

                    loga (
                              '::LIMPEZA DOS REGISTROS ANTERIORES (DPSP_FIN048_RET_NF_SAI), CD: '
                           || cd.cod_estab
                           || ' - QTDE '
                           || SQL%ROWCOUNT
                           || '::'
                         , FALSE
                    );

                    COMMIT;

                    --A carga irá executar o periodo inteiro, e depois consultar o periodo informado na tela.
                    --Exemplo: Parametrizado do dia 1 ao 10, então será carregado de 1 a 31, mas consultado de 1 a 10
                    v_qtd :=
                        carregar_nf_saida ( v_data_inicial
                                          , v_data_final
                                          , cd.cod_estab
                                          , v_data_hora_ini );



                    ---------------------
                    -- Informar CDs que retornarem sem dados de origem / select zerado
                    ---------------------
                    IF v_qtd = 0 THEN
                        --Inserir status como Aberto pois não há origem
                        msaf.dpsp_suporte_cproc_process.inserir_status_rel ( mcod_empresa
                                                                           , cd.cod_estab
                                                                           , TO_NUMBER ( TO_CHAR ( pdt_ini
                                                                                                 , 'YYYYMM' ) )
                                                                           , $$plsql_unit
                                                                           , mnm_cproc
                                                                           , mnm_tipo
                                                                           , 0
                                                                           , --Aberto
                                                                            $$plsql_unit
                                                                           , mproc_id
                                                                           , mnm_usuario
                                                                           , v_data_hora_ini );

                        lib_proc.add ( 'CD ' || cd.cod_estab || ' sem dados na origem.' );

                        lib_proc.add ( ' ' );
                        loga ( '---CD ' || cd.cod_estab || ' - SEM DADOS DE ORIGEM---'
                             , FALSE );
                        --LOGA('<< SEM DADOS DE ORIGEM >>', FALSE);

                        v_existe_origem := 'N';
                    ELSE
                        ---------------------
                        --Encerrar periodo caso não seja o mês atual e existam registros na origem
                        ---------------------
                        IF LAST_DAY ( pdt_ini ) < LAST_DAY ( SYSDATE ) THEN
                            msaf.dpsp_suporte_cproc_process.inserir_status_rel ( mcod_empresa
                                                                               , cd.cod_estab
                                                                               , TO_NUMBER ( TO_CHAR ( pdt_ini
                                                                                                     , 'YYYYMM' ) )
                                                                               , $$plsql_unit
                                                                               , mnm_cproc
                                                                               , mnm_tipo
                                                                               , 1
                                                                               , --Encerrado
                                                                                $$plsql_unit
                                                                               , mproc_id
                                                                               , mnm_usuario
                                                                               , v_data_hora_ini );
                            lib_proc.add ( 'CD ' || cd.cod_estab || ' - Período Encerrado' );

                            v_retorno_status :=
                                msaf.dpsp_suporte_cproc_process.retornar_status_rel (
                                                                                      mcod_empresa
                                                                                    , cd.cod_estab
                                                                                    , TO_NUMBER (
                                                                                                  TO_CHAR ( pdt_ini
                                                                                                          , 'YYYYMM' )
                                                                                      )
                                                                                    , $$plsql_unit
                                );
                            lib_proc.add ( 'Data de Encerramento: ' || v_retorno_status );

                            lib_proc.add ( ' ' );
                            loga ( '---ESTAB ' || cd.cod_estab || ' - PERIODO ENCERRADO: ' || v_retorno_status || '---'
                                 , FALSE );
                        ELSE
                            msaf.dpsp_suporte_cproc_process.inserir_status_rel ( mcod_empresa
                                                                               , cd.cod_estab
                                                                               , TO_NUMBER ( TO_CHAR ( pdt_ini
                                                                                                     , 'YYYYMM' ) )
                                                                               , $$plsql_unit
                                                                               , mnm_cproc
                                                                               , mnm_tipo
                                                                               , 0
                                                                               , --Aberto
                                                                                $$plsql_unit
                                                                               , mproc_id
                                                                               , mnm_usuario
                                                                               , v_data_hora_ini );

                            lib_proc.add ( 'CD ' || cd.cod_estab || ' - PERIODO EM ABERTO,'
                                         , 1 );
                            lib_proc.add ( 'Os registros gerados são temporários.'
                                         , 1 );

                            lib_proc.add ( ' '
                                         , 1 );
                            loga ( '---CD ' || cd.cod_estab || ' - PERIODO EM ABERTO---'
                                 , FALSE );
                        END IF;
                    END IF;
                --PERIODO JÁ ENCERRADO
                ELSE
                    ---   PROC_UPD_SAIDA ( V_DATA_INICIAL, V_DATA_FINAL,  CD.COD_ESTAB );

                    lib_proc.add ( 'CD ' || cd.cod_estab || ' - Período já processado e encerrado' );

                    v_retorno_status :=
                        msaf.dpsp_suporte_cproc_process.retornar_status_rel ( mcod_empresa
                                                                            , cd.cod_estab
                                                                            , TO_NUMBER ( TO_CHAR ( pdt_ini
                                                                                                  , 'YYYYMM' ) )
                                                                            , $$plsql_unit );
                    lib_proc.add ( 'Data de Encerramento: ' || v_retorno_status );

                    lib_proc.add ( ' ' );
                    loga (
                              '---CD '
                           || cd.cod_estab
                           || ' - PERIODO JÁ PROCESSADO E ENCERRADO: '
                           || v_retorno_status
                           || '---'
                         , FALSE
                    );
                END IF;

                --Limpar variaveis para proximo estab
                v_qtd := 0;
                v_retorno_status := '';
                v_sql := '';
            END LOOP;

            dbms_application_info.set_module ( $$plsql_unit
                                             , 'Estab: ' || pcod_estab || ' gerar arquivos ' );

            --=================================================================================
            -- GERAR ARQUIVO ANALITICO
            --=================================================================================
            lib_proc.add_tipo ( mproc_id
                              , i
                              ,    TO_CHAR ( pdt_ini
                                           , 'YYYYMM' )
                                || '_Ret_ICMS_ES_Saidas.xls'
                              , 2 );
            lib_proc.add ( dsp_planilha.header
                         , ptipo => i );
            lib_proc.add ( dsp_planilha.tabela_inicio
                         , ptipo => i );

            lib_proc.add ( dsp_planilha.linha (
                                                p_conteudo =>    dsp_planilha.campo ( 'SAIDAS' )
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
                                                                dsp_planilha.campo ( '' )
                                                              || --
                                                                dsp_planilha.campo ( '' )
                                                              || --
                                                                dsp_planilha.campo ( '' )
                                                              || --
                                                                dsp_planilha.campo ( '' )
                                                              || --
                                                                dsp_planilha.campo ( 'TABELAO' )
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
                                                                dsp_planilha.campo ( 'CALCULADO' )
                                                              || --
                                                                dsp_planilha.campo ( '' )
                                                              || --
                                                                dsp_planilha.campo ( '' )
                                                              || --
                                                                dsp_planilha.campo ( '' )
                                              , p_class => 'h'
                           )
                         , ptipo => i );

            FOR cd IN lista_cds LOOP
                lib_proc.add ( dsp_planilha.linha (
                                                    p_conteudo =>    dsp_planilha.campo ( 'COD_EMPRESA' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'COD_ESTAB' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'DATA_FISCAL' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'NUM_DOCFIS' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'NUM_CONTROLE_DOCTO' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'NUM_AUTENTIC_NFE' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'COD_FIS_JUR' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'CPF_CGC' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'COD_DOCTO' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'COD_MODELO' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'COD_CFO' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'COD_PRODUTO' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'DESCRICAO' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'NUM_ITEM' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'VLR_CONTABIL_ITEM' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'VLR_ITEM' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'VLR_BASE_ICMS_1' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'VLR_BASE_ICMS_2' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'VLR_BASE_ICMS_3' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'VLR_BASE_ICMS_4' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'VLR_IPI_NDESTAC' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'VLR_DESCONTO' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'ALIQ_TRIBUTO_ICMS' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'VLR_ICMS_ST' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'VLR_BASE_ST' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'VLR_ICMS_PROPRIO' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'CST' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'QUANTIDADE' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'NCM' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'MVA' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'PMC_PAUTA' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'TP_CALC' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'SIT_TRIB' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'PERC_RED_BSST' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'FINALIDADE' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'ALIQUOTA_INTERNA' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'VLR_UNIT_ITEM' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'ICMS_PROPRIO' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'BC_ICMS_ST' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'ICMS_ST' )
                                                  , p_class => 'h'
                               )
                             , ptipo => i );

                FOR cr_r IN ( SELECT cod_empresa
                                   , cod_estab
                                   , data_fiscal
                                   , num_docfis
                                   , num_controle_docto
                                   , num_autentic_nfe
                                   , cod_fis_jur
                                   , cpf_cgc
                                   , cod_docto
                                   , cod_modelo
                                   , cod_cfo
                                   , cod_produto
                                   , descricao
                                   , num_item
                                   , vlr_contabil_item
                                   , vlr_item
                                   , vlr_base_icms_1
                                   , vlr_base_icms_2
                                   , vlr_base_icms_3
                                   , vlr_base_icms_4
                                   , vlr_ipi_ndestac
                                   , vlr_desconto
                                   , aliq_tributo_icms
                                   , vlr_icms_st
                                   , vlr_base_st
                                   , vlr_icms_proprio
                                   , cst
                                   , quantidade
                                   , ncm
                                   , mva
                                   , pmc_pauta
                                   , tp_calc
                                   , sit_trib
                                   , perc_red_bsst
                                   , finalidade
                                   , aliquota_interna
                                   , vlr_unit_item
                                   , icms_proprio
                                   , bc_icms_st
                                   , icms_st
                                FROM msafi.dpsp_fin048_ret_nf_sai
                               WHERE cod_empresa = mcod_empresa
                                 AND cod_estab = cd.cod_estab
                                 AND data_fiscal BETWEEN pdt_ini AND pdt_fim ) LOOP
                    IF v_class = 'a' THEN
                        v_class := 'b';
                    ELSE
                        v_class := 'a';
                    END IF;

                    v_text01 :=
                        dsp_planilha.linha (
                                             p_conteudo =>    dsp_planilha.campo ( cr_r.cod_empresa )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.cod_estab )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.data_fiscal )
                                                           || --
                                                             dsp_planilha.campo (
                                                                                  dsp_planilha.texto (
                                                                                                       cr_r.num_docfis
                                                                                  )
                                                              )
                                                           || --
                                                             dsp_planilha.campo (
                                                                                  dsp_planilha.texto (
                                                                                                       cr_r.num_controle_docto
                                                                                  )
                                                              )
                                                           || --
                                                             dsp_planilha.campo (
                                                                                  dsp_planilha.texto (
                                                                                                       cr_r.num_autentic_nfe
                                                                                  )
                                                              )
                                                           || --
                                                             dsp_planilha.campo (
                                                                                  dsp_planilha.texto (
                                                                                                       cr_r.cod_fis_jur
                                                                                  )
                                                              )
                                                           || --
                                                             dsp_planilha.campo (
                                                                                  dsp_planilha.texto ( cr_r.cpf_cgc )
                                                              )
                                                           || --
                                                             dsp_planilha.campo (
                                                                                  dsp_planilha.texto (
                                                                                                       cr_r.cod_docto
                                                                                  )
                                                              )
                                                           || --
                                                             dsp_planilha.campo (
                                                                                  dsp_planilha.texto (
                                                                                                       cr_r.cod_modelo
                                                                                  )
                                                              )
                                                           || --
                                                             dsp_planilha.campo (
                                                                                  dsp_planilha.texto ( cr_r.cod_cfo )
                                                              )
                                                           || --
                                                             dsp_planilha.campo (
                                                                                  dsp_planilha.texto (
                                                                                                       cr_r.cod_produto
                                                                                  )
                                                              )
                                                           || --
                                                             dsp_planilha.campo (
                                                                                  dsp_planilha.texto (
                                                                                                       cr_r.descricao
                                                                                  )
                                                              )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.num_item )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.vlr_contabil_item )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.vlr_item )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.vlr_base_icms_1 )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.vlr_base_icms_2 )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.vlr_base_icms_3 )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.vlr_base_icms_4 )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.vlr_ipi_ndestac )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.vlr_desconto )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.aliq_tributo_icms )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.vlr_icms_st )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.vlr_base_st )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.vlr_icms_proprio )
                                                           || --
                                                             dsp_planilha.campo ( dsp_planilha.texto ( cr_r.cst ) )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.quantidade )
                                                           || --
                                                             dsp_planilha.campo ( dsp_planilha.texto ( cr_r.ncm ) )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.mva )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.pmc_pauta )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.tp_calc )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.sit_trib )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.perc_red_bsst )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.finalidade )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.aliquota_interna )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.vlr_unit_item )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.icms_proprio )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.bc_icms_st )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.icms_st )
                                           , p_class => v_class
                        );
                    lib_proc.add ( v_text01
                                 , ptipo => i );
                END LOOP;
            END LOOP;

            lib_proc.add ( dsp_planilha.tabela_fim
                         , ptipo => i );

            i := i + 1;

            --=================================================================================
            -- GERAR ARQUIVO SINTETICO
            --=================================================================================
            lib_proc.add_tipo ( mproc_id
                              , i
                              ,    TO_CHAR ( pdt_ini
                                           , 'YYYYMM' )
                                || '_Ret_ICMS_ES_Saidas_Sintetico.xls'
                              , 2 );
            lib_proc.add ( dsp_planilha.header
                         , ptipo => i );
            lib_proc.add ( dsp_planilha.tabela_inicio
                         , ptipo => i );

            FOR cd IN lista_cds LOOP
                lib_proc.add ( dsp_planilha.linha (
                                                    p_conteudo =>    dsp_planilha.campo ( 'PERIODO' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'VLR_TOTAL_ICMS_PROPRIO' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'VLR_TOTAL_ICMS_ST' )
                                                  , p_class => 'h'
                               )
                             , ptipo => i );

                FOR cr_r IN ( SELECT   TO_CHAR ( data_fiscal
                                               , 'MM/YYYY' )
                                           AS periodo
                                     , SUM ( icms_proprio ) AS vlr_total_icms_proprio
                                     , SUM ( icms_st ) AS vlr_total_icms_st
                                  FROM msafi.dpsp_fin048_ret_nf_sai
                                 WHERE cod_empresa = mcod_empresa
                                   AND cod_estab = cd.cod_estab
                                   AND data_fiscal BETWEEN pdt_ini AND pdt_fim
                              GROUP BY TO_CHAR ( data_fiscal
                                               , 'MM/YYYY' ) ) LOOP
                    IF v_class = 'a' THEN
                        v_class := 'b';
                    ELSE
                        v_class := 'a';
                    END IF;

                    v_text01 :=
                        dsp_planilha.linha (
                                             p_conteudo =>    dsp_planilha.campo ( cr_r.periodo )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.vlr_total_icms_proprio )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.vlr_total_icms_st )
                                           , p_class => v_class
                        );
                    lib_proc.add ( v_text01
                                 , ptipo => i );
                END LOOP;
            END LOOP;

            lib_proc.add ( dsp_planilha.tabela_fim
                         , ptipo => i );

            loga ( '---FIM DO PROCESSAMENTO [SUCESSO]---'
                 , FALSE );

            --=================================================================================
            -- FIM
            --=================================================================================
            --ENVIAR EMAIL DE SUCESSO----------------------------------------
            envia_email ( mcod_empresa
                        , v_data_inicial
                        , v_data_final
                        , ''
                        , 'S'
                        , v_data_hora_ini );

            -----------------------------------------------------------------
            IF v_existe_origem = 'N' THEN
                lib_proc.add ( 'Há CDs sem dados de origem.' );
                lib_proc.add ( ' ' );
            END IF;
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

        lib_proc.add ( 'Favor verificar LOG para detalhes.' );
        lib_proc.add ( ' ' );

        lib_proc.close;
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
    END;

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

            v_txt_email := 'ERRO no Relatório de Devolução de Mercadorias com ICMS-ST!';
            v_txt_email := v_txt_email || CHR ( 13 ) || '>> Parâmetros: ';
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Empresa : ' || vp_cod_empresa;
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Data Início : ' || vp_data_ini;
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Data Fim : ' || vp_data_fim;
            v_txt_email := v_txt_email || CHR ( 13 ) || '>> LOG: ';
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Executado por : ' || mnm_usuario;
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Hora Início : ' || vp_data_hora_ini;
            v_txt_email :=
                   v_txt_email
                || CHR ( 13 )
                || ' - Hora Término : '
                || TO_CHAR ( SYSDATE
                           , 'DD/MM/YYYY HH24:MI.SS' );
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Tempo Execução	: ' || v_tempo_exec;
            v_txt_email := v_txt_email || CHR ( 13 ) || '<< ERRO >> ' || vp_msg_oracle;
            v_assunto := 'Mastersaf - Relatório de Devolução de Mercadorias com ICMS-ST apresentou ERRO';
            notifica ( ''
                     , 'S'
                     , v_assunto
                     , v_txt_email
                     , 'DPSP_FIN048_RET_SAIDA_CPROC' );
        ELSE
            v_txt_email := 'Processo Relatório de Devolução de Mercadorias com ICMS-ST finalizado com SUCESSO.';
            v_txt_email := v_txt_email || CHR ( 13 ) || '>> Parâmetros: ';
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Empresa : ' || vp_cod_empresa;
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Data Início : ' || vp_data_ini;
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Data Fim : ' || vp_data_fim;
            v_txt_email := v_txt_email || CHR ( 13 ) || '>> LOG: ';
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Executado por : ' || mnm_usuario;
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Hora Início : ' || vp_data_hora_ini;
            v_txt_email :=
                   v_txt_email
                || CHR ( 13 )
                || ' - Hora Término : '
                || TO_CHAR ( SYSDATE
                           , 'DD/MM/YYYY HH24:MI.SS' );
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Tempo Execução : ' || v_tempo_exec;
            v_assunto := 'Mastersaf - Relatório de Devolução de Mercadorias com ICMS-ST Concluído';
            notifica ( 'S'
                     , ''
                     , v_assunto
                     , v_txt_email
                     , 'DPSP_FIN048_RET_SAIDA_CPROC' );
        END IF;
    END;
END dpsp_fin048_ret_saida_cproc;
/
SHOW ERRORS;
