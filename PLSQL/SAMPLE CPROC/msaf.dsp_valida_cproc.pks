Prompt Package DSP_VALIDA_CPROC;
--
-- DSP_VALIDA_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dsp_valida_cproc
IS
    -- DATA       : CRIADA EM 16/AGO/2017
    -- V2 CRIADA EM 03/08/2018: REBELLO - MELHORIA DE PERFORMANCE

    FUNCTION parametros
        RETURN VARCHAR2;

    FUNCTION nome
        RETURN VARCHAR2;

    FUNCTION tipo
        RETURN VARCHAR2;

    FUNCTION versao
        RETURN VARCHAR2;

    FUNCTION descricao
        RETURN VARCHAR2;

    FUNCTION modulo
        RETURN VARCHAR2;

    FUNCTION classificacao
        RETURN VARCHAR2;

    FUNCTION executar ( p_periodo DATE
                      , p_estabelecimento lib_proc.vartab )
        RETURN INTEGER;

    CURSOR crs_lojas_uf (
        p_cod_empresa VARCHAR2
      , p_periodo DATE
    )
    IS
        SELECT   a.*
               , --
                 maxdwt.cod_estab
               , maxdwt.data_fiscal
               , maxdwt.movto_e_s
               , maxdwt.norm_dev
               , maxdwt.ident_docto
               , maxdwt.ident_fis_jur
               , maxdwt.num_docfis
               , maxdwt.serie_docfis
               , maxdwt.sub_serie_docfis
               , maxdwt.num_autentic_nfe identif_docfis
               , --
                 mindwt.cod_estab cod_estab2
               , mindwt.data_fiscal data_fiscal2
               , mindwt.movto_e_s movto_e_s2
               , mindwt.norm_dev norm_dev2
               , mindwt.ident_docto ident_docto2
               , mindwt.ident_fis_jur ident_fis_jur2
               , mindwt.num_docfis num_docfis2
               , mindwt.serie_docfis serie_docfis2
               , mindwt.sub_serie_docfis sub_serie_docfis2
               , mindwt.num_autentic_nfe identif_docfis2
            FROM ( SELECT   ddf.cod_empresa
                          , esd.cod_estado uf_estab
                          , DECODE ( ddf.movto_e_s, '9', 'S', 'E' ) saida_entrada
                          , xno.cod_natureza_op finalidade
                          , xcf.cod_cfo cfop
                          , stb.cod_situacao_b cst
                          , SIGN ( dim.vlr_contab_item ) vlr_contab_item
                          , SIGN ( dim.vlr_base_icms_1 ) base_trib
                          , SIGN ( dim.vlr_tributo_icms ) vlr_icms
                          , SIGN ( dim.aliq_tributo_icms ) aliq
                          , SIGN ( dim.vlr_base_icms_2 ) isenta
                          , SIGN ( dim.vlr_base_icms_3 ) outras
                          , SIGN ( dim.vlr_base_icms_4 ) reducao
                          , SIGN ( dim.vlr_tributo_icmss ) icms_st
                          , SIGN ( dim.vlr_ipi_ndestac ) ipi_n_destac
                          , SIGN ( dim.vlr_outras ) vlr_despesa
                          , CASE
                                WHEN SIGN (
                                              dim.vlr_contab_item
                                            - dim.vlr_base_icms_1
                                            - dim.vlr_base_icms_2
                                            - dim.vlr_base_icms_3
                                            - dim.vlr_base_icms_4
                                            - dim.vlr_tributo_icmss
                                            - dim.vlr_outras
                                            - dim.vlr_ipi_ndestac
                                     ) = 0 THEN
                                    'SIM'
                                ELSE
                                    'NAO'
                            END
                                bate_vlr_item_com_bases
                          , COUNT ( 0 ) linhas
                          , ( SELECT    dav.icms
                                     || '|'
                                     || dav.aliq_icms
                                     || '|'
                                     || dav.bc_icms
                                     || '|'
                                     || dav.isentas
                                     || '|'
                                     || dav.outras
                                     || '|'
                                     || dav.reducao
                                FROM msafi.dsp_auto_valida dav
                               WHERE dav.cod_empresa = p_cod_empresa -- msafi.dpsp.V_EMPRESA
                                 AND dav.cod_estab = 'LOJ'
                                 AND DECODE ( dav.cod_estado, 'XX', esd.cod_estado, dav.cod_estado ) = esd.cod_estado
                                 AND dav.entrada_saida = DECODE ( ddf.movto_e_s, '9', 'S', 'E' )
                                 AND dav.cod_natureza_op = xno.cod_natureza_op
                                 AND dav.cod_cfo = xcf.cod_cfo
                                 AND dav.cod_situacao_b = stb.cod_situacao_b )
                                regras_validacao
                          , NULL acao
                          ,    ddf.cod_empresa
                            || esd.cod_estado
                            || DECODE ( ddf.movto_e_s, '9', 'S', 'E' )
                            || xno.cod_natureza_op
                            || xcf.cod_cfo
                            || stb.cod_situacao_b
                            || SIGN ( dim.vlr_contab_item )
                            || SIGN ( dim.vlr_base_icms_1 )
                            || SIGN ( dim.vlr_tributo_icms )
                            || SIGN ( dim.aliq_tributo_icms )
                            || SIGN ( dim.vlr_base_icms_2 )
                            || SIGN ( dim.vlr_base_icms_3 )
                            || SIGN ( dim.vlr_base_icms_4 )
                            || SIGN ( dim.vlr_tributo_icmss )
                            || SIGN ( dim.vlr_ipi_ndestac )
                            || (   1
                                 - SIGN (
                                          ABS (
                                                  dim.vlr_contab_item
                                                - dim.vlr_base_icms_1
                                                - dim.vlr_base_icms_2
                                                - dim.vlr_base_icms_3
                                                - dim.vlr_base_icms_4
                                                - dim.vlr_tributo_icmss
                                                - dim.vlr_outras
                                                - dim.vlr_ipi_ndestac
                                          )
                                   ) )
                                concatenacao
                          , MIN ( ddf.ident_docto_fiscal ) min_ident_docto_fiscal
                          , MAX ( ddf.ident_docto_fiscal ) max_ident_docto_fiscal
                       FROM msaf.dwt_docto_fiscal ddf
                          , msaf.dwt_itens_merc dim
                          , msaf.x04_pessoa_fis_jur pfj
                          , msaf.y2026_sit_trb_uf_b stb
                          , msaf.x2012_cod_fiscal xcf
                          , msaf.x2006_natureza_op xno
                          , msaf.estabelecimento esb
                          , msafi.dsp_estabelecimento dspe
                          , msaf.estado esd
                          , dsp_valida_estab filtro
                      WHERE ddf.cod_empresa = p_cod_empresa
                        AND ddf.cod_empresa = dspe.cod_empresa
                        AND ddf.cod_estab = dspe.cod_estab
                        AND esd.cod_estado = filtro.cod_filtro
                        AND filtro.tip = 'Lojas_Uf'
                        AND dspe.tipo = 'L'
                        AND ddf.data_fiscal BETWEEN p_periodo AND LAST_DAY ( p_periodo )
                        AND dim.data_fiscal BETWEEN p_periodo AND LAST_DAY ( p_periodo ) ---force partition
                        AND ddf.serie_docfis <> 'ECF'
                        AND ddf.situacao = 'N'
                        -----MSAF.DWT_ITENS_MERC      DIM
                        /*  And Dim.Cod_Empresa  = Ddf.Cod_Empresa
                                       And Dim.Cod_Estab  = Ddf.Cod_Estab
                                       And Dim.Data_Fiscal  = Ddf.Data_Fiscal
                                       And Dim.Movto_e_s  = Ddf.Movto_e_s
                                       And Dim.Norm_Dev   = Ddf.Norm_Dev
                                       And Dim.Ident_Docto  = Ddf.Ident_Docto
                                       And Dim.Ident_Fis_Jur = Ddf.Ident_Fis_Jur
                                       And Dim.Num_Docfis   = Ddf.Num_Docfis
                                       And Dim.Serie_Docfis = Ddf.Serie_Docfis
                                       And Dim.Sub_Serie_Docfis = Ddf.Sub_Serie_Docfis*/
                        AND dim.ident_docto_fiscal = ddf.ident_docto_fiscal
                        -----MSAF.X04_PESSOA_FIS_JUR  PFJ
                        AND pfj.ident_fis_jur = dim.ident_fis_jur
                        -----MSAF.Y2026_SIT_TRB_UF_B  STB
                        AND stb.ident_situacao_b(+) = dim.ident_situacao_b
                        -----MSAF.X2012_COD_FISCAL    XCF
                        AND xcf.ident_cfo(+) = dim.ident_cfo
                        -----MSAF.X2006_NATUREZA_OP   XNO
                        AND xno.ident_natureza_op(+) = dim.ident_natureza_op
                        -----MSAF.ESTABELECIMENTO     ESB
                        AND esb.cod_empresa = ddf.cod_empresa
                        AND esb.cod_estab = ddf.cod_estab
                        -----MSAF.ESTADO              ESD
                        AND esd.ident_estado = esb.ident_estado
                        -----MSAFI.DSP_AUTO_VALIDA    DAV
                        AND NOT EXISTS
                                (SELECT *
                                   FROM msafi.dsp_auto_valida dav
                                  WHERE dav.cod_empresa = p_cod_empresa
                                    AND dav.cod_estab = 'LOJ'
                                    AND DECODE ( dav.cod_estado, 'XX', esd.cod_estado, dav.cod_estado ) = esd.cod_estado
                                    AND dav.entrada_saida = DECODE ( ddf.movto_e_s, '9', 'S', 'E' )
                                    AND dav.cod_natureza_op = xno.cod_natureza_op
                                    AND dav.cod_cfo = xcf.cod_cfo
                                    AND dav.cod_situacao_b = stb.cod_situacao_b
                                    AND dav.icms = SIGN ( dim.vlr_tributo_icms )
                                    AND dav.aliq_icms = SIGN ( dim.aliq_tributo_icms )
                                    AND dav.bc_icms = SIGN ( dim.vlr_base_icms_1 )
                                    AND dav.isentas = SIGN ( dim.vlr_base_icms_2 )
                                    AND dav.outras = SIGN ( dim.vlr_base_icms_3 )
                                    AND dav.reducao = SIGN ( dim.vlr_base_icms_4 )
                                    AND   dim.vlr_contab_item
                                        - dim.vlr_base_icms_1
                                        - dim.vlr_base_icms_2
                                        - dim.vlr_base_icms_3
                                        - dim.vlr_base_icms_4
                                        - dim.vlr_tributo_icmss
                                        - dim.vlr_outras
                                        - dim.vlr_ipi_ndestac = 0)
                   GROUP BY ddf.cod_empresa
                          , dspe.cod_estado
                          , xno.cod_natureza_op
                          , xcf.cod_cfo
                          , stb.cod_situacao_b
                          , esd.cod_estado
                          , DECODE ( ddf.movto_e_s, '9', 'S', 'E' )
                          , xno.cod_natureza_op
                          , xcf.cod_cfo
                          , stb.cod_situacao_b
                          , SIGN ( dim.vlr_contab_item )
                          , SIGN ( dim.vlr_tributo_icms )
                          , SIGN ( dim.aliq_tributo_icms )
                          , SIGN ( dim.vlr_base_icms_1 )
                          , SIGN ( dim.vlr_base_icms_2 )
                          , SIGN ( dim.vlr_base_icms_3 )
                          , SIGN ( dim.vlr_base_icms_4 )
                          , SIGN ( dim.vlr_tributo_icmss )
                          , SIGN ( dim.vlr_ipi_ndestac )
                          , SIGN ( dim.vlr_outras )
                          , CASE
                                WHEN SIGN (
                                              dim.vlr_contab_item
                                            - dim.vlr_base_icms_1
                                            - dim.vlr_base_icms_2
                                            - dim.vlr_base_icms_3
                                            - dim.vlr_base_icms_4
                                            - dim.vlr_tributo_icmss
                                            - dim.vlr_outras
                                            - dim.vlr_ipi_ndestac
                                     ) = 0 THEN
                                    'SIM'
                                ELSE
                                    'NAO'
                            END
                          ,   1
                            - SIGN (
                                     ABS (
                                             dim.vlr_contab_item
                                           - dim.vlr_base_icms_1
                                           - dim.vlr_base_icms_2
                                           - dim.vlr_base_icms_3
                                           - dim.vlr_base_icms_4
                                           - dim.vlr_tributo_icmss
                                           - dim.vlr_outras
                                           - dim.vlr_ipi_ndestac
                                     )
                              ) ) a
               , msaf.dwt_docto_fiscal maxdwt
               , msaf.dwt_docto_fiscal mindwt
           WHERE maxdwt.ident_docto_fiscal = a.max_ident_docto_fiscal
             ---
             AND mindwt.ident_docto_fiscal = a.min_ident_docto_fiscal
             ---
             AND maxdwt.data_fiscal BETWEEN p_periodo AND LAST_DAY ( p_periodo ) ---force partition
             AND mindwt.data_fiscal BETWEEN p_periodo AND LAST_DAY ( p_periodo ) ---force partition
        ORDER BY linhas DESC;

    CURSOR crs_cd (
        p_cod_empresa VARCHAR2
      , p_periodo DATE
    )
    IS
        SELECT   a.*
               ,    '    || '' OR (DDF.COD_ESTAB = '''''''''
                 || a.cod_estab
                 || ''''''''' AND DDF.MOVTO_E_S'
                 || DECODE ( a.saida_entrada, 'S', '=', '<>' )
                 || '''''''''9'''''''''
                 || ' AND XNO.COD_NATUREZA_OP'
                 || CASE WHEN a.finalidade IS NULL THEN ' IS NULL' ELSE '=''''''''' || a.finalidade || '''''''''' END
                 || ' AND XCF.COD_CFO'
                 || CASE WHEN a.cfop IS NULL THEN ' IS NULL' ELSE '=''''''''' || a.cfop || '''''''''' END
                 || ' AND STB.COD_SITUACAO_B'
                 || CASE WHEN a.cst IS NULL THEN ' IS NULL' ELSE '=''''''''' || a.cst || '''''''''' END
                 || ' AND SIGN(DIM.VLR_BASE_ICMS_1) = '
                 || a.base_trib
                 || ' AND SIGN(DIM.VLR_TRIBUTO_ICMS) = '
                 || a.vlr_icms
                 || ' AND SIGN(DIM.ALIQ_TRIBUTO_ICMS) = '
                 || a.aliq
                 || ' AND SIGN(DIM.VLR_BASE_ICMS_2) = '
                 || a.isenta
                 || ' AND SIGN(DIM.VLR_BASE_ICMS_3) = '
                 || a.outras
                 || ' AND SIGN(DIM.VLR_BASE_ICMS_4) = '
                 || a.reducao
                 || ' AND SIGN(DIM.VLR_CONTAB_ITEM) = '
                 || a.vlr_contab_item
                 || ' AND SIGN(DIM.VLR_TRIBUTO_ICMSS) = '
                 || a.icms_st
                 || ' AND SIGN(DIM.VLR_IPI_NDESTAC) = '
                 || a.ipi_n_destac
                 || ' AND DIM.VLR_CONTAB_ITEM - DIM.VLR_BASE_ICMS_1 - DIM.VLR_BASE_ICMS_2 - DIM.VLR_BASE_ICMS_3 - DIM.VLR_BASE_ICMS_4 - DIM.VLR_TRIBUTO_ICMSS - DIM.VLR_OUTRAS - DIM.VLR_IPI_NDESTAC '
                 || CASE WHEN a.bate_vlr_item_com_bases = 'SIM' THEN '=' ELSE '<>' END
                 || ' 0) '''
                     AS criterios_basicos
               , mindwt.cod_estab cod_estab1
               , mindwt.data_fiscal
               , mindwt.movto_e_s
               , mindwt.norm_dev
               , mindwt.ident_docto
               , mindwt.ident_fis_jur
               , mindwt.num_docfis
               , mindwt.serie_docfis
               , mindwt.sub_serie_docfis
               , mindwt.num_autentic_nfe identif_docfis
               , maxdwt.cod_estab cod_estab2
               , maxdwt.data_fiscal data_fiscal2
               , maxdwt.movto_e_s movto_e_s2
               , maxdwt.norm_dev norm_dev2
               , maxdwt.ident_docto ident_docto2
               , maxdwt.ident_fis_jur ident_fis_jur2
               , maxdwt.num_docfis num_docfis2
               , maxdwt.serie_docfis serie_docfis2
               , maxdwt.sub_serie_docfis sub_serie_docfis2
               , maxdwt.num_autentic_nfe identif_docfis2
            FROM ( SELECT   ddf.cod_empresa
                          , ddf.cod_estab
                          , DECODE ( ddf.movto_e_s, '9', 'S', 'E' ) saida_entrada
                          , xno.cod_natureza_op finalidade
                          , xcf.cod_cfo cfop
                          , stb.cod_situacao_b cst
                          , SIGN ( dim.vlr_contab_item ) vlr_contab_item
                          , SIGN ( dim.vlr_base_icms_1 ) base_trib
                          , SIGN ( dim.vlr_tributo_icms ) vlr_icms
                          , SIGN ( dim.aliq_tributo_icms ) aliq
                          , SIGN ( dim.vlr_base_icms_2 ) isenta
                          , SIGN ( dim.vlr_base_icms_3 ) outras
                          , SIGN ( dim.vlr_base_icms_4 ) reducao
                          , SIGN ( dim.vlr_tributo_icmss ) icms_st
                          , SIGN ( dim.vlr_ipi_ndestac ) ipi_n_destac
                          , SIGN ( dim.vlr_outras ) vlr_despesa
                          , CASE
                                WHEN SIGN (
                                              dim.vlr_contab_item
                                            - dim.vlr_base_icms_1
                                            - dim.vlr_base_icms_2
                                            - dim.vlr_base_icms_3
                                            - dim.vlr_base_icms_4
                                            - dim.vlr_tributo_icmss
                                            - dim.vlr_outras
                                            - dim.vlr_ipi_ndestac
                                     ) = 0 THEN
                                    'SIM'
                                ELSE
                                    'NAO'
                            END
                                bate_vlr_item_com_bases
                          , COUNT ( 0 ) linhas
                          , ( SELECT    dav.icms
                                     || '|'
                                     || dav.aliq_icms
                                     || '|'
                                     || dav.bc_icms
                                     || '|'
                                     || dav.isentas
                                     || '|'
                                     || dav.outras
                                     || '|'
                                     || dav.reducao
                                FROM msafi.dsp_auto_valida dav
                               WHERE dav.cod_empresa = ddf.cod_empresa
                                 AND dav.cod_estab = ddf.cod_estab
                                 AND dav.cod_estado = 'XX'
                                 AND dav.entrada_saida = DECODE ( ddf.movto_e_s, '9', 'S', 'E' )
                                 AND dav.cod_natureza_op = xno.cod_natureza_op
                                 AND dav.cod_cfo = xcf.cod_cfo
                                 AND dav.cod_situacao_b = stb.cod_situacao_b )
                                regras_validacao
                          , NULL acao
                          ,    ddf.cod_empresa
                            || ddf.cod_estab
                            || DECODE ( ddf.movto_e_s, '9', 'S', 'E' )
                            || xno.cod_natureza_op
                            || xcf.cod_cfo
                            || stb.cod_situacao_b
                            || SIGN ( dim.vlr_contab_item )
                            || SIGN ( dim.vlr_base_icms_1 )
                            || SIGN ( dim.vlr_tributo_icms )
                            || SIGN ( dim.aliq_tributo_icms )
                            || SIGN ( dim.vlr_base_icms_2 )
                            || SIGN ( dim.vlr_base_icms_3 )
                            || SIGN ( dim.vlr_base_icms_4 )
                            || SIGN ( dim.vlr_tributo_icmss )
                            || SIGN ( dim.vlr_ipi_ndestac )
                            || (   1
                                 - SIGN (
                                          ABS (
                                                  dim.vlr_contab_item
                                                - dim.vlr_base_icms_1
                                                - dim.vlr_base_icms_2
                                                - dim.vlr_base_icms_3
                                                - dim.vlr_base_icms_4
                                                - dim.vlr_tributo_icmss
                                                - dim.vlr_outras
                                                - dim.vlr_ipi_ndestac
                                          )
                                   ) )
                                concatenacao
                          , MIN ( ddf.ident_docto_fiscal ) min_ident_docto_fiscal
                          , MAX ( ddf.ident_docto_fiscal ) max_ident_docto_fiscal
                       FROM msaf.dwt_docto_fiscal ddf
                          , msaf.dwt_itens_merc dim
                          , msaf.x04_pessoa_fis_jur pfj
                          , msaf.y2026_sit_trb_uf_b stb
                          , msaf.x2012_cod_fiscal xcf
                          , msaf.x2006_natureza_op xno
                          , msaf.estabelecimento esb
                          , msafi.dsp_estabelecimento dspe
                          , dsp_valida_estab filtro
                      WHERE ddf.cod_empresa = p_cod_empresa
                        AND ddf.cod_empresa = dspe.cod_empresa
                        AND ddf.cod_estab = dspe.cod_estab
                        AND dspe.tipo = 'C'
                        AND filtro.tip = 'CD_Uf'
                        AND dspe.cod_estab = filtro.cod_filtro
                        AND ddf.data_fiscal BETWEEN p_periodo AND LAST_DAY ( p_periodo )
                        AND dim.data_fiscal BETWEEN p_periodo AND LAST_DAY ( p_periodo ) ---force partition
                        AND ddf.serie_docfis <> 'ECF'
                        AND ddf.situacao = 'N'
                        -----MSAF.DWT_ITENS_MERC      DIM
                        /*And Dim.Cod_Empresa    = Ddf.Cod_Empresa
                                       And Dim.Cod_Estab    = Ddf.Cod_Estab
                                       And Dim.Data_Fiscal    = Ddf.Data_Fiscal
                                       And Dim.Movto_e_s    = Ddf.Movto_e_s
                                       And Dim.Norm_Dev     = Ddf.Norm_Dev
                                       And Dim.Ident_Docto    = Ddf.Ident_Docto
                                       And Dim.Ident_Fis_Jur  = Ddf.Ident_Fis_Jur
                                       And Dim.Num_Docfis     = Ddf.Num_Docfis
                                       And Dim.Serie_Docfis   = Ddf.Serie_Docfis
                                       And Dim.Sub_Serie_Docfis = Ddf.Sub_Serie_Docfis*/
                        AND dim.ident_docto_fiscal = ddf.ident_docto_fiscal
                        -----MSAF.X04_PESSOA_FIS_JUR  PFJ
                        AND pfj.ident_fis_jur = dim.ident_fis_jur
                        -----MSAF.Y2026_SIT_TRB_UF_B  STB
                        AND stb.ident_situacao_b(+) = dim.ident_situacao_b
                        -----MSAF.X2012_COD_FISCAL    XCF
                        AND xcf.ident_cfo(+) = dim.ident_cfo
                        -----MSAF.X2006_NATUREZA_OP   XNO
                        AND xno.ident_natureza_op(+) = dim.ident_natureza_op
                        -----MSAF.ESTABELECIMENTO     ESB
                        AND esb.cod_empresa = ddf.cod_empresa
                        AND esb.cod_estab = ddf.cod_estab
                        -----MSAFI.DSP_AUTO_VALIDA    DAV
                        AND NOT EXISTS
                                (SELECT *
                                   FROM msafi.dsp_auto_valida dav
                                  WHERE dav.cod_empresa = ddf.cod_empresa
                                    AND dav.cod_estab = ddf.cod_estab
                                    AND dav.cod_estado = 'XX'
                                    AND dav.entrada_saida = DECODE ( ddf.movto_e_s, '9', 'S', 'E' )
                                    AND dav.cod_natureza_op = xno.cod_natureza_op
                                    AND dav.cod_cfo = xcf.cod_cfo
                                    AND dav.cod_situacao_b = stb.cod_situacao_b
                                    AND dav.icms = SIGN ( dim.vlr_tributo_icms )
                                    AND dav.aliq_icms = SIGN ( dim.aliq_tributo_icms )
                                    AND dav.bc_icms = SIGN ( dim.vlr_base_icms_1 )
                                    AND dav.isentas = SIGN ( dim.vlr_base_icms_2 )
                                    AND dav.outras = SIGN ( dim.vlr_base_icms_3 )
                                    AND dav.reducao = SIGN ( dim.vlr_base_icms_4 )
                                    AND   dim.vlr_contab_item
                                        - dim.vlr_base_icms_1
                                        - dim.vlr_base_icms_2
                                        - dim.vlr_base_icms_3
                                        - dim.vlr_base_icms_4
                                        - dim.vlr_tributo_icmss
                                        - dim.vlr_outras
                                        - dim.vlr_ipi_ndestac = 0)
                   GROUP BY ddf.cod_empresa
                          , ddf.cod_estab
                          , xno.cod_natureza_op
                          , xcf.cod_cfo
                          , stb.cod_situacao_b
                          , DECODE ( ddf.movto_e_s, '9', 'S', 'E' )
                          , xno.cod_natureza_op
                          , xcf.cod_cfo
                          , stb.cod_situacao_b
                          , SIGN ( dim.vlr_contab_item )
                          , SIGN ( dim.vlr_tributo_icms )
                          , SIGN ( dim.aliq_tributo_icms )
                          , SIGN ( dim.vlr_base_icms_1 )
                          , SIGN ( dim.vlr_base_icms_2 )
                          , SIGN ( dim.vlr_base_icms_3 )
                          , SIGN ( dim.vlr_base_icms_4 )
                          , SIGN ( dim.vlr_tributo_icmss )
                          , SIGN ( dim.vlr_ipi_ndestac )
                          , SIGN ( dim.vlr_outras )
                          , CASE
                                WHEN SIGN (
                                              dim.vlr_contab_item
                                            - dim.vlr_base_icms_1
                                            - dim.vlr_base_icms_2
                                            - dim.vlr_base_icms_3
                                            - dim.vlr_base_icms_4
                                            - dim.vlr_tributo_icmss
                                            - dim.vlr_outras
                                            - dim.vlr_ipi_ndestac
                                     ) = 0 THEN
                                    'SIM'
                                ELSE
                                    'NAO'
                            END
                          ,   1
                            - SIGN (
                                     ABS (
                                             dim.vlr_contab_item
                                           - dim.vlr_base_icms_1
                                           - dim.vlr_base_icms_2
                                           - dim.vlr_base_icms_3
                                           - dim.vlr_base_icms_4
                                           - dim.vlr_tributo_icmss
                                           - dim.vlr_outras
                                           - dim.vlr_ipi_ndestac
                                     )
                              ) ) a
               , msaf.dwt_docto_fiscal maxdwt
               , msaf.dwt_docto_fiscal mindwt
           WHERE maxdwt.ident_docto_fiscal = a.max_ident_docto_fiscal
             ---
             AND mindwt.ident_docto_fiscal = a.min_ident_docto_fiscal
             ---
             AND maxdwt.data_fiscal BETWEEN p_periodo AND LAST_DAY ( p_periodo ) ---force partition
             AND mindwt.data_fiscal BETWEEN p_periodo AND LAST_DAY ( p_periodo ) ---force partition
        ORDER BY linhas DESC;

    CURSOR crs_lojas (
        p_cod_empresa VARCHAR2
      , p_periodo DATE
      , p_cod_estab VARCHAR2
    )
    IS
        SELECT   a.*
               , --
                 maxdwt.cod_estab
               , maxdwt.data_fiscal
               , maxdwt.movto_e_s
               , maxdwt.norm_dev
               , maxdwt.ident_docto
               , maxdwt.ident_fis_jur
               , maxdwt.num_docfis
               , maxdwt.serie_docfis
               , maxdwt.sub_serie_docfis
               , maxdwt.num_autentic_nfe identif_docfis
               , --
                 mindwt.cod_estab cod_estab2
               , mindwt.data_fiscal data_fiscal2
               , mindwt.movto_e_s movto_e_s2
               , mindwt.norm_dev norm_dev2
               , mindwt.ident_docto ident_docto2
               , mindwt.ident_fis_jur ident_fis_jur2
               , mindwt.num_docfis num_docfis2
               , mindwt.serie_docfis serie_docfis2
               , mindwt.sub_serie_docfis sub_serie_docfis2
               , mindwt.num_autentic_nfe identif_docfis2
            FROM ( SELECT   ddf.cod_empresa
                          , esd.cod_estado uf_estab
                          , DECODE ( ddf.movto_e_s, '9', 'S', 'E' ) saida_entrada
                          , xno.cod_natureza_op finalidade
                          , xcf.cod_cfo cfop
                          , stb.cod_situacao_b cst
                          , SIGN ( dim.vlr_contab_item ) vlr_contab_item
                          , SIGN ( dim.vlr_base_icms_1 ) base_trib
                          , SIGN ( dim.vlr_tributo_icms ) vlr_icms
                          , SIGN ( dim.aliq_tributo_icms ) aliq
                          , SIGN ( dim.vlr_base_icms_2 ) isenta
                          , SIGN ( dim.vlr_base_icms_3 ) outras
                          , SIGN ( dim.vlr_base_icms_4 ) reducao
                          , SIGN ( dim.vlr_tributo_icmss ) icms_st
                          , SIGN ( dim.vlr_ipi_ndestac ) ipi_n_destac
                          , SIGN ( dim.vlr_outras ) vlr_despesa
                          , CASE
                                WHEN SIGN (
                                              dim.vlr_contab_item
                                            - dim.vlr_base_icms_1
                                            - dim.vlr_base_icms_2
                                            - dim.vlr_base_icms_3
                                            - dim.vlr_base_icms_4
                                            - dim.vlr_tributo_icmss
                                            - dim.vlr_outras
                                            - dim.vlr_ipi_ndestac
                                     ) = 0 THEN
                                    'SIM'
                                ELSE
                                    'NAO'
                            END
                                bate_vlr_item_com_bases
                          , COUNT ( 0 ) linhas
                          , ( SELECT    dav.icms
                                     || '|'
                                     || dav.aliq_icms
                                     || '|'
                                     || dav.bc_icms
                                     || '|'
                                     || dav.isentas
                                     || '|'
                                     || dav.outras
                                     || '|'
                                     || dav.reducao
                                FROM msafi.dsp_auto_valida dav
                               WHERE dav.cod_empresa = p_cod_empresa -- msafi.dpsp.v_empresa
                                 AND dav.cod_estab = 'LOJ'
                                 AND DECODE ( dav.cod_estado, 'XX', esd.cod_estado, dav.cod_estado ) = esd.cod_estado
                                 AND dav.entrada_saida = DECODE ( ddf.movto_e_s, '9', 'S', 'E' )
                                 AND dav.cod_natureza_op = xno.cod_natureza_op
                                 AND dav.cod_cfo = xcf.cod_cfo
                                 AND dav.cod_situacao_b = stb.cod_situacao_b )
                                regras_validacao
                          , NULL acao
                          ,    ddf.cod_empresa
                            || esd.cod_estado
                            || DECODE ( ddf.movto_e_s, '9', 'S', 'E' )
                            || xno.cod_natureza_op
                            || xcf.cod_cfo
                            || stb.cod_situacao_b
                            || SIGN ( dim.vlr_contab_item )
                            || SIGN ( dim.vlr_base_icms_1 )
                            || SIGN ( dim.vlr_tributo_icms )
                            || SIGN ( dim.aliq_tributo_icms )
                            || SIGN ( dim.vlr_base_icms_2 )
                            || SIGN ( dim.vlr_base_icms_3 )
                            || SIGN ( dim.vlr_base_icms_4 )
                            || SIGN ( dim.vlr_tributo_icmss )
                            || SIGN ( dim.vlr_ipi_ndestac )
                            || (   1
                                 - SIGN (
                                          ABS (
                                                  dim.vlr_contab_item
                                                - dim.vlr_base_icms_1
                                                - dim.vlr_base_icms_2
                                                - dim.vlr_base_icms_3
                                                - dim.vlr_base_icms_4
                                                - dim.vlr_tributo_icmss
                                                - dim.vlr_outras
                                                - dim.vlr_ipi_ndestac
                                          )
                                   ) )
                                concatenacao
                          , MIN ( ddf.ident_docto_fiscal ) min_ident_docto_fiscal
                          , MAX ( ddf.ident_docto_fiscal ) max_ident_docto_fiscal
                       FROM msaf.dwt_docto_fiscal ddf
                          , msaf.dwt_itens_merc dim
                          , msaf.x04_pessoa_fis_jur pfj
                          , msaf.y2026_sit_trb_uf_b stb
                          , msaf.x2012_cod_fiscal xcf
                          , msaf.x2006_natureza_op xno
                          , msaf.estabelecimento esb
                          , msafi.dsp_estabelecimento dspe
                          , msaf.estado esd
                      WHERE ddf.cod_empresa = p_cod_empresa
                        AND ddf.cod_empresa = dspe.cod_empresa
                        AND ddf.cod_estab = dspe.cod_estab
                        AND dspe.cod_estab = p_cod_estab
                        AND dspe.tipo = 'L'
                        AND ddf.data_fiscal BETWEEN p_periodo AND LAST_DAY ( p_periodo )
                        AND dim.data_fiscal BETWEEN p_periodo AND LAST_DAY ( p_periodo ) ---force partition
                        AND ddf.serie_docfis <> 'ECF'
                        AND ddf.situacao = 'N'
                        -----MSAF.DWT_ITENS_MERC      DIM
                        /*And Dim.Cod_Empresa  = Ddf.Cod_Empresa
                                       And Dim.Cod_Estab  = Ddf.Cod_Estab
                                       And Dim.Data_Fiscal  = Ddf.Data_Fiscal
                                       And Dim.Movto_e_s  = Ddf.Movto_e_s
                                       And Dim.Norm_Dev   = Ddf.Norm_Dev
                                       And Dim.Ident_Docto  = Ddf.Ident_Docto
                                       And Dim.Ident_Fis_Jur = Ddf.Ident_Fis_Jur
                                       And Dim.Num_Docfis   = Ddf.Num_Docfis
                                       And Dim.Serie_Docfis = Ddf.Serie_Docfis
                                       And Dim.Sub_Serie_Docfis = Ddf.Sub_Serie_Docfis*/
                        AND dim.ident_docto_fiscal = ddf.ident_docto_fiscal
                        -----MSAF.X04_PESSOA_FIS_JUR  PFJ
                        AND pfj.ident_fis_jur = ddf.ident_fis_jur
                        -----MSAF.Y2026_SIT_TRB_UF_B  STB
                        AND stb.ident_situacao_b(+) = dim.ident_situacao_b
                        -----MSAF.X2012_COD_FISCAL    XCF
                        AND xcf.ident_cfo(+) = dim.ident_cfo
                        -----MSAF.X2006_NATUREZA_OP   XNO
                        AND xno.ident_natureza_op(+) = dim.ident_natureza_op
                        -----MSAF.ESTABELECIMENTO     ESB
                        AND esb.cod_empresa = ddf.cod_empresa
                        AND esb.cod_estab = ddf.cod_estab
                        -----MSAF.ESTADO              ESD
                        AND esd.ident_estado = esb.ident_estado
                        -----MSAFI.DSP_AUTO_VALIDA    DAV
                        AND NOT EXISTS
                                (SELECT *
                                   FROM msafi.dsp_auto_valida dav
                                  WHERE dav.cod_empresa = ddf.cod_empresa
                                    AND dav.cod_estab = 'LOJ'
                                    AND DECODE ( dav.cod_estado, 'XX', esd.cod_estado, dav.cod_estado ) = esd.cod_estado
                                    AND dav.entrada_saida = DECODE ( ddf.movto_e_s, '9', 'S', 'E' )
                                    AND dav.cod_natureza_op = xno.cod_natureza_op
                                    AND dav.cod_cfo = xcf.cod_cfo
                                    AND dav.cod_situacao_b = stb.cod_situacao_b
                                    AND dav.icms = SIGN ( dim.vlr_tributo_icms )
                                    AND dav.aliq_icms = SIGN ( dim.aliq_tributo_icms )
                                    AND dav.bc_icms = SIGN ( dim.vlr_base_icms_1 )
                                    AND dav.isentas = SIGN ( dim.vlr_base_icms_2 )
                                    AND dav.outras = SIGN ( dim.vlr_base_icms_3 )
                                    AND dav.reducao = SIGN ( dim.vlr_base_icms_4 )
                                    AND   dim.vlr_contab_item
                                        - dim.vlr_base_icms_1
                                        - dim.vlr_base_icms_2
                                        - dim.vlr_base_icms_3
                                        - dim.vlr_base_icms_4
                                        - dim.vlr_tributo_icmss
                                        - dim.vlr_outras
                                        - dim.vlr_ipi_ndestac = 0)
                   GROUP BY ddf.cod_empresa
                          , dspe.cod_estado
                          , xno.cod_natureza_op
                          , xcf.cod_cfo
                          , stb.cod_situacao_b
                          , esd.cod_estado
                          , DECODE ( ddf.movto_e_s, '9', 'S', 'E' )
                          , xno.cod_natureza_op
                          , xcf.cod_cfo
                          , stb.cod_situacao_b
                          , SIGN ( dim.vlr_contab_item )
                          , SIGN ( dim.vlr_tributo_icms )
                          , SIGN ( dim.aliq_tributo_icms )
                          , SIGN ( dim.vlr_base_icms_1 )
                          , SIGN ( dim.vlr_base_icms_2 )
                          , SIGN ( dim.vlr_base_icms_3 )
                          , SIGN ( dim.vlr_base_icms_4 )
                          , SIGN ( dim.vlr_tributo_icmss )
                          , SIGN ( dim.vlr_ipi_ndestac )
                          , SIGN ( dim.vlr_outras )
                          , CASE
                                WHEN SIGN (
                                              dim.vlr_contab_item
                                            - dim.vlr_base_icms_1
                                            - dim.vlr_base_icms_2
                                            - dim.vlr_base_icms_3
                                            - dim.vlr_base_icms_4
                                            - dim.vlr_tributo_icmss
                                            - dim.vlr_outras
                                            - dim.vlr_ipi_ndestac
                                     ) = 0 THEN
                                    'SIM'
                                ELSE
                                    'NAO'
                            END
                          ,   1
                            - SIGN (
                                     ABS (
                                             dim.vlr_contab_item
                                           - dim.vlr_base_icms_1
                                           - dim.vlr_base_icms_2
                                           - dim.vlr_base_icms_3
                                           - dim.vlr_base_icms_4
                                           - dim.vlr_tributo_icmss
                                           - dim.vlr_outras
                                           - dim.vlr_ipi_ndestac
                                     )
                              ) ) a
               , msaf.dwt_docto_fiscal maxdwt
               , msaf.dwt_docto_fiscal mindwt
           WHERE maxdwt.ident_docto_fiscal = a.max_ident_docto_fiscal
             ---
             AND mindwt.ident_docto_fiscal = a.min_ident_docto_fiscal
             ---
             AND maxdwt.data_fiscal BETWEEN p_periodo AND LAST_DAY ( p_periodo ) ---force partition
             AND mindwt.data_fiscal BETWEEN p_periodo AND LAST_DAY ( p_periodo ) ---force partition
        ORDER BY linhas DESC;
END dsp_valida_cproc;
/
SHOW ERRORS;
