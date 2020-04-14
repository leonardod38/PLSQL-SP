Prompt Package Body DSP_INTERF_NF_S_CPROC;
--
-- DSP_INTERF_NF_S_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dsp_interf_nf_s_cproc
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
                           , 'S - Vira NFs Uso e Consumo              '
                           , 'VARCHAR2'
                           , 'CHECKBOX'
                           , 'N'
                           , 'S'
                           , NULL ); --P_USO_CONSUMO
        lib_proc.add_param ( pstr
                           , 'N - Vira NFs Cagadas                    '
                           , 'VARCHAR2'
                           , 'CHECKBOX'
                           , 'N'
                           , 'N'
                           , NULL ); --P_CAGADAS
        lib_proc.add_param ( pstr
                           , 'N - Ignora SETUP de virada do PeopleSoft'
                           , 'VARCHAR2'
                           , 'CHECKBOX'
                           , 'N'
                           , 'N'
                           , NULL ); --P_VIRA_IGNORA_PS
        lib_proc.add_param ( pstr
                           , 'N - Carrega tabela de auditoria         '
                           , 'VARCHAR2'
                           , 'CHECKBOX'
                           , 'N'
                           , 'N'
                           , NULL ); --P_CARGA_AUDITORIA

        lib_proc.add_param ( pstr
                           , 'Estabelecimento'
                           , --P_CODESTAB
                            'VARCHAR2'
                           , 'TEXTBOX'
                           , 'S'
                           , NULL
                           , NULL );

        lib_proc.add_param ( pstr
                           , 'ID da NF no People'
                           , --P_NF_ID
                            'VARCHAR2'
                           , 'TEXTBOX'
                           , 'N'
                           , NULL );

        lib_proc.add_param ( pstr
                           , 'SAFXs'
                           , --P_SAFX
                            'VARCHAR2'
                           , 'MULTISELECT'
                           , 'N'
                           , 'S'
                           , NULL
                           , '
                           SELECT ''SAFX07''  , ''01. SAFX07''  FROM DUAL UNION
                           SELECT ''SAFX08''  , ''02. SAFX08''  FROM DUAL UNION
                           SELECT ''SAFX112'' , ''03. SAFX112'' FROM DUAL UNION
                           SELECT ''SAFX116'' , ''04. SAFX116'' FROM DUAL UNION
                           SELECT ''SAFX117'' , ''05. SAFX117'' FROM DUAL UNION
                           SELECT ''SAFX119'' , ''06. SAFX119'' FROM DUAL
                           ORDER BY 2
                           '  );

        RETURN pstr;
    END; --FUNCTION PARAMETROS RETURN VARCHAR2 IS

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Executar interfaces de Documentos Fiscais de SAIDA';
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
        RETURN 'VERSAO 1.1';
    END;

    FUNCTION descricao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Execução de interfaces Doc Fiscal de SAIDA';
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
                      , p_uso_consumo VARCHAR2
                      , p_cagadas VARCHAR2
                      , p_vira_ignora_ps VARCHAR2
                      , p_carga_auditoria VARCHAR2
                      , p_codestab VARCHAR2
                      , p_nf_id VARCHAR2
                      , p_safx lib_proc.vartab )
        RETURN INTEGER
    IS
        mproc_id INTEGER;
        i1 INTEGER;

        v_proc_status NUMBER := 0;
        v_s_proc_status VARCHAR2 ( 16 );

        v_txt_saida VARCHAR2 ( 1024 ) := '';

        v_carga_safx07 VARCHAR2 ( 32 );
        v_carga_safx08 VARCHAR2 ( 32 );
        v_carga_safx112 VARCHAR2 ( 32 );
        v_carga_safx116 VARCHAR2 ( 32 );
        v_carga_safx117 VARCHAR2 ( 32 );
        v_carga_safx119 VARCHAR2 ( 32 );
        v_c_safx07 CHAR ( 1 );
        v_c_safx08 CHAR ( 1 );
        v_c_safx112 CHAR ( 1 );
        v_c_safx116 CHAR ( 1 );
        v_c_safx117 CHAR ( 1 );
        v_c_safx119 CHAR ( 1 );
        v_s_vira_uso_consumo VARCHAR2 ( 32 );
        v_s_vira_cagadas VARCHAR2 ( 32 );
        v_s_vira_ignora_ps VARCHAR2 ( 32 );
        v_s_carga_auditoria VARCHAR2 ( 32 );

        --Variaveis genericas
        v_text01 VARCHAR2 ( 1024 );
        v_text02 VARCHAR2 ( 1024 );
        v_job_num NUMBER;
        v_estab_grupo VARCHAR2 ( 6 );
    BEGIN
        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        mproc_id :=
            lib_proc.new ( 'DSP_INTERF_NF_S_CPROC'
                         , 48
                         , 150 );
        lib_proc.add_tipo ( mproc_id
                          , 1
                          , 'Processo'
                          , 1 );
        lib_proc.add_header ( 'Execução de interfaces de NFs de SAIDA'
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
        ELSIF ( TRIM ( p_codestab ) IS NOT NULL
           AND TRIM ( p_nf_id ) IS NULL )
           OR ( TRIM ( p_codestab ) IS NULL
           AND TRIM ( p_nf_id ) IS NOT NULL ) THEN
            lib_proc.add_log ( 'Parametros de ESTABELECIMENTO e ID PEOPLE devem ser preenchidos ao mesmo tempo'
                             , 0 );
            lib_proc.add_log ( 'Pode-se preencher ambos ou nenhum dos dois.'
                             , 0 );
            lib_proc.add_log ( 'Não é possível preencher um sem preencher o outro.'
                             , 0 );
            lib_proc.add ( 'ERRO' );
            lib_proc.add ( 'Parametros de ESTABELECIMENTO e ID PEOPLE devem ser preenchidos ao mesmo tempo'
                         , 0 );
            lib_proc.add ( 'Pode-se preencher ambos ou nenhum dos dois.'
                         , 0 );
            lib_proc.add ( 'Não é possível preencher um sem preencher o outro.'
                         , 0 );
            lib_proc.close;
            RETURN mproc_id;
        END IF;

        msafi.dsp_control.createprocess ( 'DSP_INTFC_NFS_S' --P_I_PROCID            IN VARCHAR2             , --VARCHAR2(16)
                                        , 'EXEC INTFC NFS SAIDA' --P_I_PROC_DESCR        IN VARCHAR2             , --VARCHAR2(64)
                                        , p_data_ini --P_I_DATA_INI          IN DATE     DEFAULT NULL,
                                        , p_data_fim --P_I_DATA_FIM          IN DATE     DEFAULT NULL,
                                        , NULL --P_I_DETALHES1         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , NULL --P_I_DETALHES2         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , p_codestab --P_I_DETALHES3         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , p_nf_id --P_I_DETALHES4         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , musuario --P_I_USER              IN VARCHAR2 DEFAULT NULL  --VARCHAR2(64)
                                                   );
        v_proc_status := 1; --EM PROCESSO
        loga ( 'Inicio do processo' );

        v_txt_saida :=
               'BEGIN MSAFI.PRC_MSAF_PS_NF_SAIDA('''
            || TO_CHAR ( p_data_ini
                       , 'YYYYMMDD' )
            || ''','''
            || TO_CHAR ( p_data_fim
                       , 'YYYYMMDD' )
            || '''';

        IF ( p_safx.COUNT > 0 ) THEN
            v_c_safx07 := 'N';
            v_c_safx08 := 'N';
            v_c_safx112 := 'N';
            v_c_safx116 := 'N';
            v_c_safx117 := 'N';
            v_c_safx119 := 'N';

            i1 := p_safx.FIRST;

            WHILE i1 IS NOT NULL LOOP
                CASE p_safx ( i1 )
                    WHEN 'SAFX07' THEN
                        v_c_safx07 := 'S';
                    WHEN 'SAFX08' THEN
                        v_c_safx08 := 'S';
                    WHEN 'SAFX112' THEN
                        v_c_safx112 := 'S';
                    WHEN 'SAFX116' THEN
                        v_c_safx116 := 'S';
                    WHEN 'SAFX117' THEN
                        v_c_safx117 := 'S';
                    WHEN 'SAFX119' THEN
                        v_c_safx119 := 'S';
                END CASE;

                i1 := p_safx.NEXT ( i1 );
            END LOOP;

            v_carga_safx07 := ',P_CARGA_SAFX07=>' || CASE WHEN v_c_safx07 = 'S' THEN '1' ELSE '0' END;
            v_carga_safx08 := ',P_CARGA_SAFX08=>' || CASE WHEN v_c_safx08 = 'S' THEN '1' ELSE '0' END;
            v_carga_safx112 := ',P_CARGA_SAFX112=>' || CASE WHEN v_c_safx112 = 'S' THEN '1' ELSE '0' END;
            v_carga_safx116 := ',P_CARGA_SAFX116=>' || CASE WHEN v_c_safx116 = 'S' THEN '1' ELSE '0' END;
            v_carga_safx117 := ',P_CARGA_SAFX117=>' || CASE WHEN v_c_safx117 = 'S' THEN '1' ELSE '0' END;
            v_carga_safx119 := ',P_CARGA_SAFX119=>' || CASE WHEN v_c_safx119 = 'S' THEN '1' ELSE '0' END;

            v_txt_saida :=
                   v_txt_saida
                || v_carga_safx07
                || v_carga_safx08
                || v_carga_safx112
                || v_carga_safx116
                || v_carga_safx117
                || v_carga_safx119;
        ELSE
            v_c_safx07 := 'S';
            v_c_safx08 := 'S';
            v_c_safx112 := 'S';
            v_c_safx116 := 'S';
            v_c_safx117 := 'S';
            v_c_safx119 := 'S';
        END IF;

        IF NVL ( TRIM ( UPPER ( p_uso_consumo ) ), 'N' ) = 'N' THEN
            v_s_vira_uso_consumo := ',P_VIRA_USO_CONSUMO=>0';
        ELSE
            v_s_vira_uso_consumo := ',P_VIRA_USO_CONSUMO=>1';
        END IF;

        IF NVL ( TRIM ( UPPER ( p_cagadas ) ), 'N' ) = 'N' THEN
            v_s_vira_cagadas := ',P_VIRA_CAGADAS=>0';
        ELSE
            v_s_vira_cagadas := ',P_VIRA_CAGADAS=>1';
        END IF;

        IF NVL ( TRIM ( UPPER ( p_vira_ignora_ps ) ), 'N' ) = 'N' THEN
            v_s_vira_ignora_ps := ',P_VIRA_IGNORA_PS=>0';
        ELSE
            v_s_vira_ignora_ps := ',P_VIRA_IGNORA_PS=>1';
        END IF;

        IF NVL ( TRIM ( UPPER ( p_carga_auditoria ) ), 'N' ) = 'N' THEN
            v_s_carga_auditoria := ',P_INSERE_AUDIT=>0';
        ELSE
            v_s_carga_auditoria := ',P_INSERE_AUDIT=>1';
        END IF;

        v_txt_saida :=
            v_txt_saida || v_s_vira_uso_consumo || v_s_vira_cagadas || v_s_vira_ignora_ps || v_s_carga_auditoria;

        IF TRIM ( p_codestab ) IS NOT NULL
       AND TRIM ( p_nf_id ) IS NOT NULL THEN
            v_txt_saida := v_txt_saida || ',P_COD_ESTAB=>''' || p_codestab || ''',P_NF_BRL_ID=>''' || p_nf_id || '''';
        END IF;

        v_txt_saida := v_txt_saida || ',P_COD_EMPRESA=>''' || mcod_empresa || '''';
        v_txt_saida := v_txt_saida || '); END;';

        loga ( 'Executando: ' || v_txt_saida
             , FALSE );
        dbms_application_info.set_module ( 'INTERF MSAF X PSFT'
                                         , 'CARGA NF SAIDA' );

        EXECUTE IMMEDIATE v_txt_saida;

        IF ( p_cria_job = 'S' ) THEN
            SELECT estab_grupo
              INTO v_estab_grupo
              FROM msafi.dsp_interface_setup
             WHERE cod_empresa = mcod_empresa;

            --Cria o job de importação
            dbms_application_info.set_module ( 'INTERF MSAF X PSFT'
                                             , 'CRIAR JOB IMPORTACAO' );
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
                     , CASE
                           WHEN a.grupo_arquivo = 1 THEN v_estab_grupo
                           WHEN TRIM ( p_codestab ) IS NOT NULL THEN TRIM ( p_codestab )
                       END --COD_ESTAB
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
                 WHERE ( ( NVL ( TRIM ( UPPER ( v_c_safx07 ) ), 'N' ) = 'S'
                      AND a.nom_tab_work = 'SAFX07' )
                     OR ( NVL ( TRIM ( UPPER ( v_c_safx08 ) ), 'N' ) = 'S'
                     AND a.nom_tab_work = 'SAFX08' )
                     OR ( NVL ( TRIM ( UPPER ( v_c_safx112 ) ), 'N' ) = 'S'
                     AND a.nom_tab_work = 'SAFX112' )
                     OR ( NVL ( TRIM ( UPPER ( v_c_safx116 ) ), 'N' ) = 'S'
                     AND a.nom_tab_work = 'SAFX116' )
                     OR ( NVL ( TRIM ( UPPER ( v_c_safx117 ) ), 'N' ) = 'S'
                     AND a.nom_tab_work = 'SAFX117' )
                     OR ( NVL ( TRIM ( UPPER ( v_c_safx119 ) ), 'N' ) = 'S'
                     AND a.nom_tab_work = 'SAFX119' )--                   OR (NVL(TRIM(UPPER(P_CADASTROS)),'N') <> 'S' AND A.NOM_TAB_WORK IN ('SAFX04','SAFX2013') )
                                                      );

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

        --PROJETO 1952 CAT42 MODULO MSAF - INI - JUN/2019
        lib_proc.add ( 'Ajuste de Impostos nas NFs - SAIDA' );

        BEGIN
            msafi.dpsp_upd_safx_tax ( p_movto_e_s => 'S'
                                    , p_cod_estab => p_codestab
                                    , p_id_people => p_nf_id );
        EXCEPTION
            WHEN OTHERS THEN
                lib_proc.add ( 'ERRO MSAFI.DPSP_UPD_SAFX_TAX - SAIDA' );
        END;

        --PROJETO 1952 CAT42 MODULO MSAF - FIM - JUN/2019

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
END dsp_interf_nf_s_cproc;
/
SHOW ERRORS;
