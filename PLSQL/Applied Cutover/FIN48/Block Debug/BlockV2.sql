DECLARE

    pdt_ini DATE := '01/04/2016';
    pdt_fim DATE := '30/04/2016';
    pcod_estab VARCHAR2 ( 10 ) := 'DP908';
    v_data_hora_ini VARCHAR2(100) := TO_CHAR(SYSDATE);
    
    
    
    i NUMBER;
    TYPE x07_docto_fiscal_tp IS TABLE OF msafi.x07_docto_fiscal_gtt%ROWTYPE;
    x07_docto_fiscal_typ x07_docto_fiscal_tp := x07_docto_fiscal_tp();
  
    TYPE x08_itens_merc_gtt_tp IS TABLE OF msafi.x08_itens_merc_gtt%ROWTYPE;
    x08_itens_merc_typ x08_itens_merc_gtt_tp := x08_itens_merc_gtt_tp();
  
    forall_failed EXCEPTION;
    PRAGMA EXCEPTION_INIT(forall_failed, -24381);
  
    err_num  NUMBER;
    err_msg  VARCHAR2(100);
    l_error  NUMBER;
    l_errors NUMBER;
    l_errno  NUMBER;
    l_msg    VARCHAR2(4000);
    l_idx    NUMBER;
  
    log_x07_type        msafi.x07_docto_fiscal_log%ROWTYPE;
    l_cfop_saida_origem msafi.x07_docto_fiscal_gtt.cfop_saida_origem%TYPE;
    l_ident_natureza_op NUMBER;
    l_ident_cfo         NUMBER;
    l_ident_situacao_b  NUMBER;
  
    l_cod_produto x2013_produto.cod_produto%TYPE;
    --    L_IDENT_PRODUTO   X2013_PRODUTO.IDENT_PRODUTO%TYPE;
  
    x08b_type x08_base_merc%ROWTYPE;
  
  BEGIN
    EXECUTE IMMEDIATE 'delete  msafi.X07_DOCTO_FISCAL_GTT';
    EXECUTE IMMEDIATE 'delete  msafi.X08_ITENS_MERC_GTT';
  
    BEGIN
      SELECT x07.cod_empresa,
             x07.cod_estab,
             x07.data_fiscal,
             x07.movto_e_s,
             x07.norm_dev,
             x07.ident_docto,
             x07.ident_fis_jur,
             x07.num_docfis,
             x07.serie_docfis,
             x07.sub_serie_docfis,
             fin048_ret.num_item,
             x07.ROWID rowid_x07,
             fin048_ret.valor_aliquota_origem,
             fin048_ret.valor_base_icms_origem,
             fin048_ret.valor_icms_origem,
             fin048_ret.vlr_item fin48_vlr_item,
             fin048_ret.vlr_base_icms_3,
             fin048_ret.vlr_base_icms_2,
             fin048_ret.vlr_base_icms_1,
             fin048_ret.cfop_saida_origem,
             fin048_ret.cst_origem,
             fin048_ret.ROWID f_rowid BULK COLLECT
        INTO x07_docto_fiscal_typ
        FROM msafi.dpsp_fin048_ret_nf_ent fin048_ret, x07_docto_fiscal x07
       WHERE fin048_ret.data_fiscal BETWEEN pdt_ini AND pdt_fim
         --  AND FIN048_RET.NUM_DOCFIS  = '000019602'
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
       GROUP BY x07.cod_empresa,
                x07.cod_estab,
                x07.data_fiscal,
                x07.movto_e_s,
                x07.norm_dev,
                x07.ident_docto,
                x07.ident_fis_jur,
                x07.num_docfis,
                x07.serie_docfis,
                x07.sub_serie_docfis,
                fin048_ret.num_item,
                x07.ROWID,
                fin048_ret.valor_aliquota_origem,
                fin048_ret.valor_base_icms_origem,
                fin048_ret.valor_icms_origem,
                fin048_ret.vlr_item,
                fin048_ret.vlr_base_icms_3,
                fin048_ret.vlr_base_icms_2,
                fin048_ret.vlr_base_icms_1,
                fin048_ret.cfop_saida_origem,
                fin048_ret.cst_origem,
                fin048_ret.ROWID;
    
      FORALL ix7 IN x07_docto_fiscal_typ.FIRST .. x07_docto_fiscal_typ.LAST SAVE
                                                  EXCEPTIONS
        INSERT INTO msafi.x07_docto_fiscal_gtt
        VALUES x07_docto_fiscal_typ
          (ix7);
    
      SELECT x08.cod_empresa,
             x08.cod_estab,
             x08.data_fiscal,
             x08.movto_e_s,
             x08.norm_dev,
             x08.ident_docto,
             x08.ident_fis_jur,
             x08.num_docfis,
             x08.serie_docfis,
             x08.sub_serie_docfis,
             x08.discri_item,
             x08.ident_produto,
             x08.ident_und_padrao,
             x08.cod_bem,
             x08.cod_inc_bem,
             x08.valid_bem,
             x08.num_item,
             x08.ident_almox,
             x08.ident_custo,
             x08.descricao_compl,
             x08.ident_cfo,
             x08.ident_natureza_op,
             x08.ident_nbm,
             x08.quantidade,
             x08.ident_medida,
             x08.vlr_unit,
             x08.vlr_item,
             x08.vlr_desconto,
             x08.vlr_frete,
             x08.vlr_seguro,
             x08.vlr_outras,
             x08.ident_situacao_a,
             x08.ident_situacao_b,
             x08.ident_federal,
             x08.ind_ipi_incluso,
             x08.num_romaneio,
             x08.data_romaneio,
             x08.peso_liquido,
             x08.cod_indice,
             x08.vlr_item_conver,
             x08.num_processo,
             x08.ind_gravacao,
             x08.vlr_contab_compl,
             x08.vlr_aliq_destino,
             x08.vlr_outros1,
             x08.vlr_outros2,
             x08.vlr_outros3,
             x08.vlr_outros4,
             x08.vlr_outros5,
             x08.vlr_aliq_outros1,
             x08.vlr_aliq_outros2,
             x08.vlr_contab_item,
             x08.cod_obs_vcont_comp,
             x08.cod_obs_vcont_item,
             x08.vlr_outros_icms,
             x08.vlr_outros_ipi,
             x08.ind_resp_vcont_itm,
             x08.num_ato_conces,
             x08.dat_embarque,
             x08.num_reg_exp,
             x08.num_desp_exp,
             x08.vlr_tom_servico,
             x08.vlr_desp_moeda_exp,
             x08.cod_moeda_negoc,
             x08.cod_pais_dest_orig,
             x08.cod_trib_int,
             x08.vlr_icms_ndestac,
             x08.vlr_ipi_ndestac,
             x08.vlr_base_pis,
             x08.vlr_pis,
             x08.vlr_base_cofins,
             x08.vlr_cofins,
             x08.base_icms_origdest,
             x08.vlr_icms_origdest,
             x08.aliq_icms_origdest,
             x08.vlr_desc_condic,
             x08.vlr_custo_transf,
             x08.perc_red_base_icms,
             x08.qtd_embarcada,
             x08.dat_registro_exp,
             x08.dat_despacho,
             x08.dat_averbacao,
             x08.dat_di,
             x08.num_dec_imp_ref,
             x08.dsc_mot_ocor,
             x08.ident_conta,
             x08.vlr_base_icms_orig,
             x08.vlr_trib_icms_orig,
             x08.vlr_base_icms_dest,
             x08.vlr_trib_icms_dest,
             x08.vlr_perc_pres_icms,
             x08.vlr_preco_base_st,
             x08.ident_oper_oil,
             x08.cod_dcr,
             x08.ident_projeto,
             x08.dat_operacao,
             x08.usuario,
             x08.ind_mov_fis,
             x08.chassi,
             x08.num_docfis_ref,
             x08.serie_docfis_ref,
             x08.sserie_docfis_ref,
             x08.vlr_base_pis_st,
             x08.vlr_aliq_pis_st,
             x08.vlr_pis_st,
             x08.vlr_base_cofins_st,
             x08.vlr_aliq_cofins_st,
             x08.vlr_cofins_st,
             x08.vlr_base_csll,
             x08.vlr_aliq_csll,
             x08.vlr_csll,
             x08.vlr_aliq_pis,
             x08.vlr_aliq_cofins,
             x08.ind_situacao_esp_st,
             x08.vlr_icmss_ndestac,
             x08.ind_docto_rec,
             x08.dat_pgto_gnre_darj,
             x08.vlr_custo_unit,
             x08.vlr_fator_conv,
             x08.quantidade_conv,
             x08.vlr_fecp_icms,
             x08.vlr_fecp_difaliq,
             x08.vlr_fecp_icms_st,
             x08.vlr_fecp_fonte,
             x08.vlr_base_icmss_n_escrit,
             x08.vlr_icmss_n_escrit,
             x08.vlr_ajuste_cond_pg,
             x08.cod_trib_ipi,
             x08.lote_medicamento,
             x08.valid_medicamento,
             x08.ind_base_medicamento,
             x08.vlr_preco_medicamento,
             x08.ind_tipo_arma,
             x08.num_serie_arma,
             x08.num_cano_arma,
             x08.dsc_arma,
             x08.ident_observacao,
             x08.cod_ex_ncm,
             x08.cod_ex_imp,
             x08.cnpj_operadora,
             x08.cpf_operadora,
             x08.ident_uf_operadora,
             x08.ins_est_operadora,
             x08.ind_especif_receita,
             x08.cod_class_item,
             x08.vlr_terceiros,
             x08.vlr_preco_suger,
             x08.vlr_base_cide,
             x08.vlr_aliq_cide,
             x08.vlr_cide,
             x08.cod_oper_esp_st,
             x08.vlr_comissao,
             x08.vlr_icms_frete,
             x08.vlr_difal_frete,
             x08.ind_vlr_pis_cofins,
             x08.cod_enquad_ipi,
             x08.cod_situacao_pis,
             x08.qtd_base_pis,
             x08.vlr_aliq_pis_r,
             x08.cod_situacao_cofins,
             x08.qtd_base_cofins,
             x08.vlr_aliq_cofins_r,
             x08.item_port_tare,
             x08.vlr_funrural,
             x08.ind_tp_prod_medic,
             x08.vlr_custo_dca,
             x08.cod_tp_lancto,
             x08.vlr_perc_cred_out,
             x08.vlr_cred_out,
             x08.vlr_icms_dca,
             x08.vlr_pis_exp,
             x08.vlr_pis_trib,
             x08.vlr_pis_n_trib,
             x08.vlr_cofins_exp,
             x08.vlr_cofins_trib,
             x08.vlr_cofins_n_trib,
             x08.cod_enq_legal,
             x08.ind_gravacao_saics,
             x08.dat_lanc_pis_cofins,
             x08.ind_pis_cofins_extemp,
             x08.ind_natureza_frete,
             x08.cod_nat_rec,
             x08.ind_nat_base_cred,
             x08.vlr_acrescimo,
             x08.dsc_reservado1,
             x08.dsc_reservado2,
             x08.dsc_reservado3,
             x08.cod_trib_prod,
             x08.dsc_reservado4,
             x08.dsc_reservado5,
             x08.dsc_reservado6,
             x08.dsc_reservado7,
             x08.dsc_reservado8,
             x08.indice_prod_acab,
             x08.vlr_base_dia_am,
             x08.vlr_aliq_dia_am,
             x08.vlr_icms_dia_am,
             x08.vlr_aduaneiro,
             x08.cod_situacao_pis_st,
             x08.cod_situacao_cofins_st,
             x08.vlr_aliq_dcip,
             x08.num_li,
             x08.vlr_fcp_uf_dest,
             x08.vlr_icms_uf_dest,
             x08.vlr_icms_uf_orig,
             x08.vlr_dif_dub,
             x08.vlr_icms_nao_dest,
             x08.vlr_base_icms_nao_dest,
             x08.vlr_aliq_icms_nao_dest,
             x08.ind_motivo_res,
             x08.num_docfis_ret,
             x08.serie_docfis_ret,
             x08.num_autentic_nfe_ret,
             x08.num_item_ret,
             x08.ident_fis_jur_ret,
             x08.ind_tp_doc_arrec,
             x08.num_doc_arrec,
             x08.ident_cfo_dcip,
             x08.vlr_base_inss,
             x08.vlr_inss_retido,
             x08.vlr_tot_adic,
             x08.vlr_n_ret_princ,
             x08.vlr_n_ret_adic,
             x08.vlr_aliq_inss,
             x08.vlr_ret_serv,
             x08.vlr_serv_15,
             x08.vlr_serv_20,
             x08.vlr_serv_25,
             x08.ind_tp_proc_adj_princ,
             x08.ident_proc_adj_princ,
             x08.ident_susp_tbt_princ,
             x08.num_proc_adj_princ,
             x08.ind_tp_proc_adj_adic,
             x08.ident_proc_adj_adic,
             x08.ident_susp_tbt_adic,
             x08.num_proc_adj_adic,
             x08.vlr_ipi_dev,
             x08.cod_beneficio,
             x08.vlr_abat_ntributado BULK COLLECT
        INTO x08_itens_merc_typ
        FROM x08_itens_merc x08, msafi.x07_docto_fiscal_gtt x07_gtt
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
    
    DBMS_OUTPUT.PUT_LINE  ('Recupera itens_merc' || SQL%ROWCOUNT);
    
      FOR j IN x08_itens_merc_typ.FIRST .. x08_itens_merc_typ.LAST LOOP
      
        BEGIN
        
          ---  base trib  merc
          DECLARE
            x08t_type x08_trib_merc%ROWTYPE;
          BEGIN
          
            SELECT *
              INTO x08t_type
              FROM x08_trib_merc
             WHERE cod_empresa = x08_itens_merc_typ(j)
            .cod_empresa
               AND cod_estab = x08_itens_merc_typ(j)
            .cod_estab
               AND data_fiscal = x08_itens_merc_typ(j)
            .data_fiscal
               AND movto_e_s = x08_itens_merc_typ(j)
            .movto_e_s
               AND norm_dev = x08_itens_merc_typ(j)
            .norm_dev
               AND ident_docto = x08_itens_merc_typ(j)
            .ident_docto
               AND ident_fis_jur = x08_itens_merc_typ(j)
            .ident_fis_jur
               AND num_docfis = x08_itens_merc_typ(j)
            .num_docfis
               AND serie_docfis = x08_itens_merc_typ(j)
            .serie_docfis
               AND sub_serie_docfis = x08_itens_merc_typ(j)
            .sub_serie_docfis
               AND discri_item = x08_itens_merc_typ(j)
            .discri_item
               AND cod_tributo = 'ICMS';
          
            DBMS_OUTPUT.PUT_LINE  ('Recupera itens_trib:' );
