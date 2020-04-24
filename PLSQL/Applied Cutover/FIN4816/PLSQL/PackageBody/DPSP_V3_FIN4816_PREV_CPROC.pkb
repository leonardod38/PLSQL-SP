CREATE OR REPLACE PACKAGE BODY MSAF.dpsp_v3_fin4816_prev_cproc
IS
    mproc_id NUMBER;
    mnm_usuario usuario_estab.cod_usuario%TYPE;
    mcod_empresa estabelecimento.cod_empresa%TYPE;

    --Tipo, Nome e Descrição do Customizado
    mnm_tipo VARCHAR2 ( 100 ) := 'Relatorio Previdenciario';
    mnm_cproc VARCHAR2 ( 100 ) := '3.Relatorio de apoio';
    mds_cproc VARCHAR2 ( 100 ) := 'Validacao das Inf. Reinf V3';

    v_sel_data_fim VARCHAR2 ( 260 )
        := 'SELECT TRUNC( TO_DATE( :1 ,''DD/MM/YYYY'') + ROWNUM - 1) AS DATA_FIM, TRUNC( TO_DATE( :1 ,''DD/MM/YYYY'') + ROWNUM - 1) AS DATA_FIM FROM DUAL CONNECT BY ROWNUM <= LAST_DAY( TO_DATE( :1 ,''DD/MM/YYYY'') ) - TO_DATE( :1 ,''DD/MM/YYYY'') + 1 ORDER BY 1 DESC ';

    i NUMBER := 0;


     
               

--    CURSOR rc_prev ( pdate DATE
--                   , pcod_empresa VARCHAR2
--                   , p_proc_id NUMBER )
--    IS
--        SELECT 'S' AS tipo
--             , reinf.cod_empresa AS "Codigo Empresa"
--             , reinf.cod_estab AS "Codigo Estabelecimento"
--             , reinf.data_emissao AS "Data Emissão"
--             , reinf.data_fiscal AS "Data Fiscal"
--             , reinf.ident_fis_jur
--             , reinf.ident_docto
--             , reinf.num_docfis AS "Número da Nota Fiscal"
--             --
--             , reinf.num_docfis || '/' || reinf.serie_docfis AS "Docto/Série"
--             , reinf.data_emissao AS "Emissão"
--             --
--             , reinf.serie_docfis
--             , reinf.sub_serie_docfis
--             , reinf.num_item
--             , reinf.cod_usuario
--             , x04.cod_fis_jur AS "Codigo Pessoa Fisica/Juridica"
--             , INITCAP ( x04.razao_social ) AS "Razão Social Cliente"
--             , x04.ind_fis_jur
--             , x04.cpf_cgc AS "CNPJ Cliente"
--             , reinf.cod_class_doc_fis
--             , reinf.vlr_tot_nota
--             , reinf.vlr_base_inss AS "Vlr Base Calc. Retenção"
--             , reinf.vlr_aliq_inss
--             , reinf.vlr_inss_retido AS "Vlr.Trib INSS RETIDO"
--             , reinf.vlr_inss_retido AS "Valor da Retenção"
--             , reinf.vlr_contab_compl
--             , reinf.ind_tipo_proc
--             , reinf.num_proc_jur
--             , estab.razao_social
--             , estab.cgc
--             , x2005.descricao AS "Documento"
--             , prt_tipo.cod_tipo_serv_esocial AS "Tipo de Serviço E-social"
--             , prt_tipo.dsc_tipo_serv_esocial
--             , INITCAP ( empresa.razao_social ) AS "Razão Social Drogaria"
--             , reinf.vlr_servico AS "Valor do Servico"
--             , reinf.num_proc_adj_adic
--             , reinf.ind_tp_proc_adj_adic
--             , x2018.cod_servico AS codigo_serv_prod
--             , INITCAP ( x2018.descricao ) AS desc_serv_prod
--             , x2005.cod_docto
--             , NULL AS "Observação"
--             , NULL AS dsc_param
--        FROM msafi.tb_fin4816_reinf_conf_prev_gtt reinf     
--             , MSAFI.TB_FIN4816_PREV_TMP_ESTAB estab1
--             , x04_pessoa_fis_jur x04
--             , estabelecimento estab
--             , x2005_tipo_docto x2005
--             , prt_tipo_serv_esocial prt_tipo
--             , x2018_servicos x2018
--             , empresa
--         WHERE 1 = 1
--           AND reinf.cod_estab = estab1.cod_estab -- parametro
--           AND estab1.proc_id = p_proc_id -- parametro
--           AND reinf.cod_empresa = pcod_empresa -- parametro
--           AND reinf.data_emissao = pdate -- parametro
--           ---
--           AND reinf.ident_fis_jur = x04.ident_fis_jur
--           AND reinf.cod_empresa = estab.cod_empresa
--           AND reinf.cod_estab = estab.cod_estab
--           AND reinf.ident_docto = x2005.ident_docto
--           AND reinf.ident_tipo_serv_esocial = prt_tipo.ident_tipo_serv_esocial /*(+)*/
--           AND reinf.cod_empresa = empresa.cod_empresa
--           AND LENGTH ( TRIM ( x04.cpf_cgc ) ) > 11
--           AND reinf.ident_servico = x2018.ident_servico
--        UNION
--        SELECT 'R' AS tipo
--             , reinf.cod_empresa AS "Codigo Empresa"
--             , reinf.cod_estab AS "Codigo Estabelecimento"
--             , reinf.data_emissao AS "Data Emissão"
--             , reinf.data_fiscal AS "Data Fiscal"
--             , reinf.ident_fis_jur
--             , reinf.ident_docto
--             , reinf.num_docfis AS "Número da Nota Fiscal"
--             --
--             , reinf.num_docfis || '/' || reinf.serie_docfis AS "Docto/Série"
--             , reinf.data_emissao AS "Emissão"
--             --
--             , reinf.serie_docfis
--             , reinf.sub_serie_docfis
--             , reinf.num_item
--             , reinf.cod_usuario
--             , x04.cod_fis_jur AS "Codigo Pessoa Fisica/Juridica"
--             , INITCAP ( x04.razao_social ) AS "Razão Social Cliente"
--             , x04.ind_fis_jur
--             , x04.cpf_cgc AS "CNPJ Cliente"
--             , reinf.cod_class_doc_fis
--             , reinf.vlr_tot_nota
--             , reinf.vlr_base_inss AS "Vlr Base Calc. Retenção"
--             , reinf.vlr_aliq_inss
--             , reinf.vlr_inss_retido AS "Vlr.Trib INSS RETIDO"
--             , reinf.vlr_inss_retido AS "Valor da Retenção"
--             , reinf.vlr_contab_compl
--             , reinf.ind_tipo_proc
--             , reinf.num_proc_jur
--             , estab.razao_social
--             , estab.cgc
--             , x2005.descricao AS "Documento"
--             , NULL
--             , NULL
--             , INITCAP ( empresa.razao_social ) AS "Razão Social Drogaria"
--             , reinf.vlr_servico AS "Valor do Servico"
--             , reinf.num_proc_adj_adic
--             , reinf.ind_tp_proc_adj_adic
--             , x2018.cod_servico AS codigo_serv_prod
--             , INITCAP ( x2018.descricao ) AS desc_serv_prod
--             , x2005.cod_docto
--             , NULL AS "Observação"
--             , prt_repasse.dsc_param
--          FROM MSAFI.TB_FIN4816_REINF_CONF_PREV_GTT reinf
--             , MSAFI.TB_FIN4816_PREV_TMP_ESTAB estab1
--             , x04_pessoa_fis_jur x04
--             , estabelecimento estab
--             , x2005_tipo_docto x2005
--             , prt_par2_msaf prt_repasse
--             , x2018_servicos x2018
--             , empresa
--         WHERE 1 = 1
--           AND reinf.cod_estab = estab1.cod_estab -- parametro
--           AND estab1.proc_id = p_proc_id -- parametro
--           AND reinf.cod_empresa = pcod_empresa -- parametro
--           AND reinf.data_emissao = pdate -- parametro
--           --
--           AND reinf.ident_fis_jur = x04.ident_fis_jur
--           AND reinf.cod_empresa = estab.cod_empresa
--           AND reinf.cod_estab = estab.cod_estab
--           AND reinf.ident_docto = x2005.ident_docto
--           AND reinf.cod_param = prt_repasse.cod_param
--           AND reinf.cod_empresa = empresa.cod_empresa
--           AND LENGTH ( TRIM ( x04.cpf_cgc ) ) > 11
--           AND reinf.ident_servico = x2018.ident_servico;
    

        

--        CURSOR rc_2010 ( pdate DATE
--                   , pcod_empresa VARCHAR2
--                   , p_proc_id NUMBER )
--         IS
--        SELECT --  pk
--               reinf_pger_apur.cod_empresa AS cod_empresa
--             , reinf_pger_apur.cod_estab AS cod_estab
--             , rnf.dat_emissao_nf AS dat_emissao
--             , x04_pessoa_fis_jur.ident_fis_jur AS iden_fis_jur
--             , rnf.num_docto AS num_docfis
--             , empresa.cod_empresa AS "Codigo Empresa"
--             , estabelecimento.razao_social AS "Razão Social Drogaria"
--             , ( x04_pessoa_fis_jur.razao_social ) AS "Razão Social Cliente"
--             , rnf.num_docto AS "Número da Nota Fiscal"
--             , rnf.dat_emissao_nf AS "Data de Emissão da NF"
--             , rnf.data_saida_rec_nf AS "Data Fiscal"
--             , rserv.vlr_retencao AS "Valor do Tributo"
--             , rnf.observacao AS "observacao"
--             , rserv.tp_servico AS "Tipo de Serviço E-social"
--             , rserv.vlr_base_ret AS "Vlr. Base de Calc. Retenção"
--             , rserv.vlr_retencao AS "Valor da Retenção"
--             , reinf_pger_r2010_oc.proc_id
--             , reinf_pger_r2010_oc.ind_status
--             , reinf_pger_r2010_prest.cnpj_prestador
--             , reinf_pger_r2010_oc.ind_obra
--             , reinf_pger_r2010_tom.tp_inscricao
--             , reinf_pger_r2010_tom.nr_inscricao
--             , reinf_pger_r2010_oc.num_recibo
--             , reinf_pger_r2010_oc.ind_tp_amb
--             , reinf_pger_r2010_oc.vlr_bruto
--             , reinf_pger_r2010_oc.vlr_base_ret
--             , reinf_pger_r2010_oc.vlr_ret_princ
--             , reinf_pger_r2010_oc.vlr_ret_adic
--             , reinf_pger_r2010_oc.vlr_n_ret_princ
--             , reinf_pger_r2010_oc.vlr_n_ret_adic
--             , reinf_pger_r2010_oc.ind_cprb
--             , reinf_pger_r2010_oc.cod_versao_proc
--             , reinf_pger_r2010_oc.cod_versao_layout
--             , reinf_pger_r2010_oc.ind_proc_emissao
--             , reinf_pger_r2010_oc.id_evento
--             , reinf_pger_r2010_oc.ind_oper
--             , reinf_pger_r2010_oc.dat_ocorrencia
--             , estabelecimento.cgc
--             , empresa.razao_social
--             , ( x04_pessoa_fis_jur.razao_social ) x04_razao_social
--             , reinf_pger_r2010_oc.id_r2010_oc
--             , ( rnf.num_docto ) num_docto
--             , ( rnf.serie ) serie
--             , ( rnf.dat_emissao_nf ) dat_emissao_nf
--             , ( rnf.data_saida_rec_nf ) data_fiscal
--             , ( rnf.vlr_bruto ) rnf_vlr_bruto
--             , ( rnf.observacao ) observacao
--             , ( rnf.id_r2010_nf ) id_r2010_nf
--             , ( radic.ind_tp_proc_adj_adic ) ind_tp_proc_adj_adic
--             , ( radic.num_proc_adj_adic ) num_proc_adj_adic
--             , ( radic.cod_susp_adic ) cod_susp_adic
--             , ( radic.vlr_n_ret_adic ) radic_vlr_n_ret_adic
--             , ( rprinc.ind_tp_proc_adj_princ ) ind_tp_proc_adj_princ
--             , ( rprinc.num_proc_adj_princ ) num_proc_adj_princ
--             , ( rprinc.cod_susp_princ ) cod_susp_princ
--             , ( rprinc.vlr_n_ret_princ ) rprinc_vlr_n_ret_princ
--             , ( rserv.tp_servico ) tp_servico
--             , ( rserv.vlr_base_ret ) rserv_vlr_base_ret
--             , ( rserv.vlr_retencao ) vlr_retencao
--             , ( rserv.vlr_ret_sub ) vlr_ret_sub
--             , ( rserv.vlr_n_ret_princ ) rserv_vlr_n_ret_princ
--             , ( rserv.vlr_servicos_15 ) vlr_servicos_15
--             , ( rserv.vlr_servicos_20 ) vlr_servicos_20
--             , ( rserv.vlr_servicos_25 ) vlr_servicos_25
--             , ( rserv.vlr_ret_adic ) rserv_vlr_ret_adic
--             , ( rserv.vlr_n_ret_adic ) rserv_vlr_n_ret_adic
--             , RANK ( )
--                   OVER ( PARTITION BY reinf_pger_apur.cod_empresa
--                                     , reinf_pger_apur.cod_estab
--                                     , rnf.dat_emissao_nf
--                                     , x04_pessoa_fis_jur.ident_fis_jur
--                                     , rnf.num_docto
--                          ORDER BY reinf_pger_r2010_oc.dat_ocorrencia DESC )
--                   rnk
--             , reinf_pger_apur.id_pger_apur
--          FROM empresa
--             , estabelecimento
--             , reinf_pger_apur
--             , x04_pessoa_fis_jur
--             , reinf_pger_r2010_prest
--             , reinf_pger_r2010_tom
--             , reinf_pger_r2010_oc
--             , reinf_pger_r2010_nf rnf
--             , reinf_pger_r2010_tp_serv rserv
--             , reinf_pger_r2010_proc_adic radic
--             , reinf_pger_r2010_proc_princ rprinc
--             , (SELECT   MAX ( dat_ocorrencia ) dat_ocorrencia
--                       , reinf_pger_r2010_prest.id_r2010_prest
--                       , reinf_pger_r2010_tom.id_r2010_tom
--                       , reinf_pger_apur.id_pger_apur
--                    FROM reinf_pger_r2010_oc
--                       , reinf_pger_r2010_prest
--                       , reinf_pger_r2010_tom
--                       , reinf_pger_apur
--                   WHERE reinf_pger_apur.id_pger_apur = reinf_pger_r2010_tom.id_pger_apur
--                     AND reinf_pger_r2010_tom.id_r2010_tom = reinf_pger_r2010_prest.id_r2010_tom
--                     AND reinf_pger_r2010_prest.id_r2010_prest = reinf_pger_r2010_oc.id_r2010_prest
--                     AND reinf_pger_apur.cod_empresa = pcod_empresa -- parametro
--                     AND reinf_pger_apur.dat_apur = pdate -- parametro
--                     AND reinf_pger_apur.ind_r2010 = 'S'
--                     --                       AND reinf_pger_apur.cod_versao >= 'v1_04_00'
--                     AND reinf_pger_apur.ind_tp_amb = '2'
--                GROUP BY reinf_pger_r2010_prest.id_r2010_prest
--                       , reinf_pger_r2010_tom.id_r2010_tom
--                       , reinf_pger_apur.id_pger_apur) max_oc
--             , MSAFI.TB_FIN4816_PREV_TMP_ESTAB estab1
--         WHERE 1 = 1
--           AND estab1.cod_estab = estabelecimento.cod_estab
--           AND estab1.proc_id = p_proc_id
--           AND reinf_pger_apur.dat_apur = pdate
--           AND ( estabelecimento.cod_empresa = reinf_pger_apur.cod_empresa )
--           AND ( estabelecimento.cod_estab = reinf_pger_apur.cod_estab )
--           AND ( estabelecimento.cod_empresa = empresa.cod_empresa )
--           AND ( reinf_pger_r2010_prest.cnpj_prestador = x04_pessoa_fis_jur.cpf_cgc )
--           AND x04_pessoa_fis_jur.ident_fis_jur = (SELECT MAX ( x04.ident_fis_jur )
--                                                     FROM x04_pessoa_fis_jur x04
--                                                    WHERE x04.cpf_cgc = x04_pessoa_fis_jur.cpf_cgc
--                                                      AND x04.valid_fis_jur <= pdate) -- parametro
--           AND ( reinf_pger_r2010_tom.id_pger_apur = reinf_pger_apur.id_pger_apur )
--           AND ( reinf_pger_r2010_tom.id_r2010_tom = reinf_pger_r2010_prest.id_r2010_tom )
--           AND ( reinf_pger_r2010_prest.id_r2010_prest = reinf_pger_r2010_oc.id_r2010_prest )
--           AND ( reinf_pger_r2010_oc.id_r2010_oc = rnf.id_r2010_oc )
--           AND ( reinf_pger_r2010_oc.dat_ocorrencia = max_oc.dat_ocorrencia )
--           AND ( reinf_pger_r2010_prest.id_r2010_prest = max_oc.id_r2010_prest )
--           AND ( reinf_pger_r2010_tom.id_r2010_tom = max_oc.id_r2010_tom )
--           AND ( reinf_pger_apur.id_pger_apur = max_oc.id_pger_apur )
--           AND rnf.id_r2010_nf = rserv.id_r2010_nf(+)
--           AND reinf_pger_r2010_oc.id_r2010_oc = radic.id_r2010_oc(+)
--           AND reinf_pger_r2010_oc.id_r2010_oc = rprinc.id_r2010_oc(+)
--           AND ( reinf_pger_apur.ind_r2010 = 'S' )
--           --AND ( reinf_pger_apur.cod_versao = 'v1_04_00' )
--           AND reinf_pger_apur.ind_tp_amb = '2';


        

