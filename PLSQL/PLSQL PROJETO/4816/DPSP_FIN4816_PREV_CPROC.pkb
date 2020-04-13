CREATE OR REPLACE PACKAGE BODY  MSAF.DPSP_FIN4816_PREV_CPROC
IS
    mproc_id NUMBER;
    mnm_usuario usuario_estab.cod_usuario%TYPE;
    mcod_empresa estabelecimento.cod_empresa%TYPE;

    --Tipo, Nome e Descrição do Customizado
    mnm_tipo VARCHAR2 ( 100 ) :=  'Relatorio Previdenciario';
    mnm_cproc VARCHAR2 ( 100 ) := '1.Relatorio de apoio';
    mds_cproc VARCHAR2 ( 100 ) := 'Validacao das Inf. Reinf';

    v_sel_data_fim VARCHAR2 ( 260 )
        := 'SELECT TRUNC( TO_DATE( :1 ,''DD/MM/YYYY'') + ROWNUM - 1) AS DATA_FIM, TRUNC( TO_DATE( :1 ,''DD/MM/YYYY'') + ROWNUM - 1) AS DATA_FIM FROM DUAL CONNECT BY ROWNUM <= LAST_DAY( TO_DATE( :1 ,''DD/MM/YYYY'') ) - TO_DATE( :1 ,''DD/MM/YYYY'') + 1 ORDER BY 1 DESC ';

      i number := 0;
      
    
  
        -- =======================================
        -- Type  report fiscal / cursor 
        -- =======================================
            
     TYPE typ_cod_empresa             IS TABLE OF msafi.fin4816_report_fiscal_gtt.cod_empresa                 %TYPE  ;         
     TYPE typ_cod_estab               IS TABLE OF msafi.fin4816_report_fiscal_gtt.cod_estab                   %TYPE  ;         
     TYPE typ_data_fiscal             IS TABLE OF msafi.fin4816_report_fiscal_gtt.data_fiscal                 %TYPE  ;         
     TYPE typ_movto_e_s               IS TABLE OF msafi.fin4816_report_fiscal_gtt.movto_e_s                   %TYPE  ;         
     TYPE typ_norm_dev                IS TABLE OF msafi.fin4816_report_fiscal_gtt.norm_dev                    %TYPE  ;         
     TYPE typ_ident_docto             IS TABLE OF msafi.fin4816_report_fiscal_gtt.ident_docto                 %TYPE  ;         
     TYPE typ_ident_fis_jur           IS TABLE OF msafi.fin4816_report_fiscal_gtt.ident_fis_jur               %TYPE  ;         
     TYPE typ_num_docfis              IS TABLE OF msafi.fin4816_report_fiscal_gtt.num_docfis                  %TYPE  ;         
     TYPE typ_serie_docfis            IS TABLE OF msafi.fin4816_report_fiscal_gtt.serie_docfis                %TYPE  ;         
     TYPE typ_sub_serie_docfis        IS TABLE OF msafi.fin4816_report_fiscal_gtt.sub_serie_docfis            %TYPE  ;         
     TYPE typ_ident_servico           IS TABLE OF msafi.fin4816_report_fiscal_gtt.ident_servico               %TYPE  ;         
     TYPE typ_num_item                IS TABLE OF msafi.fin4816_report_fiscal_gtt.num_item                    %TYPE  ;         
     TYPE typ_periodo_emissao         IS TABLE OF msafi.fin4816_report_fiscal_gtt.periodo_emissao             %TYPE  ;         
     TYPE typ_cgc                     IS TABLE OF msafi.fin4816_report_fiscal_gtt.cgc                         %TYPE  ;         
     TYPE typ_num_docto               IS TABLE OF msafi.fin4816_report_fiscal_gtt.num_docto                   %TYPE  ;         
     TYPE typ_tipo_docto              IS TABLE OF msafi.fin4816_report_fiscal_gtt.tipo_docto                  %TYPE  ;         
     TYPE typ_data_emissao            IS TABLE OF msafi.fin4816_report_fiscal_gtt.data_emissao                %TYPE  ;         
     TYPE typ_cgc_fornecedor          IS TABLE OF msafi.fin4816_report_fiscal_gtt.cgc_fornecedor              %TYPE  ;         
     TYPE typ_uf                      IS TABLE OF msafi.fin4816_report_fiscal_gtt.uf                          %TYPE  ;         
     TYPE typ_valor_total             IS TABLE OF msafi.fin4816_report_fiscal_gtt.valor_total                 %TYPE  ;         
     TYPE typ_vlr_base_inss           IS TABLE OF msafi.fin4816_report_fiscal_gtt.vlr_base_inss               %TYPE  ;         
     TYPE typ_vlr_inss                IS TABLE OF msafi.fin4816_report_fiscal_gtt.vlr_inss                    %TYPE  ;         
     TYPE typ_codigo_fisjur           IS TABLE OF msafi.fin4816_report_fiscal_gtt.codigo_fisjur               %TYPE  ;         
     TYPE typ_razao_social            IS TABLE OF msafi.fin4816_report_fiscal_gtt.razao_social                %TYPE  ;         
     TYPE typ_municipio_prestador     IS TABLE OF msafi.fin4816_report_fiscal_gtt.municipio_prestador         %TYPE  ;         
     TYPE typ_cod_servico             IS TABLE OF msafi.fin4816_report_fiscal_gtt.cod_servico                 %TYPE  ;         
     TYPE typ_cod_cei                 IS TABLE OF msafi.fin4816_report_fiscal_gtt.cod_cei                     %TYPE  ;         
     TYPE typ_equalizacao             IS TABLE OF msafi.fin4816_report_fiscal_gtt.equalizacao                 %TYPE  ;        
 
      
             g_cod_empresa         typ_cod_empresa          ;                  
             g_cod_estab           typ_cod_estab            ;                  
             g_data_fiscal         typ_data_fiscal          ;                  
             g_movto_e_s           typ_movto_e_s            ;                  
             g_norm_dev            typ_norm_dev             ;                  
             g_ident_docto         typ_ident_docto          ;                  
             g_ident_fis_jur       typ_ident_fis_jur        ;                  
             g_num_docfis          typ_num_docfis           ;                  
             g_serie_docfis        typ_serie_docfis         ;                  
             g_sub_serie_docfis    typ_sub_serie_docfis     ;                  
             g_ident_servico       typ_ident_servico        ;                  
             g_num_item            typ_num_item             ;                  
             g_periodo_emissao     typ_periodo_emissao      ;                  
             g_cgc                 typ_cgc                  ;                  
             g_num_docto           typ_num_docto            ;                  
             g_tipo_docto          typ_tipo_docto           ;                  
             g_data_emissao        typ_data_emissao         ;                  
             g_cgc_fornecedor      typ_cgc_fornecedor       ;                  
             g_uf                  typ_uf                   ;                  
             g_valor_total         typ_valor_total          ;                  
             g_vlr_base_inss       typ_vlr_base_inss        ;                  
             g_vlr_inss            typ_vlr_inss             ;                  
             g_codigo_fisjur       typ_codigo_fisjur        ;                  
             g_razao_social        typ_razao_social         ;                  
             g_municipio_prestador typ_municipio_prestador  ;                  
             g_cod_servico         typ_cod_servico          ;                  
             g_equalizacao         typ_equalizacao          ;                   
             g_cod_cei             typ_cod_cei              ;      



           CURSOR cr_rtf   ( pdate  date, pcod_empresa varchar2 , p_proc_id NUMBER )
              is
             SELECT   
                 x09_itens_serv.cod_empresa                           as cod_empresa          -- Codigo da Empresa                                
               , x09_itens_serv.cod_estab                             as cod_estab            -- Codigo do Estabelecimento
               , x09_itens_serv.data_fiscal                           as data_fiscal          -- Data Fiscal   
               , x09_itens_serv.movto_e_s                             as movto_e_s                 
               , x09_itens_serv.norm_dev                              as norm_dev                             
               , x09_itens_serv.ident_docto                           as ident_docto               
               , x09_itens_serv.ident_fis_jur                         as ident_fis_jur             
               , x09_itens_serv.num_docfis                            as num_docfis                
               , x09_itens_serv.serie_docfis                          as serie_docfis              
               , x09_itens_serv.sub_serie_docfis                      as sub_serie_docfis          
               , x09_itens_serv.ident_servico                         as ident_servico             
               , x09_itens_serv.num_item                              as num_item     
               , x07_docto_fiscal.data_emissao                        as perido_emissao        -- Periodo de Emissão  
               , estabelecimento.cgc                                  as cgc                   -- CNPJ Drogaria 
               , x07_docto_fiscal.num_docfis                          as num_docto             -- Numero da Nota Fiscal
               , x2005_tipo_docto.cod_docto                           as tipo_docto            -- Tipo de Documento
               , x07_docto_fiscal.data_emissao                        as data_emissao          -- Data Emissão          
               , x04_pessoa_fis_jur.cpf_cgc                           as cgc_fornecedor        -- CNPJ_Fonecedor
               , estado.cod_estado                                    as uf                    -- uf 
               , x09_itens_serv.vlr_tot                               as valor_total           -- Valor Total da Nota
               , x09_itens_serv.vlr_base_inss                         as base_inss             -- Base de Calculo INSS
               , x09_itens_serv.vlr_inss_retido                       as valor_inss            -- Valor do INSS 
               , x04_pessoa_fis_jur.cod_fis_jur                       as cod_fis_jur           -- Codigo Pessoa Fisica/juridica
               , x04_pessoa_fis_jur.razao_social                      as razao_social          -- Razão Social
               , municipio.descricao                                  as municipio_prestador   -- Municipio Prestador
               , x2018_servicos.cod_servico                           as cod_servico           -- Codigo de Serviço
               , x07_docto_fiscal.cod_cei                             as cod_cei               -- Codigo CEI
               , NULL                                                 as equalizacao           -- Equalização    
              FROM x07_docto_fiscal
                 , x2005_tipo_docto    
                 , x04_pessoa_fis_jur      
                 , x09_itens_serv
                 , estabelecimento
                 , estado  
                 , x2018_servicos
                 , municipio  
                 , msafi.fin4816_prev_tmp_estab estab
             WHERE 1=1 
               AND   x09_itens_serv.cod_empresa               =   estabelecimento.cod_empresa
               AND   x09_itens_serv.cod_estab                 =   estabelecimento.cod_estab
               AND   x09_itens_serv.cod_estab                 =   estab.cod_estab
               AND   estab.proc_id                            =   p_proc_id
               AND   x09_itens_serv.cod_empresa               =   x07_docto_fiscal.cod_empresa
               AND   x09_itens_serv.cod_estab                 =   x07_docto_fiscal.cod_estab
               AND   x09_itens_serv.data_fiscal               =   x07_docto_fiscal.data_fiscal
               AND   x07_docto_fiscal.data_emissao            =   pdate     
               AND   x09_itens_serv.vlr_inss_retido           > 0              
               AND   x09_itens_serv.movto_e_s                 =   x07_docto_fiscal.movto_e_s
               AND   x09_itens_serv.norm_dev                  =   x07_docto_fiscal.norm_dev
               AND   x09_itens_serv.ident_docto               =   x07_docto_fiscal.ident_docto
               AND   x09_itens_serv.ident_fis_jur             =   x07_docto_fiscal.ident_fis_jur
               AND   x09_itens_serv.num_docfis                =   x07_docto_fiscal.num_docfis
               AND   x09_itens_serv.serie_docfis              =   x07_docto_fiscal.serie_docfis
               AND   x09_itens_serv.sub_serie_docfis          =   x07_docto_fiscal.sub_serie_docfis
               -- estado /municio 
               and  estado.ident_estado                       = x04_pessoa_fis_jur.ident_estado
               and  municipio.ident_estado                    = estado.ident_estado 
               and  municipio.cod_municipio                   = x04_pessoa_fis_jur.cod_municipio
               --  X2018_SERVICOS
               AND  x2018_servicos.ident_servico  = x09_itens_serv.ident_servico
               AND ( x2005_tipo_docto.ident_docto = x07_docto_fiscal.ident_docto )
               AND ( x04_pessoa_fis_jur.ident_fis_jur = x07_docto_fiscal.ident_fis_jur )
             --  AND ( x07_docto_fiscal.data_fiscal <= pdata_final   )    ---  DATA EMISSAO 
              -- AND ( x07_docto_fiscal.data_fiscal >= pdata_inicial )
               AND ( x07_docto_fiscal.movto_e_s IN ( 1
                                                   , 2
                                                   , 3
                                                   , 4
                                                   , 5 ) )
               AND ( ( x07_docto_fiscal.situacao <> 'S' )
                 OR ( x07_docto_fiscal.situacao IS NULL ) )
               AND ( x07_docto_fiscal.cod_estab  IS NOT NULL  )  -- COD_ESTAB 
               AND ( x07_docto_fiscal.cod_empresa =  pcod_empresa )
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
                                   AND pcum.cod_param = 415  --
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
                  ORDER BY 
                            x09_itens_serv.cod_empresa                 
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
                           , x09_itens_serv.num_item    
                  ;
                  
          

    -- =======================================
    -- Type  previdenciario/ cursor  
    -- =======================================
    TYPE typ_tipo_prv                  IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.tipo%TYPE;
    TYPE typ_codigo_empresa_prv         IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Codigo Empresa"%TYPE;
    TYPE typ_codigo_estab_prv           IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Codigo Estabelecimento"%TYPE;
    TYPE typ_data_emissao_prv           IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Data Emissão"%TYPE;
    TYPE typ_data_fiscal_prv            IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Data Fiscal"%TYPE;
    TYPE typ_ident_fis_jur_prv          IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.ident_fis_jur%TYPE;
    TYPE typ_ident_docto_prv            IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.ident_docto%TYPE;
    TYPE typ_numero_nota_fiscal_prv     IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Número da Nota Fiscal"%TYPE;
    TYPE typ_docto_serie_prv            IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Docto/Série"%TYPE;
    TYPE typ_emissao_prv                IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Emissão"%TYPE;
    TYPE typ_serie_docfis_prv           IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.serie_docfis%TYPE;
    TYPE typ_sub_serie_docfis_prv       IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.sub_serie_docfis%TYPE;
    TYPE typ_num_item_prv               IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.num_item%TYPE;
    TYPE typ_cod_usuario_prv            IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.cod_usuario%TYPE;
    TYPE typ_codigo_pess_fis_jur_prv    IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Codigo Pessoa Fisica/Juridica"%TYPE;
    TYPE typ_razao_social_cliente_prv   IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Razão Social Cliente"%TYPE;
    TYPE typ_ind_fis_jur_prv            IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.ind_fis_jur%TYPE;
    TYPE typ_cnpj_cliente_prv           IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."CNPJ Cliente"%TYPE;
    TYPE typ_cod_class_doc_fis_prv      IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.cod_class_doc_fis%TYPE;
    TYPE typ_vlr_tot_nota_prv           IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.vlr_tot_nota%TYPE;
    TYPE typ_vlr_bs_calc_retencao_prv   IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Vlr Base Calc. Retenção"%TYPE;
    TYPE typ_vlr_aliq_inss_prv          IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.vlr_aliq_inss%TYPE;
    TYPE typ_vlr_trib_inss_retido_prv   IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Vlr.Trib INSS RETIDO"%TYPE;
    TYPE typ_vlr_retencao_prv          IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Valor da Retenção"%TYPE;
    TYPE typ_vlr_contab_compl_prv       IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.vlr_contab_compl%TYPE;
    TYPE typ_ind_tipo_proc_prv          IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.ind_tipo_proc%TYPE;
    TYPE typ_num_proc_jur_prv           IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.num_proc_jur%TYPE;
    TYPE typ_razao_social_prv           IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.razao_social%TYPE;
    TYPE typ_cgc_prv                    IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.cgc%TYPE;
    TYPE typ_documento_prv              IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Documento"%TYPE;
    TYPE typ_tipo_serv_e_social_prv     IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Tipo de Serviço E-social"%TYPE;
    TYPE typ_dsc_tipo_serv_esocial_prv  IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.dsc_tipo_serv_esocial%TYPE;
    TYPE typ_razao_social_drogaria_prv  IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Razão Social Drogaria"%TYPE;
    TYPE typ_valor_servico_prv          IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Valor do Servico"%TYPE;
    TYPE typ_num_proc_adj_adic_prv      IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.num_proc_adj_adic%TYPE;
    TYPE typ_ind_tp_proc_adj_adic_prv   IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.ind_tp_proc_adj_adic%TYPE;
    TYPE typ_codigo_serv_prod_prv       IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.codigo_serv_prod%TYPE;
    TYPE typ_desc_serv_prod_prv         IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.desc_serv_prod%TYPE;
    TYPE typ_cod_docto_prv              IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.cod_docto%TYPE;
    TYPE typ_observação_prv             IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt."Observação"%TYPE;
    TYPE typ_dsc_param_prv              IS TABLE OF msafi.dpsp_tb_fin4816_reinf_prev_gtt.dsc_param%TYPE;

            g_tipo_prv                    typ_tipo_prv                   ;
            g_codigo_empresa_prv          typ_codigo_empresa_prv         ;
            g_codigo_estab_prv            typ_codigo_estab_prv           ;
            g_data_emissao_prv            typ_data_emissao_prv           ;
            g_data_fiscal_prv             typ_data_fiscal_prv            ;
            g_ident_fis_jur_prv           typ_ident_fis_jur_prv          ;
            g_ident_docto_prv             typ_ident_docto_prv            ;
            g_numero_nota_fiscal_prv      typ_numero_nota_fiscal_prv     ;
            g_docto_serie_prv             typ_docto_serie_prv            ;
            g_emissao_prv                 typ_emissao_prv                ;
            g_serie_docfis_prv            typ_serie_docfis_prv           ;
            g_sub_serie_docfis_prv        typ_sub_serie_docfis_prv       ;
            g_num_item_prv                typ_num_item_prv               ;
            g_cod_usuario_prv             typ_cod_usuario_prv            ;
            g_codigo_pess_fis_jur_prv     typ_codigo_pess_fis_jur_prv    ;
            g_razao_social_cliente_prv    typ_razao_social_cliente_prv   ;
            g_ind_fis_jur_prv             typ_ind_fis_jur_prv            ;
            g_cnpj_cliente_prv            typ_cnpj_cliente_prv           ;
            g_cod_class_doc_fis_prv       typ_cod_class_doc_fis_prv      ;
            g_vlr_tot_nota_prv            typ_vlr_tot_nota_prv           ;
            g_vlr_bs_calc_retencao_prv    typ_vlr_bs_calc_retencao_prv   ;
            g_vlr_aliq_inss_prv           typ_vlr_aliq_inss_prv          ;
            g_vlr_trib_inss_retido_prv    typ_vlr_trib_inss_retido_prv   ;
            g_vlr_retencao_prv            typ_vlr_retencao_prv           ;     --
            g_vlr_contab_compl_prv        typ_vlr_contab_compl_prv       ;
            g_ind_tipo_proc_prv           typ_ind_tipo_proc_prv          ;
            g_num_proc_jur_prv            typ_num_proc_jur_prv           ;
            g_razao_social_prv            typ_razao_social_prv           ;
            g_cgc_prv                     typ_cgc_prv                    ;
            g_documento_prv               typ_documento_prv              ;
            g_tipo_serv_e_social_prv      typ_tipo_serv_e_social_prv     ;
            g_dsc_tipo_serv_esocial_prv   typ_dsc_tipo_serv_esocial_prv  ;
            g_razao_social_drogaria_prv   typ_razao_social_drogaria_prv  ;
            g_valor_servico_prv           typ_valor_servico_prv          ;
            g_num_proc_adj_adic_prv       typ_num_proc_adj_adic_prv      ;
            g_ind_tp_proc_adj_adic_prv    typ_ind_tp_proc_adj_adic_prv   ;
            g_codigo_serv_prod_prv        typ_codigo_serv_prod_prv       ;
            g_desc_serv_prod_prv          typ_desc_serv_prod_prv         ;
            g_cod_docto_prv               typ_cod_docto_prv              ;
            g_observação_prv              typ_observação_prv             ;
            g_dsc_param_prv               typ_dsc_param_prv              ;
                            



        CURSOR rc_prev   ( pdate  date, pcod_empresa varchar2 , p_proc_id NUMBER )
         IS
         SELECT 
             'S' AS tipo
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
          FROM msafi.reinf_conf_previdenciaria_tmp  reinf
             , msafi.fin4816_prev_tmp_estab         estab1
             , x04_pessoa_fis_jur                   x04
             , estabelecimento                      estab
             , x2005_tipo_docto                     x2005
             , prt_tipo_serv_esocial                prt_tipo
             , x2018_servicos                       x2018
             , empresa             
         WHERE 1=1 
           AND reinf.cod_estab                  = estab1.cod_estab      -- parametro
           AND estab1.proc_id                   = p_proc_id             -- parametro
           AND reinf.cod_empresa                = pcod_empresa          -- parametro
           AND reinf.data_emissao               = pdate                 -- parametro
           ---
           AND reinf.ident_fis_jur              = x04.ident_fis_jur
           AND reinf.cod_empresa                = estab.cod_empresa
           AND reinf.cod_estab                  = estab.cod_estab
           AND reinf.ident_docto                = x2005.ident_docto
           AND reinf.ident_tipo_serv_esocial    = prt_tipo.ident_tipo_serv_esocial /*(+)*/
           AND reinf.cod_empresa                = empresa.cod_empresa
           AND LENGTH ( TRIM ( x04.cpf_cgc ) ) > 11
           AND reinf.ident_servico  = x2018.ident_servico
           --AND reinf.cod_usuario    = 'marcelo.orikasa' 
           --AND reinf.cod_empresa    = 'DSP'             
           --AND reinf.data_emissao   = '4/12/2018'      
           --AND reinf.cod_estab      = 'DSP062'
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
            FROM msafi.reinf_conf_previdenciaria_tmp  reinf
             ,   msafi.fin4816_prev_tmp_estab          estab1
             , x04_pessoa_fis_jur                     x04 
             , estabelecimento                        estab
             , x2005_tipo_docto                       x2005
             , prt_par2_msaf                          prt_repasse
             , x2018_servicos                         x2018
             , empresa
         WHERE 1=1 
           AND reinf.cod_estab                  = estab1.cod_estab      -- parametro
           AND estab1.proc_id                   = p_proc_id             -- parametro
           AND reinf.cod_empresa                = pcod_empresa          -- parametro
           AND reinf.data_emissao               = pdate                 -- parametro
           --
           AND reinf.ident_fis_jur              = x04.ident_fis_jur
           AND reinf.cod_empresa                = estab.cod_empresa
           AND reinf.cod_estab                  = estab.cod_estab
           AND reinf.ident_docto                = x2005.ident_docto
           AND reinf.cod_param                  = prt_repasse.cod_param
           AND reinf.cod_empresa                = empresa.cod_empresa
           AND LENGTH ( TRIM ( x04.cpf_cgc ) ) > 11
           AND reinf.ident_servico              = x2018.ident_servico
           --  AND reinf.cod_usuario                = mnm_usuario
           --  AND reinf.cod_empresa                = p_cod_empresa
           --  AND reinf.cod_estab                  = p_cod_estab
           --  AND reinf.data_emissao              >= p_data_inicial
           --  AND reinf.data_emissao              <= p_data_final
                                                        ;
                          
                  
                  
         

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


  PROCEDURE carga (   pnr_particao INTEGER
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
     
        l_status number ;
     
    BEGIN
    
        EXECUTE IMMEDIATE ( 'ALTER SESSION SET CURSOR_SHARING = FORCE' );
        EXECUTE IMMEDIATE ( 'ALTER SESSION SET TEMP_UNDO_ENABLED=FALSE ' );
        EXECUTE IMMEDIATE   'ALTER SESSION SET NLS_DATE_FORMAT = ''DD/MM/YYYY''';
        EXECUTE IMMEDIATE   'ALTER SESSION SET NLS_NUMERIC_CHARACTERS= '',.'' ';

        --DELETE FROM msafi.fin2662_x08_gtt;   --  ajustar aqui  com o delete rowid 
        --COMMIT;


        -- Registra o andamento do processo na v$session
        dbms_application_info.set_module ( cc_procedurename, 'n:' || vn_count_new );
        v_data := p_data_ini - 1 + pnr_particao;
        dbms_application_info.set_module ( cc_procedurename || '  ' || v_data , 'n:' || vn_count_new );
          
          
          
            --================================================
            -- Table -  report fiscal 
            --================================================
        
            OPEN cr_rtf   (v_data, p_nm_empresa, p_proc_id ) ;

            LOOP
           --
           DBMS_APPLICATION_INFO.SET_MODULE(cc_procedurename,'Executando o fetch report fiscal ...');
           --
           
             FETCH cr_rtf 
                BULK COLLECT INTO    -- TABLE  TMP                      
                   g_cod_empresa                                                       
                  ,g_cod_estab                                                         
                  ,g_data_fiscal                                                       
                  ,g_movto_e_s                                                         
                  ,g_norm_dev                                                          
                  ,g_ident_docto                                                       
                  ,g_ident_fis_jur                                                     
                  ,g_num_docfis                                                        
                  ,g_serie_docfis                                                      
                  ,g_sub_serie_docfis                                                  
                  ,g_ident_servico                                                     
                  ,g_num_item                                                          
                  ,g_periodo_emissao                                                   
                  ,g_cgc                                                               
                  ,g_num_docto                                                         
                  ,g_tipo_docto                                                        
                  ,g_data_emissao                                                      
                  ,g_cgc_fornecedor                                                    
                  ,g_uf                                                                
                  ,g_valor_total                                                       
                  ,g_vlr_base_inss                                                     
                  ,g_vlr_inss                                                          
                  ,g_codigo_fisjur                                                     
                  ,g_razao_social                                                      
                  ,g_municipio_prestador                                               
                  ,g_cod_servico                                                       
                  ,g_cod_cei   
                  ,g_equalizacao                                                        
                LIMIT cc_limit;



            -- inicia o cursor
                 FORALL i IN g_cod_empresa.FIRST .. g_cod_empresa.LAST
                 INSERT /*+ APPEND */
                 INTO msafi.fin4816_report_fiscal_gtt
                   (  cod_empresa         
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
                  VALUES (          
                         g_cod_empresa           (i),       
                         g_cod_estab             (i),  
                         g_data_fiscal           (i),  
                         g_movto_e_s             (i),  
                         g_norm_dev              (i),  
                         g_ident_docto           (i),  
                         g_ident_fis_jur         (i),  
                         g_num_docfis            (i),  
                         g_serie_docfis          (i),  
                         g_sub_serie_docfis      (i),  
                         g_ident_servico         (i),  
                         g_num_item              (i),  
                         g_periodo_emissao       (i),  
                         g_cgc                   (i),  
                         g_num_docto             (i),  
                         g_tipo_docto            (i),  
                         g_data_emissao          (i),  
                         g_cgc_fornecedor        (i),  
                         g_uf                    (i),  
                         g_valor_total           (i),  
                         g_vlr_base_inss         (i),  
                         g_vlr_inss              (i),  
                         g_codigo_fisjur         (i),  
                         g_razao_social          (i),  
                         g_municipio_prestador   (i),  
                         g_cod_servico           (i),  
                         g_cod_cei               (i),  
                         g_equalizacao           (i)
                           );
        --END;

            vn_count_new := vn_count_new + SQL%ROWCOUNT;
            COMMIT;

            -- Registra o andamento do processo na v$session
            dbms_application_info.set_module ( cc_procedurename || '  ' || v_data, 'n:' || vn_count_new );
            dbms_application_info.set_client_info ( TO_CHAR ( SYSDATE, 'dd-mm-yyyy hh24:mi:ss' ) );

                     
            
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
                         
            EXIT WHEN cr_rtf%NOTFOUND;
            
        END LOOP;

        COMMIT;

        CLOSE cr_rtf;

        COMMIT;

      
        
        
         --================================================
         -- Table -  Report previdenciario 
         --================================================
        BEGIN
          vn_count_new := 0;     
          OPEN rc_prev (v_data, p_nm_empresa, p_proc_id ) ;

         LOOP
             --
                dbms_application_info.set_module ( cc_procedurename
                                                 , 'Executando o fetch previdenciario ...' );

                 FETCH rc_prev
                    BULK COLLECT INTO -- TABLE  TMP
                     g_tipo_prv                 
                    ,g_codigo_empresa_prv       
                    ,g_codigo_estab_prv         
                    ,g_data_emissao_prv         
                    ,g_data_fiscal_prv          
                    ,g_ident_fis_jur_prv        
                    ,g_ident_docto_prv          
                    ,g_numero_nota_fiscal_prv   
                    ,g_docto_serie_prv          
                    ,g_emissao_prv              
                    ,g_serie_docfis_prv         
                    ,g_sub_serie_docfis_prv     
                    ,g_num_item_prv             
                    ,g_cod_usuario_prv          
                    ,g_codigo_pess_fis_jur_prv  
                    ,g_razao_social_cliente_prv 
                    ,g_ind_fis_jur_prv          
                    ,g_cnpj_cliente_prv         
                    ,g_cod_class_doc_fis_prv    
                    ,g_vlr_tot_nota_prv         
                    ,g_vlr_bs_calc_retencao_prv 
                    ,g_vlr_aliq_inss_prv        
                    ,g_vlr_trib_inss_retido_prv 
                    ,g_vlr_retencao_prv        
                    ,g_vlr_contab_compl_prv     
                    ,g_ind_tipo_proc_prv        
                    ,g_num_proc_jur_prv         
                    ,g_razao_social_prv         
                    ,g_cgc_prv                  
                    ,g_documento_prv            
                    ,g_tipo_serv_e_social_prv   
                    ,g_dsc_tipo_serv_esocial_prv
                    ,g_razao_social_drogaria_prv
                    ,g_valor_servico_prv        
                    ,g_num_proc_adj_adic_prv    
                    ,g_ind_tp_proc_adj_adic_prv 
                    ,g_codigo_serv_prod_prv     
                    ,g_desc_serv_prod_prv       
                    ,g_cod_docto_prv            
                    ,g_observação_prv           
                    ,g_dsc_param_prv    
                    
                    LIMIT cc_limit;
                    
              
             
             FORALL i IN g_num_item_prv.FIRST .. g_num_item_prv.LAST                    
             INSERT /*+ APPEND */
                INTO MSAFI.DPSP_TB_FIN4816_REINF_PREV_GTT (
                        TIPO, "Codigo Empresa", "Codigo Estabelecimento", 
                        "Data Emissão", "Data Fiscal", IDENT_FIS_JUR, 
                        IDENT_DOCTO, "Número da Nota Fiscal", "Docto/Série", 
                        "Emissão", SERIE_DOCFIS, SUB_SERIE_DOCFIS, 
                         NUM_ITEM, COD_USUARIO, "Codigo Pessoa Fisica/Juridica", 
                         "Razão Social Cliente", IND_FIS_JUR, "CNPJ Cliente", 
                         COD_CLASS_DOC_FIS, VLR_TOT_NOTA, "Vlr Base Calc. Retenção", 
                         VLR_ALIQ_INSS, "Vlr.Trib INSS RETIDO", "Valor da Retenção", 
                         VLR_CONTAB_COMPL, IND_TIPO_PROC, NUM_PROC_JUR, 
                         RAZAO_SOCIAL, CGC, "Documento", 
                         "Tipo de Serviço E-social", DSC_TIPO_SERV_ESOCIAL, "Razão Social Drogaria", 
                         "Valor do Servico", NUM_PROC_ADJ_ADIC, IND_TP_PROC_ADJ_ADIC, 
                          CODIGO_SERV_PROD, DESC_SERV_PROD, COD_DOCTO, "Observação", DSC_PARAM) 
                VALUES (      
                             g_tipo_prv                      (i)
                            ,g_codigo_empresa_prv            (i)
                            ,g_codigo_estab_prv              (i)
                            ,g_data_emissao_prv              (i)
                            ,g_data_fiscal_prv               (i)
                            ,g_ident_fis_jur_prv             (i)
                            ,g_ident_docto_prv               (i)
                            ,g_numero_nota_fiscal_prv        (i)
                            ,g_docto_serie_prv               (i)
                            ,g_emissao_prv                   (i)
                            ,g_serie_docfis_prv              (i)
                            ,g_sub_serie_docfis_prv          (i)
                            ,g_num_item_prv                  (i)
                            ,g_cod_usuario_prv               (i)
                            ,g_codigo_pess_fis_jur_prv       (i)
                            ,g_razao_social_cliente_prv      (i)
                            ,g_ind_fis_jur_prv               (i)
                            ,g_cnpj_cliente_prv              (i)
                            ,g_cod_class_doc_fis_prv         (i)
                            ,g_vlr_tot_nota_prv              (i)
                            ,g_vlr_bs_calc_retencao_prv      (i)
                            ,g_vlr_aliq_inss_prv             (i)
                            ,g_vlr_trib_inss_retido_prv      (i)
                            ,g_vlr_retencao_prv             (i)
                            ,g_vlr_contab_compl_prv          (i)
                            ,g_ind_tipo_proc_prv             (i)
                            ,g_num_proc_jur_prv              (i)
                            ,g_razao_social_prv              (i)
                            ,g_cgc_prv                       (i)
                            ,g_documento_prv                 (i)
                            ,g_tipo_serv_e_social_prv        (i)
                            ,g_dsc_tipo_serv_esocial_prv     (i)
                            ,g_razao_social_drogaria_prv     (i)
                            ,g_valor_servico_prv             (i)
                            ,g_num_proc_adj_adic_prv         (i)
                            ,g_ind_tp_proc_adj_adic_prv      (i)
                            ,g_codigo_serv_prod_prv          (i)
                            ,g_desc_serv_prod_prv            (i)
                            ,g_cod_docto_prv                 (i)
                            ,g_observação_prv                (i)
                            ,g_dsc_param_prv                 (i) );
                            
                            
                            
                            
                            vn_count_new := vn_count_new + SQL%ROWCOUNT;
                            COMMIT;
                            -- Registra o andamento do processo na v$session
                            dbms_application_info.set_module ( cc_procedurename || '  ' || v_data, 'n:' || vn_count_new );
                            dbms_application_info.set_client_info ( TO_CHAR ( SYSDATE, 'dd-mm-yyyy hh24:mi:ss' ) );
                            
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
                
                END LOOP;
                  COMMIT;
                    CLOSE rc_prev;

                    
        
        END ; 
       

        dbms_application_info.set_module ( cc_procedurename || '  ' || v_data , 'Carga definitiva' );
        dbms_application_info.set_module ( cc_procedurename , 'END:' || vn_count_new );
        
        

    END  carga;
    
    
    
    
  PROCEDURE load_excel_analitico (p_proc_instance IN VARCHAR2) IS
  
    v_sql    VARCHAR2(20000);
    v_text01 VARCHAR2(20000);
    v_class  VARCHAR2(1) := 'a';
    c_conc   SYS_REFCURSOR;
    p_lojas  VARCHAR2(6);
  
   

    CURSOR RCX 
    IS 
     SELECT a.*
      FROM  msafi.fin4816_prev_final_gtt  a
     ORDER BY ID;
      
    x  number ;
  BEGIN
        EXECUTE IMMEDIATE   'ALTER SESSION SET NLS_DATE_FORMAT = ''DD/MM/YYYY''';
        EXECUTE IMMEDIATE   'ALTER SESSION SET NLS_NUMERIC_CHARACTERS= '',.'' ';
        
        
     
        
         BEGIN
         
         --   SELECT * FROM msafi.fin4816_prev_gtt
         --   SELECT * FROM msafi.fin4816_prev_final_gtt
         
            INSERT INTO msafi.fin4816_prev_final_gtt
             SELECT 
                  NULL
                , cod_empresa         , cod_estab         ,TO_CHAR(data_emissao, 'MM/YYYY') data_emissao , cgc                  , num_docto         , tipo_docto
                , data_emissao        , data_fiscal       , cgc_fornecedor           , uf                   , valor_total       , vlr_base_inss
                , vlr_inss            , codigo_fisjur     , razao_social             , municipio_prestador   , cod_servico
                , null, null, null, null , null, null, null, null, null, null, null, null, null, null, 'A'
             FROM msafi.fin4816_prev_gtt
              WHERE vlr_inss > 0
              
              ;
         COMMIT ;
        
        
        
             DECLARE
              CURSOR RC
                IS
              SELECT  MIN(ID) ID , col32
               FROM msafi.fin4816_prev_final_gtt  a
               GROUP BY col32
              ORDER BY ID;

            BEGIN

                FOR x IN rc LOOP
                     UPDATE msafi.fin4816_prev_final_gtt a
                       SET a.col31 = 'R'
                     WHERE a.id = x.id
                     AND   a.col32 = 'A';
                     
                     UPDATE msafi.fin4816_prev_final_gtt a
                      SET  a.col31 = 'R'
                     WHERE a.id   = x.id
                     AND   a.col32 = 'B';
                     
                    COMMIT;
                END LOOP;

            END;
        
        
        
        
        
        END;  
  
          
  
    i := 11;
    loga('>>> Relatorio Previdenciario ' || p_proc_instance, FALSE);  
    lib_proc.add_tipo(p_proc_instance,i,mcod_empresa || '_analitico_reinf_' ||to_char(sysdate,'MMYYYY') || '.XLS',2);
  
    COMMIT;
  
        lib_proc.add(dsp_planilha.header, ptipo => i);
        lib_proc.add(dsp_planilha.tabela_inicio, ptipo => i);  
       -- lib_proc.add(dsp_planilha.linha(p_conteudo => dsp_planilha.campo('Report_Fiscal',p_custom => 'COLSPAN=31'),p_class => 'h'),ptipo => i);
    
    
 
  
--        lib_proc.add(dsp_planilha.linha(p_conteudo => 
--                     dsp_planilha.campo('COD_EMPRESA')       || --             
--                     dsp_planilha.campo('COD_ESTAB')         || --             
--                     dsp_planilha.campo('PERIODO_EMISSAO')   || --             
--                     dsp_planilha.campo('CGC')               || --             
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
  
    
   
    
     
      
        FOR ii IN rcx  LOOP
        
          IF v_class = 'a'
          THEN
            v_class := 'b';
          ELSE
            v_class := 'a';
          END IF;
        
            IF  ii.col31 = 'R'  AND ii.col32   = 'A' THEN
            lib_proc.add(dsp_planilha.linha(p_conteudo => dsp_planilha.campo('Report_Fiscal',p_custom => 'COLSPAN=31'),p_class => 'h'),ptipo => i);
            
            
            lib_proc.add(dsp_planilha.linha(p_conteudo => 
                     dsp_planilha.campo('COD_EMPRESA')       || --             
                     dsp_planilha.campo('COD_ESTAB')         || --             
                     dsp_planilha.campo('PERIODO_EMISSAO')   || --             
                     dsp_planilha.campo('CGC_ESTAB')         || --             
                     dsp_planilha.campo('NUM_DOCTO')         || --             
                     dsp_planilha.campo('TIPO_DOCTO')        || --             
                     dsp_planilha.campo('DATA_EMISSAO')      || --             
                     dsp_planilha.campo('DATA_FISCAL')       || --             
                     dsp_planilha.campo('CGC_FORNECEDOR')    || --             
                     dsp_planilha.campo('UF')                || --             
                     dsp_planilha.campo('VALOR_TOTAL')       || --             
                     dsp_planilha.campo('VLR_BASE_INSS')     || --             
                     dsp_planilha.campo('VLR_INSS')          || --             
                     dsp_planilha.campo('CODIGO_FISJUR')     || --             
                     dsp_planilha.campo('RAZAO_SOCIAL')      || --             
                     dsp_planilha.campo('MUNICIPIO_PRESTADOR')|| --            
                     dsp_planilha.campo('COD_SERVICO')          --             
                                            , p_class => 'h'), ptipo => i); 
                                            
                                            
                                            
                                            
                                            
                                            
                                                    
             ELSIF  ii.col31   = 'R'   AND  ii.col32   = 'B'  THEN
             lib_proc.add(dsp_planilha.linha(p_conteudo => dsp_planilha.campo('Report_Previdenciario',p_custom => 'COLSPAN=31'),p_class => 'h'),ptipo => i);
             END IF; 
           

          v_text01 := dsp_planilha.linha(p_conteudo => 
                      dsp_planilha.campo(ii.col1)           ||                  -- cod_empresa    
                      dsp_planilha.campo(ii.col2)           ||                  -- cod_estab
                      dsp_planilha.campo(ii.col3)           ||                  -- periodo_emiss                      
                      dsp_planilha.campo(dsp_planilha.texto(TO_CHAR(ii.col4))) ||-- cgc
                      dsp_planilha.campo(ii.col5)           ||                  --  num_docto
                      dsp_planilha.campo(ii.col6)           ||                  --  tipo_docto
                      dsp_planilha.campo(ii.col7)           ||                  --  data_emissao
                      dsp_planilha.campo(ii.col8)           ||                  --  data_fiscal
                      dsp_planilha.campo(dsp_planilha.texto(TO_CHAR(ii.col9))) ||-- cgc_fornecedo
                      dsp_planilha.campo(ii.col10)          ||                   -- uf
                      dsp_planilha.campo(ii.col11)          ||                   -- valor_total
                      dsp_planilha.campo(ii.col12)          ||                   -- vlr_base_inss
                      dsp_planilha.campo(ii.col13)          ||                   -- vlr_inss
                      dsp_planilha.campo(ii.col14)          ||                   -- codigo_fisjur
                      dsp_planilha.campo(ii.col15)          ||                   -- razao_social
                      dsp_planilha.campo(ii.col16)          ||                   -- municipio_pre
                      dsp_planilha.campo(ii.col17)                               -- cod_servico
                                           ,p_class => v_class);
        
           msaf.lib_proc.add(v_text01, ptipo => i);
    
      END LOOP;
  
    lib_proc.add(dsp_planilha.tabela_fim, ptipo => i);
  
  END load_excel_analitico;
  
  
  
  
  
  
  
  
  PROCEDURE prc_reinf_conf_retencao ( 
                                    p_cod_empresa IN VARCHAR2
                                  , p_cod_estab IN VARCHAR2  
                                  , p_tipo_selec IN VARCHAR2
                                  , p_data_inicial IN DATE
                                  , p_data_final IN DATE
                                  , p_cod_usuario IN VARCHAR2
                                  , p_entrada_saida IN VARCHAR2
                                  , p_proc_id    INTEGER 
                                  , p_status   in  OUT NUMBER )
IS
    cod_empresa_w estabelecimento.cod_empresa%TYPE;
    cod_estab_w estabelecimento.cod_estab%TYPE;
    data_ini_w DATE;
    data_fim_w DATE;


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
          FROM dwt_docto_fiscal                 doc_fis
             , dwt_itens_serv                   dwt_itens
             , x2018_servicos                   x2018
             , prt_id_tipo_serv_esocial         id_tipo_serv
             , prt_tipo_serv_esocial        tipo_serv
             , x2058_proc_adj x2058
             , x2058_proc_adj x2058_adic             
            -- , msafi.fin4816_prev_tmp_estab estab
         WHERE 1=1
           --AND doc_fis.cod_estab                    = estab.cod_estab
          -- AND estab.proc_id                        = p_proc_id
           AND doc_fis.cod_empresa                  = dwt_itens.cod_empresa
           AND doc_fis.cod_estab                    = dwt_itens.cod_estab
           AND doc_fis.data_fiscal                  = dwt_itens.data_fiscal
           AND doc_fis.ident_fis_jur                = dwt_itens.ident_fis_jur
           AND doc_fis.ident_docto                  = dwt_itens.ident_docto
           AND doc_fis.num_docfis                   = dwt_itens.num_docfis
           AND doc_fis.serie_docfis                 = dwt_itens.serie_docfis
           AND doc_fis.sub_serie_docfis             = dwt_itens.sub_serie_docfis
           AND dwt_itens.ident_proc_adj_princ       = x2058.ident_proc_adj(+)
           AND dwt_itens.ident_proc_adj_adic        = x2058_adic.ident_proc_adj(+)
           AND id_tipo_serv.cod_empresa             = doc_fis.cod_empresa
           AND id_tipo_serv.cod_estab               = doc_fis.cod_estab
           AND dwt_itens.ident_servico              = x2018.ident_servico
           AND x2018.grupo_servico                  = id_tipo_serv.grupo_servico
           AND x2018.cod_servico                    = id_tipo_serv.cod_servico
           AND id_tipo_serv.cod_tipo_serv_esocial   = tipo_serv.cod_tipo_serv_esocial
           AND tipo_serv.data_ini_vigencia          = (SELECT MAX ( a.data_ini_vigencia )
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
           --  , msafi.fin4816_prev_tmp_estab estab
          WHERE 1=1
          -- AND doc_fis.cod_estab                    = estab.cod_estab
          -- AND estab.proc_id                        = p_proc_id
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
          FROM dwt_docto_fiscal             doc_fis
             , dwt_itens_merc               dwt_merc
             , x2013_produto                x2013
             , prt_id_tipo_serv_prod        id_tipo_serv
             , prt_tipo_serv_esocial        tipo_serv
             , x2058_proc_adj               x2058
             , x2058_proc_adj               x2058_adic
             , x2024_modelo_docto           x2024
            -- , msafi.fin4816_prev_tmp_estab estab
          WHERE 1=1
           --  AND doc_fis.cod_estab                    = estab.cod_estab
           --  AND estab.proc_id                        = p_proc_id
           AND doc_fis.cod_empresa                  = dwt_merc.cod_empresa
           AND doc_fis.cod_estab                    = dwt_merc.cod_estab
           AND doc_fis.data_fiscal                  = dwt_merc.data_fiscal
           AND doc_fis.ident_fis_jur                = dwt_merc.ident_fis_jur
           AND doc_fis.ident_docto                  = dwt_merc.ident_docto
           AND doc_fis.num_docfis                   = dwt_merc.num_docfis
           AND doc_fis.serie_docfis                 = dwt_merc.serie_docfis
           AND doc_fis.sub_serie_docfis             = dwt_merc.sub_serie_docfis
           AND doc_fis.ident_modelo                 = x2024.ident_modelo
           AND x2024.cod_modelo IN ( '07'
                                   , '67' )
           AND dwt_merc.ident_proc_adj_princ        = x2058.ident_proc_adj(+)
           AND dwt_merc.ident_proc_adj_adic         = x2058_adic.ident_proc_adj(+)
           AND id_tipo_serv.cod_empresa             = doc_fis.cod_empresa
           AND id_tipo_serv.cod_estab               = doc_fis.cod_estab
           AND dwt_merc.ident_produto               = x2013.ident_produto
           AND id_tipo_serv.grupo_produto           = x2013.grupo_produto
           AND id_tipo_serv.cod_produto             = x2013.cod_produto
           AND id_tipo_serv.ind_produto             = x2013.ind_produto
           AND id_tipo_serv.cod_tipo_serv_esocial   = tipo_serv.cod_tipo_serv_esocial
           AND tipo_serv.data_ini_vigencia          = (SELECT MAX ( a.data_ini_vigencia )
                                                        FROM prt_tipo_serv_esocial a
                                                       WHERE a.cod_tipo_serv_esocial = tipo_serv.cod_tipo_serv_esocial
                                                        AND a.data_ini_vigencia <= p_data_final)
           AND doc_fis.dat_cancelamento IS NULL
           AND doc_fis.cod_class_doc_fis IN ( '1', '3' )
           AND doc_fis.norm_dev         = '1'
           AND ( ( doc_fis.movto_e_s    < '9'  AND p_entrada_saida = 'E' )
             OR ( doc_fis.movto_e_s     = '9'
             AND p_entrada_saida        = 'S' ) )
           AND NVL ( dwt_merc.vlr_inss_retido, 0 ) > 0
           AND doc_fis.situacao     = 'N'
           AND doc_fis.cod_empresa = p_cod_empresa
           AND doc_fis.cod_estab    = p_cod_estab
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
                        loga(p_cod_empresa||' - '||  p_cod_estab || ' - '||p_data_inicial|| ' - '||p_data_final||' - '||1 )  ;   
                           INSERT INTO msafi.reinf_conf_previdenciaria_tmp 
                                                  ( cod_empresa
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
                            
                            
                            
                            
                            
                            
        
        
                    BEGIN
                    loga('PREVIDENCIARIO: '||p_cod_empresa||' - '||  p_cod_estab || ' - '||p_data_inicial|| ' - '||p_data_final||' - '||2 )  ;   
                 -- =======================================
                 --    INSERT/SELCT  -- PREVIDENCIARIO
                 -- =======================================
                     INSERT INTO msafi.fin4816_reinf_prev_gtt
                       SELECT 
                       cod_empresa,             cod_estab,              data_emissao, 
                       data_fiscal,             ident_fis_jur,          ident_docto, 
                       num_docfis,              serie_docfis,           sub_serie_docfis, 
                       num_item,                cod_usuario,            tipo,  cod_fis_jur, 
                       x04_razao_social,        ind_fis_jur,            cpf_cgc, 
                       cod_class_doc_fis,       vlr_tot_nota,           vlr_base_inss, 
                       vlr_aliq_inss,           vlr_inss_retido,        vlr_contab_compl, 
                       ind_tipo_proc,           num_proc_jur,           razao_social, cgc, 
                       descricao,               cod_tipo_serv_esocial,  dsc_tipo_serv_esocial,   
                       empresa_razao_social,    vlr_servico,            num_proc_adj_adic, 
                       ind_tp_proc_adj_adic,    codigo_serv_prod,       desc_serv_prod
                     FROM (  SELECT 
                               'S' AS tipo
                                 , reinf.cod_empresa
                                 , reinf.cod_estab
                                 , reinf.ident_fis_jur
                                 , x04.cod_fis_jur
                                 , x04.razao_social x04_razao_social
                                 , x04.ind_fis_jur
                                 , x04.cpf_cgc
                                 , reinf.num_docfis
                                 , reinf.serie_docfis
                                 , reinf.sub_serie_docfis
                                 , reinf.num_item
                                 , reinf.data_emissao
                                 , reinf.data_fiscal
                                 , reinf.cod_class_doc_fis
                                 , reinf.vlr_tot_nota
                                 , reinf.vlr_base_inss
                                 , reinf.vlr_aliq_inss
                                 , reinf.vlr_inss_retido
                                 , reinf.vlr_contab_compl
                                 , reinf.ind_tipo_proc
                                 , reinf.num_proc_jur
                                 , estab.razao_social
                                 , estab.cgc
                                 , x2005.descricao
                                 , prt_tipo.cod_tipo_serv_esocial
                                 , prt_tipo.dsc_tipo_serv_esocial
                                 , empresa.razao_social empresa_razao_social
                                 , reinf.vlr_servico
                                 , reinf.num_proc_adj_adic
                                 , reinf.ind_tp_proc_adj_adic
                                 , x2018.cod_servico AS codigo_serv_prod
                                 , x2018.descricao AS desc_serv_prod
                                 , reinf.cod_usuario
                                 , reinf.ident_docto
                                FROM msafi.reinf_conf_previdenciaria_tmp reinf
                                 , x04_pessoa_fis_jur x04
                                 , estabelecimento estab
                                 , x2005_tipo_docto x2005
                                 , prt_tipo_serv_esocial prt_tipo
                                 , x2018_servicos x2018
                                 , empresa
                                WHERE reinf.ident_fis_jur               = x04.ident_fis_jur
                                   AND reinf.cod_empresa                = estab.cod_empresa
                                   AND reinf.cod_estab                  = estab.cod_estab
                                   AND reinf.ident_docto                = x2005.ident_docto
                                   AND reinf.ident_tipo_serv_esocial    = prt_tipo.ident_tipo_serv_esocial /*(+)*/
                                   AND reinf.cod_empresa                = empresa.cod_empresa
                                   AND LENGTH ( TRIM ( x04.cpf_cgc ) ) > 11
                                   AND reinf.cod_usuario                = mnm_usuario
                                   AND reinf.ident_servico              = x2018.ident_servico
                                   -- parametros 
                                   AND reinf.cod_empresa                = p_cod_empresa
                                   AND reinf.cod_estab                  = p_cod_estab
                                   AND reinf.data_emissao              >= p_data_inicial
                                   AND reinf.data_emissao              <= p_data_final
                                   --
                                  UNION
                                   --
                                SELECT 'R' AS tipo
                                     , reinf.cod_empresa
                                     , reinf.cod_estab
                                     , reinf.ident_fis_jur
                                     , x04.cod_fis_jur
                                     , x04.razao_social
                                     , x04.ind_fis_jur
                                     , x04.cpf_cgc
                                     , reinf.num_docfis
                                     , reinf.serie_docfis
                                     , reinf.sub_serie_docfis
                                     , reinf.num_item
                                     , reinf.data_emissao
                                     , reinf.data_fiscal
                                     , reinf.cod_class_doc_fis
                                     , reinf.vlr_tot_nota
                                     , reinf.vlr_base_inss
                                     , reinf.vlr_aliq_inss
                                     , reinf.vlr_inss_retido
                                     , reinf.vlr_contab_compl
                                     , reinf.ind_tipo_proc
                                     , reinf.num_proc_jur
                                     , estab.razao_social
                                     , estab.cgc
                                     , x2005.descricao
                                     , TO_CHAR ( reinf.cod_param, '000000000' )
                                     , prt_repasse.dsc_param
                                     , empresa.razao_social
                                     , reinf.vlr_servico
                                     , reinf.num_proc_adj_adic
                                     , reinf.ind_tp_proc_adj_adic
                                     , x2018.cod_servico AS codigo_serv_prod
                                     , x2018.descricao AS desc_serv_prod
                                     , reinf.cod_usuario
                                     , reinf.ident_docto
                                  FROM msafi.reinf_conf_previdenciaria_tmp reinf
                                     , x04_pessoa_fis_jur x04
                                     , estabelecimento estab
                                     , x2005_tipo_docto x2005
                                     , prt_par2_msaf prt_repasse
                                     , x2018_servicos x2018
                                     , empresa
                                 WHERE reinf.ident_fis_jur              = x04.ident_fis_jur
                                   AND reinf.cod_empresa                = estab.cod_empresa
                                   AND reinf.cod_estab                  = estab.cod_estab
                                   AND reinf.ident_docto                = x2005.ident_docto
                                   AND reinf.cod_param                  = prt_repasse.cod_param
                                   AND reinf.cod_empresa                = empresa.cod_empresa
                                   AND LENGTH ( TRIM ( x04.cpf_cgc ) ) > 11
                                   AND reinf.ident_servico              = x2018.ident_servico
                                   -- parametros 
                                   AND reinf.cod_usuario                = mnm_usuario
                                   AND reinf.cod_empresa                = p_cod_empresa
                                   AND reinf.cod_estab                  = p_cod_estab
                                   AND reinf.data_emissao              >= p_data_inicial
                                   AND reinf.data_emissao              <= p_data_final
                                   --
                                UNION
                                SELECT 'P' AS tipo
                                     , reinf.cod_empresa
                                     , reinf.cod_estab
                                     , reinf.ident_fis_jur
                                     , x04.cod_fis_jur
                                     , x04.razao_social
                                     , x04.ind_fis_jur
                                     , x04.cpf_cgc
                                     , reinf.num_docfis
                                     , reinf.serie_docfis
                                     , reinf.sub_serie_docfis
                                     , reinf.num_item
                                     , reinf.data_emissao
                                     , reinf.data_fiscal
                                     , reinf.cod_class_doc_fis
                                     , reinf.vlr_tot_nota
                                     , reinf.vlr_base_inss
                                     , reinf.vlr_aliq_inss
                                     , reinf.vlr_inss_retido
                                     , reinf.vlr_contab_compl
                                     , reinf.ind_tipo_proc
                                     , reinf.num_proc_jur
                                     , estab.razao_social
                                     , estab.cgc
                                     , x2005.descricao
                                     , prt_tipo.cod_tipo_serv_esocial
                                     , prt_tipo.dsc_tipo_serv_esocial
                                     , empresa.razao_social
                                     , reinf.vlr_servico
                                     , reinf.num_proc_adj_adic
                                     , reinf.ind_tp_proc_adj_adic
                                     , x2013.cod_produto AS codigo_serv_prod
                                     , x2013.descricao AS desc_serv_prod
                                     , reinf.cod_usuario
                                     , reinf.ident_docto
                                  FROM msafi.reinf_conf_previdenciaria_tmp reinf
                                     , x04_pessoa_fis_jur x04
                                     , estabelecimento estab
                                     , x2005_tipo_docto x2005
                                     , prt_tipo_serv_esocial prt_tipo
                                     , x2013_produto x2013
                                     , empresa
                                 WHERE reinf.ident_fis_jur              = x04.ident_fis_jur
                                   AND reinf.cod_empresa                = estab.cod_empresa
                                   AND reinf.cod_estab                  = estab.cod_estab
                                   AND reinf.ident_docto                = x2005.ident_docto
                                   AND reinf.ident_tipo_serv_esocial    = prt_tipo.ident_tipo_serv_esocial /*(+)*/
                                   AND reinf.cod_empresa                = empresa.cod_empresa
                                   AND LENGTH ( TRIM ( x04.cpf_cgc ) ) > 11
                                   AND reinf.cod_usuario                = mnm_usuario
                                   AND reinf.ident_produto              = x2013.ident_produto
                                   -- parametros 
                                   AND reinf.cod_usuario                = mnm_usuario
                                   AND reinf.cod_empresa                = p_cod_empresa
                                   AND reinf.cod_estab                  = p_cod_estab
                                   AND reinf.data_emissao              >= p_data_inicial
                                   AND reinf.data_emissao              <= p_data_final  )
                                   
                                        commit ;
                                    
                          EXCEPTION
                            WHEN DUP_VAL_ON_INDEX THEN
                               NULL;
                                WHEN OTHERS THEN
                                 p_status := -2;    
                                          
                    
                         END ;


                 -- =======================================
                 --  INSERT/SELECT  --  REINF2010
                 -- =======================================

                    BEGIN
                          loga('REINF2010: '||p_cod_empresa||' - '||  p_cod_estab || ' - '||p_data_inicial|| ' - '||p_data_final||' - '||3 )  ;           -- parametro
                                     
                       INSERT INTO msafi.fin4816_reinf_2010_gtt
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
                                   WHERE 1=1 
                                     AND reinf_pger_apur.id_pger_apur           = reinf_pger_r2010_tom.id_pger_apur
                                     AND reinf_pger_r2010_tom.id_r2010_tom      = reinf_pger_r2010_prest.id_r2010_tom
                                     AND reinf_pger_r2010_prest.id_r2010_prest  = reinf_pger_r2010_oc.id_r2010_prest
                                     AND reinf_pger_apur.cod_empresa            =  p_cod_empresa              -- parametro
                                     AND reinf_pger_apur.cod_estab              =  p_cod_estab                -- parametro
                                     AND reinf_pger_apur.dat_apur               >= p_data_inicial             -- parametro
                                     AND reinf_pger_apur.dat_apur               <= p_data_final               -- parametro
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
                                                                      AND x04.valid_fis_jur <= p_data_final)        -- parametro 
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
                           --
                           AND reinf_pger_apur.cod_empresa            =  p_cod_empresa              -- parametro
                           AND reinf_pger_apur.cod_estab              =  p_cod_estab                -- parametro
                           AND reinf_pger_apur.dat_apur               >= p_data_inicial             -- parametro
                           AND reinf_pger_apur.dat_apur               <= p_data_final               -- parametro
                           --                 
                           AND ( ( '' IS NOT NULL
                              AND reinf_pger_r2010_prest.cnpj_prestador = '' )
                             OR '' IS NULL )
                           AND ( reinf_pger_apur.ind_r2010 = 'S' )
                           --AND ( reinf_pger_apur.cod_versao = 'v1_04_00' )
                           AND reinf_pger_apur.ind_tp_amb = '2'
                           --AND rnf.num_docto = '000008508' ;
                           
                            ;               
            
                          EXCEPTION
                           WHEN DUP_VAL_ON_INDEX THEN
                            raise;
                           WHEN OTHERS THEN
                           p_status := -3;    
                             lib_proc.add_log('SQLERRM: ' || SQLERRM, 1);  
                           raise;
                   END ;

                    
         
      
        
        
        
        
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
        l_status  number;
    BEGIN
    
    
        -- Criação: Processo
        mproc_id :=
            lib_proc.new ( psp_nome => $$plsql_unit
                         , --  prows    => 48,
                           --  pcols    => 200,
                           pdescricao => v_descricao );

        COMMIT;

        p_task := 'PROC_EXCL_' || mproc_id;

        --EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT="DD/MM/YYYY"';
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

        --============================================
        --LIMPEZA DA TEMP QUANDO EXISTIREM REGISTROS MAIS ANTIGOS QUE 5 DIAS
        --============================================
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
            --    SELECT * FROM msafi.reinf_conf_previdenciaria_tmp ;
        
            DELETE from msafi.fin4816_report_fiscal_gtt;
            --DELETE from msafi.fin4816_prev_gtt;
            DELETE FROM msafi.fin4816_reinf_prev_gtt ;
            DELETE FROM msafi.fin4816_reinf_2010_gtt;
            
            
            
            --
            COMMIT;
              
         COMMIT;
        
        FOR v_estab IN pcod_estab.FIRST .. pcod_estab.last LOOP
            v_cont_estab := v_cont_estab + 1;

             prc_reinf_conf_retencao (  mcod_empresa,  pcod_estab ( v_estab ), '1',pdata_inicial,  pdata_final, mnm_usuario, 'E', mproc_id, l_status);
             loga (l_status);
             
         
            
             
            INSERT INTO msafi.fin4816_prev_tmp_estab
                 VALUES ( mproc_id
                        , pcod_estab ( v_estab )
                        , v_cont_estab
                        , SYSDATE );

            COMMIT;
            
            
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
                         AND reinf_pger_apur.cod_empresa IN ( mcod_empresa )               -- parametro  pdata_inicial,  pdata_final
                         AND reinf_pger_apur.cod_estab IN (  pcod_estab ( v_estab ) )              -- parametro
                         AND reinf_pger_apur.dat_apur >= pdata_inicial              -- parametro
                         AND reinf_pger_apur.dat_apur <= pdata_final                -- parametro
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
               
               AND reinf_pger_apur.cod_empresa IN ( mcod_empresa )           -- parametro  pdata_inicial,  pdata_final
               AND reinf_pger_apur.cod_estab IN (  pcod_estab ( v_estab ) )  -- parametro
               AND reinf_pger_apur.dat_apur >= pdata_inicial              -- parametro
               AND reinf_pger_apur.dat_apur <= pdata_final                -- parametro
              
                AND ( ( '' IS NOT NULL
                AND reinf_pger_r2010_prest.cnpj_prestador = '' )
                 OR '' IS NULL )
               AND ( reinf_pger_apur.ind_r2010 = 'S' )
               --AND ( reinf_pger_apur.cod_versao = 'v1_04_00' )
               AND reinf_pger_apur.ind_tp_amb = '2'
               --AND rnf.num_docto = '000008508' 
            
            ;
            
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
         --- 

        
  
       



        load_excel_analitico (mproc_id);


        loga ( '---FIM DO PROCESSAMENTO---', FALSE );

        lib_proc.close;
        RETURN mproc_id;
   
    END;

  
END dpsp_fin4816_prev_cproc;
/