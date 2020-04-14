Prompt Package Body DPSP_CARGA_PS_NF_CPROC;
--
-- DPSP_CARGA_PS_NF_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_carga_ps_nf_cproc
IS
    v_sel_data_fim VARCHAR2 ( 260 )
        := ' SELECT TRUNC( TO_DATE( :2 ,''DD/MM/YYYY'') + ROWNUM - 1) AS DATA_FIM, TRUNC( TO_DATE( :2 ,''DD/MM/YYYY'') + ROWNUM - 1) AS DATA_FIM FROM DUAL CONNECT BY ROWNUM <= LAST_DAY( TO_DATE( :2 ,''DD/MM/YYYY'') ) - TO_DATE( :2 ,''DD/MM/YYYY'') + 1 ORDER BY 1 DESC ';
    vs_mcod_empresa estabelecimento.cod_empresa%TYPE;
    vs_mcod_usuario usuario_estab.cod_usuario%TYPE;
    vs_mproc_id NUMBER;

    vg_module VARCHAR2 ( 60 ) := '';

    --Tipo, Nome e DescriÁ„o do Customizado
    mnm_tipo VARCHAR2 ( 100 ) := 'AutomatizaÁ„o';
    mnm_cproc VARCHAR2 ( 100 ) := 'Carga Autom·tica Notas Fiscais - PeopleSoft';
    mds_cproc VARCHAR2 ( 100 ) := 'ExecuÁ„o da Carga do PeopleSoft';

    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );
    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS= '',.'' ';

        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_LANGUAGE = ''Portuguese'' ';

        vs_mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        vs_mcod_usuario := lib_parametros.recuperar ( 'USUARIO' );

        lib_parametros.salvar ( 'EMPRESA'
                              , NVL ( vs_mcod_empresa, msafi.dpsp.v_empresa ) );

        --PCOD_EMPRESA
        lib_proc.add_param (
                             pparam => pstr
                           , ptitulo => 'Empresa'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'COMBOBOX'
                           , pmandatorio => 'N'
                           , pdefault => vs_mcod_empresa
                           , pmascara => NULL
                           , pvalores =>    'SELECT COD_EMPRESA,COD_EMPRESA || '' - '' || RAZAO_SOCIAL '
                                         || ' FROM EMPRESA WHERE COD_EMPRESA = '''
                                         || vs_mcod_empresa
                                         || ''' ORDER BY 1'
                           , phabilita => NULL
        );

        lib_proc.add_param ( pstr
                           , 'Data Inicial'
                           , --PDT_INI
                            'DATE'
                           , 'TEXTBOX'
                           , 'S'
                           , NULL
                           , 'DD/MM/YYYY' );

        lib_proc.add_param ( pstr
                           , 'Data Final'
                           , --PDT_FIM
                            'VARCHAR2'
                           , 'COMBOBOX'
                           , 'S'
                           , NULL
                           , '##########'
                           , v_sel_data_fim );
        lib_proc.add_param ( pstr
                           , 'Qtde de ExecuÁıes em Paralelo'
                           , --PTHREAD
                            'NUMBER'
                           , 'TEXTBOX'
                           , 'S'
                           , '20'
                           , '####' );

        lib_proc.add_param ( pparam => pstr
                           , ptitulo => 'Carregar NFs Entrada'
                           , ptipo => 'varchar2'
                           , pcontrole => 'checkbox'
                           , pmandatorio => 'N'
                           , pdefault => 'S'
                           , pmascara => NULL
                           , pvalores => 'S=Sim' );

        lib_proc.add_param ( pparam => pstr
                           , ptitulo => 'Carregar NFs SaÌda'
                           , ptipo => 'varchar2'
                           , pcontrole => 'checkbox'
                           , pmandatorio => 'N'
                           , pdefault => 'S'
                           , pmascara => NULL
                           , pvalores => 'S=Sim' );

        lib_proc.add_param (
                             pstr
                           , 'UF'
                           , --PCOD_ESTADO
                            'VARCHAR2'
                           , 'COMBOBOX'
                           , 'S'
                           , '%'
                           , '#########'
                           , 'SELECT A.COD_ESTADO, A.COD_ESTADO FROM ESTADO A UNION ALL SELECT ''%'', ''Todas as UFs'' FROM DUAL ORDER BY 1'
        );

        lib_proc.add_param (
                             pstr
                           , 'Estabelecimento'
                           , --PCOD_ESTAB
                            'VARCHAR2'
                           , 'MULTISELECT'
                           , 'S'
                           , 'S'
                           , NULL
                           ,    ' SELECT A.COD_ESTAB, A.COD_ESTAB || '' - '' || B.COD_ESTADO || '' - '' || A.CGC || '' - '' || INITCAP(A.BAIRRO) || '' / '' || INITCAP(A.CIDADE) '
                             || ' FROM ESTABELECIMENTO A, ESTADO B, MSAFI.DSP_ESTABELECIMENTO C '
                             || ' WHERE 1=1 '
                             || --
                               ' AND A.COD_EMPRESA  = '''
                             || vs_mcod_empresa
                             || ''''
                             || ' AND B.IDENT_ESTADO = A.IDENT_ESTADO '
                             || ' AND A.COD_EMPRESA  = C.COD_EMPRESA '
                             || ' AND A.COD_ESTAB    = C.COD_ESTAB '
                             || ' AND B.COD_ESTADO LIKE :7 '
                             || ' ORDER BY A.COD_ESTAB  '
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
        -- OrientaÁ„o do Papel
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
                         , '¡«…Õ”⁄¿»Ã“Ÿ¬ Œ‘€√’À‹¡«…Õ”⁄¿»Ã“Ÿ¬ Œ‘€√’À‹·ÁÈÌÛ˙‡ËÏÚ˘‚ÍÓÙ˚„ıÎ¸·ÁÈÌÛ˙‡ËÏÚ˘‚ÍÓÙ˚„ıÎ¸'
                         , 'ACEIOUAEIOUAEIOUAOEUACEIOUAEIOUAEIOUAOEUaceiouaeiouaeiouaoeuaceiouaeiouaeiouaoeu'
               )
          INTO v_nm_tipo
          FROM DUAL;

        SELECT TRANSLATE (
                           mnm_cproc
                         , '¡«…Õ”⁄¿»Ã“Ÿ¬ Œ‘€√’À‹¡«…Õ”⁄¿»Ã“Ÿ¬ Œ‘€√’À‹·ÁÈÌÛ˙‡ËÏÚ˘‚ÍÓÙ˚„ıÎ¸·ÁÈÌÛ˙‡ËÏÚ˘‚ÍÓÙ˚„ıÎ¸'
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

        v_txt_email := v_txt_email || CHR ( 13 ) || '>> Par‚metros: ';
        v_txt_email := v_txt_email || CHR ( 13 ) || ' - Empresa: ' || vp_cod_empresa;
        v_txt_email :=
               v_txt_email
            || CHR ( 13 )
            || ' - Data InÌcio: '
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
            || ' - Hora InÌcio: '
            || TO_CHAR ( vp_data_hora_ini
                       , 'DD/MM/YYYY HH24:MI.SS' );
        v_txt_email :=
               v_txt_email
            || CHR ( 13 )
            || ' - Hora TÈrmino: '
            || TO_CHAR ( SYSDATE
                       , 'DD/MM/YYYY HH24:MI.SS' );
        v_txt_email := v_txt_email || CHR ( 13 ) || ' - Tempo ExecuÁ„o: ' || TRIM ( v_tempo_exec );

        IF ( vp_tipo = 'E' ) THEN
            v_txt_email := v_txt_email || CHR ( 13 ) || ' ';
            v_txt_email := v_txt_email || CHR ( 13 ) || '<< ERRO >> ' || CHR ( 13 ) || vp_msg_oracle;
        END IF;

        --TIRAR ACENTOS
        SELECT TRANSLATE (
                           v_txt_email
                         , '¡«…Õ”⁄¿»Ã“Ÿ¬ Œ‘€√’À‹¡«…Õ”⁄¿»Ã“Ÿ¬ Œ‘€√’À‹·ÁÈÌÛ˙‡ËÏÚ˘‚ÍÓÙ˚„ıÎ¸·ÁÈÌÛ˙‡ËÏÚ˘‚ÍÓÙ˚„ıÎ¸'
                         , 'ACEIOUAEIOUAEIOUAOEUACEIOUAEIOUAEIOUAOEUaceiouaeiouaeiouaoeuaceiouaeiouaeiouaoeu'
               )
          INTO v_txt_email
          FROM DUAL;

        SELECT TRANSLATE (
                           v_assunto
                         , '¡«…Õ”⁄¿»Ã“Ÿ¬ Œ‘€√’À‹¡«…Õ”⁄¿»Ã“Ÿ¬ Œ‘€√’À‹·ÁÈÌÛ˙‡ËÏÚ˘‚ÍÓÙ˚„ıÎ¸·ÁÈÌÛ˙‡ËÏÚ˘‚ÍÓÙ˚„ıÎ¸'
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

    PROCEDURE exec_nf_parallel ( v_proc IN VARCHAR2
                               , p_lote IN INTEGER
                               , pdt_ini IN DATE
                               , pdt_fim IN DATE
                               , flg_nf_ent CHAR
                               , flg_nf_sai CHAR
                               , p_tab_partition IN VARCHAR2
                               , v_data_exec IN DATE )
    IS
        v_qt_grupos_paralelos INTEGER := 0;
        v_qt_grupos INTEGER := 0;
        p_task VARCHAR2 ( 400 );
        v_parametros VARCHAR2 ( 2000 );
        v_qtd_erro NUMBER := 0;

        v_cd_arquivo INTEGER := 2;

        --Flags da Interface de Entrada
        p_carga_po VARCHAR2 ( 10 ) := 'S';
        p_carga_auditoria_e VARCHAR2 ( 10 ) := 'N';

        --Flags da Interface de SaÌda
        p_uso_consumo CHAR := 'S';
        p_cagadas CHAR := 'N';
        p_vira_ignora_ps CHAR := 'N';
        p_carga_auditoria_s CHAR := 'N';

        --Interface Entrada e Saida
        v_c_safx07 VARCHAR2 ( 10 ) := 'S';
        v_c_safx08 VARCHAR2 ( 10 ) := 'S';
        v_c_safx03 VARCHAR2 ( 10 ) := 'N';
        v_c_safx301 VARCHAR2 ( 10 ) := 'N';
        v_c_safx112 VARCHAR2 ( 10 ) := 'S';

        --Interface Saida
        v_c_safx116 VARCHAR2 ( 10 ) := 'S';
        v_c_safx117 VARCHAR2 ( 10 ) := 'S';
        v_c_safx119 VARCHAR2 ( 10 ) := 'N';
    BEGIN
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

        loga ( '[QTD ESTABS] [' || v_qt_grupos || '] [LOTES] [' || v_qt_grupos_paralelos || ']'
             , FALSE );

        IF flg_nf_ent = 'S' THEN
            --=================================================
            loga ( '[INICIAR INTERFACE NF ENTRADA]' );
            --=================================================
            loga ( 'Carrega PO: ' || ( CASE WHEN p_carga_po = 'S' THEN 'Sim' ELSE 'N„o' END )
                 , FALSE );
            loga (
                      'Carrega tabela de auditoria: '
                   || ( CASE WHEN p_carga_auditoria_e = 'S' THEN 'Sim' ELSE 'N„o' END )
                 , FALSE
            );

            loga ( 'SAFX07: ' || ( CASE WHEN v_c_safx07 = 'S' THEN 'Sim' ELSE 'N„o' END )
                 , FALSE );
            loga ( 'SAFX08: ' || ( CASE WHEN v_c_safx08 = 'S' THEN 'Sim' ELSE 'N„o' END )
                 , FALSE );
            loga ( 'SAFX03: ' || ( CASE WHEN v_c_safx03 = 'S' THEN 'Sim' ELSE 'N„o' END )
                 , FALSE );
            loga ( 'SAFX301: ' || ( CASE WHEN v_c_safx301 = 'S' THEN 'Sim' ELSE 'N„o' END )
                 , FALSE );
            loga ( 'SAFX112: ' || ( CASE WHEN v_c_safx112 = 'S' THEN 'Sim' ELSE 'N„o' END )
                 , FALSE );

            p_task := 'EXEC_NF_ENT_' || v_proc;

            v_parametros :=
                   v_proc
                || ', '''
                || --
                  vs_mcod_empresa
                || ''', '''
                || --
                  TO_CHAR ( pdt_ini
                          , 'DD/MM/YYYY' )
                || ''', '''
                || --
                  TO_CHAR ( pdt_fim
                          , 'DD/MM/YYYY' )
                || ''', '''
                || --
                  p_tab_partition
                || ''', '''
                || --
                  TO_CHAR ( v_data_exec
                          , 'DD/MM/YYYY' )
                || ''', '''
                || --
                  p_carga_po
                || ''', '''
                || --
                  p_carga_auditoria_e
                || ''', '''
                || --
                  v_c_safx07
                || ''', '''
                || --
                  v_c_safx08
                || ''', '''
                || --
                  v_c_safx03
                || ''', '''
                || --
                  v_c_safx301
                || ''', '''
                || --
                  v_c_safx112
                || ''''; --

            -- CHUNK
            msaf.dpsp_chunk_parallel.exec_parallel ( v_proc
                                                   , 'DPSP_CARGA_PS_NF_CPROC.EXEC_NF_ENT'
                                                   , v_qt_grupos
                                                   , --QTDE DE ESTABELECIMENTOS
                                                    v_qt_grupos_paralelos
                                                   , --QTDE DE THREADS
                                                    p_task
                                                   , v_parametros );

            COMMIT;

            --=================================================
            loga ( '[FIM INTERFACE NF ENTRADA]' );
        --=================================================
        END IF;

        IF flg_nf_sai = 'S' THEN
            --=================================================
            loga ( '[INICIAR INTERFACE NF SAIDA]' );
            --=================================================

            loga ( 'Vira NFs Uso e Consumo: ' || ( CASE WHEN p_uso_consumo = 'S' THEN 'Sim' ELSE 'N„o' END )
                 , FALSE );
            loga ( 'Vira NFs Cagadas: ' || ( CASE WHEN p_cagadas = 'S' THEN 'Sim' ELSE 'N„o' END )
                 , FALSE );
            loga (
                      'Ignora SETUP de virada do PeopleSoft: '
                   || ( CASE WHEN p_vira_ignora_ps = 'S' THEN 'Sim' ELSE 'N„o' END )
                 , FALSE
            );
            loga (
                      'Carrega tabela de auditoria: '
                   || ( CASE WHEN p_carga_auditoria_s = 'S' THEN 'Sim' ELSE 'N„o' END )
                 , FALSE
            );

            loga ( 'SAFX07: ' || ( CASE WHEN v_c_safx07 = 'S' THEN 'Sim' ELSE 'N„o' END )
                 , FALSE );
            loga ( 'SAFX08: ' || ( CASE WHEN v_c_safx08 = 'S' THEN 'Sim' ELSE 'N„o' END )
                 , FALSE );
            loga ( 'SAFX112: ' || ( CASE WHEN v_c_safx112 = 'S' THEN 'Sim' ELSE 'N„o' END )
                 , FALSE );
            loga ( 'SAFX116: ' || ( CASE WHEN v_c_safx116 = 'S' THEN 'Sim' ELSE 'N„o' END )
                 , FALSE );
            loga ( 'SAFX117: ' || ( CASE WHEN v_c_safx117 = 'S' THEN 'Sim' ELSE 'N„o' END )
                 , FALSE );
            loga ( 'SAFX119: ' || ( CASE WHEN v_c_safx119 = 'S' THEN 'Sim' ELSE 'N„o' END )
                 , FALSE );

            /*
            --=================================================
             LOGA('[INICIAR LISTA DA SAIDA]');
             --=================================================

             LIST_SAIDA(VS_MCOD_EMPRESA, PDT_INI, PDT_FIM, V_DATA_EXEC);

             --=================================================
             LOGA('[FIM LISTA DA SAIDA]');
             --=================================================
             */

            p_task := 'EXEC_NF_SAI_' || v_proc;

            v_parametros :=
                   v_proc
                || ', '''
                || --
                  vs_mcod_empresa
                || ''', '''
                || --
                  TO_CHAR ( pdt_ini
                          , 'DD/MM/YYYY' )
                || ''', '''
                || --
                  TO_CHAR ( pdt_fim
                          , 'DD/MM/YYYY' )
                || ''', '''
                || --
                  p_tab_partition
                || ''', '''
                || --
                  TO_CHAR ( v_data_exec
                          , 'DD/MM/YYYY' )
                || ''', '''
                || --
                  p_uso_consumo
                || ''', '''
                || --
                  p_cagadas
                || ''', '''
                || --
                  p_vira_ignora_ps
                || ''', '''
                || --
                  p_carga_auditoria_s
                || ''', '''
                || --
                  v_c_safx07
                || ''', '''
                || --
                  v_c_safx08
                || ''', '''
                || --
                  v_c_safx112
                || ''', '''
                || --
                  v_c_safx116
                || ''', '''
                || --
                  v_c_safx117
                || ''', '''
                || --
                  v_c_safx119
                || ''''; --

            -- CHUNK
            msaf.dpsp_chunk_parallel.exec_parallel ( v_proc
                                                   , 'DPSP_CARGA_PS_NF_CPROC.EXEC_NF_SAI'
                                                   , v_qt_grupos
                                                   , --QTDE DE ESTABELECIMENTOS
                                                    v_qt_grupos_paralelos
                                                   , --QTDE DE THREADS
                                                    p_task
                                                   , v_parametros );

            COMMIT;

            --=================================================
            loga ( '[FIM INTERFACE NF SAIDA]' );
        --=================================================
        END IF;

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
            envia_email ( vs_mcod_empresa
                        , pdt_ini
                        , pdt_fim
                        , ''
                        , 'S'
                        , v_data_exec );
        -----------------------------------------------------------------

        ELSE
            loga ( 'FAVOR VERIFICAR O ARQUIVO DE LOG.'
                 , FALSE );
            loga ( '----------------------------------------'
                 , FALSE );

            arq_log_erro ( vs_mcod_empresa
                         , pdt_ini
                         , v_proc
                         , v_cd_arquivo
                         , v_data_exec );

            SELECT    error_message
                   || CHR ( 13 )
                   || CHR ( 13 )
                   || 'VERIFICAR O ARQUIVO DE LOG PARA MAIS DETALHES - PROC_ID: '
                   || vs_mproc_id
                       AS error_message
              INTO v_parametros
              FROM user_parallel_execute_chunks
             WHERE 1 = 1
               AND task_name LIKE '%' || v_proc || '%'
               AND status LIKE '%ERR%'
               AND ROWNUM = 1;

            --ENVIAR EMAIL DE ERRO-------------------------------------------
            envia_email ( vs_mcod_empresa
                        , pdt_ini
                        , pdt_fim
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
    END exec_nf_parallel;

    PROCEDURE exec_nf_ent ( p_part_ini INTEGER
                          , p_part_fim INTEGER
                          , p_proc_instance VARCHAR2
                          , pcod_empresa VARCHAR2
                          , pdt_ini DATE
                          , pdt_fim DATE
                          , p_tab_partition IN VARCHAR2
                          , v_data_exec IN DATE
                          , p_carga_po IN VARCHAR2
                          , p_carga_auditoria IN VARCHAR2
                          , v_c_safx07 IN VARCHAR2
                          , v_c_safx08 IN VARCHAR2
                          , v_c_safx03 IN VARCHAR2
                          , v_c_safx301 IN VARCHAR2
                          , v_c_safx112 IN VARCHAR2 )
    IS
        v_proc_name VARCHAR2 ( 30 ) := 'EXEC_NF_ENT';
        v_status CHAR := '';
        v_safx_name VARCHAR2 ( 100 ) := '';
        v_msg_erro VARCHAR2 ( 4000 ) := '';

        v_txt_basico VARCHAR2 ( 256 ) := '';
        v_txt_nf VARCHAR2 ( 1024 ) := '';
        v_calc CHAR := 'N';

        v_cod_estab VARCHAR2 ( 6 );
        v_tipo VARCHAR2 ( 1 );

        v_txt_entrada VARCHAR2 ( 4000 ) := '';

        v_carga_safx07 VARCHAR2 ( 30 );
        v_carga_safx08 VARCHAR2 ( 30 );
        v_carga_safx03 VARCHAR2 ( 30 );
        v_carga_safx301 VARCHAR2 ( 30 );
        v_carga_safx112 VARCHAR2 ( 30 );
    BEGIN
        EXECUTE IMMEDIATE 'SELECT COD_ESTAB, TIPO FROM ' || p_tab_partition || ' WHERE ROW_INI = :1 AND ROW_END = :2'
                       INTO v_cod_estab
                          , v_tipo
            USING p_part_ini
                , p_part_fim;

        dbms_output.put_line ( '[COD_ESTAB]:' || v_cod_estab );

        vg_module := 'DPSP_CARGA_PS_NF_' || v_cod_estab;

        dbms_application_info.set_module ( vg_module
                                         , v_proc_name );

        v_txt_basico :=
               '('''
            || TO_CHAR ( pdt_ini
                       , 'YYYYMMDD' )
            || ''','''
            || TO_CHAR ( pdt_fim
                       , 'YYYYMMDD' )
            || ''','''
            || pcod_empresa
            || ''',''';

        ----------------------------------------
        BEGIN
            --=======================
            v_status := 'A';
            v_safx_name := 'CARGA';
            dbms_application_info.set_module ( vg_module
                                             , v_proc_name || ' [' || v_status || '] [' || v_safx_name || ']' );
            --=======================

            v_txt_entrada :=
                   'BEGIN MSAFI.PRC_MSAF_PS_NF_ENTRADA('''
                || TO_CHAR ( pdt_ini
                           , 'YYYYMMDD' )
                || ''','''
                || TO_CHAR ( pdt_fim
                           , 'YYYYMMDD' )
                || '''';

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

            v_txt_entrada := v_txt_entrada || ',P_COD_EMPRESA=>''' || pcod_empresa || '''';

            v_txt_entrada := v_txt_entrada || ',P_COD_ESTAB=>''' || v_cod_estab || '''';

            v_txt_entrada := v_txt_entrada || '); END;';

            EXECUTE IMMEDIATE v_txt_entrada;

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
                    || v_txt_entrada;

                raise_application_error ( -20001
                                        , v_msg_erro );
        END;
    END exec_nf_ent;

    PROCEDURE exec_nf_sai ( p_part_ini INTEGER
                          , p_part_fim INTEGER
                          , p_proc_instance VARCHAR2
                          , pcod_empresa VARCHAR2
                          , pdt_ini DATE
                          , pdt_fim DATE
                          , p_tab_partition IN VARCHAR2
                          , v_data_exec IN DATE
                          , p_uso_consumo VARCHAR2
                          , p_cagadas VARCHAR2
                          , p_vira_ignora_ps VARCHAR2
                          , p_carga_auditoria VARCHAR2
                          , v_c_safx07 VARCHAR2
                          , v_c_safx08 VARCHAR2
                          , v_c_safx112 VARCHAR2
                          , v_c_safx116 VARCHAR2
                          , v_c_safx117 VARCHAR2
                          , v_c_safx119 VARCHAR2 )
    IS
        v_proc_name VARCHAR2 ( 30 ) := 'EXEC_NF_SAI';
        v_status CHAR := '';
        v_safx_name VARCHAR2 ( 100 ) := '';
        v_msg_erro VARCHAR2 ( 4000 ) := '';

        v_txt_basico VARCHAR2 ( 256 ) := '';
        v_txt_nf VARCHAR2 ( 1024 ) := '';
        v_calc CHAR := 'N';

        v_cod_estab VARCHAR2 ( 6 );
        v_tipo VARCHAR2 ( 1 );

        v_txt_saida VARCHAR2 ( 4000 ) := '';

        --V_CARGA_SAFX07  VARCHAR2(32);
        --V_CARGA_SAFX08  VARCHAR2(32);
        --V_CARGA_SAFX112 VARCHAR2(32);
        --V_CARGA_SAFX116 VARCHAR2(32);
        --V_CARGA_SAFX117 VARCHAR2(32);
        --V_CARGA_SAFX119 VARCHAR2(32);

        v_s_vira_uso_consumo VARCHAR2 ( 32 );
        v_s_vira_cagadas VARCHAR2 ( 32 );
        v_s_vira_ignora_ps VARCHAR2 ( 32 );
        v_s_carga_auditoria VARCHAR2 ( 32 );
    BEGIN
        EXECUTE IMMEDIATE 'SELECT COD_ESTAB, TIPO FROM ' || p_tab_partition || ' WHERE ROW_INI = :1 AND ROW_END = :2'
                       INTO v_cod_estab
                          , v_tipo
            USING p_part_ini
                , p_part_fim;

        dbms_output.put_line ( '[COD_ESTAB]:' || v_cod_estab );

        vg_module := 'DPSP_CARGA_PS_NF_' || v_cod_estab;

        dbms_application_info.set_module ( vg_module
                                         , v_proc_name );

        v_txt_basico :=
               '('''
            || TO_CHAR ( pdt_ini
                       , 'YYYYMMDD' )
            || ''','''
            || TO_CHAR ( pdt_fim
                       , 'YYYYMMDD' )
            || ''','''
            || pcod_empresa
            || ''',''';

        ----------------------------------------
        BEGIN
            --=======================
            v_status := 'B';
            v_safx_name := 'CARGA';
            dbms_application_info.set_module ( vg_module
                                             , v_proc_name || ' [' || v_status || '] [' || v_safx_name || ']' );
            --=======================

            v_txt_saida :=
                   'BEGIN MSAFI.PRC_MSAF_PS_NF_SAIDA('''
                || TO_CHAR ( pdt_ini
                           , 'YYYYMMDD' )
                || ''','''
                || TO_CHAR ( pdt_fim
                           , 'YYYYMMDD' )
                || '''';

            --V_CARGA_SAFX07  := ',P_CARGA_SAFX07=>' || CASE WHEN V_C_SAFX07 = 'S' THEN '1' ELSE '0' END;
            --V_CARGA_SAFX08  := ',P_CARGA_SAFX08=>' || CASE WHEN V_C_SAFX08 = 'S' THEN '1' ELSE '0' END;
            --V_CARGA_SAFX112 := ',P_CARGA_SAFX112=>' || CASE WHEN V_C_SAFX112 = 'S' THEN '1' ELSE '0' END;
            --V_CARGA_SAFX116 := ',P_CARGA_SAFX116=>' || CASE WHEN V_C_SAFX116 = 'S' THEN '1' ELSE '0' END;
            --V_CARGA_SAFX117 := ',P_CARGA_SAFX117=>' || CASE WHEN V_C_SAFX117 = 'S' THEN '1' ELSE '0' END;
            --V_CARGA_SAFX119 := ',P_CARGA_SAFX119=>' || CASE WHEN V_C_SAFX119 = 'S' THEN '1' ELSE '0' END;

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

            v_txt_saida := v_txt_saida || ',P_COD_ESTAB=>''' || v_cod_estab || '''';

            v_txt_saida := v_txt_saida || ',P_COD_EMPRESA=>''' || pcod_empresa || '''';
            v_txt_saida := v_txt_saida || '); END;';

            EXECUTE IMMEDIATE v_txt_saida;

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
                    || v_txt_saida;

                raise_application_error ( -20001
                                        , v_msg_erro );
        END;
    END exec_nf_sai;

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
        lib_proc.add_tipo ( vs_mproc_id
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
                             , vs_mproc_id AS "NUM_PROCESSO"
                             , vs_mcod_usuario AS "NOME_USUARIO"
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

    FUNCTION create_tab_partition ( vp_proc_id IN VARCHAR2
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
                                     , vs_mcod_usuario );

        IF ( v_tab_part = 'ERRO' ) THEN
            raise_application_error ( -20001
                                    , '!ERRO CREATE_TAB_PARTITION!' );
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

    FUNCTION executar ( pcod_empresa VARCHAR2
                      , pdt_ini DATE
                      , pdt_fim DATE
                      , pthread VARCHAR2
                      , flg_nf_ent CHAR
                      , flg_nf_sai CHAR
                      , pcod_estado VARCHAR2
                      , pcod_estab lib_proc.vartab )
        RETURN INTEGER
    IS
        mdesc VARCHAR2 ( 4000 );
        v_count NUMBER := 0;
        p_proc_instance VARCHAR2 ( 30 );
        v_tab_part VARCHAR2 ( 30 );
        v_data_exec DATE;
    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS= '',.'' ';

        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_LANGUAGE = ''Portuguese'' ';

        --Performar em caso de cÛdigos repetitivos no mesmo plano de execuÁ„o
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING = FORCE';

        --Recuperar a empresa para o plano de execuÁ„o caso n„o esteja sendo executado pelo diretamente na tela do Mastersaf
        lib_parametros.salvar ( 'EMPRESA'
                              , NVL ( vs_mcod_empresa, msafi.dpsp.v_empresa ) );

        vs_mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        vs_mcod_usuario := lib_parametros.recuperar ( 'USUARIO' );
        mdesc := lib_parametros.recuperar ( 'PDESC' );

        IF vs_mcod_usuario IS NULL THEN
            lib_parametros.salvar ( 'USUARIO'
                                  , 'AUTOMATICO' );
            vs_mcod_usuario := lib_parametros.recuperar ( 'USUARIO' );
        END IF;

        v_count := pcod_estab.COUNT;

        --InformaÁıes as execuÁıes que foram feitas via job Scheduler, PROC ou Bloco AnÙnimo do PLSQL
        IF vs_mcod_usuario = 'AUTOMATICO' THEN
            mdesc :=
                   '<< ExecuÁ„o via Job Scheduler / PL SQL Block >>'
                || CHR ( 10 )
                || --
                  'Empresa: '
                || pcod_empresa
                || CHR ( 10 )
                || --
                  'Data Inicial: '
                || pdt_ini
                || CHR ( 10 )
                || --
                  'Data Final: '
                || pdt_fim
                || CHR ( 10 )
                || --
                  'Qtde de ExecuÁıes em Paralelo: '
                || pthread
                || CHR ( 10 )
                || --
                  'Carregar NFs Entrada: '
                || ( CASE WHEN flg_nf_ent = 'S' THEN 'SIM' ELSE 'N√O' END )
                || CHR ( 10 )
                || --
                  'Carregar NFs SaÌda: '
                || ( CASE WHEN flg_nf_sai = 'S' THEN 'SIM' ELSE 'N√O' END )
                || CHR ( 10 )
                || --
                  'UF: '
                || ( CASE WHEN pcod_estado = '%' THEN 'Todas as UFs' ELSE pcod_estado END )
                || CHR ( 10 )
                || --
                  'Qtde de Estabelecimentos: '
                || v_count
                || '';
        ELSE
            -- Alterar a descriÁ„o caso seja selecionado mais que 5 estabelecimentos, para n„o ter um texto muito grande
            -- e prejudicar  a visualizaÁ„o dos histÛricos.
            IF v_count > 5 THEN
                mdesc :=
                       'Empresa: '
                    || pcod_empresa
                    || CHR ( 10 )
                    || --
                      'Data Inicial: '
                    || pdt_ini
                    || CHR ( 10 )
                    || --
                      'Data Final: '
                    || pdt_fim
                    || CHR ( 10 )
                    || --
                      'Qtde de ExecuÁıes em Paralelo: '
                    || pthread
                    || CHR ( 10 )
                    || --
                      'Carregar NFs Entrada: '
                    || ( CASE WHEN flg_nf_ent = 'S' THEN 'SIM' ELSE 'N√O' END )
                    || CHR ( 10 )
                    || --
                      'Carregar NFs SaÌda: '
                    || ( CASE WHEN flg_nf_sai = 'S' THEN 'SIM' ELSE 'N√O' END )
                    || CHR ( 10 )
                    || --
                      'UF: '
                    || ( CASE WHEN pcod_estado = '%' THEN 'Todas as UFs' ELSE pcod_estado END )
                    || CHR ( 10 )
                    || --
                      'Qtde de Estabelecimentos: '
                    || v_count
                    || '';
            END IF; -- V_COUNT
        END IF; -- VS_MCOD_USUARIO = PCOD_USUARIO

        -- CriaÁ„o: Processo
        vs_mproc_id :=
            lib_proc.new ( psp_nome => $$plsql_unit
                         , pdescricao => mdesc );
        COMMIT;

        v_data_exec := SYSDATE;

        loga ( '<<' || mnm_cproc || '>>'
             , FALSE );
        loga ( '---INICIO DO PROCESSAMENTO---'
             , FALSE );

        dbms_application_info.set_module ( $$plsql_unit
                                         , 'PROC_ID: ' || vs_mproc_id );

        loga (    'Data execuÁ„o: '
               || TO_CHAR ( v_data_exec
                          , 'DD/MM/YYYY HH24:MI:SS' )
             , FALSE );

        loga ( 'Usu·rio: ' || vs_mcod_usuario
             , FALSE );
        loga ( 'Empresa: ' || pcod_empresa
             , FALSE );
        loga ( 'PerÌodo: ' || pdt_ini || ' - ' || pdt_fim
             , FALSE );
        loga ( 'Threads: ' || pthread
             , FALSE );
        loga ( 'UF: ' || ( CASE WHEN pcod_estado = '%' THEN 'Todas as UFs' ELSE pcod_estado END )
             , FALSE );
        loga ( 'Qtde Estabs: ' || v_count
             , FALSE );

        SELECT ROUND ( dbms_random.VALUE ( 10000000000000
                                         , 999999999999999 ) )
          INTO p_proc_instance
          FROM DUAL;

        v_tab_part :=
            create_tab_partition ( p_proc_instance
                                 , pcod_estab );

        loga ( '----------------------------------------'
             , FALSE );
        loga ( '>> PROC INSERT: ' || p_proc_instance
             , FALSE );
        loga ( '>> TAB_PART: ' || v_tab_part
             , FALSE );
        loga ( '----------------------------------------'
             , FALSE );

        exec_nf_parallel ( p_proc_instance
                         , pthread
                         , pdt_ini
                         , pdt_fim
                         , flg_nf_ent
                         , flg_nf_sai
                         , v_tab_part
                         , v_data_exec );

        loga ( '---FIM DO PROCESSAMENTO---'
             , FALSE );

        lib_proc.close ( );
        COMMIT;
        RETURN vs_mproc_id;
    EXCEPTION
        WHEN OTHERS THEN
            loga ( SQLERRM
                 , FALSE );

            --ENVIAR EMAIL DE ERRO-------------------------------------------
            envia_email ( vs_mcod_empresa
                        , pdt_ini
                        , pdt_fim
                        , SQLERRM
                        , 'E'
                        , v_data_exec );
            -----------------------------------------------------------------

            lib_proc.close ( );
            COMMIT;
            raise_application_error ( -20001
                                    , SQLERRM );
    END;
END dpsp_carga_ps_nf_cproc;
/
SHOW ERRORS;
