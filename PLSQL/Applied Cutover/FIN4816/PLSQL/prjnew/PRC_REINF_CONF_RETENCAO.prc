   CREATE OR REPLACE PROCEDURE prc_reinf_conf_retencao ( p_cod_empresa IN VARCHAR2
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
                  INSERT INTO msafi.tb_fin4816_reinf_conf_prev_tmp ( cod_empresa
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