Prompt Package Body DPSP_CARGA_IMP_JOBS_CPROC;
--
-- DPSP_CARGA_IMP_JOBS_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_carga_imp_jobs_cproc
IS
    vs_mcod_empresa estabelecimento.cod_empresa%TYPE;
    vs_mcod_usuario usuario_estab.cod_usuario%TYPE;
    vs_mproc_id NUMBER;

    --Tipo, Nome e Descrição do Customizado
    mnm_tipo VARCHAR2 ( 100 ) := 'Automatização';
    mnm_cproc VARCHAR2 ( 100 ) := 'Controle Jobs - Carga e Importação';
    mds_cproc VARCHAR2 ( 100 ) := 'Detalhes e status dos jobs do DataHub, PeopleSoft e SAP';

    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );
    BEGIN
        vs_mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        vs_mcod_usuario := lib_parametros.recuperar ( 'USUARIO' );

        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS= '',.'' ';

        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_LANGUAGE = ''Portuguese'' ';

        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT="DD/MM/YYYY"';

        lib_proc.add_param (
                             pparam => pstr
                           , ptitulo => 'Processo'
                           , ptipo => 'varchar2'
                           , pcontrole => 'Radiobutton'
                           , pmandatorio => 'S'
                           , pdefault => 'C'
                           , pmascara => NULL
                           , pvalores =>    'C=Consultar Scheduler,'
                                         || --
                                           'L=Consultar Log,'
                                         || --
                                           'E=Executar,'
                                         || --
                                           'A=[Habilitar],'
                                         || --
                                           'D=[Desabilitar]'
        );

        lib_proc.add_param (
                             pstr
                           , 'Job'
                           , --PCOD_JOB
                            'VARCHAR2'
                           , 'MULTISELECT'
                           , 'S'
                           , 'S'
                           , NULL
                           ,    ' SELECT JOB_NAME , JOB_NAME || '' - "'' ||COMMENTS || ''" - ['' '
                             || --
                               ' || STATUS || '']'' '
                             || --
                               ' FROM ('
                             || --
                               ' SELECT JOB_NAME AS JOB_NAME, '
                             || --
                               ' SUBSTR(COMMENTS,1,70) AS COMMENTS, '
                             || --
                               ' SUBSTR(OWNER,1,10) AS OWNER, '
                             || ' STATE, '
                             || --
                               ' JOB_TYPE, SCHEDULE_TYPE, START_DATE, '
                             || --
                               ' SUBSTR(REPEAT_INTERVAL,1,70) AS REPEAT_INTERVAL, '
                             || --
                               ' LAST_START_DATE,LAST_RUN_DURATION, NEXT_RUN_DATE, NLS_ENV, '
                             || --
                               ' JOB_ACTION, '
                             || --
                               ' (CASE WHEN ENABLED = ''TRUE'' THEN ''Habilitado'' ELSE ''Desabilitado'' END) AS STATUS '
                             || --
                               ' FROM ALL_SCHEDULER_JOBS '
                             || --
                               ' WHERE 1=1 '
                             || --
                               ' AND OWNER = ''MSAF'''
                             || --
                               ' AND JOB_NAME LIKE ''JOB_DPSP%'''
                             || --
                               ' AND JOB_NAME IN (SELECT JOB_NAME FROM MSAFI.DPSP_CARGA_IMP_CONTROL_EXEC)'
                             || --
                               ' ORDER BY NEXT_RUN_DATE, JOB_NAME'
                             || ' )'
        );

        RETURN pstr;
    END;

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN mnm_cproc;
    END;

    FUNCTION tipo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN mnm_tipo;
    END;

    FUNCTION versao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN '1.0';
    END;

    FUNCTION descricao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN mds_cproc;
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
        -- Orientação do Papel
        RETURN 'PORTRAIT';
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

    PROCEDURE envia_email ( vp_cod_empresa IN VARCHAR2
                          , vp_data_ini IN DATE
                          , vp_data_fim IN DATE
                          , vp_msg_oracle IN VARCHAR2
                          , vp_tipo IN VARCHAR2
                          , vp_data_hora_ini IN DATE )
    IS
        vp_data_hora_fim DATE;
        v_diferenca_exec VARCHAR2 ( 50 );
        v_tempo_exec VARCHAR2 ( 50 );

        v_txt_email VARCHAR2 ( 2000 ) := '';
        v_assunto VARCHAR2 ( 100 ) := '';

        v_nm_tipo VARCHAR2 ( 100 );
        v_nm_cproc VARCHAR2 ( 100 );
    BEGIN
        loga ( '>> Envia Email [' || vp_tipo || ']'
             , FALSE );

        SELECT TRANSLATE (
                           mnm_tipo
                         , 'ÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÜÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÜáçéíóúàèìòùâêîôûãõëüáçéíóúàèìòùâêîôûãõëü'
                         , 'ACEIOUAEIOUAEIOUAOEUACEIOUAEIOUAEIOUAOEUaceiouaeiouaeiouaoeuaceiouaeiouaeiouaoeu'
               )
          INTO v_nm_tipo
          FROM DUAL;

        SELECT TRANSLATE (
                           mnm_cproc
                         , 'ÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÜÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÜáçéíóúàèìòùâêîôûãõëüáçéíóúàèìòùâêîôûãõëü'
                         , 'ACEIOUAEIOUAEIOUAOEUACEIOUAEIOUAEIOUAOEUaceiouaeiouaeiouaoeuaceiouaeiouaeiouaoeu'
               )
          INTO v_nm_cproc
          FROM DUAL;

        vp_data_hora_fim := SYSDATE;

        ---------------------------------------------------------------------
        --CALCULAR TEMPO DE EXECUCAO DO RELATORIO
        SELECT b.diferenca
             ,    TRUNC ( MOD ( b.diferenca * 24
                              , 60 ) )
               || ':'
               || TRUNC ( MOD ( b.diferenca * 24 * 60
                              , 60 ) )
               || ':'
               || TRUNC ( MOD ( b.diferenca * 24 * 60 * 60
                              , 60 ) )
                   tempo
          INTO v_diferenca_exec
             , v_tempo_exec
          FROM (SELECT a.data_final - a.data_inicial AS diferenca
                  FROM (SELECT vp_data_hora_ini AS data_inicial
                             , vp_data_hora_fim AS data_final
                          FROM DUAL) a) b;

        ---------------------------------------------------------------------

        IF ( vp_tipo = 'E' ) THEN
            v_txt_email := v_txt_email || CHR ( 13 ) || '[ERRO] ';
        ELSE
            v_txt_email := 'Processo ' || v_nm_cproc || ' finalizado com SUCESSO.';
        END IF;

        v_txt_email :=
               v_txt_email
            || CHR ( 13 )
            || LPAD ( '-'
                    , 50
                    , '-' );
        v_txt_email := v_txt_email || CHR ( 13 ) || ' - Assunto: ' || v_nm_tipo;
        v_txt_email := v_txt_email || CHR ( 13 ) || ' - Processo: ' || v_nm_cproc;

        v_txt_email := v_txt_email || CHR ( 13 ) || ' - Num Processo: ' || vs_mproc_id;
        v_txt_email := v_txt_email || CHR ( 13 ) || ' - Package: ' || $$plsql_unit;

        v_txt_email :=
               v_txt_email
            || CHR ( 13 )
            || LPAD ( '-'
                    , 50
                    , '-' );
        v_txt_email := v_txt_email || CHR ( 13 ) || ' ';

        v_txt_email := v_txt_email || CHR ( 13 ) || '>> Parâmetros: ';
        v_txt_email := v_txt_email || CHR ( 13 ) || ' - Empresa: ' || vp_cod_empresa;
        v_txt_email :=
               v_txt_email
            || CHR ( 13 )
            || ' - Data Início: '
            || TO_CHAR ( vp_data_ini
                       , 'DD/MM/YYYY' );
        v_txt_email :=
               v_txt_email
            || CHR ( 13 )
            || ' - Data Fim: '
            || TO_CHAR ( vp_data_fim
                       , 'DD/MM/YYYY' );
        v_txt_email := v_txt_email || CHR ( 13 ) || ' ';
        v_txt_email := v_txt_email || CHR ( 13 ) || '>> LOG: ';
        v_txt_email := v_txt_email || CHR ( 13 ) || ' - Executado por: ' || vs_mcod_usuario;
        v_txt_email :=
               v_txt_email
            || CHR ( 13 )
            || ' - Hora Início: '
            || TO_CHAR ( vp_data_hora_ini
                       , 'DD/MM/YYYY HH24:MI.SS' );
        v_txt_email :=
               v_txt_email
            || CHR ( 13 )
            || ' - Hora Término: '
            || TO_CHAR ( SYSDATE
                       , 'DD/MM/YYYY HH24:MI.SS' );
        v_txt_email := v_txt_email || CHR ( 13 ) || ' - Tempo Execução: ' || TRIM ( v_tempo_exec );

        IF ( vp_tipo = 'E' ) THEN
            v_txt_email := v_txt_email || CHR ( 13 ) || ' ';
            v_txt_email := v_txt_email || CHR ( 13 ) || '<< ERRO >> ' || CHR ( 13 ) || vp_msg_oracle;
        END IF;

        --TIRAR ACENTOS
        SELECT TRANSLATE (
                           v_txt_email
                         , 'ÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÜÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÜáçéíóúàèìòùâêîôûãõëüáçéíóúàèìòùâêîôûãõëü'
                         , 'ACEIOUAEIOUAEIOUAOEUACEIOUAEIOUAEIOUAOEUaceiouaeiouaeiouaoeuaceiouaeiouaeiouaoeu'
               )
          INTO v_txt_email
          FROM DUAL;

        SELECT TRANSLATE (
                           v_assunto
                         , 'ÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÜÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÜáçéíóúàèìòùâêîôûãõëüáçéíóúàèìòùâêîôûãõëü'
                         , 'ACEIOUAEIOUAEIOUAOEUACEIOUAEIOUAEIOUAOEUaceiouaeiouaeiouaoeuaceiouaeiouaeiouaoeu'
               )
          INTO v_assunto
          FROM DUAL;

        IF ( vp_tipo = 'E' ) THEN
            v_assunto := 'Mastersaf - ' || v_nm_tipo || ' - ' || v_nm_cproc || ' apresentou ERRO';
            notifica ( ''
                     , 'S'
                     , v_assunto
                     , v_txt_email
                     , $$plsql_unit );
        ELSE
            v_assunto := 'Mastersaf - ' || v_nm_tipo || ' - ' || v_nm_cproc || ' Concluido';
            notifica ( 'S'
                     , ''
                     , v_assunto
                     , v_txt_email
                     , $$plsql_unit );
        END IF;
    END;

    PROCEDURE arquivo_scheduler ( pcod_job VARCHAR2
                                , v_id_arq INTEGER )
    IS
        CURSOR consultar
        IS
            SELECT   owner
                   , job_name
                   , job_type
                   , job_action
                   , schedule_type
                   , start_date
                   , repeat_interval
                   , enabled
                   , state
                   , last_start_date
                   , last_run_duration
                   , next_run_date
                   , nls_env
                   , comments
                FROM all_scheduler_jobs
               WHERE job_name = pcod_job
            ORDER BY 1
                   , 2;

        v_text01 VARCHAR2 ( 6000 );
        v_class VARCHAR2 ( 1 );
    BEGIN
        lib_proc.add ( dsp_planilha.header
                     , ptipo => v_id_arq );
        lib_proc.add ( dsp_planilha.tabela_inicio
                     , ptipo => v_id_arq );

        lib_proc.add ( dsp_planilha.linha ( p_conteudo =>    dsp_planilha.campo ( 'OWNER' )
                                                          || --
                                                            dsp_planilha.campo ( 'JOB_NAME' )
                                                          || --
                                                            dsp_planilha.campo ( 'JOB_TYPE' )
                                                          || --
                                                            dsp_planilha.campo ( 'JOB_ACTION' )
                                                          || --
                                                            dsp_planilha.campo ( 'SCHEDULE_TYPE' )
                                                          || --
                                                            dsp_planilha.campo ( 'START_DATE' )
                                                          || --
                                                            dsp_planilha.campo ( 'REPEAT_INTERVAL' )
                                                          || --
                                                            dsp_planilha.campo ( 'ENABLED'
                                                                               , p_custom => 'BGCOLOR=#008000' )
                                                          || --
                                                            dsp_planilha.campo ( 'STATE'
                                                                               , p_custom => 'BGCOLOR=#008000' )
                                                          || --
                                                            dsp_planilha.campo ( 'LAST_START_DATE' )
                                                          || --
                                                            dsp_planilha.campo ( 'LAST_RUN_DURATION' )
                                                          || --
                                                            dsp_planilha.campo ( 'NEXT_RUN_DATE' )
                                                          || --
                                                            dsp_planilha.campo ( 'NLS_ENV' )
                                                          || --
                                                            dsp_planilha.campo ( 'COMMENTS' )
                                                          || --
                                                            ''
                                          , p_class => 'h' )
                     , ptipo => v_id_arq );

        FOR c IN consultar LOOP
            --Alterar a cor conforme a linha muda
            --IF V_CLASS = 'a' THEN
            v_class := 'b';
            --ELSE
            --  V_CLASS := 'a';
            --END IF;

            v_text01 :=
                dsp_planilha.linha (
                                     p_conteudo =>    dsp_planilha.campo ( dsp_planilha.texto ( c.owner ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( c.job_name ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( c.job_type ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( c.job_action ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( c.schedule_type ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( c.start_date ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( c.repeat_interval ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( c.enabled ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( c.state ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( c.last_start_date ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( c.last_run_duration ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( c.next_run_date ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( c.nls_env ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( c.comments ) )
                                   , p_class => v_class
                );
            lib_proc.add ( v_text01
                         , ptipo => v_id_arq );
        END LOOP;

        lib_proc.add ( dsp_planilha.tabela_fim
                     , ptipo => v_id_arq );
    END;

    PROCEDURE arquivo_log ( pcod_job VARCHAR2
                          , v_id_arq INTEGER )
    IS
        CURSOR consultar
        IS
            SELECT   log_id
                   , log_date
                   , owner
                   , job_name
                   , job_subname
                   , status
                   , --ERROR# as ERROR,
                     req_start_date
                   , actual_start_date
                   , run_duration
                   , instance_id
                   , session_id
                   , slave_pid
                   , cpu_used
                   , --CREDENTIAL_OWNER,
                     --CREDENTIAL_NAME,
                     --DESTINATION_OWNER,
                     --DESTINATION
                     --ADDITIONAL_INFO,
                     errors
                FROM all_scheduler_job_run_details
               WHERE job_name = pcod_job
                 AND log_date >= SYSDATE - 60
            ORDER BY 1 DESC;

        v_text01 VARCHAR2 ( 6000 );
        v_class VARCHAR2 ( 1 );
    BEGIN
        lib_proc.add ( dsp_planilha.header
                     , ptipo => v_id_arq );
        lib_proc.add ( dsp_planilha.tabela_inicio
                     , ptipo => v_id_arq );

        lib_proc.add ( dsp_planilha.linha ( p_conteudo =>    dsp_planilha.campo ( 'LOG_ID' )
                                                          || --
                                                            dsp_planilha.campo ( 'LOG_DATE' )
                                                          || --
                                                            dsp_planilha.campo ( 'OWNER' )
                                                          || --
                                                            dsp_planilha.campo ( 'JOB_NAME' )
                                                          || --
                                                            dsp_planilha.campo ( 'JOB_SUBNAME' )
                                                          || --
                                                            dsp_planilha.campo ( 'STATUS'
                                                                               , p_custom => 'BGCOLOR=#008000' )
                                                          || --
                                                            dsp_planilha.campo ( 'ERROR' )
                                                          || --
                                                            dsp_planilha.campo ( 'REQ_START_DATE' )
                                                          || --
                                                            dsp_planilha.campo ( 'ACTUAL_START_DATE' )
                                                          || --
                                                            dsp_planilha.campo ( 'RUN_DURATION'
                                                                               , p_custom => 'BGCOLOR=#008000' )
                                                          || --
                                                            dsp_planilha.campo ( 'INSTANCE_ID' )
                                                          || --
                                                            dsp_planilha.campo ( 'SESSION_ID' )
                                                          || --
                                                            dsp_planilha.campo ( 'SLAVE_PID' )
                                                          || --
                                                            dsp_planilha.campo ( 'CPU_USED' )
                                                          || --
                                                             --DSP_PLANILHA.CAMPO('CREDENTIAL_OWNER') || --
                                                             --DSP_PLANILHA.CAMPO('CREDENTIAL_NAME') || --
                                                             --DSP_PLANILHA.CAMPO('DESTINATION_OWNER') || --
                                                             --DSP_PLANILHA.CAMPO('DESTINATION') || --
                                                             --DSP_PLANILHA.CAMPO('ADDITIONAL_INFO'), || --
                                                             dsp_planilha.campo ( 'RUN_DURATION'
                                                                                , p_custom => 'BGCOLOR=#FF0000' )
                                                          || --
                                                            ''
                                          , p_class => 'h' )
                     , ptipo => v_id_arq );

        FOR c IN consultar LOOP
            --Alterar a cor conforme a linha muda
            --IF V_CLASS = 'a' THEN
            v_class := 'b';
            --ELSE
            --  V_CLASS := 'a';
            --END IF;

            v_text01 :=
                dsp_planilha.linha (
                                     p_conteudo =>    dsp_planilha.campo ( dsp_planilha.texto ( c.log_id ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( c.log_date ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( c.owner ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( c.job_name ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( c.job_subname ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( c.status ) )
                                                   || --
                                                      --DSP_PLANILHA.CAMPO(DSP_PLANILHA.TEXTO(C.ERROR)) || --
                                                      dsp_planilha.campo ( dsp_planilha.texto ( c.req_start_date ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( c.actual_start_date ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( c.run_duration ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( c.instance_id ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( c.session_id ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( c.slave_pid ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( c.cpu_used ) )
                                                   || --
                                                      --DSP_PLANILHA.CAMPO(DSP_PLANILHA.TEXTO(C.CREDENTIAL_OWNER)) || --
                                                      --DSP_PLANILHA.CAMPO(DSP_PLANILHA.TEXTO(C.CREDENTIAL_NAME)) || --
                                                      --DSP_PLANILHA.CAMPO(DSP_PLANILHA.TEXTO(C.DESTINATION_OWNER)) || --
                                                      --DSP_PLANILHA.CAMPO(DSP_PLANILHA.TEXTO(C.DESTINATION)) || --
                                                      --DSP_PLANILHA.CAMPO(DSP_PLANILHA.TEXTO(C.ADDITIONAL_INFO) || --
                                                      dsp_planilha.campo ( dsp_planilha.texto ( c.errors ) || --
                                                                                                             '' )
                                   , p_class => v_class
                );
            lib_proc.add ( v_text01
                         , ptipo => v_id_arq );
        END LOOP;

        lib_proc.add ( dsp_planilha.tabela_fim
                     , ptipo => v_id_arq );
    END;

    FUNCTION executar ( flg_processo CHAR
                      , pcod_job lib_proc.vartab )
        RETURN INTEGER
    IS
        v_data_exec DATE;
        dsc_processo VARCHAR2 ( 30 );
        v_id_arq NUMBER := 3;
    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS= '',.'' ';

        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_LANGUAGE = ''Portuguese'' ';

        --Performar em caso de códigos repetitivos no mesmo plano de execução
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING = FORCE';

        --Recuperar a empresa para o plano de execução caso não esteja sendo executado pelo diretamente na tela do Mastersaf
        lib_parametros.salvar ( 'EMPRESA'
                              , NVL ( vs_mcod_empresa, msafi.dpsp.v_empresa ) );

        vs_mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        vs_mcod_usuario := lib_parametros.recuperar ( 'USUARIO' );

        IF vs_mcod_usuario IS NULL THEN
            lib_parametros.salvar ( 'USUARIO'
                                  , 'AUTOMATICO' );
            vs_mcod_usuario := lib_parametros.recuperar ( 'USUARIO' );
        END IF;

        -- Criação: Processo
        vs_mproc_id :=
            lib_proc.new ( psp_nome => $$plsql_unit
                         , prows => 48
                         , pcols => 200 );
        COMMIT;

        v_data_exec := SYSDATE;

        loga ( '<<' || mnm_cproc || '>>'
             , FALSE );
        loga ( '---INICIO DO PROCESSAMENTO---'
             , FALSE );

        dbms_application_info.set_module ( $$plsql_unit
                                         , 'PROC_ID: ' || vs_mproc_id );

        loga (    '>> Data execução: '
               || TO_CHAR ( v_data_exec
                          , 'DD/MM/YYYY HH24:MI:SS' )
             , FALSE );
        loga ( 'Usuário: ' || vs_mcod_usuario
             , FALSE );

        --IMPUTAR DESCRIÇÃO
        IF flg_processo = 'E' THEN
            dsc_processo := 'Executar';
        ELSIF flg_processo = 'C' THEN
            dsc_processo := 'Consultar Scheduler';
        ELSIF flg_processo = 'L' THEN
            dsc_processo := 'Consultar Log';
        ELSIF flg_processo = 'A' THEN
            dsc_processo := 'Habilitar';
        ELSIF flg_processo = 'D' THEN
            dsc_processo := 'Desabilitar';
        END IF;

        loga ( '----------------------------------------'
             , FALSE );
        loga ( '>> ' || dsc_processo
             , FALSE );
        loga ( '----------------------------------------'
             , FALSE );

        FOR i IN pcod_job.FIRST .. pcod_job.LAST LOOP
            loga ( 'Job_Scheduler: ' || pcod_job ( i )
                 , FALSE );

            --=================================================
            IF flg_processo = 'E' THEN
                loga ( '[INICIAR EXECUÇÃO DO JOB]' );

                BEGIN
                    dbms_scheduler.run_job ( job_name => pcod_job ( i ) );
                END;

                loga ( '[FIM DA EXECUÇÃO DO JOB]' );
            --=================================================

            ELSIF flg_processo = 'C' THEN
                -- Criação: Relatório CSV
                lib_proc.add_tipo ( vs_mproc_id
                                  , v_id_arq
                                  , pcod_job ( i ) || '_Job_Scheduler.xls'
                                  , 2 );

                arquivo_scheduler ( pcod_job ( i )
                                  , v_id_arq );

                loga ( '>> Arquivo gerado'
                     , FALSE );

                v_id_arq := v_id_arq + 1;
            --=================================================

            ELSIF flg_processo = 'L' THEN
                -- Criação: Relatório CSV
                lib_proc.add_tipo ( vs_mproc_id
                                  , v_id_arq
                                  , pcod_job ( i ) || '_Log_Job_Details.xls'
                                  , 2 );

                arquivo_log ( pcod_job ( i )
                            , v_id_arq );

                loga ( '>> Arquivo gerado'
                     , FALSE );

                v_id_arq := v_id_arq + 1;
            --=================================================

            ELSIF flg_processo = 'A' THEN
                BEGIN
                    dbms_scheduler.enable ( pcod_job ( i ) );
                END;

                loga ( '>> Job ativado'
                     , FALSE );
            --=================================================
            ELSIF flg_processo = 'D' THEN
                BEGIN
                    dbms_scheduler.disable ( pcod_job ( i ) );
                END;

                loga ( '>> Job desativado'
                     , FALSE );
            END IF;
        END LOOP;

        loga ( '---FIM DO PROCESSAMENTO---'
             , FALSE );

        lib_proc.close ( );
        RETURN vs_mproc_id;
    END;
END dpsp_carga_imp_jobs_cproc;
/
SHOW ERRORS;
