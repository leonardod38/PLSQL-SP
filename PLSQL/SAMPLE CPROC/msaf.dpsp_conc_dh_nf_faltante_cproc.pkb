Prompt Package Body DPSP_CONC_DH_NF_FALTANTE_CPROC;
--
-- DPSP_CONC_DH_NF_FALTANTE_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_conc_dh_nf_faltante_cproc
IS
    mproc_id NUMBER;
    mcod_usuario usuario_estab.cod_usuario%TYPE;
    mcod_empresa estabelecimento.cod_empresa%TYPE;
    v_class VARCHAR2 ( 1 ) := 'A';

    vg_module VARCHAR2 ( 60 ) := '';

    --Tipo, Nome e DescriÁ„o do Customizado
    mnm_tipo VARCHAR2 ( 100 ) := 'AutomatizaÁ„o';
    mnm_cproc VARCHAR2 ( 100 ) := 'RelatÛrio Cupons Fiscais faltantes entre Datahub e Mastersaf DW';
    mds_cproc VARCHAR2 ( 100 )
        := 'RelatÛrio para verificar cupons fiscais faltantes entre os sistemas Datahub e Mastersaf DW';

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

        --PPERIODO
        lib_proc.add_param ( pparam => pstr
                           , ptitulo => 'Data Inicial'
                           , --P_DT_INI
                            ptipo => 'DATE'
                           , pcontrole => 'TEXTBOX'
                           , pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => 'DD/MM/YYYY' );

        lib_proc.add_param ( pparam => pstr
                           , ptitulo => 'Data Final'
                           , --P_DT_FIM
                            ptipo => 'VARCHAR2'
                           , pcontrole => 'COMBOBOX'
                           , pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => '##########'
                           , pvalores => v_sel_data_fim );

        lib_proc.add_param ( pparam => pstr
                           , ptitulo => 'Todas as lojas'
                           , --P_TODOS_ESTAB
                            ptipo => 'VARCHAR2'
                           , pcontrole => 'CHECKBOX'
                           , pmandatorio => 'N'
                           , pdefault => 'S'
                           , pmascara => NULL );

        lib_proc.add_param (
                             pparam => pstr
                           , ptitulo => 'Analisar'
                           , -- P_BUSCA
                            ptipo => 'VARCHAR2'
                           , pcontrole => 'COMBOBOX'
                           , pmandatorio => 'S'
                           , pdefault => '1'
                           , pmascara => '#########################################'
                           , pvalores =>    'SELECT 1, ''1-Cupom DH faltante MSAF/Cupom MSAF faltante DH'' from dual ' --
                                         || ' union all SELECT 2, ''2-Cupom DH faltante MSAF'' from dual ' --
                                         || ' union all SELECT 3, ''3-Cupom MSAF faltante DH'' from dual ' --
                                         || ' ORDER BY 1'
        );

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
                           , pvalores =>    'SELECT 1, ''1-ID Cupons'' FROM DUAL UNION ALL '
                                         || --
                                           'SELECT 2, ''2-Lojas'' FROM DUAL '
                           , phabilita => ' :6 = ''S'''
        );

        lib_proc.add_param ( pparam => pstr
                           , ptitulo => 'Qtde de ExecuÁıes em Paralelo'
                           , --P_NUM_THREAD
                            ptipo => 'NUMBER'
                           , pcontrole => 'TEXTBOX'
                           , pmandatorio => 'S'
                           , pdefault => '20'
                           , pmascara => '####'
                           , phabilita => ' :6 = ''S''' );

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
                                         || ''' AND COD_ESTADO LIKE :5 AND :3 = ''N'' ORDER BY TIPO, COD_ESTAB'
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

        v_txt_email := v_txt_email || CHR ( 13 ) || ' - Num Processo: ' || mproc_id;
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
        v_txt_email := v_txt_email || CHR ( 13 ) || ' - Executado por: ' || mcod_usuario;
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

    PROCEDURE load_gtt_dh ( p_cod_empresa VARCHAR2
                          , p_dt_ini DATE
                          , p_cod_estab VARCHAR2 )
    IS
        v_count NUMBER := 0;
        v_periodo_dia NUMBER
            := TO_CHAR ( p_dt_ini
                       , 'YYYYMMDD' );
    BEGIN
        loga ( '[INICIAR LOAD_GTT_DH]' );

        dbms_application_info.set_module ( $$plsql_unit
                                         , mproc_id || ' FULL LJ:' || p_cod_estab );

        FOR c_ins IN ( SELECT DISTINCT a.*
                         FROM (SELECT /*+ DRIVING_SITE(PCT) */
                                     DENSE_RANK ( )
                                          OVER ( PARTITION BY pct.codigo_loja
                                                            , pct.data_transacao
                                                            , pct.numero_componente
                                                            , pct.numero_cupom
                                                 ORDER BY
                                                     pfe.status_proc_1 DESC
                                                   , pfe.nsu_transacao DESC
                                                   , pfe.ROWID DESC )
                                          AS RANK
                                    , p_cod_empresa AS cod_empresa
                                    , pct.codigo_loja
                                    , TRIM ( pct.numero_componente ) AS numero_componente
                                    , TRIM ( pct.numero_cupom ) AS numero_cupom
                                    , TO_DATE ( pct.data_transacao
                                              , 'YYYYMMDD' )
                                          AS data_transacao
                                    , SUBSTR ( TRIM ( pct.chave_execucao )
                                             , 23
                                             , 9 )
                                          num_equip
                                    , CASE
                                          WHEN SUBSTR ( pct.chave_execucao
                                                      , 21
                                                      , 2 ) = '59' THEN
                                              '59'
                                          WHEN SUBSTR ( pct.chave_execucao
                                                      , 21
                                                      , 2 ) = '65' THEN
                                              '65'
                                          WHEN unf.cod_estado = 'SP'
                                           AND pfe.modelo_ecf = 'SAT' THEN
                                              '59'
                                          WHEN pct.chave_acesso_nfe IS NULL
                                           AND pct.chave_execucao IS NULL THEN
                                              '2D'
                                          ELSE
                                              '65'
                                      END
                                          AS modelo_ecf
                                    , pct.chave_execucao
                                    , pct.chave_acesso_nfe
                                    , pfe.status_proc_1
                                    , pfe.data_proc_1
                                    , pct.nsu_transacao
                                    , pct.tipo_venda
                                    , --Campos no Mastersaf ------------------
                                      est2.cod_estab
                                    , --
                                       ( CASE
                                            WHEN ( TRIM ( pct.chave_acesso_nfe ) IS NOT NULL
                                               OR TRIM ( pct.chave_execucao ) IS NOT NULL ) --
                                             AND unf.cod_estado = 'SP' --
                                                                      THEN
                                                TO_CHAR ( pct.numero_cupom
                                                        , 'FM000000' )
                                            WHEN ( TRIM ( pct.chave_acesso_nfe ) IS NOT NULL
                                               OR TRIM ( pct.chave_execucao ) IS NOT NULL ) --
                                             AND unf.cod_estado <> 'SP' --
                                             AND TRIM ( pct.data_transacao ) > '20170820' --
                                                                                         THEN
                                                TO_CHAR ( pct.numero_cupom
                                                        , 'FM000000000' )
                                            ELSE
                                                TO_CHAR ( pct.numero_cupom
                                                        , 'FM000000' )
                                        END )
                                          num_docfis
                                    , --
                                      TO_CHAR ( pct.numero_cupom
                                              , 'FM000000' )
                                          num_coo
                                    , unf.cod_estado
                                    , --
                                      CASE
                                          WHEN ( TRIM ( pct.chave_acesso_nfe ) IS NOT NULL
                                             OR TRIM ( pct.chave_execucao ) IS NOT NULL
                                             OR ( pfe.modelo_ecf = 'SAT'
                                             AND unf.cod_estado = 'SP' ) ) THEN
                                              'CUPOM ELETRONICO'
                                          ELSE
                                              'CUPOM FISCAL'
                                      END
                                          origem
                                    , pct.mensagem_10
                                 FROM msafi.p2k_cab_transacao pct
                                    , msafi.p2k_fechamento pfe
                                    , msafi.dsp_estabelecimento est
                                    , msaf.estabelecimento est2
                                    , msaf.estado unf
                                WHERE 1 = 1
                                  AND est.cod_estab = DECODE ( p_cod_estab, '%', est.cod_estab, p_cod_estab )
                                  AND pct.data_transacao = v_periodo_dia
                                  --
                                  --  AND PCT.TIPO_VENDA IN (1, 7, 9)
                                  AND pct.nsu_transacao = (SELECT MAX ( nsu_transacao )
                                                             FROM msafi.p2k_cab_transacao spct
                                                            WHERE spct.codigo_loja = pct.codigo_loja
                                                              AND spct.data_transacao = v_periodo_dia
                                                              AND spct.data_transacao = pct.data_transacao
                                                              AND spct.numero_componente = pct.numero_componente
                                                              AND spct.numero_cupom = pct.numero_cupom)
                                  --DSP_ESTABELECIMENTO
                                  AND est.cod_empresa = p_cod_empresa
                                  AND est.codigo_loja = pct.codigo_loja --4DG
                                  --ESTABELECIMENTO
                                  AND est2.cod_empresa = est.cod_empresa
                                  AND est2.cod_estab = est.cod_estab
                                  AND est2.cod_estab NOT LIKE 'DPSP%'
                                  --ESTADO-UF
                                  AND est2.ident_estado = unf.ident_estado
                                  --P2K_FECHAMENTO
                                  AND pfe.codigo_loja(+) = pct.codigo_loja
                                  AND pfe.data_transacao(+) = pct.data_transacao
                                  AND pfe.data_transacao(+) = v_periodo_dia
                                  AND pfe.numero_componente(+) = pct.numero_componente
                                  --AND PFE.STATUS_PROC_1(+) = 'PR'

                                  -- regra de filtro das lojas ecommerce
                                  AND ( CASE
                                           WHEN pct.numero_componente = 99
                                            AND pct.mensagem_10 IN ( 'D'
                                                                   , 'E' ) THEN
                                               0
                                           ELSE
                                               1
                                       END ) = 1) a
                        WHERE a.RANK = 1 ) LOOP
            INSERT /*+ APPEND */
                  INTO  msafi.dpsp_conc_nf_falt_dh_gtt ( cod_empresa
                                                       , codigo_loja
                                                       , numero_componente
                                                       , numero_cupom
                                                       , data_transacao
                                                       , num_equip
                                                       , modelo_ecf
                                                       , chave_execucao
                                                       , chave_acesso_nfe
                                                       , status_proc_1
                                                       , data_proc_1
                                                       , nsu_transacao
                                                       , tipo_venda
                                                       , cod_estab
                                                       , num_docfis
                                                       , num_coo
                                                       , cod_estado
                                                       , origem
                                                       , mensagem_10 )
                 VALUES ( c_ins.cod_empresa
                        , c_ins.codigo_loja
                        , c_ins.numero_componente
                        , c_ins.numero_cupom
                        , c_ins.data_transacao
                        , c_ins.num_equip
                        , c_ins.modelo_ecf
                        , c_ins.chave_execucao
                        , c_ins.chave_acesso_nfe
                        , c_ins.status_proc_1
                        , c_ins.data_proc_1
                        , c_ins.nsu_transacao
                        , c_ins.tipo_venda
                        , c_ins.cod_estab
                        , c_ins.num_docfis
                        , c_ins.num_coo
                        , c_ins.cod_estado
                        , c_ins.origem
                        , c_ins.mensagem_10 );

            --OBS: TABELAS TEMPORARIAS (GLOBAL TEMPORARY) CARREGADAS POR CONSULTAS COM DBLINK
            --DEVEM SER COMMITADAS DURANTE O LOOP CASO O CONTR¡RIO SER√O TRUNCADAS.
            COMMIT;
        END LOOP;

        COMMIT;

        SELECT COUNT ( 1 )
          INTO v_count
          FROM msafi.dpsp_conc_nf_falt_dh_gtt;

        loga ( 'Qtd cupons no periodo: ' || v_count
             , FALSE );

        loga ( '[FIM LOAD_GTT_DH]' );
    END load_gtt_dh;

    PROCEDURE load_falt_dh ( p_cod_empresa VARCHAR2
                           , v_periodo_dia DATE
                           , v_dt_first DATE
                           , p_cod_estab VARCHAR2
                           , v_proc_id NUMBER
                           , v_data_exec DATE
                           , v_usuario VARCHAR2 )
    IS
        v_count NUMBER := 0;

        v_script VARCHAR2 ( 10000 ) := '';
    BEGIN
        loga ( '[INICIAR LOAD_FALT_DH]' );

        dbms_application_info.set_module ( $$plsql_unit
                                         , mproc_id || ' FALT LJ:' || p_cod_estab );

        v_script := v_script || ' DECLARE ';
        v_script := v_script || ' V_COUNT NUMBER := 0; ';
        v_script := v_script || ' BEGIN ';
        v_script := v_script || '  ';
        v_script := v_script || ' FOR C_INS IN (SELECT ';
        v_script := v_script || ' COD_EMPRESA, ';
        v_script := v_script || ' CODIGO_LOJA, ';
        v_script := v_script || ' NUMERO_COMPONENTE, ';
        v_script := v_script || ' NUMERO_CUPOM, ';
        v_script := v_script || ' DATA_TRANSACAO, ';
        v_script := v_script || ' NUM_EQUIP, ';
        v_script := v_script || ' MODELO_ECF, ';
        v_script := v_script || ' CHAVE_EXECUCAO, ';
        v_script := v_script || ' CHAVE_ACESSO_NFE, ';
        v_script := v_script || ' STATUS_PROC_1, ';
        v_script := v_script || ' DATA_PROC_1, ';
        v_script := v_script || ' NSU_TRANSACAO, ';
        v_script := v_script || ' TIPO_VENDA, ';
        v_script := v_script || ' COD_ESTAB, ';
        v_script := v_script || ' NUM_DOCFIS, ';
        v_script := v_script || ' NUM_COO, ';
        v_script := v_script || ' COD_ESTADO, ';
        v_script := v_script || ' ORIGEM, ';
        v_script := v_script || ' MENSAGEM_10 ';
        v_script := v_script || ' FROM MSAFI.DPSP_CONC_NF_FALT_DH_GTT X ';
        v_script := v_script || ' WHERE 1 = 1 ';
        v_script := v_script || ' AND X.COD_EMPRESA = ''' || p_cod_empresa || ''' ';
        v_script := v_script || ' AND X.COD_ESTAB = ';
        v_script := v_script || ' DECODE(''' || p_cod_estab || ''', ''%'', X.COD_ESTAB, ''' || p_cod_estab || ''') ';
        v_script := v_script || ' AND X.DATA_TRANSACAO = ''' || v_periodo_dia || ''' ';
        --    V_SCRIPT := V_SCRIPT || ' AND X.DATA_TRANSACAO BETWEEN ''' || V_DT_INI ||
        --                ''' AND ''' || V_DT_FIM || ''' ';
        v_script := v_script || '  ';
        v_script := v_script || ' AND NOT EXISTS ';
        v_script := v_script || ' (SELECT ''Y'' ';
        v_script := v_script || ' FROM MSAF.X993_CAPA_CUPOM_ECF ';
        v_script := v_script || ' PARTITION FOR(''' || v_dt_first || ''')  ';
        v_script := v_script || ' CAPA, ';
        v_script := v_script || ' MSAF.X2087_EQUIPAMENTO_ECF X2087 ';
        v_script := v_script || ' WHERE 1 = 1 ';
        v_script := v_script || '  ';
        v_script := v_script || ' AND CAPA.COD_EMPRESA = X.COD_EMPRESA ';
        v_script := v_script || ' AND CAPA.DATA_EMISSAO = X.DATA_TRANSACAO ';
        v_script := v_script || ' AND CAPA.DATA_EMISSAO = ''' || v_periodo_dia || ''' ';
        --    V_SCRIPT := V_SCRIPT || ' AND CAPA.DATA_EMISSAO BETWEEN ''' || V_DT_INI ||
        --                ''' AND ';
        --    V_SCRIPT := V_SCRIPT || ' ''' || V_DT_FIM || ''' ';
        v_script := v_script || '  ';
        v_script := v_script || ' AND CAPA.IDENT_CAIXA_ECF = X2087.IDENT_CAIXA_ECF ';
        v_script := v_script || '  ';
        v_script := v_script || ' AND CAPA.COD_EMPRESA = X.COD_EMPRESA ';
        v_script := v_script || ' AND CAPA.COD_ESTAB = X.COD_ESTAB ';
        v_script := v_script || ' AND X2087.COD_CAIXA_ECF = X.NUMERO_COMPONENTE ';
        v_script := v_script || ' AND CAPA.NUM_COO = X.NUM_COO) ';
        v_script := v_script || '  ';
        v_script := v_script || ' AND NOT EXISTS ';
        v_script := v_script || ' (SELECT ''Y'' ';
        v_script := v_script || ' FROM MSAF.X07_DOCTO_FISCAL ';
        v_script := v_script || ' PARTITION FOR(''' || v_dt_first || ''')  ';
        v_script := v_script || ' CAPA ';
        v_script := v_script || ' WHERE 1 = 1 ';
        v_script := v_script || '  ';
        v_script := v_script || ' AND CAPA.COD_EMPRESA = X.COD_EMPRESA ';
        v_script := v_script || ' AND CAPA.DATA_FISCAL = X.DATA_TRANSACAO ';
        v_script := v_script || ' AND CAPA.DATA_EMISSAO = ''' || v_periodo_dia || ''' ';
        --  V_SCRIPT := V_SCRIPT || ' AND CAPA.DATA_FISCAL BETWEEN ''' || V_DT_INI ||
        --              ''' AND ';
        --  V_SCRIPT := V_SCRIPT || ' ''' || V_DT_FIM || ''' ';
        v_script := v_script || ' AND CAPA.MOVTO_E_S = ''9'' ';
        v_script := v_script || ' AND CAPA.NORM_DEV = ''1'' ';
        v_script := v_script || '  ';
        v_script := v_script || ' AND CAPA.COD_EMPRESA = X.COD_EMPRESA ';
        v_script := v_script || ' AND CAPA.COD_ESTAB = X.COD_ESTAB ';
        v_script := v_script || ' AND CAPA.SERIE_DOCFIS = X.NUMERO_COMPONENTE ';
        v_script := v_script || ' AND CAPA.NUM_DOCFIS = X.NUM_DOCFIS) ';
        v_script := v_script || '  ';
        v_script := v_script || ' ) LOOP ';
        v_script := v_script || '  ';
        v_script := v_script || ' INSERT /*+ APPEND */ ';
        v_script := v_script || ' INTO MSAFI.DPSP_CONC_NF_FALT_DH ';
        v_script := v_script || ' (COD_EMPRESA, ';
        v_script := v_script || ' CODIGO_LOJA, ';
        v_script := v_script || ' NUMERO_COMPONENTE, ';
        v_script := v_script || ' NUMERO_CUPOM, ';
        v_script := v_script || ' DATA_TRANSACAO, ';
        v_script := v_script || ' NUM_EQUIP, ';
        v_script := v_script || ' MODELO_ECF, ';
        v_script := v_script || ' CHAVE_EXECUCAO, ';
        v_script := v_script || ' CHAVE_ACESSO_NFE, ';
        v_script := v_script || ' STATUS_PROC_1, ';
        v_script := v_script || ' DATA_PROC_1, ';
        v_script := v_script || ' NSU_TRANSACAO, ';
        v_script := v_script || ' TIPO_VENDA, ';
        v_script := v_script || ' COD_ESTAB, ';
        v_script := v_script || ' NUM_DOCFIS, ';
        v_script := v_script || ' NUM_COO, ';
        v_script := v_script || ' COD_ESTADO, ';
        v_script := v_script || ' ORIGEM, ';
        v_script := v_script || ' PROC_ID, ';
        v_script := v_script || ' DATA_EXECUCAO, ';
        v_script := v_script || ' USR_LOGIN, ';
        v_script := v_script || ' MENSAGEM_10) ';
        v_script := v_script || '  ';
        v_script := v_script || ' VALUES ';
        v_script := v_script || ' (C_INS.COD_EMPRESA, ';
        v_script := v_script || ' C_INS.CODIGO_LOJA, ';
        v_script := v_script || ' C_INS.NUMERO_COMPONENTE, ';
        v_script := v_script || ' C_INS.NUMERO_CUPOM, ';
        v_script := v_script || ' C_INS.DATA_TRANSACAO, ';
        v_script := v_script || ' C_INS.NUM_EQUIP, ';
        v_script := v_script || ' C_INS.MODELO_ECF, ';
        v_script := v_script || ' C_INS.CHAVE_EXECUCAO, ';
        v_script := v_script || ' C_INS.CHAVE_ACESSO_NFE, ';
        v_script := v_script || ' C_INS.STATUS_PROC_1, ';
        v_script := v_script || ' C_INS.DATA_PROC_1, ';
        v_script := v_script || ' C_INS.NSU_TRANSACAO, ';
        v_script := v_script || ' C_INS.TIPO_VENDA, ';
        v_script := v_script || ' C_INS.COD_ESTAB, ';
        v_script := v_script || ' C_INS.NUM_DOCFIS, ';
        v_script := v_script || ' C_INS.NUM_COO, ';
        v_script := v_script || ' C_INS.COD_ESTADO, ';
        v_script := v_script || ' C_INS.ORIGEM, ';
        v_script := v_script || ' ''' || v_proc_id || ''', ';
        v_script := v_script || ' ''' || v_data_exec || ''', ';
        v_script := v_script || ' ''' || v_usuario || ''', ';
        v_script := v_script || ' C_INS.MENSAGEM_10); ';
        v_script := v_script || '  ';
        v_script := v_script || ' V_COUNT := V_COUNT + 1; ';
        v_script := v_script || ' IF V_COUNT >= 10000 THEN ';
        v_script := v_script || ' COMMIT; ';
        v_script := v_script || ' V_COUNT := 0; ';
        v_script := v_script || ' END IF; ';
        v_script := v_script || '  ';
        v_script := v_script || ' END LOOP; ';
        v_script := v_script || ' COMMIT; ';
        v_script := v_script || ' END; ';

        BEGIN
            EXECUTE IMMEDIATE v_script;

            COMMIT;
        EXCEPTION
            WHEN OTHERS THEN
                raise_application_error ( -20001
                                        , SQLERRM || '>>' || v_script );
        END;

        COMMIT;

        SELECT COUNT ( 1 )
          INTO v_count
          FROM msafi.dpsp_conc_nf_falt_dh
         WHERE proc_id = v_proc_id
           AND data_transacao = v_periodo_dia;

        loga ( 'Qtd faltante no periodo: ' || v_count
             , FALSE );

        loga ( '[FIM LOAD_FALT_DH]' );
    END load_falt_dh;

    PROCEDURE load_excel_dh ( p_cod_empresa VARCHAR2
                            , v_dt_ini DATE
                            , v_dt_fim DATE
                            , v_dt_first DATE
                            , p_cod_estab VARCHAR2
                            , p_carregar VARCHAR2
                            , v_data_exec DATE
                            , v_proc_id NUMBER )
    IS
        v_text01 VARCHAR2 ( 10000 );
    BEGIN
        loga ( '[INICIAR LOAD_EXCEL_DH]' );

        FOR c
            IN ( SELECT DISTINCT
                        cod_empresa
                      , codigo_loja
                      , numero_componente
                      , numero_cupom
                      , data_transacao
                      , num_equip
                      , modelo_ecf
                      , chave_execucao
                      , chave_acesso_nfe
                      , status_proc_1
                      , TO_CHAR ( data_proc_1
                                , 'DD/MM/YYYY HH24:MI:SS' )
                            data_proc_1
                      , nsu_transacao
                      , tipo_venda
                      , --Campos no Mastersaf ------------------
                        cod_estab
                      , num_docfis
                      , num_coo
                      , cod_estado
                      , origem
                      ,    --ObservaÁ„os de Erros------------------
                            ( CASE
                                 WHEN NVL ( status_proc_1, '-1' ) <> 'PR' THEN 'STATUS_PROC_1 diferente de ''PR'';'
                             END )
                        || ( CASE
                                WHEN tipo_venda NOT IN ( '1'
                                                       , '7'
                                                       , '9' ) THEN
                                    'TIPO_VENDA diferente de 1, 7 e 9;'
                            END )
                        || ( CASE WHEN numero_componente = '99' THEN 'NUMERO_COMPONENTE = 99' END )
                        || ( CASE
                                WHEN x.origem = 'CUPOM FISCAL'
                                 AND tipo_venda = '7' THEN
                                    'CUPOM CANCELADO - TIPO_VENDA  = 7'
                            END )
                            AS observacao
                      , --
                         ( CASE
                              WHEN x.origem = 'CUPOM ELETRONICO' THEN
                                     ' EXEC MSAFI.PRC_MSAF_CUPOM_E( '
                                  || ' P_COD_EMPRESA    => '''
                                  || p_cod_empresa
                                  || ''' '
                                  || --
                                    ' ,P_DATA_INI       => '''
                                  || v_dt_first
                                  || ''' '
                                  || --
                                    ' ,P_DATA_FIM       => '''
                                  || LAST_DAY ( v_dt_first )
                                  || ''' '
                                  || --
                                    ' ,P_COD_ESTAB      => '''
                                  || x.cod_estab
                                  || ''' '
                                  || --
                                    ' ,P_NUMERO_CUPOM   => '''
                                  || numero_cupom
                                  || ''' '
                                  || --
                                    ' ); ' --
                              ELSE
                                     ' EXEC MSAFI.PRC_MSAF_DH_CUPOM( '
                                  || --
                                    ' P_COD_EMPRESA    => '''
                                  || p_cod_empresa
                                  || ''' '
                                  || --
                                    ' ,P_DATA_INI       => '''
                                  || v_dt_first
                                  || ''' '
                                  || --
                                    ' ,P_DATA_FIM       => '''
                                  || LAST_DAY ( v_dt_first )
                                  || ''' '
                                  || --
                                    ' ,P_COD_ESTAB      => '''
                                  || x.cod_estab
                                  || ''' '
                                  || --
                                    ' ,P_NUMERO_CUPOM   => '''
                                  || numero_cupom
                                  || ''' '
                                  || --
                                    ' ); ' --
                          END )
                            recarregar
                      , mensagem_10
                   ----------------------------------------
                   FROM msafi.dpsp_conc_nf_falt_dh x
                  WHERE 1 = 1
                    AND x.cod_empresa = p_cod_empresa
                    AND x.cod_estab = DECODE ( p_cod_estab, '%', x.cod_estab, p_cod_estab )
                    AND x.data_transacao BETWEEN v_dt_ini AND v_dt_fim
                    AND x.proc_id = v_proc_id ) LOOP
            -- INSERIR NA TABELA DE SCRIPTS PARA CARREGAR QUANDO A FLAG ESTIVER SELECIONADO E N√O EXISTIR
            -- OBSERVA«’ES SOBRE A NOTA
            IF p_carregar = 'S'
           AND c.observacao IS NULL THEN
                INSERT INTO msafi.dpsp_conc_nf_falt_dh_script ( cod_empresa
                                                              , cod_estab
                                                              , data_periodo
                                                              , numero_cupom
                                                              , script
                                                              , proc_id
                                                              , data_execucao
                                                              , usr_login )
                     VALUES ( c.cod_empresa
                            , c.cod_estab
                            , v_dt_fim
                            , c.numero_cupom
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
                dsp_planilha.linha ( p_conteudo =>    dsp_planilha.campo ( dsp_planilha.texto ( c.observacao ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( c.origem ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( c.cod_empresa ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( c.codigo_loja ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( c.numero_componente ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( c.mensagem_10 ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( c.numero_cupom ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto (
                                                                                               TO_CHAR (
                                                                                                         c.data_transacao
                                                                                                       , 'DD/MM/YYYY'
                                                                                               )
                                                                          ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( c.num_equip ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( c.modelo_ecf ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( c.chave_execucao ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( c.chave_acesso_nfe ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( c.status_proc_1 ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( c.data_proc_1 ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( c.nsu_transacao ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( c.tipo_venda ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( c.cod_estab ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( c.num_docfis ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( c.num_coo ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( c.cod_estado ) )
                                                   || --
                                                     dsp_planilha.campo ( dsp_planilha.texto ( c.recarregar ) )
                                                   || --
                                                     ''
                                   , p_class => v_class );
            lib_proc.add ( v_text01
                         , ptipo => 1 );

            COMMIT;
        END LOOP;

        loga ( '[FIM LOAD_EXCEL_DH]' );
    END load_excel_dh;

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
          FROM msafi.dpsp_conc_nf_falt_dh_script
         WHERE 1 = 1
           AND proc_id = mproc_id;

        loga ( 'Qtd tabela: ' || v_count
             , FALSE );

        IF v_count = 0 THEN
            loga ( '>> N„o h· Cupons faltantes necessitando/disponÌveis para carga.'
                 , FALSE );
        ELSE
            EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || p_tab_partition            INTO v_qt_grupos;

            loga ( '[INICIAR THREADS]' );

            dbms_application_info.set_module ( $$plsql_unit
                                             , mproc_id || ' FALT CARGA' );

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

            p_task := 'EXEC_CF_' || v_proc;

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
                                                       , 'DPSP_CONC_DH_NF_FALTANTE_CPROC.EXEC_CARGA_IDs'
                                                       , v_qt_grupos
                                                       , --QTDE DE CUPONS
                                                        v_qt_grupos_paralelos
                                                       , --QTDE DE THREADS
                                                        p_task
                                                       , v_parametros );
            ELSIF p_flg_thread = '2' THEN
                msaf.dpsp_chunk_parallel.exec_parallel ( v_proc
                                                       , 'DPSP_CONC_DH_NF_FALTANTE_CPROC.EXEC_CARGA_LOJAS'
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
        v_safx_name VARCHAR2 ( 100 ) := '';
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

        vg_module := 'DPSP_CONC_DH_NF_FALTANTE_' || v_cod_estab;

        dbms_application_info.set_module ( vg_module
                                         , v_proc_name );

        ----------------------------------------
        BEGIN
            --=======================
            v_status := 'ID';
            dbms_application_info.set_module ( vg_module
                                             , v_proc_name || ' [' || v_status || '] [' || v_id_nf || ']' );

            FOR c IN ( SELECT x.script
                         FROM msafi.dpsp_conc_nf_falt_dh_script x
                        WHERE 1 = 1
                          AND x.proc_id = p_proc_id
                          AND x.numero_cupom = v_id_nf
                          AND x.cod_estab = v_cod_estab ) LOOP
                v_txt_nf := 'BEGIN ' || c.script || ' END;';

                EXECUTE IMMEDIATE v_txt_nf;
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

        v_proc_name VARCHAR2 ( 30 ) := 'EXEC_CARGA';
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

        vg_module := 'DPSP_CONC_DH_NF_FALTANTE_' || v_cod_estab;

        dbms_application_info.set_module ( vg_module
                                         , v_proc_name );

        ----------------------------------------
        BEGIN
            --=======================
            v_status := 'A';
            v_safx_name := 'CARGA';
            dbms_application_info.set_module ( vg_module
                                             , v_proc_name || ' [' || v_status || '] [' || v_safx_name || ']' );

            FOR c IN ( SELECT x.script
                         FROM msafi.dpsp_conc_nf_falt_dh_script x
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
        EXECUTE IMMEDIATE 'TRUNCATE TABLE MSAFI.DPSP_CONC_NF_FALT_DH_GTT';

        --Apagar registros com execuÁ„o maior do que 3 dias
        FOR c IN ( SELECT ROWID AS tmp_id
                     FROM msafi.dpsp_conc_nf_falt_dh
                    WHERE data_execucao < SYSDATE - 3 ) LOOP
            DELETE FROM msafi.dpsp_conc_nf_falt_dh
                  WHERE ROWID = c.tmp_id;

            v_count := v_count + 1;

            IF v_count > 10000 THEN
                COMMIT;
                v_count := 0;
            END IF;
        END LOOP;

        FOR c IN ( SELECT ROWID AS tmp_id
                     FROM msafi.dpsp_conc_nf_falt_dh_script
                    WHERE data_execucao < SYSDATE - 3 ) LOOP
            DELETE FROM msafi.dpsp_conc_nf_falt_dh_script
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
                            || '_Carga_DH_Log_Erros.xls'
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
        loga ( '>> Logs de erros gerado.'
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
                                    , '!ERRO CREATE_TAB_PART_LOJAS!' );
        END IF;

        FOR c IN ( SELECT   DISTINCT x.cod_estab
                                   , x.numero_cupom
                       FROM msafi.dpsp_conc_nf_falt_dh_script x
                      WHERE 1 = 1
                        AND x.proc_id = mproc_id
                   ORDER BY x.cod_estab
                          , x.numero_cupom ) LOOP
            v_count := v_count + 1;

            BEGIN
                EXECUTE IMMEDIATE 'INSERT INTO ' || v_tab_part || ' VALUES (:1, :2, :3, :4, :5, :6, :7)'
                    USING c.numero_cupom
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
                    lib_proc.add_log ( 'ERRO N√O TRATADO: ' || dbms_utility.format_error_backtrace
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
            loga ( '!ERRO CREATE_TAB_PART_LOJAS!' );
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

        --Primeiro dia do mÍs para a partiÁ„o
        v_dt_first DATE
            :=   TRUNC ( p_dt_ini )
               - (   TO_NUMBER ( TO_CHAR ( p_dt_ini
                                         , 'DD' ) )
                   - 1 );
    BEGIN
        -- CriaÁ„o: Processo
        mproc_id := lib_proc.new ( psp_nome => $$plsql_unit );
        COMMIT;

        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT="YYYYMMDD"';

        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS= '',.'' ';

        EXECUTE IMMEDIATE 'ALTER SESSION SET TEMP_UNDO_ENABLED=FALSE ';

        --Recuperar a empresa para o plano de execuÁ„o caso n„o esteja sendo executado pelo diretamente na tela do Mastersaf
        lib_parametros.salvar ( 'EMPRESA'
                              , NVL ( mcod_empresa, msafi.dpsp.v_empresa ) );

        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        mcod_usuario := lib_parametros.recuperar ( 'USUARIO' );

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

        EXECUTE IMMEDIATE 'ALTER SESSION SET TEMP_UNDO_ENABLED=FALSE '; --EVITAR PROBLEMAS DE GRAVACAO NAS GTTs

        dbms_application_info.set_module ( $$plsql_unit
                                         , 'PROC_ID: ' || mproc_id );

        loga (    'Data execuÁ„o: '
               || TO_CHAR ( v_data_exec
                          , 'DD/MM/YYYY HH24:MI:SS' )
             , FALSE );

        loga ( 'Usu·rio: ' || mcod_usuario
             , FALSE );
        loga ( 'Empresa: ' || mcod_empresa
             , FALSE );
        loga ( 'PerÌodo: ' || p_dt_ini || ' a ' || p_dt_fim
             , FALSE );
        loga ( 'Analisar: ' || p_busca
             , FALSE );
        loga ( 'UF: ' || p_uf
             , FALSE );
        loga ( 'Carregar Faltantes: ' || ( CASE WHEN p_carregar = 'S' THEN 'Sim' ELSE 'N„o' END )
             , FALSE );

        IF p_carregar = 'S' THEN
            loga ( '----------------------------------------'
                 , FALSE );
            loga ( 'Paralelismo por: ' || ( CASE WHEN p_flg_thread = '1' THEN 'ID Cupons' ELSE 'Lojas' END )
                 , FALSE );
            loga ( 'Threads: ' || p_num_thread
                 , FALSE );
        END IF;

        loga ( '----------------------------------------'
             , FALSE );

        loga ( 'Todas as Lojas: ' || ( CASE WHEN p_todos_estab = 'S' THEN 'Sim' ELSE 'N„o' END )
             , FALSE );

        IF p_todos_estab = 'N' THEN
            v_count := p_lojas.COUNT;
            loga ( 'Qtd de Lojas: ' || v_count
                 , FALSE );
        END IF;

        loga ( '----------------------------------------'
             , FALSE );

        --VALIDAR DATA
        IF p_dt_ini > SYSDATE THEN
            loga ( 'N„o foi possÌvel prosseguir:'
                 , FALSE );
            loga ( 'Data de InÌcio n„o informada corretamente, favor verificar.'
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
                loga ( '>> Dia: ' || c.data_par
                     , FALSE );

                EXECUTE IMMEDIATE 'TRUNCATE TABLE MSAFI.DPSP_CONC_NF_FALT_DH_GTT';

                IF NVL ( p_todos_estab, 'N' ) = 'N' THEN
                    FOR est IN p_lojas.FIRST .. p_lojas.LAST --(1)
                                                            LOOP
                        load_gtt_dh ( mcod_empresa
                                    , c.data_par
                                    , p_lojas ( est ) );
                        COMMIT;
                    END LOOP;
                END IF;

                IF p_todos_estab = 'S' THEN
                    load_gtt_dh ( mcod_empresa
                                , c.data_par
                                , '%' );
                END IF;

                COMMIT;

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

                        load_falt_dh ( mcod_empresa
                                     , c.data_par
                                     , v_dt_first
                                     , p_lojas ( est )
                                     , mproc_id
                                     , v_data_exec
                                     , mcod_usuario );

                        COMMIT;
                    END LOOP;
                END IF;

                IF p_todos_estab = 'S' THEN
                    dbms_application_info.set_module ( $$plsql_unit
                                                     , 'Dia:' || c.data_par || ' Lj:' || 'Todas' );

                    load_falt_dh ( mcod_empresa
                                 , c.data_par
                                 , v_dt_first
                                 , '%'
                                 , mproc_id
                                 , v_data_exec
                                 , mcod_usuario );
                END IF;

                COMMIT;
            END LOOP;

            lib_proc.add_tipo ( mproc_id
                              , 1
                              , 'REL_NF_DH_FALTANTE_MSAF.XLS'
                              , 2 );
            lib_proc.add ( dsp_planilha.header
                         , ptipo => 1 );
            lib_proc.add ( dsp_planilha.tabela_inicio
                         , ptipo => 1 );

            lib_proc.add ( dsp_planilha.linha ( p_conteudo =>    dsp_planilha.campo (
                                                                                      'Cupons Fiscais do Datahub faltantes no Mastersaf'
                                                                                    , p_custom => 'COLSPAN=16 BGCOLOR=BLUE'
                                                                 )
                                                              || --
                                                                dsp_planilha.campo (
                                                                                     'Formato esperado no Mastersaf'
                                                                                   , p_custom => 'COLSPAN=5 BGCOLOR=#8B008B'
                                                                 )
                                                              || --
                                                                ''
                                              , p_class => 'H' )
                         , ptipo => 1 );

            lib_proc.add ( dsp_planilha.linha ( p_conteudo =>    dsp_planilha.campo ( 'OBSERVACAO'
                                                                                    , p_custom => 'BGCOLOR=#FF0000' )
                                                              || --
                                                                dsp_planilha.campo ( 'ORIGEM' )
                                                              || --
                                                                dsp_planilha.campo ( 'COD_EMPRESA' )
                                                              || --
                                                                dsp_planilha.campo ( 'CODIGO_LOJA' )
                                                              || --
                                                                dsp_planilha.campo ( 'NUMERO_COMPONENTE' )
                                                              || --
                                                                dsp_planilha.campo ( 'MENSAGEM_10' )
                                                              || --
                                                                dsp_planilha.campo ( 'NUMERO_CUPOM' )
                                                              || --
                                                                dsp_planilha.campo ( 'DATA_TRANSACAO' )
                                                              || --
                                                                dsp_planilha.campo ( 'NUM_EQUIP' )
                                                              || --
                                                                dsp_planilha.campo ( 'MODELO_ECF' )
                                                              || --
                                                                dsp_planilha.campo ( 'CHAVE_EXECUCAO' )
                                                              || --
                                                                dsp_planilha.campo ( 'CHAVE_ACESSO_NFE' )
                                                              || --
                                                                dsp_planilha.campo ( 'STATUS_PROC_1' )
                                                              || --
                                                                dsp_planilha.campo ( 'DATA_PROC_1' )
                                                              || --
                                                                dsp_planilha.campo ( 'NSU_TRANSACAO' )
                                                              || --
                                                                dsp_planilha.campo ( 'TIPO_VENDA' )
                                                              || --
                                                                dsp_planilha.campo ( 'COD_ESTAB'
                                                                                   , p_custom => 'BGCOLOR=#33cc33' )
                                                              || --
                                                                dsp_planilha.campo ( 'NUM_DOCFIS'
                                                                                   , p_custom => 'BGCOLOR=#33cc33' )
                                                              || --
                                                                dsp_planilha.campo ( 'NUM_COO'
                                                                                   , p_custom => 'BGCOLOR=#33cc33' )
                                                              || --
                                                                dsp_planilha.campo ( 'COD_ESTADO'
                                                                                   , p_custom => 'BGCOLOR=#33cc33' )
                                                              || --
                                                                dsp_planilha.campo ( 'RECARREGAR'
                                                                                   , p_custom => 'BGCOLOR=#33cc33' )
                                                              || --
                                                                '' --
                                              , p_class => 'H' )
                         , ptipo => 1 );

            load_excel_dh ( mcod_empresa
                          , p_dt_ini
                          , p_dt_fim
                          , v_dt_first
                          , '%'
                          , p_carregar
                          , v_data_exec
                          , mproc_id );

            -- RODAPE
            lib_proc.add ( dsp_planilha.tabela_fim
                         , ptipo => 1 );
            COMMIT;
            --

            loga ( 'RelatÛrio gerado.'
                 , TRUE );
        --=========================================================
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
            ELSE
                IF p_todos_estab = 'S' THEN
                    SELECT   cod_estab
                        BULK COLLECT INTO v_cod_estab
                        FROM dsp_estabelecimento_v
                       WHERE 1 = 1
                         AND cod_empresa = mcod_empresa
                         AND tipo = 'L'
                    ORDER BY cod_estab;
                ELSIF p_flg_thread = '2' THEN
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
            loga ( 'ERRO N√O TRATADO: ' || dbms_utility.format_error_backtrace
                 , FALSE );
            loga ( 'SQLERRM: ' || SQLERRM
                 , FALSE );
            loga ( 'ERRO!'
                 , FALSE );
            loga ( ' '
                 , FALSE );
            loga ( dbms_utility.format_error_backtrace
                 , FALSE );

            --ENVIAR EMAIL DE ERRO-------------------------------------------
            envia_email ( mcod_empresa
                        , p_dt_ini
                        , p_dt_fim
                        , SQLERRM
                        , 'E'
                        , TO_CHAR ( SYSDATE
                                  , 'DD/MM/YYYY HH24:MI:SS' ) );
            -----------------------------------------------------------------

            lib_proc.close;
            COMMIT;
            RETURN mproc_id;
    END;
END dpsp_conc_dh_nf_faltante_cproc;
/
SHOW ERRORS;
