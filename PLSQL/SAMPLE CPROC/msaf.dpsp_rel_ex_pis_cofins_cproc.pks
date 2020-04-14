Prompt Package DPSP_REL_EX_PIS_COFINS_CPROC;
--
-- DPSP_REL_EX_PIS_COFINS_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dpsp_rel_ex_pis_cofins_cproc
IS
    -- AUTOR    : DSP - RODOLFO
    -- DATA     : CRIADA EM 29/NOV/2017
    -- DESCRIÇÃO: PROJETO 930

    -- V9 CRIADA EM 12/12/2018: REBELLO - VERSAO ATUAL NA PRD EM 12/12/2018
    -- V10 CRIADA EM 21/01/2019: Lucas Manarte - FIN-1647 - Relatório de Exclusão ICMS da base do PISCOFINS (2008 a 2014)
    -- V11 CRIADA EM 02/09/2019: Lucas Manarte - Ajuste na performance da extração do Relatório analítico.
    -- V12 CRIADA EM 16/09/2019: Lucas Manarte - Ajuste da Trava do Período.
    -- V13 CRIADA EM 21/01/2020: Jorge Oliveira - Ajuste de calculo e melhoria de perfomance - FIN9458

    musuario usuario_empresa.cod_usuario%TYPE;

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

    FUNCTION executar ( p_data_ini DATE
                      , p_data_fim DATE
                      , p_rel VARCHAR2
                      , p_uf VARCHAR2
                      , p_lst_neutra VARCHAR2
                      , p_agr_cfop VARCHAR2
                      , p_lojas lib_proc.vartab )
        RETURN INTEGER;

    CURSOR crs_relatorio ( p_cod_estab VARCHAR2
                         , p_i_data_ini DATE
                         , p_i_data_fim DATE
                         , p_lst_neutra VARCHAR2 )
    IS
        SELECT   ue.cod_empresa
               , ue.cod_estab
               , ue.uf_estab
               , ue.data_fiscal
               , ue.docto AS cod_docto
               , ue.num_docfis
               , ue.serie_docfis
               , ue.num_autentic_nfe
               , ue.cod_produto
               , ue.descr_item AS descricao
               , ue.num_item
               , ue.cod_cfo
               , ue.cod_nbm
               , DECODE ( ue.cod_lista,  'P', 'POSITIVA',  'N', 'NEGATIVA',  'O', 'NEUTRA',  '-' ) lista
               , ue.quantidade
               , ----
                  ( CASE WHEN ue.docto = 'ECF' THEN ue.vlr_contabil ELSE ue.vlr_item END ) AS vlr_item
               , ue.vlr_contabil vlr_contab_item
               , ( CASE WHEN ue.docto = 'ECF' THEN 0 ELSE ue.vlr_outras END ) AS vlr_outras
               , ----
                 ue.vlr_desconto
               , ue.vlr_base_icms
               , ue.aliq_icms
               , ue.vlr_icms
               , ue.cst_pis cod_situacao_pis
               , ue.vlr_base_pis
               , ue.vlr_aliq_pis
               , ue.vlr_pis
               , ue.cst_cofins cod_situacao_cofins
               , ue.vlr_base_cofins
               , ue.vlr_aliq_cofins
               , ue.vlr_cofins
               , --
                 ue.cod_estab_e
               , ue.data_fiscal_e
               , ue.num_docfis_e
               , ue.serie_docfis_e
               , ue.num_controle_docto_e
               , ue.num_autentic_nfe_e
               , ue.num_item_e
               , ue.cod_cfo_e
               , ue.cod_cfo_saida
               , ue.quantidade_e
               , ue.vlr_item_e vlr_item_e
               , ue.vlr_contab_item_e vlr_contab_item_e
               , ue.vlr_outras_e vlr_outras_e
               , ue.vlr_desconto_e vlr_desconto_e
               , ue.vlr_base_icms_e
               , ue.vlr_icms_e
               , ue.vlr_base_icmss_e
               , ue.vlr_icmss_e
               , ue.cst_pis_e cod_situacao_pis_e
               , ue.vlr_base_pis_e vlr_base_pis_e
               , ue.vlr_aliq_pis_e vlr_aliq_pis_e
               , ue.vlr_pis_e vlr_pis_e
               , ue.cst_cofins_e cod_situacao_cofins_e
               , ue.vlr_base_cofins_e vlr_base_cofins_e
               , ue.vlr_aliq_cofins_e vlr_aliq_cofins_e
               , ue.vlr_cofins_e vlr_cofins_e
               , --
                 NVL ( ue.vlr_icmss_n_escrit, 0 ) vlr_icmss_n_escrit
               , NVL ( ue.vlr_icms_unit, 0 ) vlr_icms_unit
               , NVL ( ue.vlr_icms_st_unit, 0 ) vlr_icms_st_unit
               , NVL ( ue.vlr_icms_st_unit_aux, 0 ) vlr_icms_st_unit_aux
               , NVL ( ue.vlr_icms_st_unit_xml, 0 ) AS vlr_icms_st_unit_xml
               , NVL ( ue.vlr_icmsst_ret_unit_xml, 0 ) AS vlr_icms_st_ret_unit_xml
               , NVL ( ue.base_vlr_calculado, 0 ) base_vlr_calculado
               , NVL ( ue.vlr_calculado, 0 ) vlr_calculado
            FROM msaf.dpsp_ex_bpc_uentr ue
           WHERE ue.cod_empresa = msafi.dpsp.empresa
             AND ue.cod_estab = p_cod_estab
             AND ue.data_fiscal BETWEEN p_i_data_ini AND p_i_data_fim
             AND ue.cod_lista = DECODE ( p_lst_neutra, 'S', 'O', ue.cod_lista )
        ORDER BY 1
               , 2
               , 3;

    CURSOR c_sintetico ( p_cod_estab VARCHAR2
                       , p_i_data_ini DATE
                       , p_i_data_fim DATE
                       , p_agr_cfop VARCHAR2
                       , p_lst_neutra VARCHAR2 )
    IS
        SELECT   a.cod_estab
               , a.uf_estab
               , TO_CHAR ( a.data_fiscal
                         , 'mm/yyyy' )
                     data_fiscal
               , ( CASE WHEN p_agr_cfop = 'S' THEN a.cod_cfo ELSE NULL END ) cod_cfo
               , DECODE ( a.cod_lista,  'P', 'POSITIVA',  'N', 'NEGATIVA',  'O', 'NEUTRA',  '-' ) lista
               , SUM ( a.vlr_icms ) AS icms_saida
               , SUM ( a.vlr_icms_unit ) AS icms_unit_ent
               , SUM ( a.vlr_icms_st_unit ) AS vlr_st_unit
               , SUM ( a.vlr_icms_st_unit_aux ) AS vlr_st_unit_aux
               , SUM ( a.vlr_icms_st_unit_xml ) AS vlr_st_unit_xml
               , SUM ( a.vlr_icmsst_ret_unit_xml ) AS vlr_st_unit_ret_xml
               , SUM ( a.base_vlr_calculado ) base_vlr_calculado
               , SUM ( a.vlr_calculado ) vlr_calculado
            FROM msaf.dpsp_ex_bpc_uentr a
           WHERE 1 = 1
             AND a.data_fiscal BETWEEN p_i_data_ini AND p_i_data_fim
             AND a.cod_estab = p_cod_estab
             AND a.cod_empresa = msafi.dpsp.empresa
             AND a.cod_lista = DECODE ( p_lst_neutra, 'S', 'O', a.cod_lista )
        --
        GROUP BY a.cod_estab
               , a.uf_estab
               , TO_CHAR ( a.data_fiscal
                         , 'mm/yyyy' )
               , (CASE WHEN p_agr_cfop = 'S' THEN a.cod_cfo ELSE NULL END)
               , a.cod_lista
        ORDER BY 2
               , 1
               , 3
               , 4;
END dpsp_rel_ex_pis_cofins_cproc;
/
SHOW ERRORS;
