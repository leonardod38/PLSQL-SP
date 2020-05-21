SELECT
           cod_empresa              , cod_estab               , dat_emissao             , iden_fis_jur               , num_docfis
          , "Codigo Empresa"        , "Razão Social Drogaria" , "Razão Social Cliente"  , "Número da Nota Fiscal"    , "Data de Emissão da NF"
          , "Data Fiscal"           , "Valor do Tributo"      , "observacao"            , "Tipo de Serviço E-social" , "Vlr. Base de Calc. Retenção"
          , "Valor da Retenção"     , proc_id                 , ind_status              , cnpj_prestador             , ind_obra
          , tp_inscricao            , nr_inscricao            , num_recibo              , ind_tp_amb                 , vlr_bruto
          , vlr_base_ret            , vlr_ret_princ           , vlr_ret_adic            , vlr_n_ret_princ            , vlr_n_ret_adic
          , ind_cprb                , cod_versao_proc         , cod_versao_layout       , ind_proc_emissao           , id_evento
          , ind_oper                , dat_ocorrencia          , cgc                     , razao_social               , x04_razao_social
          , id_r2010_oc             , num_docto               , serie                   , dat_emissao_nf             , data_fiscal          
          , rnf_vlr_bruto           , observacao              , id_r2010_nf             , ind_tp_proc_adj_adic       , num_proc_adj_adic       
          , cod_susp_adic           , radic_vlr_n_ret_adic    , ind_tp_proc_adj_princ   , num_proc_adj_princ         , cod_susp_princ
          , rprinc_vlr_n_ret_princ  , tp_servico              , rserv_vlr_base_ret      , vlr_retencao               , vlr_ret_sub
          , rserv_vlr_n_ret_princ   , vlr_servicos_15         , vlr_servicos_20         , vlr_servicos_25            , rserv_vlr_ret_adic
          , rserv_vlr_n_ret_adic    , rnk                     
  FROM (   SELECT 
               reinf_pger_apur.cod_empresa                          AS cod_empresa
             , reinf_pger_apur.cod_estab                            AS cod_estab
             , rnf.dat_emissao_nf                                   AS dat_emissao
             , x04_pessoa_fis_jur.ident_fis_jur                     AS iden_fis_jur
             , rnf.num_docto                                        AS num_docfis
             , empresa.cod_empresa                                  AS "Codigo Empresa"
             , estabelecimento.razao_social                         AS "Razão Social Drogaria"
             , ( x04_pessoa_fis_jur.razao_social )                  AS "Razão Social Cliente"
             , rnf.num_docto                                        AS "Número da Nota Fiscal"
             , rnf.dat_emissao_nf                                   AS "Data de Emissão da NF"
             , rnf.data_saida_rec_nf                                AS "Data Fiscal"
             , rserv.vlr_retencao                                   AS "Valor do Tributo"
             , rnf.observacao                                       AS "observacao"
             , rserv.tp_servico                                     AS "Tipo de Serviço E-social"
             , rserv.vlr_base_ret                                   AS "Vlr. Base de Calc. Retenção"
             , rserv.vlr_retencao                                   AS "Valor da Retenção"
             , reinf_pger_r2010_oc.proc_id                          AS proc_id
             , reinf_pger_r2010_oc.ind_status                       AS ind_status
             , reinf_pger_r2010_prest.cnpj_prestador                AS cnpj_prestador
             , reinf_pger_r2010_oc.ind_obra                         AS ind_obra
             , reinf_pger_r2010_tom.tp_inscricao                    AS tp_inscricao
             , reinf_pger_r2010_tom.nr_inscricao                    AS nr_inscricao
             , reinf_pger_r2010_oc.num_recibo                       AS num_recibo
             , reinf_pger_r2010_oc.ind_tp_amb                       AS ind_tp_amb
             , reinf_pger_r2010_oc.vlr_bruto                        AS vlr_bruto
             , reinf_pger_r2010_oc.vlr_base_ret                     AS vlr_base_ret
             , reinf_pger_r2010_oc.vlr_ret_princ                    AS vlr_ret_princ
             , reinf_pger_r2010_oc.vlr_ret_adic                     AS vlr_ret_adic
             , reinf_pger_r2010_oc.vlr_n_ret_princ                  AS vlr_n_ret_princ
             , reinf_pger_r2010_oc.vlr_n_ret_adic                   AS vlr_n_ret_adic
             , reinf_pger_r2010_oc.ind_cprb                         AS ind_cprb
             , reinf_pger_r2010_oc.cod_versao_proc                  AS cod_versao_proc
             , reinf_pger_r2010_oc.cod_versao_layout                AS cod_versao_layout
             , reinf_pger_r2010_oc.ind_proc_emissao                 AS ind_proc_emissao
             , reinf_pger_r2010_oc.id_evento                        AS id_evento
             , reinf_pger_r2010_oc.ind_oper                         AS ind_oper             
             , reinf_pger_r2010_oc.dat_ocorrencia                   AS dat_ocorrencia
             , estabelecimento.cgc                                  AS cgc
             , empresa.razao_social                                 AS razao_social
             , ( x04_pessoa_fis_jur.razao_social )                  AS x04_razao_social
             , reinf_pger_r2010_oc.id_r2010_oc                      AS id_r2010_oc
             , ( rnf.num_docto )                                    AS num_docto
             , ( rnf.serie )                                        AS serie
             , ( rnf.dat_emissao_nf )                               AS dat_emissao_nf
             , ( rnf.data_saida_rec_nf )                            AS data_fiscal
             , ( rnf.vlr_bruto )                                    AS rnf_vlr_bruto
             , ( rnf.observacao )                                   AS observacao
             , ( rnf.id_r2010_nf )                                  AS id_r2010_nf
             , ( radic.ind_tp_proc_adj_adic )                       AS ind_tp_proc_adj_adic
             , ( radic.num_proc_adj_adic )                          AS num_proc_adj_adic
             , ( radic.cod_susp_adic )                              AS cod_susp_adic
             , ( radic.vlr_n_ret_adic )                             AS radic_vlr_n_ret_adic
             , ( rprinc.ind_tp_proc_adj_princ )                     AS ind_tp_proc_adj_princ
             , ( rprinc.num_proc_adj_princ )                        AS num_proc_adj_princ
             , ( rprinc.cod_susp_princ )                            AS cod_susp_princ
             , ( rprinc.vlr_n_ret_princ )                           AS rprinc_vlr_n_ret_princ
             , ( rserv.tp_servico )                                 AS tp_servico
             , ( rserv.vlr_base_ret )                               AS rserv_vlr_base_ret
             , ( rserv.vlr_retencao )                               AS vlr_retencao
             , ( rserv.vlr_ret_sub )                                AS vlr_ret_sub
             , ( rserv.vlr_n_ret_princ )                            AS rserv_vlr_n_ret_princ
             , ( rserv.vlr_servicos_15 )                            AS vlr_servicos_15
             , ( rserv.vlr_servicos_20 )                            AS vlr_servicos_20
             , ( rserv.vlr_servicos_25 )                            AS vlr_servicos_25
             , ( rserv.vlr_ret_adic )                               AS rserv_vlr_ret_adic
             , ( rserv.vlr_n_ret_adic )                             AS rserv_vlr_n_ret_adic
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
                   WHERE reinf_pger_apur.id_pger_apur           = reinf_pger_r2010_tom.id_pger_apur
                     AND reinf_pger_r2010_tom.id_r2010_tom      = reinf_pger_r2010_prest.id_r2010_tom
                     AND reinf_pger_r2010_prest.id_r2010_prest  = reinf_pger_r2010_oc.id_r2010_prest
                     AND reinf_pger_apur.cod_empresa            = 'DSP'               -- parametro
                     AND reinf_pger_apur.dat_apur BETWEEN  '01/03/2020' AND  '31/03/2020'  -- parametro
                     AND reinf_pger_apur.ind_r2010 = 'S'
                 --    AND reinf_pger_apur.cod_versao >= 'v1_04_00'
                    AND reinf_pger_apur.ind_tp_amb <> '2'
                GROUP BY reinf_pger_r2010_prest.id_r2010_prest
                       , reinf_pger_r2010_tom.id_r2010_tom
                       , reinf_pger_apur.id_pger_apur) max_oc
             , msafi.tb_fin4816_prev_tmp_estab estab1
            -- select * from msafi.tb_fin4816_prev_tmp_estab estab1
         WHERE 1 = 1
           AND reinf_pger_apur.dat_apur BETWEEN  '01/03/2020' AND  '31/03/2020'
           AND estab1.cod_estab                         = estabelecimento.cod_estab
           AND estab1.proc_id                           = 1185500     
           AND  estabelecimento.cod_estab               = 'DSP004'     
           AND ( estabelecimento.cod_empresa            = reinf_pger_apur.cod_empresa )
           AND ( estabelecimento.cod_estab              = reinf_pger_apur.cod_estab )
           AND ( estabelecimento.cod_empresa            = empresa.cod_empresa )
           AND ( reinf_pger_r2010_prest.cnpj_prestador  = x04_pessoa_fis_jur.cpf_cgc )
           AND x04_pessoa_fis_jur.ident_fis_jur         = 
                                                        (SELECT MAX ( x04.ident_fis_jur )
                                                          FROM x04_pessoa_fis_jur x04
                                                         WHERE x04.cpf_cgc         = x04_pessoa_fis_jur.cpf_cgc
                                                         AND   x04.valid_fis_jur  <= '31/03/2020') -- parametro
           AND ( reinf_pger_r2010_tom.id_pger_apur      = reinf_pger_apur.id_pger_apur )
           AND ( reinf_pger_r2010_tom.id_r2010_tom      = reinf_pger_r2010_prest.id_r2010_tom )
           AND ( reinf_pger_r2010_prest.id_r2010_prest  = reinf_pger_r2010_oc.id_r2010_prest )
           AND ( reinf_pger_r2010_oc.id_r2010_oc        = rnf.id_r2010_oc )
           AND ( reinf_pger_r2010_oc.dat_ocorrencia     = max_oc.dat_ocorrencia )
           AND ( reinf_pger_r2010_prest.id_r2010_prest  = max_oc.id_r2010_prest )
           AND ( reinf_pger_r2010_tom.id_r2010_tom      = max_oc.id_r2010_tom )
           AND ( reinf_pger_apur.id_pger_apur           = max_oc.id_pger_apur )
           AND rnf.id_r2010_nf                          = rserv.id_r2010_nf(+)
           AND reinf_pger_r2010_oc.id_r2010_oc          = radic.id_r2010_oc(+)
           AND reinf_pger_r2010_oc.id_r2010_oc          = rprinc.id_r2010_oc(+)
           AND ( reinf_pger_apur.ind_r2010              = 'S' )
          --AND ( reinf_pger_apur.cod_versao = 'v1_04_00' )
            AND reinf_pger_apur.ind_tp_amb               <> '2' ) where  rnk = 1
         