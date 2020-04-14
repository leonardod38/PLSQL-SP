Prompt Package DSP_GIA_CPROC;
--
-- DSP_GIA_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dsp_gia_cproc
IS
    -- AUTOR    : DSP - LFM
    -- DATA     : 22/AGO/2012
    -- DESCRIÇÃO: Automatização do preenchimento de registros da GIA

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

    FUNCTION executar ( p_passo VARCHAR2
                      , p_periodo DATE -- R001
                      , p_verificou VARCHAR2 )
        RETURN INTEGER;

    --Baseado na query do People DSP_CAL_BALANCO
    CURSOR c_passo_0a ( p_i_ano IN INTEGER
                      , p_i_mes IN INTEGER )
    IS
        SELECT DISTINCT business_unit
          FROM msafi.ps_dsp_calbal_line
         WHERE dsp_ano_num = p_i_ano
           AND dsp_mes_num = p_i_mes;

    CURSOR c_passo_0b ( p_i_dataproc IN DATE )
    IS
        SELECT   estab AS loja
               , business_unit AS dep
               , proc_date
               , SUM ( dsp_icmstax_bss ) AS soma__dsp_icmstax_bss
               , SUM ( dsp_icmstax_amt ) AS soma__dsp_icmstax_amt
            --select*
            FROM msafi.dsp_est_gia_tmp
           WHERE proc_date = LAST_DAY ( p_i_dataproc )
        GROUP BY estab
               , business_unit
               , proc_date
        ORDER BY proc_date DESC
               , estab
               , business_unit;

    CURSOR c_passo_6
    IS
        SELECT est.cod_estab
          FROM msaf.estabelecimento est
             , msaf.estado uf
         WHERE est.ident_estado = uf.ident_estado
           AND uf.cod_estado = 'BA';

    -- R001
    -- CURSOR - LOJAS RIO DE JANEIRO
    CURSOR crs_estab ( v_cod_empresa VARCHAR2 )
    IS
        SELECT   *
            FROM msafi.dsp_estabelecimento
           WHERE cod_empresa = v_cod_empresa
             AND cod_estado = 'RJ'
             AND tipo = 'L'
        ORDER BY cod_estab;


    -- CURSOR - ITENS DE DOCUMENTOS FISCAIS CESTA BASICA
    CURSOR crs_itens (
        v_cod_empresa VARCHAR2
      , v_cod_estab VARCHAR2
      , v_data_ini DATE
      , v_data_fim DATE
    )
    IS
        --SELECT FIN4405 - Cesta Básica . Guilherme Silva

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
               , CASE WHEN a.base_reduz > 0 THEN 0 ELSE ( a.base_icms * ( ( a.aliq_tributo_icms - 7 ) / 100 ) ) END
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
                       , (SELECT cod_estab
                            FROM msafi.dsp_estabelecimento
                           WHERE cod_estado = 'RJ') est
                   WHERE 1 = 1
                     AND x08.data_fiscal BETWEEN v_data_ini AND v_data_fim
                     AND x07.cod_estab = v_cod_estab
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
                     AND x2006.ident_natureza_op = x08.ident_natureza_op
                     AND y2026.ident_situacao_b = x08.ident_situacao_b) a
           WHERE a.aliq_tributo_icms > 7
        --AND EXISTS (SELECT 'X'
        --                    FROM MSAF.APURACAO AP
        --                   WHERE AP.COD_EMPRESA = A.COD_EMPRESA
        --                     AND AP.COD_ESTAB = A.COD_ESTAB
        --                     AND AP.COD_TIPO_LIVRO = '108'
        --                     AND AP.DAT_APURACAO = LAST_DAY(V_DATA_FIM))
        ORDER BY a.cod_estab
               , a.movto_e_s
               , a.data_fiscal;
--
/*  SELECT DISTINCT CAPA.COD_EMPRESA,
                  CAPA.COD_ESTAB,
                  CAPA.MOVTO_E_S,
                  CAPA.DATA_FISCAL,
                  CAPA.NUM_DOCFIS,
                  CAPA.NUM_CONTROLE_DOCTO,
                  CFOP.COD_CFO,
                  PROD.COD_PRODUTO,
                  PROD.DESCRICAO,
                  NOPE.COD_NATUREZA_OP,
                  SITB.COD_SITUACAO_B,
                  NCM.COD_NBM,
                  ITEM.QUANTIDADE,
                  ITEM.VLR_UNIT,
                  ITEM.VLR_ITEM,
                  ITEM.VLR_CONTAB_ITEM,
                  ITEM.VLR_BASE_ICMS_1 AS BASE_ICMS,
                  ITEM.ALIQ_TRIBUTO_ICMS,
                  ITEM.VLR_TRIBUTO_ICMS AS ICMS,
                  ITEM.VLR_BASE_ICMS_2 AS BASE_ISENTO,
                  ITEM.VLR_BASE_ICMS_3 AS BASE_OUTRAS,
                  ITEM.VLR_BASE_ICMS_4 AS BASE_REDUZ,
                  ITEM.VLR_BASE_IPI_1 BASE_IPI,
                  ITEM.VLR_TRIBUTO_IPI VALOR_IPI,
                  ITEM.VLR_BASE_ICMSS BASE_ICMSS,
                  ITEM.VLR_TRIBUTO_ICMSS VLR_ICMSS,
                  ITEM.VLR_FRETE AS FRETE,
                  ITEM.VLR_OUTRAS AS DESPESAS,
                  NVL((SELECT 'S'
                        FROM MSAF.APURACAO
                       WHERE COD_EMPRESA = CAPA.COD_EMPRESA
                         AND COD_ESTAB = CAPA.COD_ESTAB
                         AND COD_TIPO_LIVRO = '108'
                         AND DAT_APURACAO = LAST_DAY(V_DATA_FIM)),
                      'N') APURACAO
    FROM MSAF.DWT_DOCTO_FISCAL CAPA
    JOIN MSAF.DWT_ITENS_MERC ITEM
      ON ITEM.IDENT_DOCTO_FISCAL = CAPA.IDENT_DOCTO_FISCAL
    JOIN MSAF.X2012_COD_FISCAL CFOP
      ON ITEM.IDENT_CFO = CFOP.IDENT_CFO
    JOIN MSAF.X2013_PRODUTO PROD
      ON ITEM.IDENT_PRODUTO = PROD.IDENT_PRODUTO
    JOIN MSAF.X2006_NATUREZA_OP NOPE
      ON ITEM.IDENT_NATUREZA_OP = NOPE.IDENT_NATUREZA_OP
    JOIN MSAF.Y2026_SIT_TRB_UF_B SITB
      ON ITEM.IDENT_SITUACAO_B = SITB.IDENT_SITUACAO_B
    JOIN MSAF.X2043_COD_NBM NCM
      ON ITEM.IDENT_NBM = NCM.IDENT_NBM
    JOIN MSAF.DSP_GIA_CESTA_BASICA CSTB
      ON CSTB.INV_ITEM_ID = PROD.COD_PRODUTO
   WHERE CAPA.COD_EMPRESA = V_COD_EMPRESA
     AND CAPA.COD_ESTAB = V_COD_ESTAB
     AND CAPA.DATA_FISCAL BETWEEN V_DATA_INI AND V_DATA_FIM
     AND ITEM.VLR_TRIBUTO_ICMS > 0
   ORDER BY CAPA.COD_ESTAB, CAPA.MOVTO_E_S, CAPA.DATA_FISCAL;*/

END dsp_gia_cproc;
/
SHOW ERRORS;
