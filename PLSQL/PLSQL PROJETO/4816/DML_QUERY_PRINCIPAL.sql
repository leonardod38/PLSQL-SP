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
     , DECODE ( ( SELECT LENGTH ( rtf.num_item )
                    FROM msafi.fin4816_reinf_prev_gtt rpv
                   WHERE rpv.cod_empresa        = rtf.cod_empresa
                     AND rpv.cod_estab          = rtf.cod_estab
                     AND rpv.data_fiscal        = rtf.data_fiscal                    
                     AND rpv.ident_docto        = rtf.ident_docto
                     AND rpv.ident_fis_jur      = rtf.ident_fis_jur
                     AND rpv.num_docfis         = rtf.num_docfis
                     AND rpv.num_item           = rtf.num_item ), 1, 'S', 'N' )
           "DWT|S-N"
  FROM msafi.fin4816_report_fiscal_gtt rtf;

--SELECT   *FROM msafi.fin4816_reinf_prev_gtt;