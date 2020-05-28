DECLARE
    pdt_ini DATE := '01/03/2016';
    pdt_fim DATE := '01/03/2016';
    pcod_estab VARCHAR2 ( 10 ) := 'DP908';
    v_data_hora_ini VARCHAR2(100) := TO_CHAR(SYSDATE);

    i NUMBER;

    TYPE x07_docto_fiscal_tp IS TABLE OF msafi.x07_docto_fiscal_gtt%ROWTYPE;

    x07_docto_fiscal_typ x07_docto_fiscal_tp := x07_docto_fiscal_tp ( );

    TYPE x08_itens_merc_gtt_tp IS TABLE OF msafi.x08_itens_merc_gtt%ROWTYPE;

    x08_itens_merc_typ x08_itens_merc_gtt_tp := x08_itens_merc_gtt_tp ( );

    forall_failed EXCEPTION;
    PRAGMA EXCEPTION_INIT ( forall_failed
                          , -24381 );


--SELECT * FROM msafi.x08_itens_merc_gtt

    err_num NUMBER;
    err_msg VARCHAR2 ( 100 );
    l_error NUMBER;
    l_errors NUMBER;
    l_errno NUMBER;
    l_msg VARCHAR2 ( 4000 );
    l_idx NUMBER;

    log_x07_type msafi.x07_docto_fiscal_log_TT%ROWTYPE;
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
             AND FIN048_RET.NUM_DOCFIS  = '000019602'
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
            
            
            
            
            
            
            
   --END ;   

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

     ---   loga ( 'Recupera itens_merc' || SQL%ROWCOUNT );
     
     
          FORALL ix8 IN x08_itens_merc_typ.FIRST .. x08_itens_merc_typ.LAST SAVE EXCEPTIONS
          INSERT INTO msafi.x08_itens_merc_gtt
          VALUES x08_itens_merc_typ ( ix8 );
          
          
         --  select a.ident_cfo , a.* from msafi.x08_itens_merc_gtt  a  

        FOR j IN x08_itens_merc_typ.FIRST .. x08_itens_merc_typ.LAST LOOP
            BEGIN
                ---  base trib  merc
                DECLARE
                    x08t_type x08_trib_merc%ROWTYPE;
                BEGIN
--                    DBMS_OUTPUT.PUT_LINE ('COD_EMPRESA ---> '||x08_itens_merc_typ ( j ).cod_empresa);
--                   DBMS_OUTPUT.PUT_LINE ('COD_EMPRESA ---> '||x08_itens_merc_typ ( j ).cod_estab);
--                    DBMS_OUTPUT.PUT_LINE ('COD_EMPRESA ---> '||x08_itens_merc_typ ( j ).data_fiscal);
--                   DBMS_OUTPUT.PUT_LINE ('COD_EMPRESA ---> '||x08_itens_merc_typ ( j ).movto_e_s);
--                    DBMS_OUTPUT.PUT_LINE ('COD_EMPRESA ---> '||x08_itens_merc_typ ( j ).norm_dev);
--                   DBMS_OUTPUT.PUT_LINE ('COD_EMPRESA ---> '||x08_itens_merc_typ ( j ).ident_docto);
--                    DBMS_OUTPUT.PUT_LINE ('COD_EMPRESA ---> '||x08_itens_merc_typ ( j ).ident_fis_jur);
--                   DBMS_OUTPUT.PUT_LINE ('COD_EMPRESA ---> '||x08_itens_merc_typ ( j ).serie_docfis);
--                    DBMS_OUTPUT.PUT_LINE ('COD_EMPRESA ---> '||x08_itens_merc_typ ( j ).sub_serie_docfis);
--                   DBMS_OUTPUT.PUT_LINE ('COD_EMPRESA ---> '||x08_itens_merc_typ ( j ).discri_item);
                   
                
                 --   select * from msafi.x08_itens_merc_gtt
                
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


--                     SELECT *
--                      FROM x08_trib_merc
--                     WHERE cod_empresa = 'DP'
--                       AND cod_estab ='DP908'
--                       AND data_fiscal = '01/03/2016'
--                       AND movto_e_s = '1'
--                       AND norm_dev = '1'
--                       AND ident_docto = 43
--                       AND ident_fis_jur = 91802
--                       AND num_docfis ='000038578'
--                       AND serie_docfis ='1'
--                       AND discri_item = '00000017942100001UN      '
--                       AND cod_tributo = 'ICMS';
--                       
--                       
--                      SELECT *
--                      FROM x08_BASE_merc
--                     WHERE cod_empresa = 'DP'
--                       AND cod_estab ='DP908'
--                       AND data_fiscal = '01/03/2016'
--                       AND movto_e_s = '1'
--                       AND norm_dev = '1'
--                       AND ident_docto = 43
--                       AND ident_fis_jur = 91802
--                       AND num_docfis ='000038578'
--                       AND serie_docfis ='1'
--                       AND discri_item = '00000017942100001UN      '
--                       AND cod_tributo = 'ICMS';
                       


