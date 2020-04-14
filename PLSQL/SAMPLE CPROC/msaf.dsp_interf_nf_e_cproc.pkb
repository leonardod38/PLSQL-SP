Prompt Package Body DSP_INTERF_NF_E_CPROC;
--
-- DSP_INTERF_NF_E_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dsp_interf_nf_e_cproc
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
                           , 'N'
                           , NULL );

        lib_proc.add_param ( pstr
                           , 'Atenção, NFs de célula não serão carregadas, utilize o customizado de célula'
                           , 'VARCHAR2'
                           , 'TEXT'
                           , 'N'
                           , '1'
                           , NULL
                           , ''
                           , 'N' );

        lib_proc.add_param ( pstr
                           , 'Carrega PO'
                           , --P_CARGA_PO
                            'VARCHAR2'
                           , 'CHECKBOX'
                           , 'N'
                           , 'S'
                           , NULL );

        lib_proc.add_param ( pstr
                           , 'Carrega tabela de auditoria'
                           , --P_CARGA_AUDITORIA
                            'VARCHAR2'
                           , 'CHECKBOX'
                           , 'N'
                           , 'S'
                           , NULL );

        lib_proc.add_param ( pstr
                           , 'Estabelecimento'
                           , --P_CODESTAB
                            'VARCHAR2'
                           , 'TEXTBOX'
                           , 'N'
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
                           SELECT ''SAFX03''  , ''03. SAFX03''  FROM DUAL UNION
                           SELECT ''SAFX301'' , ''04. SAFX301'' FROM DUAL UNION
                           SELECT ''SAFX112'' , ''05. SAFX112'' FROM DUAL
                           ORDER BY 2
                           '  );

        RETURN pstr;
    END; --FUNCTION PARAMETROS RETURN VARCHAR2 IS

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Executar interfaces de Documentos Fiscais de ENTRADA';
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
        RETURN 'Execução de interfaces Doc Fiscal de ENTRADA';
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
                      , p_carga_po VARCHAR2
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

        v_txt_entrada VARCHAR2 ( 1024 ) := '';

        v_carga_safx07 VARCHAR2 ( 32 );
        v_carga_safx08 VARCHAR2 ( 32 );
        v_carga_safx03 VARCHAR2 ( 32 );
        v_carga_safx301 VARCHAR2 ( 32 );
        v_carga_safx112 VARCHAR2 ( 32 );
        v_c_safx07 CHAR ( 1 );
        v_c_safx08 CHAR ( 1 );
        v_c_safx03 CHAR ( 1 );
        v_c_safx301 CHAR ( 1 );
        v_c_safx112 CHAR ( 1 );


        --Variaveis genericas
        v_text01 VARCHAR2 ( 1024 );
        v_text02 VARCHAR2 ( 1024 );
        v_job_num NUMBER;
        v_estab_grupo VARCHAR2 ( 6 );
    BEGIN
        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        mproc_id :=
            lib_proc.new ( 'DSP_INTERF_NF_E_CPROC'
                         , 48
                         , 150 );
        lib_proc.add_tipo ( mproc_id
                          , 1
                          , 'Processo'
                          , 1 );
        lib_proc.add_header ( 'Execução de interfaces de NF de ENTRADA'
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


        msafi.dsp_control.createprocess ( 'DSP_INTFC_NFS_E' --P_I_PROCID            IN VARCHAR2             , --VARCHAR2(16)
                                        , 'EXEC INTFC NFS ENTRADAS' --P_I_PROC_DESCR        IN VARCHAR2             , --VARCHAR2(64)
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

        v_txt_entrada :=
               'BEGIN MSAFI.PRC_MSAF_PS_NF_ENTRADA('''
            || TO_CHAR ( p_data_ini
                       , 'YYYYMMDD' )
            || ''','''
            || TO_CHAR ( p_data_fim
                       , 'YYYYMMDD' )
            || '''';

        IF ( p_safx.COUNT > 0 ) THEN
            v_c_safx07 := 'N';
            v_c_safx08 := 'N';
            v_c_safx03 := 'N';
            v_c_safx301 := 'N';
            v_c_safx112 := 'N';

            i1 := p_safx.FIRST;

            WHILE i1 IS NOT NULL LOOP
                CASE p_safx ( i1 )
                    WHEN 'SAFX07' THEN
                        v_c_safx07 := 'S';
                    WHEN 'SAFX08' THEN
                        v_c_safx08 := 'S';
                    WHEN 'SAFX03' THEN
                        v_c_safx03 := 'S';
                    WHEN 'SAFX301' THEN
                        v_c_safx301 := 'S';
                    WHEN 'SAFX112' THEN
                        v_c_safx112 := 'S';
                END CASE;

                i1 := p_safx.NEXT ( i1 );
            END LOOP;

            v_carga_safx07 := ',P_CARGA_SAFX07=>' || CASE WHEN v_c_safx07 = 'S' THEN '1' ELSE '0' END;
            v_carga_safx08 := ',P_CARGA_SAFX08=>' || CASE WHEN v_c_safx08 = 'S' THEN '1' ELSE '0' END;
            v_carga_safx03 := ',P_CARGA_SAFX03=>' || CASE WHEN v_c_safx03 = 'S' THEN '1' ELSE '0' END;
            v_carga_safx301 := ',P_CARGA_SAFX301=>' || CASE WHEN v_c_safx301 = 'S' THEN '1' ELSE '0' END;
            v_carga_safx112 := ',P_CARGA_SAFX112=>' || CASE WHEN v_c_safx112 = 'S' THEN '1' ELSE '0' END;

            v_txt_entrada :=
                   v_txt_entrada
                || v_carga_safx07
                || v_carga_safx08
                || v_carga_safx112
                || v_carga_safx03
                || v_carga_safx301;
        ELSE
            v_c_safx07 := 'S';
            v_c_safx08 := 'S';
            v_c_safx03 := 'S';
            v_c_safx301 := 'S';
            v_c_safx112 := 'S';
        END IF;

        IF TRIM ( p_codestab ) IS NOT NULL
       AND TRIM ( p_nf_id ) IS NOT NULL THEN
            v_txt_entrada :=
                v_txt_entrada || ',P_COD_ESTAB=>''' || p_codestab || ''',P_NF_BRL_ID=>''' || p_nf_id || '''';
        END IF;

        v_txt_entrada := v_txt_entrada || ',P_CARREGA_CELULA=>''N''';

        IF p_carga_po = 'S' THEN
            v_txt_entrada := v_txt_entrada || ',P_CARREGA_PO=>''S''';
        ELSE
            v_txt_entrada := v_txt_entrada || ',P_CARREGA_PO=>''N''';
        END IF;

        IF p_carga_auditoria = 'S' THEN
            v_txt_entrada := v_txt_entrada || ',P_INSERE_AUDIT=>1';
        ELSE
            v_txt_entrada := v_txt_entrada || ',P_INSERE_AUDIT=>0';
        END IF;

        v_txt_entrada := v_txt_entrada || ',P_COD_EMPRESA=>''' || mcod_empresa || ''''; --NOVO PARAMETRO

        v_txt_entrada := v_txt_entrada || '); END;';

        loga ( 'Executando: ' || v_txt_entrada
             , FALSE );

        EXECUTE IMMEDIATE v_txt_entrada;


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
                     OR ( NVL ( TRIM ( UPPER ( v_c_safx03 ) ), 'N' ) = 'S'
                     AND a.nom_tab_work = 'SAFX03' )
                     OR ( NVL ( TRIM ( UPPER ( v_c_safx301 ) ), 'N' ) = 'S'
                     AND a.nom_tab_work = 'SAFX301' )
                     OR ( NVL ( TRIM ( UPPER ( v_c_safx112 ) ), 'N' ) = 'S'
                     AND a.nom_tab_work = 'SAFX112' )--                   OR (NVL(TRIM(UPPER(P_CADASTROS)),'N') <> 'S' AND A.NOM_TAB_WORK IN ('SAFX04','SAFX2013') )
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
END dsp_interf_nf_e_cproc;
/
SHOW ERRORS;
