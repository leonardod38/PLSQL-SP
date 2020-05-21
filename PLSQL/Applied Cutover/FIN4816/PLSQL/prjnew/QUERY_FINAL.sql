SELECT *
  FROM (SELECT *
          FROM (SELECT   "Codigo da Empresa"
                       , "Codigo do Estabelecimento"
                       , "Periodo de Emissão"
                       , "CNPJ Drogaria"
                       , "Numero da Nota Fiscal"
                       , "Tipo de Documento"
                       , "Data Emissão"
                       , "CNPJ Fonecedor"
                       , uf
                       , "Valor Total da Nota"
                       , "Base de Calculo INSS"
                       , "Valor do INSS"
                       , "Codigo Pessoa Fisica/juridica"
                       , "Razão Social"
                       , "Municipio Prestador"
                       , "Codigo de Serviço"
                       , "Codigo CEI"
                       , id_rtf
                    FROM msafi.tb_fin4816_rel_apoio_fiscalv5
                   WHERE id_rtf IS NOT NULL
                ORDER BY id_rtf) a
               FULL OUTER JOIN (SELECT   empresa
                                       , "Codigo Estabelecimento"
                                       , cod_pessoa_fis_jur
                                       , "Razão Social Cliente"
                                       , "CNPJ Cliente"
                                       , "Nro. Nota Fiscal"
                                       , "Dt. Emissao"
                                       , "Dt. Fiscal"
                                       , "Vlr. Total da Nota"
                                       , "Vlr Base Calc. Retenção"
                                       , "Vlr. Aliquota INSS"
                                       , "Vlr.Trib INSS RETIDO"
                                       , "Razão Social Drogaria"
                                       , "CNPJ Drogarias"
                                       , "Descr. Tp. Documento"
                                       , "Tp.Serv. E-social"
                                       , "Descr. Tp. Serv E-social"
                                       , "Vlr. do Servico"
                                       , "Cod. Serv. Mastersaf"
                                       , "Descr. Serv. Mastersaf"
                                       , id_inss_retido
                                    FROM msafi.tb_fin4816_rel_apoio_fiscalv5
                                   WHERE id_inss_retido IS NOT NULL
                                ORDER BY id_inss_retido) b
                   ON ( b.id_inss_retido = a.id_rtf )) c
       FULL OUTER JOIN (SELECT   "Codigo Empresa"
                               , "Razão Social Drogaria."
                               , "Razão Social Cliente."
                               , "Número da Nota Fiscal."
                               , "Data de Emissão da NF."
                               , "Data Fiscal."
                               , "Valor do Tributo."
                               , "Observação."
                               , "Tipo de Serviço E-social."
                               , "Vlr. Base de Calc. Retenção."
                               , "Valor da Retenção."
                               , id_reinf_e2010
                            FROM msafi.tb_fin4816_rel_apoio_fiscalv5
                           WHERE id_reinf_e2010 IS NOT NULL
                        ORDER BY id_reinf_e2010) d
           ON ( c.id_rtf = d.id_reinf_e2010 )  ORDER  BY  "Numero da Nota Fiscal", "Nro. Nota Fiscal", "Número da Nota Fiscal."