Prompt Package DPSP_EXCL_REL_ANALI_CPROC;
--
-- DPSP_EXCL_REL_ANALI_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dpsp_excl_rel_anali_cproc
IS
    -- AUTOR    : ADEJO - TIAGO CERVANTES
    -- DATA     : 05/03/2018
    -- DESCRIÇÃO: Relatorio Analitico de Grandes Volumes

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

    --PROCEDURE TESTE;
    --PROCEDURE TESTE1;

    CURSOR crs_saidas ( p_cod_empresa VARCHAR2
                      , p_estabs VARCHAR2
                      , p_data_ini DATE
                      , p_data_fim DATE )
    IS
        SELECT a.cod_empresa
             , a.cod_estab
             , e.cod_estado
             , a.num_docfis
             , a.num_autentic_nfe
             , h.cod_produto
             , h.descricao
             , f.cod_cfo
             , g.cod_situacao_b
             , b.vlr_item
             , NVL ( ( SELECT vlr_base
                         FROM msaf.x08_base_merc g
                        WHERE g.cod_empresa = b.cod_empresa
                          AND g.cod_estab = b.cod_estab
                          AND g.data_fiscal = b.data_fiscal
                          AND g.movto_e_s = b.movto_e_s
                          AND g.norm_dev = b.norm_dev
                          AND g.ident_docto = b.ident_docto
                          AND g.ident_fis_jur = b.ident_fis_jur
                          AND g.num_docfis = b.num_docfis
                          AND g.serie_docfis = b.serie_docfis
                          AND g.sub_serie_docfis = b.sub_serie_docfis
                          AND g.discri_item = b.discri_item
                          AND g.cod_tributacao = '1'
                          AND g.cod_tributo = 'ICMS' )
                   , 0 )
                   vlr_base
             , NVL ( ( SELECT aliq_tributo
                         FROM msaf.x08_trib_merc it
                        WHERE b.cod_empresa = it.cod_empresa
                          AND b.cod_estab = it.cod_estab
                          AND b.data_fiscal = it.data_fiscal
                          AND b.movto_e_s = it.movto_e_s
                          AND b.norm_dev = it.norm_dev
                          AND b.ident_docto = it.ident_docto
                          AND b.ident_fis_jur = it.ident_fis_jur
                          AND b.num_docfis = it.num_docfis
                          AND b.serie_docfis = it.serie_docfis
                          AND b.sub_serie_docfis = it.sub_serie_docfis
                          AND b.discri_item = it.discri_item
                          AND it.cod_tributo = 'ICMS' )
                   , 0 )
                   AS aliq_icms
             , NVL ( ( SELECT vlr_tributo
                         FROM msaf.x08_trib_merc it
                        WHERE b.cod_empresa = it.cod_empresa
                          AND b.cod_estab = it.cod_estab
                          AND b.data_fiscal = it.data_fiscal
                          AND b.movto_e_s = it.movto_e_s
                          AND b.norm_dev = it.norm_dev
                          AND b.ident_docto = it.ident_docto
                          AND b.ident_fis_jur = it.ident_fis_jur
                          AND b.num_docfis = it.num_docfis
                          AND b.serie_docfis = it.serie_docfis
                          AND b.sub_serie_docfis = it.sub_serie_docfis
                          AND b.discri_item = it.discri_item
                          AND it.cod_tributo = 'ICMS' )
                   , 0 )
                   AS vlr_icms
          FROM msaf.x07_docto_fiscal a
             , msaf.x08_itens_merc b
             , msaf.x04_pessoa_fis_jur c
             , msaf.estabelecimento d
             , msaf.estado e
             , msaf.x2012_cod_fiscal f
             , --CFOP
              msaf.y2026_sit_trb_uf_b g
             , --CST
              msaf.x2013_produto h
         WHERE a.cod_empresa = b.cod_empresa
           AND b.cod_empresa = msafi.dpsp.empresa
           AND e.cod_estado = 'SP'
           AND b.data_fiscal BETWEEN TO_DATE ( p_data_ini
                                             , 'DD/MM/YYYY' )
                                 AND TO_DATE ( p_data_fim
                                             , 'DD/MM/YYYY' )
           AND f.cod_cfo = '5102'
           AND g.cod_situacao_b = '00' --CST
           AND a.cod_estab = p_estabs
           AND a.cod_estab = b.cod_estab
           AND a.data_fiscal = b.data_fiscal
           AND a.movto_e_s = b.movto_e_s
           AND a.norm_dev = b.norm_dev
           AND a.ident_docto = b.ident_docto
           AND a.ident_fis_jur = b.ident_fis_jur
           AND a.num_docfis = b.num_docfis
           AND a.serie_docfis = b.serie_docfis
           AND a.sub_serie_docfis = b.sub_serie_docfis
           AND a.ident_fis_jur = c.ident_fis_jur
           AND a.cod_estab = d.cod_estab
           AND d.ident_estado = e.ident_estado
           AND b.ident_cfo = f.ident_cfo
           AND b.ident_situacao_b = g.ident_situacao_b
           AND b.ident_produto = h.ident_produto
           AND a.ident_docto IN ( SELECT aa.ident_docto
                                    FROM msaf.x2005_tipo_docto aa
                                   WHERE aa.cod_docto IN ( 'CF'
                                                         , 'CF-E'
                                                         , 'SAT' ) );
END dpsp_excl_rel_anali_cproc;
/
SHOW ERRORS;