--                    CURSOR rc_apoio_fiscal
--                     IS 
--                      SELECT   
--                            rpf.cod_empresa AS "Codigo da Empresa"
--                          , rpf.cod_estab AS "Codigo do Estabelecimento"
--                          , TO_CHAR ( rpf.data_emissao
--                                    , 'MM/YYYY' )
--                                AS "Periodo de Emissão"
--                          , rpf.cgc AS "CNPJ Drogaria"
--                          , rpf.num_docfis AS "Numero da Nota Fiscal"
--                          , rpf.tipo_docto AS "Tipo de Documento"
--                          , rpf.data_emissao AS "Data Emissão"
--                          , rpf.cgc_fornecedor AS "CNPJ Fonecedor"
--                          , rpf.uf AS "UF"
--                          , rpf.valor_total AS "Valor Total da Nota"
--                          , rpf.vlr_base_inss AS "Base de Calculo INSS"
--                          , rpf.vlr_inss AS "Valor do INSS"
--                          , rpf.codigo_fisjur AS "Codigo Pessoa Fisica/juridica"
--                          , INITCAP ( rpf.razao_social ) AS "Razão Social"
--                          , INITCAP ( rpf.municipio_prestador ) AS "Municipio Prestador"
--                          , rpf.cod_servico AS "Codigo de Serviço"
--                          , rpf.cod_cei AS "Codigo CEI"
--                          , NVL ( ( SELECT 'S' 
--                                      FROM msafi.tb_fin4816_reinf_prev_tmp rprev 
--                                     WHERE 1 = 1
--                                       AND rprev."Codigo Empresa" = rpf.cod_empresa
--                                       AND rprev."Codigo Estabelecimento" = rpf.cod_estab
--                                       AND rprev."Data Fiscal" = rpf.data_fiscal
--                                       AND rprev."Número da Nota Fiscal" = rpf.num_docfis
--                                       AND rprev.num_item = rpf.num_item )
--                                , 'N' )
--                                AS "DWT"
--                          ---   campos do Report Previdenciario
--                          , ( SELECT rprev."Codigo Estabelecimento"
--                                FROM msafi.tb_fin4816_reinf_prev_tmp rprev 
--                               WHERE 1 = 1
--                                 AND rprev."Codigo Empresa" = rpf.cod_empresa
--                                 AND rprev."Codigo Estabelecimento" = rpf.cod_estab
--                                 AND rprev."Data Fiscal" = rpf.data_fiscal
--                                 AND rprev."Número da Nota Fiscal" = rpf.num_docfis
--                                 AND rprev.num_item = rpf.num_item )
--                                AS empresa
--                          , ( SELECT rprev."Codigo Estabelecimento"
--                                FROM msafi.tb_fin4816_reinf_prev_tmp rprev 
--                               WHERE 1 = 1
--                                 AND rprev."Codigo Empresa" = rpf.cod_empresa
--                                 AND rprev."Codigo Estabelecimento" = rpf.cod_estab
--                                 AND rprev."Data Fiscal" = rpf.data_fiscal
--                                 AND rprev."Número da Nota Fiscal" = rpf.num_docfis
--                                 AND rprev.num_item = rpf.num_item )
--                                AS "Codigo Estabelecimento"
--                          , ( SELECT rprev."Codigo Pessoa Fisica/Juridica"
--                                FROM msafi.tb_fin4816_reinf_prev_tmp rprev 
--                               WHERE 1 = 1
--                                 AND rprev."Codigo Empresa" = rpf.cod_empresa
--                                 AND rprev."Codigo Estabelecimento" = rpf.cod_estab
--                                 AND rprev."Data Fiscal" = rpf.data_fiscal
--                                 AND rprev."Número da Nota Fiscal" = rpf.num_docfis
--                                 AND rprev.num_item = rpf.num_item )
--                                AS cod_pessoa_fis_jur
--                          , ( SELECT rprev."Razão Social Cliente"
--                                FROM msafi.tb_fin4816_reinf_prev_tmp rprev 
--                               WHERE 1 = 1
--                                 AND rprev."Codigo Empresa" = rpf.cod_empresa
--                                 AND rprev."Codigo Estabelecimento" = rpf.cod_estab
--                                 AND rprev."Data Fiscal" = rpf.data_fiscal
--                                 AND rprev."Número da Nota Fiscal" = rpf.num_docfis
--                                 AND rprev.num_item = rpf.num_item )
--                                AS "Razão Social Cliente"
--                          , ( SELECT rprev."CNPJ Cliente"
--                                FROM msafi.tb_fin4816_reinf_prev_tmp rprev 
--                               WHERE 1 = 1
--                                 AND rprev."Codigo Empresa" = rpf.cod_empresa
--                                 AND rprev."Codigo Estabelecimento" = rpf.cod_estab
--                                 AND rprev."Data Fiscal" = rpf.data_fiscal
--                                 AND rprev."Número da Nota Fiscal" = rpf.num_docfis
--                                 AND rprev.num_item = rpf.num_item )
--                                AS "CNPJ Cliente"
--                          , ( SELECT rprev."Número da Nota Fiscal"
--                                FROM msafi.tb_fin4816_reinf_prev_tmp rprev 
--                               WHERE 1 = 1
--                                 AND rprev."Codigo Empresa" = rpf.cod_empresa
--                                 AND rprev."Codigo Estabelecimento" = rpf.cod_estab
--                                 AND rprev."Data Fiscal" = rpf.data_fiscal
--                                 AND rprev."Número da Nota Fiscal" = rpf.num_docfis
--                                 AND rprev.num_item = rpf.num_item )
--                                AS "Nro. Nota Fiscal"
--                          , ( SELECT rprev."Emissão"
--                                FROM msafi.tb_fin4816_reinf_prev_tmp rprev 
--                               WHERE 1 = 1
--                                 AND rprev."Codigo Empresa" = rpf.cod_empresa
--                                 AND rprev."Codigo Estabelecimento" = rpf.cod_estab
--                                 AND rprev."Data Fiscal" = rpf.data_fiscal
--                                 AND rprev."Número da Nota Fiscal" = rpf.num_docfis
--                                 AND rprev.num_item = rpf.num_item )
--                                AS "Dt. Emissao"
--                          , ( SELECT rprev."Data Fiscal"
--                                FROM msafi.tb_fin4816_reinf_prev_tmp rprev 
--                               WHERE 1 = 1
--                                 AND rprev."Codigo Empresa" = rpf.cod_empresa
--                                 AND rprev."Codigo Estabelecimento" = rpf.cod_estab
--                                 AND rprev."Data Fiscal" = rpf.data_fiscal
--                                 AND rprev."Número da Nota Fiscal" = rpf.num_docfis
--                                 AND rprev.num_item = rpf.num_item )
--                                AS "Dt. Fiscal"
--                          , ( SELECT rprev.vlr_tot_nota
--                                FROM msafi.tb_fin4816_reinf_prev_tmp rprev 
--                               WHERE 1 = 1
--                                 AND rprev."Codigo Empresa" = rpf.cod_empresa
--                                 AND rprev."Codigo Estabelecimento" = rpf.cod_estab
--                                 AND rprev."Data Fiscal" = rpf.data_fiscal
--                                 AND rprev."Número da Nota Fiscal" = rpf.num_docfis
--                                 AND rprev.num_item = rpf.num_item )
--                                AS "Vlr. Total da Nota"
--                          , ( SELECT rprev."Vlr Base Calc. Retenção"
--                                FROM msafi.tb_fin4816_reinf_prev_tmp rprev 
--                               WHERE 1 = 1
--                                 AND rprev."Codigo Empresa" = rpf.cod_empresa
--                                 AND rprev."Codigo Estabelecimento" = rpf.cod_estab
--                                 AND rprev."Data Fiscal" = rpf.data_fiscal
--                                 AND rprev."Número da Nota Fiscal" = rpf.num_docfis
--                                 AND rprev.num_item = rpf.num_item )
--                                AS "Vlr Base Calc. Retenção"
--                          , ( SELECT rprev.vlr_aliq_inss
--                                FROM msafi.tb_fin4816_reinf_prev_tmp rprev 
--                               WHERE 1 = 1
--                                 AND rprev."Codigo Empresa" = rpf.cod_empresa
--                                 AND rprev."Codigo Estabelecimento" = rpf.cod_estab
--                                 AND rprev."Data Fiscal" = rpf.data_fiscal
--                                 AND rprev."Número da Nota Fiscal" = rpf.num_docfis
--                                 AND rprev.num_item = rpf.num_item )
--                                AS "Vlr. Aliquota INSS"
--                          , ( SELECT rprev."Vlr.Trib INSS RETIDO"
--                                FROM msafi.tb_fin4816_reinf_prev_tmp rprev 
--                               WHERE 1 = 1
--                                 AND rprev."Codigo Empresa" = rpf.cod_empresa
--                                 AND rprev."Codigo Estabelecimento" = rpf.cod_estab
--                                 AND rprev."Data Fiscal" = rpf.data_fiscal
--                                 AND rprev."Número da Nota Fiscal" = rpf.num_docfis
--                                 AND rprev.num_item = rpf.num_item )
--                                AS "Vlr.Trib INSS RETIDO"
--                          , ( SELECT rprev."Razão Social Drogaria"
--                                FROM msafi.tb_fin4816_reinf_prev_tmp rprev 
--                               WHERE 1 = 1
--                                 AND rprev."Codigo Empresa" = rpf.cod_empresa
--                                 AND rprev."Codigo Estabelecimento" = rpf.cod_estab
--                                 AND rprev."Data Fiscal" = rpf.data_fiscal
--                                 AND rprev."Número da Nota Fiscal" = rpf.num_docfis
--                                 AND rprev.num_item = rpf.num_item )
--                                AS "Razão Social Drogaria"
--                          , ( SELECT rprev.cgc
--                                FROM msafi.tb_fin4816_reinf_prev_tmp rprev 
--                               WHERE 1 = 1
--                                 AND rprev."Codigo Empresa" = rpf.cod_empresa
--                                 AND rprev."Codigo Estabelecimento" = rpf.cod_estab
--                                 AND rprev."Data Fiscal" = rpf.data_fiscal
--                                 AND rprev."Número da Nota Fiscal" = rpf.num_docfis
--                                 AND rprev.num_item = rpf.num_item )
--                                AS "CNPJ Drogarias"
--                          , ( SELECT rprev.cod_docto
--                                FROM msafi.tb_fin4816_reinf_prev_tmp rprev 
--                               WHERE 1 = 1
--                                 AND rprev."Codigo Empresa" = rpf.cod_empresa
--                                 AND rprev."Codigo Estabelecimento" = rpf.cod_estab
--                                 AND rprev."Data Fiscal" = rpf.data_fiscal
--                                 AND rprev."Número da Nota Fiscal" = rpf.num_docfis
--                                 AND rprev.num_item = rpf.num_item )
--                                AS "Descr. Tp. Documento"
--                          , ( SELECT rprev."Tipo de Serviço E-social"
--                                FROM msafi.tb_fin4816_reinf_prev_tmp rprev 
--                               WHERE 1 = 1
--                                 AND rprev."Codigo Empresa" = rpf.cod_empresa
--                                 AND rprev."Codigo Estabelecimento" = rpf.cod_estab
--                                 AND rprev."Data Fiscal" = rpf.data_fiscal
--                                 AND rprev."Número da Nota Fiscal" = rpf.num_docfis
--                                 AND rprev.num_item = rpf.num_item )
--                                AS "Tp.Serv. E-social"
--                          , ( SELECT rprev.dsc_tipo_serv_esocial
--                                FROM msafi.tb_fin4816_reinf_prev_tmp rprev 
--                               WHERE 1 = 1
--                                 AND rprev."Codigo Empresa" = rpf.cod_empresa
--                                 AND rprev."Codigo Estabelecimento" = rpf.cod_estab
--                                 AND rprev."Data Fiscal" = rpf.data_fiscal
--                                 AND rprev."Número da Nota Fiscal" = rpf.num_docfis
--                                 AND rprev.num_item = rpf.num_item )
--                                AS "Descr. Tp. Serv E-social"
--                          , ( SELECT rprev."Valor do Servico"
--                                FROM msafi.tb_fin4816_reinf_prev_tmp rprev 
--                               WHERE 1 = 1
--                                 AND rprev."Codigo Empresa" = rpf.cod_empresa
--                                 AND rprev."Codigo Estabelecimento" = rpf.cod_estab
--                                 AND rprev."Data Fiscal" = rpf.data_fiscal
--                                 AND rprev."Número da Nota Fiscal" = rpf.num_docfis
--                                 AND rprev.num_item = rpf.num_item )
--                                AS "Vlr. do Servico"
--                          , ( SELECT rprev.codigo_serv_prod
--                                FROM msafi.tb_fin4816_reinf_prev_tmp rprev 
--                               WHERE 1 = 1
--                                 AND rprev."Codigo Empresa" = rpf.cod_empresa
--                                 AND rprev."Codigo Estabelecimento" = rpf.cod_estab
--                                 AND rprev."Data Fiscal" = rpf.data_fiscal
--                                 AND rprev."Número da Nota Fiscal" = rpf.num_docfis
--                                 AND rprev.num_item = rpf.num_item )
--                                AS "Cod. Serv. Mastersaf"
--                          , ( SELECT rprev.desc_serv_prod
--                                FROM msafi.tb_fin4816_reinf_prev_tmp rprev 
--                               WHERE 1 = 1
--                                 AND rprev."Codigo Empresa" = rpf.cod_empresa
--                                 AND rprev."Codigo Estabelecimento" = rpf.cod_estab
--                                 AND rprev."Data Fiscal" = rpf.data_fiscal
--                                 AND rprev."Número da Nota Fiscal" = rpf.num_docfis
--                                 AND rprev.num_item = rpf.num_item )
--                                AS "Descr. Serv. Mastersaf"
--                          ---
--                          -- REINF  EVENTO R2010
--                          ---
--                          , ( SELECT r2010.cod_empresa
--                                FROM msafi.tb_fin4816_reinf_2010_tmp r2010
--                               WHERE 1 = 1
--                                 AND r2010.cod_empresa = rpf.cod_empresa
--                                 AND r2010.cod_estab = rpf.cod_estab
--                                 AND r2010.dat_emissao = rpf.data_emissao
--                                 AND r2010.data_fiscal = rpf.data_fiscal
--                                 AND r2010.num_docfis = rpf.num_docfis
--                                 AND r2010.rnk = 1 )
--                                AS "Codigo Empresa"
--                          , ( SELECT INITCAP ( r2010."Razão Social Drogaria" )
--                                FROM msafi.tb_fin4816_reinf_2010_tmp r2010
--                               WHERE 1 = 1
--                                 AND r2010.cod_empresa = rpf.cod_empresa
--                                 AND r2010.cod_estab = rpf.cod_estab
--                                 AND r2010.dat_emissao = rpf.data_emissao
--                                 AND r2010.data_fiscal = rpf.data_fiscal
--                                 AND r2010.num_docfis = rpf.num_docfis
--                                 AND r2010.rnk = 1 )
--                                AS "Razão Social Drogaria."
--                          , ( SELECT INITCAP ( r2010."Razão Social Cliente" )
--                                FROM msafi.tb_fin4816_reinf_2010_tmp r2010
--                               WHERE 1 = 1
--                                 AND r2010.cod_empresa = rpf.cod_empresa
--                                 AND r2010.cod_estab = rpf.cod_estab
--                                 AND r2010.dat_emissao = rpf.data_emissao
--                                 AND r2010.data_fiscal = rpf.data_fiscal
--                                 AND r2010.num_docfis = rpf.num_docfis
--                                 AND r2010.rnk = 1 )
--                                AS "Razão Social Cliente."
--                          , ( SELECT ( r2010."Número da Nota Fiscal" )
--                                FROM msafi.tb_fin4816_reinf_2010_tmp r2010
--                               WHERE 1 = 1
--                                 AND r2010.cod_empresa = rpf.cod_empresa
--                                 AND r2010.cod_estab = rpf.cod_estab
--                                 AND r2010.dat_emissao = rpf.data_emissao
--                                 AND r2010.data_fiscal = rpf.data_fiscal
--                                 AND r2010.num_docfis = rpf.num_docfis
--                                 AND r2010.rnk = 1 )
--                                AS "Número da Nota Fiscal."
--                          , ( SELECT ( r2010."Data de Emissão da NF" )
--                                FROM msafi.tb_fin4816_reinf_2010_tmp r2010
--                               WHERE 1 = 1
--                                 AND r2010.cod_empresa = rpf.cod_empresa
--                                 AND r2010.cod_estab = rpf.cod_estab
--                                 AND r2010.dat_emissao = rpf.data_emissao
--                                 AND r2010.data_fiscal = rpf.data_fiscal
--                                 AND r2010.num_docfis = rpf.num_docfis
--                                 AND r2010.rnk = 1 )
--                                AS "Data de Emissão da NF."
--                          --
--                          , ( SELECT ( r2010."Data Fiscal" )
--                                FROM msafi.tb_fin4816_reinf_2010_tmp r2010
--                               WHERE 1 = 1
--                                 AND r2010.cod_empresa = rpf.cod_empresa
--                                 AND r2010.cod_estab = rpf.cod_estab
--                                 AND r2010.dat_emissao = rpf.data_emissao
--                                 AND r2010.data_fiscal = rpf.data_fiscal
--                                 AND r2010.num_docfis = rpf.num_docfis
--                                 AND r2010.rnk = 1 )
--                                AS "Data Fiscal."
--                          --
--                          , ( SELECT ( r2010."Valor do Tributo" )
--                                FROM msafi.tb_fin4816_reinf_2010_tmp r2010
--                               WHERE 1 = 1
--                                 AND r2010.cod_empresa = rpf.cod_empresa
--                                 AND r2010.cod_estab = rpf.cod_estab
--                                 AND r2010.dat_emissao = rpf.data_emissao
--                                 AND r2010.data_fiscal = rpf.data_fiscal
--                                 AND r2010.num_docfis = rpf.num_docfis
--                                 AND r2010.rnk = 1 )
--                                AS "Valor do Tributo."
--                          , ( SELECT INITCAP ( r2010."observacao" )
--                                FROM msafi.tb_fin4816_reinf_2010_tmp r2010
--                               WHERE 1 = 1
--                                 AND r2010.cod_empresa = rpf.cod_empresa
--                                 AND r2010.cod_estab = rpf.cod_estab
--                                 AND r2010.dat_emissao = rpf.data_emissao
--                                 AND r2010.data_fiscal = rpf.data_fiscal
--                                 AND r2010.num_docfis = rpf.num_docfis
--                                 AND r2010.rnk = 1 )
--                                AS "Observação."
--                          , ( SELECT INITCAP ( r2010."Tipo de Serviço E-social" )
--                                FROM msafi.tb_fin4816_reinf_2010_tmp r2010
--                               WHERE 1 = 1
--                                 AND r2010.cod_empresa = rpf.cod_empresa
--                                 AND r2010.cod_estab = rpf.cod_estab
--                                 AND r2010.dat_emissao = rpf.data_emissao
--                                 AND r2010.data_fiscal = rpf.data_fiscal
--                                 AND r2010.num_docfis = rpf.num_docfis
--                                 AND r2010.rnk = 1 )
--                                AS "Tipo de Serviço E-social."
--                          , ( SELECT ( r2010."Vlr. Base de Calc. Retenção" )
--                                FROM msafi.tb_fin4816_reinf_2010_tmp r2010
--                               WHERE 1 = 1
--                                 AND r2010.cod_empresa = rpf.cod_empresa
--                                 AND r2010.cod_estab = rpf.cod_estab
--                                 AND r2010.dat_emissao = rpf.data_emissao
--                                 AND r2010.data_fiscal = rpf.data_fiscal
--                                 AND r2010.num_docfis = rpf.num_docfis
--                                 AND r2010.rnk = 1 )
--                                AS "Vlr. Base de Calc. Retenção."
--                          , ( SELECT ( r2010."Valor da Retenção" )
--                                FROM msafi.tb_fin4816_reinf_2010_tmp r2010
--                               WHERE 1 = 1
--                                 AND r2010.cod_empresa = rpf.cod_empresa
--                                 AND r2010.cod_estab = rpf.cod_estab
--                                 AND r2010.dat_emissao = rpf.data_emissao
--                                 AND r2010.data_fiscal = rpf.data_fiscal
--                                 AND r2010.num_docfis = rpf.num_docfis
--                                 AND r2010.rnk = 1 )
--                                AS "Valor da Retenção."
--                       FROM msafi.tb_fin4816_report_fiscal_tmp rpf
--                     ORDER BY   cod_empresa
--                              , cod_estab
--                              , data_fiscal
--                              , movto_e_s
--                              , num_docfis
--                              , serie_docfis
--                              , sub_serie_docfis
--                              , num_item
--                          ;


     
        CURSOR rc_excel
        IS
               SELECT 
                     rpf.cod_empresa AS "Codigo da Empresa"
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
                   , NVL ( ( SELECT 'S'
                               FROM MSAFI.TB_FIN4816_REINF_PREV_GTT rprev
                              WHERE 1 = 1
                                AND rprev."Codigo Empresa" = rpf.cod_empresa
                                AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                                AND rprev."Data Fiscal" = rpf.data_fiscal
                                AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                                AND rprev.num_item = rpf.num_item )
                         , 'N' )
                         AS "DWT"
                   ---   campos do Report Previdenciario
                   , ( SELECT rprev."Codigo Estabelecimento"
                         FROM MSAFI.TB_FIN4816_REINF_PREV_GTT rprev
                        WHERE 1 = 1
                          AND rprev."Codigo Empresa" = rpf.cod_empresa
                          AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                          AND rprev."Data Fiscal" = rpf.data_fiscal
                          AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                          AND rprev.num_item = rpf.num_item )
                         AS empresa
                   , ( SELECT rprev."Codigo Estabelecimento"
                         FROM MSAFI.TB_FIN4816_REINF_PREV_GTT rprev
                        WHERE 1 = 1
                          AND rprev."Codigo Empresa" = rpf.cod_empresa
                          AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                          AND rprev."Data Fiscal" = rpf.data_fiscal
                          AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                          AND rprev.num_item = rpf.num_item )
                         AS "Codigo Estabelecimento"
                   , ( SELECT rprev."Codigo Pessoa Fisica/Juridica"
                         FROM MSAFI.TB_FIN4816_REINF_PREV_GTT rprev
                        WHERE 1 = 1
                          AND rprev."Codigo Empresa" = rpf.cod_empresa
                          AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                          AND rprev."Data Fiscal" = rpf.data_fiscal
                          AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                          AND rprev.num_item = rpf.num_item )
                         AS cod_pessoa_fis_jur
                   , ( SELECT rprev."Razão Social Cliente"
                         FROM MSAFI.TB_FIN4816_REINF_PREV_GTT rprev
                        WHERE 1 = 1
                          AND rprev."Codigo Empresa" = rpf.cod_empresa
                          AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                          AND rprev."Data Fiscal" = rpf.data_fiscal
                          AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                          AND rprev.num_item = rpf.num_item )
                         AS "Razão Social Cliente"
                   , ( SELECT rprev."CNPJ Cliente"
                         FROM MSAFI.TB_FIN4816_REINF_PREV_GTT rprev
                        WHERE 1 = 1
                          AND rprev."Codigo Empresa" = rpf.cod_empresa
                          AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                          AND rprev."Data Fiscal" = rpf.data_fiscal
                          AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                          AND rprev.num_item = rpf.num_item )
                         AS "CNPJ Cliente"
                   , ( SELECT rprev."Número da Nota Fiscal"
                         FROM MSAFI.TB_FIN4816_REINF_PREV_GTT rprev
                        WHERE 1 = 1
                          AND rprev."Codigo Empresa" = rpf.cod_empresa
                          AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                          AND rprev."Data Fiscal" = rpf.data_fiscal
                          AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                          AND rprev.num_item = rpf.num_item )
                         AS "Nro. Nota Fiscal"
                   , ( SELECT rprev."Emissão"
                         FROM MSAFI.TB_FIN4816_REINF_PREV_GTT rprev
                        WHERE 1 = 1
                          AND rprev."Codigo Empresa" = rpf.cod_empresa
                          AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                          AND rprev."Data Fiscal" = rpf.data_fiscal
                          AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                          AND rprev.num_item = rpf.num_item )
                         AS "Dt. Emissao"
                   , ( SELECT rprev."Data Fiscal"
                         FROM MSAFI.TB_FIN4816_REINF_PREV_GTT rprev
                        WHERE 1 = 1
                          AND rprev."Codigo Empresa" = rpf.cod_empresa
                          AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                          AND rprev."Data Fiscal" = rpf.data_fiscal
                          AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                          AND rprev.num_item = rpf.num_item )
                         AS "Dt. Fiscal"
                   , ( SELECT rprev.vlr_tot_nota
                         FROM MSAFI.TB_FIN4816_REINF_PREV_GTT rprev
                        WHERE 1 = 1
                          AND rprev."Codigo Empresa" = rpf.cod_empresa
                          AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                          AND rprev."Data Fiscal" = rpf.data_fiscal
                          AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                          AND rprev.num_item = rpf.num_item )
                         AS "Vlr. Total da Nota"
                   , ( SELECT rprev."Vlr Base Calc. Retenção"
                         FROM MSAFI.TB_FIN4816_REINF_PREV_GTT rprev
                        WHERE 1 = 1
                          AND rprev."Codigo Empresa" = rpf.cod_empresa
                          AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                          AND rprev."Data Fiscal" = rpf.data_fiscal
                          AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                          AND rprev.num_item = rpf.num_item )
                         AS "Vlr Base Calc. Retenção"
                   , ( SELECT rprev.vlr_aliq_inss
                         FROM MSAFI.TB_FIN4816_REINF_PREV_GTT rprev
                        WHERE 1 = 1
                          AND rprev."Codigo Empresa" = rpf.cod_empresa
                          AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                          AND rprev."Data Fiscal" = rpf.data_fiscal
                          AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                          AND rprev.num_item = rpf.num_item )
                         AS "Vlr. Aliquota INSS"
                   , ( SELECT rprev."Vlr.Trib INSS RETIDO"
                         FROM MSAFI.TB_FIN4816_REINF_PREV_GTT rprev
                        WHERE 1 = 1
                          AND rprev."Codigo Empresa" = rpf.cod_empresa
                          AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                          AND rprev."Data Fiscal" = rpf.data_fiscal
                          AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                          AND rprev.num_item = rpf.num_item )
                         AS "Vlr.Trib INSS RETIDO"
                   , ( SELECT rprev."Razão Social Drogaria"
                         FROM MSAFI.TB_FIN4816_REINF_PREV_GTT rprev
                        WHERE 1 = 1
                          AND rprev."Codigo Empresa" = rpf.cod_empresa
                          AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                          AND rprev."Data Fiscal" = rpf.data_fiscal
                          AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                          AND rprev.num_item = rpf.num_item )
                         AS "Razão Social Drogaria"
                   , ( SELECT rprev.cgc
                         FROM MSAFI.TB_FIN4816_REINF_PREV_GTT rprev
                        WHERE 1 = 1
                          AND rprev."Codigo Empresa" = rpf.cod_empresa
                          AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                          AND rprev."Data Fiscal" = rpf.data_fiscal
                          AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                          AND rprev.num_item = rpf.num_item )
                         AS "CNPJ Drogarias"
                   , ( SELECT rprev.cod_docto
                         FROM MSAFI.TB_FIN4816_REINF_PREV_GTT rprev
                        WHERE 1 = 1
                          AND rprev."Codigo Empresa" = rpf.cod_empresa
                          AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                          AND rprev."Data Fiscal" = rpf.data_fiscal
                          AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                          AND rprev.num_item = rpf.num_item )
                         AS "Descr. Tp. Documento"
                   , ( SELECT rprev."Tipo de Serviço E-social"
                         FROM MSAFI.TB_FIN4816_REINF_PREV_GTT rprev
                        WHERE 1 = 1
                          AND rprev."Codigo Empresa" = rpf.cod_empresa
                          AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                          AND rprev."Data Fiscal" = rpf.data_fiscal
                          AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                          AND rprev.num_item = rpf.num_item )
                         AS "Tp.Serv. E-social"
                   , ( SELECT rprev.dsc_tipo_serv_esocial
                         FROM MSAFI.TB_FIN4816_REINF_PREV_GTT rprev
                        WHERE 1 = 1
                          AND rprev."Codigo Empresa" = rpf.cod_empresa
                          AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                          AND rprev."Data Fiscal" = rpf.data_fiscal
                          AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                          AND rprev.num_item = rpf.num_item )
                         AS "Descr. Tp. Serv E-social"
                   , ( SELECT rprev."Valor do Servico"
                         FROM MSAFI.TB_FIN4816_REINF_PREV_GTT rprev
                        WHERE 1 = 1
                          AND rprev."Codigo Empresa" = rpf.cod_empresa
                          AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                          AND rprev."Data Fiscal" = rpf.data_fiscal
                          AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                          AND rprev.num_item = rpf.num_item )
                         AS "Vlr. do Servico"
                   , ( SELECT rprev.codigo_serv_prod
                         FROM MSAFI.TB_FIN4816_REINF_PREV_GTT rprev
                        WHERE 1 = 1
                          AND rprev."Codigo Empresa" = rpf.cod_empresa
                          AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                          AND rprev."Data Fiscal" = rpf.data_fiscal
                          AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                          AND rprev.num_item = rpf.num_item )
                         AS "Cod. Serv. Mastersaf"
                   , ( SELECT rprev.desc_serv_prod
                         FROM MSAFI.TB_FIN4816_REINF_PREV_GTT rprev
                        WHERE 1 = 1
                          AND rprev."Codigo Empresa" = rpf.cod_empresa
                          AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                          AND rprev."Data Fiscal" = rpf.data_fiscal
                          AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                          AND rprev.num_item = rpf.num_item )
                         AS "Descr. Serv. Mastersaf"
                   ---
                   -- REINF  EVENTO R2010
                   ---
                   , ( SELECT r2010.cod_empresa
                         FROM MSAFI.TB_FIN4816_REINF_2010_GTT r2010
                        WHERE 1 = 1
                          AND r2010.cod_empresa = rpf.cod_empresa
                          AND r2010.cod_estab = rpf.cod_estab
                          AND r2010.dat_emissao = rpf.data_emissao
                          AND r2010.data_fiscal = rpf.data_fiscal
                          AND r2010.num_docfis = rpf.num_docfis
                          AND r2010.rnk = 1 )
                         AS "Codigo Empresa"
                   , ( SELECT INITCAP ( r2010."Razão Social Drogaria" )
                         FROM MSAFI.TB_FIN4816_REINF_2010_GTT r2010
                        WHERE 1 = 1
                          AND r2010.cod_empresa = rpf.cod_empresa
                          AND r2010.cod_estab = rpf.cod_estab
                          AND r2010.dat_emissao = rpf.data_emissao
                          AND r2010.data_fiscal = rpf.data_fiscal
                          AND r2010.num_docfis = rpf.num_docfis
                          AND r2010.rnk = 1 )
                         AS "Razão Social Drogaria."
                   , ( SELECT INITCAP ( r2010."Razão Social Cliente" )
                         FROM MSAFI.TB_FIN4816_REINF_2010_GTT r2010
                        WHERE 1 = 1
                          AND r2010.cod_empresa = rpf.cod_empresa
                          AND r2010.cod_estab = rpf.cod_estab
                          AND r2010.dat_emissao = rpf.data_emissao
                          AND r2010.data_fiscal = rpf.data_fiscal
                          AND r2010.num_docfis = rpf.num_docfis
                          AND r2010.rnk = 1 )
                         AS "Razão Social Cliente."
                   , ( SELECT ( r2010."Número da Nota Fiscal" )
                         FROM MSAFI.TB_FIN4816_REINF_2010_GTT r2010
                        WHERE 1 = 1
                          AND r2010.cod_empresa = rpf.cod_empresa
                          AND r2010.cod_estab = rpf.cod_estab
                          AND r2010.dat_emissao = rpf.data_emissao
                          AND r2010.data_fiscal = rpf.data_fiscal
                          AND r2010.num_docfis = rpf.num_docfis
                          AND r2010.rnk = 1 )
                         AS "Número da Nota Fiscal."
                   , ( SELECT ( r2010."Data de Emissão da NF" )
                         FROM MSAFI.TB_FIN4816_REINF_2010_GTT r2010
                        WHERE 1 = 1
                          AND r2010.cod_empresa = rpf.cod_empresa
                          AND r2010.cod_estab = rpf.cod_estab
                          AND r2010.dat_emissao = rpf.data_emissao
                          AND r2010.data_fiscal = rpf.data_fiscal
                          AND r2010.num_docfis = rpf.num_docfis
                          AND r2010.rnk = 1 )
                         AS "Data de Emissão da NF."
                   --
                   , ( SELECT ( r2010."Data Fiscal" )
                         FROM MSAFI.TB_FIN4816_REINF_2010_GTT r2010
                        WHERE 1 = 1
                          AND r2010.cod_empresa = rpf.cod_empresa
                          AND r2010.cod_estab = rpf.cod_estab
                          AND r2010.dat_emissao = rpf.data_emissao
                          AND r2010.data_fiscal = rpf.data_fiscal
                          AND r2010.num_docfis = rpf.num_docfis
                          AND r2010.rnk = 1 )
                         AS "Data Fiscal."
                   --
                   , ( SELECT ( r2010."Valor do Tributo" )
                         FROM MSAFI.TB_FIN4816_REINF_2010_GTT r2010
                        WHERE 1 = 1
                          AND r2010.cod_empresa = rpf.cod_empresa
                          AND r2010.cod_estab = rpf.cod_estab
                          AND r2010.dat_emissao = rpf.data_emissao
                          AND r2010.data_fiscal = rpf.data_fiscal
                          AND r2010.num_docfis = rpf.num_docfis
                          AND r2010.rnk = 1 )
                         AS "Valor do Tributo."
                   , ( SELECT INITCAP ( r2010."observacao" )
                         FROM MSAFI.TB_FIN4816_REINF_2010_GTT r2010
                        WHERE 1 = 1
                          AND r2010.cod_empresa = rpf.cod_empresa
                          AND r2010.cod_estab = rpf.cod_estab
                          AND r2010.dat_emissao = rpf.data_emissao
                          AND r2010.data_fiscal = rpf.data_fiscal
                          AND r2010.num_docfis = rpf.num_docfis
                          AND r2010.rnk = 1 )
                         AS "Observação."
                   , ( SELECT INITCAP ( r2010."Tipo de Serviço E-social" )
                         FROM MSAFI.TB_FIN4816_REINF_2010_GTT r2010
                        WHERE 1 = 1
                          AND r2010.cod_empresa = rpf.cod_empresa
                          AND r2010.cod_estab = rpf.cod_estab
                          AND r2010.dat_emissao = rpf.data_emissao
                          AND r2010.data_fiscal = rpf.data_fiscal
                          AND r2010.num_docfis = rpf.num_docfis
                          AND r2010.rnk = 1 )
                         AS "Tipo de Serviço E-social."
                   , ( SELECT ( r2010."Vlr. Base de Calc. Retenção" )
                         FROM MSAFI.TB_FIN4816_REINF_2010_GTT r2010
                        WHERE 1 = 1
                          AND r2010.cod_empresa = rpf.cod_empresa
                          AND r2010.cod_estab = rpf.cod_estab
                          AND r2010.dat_emissao = rpf.data_emissao
                          AND r2010.data_fiscal = rpf.data_fiscal
                          AND r2010.num_docfis = rpf.num_docfis
                          AND r2010.rnk = 1 )
                         AS "Vlr. Base de Calc. Retenção."
                   , ( SELECT ( r2010."Valor da Retenção" )
                         FROM MSAFI.TB_FIN4816_REINF_2010_GTT r2010
                        WHERE 1 = 1
                          AND r2010.cod_empresa = rpf.cod_empresa
                          AND r2010.cod_estab = rpf.cod_estab
                          AND r2010.dat_emissao = rpf.data_emissao
                          AND r2010.data_fiscal = rpf.data_fiscal
                          AND r2010.num_docfis = rpf.num_docfis
                          AND r2010.rnk = 1 )
                         AS "Valor da Retenção."
                FROM msafi.tb_fin4816_report_fiscal_gtt rpf
            ORDER BY cod_empresa
                   , cod_estab
                   , data_fiscal
                   , movto_e_s
                   , num_docfis
                   , serie_docfis
                   , sub_serie_docfis
                   , num_item;



    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );
    BEGIN
        mnm_usuario := lib_parametros.recuperar ( UPPER ( 'USUARIO' ) );
        mcod_empresa := lib_parametros.recuperar ( UPPER ( 'EMPRESA' ) );

        lib_proc.add_param ( pparam => pstr
                           , ptitulo => 'Data Inicial'
                           , ptipo => 'DATE'
                           , pcontrole => 'textbox'
                           , pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => 'DD/MM/YYYY' );


        lib_proc.add_param ( pparam => pstr
                           , ptitulo => 'Data Final'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'COMBOBOX'
                           , pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => '##########'
                           , pvalores => v_sel_data_fim );

        -- PCOD_ESTAB
        lib_proc.add_param (
                             pstr
                           , 'Estabelecimento'
                           , --PCOD_ESTAB
                            'VARCHAR2'
                           , 'MULTISELECT'
                           , 'S'
                           , 'S'
                           , NULL
                           ,    ' SELECT A.COD_ESTAB,A.COD_ESTAB || '' - '' || B.COD_ESTADO || '' - '' || A.CGC || '' - '' || INITCAP(A.BAIRRO) || '' / '' || INITCAP(A.CIDADE) '
                             || ' FROM ESTABELECIMENTO A, ESTADO B, MSAFI.DSP_ESTABELECIMENTO C '
                             || ' WHERE 1=1 '
                             || --
                               ' AND A.COD_EMPRESA  = '''
                             || mcod_empresa
                             || ''''
                             || ' AND B.IDENT_ESTADO = A.IDENT_ESTADO '
                             || ' AND A.COD_EMPRESA  = C.COD_EMPRESA '
                             || ' AND A.COD_ESTAB    = C.COD_ESTAB '
                             || -- ' AND C.TIPO         = ''L'' ' ||
                               ' ORDER BY A.COD_ESTAB  '
        );

        RETURN pstr;
    END;

    FUNCTION tipo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN mnm_tipo;
    END;

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN mnm_cproc;
    END;

    FUNCTION descricao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN mds_cproc;
    END;

    FUNCTION versao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN '1.0';
    END;

    FUNCTION modulo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Customizados';
    END;

    FUNCTION classificacao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Customizados';
    END;

    FUNCTION orientacao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'PORTRAIT';
    END;

    PROCEDURE loga ( p_i_texto IN VARCHAR2
                   , p_i_dttm IN BOOLEAN DEFAULT TRUE )
    IS
        vtexto VARCHAR2 ( 1024 );
    BEGIN
        IF p_i_dttm THEN
            vtexto :=
                SUBSTR (    TO_CHAR ( SYSDATE
                                    , 'DD/MM/YYYY HH24:MI:SS' )
                         || ' - '
                         || p_i_texto
                       , 1
                       , 1024 );
        ELSE
            vtexto :=
                SUBSTR ( p_i_texto
                       , 1
                       , 1024 );
        END IF;

        lib_proc.add_log ( vtexto
                         , 1 );
        COMMIT;
    END loga;



 
    
        PROCEDURE prc_reinf_conf_retencao ( p_cod_empresa IN VARCHAR2
                                      , p_cod_estab IN VARCHAR2 DEFAULT NULL
                                      , p_tipo_selec IN VARCHAR2
                                      , p_data_inicial IN DATE
                                      , p_data_final IN DATE
                                      , p_cod_usuario IN VARCHAR2
                                      , p_entrada_saida IN VARCHAR2
                                      , p_status   OUT NUMBER
                                      , p_proc_id IN VARCHAR2 DEFAULT NULL )
    IS
        cod_empresa_w estabelecimento.cod_empresa%TYPE;
        cod_estab_w estabelecimento.cod_estab%TYPE;
        data_ini_w DATE;
        data_fim_w DATE;

        --  PREVISÃO DOS RETIDOS (1) = 'E'
        CURSOR c_conf_ret_prev ( p_cod_empresa VARCHAR2
                               , p_cod_estab VARCHAR2
                               , p_data_inicial DATE
                               , p_data_final DATE )
        IS
            SELECT doc_fis.data_emissao
                 , doc_fis.data_fiscal
                 , doc_fis.ident_fis_jur
                 , doc_fis.ident_docto
                 , doc_fis.num_docfis
                 , doc_fis.serie_docfis
                 , doc_fis.sub_serie_docfis
                 , tipo_serv.ident_tipo_serv_esocial
                 , doc_fis.cod_class_doc_fis
                 , doc_fis.vlr_tot_nota
                 , doc_fis.vlr_contab_compl
                 , dwt_itens.vlr_base_inss
                 , dwt_itens.vlr_aliq_inss
                 , dwt_itens.vlr_inss_retido
                 , x2058.ind_tp_proc_adj
                 , x2058.num_proc_adj
                 , dwt_itens.num_item
                 , dwt_itens.vlr_servico
                 , x2058_adic.ind_tp_proc_adj
                 , x2058_adic.num_proc_adj
                 , dwt_itens.ident_servico
                 , NULL
                 , NULL
              FROM dwt_docto_fiscal doc_fis
                 , dwt_itens_serv dwt_itens
                 , x2018_servicos x2018
                 , prt_id_tipo_serv_esocial id_tipo_serv
                 , prt_tipo_serv_esocial tipo_serv
                 , x2058_proc_adj x2058
                 , x2058_proc_adj x2058_adic
             WHERE 1 = 1
               AND doc_fis.cod_empresa = dwt_itens.cod_empresa
               AND doc_fis.cod_estab = dwt_itens.cod_estab
               AND doc_fis.data_fiscal = dwt_itens.data_fiscal
               AND doc_fis.ident_fis_jur = dwt_itens.ident_fis_jur
               AND doc_fis.ident_docto = dwt_itens.ident_docto
               AND doc_fis.num_docfis = dwt_itens.num_docfis
               AND doc_fis.serie_docfis = dwt_itens.serie_docfis
               AND doc_fis.sub_serie_docfis = dwt_itens.sub_serie_docfis
               AND dwt_itens.ident_proc_adj_princ = x2058.ident_proc_adj(+)
               AND dwt_itens.ident_proc_adj_adic = x2058_adic.ident_proc_adj(+)
               AND id_tipo_serv.cod_empresa = doc_fis.cod_empresa
               AND id_tipo_serv.cod_estab = doc_fis.cod_estab
               AND dwt_itens.ident_servico = x2018.ident_servico
               AND x2018.grupo_servico = id_tipo_serv.grupo_servico
               AND x2018.cod_servico = id_tipo_serv.cod_servico
               AND id_tipo_serv.cod_tipo_serv_esocial = tipo_serv.cod_tipo_serv_esocial
               AND tipo_serv.data_ini_vigencia = (SELECT MAX ( a.data_ini_vigencia )
                                                    FROM prt_tipo_serv_esocial a
                                                   WHERE a.cod_tipo_serv_esocial = tipo_serv.cod_tipo_serv_esocial
                                                     AND a.data_ini_vigencia <= p_data_final)
               AND doc_fis.dat_cancelamento IS NULL
               AND doc_fis.cod_class_doc_fis IN ( '2'
                                                , '3' )
               AND doc_fis.norm_dev = '1'
               AND ( ( doc_fis.movto_e_s < '9'
                  AND p_entrada_saida = 'E' )
                 OR ( doc_fis.movto_e_s = '9'
                 AND p_entrada_saida = 'S' ) )
               AND NVL ( dwt_itens.vlr_inss_retido, 0 ) > 0
               AND doc_fis.situacao = 'N'
               AND doc_fis.cod_empresa = p_cod_empresa
               AND doc_fis.cod_estab = p_cod_estab
               AND doc_fis.data_emissao >= p_data_inicial
               AND doc_fis.data_emissao <= p_data_final
            UNION ALL
            SELECT doc_fis.data_emissao
                 , doc_fis.data_fiscal
                 , doc_fis.ident_fis_jur
                 , doc_fis.ident_docto
                 , doc_fis.num_docfis
                 , doc_fis.serie_docfis
                 , doc_fis.sub_serie_docfis
                 , NULL
                 , doc_fis.cod_class_doc_fis
                 , doc_fis.vlr_tot_nota
                 , doc_fis.vlr_contab_compl
                 , dwt_itens.vlr_base_inss
                 , dwt_itens.vlr_aliq_inss
                 , dwt_itens.vlr_inss_retido
                 , x2058.ind_tp_proc_adj
                 , x2058.num_proc_adj
                 , dwt_itens.num_item
                 , dwt_itens.vlr_servico
                 , x2058_adic.ind_tp_proc_adj
                 , x2058_adic.num_proc_adj
                 , dwt_itens.ident_servico
                 , NULL
                 , prt_par2_msaf.cod_param
              FROM dwt_docto_fiscal doc_fis
                 , dwt_itens_serv dwt_itens
                 , x2018_servicos x2018
                 , prt_serv_msaf
                 , prt_par2_msaf
                 , x2058_proc_adj x2058
                 , x2058_proc_adj x2058_adic
             WHERE 1 = 1
               AND doc_fis.cod_estab = dwt_itens.cod_estab
               AND doc_fis.data_fiscal = dwt_itens.data_fiscal
               AND doc_fis.ident_fis_jur = dwt_itens.ident_fis_jur
               AND doc_fis.ident_docto = dwt_itens.ident_docto
               AND doc_fis.num_docfis = dwt_itens.num_docfis
               AND doc_fis.serie_docfis = dwt_itens.serie_docfis
               AND doc_fis.sub_serie_docfis = dwt_itens.sub_serie_docfis
               AND dwt_itens.ident_proc_adj_princ = x2058.ident_proc_adj(+)
               AND dwt_itens.ident_proc_adj_adic = x2058_adic.ident_proc_adj(+)
               AND prt_serv_msaf.cod_empresa = doc_fis.cod_empresa
               AND prt_serv_msaf.cod_estab = doc_fis.cod_estab
               AND dwt_itens.ident_servico = x2018.ident_servico
               AND x2018.grupo_servico = prt_serv_msaf.grupo_servico
               AND x2018.cod_servico = prt_serv_msaf.cod_servico
               AND prt_serv_msaf.cod_param = prt_par2_msaf.cod_param
               AND prt_serv_msaf.cod_param IN ( 683
                                              , 684
                                              , 685
                                              , 686
                                              , 690 )
               AND doc_fis.dat_cancelamento IS NULL
               AND doc_fis.cod_class_doc_fis IN ( '2'
                                                , '3' )
               AND doc_fis.norm_dev = '1'
               AND ( ( doc_fis.movto_e_s < '9'
                  AND p_entrada_saida = 'E' )
                 OR ( doc_fis.movto_e_s = '9'
                 AND p_entrada_saida = 'S' ) )
               AND NVL ( dwt_itens.vlr_inss_retido, 0 ) > 0
               AND doc_fis.situacao = 'N'
               AND doc_fis.cod_empresa = p_cod_empresa
               AND doc_fis.cod_estab = p_cod_estab
               AND doc_fis.data_emissao >= p_data_inicial
               AND doc_fis.data_emissao <= p_data_final
            UNION ALL
            SELECT doc_fis.data_emissao
                 , doc_fis.data_fiscal
                 , doc_fis.ident_fis_jur
                 , doc_fis.ident_docto
                 , doc_fis.num_docfis
                 , doc_fis.serie_docfis
                 , doc_fis.sub_serie_docfis
                 , tipo_serv.ident_tipo_serv_esocial
                 , doc_fis.cod_class_doc_fis
                 , doc_fis.vlr_tot_nota
                 , doc_fis.vlr_contab_compl
                 , dwt_merc.vlr_base_inss
                 , dwt_merc.vlr_aliq_inss
                 , dwt_merc.vlr_inss_retido
                 , x2058.ind_tp_proc_adj
                 , x2058.num_proc_adj
                 , dwt_merc.num_item
                 , dwt_merc.vlr_item
                 , x2058_adic.ind_tp_proc_adj
                 , x2058_adic.num_proc_adj
                 , NULL
                 , dwt_merc.ident_produto
                 , NULL
              FROM dwt_docto_fiscal doc_fis
                 , dwt_itens_merc dwt_merc
                 , x2013_produto x2013
                 , prt_id_tipo_serv_prod id_tipo_serv
                 , prt_tipo_serv_esocial tipo_serv
                 , x2058_proc_adj x2058
                 , x2058_proc_adj x2058_adic
                 , x2024_modelo_docto x2024
             WHERE 1 = 1
               AND doc_fis.cod_empresa = dwt_merc.cod_empresa
               AND doc_fis.cod_estab = dwt_merc.cod_estab
               AND doc_fis.data_fiscal = dwt_merc.data_fiscal
               AND doc_fis.ident_fis_jur = dwt_merc.ident_fis_jur
               AND doc_fis.ident_docto = dwt_merc.ident_docto
               AND doc_fis.num_docfis = dwt_merc.num_docfis
               AND doc_fis.serie_docfis = dwt_merc.serie_docfis
               AND doc_fis.sub_serie_docfis = dwt_merc.sub_serie_docfis
               AND doc_fis.ident_modelo = x2024.ident_modelo
               AND x2024.cod_modelo IN ( '07'
                                       , '67' )
               AND dwt_merc.ident_proc_adj_princ = x2058.ident_proc_adj(+)
               AND dwt_merc.ident_proc_adj_adic = x2058_adic.ident_proc_adj(+)
               AND id_tipo_serv.cod_empresa = doc_fis.cod_empresa
               AND id_tipo_serv.cod_estab = doc_fis.cod_estab
               AND dwt_merc.ident_produto = x2013.ident_produto
               AND id_tipo_serv.grupo_produto = x2013.grupo_produto
               AND id_tipo_serv.cod_produto = x2013.cod_produto
               AND id_tipo_serv.ind_produto = x2013.ind_produto
               AND id_tipo_serv.cod_tipo_serv_esocial = tipo_serv.cod_tipo_serv_esocial
               AND tipo_serv.data_ini_vigencia = (SELECT MAX ( a.data_ini_vigencia )
                                                    FROM prt_tipo_serv_esocial a
                                                   WHERE a.cod_tipo_serv_esocial = tipo_serv.cod_tipo_serv_esocial
                                                     AND a.data_ini_vigencia <= p_data_final)
               AND doc_fis.dat_cancelamento IS NULL
               AND doc_fis.cod_class_doc_fis IN ( '1'
                                                , '3' )
               AND doc_fis.norm_dev = '1'
               AND ( ( doc_fis.movto_e_s < '9'
                  AND p_entrada_saida = 'E' )
                 OR ( doc_fis.movto_e_s = '9'
                 AND p_entrada_saida = 'S' ) )
               AND NVL ( dwt_merc.vlr_inss_retido, 0 ) > 0
               AND doc_fis.situacao = 'N'
               AND doc_fis.cod_empresa = p_cod_empresa
               AND doc_fis.cod_estab = p_cod_estab
               AND doc_fis.data_emissao >= p_data_inicial
               AND doc_fis.data_emissao <= p_data_final;



        CURSOR c_conf_sem_tipo_serv ( p_cod_empresa VARCHAR2
                                    , p_cod_estab VARCHAR2
                                    , p_data_inicial DATE
                                    , p_data_final DATE )
        IS
            SELECT doc_fis.data_emissao
                 , doc_fis.data_fiscal
                 , doc_fis.ident_fis_jur
                 , doc_fis.ident_docto
                 , doc_fis.num_docfis
                 , doc_fis.serie_docfis
                 , doc_fis.sub_serie_docfis
                 , NULL
                 , doc_fis.cod_class_doc_fis
                 , doc_fis.vlr_tot_nota
                 , doc_fis.vlr_contab_compl
                 , dwt_itens.vlr_base_inss
                 , dwt_itens.vlr_aliq_inss
                 , dwt_itens.vlr_inss_retido
                 , x2058.ind_tp_proc_adj
                 , x2058.num_proc_adj
                 , dwt_itens.num_item
                 , dwt_itens.vlr_servico
                 , x2058_adic.ind_tp_proc_adj
                 , x2058_adic.num_proc_adj
                 , dwt_itens.ident_servico
                 , NULL
                 , NULL
              FROM dwt_docto_fiscal doc_fis
                 , dwt_itens_serv dwt_itens
                 , x2058_proc_adj x2058
                 , x2058_proc_adj x2058_adic
             WHERE doc_fis.cod_empresa = dwt_itens.cod_empresa
               AND doc_fis.cod_estab = dwt_itens.cod_estab
               AND doc_fis.data_fiscal = dwt_itens.data_fiscal
               AND doc_fis.ident_fis_jur = dwt_itens.ident_fis_jur
               AND doc_fis.ident_docto = dwt_itens.ident_docto
               AND doc_fis.num_docfis = dwt_itens.num_docfis
               AND doc_fis.serie_docfis = dwt_itens.serie_docfis
               AND doc_fis.sub_serie_docfis = dwt_itens.sub_serie_docfis
               AND dwt_itens.ident_proc_adj_princ = x2058.ident_proc_adj(+)
               AND dwt_itens.ident_proc_adj_adic = x2058_adic.ident_proc_adj(+)
               AND NOT EXISTS
                       (SELECT 1
                          FROM prt_id_tipo_serv_esocial a
                             , x2018_servicos x2018
                         WHERE a.cod_empresa = dwt_itens.cod_empresa
                           AND a.cod_estab = dwt_itens.cod_estab
                           AND x2018.ident_servico = dwt_itens.ident_servico
                           AND a.grupo_servico = x2018.grupo_servico
                           AND a.cod_servico = x2018.cod_servico)
               AND NOT EXISTS
                       (SELECT 1
                          FROM prt_serv_msaf a
                             , x2018_servicos x2018
                         WHERE a.cod_empresa = dwt_itens.cod_empresa
                           AND a.cod_estab = dwt_itens.cod_estab
                           AND x2018.ident_servico = dwt_itens.ident_servico
                           AND a.grupo_servico = x2018.grupo_servico
                           AND a.cod_servico = x2018.cod_servico
                           AND a.cod_param IN ( 683
                                              , 684
                                              , 685
                                              , 686
                                              , 690 ))
               AND doc_fis.dat_cancelamento IS NULL
               AND doc_fis.cod_class_doc_fis IN ( '2'
                                                , '3' )
               AND doc_fis.norm_dev = '1'
               AND ( ( doc_fis.movto_e_s < '9'
                  AND p_entrada_saida = 'E' )
                 OR ( doc_fis.movto_e_s = '9'
                 AND p_entrada_saida = 'S' ) )
               AND NVL ( dwt_itens.vlr_inss_retido, 0 ) > 0
               AND doc_fis.situacao = 'N'
               AND doc_fis.cod_empresa = p_cod_empresa
               AND doc_fis.cod_estab = p_cod_estab
               AND doc_fis.data_emissao >= p_data_inicial
               AND doc_fis.data_emissao <= p_data_final
            UNION ALL
            SELECT doc_fis.data_emissao
                 , doc_fis.data_fiscal
                 , doc_fis.ident_fis_jur
                 , doc_fis.ident_docto
                 , doc_fis.num_docfis
                 , doc_fis.serie_docfis
                 , doc_fis.sub_serie_docfis
                 , NULL
                 , doc_fis.cod_class_doc_fis
                 , doc_fis.vlr_tot_nota
                 , doc_fis.vlr_contab_compl
                 , dwt_merc.vlr_base_inss
                 , dwt_merc.vlr_aliq_inss
                 , dwt_merc.vlr_inss_retido
                 , x2058.ind_tp_proc_adj
                 , x2058.num_proc_adj
                 , dwt_merc.num_item
                 , dwt_merc.vlr_item
                 , x2058_adic.ind_tp_proc_adj
                 , x2058_adic.num_proc_adj
                 , NULL
                 , dwt_merc.ident_produto
                 , NULL
              FROM dwt_docto_fiscal doc_fis
                 , dwt_itens_merc dwt_merc
                 , x2058_proc_adj x2058
                 , x2058_proc_adj x2058_adic
                 , x2024_modelo_docto x2024
             WHERE doc_fis.cod_empresa = dwt_merc.cod_empresa
               AND doc_fis.cod_estab = dwt_merc.cod_estab
               AND doc_fis.data_fiscal = dwt_merc.data_fiscal
               AND doc_fis.ident_fis_jur = dwt_merc.ident_fis_jur
               AND doc_fis.ident_docto = dwt_merc.ident_docto
               AND doc_fis.num_docfis = dwt_merc.num_docfis
               AND doc_fis.serie_docfis = dwt_merc.serie_docfis
               AND doc_fis.sub_serie_docfis = dwt_merc.sub_serie_docfis
               AND doc_fis.ident_modelo = x2024.ident_modelo
               AND x2024.cod_modelo IN ( '07'
                                       , '67' )
               AND dwt_merc.ident_proc_adj_princ = x2058.ident_proc_adj(+)
               AND dwt_merc.ident_proc_adj_adic = x2058_adic.ident_proc_adj(+)
               AND NOT EXISTS
                       (SELECT 1
                          FROM prt_id_tipo_serv_prod p
                             , x2013_produto x2013
                         WHERE p.cod_empresa = dwt_merc.cod_empresa
                           AND p.cod_estab = dwt_merc.cod_estab
                           AND x2013.ident_produto = dwt_merc.ident_produto
                           AND p.grupo_produto = x2013.grupo_produto
                           AND p.cod_produto = x2013.cod_produto
                           AND p.ind_produto = x2013.ind_produto)
               AND doc_fis.dat_cancelamento IS NULL
               AND doc_fis.cod_class_doc_fis IN ( '1'
                                                , '3' )
               AND doc_fis.norm_dev = '1'
               AND ( ( doc_fis.movto_e_s < '9'
                  AND p_entrada_saida = 'E' )
                 OR ( doc_fis.movto_e_s = '9'
                 AND p_entrada_saida = 'S' ) )
               AND NVL ( dwt_merc.vlr_inss_retido, 0 ) > 0
               AND doc_fis.situacao = 'N'
               AND doc_fis.cod_empresa = p_cod_empresa
               AND doc_fis.cod_estab = p_cod_estab
               AND doc_fis.data_emissao >= p_data_inicial
               AND doc_fis.data_emissao <= p_data_final;



        CURSOR c_conf_ret_prev_proc ( p_cod_empresa VARCHAR2
                                    , p_cod_estab VARCHAR2
                                    , p_data_inicial DATE
                                    , p_data_final DATE )
        IS
            SELECT DISTINCT doc_fis.data_emissao
                          , doc_fis.data_fiscal
                          , doc_fis.ident_fis_jur
                          , doc_fis.ident_docto
                          , doc_fis.num_docfis
                          , doc_fis.serie_docfis
                          , doc_fis.sub_serie_docfis
                          , NULL
                          , doc_fis.cod_class_doc_fis
                          , doc_fis.vlr_tot_nota
                          , doc_fis.vlr_contab_compl
                          , dwt_itens.vlr_base_inss
                          , dwt_itens.vlr_aliq_inss
                          , dwt_itens.vlr_inss_retido
                          , x2058.ind_tp_proc_adj
                          , x2058.num_proc_adj
                          , dwt_itens.num_item
                          , dwt_itens.vlr_servico
                          , x2058_adic.ind_tp_proc_adj
                          , x2058_adic.num_proc_adj
                          , dwt_itens.ident_servico
                          , NULL
                          , NULL
              FROM dwt_docto_fiscal doc_fis
                 , dwt_itens_serv dwt_itens
                 , x2018_servicos x2018
                 , x2018_servicos x2018_adic
                 , x2058_proc_adj x2058
                 , x2058_proc_adj x2058_adic
             WHERE doc_fis.cod_empresa = dwt_itens.cod_empresa
               AND doc_fis.cod_estab = dwt_itens.cod_estab
               AND doc_fis.data_fiscal = dwt_itens.data_fiscal
               AND doc_fis.ident_fis_jur = dwt_itens.ident_fis_jur
               AND doc_fis.ident_docto = dwt_itens.ident_docto
               AND doc_fis.num_docfis = dwt_itens.num_docfis
               AND doc_fis.serie_docfis = dwt_itens.serie_docfis
               AND doc_fis.sub_serie_docfis = dwt_itens.sub_serie_docfis
               AND dwt_itens.ident_proc_adj_princ = x2058.ident_proc_adj(+)
               AND dwt_itens.ident_proc_adj_adic = x2058_adic.ident_proc_adj(+)
               AND dwt_itens.ident_servico = x2018.ident_servico
               AND doc_fis.dat_cancelamento IS NULL
               AND doc_fis.cod_class_doc_fis IN ( '2'
                                                , '3' )
               AND doc_fis.norm_dev = '1'
               AND ( ( doc_fis.movto_e_s < '9'
                  AND p_entrada_saida = 'E' )
                 OR ( doc_fis.movto_e_s = '9'
                 AND p_entrada_saida = 'S' ) )
               AND ( x2058.num_proc_adj IS NOT NULL
                 OR x2058_adic.num_proc_adj IS NOT NULL )
               AND NVL ( dwt_itens.vlr_inss_retido, 0 ) > 0
               AND doc_fis.situacao = 'N'
               AND doc_fis.cod_empresa = p_cod_empresa
               AND doc_fis.cod_estab = p_cod_estab
               AND doc_fis.data_emissao >= p_data_inicial
               AND doc_fis.data_emissao <= p_data_final
            UNION ALL
            SELECT doc_fis.data_emissao
                 , doc_fis.data_fiscal
                 , doc_fis.ident_fis_jur
                 , doc_fis.ident_docto
                 , doc_fis.num_docfis
                 , doc_fis.serie_docfis
                 , doc_fis.sub_serie_docfis
                 , NULL
                 , doc_fis.cod_class_doc_fis
                 , doc_fis.vlr_tot_nota
                 , doc_fis.vlr_contab_compl
                 , dwt_merc.vlr_base_inss
                 , dwt_merc.vlr_aliq_inss
                 , dwt_merc.vlr_inss_retido
                 , x2058.ind_tp_proc_adj
                 , x2058.num_proc_adj
                 , dwt_merc.num_item
                 , dwt_merc.vlr_item
                 , x2058_adic.ind_tp_proc_adj
                 , x2058_adic.num_proc_adj
                 , NULL
                 , dwt_merc.ident_produto
                 , NULL
              FROM dwt_docto_fiscal doc_fis
                 , dwt_itens_merc dwt_merc
                 , x2013_produto x2013
                 , x2058_proc_adj x2058
                 , x2058_proc_adj x2058_adic
                 , x2024_modelo_docto x2024
             WHERE doc_fis.cod_empresa = dwt_merc.cod_empresa
               AND doc_fis.cod_estab = dwt_merc.cod_estab
               AND doc_fis.data_fiscal = dwt_merc.data_fiscal
               AND doc_fis.ident_fis_jur = dwt_merc.ident_fis_jur
               AND doc_fis.ident_docto = dwt_merc.ident_docto
               AND doc_fis.num_docfis = dwt_merc.num_docfis
               AND doc_fis.serie_docfis = dwt_merc.serie_docfis
               AND doc_fis.sub_serie_docfis = dwt_merc.sub_serie_docfis
               AND doc_fis.ident_modelo = x2024.ident_modelo
               AND x2024.cod_modelo IN ( '07'
                                       , '67' )
               AND dwt_merc.ident_proc_adj_princ = x2058.ident_proc_adj(+)
               AND dwt_merc.ident_proc_adj_adic = x2058_adic.ident_proc_adj(+)
               AND dwt_merc.ident_produto = x2013.ident_produto
               AND doc_fis.dat_cancelamento IS NULL
               AND doc_fis.cod_class_doc_fis IN ( '1'
                                                , '3' )
               AND doc_fis.norm_dev = '1'
               AND ( ( doc_fis.movto_e_s < '9'
                  AND p_entrada_saida = 'E' )
                 OR ( doc_fis.movto_e_s = '9'
                 AND p_entrada_saida = 'S' ) )
               AND ( x2058.num_proc_adj IS NOT NULL
                 OR x2058_adic.num_proc_adj IS NOT NULL )
               AND NVL ( dwt_merc.vlr_inss_retido, 0 ) > 0
               AND doc_fis.situacao = 'N'
               AND doc_fis.cod_empresa = p_cod_empresa
               AND doc_fis.cod_estab = p_cod_estab
               AND doc_fis.data_emissao >= p_data_inicial
               AND doc_fis.data_emissao <= p_data_final;



        CURSOR c_conf_ret_prev_sem_proc ( p_cod_empresa VARCHAR2
                                        , p_cod_estab VARCHAR2
                                        , p_data_inicial DATE
                                        , p_data_final DATE )
        IS
            SELECT doc_fis.data_emissao
                 , doc_fis.data_fiscal
                 , doc_fis.ident_fis_jur
                 , doc_fis.ident_docto
                 , doc_fis.num_docfis
                 , doc_fis.serie_docfis
                 , doc_fis.sub_serie_docfis
                 , NULL
                 , doc_fis.cod_class_doc_fis
                 , doc_fis.vlr_tot_nota
                 , doc_fis.vlr_contab_compl
                 , dwt_itens.vlr_base_inss
                 , dwt_itens.vlr_aliq_inss
                 , dwt_itens.vlr_inss_retido
                 , dwt_itens.ind_tp_proc_adj_princ
                 , NULL
                 , dwt_itens.num_item
                 , dwt_itens.vlr_servico
                 , dwt_itens.ind_tp_proc_adj_princ
                 , NULL
                 , dwt_itens.ident_servico
                 , NULL
                 , NULL
              FROM dwt_docto_fiscal doc_fis
                 , dwt_itens_serv dwt_itens
                 , x2018_servicos x2018
             WHERE doc_fis.cod_empresa = dwt_itens.cod_empresa
               AND doc_fis.cod_estab = dwt_itens.cod_estab
               AND doc_fis.data_fiscal = dwt_itens.data_fiscal
               AND doc_fis.ident_fis_jur = dwt_itens.ident_fis_jur
               AND doc_fis.ident_docto = dwt_itens.ident_docto
               AND doc_fis.num_docfis = dwt_itens.num_docfis
               AND doc_fis.serie_docfis = dwt_itens.serie_docfis
               AND doc_fis.sub_serie_docfis = dwt_itens.sub_serie_docfis
               AND dwt_itens.ident_servico = x2018.ident_servico
               AND doc_fis.dat_cancelamento IS NULL
               AND doc_fis.cod_class_doc_fis IN ( '2'
                                                , '3' )
               AND doc_fis.norm_dev = '1'
               AND ( ( doc_fis.movto_e_s < '9'
                  AND p_entrada_saida = 'E' )
                 OR ( doc_fis.movto_e_s = '9'
                 AND p_entrada_saida = 'S' ) )
               AND dwt_itens.ident_proc_adj_princ IS NULL
               AND NVL ( dwt_itens.vlr_inss_retido, 0 ) = 0
               AND doc_fis.situacao = 'N'
               AND doc_fis.cod_empresa = p_cod_empresa
               AND doc_fis.cod_estab = p_cod_estab
               AND doc_fis.data_emissao >= p_data_inicial
               AND doc_fis.data_emissao <= p_data_final
            UNION ALL
            SELECT doc_fis.data_emissao
                 , doc_fis.data_fiscal
                 , doc_fis.ident_fis_jur
                 , doc_fis.ident_docto
                 , doc_fis.num_docfis
                 , doc_fis.serie_docfis
                 , doc_fis.sub_serie_docfis
                 , NULL
                 , doc_fis.cod_class_doc_fis
                 , doc_fis.vlr_tot_nota
                 , doc_fis.vlr_contab_compl
                 , dwt_merc.vlr_base_inss
                 , dwt_merc.vlr_aliq_inss
                 , dwt_merc.vlr_inss_retido
                 , dwt_merc.ind_tp_proc_adj_princ
                 , NULL
                 , dwt_merc.num_item
                 , dwt_merc.vlr_item
                 , dwt_merc.ind_tp_proc_adj_princ
                 , NULL
                 , NULL
                 , dwt_merc.ident_produto
                 , NULL
              FROM dwt_docto_fiscal doc_fis
                 , dwt_itens_merc dwt_merc
                 , x2013_produto x2013
                 , x2024_modelo_docto x2024
             WHERE doc_fis.cod_empresa = dwt_merc.cod_empresa
               AND doc_fis.cod_estab = dwt_merc.cod_estab
               AND doc_fis.data_fiscal = dwt_merc.data_fiscal
               AND doc_fis.ident_fis_jur = dwt_merc.ident_fis_jur
               AND doc_fis.ident_docto = dwt_merc.ident_docto
               AND doc_fis.num_docfis = dwt_merc.num_docfis
               AND doc_fis.serie_docfis = dwt_merc.serie_docfis
               AND doc_fis.sub_serie_docfis = dwt_merc.sub_serie_docfis
               AND doc_fis.ident_modelo = x2024.ident_modelo
               AND x2024.cod_modelo IN ( '07'
                                       , '67' )
               AND dwt_merc.ident_produto = x2013.ident_produto
               AND doc_fis.dat_cancelamento IS NULL
               AND doc_fis.cod_class_doc_fis IN ( '1'
                                                , '3' )
               AND doc_fis.norm_dev = '1'
               AND ( ( doc_fis.movto_e_s < '9'
                  AND p_entrada_saida = 'E' )
                 OR ( doc_fis.movto_e_s = '9'
                 AND p_entrada_saida = 'S' ) )
               AND dwt_merc.ident_proc_adj_princ IS NULL
               AND NVL ( dwt_merc.vlr_inss_retido, 0 ) = 0
               AND doc_fis.situacao = 'N'
               AND doc_fis.cod_empresa = p_cod_empresa
               AND doc_fis.cod_estab = p_cod_estab
               AND doc_fis.data_emissao >= p_data_inicial
               AND doc_fis.data_emissao <= p_data_final;



        CURSOR c_conf_inss_maior_bruto ( p_cod_empresa VARCHAR2
                                       , p_cod_estab VARCHAR2
                                       , p_data_inicial DATE
                                       , p_data_final DATE )
        IS
            SELECT doc_fis.data_emissao
                 , doc_fis.data_fiscal
                 , doc_fis.ident_fis_jur
                 , doc_fis.ident_docto
                 , doc_fis.num_docfis
                 , doc_fis.serie_docfis
                 , doc_fis.sub_serie_docfis
                 , tipo_serv.ident_tipo_serv_esocial
                 , doc_fis.cod_class_doc_fis
                 , doc_fis.vlr_tot_nota
                 , doc_fis.vlr_contab_compl
                 , dwt_itens.vlr_base_inss
                 , dwt_itens.vlr_aliq_inss
                 , dwt_itens.vlr_inss_retido
                 , x2058.ind_tp_proc_adj
                 , x2058.num_proc_adj
                 , dwt_itens.num_item
                 , dwt_itens.vlr_servico
                 , x2058_adic.ind_tp_proc_adj
                 , x2058_adic.num_proc_adj
                 , dwt_itens.ident_servico
                 , NULL
                 , NULL
              FROM dwt_docto_fiscal doc_fis
                 , dwt_itens_serv dwt_itens
                 , x2018_servicos x2018
                 , prt_id_tipo_serv_esocial id_tipo_serv
                 , prt_tipo_serv_esocial tipo_serv
                 , x2058_proc_adj x2058
                 , x2058_proc_adj x2058_adic
             WHERE doc_fis.cod_empresa = dwt_itens.cod_empresa
               AND doc_fis.cod_estab = dwt_itens.cod_estab
               AND doc_fis.data_fiscal = dwt_itens.data_fiscal
               AND doc_fis.ident_fis_jur = dwt_itens.ident_fis_jur
               AND doc_fis.ident_docto = dwt_itens.ident_docto
               AND doc_fis.num_docfis = dwt_itens.num_docfis
               AND doc_fis.serie_docfis = dwt_itens.serie_docfis
               AND doc_fis.sub_serie_docfis = dwt_itens.sub_serie_docfis
               AND dwt_itens.ident_proc_adj_princ = x2058.ident_proc_adj(+)
               AND dwt_itens.ident_proc_adj_adic = x2058_adic.ident_proc_adj(+)
               AND id_tipo_serv.cod_empresa = doc_fis.cod_empresa
               AND id_tipo_serv.cod_estab = doc_fis.cod_estab
               AND dwt_itens.ident_servico = x2018.ident_servico
               AND x2018.grupo_servico = id_tipo_serv.grupo_servico
               AND x2018.cod_servico = id_tipo_serv.cod_servico
               AND id_tipo_serv.cod_tipo_serv_esocial = tipo_serv.cod_tipo_serv_esocial
               AND tipo_serv.data_ini_vigencia = (SELECT MAX ( a.data_ini_vigencia )
                                                    FROM prt_tipo_serv_esocial a
                                                   WHERE a.cod_tipo_serv_esocial = tipo_serv.cod_tipo_serv_esocial
                                                     AND a.data_ini_vigencia <= p_data_final)
               AND doc_fis.dat_cancelamento IS NULL
               AND doc_fis.cod_class_doc_fis IN ( '2'
                                                , '3' )
               AND doc_fis.norm_dev = '1'
               AND ( ( doc_fis.movto_e_s < '9'
                  AND p_entrada_saida = 'E' )
                 OR ( doc_fis.movto_e_s = '9'
                 AND p_entrada_saida = 'S' ) )
               AND NVL ( dwt_itens.vlr_inss_retido, 0 ) > 0
               AND doc_fis.situacao = 'N'
               AND dwt_itens.vlr_base_inss > doc_fis.vlr_tot_nota
               AND doc_fis.cod_empresa = p_cod_empresa
               AND doc_fis.cod_estab = p_cod_estab
               AND doc_fis.data_emissao >= p_data_inicial
               AND doc_fis.data_emissao <= p_data_final
            UNION ALL
            SELECT doc_fis.data_emissao
                 , doc_fis.data_fiscal
                 , doc_fis.ident_fis_jur
                 , doc_fis.ident_docto
                 , doc_fis.num_docfis
                 , doc_fis.serie_docfis
                 , doc_fis.sub_serie_docfis
                 , NULL
                 , doc_fis.cod_class_doc_fis
                 , doc_fis.vlr_tot_nota
                 , doc_fis.vlr_contab_compl
                 , dwt_itens.vlr_base_inss
                 , dwt_itens.vlr_aliq_inss
                 , dwt_itens.vlr_inss_retido
                 , x2058.ind_tp_proc_adj
                 , x2058.num_proc_adj
                 , dwt_itens.num_item
                 , dwt_itens.vlr_servico
                 , x2058_adic.ind_tp_proc_adj
                 , x2058_adic.num_proc_adj
                 , dwt_itens.ident_servico
                 , NULL
                 , prt_par2_msaf.cod_param
              FROM dwt_docto_fiscal doc_fis
                 , dwt_itens_serv dwt_itens
                 , x2018_servicos x2018
                 , prt_serv_msaf
                 , prt_par2_msaf
                 , x2058_proc_adj x2058
                 , x2058_proc_adj x2058_adic
             WHERE doc_fis.cod_empresa = dwt_itens.cod_empresa
               AND doc_fis.cod_estab = dwt_itens.cod_estab
               AND doc_fis.data_fiscal = dwt_itens.data_fiscal
               AND doc_fis.ident_fis_jur = dwt_itens.ident_fis_jur
               AND doc_fis.ident_docto = dwt_itens.ident_docto
               AND doc_fis.num_docfis = dwt_itens.num_docfis
               AND doc_fis.serie_docfis = dwt_itens.serie_docfis
               AND doc_fis.sub_serie_docfis = dwt_itens.sub_serie_docfis
               AND dwt_itens.ident_proc_adj_princ = x2058.ident_proc_adj(+)
               AND dwt_itens.ident_proc_adj_adic = x2058_adic.ident_proc_adj(+)
               AND prt_serv_msaf.cod_empresa = doc_fis.cod_empresa
               AND prt_serv_msaf.cod_estab = doc_fis.cod_estab
               AND dwt_itens.ident_servico = x2018.ident_servico
               AND x2018.grupo_servico = prt_serv_msaf.grupo_servico
               AND x2018.cod_servico = prt_serv_msaf.cod_servico
               AND prt_serv_msaf.cod_param = prt_par2_msaf.cod_param
               AND prt_serv_msaf.cod_param IN ( 683
                                              , 684
                                              , 685
                                              , 686
                                              , 690 )
               AND doc_fis.dat_cancelamento IS NULL
               AND doc_fis.cod_class_doc_fis IN ( '2'
                                                , '3' )
               AND doc_fis.norm_dev = '1'
               AND ( ( doc_fis.movto_e_s < '9'
                  AND p_entrada_saida = 'E' )
                 OR ( doc_fis.movto_e_s = '9'
                 AND p_entrada_saida = 'S' ) )
               AND NVL ( dwt_itens.vlr_inss_retido, 0 ) > 0
               AND doc_fis.situacao = 'N'
               AND dwt_itens.vlr_base_inss > doc_fis.vlr_tot_nota
               AND doc_fis.cod_empresa = p_cod_empresa
               AND doc_fis.cod_estab = p_cod_estab
               AND doc_fis.data_emissao >= p_data_inicial
               AND doc_fis.data_emissao <= p_data_final
            UNION ALL
            SELECT doc_fis.data_emissao
                 , doc_fis.data_fiscal
                 , doc_fis.ident_fis_jur
                 , doc_fis.ident_docto
                 , doc_fis.num_docfis
                 , doc_fis.serie_docfis
                 , doc_fis.sub_serie_docfis
                 , tipo_serv.ident_tipo_serv_esocial
                 , doc_fis.cod_class_doc_fis
                 , doc_fis.vlr_tot_nota
                 , doc_fis.vlr_contab_compl
                 , dwt_merc.vlr_base_inss
                 , dwt_merc.vlr_aliq_inss
                 , dwt_merc.vlr_inss_retido
                 , x2058.ind_tp_proc_adj
                 , x2058.num_proc_adj
                 , dwt_merc.num_item
                 , dwt_merc.vlr_item
                 , x2058_adic.ind_tp_proc_adj
                 , x2058_adic.num_proc_adj
                 , NULL
                 , dwt_merc.ident_produto
                 , NULL
              FROM dwt_docto_fiscal doc_fis
                 , dwt_itens_merc dwt_merc
                 , x2013_produto x2013
                 , prt_id_tipo_serv_prod id_tipo_serv
                 , prt_tipo_serv_esocial tipo_serv
                 , x2058_proc_adj x2058
                 , x2058_proc_adj x2058_adic
                 , x2024_modelo_docto x2024
             WHERE doc_fis.cod_empresa = dwt_merc.cod_empresa
               AND doc_fis.cod_estab = dwt_merc.cod_estab
               AND doc_fis.data_fiscal = dwt_merc.data_fiscal
               AND doc_fis.ident_fis_jur = dwt_merc.ident_fis_jur
               AND doc_fis.ident_docto = dwt_merc.ident_docto
               AND doc_fis.num_docfis = dwt_merc.num_docfis
               AND doc_fis.serie_docfis = dwt_merc.serie_docfis
               AND doc_fis.sub_serie_docfis = dwt_merc.sub_serie_docfis
               AND doc_fis.ident_modelo = x2024.ident_modelo
               AND x2024.cod_modelo IN ( '07'
                                       , '67' )
               AND dwt_merc.ident_proc_adj_princ = x2058.ident_proc_adj(+)
               AND dwt_merc.ident_proc_adj_adic = x2058_adic.ident_proc_adj(+)
               AND id_tipo_serv.cod_empresa = doc_fis.cod_empresa
               AND id_tipo_serv.cod_estab = doc_fis.cod_estab
               AND dwt_merc.ident_produto = x2013.ident_produto
               AND id_tipo_serv.grupo_produto = x2013.grupo_produto
               AND id_tipo_serv.cod_produto = x2013.cod_produto
               AND id_tipo_serv.ind_produto = x2013.ind_produto
               AND id_tipo_serv.cod_tipo_serv_esocial = tipo_serv.cod_tipo_serv_esocial
               AND tipo_serv.data_ini_vigencia = (SELECT MAX ( a.data_ini_vigencia )
                                                    FROM prt_tipo_serv_esocial a
                                                   WHERE a.cod_tipo_serv_esocial = tipo_serv.cod_tipo_serv_esocial
                                                     AND a.data_ini_vigencia <= p_data_final)
               AND doc_fis.dat_cancelamento IS NULL
               AND doc_fis.cod_class_doc_fis IN ( '1'
                                                , '3' )
               AND doc_fis.norm_dev = '1'
               AND ( ( doc_fis.movto_e_s < '9'
                  AND p_entrada_saida = 'E' )
                 OR ( doc_fis.movto_e_s = '9'
                 AND p_entrada_saida = 'S' ) )
               AND NVL ( dwt_merc.vlr_inss_retido, 0 ) > 0
               AND doc_fis.situacao = 'N'
               AND dwt_merc.vlr_base_inss > doc_fis.vlr_tot_nota
               AND doc_fis.cod_empresa = p_cod_empresa
               AND doc_fis.cod_estab = p_cod_estab
               AND doc_fis.data_emissao >= p_data_inicial
               AND doc_fis.data_emissao <= p_data_final;



        CURSOR c_conf_inss_aliq_dif_informado ( p_cod_empresa VARCHAR2
                                              , p_cod_estab VARCHAR2
                                              , p_data_inicial DATE
                                              , p_data_final DATE )
        IS
            SELECT doc_fis.data_emissao
                 , doc_fis.data_fiscal
                 , doc_fis.ident_fis_jur
                 , doc_fis.ident_docto
                 , doc_fis.num_docfis
                 , doc_fis.serie_docfis
                 , doc_fis.sub_serie_docfis
                 , tipo_serv.ident_tipo_serv_esocial
                 , doc_fis.cod_class_doc_fis
                 , doc_fis.vlr_tot_nota
                 , doc_fis.vlr_contab_compl
                 , dwt_itens.vlr_base_inss
                 , dwt_itens.vlr_aliq_inss
                 , dwt_itens.vlr_inss_retido
                 , x2058.ind_tp_proc_adj
                 , x2058.num_proc_adj
                 , dwt_itens.num_item
                 , dwt_itens.vlr_servico
                 , x2058_adic.ind_tp_proc_adj
                 , x2058_adic.num_proc_adj
                 , dwt_itens.ident_servico
                 , NULL
                 , NULL
              FROM dwt_docto_fiscal doc_fis
                 , dwt_itens_serv dwt_itens
                 , x2018_servicos x2018
                 , prt_id_tipo_serv_esocial id_tipo_serv
                 , prt_tipo_serv_esocial tipo_serv
                 , x2058_proc_adj x2058
                 , x2058_proc_adj x2058_adic
             WHERE doc_fis.cod_empresa = dwt_itens.cod_empresa
               AND doc_fis.cod_estab = dwt_itens.cod_estab
               AND doc_fis.data_fiscal = dwt_itens.data_fiscal
               AND doc_fis.ident_fis_jur = dwt_itens.ident_fis_jur
               AND doc_fis.ident_docto = dwt_itens.ident_docto
               AND doc_fis.num_docfis = dwt_itens.num_docfis
               AND doc_fis.serie_docfis = dwt_itens.serie_docfis
               AND doc_fis.sub_serie_docfis = dwt_itens.sub_serie_docfis
               AND dwt_itens.ident_proc_adj_princ = x2058.ident_proc_adj(+)
               AND dwt_itens.ident_proc_adj_adic = x2058_adic.ident_proc_adj(+)
               AND id_tipo_serv.cod_empresa = doc_fis.cod_empresa
               AND id_tipo_serv.cod_estab = doc_fis.cod_estab
               AND dwt_itens.ident_servico = x2018.ident_servico
               AND x2018.grupo_servico = id_tipo_serv.grupo_servico
               AND x2018.cod_servico = id_tipo_serv.cod_servico
               AND id_tipo_serv.cod_tipo_serv_esocial = tipo_serv.cod_tipo_serv_esocial
               AND tipo_serv.data_ini_vigencia = (SELECT MAX ( a.data_ini_vigencia )
                                                    FROM prt_tipo_serv_esocial a
                                                   WHERE a.cod_tipo_serv_esocial = tipo_serv.cod_tipo_serv_esocial
                                                     AND a.data_ini_vigencia <= p_data_final)
               AND doc_fis.dat_cancelamento IS NULL
               AND doc_fis.cod_class_doc_fis IN ( '2'
                                                , '3' )
               AND doc_fis.norm_dev = '1'
               AND ( ( doc_fis.movto_e_s < '9'
                  AND p_entrada_saida = 'E' )
                 OR ( doc_fis.movto_e_s = '9'
                 AND p_entrada_saida = 'S' ) )
               AND NVL ( dwt_itens.vlr_inss_retido, 0 ) > 0
               AND doc_fis.situacao = 'N'
               AND ROUND ( ( dwt_itens.vlr_base_inss * dwt_itens.vlr_aliq_inss ) / 100
                         , 2 ) <> dwt_itens.vlr_inss_retido
               AND doc_fis.cod_empresa = p_cod_empresa
               AND doc_fis.cod_estab = p_cod_estab
               AND doc_fis.data_emissao >= p_data_inicial
               AND doc_fis.data_emissao <= p_data_final
            UNION ALL
            SELECT doc_fis.data_emissao
                 , doc_fis.data_fiscal
                 , doc_fis.ident_fis_jur
                 , doc_fis.ident_docto
                 , doc_fis.num_docfis
                 , doc_fis.serie_docfis
                 , doc_fis.sub_serie_docfis
                 , NULL
                 , doc_fis.cod_class_doc_fis
                 , doc_fis.vlr_tot_nota
                 , doc_fis.vlr_contab_compl
                 , dwt_itens.vlr_base_inss
                 , dwt_itens.vlr_aliq_inss
                 , dwt_itens.vlr_inss_retido
                 , x2058.ind_tp_proc_adj
                 , x2058.num_proc_adj
                 , dwt_itens.num_item
                 , dwt_itens.vlr_servico
                 , x2058_adic.ind_tp_proc_adj
                 , x2058_adic.num_proc_adj
                 , dwt_itens.ident_servico
                 , NULL
                 , prt_par2_msaf.cod_param
              FROM dwt_docto_fiscal doc_fis
                 , dwt_itens_serv dwt_itens
                 , x2018_servicos x2018
                 , prt_serv_msaf
                 , prt_par2_msaf
                 , x2058_proc_adj x2058
                 , x2058_proc_adj x2058_adic
             WHERE doc_fis.cod_empresa = dwt_itens.cod_empresa
               AND doc_fis.cod_estab = dwt_itens.cod_estab
               AND doc_fis.data_fiscal = dwt_itens.data_fiscal
               AND doc_fis.ident_fis_jur = dwt_itens.ident_fis_jur
               AND doc_fis.ident_docto = dwt_itens.ident_docto
               AND doc_fis.num_docfis = dwt_itens.num_docfis
               AND doc_fis.serie_docfis = dwt_itens.serie_docfis
               AND doc_fis.sub_serie_docfis = dwt_itens.sub_serie_docfis
               AND dwt_itens.ident_proc_adj_princ = x2058.ident_proc_adj(+)
               AND dwt_itens.ident_proc_adj_adic = x2058_adic.ident_proc_adj(+)
               AND prt_serv_msaf.cod_empresa = doc_fis.cod_empresa
               AND prt_serv_msaf.cod_estab = doc_fis.cod_estab
               AND dwt_itens.ident_servico = x2018.ident_servico
               AND x2018.grupo_servico = prt_serv_msaf.grupo_servico
               AND x2018.cod_servico = prt_serv_msaf.cod_servico
               AND prt_serv_msaf.cod_param = prt_par2_msaf.cod_param
               AND prt_serv_msaf.cod_param IN ( 683
                                              , 684
                                              , 685
                                              , 686
                                              , 690 )
               AND doc_fis.dat_cancelamento IS NULL
               AND doc_fis.cod_class_doc_fis IN ( '2'
                                                , '3' )
               AND doc_fis.norm_dev = '1'
               AND ( ( doc_fis.movto_e_s < '9'
                  AND p_entrada_saida = 'E' )
                 OR ( doc_fis.movto_e_s = '9'
                 AND p_entrada_saida = 'S' ) )
               AND NVL ( dwt_itens.vlr_inss_retido, 0 ) > 0
               AND doc_fis.situacao = 'N'
               AND ROUND ( ( dwt_itens.vlr_base_inss * dwt_itens.vlr_aliq_inss ) / 100
                         , 2 ) <> dwt_itens.vlr_inss_retido
               AND doc_fis.cod_empresa = p_cod_empresa
               AND doc_fis.cod_estab = p_cod_estab
               AND doc_fis.data_emissao >= p_data_inicial
               AND doc_fis.data_emissao <= p_data_final
            UNION ALL
            SELECT doc_fis.data_emissao
                 , doc_fis.data_fiscal
                 , doc_fis.ident_fis_jur
                 , doc_fis.ident_docto
                 , doc_fis.num_docfis
                 , doc_fis.serie_docfis
                 , doc_fis.sub_serie_docfis
                 , tipo_serv.ident_tipo_serv_esocial
                 , doc_fis.cod_class_doc_fis
                 , doc_fis.vlr_tot_nota
                 , doc_fis.vlr_contab_compl
                 , dwt_merc.vlr_base_inss
                 , dwt_merc.vlr_aliq_inss
                 , dwt_merc.vlr_inss_retido
                 , x2058.ind_tp_proc_adj
                 , x2058.num_proc_adj
                 , dwt_merc.num_item
                 , dwt_merc.vlr_item
                 , x2058_adic.ind_tp_proc_adj
                 , x2058_adic.num_proc_adj
                 , NULL
                 , dwt_merc.ident_produto
                 , NULL
              FROM dwt_docto_fiscal doc_fis
                 , dwt_itens_merc dwt_merc
                 , x2013_produto x2013
                 , prt_id_tipo_serv_prod id_tipo_serv
                 , prt_tipo_serv_esocial tipo_serv
                 , x2058_proc_adj x2058
                 , x2058_proc_adj x2058_adic
                 , x2024_modelo_docto x2024
             WHERE doc_fis.cod_empresa = dwt_merc.cod_empresa
               AND doc_fis.cod_estab = dwt_merc.cod_estab
               AND doc_fis.data_fiscal = dwt_merc.data_fiscal
               AND doc_fis.ident_fis_jur = dwt_merc.ident_fis_jur
               AND doc_fis.ident_docto = dwt_merc.ident_docto
               AND doc_fis.num_docfis = dwt_merc.num_docfis
               AND doc_fis.serie_docfis = dwt_merc.serie_docfis
               AND doc_fis.sub_serie_docfis = dwt_merc.sub_serie_docfis
               AND doc_fis.ident_modelo = x2024.ident_modelo
               AND x2024.cod_modelo IN ( '07'
                                       , '67' )
               AND dwt_merc.ident_proc_adj_princ = x2058.ident_proc_adj(+)
               AND dwt_merc.ident_proc_adj_adic = x2058_adic.ident_proc_adj(+)
               AND id_tipo_serv.cod_empresa = doc_fis.cod_empresa
               AND id_tipo_serv.cod_estab = doc_fis.cod_estab
               AND dwt_merc.ident_produto = x2013.ident_produto
               AND id_tipo_serv.grupo_produto = x2013.grupo_produto
               AND id_tipo_serv.cod_produto = x2013.cod_produto
               AND id_tipo_serv.ind_produto = x2013.ind_produto
               AND id_tipo_serv.cod_tipo_serv_esocial = tipo_serv.cod_tipo_serv_esocial
               AND tipo_serv.data_ini_vigencia = (SELECT MAX ( a.data_ini_vigencia )
                                                    FROM prt_tipo_serv_esocial a
                                                   WHERE a.cod_tipo_serv_esocial = tipo_serv.cod_tipo_serv_esocial
                                                     AND a.data_ini_vigencia <= p_data_final)
               AND doc_fis.dat_cancelamento IS NULL
               AND doc_fis.cod_class_doc_fis IN ( '1'
                                                , '3' )
               AND doc_fis.norm_dev = '1'
               AND ( ( doc_fis.movto_e_s < '9'
                  AND p_entrada_saida = 'E' )
                 OR ( doc_fis.movto_e_s = '9'
                 AND p_entrada_saida = 'S' ) )
               AND NVL ( dwt_merc.vlr_inss_retido, 0 ) > 0
               AND doc_fis.situacao = 'N'
               AND ROUND ( ( dwt_merc.vlr_base_inss * dwt_merc.vlr_aliq_inss ) / 100
                         , 2 ) <> dwt_merc.vlr_inss_retido
               AND doc_fis.cod_empresa = p_cod_empresa
               AND doc_fis.cod_estab = p_cod_estab
               AND doc_fis.data_emissao >= p_data_inicial
               AND doc_fis.data_emissao <= p_data_final;



        CURSOR c_conf_aliq_inss_invalida ( p_cod_empresa VARCHAR2
                                         , p_cod_estab VARCHAR2
                                         , p_data_inicial DATE
                                         , p_data_final DATE )
        IS
            SELECT doc_fis.data_emissao
                 , doc_fis.data_fiscal
                 , doc_fis.ident_fis_jur
                 , doc_fis.ident_docto
                 , doc_fis.num_docfis
                 , doc_fis.serie_docfis
                 , doc_fis.sub_serie_docfis
                 , tipo_serv.ident_tipo_serv_esocial
                 , doc_fis.cod_class_doc_fis
                 , doc_fis.vlr_tot_nota
                 , doc_fis.vlr_contab_compl
                 , dwt_itens.vlr_base_inss
                 , dwt_itens.vlr_aliq_inss
                 , dwt_itens.vlr_inss_retido
                 , x2058.ind_tp_proc_adj
                 , x2058.num_proc_adj
                 , dwt_itens.num_item
                 , dwt_itens.vlr_servico
                 , x2058_adic.ind_tp_proc_adj
                 , x2058_adic.num_proc_adj
                 , dwt_itens.ident_servico
                 , NULL
                 , NULL
              FROM dwt_docto_fiscal doc_fis
                 , dwt_itens_serv dwt_itens
                 , x2018_servicos x2018
                 , prt_id_tipo_serv_esocial id_tipo_serv
                 , prt_tipo_serv_esocial tipo_serv
                 , x2058_proc_adj x2058
                 , x2058_proc_adj x2058_adic
             WHERE doc_fis.cod_empresa = dwt_itens.cod_empresa
               AND doc_fis.cod_estab = dwt_itens.cod_estab
               AND doc_fis.data_fiscal = dwt_itens.data_fiscal
               AND doc_fis.ident_fis_jur = dwt_itens.ident_fis_jur
               AND doc_fis.ident_docto = dwt_itens.ident_docto
               AND doc_fis.num_docfis = dwt_itens.num_docfis
               AND doc_fis.serie_docfis = dwt_itens.serie_docfis
               AND doc_fis.sub_serie_docfis = dwt_itens.sub_serie_docfis
               AND dwt_itens.ident_proc_adj_princ = x2058.ident_proc_adj(+)
               AND dwt_itens.ident_proc_adj_adic = x2058_adic.ident_proc_adj(+)
               AND id_tipo_serv.cod_empresa = doc_fis.cod_empresa
               AND id_tipo_serv.cod_estab = doc_fis.cod_estab
               AND dwt_itens.ident_servico = x2018.ident_servico
               AND x2018.grupo_servico = id_tipo_serv.grupo_servico
               AND x2018.cod_servico = id_tipo_serv.cod_servico
               AND id_tipo_serv.cod_tipo_serv_esocial = tipo_serv.cod_tipo_serv_esocial
               AND tipo_serv.data_ini_vigencia = (SELECT MAX ( a.data_ini_vigencia )
                                                    FROM prt_tipo_serv_esocial a
                                                   WHERE a.cod_tipo_serv_esocial = tipo_serv.cod_tipo_serv_esocial
                                                     AND a.data_ini_vigencia <= p_data_final)
               AND doc_fis.dat_cancelamento IS NULL
               AND doc_fis.cod_class_doc_fis IN ( '2'
                                                , '3' )
               AND doc_fis.norm_dev = '1'
               AND ( ( doc_fis.movto_e_s < '9'
                  AND p_entrada_saida = 'E' )
                 OR ( doc_fis.movto_e_s = '9'
                 AND p_entrada_saida = 'S' ) )
               AND NVL ( dwt_itens.vlr_inss_retido, 0 ) > 0
               AND doc_fis.situacao = 'N'
               AND dwt_itens.vlr_aliq_inss <> 11
               AND dwt_itens.vlr_aliq_inss <> 3.5
               AND doc_fis.cod_empresa = p_cod_empresa
               AND doc_fis.cod_estab = p_cod_estab
               AND doc_fis.data_emissao >= p_data_inicial
               AND doc_fis.data_emissao <= p_data_final
            UNION ALL
            SELECT doc_fis.data_emissao
                 , doc_fis.data_fiscal
                 , doc_fis.ident_fis_jur
                 , doc_fis.ident_docto
                 , doc_fis.num_docfis
                 , doc_fis.serie_docfis
                 , doc_fis.sub_serie_docfis
                 , NULL
                 , doc_fis.cod_class_doc_fis
                 , doc_fis.vlr_tot_nota
                 , doc_fis.vlr_contab_compl
                 , dwt_itens.vlr_base_inss
                 , dwt_itens.vlr_aliq_inss
                 , dwt_itens.vlr_inss_retido
                 , x2058.ind_tp_proc_adj
                 , x2058.num_proc_adj
                 , dwt_itens.num_item
                 , dwt_itens.vlr_servico
                 , x2058_adic.ind_tp_proc_adj
                 , x2058_adic.num_proc_adj
                 , dwt_itens.ident_servico
                 , NULL
                 , prt_par2_msaf.cod_param
              FROM dwt_docto_fiscal doc_fis
                 , dwt_itens_serv dwt_itens
                 , x2018_servicos x2018
                 , prt_serv_msaf
                 , prt_par2_msaf
                 , x2058_proc_adj x2058
                 , x2058_proc_adj x2058_adic
             WHERE doc_fis.cod_empresa = dwt_itens.cod_empresa
               AND doc_fis.cod_estab = dwt_itens.cod_estab
               AND doc_fis.data_fiscal = dwt_itens.data_fiscal
               AND doc_fis.ident_fis_jur = dwt_itens.ident_fis_jur
               AND doc_fis.ident_docto = dwt_itens.ident_docto
               AND doc_fis.num_docfis = dwt_itens.num_docfis
               AND doc_fis.serie_docfis = dwt_itens.serie_docfis
               AND doc_fis.sub_serie_docfis = dwt_itens.sub_serie_docfis
               AND dwt_itens.ident_proc_adj_princ = x2058.ident_proc_adj(+)
               AND dwt_itens.ident_proc_adj_adic = x2058_adic.ident_proc_adj(+)
               AND prt_serv_msaf.cod_empresa = doc_fis.cod_empresa
               AND prt_serv_msaf.cod_estab = doc_fis.cod_estab
               AND dwt_itens.ident_servico = x2018.ident_servico
               AND x2018.grupo_servico = prt_serv_msaf.grupo_servico
               AND x2018.cod_servico = prt_serv_msaf.cod_servico
               AND prt_serv_msaf.cod_param = prt_par2_msaf.cod_param
               AND prt_serv_msaf.cod_param IN ( 683
                                              , 684
                                              , 685
                                              , 686
                                              , 690 )
               AND doc_fis.dat_cancelamento IS NULL
               AND doc_fis.cod_class_doc_fis IN ( '2'
                                                , '3' )
               AND doc_fis.norm_dev = '1'
               AND ( ( doc_fis.movto_e_s < '9'
                  AND p_entrada_saida = 'E' )
                 OR ( doc_fis.movto_e_s = '9'
                 AND p_entrada_saida = 'S' ) )
               AND NVL ( dwt_itens.vlr_inss_retido, 0 ) > 0
               AND doc_fis.situacao = 'N'
               AND dwt_itens.vlr_aliq_inss <> 11
               AND dwt_itens.vlr_aliq_inss <> 3.5
               AND doc_fis.cod_empresa = p_cod_empresa
               AND doc_fis.cod_estab = p_cod_estab
               AND doc_fis.data_emissao >= p_data_inicial
               AND doc_fis.data_emissao <= p_data_final
            UNION ALL
            SELECT doc_fis.data_emissao
                 , doc_fis.data_fiscal
                 , doc_fis.ident_fis_jur
                 , doc_fis.ident_docto
                 , doc_fis.num_docfis
                 , doc_fis.serie_docfis
                 , doc_fis.sub_serie_docfis
                 , tipo_serv.ident_tipo_serv_esocial
                 , doc_fis.cod_class_doc_fis
                 , doc_fis.vlr_tot_nota
                 , doc_fis.vlr_contab_compl
                 , dwt_merc.vlr_base_inss
                 , dwt_merc.vlr_aliq_inss
                 , dwt_merc.vlr_inss_retido
                 , x2058.ind_tp_proc_adj
                 , x2058.num_proc_adj
                 , dwt_merc.num_item
                 , dwt_merc.vlr_item
                 , x2058_adic.ind_tp_proc_adj
                 , x2058_adic.num_proc_adj
                 , NULL
                 , dwt_merc.ident_produto
                 , NULL
              FROM dwt_docto_fiscal doc_fis
                 , dwt_itens_merc dwt_merc
                 , x2013_produto x2013
                 , prt_id_tipo_serv_prod id_tipo_serv
                 , prt_tipo_serv_esocial tipo_serv
                 , x2058_proc_adj x2058
                 , x2058_proc_adj x2058_adic
                 , x2024_modelo_docto x2024
             WHERE doc_fis.cod_empresa = dwt_merc.cod_empresa
               AND doc_fis.cod_estab = dwt_merc.cod_estab
               AND doc_fis.data_fiscal = dwt_merc.data_fiscal
               AND doc_fis.ident_fis_jur = dwt_merc.ident_fis_jur
               AND doc_fis.ident_docto = dwt_merc.ident_docto
               AND doc_fis.num_docfis = dwt_merc.num_docfis
               AND doc_fis.serie_docfis = dwt_merc.serie_docfis
               AND doc_fis.sub_serie_docfis = dwt_merc.sub_serie_docfis
               AND doc_fis.ident_modelo = x2024.ident_modelo
               AND x2024.cod_modelo IN ( '07'
                                       , '67' )
               AND dwt_merc.ident_proc_adj_princ = x2058.ident_proc_adj(+)
               AND dwt_merc.ident_proc_adj_adic = x2058_adic.ident_proc_adj(+)
               AND id_tipo_serv.cod_empresa = doc_fis.cod_empresa
               AND id_tipo_serv.cod_estab = doc_fis.cod_estab
               AND dwt_merc.ident_produto = x2013.ident_produto
               AND id_tipo_serv.grupo_produto = x2013.grupo_produto
               AND id_tipo_serv.cod_produto = x2013.cod_produto
               AND id_tipo_serv.ind_produto = x2013.ind_produto
               AND id_tipo_serv.cod_tipo_serv_esocial = tipo_serv.cod_tipo_serv_esocial
               AND tipo_serv.data_ini_vigencia = (SELECT MAX ( a.data_ini_vigencia )
                                                    FROM prt_tipo_serv_esocial a
                                                   WHERE a.cod_tipo_serv_esocial = tipo_serv.cod_tipo_serv_esocial
                                                     AND a.data_ini_vigencia <= p_data_final)
               AND doc_fis.dat_cancelamento IS NULL
               AND doc_fis.cod_class_doc_fis IN ( '1'
                                                , '3' )
               AND doc_fis.norm_dev = '1'
               AND ( ( doc_fis.movto_e_s < '9'
                  AND p_entrada_saida = 'E' )
                 OR ( doc_fis.movto_e_s = '9'
                 AND p_entrada_saida = 'S' ) )
               AND NVL ( dwt_merc.vlr_inss_retido, 0 ) > 0
               AND doc_fis.situacao = 'N'
               AND dwt_merc.vlr_aliq_inss <> 11
               AND dwt_merc.vlr_aliq_inss <> 3.5
               AND doc_fis.cod_empresa = p_cod_empresa
               AND doc_fis.cod_estab = p_cod_estab
               AND doc_fis.data_emissao >= p_data_inicial
               AND doc_fis.data_emissao <= p_data_final;



        TYPE treg_data_emissao IS TABLE OF reinf_conf_previdenciaria.data_emissao%TYPE
            INDEX BY BINARY_INTEGER;

        TYPE treg_data_fiscal IS TABLE OF reinf_conf_previdenciaria.data_fiscal%TYPE
            INDEX BY BINARY_INTEGER;

        TYPE treg_ident_fis_jur IS TABLE OF reinf_conf_previdenciaria.ident_fis_jur%TYPE
            INDEX BY BINARY_INTEGER;

        TYPE treg_ident_docto IS TABLE OF reinf_conf_previdenciaria.ident_docto%TYPE
            INDEX BY BINARY_INTEGER;

        TYPE treg_num_docfis IS TABLE OF reinf_conf_previdenciaria.num_docfis%TYPE
            INDEX BY BINARY_INTEGER;

        TYPE treg_serie_docfis IS TABLE OF reinf_conf_previdenciaria.serie_docfis%TYPE
            INDEX BY BINARY_INTEGER;

        TYPE treg_sub_serie_docfis IS TABLE OF reinf_conf_previdenciaria.sub_serie_docfis%TYPE
            INDEX BY BINARY_INTEGER;

        TYPE treg_ident_tipo_serv_esocial IS TABLE OF reinf_conf_previdenciaria.ident_tipo_serv_esocial%TYPE
            INDEX BY BINARY_INTEGER;

        TYPE treg_cod_class_doc_fis IS TABLE OF reinf_conf_previdenciaria.cod_class_doc_fis%TYPE
            INDEX BY BINARY_INTEGER;

        TYPE treg_vlr_tot_nota IS TABLE OF reinf_conf_previdenciaria.vlr_tot_nota%TYPE
            INDEX BY BINARY_INTEGER;

        TYPE treg_vlr_contab_compl IS TABLE OF reinf_conf_previdenciaria.vlr_contab_compl%TYPE
            INDEX BY BINARY_INTEGER;

        TYPE treg_vlr_base_inss IS TABLE OF reinf_conf_previdenciaria.vlr_base_inss%TYPE
            INDEX BY BINARY_INTEGER;

        TYPE treg_vlr_aliq_inss IS TABLE OF reinf_conf_previdenciaria.vlr_aliq_inss%TYPE
            INDEX BY BINARY_INTEGER;

        TYPE treg_vlr_inss_retido IS TABLE OF reinf_conf_previdenciaria.vlr_inss_retido%TYPE
            INDEX BY BINARY_INTEGER;

        TYPE treg_ind_tipo_proc IS TABLE OF reinf_conf_previdenciaria.ind_tipo_proc%TYPE
            INDEX BY BINARY_INTEGER;

        TYPE treg_num_proc_jur IS TABLE OF reinf_conf_previdenciaria.num_proc_jur%TYPE
            INDEX BY BINARY_INTEGER;

        TYPE treg_num_item IS TABLE OF dwt_itens_serv.num_item%TYPE
            INDEX BY BINARY_INTEGER;

        TYPE treg_vlr_servico IS TABLE OF reinf_conf_previdenciaria.vlr_servico%TYPE
            INDEX BY BINARY_INTEGER;

        TYPE treg_ind_tp_proc_adj_adic IS TABLE OF reinf_conf_previdenciaria.ind_tp_proc_adj_adic%TYPE
            INDEX BY BINARY_INTEGER;

        TYPE treg_num_proc_adj_adic IS TABLE OF reinf_conf_previdenciaria.num_proc_adj_adic%TYPE
            INDEX BY BINARY_INTEGER;

        TYPE treg_ident_servico IS TABLE OF dwt_itens_serv.ident_servico%TYPE
            INDEX BY BINARY_INTEGER;

        TYPE treg_ident_produto IS TABLE OF dwt_itens_merc.ident_produto%TYPE
            INDEX BY BINARY_INTEGER;

        TYPE treg_cod_param IS TABLE OF reinf_conf_previdenciaria.cod_param%TYPE
            INDEX BY BINARY_INTEGER;

        rreg_data_emissao treg_data_emissao;
        rreg_data_fiscal treg_data_fiscal;
        rreg_ident_fis_jur treg_ident_fis_jur;
        rreg_ident_docto treg_ident_docto;
        rreg_num_docfis treg_num_docfis;
        rreg_serie_docfis treg_serie_docfis;
        rreg_sub_serie_docfis treg_sub_serie_docfis;
        rreg_ident_tipo_serv_esocial treg_ident_tipo_serv_esocial;
        rreg_cod_class_doc_fis treg_cod_class_doc_fis;
        rreg_vlr_tot_nota treg_vlr_tot_nota;
        rreg_vlr_contab_compl treg_vlr_contab_compl;
        rreg_vlr_base_inss treg_vlr_base_inss;
        rreg_vlr_aliq_inss treg_vlr_aliq_inss;
        rreg_vlr_inss_retido treg_vlr_inss_retido;
        rreg_ind_tipo_proc treg_ind_tipo_proc;
        rreg_num_proc_jur treg_num_proc_jur;
        rreg_num_item treg_num_item;
        rreg_vlr_servico treg_vlr_servico;
        rreg_ind_tp_proc_adj_adic treg_ind_tp_proc_adj_adic;
        rreg_num_proc_adj_adic treg_num_proc_adj_adic;
        rreg_ident_servico treg_ident_servico;
        rreg_ident_produto treg_ident_produto;
        rreg_cod_param treg_cod_param;

        rtabsaida reinf_conf_previdenciaria%ROWTYPE;


        PROCEDURE inicializar
        IS
        BEGIN
            rreg_data_emissao.delete;
            rreg_data_fiscal.delete;
            rreg_ident_fis_jur.delete;
            rreg_ident_docto.delete;
            rreg_num_docfis.delete;
            rreg_serie_docfis.delete;
            rreg_sub_serie_docfis.delete;
            rreg_ident_tipo_serv_esocial.delete;
            rreg_cod_class_doc_fis.delete;
            rreg_vlr_tot_nota.delete;
            rreg_vlr_contab_compl.delete;
            rreg_vlr_base_inss.delete;
            rreg_vlr_aliq_inss.delete;
            rreg_vlr_inss_retido.delete;
            rreg_ind_tipo_proc.delete;
            rreg_num_proc_jur.delete;
            rreg_num_item.delete;
            rreg_vlr_servico.delete;
            rreg_ind_tp_proc_adj_adic.delete;
            rreg_num_proc_adj_adic.delete;
            rreg_cod_param.delete;
        END inicializar;

     
        
        PROCEDURE gravaregistro ( preg IN reinf_conf_previdenciaria%ROWTYPE )
        IS
        BEGIN
            BEGIN
                  INSERT INTO msafi.tb_fin4816_reinf_conf_prev_gtt ( cod_empresa
                                                                , cod_estab
                                                                , data_emissao
                                                                , data_fiscal
                                                                , ident_fis_jur
                                                                , ident_docto
                                                                , num_docfis
                                                                , serie_docfis
                                                                , sub_serie_docfis
                                                                , cod_usuario
                                                                , ident_tipo_serv_esocial
                                                                , cod_class_doc_fis
                                                                , vlr_tot_nota
                                                                , vlr_contab_compl
                                                                , vlr_base_inss
                                                                , vlr_aliq_inss
                                                                , vlr_inss_retido
                                                                , ind_tipo_proc
                                                                , num_proc_jur
                                                                , num_item
                                                                , vlr_servico
                                                                , ind_tp_proc_adj_adic
                                                                , num_proc_adj_adic
                                                                , ident_servico
                                                                , ident_produto
                                                                , cod_param )
                     VALUES ( preg.cod_empresa
                            , preg.cod_estab
                            , preg.data_emissao
                            , preg.data_fiscal
                            , preg.ident_fis_jur
                            , preg.ident_docto
                            , preg.num_docfis
                            , preg.serie_docfis
                            , preg.sub_serie_docfis
                            , preg.cod_usuario
                            , preg.ident_tipo_serv_esocial
                            , preg.cod_class_doc_fis
                            , preg.vlr_tot_nota
                            , preg.vlr_contab_compl
                            , preg.vlr_base_inss
                            , preg.vlr_aliq_inss
                            , preg.vlr_inss_retido
                            , preg.ind_tipo_proc
                            , preg.num_proc_jur
                            , preg.num_item
                            , preg.vlr_servico
                            , preg.ind_tp_proc_adj_adic
                            , preg.num_proc_adj_adic
                            , preg.ident_servico
                            , preg.ident_produto
                            , preg.cod_param );
            EXCEPTION
                WHEN DUP_VAL_ON_INDEX THEN
                    NULL;
                WHEN OTHERS THEN
                    p_status := -1;
            END;
        END gravaregistro;


        PROCEDURE montaregistros
        IS
        BEGIN
            FOR i IN 1 .. rreg_data_emissao.COUNT LOOP
                BEGIN
                    p_status := 1;
                    rtabsaida.cod_empresa := cod_empresa_w;
                    rtabsaida.cod_estab := cod_estab_w;
                    rtabsaida.data_emissao := rreg_data_emissao ( i );
                    rtabsaida.data_fiscal := rreg_data_fiscal ( i );
                    rtabsaida.ident_fis_jur := rreg_ident_fis_jur ( i );
                    rtabsaida.ident_docto := rreg_ident_docto ( i );
                    rtabsaida.num_docfis := rreg_num_docfis ( i );
                    rtabsaida.serie_docfis := rreg_serie_docfis ( i );
                    rtabsaida.sub_serie_docfis := rreg_sub_serie_docfis ( i );
                    rtabsaida.cod_usuario := p_cod_usuario;
                    rtabsaida.ident_tipo_serv_esocial := rreg_ident_tipo_serv_esocial ( i );
                    rtabsaida.cod_class_doc_fis := rreg_cod_class_doc_fis ( i );
                    rtabsaida.vlr_tot_nota := rreg_vlr_tot_nota ( i );
                    rtabsaida.vlr_contab_compl := rreg_vlr_contab_compl ( i );
                    rtabsaida.vlr_base_inss := rreg_vlr_base_inss ( i );
                    rtabsaida.vlr_aliq_inss := rreg_vlr_aliq_inss ( i );
                    rtabsaida.vlr_inss_retido := rreg_vlr_inss_retido ( i );
                    rtabsaida.ind_tipo_proc := rreg_ind_tipo_proc ( i );
                    rtabsaida.num_proc_jur := rreg_num_proc_jur ( i );
                    rtabsaida.num_item := rreg_num_item ( i );
                    rtabsaida.vlr_servico := rreg_vlr_servico ( i );
                    rtabsaida.ind_tp_proc_adj_adic := rreg_ind_tp_proc_adj_adic ( i );
                    rtabsaida.num_proc_adj_adic := rreg_num_proc_adj_adic ( i );
                    rtabsaida.ident_servico := rreg_ident_servico ( i );
                    rtabsaida.ident_produto := rreg_ident_produto ( i );
                    rtabsaida.cod_param := rreg_cod_param ( i );

                    gravaregistro ( rtabsaida );
                END;
            END LOOP;
        END montaregistros;

        PROCEDURE montaregistrossemtiposerv
        IS
        BEGIN
            FOR i IN 1 .. rreg_data_emissao.COUNT LOOP
                BEGIN
                    p_status := 1;
                    rtabsaida.cod_empresa := cod_empresa_w;
                    rtabsaida.cod_estab := cod_estab_w;
                    rtabsaida.data_emissao := rreg_data_emissao ( i );
                    rtabsaida.data_fiscal := rreg_data_fiscal ( i );
                    rtabsaida.ident_fis_jur := rreg_ident_fis_jur ( i );
                    rtabsaida.ident_docto := rreg_ident_docto ( i );
                    rtabsaida.num_docfis := rreg_num_docfis ( i );
                    rtabsaida.serie_docfis := rreg_serie_docfis ( i );
                    rtabsaida.sub_serie_docfis := rreg_sub_serie_docfis ( i );
                    rtabsaida.cod_usuario := p_cod_usuario;
                    rtabsaida.ident_tipo_serv_esocial := NULL;
                    rtabsaida.cod_class_doc_fis := rreg_cod_class_doc_fis ( i );
                    rtabsaida.vlr_tot_nota := rreg_vlr_tot_nota ( i );
                    rtabsaida.vlr_contab_compl := rreg_vlr_contab_compl ( i );
                    rtabsaida.vlr_base_inss := rreg_vlr_base_inss ( i );
                    rtabsaida.vlr_aliq_inss := rreg_vlr_aliq_inss ( i );
                    rtabsaida.vlr_inss_retido := rreg_vlr_inss_retido ( i );
                    rtabsaida.ind_tipo_proc := rreg_ind_tipo_proc ( i );
                    rtabsaida.num_proc_jur := rreg_num_proc_jur ( i );
                    rtabsaida.num_item := rreg_num_item ( i );
                    rtabsaida.ind_tp_proc_adj_adic := rreg_ind_tp_proc_adj_adic ( i );
                    rtabsaida.num_proc_adj_adic := rreg_num_proc_adj_adic ( i );
                    rtabsaida.ident_servico := rreg_ident_servico ( i );
                    rtabsaida.ident_produto := rreg_ident_produto ( i );
                    rtabsaida.cod_param := rreg_cod_param ( i );

                    gravaregistro ( rtabsaida );
                END;
            END LOOP;
        END montaregistrossemtiposerv;



        PROCEDURE recregistrosservretprev
        IS
        BEGIN
            OPEN c_conf_ret_prev ( cod_empresa_w
                                 , cod_estab_w
                                 , data_ini_w
                                 , data_fim_w );

            LOOP
                FETCH c_conf_ret_prev
                    BULK COLLECT INTO rreg_data_emissao
                       , rreg_data_fiscal
                       , rreg_ident_fis_jur
                       , rreg_ident_docto
                       , rreg_num_docfis
                       , rreg_serie_docfis
                       , rreg_sub_serie_docfis
                       , rreg_ident_tipo_serv_esocial
                       , rreg_cod_class_doc_fis
                       , rreg_vlr_tot_nota
                       , rreg_vlr_contab_compl
                       , rreg_vlr_base_inss
                       , rreg_vlr_aliq_inss
                       , rreg_vlr_inss_retido
                       , rreg_ind_tipo_proc
                       , rreg_num_proc_jur
                       , rreg_num_item
                       , rreg_vlr_servico
                       , rreg_ind_tp_proc_adj_adic
                       , rreg_num_proc_adj_adic
                       , rreg_ident_servico
                       , rreg_ident_produto
                       , rreg_cod_param
                    LIMIT 1000;

                montaregistros;
                EXIT WHEN c_conf_ret_prev%NOTFOUND;
            END LOOP;

            COMMIT;

            CLOSE c_conf_ret_prev;
        END recregistrosservretprev;



        PROCEDURE recregistrossemtiposerv
        IS
        BEGIN
            OPEN c_conf_sem_tipo_serv ( cod_empresa_w
                                      , cod_estab_w
                                      , data_ini_w
                                      , data_fim_w );

            LOOP
                FETCH c_conf_sem_tipo_serv
                    BULK COLLECT INTO rreg_data_emissao
                       , rreg_data_fiscal
                       , rreg_ident_fis_jur
                       , rreg_ident_docto
                       , rreg_num_docfis
                       , rreg_serie_docfis
                       , rreg_sub_serie_docfis
                       , rreg_ident_tipo_serv_esocial
                       , rreg_cod_class_doc_fis
                       , rreg_vlr_tot_nota
                       , rreg_vlr_contab_compl
                       , rreg_vlr_base_inss
                       , rreg_vlr_aliq_inss
                       , rreg_vlr_inss_retido
                       , rreg_ind_tipo_proc
                       , rreg_num_proc_jur
                       , rreg_num_item
                       , rreg_vlr_servico
                       , rreg_ind_tp_proc_adj_adic
                       , rreg_num_proc_adj_adic
                       , rreg_ident_servico
                       , rreg_ident_produto
                       , rreg_cod_param
                    LIMIT 1000;

                montaregistros;
                EXIT WHEN c_conf_sem_tipo_serv%NOTFOUND;
            END LOOP;

            COMMIT;

            CLOSE c_conf_sem_tipo_serv;
        END recregistrossemtiposerv;


        PROCEDURE recregistrosretprevproc
        IS
        BEGIN
            OPEN c_conf_ret_prev_proc ( cod_empresa_w
                                      , cod_estab_w
                                      , data_ini_w
                                      , data_fim_w );

            LOOP
                FETCH c_conf_ret_prev_proc
                    BULK COLLECT INTO rreg_data_emissao
                       , rreg_data_fiscal
                       , rreg_ident_fis_jur
                       , rreg_ident_docto
                       , rreg_num_docfis
                       , rreg_serie_docfis
                       , rreg_sub_serie_docfis
                       , rreg_ident_tipo_serv_esocial
                       , rreg_cod_class_doc_fis
                       , rreg_vlr_tot_nota
                       , rreg_vlr_contab_compl
                       , rreg_vlr_base_inss
                       , rreg_vlr_aliq_inss
                       , rreg_vlr_inss_retido
                       , rreg_ind_tipo_proc
                       , rreg_num_proc_jur
                       , rreg_num_item
                       , rreg_vlr_servico
                       , rreg_ind_tp_proc_adj_adic
                       , rreg_num_proc_adj_adic
                       , rreg_ident_servico
                       , rreg_ident_produto
                       , rreg_cod_param
                    LIMIT 1000;

                montaregistros;
                EXIT WHEN c_conf_ret_prev_proc%NOTFOUND;
            END LOOP;

            COMMIT;

            CLOSE c_conf_ret_prev_proc;
        END recregistrosretprevproc;


        PROCEDURE recregistrosretprevsemproc
        IS
        BEGIN
            OPEN c_conf_ret_prev_sem_proc ( cod_empresa_w
                                          , cod_estab_w
                                          , data_ini_w
                                          , data_fim_w );

            LOOP
                FETCH c_conf_ret_prev_sem_proc
                    BULK COLLECT INTO rreg_data_emissao
                       , rreg_data_fiscal
                       , rreg_ident_fis_jur
                       , rreg_ident_docto
                       , rreg_num_docfis
                       , rreg_serie_docfis
                       , rreg_sub_serie_docfis
                       , rreg_ident_tipo_serv_esocial
                       , rreg_cod_class_doc_fis
                       , rreg_vlr_tot_nota
                       , rreg_vlr_contab_compl
                       , rreg_vlr_base_inss
                       , rreg_vlr_aliq_inss
                       , rreg_vlr_inss_retido
                       , rreg_ind_tipo_proc
                       , rreg_num_proc_jur
                       , rreg_num_item
                       , rreg_vlr_servico
                       , rreg_ind_tp_proc_adj_adic
                       , rreg_num_proc_adj_adic
                       , rreg_ident_servico
                       , rreg_ident_produto
                       , rreg_cod_param
                    LIMIT 1000;

                montaregistros;
                EXIT WHEN c_conf_ret_prev_sem_proc%NOTFOUND;
            END LOOP;

            COMMIT;

            CLOSE c_conf_ret_prev_sem_proc;
        END recregistrosretprevsemproc;



        PROCEDURE recregistrosinssmaiorbruto
        IS
        BEGIN
            OPEN c_conf_inss_maior_bruto ( cod_empresa_w
                                         , cod_estab_w
                                         , data_ini_w
                                         , data_fim_w );

            LOOP
                FETCH c_conf_inss_maior_bruto
                    BULK COLLECT INTO rreg_data_emissao
                       , rreg_data_fiscal
                       , rreg_ident_fis_jur
                       , rreg_ident_docto
                       , rreg_num_docfis
                       , rreg_serie_docfis
                       , rreg_sub_serie_docfis
                       , rreg_ident_tipo_serv_esocial
                       , rreg_cod_class_doc_fis
                       , rreg_vlr_tot_nota
                       , rreg_vlr_contab_compl
                       , rreg_vlr_base_inss
                       , rreg_vlr_aliq_inss
                       , rreg_vlr_inss_retido
                       , rreg_ind_tipo_proc
                       , rreg_num_proc_jur
                       , rreg_num_item
                       , rreg_vlr_servico
                       , rreg_ind_tp_proc_adj_adic
                       , rreg_num_proc_adj_adic
                       , rreg_ident_servico
                       , rreg_ident_produto
                       , rreg_cod_param
                    LIMIT 1000;

                montaregistros;
                EXIT WHEN c_conf_inss_maior_bruto%NOTFOUND;
            END LOOP;

            COMMIT;

            CLOSE c_conf_inss_maior_bruto;
        END recregistrosinssmaiorbruto;


        PROCEDURE recregistrosinssaliqdifinform
        IS
        BEGIN
            OPEN c_conf_inss_aliq_dif_informado ( cod_empresa_w
                                                , cod_estab_w
                                                , data_ini_w
                                                , data_fim_w );

            LOOP
                FETCH c_conf_inss_aliq_dif_informado
                    BULK COLLECT INTO rreg_data_emissao
                       , rreg_data_fiscal
                       , rreg_ident_fis_jur
                       , rreg_ident_docto
                       , rreg_num_docfis
                       , rreg_serie_docfis
                       , rreg_sub_serie_docfis
                       , rreg_ident_tipo_serv_esocial
                       , rreg_cod_class_doc_fis
                       , rreg_vlr_tot_nota
                       , rreg_vlr_contab_compl
                       , rreg_vlr_base_inss
                       , rreg_vlr_aliq_inss
                       , rreg_vlr_inss_retido
                       , rreg_ind_tipo_proc
                       , rreg_num_proc_jur
                       , rreg_num_item
                       , rreg_vlr_servico
                       , rreg_ind_tp_proc_adj_adic
                       , rreg_num_proc_adj_adic
                       , rreg_ident_servico
                       , rreg_ident_produto
                       , rreg_cod_param
                    LIMIT 1000;

                montaregistros;
                EXIT WHEN c_conf_inss_aliq_dif_informado%NOTFOUND;
            END LOOP;

            COMMIT;

            CLOSE c_conf_inss_aliq_dif_informado;
        END recregistrosinssaliqdifinform;


        PROCEDURE recregistrosaliqinssinvalida
        IS
        BEGIN
            OPEN c_conf_aliq_inss_invalida ( cod_empresa_w
                                           , cod_estab_w
                                           , data_ini_w
                                           , data_fim_w );

            LOOP
                FETCH c_conf_aliq_inss_invalida
                    BULK COLLECT INTO rreg_data_emissao
                       , rreg_data_fiscal
                       , rreg_ident_fis_jur
                       , rreg_ident_docto
                       , rreg_num_docfis
                       , rreg_serie_docfis
                       , rreg_sub_serie_docfis
                       , rreg_ident_tipo_serv_esocial
                       , rreg_cod_class_doc_fis
                       , rreg_vlr_tot_nota
                       , rreg_vlr_contab_compl
                       , rreg_vlr_base_inss
                       , rreg_vlr_aliq_inss
                       , rreg_vlr_inss_retido
                       , rreg_ind_tipo_proc
                       , rreg_num_proc_jur
                       , rreg_num_item
                       , rreg_vlr_servico
                       , rreg_ind_tp_proc_adj_adic
                       , rreg_num_proc_adj_adic
                       , rreg_ident_servico
                       , rreg_ident_produto
                       , rreg_cod_param
                    LIMIT 1000;

                montaregistros;
                EXIT WHEN c_conf_aliq_inss_invalida%NOTFOUND;
            END LOOP;

            COMMIT;

            CLOSE c_conf_aliq_inss_invalida;
        END recregistrosaliqinssinvalida;
    BEGIN
        p_status := 0;

        cod_empresa_w := p_cod_empresa;
        cod_estab_w := p_cod_estab;
        data_ini_w := p_data_inicial;
        data_fim_w := p_data_final;



        IF p_tipo_selec = '1' THEN
            recregistrosservretprev;
        ELSIF p_tipo_selec = '2' THEN
            recregistrossemtiposerv;
        ELSIF p_tipo_selec = '3' THEN
            recregistrosretprevproc;
        ELSIF p_tipo_selec = '4' THEN
            recregistrosretprevsemproc;
        ELSIF p_tipo_selec = '5' THEN
            recregistrosinssmaiorbruto;
        ELSIF p_tipo_selec = '6' THEN
            recregistrosinssaliqdifinform;
        ELSIF p_tipo_selec = '7' THEN
            recregistrosaliqinssinvalida;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_status := 0;
            RETURN;
        WHEN OTHERS THEN
            p_status := -1;
            RETURN;
    END prc_reinf_conf_retencao;


--    PROCEDURE carga ( pnr_particao INTEGER
--                    , pnr_particao2 INTEGER
--                    , p_data_ini DATE
--                    , p_data_fim DATE
--                    , p_proc_id VARCHAR2
--                    , p_nm_empresa VARCHAR2
--                    , p_nm_usuario VARCHAR2 )
--    IS
--        v_data DATE;
--
--        -- Constantes declaration
--        cc_procedurename CONSTANT VARCHAR2 ( 30 ) := 'INSERT (FIN4816) ... ';
--
--        cc_limit NUMBER ( 7 ) := 10000;
--        vn_count_new NUMBER := 0;
--
--        l_status NUMBER;
--        
--       
--  
--               
--    
--    BEGIN
--                                EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING = FORCE' ;
--                                EXECUTE IMMEDIATE 'ALTER SESSION SET TEMP_UNDO_ENABLED=FALSE ' ;
--                                EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT = ''DD/MM/YYYY''';
--                                EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS= '',.'' ';
--
--                             -- Registra o andamento do processo na v$session
--                              dbms_application_info.set_module ( cc_procedurename, 'n:' || vn_count_new );
--                              v_data := p_data_ini - 1 + pnr_particao;
--                              dbms_application_info.set_module ( cc_procedurename || '  ' || v_data, 'n:' || vn_count_new );
--                          
--                          
--                          
--                          
--
--                             --================================================
--                             -- Table -  report fiscal
--                             --================================================
--                             OPEN cr_rtf ( v_data , p_nm_empresa, p_proc_id );
--                                LOOP
--                                dbms_application_info.set_module ( cc_procedurename, 'Executando o fetch report fiscal ...' );
--                                FETCH cr_rtf BULK COLLECT INTO l_data_fiscal LIMIT cc_limit;                                 
--                                FORALL i IN 1..l_data_fiscal.COUNT
--                                INSERT INTO msafi.tb_fin4816_report_fiscal_tmp VALUES l_data_fiscal(i);
--                                EXIT WHEN cr_rtf%NOTFOUND;
--                                END LOOP;                           
--                             CLOSE cr_rtf;
--                          
--                             
--
--                              
--                             --================================================
--                             --  INSERT Table -  Report Retenção
--                             --  Validações das Retenções Previdenciarias
--                             --================================================  
--                             OPEN rc_prev ( v_data , p_nm_empresa, p_proc_id );
--                                LOOP
--                                dbms_application_info.set_module ( cc_procedurename, 'Executando o fetch report Retenções Previdenciarias ...' );
--                                FETCH rc_prev BULK COLLECT INTO l_data_reinf LIMIT cc_limit;                                 
--                                FORALL i IN 1..l_data_reinf.COUNT
--                                INSERT INTO msafi.tb_fin4816_reinf_prev_tmp VALUES l_data_reinf(i);
--                                EXIT WHEN rc_prev%NOTFOUND;
--                                END LOOP;                           
--                             CLOSE rc_prev;
--                             
--                           
--                             
--                             --================================================
--                             --  INSERT Table -  Report EFD-REINF
--                             --  Conferência dos Eventos R-2010
--                             --================================================  
--                              OPEN rc_2010 ( v_data , p_nm_empresa, p_proc_id );
--                                LOOP
--                                dbms_application_info.set_module ( cc_procedurename, 'Executando o fetch report R-2010 ...' );
--                                FETCH rc_2010 BULK COLLECT INTO l_data_r2010 LIMIT cc_limit;                                 
--                                FORALL i IN 1..l_data_r2010.COUNT
--                                INSERT INTO msafi.tb_fin4816_reinf_2010_tmp VALUES l_data_r2010(i);
--                                EXIT WHEN rc_2010%NOTFOUND;
--                                END LOOP;                           
--                             CLOSE rc_2010;
--                             
--                             
--                            
--                             
--                            
--                 
--    END carga;



    PROCEDURE load_excel ( vp_mproc_id IN NUMBER
                         , v_data_inicial IN DATE
                         , v_data_final IN DATE )
    IS
        v_sql VARCHAR2 ( 20000 );
        v_text01 VARCHAR2 ( 20000 );
        v_class VARCHAR2 ( 1 ) := 'a';
        c_conc SYS_REFCURSOR;
        v_data_inicial_p VARCHAR2 ( 30 );
    BEGIN
        v_data_inicial_p :=
            TO_CHAR ( v_data_inicial
                    , 'MM-YYYY' );

        loga ( v_data_inicial_p );

        lib_proc.add_tipo ( vp_mproc_id
                          , 99
                          , mcod_empresa || '_REL_PREVIDENCIARIO_' || v_data_inicial_p || '_' || '.XLS'
                          , 2 );

        lib_proc.add ( dsp_planilha.header
                     , ptipo => 99 );
        lib_proc.add ( dsp_planilha.tabela_inicio
                     , ptipo => 99 );

        lib_proc.add ( dsp_planilha.linha ( p_conteudo =>    dsp_planilha.campo ( 'Relatório Fiscal'
                                                                                , p_custom => 'COLSPAN=18' )
                                                          || --
                                                            dsp_planilha.campo (
                                                                                 'Relatório Previdenciario'
                                                                               , p_custom => 'COLSPAN=20 BGCOLOR=BLUE'
                                                             )
                                                          || --
                                                            dsp_planilha.campo (
                                                                                 'Relatório Evento R-2010'
                                                                               , p_custom => 'COLSPAN=21 BGCOLOR=GREEN'
                                                             )
                                          , p_class => 'h' )
                     , ptipo => 99 );

        lib_proc.add ( dsp_planilha.linha (
                                            p_conteudo =>    dsp_planilha.campo ( 'Codigo da Empresa' )
                                                          || -- 1
                                                            dsp_planilha.campo ( 'Codigo do Estabelecimento' )
                                                          || -- 2
                                                            dsp_planilha.campo ( 'Periodo de Emissão' )
                                                          || -- 3
                                                            dsp_planilha.campo ( 'CNPJ Drogaria' )
                                                          || -- 4
                                                            dsp_planilha.campo ( 'Numero da Nota Fiscal' )
                                                          || -- 5
                                                            dsp_planilha.campo ( 'Tipo de Documento' )
                                                          || -- 6
                                                            dsp_planilha.campo ( 'Data Emissão' )
                                                          || -- 7
                                                            dsp_planilha.campo ( 'CNPJ_Fonecedor' )
                                                          || -- 8
                                                            dsp_planilha.campo ( 'UF' )
                                                          || -- 9
                                                            dsp_planilha.campo ( 'Valor Total da Nota' )
                                                          || -- 10
                                                            dsp_planilha.campo ( 'Base de Calculo INSS' )
                                                          || -- 11
                                                            dsp_planilha.campo ( 'Valor do INSS' )
                                                          || -- 12
                                                            dsp_planilha.campo ( 'Codigo Pessoa Fisica/juridica' )
                                                          || -- 13
                                                            dsp_planilha.campo ( 'Razão Social' )
                                                          || -- 14
                                                            dsp_planilha.campo ( 'Municipio Prestador' )
                                                          || -- 15
                                                            dsp_planilha.campo ( 'Codigo de Serviço' )
                                                          || -- 16
                                                            dsp_planilha.campo ( 'Codigo CEI' )
                                                          || -- 17
                                                            dsp_planilha.campo ( 'Equalização|S-N' )
                                                          || -- 18
                                                             --  Previdenciario
                                                             dsp_planilha.campo ( 'Cod. da Empresa' )
                                                          || --19
                                                            dsp_planilha.campo ( 'Cod. do Estabelecimento' )
                                                          || --21
                                                            dsp_planilha.campo ( 'Cod. Pessoa Fisica/Juridica' )
                                                          || --22
                                                            dsp_planilha.campo ( 'Razão Social Cliente    ' )
                                                          || --23
                                                            dsp_planilha.campo ( 'CNPJ Cliente(s)' )
                                                          || --24
                                                            dsp_planilha.campo ( 'Nr. da Nota Fiscal' )
                                                          || --25
                                                            dsp_planilha.campo ( 'Data Emissão.' )
                                                          || --26
                                                            dsp_planilha.campo ( 'Data Fiscal.' )
                                                          || --26 *
                                                            dsp_planilha.campo ( 'Vlr. Total da Nota' )
                                                          || --27
                                                            dsp_planilha.campo ( 'Vlr Base de Calculo INSS' )
                                                          || --28
                                                            dsp_planilha.campo ( 'Vlr. Aliquota INSS' )
                                                          || --29
                                                            dsp_planilha.campo ( 'Vlr INSS Retido' )
                                                          || --30
                                                            dsp_planilha.campo ( 'Razão Social Drogaria' )
                                                          || --31
                                                            dsp_planilha.campo ( 'CNPJ-s Drogaria' )
                                                          || --32
                                                            dsp_planilha.campo ( 'Descrição do Tipo de Documento' )
                                                          || --33
                                                            dsp_planilha.campo ( 'Cod. Tipo de Serviço E-social' )
                                                          || --34
                                                            dsp_planilha.campo ( 'Descr. Tipo de Serviço E-social' )
                                                          || --35
                                                            dsp_planilha.campo ( 'Vlr. do Serviço' )
                                                          || --36
                                                            dsp_planilha.campo ( 'Cod. de Serviço Mastersaf' )
                                                          || --37
                                                            dsp_planilha.campo ( 'Descr. Codigo de Serv. Mastersaf' )
                                                          || --38
                                                             --REINF R2010
                                                             dsp_planilha.campo ( 'Codigo Empresa.' )
                                                          || --39
                                                            dsp_planilha.campo ( 'Razão Social Drogaria.' )
                                                          || --40
                                                            dsp_planilha.campo ( 'Razão Social Cliente.' )
                                                          || --41
                                                            dsp_planilha.campo ( 'Número da Nota Fiscal.' )
                                                          || --42
                                                            dsp_planilha.campo ( 'Data de Emissão da NF.' )
                                                          || --43
                                                            dsp_planilha.campo ( 'Data Fiscal.' )
                                                          || --44
                                                            dsp_planilha.campo ( 'Valor do Tributo.' )
                                                          || --45
                                                            dsp_planilha.campo ( 'Observação.' )
                                                          || --46
                                                            dsp_planilha.campo ( 'Tipo de Serviço E-social.' )
                                                          || --47
                                                            dsp_planilha.campo ( 'Vlr. Base de Calculo Retenção.' )
                                                          || --48
                                                            dsp_planilha.campo ( 'Vlr. da Retenção.' ) --49
                                          , p_class => 'h'
                       )
                     , ptipo => 99 );



        FOR i IN rc_excel LOOP
            IF v_class = 'a' THEN
                v_class := 'b';
            ELSE
                v_class := 'a';
            END IF;

            v_text01 :=
                dsp_planilha.linha (
                                     p_conteudo =>   dsp_planilha.campo ( i."Codigo da Empresa" )                                                   || -- 1
                                                     dsp_planilha.campo ( i."Codigo do Estabelecimento" )                                                   || -- 2
                                                     dsp_planilha.campo ( i."Periodo de Emissão" )                                                   || -- 3
                                                     dsp_planilha.campo ( dsp_planilha.texto ( i."CNPJ Drogaria" ) )                                                  || -- 4
                                                     dsp_planilha.campo (
                                                                          dsp_planilha.texto (
                                                                                               i."Numero da Nota Fiscal"
                                                                          )
                                                      )
                                                   || -- 5
                                                     dsp_planilha.campo (
                                                                          dsp_planilha.texto ( i."Tipo de Documento" )
                                                      )
                                                   || -- 6
                                                     dsp_planilha.campo ( i."Data Emissão" )
                                                   || -- 7
                                                     dsp_planilha.campo ( dsp_planilha.texto ( i."CNPJ Fonecedor" ) )
                                                   || -- 8
                                                     dsp_planilha.campo ( dsp_planilha.texto ( i."UF" ) )
                                                   || -- 9
                                                     dsp_planilha.campo ( i."Valor Total da Nota" )
                                                   || -- 10
                                                     dsp_planilha.campo ( i."Base de Calculo INSS" )
                                                   || -- 11
                                                     dsp_planilha.campo ( i."Valor do INSS" )
                                                   || -- 12
                                                     dsp_planilha.campo (
                                                                          dsp_planilha.texto (
                                                                                               i."Codigo Pessoa Fisica/juridica"
                                                                          )
                                                      )
                                                   || -- 13
                                                     dsp_planilha.campo ( dsp_planilha.texto ( i."Razão Social" ) )
                                                   || -- 14
                                                     dsp_planilha.campo (
                                                                          dsp_planilha.texto (
                                                                                               i."Municipio Prestador"
                                                                          )
                                                      )
                                                   || -- 15
                                                     dsp_planilha.campo (
                                                                          dsp_planilha.texto (
                                                                                               i."Codigo de Serviço"
                                                                          )
                                                      )
                                                   || -- 16
                                                     dsp_planilha.campo ( dsp_planilha.texto ( i."Codigo CEI" ) )
                                                   || -- 17
                                                     dsp_planilha.campo ( dsp_planilha.texto ( i."DWT" ) )
                                                   || -- 18
                                                      ---  Relatório Previdenciario
                                                      dsp_planilha.campo ( i.empresa )
                                                   || -- 19
                                                     dsp_planilha.campo (
                                                                          dsp_planilha.texto (
                                                                                               i."Codigo Estabelecimento"
                                                                          )
                                                      )
                                                   || -- 20
                                                     dsp_planilha.campo (
                                                                          dsp_planilha.texto ( i.cod_pessoa_fis_jur )
                                                      )
                                                   || -- 21
                                                     dsp_planilha.campo (
                                                                          dsp_planilha.texto (
                                                                                               i."Razão Social Cliente"
                                                                          )
                                                      )
                                                   || -- 22
                                                     dsp_planilha.campo ( dsp_planilha.texto ( i."CNPJ Cliente" ) )
                                                   || -- 23
                                                     dsp_planilha.campo (
                                                                          dsp_planilha.texto ( i."Nro. Nota Fiscal" )
                                                      )
                                                   || -- 24
                                                     dsp_planilha.campo ( dsp_planilha.texto ( i."Dt. Emissao" ) )
                                                   || -- 25
                                                     dsp_planilha.campo ( dsp_planilha.texto ( i."Dt. Fiscal" ) )
                                                   || -- 26
                                                     dsp_planilha.campo (
                                                                          dsp_planilha.texto (
                                                                                               i."Vlr. Total da Nota"
                                                                          )
                                                      )
                                                   || -- 27
                                                     dsp_planilha.campo (
                                                                          dsp_planilha.texto (
                                                                                               i."Vlr Base Calc. Retenção"
                                                                          )
                                                      )
                                                   || -- 28
                                                     dsp_planilha.campo (
                                                                          dsp_planilha.texto (
                                                                                               i."Vlr. Aliquota INSS"
                                                                          )
                                                      )
                                                   || -- 29
                                                     dsp_planilha.campo (
                                                                          dsp_planilha.texto (
                                                                                               i."Vlr.Trib INSS RETIDO"
                                                                          )
                                                      )
                                                   || -- 30
                                                     dsp_planilha.campo (
                                                                          dsp_planilha.texto (
                                                                                               i."Razão Social Drogaria"
                                                                          )
                                                      )
                                                   || -- 31
                                                     dsp_planilha.campo ( dsp_planilha.texto ( i."CNPJ Drogarias" ) )
                                                   || -- 32
                                                     dsp_planilha.campo (
                                                                          dsp_planilha.texto (
                                                                                               i."Descr. Tp. Documento"
                                                                          )
                                                      )
                                                   || -- 33
                                                     dsp_planilha.campo (
                                                                          dsp_planilha.texto ( i."Tp.Serv. E-social" )
                                                      )
                                                   || -- 34
                                                     dsp_planilha.campo (
                                                                          dsp_planilha.texto (
                                                                                               i."Descr. Tp. Serv E-social"
                                                                          )
                                                      )
                                                   || -- 35
                                                     dsp_planilha.campo ( dsp_planilha.texto ( i."Vlr. do Servico" ) )
                                                   || -- 36
                                                     dsp_planilha.campo (
                                                                          dsp_planilha.texto (
                                                                                               i."Cod. Serv. Mastersaf"
                                                                          )
                                                      )
                                                   || -- 37
                                                     dsp_planilha.campo (
                                                                          dsp_planilha.texto (
                                                                                               i."Descr. Serv. Mastersaf"
                                                                          )
                                                      )
                                                   || -- 38
                                                      -- reinf r2010
                                                      dsp_planilha.campo ( dsp_planilha.texto ( i."Codigo Empresa" ) )
                                                   || -- 39
                                                     dsp_planilha.campo (
                                                                          dsp_planilha.texto (
                                                                                               i."Razão Social Drogaria."
                                                                          )
                                                      )
                                                   || -- 40
                                                     dsp_planilha.campo (
                                                                          dsp_planilha.texto (
                                                                                               i."Razão Social Cliente."
                                                                          )
                                                      )
                                                   || -- 41
                                                     dsp_planilha.campo (
                                                                          dsp_planilha.texto (
                                                                                               i."Número da Nota Fiscal."
                                                                          )
                                                      )
                                                   || -- 42
                                                     dsp_planilha.campo (
                                                                          dsp_planilha.texto (
                                                                                               i."Data de Emissão da NF."
                                                                          )
                                                      )
                                                   || -- 43
                                                     dsp_planilha.campo ( dsp_planilha.texto ( i."Data Fiscal." ) )
                                                   || -- 44
                                                     dsp_planilha.campo (
                                                                          dsp_planilha.texto ( i."Valor do Tributo." )
                                                      )
                                                   || -- 45
                                                     dsp_planilha.campo ( dsp_planilha.texto ( i."Observação." ) )
                                                   || -- 46
                                                     dsp_planilha.campo (
                                                                          dsp_planilha.texto (
                                                                                               i."Tipo de Serviço E-social."
                                                                          )
                                                      )
                                                   || -- 47
                                                     dsp_planilha.campo (
                                                                          dsp_planilha.texto (
                                                                                               i."Vlr. Base de Calc. Retenção."
                                                                          )
                                                      )
                                                   || -- 48
                                                     dsp_planilha.campo (
                                                                          dsp_planilha.texto (
                                                                                               i."Valor da Retenção."
                                                                          )
                                                      ) -- 49
                                   , p_class => v_class
                );
            lib_proc.add ( v_text01
                         , ptipo => 99 );
        END LOOP;

        COMMIT;


        lib_proc.add ( dsp_planilha.tabela_fim
                     , ptipo => 99 );
    END load_excel;

    PROCEDURE prc_upload_table  (p_data_inicial date , p_data_final date , pproc_id number )  
        IS 
        
        
        TYPE array_fiscal IS TABLE OF msafi.tb_fin4816_report_fiscal_gtt%ROWTYPE;
        l_data_fiscal array_fiscal;

        TYPE array_reinf IS TABLE OF msafi.tb_fin4816_reinf_prev_gtt%ROWTYPE;
        l_data_reinf array_reinf;

        TYPE array_r2010 IS TABLE OF msafi.tb_fin4816_reinf_2010_gtt%ROWTYPE;
        l_data_r2010 array_r2010;

        TYPE array_apoio IS TABLE OF msafi.tb_fin4816_rel_apoio_fiscal%ROWTYPE;
        l_data_rel_apoio array_apoio;  
        
     CURSOR cr_rtf 
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
             AND estab.proc_id          = pproc_id
             AND x09_itens_serv.cod_empresa = x07_docto_fiscal.cod_empresa
             AND x09_itens_serv.cod_estab = x07_docto_fiscal.cod_estab
             AND x09_itens_serv.data_fiscal = x07_docto_fiscal.data_fiscal
             AND x07_docto_fiscal.data_emissao between   p_data_inicial  and p_data_final
             --AND   x09_itens_serv.vlr_inss_retido           > 0
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
             AND ( x07_docto_fiscal.cod_estab = estab.cod_estab ) -- COD_ESTAB
             AND ( x07_docto_fiscal.cod_empresa = mcod_empresa )
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
               
               
               
         CURSOR rc_prev 
         IS
         SELECT 'S' AS tipo
             , reinf.cod_empresa AS "Codigo Empresa"
             , reinf.cod_estab AS "Codigo Estabelecimento"
             , reinf.data_emissao AS "Data Emissão"
             , reinf.data_fiscal AS "Data Fiscal"
             , reinf.ident_fis_jur
             , reinf.ident_docto
             , reinf.num_docfis AS "Número da Nota Fiscal"
             --
             , reinf.num_docfis || '/' || reinf.serie_docfis AS "Docto/Série"
             , reinf.data_emissao AS "Emissão"
             --
             , reinf.serie_docfis
             , reinf.sub_serie_docfis
             , reinf.num_item
             , reinf.cod_usuario
             , x04.cod_fis_jur AS "Codigo Pessoa Fisica/Juridica"
             , INITCAP ( x04.razao_social ) AS "Razão Social Cliente"
             , x04.ind_fis_jur
             , x04.cpf_cgc AS "CNPJ Cliente"
             , reinf.cod_class_doc_fis
             , reinf.vlr_tot_nota
             , reinf.vlr_base_inss AS "Vlr Base Calc. Retenção"
             , reinf.vlr_aliq_inss
             , reinf.vlr_inss_retido AS "Vlr.Trib INSS RETIDO"
             , reinf.vlr_inss_retido AS "Valor da Retenção"
             , reinf.vlr_contab_compl
             , reinf.ind_tipo_proc
             , reinf.num_proc_jur
             , estab.razao_social
             , estab.cgc
             , x2005.descricao AS "Documento"
             , prt_tipo.cod_tipo_serv_esocial AS "Tipo de Serviço E-social"
             , prt_tipo.dsc_tipo_serv_esocial
             , INITCAP ( empresa.razao_social ) AS "Razão Social Drogaria"
             , reinf.vlr_servico AS "Valor do Servico"
             , reinf.num_proc_adj_adic
             , reinf.ind_tp_proc_adj_adic
             , x2018.cod_servico AS codigo_serv_prod
             , INITCAP ( x2018.descricao ) AS desc_serv_prod
             , x2005.cod_docto
             , NULL AS "Observação"
             , NULL AS dsc_param
        FROM msafi.tb_fin4816_reinf_conf_prev_gtt reinf     
             , msafi.tb_fin4816_prev_tmp_estab estab1
             , x04_pessoa_fis_jur x04
             , estabelecimento estab
             , x2005_tipo_docto x2005
             , prt_tipo_serv_esocial prt_tipo
             , x2018_servicos x2018
             , empresa
         WHERE 1 = 1
           AND reinf.cod_estab      = estab1.cod_estab -- parametro
           AND estab1.proc_id       = pproc_id -- parametro
           AND reinf.cod_empresa    = mcod_empresa -- parametro
           AND reinf.data_emissao    between   p_data_inicial  and p_data_final
           ---
           AND reinf.ident_fis_jur  = x04.ident_fis_jur
           AND reinf.cod_empresa    = estab.cod_empresa
           AND reinf.cod_estab      = estab.cod_estab
           AND reinf.ident_docto    = x2005.ident_docto
           AND reinf.ident_tipo_serv_esocial = prt_tipo.ident_tipo_serv_esocial /*(+)*/
           AND reinf.cod_empresa    = empresa.cod_empresa
           AND LENGTH ( TRIM ( x04.cpf_cgc ) ) > 11
           AND reinf.ident_servico  = x2018.ident_servico
        UNION
        SELECT 'R' AS tipo
             , reinf.cod_empresa AS "Codigo Empresa"
             , reinf.cod_estab AS "Codigo Estabelecimento"
             , reinf.data_emissao AS "Data Emissão"
             , reinf.data_fiscal AS "Data Fiscal"
             , reinf.ident_fis_jur
             , reinf.ident_docto
             , reinf.num_docfis AS "Número da Nota Fiscal"
             --
             , reinf.num_docfis || '/' || reinf.serie_docfis AS "Docto/Série"
             , reinf.data_emissao AS "Emissão"
             --
             , reinf.serie_docfis
             , reinf.sub_serie_docfis
             , reinf.num_item
             , reinf.cod_usuario
             , x04.cod_fis_jur AS "Codigo Pessoa Fisica/Juridica"
             , INITCAP ( x04.razao_social ) AS "Razão Social Cliente"
             , x04.ind_fis_jur
             , x04.cpf_cgc AS "CNPJ Cliente"
             , reinf.cod_class_doc_fis
             , reinf.vlr_tot_nota
             , reinf.vlr_base_inss AS "Vlr Base Calc. Retenção"
             , reinf.vlr_aliq_inss
             , reinf.vlr_inss_retido AS "Vlr.Trib INSS RETIDO"
             , reinf.vlr_inss_retido AS "Valor da Retenção"
             , reinf.vlr_contab_compl
             , reinf.ind_tipo_proc
             , reinf.num_proc_jur
             , estab.razao_social
             , estab.cgc
             , x2005.descricao AS "Documento"
             , NULL
             , NULL
             , INITCAP ( empresa.razao_social ) AS "Razão Social Drogaria"
             , reinf.vlr_servico AS "Valor do Servico"
             , reinf.num_proc_adj_adic
             , reinf.ind_tp_proc_adj_adic
             , x2018.cod_servico AS codigo_serv_prod
             , INITCAP ( x2018.descricao ) AS desc_serv_prod
             , x2005.cod_docto
             , NULL AS "Observação"
             , prt_repasse.dsc_param
        FROM   msafi.tb_fin4816_reinf_conf_prev_gtt reinf
             , msafi.tb_fin4816_prev_tmp_estab estab1
             , x04_pessoa_fis_jur x04
             , estabelecimento estab
             , x2005_tipo_docto x2005
             , prt_par2_msaf prt_repasse
             , x2018_servicos x2018
             , empresa
         WHERE 1 = 1
           AND reinf.cod_estab      = estab1.cod_estab -- parametro
           AND estab1.proc_id       = pproc_id -- parametro
           AND reinf.cod_empresa    = mcod_empresa -- parametro
           AND reinf.data_emissao    between   p_data_inicial  and p_data_final
           --
           AND reinf.ident_fis_jur = x04.ident_fis_jur
           AND reinf.cod_empresa = estab.cod_empresa
           AND reinf.cod_estab = estab.cod_estab
           AND reinf.ident_docto = x2005.ident_docto
           AND reinf.cod_param = prt_repasse.cod_param
           AND reinf.cod_empresa = empresa.cod_empresa
           AND LENGTH ( TRIM ( x04.cpf_cgc ) ) > 11
           AND reinf.ident_servico = x2018.ident_servico;
           
           
        CURSOR rc_2010 
         IS
        SELECT --  pk
               reinf_pger_apur.cod_empresa AS cod_empresa
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
                   WHERE reinf_pger_apur.id_pger_apur           = reinf_pger_r2010_tom.id_pger_apur
                     AND reinf_pger_r2010_tom.id_r2010_tom      = reinf_pger_r2010_prest.id_r2010_tom
                     AND reinf_pger_r2010_prest.id_r2010_prest  = reinf_pger_r2010_oc.id_r2010_prest
                     AND reinf_pger_apur.cod_empresa            = mcod_empresa               -- parametro
                     AND reinf_pger_apur.dat_apur between  p_data_inicial  and p_data_final  -- parametro
                     AND reinf_pger_apur.ind_r2010 = 'S'
              --    AND reinf_pger_apur.cod_versao >= 'v1_04_00'
                     AND reinf_pger_apur.ind_tp_amb = '2'
                GROUP BY reinf_pger_r2010_prest.id_r2010_prest
                       , reinf_pger_r2010_tom.id_r2010_tom
                       , reinf_pger_apur.id_pger_apur) max_oc
             , msafi.tb_fin4816_prev_tmp_estab estab1
         WHERE 1 = 1
           AND estab1.cod_estab = estabelecimento.cod_estab
           AND estab1.proc_id = pproc_id
           AND reinf_pger_apur.dat_apur between  p_data_inicial  and p_data_final
           AND ( estabelecimento.cod_empresa = reinf_pger_apur.cod_empresa )
           AND ( estabelecimento.cod_estab = reinf_pger_apur.cod_estab )
           AND ( estabelecimento.cod_empresa = empresa.cod_empresa )
           AND ( reinf_pger_r2010_prest.cnpj_prestador = x04_pessoa_fis_jur.cpf_cgc )
           AND x04_pessoa_fis_jur.ident_fis_jur = (SELECT MAX ( x04.ident_fis_jur )
                                                     FROM x04_pessoa_fis_jur x04
                                                    WHERE x04.cpf_cgc = x04_pessoa_fis_jur.cpf_cgc
                                                      AND x04.valid_fis_jur <= p_data_final) -- parametro
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
           AND reinf_pger_apur.ind_tp_amb = '2';
        




        CURSOR rc_apoio_fiscal
         IS 
            SELECT   
                  rpf.cod_empresa AS "Codigo da Empresa"
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
                , NVL ( ( SELECT 'S' 
                            FROM msafi.tb_fin4816_reinf_prev_tmp rprev 
                           WHERE 1 = 1
                             AND rprev."Codigo Empresa" = rpf.cod_empresa
                             AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                             AND rprev."Data Fiscal" = rpf.data_fiscal
                             AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                             AND rprev.num_item = rpf.num_item )
                      , 'N' )
                      AS "DWT"
                ---   campos do Report Previdenciario
                , ( SELECT rprev."Codigo Estabelecimento"
                      FROM msafi.tb_fin4816_reinf_prev_tmp rprev 
                     WHERE 1 = 1
                       AND rprev."Codigo Empresa" = rpf.cod_empresa
                       AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                       AND rprev."Data Fiscal" = rpf.data_fiscal
                       AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                       AND rprev.num_item = rpf.num_item )
                      AS empresa
                , ( SELECT rprev."Codigo Estabelecimento"
                      FROM msafi.tb_fin4816_reinf_prev_tmp rprev 
                     WHERE 1 = 1
                       AND rprev."Codigo Empresa" = rpf.cod_empresa
                       AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                       AND rprev."Data Fiscal" = rpf.data_fiscal
                       AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                       AND rprev.num_item = rpf.num_item )
                      AS "Codigo Estabelecimento"
                , ( SELECT rprev."Codigo Pessoa Fisica/Juridica"
                      FROM msafi.tb_fin4816_reinf_prev_tmp rprev 
                     WHERE 1 = 1
                       AND rprev."Codigo Empresa" = rpf.cod_empresa
                       AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                       AND rprev."Data Fiscal" = rpf.data_fiscal
                       AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                       AND rprev.num_item = rpf.num_item )
                      AS cod_pessoa_fis_jur
                , ( SELECT rprev."Razão Social Cliente"
                      FROM msafi.tb_fin4816_reinf_prev_tmp rprev 
                     WHERE 1 = 1
                       AND rprev."Codigo Empresa" = rpf.cod_empresa
                       AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                       AND rprev."Data Fiscal" = rpf.data_fiscal
                       AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                       AND rprev.num_item = rpf.num_item )
                      AS "Razão Social Cliente"
                , ( SELECT rprev."CNPJ Cliente"
                      FROM msafi.tb_fin4816_reinf_prev_tmp rprev 
                     WHERE 1 = 1
                       AND rprev."Codigo Empresa" = rpf.cod_empresa
                       AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                       AND rprev."Data Fiscal" = rpf.data_fiscal
                       AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                       AND rprev.num_item = rpf.num_item )
                      AS "CNPJ Cliente"
                , ( SELECT rprev."Número da Nota Fiscal"
                      FROM msafi.tb_fin4816_reinf_prev_tmp rprev 
                     WHERE 1 = 1
                       AND rprev."Codigo Empresa" = rpf.cod_empresa
                       AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                       AND rprev."Data Fiscal" = rpf.data_fiscal
                       AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                       AND rprev.num_item = rpf.num_item )
                      AS "Nro. Nota Fiscal"
                , ( SELECT rprev."Emissão"
                      FROM msafi.tb_fin4816_reinf_prev_tmp rprev 
                     WHERE 1 = 1
                       AND rprev."Codigo Empresa" = rpf.cod_empresa
                       AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                       AND rprev."Data Fiscal" = rpf.data_fiscal
                       AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                       AND rprev.num_item = rpf.num_item )
                      AS "Dt. Emissao"
                , ( SELECT rprev."Data Fiscal"
                      FROM msafi.tb_fin4816_reinf_prev_tmp rprev 
                     WHERE 1 = 1
                       AND rprev."Codigo Empresa" = rpf.cod_empresa
                       AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                       AND rprev."Data Fiscal" = rpf.data_fiscal
                       AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                       AND rprev.num_item = rpf.num_item )
                      AS "Dt. Fiscal"
                , ( SELECT rprev.vlr_tot_nota
                      FROM msafi.tb_fin4816_reinf_prev_tmp rprev 
                     WHERE 1 = 1
                       AND rprev."Codigo Empresa" = rpf.cod_empresa
                       AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                       AND rprev."Data Fiscal" = rpf.data_fiscal
                       AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                       AND rprev.num_item = rpf.num_item )
                      AS "Vlr. Total da Nota"
                , ( SELECT rprev."Vlr Base Calc. Retenção"
                      FROM msafi.tb_fin4816_reinf_prev_tmp rprev 
                     WHERE 1 = 1
                       AND rprev."Codigo Empresa" = rpf.cod_empresa
                       AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                       AND rprev."Data Fiscal" = rpf.data_fiscal
                       AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                       AND rprev.num_item = rpf.num_item )
                      AS "Vlr Base Calc. Retenção"
                , ( SELECT rprev.vlr_aliq_inss
                      FROM msafi.tb_fin4816_reinf_prev_tmp rprev 
                     WHERE 1 = 1
                       AND rprev."Codigo Empresa" = rpf.cod_empresa
                       AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                       AND rprev."Data Fiscal" = rpf.data_fiscal
                       AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                       AND rprev.num_item = rpf.num_item )
                      AS "Vlr. Aliquota INSS"
                , ( SELECT rprev."Vlr.Trib INSS RETIDO"
                      FROM msafi.tb_fin4816_reinf_prev_tmp rprev 
                     WHERE 1 = 1
                       AND rprev."Codigo Empresa" = rpf.cod_empresa
                       AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                       AND rprev."Data Fiscal" = rpf.data_fiscal
                       AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                       AND rprev.num_item = rpf.num_item )
                      AS "Vlr.Trib INSS RETIDO"
                , ( SELECT rprev."Razão Social Drogaria"
                      FROM msafi.tb_fin4816_reinf_prev_tmp rprev 
                     WHERE 1 = 1
                       AND rprev."Codigo Empresa" = rpf.cod_empresa
                       AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                       AND rprev."Data Fiscal" = rpf.data_fiscal
                       AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                       AND rprev.num_item = rpf.num_item )
                      AS "Razão Social Drogaria"
                , ( SELECT rprev.cgc
                      FROM msafi.tb_fin4816_reinf_prev_tmp rprev 
                     WHERE 1 = 1
                       AND rprev."Codigo Empresa" = rpf.cod_empresa
                       AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                       AND rprev."Data Fiscal" = rpf.data_fiscal
                       AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                       AND rprev.num_item = rpf.num_item )
                      AS "CNPJ Drogarias"
                , ( SELECT rprev.cod_docto
                      FROM msafi.tb_fin4816_reinf_prev_tmp rprev 
                     WHERE 1 = 1
                       AND rprev."Codigo Empresa" = rpf.cod_empresa
                       AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                       AND rprev."Data Fiscal" = rpf.data_fiscal
                       AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                       AND rprev.num_item = rpf.num_item )
                      AS "Descr. Tp. Documento"
                , ( SELECT rprev."Tipo de Serviço E-social"
                      FROM msafi.tb_fin4816_reinf_prev_tmp rprev 
                     WHERE 1 = 1
                       AND rprev."Codigo Empresa" = rpf.cod_empresa
                       AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                       AND rprev."Data Fiscal" = rpf.data_fiscal
                       AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                       AND rprev.num_item = rpf.num_item )
                      AS "Tp.Serv. E-social"
                , ( SELECT rprev.dsc_tipo_serv_esocial
                      FROM msafi.tb_fin4816_reinf_prev_tmp rprev 
                     WHERE 1 = 1
                       AND rprev."Codigo Empresa" = rpf.cod_empresa
                       AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                       AND rprev."Data Fiscal" = rpf.data_fiscal
                       AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                       AND rprev.num_item = rpf.num_item )
                      AS "Descr. Tp. Serv E-social"
                , ( SELECT rprev."Valor do Servico"
                      FROM msafi.tb_fin4816_reinf_prev_tmp rprev 
                     WHERE 1 = 1
                       AND rprev."Codigo Empresa" = rpf.cod_empresa
                       AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                       AND rprev."Data Fiscal" = rpf.data_fiscal
                       AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                       AND rprev.num_item = rpf.num_item )
                      AS "Vlr. do Servico"
                , ( SELECT rprev.codigo_serv_prod
                      FROM msafi.tb_fin4816_reinf_prev_tmp rprev 
                     WHERE 1 = 1
                       AND rprev."Codigo Empresa" = rpf.cod_empresa
                       AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                       AND rprev."Data Fiscal" = rpf.data_fiscal
                       AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                       AND rprev.num_item = rpf.num_item )
                      AS "Cod. Serv. Mastersaf"
                , ( SELECT rprev.desc_serv_prod
                      FROM msafi.tb_fin4816_reinf_prev_tmp rprev 
                     WHERE 1 = 1
                       AND rprev."Codigo Empresa" = rpf.cod_empresa
                       AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                       AND rprev."Data Fiscal" = rpf.data_fiscal
                       AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                       AND rprev.num_item = rpf.num_item )
                      AS "Descr. Serv. Mastersaf"
                ---
                -- REINF  EVENTO R2010
                ---
                , ( SELECT r2010.cod_empresa
                      FROM msafi.tb_fin4816_reinf_2010_tmp r2010
                     WHERE 1 = 1
                       AND r2010.cod_empresa = rpf.cod_empresa
                       AND r2010.cod_estab = rpf.cod_estab
                       AND r2010.dat_emissao = rpf.data_emissao
                       AND r2010.data_fiscal = rpf.data_fiscal
                       AND r2010.num_docfis = rpf.num_docfis
                       AND r2010.rnk = 1 )
                      AS "Codigo Empresa"
                , ( SELECT INITCAP ( r2010."Razão Social Drogaria" )
                      FROM msafi.tb_fin4816_reinf_2010_tmp r2010
                     WHERE 1 = 1
                       AND r2010.cod_empresa = rpf.cod_empresa
                       AND r2010.cod_estab = rpf.cod_estab
                       AND r2010.dat_emissao = rpf.data_emissao
                       AND r2010.data_fiscal = rpf.data_fiscal
                       AND r2010.num_docfis = rpf.num_docfis
                       AND r2010.rnk = 1 )
                      AS "Razão Social Drogaria."
                , ( SELECT INITCAP ( r2010."Razão Social Cliente" )
                      FROM msafi.tb_fin4816_reinf_2010_tmp r2010
                     WHERE 1 = 1
                       AND r2010.cod_empresa = rpf.cod_empresa
                       AND r2010.cod_estab = rpf.cod_estab
                       AND r2010.dat_emissao = rpf.data_emissao
                       AND r2010.data_fiscal = rpf.data_fiscal
                       AND r2010.num_docfis = rpf.num_docfis
                       AND r2010.rnk = 1 )
                      AS "Razão Social Cliente."
                , ( SELECT ( r2010."Número da Nota Fiscal" )
                      FROM msafi.tb_fin4816_reinf_2010_tmp r2010
                     WHERE 1 = 1
                       AND r2010.cod_empresa = rpf.cod_empresa
                       AND r2010.cod_estab = rpf.cod_estab
                       AND r2010.dat_emissao = rpf.data_emissao
                       AND r2010.data_fiscal = rpf.data_fiscal
                       AND r2010.num_docfis = rpf.num_docfis
                       AND r2010.rnk = 1 )
                      AS "Número da Nota Fiscal."
                , ( SELECT ( r2010."Data de Emissão da NF" )
                      FROM msafi.tb_fin4816_reinf_2010_tmp r2010
                     WHERE 1 = 1
                       AND r2010.cod_empresa = rpf.cod_empresa
                       AND r2010.cod_estab = rpf.cod_estab
                       AND r2010.dat_emissao = rpf.data_emissao
                       AND r2010.data_fiscal = rpf.data_fiscal
                       AND r2010.num_docfis = rpf.num_docfis
                       AND r2010.rnk = 1 )
                      AS "Data de Emissão da NF."
                --
                , ( SELECT ( r2010."Data Fiscal" )
                      FROM msafi.tb_fin4816_reinf_2010_tmp r2010
                     WHERE 1 = 1
                       AND r2010.cod_empresa = rpf.cod_empresa
                       AND r2010.cod_estab = rpf.cod_estab
                       AND r2010.dat_emissao = rpf.data_emissao
                       AND r2010.data_fiscal = rpf.data_fiscal
                       AND r2010.num_docfis = rpf.num_docfis
                       AND r2010.rnk = 1 )
                      AS "Data Fiscal."
                --
                , ( SELECT ( r2010."Valor do Tributo" )
                      FROM msafi.tb_fin4816_reinf_2010_tmp r2010
                     WHERE 1 = 1
                       AND r2010.cod_empresa = rpf.cod_empresa
                       AND r2010.cod_estab = rpf.cod_estab
                       AND r2010.dat_emissao = rpf.data_emissao
                       AND r2010.data_fiscal = rpf.data_fiscal
                       AND r2010.num_docfis = rpf.num_docfis
                       AND r2010.rnk = 1 )
                      AS "Valor do Tributo."
                , ( SELECT INITCAP ( r2010."observacao" )
                      FROM msafi.tb_fin4816_reinf_2010_tmp r2010
                     WHERE 1 = 1
                       AND r2010.cod_empresa = rpf.cod_empresa
                       AND r2010.cod_estab = rpf.cod_estab
                       AND r2010.dat_emissao = rpf.data_emissao
                       AND r2010.data_fiscal = rpf.data_fiscal
                       AND r2010.num_docfis = rpf.num_docfis
                       AND r2010.rnk = 1 )
                      AS "Observação."
                , ( SELECT INITCAP ( r2010."Tipo de Serviço E-social" )
                      FROM msafi.tb_fin4816_reinf_2010_tmp r2010
                     WHERE 1 = 1
                       AND r2010.cod_empresa = rpf.cod_empresa
                       AND r2010.cod_estab = rpf.cod_estab
                       AND r2010.dat_emissao = rpf.data_emissao
                       AND r2010.data_fiscal = rpf.data_fiscal
                       AND r2010.num_docfis = rpf.num_docfis
                       AND r2010.rnk = 1 )
                      AS "Tipo de Serviço E-social."
                , ( SELECT ( r2010."Vlr. Base de Calc. Retenção" )
                      FROM msafi.tb_fin4816_reinf_2010_tmp r2010
                     WHERE 1 = 1
                       AND r2010.cod_empresa = rpf.cod_empresa
                       AND r2010.cod_estab = rpf.cod_estab
                       AND r2010.dat_emissao = rpf.data_emissao
                       AND r2010.data_fiscal = rpf.data_fiscal
                       AND r2010.num_docfis = rpf.num_docfis
                       AND r2010.rnk = 1 )
                      AS "Vlr. Base de Calc. Retenção."
                , ( SELECT ( r2010."Valor da Retenção" )
                      FROM msafi.tb_fin4816_reinf_2010_tmp r2010
                     WHERE 1 = 1
                       AND r2010.cod_empresa = rpf.cod_empresa
                       AND r2010.cod_estab = rpf.cod_estab
                       AND r2010.dat_emissao = rpf.data_emissao
                       AND r2010.data_fiscal = rpf.data_fiscal
                       AND r2010.num_docfis = rpf.num_docfis
                       AND r2010.rnk = 1 )
                      AS "Valor da Retenção."
             FROM msafi.tb_fin4816_report_fiscal_tmp rpf
           ORDER BY   cod_empresa
                    , cod_estab
                    , data_fiscal
                    , movto_e_s
                    , num_docfis
                    , serie_docfis
                    , sub_serie_docfis
                    , num_item
                          ;

        BEGIN
    
             --================================================
             -- Table -  Report Fiscal
             --================================================
             OPEN cr_rtf ;
             LOOP
             FETCH cr_rtf BULK COLLECT INTO l_data_fiscal LIMIT 100;                                 
             FORALL i IN 1..l_data_fiscal.COUNT
             INSERT INTO msafi.tb_fin4816_report_fiscal_tmp VALUES l_data_fiscal(i);
             EXIT WHEN cr_rtf%NOTFOUND;
             END LOOP;                           
             CLOSE cr_rtf;
             
             
             --================================================
             -- Table -  Previsão Dos Retidos 
             --================================================
             OPEN rc_prev ;
             LOOP
             FETCH rc_prev BULK COLLECT INTO l_data_reinf LIMIT 100;                                 
             FORALL i IN 1..l_data_reinf.COUNT
             INSERT INTO msafi.tb_fin4816_reinf_prev_tmp VALUES l_data_reinf(i);
             EXIT WHEN rc_prev%NOTFOUND;
             END LOOP;                           
             CLOSE rc_prev;
             
             
             --================================================
             -- Table -  Reinf - Event - R-2010
             --================================================
             OPEN rc_2010 ;
             LOOP
             FETCH rc_2010 BULK COLLECT INTO l_data_r2010 LIMIT 100;                                 
             FORALL i IN 1..l_data_reinf.COUNT
             INSERT INTO msafi.tb_fin4816_reinf_2010_tmp VALUES l_data_r2010(i);
             EXIT WHEN rc_2010%NOTFOUND;
             END LOOP;                           
             CLOSE rc_2010;   
             COMMIT; 
           
             --================================================
             -- Table -  table final (excel)
             --================================================
             OPEN rc_apoio_fiscal ;
             LOOP
             FETCH rc_apoio_fiscal BULK COLLECT INTO l_data_rel_apoio LIMIT 100;                                 
             FORALL i IN 1..l_data_rel_apoio.COUNT
             INSERT INTO msafi.tb_fin4816_rel_apoio_fiscal VALUES l_data_rel_apoio(i);
             EXIT WHEN rc_apoio_fiscal%NOTFOUND;
             END LOOP;                
             CLOSE rc_apoio_fiscal;        

             --  select * from msafi.tb_fin4816_report_fiscal_tmp             
             --  select * from msafi.tb_fin4816_reinf_prev_tmp
             --  select * from msafi.tb_fin4816_reinf_2010_tmp
             --  select * from msafi.tb_fin4816_rel_apoio_fiscal

    END prc_upload_table; 
    
    
    PROCEDURE prc_limpa_table
    IS
    BEGIN
     delete  msafi.tb_fin4816_rel_apoio_fiscal;   -- unico 
     delete  msafi.tb_fin4816_report_fiscal_tmp;  -- gtt 
     delete  msafi.tb_fin4816_reinf_prev_tmp;     --gtt 
     delete  msafi.tb_fin4816_reinf_2010_tmp;      -- gtt 
     delete  msafi.tb_fin4816_prev_tmp_estab;       -- gtt 
      --  DENTRO DA procedure 
     delete  msafi.tb_fin4816_reinf_conf_prev_gtt;
     commit work;
    END prc_limpa_table; 
    
    

    FUNCTION executar ( pdata_inicial DATE
                      , pdata_final DATE
                      , pcod_estab lib_proc.vartab )
        RETURN INTEGER
    IS
        --Variaveis genericas
        p_lote INTEGER := 10;
        v_descricao VARCHAR2 ( 4000 );
        v_qt_grupos INTEGER := pdata_final - pdata_inicial + 1;
        v_qt_grupos_paralelos INTEGER := 10;
        p_task VARCHAR2 ( 30 );
        v_cont_estab INTEGER := 0;
        l_status NUMBER;
    BEGIN
      
                --  tb_fin4816_reinf_conf_prev_gtt  (transforma em gtt ) 
                --  tb_fin4816_reinf_2010_gtt       (transforma em gtt ) 

                -- reinf 2010     
                --01/2018	590   -- OK 
                --06/2018	2      -- OK 
                --12/2018	95        --OK 
                --05/2018	37      -- OK 
                ---
                --01/2019	1       -- OK 
                --11/2019	2



    
              -- Criação: Processo
        mproc_id :=
            lib_proc.new ( psp_nome => $$plsql_unit
                         , --  prows    => 48,
                           --  pcols    => 200,
                           pdescricao => v_descricao );

        COMMIT;

        p_task := 'PROC_EXCL_' || mproc_id;

        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT="DD/MM/YYYY"';
        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS= '',.'' ';
    
         mcod_empresa := msafi.dpsp.v_empresa;
         mnm_usuario := lib_parametros.recuperar ( 'USUARIO' );
         
         --============================================
         --LIMPA
         --============================================
          prc_limpa_table; 
          
         --============================================
         --LOOP de Estabelecimentos
         --============================================
         FOR v_estab IN pcod_estab.FIRST .. pcod_estab.LAST 
         LOOP
         v_cont_estab := v_cont_estab + 1;
         INSERT INTO msafi.tb_fin4816_prev_tmp_estab
         VALUES ( mproc_id, pcod_estab ( v_estab ), v_cont_estab, SYSDATE );
         COMMIT;
         
         
         --============================================
         -- LOOP de Estabelecimentos /inss retido 
         --============================================
          prc_reinf_conf_retencao( 
                                    p_cod_empresa   => mcod_empresa
                                   ,p_cod_estab     => pcod_estab ( v_estab )   
                                   ,p_tipo_selec    => '1'
                                   ,p_data_inicial  => TO_DATE ( pdata_inicial, 'DD/MM/YYYY')
                                   ,p_data_final    => TO_DATE ( pdata_final, 'DD/MM/YYYY')
                                   ,p_cod_usuario   => mnm_usuario
                                   ,p_entrada_saida => 'E'
                                   ,p_status        => l_status
                                   ,p_proc_id       => NULL);
          LOGA(L_STATUS);
                         
         END LOOP;
         
         
         
         
         --============================================
         -- Upload table (tmp) 
         --============================================
         prc_upload_table (pdata_inicial, pdata_final , mproc_id ); 
         
         
         



            

          loga ( '---FIM DO PROCESSAMENTO---', FALSE );
        
          lib_proc.close;
          RETURN mproc_id;
 
    END;
END dpsp_v3_fin4816_prev_cproc;
/