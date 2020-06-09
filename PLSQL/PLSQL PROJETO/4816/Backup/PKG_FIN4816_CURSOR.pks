CREATE OR REPLACE PACKAGE MSAF.pkg_fin4816_cursor
IS
    CURSOR cr_rtf ( pcod_empresa VARCHAR2
                  , pdata_ini DATE
                  , pdata_fim DATE
                  , pproc_id NUMBER )
    IS
        SELECT   x09_itens_serv.cod_empresa AS cod_empresa -- Codigo da Empresa
               , x09_itens_serv.cod_estab AS cod_estab -- Codigo do Estabelecimento
               , x09_itens_serv.data_fiscal AS data_fiscal -- Data Fiscal
               , x09_itens_serv.movto_e_s AS movto_e_s
               , x09_itens_serv.norm_dev AS norm_dev
               , x09_itens_serv.ident_docto AS ident_docto
               , x09_itens_serv.ident_fis_jur AS ident_fis_jur
               , x09_itens_serv.num_docfis AS num_docfis
               , x09_itens_serv.serie_docfis AS serie_docfis
               , x09_itens_serv.sub_serie_docfis AS sub_serie_docfis
               , x09_itens_serv.ident_servico AS ident_servico
               , x09_itens_serv.num_item AS num_item
               , x07_docto_fiscal.data_emissao AS perido_emissao -- Periodo de Emissão
               , estabelecimento.cgc AS cgc -- CNPJ Drogaria
               , x07_docto_fiscal.num_docfis AS num_docto -- Numero da Nota Fiscal
               , x07_docto_fiscal.dsc_reservado1
               , x2005_tipo_docto.cod_docto AS tipo_docto -- Tipo de Documento
               , x07_docto_fiscal.data_emissao AS data_emissao -- Data Emissão
               , x04_pessoa_fis_jur.cpf_cgc AS cgc_fornecedor -- CNPJ_Fonecedor
               , estado.cod_estado AS uf -- uf
               , x09_itens_serv.vlr_tot AS valor_total -- Valor Total da Nota
               , x09_itens_serv.vlr_base_inss AS base_inss -- Base de Calculo INSS
               , x09_itens_serv.vlr_inss_retido AS valor_inss -- Valor do INSS
               , x04_pessoa_fis_jur.cod_fis_jur AS cod_fis_jur -- Codigo Pessoa Fisica/juridica
               , x04_pessoa_fis_jur.razao_social AS razao_social -- Razão Social
               , municipio.descricao AS municipio_prestador -- Municipio Prestador
               , x2018_servicos.cod_servico AS cod_servico -- Codigo de Serviço
               , x07_docto_fiscal.cod_cei AS cod_cei -- Codigo CEI
               , NULL AS equalizacao -- Equalização
            FROM x07_docto_fiscal
               , x2005_tipo_docto
               , x04_pessoa_fis_jur
               , x09_itens_serv
               , estabelecimento
               , estado
               , x2018_servicos
               , municipio
               , msafi.tb_fin4816_prev_tmp_estab estab
           WHERE 1 = 1
             AND x09_itens_serv.cod_empresa = estabelecimento.cod_empresa
             AND x09_itens_serv.cod_estab = estabelecimento.cod_estab
             AND x09_itens_serv.cod_estab = estab.cod_estab
             AND estab.proc_id = pproc_id
             AND x09_itens_serv.cod_empresa = x07_docto_fiscal.cod_empresa
             AND x09_itens_serv.cod_estab = x07_docto_fiscal.cod_estab
             AND x09_itens_serv.data_fiscal = x07_docto_fiscal.data_fiscal
             AND x07_docto_fiscal.data_emissao BETWEEN pdata_ini AND pdata_fim
             AND x09_itens_serv.vlr_inss_retido > 0
             AND x09_itens_serv.movto_e_s = x07_docto_fiscal.movto_e_s
             AND x09_itens_serv.norm_dev = x07_docto_fiscal.norm_dev
             AND x09_itens_serv.ident_docto = x07_docto_fiscal.ident_docto
             AND x09_itens_serv.ident_fis_jur = x07_docto_fiscal.ident_fis_jur
             AND x09_itens_serv.num_docfis = x07_docto_fiscal.num_docfis
             AND x09_itens_serv.serie_docfis = x07_docto_fiscal.serie_docfis
             AND x09_itens_serv.sub_serie_docfis = x07_docto_fiscal.sub_serie_docfis
             -- estado /municio
             AND estado.ident_estado = x04_pessoa_fis_jur.ident_estado
             AND municipio.ident_estado = estado.ident_estado
             AND municipio.cod_municipio = x04_pessoa_fis_jur.cod_municipio
             --  X2018_SERVICOS
             AND x2018_servicos.ident_servico = x09_itens_serv.ident_servico
             AND ( x2005_tipo_docto.ident_docto = x07_docto_fiscal.ident_docto )
             AND ( x04_pessoa_fis_jur.ident_fis_jur = x07_docto_fiscal.ident_fis_jur )
             AND ( x07_docto_fiscal.movto_e_s IN ( 1
                                                 , 2
                                                 , 3
                                                 , 4
                                                 , 5 ) )
             AND ( ( x07_docto_fiscal.situacao <> 'S' )
               OR ( x07_docto_fiscal.situacao IS NULL ) )
             AND ( x07_docto_fiscal.cod_estab = estab.cod_estab )
             AND ( x07_docto_fiscal.cod_empresa = pcod_empresa )
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
                                 AND pcum.cod_param = 415 --
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
        ORDER BY x09_itens_serv.cod_empresa
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
               , x09_itens_serv.num_item;



    CURSOR cr_inss_retido ( pempresa VARCHAR2
                          , pdata_ini DATE
                          , pdata_fim DATE
                          , pproc_id NUMBER )
    IS
        SELECT   'S' AS tipo
               , doc_fis.cod_empresa AS "Codigo Empresa"
               , doc_fis.cod_estab AS "Codigo Estabelecimento"
               , x04.cod_fis_jur AS cod_pessoa_fis_jur
               , INITCAP ( x04.razao_social ) AS "Razão Social Cliente"
               , x04.cpf_cgc AS "CNPJ Cliente"
               , doc_fis.num_docfis AS "Número da Nota Fiscal"
               , doc_fis.data_emissao AS "Data Emissão"
               , doc_fis.data_fiscal AS "Data Fiscal"
               , doc_fis.vlr_tot_nota AS vlr_tot_nota
               , doc_fis.vlr_base_inss AS "Vlr Base Calc. Retenção"
               , doc_fis.vlr_aliq_inss AS vlr_aliq_inss
               , doc_fis.vlr_inss_retido AS "Vlr.Trib INSS RETIDO"
               , INITCAP ( empresa.razao_social ) AS "Razão Social Drogaria"
               , estabelecimento.cgc AS cgc
               , x2005.cod_docto AS cod_docto
               , tipo_serv.cod_tipo_serv_esocial AS "Tipo de Serviço E-social"
               , tipo_serv.dsc_tipo_serv_esocial AS dsc_tipo_serv_esocial
               , dwt_itens.vlr_servico AS "Valor do Servico"
               , x2018.cod_servico AS codigo_serv_prod
               , INITCAP ( x2018.descricao ) AS desc_serv_prod
            FROM dwt_docto_fiscal doc_fis
               , dwt_itens_serv dwt_itens
               , x2018_servicos x2018
               , prt_id_tipo_serv_esocial id_tipo_serv
               , prt_tipo_serv_esocial tipo_serv
               , x2058_proc_adj x2058
               , x2058_proc_adj x2058_adic
               , x04_pessoa_fis_jur x04
               , estabelecimento
               , x2005_tipo_docto x2005
               , empresa
               , msafi.tb_fin4816_prev_tmp_estab estab
           WHERE 1 = 1
             AND estab.cod_estab = dwt_itens.cod_estab
             AND estab.proc_id = pproc_id
             AND doc_fis.cod_empresa = dwt_itens.cod_empresa
             AND doc_fis.cod_estab = dwt_itens.cod_estab
             AND doc_fis.data_fiscal = dwt_itens.data_fiscal
             AND doc_fis.ident_fis_jur = dwt_itens.ident_fis_jur
             AND x04.ident_fis_jur = dwt_itens.ident_fis_jur
             AND doc_fis.ident_docto = dwt_itens.ident_docto
             AND doc_fis.num_docfis = dwt_itens.num_docfis
             AND doc_fis.serie_docfis = dwt_itens.serie_docfis
             AND doc_fis.sub_serie_docfis = dwt_itens.sub_serie_docfis
             AND dwt_itens.ident_proc_adj_princ = x2058.ident_proc_adj(+)
             AND dwt_itens.ident_proc_adj_adic = x2058_adic.ident_proc_adj(+)
             AND id_tipo_serv.cod_empresa = doc_fis.cod_empresa
          -- AND id_tipo_serv.cod_estab = doc_fis.cod_estab
             AND dwt_itens.ident_servico = x2018.ident_servico
             AND x2018.grupo_servico = id_tipo_serv.grupo_servico
             AND x2018.cod_servico = id_tipo_serv.cod_servico
             AND id_tipo_serv.cod_tipo_serv_esocial = tipo_serv.cod_tipo_serv_esocial
             AND dwt_itens.cod_empresa = estabelecimento.cod_empresa
             AND dwt_itens.cod_estab = estabelecimento.cod_estab
             AND dwt_itens.ident_docto = x2005.ident_docto
             AND empresa.cod_empresa = dwt_itens.cod_empresa
             AND tipo_serv.data_ini_vigencia = (SELECT MAX ( a.data_ini_vigencia )
                                                  FROM prt_tipo_serv_esocial a
                                                 WHERE a.cod_tipo_serv_esocial = tipo_serv.cod_tipo_serv_esocial
                                                   AND a.data_ini_vigencia <= '31/12/2018')
             AND doc_fis.dat_cancelamento IS NULL
             AND doc_fis.cod_class_doc_fis IN ( '2'
                                              , '3' )
             AND doc_fis.norm_dev = '1'
             AND ( ( doc_fis.movto_e_s < '9' )
               OR ( doc_fis.movto_e_s = '9' ) )
             AND NVL ( dwt_itens.vlr_inss_retido, 0 ) > 0
             AND doc_fis.situacao = 'N'
             AND doc_fis.cod_empresa = pempresa
             AND doc_fis.cod_estab = estab.cod_estab
             AND doc_fis.data_emissao >= pdata_ini
             AND doc_fis.data_emissao <= pdata_fim
             AND LENGTH ( TRIM ( x04.cpf_cgc ) ) > 11
        ORDER BY doc_fis.cod_empresa
               , doc_fis.cod_estab
               , doc_fis.data_fiscal
               , doc_fis.num_docfis;



    CURSOR rc_reinf_evento_e2010 ( pcod_empresa VARCHAR2
                                 , pdata_ini DATE
                                 , pdata_fim DATE
                                 , pproc_id NUMBER )
    IS
        SELECT cod_empresa
             , cod_estab
             , dat_emissao
             , iden_fis_jur
             , num_docfis
             , "Codigo Empresa"
             , "Razão Social Drogaria"
             , "Razão Social Cliente"
             , "Número da Nota Fiscal"
             , "Data de Emissão da NF"
             , "Data Fiscal"
             , "Valor do Tributo"
             , "observacao"
             , "Tipo de Serviço E-social"
             , "Vlr. Base de Calc. Retenção"
             , "Valor da Retenção"
             , proc_id
             , ind_status
             , cnpj_prestador
             , ind_obra
             , tp_inscricao
             , nr_inscricao
             , num_recibo
             , ind_tp_amb
             , vlr_bruto
             , vlr_base_ret
             , vlr_ret_princ
             , vlr_ret_adic
             , vlr_n_ret_princ
             , vlr_n_ret_adic
             , ind_cprb
             , cod_versao_proc
             , cod_versao_layout
             , ind_proc_emissao
             , id_evento
             , ind_oper
             , dat_ocorrencia
             , cgc
             , razao_social
             , x04_razao_social
             , id_r2010_oc
             , num_docto
             , serie
             , dat_emissao_nf
             , data_fiscal
             , rnf_vlr_bruto
             , observacao
             , id_r2010_nf
             , ind_tp_proc_adj_adic
             , num_proc_adj_adic
             , cod_susp_adic
             , radic_vlr_n_ret_adic
             , ind_tp_proc_adj_princ
             , num_proc_adj_princ
             , cod_susp_princ
             , rprinc_vlr_n_ret_princ
             , tp_servico
             , rserv_vlr_base_ret
             , vlr_retencao
             , vlr_ret_sub
             , rserv_vlr_n_ret_princ
             , vlr_servicos_15
             , vlr_servicos_20
             , vlr_servicos_25
             , rserv_vlr_ret_adic
             , rserv_vlr_n_ret_adic
             , rnk
          FROM (SELECT reinf_pger_apur.dat_apur
                     , reinf_pger_apur.cod_empresa AS cod_empresa
                     , reinf_pger_apur.cod_estab AS cod_estab
                     , rnf.dat_emissao_nf AS dat_emissao
                     , x04_pessoa_fis_jur.ident_fis_jur AS iden_fis_jur
                     , rnf.num_docto AS num_docfis
                     , empresa.cod_empresa AS "Codigo Empresa"
                     , estabelecimento.razao_social AS "Razão Social Drogaria"
                     , ( x04_pessoa_fis_jur.razao_social ) AS "Razão Social Cliente"
                     , rnf.num_docto AS "Número da Nota Fiscal"
                     , rnf.dat_emissao_nf AS "Data de Emissão da NF"
                     , rnf.data_saida_rec_nf AS "Data Fiscal"
                     , rserv.vlr_retencao AS "Valor do Tributo"
                     , rnf.observacao AS "observacao"
                     , rserv.tp_servico AS "Tipo de Serviço E-social"
                     , rserv.vlr_base_ret AS "Vlr. Base de Calc. Retenção"
                     , rserv.vlr_retencao AS "Valor da Retenção"
                     , reinf_pger_r2010_oc.proc_id AS proc_id
                     , reinf_pger_r2010_oc.ind_status AS ind_status
                     , reinf_pger_r2010_prest.cnpj_prestador AS cnpj_prestador
                     , reinf_pger_r2010_oc.ind_obra AS ind_obra
                     , reinf_pger_r2010_tom.tp_inscricao AS tp_inscricao
                     , reinf_pger_r2010_tom.nr_inscricao AS nr_inscricao
                     , reinf_pger_r2010_oc.num_recibo AS num_recibo
                     , reinf_pger_r2010_oc.ind_tp_amb AS ind_tp_amb
                     , reinf_pger_r2010_oc.vlr_bruto AS vlr_bruto
                     , reinf_pger_r2010_oc.vlr_base_ret AS vlr_base_ret
                     , reinf_pger_r2010_oc.vlr_ret_princ AS vlr_ret_princ
                     , reinf_pger_r2010_oc.vlr_ret_adic AS vlr_ret_adic
                     , reinf_pger_r2010_oc.vlr_n_ret_princ AS vlr_n_ret_princ
                     , reinf_pger_r2010_oc.vlr_n_ret_adic AS vlr_n_ret_adic
                     , reinf_pger_r2010_oc.ind_cprb AS ind_cprb
                     , reinf_pger_r2010_oc.cod_versao_proc AS cod_versao_proc
                     , reinf_pger_r2010_oc.cod_versao_layout AS cod_versao_layout
                     , reinf_pger_r2010_oc.ind_proc_emissao AS ind_proc_emissao
                     , reinf_pger_r2010_oc.id_evento AS id_evento
                     , reinf_pger_r2010_oc.ind_oper AS ind_oper
                     , reinf_pger_r2010_oc.dat_ocorrencia AS dat_ocorrencia
                     , estabelecimento.cgc AS cgc
                     , empresa.razao_social AS razao_social
                     , ( x04_pessoa_fis_jur.razao_social ) AS x04_razao_social
                     , reinf_pger_r2010_oc.id_r2010_oc AS id_r2010_oc
                     , ( rnf.num_docto ) AS num_docto
                     , ( rnf.serie ) AS serie
                     , ( rnf.dat_emissao_nf ) AS dat_emissao_nf
                     , ( rnf.data_saida_rec_nf ) AS data_fiscal
                     , ( rnf.vlr_bruto ) AS rnf_vlr_bruto
                     , ( rnf.observacao ) AS observacao
                     , ( rnf.id_r2010_nf ) AS id_r2010_nf
                     , ( radic.ind_tp_proc_adj_adic ) AS ind_tp_proc_adj_adic
                     , ( radic.num_proc_adj_adic ) AS num_proc_adj_adic
                     , ( radic.cod_susp_adic ) AS cod_susp_adic
                     , ( radic.vlr_n_ret_adic ) AS radic_vlr_n_ret_adic
                     , ( rprinc.ind_tp_proc_adj_princ ) AS ind_tp_proc_adj_princ
                     , ( rprinc.num_proc_adj_princ ) AS num_proc_adj_princ
                     , ( rprinc.cod_susp_princ ) AS cod_susp_princ
                     , ( rprinc.vlr_n_ret_princ ) AS rprinc_vlr_n_ret_princ
                     , ( rserv.tp_servico ) AS tp_servico
                     , ( rserv.vlr_base_ret ) AS rserv_vlr_base_ret
                     , ( rserv.vlr_retencao ) AS vlr_retencao
                     , ( rserv.vlr_ret_sub ) AS vlr_ret_sub
                     , ( rserv.vlr_n_ret_princ ) AS rserv_vlr_n_ret_princ
                     , ( rserv.vlr_servicos_15 ) AS vlr_servicos_15
                     , ( rserv.vlr_servicos_20 ) AS vlr_servicos_20
                     , ( rserv.vlr_servicos_25 ) AS vlr_servicos_25
                     , ( rserv.vlr_ret_adic ) AS rserv_vlr_ret_adic
                     , ( rserv.vlr_n_ret_adic ) AS rserv_vlr_n_ret_adic
                     , RANK ( )
                           OVER ( PARTITION BY reinf_pger_apur.cod_empresa
                                             , reinf_pger_apur.cod_estab
                                             , rnf.dat_emissao_nf
                                             , x04_pessoa_fis_jur.ident_fis_jur
                                             , rnf.num_docto
                                  ORDER BY reinf_pger_r2010_oc.dat_ocorrencia DESC )
                           rnk
                  FROM empresa
                     , estabelecimento
                     , reinf_pger_apur
                     , x04_pessoa_fis_jur
                     , reinf_pger_r2010_prest
                     , reinf_pger_r2010_tom
                     , reinf_pger_r2010_oc
                     , reinf_pger_r2010_nf rnf
                     , reinf_pger_r2010_tp_serv rserv
                     , reinf_pger_r2010_proc_adic radic
                     , reinf_pger_r2010_proc_princ rprinc
                     , (SELECT   MAX ( dat_ocorrencia ) dat_ocorrencia
                               , reinf_pger_r2010_prest.id_r2010_prest
                               , reinf_pger_r2010_tom.id_r2010_tom
                               , reinf_pger_apur.id_pger_apur
                            FROM reinf_pger_r2010_oc
                               , reinf_pger_r2010_prest
                               , reinf_pger_r2010_tom
                               , reinf_pger_apur
                           WHERE reinf_pger_apur.id_pger_apur = reinf_pger_r2010_tom.id_pger_apur
                             AND reinf_pger_r2010_tom.id_r2010_tom = reinf_pger_r2010_prest.id_r2010_tom
                             AND reinf_pger_r2010_prest.id_r2010_prest = reinf_pger_r2010_oc.id_r2010_prest
                             AND reinf_pger_apur.cod_empresa = pcod_empresa -- parametro
                             AND reinf_pger_apur.dat_apur BETWEEN pdata_ini AND pdata_fim -- parametro
                             AND reinf_pger_apur.ind_r2010 = 'S'
                             --    AND reinf_pger_apur.cod_versao >= 'v1_04_00'
                             AND reinf_pger_apur.ind_tp_amb IN ( '1'
                                                               , '2' )
                        GROUP BY reinf_pger_r2010_prest.id_r2010_prest
                               , reinf_pger_r2010_tom.id_r2010_tom
                               , reinf_pger_apur.id_pger_apur) max_oc
                     , msafi.tb_fin4816_prev_tmp_estab estab1
                 WHERE 1 = 1
                   AND reinf_pger_apur.dat_apur BETWEEN pdata_ini AND pdata_fim -- parametro
                   AND estab1.cod_estab = estabelecimento.cod_estab
                   AND estab1.proc_id = pproc_id
                   AND ( estabelecimento.cod_empresa = reinf_pger_apur.cod_empresa )
                   AND ( estabelecimento.cod_estab = reinf_pger_apur.cod_estab )
                   AND ( estabelecimento.cod_empresa = empresa.cod_empresa )
                   AND ( reinf_pger_r2010_prest.cnpj_prestador = x04_pessoa_fis_jur.cpf_cgc )
                   AND x04_pessoa_fis_jur.ident_fis_jur = (SELECT MAX ( x04.ident_fis_jur )
                                                             FROM x04_pessoa_fis_jur x04
                                                            WHERE x04.cpf_cgc = x04_pessoa_fis_jur.cpf_cgc
                                                              AND x04.valid_fis_jur <= pdata_fim) -- parametro
                   AND ( reinf_pger_r2010_tom.id_pger_apur = reinf_pger_apur.id_pger_apur )
                   AND ( reinf_pger_r2010_tom.id_r2010_tom = reinf_pger_r2010_prest.id_r2010_tom )
                   AND ( reinf_pger_r2010_prest.id_r2010_prest = reinf_pger_r2010_oc.id_r2010_prest )
                   AND ( reinf_pger_r2010_oc.id_r2010_oc = rnf.id_r2010_oc )
                   AND ( reinf_pger_r2010_oc.dat_ocorrencia = max_oc.dat_ocorrencia )
                   AND ( reinf_pger_r2010_prest.id_r2010_prest = max_oc.id_r2010_prest )
                   AND ( reinf_pger_r2010_tom.id_r2010_tom = max_oc.id_r2010_tom )
                   AND ( reinf_pger_apur.id_pger_apur = max_oc.id_pger_apur )
                   AND rnf.id_r2010_nf = rserv.id_r2010_nf(+)
                   AND reinf_pger_r2010_oc.id_r2010_oc = radic.id_r2010_oc(+)
                   AND reinf_pger_r2010_oc.id_r2010_oc = rprinc.id_r2010_oc(+)
                   AND ( reinf_pger_apur.ind_r2010 = 'S' )
                   --AND ( reinf_pger_apur.cod_versao = 'v1_04_00' )
                   AND reinf_pger_apur.ind_tp_amb IN ( '1'
                                                     , '2' ))
         WHERE rnk = 1 
         ORDER BY     "Número da Nota Fiscal"
                    , "Data de Emissão da NF"  ;



    CURSOR cr_rel_apoio_fiscal ( pcod_empresa VARCHAR2
                               , pdata_ini DATE
                               , pdata_fim DATE
                               , pproc_id NUMBER )
            IS
            SELECT 
                "Codigo da Empresa"
               , "Codigo do Estabelecimento"
               , "Periodo de Emissão"
               , "CNPJ Drogaria"
               , "Numero da Nota Fiscal"
               , "Tipo de Documento"
               , "Doc. Contábil"
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
               , ( CASE WHEN "Numero da Nota Fiscal" = "Nro. Nota Fiscal" THEN 'S' ELSE 'N' END ) dwt
               , empresa
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
               , "Codigo Empresa"
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
            FROM (SELECT *
                    FROM (SELECT a."Codigo da Empresa"
                               , a."Codigo do Estabelecimento"
                               , a."Periodo de Emissão"
                               , a."CNPJ Drogaria"
                               , a."Numero da Nota Fiscal"
                               , a."Tipo de Documento"
                               , a."Doc. Contábil"
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
                               , NULL dwt
                               , a.id_rtf
                               , a.id_geral id_geral_rtf
                            FROM msafi.tb_fin4816_rel_apoio_fiscalv5 a
                           WHERE a.id_procid = pproc_id
                             AND a."Data Emissão" BETWEEN pdata_ini AND pdata_fim
                             AND a."Codigo da Empresa" = pcod_empresa) rtf
                         FULL OUTER JOIN (SELECT c.empresa
                                               , c."Codigo Estabelecimento"
                                               , c.cod_pessoa_fis_jur
                                               , INITCAP(c."Razão Social Cliente") "Razão Social Cliente"
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
                                               , c.id_geral id_geral_retido
                                            FROM msafi.tb_fin4816_rel_apoio_fiscalv5 c
                                           WHERE c.id_procid = pproc_id
                                             AND c."Dt. Emissao" BETWEEN pdata_ini AND pdata_fim
                                             AND c.empresa = pcod_empresa) ret
                             ON ( ret.id_inss_retido = rtf.id_rtf )) result2
                 FULL OUTER JOIN (SELECT reinf."Codigo Empresa"
                                       , INITCAP(reinf."Razão Social Drogaria.")  "Razão Social Drogaria."
                                       , INITCAP(reinf."Razão Social Cliente.")   "Razão Social Cliente."
                                       , reinf."Número da Nota Fiscal."
                                       , reinf."Data de Emissão da NF."
                                       , reinf."Data Fiscal."
                                       , reinf."Valor do Tributo."
                                       , reinf."Observação."
                                       , reinf."Tipo de Serviço E-social."
                                       , reinf."Vlr. Base de Calc. Retenção."
                                       , reinf."Valor da Retenção."
                                       , reinf.id_reinf_e2010
                                       , reinf.id_geral id_geral_reinf
                                    FROM msafi.tb_fin4816_rel_apoio_fiscalv5 reinf
                                   WHERE 1 = 1
                                     AND reinf.id_procid = pproc_id
                                     AND reinf."Data de Emissão da NF." BETWEEN pdata_ini AND pdata_fim
                                     AND reinf."Codigo Empresa" = pcod_empresa) reinf
                     ON ( result2.id_rtf = reinf.id_reinf_e2010 )
        ORDER BY result2.id_geral_rtf
               , result2."Numero da Nota Fiscal"
               , result2."Nro. Nota Fiscal";
END pkg_fin4816_cursor;
/