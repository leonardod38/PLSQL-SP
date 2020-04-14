Prompt Package DSP_SPED_CONTRIB_SCPT_CPROC;
--
-- DSP_SPED_CONTRIB_SCPT_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dsp_sped_contrib_scpt_cproc
IS
    -- AUTOR    : DSP - LFM
    -- DATA     : Dez/2013
    -- DESCRIÇÃO: Módulo customizado de scripts para o Sped Contribuições (EFD PIS/COFINS)

    mcod_empresa empresa.cod_empresa%TYPE;
    mcod_estab estabelecimento.cod_estab%TYPE;
    musuario usuario_empresa.cod_usuario%TYPE;

    --Variaveis para as funções REGEXP_LIKE encontrarem DSP9xx, Depósitos, Lojas e Estabelecimentos
    v_proc_9xx VARCHAR2 ( 30 ); --V_PROC_9XX   := '^' || MCOD_EMPRESA || '9[0-9]{2}$';
    v_proc_dep VARCHAR2 ( 30 ); --V_PROC_DEP   := '^' || MCOD_EMPRESA || '9[0-9][1-9]$';
    v_proc_loj VARCHAR2 ( 30 ); --V_PROC_LOJ   := '^' || MCOD_EMPRESA || '[0-8][0-9]{' || TO_CHAR(5-LENGTH(MCOD_EMPRESA),'FM9') || '}$';
    v_proc_est VARCHAR2 ( 30 ); --V_PROC_EST   := '^' || MCOD_EMPRESA || '[0-9]{3,' || TO_CHAR(6-LENGTH(MCOD_EMPRESA),'FM9') || '}$';
    v_proc_estvd VARCHAR2 ( 30 ); --V_PROC_ESTVD := '^VD[0-9]{3,' || TO_CHAR(6-LENGTH(MCOD_EMPRESA),'FM9') || '}$';
    v_criterio1 VARCHAR2 ( 30 );
    v_criterio2 VARCHAR2 ( 30 );

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

    FUNCTION executar ( p_script VARCHAR2
                      , p_mes VARCHAR2
                      , p_ano VARCHAR2 )
        RETURN INTEGER;

    --------------------------------------------------------------------------------------------------------------
    -- Cursor: Lista de datas
    CURSOR c_datas ( p_i_data_ini IN DATE
                   , p_i_data_fim IN DATE )
    IS
        SELECT   TO_CHAR ( d.data_fiscal
                         , 'YYYYMMDD' )
                     AS data_safx
               , d.data_fiscal AS data_normal
            FROM (SELECT     p_i_data_ini + ( ROWNUM - 1 ) AS "DATA_FISCAL"
                        FROM DUAL
                  CONNECT BY LEVEL <= (p_i_data_fim - p_i_data_ini + 1)) d
        ORDER BY d.data_fiscal;

    --------------------------------------------------------------------------------------------------------------
    -- Cursor: SELECT ''001'',''001 - Corrige Zicas Kelly'' FROM DUAL
    CURSOR c_zicaskelly_01_001 (
        p_i_data IN DATE
    )
    IS
        SELECT ident_nbm_novo
             , ident_produto
             , ident_nbm
             , cod_produto
             , cod_nbm_atual
             , ( SELECT cod_nbm
                   FROM msaf.x2043_cod_nbm x2043
                  WHERE x2043.ident_nbm = a.ident_nbm_novo )
                   cod_nbm_novo
             ,    'UPDATE MSAF.X2013_PRODUTO SET IDENT_NBM = '
               || ident_nbm_novo
               || ' WHERE IDENT_PRODUTO = '
               || ident_produto
               || ' AND IDENT_NBM = '
               || ident_nbm
                   AS sql_update_nbm
          FROM (SELECT a.*
                     , b.cod_nbm AS "COD_NBM_ATUAL"
                     , NVL ( SUBSTR ( RTRIM ( REPLACE ( c.tax_class_brl
                                                      , '.'
                                                      , '' ) )
                                    , 1
                                    , 8 )
                           , '@' )
                           AS "COD_NBM_PEOPLE"
                     , ( SELECT ident_nbm
                           FROM msaf.x2043_cod_nbm sb
                          WHERE sb.cod_nbm = NVL ( SUBSTR ( RTRIM ( REPLACE ( c.tax_class_brl
                                                                            , '.'
                                                                            , '' ) )
                                                          , 1
                                                          , 8 )
                                                 , '@' )
                            AND sb.valid_nbm = (SELECT MAX ( valid_nbm )
                                                  FROM msaf.x2043_cod_nbm ssb
                                                 WHERE ssb.cod_nbm = sb.cod_nbm
                                                   AND ssb.valid_nbm <= p_i_data) )
                           AS "IDENT_NBM_NOVO"
                  FROM msaf.x2013_produto a
                     , msaf.x2043_cod_nbm b
                     , msafi.ps_inv_items c
                 WHERE valid_produto >= (SELECT MAX ( valid_produto )
                                           FROM msaf.x2013_produto sa
                                          WHERE sa.grupo_produto = a.grupo_produto
                                            AND sa.ind_produto = a.ind_produto
                                            AND sa.cod_produto = a.cod_produto
                                            AND sa.valid_produto < p_i_data)
                   AND valid_produto <= p_i_data
                   AND b.ident_nbm = a.ident_nbm
                   AND c.setid = 'GERAL'
                   AND c.inv_item_id = a.cod_produto
                   AND c.effdt = (SELECT MAX ( effdt )
                                    FROM msafi.ps_inv_items sc
                                   WHERE sc.setid = c.setid
                                     AND sc.inv_item_id = c.inv_item_id
                                     AND sc.effdt <= p_i_data)
                   AND ( ( b.cod_nbm IS NOT NULL
                      AND b.cod_nbm <> NVL ( SUBSTR ( RTRIM ( REPLACE ( c.tax_class_brl
                                                                      , '.'
                                                                      , '' ) )
                                                    , 1
                                                    , 8 )
                                           , '@' ) )
                     OR b.cod_nbm IS NULL )
                   AND NVL ( SUBSTR ( RTRIM ( REPLACE ( c.tax_class_brl
                                                      , '.'
                                                      , '' ) )
                                    , 1
                                    , 8 )
                           , '@' ) <> '@') a;

    --------------------------------------------------------------------------------------------------------------
    -- Cursor: Lista de estabelecimentos na X993 e DWT, para o período informado
    CURSOR lista_estabs_x993 ( p_cod_empresa IN VARCHAR2
                             , p_data_ini IN DATE
                             , p_data_fim IN DATE )
    IS
        SELECT DISTINCT cod_estab
          FROM (SELECT cod_estab
                  FROM msaf.x993_capa_cupom_ecf x993
                 WHERE x993.cod_empresa = p_cod_empresa
                   AND x993.data_emissao BETWEEN p_data_ini AND p_data_fim
                UNION ALL
                SELECT cod_estab
                  FROM msaf.dwt_docto_fiscal a
                 WHERE a.cod_empresa = p_cod_empresa
                   AND a.data_fiscal BETWEEN p_data_ini AND p_data_fim);
--------------------------------------------------------------------------------------------------------------

END dsp_sped_contrib_scpt_cproc;
/
SHOW ERRORS;
