CREATE OR REPLACE PACKAGE BODY msaf.dpsp_fin4816_prev_cproc
IS
    mproc_id NUMBER;
    mnm_usuario usuario_estab.cod_usuario%TYPE;
    mcod_empresa estabelecimento.cod_empresa%TYPE;

    --Tipo, Nome e Descrição do Customizado
    mnm_tipo VARCHAR2 ( 100 ) := 'Relatorio Previdenciario';
    mnm_cproc VARCHAR2 ( 100 ) := '1.Relatorio de apoio';
    mds_cproc VARCHAR2 ( 100 ) := 'Validacao das Inf. Reinf';

    v_sel_data_fim VARCHAR2 ( 260 )
        := 'SELECT TRUNC( TO_DATE( :1 ,''DD/MM/YYYY'') + ROWNUM - 1) AS DATA_FIM, TRUNC( TO_DATE( :1 ,''DD/MM/YYYY'') + ROWNUM - 1) AS DATA_FIM FROM DUAL CONNECT BY ROWNUM <= LAST_DAY( TO_DATE( :1 ,''DD/MM/YYYY'') ) - TO_DATE( :1 ,''DD/MM/YYYY'') + 1 ORDER BY 1 DESC ';

    i NUMBER := 0;



    -- =======================================
    -- Type  report fiscal / cursor
    -- =======================================

    TYPE typ_cod_empresa IS TABLE OF msafi.fin4816_report_fiscal_gtt.cod_empresa%TYPE;

    TYPE typ_cod_estab IS TABLE OF msafi.fin4816_report_fiscal_gtt.cod_estab%TYPE;

    TYPE typ_data_fiscal IS TABLE OF msafi.fin4816_report_fiscal_gtt.data_fiscal%TYPE;

    TYPE typ_movto_e_s IS TABLE OF msafi.fin4816_report_fiscal_gtt.movto_e_s%TYPE;

    TYPE typ_norm_dev IS TABLE OF msafi.fin4816_report_fiscal_gtt.norm_dev%TYPE;

    TYPE typ_ident_docto IS TABLE OF msafi.fin4816_report_fiscal_gtt.ident_docto%TYPE;

    TYPE typ_ident_fis_jur IS TABLE OF msafi.fin4816_report_fiscal_gtt.ident_fis_jur%TYPE;

    TYPE typ_num_docfis IS TABLE OF msafi.fin4816_report_fiscal_gtt.num_docfis%TYPE;

    TYPE typ_serie_docfis IS TABLE OF msafi.fin4816_report_fiscal_gtt.serie_docfis%TYPE;

    TYPE typ_sub_serie_docfis IS TABLE OF msafi.fin4816_report_fiscal_gtt.sub_serie_docfis%TYPE;

    TYPE typ_ident_servico IS TABLE OF msafi.fin4816_report_fiscal_gtt.ident_servico%TYPE;

    TYPE typ_num_item IS TABLE OF msafi.fin4816_report_fiscal_gtt.num_item%TYPE;

    TYPE typ_periodo_emissao IS TABLE OF msafi.fin4816_report_fiscal_gtt.periodo_emissao%TYPE;

    TYPE typ_cgc IS TABLE OF msafi.fin4816_report_fiscal_gtt.cgc%TYPE;

    TYPE typ_num_docto IS TABLE OF msafi.fin4816_report_fiscal_gtt.num_docto%TYPE;

    TYPE typ_tipo_docto IS TABLE OF msafi.fin4816_report_fiscal_gtt.tipo_docto%TYPE;

    TYPE typ_data_emissao IS TABLE OF msafi.fin4816_report_fiscal_gtt.data_emissao%TYPE;

    TYPE typ_cgc_fornecedor IS TABLE OF msafi.fin4816_report_fiscal_gtt.cgc_fornecedor%TYPE;

    TYPE typ_uf IS TABLE OF msafi.fin4816_report_fiscal_gtt.uf%TYPE;

    TYPE typ_valor_total IS TABLE OF msafi.fin4816_report_fiscal_gtt.valor_total%TYPE;

    TYPE typ_vlr_base_inss IS TABLE OF msafi.fin4816_report_fiscal_gtt.vlr_base_inss%TYPE;

    TYPE typ_vlr_inss IS TABLE OF msafi.fin4816_report_fiscal_gtt.vlr_inss%TYPE;

    TYPE typ_codigo_fisjur IS TABLE OF msafi.fin4816_report_fiscal_gtt.codigo_fisjur%TYPE;

    TYPE typ_razao_social IS TABLE OF msafi.fin4816_report_fiscal_gtt.razao_social%TYPE;

    TYPE typ_municipio_prestador IS TABLE OF msafi.fin4816_report_fiscal_gtt.municipio_prestador%TYPE;

    TYPE typ_cod_servico IS TABLE OF msafi.fin4816_report_fiscal_gtt.cod_servico%TYPE;

    TYPE typ_cod_cei IS TABLE OF msafi.fin4816_report_fiscal_gtt.cod_cei%TYPE;

    TYPE typ_equalizacao IS TABLE OF msafi.fin4816_report_fiscal_gtt.equalizacao%TYPE;


    g_cod_empresa typ_cod_empresa;
    g_cod_estab typ_cod_estab;
    g_data_fiscal typ_data_fiscal;
    g_movto_e_s typ_movto_e_s;
    g_norm_dev typ_norm_dev;
    g_ident_docto typ_ident_docto;
    g_ident_fis_jur typ_ident_fis_jur;
    g_num_docfis typ_num_docfis;
    g_serie_docfis typ_serie_docfis;
    g_sub_serie_docfis typ_sub_serie_docfis;
    g_ident_servico typ_ident_servico;
    g_num_item typ_num_item;
    g_periodo_emissao typ_periodo_emissao;
    g_cgc typ_cgc;
    g_num_docto typ_num_docto;
    g_tipo_docto typ_tipo_docto;
    g_data_emissao typ_data_emissao;
    g_cgc_fornecedor typ_cgc_fornecedor;
    g_uf typ_uf;
    g_valor_total typ_valor_total;
    g_vlr_base_inss typ_vlr_base_inss;
    g_vlr_inss typ_vlr_inss;
    g_codigo_fisjur typ_codigo_fisjur;
    g_razao_social typ_razao_social;
    g_municipio_prestador typ_municipio_prestador;
    g_cod_servico typ_cod_servico;
    g_equalizacao typ_equalizacao;
    g_cod_cei typ_cod_cei;



    CURSOR cr_rtf ( pdate DATE
                  , pcod_empresa VARCHAR2
                  , p_proc_id NUMBER )
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
               , msafi.fin4816_prev_tmp_estab estab
           WHERE 1 = 1
             AND x09_itens_serv.cod_empresa = estabelecimento.cod_empresa
             AND x09_itens_serv.cod_estab = estabelecimento.cod_estab
             AND x09_itens_serv.cod_estab = estab.cod_estab
             AND estab.proc_id = p_proc_id
             AND x09_itens_serv.cod_empresa = x07_docto_fiscal.cod_empresa
             AND x09_itens_serv.cod_estab = x07_docto_fiscal.cod_estab
             AND x09_itens_serv.data_fiscal = x07_docto_fiscal.data_fiscal
             AND x07_docto_fiscal.data_emissao = pdate
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



    -- =======================================
    -- Type  previdenciario/ cursor
    -- =======================================
    TYPE typ_tipo_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.tipo%TYPE;

    TYPE typ_codigo_empresa_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Codigo Empresa"%TYPE;

    TYPE typ_codigo_estab_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Codigo Estabelecimento"%TYPE;

    TYPE typ_data_emissao_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Data Emissão"%TYPE;

    TYPE typ_data_fiscal_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Data Fiscal"%TYPE;

    TYPE typ_ident_fis_jur_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.ident_fis_jur%TYPE;

    TYPE typ_ident_docto_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.ident_docto%TYPE;

    TYPE typ_numero_nota_fiscal_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Número da Nota Fiscal"%TYPE;

    TYPE typ_docto_serie_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Docto/Série"%TYPE;

    TYPE typ_emissao_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Emissão"%TYPE;

    TYPE typ_serie_docfis_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.serie_docfis%TYPE;

    TYPE typ_sub_serie_docfis_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.sub_serie_docfis%TYPE;

    TYPE typ_num_item_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.num_item%TYPE;

    TYPE typ_cod_usuario_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.cod_usuario%TYPE;

    TYPE typ_codigo_pess_fis_jur_prv
        IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Codigo Pessoa Fisica/Juridica"%TYPE;

    TYPE typ_razao_social_cliente_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Razão Social Cliente"%TYPE;

    TYPE typ_ind_fis_jur_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.ind_fis_jur%TYPE;

    TYPE typ_cnpj_cliente_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."CNPJ Cliente"%TYPE;

    TYPE typ_cod_class_doc_fis_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.cod_class_doc_fis%TYPE;

    TYPE typ_vlr_tot_nota_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.vlr_tot_nota%TYPE;

    TYPE typ_vlr_bs_calc_retencao_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Vlr Base Calc. Retenção"%TYPE;

    TYPE typ_vlr_aliq_inss_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.vlr_aliq_inss%TYPE;

    TYPE typ_vlr_trib_inss_retido_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Vlr.Trib INSS RETIDO"%TYPE;

    TYPE typ_vlr_retencao_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Valor da Retenção"%TYPE;

    TYPE typ_vlr_contab_compl_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.vlr_contab_compl%TYPE;

    TYPE typ_ind_tipo_proc_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.ind_tipo_proc%TYPE;

    TYPE typ_num_proc_jur_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.num_proc_jur%TYPE;

    TYPE typ_razao_social_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.razao_social%TYPE;

    TYPE typ_cgc_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.cgc%TYPE;

    TYPE typ_documento_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Documento"%TYPE;

    TYPE typ_tipo_serv_e_social_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Tipo de Serviço E-social"%TYPE;

    TYPE typ_dsc_tipo_serv_esocial_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.dsc_tipo_serv_esocial%TYPE;

    TYPE typ_razao_social_drogaria_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Razão Social Drogaria"%TYPE;

    TYPE typ_valor_servico_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Valor do Servico"%TYPE;

    TYPE typ_num_proc_adj_adic_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.num_proc_adj_adic%TYPE;

    TYPE typ_ind_tp_proc_adj_adic_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.ind_tp_proc_adj_adic%TYPE;

    TYPE typ_codigo_serv_prod_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.codigo_serv_prod%TYPE;

    TYPE typ_desc_serv_prod_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.desc_serv_prod%TYPE;

    TYPE typ_cod_docto_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.cod_docto%TYPE;

    TYPE typ_observação_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Observação"%TYPE;

    TYPE typ_dsc_param_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.dsc_param%TYPE;

    g_tipo_prv typ_tipo_prv;
    g_codigo_empresa_prv typ_codigo_empresa_prv;
    g_codigo_estab_prv typ_codigo_estab_prv;
    g_data_emissao_prv typ_data_emissao_prv;
    g_data_fiscal_prv typ_data_fiscal_prv;
    g_ident_fis_jur_prv typ_ident_fis_jur_prv;
    g_ident_docto_prv typ_ident_docto_prv;
    g_numero_nota_fiscal_prv typ_numero_nota_fiscal_prv;
    g_docto_serie_prv typ_docto_serie_prv;
    g_emissao_prv typ_emissao_prv;
    g_serie_docfis_prv typ_serie_docfis_prv;
    g_sub_serie_docfis_prv typ_sub_serie_docfis_prv;
    g_num_item_prv typ_num_item_prv;
    g_cod_usuario_prv typ_cod_usuario_prv;
    g_codigo_pess_fis_jur_prv typ_codigo_pess_fis_jur_prv;
    g_razao_social_cliente_prv typ_razao_social_cliente_prv;
    g_ind_fis_jur_prv typ_ind_fis_jur_prv;
    g_cnpj_cliente_prv typ_cnpj_cliente_prv;
    g_cod_class_doc_fis_prv typ_cod_class_doc_fis_prv;
    g_vlr_tot_nota_prv typ_vlr_tot_nota_prv;
    g_vlr_bs_calc_retencao_prv typ_vlr_bs_calc_retencao_prv;
    g_vlr_aliq_inss_prv typ_vlr_aliq_inss_prv;
    g_vlr_trib_inss_retido_prv typ_vlr_trib_inss_retido_prv;
    g_vlr_retencao_prv typ_vlr_retencao_prv; --
    g_vlr_contab_compl_prv typ_vlr_contab_compl_prv;
    g_ind_tipo_proc_prv typ_ind_tipo_proc_prv;
    g_num_proc_jur_prv typ_num_proc_jur_prv;
    g_razao_social_prv typ_razao_social_prv;
    g_cgc_prv typ_cgc_prv;
    g_documento_prv typ_documento_prv;
    g_tipo_serv_e_social_prv typ_tipo_serv_e_social_prv;
    g_dsc_tipo_serv_esocial_prv typ_dsc_tipo_serv_esocial_prv;
    g_razao_social_drogaria_prv typ_razao_social_drogaria_prv;
    g_valor_servico_prv typ_valor_servico_prv;
    g_num_proc_adj_adic_prv typ_num_proc_adj_adic_prv;
    g_ind_tp_proc_adj_adic_prv typ_ind_tp_proc_adj_adic_prv;
    g_codigo_serv_prod_prv typ_codigo_serv_prod_prv;
    g_desc_serv_prod_prv typ_desc_serv_prod_prv;
    g_cod_docto_prv typ_cod_docto_prv;
    g_observação_prv typ_observação_prv;
    g_dsc_param_prv typ_dsc_param_prv;



    CURSOR rc_prev ( pdate DATE
                   , pcod_empresa VARCHAR2
                   , p_proc_id NUMBER )
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
          FROM msafi.reinf_conf_previdenciaria_tmp reinf
             , msafi.fin4816_prev_tmp_estab estab1
             , x04_pessoa_fis_jur x04
             , estabelecimento estab
             , x2005_tipo_docto x2005
             , prt_tipo_serv_esocial prt_tipo
             , x2018_servicos x2018
             , empresa
         WHERE 1 = 1
           AND reinf.cod_estab = estab1.cod_estab -- parametro
           AND estab1.proc_id = p_proc_id -- parametro
           AND reinf.cod_empresa = pcod_empresa -- parametro
           AND reinf.data_emissao = pdate -- parametro
           ---
           AND reinf.ident_fis_jur = x04.ident_fis_jur
           AND reinf.cod_empresa = estab.cod_empresa
           AND reinf.cod_estab = estab.cod_estab
           AND reinf.ident_docto = x2005.ident_docto
           AND reinf.ident_tipo_serv_esocial = prt_tipo.ident_tipo_serv_esocial /*(+)*/
           AND reinf.cod_empresa = empresa.cod_empresa
           AND LENGTH ( TRIM ( x04.cpf_cgc ) ) > 11
           AND reinf.ident_servico = x2018.ident_servico
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
          FROM msafi.reinf_conf_previdenciaria_tmp reinf
             , msafi.fin4816_prev_tmp_estab estab1
             , x04_pessoa_fis_jur x04
             , estabelecimento estab
             , x2005_tipo_docto x2005
             , prt_par2_msaf prt_repasse
             , x2018_servicos x2018
             , empresa
         WHERE 1 = 1
           AND reinf.cod_estab = estab1.cod_estab -- parametro
           AND estab1.proc_id = p_proc_id -- parametro
           AND reinf.cod_empresa = pcod_empresa -- parametro
           AND reinf.data_emissao = pdate -- parametro
           --
           AND reinf.ident_fis_jur = x04.ident_fis_jur
           AND reinf.cod_empresa = estab.cod_empresa
           AND reinf.cod_estab = estab.cod_estab
           AND reinf.ident_docto = x2005.ident_docto
           AND reinf.cod_param = prt_repasse.cod_param
           AND reinf.cod_empresa = empresa.cod_empresa
           AND LENGTH ( TRIM ( x04.cpf_cgc ) ) > 11
           AND reinf.ident_servico = x2018.ident_servico;



    -- =======================================
    --    Type  REINF 2010 / cursor
    -- =======================================

    TYPE typ_cod_empresa2 IS TABLE OF msafi.fin4816_reinf_2010_gtt.cod_empresa%TYPE;

    TYPE typ_cod_estab2 IS TABLE OF msafi.fin4816_reinf_2010_gtt.cod_estab%TYPE;

    TYPE typ_dat_emissao2 IS TABLE OF msafi.fin4816_reinf_2010_gtt.dat_emissao%TYPE;

    TYPE typ_iden_fis_jur2 IS TABLE OF msafi.fin4816_reinf_2010_gtt.iden_fis_jur%TYPE;

    TYPE typ_num_docfis2 IS TABLE OF msafi.fin4816_reinf_2010_gtt.num_docfis%TYPE;

    TYPE typ_cd_empresa IS TABLE OF msafi.fin4816_reinf_2010_gtt."Codigo Empresa"%TYPE;

    TYPE typ_rz_social_drogaria IS TABLE OF msafi.fin4816_reinf_2010_gtt."Razão Social Drogaria"%TYPE;

    TYPE typ_rz_social_client IS TABLE OF msafi.fin4816_reinf_2010_gtt."Razão Social Cliente"%TYPE;

    TYPE typ_ntf IS TABLE OF msafi.fin4816_reinf_2010_gtt."Número da Nota Fiscal"%TYPE;

    TYPE typ_data_emissao_nf IS TABLE OF msafi.fin4816_reinf_2010_gtt."Data de Emissão da NF"%TYPE;

    TYPE typ_data_fiscal2 IS TABLE OF msafi.fin4816_reinf_2010_gtt."Data Fiscal"%TYPE;

    TYPE typ_vlr_tributo IS TABLE OF msafi.fin4816_reinf_2010_gtt."Valor do Tributo"%TYPE;

    TYPE typ_observacao IS TABLE OF msafi.fin4816_reinf_2010_gtt."observacao"%TYPE;

    TYPE typ_tp_servico_e_social IS TABLE OF msafi.fin4816_reinf_2010_gtt."Tipo de Serviço E-social"%TYPE;

    TYPE typ_vlr_bs_calc_retencao IS TABLE OF msafi.fin4816_reinf_2010_gtt."Vlr. Base de Calc. Retenção"%TYPE;

    TYPE typ_vlr_retencao IS TABLE OF msafi.fin4816_reinf_2010_gtt."Valor da Retenção"%TYPE;

    TYPE typ_proc_id IS TABLE OF msafi.fin4816_reinf_2010_gtt.proc_id%TYPE;

    TYPE typ_ind_status IS TABLE OF msafi.fin4816_reinf_2010_gtt.ind_status%TYPE;

    TYPE typ_cnpj_prestador IS TABLE OF msafi.fin4816_reinf_2010_gtt.cnpj_prestador%TYPE;

    TYPE typ_ind_obra IS TABLE OF msafi.fin4816_reinf_2010_gtt.ind_obra%TYPE;

    TYPE typ_tp_inscricao IS TABLE OF msafi.fin4816_reinf_2010_gtt.tp_inscricao%TYPE;

    TYPE typ_nr_inscricao IS TABLE OF msafi.fin4816_reinf_2010_gtt.nr_inscricao%TYPE;

    TYPE typ_num_recibo IS TABLE OF msafi.fin4816_reinf_2010_gtt.num_recibo%TYPE;

    TYPE typ_ind_tp_amb IS TABLE OF msafi.fin4816_reinf_2010_gtt.ind_tp_amb%TYPE;

    TYPE typ_vlr_bruto IS TABLE OF msafi.fin4816_reinf_2010_gtt.vlr_bruto%TYPE;

    TYPE typ_vlr_base_ret IS TABLE OF msafi.fin4816_reinf_2010_gtt.vlr_base_ret%TYPE;

    TYPE typ_vlr_ret_princ IS TABLE OF msafi.fin4816_reinf_2010_gtt.vlr_ret_princ%TYPE;

    TYPE typ_vlr_ret_adic IS TABLE OF msafi.fin4816_reinf_2010_gtt.vlr_ret_adic%TYPE;

    TYPE typ_vlr_n_ret_princ IS TABLE OF msafi.fin4816_reinf_2010_gtt.vlr_n_ret_princ%TYPE;

    TYPE typ_vlr_n_ret_adic IS TABLE OF msafi.fin4816_reinf_2010_gtt.vlr_n_ret_adic%TYPE;

    TYPE typ_ind_cprb IS TABLE OF msafi.fin4816_reinf_2010_gtt.ind_cprb%TYPE;

    TYPE typ_cod_versao_proc IS TABLE OF msafi.fin4816_reinf_2010_gtt.cod_versao_proc%TYPE;

    TYPE typ_cod_versao_layout IS TABLE OF msafi.fin4816_reinf_2010_gtt.cod_versao_layout%TYPE;

    TYPE typ_ind_proc_emissao IS TABLE OF msafi.fin4816_reinf_2010_gtt.ind_proc_emissao%TYPE;

    TYPE typ_id_evento IS TABLE OF msafi.fin4816_reinf_2010_gtt.id_evento%TYPE;

    TYPE typ_ind_oper IS TABLE OF msafi.fin4816_reinf_2010_gtt.ind_oper%TYPE;

    TYPE typ_dat_ocorrencia IS TABLE OF msafi.fin4816_reinf_2010_gtt.dat_ocorrencia%TYPE;

    TYPE typ_cgc_cpf IS TABLE OF msafi.fin4816_reinf_2010_gtt.cgc%TYPE;

    TYPE typ_rz_social IS TABLE OF msafi.fin4816_reinf_2010_gtt.razao_social%TYPE;

    TYPE typ_x04_razao_social IS TABLE OF msafi.fin4816_reinf_2010_gtt.x04_razao_social%TYPE;

    TYPE typ_id_r2010_oc IS TABLE OF msafi.fin4816_reinf_2010_gtt.id_r2010_oc%TYPE;

    TYPE typ_nm_docto IS TABLE OF msafi.fin4816_reinf_2010_gtt.num_docto%TYPE;

    TYPE typ_serie IS TABLE OF msafi.fin4816_reinf_2010_gtt.serie%TYPE;

    TYPE typ_dat_emissao_nf IS TABLE OF msafi.fin4816_reinf_2010_gtt.dat_emissao_nf%TYPE;

    TYPE typ_dt_fiscal IS TABLE OF msafi.fin4816_reinf_2010_gtt.data_fiscal%TYPE;

    TYPE typ_rnf_vlr_bruto IS TABLE OF msafi.fin4816_reinf_2010_gtt.rnf_vlr_bruto%TYPE;

    TYPE typ_obs IS TABLE OF msafi.fin4816_reinf_2010_gtt.observacao%TYPE;

    TYPE typ_id_r2010_nf IS TABLE OF msafi.fin4816_reinf_2010_gtt.id_r2010_nf%TYPE;

    TYPE typ_ind_tp_proc_adj_adic IS TABLE OF msafi.fin4816_reinf_2010_gtt.ind_tp_proc_adj_adic%TYPE;

    TYPE typ_num_proc_adj_adic IS TABLE OF msafi.fin4816_reinf_2010_gtt.num_proc_adj_adic%TYPE;

    TYPE typ_cod_susp_adic IS TABLE OF msafi.fin4816_reinf_2010_gtt.cod_susp_adic%TYPE;

    TYPE typ_radic_vlr_n_ret_adic IS TABLE OF msafi.fin4816_reinf_2010_gtt.radic_vlr_n_ret_adic%TYPE;

    TYPE typ_ind_tp_proc_adj_princ IS TABLE OF msafi.fin4816_reinf_2010_gtt.ind_tp_proc_adj_princ%TYPE;

    TYPE typ_num_proc_adj_princ IS TABLE OF msafi.fin4816_reinf_2010_gtt.num_proc_adj_princ%TYPE;

    TYPE typ_cod_susp_princ IS TABLE OF msafi.fin4816_reinf_2010_gtt.cod_susp_princ%TYPE;

    TYPE typ_rprinc_vlr_n_ret_princ IS TABLE OF msafi.fin4816_reinf_2010_gtt.rprinc_vlr_n_ret_princ%TYPE;

    TYPE typ_tp_servico IS TABLE OF msafi.fin4816_reinf_2010_gtt.tp_servico%TYPE;

    TYPE typ_rserv_vlr_base_ret IS TABLE OF msafi.fin4816_reinf_2010_gtt.rserv_vlr_base_ret%TYPE;

    TYPE typ_valor_retencao IS TABLE OF msafi.fin4816_reinf_2010_gtt.vlr_retencao%TYPE;

    TYPE typ_vlr_ret_sub IS TABLE OF msafi.fin4816_reinf_2010_gtt.vlr_ret_sub%TYPE;

    TYPE typ_rserv_vlr_n_ret_princ IS TABLE OF msafi.fin4816_reinf_2010_gtt.rserv_vlr_n_ret_princ%TYPE;

    TYPE typ_vlr_servicos_15 IS TABLE OF msafi.fin4816_reinf_2010_gtt.vlr_servicos_15%TYPE;

    TYPE typ_vlr_servicos_20 IS TABLE OF msafi.fin4816_reinf_2010_gtt.vlr_servicos_20%TYPE;

    TYPE typ_vlr_servicos_25 IS TABLE OF msafi.fin4816_reinf_2010_gtt.vlr_servicos_25%TYPE;

    TYPE typ_rserv_vlr_ret_adic IS TABLE OF msafi.fin4816_reinf_2010_gtt.rserv_vlr_ret_adic%TYPE;

    TYPE typ_rserv_vlr_n_ret_adic IS TABLE OF msafi.fin4816_reinf_2010_gtt.rserv_vlr_n_ret_adic%TYPE;

    TYPE typ_rnk IS TABLE OF msafi.fin4816_reinf_2010_gtt.rnk%TYPE;

    TYPE typ_id_pger_apur IS TABLE OF msafi.fin4816_reinf_2010_gtt.id_pger_apur%TYPE;

    g_cod_empresa2 typ_cod_empresa2;
    g_cod_estab2 typ_cod_estab2;
    g_dat_emissao2 typ_dat_emissao2;
    g_iden_fis_jur2 typ_iden_fis_jur2;
    g_num_docfis2 typ_num_docfis2;
    g_cd_empresa typ_cd_empresa;
    g_rz_social_drogaria typ_rz_social_drogaria;
    g_rz_social_client typ_rz_social_client;
    g_ntf typ_ntf;
    g_data_emissao_nf typ_data_emissao_nf;
    g_data_fiscal2 typ_data_fiscal2;
    g_vlr_tributo typ_vlr_tributo;
    g_observacao typ_observacao;
    g_tp_servico_e_social typ_tp_servico_e_social;
    g_vlr_bs_calc_retencao typ_vlr_bs_calc_retencao;
    g_vlr_retencao typ_vlr_retencao;
    g_proc_id typ_proc_id;
    g_ind_status typ_ind_status;
    g_cnpj_prestador typ_cnpj_prestador;
    g_ind_obra typ_ind_obra;
    g_tp_inscricao typ_tp_inscricao;
    g_nr_inscricao typ_nr_inscricao;
    g_num_recibo typ_num_recibo;
    g_ind_tp_amb typ_ind_tp_amb;
    g_vlr_bruto typ_vlr_bruto;
    g_vlr_base_ret typ_vlr_base_ret;
    g_vlr_ret_princ typ_vlr_ret_princ;
    g_vlr_ret_adic typ_vlr_ret_adic;
    g_vlr_n_ret_princ typ_vlr_n_ret_princ;
    g_vlr_n_ret_adic typ_vlr_n_ret_adic;
    g_ind_cprb typ_ind_cprb;
    g_cod_versao_proc typ_cod_versao_proc;
    g_cod_versao_layout typ_cod_versao_layout;
    g_ind_proc_emissao typ_ind_proc_emissao;
    g_id_evento typ_id_evento;
    g_ind_oper typ_ind_oper;
    g_dat_ocorrencia typ_dat_ocorrencia;
    g_cgc_cpf typ_cgc_cpf;
    g_rz_social typ_rz_social;
    g_x04_razao_social typ_x04_razao_social;
    g_id_r2010_oc typ_id_r2010_oc;
    g_nm_docto typ_nm_docto;
    g_serie typ_serie;
    g_dat_emissao_nf typ_dat_emissao_nf;
    g_dt_fiscal typ_dt_fiscal;
    g_rnf_vlr_bruto typ_rnf_vlr_bruto;
    g_obs typ_obs;
    g_id_r2010_nf typ_id_r2010_nf;
    g_ind_tp_proc_adj_adic typ_ind_tp_proc_adj_adic;
    g_num_proc_adj_adic typ_num_proc_adj_adic;
    g_cod_susp_adic typ_cod_susp_adic;
    g_radic_vlr_n_ret_adic typ_radic_vlr_n_ret_adic;
    g_ind_tp_proc_adj_princ typ_ind_tp_proc_adj_princ;
    g_num_proc_adj_princ typ_num_proc_adj_princ;
    g_cod_susp_princ typ_cod_susp_princ;
    g_rprinc_vlr_n_ret_princ typ_rprinc_vlr_n_ret_princ;
    g_tp_servico typ_tp_servico;
    g_rserv_vlr_base_ret typ_rserv_vlr_base_ret;
    g_valor_retencao typ_valor_retencao;
    g_vlr_ret_sub typ_vlr_ret_sub;
    g_rserv_vlr_n_ret_princ typ_rserv_vlr_n_ret_princ;
    g_vlr_servicos_15 typ_vlr_servicos_15;
    g_vlr_servicos_20 typ_vlr_servicos_20;
    g_vlr_servicos_25 typ_vlr_servicos_25;
    g_rserv_vlr_ret_adic typ_rserv_vlr_ret_adic;
    g_rserv_vlr_n_ret_adic typ_rserv_vlr_n_ret_adic;
    g_rnk typ_rnk;
    g_id_pger_apur typ_id_pger_apur;



    CURSOR rc_2010 ( pdate DATE
                   , pcod_empresa VARCHAR2
                   , p_proc_id NUMBER )
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
                   WHERE reinf_pger_apur.id_pger_apur = reinf_pger_r2010_tom.id_pger_apur
                     AND reinf_pger_r2010_tom.id_r2010_tom = reinf_pger_r2010_prest.id_r2010_tom
                     AND reinf_pger_r2010_prest.id_r2010_prest = reinf_pger_r2010_oc.id_r2010_prest
                     AND reinf_pger_apur.cod_empresa = pcod_empresa -- parametro
                     AND reinf_pger_apur.dat_apur = pdate -- parametro
                     AND reinf_pger_apur.ind_r2010 = 'S'
                     --                       AND reinf_pger_apur.cod_versao >= 'v1_04_00'
                     AND reinf_pger_apur.ind_tp_amb = '2'
                GROUP BY reinf_pger_r2010_prest.id_r2010_prest
                       , reinf_pger_r2010_tom.id_r2010_tom
                       , reinf_pger_apur.id_pger_apur) max_oc
             , msafi.fin4816_prev_tmp_estab estab1
         WHERE 1 = 1
           AND estab1.cod_estab = estabelecimento.cod_estab
           AND estab1.proc_id = p_proc_id
           AND reinf_pger_apur.dat_apur = pdate
           AND ( estabelecimento.cod_empresa = reinf_pger_apur.cod_empresa )
           AND ( estabelecimento.cod_estab = reinf_pger_apur.cod_estab )
           AND ( estabelecimento.cod_empresa = empresa.cod_empresa )
           AND ( reinf_pger_r2010_prest.cnpj_prestador = x04_pessoa_fis_jur.cpf_cgc )
           AND x04_pessoa_fis_jur.ident_fis_jur = (SELECT MAX ( x04.ident_fis_jur )
                                                     FROM x04_pessoa_fis_jur x04
                                                    WHERE x04.cpf_cgc = x04_pessoa_fis_jur.cpf_cgc
                                                      AND x04.valid_fis_jur <= pdate) -- parametro
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



    CURSOR rc_excel
    IS
        SELECT   rpf.cod_empresa AS "Codigo da Empresa"
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
                           FROM msafi.dpsp_tb_fin4816_reinf_prev_gtt rprev
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
                     FROM msafi.dpsp_tb_fin4816_reinf_prev_gtt rprev
                    WHERE 1 = 1
                      AND rprev."Codigo Empresa" = rpf.cod_empresa
                      AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                      AND rprev."Data Fiscal" = rpf.data_fiscal
                      AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                      AND rprev.num_item = rpf.num_item )
                     AS empresa
               , ( SELECT rprev."Codigo Estabelecimento"
                     FROM msafi.dpsp_tb_fin4816_reinf_prev_gtt rprev
                    WHERE 1 = 1
                      AND rprev."Codigo Empresa" = rpf.cod_empresa
                      AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                      AND rprev."Data Fiscal" = rpf.data_fiscal
                      AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                      AND rprev.num_item = rpf.num_item )
                     AS "Codigo Estabelecimento"
               , ( SELECT rprev."Codigo Pessoa Fisica/Juridica"
                     FROM msafi.dpsp_tb_fin4816_reinf_prev_gtt rprev
                    WHERE 1 = 1
                      AND rprev."Codigo Empresa" = rpf.cod_empresa
                      AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                      AND rprev."Data Fiscal" = rpf.data_fiscal
                      AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                      AND rprev.num_item = rpf.num_item )
                     AS cod_pessoa_fis_jur
               , ( SELECT rprev."Razão Social Cliente"
                     FROM msafi.dpsp_tb_fin4816_reinf_prev_gtt rprev
                    WHERE 1 = 1
                      AND rprev."Codigo Empresa" = rpf.cod_empresa
                      AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                      AND rprev."Data Fiscal" = rpf.data_fiscal
                      AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                      AND rprev.num_item = rpf.num_item )
                     AS "Razão Social Cliente"
               , ( SELECT rprev."CNPJ Cliente"
                     FROM msafi.dpsp_tb_fin4816_reinf_prev_gtt rprev
                    WHERE 1 = 1
                      AND rprev."Codigo Empresa" = rpf.cod_empresa
                      AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                      AND rprev."Data Fiscal" = rpf.data_fiscal
                      AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                      AND rprev.num_item = rpf.num_item )
                     AS "CNPJ Cliente"
               , ( SELECT rprev."Número da Nota Fiscal"
                     FROM msafi.dpsp_tb_fin4816_reinf_prev_gtt rprev
                    WHERE 1 = 1
                      AND rprev."Codigo Empresa" = rpf.cod_empresa
                      AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                      AND rprev."Data Fiscal" = rpf.data_fiscal
                      AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                      AND rprev.num_item = rpf.num_item )
                     AS "Nro. Nota Fiscal"
               , ( SELECT rprev."Emissão"
                     FROM msafi.dpsp_tb_fin4816_reinf_prev_gtt rprev
                    WHERE 1 = 1
                      AND rprev."Codigo Empresa" = rpf.cod_empresa
                      AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                      AND rprev."Data Fiscal" = rpf.data_fiscal
                      AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                      AND rprev.num_item = rpf.num_item )
                     AS "Dt. Emissao"
               , ( SELECT rprev."Data Fiscal"
                     FROM msafi.dpsp_tb_fin4816_reinf_prev_gtt rprev
                    WHERE 1 = 1
                      AND rprev."Codigo Empresa" = rpf.cod_empresa
                      AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                      AND rprev."Data Fiscal" = rpf.data_fiscal
                      AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                      AND rprev.num_item = rpf.num_item )
                     AS "Dt. Fiscal"
               , ( SELECT rprev.vlr_tot_nota
                     FROM msafi.dpsp_tb_fin4816_reinf_prev_gtt rprev
                    WHERE 1 = 1
                      AND rprev."Codigo Empresa" = rpf.cod_empresa
                      AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                      AND rprev."Data Fiscal" = rpf.data_fiscal
                      AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                      AND rprev.num_item = rpf.num_item )
                     AS "Vlr. Total da Nota"
               , ( SELECT rprev."Vlr Base Calc. Retenção"
                     FROM msafi.dpsp_tb_fin4816_reinf_prev_gtt rprev
                    WHERE 1 = 1
                      AND rprev."Codigo Empresa" = rpf.cod_empresa
                      AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                      AND rprev."Data Fiscal" = rpf.data_fiscal
                      AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                      AND rprev.num_item = rpf.num_item )
                     AS "Vlr Base Calc. Retenção"
               , ( SELECT rprev.vlr_aliq_inss
                     FROM msafi.dpsp_tb_fin4816_reinf_prev_gtt rprev
                    WHERE 1 = 1
                      AND rprev."Codigo Empresa" = rpf.cod_empresa
                      AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                      AND rprev."Data Fiscal" = rpf.data_fiscal
                      AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                      AND rprev.num_item = rpf.num_item )
                     AS "Vlr. Aliquota INSS"
               , ( SELECT rprev."Vlr.Trib INSS RETIDO"
                     FROM msafi.dpsp_tb_fin4816_reinf_prev_gtt rprev
                    WHERE 1 = 1
                      AND rprev."Codigo Empresa" = rpf.cod_empresa
                      AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                      AND rprev."Data Fiscal" = rpf.data_fiscal
                      AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                      AND rprev.num_item = rpf.num_item )
                     AS "Vlr.Trib INSS RETIDO"
               , ( SELECT rprev."Razão Social Drogaria"
                     FROM msafi.dpsp_tb_fin4816_reinf_prev_gtt rprev
                    WHERE 1 = 1
                      AND rprev."Codigo Empresa" = rpf.cod_empresa
                      AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                      AND rprev."Data Fiscal" = rpf.data_fiscal
                      AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                      AND rprev.num_item = rpf.num_item )
                     AS "Razão Social Drogaria"
               , ( SELECT rprev.cgc
                     FROM msafi.dpsp_tb_fin4816_reinf_prev_gtt rprev
                    WHERE 1 = 1
                      AND rprev."Codigo Empresa" = rpf.cod_empresa
                      AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                      AND rprev."Data Fiscal" = rpf.data_fiscal
                      AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                      AND rprev.num_item = rpf.num_item )
                     AS "CNPJ Drogarias"
               , ( SELECT rprev.cod_docto
                     FROM msafi.dpsp_tb_fin4816_reinf_prev_gtt rprev
                    WHERE 1 = 1
                      AND rprev."Codigo Empresa" = rpf.cod_empresa
                      AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                      AND rprev."Data Fiscal" = rpf.data_fiscal
                      AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                      AND rprev.num_item = rpf.num_item )
                     AS "Descr. Tp. Documento"
               , ( SELECT rprev."Tipo de Serviço E-social"
                     FROM msafi.dpsp_tb_fin4816_reinf_prev_gtt rprev
                    WHERE 1 = 1
                      AND rprev."Codigo Empresa" = rpf.cod_empresa
                      AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                      AND rprev."Data Fiscal" = rpf.data_fiscal
                      AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                      AND rprev.num_item = rpf.num_item )
                     AS "Tp.Serv. E-social"
               , ( SELECT rprev.dsc_tipo_serv_esocial
                     FROM msafi.dpsp_tb_fin4816_reinf_prev_gtt rprev
                    WHERE 1 = 1
                      AND rprev."Codigo Empresa" = rpf.cod_empresa
                      AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                      AND rprev."Data Fiscal" = rpf.data_fiscal
                      AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                      AND rprev.num_item = rpf.num_item )
                     AS "Descr. Tp. Serv E-social"
               , ( SELECT rprev."Valor do Servico"
                     FROM msafi.dpsp_tb_fin4816_reinf_prev_gtt rprev
                    WHERE 1 = 1
                      AND rprev."Codigo Empresa" = rpf.cod_empresa
                      AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                      AND rprev."Data Fiscal" = rpf.data_fiscal
                      AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                      AND rprev.num_item = rpf.num_item )
                     AS "Vlr. do Servico"
               , ( SELECT rprev.codigo_serv_prod
                     FROM msafi.dpsp_tb_fin4816_reinf_prev_gtt rprev
                    WHERE 1 = 1
                      AND rprev."Codigo Empresa" = rpf.cod_empresa
                      AND rprev."Codigo Estabelecimento" = rpf.cod_estab
                      AND rprev."Data Fiscal" = rpf.data_fiscal
                      AND rprev."Número da Nota Fiscal" = rpf.num_docfis
                      AND rprev.num_item = rpf.num_item )
                     AS "Cod. Serv. Mastersaf"
               , ( SELECT rprev.desc_serv_prod
                     FROM msafi.dpsp_tb_fin4816_reinf_prev_gtt rprev
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
                     FROM msafi.fin4816_reinf_2010_gtt r2010
                    WHERE 1 = 1
                      AND r2010.cod_empresa = rpf.cod_empresa
                      AND r2010.cod_estab = rpf.cod_estab
                      AND r2010.dat_emissao = rpf.data_emissao
                      AND r2010.data_fiscal = rpf.data_fiscal
                      AND r2010.num_docfis = rpf.num_docfis
                      AND r2010.rnk = 1 )
                     AS "Codigo Empresa"
               , ( SELECT INITCAP ( r2010."Razão Social Drogaria" )
                     FROM msafi.fin4816_reinf_2010_gtt r2010
                    WHERE 1 = 1
                      AND r2010.cod_empresa = rpf.cod_empresa
                      AND r2010.cod_estab = rpf.cod_estab
                      AND r2010.dat_emissao = rpf.data_emissao
                      AND r2010.data_fiscal = rpf.data_fiscal
                      AND r2010.num_docfis = rpf.num_docfis
                      AND r2010.rnk = 1 )
                     AS "Razão Social Drogaria."
               , ( SELECT INITCAP ( r2010."Razão Social Cliente" )
                     FROM msafi.fin4816_reinf_2010_gtt r2010
                    WHERE 1 = 1
                      AND r2010.cod_empresa = rpf.cod_empresa
                      AND r2010.cod_estab = rpf.cod_estab
                      AND r2010.dat_emissao = rpf.data_emissao
                      AND r2010.data_fiscal = rpf.data_fiscal
                      AND r2010.num_docfis = rpf.num_docfis
                      AND r2010.rnk = 1 )
                     AS "Razão Social Cliente."
               , ( SELECT ( r2010."Número da Nota Fiscal" )
                     FROM msafi.fin4816_reinf_2010_gtt r2010
                    WHERE 1 = 1
                      AND r2010.cod_empresa = rpf.cod_empresa
                      AND r2010.cod_estab = rpf.cod_estab
                      AND r2010.dat_emissao = rpf.data_emissao
                      AND r2010.data_fiscal = rpf.data_fiscal
                      AND r2010.num_docfis = rpf.num_docfis
                      AND r2010.rnk = 1 )
                     AS "Número da Nota Fiscal."
               , ( SELECT ( r2010."Data de Emissão da NF" )
                     FROM msafi.fin4816_reinf_2010_gtt r2010
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
                     FROM msafi.fin4816_reinf_2010_gtt r2010
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
                     FROM msafi.fin4816_reinf_2010_gtt r2010
                    WHERE 1 = 1
                      AND r2010.cod_empresa = rpf.cod_empresa
                      AND r2010.cod_estab = rpf.cod_estab
                      AND r2010.dat_emissao = rpf.data_emissao
                      AND r2010.data_fiscal = rpf.data_fiscal
                      AND r2010.num_docfis = rpf.num_docfis
                      AND r2010.rnk = 1 )
                     AS "Valor do Tributo."
               , ( SELECT INITCAP ( r2010."observacao" )
                     FROM msafi.fin4816_reinf_2010_gtt r2010
                    WHERE 1 = 1
                      AND r2010.cod_empresa = rpf.cod_empresa
                      AND r2010.cod_estab = rpf.cod_estab
                      AND r2010.dat_emissao = rpf.data_emissao
                      AND r2010.data_fiscal = rpf.data_fiscal
                      AND r2010.num_docfis = rpf.num_docfis
                      AND r2010.rnk = 1 )
                     AS "Observação."
               , ( SELECT INITCAP ( r2010."Tipo de Serviço E-social" )
                     FROM msafi.fin4816_reinf_2010_gtt r2010
                    WHERE 1 = 1
                      AND r2010.cod_empresa = rpf.cod_empresa
                      AND r2010.cod_estab = rpf.cod_estab
                      AND r2010.dat_emissao = rpf.data_emissao
                      AND r2010.data_fiscal = rpf.data_fiscal
                      AND r2010.num_docfis = rpf.num_docfis
                      AND r2010.rnk = 1 )
                     AS "Tipo de Serviço E-social."
               , ( SELECT ( r2010."Vlr. Base de Calc. Retenção" )
                     FROM msafi.fin4816_reinf_2010_gtt r2010
                    WHERE 1 = 1
                      AND r2010.cod_empresa = rpf.cod_empresa
                      AND r2010.cod_estab = rpf.cod_estab
                      AND r2010.dat_emissao = rpf.data_emissao
                      AND r2010.data_fiscal = rpf.data_fiscal
                      AND r2010.num_docfis = rpf.num_docfis
                      AND r2010.rnk = 1 )
                     AS "Vlr. Base de Calc. Retenção."
               , ( SELECT ( r2010."Valor da Retenção" )
                     FROM msafi.fin4816_reinf_2010_gtt r2010
                    WHERE 1 = 1
                      AND r2010.cod_empresa = rpf.cod_empresa
                      AND r2010.cod_estab = rpf.cod_estab
                      AND r2010.dat_emissao = rpf.data_emissao
                      AND r2010.data_fiscal = rpf.data_fiscal
                      AND r2010.num_docfis = rpf.num_docfis
                      AND r2010.rnk = 1 )
                     AS "Valor da Retenção."
            FROM msafi.fin4816_report_fiscal_gtt rpf
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
                INSERT INTO msafi.reinf_conf_previdenciaria_tmp ( cod_empresa
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


    PROCEDURE carga ( pnr_particao INTEGER
                    , pnr_particao2 INTEGER
                    , p_data_ini DATE
                    , p_data_fim DATE
                    , p_proc_id VARCHAR2
                    , p_nm_empresa VARCHAR2
                    , p_nm_usuario VARCHAR2 )
    IS
        v_data DATE;

        -- Constantes declaration
        cc_procedurename CONSTANT VARCHAR2 ( 30 ) := 'INSERT FIN4816_PREV';

        cc_limit NUMBER ( 7 ) := 10000;
        vn_count_new NUMBER := 0;

        l_status NUMBER;
        
        
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

        --  PREVISÃO DOS RETIDOS (AKK )
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
                 --
                 , msafi.fin4816_prev_tmp_estab estab
             --
             WHERE 1 = 1
               AND dwt_itens.cod_estab = estab.cod_estab
               AND estab.proc_id = p_proc_id
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
                 --
                 , msafi.fin4816_prev_tmp_estab estab
             --
             WHERE 1 = 1
               AND dwt_itens.cod_estab = estab.cod_estab
               AND estab.proc_id = p_proc_id
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
                 --
                 , msafi.fin4816_prev_tmp_estab estab
             --
             WHERE 1 = 1
               AND dwt_merc.cod_estab = estab.cod_estab
               AND estab.proc_id = p_proc_id
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
                INSERT INTO msafi.reinf_conf_previdenciaria_tmp ( cod_empresa
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
    
    
    
    BEGIN
        EXECUTE IMMEDIATE ( 'ALTER SESSION SET CURSOR_SHARING = FORCE' );

        EXECUTE IMMEDIATE ( 'ALTER SESSION SET TEMP_UNDO_ENABLED=FALSE ' );

        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT = ''DD/MM/YYYY''';

        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS= '',.'' ';

        --DELETE FROM msafi.fin2662_x08_gtt;   --  ajustar aqui  com o delete rowid
        --COMMIT;


        -- Registra o andamento do processo na v$session
        dbms_application_info.set_module ( cc_procedurename
                                         , 'n:' || vn_count_new );
        v_data := p_data_ini - 1 + pnr_particao;
        dbms_application_info.set_module ( cc_procedurename || '  ' || v_data
                                         , 'n:' || vn_count_new );



--        --================================================
--        -- Table - stage  INSS RETIDO
--        --================================================
--        prc_reinf_conf_retencao ( p_cod_empresa     => p_nm_empresa
--                                , p_cod_estab       => NULL
--                                , p_tipo_selec      => '1'
--                                , p_data_inicial    => TO_DATE ( v_data, 'DD/MM/YYYY' )
--                                , p_data_final      => TO_DATE ( v_data, 'DD/MM/YYYY' )
--                                , p_cod_usuario     => p_nm_usuario
--                                , p_entrada_saida   => 'E'
--                                , p_status          => l_status
--                                , p_proc_id         => p_proc_id );






        --================================================
        -- Table -  report fiscal
        --================================================
        OPEN cr_rtf ( v_data
                    , p_nm_empresa
                    , p_proc_id );

        LOOP
            --
            dbms_application_info.set_module ( cc_procedurename
                                             , 'Executando o fetch report fiscal ...' );

            --

            FETCH cr_rtf
                BULK COLLECT INTO -- TABLE  TMP
                                 g_cod_empresa
                   , g_cod_estab
                   , g_data_fiscal
                   , g_movto_e_s
                   , g_norm_dev
                   , g_ident_docto
                   , g_ident_fis_jur
                   , g_num_docfis
                   , g_serie_docfis
                   , g_sub_serie_docfis
                   , g_ident_servico
                   , g_num_item
                   , g_periodo_emissao
                   , g_cgc
                   , g_num_docto
                   , g_tipo_docto
                   , g_data_emissao
                   , g_cgc_fornecedor
                   , g_uf
                   , g_valor_total
                   , g_vlr_base_inss
                   , g_vlr_inss
                   , g_codigo_fisjur
                   , g_razao_social
                   , g_municipio_prestador
                   , g_cod_servico
                   , g_cod_cei
                   , g_equalizacao
                LIMIT cc_limit;



            -- inicia o cursor
            FORALL i IN g_cod_empresa.FIRST .. g_cod_empresa.LAST
                INSERT /*+ APPEND */
                      INTO  msafi.fin4816_report_fiscal_gtt ( cod_empresa
                                                            , cod_estab
                                                            , data_fiscal
                                                            , movto_e_s
                                                            , norm_dev
                                                            , ident_docto
                                                            , ident_fis_jur
                                                            , num_docfis
                                                            , serie_docfis
                                                            , sub_serie_docfis
                                                            , ident_servico
                                                            , num_item
                                                            , periodo_emissao
                                                            , cgc
                                                            , num_docto
                                                            , tipo_docto
                                                            , data_emissao
                                                            , cgc_fornecedor
                                                            , uf
                                                            , valor_total
                                                            , vlr_base_inss
                                                            , vlr_inss
                                                            , codigo_fisjur
                                                            , razao_social
                                                            , municipio_prestador
                                                            , cod_servico
                                                            , cod_cei
                                                            , equalizacao )
                     VALUES ( g_cod_empresa ( i )
                            , g_cod_estab ( i )
                            , g_data_fiscal ( i )
                            , g_movto_e_s ( i )
                            , g_norm_dev ( i )
                            , g_ident_docto ( i )
                            , g_ident_fis_jur ( i )
                            , g_num_docfis ( i )
                            , g_serie_docfis ( i )
                            , g_sub_serie_docfis ( i )
                            , g_ident_servico ( i )
                            , g_num_item ( i )
                            , g_periodo_emissao ( i )
                            , g_cgc ( i )
                            , g_num_docto ( i )
                            , g_tipo_docto ( i )
                            , g_data_emissao ( i )
                            , g_cgc_fornecedor ( i )
                            , g_uf ( i )
                            , g_valor_total ( i )
                            , g_vlr_base_inss ( i )
                            , g_vlr_inss ( i )
                            , g_codigo_fisjur ( i )
                            , g_razao_social ( i )
                            , g_municipio_prestador ( i )
                            , g_cod_servico ( i )
                            , g_cod_cei ( i )
                            , g_equalizacao ( i ) );

            --END;

            vn_count_new := vn_count_new + SQL%ROWCOUNT;
            COMMIT;

            -- Registra o andamento do processo na v$session
            dbms_application_info.set_module ( cc_procedurename || '  ' || v_data
                                             , 'n:' || vn_count_new );
            dbms_application_info.set_client_info ( TO_CHAR ( SYSDATE
                                                            , 'dd-mm-yyyy hh24:mi:ss' ) );



            g_cod_empresa.delete;
            g_cod_estab.delete;
            g_data_fiscal.delete;
            g_movto_e_s.delete;
            g_norm_dev.delete;
            g_ident_docto.delete;
            g_ident_fis_jur.delete;
            g_num_docfis.delete;
            g_serie_docfis.delete;
            g_sub_serie_docfis.delete;
            g_ident_servico.delete;
            g_num_item.delete;
            g_periodo_emissao.delete;
            g_cgc.delete;
            g_num_docto.delete;
            g_tipo_docto.delete;
            g_data_emissao.delete;
            g_cgc_fornecedor.delete;
            g_uf.delete;
            g_valor_total.delete;
            g_vlr_base_inss.delete;
            g_vlr_inss.delete;
            g_codigo_fisjur.delete;
            g_razao_social.delete;
            g_municipio_prestador.delete;
            g_cod_servico.delete;
            g_cod_cei.delete;
            g_equalizacao.delete;


            vn_count_new := vn_count_new + SQL%ROWCOUNT;
            COMMIT;

            -- Registra o andamento do processo na v$session
            dbms_application_info.set_module ( cc_procedurename || '  ' || v_data
                                             , 'n:' || vn_count_new );
            dbms_application_info.set_client_info ( TO_CHAR ( SYSDATE
                                                            , 'dd-mm-yyyy hh24:mi:ss' ) );

            EXIT WHEN cr_rtf%NOTFOUND;
        END LOOP;

        COMMIT;

        CLOSE cr_rtf;



        --================================================
        -- Table -  Report previdenciario
        --================================================
        vn_count_new := 0;

        BEGIN
            OPEN rc_prev ( v_data
                         , p_nm_empresa
                         , p_proc_id );

            --
            LOOP
                --
                dbms_application_info.set_module ( cc_procedurename
                                                 , 'Executando o fetch previdenciario ...' );

                FETCH rc_prev
                    BULK COLLECT INTO -- TABLE  TMP
                                     g_tipo_prv
                       , g_codigo_empresa_prv
                       , g_codigo_estab_prv
                       , g_data_emissao_prv
                       , g_data_fiscal_prv
                       , g_ident_fis_jur_prv
                       , g_ident_docto_prv
                       , g_numero_nota_fiscal_prv
                       , g_docto_serie_prv
                       , g_emissao_prv
                       , g_serie_docfis_prv
                       , g_sub_serie_docfis_prv
                       , g_num_item_prv
                       , g_cod_usuario_prv
                       , g_codigo_pess_fis_jur_prv
                       , g_razao_social_cliente_prv
                       , g_ind_fis_jur_prv
                       , g_cnpj_cliente_prv
                       , g_cod_class_doc_fis_prv
                       , g_vlr_tot_nota_prv
                       , g_vlr_bs_calc_retencao_prv
                       , g_vlr_aliq_inss_prv
                       , g_vlr_trib_inss_retido_prv
                       , g_vlr_retencao_prv
                       , g_vlr_contab_compl_prv
                       , g_ind_tipo_proc_prv
                       , g_num_proc_jur_prv
                       , g_razao_social_prv
                       , g_cgc_prv
                       , g_documento_prv
                       , g_tipo_serv_e_social_prv
                       , g_dsc_tipo_serv_esocial_prv
                       , g_razao_social_drogaria_prv
                       , g_valor_servico_prv
                       , g_num_proc_adj_adic_prv
                       , g_ind_tp_proc_adj_adic_prv
                       , g_codigo_serv_prod_prv
                       , g_desc_serv_prod_prv
                       , g_cod_docto_prv
                       , g_observação_prv
                       , g_dsc_param_prv
                    LIMIT cc_limit;

                --fin4816_reinf_prev_gtt

                FORALL i IN g_num_item_prv.FIRST .. g_num_item_prv.LAST
                    INSERT /*+ APPEND */
                          INTO  msafi.dpsp_tb_fin4816_reinf_prev_gtt ( tipo
                                                                     , "Codigo Empresa"
                                                                     , "Codigo Estabelecimento"
                                                                     , "Data Emissão"
                                                                     , "Data Fiscal"
                                                                     , ident_fis_jur
                                                                     , ident_docto
                                                                     , "Número da Nota Fiscal"
                                                                     , "Docto/Série"
                                                                     , "Emissão"
                                                                     , serie_docfis
                                                                     , sub_serie_docfis
                                                                     , num_item
                                                                     , cod_usuario
                                                                     , "Codigo Pessoa Fisica/Juridica"
                                                                     , "Razão Social Cliente"
                                                                     , ind_fis_jur
                                                                     , "CNPJ Cliente"
                                                                     , cod_class_doc_fis
                                                                     , vlr_tot_nota
                                                                     , "Vlr Base Calc. Retenção"
                                                                     , vlr_aliq_inss
                                                                     , "Vlr.Trib INSS RETIDO"
                                                                     , "Valor da Retenção"
                                                                     , vlr_contab_compl
                                                                     , ind_tipo_proc
                                                                     , num_proc_jur
                                                                     , razao_social
                                                                     , cgc
                                                                     , "Documento"
                                                                     , "Tipo de Serviço E-social"
                                                                     , dsc_tipo_serv_esocial
                                                                     , "Razão Social Drogaria"
                                                                     , "Valor do Servico"
                                                                     , num_proc_adj_adic
                                                                     , ind_tp_proc_adj_adic
                                                                     , codigo_serv_prod
                                                                     , desc_serv_prod
                                                                     , cod_docto
                                                                     , "Observação"
                                                                     , dsc_param )
                         VALUES ( g_tipo_prv ( i )
                                , g_codigo_empresa_prv ( i )
                                , g_codigo_estab_prv ( i )
                                , g_data_emissao_prv ( i )
                                , g_data_fiscal_prv ( i )
                                , g_ident_fis_jur_prv ( i )
                                , g_ident_docto_prv ( i )
                                , g_numero_nota_fiscal_prv ( i )
                                , g_docto_serie_prv ( i )
                                , g_emissao_prv ( i )
                                , g_serie_docfis_prv ( i )
                                , g_sub_serie_docfis_prv ( i )
                                , g_num_item_prv ( i )
                                , g_cod_usuario_prv ( i )
                                , g_codigo_pess_fis_jur_prv ( i )
                                , g_razao_social_cliente_prv ( i )
                                , g_ind_fis_jur_prv ( i )
                                , g_cnpj_cliente_prv ( i )
                                , g_cod_class_doc_fis_prv ( i )
                                , g_vlr_tot_nota_prv ( i )
                                , g_vlr_bs_calc_retencao_prv ( i )
                                , g_vlr_aliq_inss_prv ( i )
                                , g_vlr_trib_inss_retido_prv ( i )
                                , g_vlr_retencao_prv ( i )
                                , g_vlr_contab_compl_prv ( i )
                                , g_ind_tipo_proc_prv ( i )
                                , g_num_proc_jur_prv ( i )
                                , g_razao_social_prv ( i )
                                , g_cgc_prv ( i )
                                , g_documento_prv ( i )
                                , g_tipo_serv_e_social_prv ( i )
                                , g_dsc_tipo_serv_esocial_prv ( i )
                                , g_razao_social_drogaria_prv ( i )
                                , g_valor_servico_prv ( i )
                                , g_num_proc_adj_adic_prv ( i )
                                , g_ind_tp_proc_adj_adic_prv ( i )
                                , g_codigo_serv_prod_prv ( i )
                                , g_desc_serv_prod_prv ( i )
                                , g_cod_docto_prv ( i )
                                , g_observação_prv ( i )
                                , g_dsc_param_prv ( i ) );



                vn_count_new := vn_count_new + SQL%ROWCOUNT;
                COMMIT;
                -- Registra o andamento do processo na v$session
                dbms_application_info.set_module ( cc_procedurename || '  ' || v_data
                                                 , 'n:' || vn_count_new );
                dbms_application_info.set_client_info ( TO_CHAR ( SYSDATE
                                                                , 'dd-mm-yyyy hh24:mi:ss' ) );

                --
                g_tipo_prv.delete;
                g_codigo_empresa_prv.delete;
                g_codigo_estab_prv.delete;
                g_data_emissao_prv.delete;
                g_data_fiscal_prv.delete;
                g_ident_fis_jur_prv.delete;
                g_ident_docto_prv.delete;
                g_numero_nota_fiscal_prv.delete;
                g_docto_serie_prv.delete;
                g_emissao_prv.delete;
                g_serie_docfis_prv.delete;
                g_sub_serie_docfis_prv.delete;
                g_num_item_prv.delete;
                g_cod_usuario_prv.delete;
                g_codigo_pess_fis_jur_prv.delete;
                g_razao_social_cliente_prv.delete;
                g_ind_fis_jur_prv.delete;
                g_cnpj_cliente_prv.delete;
                g_cod_class_doc_fis_prv.delete;
                g_vlr_tot_nota_prv.delete;
                g_vlr_bs_calc_retencao_prv.delete;
                g_vlr_aliq_inss_prv.delete;
                g_vlr_trib_inss_retido_prv.delete;
                g_vlr_retencao_prv.delete;
                g_vlr_contab_compl_prv.delete;
                g_ind_tipo_proc_prv.delete;
                g_num_proc_jur_prv.delete;
                g_razao_social_prv.delete;
                g_cgc_prv.delete;
                g_documento_prv.delete;
                g_tipo_serv_e_social_prv.delete;
                g_dsc_tipo_serv_esocial_prv.delete;
                g_razao_social_drogaria_prv.delete;
                g_valor_servico_prv.delete;
                g_num_proc_adj_adic_prv.delete;
                g_ind_tp_proc_adj_adic_prv.delete;
                g_codigo_serv_prod_prv.delete;
                g_desc_serv_prod_prv.delete;
                g_cod_docto_prv.delete;
                g_observação_prv.delete;
                g_dsc_param_prv.delete;


                EXIT WHEN rc_prev%NOTFOUND;

                vn_count_new := vn_count_new + SQL%ROWCOUNT;
                COMMIT;

                -- Registra o andamento do processo na v$session
                dbms_application_info.set_module ( cc_procedurename || '  ' || v_data
                                                 , 'n:' || vn_count_new );
                dbms_application_info.set_client_info ( TO_CHAR ( SYSDATE
                                                                , 'dd-mm-yyyy hh24:mi:ss' ) );
            END LOOP;

            COMMIT;

            CLOSE rc_prev;
        END;



        --================================================
        -- Table -  Report Reinf 2010
        --================================================
        vn_count_new := 0;

        BEGIN
            OPEN rc_2010 ( v_data
                         , p_nm_empresa
                         , p_proc_id );

            LOOP
                dbms_application_info.set_module ( cc_procedurename
                                                 , 'Executando o fetch report 2010 ...' );

                FETCH rc_2010
                    BULK COLLECT INTO g_cod_empresa2
                       , g_cod_estab2
                       , g_dat_emissao2
                       , g_iden_fis_jur2
                       , g_num_docfis2
                       , g_cd_empresa
                       , g_rz_social_drogaria
                       , g_rz_social_client
                       , g_ntf
                       , g_data_emissao_nf
                       , g_data_fiscal2
                       , g_vlr_tributo
                       , g_observacao
                       , g_tp_servico_e_social
                       , g_vlr_bs_calc_retencao
                       , g_vlr_retencao
                       , g_proc_id
                       , g_ind_status
                       , g_cnpj_prestador
                       , g_ind_obra
                       , g_tp_inscricao
                       , g_nr_inscricao
                       , g_num_recibo
                       , g_ind_tp_amb
                       , g_vlr_bruto
                       , g_vlr_base_ret
                       , g_vlr_ret_princ
                       , g_vlr_ret_adic
                       , g_vlr_n_ret_princ
                       , g_vlr_n_ret_adic
                       , g_ind_cprb
                       , g_cod_versao_proc
                       , g_cod_versao_layout
                       , g_ind_proc_emissao
                       , g_id_evento
                       , g_ind_oper
                       , g_dat_ocorrencia
                       , g_cgc_cpf
                       , g_rz_social
                       , g_x04_razao_social
                       , g_id_r2010_oc
                       , g_nm_docto
                       , g_serie
                       , g_dat_emissao_nf
                       , g_dt_fiscal
                       , g_rnf_vlr_bruto
                       , g_obs
                       , g_id_r2010_nf
                       , g_ind_tp_proc_adj_adic
                       , g_num_proc_adj_adic
                       , g_cod_susp_adic
                       , g_radic_vlr_n_ret_adic
                       , g_ind_tp_proc_adj_princ
                       , g_num_proc_adj_princ
                       , g_cod_susp_princ
                       , g_rprinc_vlr_n_ret_princ
                       , g_tp_servico
                       , g_rserv_vlr_base_ret
                       , g_valor_retencao
                       , g_vlr_ret_sub
                       , g_rserv_vlr_n_ret_princ
                       , g_vlr_servicos_15
                       , g_vlr_servicos_20
                       , g_vlr_servicos_25
                       , g_rserv_vlr_ret_adic
                       , g_rserv_vlr_n_ret_adic
                       , g_rnk
                       , g_id_pger_apur
                    LIMIT cc_limit;



                FORALL i IN g_cod_empresa2.FIRST .. g_cod_empresa2.LAST
                    INSERT /*+ APPEND */
                          INTO  msafi.fin4816_reinf_2010_gtt ( cod_empresa
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
                                                             , id_pger_apur )
                         --
                         VALUES ( g_cod_empresa2 ( i )
                                , g_cod_estab2 ( i )
                                , g_dat_emissao2 ( i )
                                , g_iden_fis_jur2 ( i )
                                , g_num_docfis2 ( i )
                                , g_cd_empresa ( i )
                                , g_rz_social_drogaria ( i )
                                , g_rz_social_client ( i )
                                , g_ntf ( i )
                                , g_data_emissao_nf ( i )
                                , g_data_fiscal2 ( i )
                                , g_vlr_tributo ( i )
                                , g_observacao ( i )
                                , g_tp_servico_e_social ( i )
                                , g_vlr_bs_calc_retencao ( i )
                                , g_vlr_retencao ( i )
                                , g_proc_id ( i )
                                , g_ind_status ( i )
                                , g_cnpj_prestador ( i )
                                , g_ind_obra ( i )
                                , g_tp_inscricao ( i )
                                , g_nr_inscricao ( i )
                                , g_num_recibo ( i )
                                , g_ind_tp_amb ( i )
                                , g_vlr_bruto ( i )
                                , g_vlr_base_ret ( i )
                                , g_vlr_ret_princ ( i )
                                , g_vlr_ret_adic ( i )
                                , g_vlr_n_ret_princ ( i )
                                , g_vlr_n_ret_adic ( i )
                                , g_ind_cprb ( i )
                                , g_cod_versao_proc ( i )
                                , g_cod_versao_layout ( i )
                                , g_ind_proc_emissao ( i )
                                , g_id_evento ( i )
                                , g_ind_oper ( i )
                                , g_dat_ocorrencia ( i )
                                , g_cgc_cpf ( i )
                                , g_rz_social ( i )
                                , g_x04_razao_social ( i )
                                , g_id_r2010_oc ( i )
                                , g_nm_docto ( i )
                                , g_serie ( i )
                                , g_dat_emissao_nf ( i )
                                , g_dt_fiscal ( i )
                                , g_rnf_vlr_bruto ( i )
                                , g_obs ( i )
                                , g_id_r2010_nf ( i )
                                , g_ind_tp_proc_adj_adic ( i )
                                , g_num_proc_adj_adic ( i )
                                , g_cod_susp_adic ( i )
                                , g_radic_vlr_n_ret_adic ( i )
                                , g_ind_tp_proc_adj_princ ( i )
                                , g_num_proc_adj_princ ( i )
                                , g_cod_susp_princ ( i )
                                , g_rprinc_vlr_n_ret_princ ( i )
                                , g_tp_servico ( i )
                                , g_rserv_vlr_base_ret ( i )
                                , g_valor_retencao ( i )
                                , g_vlr_ret_sub ( i )
                                , g_rserv_vlr_n_ret_princ ( i )
                                , g_vlr_servicos_15 ( i )
                                , g_vlr_servicos_20 ( i )
                                , g_vlr_servicos_25 ( i )
                                , g_rserv_vlr_ret_adic ( i )
                                , g_rserv_vlr_n_ret_adic ( i )
                                , g_rnk ( i )
                                , g_id_pger_apur ( i ) );

                vn_count_new := vn_count_new + SQL%ROWCOUNT;
                COMMIT;

                -- Registra o andamento do processo na v$session
                dbms_application_info.set_module ( cc_procedurename || '  ' || v_data
                                                 , 'n:' || vn_count_new );
                dbms_application_info.set_client_info ( TO_CHAR ( SYSDATE
                                                                , 'dd-mm-yyyy hh24:mi:ss' ) );

                EXIT WHEN rc_2010%NOTFOUND;
            END LOOP;

            COMMIT;

            CLOSE rc_2010;
        END;



        dbms_application_info.set_module ( cc_procedurename || '  ' || v_data
                                         , 'Carga definitiva r2010' );
        dbms_application_info.set_module ( cc_procedurename
                                         , 'END:' || vn_count_new );
    END carga;



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
        --drop table msafi.fin4816_reinf_prev_gtt
        --===================================
        -- LIMPEZAS DAS TMP PROVISIORIAMENTE
        --===================================
        BEGIN
            --  falta substitui o nome das tabelas
            --  coloca as tabelas em em (tmp) e testa-las no periodo 01/01/2018 reinf  e 31/12/2018 INSS



            DELETE FROM msafi.fin4816_report_fiscal_gtt; -- 1. tb_fin4816_report_fiscal_01_gtt    ( através do item(1) faz se uma uma view inline no item 1,3,4

            DELETE FROM msafi.reinf_conf_previdenciaria_tmp; -- 2. tb_fin4816_stg_report_prev_02_gtt  ( resultado da procedure  prc_reinf_conf_retencao )

            DELETE FROM msafi.dpsp_tb_fin4816_reinf_prev_gtt; -- 3. tb_fin4816_stg_report_prev_03_gtt  ( executado uma query (union) junto com o resultado do item 2 )

            DELETE FROM msafi.fin4816_reinf_2010_gtt; -- 4. tb_fin4816_stg_report_reinf_04_gtt ( executa a query e salva nessa tabela)

            DELETE FROM msafi.fin4816_prev_tmp_estab; -- 5. tb_fin4816_stg_estab_05_gtt        ( salva todos os estabelecimentos  para executa os processos)



            COMMIT;
        END;



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

                
                DECLARE                
                L_STATUS  VARCHAR(1);
                
                 BEGIN
                
                        FOR V_COD_ESTAB IN PCOD_ESTAB.FIRST .. PCOD_ESTAB.LAST
                        LOOP 
                      
                         PRC_REINF_CONF_RETENCAO( 
                            P_COD_EMPRESA   => MCOD_EMPRESA
                           ,P_COD_ESTAB     => PCOD_ESTAB ( V_COD_ESTAB )    
                           ,P_TIPO_SELEC    => '1'
                           ,P_DATA_INICIAL  => TO_DATE ( PDATA_INICIAL, 'DD/MM/YYYY')
                           ,P_DATA_FINAL    => TO_DATE ( PDATA_FINAL, 'DD/MM/YYYY')
                           ,P_COD_USUARIO   => MNM_USUARIO
                           ,P_ENTRADA_SAIDA => 'E'
                           ,P_STATUS        => L_STATUS
                           ,P_PROC_ID       => NULL);
                            LOGA(L_STATUS);
        
                        END LOOP;
                 END;



                    loga ( '<< PERIODO DE: ' || pdata_inicial || ' A ' || pdata_final || ' >>', FALSE );



        --===================================
        --QUANTIDADE DE PROCESSOS EM PARALELO
        --===================================

        IF NVL ( p_lote, 0 ) < 1 THEN
            v_qt_grupos_paralelos := 20;
        ELSIF NVL ( p_lote, 0 ) > 100 THEN
            v_qt_grupos_paralelos := 100;
        ELSE
            v_qt_grupos_paralelos := p_lote;
        END IF;

        loga ( 'Quantidade em paralelo: ' || v_qt_grupos_paralelos
             , FALSE );
        loga ( ' '
             , FALSE );



        --====================================================================
        --LIMPEZA DA TEMP QUANDO EXISTIREM REGISTROS MAIS ANTIGOS QUE 5 DIAS
        --====================================================================
        --        DELETE FROM msafi.fin4816_prev_tmp_estab        -----
        --              WHERE TO_DATE ( SUBSTR ( dt_carga
        --                                     , 1
        --                                     , 10 )
        --                            , 'DD/MM/YYYY' ) < TO_DATE ( SYSDATE - 5
        --                                                       , 'DD/MM/YYYY' );
        --
        --        COMMIT;



        --============================================
        --LOOP de Estabelecimentos
        --============================================
        FOR v_estab IN pcod_estab.FIRST .. pcod_estab.LAST LOOP
            ---
            v_cont_estab := v_cont_estab + 1;

            INSERT INTO msafi.fin4816_prev_tmp_estab
                 VALUES ( mproc_id
                        , pcod_estab ( v_estab )
                        , v_cont_estab
                        , SYSDATE );

            COMMIT;
        --
        END LOOP;



        --===================================
        -- CHUNK
        --===================================
        msaf.dpsp_chunk_parallel.exec_parallel ( mproc_id
                                               , 'DPSP_FIN4816_PREV_CPROC.CARGA'
                                               , v_qt_grupos
                                               , v_qt_grupos_paralelos
                                               , p_task
                                               ,    'TO_DATE('''|| TO_CHAR ( pdata_inicial, 'DDMMYYYY' )|| ''',''DDMMYYYY''),'
                                                 || 'TO_DATE('''|| TO_CHAR ( pdata_final,   'DDMMYYYY' )|| ''',''DDMMYYYY''),'
                                                 || mproc_id
                                                 || ','''
                                                 || mcod_empresa
                                                 || ''','
                                                 || ''''
                                                 || mnm_usuario
                                                 || '''' );

            dbms_parallel_execute.drop_task ( p_task );
        
        
        

        load_excel ( vp_mproc_id => mproc_id
                   , v_data_inicial => pdata_inicial
                   , v_data_final => pdata_final );

        loga ( '---FIM DO PROCESSAMENTO---'
             , FALSE );

        lib_proc.close;
        RETURN mproc_id;
    END;
END dpsp_fin4816_prev_cproc;
/