--            || x08t_type.cod_tributo || ';' ||
--                 x08_itens_merc_typ(j)
--                 .cod_empresa || ';' || x08_itens_merc_typ(j)
--                 .cod_estab || ';' || x08_itens_merc_typ(j)
--                 .data_fiscal || ';' || x08_itens_merc_typ(j)
--                 .movto_e_s || ';' || x08_itens_merc_typ(j)
--                 .norm_dev || ';' || x08_itens_merc_typ(j)
--                 .ident_docto || ';' || x08_itens_merc_typ(j)
--                 .ident_fis_jur || ';' || x08_itens_merc_typ(j)
--                 .num_docfis || ';' || x08_itens_merc_typ(j)
--                 .serie_docfis || ';' || x08_itens_merc_typ(j)
--                 .sub_serie_docfis || ';' || x08_itens_merc_typ(j)
--                 .discri_item);
          
            IF x08t_type.cod_tributo = 'ICMS'
            THEN
              BEGIN  NULL;
                --
              
--                DELETE x08_base_merc
--                 WHERE cod_empresa = x08_itens_merc_typ(j)
--                .cod_empresa
--                   AND cod_estab = x08_itens_merc_typ(j)
--                .cod_estab
--                   AND data_fiscal = x08_itens_merc_typ(j)
--                .data_fiscal
--                   AND movto_e_s = x08_itens_merc_typ(j)
--                .movto_e_s
--                   AND norm_dev = x08_itens_merc_typ(j)
--                .norm_dev
--                   AND ident_docto = x08_itens_merc_typ(j)
--                .ident_docto
--                   AND ident_fis_jur = x08_itens_merc_typ(j)
--                .ident_fis_jur
--                   AND num_docfis = x08_itens_merc_typ(j)
--                .num_docfis
--                   AND serie_docfis = x08_itens_merc_typ(j)
--                .serie_docfis
--                   AND sub_serie_docfis = x08_itens_merc_typ(j)
--                .sub_serie_docfis
--                   AND discri_item = x08_itens_merc_typ(j)
--                .discri_item
--                   AND cod_tributo = 'ICMS';
              
                DBMS_OUTPUT.PUT_LINE  ('Recupera itens_trib delete' || SQL%ROWCOUNT);
              
