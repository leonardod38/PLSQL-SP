Prompt Package Body DPSP_FIN4816_PREV_CPROC;
--
-- DPSP_FIN4816_PREV_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_fin4816_prev_cproc
IS
    mproc_id NUMBER;
    mnm_usuario usuario_estab.cod_usuario%TYPE;
    mcod_empresa estabelecimento.cod_empresa%TYPE;

    --Tipo, Nome e Descri��o do Customizado
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
               , x07_docto_fiscal.data_emissao AS perido_emissao -- Periodo de Emiss�o
               , estabelecimento.cgc AS cgc -- CNPJ Drogaria
               , x07_docto_fiscal.num_docfis AS num_docto -- Numero da Nota Fiscal
               , x2005_tipo_docto.cod_docto AS tipo_docto -- Tipo de Documento
               , x07_docto_fiscal.data_emissao AS data_emissao -- Data Emiss�o
               , x04_pessoa_fis_jur.cpf_cgc AS cgc_fornecedor -- CNPJ_Fonecedor
               , estado.cod_estado AS uf -- uf
               , x09_itens_serv.vlr_tot AS valor_total -- Valor Total da Nota
               , x09_itens_serv.vlr_base_inss AS base_inss -- Base de Calculo INSS
               , x09_itens_serv.vlr_inss_retido AS valor_inss -- Valor do INSS
               , x04_pessoa_fis_jur.cod_fis_jur AS cod_fis_jur -- Codigo Pessoa Fisica/juridica
               , x04_pessoa_fis_jur.razao_social AS razao_social -- Raz�o Social
               , municipio.descricao AS municipio_prestador -- Municipio Prestador
               , x2018_servicos.cod_servico AS cod_servico -- Codigo de Servi�o
               , x07_docto_fiscal.cod_cei AS cod_cei -- Codigo CEI
               , NULL AS equalizacao -- Equaliza��o
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
             AND ( x07_docto_fiscal.cod_estab IS NOT NULL ) -- COD_ESTAB
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

    TYPE typ_data_emissao_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Data Emiss�o"%TYPE;

    TYPE typ_data_fiscal_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Data Fiscal"%TYPE;

    TYPE typ_ident_fis_jur_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.ident_fis_jur%TYPE;

    TYPE typ_ident_docto_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.ident_docto%TYPE;

    TYPE typ_numero_nota_fiscal_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."N�mero da Nota Fiscal"%TYPE;

    TYPE typ_docto_serie_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Docto/S�rie"%TYPE;

    TYPE typ_emissao_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Emiss�o"%TYPE;

    TYPE typ_serie_docfis_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.serie_docfis%TYPE;

    TYPE typ_sub_serie_docfis_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.sub_serie_docfis%TYPE;

    TYPE typ_num_item_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.num_item%TYPE;

    TYPE typ_cod_usuario_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.cod_usuario%TYPE;

    TYPE typ_codigo_pess_fis_jur_prv
        IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Codigo Pessoa Fisica/Juridica"%TYPE;

    TYPE typ_razao_social_cliente_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Raz�o Social Cliente"%TYPE;

    TYPE typ_ind_fis_jur_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.ind_fis_jur%TYPE;

    TYPE typ_cnpj_cliente_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."CNPJ Cliente"%TYPE;

    TYPE typ_cod_class_doc_fis_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.cod_class_doc_fis%TYPE;

    TYPE typ_vlr_tot_nota_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.vlr_tot_nota%TYPE;

    TYPE typ_vlr_bs_calc_retencao_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Vlr Base Calc. Reten��o"%TYPE;

    TYPE typ_vlr_aliq_inss_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.vlr_aliq_inss%TYPE;

    TYPE typ_vlr_trib_inss_retido_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Vlr.Trib INSS RETIDO"%TYPE;

    TYPE typ_vlr_retencao_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Valor da Reten��o"%TYPE;

    TYPE typ_vlr_contab_compl_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.vlr_contab_compl%TYPE;

    TYPE typ_ind_tipo_proc_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.ind_tipo_proc%TYPE;

    TYPE typ_num_proc_jur_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.num_proc_jur%TYPE;

    TYPE typ_razao_social_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.razao_social%TYPE;

    TYPE typ_cgc_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.cgc%TYPE;

    TYPE typ_documento_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Documento"%TYPE;

    TYPE typ_tipo_serv_e_social_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Tipo de Servi�o E-social"%TYPE;

    TYPE typ_dsc_tipo_serv_esocial_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.dsc_tipo_serv_esocial%TYPE;

    TYPE typ_razao_social_drogaria_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Raz�o Social Drogaria"%TYPE;

    TYPE typ_valor_servico_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Valor do Servico"%TYPE;

    TYPE typ_num_proc_adj_adic_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.num_proc_adj_adic%TYPE;

    TYPE typ_ind_tp_proc_adj_adic_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.ind_tp_proc_adj_adic%TYPE;

    TYPE typ_codigo_serv_prod_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.codigo_serv_prod%TYPE;

    TYPE typ_desc_serv_prod_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.desc_serv_prod%TYPE;

    TYPE typ_cod_docto_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.cod_docto%TYPE;

    TYPE typ_observa��o_prv IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Observa��o"%TYPE;

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
    g_observa��o_prv typ_observa��o_prv;
    g_dsc_param_prv typ_dsc_param_prv;



    CURSOR rc_prev ( pdate DATE
                   , pcod_empresa VARCHAR2
                   , p_proc_id NUMBER )
    IS
        SELECT 'S' AS tipo
             , reinf.cod_empresa AS "Codigo Empresa"
             , reinf.cod_estab AS "Codigo Estabelecimento"
             , reinf.data_emissao AS "Data Emiss�o"
             , reinf.data_fiscal AS "Data Fiscal"
             , reinf.ident_fis_jur
             , reinf.ident_docto
             , reinf.num_docfis AS "N�mero da Nota Fiscal"
             --
             , reinf.num_docfis || '/' || reinf.serie_docfis AS "Docto/S�rie"
             , reinf.data_emissao AS "Emiss�o"
             --
             , reinf.serie_docfis
             , reinf.sub_serie_docfis
             , reinf.num_item
             , reinf.cod_usuario
             , x04.cod_fis_jur AS "Codigo Pessoa Fisica/Juridica"
             , INITCAP ( x04.razao_social ) AS "Raz�o Social Cliente"
             , x04.ind_fis_jur
             , x04.cpf_cgc AS "CNPJ Cliente"
             , reinf.cod_class_doc_fis
             , reinf.vlr_tot_nota
             , reinf.vlr_base_inss AS "Vlr Base Calc. Reten��o"
             , reinf.vlr_aliq_inss
             , reinf.vlr_inss_retido AS "Vlr.Trib INSS RETIDO"
             , reinf.vlr_inss_retido AS "Valor da Reten��o"
             , reinf.vlr_contab_compl
             , reinf.ind_tipo_proc
             , reinf.num_proc_jur
             , estab.razao_social
             , estab.cgc
             , x2005.descricao AS "Documento"
             , prt_tipo.cod_tipo_serv_esocial AS "Tipo de Servi�o E-social"
             , prt_tipo.dsc_tipo_serv_esocial
             , INITCAP ( empresa.razao_social ) AS "Raz�o Social Drogaria"
             , reinf.vlr_servico AS "Valor do Servico"
             , reinf.num_proc_adj_adic
             , reinf.ind_tp_proc_adj_adic
             , x2018.cod_servico AS codigo_serv_prod
             , INITCAP ( x2018.descricao ) AS desc_serv_prod
             , x2005.cod_docto
             , NULL AS "Observa��o"
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
             , reinf.data_emissao AS "Data Emiss�o"
             , reinf.data_fiscal AS "Data Fiscal"
             , reinf.ident_fis_jur
             , reinf.ident_docto
             , reinf.num_docfis AS "N�mero da Nota Fiscal"
             --
             , reinf.num_docfis || '/' || reinf.serie_docfis AS "Docto/S�rie"
             , reinf.data_emissao AS "Emiss�o"
             --
             , reinf.serie_docfis
             , reinf.sub_serie_docfis
             , reinf.num_item
             , reinf.cod_usuario
             , x04.cod_fis_jur AS "Codigo Pessoa Fisica/Juridica"
             , INITCAP ( x04.razao_social ) AS "Raz�o Social Cliente"
             , x04.ind_fis_jur
             , x04.cpf_cgc AS "CNPJ Cliente"
             , reinf.cod_class_doc_fis
             , reinf.vlr_tot_nota
             , reinf.vlr_base_inss AS "Vlr Base Calc. Reten��o"
             , reinf.vlr_aliq_inss
             , reinf.vlr_inss_retido AS "Vlr.Trib INSS RETIDO"
             , reinf.vlr_inss_retido AS "Valor da Reten��o"
             , reinf.vlr_contab_compl
             , reinf.ind_tipo_proc
             , reinf.num_proc_jur
             , estab.razao_social
             , estab.cgc
             , x2005.descricao AS "Documento"
             , NULL
             , NULL
             , INITCAP ( empresa.razao_social ) AS "Raz�o Social Drogaria"
             , reinf.vlr_servico AS "Valor do Servico"
             , reinf.num_proc_adj_adic
             , reinf.ind_tp_proc_adj_adic
             , x2018.cod_servico AS codigo_serv_prod
             , INITCAP ( x2018.descricao ) AS desc_serv_prod
             , x2005.cod_docto
             , NULL AS "Observa��o"
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

    TYPE typ_rz_social_drogaria IS TABLE OF msafi.fin4816_reinf_2010_gtt."Raz�o Social Drogaria"%TYPE;

    TYPE typ_rz_social_client IS TABLE OF msafi.fin4816_reinf_2010_gtt."Raz�o Social Cliente"%TYPE;

    TYPE typ_ntf IS TABLE OF msafi.fin4816_reinf_2010_gtt."N�mero da Nota Fiscal"%TYPE;

    TYPE typ_data_emissao_nf IS TABLE OF msafi.fin4816_reinf_2010_gtt."Data de Emiss�o da NF"%TYPE;

    TYPE typ_data_fiscal2 IS TABLE OF msafi.fin4816_reinf_2010_gtt."Data Fiscal"%TYPE;

    TYPE typ_vlr_tributo IS TABLE OF msafi.fin4816_reinf_2010_gtt."Valor do Tributo"%TYPE;

    TYPE typ_observacao IS TABLE OF msafi.fin4816_reinf_2010_gtt."observacao"%TYPE;

    TYPE typ_tp_servico_e_social IS TABLE OF msafi.fin4816_reinf_2010_gtt."Tipo de Servi�o E-social"%TYPE;

    TYPE typ_vlr_bs_calc_retencao IS TABLE OF msafi.fin4816_reinf_2010_gtt."Vlr. Base de Calc. Reten��o"%TYPE;

    TYPE typ_vlr_retencao IS TABLE OF msafi.fin4816_reinf_2010_gtt."Valor da Reten��o"%TYPE;

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



    CURSOR rc_excel_analitico
    IS
        SELECT rpf.cod_empresa AS "Codigo da Empresa"
             , rpf.cod_estab AS "Codigo do Estabelecimento"
             , TO_CHAR ( rpf.data_emissao
                       , 'MM/YYYY' )
                   AS "Periodo de Emiss�o"
             , rpf.cgc AS "CNPJ Drogaria "
             , rpf.num_docfis AS "Numero da Nota Fiscal"
             , rpf.tipo_docto AS "Tipo de Documento"
             , rpf.data_emissao AS "Data Emiss�o"
             , rpf.cgc_fornecedor AS "CNPJ Fonecedor"
             , rpf.uf AS "UF"
             , rpf.valor_total AS "Valor Total da Nota"
             , rpf.vlr_base_inss AS "Base de Calculo INSS"
             , rpf.vlr_inss AS "Valor do INSS"
             , rpf.codigo_fisjur AS "Codigo Pessoa Fisica/juridica"
             , INITCAP ( rpf.razao_social ) AS "Raz�o Social"
             , INITCAP ( rpf.municipio_prestador ) AS "Municipio Prestador"
             , rpf.cod_servico AS "Codigo de Servi�o"
             , rpf.cod_cei AS "Codigo CEI"
             , NULL AS "Existe na DWT"
          FROM msafi.fin4816_report_fiscal_gtt rpf;



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
                       , g_observa��o_prv
                       , g_dsc_param_prv
                    LIMIT cc_limit;

                --fin4816_reinf_prev_gtt

                FORALL i IN g_num_item_prv.FIRST .. g_num_item_prv.LAST
                    INSERT /*+ APPEND */
                          INTO  msafi.dpsp_tb_fin4816_reinf_prev_gtt ( tipo
                                                                     , "Codigo Empresa"
                                                                     , "Codigo Estabelecimento"
                                                                     , "Data Emiss�o"
                                                                     , "Data Fiscal"
                                                                     , ident_fis_jur
                                                                     , ident_docto
                                                                     , "N�mero da Nota Fiscal"
                                                                     , "Docto/S�rie"
                                                                     , "Emiss�o"
                                                                     , serie_docfis
                                                                     , sub_serie_docfis
                                                                     , num_item
                                                                     , cod_usuario
                                                                     , "Codigo Pessoa Fisica/Juridica"
                                                                     , "Raz�o Social Cliente"
                                                                     , ind_fis_jur
                                                                     , "CNPJ Cliente"
                                                                     , cod_class_doc_fis
                                                                     , vlr_tot_nota
                                                                     , "Vlr Base Calc. Reten��o"
                                                                     , vlr_aliq_inss
                                                                     , "Vlr.Trib INSS RETIDO"
                                                                     , "Valor da Reten��o"
                                                                     , vlr_contab_compl
                                                                     , ind_tipo_proc
                                                                     , num_proc_jur
                                                                     , razao_social
                                                                     , cgc
                                                                     , "Documento"
                                                                     , "Tipo de Servi�o E-social"
                                                                     , dsc_tipo_serv_esocial
                                                                     , "Raz�o Social Drogaria"
                                                                     , "Valor do Servico"
                                                                     , num_proc_adj_adic
                                                                     , ind_tp_proc_adj_adic
                                                                     , codigo_serv_prod
                                                                     , desc_serv_prod
                                                                     , cod_docto
                                                                     , "Observa��o"
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
                                , g_observa��o_prv ( i )
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
                g_observa��o_prv.delete;
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



    --
    --  PROCEDURE load_excel_analitico (p_proc_instance IN VARCHAR2) IS
    --
    --    v_sql    VARCHAR2(20000);
    --    v_text01 VARCHAR2(20000);
    --    v_class  VARCHAR2(1) := 'a';
    --    c_conc   SYS_REFCURSOR;
    --    p_lojas  VARCHAR2(6);
    --
    --
    --
    --
    --  BEGIN
    --        EXECUTE IMMEDIATE   'ALTER SESSION SET NLS_DATE_FORMAT = ''DD/MM/YYYY''';
    --        EXECUTE IMMEDIATE   'ALTER SESSION SET NLS_NUMERIC_CHARACTERS= '',.'' ';
    --
    --
    --
    --
    --
    --
    --
    --
    --
    --
    --
    --
    --
    --
    --
    --
    --
    --
    --            i := 11;
    --            loga('>>> Relatorio Previdenciario ' || p_proc_instance, FALSE);
    --            lib_proc.add_tipo(p_proc_instance,i,mcod_empresa || '_analitico_reinf_' ||to_char(sysdate,'MMYYYY') || '.XLS',2);
    --
    --            COMMIT;
    --
    --            lib_proc.add(dsp_planilha.header, ptipo => i);
    --            lib_proc.add(dsp_planilha.tabela_inicio, ptipo => i);
    --       -- lib_proc.add(dsp_planilha.linha(p_conteudo => dsp_planilha.campo('Report_Fiscal',p_custom => 'COLSPAN=31'),p_class => 'h'),ptipo => i);
    --
    --
    --
    --
    ----        lib_proc.add(dsp_planilha.linha(p_conteudo =>
    ----                     dsp_planilha.campo('COD_EMPRESA')       || --
    ----                     dsp_planilha.campo('COD_ESTAB')         || --
    ----                     dsp_planilha.campo('PERIODO_EMISSAO')   || --
    ----                     dsp_planilha.campo('CGC')               || --
    ----                     dsp_planilha.campo('NUM_DOCTO')         || --
    ----                     dsp_planilha.campo('TIPO_DOCTO')        || --
    ----                     dsp_planilha.campo('DATA_EMISSAO')      || --
    ----                     dsp_planilha.campo('DATA_FISCAL')       || --
    ----                     dsp_planilha.campo('CGC_FORNECEDOR')    || --
    ----                     dsp_planilha.campo('UF')                || --
    ----                     dsp_planilha.campo('VALOR_TOTAL')       || --
    ----                     dsp_planilha.campo('VLR_BASE_INSS')     || --
    ----                     dsp_planilha.campo('VLR_INSS')          || --
    ----                     dsp_planilha.campo('CODIGO_FISJUR')     || --
    ----                     dsp_planilha.campo('RAZAO_SOCIAL')      || --
    ----                     dsp_planilha.campo('MUNICIPIO_PRESTADOR')|| --
    ----                     dsp_planilha.campo('COD_SERVICO')          --
    ----                                            , p_class => 'h'), ptipo => i);
    --
    --
    --
    --
    --
    --
    --        --FOR ii IN rcx  LOOP
    --
    --          IF v_class = 'a'
    --          THEN
    --            v_class := 'b';
    --          ELSE
    --            v_class := 'a';
    --          END IF;
    --
    --            IF  ii.col31 = 'R'  AND ii.col32   = 'A' THEN
    --            lib_proc.add(dsp_planilha.linha(p_conteudo => dsp_planilha.campo('Report_Fiscal',p_custom => 'COLSPAN=31'),p_class => 'h'),ptipo => i);
    --
    --
    --            lib_proc.add(dsp_planilha.linha(p_conteudo =>
    --                     dsp_planilha.campo('COD_EMPRESA')       || --
    --                     dsp_planilha.campo('COD_ESTAB')         || --
    --                     dsp_planilha.campo('PERIODO_EMISSAO')   || --
    --                     dsp_planilha.campo('CGC_ESTAB')         || --
    --                     dsp_planilha.campo('NUM_DOCTO')         || --
    --                     dsp_planilha.campo('TIPO_DOCTO')        || --
    --                     dsp_planilha.campo('DATA_EMISSAO')      || --
    --                     dsp_planilha.campo('DATA_FISCAL')       || --
    --                     dsp_planilha.campo('CGC_FORNECEDOR')    || --
    --                     dsp_planilha.campo('UF')                || --
    --                     dsp_planilha.campo('VALOR_TOTAL')       || --
    --                     dsp_planilha.campo('VLR_BASE_INSS')     || --
    --                     dsp_planilha.campo('VLR_INSS')          || --
    --                     dsp_planilha.campo('CODIGO_FISJUR')     || --
    --                     dsp_planilha.campo('RAZAO_SOCIAL')      || --
    --                     dsp_planilha.campo('MUNICIPIO_PRESTADOR')|| --
    --                     dsp_planilha.campo('COD_SERVICO')          --
    --                                            , p_class => 'h'), ptipo => i);
    --
    --
    --
    --
    --
    --
    --
    --             ELSIF  ii.col31   = 'R'   AND  ii.col32   = 'B'  THEN
    --             lib_proc.add(dsp_planilha.linha(p_conteudo => dsp_planilha.campo('Report_Previdenciario',p_custom => 'COLSPAN=31'),p_class => 'h'),ptipo => i);
    --             END IF;
    --
    --
    --          v_text01 := dsp_planilha.linha(p_conteudo =>
    --                      dsp_planilha.campo(ii.col1)           ||                  -- cod_empresa
    --                      dsp_planilha.campo(ii.col2)           ||                  -- cod_estab
    --                      dsp_planilha.campo(ii.col3)           ||                  -- periodo_emiss
    --                      dsp_planilha.campo(dsp_planilha.texto(TO_CHAR(ii.col4))) ||-- cgc
    --                      dsp_planilha.campo(ii.col5)           ||                  --  num_docto
    --                      dsp_planilha.campo(ii.col6)           ||                  --  tipo_docto
    --                      dsp_planilha.campo(ii.col7)           ||                  --  data_emissao
    --                      dsp_planilha.campo(ii.col8)           ||                  --  data_fiscal
    --                      dsp_planilha.campo(dsp_planilha.texto(TO_CHAR(ii.col9))) ||-- cgc_fornecedo
    --                      dsp_planilha.campo(ii.col10)          ||                   -- uf
    --                      dsp_planilha.campo(ii.col11)          ||                   -- valor_total
    --                      dsp_planilha.campo(ii.col12)          ||                   -- vlr_base_inss
    --                      dsp_planilha.campo(ii.col13)          ||                   -- vlr_inss
    --                      dsp_planilha.campo(ii.col14)          ||                   -- codigo_fisjur
    --                      dsp_planilha.campo(ii.col15)          ||                   -- razao_social
    --                      dsp_planilha.campo(ii.col16)          ||                   -- municipio_pre
    --                      dsp_planilha.campo(ii.col17)                               -- cod_servico
    --                                           ,p_class => v_class);
    --
    --           msaf.lib_proc.add(v_text01, ptipo => i);
    --
    --      END LOOP;
    --
    --    lib_proc.add(dsp_planilha.tabela_fim, ptipo => i);
    --
    --  END load_excel_analitico;



    PROCEDURE gera_relatorio_009 ( p_data_ini IN DATE
                                 , p_data_fim IN DATE
                                 , v_exec_all IN OUT CHAR )
    IS
        -- AJ0004
        v_quebra_arq NUMBER ( 7 ) := 1000000;
        v_contr_plan NUMBER ( 7 );
        v_cont_arq INT;
        v_text01 VARCHAR2 ( 1000 );
        v_class CHAR ( 1 ) := 'a';
        v_sql VARCHAR2 ( 4000 );
    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS='',.''';

        v_contr_plan := 0;
        v_cont_arq := 0;



        IF v_contr_plan < 1 THEN
            v_contr_plan := v_quebra_arq;
            v_cont_arq := v_cont_arq + 1;



            -- CRIA PROCESSO
            lib_proc.add_tipo ( mproc_id
                              , v_cont_arq + 1
                              ,    'FECHAMENTO_'
                                || TO_CHAR ( p_data_ini
                                           , 'YYYYMMDD' )
                                || '_'
                                || TO_CHAR ( p_data_fim
                                           , 'YYYYMMDD' )
                                || '_'
                                || LPAD ( v_cont_arq
                                        , 2
                                        , '0' )
                                || '.XLS'
                              , 2 );



            -- ADICIONA CABECALHO
            lib_proc.add ( dsp_planilha.header ( )
                         , ptipo => v_cont_arq + 1 );

            lib_proc.add ( dsp_planilha.tabela_inicio ( )
                         , ptipo => v_cont_arq + 1 );

            v_text01 := dsp_planilha.campo ( p_conteudo => 'COD_ESTAB' );
            v_text01 := v_text01 || dsp_planilha.campo ( p_conteudo => 'UF_ESTAB' );
            v_text01 := v_text01 || dsp_planilha.campo ( p_conteudo => 'UF_FORN_CLI' );
            v_text01 := v_text01 || dsp_planilha.campo ( p_conteudo => 'DATA_FISCAL' );
            v_text01 := v_text01 || dsp_planilha.campo ( p_conteudo => 'NUMERO_NF' );
            v_text01 := v_text01 || dsp_planilha.campo ( p_conteudo => 'SERIE' );
            v_text01 := v_text01 || dsp_planilha.campo ( p_conteudo => 'ID_PEOPLE' );
            v_text01 := v_text01 || dsp_planilha.campo ( p_conteudo => 'COD_DOCTO' );
            v_text01 := v_text01 || dsp_planilha.campo ( p_conteudo => 'MODELO_DOC' );
            v_text01 := v_text01 || dsp_planilha.campo ( p_conteudo => 'FIN' );
            v_text01 := v_text01 || dsp_planilha.campo ( p_conteudo => 'CFOP' );
            v_text01 := v_text01 || dsp_planilha.campo ( p_conteudo => 'CST' );
            v_text01 := v_text01 || dsp_planilha.campo ( p_conteudo => 'VLR_CONTABIL' );
            v_text01 := v_text01 || dsp_planilha.campo ( p_conteudo => 'BASE_TRIB' );
            v_text01 := v_text01 || dsp_planilha.campo ( p_conteudo => 'ALIQ_ICMS' );
            v_text01 := v_text01 || dsp_planilha.campo ( p_conteudo => 'VLR_ICMS' );
            v_text01 := v_text01 || dsp_planilha.campo ( p_conteudo => 'BASE_ISENT' );
            v_text01 := v_text01 || dsp_planilha.campo ( p_conteudo => 'BASE_OUTRAS' );
            v_text01 := v_text01 || dsp_planilha.campo ( p_conteudo => 'BASE_RED' );
            v_text01 := v_text01 || dsp_planilha.campo ( p_conteudo => 'VLR_ICMS_ST' );
            v_text01 := v_text01 || dsp_planilha.campo ( p_conteudo => 'VLR_IPI' );
            v_text01 := v_text01 || dsp_planilha.campo ( p_conteudo => 'DIF_BASES' );

            lib_proc.add ( dsp_planilha.linha ( p_conteudo => v_text01
                                              , p_class => 'h' )
                         , ptipo => v_cont_arq + 1 );
        END IF;

        IF v_class = 'a' THEN
            v_class := 'b';
        ELSE
            v_class := 'a';
        END IF;

        --        -- ADICIONA LINHA
        --        v_Text01 := Dsp_Planilha.Campo(p_Conteudo => V_COD_ESTAB);
        --        v_Text01 := v_Text01 || --
        --                    Dsp_Planilha.Campo(p_Conteudo => V_UF_ESTAB);
        --        v_Text01 := v_Text01 || --
        --                    Dsp_Planilha.Campo(p_Conteudo => V_UF_FORN_CLI);
        --        v_Text01 := v_Text01 || --
        --                    Dsp_Planilha.Campo(p_Conteudo => V_DATA_FISCAL);
        --        v_Text01 := v_Text01 || --
        --                    Dsp_Planilha.Campo(p_Conteudo => Dsp_Planilha.Texto(V_NUMERO_NF));
        --        v_Text01 := v_Text01 || --
        --                    Dsp_Planilha.Campo(p_Conteudo => Dsp_Planilha.Texto(V_SERIE));
        --        v_Text01 := v_Text01 || --
        --                    Dsp_Planilha.Campo(p_Conteudo => Dsp_Planilha.Texto(V_ID_PEOPLE));
        --        v_Text01 := v_Text01 || --
        --                    Dsp_Planilha.Campo(p_Conteudo => V_COD_DOCTO);
        --        v_Text01 := v_Text01 || --
        --                    Dsp_Planilha.Campo(p_Conteudo => Dsp_Planilha.Texto(V_MODELO_DOC));
        --        v_Text01 := v_Text01 || --
        --                    Dsp_Planilha.Campo(p_Conteudo => V_FIN);
        --        v_Text01 := v_Text01 || --
        --                    Dsp_Planilha.Campo(p_Conteudo => V_CFOP);
        --        v_Text01 := v_Text01 || --
        --                    Dsp_Planilha.Campo(p_Conteudo => Dsp_Planilha.Texto(V_CST));
        --        v_Text01 := v_Text01 || --
        --                    Dsp_Planilha.Campo(p_Conteudo => To_Char(V_VLR_CONTABIL,
        --                                                             'FM999G999G990D00'));
        --        v_Text01 := v_Text01 || --
        --                    Dsp_Planilha.Campo(p_Conteudo => To_Char(V_BASE_TRIB,
        --                                                             'FM999G999G990D00'));
        --        v_Text01 := v_Text01 || --
        --                    Dsp_Planilha.Campo(p_Conteudo => To_Char(V_ALIQ_ICMS,
        --                                                             'FM990D00'));
        --        v_Text01 := v_Text01 || --
        --                    Dsp_Planilha.Campo(p_Conteudo => To_Char(V_VLR_ICMS,
        --                                                             'FM999G999G990D00'));
        --        v_Text01 := v_Text01 || --
        --                    Dsp_Planilha.Campo(p_Conteudo => To_Char(V_BASE_ISENT,
        --                                                             'FM999G999G990D00'));
        --        v_Text01 := v_Text01 || --
        --                    Dsp_Planilha.Campo(p_Conteudo => To_Char(V_BASE_OUTRAS,
        --                                                             'FM999G999G990D00'));
        --        v_Text01 := v_Text01 || --
        --                    Dsp_Planilha.Campo(p_Conteudo => To_Char(V_BASE_RED,
        --                                                             'FM999G999G990D00'));
        --        v_Text01 := v_Text01 || --
        --                    Dsp_Planilha.Campo(p_Conteudo => To_Char(V_VLR_ICMS_ST,
        --                                                             'FM999G999G990D00'));
        --        v_Text01 := v_Text01 || --
        --                    Dsp_Planilha.Campo(p_Conteudo => To_Char(V_VLR_IPI,
        --                                                             'FM999G999G990D00'));
        --        v_Text01 := v_Text01 || --
        --                    Dsp_Planilha.Campo(p_Conteudo => To_Char(V_DIF_BASES,
        --                                                             'FM999G999G990D00'));
        --        Lib_Proc.Add(Dsp_Planilha.Linha(p_Conteudo => v_Text01,
        --                                        p_Class    => v_Class),
        --                     Ptipo => v_Cont_Arq + 1);
        --
        --        v_Contr_Plan := v_Contr_Plan - 1;

        --EXIT WHEN Cr_009%NOTFOUND;
        --End Loop;
        --CLOSE Cr_009;

        -- IMPRIME RESUMO
        lib_proc.add ( 'Arquivos gerados:'
                     , ptipo => 1 );
        lib_proc.add ( ' '
                     , ptipo => 1 );

        FOR c IN 1 .. v_cont_arq LOOP
            v_text01 :=
                   'Fechamento-'
                || TO_CHAR ( p_data_ini
                           , 'YYYYMMDD' )
                || '-'
                || TO_CHAR ( p_data_fim
                           , 'YYYYMMDD' )
                || '-'
                || LPAD ( c
                        , 2
                        , '0' )
                || '.XLS';

            IF c = v_cont_arq THEN
                v_text01 :=
                       v_text01
                    || ' => '
                    || LPAD ( TO_CHAR ( v_quebra_arq - v_contr_plan
                                      , '9G999G990' )
                            , 11
                            , ' ' )
                    || ' REGISTROS.';
            ELSE
                v_text01 :=
                       v_text01
                    || ' => '
                    || LPAD ( TO_CHAR ( v_quebra_arq
                                      , '9G999G990' )
                            , 11
                            , ' ' )
                    || ' REGISTROS.';
            END IF;

            --
            lib_proc.add ( v_text01
                         , ptipo => 1 );
        END LOOP;
    END gera_relatorio_009;



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
        -- Cria��o: Processo
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

        FOR v_cod_estab IN pcod_estab.FIRST .. pcod_estab.LAST LOOP
            NULL;
        END LOOP;



        loga ( '<< PERIODO DE: ' || pdata_inicial || ' A ' || pdata_final || ' >>'
             , FALSE );



        --===================================
        -- LIMPEZAS DAS TMP PROVISIORIAMENTE
        --===================================
        BEGIN
            DELETE FROM msafi.fin4816_report_fiscal_gtt;

            --DELETE from msafi.fin4816_prev_gtt;
            DELETE FROM msafi.fin4816_reinf_prev_gtt;

            DELETE FROM msafi.fin4816_reinf_2010_gtt;

            DELETE FROM msafi.fin4816_prev_tmp_estab;

            COMMIT;
        END;



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
                                               , -- 'PROCESSAR_EXCLUSAO',
                                                'TO_DATE('''
                                                 || TO_CHAR ( pdata_inicial
                                                            , 'DDMMYYYY' )
                                                 || ''',''DDMMYYYY''),'
                                                 || 'TO_DATE('''
                                                 || TO_CHAR ( pdata_final
                                                            , 'DDMMYYYY' )
                                                 || ''',''DDMMYYYY''),'
                                                 || mproc_id
                                                 || ','''
                                                 || mcod_empresa
                                                 || ''','
                                                 || ''''
                                                 || mnm_usuario
                                                 || '''' );

        dbms_parallel_execute.drop_task ( p_task );

        --===================================
        ---  EXCEL ( )


        --load_excel_analitico (mproc_id);


        loga ( '---FIM DO PROCESSAMENTO---'
             , FALSE );

        lib_proc.close;
        RETURN mproc_id;
    END;
END dpsp_fin4816_prev_cproc;
/
SHOW ERRORS;
