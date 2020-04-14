Prompt Package DSP_REL_CONFRONTO_CUPOM_CPROC;
--
-- DSP_REL_CONFRONTO_CUPOM_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dsp_rel_confronto_cupom_cproc
IS
    -- AUTOR    : DSP - REBELLO
    -- DATA     : 09/05/2017
    -- DESCRIÇÃO: Relatório de Confronto e Carga de Cupons

    -- AUTOR DA ATUALIZAÇÃO : Douglas Oliveira
    -- DATA     : 22/01/2019
    -- DESCRIÇÃO: Atualização nos valores contabeis, chamado: 2000892

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

    FUNCTION executar ( p_data_ini DATE
                      , p_data_fim DATE
                      , p_carga_cupom VARCHAR2
                      , p_diferenca VARCHAR2
                      , p_delete VARCHAR2
                      , p_delete_log VARCHAR2
                      , p_codestab lib_proc.vartab )
        RETURN INTEGER;

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
    -- RELATORIO: Relatório Confronto MSAF x MCD x GL
    CURSOR c_relatorio_010 (
        p_i_data_fiscal IN DATE
      , p_i_cod_estab IN VARCHAR2
    )
    IS
        SELECT   a.cod_empresa
               , a.cod_estab
               , a.uf
               , a.data_transacao
               , a.venda_liq_dh
               , a.status_dh
               , TO_CHAR ( a.data_alt_status
                         , 'DD/MM/YYYY HH24:MI:SS' )
                     AS data_alt_status
               , a.venda_liq_msaf
               , a.venda_liq_mcd
               , a.status_mcd
               , a.venda_liq_gl
               , a.diferenca
               , a.diferenca_msaf
            FROM ( SELECT mcod_empresa AS cod_empresa
                        , est.cod_estab AS cod_estab
                        , est.cod_estado AS uf
                        , COALESCE ( dh.data_transacao
                                   , cf.data_transacao
                                   , mcd.data_transacao )
                              AS data_transacao
                        , NVL ( dh.val_liquido, 0 ) AS venda_liq_dh
                        , dh.status_dh AS status_dh
                        , dh.data_alt_status AS data_alt_status
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
                                  '  *NÃO*   '
                          END
                              AS diferenca
                        , CASE
                              WHEN ( NVL ( dh.val_liquido, 0 ) <> NVL ( cf.venda_liq, 0 ) ) THEN '  *SIM*   '
                              ELSE '  *NÃO*   '
                          END
                              AS diferenca_msaf
                     FROM -- Inicio da Atualização - 22/01/2019 - Douglas Oliveira - chamado: 2000892
                          (SELECT TO_NUMBER ( REGEXP_REPLACE ( cod_estab
                                                             , 'D|S|P|V|L'
                                                             , '' ) )
                                      loja
                                , TO_DATE ( TO_CHAR ( data_lancto
                                                    , 'YYYYMMDD' )
                                          , 'YYYYMMDD' )
                                      data_transacao
                                , valor_lancto venda_liq
                             FROM msafi.dpsp_conf_contab_vw
                            WHERE cod_empresa = mcod_empresa
                              AND TO_CHAR ( REGEXP_REPLACE ( cod_estab
                                                           , 'D|S|P|V|L'
                                                           , '' ) ) = TO_CHAR ( REGEXP_REPLACE ( p_i_cod_estab
                                                                                               , 'D|S|P|V|L'
                                                                                               , '' ) )
                              AND data_lancto = p_i_data_fiscal) gl
                        , -- Fim da Atualização - 22/01/2019 - Douglas Oliveira

                          (SELECT   ptf.codigo_loja loja
                                  , TO_DATE ( ptf.data_transacao
                                            , 'YYYYMMDD' )
                                        data_transacao
                                  , pfe.status_proc_1 status_dh
                                  , MAX ( pfe.data_proc_1 ) data_alt_status
                                  , SUM ( ptf.val_liquido ) val_liquido
                               FROM msafi.p2k_trib_fech ptf
                                  , msafi.p2k_fechamento pfe
                              WHERE ptf.codigo_loja = TO_NUMBER ( REGEXP_REPLACE ( p_i_cod_estab
                                                                                 , 'D|S|P|V|L'
                                                                                 , '' ) )
                                AND ptf.data_transacao = TO_CHAR ( p_i_data_fiscal
                                                                 , 'YYYYMMDD' )
                                AND ptf.codigo_loja = pfe.codigo_loja
                                AND ptf.data_transacao = pfe.data_transacao
                                AND ptf.numero_componente = pfe.numero_componente
                                AND ptf.nsu_transacao = pfe.nsu_transacao
                           GROUP BY ptf.codigo_loja
                                  , ptf.data_transacao
                                  , pfe.status_proc_1) dh
                        , (SELECT   est.codigo_loja loja
                                  , data_fiscal data_transacao
                                  , SUM ( cfe.vlr_contab_item ) venda_liq
                               FROM msaf.dwt_itens_merc cfe
                                  , msafi.dsp_estabelecimento est
                              WHERE cfe.cod_empresa = mcod_empresa
                                AND cfe.cod_estab = p_i_cod_estab
                                AND data_fiscal = p_i_data_fiscal
                                AND cfe.ident_docto IN ( SELECT ident_docto
                                                           FROM msaf.x2005_tipo_docto
                                                          WHERE cod_docto IN ( 'CF'
                                                                             , 'CF-E'
                                                                             , 'SAT' ) )
                                AND cfe.cod_empresa = est.cod_empresa
                                AND cfe.cod_estab = est.cod_estab
                           GROUP BY est.codigo_loja
                                  , data_fiscal) cf
                        , (SELECT   TO_NUMBER ( REGEXP_REPLACE ( pdv.business_unit
                                                               , 'D|S|P|V|L'
                                                               , '' ) )
                                        loja
                                  , pdv.dsp_dt_mov data_transacao
                                  , SUM ( pdv.dsp_venda_liq_1 ) venda_liq
                                  , apur.dsp_status_mcd status_mcd
                               FROM msafi.ps_dsp_pdv_mcd pdv
                                  , msafi.ps_dsp_apur_mcd apur
                              WHERE pdv.dsp_dt_mov = p_i_data_fiscal
                                AND TO_NUMBER ( REGEXP_REPLACE ( pdv.business_unit
                                                               , 'D|S|P|V|L'
                                                               , '' ) ) = TO_NUMBER ( REGEXP_REPLACE ( p_i_cod_estab
                                                                                                     , 'D|S|P|V|L'
                                                                                                     , '' ) )
                                AND pdv.business_unit = apur.business_unit
                                AND pdv.dsp_dt_mov = apur.dsp_dt_mov
                                AND ( pdv.business_unit LIKE 'VD%'
                                  OR pdv.business_unit LIKE 'L%' )
                                AND apur.dsp_status_mcd IN ( 'C'
                                                           , 'V'
                                                           , 'F' ) --- CONCLUIDO = C/ CONFERIDO = V/ FECHADO = F
                           GROUP BY TO_NUMBER ( REGEXP_REPLACE ( pdv.business_unit
                                                               , 'D|S|P|V|L'
                                                               , '' ) )
                                  , pdv.dsp_dt_mov
                                  , apur.dsp_status_mcd) mcd
                        , (SELECT *
                             FROM msafi.dsp_estabelecimento est
                            WHERE est.cod_empresa = mcod_empresa
                              AND est.cod_estab = p_i_cod_estab) est
                    WHERE est.codigo_loja = cf.loja(+)
                      AND est.codigo_loja = mcd.loja(+)
                      AND est.codigo_loja = dh.loja(+)
                      AND est.codigo_loja = gl.loja(+)
                      AND est.cod_estab = p_i_cod_estab
                      AND est.cod_empresa = mcod_empresa ) a
           WHERE a.venda_liq_dh <> 0
              OR a.venda_liq_msaf <> 0
              OR a.venda_liq_mcd <> 0
              OR a.venda_liq_gl <> 0
        ORDER BY 4
               , 2;
--------------------------------------------------------------------------------------------------------------

END dsp_rel_confronto_cupom_cproc;
/
SHOW ERRORS;
