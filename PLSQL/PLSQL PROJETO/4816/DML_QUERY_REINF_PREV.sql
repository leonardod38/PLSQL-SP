SELECT * FROM msafi.fin4816_reinf_prev_gtt

delete  msafi.fin4816_reinf_prev_gtt;


--INSERT INTO msafi.fin4816_reinf_prev_gtt
 SELECT 
   cod_empresa, cod_estab, data_emissao, 
   data_fiscal, ident_fis_jur, ident_docto, 
   num_docfis, serie_docfis, sub_serie_docfis, 
   num_item, cod_usuario, tipo,  cod_fis_jur, 
   x04_razao_social, ind_fis_jur,  cpf_cgc, 
   cod_class_doc_fis, vlr_tot_nota,vlr_base_inss, 
   vlr_aliq_inss, vlr_inss_retido, vlr_contab_compl, 
   ind_tipo_proc, num_proc_jur,    razao_social, cgc, 
   descricao,    cod_tipo_serv_esocial,    
   dsc_tipo_serv_esocial,    empresa_razao_social,    
   vlr_servico, num_proc_adj_adic, ind_tp_proc_adj_adic, 
   codigo_serv_prod, desc_serv_prod
 FROM (SELECT 'S' AS tipo
                 , reinf.cod_empresa
                 , reinf.cod_estab
                 , reinf.ident_fis_jur
                 , x04.cod_fis_jur
                 , x04.razao_social x04_razao_social
                 , x04.ind_fis_jur
                 , x04.cpf_cgc
                 , reinf.num_docfis
                 , reinf.serie_docfis
                 , reinf.sub_serie_docfis
                 , reinf.num_item
                 , reinf.data_emissao
                 , reinf.data_fiscal
                 , reinf.cod_class_doc_fis
                 , reinf.vlr_tot_nota
                 , reinf.vlr_base_inss
                 , reinf.vlr_aliq_inss
                 , reinf.vlr_inss_retido
                 , reinf.vlr_contab_compl
                 , reinf.ind_tipo_proc
                 , reinf.num_proc_jur
                 , estab.razao_social
                 , estab.cgc
                 , x2005.descricao
                 , prt_tipo.cod_tipo_serv_esocial
                 , prt_tipo.dsc_tipo_serv_esocial
                 , empresa.razao_social empresa_razao_social
                 , reinf.vlr_servico
                 , reinf.num_proc_adj_adic
                 , reinf.ind_tp_proc_adj_adic
                 , x2018.cod_servico AS codigo_serv_prod
                 , x2018.descricao AS desc_serv_prod
                 , reinf.cod_usuario
                 , reinf.ident_docto
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
               AND reinf.cod_usuario = 'marcelo.orikasa'
               AND reinf.ident_servico = x2018.ident_servico
            UNION
            SELECT 'R' AS tipo
                 , reinf.cod_empresa
                 , reinf.cod_estab
                 , reinf.ident_fis_jur
                 , x04.cod_fis_jur
                 , x04.razao_social
                 , x04.ind_fis_jur
                 , x04.cpf_cgc
                 , reinf.num_docfis
                 , reinf.serie_docfis
                 , reinf.sub_serie_docfis
                 , reinf.num_item
                 , reinf.data_emissao
                 , reinf.data_fiscal
                 , reinf.cod_class_doc_fis
                 , reinf.vlr_tot_nota
                 , reinf.vlr_base_inss
                 , reinf.vlr_aliq_inss
                 , reinf.vlr_inss_retido
                 , reinf.vlr_contab_compl
                 , reinf.ind_tipo_proc
                 , reinf.num_proc_jur
                 , estab.razao_social
                 , estab.cgc
                 , x2005.descricao
                 , TO_CHAR ( reinf.cod_param, '000000000' )
                 , prt_repasse.dsc_param
                 , empresa.razao_social
                 , reinf.vlr_servico
                 , reinf.num_proc_adj_adic
                 , reinf.ind_tp_proc_adj_adic
                 , x2018.cod_servico AS codigo_serv_prod
                 , x2018.descricao AS desc_serv_prod
                 , reinf.cod_usuario
                 , reinf.ident_docto
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
               AND reinf.cod_usuario = 'marcelo.orikasa'
               AND reinf.ident_servico = x2018.ident_servico
            UNION
            SELECT 'P' AS tipo
                 , reinf.cod_empresa
                 , reinf.cod_estab
                 , reinf.ident_fis_jur
                 , x04.cod_fis_jur
                 , x04.razao_social
                 , x04.ind_fis_jur
                 , x04.cpf_cgc
                 , reinf.num_docfis
                 , reinf.serie_docfis
                 , reinf.sub_serie_docfis
                 , reinf.num_item
                 , reinf.data_emissao
                 , reinf.data_fiscal
                 , reinf.cod_class_doc_fis
                 , reinf.vlr_tot_nota
                 , reinf.vlr_base_inss
                 , reinf.vlr_aliq_inss
                 , reinf.vlr_inss_retido
                 , reinf.vlr_contab_compl
                 , reinf.ind_tipo_proc
                 , reinf.num_proc_jur
                 , estab.razao_social
                 , estab.cgc
                 , x2005.descricao
                 , prt_tipo.cod_tipo_serv_esocial
                 , prt_tipo.dsc_tipo_serv_esocial
                 , empresa.razao_social
                 , reinf.vlr_servico
                 , reinf.num_proc_adj_adic
                 , reinf.ind_tp_proc_adj_adic
                 , x2013.cod_produto AS codigo_serv_prod
                 , x2013.descricao AS desc_serv_prod
                 , reinf.cod_usuario
                 , reinf.ident_docto
              FROM msafi.reinf_conf_previdenciaria_tmp reinf
                 , x04_pessoa_fis_jur x04
                 , estabelecimento estab
                 , x2005_tipo_docto x2005
                 , prt_tipo_serv_esocial prt_tipo
                 , x2013_produto x2013
                 , empresa
             WHERE reinf.ident_fis_jur = x04.ident_fis_jur
               AND reinf.cod_empresa = estab.cod_empresa
               AND reinf.cod_estab = estab.cod_estab
               AND reinf.ident_docto = x2005.ident_docto
               AND reinf.ident_tipo_serv_esocial = prt_tipo.ident_tipo_serv_esocial /*(+)*/
               AND reinf.cod_empresa = empresa.cod_empresa
               AND LENGTH ( TRIM ( x04.cpf_cgc ) ) > 11
               AND reinf.cod_usuario = 'marcelo.orikasa'
               AND reinf.ident_produto = x2013.ident_produto)