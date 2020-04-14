Prompt Package Body DSP_SPED_CONTRIB_SCPT_CPROC;
--
-- DSP_SPED_CONTRIB_SCPT_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dsp_sped_contrib_scpt_cproc
IS
    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );
    BEGIN
        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        mcod_estab := lib_parametros.recuperar ( 'ESTABELECIMENTO' );
        musuario := lib_parametros.recuperar ( 'USUARIO' );

        -- PPARAM:      STRING PASSADA POR REFERÊNCIA;
        -- PTITULO:     TÍTULO DO PARÂMETRO MOSTRADO NA JANELA;
        -- PTIPO:       VARCHAR2, DATE, INTEGER;
        -- PCONTROLE:   MULTIPROC, TEXT, TEXTBOX, COMBOBOX, LISTBOX OU RADIOBUTTON;
        -- PMANDATORIO: S OU N, INDICANDO SE A INFORMAÇÃO DO PARÂMETRO É OBRIGATÓRIA;
        -- PDEFAULT:    VALOR PREENCHIDO AUTOMATICAMENTE NA ABERTURA DA JANELA;
        -- PMASCARA:    MÁSCARA PARA DIGITAÇÃO (EX: DD/MM/YYYY, 999999 OU ######);
        -- PVALORES:    SELECT (COMBOBOX OU MULTIPROC) OU COD1=DESC1,COD2=DESC2...
        -- PAPRESENTA:  S OU N, INDICANDO SE O PARÂMETRO DEVE SER MOSTRADO NA LISTAGEM DOS PROCESSOS;

        lib_proc.add_param ( pstr
                           , 'Script'
                           , --P_SCRIPT
                            'VARCHAR2'
                           , 'COMBOBOX'
                           , 'S'
                           , NULL
                           , NULL
                           , '
                            SELECT ''001'',''001 - Correções SPED PIS/COFINS'' FROM DUAL
                      UNION SELECT ''002'',''002 - Carga Bloco P - X185 e P210'' FROM DUAL
                           '  );

        lib_proc.add_param ( pstr
                           , 'Mes'
                           , --P_MES
                            'VARCHAR2'
                           , 'TEXTBOX'
                           , 'S'
                           , TO_NUMBER ( TO_CHAR (   TRUNC ( SYSDATE
                                                           , 'MM' )
                                                   - 1
                                                 , 'MM' ) )
                           , '##' );

        lib_proc.add_param ( pstr
                           , 'Ano'
                           , --P_ANO
                            'VARCHAR2'
                           , 'TEXTBOX'
                           , 'S'
                           , TO_NUMBER ( TO_CHAR (   TRUNC ( SYSDATE
                                                           , 'MM' )
                                                   - 1
                                                 , 'YYYY' ) )
                           , '####' );

        RETURN pstr;
    END; --FUNCTION PARAMETROS RETURN VARCHAR2 IS

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'SPED Contribuições - Scripts';
    END;

    FUNCTION tipo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Processos - Contabil';
    END;

    FUNCTION versao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'VERSAO 1.1';
    END;

    FUNCTION descricao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Scripts auxiliares do SPED contribuições';
    END;

    FUNCTION modulo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'PROCESSOS CUSTOMIZADOS';
    END;

    FUNCTION classificacao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'PROCESSOS CUSTOMIZADOS';
    END;

    FUNCTION orientacaopapel
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'landscape';
    END;

    PROCEDURE loga ( p_i_texto IN VARCHAR2
                   , tela IN BOOLEAN DEFAULT FALSE )
    IS
        vtexto VARCHAR2 ( 1024 );
    BEGIN
        vtexto :=
            SUBSTR (    TO_CHAR ( SYSDATE
                                , 'DD/MM/YYYY HH24:MI:SS' )
                     || ' - '
                     || p_i_texto
                   , 1
                   , 1024 );
        lib_proc.add_log ( vtexto
                         , 1 );

        IF tela THEN
            lib_proc.add ( vtexto );
        END IF;

        msafi.dsp_control.writelog ( 'INFO'
                                   , p_i_texto );
    END;

    PROCEDURE commit_loga ( n_script IN NUMBER
                          , s_name IN VARCHAR2
                          , n_count IN NUMBER
                          , s_detail IN VARCHAR2 )
    IS
    BEGIN
        IF n_count > 0 THEN
            --imprimir se tiver linhas afetadas
            loga (    TO_CHAR ( n_script
                              , 'fm00' )
                   || NVL ( s_name, ' ' )
                   || '-['
                   || s_detail
                   || '] - linhas: ['
                   || n_count
                   || ']' );
        END IF;

        COMMIT;
    END;

    FUNCTION executar ( p_script VARCHAR2
                      , p_mes VARCHAR2
                      , p_ano VARCHAR2 )
        RETURN INTEGER
    IS
        mproc_id INTEGER;

        v_sep VARCHAR2 ( 1 );

        v_proc_status NUMBER := 0;
        v_s_proc_status VARCHAR2 ( 16 );

        v_data_ini DATE
            := TO_DATE (    '01'
                         || TO_CHAR ( p_mes
                                    , 'FM00' )
                         || TO_CHAR ( p_ano
                                    , 'FM0000' )
                       , 'DDMMYYYY' );
        v_data_fim DATE
            := LAST_DAY ( TO_DATE (    '01'
                                    || TO_CHAR ( p_mes
                                               , 'FM00' )
                                    || TO_CHAR ( p_ano
                                               , 'FM0000' )
                                  , 'DDMMYYYY' ) );

        --Variaveis genericas
        v_text01 VARCHAR2 ( 256 );

        num_rows NUMBER;
        tot_rows NUMBER;
    BEGIN
        v_sep := '|';

        mproc_id :=
            lib_proc.new ( 'DSP_SPED_CONTRIB_SCPT_CPROC'
                         , 48
                         , 150 );
        lib_proc.add_tipo ( mproc_id
                          , 1
                          , 'Processo'
                          , 1
                          , pmaxcols => 150 );

        IF mcod_empresa IS NULL THEN
            lib_proc.add_log ( 'Código da empresa deve ser informado como parâmetro global.'
                             , 0 );
            lib_proc.close;
            RETURN mproc_id;
        END IF;

        msafi.dsp_control.createprocess ( 'CUST_ECFPC_SC_02' --P_I_PROCID            IN VARCHAR2             , --VARCHAR2(16)
                                        , 'CUSTOMIZADO MASTERSAF: SCRIPTS SPED CONTRIBUICOES' --P_I_PROC_DESCR        IN VARCHAR2             , --VARCHAR2(64)
                                        , NULL --P_I_DATA_INI          IN DATE     DEFAULT NULL,
                                        , NULL --P_I_DATA_FIM          IN DATE     DEFAULT NULL,
                                        , p_script --P_I_DETALHES1         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , p_mes --P_I_DETALHES2         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , p_ano --P_I_DETALHES3         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , NULL --P_I_DETALHES4         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , musuario --P_I_USER              IN VARCHAR2 DEFAULT NULL  --VARCHAR2(64)
                                                   );
        v_proc_status := 1; --EM PROCESSO

        ----------------------------------------------------------------------------------------------------------
        IF p_script = '001' THEN
            -- Script: SELECT ''001'',''001 - Corrige Zicas Kelly'' FROM DUAL
            loga ( 'Iniciando script "Correções SPED PIS/COFINS"' );
            lib_proc.add_header ( '001 - Correções SPED PIS/COFINS'
                                , 1
                                , 1 );
            lib_proc.add_header ( ' ' );

            loga ( 'Inicio das correções de NBM'
                 , tela => TRUE );

            FOR c001_a_dt IN c_datas ( v_data_ini
                                     , v_data_fim ) LOOP
                FOR c001_a IN c_zicaskelly_01_001 ( c001_a_dt.data_normal ) LOOP
                    IF c001_a.ident_nbm_novo IS NOT NULL
                   AND c001_a.ident_produto IS NOT NULL
                   AND c001_a.ident_nbm IS NOT NULL THEN
                        loga ( c001_a.sql_update_nbm );

                        EXECUTE IMMEDIATE c001_a.sql_update_nbm;
                    ELSE
                        loga (
                                  'Não executado: ['
                               || c001_a.ident_nbm_novo
                               || '/'
                               || c001_a.ident_produto
                               || '/'
                               || c001_a.ident_nbm
                               || '] '
                               || c001_a.sql_update_nbm
                        );
                    END IF;

                    lib_proc.add (
                                      'Produto: ['
                                   || c001_a.cod_produto
                                   || '] NBM atual: ['
                                   || c001_a.cod_nbm_atual
                                   || '] NBM Novo: ['
                                   || c001_a.cod_nbm_novo
                                   || ']'
                    );
                END LOOP;
            END LOOP;

            loga ( 'Fim das correções de NBM'
                 , tela => TRUE );
            loga ( '=============================================================================' );

            loga ( 'Correção: Cadastros dos estabelecimentos'
                 , tela => TRUE );

            UPDATE estabelecimento
               SET ind_reg_apur_cont_prev = 1
             WHERE cod_empresa = mcod_empresa
               AND NVL ( ind_reg_apur_cont_prev, 0 ) = 0;

            COMMIT;

            loga ( 'Capa, X07: corrige base PIS / COFINS'
                 , tela => TRUE );

            UPDATE msaf.x07_docto_fiscal a
               SET a.vlr_base_pis =
                       NVL ( ( SELECT SUM ( b.vlr_base_pis )
                                 FROM msaf.x08_itens_merc b
                                WHERE a.cod_empresa = b.cod_empresa
                                  AND a.cod_estab = b.cod_estab
                                  AND a.data_fiscal = b.data_fiscal
                                  AND a.movto_e_s = b.movto_e_s
                                  AND a.norm_dev = b.norm_dev
                                  AND a.ident_docto = b.ident_docto
                                  AND a.ident_fis_jur = b.ident_fis_jur
                                  AND a.num_docfis = b.num_docfis
                                  AND a.serie_docfis = b.serie_docfis
                                  AND b.ident_cfo <> '465' )
                           , 0 )
                 , a.vlr_base_cofins =
                       NVL ( ( SELECT SUM ( b.vlr_base_cofins )
                                 FROM msaf.x08_itens_merc b
                                WHERE a.cod_empresa = b.cod_empresa
                                  AND a.cod_estab = b.cod_estab
                                  AND a.data_fiscal = b.data_fiscal
                                  AND a.movto_e_s = b.movto_e_s
                                  AND a.norm_dev = b.norm_dev
                                  AND a.ident_docto = b.ident_docto
                                  AND a.ident_fis_jur = b.ident_fis_jur
                                  AND a.num_docfis = b.num_docfis
                                  AND a.serie_docfis = b.serie_docfis
                                  AND b.ident_cfo <> '465' )
                           , 0 )
             WHERE a.cod_empresa = mcod_empresa
               AND a.data_fiscal BETWEEN v_data_ini AND v_data_fim
               AND a.serie_docfis <> 'ECF'
               AND a.ident_docto = '39';

            COMMIT;

            loga ( 'Capa, DWT: corrige base PIS / COFINS'
                 , tela => TRUE );

            UPDATE msaf.dwt_docto_fiscal a
               SET a.vlr_base_pis =
                       NVL ( ( SELECT SUM ( b.vlr_base_pis )
                                 FROM msaf.dwt_itens_merc b
                                WHERE a.cod_empresa = b.cod_empresa
                                  AND a.cod_estab = b.cod_estab
                                  AND a.data_fiscal = b.data_fiscal
                                  AND a.movto_e_s = b.movto_e_s
                                  AND a.norm_dev = b.norm_dev
                                  AND a.ident_docto = b.ident_docto
                                  AND a.ident_fis_jur = b.ident_fis_jur
                                  AND a.num_docfis = b.num_docfis
                                  AND a.serie_docfis = b.serie_docfis
                                  AND a.ident_docto_fiscal = b.ident_docto_fiscal
                                  AND b.ident_cfo <> '465' )
                           , 0 )
                 , a.vlr_base_cofins =
                       NVL ( ( SELECT SUM ( b.vlr_base_cofins )
                                 FROM msaf.dwt_itens_merc b
                                WHERE a.cod_empresa = b.cod_empresa
                                  AND a.cod_estab = b.cod_estab
                                  AND a.data_fiscal = b.data_fiscal
                                  AND a.movto_e_s = b.movto_e_s
                                  AND a.norm_dev = b.norm_dev
                                  AND a.ident_docto = b.ident_docto
                                  AND a.ident_fis_jur = b.ident_fis_jur
                                  AND a.num_docfis = b.num_docfis
                                  AND a.serie_docfis = b.serie_docfis
                                  AND a.ident_docto_fiscal = b.ident_docto_fiscal
                                  AND b.ident_cfo <> '465' )
                           , 0 )
             WHERE a.cod_empresa = mcod_empresa
               AND a.data_fiscal BETWEEN v_data_ini AND v_data_fim
               AND a.serie_docfis <> 'ECF'
               AND a.ident_docto = '39';

            COMMIT;

            loga ( 'Capa, X07: corrige data lancamento PIS COFINS'
                 , tela => TRUE );

            UPDATE msaf.x07_docto_fiscal
               SET dat_lanc_pis_cofins = data_fiscal
                 , cod_sit_pis = '50'
                 , cod_sit_cofins = '50'
                 , vlr_aliq_cofins = 7.6
                 , vlr_aliq_pis = 1.65
                 , vlr_pis =
                       NVL ( ROUND ( vlr_base_pis * ( vlr_aliq_pis / 100 )
                                   , 2 )
                           , 0 )
                 , vlr_cofins =
                       NVL ( ROUND ( vlr_base_cofins * ( vlr_aliq_cofins / 100 )
                                   , 2 )
                           , 0 )
                 , ind_nat_base_cred = 4
             WHERE cod_empresa = mcod_empresa
               AND data_fiscal BETWEEN v_data_ini AND v_data_fim
               AND serie_docfis <> 'ECF'
               AND ident_docto = '39';

            COMMIT;

            loga ( 'DWT Capa: corrige data lancamento PIS COFINS'
                 , tela => TRUE );

            UPDATE msaf.dwt_docto_fiscal
               SET dat_lanc_pis_cofins = data_fiscal
                 , cod_sit_pis = '50'
                 , cod_sit_cofins = '50'
                 , vlr_aliq_cofins = 7.6
                 , vlr_aliq_pis = 1.65
                 , vlr_pis =
                       NVL ( ROUND ( vlr_base_pis * ( vlr_aliq_pis / 100 )
                                   , 2 )
                           , 0 )
                 , vlr_cofins =
                       NVL ( ROUND ( vlr_base_cofins * ( vlr_aliq_cofins / 100 )
                                   , 2 )
                           , 0 )
                 , ind_nat_base_cred = 4
             WHERE cod_empresa = mcod_empresa
               AND data_fiscal BETWEEN v_data_ini AND v_data_fim
               AND serie_docfis <> 'ECF'
               AND ident_docto = '39';

            COMMIT;

            loga ( 'Produto, X08: corrige data lancamento PIS COFINS'
                 , tela => TRUE );

            UPDATE msaf.x08_itens_merc
               SET dat_lanc_pis_cofins = data_fiscal
                 , cod_situacao_pis = DECODE ( ident_cfo, '465', '70', '50' )
                 , cod_situacao_cofins = DECODE ( ident_cfo, '465', '70', '50' )
                 , vlr_aliq_cofins = 7.6
                 , vlr_aliq_pis = 1.65
                 , vlr_pis =
                       NVL ( ROUND ( vlr_base_pis * ( vlr_aliq_pis / 100 )
                                   , 2 )
                           , 0 )
                 , vlr_cofins =
                       NVL ( ROUND ( vlr_base_cofins * ( vlr_aliq_cofins / 100 )
                                   , 2 )
                           , 0 )
                 , ind_nat_base_cred = '04'
             WHERE cod_empresa = mcod_empresa
               AND data_fiscal BETWEEN v_data_ini AND v_data_fim
               AND serie_docfis <> 'ECF'
               AND ident_docto = '39'; --- para NFEE

            COMMIT;

            loga ( 'DWT Produto: corrige data lancamento PIS COFINS'
                 , tela => TRUE );

            UPDATE msaf.dwt_itens_merc
               SET dat_lanc_pis_cofins = data_fiscal
                 , cod_situacao_pis = DECODE ( ident_cfo, '465', '70', '50' )
                 , cod_situacao_cofins = DECODE ( ident_cfo, '465', '70', '50' )
                 , vlr_aliq_cofins = 7.6
                 , vlr_aliq_pis = 1.65
                 , vlr_pis =
                       NVL ( ROUND ( vlr_base_pis * ( vlr_aliq_pis / 100 )
                                   , 2 )
                           , 0 )
                 , vlr_cofins =
                       NVL ( ROUND ( vlr_base_cofins * ( vlr_aliq_cofins / 100 )
                                   , 2 )
                           , 0 )
                 , ind_nat_base_cred = '04'
             WHERE cod_empresa = mcod_empresa
               AND data_fiscal BETWEEN v_data_ini AND v_data_fim
               AND serie_docfis <> 'ECF'
               AND ident_docto = '39'; --- para NFEE

            COMMIT;

            loga ( 'Depositos, X08; Muda NCM da linha da nota com o que esta no cadastro do produto'
                 , tela => TRUE );

            UPDATE msaf.x08_itens_merc x08u
               SET ident_nbm =
                       ( SELECT x2013.ident_nbm
                           FROM msaf.x2013_produto x2013
                          WHERE x2013.ident_produto = x08u.ident_produto )
             --SELECT * FROM MSAF.X08_ITENS_MERC X08U
             WHERE x08u.cod_empresa = mcod_empresa
               AND REGEXP_LIKE ( x08u.cod_estab
                               , v_proc_9xx )
               AND x08u.movto_e_s <> '9'
               AND x08u.data_fiscal BETWEEN v_data_ini AND v_data_fim
               AND EXISTS
                       (SELECT xnbma.cod_nbm
                             , xnbmb.cod_nbm
                             , dwt.ident_nbm
                             , x2013.ident_nbm
                             , dwt.*
                          FROM msaf.dwt_itens_merc dwt
                             , msaf.x2043_cod_nbm xnbma
                             , msaf.x2013_produto x2013
                             , msaf.x2043_cod_nbm xnbmb
                         WHERE dwt.cod_empresa = mcod_empresa
                           AND REGEXP_LIKE ( dwt.cod_estab
                                           , v_proc_9xx )
                           AND dwt.movto_e_s <> '9'
                           AND dwt.data_fiscal BETWEEN v_data_ini AND v_data_fim
                           AND xnbma.ident_nbm = dwt.ident_nbm
                           AND x2013.ident_produto = dwt.ident_produto
                           AND xnbmb.ident_nbm = x2013.ident_nbm
                           AND xnbmb.cod_nbm <> xnbma.cod_nbm
                           AND x08u.cod_empresa = dwt.cod_empresa
                           AND x08u.cod_estab = dwt.cod_estab
                           AND x08u.data_fiscal = dwt.data_fiscal
                           AND x08u.movto_e_s = dwt.movto_e_s
                           AND x08u.norm_dev = dwt.norm_dev
                           AND x08u.ident_docto = dwt.ident_docto
                           AND x08u.ident_fis_jur = dwt.ident_fis_jur
                           AND x08u.num_docfis = dwt.num_docfis
                           AND x08u.serie_docfis = dwt.serie_docfis
                           AND x08u.sub_serie_docfis = dwt.sub_serie_docfis
                           AND x08u.discri_item = dwt.discri_item);

            COMMIT;

            loga ( 'Depositos, DWT; Muda NCM da linha da nota com o que esta no cadastro do produto'
                 , tela => TRUE );

            UPDATE msaf.dwt_itens_merc dwtu
               SET ident_nbm =
                       ( SELECT x2013.ident_nbm
                           FROM msaf.x2013_produto x2013
                          WHERE x2013.ident_produto = dwtu.ident_produto )
             --SELECT * FROM MSAF.DWT_ITENS_MERC DWTU
             WHERE dwtu.cod_empresa = mcod_empresa
               AND REGEXP_LIKE ( dwtu.cod_estab
                               , v_proc_9xx )
               AND dwtu.movto_e_s <> '9'
               AND dwtu.data_fiscal BETWEEN v_data_ini AND v_data_fim
               AND EXISTS
                       (SELECT xnbma.cod_nbm
                             , xnbmb.cod_nbm
                             , dwt.ident_nbm
                             , x2013.ident_nbm
                             , dwt.*
                          FROM msaf.dwt_itens_merc dwt
                             , msaf.x2043_cod_nbm xnbma
                             , msaf.x2013_produto x2013
                             , msaf.x2043_cod_nbm xnbmb
                         WHERE dwt.cod_empresa = mcod_empresa
                           AND REGEXP_LIKE ( dwt.cod_estab
                                           , v_proc_9xx )
                           AND dwt.movto_e_s <> '9'
                           AND dwt.data_fiscal BETWEEN v_data_ini AND v_data_fim
                           AND xnbma.ident_nbm = dwt.ident_nbm
                           AND x2013.ident_produto = dwt.ident_produto
                           AND xnbmb.ident_nbm = x2013.ident_nbm
                           AND xnbmb.cod_nbm <> xnbma.cod_nbm
                           AND dwtu.ident_docto_fiscal = dwt.ident_docto_fiscal
                           AND dwtu.ident_item_merc = dwt.ident_item_merc);

            COMMIT;

            ---- INI - AJUSTE CUPONS SAIDA --------------------------------------------------------------------------------------------
            loga ( 'Depositos, X08; Muda NCM da linha da nota com o que esta no cadastro do produto'
                 , tela => TRUE );

            UPDATE msaf.x08_itens_merc x08u
               SET ident_nbm =
                       ( SELECT x2013.ident_nbm
                           FROM msaf.x2013_produto x2013
                          WHERE x2013.ident_produto = x08u.ident_produto )
             --SELECT * FROM MSAF.X08_ITENS_MERC X08U
             WHERE x08u.cod_empresa = mcod_empresa
               AND REGEXP_LIKE ( x08u.cod_estab
                               , v_proc_9xx )
               AND x08u.movto_e_s = '9'
               AND x08u.ident_docto IN ( '63'
                                       , '94' )
               AND x08u.data_fiscal BETWEEN v_data_ini AND v_data_fim
               AND EXISTS
                       (SELECT xnbma.cod_nbm
                             , xnbmb.cod_nbm
                             , dwt.ident_nbm
                             , x2013.ident_nbm
                             , dwt.*
                          FROM msaf.dwt_itens_merc dwt
                             , msaf.x2043_cod_nbm xnbma
                             , msaf.x2013_produto x2013
                             , msaf.x2043_cod_nbm xnbmb
                         WHERE dwt.cod_empresa = mcod_empresa
                           AND REGEXP_LIKE ( dwt.cod_estab
                                           , v_proc_9xx )
                           AND dwt.movto_e_s = '9'
                           AND dwt.data_fiscal BETWEEN v_data_ini AND v_data_fim
                           AND xnbma.ident_nbm = dwt.ident_nbm
                           AND x2013.ident_produto = dwt.ident_produto
                           AND xnbmb.ident_nbm = x2013.ident_nbm
                           AND xnbmb.cod_nbm <> xnbma.cod_nbm
                           AND x08u.cod_empresa = dwt.cod_empresa
                           AND x08u.cod_estab = dwt.cod_estab
                           AND x08u.data_fiscal = dwt.data_fiscal
                           AND x08u.movto_e_s = dwt.movto_e_s
                           AND x08u.norm_dev = dwt.norm_dev
                           AND x08u.ident_docto = dwt.ident_docto
                           AND x08u.ident_fis_jur = dwt.ident_fis_jur
                           AND x08u.num_docfis = dwt.num_docfis
                           AND x08u.serie_docfis = dwt.serie_docfis
                           AND x08u.sub_serie_docfis = dwt.sub_serie_docfis
                           AND x08u.discri_item = dwt.discri_item);

            COMMIT;

            loga ( 'Depositos, DWT; Muda NCM da linha da nota com o que esta no cadastro do produto'
                 , tela => TRUE );

            UPDATE msaf.dwt_itens_merc dwtu
               SET ident_nbm =
                       ( SELECT x2013.ident_nbm
                           FROM msaf.x2013_produto x2013
                          WHERE x2013.ident_produto = dwtu.ident_produto )
             --SELECT * FROM MSAF.DWT_ITENS_MERC DWTU
             WHERE dwtu.cod_empresa = mcod_empresa
               AND REGEXP_LIKE ( dwtu.cod_estab
                               , v_proc_9xx )
               AND dwtu.movto_e_s = '9'
               AND dwtu.ident_docto IN ( '63'
                                       , '94' )
               AND dwtu.data_fiscal BETWEEN v_data_ini AND v_data_fim
               AND EXISTS
                       (SELECT xnbma.cod_nbm
                             , xnbmb.cod_nbm
                             , dwt.ident_nbm
                             , x2013.ident_nbm
                             , dwt.*
                          FROM msaf.dwt_itens_merc dwt
                             , msaf.x2043_cod_nbm xnbma
                             , msaf.x2013_produto x2013
                             , msaf.x2043_cod_nbm xnbmb
                         WHERE dwt.cod_empresa = mcod_empresa
                           AND REGEXP_LIKE ( dwt.cod_estab
                                           , v_proc_9xx )
                           AND dwt.movto_e_s = '9'
                           AND dwt.data_fiscal BETWEEN v_data_ini AND v_data_fim
                           AND xnbma.ident_nbm = dwt.ident_nbm
                           AND x2013.ident_produto = dwt.ident_produto
                           AND xnbmb.ident_nbm = x2013.ident_nbm
                           AND xnbmb.cod_nbm <> xnbma.cod_nbm
                           AND dwtu.ident_docto = dwt.ident_docto
                           AND dwtu.ident_docto_fiscal = dwt.ident_docto_fiscal
                           AND dwtu.ident_item_merc = dwt.ident_item_merc);

            COMMIT;
            ---- FIM - AJUSTE CUPONS SAIDA --------------------------------------------------------------------------------------------

            loga ( 'Lojas, X08; Muda NCM da linha da nota com o que esta no cadastro do produto'
                 , tela => TRUE );

            UPDATE msaf.x08_itens_merc x08u
               SET ident_nbm =
                       ( SELECT x2013.ident_nbm
                           FROM msaf.x2013_produto x2013
                          WHERE x2013.ident_produto = x08u.ident_produto
                            AND x2013.valid_produto = (SELECT MAX ( a.valid_produto )
                                                         FROM msaf.x2013_produto a
                                                        WHERE a.ident_produto = x2013.ident_produto
                                                          AND a.valid_produto <= x08u.data_fiscal) )
             WHERE x08u.cod_empresa = mcod_empresa
               AND NOT REGEXP_LIKE ( x08u.cod_estab
                                   , v_proc_9xx )
               AND x08u.movto_e_s <> '9'
               AND x08u.data_fiscal BETWEEN v_data_ini AND v_data_fim
               AND x08u.ident_cfo = ANY (SELECT ident_cfo
                                           FROM msaf.x2012_cod_fiscal
                                          WHERE cod_cfo IN ( '1102'
                                                           , '1403'
                                                           , '2102'
                                                           , '2403' ))
               AND EXISTS
                       (SELECT xnbma.cod_nbm
                             , xnbmb.cod_nbm
                             , dwt.ident_nbm
                             , x2013.ident_nbm
                             , dwt.*
                          FROM msaf.dwt_itens_merc dwt
                             , msaf.x2043_cod_nbm xnbma
                             , msaf.x2013_produto x2013
                             , msaf.x2043_cod_nbm xnbmb
                         WHERE dwt.cod_empresa = mcod_empresa
                           AND NOT REGEXP_LIKE ( dwt.cod_estab
                                               , v_proc_9xx )
                           AND dwt.movto_e_s <> '9'
                           AND dwt.data_fiscal BETWEEN v_data_ini AND v_data_fim
                           AND dwt.ident_cfo IN ( SELECT ident_cfo
                                                    FROM msaf.x2012_cod_fiscal
                                                   WHERE cod_cfo IN ( '1102'
                                                                    , '1403'
                                                                    , '2102'
                                                                    , '2403' ) )
                           AND xnbma.ident_nbm = dwt.ident_nbm
                           AND x2013.ident_produto = dwt.ident_produto
                           AND xnbmb.ident_nbm = x2013.ident_nbm
                           AND xnbmb.cod_nbm <> xnbma.cod_nbm
                           AND x08u.cod_empresa = dwt.cod_empresa
                           AND x08u.cod_estab = dwt.cod_estab
                           AND x08u.data_fiscal = dwt.data_fiscal
                           AND x08u.movto_e_s = dwt.movto_e_s
                           AND x08u.norm_dev = dwt.norm_dev
                           AND x08u.ident_docto = dwt.ident_docto
                           AND x08u.ident_fis_jur = dwt.ident_fis_jur
                           AND x08u.num_docfis = dwt.num_docfis
                           AND x08u.serie_docfis = dwt.serie_docfis
                           AND x08u.sub_serie_docfis = dwt.sub_serie_docfis
                           AND x08u.discri_item = dwt.discri_item);

            COMMIT;

            loga ( 'Lojas, DWT; Muda NCM da linha da nota com o que esta no cadastro do produto'
                 , tela => TRUE );

            UPDATE msaf.dwt_itens_merc dwtu
               SET ident_nbm =
                       ( SELECT x2013.ident_nbm
                           FROM msaf.x2013_produto x2013
                          WHERE x2013.ident_produto = dwtu.ident_produto
                            AND x2013.valid_produto = (SELECT MAX ( a.valid_produto )
                                                         FROM msaf.x2013_produto a
                                                        WHERE a.ident_produto = x2013.ident_produto
                                                          AND a.valid_produto <= dwtu.data_fiscal) )
             WHERE dwtu.cod_empresa = mcod_empresa
               AND NOT REGEXP_LIKE ( dwtu.cod_estab
                                   , v_proc_9xx )
               AND dwtu.movto_e_s <> '9'
               AND dwtu.data_fiscal BETWEEN v_data_ini AND v_data_fim
               AND dwtu.ident_cfo = ANY (SELECT ident_cfo
                                           FROM msaf.x2012_cod_fiscal
                                          WHERE cod_cfo IN ( '1102'
                                                           , '1403'
                                                           , '2102'
                                                           , '2403' ))
               AND EXISTS
                       (SELECT xnbma.cod_nbm
                             , xnbmb.cod_nbm
                             , dwt.ident_nbm
                             , x2013.ident_nbm
                             , dwt.*
                          FROM msaf.dwt_itens_merc dwt
                             , msaf.x2043_cod_nbm xnbma
                             , msaf.x2013_produto x2013
                             , msaf.x2043_cod_nbm xnbmb
                         WHERE dwt.cod_empresa = mcod_empresa
                           AND NOT REGEXP_LIKE ( dwt.cod_estab
                                               , v_proc_9xx )
                           AND dwt.movto_e_s <> '9'
                           AND dwt.data_fiscal BETWEEN v_data_ini AND v_data_fim
                           AND dwt.ident_cfo IN ( SELECT ident_cfo
                                                    FROM msaf.x2012_cod_fiscal
                                                   WHERE cod_cfo IN ( '1102'
                                                                    , '1403'
                                                                    , '2102'
                                                                    , '2403' ) )
                           AND xnbma.ident_nbm = dwt.ident_nbm
                           AND x2013.ident_produto = dwt.ident_produto
                           AND xnbmb.ident_nbm = x2013.ident_nbm
                           AND xnbmb.cod_nbm <> xnbma.cod_nbm
                           AND dwtu.ident_docto_fiscal = dwt.ident_docto_fiscal
                           AND dwtu.ident_item_merc = dwt.ident_item_merc);

            COMMIT;

            ---- INI - AJUSTE NFs ENTRADA - VENDA ---------------------------------------------------------------------------------------
            loga ( 'NFs Venda, X08; Muda NCM da linha da nota com o que esta no cadastro do produto'
                 , tela => TRUE );

            UPDATE msaf.x08_itens_merc x08u
               SET ident_nbm =
                       ( SELECT x2013.ident_nbm
                           FROM msaf.x2013_produto x2013
                          WHERE x2013.ident_produto = x08u.ident_produto
                            AND x2013.valid_produto = (SELECT MAX ( a.valid_produto )
                                                         FROM msaf.x2013_produto a
                                                        WHERE a.ident_produto = x2013.ident_produto
                                                          AND a.valid_produto <= SYSDATE) )
             WHERE x08u.cod_empresa = mcod_empresa
               AND NOT REGEXP_LIKE ( x08u.cod_estab
                                   , v_proc_9xx )
               AND x08u.movto_e_s = '9'
               AND x08u.data_fiscal BETWEEN v_data_ini AND v_data_fim
               AND x08u.ident_cfo = ANY (SELECT ident_cfo
                                           FROM msaf.x2012_cod_fiscal
                                          WHERE cod_cfo IN ( '5102'
                                                           , '5405'
                                                           , '5403'
                                                           , '6102'
                                                           , '6405'
                                                           , '6403' ))
               AND EXISTS
                       (SELECT xnbma.cod_nbm
                             , xnbmb.cod_nbm
                             , dwt.ident_nbm
                             , x2013.ident_nbm
                             , dwt.*
                          FROM msaf.dwt_itens_merc dwt
                             , msaf.x2043_cod_nbm xnbma
                             , msaf.x2013_produto x2013
                             , msaf.x2043_cod_nbm xnbmb
                         WHERE dwt.cod_empresa = mcod_empresa
                           AND NOT REGEXP_LIKE ( dwt.cod_estab
                                               , v_proc_9xx )
                           AND dwt.movto_e_s = '9'
                           AND dwt.data_fiscal BETWEEN v_data_ini AND v_data_fim
                           AND dwt.ident_cfo IN ( SELECT ident_cfo
                                                    FROM msaf.x2012_cod_fiscal
                                                   WHERE cod_cfo IN ( '5102'
                                                                    , '5405'
                                                                    , '5403'
                                                                    , '6102'
                                                                    , '6405'
                                                                    , '6403' ) )
                           AND xnbma.ident_nbm = dwt.ident_nbm
                           AND x2013.ident_produto = dwt.ident_produto
                           AND xnbmb.ident_nbm = x2013.ident_nbm
                           AND xnbmb.cod_nbm <> xnbma.cod_nbm
                           AND x08u.cod_empresa = dwt.cod_empresa
                           AND x08u.cod_estab = dwt.cod_estab
                           AND x08u.data_fiscal = dwt.data_fiscal
                           AND x08u.movto_e_s = dwt.movto_e_s
                           AND x08u.norm_dev = dwt.norm_dev
                           AND x08u.ident_docto = dwt.ident_docto
                           AND x08u.ident_fis_jur = dwt.ident_fis_jur
                           AND x08u.num_docfis = dwt.num_docfis
                           AND x08u.serie_docfis = dwt.serie_docfis
                           AND x08u.sub_serie_docfis = dwt.sub_serie_docfis
                           AND x08u.discri_item = dwt.discri_item);

            COMMIT;

            loga ( 'NFs Venda, DWT; Muda NCM da linha da nota com o que esta no cadastro do produto'
                 , tela => TRUE );

            UPDATE msaf.dwt_itens_merc dwtu
               SET ident_nbm =
                       ( SELECT x2013.ident_nbm
                           FROM msaf.x2013_produto x2013
                          WHERE x2013.ident_produto = dwtu.ident_produto
                            AND x2013.valid_produto = (SELECT MAX ( a.valid_produto )
                                                         FROM msaf.x2013_produto a
                                                        WHERE a.ident_produto = x2013.ident_produto
                                                          AND a.valid_produto <= SYSDATE) )
             WHERE dwtu.cod_empresa = mcod_empresa
               AND NOT REGEXP_LIKE ( dwtu.cod_estab
                                   , v_proc_9xx )
               AND dwtu.movto_e_s = '9'
               AND dwtu.data_fiscal BETWEEN v_data_ini AND v_data_fim
               AND dwtu.ident_cfo = ANY (SELECT ident_cfo
                                           FROM msaf.x2012_cod_fiscal
                                          WHERE cod_cfo IN ( '5102'
                                                           , '5405'
                                                           , '5403'
                                                           , '6102'
                                                           , '6405'
                                                           , '6403' ))
               AND EXISTS
                       (SELECT xnbma.cod_nbm
                             , xnbmb.cod_nbm
                             , dwt.ident_nbm
                             , x2013.ident_nbm
                             , dwt.*
                          FROM msaf.dwt_itens_merc dwt
                             , msaf.x2043_cod_nbm xnbma
                             , msaf.x2013_produto x2013
                             , msaf.x2043_cod_nbm xnbmb
                         WHERE dwt.cod_empresa = mcod_empresa
                           AND NOT REGEXP_LIKE ( dwt.cod_estab
                                               , v_proc_9xx )
                           AND dwt.movto_e_s = '9'
                           AND dwt.data_fiscal BETWEEN v_data_ini AND v_data_fim
                           AND dwt.ident_cfo IN ( SELECT ident_cfo
                                                    FROM msaf.x2012_cod_fiscal
                                                   WHERE cod_cfo IN ( '5102'
                                                                    , '5405'
                                                                    , '5403'
                                                                    , '6102'
                                                                    , '6405'
                                                                    , '6403' ) )
                           AND xnbma.ident_nbm = dwt.ident_nbm
                           AND x2013.ident_produto = dwt.ident_produto
                           AND xnbmb.ident_nbm = x2013.ident_nbm
                           AND xnbmb.cod_nbm <> xnbma.cod_nbm
                           AND dwtu.ident_docto_fiscal = dwt.ident_docto_fiscal
                           AND dwtu.ident_item_merc = dwt.ident_item_merc);

            COMMIT;
            ---- FIM - AJUSTE NFs ENTRADA - VENDA ---------------------------------------------------------------------------------------

            loga ( 'Correções SPED PIS/COFINS - Passo 2 - CSTs, etc'
                 , tela => TRUE );

            FOR c001_b IN c_datas ( v_data_ini
                                  , v_data_fim ) LOOP
                loga (    'Data: ['
                       || TO_CHAR ( c001_b.data_normal
                                  , 'DD/MM/YYYY' )
                       || ']' );

                UPDATE msaf.x08_itens_merc a
                   SET vlr_pis = ( NVL ( vlr_item, 0 ) - NVL ( vlr_desconto, 0 ) ) * 0.0165
                     , vlr_cofins = ( NVL ( vlr_item, 0 ) - NVL ( vlr_desconto, 0 ) ) * 0.076
                     , vlr_aliq_pis = 1.65
                     , vlr_aliq_cofins = 7.6
                     , vlr_base_pis = ( NVL ( vlr_item, 0 ) - NVL ( vlr_desconto, 0 ) )
                     , vlr_base_cofins = ( NVL ( vlr_item, 0 ) - NVL ( vlr_desconto, 0 ) )
                 --SELECT * FROM MSAF.X08_ITENS_MERC A
                 WHERE cod_empresa = mcod_empresa
                   AND data_fiscal = c001_b.data_normal
                   AND a.ident_cfo = ANY (SELECT ident_cfo
                                            FROM msaf.x2012_cod_fiscal
                                           WHERE cod_cfo IN ( '1102'
                                                            , '2403'
                                                            , '2102'
                                                            , '1403' ))
                   AND a.cod_situacao_cofins = '50'
                   AND ( a.vlr_aliq_pis <> 1.65
                     OR a.vlr_aliq_cofins <> 7.6
                     OR a.vlr_cofins = 0
                     OR a.vlr_base_cofins = 0 );

                commit_loga ( 01
                            , ' '
                            , SQL%ROWCOUNT
                            , c001_b.data_safx );

                UPDATE msaf.dwt_itens_merc a
                   SET vlr_pis = ( NVL ( vlr_item, 0 ) - NVL ( vlr_desconto, 0 ) ) * 0.0165
                     , vlr_cofins = ( NVL ( vlr_item, 0 ) - NVL ( vlr_desconto, 0 ) ) * 0.076
                     , vlr_aliq_pis = 1.65
                     , vlr_aliq_cofins = 7.6
                     , vlr_base_pis = ( NVL ( vlr_item, 0 ) - NVL ( vlr_desconto, 0 ) )
                     , vlr_base_cofins = ( NVL ( vlr_item, 0 ) - NVL ( vlr_desconto, 0 ) )
                 --SELECT * FROM MSAF.DWT_ITENS_MERC A
                 WHERE cod_empresa = mcod_empresa
                   AND data_fiscal = c001_b.data_normal
                   AND a.ident_cfo = ANY (SELECT ident_cfo
                                            FROM msaf.x2012_cod_fiscal
                                           WHERE cod_cfo IN ( '1102'
                                                            , '2403'
                                                            , '2102'
                                                            , '1403' ))
                   AND a.cod_situacao_cofins = '50'
                   AND ( a.vlr_aliq_pis <> 1.65
                     OR a.vlr_aliq_cofins <> 7.6
                     OR a.vlr_cofins = 0
                     OR a.vlr_base_cofins = 0 );

                commit_loga ( 01
                            , 'd'
                            , SQL%ROWCOUNT
                            , c001_b.data_safx );

                UPDATE msaf.x08_itens_merc
                   SET cod_situacao_pis = '98'
                     , cod_situacao_cofins = '98'
                 WHERE cod_empresa = mcod_empresa
                   AND data_fiscal = c001_b.data_normal
                   AND movto_e_s <> '9'
                   AND cod_situacao_cofins = '8';

                commit_loga ( 02
                            , ' '
                            , SQL%ROWCOUNT
                            , c001_b.data_safx );

                UPDATE msaf.dwt_itens_merc
                   SET cod_situacao_pis = '98'
                     , cod_situacao_cofins = '98'
                 WHERE cod_empresa = mcod_empresa
                   AND data_fiscal = c001_b.data_normal
                   AND movto_e_s <> '9'
                   AND cod_situacao_cofins = '8';

                commit_loga ( 02
                            , 'd'
                            , SQL%ROWCOUNT
                            , c001_b.data_safx );

                ---Correção das devoluções de venda
                UPDATE msaf.x08_itens_merc
                   SET cod_situacao_pis = '50'
                     , cod_situacao_cofins = '50'
                     , vlr_pis = ( NVL ( vlr_item, 0 ) - NVL ( vlr_desconto, 0 ) ) * 0.0165
                     , vlr_cofins = ( NVL ( vlr_item, 0 ) - NVL ( vlr_desconto, 0 ) ) * 0.076
                     , vlr_aliq_pis = 1.65
                     , vlr_aliq_cofins = 7.6
                     , vlr_base_pis = ( NVL ( vlr_item, 0 ) - NVL ( vlr_desconto, 0 ) )
                     , vlr_base_cofins = ( NVL ( vlr_item, 0 ) - NVL ( vlr_desconto, 0 ) )
                 --SELECT * FROM MSAF.X08_ITENS_MERC
                 WHERE cod_empresa = mcod_empresa
                   AND data_fiscal = c001_b.data_normal
                   AND movto_e_s <> '9'
                   AND ident_cfo = ANY (SELECT ident_cfo
                                          FROM msaf.x2012_cod_fiscal
                                         WHERE cod_cfo IN ( '1202'
                                                          , '1411' ))
                   AND ind_base_medicamento = '3'
                   AND cod_situacao_cofins <> '50';

                commit_loga ( 05
                            , 'a'
                            , SQL%ROWCOUNT
                            , c001_b.data_safx );

                UPDATE msaf.dwt_itens_merc
                   SET cod_situacao_pis = '50'
                     , cod_situacao_cofins = '50'
                     , vlr_pis = ( NVL ( vlr_item, 0 ) - NVL ( vlr_desconto, 0 ) ) * 0.0165
                     , vlr_cofins = ( NVL ( vlr_item, 0 ) - NVL ( vlr_desconto, 0 ) ) * 0.076
                     , vlr_aliq_pis = 1.65
                     , vlr_aliq_cofins = 7.6
                     , vlr_base_pis = ( NVL ( vlr_item, 0 ) - NVL ( vlr_desconto, 0 ) )
                     , vlr_base_cofins = ( NVL ( vlr_item, 0 ) - NVL ( vlr_desconto, 0 ) )
                 --SELECT * FROM MSAF.DWT_ITENS_MERC
                 WHERE cod_empresa = mcod_empresa
                   AND data_fiscal = c001_b.data_normal
                   AND movto_e_s <> '9'
                   AND ident_cfo = ANY (SELECT ident_cfo
                                          FROM msaf.x2012_cod_fiscal
                                         WHERE cod_cfo IN ( '1202'
                                                          , '1411' ))
                   AND ind_base_medicamento = '3'
                   AND cod_situacao_cofins <> '50';

                commit_loga ( 05
                            , 'b'
                            , SQL%ROWCOUNT
                            , c001_b.data_safx );

                UPDATE msaf.x08_itens_merc
                   SET cod_situacao_pis = '70'
                     , cod_situacao_cofins = '70'
                 --SELECT * FROM MSAF.X08_ITENS_MERC
                 WHERE cod_empresa = mcod_empresa
                   AND data_fiscal = c001_b.data_normal
                   AND movto_e_s <> '9'
                   AND ident_cfo = ANY (SELECT ident_cfo
                                          FROM msaf.x2012_cod_fiscal
                                         WHERE cod_cfo IN ( '1202'
                                                          , '1411' ))
                   AND ind_base_medicamento IN ( '1'
                                               , '2' )
                   AND cod_situacao_cofins <> '70';

                commit_loga ( 05
                            , 'c'
                            , SQL%ROWCOUNT
                            , c001_b.data_safx );

                UPDATE msaf.dwt_itens_merc
                   SET cod_situacao_pis = '70'
                     , cod_situacao_cofins = '70'
                 --SELECT * FROM MSAF.DWT_ITENS_MERC
                 WHERE cod_empresa = mcod_empresa
                   AND data_fiscal = c001_b.data_normal
                   AND movto_e_s <> '9'
                   AND ident_cfo = ANY (SELECT ident_cfo
                                          FROM msaf.x2012_cod_fiscal
                                         WHERE cod_cfo IN ( '1202'
                                                          , '1411' ))
                   AND ind_base_medicamento IN ( '1'
                                               , '2' )
                   AND cod_situacao_cofins <> '70';

                commit_loga ( 05
                            , 'd'
                            , SQL%ROWCOUNT
                            , c001_b.data_safx );

                --Isto já está OK no AJUSTA_MOVTO_DEZEM, provavelmente está atualizando zero linhas, fique de olho...
                UPDATE msaf.x08_itens_merc
                   SET ind_nat_base_cred = 12
                 --SELECT * FROM MSAF.X08_ITENS_MERC
                 WHERE cod_empresa = mcod_empresa
                   AND data_fiscal = c001_b.data_normal
                   AND movto_e_s <> '9'
                   AND cod_situacao_cofins = '50'
                   AND ident_cfo = ANY (SELECT ident_cfo
                                          FROM msaf.x2012_cod_fiscal
                                         WHERE cod_cfo IN ( '1202'
                                                          , '1411' ))
                   AND NVL ( ind_nat_base_cred, 0 ) <> 12;

                commit_loga ( 03
                            , 'a'
                            , SQL%ROWCOUNT
                            , c001_b.data_safx );

                UPDATE msaf.dwt_itens_merc
                   SET ind_nat_base_cred = 12
                 --SELECT * FROM MSAF.DWT_ITENS_MERC
                 WHERE cod_empresa = mcod_empresa
                   AND data_fiscal = c001_b.data_normal
                   AND movto_e_s <> '9'
                   AND cod_situacao_cofins = '50'
                   AND ident_cfo = ANY (SELECT ident_cfo
                                          FROM msaf.x2012_cod_fiscal
                                         WHERE cod_cfo IN ( '1202'
                                                          , '1411' ))
                   AND NVL ( ind_nat_base_cred, 0 ) <> 12;

                commit_loga ( 03
                            , 'b'
                            , SQL%ROWCOUNT
                            , c001_b.data_safx );

                --Energia elétrica
                UPDATE msaf.x08_itens_merc a
                   SET vlr_pis = ( NVL ( vlr_item, 0 ) - NVL ( vlr_desconto, 0 ) ) * 0.0165
                     , vlr_cofins = ( NVL ( vlr_item, 0 ) - NVL ( vlr_desconto, 0 ) ) * 0.076
                     , vlr_aliq_pis = 1.65
                     , vlr_aliq_cofins = 7.6
                     , vlr_base_pis = ( NVL ( vlr_item, 0 ) - NVL ( vlr_desconto, 0 ) )
                     , vlr_base_cofins = ( NVL ( vlr_item, 0 ) - NVL ( vlr_desconto, 0 ) )
                     , dat_lanc_pis_cofins = data_fiscal
                     , cod_situacao_pis = '50'
                     , cod_situacao_cofins = '50'
                     , ind_nat_base_cred = '04'
                 --SELECT * FROM MSAF.X08_ITENS_MERC A
                 WHERE cod_empresa = mcod_empresa
                   AND data_fiscal = c001_b.data_normal
                   AND movto_e_s <> '9'
                   AND ident_cfo = ANY (SELECT ident_cfo
                                          FROM msaf.x2012_cod_fiscal
                                         WHERE cod_cfo IN ( '1253'
                                                          , '2253' ));

                commit_loga ( 04
                            , 'a'
                            , SQL%ROWCOUNT
                            , c001_b.data_safx );

                UPDATE msaf.dwt_itens_merc
                   SET vlr_pis = ( NVL ( vlr_item, 0 ) - NVL ( vlr_desconto, 0 ) ) * 0.0165
                     , vlr_cofins = ( NVL ( vlr_item, 0 ) - NVL ( vlr_desconto, 0 ) ) * 0.076
                     , vlr_aliq_pis = 1.65
                     , vlr_aliq_cofins = 7.6
                     , vlr_base_pis = ( NVL ( vlr_item, 0 ) - NVL ( vlr_desconto, 0 ) )
                     , vlr_base_cofins = ( NVL ( vlr_item, 0 ) - NVL ( vlr_desconto, 0 ) )
                     , dat_lanc_pis_cofins = data_fiscal
                     , cod_situacao_pis = '50'
                     , cod_situacao_cofins = '50'
                     , ind_nat_base_cred = '04'
                 WHERE cod_empresa = mcod_empresa
                   AND data_fiscal = c001_b.data_normal
                   AND movto_e_s <> '9'
                   AND ident_cfo = ANY (SELECT ident_cfo
                                          FROM msaf.x2012_cod_fiscal
                                         WHERE cod_cfo IN ( '1253'
                                                          , '2253' ));

                commit_loga ( 04
                            , 'b'
                            , SQL%ROWCOUNT
                            , c001_b.data_safx );

                UPDATE msaf.x07_docto_fiscal a
                   SET dat_lanc_pis_cofins = data_fiscal
                 WHERE cod_empresa = mcod_empresa
                   AND data_fiscal = c001_b.data_normal
                   AND movto_e_s <> '9'
                   AND dat_lanc_pis_cofins <> data_fiscal
                   AND EXISTS
                           (SELECT 1
                              FROM x08_itens_merc xim
                             WHERE xim.cod_empresa = a.cod_empresa
                               AND xim.cod_estab = a.cod_estab
                               AND xim.data_fiscal = a.data_fiscal
                               AND xim.movto_e_s = a.movto_e_s
                               AND xim.norm_dev = a.norm_dev
                               AND xim.ident_docto = a.ident_docto
                               AND xim.ident_fis_jur = a.ident_fis_jur
                               AND xim.num_docfis = a.num_docfis
                               AND xim.serie_docfis = a.serie_docfis
                               AND xim.sub_serie_docfis = a.sub_serie_docfis
                               AND xim.ident_cfo = ANY (SELECT ident_cfo
                                                          FROM msaf.x2012_cod_fiscal
                                                         WHERE cod_cfo IN ( '1253'
                                                                          , '2253' )));

                commit_loga ( 04
                            , 'c'
                            , SQL%ROWCOUNT
                            , c001_b.data_safx );

                UPDATE msaf.dwt_docto_fiscal a
                   SET dat_lanc_pis_cofins = data_fiscal
                 WHERE cod_empresa = mcod_empresa
                   AND data_fiscal = c001_b.data_normal
                   AND movto_e_s <> '9'
                   AND dat_lanc_pis_cofins <> data_fiscal
                   AND EXISTS
                           (SELECT 1
                              FROM dwt_itens_merc dim
                             WHERE dim.cod_empresa = a.cod_empresa
                               AND dim.cod_estab = a.cod_estab
                               AND dim.data_fiscal = a.data_fiscal
                               AND dim.movto_e_s = a.movto_e_s
                               AND dim.norm_dev = a.norm_dev
                               AND dim.ident_docto = a.ident_docto
                               AND dim.ident_fis_jur = a.ident_fis_jur
                               AND dim.num_docfis = a.num_docfis
                               AND dim.serie_docfis = a.serie_docfis
                               AND dim.sub_serie_docfis = a.sub_serie_docfis
                               AND dim.ident_cfo = ANY (SELECT ident_cfo
                                                          FROM msaf.x2012_cod_fiscal
                                                         WHERE cod_cfo IN ( '1253'
                                                                          , '2253' )));

                commit_loga ( 04
                            , 'd'
                            , SQL%ROWCOUNT
                            , c001_b.data_safx );
            END LOOP;

            loga ( 'Fim  do Passo 2 - CSTs, etc' );
            loga ( '=============================================================================' );

            loga ( 'Correções SPED PIS/COFINS - Passo 2b - Horários dos cupons'
                 , tela => TRUE );
            tot_rows := 0;

            FOR c001_c IN c_datas ( v_data_ini
                                  , v_data_fim ) LOOP
                UPDATE x993_capa_cupom_ecf x993
                   SET hora_emissao_fim = '120000'
                 WHERE cod_empresa = mcod_empresa
                   AND x993.data_emissao = c001_c.data_normal
                   AND ( TO_NUMBER ( SUBSTR ( TO_CHAR ( hora_emissao_fim
                                                      , 'FM000000' )
                                            , 5
                                            , 2 ) ) >= 60 --SEGUNDOS
                     OR TO_NUMBER ( SUBSTR ( TO_CHAR ( hora_emissao_fim
                                                     , 'FM000000' )
                                           , 3
                                           , 2 ) ) >= 60 --MINUTOS
                     OR TO_NUMBER ( SUBSTR ( TO_CHAR ( hora_emissao_fim
                                                     , 'FM000000' )
                                           , 1
                                           , 2 ) ) >= 24 --HORAS
                     OR ( TO_NUMBER ( SUBSTR ( TO_CHAR ( hora_emissao_fim
                                                       , 'FM000000' )
                                             , 1
                                             , 2 ) ) <= 02 --HORAS
                     AND EXISTS
                             (SELECT 1
                                FROM x991_capa_reducao_ecf x991
                               WHERE x991.cod_empresa = x993.cod_empresa
                                 AND x991.cod_estab = x993.cod_estab
                                 AND x991.ident_caixa_ecf = x993.ident_caixa_ecf
                                 AND x991.data_fiscal = x993.data_emissao
                                 AND x993.num_coo BETWEEN x991.num_coo_ini AND x991.num_coo_fim) ) );

                num_rows := SQL%ROWCOUNT;
                tot_rows := tot_rows + num_rows;
                loga (    'Loop - '
                       || TO_CHAR ( c001_c.data_normal
                                  , 'YYYY-MM-DD' )
                       || ' ['
                       || num_rows
                       || '/'
                       || tot_rows
                       || ']' );
                COMMIT;
            END LOOP;

            loga ( 'Correções SPED PIS/COFINS - Passo 2b - Horários dos cupons - FIM'
                 , tela => TRUE );

            loga ( 'Fim do script!'
                 , tela => TRUE );
            v_proc_status := 2; --SUCESSO
        ----------------------------------------------------------------------------------------------------------
        ELSIF p_script = '002' THEN
            -- Script: UNION SELECT ''002'',''002 - Carga Bloco P - X185 e P210'' FROM DUAL
            loga ( 'Iniciando script "Carga Bloco P"' );
            lib_proc.add_header ( '002 - Carga Bloco P - X185 e P210'
                                , 1
                                , 1 );
            lib_proc.add_header ( ' ' );

            loga ( 'Início do DELETE da X185'
                 , tela => TRUE );

            DELETE FROM msaf.x185_contrib_prev
                  WHERE cod_empresa = mcod_empresa
                    AND cod_receita = '299101'
                    AND discri_ativ_cont_prev =
                            '9999999932110106                                                              000000010000'
                    AND data_fim = LAST_DAY ( v_data_ini );

            COMMIT;

            IF mcod_empresa = 'DP' THEN
                v_criterio1 := 'DSP%';
                v_criterio2 := 'VD%';
            ELSE
                v_criterio1 := 'FDP%';
                v_criterio2 := v_criterio1;
            END IF;

            FOR c_estab_x993 IN lista_estabs_x993 ( mcod_empresa
                                                  , v_data_ini
                                                  , v_data_fim ) LOOP
                loga (
                          'INICIO - Loop INSERT MSAF.X185_CONTRIB_PREV ['
                       || c_estab_x993.cod_estab
                       || '] ('
                       || v_data_ini
                       || ' - '
                       || v_data_fim
                       || ')'
                );

                INSERT INTO msaf.x185_contrib_prev ( cod_empresa --VARCHAR2(3 BYTE)      NOT NULL
                                                   , cod_estab --VARCHAR2(6 BYTE)      NOT NULL
                                                   , data_ini --DATE                  NOT NULL
                                                   , cod_receita --VARCHAR2(6 BYTE)      NOT NULL
                                                   , discri_ativ_cont_prev --VARCHAR2(90 BYTE)     NOT NULL
                                                   , data_fim --DATE
                                                   , ident_ativ_cont_prev --NUMBER(5,0)
                                                   , ident_conta --NUMBER(12,0)
                                                   , ident_custo --NUMBER(12,0)
                                                   , vlr_rec_brt --NUMBER(17,2)
                                                   , vlr_rec_brt_ativ --NUMBER(17,2)
                                                   , vlr_rec_brt_demais_ativ --NUMBER(17,2)
                                                   , vlr_exc_rec_brt --NUMBER(17,2)
                                                   , vlr_base_cont_prev --NUMBER(17,2)
                                                   , vlr_aliq_cont_prev --NUMBER(12,4)
                                                   , vlr_cont_prev --NUMBER(17,2)
                                                   , dsc_complementar --VARCHAR2(255 BYTE)
                                                   , num_processo --NUMBER(12,0)
                                                   , ind_gravacao --CHAR(1 BYTE)
                                                   , ident_scp --NUMBER(12,0)
                                                               )
                    SELECT mcod_empresa
                         , -- COD_EMPRESA
                          c_estab_x993.cod_estab
                         , -- COD_ESTAB
                          TO_DATE (    '01'
                                    || TO_CHAR ( v_data_ini
                                               , 'MMYYYY' )
                                  , 'DDMMYYYY' )
                         , -- DATA_INI
                          '299101'
                         , -- COD_RECEITA
                          '9999999932110106                                                              000000010000'
                         , -- DISCRI_ATIV_CONT_PREV
                          LAST_DAY ( v_data_ini )
                         , -- DATA_FIM
                           ( SELECT ident_ativ_cont_prev
                               FROM msaf.dwt_ativ_cont_prev dacp
                              WHERE cod_ativ_cont_prev = '99999999'
                                AND data_ini_vigencia <= (SELECT MAX ( sdacp.data_ini_vigencia )
                                                            FROM msaf.dwt_ativ_cont_prev sdacp
                                                           WHERE sdacp.cod_ativ_cont_prev = dacp.cod_ativ_cont_prev
                                                             AND sdacp.data_ini_vigencia <= v_data_ini) )
                         , --ident_ativ_cont_prev
                           ( SELECT ident_conta
                               FROM msaf.x2002_plano_contas x2002
                              WHERE cod_conta = '32110106'
                                AND valid_conta = (SELECT MAX ( sx2002.valid_conta )
                                                     FROM msaf.x2002_plano_contas sx2002
                                                    WHERE sx2002.cod_conta = x2002.cod_conta
                                                      AND sx2002.valid_conta <= v_data_ini) )
                         , NULL
                         , --ident_conta
                          NVL ( a.vlr_venda_liquida_x991, 0 )
                           + NVL ( b.desconto_ddg, 0 )
                           + NVL ( g.cancelamento_red_z, 0 )
                           + NVL ( venda_bruta_sat, 0 )
                           + NVL ( j.vlr_item_nf, 0 )
                         , -- VALOR_RECEITA_BRUTA_TOTAL
                          NVL ( c.venda_perfumaria, 0 ) + NVL ( e.venda_perf_sat, 0 ) + NVL ( j.vlr_perfumaria_nf, 0 )
                         , -- VALOR_RECEITA_BRUTA_ATIVIDADE
                          NVL ( a.vlr_venda_liquida_x991, 0 )
                           + NVL ( b.desconto_ddg, 0 )
                           + NVL ( g.cancelamento_red_z, 0 )
                           + NVL ( venda_bruta_sat, 0 )
                           + NVL ( j.vlr_item_nf, 0 )
                           - NVL ( c.venda_perfumaria, 0 )
                           - NVL ( e.venda_perf_sat, 0 )
                           - NVL ( j.vlr_perfumaria_nf, 0 )
                         , --VALOR_DEMAIS_ATIVIDADES
                          NVL ( valor_exclusoes_rec_bruta, 0 ) + NVL ( j.vlr_desc_nf, 0 ) + NVL ( j.vlr_canc_nf, 0 )
                         , -- VALOR_EXCLUSOES_REC_BRUTA
                          NVL ( c.venda_perfumaria, 0 )
                           + NVL ( e.venda_perf_sat, 0 )
                           + NVL ( j.vlr_perfumaria_nf, 0 )
                           - (   NVL ( valor_exclusoes_rec_bruta, 0 )
                               + NVL ( j.vlr_desc_nf, 0 )
                               + NVL ( j.vlr_canc_nf, 0 ) )
                         , -- VLR_BASE_CONT_PREV
                           1
                         , -- VLR_ALIQ_CONT_PREV
                          ROUND (
                                    (   NVL ( c.venda_perfumaria, 0 )
                                      + NVL ( e.venda_perf_sat, 0 )
                                      + NVL ( j.vlr_perfumaria_nf, 0 )
                                      - (   NVL ( valor_exclusoes_rec_bruta, 0 )
                                          + NVL ( j.vlr_desc_nf, 0 )
                                          + NVL ( j.vlr_canc_nf, 0 ) ) )
                                  * 0.01
                                , 2
                           )
                         , -- VLR_CONT_PREV
                           NULL
                         , -- DSC_COMPLEMENTAR
                          123
                         , -- NUM_PROCESSO
                          4
                         , -- IND_GRAVACAO
                          NULL -- IDENT_SCP
                      --- NVL (B.DESCONTO_DDG, 0)+NVL (G.CANCELAMENTO_RED_Z, 0) SOMA_DDG_MAIS_CANC_REDZ,

                      FROM (SELECT   a.cod_estab
                                   , SUM ( vlr_venda_bruta ) vlr_venda_bruta_x991
                                   , SUM ( vlr_venda_liq ) vlr_venda_liquida_x991
                                FROM msaf.x991_capa_reducao_ecf a
                               WHERE a.cod_estab = c_estab_x993.cod_estab
                                 AND a.data_fiscal BETWEEN v_data_ini AND v_data_fim
                            GROUP BY a.cod_estab) a
                         , (SELECT   b.cod_estab
                                   , SUM ( b.vlr_desc_capa ) desconto_ddg
                                FROM msaf.x993_capa_cupom_ecf b
                               WHERE b.cod_estab = c_estab_x993.cod_estab
                                 AND b.data_emissao BETWEEN v_data_ini AND v_data_fim
                            GROUP BY b.cod_estab) b
                         , (SELECT   c.cod_estab
                                   , SUM ( c.vlr_item ) venda_perfumaria
                                FROM msaf.x994_item_cupom_ecf c
                                   , msaf.x2013_produto d
                                   , msaf.grupo_produto e
                               WHERE c.ident_produto = d.ident_produto
                                 AND d.ident_grupo_prod = e.ident_grupo_prod
                                 AND cod_estab = c_estab_x993.cod_estab
                                 AND e.cod_grupo_prod = 'PERF'
                                 AND c.data_emissao BETWEEN v_data_ini AND v_data_fim
                                 AND ind_situacao_item = '1'
                            GROUP BY c.cod_estab) c
                         , (SELECT   sat.cod_estab
                                   , SUM ( sat.vlr_contab_item ) venda_bruta_sat
                                FROM msaf.dwt_itens_merc sat
                                   , msaf.x2013_produto f
                                   , msaf.grupo_produto g
                               WHERE sat.ident_produto = f.ident_produto
                                 AND f.ident_grupo_prod = g.ident_grupo_prod
                                 AND sat.cod_estab = c_estab_x993.cod_estab
                                 AND sat.ident_docto IN ( SELECT ident_docto
                                                            FROM msaf.x2005_tipo_docto
                                                           WHERE cod_docto IN ( 'CF-E'
                                                                              , 'SAT' ) )
                                 AND sat.data_fiscal BETWEEN v_data_ini AND v_data_fim
                            GROUP BY sat.cod_estab) d
                         , (SELECT   sat.cod_estab
                                   , SUM ( sat.vlr_contab_item ) venda_perf_sat
                                FROM msaf.dwt_itens_merc sat
                                   , msaf.x2013_produto f
                                   , msaf.grupo_produto g
                               WHERE sat.ident_produto = f.ident_produto
                                 AND f.ident_grupo_prod = g.ident_grupo_prod
                                 AND sat.cod_estab = c_estab_x993.cod_estab
                                 AND g.cod_grupo_prod = 'PERF'
                                 AND sat.ident_docto IN ( SELECT ident_docto
                                                            FROM msaf.x2005_tipo_docto
                                                           WHERE cod_docto IN ( 'CF-E'
                                                                              , 'SAT' ) )
                                 AND sat.data_fiscal BETWEEN v_data_ini AND v_data_fim
                            GROUP BY sat.cod_estab) e
                         , (SELECT   des.cod_estab
                                   , SUM ( vlr_oper_desc_icms ) desconto_red_z
                                FROM msaf.x991_capa_reducao_ecf des
                               WHERE des.cod_estab = c_estab_x993.cod_estab
                                 AND des.data_fiscal BETWEEN v_data_ini AND v_data_fim
                            GROUP BY des.cod_estab) f
                         , (SELECT   canc.cod_estab
                                   , SUM ( vlr_oper_canc_icms ) cancelamento_red_z
                                FROM msaf.x991_capa_reducao_ecf canc
                               WHERE canc.cod_estab = c_estab_x993.cod_estab
                                 AND canc.data_fiscal BETWEEN v_data_ini AND v_data_fim
                            GROUP BY canc.cod_estab) g
                         , estabelecimento h
                         , ( SELECT   x994.cod_estab
                                    , NVL ( SUM ( x994.vlr_item_canc ), 0 ) + NVL ( SUM ( x994.vlr_desc ), 0 )
                                          valor_exclusoes_rec_bruta
                                 FROM msaf.x994_item_cupom_ecf x994
                                    , msaf.x2013_produto f
                                    , msaf.grupo_produto g
                                WHERE x994.ident_produto = f.ident_produto
                                  AND f.ident_grupo_prod = g.ident_grupo_prod
                                  AND x994.cod_estab = c_estab_x993.cod_estab
                                  AND g.cod_grupo_prod = 'PERF'
                                  AND x994.data_emissao BETWEEN v_data_ini AND v_data_fim
                             GROUP BY x994.cod_estab ) i
                         , ( SELECT   a.cod_empresa cod_empresa
                                    , a.cod_estab cod_estab
                                    , SUM ( b.vlr_contab_item ) vlr_item_nf
                                    , SUM ( DECODE ( a.situacao, 'N', b.vlr_desconto, 0 ) ) vlr_desc_nf
                                    , SUM ( DECODE ( a.situacao, 'S', b.vlr_contab_item, 0 ) ) vlr_canc_nf
                                    , SUM (
                                            CASE
                                                WHEN d.cod_grupo_prod = 'PERF' THEN NVL ( b.vlr_contab_item, 0 )
                                                ELSE 0
                                            END
                                      )
                                          vlr_perfumaria_nf
                                 FROM msaf.dwt_docto_fiscal a
                                    , msaf.dwt_itens_merc b
                                    , msaf.x2012_cod_fiscal c
                                    , msaf.grupo_produto d
                                    , msaf.x2013_produto e
                                WHERE a.cod_empresa = mcod_empresa
                                  AND a.cod_estab = c_estab_x993.cod_estab
                                  AND a.data_fiscal BETWEEN v_data_ini AND v_data_fim
                                  AND a.ident_fis_jur IN ( SELECT aa.ident_fis_jur
                                                             FROM msaf.x04_pessoa_fis_jur aa
                                                            WHERE ( aa.cod_fis_jur LIKE v_criterio1
                                                                OR aa.cod_fis_jur LIKE v_criterio2 ) )
                                  AND a.ident_docto_fiscal = b.ident_docto_fiscal
                                  AND b.ident_cfo = c.ident_cfo(+)
                                  AND b.ident_produto = e.ident_produto
                                  AND e.ident_grupo_prod = d.ident_grupo_prod
                                  AND c.cod_cfo IN ( '5102'
                                                   , '6102'
                                                   , '5403'
                                                   , '6403'
                                                   , '5405'
                                                   , '6405' )
                             GROUP BY a.cod_empresa
                                    , a.cod_estab ) j
                         , (SELECT   x202.cod_estab
                                   , NVL ( SUM ( x202.vlr_desconto ), 0 ) valor_exclusoes_rec_bruta_sat
                                FROM msaf.dwt_itens_merc x202
                                   , msaf.x2013_produto f
                                   , msaf.grupo_produto g
                               WHERE x202.ident_produto = f.ident_produto
                                 AND f.ident_grupo_prod = g.ident_grupo_prod
                                 AND x202.cod_empresa = mcod_empresa
                                 AND x202.cod_estab = c_estab_x993.cod_estab
                                 AND g.cod_grupo_prod = 'PERF'
                                 AND x202.ident_docto IN ( SELECT ident_docto
                                                             FROM msaf.x2005_tipo_docto
                                                            WHERE cod_docto IN ( 'CF-E'
                                                                               , 'SAT' ) )
                                 AND x202.data_fiscal BETWEEN v_data_ini AND v_data_fim
                            GROUP BY x202.cod_estab) k
                     WHERE h.cod_estab = c_estab_x993.cod_estab
                       AND h.cod_estab = a.cod_estab(+)
                       AND h.cod_estab = b.cod_estab(+)
                       AND h.cod_estab = c.cod_estab(+)
                       AND h.cod_estab = d.cod_estab(+)
                       AND h.cod_estab = e.cod_estab(+)
                       AND h.cod_estab = f.cod_estab(+)
                       AND h.cod_estab = g.cod_estab(+)
                       AND h.cod_estab = i.cod_estab(+)
                       AND h.cod_estab = j.cod_estab(+)
                       AND h.cod_estab = k.cod_estab(+);

                loga (
                          'FIM - Loop INSERT MSAF.X185_CONTRIB_PREV ['
                       || c_estab_x993.cod_estab
                       || '] ('
                       || SQL%ROWCOUNT
                       || ')'
                );
                COMMIT;
            END LOOP;

            loga ( 'Início do DELETE do P210'
                 , tela => TRUE );

            DELETE FROM msaf.epc_reg_ajt_p210
                  WHERE cod_empresa = mcod_empresa
                    AND data_competencia = TO_DATE (    '01'
                                                     || TO_CHAR ( v_data_ini
                                                                , 'MMYYYY' )
                                                   , 'DDMMYYYY' );

            COMMIT;

            loga ( 'Início do INSERT do P210'
                 , tela => TRUE );

            --P210
            INSERT INTO msaf.epc_reg_ajt_p210 ( cod_empresa
                                              , cod_estab
                                              , data_competencia
                                              , periodo_ref
                                              , cod_receita
                                              , ind_aj
                                              , vl_aj
                                              , cod_aj
                                              , num_doc
                                              , dsc_aj
                                              , dt_ref )
                SELECT *
                  FROM (SELECT   ddf.cod_empresa cod_empresa
                               , ddf.cod_estab cod_estab
                               , TO_DATE (    '01'
                                           || TO_CHAR ( MIN ( ddf.data_fiscal )
                                                      , 'MMYYYY' )
                                         , 'DDMMYYYY' )
                                     data_competencia
                               , TO_DATE (    '01'
                                           || TO_CHAR ( MIN ( ddf.data_fiscal )
                                                      , 'MMYYYY' )
                                         , 'DDMMYYYY' )
                                     periodo_ref
                               , '299101' cod_receita
                               , 0 ind_aj
                               , SUM ( dim.vlr_contab_item ) / 100 vl_aj
                               , '06' cod_aj
                               , TO_CHAR ( v_data_ini
                                         , 'MM/YYYY' )
                                     num_doc
                               , 'DEVOLUCAO DE VENDA' dsc_aj
                               , LAST_DAY ( TO_DATE (    '01'
                                                      || TO_CHAR ( MIN ( ddf.data_fiscal )
                                                                 , 'MMYYYY' )
                                                    , 'DDMMYYYY' ) )
                                     dt_ref
                            FROM msaf.dwt_docto_fiscal ddf
                               , msaf.dwt_itens_merc dim
                               , msaf.x2013_produto x2013
                               , msaf.grupo_produto grpp
                           WHERE ddf.cod_empresa = mcod_empresa
                             AND ddf.data_fiscal BETWEEN v_data_ini AND v_data_fim
                             AND dim.ident_docto_fiscal = ddf.ident_docto_fiscal
                             AND dim.ident_cfo = ANY (SELECT ident_cfo
                                                        FROM msaf.x2012_cod_fiscal x2012
                                                       WHERE cod_cfo IN ( '1202'
                                                                        , '1411' ))
                             AND x2013.ident_produto = dim.ident_produto
                             AND grpp.ident_grupo_prod = x2013.ident_grupo_prod
                             AND grpp.cod_grupo_prod = 'PERF'
                        GROUP BY ddf.cod_empresa
                               , ddf.cod_estab) a
                 WHERE NOT EXISTS
                           (SELECT 1
                              FROM msaf.epc_reg_ajt_p210 e
                             WHERE e.cod_empresa = a.cod_empresa
                               AND e.cod_estab = a.cod_estab
                               AND e.data_competencia = a.data_competencia);

            loga ( 'Fim do script!'
                 , tela => TRUE );
            v_proc_status := 2; --SUCESSO
        ----------------------------------------------------------------------------------------------------------
        --ELSIF P_SCRIPT = '003' THEN
        ---            lib_proc.add('         1         2         3         4         5         6         7         8        9         10        11        12         13       14        15');
        ---            lib_proc.add('123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890');
        END IF; --IF P_SCRIPT = '001' THEN ... ELSIF .......

        v_s_proc_status :=
            CASE v_proc_status
                WHEN 0 THEN 'ERROI#0' --NUNCA DEVE SER 0, POIS JÁ VIRA 1 NO INÍCIO!
                WHEN 1 THEN 'ERROI#1' --AINDA ESTÁ EM PROCESSO!??!? ERRO NO PROCESSO!
                WHEN 2 THEN 'SUCESSO'
                WHEN 3 THEN 'AVISOS'
                WHEN 4 THEN 'ERRO'
                ELSE 'ERROI#' || v_proc_status
            END;

        loga ( 'FIM DO PROCESSAMENTO, STATUS FINAL: [' || v_s_proc_status || ']' );
        msafi.dsp_control.updateprocess ( v_s_proc_status );
        lib_proc.close ( );

        COMMIT;
        RETURN mproc_id;
    EXCEPTION
        WHEN OTHERS THEN
            --MSAFI.DSP_CONTROL.LOG_CHECKPOINT(SQLERRM,'Erro não tratado, relatórios customizados');
            lib_proc.add_log ( 'Erro não tratado: ' || SQLERRM
                             , 1 );
            loga ( 'Abortando execução' );
            lib_proc.close;
            COMMIT;
            RETURN mproc_id;
    END; /* FUNCTION EXECUTAR */
BEGIN
    --configura as variáveis para funções regexp
    v_proc_9xx := '^' || mcod_empresa || '9[0-9]{2}$';
    v_proc_dep := '^' || mcod_empresa || '9[0-9][1-9]$';
    v_proc_loj :=
           '^'
        || mcod_empresa
        || '[0-8][0-9]{'
        || TO_CHAR ( 5 - LENGTH ( mcod_empresa )
                   , 'FM9' )
        || '}$';
    v_proc_est :=
           '^'
        || mcod_empresa
        || '[0-9]{3,'
        || TO_CHAR ( 6 - LENGTH ( mcod_empresa )
                   , 'FM9' )
        || '}$';
    v_proc_estvd :=
           '^VD[0-9]{3,'
        || TO_CHAR ( 6 - LENGTH ( mcod_empresa )
                   , 'FM9' )
        || '}$';
END dsp_sped_contrib_scpt_cproc;
/
SHOW ERRORS;
