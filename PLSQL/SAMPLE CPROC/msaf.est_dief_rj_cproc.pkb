Prompt Package Body EST_DIEF_RJ_CPROC;
--
-- EST_DIEF_RJ_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY est_dief_rj_cproc
IS
    mcod_estab estabelecimento.cod_estab%TYPE;
    mcod_empresa empresa.cod_empresa%TYPE;
    musuario usuario_estab.cod_usuario%TYPE;

    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );
        data_w DATE;
    BEGIN
        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        mcod_estab := NVL ( lib_parametros.recuperar ( 'ESTABELECIMENTO' ), '' );
        musuario := lib_parametros.recuperar ( 'USUARIO' );

        SELECT ADD_MONTHS ( SYSDATE
                          , -1 )
          INTO data_w
          FROM DUAL;

        lib_proc.add_param ( pstr
                           , 'Período de Apuração: '
                           , 'Date'
                           , 'Textbox'
                           , 'N'
                           , data_w
                           , 'MM/YYYY'
                           , papresenta => 'S' );

        lib_proc.add_param (
                             pstr
                           , 'Tipo de Movimentação: '
                           , 'Varchar2'
                           , 'Listbox'
                           , 'S'
                           , 3
                           , NULL
                           ,    '2=Documentos Emitidos,'
                             || '1=Documentos Recebidos,'
                             || '3=Documentos Emitidos e Recebidos'
        );

        lib_proc.add_param (
                             pstr
                           , 'Estabelecimento '
                           , 'Varchar2'
                           , 'Multiproc'
                           , 'S'
                           , NULL
                           , NULL
                           ,    'SELECT DISTINCT e.cod_estab, e.cod_estab||'' - ''||e.razao_social FROM estabelecimento e, estado uf WHERE e.ident_estado = uf.ident_estado(+) AND e.cod_municipio = 4557 '
                             || 'AND uf.cod_estado = ''RJ'' AND e.cod_empresa = '''
                             || mcod_empresa
                             || ''''
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

    FUNCTION executar ( p_dat_comp DATE
                      , ptp_docto VARCHAR2
                      , p_cod_estab VARCHAR2 )
        RETURN INTEGER
    IS
        /* Variáveis de Trabalho */
        mlinha VARCHAR2 ( 1000 );
        insc_municipal_w VARCHAR2 ( 14 );
        pdat_ini DATE;
        pdat_fim DATE;
        v_total_base NUMBER ( 17, 2 ) := 0;
        v_total_serv NUMBER ( 17, 2 ) := 0;
        count_reg INTEGER := 0;
        v_total_serv_s_nf NUMBER ( 17, 2 ) := 0; -- total dos servicos
        v_total_base_s_nf NUMBER ( 17, 2 ) := 0; -- total da base
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
        v_vlr_docto NUMBER ( 17, 2 ) := 0;
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
        v_num_item_ini NUMBER ( 3 ) := '999';
        cont_item NUMBER ( 3 );
        v_uf CHAR;
        v_vlr_base_iss_2 NUMBER ( 17, 2 ) := 0;
        v_vlr_base_iss_3 NUMBER ( 17, 2 ) := 0;
        v_aliq_tributo_iss NUMBER ( 3 ) := 0;
        v_base NUMBER ( 17, 2 ) := 0;

        ----------------------------------------------------------------------------------------------

        CURSOR c3 ( ccd_estab VARCHAR2
                  , pdat_ini DATE
                  , pdat_fim DATE
                  , ccd_tipo VARCHAR2 )
        IS
            SELECT   LPAD ( dwt07.num_docfis
                          , 6
                          , '0' )
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
                   , LPAD ( DECODE ( x04pfj.ind_contem_cod, 4, '0', x04pfj.cpf_cgc )
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
                   , 0 vlr_base_iss_1_07
                   , SUM ( NVL ( dwt09.vlr_desconto, 0 ) ) desconto
                   , 'SERV' cod_servico
                   , SUM ( NVL ( dwt07.vlr_tom_servico, 0 ) ) vlr_tom_servico
                   , NVL ( dwt07.vlr_tot_nota, 0 ) vlr_tot_nota
                   , NULL vlr_tributo_iss07
                FROM dwt_docto_fiscal dwt07
                   , dwt_itens_serv dwt09
                   , x04_pessoa_fis_jur x04pfj
                   , x2018_servicos x2018
                   , estado estad
                   , x2005_tipo_docto x2005
                   , --  FPAR_PARAM_DET     DET,
                     fpar_param_det det1
                   , fpar_parametros param
                   , fpar_param_estab festab
               WHERE dwt07.cod_empresa = mcod_empresa
                 AND dwt07.cod_estab = ccd_estab
                 -- AND DWT07.MOVTO_E_S = '1'
                 AND dwt07.movto_e_s = DECODE ( ccd_tipo,  3, '1',  1, '1',  '0' )
                 AND TO_CHAR ( dwt07.data_emissao
                             , 'DD/MM/YYYY' ) BETWEEN pdat_ini
                                                  AND pdat_fim -- '02/2005'
                 AND dwt07.cod_class_doc_fis IN ( '2'
                                                , '3' )
                 AND dwt07.situacao <> 'S'
                 AND dwt07.ident_docto_fiscal = dwt09.ident_docto_fiscal
                 AND dwt07.ident_fis_jur = x04pfj.ident_fis_jur
                 AND dwt09.ident_servico = x2018.ident_servico
                 AND x04pfj.ident_estado = estad.ident_estado
                 AND dwt07.ident_docto = x2005.ident_docto
                 -- AND DET.ID_PARAMETRO = PARAM.ID_PARAMETROS
                 AND det1.id_parametro = param.id_parametros
                 AND param.id_parametros = festab.id_parametros
                 --  AND DET.NOME_PARAM = 'Serviço'
                 AND festab.cod_empresa = dwt07.cod_empresa
                 AND festab.cod_estab = dwt07.cod_estab
                 AND det1.nome_param = 'Especie'
                 --   AND DET.CONTEUDO = X2018.COD_SERVICO
                 AND det1.conteudo = x2005.cod_docto
            GROUP BY LPAD ( dwt07.num_docfis
                          , 6
                          , '0' )
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
                   , LPAD ( DECODE ( x04pfj.ind_contem_cod, 4, '0', x04pfj.cpf_cgc )
                          , 14
                          , '0' )
                   , LENGTH ( x04pfj.cpf_cgc )
                   , RPAD ( x04pfj.cpf_cgc
                          , 14
                          , 'x' )
                   , x04pfj.insc_municipal
                   , estad.cod_estado
                   , x04pfj.cod_fis_jur
                   , 'SERV'
                   , NVL ( dwt07.vlr_tot_nota, 0 )
            UNION
            SELECT   LPAD ( dwt07.num_docfis
                          , 6
                          , '0' )
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
                   , 0 vlr_servico
                   , NVL ( dwt07.aliq_tributo_iss, 0 ) aliq_tributo_iss
                   , LPAD ( DECODE ( x04pfj.ind_contem_cod, 4, '0', x04pfj.cpf_cgc )
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
                   , SUM ( NVL ( dwt07.vlr_tributo_iss, 0 ) ) vlr_tributo_iss
                   , 0 vlr_base_iss_1
                   , 0 vlr_base_iss_2
                   , 0 vlr_base_iss_3
                   , SUM ( NVL ( dwt07.vlr_base_iss_1, 0 ) ) vlr_base_iss_1_07
                   , 0 desconto
                   , 'SEM IT' cod_servico
                   , SUM ( NVL ( dwt07.vlr_tom_servico, 0 ) ) vlr_tom_servico
                   , NVL ( dwt07.vlr_tot_nota, 0 ) vlr_tot_nota
                   , NULL vlr_tributo_iss07
                FROM dwt_docto_fiscal dwt07
                   , x04_pessoa_fis_jur x04pfj
                   , estado estad
                   , x2005_tipo_docto x2005
                   , fpar_param_det det1
                   , fpar_parametros param
                   , fpar_param_estab festab
               WHERE dwt07.cod_empresa = mcod_empresa
                 AND dwt07.cod_estab = ccd_estab
                 --AND DWT07.MOVTO_E_S <> '9'
                 AND dwt07.movto_e_s = DECODE ( ccd_tipo,  3, '1',  1, '1',  '0' )
                 AND TO_CHAR ( dwt07.data_emissao
                             , 'DD/MM/YYYY' ) BETWEEN pdat_ini
                                                  AND pdat_fim -- '02/2005'
                 AND dwt07.cod_class_doc_fis IN ( '2'
                                                , '3' )
                 AND dwt07.situacao <> 'S'
                 AND dwt07.ident_fis_jur = x04pfj.ident_fis_jur
                 AND x04pfj.ident_estado = estad.ident_estado
                 AND dwt07.ident_docto = x2005.ident_docto
                 AND det1.id_parametro = param.id_parametros
                 AND param.id_parametros = festab.id_parametros
                 AND festab.cod_empresa = dwt07.cod_empresa
                 AND festab.cod_estab = dwt07.cod_estab
                 AND det1.nome_param = 'Especie'
                 AND det1.conteudo = x2005.cod_docto
                 AND NOT EXISTS
                         (SELECT 1
                            FROM dwt_itens_serv dwt09
                           WHERE dwt07.cod_empresa = dwt09.cod_empresa
                             AND dwt07.cod_estab = dwt09.cod_estab
                             AND dwt07.num_docfis = dwt09.num_docfis
                             AND dwt07.ident_fis_jur = dwt09.ident_fis_jur
                             AND dwt07.data_fiscal = dwt09.data_fiscal)
            GROUP BY LPAD ( dwt07.num_docfis
                          , 6
                          , '0' )
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
                   , LPAD ( DECODE ( x04pfj.ind_contem_cod, 4, '0', x04pfj.cpf_cgc )
                          , 14
                          , '0' )
                   , LENGTH ( x04pfj.cpf_cgc )
                   , RPAD ( x04pfj.cpf_cgc
                          , 14
                          , 'x' )
                   , x04pfj.insc_municipal
                   , estad.cod_estado
                   , x04pfj.cod_fis_jur
                   , 'SEM IT'
                   , NVL ( dwt07.vlr_tot_nota, 0 );

        CURSOR c2 ( ccd_estab VARCHAR2
                  , pdat_ini DATE
                  , pdat_fim DATE
                  , ccd_tipo VARCHAR2 )
        IS
            SELECT   LPAD ( dwt07.num_docfis
                          , 6
                          , '0' )
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
                   , '1' situacao
                   , SUM ( NVL ( dwt09.vlr_servico, 0 ) ) vlr_servico
                   , NVL ( dwt09.aliq_tributo_iss, 0 ) aliq_tributo_iss
                   , 0
                   , x04pfj.cidade
                   , x04pfj.cod_municipio municipio_forn
                   , x04pfj.razao_social
                   , LPAD ( DECODE ( x04pfj.ind_contem_cod, 4, '0', x04pfj.cpf_cgc )
                          , 14
                          , '0' )
                         cpf_cgc
                   , LENGTH ( x04pfj.cpf_cgc ) tam_cgc
                   , RPAD ( x04pfj.cpf_cgc
                          , 14
                          , 'x' )
                         cpf_cgc_aux
                   , x04pfj.insc_municipal
                   , x04pfj.insc_estadual
                   , x04pfj.endereco
                   , x04pfj.bairro
                   , DECODE ( x04pfj.cep, '0', NULL, x04pfj.cep ) cep
                   , x04pfj.compl_endereco
                   , x04pfj.num_endereco
                   , estad.cod_estado uf
                   , x04pfj.cod_municipio
                   , x04pfj.cod_fis_jur
                   , SUM ( NVL ( dwt09.vlr_tributo_iss, 0 ) ) vlr_tributo_iss
                   , SUM ( NVL ( dwt09.vlr_base_iss_1, 0 ) ) vlr_base_iss_1
                   , SUM ( NVL ( dwt09.vlr_base_iss_2, 0 ) ) vlr_base_iss_2
                   , SUM ( NVL ( dwt09.vlr_base_iss_3, 0 ) ) vlr_base_iss_3
                   , 0 vlr_base_iss_1_07
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
                   , NVL ( dwt07.nro_aidf_nf, 0 ) nro_aidf_nf
                   , NVL ( dwt07.vlr_tot_nota, 0 ) vlr_tot_nota
                   , SUM ( NVL ( dwt07.vlr_tom_servico, 0 ) ) vlr_tom_servico
                   , 0 vlr_tributo_iss07
                   , dwt07.movto_e_s movto_e_s
                   , LPAD ( TO_CHAR ( dwt07.dat_cancelamento
                                    , 'DDMMYYYY' )
                          , 6
                          , '0' )
                         dat_cancelamento
                --        , dwt09.num_item                                                         num_item
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
               WHERE dwt07.cod_empresa = mcod_empresa
                 AND dwt07.cod_estab = ccd_estab
                 AND dwt07.movto_e_s = DECODE ( ccd_tipo,  3, '9',  2, '9',  '' )
                 AND TO_CHAR ( dwt07.data_emissao
                             , 'DD/MM/YYYY' ) BETWEEN pdat_ini
                                                  AND pdat_fim -- '02/2005'
                 AND dwt07.cod_class_doc_fis IN ( '2'
                                                , '3' )
                 AND dwt07.situacao <> 'S'
                 AND dwt07.ident_docto_fiscal = dwt09.ident_docto_fiscal
                 AND dwt07.ident_fis_jur = x04pfj.ident_fis_jur
                 AND dwt09.ident_servico = x2018.ident_servico
                 AND x04pfj.ident_estado = estad.ident_estado
                 AND dwt07.ident_docto = x2005.ident_docto
                 AND det.id_parametro = param.id_parametros
                 AND det1.id_parametro = param.id_parametros
                 AND param.id_parametros = festab.id_parametros
                 AND det.nome_param = 'Serviço'
                 AND festab.cod_empresa = dwt07.cod_empresa
                 AND festab.cod_estab = dwt07.cod_estab
                 AND det1.nome_param = 'Especie'
                 AND det.conteudo = x2018.cod_servico
                 AND det1.conteudo = x2005.cod_docto
            GROUP BY x2018.cod_servico
                   , dwt07.num_docfis
                   , TO_CHAR ( dwt07.data_emissao
                             , 'DDMMYYYY' )
                   , dwt07.serie_docfis
                   , LPAD ( DECODE ( x04pfj.ind_contem_cod, 4, '0', x04pfj.cpf_cgc )
                          , 14
                          , '0' )
                   , dwt07.situacao
                   , dwt07.data_fiscal
                   , x04pfj.cidade
                   , x04pfj.cod_municipio
                   , x04pfj.razao_social
                   , RPAD ( x04pfj.cpf_cgc
                          , 14
                          , 'x' )
                   , x04pfj.insc_estadual
                   , x04pfj.insc_municipal
                   , x04pfj.endereco
                   , x04pfj.compl_endereco
                   , x04pfj.num_endereco
                   , x04pfj.bairro
                   , estad.cod_estado
                   , x04pfj.cep
                   , NVL ( dwt09.aliq_tributo_iss, 0 )
                   , x04pfj.cod_municipio
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
                   , NVL ( dwt07.nro_aidf_nf, 0 )
                   , dwt07.movto_e_s
                   , dwt07.vlr_tot_nota
                   , LPAD ( TO_CHAR ( dwt07.dat_cancelamento
                                    , 'DDMMYYYY' )
                          , 6
                          , '0' )
                   , SUBSTR ( det1.valor
                            , 3
                            , 1 )
            --          , dwt09.num_item
            UNION
            -- documentos fiscais recebidos e emitidos sem itens
            SELECT   LPAD ( dwt07.num_docfis
                          , 6
                          , '0' )
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
                   , '1' situacao
                   , 0
                   , dwt07.aliq_tributo_iss aliq_tributo_iss
                   , 0
                   --x2018.cod_servico
                   , x04pfj.cidade
                   , x04pfj.cod_municipio municipio_forn
                   , x04pfj.razao_social
                   , LPAD ( DECODE ( x04pfj.ind_contem_cod, 4, '0', x04pfj.cpf_cgc )
                          , 14
                          , '0' )
                         cpf_cgc
                   , LENGTH ( x04pfj.cpf_cgc ) tam_cgc
                   , RPAD ( x04pfj.cpf_cgc
                          , 14
                          , 'x' )
                         cpf_cgc_aux
                   , x04pfj.insc_municipal
                   , x04pfj.insc_estadual
                   , x04pfj.endereco
                   , x04pfj.bairro
                   , DECODE ( x04pfj.cep, '0', NULL, x04pfj.cep ) cep
                   , x04pfj.compl_endereco
                   , x04pfj.num_endereco
                   , estad.cod_estado uf
                   , x04pfj.cod_municipio
                   , x04pfj.cod_fis_jur
                   , 0
                   , --dwt09.vlr_tributo_iss    tributo_iss,
                    0
                   , --dwt09.vlr_base_iss_1,
                    0
                   , --dwt09.vlr_base_iss_2,
                    0
                   , --dwt09.vlr_base_iss_3,
                    NVL ( dwt07.vlr_base_iss_1, 0 ) vlr_base_iss_1_07
                   , 0
                   , 'SEM IT' cod_servico
                   , SUBSTR ( NVL ( dwt07.num_ctr_disp, 0 )
                            , 1
                            , 6 )
                         num_ini_controle
                   , SUBSTR ( NVL ( dwt07.num_final_crt_disp, 0 )
                            , 1
                            , 6 )
                         num_final_controle
                   , NVL ( dwt07.nro_aidf_nf, 0 ) nro_aidf_nf
                   , NVL ( dwt07.vlr_tot_nota, 0 ) vlr_tot_nota
                   , SUM ( NVL ( dwt07.vlr_tom_servico, 0 ) ) vlr_tom_servico
                   , SUM ( NVL ( dwt07.vlr_tributo_iss, 0 ) ) vlr_tributo_iss07
                   , dwt07.movto_e_s movto_e_s
                   , LPAD ( dwt07.dat_cancelamento
                          , 6
                          , '0' )
                         dat_cancelamento
                --       , null
                FROM dwt_docto_fiscal dwt07
                   , x2005_tipo_docto x2005
                   , x04_pessoa_fis_jur x04pfj
                   , estado estad
                   , fpar_param_det det1
                   , fpar_parametros param
                   , fpar_param_estab festab
               WHERE x2005.ident_docto = dwt07.ident_docto
                 AND x04pfj.ident_estado = estad.ident_estado
                 AND x04pfj.ident_fis_jur = dwt07.ident_fis_jur
                 AND cod_class_doc_fis IN ( '2'
                                          , '3' )
                 AND dwt07.cod_empresa = mcod_empresa
                 AND dwt07.cod_estab = ccd_estab
                 AND TO_CHAR ( dwt07.data_emissao
                             , 'DD/MM/YYYY' ) BETWEEN pdat_ini
                                                  AND pdat_fim
                 AND dwt07.movto_e_s = DECODE ( ccd_tipo,  3, '9',  2, '9',  '' )
                 AND det1.id_parametro = param.id_parametros
                 AND param.id_parametros = festab.id_parametros
                 AND festab.cod_empresa = dwt07.cod_empresa
                 AND festab.cod_estab = dwt07.cod_estab
                 AND det1.nome_param = 'Especie'
                 AND det1.conteudo = x2005.cod_docto
                 AND dwt07.situacao <> 'S'
                 AND NOT EXISTS
                         (SELECT 1
                            FROM dwt_itens_serv dwt09
                           WHERE dwt07.cod_empresa = dwt09.cod_empresa
                             AND dwt07.cod_estab = dwt09.cod_estab
                             AND dwt07.num_docfis = dwt09.num_docfis
                             AND dwt07.ident_fis_jur = dwt09.ident_fis_jur
                             AND dwt07.data_fiscal = dwt09.data_fiscal)
            GROUP BY dwt07.cod_estab
                   , dwt07.num_docfis
                   , TO_CHAR ( dwt07.data_emissao
                             , 'DDMMYYYY' )
                   , x2005.cod_docto
                   , dwt07.serie_docfis
                   , LPAD ( DECODE ( x04pfj.ind_contem_cod, 4, '0', x04pfj.cpf_cgc )
                          , 14
                          , '0' )
                   , dwt07.situacao
                   , dwt07.data_fiscal
                   , dwt07.movto_e_s
                   , dwt07.cod_class_doc_fis
                   , x04pfj.cidade
                   , x04pfj.cod_municipio
                   , x04pfj.razao_social
                   , RPAD ( x04pfj.cpf_cgc
                          , 14
                          , 'x' )
                   , x04pfj.insc_municipal
                   , x04pfj.insc_estadual
                   , x04pfj.endereco
                   , x04pfj.bairro
                   , x04pfj.compl_endereco
                   , x04pfj.num_endereco
                   , estad.cod_estado
                   , DECODE ( x04pfj.cep, '0', NULL, x04pfj.cep )
                   , x04pfj.cod_municipio
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
                   , NVL ( dwt07.nro_aidf_nf, 0 )
                   , dwt07.movto_e_s
                   , SUBSTR ( det1.valor
                            , 1
                            , 2 )
                   , dwt07.vlr_tot_nota
                   , LPAD ( dwt07.dat_cancelamento
                          , 6
                          , '0' )
                   , SUBSTR ( det1.valor
                            , 3
                            , 1 )
            ORDER BY 3
                   , 1
                   , 6
                   , 2
                   , 15
                   , 8;

        -- Fim Cr02

        -- Documentos fiscais Cancelados
        CURSOR c1 ( ccd_estab VARCHAR2
                  , pdat_ini DATE
                  , pdat_fim DATE
                  , ccd_tipo VARCHAR2 )
        IS
            SELECT   DISTINCT LPAD ( dwt07.num_docfis
                                   , 6
                                   , '0' )
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
                            , '2' situacao
                            , SUM ( dwt09.vlr_servico ) vlr_servico
                            , NVL ( dwt09.aliq_tributo_iss, 0 ) aliq_tributo_iss
                            , LPAD ( DECODE ( x04pfj.ind_contem_cod, 4, '0', x04pfj.cpf_cgc )
                                   , 14
                                   , '0' )
                                  cpf_cgc
                            , LENGTH ( x04pfj.cpf_cgc ) tam_cgc
                            , x04pfj.cod_fis_jur cod_fis_jur
                            , SUM ( dwt09.vlr_tributo_iss ) vlr_tributo_iss
                            , SUM ( dwt09.vlr_base_iss_1 ) vlr_base_iss_1
                            , SUM ( dwt09.vlr_base_iss_2 ) vlr_base_iss_2
                            , SUM ( dwt09.vlr_base_iss_3 ) vlr_base_iss_3
                            , SUM ( dwt09.vlr_desconto ) desconto
                            , 0 vlr_base_iss_1_07
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
                            , NVL ( dwt07.nro_aidf_nf, 0 ) nro_aidf_nf
                            , NVL ( dwt07.vlr_tot_nota, 0 ) vlr_tot_nota
                            , SUM ( NVL ( dwt07.vlr_tom_servico, 0 ) ) vlr_tom_servico
                            , 0 vlr_tributo_iss07
                            , dwt07.movto_e_s movto_e_s
                            , SUBSTR ( LPAD ( dwt07.num_docfis_ref
                                            , 6
                                            , '0' )
                                     , 1
                                     , 6 )
                                  num_docfis_ref
                            , TO_CHAR ( dwt07.dat_di
                                      , 'DDMMYYYY' )
                                  data_docfis_ref
                            , dwt07.obs_compl_motivo obs_compl
                            , LPAD ( TO_CHAR ( dwt07.dat_cancelamento
                                             , 'DDMMYYYY' )
                                   , 8
                                   , '0' )
                                  dat_cancelamento
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
               WHERE dwt07.cod_empresa = mcod_empresa
                 AND dwt07.cod_estab = ccd_estab
                 AND dwt07.movto_e_s = DECODE ( ccd_tipo,  3, dwt07.movto_e_s,  2, '9',  '1' )
                 AND TO_CHAR ( dwt07.data_emissao
                             , 'DD/MM/YYYY' ) BETWEEN pdat_ini
                                                  AND pdat_fim
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
                 AND festab.cod_empresa = dwt07.cod_empresa
                 AND festab.cod_estab = dwt07.cod_estab
                 AND det1.nome_param = 'Especie'
                 AND det.conteudo = x2018.cod_servico
                 AND det1.conteudo = x2005.cod_docto
            GROUP BY LPAD ( dwt07.num_docfis
                          , 6
                          , '0' )
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
                   , LPAD ( DECODE ( x04pfj.ind_contem_cod, 4, '0', x04pfj.cpf_cgc )
                          , 14
                          , '0' )
                   , LENGTH ( x04pfj.cpf_cgc )
                   , x04pfj.cod_fis_jur
                   , SUBSTR ( det.valor
                            , 1
                            , 6 )
                   , SUBSTR ( NVL ( dwt07.num_ctr_disp, 0 )
                            , 1
                            , 6 )
                   , SUBSTR ( NVL ( dwt07.num_final_crt_disp, 0 )
                            , 1
                            , 6 )
                   , NVL ( dwt07.nro_aidf_nf, 0 )
                   , NVL ( dwt07.vlr_tot_nota, 0 )
                   , dwt07.movto_e_s
                   , SUBSTR ( LPAD ( dwt07.num_docfis_ref
                                   , 6
                                   , '0' )
                            , 1
                            , 6 )
                   , TO_CHAR ( dwt07.dat_di
                             , 'DDMMYYYY' )
                   , dwt07.obs_compl_motivo
                   , LPAD ( TO_CHAR ( dwt07.dat_cancelamento
                                    , 'DDMMYYYY' )
                          , 8
                          , '0' )
                   , SUBSTR ( det1.valor
                            , 3
                            , 1 )
            UNION
            -- documentos fiscais sem itens cancelados
            SELECT   LPAD ( dwt07.num_docfis
                          , 6
                          , '0' )
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
                   , '2' situacao
                   , 0
                   , dwt07.aliq_tributo_iss aliq_tributo_iss
                   , LPAD ( DECODE ( x04pfj.ind_contem_cod, 4, '0', x04pfj.cpf_cgc )
                          , 14
                          , '0' )
                         cpf_cgc
                   , LENGTH ( x04pfj.cpf_cgc ) tam_cgc
                   , x04pfj.cod_fis_jur
                   , 0
                   , --dwt09.vlr_tributo_iss              tributo_iss,
                    0
                   , --dwt09.vlr_base_iss_1,
                    0
                   , --dwt09.vlr_base_iss_2,
                    0
                   , SUM ( NVL ( dwt07.vlr_desconto, 0 ) ) desconto
                   , NVL ( dwt07.vlr_base_iss_1, 0 ) vlr_base_iss_1_07
                   , 'SEM IT' cod_servico
                   , SUBSTR ( NVL ( dwt07.num_ctr_disp, 0 )
                            , 1
                            , 6 )
                         num_ini_controle
                   , SUBSTR ( NVL ( dwt07.num_final_crt_disp, 0 )
                            , 1
                            , 6 )
                         num_final_controle
                   , NVL ( dwt07.nro_aidf_nf, 0 ) nro_aidf_nf
                   , NVL ( dwt07.vlr_tot_nota, 0 ) vlr_tot_nota
                   , SUM ( NVL ( dwt07.vlr_tom_servico, 0 ) ) vlr_tom_servico
                   , SUM ( NVL ( dwt07.vlr_tributo_iss, 0 ) ) vlr_tributo_iss07
                   , dwt07.movto_e_s movto_e_s
                   , SUBSTR ( LPAD ( dwt07.num_docfis_ref
                                   , 6
                                   , '0' )
                            , 1
                            , 6 )
                         num_docfis_ref
                   , TO_CHAR ( dwt07.dat_di
                             , 'DDMMYYYY' )
                         data_docfis_ref
                   , dwt07.obs_compl_motivo obs_compl
                   , LPAD ( TO_CHAR ( dwt07.dat_cancelamento
                                    , 'DDMMYYYY' )
                          , 8
                          , '0' )
                         dat_cancelamento
                FROM dwt_docto_fiscal dwt07
                   , x2005_tipo_docto x2005
                   , x04_pessoa_fis_jur x04pfj
                   , estado estad
                   , fpar_param_det det1
                   , fpar_parametros param
                   , fpar_param_estab festab
               WHERE x2005.ident_docto = dwt07.ident_docto
                 AND x04pfj.ident_estado = estad.ident_estado
                 AND x04pfj.ident_fis_jur = dwt07.ident_fis_jur
                 AND cod_class_doc_fis IN ( '2'
                                          , '3' )
                 AND dwt07.situacao = 'S'
                 AND dwt07.cod_empresa = mcod_empresa
                 AND dwt07.cod_estab = ccd_estab
                 AND TO_CHAR ( dwt07.data_emissao
                             , 'DD/MM/YYYY' ) BETWEEN pdat_ini
                                                  AND pdat_fim
                 AND dwt07.movto_e_s = DECODE ( ccd_tipo,  3, dwt07.movto_e_s,  2, '9',  '1' )
                 AND det1.id_parametro = param.id_parametros
                 AND param.id_parametros = festab.id_parametros
                 AND festab.cod_empresa = dwt07.cod_empresa
                 AND festab.cod_estab = dwt07.cod_estab
                 AND det1.nome_param = 'Especie'
                 AND det1.conteudo = x2005.cod_docto
                 AND NOT EXISTS
                         (SELECT 1
                            FROM dwt_itens_serv dwt09
                           WHERE dwt07.cod_empresa = dwt09.cod_empresa
                             AND dwt07.cod_estab = dwt09.cod_estab
                             AND dwt07.num_docfis = dwt09.num_docfis
                             AND dwt07.ident_fis_jur = dwt09.ident_fis_jur
                             AND dwt07.data_fiscal = dwt09.data_fiscal)
            GROUP BY dwt07.cod_estab
                   , dwt07.num_docfis
                   , TO_CHAR ( dwt07.data_emissao
                             , 'DDMMYYYY' )
                   , x2005.cod_docto
                   , dwt07.serie_docfis
                   , LPAD ( DECODE ( x04pfj.ind_contem_cod, 4, '0', x04pfj.cpf_cgc )
                          , 14
                          , '0' )
                   , dwt07.data_fiscal
                   , dwt07.movto_e_s
                   , dwt07.cod_class_doc_fis
                   , x04pfj.cidade
                   , x04pfj.cod_municipio
                   , x04pfj.razao_social
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
                   , NVL ( dwt07.nro_aidf_nf, 0 )
                   , dwt07.movto_e_s
                   , SUBSTR ( LPAD ( dwt07.num_docfis_ref
                                   , 6
                                   , '0' )
                            , 1
                            , 6 )
                   , TO_CHAR ( dwt07.dat_di
                             , 'DDMMYYYY' )
                   , dwt07.obs_compl_motivo
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
            ORDER BY 3
                   , 1
                   , 6
                   , 2
                   , 11
                   , 8;

        -- Fim Cr02

        PROCEDURE reg_02_03_04
        IS
        BEGIN
            FOR mreg1 IN c2 ( p_cod_estab
                            , pdat_ini
                            , pdat_fim
                            , ptp_docto ) LOOP
                --if MREG1.situacao = '1' and MREG1.movto_e_s = '9' then

                --           if MREG1.agrup='S' then -- carlos

                -- tratamento das notas agrupadas registro 02
                IF mreg1.especie IN ( '4'
                                    , '7'
                                    , '13' )
                OR ( mreg1.especie IN ( '11'
                                      , '12'
                                      , '14'
                                      , '15' )
                AND mreg1.tam_cgc = 11 ) THEN
                    IF ( v_nota_ant = 0 )
                    OR ( ( v_nota_ant + 1 ) = mreg1.num_docfis ) THEN
                        IF mreg1.cod_servico = 'SEM IT' THEN
                            v_item := '2';
                        ELSE
                            v_item := '1';
                        END IF;

                        IF mreg1.vlr_tributo_iss > 0
                        OR mreg1.vlr_tributo_iss07 > 0 THEN
                            v_trib := 1;
                        ELSE
                            v_trib := '2';
                        END IF;

                        IF v_nota_ini = 0 THEN
                            v_nota_ini := mreg1.num_docfis;
                        END IF;

                        v_nota_ant := mreg1.num_docfis;
                        v_data_emissao := mreg1.data_emissao;
                        v_cod_servico := mreg1.cod_servico;
                        v_serie_docfis := mreg1.serie_docfis;
                        v_cpf_cgc := mreg1.cpf_cgc;
                        v_situacao := mreg1.situacao;
                        v_num_ini_controle := mreg1.num_ini_controle;
                        v_num_fim_controle := mreg1.num_final_controle;
                        v_vlr_tot_nota := mreg1.vlr_tot_nota;
                        v_vlr_base_iss_1 := mreg1.vlr_base_iss_1;
                        v_vlr_servico := mreg1.vlr_servico;
                        v_vlr_base_iss_1_07 := mreg1.vlr_base_iss_1_07;
                        v_tomador := v_tomador;
                        v_nro_aidf_nf := mreg1.nro_aidf_nf;
                        v_movto_e_s := mreg1.movto_e_s;
                    ELSE
                        IF UPPER ( mreg1.uf ) <> 'EX' THEN
                            IF mreg1.tam_cgc = 14 THEN
                                v_tomador := '2';
                            ELSIF mreg1.tam_cgc = 11 THEN
                                v_tomador := '1';
                            END IF;
                        ELSE
                            v_tomador := '3';
                        END IF;

                        mlinha := NULL;
                        mlinha :=
                            lib_str.w ( mlinha
                                      , '02'
                                      , 1 ); -- Tipo de Registro
                        mlinha :=
                            lib_str.w ( mlinha
                                      , mreg1.data_emissao
                                      , 3 );
                        mlinha :=
                            lib_str.w ( mlinha
                                      , LPAD ( mreg1.especie
                                             , 2
                                             , '0' )
                                      , 11 ); -- especie
                        mlinha :=
                            lib_str.w ( mlinha
                                      , mreg1.serie_docfis
                                      , 13 );
                        mlinha :=
                            lib_str.w ( mlinha
                                      , LPAD ( v_nota_ini
                                             , 6
                                             , '0' )
                                      , 16 ); -- numero inicial docto
                        mlinha :=
                            lib_str.w ( mlinha
                                      , LPAD ( '0'
                                             , 6
                                             , '0' )
                                      , 22 ); -- numero final docto
                        mlinha :=
                            lib_str.w ( mlinha
                                      , LPAD ( mreg1.num_ini_controle
                                             , 6
                                             , '0' )
                                      , 28 ); -- numero inicial formulario
                        mlinha :=
                            lib_str.w ( mlinha
                                      , LPAD ( mreg1.num_final_controle
                                             , 6
                                             , '0' )
                                      , 34 ); -- numero final formulario
                        mlinha :=
                            lib_str.w ( mlinha
                                      , v_tomador
                                      , 40 ); -- tipo tomador
                        mlinha :=
                            lib_str.w ( mlinha
                                      , mreg1.cpf_cgc
                                      , 41 ); -- CPF/CNPJ do Tomador
                        mlinha :=
                            lib_str.w ( mlinha
                                      , LPAD ( mreg1.nro_aidf_nf
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
                    END IF;

                    -- tratamento dos itens com intervalo registro 03
                    IF ( v_aliq_ant = 0 )
                    OR ( v_aliq_ant = mreg1.aliq_tributo_iss )
                   AND ( v_cod_servico_ant = 0 )
                    OR ( v_cod_servico_ant = mreg1.cod_servico ) THEN
                        IF mreg1.vlr_base_iss_2 > 0 THEN
                            v_aliq := '06'; -- identificador aliquota MREG1.ind_aliquota
                        ELSIF mreg1.vlr_base_iss_3 > 0 THEN
                            v_aliq := '05';
                        ELSIF mreg1.aliq_tributo_iss = TO_NUMBER ( 0.5 ) THEN
                            v_aliq := '01';
                        ELSIF mreg1.aliq_tributo_iss = '2' THEN
                            v_aliq := '02';
                        ELSIF mreg1.aliq_tributo_iss = '3' THEN
                            v_aliq := '03';
                        ELSIF mreg1.aliq_tributo_iss = '5' THEN
                            v_aliq := '04';
                        END IF;

                        v_cod_servico_ant := mreg1.cod_servico;
                        v_aliq_ant := mreg1.aliq_tributo_iss;
                        v_nota_ant := mreg1.num_docfis;
                        v_cod_servico := mreg1.cod_servico;
                        v_vlr_servico := v_vlr_servico + mreg1.vlr_servico;
                        v_desconto := v_desconto + mreg1.desconto;

                        IF v_trib = 2 THEN
                            v_vlr_tributo_iss := v_vlr_tributo_iss + mreg1.vlr_tributo_iss;
                        ELSE
                            v_vlr_tributo_iss := 0;
                        END IF;
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
                                      , LPAD ( mreg1.aliq_tributo_iss
                                             , 2
                                             , '0' )
                                      , 9 ); -- identificador aliquota MREG1.ind_aliquota
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
                    OR ( ( v_nota_ant + 1 ) = mreg1.num_docfis ) THEN
                        IF v_aliq_ant = mreg1.aliq_tributo_iss THEN
                            IF ( v_cod_servico_ant = 0 )
                            OR ( v_cod_servico_ant = mreg1.cod_servico ) THEN
                                IF v_nota_ini = 0 THEN
                                    v_nota_ini := mreg1.num_docfis;
                                END IF;

                                IF mreg1.cod_servico = 'SEM IT'
                               AND mreg1.class_docfis = 2 THEN
                                    v_tot_base := v_tot_base + mreg1.vlr_base_iss_1_07;
                                    v_tot_serv := v_tot_serv + mreg1.vlr_tot_nota;
                                ELSIF mreg1.cod_servico = 'SEM IT'
                                  AND mreg1.class_docfis = 3 THEN
                                    v_tot_base := v_tot_base + mreg1.vlr_base_iss_1_07;
                                    v_tot_serv := v_tot_serv + mreg1.vlr_tom_servico;
                                ELSIF mreg1.cod_servico <> 'SEM IT' THEN
                                    v_tot_base := v_tot_base + mreg1.vlr_base_iss_1;
                                    v_tot_serv := v_tot_serv + mreg1.vlr_servico;
                                END IF;

                                v_cod_servico_ant := mreg1.cod_servico;
                                v_aliq_ant := mreg1.aliq_tributo_iss;
                                v_nota_ant := mreg1.num_docfis;
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

                ELSE
                    -- carlos

                    -- tratamento do registro 02 sem intervalo

                    IF chave IS NULL
                    OR chave = mreg1.num_docfis || mreg1.data_fiscal || mreg1.cod_servico THEN
                        IF mreg1.cod_servico = 'SEM IT' THEN
                            v_item := '2';
                        ELSE
                            v_item := '1';
                        END IF;

                        IF mreg1.vlr_tributo_iss > 0
                        OR mreg1.vlr_tributo_iss07 > 0 THEN
                            v_trib := 1;
                        ELSE
                            v_trib := '2';
                        END IF;

                        IF UPPER ( mreg1.uf ) <> 'EX' THEN
                            IF mreg1.tam_cgc = 14 THEN
                                v_tomador := '2';
                            ELSIF mreg1.tam_cgc = 11 THEN
                                v_tomador := '1';
                            END IF;
                        ELSE
                            v_tomador := '3';
                        END IF;

                        v_data_emissao := mreg1.data_emissao;
                        v_especie := mreg1.especie;
                        v_serie_docfis := mreg1.serie_docfis;
                        v_nota_ini := mreg1.num_docfis;
                        v_nota_ant := mreg1.num_docfis;
                        v_cpf_cgc := mreg1.cpf_cgc;
                        v_num_ini_controle := mreg1.num_ini_controle;
                        v_num_fim_controle := mreg1.num_final_controle;
                        v_nro_aidf_nf := mreg1.nro_aidf_nf;

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
                                      , LPAD ( '0'
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

                        chave :=
                            TO_CHAR ( NVL ( v_nota_ini, '0' ) ) || v_data_emissao || NVL ( mreg1.cod_servico, '0' );

                        v_tomador := NULL;
                        v_item := NULL;
                        v_nota_ant := mreg1.num_docfis;
                        v_cod_servico := 0;

                        count_reg := count_reg + 1;
                    END IF;

                    -- REGISTRO 03 - nf normal Serviços Emitidos - Linha de registro da tabela de itens de Documentos Fiscais Emitidos
                    --        FOR MREG1 IN C2(P_COD_ESTAB, pdat_ini, pdat_fim, ptp_docto) LOOP

                    --     if MREG1.agrup='S' then -- carlos

                    --dar tratamento com somatorio por codigo de servico
                    IF mreg1.cod_servico <> 'SEM IT' THEN
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
                               WHERE dwt07.cod_empresa = mcod_empresa
                                 AND dwt07.cod_estab = p_cod_estab
                                 AND dwt07.movto_e_s = '9'
                                 AND TO_CHAR ( dwt07.data_emissao
                                             , 'DD/MM/YYYY' ) BETWEEN pdat_ini
                                                                  AND pdat_fim -- '02/2005'
                                 AND dwt07.cod_class_doc_fis IN ( '2'
                                                                , '3' )
                                 AND dwt07.situacao = 'N'
                                 AND dwt07.ident_docto_fiscal = dwt09.ident_docto_fiscal
                                 AND dwt07.ident_fis_jur = x04pfj.ident_fis_jur
                                 AND dwt09.ident_servico = x2018.ident_servico
                                 AND x04pfj.ident_estado = estad.ident_estado
                                 AND dwt07.ident_docto = x2005.ident_docto
                                 AND det.id_parametro = param.id_parametros
                                 AND det1.id_parametro = param.id_parametros
                                 AND param.id_parametros = festab.id_parametros
                                 AND det.nome_param = 'Serviço'
                                 AND festab.cod_empresa = dwt07.cod_empresa
                                 AND festab.cod_estab = dwt07.cod_estab
                                 AND det1.nome_param = 'Especie'
                                 AND det.conteudo = x2018.cod_servico
                                 AND det1.conteudo = x2005.cod_docto
                                 AND    TO_NUMBER (    dwt09.num_docfis
                                                    || TO_CHAR ( dwt09.data_fiscal
                                                               , 'DDMMYYYY' ) )
                                     || SUBSTR ( det.valor
                                               , 1
                                               , 6 ) = TO_NUMBER ( chave )
                            GROUP BY SUBSTR ( det.valor
                                            , 1
                                            , 6 )
                                   , NVL ( dwt09.aliq_tributo_iss, 0 );
                        EXCEPTION
                            WHEN OTHERS THEN
                                chave := NULL;
                        END;

                        --||serie_docfis)

                        IF v_vlr_base_iss_2 > 0 THEN
                            v_aliq := '06'; -- identificador aliquota MREG1.ind_aliquota
                        ELSIF v_vlr_base_iss_3 > 0 THEN
                            v_aliq := '05';
                        ELSIF mreg1.aliq_tributo_iss = TO_NUMBER ( 0.5 ) THEN
                            v_aliq := '01';
                        ELSIF mreg1.aliq_tributo_iss = '2' THEN
                            v_aliq := '02';
                        ELSIF mreg1.aliq_tributo_iss = '3' THEN
                            v_aliq := '03';
                        ELSIF mreg1.aliq_tributo_iss = '5' THEN
                            v_aliq := '04';
                        END IF;

                        /*while chave = to_char(MREG1.num_docfis||MREG1.data_fiscal)
                         --and (cont_item <> 0)
                         or v_num_item_ini = '999' loop

                        if cont_item is null then
                           v_num_item_ini := '998';
                            cont_item := v_num_item;
                        end if;

                        */

                        /*                     v_vlr_servico     := v_vlr_servico     + MREG1.vlr_servico;
                                             v_desconto        := v_desconto        + MREG1.desconto;*/
                        v_vlr_tributo_iss := mreg1.vlr_tributo_iss;

                        IF v_trib = '1' THEN
                            v_base := v_vlr_base_iss_1;
                        --V_VLR_BASE_ISS_1 := 0;
                        END IF;

                        IF mreg1.cod_servico = 'SEM IT' THEN
                            v_vlr_servico := mreg1.vlr_tot_nota;
                        END IF;

                        IF mreg1.cod_servico = 'SEM IT' THEN
                            v_vlr_tributo_iss := mreg1.vlr_tributo_iss;
                        ELSE
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
                                      , 9 ); -- identificador aliquota MREG1.ind_aliquota
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

                        --- montagem do registro 04

                        IF v_trib = '1' THEN
                            IF mreg1.cod_servico = 'SEM IT'
                           AND mreg1.class_docfis = 2 THEN
                                v_tot_base := v_tot_base + mreg1.vlr_base_iss_1_07;
                                v_tot_serv := v_tot_serv + mreg1.vlr_tot_nota;
                            ELSIF mreg1.cod_servico = 'SEM IT'
                              AND mreg1.class_docfis = 3 THEN
                                v_tot_base := v_tot_base + mreg1.vlr_base_iss_1_07;
                                v_tot_serv := v_tot_serv + mreg1.vlr_tom_servico;
                            ELSIF mreg1.cod_servico <> 'SEM IT'
                              AND mreg1.vlr_tributo_iss07 > 0
                              AND mreg1.vlr_base_iss_1 = 0 THEN
                                v_tot_base := v_base;
                                v_tot_serv := v_vlr_servico;
                            ELSE
                                v_tot_serv := v_vlr_servico;
                                v_tot_base := v_base;
                            END IF;
                        ELSE
                            IF mreg1.vlr_servico IS NULL THEN
                                v_tot_serv := v_tot_serv + mreg1.vlr_tot_nota;
                            ELSE
                                v_tot_base := v_tot_base + v_vlr_base_iss_1;
                                v_tot_serv := v_tot_serv + mreg1.vlr_servico;
                            END IF;
                        END IF;

                        -- fim reg 04

                        v_aliq_ant := v_aliq;
                        v_cod_servico_ant := v_cod_servico;
                        v_vlr_servico := 0;
                        v_desconto := 0;
                        v_vlr_tributo_iss := 0;
                        v_nota_ant := mreg1.num_docfis;

                        chave := NULL;

                        cont_item := cont_item - 1;

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

                        -- V_COD_SERVICO_ANT := 0;
                        v_nota_ant := mreg1.num_docfis;

                        -- V_ALIQ_ANT := 0;
                        v_nota_ini := 0;
                        v_tot_serv := 0;
                        v_tot_base := 0;

                        v_trib := NULL;

                        count_reg := count_reg + 1;
                    END IF;
                END IF;
            --end if;

            END LOOP;

            v_nota_ant := 0;
            v_nota_ini := 0;
        END reg_02_03_04;

        PROCEDURE reg_05
        IS
        BEGIN
            FOR mreg2 IN c3 ( p_cod_estab
                            , pdat_ini
                            , pdat_fim
                            , ptp_docto ) LOOP
                v_data_emissao := mreg2.data_emissao;
                v_especie := mreg2.especie;
                v_serie_docfis := mreg2.serie_docfis;
                v_cpf_cgc := mreg2.cpf_cgc;
                v_vlr_tot_nota := mreg2.vlr_tot_nota;
                v_nota_ini := mreg2.num_docfis;
                v_vlr_base_iss_1_07 := mreg2.vlr_tributo_iss07;
                v_vlr_tributo_iss := mreg2.vlr_tributo_iss;

                IF mreg2.cod_servico = 'SEM IT'
               AND mreg2.class_docfis = '3' THEN
                    v_vlr_servico := mreg2.vlr_tom_servico;
                ELSE
                    v_vlr_servico := mreg2.vlr_servico;
                END IF;

                IF mreg2.uf = 'EX' THEN
                    v_uf := 3; -- 1 cgc 2 cpf
                ELSIF mreg2.tam_cgc = 14 THEN
                    v_uf := 2; -- 1 cgc 2 cpf
                ELSIF mreg2.tam_cgc < 14 THEN
                    v_uf := 1; -- 1 cgc 2 cpf
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

                IF mreg2.cod_servico = 'SEM IT'
               AND mreg2.class_docfis = '2' THEN
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
                                  , LPAD ( ( v_vlr_tributo_iss * 100 )
                                         , 14
                                         , 0 )
                                  , 65 );
                ELSIF mreg2.cod_servico = 'SEM IT'
                  AND mreg2.class_docfis = '3' THEN
                    -- notas mercadoria e servico
                    mlinha :=
                        lib_str.w ( mlinha
                                  , LPAD ( ( mreg2.vlr_tom_servico * 100 )
                                         , 14
                                         , 0 )
                                  , 37 );
                    mlinha :=
                        lib_str.w ( mlinha
                                  , LPAD ( ( v_vlr_tot_nota * 100 )
                                         , 14
                                         , 0 )
                                  , 51 );
                    mlinha :=
                        lib_str.w ( mlinha
                                  , LPAD ( ( v_vlr_tributo_iss * 100 )
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
            END LOOP;
        END reg_05;

        PROCEDURE reg_08_09
        IS
        BEGIN
            v_cod_servico_ant := 0;
            v_nota_ant := 0;
            v_aliq_ant := 0;
            v_nota_ini := 0;
            v_vlr_tot_nota := 0;

            FOR mreg3 IN c1 ( p_cod_estab
                            , pdat_ini
                            , pdat_fim
                            , ptp_docto ) LOOP
                IF mreg3.movto_e_s = '9' THEN
                    --        if MREG3.agrup='S' then -- carlos
                    IF mreg3.especie IN ( '4'
                                        , '7'
                                        , '13' )
                    OR ( mreg3.especie IN ( '11'
                                          , '12'
                                          , '14'
                                          , '15' )
                    AND mreg3.tam_cgc = 11 ) THEN
                        IF ( v_nota_ant = 0 )
                        OR ( ( v_nota_ant + 1 ) = mreg3.num_docfis ) THEN
                            IF v_nota_ini = 0 THEN
                                v_nota_ini := mreg3.num_docfis;
                            END IF;

                            v_nota_ant := mreg3.num_docfis;

                            IF mreg3.cod_servico = 'SEM IT' THEN
                                v_prest_serv := '2';
                                v_vlr_tot_nota := v_vlr_tot_nota + mreg3.vlr_tot_nota;
                            ELSE
                                v_prest_serv := '1';
                                v_vlr_tot_nota := v_vlr_tot_nota + mreg3.vlr_servico;
                            END IF;

                            IF mreg3.vlr_tributo_iss > 0
                            OR mreg3.vlr_tributo_iss07 > 0 THEN
                                v_destaque := '1';
                            ELSE
                                v_destaque := '2';
                            END IF;

                            IF mreg3.tam_cgc = 14 THEN
                                v_tomador := '2';
                            ELSIF mreg3.tam_cgc = 11 THEN
                                v_tomador := '1';
                            ELSE
                                v_tomador := '3';
                            END IF;

                            IF mreg3.num_docfis_ref IS NULL THEN
                                v_situacao := 4;
                            ELSE
                                v_situacao := 5;
                            END IF;

                            IF mreg3.dat_cancelamento IS NULL THEN
                                v_data_cancelamento := '00000000';
                            ELSE
                                v_data_cancelamento := mreg3.dat_cancelamento;
                            END IF;

                            v_data_emissao := mreg3.data_emissao;
                            v_cod_servico := mreg3.cod_servico;
                            v_serie_docfis := mreg3.serie_docfis;
                            v_cpf_cgc := mreg3.cpf_cgc;
                            v_num_ini_controle := mreg3.num_ini_controle;
                            v_num_fim_controle := mreg3.num_final_controle;
                            v_nro_aidf_nf := mreg3.nro_aidf_nf;
                            v_movto_e_s := mreg3.movto_e_s;
                            v_num_docfis_ref := mreg3.num_docfis_ref;
                            v_data_docfis_ref := mreg3.data_docfis_ref;
                            v_obs_compl := mreg3.obs_compl;
                            v_especie := mreg3.especie;
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
                                          , LPAD ( '0'
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
                        -- carlos

                        -- tratamento do registro 08 sem intervalo

                        IF chave IS NULL
                        OR chave = mreg3.num_docfis || mreg3.data_fiscal || mreg3.cod_servico THEN
                            IF mreg3.cod_servico = 'SEM IT' THEN
                                v_prest_serv := '2';
                                v_vlr_tot_nota := v_vlr_tot_nota + mreg3.vlr_tot_nota;
                            ELSE
                                v_prest_serv := '1';
                                v_vlr_tot_nota := v_vlr_tot_nota + mreg3.vlr_servico;
                            END IF;

                            IF mreg3.vlr_tributo_iss > 0
                            OR mreg3.vlr_tributo_iss07 > 0 THEN
                                v_destaque := '2';
                            ELSE
                                v_destaque := '1';
                            END IF;

                            IF mreg3.cod_servico = 'SEM IT' THEN
                                v_item := '2';
                            ELSE
                                v_item := '1';
                            END IF;

                            IF mreg3.tam_cgc = 14 THEN
                                v_tomador := '2';
                            ELSIF mreg3.tam_cgc = 11 THEN
                                v_tomador := '1';
                            ELSE
                                v_tomador := '3';
                            END IF;

                            IF mreg3.num_docfis_ref IS NULL THEN
                                v_situacao := 4;
                            ELSE
                                v_situacao := 5;
                            END IF;

                            IF mreg3.dat_cancelamento IS NULL THEN
                                v_data_cancelamento := '00000000';
                            ELSE
                                v_data_cancelamento := mreg3.dat_cancelamento;
                            END IF;

                            v_data_emissao := mreg3.data_emissao;
                            v_especie := mreg3.especie;
                            v_serie_docfis := mreg3.serie_docfis;
                            v_nota_ini := mreg3.num_docfis;
                            v_nota_ant := mreg3.num_docfis;
                            v_cpf_cgc := mreg3.cpf_cgc;
                            v_num_ini_controle := mreg3.num_ini_controle;
                            v_num_fim_controle := mreg3.num_final_controle;
                            v_nro_aidf_nf := mreg3.nro_aidf_nf;
                            v_num_docfis_ref := mreg3.num_docfis_ref;
                            v_data_docfis_ref := mreg3.data_docfis_ref;
                            v_obs_compl := mreg3.obs_compl;

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
                                          , LPAD ( '0'
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

                            IF mreg3.cod_servico = 'SEM IT' THEN
                                v_cod_servico := NULL;
                            ELSE
                                v_cod_servico := mreg3.cod_servico;
                            END IF;

                            chave := mreg3.num_docfis || mreg3.data_fiscal || v_cod_servico;

                            /*                      v_tomador            := null;
                            v_item               := null;
                            v_nota_ant           := MREG3.num_docfis;*/
                            --                      v_cod_servico := 0;
                            v_destaque := NULL;
                            v_prest_serv := NULL;
                        END IF;

                        -- REGISTRO 08 - nf normal Serviços Emitidos - Linha de registro da tabela de itens de Documentos Fiscais Emitidos
                        --        FOR MREG3 IN C2(P_COD_ESTAB, pdat_ini, pdat_fim, ptp_docto) LOOP

                        --     if MREG3.agrup='S' then -- carlos

                        --dar tratamento com somatorio por codigo de servico
                        IF mreg3.cod_servico <> 'SEM IT' THEN
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
                                   WHERE dwt07.cod_empresa = mcod_empresa
                                     AND dwt07.cod_estab = p_cod_estab
                                     AND dwt07.movto_e_s = '9'
                                     AND TO_CHAR ( dwt07.data_emissao
                                                 , 'DD/MM/YYYY' ) BETWEEN pdat_ini
                                                                      AND pdat_fim -- '02/2005'
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
                                     AND festab.cod_empresa = dwt07.cod_empresa
                                     AND festab.cod_estab = dwt07.cod_estab
                                     AND det1.nome_param = 'Especie'
                                     AND det.conteudo = x2018.cod_servico
                                     AND det1.conteudo = x2005.cod_docto
                                     AND TO_NUMBER (    dwt09.num_docfis
                                                     || TO_CHAR ( dwt09.data_fiscal
                                                                , 'DDMMYYYY' )
                                                     || SUBSTR ( det.valor
                                                               , 1
                                                               , 6 ) ) = TO_NUMBER ( chave )
                                GROUP BY SUBSTR ( det.valor
                                                , 1
                                                , 6 )
                                       , NVL ( dwt09.aliq_tributo_iss, 0 );
                            EXCEPTION
                                WHEN OTHERS THEN
                                    chave := NULL;
                                    v_vlr_servico := mreg3.vlr_servico;
                                    v_desconto := mreg3.desconto;
                                    v_vlr_base_iss_1 := mreg3.vlr_base_iss_1_07;
                            END;
                        END IF;

                        IF v_vlr_base_iss_2 > 0 THEN
                            v_aliq := '06'; -- identificador aliquota MREG3.ind_aliquota
                        ELSIF v_vlr_base_iss_3 > 0 THEN
                            v_aliq := '05';
                        ELSIF mreg3.aliq_tributo_iss = TO_NUMBER ( 0.5 ) THEN
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
                            v_vlr_base_iss_1 := 0;
                        END IF;

                        IF mreg3.cod_servico = 'SEM IT' THEN
                            v_vlr_servico := mreg3.vlr_servico;
                            v_desconto := mreg3.desconto;
                        END IF;

                        IF v_destaque = 1 THEN
                            v_vlr_tributo_iss := 0;
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
                                      , 9 ); -- identificador aliquota MREG3.ind_aliquota
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

                        --- montagem do registro 09

                        IF v_trib = '1' THEN
                            IF mreg3.cod_servico = 'SEM IT'
                           AND mreg3.class_docfis = 2 THEN
                                v_tot_base := v_tot_base + mreg3.vlr_base_iss_1_07;
                                v_tot_serv := v_tot_serv + mreg3.vlr_tot_nota;
                            ELSIF mreg3.cod_servico = 'SEM IT'
                              AND mreg3.class_docfis = 3 THEN
                                v_tot_base := v_tot_base + mreg3.vlr_base_iss_1_07;
                                v_tot_serv := v_tot_serv + mreg3.vlr_tom_servico;
                            ELSIF mreg3.cod_servico <> 'SEM IT'
                              AND mreg3.vlr_tributo_iss07 > 0
                              AND mreg3.vlr_base_iss_1 = 0 THEN
                                v_tot_base := v_tot_base + v_base;
                                v_tot_serv := v_tot_serv + v_vlr_servico;
                            ELSE
                                v_tot_serv := v_tot_serv + v_vlr_servico;
                                v_tot_base := v_tot_base + v_base;
                            END IF;
                        ELSE
                            IF mreg3.vlr_servico IS NULL
                            OR mreg3.vlr_servico = 0 THEN
                                v_tot_serv := v_tot_serv + mreg3.vlr_tot_nota;
                            ELSE
                                v_tot_base := v_tot_base + v_vlr_base_iss_1;
                                v_tot_serv := v_tot_serv + mreg3.vlr_servico;
                            END IF;
                        END IF;

                        -- fim reg 10

                        v_aliq_ant := v_aliq;
                        v_cod_servico_ant := v_cod_servico;
                        v_vlr_servico := 0;
                        v_desconto := 0;
                        v_vlr_tributo_iss := 0;
                        v_nota_ant := mreg3.num_docfis;

                        chave := NULL;

                        cont_item := cont_item - 1;


                        -- REGISTRO 10 - nf normal Serviços Emitidos - Linha de registro com o Valor Total do Documento Fiscal Emitido

                        --      FOR MREG3 IN C2(P_COD_ESTAB, pdat_ini, pdat_fim, ptp_docto) LOOP

                        --             if MREG3.agrup='S' then -- carlos

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

                        v_cod_servico_ant := 0;
                        v_nota_ant := mreg3.num_docfis;

                        v_aliq_ant := 0;
                        v_nota_ini := 0;
                        v_tot_serv := 0;
                        v_tot_base := 0;

                        v_trib := NULL;

                        count_reg := count_reg + 1;
                    --       end if;
                    -- chave := null;
                    END IF;

                    chave := NULL;
                END IF;
            END LOOP;
        END;

        PROCEDURE reg_10
        IS
        BEGIN
            -- Inicializa as variaveis
            v_total_base_s_nf := 0;
            v_total_serv_s_nf := 0;
            v_total_base := 0;
            v_total_serv := 0;
            v_tot_base := 0;
            v_tot_serv := 0;
            v_situacao := NULL;
            v_movto_e_s := NULL;
            v_cod_servico_ant := 0;
            v_aliq_ant := 0;
            v_nota_ant := 0;

            FOR mreg4 IN c1 ( p_cod_estab
                            , pdat_ini
                            , pdat_fim
                            , ptp_docto ) LOOP
                IF mreg4.movto_e_s = '9' THEN
                    IF ( v_nota_ant = 0 )
                    OR ( ( v_nota_ant + 1 ) = mreg4.num_docfis ) THEN
                        IF ( v_aliq_ant = 0 )
                        OR v_aliq_ant = mreg4.aliq_tributo_iss THEN
                            IF ( v_cod_servico_ant = '0' )
                            OR ( v_cod_servico_ant = mreg4.cod_servico ) THEN
                                IF v_nota_ini = 0 THEN
                                    v_nota_ini := mreg4.num_docfis;
                                END IF;

                                IF mreg4.cod_servico = 'SEM IT'
                               AND mreg4.class_docfis = 2 THEN
                                    v_tot_base := v_tot_base + mreg4.vlr_base_iss_1_07;
                                    v_tot_serv := v_tot_serv + mreg4.vlr_tot_nota;
                                ELSIF mreg4.cod_servico = 'SEM IT'
                                  AND mreg4.class_docfis = 3 THEN
                                    v_tot_base := v_tot_base + mreg4.vlr_base_iss_1_07;
                                    v_tot_serv := v_tot_serv + mreg4.vlr_tom_servico;
                                ELSIF mreg4.cod_servico <> 'SEM IT' THEN
                                    v_tot_base := v_tot_base + mreg4.vlr_base_iss_1;
                                    v_tot_serv := v_tot_serv + mreg4.vlr_servico;
                                END IF;

                                v_cod_servico_ant := mreg4.cod_servico;
                                v_aliq_ant := mreg4.aliq_tributo_iss;
                                v_nota_ant := mreg4.num_docfis;
                            END IF;
                        END IF;
                    ELSE
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

                        v_cod_servico_ant := 0;
                        v_nota_ant := 0;
                        v_aliq_ant := 0;
                        v_nota_ini := 0;

                        count_reg := count_reg + 1;
                    END IF;
                END IF;
            END LOOP;
        END reg_10;
    -------------------------------
    -- INICIO DO PROGRAMA PRINCIPAL
    -------------------------------
    BEGIN
        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );

        -- Cria Processo
        mproc_id :=
            lib_proc.new ( 'EST_DIEF_RJ_CPROC'
                         , 48
                         , 150 );
        lib_proc.add_tipo ( mproc_id
                          , 1
                          , 'DIEF-RIO' || p_cod_estab
                          , 2 );
        lib_proc.add_log ( 'Processo ' || mproc_id
                         , 1 );


        BEGIN
            SELECT LPAD ( NVL ( insc_municipal, '0' )
                        , 8
                        , '0' )
              INTO insc_municipal_w
              FROM estabelecimento
             WHERE cod_estab = p_cod_estab
               AND cod_empresa = mcod_empresa;
        EXCEPTION
            WHEN OTHERS THEN
                insc_municipal_w := NULL;
        END;

        BEGIN
            pdat_ini :=
                TO_DATE ( TO_CHAR ( p_dat_comp
                                  , 'DD/MM/YYYY' ) );
            pdat_fim := LAST_DAY ( pdat_ini );
        END;

        --Registro 01 header ---

        mlinha := NULL;
        mlinha :=
            lib_str.w ( mlinha
                      , '01'
                      , 1 ); -- Tipo de Registro
        mlinha :=
            lib_str.w ( mlinha
                      , insc_municipal_w
                      , 3 );
        mlinha :=
            lib_str.w ( mlinha
                      , TO_CHAR ( p_dat_comp
                                , 'YYYY' )
                      , 11 );
        mlinha :=
            lib_str.w ( mlinha
                      , TO_CHAR ( p_dat_comp
                                , 'MM' )
                      , 15 );
        lib_proc.add ( mlinha
                     , NULL
                     , NULL
                     , 1 );

        count_reg := count_reg + 1;

        -- REGISTRO 02 - nf normal Serviços Emitidos - Linha de registro da tabela de Documentos Fiscais Emitidos

        reg_02_03_04;

        -- REGISTRO 05 -  - Linha de registro da tabela de Documentos Fiscais Recebidos

        reg_05;

        -- REGISTRO 08 - nf cancelada ou extraviada Servicos Tomados - Linha de registro da tabela de Documentos Fiscais Cancelados
        -- inicilaiza as variaveis

        reg_08_09;

        -- REGISTRO 10 -  Linha de registro com o Valor Total do Documento Fiscal Cancelado

        --    REG_10;

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
                              , '081' );
        mcod_empresa := '081';
        mproc_id :=
            executar ( '01/03/2006'
                     , 3
                     , 'RJ001' );

        --lib_proc.list_output(mproc_id, 1);

        dbms_output.put_line ( '' );
        dbms_output.put_line ( '---Arquivo Magnetico----' );
        dbms_output.put_line ( '' );
        lib_proc.list_output ( mproc_id
                             , 2 );
    END;
END est_dief_rj_cproc;
/
SHOW ERRORS;