--                    DBMS_OUTPUT.PUT_LINE ('INSERT  ---> '||x08_itens_merc_typ ( j ).cod_empresa);
--                   DBMS_OUTPUT.PUT_LINE ('COD_EMPRESA ---> '||x08_itens_merc_typ ( j ).cod_estab);
--                    DBMS_OUTPUT.PUT_LINE ('COD_EMPRESA ---> '||x08_itens_merc_typ ( j ).data_fiscal);
--                   DBMS_OUTPUT.PUT_LINE ('COD_EMPRESA ---> '||x08_itens_merc_typ ( j ).movto_e_s);
--                    DBMS_OUTPUT.PUT_LINE ('COD_EMPRESA ---> '||x08_itens_merc_typ ( j ).norm_dev);
--                   DBMS_OUTPUT.PUT_LINE ('COD_EMPRESA ---> '||x08_itens_merc_typ ( j ).ident_docto);
--                    DBMS_OUTPUT.PUT_LINE ('COD_EMPRESA ---> '||x08_itens_merc_typ ( j ).ident_fis_jur);
--                   DBMS_OUTPUT.PUT_LINE ('COD_EMPRESA ---> '||x08_itens_merc_typ ( j ).serie_docfis);
--                    DBMS_OUTPUT.PUT_LINE ('COD_EMPRESA ---> '||x08_itens_merc_typ ( j ).sub_serie_docfis);
--                   DBMS_OUTPUT.PUT_LINE ('COD_EMPRESA ---> '||x08_itens_merc_typ ( j ).discri_item);
               

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
                               
                               
--                                 DBMS_OUTPUT.PUT_LINE ('DELETE BASE  ---> '||x08_itens_merc_typ ( j ).cod_empresa);
--                               DBMS_OUTPUT.PUT_LINE ('COD_EMPRESA ---> '||x08_itens_merc_typ ( j ).cod_estab);
--                                DBMS_OUTPUT.PUT_LINE ('COD_EMPRESA ---> '||x08_itens_merc_typ ( j ).data_fiscal);
--                               DBMS_OUTPUT.PUT_LINE ('COD_EMPRESA ---> '||x08_itens_merc_typ ( j ).movto_e_s);
--                                DBMS_OUTPUT.PUT_LINE ('COD_EMPRESA ---> '||x08_itens_merc_typ ( j ).norm_dev);
--                               DBMS_OUTPUT.PUT_LINE ('COD_EMPRESA ---> '||x08_itens_merc_typ ( j ).ident_docto);
--                                DBMS_OUTPUT.PUT_LINE ('COD_EMPRESA ---> '||x08_itens_merc_typ ( j ).ident_fis_jur);
--                               DBMS_OUTPUT.PUT_LINE ('COD_EMPRESA ---> '||x08_itens_merc_typ ( j ).serie_docfis);
--                                DBMS_OUTPUT.PUT_LINE ('COD_EMPRESA ---> '||x08_itens_merc_typ ( j ).sub_serie_docfis);
--                               DBMS_OUTPUT.PUT_LINE ('COD_EMPRESA ---> '||x08_itens_merc_typ ( j ).discri_item);

                       --     loga ( 'Recupera itens_trib delete' || SQL%ROWCOUNT );

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
                               
