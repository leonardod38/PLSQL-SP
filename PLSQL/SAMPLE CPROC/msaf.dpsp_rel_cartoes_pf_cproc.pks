Prompt Package DPSP_REL_CARTOES_PF_CPROC;
--
-- DPSP_REL_CARTOES_PF_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dpsp_rel_cartoes_pf_cproc
IS
    -- AUTOR    : DSP - REBELLO
    -- DATA     : CRIADO EM 23/11/2017
    -- DESCRIÇÃO: Relatorio de Crédito nas Vendas com Cartão de Crédito

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

    FUNCTION executar ( p_data_ini DATE
                      , p_data_fim DATE
                      , p_sintetico VARCHAR2
                      , p_analitico VARCHAR2
                      , p_conf VARCHAR2
                      , p_lojas lib_proc.vartab )
        RETURN INTEGER;

    CURSOR load_sintetico (
        p_i_cod_estab IN VARCHAR2
      , p_i_data_ini IN DATE
      , p_i_data_fim IN DATE
    )
    IS
        SELECT   a.cod_empresa
               , a.cod_estab
               , a.uf_estab
               ---
               , SUM (
                       ROUND (
                               CASE
                                   WHEN ( a.vlr_icms_unit = 0
                                     AND a.descr_tot = 'ST' )
                                     OR ( a.vlr_icms_st_unit = 0
                                     AND a.descr_tot = 'ST' ) THEN
                                       0
                                   ELSE
                                       CASE
                                           WHEN a.descr_tot = 'ST' THEN
                                               CASE
                                                   WHEN ( a.vlr_base_icms * ( a.taxa_cartao / 100 ) ) >
                                                            a.vlr_pagto_tarifa THEN
                                                         (   a.vlr_icms_st_unit
                                                           - (     ( a.base_st_unit - ( a.vlr_pagto_tarifa ) )
                                                                 * (   TO_NUMBER ( REPLACE ( a.id_aliq_st
                                                                                           , '%'
                                                                                           , '' ) )
                                                                     / 100 )
                                                               - a.vlr_icms_unit ) )
                                                       * a.quantidade --ST
                                                   ELSE
                                                         (   a.vlr_icms_st_unit
                                                           - (     (   a.base_st_unit
                                                                     - ( a.base_st_unit * ( a.taxa_cartao / 100 ) ) )
                                                                 * (   TO_NUMBER ( REPLACE ( a.id_aliq_st
                                                                                           , '%'
                                                                                           , '' ) )
                                                                     / 100 )
                                                               - a.vlr_icms_unit ) )
                                                       * a.quantidade --ST
                                               END
                                           ELSE
                                               CASE
                                                   WHEN ( a.vlr_base_icms * ( a.taxa_cartao / 100 ) ) >
                                                            a.vlr_pagto_tarifa THEN
                                                         a.vlr_icms
                                                       - (   ( a.vlr_base_icms - ( a.vlr_pagto_tarifa ) )
                                                           * ( a.vlr_aliq_icms / 100 ) ) --PROPRIO
                                                   ELSE
                                                         a.vlr_icms
                                                       - (   (   a.vlr_base_icms
                                                               - ( a.vlr_base_icms * ( a.taxa_cartao / 100 ) ) )
                                                           * ( a.vlr_aliq_icms / 100 ) ) --PROPRIO
                                               END
                                       END
                               END
                             , 2
                       )
                 )
                     AS total_credito
            FROM msafi.dpsp_msaf_cartoes_jj a
           WHERE a.cod_empresa = msafi.dpsp.empresa
             AND a.cod_estab = p_i_cod_estab
             AND a.data_fiscal BETWEEN p_i_data_ini AND p_i_data_fim
        GROUP BY a.cod_empresa
               , a.cod_estab
               , a.uf_estab;

    CURSOR load_analitico (
        p_i_cod_estab IN VARCHAR2
      , p_i_data_ini IN DATE
      , p_i_data_fim IN DATE
    )
    IS
        SELECT   a.cod_empresa
               , a.cod_estab
               , a.uf_estab
               , a.docto
               , a.cod_produto
               , a.num_item
               , a.descr_item
               , a.num_docfis
               , a.data_fiscal
               , a.serie_docfis
               , a.quantidade
               , a.cod_nbm
               , a.cod_cfo
               , a.grupo_produto
               , a.vlr_desconto
               , a.vlr_contabil
               , a.num_autentic_nfe
               , a.vlr_base_icms
               , a.vlr_aliq_icms
               , a.vlr_icms
               , a.descr_tot
               , a.autorizadora
               , a.nome_van
               , a.vlr_pago_cartao
               , a.forma_pagto
               , a.num_parcelas
               , a.codigo_aprovacao
               ---
               , a.cod_estab_e
               , a.data_fiscal_e
               , a.movto_e_s_e
               , a.norm_dev_e
               , a.ident_docto_e
               , a.ident_fis_jur_e
               , a.sub_serie_docfis_e
               , a.discri_item_e
               , a.data_emissao_e
               , a.num_docfis_e
               , a.serie_docfis_e
               , a.num_item_e
               , a.cod_fis_jur_e
               , a.cpf_cgc_e
               , a.cod_nbm_e
               , a.cod_cfo_e
               , a.cod_natureza_op_e
               , a.cod_produto_e
               , a.vlr_contab_item_e
               , a.quantidade_e
               , a.vlr_unit_e
               , a.cod_situacao_b_e
               , a.cod_estado_e
               , a.num_controle_docto_e
               , a.num_autentic_nfe_e
               , a.base_icms_unit
               , a.vlr_icms_unit
               , a.aliq_icms
               , a.base_st_unit
               , a.vlr_icms_st_unit
               , a.id_aliq_st
               , a.vlr_icms_st_unit_aux
               , a.stat_liber_cntr
               , a.taxa_cartao
               , a.vlr_pagto_tarifa
               ---
               , CASE
                     WHEN ( a.vlr_icms_unit = 0
                       AND a.descr_tot = 'ST' )
                       OR ( a.vlr_icms_st_unit = 0
                       AND a.descr_tot = 'ST' ) THEN
                         0
                     ELSE
                         CASE
                             WHEN a.descr_tot = 'ST' THEN
                                 CASE
                                     WHEN ( a.base_st_unit * ( a.taxa_cartao / 100 ) ) > a.vlr_pagto_tarifa THEN
                                         a.vlr_pagto_tarifa --ST
                                     ELSE
                                         a.base_st_unit * ( a.taxa_cartao / 100 ) --ST
                                 END
                             ELSE
                                 CASE
                                     WHEN ( a.base_st_unit * ( a.taxa_cartao / 100 ) ) > a.vlr_pagto_tarifa THEN
                                         a.vlr_pagto_tarifa --PROPRIO COL1
                                     ELSE
                                         a.vlr_base_icms * ( a.taxa_cartao / 100 ) --PROPRIO COL1
                                 END
                         END
                 END
                     AS basest_x_cartao
               ---
               , CASE
                     WHEN ( a.vlr_icms_unit = 0
                       AND a.descr_tot = 'ST' )
                       OR ( a.vlr_icms_st_unit = 0
                       AND a.descr_tot = 'ST' ) THEN
                         0
                     ELSE
                         CASE
                             WHEN a.descr_tot = 'ST' THEN
                                 CASE
                                     WHEN ( a.base_st_unit * ( a.taxa_cartao / 100 ) ) > a.vlr_pagto_tarifa THEN
                                         a.base_st_unit - ( a.vlr_pagto_tarifa ) --ST
                                     ELSE
                                         a.base_st_unit - ( a.base_st_unit * ( a.taxa_cartao / 100 ) ) --ST
                                 END
                             ELSE
                                 CASE
                                     WHEN ( a.vlr_base_icms * ( a.taxa_cartao / 100 ) ) > a.vlr_pagto_tarifa THEN
                                         a.vlr_base_icms - ( a.vlr_pagto_tarifa ) --PROPRIO COL2
                                     ELSE
                                         a.vlr_base_icms - ( a.vlr_base_icms * ( a.taxa_cartao / 100 ) ) --PROPRIO COL2
                                 END
                         END
                 END
                     AS nova_base
               ---
               , CASE
                     WHEN ( a.vlr_icms_unit = 0
                       AND a.descr_tot = 'ST' )
                       OR ( a.vlr_icms_st_unit = 0
                       AND a.descr_tot = 'ST' ) THEN
                         0
                     ELSE
                         CASE
                             WHEN a.descr_tot = 'ST' THEN
                                 CASE
                                     WHEN ( a.vlr_base_icms * ( a.taxa_cartao / 100 ) ) > a.vlr_pagto_tarifa THEN
                                             ( a.base_st_unit - ( a.vlr_pagto_tarifa ) )
                                           * (   TO_NUMBER ( REPLACE ( a.id_aliq_st
                                                                     , '%'
                                                                     , '' ) )
                                               / 100 )
                                         - a.vlr_icms_unit --ST
                                     ELSE
                                             ( a.base_st_unit - ( a.base_st_unit * ( a.taxa_cartao / 100 ) ) )
                                           * (   TO_NUMBER ( REPLACE ( a.id_aliq_st
                                                                     , '%'
                                                                     , '' ) )
                                               / 100 )
                                         - a.vlr_icms_unit --ST
                                 END
                             ELSE
                                 CASE
                                     WHEN ( a.vlr_base_icms * ( a.taxa_cartao / 100 ) ) > a.vlr_pagto_tarifa THEN
                                         ( a.vlr_base_icms - ( a.vlr_pagto_tarifa ) ) * ( a.vlr_aliq_icms / 100 ) --PROPRIO COL3
                                     ELSE
                                           ( a.vlr_base_icms - ( a.vlr_base_icms * ( a.taxa_cartao / 100 ) ) )
                                         * ( a.vlr_aliq_icms / 100 ) --PROPRIO COL3
                                 END
                         END
                 END
                     AS novo_imposto
               ---
               , CASE
                     WHEN ( a.vlr_icms_unit = 0
                       AND a.descr_tot = 'ST' )
                       OR ( a.vlr_icms_st_unit = 0
                       AND a.descr_tot = 'ST' ) THEN
                         0
                     ELSE
                         CASE
                             WHEN a.descr_tot = 'ST' THEN
                                 CASE
                                     WHEN ( a.vlr_base_icms * ( a.taxa_cartao / 100 ) ) > a.vlr_pagto_tarifa THEN
                                           a.vlr_icms_st_unit
                                         - (     ( a.base_st_unit - ( a.vlr_pagto_tarifa ) )
                                               * (   TO_NUMBER ( REPLACE ( a.id_aliq_st
                                                                         , '%'
                                                                         , '' ) )
                                                   / 100 )
                                             - a.vlr_icms_unit ) --ST
                                     ELSE
                                           a.vlr_icms_st_unit
                                         - (     ( a.base_st_unit - ( a.base_st_unit * ( a.taxa_cartao / 100 ) ) )
                                               * (   TO_NUMBER ( REPLACE ( a.id_aliq_st
                                                                         , '%'
                                                                         , '' ) )
                                                   / 100 )
                                             - a.vlr_icms_unit ) --ST
                                 END
                             ELSE
                                 0 --NORMAL
                         END
                 END
                     AS dif_st_x_novo
               ---
               , CASE
                     WHEN ( a.vlr_icms_unit = 0
                       AND a.descr_tot = 'ST' )
                       OR ( a.vlr_icms_st_unit = 0
                       AND a.descr_tot = 'ST' ) THEN
                         0
                     ELSE
                         CASE
                             WHEN a.descr_tot = 'ST' THEN
                                 CASE
                                     WHEN ( a.vlr_base_icms * ( a.taxa_cartao / 100 ) ) > a.vlr_pagto_tarifa THEN
                                           (   a.vlr_icms_st_unit
                                             - (     ( a.base_st_unit - ( a.vlr_pagto_tarifa ) )
                                                   * (   TO_NUMBER ( REPLACE ( a.id_aliq_st
                                                                             , '%'
                                                                             , '' ) )
                                                       / 100 )
                                                 - a.vlr_icms_unit ) )
                                         * a.quantidade --ST
                                     ELSE
                                           (   a.vlr_icms_st_unit
                                             - (     ( a.base_st_unit - ( a.base_st_unit * ( a.taxa_cartao / 100 ) ) )
                                                   * (   TO_NUMBER ( REPLACE ( a.id_aliq_st
                                                                             , '%'
                                                                             , '' ) )
                                                       / 100 )
                                                 - a.vlr_icms_unit ) )
                                         * a.quantidade --ST
                                 END
                             ELSE
                                 CASE
                                     WHEN ( a.vlr_base_icms * ( a.taxa_cartao / 100 ) ) > a.vlr_pagto_tarifa THEN
                                           a.vlr_icms
                                         - ( ( a.vlr_base_icms - ( a.vlr_pagto_tarifa ) ) * ( a.vlr_aliq_icms / 100 ) ) --PROPRIO
                                     ELSE
                                           a.vlr_icms
                                         - (   ( a.vlr_base_icms - ( a.vlr_base_icms * ( a.taxa_cartao / 100 ) ) )
                                             * ( a.vlr_aliq_icms / 100 ) ) --PROPRIO
                                 END
                         END
                 END
                     AS total_credito
            FROM msafi.dpsp_msaf_cartoes_jj a
           WHERE a.cod_empresa = msafi.dpsp.empresa
             AND a.cod_estab = p_i_cod_estab
             AND a.data_fiscal BETWEEN p_i_data_ini AND p_i_data_fim
        ORDER BY a.data_fiscal
               , a.cod_produto;
END dpsp_rel_cartoes_pf_cproc;
/
SHOW ERRORS;