--                DELETE x08_trib_merc
--                 WHERE cod_empresa = x08_itens_merc_typ(j)
--                .cod_empresa
--                   AND cod_estab = x08_itens_merc_typ(j)
--                .cod_estab
--                   AND data_fiscal = x08_itens_merc_typ(j)
--                .data_fiscal
--                   AND movto_e_s = x08_itens_merc_typ(j)
--                .movto_e_s
--                   AND norm_dev = x08_itens_merc_typ(j)
--                .norm_dev
--                   AND ident_docto = x08_itens_merc_typ(j)
--                .ident_docto
--                   AND ident_fis_jur = x08_itens_merc_typ(j)
--                .ident_fis_jur
--                   AND num_docfis = x08_itens_merc_typ(j)
--                .num_docfis
--                   AND serie_docfis = x08_itens_merc_typ(j)
--                .serie_docfis
--                   AND sub_serie_docfis = x08_itens_merc_typ(j)
--                .sub_serie_docfis
--                   AND discri_item = x08_itens_merc_typ(j)
--                .discri_item
--                   AND cod_tributo = 'ICMS';
              
                DBMS_OUTPUT.PUT_LINE  ('Recupera itens_trib delete' || SQL%ROWCOUNT);
              
              EXCEPTION
                WHEN OTHERS THEN
                
                  err_num                := SQLCODE;
                  err_msg                := substr(SQLERRM, 1, 100); 
                  log_x07_type.log_fin48 := 'ERROR :BLOCO 245 | DELETE ' ||
                                            err_num || ' - ' || err_msg;
                
                  INSERT INTO msafi.x07_docto_fiscal_BKP
                  VALUES log_x07_type;
                  COMMIT;
                
              END;
            END IF;
          
            BEGIN
              SELECT x07_gtt.valor_aliquota_origem,
                     x07_gtt.valor_icms_origem
                INTO x08t_type.aliq_tributo, x08t_type.vlr_tributo
                FROM msafi.x07_docto_fiscal_gtt x07_gtt
               WHERE cod_empresa = x08_itens_merc_typ(j)
              .cod_empresa
                 AND cod_estab = x08_itens_merc_typ(j)
              .cod_estab
                 AND data_fiscal = x08_itens_merc_typ(j)
              .data_fiscal
                 AND movto_e_s = x08_itens_merc_typ(j)
              .movto_e_s
                 AND norm_dev = x08_itens_merc_typ(j)
              .norm_dev
                 AND ident_docto = x08_itens_merc_typ(j)
              .ident_docto
                 AND ident_fis_jur = x08_itens_merc_typ(j)
              .ident_fis_jur
                 AND num_docfis = x08_itens_merc_typ(j)
              .num_docfis
                 AND serie_docfis = x08_itens_merc_typ(j)
              .serie_docfis
                 AND sub_serie_docfis = x08_itens_merc_typ(j)
              .sub_serie_docfis
                 AND num_item = x08_itens_merc_typ(j).num_item;
            
            EXCEPTION
              WHEN OTHERS THEN
                err_num                := SQLCODE;
                err_msg                := substr(SQLERRM, 1, 100);
                log_x07_type.log_fin48 := 'ERROR :BLOCO 276 | INTO X08T_TYPE ' ||
                                          err_num || ' - ' || err_msg;
              
                INSERT INTO msafi.x07_docto_fiscal_BKP VALUES log_x07_type;
              
            END;
          
            ---  insert  trib  
            BEGIN
             -- INSERT INTO x08_trib_merc VALUES x08t_type;
              NULL;
              
              DBMS_OUTPUT.PUT_LINE  ('Recupera itens_trib insert' || SQL%ROWCOUNT);
            
            EXCEPTION
              WHEN OTHERS THEN
                err_num                := SQLCODE;
                err_msg                := substr(SQLERRM, 1, 100);
                log_x07_type.log_fin48 := 'ERROR :BLOCO 293 | INSERT ' ||
                                          err_num || ' - ' || err_msg;
              
                INSERT INTO msafi.x07_docto_fiscal_BKP VALUES log_x07_type;
                COMMIT;
              
            END;
          
          END;
        
          --  AJUSTES NA BASE DO ICMS -  X08_BASE_MERC
          --  DECLARE
          ---    X08B_TYPE         X08_BASE_MERC%ROWTYPE;
        
          BEGIN
          
            DBMS_OUTPUT.PUT_LINE  ('Recupera itens_base' || SQL%ROWCOUNT);
          
            SELECT x07_gtt.valor_base_icms_origem
              INTO x08b_type.vlr_base
              FROM msafi.x07_docto_fiscal_gtt x07_gtt
             WHERE cod_empresa = x08_itens_merc_typ(j)
            .cod_empresa
               AND cod_estab = x08_itens_merc_typ(j)
            .cod_estab
               AND data_fiscal = x08_itens_merc_typ(j)
            .data_fiscal
               AND movto_e_s = x08_itens_merc_typ(j)
            .movto_e_s
               AND norm_dev = x08_itens_merc_typ(j)
            .norm_dev
               AND ident_docto = x08_itens_merc_typ(j)
            .ident_docto
               AND ident_fis_jur = x08_itens_merc_typ(j)
            .ident_fis_jur
               AND num_docfis = x08_itens_merc_typ(j)
            .num_docfis
               AND serie_docfis = x08_itens_merc_typ(j)
            .serie_docfis
               AND sub_serie_docfis = x08_itens_merc_typ(j)
            .sub_serie_docfis
               AND num_item = x08_itens_merc_typ(j).num_item;
          
            x08b_type.cod_empresa      := x08_itens_merc_typ(j).cod_empresa;
            x08b_type.cod_estab        := x08_itens_merc_typ(j).cod_estab;
            x08b_type.data_fiscal      := x08_itens_merc_typ(j).data_fiscal;
            x08b_type.movto_e_s        := x08_itens_merc_typ(j).movto_e_s;
            x08b_type.norm_dev         := x08_itens_merc_typ(j).norm_dev;
            x08b_type.ident_docto      := x08_itens_merc_typ(j).ident_docto;
            x08b_type.ident_fis_jur    := x08_itens_merc_typ(j)
                                         .ident_fis_jur;
            x08b_type.num_docfis       := x08_itens_merc_typ(j).num_docfis;
            x08b_type.serie_docfis     := x08_itens_merc_typ(j)
                                         .serie_docfis;
            x08b_type.sub_serie_docfis := x08_itens_merc_typ(j)
                                         .sub_serie_docfis;
            x08b_type.discri_item      := x08_itens_merc_typ(j).discri_item;
            x08b_type.cod_tributo      := 'ICMS';
            x08b_type.cod_tributacao   := 1;
          
            ---INSERT INTO x08_base_merc VALUES x08b_type;
          
          EXCEPTION
          
            WHEN OTHERS THEN
              err_num                := SQLCODE;
              err_msg                := substr(SQLERRM, 1, 100);
              log_x07_type.log_fin48 := 'ERROR :BLOCO 195 | DELETE ' ||
                                        err_num || ' - ' || err_msg;
              --  INSERT 
              INSERT INTO msafi.x07_docto_fiscal_BKP VALUES log_x07_type;
              COMMIT;
            
          END;
        
          BEGIN
            IF x08b_type.cod_tributacao = 2
            THEN   NULL ;
            
