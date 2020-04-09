DECLARE
    TYPE typ_tipo_prv                   IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.tipo%TYPE;
    TYPE typ_codigo_empresa_prv         IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Codigo Empresa"%TYPE;
    TYPE typ_codigo_estab_prv           IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Codigo Estabelecimento"%TYPE;
    TYPE typ_data_emissao_prv           IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Data Emissão"%TYPE;
    TYPE typ_data_fiscal_prv            IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Data Fiscal"%TYPE;
    TYPE typ_ident_fis_jur_prv          IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.ident_fis_jur%TYPE;
    TYPE typ_ident_docto_prv            IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.ident_docto%TYPE;
    TYPE typ_numero_nota_fiscal_prv     IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Número da Nota Fiscal"%TYPE;
    TYPE typ_docto_serie_prv            IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Docto/Série"%TYPE;
    TYPE typ_emissao_prv                IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Emissão"%TYPE;
    TYPE typ_serie_docfis_prv           IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.serie_docfis%TYPE;
    TYPE typ_sub_serie_docfis_prv       IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.sub_serie_docfis%TYPE;
    TYPE typ_num_item_prv               IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.num_item%TYPE;
    TYPE typ_cod_usuario_prv            IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.cod_usuario%TYPE;
    TYPE typ_codigo_pess_fis_jur_prv    IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Codigo Pessoa Fisica/Juridica"%TYPE;
    TYPE typ_razao_social_cliente_prv   IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Razão Social Cliente"%TYPE;
    TYPE typ_ind_fis_jur_prv            IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.ind_fis_jur%TYPE;
    TYPE typ_cnpj_cliente_prv           IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."CNPJ Cliente"%TYPE;
    TYPE typ_cod_class_doc_fis_prv      IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.cod_class_doc_fis%TYPE;
    TYPE typ_vlr_tot_nota_prv           IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.vlr_tot_nota%TYPE;
    TYPE typ_vlr_bs_calc_retencao_prv   IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Vlr Base Calc. Retenção"%TYPE;
    TYPE typ_vlr_aliq_inss_prv          IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.vlr_aliq_inss%TYPE;
    TYPE typ_vlr_trib_inss_retido_prv   IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Vlr.Trib INSS RETIDO"%TYPE;
    TYPE typ_vlr_retencao__prv           IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Valor da Retenção"%TYPE;
    TYPE typ_vlr_contab_compl_prv       IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.vlr_contab_compl%TYPE;
    TYPE typ_ind_tipo_proc_prv          IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.ind_tipo_proc%TYPE;
    TYPE typ_num_proc_jur_prv           IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.num_proc_jur%TYPE;
    TYPE typ_razao_social_prv           IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.razao_social%TYPE;
    TYPE typ_cgc_prv                    IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.cgc%TYPE;
    TYPE typ_documento_prv              IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Documento"%TYPE;
    TYPE typ_tipo_serv_e_social_prv     IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Tipo de Serviço E-social"%TYPE;
    TYPE typ_dsc_tipo_serv_esocial_prv  IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.dsc_tipo_serv_esocial%TYPE;
    TYPE typ_razao_social_drogaria_prv  IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Razão Social Drogaria"%TYPE;
    TYPE typ_valor_servico_prv          IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Valor do Servico"%TYPE;
    TYPE typ_num_proc_adj_adic_prv      IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.num_proc_adj_adic%TYPE;
    TYPE typ_ind_tp_proc_adj_adic_prv   IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.ind_tp_proc_adj_adic%TYPE;
    TYPE typ_codigo_serv_prod_prv       IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.codigo_serv_prod%TYPE;
    TYPE typ_desc_serv_prod_prv         IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.desc_serv_prod%TYPE;
    TYPE typ_cod_docto_prv              IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.cod_docto%TYPE;
    TYPE typ_observação_prv             IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Observação"%TYPE;
    TYPE typ_dsc_param_prv              IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.dsc_param%TYPE;

                            typ_tipo_prv                   
                            typ_codigo_empresa_prv             
                            typ_codigo_estab_prv               
                            typ_data_emissao_prv               
                            typ_data_fiscal_prv                
                            typ_ident_fis_jur_prv              
                            typ_ident_docto_prv                
                            typ_numero_nota_fiscal_prv         
                            typ_docto_serie_prv                
                            typ_emissao_prv                    
                            typ_serie_docfis_prv               
                            typ_sub_serie_docfis_prv           
                            typ_num_item_prv                   
                            typ_cod_usuario_prv                
                            typ_codigo_pess_fis_jur_prv        
                            typ_razao_social_cliente_prv       
                            typ_ind_fis_jur_prv                
                            typ_cnpj_cliente_prv               
                            typ_cod_class_doc_fis_prv          
                            typ_vlr_tot_nota_prv               
                            typ_vlr_bs_calc_retencao_prv       
                            typ_vlr_aliq_inss_prv              
                            typ_vlr_trib_inss_retido_prv       
                            typ_vlr_retencao__prv              
                            typ_vlr_contab_compl_prv           
                            typ_ind_tipo_proc_prv              
                            typ_num_proc_jur_prv               
                            typ_razao_social_prv               
                            typ_cgc_prv                        
                            typ_documento_prv                  
                            typ_tipo_serv_e_social_prv         
                            typ_dsc_tipo_serv_esocial_prv      
                            typ_razao_social_drogaria_prv      
                            typ_valor_servico_prv              
                            typ_num_proc_adj_adic_prv          
                            typ_ind_tp_proc_adj_adic_prv       
                            typ_codigo_serv_prod_prv           
                            typ_desc_serv_prod_prv             
                            typ_cod_docto_prv                  
                            typ_observação_prv                 
                            typ_dsc_param_prv                  
                                
                                



    CURSOR rc_prev
    IS
        SELECT 'Servico' AS tipo
             , reinf.cod_empresa AS "Codigo Empresa"
             , reinf.cod_estab AS "Codigo Estabelecimento"
             , reinf.data_emissao AS "Data Emissão"
             , reinf.data_fiscal AS "Data Fiscal"
             , reinf.ident_fis_jur
             , reinf.ident_docto
             , reinf.num_docfis AS "Número da Nota Fiscal"
             --
             , reinf.num_docfis || '/' || reinf.serie_docfis AS "Docto/Série"
             , reinf.data_emissao AS "Emissão"
             --
             , reinf.serie_docfis
             , reinf.sub_serie_docfis
             , reinf.num_item
             , reinf.cod_usuario
             , x04.cod_fis_jur AS "Codigo Pessoa Fisica/Juridica"
             , INITCAP ( x04.razao_social ) AS "Razão Social Cliente"
             , x04.ind_fis_jur
             , x04.cpf_cgc AS "CNPJ Cliente"
             , reinf.cod_class_doc_fis
             , reinf.vlr_tot_nota
             , reinf.vlr_base_inss AS "Vlr Base Calc. Retenção"
             , reinf.vlr_aliq_inss
             , reinf.vlr_inss_retido AS "Vlr.Trib INSS RETIDO"
             , reinf.vlr_inss_retido AS "Valor da Retenção"
             , reinf.vlr_contab_compl
             , reinf.ind_tipo_proc
             , reinf.num_proc_jur
             , estab.razao_social
             , estab.cgc
             , x2005.descricao AS "Documento"
             , prt_tipo.cod_tipo_serv_esocial AS "Tipo de Serviço E-social"
             , prt_tipo.dsc_tipo_serv_esocial
             , INITCAP ( empresa.razao_social ) AS "Razão Social Drogaria"
             , reinf.vlr_servico AS "Valor do Servico"
             , reinf.num_proc_adj_adic
             , reinf.ind_tp_proc_adj_adic
             , x2018.cod_servico AS codigo_serv_prod
             , INITCAP ( x2018.descricao ) AS desc_serv_prod
             , x2005.cod_docto
             , NULL AS "Observação"
             , NULL AS dsc_param
          FROM msafi.reinf_conf_previdenciaria_tmp reinf
             , x04_pessoa_fis_jur x04
             , estabelecimento estab
             , x2005_tipo_docto x2005
             , prt_tipo_serv_esocial prt_tipo
             , x2018_servicos x2018
             , empresa
         WHERE reinf.ident_fis_jur = x04.ident_fis_jur
           AND reinf.cod_empresa = estab.cod_empresa
           AND reinf.cod_estab = estab.cod_estab
           AND reinf.ident_docto = x2005.ident_docto
           AND reinf.ident_tipo_serv_esocial = prt_tipo.ident_tipo_serv_esocial /*(+)*/
           AND reinf.cod_empresa = empresa.cod_empresa
           AND LENGTH ( TRIM ( x04.cpf_cgc ) ) > 11
           AND reinf.ident_servico = x2018.ident_servico
           AND reinf.cod_usuario = 'marcelo.orikasa' -- parametro
           AND reinf.cod_empresa = 'DSP' -- parametro
           AND reinf.data_emissao = '4/12/2018' -- parametro
           AND reinf.cod_estab = 'DSP062'
        UNION
        SELECT 'R' AS tipo
             , reinf.cod_empresa AS "Codigo Empresa"
             , reinf.cod_estab AS "Codigo Estabelecimento"
             , reinf.data_emissao AS "Data Emissão"
             , reinf.data_fiscal AS "Data Fiscal"
             , reinf.ident_fis_jur
             , reinf.ident_docto
             , reinf.num_docfis AS "Número da Nota Fiscal"
             --
             , reinf.num_docfis || '/' || reinf.serie_docfis AS "Docto/Série"
             , reinf.data_emissao AS "Emissão"
             --
             , reinf.serie_docfis
             , reinf.sub_serie_docfis
             , reinf.num_item
             , reinf.cod_usuario
             , x04.cod_fis_jur AS "Codigo Pessoa Fisica/Juridica"
             , INITCAP ( x04.razao_social ) AS "Razão Social Cliente"
             , x04.ind_fis_jur
             , x04.cpf_cgc AS "CNPJ Cliente"
             , reinf.cod_class_doc_fis
             , reinf.vlr_tot_nota
             , reinf.vlr_base_inss AS "Vlr Base Calc. Retenção"
             , reinf.vlr_aliq_inss
             , reinf.vlr_inss_retido AS "Vlr.Trib INSS RETIDO"
             , reinf.vlr_inss_retido AS "Valor da Retenção"
             , reinf.vlr_contab_compl
             , reinf.ind_tipo_proc
             , reinf.num_proc_jur
             , estab.razao_social
             , estab.cgc
             , x2005.descricao AS "Documento"
             , NULL
             , NULL
             , INITCAP ( empresa.razao_social ) AS "Razão Social Drogaria"
             , reinf.vlr_servico AS "Valor do Servico"
             , reinf.num_proc_adj_adic
             , reinf.ind_tp_proc_adj_adic
             , x2018.cod_servico AS codigo_serv_prod
             , INITCAP ( x2018.descricao ) AS desc_serv_prod
             , x2005.cod_docto
             , NULL AS "Observação"
             , prt_repasse.dsc_param
          FROM msafi.reinf_conf_previdenciaria_tmp reinf
             , x04_pessoa_fis_jur x04
             , estabelecimento estab
             , x2005_tipo_docto x2005
             , prt_par2_msaf prt_repasse
             , x2018_servicos x2018
             , empresa
         WHERE reinf.ident_fis_jur = x04.ident_fis_jur
           AND reinf.cod_empresa = estab.cod_empresa
           AND reinf.cod_estab = estab.cod_estab
           AND reinf.ident_docto = x2005.ident_docto
           AND reinf.cod_param = prt_repasse.cod_param
           AND reinf.cod_empresa = empresa.cod_empresa
           AND LENGTH ( TRIM ( x04.cpf_cgc ) ) > 11
           AND reinf.ident_servico = x2018.ident_servico-- parametros
                                                        --  AND reinf.cod_usuario                = mnm_usuario
                                                        --  AND reinf.cod_empresa                = p_cod_empresa
                                                        --  AND reinf.cod_estab                  = p_cod_estab
                                                        --  AND reinf.data_emissao              >= p_data_inicial
                                                        --  AND reinf.data_emissao              <= p_data_final
                                                        ;
