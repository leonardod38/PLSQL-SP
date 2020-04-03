           
  


              INSERT INTO msafi.fin4816_prev_final_gtt
              SELECT 
                  NULL
                , cod_empresa         , cod_estab         ,TO_CHAR(data_emissao, 'MM/YYYY') data_emissao , cgc                  , num_docto         , tipo_docto
                , data_emissao        , data_fiscal       , cgc_fornecedor           , uf                   , valor_total       , vlr_base_inss
                , vlr_inss            , codigo_fisjur     , razao_social             , municipio_prestador   , cod_servico
                , null, null, null, null , null, null, null, null, null, null, null, null, null, null, 'A'--
             FROM msafi.fin4816_prev_gtt
              WHERE vlr_inss > 0 
              union ALL
--             SELECT  NULL , NULL -- 'Relatorio Previdenciario'
--             , null ,    null, null , null,    null, null , null,    null, null, null,  null, null, null,  null, null
--             , null, null, null, null , null, null, null, null, null, null, null, null, null, null, null, null 
--             FROM DUAL 
--             union all 
               SELECT 
                  NULL
                , cod_empresa         , cod_estab         ,TO_CHAR(data_emissao, 'MM/YYYY') data_emissao , cgc                  , num_docto         , tipo_docto
                , data_emissao        , data_fiscal       , cgc_fornecedor           , uf                   , valor_total       , vlr_base_inss
                , vlr_inss            , codigo_fisjur     , razao_social             , municipio_prestador   , cod_servico
                , null, null, null, null , null, null, null, null, null, null, null, null, null, null, 'B'--
             FROM msafi.fin4816_prev_gtt
              WHERE 1=1 
              and vlr_inss > 0
              and  EXISTS  
                    (  SELECT  1 
                          FROM  msafi.reinf_conf_previdenciaria_tmp reinf
                         WHERE 1=1
                         AND    reinf.cod_empresa       = msafi.fin4816_prev_gtt.cod_empresa
                         AND    reinf.cod_estab         = msafi.fin4816_prev_gtt.cod_estab
                         AND    reinf.data_fiscal       = msafi.fin4816_prev_gtt.data_fiscal
                         AND    reinf.vlr_base_inss     = msafi.fin4816_prev_gtt.vlr_base_inss 
                         AND    reinf.vlr_inss_retido   = msafi.fin4816_prev_gtt.vlr_inss  ) ;
                         
                         
                         
                         
                         
                         
                         select * from msafi.fin4816_prev_final_gtt
                           order by col32, col1, col2, col7, col16