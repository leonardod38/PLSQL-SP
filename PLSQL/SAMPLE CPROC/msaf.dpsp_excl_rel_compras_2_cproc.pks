Prompt Package DPSP_EXCL_REL_COMPRAS_2_CPROC;
--
-- DPSP_EXCL_REL_COMPRAS_2_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dpsp_excl_rel_compras_2_cproc
IS
    -- AUTOR    : ADEJO - TIAGO CERVANTES
    -- DATA     : 21/03/2018
    -- DESCRIÇÃO: Relatorio Compras - CFOPs: 1102, 2102, 1403, 2403

    FUNCTION executar ( p_data_ini DATE
                      , p_data_fim DATE
                      , p_cod_empresa lib_proc.vartab )
        RETURN NUMBER;

    FUNCTION parametros
        RETURN VARCHAR2;

    FUNCTION nome
        RETURN VARCHAR2;

    FUNCTION descricao
        RETURN VARCHAR2;

    FUNCTION versao
        RETURN VARCHAR2;

    FUNCTION tipo
        RETURN VARCHAR2;

    CURSOR crs_saidas ( p_cod_empresa VARCHAR2
                      , p_data_ini DATE
                      , p_data_fim DATE )
    IS
        SELECT x07.cod_empresa AS empresa
             , x07.cod_estab AS filial
             , x07.dat_lanc_pis_cofins AS dat_lanc_pis_cofins
             , x07.num_docfis AS num_nota
             , x07.num_autentic_nfe AS chave_nfe
             , ( SELECT cod_nbm
                   FROM msaf.x2043_cod_nbm x2043
                  WHERE x2043.ident_nbm = x2013.ident_nbm )
                   AS nbm
             , x2013.cod_produto AS cod_produto
             , SUBSTR ( x2013.descricao
                      , 1
                      , 12 )
                   AS descricao
             , x08.num_item AS num_item
             , x2012.cod_cfo AS cfop
             , x08.vlr_contab_item AS vlr_contab_item
             , x08.vlr_base_pis AS vlr_base_pis
             , x08.vlr_aliq_pis AS aliq_pis
             , x08.vlr_pis AS vlr_pis
             , x08.vlr_base_cofins AS vlr_base_cofins
             , x08.vlr_aliq_cofins AS aliq_cofins
             , x08.vlr_cofins AS vlr_cofins
             , x08.cod_situacao_pis AS cst_pis
             , x08.cod_situacao_cofins AS cst_cofins
             , lista.class_pis_dsp AS class_pis_dsp
          FROM msaf.dwt_docto_fiscal x07
             , msaf.dwt_itens_merc x08
             , msaf.x2013_produto x2013
             , msaf.x2012_cod_fiscal x2012
             , msafi.ps_atrb_op_eff_dsp lista
         WHERE x07.cod_empresa = p_cod_empresa
           AND x07.data_fiscal BETWEEN TO_DATE ( p_data_ini
                                               , 'DD/MM/YYYY' )
                                   AND TO_DATE ( p_data_fim
                                               , 'DD/MM/YYYY' )
           AND x07.movto_e_s <> '9'
           AND x08.ident_docto_fiscal = x07.ident_docto_fiscal
           AND x08.ident_cfo IN ( SELECT ident_cfo
                                    FROM msaf.x2012_cod_fiscal
                                   WHERE cod_cfo IN ( '1102'
                                                    , '2102'
                                                    , '1403'
                                                    , '2403'
                                                    , '1910'
                                                    , '2910'
                                                    , '1202'
                                                    , '2202'
                                                    , '1410'
                                                    , '2410'
                                                    , '1411'
                                                    , '2411'
                                                    , '1253'
                                                    , '1353'
                                                    , '2353' ) )
           AND x2013.ident_produto = x08.ident_produto
           AND x2013.cod_produto = lista.inv_item_id
           AND x08.ident_cfo = x2012.ident_cfo
           AND lista.setid = 'GERAL'
           AND lista.effdt = (SELECT MAX ( lista2.effdt )
                                FROM msafi.ps_atrb_op_eff_dsp lista2
                               WHERE lista.setid = lista2.setid
                                 AND lista.inv_item_id = lista2.inv_item_id
                                 AND lista2.effdt <= SYSDATE);
END dpsp_excl_rel_compras_2_cproc;
/
SHOW ERRORS;
