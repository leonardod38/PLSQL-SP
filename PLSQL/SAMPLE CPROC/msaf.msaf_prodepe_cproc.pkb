Prompt Package Body MSAF_PRODEPE_CPROC;
--
-- MSAF_PRODEPE_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY msaf_prodepe_cproc
IS
    mproc_id NUMBER;
    mnm_usuario usuario_estab.cod_usuario%TYPE;
    mcod_empresa estabelecimento.cod_empresa%TYPE;
    vs_mlinha VARCHAR2 ( 4000 );

    --Tipo, Nome e Descrição do Customizado
    mnm_tipo VARCHAR2 ( 100 ) := 'PRODEPE';
    mnm_cproc VARCHAR2 ( 100 ) := $$plsql_unit;
    mds_cproc VARCHAR2 ( 100 ) := 'Processo para apurar rateio de credito Prodepe';

    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );
    BEGIN
        mnm_usuario := lib_parametros.recuperar ( UPPER ( 'USUARIO' ) );
        mcod_empresa := lib_parametros.recuperar ( UPPER ( 'EMPRESA' ) );

        --PPERIODO
        lib_proc.add_param ( pparam => pstr
                           , ptitulo => 'Periodo'
                           , ptipo => 'DATE'
                           , pcontrole => 'textbox'
                           , pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => 'MM/YYYY' );

        lib_proc.add_param ( pparam => pstr
                           , ptitulo => 'Processar_periodo'
                           , ptipo => 'Varchar2'
                           , pcontrole => 'Checkbox'
                           , pmandatorio => 'S'
                           , pdefault => 'N'
                           , pmascara => NULL
                           , pvalores => 'S=Sim,N=Não'
                           , papresenta => 'N' );

        lib_proc.add_param ( pparam => pstr
                           , ptitulo => 'Relatorio Notas Fiscais Emitidas'
                           , ptipo => 'Varchar2'
                           , pcontrole => 'Checkbox'
                           , pmandatorio => 'S'
                           , pdefault => 'N'
                           , pmascara => NULL
                           , pvalores => 'S=Sim,N=Não'
                           , papresenta => 'N' );

        lib_proc.add_param ( pparam => pstr
                           , ptitulo => 'Relatorio Analitico de Rateio'
                           , ptipo => 'Varchar2'
                           , pcontrole => 'Checkbox'
                           , pmandatorio => 'S'
                           , pdefault => 'N'
                           , pmascara => NULL
                           , pvalores => 'S=Sim,N=Não'
                           , papresenta => 'N' );

        lib_proc.add_param ( pparam => pstr
                           , ptitulo => 'Relatorio Sintetico de Rateio'
                           , ptipo => 'Varchar2'
                           , pcontrole => 'Checkbox'
                           , pmandatorio => 'S'
                           , pdefault => 'N'
                           , pmascara => NULL
                           , pvalores => 'S=Sim,N=Não'
                           , papresenta => 'N' );

        --PCOD_ESTAB
        lib_proc.add_param (
                             pparam => pstr
                           , ptitulo => 'Estabelecimento'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'Combobox'
                           , --'MULTISELECT',
                            pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => NULL
                           , pvalores =>    'SELECT A.COD_ESTAB,A.COD_ESTAB || '' - '' || B.COD_ESTADO || '' - '' || A.CGC || '' - '' || INITCAP(A.BAIRRO) || '' / '' || INITCAP(A.CIDADE) FROM ESTABELECIMENTO A, ESTADO B WHERE A.COD_EMPRESA  = '''
                                         || mcod_empresa
                                         || ''' AND B.IDENT_ESTADO = A.IDENT_ESTADO AND B.COD_ESTADO = ''PE'' ORDER BY B.COD_ESTADO, A.COD_ESTAB'
                           , papresenta => 'N'
        );
        RETURN pstr;
    END;

    FUNCTION tipo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN mnm_tipo;
    END;

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN mnm_cproc;
    END;

    FUNCTION descricao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN mds_cproc;
    END;

    FUNCTION versao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN '1.0';
    END;

    FUNCTION modulo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Customizados';
    END;

    FUNCTION classificacao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Customizados';
    END;

    FUNCTION orientacao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'PORTRAIT';
    END;

    FUNCTION executar ( pperiodo DATE
                      , v_processa_rateio VARCHAR2
                      , v_relatotorio_nf_emitidas VARCHAR2
                      , v_relatotorio_analitico_rateio VARCHAR2
                      , v_relatotorio_sintetico_rateio VARCHAR2
                      , pcod_estab VARCHAR2 --lib_proc.vartab
                                            )
        RETURN INTEGER
    IS
        v_data_inicial DATE
            :=   TRUNC ( pperiodo )
               - (   TO_NUMBER ( TO_CHAR ( pperiodo
                                         , 'DD' ) )
                   - 1 );
        v_data_final DATE := LAST_DAY ( pperiodo );
        v_data_hora_ini VARCHAR2 ( 20 );

        v_tipo_arq VARCHAR2 ( 2 );

        --Variaveis genericas

        v_qtde_utilizada NUMBER;
        v_qtde_utilizada_saida NUMBER;
        v_qtde_saldo_saida NUMBER;
    BEGIN
        -- Criação: Processo
        mproc_id := lib_proc.new ( psp_nome => $$plsql_unit /*,
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           pdescricao => v_descricao*/
                                                            );

        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT="YYYYMMDD"';

        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS= '',.'' ';

        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        mnm_usuario := lib_parametros.recuperar ( 'USUARIO' );

        --MARCAR INCIO DA EXECUCAO
        v_data_hora_ini :=
            TO_CHAR ( SYSDATE
                    , 'DD/MM/YYYY HH24:MI.SS' );

        IF mcod_empresa IS NULL THEN
            lib_proc.add_log ( 'Código da empresa deve ser informado como parâmetro global.'
                             , 0 );
            lib_proc.add ( 'ERRO' );
            lib_proc.add ( 'CÓDIGO DA EMPRESA DEVE SER INFORMADO COMO PARÂMETRO GLOBAL.' );
            lib_proc.close;
            RETURN mproc_id;
        END IF;

        loga ( '---INI DO PROCESSAMENTO---'
             , FALSE );
        loga (    '<< Período do processamento: '
               || TO_CHAR ( v_data_inicial
                          , 'MM/YYYY' )
               || ' >>'
             , FALSE );

        loga (    '<< DT INICIO: '
               || TO_CHAR ( v_data_inicial
                          , 'DD/MM/YYYY' )
               || ' >>'
             , FALSE );

        loga (    '<< DT INICIO: '
               || TO_CHAR ( v_data_final
                          , 'DD/MM/YYYY' )
               || ' >>'
             , FALSE );

        --=================================================================================
        -- INICIO
        --=================================================================================

        IF v_processa_rateio = 'S' THEN
            -- FOR v_cod_estab IN pcod_estab.FIRST .. pcod_estab.LAST LOOP

            dbms_application_info.set_module ( $$plsql_unit
                                             , 'Estab: ' || pcod_estab /*(v_cod_estab)*/
                                                                       );

            loga ( '<< ESTAB: ' || pcod_estab /*(v_cod_estab)*/
                                             || ' >>'
                 , FALSE );

            -- exclui itens de entrada ja carregados para reprocessamento
            FOR d IN ( SELECT ROWID v_rowid
                         FROM cust_prodepe_nf_entrada
                        WHERE 1 = 1
                          AND data_fiscal BETWEEN v_data_inicial AND v_data_final
                          AND cod_estab = pcod_estab /*(v_cod_estab)*/
                          AND cod_empresa = mcod_empresa ) LOOP
                DELETE FROM cust_prodepe_nf_entrada
                      WHERE ROWID = d.v_rowid;

                COMMIT;
            END LOOP;

            -- Recupera itens de entrada
            FOR c IN ( SELECT capa.cod_empresa
                            , capa.cod_estab
                            , capa.data_fiscal
                            , capa.movto_e_s
                            , capa.norm_dev
                            , capa.ident_docto
                            , capa.ident_fis_jur
                            , capa.num_docfis
                            , capa.serie_docfis
                            , capa.sub_serie_docfis
                            , item.discri_item
                            , capa.num_controle_docto
                            , capa.data_emissao
                            , item.ident_produto
                            , x2013.ind_produto
                            , x2013.cod_produto
                            , item.quantidade
                            , item.vlr_unit vl_unit
                            , item.vlr_item vl_total
                            , NVL ( ( SELECT x08.vlr_tributo
                                        FROM x08_trib_merc x08
                                       WHERE x08.cod_empresa = item.cod_empresa
                                         AND x08.cod_estab = item.cod_estab
                                         AND x08.data_fiscal = item.data_fiscal
                                         AND x08.movto_e_s = item.movto_e_s
                                         AND x08.norm_dev = item.norm_dev
                                         AND x08.ident_docto = item.ident_docto
                                         AND x08.ident_fis_jur = item.ident_fis_jur
                                         AND x08.num_docfis = item.num_docfis
                                         AND x08.serie_docfis = item.serie_docfis
                                         AND x08.sub_serie_docfis = item.sub_serie_docfis
                                         AND x08.discri_item = item.discri_item
                                         AND x08.cod_tributo = 'ICMS' )
                                  , 0 )
                                  vl_icms
                            , ( SELECT x08.aliq_tributo
                                  FROM x08_trib_merc x08
                                 WHERE x08.cod_empresa = item.cod_empresa
                                   AND x08.cod_estab = item.cod_estab
                                   AND x08.data_fiscal = item.data_fiscal
                                   AND x08.movto_e_s = item.movto_e_s
                                   AND x08.norm_dev = item.norm_dev
                                   AND x08.ident_docto = item.ident_docto
                                   AND x08.ident_fis_jur = item.ident_fis_jur
                                   AND x08.num_docfis = item.num_docfis
                                   AND x08.serie_docfis = item.serie_docfis
                                   AND x08.sub_serie_docfis = item.sub_serie_docfis
                                   AND x08.discri_item = item.discri_item
                                   AND x08.cod_tributo = 'ICMS' )
                                  aliq_icms
                         FROM msaf.x08_itens_merc item
                            , msaf.x07_docto_fiscal capa
                            , x2013_produto x2013
                            , x2005_tipo_docto x2005
                            , x04_pessoa_fis_jur x04
                            , x2012_cod_fiscal x2012
                            , x2006_natureza_op x2006
                        WHERE 1 = 1
                          AND capa.cod_empresa = item.cod_empresa
                          AND capa.cod_estab = item.cod_estab
                          AND capa.data_fiscal = item.data_fiscal
                          AND capa.movto_e_s = item.movto_e_s
                          AND capa.norm_dev = item.norm_dev
                          AND capa.ident_docto = item.ident_docto
                          AND capa.ident_fis_jur = item.ident_fis_jur
                          AND capa.num_docfis = item.num_docfis
                          AND capa.serie_docfis = item.serie_docfis
                          AND capa.sub_serie_docfis = item.sub_serie_docfis
                          AND capa.ident_docto = x2005.ident_docto
                          AND capa.ident_fis_jur = x04.ident_fis_jur
                          AND item.ident_cfo = x2012.ident_cfo
                          AND item.ident_natureza_op = x2006.ident_natureza_op
                          AND item.ident_produto = x2013.ident_produto
                          AND capa.situacao = 'N'
                          AND capa.movto_e_s <> '9'
                          AND capa.data_fiscal BETWEEN v_data_inicial AND v_data_final
                          AND capa.norm_dev = '1' -- verificar como tratar devolucao, tratar como entrada na saida e saida na entrada?
                          AND x2006.cod_natureza_op IN ( 'IST'
                                                       , 'REV' )
                          AND capa.cod_estab = pcod_estab /*(v_cod_estab)*/
                          AND capa.cod_empresa = mcod_empresa ) LOOP
                INSERT /*+ APPEND */
                      INTO  cust_prodepe_nf_entrada ( cod_empresa
                                                    , cod_estab
                                                    , data_fiscal
                                                    , movto_e_s
                                                    , norm_dev
                                                    , ident_docto
                                                    , ident_fis_jur
                                                    , num_docfis
                                                    , serie_docfis
                                                    , sub_serie_docfis
                                                    , ident_produto
                                                    , ind_produto
                                                    , cod_produto
                                                    , discri_item
                                                    , num_controle_docto
                                                    , data_emissao
                                                    , quantidade
                                                    , vl_unit
                                                    , vl_total
                                                    , vl_icms
                                                    , aliq_icms )
                     VALUES ( c.cod_empresa
                            , c.cod_estab
                            , c.data_fiscal
                            , c.movto_e_s
                            , c.norm_dev
                            , c.ident_docto
                            , c.ident_fis_jur
                            , c.num_docfis
                            , c.serie_docfis
                            , c.sub_serie_docfis
                            , c.ident_produto
                            , c.ind_produto
                            , c.cod_produto
                            , c.discri_item
                            , c.num_controle_docto
                            , c.data_emissao
                            , c.quantidade
                            , c.vl_unit
                            , c.vl_total
                            , c.vl_icms
                            , c.aliq_icms );

                COMMIT;
            END LOOP;

            -- Limpa tabela auxiliar
            DELETE FROM cust_gtt_nf_saida;

            COMMIT;

            DELETE FROM cust_gtt_nf_entrada;

            COMMIT;

            -- limpa tabela definitiva
            FOR d IN ( SELECT ROWID v_rowid
                         FROM msafi.cust_nf_saida_entrada
                        WHERE 1 = 1
                          AND data_fiscal BETWEEN v_data_inicial AND v_data_final
                          AND cod_estab = pcod_estab /*(v_cod_estab)*/
                          AND cod_empresa = mcod_empresa ) LOOP
                DELETE msafi.cust_nf_saida_entrada
                 WHERE ROWID = d.v_rowid;

                COMMIT;
            END LOOP;

            -- Recupera itens de saida
            FOR c IN ( SELECT capa.cod_empresa
                            , capa.cod_estab
                            , capa.data_fiscal
                            , capa.movto_e_s
                            , capa.norm_dev
                            , capa.ident_docto
                            , capa.ident_fis_jur
                            , capa.num_docfis
                            , capa.serie_docfis
                            , capa.sub_serie_docfis
                            , item.discri_item
                            , capa.num_controle_docto
                            , capa.data_emissao
                            , item.ident_produto
                            , x2013.ind_produto
                            , x2013.cod_produto
                            , item.quantidade
                            , item.vlr_unit vl_unit
                            , item.vlr_item vl_total
                            , NVL ( ( SELECT x08.vlr_tributo
                                        FROM x08_trib_merc x08
                                       WHERE x08.cod_empresa = item.cod_empresa
                                         AND x08.cod_estab = item.cod_estab
                                         AND x08.data_fiscal = item.data_fiscal
                                         AND x08.movto_e_s = item.movto_e_s
                                         AND x08.norm_dev = item.norm_dev
                                         AND x08.ident_docto = item.ident_docto
                                         AND x08.ident_fis_jur = item.ident_fis_jur
                                         AND x08.num_docfis = item.num_docfis
                                         AND x08.serie_docfis = item.serie_docfis
                                         AND x08.sub_serie_docfis = item.sub_serie_docfis
                                         AND x08.discri_item = item.discri_item
                                         AND x08.cod_tributo = 'ICMS' )
                                  , 0 )
                                  vl_icms
                            , ( SELECT x08.aliq_tributo
                                  FROM x08_trib_merc x08
                                 WHERE x08.cod_empresa = item.cod_empresa
                                   AND x08.cod_estab = item.cod_estab
                                   AND x08.data_fiscal = item.data_fiscal
                                   AND x08.movto_e_s = item.movto_e_s
                                   AND x08.norm_dev = item.norm_dev
                                   AND x08.ident_docto = item.ident_docto
                                   AND x08.ident_fis_jur = item.ident_fis_jur
                                   AND x08.num_docfis = item.num_docfis
                                   AND x08.serie_docfis = item.serie_docfis
                                   AND x08.sub_serie_docfis = item.sub_serie_docfis
                                   AND x08.discri_item = item.discri_item
                                   AND x08.cod_tributo = 'ICMS' )
                                  aliq_icms
                         FROM msaf.x08_itens_merc item
                            , msaf.x07_docto_fiscal capa
                            , x2013_produto x2013
                            , x2005_tipo_docto x2005
                            , x04_pessoa_fis_jur x04
                            , x2012_cod_fiscal x2012
                            , x2006_natureza_op x2006
                        WHERE 1 = 1
                          AND capa.cod_empresa = item.cod_empresa
                          AND capa.cod_estab = item.cod_estab
                          AND capa.data_fiscal = item.data_fiscal
                          AND capa.movto_e_s = item.movto_e_s
                          AND capa.norm_dev = item.norm_dev
                          AND capa.ident_docto = item.ident_docto
                          AND capa.ident_fis_jur = item.ident_fis_jur
                          AND capa.num_docfis = item.num_docfis
                          AND capa.serie_docfis = item.serie_docfis
                          AND capa.sub_serie_docfis = item.sub_serie_docfis
                          AND capa.ident_docto = x2005.ident_docto
                          AND capa.ident_fis_jur = x04.ident_fis_jur
                          AND item.ident_cfo = x2012.ident_cfo
                          AND item.ident_natureza_op = x2006.ident_natureza_op
                          AND item.ident_produto = x2013.ident_produto
                          AND capa.situacao = 'N'
                          AND capa.movto_e_s = '9'
                          AND capa.data_fiscal BETWEEN v_data_inicial AND v_data_final
                          AND capa.norm_dev = '1' -- verificar como tratar devolucao, tratar como entrada na saida e saida na entrada?
                          AND x2006.cod_natureza_op IN ( 'IST'
                                                       , 'REV' )
                          AND capa.cod_estab = pcod_estab /*(v_cod_estab)*/
                          AND capa.cod_empresa = mcod_empresa ) LOOP
                INSERT /*+ APPEND */
                      INTO  cust_gtt_nf_saida ( cod_empresa
                                              , cod_estab
                                              , data_fiscal
                                              , movto_e_s
                                              , norm_dev
                                              , ident_docto
                                              , ident_fis_jur
                                              , num_docfis
                                              , serie_docfis
                                              , sub_serie_docfis
                                              , ident_produto
                                              , ind_produto
                                              , cod_produto
                                              , discri_item
                                              , num_controle_docto
                                              , data_emissao
                                              , quantidade
                                              , vl_unit
                                              , vl_total
                                              , vl_icms
                                              , aliq_icms )
                     VALUES ( c.cod_empresa
                            , c.cod_estab
                            , c.data_fiscal
                            , c.movto_e_s
                            , c.norm_dev
                            , c.ident_docto
                            , c.ident_fis_jur
                            , c.num_docfis
                            , c.serie_docfis
                            , c.sub_serie_docfis
                            , c.ident_produto
                            , c.ind_produto
                            , c.cod_produto
                            , c.discri_item
                            , c.num_controle_docto
                            , c.data_emissao
                            , c.quantidade
                            , c.vl_unit
                            , c.vl_total
                            , c.vl_icms
                            , c.aliq_icms );

                COMMIT;
            END LOOP;

            -- Recupera itens de entrada
            FOR c IN ( SELECT cod_empresa
                            , cod_estab
                            , data_fiscal
                            , movto_e_s
                            , norm_dev
                            , ident_docto
                            , ident_fis_jur
                            , num_docfis
                            , serie_docfis
                            , sub_serie_docfis
                            , ident_produto
                            , ind_produto
                            , cod_produto
                            , discri_item
                            , num_controle_docto
                            , data_emissao
                            , quantidade
                            , vl_unit
                            , vl_total
                            , vl_icms
                            , aliq_icms
                         FROM cust_prodepe_nf_entrada
                        WHERE 1 = 1 ) LOOP
                INSERT /*+ APPEND */
                      INTO  cust_gtt_nf_entrada ( cod_empresa
                                                , cod_estab
                                                , data_fiscal
                                                , movto_e_s
                                                , norm_dev
                                                , ident_docto
                                                , ident_fis_jur
                                                , num_docfis
                                                , serie_docfis
                                                , sub_serie_docfis
                                                , ident_produto
                                                , ind_produto
                                                , cod_produto
                                                , discri_item
                                                , num_controle_docto
                                                , data_emissao
                                                , quantidade
                                                , vl_unit
                                                , vl_total
                                                , vl_icms
                                                , aliq_icms )
                     VALUES ( c.cod_empresa
                            , c.cod_estab
                            , c.data_fiscal
                            , c.movto_e_s
                            , c.norm_dev
                            , c.ident_docto
                            , c.ident_fis_jur
                            , c.num_docfis
                            , c.serie_docfis
                            , c.sub_serie_docfis
                            , c.ident_produto
                            , c.ind_produto
                            , c.cod_produto
                            , c.discri_item
                            , c.num_controle_docto
                            , c.data_emissao
                            , c.quantidade
                            , c.vl_unit
                            , c.vl_total
                            , c.vl_icms
                            , c.aliq_icms );

                COMMIT;
            END LOOP;

            -- recupera as saidas
            FOR s IN ( SELECT cod_empresa
                            , cod_estab
                            , data_fiscal
                            , movto_e_s
                            , norm_dev
                            , ident_docto
                            , ident_fis_jur
                            , num_docfis
                            , serie_docfis
                            , sub_serie_docfis
                            , ident_produto
                            , ind_produto
                            , cod_produto
                            , discri_item
                            , num_controle_docto
                            , data_emissao
                            , quantidade
                            , vl_unit
                            , vl_total
                            , vl_icms
                            , aliq_icms
                         FROM cust_gtt_nf_saida ) LOOP
                -- Atualiza quantidade a recuperar
                v_qtde_saldo_saida := s.quantidade;

                -- recupera as entradas
                FOR e IN ( SELECT   cod_empresa
                                  , cod_estab
                                  , data_fiscal
                                  , movto_e_s
                                  , norm_dev
                                  , ident_docto
                                  , ident_fis_jur
                                  , num_docfis
                                  , serie_docfis
                                  , sub_serie_docfis
                                  , ident_produto
                                  , ind_produto
                                  , cod_produto
                                  , discri_item
                                  , num_controle_docto
                                  , data_emissao
                                  , quantidade
                                  , vl_unit
                                  , vl_total
                                  , vl_icms
                                  , aliq_icms
                               FROM cust_gtt_nf_entrada
                              WHERE 1 = 1
                                AND cod_produto = s.cod_produto
                                AND ind_produto = s.ind_produto
                                AND data_fiscal <= s.data_fiscal
                           ORDER BY num_controle_docto ) LOOP
                    -- verifica se ja atingiu a quantidade que representa a saita
                    IF v_qtde_saldo_saida = 0 THEN
                        EXIT;
                    END IF;

                    -- verifica quantidade utilizada em outras saidas
                    SELECT NVL ( SUM ( util.quantidade_utilizada_e ), 0 )
                      INTO v_qtde_utilizada
                      FROM msafi.cust_nf_saida_entrada util
                     WHERE 1 = 1
                       AND e.cod_empresa = util.cod_empresa_e
                       AND e.cod_estab = util.cod_estab_e
                       AND e.data_fiscal = util.data_fiscal_e
                       AND e.movto_e_s = util.movto_e_s_e
                       AND e.norm_dev = util.norm_dev_e
                       AND e.ident_docto = util.ident_docto_e
                       AND e.ident_fis_jur = util.ident_fis_jur_e
                       AND e.num_docfis = util.num_docfis_e
                       AND e.serie_docfis = util.serie_docfis_e
                       AND e.sub_serie_docfis = util.sub_serie_docfis_e
                       AND e.discri_item = util.discri_item_e;

                    -- verifica se existe quantidade de entrada nao utilizada
                    IF e.quantidade > v_qtde_utilizada THEN
                        -- verifica se a quantidade de entrada nao utilizado eh maior que a quantidade de saida necessaria
                        IF ( e.quantidade - v_qtde_utilizada ) > v_qtde_saldo_saida THEN
                            -- se sim atribui o valor da quantidade de saida necessaria
                            v_qtde_utilizada_saida := v_qtde_saldo_saida;
                        ELSE
                            -- se nao atribui o valor da quantidade restante de entrada e busca outra nota de entrada
                            v_qtde_utilizada_saida := ( e.quantidade - v_qtde_utilizada );
                        END IF;

                        -- atualiza saldo de saida com valor encontrado
                        v_qtde_saldo_saida := v_qtde_saldo_saida - v_qtde_utilizada_saida;

                        -- insere registro de relacionamento de nota de saida com nota de entrada
                        INSERT /*+ APPEND */
                              INTO  msafi.cust_nf_saida_entrada ( cod_empresa
                                                                , cod_estab
                                                                , data_fiscal
                                                                , movto_e_s
                                                                , norm_dev
                                                                , ident_docto
                                                                , ident_fis_jur
                                                                , num_docfis
                                                                , serie_docfis
                                                                , sub_serie_docfis
                                                                , ident_produto
                                                                , ind_produto
                                                                , cod_produto
                                                                , discri_item
                                                                , num_controle_docto
                                                                , data_emissao
                                                                , quantidade
                                                                , vl_unit
                                                                , vl_total
                                                                , vl_icms
                                                                , aliq_icms
                                                                , cod_empresa_e
                                                                , cod_estab_e
                                                                , data_fiscal_e
                                                                , movto_e_s_e
                                                                , norm_dev_e
                                                                , ident_docto_e
                                                                , ident_fis_jur_e
                                                                , num_docfis_e
                                                                , serie_docfis_e
                                                                , sub_serie_docfis_e
                                                                , discri_item_e
                                                                , num_controle_docto_e
                                                                , data_emissao_e
                                                                , ident_produto_e
                                                                , quantidade_e
                                                                , vl_unit_e
                                                                , vl_total_e
                                                                , vl_icms_e
                                                                , aliq_icms_e
                                                                , quantidade_utilizada_e
                                                                , quantidade_nao_encontrada_e )
                             VALUES ( s.cod_empresa
                                    , s.cod_estab
                                    , s.data_fiscal
                                    , s.movto_e_s
                                    , s.norm_dev
                                    , s.ident_docto
                                    , s.ident_fis_jur
                                    , s.num_docfis
                                    , s.serie_docfis
                                    , s.sub_serie_docfis
                                    , s.ident_produto
                                    , s.ind_produto
                                    , s.cod_produto
                                    , s.discri_item
                                    , s.num_controle_docto
                                    , s.data_emissao
                                    , s.quantidade
                                    , s.vl_unit
                                    , s.vl_total
                                    , s.vl_icms
                                    , s.aliq_icms
                                    , e.cod_empresa
                                    , e.cod_estab
                                    , e.data_fiscal
                                    , e.movto_e_s
                                    , e.norm_dev
                                    , e.ident_docto
                                    , e.ident_fis_jur
                                    , e.num_docfis
                                    , e.serie_docfis
                                    , e.sub_serie_docfis
                                    , e.discri_item
                                    , e.num_controle_docto
                                    , e.data_emissao
                                    , e.ident_produto
                                    , e.quantidade
                                    , e.vl_unit
                                    , e.vl_total
                                    , e.vl_icms
                                    , e.aliq_icms
                                    , v_qtde_utilizada_saida
                                    , --quantidade_utilizada_e
                                     NULL );

                        COMMIT;
                    END IF;
                END LOOP;

                -- insere registro de saida com valor utilizado 0 caso nao encontre valor de entrada
                IF v_qtde_saldo_saida > 0 THEN
                    INSERT /*+ APPEND */
                          INTO  msafi.cust_nf_saida_entrada ( cod_empresa
                                                            , cod_estab
                                                            , data_fiscal
                                                            , movto_e_s
                                                            , norm_dev
                                                            , ident_docto
                                                            , ident_fis_jur
                                                            , num_docfis
                                                            , serie_docfis
                                                            , sub_serie_docfis
                                                            , ident_produto
                                                            , ind_produto
                                                            , cod_produto
                                                            , discri_item
                                                            , num_controle_docto
                                                            , data_emissao
                                                            , quantidade
                                                            , vl_unit
                                                            , vl_total
                                                            , vl_icms
                                                            , aliq_icms
                                                            , cod_empresa_e
                                                            , cod_estab_e
                                                            , data_fiscal_e
                                                            , movto_e_s_e
                                                            , norm_dev_e
                                                            , ident_docto_e
                                                            , ident_fis_jur_e
                                                            , num_docfis_e
                                                            , serie_docfis_e
                                                            , sub_serie_docfis_e
                                                            , discri_item_e
                                                            , num_controle_docto_e
                                                            , data_emissao_e
                                                            , ident_produto_e
                                                            , quantidade_e
                                                            , vl_unit_e
                                                            , vl_total_e
                                                            , vl_icms_e
                                                            , aliq_icms_e
                                                            , quantidade_utilizada_e
                                                            , quantidade_nao_encontrada_e )
                         VALUES ( s.cod_empresa
                                , s.cod_estab
                                , s.data_fiscal
                                , s.movto_e_s
                                , s.norm_dev
                                , s.ident_docto
                                , s.ident_fis_jur
                                , s.num_docfis
                                , s.serie_docfis
                                , s.sub_serie_docfis
                                , s.ident_produto
                                , s.ind_produto
                                , s.cod_produto
                                , s.discri_item
                                , s.num_controle_docto
                                , s.data_emissao
                                , s.quantidade
                                , s.vl_unit
                                , s.vl_total
                                , s.vl_icms
                                , s.aliq_icms
                                , NULL
                                , -- cod_empresa,
                                 NULL
                                , -- cod_estab,
                                 NULL
                                , -- data_fiscal,
                                 NULL
                                , -- movto_e_s,
                                 NULL
                                , -- norm_dev,
                                 NULL
                                , -- ident_docto,
                                 NULL
                                , -- ident_fis_jur,
                                 NULL
                                , -- num_docfis,
                                 NULL
                                , -- serie_docfis,
                                 NULL
                                , -- sub_serie_docfis,
                                 NULL
                                , -- discri_item,
                                 NULL
                                , -- num_controle_docto
                                 NULL
                                , -- data_emissao
                                 NULL
                                , -- ident_produto
                                 NULL
                                , -- quantidade,
                                 NULL
                                , -- vl_unit,
                                 NULL
                                , -- vl_total,
                                 NULL
                                , -- vl_icms,
                                 NULL
                                , -- aliq_icms,
                                 NULL
                                , -- quantidade_utilizada_e
                                 v_qtde_saldo_saida --quantidade_nao_encontrada_e
                                                    );

                    COMMIT;
                END IF;
            END LOOP;
        --  END LOOP;
        END IF;

        --=================================================================================
        -- FIM
        --=================================================================================

        -- relatorio de notas fiscais emitidas
        IF v_relatotorio_nf_emitidas = 'S' THEN
            v_tipo_arq := 1;
            --Tela DW
            lib_proc.add_tipo ( pproc_id => mproc_id
                              , ptipo => v_tipo_arq
                              , ptitulo =>    'PRODEPE_'
                                           || TO_CHAR ( pperiodo
                                                      , 'YYYYMM' )
                                           || '_'
                                           || 'NOTA_FISCAL_EMITIDA'
                              , ptipo_arq => 2 );

            cabecalho ( pcod_estab
                      , v_data_hora_ini
                      , v_data_inicial
                      , v_tipo_arq );

            vs_mlinha := CHR ( 10 );
            lib_proc.add ( vs_mlinha
                         , NULL
                         , NULL
                         , v_tipo_arq );

            vs_mlinha := NULL;
            vs_mlinha := vs_mlinha || 'cod_empresa' || '|';
            vs_mlinha := vs_mlinha || 'cod_estab' || '|';
            vs_mlinha := vs_mlinha || 'movto_e_s' || '|';
            vs_mlinha := vs_mlinha || 'data_emissao' || '|';
            vs_mlinha := vs_mlinha || 'mes' || '|';
            vs_mlinha := vs_mlinha || 'doc_number' || '|';
            vs_mlinha := vs_mlinha || 'nf' || '|';
            vs_mlinha := vs_mlinha || 'item' || '|';
            vs_mlinha := vs_mlinha || 'quantidade' || '|';
            vs_mlinha := vs_mlinha || 'vl_unit' || '|';
            vs_mlinha := vs_mlinha || 'vl_total' || '|';
            vs_mlinha := vs_mlinha || 'aliq_icms' || '|';
            vs_mlinha := vs_mlinha || 'vl_icms' || '|';

            lib_proc.add ( vs_mlinha
                         , NULL
                         , NULL
                         , v_tipo_arq );

            -- FOR v_cod_estab IN pcod_estab.FIRST .. pcod_estab.LAST LOOP
            -- inicio do relatorio
            FOR c IN ( SELECT   cod_empresa
                              , DECODE ( movto_e_s, '9', cod_estab, cod_estab_x04 ) cod_estab
                              , data_emissao
                              , data_fiscal
                              , mes
                              , DECODE ( movto_e_s, '9', 'S', 'E' ) movto_e_s
                              , ident_docto
                              , x04.cod_fis_jur
                              , x04.razao_social
                              , doc_number
                              , nf
                              , x2013.cod_produto
                              , x2013.descricao descricao_produto
                              , quantidade
                              , vl_unit
                              , vl_total
                              , aliq_icms
                              , vl_icms
                           FROM (SELECT DISTINCT cod_empresa
                                               , cod_estab
                                               , data_emissao
                                               , data_fiscal
                                               , TO_CHAR ( data_fiscal
                                                         , 'mm/yyyy' )
                                                     mes
                                               , movto_e_s
                                               , norm_dev
                                               , ident_docto
                                               , ident_fis_jur
                                               , num_controle_docto doc_number
                                               , num_docfis nf
                                               , serie_docfis
                                               , sub_serie_docfis
                                               , ident_produto
                                               , ind_produto
                                               , cod_produto
                                               , discri_item
                                               , quantidade
                                               , vl_unit
                                               , vl_total
                                               , vl_icms
                                               , aliq_icms
                                   FROM msafi.cust_nf_saida_entrada t
                                  WHERE data_fiscal BETWEEN v_data_inicial AND v_data_final
                                    AND cod_estab = pcod_estab /*(v_cod_estab)*/
                                 UNION ALL
                                 SELECT cod_empresa
                                      , cod_estab
                                      , data_emissao
                                      , data_fiscal
                                      , TO_CHAR ( data_fiscal
                                                , 'mm/yyyy' )
                                            mes
                                      , movto_e_s
                                      , norm_dev
                                      , ident_docto
                                      , ident_fis_jur
                                      , num_controle_docto doc_number
                                      , num_docfis nf
                                      , serie_docfis
                                      , sub_serie_docfis
                                      , ident_produto
                                      , ind_produto
                                      , cod_produto
                                      , discri_item
                                      , quantidade
                                      , vl_unit
                                      , vl_total
                                      , vl_icms
                                      , aliq_icms
                                   FROM msaf.cust_prodepe_nf_entrada t
                                  WHERE data_fiscal BETWEEN v_data_inicial AND v_data_final
                                    AND cod_estab = pcod_estab /*(v_cod_estab)*/
                                                              ) aux
                              , x04_pessoa_fis_jur x04
                              , x2013_produto x2013
                              , (SELECT   cgc
                                        , MAX ( cod_estab ) cod_estab_x04
                                     FROM estabelecimento
                                 GROUP BY cgc) cod_estab_x04
                          WHERE aux.ident_fis_jur = x04.ident_fis_jur
                            AND aux.ident_produto = x2013.ident_produto
                            AND cod_estab_x04.cgc(+) = x04.cpf_cgc
                       ORDER BY data_fiscal
                              , doc_number ) LOOP
                vs_mlinha := NULL;
                vs_mlinha := vs_mlinha || c.cod_empresa || '|';
                vs_mlinha := vs_mlinha || c.cod_estab || '|';
                vs_mlinha := vs_mlinha || c.movto_e_s || '|';
                vs_mlinha :=
                       vs_mlinha
                    || TO_CHAR ( c.data_emissao
                               , 'dd/mm/yyyy' )
                    || '|';
                vs_mlinha := vs_mlinha || c.mes || '|';
                vs_mlinha := vs_mlinha || c.doc_number || '|';
                vs_mlinha := vs_mlinha || c.nf || '|';
                vs_mlinha := vs_mlinha || c.descricao_produto || '|';
                vs_mlinha := vs_mlinha || c.quantidade || '|';
                vs_mlinha :=
                       vs_mlinha
                    || LTRIM ( RTRIM ( TO_CHAR ( NVL ( c.vl_unit, 0 )
                                               ,    '999999990D'
                                                 || RPAD ( '0'
                                                         , 2
                                                         , '0' )
                                               , 'nls_numeric_characters = '',.''' ) ) )
                    || '|';
                vs_mlinha :=
                       vs_mlinha
                    || LTRIM ( RTRIM ( TO_CHAR ( NVL ( c.vl_total, 0 )
                                               ,    '999999990D'
                                                 || RPAD ( '0'
                                                         , 2
                                                         , '0' )
                                               , 'nls_numeric_characters = '',.''' ) ) )
                    || '|';
                vs_mlinha := vs_mlinha || c.aliq_icms || '|';
                vs_mlinha :=
                       vs_mlinha
                    || LTRIM ( RTRIM ( TO_CHAR ( NVL ( c.vl_icms, 0 )
                                               ,    '999999990D'
                                                 || RPAD ( '0'
                                                         , 2
                                                         , '0' )
                                               , 'nls_numeric_characters = '',.''' ) ) )
                    || '|';

                lib_proc.add ( vs_mlinha
                             , NULL
                             , NULL
                             , v_tipo_arq );
            END LOOP;
        -- END LOOP;

        END IF;

        -- relatorio analitico de rateio
        IF v_relatotorio_analitico_rateio = 'S' THEN
            v_tipo_arq := 2;

            --Tela DW
            lib_proc.add_tipo ( pproc_id => mproc_id
                              , ptipo => 2
                              , ptitulo =>    'PRODEPE_'
                                           || TO_CHAR ( pperiodo
                                                      , 'YYYYMM' )
                                           || '_'
                                           || 'ANALITICO_RATEIO'
                              , ptipo_arq => v_tipo_arq );

            cabecalho ( pcod_estab
                      , v_data_hora_ini
                      , v_data_inicial
                      , 2 );

            vs_mlinha := CHR ( 10 );
            lib_proc.add ( vs_mlinha
                         , NULL
                         , NULL
                         , v_tipo_arq );

            vs_mlinha := NULL;
            vs_mlinha := vs_mlinha || 'chave' || '|';
            vs_mlinha := vs_mlinha || 'item' || '|';
            vs_mlinha := vs_mlinha || 'cod_empresa' || '|';
            vs_mlinha := vs_mlinha || 'cod_estab' || '|';
            vs_mlinha := vs_mlinha || 'movto_e_s' || '|';
            vs_mlinha := vs_mlinha || 'mes' || '|';
            vs_mlinha := vs_mlinha || 'data_emissao' || '|';
            vs_mlinha := vs_mlinha || 'doc_number' || '|';
            vs_mlinha := vs_mlinha || 'nf' || '|';
            vs_mlinha := vs_mlinha || 'item' || '|';
            vs_mlinha := vs_mlinha || 'quantidade' || '|';
            vs_mlinha := vs_mlinha || 'vl_unit' || '|';
            vs_mlinha := vs_mlinha || 'vl_total' || '|';
            vs_mlinha := vs_mlinha || 'aliq_icms' || '|';
            vs_mlinha := vs_mlinha || 'vl_icms' || '|';
            vs_mlinha := vs_mlinha || 'base icms proporcional' || '|';
            vs_mlinha := vs_mlinha || 'vl icms proporcional' || '|';
            vs_mlinha := vs_mlinha || 'quantidade utilizada' || '|';
            vs_mlinha := vs_mlinha || 'vl total venda' || '|';
            vs_mlinha := vs_mlinha || 'aliquota venda' || '|';
            vs_mlinha := vs_mlinha || 'vl icms' || '|';
            vs_mlinha := vs_mlinha || 'diferenca icms' || '|';

            lib_proc.add ( vs_mlinha
                         , NULL
                         , NULL
                         , v_tipo_arq );

            -- FOR v_cod_estab IN pcod_estab.FIRST .. pcod_estab.LAST LOOP
            -- inicio do relatorio
            FOR c
                IN ( SELECT   chave
                            , item
                            , DECODE ( movto_e_s, '9', '', '-->' ) x
                            , cod_empresa
                            , cod_estab
                            , data_fiscal
                            , mes
                            , DECODE ( movto_e_s, '9', 'S', 'E' ) movto_e_s
                            , ident_docto
                            , x04.cod_fis_jur
                            , x04.razao_social
                            , doc_number
                            , nf
                            , data_emissao
                            , x2013.cod_produto
                            , x2013.descricao descricao_produto
                            , quantidade
                            , vl_unit
                            , vl_total
                            , aliq_icms
                            , vl_icms
                            , base_icms_proporcional
                            , valor_icms_proporcional
                            , (   MAX ( vl_unit_venda )
                                      OVER ( PARTITION BY v_rank
                                                        , v_rank_item )
                                * quantidade_utilizada_e )
                                  vl_venda
                            , (   MAX ( aliq_venda )
                                      OVER ( PARTITION BY v_rank
                                                        , v_rank_item )
                                * quantidade_utilizada_e )
                                  aliq_venda
                            , (   base_icms_proporcional
                                * (   MAX ( aliq_venda )
                                          OVER ( PARTITION BY v_rank
                                                            , v_rank_item )
                                    / 100 )
                                * quantidade_utilizada_e )
                                  vlr_icms_calculado
                            , (   (   base_icms_proporcional
                                    * (   MAX ( aliq_venda )
                                              OVER ( PARTITION BY v_rank
                                                                , v_rank_item )
                                        / 100 )
                                    * quantidade_utilizada_e )
                                - valor_icms_proporcional )
                                  diferença_icms
                            , quantidade_utilizada_e
                            , quantidade_nao_encontrada_e
                         FROM ( SELECT DISTINCT num_controle_docto chave
                                              , discri_item item
                                              , cod_empresa
                                              , cod_estab
                                              , data_fiscal
                                              , TO_CHAR ( data_fiscal
                                                        , 'mm/yyyy' )
                                                    mes
                                              , movto_e_s
                                              , norm_dev
                                              , ident_docto
                                              , ident_fis_jur
                                              , num_controle_docto doc_number
                                              , num_docfis nf
                                              , serie_docfis
                                              , sub_serie_docfis
                                              , data_emissao
                                              , ident_produto
                                              , ind_produto
                                              , cod_produto
                                              , discri_item
                                              , quantidade
                                              , vl_unit
                                              , vl_total
                                              , vl_icms
                                              , aliq_icms
                                              , vl_unit vl_unit_venda
                                              , vl_icms vl_icms_venda
                                              , aliq_icms aliq_venda
                                              , SUM ( NVL ( vl_unit_e * quantidade_utilizada_e, 0 ) )
                                                    OVER ( PARTITION BY cod_empresa
                                                                      , cod_estab
                                                                      , data_fiscal
                                                                      , movto_e_s
                                                                      , norm_dev
                                                                      , ident_docto
                                                                      , ident_fis_jur
                                                                      , num_controle_docto
                                                                      , num_docfis
                                                                      , serie_docfis
                                                                      , sub_serie_docfis
                                                                      , discri_item )
                                                    base_icms_proporcional
                                              , SUM ( NVL ( vl_icms_e / quantidade_e * quantidade_utilizada_e, 0 ) )
                                                    OVER ( PARTITION BY cod_empresa
                                                                      , cod_estab
                                                                      , data_fiscal
                                                                      , movto_e_s
                                                                      , norm_dev
                                                                      , ident_docto
                                                                      , ident_fis_jur
                                                                      , num_controle_docto
                                                                      , num_docfis
                                                                      , serie_docfis
                                                                      , sub_serie_docfis
                                                                      , discri_item )
                                                    valor_icms_proporcional
                                              , SUM ( NVL ( quantidade_utilizada_e, 0 ) )
                                                    OVER ( PARTITION BY cod_empresa
                                                                      , cod_estab
                                                                      , data_fiscal
                                                                      , movto_e_s
                                                                      , norm_dev
                                                                      , ident_docto
                                                                      , ident_fis_jur
                                                                      , num_controle_docto
                                                                      , num_docfis
                                                                      , serie_docfis
                                                                      , sub_serie_docfis
                                                                      , discri_item )
                                                    quantidade_utilizada_e
                                              , SUM ( NVL ( quantidade_nao_encontrada_e, 0 ) )
                                                    OVER ( PARTITION BY cod_empresa
                                                                      , cod_estab
                                                                      , data_fiscal
                                                                      , movto_e_s
                                                                      , norm_dev
                                                                      , ident_docto
                                                                      , ident_fis_jur
                                                                      , num_controle_docto
                                                                      , num_docfis
                                                                      , serie_docfis
                                                                      , sub_serie_docfis
                                                                      , discri_item )
                                                    quantidade_nao_encontrada_e
                                              , DENSE_RANK ( )
                                                    OVER ( ORDER BY
                                                               cod_empresa
                                                             , cod_estab
                                                             , data_fiscal
                                                             , movto_e_s
                                                             , norm_dev
                                                             , ident_docto
                                                             , t.ident_fis_jur
                                                             , num_controle_docto
                                                             , num_docfis
                                                             , serie_docfis
                                                             , sub_serie_docfis )
                                                    v_rank
                                              , DENSE_RANK ( )
                                                    OVER ( PARTITION BY cod_empresa
                                                                      , cod_estab
                                                                      , data_fiscal
                                                                      , movto_e_s
                                                                      , norm_dev
                                                                      , ident_docto
                                                                      , t.ident_fis_jur
                                                                      , num_controle_docto
                                                                      , num_docfis
                                                                      , serie_docfis
                                                                      , sub_serie_docfis
                                                           ORDER BY discri_item )
                                                    v_rank_item
                                  FROM msafi.cust_nf_saida_entrada t
                                 WHERE data_fiscal BETWEEN v_data_inicial AND v_data_final
                                   AND cod_estab = pcod_estab
                                UNION ALL
                                SELECT num_controle_docto chave
                                     , discri_item item
                                     , cod_empresa_e
                                     , estab_x04.cod_estab_x04 cod_estab_e
                                     , data_fiscal_e
                                     , TO_CHAR ( data_fiscal_e
                                               , 'mm/yyyy' )
                                           mes
                                     , movto_e_s_e
                                     , norm_dev_e
                                     , ident_docto_e
                                     , ident_fis_jur_e
                                     , num_controle_docto_e doc_number
                                     , num_docfis_e nf_e
                                     , serie_docfis_e
                                     , sub_serie_docfis_e
                                     , data_emissao_e
                                     , ident_produto_e
                                     , ind_produto
                                     , cod_produto
                                     , discri_item_e
                                     , quantidade_e
                                     , vl_unit_e
                                     , vl_total_e
                                     , vl_icms_e
                                     , aliq_icms_e
                                     , NULL vlr_unit_venda
                                     , NULL vlr_icms_venda
                                     , NULL aliq_venda
                                     , NVL ( vl_unit_e * quantidade_utilizada_e, 0 ) base_icms_proporcional
                                     , NVL ( vl_icms_e / quantidade_e * quantidade_utilizada_e, 0 )
                                           valor_icms_proporcional
                                     , NVL ( quantidade_utilizada_e, 0 )
                                     , 0
                                     , DENSE_RANK ( )
                                           OVER ( ORDER BY
                                                      cod_empresa
                                                    , cod_estab
                                                    , data_fiscal
                                                    , movto_e_s
                                                    , norm_dev
                                                    , ident_docto
                                                    , t.ident_fis_jur
                                                    , num_controle_docto
                                                    , num_docfis
                                                    , serie_docfis
                                                    , sub_serie_docfis )
                                           v_rank
                                     , DENSE_RANK ( )
                                           OVER ( PARTITION BY cod_empresa
                                                             , cod_estab
                                                             , data_fiscal
                                                             , movto_e_s
                                                             , norm_dev
                                                             , ident_docto
                                                             , t.ident_fis_jur
                                                             , num_controle_docto
                                                             , num_docfis
                                                             , serie_docfis
                                                             , sub_serie_docfis
                                                  ORDER BY discri_item )
                                           v_rank_item
                                  FROM msafi.cust_nf_saida_entrada t
                                     , x04_pessoa_fis_jur x04
                                     , (SELECT   cgc
                                               , MAX ( cod_estab ) cod_estab_x04
                                            FROM estabelecimento
                                        GROUP BY cgc) estab_x04
                                 WHERE x04.ident_fis_jur(+) = t.ident_fis_jur_e
                                   AND x04.cpf_cgc = estab_x04.cgc(+)
                                   AND data_fiscal BETWEEN v_data_inicial AND v_data_final
                                   AND cod_estab = pcod_estab ) aux
                            , x04_pessoa_fis_jur x04
                            , x2013_produto x2013
                        WHERE aux.ident_fis_jur = x04.ident_fis_jur
                          AND aux.ident_produto = x2013.ident_produto
                     ORDER BY v_rank
                            , v_rank_item
                            , movto_e_s DESC
                            , data_fiscal
                            , doc_number ) LOOP
                vs_mlinha := NULL;
                vs_mlinha := vs_mlinha || c.chave || '|';
                vs_mlinha := vs_mlinha || c.item || '|';
                vs_mlinha := vs_mlinha || c.cod_empresa || '|';
                vs_mlinha := vs_mlinha || c.cod_estab || '|';
                vs_mlinha := vs_mlinha || c.movto_e_s || '|';
                vs_mlinha :=
                       vs_mlinha
                    || TO_CHAR ( c.data_emissao
                               , 'dd/mm/yyyy' )
                    || '|';
                vs_mlinha := vs_mlinha || c.mes || '|';
                vs_mlinha := vs_mlinha || c.doc_number || '|';
                vs_mlinha := vs_mlinha || c.nf || '|';
                vs_mlinha := vs_mlinha || c.descricao_produto || '|';
                vs_mlinha := vs_mlinha || c.quantidade || '|';
                vs_mlinha :=
                       vs_mlinha
                    || LTRIM ( RTRIM ( TO_CHAR ( NVL ( c.vl_unit, 0 )
                                               ,    '999999990D'
                                                 || RPAD ( '0'
                                                         , 2
                                                         , '0' )
                                               , 'nls_numeric_characters = '',.''' ) ) )
                    || '|';
                vs_mlinha :=
                       vs_mlinha
                    || LTRIM ( RTRIM ( TO_CHAR ( NVL ( c.vl_total, 0 )
                                               ,    '999999990D'
                                                 || RPAD ( '0'
                                                         , 2
                                                         , '0' )
                                               , 'nls_numeric_characters = '',.''' ) ) )
                    || '|';
                vs_mlinha := vs_mlinha || c.aliq_icms || '|';
                vs_mlinha :=
                       vs_mlinha
                    || LTRIM ( RTRIM ( TO_CHAR ( NVL ( c.vl_icms, 0 )
                                               ,    '999999990D'
                                                 || RPAD ( '0'
                                                         , 2
                                                         , '0' )
                                               , 'nls_numeric_characters = '',.''' ) ) )
                    || '|';
                -- calculado
                vs_mlinha :=
                       vs_mlinha
                    || LTRIM ( RTRIM ( TO_CHAR ( NVL ( c.base_icms_proporcional, 0 )
                                               ,    '999999990D'
                                                 || RPAD ( '0'
                                                         , 2
                                                         , '0' )
                                               , 'nls_numeric_characters = '',.''' ) ) )
                    || '|';
                vs_mlinha :=
                       vs_mlinha
                    || LTRIM ( RTRIM ( TO_CHAR ( NVL ( c.valor_icms_proporcional, 0 )
                                               ,    '999999990D'
                                                 || RPAD ( '0'
                                                         , 2
                                                         , '0' )
                                               , 'nls_numeric_characters = '',.''' ) ) )
                    || '|';
                vs_mlinha := vs_mlinha || c.quantidade_utilizada_e || '|';
                vs_mlinha :=
                       vs_mlinha
                    || LTRIM ( RTRIM ( TO_CHAR ( NVL ( c.vl_venda, 0 )
                                               ,    '999999990D'
                                                 || RPAD ( '0'
                                                         , 2
                                                         , '0' )
                                               , 'nls_numeric_characters = '',.''' ) ) )
                    || '|';

                vs_mlinha := vs_mlinha || c.aliq_venda || '|';
                vs_mlinha :=
                       vs_mlinha
                    || LTRIM ( RTRIM ( TO_CHAR ( NVL ( c.vlr_icms_calculado, 0 )
                                               ,    '999999990D'
                                                 || RPAD ( '0'
                                                         , 2
                                                         , '0' )
                                               , 'nls_numeric_characters = '',.''' ) ) )
                    || '|';

                vs_mlinha :=
                       vs_mlinha
                    || LTRIM ( RTRIM ( TO_CHAR ( NVL ( c.diferença_icms, 0 )
                                               ,    '999999990D'
                                                 || RPAD ( '0'
                                                         , 2
                                                         , '0' )
                                               , 'nls_numeric_characters = '',.''' ) ) )
                    || '|';

                lib_proc.add ( vs_mlinha
                             , NULL
                             , NULL
                             , v_tipo_arq );
            END LOOP;
        -- END LOOP;

        END IF;

        -- relatorio sintetico de rateio
        IF v_relatotorio_sintetico_rateio = 'S' THEN
            --Tela DW
            lib_proc.add_tipo ( pproc_id => mproc_id
                              , ptipo => 3
                              , ptitulo =>    'PRODEPE_'
                                           || TO_CHAR ( pperiodo
                                                      , 'YYYYMM' )
                                           || '_'
                                           || 'SINTETICO_RATEIO'
                              , ptipo_arq => 2 );

            cabecalho ( pcod_estab
                      , v_data_hora_ini
                      , v_data_inicial
                      , 3 );
        END IF;

        lib_proc.close;
        RETURN mproc_id;
    EXCEPTION
        WHEN OTHERS THEN
            loga ( 'SQLERRM: ' || SQLERRM
                 , FALSE );
            lib_proc.add_log ( 'Erro não tratado: ' || dbms_utility.format_error_backtrace
                             , 1 );
            lib_proc.add_log ( 'SQLERRM: ' || SQLERRM
                             , 1 );
            lib_proc.add ( 'ERRO!'
                         , 1 );
            lib_proc.add ( ' '
                         , 1 );
            lib_proc.add ( dbms_utility.format_error_backtrace
                         , 1 );

            lib_proc.close;
            COMMIT;
            RETURN mproc_id;
    END;

    PROCEDURE loga ( p_i_texto IN VARCHAR2
                   , p_i_dttm IN BOOLEAN DEFAULT TRUE )
    IS
        vtexto VARCHAR2 ( 1024 );
    BEGIN
        IF p_i_dttm THEN
            vtexto :=
                SUBSTR (    TO_CHAR ( SYSDATE
                                    , 'DD/MM/YYYY HH24:MI:SS' )
                         || ' - '
                         || p_i_texto
                       , 1
                       , 1024 );
        ELSE
            vtexto :=
                SUBSTR ( p_i_texto
                       , 1
                       , 1024 );
        END IF;

        lib_proc.add_log ( vtexto
                         , 1 );
        COMMIT;
    END;

    PROCEDURE cabecalho ( pcod_estab VARCHAR2
                        , v_data_hora_ini VARCHAR2
                        , v_data_inicial DATE
                        , v_tipo VARCHAR2 )
    IS
        pnm_empresa VARCHAR2 ( 100 );
        pcnpj VARCHAR2 ( 100 );
        pdescricao VARCHAR2 ( 100 );
    BEGIN
        SELECT razao_social
             , DECODE ( cnpj
                      , NULL, NULL
                      , REPLACE ( REPLACE ( REPLACE ( TO_CHAR ( LPAD ( REPLACE ( cnpj
                                                                               , '' )
                                                                     , 14
                                                                     , '0' )
                                                              , '00,000,000,0000,00' )
                                                    , ','
                                                    , '.' )
                                          , ' ' )
                                ,    '.'
                                  || TRIM ( TO_CHAR ( TRUNC (   MOD ( LPAD ( cnpj
                                                                           , 14
                                                                           , '0' )
                                                                    , 1000000 )
                                                              / 100 )
                                                    , '0000' ) )
                                  || '.'
                                ,    '/'
                                  || TRIM ( TO_CHAR ( TRUNC (   MOD ( LPAD ( cnpj
                                                                           , 14
                                                                           , '0' )
                                                                    , 1000000 )
                                                              / 100 )
                                                    , '0000' ) )
                                  || '-' ) )
                   AS cnpj
          INTO pnm_empresa
             , pcnpj
          FROM empresa
         WHERE cod_empresa = mcod_empresa;

        --=================================================================================
        -- Cabeçalho do DW
        --=================================================================================
        vs_mlinha := NULL;
        vs_mlinha :=
            lib_str.w ( vs_mlinha
                      , 'Empresa: ' || mcod_empresa || ' - ' || pnm_empresa
                      , 1 );
        lib_proc.add ( vs_mlinha
                     , NULL
                     , NULL
                     , v_tipo );

        SELECT    a.cod_estab
               || ' - '
               || b.cod_estado
               || ' - '
               || a.cgc
               || ' - '
               || INITCAP ( a.bairro )
               || ' / '
               || INITCAP ( a.cidade )
          INTO pdescricao
          FROM estabelecimento a
             , estado b
         WHERE a.cod_empresa = mcod_empresa
           AND b.ident_estado = a.ident_estado
           AND cod_estab = pcod_estab;

        vs_mlinha := NULL;
        vs_mlinha :=
            lib_str.w ( vs_mlinha
                      , 'Estabelecimento: ' || pdescricao
                      , 1 );
        lib_proc.add ( vs_mlinha
                     , NULL
                     , NULL
                     , v_tipo );

        vs_mlinha := NULL;
        vs_mlinha :=
            lib_str.w ( vs_mlinha
                      , 'Data de Processamento : ' || v_data_hora_ini
                      , 1 );
        lib_proc.add ( vs_mlinha
                     , NULL
                     , NULL
                     , v_tipo );

        vs_mlinha := NULL;
        vs_mlinha :=
               'Período do processamento: '
            || TO_CHAR ( v_data_inicial
                       , 'MM/YYYY' );
        lib_proc.add ( vs_mlinha
                     , NULL
                     , NULL
                     , v_tipo );
    END cabecalho;
END msaf_prodepe_cproc;
/
SHOW ERRORS;
