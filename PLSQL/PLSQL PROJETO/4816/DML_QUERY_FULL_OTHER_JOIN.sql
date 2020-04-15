SELECT rpf.cod_empresa AS "Codigo da Empresa"
     , rpf.cod_estab AS "Codigo do Estabelecimento"
     , TO_CHAR ( rpf.data_emissao
               , 'MM/YYYY' )
           AS "Periodo de Emissão"
     , rpf.cgc AS "CNPJ Drogaria"
     , rpf.num_docfis AS "Numero da Nota Fiscal"
     , rpf.tipo_docto AS "Tipo de Documento"
     , rpf.data_emissao AS "Data Emissão"
     , rpf.cgc_fornecedor AS "CNPJ Fonecedor"
     , rpf.uf AS "UF"
     , rpf.valor_total AS "Valor Total da Nota"
     , rpf.vlr_base_inss AS "Base de Calculo INSS"
     , rpf.vlr_inss AS "Valor do INSS"
     , rpf.codigo_fisjur AS "Codigo Pessoa Fisica/juridica"
     , INITCAP ( rpf.razao_social ) AS "Razão Social"
     , INITCAP ( rpf.municipio_prestador ) AS "Municipio Prestador"
     , rpf.cod_servico AS "Codigo de Serviço"
     , rpf.cod_cei AS "Codigo CEI"   
     -- 
     , NULL DWT 
     , rprev."Codigo Empresa" 
     , rprev."Codigo Estabelecimento"
     , rprev."Codigo Pessoa Fisica/Juridica" 
     , rprev."Razão Social Cliente"
     , rprev."CNPJ Cliente"
     , rprev."Número da Nota Fiscal" 
     , rprev."Emissão" 
     , rprev."Data Fiscal" 
     , rprev.vlr_tot_nota                    AS  "Vlr. Total da Nota"
     , rprev."Vlr Base Calc. Retenção"
     , rprev.vlr_aliq_inss                   AS  "Vlr. Aliquota INSS"
     , rprev."Vlr.Trib INSS RETIDO"
     , rprev."Razão Social Drogaria"
     , rprev.cgc                             AS  "CNPJ Drogarias"
     , rprev.cod_docto                       AS  "Descr. Tp. Documento"
     , rprev."Tipo de Serviço E-social" 
     , rprev.dsc_tipo_serv_esocial           AS "Descr. Tp. Serv E-social" 
     , rprev."Valor do Servico" 
     , rprev.codigo_serv_prod                AS  "Cod. Serv. Mastersaf"
     , rprev.desc_serv_prod                  AS  "Descr. Serv. Mastersaf"     
  FROM msafi.fin4816_report_fiscal_gtt rpf  FULL OUTER JOIN 
       msafi.dpsp_tb_fin4816_reinf_prev_gtt  rprev ON ( 1=1
       AND    rprev."Codigo Empresa"            = rpf.cod_empresa 
       AND    rprev."Codigo Estabelecimento"    = rpf.cod_estab   
       AND    rprev."Data Fiscal"               = rpf.data_fiscal 
       AND    rprev."Número da Nota Fiscal"     = rpf.num_docfis  
       AND    rprev.num_item                    = rpf.num_item )   