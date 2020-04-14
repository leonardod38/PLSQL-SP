Prompt Package DPSP_REL_PERDAS_UF_CPROC;
--
-- DPSP_REL_PERDAS_UF_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dpsp_rel_perdas_uf_cproc
IS
    -- AUTOR    : ACCENTURE - REBELLO
    -- DATA     : NOVA VERSAO CRIADA EM 11/OUT/2018
    -- DESCRIÇÃO: NOVO PROCESSAMENTO PARA RELATORIO DE PERDAS - FIN273

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

    FUNCTION executar ( p_data_inicial DATE
                      , p_data_final DATE
                      , p_sintetico VARCHAR2
                      , p_analitico VARCHAR2
                      , p_mapa VARCHAR2
                      , p_uf VARCHAR2
                      , p_lojas lib_proc.vartab )
        RETURN INTEGER;

    CURSOR load_mapa ( p_i_cod_estab IN VARCHAR2
                     , p_i_data_ini IN DATE
                     , p_i_data_fim IN DATE )
    IS
        SELECT   b.cod_empresa
               , b.cod_estado
               , b.cod_estab
               , NVL ( a.qtde_ajustes, 0 ) qtde_ajustes
            FROM (SELECT   cod_empresa
                         , cod_estab
                         , COUNT ( * ) AS qtde_ajustes
                      FROM msafi.dpsp_msaf_perdas_uf
                     WHERE cod_empresa = mcod_empresa
                       AND cod_estab = p_i_cod_estab
                       AND data_inv BETWEEN p_i_data_ini AND p_i_data_fim
                  GROUP BY cod_empresa
                         , cod_estab) a
               , msafi.dsp_estabelecimento b
           WHERE b.cod_empresa = a.cod_empresa(+)
             AND b.cod_estab = a.cod_estab(+)
             AND b.cod_empresa = mcod_empresa
             AND b.cod_estab = p_i_cod_estab
        ORDER BY 2;

    CURSOR load_sintetico ( p_i_cod_estab IN VARCHAR2
                          , p_i_data_ini IN DATE
                          , p_i_data_fim IN DATE )
    IS
        SELECT   b.cod_empresa
               , b.cod_estado
               , b.cod_estab
               , periodo
               , --NVL(A.VLR_PMC, 0)                 VLR_PMC,
                 --NVL(A.VLR_MVA, 0)                 VLR_MVA,
                 --NVL(A.VLR_PMC + A.VLR_MVA, 0)     VLR_TOTAL,
                 NVL ( a.total_icms, 0 ) total_icms
               , NVL ( a.total_icms_st, 0 ) total_icms_st
               , NVL ( a.estorno_pis_s, 0 ) estorno_pis_s
               , NVL ( a.estorno_cofins_s, 0 ) estorno_cofins_s
            FROM (SELECT   cod_empresa
                         , cod_estab
                         , TO_CHAR ( data_inv
                                   , 'MM/YYYY' )
                               periodo
                         , SUM ( total_icms ) total_icms
                         , SUM ( total_icms_st ) total_icms_st
                         , SUM ( estorno_pis_s ) estorno_pis_s
                         , SUM ( estorno_cofins_s ) estorno_cofins_s
                      FROM msafi.dpsp_msaf_perdas_uf
                     WHERE cod_empresa = mcod_empresa
                       AND cod_estab = p_i_cod_estab
                       AND data_inv BETWEEN p_i_data_ini AND p_i_data_fim
                  GROUP BY cod_empresa
                         , cod_estab
                         , TO_CHAR ( data_inv
                                   , 'MM/YYYY' )) a
               , msafi.dsp_estabelecimento b
           WHERE b.cod_empresa = a.cod_empresa(+)
             AND b.cod_estab = a.cod_estab(+)
             AND b.cod_empresa = mcod_empresa
             AND b.cod_estab = p_i_cod_estab
        ORDER BY 2;

    CURSOR load_analitico ( p_i_cod_estab IN VARCHAR2
                          , p_i_data_ini IN DATE
                          , p_i_data_fim IN DATE )
    IS
        SELECT   cod_empresa
               , cod_estab
               , data_inv
               , cod_produto
               , descricao
               , qtd_ajuste
               , cnpj_emitente
               , razao_social_emi
               , ---
                 cod_estab_e
               , data_fiscal_e
               , movto_e_s_e
               , norm_dev_e
               , ident_docto_e
               , ident_fis_jur_e
               , sub_serie_docfis_e
               , discri_item_e
               , data_emissao_e
               , num_docfis_e
               , serie_docfis_e
               , num_item_e
               , cod_fis_jur_e
               , cpf_cgc_e
               , razao_social_e
               , cod_nbm_e
               , cod_cfo_e
               , cod_natureza_op_e
               , cod_produto_e
               , vlr_contab_item_e
               , quantidade_e
               , vlr_unit_e
               , cod_situacao_a_e
               , cod_situacao_b_e
               , cod_estado_e
               , num_controle_docto_e
               , num_autentic_nfe_e
               , base_icms_unit_e
               , vlr_icms_unit_e
               , aliq_icms_e
               , base_st_unit_e
               , vlr_icms_st_unit_e
               , stat_liber_cntr
               , id_aliq_st
               , vlr_pmc
               , total_icms
               , total_icms_st
               , lista_produto
               , cst_pis
               , cst_cofins
               , estorno_pis_e
               , estorno_cofins_e
               , estorno_pis_s
               , estorno_cofins_s
            FROM msafi.dpsp_msaf_perdas_uf
           WHERE cod_empresa = mcod_empresa
             AND cod_estab = p_i_cod_estab
             AND data_inv BETWEEN p_i_data_ini AND p_i_data_fim
        ORDER BY data_inv
               , cod_produto;
END dpsp_rel_perdas_uf_cproc;
/
SHOW ERRORS;
