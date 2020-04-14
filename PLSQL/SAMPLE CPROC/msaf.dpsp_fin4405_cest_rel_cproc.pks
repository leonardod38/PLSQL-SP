Prompt Package DPSP_FIN4405_CEST_REL_CPROC;
--
-- DPSP_FIN4405_CEST_REL_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dpsp_fin4405_cest_rel_cproc
IS
    -- AUTOR    : Accenture - Guilherme Silva
    -- DATA     : V1 CRIADA EM 19/NOVEMBRO/2019
    -- DESCRIÇÃO: Projeto FIN 4405 - Relatório Cesta Básica

    mcod_empresa empresa.cod_empresa%TYPE;
    mcod_estab estabelecimento.cod_estab%TYPE;
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

    FUNCTION executar ( p_periodo DATE -- R001
                      , p_verificou VARCHAR2
                      , p_lojas lib_proc.vartab )
        RETURN INTEGER;

    CURSOR crs_itens (
        v_cod_empresa VARCHAR2
      , v_cod_estab VARCHAR2
      , v_data_ini DATE
      , v_data_fim DATE
      , p_periodo VARCHAR2
    )
    IS
        --SELECT FIN4405 - Cesta Básica . Guilherme Silva
        SELECT   cod_empresa
               , cod_estab
               , movto_e_s
               , apuracao
               , SUM ( valor_estorno ) AS valor_estorno
            FROM ( SELECT   a.cod_empresa
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
                                AND x07.cod_estab = v_cod_estab
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
                          , a.data_fiscal )
        GROUP BY cod_empresa
               , cod_estab
               , movto_e_s
               , apuracao;
END dpsp_fin4405_cest_rel_cproc;
/
SHOW ERRORS;
