

                    SELECT   
                       x09_itens_serv.cod_empresa                           as cod_empresa      
                     , x09_itens_serv.cod_estab                             as cod_estab
                     , x09_itens_serv.data_fiscal                           as data_fiscal               
                     , x09_itens_serv.movto_e_s                             as movto_e_s                 
                     , x09_itens_serv.norm_dev                  
                     , x09_itens_serv.ident_docto               
                     , x09_itens_serv.ident_fis_jur             
                     , x09_itens_serv.num_docfis                
                     , x09_itens_serv.serie_docfis              
                     , x09_itens_serv.sub_serie_docfis          
                     , x09_itens_serv.ident_servico             
                     , x09_itens_serv.num_item     
                     , x07_docto_fiscal.data_emissao                      as perido_emissao   
                     , estabelecimento.cgc                                as cgc 
                     , x07_docto_fiscal.num_docfis                        as num_docto
                     , x2005_tipo_docto.cod_docto                         as tipo_docto
                     , x07_docto_fiscal.data_emissao                      as data_emissao                    
                     , x04_pessoa_fis_jur.cpf_cgc                         as cgc_fornecedor
                     , estado.cod_estado                                  as uf
                     , MAX(x09_itens_serv.vlr_tot)                        as valor_total
                     , MAX(x09_itens_serv.vlr_base_inss)                  as base_inss
                     , MAX(x09_itens_serv.vlr_inss_retido )               as valor_inss
                     , MAX(x04_pessoa_fis_jur.cod_fis_jur )               as cod_fis_jur
                     , x04_pessoa_fis_jur.razao_social                    as razao_social
                     , municipio.descricao                                as municipio_prestador
                     , x2018_servicos.cod_servico                         as cod_servico
                    FROM x07_docto_fiscal
                       , x2005_tipo_docto    
                       , x04_pessoa_fis_jur      
                       , x09_itens_serv
                       , estabelecimento
                       , estado  
                       , x2018_servicos
                       , municipio  
                       , msafi.fin4816_prev_tmp_estab estab
                   WHERE 1=1 
                     AND   x09_itens_serv.cod_empresa               =   estabelecimento.cod_empresa
                     AND   x09_itens_serv.cod_estab                 =   estabelecimento.cod_estab
                     AND   x09_itens_serv.cod_estab                 =   estab.cod_estab
                    -- AND   estab.proc_id                            =   p_proc_id
                     AND   x09_itens_serv.cod_empresa               =   x07_docto_fiscal.cod_empresa
                     AND   x09_itens_serv.cod_estab                 =   x07_docto_fiscal.cod_estab
                     AND   x09_itens_serv.data_fiscal               =   x07_docto_fiscal.data_fiscal
                     AND   x07_docto_fiscal.data_emissao            =   '19/04/2018'     
                     AND   x09_itens_serv.vlr_inss_retido           > 0              
                     AND   x09_itens_serv.movto_e_s                 =   x07_docto_fiscal.movto_e_s
                     AND   x09_itens_serv.norm_dev                  =   x07_docto_fiscal.norm_dev
                     AND   x09_itens_serv.ident_docto               =   x07_docto_fiscal.ident_docto
                     AND   x09_itens_serv.ident_fis_jur             =   x07_docto_fiscal.ident_fis_jur
                     AND   x09_itens_serv.num_docfis                =   x07_docto_fiscal.num_docfis
                     AND   x09_itens_serv.serie_docfis              =   x07_docto_fiscal.serie_docfis
                     AND   x09_itens_serv.sub_serie_docfis          =   x07_docto_fiscal.sub_serie_docfis
                     -- estado /municio 
                     and  estado.ident_estado                       = x04_pessoa_fis_jur.ident_estado
                     and  municipio.ident_estado                    = estado.ident_estado 
                     and  municipio.cod_municipio                   = x04_pessoa_fis_jur.cod_municipio
                     --  X2018_SERVICOS
                     AND  x2018_servicos.ident_servico  = x09_itens_serv.ident_servico
                     AND ( x2005_tipo_docto.ident_docto = x07_docto_fiscal.ident_docto )
                     AND ( x04_pessoa_fis_jur.ident_fis_jur = x07_docto_fiscal.ident_fis_jur )
                   --  AND ( x07_docto_fiscal.data_fiscal <= pdata_final   )    ---  DATA EMISSAO 
                    -- AND ( x07_docto_fiscal.data_fiscal >= pdata_inicial )
                     AND ( x07_docto_fiscal.movto_e_s IN ( 1
                                                         , 2
                                                         , 3
                                                         , 4
                                                         , 5 ) )
                     AND ( ( x07_docto_fiscal.situacao <> 'S' )
                       OR ( x07_docto_fiscal.situacao IS NULL ) )
                     AND ( x07_docto_fiscal.cod_estab  IS NOT NULL  )  -- COD_ESTAB 
                     --AND ( x07_docto_fiscal.cod_empresa =  pcod_empresa )
                     AND ( x07_docto_fiscal.cod_class_doc_fis = '2' )
                     AND ( ( x07_docto_fiscal.ident_cfo IS NULL )
                       OR ( NOT ( EXISTS
                                     (SELECT 1
                                        FROM x2012_cod_fiscal x2012
                                           , prt_cfo_uf_msaf pcum
                                           , estabelecimento est
                                       WHERE x2012.ident_cfo = x07_docto_fiscal.ident_cfo
                                         AND est.cod_empresa = x07_docto_fiscal.cod_empresa
                                         AND est.cod_estab = x07_docto_fiscal.cod_estab
                                         AND pcum.cod_empresa = est.cod_empresa
                                         AND pcum.cod_param = 415  --
                                         AND pcum.ident_estado = est.ident_estado
                                         AND pcum.cod_cfo = x2012.cod_cfo)
                             AND EXISTS
                                     (SELECT 1
                                        FROM ict_par_icms_uf ipiu
                                           , estabelecimento esta
                                       WHERE ipiu.ident_estado = esta.ident_estado
                                         AND esta.cod_empresa = x07_docto_fiscal.cod_empresa
                                         AND esta.cod_estab = x07_docto_fiscal.cod_estab
                                         AND ipiu.dsc_param = '64'
                                         AND ipiu.ind_tp_par = 'S') ) ) )
                GROUP BY x07_docto_fiscal.cod_empresa
                       , x07_docto_fiscal.cod_estab
                       , x07_docto_fiscal.num_docfis
                       , x2005_tipo_docto.cod_docto
                       , x07_docto_fiscal.serie_docfis
                       , x07_docto_fiscal.sub_serie_docfis
                       , x07_docto_fiscal.movto_e_s
                       , x07_docto_fiscal.data_emissao
                       , x07_docto_fiscal.data_fiscal
                       , x04_pessoa_fis_jur.cpf_cgc
                       , x04_pessoa_fis_jur.ident_estado
                       , x04_pessoa_fis_jur.razao_social
                       , x04_pessoa_fis_jur.cod_municipio
                       --, x07_docto_fiscal.vlr_tot_nota
                       , x09_itens_serv.vlr_tot
                       , Estabelecimento.Cgc
                       , Estado.Cod_Estado    
                       , X09_Itens_Serv.Vlr_Base_Inss   
                       , X2018_Servicos.Cod_Servico  
                       , Municipio.Descricao  
                       --
                         ,  x09_itens_serv.cod_empresa               
                         , x09_itens_serv.cod_estab                 
                         , x09_itens_serv.data_fiscal               
                         , x09_itens_serv.movto_e_s                 
                         , x09_itens_serv.norm_dev                  
                         , x09_itens_serv.ident_docto               
                         , x09_itens_serv.ident_fis_jur             
                         , x09_itens_serv.num_docfis                
                         , x09_itens_serv.serie_docfis              
                         , x09_itens_serv.sub_serie_docfis          
                         , x09_itens_serv.ident_servico             
                         , x09_itens_serv.num_item      
                ORDER BY
                  cod_empresa
                , cod_estab
                , data_emissao
                , num_docto;