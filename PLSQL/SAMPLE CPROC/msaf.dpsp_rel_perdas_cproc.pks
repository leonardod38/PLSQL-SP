Prompt Package DPSP_REL_PERDAS_CPROC;
--
-- DPSP_REL_PERDAS_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dpsp_rel_perdas_cproc
IS
    -- AUTOR    : DSP - REBELLO
    -- DATA     : CRIADO EM 26/JUL/2017
    -- DESCRIÇÃO: Relatorio de Perdas

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

    FUNCTION executar ( p_periodo DATE
                      , p_sintetico VARCHAR2
                      , p_analitico VARCHAR2
                      , p_lojas lib_proc.vartab )
        RETURN INTEGER;

    CURSOR load_sintetico ( p_i_cod_estab IN VARCHAR2
                          , p_i_data_ini IN DATE
                          , p_i_data_fim IN DATE )
    IS
        SELECT   b.cod_empresa
               , b.cod_estab
               , NVL ( a.vlr_pmc, 0 ) vlr_pmc
               , NVL ( a.vlr_mva, 0 ) vlr_mva
               , NVL ( a.vlr_pmc + a.vlr_mva, 0 ) vlr_total
            FROM (SELECT   cod_empresa
                         , cod_estab
                         , SUM ( CASE WHEN vlr_pmc = 0 THEN vlr_dif_qtde ELSE 0 END ) vlr_pmc
                         , SUM ( CASE WHEN vlr_pmc <> 0 THEN vlr_dif_qtde ELSE 0 END ) vlr_mva
                      FROM msafi.dpsp_msaf_perdas
                     WHERE cod_empresa = mcod_empresa
                       AND cod_estab = p_i_cod_estab
                       AND data_inv BETWEEN p_i_data_ini AND p_i_data_fim
                       AND deb_cred = 'CRÉDITO'
                  GROUP BY cod_empresa
                         , cod_estab) a
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
               , cod_produto
               , data_inv
               , qtd_saldo
               , qtd_contagem
               , qtd_ajuste
               , vlr_custo
               ---
               , cod_estab_e
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
               , cod_nbm_e
               , cod_cfo_e
               , cod_natureza_op_e
               , cod_produto_e
               , vlr_contab_item_e
               , quantidade_e
               , vlr_unit_e
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
               , vlr_icms_aux
               , vlr_icms_bruto
               , vlr_icms_s_venda
               , vlr_dif_qtde
               , deb_cred
               , usuario
               , dat_operacao
               , vlr_icms_st_unit_aux
            FROM msafi.dpsp_msaf_perdas
           WHERE cod_empresa = mcod_empresa
             AND cod_estab = p_i_cod_estab
             AND data_inv BETWEEN p_i_data_ini AND p_i_data_fim
        ORDER BY data_inv
               , cod_produto;
END dpsp_rel_perdas_cproc;
/
SHOW ERRORS;
