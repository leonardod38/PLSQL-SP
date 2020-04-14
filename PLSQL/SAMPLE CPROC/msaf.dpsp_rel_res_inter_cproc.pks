Prompt Package DPSP_REL_RES_INTER_CPROC;
--
-- DPSP_REL_RES_INTER_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dpsp_rel_res_inter_cproc
IS
    -------------------------------------------------------------------------
    -- AUTOR    : DSP - REBELLO
    -- DATA     : V1 CRIADA EM 06/MAR/2018
    -- DESCRIÇÃO: Relatório do Ressarcimento Interestadual - Projeto 1007
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
                      , p_sintetico VARCHAR2
                      , p_analitico VARCHAR2
                      , p_cds lib_proc.vartab )
        RETURN INTEGER;

    CURSOR load_analitico ( p_i_cod_estab IN VARCHAR2
                          , p_i_data_ini IN DATE
                          , p_i_data_fim IN DATE )
    IS
        SELECT cod_empresa
             , cod_estab
             , num_docfis
             , num_controle_docto
             , num_item
             , cod_produto
             , descr_item
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
             , cod_nbm
             , cod_natureza_op
             , vlr_contab_item
             , vlr_unit_e
             , cod_situacao_b
             , data_emissao
             , cod_estado
             , num_controle_docto_e
             , num_autentic_nfe_e
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
             , vlr_antecip_rev
             ---CAMPOS CALCULADOS
             , vlr_icms_calculado
             , vlr_icms_ressarc
             , vlr_icmsst_ressarc
             , vlr_icms_ant_res
          FROM msafi.dpsp_msaf_res_inter
         WHERE cod_empresa = msafi.dpsp.empresa
           AND cod_estab = p_i_cod_estab
           AND data_fiscal BETWEEN p_i_data_ini AND p_i_data_fim;
END dpsp_rel_res_inter_cproc;
/
SHOW ERRORS;
