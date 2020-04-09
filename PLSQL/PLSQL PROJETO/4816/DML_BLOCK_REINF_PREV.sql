DECLARE 

TYPE  typ_tipo                               IS TABLE OF       MSAFI.DPSP_TB_FIN4816_REINF_PREV_GTT.TIPO                           %TYPE;   
TYPE  typ_codigo_empresa                     IS TABLE OF       MSAFI.DPSP_TB_FIN4816_REINF_PREV_GTT."Codigo Empresa"               %TYPE;   
TYPE  typ_codigo_estab                       IS TABLE OF       MSAFI.DPSP_TB_FIN4816_REINF_PREV_GTT."Codigo Estabelecimento"       %TYPE;   
TYPE  typ_data_emissao                       IS TABLE OF       MSAFI.DPSP_TB_FIN4816_REINF_PREV_GTT."Data Emissão"                 %TYPE;   
TYPE  typ_data_fiscal_1                      IS TABLE OF       MSAFI.DPSP_TB_FIN4816_REINF_PREV_GTT."Data Fiscal"                  %TYPE;   
TYPE  typ_ident_fis_jur                      IS TABLE OF       MSAFI.DPSP_TB_FIN4816_REINF_PREV_GTT.IDENT_FIS_JUR                  %TYPE;   
TYPE  typ_ident_docto                        IS TABLE OF       MSAFI.DPSP_TB_FIN4816_REINF_PREV_GTT.IDENT_DOCTO                    %TYPE;   
TYPE  typ_numero_nota_fiscal                 IS TABLE OF       MSAFI.DPSP_TB_FIN4816_REINF_PREV_GTT."Número da Nota Fiscal"        %TYPE;   
TYPE  typ_docto_serie                        IS TABLE OF       MSAFI.DPSP_TB_FIN4816_REINF_PREV_GTT."Docto/Série"                  %TYPE;   
TYPE  typ_emissao                            IS TABLE OF       MSAFI.DPSP_TB_FIN4816_REINF_PREV_GTT."Emissão"                      %TYPE;   
TYPE  typ_serie_docfis                       IS TABLE OF       MSAFI.DPSP_TB_FIN4816_REINF_PREV_GTT.SERIE_DOCFIS                   %TYPE;   
TYPE  typ_sub_serie_docfis                   IS TABLE OF       MSAFI.DPSP_TB_FIN4816_REINF_PREV_GTT.SUB_SERIE_DOCFIS               %TYPE;   
TYPE  typ_num_item                           IS TABLE OF       MSAFI.DPSP_TB_FIN4816_REINF_PREV_GTT.NUM_ITEM                       %TYPE;   
TYPE  typ_cod_usuario                        IS TABLE OF       MSAFI.DPSP_TB_FIN4816_REINF_PREV_GTT.COD_USUARIO                    %TYPE;   
TYPE  typ_codigo_pess_fis_jur                IS TABLE OF       MSAFI.DPSP_TB_FIN4816_REINF_PREV_GTT."Codigo Pessoa Fisica/Juridica"%TYPE;   
TYPE  typ_razao_social_cliente               IS TABLE OF       MSAFI.DPSP_TB_FIN4816_REINF_PREV_GTT."Razão Social Cliente"         %TYPE;   
TYPE  typ_ind_fis_jur                        IS TABLE OF       MSAFI.DPSP_TB_FIN4816_REINF_PREV_GTT.IND_FIS_JUR                    %TYPE;   
TYPE  typ_cnpj_cliente                       IS TABLE OF       MSAFI.DPSP_TB_FIN4816_REINF_PREV_GTT."CNPJ Cliente"                 %TYPE;   
TYPE  typ_cod_class_doc_fis                  IS TABLE OF       MSAFI.DPSP_TB_FIN4816_REINF_PREV_GTT.COD_CLASS_DOC_FIS              %TYPE;   
TYPE  typ_vlr_tot_nota                       IS TABLE OF       MSAFI.DPSP_TB_FIN4816_REINF_PREV_GTT.VLR_TOT_NOTA                   %TYPE;   
TYPE  typ_vlr_bs_calc_retencao               IS TABLE OF       MSAFI.DPSP_TB_FIN4816_REINF_PREV_GTT."Vlr Base Calc. Retenção"      %TYPE;   
TYPE  typ_vlr_aliq_inss                      IS TABLE OF       MSAFI.DPSP_TB_FIN4816_REINF_PREV_GTT.VLR_ALIQ_INSS                  %TYPE;   
TYPE  typ_vlr_trib_inss_retido               IS TABLE OF       MSAFI.DPSP_TB_FIN4816_REINF_PREV_GTT."Vlr.Trib INSS RETIDO"         %TYPE;   
TYPE  typ_vlr_retenção                       IS TABLE OF       MSAFI.DPSP_TB_FIN4816_REINF_PREV_GTT."Valor da Retenção"            %TYPE;   
TYPE  typ_vlr_contab_compl                   IS TABLE OF       MSAFI.DPSP_TB_FIN4816_REINF_PREV_GTT.VLR_CONTAB_COMPL               %TYPE;   
TYPE  typ_ind_tipo_proc                      IS TABLE OF       MSAFI.DPSP_TB_FIN4816_REINF_PREV_GTT.IND_TIPO_PROC                  %TYPE;   
TYPE  typ_num_proc_jur                       IS TABLE OF       MSAFI.DPSP_TB_FIN4816_REINF_PREV_GTT.NUM_PROC_JUR                   %TYPE;   
TYPE  typ_razao_social                       IS TABLE OF       MSAFI.DPSP_TB_FIN4816_REINF_PREV_GTT.RAZAO_SOCIAL                   %TYPE;   
TYPE  typ_cgc                                IS TABLE OF       MSAFI.DPSP_TB_FIN4816_REINF_PREV_GTT.CGC                            %TYPE;   
TYPE  typ_documento                          IS TABLE OF       MSAFI.DPSP_TB_FIN4816_REINF_PREV_GTT."Documento"                    %TYPE;   
TYPE  typ_tipo_serv_e_social                 IS TABLE OF       MSAFI.DPSP_TB_FIN4816_REINF_PREV_GTT."Tipo de Serviço E-social"     %TYPE;   
TYPE  typ_dsc_tipo_serv_esocial              IS TABLE OF       MSAFI.DPSP_TB_FIN4816_REINF_PREV_GTT.DSC_TIPO_SERV_ESOCIAL          %TYPE;   
TYPE  typ_razao_social_drogaria              IS TABLE OF       MSAFI.DPSP_TB_FIN4816_REINF_PREV_GTT."Razão Social Drogaria"        %TYPE;   
TYPE  typ_valor_servico                      IS TABLE OF       MSAFI.DPSP_TB_FIN4816_REINF_PREV_GTT."Valor do Servico"             %TYPE;   
TYPE  typ_num_proc_adj_adic                  IS TABLE OF       MSAFI.DPSP_TB_FIN4816_REINF_PREV_GTT.NUM_PROC_ADJ_ADIC              %TYPE;   
TYPE  typ_ind_tp_proc_adj_adic               IS TABLE OF       MSAFI.DPSP_TB_FIN4816_REINF_PREV_GTT.IND_TP_PROC_ADJ_ADIC           %TYPE;   
TYPE  typ_codigo_serv_prod                   IS TABLE OF       MSAFI.DPSP_TB_FIN4816_REINF_PREV_GTT.CODIGO_SERV_PROD               %TYPE;   
TYPE  typ_desc_serv_prod                     IS TABLE OF       MSAFI.DPSP_TB_FIN4816_REINF_PREV_GTT.DESC_SERV_PROD                 %TYPE;   
TYPE  typ_cod_docto                          IS TABLE OF       MSAFI.DPSP_TB_FIN4816_REINF_PREV_GTT.COD_DOCTO                      %TYPE;   
TYPE  typ_observação                         IS TABLE OF       MSAFI.DPSP_TB_FIN4816_REINF_PREV_GTT."Observação"                   %TYPE;   
TYPE  typ_dsc_param                          IS TABLE OF       MSAFI.DPSP_TB_FIN4816_REINF_PREV_GTT.DSC_PARAM                      %TYPE;   
                             

        g_tipo                         typ_tipo                             ;     
        g_codigo_empresa               typ_codigo_empresa                   ;
        g_codigo_estab                 typ_codigo_estab                     ;
        g_data_emissao                 typ_data_emissao                     ;
        g_data_fiscal_1                typ_data_fiscal_1                    ;
        g_ident_fis_jur                typ_ident_fis_jur                    ;
        g_ident_docto                  typ_ident_docto                      ;
        g_numero_nota_fiscal           typ_numero_nota_fiscal               ;
        g_docto_serie                  typ_docto_serie                      ;
        g_emissao                      typ_emissao                          ;
        g_serie_docfis                 typ_serie_docfis                     ;
        g_sub_serie_docfis             typ_sub_serie_docfis                 ;
        g_num_item                     typ_num_item                         ;
        g_cod_usuario                  typ_cod_usuario                      ;
        g_codigo_pess_fis_jur          typ_codigo_pess_fis_jur              ;
        g_razao_social_cliente         typ_razao_social_cliente             ;
        g_ind_fis_jur                  typ_ind_fis_jur                      ;
        g_cnpj_cliente                 typ_cnpj_cliente                     ;
        g_cod_class_doc_fis            typ_cod_class_doc_fis                ;
        g_vlr_tot_nota                 typ_vlr_tot_nota                     ;
        g_vlr_bs_calc_retencao         typ_vlr_bs_calc_retencao             ;
        g_vlr_aliq_inss                typ_vlr_aliq_inss                    ;
        g_vlr_trib_inss_retido         typ_vlr_trib_inss_retido             ;
        g_vlr_retenção                 typ_vlr_retenção                     ;
        g_vlr_contab_compl             typ_vlr_contab_compl                 ;
        g_ind_tipo_proc                typ_ind_tipo_proc                    ;
        g_num_proc_jur                 typ_num_proc_jur                     ;
        g_razao_social                 typ_razao_social                     ;
        g_cgc                          typ_cgc                              ;
        g_documento                    typ_documento                        ;
        g_tipo_serv_e_social           typ_tipo_serv_e_social               ;
        g_dsc_tipo_serv_esocial        typ_dsc_tipo_serv_esocial            ;
        g_razao_social_drogaria        typ_razao_social_drogaria            ;
        g_valor_servico                typ_valor_servico                    ;
        g_num_proc_adj_adic            typ_num_proc_adj_adic                ;
        g_ind_tp_proc_adj_adic         typ_ind_tp_proc_adj_adic             ;
        g_codigo_serv_prod             typ_codigo_serv_prod                 ;
        g_desc_serv_prod               typ_desc_serv_prod                   ;
        g_cod_docto                    typ_cod_docto                        ;
        g_observação                   typ_observação                       ;
        g_dsc_param                    typ_dsc_param                        ;



