Prompt Package Body DSP_SPED_FISCAL_SCPT_CPROC;
--
-- DSP_SPED_FISCAL_SCPT_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dsp_sped_fiscal_scpt_cproc
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
                            SELECT ''001'',''001 - Atualiza NFs de Entrada'' FROM DUAL
                      UNION SELECT ''002'',''002 - Carrega Dados Registro C176'' FROM DUAL
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
        RETURN 'SPED Fiscal - Scripts';
    END;

    FUNCTION tipo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Processos - Fiscal';
    END;

    FUNCTION versao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'VERSAO 1.0';
    END;

    FUNCTION descricao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Scripts auxiliares do SPED Fiscal';
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
                   , p_i_tela IN BOOLEAN DEFAULT FALSE
                   , p_i_dttm IN BOOLEAN DEFAULT TRUE )
    IS
        vtexto VARCHAR2 ( 1024 );
    BEGIN
        IF p_i_tela THEN
            lib_proc.add ( p_i_texto );
        END IF;

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
        msafi.dsp_control.writelog ( 'INFO'
                                   , p_i_texto );
    END;

    FUNCTION executar ( p_script VARCHAR2
                      , p_mes VARCHAR2
                      , p_ano VARCHAR2 )
        RETURN INTEGER
    IS
        mproc_id INTEGER;

        v_carregado INTEGER;
        v_equalizado VARCHAR2 ( 3 );

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
        v_data_carga DATE := SYSDATE;

        num_rows NUMBER;
        tot_rows NUMBER;
    BEGIN
        mproc_id :=
            lib_proc.new ( 'DSP_SPED_FISCAL_SCPT_CPROC'
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

        msafi.dsp_control.createprocess ( 'CUST_SPDFC_DC_02' --P_I_PROCID            IN VARCHAR2             , --VARCHAR2(16)
                                        , 'CUSTOMIZADO MASTERSAF: SCRIPTS SPED FISCAL' --P_I_PROC_DESCR        IN VARCHAR2             , --VARCHAR2(64)
                                        , NULL --P_I_DATA_INI          IN DATE     DEFAULT NULL,
                                        , NULL --P_I_DATA_FIM          IN DATE     DEFAULT NULL,
                                        , p_script --P_I_DETALHES1         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , p_mes --P_I_DETALHES2         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , p_ano --P_I_DETALHES3         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , NULL --P_I_DETALHES4         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , musuario --P_I_USER              IN VARCHAR2 DEFAULT NULL  --VARCHAR2(64)
                                                   );
        v_proc_status := 1; --EM PROCESSO

        --EXECUTE IMMEDIATE 'ALTER SESSION ENABLE PARALLEL DML';
        ----------------------------------------------------------------------------------------------------------
        IF p_script = '001' THEN
            -- Script: SELECT ''001'',''001 - Atualiza NFs de Entrada'' FROM DUAL
            loga ( 'Iniciando script "Atualiza NFs de Entrada"' );
            lib_proc.add_header ( '001 - Atualiza NFs de Entrada'
                                , 1
                                , 1 );
            lib_proc.add_header ( ' ' );

            loga ( 'Atualizaremos a tabela temporária de NFs de entrada'
                 , TRUE );
            loga ( 'Este script roda no mês escolhido e no anterior'
                 , TRUE );

            FOR c_est IN c_estabs LOOP
                FOR c1 IN c_datas ( ADD_MONTHS ( v_data_ini
                                               , -1 )
                                  , v_data_fim ) LOOP
                    DELETE FROM msafi.dsp_sped_x08_c176
                          WHERE cod_empresa = c_est.cod_empresa
                            AND cod_estab = c_est.cod_estab
                            AND data_fiscal = c1.data_normal;

                    -- Aqui não incluímos os filtros dos tipos de entradas que devemos usar, pois se os
                    -- critérios mudarem futuramente, não será necessário carregar todo o passado de novo.
                    -- Os filtros de CFOP, etc; são feitos depois, na hora de carregar a tabela temporária para UPDATE.
                    INSERT INTO msafi.dsp_sped_x08_c176 ( cod_empresa
                                                        , cod_estab
                                                        , dt_carga
                                                        , num_docfis
                                                        , serie_docfis
                                                        , sub_serie_docfis
                                                        , movto_e_s
                                                        , data_fiscal
                                                        , num_item
                                                        , cod_produto
                                                        , quantidade
                                                        , cod_fis_jur
                                                        , cod_cfo
                                                        , cod_natureza_op
                                                        , vlr_base_icmss_n_escrit
                                                        , vlr_base_icmss
                                                        , vlr_tributo_icmss
                                                        , tem_vlr_base_icmss
                                                        , tem_vlr_tributo_icmss
                                                        , vlr_base_icms_1
                                                        , vlr_base_icms_2
                                                        , vlr_base_icms_3
                                                        , vlr_base_icms_4
                                                        , vlr_tributo_icms
                                                        , vlr_unit
                                                        , vlr_item
                                                        , vlr_desconto
                                                        , vlr_contab_item )
                        --                    SELECT /*+ parallel(X07) parallel(X08) parallel(X2013) parallel(X2012) parallel(X04) parallel(X2006) */
                        --                    SELECT /*+ parallel(4) */
                        SELECT x08.cod_empresa
                             , x08.cod_estab
                             , v_data_carga
                             , x08.num_docfis
                             , x08.serie_docfis
                             , x08.sub_serie_docfis
                             , x08.movto_e_s
                             , x08.data_fiscal
                             , x08.num_item
                             , x2013.cod_produto
                             , x08.quantidade
                             , x04.cod_fis_jur
                             , x2012.cod_cfo
                             , x2006.cod_natureza_op
                             , NVL ( x08.vlr_base_icmss_n_escrit, 0 )
                             , NVL ( ( SELECT SUM ( vlr_base )
                                         FROM x08_base_merc x08b
                                        WHERE x08b.cod_empresa = c_est.cod_empresa --X08.COD_EMPRESA
                                          AND x08b.cod_estab = c_est.cod_estab --X08.COD_ESTAB
                                          AND x08b.data_fiscal = c1.data_normal --X08.DATA_FISCAL
                                          AND x08b.movto_e_s = x08.movto_e_s
                                          AND x08b.norm_dev = x08.norm_dev
                                          AND x08b.ident_docto = x08.ident_docto
                                          AND x08b.ident_fis_jur = x08.ident_fis_jur
                                          AND x08b.num_docfis = x08.num_docfis
                                          AND x08b.serie_docfis = x08.serie_docfis
                                          AND x08b.sub_serie_docfis = x08.sub_serie_docfis
                                          AND x08b.discri_item = x08.discri_item
                                          AND x08b.cod_tributo = 'ICMS-S' )
                                   , 0 )
                                   vlr_base_icmss
                             , NVL ( ( SELECT SUM ( vlr_tributo )
                                         FROM x08_trib_merc x08t
                                        WHERE x08t.cod_empresa = c_est.cod_empresa --X08.COD_EMPRESA
                                          AND x08t.cod_estab = c_est.cod_estab --X08.COD_ESTAB
                                          AND x08t.data_fiscal = c1.data_normal --X08.DATA_FISCAL
                                          AND x08t.movto_e_s = x08.movto_e_s
                                          AND x08t.norm_dev = x08.norm_dev
                                          AND x08t.ident_docto = x08.ident_docto
                                          AND x08t.ident_fis_jur = x08.ident_fis_jur
                                          AND x08t.num_docfis = x08.num_docfis
                                          AND x08t.serie_docfis = x08.serie_docfis
                                          AND x08t.sub_serie_docfis = x08.sub_serie_docfis
                                          AND x08t.discri_item = x08.discri_item
                                          AND x08t.cod_tributo = 'ICMS-S' )
                                   , 0 )
                                   vlr_tributo_icmss
                             , CASE
                                   WHEN NVL ( ( SELECT SUM ( vlr_base )
                                                  FROM x08_base_merc x08b
                                                 WHERE x08b.cod_empresa = c_est.cod_empresa --X08.COD_EMPRESA
                                                   AND x08b.cod_estab = c_est.cod_estab --X08.COD_ESTAB
                                                   AND x08b.data_fiscal = c1.data_normal --X08.DATA_FISCAL
                                                   AND x08b.movto_e_s = x08.movto_e_s
                                                   AND x08b.norm_dev = x08.norm_dev
                                                   AND x08b.ident_docto = x08.ident_docto
                                                   AND x08b.ident_fis_jur = x08.ident_fis_jur
                                                   AND x08b.num_docfis = x08.num_docfis
                                                   AND x08b.serie_docfis = x08.serie_docfis
                                                   AND x08b.sub_serie_docfis = x08.sub_serie_docfis
                                                   AND x08b.discri_item = x08.discri_item
                                                   AND x08b.cod_tributo = 'ICMS-S' )
                                            , 0 ) > 0 THEN
                                       'S'
                                   ELSE
                                       'N'
                               END
                                   tem_vlr_base_icmss
                             , CASE
                                   WHEN NVL ( ( SELECT SUM ( vlr_tributo )
                                                  FROM x08_trib_merc x08t
                                                 WHERE x08t.cod_empresa = c_est.cod_empresa --X08.COD_EMPRESA
                                                   AND x08t.cod_estab = c_est.cod_estab --X08.COD_ESTAB
                                                   AND x08t.data_fiscal = c1.data_normal --X08.DATA_FISCAL
                                                   AND x08t.movto_e_s = x08.movto_e_s
                                                   AND x08t.norm_dev = x08.norm_dev
                                                   AND x08t.ident_docto = x08.ident_docto
                                                   AND x08t.ident_fis_jur = x08.ident_fis_jur
                                                   AND x08t.num_docfis = x08.num_docfis
                                                   AND x08t.serie_docfis = x08.serie_docfis
                                                   AND x08t.sub_serie_docfis = x08.sub_serie_docfis
                                                   AND x08t.discri_item = x08.discri_item
                                                   AND x08t.cod_tributo = 'ICMS-S' )
                                            , 0 ) > 0 THEN
                                       'S'
                                   ELSE
                                       'N'
                               END
                                   tem_vlr_tributo_icmss
                             , NVL ( ( SELECT vlr_base
                                         FROM x08_base_merc x08b
                                        WHERE x08b.cod_empresa = c_est.cod_empresa --X08.COD_EMPRESA
                                          AND x08b.cod_estab = c_est.cod_estab --X08.COD_ESTAB
                                          AND x08b.data_fiscal = c1.data_normal --X08.DATA_FISCAL
                                          AND x08b.movto_e_s = x08.movto_e_s
                                          AND x08b.norm_dev = x08.norm_dev
                                          AND x08b.ident_docto = x08.ident_docto
                                          AND x08b.ident_fis_jur = x08.ident_fis_jur
                                          AND x08b.num_docfis = x08.num_docfis
                                          AND x08b.serie_docfis = x08.serie_docfis
                                          AND x08b.sub_serie_docfis = x08.sub_serie_docfis
                                          AND x08b.discri_item = x08.discri_item
                                          AND x08b.cod_tributo = 'ICMS'
                                          AND x08b.cod_tributacao = 1 )
                                   , 0 )
                                   vlr_base_icms_1
                             , NVL ( ( SELECT vlr_base
                                         FROM x08_base_merc x08b
                                        WHERE x08b.cod_empresa = c_est.cod_empresa --X08.COD_EMPRESA
                                          AND x08b.cod_estab = c_est.cod_estab --X08.COD_ESTAB
                                          AND x08b.data_fiscal = c1.data_normal --X08.DATA_FISCAL
                                          AND x08b.movto_e_s = x08.movto_e_s
                                          AND x08b.norm_dev = x08.norm_dev
                                          AND x08b.ident_docto = x08.ident_docto
                                          AND x08b.ident_fis_jur = x08.ident_fis_jur
                                          AND x08b.num_docfis = x08.num_docfis
                                          AND x08b.serie_docfis = x08.serie_docfis
                                          AND x08b.sub_serie_docfis = x08.sub_serie_docfis
                                          AND x08b.discri_item = x08.discri_item
                                          AND x08b.cod_tributo = 'ICMS'
                                          AND x08b.cod_tributacao = 2 )
                                   , 0 )
                                   vlr_base_icms_2
                             , NVL ( ( SELECT vlr_base
                                         FROM x08_base_merc x08b
                                        WHERE x08b.cod_empresa = c_est.cod_empresa --X08.COD_EMPRESA
                                          AND x08b.cod_estab = c_est.cod_estab --X08.COD_ESTAB
                                          AND x08b.data_fiscal = c1.data_normal --X08.DATA_FISCAL
                                          AND x08b.movto_e_s = x08.movto_e_s
                                          AND x08b.norm_dev = x08.norm_dev
                                          AND x08b.ident_docto = x08.ident_docto
                                          AND x08b.ident_fis_jur = x08.ident_fis_jur
                                          AND x08b.num_docfis = x08.num_docfis
                                          AND x08b.serie_docfis = x08.serie_docfis
                                          AND x08b.sub_serie_docfis = x08.sub_serie_docfis
                                          AND x08b.discri_item = x08.discri_item
                                          AND x08b.cod_tributo = 'ICMS'
                                          AND x08b.cod_tributacao = 3 )
                                   , 0 )
                                   vlr_base_icms_3
                             , NVL ( ( SELECT vlr_base
                                         FROM x08_base_merc x08b
                                        WHERE x08b.cod_empresa = c_est.cod_empresa --X08.COD_EMPRESA
                                          AND x08b.cod_estab = c_est.cod_estab --X08.COD_ESTAB
                                          AND x08b.data_fiscal = c1.data_normal --X08.DATA_FISCAL
                                          AND x08b.movto_e_s = x08.movto_e_s
                                          AND x08b.norm_dev = x08.norm_dev
                                          AND x08b.ident_docto = x08.ident_docto
                                          AND x08b.ident_fis_jur = x08.ident_fis_jur
                                          AND x08b.num_docfis = x08.num_docfis
                                          AND x08b.serie_docfis = x08.serie_docfis
                                          AND x08b.sub_serie_docfis = x08.sub_serie_docfis
                                          AND x08b.discri_item = x08.discri_item
                                          AND x08b.cod_tributo = 'ICMS'
                                          AND x08b.cod_tributacao = 4 )
                                   , 0 )
                                   vlr_base_icms_4
                             , NVL ( ( SELECT SUM ( vlr_tributo )
                                         FROM x08_trib_merc x08t
                                        WHERE x08t.cod_empresa = c_est.cod_empresa --X08.COD_EMPRESA
                                          AND x08t.cod_estab = c_est.cod_estab --X08.COD_ESTAB
                                          AND x08t.data_fiscal = c1.data_normal --X08.DATA_FISCAL
                                          AND x08t.movto_e_s = x08.movto_e_s
                                          AND x08t.norm_dev = x08.norm_dev
                                          AND x08t.ident_docto = x08.ident_docto
                                          AND x08t.ident_fis_jur = x08.ident_fis_jur
                                          AND x08t.num_docfis = x08.num_docfis
                                          AND x08t.serie_docfis = x08.serie_docfis
                                          AND x08t.sub_serie_docfis = x08.sub_serie_docfis
                                          AND x08t.discri_item = x08.discri_item
                                          AND x08t.cod_tributo = 'ICMS' )
                                   , 0 )
                                   vlr_tributo_icms
                             , x08.vlr_unit
                             , x08.vlr_item
                             , x08.vlr_desconto
                             , x08.vlr_contab_item
                          FROM x07_docto_fiscal x07
                             , x08_itens_merc x08
                             , x2013_produto x2013
                             , x2012_cod_fiscal x2012
                             , x04_pessoa_fis_jur x04
                             , x2006_natureza_op x2006
                         WHERE x07.cod_empresa = c_est.cod_empresa
                           AND x07.cod_estab = c_est.cod_estab
                           AND x07.data_fiscal = c1.data_normal
                           AND x07.situacao = 'N'
                           AND x07.movto_e_s <> '9'
                           --X08
                           AND x08.cod_empresa = c_est.cod_empresa --X07.COD_EMPRESA
                           AND x08.cod_estab = c_est.cod_estab --X07.COD_ESTAB
                           AND x08.data_fiscal = c1.data_normal --X07.DATA_FISCAL
                           AND x08.movto_e_s = x07.movto_e_s
                           AND x08.norm_dev = x07.norm_dev
                           AND x08.ident_docto = x07.ident_docto
                           AND x08.ident_fis_jur = x07.ident_fis_jur
                           AND x08.num_docfis = x07.num_docfis
                           AND x08.serie_docfis = x07.serie_docfis
                           AND x08.sub_serie_docfis = x07.sub_serie_docfis
                           --X2013
                           AND x2013.ident_produto = x08.ident_produto
                           --X2012
                           AND x2012.ident_cfo(+) = x08.ident_cfo
                           --X04
                           AND x04.ident_fis_jur(+) = x07.ident_fis_jur
                           --X2006
                           AND x2006.ident_natureza_op(+) = x08.ident_natureza_op;

                    loga (    'INSERT ['
                           || c_est.cod_estab
                           || '/'
                           || TO_CHAR ( c1.data_normal
                                      , 'DD/MM/YYYY' )
                           || '] Linhas: ['
                           || SQL%ROWCOUNT
                           || ']' );
                    COMMIT;
                END LOOP; --FOR c1 IN C_Datas(ADD_MONTHS(V_DATA_INI,-1),V_DATA_FIM)
            END LOOP; --FOR c_Est in C_Estabs

            loga ( 'Fim da carga, calculando as estatísticas'
                 , TRUE );
            msafi.dsp_aux.calcstats_msafi ( 'DSP_SPED_X08_C176' );

            loga ( 'Fim do script!'
                 , TRUE );
            v_proc_status := 2; --SUCESSO
        ----------------------------------------------------------------------------------------------------------
        ELSIF p_script = '002' THEN
            -- Script: UNION SELECT ''002'',''002 - Carrega Dados Registro C176'' FROM DUAL
            loga ( 'Iniciando script "Carrega Dados Registro C176"' );
            lib_proc.add_header ( '002 - Carrega Dados Registro C176'
                                , 1
                                , 1 );
            lib_proc.add_header ( ' ' );

            loga ( 'Inicio do script, favor VERIFICAR O LOG!'
                 , TRUE );
            loga ( 'Certifique que o passo 1 foi executado para todos os meses anteriores.'
                 , TRUE );

            FOR c_est IN c_estabs LOOP
                v_carregado := 0;
                v_equalizado := 'NAO';

                loga ( 'Verificando se o período está carregado' );

                BEGIN
                    SELECT /*+ parallel(a) */
                          COUNT ( DISTINCT data_fiscal )
                      INTO v_carregado
                      FROM msafi.dsp_sped_x08_c176 a
                     WHERE cod_empresa = c_est.cod_empresa
                       AND cod_estab = c_est.cod_estab
                       AND data_fiscal BETWEEN v_data_ini AND v_data_fim
                       AND dt_carga >= TRUNC ( SYSDATE - 4 );
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        v_carregado := 0;
                END;

                loga ( 'Verificando se o período está equalizado' );

                SELECT CASE
                           WHEN NVL ( ( SELECT COUNT ( 0 )
                                          FROM msaf.x08_itens_merc a
                                         WHERE cod_empresa = c_est.cod_empresa
                                           AND cod_estab = c_est.cod_estab
                                           AND data_fiscal BETWEEN v_data_ini AND v_data_fim )
                                    , 0 ) = NVL ( ( SELECT COUNT ( 0 )
                                                      FROM msaf.dwt_itens_merc a
                                                     WHERE cod_empresa = c_est.cod_empresa
                                                       AND cod_estab = c_est.cod_estab
                                                       AND data_fiscal BETWEEN v_data_ini AND v_data_fim )
                                                , 0 ) THEN
                               'OK'
                           ELSE
                               'NAO'
                       END
                  INTO v_equalizado
                  FROM DUAL;

                IF v_carregado >= 10
               AND v_equalizado = 'OK' THEN
                    --Utilizando uma temporária de entradas, somente com as últimas entradas de cada produto até a data de inicio
                    -- e também todas as entradas dentro do período, ignorando entradas posteriores a data final
                    -- Também é aqui que incluímos os filtros dos tipos de entradas que devemos usar
                    -- Caso isto mude no futuro, não será necessário carregar todo o passado novamente.
                    --Isto deve "eliminar" uma grande quantidade de linhas desnecessárias
                    msafi.dsp_aux.truncatabela_msafi ( 'DSP_SPED_X08_C176_E_TMP' );
                    loga ( 'Insert na temporária de entrada' );

                    INSERT /*+ APPEND */
                          INTO  msafi.dsp_sped_x08_c176_e_tmp ( cod_empresa
                                                              , cod_estab
                                                              , num_docfis
                                                              , serie_docfis
                                                              , sub_serie_docfis
                                                              , movto_e_s
                                                              , data_fiscal
                                                              , cod_fis_jur
                                                              , num_item
                                                              , cod_produto
                                                              , quantidade
                                                              , cod_cfo
                                                              , cod_natureza_op
                                                              , vlr_base_icmss_n_escrit
                                                              , vlr_base_icmss
                                                              , vlr_tributo_icmss
                                                              , vlr_base_icms_1
                                                              , vlr_base_icms_2
                                                              , vlr_base_icms_3
                                                              , vlr_base_icms_4
                                                              , vlr_tributo_icms
                                                              , vlr_unit
                                                              , vlr_item
                                                              , vlr_desconto
                                                              , vlr_contab_item )
                        SELECT cod_empresa
                             , cod_estab
                             , num_docfis
                             , serie_docfis
                             , sub_serie_docfis
                             , movto_e_s
                             , data_fiscal
                             , cod_fis_jur
                             , num_item
                             , cod_produto
                             , quantidade
                             , cod_cfo
                             , cod_natureza_op
                             , vlr_base_icmss_n_escrit
                             , vlr_base_icmss
                             , vlr_tributo_icmss
                             , vlr_base_icms_1
                             , vlr_base_icms_2
                             , vlr_base_icms_3
                             , vlr_base_icms_4
                             , vlr_tributo_icms
                             , vlr_unit
                             , vlr_item
                             , vlr_desconto
                             , vlr_contab_item
                          FROM msafi.dsp_sped_x08_c176 a
                         WHERE a.cod_empresa = c_est.cod_empresa
                           AND a.cod_estab = c_est.cod_estab
                           AND a.data_fiscal >= (SELECT MAX ( data_fiscal )
                                                   FROM msafi.dsp_sped_x08_c176 b
                                                  WHERE b.cod_empresa = a.cod_empresa
                                                    AND b.cod_estab = a.cod_estab
                                                    AND b.data_fiscal <= v_data_ini
                                                    AND b.cod_produto = a.cod_produto)
                           AND a.data_fiscal <= v_data_fim
                           --vamos pegar somente uma entrada por dia por produto, com os critérios que precisamos
                           AND a.ROWID = (SELECT MAX ( ROWID )
                                            FROM msafi.dsp_sped_x08_c176 b
                                           WHERE b.cod_empresa = a.cod_empresa
                                             AND b.cod_estab = a.cod_estab
                                             AND b.data_fiscal = a.data_fiscal
                                             AND b.cod_produto = a.cod_produto
                                             AND b.cod_cfo IN ( '1403'
                                                              , '2403' )
                                             AND b.cod_natureza_op IN ( 'IST'
                                                                      , 'RST' )
                                             AND b.tem_vlr_base_icmss = 'S'
                                             AND b.tem_vlr_tributo_icmss = 'S');

                    loga ( 'Fim da carga [' || SQL%ROWCOUNT || '], calculando estatísticas' );
                    COMMIT;
                    msafi.dsp_aux.calcstats_msafi ( 'DSP_SPED_X08_C176_E_TMP' );
                    loga ( 'Fim das estatísticas' );

                    FOR c1 IN c_datas ( v_data_ini
                                      , v_data_fim ) LOOP
                        msafi.dsp_aux.truncatabela_msafi ( 'DSP_SPED_X08_C176_S_TMP' );
                        msafi.dsp_aux.calcstats_msafi ( 'DSP_SPED_X08_C176_S_TMP' );

                        INSERT /*+ APPEND */
                              INTO  msafi.dsp_sped_x08_c176_s_tmp ( x08_rowid
                                                                  , dwt_rowid
                                                                  , cod_empresa
                                                                  , cod_estab
                                                                  , num_docfis
                                                                  , serie_docfis
                                                                  , sub_serie_docfis
                                                                  , movto_e_s
                                                                  , data_fiscal
                                                                  , cod_fis_jur
                                                                  , discri_item
                                                                  , num_item
                                                                  , cod_produto
                                                                  , cod_cfo
                                                                  , cod_natureza_op
                                                                  , vlr_base_icmss_n_escrit
                                                                  , vlr_base_icms_orig
                                                                  , dat_di
                                                                  , num_docfis_ref
                                                                  , serie_docfis_ref
                                                                  , sserie_docfis_ref )
                            --                        SELECT /*+ parallel(DDF) parallel(DIM) parallel(X2012) parallel(X04) parallel(X2006) parallel(X2013) parallel(C176_E) parallel(X07) parallel(X08) */
                            SELECT x08.ROWID
                                 , dim.ROWID
                                 , x08.cod_empresa
                                 , x08.cod_estab
                                 , x08.num_docfis
                                 , x08.serie_docfis
                                 , x08.sub_serie_docfis
                                 , x08.movto_e_s
                                 , x08.data_fiscal
                                 , x04.cod_fis_jur
                                 , x08.discri_item
                                 , x08.num_item
                                 , x2013.cod_produto
                                 , x2012.cod_cfo
                                 , x2006.cod_natureza_op
                                 , ( c176_e.vlr_base_icmss_n_escrit / c176_e.quantidade ) * x08.quantidade
                                       AS vlr_base_icmss_n_escrit
                                 , ( c176_e.vlr_base_icms_1 / c176_e.quantidade ) * x08.quantidade
                                       AS vlr_base_icms_orig
                                 , c176_e.data_fiscal AS dat_di
                                 , c176_e.num_docfis AS num_docfis_ref
                                 , c176_e.serie_docfis AS serie_docfis_ref
                                 , c176_e.sub_serie_docfis AS sserie_docfis_ref
                              FROM dwt_docto_fiscal ddf
                                 , dwt_itens_merc dim
                                 , x2012_cod_fiscal x2012
                                 , x04_pessoa_fis_jur x04
                                 , x2006_natureza_op x2006
                                 , x2013_produto x2013
                                 , msafi.dsp_sped_x08_c176_e_tmp c176_e
                                 , x07_docto_fiscal x07
                                 , x08_itens_merc x08
                             WHERE ddf.cod_empresa = c_est.cod_empresa
                               AND ddf.cod_estab = c_est.cod_estab
                               AND ddf.data_fiscal = c1.data_normal
                               AND ddf.situacao = 'N'
                               AND ddf.movto_e_s = '9'
                               --DIM
                               AND dim.ident_docto_fiscal = ddf.ident_docto_fiscal
                               AND dim.vlr_base_icmss > 0
                               AND dim.vlr_tributo_icmss > 0
                               --X2012
                               AND x2012.ident_cfo = dim.ident_cfo
                               AND x2012.cod_cfo IN ( '6152'
                                                    , '6409' )
                               --X04
                               AND x04.ident_fis_jur = ddf.ident_fis_jur
                               --X2006
                               AND x2006.ident_natureza_op = dim.ident_natureza_op
                               AND x2006.cod_natureza_op IN ( 'REV'
                                                            , 'IST'
                                                            , 'RST' )
                               --X2013
                               AND x2013.ident_produto = dim.ident_produto
                               --,MSAFI.DSP_SPED_X08_C176_E_TMP  C176_E
                               --Nesta tabela temos no máximo uma entrada por dia para cada produto por estabelecimento, por isso não preciamos de mais critérios
                               AND c176_e.cod_empresa = c_est.cod_empresa --DDF.COD_EMPRESA
                               AND c176_e.cod_estab = c_est.cod_estab --DDF.COD_ESTAB
                               AND c176_e.cod_produto = x2013.cod_produto
                               AND c176_e.data_fiscal = (SELECT MAX ( data_fiscal )
                                                           FROM msafi.dsp_sped_x08_c176_e_tmp sc176_e
                                                          WHERE sc176_e.cod_empresa = c176_e.cod_empresa
                                                            AND sc176_e.cod_estab = c176_e.cod_estab
                                                            AND sc176_e.cod_produto = c176_e.cod_produto
                                                            AND sc176_e.data_fiscal <= x07.data_fiscal)
                               --07
                               AND x07.cod_empresa = c_est.cod_empresa --DDF.COD_EMPRESA
                               AND x07.cod_estab = c_est.cod_estab --DDF.COD_ESTAB
                               AND x07.data_fiscal = c1.data_normal --DDF.DATA_FISCAL
                               AND x07.movto_e_s = '9' --DDF.MOVTO_E_S
                               AND x07.norm_dev = ddf.norm_dev
                               AND x07.ident_docto = ddf.ident_docto
                               AND x07.ident_fis_jur = ddf.ident_fis_jur
                               AND x07.num_docfis = ddf.num_docfis
                               AND x07.serie_docfis = ddf.serie_docfis
                               AND x07.sub_serie_docfis = ddf.sub_serie_docfis
                               --X08
                               AND x08.cod_empresa = c_est.cod_empresa --DDF.COD_EMPRESA
                               AND x08.cod_estab = c_est.cod_estab --DDF.COD_ESTAB
                               AND x08.data_fiscal = c1.data_normal --DDF.DATA_FISCAL
                               AND x08.movto_e_s = '9' --DDF.MOVTO_E_S
                               AND x08.norm_dev = ddf.norm_dev
                               AND x08.ident_docto = ddf.ident_docto
                               AND x08.ident_fis_jur = ddf.ident_fis_jur
                               AND x08.num_docfis = ddf.num_docfis
                               AND x08.serie_docfis = ddf.serie_docfis
                               AND x08.sub_serie_docfis = ddf.sub_serie_docfis
                               AND x08.discri_item = dim.discri_item;

                        loga (    'INSERT ['
                               || c_est.cod_estab
                               || '/'
                               || TO_CHAR ( c1.data_normal
                                          , 'DD/MM/YYYY' )
                               || '] Linhas: ['
                               || SQL%ROWCOUNT
                               || ']' );
                        COMMIT;
                        msafi.dsp_aux.calcstats_msafi ( 'DSP_SPED_X08_C176_S_TMP' );


                        MERGE /*+ parallel(C176S) */
                             INTO  x08_itens_merc x08
                             USING msafi.dsp_sped_x08_c176_s_tmp c176s
                                ON ( x08.ROWID = c176s.x08_rowid )
                        WHEN MATCHED THEN
                            UPDATE SET x08.vlr_base_icmss_n_escrit = c176s.vlr_base_icmss_n_escrit
                                     , x08.vlr_base_icms_orig = c176s.vlr_base_icms_orig
                                     , x08.dat_di = c176s.dat_di
                                     , x08.num_docfis_ref = c176s.num_docfis_ref
                                     , x08.serie_docfis_ref = c176s.serie_docfis_ref
                                     , x08.sserie_docfis_ref = c176s.sserie_docfis_ref;

                        loga (    'MERGE X08 ['
                               || c_est.cod_estab
                               || '/'
                               || TO_CHAR ( c1.data_normal
                                          , 'DD/MM/YYYY' )
                               || '] Linhas: ['
                               || SQL%ROWCOUNT
                               || ']' );
                        COMMIT;

                        MERGE /*+ parallel(C176S) */
                             INTO  dwt_itens_merc dim
                             USING msafi.dsp_sped_x08_c176_s_tmp c176s
                                ON ( dim.ROWID = c176s.dwt_rowid )
                        WHEN MATCHED THEN
                            UPDATE SET dim.vlr_base_icmss_n_escrit = c176s.vlr_base_icmss_n_escrit
                                     , dim.vlr_base_icms_orig = c176s.vlr_base_icms_orig
                                     , dim.dat_di = c176s.dat_di
                                     , dim.num_docfis_ref = c176s.num_docfis_ref
                                     , dim.serie_docfis_ref = c176s.serie_docfis_ref
                                     , dim.sserie_docfis_ref = c176s.sserie_docfis_ref;

                        loga (    'MERGE DWT ['
                               || c_est.cod_estab
                               || '/'
                               || TO_CHAR ( c1.data_normal
                                          , 'DD/MM/YYYY' )
                               || '] Linhas: ['
                               || SQL%ROWCOUNT
                               || ']' );
                        COMMIT;
                    END LOOP; --FOR c1 IN C_Datas(V_DATA_INI,V_DATA_FIM)
                ELSE
                    IF NOT ( v_carregado >= 10 ) THEN
                        loga ( 'Menos de 10 dias carregados no passo 1, favor verificar. [' || c_est.cod_estab || ']' );
                    END IF;

                    IF NOT ( v_equalizado = 'OK' ) THEN
                        loga ( 'Período não equalizado para o estabelecimento [' || c_est.cod_estab || ']' );
                    END IF;

                    v_proc_status := 3;
                END IF; --IF V_CARREGADO >= 10 AND V_EQUALIZADO = 'OK' THEN
            END LOOP; --FOR c_Est in C_Estabs

            loga ( 'Fim das operações, truncando.' );

            msafi.dsp_aux.truncatabela_msafi ( 'DSP_SPED_X08_C176_E_TMP' );
            msafi.dsp_aux.truncatabela_msafi ( 'DSP_SPED_X08_C176_S_TMP' );


            loga ( 'Fim do script!' );

            IF v_proc_status = 1 THEN
                v_proc_status := 2; --SUCESSO
            END IF;
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
END dsp_sped_fiscal_scpt_cproc;
/
SHOW ERRORS;
