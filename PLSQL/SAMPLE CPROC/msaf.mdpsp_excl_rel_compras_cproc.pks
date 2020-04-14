Prompt Package MDPSP_EXCL_REL_COMPRAS_CPROC;
--
-- MDPSP_EXCL_REL_COMPRAS_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE mdpsp_excl_rel_compras_cproc
IS
    -- AUTOR    : ADEJO - TIAGO CERVANTES
    -- DATA     : 21/03/2018
    -- DESCRIÇÃO: Relatorio Compras - CFOPs: 1102, 2102, 1403, 2403

    FUNCTION executar ( p_data_ini DATE
                      , p_data_fim DATE
                      , p_estabs lib_proc.vartab )
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
                      , p_estabs VARCHAR2
                      , p_data_ini DATE
                      , p_data_fim DATE )
    IS
        SELECT x07.cod_estab
             , x07.dat_lanc_pis_cofins
             , x07.num_docfis
             , ( SELECT cod_nbm
                   FROM msaf.x2043_cod_nbm x2043
                  WHERE x2043.ident_nbm = x2013.ident_nbm )
                   nbm
             , x2013.cod_produto
             , SUBSTR ( x2013.descricao
                      , 1
                      , 12 )
                   descricao
             , x08.num_item
             , x08.vlr_contab_item
             , x08.vlr_base_pis
             , x08.vlr_pis
             , x08.vlr_base_cofins
             , x08.vlr_cofins
             , lista.class_pis_dsp
          FROM msaf.dwt_docto_fiscal x07
             , msaf.dwt_itens_merc x08
             , msaf.x2013_produto x2013
             , msafi.ps_atrb_op_eff_dsp lista
         WHERE x07.cod_empresa = p_cod_empresa
           AND x07.data_fiscal BETWEEN TO_DATE ( p_data_ini
                                               , 'DD/MM/YYYY' )
                                   AND TO_DATE ( p_data_fim
                                               , 'DD/MM/YYYY' )
           AND x07.cod_estab = p_estabs
           AND x07.movto_e_s <> '9'
           AND x08.ident_docto_fiscal = x07.ident_docto_fiscal
           AND x08.ident_cfo IN ( SELECT ident_cfo
                                    FROM msaf.x2012_cod_fiscal
                                   WHERE cod_cfo IN ( '1102'
                                                    , '2102'
                                                    , '1403'
                                                    , '2403' ) )
           AND x2013.ident_produto = x08.ident_produto
           AND x2013.cod_produto = lista.inv_item_id
           AND lista.setid = 'GERAL'
           AND lista.effdt = (SELECT MAX ( lista2.effdt )
                                FROM msafi.ps_atrb_op_eff_dsp lista2
                               WHERE lista.setid = lista2.setid
                                 AND lista.inv_item_id = lista2.inv_item_id
                                 AND lista2.effdt <= SYSDATE);
END dpsp_excl_rel_compras_cproc;
/
SHOW ERRORS;