--                                   DBMS_OUTPUT.PUT_LINE ('DELETE TRIB  ---> '||x08_itens_merc_typ ( j ).cod_empresa);
--                               DBMS_OUTPUT.PUT_LINE ('COD_EMPRESA ---> '||x08_itens_merc_typ ( j ).cod_estab);
--                                DBMS_OUTPUT.PUT_LINE ('COD_EMPRESA ---> '||x08_itens_merc_typ ( j ).data_fiscal);
--                               DBMS_OUTPUT.PUT_LINE ('COD_EMPRESA ---> '||x08_itens_merc_typ ( j ).movto_e_s);
--                                DBMS_OUTPUT.PUT_LINE ('COD_EMPRESA ---> '||x08_itens_merc_typ ( j ).norm_dev);
--                               DBMS_OUTPUT.PUT_LINE ('COD_EMPRESA ---> '||x08_itens_merc_typ ( j ).ident_docto);
--                                DBMS_OUTPUT.PUT_LINE ('COD_EMPRESA ---> '||x08_itens_merc_typ ( j ).ident_fis_jur);
--                               DBMS_OUTPUT.PUT_LINE ('COD_EMPRESA ---> '||x08_itens_merc_typ ( j ).serie_docfis);
--                                DBMS_OUTPUT.PUT_LINE ('COD_EMPRESA ---> '||x08_itens_merc_typ ( j ).sub_serie_docfis);
--                               DBMS_OUTPUT.PUT_LINE ('COD_EMPRESA ---> '||x08_itens_merc_typ ( j ).discri_item);
                               

                            --loga ( 'Recupera itens_trib delete' || SQL%ROWCOUNT );
                        EXCEPTION
                            WHEN OTHERS THEN
                            
                            
                              DBMS_OUTPUT.PUT_LINE (err_msg||'01');
                                err_num := SQLCODE;
                                err_msg :=
                                    SUBSTR ( SQLERRM
                                           , 1
                                           , 100 );
                                log_x07_type.log_fin48 := 'ERROR :BLOCO 245 | DELETE ' || err_num || ' - ' || err_msg;

                                
                        END;
                    END IF;

                    BEGIN
                        SELECT x07_gtt.valor_aliquota_origem
                             , x07_gtt.valor_icms_origem
                          INTO x08t_type.aliq_tributo
                             , x08t_type.vlr_tributo
                          FROM msafi.x07_docto_fiscal_gtt x07_gtt
                         WHERE cod_empresa      = x08_itens_merc_typ ( j ).cod_empresa
                           AND cod_estab        = x08_itens_merc_typ ( j ).cod_estab
                           AND data_fiscal      = x08_itens_merc_typ ( j ).data_fiscal
                           AND movto_e_s        = x08_itens_merc_typ ( j ).movto_e_s
                           AND norm_dev         = x08_itens_merc_typ ( j ).norm_dev
                           AND ident_docto      = x08_itens_merc_typ ( j ).ident_docto
                           AND ident_fis_jur    = x08_itens_merc_typ ( j ).ident_fis_jur
                           AND num_docfis       = x08_itens_merc_typ ( j ).num_docfis
                           AND serie_docfis     = x08_itens_merc_typ ( j ).serie_docfis
                           AND sub_serie_docfis = x08_itens_merc_typ ( j ).sub_serie_docfis
                           AND num_item         = x08_itens_merc_typ ( j ).num_item;
                           
                           DBMS_OUTPUT.PUT_LINE (  'x08t_type.aliq_tributo --> '||  x08t_type.aliq_tributo);
                           DBMS_OUTPUT.PUT_LINE (  'x08t_type.vlr_tributo --> '||  x08t_type.vlr_tributo);
                      
                           
                           
                    EXCEPTION
                        WHEN OTHERS THEN
                          DBMS_OUTPUT.PUT_LINE (err_msg||'02');
                            err_num := SQLCODE;
                            err_msg :=
                                SUBSTR ( SQLERRM
                                       , 1
                                       , 100 );
                            log_x07_type.log_fin48 :=
                                'ERROR :BLOCO 276 | INTO X08T_TYPE ' || err_num || ' - ' || err_msg;

                            INSERT INTO msafi.x07_docto_fiscal_log_BKP
                            VALUES log_x07_type;
                    END;

                    ---  insert  trib
                    BEGIN
                        INSERT INTO x08_trib_merc
                        VALUES x08t_type;
                      --  loga ( 'Recupera itens_trib insert' || SQL%ROWCOUNT );
                         
                        DBMS_OUTPUT.PUT_LINE (  'x08t_type.COD_EMPRESA --> '||  x08t_type.cod_empresa);
                      
                      
                    EXCEPTION
                        WHEN OTHERS THEN
                          DBMS_OUTPUT.PUT_LINE (err_msg||'xxx 03 xxxxx ');
                          
                        
                            
