Prompt Package Body DPSP_REL_EX_PIS_COFINS_CPROC;
--
-- DPSP_REL_EX_PIS_COFINS_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_rel_ex_pis_cofins_cproc
IS
    mcod_empresa empresa.cod_empresa%TYPE;
    mproc_id INTEGER;
    mproc_id_o INTEGER;
    v_quant_empresas INTEGER := 1;

    --Tipo, Nome e Descrição do Customizado
    mnm_tipo VARCHAR2 ( 100 ) := 'Ressarcimento';
    mnm_cproc VARCHAR2 ( 100 ) := 'Relatório Dados Exclusão de ICMS da BC PIS/Cofins';
    mds_cproc VARCHAR2 ( 100 ) := mnm_cproc;

    v_sel_data_fim VARCHAR2 ( 260 )
        := 'SELECT TRUNC( TO_DATE( :1 ,''DD/MM/YYYY'') + ROWNUM - 1) AS DATA_FIM, TRUNC( TO_DATE( :1 ,''DD/MM/YYYY'') + ROWNUM - 1) AS DATA_FIM FROM DUAL CONNECT BY ROWNUM <= LAST_DAY( TO_DATE( :1 ,''DD/MM/YYYY'') ) - TO_DATE( :1 ,''DD/MM/YYYY'') + 1 ORDER BY 1 DESC ';

    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );
    BEGIN
        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );

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
                            'VARCHAR2'
                           , 'COMBOBOX'
                           , 'S'
                           , NULL
                           , '##########'
                           , v_sel_data_fim );

        /*    lib_proc.add_param(pstr,
        'Data Final', --P_DATA_FIM
        'DATE',
        'TEXTBOX',
        'S',
        NULL,
        'DD/MM/YYYY');*/

        lib_proc.add_param ( pparam => pstr
                           , ptitulo =>    LPAD ( ' '
                                                , 20
                                                , ' ' )
                                        || LPAD ( '_'
                                                , 50
                                                , '_' )
                           , ptipo => 'Varchar2'
                           , pcontrole => 'Text'
                           , pmandatorio => 'N'
                           , pdefault => 'N'
                           , pmascara => NULL
                           , pvalores => NULL
                           , papresenta => 'N' );

        lib_proc.add_param ( pparam => pstr
                           , -- P_REL
                            ptitulo => 'Processo'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'RADIOBUTTON'
                           , pmandatorio => 'S'
                           , pdefault => '2'
                           , pvalores => '2=Relatório analítico,' || --
                                                                      '3=Relatório sintético' );

        lib_proc.add_param (
                             pparam => pstr
                           , --P_UF
                            ptitulo => 'UF'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'COMBOBOX'
                           , pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => '####################'
                           , pvalores => 'SELECT DISTINCT A.COD_ESTADO, A.COD_ESTADO FROM MSAFI.DSP_ESTABELECIMENTO A UNION ALL SELECT ''%'', ''--TODAS--'' FROM DUAL ORDER BY 1'
        );

        lib_proc.add_param ( pstr
                           , 'Filtrar Lista Neutra'
                           , 'VARCHAR2'
                           , 'CHECKBOX'
                           , 'N'
                           , 'N'
                           , NULL );
        lib_proc.add_param ( pstr
                           , 'Agrupar por CFOP'
                           , 'VARCHAR2'
                           , 'CHECKBOX'
                           , 'N'
                           , 'N'
                           , NULL
                           , phabilita => ' :4 = 3 ' );

        lib_proc.add_param (
                             pstr
                           , 'Estabelecimentos'
                           , --P_LOJAS
                            'VARCHAR2'
                           , 'MULTISELECT'
                           , 'S'
                           , NULL
                           , NULL
                           ,    ' SELECT COD_ESTAB COD , COD_ESTADO||'' - ''||COD_ESTAB||'' - ''||INITCAP(ENDER) ||'' ''||(CASE WHEN TIPO = ''C'' THEN ''(CD)'' END) LOJA'
                             || --
                               ' FROM DSP_ESTABELECIMENTO_V WHERE 1=1 '
                             || ' AND COD_EMPRESA = '''
                             || mcod_empresa
                             || ''' AND COD_ESTADO LIKE :5  ORDER BY TIPO, 2'
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
        RETURN 'VERSAO 1.0';
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

    PROCEDURE loga ( p_i_texto IN VARCHAR2
                   , p_i_dttm IN BOOLEAN DEFAULT TRUE )
    IS
        vtexto VARCHAR2 ( 1024 );
    BEGIN
        dbms_output.put_line ( p_i_texto );

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
    ---
    END;

    FUNCTION moeda ( v_conteudo NUMBER )
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN TRIM ( TO_CHAR ( v_conteudo
                              , '9g999g999g990d00' ) );
    END;

    PROCEDURE envia_email ( vp_cod_empresa IN VARCHAR2
                          , vp_data_ini IN DATE
                          , vp_data_fim IN DATE
                          , vp_msg_oracle IN VARCHAR2
                          , vp_tipo IN VARCHAR2
                          , vp_data_hora_ini IN VARCHAR2 )
    IS
        v_txt_email VARCHAR2 ( 2000 ) := '';
        v_assunto VARCHAR2 ( 100 ) := '';
        v_horas NUMBER;
        v_minutos NUMBER;
        v_segundos NUMBER;
        v_tempo_exec VARCHAR2 ( 50 );
    BEGIN
        --CALCULAR TEMPO DE EXECUCAO DO RELATORIO
        SELECT   TRUNC (   (   (   86400
                                 * (   SYSDATE
                                     - TO_DATE ( vp_data_hora_ini
                                               , 'DD/MM/YYYY HH24:MI.SS' ) ) )
                             / 60 )
                         / 60 )
               -   24
                 * ( TRUNC (   (   (   (   86400
                                         * (   SYSDATE
                                             - TO_DATE ( vp_data_hora_ini
                                                       , 'DD/MM/YYYY HH24:MI.SS' ) ) )
                                     / 60 )
                                 / 60 )
                             / 24 ) )
             ,   TRUNC (   (   86400
                             * (   SYSDATE
                                 - TO_DATE ( vp_data_hora_ini
                                           , 'DD/MM/YYYY HH24:MI.SS' ) ) )
                         / 60 )
               -   60
                 * ( TRUNC (   (   (   86400
                                     * (   SYSDATE
                                         - TO_DATE ( vp_data_hora_ini
                                                   , 'DD/MM/YYYY HH24:MI.SS' ) ) )
                                 / 60 )
                             / 60 ) )
             ,   TRUNC (   86400
                         * (   SYSDATE
                             - TO_DATE ( vp_data_hora_ini
                                       , 'DD/MM/YYYY HH24:MI.SS' ) ) )
               -   60
                 * ( TRUNC (   (   86400
                                 * (   SYSDATE
                                     - TO_DATE ( vp_data_hora_ini
                                               , 'DD/MM/YYYY HH24:MI.SS' ) ) )
                             / 60 ) )
          INTO v_horas
             , v_minutos
             , v_segundos
          FROM DUAL;

        v_tempo_exec := v_horas || ':' || v_minutos || '.' || v_segundos;

        IF ( vp_tipo = 'E' ) THEN
            --VP_TIPO = 'E' (ERRO) OU 'S' (SUCESSO)

            v_txt_email := 'ERRO no Processo Exclusao ICMS!';
            v_txt_email := v_txt_email || CHR ( 13 ) || '>> Parâmetros: ';
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Empresa : ' || vp_cod_empresa;
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Data Início : ' || vp_data_ini;
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Data Fim : ' || vp_data_fim;
            v_txt_email := v_txt_email || CHR ( 13 ) || '>> LOG: ';
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Executado por : ' || musuario;
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Hora Início : ' || vp_data_hora_ini;
            v_txt_email :=
                   v_txt_email
                || CHR ( 13 )
                || ' - Hora Término : '
                || TO_CHAR ( SYSDATE
                           , 'DD/MM/YYYY HH24:MI.SS' );
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Tempo Execução	: ' || v_tempo_exec;
            v_txt_email := v_txt_email || CHR ( 13 ) || '<< ERRO >> ' || vp_msg_oracle;
            v_assunto := 'Mastersaf - Relatorio Exclusao ICMS apresentou ERRO';
            notifica ( ''
                     , 'S'
                     , v_assunto
                     , v_txt_email
                     , $$plsql_unit );
        ELSE
            v_txt_email := 'Processo Exclusao ICMS finalizado com SUCESSO.';
            v_txt_email := v_txt_email || CHR ( 13 ) || '>> Parâmetros: ';
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Empresa : ' || vp_cod_empresa;
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Data Início : ' || vp_data_ini;
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Data Fim : ' || vp_data_fim;
            v_txt_email := v_txt_email || CHR ( 13 ) || '>> LOG: ';
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Executado por : ' || musuario;
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Hora Início : ' || vp_data_hora_ini;
            v_txt_email :=
                   v_txt_email
                || CHR ( 13 )
                || ' - Hora Término : '
                || TO_CHAR ( SYSDATE
                           , 'DD/MM/YYYY HH24:MI.SS' );
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Tempo Execução : ' || v_tempo_exec;
            v_assunto := 'Mastersaf - Relatorio Exclusao ICMS Concluido';
            notifica ( 'S'
                     , ''
                     , v_assunto
                     , v_txt_email
                     , $$plsql_unit );
        END IF;
    END;

    PROCEDURE grava ( p_texto VARCHAR2
                    , p_tipo VARCHAR2 DEFAULT '1' )
    IS
    BEGIN
        lib_proc.add ( p_texto
                     , ptipo => p_tipo );
    END;

    PROCEDURE cabecalho_analitico ( p_cod_estab VARCHAR2
                                  , p_tipo VARCHAR2 DEFAULT '1' )
    IS
        v_cl_01 VARCHAR2 ( 6 ) := 'AAAAAA';
        v_cl_02 VARCHAR2 ( 6 ) := '55AA55';
    BEGIN
        grava ( dsp_planilha.linha (    dsp_planilha.campo ( 'SAIDAS ' || p_cod_estab
                                                           , p_custom => 'COLSPAN=30' )
                                     || --
                                       dsp_planilha.campo ( 'ENTRADAS'
                                                          , p_custom => 'COLSPAN=32 BGCOLOR="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'CALCULO'
                                                          , p_custom => 'COLSPAN=2 BGCOLOR="#' || v_cl_02 || '"' )
                                   , --
                                    p_class => 'H' )
              , p_tipo );
        grava ( dsp_planilha.linha (    dsp_planilha.campo ( 'COD_EMPRESA' )
                                     || --
                                       dsp_planilha.campo ( 'COD_ESTAB' )
                                     || --
                                       dsp_planilha.campo ( 'UF_ESTAB' )
                                     || --
                                       dsp_planilha.campo ( 'DATA_FISCAL' )
                                     || --
                                       dsp_planilha.campo ( 'COD_DOCTO' )
                                     || --
                                       dsp_planilha.campo ( 'NUM_DOCFIS' )
                                     || --
                                       dsp_planilha.campo ( 'SERIE_DOCFIS' )
                                     || --
                                       dsp_planilha.campo ( 'NUM_AUTENTIC_NFE'
                                                          , p_width => 280 )
                                     || --
                                       dsp_planilha.campo ( 'COD_PRODUTO' )
                                     || --
                                       dsp_planilha.campo ( 'DESCRICAO' )
                                     || --
                                       dsp_planilha.campo ( 'NUM_ITEM' )
                                     || --
                                       dsp_planilha.campo ( 'COD_CFO' )
                                     || --
                                       dsp_planilha.campo ( 'COD_NBM' )
                                     || --
                                       dsp_planilha.campo ( 'LISTA' )
                                     || --
                                        --DSP_PLANILHA.CAMPO('CST_TAB') || --
                                        dsp_planilha.campo ( 'QUANTIDADE' )
                                     || --
                                       dsp_planilha.campo ( 'VLR_ITEM' )
                                     || --
                                       dsp_planilha.campo ( 'VLR_CONTAB_ITEM' )
                                     || --
                                       dsp_planilha.campo ( 'VLR_OUTRAS' )
                                     || --
                                       dsp_planilha.campo ( 'VLR_DESCONTO' )
                                     || --
                                       dsp_planilha.campo ( 'VLR_BASE_ICMS' )
                                     || --
                                       dsp_planilha.campo ( 'ALIQ_ICMS' )
                                     || --
                                       dsp_planilha.campo ( 'VLR_ICMS' )
                                     || --
                                       dsp_planilha.campo ( 'COD_SITUACAO_PIS' )
                                     || --
                                       dsp_planilha.campo ( 'VLR_BASE_PIS' )
                                     || --
                                       dsp_planilha.campo ( 'VLR_ALIQ_PIS' )
                                     || --
                                       dsp_planilha.campo ( 'VLR_PIS' )
                                     || --
                                       dsp_planilha.campo ( 'COD_SITUACAO_COFINS' )
                                     || --
                                       dsp_planilha.campo ( 'VLR_BASE_COFINS' )
                                     || --
                                       dsp_planilha.campo ( 'VLR_ALIQ_COFINS' )
                                     || --
                                       dsp_planilha.campo ( 'VLR_COFINS' )
                                     || --
                                        ----
                                        dsp_planilha.campo ( 'COD_ESTAB'
                                                           , p_custom => 'BGCOLOR="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'DATA_FISCAL'
                                                          , p_custom => 'BGCOLOR="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'NUM_DOCFIS'
                                                          , p_custom => 'BGCOLOR="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'SERIE_DOCFIS'
                                                          , p_custom => 'BGCOLOR="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'NUM_CONTROLE_DOCTO'
                                                          , p_custom => 'BGCOLOR="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'NUM_AUTENTIC_NFE'
                                                          , p_custom => 'BGCOLOR="#' || v_cl_01 || '"'
                                                          , p_width => 280 )
                                     || --
                                       dsp_planilha.campo ( 'NUM_ITEM'
                                                          , p_custom => 'BGCOLOR="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'COD_CFO'
                                                          , p_custom => 'BGCOLOR="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'COD_CFO_SAIDA'
                                                          , p_custom => 'BGCOLOR="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'QUANTIDADE'
                                                          , p_custom => 'BGCOLOR="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'VLR_ITEM'
                                                          , p_custom => 'BGCOLOR="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'VLR_CONTAB_ITEM'
                                                          , p_custom => 'BGCOLOR="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'VLR_OUTRAS'
                                                          , p_custom => 'BGCOLOR="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'VLR_DESCONTO'
                                                          , p_custom => 'BGCOLOR="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'VLR_BASE_ICMS'
                                                          , p_custom => 'BGCOLOR="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'VLR_ICMS'
                                                          , p_custom => 'BGCOLOR="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'VLR_BASE_ICMS_ST'
                                                          , p_custom => 'BGCOLOR="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'VLR_ICMS_ST'
                                                          , p_custom => 'BGCOLOR="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'COD_SITUACAO_PIS'
                                                          , p_custom => 'BGCOLOR="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'VLR_BASE_PIS'
                                                          , p_custom => 'BGCOLOR="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'VLR_ALIQ_PIS'
                                                          , p_custom => 'BGCOLOR="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'VLR_PIS'
                                                          , p_custom => 'BGCOLOR="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'COD_SITUACAO_COFINS'
                                                          , p_custom => 'BGCOLOR="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'VLR_BASE_COFINS'
                                                          , p_custom => 'BGCOLOR="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'VLR_ALIQ_COFINS'
                                                          , p_custom => 'BGCOLOR="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'VLR_COFINS'
                                                          , p_custom => 'BGCOLOR="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'VLR_ICMSS_N_ESCRIT'
                                                          , p_custom => 'BGCOLOR="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'VLR_ICMS_UNIT'
                                                          , p_custom => 'BGCOLOR="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'VLR_ICMS_ST_UNIT'
                                                          , p_custom => 'BGCOLOR="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'VLR_ICMS_ST_UNIT_AUX'
                                                          , p_custom => 'BGCOLOR="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'VLR_ICMS_ST_UNIT_XML'
                                                          , p_custom => 'BGCOLOR="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'VLR_ICMS_ST_UNIT_RET_XML'
                                                          , p_custom => 'BGCOLOR="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'BASE'
                                                          , p_custom => 'BGCOLOR="#' || v_cl_02 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'VALOR'
                                                          , p_custom => 'BGCOLOR="#' || v_cl_02 || '"' ) --
                                   , p_class => 'H' )
              , p_tipo );
    END;

    PROCEDURE cabecalho_sintetico ( p_tipo VARCHAR2 DEFAULT '1' )
    IS
    BEGIN
        grava ( dsp_planilha.linha ( dsp_planilha.campo ( 'RELATORIO SINTETICO'
                                                        , p_custom => 'COLSPAN=13' )
                                   , p_class => 'H' )
              , p_tipo );

        grava ( dsp_planilha.linha (
                                        dsp_planilha.campo ( 'COD_ESTAB' )
                                     || --
                                       dsp_planilha.campo ( 'UF' )
                                     || --
                                       dsp_planilha.campo ( 'DATA FISCAL' )
                                     || --
                                       dsp_planilha.campo ( 'CFOP' )
                                     || --
                                       dsp_planilha.campo ( 'LISTA' )
                                     || --
                                       dsp_planilha.campo ( 'ICMS_SAIDA' )
                                     || --
                                       dsp_planilha.campo ( 'ICMS_UNIT_ENT' )
                                     || --
                                       dsp_planilha.campo ( 'VLR_ST_UNIT' )
                                     || --
                                       dsp_planilha.campo ( 'VLR_ST_UNIT_AUX' )
                                     || --
                                       dsp_planilha.campo ( 'VLR_ST_UNIT_XML' )
                                     || --
                                       dsp_planilha.campo ( 'VLR_ST_UNIT_RET_XML' )
                                     || --
                                       dsp_planilha.campo ( 'BASE VLR CALCULADO' )
                                     || --
                                       dsp_planilha.campo ( 'VLR CALCULADO' )
                                   , p_class => 'H'
                )
              , p_tipo );
    END;

    PROCEDURE grava_analitico ( p_cod_estab VARCHAR2
                              , vp_data_ini DATE
                              , vp_data_fim DATE
                              , p_lst_neutra VARCHAR2
                              , p_tipo VARCHAR2 DEFAULT '1' )
    IS
        v_tipo VARCHAR2 ( 30 ) := p_tipo;
        v_class_linha VARCHAR2 ( 10 ) := 'A';
    --Primeiro dia do mês para a partição

    BEGIN
        lib_proc.add_tipo ( mproc_id
                          , p_tipo
                          ,    'REL_EXCLUSAO_ANALITICO_'
                            || mcod_empresa
                            || '_'
                            || p_cod_estab
                            || '_'
                            || TO_CHAR ( vp_data_ini
                                       , 'YYYYMM' )
                            || '.XLS'
                          , 2 );


        grava ( dsp_planilha.header
              , p_tipo );
        grava ( dsp_planilha.tabela_inicio
              , p_tipo );
        cabecalho_analitico ( p_cod_estab
                            , p_tipo );

        FOR p_rs_relatorio IN crs_relatorio ( p_cod_estab
                                            , vp_data_ini
                                            , vp_data_fim
                                            , p_lst_neutra ) LOOP
            IF v_class_linha = 'B' THEN
                v_class_linha := 'A';
            ELSE
                v_class_linha := 'B';
            END IF;

            lib_proc.add ( dsp_planilha.linha (
                                                   dsp_planilha.campo ( p_rs_relatorio.cod_empresa )
                                                || dsp_planilha.campo ( p_rs_relatorio.cod_estab )
                                                || dsp_planilha.campo ( p_rs_relatorio.uf_estab )
                                                || --
                                                  dsp_planilha.campo ( p_rs_relatorio.data_fiscal )
                                                || dsp_planilha.campo ( p_rs_relatorio.cod_docto )
                                                || dsp_planilha.campo (
                                                                        dsp_planilha.texto (
                                                                                             p_rs_relatorio.num_docfis
                                                                        )
                                                   )
                                                || dsp_planilha.campo ( p_rs_relatorio.serie_docfis )
                                                || dsp_planilha.campo (
                                                                        dsp_planilha.texto (
                                                                                             p_rs_relatorio.num_autentic_nfe
                                                                        )
                                                   )
                                                || dsp_planilha.campo (
                                                                        dsp_planilha.texto (
                                                                                             p_rs_relatorio.cod_produto
                                                                        )
                                                   )
                                                || dsp_planilha.campo ( p_rs_relatorio.descricao )
                                                || dsp_planilha.campo ( p_rs_relatorio.num_item )
                                                || dsp_planilha.campo ( p_rs_relatorio.cod_cfo )
                                                || dsp_planilha.campo ( dsp_planilha.texto ( p_rs_relatorio.cod_nbm ) )
                                                || dsp_planilha.campo ( p_rs_relatorio.lista )
                                                || dsp_planilha.campo ( p_rs_relatorio.quantidade )
                                                || dsp_planilha.campo ( p_rs_relatorio.vlr_item )
                                                || dsp_planilha.campo ( p_rs_relatorio.vlr_contab_item )
                                                || dsp_planilha.campo ( p_rs_relatorio.vlr_outras )
                                                || dsp_planilha.campo ( p_rs_relatorio.vlr_desconto )
                                                || dsp_planilha.campo ( p_rs_relatorio.vlr_base_icms )
                                                || dsp_planilha.campo ( p_rs_relatorio.aliq_icms )
                                                || dsp_planilha.campo ( p_rs_relatorio.vlr_icms )
                                                || dsp_planilha.campo (
                                                                        dsp_planilha.texto (
                                                                                             p_rs_relatorio.cod_situacao_pis
                                                                        )
                                                   )
                                                || dsp_planilha.campo ( p_rs_relatorio.vlr_base_pis )
                                                || dsp_planilha.campo ( p_rs_relatorio.vlr_aliq_pis )
                                                || dsp_planilha.campo ( p_rs_relatorio.vlr_pis )
                                                || dsp_planilha.campo (
                                                                        dsp_planilha.texto (
                                                                                             p_rs_relatorio.cod_situacao_cofins
                                                                        )
                                                   )
                                                || dsp_planilha.campo ( p_rs_relatorio.vlr_base_cofins )
                                                || dsp_planilha.campo ( p_rs_relatorio.vlr_aliq_cofins )
                                                || dsp_planilha.campo ( p_rs_relatorio.vlr_cofins )
                                                || dsp_planilha.campo ( p_rs_relatorio.cod_estab_e )
                                                || dsp_planilha.campo ( p_rs_relatorio.data_fiscal_e )
                                                || dsp_planilha.campo (
                                                                        dsp_planilha.texto (
                                                                                             p_rs_relatorio.num_docfis_e
                                                                        )
                                                   )
                                                || dsp_planilha.campo ( p_rs_relatorio.serie_docfis_e )
                                                || dsp_planilha.campo (
                                                                        dsp_planilha.texto (
                                                                                             p_rs_relatorio.num_controle_docto_e
                                                                        )
                                                   )
                                                || dsp_planilha.campo (
                                                                        dsp_planilha.texto (
                                                                                             p_rs_relatorio.num_autentic_nfe_e
                                                                        )
                                                   )
                                                || dsp_planilha.campo ( p_rs_relatorio.num_item_e )
                                                || dsp_planilha.campo ( p_rs_relatorio.cod_cfo_e )
                                                || dsp_planilha.campo ( p_rs_relatorio.cod_cfo_saida )
                                                || dsp_planilha.campo ( p_rs_relatorio.quantidade_e )
                                                || dsp_planilha.campo ( p_rs_relatorio.vlr_item_e )
                                                || dsp_planilha.campo ( p_rs_relatorio.vlr_contab_item_e )
                                                || dsp_planilha.campo ( p_rs_relatorio.vlr_outras_e )
                                                || dsp_planilha.campo ( p_rs_relatorio.vlr_desconto_e )
                                                || dsp_planilha.campo ( p_rs_relatorio.vlr_base_icms_e )
                                                || dsp_planilha.campo ( p_rs_relatorio.vlr_icms_e )
                                                || dsp_planilha.campo ( p_rs_relatorio.vlr_base_icmss_e )
                                                || dsp_planilha.campo ( p_rs_relatorio.vlr_icmss_e )
                                                || dsp_planilha.campo (
                                                                        dsp_planilha.texto (
                                                                                             p_rs_relatorio.cod_situacao_pis_e
                                                                        )
                                                   )
                                                || dsp_planilha.campo ( p_rs_relatorio.vlr_base_pis_e )
                                                || dsp_planilha.campo ( p_rs_relatorio.vlr_aliq_pis_e )
                                                || dsp_planilha.campo ( p_rs_relatorio.vlr_pis_e )
                                                || dsp_planilha.campo (
                                                                        dsp_planilha.texto (
                                                                                             p_rs_relatorio.cod_situacao_cofins_e
                                                                        )
                                                   )
                                                || dsp_planilha.campo ( p_rs_relatorio.vlr_base_cofins_e )
                                                || dsp_planilha.campo ( p_rs_relatorio.vlr_aliq_cofins_e )
                                                || dsp_planilha.campo ( p_rs_relatorio.vlr_cofins_e )
                                                || dsp_planilha.campo ( p_rs_relatorio.vlr_icmss_n_escrit )
                                                || dsp_planilha.campo ( p_rs_relatorio.vlr_icms_unit )
                                                || dsp_planilha.campo ( p_rs_relatorio.vlr_icms_st_unit )
                                                || dsp_planilha.campo ( p_rs_relatorio.vlr_icms_st_unit_aux )
                                                || dsp_planilha.campo ( p_rs_relatorio.vlr_icms_st_unit_xml )
                                                || dsp_planilha.campo ( p_rs_relatorio.vlr_icms_st_ret_unit_xml )
                                                || dsp_planilha.campo ( p_rs_relatorio.base_vlr_calculado )
                                                || dsp_planilha.campo ( p_rs_relatorio.vlr_calculado )
                                              , p_class => v_class_linha
                           )
                         , ptipo => v_tipo );
        END LOOP;

        grava ( dsp_planilha.tabela_fim
              , p_tipo );
    END;

    PROCEDURE grava_sintetico ( p_cod_estab VARCHAR2
                              , vp_data_ini DATE
                              , vp_data_fim DATE
                              , p_lst_neutra VARCHAR2
                              , p_agr_cfop VARCHAR2
                              , p_tipo VARCHAR2 DEFAULT '1' )
    IS
        v_class_linha CHAR ( 1 ) := 'A';
    BEGIN
        FOR c_si IN c_sintetico ( p_cod_estab
                                , vp_data_ini
                                , vp_data_fim
                                , p_lst_neutra
                                , p_agr_cfop ) LOOP
            IF v_class_linha = 'B' THEN
                v_class_linha := 'A';
            ELSE
                v_class_linha := 'B';
            END IF;

            grava ( dsp_planilha.linha (
                                            dsp_planilha.campo ( c_si.cod_estab )
                                         || --
                                           dsp_planilha.campo ( c_si.uf_estab )
                                         || --
                                           dsp_planilha.campo ( c_si.data_fiscal )
                                         || --
                                           dsp_planilha.campo ( c_si.cod_cfo )
                                         || --
                                           dsp_planilha.campo ( c_si.lista )
                                         || --
                                           dsp_planilha.campo ( c_si.icms_saida )
                                         || --
                                           dsp_planilha.campo ( c_si.icms_unit_ent )
                                         || --
                                           dsp_planilha.campo ( c_si.vlr_st_unit )
                                         || --
                                           dsp_planilha.campo ( c_si.vlr_st_unit_aux )
                                         || --
                                           dsp_planilha.campo ( c_si.vlr_st_unit_xml )
                                         || --
                                           dsp_planilha.campo ( c_si.vlr_st_unit_ret_xml )
                                         || --
                                           dsp_planilha.campo ( c_si.base_vlr_calculado )
                                         || --
                                           dsp_planilha.campo ( c_si.vlr_calculado )
                                       , --
                                         --
                                         p_class => v_class_linha
                    )
                  , p_tipo );
        END LOOP;
    END;

    FUNCTION executar ( p_data_ini DATE
                      , p_data_fim DATE
                      , p_rel VARCHAR2
                      , p_uf VARCHAR2
                      , p_lst_neutra VARCHAR2
                      , p_agr_cfop VARCHAR2
                      , p_lojas lib_proc.vartab )
        RETURN INTEGER
    IS
        vtipo INTEGER := 0;
        v_uf VARCHAR2 ( 6 );

        i1 INTEGER;

        TYPE a_estabs_t IS TABLE OF VARCHAR2 ( 6 );

        a_estabs a_estabs_t := a_estabs_t ( );
        a_estab_part a_estabs_t := a_estabs_t ( );

        ---
        p_tipo VARCHAR2 ( 8 );
        ---
        v_data_hora_ini VARCHAR2 ( 20 );

        v_count NUMBER;
        ------------------------------------------------------------------------------------------------------------------------------------------------------
        --RANGE DE DATAS PARA BUSCAR VENDAS
        v_data_inicial DATE := p_data_ini; -- DATA INICIAL
        v_data_final DATE := p_data_fim; -- DATA FINAL
        ------------------------------------------------------------------------------------------------------------------------------------------------------

        mproc_id_orig INTEGER := 0;

        mdesc VARCHAR2 ( 100 );
    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS='',.'' ';

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING = FORCE';

        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        musuario := lib_parametros.recuperar ( 'USUARIO' );
        mproc_id_orig := lib_parametros.recuperar ( 'PROCORIG' );
        mdesc := lib_parametros.recuperar ( 'PDESC' );

        mproc_id_o := lib_proc.new ( $$plsql_unit );
        lib_parametros.salvar ( 'MPROC_ID'
                              , mproc_id_o );
        mproc_id := lib_parametros.recuperar ( 'MPROC_ID' );

        dbms_application_info.set_module ( $$plsql_unit
                                         , 'PROC_ID_ORIG: ' || mproc_id_o );

        --MARCAR INCIO DA EXECUCAO
        v_data_hora_ini :=
            TO_CHAR ( SYSDATE
                    , 'DD/MM/YYYY HH24:MI.SS' );

        loga ( '<<' || mnm_cproc || '>>'
             , FALSE );
        loga ( '---INICIO DO PROCESSAMENTO TOTAL---'
             , FALSE );

        dbms_application_info.set_module ( $$plsql_unit
                                         , 'PROC_ID: ' || mproc_id );

        loga ( 'Data execução: ' || v_data_hora_ini
             , FALSE );

        loga ( 'Usuário: ' || musuario
             , FALSE );
        loga ( 'Empresa: ' || mcod_empresa
             , FALSE );
        loga ( 'Período: ' || v_data_inicial || ' a ' || v_data_final
             , FALSE );
        loga ( 'Relatório: ' || p_rel
             , FALSE );
        loga ( 'UF: ' || p_uf
             , FALSE );

        loga ( '----------------------------------------'
             , FALSE );

        v_count := p_lojas.COUNT;
        loga ( 'Qtd de Lojas: ' || v_count
             , FALSE );

        loga ( '----------------------------------------'
             , FALSE );

        IF msafi.get_trava_info ( 'EXCLUSAO'
                                , TO_CHAR ( v_data_inicial
                                          , 'YYYY/MM' ) ) = 'S'
       AND p_rel = '1' THEN
            loga ( '<< PERIODO BLOQUEADO PARA REPROCESSAMENTO >>'
                 , FALSE );
            raise_application_error ( -20001
                                    ,    'PERIODO '
                                      || TO_CHAR ( v_data_inicial
                                                 , 'YYYY/MM' )
                                      || ' BLOQUEADO PARA REPROCESSAMENTO' );

            lib_proc.close;
            COMMIT;
            RETURN mproc_id;
        END IF;

        ----PREPARAR LOJAS SP----
        IF ( p_lojas.COUNT > 0 ) THEN
            i1 := p_lojas.FIRST;

            IF SUBSTR ( p_lojas ( i1 )
                      , 1
                      , 2 ) = 'UF' THEN
                --V_LOJAS_UF
                v_uf :=
                    SUBSTR ( p_lojas ( i1 )
                           , 2 );

                FOR c IN ( SELECT *
                             FROM dsp_estabelecimento_v
                            WHERE cod_estado = v_uf ) LOOP
                    a_estabs.EXTEND ( );
                    a_estabs ( a_estabs.LAST ) := c.cod_estab;
                END LOOP;
            ELSE
                SELECT cod_estado
                  INTO v_uf
                  FROM msafi.dsp_estabelecimento e
                 WHERE e.cod_empresa = mcod_empresa
                   AND e.cod_estab = p_lojas ( i1 );

                WHILE i1 IS NOT NULL LOOP
                    a_estabs.EXTEND ( );
                    a_estabs ( a_estabs.LAST ) := p_lojas ( i1 );
                    i1 := p_lojas.NEXT ( i1 );
                END LOOP;
            END IF;
        END IF;

        ---------------

        IF p_rel <> '3' THEN
            --(1)

            i1 := 0;

            FOR est IN a_estabs.FIRST .. a_estabs.COUNT LOOP
                i1 := i1 + 1;
                a_estab_part.EXTEND ( );
                a_estab_part ( i1 ) := a_estabs ( est );

                IF MOD ( a_estab_part.COUNT
                       , v_quant_empresas ) = 0
                OR est = a_estabs.COUNT THEN
                    i1 := 0;

                    --=======================================================
                    --ANALITICO
                    --=======================================================
                    IF p_rel = '2' THEN
                        loga ( '[INICIAR GRAVA_ANALITICO]'
                             , TRUE );

                        FOR est IN 1 .. a_estab_part.COUNT LOOP
                            dbms_application_info.set_module ( $$plsql_unit
                                                             , mproc_id || ' ANALITICO LJ ' || a_estab_part ( est ) );

                            loga ( '>> ESTAB: ' || a_estab_part ( est )
                                 , FALSE );

                            vtipo := vtipo + 1;

                            grava_analitico ( a_estab_part ( est )
                                            , v_data_inicial
                                            , v_data_final
                                            , p_lst_neutra
                                            , vtipo );
                        END LOOP;

                        loga ( '[FIM GRAVA_ANALITICO]'
                             , TRUE );

                        loga ( 'Qtd concluida: ' || est || ' / ' || v_count
                             , FALSE );
                    END IF;

                    a_estab_part := a_estabs_t ( );
                END IF;
            END LOOP; --EST IN A_ESTABS.FIRST .. A_ESTABS.COUNT

            --DISPONIBILIZAR PERIODO PROCESSADO PARA TRAVA DE REPROCESSAMENTO
            msafi.add_trava_info ( 'EXCLUSAO'
                                 , TO_CHAR ( v_data_inicial
                                           , 'YYYY/MM' ) );

            -----
            IF TRIM ( mdesc ) IS NOT NULL THEN
                UPDATE lib_proc_log o
                   SET o.proc_id = mproc_id_orig
                 WHERE o.proc_id = mproc_id_o;

                COMMIT;
            END IF;
        -----

        ELSE
            --(1)

            --=======================================================
            --SINTETICO
            --=======================================================

            p_tipo := 9999;
            mproc_id := lib_proc.new ( $$plsql_unit );
            lib_proc.add_tipo ( mproc_id
                              , p_tipo
                              ,    'REL_EXCLUSAO_'
                                || mcod_empresa
                                || '_SINTETICO_'
                                || TO_CHAR ( v_data_inicial
                                           , 'YYYYMM' )
                                || '.XLS'
                              , 2 );

            grava ( dsp_planilha.header
                  , p_tipo );
            grava ( dsp_planilha.tabela_inicio
                  , p_tipo );
            cabecalho_sintetico ( p_tipo );

            loga ( '[INICIAR GRAVA_SINTETICO]'
                 , TRUE );

            FOR est IN 1 .. a_estabs.COUNT LOOP
                dbms_application_info.set_module ( $$plsql_unit
                                                 , mproc_id || ' SINTETICO LJ ' || a_estabs ( est ) );

                loga ( '>> ESTAB: ' || a_estabs ( est )
                     , FALSE );

                grava_sintetico ( a_estabs ( est )
                                , v_data_inicial
                                , v_data_final
                                , p_lst_neutra
                                , p_agr_cfop
                                , p_tipo );
            END LOOP;

            loga ( '[FIM GRAVA_SINTETICO]'
                 , TRUE );

            grava ( dsp_planilha.tabela_fim
                  , p_tipo );
        END IF; --(1)

        loga ( '---FIM DO PROCESSAMENTO TOTAL---'
             , FALSE );
        COMMIT;

        dbms_application_info.set_module ( $$plsql_unit
                                         , ' FIM' );

        --ENVIAR EMAIL DE SUCESSO----------------------------------------
        /*  ENVIA_EMAIL(MCOD_EMPRESA,
        V_DATA_INICIAL,
        V_DATA_FINAL,
        '',
        'S',
        V_DATA_HORA_INI);*/
        -----------------------------------------------------------------

        lib_proc.close ( );

        IF p_rel IN ( '1'
                    , '3' ) THEN
            lib_proc.delete ( mproc_id_o );
        END IF;

        RETURN mproc_id_o;
    EXCEPTION
        WHEN OTHERS THEN
            loga ( 'ERRO - Limpar Tabelas Temporárias'
                 , FALSE );
            --DELETE_TEMP_TBL(P_PROC_INSTANCE, V_NOME_TABELA_ALIQ, V_TAB_ENTRADA_C, V_TAB_ENTRADA_F, V_TAB_ENTRADA_CO, V_TABELA_SAIDA, V_TABELA_NF, V_TABELA_ULT_ENTRADA);
            loga ( 'ERRO - TABELAS TEMPORÁRIAS LIMPAS'
                 , FALSE );

            loga ( 'SQLERRM: ' || SQLERRM
                 , FALSE );

            lib_proc.add_log ( 'ERRO NÃO TRATADO: ' || dbms_utility.format_error_backtrace
                             , 1 );
            lib_proc.add_log ( 'SQLERRM: ' || SQLERRM
                             , 1 );

            --ENVIAR EMAIL DE ERRO-------------------------------------------
            /*  ENVIA_EMAIL(MCOD_EMPRESA,
            V_DATA_INICIAL,
            V_DATA_FINAL,
            SQLERRM,
            'E',
            V_DATA_HORA_INI);*/
            -----------------------------------------------------------------
            lib_proc.close ( );
            msafi.dpsp_lib_proc_error ( mproc_id
                                      , $$plsql_unit );

            COMMIT;
            RETURN mproc_id;
    END; /* FUNCTION EXECUTAR */
END dpsp_rel_ex_pis_cofins_cproc;
/
SHOW ERRORS;
