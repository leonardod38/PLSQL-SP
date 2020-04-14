Prompt Package DPSP_REL_RES_INTER_LOTE_CPROC;
--
-- DPSP_REL_RES_INTER_LOTE_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dpsp_rel_res_inter_lote_cproc
IS
    -------------------------------------------------------------------------
    -- AUTOR    : ACCENTURE - REBELLO
    -- DATA     : V2 CRIADA EM 14/SET/2018
    -- DESCRIÇÃO: Relatório do Ressarcimento Interestadual por LOTE - Projeto 392
    -------------------------------------------------------------------------

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

    FUNCTION executar ( p_data_ini DATE
                      , p_data_fim DATE
                      , p_cenario1 VARCHAR2
                      , p_cenario2 VARCHAR2
                      , p_cenario3 VARCHAR2
                      , p_cenario4 VARCHAR2
                      , p_cenario5 VARCHAR2
                      , p_cenario6 VARCHAR2
                      , p_cenario7 VARCHAR2
                      , p_lote VARCHAR2
                      , p_sintetico VARCHAR2
                      , p_analitico VARCHAR2
                      , p_txt VARCHAR2
                      , p_cds lib_proc.vartab )
        RETURN INTEGER;

    CURSOR load_analitico ( p_i_cod_estab IN VARCHAR2
                          , p_i_data_ini IN DATE
                          , p_i_data_fim IN DATE
                          , p_i_lote IN VARCHAR2 )
    IS
        SELECT cod_empresa
             , cod_estab
             , num_docfis
             , num_controle_docto
             , num_item
             , seqnum
             , cod_produto
             , descr_item
             , cod_ean
             , grupo_produto
             , data_fiscal
             , uf_origem
             , uf_destino
             , cod_fis_jur
             , cnpj
             , razao_social
             , serie_docfis
             , finalidade
             , nbm
             , num_autentic_nfe
             , vlr_unit
             , vlr_item
             , vlr_base_icms
             , vlr_icms
             , aliq_icms
             , qtde_lote_s
             , id_lote_saida
             , data_fabricacao
             , data_validade
             ---ENTRADA
             , cod_estab_e
             , data_fiscal_e
             , movto_e_s
             , norm_dev
             , ident_docto
             , ident_fis_jur
             , num_docfis_e
             , serie_docfis_e
             , sub_serie_docfis
             , discri_item
             , num_item_e
             , cod_fis_jur_e
             , cpf_cgc
             , razao_social_e
             , cod_nbm
             , cod_natureza_op
             , vlr_contab_item
             , vlr_unit_e
             , cod_situacao_b
             , data_emissao
             , cod_estado
             , num_controle_docto_e
             , num_autentic_nfe_e
             , id_lote_entrada
             , qtde_lote
             ---XML
             , cfop AS cfop_saida
             , cod_cfo AS cfop_entrada
             , cfop_forn AS cfop_saida_forn
             , quantidade
             , quantidade_e
             , vlr_base_icms_e
             , vlr_icms_e
             , aliq_reducao
             , vlr_base_icms_st
             , vlr_icms_st
             , vlr_base_icmsst_ret
             , vlr_icmsst_ret
             , classificacao
             ---PEOPLE ANTECIPACAO
             , aliq_interna
             , vlr_antecip_ist
             , vlr_ant_ist_ttl
             , vlr_antecip_rev
             , vlr_ant_rev_ttl
             , codigo_receita
             , vlr_pmc
             , vlr_mva
             , CASE
                   WHEN metodo_calc_ant = 0
                    AND grupo_produto = 'Medicamentos' THEN
                       'PMC'
                   ELSE
                       TO_CHAR ( metodo_calc_ant )
               END
                   AS metodo_calc_ant
             ---CAMPOS CALCULADOS
             , vlr_icms_calculado
             , vlr_icms_ressarc
             , vlr_icmsst_ressarc
             , vlr_icms_ant_res
             , pct_red_icmsst
          FROM msafi.dpsp_msaf_res_inter_lote
         WHERE cod_empresa = msafi.dpsp.empresa
           AND cod_estab = p_i_cod_estab
           AND grupo_produto = 'Medicamentos'
           AND NVL ( id_lote_saida, '1' ) = DECODE ( p_i_lote, 'S', id_lote_entrada, NVL ( id_lote_saida, '1' ) )
           AND data_fiscal BETWEEN p_i_data_ini AND p_i_data_fim
        UNION ALL
        SELECT cod_empresa
             , cod_estab
             , num_docfis
             , num_controle_docto
             , num_item
             , seqnum
             , cod_produto
             , descr_item
             , cod_ean
             , grupo_produto
             , data_fiscal
             , uf_origem
             , uf_destino
             , cod_fis_jur
             , cnpj
             , razao_social
             , serie_docfis
             , finalidade
             , nbm
             , num_autentic_nfe
             , vlr_unit
             , vlr_item
             , vlr_base_icms
             , vlr_icms
             , aliq_icms
             , qtde_lote_s
             , id_lote_saida
             , data_fabricacao
             , data_validade
             ---ENTRADA
             , cod_estab_e
             , data_fiscal_e
             , movto_e_s
             , norm_dev
             , ident_docto
             , ident_fis_jur
             , num_docfis_e
             , serie_docfis_e
             , sub_serie_docfis
             , discri_item
             , num_item_e
             , cod_fis_jur_e
             , cpf_cgc
             , razao_social_e
             , cod_nbm
             , cod_natureza_op
             , vlr_contab_item
             , vlr_unit_e
             , cod_situacao_b
             , data_emissao
             , cod_estado
             , num_controle_docto_e
             , num_autentic_nfe_e
             , id_lote_entrada
             , qtde_lote
             ---XML
             , cfop AS cfop_saida
             , cod_cfo AS cfop_entrada
             , cfop_forn AS cfop_saida_forn
             , quantidade
             , quantidade_e
             , vlr_base_icms_e
             , vlr_icms_e
             , aliq_reducao
             , vlr_base_icms_st
             , vlr_icms_st
             , vlr_base_icmsst_ret
             , vlr_icmsst_ret
             , classificacao
             ---PEOPLE ANTECIPACAO
             , aliq_interna
             , vlr_antecip_ist
             , vlr_ant_ist_ttl
             , vlr_antecip_rev
             , vlr_ant_rev_ttl
             , codigo_receita
             , vlr_pmc
             , vlr_mva
             , CASE
                   WHEN metodo_calc_ant = 0
                    AND grupo_produto <> 'Medicamentos' THEN
                       'MVA'
                   ELSE
                       TO_CHAR ( metodo_calc_ant )
               END
                   AS metodo_calc_ant
             ---CAMPOS CALCULADOS
             , vlr_icms_calculado
             , vlr_icms_ressarc
             , vlr_icmsst_ressarc
             , vlr_icms_ant_res
             , pct_red_icmsst
          FROM msafi.dpsp_msaf_res_inter_lote
         WHERE cod_empresa = msafi.dpsp.empresa
           AND cod_estab = p_i_cod_estab
           AND grupo_produto <> 'Medicamentos'
           AND data_fiscal BETWEEN p_i_data_ini AND p_i_data_fim;
END dpsp_rel_res_inter_lote_cproc;
/
SHOW ERRORS;