--              UPDATE x08_base_merc
--                 SET cod_tributacao = 1
--               WHERE cod_empresa = x08_itens_merc_typ(j)
--              .cod_empresa
--                 AND cod_estab = x08_itens_merc_typ(j)
--              .cod_estab
--                 AND data_fiscal = x08_itens_merc_typ(j)
--              .data_fiscal
--                 AND movto_e_s = x08_itens_merc_typ(j)
--              .movto_e_s
--                 AND norm_dev = x08_itens_merc_typ(j)
--              .norm_dev
--                 AND ident_docto = x08_itens_merc_typ(j)
--              .ident_docto
--                 AND ident_fis_jur = x08_itens_merc_typ(j)
--              .ident_fis_jur
--                 AND num_docfis = x08_itens_merc_typ(j)
--              .num_docfis
--                 AND serie_docfis = x08_itens_merc_typ(j)
--              .serie_docfis
--                 AND sub_serie_docfis = x08_itens_merc_typ(j)
--              .sub_serie_docfis
--                 AND discri_item = x08_itens_merc_typ(j)
--              .discri_item
--                 AND cod_tributo = 'ICMS'
--                 AND cod_tributacao = 2;
            
            ELSIF x08b_type.cod_tributacao = 3
            THEN  NULL ;
             
