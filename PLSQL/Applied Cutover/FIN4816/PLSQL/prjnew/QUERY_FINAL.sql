                 

                     SELECT   DISTINCT 
                         a."Codigo da Empresa"
                       , a."Codigo do Estabelecimento"
                       , a."Periodo de Emiss�o"
                       , a."CNPJ Drogaria"
                       , a."Numero da Nota Fiscal"
                       , a."Tipo de Documento"
                       , a."Data Emiss�o"
                       , a."CNPJ Fonecedor"
                       , a.uf
                       , a."Valor Total da Nota"
                       , a."Base de Calculo INSS"
                       , a."Valor do INSS"
                       , a."Codigo Pessoa Fisica/juridica"
                       , a."Raz�o Social"
                       , a."Municipio Prestador"
                       , a."Codigo de Servi�o"
                       , a."Codigo CEI"
                       , a.id_rtf
                       , c.empresa
                       , c."Codigo Estabelecimento"
                       , c.cod_pessoa_fis_jur
                       , c."Raz�o Social Cliente"
                       , c."CNPJ Cliente"
                       , c."Nro. Nota Fiscal"
                       , c."Dt. Emissao"
                       , c."Dt. Fiscal"
                       , c."Vlr. Total da Nota"
                       , c."Vlr Base Calc. Reten��o"
                       , c."Vlr. Aliquota INSS"
                       , c."Vlr.Trib INSS RETIDO"
                       , c."Raz�o Social Drogaria"
                       , c."CNPJ Drogarias"
                       , c."Descr. Tp. Documento"
                       , c."Tp.Serv. E-social"
                       , c."Descr. Tp. Serv E-social"
                       , c."Vlr. do Servico"
                       , c."Cod. Serv. Mastersaf"
                       , c."Descr. Serv. Mastersaf"
                       , c.id_inss_retido    
                       , d."Codigo Empresa"
                       , d."Raz�o Social Drogaria."
                       , d."Raz�o Social Cliente."
                       , d."N�mero da Nota Fiscal."
                       , d."Data de Emiss�o da NF."
                       , d."Data Fiscal."
                       , d."Valor do Tributo."
                       , d."Observa��o."
                       , d."Tipo de Servi�o E-social."
                       , d."Vlr. Base de Calc. Reten��o."
                       , d."Valor da Reten��o."
                       , d.id_reinf_e2010      
                       , B.id_geral
                    FROM msafi.tb_fin4816_rel_apoio_fiscalv5  a 
                    ,    msafi.tb_fin4816_rel_apoio_fiscalv5  B 
                    ,    msafi.tb_fin4816_rel_apoio_fiscalv5  c 
                    ,    msafi.tb_fin4816_rel_apoio_fiscalv5  d
                    ,    msafi.tb_fin4816_prev_tmp_estab	  e
                    WHERE 1=1 
                    AND   a."Data Emiss�o"     BETWEEN    '01/12/2018'  and '31/12/2018'
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
                    
               