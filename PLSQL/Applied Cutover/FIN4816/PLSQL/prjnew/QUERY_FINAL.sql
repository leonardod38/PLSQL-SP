                 

                     SELECT   DISTINCT 
                         a."Codigo da Empresa"
                       , a."Codigo do Estabelecimento"
                       , a."Periodo de Emissão"
                       , a."CNPJ Drogaria"
                       , a."Numero da Nota Fiscal"
                       , a."Tipo de Documento"
                       , a."Data Emissão"
                       , a."CNPJ Fonecedor"
                       , a.uf
                       , a."Valor Total da Nota"
                       , a."Base de Calculo INSS"
                       , a."Valor do INSS"
                       , a."Codigo Pessoa Fisica/juridica"
                       , a."Razão Social"
                       , a."Municipio Prestador"
                       , a."Codigo de Serviço"
                       , a."Codigo CEI"
                       , a.id_rtf
                       , c.empresa
                       , c."Codigo Estabelecimento"
                       , c.cod_pessoa_fis_jur
                       , c."Razão Social Cliente"
                       , c."CNPJ Cliente"
                       , c."Nro. Nota Fiscal"
                       , c."Dt. Emissao"
                       , c."Dt. Fiscal"
                       , c."Vlr. Total da Nota"
                       , c."Vlr Base Calc. Retenção"
                       , c."Vlr. Aliquota INSS"
                       , c."Vlr.Trib INSS RETIDO"
                       , c."Razão Social Drogaria"
                       , c."CNPJ Drogarias"
                       , c."Descr. Tp. Documento"
                       , c."Tp.Serv. E-social"
                       , c."Descr. Tp. Serv E-social"
                       , c."Vlr. do Servico"
                       , c."Cod. Serv. Mastersaf"
                       , c."Descr. Serv. Mastersaf"
                       , c.id_inss_retido    
                       , d."Codigo Empresa"
                       , d."Razão Social Drogaria."
                       , d."Razão Social Cliente."
                       , d."Número da Nota Fiscal."
                       , d."Data de Emissão da NF."
                       , d."Data Fiscal."
                       , d."Valor do Tributo."
                       , d."Observação."
                       , d."Tipo de Serviço E-social."
                       , d."Vlr. Base de Calc. Retenção."
                       , d."Valor da Retenção."
                       , d.id_reinf_e2010      
                       , B.id_geral
                    FROM msafi.tb_fin4816_rel_apoio_fiscalv5  a 
                    ,    msafi.tb_fin4816_rel_apoio_fiscalv5  B 
                    ,    msafi.tb_fin4816_rel_apoio_fiscalv5  c 
                    ,    msafi.tb_fin4816_rel_apoio_fiscalv5  d
                    ,    msafi.tb_fin4816_prev_tmp_estab	  e
                    WHERE 1=1 
                    AND   a."Data Emissão"     BETWEEN    '01/12/2018'  and '31/12/2018'
                    AND   a."Codigo da Empresa"         = 'DSP'
                    AND   e.proc_id                     = 299313
                    AND   e.cod_estab                   = a."Codigo do Estabelecimento"
                    AND   b.id_geral                    = a.id_rtf (+)  
                    AND   b.id_geral                    = c.id_inss_retido(+)
                    AND   b.id_geral                    = d.id_reinf_e2010(+)
                    ORDER BY b.id_geral
                    


--   )
--                    WHERE   id_rtf  IS NOT NULL 
--                    AND     id_inss_retido IS NOT NULL 
--                    AND     id_reinf_e2010 IS NOT NULL ;
                    
               