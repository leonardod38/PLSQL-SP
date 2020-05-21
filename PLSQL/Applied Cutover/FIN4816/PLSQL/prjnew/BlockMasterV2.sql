

DECLARE
    p_data_inicial DATE             := '01/08/2018';  -- data  inicial emissao '01/07/2018'   AND  '30/07/2018'  DSP062
    p_data_final DATE               := '31/08/2018';  -- data  final  emissao
    p_cod_empresa VARCHAR2 ( 10 )   := 'DSP';
    p_cod_estab VARCHAR2 ( 10 )     := 'DSP004';
    pproc_id  number                := 1185500;
    
    idx NUMBER ( 10 )               := 0;
    v_sql VARCHAR2 ( 32767 );
    l_status  varchar2(10);
  
   --    select distinct * from msafi.tb_fin4816_rel_apoio_fiscalv5 
   
   --    select * from msafi.tb_fin4816_reinf_conf_prev_tmp
    
   TYPE typ_fin4816_rtf IS RECORD
    (
      "Codigo da Empresa"              VARCHAR2(3 BYTE),
      "Codigo do Estabelecimento"      VARCHAR2(6 BYTE),
      "Periodo de Emissão"             VARCHAR2(7 BYTE),
      "CNPJ Drogaria"                  VARCHAR2(14 BYTE),
      "Numero da Nota Fiscal"          VARCHAR2(12 BYTE),
      "Tipo de Documento"              VARCHAR2(5 BYTE),
      "Data Emissão"                   DATE,
      "CNPJ Fonecedor"                 VARCHAR2(50 BYTE),
      UF                               VARCHAR2(5 BYTE),
      "Valor Total da Nota"            NUMBER(17,2),
      "Base de Calculo INSS"           NUMBER(17,2),
      "Valor do INSS"                  NUMBER(17,2),
      "Codigo Pessoa Fisica/juridica"  VARCHAR2(14 BYTE),
      "Razão Social"                   VARCHAR2(120 BYTE),
      "Municipio Prestador"            VARCHAR2(50 BYTE),
      "Codigo de Serviço"              VARCHAR2(14 BYTE),
      "Codigo CEI"                     VARCHAR2(15 BYTE),
      DWT                              VARCHAR2(1 BYTE),
      --
      EMPRESA                          VARCHAR2(6 BYTE),
      "Codigo Estabelecimento"         VARCHAR2(6 BYTE),
      COD_PESSOA_FIS_JUR               VARCHAR2(14 BYTE),
      "Razão Social Cliente"           VARCHAR2(70 BYTE),
      "CNPJ Cliente"                   VARCHAR2(14 BYTE),
      "Nro. Nota Fiscal"               VARCHAR2(12 BYTE),
      "Dt. Emissao"                    DATE,
      "Dt. Fiscal"                     DATE,
      "Vlr. Total da Nota"             NUMBER,
      "Vlr Base Calc. Retenção"        NUMBER,
      "Vlr. Aliquota INSS"             NUMBER,
      "Vlr.Trib INSS RETIDO"           NUMBER,
      "Razão Social Drogaria"          VARCHAR2(70 BYTE),
      "CNPJ Drogarias"                 VARCHAR2(14 BYTE),
      "Descr. Tp. Documento"           VARCHAR2(5 BYTE),
      "Tp.Serv. E-social"              VARCHAR2(9 BYTE),
      "Descr. Tp. Serv E-social"       VARCHAR2(100 BYTE),
      "Vlr. do Servico"                NUMBER,
      "Cod. Serv. Mastersaf"           VARCHAR2(4 BYTE),
      "Descr. Serv. Mastersaf"         VARCHAR2(50 BYTE),
      --
      "Codigo Empresa"                 VARCHAR2(3 BYTE),
      "Razão Social Drogaria."         VARCHAR2(100 BYTE),
      "Razão Social Cliente."          VARCHAR2(70 BYTE),
      "Número da Nota Fiscal."         VARCHAR2(15 BYTE),
      "Data de Emissão da NF."         DATE,
      "Data Fiscal."                   DATE,
      "Valor do Tributo."              NUMBER,
      "Observação."                    VARCHAR2(250 BYTE),
      "Tipo de Serviço E-social."      VARCHAR2(40 BYTE),
      "Vlr. Base de Calc. Retenção."   NUMBER,
      "Valor da Retenção."             NUMBER
    );
    
    
    
      TYPE table_fin4816_rtf IS TABLE OF typ_fin4816_rtf
        INDEX BY PLS_INTEGER;

      t_fin4816_rtf table_fin4816_rtf;
    
    
  
               
        
        
        CURSOR cr_rtf 
        IS
        SELECT   x09_itens_serv.cod_empresa         AS cod_empresa          -- Codigo da Empresa
               , x09_itens_serv.cod_estab           AS cod_estab            -- Codigo do Estabelecimento
               , x09_itens_serv.data_fiscal         AS data_fiscal          -- Data Fiscal
               , x09_itens_serv.movto_e_s           AS movto_e_s
               , x09_itens_serv.norm_dev            AS norm_dev
               , x09_itens_serv.ident_docto         AS ident_docto
               , x09_itens_serv.ident_fis_jur       AS ident_fis_jur
               , x09_itens_serv.num_docfis          AS num_docfis
               , x09_itens_serv.serie_docfis        AS serie_docfis
               , x09_itens_serv.sub_serie_docfis    AS sub_serie_docfis
               , x09_itens_serv.ident_servico       AS ident_servico
               , x09_itens_serv.num_item            AS num_item
               , x07_docto_fiscal.data_emissao      AS perido_emissao       -- Periodo de Emissão
               , estabelecimento.cgc                AS cgc                  -- CNPJ Drogaria
               , x07_docto_fiscal.num_docfis        AS num_docto            -- Numero da Nota Fiscal
               , x2005_tipo_docto.cod_docto         AS tipo_docto           -- Tipo de Documento
               , x07_docto_fiscal.data_emissao      AS data_emissao         -- Data Emissão
               , x04_pessoa_fis_jur.cpf_cgc         AS cgc_fornecedor       -- CNPJ_Fonecedor
               , estado.cod_estado                  AS uf                   -- uf
               , x09_itens_serv.vlr_tot             AS valor_total          -- Valor Total da Nota
               , x09_itens_serv.vlr_base_inss       AS base_inss            -- Base de Calculo INSS
               , x09_itens_serv.vlr_inss_retido     AS valor_inss           -- Valor do INSS
               , x04_pessoa_fis_jur.cod_fis_jur     AS cod_fis_jur          -- Codigo Pessoa Fisica/juridica
               , x04_pessoa_fis_jur.razao_social    AS razao_social         -- Razão Social
               , municipio.descricao                AS municipio_prestador  -- Municipio Prestador
               , x2018_servicos.cod_servico         AS cod_servico          -- Codigo de Serviço
               , x07_docto_fiscal.cod_cei           AS cod_cei              -- Codigo CEI
               , NULL                               AS equalizacao          -- Equalização
            FROM x07_docto_fiscal
               , x2005_tipo_docto
               , x04_pessoa_fis_jur
               , x09_itens_serv
               , estabelecimento
               , estado
               , x2018_servicos
               , municipio
            --   , msafi.tb_fin4816_prev_tmp_estab estab
           WHERE 1 = 1
             AND x09_itens_serv.cod_empresa = estabelecimento.cod_empresa
             AND x09_itens_serv.cod_estab = estabelecimento.cod_estab
            -- AND x09_itens_serv.cod_estab = estab.cod_estab
             --AND estab.proc_id          = pproc_id
             AND x09_itens_serv.cod_empresa = x07_docto_fiscal.cod_empresa
             AND x09_itens_serv.cod_estab = x07_docto_fiscal.cod_estab
             AND x09_itens_serv.data_fiscal = x07_docto_fiscal.data_fiscal
             AND x07_docto_fiscal.data_emissao between   p_data_inicial  and p_data_final
             AND x09_itens_serv.vlr_inss_retido           >= 0
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
             AND ( x07_docto_fiscal.movto_e_s IN ( 1, 2, 3, 4, 5 ) )              AND ( ( x07_docto_fiscal.situacao <> 'S' )               OR ( x07_docto_fiscal.situacao IS NULL ) )
             AND ( x07_docto_fiscal.cod_estab = p_cod_estab ) --estab.cod_estab ) -- COD_ESTAB
             AND ( x07_docto_fiscal.cod_empresa = p_cod_empresa )
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
     


          r_fin4816_rel_apoio_fiscal  msafi.tb_fin4816_rel_apoio_fiscalV5%rowtype;  --  TARGET LOOP
          
          
          
          
               CURSOR rc_prev   
                 (  pcod_empresa        VARCHAR2   
                   ,pcod_estab          VARCHAR2
                   ,pdataemissao        DATE
                   ,pdata               DATE
                   ,pident_fisjur       NUMBER
                   ,pident_docto        NUMBER
                   ,pnum_docfis         VARCHAR2
                   ,pserie_docfis       VARCHAR2
                   ,psubseriesdocfis    VARCHAR2
                   ,pnum_item           NUMBER
                   ,pproc_id            NUMBER) 
                   IS
                 SELECT 'S'                                                     AS tipo
                     , reinf.cod_empresa                                        AS "Codigo Empresa"
                     , reinf.cod_estab                                          AS "Codigo Estabelecimento"
                     , reinf.data_emissao                                       AS "Data Emissão"
                     , reinf.data_fiscal                                        AS "Data Fiscal"
                     , reinf.ident_fis_jur                                      AS ident_fis_jur
                     , reinf.ident_docto                                        AS ident_docto
                     , reinf.num_docfis                                         AS "Número da Nota Fiscal"
                     , reinf.num_docfis || '/' || reinf.serie_docfis            AS "Docto/Série"
                     , reinf.data_emissao                                       AS "Emissão"
                     , reinf.serie_docfis                                       AS serie_docfis
                     , reinf.sub_serie_docfis                                   AS sub_serie_docfis
                     , reinf.num_item                                           AS num_item
                     , reinf.cod_usuario                                        AS cod_usuario
                     , x04.cod_fis_jur                                          AS "Codigo Pessoa Fisica/Juridica"
                     , INITCAP ( x04.razao_social )                             AS "Razão Social Cliente"
                     , x04.ind_fis_jur                                          AS ind_fis_jur
                     , x04.cpf_cgc                                              AS "CNPJ Cliente"                            
                     , reinf.cod_class_doc_fis                                  AS cod_class_doc_fis
                     , reinf.vlr_tot_nota                                       AS vlr_tot_nota
                     , reinf.vlr_base_inss                                      AS "Vlr Base Calc. Retenção"
                     , reinf.vlr_aliq_inss                                      AS vlr_aliq_inss
                     , reinf.vlr_inss_retido                                    AS "Vlr.Trib INSS RETIDO"
                     , reinf.vlr_inss_retido                                    AS "Valor da Retenção"
                     , reinf.vlr_contab_compl                                   AS vlr_contab_compl
                     , reinf.ind_tipo_proc                                      AS ind_tipo_proc
                     , reinf.num_proc_jur                                       AS num_proc_jur
                     , estab.razao_social                                       AS razao_social
                     , estab.cgc                                                AS cgc
                     , x2005.descricao                                          AS "Documento"
                     , prt_tipo.cod_tipo_serv_esocial                           AS "Tipo de Serviço E-social"
                     , prt_tipo.dsc_tipo_serv_esocial                           AS dsc_tipo_serv_esocial
                     , INITCAP ( empresa.razao_social )                         AS "Razão Social Drogaria"
                     , reinf.vlr_servico                                        AS "Valor do Servico"
                     , reinf.num_proc_adj_adic                                  AS num_proc_adj_adic
                     , reinf.ind_tp_proc_adj_adic                               AS ind_tp_proc_adj_adic
                     , x2018.cod_servico                                        AS codigo_serv_prod
                     , INITCAP ( x2018.descricao )                              AS desc_serv_prod
                     , x2005.cod_docto                                          AS cod_docto
                     , NULL                                                     AS "Observação"
                     , NULL                                                     AS dsc_param
                FROM   msafi.tb_fin4816_reinf_conf_prev_tmp reinf     
                     , msafi.tb_fin4816_prev_tmp_estab      estab1
                     , x04_pessoa_fis_jur                   x04
                     , estabelecimento                      estab
                     , x2005_tipo_docto                     x2005
                     , prt_tipo_serv_esocial                prt_tipo
                     , x2018_servicos                       x2018
                     , empresa
                 WHERE 1 = 1
                  AND reinf.cod_empresa                 = pcod_empresa             
                  AND reinf.cod_estab                   = pcod_estab          
                  AND reinf.data_emissao                = pdataemissao        
                  AND reinf.data_fiscal                 = pdata               
                  AND reinf.ident_fis_jur               = pident_fisjur       
                  AND reinf.ident_docto                 = pident_docto        
                  AND reinf.num_docfis                  = pnum_docfis                 
                  AND reinf.serie_docfis                = pserie_docfis       
                  AND reinf.sub_serie_docfis            = psubseriesdocfis    
                  AND reinf.num_item                    = pnum_item                 
                  AND pproc_id                          = pproc_id
                  --
                  AND reinf.ident_fis_jur               = x04.ident_fis_jur
                  AND reinf.cod_empresa                 = estab.cod_empresa
                  AND reinf.cod_estab                   = estab.cod_estab
                  AND reinf.ident_docto                 = x2005.ident_docto
                  AND reinf.ident_tipo_serv_esocial     = prt_tipo.ident_tipo_serv_esocial 
                  AND reinf.cod_empresa                 = empresa.cod_empresa                   
                  AND reinf.ident_servico               = x2018.ident_servico
                  AND LENGTH ( TRIM ( x04.cpf_cgc ) )  > 11;
   

         
         
       ---   finalizar 
        CURSOR  RC_REINF_EVENTO_E2010   (PCOD_EMPRESA  VARCHAR2, PCOD_ESTAB VARCHAR2 , pdta)
         IS 
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
         FROM (  
            SELECT
                reinf_pger_apur.dat_apur 
             ,  reinf_pger_apur.cod_empresa                         AS cod_empresa
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
                     AND reinf_pger_apur.cod_empresa            = pcod_empresa                -- parametro
                     AND reinf_pger_apur.dat_apur BETWEEN    p_data_inicial  AND  p_data_final -- parametro
                     AND reinf_pger_apur.ind_r2010 = 'S'
                 --    AND reinf_pger_apur.cod_versao >= 'v1_04_00'
                    AND reinf_pger_apur.ind_tp_amb <> '2'
                GROUP BY reinf_pger_r2010_prest.id_r2010_prest
                       , reinf_pger_r2010_tom.id_r2010_tom
                       , reinf_pger_apur.id_pger_apur) max_oc
             , msafi.tb_fin4816_prev_tmp_estab estab1
            -- select * from msafi.tb_fin4816_prev_tmp_estab estab1
         WHERE 1 = 1
           AND reinf_pger_apur.dat_apur BETWEEN     p_data_inicial  AND  p_data_final -- parametro
           AND estab1.cod_estab                         = estabelecimento.cod_estab
           AND estab1.proc_id                           = pproc_id     
           AND  estabelecimento.cod_estab               = pcod_estab  
           AND ( estabelecimento.cod_empresa            = reinf_pger_apur.cod_empresa )
           AND ( estabelecimento.cod_estab              = reinf_pger_apur.cod_estab )
           AND ( estabelecimento.cod_empresa            = empresa.cod_empresa )
           AND ( reinf_pger_r2010_prest.cnpj_prestador  = x04_pessoa_fis_jur.cpf_cgc )
           AND x04_pessoa_fis_jur.ident_fis_jur         = 
                                                        (SELECT MAX ( x04.ident_fis_jur )
                                                          FROM x04_pessoa_fis_jur x04
                                                         WHERE x04.cpf_cgc         = x04_pessoa_fis_jur.cpf_cgc
                                                         AND   x04.valid_fis_jur  <= p_data_final ) -- parametro
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
         
  ;                     
                         
    
        BEGIN
          delete msafi.tb_fin4816_rel_apoio_fiscalV5 ;
          delete msafi.tb_fin4816_reinf_conf_prev_tmp;      
          commit;
   


              --   select * from msafi.tb_fin4816_rel_apoio_fiscalv5 
              --   select * from msafi.tb_fin4816_reinf_conf_prev_tmp

 
                                                 
         
                                                       prc_reinf_conf_retencao( 
                                                              p_cod_empresa   => p_cod_empresa                  
                                                             ,p_cod_estab     => p_cod_estab                    
                                                             ,p_tipo_selec    => '1'                            
                                                             ,p_data_inicial  => p_data_inicial                 
                                                             ,p_data_final    => p_data_final                   
                                                             ,p_cod_usuario   => 'leonardo.b.lima'              
                                                             ,p_entrada_saida => 'E'                            
                                                             ,p_status        => l_status                       
                                                             ,p_procid       => pproc_id                         
                                                             );
        
 
                         for m in  cr_rtf  
                         loop
                              idx := idx + 1;
                              t_fin4816_rtf ( idx )."Codigo da Empresa"            := m.cod_empresa ;
                              t_fin4816_rtf ( idx )."Codigo do Estabelecimento"    := m.cod_estab;
                              t_fin4816_rtf ( idx )."Periodo de Emissão"           := to_char(m.data_emissao,'mm/yyyy');
                              t_fin4816_rtf ( idx )."CNPJ Drogaria"                := m.cgc;
                              t_fin4816_rtf ( idx )."Numero da Nota Fiscal"        := m.num_docto;
                              t_fin4816_rtf ( idx )."Tipo de Documento"            := m.tipo_docto;
                              t_fin4816_rtf ( idx )."Data Emissão"                 := m.data_emissao;
                              t_fin4816_rtf ( idx )."CNPJ Fonecedor"               := m.cgc_fornecedor;       
                              t_fin4816_rtf ( idx ).uf                             := m.uf;                   
                              t_fin4816_rtf ( idx )."Valor Total da Nota"          := m.valor_total;          
                              t_fin4816_rtf ( idx )."Base de Calculo INSS"         := m.base_inss  ;
                              t_fin4816_rtf ( idx )."Valor do INSS"                := m.valor_inss ;
                              t_fin4816_rtf ( idx )."Codigo Pessoa Fisica/juridica":= m.cod_fis_jur;
                              t_fin4816_rtf ( idx )."Razão Social"                 := m.razao_social;         
                              t_fin4816_rtf ( idx )."Municipio Prestador"          := m.municipio_prestador;  
                              t_fin4816_rtf ( idx )."Codigo de Serviço"            := m.cod_servico;          
                              t_fin4816_rtf ( idx )."Codigo CEI"                   := m.cod_cei;
                              
                          
              
                                                    
                                                              --  INSS  RETID0 
                                                            FOR n IN  rc_prev   
                                                               (  pcod_empresa     => m.cod_empresa     
                                                               ,  pcod_estab       => m.cod_estab                         
                                                               ,  pdataemissao     => m.data_emissao                     
                                                               ,  pdata            => m.data_fiscal                    
                                                               ,  pident_fisjur    => m.ident_fis_jur                    
                                                               ,  pident_docto     => m.ident_docto                  
                                                               ,  pnum_docfis      => m.num_docfis                       
                                                               ,  pserie_docfis    => m.serie_docfis
                                                               ,  psubseriesdocfis => m.sub_serie_docfis  
                                                               ,  pnum_item        => m.num_item
                                                               ,  pproc_id         => pproc_id   )  
                                                            LOOP
                                                                 t_fin4816_rtf ( idx ).DWT                         := 'S';                                              
                                                                 t_fin4816_rtf ( idx ).EMPRESA                     := n."Codigo Empresa";                              
                                                                 t_fin4816_rtf ( idx )."Codigo Estabelecimento"    := n."Codigo Estabelecimento";                          
                                                                 t_fin4816_rtf ( idx ).cod_pessoa_fis_jur          := n."Codigo Pessoa Fisica/Juridica";                   
                                                                 t_fin4816_rtf ( idx )."Razão Social Cliente"      := n."Razão Social Cliente";                            
                                                                 t_fin4816_rtf ( idx )."CNPJ Cliente"              := n."CNPJ Cliente";                                    
                                                                 t_fin4816_rtf ( idx )."Nro. Nota Fiscal"          := n."Número da Nota Fiscal";                           
                                                                 t_fin4816_rtf ( idx )."Dt. Emissao"               := n."Emissão";                                         
                                                                 t_fin4816_rtf ( idx )."Dt. Fiscal"                := n."Data Fiscal";                                     
                                                                 t_fin4816_rtf ( idx )."Vlr. Total da Nota"        := n.vlr_tot_nota;                                      
                                                                 t_fin4816_rtf ( idx )."Vlr Base Calc. Retenção"   := n."Vlr Base Calc. Retenção";                         
                                                                 t_fin4816_rtf ( idx )."Vlr. Aliquota INSS"        := n.vlr_aliq_inss  ;                                    
                                                                 t_fin4816_rtf ( idx )."Vlr.Trib INSS RETIDO"      := n."Vlr.Trib INSS RETIDO";                            
                                                                 t_fin4816_rtf ( idx )."Razão Social Drogaria"     := n."Razão Social Drogaria";                           
                                                                 t_fin4816_rtf ( idx )."CNPJ Drogarias"            := n.cgc;                                                  
                                                                 t_fin4816_rtf ( idx )."Descr. Tp. Documento"      := n.cod_docto;                                       
                                                                 t_fin4816_rtf ( idx )."Tp.Serv. E-social"         := n."Tipo de Serviço E-social";                                    
                                                                 t_fin4816_rtf ( idx )."Descr. Tp. Serv E-social"  := n.dsc_tipo_serv_esocial;                             
                                                                 t_fin4816_rtf ( idx )."Vlr. do Servico"           := n."Valor do Servico";                                
                                                                 t_fin4816_rtf ( idx )."Cod. Serv. Mastersaf"      := n.codigo_serv_prod;                                  
                                                                 t_fin4816_rtf ( idx )."Descr. Serv. Mastersaf"    := n.desc_serv_prod;                                
                                                            END LOOP;  
                                                            
                                                            IF   t_fin4816_rtf ( idx ).DWT IS NULL 
                                                            THEN t_fin4816_rtf ( idx ).DWT := 'N';                                                                                                         
                                                            END IF; 
                            
                                               --     SELECT  distinct * FROM msafi.tb_fin4816_rel_apoio_fiscalv5 
                                                                                                             
                                                INSERT INTO msafi.tb_fin4816_rel_apoio_fiscalv5 
                                                  VALUES t_fin4816_rtf ( idx );
                                                COMMIT;
       
                         END LOOP;
                         idx := 0;
    
        EXCEPTION
        WHEN OTHERS THEN
    dbms_output.put_line ( SQLERRM );
 END ;
   