--                          DBMS_OUTPUT.PUT_LINE (x08_itens_merc_typ ( j ).cod_empresa);
--                          DBMS_OUTPUT.PUT_LINE (x08_itens_merc_typ ( j ).cod_estab  );
--                          DBMS_OUTPUT.PUT_LINE (x08_itens_merc_typ ( j ).data_fiscal);
--                          DBMS_OUTPUT.PUT_LINE (x08_itens_merc_typ ( j ).movto_e_s);
--                          DBMS_OUTPUT.PUT_LINE (x08_itens_merc_typ ( j ).norm_dev);
--                          DBMS_OUTPUT.PUT_LINE (x08_itens_merc_typ ( j ).ident_docto);
--                          DBMS_OUTPUT.PUT_LINE (x08_itens_merc_typ ( j ).ident_fis_jur);
--                          DBMS_OUTPUT.PUT_LINE (x08_itens_merc_typ ( j ).num_docfis);
--                          DBMS_OUTPUT.PUT_LINE (x08_itens_merc_typ ( j ).serie_docfis);
--                          DBMS_OUTPUT.PUT_LINE (x08_itens_merc_typ ( j ).sub_serie_docfis);
--                          DBMS_OUTPUT.PUT_LINE (x08_itens_merc_typ ( j ).num_item);



                          
                          
                          
                            err_num := SQLCODE;
                            err_msg :=
                                SUBSTR ( SQLERRM
                                       , 1
                                       , 100 );
                            log_x07_type.log_fin48 := 'ERROR :BLOCO 293 | INSERT ' || err_num || ' - ' || err_msg;

                            INSERT INTO msafi.x07_docto_fiscal_log_BKP
                            VALUES log_x07_type;
                    END;
                END;

                --  AJUSTES NA BASE DO ICMS -  X08_BASE_MERC
                --  DECLARE
                ---    X08B_TYPE         X08_BASE_MERC%ROWTYPE;

                BEGIN
                  ---  loga ( 'Recupera itens_base' || SQL%ROWCOUNT );

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
                        DBMS_OUTPUT.PUT_LINE (err_msg||'04');
                        err_num := SQLCODE;
                        err_msg :=
                            SUBSTR ( SQLERRM
                                   , 1
                                   , 100 );
                        log_x07_type.log_fin48 := 'ERROR :BLOCO 195 | DELETE ' || err_num || ' - ' || err_msg;

                        --  INSERT
                        INSERT INTO msafi.x07_docto_fiscal_log_BKP
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
                    DBMS_OUTPUT.PUT_LINE (err_msg||'05');
                        err_num := SQLCODE;
                        err_msg :=
                            SUBSTR ( SQLERRM
                                   , 1
                                   , 100 );
                        log_x07_type.log_fin48 := 'ERROR :BLOCO 171 | DELETE ' || err_num || ' - ' || err_msg;
                END;
            EXCEPTION
                WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE (err_msg||'06');
                    err_num := SQLCODE;
                    err_msg :=
                        SUBSTR ( SQLERRM
                               , 1
                               , 100 );
                    log_x07_type.log_fin48 := 'ERROR :BLOCO 293 | INSERT ' || err_num || ' - ' || err_msg;

                    INSERT INTO msafi.x07_docto_fiscal_log_BKP
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
                DBMS_OUTPUT.PUT_LINE (err_msg||'07');
                    err_num := SQLCODE;
                    err_msg :=
                        SUBSTR ( SQLERRM
                               , 1
                               , 100 );
                    log_x07_type.log_fin48 := 'ERROR :BLOCO 403 | CFOP_SAIDA_ORIGEM ' || err_num || ' - ' || err_msg;

                    --
                    INSERT INTO msafi.x07_docto_fiscal_log_BKP
                    VALUES log_x07_type;
            END;

            l_ident_natureza_op := x08_itens_merc_typ ( j ).ident_natureza_op;

            BEGIN
              DBMS_OUTPUT.PUT_LINE (l_cfop_saida_origem);     
              DBMS_OUTPUT.PUT_LINE (l_ident_natureza_op);
            
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
                                                                        , '2209'
                                                                                ) THEN 
                                                                                        
                                                '2152'
                                            ELSE
                                                l_cfop_saida_origem
                                        END)
                   AND x2006.valid_natureza_op = (SELECT MAX ( valid_natureza_op )
                                                    FROM x2006_natureza_op op
                                                   WHERE 1=1
                                                   AND op.valid_natureza_op <= x08_itens_merc_typ ( j ).data_fiscal
                                                   AND x2006.ident_natureza_op  = op.ident_natureza_op  
                                                   );
                                                   
                                              
                                                   
            EXCEPTION
                WHEN NO_DATA_FOUND THEN 
                   DBMS_OUTPUT.PUT_LINE (l_ident_cfo ||' NO_DATA_FOUND ERRR  <<<  08  AKKK  >>>   ');
            
                WHEN OTHERS THEN
                
                INSERT INTO msafi.x07_docto_fiscal_log_BKP
                    VALUES log_x07_type;
                    
                    
              
                    err_num := SQLCODE;
                    err_msg :=
                        SUBSTR ( SQLERRM
                               , 1
                               , 100 );
                    log_x07_type.log_fin48 := 'ERROR :BLOCO 479 | L_IDENT_CFO ' || err_num || ' - ' || err_msg;
                        
                    DBMS_OUTPUT.PUT_LINE (err_msg);
           
                    
                    
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
                DBMS_OUTPUT.PUT_LINE (err_msg||'09');
                    err_num := SQLCODE;
                    err_msg :=
                        SUBSTR ( SQLERRM
                               , 1
                               , 100 );
                    log_x07_type.log_fin48 :=
                        'ERROR :BLOCO 613 | L_IDENT_SITUACAO_B UP ' || err_num || ' - ' || err_msg;

                    --
                    INSERT INTO msafi.x07_docto_fiscal_log_TT
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
                DBMS_OUTPUT.PUT_LINE (err_msg||'10');
                    err_num := SQLCODE;
                    err_msg :=
                        SUBSTR ( SQLERRM
                               , 1
                               , 100 );
                    log_x07_type.log_fin48 := 'ERROR :BLOCO 520 | X08_ITENS_MERC UP ' || err_num || ' - ' || err_msg;

                    --
                    INSERT INTO msafi.x07_docto_fiscal_log_TT
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
            EXCEPTION 
            WHEN OTHERS THEN 
        DBMS_OUTPUT.PUT_LINE ('98');
           --- loga ( 'DW atualizados - Nr. Itens ' || i );
        END;
    EXCEPTION
        WHEN forall_failed THEN
        
         DBMS_OUTPUT.PUT_LINE ('99');
        
       
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
                log_x07_type.log_fin48 := 'ERROR :BLOCO 530 | INSERT ' || l_errno || ' - ' || l_msg || ' - ' || l_idx;

                INSERT INTO msafi.x07_docto_fiscal_log_BKP
                VALUES log_x07_type;
            END LOOP;

            COMMIT;
    END;
