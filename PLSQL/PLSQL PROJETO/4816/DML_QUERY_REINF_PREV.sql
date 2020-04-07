SELECT * FROM msafi.fin4816_reinf_prev_gtt



INSERT INTO msafi.fin4816_reinf_prev_gtt
 SELECT 
   COD_EMPRESA, COD_ESTAB, DATA_EMISSAO, 
   DATA_FISCAL, IDENT_FIS_JUR, IDENT_DOCTO, 
   NUM_DOCFIS, SERIE_DOCFIS, SUB_SERIE_DOCFIS, 
   NUM_ITEM, COD_USUARIO, TIPO,  COD_FIS_JUR, 
   X04_RAZAO_SOCIAL, IND_FIS_JUR,  CPF_CGC, 
   COD_CLASS_DOC_FIS, VLR_TOT_NOTA,VLR_BASE_INSS, 
   VLR_ALIQ_INSS, VLR_INSS_RETIDO, VLR_CONTAB_COMPL, 
   IND_TIPO_PROC, NUM_PROC_JUR,    RAZAO_SOCIAL, CGC, 
   DESCRICAO,    COD_TIPO_SERV_ESOCIAL,    
   DSC_TIPO_SERV_ESOCIAL,    EMPRESA_RAZAO_SOCIAL,    
   VLR_SERVICO, NUM_PROC_ADJ_ADIC, IND_TP_PROC_ADJ_ADIC, 
   CODIGO_SERV_PROD, DESC_SERV_PROD
   
   
   
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
                 , TO_CHAR ( reinf.cod_param
                           , '000000000' )
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