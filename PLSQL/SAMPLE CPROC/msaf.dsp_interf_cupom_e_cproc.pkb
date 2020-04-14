Prompt Package Body DSP_INTERF_CUPOM_E_CPROC;
--
-- DSP_INTERF_CUPOM_E_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dsp_interf_cupom_e_cproc
IS
    mcod_empresa empresa.cod_empresa%TYPE;
    mcod_estab estabelecimento.cod_estab%TYPE;
    musuario usuario_empresa.cod_usuario%TYPE;

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
                           , 'Data Inicial'
                           , --P_DATA_INI
                            'DATE'
                           , 'TEXTBOX'
                           , 'S'
                           , NULL
                           , 'DD/MM/YYYY' );

        lib_proc.add_param ( pstr
                           , 'Data Final'
                           , --P_DATA_FIM
                            'DATE'
                           , 'TEXTBOX'
                           , 'S'
                           , NULL
                           , 'DD/MM/YYYY' );

        lib_proc.add_param ( pstr
                           , 'Cria job de importação'
                           , --P_CRIA_JOB
                            'VARCHAR2'
                           , 'CHECKBOX'
                           , 'N'
                           , 'S'
                           , NULL );

        lib_proc.add_param ( pstr
                           , 'SAFX07   '
                           , 'VARCHAR2'
                           , 'CHECKBOX'
                           , 'N'
                           , 'S'
                           , NULL ); --P_SAFX07
        lib_proc.add_param ( pstr
                           , 'SAFX08   '
                           , 'VARCHAR2'
                           , 'CHECKBOX'
                           , 'N'
                           , 'S'
                           , NULL ); --P_SAFX08

        IF mcod_empresa = 'DSP' THEN
            lib_proc.add_param ( pstr
                               , 'SAFX201  '
                               , 'VARCHAR2'
                               , 'CHECKBOX'
                               , 'N'
                               , 'S'
                               , NULL ); --P_SAFX201
            lib_proc.add_param ( pstr
                               , 'SAFX202  '
                               , 'VARCHAR2'
                               , 'CHECKBOX'
                               , 'N'
                               , 'S'
                               , NULL ); --P_SAFX202
        ELSE
            lib_proc.add_param ( pstr
                               , 'SAFX201  '
                               , 'VARCHAR2'
                               , 'CHECKBOX'
                               , 'N'
                               , 'N'
                               , NULL
                               , NULL
                               , 'N'
                               , 'N' ); --P_SAFX201
            lib_proc.add_param ( pstr
                               , 'SAFX202  '
                               , 'VARCHAR2'
                               , 'CHECKBOX'
                               , 'N'
                               , 'N'
                               , NULL
                               , NULL
                               , 'N'
                               , 'N' ); --P_SAFX202
        END IF;

        lib_proc.add_param (
                             pstr
                           , 'Estabelecimento'
                           , --P_CODESTAB
                            'VARCHAR2'
                           , 'MULTISELECT'
                           , 'N'
                           , 'S'
                           , NULL
                           ,    '
                            SELECT A.COD_ESTAB, A.COD_ESTAB || '' - '' || B.COD_ESTADO || '' - '' || A.CGC || '' - '' || INITCAP(A.BAIRRO) || '' / '' || INITCAP(A.CIDADE)
                            FROM ESTABELECIMENTO A, ESTADO B, MSAFI.DSP_ESTABELECIMENTO C
                            WHERE A.COD_EMPRESA  = '''
                             || mcod_empresa
                             || '''
                            AND   B.IDENT_ESTADO = A.IDENT_ESTADO
                            AND   B.COD_ESTADO  IN (''SP'',''RJ'',''PR'',''AL'',''PB'',''DF'',''BA'')
                            AND   C.COD_EMPRESA  = A.COD_EMPRESA
                            AND   C.COD_ESTAB    = A.COD_ESTAB
                            AND   C.TIPO         = ''L'' -- LOJA
                            ORDER BY B.COD_ESTADO, A.COD_ESTAB
                           '
        );

        RETURN pstr;
    END; --FUNCTION PARAMETROS RETURN VARCHAR2 IS

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Executar interfaces de Cupons Fiscais Eletrônicos';
    END;

    FUNCTION tipo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Interfaces';
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
        RETURN 'Execução de interfaces de Cupons Fiscais Eletrônicos';
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
        msafi.dsp_control.writelog ( 'INFO'
                                   , p_i_texto );
    END;


    FUNCTION executar ( p_data_ini DATE
                      , p_data_fim DATE
                      , p_cria_job VARCHAR2
                      , p_safx07_e VARCHAR2
                      , p_safx08_e VARCHAR2
                      , p_safx201_e VARCHAR2
                      , p_safx202_e VARCHAR2
                      , p_codestab lib_proc.vartab )
        RETURN INTEGER
    IS
        mproc_id INTEGER;
        i1 INTEGER;

        v_proc_status NUMBER := 0;
        v_s_proc_status VARCHAR2 ( 16 );

        v_txt_nf VARCHAR2 ( 1024 ) := '';
        v_txt_basico VARCHAR2 ( 256 ) := '';

        TYPE a_estabs_t IS TABLE OF VARCHAR2 ( 6 );

        a_estabs a_estabs_t := a_estabs_t ( );

        --Variaveis genericas
        v_job_num NUMBER;
        v_estab_grupo VARCHAR2 ( 6 );
    BEGIN
        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' ); -- AJUSTE 2017-06-09

        mproc_id :=
            lib_proc.new ( 'DSP_INTERF_CUPOM_E_CPROC'
                         , 48
                         , 150 );
        lib_proc.add_tipo ( mproc_id
                          , 1
                          , 'Processo'
                          , 1 );
        lib_proc.add_header ( 'Execução de interfaces de Cupom Fiscal-e'
                            , 1
                            , 1 );
        lib_proc.add ( ' ' );

        IF mcod_empresa IS NULL THEN
            lib_proc.add_log ( 'Código da empresa deve ser informado como parâmetro global.'
                             , 0 );
            lib_proc.add ( 'ERRO' );
            lib_proc.add ( 'CÓDIGO DA EMPRESA DEVE SER INFORMADO COMO PARÂMETRO GLOBAL.' );
            lib_proc.close;
            RETURN mproc_id;
        END IF;


        msafi.dsp_control.createprocess ( 'DSP_INTFC_E_CF' --P_I_PROCID            IN VARCHAR2             , --VARCHAR2(16)
                                        , 'EXEC INTFC E CF' --P_I_PROC_DESCR        IN VARCHAR2             , --VARCHAR2(64)
                                        , p_data_ini --P_I_DATA_INI          IN DATE     DEFAULT NULL,
                                        , p_data_fim --P_I_DATA_FIM          IN DATE     DEFAULT NULL,
                                        , p_codestab.COUNT --P_I_DETALHES1         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , NULL --P_I_DETALHES2         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , NULL --P_I_DETALHES3         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , NULL --P_I_DETALHES4         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , musuario --P_I_USER              IN VARCHAR2 DEFAULT NULL  --VARCHAR2(64)
                                                   );
        v_proc_status := 1; --EM PROCESSO

        v_txt_basico :=
               '('''
            || TO_CHAR ( p_data_ini
                       , 'YYYYMMDD' )
            || ''','''
            || TO_CHAR ( p_data_fim
                       , 'YYYYMMDD' )
            || ''','''
            || mcod_empresa
            || ''',''';

        IF ( p_codestab.COUNT > 0 ) THEN
            i1 := p_codestab.FIRST;

            WHILE i1 IS NOT NULL LOOP
                a_estabs.EXTEND ( );
                a_estabs ( a_estabs.LAST ) := p_codestab ( i1 );
                i1 := p_codestab.NEXT ( i1 );
            END LOOP;
        ELSE
            FOR c1 IN ( SELECT cod_estab
                          FROM estabelecimento
                         WHERE cod_empresa = mcod_empresa ) LOOP
                a_estabs.EXTEND ( );
                a_estabs ( a_estabs.LAST ) := c1.cod_estab;
            END LOOP;
        END IF;

        ------------------------------------------------------------------------------------------------------------------------------------------------------
        --- NOVA chamada para cupom eletronico - INI
        IF ( p_safx07_e = 'S'
         OR p_safx08_e = 'S'
         OR p_safx201_e = 'S'
         OR p_safx202_e = 'S' ) THEN
            loga ( 'Executando SAFX07e/SAFX08e/SAFX201e/SAFX202e' );

            v_txt_basico :=
                   'BEGIN MSAFI.PRC_MSAF_CUPOM_E('''
                || TO_CHAR ( p_data_ini
                           , 'YYYYMMDD' )
                || ''','''
                || TO_CHAR ( p_data_fim
                           , 'YYYYMMDD' )
                || '''';

            IF NOT ( p_safx07_e = 'S'
                AND p_safx08_e = 'S'
                AND p_safx201_e = 'S'
                AND p_safx202_e = 'S' ) THEN
                IF p_safx07_e <> 'S' THEN
                    v_txt_basico := v_txt_basico || ',P_CARGA_SAFX07=>0';
                END IF;

                IF p_safx08_e <> 'S' THEN
                    v_txt_basico := v_txt_basico || ',P_CARGA_SAFX08=>0';
                END IF;

                --Nao executar SAFX201 e 202 para PACHECO
                IF p_safx201_e <> 'S'
                OR mcod_empresa = 'DP' THEN
                    v_txt_basico := v_txt_basico || ',P_CARGA_SAFX201=>0';
                END IF;

                IF p_safx202_e <> 'S'
                OR mcod_empresa = 'DP' THEN
                    v_txt_basico := v_txt_basico || ',P_CARGA_SAFX202=>0';
                END IF;
            END IF; --IF NOT (P_SAFX07_E = 'S' AND P_SAFX08_E = 'S' AND P_SAFX201_E = 'S' AND P_SAFX202_E = 'S') THEN

            v_txt_basico := v_txt_basico || ',P_COD_EMPRESA=>''' || mcod_empresa || '''';

            --Vamos contar quantos estabelecimentos existem para verificar se estamos rodando para todos ou apenas alguns.
            SELECT COUNT ( 0 )
              INTO i1
              FROM estabelecimento a
             WHERE a.cod_empresa = mcod_empresa;

            IF a_estabs.COUNT <> i1 THEN --Se não selecionamos todos os estabelecimentos
                --Vamos contar somente lojas
                SELECT COUNT ( 0 )
                  INTO i1
                  FROM estabelecimento a
                     , msafi.dsp_estabelecimento b
                 WHERE a.cod_empresa = mcod_empresa
                   AND a.cod_empresa = b.cod_empresa
                   AND a.cod_estab = b.cod_estab
                   AND b.tipo = 'L' --LOJA
                                   ;
            END IF;

            --Se o número de estabelecimentos selecionados for maior ou igual ao número de lojas, vamos rodar para todas as lojas
            IF a_estabs.COUNT >= i1 THEN
                v_txt_nf := v_txt_basico || '); END;';
                loga ( 'Executando: ' || v_txt_nf );

                EXECUTE IMMEDIATE v_txt_nf;
            ELSE
                FOR i IN 1 .. a_estabs.COUNT LOOP
                    v_txt_nf := v_txt_basico || ',P_COD_ESTAB=>''' || a_estabs ( i ) || '''); END;';

                    --LOGA('Executando: ' || V_TXT_NF);
                    EXECUTE IMMEDIATE v_txt_nf;
                END LOOP;
            END IF; --IF A_ESTABS.COUNT >= I1 THEN
        END IF; --IF P_SAFX07_E = 'S' OR P_SAFX08_E = 'S' OR P_SAFX201_E = 'S' THEN

        --- NOVA chamada para cupom eletronico - FIM
        ------------------------------------------------------------------------------------------------------------------------------------------------------

        IF ( p_cria_job = 'S' ) THEN
            SELECT estab_grupo
              INTO v_estab_grupo
              FROM msafi.dsp_interface_setup
             WHERE cod_empresa = mcod_empresa;

            --Cria o job de importação
            saf_pega_ident ( 'JOB_IMPORTACAO'
                           , 'NUM_JOB'
                           , v_job_num );

            INSERT INTO job_importacao ( num_job
                                       , tipo_job
                                       , status_job
                                       , data_abertura
                                       , data_encerramento
                                       , ind_ato_cotepe )
                 VALUES ( v_job_num
                        , 'I'
                        , 'P'
                        , SYSDATE
                        , SYSDATE
                        , 'N' );

            COMMIT;

            --Cria as linhas do job
            INSERT INTO det_job_import ( num_job
                                       , grupo_arquivo
                                       , numero_arquivo
                                       , cod_empresa
                                       , cod_estab
                                       , data_ini
                                       , data_fim
                                       , perc_erro
                                       , ind_aborta_job
                                       , status
                                       , ind_drop_tab
                                       , dat_ini_exec
                                       , dat_fim_exec
                                       , ind_periodo
                                       , ind_sobrepor_reg
                                       , ind_log_x2013
                                       , ind_valid_x2013
                                       , ind_data_averb_x48
                                       , ind_gera_x530
                                       , ind_gera_x751
                                       , ind_valid_cep_x04 )
                SELECT v_job_num --NUM_JOB
                     , a.grupo_arquivo --GRUPO_ARQUIVO
                     , a.numero_arquivo --NUMERO_ARQUIVO
                     , mcod_empresa --COD_EMPRESA
                     , CASE WHEN a.grupo_arquivo = 1 THEN v_estab_grupo ELSE NULL END --COD_ESTAB
                     , CASE
                           WHEN a.grupo_arquivo = 1 THEN
                               TO_DATE ( '01011900'
                                       , 'DDMMYYYY' )
                           ELSE
                               p_data_ini
                       END --DATA_INI
                     , p_data_fim --DATA_FIM
                     , CASE WHEN a.nom_tab_work = 'SAFX08' THEN 2 ELSE 10 END --PERC_ERRO
                     , 'S' --IND_ABORTA_JOB
                     , 'P' --STATUS
                     , 'S' --IND_DROP_TAB
                     , NULL --DAT_INI_EXEC
                     , NULL --DAT_FIM_EXEC
                     , CASE WHEN a.grupo_arquivo = 1 THEN 'N' ELSE 'S' END --IND_PERIODO
                     , 'S' --IND_SOBREPOR_REG
                     , 'N' --IND_LOG_X2013
                     , CASE WHEN a.nom_tab_work = 'SAFX2013' THEN 'S' ELSE 'N' END --IND_VALID_X2013
                     , 'N' --IND_DATA_AVERB_X48
                     , 'N' --IND_GERA_X530
                     , 'N' --IND_GERA_X751
                     , 'S' --ind_valid_cep_x04
                  FROM cat_prior_imp a
                 WHERE ( ( NVL ( TRIM ( UPPER ( p_safx07_e ) ), 'N' ) = 'S'
                      AND a.nom_tab_work = 'SAFX07' )
                     OR ( NVL ( TRIM ( UPPER ( p_safx08_e ) ), 'N' ) = 'S'
                     AND a.nom_tab_work = 'SAFX08' )
                     OR ( NVL ( TRIM ( UPPER ( p_safx201_e ) ), 'N' ) = 'S'
                     AND a.nom_tab_work = 'SAFX201' )
                     OR ( NVL ( TRIM ( UPPER ( p_safx202_e ) ), 'N' ) = 'S'
                     AND a.nom_tab_work = 'SAFX202' ) );

            COMMIT;

            loga ( 'Job de importação criado: [' || v_job_num || ']' );
            lib_proc.add ( 'Job de importação criado: [' || v_job_num || ']' );
        END IF;

        v_proc_status := 2;

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
        lib_proc.add ( 'FIM DO PROCESSAMENTO, STATUS FINAL: [' || v_s_proc_status || ']' );
        lib_proc.add ( 'Favor verificar LOG para detalhes.' );
        msafi.dsp_control.updateprocess ( v_s_proc_status );

        lib_proc.close ( );

        COMMIT;
        RETURN mproc_id;
    EXCEPTION
        WHEN OTHERS THEN
            msafi.dsp_control.log_checkpoint ( SQLERRM
                                             , 'Erro não tratado, executador de interfaces' );
            lib_proc.add_log ( 'Erro não tratado: ' || dbms_utility.format_error_backtrace
                             , 1 );
            lib_proc.add_log ( 'SQLERRM: ' || SQLERRM
                             , 1 );
            lib_proc.add ( 'ERRO!' );
            lib_proc.add ( dbms_utility.format_error_backtrace );
            lib_proc.close;
            COMMIT;
            RETURN mproc_id;
    END; /* FUNCTION EXECUTAR */
END dsp_interf_cupom_e_cproc;
/
SHOW ERRORS;
