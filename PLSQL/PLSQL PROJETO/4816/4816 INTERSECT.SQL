



                 SELECT 
                   (    SELECT r2010.cod_empresa
                            FROM msafi.fin4816_reinf_2010_gtt     r2010
                           WHERE 1=1 
                           AND    r2010.cod_empresa                 = rpf.cod_empresa
                           AND    r2010.cod_estab                   = rpf.cod_estab
                           AND    r2010.dat_emissao                 = rpf.data_emissao
                           AND    r2010.data_fiscal                 = rpf.data_fiscal
                           AND    r2010.num_docfis                  = rpf.num_docfis 
                           AND    r2010.RNK = 1 )                                           AS "Codigo Empresa"
                    ,(    SELECT INITCAP(r2010."Razão Social Drogaria")
                            FROM msafi.fin4816_reinf_2010_gtt     r2010
                           WHERE 1=1 
                           AND    r2010.cod_empresa                 = rpf.cod_empresa
                           AND    r2010.cod_estab                   = rpf.cod_estab
                           AND    r2010.dat_emissao                 = rpf.data_emissao
                           AND    r2010.data_fiscal                 = rpf.data_fiscal
                           AND    r2010.num_docfis                  = rpf.num_docfis 
                           AND    r2010.RNK = 1 )                                           AS "Razão Social Drogaria."
                    ,(    SELECT INITCAP(r2010."Razão Social Cliente")
                            FROM msafi.fin4816_reinf_2010_gtt     r2010
                           WHERE 1=1 
                           AND    r2010.cod_empresa                 = rpf.cod_empresa
                           AND    r2010.cod_estab                   = rpf.cod_estab
                           AND    r2010.dat_emissao                 = rpf.data_emissao
                           AND    r2010.data_fiscal                 = rpf.data_fiscal
                           AND    r2010.num_docfis                  = rpf.num_docfis 
                           AND    r2010.RNK = 1 )                                           AS "Razão Social Cliente."              
                    ,(    SELECT (r2010."Número da Nota Fiscal")
                            FROM msafi.fin4816_reinf_2010_gtt     r2010
                           WHERE 1=1 
                           AND    r2010.cod_empresa                 = rpf.cod_empresa
                           AND    r2010.cod_estab                   = rpf.cod_estab
                           AND    r2010.dat_emissao                 = rpf.data_emissao
                           AND    r2010.data_fiscal                 = rpf.data_fiscal
                           AND    r2010.num_docfis                  = rpf.num_docfis 
                           AND    r2010.RNK = 1 )                                          AS "Número da Nota Fiscal."
                   ,(    SELECT (r2010."Data de Emissão da NF")
                            FROM msafi.fin4816_reinf_2010_gtt     r2010
                           WHERE 1=1 
                           AND    r2010.cod_empresa                 = rpf.cod_empresa
                           AND    r2010.cod_estab                   = rpf.cod_estab
                           AND    r2010.dat_emissao                 = rpf.data_emissao
                           AND    r2010.data_fiscal                 = rpf.data_fiscal
                           AND    r2010.num_docfis                  = rpf.num_docfis 
                           AND    r2010.RNK = 1 )                                           AS "Data de Emissão da NF."
                           --
                     ,(  SELECT (r2010."Data Fiscal")
                            FROM msafi.fin4816_reinf_2010_gtt     r2010
                           WHERE 1=1 
                           AND    r2010.cod_empresa                 = rpf.cod_empresa
                           AND    r2010.cod_estab                   = rpf.cod_estab
                           AND    r2010.dat_emissao                 = rpf.data_emissao
                           AND    r2010.data_fiscal                 = rpf.data_fiscal
                           AND    r2010.num_docfis                  = rpf.num_docfis 
                           AND    r2010.RNK = 1 )                                           AS "Data Fiscal."
                           --
                     ,(  SELECT (r2010."Valor do Tributo")
                            FROM msafi.fin4816_reinf_2010_gtt     r2010
                           WHERE 1=1 
                           AND    r2010.cod_empresa                 = rpf.cod_empresa
                           AND    r2010.cod_estab                   = rpf.cod_estab
                           AND    r2010.dat_emissao                 = rpf.data_emissao
                           AND    r2010.data_fiscal                 = rpf.data_fiscal
                           AND    r2010.num_docfis                  = rpf.num_docfis 
                           AND    r2010.RNK = 1 )                                           AS "Valor do Tributo."
                      ,(  SELECT INITCAP(r2010."observacao")
                            FROM msafi.fin4816_reinf_2010_gtt     r2010
                           WHERE 1=1 
                           AND    r2010.cod_empresa                 = rpf.cod_empresa
                           AND    r2010.cod_estab                   = rpf.cod_estab
                           AND    r2010.dat_emissao                 = rpf.data_emissao
                           AND    r2010.data_fiscal                 = rpf.data_fiscal
                           AND    r2010.num_docfis                  = rpf.num_docfis 
                           AND    r2010.RNK = 1 )                                           AS "Observação."
                     ,(  SELECT INITCAP(r2010."Tipo de Serviço E-social")
                            FROM msafi.fin4816_reinf_2010_gtt     r2010
                           WHERE 1=1 
                           AND    r2010.cod_empresa                 = rpf.cod_empresa
                           AND    r2010.cod_estab                   = rpf.cod_estab
                           AND    r2010.dat_emissao                 = rpf.data_emissao
                           AND    r2010.data_fiscal                 = rpf.data_fiscal
                           AND    r2010.num_docfis                  = rpf.num_docfis 
                           AND    r2010.RNK = 1 )                                           AS "Tipo de Serviço E-social."
                     ,(  SELECT (r2010."Vlr. Base de Calc. Retenção")
                            FROM msafi.fin4816_reinf_2010_gtt     r2010
                           WHERE 1=1 
                           AND    r2010.cod_empresa                 = rpf.cod_empresa
                           AND    r2010.cod_estab                   = rpf.cod_estab
                           AND    r2010.dat_emissao                 = rpf.data_emissao
                           AND    r2010.data_fiscal                 = rpf.data_fiscal
                           AND    r2010.num_docfis                  = rpf.num_docfis 
                           AND    r2010.RNK = 1 )                                           AS "Vlr. Base de Calc. Retenção."
                      ,(  SELECT (r2010."Valor da Retenção")
                            FROM msafi.fin4816_reinf_2010_gtt     r2010
                           WHERE 1=1 
                           AND    r2010.cod_empresa                 = rpf.cod_empresa
                           AND    r2010.cod_estab                   = rpf.cod_estab
                           AND    r2010.dat_emissao                 = rpf.data_emissao
                           AND    r2010.data_fiscal                 = rpf.data_fiscal
                           AND    r2010.num_docfis                  = rpf.num_docfis 
                           AND    r2010.RNK = 1 )                                           AS "Valor da Retenção."                           
            FROM msafi.fin4816_report_fiscal_gtt  rpf  
              ORDER BY 
            cod_empresa, cod_estab, data_fiscal, movto_e_s,  num_docfis, serie_docfis, sub_serie_docfis, num_item ;
                  
            
            
            
            SELECT DISTINCT r2010.num_docfis , rpf.num_docfis
             FROM msafi.fin4816_report_fiscal_gtt  rpf  , 
                  msafi.fin4816_reinf_2010_gtt     r2010
             WHERE 1=1 
              AND    r2010.cod_empresa          = rpf.cod_empresa
              AND    r2010.cod_estab            = rpf.cod_estab
              AND    r2010.dat_emissao          = rpf.data_emissao
              
              
              
              
              
              
             
                        -- report fiscal vs REINF R-2010
                 
                 SELECT r2010.cod_empresa , r2010.cod_estab, r2010.dat_emissao ,  r2010.num_docfis
                 FROM   msafi.fin4816_reinf_2010_gtt     r2010
                  INTERSECT 
                  SELECT  rpf.cod_empresa , rpf.cod_estab ,rpf.data_emissao ,  rpf.num_docfis
                 FROM  msafi.fin4816_report_fiscal_gtt  rpf 
                 
                  
                 
                     --  REPORT FISCAL VS PREVISÃO INSS  RETIDO
                   select "Codigo Empresa"  ,"Codigo Estabelecimento" , "Data Emissão"  , "Número da Nota Fiscal" 
                    from msafi.dpsp_tb_fin4816_reinf_prev_gtt
                   intersect
                  SELECT  rpf.cod_empresa , rpf.cod_estab ,rpf.data_emissao ,  rpf.num_docfis
                   FROM  msafi.fin4816_report_fiscal_gtt  rpf
                 
                 
                
                    -- PREVISÃO INSS  VS REINF EVENT R2010
                   SELECT r2010.cod_empresa , r2010.cod_estab ,r2010.dat_emissao ,  r2010.num_docfis
                 FROM   msafi.fin4816_reinf_2010_gtt     r2010
                  INTERSECT     
                  select "Codigo Empresa"  ,"Codigo Estabelecimento" , "Data Emissão"  , "Número da Nota Fiscal" 
                    from msafi.dpsp_tb_fin4816_reinf_prev_gtt