CURSOR rc_prev
IS
SELECT 'Servico'                                        AS tipo
     , reinf.cod_empresa                                AS "Codigo Empresa"
     , reinf.cod_estab                                  AS "Codigo Estabelecimento"
     , reinf.data_emissao                               AS "Data Emissão"
     , reinf.data_fiscal                                AS "Data Fiscal"
     , reinf.ident_fis_jur
     , reinf.ident_docto
     , reinf.num_docfis                                 AS "Número da Nota Fiscal"
     --
     , reinf.num_docfis || '/' || reinf.serie_docfis    AS "Docto/Série"
     , reinf.data_emissao                               AS "Emissão"
     --
     , reinf.serie_docfis
     , reinf.sub_serie_docfis
     , reinf.num_item
     , reinf.cod_usuario
     , x04.cod_fis_jur                                  AS "Codigo Pessoa Fisica/Juridica"
     , INITCAP ( x04.razao_social )                     AS "Razão Social Cliente"
     , x04.ind_fis_jur
     , x04.cpf_cgc                                      AS "CNPJ Cliente"
     , reinf.cod_class_doc_fis
     , reinf.vlr_tot_nota
     , reinf.vlr_base_inss                              AS "Vlr Base Calc. Retenção"
     , reinf.vlr_aliq_inss
     , reinf.vlr_inss_retido                            AS "Vlr.Trib INSS RETIDO"
     , reinf.vlr_inss_retido                            AS "Valor da Retenção"
     , reinf.vlr_contab_compl
     , reinf.ind_tipo_proc
     , reinf.num_proc_jur
     , estab.razao_social
     , estab.cgc
     , x2005.descricao                                  AS "Documento"
     , prt_tipo.cod_tipo_serv_esocial                   AS "Tipo de Serviço E-social"
     , prt_tipo.dsc_tipo_serv_esocial
     , INITCAP ( empresa.razao_social )                 AS "Razão Social Drogaria"
     , reinf.vlr_servico                                AS "Valor do Servico"
     , reinf.num_proc_adj_adic
     , reinf.ind_tp_proc_adj_adic
     , x2018.cod_servico                                AS codigo_serv_prod
     , INITCAP ( x2018.descricao )                      AS desc_serv_prod
     , x2005.cod_docto
     , NULL                                             AS "Observação"
     , NULL                                             AS dsc_param
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
   AND reinf.ident_servico = x2018.ident_servico
     -- parametros
