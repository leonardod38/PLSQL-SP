Prompt Package DSP_RELATORIOS_02_CPROC;
--
-- DSP_RELATORIOS_02_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dsp_relatorios_02_cproc
IS
    -- AUTOR       : DSP - LFM
    -- DATA        : 20/Fev/2013 -- criação
    -- MOTIVO REV  : Inclusão dos Campos ICMS ST e IPI no relatório NFS por Célula
    -- DESCRIÇÃO   : Executador de relatórios por data

    mcod_empresa empresa.cod_empresa%TYPE;
    mcod_estab estabelecimento.cod_estab%TYPE;
    musuario usuario_empresa.cod_usuario%TYPE;

    --Variaveis (aqui nao podem ser constantes) para as funções REGEXP_LIKE encontrarem DSP9xx, Depósitos, Lojas e Estabelecimentos
    c_proc_9xx VARCHAR2 ( 30 ); --C_PROC_9XX   := '^' || MCOD_EMPRESA || '9[0-9]{2}$';
    c_proc_dep VARCHAR2 ( 30 ); --C_PROC_DEP   := '^' || MCOD_EMPRESA || '9[0-9][1-9]$';
    c_proc_loj VARCHAR2 ( 30 ); --C_PROC_LOJ   := '^' || MCOD_EMPRESA || '[0-8][0-9]{' || TO_CHAR(5-LENGTH(MCOD_EMPRESA),'FM9') || '}$';
    c_proc_est VARCHAR2 ( 30 ); --C_PROC_EST   := '^' || MCOD_EMPRESA || '[0-9]{3,' || TO_CHAR(6-LENGTH(MCOD_EMPRESA),'FM9') || '}$';
    c_proc_estvd VARCHAR2 ( 30 ); --C_PROC_ESTVD := '^VD[0-9]{3,' || TO_CHAR(6-LENGTH(MCOD_EMPRESA),'FM9') || '}$';

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

    PROCEDURE loga ( p_i_texto IN VARCHAR2
                   , p_i_dttm IN BOOLEAN DEFAULT TRUE );

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

    FUNCTION executar ( p_relatorio VARCHAR2
                      , p_data_ini DATE
                      , p_data_fim DATE )
        RETURN INTEGER;

    CURSOR c_estabs
    IS
        SELECT   cod_estab
               , TO_NUMBER ( REPLACE ( cod_estab
                                     , mcod_empresa
                                     , '' ) )
                     AS codigo_loja
            FROM msafi.dsp_proc_estabs
        ORDER BY 1;

    CURSOR c_datas ( p_data_ini DATE
                   , p_data_fim DATE )
    IS
        SELECT     p_data_ini + ROWNUM - 1 AS data_normal
                 , TO_CHAR ( ( p_data_ini + ROWNUM - 1 )
                           , 'YYYYMMDD' )
                       AS data_safx
              FROM DUAL
        CONNECT BY LEVEL <= ( p_data_fim - p_data_ini ) + 1
          ORDER BY 1;

    --------------------------------------------------------------------------------------------------------------
    -- RELATORIO: UNION SELECT ''002'',''002 - Quebra Sequencia Entrada Lojas'' FROM DUAL
    CURSOR c_relatorio_02_002 ( p_i_data_ini IN DATE
                              , p_i_data_fim IN DATE )
    IS
        SELECT   t.*
               , CASE
                     WHEN EXISTS
                              (SELECT 1
                                 FROM msaf.dwt_docto_fiscal ddf
                                    , msaf.x04_pessoa_fis_jur x04
                                WHERE ddf.cod_empresa = mcod_empresa
                                  AND ddf.cod_estab NOT LIKE mcod_empresa || '9%'
                                  AND ddf.data_fiscal BETWEEN p_i_data_ini AND p_i_data_fim
                                  AND ddf.movto_e_s <> 9
                                  AND ddf.serie_docfis = '2'
                                  AND x04.ident_fis_jur = ddf.ident_fis_jur
                                  AND x04.cod_fis_jur = ddf.cod_estab
                                  AND ddf.cod_estab = t.cod_estab
                                  AND ddf.num_docfis = t.nf_faltante) THEN
                         'S'
                     ELSE
                         'NAO'
                 END
                     AS existe_nf_no_periodo
            FROM (SELECT a.cod_estab
                       , a.data_fiscal
                       , a.num_docfis
                       , b.data_fiscal proxima_nf_dt
                       , b.num_docfis proxima_nf_num
                       , LPAD ( a.num_docfis + 1
                              , 9
                              , '0' )
                             AS nf_faltante
                    FROM (SELECT ROWNUM rn
                               , x.*
                            FROM (SELECT   ddf.cod_estab
                                         , ddf.data_fiscal
                                         , ddf.num_docfis
                                         , ddf.serie_docfis
                                      FROM msaf.dwt_docto_fiscal ddf
                                         , msaf.x04_pessoa_fis_jur x04
                                     WHERE ddf.cod_empresa = mcod_empresa
                                       AND ddf.cod_estab NOT LIKE mcod_empresa || '9%'
                                       AND ddf.data_fiscal BETWEEN p_i_data_ini AND p_i_data_fim
                                       AND ddf.movto_e_s <> 9
                                       AND ddf.serie_docfis = '2'
                                       AND x04.ident_fis_jur = ddf.ident_fis_jur
                                       AND x04.cod_fis_jur = ddf.cod_estab
                                  ORDER BY ddf.cod_estab
                                         , ddf.data_fiscal
                                         , ddf.num_docfis) x) a
                       , (SELECT ROWNUM rn
                               , x.*
                            FROM (SELECT   ddf.cod_estab
                                         , ddf.data_fiscal
                                         , ddf.num_docfis
                                         , ddf.serie_docfis
                                      FROM msaf.dwt_docto_fiscal ddf
                                         , msaf.x04_pessoa_fis_jur x04
                                     WHERE ddf.cod_empresa = mcod_empresa
                                       AND ddf.cod_estab NOT LIKE mcod_empresa || '9%'
                                       AND ddf.data_fiscal BETWEEN p_i_data_ini AND p_i_data_fim
                                       AND ddf.movto_e_s <> 9
                                       AND ddf.serie_docfis = '2'
                                       AND x04.ident_fis_jur = ddf.ident_fis_jur
                                       AND x04.cod_fis_jur = ddf.cod_estab
                                  ORDER BY ddf.cod_estab
                                         , ddf.data_fiscal
                                         , ddf.num_docfis) x) b
                   WHERE a.cod_estab = b.cod_estab
                     AND a.rn = b.rn - 1
                     AND a.num_docfis <> b.num_docfis - 1) t
        ORDER BY cod_estab
               , num_docfis;

    --------------------------------------------------------------------------------------------------------------
    -- RELATORIO: UNION SELECT ''003'',''003 - Conferência NFs da Célula'' FROM DUAL
    CURSOR c_relatorio_02_003 ( p_i_data_ini IN DATE
                              , p_i_data_fim IN DATE )
    IS
        SELECT   a.cod_estab
               , est.cgc cnpj
               , h.cod_estado uf_estab
               , a.data_fiscal
               , a.data_emissao
               , a.num_docfis
               , a.num_controle_docto
               , '''' || a.num_autentic_nfe chave_acesso_ok
               , a.serie_docfis
               , a.sub_serie_docfis
               , f.cod_fis_jur
               , i.cod_estado uf_x04
               , f.cpf_cgc
               , c.cod_docto modelo_docto
               , d.cod_modelo modelo_de_nf
               , e.cod_cfo cfop
               , j.cod_situacao_b cst
               , l.cod_natureza_op cod_nat_operacao
               , SUM ( b.vlr_unit ) valor_unitario
               , SUM ( b.vlr_contab_item ) valor_contabil
               , SUM ( b.vlr_base_icms_1 ) base_tributada
               , b.aliq_tributo_icms aliquota_icms
               , SUM ( b.vlr_tributo_icms ) valor_icms
               , SUM ( b.vlr_base_icms_2 ) base_isenta
               , SUM ( b.vlr_base_icms_3 ) base_outras
               , SUM ( b.vlr_base_icms_4 ) base_reducao
               , SUM ( b.vlr_tributo_icmss ) valor_icms_st
               , SUM ( b.vlr_tributo_ipi ) valor_ipi
               , SUBSTR ( a.usuario
                        , 1
                        , 12 )
                     usuario
               , b.obs_tributo_icms
               , a.obs_dados_fatura usuario_people
            FROM msaf.dwt_docto_fiscal a
               , msaf.estabelecimento est
               , msaf.dwt_itens_merc b
               , msaf.x2005_tipo_docto c
               , msaf.x2024_modelo_docto d
               , msaf.x2012_cod_fiscal e
               , msaf.x04_pessoa_fis_jur f
               , msaf.estabelecimento g
               , msaf.estado h
               , msaf.estado i
               , msaf.y2026_sit_trb_uf_b j
               , msaf.x2006_natureza_op l
           WHERE a.ident_docto_fiscal = b.ident_docto_fiscal
             AND b.ident_docto = c.ident_docto(+)
             AND a.ident_modelo = d.ident_modelo(+)
             AND b.ident_cfo = e.ident_cfo(+)
             AND a.ident_fis_jur = f.ident_fis_jur(+)
             AND a.cod_estab = g.cod_estab(+)
             AND g.ident_estado = h.ident_estado(+)
             AND f.ident_estado = i.ident_estado(+)
             AND b.ident_situacao_b = j.ident_situacao_b(+)
             AND b.ident_natureza_op = l.ident_natureza_op(+)
             AND a.cod_estab = est.cod_estab
             AND a.cod_empresa = mcod_empresa
             AND a.data_fiscal BETWEEN p_i_data_ini AND p_i_data_fim
             AND a.num_controle_docto LIKE 'C%'
        GROUP BY a.cod_estab
               , est.cgc
               , h.cod_estado
               , a.data_fiscal
               , a.data_emissao
               , a.num_docfis
               , a.num_controle_docto
               , a.num_autentic_nfe
               , a.serie_docfis
               , a.sub_serie_docfis
               , a.usuario
               , f.cod_fis_jur
               , i.cod_estado
               , f.cpf_cgc
               , c.cod_docto
               , d.cod_modelo
               , e.cod_cfo
               , j.cod_situacao_b
               , l.cod_natureza_op
               , b.obs_tributo_icms
               , b.aliq_tributo_icms
               , a.obs_dados_fatura
        ORDER BY a.cod_estab
               , a.data_fiscal
               , a.num_docfis;

    --------------------------------------------------------------------------------------------------------------
    -- RELATORIO: UNION SELECT ''004'',''004 - Notas Fiscais de Entrada Duplicadas'' FROM DUAL
    CURSOR c_relatorio_02_004 ( p_i_data_ini IN DATE
                              , p_i_data_fim IN DATE )
    IS
        SELECT a.cod_estab
             , b.cod_estab AS cod_estab_b
             , a.num_docfis
             , a.serie_docfis
             , x04a.cpf_cgc
             , a.data_fiscal data_fiscal_a
             , x04a.cod_fis_jur cod_fis_jur_a
             , SUBSTR ( x04a.razao_social
                      , 1
                      , 14 )
                   razao_social_a
             , a.vlr_tot_nota vlr_tot_nota_a
             , b.data_fiscal data_fiscal_b
             , x04b.cod_fis_jur cod_fis_jur_b
             , SUBSTR ( x04b.razao_social
                      , 1
                      , 14 )
                   razao_social_b
             , b.vlr_tot_nota vlr_tot_nota_b
             , a.ident_docto_fiscal ident_docto_fiscal_a
             , b.ident_docto_fiscal ident_docto_fiscal_b
             , a.num_autentic_nfe chave_acesso_a
          FROM dwt_docto_fiscal a
             , x04_pessoa_fis_jur x04a
             , dwt_docto_fiscal b
             , x04_pessoa_fis_jur x04b
         WHERE a.cod_empresa = mcod_empresa
           AND a.data_fiscal BETWEEN p_i_data_ini AND p_i_data_fim
           AND a.movto_e_s <> '9'
           AND b.movto_e_s <> '9'
           AND a.cod_class_doc_fis = '1'
           AND b.cod_class_doc_fis = '1'
           AND x04a.ident_fis_jur = a.ident_fis_jur
           AND x04b.ident_fis_jur = b.ident_fis_jur
           AND x04a.cpf_cgc = x04b.cpf_cgc
           AND b.cod_empresa = a.cod_empresa
           AND b.num_docfis = a.num_docfis
           AND b.serie_docfis = a.serie_docfis
           AND b.num_autentic_nfe = a.num_autentic_nfe
           AND b.ident_docto_fiscal <> a.ident_docto_fiscal;

    --------------------------------------------------------------------------------------------------------------
    -- RELATORIO: UNION SELECT ''005'',''005 - Relação de Itens para PROTEG-GO'' FROM DUAL
    CURSOR c_relatorio_02_005 ( p_i_data_ini IN DATE
                              , p_i_data_fim IN DATE )
    IS
        SELECT   estab.cod_estab cod_estab
               , dh.codigo_loja codigo_loja
               , TO_DATE ( dh.data_transacao
                         , 'YYYYMMDD' )
                     data_transacao
               , dh.numero_componente numero_componente
               , dh.numero_cupom numero_cupom
               , dh.codigo_produto codigo_produto
               , pro.cod_produto cod_produto
               , pro.descricao descricao_produto
               , ncm.cod_nbm cod_nbm
               , ncm.descricao descricao_nbm
               , dh.cod_tributacao cod_tributacao
               , SUM ( dh.valor_total_produto ) valor_total_produto
               , SUM ( dh.valor_desconto ) valor_desconto
               , SUM ( dh.valor_icms ) valor_icms
            FROM msafi.p2k_item_transacao dh
               , msaf.x2013_produto pro
               , msaf.x2043_cod_nbm ncm
               , msafi.estabelecimento estab
               , msafi.dsp_estabelecimento estab2
               , msafi.estado uf
           WHERE dh.codigo_loja = estab2.codigo_loja
             AND estab.ident_estado = uf.ident_estado
             AND estab.cod_empresa = estab2.cod_empresa
             AND estab.cod_estab = estab2.cod_estab
             AND uf.cod_estado = 'GO'
             AND TO_CHAR ( TO_DATE ( data_transacao
                                   , 'YYYYMMDD' )
                         , 'DD/MM/YYYY' ) BETWEEN p_i_data_ini
                                              AND p_i_data_fim
             AND dh.codigo_produto = pro.cod_produto
             AND pro.valid_produto = (SELECT MAX ( pro2.valid_produto )
                                        FROM msaf.x2013_produto pro2
                                       WHERE pro2.cod_produto = pro.cod_produto
                                         AND pro2.valid_produto <= TO_DATE ( dh.data_transacao
                                                                           , 'YYYYMMDD' ))
             AND pro.ident_nbm = ncm.ident_nbm
             AND ( ncm.cod_nbm LIKE '3301%'
               OR ncm.cod_nbm LIKE '3302%'
               OR ncm.cod_nbm LIKE '3303%'
               OR ncm.cod_nbm LIKE '3304%'
               OR ncm.cod_nbm LIKE '3305%'
               OR ncm.cod_nbm LIKE '3306%'
               OR ncm.cod_nbm LIKE '3307%' )
        GROUP BY estab.cod_estab
               , dh.codigo_loja
               , dh.data_transacao
               , dh.numero_componente
               , dh.numero_cupom
               , dh.codigo_produto
               , pro.cod_produto
               , pro.descricao
               , ncm.cod_nbm
               , ncm.descricao
               , dh.cod_tributacao;

    --------------------------------------------------------------------------------------------------------------
    -- RELATORIO: UNION SELECT ''006'',''006 - Conferência de Vendas DSP x DP'' FROM DUAL
    CURSOR c_relatorio_02_006 ( p_i_data_ini IN DATE
                              , p_i_data_fim IN DATE )
    IS
        SELECT   capa.cod_empresa cod_empresa
               , capa.cod_estab cod_estab
               , capa.movto_e_s movto_e_s
               , capa.num_docfis num_docfis
               , capa.serie_docfis serie_docfis
               , capa.num_controle_docto id_people
               , capa.data_fiscal data_fiscal
               , capa.situacao situacao
               , capa.num_autentic_nfe num_autentic_nfe
               , cfo.cod_cfo cod_cfo
               , cst.cod_situacao_b cod_situacao_b
               , fin.cod_natureza_op cod_natureza_op
               , SUM ( item.vlr_contab_item ) vlr_contab_item
               , SUM ( item.vlr_base_icms_1 ) base_tributada
               , SUM ( item.aliq_tributo_icms ) aliq_icms
               , SUM ( item.vlr_tributo_icms ) valor_icms
               , SUM ( item.vlr_base_icms_2 ) isenta
               , SUM ( item.vlr_base_icms_3 ) outras
               , SUM ( item.vlr_base_icms_4 ) reducao
            FROM msaf.dwt_docto_fiscal capa
               , msaf.dwt_itens_merc item
               , msaf.x2012_cod_fiscal cfo
               , msaf.y2026_sit_trb_uf_b cst
               , msaf.x2006_natureza_op fin
               , msaf.x04_pessoa_fis_jur forn
           WHERE capa.ident_docto_fiscal = item.ident_docto_fiscal
             AND item.ident_cfo = cfo.ident_cfo
             AND item.ident_situacao_b = cst.ident_situacao_b
             AND item.ident_natureza_op = fin.ident_natureza_op
             AND capa.ident_fis_jur = forn.ident_fis_jur
             AND capa.cod_empresa = mcod_empresa
             AND capa.movto_e_s = '9'
             AND capa.situacao <> 'S'
             AND capa.data_fiscal BETWEEN p_i_data_ini AND p_i_data_fim
             AND forn.cpf_cgc LIKE '334382500%'
        GROUP BY capa.cod_empresa
               , capa.cod_estab
               , capa.movto_e_s
               , capa.num_docfis
               , capa.serie_docfis
               , capa.num_controle_docto
               , capa.data_fiscal
               , capa.situacao
               , capa.num_autentic_nfe
               , cfo.cod_cfo
               , cst.cod_situacao_b
               , fin.cod_natureza_op;

    --------------------------------------------------------------------------------------------------------------
    -- RELATORIO: UNION SELECT ''007'',''007 - Conferência de Vendas DP x DSP'' FROM DUAL
    CURSOR c_relatorio_02_007 ( p_i_data_ini IN DATE
                              , p_i_data_fim IN DATE )
    IS
        SELECT   capa.cod_empresa cod_empresa
               , capa.cod_estab cod_estab
               , capa.movto_e_s movto_e_s
               , capa.num_docfis num_docfis
               , capa.serie_docfis serie_docfis
               , capa.num_controle_docto id_people
               , capa.data_fiscal data_fiscal
               , capa.situacao situacao
               , capa.num_autentic_nfe num_autentic_nfe
               , cfo.cod_cfo cod_cfo
               , cst.cod_situacao_b cod_situacao_b
               , fin.cod_natureza_op cod_natureza_op
               , SUM ( item.vlr_contab_item ) vlr_contab_item
               , SUM ( item.vlr_base_icms_1 ) base_tributada
               , SUM ( item.aliq_tributo_icms ) aliq_icms
               , SUM ( item.vlr_tributo_icms ) valor_icms
               , SUM ( item.vlr_base_icms_2 ) isenta
               , SUM ( item.vlr_base_icms_3 ) outras
               , SUM ( item.vlr_base_icms_4 ) reducao
            FROM msaf.dwt_docto_fiscal capa
               , msaf.dwt_itens_merc item
               , msaf.x2012_cod_fiscal cfo
               , msaf.y2026_sit_trb_uf_b cst
               , msaf.x2006_natureza_op fin
               , msaf.x04_pessoa_fis_jur forn
           WHERE capa.ident_docto_fiscal = item.ident_docto_fiscal
             AND item.ident_cfo = cfo.ident_cfo
             AND item.ident_situacao_b = cst.ident_situacao_b
             AND item.ident_natureza_op = fin.ident_natureza_op
             AND capa.ident_fis_jur = forn.ident_fis_jur
             AND capa.cod_empresa = mcod_empresa
             AND capa.movto_e_s = '9'
             AND capa.situacao <> 'S'
             AND capa.data_fiscal BETWEEN p_i_data_ini AND p_i_data_fim
             AND forn.cpf_cgc LIKE '61412110%'
        GROUP BY capa.cod_empresa
               , capa.cod_estab
               , capa.movto_e_s
               , capa.num_docfis
               , capa.serie_docfis
               , capa.num_controle_docto
               , capa.data_fiscal
               , capa.situacao
               , capa.num_autentic_nfe
               , cfo.cod_cfo
               , cst.cod_situacao_b
               , fin.cod_natureza_op;

    --------------------------------------------------------------------------------------------------------------
    -- RELATORIO: UNION SELECT ''008'',''008 - Confronto DH x Mastersaf x MCD'' FROM DUAL
    CURSOR c_relatorio_02_008 ( p_i_data_fiscal IN DATE )
    IS
        SELECT a.cod_empresa
             , a.cod_estab
             , a.caixa
             , a.data_transacao
             , a.modelo
             , a.venda_liq_dh
             , a.venda_liq_msaf
             , a.venda_liq_mcd
             , a.diferenca
          FROM (SELECT mcod_empresa AS cod_empresa
                     , est.cod_estab AS cod_estab
                     , est.cod_caixa_ecf AS caixa
                     , p_i_data_fiscal AS data_transacao
                     , est.cod_modelo AS modelo
                     , NVL ( dh.val_liquido, 0 ) AS venda_liq_dh
                     , NVL ( cf.venda_liq, 0 ) AS venda_liq_msaf
                     , NVL ( mcd.venda_liq, 0 ) AS venda_liq_mcd
                     , CASE
                           WHEN ( NVL ( cf.venda_liq, 0 ) <> NVL ( mcd.venda_liq, 0 ) )
                             OR ( NVL ( cf.venda_liq, 0 ) <> NVL ( dh.val_liquido, 0 ) )
                             OR ( NVL ( dh.val_liquido, 0 ) <> NVL ( mcd.venda_liq, 0 ) ) THEN
                               '  *SIM*   '
                           ELSE
                               '  *NÃO*   '
                       END
                           AS diferenca
                  FROM (SELECT   TRIM ( TO_CHAR ( codigo_loja
                                                , '000' ) )
                                     loja
                               , data_transacao data_transacao
                               , REPLACE ( TO_CHAR ( numero_componente
                                                   , '0000' )
                                         , ' '
                                         , '' )
                                     caixa
                               , SUM ( val_liquido ) val_liquido
                            FROM msafi.p2k_trib_fech
                           WHERE data_transacao =    SUBSTR ( TO_CHAR ( p_i_data_fiscal
                                                                      , 'DD/MM/YYYY' )
                                                            , 7
                                                            , 4 )
                                                  || SUBSTR ( TO_CHAR ( p_i_data_fiscal
                                                                      , 'DD/MM/YYYY' )
                                                            , 4
                                                            , 2 )
                                                  || SUBSTR ( TO_CHAR ( p_i_data_fiscal
                                                                      , 'DD/MM/YYYY' )
                                                            , 1
                                                            , 2 )
                        GROUP BY codigo_loja
                               , data_transacao
                               , numero_componente) dh
                     , (SELECT REPLACE ( REPLACE ( cf.cod_estab
                                                 , 'DSP'
                                                 , '' )
                                       , 'DP'
                                       , '' )
                                   loja
                             , data_fiscal data_transacao
                             , REPLACE ( TO_CHAR ( cod_equipamento
                                                 , '0000' )
                                       , ' '
                                       , '' )
                                   caixa
                             , pdv.cod_modelo modelo
                             , vlr_gt_final - vlr_gt_inicial venda_bruta
                             , vlr_gt_final - vlr_gt_inicial - vlr_desconto - vlr_cancelado venda_liq
                             , vlr_desconto desconto
                             , vlr_cancelado canc
                          FROM msaf.x28_capa_ecf cf
                             , msaf.x2087_equipamento_ecf pdv
                         WHERE cf.cod_empresa = mcod_empresa
                           --AND CF.COD_ESTAB          = 'DSP344'
                           AND data_fiscal = p_i_data_fiscal
                           AND cf.cod_estab = pdv.cod_estab
                           AND cf.cod_equipamento = pdv.cod_caixa_ecf
                           AND pdv.cod_modelo = '2D'
                           AND pdv.valid_caixa_ecf = (SELECT MAX ( pdv2.valid_caixa_ecf )
                                                        FROM msaf.x2087_equipamento_ecf pdv2
                                                       WHERE pdv2.cod_caixa_ecf = pdv.cod_caixa_ecf
                                                         AND pdv2.cod_empresa = pdv.cod_empresa
                                                         AND pdv2.cod_estab = pdv.cod_estab
                                                         AND pdv2.valid_caixa_ecf <= SYSDATE)
                        UNION ALL
                        SELECT   REPLACE ( REPLACE ( cfe.cod_estab
                                                   , 'DSP'
                                                   , '' )
                                         , 'DP'
                                         , '' )
                                     loja
                               , data_emissao data_transacao
                               , REPLACE ( TO_CHAR ( pdv.cod_caixa_ecf
                                                   , '0000' )
                                         , ' '
                                         , '' )
                                     caixa
                               , pdv.cod_modelo modelo
                               , SUM ( vlr_item ) venda_bruta
                               , SUM ( vlr_tot_liq ) venda_liq
                               , SUM ( vlr_desc ) desconto
                               , 0 canc
                            FROM msaf.x202_item_cupom_cfe cfe
                               , msaf.x2087_equipamento_ecf pdv
                           WHERE cfe.cod_empresa = mcod_empresa
                             --AND CFE.COD_ESTAB         = 'DSP344'
                             AND data_emissao = p_i_data_fiscal
                             AND pdv.cod_modelo = '59'
                             AND cfe.cod_estab = pdv.cod_estab
                             AND cfe.num_equip = TO_NUMBER ( REPLACE ( pdv.cod_fabricacao_ecf
                                                                     , 'ANA'
                                                                     , '' ) )
                             AND pdv.valid_caixa_ecf = (SELECT MAX ( pdv2.valid_caixa_ecf )
                                                          FROM msaf.x2087_equipamento_ecf pdv2
                                                         WHERE pdv2.cod_caixa_ecf = pdv.cod_caixa_ecf
                                                           AND pdv2.cod_empresa = pdv.cod_empresa
                                                           AND pdv2.cod_estab = pdv.cod_estab
                                                           AND pdv2.valid_caixa_ecf <= SYSDATE)
                        GROUP BY cfe.cod_estab
                               , data_emissao
                               , pdv.cod_caixa_ecf
                               , pdv.cod_modelo) cf
                     , (SELECT REPLACE ( pdv.business_unit
                                       , 'VD'
                                       , '' )
                                   loja
                             , pdv.dsp_dt_mov data_transacao
                             , numero_pdv_dsp caixa
                             , pdv.dsp_venda_bruta venda_bruta
                             , pdv.dsp_venda_liq_1 venda_liq
                             , pdv.dsp_vlr_desc desconto
                             , pdv.dsp_vlr_cancel canc
                          FROM msafi.ps_dsp_pdv_mcd pdv
                             , msafi.ps_dsp_apur_mcd apur
                         WHERE pdv.dsp_dt_mov = p_i_data_fiscal
                           --AND PDV.BUSINESS_UNIT = 'VD344'
                           AND pdv.business_unit = apur.business_unit
                           AND pdv.dsp_dt_mov = apur.dsp_dt_mov
                           AND pdv.business_unit LIKE 'VD%'
                           AND apur.dsp_status_mcd IN ( 'C'
                                                      , 'V' )) mcd
                     , msaf.x2087_equipamento_ecf est
                 WHERE REPLACE ( REPLACE ( est.cod_estab
                                         , 'DSP'
                                         , '' )
                               , 'DP'
                               , '' ) = cf.loja(+)
                   AND REPLACE ( REPLACE ( est.cod_estab
                                         , 'DSP'
                                         , '' )
                               , 'DP'
                               , '' ) = mcd.loja(+)
                   AND REPLACE ( TO_CHAR ( est.cod_caixa_ecf
                                         , '0000' )
                               , ' '
                               , '' ) = cf.caixa(+)
                   AND REPLACE ( TO_CHAR ( est.cod_caixa_ecf
                                         , '0000' )
                               , ' '
                               , '' ) = mcd.caixa(+)
                   AND REPLACE ( REPLACE ( est.cod_estab
                                         , 'DSP'
                                         , '' )
                               , 'DP'
                               , '' ) = dh.loja(+)
                   AND REPLACE ( TO_CHAR ( est.cod_caixa_ecf
                                         , '0000' )
                               , ' '
                               , '' ) = dh.caixa(+)
                   AND est.cod_empresa = mcod_empresa
                   --AND   EST.COD_ESTAB   = 'DSP344'
                   AND est.valid_caixa_ecf = (SELECT MAX ( valid_caixa_ecf )
                                                FROM msaf.x2087_equipamento_ecf est1
                                               WHERE est.cod_empresa = est1.cod_empresa
                                                 AND est.cod_estab = est1.cod_estab
                                                 AND est.cod_caixa_ecf = est1.cod_caixa_ecf)) a
         WHERE a.venda_liq_dh <> 0
            OR a.venda_liq_msaf <> 0
            OR a.venda_liq_mcd <> 0;

    --------------------------------------------------------------------------------------------------------------
    -- RELATORIO: UNION SELECT ''009'',''009 - Relatório Valor do FECP-RJ'' FROM DUAL
    CURSOR c_relatorio_009 ( p_i_data_ini IN DATE
                           , p_i_data_fim IN DATE )
    IS
        SELECT   a.cod_empresa
               , a.cod_estab
               , a.data_apuracao
               , a.base_tributada_saida
               , a.base_tributada_entrada
               , ROUND ( ( a.base_tributada_saida - a.base_tributada_entrada ) / 50
                       , 2 )
                     valor_fecp --- divisao por 50 corresponde a 2%
            FROM (SELECT   ddf.cod_empresa cod_empresa
                         , ddf.cod_estab cod_estab
                         , LAST_DAY ( MAX ( ddf.data_fiscal ) ) data_apuracao
                         , SUM ( DECODE ( ddf.movto_e_s, '9', dim.vlr_base_icms_1, 0 ) ) base_tributada_saida
                         , SUM ( DECODE ( ddf.movto_e_s, '9', 0, dim.vlr_base_icms_1 ) ) base_tributada_entrada
                      FROM msaf.dwt_docto_fiscal ddf
                         , msaf.estabelecimento esb
                         , msaf.estado esd
                         , msaf.x04_pessoa_fis_jur x04
                         , msaf.estado ex4
                         , msaf.dwt_itens_merc dim
                         , msafi.dsp_estabelecimento estab
                     WHERE ddf.cod_empresa = mcod_empresa
                       AND ddf.cod_estab = estab.cod_estab
                       AND ddf.cod_empresa = estab.cod_empresa
                       AND estab.tipo = 'L' --- apenas LOJAS RJ
                       AND ddf.data_fiscal BETWEEN p_i_data_ini AND p_i_data_fim
                       AND ddf.situacao = 'N'
                       -- ,MSAF.ESTABELECIMENTO ESB
                       AND esb.cod_estab = ddf.cod_estab
                       -- ,MSAF.ESTADO ESD
                       AND esd.ident_estado = esb.ident_estado
                       AND esd.cod_estado = 'RJ'
                       -- ,MSAF.X04_PESSOA_FIS_JUR X04
                       AND x04.ident_fis_jur = ddf.ident_fis_jur
                       -- ,MSAF.ESTADO EX4
                       AND ex4.ident_estado = x04.ident_estado
                       AND ex4.cod_estado = 'RJ'
                       -- ,MSAF.DWT_ITENS_MERC DIM
                       --AND DIM.IDENT_DOCTO_FISCAL = DDF.IDENT_DOCTO_FISCAL
                       AND dim.cod_empresa = ddf.cod_empresa
                       AND dim.cod_estab = ddf.cod_estab
                       AND dim.data_fiscal = ddf.data_fiscal
                       AND dim.movto_e_s = ddf.movto_e_s
                       AND dim.norm_dev = ddf.norm_dev
                       AND dim.norm_dev = ddf.norm_dev
                       AND dim.ident_docto = ddf.ident_docto
                       AND dim.ident_fis_jur = ddf.ident_fis_jur
                       AND dim.num_docfis = ddf.num_docfis
                       AND dim.serie_docfis = ddf.serie_docfis
                       AND dim.sub_serie_docfis = ddf.sub_serie_docfis
                       AND dim.vlr_base_icms_1 > 0
                  GROUP BY ddf.cod_empresa
                         , ddf.cod_estab) a
           WHERE a.base_tributada_saida - a.base_tributada_entrada > 0
        ORDER BY 1
               , 2;

    --------------------------------------------------------------------------------------------------------------
    -- RELATORIO: UNION SELECT ''010'',''010 - Relatório Confronto MSAF x MCD x GL'' FROM DUAL
    CURSOR c_relatorio_010 ( p_i_data_fiscal IN DATE )
    IS
        SELECT   a.cod_empresa
               , a.cod_estab
               , a.uf
               , a.data_transacao
               , a.venda_liq_dh
               , a.status_dh
               , a.venda_liq_msaf
               , a.venda_liq_mcd
               , a.status_mcd
               , a.venda_liq_gl
               , a.diferenca
            FROM (SELECT mcod_empresa AS cod_empresa
                       , est.cod_estab AS cod_estab
                       , est.cod_estado AS uf
                       , dh.data_transacao AS data_transacao
                       , NVL ( dh.val_liquido, 0 ) AS venda_liq_dh
                       , dh.status_dh AS status_dh
                       , NVL ( cf.venda_liq, 0 ) AS venda_liq_msaf
                       , NVL ( mcd.venda_liq, 0 ) AS venda_liq_mcd
                       , mcd.status_mcd AS status_mcd
                       , NVL ( gl.venda_liq, 0 ) AS venda_liq_gl
                       , CASE
                             WHEN ( NVL ( dh.val_liquido, 0 ) <> NVL ( cf.venda_liq, 0 ) )
                               OR ( NVL ( dh.val_liquido, 0 ) <> NVL ( mcd.venda_liq, 0 ) )
                               OR ( NVL ( dh.val_liquido, 0 ) <> NVL ( gl.venda_liq, 0 ) )
                               OR ( NVL ( cf.venda_liq, 0 ) <> NVL ( mcd.venda_liq, 0 ) )
                               OR ( NVL ( cf.venda_liq, 0 ) <> NVL ( gl.venda_liq, 0 ) )
                               OR ( NVL ( mcd.venda_liq, 0 ) <> NVL ( gl.venda_liq, 0 ) ) THEN
                                 '  *SIM*   '
                             ELSE
                                 '  *não*   '
                         END
                             AS diferenca
                    FROM (SELECT   REPLACE ( REPLACE ( gl.operating_unit
                                                     , 'DSP'
                                                     , '' )
                                           , 'DP'
                                           , '' )
                                       loja
                                 , gl.journal_date data_transacao
                                 , SUM ( gl.monetary_amount * -1 ) venda_liq
                              FROM msafi.ps_jrnl_ln gl
                                 , msafi.dsp_interface_setup stp
                             WHERE gl.business_unit = stp.bu_gl
                               AND stp.cod_empresa = mcod_empresa
                               --AND OPERATING_UNIT = 'DSP004'
                               AND gl.journal_date = p_i_data_fiscal
                               AND gl.account LIKE '3%'
                               AND gl.journal_id LIKE 'MCD%'
                               AND gl.monetary_amount < 0
                          GROUP BY REPLACE ( REPLACE ( gl.operating_unit
                                                     , 'DSP'
                                                     , '' )
                                           , 'DP'
                                           , '' )
                                 , gl.journal_date) gl
                       , (SELECT   CASE mcod_empresa
                                       WHEN 'DSP' THEN
                                           TRIM ( TO_CHAR ( ptf.codigo_loja
                                                          , '000' ) )
                                       ELSE
                                           TRIM ( TO_CHAR ( ptf.codigo_loja
                                                          , '0000' ) )
                                   END
                                       loja
                                 , TO_DATE ( ptf.data_transacao
                                           , 'YYYYMMDD' )
                                       data_transacao
                                 , pfe.status_proc_1 status_dh
                                 , SUM ( ptf.val_liquido ) val_liquido
                              FROM msafi.p2k_trib_fech ptf
                                 , msafi.p2k_fechamento pfe
                             WHERE --CODIGO_LOJA    = '4' AND
                                   ptf.data_transacao =    SUBSTR ( TO_CHAR ( p_i_data_fiscal
                                                                            , 'DD/MM/YYYY' )
                                                                  , 7
                                                                  , 4 )
                                                        || SUBSTR ( TO_CHAR ( p_i_data_fiscal
                                                                            , 'DD/MM/YYYY' )
                                                                  , 4
                                                                  , 2 )
                                                        || SUBSTR ( TO_CHAR ( p_i_data_fiscal
                                                                            , 'DD/MM/YYYY' )
                                                                  , 1
                                                                  , 2 )
                               AND ptf.codigo_loja = pfe.codigo_loja
                               AND ptf.data_transacao = pfe.data_transacao
                               AND ptf.numero_componente = pfe.numero_componente
                               AND ptf.nsu_transacao = pfe.nsu_transacao
                          GROUP BY ptf.codigo_loja
                                 , ptf.data_transacao
                                 , pfe.status_proc_1) dh
                       , (SELECT   REPLACE ( REPLACE ( cfe.cod_estab
                                                     , 'DSP'
                                                     , '' )
                                           , 'DP'
                                           , '' )
                                       loja
                                 , data_fiscal data_transacao
                                 , SUM ( cfe.vlr_contab_item ) venda_liq
                              FROM msaf.dwt_itens_merc cfe
                             WHERE cfe.cod_empresa = mcod_empresa
                               --AND CFE.COD_ESTAB      = 'DSP004'
                               AND data_fiscal = p_i_data_fiscal
                               AND cfe.ident_docto IN ( SELECT ident_docto
                                                          FROM msaf.x2005_tipo_docto
                                                         WHERE cod_docto IN ( 'CF-E'
                                                                            , 'CF'
                                                                            , 'SAT' ) )
                          GROUP BY cfe.cod_estab
                                 , data_fiscal) cf
                       , (SELECT   REPLACE ( REPLACE ( pdv.business_unit
                                                     , 'VD'
                                                     , '' )
                                           , 'L'
                                           , '' )
                                       loja
                                 , pdv.dsp_dt_mov data_transacao
                                 , SUM ( pdv.dsp_venda_liq_1 ) venda_liq
                                 , apur.dsp_status_mcd status_mcd
                              FROM msafi.ps_dsp_pdv_mcd pdv
                                 , msafi.ps_dsp_apur_mcd apur
                             WHERE pdv.dsp_dt_mov = p_i_data_fiscal
                               --AND PDV.BUSINESS_UNIT    = 'VD004'
                               AND pdv.business_unit = apur.business_unit
                               AND pdv.dsp_dt_mov = apur.dsp_dt_mov
                               AND ( pdv.business_unit LIKE 'VD%'
                                 OR pdv.business_unit LIKE 'L%' )
                               AND apur.dsp_status_mcd IN ( 'C'
                                                          , 'V'
                                                          , 'F' )
                          GROUP BY REPLACE ( REPLACE ( pdv.business_unit
                                                     , 'VD'
                                                     , '' )
                                           , 'L'
                                           , '' )
                                 , pdv.dsp_dt_mov
                                 , apur.dsp_status_mcd) mcd
                       , (SELECT *
                            FROM msaf.estabelecimento est
                               , msaf.estado tuf
                           WHERE est.cod_empresa = mcod_empresa
                             AND est.ident_estado = tuf.ident_estado(+)--AND EST.COD_ESTAB   = 'DSP004'
                                                                       ) est
                   WHERE REPLACE ( REPLACE ( est.cod_estab
                                           , 'DSP'
                                           , '' )
                                 , 'DP'
                                 , '' ) = cf.loja(+)
                     AND REPLACE ( REPLACE ( est.cod_estab
                                           , 'DSP'
                                           , '' )
                                 , 'DP'
                                 , '' ) = mcd.loja(+)
                     AND REPLACE ( REPLACE ( est.cod_estab
                                           , 'DSP'
                                           , '' )
                                 , 'DP'
                                 , '' ) = dh.loja(+)
                     AND REPLACE ( REPLACE ( est.cod_estab
                                           , 'DSP'
                                           , '' )
                                 , 'DP'
                                 , '' ) = gl.loja(+)
                     --AND EST.COD_ESTAB   = 'DSP004'
                     AND est.cod_empresa = mcod_empresa) a
           WHERE a.venda_liq_dh <> 0
              OR a.venda_liq_msaf <> 0
              OR a.venda_liq_mcd <> 0
              OR a.venda_liq_gl <> 0
        ORDER BY 4
               , 2;
--------------------------------------------------------------------------------------------------------------

END dsp_relatorios_02_cproc;
/
SHOW ERRORS;
