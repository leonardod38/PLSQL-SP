SELECT *
  FROM (SELECT *
          FROM (SELECT   "Codigo da Empresa"
                       , "Codigo do Estabelecimento"
                       , "Periodo de Emiss�o"
                       , "CNPJ Drogaria"
                       , "Numero da Nota Fiscal"
                       , "Tipo de Documento"
                       , "Data Emiss�o"
                       , "CNPJ Fonecedor"
                       , uf
                       , "Valor Total da Nota"
                       , "Base de Calculo INSS"
                       , "Valor do INSS"
                       , "Codigo Pessoa Fisica/juridica"
                       , "Raz�o Social"
                       , "Municipio Prestador"
                       , "Codigo de Servi�o"
                       , "Codigo CEI"
                       , id_rtf
                    FROM msafi.tb_fin4816_rel_apoio_fiscalv5
                   WHERE id_rtf IS NOT NULL
                ORDER BY id_rtf) a
               FULL OUTER JOIN (SELECT   empresa
                                       , "Codigo Estabelecimento"
                                       , cod_pessoa_fis_jur
                                       , "Raz�o Social Cliente"
                                       , "CNPJ Cliente"
                                       , "Nro. Nota Fiscal"
                                       , "Dt. Emissao"
                                       , "Dt. Fiscal"
                                       , "Vlr. Total da Nota"
                                       , "Vlr Base Calc. Reten��o"
                                       , "Vlr. Aliquota INSS"
                                       , "Vlr.Trib INSS RETIDO"
                                       , "Raz�o Social Drogaria"
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
                               , "Raz�o Social Drogaria."
                               , "Raz�o Social Cliente."
                               , "N�mero da Nota Fiscal."
                               , "Data de Emiss�o da NF."
                               , "Data Fiscal."
                               , "Valor do Tributo."
                               , "Observa��o."
                               , "Tipo de Servi�o E-social."
                               , "Vlr. Base de Calc. Reten��o."
                               , "Valor da Reten��o."
                               , id_reinf_e2010
                            FROM msafi.tb_fin4816_rel_apoio_fiscalv5
                           WHERE id_reinf_e2010 IS NOT NULL
                        ORDER BY id_reinf_e2010) d
           ON ( c.id_rtf = d.id_reinf_e2010 )  ORDER  BY  "Numero da Nota Fiscal", "Nro. Nota Fiscal", "N�mero da Nota Fiscal."