END; -- prc_upd_nf_entrada;
















        select * from msafi.x08_itens_merc_gtt



     create table msafi.dpsp_entrada_nf_dp908_tt
     as  select * from msafi.dpsp_entrada_nf_dp908_gtt 
     where 1=0  ;  ---   drop table 
     
     select * from msafi.dpsp_entrada_nf_dp908_tt
     where num_docfis = '000019602'
     
     
  ---   carregar_nf_entrada
 insert into  msafi.dpsp_entrada_nf_dp908_tt
      SELECT DISTINCT a.cod_empresa,
                      a.cod_estab,
                      a.data_fiscal,
                      a.movto_e_s,
                      a.norm_dev,
                      a.ident_docto,
                      a.ident_fis_jur,
                      a.num_docfis,
                      a.serie_docfis,
                      a.sub_serie_docfis,
                      a.discri_item,
                      a.num_autentic_nfe,
                      a.cod_produto,
                      a.num_item
     FROM msafi.dpsp_nf_entrada     a
     ,    msafi.x08_itens_merc_gtt  b
       WHERE 1 = 1
         AND a.data_fiscal = b.data_fiscal 
         AND a.cod_empresa = b.cod_empresa
         AND a.cod_estab = b.cod_estab
         AND a.movto_e_s <> '9'
         AND a.situacao = 'N'
         AND a.cod_cfo NOT IN ('2557');
  



  --- 
   
          ---  segunda carga   
        SELECT gtt.cod_empresa,
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
               nvl((SELECT ip.tax_brl_bse
                     FROM fdspprd.ps_ar_imp_bbl_bkp_nov2016@dblink_dbpsthst ip 
                    WHERE 1 = 1
                      AND i.business_unit = ip.business_unit
                      AND i.nf_brl_id = ip.nf_brl_id
                      AND i.nf_brl_line_num = ip.nf_brl_line_num
                      AND ip.tax_id_bbl IN ('ICMS')),
                   0) AS vlr_base_icms,
               nvl((SELECT ip.tax_brl_amt
                     FROM fdspprd.ps_ar_imp_bbl_bkp_nov2016@dblink_dbpsthst ip 
                    WHERE 1 = 1
                      AND i.business_unit = ip.business_unit
                      AND i.nf_brl_id = ip.nf_brl_id
                      AND i.nf_brl_line_num = ip.nf_brl_line_num
                      AND ip.tax_id_bbl IN ('ICMS')),
                   0) AS vlr_icms,
               nvl((SELECT ip.tax_brl_amt
                     FROM  fdspprd.ps_ar_imp_bbl_bkp_nov2016@dblink_dbpsthst ip 
                    WHERE 1 = 1
                      AND i.business_unit = ip.business_unit
                      AND i.nf_brl_id = ip.nf_brl_id
                      AND i.nf_brl_line_num = ip.nf_brl_line_num
                      AND ip.tax_id_bbl IN ('ICMST')),
                   0) AS vlr_icms_st
          FROM fdspprd.ps_ar_nfret_bbl_bkp_nov2016@dblink_dbpsthst    capa,
               fdspprd.ps_ar_itens_nf_bbl_bkp_nov2016@dblink_dbpsthst             i,
               msafi.dpsp_entrada_nf_dp908_tt            gtt
         WHERE 1 = 1
           AND i.inv_item_id = gtt.cod_produto
           AND capa.nfee_key_bbl = gtt.num_autentic_nfe
           AND capa.business_unit = i.business_unit
           AND i.nf_brl_line_num = gtt.num_item
           and NUM_DOCFIS = '000019602'
           AND capa.nf_brl_id = i.nf_brl_id
           AND i.cfo_brl_cd =  '6.152';





         -- nada   
         
  SELECT /*+ DRIVING_SITE(i) parallel(32) */
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
     SUM(icms_st.tax_brl_amt) vlr_icms_st
      FROM msafi.ps_ar_nfret_bbl     capa,
           msafi.ps_ar_itens_nf_bbl  i,
           msafi.ps_ar_imp_bbl       icms,
           msafi.ps_ar_imp_bbl       icms_st,
          msafi.dpsp_entrada_nf_dp908_tt gtt
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
              i.cfo_brl_cd
              
              
      ---   
      
      CREATE TABLE msafi.dpsp_msaf_fin048_xml_tt
      AS SELECT * FROM msafi.dpsp_msaf_fin048_xml_gtt
      WHERE 0=1 
      
      --  drop table msafi.dpsp_msaf_fin048_xml_tt
      
      
      SELECT * FROM msafi.dpsp_msaf_fin048_xml_tt
      
      INSERT INTO msafi.dpsp_msaf_fin048_xml_tt
       SELECT /*+DRIVING_SITE(i)*/
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
       cfop_forn cfo_brl_cd,          ---   CFOP --OK   ( 000019602  )   -- 6101
       SUM(vlr_base_icms) vlr_base_icms,
       SUM(vlr_icms) vlr_icms,
       SUM(vlr_icms_st) vlr_icms_st,
        3,
       1 mproc_id,
       SYSDATE
        FROM msafi.ps_xml_forn xml_forn, msafi.dpsp_entrada_nf_dp908_tt gtt
       WHERE xml_forn.inv_item_id = gtt.cod_produto
         AND xml_forn.nfe_verif_code_pbl = gtt.num_autentic_nfe
          and NUM_DOCFIS = '000019602'
         AND xml_forn.cfop_forn IN
             ('6101', '6102', '6105', '6106', '6401', '6403', '6404')
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
                cfop_forn;        
                
                
                
                
                
                dpsp_fin048_ret_nf_ent
                
                CREATE TABLE   msafi.dpsp_fin048_ret_nf_ent_TT
                AS  SELECT * FROM  msafi.dpsp_fin048_ret_nf_ent
                WHERE 1=0;
                -- DROP  TABLE msafi.dpsp_fin048_ret_nf_ent_TT   --  até  
                
                
                
            
           INSERT INTO  msafi.dpsp_fin048_ret_nf_ent_tt
           SELECT *
                FROM (SELECT /*+ parallel(32) */ x07.cod_empresa AS cod_empresa,
                             x07.cod_estab AS cod_estab,
                             x07.data_fiscal AS data_fiscal,
                             x07.num_docfis AS num_docfis,
                             x07.num_autentic_nfe AS num_autentic_nfe,
                             x04.cod_fis_jur AS cod_fis_jur,
                             x04.cpf_cgc AS cpf_cgc,
                             x2005.cod_docto AS cod_docto,
                             x2024.cod_modelo AS cod_modelo,
                             x2012.cod_cfo AS cod_cfo,
                             x2006.cod_natureza_op AS natureza_operacao,
                             x2013.cod_produto AS cod_produto,
                             substr(x2013.descricao, 1, 255) AS descricao,
                             y2025.cod_situacao_a AS cst_a,
                             y2026.cod_situacao_b AS cst_b,
                             x08.quantidade AS quantidade,
                             x2043.cod_nbm AS ncm,
                             x08.num_item AS num_item,
                             x08.vlr_contab_item AS vlr_contabil_item,
                             x08.vlr_item AS vlr_item,
                             (SELECT nvl(x08_base.vlr_base, 0)
                                FROM msaf.x08_base_merc x08_base
                               WHERE x08.cod_empresa = x08_base.cod_empresa
                                 AND x08.cod_estab = x08_base.cod_estab
                                 AND x08.data_fiscal = x08_base.data_fiscal
                                 AND x08.movto_e_s = x08_base.movto_e_s
                                 AND x08.norm_dev = x08_base.norm_dev
                                 AND x08.ident_docto = x08_base.ident_docto
                                 AND x08.ident_fis_jur =
                                     x08_base.ident_fis_jur
                                 AND x08.num_docfis = x08_base.num_docfis
                                 AND x08.serie_docfis = x08_base.serie_docfis
                                 AND x08.sub_serie_docfis =
                                     x08_base.sub_serie_docfis
                                 AND x08.discri_item = x08_base.discri_item
                                 AND x08_base.cod_tributo = 'ICMS'
                                 AND x08_base.cod_tributacao = '1') AS vlr_base_icms_1,
                             (SELECT nvl(x08_base_trib.aliq_tributo, 0)
                                FROM msaf.x08_trib_merc x08_base_trib
                               WHERE x08.cod_empresa =
                                     x08_base_trib.cod_empresa
                                 AND x08.cod_estab = x08_base_trib.cod_estab
                                 AND x08.data_fiscal =
                                     x08_base_trib.data_fiscal
                                 AND x08.movto_e_s = x08_base_trib.movto_e_s
                                 AND x08.norm_dev = x08_base_trib.norm_dev
                                 AND x08.ident_docto =
                                     x08_base_trib.ident_docto
                                 AND x08.ident_fis_jur =
                                     x08_base_trib.ident_fis_jur
                                 AND x08.num_docfis = x08_base_trib.num_docfis
                                 AND x08.serie_docfis =
                                     x08_base_trib.serie_docfis
                                 AND x08.sub_serie_docfis =
                                     x08_base_trib.sub_serie_docfis
                                 AND x08.discri_item =
                                     x08_base_trib.discri_item
                                 AND x08_base_trib.cod_tributo = 'ICMS') AS vlr_aliquota,
                             (SELECT nvl(x08_base_trib.vlr_tributo, 0)
                                FROM msaf.x08_trib_merc x08_base_trib
                               WHERE x08.cod_empresa =
                                     x08_base_trib.cod_empresa
                                 AND x08.cod_estab = x08_base_trib.cod_estab
                                 AND x08.data_fiscal =
                                     x08_base_trib.data_fiscal
                                 AND x08.movto_e_s = x08_base_trib.movto_e_s
                                 AND x08.norm_dev = x08_base_trib.norm_dev
                                 AND x08.ident_docto =
                                     x08_base_trib.ident_docto
                                 AND x08.ident_fis_jur =
                                     x08_base_trib.ident_fis_jur
                                 AND x08.num_docfis = x08_base_trib.num_docfis
                                 AND x08.serie_docfis =
                                     x08_base_trib.serie_docfis
                                 AND x08.sub_serie_docfis =
                                     x08_base_trib.sub_serie_docfis
                                 AND x08.discri_item =
                                     x08_base_trib.discri_item
                                 AND x08_base_trib.cod_tributo = 'ICMS') AS vlr_icms_proprio,
                             (SELECT nvl(x08_base.vlr_base, 0)
                                FROM msaf.x08_base_merc x08_base
                               WHERE x08.cod_empresa = x08_base.cod_empresa
                                 AND x08.cod_estab = x08_base.cod_estab
                                 AND x08.data_fiscal = x08_base.data_fiscal
                                 AND x08.movto_e_s = x08_base.movto_e_s
                                 AND x08.norm_dev = x08_base.norm_dev
                                 AND x08.ident_docto = x08_base.ident_docto
                                 AND x08.ident_fis_jur =
                                     x08_base.ident_fis_jur
                                 AND x08.num_docfis = x08_base.num_docfis
                                 AND x08.serie_docfis = x08_base.serie_docfis
                                 AND x08.sub_serie_docfis =
                                     x08_base.sub_serie_docfis
                                 AND x08.discri_item = x08_base.discri_item
                                 AND x08_base.cod_tributo = 'ICMS'
                                 AND x08_base.cod_tributacao = '2') AS vlr_base_icms_2,
                             (SELECT nvl(SUM(x08_base.vlr_base), 0)
                                FROM msaf.x08_base_merc x08_base
                               WHERE x08.cod_empresa = x08_base.cod_empresa
                                 AND x08.cod_estab = x08_base.cod_estab
                                 AND x08.data_fiscal = x08_base.data_fiscal
                                 AND x08.movto_e_s = x08_base.movto_e_s
                                 AND x08.norm_dev = x08_base.norm_dev
                                 AND x08.ident_docto = x08_base.ident_docto
                                 AND x08.ident_fis_jur =
                                     x08_base.ident_fis_jur
                                 AND x08.num_docfis = x08_base.num_docfis
                                 AND x08.serie_docfis = x08_base.serie_docfis
                                 AND x08.sub_serie_docfis =
                                     x08_base.sub_serie_docfis
                                 AND x08.discri_item = x08_base.discri_item
                                 AND x08_base.cod_tributo = 'ICMS'
                                 AND x08_base.cod_tributacao = '3') AS vlr_base_icms_3,
                             REPLACE(aux.cfo_brl_cd, '.', '') AS cfop_saida_origem,     -- CFOP  6101  /  000019602
                             x2012.cod_cfo AS cfop_entrada_origem,
                             aux.vlr_base_icms AS valor_base_icms_origem,
                             (SELECT nvl(c.icmstax_brl_pct, 0) AS aliq_icms
                                FROM msafi.ps_nf_ln_brl c
                               WHERE c.nf_brl_id = x07.num_controle_docto
                                 AND c.business_unit =
                                     (CASE x07.cod_empresa WHEN 'DP' THEN
                                      'POCDP' WHEN 'DSP' THEN 'POCOM' END)
                                 AND c.nf_brl_line_num = x08.num_item) AS valor_aliquota_origem,
                             aux.vlr_icms AS valor_icms_origem,
                             to_char(aux.vlr_icms_st) AS cst_origem,
                             x07.num_controle_docto AS num_controle_docto,
                             proc_id AS proc_id,
                             'A' AS nm_usuario,
                             SYSDATE AS dt_carga,
                             'S' status
                        FROM msaf.x07_docto_fiscal          x07,
                             msaf.x08_itens_merc            x08,
                             msaf.x04_pessoa_fis_jur        x04,
                             msaf.estado                    estado,
                             msaf.x2005_tipo_docto          x2005,
                             msaf.x2024_modelo_docto        x2024,
                             msaf.x2012_cod_fiscal          x2012,
                             msaf.x2013_produto             x2013,
                             msaf.x2043_cod_nbm             x2043,
                             msaf.y2025_sit_trb_uf_a        y2025,
                             msaf.y2026_sit_trb_uf_b        y2026,
                             msaf.x2006_natureza_op         x2006,
                             msafi.dpsp_msaf_fin048_xml_tt aux
                       WHERE x07.data_fiscal BETWEEN '01/03/2016' AND '01/03/2016'
                         AND x07.cod_empresa = 'DP'
                         and aux.NUM_DOCFIS = '000019602'
                         AND x07.cod_estab = 'DP908'
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
                         AND x08.ident_natureza_op =
                             x2006.ident_natureza_op(+)
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
                         AND x08.discri_item = aux.discri_item)  ;
                         
                         
                         
                         
                         
                         
                      





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
             AND FIN048_RET.NUM_DOCFIS  = '000019602'
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