--  AND reinf.cod_usuario                = mnm_usuario
--  AND reinf.cod_empresa                = p_cod_empresa
--  AND reinf.cod_estab                  = p_cod_estab
--  AND reinf.data_emissao              >= p_data_inicial
--  AND reinf.data_emissao              <= p_data_final
;
BEGIN
     OPEN rc_prev   ;
        LOOP
           --
           DBMS_APPLICATION_INFO.SET_MODULE(cc_procedurename,'Executando o fetch previdenciario ...');
          FETCH rc_prev 
                BULK COLLECT INTO    -- TABLE  TMP                      
                   g_cod_empresa                                                       
                  ,g_cod_estab                                                         
                  ,g_data_fiscal                                                       
                  ,g_movto_e_s                                                         
                  ,g_norm_dev                                                          
                  ,g_ident_docto                                                       
                  ,g_ident_fis_jur                                                     
                  ,g_num_docfis                                                        
                  ,g_serie_docfis                                                      
                  ,g_sub_serie_docfis                                                  
                  ,g_ident_servico                                                     
                  ,g_num_item                                                          
                  ,g_periodo_emissao                                                   
                  ,g_cgc                                                               
                  ,g_num_docto                                                         
                  ,g_tipo_docto                                                        
                  ,g_data_emissao                                                      
                  ,g_cgc_fornecedor                                                    
                  ,g_uf                                                                
                  ,g_valor_total                                                       
                  ,g_vlr_base_inss                                                     
                  ,g_vlr_inss                                                          
                  ,g_codigo_fisjur                                                     
                  ,g_razao_social                                                      
                  ,g_municipio_prestador                                               
                  ,g_cod_servico                                                       
                  ,g_cod_cei   
                  ,g_equalizacao      
                  
                  
                  
                  
                  
                  
                  
                  
                  
                  
                  
                  
                  
                  
                  
                  
                  
                  
                  
                  
                  
                  
                  
                  
                  
                  
                  
                  
                  
                  
                  
                  
                  
                  
                  
                  
                  
                  
                  
                                                                    
                LIMIT 100;
END ;


