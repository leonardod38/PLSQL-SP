Prompt Package Body MSAF_CUSTOM_AMBEV_DIF_CPROC;
--
-- MSAF_CUSTOM_AMBEV_DIF_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY msaf_custom_ambev_dif_cproc
IS
    -- Autor   : Pedro A. Puerta
    -- Created : 03/12/2007
    -- Purpose : Diferencial de Aliquota

    mproc_id INTEGER;

    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );
    BEGIN
        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        mcod_estab := NVL ( lib_parametros.recuperar ( 'ESTABELECIMENTO' ), '' );
        musuario := lib_parametros.recuperar ( 'Usuario' );

        SELECT razao_social
          INTO w_razao
          FROM empresa
         WHERE cod_empresa = mcod_empresa;

        lib_proc.add_param ( pstr
                           , LPAD ( ' '
                                  , 64
                                  , ' ' )
                           , 'varchar2'
                           , 'text'
                           , 'N'
                           , NULL
                           , NULL );
        lib_proc.add_param (
                             pstr
                           ,    LPAD ( ' '
                                     , 64
                                     , ' ' )
                             || '**********   Tela de Parametro para a Emissao do Relatorio de Diferencial de Aliquota  **********'
                           , 'varchar2'
                           , 'text'
                           , 'N'
                           , NULL
                           , NULL
        );
        lib_proc.add_param ( pstr
                           , LPAD ( ' '
                                  , 64
                                  , ' ' )
                           , 'varchar2'
                           , 'text'
                           , 'N'
                           , NULL
                           , NULL );
        lib_proc.add_param ( pstr
                           ,    LPAD ( ' '
                                     , 64
                                     , ' ' )
                             || mcod_empresa
                             || ' - '
                             || w_razao
                           , 'varchar2'
                           , 'text'
                           , 'N'
                           , NULL
                           , NULL );

        lib_proc.add_param (
                             pstr
                           , 'Estabelecimento'
                           , 'varchar2'
                           , 'combobox'
                           , 'S'
                           , NULL
                           , NULL
                           ,    'select cod_estab, cod_estab||'' - ''||razao_social||'' - ''||nome_fantasia from estabelecimento where cod_empresa = '''
                             || mcod_empresa
                             || ''' ORDER BY 1 '
        );
        lib_proc.add_param ( pstr
                           , 'Periodo Inicial'
                           , 'date'
                           , 'Textbox'
                           , 'S'
                           , NULL
                           , 'dd/mm/yyyy' );
        lib_proc.add_param ( pstr
                           , 'Periodo Finial'
                           , 'date'
                           , 'Textbox'
                           , 'S'
                           , NULL
                           , 'dd/mm/yyyy' );
        lib_proc.add_param (
                             pstr
                           , 'Perfil '
                           , 'Varchar2'
                           , 'Combobox'
                           , 'S'
                           , NULL
                           , '##################'
                           , 'select id_parametros, upper(Descricao) from fpar_parametros a where nome_framework = ''MSAF_CUSTOM_AMBEV_DIF_CPAR'' order by 1'
        );

        RETURN pstr;
    END;

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Relatorio - Diferencial de Aliquota por CFOP';
    END;

    FUNCTION tipo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Relatorio';
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
        RETURN 'Relatorio de Diferencial de Aliquota';
    END;

    FUNCTION modulo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Ambev';
    END;

    FUNCTION classificacao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'ESPECIFICOS - Ambev';
    END;

    FUNCTION executar ( pestab VARCHAR2
                      , pperini DATE
                      , pperfim DATE
                      , pperfil VARCHAR2 )
        RETURN INTEGER
    IS
        /* Variaveis de Trabalho */

        minsereheader BOOLEAN;
        mcount NUMBER;
        v_vlr_total NUMBER := 0;
        x VARCHAR2 ( 1 );
    BEGIN
        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        mcod_estab := pestab;
        conta := 0;
        pfolha := 0;
        -- Cria Processo
        mproc_id :=
            lib_proc.new ( 'MSAF_CUSTOM_AMBEV_DIF_CPROC'
                         , 49
                         , 150 );
        lib_proc.add_tipo ( mproc_id
                          , 1
                          , 'Diferencial de Aliquota'
                          , 1
                          , NULL
                          , NULL
                          , 8 );
        -- Inicializa variaveis auxiliares
        minsereheader := TRUE;
        mcount := 0;


        -- Inicio do cursor do Relatorio
        DECLARE
            CURSOR c_rel
            IS
                ( SELECT  dwt_docto_fiscal.cod_empresa
                        , dwt_docto_fiscal.cod_estab
                        , estabelecimento.razao_social
                        , estabelecimento.cgc
                        , registro_estadual.inscricao_estadual
                        , dwt_docto_fiscal.num_docfis
                        , x2005_tipo_docto.cod_docto
                        , dwt_docto_fiscal.serie_docfis
                        , dwt_docto_fiscal.sub_serie_docfis
                        , dwt_docto_fiscal.data_fiscal
                        , x04_pessoa_fis_jur.cpf_cgc
                        , x2012_cod_fiscal.cod_cfo
                        , x2006_natureza_op.cod_natureza_op
                        , estado.cod_estado
                        , dwt_itens_merc.aliq_tributo_icms
                        , dwt_itens_merc.vlr_aliq_destino
                        , dwt_itens_merc.dif_aliq_trib_icms
                        , DECODE ( dwt_docto_fiscal.ind_situacao_esp, '1', 0, SUM ( dwt_itens_merc.vlr_contab_item ) )
                              vlr_contab
                        , DECODE ( dwt_docto_fiscal.ind_situacao_esp, '1', 0, SUM ( dwt_itens_merc.vlr_base_icms_1 ) )
                              vlr_icms_t
                        , DECODE ( dwt_docto_fiscal.ind_situacao_esp, '1', 0, SUM ( dwt_itens_merc.vlr_base_icms_2 ) )
                              vlr_icms_2
                        , DECODE ( dwt_docto_fiscal.ind_situacao_esp, '1', 0, SUM ( dwt_itens_merc.vlr_base_icms_3 ) )
                              vlr_icms_3
                        , DECODE ( dwt_docto_fiscal.ind_situacao_esp, '1', 0, SUM ( dwt_itens_merc.vlr_base_icms_4 ) )
                              vlr_icms_4
                        , DECODE ( dwt_docto_fiscal.ind_situacao_esp, '1', 0, SUM ( dwt_itens_merc.vlr_tributo_icmss ) )
                              vlr_icms_r
                        , DECODE ( dwt_docto_fiscal.ind_situacao_esp, '1', 0, SUM ( dwt_itens_merc.vlr_tributo_icms ) )
                              vlr_trib_icms
                        , prt_par3_msaf.ind_base_dif_aliq
                        , DECODE ( dwt_docto_fiscal.ind_situacao_esp, '1', 0, SUM ( dwt_itens_merc.vlr_icms_ndestac ) )
                              vlr_icms_ndestac
                        , DECODE ( dwt_docto_fiscal.ind_situacao_esp, '1', 0, SUM ( dwt_itens_merc.vlr_outros1 ) )
                              vlr_outros1
                        , 0.00 vlr_dif_aliq
                        , dwt_docto_fiscal.dat_intern_am
                     FROM dwt_docto_fiscal
                        , dwt_itens_merc
                        , estabelecimento
                        , x2012_cod_fiscal
                        , registro_estadual
                        , x2005_tipo_docto
                        , x04_pessoa_fis_jur
                        , x2006_natureza_op
                        , estado
                        , prt_par3_msaf
                    WHERE ( dwt_itens_merc.ident_natureza_op = x2006_natureza_op.ident_natureza_op(+) )
                      AND ( dwt_docto_fiscal.ident_docto_fiscal = dwt_itens_merc.ident_docto_fiscal )
                      AND ( dwt_itens_merc.cod_empresa = estabelecimento.cod_empresa )
                      AND ( dwt_itens_merc.ident_cfo = x2012_cod_fiscal.ident_cfo )
                      AND ( dwt_itens_merc.cod_estab = estabelecimento.cod_estab )
                      AND ( estabelecimento.cod_empresa = registro_estadual.cod_empresa )
                      AND ( estabelecimento.cod_estab = registro_estadual.cod_estab )
                      AND ( dwt_docto_fiscal.ident_docto = x2005_tipo_docto.ident_docto )
                      AND ( dwt_docto_fiscal.ident_fis_jur = x04_pessoa_fis_jur.ident_fis_jur )
                      AND ( estabelecimento.ident_estado = registro_estadual.ident_estado )
                      AND ( x04_pessoa_fis_jur.ident_estado = estado.ident_estado )
                      AND ( estabelecimento.cod_empresa = prt_par3_msaf.cod_empresa )
                      AND ( estabelecimento.cod_estab = prt_par3_msaf.cod_estab )
                      AND ( dwt_docto_fiscal.cod_empresa = mcod_empresa )
                      AND ( dwt_docto_fiscal.cod_estab LIKE pestab )
                      AND ( dwt_docto_fiscal.data_fiscal >= pperini )
                      AND ( dwt_docto_fiscal.data_fiscal <= pperfim )
                      AND ( dwt_docto_fiscal.cod_class_doc_fis IN ( '1'
                                                                  , '3' ) )
                      AND ( dwt_docto_fiscal.situacao <> 'S' )
                      AND ( dwt_docto_fiscal.movto_e_s IN ( '1'
                                                          , '2'
                                                          , '3'
                                                          , '4'
                                                          , '5' ) )
                      AND ( ( --dwt_itens_merc.dif_aliq_trib_icms <> 0 AND
                              prt_par3_msaf.ind_base_dif_aliq IN ( '1'
                                                                 , '2'
                                                                 , '3' ) )
                        OR ( dwt_itens_merc.vlr_outros1 <> 0
                        AND prt_par3_msaf.ind_base_dif_aliq = '4' ) )
                      AND EXISTS
                              (SELECT 1
                                 FROM fpar_param_det
                                WHERE id_parametro = pperfil
                                  AND nome_param = 'INTERF'
                                  AND conteudo = x2012_cod_fiscal.ident_cfo)
                 GROUP BY dwt_docto_fiscal.cod_empresa
                        , dwt_docto_fiscal.cod_estab
                        , estabelecimento.razao_social
                        , estabelecimento.cgc
                        , registro_estadual.inscricao_estadual
                        , dwt_docto_fiscal.num_docfis
                        , x2005_tipo_docto.cod_docto
                        , dwt_docto_fiscal.serie_docfis
                        , dwt_docto_fiscal.sub_serie_docfis
                        , dwt_docto_fiscal.data_fiscal
                        , x04_pessoa_fis_jur.cpf_cgc
                        , x2012_cod_fiscal.cod_cfo
                        , x2006_natureza_op.cod_natureza_op
                        , estado.cod_estado
                        , dwt_itens_merc.aliq_tributo_icms
                        , dwt_itens_merc.vlr_aliq_destino
                        , dwt_itens_merc.dif_aliq_trib_icms
                        , prt_par3_msaf.ind_base_dif_aliq
                        , dwt_docto_fiscal.dat_intern_am
                        , dwt_docto_fiscal.ind_situacao_esp
                 UNION
                 SELECT   dwt_docto_fiscal.cod_empresa
                        , dwt_docto_fiscal.cod_estab
                        , estabelecimento.razao_social
                        , estabelecimento.cgc
                        , registro_estadual.inscricao_estadual
                        , dwt_docto_fiscal.num_docfis
                        , x2005_tipo_docto.cod_docto
                        , dwt_docto_fiscal.serie_docfis
                        , dwt_docto_fiscal.sub_serie_docfis
                        , dwt_docto_fiscal.data_fiscal
                        , x04_pessoa_fis_jur.cpf_cgc
                        , x2012_cod_fiscal.cod_cfo
                        , x2006_natureza_op.cod_natureza_op
                        , estado.cod_estado
                        , dwt_docto_fiscal.aliq_tributo_icms
                        , dwt_docto_fiscal.vlr_aliq_destino
                        , dwt_docto_fiscal.dif_aliq_trib_icms
                        , DECODE ( dwt_docto_fiscal.ind_situacao_esp, '1', 0, SUM ( dwt_docto_fiscal.vlr_tot_nota ) )
                              vlr_contab
                        , DECODE ( dwt_docto_fiscal.ind_situacao_esp, '1', 0, SUM ( dwt_docto_fiscal.vlr_base_icms_1 ) )
                              vlr_icms_t
                        , DECODE ( dwt_docto_fiscal.ind_situacao_esp, '1', 0, SUM ( dwt_docto_fiscal.vlr_base_icms_2 ) )
                              vlr_icms_2
                        , DECODE ( dwt_docto_fiscal.ind_situacao_esp, '1', 0, SUM ( dwt_docto_fiscal.vlr_base_icms_3 ) )
                              vlr_icms_3
                        , DECODE ( dwt_docto_fiscal.ind_situacao_esp, '1', 0, SUM ( dwt_docto_fiscal.vlr_base_icms_4 ) )
                              vlr_icms_4
                        , DECODE ( dwt_docto_fiscal.ind_situacao_esp
                                 , '1', 0
                                 , SUM ( dwt_docto_fiscal.vlr_tributo_icmss ) )
                              vlr_icms_r
                        , DECODE ( dwt_docto_fiscal.ind_situacao_esp, '1', 0, SUM ( dwt_docto_fiscal.vlr_tributo_icms ) )
                              vlr_trib_icms
                        , prt_par3_msaf.ind_base_dif_aliq
                        , DECODE ( dwt_docto_fiscal.ind_situacao_esp, '1', 0, SUM ( dwt_docto_fiscal.vlr_icms_ndestac ) )
                              vlr_icms_ndestac
                        , DECODE ( dwt_docto_fiscal.ind_situacao_esp, '1', 0, SUM ( dwt_docto_fiscal.vlr_outros1 ) )
                              vlr_outros1
                        , 0.00 vlr_dif_aliq
                        , dwt_docto_fiscal.dat_intern_am
                     FROM dwt_docto_fiscal
                        , estabelecimento
                        , x2012_cod_fiscal
                        , registro_estadual
                        , x2005_tipo_docto
                        , x04_pessoa_fis_jur
                        , x2006_natureza_op
                        , estado
                        , prt_par3_msaf
                    WHERE ( dwt_docto_fiscal.ident_natureza_op = x2006_natureza_op.ident_natureza_op(+) )
                      AND ( estabelecimento.cod_empresa = registro_estadual.cod_empresa )
                      AND ( estabelecimento.cod_estab = registro_estadual.cod_estab )
                      AND ( dwt_docto_fiscal.ident_docto = x2005_tipo_docto.ident_docto )
                      AND ( dwt_docto_fiscal.ident_fis_jur = x04_pessoa_fis_jur.ident_fis_jur )
                      AND ( estabelecimento.ident_estado = registro_estadual.ident_estado )
                      AND ( x04_pessoa_fis_jur.ident_estado = estado.ident_estado )
                      AND ( dwt_docto_fiscal.cod_empresa = estabelecimento.cod_empresa )
                      AND ( dwt_docto_fiscal.cod_estab = estabelecimento.cod_estab )
                      AND ( dwt_docto_fiscal.ident_cfo = x2012_cod_fiscal.ident_cfo )
                      AND ( estabelecimento.cod_empresa = prt_par3_msaf.cod_empresa )
                      AND ( estabelecimento.cod_estab = prt_par3_msaf.cod_estab )
                      AND ( dwt_docto_fiscal.cod_empresa = mcod_empresa )
                      AND ( dwt_docto_fiscal.cod_estab = pestab )
                      AND ( dwt_docto_fiscal.data_fiscal >= pperini )
                      AND ( dwt_docto_fiscal.data_fiscal <= pperfim )
                      AND ( dwt_docto_fiscal.cod_class_doc_fis IN ( '1'
                                                                  , '3' ) )
                      AND ( dwt_docto_fiscal.situacao <> 'S' )
                      AND ( dwt_docto_fiscal.movto_e_s IN ( '1'
                                                          , '2'
                                                          , '3'
                                                          , '4'
                                                          , '5' ) )
                      AND ( ( --dwt_docto_fiscal.dif_aliq_trib_icms <> 0 AND
                              prt_par3_msaf.ind_base_dif_aliq IN ( '1'
                                                                 , '2'
                                                                 , '3' ) )
                        OR ( dwt_docto_fiscal.vlr_outros1 <> 0
                        AND prt_par3_msaf.ind_base_dif_aliq = '4' ) )
                      AND NOT EXISTS
                              (SELECT 1
                                 FROM dwt_itens_merc
                                WHERE dwt_itens_merc.ident_docto_fiscal = dwt_docto_fiscal.ident_docto_fiscal)
                      AND EXISTS
                              (SELECT 1
                                 FROM fpar_param_det
                                WHERE id_parametro = pperfil
                                  AND nome_param = 'INTERF'
                                  AND conteudo = x2012_cod_fiscal.ident_cfo)
                 GROUP BY dwt_docto_fiscal.cod_empresa
                        , dwt_docto_fiscal.cod_estab
                        , estabelecimento.razao_social
                        , estabelecimento.cgc
                        , registro_estadual.inscricao_estadual
                        , dwt_docto_fiscal.num_docfis
                        , x2005_tipo_docto.cod_docto
                        , dwt_docto_fiscal.serie_docfis
                        , dwt_docto_fiscal.sub_serie_docfis
                        , dwt_docto_fiscal.data_fiscal
                        , x04_pessoa_fis_jur.cpf_cgc
                        , x2012_cod_fiscal.cod_cfo
                        , x2006_natureza_op.cod_natureza_op
                        , estado.cod_estado
                        , dwt_docto_fiscal.aliq_tributo_icms
                        , dwt_docto_fiscal.vlr_aliq_destino
                        , dwt_docto_fiscal.dif_aliq_trib_icms
                        , prt_par3_msaf.ind_base_dif_aliq
                        , dwt_docto_fiscal.dat_intern_am
                        , dwt_docto_fiscal.ind_situacao_esp );
        BEGIN
            BEGIN
                SELECT e.razao_social empresa
                     , x.razao_social
                     , x.endereco || ', ' || x.num_endereco
                     , x.bairro
                     , x.cidade
                     ,    SUBSTR ( z.inscricao_estadual
                                 , 1
                                 , 3 )
                       || '.'
                       || SUBSTR ( z.inscricao_estadual
                                 , 4
                                 , 3 )
                       || '.'
                       || SUBSTR ( z.inscricao_estadual
                                 , 7
                                 , 3 )
                       || '.'
                       || SUBSTR ( z.inscricao_estadual
                                 , 10
                                 , 3 )
                     ,    SUBSTR ( x.cgc
                                 , 1
                                 , 2 )
                       || '.'
                       || SUBSTR ( x.cgc
                                 , 3
                                 , 3 )
                       || '.'
                       || SUBSTR ( x.cgc
                                 , 6
                                 , 3 )
                       || '/'
                       || SUBSTR ( x.cgc
                                 , 9
                                 , 4 )
                       || '-'
                       || SUBSTR ( x.cgc
                                 , 13
                                 , 2 )
                     , x.insc_municipal
                  INTO temp
                     , tnome
                     , tend
                     , tbai
                     , tmun
                     , tinscest
                     , tcpnj
                     , tccm
                  FROM estabelecimento x
                     , registro_estadual z
                     , empresa e
                 WHERE z.cod_empresa = x.cod_empresa
                   AND z.cod_estab = x.cod_estab
                   AND z.ident_estado = x.ident_estado
                   AND x.cod_estab = pestab
                   AND x.cod_empresa = e.cod_empresa
                   AND e.cod_empresa = mcod_empresa;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    lib_proc.add_log (
                                          'Registro de Estabelecimento nao identificado para '
                                       || mcod_empresa
                                       || ' - '
                                       || pestab
                                     , 1
                    );
                WHEN OTHERS THEN
                    lib_proc.add_log ( 'Erro nao tratado pelo sistema ' || mcod_empresa || ' - ' || pestab
                                     , 1 );
            END;

            cabecalho ( pperini
                      , pperfim );

            FOR mreg IN c_rel LOOP
                BEGIN
                    SELECT DISTINCT ae.aliquota
                      INTO wori
                      FROM aliquota_estado ae
                         , estado eo
                         , estado ed
                         , estabelecimento est
                     WHERE est.ident_estado = eo.ident_estado
                       AND ae.ident_uf_origem = eo.ident_estado
                       AND ae.ident_uf_destino = ed.ident_estado
                       AND eo.ident_estado = ed.ident_estado
                       AND est.cod_empresa = mreg.cod_empresa
                       AND est.cod_estab = mreg.cod_estab--and    ed.cod_estado = mReg.cod_estado
                                                         ;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        wori := '000.00';
                        lib_proc.add_log ( 'Aliquota de Origem nao encontrada na parametrizacao por UF '
                                         , 1 );
                    WHEN OTHERS THEN
                        wori := '000.00';
                        lib_proc.add_log ( 'Aliquota de Origem : Erro nao previsto '
                                         , 1 );
                END;

                BEGIN
                    SELECT DISTINCT ae.aliquota
                      INTO wdest
                      FROM aliquota_estado ae
                         , estado eo
                         , estado ed
                         , estabelecimento est
                     WHERE est.ident_estado = eo.ident_estado
                       AND ae.ident_uf_origem = eo.ident_estado
                       AND ae.ident_uf_destino = ed.ident_estado
                       --and    eo.ident_estado <> ed.ident_estado
                       AND est.cod_estab = mreg.cod_estab
                       AND est.cod_empresa = mreg.cod_empresa
                       AND ed.cod_estado = mreg.cod_estado;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        wdest := '000.00';
                        lib_proc.add_log (
                                              'Aliquota de Destino nao encontrada na parametrizacao por UF - '
                                           || mreg.cod_estado
                                         , 1
                        );
                    WHEN OTHERS THEN
                        wdest := '000.00';
                        lib_proc.add_log ( 'Aliquota de Destino : Erro nao previsto '
                                         , 1 );
                END;

                mlinha :=
                    lib_str.w ( ''
                              , vsep
                              , 1 );
                mlinha :=
                    lib_str.w ( mlinha
                              , RPAD ( mreg.num_docfis
                                     , 6
                                     , '0' )
                              , 4 );
                mlinha :=
                    lib_str.w ( mlinha
                              , vsep
                              , LENGTH ( mlinha ) + 3 );
                mlinha :=
                    lib_str.w ( mlinha
                              , RPAD ( mreg.cod_docto
                                     , 4
                                     , ' ' )
                              , LENGTH ( mlinha ) + 3 );
                mlinha :=
                    lib_str.w ( mlinha
                              , vsep
                              , LENGTH ( mlinha ) + 1 );
                mlinha :=
                    lib_str.w ( mlinha
                              ,    LPAD ( mreg.serie_docfis
                                        , 3
                                        , ' ' )
                                || '/'
                                || RPAD ( mreg.sub_serie_docfis
                                        , 2
                                        , ' ' )
                              , LENGTH ( mlinha ) + 2 );
                mlinha :=
                    lib_str.w ( mlinha
                              , vsep
                              , LENGTH ( mlinha ) + 1 );
                mlinha :=
                    lib_str.w ( mlinha
                              , TO_CHAR ( mreg.data_fiscal
                                        , 'dd/mm/yy' )
                              , LENGTH ( mlinha ) + 1 );
                mlinha :=
                    lib_str.w ( mlinha
                              , vsep
                              , LENGTH ( mlinha ) + 1 );
                mlinha :=
                    lib_str.w ( mlinha
                              , LPAD ( mreg.cpf_cgc
                                     , 14
                                     , ' ' )
                              , LENGTH ( mlinha ) + 1 );
                mlinha :=
                    lib_str.w ( mlinha
                              , vsep
                              , LENGTH ( mlinha ) + 1 );
                mlinha :=
                    lib_str.w ( mlinha
                              , mreg.cod_cfo
                              , LENGTH ( mlinha ) + 2 );
                mlinha :=
                    lib_str.w ( mlinha
                              , vsep
                              , LENGTH ( mlinha ) + 2 );
                mlinha :=
                    lib_str.w ( mlinha
                              , mreg.cod_natureza_op
                              , LENGTH ( mlinha ) + 2 );
                mlinha :=
                    lib_str.w ( mlinha
                              , vsep
                              , LENGTH ( mlinha ) + 1 );
                mlinha :=
                    lib_str.w ( mlinha
                              , mreg.cod_estado
                              , LENGTH ( mlinha ) + 1 );
                mlinha :=
                    lib_str.w ( mlinha
                              , vsep
                              , LENGTH ( mlinha ) + 1 );
                mlinha :=
                    lib_str.w ( mlinha
                              , TO_CHAR ( wori * 100
                                        , '90G00' )
                              , LENGTH ( mlinha ) );
                mlinha :=
                    lib_str.w ( mlinha
                              , vsep
                              , LENGTH ( mlinha ) + 1 );
                mlinha :=
                    lib_str.w ( mlinha
                              , TO_CHAR ( wdest * 100
                                        , '90G00' )
                              , LENGTH ( mlinha ) );
                mlinha :=
                    lib_str.w ( mlinha
                              , vsep
                              , LENGTH ( mlinha ) + 1 );
                mlinha :=
                    lib_str.w ( mlinha
                              , TO_CHAR ( mreg.vlr_contab
                                        , '999G990D00' )
                              , LENGTH ( mlinha ) + 1 );
                mlinha :=
                    lib_str.w ( mlinha
                              , vsep
                              , LENGTH ( mlinha ) + 1 );
                mlinha :=
                    lib_str.w ( mlinha
                              , TO_CHAR ( mreg.vlr_icms_t
                                        , '999G990D00' )
                              , LENGTH ( mlinha ) + 1 );
                mlinha :=
                    lib_str.w ( mlinha
                              , vsep
                              , LENGTH ( mlinha ) + 1 );
                mlinha :=
                    lib_str.w ( mlinha
                              , TO_CHAR ( mreg.vlr_icms_3
                                        , '999G990D00' )
                              , LENGTH ( mlinha ) + 1 );
                mlinha :=
                    lib_str.w ( mlinha
                              , vsep
                              , LENGTH ( mlinha ) + 1 );
                mlinha :=
                    lib_str.w ( mlinha
                              , TO_CHAR ( ( mreg.vlr_icms_3 * wori ) / 100
                                        , '999G990D00' )
                              , LENGTH ( mlinha ) + 1 );
                mlinha :=
                    lib_str.w ( mlinha
                              , vsep
                              , LENGTH ( mlinha ) + 1 );
                mlinha :=
                    lib_str.w ( mlinha
                              , TO_CHAR ( ( mreg.vlr_icms_3 * wdest ) / 100
                                        , '999G990D00' )
                              , LENGTH ( mlinha ) + 1 );
                mlinha :=
                    lib_str.w ( mlinha
                              , vsep
                              , LENGTH ( mlinha ) + 1 );
                mlinha :=
                    lib_str.w ( mlinha
                              , TO_CHAR ( ( ( mreg.vlr_icms_3 * wori ) - ( mreg.vlr_icms_3 * wdest ) ) / 100
                                        , '999G990D00' )
                              , LENGTH ( mlinha ) + 1 );
                mlinha :=
                    lib_str.w ( mlinha
                              , vsep
                              , LENGTH ( mlinha ) + 1 );
                lib_proc.add ( mlinha );
                --dbms_output.put_line(mLinha);

                cabecalho ( pperini
                          , pperfim );
                conta := conta + 1;
            END LOOP;

            mlinha :=
                lib_str.w ( ''
                          , RPAD ( vlinha
                                 , 150
                                 , vlinha )
                          , 1 );
            lib_proc.add ( mlinha );

            mcount := mcount + 1;

            WHILE mcount < 36 LOOP
                BEGIN
                    mlinha :=
                        lib_str.w ( ''
                                  , ''
                                  , 1 );
                    lib_proc.add ( mlinha );
                    --Cabecalho ( pdata_apuracaoi,pdata_apuracaof);

                    mcount := mcount + 1;
                END;
            END LOOP;

            minsereheader := TRUE;

            WHILE mcount < 35 LOOP
                BEGIN
                    mlinha :=
                        lib_str.w ( ''
                                  , ''
                                  , 1 );
                    lib_proc.add ( mlinha );
                    mcount := mcount + 1;
                END;
            END LOOP;
        --mInsereHeader   := TRUE;


        END;

        lib_proc.close ( );

        RETURN mproc_id;
    END;

    PROCEDURE teste
    IS
        mproc_id INTEGER;
    BEGIN
        lib_parametros.salvar ( 'EMPRESA'
                              , 'HDB' );
        mcod_empresa := 'HDB';
        mproc_id :=
            executar ( '0001'
                     , '01/01/2004'
                     , '30/04/2004'
                     , '1' );

        lib_proc.list_output ( mproc_id
                             , 1 );

        dbms_output.put_line ( '' );
        dbms_output.put_line ( '---Arquivo Magnetico----' );
        dbms_output.put_line ( '' );
        lib_proc.list_output ( mproc_id
                             , 2 );
    END;

    PROCEDURE cabecalho ( pini DATE
                        , pfim DATE )
    IS
    BEGIN
        IF conta = 0
       AND pfolha = 0 THEN
            pfolha := 1;
            conta := 0;
            pprinta := TRUE;
        ELSIF conta >= 46 THEN
            pprinta := TRUE;
            conta := 0;
            pfolha := pfolha + 1;
            mlinha :=
                lib_str.w ( ''
                          , RPAD ( vlinha
                                 , 150
                                 , vlinha )
                          , 1 );
            lib_proc.add ( mlinha );
            lib_proc.new_page ( );
        ELSE
            pprinta := FALSE;
        END IF;

        IF pprinta THEN
            mlinha :=
                lib_str.w ( ''
                          , ''
                          , 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , temp
                          , 3 );
            mlinha :=
                lib_str.wcenter ( mlinha
                                ,    'Periodo : '
                                  || TO_CHAR ( pini
                                             , 'DD/MM/RRRR' )
                                  || ' Até '
                                  || TO_CHAR ( pfim
                                             , 'DD/MM/RRRR' )
                                , 150 );
            mlinha :=
                lib_str.wd ( mlinha
                           ,    'Data : '
                             || TO_CHAR ( SYSDATE
                                        , 'dd/mm/yyyy hh24:mi:ss' )
                             || '   '
                             || 'Pagina : '
                             || LPAD ( pfolha
                                     , 3
                                     , ' ' )
                           , 148 );
            lib_proc.add ( mlinha );
            conta := conta + 1;

            mlinha :=
                lib_str.w ( ''
                          , ''
                          , 1 );
            lib_proc.add ( mlinha );
            conta := conta + 1;

            mlinha :=
                lib_str.w ( ''
                          , ''
                          , 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , SUBSTR ( tnome
                                   , 1
                                   , 50 )
                          , 3 );
            mlinha :=
                lib_str.wcenter ( mlinha
                                , 'Insc.Estadual : ' || tinscest
                                , 150 );
            mlinha :=
                lib_str.wd ( mlinha
                           , 'C.N.P.J. : ' || tcpnj
                           , 148 );
            lib_proc.add ( mlinha );
            conta := conta + 1;

            mlinha :=
                lib_str.w ( ''
                          , ''
                          , 1 );
            lib_proc.add ( mlinha );
            conta := conta + 1;

            mlinha :=
                lib_str.w ( ''
                          , ''
                          , 1 );
            mlinha :=
                lib_str.wcenter ( mlinha
                                , 'Diferencial de Aliquota por Documento'
                                , 150 );
            lib_proc.add ( mlinha );
            conta := conta + 1;

            mlinha :=
                lib_str.w ( ''
                          , ''
                          , 1 );
            lib_proc.add ( mlinha );

            mlinha :=
                lib_str.w ( ''
                          , RPAD ( vlinha
                                 , 150
                                 , vlinha )
                          , 1 );
            lib_proc.add ( mlinha );
            conta := conta + 1;

            mlinha :=
                lib_str.w ( ''
                          , vsep
                          , 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , ' Numero '
                          , 3 );
            mlinha :=
                lib_str.w ( mlinha
                          , vsep
                          , LENGTH ( mlinha ) + 2 );
            mlinha :=
                lib_str.w ( mlinha
                          , ' Tipo '
                          , LENGTH ( mlinha ) + 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , vsep
                          , LENGTH ( mlinha ) + 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , ' Serie '
                          , LENGTH ( mlinha ) + 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , vsep
                          , LENGTH ( mlinha ) + 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , '  Data  '
                          , LENGTH ( mlinha ) + 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , vsep
                          , LENGTH ( mlinha ) + 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , '  Codigo  de  '
                          , LENGTH ( mlinha ) + 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , vsep
                          , LENGTH ( mlinha ) + 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , ' CFOP '
                          , LENGTH ( mlinha ) + 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , vsep
                          , LENGTH ( mlinha ) + 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , 'Nat.'
                          , LENGTH ( mlinha ) + 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , vsep
                          , LENGTH ( mlinha ) + 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , 'UF'
                          , LENGTH ( mlinha ) + 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , vsep
                          , LENGTH ( mlinha ) + 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , 'Aliq.'
                          , LENGTH ( mlinha ) + 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , vsep
                          , LENGTH ( mlinha ) + 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , 'Aliq.'
                          , LENGTH ( mlinha ) + 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , vsep
                          , LENGTH ( mlinha ) + 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , '   Valor   '
                          , LENGTH ( mlinha ) + 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , vsep
                          , LENGTH ( mlinha ) + 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , ' Base ICMS '
                          , LENGTH ( mlinha ) + 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , vsep
                          , LENGTH ( mlinha ) + 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , ' Base ICMS '
                          , LENGTH ( mlinha ) + 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , vsep
                          , LENGTH ( mlinha ) + 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , '   ICMS    '
                          , LENGTH ( mlinha ) + 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , vsep
                          , LENGTH ( mlinha ) + 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , '   ICMS    '
                          , LENGTH ( mlinha ) + 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , vsep
                          , LENGTH ( mlinha ) + 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , '  Valor    '
                          , LENGTH ( mlinha ) + 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , vsep
                          , LENGTH ( mlinha ) + 1 );
            lib_proc.add ( mlinha );
            conta := conta + 1;

            mlinha :=
                lib_str.w ( ''
                          , vsep
                          , 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , ' Docto. '
                          , 3 );
            mlinha :=
                lib_str.w ( mlinha
                          , vsep
                          , LENGTH ( mlinha ) + 2 );
            mlinha :=
                lib_str.w ( mlinha
                          , ' Doc. '
                          , LENGTH ( mlinha ) + 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , vsep
                          , LENGTH ( mlinha ) + 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , ' /Sub. '
                          , LENGTH ( mlinha ) + 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , vsep
                          , LENGTH ( mlinha ) + 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , ' Fiscal '
                          , LENGTH ( mlinha ) + 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , vsep
                          , LENGTH ( mlinha ) + 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , '   Emitente   '
                          , LENGTH ( mlinha ) + 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , vsep
                          , LENGTH ( mlinha ) + 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , '      '
                          , LENGTH ( mlinha ) + 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , vsep
                          , LENGTH ( mlinha ) + 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , 'Op. '
                          , LENGTH ( mlinha ) + 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , vsep
                          , LENGTH ( mlinha ) + 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , '  '
                          , LENGTH ( mlinha ) + 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , vsep
                          , LENGTH ( mlinha ) + 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , 'Orig.'
                          , LENGTH ( mlinha ) + 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , vsep
                          , LENGTH ( mlinha ) + 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , 'Dest.'
                          , LENGTH ( mlinha ) + 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , vsep
                          , LENGTH ( mlinha ) + 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , '  Contabil '
                          , LENGTH ( mlinha ) + 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , vsep
                          , LENGTH ( mlinha ) + 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , ' Tributada '
                          , LENGTH ( mlinha ) + 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , vsep
                          , LENGTH ( mlinha ) + 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , '   Outras  '
                          , LENGTH ( mlinha ) + 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , vsep
                          , LENGTH ( mlinha ) + 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , '  Devido   '
                          , LENGTH ( mlinha ) + 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , vsep
                          , LENGTH ( mlinha ) + 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , ' Destacado '
                          , LENGTH ( mlinha ) + 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , vsep
                          , LENGTH ( mlinha ) + 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , ' Dif.Aliq. '
                          , LENGTH ( mlinha ) + 1 );
            mlinha :=
                lib_str.w ( mlinha
                          , vsep
                          , LENGTH ( mlinha ) + 1 );
            lib_proc.add ( mlinha );
            conta := conta + 1;

            mlinha :=
                lib_str.w ( ''
                          , RPAD ( vlinha
                                 , 150
                                 , vlinha )
                          , 1 );
            lib_proc.add ( mlinha );
            conta := conta + 1;
        END IF;
    END cabecalho;
END msaf_custom_ambev_dif_cproc;
/
SHOW ERRORS;
