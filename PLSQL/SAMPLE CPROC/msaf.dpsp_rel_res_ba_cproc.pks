Prompt Package DPSP_REL_RES_BA_CPROC;
--
-- DPSP_REL_RES_BA_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dpsp_rel_res_ba_cproc
IS
    -- AUTOR    : DSP - REBELLO
    -- DATA     : CRIADO EM 15/12/2017
    -- DESCRIÇÃO: Relatorio de Ressarcimento BA - apenas leitura de tabela TEMP no Peoplesoft

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

    FUNCTION executar ( p_oprid VARCHAR2
                      , p_run_cntl_id VARCHAR2 )
        RETURN INTEGER;

    CURSOR load_analitico (
        p_i_oprid IN VARCHAR2
      , p_i_run_cntl_id IN VARCHAR2
    )
    IS
        SELECT /*+DRIVING_SITE(B)*/
              b  .business_unit
               , b.nf_brl_id
               , b.nf_brl_line_num
               , b.seq_num
               , b.tp_pagto_dpsp
               , b.destin_bu
               , b.location
               , b.cnpj_dsp
               , b.dsp_inscr_estad
               , b.ship_from_state
               , b.ship_to_state
               , b.nf_brl
               , b.dsp_nf_brl_series
               , b.nf_brl_date
               , b.inv_item_id
               , b.descr
               , b.qty_nf_brl
               , b.qty_allocated
               , b.dsp_icms_crt_extem
               , b.icmstax_brl_bse
               , b.dsp_icmstax_pct
               , b.dsp_icmstax_amt
               , b.icmssub_brl_bss
               , b.icmssub_brl_bse
               ---
               , b.business_unit_ext
               , b.vendor_id
               , b.name1
               , b.ipi_contrib_brl
               , b.cgc_vendor_brl
               , b.ie_brl
               , b.state_vndr
               , b.state_bu
               , b.nf_brl_ext
               , b.nf_brl_id_ext
               , b.nf_brl_series
               , b.entered_dt
               , b.nf_brl_line_num_ex
               , b.icmstax_brl_bss
               , b.icmstax_brl_pct
               , b.icmstax_brl_amt
               , b.qty
               , b.unit_of_measure
               , b.unit_price
               , b.dsp_price_liq
               , b.dscnt_amt
               , b.dsp_total_liq
               , b.ipitax_brl_pct
               , b.ipitax_brl_amt
               , b.dsp_icmssubbrl_bss
               , b.dsp_icms_bss_st
               , b.dsp_icmssubbrl_amt
               , b.dsp_icms_amt_st
               , b.po_id
               , b.tax_type_brl
               , b.tax_class_brl
               , b.purch_prop_brl
               , b.cfo_brl_cd
               , b.ship_to_cust_id
               , b.nf_brl_status
               , b.dpsp_cfo_brl_cd
               , b.dpsp_tax_class_brl
               , b.dpsp_icms_bss_st
               , b.dpsp_icms_amt_st
               , b.txn_nat_bbl
               , b.nfe_verif_code_pbl
               , b.merchandise_amt
               , b.nfee_key_bbl
               , b.merch_amt_bse
               , b.cfop_incom_pbl
               , b.base_icms_unit
               , b.base_calc_ret
               , b.base_calc_ret_ttl
               , b.vlr_icms_unit
               , b.vlr_destaque
               , b.vlr_compensar
               , b.vlr_ressarc
               , b.icms_st_unit
               , b.icms_st_ttl
            FROM ( SELECT business_unit
                        , nf_brl_id
                        , nf_brl_line_num
                        , seq_num
                        , DECODE ( tp_pagto_dpsp, 'G', 'SUBSTITUTO', 'SUBSTITUIDO' ) AS tp_pagto_dpsp
                        , destin_bu
                        , location
                        , cnpj_dsp
                        , dsp_inscr_estad
                        , ship_from_state
                        , ship_to_state
                        , nf_brl
                        , dsp_nf_brl_series
                        , nf_brl_date
                        , inv_item_id
                        , descr
                        , qty_nf_brl
                        , qty_allocated
                        , dsp_icms_crt_extem
                        , icmstax_brl_bse
                        , dsp_icmstax_pct
                        , dsp_icmstax_amt
                        , icmssub_brl_bss
                        , icmssub_brl_bse
                        ---
                        , business_unit_ext
                        , vendor_id
                        , name1
                        , ipi_contrib_brl
                        , cgc_vendor_brl
                        , ie_brl
                        , state_vndr
                        , state_bu
                        , nf_brl_ext
                        , nf_brl_id_ext
                        , nf_brl_series
                        , entered_dt
                        , nf_brl_line_num_ex
                        , icmstax_brl_bss
                        , icmstax_brl_pct
                        , icmstax_brl_amt
                        , qty
                        , unit_of_measure
                        , unit_price
                        , dsp_price_liq
                        , dscnt_amt
                        , dsp_total_liq
                        , ipitax_brl_pct
                        , ipitax_brl_amt
                        , dsp_icmssubbrl_bss
                        , dsp_icms_bss_st
                        , dsp_icmssubbrl_amt
                        , dsp_icms_amt_st
                        , po_id
                        , tax_type_brl
                        , tax_class_brl
                        , purch_prop_brl
                        , cfo_brl_cd
                        , ship_to_cust_id
                        , nf_brl_status
                        , dpsp_cfo_brl_cd
                        , dpsp_tax_class_brl
                        , dpsp_icms_bss_st
                        , dpsp_icms_amt_st
                        , txn_nat_bbl
                        , nfe_verif_code_pbl
                        , merchandise_amt
                        , nfee_key_bbl
                        , merch_amt_bse
                        , cfop_incom_pbl
                        ---
                        , DECODE ( qty, 0, 0, icmstax_brl_bss / qty ) AS base_icms_unit
                        , DECODE ( qty
                                 , 0, 0
                                 , DECODE ( dsp_icmssubbrl_bss, 0, dsp_icms_bss_st / qty, dsp_icmssubbrl_bss / qty ) )
                              AS base_calc_ret
                        , DECODE ( qty, 0, 0, DECODE ( dsp_icmssubbrl_bss, 0, dsp_icms_bss_st, dsp_icmssubbrl_bss ) )
                              AS base_calc_ret_ttl
                        , DECODE ( qty
                                 , 0, 0
                                 , DECODE ( dsp_icmssubbrl_amt, 0, dsp_icms_amt_st / qty, dsp_icmssubbrl_amt / qty ) )
                              AS icms_st_unit
                        , DECODE ( qty, 0, 0, DECODE ( dsp_icmssubbrl_amt, 0, dsp_icms_amt_st, dsp_icmssubbrl_amt ) )
                              AS icms_st_ttl
                        , DECODE ( qty
                                 , 0, 0
                                 , ROUND ( icmstax_brl_amt / qty
                                         , 2 ) )
                              AS vlr_icms_unit
                        , CASE
                              WHEN ( icmstax_brl_amt > 0
                                AND qty > 0 ) THEN
                                  ROUND ( icmstax_brl_amt / qty
                                        , 2 )
                              ELSE
                                  icmstax_brl_amt
                          END
                              AS vlr_destaque
                        , CASE
                              WHEN ( CASE
                                        WHEN ( icmstax_brl_amt > 0
                                          AND qty > 0 ) THEN
                                            ROUND ( icmstax_brl_amt / qty
                                                  , 2 )
                                        ELSE
                                            icmstax_brl_amt
                                    END ) > 0
                               AND qty_allocated > 0 THEN
                                  ROUND (   ( CASE
                                                 WHEN ( icmstax_brl_amt > 0
                                                   AND qty > 0 ) THEN
                                                     ROUND ( icmstax_brl_amt / qty
                                                           , 2 )
                                                 ELSE
                                                     icmstax_brl_amt
                                             END )
                                          * qty_allocated
                                        , 2 )
                              ELSE
                                  icmstax_brl_amt
                          END
                              AS vlr_compensar
                        ,   ( DECODE (
                                       qty
                                     , 0, 0
                                     , DECODE ( dsp_icmssubbrl_amt, 0, dsp_icms_amt_st / qty, dsp_icmssubbrl_amt / qty )
                             ) )
                          * qty_allocated
                              AS vlr_ressarc
                     FROM msafi.ps_dpsp_cext_b_tmp
                    WHERE oprid = p_i_oprid
                      AND run_cntl_id = p_i_run_cntl_id ) b
        ORDER BY b.nf_brl_date
               , b.inv_item_id;
END dpsp_rel_res_ba_cproc;
/
SHOW ERRORS;