BEGIN
    OPEN rc_prev;

    LOOP
     --
     --   dbms_application_info.set_module ( cc_procedurename
     --                                    , 'Executando o fetch previdenciario ...' );

        FETCH rc_prev
            BULK COLLECT INTO -- TABLE  TMP
                             g_tipo
               , g_codigo_empresa
               , g_codigo_estab
               , g_data_emissao
               , g_data_fiscal_1
               , g_ident_fis_jur
               , g_ident_docto
               , g_numero_nota_fiscal
               , g_docto_serie
               , g_emissao
               , g_serie_docfis
               , g_sub_serie_docfis
               , g_num_item
               , g_cod_usuario
               , g_codigo_pess_fis_jur
               , g_razao_social_cliente
               , g_ind_fis_jur
               , g_cnpj_cliente
               , g_cod_class_doc_fis
               , g_vlr_tot_nota
               , g_vlr_bs_calc_retencao
               , g_vlr_aliq_inss
               , g_vlr_trib_inss_retido
               , g_vlr_retenção
               , g_vlr_contab_compl
               , g_ind_tipo_proc
               , g_num_proc_jur
               , g_razao_social
               , g_cgc
               , g_documento
               , g_tipo_serv_e_social
               , g_dsc_tipo_serv_esocial
               , g_razao_social_drogaria
               , g_valor_servico
               , g_num_proc_adj_adic
               , g_ind_tp_proc_adj_adic
               , g_codigo_serv_prod
               , g_desc_serv_prod
               , g_cod_docto
               , g_observação
               , g_dsc_param
            LIMIT 100;
            
            
            FORALL i IN g_codigo_empresa.FIRST .. g_codigo_empresa.LAST
            
                               INSERT /*+ APPEND */
                               INTO MSAFI.DPSP_TB_FIN4816_REINF_PREV_GTT (
                               TIPO, "Codigo Empresa", "Codigo Estabelecimento", 
                               "Data Emissão", "Data Fiscal", IDENT_FIS_JUR, 
                               IDENT_DOCTO, "Número da Nota Fiscal", "Docto/Série", 
                               "Emissão", SERIE_DOCFIS, SUB_SERIE_DOCFIS, 
                               NUM_ITEM, COD_USUARIO, "Codigo Pessoa Fisica/Juridica", 
                               "Razão Social Cliente", IND_FIS_JUR, "CNPJ Cliente", 
                               COD_CLASS_DOC_FIS, VLR_TOT_NOTA, "Vlr Base Calc. Retenção", 
                               VLR_ALIQ_INSS, "Vlr.Trib INSS RETIDO", "Valor da Retenção", 
                               VLR_CONTAB_COMPL, IND_TIPO_PROC, NUM_PROC_JUR, 
                               RAZAO_SOCIAL, CGC, "Documento", 
                               "Tipo de Serviço E-social", DSC_TIPO_SERV_ESOCIAL, "Razão Social Drogaria", 
                               "Valor do Servico", NUM_PROC_ADJ_ADIC, IND_TP_PROC_ADJ_ADIC, 
                               CODIGO_SERV_PROD, DESC_SERV_PROD, COD_DOCTO, 
                               "Observação", DSC_PARAM) 
                               VALUES (      
                                             g_tipo                       (i)
                                           , g_codigo_empresa             (i)
                                           , g_codigo_estab               (i)
                                           , g_data_emissao               (i)
                                           , g_data_fiscal_1              (i)
                                           , g_ident_fis_jur              (i)
                                           , g_ident_docto                (i)
                                           , g_numero_nota_fiscal         (i)
                                           , g_docto_serie                (i)
                                           , g_emissao                    (i)
                                           , g_serie_docfis               (i)
                                           , g_sub_serie_docfis           (i)
                                           , g_num_item                   (i)
                                           , g_cod_usuario                (i)
                                           , g_codigo_pess_fis_jur        (i)
                                           , g_razao_social_cliente       (i)
                                           , g_ind_fis_jur                (i)
                                           , g_cnpj_cliente               (i)
                                           , g_cod_class_doc_fis          (i)
                                           , g_vlr_tot_nota               (i)
                                           , g_vlr_bs_calc_retencao       (i)
                                           , g_vlr_aliq_inss              (i)
                                           , g_vlr_trib_inss_retido       (i)
                                           , g_vlr_retenção               (i)
                                           , g_vlr_contab_compl           (i)
                                           , g_ind_tipo_proc              (i)
                                           , g_num_proc_jur               (i)
                                           , g_razao_social               (i)
                                           , g_cgc                        (i)
                                           , g_documento                  (i)
                                           , g_tipo_serv_e_social         (i)
                                           , g_dsc_tipo_serv_esocial      (i)
                                           , g_razao_social_drogaria      (i)
                                           , g_valor_servico              (i)
                                           , g_num_proc_adj_adic          (i)
                                           , g_ind_tp_proc_adj_adic       (i)
                                           , g_codigo_serv_prod           (i)
                                           , g_desc_serv_prod             (i)
                                           , g_cod_docto                  (i)
                                           , g_observação                 (i)
                                           , g_dsc_param                  (i) 
 );
            
            
            
            
               
            

        EXIT WHEN rc_prev%NOTFOUND;
    END LOOP;

    COMMIT;
        
    CLOSE rc_prev;

    COMMIT;
END;