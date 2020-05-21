Prompt Package Body DPSP_FIN048_RET_ENTRADA_CPROC;
--
-- DPSP_FIN048_RET_ENTRADA_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_fin048_ret_entrada_cproc
IS
    mproc_id NUMBER;
    vn_linha NUMBER := 0;
    vn_pagina NUMBER := 0;
    mnm_usuario usuario_estab.cod_usuario%TYPE := lib_parametros.recuperar ( 'USUARIO' );
    mcod_empresa estabelecimento.cod_empresa%TYPE;
    vs_mlinha VARCHAR2 ( 4000 );

    --V_TAB_ENTRADA_C   VARCHAR2(255) := 'MSAFI.DPSP_FIN048_RET_NF_ENT';
    v_data_hora_ini VARCHAR2 ( 20 )
        := TO_CHAR ( SYSDATE
                   , 'DD/MM/YYYY HH24:MI.SS' );
    --  V_TABELA_XML      VARCHAR2(30);
    --  V_TABELA_XML_DPSP VARCHAR2(30);

    --TIPO, NOME E DESCRIÇÃO DO CUSTOMIZADO
    --MELHORIA FIN048
    mnm_tipo VARCHAR2 ( 100 ) := 'Retificação ICMS ES';
    mnm_cproc VARCHAR2 ( 100 ) := '1. Relatório De Notas Fiscais De Entrada Para Retificacao Apuração Icms (ES)';
    mds_cproc VARCHAR2 ( 100 ) := 'Processo Para Ajuste De Notas De Entrada';

    v_sql VARCHAR2 ( 30000 );

    PROCEDURE prc_upd_nf_entrada ( pdt_ini DATE
                                 , pdt_fim DATE
                                 , pcod_estab VARCHAR2
                                 , v_data_hora_ini VARCHAR2 )
    IS
        i NUMBER;

        TYPE x07_docto_fiscal_tp IS TABLE OF msafi.x07_docto_fiscal_gtt%ROWTYPE;

        x07_docto_fiscal_typ x07_docto_fiscal_tp := x07_docto_fiscal_tp ( );

        TYPE x08_itens_merc_gtt_tp IS TABLE OF msafi.x08_itens_merc_gtt%ROWTYPE;

        x08_itens_merc_typ x08_itens_merc_gtt_tp := x08_itens_merc_gtt_tp ( );

        forall_failed EXCEPTION;
        PRAGMA EXCEPTION_INIT ( forall_failed
                              , -24381 );

        err_num NUMBER;
        err_msg VARCHAR2 ( 100 );
        l_error NUMBER;
        l_errors NUMBER;
        l_errno NUMBER;
        l_msg VARCHAR2 ( 4000 );
        l_idx NUMBER;

        log_x07_type msafi.x07_docto_fiscal_log%ROWTYPE;
        l_cfop_saida_origem msafi.x07_docto_fiscal_gtt.cfop_saida_origem%TYPE;
        l_ident_natureza_op NUMBER;
        l_ident_cfo NUMBER;
        l_ident_situacao_b NUMBER;

        l_cod_produto x2013_produto.cod_produto%TYPE;
        --    L_IDENT_PRODUTO   X2013_PRODUTO.IDENT_PRODUTO%TYPE;

        x08b_type x08_base_merc%ROWTYPE;
    BEGIN
        EXECUTE IMMEDIATE 'delete  msafi.X07_DOCTO_FISCAL_GTT';

        EXECUTE IMMEDIATE 'delete  msafi.X08_ITENS_MERC_GTT';

        BEGIN
            SELECT   x07.cod_empresa
                   , x07.cod_estab
                   , x07.data_fiscal
                   , x07.movto_e_s
                   , x07.norm_dev
                   , x07.ident_docto
                   , x07.ident_fis_jur
                   , x07.num_docfis
                   , x07.serie_docfis
                   , x07.sub_serie_docfis
                   , fin048_ret.num_item
                   , x07.ROWID rowid_x07
                   , fin048_ret.valor_aliquota_origem
                   , fin048_ret.valor_base_icms_origem
                   , fin048_ret.valor_icms_origem
                   , fin048_ret.vlr_item fin48_vlr_item
                   , fin048_ret.vlr_base_icms_3
                   , fin048_ret.vlr_base_icms_2
                   , fin048_ret.vlr_base_icms_1
                   , fin048_ret.cfop_saida_origem
                   , fin048_ret.cst_origem
                   , fin048_ret.ROWID f_rowid
                BULK COLLECT INTO x07_docto_fiscal_typ
                FROM msafi.dpsp_fin048_ret_nf_ent fin048_ret
                   , x07_docto_fiscal x07
               WHERE fin048_ret.data_fiscal BETWEEN pdt_ini AND pdt_fim
                 --  AND   FIN048_RET.NUM_DOCFIS  = '000094105'
                 AND fin048_ret.cod_estab = pcod_estab
                 AND fin048_ret.cod_empresa = 'DP'
                 AND fin048_ret.cod_empresa = x07.cod_empresa
                 AND fin048_ret.cod_estab = x07.cod_estab
                 AND fin048_ret.num_docfis = x07.num_docfis
                 AND fin048_ret.data_fiscal = x07.data_fiscal
                 AND fin048_ret.num_controle_docto = x07.num_controle_docto
                 AND fin048_ret.num_autentic_nfe = x07.num_autentic_nfe
                 AND x07.data_fiscal BETWEEN pdt_ini AND pdt_fim
                 AND x07.cod_estab = pcod_estab
                 AND x07.cod_empresa = 'DP'
            GROUP BY x07.cod_empresa
                   , x07.cod_estab
                   , x07.data_fiscal
                   , x07.movto_e_s
                   , x07.norm_dev
                   , x07.ident_docto
                   , x07.ident_fis_jur
                   , x07.num_docfis
                   , x07.serie_docfis
                   , x07.sub_serie_docfis
                   , fin048_ret.num_item
                   , x07.ROWID
                   , fin048_ret.valor_aliquota_origem
                   , fin048_ret.valor_base_icms_origem
                   , fin048_ret.valor_icms_origem
                   , fin048_ret.vlr_item
                   , fin048_ret.vlr_base_icms_3
                   , fin048_ret.vlr_base_icms_2
                   , fin048_ret.vlr_base_icms_1
                   , fin048_ret.cfop_saida_origem
                   , fin048_ret.cst_origem
                   , fin048_ret.ROWID;

            FORALL ix7 IN x07_docto_fiscal_typ.FIRST .. x07_docto_fiscal_typ.LAST SAVE EXCEPTIONS
                INSERT INTO msafi.x07_docto_fiscal_gtt
                VALUES x07_docto_fiscal_typ ( ix7 );

            SELECT x08.cod_empresa
                 , x08.cod_estab
                 , x08.data_fiscal
                 , x08.movto_e_s
                 , x08.norm_dev
                 , x08.ident_docto
                 , x08.ident_fis_jur
                 , x08.num_docfis
                 , x08.serie_docfis
                 , x08.sub_serie_docfis
                 , x08.discri_item
                 , x08.ident_produto
                 , x08.ident_und_padrao
                 , x08.cod_bem
                 , x08.cod_inc_bem
                 , x08.valid_bem
                 , x08.num_item
                 , x08.ident_almox
                 , x08.ident_custo
                 , x08.descricao_compl
                 , x08.ident_cfo
                 , x08.ident_natureza_op
                 , x08.ident_nbm
                 , x08.quantidade
                 , x08.ident_medida
                 , x08.vlr_unit
                 , x08.vlr_item
                 , x08.vlr_desconto
                 , x08.vlr_frete
                 , x08.vlr_seguro
                 , x08.vlr_outras
                 , x08.ident_situacao_a
                 , x08.ident_situacao_b
                 , x08.ident_federal
                 , x08.ind_ipi_incluso
                 , x08.num_romaneio
                 , x08.data_romaneio
                 , x08.peso_liquido
                 , x08.cod_indice
                 , x08.vlr_item_conver
                 , x08.num_processo
                 , x08.ind_gravacao
                 , x08.vlr_contab_compl
                 , x08.vlr_aliq_destino
                 , x08.vlr_outros1
                 , x08.vlr_outros2
                 , x08.vlr_outros3
                 , x08.vlr_outros4
                 , x08.vlr_outros5
                 , x08.vlr_aliq_outros1
                 , x08.vlr_aliq_outros2
                 , x08.vlr_contab_item
                 , x08.cod_obs_vcont_comp
                 , x08.cod_obs_vcont_item
                 , x08.vlr_outros_icms
                 , x08.vlr_outros_ipi
                 , x08.ind_resp_vcont_itm
                 , x08.num_ato_conces
                 , x08.dat_embarque
                 , x08.num_reg_exp
                 , x08.num_desp_exp
                 , x08.vlr_tom_servico
                 , x08.vlr_desp_moeda_exp
                 , x08.cod_moeda_negoc
                 , x08.cod_pais_dest_orig
                 , x08.cod_trib_int
                 , x08.vlr_icms_ndestac
                 , x08.vlr_ipi_ndestac
                 , x08.vlr_base_pis
                 , x08.vlr_pis
                 , x08.vlr_base_cofins
                 , x08.vlr_cofins
                 , x08.base_icms_origdest
                 , x08.vlr_icms_origdest
                 , x08.aliq_icms_origdest
                 , x08.vlr_desc_condic
                 , x08.vlr_custo_transf
                 , x08.perc_red_base_icms
                 , x08.qtd_embarcada
                 , x08.dat_registro_exp
                 , x08.dat_despacho
                 , x08.dat_averbacao
                 , x08.dat_di
                 , x08.num_dec_imp_ref
                 , x08.dsc_mot_ocor
                 , x08.ident_conta
                 , x08.vlr_base_icms_orig
                 , x08.vlr_trib_icms_orig
                 , x08.vlr_base_icms_dest
                 , x08.vlr_trib_icms_dest
                 , x08.vlr_perc_pres_icms
                 , x08.vlr_preco_base_st
                 , x08.ident_oper_oil
                 , x08.cod_dcr
                 , x08.ident_projeto
                 , x08.dat_operacao
                 , x08.usuario
                 , x08.ind_mov_fis
                 , x08.chassi
                 , x08.num_docfis_ref
                 , x08.serie_docfis_ref
                 , x08.sserie_docfis_ref
                 , x08.vlr_base_pis_st
                 , x08.vlr_aliq_pis_st
                 , x08.vlr_pis_st
                 , x08.vlr_base_cofins_st
                 , x08.vlr_aliq_cofins_st
                 , x08.vlr_cofins_st
                 , x08.vlr_base_csll
                 , x08.vlr_aliq_csll
                 , x08.vlr_csll
                 , x08.vlr_aliq_pis
                 , x08.vlr_aliq_cofins
                 , x08.ind_situacao_esp_st
                 , x08.vlr_icmss_ndestac
                 , x08.ind_docto_rec
                 , x08.dat_pgto_gnre_darj
                 , x08.vlr_custo_unit
                 , x08.vlr_fator_conv
                 , x08.quantidade_conv
                 , x08.vlr_fecp_icms
                 , x08.vlr_fecp_difaliq
                 , x08.vlr_fecp_icms_st
                 , x08.vlr_fecp_fonte
                 , x08.vlr_base_icmss_n_escrit
                 , x08.vlr_icmss_n_escrit
                 , x08.vlr_ajuste_cond_pg
                 , x08.cod_trib_ipi
                 , x08.lote_medicamento
                 , x08.valid_medicamento
                 , x08.ind_base_medicamento
                 , x08.vlr_preco_medicamento
                 , x08.ind_tipo_arma
                 , x08.num_serie_arma
                 , x08.num_cano_arma
                 , x08.dsc_arma
                 , x08.ident_observacao
                 , x08.cod_ex_ncm
                 , x08.cod_ex_imp
                 , x08.cnpj_operadora
                 , x08.cpf_operadora
                 , x08.ident_uf_operadora
                 , x08.ins_est_operadora
                 , x08.ind_especif_receita
                 , x08.cod_class_item
                 , x08.vlr_terceiros
                 , x08.vlr_preco_suger
                 , x08.vlr_base_cide
                 , x08.vlr_aliq_cide
                 , x08.vlr_cide
                 , x08.cod_oper_esp_st
                 , x08.vlr_comissao
                 , x08.vlr_icms_frete
                 , x08.vlr_difal_frete
                 , x08.ind_vlr_pis_cofins
                 , x08.cod_enquad_ipi
                 , x08.cod_situacao_pis
                 , x08.qtd_base_pis
                 , x08.vlr_aliq_pis_r
                 , x08.cod_situacao_cofins
                 , x08.qtd_base_cofins
                 , x08.vlr_aliq_cofins_r
                 , x08.item_port_tare
                 , x08.vlr_funrural
                 , x08.ind_tp_prod_medic
                 , x08.vlr_custo_dca
                 , x08.cod_tp_lancto
                 , x08.vlr_perc_cred_out
                 , x08.vlr_cred_out
                 , x08.vlr_icms_dca
                 , x08.vlr_pis_exp
                 , x08.vlr_pis_trib
                 , x08.vlr_pis_n_trib
                 , x08.vlr_cofins_exp
                 , x08.vlr_cofins_trib
                 , x08.vlr_cofins_n_trib
                 , x08.cod_enq_legal
                 , x08.ind_gravacao_saics
                 , x08.dat_lanc_pis_cofins
                 , x08.ind_pis_cofins_extemp
                 , x08.ind_natureza_frete
                 , x08.cod_nat_rec
                 , x08.ind_nat_base_cred
                 , x08.vlr_acrescimo
                 , x08.dsc_reservado1
                 , x08.dsc_reservado2
                 , x08.dsc_reservado3
                 , x08.cod_trib_prod
                 , x08.dsc_reservado4
                 , x08.dsc_reservado5
                 , x08.dsc_reservado6
                 , x08.dsc_reservado7
                 , x08.dsc_reservado8
                 , x08.indice_prod_acab
                 , x08.vlr_base_dia_am
                 , x08.vlr_aliq_dia_am
                 , x08.vlr_icms_dia_am
                 , x08.vlr_aduaneiro
                 , x08.cod_situacao_pis_st
                 , x08.cod_situacao_cofins_st
                 , x08.vlr_aliq_dcip
                 , x08.num_li
                 , x08.vlr_fcp_uf_dest
                 , x08.vlr_icms_uf_dest
                 , x08.vlr_icms_uf_orig
                 , x08.vlr_dif_dub
                 , x08.vlr_icms_nao_dest
                 , x08.vlr_base_icms_nao_dest
                 , x08.vlr_aliq_icms_nao_dest
                 , x08.ind_motivo_res
                 , x08.num_docfis_ret
                 , x08.serie_docfis_ret
                 , x08.num_autentic_nfe_ret
                 , x08.num_item_ret
                 , x08.ident_fis_jur_ret
                 , x08.ind_tp_doc_arrec
                 , x08.num_doc_arrec
                 , x08.ident_cfo_dcip
                 , x08.vlr_base_inss
                 , x08.vlr_inss_retido
                 , x08.vlr_tot_adic
                 , x08.vlr_n_ret_princ
                 , x08.vlr_n_ret_adic
                 , x08.vlr_aliq_inss
                 , x08.vlr_ret_serv
                 , x08.vlr_serv_15
                 , x08.vlr_serv_20
                 , x08.vlr_serv_25
                 , x08.ind_tp_proc_adj_princ
                 , x08.ident_proc_adj_princ
                 , x08.ident_susp_tbt_princ
                 , x08.num_proc_adj_princ
                 , x08.ind_tp_proc_adj_adic
                 , x08.ident_proc_adj_adic
                 , x08.ident_susp_tbt_adic
                 , x08.num_proc_adj_adic
                 , x08.vlr_ipi_dev
                 , x08.cod_beneficio
                 , x08.vlr_abat_ntributado
              BULK COLLECT INTO x08_itens_merc_typ
              FROM x08_itens_merc x08
                 , msafi.x07_docto_fiscal_gtt x07_gtt
             WHERE x08.cod_empresa = x07_gtt.cod_empresa
               AND x08.cod_estab = x07_gtt.cod_estab
               AND x08.data_fiscal = x07_gtt.data_fiscal
               AND x08.movto_e_s = x07_gtt.movto_e_s
               AND x08.norm_dev = x07_gtt.norm_dev
               AND x08.ident_docto = x07_gtt.ident_docto
               AND x08.ident_fis_jur = x07_gtt.ident_fis_jur
               AND x08.num_docfis = x07_gtt.num_docfis
               AND x08.serie_docfis = x07_gtt.serie_docfis
               AND x08.sub_serie_docfis = x07_gtt.sub_serie_docfis
               AND x08.num_item = x07_gtt.num_item;

            loga ( 'Recupera itens_merc' || SQL%ROWCOUNT );

            FOR j IN x08_itens_merc_typ.FIRST .. x08_itens_merc_typ.LAST LOOP
                BEGIN
                    ---  base trib  merc
                    DECLARE
                        x08t_type x08_trib_merc%ROWTYPE;
                    BEGIN
                        SELECT *
                          INTO x08t_type
                          FROM x08_trib_merc
                         WHERE cod_empresa = x08_itens_merc_typ ( j ).cod_empresa
                           AND cod_estab = x08_itens_merc_typ ( j ).cod_estab
                           AND data_fiscal = x08_itens_merc_typ ( j ).data_fiscal
                           AND movto_e_s = x08_itens_merc_typ ( j ).movto_e_s
                           AND norm_dev = x08_itens_merc_typ ( j ).norm_dev
                           AND ident_docto = x08_itens_merc_typ ( j ).ident_docto
                           AND ident_fis_jur = x08_itens_merc_typ ( j ).ident_fis_jur
                           AND num_docfis = x08_itens_merc_typ ( j ).num_docfis
                           AND serie_docfis = x08_itens_merc_typ ( j ).serie_docfis
                           AND sub_serie_docfis = x08_itens_merc_typ ( j ).sub_serie_docfis
                           AND discri_item = x08_itens_merc_typ ( j ).discri_item
                           AND cod_tributo = 'ICMS';

                        loga (
                                  'Recupera itens_trib:'
                               || x08t_type.cod_tributo
                               || ';'
                               || x08_itens_merc_typ ( j ).cod_empresa
                               || ';'
                               || x08_itens_merc_typ ( j ).cod_estab
                               || ';'
                               || x08_itens_merc_typ ( j ).data_fiscal
                               || ';'
                               || x08_itens_merc_typ ( j ).movto_e_s
                               || ';'
                               || x08_itens_merc_typ ( j ).norm_dev
                               || ';'
                               || x08_itens_merc_typ ( j ).ident_docto
                               || ';'
                               || x08_itens_merc_typ ( j ).ident_fis_jur
                               || ';'
                               || x08_itens_merc_typ ( j ).num_docfis
                               || ';'
                               || x08_itens_merc_typ ( j ).serie_docfis
                               || ';'
                               || x08_itens_merc_typ ( j ).sub_serie_docfis
                               || ';'
                               || x08_itens_merc_typ ( j ).discri_item
                        );

                        IF x08t_type.cod_tributo = 'ICMS' THEN
                            BEGIN
                                --

                                DELETE x08_base_merc
                                 WHERE cod_empresa = x08_itens_merc_typ ( j ).cod_empresa
                                   AND cod_estab = x08_itens_merc_typ ( j ).cod_estab
                                   AND data_fiscal = x08_itens_merc_typ ( j ).data_fiscal
                                   AND movto_e_s = x08_itens_merc_typ ( j ).movto_e_s
                                   AND norm_dev = x08_itens_merc_typ ( j ).norm_dev
                                   AND ident_docto = x08_itens_merc_typ ( j ).ident_docto
                                   AND ident_fis_jur = x08_itens_merc_typ ( j ).ident_fis_jur
                                   AND num_docfis = x08_itens_merc_typ ( j ).num_docfis
                                   AND serie_docfis = x08_itens_merc_typ ( j ).serie_docfis
                                   AND sub_serie_docfis = x08_itens_merc_typ ( j ).sub_serie_docfis
                                   AND discri_item = x08_itens_merc_typ ( j ).discri_item
                                   AND cod_tributo = 'ICMS';

                                loga ( 'Recupera itens_trib delete' || SQL%ROWCOUNT );

                                DELETE x08_trib_merc
                                 WHERE cod_empresa = x08_itens_merc_typ ( j ).cod_empresa
                                   AND cod_estab = x08_itens_merc_typ ( j ).cod_estab
                                   AND data_fiscal = x08_itens_merc_typ ( j ).data_fiscal
                                   AND movto_e_s = x08_itens_merc_typ ( j ).movto_e_s
                                   AND norm_dev = x08_itens_merc_typ ( j ).norm_dev
                                   AND ident_docto = x08_itens_merc_typ ( j ).ident_docto
                                   AND ident_fis_jur = x08_itens_merc_typ ( j ).ident_fis_jur
                                   AND num_docfis = x08_itens_merc_typ ( j ).num_docfis
                                   AND serie_docfis = x08_itens_merc_typ ( j ).serie_docfis
                                   AND sub_serie_docfis = x08_itens_merc_typ ( j ).sub_serie_docfis
                                   AND discri_item = x08_itens_merc_typ ( j ).discri_item
                                   AND cod_tributo = 'ICMS';

                                loga ( 'Recupera itens_trib delete' || SQL%ROWCOUNT );
                            EXCEPTION
                                WHEN OTHERS THEN
                                    err_num := SQLCODE;
                                    err_msg :=
                                        SUBSTR ( SQLERRM
                                               , 1
                                               , 100 );
                                    log_x07_type.log_fin48 :=
                                        'ERROR :BLOCO 245 | DELETE ' || err_num || ' - ' || err_msg;

                                    INSERT INTO msafi.x07_docto_fiscal_log
                                    VALUES log_x07_type;
                            END;
                        END IF;

                        BEGIN
                            SELECT x07_gtt.valor_aliquota_origem
                                 , x07_gtt.valor_icms_origem
                              INTO x08t_type.aliq_tributo
                                 , x08t_type.vlr_tributo
                              FROM msafi.x07_docto_fiscal_gtt x07_gtt
                             WHERE cod_empresa = x08_itens_merc_typ ( j ).cod_empresa
                               AND cod_estab = x08_itens_merc_typ ( j ).cod_estab
                               AND data_fiscal = x08_itens_merc_typ ( j ).data_fiscal
                               AND movto_e_s = x08_itens_merc_typ ( j ).movto_e_s
                               AND norm_dev = x08_itens_merc_typ ( j ).norm_dev
                               AND ident_docto = x08_itens_merc_typ ( j ).ident_docto
                               AND ident_fis_jur = x08_itens_merc_typ ( j ).ident_fis_jur
                               AND num_docfis = x08_itens_merc_typ ( j ).num_docfis
                               AND serie_docfis = x08_itens_merc_typ ( j ).serie_docfis
                               AND sub_serie_docfis = x08_itens_merc_typ ( j ).sub_serie_docfis
                               AND num_item = x08_itens_merc_typ ( j ).num_item;
                        EXCEPTION
                            WHEN OTHERS THEN
                                err_num := SQLCODE;
                                err_msg :=
                                    SUBSTR ( SQLERRM
                                           , 1
                                           , 100 );
                                log_x07_type.log_fin48 :=
                                    'ERROR :BLOCO 276 | INTO X08T_TYPE ' || err_num || ' - ' || err_msg;

                                INSERT INTO msafi.x07_docto_fiscal_log
                                VALUES log_x07_type;
                        END;

                        ---  insert  trib
                        BEGIN
                            INSERT INTO x08_trib_merc
                            VALUES x08t_type;

                            loga ( 'Recupera itens_trib insert' || SQL%ROWCOUNT );
                        EXCEPTION
                            WHEN OTHERS THEN
                                err_num := SQLCODE;
                                err_msg :=
                                    SUBSTR ( SQLERRM
                                           , 1
                                           , 100 );
                                log_x07_type.log_fin48 := 'ERROR :BLOCO 293 | INSERT ' || err_num || ' - ' || err_msg;

                                INSERT INTO msafi.x07_docto_fiscal_log
                                VALUES log_x07_type;
                        END;
                    END;

                    --  AJUSTES NA BASE DO ICMS -  X08_BASE_MERC
                    --  DECLARE
                    ---    X08B_TYPE         X08_BASE_MERC%ROWTYPE;

                    BEGIN
                        loga ( 'Recupera itens_base' || SQL%ROWCOUNT );

                        SELECT x07_gtt.valor_base_icms_origem
                          INTO x08b_type.vlr_base
                          FROM msafi.x07_docto_fiscal_gtt x07_gtt
                         WHERE cod_empresa = x08_itens_merc_typ ( j ).cod_empresa
                           AND cod_estab = x08_itens_merc_typ ( j ).cod_estab
                           AND data_fiscal = x08_itens_merc_typ ( j ).data_fiscal
                           AND movto_e_s = x08_itens_merc_typ ( j ).movto_e_s
                           AND norm_dev = x08_itens_merc_typ ( j ).norm_dev
                           AND ident_docto = x08_itens_merc_typ ( j ).ident_docto
                           AND ident_fis_jur = x08_itens_merc_typ ( j ).ident_fis_jur
                           AND num_docfis = x08_itens_merc_typ ( j ).num_docfis
                           AND serie_docfis = x08_itens_merc_typ ( j ).serie_docfis
                           AND sub_serie_docfis = x08_itens_merc_typ ( j ).sub_serie_docfis
                           AND num_item = x08_itens_merc_typ ( j ).num_item;

                        x08b_type.cod_empresa := x08_itens_merc_typ ( j ).cod_empresa;
                        x08b_type.cod_estab := x08_itens_merc_typ ( j ).cod_estab;
                        x08b_type.data_fiscal := x08_itens_merc_typ ( j ).data_fiscal;
                        x08b_type.movto_e_s := x08_itens_merc_typ ( j ).movto_e_s;
                        x08b_type.norm_dev := x08_itens_merc_typ ( j ).norm_dev;
                        x08b_type.ident_docto := x08_itens_merc_typ ( j ).ident_docto;
                        x08b_type.ident_fis_jur := x08_itens_merc_typ ( j ).ident_fis_jur;
                        x08b_type.num_docfis := x08_itens_merc_typ ( j ).num_docfis;
                        x08b_type.serie_docfis := x08_itens_merc_typ ( j ).serie_docfis;
                        x08b_type.sub_serie_docfis := x08_itens_merc_typ ( j ).sub_serie_docfis;
                        x08b_type.discri_item := x08_itens_merc_typ ( j ).discri_item;
                        x08b_type.cod_tributo := 'ICMS';
                        x08b_type.cod_tributacao := 1;

                        INSERT INTO x08_base_merc
                        VALUES x08b_type;
                    EXCEPTION
                        WHEN OTHERS THEN
                            err_num := SQLCODE;
                            err_msg :=
                                SUBSTR ( SQLERRM
                                       , 1
                                       , 100 );
                            log_x07_type.log_fin48 := 'ERROR :BLOCO 195 | DELETE ' || err_num || ' - ' || err_msg;

                            --  INSERT
                            INSERT INTO msafi.x07_docto_fiscal_log
                            VALUES log_x07_type;
                    END;

                    BEGIN
                        IF x08b_type.cod_tributacao = 2 THEN
                            UPDATE x08_base_merc
                               SET cod_tributacao = 1
                             WHERE cod_empresa = x08_itens_merc_typ ( j ).cod_empresa
                               AND cod_estab = x08_itens_merc_typ ( j ).cod_estab
                               AND data_fiscal = x08_itens_merc_typ ( j ).data_fiscal
                               AND movto_e_s = x08_itens_merc_typ ( j ).movto_e_s
                               AND norm_dev = x08_itens_merc_typ ( j ).norm_dev
                               AND ident_docto = x08_itens_merc_typ ( j ).ident_docto
                               AND ident_fis_jur = x08_itens_merc_typ ( j ).ident_fis_jur
                               AND num_docfis = x08_itens_merc_typ ( j ).num_docfis
                               AND serie_docfis = x08_itens_merc_typ ( j ).serie_docfis
                               AND sub_serie_docfis = x08_itens_merc_typ ( j ).sub_serie_docfis
                               AND discri_item = x08_itens_merc_typ ( j ).discri_item
                               AND cod_tributo = 'ICMS'
                               AND cod_tributacao = 2;
                        ELSIF x08b_type.cod_tributacao = 3 THEN
                            UPDATE x08_base_merc
                               SET cod_tributacao = 1
                             WHERE cod_empresa = x08_itens_merc_typ ( j ).cod_empresa
                               AND cod_estab = x08_itens_merc_typ ( j ).cod_estab
                               AND data_fiscal = x08_itens_merc_typ ( j ).data_fiscal
                               AND movto_e_s = x08_itens_merc_typ ( j ).movto_e_s
                               AND norm_dev = x08_itens_merc_typ ( j ).norm_dev
                               AND ident_docto = x08_itens_merc_typ ( j ).ident_docto
                               AND ident_fis_jur = x08_itens_merc_typ ( j ).ident_fis_jur
                               AND num_docfis = x08_itens_merc_typ ( j ).num_docfis
                               AND serie_docfis = x08_itens_merc_typ ( j ).serie_docfis
                               AND sub_serie_docfis = x08_itens_merc_typ ( j ).sub_serie_docfis
                               AND discri_item = x08_itens_merc_typ ( j ).discri_item
                               AND cod_tributo = 'ICMS'
                               AND cod_tributacao = 3;
                        END IF;
                    EXCEPTION
                        WHEN OTHERS THEN
                            err_num := SQLCODE;
                            err_msg :=
                                SUBSTR ( SQLERRM
                                       , 1
                                       , 100 );
                            log_x07_type.log_fin48 := 'ERROR :BLOCO 171 | DELETE ' || err_num || ' - ' || err_msg;
                    END;
                EXCEPTION
                    WHEN OTHERS THEN
                        err_num := SQLCODE;
                        err_msg :=
                            SUBSTR ( SQLERRM
                                   , 1
                                   , 100 );
                        log_x07_type.log_fin48 := 'ERROR :BLOCO 293 | INSERT ' || err_num || ' - ' || err_msg;

                        INSERT INTO msafi.x07_docto_fiscal_log
                        VALUES log_x07_type;
                END;

                ----   cfop/cst /

                DECLARE
                BEGIN
                    l_cfop_saida_origem := NULL;

                    SELECT x07_gtt.cfop_saida_origem
                      INTO l_cfop_saida_origem
                      FROM msafi.x07_docto_fiscal_gtt x07_gtt
                     WHERE cod_empresa = x08_itens_merc_typ ( j ).cod_empresa
                       AND cod_estab = x08_itens_merc_typ ( j ).cod_estab
                       AND data_fiscal = x08_itens_merc_typ ( j ).data_fiscal
                       AND movto_e_s = x08_itens_merc_typ ( j ).movto_e_s
                       AND norm_dev = x08_itens_merc_typ ( j ).norm_dev
                       AND ident_docto = x08_itens_merc_typ ( j ).ident_docto
                       AND ident_fis_jur = x08_itens_merc_typ ( j ).ident_fis_jur
                       AND num_docfis = x08_itens_merc_typ ( j ).num_docfis
                       AND serie_docfis = x08_itens_merc_typ ( j ).serie_docfis
                       AND sub_serie_docfis = x08_itens_merc_typ ( j ).sub_serie_docfis
                       AND num_item = x08_itens_merc_typ ( j ).num_item;
                EXCEPTION
                    WHEN OTHERS THEN
                        err_num := SQLCODE;
                        err_msg :=
                            SUBSTR ( SQLERRM
                                   , 1
                                   , 100 );
                        log_x07_type.log_fin48 :=
                            'ERROR :BLOCO 403 | CFOP_SAIDA_ORIGEM ' || err_num || ' - ' || err_msg;

                        --
                        INSERT INTO msafi.x07_docto_fiscal_log
                        VALUES log_x07_type;
                END;

                l_ident_natureza_op := x08_itens_merc_typ ( j ).ident_natureza_op;

                BEGIN
                    SELECT x2081.ident_cfo
                      INTO l_ident_cfo
                      FROM x2012_cod_fiscal x2012
                         , x2081_extensao_cfo x2081
                         , x2006_natureza_op x2006
                     WHERE x2012.ident_cfo = x2081.ident_cfo
                       AND x2006.ident_natureza_op = x2081.ident_natureza_op
                       AND x2081.ident_natureza_op = l_ident_natureza_op
                       AND x2012.cod_cfo = (CASE
                                                WHEN l_cfop_saida_origem IN ( '6102'
                                                                            , '6101'
                                                                            , '6105'
                                                                            , '6106'
                                                                            , '6401'
                                                                            , '6403'
                                                                            , '6404' ) THEN
                                                    '2102'
                                                WHEN l_cfop_saida_origem IN ( '6152'
                                                                            , '2209' ) THEN
                                                    '2152'
                                                ELSE
                                                    l_cfop_saida_origem
                                            END)
                       AND x2006.valid_natureza_op =
                               (SELECT MAX ( valid_natureza_op )
                                  FROM x2006_natureza_op op
                                 WHERE op.valid_natureza_op <= x08_itens_merc_typ ( j ).data_fiscal);
                EXCEPTION
                    WHEN OTHERS THEN
                        err_num := SQLCODE;
                        err_msg :=
                            SUBSTR ( SQLERRM
                                   , 1
                                   , 100 );
                        log_x07_type.log_fin48 := 'ERROR :BLOCO 479 | L_IDENT_CFO ' || err_num || ' - ' || err_msg;

                        --
                        INSERT INTO msafi.x07_docto_fiscal_log
                        VALUES log_x07_type;
                END;

                ---  CST (40 ) POR PRODUTO DE CANCERÍGENO ISENTO
                BEGIN
                    SELECT x2013.cod_produto
                      INTO l_cod_produto
                      FROM x2013_produto x2013
                     WHERE x2013.ident_produto = x08_itens_merc_typ ( j ).ident_produto;

                    IF l_cod_produto IN ( '639'
                                        , '2836'
                                        , '4391'
                                        , '5681'
                                        , '18171'
                                        , '18481'
                                        , '18902'
                                        , '22330'
                                        , '26859'
                                        , '27391'
                                        , '28134'
                                        , '29327'
                                        , '30279'
                                        , '32018'
                                        , '32522'
                                        , '34550'
                                        , '34665'
                                        , '39365'
                                        , '39390'
                                        , '40878'
                                        , '41068'
                                        , '47899'
                                        , '51896'
                                        , '55794'
                                        , '67725'
                                        , '72257'
                                        , '73903'
                                        , '74462'
                                        , '74632'
                                        , '75272'
                                        , '75280'
                                        , '75329'
                                        , '75345'
                                        , '85332'
                                        , '88188'
                                        , '95559'
                                        , '96393'
                                        , '97853'
                                        , '104655'
                                        , '127302'
                                        , '148032'
                                        , '148059'
                                        , '148067'
                                        , '151130'
                                        , '170526'
                                        , '171026'
                                        , '186651'
                                        , '205265'
                                        , '205346'
                                        , '217492'
                                        , '219215'
                                        , '219223'
                                        , '219231'
                                        , '219240'
                                        , '219258'
                                        , '221953'
                                        , '221961'
                                        , '260762'
                                        , '260819'
                                        , '261122'
                                        , '261130'
                                        , '263648'
                                        , '266086'
                                        , '280089'
                                        , '288624'
                                        , '288950'
                                        , '290203'
                                        , '290378'
                                        , '290610'
                                        , '291285'
                                        , '292060'
                                        , '293725'
                                        , '295396'
                                        , '296562'
                                        , '299219'
                                        , '320021'
                                        , '322334'
                                        , '326534'
                                        , '326550'
                                        , '337471'
                                        , '337803'
                                        , '337811'
                                        , '341177'
                                        , '342262'
                                        , '342327'
                                        , '342939'
                                        , '343749'
                                        , '343757'
                                        , '343870'
                                        , '344770'
                                        , '344788'
                                        , '345067'
                                        , '346322'
                                        , '346330'
                                        , '346357'
                                        , '346365'
                                        , '347760'
                                        , '356506'
                                        , '356514'
                                        , '358550'
                                        , '362131'
                                        , '367311'
                                        , '370665'
                                        , '372498'
                                        , '372706'
                                        , '372846'
                                        , '372854'
                                        , '372862'
                                        , '375691'
                                        , '375772'
                                        , '383082'
                                        , '383090'
                                        , '387738'
                                        , '421804'
                                        , '422754'
                                        , '422762'
                                        , '423130'
                                        , '427748'
                                        , '427764'
                                        , '427772'
                                        , '427780'
                                        , '427799'
                                        , '427802'
                                        , '427829'
                                        , '427837'
                                        , '427845'
                                        , '427853'
                                        , '427861'
                                        , '427870'
                                        , '427888'
                                        , '427896'
                                        , '456101'
                                        , '456110'
                                        , '456128'
                                        , '465356'
                                        , '467049'
                                        , '472921'
                                        , '473391'
                                        , '478857'
                                        , '478865'
                                        , '478873'
                                        , '478881'
                                        , '478890'
                                        , '478903'
                                        , '482846'
                                        , '487759'
                                        , '487899'
                                        , '489964'
                                        , '490075'
                                        , '490091'
                                        , '491292'
                                        , '492108'
                                        , '492132'
                                        , '499595'
                                        , '499609'
                                        , '499617'
                                        , '506095'
                                        , '512486'
                                        , '515019'
                                        , '519596'
                                        , '521116'
                                        , '521124'
                                        , '521132'
                                        , '521140'
                                        , '533874'
                                        , '533947'
                                        , '533955'
                                        , '538442'
                                        , '550892'
                                        , '553182'
                                        , '563102'
                                        , '563110'
                                        , '563129'
                                        , '563137'
                                        , '563145'
                                        , '568180'
                                        , '575992'
                                        , '584878'
                                        , '618896'
                                        , '618900'
                                        , '634832'
                                        , '643416'
                                        , '647322'
                                        , '647330'
                                        , '647357'
                                        , '654280'
                                        , '655457'
                                        , '655465'
                                        , '666513'
                                        , '670421'
                                        , '672270'
                                        , '674249'
                                        , '674257'
                                        , '9002090'
                                        , '9004130'
                                        , '9005064'
                                        , '9007610'
                                        , '9007792'
                                        , '9008195'
                                        , '9008390' ) THEN
                        l_ident_situacao_b := 18; -- CST 40 (ISENTA)

                        BEGIN
                            SELECT x07_gtt.vlr_base_icms_2
                              INTO x08b_type.vlr_base
                              FROM msafi.x07_docto_fiscal_gtt x07_gtt
                             WHERE cod_empresa = x08_itens_merc_typ ( j ).cod_empresa
                               AND cod_estab = x08_itens_merc_typ ( j ).cod_estab
                               AND data_fiscal = x08_itens_merc_typ ( j ).data_fiscal
                               AND movto_e_s = x08_itens_merc_typ ( j ).movto_e_s
                               AND norm_dev = x08_itens_merc_typ ( j ).norm_dev
                               AND ident_docto = x08_itens_merc_typ ( j ).ident_docto
                               AND ident_fis_jur = x08_itens_merc_typ ( j ).ident_fis_jur
                               AND num_docfis = x08_itens_merc_typ ( j ).num_docfis
                               AND serie_docfis = x08_itens_merc_typ ( j ).serie_docfis
                               AND sub_serie_docfis = x08_itens_merc_typ ( j ).sub_serie_docfis
                               AND num_item = x08_itens_merc_typ ( j ).num_item;

                            UPDATE x08_trib_merc
                               SET aliq_tributo = 0
                                 , vlr_tributo = 0
                             WHERE cod_empresa = x08_itens_merc_typ ( j ).cod_empresa
                               AND cod_estab = x08_itens_merc_typ ( j ).cod_estab
                               AND data_fiscal = x08_itens_merc_typ ( j ).data_fiscal
                               AND movto_e_s = x08_itens_merc_typ ( j ).movto_e_s
                               AND norm_dev = x08_itens_merc_typ ( j ).norm_dev
                               AND ident_docto = x08_itens_merc_typ ( j ).ident_docto
                               AND ident_fis_jur = x08_itens_merc_typ ( j ).ident_fis_jur
                               AND num_docfis = x08_itens_merc_typ ( j ).num_docfis
                               AND serie_docfis = x08_itens_merc_typ ( j ).serie_docfis
                               AND sub_serie_docfis = x08_itens_merc_typ ( j ).sub_serie_docfis
                               AND discri_item = x08_itens_merc_typ ( j ).discri_item
                               AND cod_tributo = 'ICMS';

                            UPDATE x08_base_merc
                               SET cod_tributacao = 2
                                 , vlr_base = x08b_type.vlr_base
                             WHERE cod_empresa = x08_itens_merc_typ ( j ).cod_empresa
                               AND cod_estab = x08_itens_merc_typ ( j ).cod_estab
                               AND data_fiscal = x08_itens_merc_typ ( j ).data_fiscal
                               AND movto_e_s = x08_itens_merc_typ ( j ).movto_e_s
                               AND norm_dev = x08_itens_merc_typ ( j ).norm_dev
                               AND ident_docto = x08_itens_merc_typ ( j ).ident_docto
                               AND ident_fis_jur = x08_itens_merc_typ ( j ).ident_fis_jur
                               AND num_docfis = x08_itens_merc_typ ( j ).num_docfis
                               AND serie_docfis = x08_itens_merc_typ ( j ).serie_docfis
                               AND sub_serie_docfis = x08_itens_merc_typ ( j ).sub_serie_docfis
                               AND discri_item = x08_itens_merc_typ ( j ).discri_item
                               AND cod_tributo = 'ICMS'
                               AND cod_tributacao = 1;
                        END;
                    ELSE
                        l_ident_situacao_b := 14; -- CST  00  TRIBUTADA INTEGRALMENTE
                    END IF;
                EXCEPTION
                    WHEN OTHERS THEN
                        err_num := SQLCODE;
                        err_msg :=
                            SUBSTR ( SQLERRM
                                   , 1
                                   , 100 );
                        log_x07_type.log_fin48 :=
                            'ERROR :BLOCO 613 | L_IDENT_SITUACAO_B UP ' || err_num || ' - ' || err_msg;

                        --
                        INSERT INTO msafi.x07_docto_fiscal_log
                        VALUES log_x07_type;
                END;

                BEGIN
                    UPDATE x08_itens_merc
                       SET ident_cfo = l_ident_cfo
                         -- ,     IDENT_NATUREZA_OP   = L_IDENT_NATUREZA_OP
                         , ident_situacao_b = l_ident_situacao_b
                     WHERE cod_empresa = x08_itens_merc_typ ( j ).cod_empresa
                       AND cod_estab = x08_itens_merc_typ ( j ).cod_estab
                       AND data_fiscal = x08_itens_merc_typ ( j ).data_fiscal
                       AND movto_e_s = x08_itens_merc_typ ( j ).movto_e_s
                       AND norm_dev = x08_itens_merc_typ ( j ).norm_dev
                       AND ident_docto = x08_itens_merc_typ ( j ).ident_docto
                       AND ident_fis_jur = x08_itens_merc_typ ( j ).ident_fis_jur
                       AND num_docfis = x08_itens_merc_typ ( j ).num_docfis
                       AND serie_docfis = x08_itens_merc_typ ( j ).serie_docfis
                       AND sub_serie_docfis = x08_itens_merc_typ ( j ).sub_serie_docfis
                       AND discri_item = x08_itens_merc_typ ( j ).discri_item;
                EXCEPTION
                    WHEN OTHERS THEN
                        err_num := SQLCODE;
                        err_msg :=
                            SUBSTR ( SQLERRM
                                   , 1
                                   , 100 );
                        log_x07_type.log_fin48 :=
                            'ERROR :BLOCO 520 | X08_ITENS_MERC UP ' || err_num || ' - ' || err_msg;

                        --
                        INSERT INTO msafi.x07_docto_fiscal_log
                        VALUES log_x07_type;
                END;

                UPDATE msafi.dpsp_fin048_ret_nf_ent
                   SET status = 'UPD'
                 WHERE cod_empresa = x08_itens_merc_typ ( j ).cod_empresa
                   AND cod_estab = x08_itens_merc_typ ( j ).cod_estab
                   AND data_fiscal = x08_itens_merc_typ ( j ).data_fiscal
                   AND num_docfis = x08_itens_merc_typ ( j ).num_docfis
                   AND num_item = x08_itens_merc_typ ( j ).num_item;
            END LOOP;

            DECLARE
                i NUMBER;
            BEGIN
                SELECT COUNT ( * )
                  INTO i
                  FROM msafi.dpsp_fin048_ret_nf_ent
                 WHERE data_fiscal BETWEEN pdt_ini AND pdt_fim
                   AND cod_estab = pcod_estab;

                loga ( 'DW atualizados - Nr. Itens ' || i );
            END;
        EXCEPTION
            WHEN forall_failed THEN
                FOR i IN 1 .. l_errors LOOP
                    l_errno := SQL%BULK_EXCEPTIONS ( i ).ERROR_CODE;
                    l_msg := SQLERRM ( -l_errno );
                    l_idx := SQL%BULK_EXCEPTIONS ( i ).ERROR_INDEX;

                    log_x07_type.cod_empresa := x07_docto_fiscal_typ ( i ).cod_empresa;
                    log_x07_type.cod_estab := x07_docto_fiscal_typ ( i ).cod_estab;
                    log_x07_type.data_fiscal := x07_docto_fiscal_typ ( i ).data_fiscal;
                    log_x07_type.movto_e_s := x07_docto_fiscal_typ ( i ).movto_e_s;
                    log_x07_type.norm_dev := x07_docto_fiscal_typ ( i ).norm_dev;
                    log_x07_type.ident_docto := x07_docto_fiscal_typ ( i ).ident_docto;
                    log_x07_type.ident_fis_jur := x07_docto_fiscal_typ ( i ).ident_fis_jur;
                    log_x07_type.num_docfis := x07_docto_fiscal_typ ( i ).num_docfis;
                    log_x07_type.serie_docfis := x07_docto_fiscal_typ ( i ).serie_docfis;
                    log_x07_type.sub_serie_docfis := x07_docto_fiscal_typ ( i ).sub_serie_docfis;
                    log_x07_type.num_item := x07_docto_fiscal_typ ( i ).num_item;
                    log_x07_type.log_fin48 :=
                        'ERROR :BLOCO 530 | INSERT ' || l_errno || ' - ' || l_msg || ' - ' || l_idx;

                    INSERT INTO msafi.x07_docto_fiscal_log
                    VALUES log_x07_type;
                END LOOP;

                COMMIT;
        END;
    END prc_upd_nf_entrada;

    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );
    BEGIN
        mnm_usuario := lib_parametros.recuperar ( UPPER ( 'USUARIO' ) );
        mcod_empresa := lib_parametros.recuperar ( UPPER ( 'EMPRESA' ) );

        lib_proc.add_param ( pparam => pstr
                           , ptitulo => 'Data Inicial'
                           , ptipo => 'DATE'
                           , pcontrole => 'TEXTBOX'
                           , pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => 'DD/MM/YYYY' );

        lib_proc.add_param ( pparam => pstr
                           , ptitulo => 'Data Final'
                           , ptipo => 'DATE'
                           , pcontrole => 'TEXTBOX'
                           , pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => 'DD/MM/YYYY' );

        --    lib_proc.add_param(pparam      => pstr,
        --                       ptitulo     => 'Atualiza Mastersaf',
        --                       ptipo       => 'Varchar2',
        --                       pcontrole   => 'Checkbox',
        --                       pmandatorio => 'S',
        --                       pdefault    => 'N',
        --                       pmascara    => null,
        --                       pvalores    => 'S=Sim,N=Não',
        --                       papresenta  => 'N',
        --                       phabilita   => ' ');

        lib_proc.add_param (
                             pstr
                           , 'CDS'
                           , 'VARCHAR2'
                           , 'COMBOBOX'
                           , 'S'
                           , NULL
                           , NULL
                           ,    'SELECT A.COD_ESTAB, A.COD_ESTAB || '' - '' || B.COD_ESTADO || '' - '' || A.CGC || '' - '' || INITCAP(A.BAIRRO) || '' / '' || INITCAP(A.CIDADE) FROM ESTABELECIMENTO A, ESTADO B, MSAFI.DSP_ESTABELECIMENTO C WHERE A.COD_EMPRESA  = '''
                             || mcod_empresa
                             || ''' AND B.IDENT_ESTADO = A.IDENT_ESTADO AND A.COD_EMPRESA = C.COD_EMPRESA AND A.COD_ESTAB = C.COD_ESTAB AND C.TIPO = ''C'' AND B.COD_ESTADO = ''ES'' '
        );

        lib_proc.add_param (
                             pparam => pstr
                           , --p_radio
                            ptitulo => 'Processo'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'RADIOBUTTON'
                           , pmandatorio => 'S'
                           , pdefault => '1'
                           , --Pmascara    => '',
                             pvalores =>    '1=Processar registros entradas e gerar relatório.,'
                                         || --
                                           '2=Atualiza Mastersaf.' --,
        --Papresenta => 'S',
        --Phabilita  => 'S'
        --
         );

        lib_proc.add_param ( pparam => pstr
                           , ptitulo =>    LPAD ( '-'
                                                , 60
                                                , '-' )
                                        || 'NOTAS DE ENTRADA'
                                        || LPAD ( '-'
                                                , 60
                                                , '-' )
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'TEXT'
                           , pmandatorio => 'N'
                           , pdefault => 'N'
                           , pmascara => NULL
                           , pvalores => NULL
                           , papresenta => 'N' );

        lib_proc.add_param (
                             pparam => pstr
                           , ptitulo => 'CFOP DO FORNECEDOR 6102/6101/6105/6106/6401/6403/6404: AJUSTAR ENTRADA PARA 2.102'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'TEXT'
                           , pmandatorio => 'N'
                           , pdefault => 'N'
                           , pmascara => NULL
                           , pvalores => NULL
                           , papresenta => 'N'
        );

        lib_proc.add_param ( pparam => pstr
                           , ptitulo => 'CFOP DO FORNECEDOR 6152: AJUSTAR ENTRADA PARA 2.152'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'TEXT'
                           , pmandatorio => 'N'
                           , pdefault => 'N'
                           , pmascara => NULL
                           , pvalores => NULL
                           , papresenta => 'N' );

        RETURN pstr;
    END;

    FUNCTION tipo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN mnm_tipo;
    END;

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN mnm_cproc;
    END;

    FUNCTION descricao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN mds_cproc;
    END;

    FUNCTION versao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN '1.0';
    END;

    FUNCTION modulo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'CUSTOMIZADOS';
    END;

    FUNCTION classificacao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'CUSTOMIZADOS';
    END;

    FUNCTION orientacao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'PORTRAIT';
    END;

    FUNCTION executar ( pdt_ini DATE
                      , pdt_fim DATE
                      , pcod_estab VARCHAR2
                      , p_radio VARCHAR2 )
        RETURN INTEGER
    IS
        v_qtd INTEGER;
        v_validar_status INTEGER := 0;
        v_existe_origem CHAR := 'S';

        v_data_inicial DATE
            :=   TRUNC ( pdt_ini )
               - (   TO_NUMBER ( TO_CHAR ( pdt_ini
                                         , 'DD' ) )
                   - 1 );
        v_data_final DATE := LAST_DAY ( pdt_fim );
        v_data_hora_ini VARCHAR2 ( 20 );
        p_proc_instance VARCHAR2 ( 30 );

        --PTAB_ENTRADA     VARCHAR2(50);
        v_sql VARCHAR2 ( 4000 );
        v_retorno_status VARCHAR2 ( 4000 );

        i INTEGER := 2;
        --VARIAVEIS GENERICAS
        v_text01 VARCHAR2 ( 6000 );
        v_class VARCHAR2 ( 1 ) := 'A';

        CURSOR lista_cds
        IS
            SELECT a.cod_estab
              FROM estabelecimento a
                 , estado b
                 , msafi.dsp_estabelecimento c
             WHERE b.ident_estado = a.ident_estado
               AND a.cod_empresa = c.cod_empresa
               AND a.cod_estab = c.cod_estab
               AND c.tipo = 'C'
               AND a.cod_empresa = mcod_empresa
               AND a.cod_estab = (CASE WHEN pcod_estab = 'TODOS' THEN a.cod_estab ELSE pcod_estab END);
    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET TEMP_UNDO_ENABLED=FALSE ';

        -- CRIAÇÃO: PROCESSO
        mproc_id :=
            lib_proc.new ( psp_nome => $$plsql_unit
                         , -- PACKAGE
                          prows => 48
                         , pcols => 200 );

        --TELA DW
        lib_proc.add_tipo ( pproc_id => mproc_id
                          , ptipo => 1
                          , ptitulo =>    TO_CHAR ( SYSDATE
                                                  , 'YYYYMMDDHH24MISS' )
                                       || '_RET_ICMS_ES_ENTRADAS'
                          , ptipo_arq => 1 );

        vn_pagina := 1;
        vn_linha := 48;

        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT="DD/MM/YYYY"';

        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS= '',.'' ';

        EXECUTE IMMEDIATE 'ALTER SESSION SET TEMP_UNDO_ENABLED=FALSE '; --EVITAR PROBLEMAS DE GRAVACAO NAS GTTs

        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        mnm_usuario := lib_parametros.recuperar ( 'USUARIO' );

        --MARCAR INCIO DA EXECUCAO
        v_data_hora_ini :=
            TO_CHAR ( SYSDATE
                    , 'DD/MM/YYYY HH24:MI.SS' );

        IF mcod_empresa IS NULL THEN
            lib_proc.add_log ( 'CÓDIGO DA EMPRESA DEVE SER INFORMADO COMO PARÂMETRO GLOBAL.'
                             , 0 );
            lib_proc.add ( 'ERRO' );
            lib_proc.add ( 'CÓDIGO DA EMPRESA DEVE SER INFORMADO COMO PARÂMETRO GLOBAL.' );
            lib_proc.close;
            RETURN mproc_id;
        END IF;

        FOR c_dados_emp IN ( SELECT cod_empresa
                                  , razao_social
                                  , DECODE ( cnpj
                                           , NULL, NULL
                                           , REPLACE ( REPLACE ( REPLACE ( TO_CHAR ( LPAD ( REPLACE ( cnpj
                                                                                                    , '' )
                                                                                          , 14
                                                                                          , '0' )
                                                                                   , '00,000,000,0000,00' )
                                                                         , ','
                                                                         , '.' )
                                                               , ' ' )
                                                     ,    '.'
                                                       || TRIM ( TO_CHAR ( TRUNC (   MOD ( LPAD ( cnpj
                                                                                                , 14
                                                                                                , '0' )
                                                                                         , 1000000 )
                                                                                   / 100 )
                                                                         , '0000' ) )
                                                       || '.'
                                                     ,    '/'
                                                       || TRIM ( TO_CHAR ( TRUNC (   MOD ( LPAD ( cnpj
                                                                                                , 14
                                                                                                , '0' )
                                                                                         , 1000000 )
                                                                                   / 100 )
                                                                         , '0000' ) )
                                                       || '-' ) )
                                        AS cnpj
                               FROM empresa
                              WHERE cod_empresa = mcod_empresa ) LOOP
            cabecalho ( c_dados_emp.razao_social
                      , c_dados_emp.cnpj
                      , v_data_hora_ini
                      , mnm_cproc
                      , pdt_ini
                      , pdt_fim
                      , pcod_estab );
        END LOOP;

        loga ( '---INI DO PROCESSAMENTO---'
             , FALSE );
        loga ( '<< PERIODO DE: ' || v_data_inicial || ' A ' || v_data_final || ' >>'
             , FALSE );

        --=================================================================================
        -- INICIO
        --=================================================================================
        --PERMITIR PROCESSO SOMENTE PARA UM MÊS
        IF LAST_DAY ( pdt_ini ) = LAST_DAY ( pdt_fim ) THEN
            --=================================================================================
            -- INICIO
            --=================================================================================

            --LOGA ('PASSO 0',FALSE);

            -- UM CD POR VEZ
            FOR cd IN lista_cds LOOP
                ---LOGA ('PASSO AAA',FALSE);

                dbms_application_info.set_module ( $$plsql_unit
                                                 , 'ESTAB: ' || cd.cod_estab );

                --GERAR CHAVE PROC_ID
                SELECT ROUND ( dbms_random.VALUE ( 10000000000000
                                                 , 999999999999999 ) )
                  INTO p_proc_instance
                  FROM DUAL;

                loga ( 'PASSO 1'
                     , FALSE );

                loga ( $$plsql_unit
                     , FALSE );

                IF p_radio = 1 THEN
                    --PROCESSAR

                    v_validar_status :=
                        msaf.dpsp_suporte_cproc_process.validar_status_rel ( mcod_empresa
                                                                           , cd.cod_estab
                                                                           , TO_NUMBER ( TO_CHAR ( pdt_ini
                                                                                                 , 'YYYYMM' ) )
                                                                           , $$plsql_unit );

                    --=================================================================================
                    -- CARREGAR TABELA DE NOTAS DE ENTRADA
                    --=================================================================================
                    IF v_validar_status = 0 THEN
                        loga ( '>> INICIO CD: ' || cd.cod_estab || ' PROC INSERT ' || p_proc_instance
                             , FALSE );

                        loga ( 'PASSO 2  : ' || v_validar_status
                             , FALSE );

                        ---------------------
                        -- LIMPEZA
                        ---------------------
                        DELETE FROM msafi.dpsp_fin048_ret_nf_ent
                              WHERE cod_empresa = mcod_empresa
                                AND cod_estab = cd.cod_estab
                                AND data_fiscal BETWEEN v_data_inicial AND v_data_final;

                        loga (
                                  '::LIMPEZA DOS REGISTROS ANTERIORES (MSAFI.DPSP_FIN048_RET_NF_ENT), CD: '
                               || cd.cod_estab
                               || ' - QTDE '
                               || SQL%ROWCOUNT
                               || '::'
                             , FALSE
                        );

                        COMMIT;

                        loga ( 'PASSO 3'
                             , FALSE );

                        --carrega_gtt(v_data_inicial, v_data_final, cd.cod_estab);

                        loga ( 'CARREGA GTT' );

                        --A CARGA IRÁ EXECUTAR O PERIODO INTEIRO, E DEPOIS CONSULTAR O PERIODO INFORMADO NA TELA.
                        --EXEMPLO: PARAMETRIZADO DO DIA 1 AO 10, ENTÃO SERÁ CARREGADO DE 1 A 31, MAS CONSULTADO DE 1 A 10
                        v_qtd :=
                            carregar_nf_entrada ( v_data_inicial
                                                , v_data_final
                                                , cd.cod_estab
                                                , v_data_hora_ini );

                        loga ( 'PASSO 4'
                             , FALSE );

                        loga ( v_qtd || ' = quantidade' );

                        IF v_qtd = 0 THEN
                            --INSERIR STATUS COMO ABERTO POIS NÃO HÁ ORIGEM
                            msaf.dpsp_suporte_cproc_process.inserir_status_rel ( mcod_empresa
                                                                               , cd.cod_estab
                                                                               , TO_NUMBER ( TO_CHAR ( pdt_ini
                                                                                                     , 'YYYYMM' ) )
                                                                               , $$plsql_unit
                                                                               , mnm_cproc
                                                                               , mnm_tipo
                                                                               , 0
                                                                               , --ABERTO
                                                                                $$plsql_unit
                                                                               , mproc_id
                                                                               , mnm_usuario
                                                                               , v_data_hora_ini );

                            lib_proc.add ( 'CD ' || cd.cod_estab || ' SEM DADOS NA ORIGEM.' );

                            lib_proc.add ( ' ' );
                            loga ( '---CD ' || cd.cod_estab || ' - SEM DADOS DE ORIGEM---'
                                 , FALSE );
                            --LOGA('<< SEM DADOS DE ORIGEM >>', FALSE);

                            v_existe_origem := 'N';
                        ELSE
                            ---------------------
                            --ENCERRAR PERIODO CASO NÃO SEJA O MÊS ATUAL E EXISTAM REGISTROS NA ORIGEM
                            ---------------------
                            IF LAST_DAY ( pdt_ini ) < LAST_DAY ( SYSDATE ) THEN
                                msaf.dpsp_suporte_cproc_process.inserir_status_rel ( mcod_empresa
                                                                                   , cd.cod_estab
                                                                                   , TO_NUMBER ( TO_CHAR ( pdt_ini
                                                                                                         , 'YYYYMM' ) )
                                                                                   , $$plsql_unit
                                                                                   , mnm_cproc
                                                                                   , mnm_tipo
                                                                                   , 1
                                                                                   , --ENCERRADO
                                                                                    $$plsql_unit
                                                                                   , mproc_id
                                                                                   , mnm_usuario
                                                                                   , v_data_hora_ini );
                                lib_proc.add ( 'CD ' || cd.cod_estab || ' - PERÍODO ENCERRADO' );

                                v_retorno_status :=
                                    msaf.dpsp_suporte_cproc_process.retornar_status_rel (
                                                                                          mcod_empresa
                                                                                        , cd.cod_estab
                                                                                        , TO_NUMBER (
                                                                                                      TO_CHAR (
                                                                                                                pdt_ini
                                                                                                              , 'YYYYMM'
                                                                                                      )
                                                                                          )
                                                                                        , $$plsql_unit
                                    );

                                lib_proc.add ( 'DATA DE ENCERRAMENTO: ' || v_retorno_status );

                                lib_proc.add ( ' ' );
                                loga (
                                          '---ESTAB '
                                       || cd.cod_estab
                                       || ' - PERIODO ENCERRADO: '
                                       || v_retorno_status
                                       || '---'
                                     , FALSE
                                );
                            ELSE
                                msaf.dpsp_suporte_cproc_process.inserir_status_rel ( mcod_empresa
                                                                                   , cd.cod_estab
                                                                                   , TO_NUMBER ( TO_CHAR ( pdt_ini
                                                                                                         , 'YYYYMM' ) )
                                                                                   , $$plsql_unit
                                                                                   , mnm_cproc
                                                                                   , mnm_tipo
                                                                                   , 0
                                                                                   , --ABERTO
                                                                                    $$plsql_unit
                                                                                   , mproc_id
                                                                                   , mnm_usuario
                                                                                   , v_data_hora_ini );

                                lib_proc.add ( 'CD ' || cd.cod_estab || ' - PERIODO EM ABERTO,'
                                             , 1 );
                                lib_proc.add ( 'OS REGISTROS GERADOS SÃO TEMPORÁRIOS.'
                                             , 1 );
                                lib_proc.add ( ' '
                                             , 1 );
                                loga ( '---CD ' || cd.cod_estab || ' - PERIODO EM ABERTO---'
                                     , FALSE );
                            END IF;
                        END IF;
                    --PERIODO JÁ ENCERRADO
                    ELSE
                        lib_proc.add ( 'CD ' || cd.cod_estab || ' - PERÍODO JÁ PROCESSADO E ENCERRADO' );

                        v_retorno_status :=
                            msaf.dpsp_suporte_cproc_process.retornar_status_rel ( mcod_empresa
                                                                                , cd.cod_estab
                                                                                , TO_NUMBER ( TO_CHAR ( pdt_ini
                                                                                                      , 'YYYYMM' ) )
                                                                                , $$plsql_unit );

                        lib_proc.add ( 'DATA DE ENCERRAMENTO: ' || v_retorno_status );
                        lib_proc.add ( ' ' );
                        loga (
                                  '---CD '
                               || cd.cod_estab
                               || ' - PERIODO JÁ PROCESSADO E ENCERRADO: '
                               || v_retorno_status
                               || '---'
                             , FALSE
                        );
                    END IF;
                ELSIF ( p_radio = '2' ) THEN
                    v_validar_status :=
                        msaf.dpsp_suporte_cproc_process.validar_status_rel ( mcod_empresa
                                                                           , cd.cod_estab
                                                                           , TO_NUMBER ( TO_CHAR ( pdt_ini
                                                                                                 , 'YYYYMM' ) )
                                                                           , $$plsql_unit );

                    IF v_validar_status = 1 THEN
                        -- ENCERRADO, RODA ISSO

                        loga ( 'PRC_UPD_NF_ENTRADA-INI'
                             , FALSE );
                        prc_upd_nf_entrada ( pdt_ini
                                           , pdt_fim
                                           , cd.cod_estab
                                           , v_data_hora_ini );
                        loga ( 'PRC_UPD_NF_ENTRADA-FIM'
                             , FALSE );
                    ELSE
                        NULL;
                    END IF;
                END IF;

                --LIMPAR VARIAVEIS PARA PROXIMO ESTAB
                v_qtd := 0;
                v_retorno_status := '';
                v_sql := '';
            END LOOP;

            --=================================================================================
            -- GERAR ARQUIVO ANALITICO
            --=================================================================================
            lib_proc.add_tipo ( mproc_id
                              , i
                              ,    TO_CHAR ( pdt_ini
                                           , 'YYYYMM' )
                                || '_RET_ICMS_ES_ENTRADAS.XLS'
                              , 2 );
            lib_proc.add ( dsp_planilha.header
                         , ptipo => i );
            lib_proc.add ( dsp_planilha.tabela_inicio
                         , ptipo => i );

            FOR cd IN lista_cds LOOP
                lib_proc.add ( dsp_planilha.linha (
                                                    p_conteudo =>    dsp_planilha.campo ( 'COD_EMPRESA' ) --1
                                                                  || dsp_planilha.campo ( 'COD_ESTAB' ) --2
                                                                  || dsp_planilha.campo ( 'DATA_FISCAL' ) --3
                                                                  || dsp_planilha.campo ( 'NUM_DOCFIS' ) --4
                                                                  || dsp_planilha.campo ( 'NUM_AUTENTIC_NFE' ) --5
                                                                  || dsp_planilha.campo ( 'COD_FIS_JUR' ) --6
                                                                  || dsp_planilha.campo ( 'CPF_CGC' ) --7
                                                                  || dsp_planilha.campo ( 'COD_DOCTO' ) --8
                                                                  || dsp_planilha.campo ( 'COD_MODELO' ) --9
                                                                  || dsp_planilha.campo ( 'COD_CFO' ) --10
                                                                  ---
                                                                  || dsp_planilha.campo ( 'NATUREZA_OPERACAO' ) -- 11
                                                                  || dsp_planilha.campo ( 'COD_PRODUTO' ) -- 12
                                                                  || dsp_planilha.campo ( 'DESCRICAO' ) -- 13
                                                                  || dsp_planilha.campo ( 'CST_A' ) -- 14
                                                                  || dsp_planilha.campo ( 'CST_B' ) -- 15
                                                                  || dsp_planilha.campo ( 'QUANTIDADE' ) -- 16
                                                                  || dsp_planilha.campo ( 'NCM' ) -- 17
                                                                  || dsp_planilha.campo ( 'NUM_ITEM' ) -- 18
                                                                  || dsp_planilha.campo ( 'VLR_CONTABIL_ITEM' ) -- 19
                                                                  || dsp_planilha.campo ( 'VLR_ITEM' ) -- 20
                                                                  || dsp_planilha.campo ( 'VLR_BASE_ICMS_1' ) -- 21
                                                                  || dsp_planilha.campo ( 'VLR_ALIQUOTA' ) -- 22
                                                                  || dsp_planilha.campo ( 'VLR_ICMS_PROPRIO' ) -- 23
                                                                  || dsp_planilha.campo ( 'VLR_BASE_ICMS_2' ) -- 24
                                                                  || dsp_planilha.campo ( 'VLR_BASE_ICMS_3' ) -- 25
                                                                  || dsp_planilha.campo ( 'CFOP_SAIDA_ORIGEM' ) -- 26
                                                                  || dsp_planilha.campo ( 'CFOP_ENTRADA_ORIGEM' ) -- 27
                                                                  || dsp_planilha.campo ( 'VALOR_BASE_ICMS_ORIGEM' ) -- 28
                                                                  || dsp_planilha.campo ( 'VALOR_ALIQUOTA_ORIGEM' ) -- 29
                                                                  || dsp_planilha.campo ( 'VALOR_ICMS_ORIGEM' ) -- 30
                                                  , p_class => 'H'
                               )
                             , ptipo => i );

                FOR cr_r IN ( SELECT *
                                FROM msafi.dpsp_fin048_ret_nf_ent d
                               WHERE d.cod_empresa = mcod_empresa
                                 AND d.cod_estab = cd.cod_estab
                                 AND d.data_fiscal BETWEEN pdt_ini AND pdt_fim ) LOOP
                    IF v_class = 'A' THEN
                        v_class := 'B';
                    ELSE
                        v_class := 'A';
                    END IF;

                    v_text01 :=
                        dsp_planilha.linha (
                                             p_conteudo =>    dsp_planilha.campo ( cr_r.cod_empresa ) -- 1
                                                           || dsp_planilha.campo ( cr_r.cod_estab ) -- 2
                                                           || dsp_planilha.campo ( cr_r.data_fiscal ) -- 3
                                                           || dsp_planilha.campo (
                                                                                   dsp_planilha.texto (
                                                                                                        cr_r.num_docfis
                                                                                   )
                                                              ) -- 4
                                                           || dsp_planilha.campo (
                                                                                   dsp_planilha.texto (
                                                                                                        cr_r.num_autentic_nfe
                                                                                   )
                                                              ) -- 5
                                                           || dsp_planilha.campo (
                                                                                   dsp_planilha.texto (
                                                                                                        cr_r.cod_fis_jur
                                                                                   )
                                                              ) -- 6
                                                           || dsp_planilha.campo (
                                                                                   dsp_planilha.texto ( cr_r.cpf_cgc )
                                                              ) -- 7
                                                           || dsp_planilha.campo (
                                                                                   dsp_planilha.texto (
                                                                                                        cr_r.cod_docto
                                                                                   )
                                                              ) -- 8
                                                           || dsp_planilha.campo (
                                                                                   dsp_planilha.texto (
                                                                                                        cr_r.cod_modelo
                                                                                   )
                                                              ) -- 9
                                                           || dsp_planilha.campo (
                                                                                   dsp_planilha.texto ( cr_r.cod_cfo )
                                                              ) -- 10
                                                           || dsp_planilha.campo (
                                                                                   dsp_planilha.texto (
                                                                                                        cr_r.natureza_operacao
                                                                                   )
                                                              ) -- 11
                                                           || dsp_planilha.campo (
                                                                                   dsp_planilha.texto (
                                                                                                        cr_r.cod_produto
                                                                                   )
                                                              ) -- 12
                                                           || dsp_planilha.campo (
                                                                                   dsp_planilha.texto (
                                                                                                        cr_r.descricao
                                                                                   )
                                                              ) -- 13
                                                           || dsp_planilha.campo ( dsp_planilha.texto ( cr_r.cst_a ) ) -- 14
                                                           || dsp_planilha.campo ( dsp_planilha.texto ( cr_r.cst_b ) ) -- 15
                                                           || dsp_planilha.campo ( cr_r.quantidade ) -- 16
                                                           || dsp_planilha.campo ( cr_r.ncm ) -- 17
                                                           || dsp_planilha.campo (
                                                                                   dsp_planilha.texto ( cr_r.num_item )
                                                              ) -- 18
                                                           || dsp_planilha.campo ( cr_r.vlr_contabil_item ) -- 19
                                                           || dsp_planilha.campo ( cr_r.vlr_item ) -- 20
                                                           || dsp_planilha.campo ( cr_r.vlr_base_icms_1 ) -- 21
                                                           || dsp_planilha.campo ( cr_r.vlr_aliquota ) -- 22
                                                           || dsp_planilha.campo ( cr_r.vlr_icms_proprio ) -- 23
                                                           || dsp_planilha.campo ( cr_r.vlr_base_icms_2 ) -- 24
                                                           || dsp_planilha.campo ( cr_r.vlr_base_icms_3 ) -- 25
                                                           --                                           --  XML
                                                           || dsp_planilha.campo ( cr_r.cfop_saida_origem ) -- 26  (XML)
                                                           || dsp_planilha.campo ( cr_r.cfop_entrada_origem ) -- 27  (XML)
                                                           || dsp_planilha.campo ( cr_r.valor_base_icms_origem ) -- 28  (XML)
                                                           || dsp_planilha.campo ( cr_r.valor_aliquota_origem ) -- 29  (XML)
                                                           || dsp_planilha.campo ( cr_r.valor_icms_origem ) -- 30  (XML)
                                           , p_class => v_class
                        );
                    lib_proc.add ( v_text01
                                 , ptipo => i );
                END LOOP;
            END LOOP;

            lib_proc.add ( dsp_planilha.tabela_fim
                         , ptipo => i );

            i := i + 1;

            --=================================================================================
            -- FIM
            --=================================================================================

            --=================================================================================
            -- GERAR ARQUIVO SINTETICO
            --=================================================================================
            lib_proc.add_tipo ( mproc_id
                              , i
                              ,    TO_CHAR ( pdt_ini
                                           , 'YYYYMM' )
                                || '__RET_ICMS_ES_ENTRADAS_SINTETICO.XLS'
                              , 2 );
            lib_proc.add ( dsp_planilha.header
                         , ptipo => i );
            lib_proc.add ( dsp_planilha.tabela_inicio
                         , ptipo => i );

            FOR cd IN lista_cds LOOP
                lib_proc.add ( dsp_planilha.linha (
                                                    p_conteudo =>    dsp_planilha.campo ( 'CFO' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'VLR_CONTABIL' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'BASE_TRIB' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'VLR_ICMS' )
                                                  , p_class => 'H'
                               )
                             , ptipo => i );

                --
                --    SELECT COD_CFO AS CFO,
                --                            SUM(VLR_CONTABIL_ITEM) AS VLR_CONTABIL,
                --                            SUM(VALOR_BASE_ICMS_ORIGEM) AS BASE_TRIB,
                --                            SUM(VALOR_ICMS_ORIGEM) AS VLR_ICMS
                --                       FROM MSAFI.DPSP_FIN048_RET_NF_ENT
                --                      WHERE 1 = 1
                --                        AND COD_ESTAB = 'DP908'
                --                       AND DATA_FISCAL = '10/04/2017'
                --                        AND  COD_CFO   = '2152'
                --                      GROUP BY COD_CFO;

                FOR cr_r IN ( SELECT   cod_cfo AS cfo
                                     , SUM ( vlr_contabil_item ) AS vlr_contabil
                                     , SUM ( valor_base_icms_origem ) AS base_trib
                                     , SUM ( valor_icms_origem ) AS vlr_icms
                                  FROM msafi.dpsp_fin048_ret_nf_ent
                                 WHERE 1 = 1
                                   AND cod_estab = cd.cod_estab
                                   AND data_fiscal BETWEEN pdt_ini AND pdt_fim
                              GROUP BY cod_cfo ) LOOP
                    IF v_class = 'A' THEN
                        v_class := 'B';
                    ELSE
                        v_class := 'A';
                    END IF;

                    v_text01 :=
                        dsp_planilha.linha (
                                             p_conteudo =>    dsp_planilha.campo ( cr_r.cfo )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.vlr_contabil )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.base_trib )
                                                           || --
                                                             dsp_planilha.campo ( cr_r.vlr_icms )
                                           , p_class => v_class
                        );
                    lib_proc.add ( v_text01
                                 , ptipo => i );
                END LOOP;
            END LOOP;

            lib_proc.add ( dsp_planilha.tabela_fim
                         , ptipo => i );

            loga ( '---FIM DO PROCESSAMENTO [SUCESSO]---'
                 , FALSE );

            --=================================================================================
            -- FIM
            --=================================================================================

            --ENVIAR EMAIL DE SUCESSO----------------------------------------
            envia_email ( mcod_empresa
                        , v_data_inicial
                        , v_data_final
                        , ''
                        , 'S'
                        , v_data_hora_ini );

            -----------------------------------------------------------------
            IF v_existe_origem = 'N' THEN
                lib_proc.add ( 'HÁ CDS SEM DADOS DE ORIGEM.' );
                lib_proc.add ( ' ' );
            END IF;
        --EM CASOS DE MESES DIFERENTES
        ELSE
            lib_proc.add ( 'PROCESSO NÃO PERMITIDO:'
                         , 1 );
            lib_proc.add ( 'FAVOR INFORMAR SOMENTE UM ÚNICO MÊS ENTRE A DATA INICIAL E DATA FINAL'
                         , 1 );
            lib_proc.add ( ' '
                         , 1 );

            loga ( ' '
                 , FALSE );
            loga ( '<< PROCESSO NÃO PERMITIDO >>'
                 , FALSE );
            loga ( 'NÃO É PERMITIDO O PROCESSAMENTO DE MESES DIFERENTES'
                 , FALSE );
            loga ( ' '
                 , FALSE );

            loga ( '---FIM DO PROCESSAMENTO [ERRO]---'
                 , FALSE );
        END IF;

        lib_proc.add ( 'FAVOR VERIFICAR LOG PARA DETALHES.' );
        lib_proc.add ( ' ' );

        lib_proc.close;
        RETURN mproc_id;
    EXCEPTION
        WHEN OTHERS THEN
            loga ( 'SQLERRM: ' || SQLERRM
                 , FALSE );
            lib_proc.add_log ( 'ERRO NÃO TRATADO: ' || dbms_utility.format_error_backtrace
                             , 1 );
            lib_proc.add_log ( 'SQLERRM: ' || SQLERRM
                             , 1 );
            lib_proc.add ( 'ERRO!' );
            lib_proc.add ( dbms_utility.format_error_backtrace );

            --ENVIAR EMAIL DE ERRO-------------------------------------------
            envia_email ( mcod_empresa
                        , v_data_inicial
                        , v_data_final
                        , SQLERRM
                        , 'E'
                        , v_data_hora_ini );
            -----------------------------------------------------------------

            lib_proc.close;
            COMMIT;
            RETURN mproc_id;
    END;

    PROCEDURE loga ( p_i_texto IN VARCHAR2
                   , p_i_dttm IN BOOLEAN DEFAULT TRUE )
    IS
        vtexto VARCHAR2 ( 1024 );
    BEGIN
        IF p_i_dttm THEN
            vtexto :=
                SUBSTR (    TO_CHAR ( SYSDATE
                                    , 'DD/MM/YYYY HH24:MI:SS' )
                         || ' - '
                         || p_i_texto
                       , 1
                       , 1024 );
        ELSE
            vtexto :=
                SUBSTR ( p_i_texto
                       , 1
                       , 1024 );
        END IF;

        lib_proc.add_log ( vtexto
                         , 1 );
        COMMIT;
    END;

    PROCEDURE envia_email ( vp_cod_empresa IN VARCHAR2
                          , vp_data_ini IN DATE
                          , vp_data_fim IN DATE
                          , vp_msg_oracle IN VARCHAR2
                          , vp_tipo IN VARCHAR2
                          , vp_data_hora_ini IN VARCHAR2 )
    IS
        v_txt_email VARCHAR2 ( 20000 ) := '';
        v_assunto VARCHAR2 ( 10000 ) := '';
        v_horas NUMBER;
        v_minutos NUMBER;
        v_segundos NUMBER;
        v_tempo_exec VARCHAR2 ( 20000 );
    BEGIN
        --CALCULAR TEMPO DE EXECUCAO DO RELATORIO
        SELECT   TRUNC (   (   (   86400
                                 * (   SYSDATE
                                     - TO_DATE ( vp_data_hora_ini
                                               , 'DD/MM/YYYY HH24:MI.SS' ) ) )
                             / 60 )
                         / 60 )
               -   24
                 * ( TRUNC (   (   (   (   86400
                                         * (   SYSDATE
                                             - TO_DATE ( vp_data_hora_ini
                                                       , 'DD/MM/YYYY HH24:MI.SS' ) ) )
                                     / 60 )
                                 / 60 )
                             / 24 ) )
             ,   TRUNC (   (   86400
                             * (   SYSDATE
                                 - TO_DATE ( vp_data_hora_ini
                                           , 'DD/MM/YYYY HH24:MI.SS' ) ) )
                         / 60 )
               -   60
                 * ( TRUNC (   (   (   86400
                                     * (   SYSDATE
                                         - TO_DATE ( vp_data_hora_ini
                                                   , 'DD/MM/YYYY HH24:MI.SS' ) ) )
                                 / 60 )
                             / 60 ) )
             ,   TRUNC (   86400
                         * (   SYSDATE
                             - TO_DATE ( vp_data_hora_ini
                                       , 'DD/MM/YYYY HH24:MI.SS' ) ) )
               -   60
                 * ( TRUNC (   (   86400
                                 * (   SYSDATE
                                     - TO_DATE ( vp_data_hora_ini
                                               , 'DD/MM/YYYY HH24:MI.SS' ) ) )
                             / 60 ) )
          INTO v_horas
             , v_minutos
             , v_segundos
          FROM DUAL;

        v_tempo_exec := v_horas || ':' || v_minutos || '.' || v_segundos;

        IF ( vp_tipo = 'E' ) THEN
            --VP_TIPO = 'E' (ERRO) OU 'S' (SUCESSO)

            v_txt_email := 'ERRO NO ' || mnm_cproc || '!';
            v_txt_email := v_txt_email || CHR ( 13 ) || '>> PARÂMETROS: ';
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - EMPRESA : ' || vp_cod_empresa;
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - DATA INÍCIO : ' || vp_data_ini;
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - DATA FIM : ' || vp_data_fim;
            v_txt_email := v_txt_email || CHR ( 13 ) || '>> LOG: ';
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - EXECUTADO POR : ' || mnm_usuario;
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - HORA INÍCIO : ' || vp_data_hora_ini;
            v_txt_email :=
                   v_txt_email
                || CHR ( 13 )
                || ' - HORA TÉRMINO : '
                || TO_CHAR ( SYSDATE
                           , 'DD/MM/YYYY HH24:MI.SS' );
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - TEMPO EXECUÇÃO	: ' || v_tempo_exec;
            v_txt_email := v_txt_email || CHR ( 13 ) || '<< ERRO >> ' || vp_msg_oracle;
            v_assunto := 'MASTERSAF -  ' || mnm_cproc || ' APRESENTOU ERRO';
            notifica ( ''
                     , 'S'
                     , v_assunto
                     , v_txt_email
                     , 'DPSP_FIN048_RET_ENTRADA_CPROC' );
        ELSE
            v_txt_email := mnm_cproc || ' FINALIZADO COM SUCESSO.';
            v_txt_email := v_txt_email || CHR ( 13 ) || '>> PARÂMETROS: ';
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - EMPRESA : ' || vp_cod_empresa;
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - DATA INÍCIO : ' || vp_data_ini;
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - DATA FIM : ' || vp_data_fim;
            v_txt_email := v_txt_email || CHR ( 13 ) || '>> LOG: ';
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - EXECUTADO POR : ' || mnm_usuario;
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - HORA INÍCIO : ' || vp_data_hora_ini;
            v_txt_email :=
                   v_txt_email
                || CHR ( 13 )
                || ' - HORA TÉRMINO : '
                || TO_CHAR ( SYSDATE
                           , 'DD/MM/YYYY HH24:MI.SS' );
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - TEMPO EXECUÇÃO : ' || v_tempo_exec;
            v_assunto := 'MASTERSAF - ' || mnm_cproc || ' CONCLUÍDO';
            notifica ( 'S'
                     , ''
                     , v_assunto
                     , v_txt_email
                     , $$plsql_unit );
        END IF;
    END;

    PROCEDURE cabecalho ( pnm_empresa VARCHAR2
                        , pcnpj VARCHAR2
                        , v_data_hora_ini VARCHAR2
                        , mnm_cproc VARCHAR2
                        , pdt_ini DATE
                        , pdt_fim DATE
                        , pcod_estab VARCHAR2 )
    IS
    BEGIN
        --=================================================================================
        -- CABEÇALHO DO DW
        --=================================================================================
        vs_mlinha := NULL;
        vs_mlinha :=
            lib_str.w ( vs_mlinha
                      , 'EMPRESA: ' || mcod_empresa || ' - ' || pnm_empresa
                      , 1 );
        vs_mlinha :=
            lib_str.w ( vs_mlinha
                      ,    'PÁGINA : '
                        || LPAD ( vn_pagina
                                , 5
                                , '0' )
                      , 136 );
        lib_proc.add ( vs_mlinha
                     , NULL
                     , NULL
                     , 1 );

        vs_mlinha := NULL;
        vs_mlinha :=
            lib_str.w ( vs_mlinha
                      , 'CNPJ: ' || pcnpj
                      , 1 );
        lib_proc.add ( vs_mlinha
                     , NULL
                     , NULL
                     , 1 );

        vs_mlinha := NULL;
        vs_mlinha :=
            lib_str.w ( vs_mlinha
                      , 'DATA DE PROCESSAMENTO : ' || v_data_hora_ini
                      , 1 );
        lib_proc.add ( vs_mlinha
                     , NULL
                     , NULL
                     , 1 );

        vs_mlinha := NULL;
        vs_mlinha :=
            lib_str.w ( vs_mlinha
                      , LPAD ( '-'
                             , 150
                             , '-' )
                      , 1 );
        lib_proc.add ( vs_mlinha
                     , NULL
                     , NULL
                     , 1 );

        vs_mlinha := NULL;
        vs_mlinha := mnm_cproc;
        lib_proc.add ( vs_mlinha
                     , NULL
                     , NULL
                     , 1 );

        vs_mlinha := NULL;
        vs_mlinha := 'DATA INICIAL: ' || pdt_ini;
        lib_proc.add ( vs_mlinha
                     , NULL
                     , NULL
                     , 1 );

        vs_mlinha := NULL;
        vs_mlinha := 'DATA FINAL: ' || pdt_fim;
        lib_proc.add ( vs_mlinha
                     , NULL
                     , NULL
                     , 1 );

        vs_mlinha := NULL;
        vs_mlinha :=
               'PERÍODO PARA ENCERRAMENTO: '
            || TO_CHAR ( pdt_ini
                       , 'MM/YYYY' );
        lib_proc.add ( vs_mlinha
                     , NULL
                     , NULL
                     , 1 );

        vs_mlinha := NULL;
        vs_mlinha :=
            lib_str.w ( vs_mlinha
                      , LPAD ( '-'
                             , 150
                             , '-' )
                      , 1 );
        lib_proc.add ( vs_mlinha
                     , NULL
                     , NULL
                     , 1 );

        vs_mlinha := NULL;
        vs_mlinha :=
            lib_str.w ( vs_mlinha
                      , LPAD ( '-'
                             , 150
                             , '-' )
                      , 1 );
        lib_proc.add ( vs_mlinha
                     , NULL
                     , NULL
                     , 1 );

        vs_mlinha := NULL;
        vs_mlinha :=
            lib_str.w ( vs_mlinha
                      , ' '
                      , 1 );
        lib_proc.add ( vs_mlinha
                     , NULL
                     , NULL
                     , 1 );
    END cabecalho;

    FUNCTION carregar_nf_entrada ( pdt_ini DATE
                                 , pdt_fim DATE
                                 , pcod_estab VARCHAR2
                                 , v_data_hora_ini VARCHAR2 )
        RETURN INTEGER
    IS
        v_sql VARCHAR2 ( 10000 );

        --CC_LIMIT      NUMBER(7) := 1000;
        v_count_new INTEGER := 0;

        -- V_PEOPLE_DE   VARCHAR2(5) := (CASE WHEN SUBSTR(PCOD_ESTAB, 1, 2) = 'ST' THEN 'ST' ELSE 'VD' END);
        --  V_PEOPLE_PARA VARCHAR2(5) := MCOD_EMPRESA; -- DP OU DSP

        TYPE fin048_ret_nf_entr_typ IS TABLE OF msafi.dpsp_fin048_ret_nf_ent%ROWTYPE;

        v_cfo_brl_cd VARCHAR ( 10 );
        v_vlr_base_icms NUMBER;
        v_vlr_icms NUMBER;
        v_vlr_icms_st NUMBER;

        v_ok INTEGER;
        v_qtde INTEGER;

        forall_failed EXCEPTION;
        PRAGMA EXCEPTION_INIT ( forall_failed
                              , -24381 );

        l_errors NUMBER;
        l_errno NUMBER;
        l_msg VARCHAR2 ( 4000 );
        l_idx NUMBER;
    --

    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET TEMP_UNDO_ENABLED=FALSE ';

        v_sql := ' TRUNCATE TABLE MSAFI.DPSP_ENTRADA_NF_DP908_GTT ';

        EXECUTE IMMEDIATE v_sql;

        /*    v_sql := 'BEGIN INSERT INTO DPSP_ENTRADA_NF_DP908_GTT ';
        v_sql := v_sql || '  SELECT DISTINCT cod_empresa, ';
        v_sql := v_sql || '                 cod_estab,    ';
        v_sql := v_sql || '                 data_fiscal,  ';
        v_sql := v_sql || '                 movto_e_s,    ';
        v_sql := v_sql || '                 norm_dev,     ';
        v_sql := v_sql || '                 ident_docto,  ';
        v_sql := v_sql || '                 ident_fis_jur, ';
        v_sql := v_sql || '                 num_docfis,    ';
        v_sql := v_sql || '                 serie_docfis,  ';
        v_sql := v_sql || '                 sub_serie_docfis, ';
        v_sql := v_sql || '                 discri_item,      ';
        v_sql := v_sql || '                 num_autentic_nfe, ';
        v_sql := v_sql || '                 cod_produto,      ';
        v_sql := v_sql || '                 num_item          ';
        v_sql := v_sql || '   FROM msafi.dpsp_nf_entrada a    ';
        v_sql := v_sql || '  WHERE 1 = 1 ';
        v_sql := v_sql || '    AND data_fiscal BETWEEN ''' || pdt_ini ||
                 ''' AND ''' || pdt_fim || ''' ';
        v_sql := v_sql || '    AND cod_empresa = ''DP''   ';
        v_sql := v_sql || '    AND cod_estab = ''' || pcod_estab || ''' ';
        v_sql := v_sql || '    AND movto_e_s <> ''9'' ';
        v_sql := v_sql || '    AND situacao = ''N'' ';
        v_sql := v_sql || '    and cod_cfo not in (''2557'') ; END ; ';*/

        INSERT INTO msafi.dpsp_entrada_nf_dp908_gtt
            SELECT DISTINCT cod_empresa
                          , cod_estab
                          , data_fiscal
                          , movto_e_s
                          , norm_dev
                          , ident_docto
                          , ident_fis_jur
                          , num_docfis
                          , serie_docfis
                          , sub_serie_docfis
                          , discri_item
                          , num_autentic_nfe
                          , cod_produto
                          , num_item
              FROM msafi.dpsp_nf_entrada a
             WHERE 1 = 1
               AND data_fiscal BETWEEN pdt_ini AND pdt_fim
               AND cod_empresa = 'DP'
               AND cod_estab = pcod_estab
               AND movto_e_s <> '9'
               AND situacao = 'N'
               AND cod_cfo NOT IN ( '2557' );

        loga ( 'INSERT GTT ' || SQL%ROWCOUNT );

        COMMIT;

        v_qtde := 0;

        SELECT COUNT ( 1 )
          INTO v_qtde
          FROM msafi.dpsp_entrada_nf_dp908_gtt;

        COMMIT;
        loga ( 'INSERT 2.0 qtde:' || v_qtde ); --

        DELETE msafi.dpsp_msaf_fin048_xml_gtt;

        COMMIT;

        v_ok := 0;

        IF v_ok = 0
       AND pdt_fim <= TO_DATE ( '20161031'
                              , 'yyyymmdd' ) THEN
            --

            dbms_application_info.set_module ( $$plsql_unit
                                             , ' ENTRADA HIST' );

            INSERT INTO msafi.dpsp_msaf_fin048_xml_gtt
                SELECT gtt.cod_empresa
                     , gtt.cod_estab
                     , gtt.data_fiscal
                     , gtt.movto_e_s
                     , gtt.norm_dev
                     , gtt.ident_docto
                     , gtt.ident_fis_jur
                     , gtt.num_docfis
                     , gtt.serie_docfis
                     , gtt.sub_serie_docfis
                     , gtt.discri_item
                     , gtt.num_autentic_nfe
                     , gtt.cod_produto
                     , i.cfo_brl_cd
                     , NVL ( ( SELECT ip.tax_brl_bse
                                 FROM fdspprd.ps_ar_imp_bbl_bkp_nov2016@dblink_dbpsthst ip
                                WHERE 1 = 1
                                  AND i.business_unit = ip.business_unit
                                  AND i.nf_brl_id = ip.nf_brl_id
                                  AND i.nf_brl_line_num = ip.nf_brl_line_num
                                  AND ip.tax_id_bbl IN ( 'ICMS' ) )
                           , 0 )
                           AS vlr_base_icms
                     , NVL ( ( SELECT ip.tax_brl_amt
                                 FROM fdspprd.ps_ar_imp_bbl_bkp_nov2016@dblink_dbpsthst ip
                                WHERE 1 = 1
                                  AND i.business_unit = ip.business_unit
                                  AND i.nf_brl_id = ip.nf_brl_id
                                  AND i.nf_brl_line_num = ip.nf_brl_line_num
                                  AND ip.tax_id_bbl IN ( 'ICMS' ) )
                           , 0 )
                           AS vlr_icms
                     , NVL ( ( SELECT ip.tax_brl_amt
                                 FROM fdspprd.ps_ar_imp_bbl_bkp_nov2016@dblink_dbpsthst ip
                                WHERE 1 = 1
                                  AND i.business_unit = ip.business_unit
                                  AND i.nf_brl_id = ip.nf_brl_id
                                  AND i.nf_brl_line_num = ip.nf_brl_line_num
                                  AND ip.tax_id_bbl IN ( 'ICMST' ) )
                           , 0 )
                           AS vlr_icms_st
                     , 1
                     , mproc_id
                     , SYSDATE
                  FROM fdspprd.ps_ar_nfret_bbl_bkp_nov2016@dblink_dbpsthst capa
                     , fdspprd.ps_ar_itens_nf_bbl_bkp_nov2016@dblink_dbpsthst i
                     , msafi.dpsp_entrada_nf_dp908_gtt gtt
                 WHERE 1 = 1
                   AND i.inv_item_id = gtt.cod_produto
                   AND capa.nfee_key_bbl = gtt.num_autentic_nfe
                   AND capa.business_unit = i.business_unit
                   AND i.nf_brl_line_num = gtt.num_item
                   AND capa.nf_brl_id = i.nf_brl_id
                   AND i.cfo_brl_cd = '6.152';

            loga ( 'INSERT HIST 1' || SQL%ROWCOUNT );
            COMMIT;

            v_ok := 1;
        END IF;

        /*  IF v_ok = 0 AND 1 = 2
        THEN */

        dbms_application_info.set_module ( $$plsql_unit
                                         , ' ENTRADA 1' );

        /*INSERT INTO msafi.dpsp_msaf_fin048_xml_gtt
        SELECT \*+DRIVING_SITE(i)*\
         gtt.cod_empresa,
         gtt.cod_estab,
         gtt.data_fiscal,
         gtt.movto_e_s,
         gtt.norm_dev,
         gtt.ident_docto,
         gtt.ident_fis_jur,
         gtt.num_docfis,
         gtt.serie_docfis,
         gtt.sub_serie_docfis,
         gtt.discri_item,
         gtt.num_autentic_nfe,
         gtt.cod_produto,
         i.cfo_brl_cd,
         SUM(icms.tax_brl_bse) vlr_base_icms,
         SUM(icms.tax_brl_amt) vlr_icms,
         SUM(icms_st.tax_brl_amt) vlr_icms_st,
         3,
         mproc_id,
         SYSDATE
          FROM msafi.ps_ar_nfret_bbl     capa,
               msafi.ps_ar_itens_nf_bbl  i,
               msafi.ps_ar_imp_bbl       icms,
               msafi.ps_ar_imp_bbl       icms_st,
               dpsp_entrada_nf_dp908_gtt gtt
         WHERE 1 = 1
           AND i.inv_item_id = gtt.cod_produto
           AND capa.nfee_key_bbl = gtt.num_autentic_nfe
           AND capa.business_unit = i.business_unit
           AND capa.nf_brl_id = i.nf_brl_id
           AND cfo_brl_cd = '6.152'
           AND i.business_unit = icms.business_unit(+)
           AND i.nf_brl_id = icms.nf_brl_id(+)
           AND i.nf_brl_line_num = icms.nf_brl_line_num(+)
           AND icms.tax_id_bbl(+) IN ('ICMS')
           AND i.business_unit = icms_st.business_unit(+)
           AND i.nf_brl_id = icms_st.nf_brl_id(+)
           AND i.nf_brl_line_num = icms_st.nf_brl_line_num(+)
           AND icms_st.tax_id_bbl(+) IN ('ICMST')
         GROUP BY gtt.cod_empresa,
                  gtt.cod_estab,
                  gtt.data_fiscal,
                  gtt.movto_e_s,
                  gtt.norm_dev,
                  gtt.ident_docto,
                  gtt.ident_fis_jur,
                  gtt.num_docfis,
                  gtt.serie_docfis,
                  gtt.sub_serie_docfis,
                  gtt.discri_item,
                  gtt.num_autentic_nfe,
                  gtt.cod_produto,
                  i.cfo_brl_cd;*/

        v_qtde := 0;

        SELECT COUNT ( 1 )
          INTO v_qtde
          FROM msafi.dpsp_entrada_nf_dp908_gtt;

        COMMIT;
        loga ( 'INSERT 2.1 qtde:' || v_qtde ); --

        v_qtde := 0;

        FOR c IN ( SELECT /*+ DRIVING_SITE(i) parallel(32) */
                         gtt.cod_empresa
                          , gtt.cod_estab
                          , gtt.data_fiscal
                          , gtt.movto_e_s
                          , gtt.norm_dev
                          , gtt.ident_docto
                          , gtt.ident_fis_jur
                          , gtt.num_docfis
                          , gtt.serie_docfis
                          , gtt.sub_serie_docfis
                          , gtt.discri_item
                          , gtt.num_autentic_nfe
                          , gtt.cod_produto
                          , i.cfo_brl_cd
                          , SUM ( icms.tax_brl_bse ) vlr_base_icms
                          , SUM ( icms.tax_brl_amt ) vlr_icms
                          , SUM ( icms_st.tax_brl_amt ) vlr_icms_st
                          , 3
                          , mproc_id
                          , SYSDATE
                       FROM msafi.ps_ar_nfret_bbl capa
                          , msafi.ps_ar_itens_nf_bbl i
                          , msafi.ps_ar_imp_bbl icms
                          , msafi.ps_ar_imp_bbl icms_st
                          , msafi.dpsp_entrada_nf_dp908_gtt gtt
                      WHERE 1 = 1
                        AND i.inv_item_id = gtt.cod_produto
                        AND capa.nfee_key_bbl = gtt.num_autentic_nfe
                        AND capa.business_unit = i.business_unit
                        AND capa.nf_brl_id = i.nf_brl_id
                        AND cfo_brl_cd = '6.152'
                        AND i.business_unit = icms.business_unit(+)
                        AND i.nf_brl_id = icms.nf_brl_id(+)
                        AND i.nf_brl_line_num = icms.nf_brl_line_num(+)
                        AND icms.tax_id_bbl(+) IN ( 'ICMS' )
                        AND i.business_unit = icms_st.business_unit(+)
                        AND i.nf_brl_id = icms_st.nf_brl_id(+)
                        AND i.nf_brl_line_num = icms_st.nf_brl_line_num(+)
                        AND icms_st.tax_id_bbl(+) IN ( 'ICMST' )
                   GROUP BY gtt.cod_empresa
                          , gtt.cod_estab
                          , gtt.data_fiscal
                          , gtt.movto_e_s
                          , gtt.norm_dev
                          , gtt.ident_docto
                          , gtt.ident_fis_jur
                          , gtt.num_docfis
                          , gtt.serie_docfis
                          , gtt.sub_serie_docfis
                          , gtt.discri_item
                          , gtt.num_autentic_nfe
                          , gtt.cod_produto
                          , i.cfo_brl_cd ) LOOP
            v_qtde := v_qtde + 1;

            dbms_application_info.set_module ( $$plsql_unit
                                             , ' ENTRADA 2.1 Reg:' || v_qtde );

            /*      BEGIN

                    SELECT \*+DRIVING_SITE(i)*\
                     i.cfo_brl_cd,
                     SUM(icms.tax_brl_bse) vlr_base_icms,
                     SUM(icms.tax_brl_amt) vlr_icms,
                     SUM(icms_st.tax_brl_amt) vlr_icms_st
                      INTO v_cfo_brl_cd, v_vlr_base_icms, v_vlr_icms, v_vlr_icms_st
                      FROM msafi.ps_ar_nfret_bbl    capa,
                           msafi.ps_ar_itens_nf_bbl i,
                           msafi.ps_ar_imp_bbl      icms,
                           msafi.ps_ar_imp_bbl      icms_st
                     WHERE 1 = 1
                       AND capa.business_unit = i.business_unit
                       AND capa.nf_brl_id = i.nf_brl_id
                       AND cfo_brl_cd = '6.152'
                       AND i.business_unit = icms.business_unit(+)
                       AND i.nf_brl_id = icms.nf_brl_id(+)
                       AND i.nf_brl_line_num = icms.nf_brl_line_num(+)
                       AND icms.tax_id_bbl(+) IN ('ICMS')
                       AND i.business_unit = icms_st.business_unit(+)
                       AND i.nf_brl_id = icms_st.nf_brl_id(+)
                       AND i.nf_brl_line_num = icms_st.nf_brl_line_num(+)
                       AND icms_st.tax_id_bbl(+) IN ('ICMST')
                       AND i.inv_item_id = c.cod_produto
                       AND capa.nfee_key_bbl = c.num_autentic_nfe
                     GROUP BY i.cfo_brl_cd;

                  EXCEPTION
                    WHEN no_data_found THEN
                      v_cfo_brl_cd    := NULL;
                      v_vlr_base_icms := NULL;
                      v_vlr_icms      := NULL;
                      v_vlr_icms_st   := NULL;
                  END;*/

            INSERT INTO msafi.dpsp_msaf_fin048_xml_gtt
                 VALUES ( c.cod_empresa
                        , c.cod_estab
                        , c.data_fiscal
                        , c.movto_e_s
                        , c.norm_dev
                        , c.ident_docto
                        , c.ident_fis_jur
                        , c.num_docfis
                        , c.serie_docfis
                        , c.sub_serie_docfis
                        , c.discri_item
                        , c.num_autentic_nfe
                        , c.cod_produto
                        , -- ps
                          c.cfo_brl_cd
                        , c.vlr_base_icms
                        , c.vlr_icms
                        , c.vlr_icms_st
                        , -- fixo
                          3
                        , mproc_id
                        , SYSDATE );
        END LOOP;

        SELECT COUNT ( 1 )
          INTO v_qtde
          FROM msafi.dpsp_msaf_fin048_xml_gtt;

        COMMIT;
        loga ( 'INSERT 2 qtde:' || v_qtde ); --
        v_ok := 1;

        --  END IF;

        /* IF v_ok = 0

        THEN*/

        dbms_application_info.set_module ( $$plsql_unit
                                         , ' ENTRADA - 2' );

        INSERT INTO msafi.dpsp_msaf_fin048_xml_gtt
            SELECT /*+DRIVING_SITE(i)*/
                  gtt.cod_empresa
                   , gtt.cod_estab
                   , gtt.data_fiscal
                   , gtt.movto_e_s
                   , gtt.norm_dev
                   , gtt.ident_docto
                   , gtt.ident_fis_jur
                   , gtt.num_docfis
                   , gtt.serie_docfis
                   , gtt.sub_serie_docfis
                   , gtt.discri_item
                   , gtt.num_autentic_nfe
                   , gtt.cod_produto
                   , cfop_forn cfo_brl_cd
                   , SUM ( vlr_base_icms ) vlr_base_icms
                   , SUM ( vlr_icms ) vlr_icms
                   , SUM ( vlr_icms_st ) vlr_icms_st
                   , 3
                   , mproc_id
                   , SYSDATE
                FROM msafi.ps_xml_forn xml_forn
                   , msafi.dpsp_entrada_nf_dp908_gtt gtt
               WHERE xml_forn.inv_item_id = gtt.cod_produto
                 AND xml_forn.nfe_verif_code_pbl = gtt.num_autentic_nfe
                 AND xml_forn.cfop_forn IN ( '6101'
                                           , '6102'
                                           , '6105'
                                           , '6106'
                                           , '6401'
                                           , '6403'
                                           , '6404' )
            GROUP BY gtt.cod_empresa
                   , gtt.cod_estab
                   , gtt.data_fiscal
                   , gtt.movto_e_s
                   , gtt.norm_dev
                   , gtt.ident_docto
                   , gtt.ident_fis_jur
                   , gtt.num_docfis
                   , gtt.serie_docfis
                   , gtt.sub_serie_docfis
                   , gtt.discri_item
                   , gtt.num_autentic_nfe
                   , gtt.cod_produto
                   , cfop_forn;

        COMMIT;

        SELECT COUNT ( 1 )
          INTO v_qtde
          FROM msafi.dpsp_msaf_fin048_xml_gtt;

        loga ( 'INSERT 2 qtde:' || v_qtde );
        v_ok := 1;

        -- END IF;

        --   END LOOP;
        -- END LOOP;

        dbms_application_info.set_module ( $$plsql_unit
                                         , ' ENTRADA  3' );

        /*
            v_sql := '            SELECT   * ';
            v_sql := v_sql || '        FROM ('; --  1
            v_sql := v_sql || '      SELECT X07.COD_EMPRESA AS COD_EMPRESA '; --  1     ---  QUERY FORNECEDOR
            v_sql := v_sql || '            ,';
            v_sql := v_sql || '             X07.COD_ESTAB AS COD_ESTAB       '; --  2
            v_sql := v_sql || '            ,';
            v_sql := v_sql || '             X07.DATA_FISCAL AS DATA_FISCAL '; --  3
            v_sql := v_sql || '            ,';
            v_sql := v_sql || '             X07.NUM_DOCFIS AS NUM_DOCFIS '; --  4
            v_sql := v_sql || '            ,';
            v_sql := v_sql ||
                     '             X07.NUM_AUTENTIC_NFE AS NUM_AUTENTIC_NFE  '; --  5
            v_sql := v_sql || '            ,';
            v_sql := v_sql || '             X04.COD_FIS_JUR AS COD_FIS_JUR '; --  6
            v_sql := v_sql || '            ,';
            v_sql := v_sql || '             X04.CPF_CGC AS CPF_CGC   '; --  7
            v_sql := v_sql || '            ,';
            v_sql := v_sql || '             X2005.COD_DOCTO AS COD_DOCTO  '; --  8
            v_sql := v_sql || '            ,';
            v_sql := v_sql || '             X2024.COD_MODELO AS COD_MODELO '; --  9
            v_sql := v_sql || '            ,';
            v_sql := v_sql || '             X2012.COD_CFO AS COD_CFO '; --  10
            v_sql := v_sql || '            ,';
            v_sql := v_sql ||
                     '             X2006.COD_NATUREZA_OP AS COD_NAT_OPER  '; --  11
            v_sql := v_sql || '            ,';
            v_sql := v_sql || '             X2013.COD_PRODUTO AS COD_PRODUTO '; --  12
            v_sql := v_sql || '            ,';
            v_sql := v_sql ||
                     '             SUBSTR(X2013.DESCRICAO, 1, 255) AS DESCRICAO '; --  13
            v_sql := v_sql || '            ,';
            v_sql := v_sql || '             Y2025.COD_SITUACAO_A AS CST_A   '; --  14
            v_sql := v_sql || '            ,';
            v_sql := v_sql || '             Y2026.COD_SITUACAO_B AS CST_B '; --  15
            v_sql := v_sql || '            ,';
            v_sql := v_sql || '             X08.QUANTIDADE AS QUANTIDADE '; --  16
            v_sql := v_sql || '            ,';
            v_sql := v_sql || '             X2043.COD_NBM AS NCM  '; --  17
            v_sql := v_sql || '            ,';
            v_sql := v_sql || '             X08.NUM_ITEM AS NUM_ITEM '; --  18
            v_sql := v_sql || '            ,';
            v_sql := v_sql ||
                     '             X08.VLR_CONTAB_ITEM AS VLR_CONTABIL_ITEM  '; --  19
            v_sql := v_sql || '            ,';
            v_sql := v_sql || '             X08.VLR_ITEM AS VLR_ITEM  '; --  20
            v_sql := v_sql || '            ,';
            v_sql := v_sql || '             (SELECT NVL(X08_BASE.VLR_BASE, 0)';
            v_sql := v_sql || '                FROM MSAF.X08_BASE_MERC X08_BASE';
            v_sql := v_sql ||
                     '               WHERE X08.COD_EMPRESA = X08_BASE.COD_EMPRESA';
            v_sql := v_sql ||
                     '                 AND X08.COD_ESTAB = X08_BASE.COD_ESTAB';
            v_sql := v_sql ||
                     '                 AND X08.DATA_FISCAL = X08_BASE.DATA_FISCAL';
            v_sql := v_sql ||
                     '                 AND X08.MOVTO_E_S = X08_BASE.MOVTO_E_S';
            v_sql := v_sql ||
                     '                 AND X08.NORM_DEV = X08_BASE.NORM_DEV';
            v_sql := v_sql ||
                     '                 AND X08.IDENT_DOCTO = X08_BASE.IDENT_DOCTO';
            v_sql := v_sql ||
                     '                 AND X08.IDENT_FIS_JUR = X08_BASE.IDENT_FIS_JUR';
            v_sql := v_sql ||
                     '                 AND X08.NUM_DOCFIS = X08_BASE.NUM_DOCFIS';
            v_sql := v_sql ||
                     '                 AND X08.SERIE_DOCFIS = X08_BASE.SERIE_DOCFIS';
            v_sql := v_sql ||
                     '                 AND X08.SUB_SERIE_DOCFIS = X08_BASE.SUB_SERIE_DOCFIS';
            v_sql := v_sql ||
                     '                 AND X08.DISCRI_ITEM = X08_BASE.DISCRI_ITEM';
            v_sql := v_sql ||
                     '                 AND X08_BASE.COD_TRIBUTO = ''ICMS''';
            v_sql := v_sql ||
                     '                 AND X08_BASE.COD_TRIBUTACAO = ''1'') AS VLR_BASE_ICMS_1   '; -- 21
            v_sql := v_sql || '            ,';
            v_sql := v_sql ||
                     '             (SELECT NVL(X08_BASE_TRIB.ALIQ_TRIBUTO, 0)';
            v_sql := v_sql ||
                     '                FROM MSAF.X08_TRIB_MERC X08_BASE_TRIB';
            v_sql := v_sql ||
                     '               WHERE X08.COD_EMPRESA = X08_BASE_TRIB.COD_EMPRESA';
            v_sql := v_sql ||
                     '                 AND X08.COD_ESTAB = X08_BASE_TRIB.COD_ESTAB';
            v_sql := v_sql ||
                     '                 AND X08.DATA_FISCAL = X08_BASE_TRIB.DATA_FISCAL';
            v_sql := v_sql ||
                     '                 AND X08.MOVTO_E_S = X08_BASE_TRIB.MOVTO_E_S';
            v_sql := v_sql ||
                     '                 AND X08.NORM_DEV = X08_BASE_TRIB.NORM_DEV';
            v_sql := v_sql ||
                     '                 AND X08.IDENT_DOCTO = X08_BASE_TRIB.IDENT_DOCTO';
            v_sql := v_sql ||
                     '                 AND X08.IDENT_FIS_JUR = X08_BASE_TRIB.IDENT_FIS_JUR';
            v_sql := v_sql ||
                     '                 AND X08.NUM_DOCFIS = X08_BASE_TRIB.NUM_DOCFIS';
            v_sql := v_sql ||
                     '                 AND X08.SERIE_DOCFIS = X08_BASE_TRIB.SERIE_DOCFIS ';
            v_sql := v_sql ||
                     '                 AND X08.SUB_SERIE_DOCFIS = X08_BASE_TRIB.SUB_SERIE_DOCFIS ';
            v_sql := v_sql ||
                     '                 AND X08.DISCRI_ITEM = X08_BASE_TRIB.DISCRI_ITEM';
            v_sql := v_sql ||
                     '                 AND X08_BASE_TRIB.COD_TRIBUTO = ''ICMS'') AS VLR_ALIQUOTA    '; -- 22

            v_sql := v_sql || '            ,';
            v_sql := v_sql ||
                     '             (SELECT NVL(X08_BASE_TRIB.VLR_TRIBUTO, 0)';
            v_sql := v_sql ||
                     '                FROM MSAF.X08_TRIB_MERC X08_BASE_TRIB';
            v_sql := v_sql ||
                     '               WHERE X08.COD_EMPRESA = X08_BASE_TRIB.COD_EMPRESA';
            v_sql := v_sql ||
                     '                 AND X08.COD_ESTAB = X08_BASE_TRIB.COD_ESTAB';
            v_sql := v_sql ||
                     '                 AND X08.DATA_FISCAL = X08_BASE_TRIB.DATA_FISCAL';
            v_sql := v_sql ||
                     '                 AND X08.MOVTO_E_S = X08_BASE_TRIB.MOVTO_E_S';
            v_sql := v_sql ||
                     '                 AND X08.NORM_DEV = X08_BASE_TRIB.NORM_DEV';
            v_sql := v_sql ||
                     '                 AND X08.IDENT_DOCTO = X08_BASE_TRIB.IDENT_DOCTO';
            v_sql := v_sql ||
                     '                 AND X08.IDENT_FIS_JUR = X08_BASE_TRIB.IDENT_FIS_JUR';
            v_sql := v_sql ||
                     '                 AND X08.NUM_DOCFIS = X08_BASE_TRIB.NUM_DOCFIS';
            v_sql := v_sql ||
                     '                 AND X08.SERIE_DOCFIS = X08_BASE_TRIB.SERIE_DOCFIS';
            v_sql := v_sql ||
                     '                 AND X08.SUB_SERIE_DOCFIS = X08_BASE_TRIB.SUB_SERIE_DOCFIS';
            v_sql := v_sql ||
                     '                 AND X08.DISCRI_ITEM = X08_BASE_TRIB.DISCRI_ITEM';
            v_sql := v_sql ||
                     '                 AND X08_BASE_TRIB.COD_TRIBUTO = ''ICMS'') AS VLR_ICMS_PROPRIO '; --23
            v_sql := v_sql || '            ,';
            v_sql := v_sql || '             (SELECT NVL(X08_BASE.VLR_BASE, 0)';
            v_sql := v_sql || '                FROM MSAF.X08_BASE_MERC X08_BASE';
            v_sql := v_sql ||
                     '               WHERE X08.COD_EMPRESA = X08_BASE.COD_EMPRESA';
            v_sql := v_sql ||
                     '                 AND X08.COD_ESTAB = X08_BASE.COD_ESTAB';
            v_sql := v_sql ||
                     '                 AND X08.DATA_FISCAL = X08_BASE.DATA_FISCAL';
            v_sql := v_sql ||
                     '                 AND X08.MOVTO_E_S = X08_BASE.MOVTO_E_S';
            v_sql := v_sql ||
                     '                 AND X08.NORM_DEV = X08_BASE.NORM_DEV';
            v_sql := v_sql ||
                     '                 AND X08.IDENT_DOCTO = X08_BASE.IDENT_DOCTO';
            v_sql := v_sql ||
                     '                 AND X08.IDENT_FIS_JUR = X08_BASE.IDENT_FIS_JUR';
            v_sql := v_sql ||
                     '                 AND X08.NUM_DOCFIS = X08_BASE.NUM_DOCFIS';
            v_sql := v_sql ||
                     '                 AND X08.SERIE_DOCFIS = X08_BASE.SERIE_DOCFIS';
            v_sql := v_sql ||
                     '                 AND X08.SUB_SERIE_DOCFIS = X08_BASE.SUB_SERIE_DOCFIS';
            v_sql := v_sql ||
                     '                 AND X08.DISCRI_ITEM = X08_BASE.DISCRI_ITEM';
            v_sql := v_sql ||
                     '                 AND X08_BASE.COD_TRIBUTO = ''ICMS''';
            v_sql := v_sql ||
                     '                 AND X08_BASE.COD_TRIBUTACAO = ''2'') AS VLR_BASE_ICMS_2    '; -- 24
            v_sql := v_sql || '            ,';
            v_sql := v_sql || '             (SELECT NVL(SUM(X08_BASE.VLR_BASE), 0)';
            v_sql := v_sql || '                FROM MSAF.X08_BASE_MERC X08_BASE ';
            v_sql := v_sql ||
                     '               WHERE X08.COD_EMPRESA = X08_BASE.COD_EMPRESA ';
            v_sql := v_sql ||
                     '                 AND X08.COD_ESTAB = X08_BASE.COD_ESTAB ';
            v_sql := v_sql ||
                     '                 AND X08.DATA_FISCAL = X08_BASE.DATA_FISCAL ';
            v_sql := v_sql ||
                     '                 AND X08.MOVTO_E_S = X08_BASE.MOVTO_E_S ';
            v_sql := v_sql ||
                     '                 AND X08.NORM_DEV = X08_BASE.NORM_DEV ';
            v_sql := v_sql ||
                     '                 AND X08.IDENT_DOCTO = X08_BASE.IDENT_DOCTO ';
            v_sql := v_sql ||
                     '                 AND X08.IDENT_FIS_JUR = X08_BASE.IDENT_FIS_JUR ';
            v_sql := v_sql ||
                     '                 AND X08.NUM_DOCFIS = X08_BASE.NUM_DOCFIS ';
            v_sql := v_sql ||
                     '                 AND X08.SERIE_DOCFIS = X08_BASE.SERIE_DOCFIS ';
            v_sql := v_sql ||
                     '                 AND X08.SUB_SERIE_DOCFIS = X08_BASE.SUB_SERIE_DOCFIS ';
            v_sql := v_sql ||
                     '                 AND X08.DISCRI_ITEM = X08_BASE.DISCRI_ITEM ';
            v_sql := v_sql ||
                     '                 AND X08_BASE.COD_TRIBUTO = ''ICMS''';
            v_sql := v_sql ||
                     '                 AND X08_BASE.COD_TRIBUTACAO = ''3'') AS VLR_BASE_ICMS_3  '; --  25
            v_sql := v_sql || '            ,';

            v_sql := v_sql ||
                     '             REPLACE(aux.cfo_brl_cd, ''.'', '''') AS CFOP_SAIDA_ORIGEM '; --  26
            v_sql := v_sql || '            ,';
            v_sql := v_sql || '             X2012.COD_CFO AS CFOP_ENTRADA_ORIGEM '; --  27
            v_sql := v_sql || '            ,';

            v_sql := v_sql ||
                     '             aux.VLR_BASE_ICMS AS VALOR_BASE_ICMS_ORIGEM,  '; --  28

            v_sql := v_sql ||
                     '     (SELECT NVL(C.ICMSTAX_BRL_PCT, 0) AS ALIQ_ICMS ';
            v_sql := v_sql || '     FROM msafi.PS_NF_LN_BRL  C ';
            v_sql := v_sql || '     WHERE C.NF_BRL_ID = X07.NUM_CONTROLE_DOCTO ';
            v_sql := v_sql ||
                     '     AND C.BUSINESS_UNIT = (CASE X07.COD_EMPRESA WHEN ''DP'' THEN  ';
            v_sql := v_sql || '     ''POCDP'' WHEN ''DSP'' THEN ''POCOM'' END) ';
            v_sql := v_sql ||
                     '      AND C.NF_BRL_LINE_NUM = X08.NUM_ITEM) AS VALOR_ALIQUOTA_ORIGEM , '; -- 29
            v_sql := v_sql || '             aux.VLR_ICMS AS VALOR_ICMS_ORIGEM,  '; --  30
            v_sql := v_sql ||
                     '             TO_CHAR(aux.VLR_ICMS_ST) AS CST_ICMS_ORIGEM    , '; --  31
            v_sql := v_sql ||
                     '            X07.NUM_CONTROLE_DOCTO AS NUM_CONTROLE_DOCTO,  ';
            v_sql := v_sql || '            ''' || mproc_id ||
                     '''     AS PROC_ID  ,';
            v_sql := v_sql || '            ''' || mnm_usuario ||
                     ''' AS NM_USUARIO ,';
            v_sql := v_sql || '             SYSDATE AS DATA_CARGA ,';
            v_sql := v_sql || '             NULL ';
            v_sql := v_sql ||
                     '        FROM MSAF.X07_DOCTO_FISCAL    partition for ( TO_DATE(''' ||
                     to_char(pdt_fim, 'YYYYMMDD') || ''',''YYYYMMDD''))  X07, ';
            v_sql := v_sql ||
                     '             MSAF.X08_ITENS_MERC      partition for ( TO_DATE(''' ||
                     to_char(pdt_fim, 'YYYYMMDD') || ''',''YYYYMMDD''))  X08, ';
            v_sql := v_sql || '             MSAF.X04_PESSOA_FIS_JUR X04,   ';
            v_sql := v_sql || '             MSAF.ESTADO             ESTADO,';
            v_sql := v_sql || '             MSAF.X2005_TIPO_DOCTO   X2005, ';
            v_sql := v_sql || '             MSAF.X2024_MODELO_DOCTO X2024, ';
            v_sql := v_sql || '             MSAF.X2012_COD_FISCAL   X2012, ';
            v_sql := v_sql || '             MSAF.X2013_PRODUTO      X2013, ';
            v_sql := v_sql || '             MSAF.X2043_COD_NBM      X2043, ';
            v_sql := v_sql || '             MSAF.Y2025_SIT_TRB_UF_A Y2025, ';
            v_sql := v_sql || '             MSAF.Y2026_SIT_TRB_UF_B Y2026, ';
            v_sql := v_sql || '             MSAF.X2006_NATUREZA_OP  X2006';
            v_sql := v_sql || '             , msafi.DPSP_MSAF_FIN048_XML_GTT aux ';
            v_sql := v_sql || '       WHERE ';
            v_sql := v_sql || ' X07.DATA_FISCAL BETWEEN TO_DATE(''' ||
                     to_char(pdt_ini, 'DDMMYYYY') ||
                     ''',''DDMMYYYY'') AND TO_DATE(''' ||
                     to_char(pdt_fim, 'DDMMYYYY') || ''',''DDMMYYYY'') ';
            v_sql := v_sql || '       AND X07.COD_EMPRESA     = ''' || mcod_empresa ||
                     ''' ';
            v_sql := v_sql || '       AND X07.COD_ESTAB = ''' || pcod_estab ||
                     ''' ';
            v_sql := v_sql || '       AND X07.MOVTO_E_S <> ''9'' ';
            v_sql := v_sql || '       AND X07.SITUACAO = ''N''';
            v_sql := v_sql || '       AND X07.COD_EMPRESA = X08.COD_EMPRESA ';
            v_sql := v_sql || '       AND X07.COD_ESTAB = X08.COD_ESTAB ';
            v_sql := v_sql || '       AND X07.DATA_FISCAL = X08.DATA_FISCAL ';
            v_sql := v_sql || '       AND X07.MOVTO_E_S = X08.MOVTO_E_S ';
            v_sql := v_sql || '       AND X07.NORM_DEV = X08.NORM_DEV ';
            v_sql := v_sql || '       AND X07.IDENT_DOCTO = X08.IDENT_DOCTO ';
            v_sql := v_sql || '       AND X07.IDENT_FIS_JUR = X08.IDENT_FIS_JUR ';
            v_sql := v_sql || '       AND X07.NUM_DOCFIS = X08.NUM_DOCFIS ';
            v_sql := v_sql || '       AND X07.SERIE_DOCFIS = X08.SERIE_DOCFIS ';
            v_sql := v_sql ||
                     '       AND X07.SUB_SERIE_DOCFIS = X08.SUB_SERIE_DOCFIS ';
            v_sql := v_sql || '       AND X07.IDENT_FIS_JUR = X04.IDENT_FIS_JUR(+) ';
            v_sql := v_sql || '       AND X04.IDENT_ESTADO = ESTADO.IDENT_ESTADO(+) ';
            v_sql := v_sql || '       AND X07.IDENT_DOCTO = X2005.IDENT_DOCTO(+) ';
            v_sql := v_sql || '       AND X07.IDENT_MODELO = X2024.IDENT_MODELO(+) ';
            v_sql := v_sql || '       AND X08.IDENT_CFO = X2012.IDENT_CFO(+) ';
            v_sql := v_sql || '       AND X08.IDENT_PRODUTO = X2013.IDENT_PRODUTO(+) ';
            v_sql := v_sql || '       AND X2013.IDENT_NBM = X2043.IDENT_NBM(+) ';
            v_sql := v_sql ||
                     '       AND Y2025.IDENT_SITUACAO_A(+) = X08.IDENT_SITUACAO_A ';
            v_sql := v_sql ||
                     '       AND X08.IDENT_SITUACAO_B = Y2026.IDENT_SITUACAO_B(+) ';
            v_sql := v_sql ||
                     '       AND X08.IDENT_NATUREZA_OP = X2006.IDENT_NATUREZA_OP(+) ';

            --
            v_sql := v_sql || '       AND X07.COD_EMPRESA = AUX.COD_EMPRESA ';
            v_sql := v_sql || '       AND X07.COD_ESTAB = AUX.COD_ESTAB ';
            v_sql := v_sql || '       AND X07.DATA_FISCAL = AUX.DATA_FISCAL ';
            v_sql := v_sql || '       AND X07.MOVTO_E_S = AUX.MOVTO_E_S ';
            v_sql := v_sql || '       AND X07.NORM_DEV = AUX.NORM_DEV ';
            v_sql := v_sql || '       AND X07.IDENT_DOCTO = AUX.IDENT_DOCTO ';
            v_sql := v_sql || '       AND X07.IDENT_FIS_JUR = AUX.IDENT_FIS_JUR ';
            v_sql := v_sql || '       AND X07.NUM_DOCFIS = AUX.NUM_DOCFIS ';
            v_sql := v_sql || '       AND X07.SERIE_DOCFIS = AUX.SERIE_DOCFIS ';
            v_sql := v_sql ||
                     '       AND X07.SUB_SERIE_DOCFIS = AUX.SUB_SERIE_DOCFIS ';
            v_sql := v_sql || '       AND X08.DISCRI_ITEM = AUX.DISCRI_ITEM ';
            v_sql := v_sql || '       AND aux.proc_id =  ' || mproc_id;
            v_sql := v_sql || '       ) ';

            insert into msafi.teste_jj values(v_sql,sysdate);
        */
        FOR c
            IN ( SELECT *
                   FROM ( SELECT /*+ parallel(32) */
                                x07.cod_empresa AS cod_empresa
                               , x07.cod_estab AS cod_estab
                               , x07.data_fiscal AS data_fiscal
                               , x07.num_docfis AS num_docfis
                               , x07.num_autentic_nfe AS num_autentic_nfe
                               , x04.cod_fis_jur AS cod_fis_jur
                               , x04.cpf_cgc AS cpf_cgc
                               , x2005.cod_docto AS cod_docto
                               , x2024.cod_modelo AS cod_modelo
                               , x2012.cod_cfo AS cod_cfo
                               , x2006.cod_natureza_op AS natureza_operacao
                               , x2013.cod_produto AS cod_produto
                               , SUBSTR ( x2013.descricao
                                        , 1
                                        , 255 )
                                     AS descricao
                               , y2025.cod_situacao_a AS cst_a
                               , y2026.cod_situacao_b AS cst_b
                               , x08.quantidade AS quantidade
                               , x2043.cod_nbm AS ncm
                               , x08.num_item AS num_item
                               , x08.vlr_contab_item AS vlr_contabil_item
                               , x08.vlr_item AS vlr_item
                               , ( SELECT NVL ( x08_base.vlr_base, 0 )
                                     FROM msaf.x08_base_merc x08_base
                                    WHERE x08.cod_empresa = x08_base.cod_empresa
                                      AND x08.cod_estab = x08_base.cod_estab
                                      AND x08.data_fiscal = x08_base.data_fiscal
                                      AND x08.movto_e_s = x08_base.movto_e_s
                                      AND x08.norm_dev = x08_base.norm_dev
                                      AND x08.ident_docto = x08_base.ident_docto
                                      AND x08.ident_fis_jur = x08_base.ident_fis_jur
                                      AND x08.num_docfis = x08_base.num_docfis
                                      AND x08.serie_docfis = x08_base.serie_docfis
                                      AND x08.sub_serie_docfis = x08_base.sub_serie_docfis
                                      AND x08.discri_item = x08_base.discri_item
                                      AND x08_base.cod_tributo = 'ICMS'
                                      AND x08_base.cod_tributacao = '1' )
                                     AS vlr_base_icms_1
                               , ( SELECT NVL ( x08_base_trib.aliq_tributo, 0 )
                                     FROM msaf.x08_trib_merc x08_base_trib
                                    WHERE x08.cod_empresa = x08_base_trib.cod_empresa
                                      AND x08.cod_estab = x08_base_trib.cod_estab
                                      AND x08.data_fiscal = x08_base_trib.data_fiscal
                                      AND x08.movto_e_s = x08_base_trib.movto_e_s
                                      AND x08.norm_dev = x08_base_trib.norm_dev
                                      AND x08.ident_docto = x08_base_trib.ident_docto
                                      AND x08.ident_fis_jur = x08_base_trib.ident_fis_jur
                                      AND x08.num_docfis = x08_base_trib.num_docfis
                                      AND x08.serie_docfis = x08_base_trib.serie_docfis
                                      AND x08.sub_serie_docfis = x08_base_trib.sub_serie_docfis
                                      AND x08.discri_item = x08_base_trib.discri_item
                                      AND x08_base_trib.cod_tributo = 'ICMS' )
                                     AS vlr_aliquota
                               , ( SELECT NVL ( x08_base_trib.vlr_tributo, 0 )
                                     FROM msaf.x08_trib_merc x08_base_trib
                                    WHERE x08.cod_empresa = x08_base_trib.cod_empresa
                                      AND x08.cod_estab = x08_base_trib.cod_estab
                                      AND x08.data_fiscal = x08_base_trib.data_fiscal
                                      AND x08.movto_e_s = x08_base_trib.movto_e_s
                                      AND x08.norm_dev = x08_base_trib.norm_dev
                                      AND x08.ident_docto = x08_base_trib.ident_docto
                                      AND x08.ident_fis_jur = x08_base_trib.ident_fis_jur
                                      AND x08.num_docfis = x08_base_trib.num_docfis
                                      AND x08.serie_docfis = x08_base_trib.serie_docfis
                                      AND x08.sub_serie_docfis = x08_base_trib.sub_serie_docfis
                                      AND x08.discri_item = x08_base_trib.discri_item
                                      AND x08_base_trib.cod_tributo = 'ICMS' )
                                     AS vlr_icms_proprio
                               , ( SELECT NVL ( x08_base.vlr_base, 0 )
                                     FROM msaf.x08_base_merc x08_base
                                    WHERE x08.cod_empresa = x08_base.cod_empresa
                                      AND x08.cod_estab = x08_base.cod_estab
                                      AND x08.data_fiscal = x08_base.data_fiscal
                                      AND x08.movto_e_s = x08_base.movto_e_s
                                      AND x08.norm_dev = x08_base.norm_dev
                                      AND x08.ident_docto = x08_base.ident_docto
                                      AND x08.ident_fis_jur = x08_base.ident_fis_jur
                                      AND x08.num_docfis = x08_base.num_docfis
                                      AND x08.serie_docfis = x08_base.serie_docfis
                                      AND x08.sub_serie_docfis = x08_base.sub_serie_docfis
                                      AND x08.discri_item = x08_base.discri_item
                                      AND x08_base.cod_tributo = 'ICMS'
                                      AND x08_base.cod_tributacao = '2' )
                                     AS vlr_base_icms_2
                               , ( SELECT NVL ( SUM ( x08_base.vlr_base ), 0 )
                                     FROM msaf.x08_base_merc x08_base
                                    WHERE x08.cod_empresa = x08_base.cod_empresa
                                      AND x08.cod_estab = x08_base.cod_estab
                                      AND x08.data_fiscal = x08_base.data_fiscal
                                      AND x08.movto_e_s = x08_base.movto_e_s
                                      AND x08.norm_dev = x08_base.norm_dev
                                      AND x08.ident_docto = x08_base.ident_docto
                                      AND x08.ident_fis_jur = x08_base.ident_fis_jur
                                      AND x08.num_docfis = x08_base.num_docfis
                                      AND x08.serie_docfis = x08_base.serie_docfis
                                      AND x08.sub_serie_docfis = x08_base.sub_serie_docfis
                                      AND x08.discri_item = x08_base.discri_item
                                      AND x08_base.cod_tributo = 'ICMS'
                                      AND x08_base.cod_tributacao = '3' )
                                     AS vlr_base_icms_3
                               , REPLACE ( aux.cfo_brl_cd
                                         , '.'
                                         , '' )
                                     AS cfop_saida_origem
                               , x2012.cod_cfo AS cfop_entrada_origem
                               , aux.vlr_base_icms AS valor_base_icms_origem
                               , ( SELECT NVL ( c.icmstax_brl_pct, 0 ) AS aliq_icms
                                     FROM msafi.ps_nf_ln_brl c
                                    WHERE c.nf_brl_id = x07.num_controle_docto
                                      AND c.business_unit =
                                              (CASE x07.cod_empresa WHEN 'DP' THEN 'POCDP' WHEN 'DSP' THEN 'POCOM' END)
                                      AND c.nf_brl_line_num = x08.num_item )
                                     AS valor_aliquota_origem
                               , aux.vlr_icms AS valor_icms_origem
                               , TO_CHAR ( aux.vlr_icms_st ) AS cst_origem
                               , x07.num_controle_docto AS num_controle_docto
                               , proc_id AS proc_id
                               , mnm_usuario AS nm_usuario
                               , SYSDATE AS dt_carga
                               , NULL status
                            FROM msaf.x07_docto_fiscal x07
                               , msaf.x08_itens_merc x08
                               , msaf.x04_pessoa_fis_jur x04
                               , msaf.estado estado
                               , msaf.x2005_tipo_docto x2005
                               , msaf.x2024_modelo_docto x2024
                               , msaf.x2012_cod_fiscal x2012
                               , msaf.x2013_produto x2013
                               , msaf.x2043_cod_nbm x2043
                               , msaf.y2025_sit_trb_uf_a y2025
                               , msaf.y2026_sit_trb_uf_b y2026
                               , msaf.x2006_natureza_op x2006
                               , msafi.dpsp_msaf_fin048_xml_gtt aux
                           WHERE x07.data_fiscal BETWEEN pdt_ini AND pdt_fim
                             AND x07.cod_empresa = mcod_empresa
                             AND x07.cod_estab = pcod_estab
                             AND x07.movto_e_s <> '9'
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
                             AND x07.ident_fis_jur = x04.ident_fis_jur(+)
                             AND x04.ident_estado = estado.ident_estado(+)
                             AND x07.ident_docto = x2005.ident_docto(+)
                             AND x07.ident_modelo = x2024.ident_modelo(+)
                             AND x08.ident_cfo = x2012.ident_cfo(+)
                             AND x08.ident_produto = x2013.ident_produto(+)
                             AND x2013.ident_nbm = x2043.ident_nbm(+)
                             AND y2025.ident_situacao_a(+) = x08.ident_situacao_a
                             AND x08.ident_situacao_b = y2026.ident_situacao_b(+)
                             AND x08.ident_natureza_op = x2006.ident_natureza_op(+)
                             AND x07.cod_empresa = aux.cod_empresa
                             AND x07.cod_estab = aux.cod_estab
                             AND x07.data_fiscal = aux.data_fiscal
                             AND x07.movto_e_s = aux.movto_e_s
                             AND x07.norm_dev = aux.norm_dev
                             AND x07.ident_docto = aux.ident_docto
                             AND x07.ident_fis_jur = aux.ident_fis_jur
                             AND x07.num_docfis = aux.num_docfis
                             AND x07.serie_docfis = aux.serie_docfis
                             AND x07.sub_serie_docfis = aux.sub_serie_docfis
                             AND x08.discri_item = aux.discri_item ) ) LOOP
            INSERT INTO msafi.dpsp_fin048_ret_nf_ent
                 VALUES ( c.cod_empresa
                        , c.cod_estab
                        , c.data_fiscal
                        , c.num_docfis
                        , c.num_autentic_nfe
                        , c.cod_fis_jur
                        , c.cpf_cgc
                        , c.cod_docto
                        , c.cod_modelo
                        , c.cod_cfo
                        , c.natureza_operacao
                        , c.cod_produto
                        , c.descricao
                        , c.cst_a
                        , c.cst_b
                        , c.quantidade
                        , c.ncm
                        , c.num_item
                        , c.vlr_contabil_item
                        , c.vlr_item
                        , c.vlr_base_icms_1
                        , c.vlr_aliquota
                        , c.vlr_icms_proprio
                        , c.vlr_base_icms_2
                        , c.vlr_base_icms_3
                        , c.cfop_saida_origem
                        , c.cfop_entrada_origem
                        , c.valor_base_icms_origem
                        , c.valor_aliquota_origem
                        , c.valor_icms_origem
                        , c.cst_origem
                        , c.num_controle_docto
                        , c.proc_id
                        , c.nm_usuario
                        , c.dt_carga
                        , c.status );

            v_count_new := v_count_new + SQL%ROWCOUNT;

            dbms_application_info.set_module ( $$plsql_unit
                                             , ' ENTRADA 3 - ' || v_count_new );
        END LOOP;

        SELECT COUNT ( * )
          INTO v_count_new
          FROM msafi.dpsp_fin048_ret_nf_ent
         WHERE data_fiscal BETWEEN pdt_ini AND pdt_fim;

        loga (
                  '::QUANTIDADE DE REGISTROS INSERIDOS (DPSP_FIN048_RET_NF_ENT) , CD: '
               || pcod_estab
               || ' - QTDE '
               || NVL ( v_count_new, 0 )
               || '::'
             , FALSE
        );

        RETURN NVL ( v_count_new, 0 );
    END;
-- END;
END dpsp_fin048_ret_entrada_cproc;
/
SHOW ERRORS;
