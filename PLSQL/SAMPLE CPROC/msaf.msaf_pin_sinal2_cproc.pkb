Prompt Package Body MSAF_PIN_SINAL2_CPROC;
--
-- MSAF_PIN_SINAL2_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY msaf_pin_sinal2_cproc
IS
    ---------------------------------------------------------------------------------------------------------
    -- Autor         : Valdir Stropa - DW Consulting - MasterSaf
    -- Created       : 10/04/2008
    -- Purpose       : Meio magnetico xml Pin-Sinal
    ---------------------------------------------------------------------------------------------------------

    --variáveis de status

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
        musuario := lib_parametros.recuperar ( 'Usuario' );

        lib_proc.add_param ( pstr
                           , 'Data Geração'
                           , 'Date'
                           , 'Textbox'
                           , 'S'
                           , SYSDATE
                           , 'dd/mm/yyyy' );

        lib_proc.add_param ( pstr
                           , 'Lotes'
                           , 'Varchar2'
                           , 'MULTISELECT'
                           , 'S'
                           , NULL
                           , NULL
                           , 'Select distinct num_lote, num_lote from TB_MSAF_NF_LOTE where data_geracao = :1' );

        RETURN pstr;
    END;

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN '3 - Meio Magnetico de Lote Pin - Sinal';
    END;

    FUNCTION tipo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Pin - Sinal';
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
        RETURN 'Meio Magnetico de Lote';
    END;

    FUNCTION modulo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'ESPECIFICOS';
    END;

    FUNCTION classificacao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'PIN - SINAL';
    END;

    FUNCTION executar ( pdata DATE
                      , plote lib_proc.vartab )
        RETURN INTEGER
    IS
        /* Variaveis de Trabalho */
        mproc_id INTEGER;
        mlinha VARCHAR2 ( 160 );
        v_linha NUMBER := 0;
        v_folha NUMBER := 0;

        v_conta NUMBER := 0;
        v_tot_deb NUMBER := 0;
        v_tot_cre NUMBER := 0;
        v_cod_div VARCHAR2 ( 10 ) := '';

        i INTEGER;
    BEGIN
        -- Cria Processo

        mproc_id :=
            lib_proc.new ( 'MSAF_PIN_SINAL2_CPROC'
                         , 48
                         , 160 );

        DECLARE
        BEGIN
            DECLARE
                v_razao VARCHAR2 ( 50 ) := '';
                v_cnpj VARCHAR2 ( 20 ) := '';
                v_insc VARCHAR2 ( 20 ) := '';
                v_chave VARCHAR2 ( 40 ) := '';
                v_estab VARCHAR2 ( 200 ) := '';
                v_uf VARCHAR2 ( 2 ) := '';
                v_status INTEGER := 0;
                v_tipo_nota CHAR ( 1 ) := '';
                v_lote VARCHAR2 ( 20 ) := '';
                v_tab VARCHAR2 ( 20 ) := '	';

                v_num_lote tb_msaf_nf_lote.num_lote%TYPE;
                v_versao VARCHAR2 ( 20 ) := '';
                v_dt_gera VARCHAR2 ( 10 ) := '';
                v_cnpj_dest VARCHAR2 ( 20 ) := '';
                v_cnpj_tran VARCHAR2 ( 20 ) := '';
                v_insc_sufr VARCHAR2 ( 20 ) := '';
                v_uf_dest VARCHAR2 ( 2 ) := '';
                v_uf_orig VARCHAR2 ( 20 ) := '';
                v_qtd_nf INTEGER := 0;
                v_tag_nf VARCHAR2 ( 20 ) := '';
                v_nf VARCHAR2 ( 20 ) := '';
                v_chave_acesso VARCHAR2 ( 20 ) := '';
                v_taxa_zero VARCHAR2 ( 20 ) := '';
                v_inicio CHAR ( 1 ) := '0';
                v_seq_lote INTEGER := 0;
                v_data_emissao VARCHAR2 ( 10 ) := '';
                v_hora_saida VARCHAR2 ( 10 ) := '';
                v_vlr_base_icms_1 VARCHAR2 ( 20 ) := '';
                v_vlr_tributo_icms VARCHAR2 ( 20 ) := '';
                v_vlr_frete VARCHAR2 ( 20 ) := '';
                v_vlr_seguro VARCHAR2 ( 20 ) := '';
                v_vlr_outras VARCHAR2 ( 20 ) := '';
                v_vlr_tot_nota VARCHAR2 ( 20 ) := '';
                v_vlr_pis VARCHAR2 ( 20 ) := '';
                v_vlr_cofins VARCHAR2 ( 20 ) := '';
                v_placa_veiculo VARCHAR2 ( 20 ) := '';
                v_uf_cam VARCHAR2 ( 2 ) := '';
                v_insc_trans VARCHAR2 ( 20 ) := '';
                v_qtd_volumes VARCHAR2 ( 20 ) := '';
                v_cod_volume VARCHAR2 ( 20 ) := '';
                v_peso_bruto VARCHAR2 ( 20 ) := '';
                v_peso_liquido VARCHAR2 ( 20 ) := '';
                v_base_icmss_substituido VARCHAR2 ( 20 ) := '';
                v_vlr_icmss_substituido VARCHAR2 ( 20 ) := '';
                v_cod_produto VARCHAR2 ( 35 ) := '';
                v_desc_item VARCHAR2 ( 120 ) := '';
                v_cod_nbm VARCHAR2 ( 10 ) := '';
                v_cod_ncm VARCHAR2 ( 10 ) := '';
                v_cod_medida VARCHAR2 ( 20 ) := '';
                v_vlr_unit VARCHAR2 ( 20 ) := '';
                v_vlr_item VARCHAR2 ( 20 ) := '';
                v_sit_trib VARCHAR2 ( 10 ) := '';
                v_aliq_icms VARCHAR2 ( 8 ) := '';
                v_aliq_ipi VARCHAR2 ( 8 ) := '';
                v_vlr_item_ipi VARCHAR2 ( 20 ) := '';
                v_cnpj_remetente VARCHAR2 ( 20 ) := '';
                v_serie_docfis VARCHAR2 ( 20 ) := '';
                v_insc_est VARCHAR2 ( 20 ) := '';
                v_dt_emissao VARCHAR2 ( 10 ) := '';
                v_cfop VARCHAR2 ( 06 ) := '';
                v_cod_modelo VARCHAR2 ( 20 ) := '';
                v_op_debito VARCHAR2 ( 20 ) := '';
                v_dados_adic VARCHAR2 ( 20 ) := '';
                v_vlr_ipi VARCHAR2 ( 20 ) := '';
                v_vlr_tot_item VARCHAR2 ( 20 ) := '';
                v_vlr_abat_icms VARCHAR2 ( 20 ) := '';
                v_frete_pcta VARCHAR2 ( 20 ) := '';
                v_marca_volume VARCHAR2 ( 20 ) := '';
                v_numero_volume VARCHAR2 ( 20 ) := '';
                v_vlr_gnre VARCHAR2 ( 20 ) := '';
                v_dt_vcto_gnre VARCHAR2 ( 20 ) := '';
                v_periodo_gnre VARCHAR2 ( 20 ) := '';
                v_nf_refatura VARCHAR2 ( 20 ) := '';
                v_dt_refatura VARCHAR2 ( 20 ) := '';
                v_ins_suf_ref VARCHAR2 ( 20 ) := '';
                v_ins_est_subs VARCHAR2 ( 20 ) := '';
                v_ind_nf_especial VARCHAR2 ( 1 ) := '';
                v_quantidade VARCHAR2 ( 22 ) := '';
            BEGIN
                i := plote.FIRST;

                WHILE i IS NOT NULL LOOP
                    v_lote := plote ( i );
                    --Cria o processo do lote
                    lib_proc.add_tipo ( mproc_id
                                      , v_seq_lote + 2
                                      , v_lote || '__Pin_Sinal.SIN'
                                      , 2 ); --2 arquivo

                    --Busca o tipo de NF
                    BEGIN
                        SELECT DISTINCT k.tipo_nota
                          INTO v_tipo_nota
                          FROM tb_msaf_nf_lote k
                         WHERE k.num_lote = v_lote
                           AND ROWNUM = 1;
                    EXCEPTION
                        WHEN OTHERS THEN
                            v_tipo_nota := '';
                    END;

                    --Gera o meio magnetico
                    v_inicio := '0';

                    FOR c1 IN ( SELECT a.ROWID linha
                                     , a.cod_empresa
                                     , a.cod_estab
                                     , a.data_fiscal
                                     , a.movto_e_s
                                     , a.norm_dev
                                     , a.ident_docto
                                     , f.cod_modelo
                                     , e.cod_cfo
                                     , a.ident_fis_jur
                                     , a.num_docfis
                                     , a.serie_docfis
                                     , a.sub_serie_docfis
                                     , TO_CHAR ( a.data_geracao
                                               , 'dd/mm/yyyy' )
                                           data_geracao
                                     , a.num_lote
                                     , a.tipo_nota
                                     , b.cpf_cgc
                                     , a.cnpj_transp
                                     , b.insc_suframa
                                     , c.cgc cnpj_remetente
                                     , d.cod_estado
                                     , b.insc_estadual
                                     , dwt07.ident_uf_destino
                                     , dwt07.ident_uf_orig_dest
                                  FROM tb_msaf_nf_lote a
                                     , dwt_docto_fiscal dwt07
                                     , x04_pessoa_fis_jur b
                                     , estabelecimento c
                                     , estado d
                                     , x2012_cod_fiscal e
                                     , x2024_modelo_docto f
                                 WHERE a.ident_fis_jur = b.ident_fis_jur
                                   AND dwt07.cod_empresa = a.cod_empresa
                                   AND dwt07.ident_cfo = e.ident_cfo
                                   AND dwt07.ident_docto = a.ident_docto
                                   AND dwt07.cod_estab = a.cod_estab
                                   AND dwt07.data_fiscal = a.data_fiscal
                                   AND dwt07.norm_dev = a.norm_dev
                                   AND dwt07.num_docfis = a.num_docfis
                                   AND dwt07.ident_modelo = f.ident_modelo
                                   AND dwt07.cod_empresa = c.cod_empresa
                                   AND dwt07.cod_estab = c.cod_estab
                                   AND c.ident_estado = d.ident_estado
                                   AND a.num_lote = v_lote
                                   AND a.tipo_nota = v_tipo_nota
                                   AND a.status = 'G' ) LOOP
                        BEGIN
                            IF c1.tipo_nota = 'E' THEN
                                v_num_lote := c1.num_lote;
                                v_versao := '6.0';
                                v_dt_gera := c1.data_geracao;
                                v_cnpj_dest := c1.cpf_cgc;
                                v_cnpj_tran := c1.cnpj_transp;
                                v_insc_sufr := c1.insc_suframa;


                                --uf destino
                                BEGIN
                                    SELECT b.cod_estado
                                      INTO v_uf_dest
                                      FROM dwt_docto_fiscal dwt07
                                         , estado b
                                     WHERE dwt07.ident_uf_destino = b.ident_estado(+)
                                       AND dwt07.cod_empresa = c1.cod_empresa
                                       AND dwt07.cod_estab = c1.cod_estab
                                       AND dwt07.data_fiscal = c1.data_fiscal
                                       AND dwt07.movto_e_s = c1.movto_e_s
                                       AND dwt07.norm_dev = c1.norm_dev
                                       AND dwt07.ident_docto = c1.ident_docto
                                       AND dwt07.ident_fis_jur = c1.ident_fis_jur
                                       AND dwt07.num_docfis = c1.num_docfis
                                       AND dwt07.serie_docfis = c1.serie_docfis
                                       AND dwt07.sub_serie_docfis = c1.sub_serie_docfis;
                                END;


                                v_uf_orig := c1.cod_estado;

                                --qtde nfs no lote
                                BEGIN
                                    SELECT COUNT ( 1 )
                                      INTO v_qtd_nf
                                      FROM tb_msaf_nf_lote a
                                     WHERE a.num_lote = c1.num_lote;
                                END;


                                --
                                v_tag_nf := '@'; --???
                                v_nf := c1.num_docfis; --???
                                v_chave_acesso := '@'; --???
                                v_taxa_zero := '@'; --???

                                --Inicia a montagem do registro xml
                                IF v_inicio = '0' THEN
                                    --linha 1
                                    mlinha :=
                                        lib_str.w ( ''
                                                  , ''
                                                  , 1 );
                                    mlinha :=
                                        lib_str.w ( mlinha
                                                  , '<?xml version="1.0" encoding="UTF-8"?>'
                                                  , 1 );
                                    lib_proc.add ( mlinha
                                                 , NULL
                                                 , NULL
                                                 , v_seq_lote + 2 );
                                    --linha 2
                                    mlinha := '';
                                    mlinha := '<lote nro="';
                                    mlinha :=
                                           mlinha
                                        || v_num_lote
                                        || '" versao_sw="'
                                        || v_versao
                                        || '" dtEmissao="'
                                        || v_dt_gera
                                        || '">';
                                    lib_proc.add ( mlinha
                                                 , NULL
                                                 , NULL
                                                 , v_seq_lote + 2 );
                                    --linha 3
                                    mlinha := '';
                                    mlinha := v_tab || '<cnpjDestinatario>' || v_cnpj_dest || '</cnpjDestinatario>';
                                    lib_proc.add ( mlinha
                                                 , NULL
                                                 , NULL
                                                 , v_seq_lote + 2 );
                                    --linha 4
                                    mlinha := '';
                                    mlinha := v_tab || '<cnpjTransp>' || v_cnpj_tran || '</cnpjTransp>';
                                    lib_proc.add ( mlinha
                                                 , NULL
                                                 , NULL
                                                 , v_seq_lote + 2 );
                                    --linha 5
                                    mlinha := '';
                                    mlinha :=
                                        v_tab || '<inscSufDestinatario>' || v_insc_sufr || '</inscSufDestinatario>';
                                    lib_proc.add ( mlinha
                                                 , NULL
                                                 , NULL
                                                 , v_seq_lote + 2 );
                                    --linha 6
                                    mlinha := '';
                                    mlinha := v_tab || '<ufDestino>' || v_uf_dest || '</ufDestino>';
                                    lib_proc.add ( mlinha
                                                 , NULL
                                                 , NULL
                                                 , v_seq_lote + 2 );
                                    --linha 7
                                    mlinha := '';
                                    mlinha := v_tab || '<ufOrigem>' || v_uf_orig || '</ufOrigem>';
                                    lib_proc.add ( mlinha
                                                 , NULL
                                                 , NULL
                                                 , v_seq_lote + 2 );
                                    --linha 8
                                    mlinha := '';
                                    mlinha := v_tab || '<qtdeNF>' || v_qtd_nf || '</qtdeNF>';
                                    lib_proc.add ( mlinha
                                                 , NULL
                                                 , NULL
                                                 , v_seq_lote + 2 );
                                    --linha 9
                                    mlinha := '';
                                    mlinha := v_tab || '<notasFiscais>';
                                    lib_proc.add ( mlinha
                                                 , NULL
                                                 , NULL
                                                 , v_seq_lote + 2 );

                                    v_inicio := '1';
                                END IF;

                                --linha N+1
                                mlinha := '';
                                mlinha := v_tab || v_tab || '<notaFiscal chaveAcesso="" txZero="false">' || v_nf;
                                lib_proc.add ( mlinha
                                             , NULL
                                             , NULL
                                             , v_seq_lote + 2 );
                                mlinha := '';
                                mlinha := v_tab || v_tab || '</notaFiscal>';
                                lib_proc.add ( mlinha
                                             , NULL
                                             , NULL
                                             , v_seq_lote + 2 );
                            ELSE
                                --Se NF convencional 'C'

                                v_num_lote := c1.num_lote;
                                v_cfop := c1.cod_cfo;
                                v_cod_modelo := c1.cod_modelo;
                                v_versao := '6.0';
                                v_dt_gera := c1.data_geracao;
                                v_cnpj_dest := c1.cpf_cgc;
                                v_cnpj_tran := c1.cnpj_transp;
                                v_insc_sufr := c1.insc_suframa;

                                --uf destino
                                BEGIN
                                    FOR c_conv
                                        IN ( SELECT NVL ( b.cod_estado, '' )
                                                  , TO_CHAR ( dwt07.data_emissao
                                                            , 'dd/mm/yyyy' )
                                                        data_emissao
                                                  ,    SUBSTR ( SUBSTR ( LPAD ( NVL ( dwt07.hora_saida, 0 )
                                                                              , 6
                                                                              , '0' )
                                                                       , -6 )
                                                              , 1
                                                              , 2 )
                                                    || ':'
                                                    || SUBSTR ( SUBSTR ( LPAD ( NVL ( dwt07.hora_saida, 0 )
                                                                              , 6
                                                                              , '0' )
                                                                       , -6 )
                                                              , 3
                                                              , 2 )
                                                        hora_saida
                                                  , TO_CHAR ( dwt08.vlr_base_icms_1
                                                            , '999999990D00' )
                                                        vlr_base_icms_1
                                                  , TO_CHAR ( dwt08.vlr_tributo_icms
                                                            , '999999990D00' )
                                                        vlr_tributo_icms
                                                  , TO_CHAR ( dwt08.vlr_frete
                                                            , '999999990D00' )
                                                        vlr_frete
                                                  , TO_CHAR ( dwt08.vlr_seguro
                                                            , '999999990D00' )
                                                        vlr_seguro
                                                  , TO_CHAR ( dwt08.vlr_outras
                                                            , '999999990D00' )
                                                        vlr_outras
                                                  , TO_CHAR ( dwt07.vlr_tot_nota
                                                            , '999999990D00' )
                                                        vlr_tot_nota
                                                  , TO_CHAR ( dwt08.vlr_pis
                                                            , '999999990D00' )
                                                        vlr_pis
                                                  , TO_CHAR ( dwt08.vlr_cofins
                                                            , '999999990D00' )
                                                        vlr_cofins
                                                  , TO_CHAR ( dwt07.base_icmss_substituido
                                                            , '999999990D00' )
                                                        base_icmss_substituido
                                                  , TO_CHAR ( dwt07.vlr_icmss_substituido
                                                            , '999999990D00' )
                                                        vlr_icmss_substituido
                                                  , DECODE ( dwt07.ind_nf_especial,  'I', '0',  'F', 0,  '' )
                                                        ind_nf_especial
                                               FROM dwt_docto_fiscal dwt07
                                                  , dwt_itens_merc dwt08
                                                  , estado b
                                              WHERE dwt07.ident_uf_destino = b.ident_estado(+)
                                                AND dwt07.ident_docto_fiscal = dwt08.ident_docto_fiscal
                                                AND dwt07.cod_empresa = c1.cod_empresa
                                                AND dwt07.cod_estab = c1.cod_estab
                                                AND dwt07.data_fiscal = c1.data_fiscal
                                                AND dwt07.movto_e_s = c1.movto_e_s
                                                AND dwt07.norm_dev = c1.norm_dev
                                                AND dwt07.ident_docto = c1.ident_docto
                                                AND dwt07.ident_fis_jur = c1.ident_fis_jur
                                                AND dwt07.num_docfis = c1.num_docfis
                                                AND dwt07.serie_docfis = c1.serie_docfis
                                                AND dwt07.sub_serie_docfis = c1.sub_serie_docfis ) LOOP
                                        v_uf_dest := c1.ident_uf_destino;
                                        v_data_emissao := c1.data_fiscal;
                                        v_hora_saida := c_conv.hora_saida;
                                        v_vlr_base_icms_1 := c_conv.vlr_base_icms_1;
                                        v_vlr_tributo_icms := c_conv.vlr_tributo_icms;
                                        v_vlr_frete := c_conv.vlr_frete;
                                        v_vlr_seguro := c_conv.vlr_seguro;
                                        v_vlr_outras := c_conv.vlr_outras;
                                        v_vlr_tot_nota := c_conv.vlr_tot_nota;
                                        v_vlr_pis := c_conv.vlr_pis;
                                        v_vlr_cofins := c_conv.vlr_cofins;
                                        v_base_icmss_substituido := c_conv.base_icmss_substituido;
                                        v_vlr_icmss_substituido := c_conv.vlr_icmss_substituido;
                                        v_ind_nf_especial := c_conv.ind_nf_especial;
                                    END LOOP;


                                    v_uf_orig := c1.cod_estado;

                                    --qtde nfs no lote
                                    BEGIN
                                        SELECT COUNT ( 1 )
                                          INTO v_qtd_nf
                                          FROM tb_msaf_nf_lote a
                                         WHERE a.num_lote = c1.num_lote;
                                    EXCEPTION
                                        WHEN OTHERS THEN
                                            v_qtd_nf := 0;
                                    END;

                                    --
                                    --Dados transporte
                                    BEGIN
                                        SELECT a.placa_veiculo
                                             , b.cod_estado
                                             , c.insc_estadual
                                             , a.qtd_volumes
                                             , d.cod_volume
                                             , TO_CHAR ( a.peso_bruto
                                                       , '99999999999999.00' )
                                             , TO_CHAR ( a.peso_liquido
                                                       , '99999999999999.00' )
                                          INTO v_placa_veiculo
                                             , v_uf_cam
                                             , v_insc_trans
                                             , v_qtd_volumes
                                             , v_cod_volume
                                             , v_peso_bruto
                                             , v_peso_liquido
                                          FROM x50_transp_docfis a
                                             , estado b
                                             , x04_pessoa_fis_jur c
                                             , x2042_esp_volume d
                                         WHERE a.ident_uf_cam = b.ident_estado(+)
                                           AND a.ident_transp = c.ident_fis_jur(+)
                                           AND a.ident_volume = d.ident_volume(+)
                                           AND a.cod_empresa = c1.cod_empresa
                                           AND a.cod_estab = c1.cod_estab
                                           AND a.data_escr_fiscal = c1.data_fiscal
                                           AND a.movto_e_s = c1.movto_e_s
                                           AND a.norm_dev = c1.norm_dev
                                           AND a.ident_docto = c1.ident_docto
                                           AND a.ident_fis_jur = c1.ident_fis_jur
                                           AND a.num_docfis = c1.num_docfis
                                           AND a.serie_docfis = c1.serie_docfis
                                           AND a.sub_serie_docfis = c1.sub_serie_docfis;
                                    EXCEPTION
                                        WHEN OTHERS THEN
                                            v_placa_veiculo := '';
                                            v_uf_cam := '';
                                            v_insc_trans := '';
                                            v_qtd_volumes := '';
                                            v_cod_volume := '';
                                            v_peso_bruto := '';
                                            v_peso_liquido := '';
                                    END;

                                    v_tag_nf := '@'; --???
                                    v_nf := c1.num_docfis; --???
                                    v_chave_acesso := '@'; --???
                                    v_taxa_zero := '@'; --???

                                    v_cnpj_remetente := c1.cnpj_remetente;
                                    v_serie_docfis := c1.serie_docfis;
                                    v_insc_est := c1.insc_estadual;

                                    v_dt_emissao := '';
                                    v_op_debito := '';
                                    v_dados_adic := '';
                                    v_vlr_ipi := '';
                                    v_vlr_tot_item := '';
                                    v_vlr_abat_icms := '';
                                    v_frete_pcta := '0';
                                    v_marca_volume := '';
                                    v_numero_volume := '';
                                    v_vlr_gnre := '';
                                    v_dt_vcto_gnre := '';
                                    v_periodo_gnre := '';
                                    v_nf_refatura := '';
                                    v_dt_refatura := '';
                                    v_ins_suf_ref := '';
                                    v_ins_est_subs := '';

                                    --Inicia a montagem do registro xml
                                    IF v_inicio = '0' THEN
                                        --linha 1
                                        mlinha :=
                                            lib_str.w ( ''
                                                      , ''
                                                      , 1 );
                                        mlinha :=
                                            lib_str.w ( mlinha
                                                      , '<?xml version="1.0" encoding="UTF-8"?>'
                                                      , 1 );
                                        lib_proc.add ( mlinha
                                                     , NULL
                                                     , NULL
                                                     , v_seq_lote + 2 );
                                        --linha 2
                                        mlinha := '';
                                        mlinha := '<lote nro="';
                                        mlinha :=
                                               mlinha
                                            || v_num_lote
                                            || '" versao_sw="'
                                            || v_versao
                                            || '" dtEmissao="'
                                            || v_dt_gera
                                            || '">';
                                        lib_proc.add ( mlinha
                                                     , NULL
                                                     , NULL
                                                     , v_seq_lote + 2 );
                                        --linha 3
                                        mlinha := '';
                                        mlinha := v_tab || '<cnpjDestinatario>' || v_cnpj_dest || '</cnpjDestinatario>';
                                        lib_proc.add ( mlinha
                                                     , NULL
                                                     , NULL
                                                     , v_seq_lote + 2 );
                                        --linha 4
                                        mlinha := '';
                                        mlinha := v_tab || '<cnpjTransp>' || v_cnpj_tran || '</cnpjTransp>';
                                        lib_proc.add ( mlinha
                                                     , NULL
                                                     , NULL
                                                     , v_seq_lote + 2 );
                                        --linha 5
                                        mlinha := '';
                                        mlinha :=
                                            v_tab || '<inscSufDestinatario>' || v_insc_sufr || '</inscSufDestinatario>';
                                        lib_proc.add ( mlinha
                                                     , NULL
                                                     , NULL
                                                     , v_seq_lote + 2 );
                                        --linha 6
                                        mlinha := '';
                                        mlinha := v_tab || '<ufDestino>' || v_uf_dest || '</ufDestino>';
                                        lib_proc.add ( mlinha
                                                     , NULL
                                                     , NULL
                                                     , v_seq_lote + 2 );
                                        --linha 7
                                        mlinha := '';
                                        mlinha := v_tab || '<ufOrigem>' || v_uf_orig || '</ufOrigem>';
                                        lib_proc.add ( mlinha
                                                     , NULL
                                                     , NULL
                                                     , v_seq_lote + 2 );
                                        --linha 8
                                        mlinha := '';
                                        mlinha := v_tab || '<qtdeNF>' || v_qtd_nf || '</qtdeNF>';
                                        lib_proc.add ( mlinha
                                                     , NULL
                                                     , NULL
                                                     , v_seq_lote + 2 );
                                        --linha 9
                                        mlinha := '';
                                        mlinha := v_tab || '<notasFiscais>';
                                        lib_proc.add ( mlinha
                                                     , NULL
                                                     , NULL
                                                     , v_seq_lote + 2 );

                                        v_inicio := '1';
                                    END IF;

                                    --linha N+1
                                    mlinha := '';
                                    mlinha :=
                                           v_tab
                                        || v_tab
                                        || '<notaFiscal nro="'
                                        || v_nf
                                        || '" dtEmissao="'
                                        || v_data_emissao
                                        || '" txZero="false" incent="'
                                        || 0
                                        || '">';
                                    lib_proc.add ( mlinha
                                                 , NULL
                                                 , NULL
                                                 , v_seq_lote + 2 );
                                    --linha dados nf
                                    mlinha := '';
                                    mlinha :=
                                           v_tab
                                        || v_tab
                                        || v_tab
                                        || '<cnpjRemetente>'
                                        || v_cnpj_remetente
                                        || '</cnpjRemetente>';
                                    lib_proc.add ( mlinha
                                                 , NULL
                                                 , NULL
                                                 , v_seq_lote + 2 );
                                    --linha dados nf
                                    mlinha := '';
                                    mlinha := v_tab || v_tab || v_tab || '<CFOP>' || v_cfop || '</CFOP>';
                                    lib_proc.add ( mlinha
                                                 , NULL
                                                 , NULL
                                                 , v_seq_lote + 2 );
                                    --linha dados nf
                                    mlinha := '';
                                    mlinha := v_tab || v_tab || v_tab || '<modelo>' || v_cod_modelo || '</modelo>';
                                    lib_proc.add ( mlinha
                                                 , NULL
                                                 , NULL
                                                 , v_seq_lote + 2 );
                                    --linha dados nf
                                    mlinha := '';
                                    mlinha := v_tab || v_tab || v_tab || '<serie>' || v_serie_docfis || '</serie>';
                                    lib_proc.add ( mlinha
                                                 , NULL
                                                 , NULL
                                                 , v_seq_lote + 2 );
                                    --linha dados nf
                                    mlinha := '';
                                    mlinha :=
                                           v_tab
                                        || v_tab
                                        || v_tab
                                        || '<inscEstDestinatario>'
                                        || v_insc_est
                                        || '</inscEstDestinatario>';
                                    lib_proc.add ( mlinha
                                                 , NULL
                                                 , NULL
                                                 , v_seq_lote + 2 );
                                    --linha dados nf
                                    mlinha := '';
                                    mlinha :=
                                        v_tab || v_tab || v_tab || '<dtSaidaNF>' || v_data_emissao || '</dtSaidaNF>';
                                    lib_proc.add ( mlinha
                                                 , NULL
                                                 , NULL
                                                 , v_seq_lote + 2 );
                                    --linha dados nf
                                    mlinha := '';
                                    mlinha :=
                                        v_tab || v_tab || v_tab || '<hrSaidaNF>' || v_hora_saida || '</hrSaidaNF>';
                                    lib_proc.add ( mlinha
                                                 , NULL
                                                 , NULL
                                                 , v_seq_lote + 2 );
                                    --linha dados nf
                                    mlinha := '';
                                    mlinha := v_tab || v_tab || v_tab || '<optDebito>' || '2' || '</optDebito>';
                                    lib_proc.add ( mlinha
                                                 , NULL
                                                 , NULL
                                                 , v_seq_lote + 2 );
                                    --linha dados nf
                                    mlinha := '';
                                    mlinha :=
                                           v_tab
                                        || v_tab
                                        || v_tab
                                        || '<ddAdicionais>'
                                        || v_dados_adic
                                        || '</ddAdicionais>';
                                    lib_proc.add ( mlinha
                                                 , NULL
                                                 , NULL
                                                 , v_seq_lote + 2 );
                                    --linha dados nf
                                    mlinha := '';
                                    mlinha := v_tab || v_tab || v_tab || '<valores>';
                                    lib_proc.add ( mlinha
                                                 , NULL
                                                 , NULL
                                                 , v_seq_lote + 2 );
                                    --linha dados nf valores
                                    mlinha := '';
                                    mlinha :=
                                           v_tab
                                        || v_tab
                                        || v_tab
                                        || v_tab
                                        || '<baseCalcICMS>'
                                        || v_vlr_base_icms_1
                                        || '</baseCalcICMS>';
                                    lib_proc.add ( mlinha
                                                 , NULL
                                                 , NULL
                                                 , v_seq_lote + 2 );
                                    --linha dados nf valores
                                    mlinha := '';
                                    mlinha :=
                                           v_tab
                                        || v_tab
                                        || v_tab
                                        || v_tab
                                        || '<valICMS>'
                                        || v_vlr_tributo_icms
                                        || '</valICMS>';
                                    lib_proc.add ( mlinha
                                                 , NULL
                                                 , NULL
                                                 , v_seq_lote + 2 );
                                    --linha dados nf valores
                                    mlinha := '';
                                    mlinha :=
                                        v_tab || v_tab || v_tab || v_tab || '<valFT>' || v_vlr_frete || '</valFT>';
                                    lib_proc.add ( mlinha
                                                 , NULL
                                                 , NULL
                                                 , v_seq_lote + 2 );
                                    --linha dados nf valores
                                    mlinha := '';
                                    mlinha :=
                                           v_tab
                                        || v_tab
                                        || v_tab
                                        || v_tab
                                        || '<valSeguro>'
                                        || v_vlr_seguro
                                        || '</valSeguro>';
                                    lib_proc.add ( mlinha
                                                 , NULL
                                                 , NULL
                                                 , v_seq_lote + 2 );

                                    --Vlr IPI
                                    BEGIN
                                        SELECT TO_CHAR ( SUM ( t.aliq_tributo )
                                                       , '99999999999999.00' )
                                          INTO v_vlr_ipi
                                          FROM x08_trib_merc t
                                         WHERE t.cod_empresa = c1.cod_empresa
                                           AND t.cod_estab = c1.cod_estab
                                           AND t.data_fiscal = c1.data_fiscal
                                           AND t.movto_e_s = c1.movto_e_s
                                           AND t.norm_dev = c1.norm_dev
                                           AND t.ident_docto = c1.ident_docto
                                           AND t.ident_fis_jur = c1.ident_fis_jur
                                           AND t.num_docfis = c1.num_docfis
                                           AND t.serie_docfis = c1.serie_docfis
                                           AND t.sub_serie_docfis = c1.sub_serie_docfis
                                           AND t.cod_tributo = 'IPI';
                                    EXCEPTION
                                        WHEN OTHERS THEN
                                            v_vlr_ipi := '';
                                    END;

                                    --linha dados nf valores
                                    mlinha := '';
                                    mlinha :=
                                           v_tab
                                        || v_tab
                                        || v_tab
                                        || v_tab
                                        || '<valTotIPI>'
                                        || v_vlr_ipi
                                        || '</valTotIPI>';
                                    lib_proc.add ( mlinha
                                                 , NULL
                                                 , NULL
                                                 , v_seq_lote + 2 );
                                    --linha dados nf valores
                                    mlinha := '';
                                    mlinha :=
                                           v_tab
                                        || v_tab
                                        || v_tab
                                        || v_tab
                                        || '<valOutrasDesp>'
                                        || v_vlr_outras
                                        || '</valOutrasDesp>';
                                    lib_proc.add ( mlinha
                                                 , NULL
                                                 , NULL
                                                 , v_seq_lote + 2 );
                                    --linha dados nf valores
                                    mlinha := '';
                                    mlinha :=
                                           v_tab
                                        || v_tab
                                        || v_tab
                                        || v_tab
                                        || '<valTotItens>'
                                        || v_vlr_tot_nota
                                        || '</valTotItens>';
                                    lib_proc.add ( mlinha
                                                 , NULL
                                                 , NULL
                                                 , v_seq_lote + 2 );
                                    --linha dados nf valores
                                    mlinha := '';
                                    mlinha :=
                                           v_tab
                                        || v_tab
                                        || v_tab
                                        || v_tab
                                        || '<valTotNF>'
                                        || v_vlr_tot_nota
                                        || '</valTotNF>';
                                    lib_proc.add ( mlinha
                                                 , NULL
                                                 , NULL
                                                 , v_seq_lote + 2 );
                                    --linha dados nf valores
                                    mlinha := '';
                                    mlinha :=
                                        v_tab || v_tab || v_tab || v_tab || '<valPIS>' || v_vlr_pis || '</valPIS>';
                                    lib_proc.add ( mlinha
                                                 , NULL
                                                 , NULL
                                                 , v_seq_lote + 2 );
                                    --linha dados nf valores
                                    mlinha := '';
                                    mlinha :=
                                           v_tab
                                        || v_tab
                                        || v_tab
                                        || v_tab
                                        || '<valCOFINS>'
                                        || v_vlr_cofins
                                        || '</valCOFINS>';
                                    lib_proc.add ( mlinha
                                                 , NULL
                                                 , NULL
                                                 , v_seq_lote + 2 );
                                    --linha dados nf valores
                                    mlinha := '';
                                    mlinha :=
                                           v_tab
                                        || v_tab
                                        || v_tab
                                        || v_tab
                                        || '<valAbatICMS>'
                                        || v_vlr_abat_icms
                                        || '</valAbatICMS></valores>';
                                    lib_proc.add ( mlinha
                                                 , NULL
                                                 , NULL
                                                 , v_seq_lote + 2 );
                                    --Fim Valores
                                    --linha dados nf
                                    mlinha := '';
                                    mlinha := v_tab || v_tab || v_tab || '<transportador>';
                                    lib_proc.add ( mlinha
                                                 , NULL
                                                 , NULL
                                                 , v_seq_lote + 2 );
                                    --linha dados nf transportador
                                    mlinha := '';
                                    mlinha :=
                                           v_tab
                                        || v_tab
                                        || v_tab
                                        || v_tab
                                        || '<cnpjTransp>'
                                        || v_cnpj_tran
                                        || '</cnpjTransp>';
                                    lib_proc.add ( mlinha
                                                 , NULL
                                                 , NULL
                                                 , v_seq_lote + 2 );
                                    --linha dados nf transportador
                                    mlinha := '';
                                    mlinha :=
                                        v_tab || v_tab || v_tab || v_tab || '<ftConta>' || v_frete_pcta || '</ftConta>';
                                    lib_proc.add ( mlinha
                                                 , NULL
                                                 , NULL
                                                 , v_seq_lote + 2 );
                                    --linha dados nf transportador
                                    mlinha := '';
                                    mlinha :=
                                           v_tab
                                        || v_tab
                                        || v_tab
                                        || v_tab
                                        || '<placaVeic>'
                                        || v_placa_veiculo
                                        || '</placaVeic>';
                                    lib_proc.add ( mlinha
                                                 , NULL
                                                 , NULL
                                                 , v_seq_lote + 2 );
                                    --linha dados nf transportador
                                    mlinha := '';
                                    mlinha :=
                                           v_tab
                                        || v_tab
                                        || v_tab
                                        || v_tab
                                        || '<ufPlacaVeic>'
                                        || v_uf_cam
                                        || '</ufPlacaVeic>';
                                    lib_proc.add ( mlinha
                                                 , NULL
                                                 , NULL
                                                 , v_seq_lote + 2 );
                                    --linha dados nf transportador
                                    mlinha := '';
                                    mlinha :=
                                           v_tab
                                        || v_tab
                                        || v_tab
                                        || v_tab
                                        || '<inscEstTransp>'
                                        || v_insc_trans
                                        || '</inscEstTransp>';
                                    lib_proc.add ( mlinha
                                                 , NULL
                                                 , NULL
                                                 , v_seq_lote + 2 );
                                    --linha dados nf transportador
                                    mlinha := '';
                                    mlinha :=
                                           v_tab
                                        || v_tab
                                        || v_tab
                                        || v_tab
                                        || '<qtdeVol>'
                                        || v_qtd_volumes
                                        || '</qtdeVol>';
                                    lib_proc.add ( mlinha
                                                 , NULL
                                                 , NULL
                                                 , v_seq_lote + 2 );
                                    --linha dados nf transportador
                                    mlinha := '';
                                    mlinha :=
                                        v_tab || v_tab || v_tab || v_tab || '<especie>' || v_cod_volume || '</especie>';
                                    lib_proc.add ( mlinha
                                                 , NULL
                                                 , NULL
                                                 , v_seq_lote + 2 );
                                    --linha dados nf transportador
                                    mlinha := '';
                                    mlinha := v_tab || v_tab || v_tab || v_tab || '<marca>1</marca>';
                                    lib_proc.add ( mlinha
                                                 , NULL
                                                 , NULL
                                                 , v_seq_lote + 2 );
                                    --linha dados nf transportador
                                    mlinha := '';
                                    mlinha :=
                                           v_tab
                                        || v_tab
                                        || v_tab
                                        || v_tab
                                        || '<numero>'
                                        || v_numero_volume
                                        || '</numero>';
                                    lib_proc.add ( mlinha
                                                 , NULL
                                                 , NULL
                                                 , v_seq_lote + 2 );
                                    --linha dados nf transportador
                                    mlinha := '';
                                    mlinha :=
                                           v_tab
                                        || v_tab
                                        || v_tab
                                        || v_tab
                                        || '<pesoBruto>'
                                        || v_peso_bruto
                                        || '</pesoBruto>';
                                    lib_proc.add ( mlinha
                                                 , NULL
                                                 , NULL
                                                 , v_seq_lote + 2 );
                                    --linha dados nf transportador
                                    mlinha := '';
                                    mlinha :=
                                           v_tab
                                        || v_tab
                                        || v_tab
                                        || v_tab
                                        || '<pesoLiq>'
                                        || v_peso_liquido
                                        || '</pesoLiq></transportador>';
                                    lib_proc.add ( mlinha
                                                 , NULL
                                                 , NULL
                                                 , v_seq_lote + 2 );
                                    --Fim transportador
                                    --linha dados nf
                                    mlinha := '';
                                    mlinha := v_tab || v_tab || v_tab || '<gnre>';
                                    lib_proc.add ( mlinha
                                                 , NULL
                                                 , NULL
                                                 , v_seq_lote + 2 );
                                    --linha dados nf Gnre
                                    mlinha := '';
                                    mlinha :=
                                        v_tab || v_tab || v_tab || v_tab || '<valGNRE>' || v_vlr_gnre || '</valGNRE>';
                                    lib_proc.add ( mlinha
                                                 , NULL
                                                 , NULL
                                                 , v_seq_lote + 2 );
                                    --linha dados nf Gnre
                                    mlinha := '';
                                    mlinha :=
                                           v_tab
                                        || v_tab
                                        || v_tab
                                        || v_tab
                                        || '<dtVencGNRE>'
                                        || v_dt_vcto_gnre
                                        || '</dtVencGNRE>';
                                    lib_proc.add ( mlinha
                                                 , NULL
                                                 , NULL
                                                 , v_seq_lote + 2 );
                                    --linha dados nf Gnre
                                    mlinha := '';
                                    mlinha :=
                                           v_tab
                                        || v_tab
                                        || v_tab
                                        || v_tab
                                        || '<perRefGNRE>'
                                        || v_periodo_gnre
                                        || '</perRefGNRE></gnre>';
                                    lib_proc.add ( mlinha
                                                 , NULL
                                                 , NULL
                                                 , v_seq_lote + 2 );
                                    --Final Gnre
                                    --linha dados nf
                                    mlinha := '';
                                    mlinha := v_tab || v_tab || v_tab || '<refaturamento>';
                                    lib_proc.add ( mlinha
                                                 , NULL
                                                 , NULL
                                                 , v_seq_lote + 2 );
                                    --linha dados nf Gnre
                                    mlinha := '';
                                    mlinha :=
                                           v_tab
                                        || v_tab
                                        || v_tab
                                        || v_tab
                                        || '<NFRefat>'
                                        || v_nf_refatura
                                        || '</NFRefat>';
                                    lib_proc.add ( mlinha
                                                 , NULL
                                                 , NULL
                                                 , v_seq_lote + 2 );
                                    --linha dados nf Gnre
                                    mlinha := '';
                                    mlinha :=
                                           v_tab
                                        || v_tab
                                        || v_tab
                                        || v_tab
                                        || '<dtEmissaoRefat>'
                                        || v_dt_refatura
                                        || '</dtEmissaoRefat>';
                                    lib_proc.add ( mlinha
                                                 , NULL
                                                 , NULL
                                                 , v_seq_lote + 2 );
                                    --linha dados nf Gnre
                                    mlinha := '';
                                    mlinha :=
                                           v_tab
                                        || v_tab
                                        || v_tab
                                        || v_tab
                                        || '<inscSufRefat>'
                                        || v_ins_suf_ref
                                        || '</inscSufRefat></refaturamento>';
                                    lib_proc.add ( mlinha
                                                 , NULL
                                                 , NULL
                                                 , v_seq_lote + 2 );
                                    --Fim refaturamento
                                    --linha dados nf
                                    mlinha := '';
                                    mlinha := v_tab || v_tab || v_tab || '<substTributaria>';
                                    lib_proc.add ( mlinha
                                                 , NULL
                                                 , NULL
                                                 , v_seq_lote + 2 );
                                    --linha dados nf SubsTributaria
                                    mlinha := '';
                                    mlinha :=
                                           v_tab
                                        || v_tab
                                        || v_tab
                                        || v_tab
                                        || '<baseCalcICMSSubTrib>'
                                        || v_base_icmss_substituido
                                        || '</baseCalcICMSSubTrib>';
                                    lib_proc.add ( mlinha
                                                 , NULL
                                                 , NULL
                                                 , v_seq_lote + 2 );
                                    --linha dados nf SubsTributaria
                                    mlinha := '';
                                    mlinha :=
                                           v_tab
                                        || v_tab
                                        || v_tab
                                        || v_tab
                                        || '<valICMSSub>'
                                        || v_vlr_icmss_substituido
                                        || '</valICMSSub>';
                                    lib_proc.add ( mlinha
                                                 , NULL
                                                 , NULL
                                                 , v_seq_lote + 2 );
                                    --linha dados nf SubsTributaria
                                    mlinha := '';
                                    mlinha :=
                                           v_tab
                                        || v_tab
                                        || v_tab
                                        || v_tab
                                        || '<inscEstSubTrib>'
                                        || v_ins_est_subs
                                        || '</inscEstSubTrib></substTributaria>';
                                    lib_proc.add ( mlinha
                                                 , NULL
                                                 , NULL
                                                 , v_seq_lote + 2 );
                                    --Fim SubsTributaria
                                    --linha dados nf
                                    mlinha := '';
                                    mlinha := v_tab || v_tab || v_tab || '<itens>';
                                    lib_proc.add ( mlinha
                                                 , NULL
                                                 , NULL
                                                 , v_seq_lote + 2 );

                                    --Busca informacoes do item
                                    FOR c4 IN ( SELECT b.cod_produto
                                                     , b.descricao
                                                     , dwt08.descricao_compl
                                                     , c.cod_nbm
                                                     , DECODE ( TRIM ( e.cod_ncm ), NULL, c.cod_nbm ) cod_ncm
                                                     , d.cod_medida
                                                     , cfo.cod_cfo
                                                     , TO_CHAR ( dwt08.vlr_unit
                                                               , '999999990D00' )
                                                           vlr_unit
                                                     , TO_CHAR ( dwt08.quantidade
                                                               , '999999999999.00000000' )
                                                           quantidade
                                                     , TO_CHAR ( dwt08.vlr_item
                                                               , '999999990D00' )
                                                           vlr_item
                                                     , dwt08.ind_situacao_esp_st
                                                     , dwt08.discri_item
                                                  FROM dwt_itens_merc dwt08
                                                     , x2012_cod_fiscal cfo
                                                     , x2013_produto b
                                                     , x2043_cod_nbm c
                                                     , x2007_medida d
                                                     , x2045_cod_ncm e
                                                 WHERE dwt08.ident_produto = b.ident_produto
                                                   AND b.ident_nbm = c.ident_nbm(+)
                                                   AND dwt08.ident_cfo = cfo.ident_cfo
                                                   AND dwt08.ident_medida = d.ident_medida(+)
                                                   AND b.ident_ncm = e.ident_ncm(+)
                                                   AND dwt08.cod_empresa = c1.cod_empresa
                                                   AND dwt08.cod_estab = c1.cod_estab
                                                   AND dwt08.data_fiscal = c1.data_fiscal
                                                   AND dwt08.movto_e_s = c1.movto_e_s
                                                   AND dwt08.norm_dev = c1.norm_dev
                                                   AND dwt08.ident_docto = c1.ident_docto
                                                   AND dwt08.ident_fis_jur = c1.ident_fis_jur
                                                   AND dwt08.num_docfis = c1.num_docfis
                                                   AND dwt08.serie_docfis = c1.serie_docfis
                                                   AND dwt08.sub_serie_docfis = c1.sub_serie_docfis ) LOOP
                                        BEGIN
                                            --linha dados nf Itens
                                            mlinha := '';
                                            mlinha := v_tab || v_tab || v_tab || v_tab || '<item>';
                                            lib_proc.add ( mlinha
                                                         , NULL
                                                         , NULL
                                                         , v_seq_lote + 2 );
                                            v_cod_produto := c4.cod_produto;
                                            v_desc_item := c4.descricao;
                                            v_cod_nbm := c4.cod_nbm;
                                            v_cod_ncm := c4.cod_ncm;
                                            v_cfop := c4.cod_cfo;
                                            v_cod_medida := c4.cod_medida;
                                            v_vlr_unit := c4.vlr_unit;
                                            v_quantidade := c4.quantidade;
                                            v_vlr_item := c4.vlr_item;
                                            v_sit_trib := c4.ind_situacao_esp_st;



                                            BEGIN
                                                --Busca Aliq_icms
                                                SELECT TO_CHAR ( t.aliq_tributo
                                                               , '999.0000' )
                                                  INTO v_aliq_icms
                                                  FROM x08_trib_merc t
                                                 WHERE t.cod_empresa = c1.cod_empresa
                                                   AND t.cod_estab = c1.cod_estab
                                                   AND t.data_fiscal = c1.data_fiscal
                                                   AND t.movto_e_s = c1.movto_e_s
                                                   AND t.norm_dev = c1.norm_dev
                                                   AND t.ident_docto = c1.ident_docto
                                                   AND t.ident_fis_jur = c1.ident_fis_jur
                                                   AND t.num_docfis = c1.num_docfis
                                                   AND t.serie_docfis = c1.serie_docfis
                                                   AND t.sub_serie_docfis = c1.sub_serie_docfis
                                                   AND t.discri_item = c4.discri_item
                                                   AND t.cod_tributo = 'ICMS';
                                            EXCEPTION
                                                WHEN OTHERS THEN
                                                    v_aliq_icms := '';
                                            END;

                                            BEGIN
                                                --Busca Aliq IPI e Valor IPI
                                                SELECT TO_CHAR ( t.aliq_tributo
                                                               , '999.0000' )
                                                     , TO_CHAR ( t.vlr_tributo
                                                               , '999.0000' )
                                                  INTO v_aliq_ipi
                                                     , v_vlr_item_ipi
                                                  FROM x08_trib_merc t
                                                 WHERE t.cod_empresa = c1.cod_empresa
                                                   AND t.cod_estab = c1.cod_estab
                                                   AND t.data_fiscal = c1.data_fiscal
                                                   AND t.movto_e_s = c1.movto_e_s
                                                   AND t.norm_dev = c1.norm_dev
                                                   AND t.ident_docto = c1.ident_docto
                                                   AND t.ident_fis_jur = c1.ident_fis_jur
                                                   AND t.num_docfis = c1.num_docfis
                                                   AND t.serie_docfis = c1.serie_docfis
                                                   AND t.sub_serie_docfis = c1.sub_serie_docfis
                                                   AND t.discri_item = c4.discri_item
                                                   AND t.cod_tributo = 'IPI';
                                            EXCEPTION
                                                WHEN OTHERS THEN
                                                    v_aliq_ipi := '';
                                                    v_vlr_item_ipi := '';
                                            END;

                                            --linha dados nf Itens
                                            mlinha := '';
                                            mlinha :=
                                                   v_tab
                                                || v_tab
                                                || v_tab
                                                || v_tab
                                                || v_tab
                                                || '<codProd>'
                                                || v_cod_produto
                                                || '</codProd>';
                                            lib_proc.add ( mlinha
                                                         , NULL
                                                         , NULL
                                                         , v_seq_lote + 2 );
                                            --linha dados nf Itens
                                            mlinha := '';
                                            mlinha :=
                                                   v_tab
                                                || v_tab
                                                || v_tab
                                                || v_tab
                                                || v_tab
                                                || '<descItem>'
                                                || v_desc_item
                                                || '</descItem>';
                                            lib_proc.add ( mlinha
                                                         , NULL
                                                         , NULL
                                                         , v_seq_lote + 2 );
                                            --linha dados nf Itens
                                            mlinha := '';
                                            mlinha :=
                                                   v_tab
                                                || v_tab
                                                || v_tab
                                                || v_tab
                                                || v_tab
                                                || '<codNCM>'
                                                || v_cod_ncm
                                                || '</codNCM>';
                                            lib_proc.add ( mlinha
                                                         , NULL
                                                         , NULL
                                                         , v_seq_lote + 2 );
                                            --linha dados nf Itens
                                            mlinha := '';
                                            mlinha :=
                                                   v_tab
                                                || v_tab
                                                || v_tab
                                                || v_tab
                                                || v_tab
                                                || '<unidMed>'
                                                || v_cod_medida
                                                || '</unidMed>';
                                            lib_proc.add ( mlinha
                                                         , NULL
                                                         , NULL
                                                         , v_seq_lote + 2 );
                                            --linha dados nf Itens
                                            mlinha := '';
                                            mlinha :=
                                                   v_tab
                                                || v_tab
                                                || v_tab
                                                || v_tab
                                                || v_tab
                                                || '<valUnit>'
                                                || v_vlr_unit
                                                || '</valUnit>';
                                            lib_proc.add ( mlinha
                                                         , NULL
                                                         , NULL
                                                         , v_seq_lote + 2 );
                                            --linha dados nf Itens
                                            mlinha := '';
                                            mlinha :=
                                                   v_tab
                                                || v_tab
                                                || v_tab
                                                || v_tab
                                                || v_tab
                                                || '<qtde>'
                                                || v_quantidade
                                                || '</qtde>';
                                            lib_proc.add ( mlinha
                                                         , NULL
                                                         , NULL
                                                         , v_seq_lote + 2 );
                                            --linha dados nf Itens
                                            mlinha := '';
                                            mlinha :=
                                                   v_tab
                                                || v_tab
                                                || v_tab
                                                || v_tab
                                                || v_tab
                                                || '<valTot>'
                                                || v_vlr_item
                                                || '</valTot>';
                                            lib_proc.add ( mlinha
                                                         , NULL
                                                         , NULL
                                                         , v_seq_lote + 2 );
                                            --linha dados nf Itens
                                            mlinha := '';
                                            mlinha :=
                                                   v_tab
                                                || v_tab
                                                || v_tab
                                                || v_tab
                                                || v_tab
                                                || '<classFiscal>'
                                                || v_cod_nbm
                                                || '</classFiscal>';
                                            lib_proc.add ( mlinha
                                                         , NULL
                                                         , NULL
                                                         , v_seq_lote + 2 );
                                            --linha dados nf Itens
                                            mlinha := '';
                                            mlinha :=
                                                   v_tab
                                                || v_tab
                                                || v_tab
                                                || v_tab
                                                || v_tab
                                                || '<sitTribut>'
                                                || v_sit_trib
                                                || '</sitTribut>';
                                            lib_proc.add ( mlinha
                                                         , NULL
                                                         , NULL
                                                         , v_seq_lote + 2 );
                                            --linha dados nf Itens
                                            mlinha := '';
                                            mlinha :=
                                                   v_tab
                                                || v_tab
                                                || v_tab
                                                || v_tab
                                                || v_tab
                                                || '<alICMS>'
                                                || v_aliq_icms
                                                || '</alICMS>';
                                            lib_proc.add ( mlinha
                                                         , NULL
                                                         , NULL
                                                         , v_seq_lote + 2 );
                                            --linha dados nf Itens
                                            mlinha := '';
                                            mlinha :=
                                                   v_tab
                                                || v_tab
                                                || v_tab
                                                || v_tab
                                                || v_tab
                                                || '<alIPI>'
                                                || v_aliq_ipi
                                                || '</alIPI>';
                                            lib_proc.add ( mlinha
                                                         , NULL
                                                         , NULL
                                                         , v_seq_lote + 2 );
                                            --linha dados nf Itens
                                            mlinha := '';
                                            mlinha :=
                                                   v_tab
                                                || v_tab
                                                || v_tab
                                                || v_tab
                                                || v_tab
                                                || '<valIPI>'
                                                || v_vlr_item_ipi
                                                || '</valIPI>';
                                            lib_proc.add ( mlinha
                                                         , NULL
                                                         , NULL
                                                         , v_seq_lote + 2 );

                                            --linha dados nf Itens - Final
                                            mlinha := '';
                                            mlinha := v_tab || v_tab || v_tab || v_tab || '</item>';
                                            lib_proc.add ( mlinha
                                                         , NULL
                                                         , NULL
                                                         , v_seq_lote + 2 );
                                        END;
                                    END LOOP;


                                    --linha dados nf
                                    mlinha := '';
                                    mlinha := v_tab || v_tab || v_tab || '</itens>';
                                    lib_proc.add ( mlinha
                                                 , NULL
                                                 , NULL
                                                 , v_seq_lote + 2 );
                                    --NF final
                                    mlinha := '';
                                    mlinha := v_tab || v_tab || '</notaFiscal>';
                                    lib_proc.add ( mlinha
                                                 , NULL
                                                 , NULL
                                                 , v_seq_lote + 2 );

                                    --              end if;

                                    --Atualiza o status da NF
                                    BEGIN
                                        UPDATE tb_msaf_nf_lote
                                           SET status = 'C'
                                         WHERE ROWID = c1.linha;
                                    EXCEPTION
                                        WHEN OTHERS THEN
                                            NULL;
                                    END;
                                EXCEPTION
                                    WHEN OTHERS THEN
                                        NULL;
                                END;
                            END IF;
                        END loop;
                    END LOOP;

                    --grava o rodape de nf
                    --N -2
                    mlinha := '';
                    mlinha := v_tab || '</notasFiscais>';
                    lib_proc.add ( mlinha
                                 , NULL
                                 , NULL
                                 , v_seq_lote + 2 );
                    --N -1
                    mlinha := '';
                    mlinha := '</lote>';
                    lib_proc.add ( mlinha
                                 , NULL
                                 , NULL
                                 , v_seq_lote + 2 );
                    --N -0
                    mlinha := '';
                    lib_proc.add ( mlinha
                                 , NULL
                                 , NULL
                                 , v_seq_lote + 2 );

                    --Atualiza o lote
                    BEGIN
                        UPDATE tb_msaf_lote l
                           SET l.data_envio = SYSDATE
                         WHERE l.num_lote = v_lote;
                    EXCEPTION
                        WHEN OTHERS THEN
                            NULL;
                    END;

                    v_seq_lote := v_seq_lote + 1;

                    i := plote.NEXT ( i );
                END LOOP;

                COMMIT;

                lib_proc.add_log (
                                   '----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------'
                                 , 0
                );
                lib_proc.add_log ( ' Finalizado com sucesso '
                                 , 5 );
                lib_proc.add_log (
                                   '----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------'
                                 , 0
                );
                lib_proc.add_log (    'FINAL DO PROCESSO:  '
                                   || TO_CHAR ( SYSDATE
                                              , 'DD/MM/YYYY HH24:MI:SS' )
                                 , 1 );
            EXCEPTION
                WHEN OTHERS THEN
                    lib_proc.add_log (
                                       '----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------'
                                     , 0
                    );
                    lib_proc.add_log ( ' Finalizado com erro cursor ' || SQLERRM
                                     , 1 );
                    lib_proc.add_log (
                                       '----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------'
                                     , 0
                    );
            END;
        END;

        lib_proc.close ( );

        RETURN mproc_id;
    END;
---

END msaf_pin_sinal2_cproc;
/
SHOW ERRORS;
