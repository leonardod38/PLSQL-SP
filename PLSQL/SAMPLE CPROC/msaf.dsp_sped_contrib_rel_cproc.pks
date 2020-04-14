Prompt Package DSP_SPED_CONTRIB_REL_CPROC;
--
-- DSP_SPED_CONTRIB_REL_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dsp_sped_contrib_rel_cproc
IS
    -- AUTOR    : DSP - LFM
    -- DATA     : Nov/2013
    -- DESCRIÇÃO: Módulo customizado de relatórios do Sped Contribuições (EFD PIS/COFINS)

    mcod_empresa empresa.cod_empresa%TYPE;
    mcod_estab estabelecimento.cod_estab%TYPE;
    musuario usuario_empresa.cod_usuario%TYPE;

    --Variaveis para as funções REGEXP_LIKE encontrarem DSP9xx, Depósitos, Lojas e Estabelecimentos
    v_proc_9xx VARCHAR2 ( 30 ); --V_PROC_9XX   := '^' || MCOD_EMPRESA || '9[0-9]{2}$';
    v_proc_dep VARCHAR2 ( 30 ); --V_PROC_DEP   := '^' || MCOD_EMPRESA || '9[0-9][1-9]$';
    v_proc_loj VARCHAR2 ( 30 ); --V_PROC_LOJ   := '^' || MCOD_EMPRESA || '[0-8][0-9]{' || TO_CHAR(5-LENGTH(MCOD_EMPRESA),'FM9') || '}$';
    v_proc_est VARCHAR2 ( 30 ); --V_PROC_EST   := '^' || MCOD_EMPRESA || '[0-9]{3,' || TO_CHAR(6-LENGTH(MCOD_EMPRESA),'FM9') || '}$';
    v_proc_estvd VARCHAR2 ( 30 ); --V_PROC_ESTVD := '^VD[0-9]{3,' || TO_CHAR(6-LENGTH(MCOD_EMPRESA),'FM9') || '}$';

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

    FUNCTION executar ( p_relatorio VARCHAR2
                      , p_data_ini DATE
                      , p_data_fim DATE
                      , p_estab_ini VARCHAR2
                      , p_estab_fim VARCHAR2 )
        RETURN INTEGER;

    --------------------------------------------------------------------------------------------------------------
    -- RELATORIO: SELECT ''001'',''001 - Devolução de venda - somente data'' FROM DUAL
    CURSOR c_contrib_rel_001 ( p_i_data_ini IN DATE
                             , p_i_data_fim IN DATE )
    IS
        SELECT capa.cod_estab
             , item.dat_lanc_pis_cofins
             , capa.num_docfis
             , item.num_item
             , item.vlr_contab_item
             , item.vlr_base_pis
             , item.vlr_pis
             , item.vlr_base_cofins
             , item.vlr_cofins
             , item.cod_situacao_cofins
          FROM dwt_docto_fiscal capa
             , dwt_itens_merc item
         WHERE capa.cod_empresa = mcod_empresa
           AND capa.data_fiscal BETWEEN p_i_data_ini AND p_i_data_fim
           AND capa.movto_e_s <> '9'
           AND capa.situacao <> 'S'
           AND item.ident_docto_fiscal = capa.ident_docto_fiscal
           AND item.ident_cfo IN ( SELECT ident_cfo
                                     FROM msaf.x2012_cod_fiscal
                                    WHERE cod_cfo IN ( '1202'
                                                     , '1411'
                                                     , '2202'
                                                     , '2411' ) );

    --------------------------------------------------------------------------------------------------------------
    -- RELATORIO: UNION SELECT ''002'',''002 - Compras - somente data'' FROM DUAL
    CURSOR c_contrib_rel_002 ( p_i_data_ini IN DATE
                             , p_i_data_fim IN DATE )
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
          FROM dwt_docto_fiscal x07
             , dwt_itens_merc x08
             , x2013_produto x2013
         WHERE x07.cod_empresa = mcod_empresa
           AND x07.data_fiscal BETWEEN p_i_data_ini AND p_i_data_fim
           AND x07.movto_e_s <> '9'
           AND x08.ident_docto_fiscal = x07.ident_docto_fiscal
           AND x08.cod_situacao_cofins = '50'
           AND x08.ident_cfo IN ( SELECT ident_cfo
                                    FROM msaf.x2012_cod_fiscal
                                   WHERE cod_cfo IN ( '1102'
                                                    , '2102'
                                                    , '1403'
                                                    , '2403' ) )
           AND x2013.ident_produto = x08.ident_produto;

    --------------------------------------------------------------------------------------------------------------
    -- RELATORIO: UNION SELECT ''003'',''003 - Energia Elétrica - somente data'' FROM DUAL
    CURSOR c_contrib_rel_003 ( p_i_data_ini IN DATE
                             , p_i_data_fim IN DATE )
    IS
        SELECT capa.cod_estab
             , capa.dat_lanc_pis_cofins capa_dat_lanc_pis_cofins
             , item.dat_lanc_pis_cofins item_dat_lanc_pis_cofins
             , capa.data_fiscal
             , capa.num_docfis
             , item.num_item
             , item.vlr_contab_item
             , item.vlr_base_pis
             , item.vlr_pis
             , item.vlr_base_cofins
             , item.vlr_cofins
          FROM dwt_docto_fiscal capa
             , dwt_itens_merc item
         WHERE capa.cod_empresa = mcod_empresa
           AND capa.data_fiscal BETWEEN p_i_data_ini AND p_i_data_fim
           AND capa.movto_e_s <> '9'
           AND item.ident_docto_fiscal = capa.ident_docto_fiscal
           AND item.ident_cfo IN ( SELECT ident_cfo
                                     FROM msaf.x2012_cod_fiscal
                                    WHERE cod_cfo IN ( '1253'
                                                     , '2253' ) );

    --------------------------------------------------------------------------------------------------------------
    -- RELATORIO: UNION SELECT ''004'',''004 - Faturamento - somente data'' FROM DUAL
    CURSOR c_contrib_rel_004 ( p_i_estab_ini IN VARCHAR2
                             , p_i_estab_fim IN VARCHAR2
                             , p_i_data_ini IN DATE
                             , p_i_data_fim IN DATE )
    IS
        SELECT   cod_estab cod_estab
               , data_emissao data_emissao
               , SUM ( vlr_tot_liq ) vlr_item
               , cod_sit_trib_pis cod_sit_trib_pis
               , SUM ( vlr_base_pis ) vlr_base_pis
               , aliq_pis vlr_aliq_pis
               , SUM ( vlr_pis ) vlr_pis
               , cod_sit_trib_cofins cod_sit_trib_cofins
               , SUM ( vlr_base_cofins ) vlr_base_cofins
               , aliq_cofins vlr_aliq_cofins
               , SUM ( vlr_cofins ) vlr_cofins
            FROM (SELECT /*+STAR(ITEM)*/
                        item.cod_estab cod_estab
                         , item.data_fiscal data_emissao
                         , SUM ( item.vlr_contab_item ) vlr_tot_liq
                         , item.cod_situacao_pis || ' ' cod_sit_trib_pis
                         , SUM ( item.vlr_base_pis ) vlr_base_pis
                         , item.vlr_aliq_pis aliq_pis
                         , SUM ( item.vlr_pis ) vlr_pis
                         , item.cod_situacao_cofins || ' ' cod_sit_trib_cofins
                         , SUM ( item.vlr_base_cofins ) vlr_base_cofins
                         , item.vlr_aliq_cofins aliq_cofins
                         , SUM ( item.vlr_cofins ) vlr_cofins
                      FROM msaf.dwt_itens_merc item
                         , msaf.dwt_docto_fiscal doc
                     WHERE item.cod_empresa = mcod_empresa
                       AND item.cod_estab BETWEEN p_i_estab_ini AND p_i_estab_fim
                       AND item.data_fiscal BETWEEN p_i_data_ini AND p_i_data_fim
                       AND item.ident_docto IN ( SELECT ident_docto
                                                   FROM msaf.x2005_tipo_docto
                                                  WHERE cod_docto IN ( 'CF-E'
                                                                     , 'SAT' ) )
                       AND item.ident_docto_fiscal = doc.ident_docto_fiscal
                       AND doc.situacao <> 'S'
                  GROUP BY item.cod_estab
                         , item.data_fiscal
                         , item.cod_situacao_cofins
                         , item.cod_situacao_pis
                         , item.vlr_aliq_pis
                         , item.vlr_aliq_cofins
                  UNION ALL
                  SELECT /*+STAR(X994)*/
                        x993.cod_estab cod_estab
                         , x993.data_emissao data_emissao
                         , SUM ( x994.vlr_liq_item ) vlr_tot_liq
                         , x994.cod_sit_trib_pis || ' ' cod_sit_trib_pis
                         , SUM ( x994.vlr_base_pis ) vlr_base_pis
                         , x994.vlr_aliq_pis aliq_pis
                         , SUM ( x994.vlr_pis ) vlr_pis
                         , x994.cod_sit_trib_cofins || ' ' cod_sit_trib_cofins
                         , SUM ( x994.vlr_base_cofins ) vlr_base_cofins
                         , x994.vlr_aliq_cofins aliq_cofins
                         , SUM ( x994.vlr_cofins ) vlr_cofins
                      FROM msaf.x993_capa_cupom_ecf x993
                         , msaf.x994_item_cupom_ecf x994
                         , msaf.x2087_equipamento_ecf x2087
                         , msaf.x2013_produto x2013
                         , msaf.x2012_cod_fiscal x2012
                     WHERE x994.cod_empresa = mcod_empresa
                       AND x994.cod_estab BETWEEN p_i_estab_ini AND p_i_estab_fim
                       AND x994.data_emissao BETWEEN p_i_data_ini AND p_i_data_fim
                       AND x994.ind_situacao_item = '1'
                       AND x993.ind_situacao_cupom = '1'
                       AND x2087.cod_empresa = x993.cod_empresa
                       AND x2087.cod_estab = x993.cod_estab
                       AND x2087.ident_caixa_ecf = x993.ident_caixa_ecf
                       AND x994.cod_empresa = x993.cod_empresa
                       AND x994.cod_estab = x993.cod_estab
                       AND x994.ident_caixa_ecf = x993.ident_caixa_ecf
                       AND x994.num_coo = x993.num_coo
                       AND x994.data_emissao = x993.data_emissao
                       AND x2013.ident_produto = x994.ident_produto
                       AND x2012.ident_cfo = x994.ident_cfo
                  GROUP BY x993.cod_estab
                         , x993.data_emissao
                         , x994.cod_sit_trib_pis
                         , x994.cod_sit_trib_cofins
                         , x994.vlr_aliq_pis
                         , x994.vlr_aliq_cofins
                  UNION ALL
                  SELECT /*+STAR(ITEM)*/
                        item.cod_estab cod_estab
                         , item.data_fiscal data_emissao
                         , SUM ( item.vlr_contab_item ) vlr_tot_liq
                         , item.cod_situacao_pis || ' ' cod_sit_trib_pis
                         , SUM ( item.vlr_base_pis ) vlr_base_pis
                         , item.vlr_aliq_pis aliq_pis
                         , SUM ( item.vlr_pis ) vlr_pis
                         , item.cod_situacao_cofins || ' ' cod_sit_trib_cofins
                         , SUM ( item.vlr_base_cofins ) vlr_base_cofins
                         , item.vlr_aliq_cofins aliq_cofins
                         , SUM ( item.vlr_cofins ) vlr_cofins
                      FROM msaf.dwt_itens_merc item
                         , msaf.dwt_docto_fiscal doc
                     WHERE item.cod_empresa = mcod_empresa
                       AND item.cod_estab BETWEEN p_i_estab_ini AND p_i_estab_fim
                       AND item.data_fiscal BETWEEN p_i_data_ini AND p_i_data_fim
                       AND item.ident_cfo IN ( SELECT ident_cfo
                                                 FROM msaf.x2012_cod_fiscal
                                                WHERE cod_cfo IN ( '5102'
                                                                 , '5405' ) )
                       AND doc.ident_modelo IN ( SELECT ident_modelo
                                                   FROM msaf.x2024_modelo_docto x
                                                  WHERE x.cod_modelo = '55' )
                       AND item.ident_docto_fiscal = doc.ident_docto_fiscal
                       AND doc.situacao <> 'S'
                  GROUP BY item.cod_estab
                         , item.data_fiscal
                         , item.cod_situacao_cofins
                         , item.cod_situacao_pis
                         , item.vlr_aliq_pis
                         , item.vlr_aliq_cofins)
        GROUP BY cod_estab
               , data_emissao
               , cod_sit_trib_pis
               , aliq_pis
               , cod_sit_trib_cofins
               , aliq_cofins;

    --------------------------------------------------------------------------------------------------------------
    -- RELATORIO: UNION SELECT ''005'',''005 - Movimentação por CFOP - data e estabelecimento'' FROM DUAL
    CURSOR c_contrib_rel_005 ( p_i_estab_ini IN VARCHAR2
                             , p_i_estab_fim IN VARCHAR2
                             , p_i_data_ini IN DATE
                             , p_i_data_fim IN DATE )
    IS
        SELECT   ddf.cod_estab
               , ddf.data_fiscal
               , ddf.num_docfis
               , x04.cod_fis_jur
               , xcf.cod_cfo
               , SUM ( dim.vlr_contab_item ) vlr_contab_item
               , SUM ( dim.vlr_tributo_icms ) vlr_tributo_icms
            FROM dwt_docto_fiscal ddf
               , dwt_itens_merc dim
               , x2012_cod_fiscal xcf
               , x04_pessoa_fis_jur x04
           WHERE ddf.cod_empresa = mcod_empresa
             AND ddf.cod_estab BETWEEN p_i_estab_ini AND p_i_estab_fim
             AND ddf.data_fiscal BETWEEN p_i_data_ini AND p_i_data_fim
             AND ddf.serie_docfis <> 'ECF'
             AND ddf.situacao <> 'S'
             AND dim.ident_docto_fiscal = ddf.ident_docto_fiscal
             AND xcf.ident_cfo = dim.ident_cfo
             AND x04.ident_fis_jur = ddf.ident_fis_jur
        GROUP BY ddf.cod_estab
               , ddf.data_fiscal
               , ddf.num_docfis
               , x04.cod_fis_jur
               , xcf.cod_cfo
        ORDER BY ddf.cod_estab
               , ddf.data_fiscal
               , ddf.num_docfis;

    --------------------------------------------------------------------------------------------------------------
    -- RELATORIO: UNION SELECT ''006'',''006 - Relatório P100 RH - somente data'' FROM DUAL
    CURSOR c_contrib_rel_006 ( p_i_data_ini IN DATE
                             , p_i_data_fim IN DATE )
    IS
        SELECT cod_estab cod_estab
             , data_fim data_fim
             , vlr_rec_brt valor_receita_bruta_total
             , vlr_rec_brt_demais_ativ valor_demais_atividades
             , vlr_rec_brt_ativ valor_receita_bruta_atividade
             , vlr_exc_rec_brt valor_exclusoes_rec_bruta
             , vlr_base_cont_prev base_calculo_ativ
             , vlr_cont_prev valor_contribuicao_prev
             ,   ( SELECT SUM ( vlr_oper_canc_icms ) cancelamento_red_z
                     FROM msaf.x991_capa_reducao_ecf
                    WHERE cod_empresa = x185.cod_empresa
                      AND cod_estab = x185.cod_estab
                      AND data_fiscal BETWEEN p_i_data_ini AND p_i_data_fim )
               + ( SELECT SUM ( vlr_desc_capa ) desconto_ddg
                     FROM msaf.x993_capa_cupom_ecf
                    WHERE cod_empresa = x185.cod_empresa
                      AND cod_estab = x185.cod_estab
                      AND data_emissao BETWEEN p_i_data_ini AND p_i_data_fim )
                   valor_ajuste
          FROM msaf.x185_contrib_prev x185
         WHERE cod_empresa = mcod_empresa
           AND data_ini BETWEEN p_i_data_ini AND p_i_data_fim;

    --------------------------------------------------------------------------------------------------------------
    -- RELATORIO: UNION SELECT ''007'',''007 - Movimentação 147 - somente data'' FROM DUAL
    CURSOR c_contrib_rel_007 ( p_i_data_ini IN DATE
                             , p_i_data_fim IN DATE )
    IS
        SELECT   x147.cod_estab
               , x2002.cod_conta
               , SUM ( vlr_oper ) AS vlr_oper
               , SUM ( vlr_base_pis ) AS vlr_base_pis
               , SUM ( vlr_pis ) AS vlr_pis
               , SUM ( vlr_cofins ) AS vlr_cofins
            FROM msaf.x147_oper_cred x147
               , msaf.x2002_plano_contas x2002
           WHERE x147.cod_empresa = mcod_empresa
             AND x147.data_oper BETWEEN p_i_data_ini AND p_i_data_fim
             AND x2002.ident_conta = x147.ident_conta
        GROUP BY x147.cod_estab
               , x2002.cod_conta
        ORDER BY x147.cod_estab
               , x2002.cod_conta;

    --------------------------------------------------------------------------------------------------------------
    -- RELATORIO: UNION SELECT ''008'',''008 - Movimentação 148 - somente data'' FROM DUAL
    CURSOR c_contrib_rel_008 ( p_i_data_ini IN DATE
                             , p_i_data_fim IN DATE )
    IS
        SELECT   x148.cod_estab
               , x2002.cod_conta
               , SUM ( vlr_dep_amort ) AS vlr_dep_amort
               , SUM ( vlr_base_cred_pispasep ) AS vlr_base_cred_pispasep
               , SUM ( vlr_base_pis ) AS vlr_base_pis
               , SUM ( vlr_pis ) AS vlr_pis
               , SUM ( vlr_cofins ) AS vlr_cofins
            FROM msaf.x148_bens_ativo_imob x148
               , msaf.x2002_plano_contas x2002
           WHERE x148.cod_empresa = mcod_empresa
             AND x148.data_lancto BETWEEN p_i_data_ini AND p_i_data_fim
             AND x2002.ident_conta = x148.ident_conta
        GROUP BY x148.cod_estab
               , x2002.cod_conta
        ORDER BY x148.cod_estab
               , x2002.cod_conta;

    --------------------------------------------------------------------------------------------------------------
    -- RELATORIO: UNION SELECT ''009'',''009 - Relatório de Transferências'' FROM DUAL
    CURSOR c_contrib_rel_009 ( p_i_estab_ini IN VARCHAR2
                             , p_i_estab_fim IN VARCHAR2
                             , p_i_data_ini IN DATE
                             , p_i_data_fim IN DATE )
    IS
        SELECT   a.cod_estab estabelecimento
               , a.data_fiscal data_fiscal
               , a.num_docfis documento_fiscal
               , d.cod_produto codigo_do_item
               , c.cod_cfo cfop
               , SUM ( b.vlr_contab_item ) valor_contabil
               , SUM ( b.vlr_base_icms_1 ) base_tributada
               , SUM ( b.vlr_tributo_icms ) valor_tributo
               , SUM ( b.vlr_base_icms_2 ) base_isenta
               , SUM ( b.vlr_base_icms_3 ) base_outras
            FROM msaf.dwt_docto_fiscal a
               , msaf.dwt_itens_merc b
               , msaf.x2012_cod_fiscal c
               , msaf.x2013_produto d
           WHERE a.ident_docto_fiscal = b.ident_docto_fiscal
             AND b.ident_cfo = c.ident_cfo
             AND b.ident_produto = d.ident_produto
             AND a.cod_empresa = mcod_empresa
             ---AND   A.MOVTO_E_S          = '9'
             AND a.situacao <> 'S'
             AND a.cod_estab BETWEEN p_i_estab_ini AND p_i_estab_fim
             AND a.data_fiscal BETWEEN p_i_data_ini AND p_i_data_fim
             AND c.cod_cfo IN ( '5152'
                              , '6152'
                              , '5409'
                              , '6409'
                              , '5209'
                              , '6209'
                              , '1152'
                              , '2152'
                              , '1409'
                              , '2409'
                              , '1209'
                              , '2209' )
        GROUP BY a.cod_estab
               , a.data_fiscal
               , a.num_docfis
               , d.cod_produto
               , c.cod_cfo;
--------------------------------------------------------------------------------------------------------------

END dsp_sped_contrib_rel_cproc;
/
SHOW ERRORS;