--              UPDATE x08_base_merc
--                 SET cod_tributacao = 1
--               WHERE cod_empresa = x08_itens_merc_typ(j)
--              .cod_empresa
--                 AND cod_estab = x08_itens_merc_typ(j)
--              .cod_estab
--                 AND data_fiscal = x08_itens_merc_typ(j)
--              .data_fiscal
--                 AND movto_e_s = x08_itens_merc_typ(j)
--              .movto_e_s
--                 AND norm_dev = x08_itens_merc_typ(j)
--              .norm_dev
--                 AND ident_docto = x08_itens_merc_typ(j)
--              .ident_docto
--                 AND ident_fis_jur = x08_itens_merc_typ(j)
--              .ident_fis_jur
--                 AND num_docfis = x08_itens_merc_typ(j)
--              .num_docfis
--                 AND serie_docfis = x08_itens_merc_typ(j)
--              .serie_docfis
--                 AND sub_serie_docfis = x08_itens_merc_typ(j)
--              .sub_serie_docfis
--                 AND discri_item = x08_itens_merc_typ(j)
--              .discri_item
--                 AND cod_tributo = 'ICMS'
--                 AND cod_tributacao = 3;
            
            END IF;
          
          EXCEPTION
            WHEN OTHERS THEN
              err_num                := SQLCODE;
              err_msg                := substr(SQLERRM, 1, 100);
              log_x07_type.log_fin48 := 'ERROR :BLOCO 171 | DELETE ' ||
                                        err_num || ' - ' || err_msg;
                                        
                                        
                                           INSERT INTO msafi.x07_docto_fiscal_BKP VALUES log_x07_type;
                                           COMMIT;
          END;
        
        EXCEPTION
          WHEN OTHERS THEN
            err_num                := SQLCODE;
            err_msg                := substr(SQLERRM, 1, 100);
            log_x07_type.log_fin48 := 'ERROR :BLOCO 293 | INSERT ' ||
                                      err_num || ' - ' || err_msg;
          
            INSERT INTO msafi.x07_docto_fiscal_BKP VALUES log_x07_type;
            COMMIT;
          
        END;
      
        ----   cfop/cst / 
      
        DECLARE
        
        BEGIN
        
          l_cfop_saida_origem := NULL;
        
          SELECT x07_gtt.cfop_saida_origem
            INTO l_cfop_saida_origem
            FROM msafi.x07_docto_fiscal_gtt x07_gtt
           WHERE cod_empresa = x08_itens_merc_typ(j)
          .cod_empresa
             AND cod_estab = x08_itens_merc_typ(j)
          .cod_estab
             AND data_fiscal = x08_itens_merc_typ(j)
          .data_fiscal
             AND movto_e_s = x08_itens_merc_typ(j)
          .movto_e_s
             AND norm_dev = x08_itens_merc_typ(j)
          .norm_dev
             AND ident_docto = x08_itens_merc_typ(j)
          .ident_docto
             AND ident_fis_jur = x08_itens_merc_typ(j)
          .ident_fis_jur
             AND num_docfis = x08_itens_merc_typ(j)
          .num_docfis
             AND serie_docfis = x08_itens_merc_typ(j)
          .serie_docfis
             AND sub_serie_docfis = x08_itens_merc_typ(j)
          .sub_serie_docfis
             AND num_item = x08_itens_merc_typ(j).num_item;
        
        EXCEPTION
          WHEN OTHERS THEN
            err_num                := SQLCODE;
            err_msg                := substr(SQLERRM, 1, 100);
            log_x07_type.log_fin48 := 'ERROR :BLOCO 403 | CFOP_SAIDA_ORIGEM ' ||
                                      err_num || ' - ' || err_msg;
            --                      
            INSERT INTO msafi.x07_docto_fiscal_BKP VALUES log_x07_type;
            COMMIT;
        END;
      
        l_ident_natureza_op := x08_itens_merc_typ(j).ident_natureza_op;
      
        BEGIN
          SELECT x2081.ident_cfo
            INTO l_ident_cfo
            FROM x2012_cod_fiscal   x2012,
                 x2081_extensao_cfo x2081,
                 x2006_natureza_op  x2006
           WHERE x2012.ident_cfo = x2081.ident_cfo
             AND x2006.ident_natureza_op = x2081.ident_natureza_op
             AND x2081.ident_natureza_op = l_ident_natureza_op
             AND x2012.cod_cfo = (CASE WHEN l_cfop_saida_origem IN
                  ('6102', '6101', '6105', '6106',
                   '6401', '6403', '6404') THEN '2102' WHEN
                  l_cfop_saida_origem IN ('6152', '2209') THEN
                  '2152' ELSE l_cfop_saida_origem END)
