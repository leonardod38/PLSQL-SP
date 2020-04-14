Prompt Package DPSP_EXCL_REL_FAT_ALIQ_CPROC;
--
-- DPSP_EXCL_REL_FAT_ALIQ_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dpsp_excl_rel_fat_aliq_cproc
IS
    -- AUTOR    : ADEJO - TIAGO CERVANTES
    -- DATA     : 06/03/2018
    -- DESCRIÇÃO: Relatorio Analitico de Faturamento por Aliquota

    FUNCTION executar ( p_data_ini DATE
                      , p_data_fim DATE
                      , p_estabs lib_proc.vartab )
        RETURN NUMBER;

    FUNCTION parametros
        RETURN VARCHAR2;

    FUNCTION nome
        RETURN VARCHAR2;

    FUNCTION descricao
        RETURN VARCHAR2;

    FUNCTION versao
        RETURN VARCHAR2;

    FUNCTION tipo
        RETURN VARCHAR2;

    CURSOR crs_saidas ( p_cod_empresa VARCHAR2
                      , p_estabs VARCHAR2
                      , p_data_ini DATE
                      , p_data_fim DATE )
    IS
        SELECT   cod_empresa
               , cod_estab
               , data_fiscal
               , num_cupom
               , cod_cfo
               , cod_produto
               , a.tipo_doc
               , TO_NUMBER ( ps.aliq ) aliq
               , SUM ( TO_NUMBER ( a.vlr_liq ) ) AS vlr_liq
               , SUM ( TO_NUMBER ( a.vlr_liq ) * ( TO_NUMBER ( ps.aliq ) / 100 ) ) AS vlr_imposto
            FROM (SELECT   i.cod_empresa
                         , i.cod_estab
                         , i.data_fiscal
                         , i.num_docfis AS num_cupom
                         , d.cod_docto AS tipo_doc
                         , c.cod_cfo
                         , p.cod_produto
                         , SUM ( i.vlr_contab_item ) vlr_liq
                      FROM msaf.x08_itens_merc i
                         , msaf.x2013_produto p
                         , msaf.x2012_cod_fiscal c
                         , msaf.x2005_tipo_docto d
                     WHERE 1 = 1
                       AND i.cod_empresa = msafi.dpsp.empresa
                       AND i.cod_estab = p_estabs
                       AND i.data_fiscal BETWEEN TO_DATE ( p_data_ini
                                                         , 'DD/MM/YYYY' )
                                             AND TO_DATE ( p_data_fim
                                                         , 'DD/MM/YYYY' )
                       AND i.movto_e_s = '9'
                       AND i.norm_dev = '1'
                       AND i.ident_docto = d.ident_docto
                       AND d.cod_docto IN ( 'CF-E'
                                          , 'SAT' )
                       AND i.ident_produto = p.ident_produto
                       AND i.ident_cfo = c.ident_cfo
                  GROUP BY cod_empresa
                         , cod_estab
                         , data_fiscal
                         , num_docfis
                         , c.cod_cfo
                         , p.cod_produto
                  UNION ALL
                  SELECT   cod_empresa
                         , cod_estab
                         , data_emissao data_fiscal
                         , num_coo num_cupom
                         , 'CF' tipo_doc
                         , c.cod_cfo
                         , p.cod_produto
                         , SUM ( TO_NUMBER ( i.vlr_liq_item ) ) vlr_liq
                      FROM msaf.x994_item_cupom_ecf i
                         , msaf.x2013_produto p
                         , msaf.x2012_cod_fiscal c
                     WHERE i.cod_empresa = msafi.dpsp.empresa
                       AND i.cod_estab = p_estabs
                       AND i.data_emissao BETWEEN TO_DATE ( p_data_ini
                                                          , 'DD/MM/YYYY' )
                                              AND TO_DATE ( p_data_fim
                                                          , 'DD/MM/YYYY' )
                       AND i.ident_produto = p.ident_produto
                       AND i.ident_cfo = c.ident_cfo
                  GROUP BY cod_empresa
                         , cod_estab
                         , num_coo
                         , data_emissao
                         , c.cod_cfo
                         , p.cod_produto) a
               , (SELECT   DISTINCT /*+DRIVING_SITE(PS)*/
                                   TO_NUMBER ( a.inv_item_id ) inv_item_id
                                  , TO_NUMBER ( a.mrank )
                                  , MAX ( a.aliq ) AS aliq
                      FROM (SELECT inv_item_id
                                 , TO_NUMBER ( b.dpsp_carga_tribut ) aliq
                                 , RANK ( )
                                       OVER ( PARTITION BY b.inv_item_id
                                              ORDER BY
                                                  b.inv_item_id ASC
                                                , b.effdt DESC )
                                       mrank
                              FROM fdspprd.ps_dsp_ln_mva_his@dblink_dbpsprod b
                             WHERE crit_state_to_pbl <> crit_state_fr_pbl
                               AND crit_state_fr_pbl = 'SP'
                               AND b.effdt <= TO_DATE ( p_data_fim
                                                      , 'DD/MM/YYYY' )) a
                     WHERE a.mrank = 1
                  GROUP BY a.inv_item_id
                         , a.mrank) ps
           WHERE a.cod_produto = ps.inv_item_id(+)
        GROUP BY cod_empresa
               , cod_estab
               , data_fiscal
               , num_cupom
               , cod_cfo
               , cod_produto
               , a.tipo_doc
               , ps.aliq;
END dpsp_excl_rel_fat_aliq_cproc;
/
SHOW ERRORS;
