--DELETE msafi.fin4816_reinf_2010_gtt
     --INSERT INTO MSAFI.FIN4816_REINF_2010_GTT



SELECT cod_empresa
     , cod_estab
     , dat_emissao
     , iden_fis_jur
     , num_docfis
     , "Codigo Empresa"
     , "Raz�o Social Drogaria"
     , "Raz�o Social Cliente"
     , "N�mero da Nota Fiscal"
     , "Data de Emiss�o da NF"
     , "Data Fiscal"
     , "Valor do Tributo"
     , "observacao"
     , "Tipo de Servi�o E-social"
     , "Vlr. Base de Calc. Reten��o"
     , "Valor da Reten��o"
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
  --               , rnk
  --               , id_pger_apur
  FROM (SELECT --  pk
               reinf_pger_apur.cod_empresa AS cod_empresa
             , reinf_pger_apur.cod_estab AS cod_estab
             , rnf.dat_emissao_nf AS dat_emissao
             , x04_pessoa_fis_jur.ident_fis_jur AS iden_fis_jur
             , rnf.num_docto AS num_docfis
             , empresa.cod_empresa AS "Codigo Empresa"
             , estabelecimento.razao_social AS "Raz�o Social Drogaria"
             , ( x04_pessoa_fis_jur.razao_social ) AS "Raz�o Social Cliente"
             , rnf.num_docto AS "N�mero da Nota Fiscal"
             , rnf.dat_emissao_nf AS "Data de Emiss�o da NF"
             , rnf.data_saida_rec_nf AS "Data Fiscal"
             , rserv.vlr_retencao AS "Valor do Tributo"
             , rnf.observacao AS "observacao"
             , rserv.tp_servico AS "Tipo de Servi�o E-social"
             , rserv.vlr_base_ret AS "Vlr. Base de Calc. Reten��o"
             , rserv.vlr_retencao AS "Valor da Reten��o"
             , reinf_pger_r2010_oc.proc_id
             , reinf_pger_r2010_oc.ind_status
             , reinf_pger_r2010_prest.cnpj_prestador
             , reinf_pger_r2010_oc.ind_obra
             , reinf_pger_r2010_tom.tp_inscricao
             , reinf_pger_r2010_tom.nr_inscricao
             , reinf_pger_r2010_oc.num_recibo
             , reinf_pger_r2010_oc.ind_tp_amb
             , reinf_pger_r2010_oc.vlr_bruto
             , reinf_pger_r2010_oc.vlr_base_ret
             , reinf_pger_r2010_oc.vlr_ret_princ
             , reinf_pger_r2010_oc.vlr_ret_adic
             , reinf_pger_r2010_oc.vlr_n_ret_princ
             , reinf_pger_r2010_oc.vlr_n_ret_adic
             , reinf_pger_r2010_oc.ind_cprb
             , reinf_pger_r2010_oc.cod_versao_proc
             , reinf_pger_r2010_oc.cod_versao_layout
             , reinf_pger_r2010_oc.ind_proc_emissao
             , reinf_pger_r2010_oc.id_evento
             , reinf_pger_r2010_oc.ind_oper
             , reinf_pger_r2010_oc.dat_ocorrencia
             , estabelecimento.cgc
             , empresa.razao_social
             , ( x04_pessoa_fis_jur.razao_social ) x04_razao_social
             , reinf_pger_r2010_oc.id_r2010_oc
             , ( rnf.num_docto ) num_docto
             , ( rnf.serie ) serie
             , ( rnf.dat_emissao_nf ) dat_emissao_nf
             , ( rnf.data_saida_rec_nf ) data_fiscal
             , ( rnf.vlr_bruto ) rnf_vlr_bruto
             , ( rnf.observacao ) observacao
             , ( rnf.id_r2010_nf ) id_r2010_nf
             , ( radic.ind_tp_proc_adj_adic ) ind_tp_proc_adj_adic
             , ( radic.num_proc_adj_adic ) num_proc_adj_adic
             , ( radic.cod_susp_adic ) cod_susp_adic
             , ( radic.vlr_n_ret_adic ) radic_vlr_n_ret_adic
             , ( rprinc.ind_tp_proc_adj_princ ) ind_tp_proc_adj_princ
             , ( rprinc.num_proc_adj_princ ) num_proc_adj_princ
             , ( rprinc.cod_susp_princ ) cod_susp_princ
             , ( rprinc.vlr_n_ret_princ ) rprinc_vlr_n_ret_princ
             , ( rserv.tp_servico ) tp_servico
             , ( rserv.vlr_base_ret ) rserv_vlr_base_ret
             , ( rserv.vlr_retencao ) vlr_retencao
             , ( rserv.vlr_ret_sub ) vlr_ret_sub
             , ( rserv.vlr_n_ret_princ ) rserv_vlr_n_ret_princ
             , ( rserv.vlr_servicos_15 ) vlr_servicos_15
             , ( rserv.vlr_servicos_20 ) vlr_servicos_20
             , ( rserv.vlr_servicos_25 ) vlr_servicos_25
             , ( rserv.vlr_ret_adic ) rserv_vlr_ret_adic
             , ( rserv.vlr_n_ret_adic ) rserv_vlr_n_ret_adic
             , RANK ( )
                   OVER ( PARTITION BY reinf_pger_apur.cod_empresa
                                     , reinf_pger_apur.cod_estab
                                     , rnf.dat_emissao_nf
                                     , x04_pessoa_fis_jur.ident_fis_jur
                                     , rnf.num_docto
                          ORDER BY reinf_pger_r2010_oc.dat_ocorrencia DESC )
                   rnk
             , reinf_pger_apur.id_pger_apur
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
                     AND reinf_pger_apur.cod_empresa = 'DSP' -- parametro
                     AND reinf_pger_apur.dat_apur = '31/01/2018' -- parametro
                     AND reinf_pger_apur.ind_r2010 = 'S'
                     --                       AND reinf_pger_apur.cod_versao >= 'v1_04_00'
                     AND reinf_pger_apur.ind_tp_amb = '2'
                GROUP BY reinf_pger_r2010_prest.id_r2010_prest
                       , reinf_pger_r2010_tom.id_r2010_tom
                       , reinf_pger_apur.id_pger_apur) max_oc
             , msafi.fin4816_prev_tmp_estab estab1
         WHERE 1 = 1
           AND estab1.cod_estab = estabelecimento.cod_estab
           --AND  estab1.proc_id                          = 289642
           AND rnf.dat_emissao_nf = '31/01/2018'
           AND reinf_pger_apur.dat_apur = '31/01/2018'
           AND x04_pessoa_fis_jur.ident_fis_jur = 319193
           -- AND  rnf.num_docto                           = '000007397'
           AND ( estabelecimento.cod_empresa = reinf_pger_apur.cod_empresa )
           AND ( estabelecimento.cod_estab = reinf_pger_apur.cod_estab )
           AND ( estabelecimento.cod_empresa = empresa.cod_empresa )
           AND ( reinf_pger_r2010_prest.cnpj_prestador = x04_pessoa_fis_jur.cpf_cgc )
           AND x04_pessoa_fis_jur.ident_fis_jur = (SELECT MAX ( x04.ident_fis_jur )
                                                     FROM x04_pessoa_fis_jur x04
                                                    WHERE x04.cpf_cgc = x04_pessoa_fis_jur.cpf_cgc
                                                      AND x04.valid_fis_jur <= '31/12/2018') -- parametro
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
           AND reinf_pger_apur.ind_tp_amb = '2')
 WHERE rnk = 1



--
--select      max(id_pger_apur) over () as min_sal
--   , reinf_pger_apur.*
--  from reinf_pger_apur
--where dat_apur = '31/01/2018'