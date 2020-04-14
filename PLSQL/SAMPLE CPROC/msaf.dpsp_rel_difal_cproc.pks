Prompt Package DPSP_REL_DIFAL_CPROC;
--
-- DPSP_REL_DIFAL_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dpsp_rel_difal_cproc
IS
    -- AUTOR    : Douglas Oliveira
    -- DATA     : 23/10/2018
    -- DESCRI«√O: Relatorio Difal

    FUNCTION executar ( p_data_ini DATE
                      , p_data_fim DATE
                      , p_uf VARCHAR2
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
        SELECT a.num_docfis AS n_nf
             , a.cod_estab AS estabelecimento
             , a.data_fiscal AS data_fiscal
             , a.data_emissao AS data_emiss√o
             , a.num_controle_docto AS num_controle
             , d.cod_modelo AS mod_documento
             , a.num_autentic_nfe AS chave_acesso_nfe
             , e.razao_social AS raz√o_social
             , e.cgc AS cpf_cnpj
             , f.inscricao_estadual AS insc_estadual
             , g.cod_estado AS uf
             , m.cod_fis_jur AS cod_destinatario
             , m.razao_social AS razao_social_destinatario
             , m.cpf_cgc AS cnpj_destinatario
             , m.insc_estadual AS ie_destinatario
             , ( SELECT cod_estado
                   FROM estado
                  WHERE estado.ident_estado = m.ident_estado )
                   AS uf_destinatario
             , b.num_item AS num_item_nf
             , h.cod_produto AS cod_produto
             , h.descricao AS descri«√o
             , i.cod_nbm AS ncm
             , c.cod_cfo AS cfop
             , j.cod_natureza_op AS nat_operacao
             , l.cod_situacao_b AS cst_a_b
             , b.vlr_unit AS valor_unitario
             , b.quantidade AS quantidade
             , b.vlr_item AS valor_total
             , b.vlr_contab_item AS valor_cont¡bil
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
                   AS base_icmss
             , b.vlr_icms_ndestac AS vlr_icms_ndestac
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
                          AND g.cod_tributacao = '2'
                          AND g.cod_tributo = 'ICMS' )
                   , 0 )
                   AS valor_isentas
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
                          AND g.cod_tributacao = '3'
                          AND g.cod_tributo = 'ICMS' )
                   , 0 )
                   AS valor_outras
          FROM msaf.x07_docto_fiscal a
             , msaf.x08_itens_merc b
             , msaf.x2012_cod_fiscal c
             , msaf.x2024_modelo_docto d
             , msaf.estabelecimento e
             , msaf.registro_estadual f
             , msaf.estado g
             , msaf.x2013_produto h
             , msaf.x2043_cod_nbm i
             , msaf.x2006_natureza_op j
             , msaf.y2026_sit_trb_uf_b l
             , msaf.x04_pessoa_fis_jur m
         WHERE a.cod_empresa = p_cod_empresa
           AND a.cod_estab = p_estabs
           AND a.data_fiscal BETWEEN TO_DATE ( p_data_ini
                                             , 'DD/MM/YYYY' )
                                 AND TO_DATE ( p_data_fim
                                             , 'DD/MM/YYYY' )
           AND a.cod_empresa = b.cod_empresa
           AND a.cod_estab = b.cod_estab
           AND a.data_fiscal = b.data_fiscal
           AND a.movto_e_s = b.movto_e_s
           AND a.norm_dev = b.norm_dev
           AND a.ident_docto = b.ident_docto
           AND a.ident_fis_jur = b.ident_fis_jur
           AND a.num_docfis = b.num_docfis
           AND a.serie_docfis = b.serie_docfis
           AND a.sub_serie_docfis = b.sub_serie_docfis
           AND b.ident_cfo = c.ident_cfo
           AND a.ident_modelo = d.ident_modelo
           AND a.cod_estab = e.cod_estab
           AND e.cod_estab = f.cod_estab
           AND e.ident_estado = g.ident_estado
           AND b.ident_produto = h.ident_produto
           AND h.ident_nbm = i.ident_nbm
           AND b.ident_natureza_op = j.ident_natureza_op
           AND b.ident_situacao_b = l.ident_situacao_b
           AND b.ident_fis_jur = m.ident_fis_jur
           AND c.cod_cfo IN ( '2551'
                            , '2556'
                            , '2557'
                            , '2353' );
END dpsp_rel_difal_cproc;
/
SHOW ERRORS;
