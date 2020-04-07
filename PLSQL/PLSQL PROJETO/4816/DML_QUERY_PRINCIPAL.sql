SELECT rtf.cod_empresa                                  AS "Codigo da Empresa"
     , rtf.cod_estab                                    AS "Codigo do Estabelecimento"
     , TO_CHAR ( rtf.data_emissao, 'MM/YYYY' )          AS "Periodo de Emissão"
     , rtf.cgc                                          AS "CNPJ Drogaria "
     , rtf.num_docfis                                   AS "Numero da Nota Fiscal"
     , rtf.tipo_docto                                   AS "Tipo de Documento"
     , rtf.data_emissao                                 AS "Data Emissão"
     , rtf.data_fiscal                                  AS "Data Fiscal"
     , Rtf.cgc_fornecedor                               AS "CNPJ Fonecedor"
     , rtf.uf                                           AS "UF"
     , rtf.valor_total                                  AS "Valor Total da Nota"
     , rtf.vlr_base_inss                                AS "Base de Calculo INSS"
     , rtf.vlr_inss                                     AS "Valor do INSS"
     , rtf.codigo_fisjur                                AS "Codigo Pessoa Fisica/juridica"
     , INITCAP(rtf.razao_social)                        AS "Razão Social"
     , INITCAP(rtf.municipio_prestador)                 AS "Municipio Prestador"
     , rtf.cod_servico                                  AS "Codigo de Serviço"
     , rtf.cod_cei	                                    AS "Codigo CEI"
     , DECODE ( ( SELECT LENGTH ( rpv.num_item )
                    FROM msafi.fin4816_reinf_prev_gtt rpv
                   WHERE rpv.cod_empresa        = rtf.cod_empresa
                     AND rpv.cod_estab          = rtf.cod_estab
                     AND rpv.data_fiscal        = rtf.data_fiscal                    
                     AND rpv.ident_docto        = rtf.ident_docto
                     AND rpv.ident_fis_jur      = rtf.ident_fis_jur
                     AND rpv.num_docfis         = rtf.num_docfis
                     AND rpv.num_item           = rtf.num_item         ), 1, 'S', 'N' )           AS "Equalização|S-N"
     ,(         SELECT    rpv.cod_empresa  
                    FROM msafi.fin4816_reinf_prev_gtt rpv
                   WHERE rpv.cod_empresa        = rtf.cod_empresa
                     AND rpv.cod_estab          = rtf.cod_estab
                     AND rpv.data_fiscal        = rtf.data_fiscal                    
                     AND rpv.ident_docto        = rtf.ident_docto
                     AND rpv.ident_fis_jur      = rtf.ident_fis_jur
                     AND rpv.num_docfis         = rtf.num_docfis
                     AND rpv.num_item           = rtf.num_item          ) AS  "Codigo da Empresa 1 "  
      ,(         SELECT    rpv.cod_estab  
                    FROM msafi.fin4816_reinf_prev_gtt rpv
                   WHERE rpv.cod_empresa        = rtf.cod_empresa
                     AND rpv.cod_estab          = rtf.cod_estab
                     AND rpv.data_fiscal        = rtf.data_fiscal                    
                     AND rpv.ident_docto        = rtf.ident_docto
                     AND rpv.ident_fis_jur      = rtf.ident_fis_jur
                     AND rpv.num_docfis         = rtf.num_docfis
                     AND rpv.num_item           = rtf.num_item          ) AS  "Codigo do Estabelecimento 1"
      ,(         SELECT    rpv.cod_fis_jur
                    FROM msafi.fin4816_reinf_prev_gtt rpv
                   WHERE rpv.cod_empresa        = rtf.cod_empresa
                     AND rpv.cod_estab          = rtf.cod_estab
                     AND rpv.data_fiscal        = rtf.data_fiscal                    
                     AND rpv.ident_docto        = rtf.ident_docto
                     AND rpv.ident_fis_jur      = rtf.ident_fis_jur
                     AND rpv.num_docfis         = rtf.num_docfis
                     AND rpv.num_item           = rtf.num_item          ) AS  "Cod. Pessoa Fisica/Juridica 1"
       ,(         SELECT    initcap(rpv.razao_social)
                    FROM msafi.fin4816_reinf_prev_gtt rpv
                   WHERE rpv.cod_empresa        = rtf.cod_empresa
                     AND rpv.cod_estab          = rtf.cod_estab
                     AND rpv.data_fiscal        = rtf.data_fiscal                    
                     AND rpv.ident_docto        = rtf.ident_docto
                     AND rpv.ident_fis_jur      = rtf.ident_fis_jur
                     AND rpv.num_docfis         = rtf.num_docfis
                     AND rpv.num_item           = rtf.num_item          ) AS  "Razão Social 1"
         ,(    SELECT    initcap(rpv.cpf_cgc)
                    FROM msafi.fin4816_reinf_prev_gtt rpv
                   WHERE rpv.cod_empresa        = rtf.cod_empresa
                     AND rpv.cod_estab          = rtf.cod_estab
                     AND rpv.data_fiscal        = rtf.data_fiscal                    
                     AND rpv.ident_docto        = rtf.ident_docto
                     AND rpv.ident_fis_jur      = rtf.ident_fis_jur
                     AND rpv.num_docfis         = rtf.num_docfis
                     AND rpv.num_item           = rtf.num_item          ) AS  "CNPJ_Cliente 1"
        ,(    SELECT    rpv.num_docfis  num_docfis
                    FROM msafi.fin4816_reinf_prev_gtt rpv
                   WHERE rpv.cod_empresa        = rtf.cod_empresa
                     AND rpv.cod_estab          = rtf.cod_estab
                     AND rpv.data_fiscal        = rtf.data_fiscal                    
                     AND rpv.ident_docto        = rtf.ident_docto
                     AND rpv.ident_fis_jur      = rtf.ident_fis_jur
                     AND rpv.num_docfis         = rtf.num_docfis
                     AND rpv.num_item           = rtf.num_item          ) AS  "Número da Nota Fiscal 1"
             ,(   SELECT rpv.data_emissao  
                    FROM msafi.fin4816_reinf_prev_gtt rpv
                   WHERE rpv.cod_empresa        = rtf.cod_empresa
                     AND rpv.cod_estab          = rtf.cod_estab
                     AND rpv.data_fiscal        = rtf.data_fiscal                    
                     AND rpv.ident_docto        = rtf.ident_docto
                     AND rpv.ident_fis_jur      = rtf.ident_fis_jur
                     AND rpv.num_docfis         = rtf.num_docfis
                     AND rpv.num_item           = rtf.num_item          ) AS  "Data Emissão 1"
                     --
            ,(   SELECT rpv.data_fiscal  
                    FROM msafi.fin4816_reinf_prev_gtt rpv
                   WHERE rpv.cod_empresa        = rtf.cod_empresa
                     AND rpv.cod_estab          = rtf.cod_estab
                     AND rpv.data_fiscal        = rtf.data_fiscal                    
                     AND rpv.ident_docto        = rtf.ident_docto
                     AND rpv.ident_fis_jur      = rtf.ident_fis_jur
                     AND rpv.num_docfis         = rtf.num_docfis
                     AND rpv.num_item           = rtf.num_item          ) AS  "Data Fiscal 1"
             ,(   SELECT rpv.vlr_tot_nota  
                    FROM msafi.fin4816_reinf_prev_gtt rpv
                   WHERE rpv.cod_empresa        = rtf.cod_empresa
                     AND rpv.cod_estab          = rtf.cod_estab
                     AND rpv.data_fiscal        = rtf.data_fiscal                    
                     AND rpv.ident_docto        = rtf.ident_docto
                     AND rpv.ident_fis_jur      = rtf.ident_fis_jur
                     AND rpv.num_docfis         = rtf.num_docfis
                     AND rpv.num_item           = rtf.num_item          ) AS  "Valor Total da Nota 1"
           ,(   SELECT rpv.vlr_base_inss  
                    FROM msafi.fin4816_reinf_prev_gtt rpv
                   WHERE rpv.cod_empresa        = rtf.cod_empresa
                     AND rpv.cod_estab          = rtf.cod_estab
                     AND rpv.data_fiscal        = rtf.data_fiscal                    
                     AND rpv.ident_docto        = rtf.ident_docto
                     AND rpv.ident_fis_jur      = rtf.ident_fis_jur
                     AND rpv.num_docfis         = rtf.num_docfis
                     AND rpv.num_item           = rtf.num_item          ) AS  "Valor Base de Calculo INSS 1"
          ,(   SELECT rpv.vlr_base_inss  
                    FROM msafi.fin4816_reinf_prev_gtt rpv
                   WHERE rpv.cod_empresa        = rtf.cod_empresa
                     AND rpv.cod_estab          = rtf.cod_estab
                     AND rpv.data_fiscal        = rtf.data_fiscal                    
                     AND rpv.ident_docto        = rtf.ident_docto
                     AND rpv.ident_fis_jur      = rtf.ident_fis_jur
                     AND rpv.num_docfis         = rtf.num_docfis
                     AND rpv.num_item           = rtf.num_item          ) AS  "Valor Base de Calculo INSS 1"
  FROM msafi.fin4816_report_fiscal_gtt rtf
 ORDER BY  
  rtf.cod_empresa
 ,rtf.cod_estab
 ,rtf.data_emissao  
 ,rtf.ident_docto
 ,rtf.ident_fis_jur
 ,rtf.num_docfis 
