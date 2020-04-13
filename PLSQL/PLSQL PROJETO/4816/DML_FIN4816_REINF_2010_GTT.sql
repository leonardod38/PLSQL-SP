

select *  FROM MSAFI.FIN4816_REINF_2010_GTT



INSERT INTO MSAFI.FIN4816_REINF_2010_GTT
SELECT 
        --  pk        
        reinf_pger_apur.cod_empresa             as cod_empresa_pk
      , reinf_pger_apur.cod_estab               as cod_estab_pk
      , rnf.data_saida_rec_nf                   as dat_fiscal_pk                    
      , rnf.dat_emissao_nf                      as dat_emissao_pk
      , x04_pessoa_fis_jur.ident_fis_jur        as iden_fis_jur_pk 
      , rnf.num_docto                           as num_docfis_pk         
        -- relatorio 
     ,  empresa.cod_empresa                     AS "Codigo Empresa"         
     , estabelecimento.razao_social             AS "Razão Social Drogaria"
     , ( x04_pessoa_fis_jur.razao_social )      AS "Razão Social Cliente"
     ,  rnf.num_docto                           AS "Número da Nota Fiscal"
     ,  rnf.dat_emissao_nf                      AS "Data de Emissão da NF"
     ,  rnf.data_saida_rec_nf                   AS "Data Fiscal"
     ,  rserv.vlr_retencao                      AS "Valor do Tributo"
     ,  rnf.observacao                          AS "observacao"
     ,  rserv.tp_servico                        AS "Tipo de Serviço E-social"
     ,  rserv.vlr_base_ret                      AS "Vlr. Base de Calc. Retenção"
     ,  rserv.vlr_retencao                      AS "Valor da Retenção"
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
     , reinf_pger_apur.cod_empresa
     , reinf_pger_apur.cod_estab
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
             AND reinf_pger_apur.cod_empresa IN ( 'DSP' )               -- parametro
             AND reinf_pger_apur.cod_estab IN ( 'DSP004' )              -- parametro
             AND reinf_pger_apur.dat_apur >= '01/12/2018'               -- parametro
             AND reinf_pger_apur.dat_apur <= '31/12/2018'               -- parametro
             AND ( ( '' IS NOT NULL
                AND reinf_pger_r2010_prest.cnpj_prestador = '' )
               OR '' IS NULL )
             AND reinf_pger_apur.ind_r2010 = 'S'
           --  AND reinf_pger_apur.cod_versao = 'v1_04_00'
             AND reinf_pger_apur.ind_tp_amb = '2'
        GROUP BY reinf_pger_r2010_prest.id_r2010_prest
               , reinf_pger_r2010_tom.id_r2010_tom
               , reinf_pger_apur.id_pger_apur) max_oc
 WHERE ( estabelecimento.cod_empresa = reinf_pger_apur.cod_empresa )
   AND ( estabelecimento.cod_estab = reinf_pger_apur.cod_estab )
   AND ( estabelecimento.cod_empresa = empresa.cod_empresa )
   AND ( reinf_pger_r2010_prest.cnpj_prestador = x04_pessoa_fis_jur.cpf_cgc )
   AND x04_pessoa_fis_jur.ident_fis_jur = (SELECT MAX ( x04.ident_fis_jur )
                                             FROM x04_pessoa_fis_jur x04
                                            WHERE x04.cpf_cgc = x04_pessoa_fis_jur.cpf_cgc
                                              AND x04.valid_fis_jur <= '31/12/2018')        -- parametro 
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
   AND ( reinf_pger_apur.cod_empresa IN ( 'DSP' ) )         -- parametro
   AND ( reinf_pger_apur.cod_estab IN ( 'DSP004' ) )        -- parametro 
   AND reinf_pger_apur.dat_apur >= '01/12/2018'             -- parametro
   AND reinf_pger_apur.dat_apur <= '31/12/2018'             -- parametro
   AND ( ( '' IS NOT NULL
      AND reinf_pger_r2010_prest.cnpj_prestador = '' )
     OR '' IS NULL )
   AND ( reinf_pger_apur.ind_r2010 = 'S' )
   --AND ( reinf_pger_apur.cod_versao = 'v1_04_00' )
   AND reinf_pger_apur.ind_tp_amb = '2'
   --AND rnf.num_docto = '000008508'