/*             AND x2006.valid_natureza_op =
                 (SELECT MAX(valid_natureza_op)
                    FROM x2006_natureza_op op
                   WHERE op.valid_natureza_op <= x08_itens_merc_typ(j)
                  .data_fiscal)*/
                  ;
        
        EXCEPTION
          WHEN OTHERS THEN
            err_num                := SQLCODE;
            err_msg                := substr(SQLERRM, 1, 100);
            log_x07_type.log_fin48 := 'ERROR :BLOCO 479 | L_IDENT_CFO ' ||
                                      err_num || ' - ' || err_msg;
            --                      
            INSERT INTO msafi.x07_docto_fiscal_BKP VALUES log_x07_type;
            COMMIT;
        END;
      
        ---  CST (40 ) POR PRODUTO DE CANCERÍGENO ISENTO 
        BEGIN
          SELECT x2013.cod_produto
            INTO l_cod_produto
            FROM x2013_produto x2013
           WHERE x2013.ident_produto = x08_itens_merc_typ(j).ident_produto;
        
          IF l_cod_produto IN
             ('639', '2836', '4391', '5681', '18171', '18481', '18902',
              '22330', '26859', '27391', '28134', '29327', '30279', '32018',
              '32522', '34550', '34665', '39365', '39390', '40878', '41068',
              '47899', '51896', '55794', '67725', '72257', '73903', '74462',
              '74632', '75272', '75280', '75329', '75345', '85332', '88188',
              '95559', '96393', '97853', '104655', '127302', '148032',
              '148059', '148067', '151130', '170526', '171026', '186651',
              '205265', '205346', '217492', '219215', '219223', '219231',
              '219240', '219258', '221953', '221961', '260762', '260819',
              '261122', '261130', '263648', '266086', '280089', '288624',
              '288950', '290203', '290378', '290610', '291285', '292060',
              '293725', '295396', '296562', '299219', '320021', '322334',
              '326534', '326550', '337471', '337803', '337811', '341177',
              '342262', '342327', '342939', '343749', '343757', '343870',
              '344770', '344788', '345067', '346322', '346330', '346357',
              '346365', '347760', '356506', '356514', '358550', '362131',
              '367311', '370665', '372498', '372706', '372846', '372854',
              '372862', '375691', '375772', '383082', '383090', '387738',
              '421804', '422754', '422762', '423130', '427748', '427764',
              '427772', '427780', '427799', '427802', '427829', '427837',
              '427845', '427853', '427861', '427870', '427888', '427896',
              '456101', '456110', '456128', '465356', '467049', '472921',
              '473391', '478857', '478865', '478873', '478881', '478890',
              '478903', '482846', '487759', '487899', '489964', '490075',
              '490091', '491292', '492108', '492132', '499595', '499609',
              '499617', '506095', '512486', '515019', '519596', '521116',
              '521124', '521132', '521140', '533874', '533947', '533955',
              '538442', '550892', '553182', '563102', '563110', '563129',
              '563137', '563145', '568180', '575992', '584878', '618896',
              '618900', '634832', '643416', '647322', '647330', '647357',
              '654280', '655457', '655465', '666513', '670421', '672270',
              '674249', '674257', '9002090', '9004130', '9005064', '9007610',
              '9007792', '9008195', '9008390')
          
          THEN
            l_ident_situacao_b := 18; -- CST 40 (ISENTA)   
            BEGIN
            
              SELECT x07_gtt.vlr_base_icms_2
                INTO x08b_type.vlr_base
                FROM msafi.x07_docto_fiscal_gtt x07_gtt
               WHERE cod_empresa = x08_itens_merc_typ(j)
              .cod_empresa
                 AND cod_estab = x08_itens_merc_typ(j)
              .cod_estab
                 AND data_fiscal = x08_itens_merc_typ(j)
              .data_fiscal
                 AND movto_e_s = x08_itens_merc_typ(j)
              .movto_e_s
                 AND norm_dev = x08_itens_merc_typ(j)
              .norm_dev
                 AND ident_docto = x08_itens_merc_typ(j)
              .ident_docto
                 AND ident_fis_jur = x08_itens_merc_typ(j)
              .ident_fis_jur
                 AND num_docfis = x08_itens_merc_typ(j)
              .num_docfis
                 AND serie_docfis = x08_itens_merc_typ(j)
              .serie_docfis
                 AND sub_serie_docfis = x08_itens_merc_typ(j)
              .sub_serie_docfis
                 AND num_item = x08_itens_merc_typ(j).num_item;
            
