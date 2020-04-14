Prompt Package DPSP_EX_PIS_COFINS_635_CPROC;
--
-- DPSP_EX_PIS_COFINS_635_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dpsp_ex_pis_cofins_635_cproc
IS
    -- AUTOR    : DSP - RODOLFO
    -- DATA     : CRIADA EM 29/NOV/2017
    -- DESCRIÇÃO: Projeto 930
    -- V9 CRIADA EM 12/12/2018: REBELLO - VERSAO ATUAL NA PRD EM 12/12/2018

    musuario usuario_empresa.cod_usuario%TYPE;

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

    FUNCTION executar ( p_data_ini DATE
                      , p_data_fim DATE
                      , p_rel VARCHAR2
                      , p_uf VARCHAR2
                      , p_lojas lib_proc.vartab )
        RETURN INTEGER;

    CURSOR crs_relatorio ( p_cod_estab VARCHAR2
                         , p_i_data_ini DATE
                         , p_i_data_fim DATE )
    IS
        SELECT /*+ DRIVING_SITE(PS)*/
              ue.cod_empresa
             , ue.cod_estab
             , ue.uf_estab
             , ue.data_fiscal
             , ue.docto AS cod_docto
             , ue.num_docfis
             , ue.serie_docfis
             , ue.num_autentic_nfe
             , ue.cod_produto
             , ue.descr_item AS descricao
             , ue.num_item
             , ue.cod_cfo
             , ue.cod_nbm
             , -- UE.COD_SITUACAO_B,
               -- UE.COD_NATUREZA_OP,
               l.lista
             , --l.Cst_Pc,
               ue.quantidade
             , ue.vlr_item
             , ue.vlr_contabil vlr_contab_item
             , ue.vlr_outras
             , ue.vlr_desconto
             , ue.vlr_base_icms
             , ue.aliq_icms
             , ue.vlr_icms
             , ue.cst_pis cod_situacao_pis
             , ue.vlr_base_pis
             , ue.vlr_aliq_pis
             , ue.vlr_pis
             , ue.cst_cofins cod_situacao_cofins
             , ue.vlr_base_cofins
             , ue.vlr_aliq_cofins
             , ue.vlr_cofins
             , --
               ue.cod_estab_e
             , ue.data_fiscal_e
             , ue.num_docfis_e
             , ue.serie_docfis_e
             , ue.num_controle_docto_e
             , ue.num_autentic_nfe_e
             , ue.num_item_e
             , ue.cod_cfo_e
             , NVL ( icfo_brl_cd, ccfo_brl_cd ) cod_cfo_saida
             , ue.quantidade_e
             , ue.vlr_item_e vlr_item_e
             , ue.vlr_contab_item_e vlr_contab_item_e
             , ue.vlr_outras_e vlr_outras_e
             , ue.vlr_desconto_e vlr_desconto_e
             , --       UE.VLR_BASE_ICMS,
               --       UE.ALIQ_ICMS_E,
               --       UE.VLR_ICMS,
               ue.vlr_base_icms_e
             , ue.vlr_icms_e
             , ue.vlr_base_icmss_e
             , ue.vlr_icmss_e
             , ue.cst_pis_e cod_situacao_pis_e
             , ue.vlr_base_pis_e vlr_base_pis_e
             , ue.vlr_aliq_pis_e vlr_aliq_pis_e
             , ue.vlr_pis_e vlr_pis_e
             , ue.cst_cofins_e cod_situacao_cofins_e
             , ue.vlr_base_cofins_e vlr_base_cofins_e
             , ue.vlr_aliq_cofins_e vlr_aliq_cofins_e
             , ue.vlr_cofins_e vlr_cofins_e
             , --
               ue.vlr_icmss_n_escrit
             , ue.vlr_icms_unit
             , ue.vlr_icms_st_unit
             , ue.vlr_icms_st_unit_aux
          --
          FROM msaf.dpsp_ex_bpc_uentr_jj ue
               LEFT JOIN dpsp_ps_lista l --  Left Join Dpsp_Lista_Temp l
                                         ON l.cod_produto = ue.cod_produto
               LEFT JOIN
               (SELECT nf_brl_date
                     , nf_brl
                     , ips.cfo_brl_cd icfo_brl_cd
                     , cps.cfo_brl_cd ccfo_brl_cd
                     , ips.nf_brl_line_num
                     , impps.tax_brl_bse
                     , impps.tax_brl_amt
                  FROM fdspprd.ps_ar_nfe_pbl@dblink_dbpsprod cps
                       JOIN fdspprd.ps_ar_item_nfe_pbl@dblink_dbpsprod ips ON cps.nf_brl_int_id = ips.nf_brl_int_id
                       JOIN fdspprd.ps_ar_imp_pbl@dblink_dbpsprod impps
                           ON impps.nf_brl_int_id = cps.nf_brl_int_id
                          AND impps.nf_brl_line_num = ips.nf_brl_line_num
                 WHERE impps.tax_type_pbl = 'ICST'
                   AND SUBSTR ( NVL ( ips.cfo_brl_cd, cps.cfo_brl_cd )
                              , 1
                              , 1 ) > '3') ps
                   ON nf_brl = ue.num_docfis_e
                  AND nf_brl_date = ue.data_emissao_e
                  AND nf_brl_line_num = ue.num_item_e
         WHERE ue.cod_empresa = msafi.dpsp.empresa
           AND ue.cod_estab = p_cod_estab
           AND ue.data_fiscal BETWEEN p_i_data_ini AND p_i_data_fim
           AND l.effdt = (SELECT MAX ( effdt )
                            FROM dpsp_ps_lista
                           WHERE cod_produto = l.cod_produto)
           AND ue.docto IN ( 'CF-E'
                           , 'SAT' )
        UNION
        SELECT ue.cod_empresa
             , ue.cod_estab
             , ue.uf_estab
             , ue.data_fiscal
             , ue.docto AS cod_docto
             , ue.num_docfis
             , ue.serie_docfis
             , ue.num_autentic_nfe
             , ue.cod_produto
             , ue.descr_item AS descricao
             , ue.num_item
             , ue.cod_cfo
             , ue.cod_nbm
             , -- UE.COD_SITUACAO_B,
               -- UE.COD_NATUREZA_OP,
               l.lista
             , --l.Cst_Pc,
               ue.quantidade
             , ue.vlr_contabil vlr_item
             , ue.vlr_contabil vlr_contab_item
             , 0 vlr_outras
             , ue.vlr_desconto vlr_desconto
             , ue.vlr_base_icms
             , ue.aliq_icms
             , ue.vlr_icms
             , ue.cst_pis cod_situacao_pis
             , ue.vlr_base_pis
             , ue.vlr_aliq_pis
             , ue.vlr_pis
             , ue.cst_cofins cod_situacao_cofins
             , ue.vlr_base_cofins
             , ue.vlr_aliq_cofins
             , ue.vlr_cofins
             , --
               ue.cod_estab_e
             , ue.data_fiscal_e
             , ue.num_docfis_e
             , ue.serie_docfis_e
             , ue.num_controle_docto_e
             , ue.num_autentic_nfe_e
             , ue.num_item_e
             , ue.cod_cfo_e
             , NVL ( icfo_brl_cd, ccfo_brl_cd ) cod_cfo_saida
             , ue.quantidade_e
             , ue.vlr_item_e vlr_item_e
             , ue.vlr_contab_item_e vlr_contab_item_e
             , ue.vlr_outras_e vlr_outras_e
             , ue.vlr_desconto_e vlr_desconto_e
             , --       UE.VLR_BASE_ICMS,
               --       UE.ALIQ_ICMS_E,
               --       UE.VLR_ICMS,
               ue.vlr_base_icms_e
             , ue.vlr_icms_e
             , ue.vlr_base_icmss_e
             , ue.vlr_icmss_e
             , ue.cst_pis_e cod_situacao_pis_e
             , ue.vlr_base_pis_e vlr_base_pis_e
             , ue.vlr_aliq_pis_e vlr_aliq_pis_e
             , ue.vlr_pis_e vlr_pis_e
             , ue.cst_cofins_e cod_situacao_cofins_e
             , ue.vlr_base_cofins_e vlr_base_cofins_e
             , ue.vlr_aliq_cofins_e vlr_aliq_cofins_e
             , ue.vlr_cofins_e vlr_cofins_e
             , --
               ue.vlr_icmss_n_escrit
             , ue.vlr_icms_unit
             , ue.vlr_icms_st_unit
             , ue.vlr_icms_st_unit_aux
          --
          FROM msaf.dpsp_ex_bpc_uentr_jj ue
               LEFT JOIN dpsp_ps_lista l -- Left Join Dpsp_Lista_Temp l
                                         ON l.cod_produto = ue.cod_produto
               LEFT JOIN
               (SELECT nf_brl_date
                     , nf_brl
                     , ips.cfo_brl_cd icfo_brl_cd
                     , cps.cfo_brl_cd ccfo_brl_cd
                     , ips.nf_brl_line_num
                     , impps.tax_brl_bse
                     , impps.tax_brl_amt
                  FROM fdspprd.ps_ar_nfe_pbl@dblink_dbpsprod cps
                       JOIN fdspprd.ps_ar_item_nfe_pbl@dblink_dbpsprod ips ON cps.nf_brl_int_id = ips.nf_brl_int_id
                       JOIN fdspprd.ps_ar_imp_pbl@dblink_dbpsprod impps
                           ON impps.nf_brl_int_id = cps.nf_brl_int_id
                          AND impps.nf_brl_line_num = ips.nf_brl_line_num
                 WHERE impps.tax_type_pbl = 'ICST'
                   AND SUBSTR ( NVL ( ips.cfo_brl_cd, cps.cfo_brl_cd )
                              , 1
                              , 1 ) > '3') ps
                   ON nf_brl = ue.num_docfis_e
                  AND nf_brl_date = ue.data_emissao_e
                  AND nf_brl_line_num = ue.num_item_e
         WHERE ue.cod_empresa = msafi.dpsp.empresa
           AND ue.cod_estab = p_cod_estab
           AND ue.data_fiscal BETWEEN p_i_data_ini AND p_i_data_fim
           AND l.effdt = (SELECT MAX ( effdt )
                            FROM dpsp_ps_lista
                           WHERE cod_produto = l.cod_produto)
           AND ue.docto = 'ECF'
        ORDER BY 1
               , 2
               , 3;

    CURSOR c_sintetico (
        p_cod_estab VARCHAR2
      , p_i_data_ini DATE
      , p_i_data_fim DATE
    )
    IS
        SELECT   a.cod_estab
               , a.uf_estab
               , a.data_fiscal
               , a.cod_cfo
               , DECODE ( b.lista,  'P', 'POSITIVA',  'N', 'NEGATIVA',  'O', 'NEUTRA',  '-' ) lista
               , SUM ( a.vlr_icms_unit ) AS vlr_icms_unit
               , SUM ( a.vlr_icms_st_unit ) AS vlr_icms_st_unit
               , SUM ( a.vlr_icms_st_unit_aux ) AS vlr_icms_st_unit_aux
               , SUM (
                       CASE
                           WHEN a.cod_cfo = '5405' THEN
                               CASE
                                   WHEN ( a.vlr_icmss_e > 0
                                      OR a.vlr_icmss_n_escrit > 0 )
                                     OR ( a.uf_estab = 'SP'
                                     AND a.cod_cfo_e = '1409'
                                     AND a.vlr_icms_unit > 0 ) THEN
                                       CASE
                                           WHEN a.vlr_icms_st_unit > 0 THEN
                                               ( a.vlr_icms_unit + a.vlr_icms_st_unit ) * a.quantidade
                                           ELSE
                                               ( a.vlr_icms_unit + a.vlr_icms_st_unit_aux ) * a.quantidade
                                       END
                                   ELSE
                                       0
                               END
                           ELSE
                               CASE WHEN a.cod_cfo = '5102' THEN a.vlr_icms ELSE 0 END
                       END
                 )
                     AS vlr_calculado
            FROM msaf.dpsp_ex_bpc_uentr_jj a
               , (SELECT cod_produto
                       , lista
                       , RANK ( )
                             OVER ( PARTITION BY cod_produto
                                    ORDER BY effdt DESC )
                             RANK
                    FROM msaf.dpsp_ps_lista) b
           WHERE a.cod_produto = b.cod_produto
             AND b.RANK = 1
             AND a.data_fiscal BETWEEN p_i_data_ini AND p_i_data_fim
             AND a.cod_estab = p_cod_estab
             AND a.cod_empresa = msafi.dpsp.empresa
        GROUP BY a.cod_estab
               , a.uf_estab
               , a.data_fiscal
               , a.cod_cfo
               , DECODE ( b.lista,  'P', 'POSITIVA',  'N', 'NEGATIVA',  'O', 'NEUTRA',  '-' )
        ORDER BY 2
               , 1
               , 3
               , 4;
END dpsp_ex_pis_cofins_635_cproc;
/
SHOW ERRORS;
