Prompt Package DPSP_REL_VALIDA_CPROC;
--
-- DPSP_REL_VALIDA_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dpsp_rel_valida_cproc
IS
    -- AUTOR    : DSP - REBELLO
    -- DATA     : 03/FEV/2017
    -- DESCRIÇÃO: Relatorio de Notas Fiscais do VALIDA

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

    FUNCTION fazcampo ( p_i_campo IN VARCHAR2
                      , p_i_fill IN VARCHAR2
                      , p_i_size IN NUMBER )
        RETURN VARCHAR2;

    FUNCTION fazcampo ( p_i_campo IN NUMBER
                      , p_i_format IN VARCHAR2
                      , p_i_fill IN VARCHAR2
                      , p_i_size IN NUMBER )
        RETURN VARCHAR2;

    FUNCTION fazcampo ( p_i_campo IN DATE
                      , p_i_format IN VARCHAR2
                      , p_i_fill IN VARCHAR2
                      , p_i_size IN NUMBER )
        RETURN VARCHAR2;

    FUNCTION executar ( p_data_fechamento VARCHAR2
                      , p_nome_planilha VARCHAR2
                      , p_concatena_id VARCHAR2 )
        RETURN INTEGER;

    CURSOR c_valida_entrada_cd ( p_i_cod_empresa VARCHAR
                               , p_i_data_fechamento DATE
                               , p_i_nome_arquivo VARCHAR
                               , p_i_concatenacao VARCHAR )
    IS
        SELECT   ddf.cod_empresa
               , ddf.cod_estab
               , esd.cod_estado
               , ddf.data_fiscal
               , ddf.num_controle_docto
               , ddf.num_docfis
               , dim.num_item
               , xcf.cod_cfo
               , xno.cod_natureza_op
               , stb.cod_situacao_b
               , dim.vlr_contab_item
               , dim.vlr_item
               , dim.vlr_base_icms_1
               , dim.vlr_base_icms_2
               , dim.vlr_base_icms_3
               , dim.vlr_base_icms_4
               , dim.vlr_tributo_icmss
               , dim.vlr_outras
            FROM msaf.dwt_docto_fiscal ddf
               , msaf.dwt_itens_merc dim
               , msaf.x04_pessoa_fis_jur pfj
               , msaf.x2013_produto x2p
               , msaf.y2026_sit_trb_uf_b stb
               , msaf.x2012_cod_fiscal xcf
               , msaf.x2006_natureza_op xno
               , msaf.estabelecimento esb
               , msaf.estado esd
               , msafi.dsp_valida_hdr vhd
               , msafi.dsp_valida_ln vln
           WHERE ddf.cod_empresa = p_i_cod_empresa
             AND ddf.cod_estab = vln.cod_uf_estab
             AND ddf.movto_e_s <> '9'
             AND ddf.data_fiscal BETWEEN ADD_MONTHS ( vhd.data_fechamento
                                                    , -1 )
                                     AND LAST_DAY ( ADD_MONTHS ( vhd.data_fechamento
                                                               , -1 ) )
             AND ddf.ident_docto_fiscal = dim.ident_docto_fiscal
             AND dim.ident_docto_fiscal = ddf.ident_docto_fiscal
             AND pfj.ident_fis_jur = ddf.ident_fis_jur
             AND x2p.ident_produto = dim.ident_produto
             AND stb.ident_situacao_b(+) = dim.ident_situacao_b
             AND xcf.ident_cfo(+) = dim.ident_cfo
             AND xno.ident_natureza_op(+) = dim.ident_natureza_op
             AND esb.cod_empresa = ddf.cod_empresa
             AND esb.cod_estab = ddf.cod_estab
             AND esd.ident_estado = esb.ident_estado
             AND vhd.controle_id = vln.controle_id
             ---
             AND vhd.data_fechamento = p_i_data_fechamento
             AND vln.concatenacao = p_i_concatenacao
             AND REPLACE ( REPLACE ( UPPER ( vhd.nome_arquivo )
                                   , '.XLSX'
                                   , '' )
                         , '.XLS'
                         , '' ) = REPLACE ( REPLACE ( UPPER ( p_i_nome_arquivo )
                                                    , '.XLSX'
                                                    , '' )
                                          , '.XLS'
                                          , '' )
             ---
             AND esb.cod_estab = vln.cod_uf_estab
             AND xno.cod_natureza_op = vln.finalidade
             AND xcf.cod_cfo = vln.cfop
             AND stb.cod_situacao_b = vln.cst
             AND SIGN ( dim.vlr_base_icms_1 ) = vln.base_1
             AND SIGN ( dim.vlr_tributo_icms ) = vln.vlr_icms
             AND SIGN ( dim.aliq_tributo_icms ) = vln.aliquota
             AND SIGN ( dim.vlr_base_icms_2 ) = vln.base_2
             AND SIGN ( dim.vlr_base_icms_3 ) = vln.base_3
             AND SIGN ( dim.vlr_base_icms_4 ) = vln.base_4
             AND SIGN ( dim.vlr_contab_item ) = vln.vlr_contabil
             AND SIGN ( dim.vlr_tributo_icmss ) = vln.icms_st
             AND vln.saida_entrada = 'E'
        ORDER BY 2
               , 4;

    CURSOR c_valida_entrada_loja ( p_i_cod_empresa VARCHAR
                                 , p_i_data_fechamento DATE
                                 , p_i_nome_arquivo VARCHAR
                                 , p_i_concatenacao VARCHAR )
    IS
        SELECT   ddf.cod_empresa
               , ddf.cod_estab
               , esd.cod_estado
               , ddf.data_fiscal
               , ddf.num_controle_docto
               , ddf.num_docfis
               , dim.num_item
               , xcf.cod_cfo
               , xno.cod_natureza_op
               , stb.cod_situacao_b
               , dim.vlr_contab_item
               , dim.vlr_item
               , dim.vlr_base_icms_1
               , dim.vlr_base_icms_2
               , dim.vlr_base_icms_3
               , dim.vlr_base_icms_4
               , dim.vlr_tributo_icmss
               , dim.vlr_outras
            FROM msaf.dwt_docto_fiscal ddf
               , msaf.dwt_itens_merc dim
               , msaf.x04_pessoa_fis_jur pfj
               , msaf.x2013_produto x2p
               , msaf.y2026_sit_trb_uf_b stb
               , msaf.x2012_cod_fiscal xcf
               , msaf.x2006_natureza_op xno
               , msaf.estabelecimento esb
               , msaf.estado esd
               , msafi.dsp_valida_hdr vhd
               , msafi.dsp_valida_ln vln
           WHERE ddf.cod_empresa = p_i_cod_empresa
             AND esd.cod_estado = vln.cod_uf_estab
             AND ddf.movto_e_s <> '9'
             AND ddf.data_fiscal BETWEEN ADD_MONTHS ( vhd.data_fechamento
                                                    , -1 )
                                     AND LAST_DAY ( ADD_MONTHS ( vhd.data_fechamento
                                                               , -1 ) )
             AND ddf.ident_docto_fiscal = dim.ident_docto_fiscal
             AND dim.ident_docto_fiscal = ddf.ident_docto_fiscal
             AND pfj.ident_fis_jur = ddf.ident_fis_jur
             AND x2p.ident_produto = dim.ident_produto
             AND stb.ident_situacao_b(+) = dim.ident_situacao_b
             AND xcf.ident_cfo(+) = dim.ident_cfo
             AND xno.ident_natureza_op(+) = dim.ident_natureza_op
             AND esb.cod_empresa = ddf.cod_empresa
             AND esb.cod_estab = ddf.cod_estab
             AND esd.ident_estado = esb.ident_estado
             AND vhd.controle_id = vln.controle_id
             ---
             AND vhd.data_fechamento = p_i_data_fechamento
             AND vln.concatenacao = p_i_concatenacao
             AND REPLACE ( REPLACE ( UPPER ( vhd.nome_arquivo )
                                   , '.XLSX'
                                   , '' )
                         , '.XLS'
                         , '' ) = REPLACE ( REPLACE ( UPPER ( p_i_nome_arquivo )
                                                    , '.XLSX'
                                                    , '' )
                                          , '.XLS'
                                          , '' )
             ---
             AND xno.cod_natureza_op = vln.finalidade
             AND xcf.cod_cfo = vln.cfop
             AND stb.cod_situacao_b = vln.cst
             AND SIGN ( dim.vlr_base_icms_1 ) = vln.base_1
             AND SIGN ( dim.vlr_tributo_icms ) = vln.vlr_icms
             AND SIGN ( dim.aliq_tributo_icms ) = vln.aliquota
             AND SIGN ( dim.vlr_base_icms_2 ) = vln.base_2
             AND SIGN ( dim.vlr_base_icms_3 ) = vln.base_3
             AND SIGN ( dim.vlr_base_icms_4 ) = vln.base_4
             AND SIGN ( dim.vlr_contab_item ) = vln.vlr_contabil
             AND SIGN ( dim.vlr_tributo_icmss ) = vln.icms_st
             AND vln.saida_entrada = 'E'
        ORDER BY 2
               , 4;

    CURSOR c_valida_saida_cd ( p_i_cod_empresa VARCHAR
                             , p_i_data_fechamento DATE
                             , p_i_nome_arquivo VARCHAR
                             , p_i_concatenacao VARCHAR )
    IS
        SELECT   ddf.cod_empresa
               , ddf.cod_estab
               , esd.cod_estado
               , ddf.data_fiscal
               , ddf.num_controle_docto
               , ddf.num_docfis
               , dim.num_item
               , xcf.cod_cfo
               , xno.cod_natureza_op
               , stb.cod_situacao_b
               , dim.vlr_contab_item
               , dim.vlr_item
               , dim.vlr_base_icms_1
               , dim.vlr_base_icms_2
               , dim.vlr_base_icms_3
               , dim.vlr_base_icms_4
               , dim.vlr_tributo_icmss
               , dim.vlr_outras
            FROM msaf.dwt_docto_fiscal ddf
               , msaf.dwt_itens_merc dim
               , msaf.x04_pessoa_fis_jur pfj
               , msaf.x2013_produto x2p
               , msaf.y2026_sit_trb_uf_b stb
               , msaf.x2012_cod_fiscal xcf
               , msaf.x2006_natureza_op xno
               , msaf.estabelecimento esb
               , msaf.estado esd
               , msafi.dsp_valida_hdr vhd
               , msafi.dsp_valida_ln vln
           WHERE ddf.cod_empresa = p_i_cod_empresa
             AND ddf.cod_estab = vln.cod_uf_estab
             AND ddf.movto_e_s = '9'
             AND ddf.data_fiscal BETWEEN ADD_MONTHS ( vhd.data_fechamento
                                                    , -1 )
                                     AND LAST_DAY ( ADD_MONTHS ( vhd.data_fechamento
                                                               , -1 ) )
             AND ddf.ident_docto_fiscal = dim.ident_docto_fiscal
             AND dim.ident_docto_fiscal = ddf.ident_docto_fiscal
             AND pfj.ident_fis_jur = ddf.ident_fis_jur
             AND x2p.ident_produto = dim.ident_produto
             AND stb.ident_situacao_b(+) = dim.ident_situacao_b
             AND xcf.ident_cfo(+) = dim.ident_cfo
             AND xno.ident_natureza_op(+) = dim.ident_natureza_op
             AND esb.cod_empresa = ddf.cod_empresa
             AND esb.cod_estab = ddf.cod_estab
             AND esd.ident_estado = esb.ident_estado
             AND vhd.controle_id = vln.controle_id
             ---
             AND vhd.data_fechamento = p_i_data_fechamento
             AND vln.concatenacao = p_i_concatenacao
             AND REPLACE ( REPLACE ( UPPER ( vhd.nome_arquivo )
                                   , '.XLSX'
                                   , '' )
                         , '.XLS'
                         , '' ) = REPLACE ( REPLACE ( UPPER ( p_i_nome_arquivo )
                                                    , '.XLSX'
                                                    , '' )
                                          , '.XLS'
                                          , '' )
             ---
             AND esb.cod_estab = vln.cod_uf_estab
             AND xno.cod_natureza_op = vln.finalidade
             AND xcf.cod_cfo = vln.cfop
             AND stb.cod_situacao_b = vln.cst
             AND SIGN ( dim.vlr_base_icms_1 ) = vln.base_1
             AND SIGN ( dim.vlr_tributo_icms ) = vln.vlr_icms
             AND SIGN ( dim.aliq_tributo_icms ) = vln.aliquota
             AND SIGN ( dim.vlr_base_icms_2 ) = vln.base_2
             AND SIGN ( dim.vlr_base_icms_3 ) = vln.base_3
             AND SIGN ( dim.vlr_base_icms_4 ) = vln.base_4
             AND SIGN ( dim.vlr_contab_item ) = vln.vlr_contabil
             AND SIGN ( dim.vlr_tributo_icmss ) = vln.icms_st
             AND vln.saida_entrada = 'S'
        ORDER BY 2
               , 4;

    CURSOR c_valida_saida_loja ( p_i_cod_empresa VARCHAR
                               , p_i_data_fechamento DATE
                               , p_i_nome_arquivo VARCHAR
                               , p_i_concatenacao VARCHAR )
    IS
        SELECT   ddf.cod_empresa
               , ddf.cod_estab
               , esd.cod_estado
               , ddf.data_fiscal
               , ddf.num_controle_docto
               , ddf.num_docfis
               , dim.num_item
               , xcf.cod_cfo
               , xno.cod_natureza_op
               , stb.cod_situacao_b
               , dim.vlr_contab_item
               , dim.vlr_item
               , dim.vlr_base_icms_1
               , dim.vlr_base_icms_2
               , dim.vlr_base_icms_3
               , dim.vlr_base_icms_4
               , dim.vlr_tributo_icmss
               , dim.vlr_outras
            FROM msaf.dwt_docto_fiscal ddf
               , msaf.dwt_itens_merc dim
               , msaf.x04_pessoa_fis_jur pfj
               , msaf.x2013_produto x2p
               , msaf.y2026_sit_trb_uf_b stb
               , msaf.x2012_cod_fiscal xcf
               , msaf.x2006_natureza_op xno
               , msaf.estabelecimento esb
               , msaf.estado esd
               , msafi.dsp_valida_hdr vhd
               , msafi.dsp_valida_ln vln
           WHERE ddf.cod_empresa = p_i_cod_empresa
             AND esd.cod_estado = vln.cod_uf_estab
             AND ddf.movto_e_s = '9'
             AND ddf.data_fiscal BETWEEN ADD_MONTHS ( vhd.data_fechamento
                                                    , -1 )
                                     AND LAST_DAY ( ADD_MONTHS ( vhd.data_fechamento
                                                               , -1 ) )
             AND ddf.ident_docto_fiscal = dim.ident_docto_fiscal
             AND dim.ident_docto_fiscal = ddf.ident_docto_fiscal
             AND pfj.ident_fis_jur = ddf.ident_fis_jur
             AND x2p.ident_produto = dim.ident_produto
             AND stb.ident_situacao_b(+) = dim.ident_situacao_b
             AND xcf.ident_cfo(+) = dim.ident_cfo
             AND xno.ident_natureza_op(+) = dim.ident_natureza_op
             AND esb.cod_empresa = ddf.cod_empresa
             AND esb.cod_estab = ddf.cod_estab
             AND esd.ident_estado = esb.ident_estado
             AND vhd.controle_id = vln.controle_id
             ---
             AND vhd.data_fechamento = p_i_data_fechamento
             AND vln.concatenacao = p_i_concatenacao
             AND REPLACE ( REPLACE ( UPPER ( vhd.nome_arquivo )
                                   , '.XLSX'
                                   , '' )
                         , '.XLS'
                         , '' ) = REPLACE ( REPLACE ( UPPER ( p_i_nome_arquivo )
                                                    , '.XLSX'
                                                    , '' )
                                          , '.XLS'
                                          , '' )
             ---
             AND xno.cod_natureza_op = vln.finalidade
             AND xcf.cod_cfo = vln.cfop
             AND stb.cod_situacao_b = vln.cst
             AND SIGN ( dim.vlr_base_icms_1 ) = vln.base_1
             AND SIGN ( dim.vlr_tributo_icms ) = vln.vlr_icms
             AND SIGN ( dim.aliq_tributo_icms ) = vln.aliquota
             AND SIGN ( dim.vlr_base_icms_2 ) = vln.base_2
             AND SIGN ( dim.vlr_base_icms_3 ) = vln.base_3
             AND SIGN ( dim.vlr_base_icms_4 ) = vln.base_4
             AND SIGN ( dim.vlr_contab_item ) = vln.vlr_contabil
             AND SIGN ( dim.vlr_tributo_icmss ) = vln.icms_st
             AND vln.saida_entrada = 'S'
        ORDER BY 2
               , 4;
END dpsp_rel_valida_cproc;
/
SHOW ERRORS;
