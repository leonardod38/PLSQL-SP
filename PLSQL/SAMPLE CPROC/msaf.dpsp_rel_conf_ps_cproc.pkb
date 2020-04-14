Prompt Package Body DPSP_REL_CONF_PS_CPROC;
--
-- DPSP_REL_CONF_PS_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_rel_conf_ps_cproc
IS
    mcod_empresa empresa.cod_empresa%TYPE;
    mcod_estab estabelecimento.cod_estab%TYPE;
    mcod_usuario usuario_empresa.cod_usuario%TYPE;
    macesso_full VARCHAR2 ( 5 );
    mproc_id NUMBER;

    --Tipo, Nome e DescriÁ„o do Customizado
    mnm_tipo VARCHAR2 ( 100 ) := 'AutomatizaÁ„o';
    mnm_cproc VARCHAR2 ( 100 ) := 'RelatÛrio Confronto Peoplesoft x MSAF';
    mds_cproc VARCHAR2 ( 100 ) := 'Emitir relatÛrio de confronto de NFs Peoplesoft x Mastersaf';

    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );

        v_sel_data_fim VARCHAR2 ( 260 )
            := ' SELECT TRUNC( TO_DATE( :1 ,''DD/MM/YYYY'') + ROWNUM - 1) AS DATA_FIM, TRUNC( TO_DATE( :1 ,''DD/MM/YYYY'') + ROWNUM - 1) AS DATA_FIM FROM DUAL CONNECT BY ROWNUM <= LAST_DAY( TO_DATE( :1 ,''DD/MM/YYYY'') ) - TO_DATE( :1 ,''DD/MM/YYYY'') + 1 ORDER BY 1 DESC ';
    BEGIN
        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        mcod_estab := lib_parametros.recuperar ( 'ESTABELECIMENTO' );
        mcod_usuario := lib_parametros.recuperar ( 'USUARIO' );

        --VALIDAR ACESSO DO USU¡RIO
        SELECT ( CASE WHEN qtd = 0 THEN 'N' ELSE 'S' END )
          INTO macesso_full
          FROM (SELECT COUNT ( 1 ) qtd
                  FROM pl_grp_usr rol
                     , pl_grp grp
                     , pl_usr usr
                 WHERE 1 = 1
                   AND rol.grp_key = grp.grp_key
                   AND rol.usr_key = usr.usr_key
                   AND grp_name IN ( 'DEVELOPER'
                                   , 'DEVELOPER_DP' )
                   AND TRIM ( UPPER ( usr.usr_login ) ) = TRIM ( UPPER ( mcod_usuario ) ));

        -- PPARAM:      STRING PASSADA POR REFER NCIA;
        -- PTITULO:     TÕTULO DO PAR¬METRO MOSTRADO NA JANELA;
        -- PTIPO:       VARCHAR2, DATE, INTEGER;
        -- PCONTROLE:   MULTIPROC, TEXT, TEXTBOX, COMBOBOX, LISTBOX OU RADIOBUTTON;
        -- PMANDATORIO: S OU N, INDICANDO SE A INFORMA«√O DO PAR¬METRO … OBRIGAT”RIA;
        -- PDEFAULT:    VALOR PREENCHIDO AUTOMATICAMENTE NA ABERTURA DA JANELA;
        -- PMASCARA:    M¡SCARA PARA DIGITA«√O (EX: DD/MM/YYYY, 999999 OU ######);
        -- PVALORES:    SELECT (COMBOBOX OU MULTIPROC) OU COD1=DESC1,COD2=DESC2...
        -- PAPRESENTA:  S OU N, INDICANDO SE O PAR¬METRO DEVE SER MOSTRADO NA LISTAGEM DOS PROCESSOS;

        --1
        lib_proc.add_param ( pstr
                           , 'Data Inicial'
                           , --P_DATA_INI
                            'DATE'
                           , 'TEXTBOX'
                           , 'S'
                           , NULL
                           , 'DD/MM/YYYY' );
        --2
        lib_proc.add_param ( pstr
                           , 'Data Final'
                           , --PDT_FIM
                            'VARCHAR2'
                           , 'COMBOBOX'
                           , 'S'
                           , NULL
                           , '##########'
                           , v_sel_data_fim );

        --3
        lib_proc.add_param (
                             pstr
                           , 'UF'
                           , --P_COD_ESTADO
                            'VARCHAR2'
                           , 'COMBOBOX'
                           , 'S'
                           , '%'
                           , '##########'
                           , 'SELECT A.COD_ESTADO, A.COD_ESTADO FROM ESTADO A UNION ALL SELECT ''%'', ''Todas as UFs'' FROM DUAL ORDER BY 1'
        );

        --4
        lib_proc.add_param (
                             pstr
                           , 'Status'
                           , --P_STATUS
                            'VARCHAR2'
                           , 'COMBOBOX'
                           , 'S'
                           , 1
                           , NULL
                           , 'SELECT ''1'',''01. NFs de Saida Confirmadas, Canceladas, Impressas, Inutilizadas e Denegadas''  FROM DUAL UNION ALL
                           SELECT ''2'',''02. NFs de Saida Demais Status''  FROM DUAL UNION ALL
                           SELECT ''3'',''03. Confronto Valor Cont·bil Mastersaf x Peoplesoft''  FROM DUAL UNION ALL
                           SELECT ''4'',''04. Confronto Nfs de Entrada Mastersaf x Peoplesoft''  FROM DUAL UNION ALL
                           SELECT ''5'',''05. Confronto Valor Cont·bil Mastersaf x Peoplesoft por CFOP'' FROM DUAL UNION ALL
                           SELECT ''99'',''99. Confronto NFs de Saida e Entrada'' FROM DUAL
                           '
        );

        --5
        lib_proc.add_param ( pstr
                           , 'Tipo Grupo/Estab'
                           , --P_TIPO
                            'VARCHAR2'
                           , 'COMBOBOX'
                           , 'S'
                           , 'C'
                           , NULL
                           , 'SELECT ''C'',''Lojas por UF e CDs''  FROM DUAL UNION ALL
                           SELECT ''%'',''Lojas por UF, CDs e todas as Lojas''  FROM DUAL
                           '  );

        --6
        lib_proc.add_param ( pstr
                           ,    LPAD ( ' '
                                     , 62
                                     , ' ' )
                             || '[ Configurar layout do RelatÛrio ]'
                           , 'VARCHAR2'
                           , 'TEXT'
                           , 'N'
                           , '1'
                           , NULL
                           , ''
                           , 'N' );
        --7
        lib_proc.add_param ( pstr
                           , 'Extrair com scripts de recarga'
                           , --P_EXT_CARGA
                            'VARCHAR2'
                           , 'CHECKBOX'
                           , 'N'
                           , 'N'
                           , NULL
                           , phabilita => ' :3 IN (1,4) ' || --
                                                            '' );
        --8
        lib_proc.add_param (
                             pstr
                           , 'Grupo/Estabelecimentos'
                           , --P_GRUPO
                            'VARCHAR2'
                           , 'MULTISELECT'
                           , 'N'
                           , NULL
                           , NULL
                           ,    'SELECT DISTINCT ''UF''||COD_ESTADO , '' LOJAS ''||COD_ESTADO TXT'
                             || ' FROM DSP_ESTABELECIMENTO_V WHERE 1=1 AND TIPO = ''L'' AND COD_ESTADO LIKE :3 UNION'
                             || ' SELECT TIPO||COD_ESTAB , ''(''|| TIPO || '') ''||COD_ESTADO||'' - ''||COD_ESTAB||'' - ''||INITCAP(ENDER)'
                             || ' FROM DSP_ESTABELECIMENTO_V WHERE 1=1 AND COD_ESTADO LIKE :3 AND TIPO LIKE :5 ORDER BY 2'
        );

        RETURN pstr;
    END; --FUNCTION PARAMETROS RETURN VARCHAR2 IS

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
        RETURN 'VERSAO 1.2';
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

    FUNCTION moeda ( v_conteudo NUMBER )
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN TRIM ( TO_CHAR ( v_conteudo
                              , '9g999g999g990d00' ) );
    END;

    FUNCTION fazcampo ( p_i_campo IN VARCHAR2
                      , p_i_fill IN VARCHAR2
                      , p_i_size IN NUMBER )
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN LPAD ( NVL ( p_i_campo, ' ' )
                    , p_i_size
                    , p_i_fill );
    END;

    FUNCTION fazcampo ( p_i_campo IN NUMBER
                      , p_i_format IN VARCHAR2
                      , p_i_fill IN VARCHAR2
                      , p_i_size IN NUMBER )
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN LPAD ( NVL ( TO_CHAR ( p_i_campo
                                    , p_i_format )
                          , ' ' )
                    , p_i_size
                    , p_i_fill );
    END;

    FUNCTION fazcampo ( p_i_campo IN DATE
                      , p_i_format IN VARCHAR2
                      , p_i_fill IN VARCHAR2
                      , p_i_size IN NUMBER )
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN LPAD ( NVL ( TO_CHAR ( p_i_campo
                                    , p_i_format )
                          , ' ' )
                    , p_i_size
                    , p_i_fill );
    END;

    FUNCTION executar ( p_data_ini DATE
                      , p_data_fim DATE
                      , p_cod_estado VARCHAR2
                      , p_status VARCHAR2
                      , p_tipo VARCHAR2
                      , p_ext_carga VARCHAR2
                      , p_grupo lib_proc.vartab )
        RETURN INTEGER
    IS
        mdesc VARCHAR2 ( 4000 );
        i1 INTEGER;
        v_data_exec DATE;
        v_count NUMBER;
        v_id_arq NUMBER := 90;

        v_proc_status NUMBER := 0;
        v_s_proc_status VARCHAR2 ( 16 );

        v_txt_temp VARCHAR2 ( 1024 ) := '';
        v_txt_basico VARCHAR2 ( 256 ) := '';

        TYPE a_estabs_t IS TABLE OF VARCHAR2 ( 8 );

        a_estabs a_estabs_t := a_estabs_t ( );

        --Variaveis genericas
        v_text01 VARCHAR2 ( 6000 );
        v_sep VARCHAR2 ( 1 ) := CHR ( 9 );
        p_proc_instance VARCHAR2 ( 30 );

        --
        TYPE cur_typ IS REF CURSOR;

        cr_cup cur_typ;
        --
        v_class VARCHAR2 ( 1 ) := 'a';
        v_filtro_status VARCHAR2 ( 50 );
        v_sql VARCHAR2 ( 6000 );
        c_nf SYS_REFCURSOR;
        v_tem_grupo VARCHAR2 ( 1 );

        TYPE cur_tab_nf IS RECORD
        (
            emitente VARCHAR2 ( 6 )
          , uf_emitente VARCHAR2 ( 2 )
          , nf_brl_id VARCHAR2 ( 14 )
          , dt_emissao DATE
          , dt_sefaz DATE
          , protocolo_sefaz VARCHAR2 ( 20 )
          , numero_nf VARCHAR2 ( 12 )
          , destin_bu VARCHAR2 ( 20 )
          , cfop VARCHAR2 ( 4 )
          , chave_acesso VARCHAR2 ( 80 )
          , status VARCHAR2 ( 30 )
          , valor_tot_nf NUMBER ( 17, 2 )
        );

        TYPE c_tab_nf IS TABLE OF cur_tab_nf;

        tab_nf c_tab_nf;

        ---
        TYPE cur_tab_nf2 IS RECORD
        (
            cod_estab VARCHAR2 ( 6 )
          , uf_emitente VARCHAR2 ( 2 )
          , id_people_soft VARCHAR2 ( 14 )
          , dt_emissao DATE
          , dt_sefaz DATE
          , protocolo_sefaz VARCHAR2 ( 20 )
          , numero_nf VARCHAR2 ( 12 )
          , chave_acesso VARCHAR2 ( 80 )
          , status_peoplesoft VARCHAR2 ( 30 )
          , vlr_tot_psft NUMBER ( 17, 2 )
          , vlr_contab_msaf NUMBER ( 17, 2 )
        );

        TYPE c_tab_nf2 IS TABLE OF cur_tab_nf2;

        tab_nf2 c_tab_nf2;

        ---
        TYPE cur_tab_nf3 IS RECORD
        (
            cod_estab VARCHAR2 ( 7 )
          , id_nf VARCHAR2 ( 12 )
          , id_peoplesoft VARCHAR2 ( 14 )
          , serie_nf VARCHAR2 ( 3 )
          , dt_fiscal DATE
          , chave_nf VARCHAR2 ( 80 )
          , uf VARCHAR2 ( 2 )
          , status VARCHAR2 ( 30 )
          , dt_ultima_atualizacao DATE
          , tipo_nf VARCHAR2 ( 10 )
          , vlr_tot_nota NUMBER ( 17, 2 )
        );

        TYPE c_tab_nf3 IS TABLE OF cur_tab_nf3;

        tab_nf3 c_tab_nf3;

        ---
        TYPE cur_tab_nf5 IS RECORD
        (
            cod_estab VARCHAR2 ( 6 )
          , uf_emitente VARCHAR2 ( 2 )
          , id_people_soft VARCHAR2 ( 14 )
          , dt_emissao DATE
          , dt_sefaz DATE
          , protocolo_sefaz VARCHAR2 ( 20 )
          , numero_nf VARCHAR2 ( 12 )
          , chave_acesso VARCHAR2 ( 80 )
          , status_peoplesoft VARCHAR2 ( 30 )
          , cod_cfo VARCHAR2 ( 6 )
          , vlr_tot_psft NUMBER ( 17, 2 )
          , vlr_contab_msaf NUMBER ( 17, 2 )
        );

        TYPE c_tab_nf5 IS TABLE OF cur_tab_nf5;

        tab_nf5 c_tab_nf5;
    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS= '',.'' ';

        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_LANGUAGE = ''Portuguese'' ';

        --Performar em caso de cÛdigos repetitivos no mesmo plano de execuÁ„o
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING = FORCE';

        --Recuperar a empresa para o plano de execuÁ„o caso n„o esteja sendo executado pelo diretamente na tela do Mastersaf
        lib_parametros.salvar ( 'EMPRESA'
                              , NVL ( mcod_empresa, msafi.dpsp.v_empresa ) );

        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        mcod_usuario := lib_parametros.recuperar ( 'USUARIO' );
        mdesc := lib_parametros.recuperar ( 'PDESC' );

        IF mcod_usuario IS NULL THEN
            lib_parametros.salvar ( 'USUARIO'
                                  , 'AUTOMATICO' );
            mcod_usuario := lib_parametros.recuperar ( 'USUARIO' );
            macesso_full := 'S';
        END IF;

        v_count := p_grupo.COUNT;

        --InformaÁıes as execuÁıes que foram feitas via job Scheduler, PROC ou Bloco AnÙnimo do PLSQL
        IF mcod_usuario = 'AUTOMATICO' THEN
            mdesc :=
                   '<< ExecuÁ„o via Job Scheduler / PL SQL Block >>'
                || CHR ( 10 )
                || --
                  'Empresa: '
                || mcod_empresa
                || CHR ( 10 )
                || --
                  'Data Inicial: '
                || TO_CHAR ( p_data_ini
                           , 'DD/MM/YYYY' )
                || CHR ( 10 )
                || --
                  'Data Final: '
                || TO_CHAR ( p_data_fim
                           , 'DD/MM/YYYY' )
                || CHR ( 10 )
                || --
                  'UF: '
                || ( CASE WHEN p_cod_estado = '%' THEN 'Todas as UFs' ELSE p_cod_estado END )
                || CHR ( 10 )
                || --
                  'Status: '
                || ( CASE
                        WHEN p_status = '1' THEN
                            '01. NFs de Saida Confirmadas, Canceladas, Impressas, Inutilizadas e Denegadas'
                        WHEN p_status = '2' THEN
                            '02. NFs de Saida Demais Status'
                        WHEN p_status = '3' THEN
                            '03. Confronto Valor Cont·bil Mastersaf x Peoplesoft'
                        WHEN p_status = '4' THEN
                            '04. Confronto Nfs de Entrada Mastersaf x Peoplesoft'
                        WHEN p_status = '5' THEN
                            '05. Confronto Valor Cont·bil Mastersaf x Peoplesoft por CFOP'
                        WHEN p_status = '99' THEN
                            '99. Confronto NFs de Saida e Entrada'
                        ELSE
                            p_status
                    END )
                || CHR ( 10 )
                || --
                  'Qtde de Grupos/Estabelecimentos: '
                || v_count
                || --
                  '';
        END IF; -- VS_MCOD_USUARIO = PCOD_USUARIO

        -- CriaÁ„o: Processo
        mproc_id :=
            lib_proc.new ( psp_nome => $$plsql_unit
                         , pdescricao => mdesc );
        COMMIT;
        v_data_exec := SYSDATE;

        loga ( '<<' || mnm_cproc || '>>'
             , FALSE );
        loga ( '---INICIO DO PROCESSAMENTO---'
             , FALSE );

        dbms_application_info.set_module ( $$plsql_unit
                                         , 'PROC_ID: ' || mproc_id );

        loga (    'Data execuÁ„o: '
               || TO_CHAR ( v_data_exec
                          , 'DD/MM/YYYY HH24:MI:SS' )
             , FALSE );

        loga ( LPAD ( '-'
                    , 62
                    , '-' )
             , FALSE );
        loga ( 'Usu·rio: ' || mcod_usuario
             , FALSE );
        loga ( 'Empresa: ' || mcod_empresa
             , FALSE );
        loga (    'PerÌodo: '
               || TO_CHAR ( p_data_ini
                          , 'DD/MM/YYYY' )
               || ' - '
               || TO_CHAR ( p_data_fim
                          , 'DD/MM/YYYY' )
             , FALSE );
        loga ( 'UF: ' || ( CASE WHEN p_cod_estado = '%' THEN 'Todas as UFs' ELSE p_cod_estado END )
             , FALSE );
        loga (
                  'Status: '
               || ( CASE
                       WHEN p_status = '1' THEN
                           '01. NFs de Saida Confirmadas, Canceladas, Impressas, Inutilizadas e Denegadas'
                       WHEN p_status = '2' THEN
                           '02. NFs de Saida Demais Status'
                       WHEN p_status = '3' THEN
                           '03. Confronto Valor Cont·bil Mastersaf x Peoplesoft'
                       WHEN p_status = '4' THEN
                           '04. Confronto Nfs de Entrada Mastersaf x Peoplesoft'
                       WHEN p_status = '5' THEN
                           '05. Confronto Valor Cont·bil Mastersaf x Peoplesoft por CFOP'
                       WHEN p_status = '99' THEN
                           '99. Confronto NFs de Saida e Entrada'
                       ELSE
                           p_status
                   END )
             , FALSE
        );
        loga ( 'EXTRAIR com scripts de recarga: ' || ( CASE WHEN p_ext_carga = 'S' THEN 'SIM' ELSE 'N√O' END )
             , FALSE );
        loga ( 'Qtde Grupos/Estabelecimentos: ' || v_count
             , FALSE );
        loga ( LPAD ( '-'
                    , 62
                    , '-' )
             , FALSE );

        IF macesso_full = 'N'
       AND ( p_ext_carga = 'S' ) THEN
            loga ( LPAD ( '-'
                        , 62
                        , '-' )
                 , FALSE );
            loga ( 'ATEN«√O! As opÁıes de execuÁ„o de carga s„o de uso exclusivo do Suporte Mastersaf!'
                 , FALSE );
            loga ( 'N„o s„o permitidas as opÁıes selecionados no relatÛrio para o usu·rio atual:'
                 , FALSE );
            loga ( mcod_usuario
                 , FALSE );
            loga ( LPAD ( '-'
                        , 62
                        , '-' )
                 , FALSE );
            loga ( 'STATUS FINAL: [ERRO]' );
            loga ( '---FIM DO PROCESSAMENTO---'
                 , FALSE );

            --ENVIAR EMAIL DE ERRO-------------------------------------------
            envia_email (
                          mcod_empresa
                        , p_data_ini
                        , p_data_fim
                        ,    'A execuÁ„o deste customizado È de uso exclusivo do Suporte Mastersaf!'
                          || CHR ( 10 )
                          || 'O usu·rio '
                          || mcod_usuario
                          || ' n„o apresenta as permissıes necess·rias.'
                        , 'E'
                        , v_data_exec
            );
            -----------------------------------------------------------------

            lib_proc.close ( );
            COMMIT;
            RETURN mproc_id;
        END IF;

        IF TO_NUMBER ( TO_CHAR ( p_data_ini
                               , 'YYYY' ) ) = '1900' THEN
            loga ( LPAD ( '-'
                        , 62
                        , '-' )
                 , FALSE );
            loga ( 'N„o È possÌvel prosseguir com o perÌodo informado.'
                 , FALSE );
            loga ( LPAD ( '-'
                        , 62
                        , '-' )
                 , FALSE );
            loga ( '---FIM DO PROCESSAMENTO---'
                 , FALSE );
            lib_proc.close ( );
            COMMIT;
            RETURN mproc_id;
        END IF;

        msafi.dsp_control.createprocess ( 'DPSP_REL_CONF_PS'
                                        , --P_I_PROCID            IN VARCHAR2              --VARCHAR2(16)
                                         'DPSP_REL_CONF_PS'
                                        , --P_I_PROC_DESCR        IN VARCHAR2              --VARCHAR2(64)
                                         NULL
                                        , --P_I_DATA_INI          IN DATE     DEFAULT NULL
                                         NULL
                                        , --P_I_DATA_FIM          IN DATE     DEFAULT NULL
                                         TO_CHAR ( p_data_ini
                                                 , 'DD/MM/YYYY' )
                                        , --P_I_DETALHES1         IN VARCHAR2 DEFAULT NULL --VARCHAR2(32)
                                         TO_CHAR ( p_data_fim
                                                 , 'DD/MM/YYYY' )
                                        , --P_I_DETALHES2         IN VARCHAR2 DEFAULT NULL --VARCHAR2(32)
                                         NULL
                                        , --P_I_DETALHES3         IN VARCHAR2 DEFAULT NULL --VARCHAR2(32)
                                         NULL
                                        , --P_I_DETALHES4         IN VARCHAR2 DEFAULT NULL --VARCHAR2(32)
                                         mcod_usuario --P_I_USER              IN VARCHAR2 DEFAULT NULL  --VARCHAR2(64)
                                                      );
        v_proc_status := 1; --EM PROCESSO

        loga ( '[INICIO] RELATORIO '
             , FALSE );
        loga ( '>> PROC_INSTANCE: ' || p_proc_instance
             , FALSE );
        loga ( '>> DT INICIAL: ' || p_data_ini
             , FALSE );
        loga ( '>> DT FINAL: ' || p_data_fim
             , FALSE );

        IF p_status = '99' THEN
            loga ( '>> Status 99: GeraÁ„o dos Status 1 e 4'
                 , FALSE );
        END IF;

        --
        COMMIT;

        IF ( p_status = '1'
         OR p_status = '99' ) THEN
            v_filtro_status := ' IN ';
        ELSE
            v_filtro_status := ' NOT IN ';
        END IF;

        ---

        --PREPARAR GRUPOS
        IF ( p_grupo.COUNT > 0 ) THEN
            i1 := p_grupo.FIRST;

            WHILE i1 IS NOT NULL LOOP
                a_estabs.EXTEND ( );
                a_estabs ( a_estabs.LAST ) := p_grupo ( i1 );
                i1 := p_grupo.NEXT ( i1 );
            END LOOP;

            v_tem_grupo := 'Y';
        ELSE
            v_tem_grupo := 'N';
        END IF;

        ---

        IF ( p_status = '1'
         OR p_status = '2'
         OR p_status = '99' ) THEN
            --(3)
            v_id_arq := v_id_arq + 1;

            lib_proc.add_tipo ( mproc_id
                              , v_id_arq
                              ,    mcod_empresa
                                || '_'
                                || TO_CHAR ( p_data_ini
                                           , 'MMYYYY' )
                                || '_REL_CONFRONTO_NF_SAIDA_MSAF_PS.XLS'
                              , 2 );

            lib_proc.add ( dsp_planilha.header
                         , ptipo => v_id_arq );
            lib_proc.add ( dsp_planilha.tabela_inicio
                         , ptipo => v_id_arq );

            lib_proc.add ( dsp_planilha.linha ( p_conteudo => dsp_planilha.campo ( 'CONFRONTO SAIDA MSAF PS'
                                                                                 , p_custom => 'COLSPAN=12' )
                                              , p_class => 'h' )
                         , ptipo => v_id_arq );

            lib_proc.add ( dsp_planilha.linha ( p_conteudo =>    dsp_planilha.campo ( 'EMITENTE' )
                                                              || --
                                                                dsp_planilha.campo ( 'UF_EMITENTE' )
                                                              || --
                                                                dsp_planilha.campo ( 'ID_PEOPLESOFT' )
                                                              || --
                                                                dsp_planilha.campo ( 'DT_EMISSAO' )
                                                              || --
                                                                dsp_planilha.campo ( 'DT_SEFAZ' )
                                                              || --
                                                                dsp_planilha.campo ( 'PROTOCOLO_SEFAZ' )
                                                              || --
                                                                dsp_planilha.campo ( 'NUMERO_NF' )
                                                              || --
                                                                dsp_planilha.campo ( 'DESTIN_BU' )
                                                              || --
                                                                dsp_planilha.campo ( 'CFOP' )
                                                              || --
                                                                dsp_planilha.campo ( 'CHAVE_ACESSO' )
                                                              || --
                                                                dsp_planilha.campo ( 'STATUS_PEOPLESOFT' )
                                                              || --
                                                                dsp_planilha.campo ( 'VALOR_TOT_NF' )
                                                              || --
                                                                 ( CASE
                                                                      WHEN p_ext_carga = 'S' THEN --
                                                                             dsp_planilha.campo (
                                                                                                  'CARREGAR NF'
                                                                                                , p_custom => 'BGCOLOR=green'
                                                                             )
                                                                          || --
                                                                            dsp_planilha.campo (
                                                                                                 '-'
                                                                                               , p_custom => 'BGCOLOR=green'
                                                                             )
                                                                  END ) --
                                                              || --
                                                                ''
                                              , p_class => 'h' )
                         , ptipo => v_id_arq );

            IF ( v_tem_grupo = 'Y' ) THEN
                --BUSCAR TODOS --(2)

                FOR i IN 1 .. a_estabs.COUNT --(1)
                                            LOOP
                    dbms_application_info.set_client_info ( a_estabs ( i ) || ';' || i || ';' || a_estabs.COUNT );
                    --- COMPARATIVO PEOPLE X MSAF - NOTAS EMITIDAS
                    v_sql := 'SELECT   ';
                    v_sql := v_sql || ' F.COD_ESTAB AS EMITENTE ';
                    v_sql := v_sql || ',A.UF_EMITENTE ';
                    v_sql := v_sql || ',A.ID_PEOPLE_SOFT ';
                    v_sql := v_sql || ',A.DT_EMISSAO ';
                    v_sql := v_sql || ',A.DT_SEFAZ ';
                    v_sql := v_sql || ',A.PROTOCOLO_SEFAZ ';
                    v_sql := v_sql || ',A.NUMERO_NF ';
                    v_sql := v_sql || ',A.DESTIN_BU ';
                    v_sql := v_sql || ',A.CFOP ';
                    v_sql := v_sql || ',A.CHAVE_ACESSO ';
                    v_sql := v_sql || ',A.STATUS_PEOPLESOFT ';
                    v_sql := v_sql || ',A.VALOR_TOT_NF ';
                    v_sql := v_sql || 'FROM ( ';
                    v_sql := v_sql || '    SELECT /*+ DRIVING_SITE(A) */  ';
                    v_sql := v_sql || '           A.SHIP_FROM_STATE AS UF_EMITENTE ';
                    v_sql := v_sql || '          ,A.NF_BRL_ID AS ID_PEOPLE_SOFT ';
                    v_sql := v_sql || '          ,A.NF_ISSUE_DT_BBL AS DT_EMISSAO ';
                    v_sql := v_sql || '          ,E.NFEE_DT_BBL AS DT_SEFAZ ';
                    v_sql := v_sql || '          ,E.NFEE_USE_BBL AS PROTOCOLO_SEFAZ ';
                    v_sql := v_sql || '          ,A.NF_BRL AS NUMERO_NF ';
                    v_sql := v_sql || '          ,CASE WHEN A.SHIP_TO_CUST_ID=''AR000000098'' THEN ';
                    v_sql :=
                           v_sql
                        || '             CASE WHEN LTRIM(TRIM(REPLACE(REPLACE(REPLACE(NVL(TRIM(C.CGC_BRL),C.CPF_BRL),''.'',''''),''-'',''''),''/'','''')),''0'') IS NULL THEN A.EF_LOC_BRL ';
                    v_sql :=
                           v_sql
                        || '             ELSE TRIM(SUBSTR(''CF'' || REPLACE(REPLACE(REPLACE(NVL(TRIM(C.CGC_BRL),C.CPF_BRL),''.'',''''),''-'',''''),''/'',''''),1,14)) ';
                    v_sql := v_sql || '             END ';
                    v_sql := v_sql || '          ELSE ';
                    v_sql :=
                           v_sql
                        || '             CASE WHEN LENGTH(REPLACE(REPLACE(SUBSTR(NVL(NVL(TRIM(A.SHIP_TO_CUST_ID),TRIM(A.DESTIN_BU)),TRIM(A.LOCATION)),1,14),'' '',''''),''VD'',''DP'')) > 14 THEN ';
                    v_sql :=
                           v_sql
                        || '                REPLACE(REPLACE(REPLACE(SUBSTR(NVL(NVL(TRIM(A.SHIP_TO_CUST_ID),TRIM(A.DESTIN_BU)),TRIM(A.LOCATION)),1,14),'' '',''''),''VD'',''DP''),''F000'',''F'') ';
                    v_sql := v_sql || '             ELSE ';
                    v_sql :=
                           v_sql
                        || '                REPLACE(REPLACE(REPLACE(SUBSTR(NVL(NVL(TRIM(A.SHIP_TO_CUST_ID),TRIM(A.DESTIN_BU)),TRIM(A.LOCATION)),1,14),'' '',''''),''VD'',''DP''),''L'',''DP'') ';
                    v_sql := v_sql || '             END ';
                    v_sql := v_sql || '          END AS DESTIN_BU ';
                    v_sql := v_sql || '          ,SUBSTR(REPLACE(D.CFO_BRL_CD, ''.'', ''''), 1, 4) AS CFOP ';
                    v_sql := v_sql || '          ,A.NFEE_KEY_BBL AS CHAVE_ACESSO ';
                    v_sql := v_sql || '          ,XLAT.XLATLONGNAME AS STATUS_PEOPLESOFT ';
                    v_sql := v_sql || '          ,SUM(A.GROSS_AMT_BSE) AS VALOR_TOT_NF ';
                    v_sql := v_sql || '          ,A.EF_LOC_BRL ';

                    v_sql := v_sql || '    FROM MSAFI.PS_NF_HDR_BBL_FS    A, ';
                    v_sql := v_sql || '         MSAFI.PS_DSP_SOL_NFE_HDR  B, ';
                    v_sql := v_sql || '         MSAFI.PS_DSP_SOL_NFE_ADR  C, ';
                    v_sql := v_sql || '         MSAFI.PS_NF_LN_BBL_FS     D, ';
                    v_sql := v_sql || '         MSAFI.PS_AR_NFRET_BBL     E, ';
                    v_sql := v_sql || '         MSAFI.PSXLATITEM XLAT ';

                    v_sql :=
                           v_sql
                        || '    WHERE A.NF_ISSUE_DT_BBL BETWEEN TO_DATE('''
                        || TO_CHAR ( p_data_ini
                                   , 'YYYYMMDD' )
                        || ''',''YYYYMMDD'') AND TO_DATE('''
                        || TO_CHAR ( p_data_fim
                                   , 'YYYYMMDD' )
                        || ''',''YYYYMMDD'') ';
                    v_sql :=
                           v_sql
                        || '      AND A.NF_STATUS_BBL '
                        || v_filtro_status
                        || ' (''CNFM'', ''CNCL'', ''PRNT'', ''INTL'', ''DNGD'') ';

                    v_sql := v_sql || '      AND B.BUSINESS_UNIT (+) = A.BUSINESS_UNIT ';
                    v_sql := v_sql || '      AND B.NF_BRL_ID     (+) = A.NF_BRL_ID ';

                    v_sql := v_sql || '      AND B.DSP_TIPO_OPER (+) = ''V_AVISTA'' ';

                    v_sql := v_sql || '      AND B.BUSINESS_UNIT = C.BUSINESS_UNIT (+) ';
                    v_sql := v_sql || '      AND B.DSP_NFE_ID    = C.DSP_NFE_ID    (+) ';

                    v_sql := v_sql || '      AND A.BUSINESS_UNIT = D.BUSINESS_UNIT ';
                    v_sql := v_sql || '      AND A.NF_BRL_ID     = D.NF_BRL_ID ';

                    v_sql := v_sql || '      AND A.BUSINESS_UNIT = E.BUSINESS_UNIT (+) ';
                    v_sql := v_sql || '      AND A.NF_BRL_ID     = E.NF_BRL_ID     (+) ';

                    v_sql := v_sql || '      AND XLAT.FIELDNAME  = ''NF_STATUS_BBL'' ';
                    v_sql := v_sql || '      AND XLAT.FIELDVALUE = A.NF_STATUS_BBL ';

                    v_sql := v_sql || '    GROUP BY ';
                    v_sql := v_sql || '        A.SHIP_FROM_STATE ';
                    v_sql := v_sql || '       ,A.NF_BRL_ID ';
                    v_sql := v_sql || '       ,A.NF_ISSUE_DT_BBL ';
                    v_sql := v_sql || '       ,E.NFEE_DT_BBL ';
                    v_sql := v_sql || '       ,E.NFEE_USE_BBL ';
                    v_sql := v_sql || '       ,A.NF_BRL ';
                    v_sql := v_sql || '       ,CASE WHEN A.SHIP_TO_CUST_ID=''AR000000098'' THEN ';
                    v_sql :=
                           v_sql
                        || '        CASE WHEN LTRIM(TRIM(REPLACE(REPLACE(REPLACE(NVL(TRIM(C.CGC_BRL),C.CPF_BRL),''.'',''''),''-'',''''),''/'','''')),''0'') IS NULL THEN A.EF_LOC_BRL ';
                    v_sql :=
                           v_sql
                        || '        ELSE TRIM(SUBSTR(''CF'' || REPLACE(REPLACE(REPLACE(NVL(TRIM(C.CGC_BRL),C.CPF_BRL),''.'',''''),''-'',''''),''/'',''''),1,14)) ';
                    v_sql := v_sql || '        END ';
                    v_sql := v_sql || '        ELSE ';
                    v_sql :=
                           v_sql
                        || '        CASE WHEN LENGTH(REPLACE(REPLACE(SUBSTR(NVL(NVL(TRIM(A.SHIP_TO_CUST_ID),TRIM(A.DESTIN_BU)),TRIM(A.LOCATION)),1,14),'' '',''''),''VD'',''DP'')) > 14 THEN ';
                    v_sql :=
                           v_sql
                        || '        REPLACE(REPLACE(REPLACE(SUBSTR(NVL(NVL(TRIM(A.SHIP_TO_CUST_ID),TRIM(A.DESTIN_BU)),TRIM(A.LOCATION)),1,14),'' '',''''),''VD'',''DP''),''F000'',''F'') ';
                    v_sql := v_sql || '        ELSE ';
                    v_sql :=
                           v_sql
                        || '        REPLACE(REPLACE(REPLACE(SUBSTR(NVL(NVL(TRIM(A.SHIP_TO_CUST_ID),TRIM(A.DESTIN_BU)),TRIM(A.LOCATION)),1,14),'' '',''''),''VD'',''DP''),''L'',''DP'') ';
                    v_sql := v_sql || '        END ';
                    v_sql := v_sql || '        END ';
                    v_sql := v_sql || '       ,SUBSTR(REPLACE(D.CFO_BRL_CD, ''.'', ''''), 1, 4) ';
                    v_sql := v_sql || '       ,A.NFEE_KEY_BBL ';
                    v_sql := v_sql || '       ,XLAT.XLATLONGNAME ';
                    v_sql := v_sql || '       ,A.EF_LOC_BRL ';
                    v_sql := v_sql || '   ) A, ';
                    v_sql := v_sql || '  MSAFI.DSP_ESTABELECIMENTO F ';

                    v_sql := v_sql || 'WHERE A.EF_LOC_BRL = F.LOCATION ';

                    IF ( SUBSTR ( a_estabs ( i )
                                , 1
                                , 1 ) = 'U' ) THEN
                        --UF
                        v_sql :=
                               v_sql
                            || '      AND F.COD_ESTADO = '''
                            || SUBSTR ( a_estabs ( i )
                                      , 3
                                      , 2 )
                            || ''' ';
                    ELSIF ( SUBSTR ( a_estabs ( i )
                                   , 1
                                   , 1 ) = 'C' ) THEN
                        --CD
                        v_sql :=
                               v_sql
                            || '      AND F.COD_ESTAB     = '''
                            || SUBSTR ( a_estabs ( i )
                                      , 2
                                      , 5 )
                            || ''' AND F.TIPO = ''C'' ';
                    ELSIF ( SUBSTR ( a_estabs ( i )
                                   , 1
                                   , 1 ) = 'L' ) THEN
                        --FILIAL
                        v_sql :=
                               v_sql
                            || '      AND F.COD_ESTAB     = '''
                            || SUBSTR ( a_estabs ( i )
                                      , 2
                                      , 6 )
                            || ''' AND F.TIPO = ''L'' ';
                    END IF;

                    v_sql := v_sql || '  AND NOT EXISTS (SELECT /*+ parallel(16) */ ''Y'' ';
                    v_sql :=
                           v_sql
                        || '     FROM MSAF.X07_DOCTO_FISCAL partition for (TO_DATE('''
                        || TO_CHAR ( p_data_ini
                                   , 'YYYYMMDD' )
                        || ''',''YYYYMMDD''))  X07, ';
                    v_sql := v_sql || '          MSAF.X04_PESSOA_FIS_JUR X04 ';
                    v_sql := v_sql || '     WHERE X07.COD_EMPRESA = ''' || mcod_empresa || ''' ';
                    --V_SQL := V_SQL || '       AND X07.COD_ESTAB = ''DP909'' ';
                    v_sql :=
                           v_sql
                        || '       AND X07.DATA_FISCAL BETWEEN TO_DATE('''
                        || TO_CHAR ( p_data_ini
                                   , 'YYYYMMDD' )
                        || ''',''YYYYMMDD'') AND TO_DATE('''
                        || TO_CHAR ( p_data_fim
                                   , 'YYYYMMDD' )
                        || ''',''YYYYMMDD'') ';
                    --  V_SQL := V_SQL || '       AND X07.IDENTIF_DOCFIS LIKE ''S%'' ';
                    v_sql := v_sql || '       AND X07.IDENT_FIS_JUR = X04.IDENT_FIS_JUR ';
                    v_sql := v_sql || '       AND F.COD_ESTAB = X07.COD_ESTAB ';
                    v_sql := v_sql || '       AND A.NUMERO_NF = X07.NUM_DOCFIS ';
                    v_sql := v_sql || '       AND A.DT_EMISSAO = X07.DATA_FISCAL ';
                    v_sql := v_sql || '       AND A.ID_PEOPLE_SOFT = X07.NUM_CONTROLE_DOCTO) ';
                    v_sql := v_sql || '     ORDER BY 2, 1 ';

                    BEGIN
                        OPEN c_nf FOR v_sql;
                    EXCEPTION
                        WHEN OTHERS THEN
                            loga ( 'SQLERRM: ' || SQLERRM
                                 , FALSE );
                            loga ( SUBSTR ( v_sql
                                          , 1
                                          , 1024 )
                                 , FALSE );
                            loga ( SUBSTR ( v_sql
                                          , 1024
                                          , 1024 )
                                 , FALSE );
                            loga ( SUBSTR ( v_sql
                                          , 2048
                                          , 1024 )
                                 , FALSE );
                            loga ( SUBSTR ( v_sql
                                          , 3072
                                          , 1024 )
                                 , FALSE );
                            loga ( SUBSTR ( v_sql
                                          , 4096
                                          , 1024 )
                                 , FALSE );
                            raise_application_error ( -20344
                                                    , '!ERRO GERANDO RELATORIO! [1]' );
                    END;

                    LOOP
                        FETCH c_nf
                            BULK COLLECT INTO tab_nf
                            LIMIT 100;

                        FOR i IN 1 .. tab_nf.COUNT LOOP
                            IF v_class = 'a' THEN
                                v_class := 'b';
                            ELSE
                                v_class := 'a';
                            END IF;

                            v_text01 :=
                                dsp_planilha.linha (
                                                     p_conteudo =>    dsp_planilha.campo ( tab_nf ( i ).emitente )
                                                                   || --
                                                                     dsp_planilha.campo ( tab_nf ( i ).uf_emitente )
                                                                   || --
                                                                     dsp_planilha.campo (
                                                                                          dsp_planilha.texto (
                                                                                                               tab_nf (
                                                                                                                        i
                                                                                                               ).nf_brl_id
                                                                                          )
                                                                      )
                                                                   || --
                                                                     dsp_planilha.campo ( tab_nf ( i ).dt_emissao )
                                                                   || --
                                                                     dsp_planilha.campo ( tab_nf ( i ).dt_sefaz )
                                                                   || --
                                                                     dsp_planilha.campo (
                                                                                          dsp_planilha.texto (
                                                                                                               tab_nf (
                                                                                                                        i
                                                                                                               ).protocolo_sefaz
                                                                                          )
                                                                      )
                                                                   || --
                                                                     dsp_planilha.campo (
                                                                                          dsp_planilha.texto (
                                                                                                               tab_nf (
                                                                                                                        i
                                                                                                               ).numero_nf
                                                                                          )
                                                                      )
                                                                   || --
                                                                     dsp_planilha.campo (
                                                                                          dsp_planilha.texto (
                                                                                                               tab_nf (
                                                                                                                        i
                                                                                                               ).destin_bu
                                                                                          )
                                                                      )
                                                                   || --
                                                                     dsp_planilha.campo ( tab_nf ( i ).cfop )
                                                                   || --
                                                                     dsp_planilha.campo (
                                                                                          dsp_planilha.texto (
                                                                                                               tab_nf (
                                                                                                                        i
                                                                                                               ).chave_acesso
                                                                                          )
                                                                      )
                                                                   || --
                                                                     dsp_planilha.campo ( tab_nf ( i ).status )
                                                                   || --
                                                                     dsp_planilha.campo (
                                                                                          moeda (
                                                                                                  tab_nf ( i ).valor_tot_nf
                                                                                          )
                                                                      )
                                                                   || --
                                                                      ( CASE
                                                                           WHEN p_ext_carga = 'S' THEN --
                                                                                  dsp_planilha.campo (
                                                                                                          'EXEC MSAFI.PRC_MSAF_PS_NF_SAIDA('
                                                                                                       || --
                                                                                                         'P_COD_EMPRESA =>'''
                                                                                                       || mcod_empresa
                                                                                                       || ''''
                                                                                                       || --
                                                                                                         ',P_COD_ESTAB =>'''
                                                                                                       || tab_nf ( i ).emitente
                                                                                                       || ''''
                                                                                                       || --
                                                                                                         ',P_NF_BRL_ID =>'''
                                                                                                       || LPAD (
                                                                                                                 TRIM (
                                                                                                                        tab_nf (
                                                                                                                                 i
                                                                                                                        ).nf_brl_id
                                                                                                                 )
                                                                                                               , 10
                                                                                                               , '0'
                                                                                                          )
                                                                                                       || ''' '
                                                                                                       || --
                                                                                                         ',P_INSERE_AUDIT => ''0'''
                                                                                                       || --
                                                                                                         ');'
                                                                                  )
                                                                               || --
                                                                                 dsp_planilha.campo ( '-' )
                                                                       END )
                                                                   || --
                                                                     ''
                                                   , p_class => v_class
                                );

                            lib_proc.add ( v_text01
                                         , ptipo => v_id_arq );

                            COMMIT;
                        END LOOP;

                        tab_nf.delete;

                        EXIT WHEN c_nf%NOTFOUND;
                    END LOOP;

                    CLOSE c_nf;
                END LOOP; --(1)
            ELSE
                --(2)

                --- COMPARATIVO PEOPLE X MSAF - NOTAS EMITIDAS
                v_sql := 'SELECT  ';
                v_sql := v_sql || ' F.COD_ESTAB AS EMITENTE ';
                v_sql := v_sql || ',A.UF_EMITENTE ';
                v_sql := v_sql || ',A.ID_PEOPLE_SOFT ';
                v_sql := v_sql || ',A.DT_EMISSAO ';
                v_sql := v_sql || ',A.DT_SEFAZ ';
                v_sql := v_sql || ',A.PROTOCOLO_SEFAZ ';
                v_sql := v_sql || ',A.NUMERO_NF ';
                v_sql := v_sql || ',A.DESTIN_BU ';
                v_sql := v_sql || ',A.CFOP ';
                v_sql := v_sql || ',A.CHAVE_ACESSO ';
                v_sql := v_sql || ',A.STATUS_PEOPLESOFT ';
                v_sql := v_sql || ',A.VALOR_TOT_NF ';
                v_sql := v_sql || 'FROM ( ';
                v_sql := v_sql || '    SELECT /*+ DRIVING_SITE(A) */  A.SHIP_FROM_STATE AS UF_EMITENTE ';
                v_sql := v_sql || '          ,A.NF_BRL_ID AS ID_PEOPLE_SOFT ';
                v_sql := v_sql || '          ,A.NF_ISSUE_DT_BBL AS DT_EMISSAO ';
                v_sql := v_sql || '          ,E.NFEE_DT_BBL AS DT_SEFAZ ';
                v_sql := v_sql || '          ,E.NFEE_USE_BBL AS PROTOCOLO_SEFAZ ';
                v_sql := v_sql || '          ,A.NF_BRL AS NUMERO_NF ';
                v_sql := v_sql || '          ,CASE WHEN A.SHIP_TO_CUST_ID=''AR000000098'' THEN ';
                v_sql :=
                       v_sql
                    || '             CASE WHEN LTRIM(TRIM(REPLACE(REPLACE(REPLACE(NVL(TRIM(C.CGC_BRL),C.CPF_BRL),''.'',''''),''-'',''''),''/'','''')),''0'') IS NULL THEN A.EF_LOC_BRL ';
                v_sql :=
                       v_sql
                    || '             ELSE TRIM(SUBSTR(''CF'' || REPLACE(REPLACE(REPLACE(NVL(TRIM(C.CGC_BRL),C.CPF_BRL),''.'',''''),''-'',''''),''/'',''''),1,14)) ';
                v_sql := v_sql || '             END ';
                v_sql := v_sql || '          ELSE ';
                v_sql :=
                       v_sql
                    || '             CASE WHEN LENGTH(REPLACE(REPLACE(SUBSTR(NVL(NVL(TRIM(A.SHIP_TO_CUST_ID),TRIM(A.DESTIN_BU)),TRIM(A.LOCATION)),1,14),'' '',''''),''VD'',''DP'')) > 14 THEN ';
                v_sql :=
                       v_sql
                    || '                REPLACE(REPLACE(REPLACE(SUBSTR(NVL(NVL(TRIM(A.SHIP_TO_CUST_ID),TRIM(A.DESTIN_BU)),TRIM(A.LOCATION)),1,14),'' '',''''),''VD'',''DP''),''F000'',''F'') ';
                v_sql := v_sql || '             ELSE ';
                v_sql :=
                       v_sql
                    || '                REPLACE(REPLACE(REPLACE(SUBSTR(NVL(NVL(TRIM(A.SHIP_TO_CUST_ID),TRIM(A.DESTIN_BU)),TRIM(A.LOCATION)),1,14),'' '',''''),''VD'',''DP''),''L'',''DP'') ';
                v_sql := v_sql || '             END ';
                v_sql := v_sql || '          END AS DESTIN_BU ';
                v_sql := v_sql || '          ,SUBSTR(REPLACE(D.CFO_BRL_CD, ''.'', ''''), 1, 4) AS CFOP ';
                v_sql := v_sql || '          ,A.NFEE_KEY_BBL AS CHAVE_ACESSO ';
                v_sql := v_sql || '          ,XLAT.XLATLONGNAME AS STATUS_PEOPLESOFT ';
                v_sql := v_sql || '          ,SUM(A.GROSS_AMT_BSE) AS VALOR_TOT_NF ';
                v_sql := v_sql || '          ,A.EF_LOC_BRL ';

                v_sql := v_sql || '    FROM MSAFI.PS_NF_HDR_BBL_FS    A, ';
                v_sql := v_sql || '         MSAFI.PS_DSP_SOL_NFE_HDR  B, ';
                v_sql := v_sql || '         MSAFI.PS_DSP_SOL_NFE_ADR  C, ';
                v_sql := v_sql || '         MSAFI.PS_NF_LN_BBL_FS     D, ';
                v_sql := v_sql || '         MSAFI.PS_AR_NFRET_BBL     E, ';
                v_sql := v_sql || '         MSAFI.PSXLATITEM XLAT ';

                v_sql :=
                       v_sql
                    || '    WHERE A.NF_ISSUE_DT_BBL BETWEEN TO_DATE('''
                    || TO_CHAR ( p_data_ini
                               , 'YYYYMMDD' )
                    || ''',''YYYYMMDD'') AND TO_DATE('''
                    || TO_CHAR ( p_data_fim
                               , 'YYYYMMDD' )
                    || ''',''YYYYMMDD'') ';
                v_sql :=
                       v_sql
                    || '      AND A.NF_STATUS_BBL '
                    || v_filtro_status
                    || ' (''CNFM'', ''CNCL'', ''PRNT'', ''INTL'', ''DNGD'') ';

                v_sql := v_sql || '      AND B.BUSINESS_UNIT (+) = A.BUSINESS_UNIT ';
                v_sql := v_sql || '      AND B.NF_BRL_ID     (+) = A.NF_BRL_ID ';
                --V_SQL := V_SQL || '      AND A.BUSINESS_UNIT     = ''VD909'' ';

                v_sql := v_sql || '      AND B.DSP_TIPO_OPER (+) = ''V_AVISTA'' ';

                v_sql := v_sql || '      AND B.BUSINESS_UNIT = C.BUSINESS_UNIT (+) ';
                v_sql := v_sql || '      AND B.DSP_NFE_ID    = C.DSP_NFE_ID    (+) ';

                v_sql := v_sql || '      AND A.BUSINESS_UNIT = D.BUSINESS_UNIT ';
                v_sql := v_sql || '      AND A.NF_BRL_ID     = D.NF_BRL_ID ';

                v_sql := v_sql || '      AND A.BUSINESS_UNIT = E.BUSINESS_UNIT (+) ';
                v_sql := v_sql || '      AND A.NF_BRL_ID     = E.NF_BRL_ID     (+) ';

                v_sql := v_sql || '      AND XLAT.FIELDNAME  = ''NF_STATUS_BBL'' ';
                v_sql := v_sql || '      AND XLAT.FIELDVALUE = A.NF_STATUS_BBL ';

                v_sql := v_sql || '    GROUP BY A.SHIP_FROM_STATE ';
                v_sql := v_sql || '       ,A.NF_BRL_ID ';
                v_sql := v_sql || '       ,A.NF_ISSUE_DT_BBL ';
                v_sql := v_sql || '       ,E.NFEE_DT_BBL ';
                v_sql := v_sql || '       ,E.NFEE_USE_BBL ';
                v_sql := v_sql || '       ,A.NF_BRL ';
                v_sql := v_sql || '       ,CASE WHEN A.SHIP_TO_CUST_ID=''AR000000098'' THEN ';
                v_sql :=
                       v_sql
                    || '        CASE WHEN LTRIM(TRIM(REPLACE(REPLACE(REPLACE(NVL(TRIM(C.CGC_BRL),C.CPF_BRL),''.'',''''),''-'',''''),''/'','''')),''0'') IS NULL THEN A.EF_LOC_BRL ';
                v_sql :=
                       v_sql
                    || '        ELSE TRIM(SUBSTR(''CF'' || REPLACE(REPLACE(REPLACE(NVL(TRIM(C.CGC_BRL),C.CPF_BRL),''.'',''''),''-'',''''),''/'',''''),1,14)) ';
                v_sql := v_sql || '        END ';
                v_sql := v_sql || '        ELSE ';
                v_sql :=
                       v_sql
                    || '        CASE WHEN LENGTH(REPLACE(REPLACE(SUBSTR(NVL(NVL(TRIM(A.SHIP_TO_CUST_ID),TRIM(A.DESTIN_BU)),TRIM(A.LOCATION)),1,14),'' '',''''),''VD'',''DP'')) > 14 THEN ';
                v_sql :=
                       v_sql
                    || '        REPLACE(REPLACE(REPLACE(SUBSTR(NVL(NVL(TRIM(A.SHIP_TO_CUST_ID),TRIM(A.DESTIN_BU)),TRIM(A.LOCATION)),1,14),'' '',''''),''VD'',''DP''),''F000'',''F'') ';
                v_sql := v_sql || '        ELSE ';
                v_sql :=
                       v_sql
                    || '        REPLACE(REPLACE(REPLACE(SUBSTR(NVL(NVL(TRIM(A.SHIP_TO_CUST_ID),TRIM(A.DESTIN_BU)),TRIM(A.LOCATION)),1,14),'' '',''''),''VD'',''DP''),''L'',''DP'') ';
                v_sql := v_sql || '        END ';
                v_sql := v_sql || '        END ';
                v_sql := v_sql || '       ,SUBSTR(REPLACE(D.CFO_BRL_CD, ''.'', ''''), 1, 4) ';
                v_sql := v_sql || '       ,A.NFEE_KEY_BBL ';
                v_sql := v_sql || '       ,XLAT.XLATLONGNAME ';
                v_sql := v_sql || '       ,A.EF_LOC_BRL ';
                v_sql := v_sql || '   ) A, ';
                v_sql := v_sql || '   MSAFI.DSP_ESTABELECIMENTO F ';

                v_sql := v_sql || 'WHERE A.EF_LOC_BRL = F.LOCATION ';
                v_sql := v_sql || '  AND NOT EXISTS (SELECT /*+ parallel(16) */ ''Y'' ';
                v_sql :=
                       v_sql
                    || '     FROM MSAF.X07_DOCTO_FISCAL  partition for (TO_DATE('''
                    || TO_CHAR ( p_data_ini
                               , 'YYYYMMDD' )
                    || ''',''YYYYMMDD''))   X07, ';
                v_sql := v_sql || '          MSAF.X04_PESSOA_FIS_JUR X04 ';
                v_sql := v_sql || '     WHERE X07.COD_EMPRESA = ''' || mcod_empresa || ''' ';
                --V_SQL := V_SQL || '       AND X07.COD_ESTAB = ''DP909'' ';
                v_sql :=
                       v_sql
                    || '       AND X07.DATA_FISCAL BETWEEN TO_DATE('''
                    || TO_CHAR ( p_data_ini
                               , 'YYYYMMDD' )
                    || ''',''YYYYMMDD'') AND TO_DATE('''
                    || TO_CHAR ( p_data_fim
                               , 'YYYYMMDD' )
                    || ''',''YYYYMMDD'') ';
                --   V_SQL := V_SQL || '       AND X07.IDENTIF_DOCFIS LIKE ''S%'' ';
                v_sql := v_sql || '       AND X07.IDENT_FIS_JUR = X04.IDENT_FIS_JUR ';
                v_sql := v_sql || '       AND F.COD_ESTAB = X07.COD_ESTAB ';
                v_sql := v_sql || '       AND A.NUMERO_NF = X07.NUM_DOCFIS ';
                v_sql := v_sql || '       AND A.DT_EMISSAO = X07.DATA_FISCAL ';
                v_sql := v_sql || '       AND A.ID_PEOPLE_SOFT = X07.NUM_CONTROLE_DOCTO) ';
                v_sql := v_sql || '     ORDER BY 2, 1 ';

                BEGIN
                    OPEN c_nf FOR v_sql;
                EXCEPTION
                    WHEN OTHERS THEN
                        loga ( 'SQLERRM: ' || SQLERRM
                             , FALSE );
                        loga ( SUBSTR ( v_sql
                                      , 1
                                      , 1024 )
                             , FALSE );
                        loga ( SUBSTR ( v_sql
                                      , 1024
                                      , 1024 )
                             , FALSE );
                        loga ( SUBSTR ( v_sql
                                      , 2048
                                      , 1024 )
                             , FALSE );
                        loga ( SUBSTR ( v_sql
                                      , 3072
                                      , 1024 )
                             , FALSE );
                        loga ( SUBSTR ( v_sql
                                      , 4096
                                      , 1024 )
                             , FALSE );
                        raise_application_error ( -20344
                                                , '!ERRO GERANDO RELATORIO! [2]' );
                END;

                LOOP
                    FETCH c_nf
                        BULK COLLECT INTO tab_nf
                        LIMIT 100;

                    FOR i IN 1 .. tab_nf.COUNT LOOP
                        IF v_class = 'a' THEN
                            v_class := 'b';
                        ELSE
                            v_class := 'a';
                        END IF;

                        v_text01 :=
                            dsp_planilha.linha (
                                                 p_conteudo =>    dsp_planilha.campo ( tab_nf ( i ).emitente )
                                                               || -- EMITENTE ';
                                                                 dsp_planilha.campo ( tab_nf ( i ).uf_emitente )
                                                               || -- UF_EMITENTE ';
                                                                 dsp_planilha.campo (
                                                                                      dsp_planilha.texto (
                                                                                                           tab_nf (
                                                                                                                    i
                                                                                                           ).nf_brl_id
                                                                                      )
                                                                  )
                                                               || -- ID_PEOPLE_SOFT ';
                                                                 dsp_planilha.campo ( tab_nf ( i ).dt_emissao )
                                                               || -- DT_EMISSAO ';
                                                                 dsp_planilha.campo ( tab_nf ( i ).dt_sefaz )
                                                               || -- DT_SEFAZ ';
                                                                 dsp_planilha.campo (
                                                                                      dsp_planilha.texto (
                                                                                                           tab_nf (
                                                                                                                    i
                                                                                                           ).protocolo_sefaz
                                                                                      )
                                                                  )
                                                               || -- PROTOCOLO_SEFAZ ';
                                                                 dsp_planilha.campo (
                                                                                      dsp_planilha.texto (
                                                                                                           tab_nf (
                                                                                                                    i
                                                                                                           ).numero_nf
                                                                                      )
                                                                  )
                                                               || -- NUMERO_NF ';
                                                                 dsp_planilha.campo (
                                                                                      dsp_planilha.texto (
                                                                                                           tab_nf (
                                                                                                                    i
                                                                                                           ).destin_bu
                                                                                      )
                                                                                    , p_width => '100'
                                                                  )
                                                               || -- DESTIN_BU ';
                                                                 dsp_planilha.campo ( tab_nf ( i ).cfop )
                                                               || -- CFOP ';
                                                                 dsp_planilha.campo (
                                                                                      dsp_planilha.texto (
                                                                                                           tab_nf (
                                                                                                                    i
                                                                                                           ).chave_acesso
                                                                                      )
                                                                                    , p_width => '280'
                                                                  )
                                                               || -- CHAVE_ACESSO ';
                                                                 dsp_planilha.campo ( tab_nf ( i ).status )
                                                               || -- STATUS_PEOPLESOFT ';
                                                                 dsp_planilha.campo (
                                                                                      moeda (
                                                                                              tab_nf ( i ).valor_tot_nf
                                                                                      )
                                                                  ) -- VALOR_TOT_NF ';
                                               , p_class => v_class
                            );

                        lib_proc.add ( v_text01
                                     , ptipo => v_id_arq );

                        COMMIT;
                    END LOOP;

                    tab_nf.delete;

                    EXIT WHEN c_nf%NOTFOUND;
                END LOOP;

                CLOSE c_nf;
            END IF; --(2)

            lib_proc.add ( dsp_planilha.tabela_fim
                         , ptipo => v_id_arq );
        END IF; --(3)

        IF ( p_status = '3' ) THEN
            --(4)
            v_id_arq := v_id_arq + 1;

            lib_proc.add_tipo ( mproc_id
                              , v_id_arq
                              ,    mcod_empresa
                                || '_'
                                || TO_CHAR ( p_data_ini
                                           , 'MMYYYY' )
                                || '_REL_CONFRONTO_VLR_CONTAB_MSAF_PS.XLS'
                              , 2 );

            lib_proc.add ( dsp_planilha.header
                         , ptipo => v_id_arq );
            lib_proc.add ( dsp_planilha.tabela_inicio
                         , ptipo => v_id_arq );

            lib_proc.add ( dsp_planilha.linha ( p_conteudo => dsp_planilha.campo ( 'CONFRONTO ENTRADA MSAF PS'
                                                                                 , p_custom => 'COLSPAN=11' )
                                              , p_class => 'h' )
                         , ptipo => v_id_arq );

            lib_proc.add ( dsp_planilha.linha (
                                                p_conteudo =>    dsp_planilha.campo ( 'COD ESTAB' )
                                                              || --CONF.COD_ESTAB
                                                                dsp_planilha.campo ( 'UF_EMITENTE' )
                                                              || --CONF.UF_EMITENTE
                                                                dsp_planilha.campo ( 'ID_PEOPLESOFT' )
                                                              || --CONF.ID_PEOPLE_SOFT
                                                                dsp_planilha.campo ( 'DT_EMISSAO' )
                                                              || --CONF.DT_EMISSAO
                                                                dsp_planilha.campo ( 'DT_SEFAZ' )
                                                              || --CONF.DT_SEFAZ
                                                                dsp_planilha.campo ( 'PROTOCOLO_SEFAZ' )
                                                              || --CONF.PROTOCOLO_SEFAZ
                                                                dsp_planilha.campo ( 'NUMERO_NF' )
                                                              || --CONF.NUMERO_NF
                                                                dsp_planilha.campo ( 'CHAVE ACESSO' )
                                                              || --CONF.CHAVE_ACESSO
                                                                dsp_planilha.campo ( 'STATUS' )
                                                              || --CONF.STATUS_PEOPLESOFT
                                                                dsp_planilha.campo ( 'VLR_TOT_PSFT' )
                                                              || --CONF.VLR_TOT_PSFT
                                                                dsp_planilha.campo ( 'VLR_CONTAB_MSAF' ) --CONF.VLR_CONTAB_MSAF
                                              , p_class => 'h'
                           )
                         , ptipo => v_id_arq );

            FOR i IN 1 .. a_estabs.COUNT --(5)
                                        LOOP
                dbms_application_info.set_client_info ( a_estabs ( i ) || ';' || i || ';' || a_estabs.COUNT );

                v_sql := 'SELECT  CONF.COD_ESTAB         ';
                v_sql := v_sql || '       ,CONF.UF_EMITENTE       ';
                v_sql := v_sql || '       ,CONF.ID_PEOPLE_SOFT    ';
                v_sql := v_sql || '       ,CONF.DT_EMISSAO        ';
                v_sql := v_sql || '       ,CONF.DT_SEFAZ          ';
                v_sql := v_sql || '       ,CONF.PROTOCOLO_SEFAZ   ';
                v_sql := v_sql || '       ,CONF.NUMERO_NF         ';
                v_sql := v_sql || '       ,CONF.CHAVE_ACESSO      ';
                v_sql := v_sql || '       ,CONF.STATUS_PEOPLESOFT ';
                v_sql := v_sql || '       ,CONF.VLR_TOT_PSFT      ';
                v_sql := v_sql || '       ,CONF.VLR_CONTAB_MSAF   ';
                v_sql := v_sql || 'FROM (                         ';
                v_sql := v_sql || 'SELECT  B.COD_ESTAB         ';
                v_sql := v_sql || '       ,B.UF_EMITENTE       ';
                v_sql := v_sql || '       ,B.ID_PEOPLE_SOFT    ';
                v_sql := v_sql || '       ,B.DT_EMISSAO        ';
                v_sql := v_sql || '       ,B.DT_SEFAZ          ';
                v_sql := v_sql || '       ,B.PROTOCOLO_SEFAZ   ';
                v_sql := v_sql || '       ,B.NUMERO_NF         ';
                v_sql := v_sql || '       ,B.CHAVE_ACESSO      ';
                v_sql := v_sql || '       ,B.STATUS_PEOPLESOFT ';
                v_sql := v_sql || '       ,B.VLR_TOT_PSFT      ';
                v_sql := v_sql || '       ,A.VLR_CONTAB_MSAF   ';
                v_sql := v_sql || 'FROM                        ';

                v_sql := v_sql || '(SELECT /*+ parallel(16) */ CAP.COD_EMPRESA          AS EMPRESA,         ';
                v_sql := v_sql || '       CAP.COD_ESTAB             AS ESTAB,           ';
                v_sql := v_sql || '       CAP.NUM_CONTROLE_DOCTO    AS ID_PEOPLE,       ';
                v_sql := v_sql || '       CAP.DATA_FISCAL           AS DATA_EMISSAO,    ';
                v_sql := v_sql || '       CAP.NUM_DOCFIS            AS NUMERO_NF,       ';
                v_sql := v_sql || '       CAP.NUM_AUTENTIC_NFE      AS CHAVE_DE_ACESSO, ';
                v_sql := v_sql || '       CAP.VLR_TOT_NOTA          AS VLR_TOT_NOTA,    ';
                v_sql := v_sql || '       SUM(ITEM.VLR_CONTAB_ITEM) AS VLR_CONTAB_MSAF  ';
                v_sql :=
                       v_sql
                    || 'FROM MSAF.X07_DOCTO_FISCAL  partition for (TO_DATE('''
                    || TO_CHAR ( p_data_ini
                               , 'YYYYMMDD' )
                    || ''',''YYYYMMDD''))  CAP, ';
                v_sql := v_sql || '     MSAF.X08_ITENS_MERC    ITEM ';

                v_sql := v_sql || 'WHERE CAP.COD_EMPRESA   = ITEM.COD_EMPRESA   ';
                v_sql := v_sql || 'AND   CAP.COD_ESTAB     = ITEM.COD_ESTAB     ';
                v_sql := v_sql || 'AND   CAP.DATA_FISCAL   = ITEM.DATA_FISCAL   ';
                v_sql := v_sql || 'AND   CAP.MOVTO_E_S     = ITEM.MOVTO_E_S     ';
                v_sql := v_sql || 'AND   CAP.NORM_DEV      = ITEM.NORM_DEV      ';
                v_sql := v_sql || 'AND   CAP.IDENT_DOCTO   = ITEM.IDENT_DOCTO   ';
                v_sql := v_sql || 'AND   CAP.IDENT_FIS_JUR = ITEM.IDENT_FIS_JUR ';
                v_sql := v_sql || 'AND   CAP.NUM_DOCFIS    = ITEM.NUM_DOCFIS    ';
                v_sql := v_sql || 'AND   CAP.SERIE_DOCFIS  = ITEM.SERIE_DOCFIS  ';
                v_sql := v_sql || 'AND   CAP.COD_EMPRESA   = MSAFI.DPSP.EMPRESA ';
                v_sql :=
                       v_sql
                    || 'AND   CAP.DATA_FISCAL BETWEEN TO_DATE('''
                    || TO_CHAR ( p_data_ini
                               , 'YYYYMMDD' )
                    || ''',''YYYYMMDD'') AND TO_DATE('''
                    || TO_CHAR ( p_data_fim
                               , 'YYYYMMDD' )
                    || ''',''YYYYMMDD'') ';
                v_sql := v_sql || 'AND   CAP.IDENTIF_DOCFIS LIKE ''S%'' ';
                v_sql := v_sql || 'GROUP BY CAP.COD_EMPRESA     , ';
                v_sql := v_sql || '       CAP.COD_ESTAB         , ';
                v_sql := v_sql || '       CAP.DATA_FISCAL       , ';
                v_sql := v_sql || '       CAP.NUM_CONTROLE_DOCTO, ';
                v_sql := v_sql || '       CAP.NUM_DOCFIS        , ';
                v_sql := v_sql || '       CAP.NUM_AUTENTIC_NFE  , ';
                v_sql := v_sql || '       CAP.VLR_TOT_NOTA ) A,   ';

                v_sql := v_sql || '(SELECT /*+ DRIVING_SITE(A) */ ';
                v_sql := v_sql || '       A.EF_LOC_BRL         AS COD_ESTAB       ';
                v_sql := v_sql || '      ,A.SHIP_FROM_STATE    AS UF_EMITENTE     ';
                v_sql := v_sql || '      ,A.NF_BRL_ID          AS ID_PEOPLE_SOFT  ';
                v_sql := v_sql || '      ,A.NF_ISSUE_DT_BBL    AS DT_EMISSAO      ';
                v_sql := v_sql || '      ,E.NFEE_DT_BBL        AS DT_SEFAZ        ';
                v_sql := v_sql || '      ,E.NFEE_USE_BBL       AS PROTOCOLO_SEFAZ ';
                v_sql := v_sql || '      ,A.NF_BRL             AS NUMERO_NF       ';
                v_sql := v_sql || '      ,A.NFEE_KEY_BBL       AS CHAVE_ACESSO    ';
                v_sql := v_sql || '      ,XLAT.XLATLONGNAME    AS STATUS_PEOPLESOFT ';
                v_sql :=
                       v_sql
                    || '      ,ROUND(SUM(D.MERCH_AMT_BSE)+SUM(D.IPITAX_BRL_BSE)+SUM(D.ICMSSUB_BRL_BSE)+SUM(D.OTHEREXP_BRL_BSE)+SUM(D.FREIGHT_AMT_BSE),2) AS VLR_TOT_PSFT ';

                v_sql := v_sql || '      FROM MSAFI.PS_NF_HDR_BBL_FS    A, ';
                v_sql := v_sql || '           MSAFI.PS_DSP_SOL_NFE_HDR  B, ';
                v_sql := v_sql || '           MSAFI.PS_DSP_SOL_NFE_ADR  C, ';
                v_sql := v_sql || '           MSAFI.PS_NF_LN_BBL_FS     D, ';
                v_sql := v_sql || '           MSAFI.PS_AR_NFRET_BBL     E, ';
                v_sql := v_sql || '           MSAFI.PSXLATITEM        XLAT ';

                v_sql :=
                       v_sql
                    || 'WHERE A.NF_ISSUE_DT_BBL BETWEEN TO_DATE('''
                    || TO_CHAR ( p_data_ini
                               , 'YYYYMMDD' )
                    || ''',''YYYYMMDD'') AND TO_DATE('''
                    || TO_CHAR ( p_data_fim
                               , 'YYYYMMDD' )
                    || ''',''YYYYMMDD'') ';
                v_sql := v_sql || '  AND A.NF_STATUS_BBL IN (''CNFM'', ''CNCL'', ''PRNT'', ''INTL'', ''DNGD'') ';

                v_sql := v_sql || '  AND B.BUSINESS_UNIT (+) = A.BUSINESS_UNIT ';
                v_sql := v_sql || '  AND B.NF_BRL_ID     (+) = A.NF_BRL_ID     ';

                v_sql := v_sql || '  AND B.DSP_TIPO_OPER (+) = ''V_AVISTA'' ';

                v_sql := v_sql || '  AND B.BUSINESS_UNIT = C.BUSINESS_UNIT (+) ';
                v_sql := v_sql || '  AND B.DSP_NFE_ID    = C.DSP_NFE_ID    (+) ';

                v_sql := v_sql || '  AND A.BUSINESS_UNIT = D.BUSINESS_UNIT ';
                v_sql := v_sql || '  AND A.NF_BRL_ID     = D.NF_BRL_ID     ';

                v_sql := v_sql || '  AND A.BUSINESS_UNIT = E.BUSINESS_UNIT (+) ';
                v_sql := v_sql || '  AND A.NF_BRL_ID     = E.NF_BRL_ID     (+) ';

                v_sql := v_sql || '  AND XLAT.FIELDNAME  = ''NF_STATUS_BBL'' ';
                v_sql := v_sql || '  AND XLAT.FIELDVALUE = A.NF_STATUS_BBL ';

                v_sql := v_sql || 'GROUP BY ';
                v_sql := v_sql || '    A.EF_LOC_BRL       ';
                v_sql := v_sql || '   ,A.SHIP_FROM_STATE  ';
                v_sql := v_sql || '   ,A.NF_BRL_ID        ';
                v_sql := v_sql || '   ,A.NF_ISSUE_DT_BBL  ';
                v_sql := v_sql || '   ,E.NFEE_DT_BBL      ';
                v_sql := v_sql || '   ,E.NFEE_USE_BBL     ';
                v_sql := v_sql || '   ,A.NF_BRL           ';
                v_sql := v_sql || '   ,A.NFEE_KEY_BBL     ';
                v_sql := v_sql || '   ,XLAT.XLATLONGNAME  ';
                v_sql := v_sql || '   ) B ';

                v_sql := v_sql || 'WHERE B.COD_ESTAB      = A.ESTAB        (+) ';
                v_sql := v_sql || 'AND   B.NUMERO_NF      = A.NUMERO_NF    (+) ';
                v_sql := v_sql || 'AND   B.DT_EMISSAO     = A.DATA_EMISSAO (+) ';
                v_sql := v_sql || 'AND   B.ID_PEOPLE_SOFT = A.ID_PEOPLE    (+) ';
                v_sql := v_sql || 'AND   B.VLR_TOT_PSFT <> VLR_CONTAB_MSAF ';
                v_sql := v_sql || ') CONF, ';
                v_sql := v_sql || 'MSAFI.DSP_ESTABELECIMENTO EST ';
                v_sql := v_sql || 'WHERE CONF.COD_ESTAB  = EST.COD_ESTAB ';
                v_sql := v_sql || '  AND EST.COD_EMPRESA = MSAFI.DPSP.EMPRESA ';

                IF ( v_tem_grupo = 'Y' ) THEN
                    IF ( SUBSTR ( a_estabs ( i )
                                , 1
                                , 1 ) = 'U' ) THEN
                        --UF
                        v_sql :=
                               v_sql
                            || ' AND EST.COD_ESTADO = '''
                            || SUBSTR ( a_estabs ( i )
                                      , 3
                                      , 2 )
                            || ''' ';
                    ELSIF ( SUBSTR ( a_estabs ( i )
                                   , 1
                                   , 1 ) = 'C' ) THEN
                        --CD
                        v_sql :=
                               v_sql
                            || ' AND EST.COD_ESTAB     = '''
                            || SUBSTR ( a_estabs ( i )
                                      , 2
                                      , 5 )
                            || ''' AND EST.TIPO = ''C'' ';
                    ELSIF ( SUBSTR ( a_estabs ( i )
                                   , 1
                                   , 1 ) = 'L' ) THEN
                        --FILIAL
                        v_sql :=
                               v_sql
                            || ' AND EST.COD_ESTAB     = '''
                            || SUBSTR ( a_estabs ( i )
                                      , 2
                                      , 6 )
                            || ''' AND EST.TIPO = ''L'' ';
                    END IF;
                END IF;

                BEGIN
                    OPEN c_nf FOR v_sql;
                EXCEPTION
                    WHEN OTHERS THEN
                        loga ( 'SQLERRM: ' || SQLERRM
                             , FALSE );
                        loga ( SUBSTR ( v_sql
                                      , 1
                                      , 1024 )
                             , FALSE );
                        loga ( SUBSTR ( v_sql
                                      , 1024
                                      , 1024 )
                             , FALSE );
                        loga ( SUBSTR ( v_sql
                                      , 2048
                                      , 1024 )
                             , FALSE );
                        loga ( SUBSTR ( v_sql
                                      , 3072
                                      , 1024 )
                             , FALSE );
                        loga ( SUBSTR ( v_sql
                                      , 4096
                                      , 1024 )
                             , FALSE );
                        raise_application_error ( -20344
                                                , '!ERRO GERANDO RELATORIO!' );
                END;

                LOOP
                    FETCH c_nf
                        BULK COLLECT INTO tab_nf2
                        LIMIT 100;

                    FOR i IN 1 .. tab_nf2.COUNT LOOP
                        IF v_class = 'a' THEN
                            v_class := 'b';
                        ELSE
                            v_class := 'a';
                        END IF;

                        v_text01 :=
                            dsp_planilha.linha (
                                                 p_conteudo =>    dsp_planilha.campo ( tab_nf2 ( i ).cod_estab )
                                                               || dsp_planilha.campo ( tab_nf2 ( i ).uf_emitente )
                                                               || dsp_planilha.campo (
                                                                                       dsp_planilha.texto (
                                                                                                            tab_nf2 (
                                                                                                                      i
                                                                                                            ).id_people_soft
                                                                                       )
                                                                  )
                                                               || dsp_planilha.campo ( tab_nf2 ( i ).dt_emissao )
                                                               || dsp_planilha.campo ( tab_nf2 ( i ).dt_sefaz )
                                                               || dsp_planilha.campo (
                                                                                       dsp_planilha.texto (
                                                                                                            tab_nf2 (
                                                                                                                      i
                                                                                                            ).protocolo_sefaz
                                                                                       )
                                                                  )
                                                               || dsp_planilha.campo (
                                                                                       dsp_planilha.texto (
                                                                                                            tab_nf2 (
                                                                                                                      i
                                                                                                            ).numero_nf
                                                                                       )
                                                                  )
                                                               || dsp_planilha.campo (
                                                                                       dsp_planilha.texto (
                                                                                                            tab_nf2 (
                                                                                                                      i
                                                                                                            ).chave_acesso
                                                                                       )
                                                                                     , p_width => '280'
                                                                  )
                                                               || dsp_planilha.campo (
                                                                                       tab_nf2 ( i ).status_peoplesoft
                                                                  )
                                                               || dsp_planilha.campo (
                                                                                       moeda (
                                                                                               tab_nf2 ( i ).vlr_tot_psft
                                                                                       )
                                                                  )
                                                               || dsp_planilha.campo (
                                                                                       moeda (
                                                                                               tab_nf2 ( i ).vlr_contab_msaf
                                                                                       )
                                                                  )
                                               , p_class => v_class
                            );

                        lib_proc.add ( v_text01
                                     , ptipo => v_id_arq );

                        COMMIT;
                    END LOOP;

                    tab_nf2.delete;

                    EXIT WHEN c_nf%NOTFOUND;
                END LOOP;

                CLOSE c_nf;
            END LOOP; --(5)

            lib_proc.add ( dsp_planilha.tabela_fim
                         , ptipo => v_id_arq );
        END IF; --(4)

        IF ( p_status = '4'
         OR p_status = '99' ) THEN
            --(5)
            v_id_arq := v_id_arq + 1;

            lib_proc.add_tipo ( mproc_id
                              , v_id_arq
                              ,    mcod_empresa
                                || '_'
                                || TO_CHAR ( p_data_ini
                                           , 'MMYYYY' )
                                || '_REL_CONFRONTO_NF_ENTRADA_MSAF_PS.XLS'
                              , 2 );

            lib_proc.add ( dsp_planilha.header
                         , ptipo => v_id_arq );
            lib_proc.add ( dsp_planilha.tabela_inicio
                         , ptipo => v_id_arq );

            lib_proc.add ( dsp_planilha.linha ( p_conteudo => dsp_planilha.campo ( 'CONFRONTO ENTRADA MSAF PS'
                                                                                 , p_custom => 'COLSPAN=11' )
                                              , p_class => 'h' )
                         , ptipo => v_id_arq );

            lib_proc.add ( dsp_planilha.linha ( p_conteudo =>    dsp_planilha.campo ( 'COD_ESTAB' )
                                                              || --
                                                                dsp_planilha.campo ( 'ID_NF' )
                                                              || --
                                                                dsp_planilha.campo ( 'ID_PEOPLESOFT' )
                                                              || --
                                                                dsp_planilha.campo ( 'SERIE_NF' )
                                                              || --
                                                                dsp_planilha.campo ( 'DT_FISCAL' )
                                                              || --
                                                                dsp_planilha.campo ( 'CHAVE_NF' )
                                                              || --
                                                                dsp_planilha.campo ( 'UF' )
                                                              || --
                                                                dsp_planilha.campo ( 'STATUS' )
                                                              || --
                                                                dsp_planilha.campo ( 'DT_ULTIMA_ATUALIZACAO' )
                                                              || --
                                                                dsp_planilha.campo ( 'TIPO_NF' )
                                                              || --
                                                                dsp_planilha.campo ( 'VLR_TOT_NOTA' )
                                                              || --
                                                                 ( CASE
                                                                      WHEN p_ext_carga = 'S' THEN --
                                                                             dsp_planilha.campo (
                                                                                                  'CARREGAR NF'
                                                                                                , p_custom => 'BGCOLOR=green'
                                                                             )
                                                                          || --
                                                                            dsp_planilha.campo (
                                                                                                 '-'
                                                                                               , p_custom => 'BGCOLOR=green'
                                                                             )
                                                                  END ) --
                                                              || --
                                                                ''
                                              , p_class => 'h' )
                         , ptipo => v_id_arq );

            FOR i IN 1 .. a_estabs.COUNT --(6)
                                        LOOP
                dbms_application_info.set_client_info ( a_estabs ( i ) || ';' || i || ';' || a_estabs.COUNT );

                v_sql := 'SELECT /*+ DRIVING_SITE(A) */ A.EF_LOC_BRL AS COD_ESTAB,                      ';
                v_sql := v_sql || 'A.NF_BRL AS ID_NF,                                   ';
                v_sql := v_sql || 'A.NF_BRL_ID AS ID_PEOPLESOFT,                        ';
                v_sql := v_sql || 'A.NF_BRL_SERIES AS SERIE_NF,                         ';
                v_sql := v_sql || 'A.ACCOUNTING_DT AS DT_FISCAL,                        ';
                v_sql := v_sql || 'A.NFE_VERIF_CODE_PBL AS CHAVE_NF,                    ';
                v_sql := v_sql || 'EST.COD_ESTADO AS UF,                    ';
                v_sql := v_sql || 'DECODE(A.NF_BRL_STATUS,''F'',''Completo'') AS STATUS,    ';
                v_sql := v_sql || 'A.LAST_UPDATE_DT AS DT_ULTIMA_ATUALIZACAO,           ';
                v_sql := v_sql || 'A.NF_BRL_TYPE AS TIPO_NF,                            ';
                v_sql := v_sql || 'A.GROSS_AMT/1 AS VLR_TOT_NOTA                        ';
                v_sql := v_sql || 'FROM MSAFI.PS_NF_HDR_BRL A,                          ';
                v_sql := v_sql || 'MSAFI.DSP_ESTABELECIMENTO EST                        ';
                v_sql := v_sql || 'WHERE EST.COD_EMPRESA = ''' || mcod_empresa || ''' ';
                v_sql := v_sql || 'AND A.EF_LOC_BRL = EST.LOCATION                      ';

                IF ( v_tem_grupo = 'Y' ) THEN
                    --lOGA('ENTROU NO GRUPO');
                    IF ( SUBSTR ( a_estabs ( i )
                                , 1
                                , 1 ) = 'U' ) THEN
                        --UF
                        v_sql :=
                               v_sql
                            || ' AND EST.COD_ESTADO = '''
                            || SUBSTR ( a_estabs ( i )
                                      , 3
                                      , 2 )
                            || ''' ';
                    ELSIF ( SUBSTR ( a_estabs ( i )
                                   , 1
                                   , 1 ) = 'C' ) THEN
                        --CD
                        v_sql :=
                               v_sql
                            || ' AND EST.COD_ESTAB     = '''
                            || SUBSTR ( a_estabs ( i )
                                      , 2
                                      , 5 )
                            || ''' AND EST.TIPO = ''C'' ';
                    ELSIF ( SUBSTR ( a_estabs ( i )
                                   , 1
                                   , 1 ) = 'L' ) THEN
                        --FILIAL
                        v_sql :=
                               v_sql
                            || ' AND EST.COD_ESTAB     = '''
                            || SUBSTR ( a_estabs ( i )
                                      , 2
                                      , 6 )
                            || ''' AND EST.TIPO = ''L'' ';
                    END IF;
                END IF;

                v_sql :=
                       v_sql
                    || 'AND A.ACCOUNTING_DT BETWEEN TO_DATE('''
                    || TO_CHAR ( p_data_ini
                               , 'YYYYMMDD' )
                    || ''',''YYYYMMDD'') AND TO_DATE('''
                    || TO_CHAR ( p_data_fim
                               , 'YYYYMMDD' )
                    || ''',''YYYYMMDD'') ';
                v_sql := v_sql || 'AND A.NF_BRL_ID NOT LIKE ''C%''                        ';
                v_sql := v_sql || 'AND A.NF_BRL_STATUS = ''F''                            ';
                v_sql := v_sql || 'AND A.INOUT_FLG_PBL = ''I''                            ';
                v_sql := v_sql || 'AND A.NF_BRL_TYPE NOT IN (''GNR'',''GUI'')               ';
                v_sql := v_sql || 'AND A.NF_BRL_SERIES <> ''GAR''                         ';
                v_sql := v_sql || 'AND NOT EXISTS  (                                    ';
                v_sql :=
                       v_sql
                    || 'SELECT /*+ parallel(16) */ ''X'' FROM MSAF.X07_DOCTO_FISCAL  partition for (TO_DATE('''
                    || TO_CHAR ( p_data_ini
                               , 'YYYYMMDD' )
                    || ''',''YYYYMMDD''))  A1             ';
                v_sql := v_sql || 'WHERE A1.COD_EMPRESA = EST.COD_EMPRESA               ';
                v_sql := v_sql || 'AND   A1.COD_ESTAB   = EST.COD_ESTAB                 ';
                v_sql :=
                       v_sql
                    || 'AND   A1.DATA_FISCAL BETWEEN TO_DATE('''
                    || TO_CHAR ( p_data_ini
                               , 'YYYYMMDD' )
                    || ''',''YYYYMMDD'') AND TO_DATE('''
                    || TO_CHAR ( p_data_fim
                               , 'YYYYMMDD' )
                    || ''',''YYYYMMDD'') ';
                v_sql := v_sql || 'AND   A1.MOVTO_E_S <> ''9''                                ';
                v_sql := v_sql || 'AND   A.NF_BRL_ID  = replace(A1.NUM_CONTROLE_DOCTO,''C-'',''''))          ';
                v_sql := v_sql || 'ORDER BY A.EF_LOC_BRL         ';

                BEGIN
                    OPEN c_nf FOR v_sql;
                EXCEPTION
                    WHEN OTHERS THEN
                        loga ( 'SQLERRM: ' || SQLERRM
                             , FALSE );
                        loga ( SUBSTR ( v_sql
                                      , 1
                                      , 1024 )
                             , FALSE );
                        loga ( SUBSTR ( v_sql
                                      , 1024
                                      , 1024 )
                             , FALSE );
                        loga ( SUBSTR ( v_sql
                                      , 2048
                                      , 1024 )
                             , FALSE );
                        loga ( SUBSTR ( v_sql
                                      , 3072
                                      , 1024 )
                             , FALSE );
                        loga ( SUBSTR ( v_sql
                                      , 4096
                                      , 1024 )
                             , FALSE );
                        raise_application_error ( -20344
                                                , '!ERRO GERANDO RELATORIO!' );
                END;

                LOOP
                    FETCH c_nf
                        BULK COLLECT INTO tab_nf3
                        LIMIT 100;

                    FOR i IN 1 .. tab_nf3.COUNT LOOP
                        IF v_class = 'a' THEN
                            v_class := 'b';
                        ELSE
                            v_class := 'a';
                        END IF;

                        v_text01 :=
                            dsp_planilha.linha (
                                                 p_conteudo =>    dsp_planilha.campo ( tab_nf3 ( i ).cod_estab )
                                                               || --
                                                                 dsp_planilha.campo (
                                                                                      dsp_planilha.texto (
                                                                                                           tab_nf3 (
                                                                                                                     i
                                                                                                           ).id_nf
                                                                                      )
                                                                                    , p_width => '100'
                                                                  )
                                                               || --
                                                                 dsp_planilha.campo (
                                                                                      dsp_planilha.texto (
                                                                                                           tab_nf3 (
                                                                                                                     i
                                                                                                           ).id_peoplesoft
                                                                                      )
                                                                  )
                                                               || --
                                                                 dsp_planilha.campo (
                                                                                      dsp_planilha.texto (
                                                                                                           tab_nf3 (
                                                                                                                     i
                                                                                                           ).serie_nf
                                                                                      )
                                                                  )
                                                               || --
                                                                 dsp_planilha.campo ( tab_nf3 ( i ).dt_fiscal )
                                                               || --
                                                                 dsp_planilha.campo (
                                                                                      dsp_planilha.texto (
                                                                                                           tab_nf3 (
                                                                                                                     i
                                                                                                           ).chave_nf
                                                                                      )
                                                                                    , p_width => '280'
                                                                  )
                                                               || --
                                                                 dsp_planilha.campo ( tab_nf3 ( i ).uf )
                                                               || --
                                                                 dsp_planilha.campo ( tab_nf3 ( i ).status )
                                                               || --
                                                                 dsp_planilha.campo (
                                                                                      tab_nf3 ( i ).dt_ultima_atualizacao
                                                                  )
                                                               || --
                                                                 dsp_planilha.campo (
                                                                                      dsp_planilha.texto (
                                                                                                           tab_nf3 (
                                                                                                                     i
                                                                                                           ).tipo_nf
                                                                                      )
                                                                  )
                                                               || --
                                                                 dsp_planilha.campo (
                                                                                      moeda (
                                                                                              tab_nf3 ( i ).vlr_tot_nota
                                                                                      )
                                                                  )
                                                               || --
                                                                  ( CASE
                                                                       WHEN p_ext_carga = 'S' THEN --
                                                                              dsp_planilha.campo (
                                                                                                      'EXEC MSAFI.PRC_MSAF_PS_NF_ENTRADA('
                                                                                                   || --
                                                                                                     'P_DATAINI => '''
                                                                                                   || '19000101'
                                                                                                   || ''''
                                                                                                   || --
                                                                                                     ',P_DATAFIM => '''
                                                                                                   || TO_CHAR (
                                                                                                                LAST_DAY (
                                                                                                                           p_data_fim
                                                                                                                )
                                                                                                              , 'YYYYMMDD'
                                                                                                      )
                                                                                                   || ''''
                                                                                                   || --
                                                                                                     ',P_COD_EMPRESA=> '''
                                                                                                   || mcod_empresa
                                                                                                   || ''''
                                                                                                   || --
                                                                                                     ',P_COD_ESTAB=>'''
                                                                                                   || tab_nf3 ( i ).cod_estab
                                                                                                   || ''''
                                                                                                   || --
                                                                                                     ',P_NF_BRL_ID=> '''
                                                                                                   || tab_nf3 ( i ).id_peoplesoft
                                                                                                   || ''''
                                                                                                   || --
                                                                                                     ');'
                                                                              )
                                                                           || --
                                                                             dsp_planilha.campo ( '-' )
                                                                   END )
                                                               || --
                                                                 ''
                                               , p_class => v_class
                            );

                        lib_proc.add ( v_text01
                                     , ptipo => v_id_arq );
                        COMMIT;
                    END LOOP;

                    tab_nf3.delete;

                    EXIT WHEN c_nf%NOTFOUND;
                END LOOP;

                CLOSE c_nf;

                v_sql := '';
            END LOOP; --(6)

            lib_proc.add ( dsp_planilha.tabela_fim
                         , ptipo => v_id_arq );
        END IF; --(5)

        IF ( p_status = '5' ) THEN
            --(4)
            v_id_arq := v_id_arq + 1;

            lib_proc.add_tipo ( mproc_id
                              , v_id_arq
                              ,    mcod_empresa
                                || '_'
                                || TO_CHAR ( p_data_ini
                                           , 'MMYYYY' )
                                || '_REL_CONF_VLR_CONTAB_MSAF_PS_CFOP.XLS'
                              , 2 );

            lib_proc.add ( dsp_planilha.header
                         , ptipo => v_id_arq );
            lib_proc.add ( dsp_planilha.tabela_inicio
                         , ptipo => v_id_arq );

            lib_proc.add ( dsp_planilha.linha ( p_conteudo => dsp_planilha.campo ( 'CONFRONTO MSAF PS - CFOP'
                                                                                 , p_custom => 'COLSPAN=12' )
                                              , p_class => 'h' )
                         , ptipo => v_id_arq );

            lib_proc.add ( dsp_planilha.linha (
                                                p_conteudo =>    dsp_planilha.campo ( 'COD ESTAB' )
                                                              || --CONF.COD_ESTAB
                                                                dsp_planilha.campo ( 'UF_EMITENTE' )
                                                              || --CONF.UF_EMITENTE
                                                                dsp_planilha.campo ( 'ID_PEOPLESOFT' )
                                                              || --CONF.ID_PEOPLE_SOFT
                                                                dsp_planilha.campo ( 'DT_EMISSAO' )
                                                              || --CONF.DT_EMISSAO
                                                                dsp_planilha.campo ( 'DT_SEFAZ' )
                                                              || --CONF.DT_SEFAZ
                                                                dsp_planilha.campo ( 'PROTOCOLO_SEFAZ' )
                                                              || --CONF.PROTOCOLO_SEFAZ
                                                                dsp_planilha.campo ( 'NUMERO_NF' )
                                                              || --CONF.NUMERO_NF
                                                                dsp_planilha.campo ( 'CHAVE ACESSO' )
                                                              || --CONF.CHAVE_ACESSO
                                                                dsp_planilha.campo ( 'STATUS' )
                                                              || --CONF.STATUS_PEOPLESOFT
                                                                dsp_planilha.campo ( 'CFOP' )
                                                              || --CONF.COD_CFO
                                                                dsp_planilha.campo ( 'VLR_TOT_PSFT' )
                                                              || --CONF.VLR_TOT_PSFT
                                                                dsp_planilha.campo ( 'VLR_CONTAB_MSAF' ) --CONF.VLR_CONTAB_MSAF
                                              , p_class => 'h'
                           )
                         , ptipo => v_id_arq );

            FOR i IN 1 .. a_estabs.COUNT --(5)
                                        LOOP
                dbms_application_info.set_client_info ( a_estabs ( i ) || ';' || i || ';' || a_estabs.COUNT );

                v_sql := 'SELECT  CONF.COD_ESTAB         ';
                v_sql := v_sql || '       ,CONF.UF_EMITENTE       ';
                v_sql := v_sql || '       ,CONF.ID_PEOPLE_SOFT    ';
                v_sql := v_sql || '       ,CONF.DT_EMISSAO        ';
                v_sql := v_sql || '       ,CONF.DT_SEFAZ          ';
                v_sql := v_sql || '       ,CONF.PROTOCOLO_SEFAZ   ';
                v_sql := v_sql || '       ,CONF.NUMERO_NF         ';
                v_sql := v_sql || '       ,CONF.CHAVE_ACESSO      ';
                v_sql := v_sql || '       ,CONF.STATUS_PEOPLESOFT ';
                v_sql := v_sql || '       ,CONF.COD_CFO           ';
                v_sql := v_sql || '       ,CONF.VLR_TOT_PSFT      ';
                v_sql := v_sql || '       ,CONF.VLR_CONTAB_MSAF   ';
                v_sql := v_sql || 'FROM (                         ';
                v_sql := v_sql || 'SELECT  B.COD_ESTAB         ';
                v_sql := v_sql || '       ,B.UF_EMITENTE       ';
                v_sql := v_sql || '       ,B.ID_PEOPLE_SOFT    ';
                v_sql := v_sql || '       ,B.DT_EMISSAO        ';
                v_sql := v_sql || '       ,B.DT_SEFAZ          ';
                v_sql := v_sql || '       ,B.PROTOCOLO_SEFAZ   ';
                v_sql := v_sql || '       ,B.NUMERO_NF         ';
                v_sql := v_sql || '       ,B.CHAVE_ACESSO      ';
                v_sql := v_sql || '       ,B.STATUS_PEOPLESOFT ';
                v_sql := v_sql || '       ,B.COD_CFO           ';
                v_sql := v_sql || '       ,B.VLR_TOT_PSFT      ';
                v_sql := v_sql || '       ,A.VLR_CONTAB_MSAF   ';
                v_sql := v_sql || 'FROM                        ';

                v_sql := v_sql || '(SELECT /*+ parallel(16) */ CAP.COD_EMPRESA          AS EMPRESA,         ';
                v_sql := v_sql || '       CAP.COD_ESTAB             AS ESTAB,           ';
                v_sql := v_sql || '       CAP.NUM_CONTROLE_DOCTO    AS ID_PEOPLE,       ';
                v_sql := v_sql || '       CAP.DATA_FISCAL           AS DATA_EMISSAO,    ';
                v_sql := v_sql || '       CAP.NUM_DOCFIS            AS NUMERO_NF,       ';
                v_sql := v_sql || '       CAP.NUM_AUTENTIC_NFE      AS CHAVE_DE_ACESSO, ';
                v_sql := v_sql || '       CFOP.COD_CFO              AS COD_CFO,         ';
                v_sql := v_sql || '       CAP.VLR_TOT_NOTA          AS VLR_TOT_NOTA,    ';
                v_sql := v_sql || '       SUM(ITEM.VLR_CONTAB_ITEM) AS VLR_CONTAB_MSAF  ';
                v_sql :=
                       v_sql
                    || 'FROM MSAF.X07_DOCTO_FISCAL  partition for (TO_DATE('''
                    || TO_CHAR ( p_data_ini
                               , 'YYYYMMDD' )
                    || ''',''YYYYMMDD''))  CAP, ';
                v_sql :=
                       v_sql
                    || '     MSAF.X08_ITENS_MERC    partition for (TO_DATE('''
                    || TO_CHAR ( p_data_ini
                               , 'YYYYMMDD' )
                    || ''',''YYYYMMDD'')) ITEM, ';
                v_sql := v_sql || '     MSAF.X2012_COD_FISCAL  CFOP ';

                v_sql := v_sql || 'WHERE CAP.COD_EMPRESA   = ITEM.COD_EMPRESA   ';
                v_sql := v_sql || 'AND   CAP.COD_ESTAB     = ITEM.COD_ESTAB     ';
                v_sql := v_sql || 'AND   CAP.DATA_FISCAL   = ITEM.DATA_FISCAL   ';
                v_sql := v_sql || 'AND   CAP.MOVTO_E_S     = ITEM.MOVTO_E_S     ';
                v_sql := v_sql || 'AND   CAP.NORM_DEV      = ITEM.NORM_DEV      ';
                v_sql := v_sql || 'AND   CAP.IDENT_DOCTO   = ITEM.IDENT_DOCTO   ';
                v_sql := v_sql || 'AND   CAP.IDENT_FIS_JUR = ITEM.IDENT_FIS_JUR ';
                v_sql := v_sql || 'AND   CAP.NUM_DOCFIS    = ITEM.NUM_DOCFIS    ';
                v_sql := v_sql || 'AND   CAP.SERIE_DOCFIS  = ITEM.SERIE_DOCFIS  ';
                v_sql := v_sql || 'AND   CFOP.IDENT_CFO    = ITEM.IDENT_CFO     ';
                v_sql := v_sql || 'AND   CAP.COD_EMPRESA   = MSAFI.DPSP.EMPRESA ';
                v_sql :=
                       v_sql
                    || 'AND   CAP.DATA_FISCAL BETWEEN TO_DATE('''
                    || TO_CHAR ( p_data_ini
                               , 'YYYYMMDD' )
                    || ''',''YYYYMMDD'') AND TO_DATE('''
                    || TO_CHAR ( p_data_fim
                               , 'YYYYMMDD' )
                    || ''',''YYYYMMDD'') ';
                v_sql := v_sql || 'AND   CAP.IDENTIF_DOCFIS LIKE ''S%'' ';
                v_sql := v_sql || 'GROUP BY CAP.COD_EMPRESA     , ';
                v_sql := v_sql || '       CAP.COD_ESTAB         , ';
                v_sql := v_sql || '       CAP.DATA_FISCAL       , ';
                v_sql := v_sql || '       CAP.NUM_CONTROLE_DOCTO, ';
                v_sql := v_sql || '       CAP.NUM_DOCFIS        , ';
                v_sql := v_sql || '       CAP.NUM_AUTENTIC_NFE  , ';
                v_sql := v_sql || '       CFOP.COD_CFO          , ';
                v_sql := v_sql || '       CAP.VLR_TOT_NOTA ) A,   ';

                v_sql := v_sql || '(SELECT /*+ DRIVING_SITE(A) */ ';
                v_sql := v_sql || '       A.EF_LOC_BRL         AS COD_ESTAB       ';
                v_sql := v_sql || '      ,A.SHIP_FROM_STATE    AS UF_EMITENTE     ';
                v_sql := v_sql || '      ,A.NF_BRL_ID          AS ID_PEOPLE_SOFT  ';
                v_sql := v_sql || '      ,A.NF_ISSUE_DT_BBL    AS DT_EMISSAO      ';
                v_sql := v_sql || '      ,E.NFEE_DT_BBL        AS DT_SEFAZ        ';
                v_sql := v_sql || '      ,E.NFEE_USE_BBL       AS PROTOCOLO_SEFAZ ';
                v_sql := v_sql || '      ,A.NF_BRL             AS NUMERO_NF       ';
                v_sql := v_sql || '      ,A.NFEE_KEY_BBL       AS CHAVE_ACESSO    ';
                v_sql := v_sql || '      ,REPLACE(D.CFO_BRL_CD,''.'','''') AS COD_CFO ';
                v_sql := v_sql || '      ,XLAT.XLATLONGNAME    AS STATUS_PEOPLESOFT ';
                v_sql :=
                       v_sql
                    || '      ,ROUND(SUM(D.MERCH_AMT_BSE)+SUM(D.IPITAX_BRL_BSE)+SUM(D.ICMSSUB_BRL_BSE),2) AS VLR_TOT_PSFT ';

                v_sql := v_sql || '      FROM MSAFI.PS_NF_HDR_BBL_FS    A, ';
                v_sql := v_sql || '           MSAFI.PS_DSP_SOL_NFE_HDR  B, ';
                v_sql := v_sql || '           MSAFI.PS_DSP_SOL_NFE_ADR  C, ';
                v_sql := v_sql || '           MSAFI.PS_NF_LN_BBL_FS     D, ';
                v_sql := v_sql || '           MSAFI.PS_AR_NFRET_BBL     E, ';
                v_sql := v_sql || '           MSAFI.PSXLATITEM        XLAT ';

                v_sql :=
                       v_sql
                    || 'WHERE A.NF_ISSUE_DT_BBL BETWEEN TO_DATE('''
                    || TO_CHAR ( p_data_ini
                               , 'YYYYMMDD' )
                    || ''',''YYYYMMDD'') AND TO_DATE('''
                    || TO_CHAR ( p_data_fim
                               , 'YYYYMMDD' )
                    || ''',''YYYYMMDD'') ';
                v_sql := v_sql || '  AND A.NF_STATUS_BBL IN (''CNFM'', ''CNCL'', ''PRNT'', ''INTL'', ''DNGD'') ';

                v_sql := v_sql || '  AND B.BUSINESS_UNIT (+) = A.BUSINESS_UNIT ';
                v_sql := v_sql || '  AND B.NF_BRL_ID     (+) = A.NF_BRL_ID     ';

                v_sql := v_sql || '  AND B.DSP_TIPO_OPER (+) = ''V_AVISTA'' ';

                v_sql := v_sql || '  AND B.BUSINESS_UNIT = C.BUSINESS_UNIT (+) ';
                v_sql := v_sql || '  AND B.DSP_NFE_ID    = C.DSP_NFE_ID    (+) ';

                v_sql := v_sql || '  AND A.BUSINESS_UNIT = D.BUSINESS_UNIT ';
                v_sql := v_sql || '  AND A.NF_BRL_ID     = D.NF_BRL_ID     ';

                v_sql := v_sql || '  AND A.BUSINESS_UNIT = E.BUSINESS_UNIT (+) ';
                v_sql := v_sql || '  AND A.NF_BRL_ID     = E.NF_BRL_ID     (+) ';

                v_sql := v_sql || '  AND XLAT.FIELDNAME  = ''NF_STATUS_BBL'' ';
                v_sql := v_sql || '  AND XLAT.FIELDVALUE = A.NF_STATUS_BBL ';

                v_sql := v_sql || 'GROUP BY ';
                v_sql := v_sql || '    A.EF_LOC_BRL       ';
                v_sql := v_sql || '   ,A.SHIP_FROM_STATE  ';
                v_sql := v_sql || '   ,A.NF_BRL_ID        ';
                v_sql := v_sql || '   ,A.NF_ISSUE_DT_BBL  ';
                v_sql := v_sql || '   ,E.NFEE_DT_BBL      ';
                v_sql := v_sql || '   ,E.NFEE_USE_BBL     ';
                v_sql := v_sql || '   ,A.NF_BRL           ';
                v_sql := v_sql || '   ,A.NFEE_KEY_BBL     ';
                v_sql := v_sql || '   ,D.CFO_BRL_CD       ';
                v_sql := v_sql || '   ,XLAT.XLATLONGNAME  ';
                v_sql := v_sql || '   ) B ';

                v_sql := v_sql || 'WHERE B.COD_ESTAB      = A.ESTAB        (+) ';
                v_sql := v_sql || 'AND   B.NUMERO_NF      = A.NUMERO_NF    (+) ';
                v_sql := v_sql || 'AND   B.DT_EMISSAO     = A.DATA_EMISSAO (+) ';
                v_sql := v_sql || 'AND   B.ID_PEOPLE_SOFT = A.ID_PEOPLE    (+) ';
                v_sql := v_sql || 'AND   B.COD_CFO        = A.COD_CFO      (+) ';
                v_sql := v_sql || 'AND   B.VLR_TOT_PSFT <> VLR_CONTAB_MSAF ';
                v_sql := v_sql || ') CONF, ';
                v_sql := v_sql || 'MSAFI.DSP_ESTABELECIMENTO EST ';
                v_sql := v_sql || 'WHERE CONF.COD_ESTAB  = EST.COD_ESTAB ';
                v_sql := v_sql || '  AND EST.COD_EMPRESA = MSAFI.DPSP.EMPRESA ';

                IF ( v_tem_grupo = 'Y' ) THEN
                    IF ( SUBSTR ( a_estabs ( i )
                                , 1
                                , 1 ) = 'U' ) THEN
                        --UF
                        v_sql :=
                               v_sql
                            || ' AND EST.COD_ESTADO = '''
                            || SUBSTR ( a_estabs ( i )
                                      , 3
                                      , 2 )
                            || ''' ';
                    ELSIF ( SUBSTR ( a_estabs ( i )
                                   , 1
                                   , 1 ) = 'C' ) THEN
                        --CD
                        v_sql :=
                               v_sql
                            || ' AND EST.COD_ESTAB     = '''
                            || SUBSTR ( a_estabs ( i )
                                      , 2
                                      , 5 )
                            || ''' AND EST.TIPO = ''C'' ';
                    ELSIF ( SUBSTR ( a_estabs ( i )
                                   , 1
                                   , 1 ) = 'L' ) THEN
                        --FILIAL
                        v_sql :=
                               v_sql
                            || ' AND EST.COD_ESTAB     = '''
                            || SUBSTR ( a_estabs ( i )
                                      , 2
                                      , 6 )
                            || ''' AND EST.TIPO = ''L'' ';
                    END IF;
                END IF;

                BEGIN
                    OPEN c_nf FOR v_sql;
                EXCEPTION
                    WHEN OTHERS THEN
                        loga ( 'SQLERRM: ' || SQLERRM
                             , FALSE );
                        loga ( SUBSTR ( v_sql
                                      , 1
                                      , 1024 )
                             , FALSE );
                        loga ( SUBSTR ( v_sql
                                      , 1024
                                      , 1024 )
                             , FALSE );
                        loga ( SUBSTR ( v_sql
                                      , 2048
                                      , 1024 )
                             , FALSE );
                        loga ( SUBSTR ( v_sql
                                      , 3072
                                      , 1024 )
                             , FALSE );
                        loga ( SUBSTR ( v_sql
                                      , 4096
                                      , 1024 )
                             , FALSE );
                        raise_application_error ( -20344
                                                , '!ERRO GERANDO RELATORIO!' );
                END;

                LOOP
                    FETCH c_nf
                        BULK COLLECT INTO tab_nf5
                        LIMIT 100;

                    FOR i IN 1 .. tab_nf5.COUNT LOOP
                        IF v_class = 'a' THEN
                            v_class := 'b';
                        ELSE
                            v_class := 'a';
                        END IF;

                        v_text01 :=
                            dsp_planilha.linha (
                                                 p_conteudo =>    dsp_planilha.campo ( tab_nf5 ( i ).cod_estab )
                                                               || dsp_planilha.campo ( tab_nf5 ( i ).uf_emitente )
                                                               || dsp_planilha.campo (
                                                                                       dsp_planilha.texto (
                                                                                                            tab_nf5 (
                                                                                                                      i
                                                                                                            ).id_people_soft
                                                                                       )
                                                                  )
                                                               || dsp_planilha.campo ( tab_nf5 ( i ).dt_emissao )
                                                               || dsp_planilha.campo ( tab_nf5 ( i ).dt_sefaz )
                                                               || dsp_planilha.campo (
                                                                                       dsp_planilha.texto (
                                                                                                            tab_nf5 (
                                                                                                                      i
                                                                                                            ).protocolo_sefaz
                                                                                       )
                                                                  )
                                                               || dsp_planilha.campo (
                                                                                       dsp_planilha.texto (
                                                                                                            tab_nf5 (
                                                                                                                      i
                                                                                                            ).numero_nf
                                                                                       )
                                                                  )
                                                               || dsp_planilha.campo (
                                                                                       dsp_planilha.texto (
                                                                                                            tab_nf5 (
                                                                                                                      i
                                                                                                            ).chave_acesso
                                                                                       )
                                                                                     , p_width => '280'
                                                                  )
                                                               || dsp_planilha.campo (
                                                                                       tab_nf5 ( i ).status_peoplesoft
                                                                  )
                                                               || dsp_planilha.campo ( tab_nf5 ( i ).cod_cfo )
                                                               || dsp_planilha.campo (
                                                                                       moeda (
                                                                                               tab_nf5 ( i ).vlr_tot_psft
                                                                                       )
                                                                  )
                                                               || dsp_planilha.campo (
                                                                                       moeda (
                                                                                               tab_nf5 ( i ).vlr_contab_msaf
                                                                                       )
                                                                  )
                                               , p_class => v_class
                            );

                        lib_proc.add ( v_text01
                                     , ptipo => v_id_arq );
                        COMMIT;
                    END LOOP;

                    tab_nf5.delete;

                    EXIT WHEN c_nf%NOTFOUND;
                END LOOP;

                CLOSE c_nf;
            END LOOP; --(5)

            lib_proc.add ( dsp_planilha.tabela_fim
                         , ptipo => v_id_arq );
        END IF; --(4)

        ---MONTAR RELATORIO-FIM--------------------------------------------------------------------------------

        loga ( '[FIM] RELATORIO'
             , TRUE );
        v_proc_status := 2;

        v_s_proc_status :=
            CASE v_proc_status
                WHEN 0 THEN 'ERROI#0' --NUNCA DEVE SER 0, POIS J¡ VIRA 1 NO INÕCIO!
                WHEN 1 THEN 'ERROI#1' --AINDA EST¡ EM PROCESSO!??!? ERRO NO PROCESSO!
                WHEN 2 THEN 'SUCESSO'
                WHEN 3 THEN 'AVISOS'
                WHEN 4 THEN 'ERRO'
                ELSE 'ERROI#' || v_proc_status
            END;

        loga ( 'FIM DO PROCESSAMENTO, STATUS FINAL: [' || v_s_proc_status || ']'
             , FALSE );
        msafi.dsp_control.updateprocess ( v_s_proc_status );

        lib_proc.close ( );

        COMMIT;
        RETURN mproc_id;
    EXCEPTION
        WHEN OTHERS THEN
            msafi.dsp_control.log_checkpoint ( SQLERRM
                                             , 'Erro n„o tratado, executador de interfaces' );

            loga ( 'SQLERRM: ' || SQLERRM
                 , FALSE );

            lib_proc.add_log ( 'Erro n„o tratado: ' || dbms_utility.format_error_backtrace
                             , 1 );
            lib_proc.add_log ( 'SQLERRM: ' || SQLERRM
                             , 1 );
            lib_proc.add ( 'ERRO!' );
            lib_proc.add ( dbms_utility.format_error_backtrace );
            lib_proc.close;
            COMMIT;
            RETURN mproc_id;
    END; /* FUNCTION EXECUTAR */
END dpsp_rel_conf_ps_cproc;
/
SHOW ERRORS;