SELECT * FROM msafi.x07_docto_fiscal_gtt


   
      SELECT 
            fin048_ret.COD_CFO
         ,  fin048_ret.CFOP_SAIDA_ORIGEM
         ,  fin048_ret.*        
        FROM msafi.dpsp_fin048_ret_nf_ent_tt  fin048_ret, x07_docto_fiscal x07
       WHERE fin048_ret.data_fiscal BETWEEN '01/03/2016' AND '01/03/2016'
         AND   FIN048_RET.NUM_DOCFIS  = '000019602'
         AND fin048_ret.cod_estab = 'DP908'
         AND fin048_ret.cod_empresa = 'DP'
         AND fin048_ret.cod_empresa = x07.cod_empresa
         AND fin048_ret.cod_estab = x07.cod_estab
         AND fin048_ret.num_docfis = x07.num_docfis
         AND fin048_ret.data_fiscal = x07.data_fiscal
         AND fin048_ret.num_controle_docto = x07.num_controle_docto
         AND fin048_ret.num_autentic_nfe = x07.num_autentic_nfe
         AND x07.data_fiscal BETWEEN '01/03/2016' AND '01/03/2016'
         AND x07.cod_estab = 'DP908'
         AND x07.cod_empresa = 'DP'
                         
                         
                         
         ---  
          --      l_cfop_saida_origem := NULL;
         
         SELECT x07_gtt.cfop_saida_origem
            FROM msafi.x07_docto_fiscal_gtt x07_gtt
           WHERE cod_empresa        = 'DP'
             AND cod_estab          = 'DP908'
             AND data_fiscal        = '01/03/2016'
             AND movto_e_s          = '1'
             AND norm_dev           = '1'
             AND ident_docto        = 43
             AND ident_fis_jur      = 138105
             AND num_docfis         = '000019602'
             AND serie_docfis       = '0'
             
             
         




                 SELECT x2081.ident_cfo
                  FROM x2012_cod_fiscal x2012
                     , x2081_extensao_cfo x2081
                     , x2006_natureza_op x2006
                 WHERE x2012.ident_cfo = x2081.ident_cfo
                   AND x2006.ident_natureza_op = x2081.ident_natureza_op
                   AND x2081.ident_natureza_op = 9    
                   AND x2012.cod_cfo = (CASE
                                            WHEN '6101' IN ( '6102' , '6101' , '6105', '6106', '6401', '6403', '6404' ) THEN '2102'
                                            WHEN '6101' IN ( '6152' , '2209')                                           THEN '2152'
                                            ELSE '6101'
                                        END)
                   AND x2006.valid_natureza_op = ( SELECT MAX( valid_natureza_op )
                                                     FROM x2006_natureza_op op
                                                    WHERE op.valid_natureza_op <= '01/03/2016'
                                                    AND   x2006.ident_natureza_op  = op.ident_natureza_op  -- > Solução para o problema 
                                                   );
      




                SELECT x2081.ident_cfo, valid_natureza_op
                  FROM x2012_cod_fiscal x2012
                     , x2081_extensao_cfo x2081
                     , x2006_natureza_op x2006
                 WHERE x2012.ident_cfo = x2081.ident_cfo
                   AND x2006.ident_natureza_op = x2081.ident_natureza_op
                   AND x2081.ident_natureza_op = 9    
                       AND x2012.cod_cfo = (CASE
                                            WHEN '6101' IN ( '6102' , '6101' , '6105', '6106', '6401', '6403', '6404' ) THEN '2102'
                                            WHEN '6101' IN ( '6152' , '2209')                                           THEN '2152'
                                            ELSE '6101'
                                        END)
                                             
                                         



                                           SELECT x2006.*
                                             FROM x2006_natureza_op x2006
                                            WHERE 1=1
                                            AND  valid_natureza_op <= '01/03/2016'
                                                  