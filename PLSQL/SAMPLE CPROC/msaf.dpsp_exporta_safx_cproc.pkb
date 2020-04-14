Prompt Package Body DPSP_EXPORTA_SAFX_CPROC;
--
-- DPSP_EXPORTA_SAFX_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_exporta_safx_cproc
IS
    mnm_usuario usuario_estab.cod_usuario%TYPE;
    mcod_empresa estabelecimento.cod_empresa%TYPE;

    mproc_id INTEGER;
    mnm_tipo VARCHAR2 ( 100 ) := 'Backup de Documentos Fiscais';
    mnm_cproc VARCHAR2 ( 100 ) := 'Backup / Exclusão Dados (SAFX07/08)';
    mds_cproc VARCHAR2 ( 100 ) := 'Backup / Exclusão Dados (SAFX07/08)';

    v_dblink VARCHAR2 ( 30 );

    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 2000 );
    BEGIN
        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        mnm_usuario := lib_parametros.recuperar ( 'USUARIO' );

        lib_proc.add_param ( pstr
                           , 'Data Inicial'
                           , --P_DATA_INI
                            'DATE'
                           , 'TEXTBOX'
                           , 'S'
                           , NULL
                           , 'DD/MM/YYYY' );

        lib_proc.add_param ( pstr
                           , 'Data Final'
                           , --P_DATA_FIM
                            'DATE'
                           , 'TEXTBOX'
                           , 'S'
                           , NULL
                           , 'DD/MM/YYYY' );

        lib_proc.add_param (
                             pstr
                           , 'UF'
                           , --P_UF
                            'VARCHAR2'
                           , 'COMBOBOX'
                           , 'S'
                           , '%'
                           , '#########'
                           , 'SELECT A.COD_ESTADO, A.COD_ESTADO FROM ESTADO A UNION ALL SELECT ''%'', ''--TODAS--'' FROM DUAL ORDER BY 1'
        );

        lib_proc.add_param (
                             pstr
                           , 'NF Entrada/Saida'
                           , --p_movto_e_s
                            'VARCHAR2'
                           , 'COMBOBOX'
                           , 'S'
                           , NULL
                           , '1 - Entrada/Saida'
                           ,    ' SELECT ''1'',''1 - Entrada/Saida'' FROM DUAL '
                             || ' UNION SELECT ''2'',''2 - Saida'' FROM DUAL '
                             || ' UNION SELECT ''3'',''3 - Entrada'' FROM DUAL '
        );

        lib_proc.add_param ( pstr
                           , 'Chave Acesso'
                           , --p_chave_acesso
                            'VARCHAR2'
                           , 'TEXTBOX'
                           , 'N'
                           , NULL
                           , '00000000000000000000000000000000000000000000' );


        lib_proc.add_param ( pstr
                           , 'SAFX07'
                           , --p_safx07
                            'VARCHAR2'
                           , 'CHECKBOX'
                           , 'N'
                           , 'N'
                           , NULL );

        lib_proc.add_param ( pstr
                           , 'SAFX08'
                           , --p_safx08
                            'VARCHAR2'
                           , 'CHECKBOX'
                           , 'N'
                           , 'N'
                           , NULL );

        lib_proc.add_param (
                             pstr
                           ,    '                                   '
                             || '____________________________________________________'
                           , 'VARCHAR2'
                           , 'TEXT'
        );

        lib_proc.add_param ( pstr
                           , 'Excluir Documentos Fiscais (Apenas Origem Peoplesoft)'
                           , --p_delete
                            'VARCHAR2'
                           , 'CHECKBOX'
                           , 'N'
                           , 'N'
                           , NULL );

        lib_proc.add_param (
                             pstr
                           , 'Estabelecimentos'
                           , --p_cod_estab
                            'VARCHAR2'
                           , 'MULTISELECT'
                           , 'S'
                           , NULL
                           , NULL
                           ,    'SELECT A.COD_ESTAB, A.COD_ESTAB || '' - '' || B.COD_ESTADO || '' - '' || A.CGC || '' - '' || INITCAP(A.BAIRRO) || '' / '' || INITCAP(A.CIDADE) FROM ESTABELECIMENTO A, ESTADO B, MSAFI.DSP_ESTABELECIMENTO C WHERE A.COD_EMPRESA  = '''
                             || mcod_empresa
                             || ''' AND B.IDENT_ESTADO = A.IDENT_ESTADO AND A.COD_EMPRESA = C.COD_EMPRESA AND A.COD_ESTAB = C.COD_ESTAB AND B.COD_ESTADO LIKE :3 ORDER BY B.COD_ESTADO, A.COD_ESTAB'
        );

        RETURN pstr;
    END;

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN mnm_cproc;
    END;

    FUNCTION tipo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN mnm_tipo;
    END;

    FUNCTION versao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'VERSAO 1.0';
    END;

    FUNCTION descricao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN mds_cproc;
    END;

    FUNCTION modulo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'PROCESSOS CUSTOMIZADOS';
    END;

    FUNCTION classificacao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'PROCESSOS CUSTOMIZADOS';
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
    END;

    PROCEDURE safx07 ( p_data_ini DATE
                     , p_data_fim DATE
                     , p_movto_e_s VARCHAR2
                     , p_chave_acesso VARCHAR2
                     , p_cod_estab VARCHAR2 )
    IS
        -- REFERENCIA SAF_EXP_X07

        v_sql LONG;
        v_qtde INTEGER := 0;
        linha_w LONG;

        /* CONTADORES */
        ac_reg INTEGER := 0;

        /* VARIAVEIS DE TRATAMENTO DE ERRO */
        erro_leitura EXCEPTION;

        TYPE tcursor IS REF CURSOR;

        cmovto tcursor;
        rmovto x07_docto_fiscal%ROWTYPE;

        PROCEDURE opencursor ( p_cod_estab IN VARCHAR2
                             , p_dt_inic IN DATE
                             , p_dt_fim IN DATE
                             , p_chave_acesso IN VARCHAR2
                             , pcursor IN OUT tcursor )
        IS
        BEGIN
            OPEN pcursor FOR
                SELECT *
                  FROM x07_docto_fiscal
                 WHERE data_fiscal BETWEEN p_dt_inic AND p_dt_fim
                   AND cod_estab = p_cod_estab
                   AND cod_empresa = mcod_empresa
                   AND num_autentic_nfe = DECODE ( p_chave_acesso, NULL, num_autentic_nfe, p_chave_acesso )
                   AND movto_e_s = DECODE ( p_movto_e_s,  '1', movto_e_s,  '2', '9',  movto_e_s )
                   AND movto_e_s <> DECODE ( p_movto_e_s, '3', '9', '-1' );
        END;
    /* INICIO */
    BEGIN
        dbms_application_info.set_module ( $$plsql_unit || '-' || p_cod_estab
                                         , ' - SAFX07: ' || 'Inicio' );

        opencursor ( p_cod_estab
                   , p_data_ini
                   , p_data_fim
                   , p_chave_acesso
                   , cmovto );

        FETCH cmovto
            INTO rmovto;

        WHILE cmovto%FOUND LOOP
            linha_w :=
                pkg_formata_exportacao.x07 ( rmovto.cod_empresa
                                           , rmovto.cod_estab
                                           , rmovto.data_fiscal
                                           , rmovto.movto_e_s
                                           , rmovto.norm_dev
                                           , rmovto.ident_docto
                                           , rmovto.ident_fis_jur
                                           , rmovto.num_docfis
                                           , rmovto.serie_docfis
                                           , rmovto.sub_serie_docfis
                                           , rmovto.data_emissao
                                           , rmovto.cod_class_doc_fis
                                           , rmovto.ident_modelo
                                           , rmovto.ident_cfo
                                           , rmovto.ident_natureza_op
                                           , rmovto.num_docfis_ref
                                           , rmovto.serie_docfis_ref
                                           , rmovto.s_ser_docfis_ref
                                           , rmovto.num_dec_imp_ref
                                           , rmovto.data_saida_rec
                                           , rmovto.insc_estad_substit
                                           , rmovto.vlr_produto
                                           , rmovto.vlr_tot_nota
                                           , rmovto.vlr_frete
                                           , rmovto.vlr_seguro
                                           , rmovto.vlr_outras
                                           , rmovto.vlr_base_dif_frete
                                           , rmovto.vlr_desconto
                                           , rmovto.contrib_final
                                           , rmovto.situacao
                                           , rmovto.cod_indice
                                           , rmovto.vlr_nota_conv
                                           , rmovto.ident_conta
                                           , rmovto.ind_modelo_cupom
                                           , rmovto.num_processo
                                           , rmovto.ind_gravacao
                                           , rmovto.vlr_contab_compl
                                           , rmovto.num_controle_docto
                                           , rmovto.vlr_aliq_destino
                                           , rmovto.vlr_outros1
                                           , rmovto.vlr_outros2
                                           , rmovto.vlr_outros3
                                           , rmovto.vlr_outros4
                                           , rmovto.vlr_outros5
                                           , rmovto.vlr_aliq_outros1
                                           , rmovto.vlr_aliq_outros2
                                           , rmovto.ind_nf_especial
                                           , rmovto.ind_tp_frete
                                           , rmovto.cod_municipio
                                           , rmovto.ind_transf_cred
                                           , rmovto.dat_di
                                           , rmovto.vlr_tom_servico
                                           , rmovto.dat_escr_extemp
                                           , rmovto.cod_trib_int
                                           , rmovto.cod_regiao
                                           , rmovto.dat_autentic
                                           , rmovto.cod_canal_distrib
                                           , rmovto.vlr_icms_ndestac
                                           , rmovto.vlr_ipi_ndestac
                                           , rmovto.vlr_base_inss
                                           , rmovto.vlr_aliq_inss
                                           , rmovto.vlr_inss_retido
                                           , rmovto.vlr_mat_aplic_iss
                                           , rmovto.vlr_subempr_iss
                                           , rmovto.ind_munic_iss
                                           , rmovto.ind_classe_op_iss
                                           , rmovto.dat_fato_gerador
                                           , rmovto.dat_cancelamento
                                           , rmovto.num_pagina
                                           , rmovto.num_livro
                                           , rmovto.nro_aidf_nf
                                           , rmovto.dat_valid_doc_aidf
                                           , rmovto.ind_fatura
                                           , rmovto.ident_quitacao
                                           , rmovto.num_selo_cont_icms
                                           , rmovto.vlr_base_pis
                                           , rmovto.vlr_pis
                                           , rmovto.vlr_base_cofins
                                           , rmovto.vlr_cofins
                                           , rmovto.base_icms_origdest
                                           , rmovto.vlr_icms_origdest
                                           , rmovto.aliq_icms_origdest
                                           , rmovto.vlr_desc_condic
                                           , rmovto.perc_red_base_icms
                                           , rmovto.ident_fisjur_cpdir
                                           , rmovto.ind_medidajudicial
                                           , rmovto.ident_uf_orig_dest
                                           , rmovto.ind_compra_venda
                                           , rmovto.cod_tp_disp_seg
                                           , rmovto.num_ctr_disp
                                           , rmovto.num_fim_docto
                                           , rmovto.ident_uf_destino
                                           , rmovto.serie_ctr_disp
                                           , rmovto.sub_serie_ctr_disp
                                           , rmovto.ind_situacao_esp
                                           , rmovto.insc_estadual
                                           , rmovto.cod_pagto_inss
                                           , rmovto.dat_operacao
                                           , rmovto.usuario
                                           , rmovto.dat_intern_am
                                           , rmovto.ident_fisjur_lsg
                                           , rmovto.comprov_exp
                                           , rmovto.num_final_crt_disp
                                           , rmovto.num_alvara
                                           , rmovto.notifica_sefaz
                                           , rmovto.interna_suframa
                                           , rmovto.cod_amparo
                                           , rmovto.ident_estado_ampar
                                           , rmovto.ind_nota_servico
                                           , rmovto.cod_motivo
                                           , rmovto.obs_compl_motivo
                                           , rmovto.ind_tp_ret
                                           , rmovto.ind_tp_tomador
                                           , rmovto.cod_antec_st
                                           , rmovto.cnpj_armaz_orig
                                           , rmovto.ident_uf_armaz_orig
                                           , rmovto.ins_est_armaz_orig
                                           , rmovto.cnpj_armaz_dest
                                           , rmovto.ident_uf_armaz_dest
                                           , rmovto.ins_est_armaz_dest
                                           , rmovto.obs_inf_adic_nf
                                           , rmovto.vlr_base_inss_2
                                           , rmovto.vlr_aliq_inss_2
                                           , rmovto.vlr_inss_retido_2
                                           , rmovto.cod_pagto_inss_2
                                           , rmovto.vlr_base_pis_st
                                           , rmovto.vlr_aliq_pis_st
                                           , rmovto.vlr_pis_st
                                           , rmovto.vlr_base_cofins_st
                                           , rmovto.vlr_aliq_cofins_st
                                           , rmovto.vlr_cofins_st
                                           , rmovto.vlr_base_csll
                                           , rmovto.vlr_aliq_csll
                                           , rmovto.vlr_csll
                                           , rmovto.vlr_aliq_pis
                                           , rmovto.vlr_aliq_cofins
                                           , rmovto.base_icmss_substituido
                                           , rmovto.vlr_icmss_substituido
                                           , rmovto.ind_situacao_esp_st
                                           , rmovto.vlr_icmss_ndestac
                                           , rmovto.ind_docto_rec
                                           , rmovto.dat_pgto_gnre_darj
                                           , rmovto.cod_cei
                                           , rmovto.vlr_juros_inss
                                           , rmovto.vlr_multa_inss
                                           , rmovto.dt_pagto_nf
                                           , rmovto.ind_origem_info
                                           , rmovto.hora_saida
                                           , rmovto.cod_sit_docfis
                                           , rmovto.ident_observacao
                                           , rmovto.ident_situacao_a
                                           , rmovto.ident_situacao_b
                                           , rmovto.num_ciclo
                                           , rmovto.cod_municipio_orig
                                           , rmovto.cod_municipio_dest
                                           , rmovto.cod_cfps
                                           , rmovto.num_lancamento
                                           , rmovto.vlr_mat_prop
                                           , rmovto.vlr_mat_terc
                                           , rmovto.vlr_base_iss_retido
                                           , rmovto.vlr_iss_retido
                                           , rmovto.vlr_deducao_iss
                                           , rmovto.cod_munic_armaz_orig
                                           , rmovto.ins_munic_armaz_orig
                                           , rmovto.cod_munic_armaz_dest
                                           , rmovto.ins_munic_armaz_dest
                                           , rmovto.ident_classe_consumo
                                           , rmovto.ind_especif_receita
                                           , rmovto.num_contrato
                                           , rmovto.cod_area_terminal
                                           , rmovto.cod_tp_util
                                           , rmovto.grupo_tensao
                                           , rmovto.data_consumo_ini
                                           , rmovto.data_consumo_fim
                                           , rmovto.data_consumo_leit
                                           , rmovto.qtd_contratada_ponta
                                           , rmovto.qtd_contratada_fponta
                                           , rmovto.qtd_consumo_total
                                           , rmovto.ident_uf_consumo
                                           , rmovto.cod_munic_consumo
                                           , rmovto.cod_oper_esp_st
                                           , rmovto.ato_normativo
                                           , rmovto.num_ato_normativo
                                           , rmovto.ano_ato_normativo
                                           , rmovto.capitulacao_norma
                                           , rmovto.vlr_outras_entid
                                           , rmovto.vlr_terceiros
                                           , rmovto.ind_tp_compl_icms
                                           , rmovto.vlr_base_cide
                                           , rmovto.vlr_aliq_cide
                                           , rmovto.vlr_cide
                                           , rmovto.cod_verific_nfe
                                           , -- OS2286
                                            rmovto.cod_tp_rps_nfe
                                           , -- OS2286
                                            rmovto.num_rps_nfe
                                           , -- OS2286
                                            rmovto.serie_rps_nfe
                                           , -- OS2286
                                            rmovto.dat_emissao_rps_nfe
                                           , -- OS2286
                                            rmovto.dsc_servico_nfe
                                           , -- OS2286
                                            rmovto.num_autentic_nfe
                                           , -- OS2295
                                            rmovto.num_dv_nfe
                                           , -- CH33683
                                            rmovto.modelo_nf_dms
                                           , -- OS 2313
                                            rmovto.cod_modelo_cotepe
                                           , --OS2354
                                            rmovto.vlr_comissao
                                           , rmovto.ind_nfe_deneg_inut
                                           , rmovto.ind_nf_reg_especial
                                           , rmovto.vlr_abat_ntributado
                                           , rmovto.vlr_outros_icms
                                           , --OS2409
                                            rmovto.hora_emissao
                                           , -- OS2466-A
                                            rmovto.obs_dados_fatura
                                           , -- OS2466-A
                                            rmovto.ident_fis_conces
                                           , -- OS2388-Pdw
                                            rmovto.cod_autentic
                                           , --OS2609-A
                                            rmovto.ind_port_cat44
                                           , --OS2609-A
                                            rmovto.vlr_base_inss_rural
                                           , --OS2388-B2
                                            rmovto.vlr_aliq_inss_rural
                                           , --OS2388-B2
                                            rmovto.vlr_inss_rural
                                           , --OS2388-B2
                                            rmovto.ident_classe_consumo_sef_pe
                                           , --OS3132
                                            rmovto.vlr_pis_retido
                                           , -- 3169-DW1
                                            rmovto.vlr_cofins_retido
                                           , -- 3169-DW1
                                            rmovto.dat_lanc_pis_cofins
                                           , -- 3169-DW1
                                            rmovto.ind_pis_cofins_extemp
                                           , -- 3169-DW1
                                            rmovto.cod_sit_pis
                                           , -- 3169-DW1
                                            rmovto.cod_sit_cofins
                                           , -- 3169-DW1
                                            rmovto.ind_nat_frete
                                           , rmovto.cod_nat_rec
                                           , -- 3169-DW11,
                                            rmovto.ind_venda_canc
                                           , -- 3169-ge13,
                                            rmovto.ind_nat_base_cred
                                           , -- 3169-GE13B
                                            rmovto.ind_nf_contingencia
                                           , rmovto.vlr_acrescimo
                                           , rmovto.vlr_antecip_trib
                                           , rmovto.dsc_reservado1
                                           , --3521
                                            rmovto.dsc_reservado2
                                           , --3521
                                            rmovto.dsc_reservado3
                                           , --3521
                                            rmovto.num_nfts
                                           , rmovto.ind_nf_venda_terceiros
                                           , rmovto.dsc_reservado4
                                           , rmovto.dsc_reservado5
                                           , rmovto.dsc_reservado6
                                           , rmovto.dsc_reservado7
                                           , rmovto.dsc_reservado8
                                           , rmovto.identif_docfis
                                           , --OS3743
                                            rmovto.cod_sistema_orig
                                           , --OS3743
                                            rmovto.ident_scp
                                           , --OS4316
                                            rmovto.ind_prest_serv
                                           , -- OS4514
                                            rmovto.ind_tipo_proc
                                           , -- OS4514
                                            rmovto.num_proc_jur
                                           , -- OS4514
                                            rmovto.ind_dec_proc
                                           , -- OS4514
                                            rmovto.ind_tipo_aquis
                                           , -- OS4514
                                            rmovto.vlr_desc_gilrat
                                           , -- OS4514
                                            rmovto.vlr_desc_senar
                                           , -- OS4514
                                            rmovto.cnpj_subempreiteiro
                                           , rmovto.cnpj_cpf_proprietario_cno
                                           , rmovto.vlr_ret_subempreitado
                                           , rmovto.num_docfis_serv -- OS 3341
                                           , rmovto.vlr_fcp_uf_dest -- MFS2101
                                           , rmovto.vlr_icms_uf_dest -- MFS2101
                                           , rmovto.vlr_icms_uf_orig -- MFS2101
                                           , rmovto.vlr_contrib_prev --MFS2967
                                           , rmovto.vlr_gilrat --MFS2967
                                           , rmovto.vlr_contrib_senar --MFS2967
                                           , rmovto.cpf_cnpj --MFS11800
                                           , rmovto.num_certif_qual --mfs13120
                                           , rmovto.obs_reinf --mfs14129
                                           , rmovto.vlr_tot_adic
                                           , rmovto.vlr_ret_serv
                                           , rmovto.vlr_serv_15
                                           , rmovto.vlr_serv_20
                                           , rmovto.vlr_serv_25
                                           , rmovto.vlr_ipi_dev --MFS20985
                                           , rmovto.vlr_sest
                                           , rmovto.vlr_senat );
            v_sql := '';
            v_sql := v_sql || ' INSERT INTO msafi.DPSP_SAFX07_BKP ';
            v_sql := v_sql || ' ( 			                    ';
            v_sql := v_sql || 'COD_EMPRESA                      ,';
            v_sql := v_sql || 'COD_ESTAB                        ,';
            v_sql := v_sql || 'MOVTO_E_S                        ,';
            v_sql := v_sql || 'NORM_DEV                         ,';
            v_sql := v_sql || 'COD_DOCTO                        ,';
            v_sql := v_sql || 'IDENT_FIS_JUR                    ,';
            v_sql := v_sql || 'COD_FIS_JUR                      ,';
            v_sql := v_sql || 'NUM_DOCFIS                       ,';
            v_sql := v_sql || 'SERIE_DOCFIS                     ,';
            v_sql := v_sql || 'SUB_SERIE_DOCFIS                 ,';
            v_sql := v_sql || 'DATA_EMISSAO                     ,';
            v_sql := v_sql || 'COD_CLASS_DOC_FIS                ,';
            v_sql := v_sql || 'COD_MODELO                       ,';
            v_sql := v_sql || 'COD_CFO                          ,';
            v_sql := v_sql || 'COD_NATUREZA_OP                  ,';
            v_sql := v_sql || 'NUM_DOCFIS_REF                   ,';
            v_sql := v_sql || 'SERIE_DOCFIS_REF                 ,';
            v_sql := v_sql || 'S_SER_DOCFIS_REF                 ,';
            v_sql := v_sql || 'NUM_DEC_IMP_REF                  ,';
            v_sql := v_sql || 'DATA_SAIDA_REC                   ,';
            v_sql := v_sql || 'INSC_ESTAD_SUBSTIT               ,';
            v_sql := v_sql || 'VLR_PRODUTO                      ,';
            v_sql := v_sql || 'VLR_TOT_NOTA                     ,';
            v_sql := v_sql || 'VLR_FRETE                        ,';
            v_sql := v_sql || 'VLR_SEGURO                       ,';
            v_sql := v_sql || 'VLR_OUTRAS                       ,';
            v_sql := v_sql || 'VLR_BASE_DIF_FRETE               ,';
            v_sql := v_sql || 'VLR_DESCONTO                     ,';
            v_sql := v_sql || 'CONTRIB_FINAL                    ,';
            v_sql := v_sql || 'SITUACAO                         ,';
            v_sql := v_sql || 'COD_INDICE                       ,';
            v_sql := v_sql || 'VLR_NOTA_CONV                    ,';
            v_sql := v_sql || 'COD_CONTA                        ,';
            v_sql := v_sql || 'VLR_ALIQ_ICMS                    ,';
            v_sql := v_sql || 'VLR_ICMS                         ,';
            v_sql := v_sql || 'DIF_ALIQ_ICMS                    ,';
            v_sql := v_sql || 'OBS_ICMS                         ,';
            v_sql := v_sql || 'COD_APUR_ICMS                    ,';
            v_sql := v_sql || 'VLR_ALIQ_IPI                     ,';
            v_sql := v_sql || 'VLR_IPI                          ,';
            v_sql := v_sql || 'OBS_IPI                          ,';
            v_sql := v_sql || 'COD_APUR_IPI                     ,';
            v_sql := v_sql || 'VLR_ALIQ_IR                      ,';
            v_sql := v_sql || 'VLR_IR                           ,';
            v_sql := v_sql || 'VLR_ALIQ_ISS                     ,';
            v_sql := v_sql || 'VLR_ISS                          ,';
            v_sql := v_sql || 'VLR_ALIQ_SUB_ICMS                ,';
            v_sql := v_sql || 'VLR_SUBST_ICMS                   ,';
            v_sql := v_sql || 'OBS_SUBST_ICMS                   ,';
            v_sql := v_sql || 'COD_APUR_SUB_ICMS                ,';
            v_sql := v_sql || 'BASE_TRIB_ICMS                   ,';
            v_sql := v_sql || 'BASE_ISEN_ICMS                   ,';
            v_sql := v_sql || 'BASE_OUTR_ICMS                   ,';
            v_sql := v_sql || 'BASE_REDU_ICMS                   ,';
            v_sql := v_sql || 'BASE_TRIB_IPI                    ,';
            v_sql := v_sql || 'BASE_ISEN_IPI                    ,';
            v_sql := v_sql || 'BASE_OUTR_IPI                    ,';
            v_sql := v_sql || 'BASE_REDU_IPI                    ,';
            v_sql := v_sql || 'BASE_TRIB_IR                     ,';
            v_sql := v_sql || 'BASE_ISEN_IR                     ,';
            v_sql := v_sql || 'BASE_TRIB_ISS                    ,';
            v_sql := v_sql || 'BASE_ISEN_ISS                    ,';
            v_sql := v_sql || 'BASE_REAL_TERC_ISS               ,';
            v_sql := v_sql || 'BASE_SUB_TRIB_ICMS               ,';
            v_sql := v_sql || 'NUM_MAQ_REG                      ,';
            v_sql := v_sql || 'NUM_CUPON_FISC                   ,';
            v_sql := v_sql || 'IND_MODELO_CUPOM                 ,';
            v_sql := v_sql || 'VLR_CONTAB_COMPL                 ,';
            v_sql := v_sql || 'NUM_CONTROLE_DOCTO               ,';
            v_sql := v_sql || 'VLR_ALIQ_DESTINO                 ,';
            v_sql := v_sql || 'IND_NF_ESPECIAL                  ,';
            v_sql := v_sql || 'IND_TP_FRETE                     ,';
            v_sql := v_sql || 'COD_MUNICIPIO                    ,';
            v_sql := v_sql || 'IND_TRANSF_CRED                  ,';
            v_sql := v_sql || 'DAT_DI                           ,';
            v_sql := v_sql || 'VLR_TOM_SERVICO                  ,';
            v_sql := v_sql || 'DAT_ESCR_EXTEMP                  ,';
            v_sql := v_sql || 'COD_TRIB_INT                     ,';
            v_sql := v_sql || 'COD_REGIAO                       ,';
            v_sql := v_sql || 'DAT_AUTENTIC                     ,';
            v_sql := v_sql || 'COD_CANAL_DISTRIB                ,';
            v_sql := v_sql || 'IND_CRED_ICMSS                   ,';
            v_sql := v_sql || 'VLR_ICMS_NDESTAC                 ,';
            v_sql := v_sql || 'VLR_IPI_NDESTAC                  ,';
            v_sql := v_sql || 'VLR_BASE_INSS                    ,';
            v_sql := v_sql || 'VLR_ALIQ_INSS                    ,';
            v_sql := v_sql || 'VLR_INSS_RETIDO                  ,';
            v_sql := v_sql || 'VLR_MAT_APLIC_ISS                ,';
            v_sql := v_sql || 'VLR_SUBEMPR_ISS                  ,';
            v_sql := v_sql || 'IND_MUNIC_ISS                    ,';
            v_sql := v_sql || 'IND_CLASSE_OP_ISS                ,';
            v_sql := v_sql || 'VLR_OUTROS1                      ,';
            v_sql := v_sql || 'DAT_FATO_GERADOR                 ,';
            v_sql := v_sql || 'DAT_CANCELAMENTO                 ,';
            v_sql := v_sql || 'NUM_PAGINA                       ,';
            v_sql := v_sql || 'NUM_LIVRO                        ,';
            v_sql := v_sql || 'NRO_AIDF_NF                      ,';
            v_sql := v_sql || 'DAT_VALID_DOC_AIDF               ,';
            v_sql := v_sql || 'IND_FATURA                       ,';
            v_sql := v_sql || 'COD_QUITACAO                     ,';
            v_sql := v_sql || 'NUM_SELO_CONT_ICMS               ,';
            v_sql := v_sql || 'VLR_BASE_PIS                     ,';
            v_sql := v_sql || 'VLR_PIS                          ,';
            v_sql := v_sql || 'VLR_BASE_COFINS                  ,';
            v_sql := v_sql || 'VLR_COFINS                       ,';
            v_sql := v_sql || 'BASE_ICMS_ORIGDEST               ,';
            v_sql := v_sql || 'VLR_ICMS_ORIGDEST                ,';
            v_sql := v_sql || 'ALIQ_ICMS_ORIGDEST               ,';
            v_sql := v_sql || 'VLR_DESC_CONDIC                  ,';
            v_sql := v_sql || 'VLR_BASE_ISE_ICMSS               ,';
            v_sql := v_sql || 'VLR_BASE_OUT_ICMSS               ,';
            v_sql := v_sql || 'VLR_RED_BASE_ICMSS               ,';
            v_sql := v_sql || 'PERC_RED_BASE_ICMS               ,';
            v_sql := v_sql || 'IND_FISJUR_CPDIR                 ,';
            v_sql := v_sql || 'COD_FISJUR_CPDIR                 ,';
            v_sql := v_sql || 'IND_MEDIDAJUDICIAL               ,';
            v_sql := v_sql || 'UF_ORIG_DEST                     ,';
            v_sql := v_sql || 'IND_COMPRA_VENDA                 ,';
            v_sql := v_sql || 'COD_TP_DISP_SEG                  ,';
            v_sql := v_sql || 'NUM_CTR_DISP                     ,';
            v_sql := v_sql || 'NUM_FIM_DOCTO                    ,';
            v_sql := v_sql || 'UF_DESTINO                       ,';
            v_sql := v_sql || 'SERIE_CTR_DISP                   ,';
            v_sql := v_sql || 'SUB_SERIE_CTR_DISP               ,';
            v_sql := v_sql || 'IND_SITUACAO_ESP                 ,';
            v_sql := v_sql || 'INSC_ESTADUAL                    ,';
            v_sql := v_sql || 'COD_PAGTO_INSS                   ,';
            v_sql := v_sql || 'DAT_INTERN_AM                    ,';
            v_sql := v_sql || 'IND_FISJUR_LSG                   ,';
            v_sql := v_sql || 'COD_FISJUR_LSG                   ,';
            v_sql := v_sql || 'COMPROV_EXP                      ,';
            v_sql := v_sql || 'NUM_FINAL_CRT_DISP               ,';
            v_sql := v_sql || 'NUM_ALVARA                       ,';
            v_sql := v_sql || 'NOTIFICA_SEFAZ                   ,';
            v_sql := v_sql || 'INTERNA_SUFRAMA                  ,';
            v_sql := v_sql || 'COD_AMPARO                       ,';
            v_sql := v_sql || 'IND_NOTA_SERVICO                 ,';
            v_sql := v_sql || 'COD_MOTIVO                       ,';
            v_sql := v_sql || 'UF_AMPARO_LEGAL                  ,';
            v_sql := v_sql || 'OBS_COMPL_MOTIVO                 ,';
            v_sql := v_sql || 'IND_TP_RET                       ,';
            v_sql := v_sql || 'IND_TP_TOMADOR                   ,';
            v_sql := v_sql || 'COD_ANTEC_ST                     ,';
            v_sql := v_sql || 'CNPJ_ARMAZ_ORIG                  ,';
            v_sql := v_sql || 'UF_ARMAZ_ORIG                    ,';
            v_sql := v_sql || 'INS_EST_ARMAZ_ORIG               ,';
            v_sql := v_sql || 'CNPJ_ARMAZ_DEST                  ,';
            v_sql := v_sql || 'UF_ARMAZ_DEST                    ,';
            v_sql := v_sql || 'INS_EST_ARMAZ_DEST               ,';
            v_sql := v_sql || 'OBS_INF_ADIC_NF                  ,';
            v_sql := v_sql || 'VLR_BASE_INSS_2                  ,';
            v_sql := v_sql || 'VLR_ALIQ_INSS_2                  ,';
            v_sql := v_sql || 'VLR_INSS_RETIDO_2                ,';
            v_sql := v_sql || 'COD_PAGTO_INSS_2                 ,';
            v_sql := v_sql || 'VLR_BASE_PIS_ST                  ,';
            v_sql := v_sql || 'VLR_ALIQ_PIS_ST                  ,';
            v_sql := v_sql || 'VLR_PIS_ST                       ,';
            v_sql := v_sql || 'VLR_BASE_COFINS_ST               ,';
            v_sql := v_sql || 'VLR_ALIQ_COFINS_ST               ,';
            v_sql := v_sql || 'VLR_COFINS_ST                    ,';
            v_sql := v_sql || 'VLR_BASE_CSLL                    ,';
            v_sql := v_sql || 'VLR_ALIQ_CSLL                    ,';
            v_sql := v_sql || 'VLR_CSLL                         ,';
            v_sql := v_sql || 'VLR_ALIQ_PIS                     ,';
            v_sql := v_sql || 'VLR_ALIQ_COFINS                  ,';
            v_sql := v_sql || 'BASE_ICMSS_SUBSTITUIDO           ,';
            v_sql := v_sql || 'VLR_ICMSS_SUBSTITUIDO            ,';
            v_sql := v_sql || 'IND_SITUACAO_ESP_ST              ,';
            v_sql := v_sql || 'VLR_ICMSS_NDESTAC                ,';
            v_sql := v_sql || 'IND_DOCTO_REC                    ,';
            v_sql := v_sql || 'DAT_PGTO_GNRE_DARJ               ,';
            v_sql := v_sql || 'COD_CEI                          ,';
            v_sql := v_sql || 'VLR_JUROS_INSS                   ,';
            v_sql := v_sql || 'VLR_MULTA_INSS                   ,';
            v_sql := v_sql || 'DT_PAGTO_NF                      ,';
            v_sql := v_sql || 'HORA_SAIDA                       ,';
            v_sql := v_sql || 'COD_SIT_DOCFIS                   ,';
            v_sql := v_sql || 'COD_OBSERVACAO                   ,';
            v_sql := v_sql || 'COD_SITUACAO_A                   ,';
            v_sql := v_sql || 'COD_SITUACAO_B                   ,';
            v_sql := v_sql || 'NUM_CONT_REDUC                   ,';
            v_sql := v_sql || 'COD_MUNICIPIO_ORIG               ,';
            v_sql := v_sql || 'COD_MUNICIPIO_DEST               ,';
            v_sql := v_sql || 'COD_CFPS                         ,';
            v_sql := v_sql || 'NUM_LANCAMENTO                   ,';
            v_sql := v_sql || 'VLR_MAT_PROP                     ,';
            v_sql := v_sql || 'VLR_MAT_TERC                     ,';
            v_sql := v_sql || 'VLR_BASE_ISS_RETIDO              ,';
            v_sql := v_sql || 'VLR_ISS_RETIDO                   ,';
            v_sql := v_sql || 'VLR_DEDUCAO_ISS                  ,';
            v_sql := v_sql || 'COD_MUNIC_ARMAZ_ORIG             ,';
            v_sql := v_sql || 'INS_MUNIC_ARMAZ_ORIG             ,';
            v_sql := v_sql || 'COD_MUNIC_ARMAZ_DEST             ,';
            v_sql := v_sql || 'INS_MUNIC_ARMAZ_DEST             ,';
            v_sql := v_sql || 'COD_CLASSE_CONSUMO               ,';
            v_sql := v_sql || 'IND_ESPECIF_RECEITA              ,';
            v_sql := v_sql || 'NUM_CONTRATO                     ,';
            v_sql := v_sql || 'COD_AREA_TERMINAL                ,';
            v_sql := v_sql || 'COD_TP_UTIL                      ,';
            v_sql := v_sql || 'GRUPO_TENSAO                     ,';
            v_sql := v_sql || 'DATA_CONSUMO_INI                 ,';
            v_sql := v_sql || 'DATA_CONSUMO_FIM                 ,';
            v_sql := v_sql || 'DATA_CONSUMO_LEIT                ,';
            v_sql := v_sql || 'QTD_CONTRATADA_PONTA             ,';
            v_sql := v_sql || 'QTD_CONTRATADA_FPONTA            ,';
            v_sql := v_sql || 'QTD_CONSUMO_TOTAL                ,';
            v_sql := v_sql || 'UF_CONSUMO                       ,';
            v_sql := v_sql || 'COD_MUNIC_CONSUMO                ,';
            v_sql := v_sql || 'COD_OPER_ESP_ST                  ,';
            v_sql := v_sql || 'ATO_NORMATIVO                    ,';
            v_sql := v_sql || 'NUM_ATO_NORMATIVO                ,';
            v_sql := v_sql || 'ANO_ATO_NORMATIVO                ,';
            v_sql := v_sql || 'CAPITULACAO_NORMA                ,';
            v_sql := v_sql || 'VLR_OUTRAS_ENTID                 ,';
            v_sql := v_sql || 'VLR_TERCEIROS                    ,';
            v_sql := v_sql || 'IND_TP_COMPL_ICMS                ,';
            v_sql := v_sql || 'VLR_BASE_CIDE                    ,';
            v_sql := v_sql || 'VLR_ALIQ_CIDE                    ,';
            v_sql := v_sql || 'VLR_CIDE                         ,';
            v_sql := v_sql || 'COD_VERIFIC_NFE                  ,';
            v_sql := v_sql || 'COD_TP_RPS_NFE                   ,';
            v_sql := v_sql || 'NUM_RPS_NFE                      ,';
            v_sql := v_sql || 'SERIE_RPS_NFE                    ,';
            v_sql := v_sql || 'DAT_EMISSAO_RPS_NFE              ,';
            v_sql := v_sql || 'DSC_SERVICO_NFE                  ,';
            v_sql := v_sql || 'NUM_AUTENTIC_NFE                 ,';
            v_sql := v_sql || 'NUM_DV_NFE                       ,';
            v_sql := v_sql || 'MODELO_NF_DMS                    ,';
            v_sql := v_sql || 'COD_MODELO_COTEPE                ,';
            v_sql := v_sql || 'VLR_COMISSAO                     ,';
            v_sql := v_sql || 'IND_NFE_DENEG_INUT               ,';
            v_sql := v_sql || 'IND_NF_REG_ESPECIAL              ,';
            v_sql := v_sql || 'VLR_ABAT_NTRIBUTADO              ,';
            v_sql := v_sql || 'VLR_OUTROS_ICMS                  ,';
            v_sql := v_sql || 'HORA_EMISSAO                     ,';
            v_sql := v_sql || 'OBS_DADOS_FATURA                 ,';
            v_sql := v_sql || 'IND_FIS_CONCES                   ,';
            v_sql := v_sql || 'COD_FIS_CONCES                   ,';
            v_sql := v_sql || 'COD_AUTENTIC                     ,';
            v_sql := v_sql || 'IND_PORT_CAT44                   ,';
            v_sql := v_sql || 'VLR_BASE_INSS_RURAL              ,';
            v_sql := v_sql || 'VLR_ALIQ_INSS_RURAL              ,';
            v_sql := v_sql || 'VLR_INSS_RURAL                   ,';
            v_sql := v_sql || 'COD_CLASSE_CONSUMO_SEF_PE        ,';
            v_sql := v_sql || 'VLR_PIS_RETIDO                   ,';
            v_sql := v_sql || 'VLR_COFINS_RETIDO                ,';
            v_sql := v_sql || 'DAT_LANC_PIS_COFINS              ,';
            v_sql := v_sql || 'IND_PIS_COFINS_EXTEMP            ,';
            v_sql := v_sql || 'COD_SIT_PIS                      ,';
            v_sql := v_sql || 'COD_SIT_COFINS                   ,';
            v_sql := v_sql || 'IND_NAT_FRETE                    ,';
            v_sql := v_sql || 'COD_NAT_REC                      ,';
            v_sql := v_sql || 'IND_VENDA_CANC                   ,';
            v_sql := v_sql || 'IND_NAT_BASE_CRED                ,';
            v_sql := v_sql || 'IND_NF_CONTINGENCIA              ,';
            v_sql := v_sql || 'VLR_ACRESCIMO                    ,';
            v_sql := v_sql || 'VLR_ANTECIP_TRIB                 ,';
            v_sql := v_sql || 'IND_IPI_NDESTAC_DF               ,';
            v_sql := v_sql || 'DSC_RESERVADO1                   ,';
            v_sql := v_sql || 'DSC_RESERVADO2                   ,';
            v_sql := v_sql || 'DSC_RESERVADO3                   ,';
            v_sql := v_sql || 'NUM_NFTS                         ,';
            v_sql := v_sql || 'IND_NF_VENDA_TERCEIROS           ,';
            v_sql := v_sql || 'DSC_RESERVADO4                   ,';
            v_sql := v_sql || 'DSC_RESERVADO5                   ,';
            v_sql := v_sql || 'DSC_RESERVADO6                   ,';
            v_sql := v_sql || 'DSC_RESERVADO7                   ,';
            v_sql := v_sql || 'DSC_RESERVADO8                   ,';
            v_sql := v_sql || 'IDENTIF_DOCFIS                   ,';
            v_sql := v_sql || 'COD_SISTEMA_ORIG                 ,';
            v_sql := v_sql || 'COD_SCP                          ,';
            v_sql := v_sql || 'IND_PREST_SERV                   ,';
            v_sql := v_sql || 'IND_TIPO_PROC                    ,';
            v_sql := v_sql || 'NUM_PROC_JUR                     ,';
            v_sql := v_sql || 'IND_DEC_PROC                     ,';
            v_sql := v_sql || 'IND_TIPO_AQUIS                   ,';
            v_sql := v_sql || 'VLR_DESC_GILRAT                  ,';
            v_sql := v_sql || 'VLR_DESC_SENAR                   ,';
            v_sql := v_sql || 'CNPJ_SUBEMPREITEIRO              ,';
            v_sql := v_sql || 'CNPJ_CPF_PROPRIETARIO_CNO        ,';
            v_sql := v_sql || 'VLR_RET_SUBEMPREITADO            ,';
            v_sql := v_sql || 'NUM_DOCFIS_SERV                  ,';
            v_sql := v_sql || 'VLR_FCP_UF_DEST                  ,';
            v_sql := v_sql || 'VLR_ICMS_UF_DEST                 ,';
            v_sql := v_sql || 'VLR_ICMS_UF_ORIG                 ,';
            v_sql := v_sql || 'VLR_CONTRIB_PREV                 ,';
            v_sql := v_sql || 'VLR_GILRAT                       ,';
            v_sql := v_sql || 'VLR_CONTRIB_SENAR                ,';
            v_sql := v_sql || 'CPF_CNPJ                         ,';
            v_sql := v_sql || 'NUM_CERTIF_QUAL                  ,';
            v_sql := v_sql || 'OBS_REINF                        ,';
            v_sql := v_sql || 'VLR_TOT_ADIC                     ,';
            v_sql := v_sql || 'VLR_RET_SERV                     ,';
            v_sql := v_sql || 'VLR_SERV_15                      ,';
            v_sql := v_sql || 'VLR_SERV_20                      ,';
            v_sql := v_sql || 'VLR_SERV_25                      ,';
            v_sql := v_sql || 'VLR_IPI_DEV                      ,';
            v_sql := v_sql || 'VLR_SEST                         ,';
            v_sql := v_sql || 'VLR_SENAT                        ';
            v_sql := v_sql || ')		                        ';
            v_sql := v_sql || ' VALUES (                            ';

            linha_w :=
                   ''''
                || REPLACE ( linha_w
                           , CHR ( 9 )
                           , ''',''' )
                || '''';

            v_qtde :=
                INSTR ( linha_w
                      , ' '',' );

            WHILE v_qtde > 0 LOOP
                v_qtde :=
                    INSTR ( linha_w
                          , ' '',' );
                linha_w :=
                    REPLACE ( linha_w
                            , ' '','
                            , ''',' );
            END LOOP;

            linha_w := v_sql || linha_w || ')';

            dbms_application_info.set_module ( $$plsql_unit || '-' || p_cod_estab
                                             , ' - SAFX07: ' || ac_reg );

            EXECUTE IMMEDIATE ( linha_w );

            COMMIT;
            ac_reg := ac_reg + 1;

            FETCH cmovto
                INTO rmovto;
        END LOOP;

        loga ( 'Qtde SAFX07 BKP:' || ac_reg );
        COMMIT;

        CLOSE cmovto;

        RETURN;
    END;

    PROCEDURE safx08 ( p_data_ini DATE
                     , p_data_fim DATE
                     , p_movto_e_s VARCHAR2
                     , p_chave_acesso VARCHAR2
                     , p_cod_estab VARCHAR2 )
    IS
        -- REFERENCIA SAF_EXP_X08

        v_sql LONG;
        v_qtde INTEGER := 0;
        linha_w LONG;

        /* CONTADORES */
        ac_reg INTEGER := 0;

        /* VARIAVEIS DE TRATAMENTO DE ERRO */
        erro_leitura EXCEPTION;

        TYPE tcursor IS REF CURSOR;

        cmovto tcursor;
        rmovto x08_itens_merc%ROWTYPE;

        PROCEDURE opencursor ( p_cod_estab IN VARCHAR2
                             , p_dt_inic IN DATE
                             , p_dt_fim IN DATE
                             , pcursor IN OUT tcursor )
        IS
        BEGIN
            OPEN pcursor FOR
                SELECT x08.*
                  FROM x08_itens_merc x08
                     , x07_docto_fiscal x07
                 WHERE x07.data_fiscal BETWEEN p_dt_inic AND p_dt_fim
                   AND x07.cod_estab = p_cod_estab
                   AND x07.cod_empresa = mcod_empresa
                   AND x07.num_autentic_nfe = DECODE ( p_chave_acesso, NULL, x07.num_autentic_nfe, p_chave_acesso )
                   AND x07.movto_e_s = DECODE ( p_movto_e_s,  '1', x07.movto_e_s,  '2', '9',  x07.movto_e_s )
                   AND x07.movto_e_s <> DECODE ( p_movto_e_s, '3', '9', '-1' )
                   ---
                   AND x08.cod_empresa = x07.cod_empresa
                   AND x08.cod_estab = x07.cod_estab
                   AND x08.data_fiscal = x07.data_fiscal
                   AND x08.movto_e_s = x07.movto_e_s
                   AND x08.norm_dev = x07.norm_dev
                   AND x08.ident_docto = x07.ident_docto
                   AND x08.ident_fis_jur = x07.ident_fis_jur
                   AND x08.num_docfis = x07.num_docfis
                   AND x08.serie_docfis = x07.serie_docfis
                   AND x08.sub_serie_docfis = x07.sub_serie_docfis;
        END;
    /* INICIO */
    BEGIN
        dbms_application_info.set_module ( $$plsql_unit || '-' || p_cod_estab
                                         , ' - SAFX08: ' || 'Inicio' );

        opencursor ( p_cod_estab
                   , p_data_ini
                   , p_data_fim
                   , cmovto );

        FETCH cmovto
            INTO rmovto;

        WHILE cmovto%FOUND LOOP
            linha_w :=
                msaf.pkg_formata_exportacao.x08 ( rmovto.cod_empresa
                                                , rmovto.cod_estab
                                                , rmovto.data_fiscal
                                                , rmovto.movto_e_s
                                                , rmovto.norm_dev
                                                , rmovto.ident_docto
                                                , rmovto.ident_fis_jur
                                                , rmovto.num_docfis
                                                , rmovto.serie_docfis
                                                , rmovto.sub_serie_docfis
                                                , rmovto.discri_item
                                                , rmovto.ident_produto
                                                , rmovto.ident_und_padrao
                                                , rmovto.cod_bem
                                                , rmovto.cod_inc_bem
                                                , rmovto.valid_bem
                                                , rmovto.num_item
                                                , rmovto.ident_almox
                                                , rmovto.ident_custo
                                                , rmovto.descricao_compl
                                                , rmovto.ident_cfo
                                                , rmovto.ident_natureza_op
                                                , rmovto.ident_nbm
                                                , rmovto.quantidade
                                                , rmovto.ident_medida
                                                , rmovto.vlr_unit
                                                , rmovto.vlr_item
                                                , rmovto.vlr_desconto
                                                , rmovto.vlr_frete
                                                , rmovto.vlr_seguro
                                                , rmovto.vlr_outras
                                                , rmovto.ident_situacao_a
                                                , rmovto.ident_situacao_b
                                                , rmovto.ident_federal
                                                , rmovto.ind_ipi_incluso
                                                , rmovto.num_romaneio
                                                , rmovto.data_romaneio
                                                , rmovto.peso_liquido
                                                , rmovto.cod_indice
                                                , rmovto.vlr_item_conver
                                                , rmovto.num_processo
                                                , rmovto.ind_gravacao
                                                , rmovto.vlr_contab_compl
                                                , rmovto.vlr_aliq_destino
                                                , rmovto.vlr_outros1
                                                , rmovto.vlr_outros2
                                                , rmovto.vlr_outros3
                                                , rmovto.vlr_outros4
                                                , rmovto.vlr_outros5
                                                , rmovto.vlr_aliq_outros1
                                                , rmovto.vlr_aliq_outros2
                                                , rmovto.vlr_contab_item
                                                , rmovto.cod_obs_vcont_comp
                                                , rmovto.cod_obs_vcont_item
                                                , rmovto.vlr_outros_icms
                                                , rmovto.vlr_outros_ipi
                                                , rmovto.ind_resp_vcont_itm
                                                , rmovto.num_ato_conces
                                                , rmovto.dat_embarque
                                                , rmovto.num_reg_exp
                                                , rmovto.num_desp_exp
                                                , rmovto.vlr_tom_servico
                                                , rmovto.vlr_desp_moeda_exp
                                                , rmovto.cod_moeda_negoc
                                                , rmovto.cod_pais_dest_orig
                                                , rmovto.cod_trib_int
                                                , rmovto.vlr_icms_ndestac
                                                , rmovto.vlr_ipi_ndestac
                                                , rmovto.vlr_base_pis
                                                , rmovto.vlr_pis
                                                , rmovto.vlr_base_cofins
                                                , rmovto.vlr_cofins
                                                , rmovto.base_icms_origdest
                                                , rmovto.vlr_icms_origdest
                                                , rmovto.aliq_icms_origdest
                                                , rmovto.vlr_desc_condic
                                                , rmovto.vlr_custo_transf
                                                , rmovto.perc_red_base_icms
                                                , rmovto.qtd_embarcada
                                                , rmovto.dat_registro_exp
                                                , rmovto.dat_despacho
                                                , rmovto.dat_averbacao
                                                , rmovto.dat_di
                                                , rmovto.num_dec_imp_ref
                                                , rmovto.dsc_mot_ocor
                                                , rmovto.ident_conta
                                                , rmovto.vlr_base_icms_orig
                                                , rmovto.vlr_trib_icms_orig
                                                , rmovto.vlr_base_icms_dest
                                                , rmovto.vlr_trib_icms_dest
                                                , rmovto.vlr_perc_pres_icms
                                                , rmovto.vlr_preco_base_st
                                                , rmovto.ident_oper_oil
                                                , rmovto.cod_dcr
                                                , rmovto.ident_projeto
                                                , rmovto.dat_operacao
                                                , rmovto.usuario
                                                , rmovto.ind_mov_fis
                                                , rmovto.chassi
                                                , rmovto.num_docfis_ref
                                                , rmovto.serie_docfis_ref
                                                , rmovto.sserie_docfis_ref
                                                , rmovto.vlr_base_pis_st
                                                , rmovto.vlr_aliq_pis_st
                                                , rmovto.vlr_pis_st
                                                , rmovto.vlr_base_cofins_st
                                                , rmovto.vlr_aliq_cofins_st
                                                , rmovto.vlr_cofins_st
                                                , rmovto.vlr_base_csll
                                                , rmovto.vlr_aliq_csll
                                                , rmovto.vlr_csll
                                                , rmovto.vlr_aliq_pis
                                                , rmovto.vlr_aliq_cofins
                                                , rmovto.ind_situacao_esp_st
                                                , rmovto.vlr_icmss_ndestac
                                                , rmovto.ind_docto_rec
                                                , rmovto.dat_pgto_gnre_darj
                                                , rmovto.vlr_custo_unit
                                                , rmovto.quantidade_conv
                                                , rmovto.vlr_fecp_icms
                                                , rmovto.vlr_fecp_difaliq
                                                , rmovto.vlr_fecp_icms_st
                                                , rmovto.vlr_fecp_fonte
                                                , rmovto.vlr_base_icmss_n_escrit
                                                , rmovto.vlr_icmss_n_escrit
                                                , rmovto.cod_trib_ipi
                                                , rmovto.lote_medicamento
                                                , rmovto.valid_medicamento
                                                , rmovto.ind_base_medicamento
                                                , rmovto.vlr_preco_medicamento
                                                , rmovto.ind_tipo_arma
                                                , rmovto.num_serie_arma
                                                , rmovto.num_cano_arma
                                                , rmovto.dsc_arma
                                                , rmovto.ident_observacao
                                                , rmovto.cod_ex_ncm
                                                , rmovto.cod_ex_imp
                                                , rmovto.cnpj_operadora
                                                , rmovto.cpf_operadora
                                                , rmovto.ident_uf_operadora
                                                , rmovto.ins_est_operadora
                                                , rmovto.ind_especif_receita
                                                , rmovto.cod_class_item
                                                , rmovto.vlr_terceiros
                                                , rmovto.vlr_preco_suger
                                                , rmovto.vlr_base_cide
                                                , rmovto.vlr_aliq_cide
                                                , rmovto.vlr_cide
                                                , rmovto.cod_oper_esp_st
                                                , rmovto.vlr_comissao
                                                , rmovto.vlr_icms_frete
                                                , rmovto.vlr_difal_frete
                                                , rmovto.ind_vlr_pis_cofins
                                                , rmovto.cod_enquad_ipi
                                                , rmovto.cod_situacao_pis
                                                , rmovto.qtd_base_pis
                                                , rmovto.vlr_aliq_pis_r
                                                , rmovto.cod_situacao_cofins
                                                , rmovto.qtd_base_cofins
                                                , rmovto.vlr_aliq_cofins_r
                                                , rmovto.item_port_tare
                                                , rmovto.vlr_funrural
                                                , rmovto.ind_tp_prod_medic
                                                , rmovto.vlr_custo_dca
                                                , rmovto.cod_tp_lancto
                                                , rmovto.vlr_perc_cred_out
                                                , rmovto.vlr_cred_out
                                                , rmovto.vlr_icms_dca
                                                , rmovto.vlr_pis_exp
                                                , rmovto.vlr_pis_trib
                                                , rmovto.vlr_pis_n_trib
                                                , rmovto.vlr_cofins_exp
                                                , rmovto.vlr_cofins_trib
                                                , rmovto.vlr_cofins_n_trib
                                                , rmovto.cod_enq_legal
                                                , rmovto.ind_gravacao_saics
                                                , rmovto.dat_lanc_pis_cofins
                                                , -- 3169-DW1
                                                 rmovto.ind_pis_cofins_extemp
                                                , -- 3169-DW1
                                                 rmovto.ind_natureza_frete
                                                , -- 3169-DW1
                                                 rmovto.cod_nat_rec
                                                , --3169-DW11
                                                 rmovto.ind_nat_base_cred
                                                , --3169-GE13B
                                                 rmovto.vlr_acrescimo
                                                , rmovto.dsc_reservado1
                                                , --3521
                                                 rmovto.dsc_reservado2
                                                , --3521
                                                 rmovto.dsc_reservado3
                                                , --3521
                                                 rmovto.cod_trib_prod
                                                , -- OS3663
                                                 rmovto.dsc_reservado4
                                                , rmovto.dsc_reservado5
                                                , rmovto.dsc_reservado6
                                                , rmovto.dsc_reservado7
                                                , rmovto.dsc_reservado8
                                                , rmovto.indice_prod_acab
                                                , rmovto.vlr_base_dia_am
                                                , rmovto.vlr_aliq_dia_am
                                                , rmovto.vlr_icms_dia_am
                                                , rmovto.vlr_aduaneiro
                                                , rmovto.cod_situacao_pis_st
                                                , rmovto.cod_situacao_cofins_st
                                                , rmovto.vlr_aliq_dcip
                                                , rmovto.num_li
                                                , rmovto.vlr_fcp_uf_dest -- MFS2101
                                                , rmovto.vlr_icms_uf_dest -- MFS2101
                                                , rmovto.vlr_icms_uf_orig -- MFS2101
                                                , rmovto.vlr_dif_dub -- MFS 3484
                                                , rmovto.vlr_icms_nao_dest -- MFS 4881
                                                , rmovto.vlr_base_icms_nao_dest
                                                , rmovto.vlr_aliq_icms_nao_dest
                                                , rmovto.ind_motivo_res
                                                , rmovto.num_docfis_ret
                                                , rmovto.serie_docfis_ret
                                                , rmovto.num_autentic_nfe_ret
                                                , rmovto.num_item_ret
                                                , rmovto.ident_fis_jur_ret
                                                , rmovto.ind_tp_doc_arrec
                                                , rmovto.num_doc_arrec
                                                , rmovto.ident_cfo_dcip
                                                , rmovto.vlr_base_inss
                                                , rmovto.vlr_inss_retido
                                                , rmovto.vlr_tot_adic
                                                , rmovto.vlr_n_ret_princ
                                                , rmovto.vlr_n_ret_adic
                                                , rmovto.vlr_aliq_inss
                                                , rmovto.vlr_ret_serv
                                                , rmovto.vlr_serv_15
                                                , rmovto.vlr_serv_20
                                                , rmovto.vlr_serv_25
                                                , rmovto.ind_tp_proc_adj_princ
                                                , rmovto.ident_proc_adj_princ
                                                , rmovto.ident_susp_tbt_princ
                                                , rmovto.num_proc_adj_princ
                                                , rmovto.ind_tp_proc_adj_adic
                                                , rmovto.ident_proc_adj_adic
                                                , rmovto.ident_susp_tbt_adic
                                                , rmovto.num_proc_adj_adic
                                                --I.MFS20985
                                                , rmovto.vlr_ipi_dev
                                                , rmovto.cod_beneficio
                                                , rmovto.vlr_abat_ntributado
                                                , rmovto.vlr_credito_mva_sn
                                                , rmovto.vlr_desonerado_icms
                                                , rmovto.vlr_diferido_icms );

            v_sql := '';
            v_sql := v_sql || ' INSERT INTO MSAFI.DPSP_SAFX08_BKP';
            v_sql := v_sql || ' ( 			                    ';
            v_sql := v_sql || 'COD_EMPRESA               ,';
            v_sql := v_sql || 'COD_ESTAB                 ,';
            v_sql := v_sql || 'DATA_FISCAL               ,';
            v_sql := v_sql || 'MOVTO_E_S                 ,';
            v_sql := v_sql || 'NORM_DEV                  ,';
            v_sql := v_sql || 'COD_DOCTO                 ,';
            v_sql := v_sql || 'IND_FIS_JUR               ,';
            v_sql := v_sql || 'COD_FIS_JUR               ,';
            v_sql := v_sql || 'NUM_DOCFIS                ,';
            v_sql := v_sql || 'SERIE_DOCFIS              ,';
            v_sql := v_sql || 'SUB_SERIE_DOCFIS          ,';
            v_sql := v_sql || 'IND_BEM_PATR              ,';
            v_sql := v_sql || 'IND_PRODUTO               ,';
            v_sql := v_sql || 'COD_PRODUTO               ,';
            v_sql := v_sql || 'COD_BEM                   ,';
            v_sql := v_sql || 'COD_INC_BEM               ,';
            v_sql := v_sql || 'COD_UND_PADRAO            ,';
            v_sql := v_sql || 'NUM_ITEM                  ,';
            v_sql := v_sql || 'COD_ALMOX                 ,';
            v_sql := v_sql || 'COD_CUSTO                 ,';
            v_sql := v_sql || 'DESCRICAO_COMPL           ,';
            v_sql := v_sql || 'COD_CFO                   ,';
            v_sql := v_sql || 'COD_NATUREZA_OP           ,';
            v_sql := v_sql || 'QUANTIDADE                ,';
            v_sql := v_sql || 'COD_MEDIDA                ,';
            v_sql := v_sql || 'COD_NBM                   ,';
            v_sql := v_sql || 'VLR_UNIT                  ,';
            v_sql := v_sql || 'VLR_ITEM                  ,';
            v_sql := v_sql || 'VLR_DESCONTO              ,';
            v_sql := v_sql || 'COD_SITUACAO_A            ,';
            v_sql := v_sql || 'COD_SITUACAO_B            ,';
            v_sql := v_sql || 'COD_FEDERAL               ,';
            v_sql := v_sql || 'IND_IPI_INCLUSO           ,';
            v_sql := v_sql || 'NUM_ROMANEIO              ,';
            v_sql := v_sql || 'DATA_ROMANEIO             ,';
            v_sql := v_sql || 'PESO_LIQUIDO              ,';
            v_sql := v_sql || 'COD_INDICE                ,';
            v_sql := v_sql || 'VLR_ITEM_CONVER           ,';
            v_sql := v_sql || 'VLR_FRETE                 ,';
            v_sql := v_sql || 'VLR_SEGURO                ,';
            v_sql := v_sql || 'VLR_OUTRAS                ,';
            v_sql := v_sql || 'VLR_ALIQ_ICMS             ,';
            v_sql := v_sql || 'VLR_ICMS                  ,';
            v_sql := v_sql || 'DIF_ALIQ_ICMS             ,';
            v_sql := v_sql || 'OBS_ICMS                  ,';
            v_sql := v_sql || 'COD_APUR_ICMS             ,';
            v_sql := v_sql || 'VLR_ALIQ_IPI              ,';
            v_sql := v_sql || 'VLR_IPI                   ,';
            v_sql := v_sql || 'OBS_IPI                   ,';
            v_sql := v_sql || 'COD_APUR_IPI              ,';
            v_sql := v_sql || 'VLR_ALIQ_SUB_ICMS         ,';
            v_sql := v_sql || 'VLR_SUBST_ICMS            ,';
            v_sql := v_sql || 'OBS_SUBST_ICMS            ,';
            v_sql := v_sql || 'COD_APUR_SUB_ICMS         ,';
            v_sql := v_sql || 'TRIB_ICMS                 ,';
            v_sql := v_sql || 'BASE_ICMS                 ,';
            v_sql := v_sql || 'BASE_REDU_ICMS            ,';
            v_sql := v_sql || 'TRIB_IPI                  ,';
            v_sql := v_sql || 'BASE_IPI                  ,';
            v_sql := v_sql || 'BASE_REDU_IPI             ,';
            v_sql := v_sql || 'BASE_SUB_TRIB_ICMS        ,';
            v_sql := v_sql || 'VLR_CONTAB_COMPL          ,';
            v_sql := v_sql || 'VLR_ALIQ_DESTINO          ,';
            v_sql := v_sql || 'VLR_CONTAB_ITEM           ,';
            v_sql := v_sql || 'COD_OBS_VCONT_COMP        ,';
            v_sql := v_sql || 'COD_OBS_VCONT_ITEM        ,';
            v_sql := v_sql || 'VLR_OUTROS_ICMS           ,';
            v_sql := v_sql || 'VLR_OUTROS_IPI            ,';
            v_sql := v_sql || 'VLR_OUTROS1               ,';
            v_sql := v_sql || 'NUM_ATO_CONCES            ,';
            v_sql := v_sql || 'DAT_EMBARQUE              ,';
            v_sql := v_sql || 'NUM_REG_EXP               ,';
            v_sql := v_sql || 'NUM_DESP_EXP              ,';
            v_sql := v_sql || 'VLR_TOM_SERVICO           ,';
            v_sql := v_sql || 'VLR_DESP_MOEDA_EXP        ,';
            v_sql := v_sql || 'COD_MOEDA_NEGOC           ,';
            v_sql := v_sql || 'COD_PAIS_DEST_ORIG        ,';
            v_sql := v_sql || 'IND_CRED_ICMSS            ,';
            v_sql := v_sql || 'COD_TRIB_INT              ,';
            v_sql := v_sql || 'VLR_ICMS_NDESTAC          ,';
            v_sql := v_sql || 'VLR_IPI_NDESTAC           ,';
            v_sql := v_sql || 'TRIB_ICMS_AUX             ,';
            v_sql := v_sql || 'BASE_ICMS_AUX             ,';
            v_sql := v_sql || 'TRIB_IPI_AUX              ,';
            v_sql := v_sql || 'BASE_IPI_AUX              ,';
            v_sql := v_sql || 'VLR_BASE_PIS              ,';
            v_sql := v_sql || 'VLR_PIS                   ,';
            v_sql := v_sql || 'VLR_BASE_COFINS           ,';
            v_sql := v_sql || 'VLR_COFINS                ,';
            v_sql := v_sql || 'BASE_ICMS_ORIGDEST        ,';
            v_sql := v_sql || 'VLR_ICMS_ORIGDEST         ,';
            v_sql := v_sql || 'ALIQ_ICMS_ORIGDEST        ,';
            v_sql := v_sql || 'VLR_DESC_CONDIC           ,';
            v_sql := v_sql || 'TRIB_ICMSS                ,';
            v_sql := v_sql || 'BASE_REDU_ICMSS           ,';
            v_sql := v_sql || 'VLR_CUSTO_TRANSF          ,';
            v_sql := v_sql || 'PERC_RED_BASE_ICMS        ,';
            v_sql := v_sql || 'QTD_EMBARCADA             ,';
            v_sql := v_sql || 'DAT_REGISTRO_EXP          ,';
            v_sql := v_sql || 'DAT_DESPACHO              ,';
            v_sql := v_sql || 'DAT_AVERBACAO             ,';
            v_sql := v_sql || 'DAT_DI                    ,';
            v_sql := v_sql || 'NUM_DEC_IMP_REF           ,';
            v_sql := v_sql || 'DSC_MOT_OCOR              ,';
            v_sql := v_sql || 'COD_CONTA                 ,';
            v_sql := v_sql || 'VLR_BASE_ICMS_ORIG        ,';
            v_sql := v_sql || 'VLR_TRIB_ICMS_ORIG        ,';
            v_sql := v_sql || 'VLR_BASE_ICMS_DEST        ,';
            v_sql := v_sql || 'VLR_TRIB_ICMS_DEST        ,';
            v_sql := v_sql || 'VLR_PERC_PRES_ICMS        ,';
            v_sql := v_sql || 'VLR_PRECO_BASE_ST         ,';
            v_sql := v_sql || 'COD_OPER_OIL              ,';
            v_sql := v_sql || 'COD_DCR                   ,';
            v_sql := v_sql || 'COD_PROJETO               ,';
            v_sql := v_sql || 'IND_MOV_FIS               ,';
            v_sql := v_sql || 'CHASSI                    ,';
            v_sql := v_sql || 'NUM_DOCFIS_REF            ,';
            v_sql := v_sql || 'SERIE_DOCFIS_REF          ,';
            v_sql := v_sql || 'SSERIE_DOCFIS_REF         ,';
            v_sql := v_sql || 'VLR_BASE_PIS_ST           ,';
            v_sql := v_sql || 'VLR_ALIQ_PIS_ST           ,';
            v_sql := v_sql || 'VLR_PIS_ST                ,';
            v_sql := v_sql || 'VLR_BASE_COFINS_ST        ,';
            v_sql := v_sql || 'VLR_ALIQ_COFINS_ST        ,';
            v_sql := v_sql || 'VLR_COFINS_ST             ,';
            v_sql := v_sql || 'VLR_BASE_CSLL             ,';
            v_sql := v_sql || 'VLR_ALIQ_CSLL             ,';
            v_sql := v_sql || 'VLR_CSLL                  ,';
            v_sql := v_sql || 'VLR_ALIQ_PIS              ,';
            v_sql := v_sql || 'VLR_ALIQ_COFINS           ,';
            v_sql := v_sql || 'IND_FORNEC_ICMSS          ,';
            v_sql := v_sql || 'IND_SITUACAO_ESP_ST       ,';
            v_sql := v_sql || 'VLR_ICMSS_NDESTAC         ,';
            v_sql := v_sql || 'IND_DOCTO_REC             ,';
            v_sql := v_sql || 'DAT_PGTO_GNRE_DARJ        ,';
            v_sql := v_sql || 'VLR_CUSTO_UNIT            ,';
            v_sql := v_sql || 'QUANTIDADE_CONV           ,';
            v_sql := v_sql || 'VLR_FECP_ICMS             ,';
            v_sql := v_sql || 'VLR_FECP_DIFALIQ          ,';
            v_sql := v_sql || 'VLR_FECP_ICMS_ST          ,';
            v_sql := v_sql || 'VLR_FECP_FONTE            ,';
            v_sql := v_sql || 'TRIB_ICMSS_AUX2           ,';
            v_sql := v_sql || 'BASE_ICMSS_AUX2           ,';
            v_sql := v_sql || 'VLR_BASE_ICMSS_N_ESCRIT   ,';
            v_sql := v_sql || 'VLR_ICMSS_N_ESCRIT        ,';
            v_sql := v_sql || 'COD_TRIB_IPI              ,';
            v_sql := v_sql || 'LOTE_MEDICAMENTO          ,';
            v_sql := v_sql || 'VALID_MEDICAMENTO         ,';
            v_sql := v_sql || 'IND_BASE_MEDICAMENTO      ,';
            v_sql := v_sql || 'VLR_PRECO_MEDICAMENTO     ,';
            v_sql := v_sql || 'IND_TIPO_ARMA             ,';
            v_sql := v_sql || 'NUM_SERIE_ARMA            ,';
            v_sql := v_sql || 'NUM_CANO_ARMA             ,';
            v_sql := v_sql || 'DSC_ARMA                  ,';
            v_sql := v_sql || 'COD_OBSERVACAO            ,';
            v_sql := v_sql || 'COD_EX_NCM                ,';
            v_sql := v_sql || 'COD_EX_IMP                ,';
            v_sql := v_sql || 'CNPJ_OPERADORA            ,';
            v_sql := v_sql || 'CPF_OPERADORA             ,';
            v_sql := v_sql || 'UF_OPERADORA              ,';
            v_sql := v_sql || 'INS_EST_OPERADORA         ,';
            v_sql := v_sql || 'IND_ESPECIF_RECEITA       ,';
            v_sql := v_sql || 'COD_CLASS_ITEM            ,';
            v_sql := v_sql || 'VLR_TERCEIROS             ,';
            v_sql := v_sql || 'VLR_PRECO_SUGER           ,';
            v_sql := v_sql || 'VLR_BASE_CIDE             ,';
            v_sql := v_sql || 'VLR_ALIQ_CIDE             ,';
            v_sql := v_sql || 'VLR_CIDE                  ,';
            v_sql := v_sql || 'COD_OPER_ESP_ST           ,';
            v_sql := v_sql || 'VLR_COMISSAO              ,';
            v_sql := v_sql || 'VLR_ICMS_FRETE            ,';
            v_sql := v_sql || 'VLR_DIFAL_FRETE           ,';
            v_sql := v_sql || 'IND_VLR_PIS_COFINS        ,';
            v_sql := v_sql || 'COD_ENQUAD_IPI            ,';
            v_sql := v_sql || 'COD_SITUACAO_PIS          ,';
            v_sql := v_sql || 'QTD_BASE_PIS              ,';
            v_sql := v_sql || 'VLR_ALIQ_PIS_R            ,';
            v_sql := v_sql || 'COD_SITUACAO_COFINS       ,';
            v_sql := v_sql || 'QTD_BASE_COFINS           ,';
            v_sql := v_sql || 'VLR_ALIQ_COFINS_R         ,';
            v_sql := v_sql || 'ITEM_PORT_TARE            ,';
            v_sql := v_sql || 'VLR_FUNRURAL              ,';
            v_sql := v_sql || 'IND_TP_PROD_MEDIC         ,';
            v_sql := v_sql || 'VLR_CUSTO_DCA             ,';
            v_sql := v_sql || 'COD_TP_LANCTO             ,';
            v_sql := v_sql || 'VLR_PERC_CRED_OUT         ,';
            v_sql := v_sql || 'VLR_CRED_OUT              ,';
            v_sql := v_sql || 'VLR_ICMS_DCA              ,';
            v_sql := v_sql || 'VLR_PIS_EXP               ,';
            v_sql := v_sql || 'VLR_PIS_TRIB              ,';
            v_sql := v_sql || 'VLR_PIS_N_TRIB            ,';
            v_sql := v_sql || 'VLR_COFINS_EXP            ,';
            v_sql := v_sql || 'VLR_COFINS_TRIB           ,';
            v_sql := v_sql || 'VLR_COFINS_N_TRIB         ,';
            v_sql := v_sql || 'COD_ENQ_LEGAL             ,';
            v_sql := v_sql || 'DAT_LANC_PIS_COFINS       ,';
            v_sql := v_sql || 'IND_PIS_COFINS_EXTEMP     ,';
            v_sql := v_sql || 'IND_NATUREZA_FRETE        ,';
            v_sql := v_sql || 'COD_NAT_REC               ,';
            v_sql := v_sql || 'IND_NAT_BASE_CRED         ,';
            v_sql := v_sql || 'VLR_ACRESCIMO             ,';
            v_sql := v_sql || 'IND_IPI_NDESTAC_DF        ,';
            v_sql := v_sql || 'DSC_RESERVADO1            ,';
            v_sql := v_sql || 'DSC_RESERVADO2            ,';
            v_sql := v_sql || 'DSC_RESERVADO3            ,';
            v_sql := v_sql || 'COD_TRIB_PROD             ,';
            v_sql := v_sql || 'DSC_RESERVADO4            ,';
            v_sql := v_sql || 'DSC_RESERVADO5            ,';
            v_sql := v_sql || 'DSC_RESERVADO6            ,';
            v_sql := v_sql || 'DSC_RESERVADO7            ,';
            v_sql := v_sql || 'DSC_RESERVADO8            ,';
            v_sql := v_sql || 'INDICE_PROD_ACAB          ,';
            v_sql := v_sql || 'VLR_BASE_DIA_AM           ,';
            v_sql := v_sql || 'VLR_ALIQ_DIA_AM           ,';
            v_sql := v_sql || 'VLR_ICMS_DIA_AM           ,';
            v_sql := v_sql || 'VLR_ADUANEIRO             ,';
            v_sql := v_sql || 'COD_SITUACAO_PIS_ST       ,';
            v_sql := v_sql || 'COD_SITUACAO_COFINS_ST    ,';
            v_sql := v_sql || 'VLR_ALIQ_DCIP             ,';
            v_sql := v_sql || 'NUM_LI                    ,';
            v_sql := v_sql || 'VLR_FCP_UF_DEST           ,';
            v_sql := v_sql || 'VLR_ICMS_UF_DEST          ,';
            v_sql := v_sql || 'VLR_ICMS_UF_ORIG          ,';
            v_sql := v_sql || 'VLR_DIF_DUB               ,';
            v_sql := v_sql || 'VLR_ICMS_NAO_DEST         ,';
            v_sql := v_sql || 'VLR_BASE_ICMS_NAO_DEST    ,';
            v_sql := v_sql || 'VLR_ALIQ_ICMS_NAO_DEST    ,';
            v_sql := v_sql || 'IND_MOTIVO_RES            ,';
            v_sql := v_sql || 'NUM_DOCFIS_RET            ,';
            v_sql := v_sql || 'SERIE_DOCFIS_RET          ,';
            v_sql := v_sql || 'NUM_AUTENTIC_NFE_RET      ,';
            v_sql := v_sql || 'NUM_ITEM_RET              ,';
            v_sql := v_sql || 'IND_FIS_JUR_RET           ,';
            v_sql := v_sql || 'COD_FIS_JUR_RET           ,';
            v_sql := v_sql || 'IND_TP_DOC_ARREC          ,';
            v_sql := v_sql || 'NUM_DOC_ARREC             ,';
            v_sql := v_sql || 'COD_CFO_DCIP              ,';
            v_sql := v_sql || 'VLR_BASE_INSS             ,';
            v_sql := v_sql || 'VLR_INSS_RETIDO           ,';
            v_sql := v_sql || 'VLR_TOT_ADIC              ,';
            v_sql := v_sql || 'VLR_N_RET_PRINC           ,';
            v_sql := v_sql || 'VLR_N_RET_ADIC            ,';
            v_sql := v_sql || 'VLR_ALIQ_INSS             ,';
            v_sql := v_sql || 'VLR_RET_SERV              ,';
            v_sql := v_sql || 'VLR_SERV_15               ,';
            v_sql := v_sql || 'VLR_SERV_20               ,';
            v_sql := v_sql || 'VLR_SERV_25               ,';
            v_sql := v_sql || 'IND_TP_PROC_ADJ_PRINC     ,';
            v_sql := v_sql || 'NUM_PROC_ADJ_PRINC        ,';
            v_sql := v_sql || 'COD_SUSP_PRINC            ,';
            v_sql := v_sql || 'IND_TP_PROC_ADJ_ADIC      ,';
            v_sql := v_sql || 'NUM_PROC_ADJ_ADIC         ,';
            v_sql := v_sql || 'COD_SUSP_ADIC             ,';
            v_sql := v_sql || 'VLR_IPI_DEV               ,';
            v_sql := v_sql || 'COD_BENEFICIO             ,';
            v_sql := v_sql || 'VLR_ABAT_NTRIBUTADO       ,';
            v_sql := v_sql || 'VLR_CREDITO_MVA_SN        ,';
            v_sql := v_sql || 'VLR_DESONERADO_ICMS        ,';
            v_sql := v_sql || 'VLR_DESONERADO_ICMS        ';
            v_sql := v_sql || ') ';
            v_sql := v_sql || ' VALUES (                            ';

            linha_w :=
                REPLACE ( linha_w
                        , ''''
                        , '''''' );
            linha_w :=
                   ''''
                || REPLACE ( linha_w
                           , CHR ( 9 )
                           , ''',''' )
                || '''';

            v_qtde :=
                INSTR ( linha_w
                      , ' '',' );

            WHILE v_qtde > 0 LOOP
                v_qtde :=
                    INSTR ( linha_w
                          , ' '',' );
                linha_w :=
                    REPLACE ( linha_w
                            , ' '','
                            , ''',' );
            END LOOP;

            linha_w := v_sql || linha_w || ')';

            dbms_application_info.set_module ( $$plsql_unit || '-' || p_cod_estab
                                             , ' - SAFX08: ' || ac_reg );

            EXECUTE IMMEDIATE ( linha_w );

            COMMIT;
            ac_reg := ac_reg + 1;

            FETCH cmovto
                INTO rmovto;
        END LOOP;

        loga ( 'Qtde SAFX08:' || ac_reg );

        CLOSE cmovto;

        RETURN;
    END;

    PROCEDURE safx09 ( p_data_ini DATE
                     , p_data_fim DATE
                     , p_movto_e_s VARCHAR2
                     , p_chave_acesso VARCHAR2
                     , p_cod_estab VARCHAR2 )
    IS
        -- REFERENCIA SAF_EXP_X09

        v_sql LONG;
        v_qtde INTEGER := 0;
        linha_w LONG;

        /* CONTADORES */
        ac_reg INTEGER := 0;

        /* VARIAVEIS DE TRATAMENTO DE ERRO */
        erro_leitura EXCEPTION;

        TYPE tcursor IS REF CURSOR;

        cmovto tcursor;
        rmovto x09_itens_serv%ROWTYPE;

        PROCEDURE opencursor ( p_cod_estab IN VARCHAR2
                             , p_dt_inic IN DATE
                             , p_dt_fim IN DATE
                             , pcursor IN OUT tcursor )
        IS
        BEGIN
            OPEN pcursor FOR
                SELECT *
                  FROM x09_itens_serv
                 WHERE data_fiscal BETWEEN p_dt_inic AND p_dt_fim
                   AND cod_estab = p_cod_estab
                   AND cod_empresa = mcod_empresa
                   AND num_docfis = DECODE ( p_chave_acesso, NULL, num_docfis, p_chave_acesso )
                   AND movto_e_s = DECODE ( p_movto_e_s,  '1', movto_e_s,  '2', '9',  '3', movto_e_s )
                   AND movto_e_s <> DECODE ( p_movto_e_s, '3', '9', '-1' );
        END;
    /* INICIO */
    BEGIN
        dbms_application_info.set_module ( $$plsql_unit || '-' || p_cod_estab
                                         , ' - SAFX09: ' || 'Inicio' );

        opencursor ( p_cod_estab
                   , p_data_ini
                   , p_data_fim
                   , cmovto );

        FETCH cmovto
            INTO rmovto;

        WHILE cmovto%FOUND LOOP
            linha_w :=
                pkg_formata_exportacao.x09 ( rmovto.cod_empresa
                                           , rmovto.cod_estab
                                           , rmovto.data_fiscal
                                           , rmovto.movto_e_s
                                           , rmovto.norm_dev
                                           , rmovto.ident_docto
                                           , rmovto.ident_fis_jur
                                           , rmovto.num_docfis
                                           , rmovto.serie_docfis
                                           , rmovto.sub_serie_docfis
                                           , rmovto.ident_servico
                                           , rmovto.num_item
                                           , rmovto.descricao_compl
                                           , rmovto.ident_cfo
                                           , rmovto.ident_natureza_op
                                           , rmovto.quantidade
                                           , rmovto.vlr_unit
                                           , rmovto.vlr_servico
                                           , rmovto.vlr_desconto
                                           , rmovto.vlr_tot
                                           , rmovto.contrato
                                           , rmovto.cod_indice
                                           , rmovto.vlr_servico_conv
                                           , rmovto.num_processo
                                           , rmovto.ind_gravacao
                                           , rmovto.ident_produto
                                           , rmovto.dat_operacao
                                           , rmovto.usuario
                                           , rmovto.compl_isencao
                                           , rmovto.vlr_base_csll
                                           , rmovto.vlr_aliq_csll
                                           , rmovto.vlr_csll
                                           , rmovto.vlr_base_pis
                                           , rmovto.vlr_aliq_pis
                                           , rmovto.vlr_pis
                                           , rmovto.vlr_base_cofins
                                           , rmovto.vlr_aliq_cofins
                                           , rmovto.vlr_cofins
                                           , rmovto.ident_conta
                                           , rmovto.ident_observacao
                                           , rmovto.cod_trib_iss
                                           , rmovto.vlr_mat_prop
                                           , rmovto.vlr_mat_terc
                                           , rmovto.vlr_base_iss_retido
                                           , rmovto.vlr_iss_retido
                                           , rmovto.vlr_deducao_iss
                                           , rmovto.vlr_subempr_iss
                                           , rmovto.cod_cfps
                                           , rmovto.vlr_out_desp
                                           , rmovto.vlr_base_cide
                                           , rmovto.vlr_aliq_cide
                                           , rmovto.vlr_cide
                                           , rmovto.vlr_comissao
                                           , rmovto.ind_vlr_pis_cofins
                                           , rmovto.cod_situacao_pis
                                           , rmovto.cod_situacao_cofins
                                           , rmovto.vlr_pis_exp
                                           , rmovto.vlr_pis_trib
                                           , rmovto.vlr_pis_n_trib
                                           , rmovto.vlr_cofins_exp
                                           , rmovto.vlr_cofins_trib
                                           , rmovto.vlr_cofins_n_trib
                                           , rmovto.vlr_pis_retido
                                           , -- 3169-DW1
                                            rmovto.vlr_cofins_retido
                                           , -- 3169-DW1
                                            rmovto.dat_lanc_pis_cofins
                                           , -- 3169-DW1
                                            rmovto.ind_pis_cofins_extemp
                                           , -- 3169-DW1
                                            rmovto.ind_local_exec_serv
                                           , -- 3169-DW1
                                            rmovto.ident_custo
                                           , -- 3169-DW1
                                            rmovto.vlr_base_inss
                                           , -- 3003
                                            rmovto.vlr_aliq_inss
                                           , -- 3003
                                            rmovto.vlr_inss_retido
                                           , -- 3003
                                            rmovto.cod_nat_rec
                                           , -- 3169-Dw11
                                            rmovto.ind_nat_base_cred
                                           , --3169-GE13B
                                            rmovto.vlr_acrescimo
                                           , rmovto.dsc_reservado1
                                           , --3521
                                            rmovto.dsc_reservado2
                                           , --3521
                                            rmovto.dsc_reservado3
                                           , --3521
                                            rmovto.ident_nbs
                                           , -- OS3924
                                            rmovto.vlr_tot_adic
                                           , -- OS4514
                                            rmovto.vlr_tot_ret
                                           , -- OS4514
                                            rmovto.vlr_deducao_nf
                                           , -- OS4514
                                            rmovto.vlr_ret_nf
                                           , -- OS4514
                                            rmovto.vlr_ret_serv
                                           , -- OS4514
                                            rmovto.vlr_aliq_iss_retido
                                           , -- OS4226
                                            rmovto.cod_sit_trib_iss
                                           , -- OS4667
                                            rmovto.vlr_n_ret_princ
                                           , --MFS8798
                                            rmovto.vlr_n_ret_adic
                                           , rmovto.vlr_ded_alim
                                           , rmovto.vlr_ded_trans
                                           , rmovto.ind_tp_proc_adj_princ
                                           , -- MFS10357
                                            rmovto.ident_proc_adj_princ
                                           , rmovto.ident_susp_tbt_princ
                                           , rmovto.ind_tp_proc_adj_adic
                                           , rmovto.ident_proc_adj_adic
                                           , rmovto.ident_susp_tbt_adic
                                           , rmovto.vlr_serv_15
                                           , rmovto.vlr_serv_20
                                           , rmovto.vlr_serv_25
                                           , rmovto.vlr_abat_ntributado --MFS20985
                                                                        );

            v_sql := '';
            v_sql := v_sql || ' INSERT INTO MSAFI.DPSP_SAFX09_BKP';
            v_sql := v_sql || ' ( 			                    ';
            v_sql := v_sql || ' COD_EMPRESA					,';
            v_sql := v_sql || ' COD_ESTAB                   ,';
            v_sql := v_sql || ' DATA_FISCAL                 ,';
            v_sql := v_sql || ' MOVTO_E_S                   ,';
            v_sql := v_sql || ' NORM_DEV                    ,';
            v_sql := v_sql || ' COD_DOCTO                   ,';
            v_sql := v_sql || ' IND_FIS_JUR                 ,';
            v_sql := v_sql || ' COD_FIS_JUR                 ,';
            v_sql := v_sql || ' NUM_DOCFIS                  ,';
            v_sql := v_sql || ' SERIE_DOCFIS                ,';
            v_sql := v_sql || ' SUB_SERIE_DOCFIS            ,';
            v_sql := v_sql || ' COD_SERVICO                 ,';
            v_sql := v_sql || ' NUM_ITEM                    ,';
            v_sql := v_sql || ' VLR_SERVICO                 ,';
            v_sql := v_sql || ' VLR_TOT                     ,';
            v_sql := v_sql || ' DESCRICAO_COMPL             ,';
            v_sql := v_sql || ' COD_CFO                     ,';
            v_sql := v_sql || ' COD_NATUREZA_OP             ,';
            v_sql := v_sql || ' QUANTIDADE                  ,';
            v_sql := v_sql || ' VLR_UNIT                    ,';
            v_sql := v_sql || ' VLR_DESCONTO                ,';
            v_sql := v_sql || ' CONTRATO                    ,';
            v_sql := v_sql || ' COD_INDICE                  ,';
            v_sql := v_sql || ' VLR_SERVICO_CONV            ,';
            v_sql := v_sql || ' VLR_ALIQ_ICMS               ,';
            v_sql := v_sql || ' VLR_ICMS                    ,';
            v_sql := v_sql || ' DIF_ALIQ_ICMS               ,';
            v_sql := v_sql || ' OBS_ICMS                    ,';
            v_sql := v_sql || ' COD_APUR_ICMS               ,';
            v_sql := v_sql || ' VLR_ALIQ_IR                 ,';
            v_sql := v_sql || ' VLR_IR                      ,';
            v_sql := v_sql || ' VLR_ALIQ_ISS                ,';
            v_sql := v_sql || ' VLR_ISS                     ,';
            v_sql := v_sql || ' TRIB_ICMS                   ,';
            v_sql := v_sql || ' BASE_ICMS                   ,';
            v_sql := v_sql || ' TRIB_IR                     ,';
            v_sql := v_sql || ' BASE_IR                     ,';
            v_sql := v_sql || ' TRIB_ISS                    ,';
            v_sql := v_sql || ' BASE_ISS                    ,';
            v_sql := v_sql || ' IND_PRODUTO                 ,';
            v_sql := v_sql || ' COD_PRODUTO                 ,';
            v_sql := v_sql || ' COMPL_ISENCAO               ,';
            v_sql := v_sql || ' VLR_BASE_CSLL               ,';
            v_sql := v_sql || ' VLR_ALIQ_CSLL               ,';
            v_sql := v_sql || ' VLR_CSLL                    ,';
            v_sql := v_sql || ' VLR_BASE_PIS                ,';
            v_sql := v_sql || ' VLR_ALIQ_PIS                ,';
            v_sql := v_sql || ' VLR_PIS                     ,';
            v_sql := v_sql || ' VLR_BASE_COFINS             ,';
            v_sql := v_sql || ' VLR_ALIQ_COFINS             ,';
            v_sql := v_sql || ' VLR_COFINS                  ,';
            v_sql := v_sql || ' COD_CONTA                   ,';
            v_sql := v_sql || ' COD_OBSERVACAO              ,';
            v_sql := v_sql || ' COD_TRIB_ISS                ,';
            v_sql := v_sql || ' VLR_MAT_PROP                ,';
            v_sql := v_sql || ' VLR_MAT_TERC                ,';
            v_sql := v_sql || ' VLR_BASE_ISS_RETIDO         ,';
            v_sql := v_sql || ' VLR_ISS_RETIDO              ,';
            v_sql := v_sql || ' VLR_DEDUCAO_ISS             ,';
            v_sql := v_sql || ' VLR_SUBEMPR_ISS             ,';
            v_sql := v_sql || ' COD_CFPS                    ,';
            v_sql := v_sql || ' VLR_OUT_DESP                ,';
            v_sql := v_sql || ' VLR_BASE_CIDE               ,';
            v_sql := v_sql || ' VLR_ALIQ_CIDE               ,';
            v_sql := v_sql || ' VLR_CIDE                    ,';
            v_sql := v_sql || ' VLR_COMISSAO                ,';
            v_sql := v_sql || ' IND_VLR_PIS_COFINS          ,';
            v_sql := v_sql || ' COD_SITUACAO_PIS            ,';
            v_sql := v_sql || ' COD_SITUACAO_COFINS         ,';
            v_sql := v_sql || ' VLR_PIS_EXP                 ,';
            v_sql := v_sql || ' VLR_PIS_TRIB                ,';
            v_sql := v_sql || ' VLR_PIS_N_TRIB              ,';
            v_sql := v_sql || ' VLR_COFINS_EXP              ,';
            v_sql := v_sql || ' VLR_COFINS_TRIB             ,';
            v_sql := v_sql || ' VLR_COFINS_N_TRIB           ,';
            v_sql := v_sql || ' VLR_BASE_INSS               ,';
            v_sql := v_sql || ' VLR_INSS_RETIDO             ,';
            v_sql := v_sql || ' VLR_ALIQ_INSS               ,';
            v_sql := v_sql || ' VLR_PIS_RETIDO              ,';
            v_sql := v_sql || ' VLR_COFINS_RETIDO           ,';
            v_sql := v_sql || ' DAT_LANC_PIS_COFINS         ,';
            v_sql := v_sql || ' IND_PIS_COFINS_EXTEMP       ,';
            v_sql := v_sql || ' IND_LOCAL_EXEC_SERV         ,';
            v_sql := v_sql || ' COD_CUSTO                   ,';
            v_sql := v_sql || ' COD_NAT_REC                 ,';
            v_sql := v_sql || ' IND_NAT_BASE_CRED           ,';
            v_sql := v_sql || ' VLR_ACRESCIMO               ,';
            v_sql := v_sql || ' DSC_RESERVADO1              ,';
            v_sql := v_sql || ' DSC_RESERVADO2              ,';
            v_sql := v_sql || ' DSC_RESERVADO3              ,';
            v_sql := v_sql || ' COD_NBS                     ,';
            v_sql := v_sql || ' VLR_TOT_ADIC                ,';
            v_sql := v_sql || ' VLR_TOT_RET                 ,';
            v_sql := v_sql || ' VLR_DEDUCAO_NF              ,';
            v_sql := v_sql || ' VLR_RET_NF                  ,';
            v_sql := v_sql || ' VLR_RET_SERV                ,';
            v_sql := v_sql || ' VLR_ALIQ_ISS_RETIDO         ,';
            v_sql := v_sql || ' COD_SIT_TRIB_ISS            ,';
            v_sql := v_sql || ' VLR_N_RET_PRINC             ,';
            v_sql := v_sql || ' VLR_N_RET_ADIC              ,';
            v_sql := v_sql || ' VLR_DED_ALIM                ,';
            v_sql := v_sql || ' VLR_DED_TRANS               ,';
            v_sql := v_sql || ' IND_TP_PROC_ADJ_PRINC       ,';
            v_sql := v_sql || ' NUM_PROC_ADJ_PRINC          ,';
            v_sql := v_sql || ' COD_SUSP_PRINC              ,';
            v_sql := v_sql || ' IND_TP_PROC_ADJ_ADIC        ,';
            v_sql := v_sql || ' NUM_PROC_ADJ_ADIC           ,';
            v_sql := v_sql || ' COD_SUSP_ADIC               ,';
            v_sql := v_sql || ' VLR_SERV_15                 ,';
            v_sql := v_sql || ' VLR_SERV_20                 ,';
            v_sql := v_sql || ' VLR_SERV_25                 ,';
            v_sql := v_sql || ' VLR_ABAT_NTRIBUTADO          ';
            v_sql := v_sql || ')		                        ';
            v_sql := v_sql || ' VALUES (                            ';

            linha_w :=
                   ''''
                || REPLACE ( linha_w
                           , CHR ( 9 )
                           , ''',''' )
                || '''';

            v_qtde :=
                INSTR ( linha_w
                      , ' '',' );

            WHILE v_qtde > 0 LOOP
                v_qtde :=
                    INSTR ( linha_w
                          , ' '',' );
                linha_w :=
                    REPLACE ( linha_w
                            , ' '','
                            , ''',' );
            END LOOP;

            linha_w := v_sql || linha_w || ')';

            dbms_application_info.set_module ( $$plsql_unit || '-' || p_cod_estab
                                             , ' - SAFX09: ' || ac_reg );

            EXECUTE IMMEDIATE ( linha_w );

            COMMIT;
            ac_reg := ac_reg + 1;

            FETCH cmovto
                INTO rmovto;
        END LOOP;

        loga ( 'Qtde SAFX09:' || ac_reg );

        CLOSE cmovto;

        RETURN;
    END;

    PROCEDURE excluir_nfs ( p_dt_inic DATE
                          , p_dt_fim DATE
                          , p_movto_e_s VARCHAR2
                          , p_chave_acesso VARCHAR2
                          , p_cod_estab VARCHAR2 )
    IS
        p_msg_erro VARCHAR2 ( 2000 );
        p_cod_erro INTEGER;

        c07_del msaf.pkg_imp_x07.t_c07_del;

        ret_w INTEGER;
        ac_reg INTEGER := 0;
        chk_count INTEGER DEFAULT 0;

        CURSOR c_del_nf ( p_dt_inic IN DATE
                        , p_dt_fim IN DATE
                        , p_cod_estab IN VARCHAR2
                        , p_chave_acesso IN VARCHAR2
                        , p_movto_e_s IN VARCHAR2 )
        IS
            SELECT cod_empresa
                 , cod_estab
                 , data_fiscal
                 , movto_e_s
                 , norm_dev
                 , ident_docto
                 , ident_fis_jur
                 , num_docfis
                 , serie_docfis
                 , sub_serie_docfis
              FROM msaf.x07_docto_fiscal a
             WHERE data_fiscal BETWEEN p_dt_inic AND p_dt_fim
               AND cod_estab = p_cod_estab
               AND cod_empresa = mcod_empresa
               AND num_autentic_nfe = DECODE ( p_chave_acesso, NULL, num_autentic_nfe, p_chave_acesso )
               AND movto_e_s = DECODE ( p_movto_e_s,  '1', movto_e_s,  '2', '9',  movto_e_s )
               AND movto_e_s <> DECODE ( p_movto_e_s, '3', '9', '-1' )
               AND cod_sistema_orig IN ( 'PS-E'
                                       , 'PS-S' ); --- Peoplesoft Only

        TYPE t_tab_del IS TABLE OF c_del_nf%ROWTYPE;

        tab_del t_tab_del;
    BEGIN
        OPEN c_del_nf ( p_dt_inic
                      , p_dt_fim
                      , p_cod_estab
                      , p_chave_acesso
                      , p_movto_e_s );

        LOOP
            FETCH c_del_nf
                BULK COLLECT INTO tab_del
                LIMIT 100;

            FOR c IN tab_del.FIRST .. tab_del.LAST LOOP
                ac_reg := ac_reg + 1;
                dbms_application_info.set_module ( $$plsql_unit || '-' || p_cod_estab
                                                 , ' - NFs Del: ' || ac_reg );

                c07_del ( ac_reg ).cod_empresa := tab_del ( c ).cod_empresa;
                c07_del ( ac_reg ).cod_estab := tab_del ( c ).cod_estab;
                c07_del ( ac_reg ).data_fiscal := tab_del ( c ).data_fiscal;
                c07_del ( ac_reg ).movto_e_s := tab_del ( c ).movto_e_s;
                c07_del ( ac_reg ).norm_dev := tab_del ( c ).norm_dev;
                c07_del ( ac_reg ).ident_docto := tab_del ( c ).ident_docto;
                c07_del ( ac_reg ).ident_fis_jur := tab_del ( c ).ident_fis_jur;
                c07_del ( ac_reg ).num_docfis := tab_del ( c ).num_docfis;
                c07_del ( ac_reg ).serie_docfis := tab_del ( c ).serie_docfis;
                c07_del ( ac_reg ).sub_serie_docfis := tab_del ( c ).sub_serie_docfis;
            END LOOP;

            ret_w :=
                msaf.pkg_imp_x07.deleta_tab_nf ( c07_del
                                               , 'N'
                                               , p_msg_erro
                                               , p_cod_erro );

            COMMIT;
            chk_count := chk_count + c07_del.COUNT;
            ac_reg := 0;
            c07_del.delete;

            tab_del.delete;
            EXIT WHEN c_del_nf%NOTFOUND;
        END LOOP;

        CLOSE c_del_nf;

        loga (
                  'Qtde NF Excluidas: '
               || ac_reg
               || ' Param Retorno: '
               || p_cod_erro
               || '|'
               || p_msg_erro
               || '|'
               || ret_w
               || '|'
               || chk_count
        );
    END;

    FUNCTION executar ( p_data_ini DATE
                      , p_data_fim DATE
                      , p_uf VARCHAR2
                      , p_movto_e_s VARCHAR2
                      , p_chave_acesso VARCHAR2
                      , p_safx07 VARCHAR2
                      , p_safx08 VARCHAR2
                      , p_delete VARCHAR2
                      , --                    p_safx09     VARCHAR2,
                        p_cod_estab lib_proc.vartab )
        RETURN INTEGER
    IS
        i1 INTEGER := 0;

        p_safx09 VARCHAR2 ( 1 ) := 'N';
    BEGIN
        -- Criação: Processo
        mproc_id := lib_proc.new ( $$plsql_unit );

        mcod_empresa := NVL ( mcod_empresa, msafi.dpsp.v_empresa );

        IF mcod_empresa = 'DP' THEN
            v_dblink := 'DBLINK_DBMRJPRD';
        ELSIF mcod_empresa = 'DSP' THEN
            v_dblink := 'DBLINK_DBMSPPRD';
        END IF;

        loga ( 'Empresa:' || mcod_empresa );
        loga ( v_dblink );

        loga ( 'Inicio: ' );

        IF ( p_cod_estab.COUNT > 0 ) THEN
            i1 := p_cod_estab.FIRST;

            WHILE i1 IS NOT NULL LOOP
                loga ( 'Estab: ' || p_cod_estab ( i1 ) );

                IF p_safx07 = 'S' THEN
                    safx07 ( p_data_ini
                           , p_data_fim
                           , p_movto_e_s
                           , p_chave_acesso
                           , p_cod_estab ( i1 ) );
                END IF;

                IF p_safx08 = 'S' THEN
                    safx08 ( p_data_ini
                           , p_data_fim
                           , p_movto_e_s
                           , p_chave_acesso
                           , p_cod_estab ( i1 ) );
                END IF;

                IF p_safx09 = 'S' THEN
                    safx09 ( p_data_ini
                           , p_data_fim
                           , p_movto_e_s
                           , p_chave_acesso
                           , p_cod_estab ( i1 ) );
                END IF;

                IF p_delete = 'S' THEN
                    excluir_nfs ( p_data_ini
                                , p_data_fim
                                , p_movto_e_s
                                , p_chave_acesso
                                , p_cod_estab ( i1 ) );
                END IF;

                i1 := p_cod_estab.NEXT ( i1 );
            END LOOP;
        END IF;

        dbms_application_info.set_module ( $$plsql_unit
                                         , ' fim ' );

        loga ( 'Fim ' );

        lib_proc.close ( );

        RETURN mproc_id;
    EXCEPTION
        WHEN OTHERS THEN
            loga ( 'SQLERRM: ' || SQLERRM );
            lib_proc.add_log ( 'Erro não tratado: ' || dbms_utility.format_error_backtrace
                             , 1 );
            lib_proc.add_log ( 'SQLERRM: ' || SQLERRM
                             , 1 );
            lib_proc.add ( 'ERRO!' );
            lib_proc.add ( dbms_utility.format_error_backtrace );
            lib_proc.close;
            COMMIT;
            RETURN mproc_id;
    END;
END dpsp_exporta_safx_cproc;
/
SHOW ERRORS;