--              UPDATE x08_trib_merc
--                 SET aliq_tributo = 0, vlr_tributo = 0
--               WHERE cod_empresa = x08_itens_merc_typ(j)
--              .cod_empresa
--                 AND cod_estab = x08_itens_merc_typ(j)
--              .cod_estab
--                 AND data_fiscal = x08_itens_merc_typ(j)
--              .data_fiscal
--                 AND movto_e_s = x08_itens_merc_typ(j)
--              .movto_e_s
--                 AND norm_dev = x08_itens_merc_typ(j)
--              .norm_dev
--                 AND ident_docto = x08_itens_merc_typ(j)
--              .ident_docto
--                 AND ident_fis_jur = x08_itens_merc_typ(j)
--              .ident_fis_jur
--                 AND num_docfis = x08_itens_merc_typ(j)
--              .num_docfis
--                 AND serie_docfis = x08_itens_merc_typ(j)
--              .serie_docfis
--                 AND sub_serie_docfis = x08_itens_merc_typ(j)
--              .sub_serie_docfis
--                 AND discri_item = x08_itens_merc_typ(j)
--              .discri_item
--                 AND cod_tributo = 'ICMS';
--            
--              UPDATE x08_base_merc
--                 SET cod_tributacao = 2, vlr_base = x08b_type.vlr_base
--               WHERE cod_empresa = x08_itens_merc_typ(j)
--              .cod_empresa
--                 AND cod_estab = x08_itens_merc_typ(j)
--              .cod_estab
--                 AND data_fiscal = x08_itens_merc_typ(j)
--              .data_fiscal
--                 AND movto_e_s = x08_itens_merc_typ(j)
--              .movto_e_s
--                 AND norm_dev = x08_itens_merc_typ(j)
--              .norm_dev
--                 AND ident_docto = x08_itens_merc_typ(j)
--              .ident_docto
--                 AND ident_fis_jur = x08_itens_merc_typ(j)
--              .ident_fis_jur
--                 AND num_docfis = x08_itens_merc_typ(j)
--              .num_docfis
--                 AND serie_docfis = x08_itens_merc_typ(j)
--              .serie_docfis
--                 AND sub_serie_docfis = x08_itens_merc_typ(j)
--              .sub_serie_docfis
--                 AND discri_item = x08_itens_merc_typ(j)
--              .discri_item
--                 AND cod_tributo = 'ICMS'
--                 AND cod_tributacao = 1;
            
            END;
          
          ELSE
            l_ident_situacao_b := 14; -- CST  00  TRIBUTADA INTEGRALMENTE                                                
          END IF;
        
        EXCEPTION
          WHEN OTHERS THEN
            err_num                := SQLCODE;
            err_msg                := substr(SQLERRM, 1, 100);
            log_x07_type.log_fin48 := 'ERROR :BLOCO 613 | L_IDENT_SITUACAO_B UP ' ||
                                      err_num || ' - ' || err_msg;
          
            --                      
            INSERT INTO msafi.x07_docto_fiscal_BKP VALUES log_x07_type;
            COMMIT;
            
        END;
      
        BEGIN  NULL;
        
