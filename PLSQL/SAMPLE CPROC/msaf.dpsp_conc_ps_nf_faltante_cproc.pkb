Prompt Package Body DPSP_CONC_PS_NF_FALTANTE_CPROC;
--
-- DPSP_CONC_PS_NF_FALTANTE_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_conc_ps_nf_faltante_cproc
IS
    mproc_id NUMBER;
    mcod_usuario usuario_estab.cod_usuario%TYPE;
    mcod_empresa estabelecimento.cod_empresa%TYPE;
    v_class VARCHAR2 ( 1 ) := 'A';
    v_step VARCHAR2 ( 30 ) := '';

    vg_module VARCHAR2 ( 60 ) := '';

    --Tipo, Nome e Descrição do Customizado
    mnm_tipo VARCHAR2 ( 100 ) := 'Automatização';
    mnm_cproc VARCHAR2 ( 100 ) := 'Relatório Notas Fiscais faltantes entre Peoplesoft e Mastersaf DW';
    mds_cproc VARCHAR2 ( 100 )
        := 'Relatório para verificar notas fiscais faltantes entre os sistemas Peoplesoft e Mastersaf DW';

    v_sel_data_fim VARCHAR2 ( 260 )
        := ' SELECT TRUNC( TO_DATE( :1 ,''DD/MM/YYYY'') + ROWNUM - 1) AS DATA_FIM, TRUNC( TO_DATE( :1 ,''DD/MM/YYYY'') + ROWNUM - 1) AS DATA_FIM FROM DUAL CONNECT BY ROWNUM <= LAST_DAY( TO_DATE( :1 ,''DD/MM/YYYY'') ) - TO_DATE( :1 ,''DD/MM/YYYY'') + 1 ORDER BY 1 DESC ';

    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );
    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS= '',.'' ';

        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_LANGUAGE = ''Portuguese'' ';

        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        mcod_usuario := lib_parametros.recuperar ( 'USUARIO' );

        lib_parametros.salvar ( 'EMPRESA'
                              , NVL ( mcod_empresa, msafi.dpsp.v_empresa ) );

        --1
        lib_proc.add_param ( pparam => pstr
                           , ptitulo => 'Data Inicial'
                           , --P_DT_INI
                            ptipo => 'DATE'
                           , pcontrole => 'TEXTBOX'
                           , pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => 'DD/MM/YYYY' );
        --2
        lib_proc.add_param ( pparam => pstr
                           , ptitulo => 'Data Final'
                           , --P_DT_FIM
                            ptipo => 'VARCHAR2'
                           , pcontrole => 'COMBOBOX'
                           , pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => '##########'
                           , pvalores => v_sel_data_fim );
        --3
        lib_proc.add_param ( pparam => pstr
                           , ptitulo => 'Todas as lojas'
                           , --P_TODOS_ESTAB
                            ptipo => 'VARCHAR2'
                           , pcontrole => 'CHECKBOX'
                           , pmandatorio => 'N'
                           , pdefault => 'S'
                           , pmascara => NULL );
        --4
        lib_proc.add_param (
                             pparam => pstr
                           , ptitulo => 'Movimento'
                           , -- P_MOVTO_E_S
                            ptipo => 'VARCHAR2'
                           , pcontrole => 'COMBOBOX'
                           , pmandatorio => 'S'
                           , pdefault => '1'
                           , pmascara => '####################'
                           , pvalores =>    'SELECT 1, ''1-Entrada/Saida'' from dual ' --
                                         || ' union all SELECT 2, ''2-Entrada'' from dual ' --
                                         || ' union all SELECT 3, ''3-Saida'' from dual ' --
                                         || ' ORDER BY 1'
        );
        --5
        lib_proc.add_param (
                             pparam => pstr
                           , ptitulo => 'Analisar'
                           , -- P_BUSCA
                            ptipo => 'VARCHAR2'
                           , pcontrole => 'COMBOBOX'
                           , pmandatorio => 'S'
                           , pdefault => '1'
                           , pmascara => '#########################################'
                           , pvalores =>    'SELECT 1, ''1-NF PS faltante MSAF/NF MSAF faltante PS'' from dual ' --
                                         || ' union all SELECT 2, ''2-NF PS faltante MSAF'' from dual ' --
                                         || ' union all SELECT 3, ''3-NF MSAF faltante PS'' from dual ' --
                                         || ' ORDER BY 1'
        );
        --6
        lib_proc.add_param (
                             pparam => pstr
                           , ptitulo => 'UF'
                           , -- P_UF
                            ptipo => 'VARCHAR2'
                           , pcontrole => 'COMBOBOX'
                           , pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => '####################'
                           , pvalores =>    'SELECT COD_ESTADO, COD_ESTADO || '' - '' || DESCRICAO TXT FROM ESTADO '
                                         || ' WHERE COD_ESTADO IN (SELECT COD_ESTADO FROM DSP_ESTABELECIMENTO_V) UNION ALL SELECT ''%'', ''Todas as UFs'' FROM DUAL'
                                         || '  ORDER BY 1'
                           , phabilita => ' :3 = ''N'''
        );

        --7
        lib_proc.add_param ( pparam => pstr
                           , ptitulo => 'Carregar Faltantes'
                           , --P_CARREGAR
                            ptipo => 'VARCHAR2'
                           , pcontrole => 'CHECKBOX'
                           , pmandatorio => 'N'
                           , pdefault => 'S'
                           , pmascara => NULL );

        lib_proc.add_param ( pparam => pstr
                           , ptitulo => LPAD ( '-'
                                             , 150
                                             , '-' )
                           , --P_CARREGAR
                            ptipo => 'VARCHAR2'
                           , pcontrole => 'TEXT'
                           , pmandatorio => NULL
                           , pdefault => NULL
                           , pmascara => NULL );

        lib_proc.add_param (
                             pparam => pstr
                           , ptitulo => 'Paralelismo por'
                           , --P_FLG_THREAD
                            ptipo => 'VARCHAR2'
                           , pcontrole => 'COMBOBOX'
                           , pmandatorio => 'N'
                           , pdefault => '1'
                           , pmascara => '####################'
                           , pvalores =>    'SELECT 1, ''1-ID NFs'' FROM DUAL UNION ALL '
                                         || --
                                           'SELECT 2, ''2-Lojas'' FROM DUAL '
                           , phabilita => ' :7 = ''S'''
        );

        lib_proc.add_param ( pparam => pstr
                           , ptitulo => 'Qtde de Execuções em Paralelo'
                           , --P_NUM_THREAD
                            ptipo => 'NUMBER'
                           , pcontrole => 'TEXTBOX'
                           , pmandatorio => 'S'
                           , pdefault => '20'
                           , pmascara => '####'
                           , phabilita => ' :7 = ''S''' );

        lib_proc.add_param ( pparam => pstr
                           , ptitulo => LPAD ( '-'
                                             , 150
                                             , '-' )
                           , --P_CARREGAR
                            ptipo => 'VARCHAR2'
                           , pcontrole => 'TEXT'
                           , pmandatorio => NULL
                           , pdefault => NULL
                           , pmascara => NULL );

        lib_proc.add_param (
                             pparam => pstr
                           , ptitulo => 'Estabelecimentos'
                           , --P_LOJAS
                            ptipo => 'VARCHAR2'
                           , pcontrole => 'MULTISELECT'
                           , pmandatorio => ' :3 = ''N'''
                           , pdefault => NULL
                           , pmascara => NULL
                           , pvalores =>    ' SELECT COD_ESTAB COD , COD_ESTADO||'' - ''||COD_ESTAB||'' - ''||INITCAP(ENDER) ||'' ''||(CASE WHEN TIPO = ''C'' THEN ''(CD)'' END) LOJA'
                                         || --
                                           ' FROM MSAF.DSP_ESTABELECIMENTO_V WHERE 1=1 '
                                         || ' AND COD_EMPRESA = '''
                                         || mcod_empresa
                                         || ''' AND COD_ESTADO LIKE :6 AND :3 = ''N'' ORDER BY TIPO, COD_ESTAB'
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
        v_assunto VARCHAR2 ( 2000 ) := '';

        v_nm_tipo VARCHAR2 ( 100 );
        v_nm_cproc VARCHAR2 ( 100 );
    BEGIN
        loga ( '>> Envia Email'
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

        v_txt_email := v_txt_email || CHR ( 13 ) || ' - Num Processo: ' || mproc_id;
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
        v_txt_email := v_txt_email || CHR ( 13 ) || ' - Executado por: ' || mcod_usuario;
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

    PROCEDURE load_gtt_ps ( p_periodo DATE
                          , p_movto_e_s VARCHAR2
                          , p_cod_estab VARCHAR2 )
    IS
        v_count NUMBER := 0;
    BEGIN
        loga ( '[INICIAR LOAD_GTT_PS]'
             , TRUE );

        --=========================================================
        loga ( '>> SAIDAS PS'
             , TRUE );
        --=========================================================
        v_step := 'A';

        dbms_application_info.set_module ( $$plsql_unit
                                         , mproc_id || ' SAI LJ:' || p_cod_estab );

        FOR c_ps_saida
            IN ( SELECT /*+ DRIVING_SITE(NFH) */
                        --
                       estab.cod_estab
                      , nfh.ef_loc_brl
                      , nfh.nf_brl
                      , nfh.nf_brl_id
                      , nfh.nf_brl_series
                      , nfh.accounting_dt
                      , -------------
                        nfh.lt_grp_id_bbl
                      , nfh.entered_dt
                      , nfh.nf_conf_dt_bbl
                      , nfh.nf_issue_dt_bbl
                   FROM msafi.ps_nf_hdr_bbl_fs nfh
                      , msafi.dsp_estabelecimento estab
                  WHERE 1 = 1
                    AND estab.cod_empresa = mcod_empresa
                    AND nfh.ef_loc_brl = estab.location
                    AND estab.cod_estab = DECODE ( p_cod_estab, '%', estab.cod_estab, p_cod_estab )
                    AND nfh.nf_brl_date >= (  TRUNC ( p_periodo
                                                    , 'MM' )
                                            - 95) -- INCLUIDO FILTRO PARA MELHORIA DE PERFOMANCE PEGANDO UM RANGE MENOR DE PARTICAO
                    AND TO_DATE ( ( CASE
                                       WHEN nfh.lt_grp_id_bbl IN ( 'TRO_LIB_23'
                                                                 , 'TRO_DIA_23' ) THEN
                                           TO_CHAR ( nfh.entered_dt
                                                   , 'YYYYMMDD' )
                                       WHEN nfh.lt_grp_id_bbl IN ( 'EST_LIB_14'
                                                                 , 'EST_LIB_4'
                                                                 , 'EST_DIA_23'
                                                                 , 'EST_DIA_2'
                                                                 , 'EST_LIB_23'
                                                                 , 'EST_LIB_3' ) THEN
                                           TO_CHAR ( NVL ( nfh.nf_conf_dt_bbl, nfh.nf_issue_dt_bbl )
                                                   , 'YYYYMMDD' )
                                       ELSE
                                           TO_CHAR ( nfh.nf_issue_dt_bbl
                                                   , 'YYYYMMDD' )
                                   END )
                                , 'YYYYMMDD' ) = p_periodo
                    AND TRIM ( nfh.inout_flg_pbl ) =
                            DECODE ( p_movto_e_s,  1, TRIM ( nfh.inout_flg_pbl ),  2, 'I',  3, 'O' ) ) LOOP
            INSERT /*+ APPEND */
                  INTO  msafi.dpsp_conc_nf_falt_ps_sai_gtt ( cod_estab
                                                           , ef_loc_brl
                                                           , nf_brl
                                                           , nf_brl_id
                                                           , nf_brl_series
                                                           , accounting_dt
                                                           , lt_grp_id_bbl
                                                           , entered_dt
                                                           , nf_conf_dt_bbl
                                                           , nf_issue_dt_bbl )
                 VALUES ( c_ps_saida.cod_estab
                        , c_ps_saida.ef_loc_brl
                        , c_ps_saida.nf_brl
                        , c_ps_saida.nf_brl_id
                        , c_ps_saida.nf_brl_series
                        , c_ps_saida.accounting_dt
                        , c_ps_saida.lt_grp_id_bbl
                        , c_ps_saida.entered_dt
                        , c_ps_saida.nf_conf_dt_bbl
                        , c_ps_saida.nf_issue_dt_bbl );

            --OBS: TABELAS TEMPORARIAS (GLOBAL TEMPORARY) CARREGADAS POR CONSULTAS COM DBLINK
            --DEVEM SER COMMITADAS DURANTE O LOOP CASO O CONTRÁRIO SERÃO TRUNCADAS.
            COMMIT;
        END LOOP;

        COMMIT;

        SELECT COUNT ( 1 )
          INTO v_count
          FROM msafi.dpsp_conc_nf_falt_ps_sai_gtt;

        loga ( 'Qtd tabela: ' || v_count
             , FALSE );

        --=========================================================
        loga ( '>> ENTRADAS PS'
             , TRUE );
        --=========================================================
        v_step := 'B';

        dbms_application_info.set_module ( $$plsql_unit
                                         , mproc_id || ' ENT LJ:' || p_cod_estab );

        FOR c_ps_entrada
            IN ( SELECT /*+ DRIVING_SITE(NFH) */
                        --
                       estab.cod_estab
                      , nfh.ef_loc_brl
                      , nfh.nf_brl
                      , nfh.nf_brl_id
                      , nfh.nf_brl_series
                      , nfh.accounting_dt
                      , -------------
                        nfh.lt_grp_id_bbl
                      , nfh.entered_dt
                      , nfh.nf_conf_dt_bbl
                      , nfh.nf_issue_dt_bbl
                   FROM msafi.ps_nf_hdr_brl nfh
                      , msafi.dsp_estabelecimento estab
                  WHERE 1 = 1
                    AND estab.cod_empresa = mcod_empresa
                    AND nfh.ef_loc_brl = estab.location
                    AND estab.cod_estab = DECODE ( p_cod_estab, '%', estab.cod_estab, p_cod_estab )
                    AND accounting_dt = p_periodo
                    AND TRIM ( nfh.inout_flg_pbl ) =
                            DECODE ( p_movto_e_s,  1, TRIM ( nfh.inout_flg_pbl ),  2, 'I',  3, 'O' )
                    AND nfh.nf_brl_type NOT IN ( 'GNR'
                                               , 'GUI' )
                    AND nfh.nf_brl_series <> 'GAR' ) LOOP
            INSERT /*+ APPEND */
                  INTO  msafi.dpsp_conc_nf_falt_ps_ent_gtt ( cod_estab
                                                           , ef_loc_brl
                                                           , nf_brl
                                                           , nf_brl_id
                                                           , nf_brl_series
                                                           , accounting_dt
                                                           , lt_grp_id_bbl
                                                           , entered_dt
                                                           , nf_conf_dt_bbl
                                                           , nf_issue_dt_bbl )
                 VALUES ( c_ps_entrada.cod_estab
                        , c_ps_entrada.ef_loc_brl
                        , c_ps_entrada.nf_brl
                        , c_ps_entrada.nf_brl_id
                        , c_ps_entrada.nf_brl_series
                        , c_ps_entrada.accounting_dt
                        , c_ps_entrada.lt_grp_id_bbl
                        , c_ps_entrada.entered_dt
                        , c_ps_entrada.nf_conf_dt_bbl
                        , c_ps_entrada.nf_issue_dt_bbl );

            --OBS: TABELAS TEMPORARIAS (GLOBAL TEMPORARY) CARREGADAS POR CONSULTAS COM DBLINK
            --DEVEM SER COMMITADAS DURANTE O LOOP CASO O CONTRÁRIO SERÃO TRUNCADAS.
            COMMIT;
        END LOOP;

        COMMIT;

        SELECT COUNT ( 1 )
          INTO v_count
          FROM msafi.dpsp_conc_nf_falt_ps_ent_gtt;

        loga ( 'Qtd tabela: ' || v_count
             , FALSE );

        --=========================================================
        loga ( '[FIM LOAD_GTT_PS]'
             , TRUE );
    --=========================================================

    END load_gtt_ps;

    PROCEDURE load_excel_ps ( p_periodo DATE
                            , v_dt_first DATE
                            , p_movto_e_s VARCHAR2
                            , p_cod_estab VARCHAR2
                            , p_carregar VARCHAR2
                            , v_data_exec DATE )
    IS
        v_text01 VARCHAR2 ( 10000 );
        v_script VARCHAR2 ( 10000 ) := '';
        v_count NUMBER := 0;
    BEGIN
        --=========================================================
        loga ( '[INICIAR LOAD_EXCEL_PS]'
             , TRUE );

        --=========================================================

        IF p_movto_e_s IN ( 1
                          , 3 ) THEN
            --=========================================================
            loga ( '>> SAIDAS DIF'
                 , TRUE );
            --=========================================================
            v_step := 'C';

            dbms_application_info.set_module ( $$plsql_unit
                                             , mproc_id || ' SAI LJ:' || p_cod_estab );

            EXECUTE IMMEDIATE 'TRUNCATE TABLE MSAFI.DPSP_CONC_NF_FALT_PS_CHAVE';

            v_script := '';
            v_script := v_script || ' DECLARE ';
            v_script := v_script || ' BEGIN ';
            v_script := v_script || ' FOR DIF IN ( ';
            v_script := v_script || ' SELECT * FROM MSAFI.DPSP_CONC_NF_FALT_PS_SAI_GTT GTT ';
            v_script := v_script || ' WHERE 1 = 1 ';
            v_script :=
                   v_script
                || 'AND GTT.COD_ESTAB = DECODE('''
                || p_cod_estab
                || ''', ''%'', GTT.COD_ESTAB, '''
                || p_cod_estab
                || ''') ';
            v_script := v_script || 'AND TO_DATE((CASE WHEN GTT.LT_GRP_ID_BBL IN ';
            v_script := v_script || '(''TRO_LIB_23'', ''TRO_DIA_23'') THEN ';
            v_script := v_script || 'TO_CHAR(GTT.ENTERED_DT, ''YYYYMMDD'') WHEN ';
            v_script := v_script || ' GTT.LT_GRP_ID_BBL IN ';
            v_script := v_script || ' (''EST_LIB_14'', ''EST_LIB_4'', ''EST_DIA_23'', ';
            v_script := v_script || ' ''EST_DIA_2'', ''EST_LIB_23'', ''EST_LIB_3'') THEN ';
            v_script := v_script || ' TO_CHAR(NVL(GTT.NF_CONF_DT_BBL, ';
            v_script := v_script || ' GTT.NF_ISSUE_DT_BBL), ';
            v_script := v_script || ' ''YYYYMMDD'') ELSE ';
            v_script := v_script || ' TO_CHAR(GTT.NF_ISSUE_DT_BBL, ''YYYYMMDD'') END), ';
            v_script := v_script || ' ''YYYYMMDD'') = ''' || p_periodo || ''' ';
            --=========================================================
            v_script := v_script || ' AND NOT EXISTS ';
            v_script := v_script || ' (SELECT 1 ';
            v_script := v_script || ' FROM MSAF.X07_DOCTO_FISCAL ';
            v_script := v_script || ' PARTITION FOR(TO_DATE(''' || v_dt_first || ''',''YYYYMMDD''))  ';
            v_script := v_script || ' X07 ';
            v_script := v_script || ' WHERE 1 = 1 ';
            v_script := v_script || ' AND X07.COD_EMPRESA = ''' || mcod_empresa || ''' ';
            v_script := v_script || ' AND X07.NUM_DOCFIS = GTT.NF_BRL ';
            v_script := v_script || ' AND X07.NUM_CONTROLE_DOCTO = GTT.NF_BRL_ID ';
            v_script := v_script || ' AND X07.DATA_FISCAL = ';
            v_script := v_script || ' TO_DATE((CASE WHEN GTT.LT_GRP_ID_BBL IN ';
            v_script := v_script || ' (''TRO_LIB_23'', ''TRO_DIA_23'') THEN ';
            v_script := v_script || ' TO_CHAR(GTT.ENTERED_DT, ''YYYYMMDD'') WHEN ';
            v_script := v_script || ' GTT.LT_GRP_ID_BBL IN ';
            v_script := v_script || ' (''EST_LIB_14'', ''EST_LIB_4'', ';
            v_script := v_script || ' ''EST_DIA_23'', ''EST_DIA_2'', ';
            v_script := v_script || ' ''EST_LIB_23'', ''EST_LIB_3'') THEN ';
            v_script := v_script || ' TO_CHAR(NVL(GTT.NF_CONF_DT_BBL, ';
            v_script := v_script || ' GTT.NF_ISSUE_DT_BBL), ';
            v_script := v_script || ' ''YYYYMMDD'') ELSE ';
            v_script := v_script || ' TO_CHAR(GTT.NF_ISSUE_DT_BBL, ';
            v_script := v_script || ' ''YYYYMMDD'') END), ';
            v_script := v_script || '  ''YYYYMMDD'') ';
            v_script := v_script || ' AND X07.COD_ESTAB = GTT.COD_ESTAB ';
            v_script := v_script || ' AND X07.SERIE_DOCFIS = GTT.NF_BRL_SERIES) ';
            --=========================================================
            v_script := v_script || ' ) LOOP ';
            v_script := v_script || ' INSERT INTO MSAFI.DPSP_CONC_NF_FALT_PS_CHAVE '; --
            v_script := v_script || ' (COD_ESTAB, ';
            v_script := v_script || ' EF_LOC_BRL, ';
            v_script := v_script || ' NF_BRL, ';
            v_script := v_script || ' NF_BRL_ID, ';
            v_script := v_script || ' NF_BRL_SERIES, ';
            v_script := v_script || ' ACCOUNTING_DT) ';
            v_script := v_script || ' VALUES ';
            v_script := v_script || ' (DIF.COD_ESTAB, ';
            v_script := v_script || ' DIF.EF_LOC_BRL, ';
            v_script := v_script || ' DIF.NF_BRL, ';
            v_script := v_script || ' DIF.NF_BRL_ID, ';
            v_script := v_script || ' DIF.NF_BRL_SERIES, ';
            v_script := v_script || ' DIF.ACCOUNTING_DT); ';
            --
            v_script := v_script || ' COMMIT; ';
            v_script := v_script || ' END LOOP; ';
            v_script := v_script || ' END; ';

            BEGIN
                EXECUTE IMMEDIATE v_script;

                COMMIT;
            EXCEPTION
                WHEN OTHERS THEN
                    raise_application_error ( -20001
                                            , SQLERRM || '>>' || v_script );
            END;

            SELECT COUNT ( 1 )
              INTO v_count
              FROM msafi.dpsp_conc_nf_falt_ps_chave;

            loga ( 'Qtd tabela: ' || v_count
                 , FALSE );

            --=========================================================
            loga ( '>> SAIDA RECUPERA DADOS'
                 , FALSE );
            --=========================================================
            v_step := 'D';

            FOR c
                IN ( SELECT /*+ DRIVING_SITE(NFH) */
                            --
                           mcod_empresa cod_empresa
                          , estab.cod_estab
                          , LPAD ( TO_CHAR ( TRIM ( nfh.nf_brl ) )
                                 , 9
                                 , '0' )
                                nf_brl
                          , --
                           LPAD ( TRIM ( nfh.nf_brl_id )
                                , 10
                                , '0' )
                                nf_brl_id
                          , nfh.accounting_dt
                          , --
                           nfh.last_update_dt
                          , nfh.ef_loc_brl
                          , --
                           nfh.nf_brl_series
                          , --
                            --
                            nfh.nf_brl_status
                          , -- 'F'
                            ( SELECT MAX ( xlatlongname )
                                FROM msafi.psxlatitem
                               WHERE fieldname = 'NF_BRL_STATUS'
                                 AND fieldvalue = nfh.nf_brl_status )
                                desc_nf_brl_status
                          , --
                            nfh.inout_flg_pbl
                          , --= 'O'
                            ( SELECT MAX ( xlatlongname )
                                FROM msafi.psxlatitem
                               WHERE fieldname = 'INOUT_FLG_PBL'
                                 AND fieldvalue = nfh.inout_flg_pbl )
                                desc_inout_flg_pbl
                          , --
                            nfh.nf_brl_type
                          , ( SELECT MAX ( descr )
                                FROM msafi.ps_nf_type_brl
                               WHERE nf_brl_type = nfh.nf_brl_type )
                                desc_nf_brl_type
                          , --
                            nfh.nf_status_bbl
                          , -- ('CNFM', 'CNCL', 'PRNT', 'INTL', 'DNGD')
                            ( SELECT MAX ( xlatlongname )
                                FROM msafi.psxlatitem
                               WHERE fieldname = 'NF_STATUS_BBL'
                                 AND fieldvalue = nfh.nf_status_bbl )
                                desc_nf_status_bbl
                          , --
                            nfh.lt_grp_id_bbl
                          , ( SELECT MAX ( lgb.descr ) descricao
                                FROM msafi.ps_lt_grp_bbl lgb
                               WHERE nfh.lt_grp_id_bbl = lgb.lt_grp_id_bbl )
                                desc_lt_grp_id_bbl
                          , nfh.entered_dt
                          , nfh.nf_conf_dt_bbl
                          , nfh.nf_issue_dt_bbl
                          , nfh.nfee_key_bbl
                          , nfh.vendor_setid
                          , nfh.vendor_id
                          , nfh.address_seq_num
                          , nfh.delivered_dt
                          , ( SELECT MAX ( nfl.tof_pbl )
                                FROM msafi.ps_nf_ln_bbl_fs nfl
                               WHERE 1 = 1
                                 AND nfl.business_unit = nfh.business_unit
                                 AND nfl.nf_brl_id = nfh.nf_brl_id
                                 AND nfl.purch_prop_brl <> 'SER' )
                                maior_tof_pbl
                          ,    --Observaçãos de Erros------------------
                                ( CASE
                                     WHEN nfh.nf_status_bbl NOT IN ( 'CNFM'
                                                                   , 'CNCL'
                                                                   , 'PRNT'
                                                                   , 'INTL'
                                                                   , 'DNGD' ) THEN
                                         'Aguardando autorização da SEFAZ; '
                                 END )
                            || --
                              DECODE ( TO_CHAR ( TRIM ( nfh.ef_loc_brl ) ), NULL, 'EF_LOC_BRL em Branco ou Nulo; ' )
                            || --
                              DECODE ( TO_CHAR ( TRIM ( nfh.nf_brl ) ), NULL, 'NF_BRL em Branco ou Nulo; ' )
                            || --
                              DECODE ( TO_CHAR ( TRIM ( nfh.nf_brl_id ) ), NULL, 'NF_BRL_ID em Branco ou Nulo; ' )
                            || --
                              DECODE ( TO_CHAR ( TRIM ( nfh.nfee_key_bbl ) )
                                     , NULL, 'NFEE_KEY_BBL em Branco ou Nulo; ' )
                            || --
                              ''
                                AS observacao
                          ,    'EXEC MSAFI.PRC_MSAF_PS_NF_SAIDA('
                            || --
                              'P_COD_EMPRESA =>'''
                            || mcod_empresa
                            || ''''
                            || --
                              ',P_COD_ESTAB =>'''
                            || estab.cod_estab
                            || ''''
                            || --
                              ',P_NF_BRL_ID =>'''
                            || LPAD ( TRIM ( nfh.nf_brl_id )
                                    , 10
                                    , '0' )
                            || ''' '
                            || --
                               --' ,P_CARGA_SAFX07 => 1' || -- Por Default serão trazidas.
                               --' ,P_CARGA_SAFX08 => 1' || --
                               --' ,P_CARGA_SAFX112 => 1' || --
                               --' ,P_CARGA_SAFX116 => 1' || --
                               --' ,P_CARGA_SAFX117 => 1' || --
                               ',P_CARGA_SAFX119 =>''1'''
                            || --
                               --',P_VIRA_USO_CONSUMO => 1' || --
                               --',P_VIRA_CAGADAS => 0' || --
                               --',P_VIRA_IGNORA_PS => 0' || --
                               ',P_INSERE_AUDIT => ''0'''
                            || --
                              ');'
                            || --
                              ''
                                AS recarregar
                       ----------------------------------------
                       FROM msafi.ps_nf_hdr_bbl_fs nfh
                          , msafi.dsp_estabelecimento estab
                          , msafi.dpsp_conc_nf_falt_ps_chave filtro
                      WHERE 1 = 1
                        AND nfh.ef_loc_brl = estab.location
                        --     AND ESTAB.COD_ESTAB =
                        --         DECODE(P_COD_ESTAB, '%', ESTAB.COD_ESTAB, P_COD_ESTAB)
                        --     AND NFH.ACCOUNTING_DT = P_PERIODO
                        AND filtro.ef_loc_brl = nfh.ef_loc_brl
                        AND filtro.nf_brl = nfh.nf_brl
                        AND filtro.nf_brl_id = nfh.nf_brl_id
                        AND filtro.nf_brl_series = nfh.nf_brl_series ) LOOP
                -- INSERIR NA TABELA DE SCRIPTS PARA CARREGAR QUANDO A FLAG ESTIVER SELECIONADO E NÃO EXISTIR
                -- OBSERVAÇÕES SOBRE A NOTA
                IF p_carregar = 'S'
               AND c.observacao IS NULL THEN
                    INSERT INTO msafi.dpsp_conc_nf_falt_ps_script ( cod_empresa
                                                                  , cod_estab
                                                                  , data_periodo
                                                                  , nf_brl
                                                                  , nf_brl_id
                                                                  , script
                                                                  , proc_id
                                                                  , data_execucao
                                                                  , usr_login )
                         VALUES ( c.cod_empresa
                                , c.cod_estab
                                , p_periodo
                                , c.nf_brl
                                , c.nf_brl_id
                                , TRIM ( REPLACE ( c.recarregar
                                                 , 'EXEC '
                                                 , '' ) )
                                , mproc_id
                                , v_data_exec
                                , mcod_usuario );

                    COMMIT;
                END IF;

                IF v_class = 'A' THEN
                    v_class := 'B';
                ELSE
                    v_class := 'A';
                END IF;

                v_text01 :=
                    dsp_planilha.linha (
                                         p_conteudo =>    dsp_planilha.campo ( dsp_planilha.texto ( c.observacao ) )
                                                       || --
                                                         dsp_planilha.campo ( dsp_planilha.texto ( c.cod_empresa ) )
                                                       || --
                                                         dsp_planilha.campo ( dsp_planilha.texto ( c.cod_estab ) )
                                                       || --
                                                         dsp_planilha.campo ( dsp_planilha.texto (
                                                                                                   TO_CHAR (
                                                                                                             c.accounting_dt
                                                                                                           , 'DD/MM/YYYY'
                                                                                                   )
                                                                              ) )
                                                       || --
                                                         dsp_planilha.campo ( dsp_planilha.texto ( c.nf_brl ) )
                                                       || --
                                                         dsp_planilha.campo ( dsp_planilha.texto ( c.nf_brl_series ) )
                                                       || --
                                                         dsp_planilha.campo ( dsp_planilha.texto ( c.nf_brl_id ) )
                                                       || --
                                                         dsp_planilha.campo ( dsp_planilha.texto ( c.nf_brl_status ) )
                                                       || --
                                                         dsp_planilha.campo (
                                                                              dsp_planilha.texto (
                                                                                                   c.desc_nf_brl_status
                                                                              )
                                                          )
                                                       || --
                                                         dsp_planilha.campo ( dsp_planilha.texto ( c.inout_flg_pbl ) )
                                                       || --
                                                         dsp_planilha.campo (
                                                                              dsp_planilha.texto (
                                                                                                   c.desc_inout_flg_pbl
                                                                              )
                                                          )
                                                       || --
                                                         dsp_planilha.campo ( dsp_planilha.texto ( c.nf_brl_type ) )
                                                       || --
                                                         dsp_planilha.campo (
                                                                              dsp_planilha.texto (
                                                                                                   c.desc_nf_brl_type
                                                                              )
                                                          )
                                                       || --
                                                         dsp_planilha.campo ( dsp_planilha.texto ( c.nf_status_bbl ) )
                                                       || --
                                                         dsp_planilha.campo (
                                                                              dsp_planilha.texto (
                                                                                                   c.desc_nf_status_bbl
                                                                              )
                                                          )
                                                       || --*/
                                                         dsp_planilha.campo ( dsp_planilha.texto (
                                                                                                   TO_CHAR (
                                                                                                             c.entered_dt
                                                                                                           , 'DD/MM/YYYY'
                                                                                                   )
                                                                              ) )
                                                       || --
                                                         dsp_planilha.campo ( dsp_planilha.texto (
                                                                                                   TO_CHAR (
                                                                                                             c.nf_conf_dt_bbl
                                                                                                           , 'DD/MM/YYYY'
                                                                                                   )
                                                                              ) )
                                                       || --
                                                         dsp_planilha.campo ( dsp_planilha.texto (
                                                                                                   TO_CHAR (
                                                                                                             c.nf_issue_dt_bbl
                                                                                                           , 'DD/MM/YYYY'
                                                                                                   )
                                                                              ) )
                                                       || --
                                                         dsp_planilha.campo ( dsp_planilha.texto (
                                                                                                   TO_CHAR (
                                                                                                             c.last_update_dt
                                                                                                           , 'DD/MM/YYYY'
                                                                                                   )
                                                                              ) )
                                                       || --
                                                         dsp_planilha.campo ( dsp_planilha.texto ( c.nfee_key_bbl ) )
                                                       || --
                                                         dsp_planilha.campo ( dsp_planilha.texto ( c.vendor_id ) )
                                                       || --
                                                         dsp_planilha.campo ( dsp_planilha.texto ( c.ef_loc_brl ) )
                                                       || --
                                                         dsp_planilha.campo ( dsp_planilha.texto ( c.lt_grp_id_bbl ) )
                                                       || --
                                                         dsp_planilha.campo (
                                                                              dsp_planilha.texto (
                                                                                                   c.desc_lt_grp_id_bbl
                                                                              )
                                                          )
                                                       || --
                                                         dsp_planilha.campo ( dsp_planilha.texto ( c.vendor_setid ) )
                                                       || ---
                                                         dsp_planilha.campo (
                                                                              dsp_planilha.texto ( c.address_seq_num )
                                                          )
                                                       || ---
                                                         dsp_planilha.campo ( dsp_planilha.texto ( c.delivered_dt ) )
                                                       || --
                                                         dsp_planilha.campo ( dsp_planilha.texto ( c.maior_tof_pbl ) )
                                                       || --
                                                         dsp_planilha.campo ( dsp_planilha.texto ( c.recarregar ) )
                                                       || --
                                                         ''
                                       , p_class => v_class
                    );
                lib_proc.add ( v_text01
                             , ptipo => 98 );

                COMMIT;
            END LOOP;
        END IF;

        IF p_movto_e_s IN ( 1
                          , 2 ) THEN
            --=========================================================
            loga ( '>> ENTRADAS DIF'
                 , TRUE );
            --=========================================================
            v_step := 'E';

            dbms_application_info.set_module ( $$plsql_unit
                                             , mproc_id || ' ENT LJ:' || p_cod_estab );

            EXECUTE IMMEDIATE 'TRUNCATE TABLE MSAFI.DPSP_CONC_NF_FALT_PS_CHAVE';

            v_script := '';
            v_script := v_script || ' DECLARE ';
            v_script := v_script || ' BEGIN ';
            --
            v_script := v_script || ' FOR DIF IN (SELECT * ';
            v_script := v_script || ' FROM MSAFI.DPSP_CONC_NF_FALT_PS_ENT_GTT GTT ';
            v_script := v_script || ' WHERE 1 = 1 ';
            v_script :=
                   v_script
                || ' AND GTT.COD_ESTAB = DECODE('''
                || p_cod_estab
                || ''', ''%'', GTT.COD_ESTAB, '''
                || p_cod_estab
                || ''') ';
            v_script := v_script || ' AND GTT.ACCOUNTING_DT =  ''' || p_periodo || ''' ';
            v_script := v_script || ' AND NOT EXISTS ';
            v_script := v_script || ' (SELECT 1 ';
            v_script := v_script || ' FROM MSAF.X07_DOCTO_FISCAL ';
            v_script := v_script || ' PARTITION FOR(TO_DATE(''' || v_dt_first || ''',''YYYYMMDD''))  ';
            v_script := v_script || ' X07 ';
            v_script := v_script || ' WHERE 1 = 1 ';
            v_script := v_script || ' AND X07.COD_EMPRESA = ''' || mcod_empresa || ''' ';
            v_script := v_script || ' AND X07.NUM_DOCFIS = GTT.NF_BRL ';
            v_script := v_script || ' AND REPLACE(X07.NUM_CONTROLE_DOCTO, ''C-'', '''') = ';
            v_script := v_script || ' GTT.NF_BRL_ID ';
            v_script := v_script || ' AND X07.DATA_FISCAL = GTT.ACCOUNTING_DT ';
            v_script := v_script || ' AND X07.COD_ESTAB = GTT.COD_ESTAB ';
            v_script := v_script || ' AND X07.SERIE_DOCFIS = GTT.NF_BRL_SERIES)) ';
            v_script := v_script || ' LOOP ';
            --
            v_script := v_script || ' INSERT INTO MSAFI.DPSP_CONC_NF_FALT_PS_CHAVE ';
            v_script := v_script || ' (COD_ESTAB, ';
            v_script := v_script || ' EF_LOC_BRL, ';
            v_script := v_script || ' NF_BRL, ';
            v_script := v_script || ' NF_BRL_ID, ';
            v_script := v_script || ' NF_BRL_SERIES, ';
            v_script := v_script || ' ACCOUNTING_DT) ';
            v_script := v_script || ' VALUES ';
            v_script := v_script || ' (DIF.COD_ESTAB, ';
            v_script := v_script || ' DIF.EF_LOC_BRL, ';
            v_script := v_script || ' DIF.NF_BRL, ';
            v_script := v_script || ' DIF.NF_BRL_ID, ';
            v_script := v_script || ' DIF.NF_BRL_SERIES, ';
            v_script := v_script || ' DIF.ACCOUNTING_DT); ';
            --
            v_script := v_script || ' COMMIT; ';
            v_script := v_script || ' END LOOP; ';
            v_script := v_script || ' END; ';

            BEGIN
                EXECUTE IMMEDIATE v_script;

                COMMIT;
            EXCEPTION
                WHEN OTHERS THEN
                    raise_application_error ( -20001
                                            , SQLERRM || '>>' || v_script );
            END;

            SELECT COUNT ( 1 )
              INTO v_count
              FROM msafi.dpsp_conc_nf_falt_ps_chave;

            loga ( 'Qtd tabela: ' || v_count
                 , FALSE );

            --=========================================================
            loga ( '>> ENTRADA RECUPERA DADOS '
                 , FALSE );
            --=========================================================
            v_step := 'F';

            FOR c
                IN ( SELECT /*+ DRIVING_SITE(NFH) */
                            --
                           mcod_empresa AS cod_empresa
                          , estab.cod_estab
                          , nfh.nf_brl
                          , --
                           nfh.nf_brl_id
                          , nfh.accounting_dt
                          , --
                           nfh.last_update_dt
                          , nfh.ef_loc_brl
                          , --
                           nfh.nf_brl_series
                          , --
                            --
                            nfh.nf_brl_status
                          , -- 'F'
                            ( SELECT MAX ( xlatlongname )
                                FROM msafi.psxlatitem
                               WHERE fieldname = 'NF_BRL_STATUS'
                                 AND fieldvalue = nfh.nf_brl_status )
                                AS desc_nf_brl_status
                          , --
                            nfh.inout_flg_pbl
                          , --= 'O'
                            ( SELECT MAX ( xlatlongname )
                                FROM msafi.psxlatitem
                               WHERE fieldname = 'INOUT_FLG_PBL'
                                 AND fieldvalue = nfh.inout_flg_pbl )
                                AS desc_inout_flg_pbl
                          , --
                            nfh.nf_brl_type
                          , ( SELECT MAX ( descr )
                                FROM msafi.ps_nf_type_brl
                               WHERE nf_brl_type = nfh.nf_brl_type )
                                AS desc_nf_brl_type
                          , --
                            nfh.nf_status_bbl
                          , -- ('CNFM', 'CNCL', 'PRNT', 'INTL', 'DNGD')
                            ( SELECT MAX ( xlatlongname )
                                FROM msafi.psxlatitem
                               WHERE fieldname = 'NF_STATUS_BBL'
                                 AND fieldvalue = nfh.nf_status_bbl )
                                AS desc_nf_status_bbl
                          , --
                            nfh.lt_grp_id_bbl
                          , ( SELECT MAX ( lgb.descr ) AS descricao
                                FROM msafi.ps_lt_grp_bbl lgb
                               WHERE nfh.lt_grp_id_bbl = lgb.lt_grp_id_bbl )
                                AS desc_lt_grp_id_bbl
                          , nfh.entered_dt
                          , nfh.nf_conf_dt_bbl
                          , nfh.nf_issue_dt_bbl
                          , TRIM ( nfh.nfe_verif_code_pbl ) AS nfee_key_bbl
                          , nfh.vendor_setid
                          , nfh.vendor_id
                          , nfh.address_seq_num
                          , nfh.delivered_dt
                          , ( SELECT MAX ( nfl.tof_pbl )
                                FROM msafi.ps_nf_ln_bbl_fs nfl
                               WHERE 1 = 1
                                 AND nfl.business_unit = nfh.business_unit
                                 AND nfl.nf_brl_id = nfh.nf_brl_id
                                 AND nfl.purch_prop_brl <> 'SER' )
                                maior_tof_pbl
                          ,    --Observaçãos de Erros------------------
                                ( CASE
                                     WHEN TRIM ( nfh.nf_brl_status ) <> 'F' THEN 'NF_BRL_STATUS diferente de ''F''; '
                                 END )
                            || --
                               ( CASE
                                    WHEN TRIM ( nfh.inout_flg_pbl ) <> 'I' THEN 'INOUT_FLG_PBL diferente de ''I''; '
                                END )
                            || --
                              DECODE ( TO_CHAR ( TRIM ( nfh.ef_loc_brl ) ), NULL, 'EF_LOC_BRL em Branco ou Nulo; ' )
                            || --
                              DECODE ( TO_CHAR ( TRIM ( nfh.nf_brl ) ), NULL, 'NF_BRL em Branco ou Nulo; ' )
                            || --
                              DECODE ( TO_CHAR ( TRIM ( nfh.nf_brl_id ) ), NULL, 'NF_BRL_ID em Branco ou Nulo; ' )
                            || --
                              DECODE ( TO_CHAR ( TRIM ( nfh.nfe_verif_code_pbl ) )
                                     , NULL, 'NFEE_KEY_BBL em Branco ou Nulo; ' )
                            || --
                              ''
                                AS observacao
                          ,    'EXEC MSAFI.PRC_MSAF_PS_NF_ENTRADA ('
                            || --
                              ' P_DATAINI => '''
                            || v_dt_first
                            || ''''
                            || --
                              ' ,P_DATAFIM => '''
                            || LAST_DAY ( v_dt_first )
                            || ''''
                            || --
                              ' ,P_COD_EMPRESA=> '''
                            || mcod_empresa
                            || ''''
                            || --
                              ' ,P_COD_ESTAB=>'''
                            || estab.cod_estab
                            || ''''
                            || --
                              ' ,P_NF_BRL_ID=> '''
                            || nfh.nf_brl_id
                            || ''''
                            || --
                              ');'
                            || --
                              ''
                                AS recarregar
                       ----------------------------------------
                       FROM msafi.ps_nf_hdr_brl nfh
                          , msafi.dsp_estabelecimento estab
                          , msafi.dpsp_conc_nf_falt_ps_chave filtro
                      WHERE 1 = 1
                        AND nfh.ef_loc_brl = estab.location
                        --     AND ESTAB.COD_ESTAB =
                        --         DECODE(P_COD_ESTAB, '%', ESTAB.COD_ESTAB, P_COD_ESTAB)
                        --     AND NFH.ACCOUNTING_DT = P_PERIODO
                        --  BETWEEN VD_DATA_INICIAL AND
                        --         VD_DATA_FINAL
                        AND filtro.ef_loc_brl = nfh.ef_loc_brl
                        AND filtro.nf_brl = nfh.nf_brl
                        AND filtro.nf_brl_id = nfh.nf_brl_id
                        AND filtro.nf_brl_series = nfh.nf_brl_series ) LOOP
                -- INSERIR NA TABELA DE SCRIPTS PARA CARREGAR QUANDO A FLAG ESTIVER SELECIONADO E NÃO EXISTIR
                -- OBSERVAÇÕES SOBRE A NOTA
                IF p_carregar = 'S'
               AND c.observacao IS NULL THEN
                    INSERT INTO msafi.dpsp_conc_nf_falt_ps_script ( cod_empresa
                                                                  , cod_estab
                                                                  , data_periodo
                                                                  , nf_brl
                                                                  , nf_brl_id
                                                                  , script
                                                                  , proc_id
                                                                  , data_execucao
                                                                  , usr_login )
                         VALUES ( c.cod_empresa
                                , c.cod_estab
                                , p_periodo
                                , c.nf_brl
                                , c.nf_brl_id
                                , TRIM ( REPLACE ( c.recarregar
                                                 , 'EXEC '
                                                 , '' ) )
                                , mproc_id
                                , v_data_exec
                                , mcod_usuario );

                    COMMIT;
                END IF;

                IF v_class = 'A' THEN
                    v_class := 'B';
                ELSE
                    v_class := 'A';
                END IF;

                v_text01 :=
                    dsp_planilha.linha (
                                         p_conteudo =>    dsp_planilha.campo ( dsp_planilha.texto ( c.observacao ) )
                                                       || --
                                                         dsp_planilha.campo ( dsp_planilha.texto ( c.cod_empresa ) )
                                                       || --
                                                         dsp_planilha.campo ( dsp_planilha.texto ( c.cod_estab ) )
                                                       || --
                                                         dsp_planilha.campo ( dsp_planilha.texto (
                                                                                                   TO_CHAR (
                                                                                                             c.accounting_dt
                                                                                                           , 'DD/MM/YYYY'
                                                                                                   )
                                                                              ) )
                                                       || --
                                                         dsp_planilha.campo ( dsp_planilha.texto ( c.nf_brl ) )
                                                       || --
                                                         dsp_planilha.campo ( dsp_planilha.texto ( c.nf_brl_series ) )
                                                       || --
                                                         dsp_planilha.campo ( dsp_planilha.texto ( c.nf_brl_id ) )
                                                       || --
                                                         dsp_planilha.campo ( dsp_planilha.texto ( c.nf_brl_status ) )
                                                       || --
                                                         dsp_planilha.campo (
                                                                              dsp_planilha.texto (
                                                                                                   c.desc_nf_brl_status
                                                                              )
                                                          )
                                                       || --
                                                         dsp_planilha.campo ( dsp_planilha.texto ( c.inout_flg_pbl ) )
                                                       || --
                                                         dsp_planilha.campo (
                                                                              dsp_planilha.texto (
                                                                                                   c.desc_inout_flg_pbl
                                                                              )
                                                          )
                                                       || --
                                                         dsp_planilha.campo ( dsp_planilha.texto ( c.nf_brl_type ) )
                                                       || --
                                                         dsp_planilha.campo (
                                                                              dsp_planilha.texto (
                                                                                                   c.desc_nf_brl_type
                                                                              )
                                                          )
                                                       || --
                                                         dsp_planilha.campo ( dsp_planilha.texto ( c.nf_status_bbl ) )
                                                       || --
                                                         dsp_planilha.campo (
                                                                              dsp_planilha.texto (
                                                                                                   c.desc_nf_status_bbl
                                                                              )
                                                          )
                                                       || --*/
                                                         dsp_planilha.campo ( dsp_planilha.texto (
                                                                                                   TO_CHAR (
                                                                                                             c.entered_dt
                                                                                                           , 'DD/MM/YYYY'
                                                                                                   )
                                                                              ) )
                                                       || --
                                                         dsp_planilha.campo ( dsp_planilha.texto (
                                                                                                   TO_CHAR (
                                                                                                             c.nf_conf_dt_bbl
                                                                                                           , 'DD/MM/YYYY'
                                                                                                   )
                                                                              ) )
                                                       || --
                                                         dsp_planilha.campo ( dsp_planilha.texto (
                                                                                                   TO_CHAR (
                                                                                                             c.nf_issue_dt_bbl
                                                                                                           , 'DD/MM/YYYY'
                                                                                                   )
                                                                              ) )
                                                       || --
                                                         dsp_planilha.campo ( dsp_planilha.texto (
                                                                                                   TO_CHAR (
                                                                                                             c.last_update_dt
                                                                                                           , 'DD/MM/YYYY'
                                                                                                   )
                                                                              ) )
                                                       || --
                                                         dsp_planilha.campo ( dsp_planilha.texto ( c.nfee_key_bbl ) )
                                                       || --
                                                         dsp_planilha.campo ( dsp_planilha.texto ( c.vendor_id ) )
                                                       || --
                                                         dsp_planilha.campo ( dsp_planilha.texto ( c.ef_loc_brl ) )
                                                       || --
                                                         dsp_planilha.campo ( dsp_planilha.texto ( c.lt_grp_id_bbl ) )
                                                       || --
                                                         dsp_planilha.campo (
                                                                              dsp_planilha.texto (
                                                                                                   c.desc_lt_grp_id_bbl
                                                                              )
                                                          )
                                                       || --
                                                         dsp_planilha.campo ( dsp_planilha.texto ( c.vendor_setid ) )
                                                       || ---
                                                         dsp_planilha.campo (
                                                                              dsp_planilha.texto ( c.address_seq_num )
                                                          )
                                                       || ---
                                                         dsp_planilha.campo ( dsp_planilha.texto ( c.delivered_dt ) )
                                                       || --
                                                         dsp_planilha.campo ( dsp_planilha.texto ( c.maior_tof_pbl ) )
                                                       || --
                                                         dsp_planilha.campo ( dsp_planilha.texto ( c.recarregar ) )
                                                       || --
                                                         ''
                                       , p_class => v_class
                    );
                lib_proc.add ( v_text01
                             , ptipo => 98 );

                COMMIT;
            END LOOP;
        END IF;

        --=========================================================
        loga ( '[FIM LOAD_EXCEL_PS]'
             , TRUE );
    --=========================================================

    END load_excel_ps;

    PROCEDURE load_excel_ms ( p_periodo DATE
                            , v_dt_first DATE
                            , p_movto_e_s VARCHAR2
                            , p_cod_estab VARCHAR2 )
    IS
        v_text01 VARCHAR2 ( 10000 );
        v_script VARCHAR2 ( 10000 ) := '';
        v_count NUMBER := 0;
    BEGIN
        --=========================================================
        loga ( '[INICIAR LOAD_EXCEL_MS]'
             , TRUE );

        --=========================================================

        --=========================================================
        IF p_movto_e_s IN ( 1
                          , 3 ) THEN
            --=========================================================

            --=========================================================
            loga ( '>> SAIDA'
                 , TRUE );
            --=========================================================
            v_step := 'G';

            dbms_application_info.set_module ( $$plsql_unit
                                             , mproc_id || ' SAI LJ:' || p_cod_estab );

            EXECUTE IMMEDIATE 'TRUNCATE TABLE MSAFI.DPSP_CONC_NF_MS_FALT_PS_CHAVE';

            v_script := '';
            v_script := v_script || ' DECLARE ';
            v_script := v_script || ' BEGIN ';
            v_script := v_script || ' FOR DIF IN (SELECT X07.ROWID V_ROWID ';
            v_script := v_script || ' FROM MSAF.X07_DOCTO_FISCAL ';
            v_script := v_script || ' PARTITION FOR(TO_DATE(''' || v_dt_first || ''',''YYYYMMDD''))  ';
            v_script := v_script || ' X07 ';
            v_script := v_script || ' WHERE 1 = 1 ';
            v_script := v_script || ' AND X07.COD_EMPRESA = ''' || mcod_empresa || ''' ';
            v_script := v_script || ' AND X07.COD_ESTAB = ';
            v_script :=
                v_script || ' DECODE(''' || p_cod_estab || ''', ''%'', X07.COD_ESTAB, ''' || p_cod_estab || ''') ';
            v_script := v_script || ' AND X07.DATA_FISCAL = ''' || p_periodo || ''' ';
            v_script := v_script || ' AND X07.MOVTO_E_S = ''9'' ';
            v_script := v_script || ' AND X07.COD_SISTEMA_ORIG IN (''PS-E'', ''PS-S'') ';
            v_script := v_script || ' AND NOT EXISTS ';
            v_script := v_script || ' (SELECT 1 ';
            v_script := v_script || ' FROM MSAFI.DPSP_CONC_NF_FALT_PS_SAI_GTT NFH ';
            v_script := v_script || ' WHERE 1 = 1 ';
            v_script := v_script || ' AND X07.NUM_DOCFIS = NFH.NF_BRL ';
            v_script := v_script || ' AND X07.NUM_CONTROLE_DOCTO = ';
            v_script := v_script || ' LPAD(NFH.NF_BRL_ID, 10, ''0'') ';
            v_script := v_script || ' AND X07.DATA_FISCAL = ';
            v_script := v_script || ' TO_DATE((CASE WHEN ';
            v_script := v_script || ' NFH.LT_GRP_ID_BBL IN ';
            v_script := v_script || ' (''TRO_LIB_23'', ''TRO_DIA_23'') THEN ';
            v_script := v_script || ' TO_CHAR(NFH.ENTERED_DT, ''YYYYMMDD'') WHEN ';
            v_script := v_script || ' NFH.LT_GRP_ID_BBL IN ';
            v_script := v_script || ' (''EST_LIB_14'', ''EST_LIB_4'', ';
            v_script := v_script || ' ''EST_DIA_23'', ''EST_DIA_2'', ';
            v_script := v_script || ' ''EST_LIB_23'', ''EST_LIB_3'') THEN ';
            v_script := v_script || ' TO_CHAR(NVL(NFH.NF_CONF_DT_BBL, ';
            v_script := v_script || ' NFH.NF_ISSUE_DT_BBL), ';
            v_script := v_script || ' ''YYYYMMDD'') ELSE ';
            v_script := v_script || ' TO_CHAR(NFH.NF_ISSUE_DT_BBL, ';
            v_script := v_script || ' ''YYYYMMDD'') END), ';
            v_script := v_script || ' ''YYYYMMDD'') ';
            v_script := v_script || ' AND X07.COD_ESTAB = NFH.COD_ESTAB ';
            v_script := v_script || ' AND NVL(X07.SERIE_DOCFIS, ''@'') = ';
            v_script := v_script || ' NVL(NFH.NF_BRL_SERIES, ''@''))) LOOP ';
            v_script := v_script || '  ';
            v_script := v_script || ' INSERT INTO MSAFI.DPSP_CONC_NF_MS_FALT_PS_CHAVE ';
            v_script := v_script || ' (COD_ROWID) ';
            v_script := v_script || ' VALUES ';
            v_script := v_script || ' (DIF.V_ROWID); ';
            --
            v_script := v_script || ' COMMIT; ';
            v_script := v_script || ' END LOOP; ';
            v_script := v_script || ' END; ';

            BEGIN
                EXECUTE IMMEDIATE v_script;

                COMMIT;
            EXCEPTION
                WHEN OTHERS THEN
                    raise_application_error ( -20001
                                            , SQLERRM || '>>' || v_script );
            END;

            SELECT COUNT ( 1 )
              INTO v_count
              FROM msafi.dpsp_conc_nf_ms_falt_ps_chave;

            loga ( 'Qtd tabela: ' || v_count
                 , FALSE );

            --=========================================================
            loga ( '>> SAIDA DIF '
                 , TRUE );
            --=========================================================
            v_step := 'H';

            v_script := '';
            v_script := v_script || ' DECLARE ';
            v_script := v_script || ' BEGIN ';
            v_script := v_script || '  ';
            v_script := v_script || ' FOR DIF IN (SELECT X07.ROWID V_ROWID ';
            --
            v_script := v_script || ' FROM MSAF.X07_DOCTO_FISCAL ';
            v_script := v_script || ' PARTITION FOR(TO_DATE(''' || v_dt_first || ''',''YYYYMMDD''))  ';
            v_script := v_script || ' X07 ';
            v_script := v_script || ' WHERE 1 = 1 ';
            v_script := v_script || ' AND X07.COD_EMPRESA = ''' || mcod_empresa || ''' ';
            v_script := v_script || ' AND X07.COD_ESTAB = ';
            v_script :=
                v_script || ' DECODE(''' || p_cod_estab || ''', ''%'', X07.COD_ESTAB, ''' || p_cod_estab || ''') ';
            v_script := v_script || ' AND X07.DATA_FISCAL = ''' || p_periodo || ''' ';
            v_script := v_script || ' AND X07.MOVTO_E_S <> ''9'' ';
            v_script := v_script || ' AND X07.NORM_DEV = 2 ';
            v_script := v_script || ' AND X07.COD_SISTEMA_ORIG IN (''PS-E'', ''PS-S'') ';
            v_script := v_script || '  ';

            --=========================================================
            -- OBS: Este Not Exits não utiliza a GTT de Entrada quando o P_MOVTO_E_S for diferente de 1
            -- pois é necessário consultar todas as Notas de Entrada independente do campo INOUT_FLG_PBL (E/S)
            --=========================================================
            IF p_movto_e_s = 1 THEN
                v_script := v_script || ' AND NOT EXISTS ';
                v_script := v_script || ' (SELECT ';
                v_script := v_script || ' 1 ';
                v_script := v_script || ' FROM MSAFI.DPSP_CONC_NF_FALT_PS_ENT_GTT ENT_GTT ';
                v_script := v_script || ' WHERE 1 = 1 ';
                v_script := v_script || ' AND X07.NUM_DOCFIS = ENT_GTT.NF_BRL ';
                v_script := v_script || ' AND X07.NUM_CONTROLE_DOCTO = ENT_GTT.NF_BRL_ID ';
                v_script := v_script || ' AND X07.DATA_FISCAL = ENT_GTT.ACCOUNTING_DT ';
                v_script := v_script || ' AND X07.COD_ESTAB = ENT_GTT.COD_ESTAB ';
                v_script := v_script || ' AND X07.SERIE_DOCFIS = ENT_GTT.NF_BRL_SERIES) ';
            ELSE
                v_script := v_script || ' AND NOT EXISTS ';
                v_script := v_script || ' (SELECT /*+ DRIVING_SITE(NFH) */ ';
                v_script := v_script || ' 1 ';
                v_script := v_script || ' FROM MSAFI.PS_NF_HDR_BRL       NFH, ';
                v_script := v_script || ' MSAFI.DSP_ESTABELECIMENTO ESTAB ';
                v_script := v_script || ' WHERE 1 = 1 ';
                v_script := v_script || ' AND NFH.NF_BRL_TYPE NOT IN (''GNR'', ''GUI'') ';
                v_script := v_script || ' AND NFH.NF_BRL_SERIES <> ''GAR'' ';
                v_script := v_script || ' AND NFH.EF_LOC_BRL = ESTAB.LOCATION ';
                v_script := v_script || ' AND X07.NUM_DOCFIS = NFH.NF_BRL ';

                v_script := v_script || ' AND X07.NUM_CONTROLE_DOCTO = NFH.NF_BRL_ID ';
                v_script := v_script || ' AND X07.DATA_FISCAL = NFH.ACCOUNTING_DT ';
                v_script := v_script || ' AND X07.COD_ESTAB = ESTAB.COD_ESTAB ';
                v_script := v_script || ' AND X07.SERIE_DOCFIS = NFH.NF_BRL_SERIES) ';
            END IF;

            --=========================================================
            --- Verificar se não existe a nota de Saída no PeopleSoft
            --=========================================================
            v_script := v_script || ' AND NOT EXISTS ';
            v_script := v_script || ' (SELECT 1 ';
            v_script := v_script || ' FROM MSAFI.DPSP_CONC_NF_FALT_PS_SAI_GTT SAI_GTT ';
            v_script := v_script || ' WHERE 1 = 1 ';
            v_script := v_script || ' AND X07.NUM_DOCFIS = SAI_GTT.NF_BRL ';
            v_script := v_script || ' AND X07.NUM_CONTROLE_DOCTO = ';
            v_script := v_script || ' LPAD(SAI_GTT.NF_BRL_ID, 10, ''0'') ';
            v_script := v_script || ' AND X07.DATA_FISCAL = ';
            v_script := v_script || ' TO_DATE((CASE WHEN ';
            v_script := v_script || ' SAI_GTT.LT_GRP_ID_BBL IN ';
            v_script := v_script || ' (''TRO_LIB_23'', ''TRO_DIA_23'') THEN ';
            v_script := v_script || ' TO_CHAR(SAI_GTT.ENTERED_DT, ''YYYYMMDD'') WHEN ';
            v_script := v_script || ' SAI_GTT.LT_GRP_ID_BBL IN ';
            v_script := v_script || ' (''EST_LIB_14'', ''EST_LIB_4'', ';
            v_script := v_script || ' ''EST_DIA_23'', ''EST_DIA_2'', ';
            v_script := v_script || ' ''EST_LIB_23'', ''EST_LIB_3'') THEN ';
            v_script := v_script || ' TO_CHAR(NVL(SAI_GTT.NF_CONF_DT_BBL, ';
            v_script := v_script || ' SAI_GTT.NF_ISSUE_DT_BBL), ';
            v_script := v_script || ' ''YYYYMMDD'') ELSE ';
            v_script := v_script || ' TO_CHAR(SAI_GTT.NF_ISSUE_DT_BBL, ';
            v_script := v_script || ' ''YYYYMMDD'') END), ';
            v_script := v_script || ' ''YYYYMMDD'') ';
            v_script := v_script || ' AND X07.COD_ESTAB = SAI_GTT.COD_ESTAB ';
            v_script := v_script || ' AND NVL(X07.SERIE_DOCFIS, ''@'') = ';
            v_script := v_script || ' NVL(SAI_GTT.NF_BRL_SERIES, ''@'')) ';
            --=========================================================
            --=========================================================
            v_script := v_script || ' ) LOOP ';
            v_script := v_script || ' INSERT INTO MSAFI.DPSP_CONC_NF_MS_FALT_PS_CHAVE ';
            v_script := v_script || ' (COD_ROWID) ';
            v_script := v_script || ' VALUES ';
            v_script := v_script || ' (DIF.V_ROWID); ';
            v_script := v_script || '  ';
            --
            v_script := v_script || ' COMMIT; ';
            v_script := v_script || ' END LOOP; ';
            v_script := v_script || ' END; ';

            BEGIN
                EXECUTE IMMEDIATE v_script;

                COMMIT;
            EXCEPTION
                WHEN OTHERS THEN
                    raise_application_error ( -20001
                                            , SQLERRM || '>>' || v_script );
            END;

            SELECT COUNT ( 1 )
              INTO v_count
              FROM msafi.dpsp_conc_nf_ms_falt_ps_chave;

            loga ( 'Qtd tabela: ' || v_count
                 , FALSE );

            --=========================================================
            loga ( '>> SAIDA RECUPERA DADOS'
                 , FALSE );
            --=========================================================
            v_step := 'I';

            FOR c IN ( SELECT x07.cod_empresa
                            , x07.cod_estab
                            , x07.data_fiscal
                            , x07.data_emissao
                            , x07.movto_e_s
                            , x07.num_docfis
                            , x07.num_controle_docto
                            , x07.serie_docfis
                            , x07.sub_serie_docfis
                            , x07.situacao
                            , x07.ident_modelo
                            , x2024.cod_modelo
                            , x07.norm_dev
                            , x07.ident_docto
                            , x2005.cod_docto
                            , x07.ident_fis_jur
                            , x04.cod_fis_jur
                            , x04.razao_social
                            , x04.cpf_cgc
                            , x07.cod_sistema_orig
                            , x07.num_autentic_nfe
                            ,    ( SELECT DISTINCT 'Campo de Loja (EF_LOC_BRL) diferente do Mastersaf no People; '
                                     FROM msafi.ps_nf_hdr_bbl_fs nfh
                                    WHERE 1 = 1
                                      AND nfh.inout_flg_pbl = 'O'
                                      AND nfh.nf_brl_id = x07.num_controle_docto
                                      AND nfh.nf_brl = x07.num_docfis
                                      AND nfh.nf_status_bbl IN ( 'CNFM'
                                                               , 'CNCL'
                                                               , 'PRNT'
                                                               , 'INTL'
                                                               , 'DNGD' )
                                      AND nfh.ef_loc_brl <> estab.location )
                              || --
                                 ( SELECT DISTINCT 'Data da Nota Fiscal diferente do Mastersaf no People; '
                                     FROM msafi.ps_nf_hdr_bbl_fs nfh
                                    WHERE 1 = 1
                                      AND nfh.inout_flg_pbl = 'O'
                                      AND nfh.nf_brl_id = x07.num_controle_docto
                                      AND nfh.nf_brl = x07.num_docfis
                                      AND nfh.nf_status_bbl IN ( 'CNFM'
                                                               , 'CNCL'
                                                               , 'PRNT'
                                                               , 'INTL'
                                                               , 'DNGD' )
                                      AND nfh.ef_loc_brl = estab.location
                                      AND ( CASE
                                               WHEN nfh.lt_grp_id_bbl IN ( 'TRO_LIB_23'
                                                                         , 'TRO_DIA_23' ) THEN
                                                   nfh.entered_dt
                                               WHEN nfh.lt_grp_id_bbl IN ( 'EST_LIB_14'
                                                                         , 'EST_LIB_4'
                                                                         , 'EST_DIA_23'
                                                                         , 'EST_DIA_2'
                                                                         , 'EST_LIB_23'
                                                                         , 'EST_LIB_3' ) THEN
                                                   NVL ( nfh.nf_conf_dt_bbl, nfh.nf_issue_dt_bbl )
                                               ELSE
                                                   nfh.nf_issue_dt_bbl
                                           END ) <> x07.data_fiscal )
                              || --
                                 ( SELECT DISTINCT 'Número da Nota (NF_BRL) diferente do Mastersaf no People; '
                                     FROM msafi.ps_nf_hdr_bbl_fs nfh
                                    WHERE 1 = 1
                                      AND nfh.inout_flg_pbl = 'O'
                                      AND nfh.nf_brl_id = x07.num_controle_docto
                                      AND nfh.nf_brl <> x07.num_docfis
                                      AND nfh.nf_status_bbl IN ( 'CNFM'
                                                               , 'CNCL'
                                                               , 'PRNT'
                                                               , 'INTL'
                                                               , 'DNGD' )
                                      AND nfh.ef_loc_brl = estab.location )
                              || --
                                ''
                                  AS observacao
                         FROM msaf.x07_docto_fiscal x07
                            , msaf.x04_pessoa_fis_jur x04
                            , msaf.x2005_tipo_docto x2005
                            , msaf.x2024_modelo_docto x2024
                            , msafi.dpsp_conc_nf_ms_falt_ps_chave filtro
                            , msafi.dsp_estabelecimento estab
                        WHERE 1 = 1
                          AND x07.cod_empresa = mcod_empresa
                          AND x07.cod_sistema_orig IN ( 'PS-E'
                                                      , 'PS-S' )
                          AND x07.ROWID = filtro.cod_rowid
                          AND x07.ident_fis_jur = x04.ident_fis_jur(+)
                          AND x07.ident_docto = x2005.ident_docto(+)
                          AND x07.ident_modelo = x2024.ident_modelo(+)
                          AND x07.data_fiscal = p_periodo
                          AND estab.cod_empresa = x07.cod_empresa
                          AND estab.cod_estab = x07.cod_estab ) LOOP
                IF v_class = 'A' THEN
                    v_class := 'B';
                ELSE
                    v_class := 'A';
                END IF;

                v_text01 :=
                    dsp_planilha.linha (
                                         p_conteudo =>    dsp_planilha.campo ( dsp_planilha.texto ( c.observacao ) )
                                                       || --
                                                         dsp_planilha.campo ( c.cod_empresa )
                                                       || --
                                                         dsp_planilha.campo ( c.cod_estab )
                                                       || --
                                                         dsp_planilha.campo ( dsp_planilha.texto (
                                                                                                   TO_CHAR (
                                                                                                             c.data_fiscal
                                                                                                           , 'DD/MM/YYYY'
                                                                                                   )
                                                                              ) )
                                                       || --
                                                         dsp_planilha.campo ( dsp_planilha.texto (
                                                                                                   TO_CHAR (
                                                                                                             c.data_emissao
                                                                                                           , 'DD/MM/YYYY'
                                                                                                   )
                                                                              ) )
                                                       || --
                                                         dsp_planilha.campo ( c.movto_e_s )
                                                       || --
                                                         dsp_planilha.campo ( dsp_planilha.texto ( c.num_docfis ) )
                                                       || --
                                                         dsp_planilha.campo (
                                                                              dsp_planilha.texto (
                                                                                                   c.num_controle_docto
                                                                              )
                                                          )
                                                       || --
                                                         dsp_planilha.campo ( dsp_planilha.texto ( c.serie_docfis ) )
                                                       || --
                                                         dsp_planilha.campo (
                                                                              dsp_planilha.texto (
                                                                                                   c.sub_serie_docfis
                                                                              )
                                                          )
                                                       || --
                                                         dsp_planilha.campo ( c.situacao )
                                                       || --
                                                         dsp_planilha.campo ( c.ident_modelo )
                                                       || --
                                                         dsp_planilha.campo ( dsp_planilha.texto ( c.cod_modelo ) )
                                                       || --
                                                         dsp_planilha.campo ( dsp_planilha.texto ( c.norm_dev ) )
                                                       || --
                                                         dsp_planilha.campo ( c.ident_docto )
                                                       || --
                                                         dsp_planilha.campo ( dsp_planilha.texto ( c.cod_docto ) )
                                                       || --
                                                         dsp_planilha.campo ( c.ident_fis_jur )
                                                       || --
                                                         dsp_planilha.campo ( dsp_planilha.texto ( c.cod_fis_jur ) )
                                                       || --
                                                         dsp_planilha.campo ( c.razao_social )
                                                       || --
                                                         dsp_planilha.campo ( dsp_planilha.texto ( c.cpf_cgc ) )
                                                       || --
                                                         dsp_planilha.campo (
                                                                              dsp_planilha.texto (
                                                                                                   c.cod_sistema_orig
                                                                              )
                                                          )
                                                       || --
                                                         dsp_planilha.campo (
                                                                              dsp_planilha.texto (
                                                                                                   c.num_autentic_nfe
                                                                              )
                                                          )
                                                       || --
                                                         ''
                                       , p_class => v_class
                    );
                lib_proc.add ( v_text01
                             , ptipo => 99 );

                COMMIT;
            END LOOP;
        --=========================================================
        END IF; -- P_MOVTO_E_S IN (1, 3)

        --=========================================================

        IF p_movto_e_s IN ( 1
                          , 2 ) THEN
            --=========================================================
            loga ( '>> ENTRADA'
                 , TRUE );
            --=========================================================
            v_step := 'J';

            dbms_application_info.set_module ( $$plsql_unit
                                             , mproc_id || ' ENT LJ:' || p_cod_estab );

            EXECUTE IMMEDIATE 'TRUNCATE TABLE MSAFI.DPSP_CONC_NF_MS_FALT_PS_CHAVE';

            loga ( '>> ENTRADA DIF '
                 , TRUE );

            /*FOR DIF IN (SELECT X07.ROWID V_ROWID
                          FROM MSAF.X07_DOCTO_FISCAL
                               --PARTITION FOR(V_DT_FIRST)
                                X07
                         WHERE 1 = 1
                           AND X07.COD_ESTAB =
                               DECODE(P_COD_ESTAB, '%', X07.COD_ESTAB, P_COD_ESTAB)
                           AND X07.DATA_FISCAL = P_PERIODO
                           AND X07.MOVTO_E_S <> '9'
                           AND X07.NORM_DEV = 1
                           AND X07.COD_SISTEMA_ORIG IN ('PS-E', 'PS-S')
                           AND NOT EXISTS
                         (SELECT 1
                                  FROM MSAFI.DPSP_CONC_NF_FALT_PS_ENT_GTT NFH
                                 WHERE 1 = 1
                                      --AND NFH.EF_LOC_BRL = ESTAB.LOCATION
                                   AND X07.NUM_DOCFIS = NFH.NF_BRL
                                   AND REPLACE(X07.NUM_CONTROLE_DOCTO, 'C-', '') =
                                       NFH.NF_BRL_ID
                                   AND X07.DATA_FISCAL = NFH.ACCOUNTING_DT
                                   AND X07.COD_ESTAB = NFH.COD_ESTAB
                                   AND X07.SERIE_DOCFIS = NFH.NF_BRL_SERIES)) LOOP

              INSERT INTO MSAFI.DPSP_CONC_NF_MS_FALT_PS_CHAVE
                (COD_ROWID)
              VALUES
                (DIF.V_ROWID);

              COMMIT;

            END LOOP;*/

            v_script := '';
            v_script := v_script || ' DECLARE ';
            v_script := v_script || ' BEGIN ';
            v_script := v_script || '  ';
            v_script := v_script || ' FOR DIF IN ( ';
            --
            v_script := v_script || ' SELECT X07.ROWID V_ROWID ';
            v_script := v_script || ' FROM MSAF.X07_DOCTO_FISCAL ';
            v_script := v_script || ' PARTITION FOR(''' || v_dt_first || ''')  ';
            v_script := v_script || ' X07 ';
            v_script := v_script || ' WHERE 1 = 1 ';
            v_script := v_script || ' AND X07.COD_EMPRESA = ''' || mcod_empresa || ''' ';
            v_script := v_script || ' AND X07.COD_ESTAB = ';
            v_script :=
                v_script || ' DECODE(''' || p_cod_estab || ''', ''%'', X07.COD_ESTAB, ''' || p_cod_estab || ''') ';
            v_script := v_script || ' AND X07.DATA_FISCAL = ''' || p_periodo || ''' ';
            v_script := v_script || ' AND X07.MOVTO_E_S <> ''9'' ';
            v_script := v_script || ' AND X07.NORM_DEV = 1 ';
            v_script := v_script || ' AND X07.COD_SISTEMA_ORIG IN (''PS-E'', ''PS-S'') ';
            --=========================================================
            --- Verificar se não existe a nota de Entrada no PeopleSoft
            --=========================================================
            v_script := v_script || ' AND NOT EXISTS ';
            v_script := v_script || ' (SELECT 1 ';
            v_script := v_script || ' FROM MSAFI.DPSP_CONC_NF_FALT_PS_ENT_GTT NFH ';
            v_script := v_script || ' WHERE 1 = 1 ';
            v_script := v_script || ' AND X07.NUM_DOCFIS = NFH.NF_BRL ';
            v_script := v_script || ' AND REPLACE(X07.NUM_CONTROLE_DOCTO, ''C-'', '''') = ';
            v_script := v_script || ' NFH.NF_BRL_ID ';
            v_script := v_script || ' AND X07.DATA_FISCAL = NFH.ACCOUNTING_DT ';
            v_script := v_script || ' AND X07.COD_ESTAB = NFH.COD_ESTAB ';
            v_script := v_script || ' AND X07.SERIE_DOCFIS = NFH.NF_BRL_SERIES) ';
            --=========================================================
            --=========================================================
            v_script := v_script || ' ) LOOP ';
            v_script := v_script || ' INSERT INTO MSAFI.DPSP_CONC_NF_MS_FALT_PS_CHAVE ';
            v_script := v_script || ' (COD_ROWID) ';
            v_script := v_script || ' VALUES ';
            v_script := v_script || ' (DIF.V_ROWID); ';
            v_script := v_script || '  ';
            v_script := v_script || ' COMMIT; ';
            v_script := v_script || ' END LOOP; ';
            v_script := v_script || ' END; ';

            BEGIN
                EXECUTE IMMEDIATE v_script;

                COMMIT;
            EXCEPTION
                WHEN OTHERS THEN
                    raise_application_error ( -20001
                                            , SQLERRM || '>>' || v_script );
            END;

            SELECT COUNT ( 1 )
              INTO v_count
              FROM msafi.dpsp_conc_nf_ms_falt_ps_chave;

            loga ( 'Qtd tabela: ' || v_count
                 , FALSE );

            --=========================================================
            loga ( '>> ENTRADA RECUPERA DADOS'
                 , FALSE );
            --=========================================================
            v_step := 'K';

            FOR c IN ( SELECT cod_empresa
                            , cod_estab
                            , data_fiscal
                            , data_emissao
                            , movto_e_s
                            , num_docfis
                            , num_controle_docto
                            , serie_docfis
                            , sub_serie_docfis
                            , x07.ident_modelo
                            , cod_modelo
                            , situacao
                            , norm_dev
                            , x07.ident_docto
                            , x2005.cod_docto
                            , x07.ident_fis_jur
                            , cod_fis_jur
                            , razao_social
                            , cpf_cgc
                            , cod_sistema_orig
                            , x07.num_autentic_nfe
                            , '' AS observacao
                         FROM msaf.x07_docto_fiscal x07
                            , msaf.x04_pessoa_fis_jur x04
                            , msaf.x2005_tipo_docto x2005
                            , msaf.x2024_modelo_docto x2024
                            , msafi.dpsp_conc_nf_ms_falt_ps_chave filtro
                        WHERE 1 = 1
                          AND x07.ROWID = filtro.cod_rowid
                          AND x07.ident_fis_jur = x04.ident_fis_jur(+)
                          AND x07.ident_docto = x2005.ident_docto(+)
                          AND x07.ident_modelo = x2024.ident_modelo(+)
                          AND x07.data_fiscal = p_periodo ) LOOP
                IF v_class = 'A' THEN
                    v_class := 'B';
                ELSE
                    v_class := 'A';
                END IF;

                v_text01 :=
                    dsp_planilha.linha (
                                         p_conteudo =>    dsp_planilha.campo ( dsp_planilha.texto ( c.observacao ) )
                                                       || --
                                                         dsp_planilha.campo ( c.cod_empresa )
                                                       || --
                                                         dsp_planilha.campo ( c.cod_estab )
                                                       || --
                                                         dsp_planilha.campo ( dsp_planilha.texto (
                                                                                                   TO_CHAR (
                                                                                                             c.data_fiscal
                                                                                                           , 'DD/MM/YYYY'
                                                                                                   )
                                                                              ) )
                                                       || --
                                                         dsp_planilha.campo ( dsp_planilha.texto (
                                                                                                   TO_CHAR (
                                                                                                             c.data_emissao
                                                                                                           , 'DD/MM/YYYY'
                                                                                                   )
                                                                              ) )
                                                       || --
                                                         dsp_planilha.campo ( c.movto_e_s )
                                                       || --
                                                         dsp_planilha.campo ( dsp_planilha.texto ( c.num_docfis ) )
                                                       || --
                                                         dsp_planilha.campo (
                                                                              dsp_planilha.texto (
                                                                                                   c.num_controle_docto
                                                                              )
                                                          )
                                                       || --
                                                         dsp_planilha.campo ( dsp_planilha.texto ( c.serie_docfis ) )
                                                       || --
                                                         dsp_planilha.campo (
                                                                              dsp_planilha.texto (
                                                                                                   c.sub_serie_docfis
                                                                              )
                                                          )
                                                       || --
                                                         dsp_planilha.campo ( c.situacao )
                                                       || --
                                                         dsp_planilha.campo ( c.ident_modelo )
                                                       || --
                                                         dsp_planilha.campo ( dsp_planilha.texto ( c.cod_modelo ) )
                                                       || --
                                                         dsp_planilha.campo ( dsp_planilha.texto ( c.norm_dev ) )
                                                       || --
                                                         dsp_planilha.campo ( c.ident_docto )
                                                       || --
                                                         dsp_planilha.campo ( dsp_planilha.texto ( c.cod_docto ) )
                                                       || --
                                                         dsp_planilha.campo ( c.ident_fis_jur )
                                                       || --
                                                         dsp_planilha.campo ( dsp_planilha.texto ( c.cod_fis_jur ) )
                                                       || --
                                                         dsp_planilha.campo ( c.razao_social )
                                                       || --
                                                         dsp_planilha.campo ( dsp_planilha.texto ( c.cpf_cgc ) )
                                                       || --
                                                         dsp_planilha.campo (
                                                                              dsp_planilha.texto (
                                                                                                   c.cod_sistema_orig
                                                                              )
                                                          )
                                                       || --
                                                         dsp_planilha.campo (
                                                                              dsp_planilha.texto (
                                                                                                   c.num_autentic_nfe
                                                                              )
                                                          )
                                                       || --
                                                         ''
                                       , p_class => v_class
                    );
                lib_proc.add ( v_text01
                             , ptipo => 99 );

                COMMIT;
            END LOOP;
        --=========================================================
        END IF; -- P_MOVTO_E_S IN (1, 2)

        --=========================================================

        --=========================================================
        loga ( '[FIM LOAD_EXCEL_MS]'
             , TRUE );
    --=========================================================

    END load_excel_ms;

    PROCEDURE exec_nf_parallel ( v_proc IN VARCHAR2
                               , p_flg_thread VARCHAR2
                               , p_lote IN INTEGER
                               , p_tab_partition IN VARCHAR2
                               , p_dt_ini DATE
                               , p_dt_fim DATE
                               , v_data_exec IN DATE )
    IS
        v_qt_grupos_paralelos INTEGER := 0;
        v_qt_grupos INTEGER := 0;
        p_task VARCHAR2 ( 400 );
        v_parametros VARCHAR2 ( 2000 );
        v_qtd_erro NUMBER := 0;

        v_cd_arquivo INTEGER := 20001;
        v_count NUMBER := 0;
    BEGIN
        SELECT COUNT ( script )
          INTO v_count
          FROM msafi.dpsp_conc_nf_falt_ps_script
         WHERE 1 = 1
           AND proc_id = mproc_id;

        loga ( 'Qtd tabela: ' || v_count
             , FALSE );

        IF v_count = 0 THEN
            loga ( '>> Não há NFs faltantes necessitando/disponíveis para carga.'
                 , FALSE );
        ELSE
            EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || p_tab_partition            INTO v_qt_grupos;

            loga ( '[INICIAR THREADS]' );

            --===================================
            --QUANTIDADE DE PROCESSOS EM PARALELO
            --===================================

            IF NVL ( p_lote, 0 ) < 1 THEN
                v_qt_grupos_paralelos := 20;
            ELSIF NVL ( p_lote, 0 ) > 100 THEN
                v_qt_grupos_paralelos := 100;
            ELSE
                IF NVL ( p_lote, 0 ) > NVL ( v_qt_grupos, 0 ) THEN
                    --SE O NUMERO DE THREADS FOR MAIOR QUE O NUMERO DE ESTABELECIMENTOS, OCORRE ERRO DE 'CRASHED' NA TASK
                    v_qt_grupos_paralelos := v_qt_grupos;
                ELSE
                    v_qt_grupos_paralelos := p_lote;
                END IF;
            END IF;

            loga ( '[QTD] [' || v_qt_grupos || '] [LOTES] [' || v_qt_grupos_paralelos || ']'
                 , FALSE );

            --=================================================
            loga ( '[INICIAR EXEC_CARGA]' );
            --=================================================

            p_task := 'EXEC_NF_' || v_proc;

            v_parametros :=
                   v_proc
                || ', '''
                || --
                  mproc_id
                || ''', '''
                || --
                  mcod_empresa
                || ''', '''
                || --
                  p_dt_ini
                || ''', '''
                || --
                  p_dt_ini
                || ''', '''
                || --
                  p_tab_partition
                || ''', '''
                || --
                  v_data_exec
                || ''''
                || --
                  '';

            -- CHUNK
            IF p_flg_thread = '1' THEN
                msaf.dpsp_chunk_parallel.exec_parallel ( v_proc
                                                       , 'DPSP_CONC_PS_NF_FALTANTE_CPROC.EXEC_CARGA_IDs'
                                                       , v_qt_grupos
                                                       , --QTDE DE CUPONS
                                                        v_qt_grupos_paralelos
                                                       , --QTDE DE THREADS
                                                        p_task
                                                       , v_parametros );
            ELSIF p_flg_thread = '2' THEN
                msaf.dpsp_chunk_parallel.exec_parallel ( v_proc
                                                       , 'DPSP_CONC_PS_NF_FALTANTE_CPROC.EXEC_CARGA_LOJAS'
                                                       , v_qt_grupos
                                                       , --QTDE DE ESTABELECIMENTOS
                                                        v_qt_grupos_paralelos
                                                       , --QTDE DE THREADS
                                                        p_task
                                                       , v_parametros );
            END IF;

            COMMIT;

            --=================================================
            loga ( '[FIM EXEC_CARGA]' );
            --=================================================

            loga ( '[FIM THREADS]' );

            --=================================================
            loga ( '[INICIO ARQUIVO LOG ERROS]' );

            --=================================================

            SELECT COUNT ( 1 )
              INTO v_qtd_erro
              FROM user_parallel_execute_chunks
             WHERE 1 = 1
               AND task_name LIKE '%' || v_proc || '%'
               AND status LIKE '%ERR%';

            loga ( '----------------------------------------'
                 , FALSE );
            loga ( 'TOTAL DE ' || v_qtd_erro || ' ERRO(S) ENCONTRADO(S)!'
                 , FALSE );

            IF v_qtd_erro = 0 THEN
                loga ( 'CARGA REALIZADA COM SUCESSO!'
                     , FALSE );
                loga ( '----------------------------------------'
                     , FALSE );

                --ENVIAR EMAIL DE SUCESSO----------------------------------------
                envia_email ( mcod_empresa
                            , p_dt_ini
                            , p_dt_fim
                            , ''
                            , 'S'
                            , v_data_exec );
            -----------------------------------------------------------------

            ELSE
                loga ( 'FAVOR VERIFICAR O ARQUIVO DE LOG.'
                     , FALSE );
                loga ( '----------------------------------------'
                     , FALSE );

                arq_log_erro ( mcod_empresa
                             , p_dt_ini
                             , v_proc
                             , v_cd_arquivo
                             , v_data_exec );

                SELECT    error_message
                       || CHR ( 13 )
                       || CHR ( 13 )
                       || 'VERIFICAR O ARQUIVO DE LOG PARA MAIS DETALHES - PROC_ID: '
                       || mproc_id
                           AS error_message
                  INTO v_parametros
                  FROM user_parallel_execute_chunks
                 WHERE 1 = 1
                   AND task_name LIKE '%' || v_proc || '%'
                   AND status LIKE '%ERR%'
                   AND ROWNUM = 1;

                --ENVIAR EMAIL DE ERRO-------------------------------------------
                envia_email ( mcod_empresa
                            , p_dt_ini
                            , p_dt_fim
                            , v_parametros
                            , 'E'
                            , v_data_exec );
            -----------------------------------------------------------------

            END IF;

            --=================================================
            loga ( '[FIM ARQUIVO LOG ERROS]' );
            --=================================================
            loga ( '>> Limpeza Tasks' );

            --Limpar Tasks com mais de 5 dias

            FOR c IN ( SELECT   DISTINCT task_name
                           FROM user_parallel_execute_chunks
                          WHERE 1 = 1
                            AND TO_DATE ( TO_CHAR ( end_ts
                                                  , 'DD/MM/YYYY' )
                                        , 'DD/MM/YYYY' ) < TO_DATE ( TO_CHAR ( SYSDATE - 5
                                                                             , 'DD/MM/YYYY' )
                                                                   , 'DD/MM/YYYY' )
                       ORDER BY 1 ) LOOP
                dbms_parallel_execute.drop_task ( c.task_name );
            END LOOP;
        END IF; -- V_COUNT = 0
    END exec_nf_parallel;

    PROCEDURE exec_carga_ids ( p_part_ini INTEGER
                             , p_part_fim INTEGER
                             , p_proc_instance VARCHAR2
                             , p_proc_id VARCHAR2
                             , pcod_empresa VARCHAR2
                             , p_dt_ini DATE
                             , p_dt_fim DATE
                             , p_tab_partition IN VARCHAR2
                             , v_data_exec IN DATE )
    IS
        v_proc_name VARCHAR2 ( 30 ) := 'EXEC_CARGA';
        v_status VARCHAR2 ( 10 ) := '';
        v_msg_erro VARCHAR2 ( 4000 ) := '';

        v_txt_nf VARCHAR2 ( 4000 ) := '';

        v_id_nf VARCHAR2 ( 40 );
        v_cod_estab VARCHAR2 ( 6 );
        v_tipo VARCHAR2 ( 1 );
    BEGIN
        EXECUTE IMMEDIATE
            'SELECT ID_NF ,COD_ESTAB, TIPO FROM ' || p_tab_partition || ' WHERE ROW_INI = :1 AND ROW_END = :2'
                       INTO v_id_nf
                          , v_cod_estab
                          , v_tipo
            USING p_part_ini
                , p_part_fim;

        vg_module := 'DPSP_CONC_PS_NF_FALTANTE_' || v_cod_estab;

        dbms_application_info.set_module ( vg_module
                                         , v_proc_name );

        ----------------------------------------
        BEGIN
            --=======================
            v_status := 'ID';
            dbms_application_info.set_module ( vg_module
                                             , v_proc_name || ' [' || v_status || '] [' || v_id_nf || ']' );

            FOR c IN ( SELECT x.script
                         FROM msafi.dpsp_conc_nf_falt_ps_script x
                        WHERE 1 = 1
                          AND x.proc_id = p_proc_id
                          AND x.nf_brl_id = v_id_nf
                          AND x.cod_estab = v_cod_estab ) LOOP
                v_txt_nf := c.script;

                INSERT INTO msafi.dpsp_conc_nf_falt_ps_script ( script )
                     VALUES ( v_txt_nf );

                COMMIT;

                EXECUTE IMMEDIATE 'BEGIN ' || v_txt_nf || ' END;';
            END LOOP;

            COMMIT;

            EXECUTE IMMEDIATE
                   'UPDATE '
                || p_tab_partition
                || ' SET STATUS = '''
                || v_status
                || ''' WHERE ROW_INI = :1 AND ROW_END = :2'
                USING p_part_ini
                    , p_part_fim;

            COMMIT;
        EXCEPTION
            WHEN OTHERS THEN
                v_msg_erro :=
                       '!ERRO '
                    || v_proc_name
                    || '! '
                    || --
                      '['
                    || v_cod_estab
                    || '] '
                    || --
                      '['
                    || v_status
                    || '] '
                    || --
                      '>> '
                    || SQLERRM
                    || ' >> '
                    || v_txt_nf;

                raise_application_error ( -20001
                                        , v_msg_erro );
        END;

        NULL;
    END exec_carga_ids;

    PROCEDURE exec_carga_lojas ( p_part_ini INTEGER
                               , p_part_fim INTEGER
                               , p_proc_instance VARCHAR2
                               , p_proc_id VARCHAR2
                               , pcod_empresa VARCHAR2
                               , p_dt_ini DATE
                               , p_dt_fim DATE
                               , p_tab_partition IN VARCHAR2
                               , v_data_exec IN DATE )
    IS
        v_count NUMBER := 0;
        v_commit NUMBER := 0;
        v_limit NUMBER := 100;

        v_proc_name VARCHAR2 ( 30 ) := 'EXEC_CARGA_IDs';
        v_status VARCHAR2 ( 10 ) := '';
        v_safx_name VARCHAR2 ( 100 ) := '';
        v_msg_erro VARCHAR2 ( 4000 ) := '';

        v_txt_nf VARCHAR2 ( 4000 ) := '';

        v_cod_estab VARCHAR2 ( 6 );
        v_tipo VARCHAR2 ( 1 );
    BEGIN
        dbms_application_info.set_module ( $$plsql_unit
                                         , 'CAR. QTD: ' || v_count );

        v_count := 0;

        EXECUTE IMMEDIATE 'SELECT COD_ESTAB, TIPO FROM ' || p_tab_partition || ' WHERE ROW_INI = :1 AND ROW_END = :2'
                       INTO v_cod_estab
                          , v_tipo
            USING p_part_ini
                , p_part_fim;

        vg_module := 'DPSP_CONC_PS_NF_FALTANTE_' || v_cod_estab;

        dbms_application_info.set_module ( vg_module
                                         , v_proc_name );

        ----------------------------------------
        BEGIN
            --=======================
            v_status := 'LJ';
            v_safx_name := 'CARGA';
            dbms_application_info.set_module ( vg_module
                                             , v_proc_name || ' [' || v_status || '] [' || v_safx_name || ']' );

            FOR c IN ( SELECT x.script
                         FROM msafi.dpsp_conc_nf_falt_ps_script x
                        WHERE 1 = 1
                          AND x.proc_id = p_proc_id
                          AND x.cod_estab = v_cod_estab ) LOOP
                v_count := 1;
                v_commit := v_commit + 1;

                v_txt_nf := 'BEGIN ' || c.script || ' END;';

                EXECUTE IMMEDIATE v_txt_nf;

                IF v_commit >= v_limit THEN
                    COMMIT;
                    v_commit := 0;
                END IF;

                dbms_application_info.set_module ( $$plsql_unit
                                                 , 'CAR. QTD: ' || v_count );
            END LOOP;

            EXECUTE IMMEDIATE
                   'UPDATE '
                || p_tab_partition
                || ' SET STATUS = '''
                || v_status
                || ''' WHERE ROW_INI = :1 AND ROW_END = :2'
                USING p_part_ini
                    , p_part_fim;

            COMMIT;
        EXCEPTION
            WHEN OTHERS THEN
                v_msg_erro :=
                       '!ERRO '
                    || v_proc_name
                    || '! '
                    || --
                      '['
                    || v_cod_estab
                    || '] '
                    || --
                      '['
                    || v_status
                    || '] '
                    || --
                      '['
                    || v_safx_name
                    || '] '
                    || --
                      '>> '
                    || SQLERRM
                    || ' >> '
                    || v_txt_nf;

                raise_application_error ( -20001
                                        , v_msg_erro );
        END;
    END exec_carga_lojas;

    PROCEDURE limpeza_gtts
    IS
        v_count NUMBER;
    BEGIN
        EXECUTE IMMEDIATE 'TRUNCATE TABLE MSAFI.DPSP_CONC_NF_FALT_PS_SAI_GTT';

        EXECUTE IMMEDIATE 'TRUNCATE TABLE MSAFI.DPSP_CONC_NF_FALT_PS_ENT_GTT';

        EXECUTE IMMEDIATE 'TRUNCATE TABLE MSAFI.DPSP_CONC_NF_FALT_PS_ENT_GTT';

        EXECUTE IMMEDIATE 'TRUNCATE TABLE MSAFI.DPSP_CONC_NF_MS_FALT_PS_CHAVE';

        --Apagar registros com execução maior do que 3 dias
        FOR c IN ( SELECT ROWID AS tmp_id
                     FROM msafi.dpsp_conc_nf_falt_ps_script
                    WHERE data_execucao < SYSDATE - 3 ) LOOP
            DELETE FROM msafi.dpsp_conc_nf_falt_ps_script
                  WHERE ROWID = c.tmp_id;

            v_count := v_count + 1;

            IF v_count > 10000 THEN
                COMMIT;
                v_count := 0;
            END IF;
        END LOOP;
    END;

    PROCEDURE arq_log_erro ( pcod_empresa VARCHAR2
                           , pdt_ini DATE
                           , v_proc VARCHAR2
                           , v_cd_arquivo INTEGER
                           , v_data_exec DATE )
    IS
        i INTEGER := v_cd_arquivo;
        --Variaveis genericas
        v_text01 VARCHAR2 ( 6000 );
        v_class VARCHAR2 ( 1 ) := 'a';
    BEGIN
        --Arquivo Sintetico
        lib_proc.add_tipo ( mproc_id
                          , i
                          ,    pcod_empresa
                            || '_'
                            || TO_CHAR ( pdt_ini
                                       , 'YYYYMM' )
                            || '_Carga_PS_Log_Erros.xls'
                          , 2 );

        lib_proc.add ( dsp_planilha.header
                     , ptipo => i );
        lib_proc.add ( dsp_planilha.tabela_inicio
                     , ptipo => i );

        lib_proc.add ( dsp_planilha.linha ( p_conteudo =>    dsp_planilha.campo ( 'CHUNK_ID' )
                                                          || --
                                                            dsp_planilha.campo ( 'TASK_NAME' )
                                                          || --
                                                            dsp_planilha.campo ( 'ERROR_CODE' )
                                                          || --
                                                            dsp_planilha.campo ( 'ERROR_MESSAGE'
                                                                               , p_custom => 'BGCOLOR=red' )
                                                          || --
                                                            dsp_planilha.campo ( 'STATUS' )
                                                          || --
                                                            dsp_planilha.campo ( 'START_ROWID' )
                                                          || --
                                                            dsp_planilha.campo ( 'END_ROWID' )
                                                          || --
                                                            dsp_planilha.campo ( 'START_ID' )
                                                          || --
                                                            dsp_planilha.campo ( 'END_ID' )
                                                          || --
                                                            dsp_planilha.campo ( 'JOB_NAME' )
                                                          || --
                                                            dsp_planilha.campo ( 'START_TS' )
                                                          || --
                                                            dsp_planilha.campo ( 'END_TS' )
                                                          || --
                                                            dsp_planilha.campo ( 'PROC_INSERT'
                                                                               , p_custom => 'BGCOLOR=green' )
                                                          || --
                                                            dsp_planilha.campo ( 'NUM_PROCESSO'
                                                                               , p_custom => 'BGCOLOR=green' )
                                                          || --
                                                            dsp_planilha.campo ( 'NOME_USUARIO'
                                                                               , p_custom => 'BGCOLOR=green' )
                                                          || dsp_planilha.campo ( 'DATA_EXEC'
                                                                                , p_custom => 'BGCOLOR=green' )
                                          , p_class => 'h' )
                     , ptipo => i );

        FOR cr_r IN ( SELECT   "CHUNK_ID"
                             , "TASK_NAME"
                             , "ERROR_CODE"
                             , "ERROR_MESSAGE"
                             , "STATUS"
                             , "START_ROWID"
                             , "END_ROWID"
                             , "START_ID"
                             , "END_ID"
                             , "JOB_NAME"
                             , "START_TS"
                             , "END_TS"
                             , v_proc AS "PROC_INSTANCE"
                             , mproc_id AS "NUM_PROCESSO"
                             , mcod_usuario AS "NOME_USUARIO"
                             , TO_CHAR ( v_data_exec
                                       , 'DD/MM/YYYY HH24:MI:SS' )
                                   AS "DATA_EXEC"
                          FROM user_parallel_execute_chunks
                         WHERE 1 = 1
                           AND task_name LIKE '%' || v_proc || '%'
                           AND status LIKE '%ERR%'
                      ORDER BY 1 DESC ) LOOP
            --Alterar a cor conforme a linha muda
            --IF V_CLASS = 'a' THEN
            v_class := 'b';
            --ELSE
            --  V_CLASS := 'a';
            --END IF;

            v_text01 :=
                dsp_planilha.linha (
                                     p_conteudo =>    dsp_planilha.campo ( dsp_planilha.texto ( cr_r."CHUNK_ID" ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( cr_r."TASK_NAME" ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( cr_r."ERROR_CODE" ) )
                                                   || --
                                                     dsp_planilha.campo (
                                                                          dsp_planilha.texto ( cr_r."ERROR_MESSAGE" )
                                                      )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( cr_r."STATUS" ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( cr_r."START_ROWID" ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( cr_r."END_ROWID" ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( cr_r."START_ID" ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( cr_r."END_ID" ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( cr_r."JOB_NAME" ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( cr_r."START_TS" ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( cr_r."END_TS" ) )
                                                   || --
                                                     dsp_planilha.campo (
                                                                          dsp_planilha.texto ( cr_r."PROC_INSTANCE" )
                                                      )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( cr_r."NUM_PROCESSO" ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( cr_r."NOME_USUARIO" ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( cr_r."DATA_EXEC" ) )
                                   , p_class => v_class
                );
            lib_proc.add ( v_text01
                         , ptipo => i );
        END LOOP;

        lib_proc.add ( dsp_planilha.tabela_fim
                     , ptipo => i );
        loga ( '>> Arquivo gerado.'
             , FALSE );
    END arq_log_erro;

    FUNCTION create_tab_part_ids ( vp_proc_id IN VARCHAR2 )
        RETURN VARCHAR2
    IS
        v_tab_part VARCHAR2 ( 30 );
        v_tipo VARCHAR2 ( 1 );
        v_count NUMBER := 0;
    BEGIN
        --O PARAMETRO DEVE ESTAR CADASTRADO NA TABELA: MSAFI.DPSP_TAB_MODELO

        v_tab_part :=
            msaf.dpsp_create_tab_tmp ( vp_proc_id
                                     , vp_proc_id
                                     , 'TAB_CARGA_PART_ID'
                                     , mcod_usuario );

        IF ( v_tab_part = 'ERRO' ) THEN
            loga ( '!ERRO CREATE_TAB_PART_LOJAS!' );
            raise_application_error ( -20001
                                    , '!ERRO CREATE_TAB_PART_IDs!' );
        END IF;

        FOR c IN ( SELECT   DISTINCT x.cod_estab
                                   , x.nf_brl_id AS id_nf
                       FROM msafi.dpsp_conc_nf_falt_ps_script x
                      WHERE 1 = 1
                        AND x.proc_id = mproc_id
                   ORDER BY x.cod_estab
                          , x.nf_brl_id ) LOOP
            v_count := v_count + 1;

            BEGIN
                EXECUTE IMMEDIATE 'INSERT INTO ' || v_tab_part || ' VALUES (:1, :2, :3, :4, :5, :6, :7)'
                    USING c.id_nf
                        , c.cod_estab
                        , v_count
                        , v_count
                        , ''
                        , v_tipo
                        , '';
            EXCEPTION
                WHEN OTHERS THEN
                    loga ( 'SQLERRM: ' || SQLERRM
                         , FALSE );
                    lib_proc.add_log ( 'ERRO NÃO TRATADO: ' || dbms_utility.format_error_backtrace
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
        END LOOP;

        COMMIT;

        RETURN v_tab_part;
    END;

    FUNCTION create_tab_part_lojas ( vp_proc_id IN VARCHAR2
                                   , vp_cod_estab IN lib_proc.vartab )
        RETURN VARCHAR2
    IS
        v_tab_part VARCHAR2 ( 30 );
        v_tipo VARCHAR2 ( 1 );
    BEGIN
        --O PARAMETRO DEVE ESTAR CADASTRADO NA TABELA: MSAFI.DPSP_TAB_MODELO

        v_tab_part :=
            msaf.dpsp_create_tab_tmp ( vp_proc_id
                                     , vp_proc_id
                                     , 'TAB_CARGA_PART'
                                     , mcod_usuario );

        IF ( v_tab_part = 'ERRO' ) THEN
            raise_application_error ( -20001
                                    , '!ERRO CREATE_TAB_PART_LOJAS!' );
        END IF;

        FOR i IN vp_cod_estab.FIRST .. vp_cod_estab.LAST LOOP
            SELECT tipo
              INTO v_tipo
              FROM msafi.dsp_estabelecimento
             WHERE cod_empresa = msafi.dpsp.empresa
               AND cod_estab = vp_cod_estab ( i );

            EXECUTE IMMEDIATE 'INSERT INTO ' || v_tab_part || ' VALUES (:1, :2, :3, :4, :5, :6)'
                USING vp_cod_estab ( i )
                    , i
                    , i
                    , ''
                    , v_tipo
                    , '';
        END LOOP;

        COMMIT;

        RETURN v_tab_part;
    END;

    FUNCTION executar ( p_dt_ini DATE
                      , p_dt_fim DATE
                      , p_todos_estab VARCHAR2
                      , p_movto_e_s VARCHAR2
                      , p_busca VARCHAR2
                      , p_uf VARCHAR2 DEFAULT NULL
                      , p_carregar VARCHAR2
                      , p_flg_thread VARCHAR2
                      , p_num_thread VARCHAR2
                      , p_lojas lib_proc.vartab DEFAULT p_null_lojas )
        RETURN INTEGER
    IS
        mdesc VARCHAR2 ( 4000 );
        v_data_exec DATE;
        v_count NUMBER := 0;

        --CARREGAR
        p_proc_instance VARCHAR2 ( 30 );
        v_tab_part VARCHAR2 ( 30 );
        v_cod_estab msaf.lib_proc.vartab;

        --Primeiro dia do mês para a partição
        v_dt_first DATE
            :=   TRUNC ( p_dt_ini )
               - (   TO_NUMBER ( TO_CHAR ( p_dt_ini
                                         , 'DD' ) )
                   - 1 );
    BEGIN
        -- Criação: Processo
        mproc_id := lib_proc.new ( psp_nome => $$plsql_unit );
        COMMIT;

        EXECUTE IMMEDIATE 'ALTER SESSION SET TEMP_UNDO_ENABLED=FALSE ';

        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT="YYYYMMDD"';

        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS= '',.'' ';

        --Recuperar a empresa para o plano de execução caso não esteja sendo executado pelo diretamente na tela do Mastersaf
        lib_parametros.salvar ( 'EMPRESA'
                              , NVL ( mcod_empresa, msafi.dpsp.v_empresa ) );

        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        mcod_usuario := lib_parametros.recuperar ( 'USUARIO' );
        mdesc := lib_parametros.recuperar ( 'PDESC' );

        IF mcod_usuario IS NULL THEN
            lib_parametros.salvar ( 'USUARIO'
                                  , 'AUTOMATICO' );
            mcod_usuario := lib_parametros.recuperar ( 'USUARIO' );
        END IF;

        v_data_exec := SYSDATE;

        loga ( '<<' || mnm_cproc || '>>'
             , FALSE );
        loga ( '---INICIO DO PROCESSAMENTO---'
             , FALSE );

        dbms_application_info.set_module ( $$plsql_unit
                                         , 'PROC_ID: ' || mproc_id );

        loga (    'Data execução: '
               || TO_CHAR ( v_data_exec
                          , 'DD/MM/YYYY HH24:MI:SS' )
             , FALSE );

        loga ( 'Usuário: ' || mcod_usuario
             , FALSE );
        loga ( 'Empresa: ' || mcod_empresa
             , FALSE );
        loga ( 'Período: ' || p_dt_ini || ' a ' || p_dt_fim
             , FALSE );
        loga ( 'Movimento: ' || p_movto_e_s
             , FALSE );
        loga ( 'Analisar: ' || p_busca
             , FALSE );
        loga ( 'UF: ' || p_uf
             , FALSE );

        IF p_carregar = 'S' THEN
            loga ( '----------------------------------------'
                 , FALSE );
            loga ( 'Paralelismo por: ' || ( CASE WHEN p_flg_thread = '1' THEN 'ID NFs' ELSE 'Lojas' END )
                 , FALSE );
            loga ( 'Threads: ' || p_num_thread
                 , FALSE );
        END IF;

        loga ( '----------------------------------------'
             , FALSE );

        loga ( 'Todas as Lojas: ' || ( CASE WHEN p_todos_estab = 'S' THEN 'Sim' ELSE 'Não' END )
             , FALSE );

        IF p_todos_estab = 'N' THEN
            v_count := p_lojas.COUNT;
            loga ( 'Qtd de Lojas: ' || v_count
                 , FALSE );
        END IF;

        loga ( '----------------------------------------'
             , FALSE );

        --VALIDAR DATA
        IF p_dt_ini >= SYSDATE THEN
            loga ( 'Não foi possível prosseguir:'
                 , FALSE );
            loga ( 'Data de Início não informada corretamente, favor verificar.'
                 , FALSE );
        ELSE
            --=========================================================
            loga ( '>> Processar'
                 , FALSE );
            --=========================================================

            --LIMPEZA
            limpeza_gtts;

            FOR c IN ( SELECT     p_dt_ini + ROWNUM - 1 AS data_par
                             FROM DUAL
                       CONNECT BY ROWNUM <= p_dt_fim - p_dt_ini + 1
                         ORDER BY 1 ) LOOP
                loga ( '----------------------------------------'
                     , FALSE );
                loga ( 'Dia: ' || c.data_par
                     , FALSE );
                loga ( '----------------------------------------'
                     , FALSE );

                IF NVL ( p_todos_estab, 'N' ) = 'N' THEN
                    FOR est IN p_lojas.FIRST .. p_lojas.LAST --(1)
                                                            LOOP
                        load_gtt_ps ( c.data_par
                                    , p_movto_e_s
                                    , p_lojas ( est ) );

                        COMMIT;
                    END LOOP;
                END IF;

                IF p_todos_estab = 'S' THEN
                    load_gtt_ps ( c.data_par
                                , p_movto_e_s
                                , '%' );
                END IF;

                COMMIT;
            END LOOP;

            --=========================================================
            IF p_busca IN ( 1
                          , 2 ) THEN
                --=========================================================

                lib_proc.add_tipo ( mproc_id
                                  , 98
                                  , 'REL_NF_PS_FALTANTE_MSAF.XLS'
                                  , 2 );

                lib_proc.add ( dsp_planilha.header
                             , ptipo => 98 );
                lib_proc.add ( dsp_planilha.tabela_inicio
                             , ptipo => 98 );

                lib_proc.add ( dsp_planilha.linha ( p_conteudo => dsp_planilha.campo (
                                                                                       'Notas Fiscais do People faltantes no Mastersaf'
                                                                                     , p_custom => 'COLSPAN=29 BGCOLOR=BLUE'
                                                                 ) --
                                                  , p_class => 'H' )
                             , ptipo => 98 );

                lib_proc.add ( dsp_planilha.linha (
                                                    p_conteudo =>    dsp_planilha.campo (
                                                                                          'OBSERVACAO'
                                                                                        , p_custom => 'BGCOLOR=#FF0000'
                                                                     )
                                                                  || --
                                                                    dsp_planilha.campo ( 'COD_EMPRESA' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'COD_ESTAB' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'ACCOUNTING_DT' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'NF_BRL' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'NF_BRL_SERIES' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'NF_BRL_ID' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'NF_BRL_STATUS' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'DESC_NF_BRL_STATUS' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'INOUT_FLG_PBL' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'DESC_INOUT_FLG_PBL' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'NF_BRL_TYPE' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'DESC_NF_BRL_TYPE' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'NF_STATUS_BBL' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'DESC_NF_STATUS_BBL' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'ENTERED_DT' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'NF_CONF_DT_BBL' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'NF_ISSUE_DT_BBL' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'LAST_UPDATE_DT' )
                                                                  || --
                                                                    dsp_planilha.campo (
                                                                                         'NFEE_KEY_BBL (CHAVE ACESSO)'
                                                                     )
                                                                  || --
                                                                    dsp_planilha.campo ( 'VENDOR_ID (COD_FIS_JUR)' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'EF_LOC_BRL' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'LT_GRP_ID_BBL' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'DESC_LT_GRP_ID_BBL' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'VENDOR_SETID' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'ADDRESS_SEQ_NUM' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'DELIVERED_DT' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'MAIOR_TOF_PBL_LINHA' )
                                                                  || --
                                                                    dsp_planilha.campo (
                                                                                         'RECARREGAR'
                                                                                       , p_custom => 'BGCOLOR=#33cc33'
                                                                     )
                                                                  || --
                                                                    '' --
                                                  , p_class => 'H'
                               )
                             , ptipo => 98 );

                -- CORPO
                FOR c IN ( SELECT     p_dt_ini + ROWNUM - 1 AS data_par
                                 FROM DUAL
                           CONNECT BY ROWNUM <= p_dt_fim - p_dt_ini + 1
                             ORDER BY 1 ) LOOP
                    loga ( '----------------------------------------'
                         , FALSE );
                    loga ( 'Dia: ' || c.data_par
                         , FALSE );
                    loga ( '----------------------------------------'
                         , FALSE );

                    IF NVL ( p_todos_estab, 'N' ) = 'N' THEN
                        FOR est IN p_lojas.FIRST .. p_lojas.LAST --(1)
                                                                LOOP
                            dbms_application_info.set_module (
                                                               $$plsql_unit
                                                             ,    'PS-Ent '
                                                               || 'Dia:'
                                                               || c.data_par
                                                               || ' Lj:'
                                                               || p_lojas ( est )
                            );

                            load_excel_ps ( c.data_par
                                          , v_dt_first
                                          , p_movto_e_s
                                          , p_lojas ( est )
                                          , p_carregar
                                          , v_data_exec );

                            COMMIT;
                        END LOOP;
                    END IF;

                    IF p_todos_estab = 'S' THEN
                        dbms_application_info.set_module ( $$plsql_unit
                                                         , 'Dia:' || c.data_par || ' Lj:' || 'Todas' );

                        load_excel_ps ( c.data_par
                                      , v_dt_first
                                      , p_movto_e_s
                                      , '%'
                                      , p_carregar
                                      , v_data_exec );
                    END IF;

                    COMMIT;
                END LOOP;

                -- RODAPE
                lib_proc.add ( dsp_planilha.tabela_fim
                             , ptipo => 98 );
                COMMIT;
            --

            --=========================================================
            END IF; -- P_BUSCA IN (1, 2)

            --=========================================================

            --=========================================================
            IF p_busca IN ( 1
                          , 3 ) THEN
                --=========================================================

                -- RELATORIO: CONTEM NO MSAF MAS NAO TEM NO PS

                dbms_application_info.set_module ( $$plsql_unit
                                                 , 'VERIFICA MSAF' );

                lib_proc.add_tipo ( mproc_id
                                  , 99
                                  , 'REL_NF_MSAF_FALTANTE_PS.XLS'
                                  , 2 );

                lib_proc.add ( dsp_planilha.header
                             , ptipo => 99 );
                lib_proc.add ( dsp_planilha.tabela_inicio
                             , ptipo => 99 );

                lib_proc.add ( dsp_planilha.linha ( p_conteudo => dsp_planilha.campo (
                                                                                       'Notas Fiscais do Mastersaf faltantes no People'
                                                                                     , p_custom => 'COLSPAN=21 BGCOLOR=#8B008B'
                                                                 ) --
                                                  , p_class => 'H' )
                             , ptipo => 99 );

                lib_proc.add ( dsp_planilha.linha ( p_conteudo =>    dsp_planilha.campo (
                                                                                          'OBSERVACAO'
                                                                                        , p_custom => 'BGCOLOR=#FF0000'
                                                                     )
                                                                  || --
                                                                    dsp_planilha.campo ( 'COD_EMPRESA' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'COD_ESTAB' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'DATA_FISCAL' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'DATA_EMISSAO' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'MOVTO_E_S' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'NUM_DOCFIS' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'NUM_CONTROLE_DOCTO' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'SERIE_DOCFIS' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'SUB_SERIE_DOCFIS' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'SITUACAO' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'IDENT_MODELO' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'COD_MODELO' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'NORM_DEV' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'IDENT_DOCTO' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'COD_DOCTO' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'IDENT_FIS_JUR' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'COD_FIS_JUR' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'RAZAO_SOCIAL' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'CPF_CGC' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'COD_SISTEMA_ORIG' )
                                                                  || --
                                                                    dsp_planilha.campo ( 'NUM_AUTENTIC_NFE' )
                                                                  || --
                                                                    ''
                                                  , p_class => 'H' )
                             , ptipo => 99 );

                -- CORPO

                FOR c IN ( SELECT     p_dt_ini + ROWNUM - 1 AS data_par
                                 FROM DUAL
                           CONNECT BY ROWNUM <= p_dt_fim - p_dt_ini + 1
                             ORDER BY 1 ) LOOP
                    loga ( '----------------------------------------'
                         , FALSE );
                    loga ( 'Dia:' || c.data_par
                         , FALSE );
                    loga ( '----------------------------------------'
                         , FALSE );

                    IF NVL ( p_todos_estab, 'N' ) = 'N' THEN
                        FOR est IN p_lojas.FIRST .. p_lojas.LAST --(1)
                                                                LOOP
                            dbms_application_info.set_module ( $$plsql_unit
                                                             , 'Dia:' || c.data_par || ' Loja:' || p_lojas ( est ) );

                            load_excel_ms ( c.data_par
                                          , v_dt_first
                                          , p_movto_e_s
                                          , p_lojas ( est ) );

                            COMMIT;
                        END LOOP;
                    END IF;

                    IF p_todos_estab = 'S' THEN
                        dbms_application_info.set_module ( $$plsql_unit
                                                         , 'Dia:' || c.data_par || ' Loja:' || 'Totas' );

                        load_excel_ms ( c.data_par
                                      , v_dt_first
                                      , p_movto_e_s
                                      , '%' );
                    END IF;

                    COMMIT;
                END LOOP;

                -- RODAPE
                lib_proc.add ( dsp_planilha.tabela_fim
                             , ptipo => 99 );
                COMMIT;
            --

            --=========================================================
            END IF; -- P_BUSCA IN (1, 3)
        --=========================================================

        END IF; --VALIDAR DATA

        --=========================================================
        IF p_carregar = 'S' THEN
            --=========================================================

            SELECT ROUND ( dbms_random.VALUE ( 10000000000000
                                             , 999999999999999 ) )
              INTO p_proc_instance
              FROM DUAL;

            IF p_flg_thread = '1' THEN
                v_tab_part := create_tab_part_ids ( p_proc_instance );
            ELSIF p_flg_thread = '2' THEN
                IF p_todos_estab = 'S' THEN
                    SELECT   cod_estab
                        BULK COLLECT INTO v_cod_estab
                        FROM dsp_estabelecimento_v
                       WHERE 1 = 1
                         AND cod_empresa = mcod_empresa
                    ORDER BY cod_estab;
                ELSE
                    v_cod_estab := p_lojas;
                END IF;

                v_tab_part :=
                    create_tab_part_lojas ( p_proc_instance
                                          , v_cod_estab );
            END IF;

            loga ( '----------------------------------------'
                 , FALSE );
            loga ( '>> PROC INSERT: ' || p_proc_instance
                 , FALSE );
            loga ( '>> TAB_PART: ' || v_tab_part
                 , FALSE );
            loga ( '----------------------------------------'
                 , FALSE );

            exec_nf_parallel ( p_proc_instance
                             , p_flg_thread
                             , p_num_thread
                             , v_tab_part
                             , p_dt_ini
                             , p_dt_fim
                             , v_data_exec );
        --=========================================================
        END IF; -- P_CARREGAR ='S'

        --=========================================================

        --LIMPEZA
        loga ( '>> Limpeza'
             , FALSE );
        limpeza_gtts;

        loga ( '---FIM DO PROCESSAMENTO---'
             , FALSE );

        lib_proc.close;
        RETURN mproc_id;
    EXCEPTION
        WHEN OTHERS THEN
            loga ( 'SQLERRM: ' || SQLERRM
                 , FALSE );
            lib_proc.add_log ( 'ERRO NÃO TRATADO: ' || dbms_utility.format_error_backtrace
                             , 1 );
            lib_proc.add_log ( 'SQLERRM: ' || SQLERRM
                             , 1 );
            lib_proc.add ( 'ERRO!'
                         , 1 );
            lib_proc.add ( ' '
                         , 1 );
            lib_proc.add ( dbms_utility.format_error_backtrace
                         , 1 );

            --ENVIAR EMAIL DE ERRO-------------------------------------------
            envia_email ( mcod_empresa
                        , p_dt_ini
                        , p_dt_fim
                        , SQLERRM
                        , 'E'
                        , v_data_exec );
            -----------------------------------------------------------------

            lib_proc.close;
            COMMIT;
            RETURN mproc_id;
    END;
END dpsp_conc_ps_nf_faltante_cproc;
/
SHOW ERRORS;
