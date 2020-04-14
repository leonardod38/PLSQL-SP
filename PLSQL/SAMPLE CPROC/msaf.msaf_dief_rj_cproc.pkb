Prompt Package Body MSAF_DIEF_RJ_CPROC;
--
-- MSAF_DIEF_RJ_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY msaf_dief_rj_cproc
IS
    mcod_estab estabelecimento.cod_estab%TYPE;
    mcod_empresa empresa.cod_empresa%TYPE;
    musuario usuario_estab.cod_usuario%TYPE;

    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );
    BEGIN
        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        mcod_estab := NVL ( lib_parametros.recuperar ( 'ESTABELECIMENTO' ), '' );
        musuario := lib_parametros.recuperar ( 'USUARIO' );

        lib_proc.add_param (
                             pstr
                           , 'Estabelecimento '
                           , 'Varchar2'
                           , 'Combobox'
                           , 'S'
                           , NULL
                           , NULL
                           ,    'SELECT DISTINCT e.cod_estab, e.cod_estab||'' - ''||e.razao_social FROM estabelecimento e, ict_estab_iestad i WHERE e.cod_empresa = i.cod_empresa(+) AND e.cod_estab = i.cod_estab(+) AND e.cod_empresa = '''
                             || mcod_empresa
                             || ''''
        );

        lib_proc.add_param ( pstr
                           , 'Competencia '
                           , 'Date'
                           , 'Textbox'
                           , 'S'
                           , NULL
                           , 'mm/yyyy' );

        lib_proc.add_param (
                             pstr
                           , 'Tipo de Documento '
                           , 'Varchar2'
                           , 'Listbox'
                           , 'S'
                           , NULL
                           , NULL
                           ,    '1 = Documentos Recebidos,'
                             || '2 = Documentos Emitidos,'
                             || '3 = Documentos Emitidos e Recebidos'
        );

        RETURN pstr;
    END;

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN ' DIEF Rio de Janeiro';
    END;

    FUNCTION tipo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN ' DIEF Rio de Janeiro';
    END;

    FUNCTION versao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN '1.0';
    END;

    FUNCTION descricao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN ' DIEF Rio de Janeiro';
    END;

    FUNCTION modulo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Processos Customizados';
    END;

    FUNCTION classificacao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Processos Customizados';
    END;

    FUNCTION executar ( pcd_estab VARCHAR2
                      , pdt_comp DATE
                      , ptp_docto VARCHAR2 )
        RETURN INTEGER
    IS
        /* Variáveis de Trabalho */
        mlinha VARCHAR2 ( 1000 );
        v_insc_municipal VARCHAR2 ( 14 );
        pdat_ini DATE;
        pdat_fim DATE;
        count_reg INTEGER := 0;
        v_nota_ant NUMBER := 0;
        v_nota_ini NUMBER := 0;
        v_data_emissao VARCHAR2 ( 8 );
        v_data_cancelamento VARCHAR2 ( 8 );
        v_cod_servico VARCHAR2 ( 6 );
        v_serie_docfis VARCHAR2 ( 3 );
        v_cpf_cgc VARCHAR2 ( 14 );
        v_situacao NUMBER ( 1 );
        v_vlr_tot_nota NUMBER ( 17, 2 ) := 0;
        v_vlr_base_iss_1 NUMBER ( 17, 2 ) := 0;
        v_vlr_servico NUMBER ( 17, 2 ) := 0;
        v_vlr_base_iss_1_07 NUMBER ( 17, 2 ) := 0;
        v_tot_base NUMBER ( 17, 2 ) := 0;
        v_tot_serv NUMBER ( 17, 2 ) := 0;
        v_tomador NUMBER ( 1 );
        v_num_ini_controle NUMBER ( 12 );
        v_num_fim_controle NUMBER ( 12 );
        v_nro_aidf_nf NUMBER ( 12 );
        v_movto_e_s NUMBER ( 1 ) NULL;
        v_num_docfis_ref NUMBER ( 12 ) NULL;
        v_data_docfis_ref VARCHAR2 ( 8 );
        v_obs_compl VARCHAR2 ( 250 );
        v_destaque NUMBER ( 1 );
        v_prest_serv NUMBER ( 1 );
        v_vlr_doc_tot NUMBER ( 17, 2 ) := 0;
        v_vlr_tributo_iss NUMBER ( 17, 2 ) := 0;
        v_vlr_tributo_iss07 NUMBER ( 17, 2 ) := 0;
        v_especie VARCHAR2 ( 5 );
        v_item CHAR ( 1 );
        v_trib CHAR ( 1 );
        v_aliq NUMBER ( 3 ) := 0;
        v_desconto NUMBER ( 17, 2 ) := 0;
        v_aliq_ant NUMBER ( 3 ) := 0;
        v_cod_servico_ant VARCHAR2 ( 6 );
        chave VARCHAR2 ( 30 ) := NULL;
        v_num_item NUMBER ( 3 );
        cont_item NUMBER ( 3 );
        v_uf CHAR;
        v_vlr_base_iss_2 NUMBER ( 17, 2 ) := 0;
        v_vlr_base_iss_3 NUMBER ( 17, 2 ) := 0;
        v_aliq_tributo_iss NUMBER ( 3 ) := 0;
        v_base NUMBER ( 17, 2 ) := 0;

        ----------------------------------------------------------------------------------------------
        -- documentos recebidos
        CURSOR c3 ( ccd_estab VARCHAR2
                  , pdat_ini DATE
                  , pdat_fim DATE
                  , ccd_tipo VARCHAR2 )
        IS
            SELECT   LPAD ( SUBSTR ( TO_NUMBER ( dwt07.num_docfis
                                               , 999999999 )
                                   , 1
                                   , 6 )
                          , 6
                          , 0 )
                         num_docfis
                   , RPAD ( dwt07.serie_docfis
                          , 3
                          , ' ' )
                         serie_docfis
                   , TO_CHAR ( dwt07.data_fiscal
                             , 'DDMMYYYY' )
                         data_fiscal
                   , TO_CHAR ( dwt07.data_emissao
                             , 'DDMMYYYY' )
                         data_emissao
                   , dwt07.cod_class_doc_fis class_docfis
                   , SUBSTR ( det1.valor
                            , 1
                            , 2 )
                         especie
                   , '1' situacao
                   , SUM ( NVL ( dwt09.vlr_servico, 0 ) ) vlr_servico
                   , NVL ( dwt09.aliq_tributo_iss, 0 ) aliq_tributo_iss
                   , LPAD ( x04pfj.cpf_cgc
                          , 14
                          , '0' )
                         cpf_cgc
                   , LENGTH ( x04pfj.cpf_cgc ) tam_cgc
                   , RPAD ( x04pfj.cpf_cgc
                          , 14
                          , 'x' )
                         cpf_cgc_aux
                   , x04pfj.insc_municipal
                   , estad.cod_estado uf
                   , x04pfj.cod_fis_jur
                   , SUM ( NVL ( dwt09.vlr_tributo_iss, 0 ) ) vlr_tributo_iss
                   , SUM ( NVL ( dwt09.vlr_base_iss_1, 0 ) ) vlr_base_iss_1
                   , SUM ( NVL ( dwt09.vlr_base_iss_2, 0 ) ) vlr_base_iss_2
                   , SUM ( NVL ( dwt09.vlr_base_iss_3, 0 ) ) vlr_base_iss_3
                   , SUM ( NVL ( dwt09.vlr_desconto, 0 ) ) desconto
                   , SUM ( NVL ( dwt07.vlr_tom_servico, 0 ) ) vlr_tom_servico
                   , NVL ( dwt07.vlr_tot_nota, 0 ) vlr_tot_nota
                   , dwt07.vlr_tributo_iss vlr_tributo_iss07
                   , MAX ( x2005.valid_docto )
                   , 'SERV' cod_servico
                FROM dwt_docto_fiscal dwt07
                   , dwt_itens_serv dwt09
                   , x04_pessoa_fis_jur x04pfj
                   , estado estad
                   , x2005_tipo_docto x2005
                   , grupo_estab grup
                   , fpar_param_det det1
                   , fpar_parametros param
                   , fpar_param_estab festab
               WHERE dwt07.cod_empresa = dwt09.cod_empresa
                 AND dwt07.cod_estab = dwt09.cod_estab
                 AND dwt07.data_fiscal = dwt09.data_fiscal
                 AND dwt07.movto_e_s = dwt09.movto_e_s
                 AND dwt07.norm_dev = dwt09.norm_dev
                 AND dwt07.ident_docto_fiscal = dwt09.ident_docto_fiscal
                 AND dwt07.ident_fis_jur = dwt09.ident_fis_jur
                 AND dwt07.num_docfis = dwt09.num_docfis
                 AND dwt07.serie_docfis = dwt09.serie_docfis
                 AND dwt07.sub_serie_docfis = dwt09.sub_serie_docfis
                 AND dwt07.ident_fis_jur = x04pfj.ident_fis_jur
                 AND x04pfj.ident_estado = estad.ident_estado
                 AND x04pfj.grupo_fis_jur = grup.grupo_estab
                 AND x2005.grupo_docto = grup.grupo_estab
                 AND dwt07.ident_docto = x2005.ident_docto
                 AND det1.id_parametro = param.id_parametros
                 AND param.id_parametros = festab.id_parametros
                 AND dwt07.cod_empresa = festab.cod_empresa
                 AND dwt07.cod_estab = festab.cod_estab
                 AND festab.cod_empresa = dwt07.cod_empresa
                 AND det1.nome_param = 'Especie'
                 AND det1.conteudo = x2005.cod_docto
                 AND dwt07.cod_class_doc_fis IN ( '2'
                                                , '3' )
                 AND dwt07.situacao = 'N'
                 AND dwt07.cod_empresa = mcod_empresa
                 AND dwt07.cod_estab = ccd_estab
                 AND dwt07.movto_e_s <> '9'
                 AND dwt07.movto_e_s = DECODE ( ccd_tipo,  3, '1',  1, '1',  '' )
                 AND dwt07.data_emissao BETWEEN pdat_ini AND pdat_fim
                 AND x2005.valid_docto = (SELECT f.valid_docto
                                            FROM x2005_tipo_docto f
                                           WHERE dwt07.ident_docto = f.ident_docto
                                             AND det1.conteudo = f.cod_docto)
            GROUP BY LPAD ( SUBSTR ( TO_NUMBER ( dwt07.num_docfis
                                               , 999999999 )
                                   , 1
                                   , 6 )
                          , 6
                          , 0 )
                   , RPAD ( dwt07.serie_docfis
                          , 3
                          , ' ' )
                   , TO_CHAR ( dwt07.data_fiscal
                             , 'DDMMYYYY' )
                   , TO_CHAR ( dwt07.data_emissao
                             , 'DDMMYYYY' )
                   , dwt07.cod_class_doc_fis
                   , SUBSTR ( det1.valor
                            , 1
                            , 2 )
                   , NVL ( dwt09.aliq_tributo_iss, 0 )
                   , LPAD ( x04pfj.cpf_cgc
                          , 14
                          , '0' )
                   , LENGTH ( x04pfj.cpf_cgc )
                   , RPAD ( x04pfj.cpf_cgc
                          , 14
                          , 'x' )
                   , x04pfj.insc_municipal
                   , estad.cod_estado
                   , x04pfj.cod_fis_jur
                   , NVL ( dwt07.vlr_tot_nota, 0 )
                   , dwt07.vlr_tributo_iss
            UNION
            SELECT   LPAD ( SUBSTR ( TO_NUMBER ( dwt07.num_docfis
                                               , 999999999 )
                                   , 1
                                   , 6 )
                          , 6
                          , 0 )
                         num_docfis
                   , RPAD ( dwt07.serie_docfis
                          , 3
                          , ' ' )
                         serie_docfis
                   , TO_CHAR ( dwt07.data_fiscal
                             , 'DDMMYYYY' )
                         data_fiscal
                   , TO_CHAR ( dwt07.data_emissao
                             , 'DDMMYYYY' )
                         data_emissao
                   , dwt07.cod_class_doc_fis class_docfis
                   , SUBSTR ( det1.valor
                            , 1
                            , 2 )
                         especie
                   , '1' situacao
                   , NULL vlr_servico
                   , NVL ( dwt07.aliq_tributo_iss, 0 ) aliq_tributo_iss
                   , LPAD ( x04pfj.cpf_cgc
                          , 14
                          , '0' )
                         cpf_cgc
                   , LENGTH ( x04pfj.cpf_cgc ) tam_cgc
                   , RPAD ( x04pfj.cpf_cgc
                          , 14
                          , 'x' )
                         cpf_cgc_aux
                   , x04pfj.insc_municipal
                   , estad.cod_estado uf
                   , x04pfj.cod_fis_jur
                   , NULL vlr_tributo_iss
                   , NULL vlr_base_iss_1
                   , NULL vlr_base_iss_2
                   , NULL vlr_base_iss_3
                   , NULL desconto
                   , SUM ( NVL ( dwt07.vlr_tom_servico, 0 ) ) vlr_tom_servico
                   , NVL ( dwt07.vlr_tot_nota, 0 ) vlr_tot_nota
                   , dwt07.vlr_tributo_iss vlr_tributo_iss07
                   , MAX ( x2005.valid_docto )
                   , 'SEM IT' cod_servico
                FROM dwt_docto_fiscal dwt07
                   , x04_pessoa_fis_jur x04pfj
                   , estado estad
                   , x2005_tipo_docto x2005
                   , grupo_estab grup
                   , fpar_param_det det1
                   , fpar_parametros param
                   , fpar_param_estab festab
               WHERE dwt07.ident_fis_jur = x04pfj.ident_fis_jur
                 AND x04pfj.ident_estado = estad.ident_estado
                 AND x04pfj.grupo_fis_jur = grup.grupo_estab
                 AND x2005.grupo_docto = grup.grupo_estab
                 AND dwt07.ident_docto = x2005.ident_docto
                 AND det1.id_parametro = param.id_parametros
                 AND param.id_parametros = festab.id_parametros
                 AND dwt07.cod_empresa = festab.cod_empresa
                 AND dwt07.cod_estab = festab.cod_estab
                 AND festab.cod_empresa = dwt07.cod_empresa
                 AND det1.nome_param = 'Especie'
                 AND det1.conteudo = x2005.cod_docto
                 AND dwt07.cod_class_doc_fis IN ( '2'
                                                , '3' )
                 AND dwt07.situacao = 'N'
                 AND dwt07.cod_empresa = mcod_empresa
                 AND dwt07.cod_estab = ccd_estab
                 AND dwt07.movto_e_s <> '9'
                 AND dwt07.movto_e_s = DECODE ( ccd_tipo,  3, '1',  1, '1',  '' )
                 AND dwt07.data_emissao BETWEEN pdat_ini AND pdat_fim
                 AND x2005.valid_docto = (SELECT f.valid_docto
                                            FROM x2005_tipo_docto f
                                           WHERE dwt07.ident_docto = f.ident_docto
                                             AND det1.conteudo = f.cod_docto)
                 AND NOT EXISTS
                         (SELECT 1
                            FROM dwt_itens_serv dwt09
                           WHERE dwt07.cod_empresa = dwt09.cod_empresa
                             AND dwt07.cod_estab = dwt09.cod_estab
                             AND dwt07.data_fiscal = dwt09.data_fiscal
                             AND dwt07.movto_e_s = dwt09.movto_e_s
                             AND dwt07.norm_dev = dwt09.norm_dev
                             AND dwt07.ident_docto_fiscal = dwt09.ident_docto_fiscal
                             AND dwt07.ident_fis_jur = dwt09.ident_fis_jur
                             AND dwt07.num_docfis = dwt09.num_docfis
                             AND dwt07.serie_docfis = dwt09.serie_docfis
                             AND dwt07.sub_serie_docfis = dwt09.sub_serie_docfis)
            GROUP BY LPAD ( SUBSTR ( TO_NUMBER ( dwt07.num_docfis
                                               , 999999999 )
                                   , 1
                                   , 6 )
                          , 6
                          , 0 )
                   , RPAD ( dwt07.serie_docfis
                          , 3
                          , ' ' )
                   , TO_CHAR ( dwt07.data_fiscal
                             , 'DDMMYYYY' )
                   , TO_CHAR ( dwt07.data_emissao
                             , 'DDMMYYYY' )
                   , dwt07.cod_class_doc_fis
                   , SUBSTR ( det1.valor
                            , 1
                            , 2 )
                   , NVL ( dwt07.aliq_tributo_iss, 0 )
                   , LPAD ( x04pfj.cpf_cgc
                          , 14
                          , '0' )
                   , LENGTH ( x04pfj.cpf_cgc )
                   , RPAD ( x04pfj.cpf_cgc
                          , 14
                          , 'x' )
                   , x04pfj.insc_municipal
                   , estad.cod_estado
                   , x04pfj.cod_fis_jur
                   , NVL ( dwt07.vlr_tot_nota, 0 )
                   , dwt07.vlr_tributo_iss;



        -- Inicio Cr02 documentos emitidos
        CURSOR c2 ( ccd_estab VARCHAR2
                  , pdat_ini DATE
                  , pdat_fim DATE
                  , ccd_tipo VARCHAR2 )
        IS
            SELECT   dwt07.cod_empresa
                   , dwt07.cod_estab
                   , dwt07.ident_fis_jur
                   , dwt07.sub_serie_docfis
                   , dwt07.norm_dev
                   , LPAD ( SUBSTR ( TO_NUMBER ( dwt07.num_docfis
                                               , 999999999 )
                                   , 1
                                   , 6 )
                          , 6
                          , 0 )
                         num_docfis
                   , RPAD ( dwt07.serie_docfis
                          , 3
                          , ' ' )
                         serie_docfis
                   , TO_CHAR ( dwt07.data_fiscal
                             , 'DDMMYYYY' )
                         data_fiscal
                   , TO_CHAR ( dwt07.data_emissao
                             , 'DDMMYYYY' )
                         data_emissao
                   , dwt07.cod_class_doc_fis class_docfis
                   , SUBSTR ( det1.valor
                            , 1
                            , 2 )
                         especie
                   , SUBSTR ( det1.valor
                            , 3
                            , 1 )
                         agrup
                   , dwt07.situacao situacao
                   , SUM ( NVL ( dwt09.vlr_servico, 0 ) ) vlr_servico
                   , NVL ( dwt09.aliq_tributo_iss, 0 ) aliq_tributo_iss
                   , NULL
                   , LPAD ( x04pfj.cpf_cgc
                          , 14
                          , '0' )
                         cpf_cgc
                   , LENGTH ( x04pfj.cpf_cgc ) tam_cgc
                   , estad.cod_estado uf
                   , x04pfj.cod_fis_jur
                   , SUM ( NVL ( dwt09.vlr_tributo_iss, 0 ) ) vlr_tributo_iss
                   , SUM ( NVL ( dwt09.vlr_base_iss_1, 0 ) ) vlr_base_iss_1
                   , SUM ( NVL ( dwt09.vlr_base_iss_2, 0 ) ) vlr_base_iss_2
                   , SUM ( NVL ( dwt09.vlr_base_iss_3, 0 ) ) vlr_base_iss_3
                   , NULL vlr_base_iss_1_07
                   , SUM ( NVL ( dwt09.vlr_desconto, 0 ) ) desconto
                   , SUBSTR ( det.valor
                            , 1
                            , 6 )
                         cod_servico
                   , SUBSTR ( NVL ( dwt07.num_ctr_disp, 0 )
                            , 1
                            , 6 )
                         num_ini_controle
                   , SUBSTR ( NVL ( dwt07.num_final_crt_disp, 0 )
                            , 1
                            , 6 )
                         num_final_controle
                   , dwt07.nro_aidf_nf nro_aidf_nf
                   , NVL ( dwt07.vlr_tot_nota, 0 ) vlr_tot_nota
                   , SUM ( NVL ( dwt07.vlr_tom_servico, 0 ) ) vlr_tom_servico
                   , NULL vlr_tributo_iss07
                   , dwt07.movto_e_s movto_e_s
                   , LPAD ( TO_CHAR ( dwt07.dat_cancelamento
                                    , 'DDMMYYYY' )
                          , 8
                          , '0' )
                         dat_cancelamento
                   , dwt07.num_docfis_ref num_docfis_ref
                   , TO_CHAR ( dwt07.dat_di
                             , 'DDMMYYYY' )
                         data_docfis_ref
                   , dwt07.obs_compl_motivo obs_compl
                FROM dwt_docto_fiscal dwt07
                   , dwt_itens_serv dwt09
                   , x04_pessoa_fis_jur x04pfj
                   , x2018_servicos x2018
                   , estado estad
                   , x2005_tipo_docto x2005
                   , grupo_estab grup
                   , fpar_param_det det
                   , fpar_param_det det1
                   , fpar_parametros param
                   , fpar_param_estab festab
               WHERE dwt07.cod_empresa = dwt09.cod_empresa
                 AND dwt07.cod_estab = dwt09.cod_estab
                 AND dwt07.data_fiscal = dwt09.data_fiscal
                 AND dwt07.movto_e_s = dwt09.movto_e_s
                 AND dwt07.norm_dev = dwt09.norm_dev
                 AND dwt07.ident_docto_fiscal = dwt09.ident_docto_fiscal
                 AND dwt07.ident_fis_jur = dwt09.ident_fis_jur
                 AND dwt07.num_docfis = dwt09.num_docfis
                 AND dwt07.serie_docfis = dwt09.serie_docfis
                 AND dwt07.sub_serie_docfis = dwt09.sub_serie_docfis
                 AND dwt07.cod_class_doc_fis IN ( '2'
                                                , '3' )
                 AND dwt07.ident_fis_jur = x04pfj.ident_fis_jur
                 AND dwt09.ident_servico = x2018.ident_servico
                 AND x04pfj.ident_estado = estad.ident_estado
                 AND dwt07.ident_docto = x2005.ident_docto
                 AND det.id_parametro = param.id_parametros
                 AND det1.id_parametro = param.id_parametros
                 AND param.id_parametros = festab.id_parametros
                 AND dwt07.cod_empresa = festab.cod_empresa
                 AND dwt07.cod_estab = festab.cod_estab
                 AND x04pfj.grupo_fis_jur = grup.grupo_estab
                 AND x2018.grupo_servico = grup.grupo_estab
                 AND x2005.grupo_docto = grup.grupo_estab
                 AND det.nome_param = 'Serviço'
                 AND festab.cod_empresa = dwt07.cod_empresa
                 AND det1.nome_param = 'Especie'
                 AND det.conteudo = x2018.cod_servico
                 AND det1.conteudo = x2005.cod_docto
                 AND x2018.valid_servico = (SELECT t.valid_servico
                                              FROM x2018_servicos t
                                             WHERE dwt09.ident_servico = t.ident_servico
                                               AND det.conteudo = t.cod_servico)
                 AND x2005.valid_docto = (SELECT f.valid_docto
                                            FROM x2005_tipo_docto f
                                           WHERE dwt07.ident_docto = f.ident_docto
                                             AND det1.conteudo = f.cod_docto)
                 AND dwt07.cod_empresa = mcod_empresa
                 AND dwt07.cod_estab = ccd_estab
                 AND dwt07.movto_e_s = DECODE ( ccd_tipo,  3, '9',  2, '9',  '' )
                 AND TO_CHAR ( dwt07.data_emissao
                             , 'DD/MM/YYYY' ) BETWEEN pdat_ini
                                                  AND pdat_fim
            GROUP BY dwt07.cod_empresa
                   , dwt07.cod_estab
                   , dwt07.ident_fis_jur
                   , dwt07.sub_serie_docfis
                   , dwt07.norm_dev
                   , x2018.cod_servico
                   , LPAD ( SUBSTR ( TO_NUMBER ( dwt07.num_docfis
                                               , 999999999 )
                                   , 1
                                   , 6 )
                          , 6
                          , 0 )
                   , TO_CHAR ( dwt07.data_emissao
                             , 'DDMMYYYY' )
                   , dwt07.serie_docfis
                   , x04pfj.cpf_cgc
                   , dwt07.situacao
                   , dwt07.data_fiscal
                   , estad.cod_estado
                   , NVL ( dwt09.aliq_tributo_iss, 0 )
                   , x04pfj.cod_fis_jur
                   , SUBSTR ( det1.valor
                            , 1
                            , 2 )
                   , dwt07.cod_class_doc_fis
                   , LENGTH ( x04pfj.cpf_cgc )
                   , dwt07.data_fiscal
                   , SUBSTR ( det.valor
                            , 1
                            , 6 )
                   , dwt07.num_controle_docto
                   , SUBSTR ( NVL ( dwt07.num_ctr_disp, 0 )
                            , 1
                            , 6 )
                   , SUBSTR ( NVL ( dwt07.num_final_crt_disp, 0 )
                            , 1
                            , 6 )
                   , dwt07.nro_aidf_nf
                   , dwt07.movto_e_s
                   , dwt07.vlr_tot_nota
                   , LPAD ( TO_CHAR ( dwt07.dat_cancelamento
                                    , 'DDMMYYYY' )
                          , 8
                          , '0' )
                   , SUBSTR ( det1.valor
                            , 3
                            , 1 )
                   , dwt07.num_docfis_ref
                   , TO_CHAR ( dwt07.dat_di
                             , 'DDMMYYYY' )
                   , dwt07.obs_compl_motivo
            UNION
            -- documentos fiscais emitidos sem itens
            SELECT   dwt07.cod_empresa
                   , dwt07.cod_estab
                   , dwt07.ident_fis_jur
                   , dwt07.sub_serie_docfis
                   , dwt07.norm_dev
                   , LPAD ( SUBSTR ( TO_NUMBER ( dwt07.num_docfis
                                               , 999999999 )
                                   , 1
                                   , 6 )
                          , 6
                          , 0 )
                         num_docfis
                   , RPAD ( dwt07.serie_docfis
                          , 3
                          , ' ' )
                         serie_docfis
                   , TO_CHAR ( dwt07.data_emissao
                             , 'DDMMYYYY' )
                         data_emissao
                   , TO_CHAR ( dwt07.data_fiscal
                             , 'DDMMYYYY' )
                         data_fiscal
                   , dwt07.cod_class_doc_fis class_docfis
                   , SUBSTR ( det1.valor
                            , 1
                            , 2 )
                         especie
                   , SUBSTR ( det1.valor
                            , 3
                            , 1 )
                         agrup
                   , dwt07.situacao situacao
                   , NULL
                   , dwt07.aliq_tributo_iss aliq_tributo_iss
                   , NULL --x2018.cod_servico
                   , LPAD ( x04pfj.cpf_cgc
                          , 14
                          , '0' )
                         cpf_cgc
                   , LENGTH ( x04pfj.cpf_cgc ) tam_cgc
                   , estad.cod_estado uf
                   , x04pfj.cod_fis_jur
                   , NULL --dwt09.vlr_tributo_iss                                            tributo_iss
                   , NULL --dwt09.vlr_base_iss_1
                   , NULL --dwt09.vlr_base_iss_2
                   , NULL --dwt09.vlr_base_iss_3
                   , NVL ( dwt07.vlr_base_iss_1, 0 ) vlr_base_iss_1_07
                   , NULL
                   , 'SEM IT' cod_servico
                   , SUBSTR ( NVL ( dwt07.num_ctr_disp, 0 )
                            , 1
                            , 6 )
                         num_ini_controle
                   , SUBSTR ( NVL ( dwt07.num_final_crt_disp, 0 )
                            , 1
                            , 6 )
                         num_final_controle
                   , dwt07.nro_aidf_nf nro_aidf_nf
                   , NVL ( dwt07.vlr_tot_nota, 0 ) vlr_tot_nota
                   , SUM ( NVL ( dwt07.vlr_tom_servico, 0 ) ) vlr_tom_servico
                   , SUM ( NVL ( dwt07.vlr_tributo_iss, 0 ) ) vlr_tributo_iss07
                   , dwt07.movto_e_s movto_e_s
                   , LPAD ( TO_CHAR ( dwt07.dat_cancelamento
                                    , 'DDMMYYYY' )
                          , 8
                          , '0' )
                         dat_cancelamento
                   , dwt07.num_docfis_ref num_docfis_ref
                   , TO_CHAR ( dwt07.dat_di
                             , 'DDMMYYYY' )
                         data_docfis_ref
                   , dwt07.obs_compl_motivo obs_compl
                FROM dwt_docto_fiscal dwt07
                   , x2005_tipo_docto x2005
                   , x04_pessoa_fis_jur x04pfj
                   , estado estad
                   , fpar_param_det det1
                   , fpar_parametros param
                   , fpar_param_estab festab
                   , grupo_estab grup
               WHERE x2005.ident_docto = dwt07.ident_docto
                 AND x04pfj.ident_estado = estad.ident_estado
                 AND cod_class_doc_fis IN ( '2'
                                          , '3' )
                 AND det1.id_parametro = param.id_parametros
                 AND param.id_parametros = festab.id_parametros
                 AND det1.conteudo = x2005.cod_docto
                 AND dwt07.cod_empresa = festab.cod_empresa
                 AND dwt07.cod_estab = festab.cod_estab
                 AND x04pfj.grupo_fis_jur = grup.grupo_estab
                 AND x2005.grupo_docto = grup.grupo_estab
                 AND x04pfj.ident_fis_jur = dwt07.ident_fis_jur
                 AND x2005.valid_docto = (SELECT f.valid_docto
                                            FROM x2005_tipo_docto f
                                           WHERE dwt07.ident_docto = f.ident_docto
                                             AND det1.conteudo = f.cod_docto)
                 AND dwt07.cod_empresa = mcod_empresa
                 AND dwt07.cod_estab = ccd_estab
                 AND TO_CHAR ( dwt07.data_emissao
                             , 'DD/MM/YYYY' ) BETWEEN pdat_ini
                                                  AND pdat_fim
                 AND dwt07.movto_e_s = DECODE ( ccd_tipo,  3, '9',  2, '9',  '' )
                 AND det1.nome_param = 'Especie'
                 AND NOT EXISTS
                         (SELECT 1
                            FROM dwt_itens_serv dwt09
                           WHERE dwt07.cod_empresa = dwt09.cod_empresa
                             AND dwt07.cod_estab = dwt09.cod_estab
                             AND dwt07.data_fiscal = dwt09.data_fiscal
                             AND dwt07.movto_e_s = dwt09.movto_e_s
                             AND dwt07.norm_dev = dwt09.norm_dev
                             AND dwt07.ident_docto_fiscal = dwt09.ident_docto_fiscal
                             AND dwt07.ident_fis_jur = dwt09.ident_fis_jur
                             AND dwt07.num_docfis = dwt09.num_docfis
                             AND dwt07.serie_docfis = dwt09.serie_docfis
                             AND dwt07.sub_serie_docfis = dwt09.sub_serie_docfis)
            GROUP BY dwt07.cod_empresa
                   , dwt07.cod_estab
                   , dwt07.ident_fis_jur
                   , dwt07.sub_serie_docfis
                   , dwt07.norm_dev
                   , dwt07.num_docfis
                   , TO_CHAR ( dwt07.data_emissao
                             , 'DDMMYYYY' )
                   , x2005.cod_docto
                   , dwt07.serie_docfis
                   , x04pfj.cpf_cgc
                   , dwt07.situacao
                   , dwt07.data_fiscal
                   , dwt07.movto_e_s
                   , dwt07.cod_class_doc_fis
                   , estad.cod_estado
                   , x04pfj.cod_fis_jur
                   , dwt07.aliq_tributo_iss
                   , LENGTH ( x04pfj.cpf_cgc )
                   , dwt07.data_fiscal
                   , dwt07.vlr_base_iss_1
                   , dwt07.num_controle_docto
                   , SUBSTR ( NVL ( dwt07.num_ctr_disp, 0 )
                            , 1
                            , 6 )
                   , SUBSTR ( NVL ( dwt07.num_final_crt_disp, 0 )
                            , 1
                            , 6 )
                   , dwt07.nro_aidf_nf
                   , dwt07.movto_e_s
                   , SUBSTR ( det1.valor
                            , 1
                            , 2 )
                   , dwt07.vlr_tot_nota
                   , LPAD ( TO_CHAR ( dwt07.dat_cancelamento
                                    , 'DDMMYYYY' )
                          , 8
                          , '0' )
                   , SUBSTR ( det1.valor
                            , 3
                            , 1 )
                   , dwt07.num_docfis_ref
                   , TO_CHAR ( dwt07.dat_di
                             , 'DDMMYYYY' )
                   , dwt07.obs_compl_motivo
            ORDER BY data_emissao
                   , 6
                   , especie
                   , 4
                   , cpf_cgc
                   , situacao;
    -- Fim Cr02



    BEGIN
        BEGIN
            SELECT LPAD ( NVL ( insc_municipal, '0' )
                        , 8
                        , '0' )
              INTO v_insc_municipal
              FROM estabelecimento
             WHERE cod_estab = pcd_estab
               AND cod_empresa = mcod_empresa;
        EXCEPTION
            WHEN OTHERS THEN
                v_insc_municipal := NULL;
        END;

        BEGIN
            pdat_ini := pdt_comp;
            pdat_fim := LAST_DAY ( pdat_ini );
        END;

        -- Cria Processo
        mproc_id :=
            lib_proc.new ( 'MSAF_DIEF_RJ_CPROC'
                         , 48
                         , 150 );
        lib_proc.add_tipo ( mproc_id
                          , 1
                          , 'DIEF-RIO' || pcd_estab
                          , 2 );
        lib_proc.add_log ( 'Processo ' || mproc_id
                         , 1 );

        --Registro 01 header ---

        mlinha := NULL;
        mlinha :=
            lib_str.w ( mlinha
                      , '01'
                      , 1 ); -- Tipo de Registro
        mlinha :=
            lib_str.w ( mlinha
                      , v_insc_municipal
                      , 3 );
        mlinha :=
            lib_str.w ( mlinha
                      , TO_CHAR ( pdt_comp
                                , 'YYYY' )
                      , 11 );
        mlinha :=
            lib_str.w ( mlinha
                      , TO_CHAR ( pdt_comp
                                , 'MM' )
                      , 15 );
        lib_proc.add ( mlinha
                     , NULL
                     , NULL
                     , 1 );

        count_reg := count_reg + 1;

        -- REGISTRO 02 - nf normal Serviços Emitidos - Linha de registro da tabela de Documentos Fiscais Emitidos

        FOR mreg IN c2 ( pcd_estab
                       , pdat_ini
                       , pdat_fim
                       , ptp_docto ) LOOP
            IF mreg.movto_e_s = '9' THEN
                -- tratamento das notas agrupadas registro 02
                IF mreg.especie IN ( '4'
                                   , '7'
                                   , '13' )
                OR ( mreg.especie IN ( '11'
                                     , '12'
                                     , '14'
                                     , '15' )
                AND mreg.tam_cgc = 11 ) THEN
                    IF ( v_nota_ant = 0 )
                    OR ( ( v_nota_ant + 1 ) = mreg.num_docfis ) THEN
                        IF mreg.cod_servico = 'SEM IT' THEN
                            v_item := '2';
                        ELSE
                            v_item := '1';
                        END IF;

                        IF mreg.nro_aidf_nf IS NOT NULL THEN
                            BEGIN
                                SELECT LPAD ( valor
                                            , 12
                                            , '0' )
                                  INTO v_nro_aidf_nf
                                  FROM dwt_docto_fiscal dwt07
                                     , fpar_param_det det2
                                     , fpar_parametros param
                                     , fpar_param_estab festab
                                 WHERE det2.id_parametro = param.id_parametros
                                   AND det2.conteudo = dwt07.nro_aidf_nf
                                   AND SUBSTR ( det2.nome_param
                                              , 1
                                              , 4 ) = 'AIDF'
                                   AND dwt07.cod_empresa = mreg.cod_empresa
                                   AND dwt07.cod_estab = mreg.cod_estab
                                   AND dwt07.num_docfis = mreg.num_docfis
                                   AND TO_CHAR ( dwt07.data_fiscal
                                               , 'DDMMYYYY' ) = mreg.data_fiscal
                                   AND dwt07.movto_e_s = mreg.movto_e_s
                                   AND dwt07.norm_dev = mreg.norm_dev
                                   AND dwt07.ident_fis_jur = mreg.ident_fis_jur
                                   AND dwt07.cod_empresa = festab.cod_empresa
                                   AND dwt07.cod_estab = festab.cod_estab
                                   AND param.id_parametros = festab.id_parametros;
                            EXCEPTION
                                WHEN NO_DATA_FOUND THEN
                                    lib_proc.add_log (
                                                          'Falta cadastro no De Para de AIDF - Doc = '
                                                       || mreg.num_docfis
                                                       || ' , AIDF num = '
                                                       || mreg.nro_aidf_nf
                                                     , NULL
                                    );
                                    v_nro_aidf_nf := '000000000000';
                            END;
                        ELSE
                            v_nro_aidf_nf := '000000000000';
                        END IF;

                        IF mreg.vlr_tributo_iss > 0
                        OR mreg.vlr_tributo_iss07 > 0 THEN
                            v_trib := 1;
                        ELSE
                            v_trib := '2';
                        END IF;

                        IF v_nota_ini = 0 THEN
                            v_nota_ini := mreg.num_docfis;
                        END IF;

                        v_nota_ant := mreg.num_docfis;
                        v_data_emissao := mreg.data_emissao;
                        v_cod_servico := mreg.cod_servico;
                        v_serie_docfis := mreg.serie_docfis;
                        v_cpf_cgc := mreg.cpf_cgc;
                        v_situacao := mreg.situacao;
                        v_num_ini_controle := mreg.num_ini_controle;
                        v_num_fim_controle := mreg.num_final_controle;
                        v_vlr_tot_nota := mreg.vlr_tot_nota;
                        v_vlr_base_iss_1 := mreg.vlr_base_iss_1;
                        v_vlr_servico := mreg.vlr_servico;
                        v_vlr_base_iss_1_07 := mreg.vlr_base_iss_1_07;
                        v_tomador := v_tomador;
                        v_movto_e_s := mreg.movto_e_s;
                    ELSE
                        IF mreg.tam_cgc = 14
                       AND mreg.uf <> 'EX' THEN
                            v_tomador := 2; -- 1 cgc 2 cpf
                        ELSIF mreg.tam_cgc < 14
                          AND mreg.uf <> 'EX' THEN
                            v_tomador := 1; -- 1 cgc 2 cpf
                        ELSIF mreg.uf = 'EX' THEN
                            v_tomador := 3; -- 1 cgc 2 cpf
                        ELSE
                            v_tomador := 0;
                        END IF;


                        mlinha := NULL;
                        mlinha :=
                            lib_str.w ( mlinha
                                      , '02'
                                      , 1 ); -- Tipo de Registro
                        mlinha :=
                            lib_str.w ( mlinha
                                      , mreg.data_emissao
                                      , 3 );
                        mlinha :=
                            lib_str.w ( mlinha
                                      , LPAD ( mreg.especie
                                             , 2
                                             , '0' )
                                      , 11 ); -- especie
                        mlinha :=
                            lib_str.w ( mlinha
                                      , mreg.serie_docfis
                                      , 13 );
                        mlinha :=
                            lib_str.w ( mlinha
                                      , LPAD ( v_nota_ini
                                             , 6
                                             , '0' )
                                      , 16 ); -- numero inicial docto
                        mlinha :=
                            lib_str.w ( mlinha
                                      , LPAD ( v_nota_ant
                                             , 6
                                             , '0' )
                                      , 22 ); -- numero final docto
                        mlinha :=
                            lib_str.w ( mlinha
                                      , LPAD ( mreg.num_ini_controle
                                             , 6
                                             , '0' )
                                      , 28 ); -- numero inicial formulario
                        mlinha :=
                            lib_str.w ( mlinha
                                      , LPAD ( mreg.num_final_controle
                                             , 6
                                             , '0' )
                                      , 34 ); -- numero final formulario
                        mlinha :=
                            lib_str.w ( mlinha
                                      , v_tomador
                                      , 40 ); -- tipo tomador
                        mlinha :=
                            lib_str.w ( mlinha
                                      , mreg.cpf_cgc
                                      , 41 ); -- CPF/CNPJ do Tomador
                        mlinha :=
                            lib_str.w ( mlinha
                                      , LPAD ( v_nro_aidf_nf
                                             , 12
                                             , '0' )
                                      , 55 ); -- Identificador da Autorização AIDF
                        mlinha :=
                            lib_str.w ( mlinha
                                      , v_item
                                      , 67 );
                        mlinha :=
                            lib_str.w ( mlinha
                                      , v_trib
                                      , 68 );
                        lib_proc.add ( mlinha
                                     , NULL
                                     , NULL
                                     , 1 );

                        count_reg := count_reg + 1;
                        v_nro_aidf_nf := NULL;
                    END IF;

                    -- tratamento dos itens com intervalo registro 03
                    IF ( v_aliq_ant = 0 )
                    OR ( v_aliq_ant = mreg.aliq_tributo_iss )
                   AND ( v_cod_servico_ant = 0 )
                    OR ( v_cod_servico_ant = mreg.cod_servico ) THEN
                        IF mreg.vlr_base_iss_2 > 0 THEN
                            v_aliq := '06'; -- identificador aliquota mreg.ind_aliquota
                        ELSIF mreg.vlr_base_iss_3 > 0 THEN
                            v_aliq := '05';
                        ELSIF ( mreg.aliq_tributo_iss * 100 ) = '5' THEN
                            v_aliq := '01';
                        ELSIF mreg.aliq_tributo_iss = '2' THEN
                            v_aliq := '02';
                        ELSIF mreg.aliq_tributo_iss = '3' THEN
                            v_aliq := '03';
                        ELSIF mreg.aliq_tributo_iss = '5' THEN
                            v_aliq := '04';
                        END IF;

                        v_cod_servico_ant := mreg.cod_servico;
                        v_aliq_ant := mreg.aliq_tributo_iss;
                        v_nota_ant := mreg.num_docfis;
                        v_cod_servico := mreg.cod_servico;
                        v_vlr_servico := v_vlr_servico + mreg.vlr_servico;
                        v_desconto := v_desconto + mreg.desconto;
                        v_vlr_tributo_iss := v_vlr_tributo_iss + mreg.vlr_tributo_iss;
                    ELSE
                        mlinha := NULL;
                        mlinha :=
                            lib_str.w ( mlinha
                                      , '03'
                                      , 1 ); -- Tipo de Registro
                        mlinha :=
                            lib_str.w ( mlinha
                                      , v_cod_servico
                                      , 3 ); -- cod servico de/para
                        mlinha :=
                            lib_str.w ( mlinha
                                      , LPAD ( v_aliq
                                             , 2
                                             , '0' )
                                      , 9 ); -- identificador aliquota mreg.ind_aliquota
                        mlinha :=
                            lib_str.w ( mlinha
                                      , LPAD ( ( v_vlr_servico * 100 )
                                             , 14
                                             , '0' )
                                      , 11 ); -- valor dos serviços
                        mlinha :=
                            lib_str.w ( mlinha
                                      , LPAD ( ( v_desconto * 100 )
                                             , 14
                                             , '0' )
                                      , 25 ); -- valor deducao/desconto
                        mlinha :=
                            lib_str.w ( mlinha
                                      , LPAD ( ( v_vlr_tributo_iss * 100 )
                                             , 14
                                             , '0' )
                                      , 39 ); -- valor do imposto retido
                        lib_proc.add ( mlinha
                                     , NULL
                                     , NULL
                                     , 1 );

                        v_cod_servico_ant := 0;
                        v_nota_ant := 0;
                        v_aliq_ant := 0;
                        v_nota_ini := 0;
                        v_vlr_servico := 0;
                        v_desconto := 0;
                        v_vlr_tributo_iss := 0;

                        count_reg := count_reg + 1;
                    END IF;

                    -- tratamento do registro com intervalo 04
                    IF ( v_nota_ant = 0 )
                    OR ( ( v_nota_ant + 1 ) = mreg.num_docfis ) THEN
                        IF v_aliq_ant = mreg.aliq_tributo_iss THEN
                            IF ( v_cod_servico_ant = 0 )
                            OR ( v_cod_servico_ant = mreg.cod_servico ) THEN
                                IF v_nota_ini = 0 THEN
                                    v_nota_ini := mreg.num_docfis;
                                END IF;

                                IF mreg.cod_servico = 'SEM IT'
                               AND mreg.class_docfis = 2 THEN
                                    v_tot_base := v_tot_base + mreg.vlr_base_iss_1_07;
                                    v_tot_serv := v_tot_serv + mreg.vlr_tot_nota;
                                ELSIF mreg.cod_servico = 'SEM IT'
                                  AND mreg.class_docfis = 3 THEN
                                    v_tot_base := v_tot_base + mreg.vlr_base_iss_1_07;
                                    v_tot_serv := v_tot_serv + mreg.vlr_tom_servico;
                                ELSIF mreg.cod_servico <> 'SEM IT' THEN
                                    v_tot_base := v_tot_base + mreg.vlr_base_iss_1;
                                    v_tot_serv := v_tot_serv + mreg.vlr_servico;
                                END IF;


                                v_cod_servico_ant := mreg.cod_servico;
                                v_aliq_ant := mreg.aliq_tributo_iss;
                                v_nota_ant := mreg.num_docfis;
                            END IF;
                        END IF;
                    ELSE
                        mlinha := NULL;
                        mlinha :=
                            lib_str.w ( mlinha
                                      , '04'
                                      , 1 ); -- Tipo de Registro
                        mlinha :=
                            lib_str.w ( mlinha
                                      , LPAD ( ( v_tot_base * 100 )
                                             , 14
                                             , '0' )
                                      , 3 ); -- Total base de ISS
                        mlinha :=
                            lib_str.w ( mlinha
                                      , LPAD ( ( v_tot_serv * 100 )
                                             , 14
                                             , '0' )
                                      , 17 ); -- valor dos serviços
                        lib_proc.add ( mlinha
                                     , NULL
                                     , NULL
                                     , 1 );


                        v_cod_servico_ant := 0;
                        v_nota_ant := 0;
                        v_aliq_ant := 0;
                        v_nota_ini := 0;

                        count_reg := count_reg + 1;
                    END IF;
                -- fim do registro 04 com intervalo

                ELSE -- carlos
                    -- tratamento do registro 02 sem intervalo

                    IF chave IS NULL
                    OR chave = mreg.num_docfis || mreg.data_fiscal || mreg.cod_fis_jur THEN
                        IF mreg.cod_servico = 'SEM IT' THEN
                            v_item := '2';
                        ELSE
                            v_item := '1';
                        END IF;

                        IF mreg.nro_aidf_nf IS NOT NULL THEN
                            BEGIN
                                SELECT LPAD ( valor
                                            , 12
                                            , '0' )
                                  INTO v_nro_aidf_nf
                                  FROM dwt_docto_fiscal dwt07
                                     , fpar_param_det det2
                                     , fpar_parametros param
                                     , fpar_param_estab festab
                                 WHERE det2.id_parametro = param.id_parametros
                                   AND det2.conteudo = dwt07.nro_aidf_nf
                                   AND SUBSTR ( det2.nome_param
                                              , 1
                                              , 4 ) = 'AIDF'
                                   AND dwt07.cod_empresa = mreg.cod_empresa
                                   AND dwt07.cod_estab = mreg.cod_estab
                                   AND dwt07.num_docfis = mreg.num_docfis
                                   AND TO_CHAR ( dwt07.data_fiscal
                                               , 'DDMMYYYY' ) = mreg.data_fiscal
                                   AND dwt07.movto_e_s = mreg.movto_e_s
                                   AND dwt07.norm_dev = mreg.norm_dev
                                   AND dwt07.ident_fis_jur = mreg.ident_fis_jur
                                   --and dwt07.serie_docfis                = mreg.serie_docfis
                                   --and dwt07.sub_serie_docfis            = mreg.sub_serie_docfis
                                   AND dwt07.cod_empresa = festab.cod_empresa
                                   AND dwt07.cod_estab = festab.cod_estab
                                   AND param.id_parametros = festab.id_parametros;
                            EXCEPTION
                                WHEN NO_DATA_FOUND THEN
                                    lib_proc.add_log (
                                                          'Falta cadastro no De Para de AIDF - Doc = '
                                                       || mreg.num_docfis
                                                       || ' , AIDF num = '
                                                       || mreg.nro_aidf_nf
                                                     , NULL
                                    );
                                    v_nro_aidf_nf := '000000000000';
                            END;
                        ELSE
                            v_nro_aidf_nf := '000000000000';
                        END IF;



                        IF mreg.vlr_tributo_iss > 0
                        OR mreg.vlr_tributo_iss07 > 0 THEN
                            v_trib := '1';
                        ELSE
                            v_trib := '2';
                        END IF;

                        IF mreg.tam_cgc = 14
                       AND mreg.uf <> 'EX' THEN
                            v_tomador := 2; -- 1 cgc 2 cpf
                        ELSIF mreg.tam_cgc < 14
                          AND mreg.uf <> 'EX' THEN
                            v_tomador := 1; -- 1 cgc 2 cpf
                        ELSIF mreg.uf = 'EX' THEN
                            v_tomador := 3; -- 1 cgc 2 cpf
                        ELSE
                            v_tomador := 0;
                        END IF;


                        v_data_emissao := mreg.data_emissao;
                        v_especie := mreg.especie;
                        v_serie_docfis := mreg.serie_docfis;
                        v_nota_ini := mreg.num_docfis;
                        v_nota_ant := 0;
                        v_cpf_cgc := mreg.cpf_cgc;
                        v_num_ini_controle := mreg.num_ini_controle;
                        v_num_fim_controle := mreg.num_final_controle;

                        mlinha := NULL;
                        mlinha :=
                            lib_str.w ( mlinha
                                      , '02'
                                      , 1 ); -- Tipo de Registro
                        mlinha :=
                            lib_str.w ( mlinha
                                      , v_data_emissao
                                      , 3 );
                        mlinha :=
                            lib_str.w ( mlinha
                                      , LPAD ( v_especie
                                             , 2
                                             , '0' )
                                      , 11 ); -- especie
                        mlinha :=
                            lib_str.w ( mlinha
                                      , v_serie_docfis
                                      , 13 );
                        mlinha :=
                            lib_str.w ( mlinha
                                      , LPAD ( v_nota_ini
                                             , 6
                                             , '0' )
                                      , 16 ); -- numero inicial docto
                        mlinha :=
                            lib_str.w ( mlinha
                                      , LPAD ( v_nota_ant
                                             , 6
                                             , '0' )
                                      , 22 ); -- numero final docto
                        mlinha :=
                            lib_str.w ( mlinha
                                      , LPAD ( v_num_ini_controle
                                             , 6
                                             , '0' )
                                      , 28 ); -- numero inicial formulario
                        mlinha :=
                            lib_str.w ( mlinha
                                      , LPAD ( v_num_fim_controle
                                             , 6
                                             , '0' )
                                      , 34 ); -- numero final formulario
                        mlinha :=
                            lib_str.w ( mlinha
                                      , v_tomador
                                      , 40 ); -- tipo tomador
                        mlinha :=
                            lib_str.w ( mlinha
                                      , v_cpf_cgc
                                      , 41 ); -- CPF/CNPJ do Tomador
                        mlinha :=
                            lib_str.w ( mlinha
                                      , LPAD ( v_nro_aidf_nf
                                             , 12
                                             , '0' )
                                      , 55 ); -- Identificador da Autorização AIDF
                        mlinha :=
                            lib_str.w ( mlinha
                                      , v_item
                                      , 67 );
                        mlinha :=
                            lib_str.w ( mlinha
                                      , v_trib
                                      , 68 );
                        lib_proc.add ( mlinha
                                     , NULL
                                     , NULL
                                     , 1 );

                        chave := /*to_char(*/
                                mreg.num_docfis || mreg.data_fiscal || mreg.cod_fis_jur /*)*/
                                                                                       ;

                        v_tomador := NULL;
                        --                      v_item               := null;
                        v_nota_ant := mreg.num_docfis;
                        v_cod_servico := 0;
                        v_nro_aidf_nf := NULL;

                        count_reg := count_reg + 1;
                    END IF;

                    -- REGISTRO 03 - nf normal Serviços Emitidos - Linha de registro da tabela de itens de Documentos Fiscais Emitidos
                    --        FOR mreg IN C2(pcd_estab, pdat_ini, pdat_fim, ptp_docto) LOOP

                    --     if mreg.agrup='S' then -- carlos

                    --dar tratamento com somatorio por codigo de servico
                    IF mreg.cod_servico <> 'SEM IT' THEN
                        BEGIN
                            SELECT   COUNT ( * )
                                   , SUBSTR ( det.valor
                                            , 1
                                            , 6 )
                                   , SUM ( dwt09.vlr_servico )
                                   , SUM ( NVL ( dwt09.vlr_tributo_iss, 0 ) )
                                   , SUM ( NVL ( dwt09.vlr_base_iss_1, 0 ) )
                                   , SUM ( NVL ( dwt09.vlr_base_iss_2, 0 ) )
                                   , SUM ( NVL ( dwt09.vlr_base_iss_3, 0 ) )
                                   , SUM ( NVL ( dwt09.vlr_desconto, 0 ) )
                                   , NVL ( dwt09.aliq_tributo_iss, 0 )
                                INTO v_num_item
                                   , v_cod_servico
                                   , v_vlr_servico
                                   , v_vlr_tributo_iss
                                   , v_vlr_base_iss_1
                                   , v_vlr_base_iss_2
                                   , v_vlr_base_iss_3
                                   , v_desconto
                                   , v_aliq_tributo_iss
                                FROM dwt_docto_fiscal dwt07
                                   , dwt_itens_serv dwt09
                                   , x04_pessoa_fis_jur x04pfj
                                   , x2018_servicos x2018
                                   , estado estad
                                   , x2005_tipo_docto x2005
                                   , fpar_param_det det
                                   , fpar_param_det det1
                                   , fpar_parametros param
                                   , fpar_param_estab festab
                               WHERE dwt07.cod_empresa = dwt09.cod_empresa
                                 AND dwt07.cod_estab = dwt09.cod_estab
                                 AND dwt07.data_fiscal = dwt09.data_fiscal
                                 AND dwt07.movto_e_s = dwt09.movto_e_s
                                 AND dwt07.norm_dev = dwt09.norm_dev
                                 AND dwt07.ident_docto_fiscal = dwt09.ident_docto_fiscal
                                 AND dwt07.ident_fis_jur = dwt09.ident_fis_jur
                                 AND dwt07.num_docfis = dwt09.num_docfis
                                 AND dwt07.serie_docfis = dwt09.serie_docfis
                                 AND dwt07.sub_serie_docfis = dwt09.sub_serie_docfis
                                 AND dwt07.cod_class_doc_fis IN ( '2'
                                                                , '3' )
                                 AND dwt07.ident_docto_fiscal = dwt09.ident_docto_fiscal
                                 AND dwt07.ident_fis_jur = x04pfj.ident_fis_jur
                                 AND dwt09.ident_servico = x2018.ident_servico
                                 AND x04pfj.ident_estado = estad.ident_estado
                                 AND dwt07.ident_docto = x2005.ident_docto
                                 AND det.id_parametro = param.id_parametros
                                 AND det1.id_parametro = param.id_parametros
                                 AND param.id_parametros = festab.id_parametros
                                 AND det.nome_param = 'Serviço'
                                 AND dwt07.cod_empresa = festab.cod_empresa
                                 AND dwt07.cod_estab = festab.cod_estab
                                 AND det1.nome_param = 'Especie'
                                 AND det.conteudo = x2018.cod_servico
                                 AND det1.conteudo = x2005.cod_docto
                                 AND dwt07.cod_empresa = mcod_empresa
                                 AND dwt07.cod_estab = pcd_estab
                                 AND dwt07.movto_e_s = '9'
                                 AND TO_CHAR ( dwt07.data_emissao
                                             , 'DD/MM/YYYY' ) BETWEEN pdat_ini
                                                                  AND pdat_fim
                                 AND /*to_char(*/
                                    dwt09.num_docfis
                                     || TO_CHAR ( dwt09.data_fiscal
                                                , 'DDMMYYYY' )
                                     || x04pfj.cod_fis_jur /*)*/
                                                          = /*to_char(*/
                                                           chave /*)*/
                            GROUP BY SUBSTR ( det.valor
                                            , 1
                                            , 6 )
                                   , NVL ( dwt09.aliq_tributo_iss, 0 );
                        EXCEPTION
                            WHEN OTHERS THEN
                                chave := NULL;
                        END;


                        IF v_vlr_base_iss_2 > 0 THEN
                            v_aliq := '06'; -- identificador aliquota mreg.ind_aliquota
                        ELSIF v_vlr_base_iss_3 > 0 THEN
                            v_aliq := '05';
                        ELSIF ( v_aliq_tributo_iss * 100 ) = '5' THEN
                            v_aliq := '01';
                        ELSIF v_aliq_tributo_iss = '2' THEN
                            v_aliq := '02';
                        ELSIF v_aliq_tributo_iss = '3' THEN
                            v_aliq := '03';
                        ELSIF v_aliq_tributo_iss = '5' THEN
                            v_aliq := '04';
                        END IF;



                        IF v_trib = '1' THEN
                            v_base := v_vlr_base_iss_1;
                            v_vlr_tributo_iss := 0;
                        END IF;

                        mlinha := NULL;
                        mlinha :=
                            lib_str.w ( mlinha
                                      , '03'
                                      , 1 ); -- Tipo de Registro
                        mlinha :=
                            lib_str.w ( mlinha
                                      , v_cod_servico
                                      , 3 ); -- cod servico de/para
                        mlinha :=
                            lib_str.w ( mlinha
                                      , LPAD ( v_aliq
                                             , 2
                                             , '0' )
                                      , 9 ); -- identificador aliquota mreg.ind_aliquota
                        mlinha :=
                            lib_str.w ( mlinha
                                      , LPAD ( ( v_vlr_servico * 100 )
                                             , 14
                                             , '0' )
                                      , 11 ); -- valor dos serviços
                        mlinha :=
                            lib_str.w ( mlinha
                                      , LPAD ( ( v_desconto * 100 )
                                             , 14
                                             , '0' )
                                      , 25 ); -- valor deducao/desconto
                        mlinha :=
                            lib_str.w ( mlinha
                                      , LPAD ( ( v_vlr_tributo_iss * 100 )
                                             , 14
                                             , '0' )
                                      , 39 ); -- valor do imposto retido
                        lib_proc.add ( mlinha
                                     , NULL
                                     , NULL
                                     , 1 );

                        count_reg := count_reg + 1;

                        v_vlr_tributo_iss := 0;
                        v_nota_ant := mreg.num_docfis;
                        chave := NULL;
                        v_vlr_base_iss_2 := 0;
                        v_vlr_base_iss_3 := 0;
                        v_aliq_tributo_iss := 0;

                        --- montagem do registro 04

                        IF v_trib = '1' THEN
                            v_tot_base := v_tot_base + v_base;
                            v_tot_serv := v_tot_serv + v_vlr_servico;
                        ELSE
                            v_tot_base := v_tot_base + v_vlr_base_iss_1; -- nesse ponto v_vlr_base_iss_1 esta zerado
                            v_tot_serv := v_tot_serv + v_vlr_servico;
                        END IF;

                        -- fim reg 04

                        -- REGISTRO 04 - nf normal Serviços Emitidos - Linha de registro com o Valor Total do Documento Fiscal Emitido

                        mlinha := NULL;
                        mlinha :=
                            lib_str.w ( mlinha
                                      , '04'
                                      , 1 ); -- Tipo de Registro
                        mlinha :=
                            lib_str.w ( mlinha
                                      , LPAD ( ( v_tot_base * 100 )
                                             , 14
                                             , '0' )
                                      , 3 ); -- Total base de ISS
                        mlinha :=
                            lib_str.w ( mlinha
                                      , LPAD ( ( v_tot_serv * 100 )
                                             , 14
                                             , '0' )
                                      , 17 ); -- valor dos serviços
                        lib_proc.add ( mlinha
                                     , NULL
                                     , NULL
                                     , 1 );

                        v_tot_serv := 0;
                        v_tot_base := 0;
                        v_trib := NULL;
                        v_vlr_servico := 0;
                        v_desconto := 0;
                        v_vlr_base_iss_1 := 0;
                        v_aliq := 0;

                        count_reg := count_reg + 1;
                    ELSE
                        -- REGISTRO 04 - Sem itens - nf normal Serviços Emitidos
                        -- Linha de registro com o Valor Total do Documento Fiscal Emitido

                        v_tot_base := mreg.vlr_base_iss_1_07;
                        v_vlr_servico := mreg.vlr_tot_nota;

                        mlinha := NULL;
                        mlinha :=
                            lib_str.w ( mlinha
                                      , '04'
                                      , 1 ); -- Tipo de Registro
                        mlinha :=
                            lib_str.w ( mlinha
                                      , LPAD ( ( v_tot_base * 100 )
                                             , 14
                                             , '0' )
                                      , 3 ); -- Total base de ISS
                        mlinha :=
                            lib_str.w ( mlinha
                                      , LPAD ( ( v_vlr_servico * 100 )
                                             , 14
                                             , '0' )
                                      , 17 ); -- valor dos serviços
                        lib_proc.add ( mlinha
                                     , NULL
                                     , NULL
                                     , 1 );

                        v_tot_serv := 0;
                        v_tot_base := 0;
                        v_trib := NULL;
                        v_vlr_servico := 0;
                        v_desconto := 0;
                        v_vlr_base_iss_1 := 0;
                        v_aliq := 0;
                        chave := NULL;

                        count_reg := count_reg + 1;
                    END IF;
                END IF;
            END IF;
        END LOOP;


        -- REGISTRO 05 -  - Linha de registro da tabela de Documentos Fiscais Recebidos
        FOR mreg IN c3 ( pcd_estab
                       , pdat_ini
                       , pdat_fim
                       , ptp_docto ) LOOP
            v_data_emissao := mreg.data_emissao;
            v_especie := mreg.especie;
            v_serie_docfis := mreg.serie_docfis;
            v_cpf_cgc := mreg.cpf_cgc;
            v_vlr_tot_nota := mreg.vlr_tot_nota;
            v_nota_ini := mreg.num_docfis;
            v_vlr_tributo_iss07 := mreg.vlr_tributo_iss07;
            v_vlr_tributo_iss := mreg.vlr_tributo_iss;

            IF mreg.cod_servico = 'SEM IT'
           AND mreg.class_docfis = '3' THEN
                v_vlr_servico := mreg.vlr_tom_servico;
            ELSE
                v_vlr_servico := mreg.vlr_servico;
            END IF;

            IF mreg.tam_cgc = 14
           AND mreg.uf <> 'EX' THEN
                v_uf := 2; -- 1 cgc 2 cpf
            ELSIF mreg.tam_cgc < 14
              AND mreg.uf <> 'EX' THEN
                v_uf := 1; -- 1 cgc 2 cpf
            ELSIF mreg.uf = 'EX' THEN
                v_uf := 3; -- 1 cgc 2 cpf
            ELSE
                v_uf := 0;
            END IF;

            mlinha := NULL;
            mlinha :=
                lib_str.w ( mlinha
                          , '05'
                          , 1 ); -- Tipo de Registro
            mlinha :=
                lib_str.w ( mlinha
                          , v_data_emissao
                          , 3 );
            mlinha :=
                lib_str.w ( mlinha
                          , LPAD ( v_especie
                                 , 2
                                 , '0' )
                          , 11 ); -- codigo do documento
            mlinha :=
                lib_str.w ( mlinha
                          , v_serie_docfis
                          , 13 );
            mlinha :=
                lib_str.w ( mlinha
                          , LPAD ( v_nota_ini
                                 , 6
                                 , 0 )
                          , 16 ); -- numero inicial docto
            mlinha :=
                lib_str.w ( mlinha
                          , v_uf
                          , 22 ); -- 1 cgc 2 cpf
            mlinha :=
                lib_str.w ( mlinha
                          , LPAD ( v_cpf_cgc
                                 , 14
                                 , 0 )
                          , 23 ); -- CPF/CNPJ do Tomador

            IF mreg.cod_servico = 'SEM IT'
           AND mreg.class_docfis = '2' THEN
                mlinha :=
                    lib_str.w ( mlinha
                              , LPAD ( ( v_vlr_tot_nota * 100 )
                                     , 14
                                     , 0 )
                              , 37 );
                mlinha :=
                    lib_str.w ( mlinha
                              , LPAD ( ( v_vlr_tot_nota * 100 )
                                     , 14
                                     , 0 )
                              , 51 ); -- valor total do docto
                mlinha :=
                    lib_str.w ( mlinha
                              , LPAD ( ( v_vlr_tributo_iss07 * 100 )
                                     , 14
                                     , 0 )
                              , 65 );
            ELSIF mreg.cod_servico = 'SEM IT'
              AND mreg.class_docfis = '3' THEN -- notas mercadoria e servico
                mlinha :=
                    lib_str.w ( mlinha
                              , LPAD ( ( mreg.vlr_tom_servico * 100 )
                                     , 14
                                     , 0 )
                              , 37 );
                mlinha :=
                    lib_str.w ( mlinha
                              , LPAD ( ( mreg.vlr_tom_servico * 100 )
                                     , 14
                                     , 0 )
                              , 51 );
                mlinha :=
                    lib_str.w ( mlinha
                              , LPAD ( ( v_vlr_tributo_iss07 * 100 )
                                     , 14
                                     , 0 )
                              , 65 );
            ELSE
                mlinha :=
                    lib_str.w ( mlinha
                              , LPAD ( ( v_vlr_servico * 100 )
                                     , 14
                                     , 0 )
                              , 37 );
                mlinha :=
                    lib_str.w ( mlinha
                              , LPAD ( ( v_vlr_tot_nota * 100 )
                                     , 14
                                     , 0 )
                              , 51 ); -- valor total do docto
                mlinha :=
                    lib_str.w ( mlinha
                              , LPAD ( ( v_vlr_tributo_iss * 100 )
                                     , 14
                                     , 0 )
                              , 65 ); -- valor do imposto retido
            END IF;

            lib_proc.add ( mlinha
                         , NULL
                         , NULL
                         , 1 );

            count_reg := count_reg + 1;


            v_data_emissao := NULL;
            v_especie := NULL;
            v_serie_docfis := NULL;
            v_cpf_cgc := NULL;
            v_vlr_tot_nota := 0;
            v_nota_ini := NULL;
            v_vlr_base_iss_1_07 := 0;
            v_vlr_tributo_iss := 0;

            v_uf := NULL;
        END LOOP;

        -- REGISTRO 08 - nf cancelada ou extraviada Servicos Tomados - Linha de registro da tabela de Documentos Fiscais Cancelados
        -- inicilaiza as variaveis
        v_cod_servico_ant := 0;
        v_nota_ant := 0;
        v_aliq_ant := 0;
        v_nota_ini := 0;

        FOR mreg IN c2 ( pcd_estab
                       , pdat_ini
                       , pdat_fim
                       , ptp_docto ) LOOP
            IF mreg.movto_e_s = '9'
           AND mreg.situacao = 'S' THEN
                IF mreg.especie IN ( '4'
                                   , '7'
                                   , '13' )
                OR ( mreg.especie IN ( '11'
                                     , '12'
                                     , '14'
                                     , '15' )
                AND mreg.tam_cgc = 11 ) THEN
                    IF ( v_nota_ant = 0 )
                    OR ( ( v_nota_ant + 1 ) = mreg.num_docfis ) THEN
                        IF v_nota_ini = 0 THEN
                            v_nota_ini := mreg.num_docfis;
                        END IF;

                        v_nota_ant := mreg.num_docfis;


                        IF mreg.cod_servico = 'SEM IT' THEN
                            v_prest_serv := '2';
                            v_vlr_tot_nota := v_vlr_tot_nota + mreg.vlr_tot_nota;
                        ELSE
                            v_prest_serv := '1';
                            v_vlr_tot_nota := v_vlr_tot_nota + mreg.vlr_servico;
                        END IF;

                        IF mreg.vlr_tributo_iss > 0
                        OR mreg.vlr_tributo_iss07 > 0 THEN
                            v_destaque := '1';
                        ELSE
                            v_destaque := '2';
                        END IF;

                        IF mreg.tam_cgc = 14
                       AND mreg.uf <> 'EX' THEN
                            v_tomador := 2; -- 1 cgc 2 cpf
                        ELSIF mreg.tam_cgc < 14
                          AND mreg.uf <> 'EX' THEN
                            v_tomador := 1; -- 1 cgc 2 cpf
                        ELSIF mreg.uf = 'EX' THEN
                            v_tomador := 3; -- 1 cgc 2 cpf
                        ELSE
                            v_tomador := 0;
                        END IF;

                        IF mreg.num_docfis_ref IS NULL THEN
                            v_situacao := 4;
                        ELSE
                            v_situacao := 5;
                        END IF;

                        IF mreg.dat_cancelamento IS NULL THEN
                            v_data_cancelamento := '00000000';
                        ELSE
                            v_data_cancelamento := mreg.dat_cancelamento;
                        END IF;

                        v_data_emissao := mreg.data_emissao;
                        v_cod_servico := mreg.cod_servico;
                        v_serie_docfis := mreg.serie_docfis;
                        v_cpf_cgc := mreg.cpf_cgc;
                        v_num_ini_controle := mreg.num_ini_controle;
                        v_num_fim_controle := mreg.num_final_controle;
                        v_nro_aidf_nf := mreg.nro_aidf_nf;
                        v_movto_e_s := mreg.movto_e_s;
                        v_num_docfis_ref := mreg.num_docfis_ref;
                        v_data_docfis_ref := mreg.data_docfis_ref;
                        v_obs_compl := mreg.obs_compl;
                        v_especie := mreg.especie;
                    ELSE
                        mlinha := NULL;
                        mlinha :=
                            lib_str.w ( mlinha
                                      , '08'
                                      , 1 ); -- Tipo de Registro
                        mlinha :=
                            lib_str.w ( mlinha
                                      , v_data_emissao
                                      , 3 );
                        mlinha :=
                            lib_str.w ( mlinha
                                      , LPAD ( v_especie
                                             , 2
                                             , '0' )
                                      , 11 ); -- especie
                        mlinha :=
                            lib_str.w ( mlinha
                                      , v_serie_docfis
                                      , 13 );
                        mlinha :=
                            lib_str.w ( mlinha
                                      , LPAD ( v_nota_ini
                                             , 6
                                             , '0' )
                                      , 16 ); -- numero inicial docto
                        mlinha :=
                            lib_str.w ( mlinha
                                      , LPAD ( v_nota_ant
                                             , 6
                                             , '0' )
                                      , 22 ); -- numero final docto
                        mlinha :=
                            lib_str.w ( mlinha
                                      , v_tomador
                                      , 28 ); -- tipo tomador
                        mlinha :=
                            lib_str.w ( mlinha
                                      , v_cpf_cgc
                                      , 29 ); -- CPF/CNPJ do Tomador
                        mlinha :=
                            lib_str.w ( mlinha
                                      , v_situacao
                                      , 43 ); -- Situacao
                        mlinha :=
                            lib_str.w ( mlinha
                                      , v_data_cancelamento
                                      , 44 ); -- data de cancelamento
                        mlinha :=
                            lib_str.w ( mlinha
                                      , LPAD ( v_num_docfis_ref
                                             , 6
                                             , '0' )
                                      , 52 );
                        mlinha :=
                            lib_str.w ( mlinha
                                      , RPAD ( v_obs_compl
                                             , 250
                                             , ' ' )
                                      , 58 ); -- Motivo do cancelamento
                        mlinha :=
                            lib_str.w ( mlinha
                                      , v_prest_serv
                                      , 308 );
                        mlinha :=
                            lib_str.w ( mlinha
                                      , v_destaque
                                      , 309 ); -- destaque
                        lib_proc.add ( mlinha
                                     , NULL
                                     , NULL
                                     , 1 );


                        v_nota_ant := 0;
                        v_nota_ini := 0;
                        v_data_emissao := NULL;
                        v_cod_servico := NULL;
                        v_serie_docfis := NULL;
                        v_cpf_cgc := NULL;
                        v_situacao := NULL;
                        v_num_ini_controle := NULL;
                        v_num_fim_controle := NULL;
                        v_vlr_tot_nota := 0;
                        v_vlr_base_iss_1 := 0;
                        v_vlr_servico := 0;
                        v_vlr_base_iss_1_07 := 0;
                        v_tomador := NULL;
                        v_nro_aidf_nf := NULL;
                        v_movto_e_s := NULL;
                        v_num_docfis_ref := NULL;
                        v_data_docfis_ref := NULL;
                        v_obs_compl := NULL;
                        v_vlr_doc_tot := 0;
                        v_vlr_tributo_iss := 0;
                        v_vlr_tributo_iss07 := 0;
                        v_especie := NULL;
                        v_data_cancelamento := NULL;
                        v_destaque := NULL;
                        v_prest_serv := NULL;
                        count_reg := count_reg + 1;
                    END IF;
                ELSE
                    -- tratamento do registro 08 sem intervalo

                    IF chave IS NULL
                    OR chave = mreg.num_docfis || mreg.data_fiscal || mreg.cod_fis_jur THEN
                        IF mreg.cod_servico = 'SEM IT' THEN
                            v_prest_serv := '2';
                            v_vlr_tot_nota := mreg.vlr_tot_nota;
                        ELSE
                            v_prest_serv := '1';
                            v_vlr_tot_nota := mreg.vlr_servico;
                        END IF;

                        IF mreg.vlr_tributo_iss > 0
                        OR mreg.vlr_tributo_iss07 > 0 THEN
                            v_destaque := '1';
                        ELSE
                            v_destaque := '2';
                        END IF;

                        IF mreg.tam_cgc = 14
                       AND mreg.uf <> 'EX' THEN
                            v_tomador := 2; -- 1 cgc 2 cpf
                        ELSIF mreg.tam_cgc < 14
                          AND mreg.uf <> 'EX' THEN
                            v_tomador := 1; -- 1 cgc 2 cpf
                        ELSIF mreg.uf = 'EX' THEN
                            v_tomador := 3; -- 1 cgc 2 cpf
                        ELSE
                            v_tomador := 0;
                        END IF;

                        IF mreg.num_docfis_ref IS NULL THEN
                            v_situacao := 4;
                            v_num_docfis_ref := '000000';
                        ELSE
                            v_situacao := 5;
                            v_num_docfis_ref := mreg.num_docfis_ref;
                        END IF;

                        IF mreg.dat_cancelamento IS NULL THEN
                            v_data_cancelamento := '00000000';
                        ELSE
                            v_data_cancelamento := mreg.dat_cancelamento;
                        END IF;

                        v_data_emissao := mreg.data_emissao;
                        v_especie := mreg.especie;
                        v_serie_docfis := mreg.serie_docfis;
                        v_nota_ini := mreg.num_docfis;
                        v_nota_ant := 0;
                        v_cpf_cgc := mreg.cpf_cgc;
                        v_num_ini_controle := mreg.num_ini_controle;
                        v_num_fim_controle := mreg.num_final_controle;
                        v_nro_aidf_nf := mreg.nro_aidf_nf;
                        v_obs_compl := mreg.obs_compl;


                        mlinha := NULL;
                        mlinha :=
                            lib_str.w ( mlinha
                                      , '08'
                                      , 1 ); -- Tipo de Registro
                        mlinha :=
                            lib_str.w ( mlinha
                                      , v_data_emissao
                                      , 3 );
                        mlinha :=
                            lib_str.w ( mlinha
                                      , LPAD ( v_especie
                                             , 2
                                             , '0' )
                                      , 11 ); -- especie
                        mlinha :=
                            lib_str.w ( mlinha
                                      , v_serie_docfis
                                      , 13 );
                        mlinha :=
                            lib_str.w ( mlinha
                                      , LPAD ( v_nota_ini
                                             , 6
                                             , '0' )
                                      , 16 ); -- numero inicial docto
                        mlinha :=
                            lib_str.w ( mlinha
                                      , LPAD ( v_nota_ant
                                             , 6
                                             , '0' )
                                      , 22 ); -- numero final docto
                        mlinha :=
                            lib_str.w ( mlinha
                                      , v_tomador
                                      , 28 ); -- tipo tomador
                        mlinha :=
                            lib_str.w ( mlinha
                                      , v_cpf_cgc
                                      , 29 ); -- CPF/CNPJ do Tomador
                        mlinha :=
                            lib_str.w ( mlinha
                                      , v_situacao
                                      , 43 ); -- Situacao
                        mlinha :=
                            lib_str.w ( mlinha
                                      , v_data_cancelamento
                                      , 44 ); -- data de cancelamento
                        mlinha :=
                            lib_str.w ( mlinha
                                      , LPAD ( v_num_docfis_ref
                                             , 6
                                             , '0' )
                                      , 52 );
                        mlinha :=
                            lib_str.w ( mlinha
                                      , RPAD ( v_obs_compl
                                             , 250
                                             , ' ' )
                                      , 58 ); -- Motivo do cancelamento
                        mlinha :=
                            lib_str.w ( mlinha
                                      , v_prest_serv
                                      , 308 );
                        mlinha :=
                            lib_str.w ( mlinha
                                      , v_destaque
                                      , 309 ); -- destaque
                        lib_proc.add ( mlinha
                                     , NULL
                                     , NULL
                                     , 1 );

                        count_reg := count_reg + 1;

                        IF mreg.cod_servico = 'SEM IT' THEN
                            v_cod_servico := NULL;
                        ELSE
                            v_cod_servico := mreg.cod_servico;
                        END IF;

                        chave := /*to_char(*/
                                mreg.num_docfis || mreg.data_fiscal || mreg.cod_fis_jur /*)*/
                                                                                       ;
                    END IF;

                    -- REGISTRO 08 - nf normal Serviços Emitidos - Linha de registro da tabela de itens de Documentos Fiscais Emitidos
                    -- tratamento com somatorio por codigo de servico
                    IF mreg.cod_servico <> 'SEM IT' THEN
                        BEGIN
                            SELECT   COUNT ( * )
                                   , SUBSTR ( det.valor
                                            , 1
                                            , 6 )
                                   , SUM ( dwt09.vlr_servico )
                                   , SUM ( NVL ( dwt09.vlr_tributo_iss, 0 ) )
                                   , SUM ( NVL ( dwt09.vlr_base_iss_1, 0 ) )
                                   , SUM ( NVL ( dwt09.vlr_base_iss_2, 0 ) )
                                   , SUM ( NVL ( dwt09.vlr_base_iss_3, 0 ) )
                                   , SUM ( NVL ( dwt09.vlr_desconto, 0 ) )
                                   , NVL ( dwt09.aliq_tributo_iss, 0 )
                                INTO v_num_item
                                   , v_cod_servico
                                   , v_vlr_servico
                                   , v_vlr_tributo_iss
                                   , v_vlr_base_iss_1
                                   , v_vlr_base_iss_2
                                   , v_vlr_base_iss_3
                                   , v_desconto
                                   , v_aliq_tributo_iss
                                FROM dwt_docto_fiscal dwt07
                                   , dwt_itens_serv dwt09
                                   , x04_pessoa_fis_jur x04pfj
                                   , x2018_servicos x2018
                                   , estado estad
                                   , x2005_tipo_docto x2005
                                   , fpar_param_det det
                                   , fpar_param_det det1
                                   , fpar_parametros param
                                   , fpar_param_estab festab
                               WHERE dwt07.cod_empresa = dwt09.cod_empresa
                                 AND dwt07.cod_estab = dwt09.cod_estab
                                 AND dwt07.data_fiscal = dwt09.data_fiscal
                                 AND dwt07.movto_e_s = dwt09.movto_e_s
                                 AND dwt07.norm_dev = dwt09.norm_dev
                                 AND dwt07.ident_docto_fiscal = dwt09.ident_docto_fiscal
                                 AND dwt07.ident_fis_jur = dwt09.ident_fis_jur
                                 AND dwt07.num_docfis = dwt09.num_docfis
                                 AND dwt07.serie_docfis = dwt09.serie_docfis
                                 AND dwt07.sub_serie_docfis = dwt09.sub_serie_docfis
                                 AND dwt07.cod_class_doc_fis IN ( '2'
                                                                , '3' )
                                 AND dwt07.situacao = 'S'
                                 AND dwt07.ident_docto_fiscal = dwt09.ident_docto_fiscal
                                 AND dwt07.ident_fis_jur = x04pfj.ident_fis_jur
                                 AND dwt09.ident_servico = x2018.ident_servico
                                 AND x04pfj.ident_estado = estad.ident_estado
                                 AND dwt07.ident_docto = x2005.ident_docto
                                 AND det.id_parametro = param.id_parametros
                                 AND det1.id_parametro = param.id_parametros
                                 AND param.id_parametros = festab.id_parametros
                                 AND det.nome_param = 'Serviço'
                                 AND dwt07.cod_empresa = festab.cod_empresa
                                 AND dwt07.cod_estab = festab.cod_estab
                                 AND det1.nome_param = 'Especie'
                                 AND det.conteudo = x2018.cod_servico
                                 AND det1.conteudo = x2005.cod_docto
                                 AND dwt07.cod_empresa = mcod_empresa
                                 AND dwt07.cod_estab = pcd_estab
                                 AND dwt07.movto_e_s = '9'
                                 AND TO_CHAR ( dwt07.data_emissao
                                             , 'DD/MM/YYYY' ) BETWEEN pdat_ini
                                                                  AND pdat_fim
                                 AND /*to_char(*/
                                    dwt09.num_docfis
                                     || TO_CHAR ( dwt09.data_fiscal
                                                , 'DDMMYYYY' )
                                     || x04pfj.cod_fis_jur /*)*/
                                                          = /*to_char(*/
                                                           chave /*)*/
                            GROUP BY SUBSTR ( det.valor
                                            , 1
                                            , 6 )
                                   , NVL ( dwt09.aliq_tributo_iss, 0 );
                        EXCEPTION
                            WHEN OTHERS THEN
                                chave := NULL;
                        END;

                        IF v_vlr_base_iss_2 > 0 THEN
                            v_aliq := '06';
                        ELSIF v_vlr_base_iss_3 > 0 THEN
                            v_aliq := '05';
                        ELSIF ( v_aliq_tributo_iss * 100 ) = '5' THEN
                            v_aliq := '01';
                        ELSIF v_aliq_tributo_iss = '2' THEN
                            v_aliq := '02';
                        ELSIF v_aliq_tributo_iss = '3' THEN
                            v_aliq := '03';
                        ELSIF v_aliq_tributo_iss = '5' THEN
                            v_aliq := '04';
                        END IF;

                        IF v_destaque = '1' THEN
                            v_base := v_vlr_base_iss_1;
                            v_vlr_tributo_iss := 0;
                        END IF;

                        IF mreg.cod_servico = 'SEM IT' THEN
                            v_vlr_servico := mreg.vlr_tot_nota;
                        END IF;


                        mlinha := NULL;
                        mlinha :=
                            lib_str.w ( mlinha
                                      , '09'
                                      , 1 ); -- Tipo de Registro
                        mlinha :=
                            lib_str.w ( mlinha
                                      , v_cod_servico
                                      , 3 ); -- cod servico de/para
                        mlinha :=
                            lib_str.w ( mlinha
                                      , LPAD ( v_aliq
                                             , 2
                                             , '0' )
                                      , 9 ); -- identificador aliquota mreg.ind_aliquota
                        mlinha :=
                            lib_str.w ( mlinha
                                      , LPAD ( ( v_vlr_servico * 100 )
                                             , 14
                                             , '0' )
                                      , 11 ); -- valor dos serviços
                        mlinha :=
                            lib_str.w ( mlinha
                                      , LPAD ( ( v_desconto * 100 )
                                             , 14
                                             , '0' )
                                      , 25 ); -- valor deducao/desconto
                        mlinha :=
                            lib_str.w ( mlinha
                                      , LPAD ( ( v_vlr_tributo_iss * 100 )
                                             , 14
                                             , '0' )
                                      , 39 ); -- valor do imposto retido
                        lib_proc.add ( mlinha
                                     , NULL
                                     , NULL
                                     , 1 );

                        v_vlr_base_iss_1 := 0;


                        count_reg := count_reg + 1;


                        --- montagem do registro 09

                        IF v_destaque = '1' THEN
                            v_tot_base := v_tot_base + v_base;
                            v_tot_serv := v_tot_serv + v_vlr_servico;
                        ELSE
                            v_tot_base := 0;
                            v_tot_serv := v_tot_serv + v_vlr_servico;
                        END IF;

                        v_aliq_ant := v_aliq;
                        v_cod_servico_ant := v_cod_servico;
                        v_vlr_servico := 0;
                        v_desconto := 0;
                        v_vlr_tributo_iss := 0;
                        v_nota_ant := mreg.num_docfis;

                        chave := NULL;

                        cont_item := cont_item - 1;

                        -- REGISTRO 10 - nf normal Serviços Emitidos - Linha de registro com o Valor Total do Documento Fiscal Emitido

                        mlinha := NULL;
                        mlinha :=
                            lib_str.w ( mlinha
                                      , '10'
                                      , 1 ); -- Tipo de Registro
                        mlinha :=
                            lib_str.w ( mlinha
                                      , LPAD ( ( v_tot_base * 100 )
                                             , 14
                                             , '0' )
                                      , 3 ); -- Total base de ISS
                        mlinha :=
                            lib_str.w ( mlinha
                                      , LPAD ( ( v_tot_serv * 100 )
                                             , 14
                                             , '0' )
                                      , 17 ); -- valor dos serviços
                        lib_proc.add ( mlinha
                                     , NULL
                                     , NULL
                                     , 1 );

                        v_tot_serv := 0;
                        v_tot_base := 0;
                        v_trib := NULL;

                        count_reg := count_reg + 1;
                    ELSE
                        -- REGISTRO 10 - nf normal Serviços Emitidos Sem Itens - Linha de registro com o Valor Total do Documento Fiscal Emitido

                        IF v_destaque = '1' THEN
                            v_tot_base := mreg.vlr_base_iss_1_07;
                            v_tot_serv := mreg.vlr_tot_nota;
                        ELSE
                            v_tot_base := 0;
                            v_tot_serv := v_vlr_servico;
                        END IF;


                        mlinha := NULL;
                        mlinha :=
                            lib_str.w ( mlinha
                                      , '10'
                                      , 1 ); -- Tipo de Registro
                        mlinha :=
                            lib_str.w ( mlinha
                                      , LPAD ( ( v_tot_base * 100 )
                                             , 14
                                             , '0' )
                                      , 3 ); -- Total base de ISS
                        mlinha :=
                            lib_str.w ( mlinha
                                      , LPAD ( ( v_tot_serv * 100 )
                                             , 14
                                             , '0' )
                                      , 17 ); -- valor dos serviços
                        lib_proc.add ( mlinha
                                     , NULL
                                     , NULL
                                     , 1 );

                        v_tot_serv := 0;
                        v_tot_base := 0;
                        v_trib := NULL;
                        chave := NULL;

                        count_reg := count_reg + 1;
                    END IF;
                END IF;
            END IF;
        END LOOP;

        -- REGISTRO 11 -  Footer - Fim de arquivo

        mlinha := NULL;
        mlinha :=
            lib_str.w ( mlinha
                      , '11'
                      , 1 ); -- Tipo de Registro
        mlinha :=
            lib_str.w ( mlinha
                      , LPAD ( ( count_reg + 1 )
                             , 8
                             , '0' )
                      , 3 ); -- cod servico de/para
        lib_proc.add ( mlinha
                     , NULL
                     , NULL
                     , 1 );

        lib_proc.add_log ( 'Finalizado com sucesso'
                         , 1 );
        lib_proc.close ( );
        RETURN mproc_id;
    END;

    -------------------------------------------------------------------------
    -- Procedure para Teste
    -------------------------------------------------------------------------

    PROCEDURE teste
    IS
        mproc_id INTEGER;
    BEGIN
        lib_parametros.salvar ( 'EMPRESA'
                              , '1' );
        mcod_empresa := '1';
        mproc_id :=
            executar ( '001'
                     , '01022005'
                     , 2 );

        --lib_proc.list_output(mproc_id, 1);

        dbms_output.put_line ( '' );
        dbms_output.put_line ( '---Arquivo Magnetico----' );
        dbms_output.put_line ( '' );
        lib_proc.list_output ( mproc_id
                             , 2 );
    END;
END msaf_dief_rj_cproc;
/
SHOW ERRORS;