--          UPDATE x08_itens_merc
--             SET ident_cfo = l_ident_cfo
--                 -- ,     IDENT_NATUREZA_OP   = L_IDENT_NATUREZA_OP
--                ,
--                 ident_situacao_b = l_ident_situacao_b
--           WHERE cod_empresa = x08_itens_merc_typ(j)
--          .cod_empresa
--             AND cod_estab = x08_itens_merc_typ(j)
--          .cod_estab
--             AND data_fiscal = x08_itens_merc_typ(j)
--          .data_fiscal
--             AND movto_e_s = x08_itens_merc_typ(j)
--          .movto_e_s
--             AND norm_dev = x08_itens_merc_typ(j)
--          .norm_dev
--             AND ident_docto = x08_itens_merc_typ(j)
--          .ident_docto
--             AND ident_fis_jur = x08_itens_merc_typ(j)
--          .ident_fis_jur
--             AND num_docfis = x08_itens_merc_typ(j)
--          .num_docfis
--             AND serie_docfis = x08_itens_merc_typ(j)
--          .serie_docfis
--             AND sub_serie_docfis = x08_itens_merc_typ(j)
--          .sub_serie_docfis
--             AND discri_item = x08_itens_merc_typ(j).discri_item;
        
        EXCEPTION
          WHEN OTHERS THEN
            err_num                := SQLCODE;
            err_msg                := substr(SQLERRM, 1, 100);
            log_x07_type.log_fin48 := 'ERROR :BLOCO 520 | X08_ITENS_MERC UP ' ||
                                      err_num || ' - ' || err_msg;
          
            --                      
            INSERT INTO msafi.x07_docto_fiscal_BKP VALUES log_x07_type;
            COMMIT;
            
        END;
      
--        UPDATE msafi.dpsp_fin048_ret_nf_ent
--           SET status = 'UPD'
--         WHERE cod_empresa = x08_itens_merc_typ(j)
--        .cod_empresa
--           AND cod_estab = x08_itens_merc_typ(j)
--        .cod_estab
--           AND data_fiscal = x08_itens_merc_typ(j)
--        .data_fiscal
--           AND num_docfis = x08_itens_merc_typ(j)
--        .num_docfis
--           AND num_item = x08_itens_merc_typ(j).num_item;
      
      END LOOP;
    
      DECLARE
        i NUMBER;
      BEGIN
        SELECT COUNT(*)
          INTO i
          FROM msafi.dpsp_fin048_ret_nf_ent
         WHERE data_fiscal BETWEEN pdt_ini AND pdt_fim
           AND cod_estab = pcod_estab;
        DBMS_OUTPUT.PUT_LINE   ('DW atualizados - Nr. Itens ' || i);
        
      END;
    
    EXCEPTION
      WHEN forall_failed THEN
      
        FOR i IN 1 .. l_errors LOOP
          l_errno := SQL%BULK_EXCEPTIONS(i).ERROR_CODE;
          l_msg   := SQLERRM(-l_errno);
          l_idx   := SQL%BULK_EXCEPTIONS(i).ERROR_INDEX;
        
          log_x07_type.cod_empresa      := x07_docto_fiscal_typ(i)
                                          .cod_empresa;
          log_x07_type.cod_estab        := x07_docto_fiscal_typ(i)
                                          .cod_estab;
          log_x07_type.data_fiscal      := x07_docto_fiscal_typ(i)
                                          .data_fiscal;
          log_x07_type.movto_e_s        := x07_docto_fiscal_typ(i)
                                          .movto_e_s;
          log_x07_type.norm_dev         := x07_docto_fiscal_typ(i).norm_dev;
          log_x07_type.ident_docto      := x07_docto_fiscal_typ(i)
                                          .ident_docto;
          log_x07_type.ident_fis_jur    := x07_docto_fiscal_typ(i)
                                          .ident_fis_jur;
          log_x07_type.num_docfis       := x07_docto_fiscal_typ(i)
                                          .num_docfis;
          log_x07_type.serie_docfis     := x07_docto_fiscal_typ(i)
                                          .serie_docfis;
          log_x07_type.sub_serie_docfis := x07_docto_fiscal_typ(i)
                                          .sub_serie_docfis;
          log_x07_type.num_item         := x07_docto_fiscal_typ(i).num_item;
          log_x07_type.log_fin48        := 'ERROR :BLOCO 530 | INSERT ' ||
                                           l_errno || ' - ' || l_msg ||
                                           ' - ' || l_idx;
        
          INSERT INTO msafi.x07_docto_fiscal_BKP VALUES log_x07_type;
         COMMIT;
         
        END LOOP;
        COMMIT;
    END;
  END prc_upd_nf_entrada;