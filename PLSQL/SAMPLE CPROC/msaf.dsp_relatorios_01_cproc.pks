Prompt Package DSP_RELATORIOS_01_CPROC;
--
-- DSP_RELATORIOS_01_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dsp_relatorios_01_cproc
IS
    /*Tabelas auxiliares - INICIO
    error(1): wrong syntax
    CREATE GLOBAL TEMPORARY TABLE MSAFI.DSP_REL_FIS_01_TMP01
    (COD_EMPRESA                    VARCHAR2(3)
    ,COD_ESTAB                      VARCHAR2(6)
    ,COD_CAIXA_ECF                  VARCHAR2(3)
    ,NUM_CRZ                        VARCHAR2(6)
    ,DATA_FISCAL                    DATE
    ,NUM_CRO                        VARCHAR2(6)
    ,NUM_COO_INI                    VARCHAR2(6)
    ,NUM_COO_FIM                    VARCHAR2(6)
    ,NUM_COO                        VARCHAR2(6)
    ,DATA_EMISSAO                   DATE
    ,HORA_EMISSAO_FIM               NUMBER
    )
    ON COMMIT PRESERVE ROWS
    ;

    CREATE INDEX DSP_REL_FIS_01_TMP01_IDX1 ON DSP_REL_FIS_01_TMP01
    (COD_EMPRESA,COD_ESTAB,COD_CAIXA_ECF,NUM_CRZ,DATA_FISCAL,NUM_CRO,NUM_COO_INI,NUM_COO_FIM);

    /*Tabelas auxiliares - FIM*/

    -- AUTOR    : DSP - LFM
    -- DATA     : 24/JUL/2012
    -- DESCRIÇÃO: Executador de relatórios

    mcod_empresa empresa.cod_empresa%TYPE;
    mcod_estab estabelecimento.cod_estab%TYPE;
    musuario usuario_empresa.cod_usuario%TYPE;

    mproc_id INTEGER;

    --Variaveis (aqui nao podem ser constantes) para as funções REGEXP_LIKE encontrarem DSP9xx, Depósitos, Lojas e Estabelecimentos
    c_proc_9xx VARCHAR2 ( 30 ); --C_PROC_9XX   := '^' || MCOD_EMPRESA || '9[0-9]{2}$';
    c_proc_dep VARCHAR2 ( 30 ); --C_PROC_DEP   := '^' || MCOD_EMPRESA || '9[0-9][1-9]$';
    c_proc_loj VARCHAR2 ( 30 ); --C_PROC_LOJ   := '^' || MCOD_EMPRESA || '[0-8][0-9]{' || TO_CHAR(5-LENGTH(MCOD_EMPRESA),'FM9') || '}$';
    c_proc_est VARCHAR2 ( 30 ); --C_PROC_EST   := '^' || MCOD_EMPRESA || '[0-9]{3,' || TO_CHAR(6-LENGTH(MCOD_EMPRESA),'FM9') || '}$';
    c_proc_estvd VARCHAR2 ( 30 ); --C_PROC_ESTVD := '^VD[0-9]{3,' || TO_CHAR(6-LENGTH(MCOD_EMPRESA),'FM9') || '}$';

    FUNCTION parametros
        RETURN VARCHAR2;

    FUNCTION nome
        RETURN VARCHAR2;

    FUNCTION tipo
        RETURN VARCHAR2;

    FUNCTION versao
        RETURN VARCHAR2;

    FUNCTION descricao
        RETURN VARCHAR2;

    FUNCTION modulo
        RETURN VARCHAR2;

    FUNCTION classificacao
        RETURN VARCHAR2;

    PROCEDURE loga ( p_i_texto IN VARCHAR2
                   , p_i_dttm IN BOOLEAN DEFAULT TRUE );

    FUNCTION moeda ( v_conteudo NUMBER )
        RETURN VARCHAR2;

    FUNCTION fazcampo ( p_i_campo IN VARCHAR2
                      , p_i_fill IN VARCHAR2
                      , p_i_size IN NUMBER )
        RETURN VARCHAR2;

    FUNCTION fazcampo ( p_i_campo IN NUMBER
                      , p_i_format IN VARCHAR2
                      , p_i_fill IN VARCHAR2
                      , p_i_size IN NUMBER )
        RETURN VARCHAR2;

    FUNCTION fazcampo ( p_i_campo IN DATE
                      , p_i_format IN VARCHAR2
                      , p_i_fill IN VARCHAR2
                      , p_i_size IN NUMBER )
        RETURN VARCHAR2;

    FUNCTION executar ( p_relatorio VARCHAR2
                      , p_data_ini DATE
                      , p_data_fim DATE
                      --                     , P_SEP        VARCHAR2
                      , p_exec_all VARCHAR2
                      , p_uf VARCHAR2
                      , p_codestab lib_proc.vartab )
        RETURN INTEGER;


    CURSOR c_estabs
    IS
        SELECT   cod_estab
               , TO_NUMBER ( REPLACE ( cod_estab
                                     , mcod_empresa
                                     , '' ) )
                     AS codigo_loja
            FROM msafi.dsp_proc_estabs
        ORDER BY 1;

    CURSOR c_datas ( p_data_ini DATE
                   , p_data_fim DATE )
    IS
        SELECT     p_data_ini + ROWNUM - 1 AS data_normal
                 , TO_CHAR ( ( p_data_ini + ROWNUM - 1 )
                           , 'YYYYMMDD' )
                       AS data_safx
              FROM DUAL
        CONNECT BY LEVEL <= ( p_data_fim - p_data_ini ) + 1
          ORDER BY 1;

    --------------------------------------------------------------------------------------------------------------
    -- RELATORIO: UNION SELECT ''001'',''001 - Cupom - Incoerência de datas entre X991 e X993/X994'' FROM DUAL
    CURSOR c_relatorio_01
    IS
        SELECT   cod_empresa
               , cod_estab
               , cod_caixa_ecf
               , num_crz
               , data_fiscal
               , num_cro
               , num_coo_ini
               , num_coo_fim
               , MIN ( num_coo ) menor_num_cupom
               , MAX ( num_coo ) maior_num_cupom
               , MIN ( data_emissao ) menor_data_cupom
               , MAX ( data_emissao ) maior_data_cupom
               , COUNT ( 0 ) num_cupons
            FROM msafi.dsp_rel_fis_01_tmp01
        GROUP BY cod_empresa
               , cod_estab
               , cod_caixa_ecf
               , num_crz
               , data_fiscal
               , num_cro
               , num_coo_ini
               , num_coo_fim
        ORDER BY cod_empresa
               , cod_estab
               , cod_caixa_ecf
               , num_crz
               , data_fiscal
               , num_cro
               , num_coo_ini
               , num_coo_fim;

    --------------------------------------------------------------------------------------------------------------
    -- RELATORIO: UNION SELECT ''004'',''004 - Divergência de Devolução das lojas para CDs'' FROM DUAL
    CURSOR c_relatorio_004 ( p_i_cod_empresa IN VARCHAR2
                           , p_i_data_ini IN DATE
                           , p_i_data_fim IN DATE )
    IS
        SELECT   e.cod_estab
               , s.data_fiscal
               , e.num_docfis
               , e.cod_fis_jur
               , e.vlr_contab_item vlr_contab_1209
               , s.vlr_contab_item vlr_contab_5209
               , e.vlr_base_icms_1 base_trib_1209
               , s.vlr_base_icms_1 base_trib_5209
               , e.vlr_base_icms_2 base_isen_1209
               , s.vlr_base_icms_2 base_isen_5209
               , e.vlr_base_icms_3 base_outras_1209
               , s.vlr_base_icms_3 base_outras_5209
               , e.num_linhas linhas_entrada
               , s.num_linhas linhas_saida
               , s.cod_estab cod_estab_saida
               , s.num_controle_docto num_controle_docto_saida
            FROM (SELECT   ddf.cod_estab
                         , ddf.data_emissao
                         , ddf.num_docfis
                         , ddf.num_controle_docto
                         , ddf.serie_docfis
                         , x04.cod_fis_jur
                         , SUM ( dim.vlr_contab_item ) vlr_contab_item
                         , SUM ( dim.vlr_base_icms_1 ) vlr_base_icms_1
                         , SUM ( dim.vlr_base_icms_2 ) vlr_base_icms_2
                         , SUM ( dim.vlr_base_icms_3 ) vlr_base_icms_3
                         , COUNT ( 0 ) num_linhas
                      FROM dwt_docto_fiscal ddf
                         , dwt_itens_merc dim
                         , x2012_cod_fiscal x12
                         , x04_pessoa_fis_jur x04
                     WHERE ddf.cod_empresa = p_i_cod_empresa
                       AND ddf.cod_estab LIKE mcod_empresa || '9%'
                       AND ddf.data_fiscal BETWEEN p_i_data_ini AND p_i_data_fim
                       AND ddf.movto_e_s <> '9'
                       AND dim.ident_docto_fiscal = ddf.ident_docto_fiscal
                       AND x12.ident_cfo = dim.ident_cfo
                       AND x12.cod_cfo IN ( '1209'
                                          , '2209' )
                       AND x04.ident_fis_jur = dim.ident_fis_jur
                       AND x04.cod_fis_jur NOT LIKE mcod_empresa || '9%'
                  GROUP BY ddf.cod_estab
                         , ddf.data_emissao
                         , ddf.num_docfis
                         , ddf.num_controle_docto
                         , ddf.serie_docfis
                         , x04.cod_fis_jur) e
               , (SELECT   ddf.cod_estab
                         , ddf.data_fiscal
                         , ddf.num_docfis
                         , ddf.num_controle_docto
                         , ddf.serie_docfis
                         , x04.cod_fis_jur
                         , SUM ( dim.vlr_contab_item ) vlr_contab_item
                         , SUM ( dim.vlr_base_icms_1 ) vlr_base_icms_1
                         , SUM ( dim.vlr_base_icms_2 ) vlr_base_icms_2
                         , SUM ( dim.vlr_base_icms_3 ) vlr_base_icms_3
                         , COUNT ( 0 ) num_linhas
                      FROM dwt_docto_fiscal ddf
                         , dwt_itens_merc dim
                         , x2012_cod_fiscal x12
                         , x04_pessoa_fis_jur x04
                     WHERE ddf.cod_empresa = p_i_cod_empresa
                       AND ddf.cod_estab NOT LIKE mcod_empresa || '9%'
                       AND ddf.data_fiscal BETWEEN p_i_data_ini AND p_i_data_fim
                       AND ddf.movto_e_s = '9'
                       AND dim.ident_docto_fiscal = ddf.ident_docto_fiscal
                       AND x12.ident_cfo = dim.ident_cfo
                       AND x12.cod_cfo IN ( '5209'
                                          , '6209' )
                       AND x04.ident_fis_jur = dim.ident_fis_jur
                       AND x04.cod_fis_jur LIKE mcod_empresa || '9%'
                  GROUP BY ddf.cod_estab
                         , ddf.data_fiscal
                         , ddf.num_docfis
                         , ddf.num_controle_docto
                         , ddf.serie_docfis
                         , x04.cod_fis_jur) s
           WHERE e.cod_estab = s.cod_fis_jur
             AND s.cod_estab = e.cod_fis_jur
             AND e.data_emissao <= s.data_fiscal
             AND e.num_docfis = s.num_docfis
             AND e.serie_docfis = s.serie_docfis
             AND ( e.vlr_contab_item <> s.vlr_contab_item
               OR e.num_linhas <> s.num_linhas--OR E.VLR_BASE_ICMS_1 <> S.VLR_BASE_ICMS_1
                                              --OR E.VLR_BASE_ICMS_2 <> S.VLR_BASE_ICMS_2
                                              --OR E.VLR_BASE_ICMS_3 <> S.VLR_BASE_ICMS_3
                                               )
        ORDER BY 1
               , 2
               , 3
               , 4;

    --------------------------------------------------------------------------------------------------------------
    -- RELATORIO: UNION SELECT ''005'',''005 - NFs potencialmente problematicas'' FROM DUAL
    CURSOR c_relatorio_005 ( p_data_ini DATE
                           , p_data_fim DATE )
    IS
        SELECT ( SELECT cod_modelo
                   FROM x2024_modelo_docto x
                  WHERE x.ident_modelo = a.ident_modelo )
                   cod_modelo
             , ( SELECT cod_docto
                   FROM x2005_tipo_docto x
                  WHERE x.ident_docto = a.ident_docto )
                   cod_docto
             , a.cod_class_doc_fis
             , ( SELECT cod_cfo
                   FROM x2012_cod_fiscal x
                  WHERE x.ident_cfo = a.ident_cfo )
                   cod_cfo
             , ( SELECT COUNT ( 0 )
                   FROM dwt_itens_merc b
                  WHERE b.ident_docto_fiscal = a.ident_docto_fiscal )
                   num_linhas
             , ( SELECT COUNT ( 0 )
                   FROM dwt_itens_merc b
                  WHERE b.ident_docto_fiscal = a.ident_docto_fiscal
                    AND b.ident_cfo IS NULL )
                   total_item_sem_cfop
             , ( SELECT MIN ( num_item )
                   FROM dwt_itens_merc b
                  WHERE b.ident_docto_fiscal = a.ident_docto_fiscal
                    AND b.ident_cfo IS NULL )
                   menor_item_sem_cfop
             , ( SELECT MAX ( num_item )
                   FROM dwt_itens_merc b
                  WHERE b.ident_docto_fiscal = a.ident_docto_fiscal
                    AND b.ident_cfo IS NULL )
                   maior_item_sem_cfop
             , ( SELECT cod_fis_jur
                   FROM x04_pessoa_fis_jur x
                  WHERE x.ident_fis_jur = a.ident_fis_jur )
                   cod_fis_jur
             , a.cod_estab
             , a.data_fiscal
             , a.num_docfis
          FROM dwt_docto_fiscal a
         WHERE cod_empresa = 'DSP'
           AND data_fiscal BETWEEN p_data_ini AND p_data_fim
           AND ( ident_modelo NOT IN ( SELECT ident_modelo
                                         FROM x2024_modelo_docto
                                        WHERE cod_modelo IN ( '01'
                                                            , '06'
                                                            , '21'
                                                            , '22'
                                                            , '2D'
                                                            , '38'
                                                            , '55' ) )
             OR ident_docto NOT IN ( SELECT ident_docto
                                       FROM x2005_tipo_docto
                                      WHERE cod_docto IN ( 'NFFST'
                                                         , 'NFSC'
                                                         , 'NF'
                                                         , 'CF'
                                                         , 'NFEE'
                                                         , 'NFF'
                                                         , 'NFE'
                                                         , 'NFS' ) )
             OR cod_class_doc_fis <> 1
             OR ident_cfo IS NOT NULL
             OR NOT EXISTS
                    (SELECT 1
                       FROM dwt_itens_merc b
                      WHERE b.ident_docto_fiscal = a.ident_docto_fiscal)
             OR EXISTS
                    (SELECT 1
                       FROM dwt_itens_merc b
                      WHERE b.ident_docto_fiscal = a.ident_docto_fiscal
                        AND b.ident_cfo IS NULL) );

    --------------------------------------------------------------------------------------------------------------
    -- RELATORIO: UNION SELECT ''006'',''006 - NFs alteradas fora de periodo no PS'' FROM DUAL
    CURSOR c_relatorio_006 (
        p_i_data_ini DATE
      , p_i_data_fim DATE
    )
    IS
        --    SELECT COD_ESTAB,MIN(DATA_FISCAL) MIN_DATA_FISCAL,MAX(DATA_FISCAL) MAX_DATA_FISCAL ,MIN(DATA_ALTERACAO) MIN_DATA_ALTERACAO,MAX(DATA_ALTERACAO) MAX_DATA_ALTERACAO
        --          ,SUM(CASE WHEN CANCELADA_S_N = 'N' THEN 1 ELSE 0 END) SUM_NAO_CANC
        --          ,SUM(CASE WHEN CANCELADA_S_N = 'S' THEN 1 ELSE 0 END) SUM_CANC
        --    FROM (
        SELECT   nfh.ef_loc_brl cod_estab
               , CASE
                     WHEN nfh.lt_grp_id_bbl IN ( 'TRO_LIB_23'
                                               , 'TRO_DIA_23' ) THEN
                         nfh.entered_dt
                     WHEN nfh.lt_grp_id_bbl IN ( 'EST_LIB_14'
                                               , 'EST_LIB_4'
                                               , 'EST_DIA_23'
                                               , 'EST_DIA_2'
                                               , 'EST_LIB_23'
                                               , 'EST_LIB_3' ) THEN
                         NVL ( nfh.nf_conf_dt_bbl, nfh.nf_issue_dt_bbl )
                     ELSE
                         nfh.nf_issue_dt_bbl
                 END
                     data_fiscal
               , nfh.last_update_dt data_alteracao
               , nfh.nf_brl num_docfis
               , CASE
                     WHEN NVL ( LTRIM ( TRIM ( nfh.nf_brl_series )
                                      , '0' )
                              , '0' ) IN ( '0'
                                         , 'M1'
                                         , 'UN' ) THEN
                         '@'
                     ELSE
                         TRIM ( nfh.nf_brl_series )
                 END
                     serie_docfis
               , CASE
                     WHEN nfh.ship_to_cust_id = 'AR000000098' THEN
                         CASE
                             WHEN LTRIM ( TRIM ( REPLACE ( REPLACE ( REPLACE ( NVL ( TRIM ( dsl.cgc_brl ), dsl.cpf_brl )
                                                                             , '.'
                                                                             , '' )
                                                                   , '-'
                                                                   , '' )
                                                         , '/'
                                                         , '' ) )
                                        , '0' )
                                      IS NULL THEN
                                 nfh.ef_loc_brl --se nao temos o numero do CPF do cliente, preenchemos o cod_fis_jur com o cod_estab
                             ELSE
                                 TRIM (
                                        SUBSTR (
                                                    'CF'
                                                 || REPLACE (
                                                              REPLACE (
                                                                        REPLACE (
                                                                                  NVL ( TRIM ( dsl.cgc_brl )
                                                                                      , dsl.cpf_brl )
                                                                                , '.'
                                                                                , ''
                                                                        )
                                                                      , '-'
                                                                      , ''
                                                              )
                                                            , '/'
                                                            , ''
                                                    )
                                               , 1
                                               , 14
                                        )
                                 )
                         END
                     WHEN ( NOT REGEXP_LIKE (
                                              NVL ( NVL ( TRIM ( nfh.ship_to_cust_id ), TRIM ( nfh.destin_bu ) )
                                                  , TRIM ( nfh.location ) )
                                            , c_proc_est
                                ) )
                      AND ( NOT REGEXP_LIKE (
                                              NVL ( NVL ( TRIM ( nfh.ship_to_cust_id ), TRIM ( nfh.destin_bu ) )
                                                  , TRIM ( nfh.location ) )
                                            , c_proc_estvd
                                ) ) THEN
                            SUBSTR (
                                     NVL ( NVL ( TRIM ( nfh.ship_to_cust_id ), TRIM ( nfh.destin_bu ) )
                                         , TRIM ( nfh.location ) )
                                   , 1
                                   , 14
                            )
                         || '-'
                         || nfh.address_seq_ship
                     ELSE
                         REPLACE (
                                   NVL ( NVL ( TRIM ( nfh.ship_to_cust_id ), TRIM ( nfh.destin_bu ) )
                                       , TRIM ( nfh.location ) )
                                 , 'VD'
                                 , mcod_empresa
                         )
                 END
                     cod_fis_jur
               , DECODE ( nfh.nf_status_bbl, 'CNCL', 'S', 'N' ) cancelada_s_n
               , nfh.gross_amt_bse x07_vlr_tot_nota
               , nfh.business_unit business_unit
               , nfh.nf_brl_id nf_brl_id
               , nfh.nf_status_bbl nf_status_bbl
            FROM msafi.ps_nf_hdr_bbl_fs nfh
               , msafi.ps_dsp_sol_nfe_hdr dsh
               , msafi.ps_dsp_sol_nfe_adr dsl
           WHERE nfh.inout_flg_pbl = 'O'
             AND nfh.nf_status_bbl IN ( 'CNFM'
                                      , 'CNCL'
                                      , 'PRNT' )
             AND nfh.last_update_dt BETWEEN p_i_data_ini AND p_i_data_fim
             AND ( ( nfh.lt_grp_id_bbl IN ( 'TRO_LIB_23'
                                          , 'TRO_DIA_23' )
                AND TO_CHAR ( nfh.entered_dt
                            , 'YYYYMM' ) <> TO_CHAR ( nfh.last_update_dt
                                                    , 'YYYYMM' ) )
               OR ( nfh.lt_grp_id_bbl IN ( 'EST_LIB_14'
                                         , 'EST_LIB_4'
                                         , 'EST_DIA_23'
                                         , 'EST_DIA_2'
                                         , 'EST_LIB_23'
                                         , 'EST_LIB_3' )
               AND TO_CHAR ( NVL ( nfh.nf_conf_dt_bbl, nfh.nf_issue_dt_bbl )
                           , 'YYYYMM' ) <> TO_CHAR ( nfh.last_update_dt
                                                   , 'YYYYMM' ) )
               OR ( nfh.lt_grp_id_bbl NOT IN ( 'TRO_LIB_23'
                                             , 'TRO_DIA_23'
                                             , 'EST_LIB_14'
                                             , 'EST_LIB_4'
                                             , 'EST_DIA_23'
                                             , 'EST_DIA_2'
                                             , 'EST_LIB_23'
                                             , 'EST_LIB_3' )
               AND TO_CHAR ( nfh.nf_issue_dt_bbl
                           , 'YYYYMM' ) <> TO_CHAR ( nfh.last_update_dt
                                                   , 'YYYYMM' ) ) )
             ---PS_DSP_SOL_NFE_HDR DSH, PS_DSP_SOL_NFE_ADR DSL,
             AND dsh.business_unit(+) = nfh.business_unit
             AND dsh.nf_brl_id(+) = nfh.nf_brl_id
             AND dsh.dsp_tipo_oper(+) = 'V_AVISTA'
             AND dsl.business_unit(+) = dsh.business_unit
             AND dsl.dsp_nfe_id(+) = dsh.dsp_nfe_id
        ORDER BY nfh.last_update_dt DESC
               , nfh.ef_loc_brl DESC
               , nfh.nf_brl--    )
                           --    GROUP BY COD_ESTAB
                           --    ORDER BY COD_ESTAB DESC
                           ;

    --------------------------------------------------------------------------------------------------------------
    -- RELATORIO: UNION SELECT ''007'',''007 - Validação de Chave de Acesso'' FROM DUAL
    CURSOR c_relatorio_007 (
        p_i_data_ini IN DATE
      , p_i_data_fim IN DATE
      , p_i_todas IN CHAR
    )
    IS
        SELECT *
          FROM ( SELECT ddf.cod_estab
                      , ddf.data_fiscal
                      , ufe.cod_estado
                      , ddf.movto_e_s
                      , ddf.num_docfis
                      , ddf.serie_docfis
                      , x04.cod_fis_jur forne_cliente
                      , ufx.cod_estado uf_fisjur
                      , ddf.num_controle_docto
                      , CASE
                            WHEN TRIM ( ddf.num_autentic_nfe ) IS NULL THEN
                                '(BRANCO)'
                            WHEN LENGTH ( ddf.num_autentic_nfe ) = 44
                             AND ( -- CH000001 >>
                                   ( SUBSTR ( ddf.num_autentic_nfe
                                            , 1
                                            , 2 ) =
                                        ( SELECT cod_ibge
                                            FROM msafi.dsp_estado_ibge dei
                                           WHERE dei.cod_estado =
                                                     DECODE ( ddf.movto_e_s, '9', ufe.cod_estado, ufx.cod_estado ) )
                                AND ddf.norm_dev = '1' )
                               OR ( ( SUBSTR ( ddf.num_autentic_nfe
                                             , 1
                                             , 2 ) IN ( SELECT cod_ibge
                                                          FROM msafi.dsp_estado_ibge dei
                                                         WHERE dei.cod_estado IN ( ufe.cod_estado
                                                                                 , ufx.cod_estado ) )
                                 AND ddf.norm_dev = '2' ) ) ) -- CH0000001 <<
                             AND SUBSTR ( ddf.num_autentic_nfe
                                        , 3
                                        , 4 ) = TO_CHAR ( ddf.data_emissao
                                                        , 'YYMM' )
                             AND SUBSTR ( ddf.num_autentic_nfe
                                        , 7
                                        , 14 ) = DECODE ( ddf.movto_e_s, '9', est.cgc, x04.cpf_cgc )
                             AND SUBSTR ( ddf.num_autentic_nfe
                                        , 21
                                        , 2 ) = xmd.cod_modelo
                             AND SUBSTR ( ddf.num_autentic_nfe
                                        , 23
                                        , 3 ) = LPAD ( NVL ( TRIM ( ddf.serie_docfis ), '0' )
                                                     , 3
                                                     , '0' )
                             AND SUBSTR ( ddf.num_autentic_nfe
                                        , 26
                                        , 9 ) = LPAD ( TRIM ( ddf.num_docfis )
                                                     , 9
                                                     , '0' )
                             --                 AND SUBSTR(DDF.NUM_AUTENTIC_NFE,35, 1) = tpEmis – forma de emissão da NF-e
                             --                 AND SUBSTR(DDF.NUM_AUTENTIC_NFE,36, 8) = cNF - Código Numérico que compõe a Chave de Acesso
                             AND SUBSTR ( ddf.num_autentic_nfe
                                        , 44
                                        , 1 ) = msafi.dsp_dv_modulo11 ( SUBSTR ( ddf.num_autentic_nfe
                                                                               , 1
                                                                               , 43 ) ) THEN
                                'OK'
                            ELSE
                                   'Inv('
                                || CASE WHEN LENGTH ( ddf.num_autentic_nfe ) <> 44 THEN 'TM/' END
                                -- || CASE WHEN SUBSTR(DDF.NUM_AUTENTIC_NFE, 1, 2) <> (SELECT COD_IBGE FROM MSAFI.DSP_ESTADO_IBGE DEI WHERE DEI.COD_ESTADO = DECODE(DDF.MOVTO_E_S,'9',UFE.COD_ESTADO,UFX.COD_ESTADO)) THEN 'UF/' END
                                || CASE
                                       WHEN NOT ( -- CH000001 >>
                                                  ( SUBSTR ( ddf.num_autentic_nfe
                                                           , 1
                                                           , 2 ) =
                                                       ( SELECT cod_ibge
                                                           FROM msafi.dsp_estado_ibge dei
                                                          WHERE dei.cod_estado =
                                                                    DECODE ( ddf.movto_e_s
                                                                           , '9', ufe.cod_estado
                                                                           , ufx.cod_estado ) )
                                               AND ddf.norm_dev = '1' )
                                              OR ( ( SUBSTR ( ddf.num_autentic_nfe
                                                            , 1
                                                            , 2 ) IN ( SELECT cod_ibge
                                                                         FROM msafi.dsp_estado_ibge dei
                                                                        WHERE dei.cod_estado IN ( ufe.cod_estado
                                                                                                , ufx.cod_estado ) )
                                                AND ddf.norm_dev = '2' ) ) ) THEN
                                           'UF/'
                                   END -- CH0000001 <<
                                || CASE
                                       WHEN SUBSTR ( ddf.num_autentic_nfe
                                                   , 3
                                                   , 4 ) <> TO_CHAR ( ddf.data_emissao
                                                                    , 'YYMM' ) THEN
                                           'DT/'
                                   END
                                || CASE
                                       WHEN SUBSTR ( ddf.num_autentic_nfe
                                                   , 7
                                                   , 14 ) <> DECODE ( ddf.movto_e_s, '9', est.cgc, x04.cpf_cgc ) THEN
                                           'CJ/'
                                   END
                                || CASE
                                       WHEN SUBSTR ( ddf.num_autentic_nfe
                                                   , 21
                                                   , 2 ) <> xmd.cod_modelo THEN
                                           'MD/'
                                   END
                                || CASE
                                       WHEN SUBSTR ( ddf.num_autentic_nfe
                                                   , 23
                                                   , 3 ) <> LPAD ( NVL ( TRIM ( ddf.serie_docfis ), '0' )
                                                                 , 3
                                                                 , '0' ) THEN
                                           'SR/'
                                   END
                                || CASE
                                       WHEN SUBSTR ( ddf.num_autentic_nfe
                                                   , 26
                                                   , 9 ) <> LPAD ( TRIM ( ddf.num_docfis )
                                                                 , 9
                                                                 , '0' ) THEN
                                           'NM/'
                                   END
                                --                        WHEN SUBSTR(DDF.NUM_AUTENTIC_NFE,35, 1) <> tpEmis – forma de emissão da NF-e
                                --                        WHEN SUBSTR(DDF.NUM_AUTENTIC_NFE,36, 8) <> cNF - Código Numérico que compõe a Chave de Acesso
                                || CASE
                                       WHEN SUBSTR ( ddf.num_autentic_nfe
                                                   , 44
                                                   , 1 ) <> msafi.dsp_dv_modulo11 ( SUBSTR ( ddf.num_autentic_nfe
                                                                                           , 1
                                                                                           , 43 ) ) THEN
                                           'DV/'
                                   END
                        END
                            AS chave_acesso_ok
                      , NVL ( TRIM ( ddf.num_autentic_nfe ), '(vazio)' ) AS chave_de_acesso
                   FROM dwt_docto_fiscal ddf
                      , estabelecimento est
                      , estado ufe
                      , x04_pessoa_fis_jur x04
                      , estado ufx
                      , x2024_modelo_docto xmd
                  WHERE ddf.cod_empresa = mcod_empresa
                    AND ( p_i_todas <> 'N'
                      OR ddf.cod_estab IN ( SELECT cod_estab
                                              FROM msafi.dsp_proc_estabs ) )
                    AND ddf.data_fiscal BETWEEN p_i_data_ini AND p_i_data_fim
                    --,ESTABELECIMENTO      EST
                    AND est.cod_empresa = ddf.cod_empresa
                    AND est.cod_estab = ddf.cod_estab
                    --,ESTADO               UFE
                    AND ufe.ident_estado = est.ident_estado
                    --,X04_PESSOA_FIS_JUR   X04
                    AND x04.ident_fis_jur = ddf.ident_fis_jur
                    --,ESTADO               UFX
                    AND ufx.ident_estado = x04.ident_estado
                    --,X2024_MODELO_DOCTO   XMD
                    AND xmd.ident_modelo = ddf.ident_modelo
                    AND xmd.cod_modelo = '55' )
         --Chave de acesso inválida
         WHERE chave_acesso_ok <> 'OK';

    --------------------------------------------------------------------------------------------------------------
    -- RELATORIO: UNION SELECT ''008'',''008 - Relatório de diferenças de ICMS x alíquota'' FROM DUAL
    CURSOR c_relatorio_008 ( p_i_data_ini IN DATE
                           , p_i_data_fim IN DATE
                           , p_i_todas IN CHAR )
    IS
        SELECT h.cod_empresa
             , h.cod_estab
             , h.data_fiscal
             , h.movto_e_s
             , h.norm_dev
             , h.num_docfis
             , h.serie_docfis
             , x2012.cod_cfo
             , x04.cod_fis_jur
             , x04.razao_social
             , h.vlr_tot_nota
             , h.num_controle_docto
             , l.vlr_contab_item
             , l.vlr_tributo_icms
             , l.aliq_tributo_icms
             , l.vlr_base_icms_1
             , l.vlr_base_icms_2
             , l.vlr_base_icms_3
             , l.vlr_base_icms_4
          FROM msaf.dwt_docto_fiscal h
             , msaf.dwt_itens_merc l
             , msaf.x04_pessoa_fis_jur x04
             , msaf.x2012_cod_fiscal x2012
         WHERE h.cod_empresa = mcod_empresa
           AND ( p_i_todas <> 'N'
             OR h.cod_estab IN ( SELECT cod_estab
                                   FROM msafi.dsp_proc_estabs ) )
           AND h.data_fiscal BETWEEN p_i_data_ini AND p_i_data_fim
           AND h.serie_docfis <> 'ECF'
           AND l.ident_docto_fiscal = h.ident_docto_fiscal
           AND x04.ident_fis_jur = h.ident_fis_jur
           AND l.ident_cfo = x2012.ident_cfo
           AND h.movto_e_s = '9'
           AND ROUND ( l.vlr_base_icms_1 * ( l.aliq_tributo_icms / 100 )
                     , 2 ) <> l.vlr_tributo_icms
           AND l.vlr_base_icms_1 > '0'--ORDER BY  H.COD_EMPRESA,H.COD_ESTAB,H.DATA_FISCAL,H.NUM_DOCFIS, L.ALIQ_TRIBUTO_ICMS
                                      ;

    --------------------------------------------------------------------------------------------------------------
    -- RELATORIO: SELECT ''010'',''010 - Relatório por Finalidade IST - Depósitos'' FROM DUAL
    CURSOR c_relatorio_010 ( p_i_data_ini IN DATE
                           , p_i_data_fim IN DATE
                           , p_i_todas IN CHAR )
    IS
        SELECT   a.cod_estab
               , a.data_fiscal
               , a.num_docfis numero_nf
               , a.movto_e_s saida_entrada
               , c.cod_cfo cfop
               , d.cod_produto produto
               , e.cod_nbm nbm
               , f.cod_natureza_op finalidade
               , SUM ( b.vlr_base_icms_1 ) base_tributada
               , b.aliq_tributo_icms
               , SUM ( b.vlr_tributo_icms ) valor_icms
            FROM msaf.dwt_docto_fiscal a
               , msaf.dwt_itens_merc b
               , msaf.x2012_cod_fiscal c
               , msaf.x2013_produto d
               , msaf.x2043_cod_nbm e
               , msaf.x2006_natureza_op f
           WHERE a.ident_docto_fiscal = b.ident_docto_fiscal
             AND b.ident_cfo = c.ident_cfo
             AND b.ident_produto = d.ident_produto
             AND b.ident_nbm = e.ident_nbm
             AND b.ident_natureza_op = f.ident_natureza_op
             AND a.cod_empresa = mcod_empresa
             AND a.cod_estab LIKE 'DSP9%'
             AND ( p_i_todas <> 'N'
               OR a.cod_estab IN ( SELECT cod_estab
                                     FROM msafi.dsp_proc_estabs
                                    WHERE cod_estab LIKE 'DSP9%' ) )
             AND a.data_fiscal BETWEEN p_i_data_ini AND p_i_data_fim
             AND c.cod_cfo = '6202'
             AND a.movto_e_s = '9'
             AND f.cod_natureza_op = 'IST'
             AND b.vlr_base_icms_1 > 0
        GROUP BY a.cod_estab
               , a.data_fiscal
               , a.num_docfis
               , a.movto_e_s
               , c.cod_cfo
               , d.cod_produto
               , e.cod_nbm
               , f.cod_natureza_op
               , b.aliq_tributo_icms
        ORDER BY 1
               , 2
               , 3;

    --------------------------------------------------------------------------------------------------------------
    -- RELATORIO: SELECT ''011'',''011 - Relatório Controle de Apuração de ICMS'' FROM DUAL
    CURSOR c_relatorio_011 ( p_i_data_ini IN DATE
                           , p_i_data_fim IN DATE
                           , p_i_todas IN CHAR )
    IS
        SELECT   a.cod_estab estabelecimento
               , a.val_apuracao saldo_period_ant
               , b.val_apuracao cred_imposto
               , SUM ( c.val_item_discrim ) outros_creditos
               , SUM ( e.val_apuracao ) estorno_debito
               , SUM ( f.val_apuracao ) deducoes
               , d.val_apuracao total_credito
               , g.val_apuracao debito_imposto
               , SUM ( h.val_apuracao ) outros_debitos
               , SUM ( i.val_item_discrim ) estorno_credito
               , j.val_apuracao total_debito
               , d.val_apuracao - j.val_apuracao saldo_period_cred_deb
            FROM msaf.item_apurac_calc a
               , msaf.item_apurac_calc b
               , msaf.item_apurac_discr c
               , msaf.item_apurac_calc e
               , msaf.item_apurac_calc f
               , msaf.item_apurac_calc d
               , msaf.item_apurac_calc g
               , msaf.item_apurac_calc h
               , msaf.item_apurac_discr i
               , msaf.item_apurac_calc j
           WHERE ( p_i_todas <> 'N'
               OR a.cod_estab IN ( SELECT cod_estab
                                     FROM msafi.dsp_proc_estabs ) )
             AND a.dat_apuracao BETWEEN p_i_data_ini AND p_i_data_fim
             AND a.cod_oper_apur = '009'
             AND a.cod_estab = b.cod_estab(+)
             AND a.dat_apuracao = b.dat_apuracao(+)
             AND b.cod_oper_apur(+) = '005'
             AND a.cod_estab = c.cod_estab(+)
             AND a.dat_apuracao = c.dat_apuracao(+)
             AND c.cod_oper_apur(+) = '006'
             AND a.cod_estab = e.cod_estab(+)
             AND a.dat_apuracao = e.dat_apuracao(+)
             AND e.cod_oper_apur(+) = '007'
             AND a.cod_estab = f.cod_estab(+)
             AND a.dat_apuracao = f.dat_apuracao(+)
             AND f.cod_oper_apur(+) = '012'
             AND a.cod_estab = d.cod_estab(+)
             AND a.dat_apuracao = d.dat_apuracao(+)
             AND d.cod_oper_apur(+) = '010'
             AND a.cod_estab = g.cod_estab(+)
             AND a.dat_apuracao = g.dat_apuracao(+)
             AND g.cod_oper_apur(+) = '001'
             AND a.cod_estab = h.cod_estab(+)
             AND a.dat_apuracao = h.dat_apuracao(+)
             AND h.cod_oper_apur(+) = '002'
             AND a.cod_estab = i.cod_estab(+)
             AND a.dat_apuracao = i.dat_apuracao(+)
             AND i.cod_oper_apur(+) = '003'
             AND a.cod_estab = j.cod_estab(+)
             AND a.dat_apuracao = j.dat_apuracao(+)
             AND j.cod_oper_apur(+) = '004'
        GROUP BY a.cod_estab
               , b.val_apuracao
               , a.val_apuracao
               , j.val_apuracao
               , g.val_apuracao
               , d.val_apuracao
        ORDER BY 1;

    --------------------------------------------------------------------------------------------------------------
    --012 - Notas Fiscais de Entrada Duplicadas
    CURSOR c_relatorio_012_all ( p_i_data_ini IN DATE
                               , p_i_data_fim IN DATE )
    IS
        SELECT a.cod_estab
             , b.cod_estab AS cod_estab_b
             , a.num_docfis
             , a.serie_docfis
             , x04a.cpf_cgc
             , a.data_fiscal data_fiscal_a
             , x04a.cod_fis_jur cod_fis_jur_a
             , SUBSTR ( x04a.razao_social
                      , 1
                      , 14 )
                   razao_social_a
             , a.vlr_tot_nota vlr_tot_nota_a
             , b.data_fiscal data_fiscal_b
             , x04b.cod_fis_jur cod_fis_jur_b
             , SUBSTR ( x04b.razao_social
                      , 1
                      , 14 )
                   razao_social_b
             , b.vlr_tot_nota vlr_tot_nota_b
             , a.ident_docto_fiscal ident_docto_fiscal_a
             , b.ident_docto_fiscal ident_docto_fiscal_b
             , a.num_autentic_nfe chave_acesso_a
          FROM msaf.dwt_docto_fiscal a
             , msaf.x04_pessoa_fis_jur x04a
             , msaf.dwt_docto_fiscal b
             , msaf.x04_pessoa_fis_jur x04b
         WHERE a.cod_empresa = mcod_empresa
           AND a.data_fiscal BETWEEN p_i_data_ini AND p_i_data_fim
           AND a.movto_e_s <> '9'
           AND b.cod_empresa = a.cod_empresa
           --AND B.COD_ESTAB           = A.COD_ESTAB     estroncho!
           AND b.movto_e_s <> '9'
           --AND B.DATA_FISCAL         BETWEEN P_I_DATA_INI AND P_I_DATA_FIM
           AND x04a.ident_fis_jur = a.ident_fis_jur
           AND x04b.ident_fis_jur = b.ident_fis_jur
           AND x04a.cpf_cgc = x04b.cpf_cgc
           AND b.num_docfis = a.num_docfis
           AND b.serie_docfis = a.serie_docfis
           AND b.ident_docto_fiscal <> a.ident_docto_fiscal;

    --------------------------------------------------------------------------------------------------------------
    --012 - Notas Fiscais de Entrada Duplicadas
    CURSOR c_relatorio_012_estab ( p_i_data_ini IN DATE
                                 , p_i_data_fim IN DATE )
    IS
        SELECT a.cod_estab
             , b.cod_estab AS cod_estab_b
             , a.num_docfis
             , a.serie_docfis
             , x04a.cpf_cgc
             , a.data_fiscal data_fiscal_a
             , x04a.cod_fis_jur cod_fis_jur_a
             , SUBSTR ( x04a.razao_social
                      , 1
                      , 14 )
                   razao_social_a
             , a.vlr_tot_nota vlr_tot_nota_a
             , b.data_fiscal data_fiscal_b
             , x04b.cod_fis_jur cod_fis_jur_b
             , SUBSTR ( x04b.razao_social
                      , 1
                      , 14 )
                   razao_social_b
             , b.vlr_tot_nota vlr_tot_nota_b
             , a.ident_docto_fiscal ident_docto_fiscal_a
             , b.ident_docto_fiscal ident_docto_fiscal_b
             , a.num_autentic_nfe chave_acesso_a
          FROM msaf.dwt_docto_fiscal a
             , msaf.x04_pessoa_fis_jur x04a
             , msaf.dwt_docto_fiscal b
             , msaf.x04_pessoa_fis_jur x04b
             , msafi.dsp_proc_estabs est
         WHERE a.cod_empresa = mcod_empresa
           AND a.cod_estab = est.cod_estab --FIXAR NA TABELA 'A'
           AND a.data_fiscal BETWEEN p_i_data_ini AND p_i_data_fim
           AND a.movto_e_s <> '9'
           AND b.cod_empresa = a.cod_empresa
           --AND B.COD_ESTAB           = A.COD_ESTAB     estroncho!
           AND b.movto_e_s <> '9'
           --AND B.DATA_FISCAL         BETWEEN P_I_DATA_INI AND P_I_DATA_FIM
           AND x04a.ident_fis_jur = a.ident_fis_jur
           AND x04b.ident_fis_jur = b.ident_fis_jur
           AND x04a.cpf_cgc = x04b.cpf_cgc
           AND b.num_docfis = a.num_docfis
           AND b.serie_docfis = a.serie_docfis
           AND b.ident_docto_fiscal <> a.ident_docto_fiscal;

    --------------------------------------------------------------------------------------------------------------
    -- RELATORIO: UNION SELECT ''101'',''101 - P2K - Dif. P2K_FECHAMENTO e P2K_TRIB_FECH'' FROM DUAL
    CURSOR c_relatorio_101a ( p_data_ini VARCHAR2
                            , p_data_fim VARCHAR2 )
    IS
        SELECT   pfc.codigo_loja
               , TO_DATE ( pfc.data_transacao
                         , 'YYYYMMDD' )
                     data_transacao
               , pfc.numero_componente
               , pfc.venda_bruta
               , pfc.total_canc
               , pfc.total_descontos
               , pfc.pfc_liq
               , ptf.val_liquido
            FROM (SELECT codigo_loja
                       , data_transacao
                       , numero_componente
                       , nsu_transacao
                       , gt_inicial
                       , gt_final
                       , total_canc
                       , total_descontos
                       , venda_bruta
                       , venda_bruta - total_canc - total_descontos pfc_liq
                    FROM msafi.p2k_fechamento a
                   WHERE a.data_transacao BETWEEN p_data_ini AND p_data_fim
                     AND a.tipo_fechamento = '2'
                     AND a.nsu_transacao = (SELECT MAX ( b.nsu_transacao )
                                              FROM msafi.p2k_fechamento b
                                             WHERE b.codigo_loja = a.codigo_loja
                                               AND b.data_transacao = a.data_transacao
                                               AND b.numero_componente = a.numero_componente)) pfc
                 FULL OUTER JOIN (SELECT   codigo_loja
                                         , data_transacao
                                         , numero_componente
                                         , nsu_transacao
                                         , SUM ( val_bruto ) val_bruto
                                         , SUM ( val_liquido ) val_liquido
                                      FROM msafi.p2k_trib_fech a
                                     WHERE data_transacao BETWEEN p_data_ini AND p_data_fim
                                       AND SUBSTR ( TRIM ( a.codigo_trib )
                                                  , 1
                                                  , 1 ) IN ( 'T'
                                                           , 'I'
                                                           , 'N'
                                                           , 'F' )
                                       AND TRIM ( a.codigo_trib ) NOT IN ( 'FS'
                                                                         , 'NS'
                                                                         , 'IS' )
                                       AND a.val_liquido IS NOT NULL
                                  GROUP BY codigo_loja
                                         , data_transacao
                                         , numero_componente
                                         , nsu_transacao) ptf
                     ON pfc.codigo_loja = ptf.codigo_loja
                    AND pfc.data_transacao = ptf.data_transacao
                    AND pfc.numero_componente = ptf.numero_componente
                    AND pfc.nsu_transacao = ptf.nsu_transacao
           WHERE pfc.data_transacao BETWEEN p_data_ini AND p_data_fim
             AND NVL ( pfc.pfc_liq, -1 ) <> NVL ( ptf.val_liquido, 0 )
        ORDER BY 1
               , 2
               , 3;

    --------------------------------------------------------------------------------------------------------------
    CURSOR c_relatorio_101b ( p_data_ini VARCHAR2
                            , p_data_fim VARCHAR2 )
    IS
        SELECT   pfc.codigo_loja
               , TO_DATE ( pfc.data_transacao
                         , 'YYYYMMDD' )
                     data_transacao
               , pfc.numero_componente
               , pfc.venda_bruta
               , pfc.total_canc
               , pfc.total_descontos
               , pfc.pfc_liq
               , ptf.val_liquido
            FROM (SELECT codigo_loja
                       , data_transacao
                       , numero_componente
                       , nsu_transacao
                       , gt_inicial
                       , gt_final
                       , total_canc
                       , total_descontos
                       , venda_bruta
                       , venda_bruta - total_canc - total_descontos pfc_liq
                    FROM msafi.p2k_fechamento a
                   WHERE a.data_transacao BETWEEN p_data_ini AND p_data_fim
                     AND a.tipo_fechamento = '2'
                     AND a.nsu_transacao = (SELECT MAX ( b.nsu_transacao )
                                              FROM msafi.p2k_fechamento b
                                             WHERE b.codigo_loja = a.codigo_loja
                                               AND b.data_transacao = a.data_transacao
                                               AND b.numero_componente = a.numero_componente)) pfc
                 FULL OUTER JOIN (SELECT   codigo_loja
                                         , data_transacao
                                         , numero_componente
                                         , nsu_transacao
                                         , SUM ( val_bruto ) val_bruto
                                         , SUM ( val_liquido ) val_liquido
                                      FROM msafi.p2k_trib_fech a
                                     WHERE data_transacao BETWEEN p_data_ini AND p_data_fim
                                       AND SUBSTR ( TRIM ( a.codigo_trib )
                                                  , 1
                                                  , 1 ) IN ( 'T'
                                                           , 'I'
                                                           , 'N'
                                                           , 'F' )
                                       AND TRIM ( a.codigo_trib ) NOT IN ( 'FS'
                                                                         , 'NS'
                                                                         , 'IS' )
                                       AND a.val_liquido IS NOT NULL
                                  GROUP BY codigo_loja
                                         , data_transacao
                                         , numero_componente
                                         , nsu_transacao) ptf
                     ON pfc.codigo_loja = ptf.codigo_loja
                    AND pfc.data_transacao = ptf.data_transacao
                    AND pfc.numero_componente = ptf.numero_componente
                    AND pfc.nsu_transacao = ptf.nsu_transacao
           WHERE pfc.data_transacao BETWEEN p_data_ini AND p_data_fim
             AND NVL ( pfc.pfc_liq, -1 ) <> NVL ( ptf.val_liquido, 0 )
             AND pfc.codigo_loja IN ( SELECT TO_NUMBER ( SUBSTR ( cod_estab
                                                                , 4
                                                                , 3 ) )
                                        FROM msafi.dsp_proc_estabs )
        ORDER BY 1
               , 2
               , 3;

    --------------------------------------------------------------------------------------------------------------
    -- RELATORIO: UNION SELECT ''102'',''102 - P2K - Dif. P2K_TRIB_FECH e P2K_CAB_TRANSACAO - VENDA LIQUIDA'' FROM DUAL
    CURSOR c_relatorio_102a ( p_data_ini VARCHAR2
                            , p_data_fim VARCHAR2 )
    IS
        SELECT   a.codigo_loja
               , TO_DATE ( a.data_transacao
                         , 'YYYYMMDD' )
                     data_transacao
               , a.numero_componente
               , a.ptf_val_bruto
               , b.pct_valor_total_venda
               , a.ptf_val_bruto - b.pct_valor_total_venda AS dif
            FROM (SELECT   pfc.codigo_loja
                         , pfc.numero_componente
                         , pfc.data_transacao
                         , SUM ( ptf.val_bruto ) AS ptf_val_bruto
                      FROM msafi.p2k_fechamento pfc
                         , msafi.p2k_trib_fech ptf
                     WHERE pfc.data_transacao BETWEEN p_data_ini AND p_data_fim
                       AND pfc.codigo_loja = ptf.codigo_loja
                       AND pfc.data_transacao = ptf.data_transacao
                       AND pfc.numero_componente = ptf.numero_componente
                       AND pfc.nsu_transacao = ptf.nsu_transacao
                       AND pfc.tipo_fechamento = '2'
                  GROUP BY pfc.codigo_loja
                         , pfc.numero_componente
                         , pfc.data_transacao) a
               , (SELECT   pct.codigo_loja
                         , pct.data_transacao
                         , pct.numero_componente
                         , SUM ( pct.valor_total_venda ) AS pct_valor_total_venda
                      FROM msafi.p2k_cab_transacao pct
                     WHERE pct.data_transacao BETWEEN p_data_ini AND p_data_fim
                       AND pct.tipo_venda = 1
                       AND pct.nsu_transacao = (SELECT MAX ( nsu_transacao )
                                                  FROM msafi.p2k_cab_transacao spct
                                                 WHERE spct.codigo_loja = pct.codigo_loja
                                                   AND spct.data_transacao = pct.data_transacao
                                                   AND spct.numero_componente = pct.numero_componente
                                                   AND spct.numero_cupom = pct.numero_cupom)
                       AND NOT EXISTS
                               (SELECT 1
                                  FROM msafi.p2k_canc_cupom pcc
                                 WHERE pcc.codigo_loja_trs_canc = pct.codigo_loja
                                   AND pcc.data_trs_canc = pct.data_transacao
                                   AND pcc.num_componente_trs_canc = pct.numero_componente
                                   AND pcc.nsu_trs_canc = pct.nsu_transacao)
                  GROUP BY pct.codigo_loja
                         , pct.data_transacao
                         , pct.numero_componente) b
           WHERE a.codigo_loja = b.codigo_loja
             AND a.data_transacao = b.data_transacao
             AND a.numero_componente = b.numero_componente
             AND a.ptf_val_bruto <> b.pct_valor_total_venda
        ORDER BY 1
               , 2
               , 3;

    --------------------------------------------------------------------------------------------------------------
    CURSOR c_relatorio_102b ( p_data_ini VARCHAR2
                            , p_data_fim VARCHAR2 )
    IS
        SELECT   a.codigo_loja
               , TO_DATE ( a.data_transacao
                         , 'YYYYMMDD' )
                     data_transacao
               , a.numero_componente
               , a.ptf_val_bruto
               , b.pct_valor_total_venda
               , a.ptf_val_bruto - b.pct_valor_total_venda AS dif
            FROM (SELECT   pfc.codigo_loja
                         , pfc.numero_componente
                         , pfc.data_transacao
                         , SUM ( ptf.val_bruto ) AS ptf_val_bruto
                      FROM msafi.p2k_fechamento pfc
                         , msafi.p2k_trib_fech ptf
                     WHERE pfc.codigo_loja IN ( SELECT TO_NUMBER ( SUBSTR ( cod_estab
                                                                          , 4
                                                                          , 3 ) )
                                                  FROM msafi.dsp_proc_estabs )
                       AND pfc.data_transacao BETWEEN p_data_ini AND p_data_fim
                       AND pfc.codigo_loja = ptf.codigo_loja
                       AND pfc.data_transacao = ptf.data_transacao
                       AND pfc.numero_componente = ptf.numero_componente
                       AND pfc.nsu_transacao = ptf.nsu_transacao
                       AND pfc.tipo_fechamento = '2'
                  GROUP BY pfc.codigo_loja
                         , pfc.numero_componente
                         , pfc.data_transacao) a
               , (SELECT   pct.codigo_loja
                         , pct.data_transacao
                         , pct.numero_componente
                         , SUM ( pct.valor_total_venda ) AS pct_valor_total_venda
                      FROM msafi.p2k_cab_transacao pct
                     WHERE pct.codigo_loja IN ( SELECT TO_NUMBER ( SUBSTR ( cod_estab
                                                                          , 4
                                                                          , 3 ) )
                                                  FROM msafi.dsp_proc_estabs )
                       AND pct.data_transacao BETWEEN p_data_ini AND p_data_fim
                       AND pct.tipo_venda = 1 --AND PCT.CODIGO_LOJA = 4
                       AND pct.nsu_transacao = (SELECT MAX ( nsu_transacao )
                                                  FROM msafi.p2k_cab_transacao spct
                                                 WHERE spct.codigo_loja = pct.codigo_loja
                                                   AND spct.data_transacao = pct.data_transacao
                                                   AND spct.numero_componente = pct.numero_componente
                                                   AND spct.numero_cupom = pct.numero_cupom)
                       AND NOT EXISTS
                               (SELECT 1
                                  FROM msafi.p2k_canc_cupom pcc
                                 WHERE pcc.codigo_loja_trs_canc = pct.codigo_loja
                                   AND pcc.data_trs_canc = pct.data_transacao
                                   AND pcc.num_componente_trs_canc = pct.numero_componente
                                   AND pcc.nsu_trs_canc = pct.nsu_transacao)
                  GROUP BY pct.codigo_loja
                         , pct.data_transacao
                         , pct.numero_componente) b
           WHERE a.codigo_loja IN ( SELECT TO_NUMBER ( SUBSTR ( cod_estab
                                                              , 4
                                                              , 3 ) )
                                      FROM msafi.dsp_proc_estabs )
             AND a.codigo_loja = b.codigo_loja
             AND a.data_transacao = b.data_transacao
             AND a.numero_componente = b.numero_componente
             AND a.ptf_val_bruto <> b.pct_valor_total_venda
        ORDER BY 1
               , 2
               , 3;

    --------------------------------------------------------------------------------------------------------------
    -- RELATORIO: UNION SELECT ''103'',''103 - P2K - Dif. P2K_TRIB_FECH e P2K_ITEM_TRANSACAO - VENDA LIQUIDA'' FROM DUAL
    CURSOR c_relatorio_103 (
        p_codigo_loja NUMBER
      , p_data_ini VARCHAR2
      , p_data_fim VARCHAR2
    )
    IS
        SELECT   NVL ( a.codigo_loja, b.codigo_loja ) codigo_loja
               , TO_DATE ( NVL ( a.data_transacao, b.data_transacao )
                         , 'YYYYMMDD' )
                     data_transacao
               , NVL ( a.numero_componente, b.numero_componente ) numero_componente
               , NVL ( a.ptf_codigo_trib, b.tipo_imposto ) ptf_codigo_trib
               , a.ptf_val_bruto
               , b.pit_valor_liquido
               , a.ptf_val_bruto - b.pit_valor_liquido AS dif
            FROM ( SELECT   pfc.codigo_loja
                          , pfc.numero_componente
                          , pfc.data_transacao
                          , CASE
                                WHEN TRIM ( ptf.codigo_trib ) = 'I' THEN
                                    'I'
                                WHEN TRIM ( ptf.codigo_trib ) = 'N' THEN
                                    'N'
                                WHEN TRIM ( ptf.codigo_trib ) = 'F' THEN
                                    'F'
                                WHEN SUBSTR ( TRIM ( ptf.codigo_trib )
                                            , 1
                                            , 1 ) = 'T' THEN
                                    DECODE ( TRIM ( ptf.val_percentual )
                                           , '7', 'T6'
                                           , '12', 'T3'
                                           , '17', 'T17'
                                           , '18', 'T1'
                                           , '19', 'T8'
                                           , '25', 'T2'
                                           , '26', 'T9'
                                           , TRIM ( ptf.val_percentual ) )
                                ELSE
                                    SUBSTR ( '?' || TRIM ( ptf.codigo_trib )
                                           , 1
                                           , 5 )
                            END
                                ptf_codigo_trib
                          , SUM ( ptf.val_bruto ) AS ptf_val_bruto --SELECT*FROM P2K_TRIB_FECH
                       FROM msafi.p2k_fechamento pfc
                          , msafi.p2k_trib_fech ptf
                      WHERE pfc.codigo_loja = p_codigo_loja
                        AND pfc.data_transacao BETWEEN p_data_ini AND p_data_fim
                        AND pfc.codigo_loja = ptf.codigo_loja
                        AND pfc.data_transacao = ptf.data_transacao
                        AND pfc.numero_componente = ptf.numero_componente
                        AND pfc.nsu_transacao = ptf.nsu_transacao
                        AND pfc.tipo_fechamento = '2'
                        AND ptf.val_bruto <> 0
                   GROUP BY pfc.codigo_loja
                          , pfc.numero_componente
                          , pfc.data_transacao
                          , CASE
                                WHEN TRIM ( ptf.codigo_trib ) = 'I' THEN
                                    'I'
                                WHEN TRIM ( ptf.codigo_trib ) = 'N' THEN
                                    'N'
                                WHEN TRIM ( ptf.codigo_trib ) = 'F' THEN
                                    'F'
                                WHEN SUBSTR ( TRIM ( ptf.codigo_trib )
                                            , 1
                                            , 1 ) = 'T' THEN
                                    DECODE ( TRIM ( ptf.val_percentual )
                                           , '7', 'T6'
                                           , '12', 'T3'
                                           , '17', 'T17'
                                           , '18', 'T1'
                                           , '19', 'T8'
                                           , '25', 'T2'
                                           , '26', 'T9'
                                           , TRIM ( ptf.val_percentual ) )
                                ELSE
                                    SUBSTR ( '?' || TRIM ( ptf.codigo_trib )
                                           , 1
                                           , 5 )
                            END ) a
                 FULL OUTER JOIN (SELECT   pct.codigo_loja
                                         , pct.data_transacao
                                         , pct.numero_componente
                                         , CASE
                                               WHEN TRIM ( pit.tipo_imposto ) = 'FONTE' THEN
                                                   'F'
                                               WHEN TRIM ( pit.tipo_imposto ) = 'ISENTO' THEN
                                                   'I'
                                               WHEN TRIM ( pit.tipo_imposto ) = 'NAO TRIBUTADO' THEN
                                                   'N'
                                               WHEN TRIM ( pit.tipo_imposto ) = '7' THEN
                                                   'T6'
                                               WHEN TRIM ( pit.tipo_imposto ) = '12' THEN
                                                   'T3'
                                               WHEN TRIM ( pit.tipo_imposto ) = '17' THEN
                                                   'T17'
                                               WHEN TRIM ( pit.tipo_imposto ) = '18' THEN
                                                   'T1'
                                               WHEN TRIM ( pit.tipo_imposto ) = '19' THEN
                                                   'T8'
                                               WHEN TRIM ( pit.tipo_imposto ) = '25' THEN
                                                   'T2'
                                               WHEN TRIM ( pit.tipo_imposto ) = '26' THEN
                                                   'T9'
                                               ELSE
                                                   SUBSTR ( '?' || TRIM ( pit.tipo_imposto )
                                                          , 1
                                                          , 5 )
                                           END
                                               tipo_imposto
                                         , SUM ( pit.valor_total_produto - pit.valor_desconto ) AS pit_valor_liquido
                                      FROM msafi.p2k_cab_transacao pct
                                         , msafi.p2k_item_transacao pit
                                     WHERE pct.codigo_loja = p_codigo_loja
                                       AND pct.data_transacao BETWEEN p_data_ini AND p_data_fim
                                       AND pct.tipo_venda = 1
                                       AND pct.nsu_transacao = (SELECT MAX ( nsu_transacao )
                                                                  FROM msafi.p2k_cab_transacao spct
                                                                 WHERE spct.codigo_loja = pct.codigo_loja
                                                                   AND spct.data_transacao = pct.data_transacao
                                                                   AND spct.numero_componente = pct.numero_componente
                                                                   AND spct.numero_cupom = pct.numero_cupom)
                                       --P2K_ITEM_TRANSACAO PIT
                                       AND pit.codigo_loja = pct.codigo_loja
                                       AND pit.data_transacao = pct.data_transacao
                                       AND pit.numero_componente = pct.numero_componente
                                       AND pit.nsu_transacao = pct.nsu_transacao
                                       AND pit.status_item = 'V'
                                       AND NOT EXISTS
                                               (SELECT 1
                                                  FROM msafi.p2k_canc_cupom pcc
                                                 WHERE pcc.codigo_loja_trs_canc = pct.codigo_loja
                                                   AND pcc.data_trs_canc = pct.data_transacao
                                                   AND pcc.num_componente_trs_canc = pct.numero_componente
                                                   AND pcc.nsu_trs_canc = pct.nsu_transacao)
                                  GROUP BY pct.codigo_loja
                                         , pct.data_transacao
                                         , pct.numero_componente
                                         , TRIM ( pit.tipo_imposto )) b
                     ON a.codigo_loja = b.codigo_loja
                    AND a.data_transacao = b.data_transacao
                    AND a.numero_componente = b.numero_componente
                    AND a.ptf_codigo_trib = b.tipo_imposto
           WHERE NVL ( a.ptf_val_bruto, -1.234 ) <> NVL ( b.pit_valor_liquido, -2.345 )
        ORDER BY 1
               , 2
               , 3
               , 4;

    --------------------------------------------------------------------------------------------------------------
    -- RELATORIO: SELECT ''012'',''012 - Relatório Análise de Saldo da CAT17'' FROM DUAL
    CURSOR c_relatorio_012 ( p_cod_estab VARCHAR2
                           , p_data_saldo VARCHAR2 )
    IS
        SELECT   a.cod_estab
               , c.cod_produto
               , a.ident_produto
               , c.descricao
               , TO_CHAR ( b.dat_saldo
                         , 'DD/MM/YYYY' )
                     AS data_saldo_inicial
               , b.qtd_saldo AS saldo_inicial
               , TO_CHAR ( a.dat_saldo
                         , 'DD/MM/YYYY' )
                     AS data_saldo_final
               , a.qtd_saldo AS saldo_final
            FROM msaf.x26_saldos_est_st a
               , msaf.x26_saldos_est_st b
               , msaf.x2013_produto c
           WHERE a.cod_empresa = mcod_empresa
             AND a.cod_estab = p_cod_estab
             AND a.dat_saldo = p_data_saldo
             -------
             AND a.cod_empresa = b.cod_empresa
             AND a.cod_estab = b.cod_estab
             AND a.ident_produto = b.ident_produto
             AND ADD_MONTHS ( a.dat_saldo
                            , -1 ) = b.dat_saldo
             -------
             AND c.ident_produto = a.ident_produto
        ORDER BY c.descricao;
--------------------------------------------------------------------------------------------------------------

END dsp_relatorios_01_cproc;
/
SHOW ERRORS;
