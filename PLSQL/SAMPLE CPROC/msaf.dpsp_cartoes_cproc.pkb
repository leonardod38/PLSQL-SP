Prompt Package Body DPSP_CARTOES_CPROC;
--
-- DPSP_CARTOES_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_cartoes_cproc
IS
    mcod_empresa empresa.cod_empresa%TYPE;
    mproc_id INTEGER;
    mproc_id_o INTEGER;
    mnm_usuario usuario_estab.cod_usuario%TYPE;

    v_tablespace_table VARCHAR2 ( 30 ) := 'MSAF_BIG_TABLES';
    v_tablespace_index VARCHAR2 ( 30 ) := 'MSAF_BIG_TABLES';

    mnm_tipo VARCHAR2 ( 100 ) := 'Ressarcimento';
    mnm_cproc VARCHAR2 ( 100 ) := 'Processar Dados Crédito dos Cartões';
    mds_cproc VARCHAR2 ( 100 ) := 'Processar Carga de Dados para informação de crédito dos Cartões de Crédito';

    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );
    BEGIN
        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        mnm_usuario := lib_parametros.recuperar ( 'USUARIO' );

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
                           , 'Origem Entrada CD1'
                           , --P_ORIGEM1
                            'VARCHAR2'
                           , 'RADIOBUTTON'
                           , 'S'
                           , NULL
                           , NULL
                           , '1=Filial (Transferência),2=CD (Compra)' );

        lib_proc.add_param (
                             pstr
                           , 'Checar Entradas CD1'
                           , --P_CD1
                            'VARCHAR2'
                           , 'COMBOBOX'
                           , 'S'
                           , NULL
                           , NULL
                           ,    ' SELECT A.COD_ESTAB, A.COD_ESTAB || '' - '' || B.COD_ESTADO || '' - '' || A.CGC || '' - '' || INITCAP(A.BAIRRO) || '' / '' || INITCAP(A.CIDADE)
                            FROM ESTABELECIMENTO A, ESTADO B, MSAFI.DSP_ESTABELECIMENTO C
                            WHERE A.COD_EMPRESA  = '''
                             || mcod_empresa
                             || '''
                              AND B.IDENT_ESTADO = A.IDENT_ESTADO
                              AND A.COD_EMPRESA  = C.COD_EMPRESA
                              AND A.COD_ESTAB    = C.COD_ESTAB
                              AND C.TIPO         = ''C''
                            ORDER BY A.COD_ESTAB DESC
                           '
        );

        lib_proc.add_param ( pstr
                           , 'Origem Entrada CD2'
                           , --P_ORIGEM2
                            'VARCHAR2'
                           , 'RADIOBUTTON'
                           , 'N'
                           , NULL
                           , NULL
                           , '1=Filial (Transferência),2=CD (Compra)' );

        lib_proc.add_param (
                             pstr
                           , 'Checar Entradas CD2'
                           , --P_CD2
                            'VARCHAR2'
                           , 'COMBOBOX'
                           , 'N'
                           , NULL
                           , NULL
                           ,    ' SELECT A.COD_ESTAB, A.COD_ESTAB || '' - '' || B.COD_ESTADO || '' - '' || A.CGC || '' - '' || INITCAP(A.BAIRRO) || '' / '' || INITCAP(A.CIDADE)
                            FROM ESTABELECIMENTO A, ESTADO B, MSAFI.DSP_ESTABELECIMENTO C
                            WHERE A.COD_EMPRESA  = '''
                             || mcod_empresa
                             || '''
                              AND B.IDENT_ESTADO = A.IDENT_ESTADO
                              AND A.COD_EMPRESA  = C.COD_EMPRESA
                              AND A.COD_ESTAB    = C.COD_ESTAB
                              AND C.TIPO         = ''C''
                            ORDER BY A.COD_ESTAB DESC
                           '
        );

        lib_proc.add_param ( pstr
                           , 'Origem Entrada CD3'
                           , --P_ORIGEM3
                            'VARCHAR2'
                           , 'RADIOBUTTON'
                           , 'N'
                           , NULL
                           , NULL
                           , '1=Filial (Transferência),2=CD (Compra)' );

        lib_proc.add_param (
                             pstr
                           , 'Checar Entradas CD3'
                           , --P_CD3
                            'VARCHAR2'
                           , 'COMBOBOX'
                           , 'N'
                           , NULL
                           , NULL
                           ,    ' SELECT A.COD_ESTAB, A.COD_ESTAB || '' - '' || B.COD_ESTADO || '' - '' || A.CGC || '' - '' || INITCAP(A.BAIRRO) || '' / '' || INITCAP(A.CIDADE)
                            FROM ESTABELECIMENTO A, ESTADO B, MSAFI.DSP_ESTABELECIMENTO C
                            WHERE A.COD_EMPRESA  = '''
                             || mcod_empresa
                             || '''
                              AND B.IDENT_ESTADO = A.IDENT_ESTADO
                              AND A.COD_EMPRESA  = C.COD_EMPRESA
                              AND A.COD_ESTAB    = C.COD_ESTAB
                              AND C.TIPO         = ''C''
                            ORDER BY A.COD_ESTAB DESC
                           '
        );

        lib_proc.add_param ( pstr
                           , 'Origem Entrada CD4'
                           , --P_ORIGEM4
                            'VARCHAR2'
                           , 'RADIOBUTTON'
                           , 'N'
                           , NULL
                           , NULL
                           , '1=Filial (Transferência),2=CD (Compra)' );

        lib_proc.add_param ( pstr
                           , 'Checar Entradas CD4'
                           , --P_CD4
                            'VARCHAR2'
                           , 'TEXTBOX'
                           , 'N'
                           , NULL
                           , '######' );

        lib_proc.add_param (
                             pparam => pstr
                           , --P_UF
                            ptitulo => 'UF'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'COMBOBOX'
                           , pmandatorio => 'S'
                           , pdefault => 'SP'
                           , pmascara => '####################'
                           , pvalores =>    'SELECT COD_ESTADO, COD_ESTADO || '' - '' || DESCRICAO TXT FROM ESTADO '
                                         || ' WHERE COD_ESTADO IN (SELECT COD_ESTADO FROM DSP_ESTABELECIMENTO_V) '
                                         || ' AND COD_ESTADO = ''SP'' ORDER BY 1'
        );

        lib_proc.add_param (
                             pstr
                           , 'Filiais'
                           , --P_LOJAS  -- Somente SP
                            'VARCHAR2'
                           , 'MULTISELECT'
                           , 'S'
                           , NULL
                           , NULL
                           ,    ' SELECT A.COD_ESTAB, A.COD_ESTAB || '' - '' || B.COD_ESTADO || '' - '' || A.CGC || '' - '' || INITCAP(A.BAIRRO) || '' / '' || INITCAP(A.CIDADE)
                            FROM ESTABELECIMENTO A, ESTADO B, MSAFI.DSP_ESTABELECIMENTO C
                            WHERE A.COD_EMPRESA  = '''
                             || mcod_empresa
                             || '''
                              AND B.IDENT_ESTADO = A.IDENT_ESTADO
                              AND A.COD_EMPRESA  = C.COD_EMPRESA
                              AND A.COD_ESTAB    = C.COD_ESTAB
                              AND C.TIPO         = ''L''
                              AND C.COD_ESTADO   = ''SP''
                            ORDER BY B.COD_ESTADO, A.COD_ESTAB
                           '
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

        v_erro VARCHAR2 ( 1024 );
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
        --MSAFI.DSP_CONTROL.WRITELOG('CARTOES', P_I_TEXTO);
        COMMIT;
    ---> Para acompanhar processamento usar SELECT abaixo
    --SELECT * FROM DSP_LOG
    --WHERE LOG_TYPE = 'CARTOES'
    --ORDER BY 3 DESC, 2 DESC
    ---

    EXCEPTION
        WHEN OTHERS THEN
            v_erro := SQLERRM;
    END;

    FUNCTION moeda ( v_conteudo NUMBER )
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN TRIM ( TO_CHAR ( v_conteudo
                              , '9g999g999g990d00' ) );
    END;

    PROCEDURE save_tmp_control ( vp_proc_instance IN NUMBER
                               , vp_table_name IN VARCHAR2 )
    IS
        v_sid NUMBER;
    BEGIN
        ---> Rotina para armazenar tabelas TEMP criadas, caso programa seja
        ---  interrompido, elas serao excluidas em outros processamentos
        SELECT USERENV ( 'SID' )
          INTO v_sid
          FROM DUAL;

        ---
        INSERT /*+APPEND*/
              INTO  msafi.dpsp_msaf_tmp_control
             VALUES ( vp_proc_instance
                    , vp_table_name
                    , SYSDATE
                    , mnm_usuario
                    , v_sid );

        COMMIT;
    END;

    PROCEDURE del_tmp_control ( vp_proc_instance IN NUMBER
                              , vp_table_name IN VARCHAR2 )
    IS
    BEGIN
        DELETE msafi.dpsp_msaf_tmp_control
         WHERE proc_id = vp_proc_instance
           AND table_name = vp_table_name;

        COMMIT;
    END;

    PROCEDURE delete_temp_tbl_gen ( p_i_proc_instance IN VARCHAR2
                                  , vp_nome_tabela IN VARCHAR2 )
    IS
    BEGIN
        BEGIN
            EXECUTE IMMEDIATE 'DROP TABLE ' || vp_nome_tabela;
        EXCEPTION
            WHEN OTHERS THEN
                loga ( '[ERRO] DROP TABLE ' || vp_nome_tabela
                     , FALSE );
        END;

        --- remover nome da TMP do controle
        del_tmp_control ( p_i_proc_instance
                        , vp_nome_tabela );
    END;

    PROCEDURE drop_old_tmp ( vp_proc_instance IN NUMBER )
    IS
        CURSOR c_old_tmp
        IS
            SELECT table_name
              FROM msafi.dpsp_msaf_tmp_control
             WHERE TRUNC ( ( ( ( 86400 * ( SYSDATE - dttm_created ) ) / 60 ) / 60 ) / 24 ) >= 2;

        l_table_name VARCHAR2 ( 30 );
    BEGIN
        ---> Dropar tabelas TMP que tiveram processo interrompido a mais de 2 dias
        OPEN c_old_tmp;

        LOOP
            FETCH c_old_tmp
                INTO l_table_name;

            BEGIN
                EXECUTE IMMEDIATE 'DROP TABLE ' || l_table_name;
            EXCEPTION
                WHEN OTHERS THEN
                    loga ( '<<TAB OLD NAO ENCONTRADA>> ' || l_table_name
                         , FALSE );
            END;

            ---
            DELETE msafi.dpsp_msaf_tmp_control
             WHERE table_name = l_table_name;

            COMMIT;

            EXIT WHEN c_old_tmp%NOTFOUND;
        END LOOP;

        COMMIT;

        CLOSE c_old_tmp;
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

            v_txt_email := 'ERRO no Processo Credito dos Cartoes!';
            v_txt_email := v_txt_email || CHR ( 13 ) || '>> Parâmetros: ';
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Empresa : ' || vp_cod_empresa;
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Data Início : ' || vp_data_ini;
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Data Fim : ' || vp_data_fim;
            v_txt_email := v_txt_email || CHR ( 13 ) || '>> LOG: ';
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Executado por : ' || mnm_usuario;
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Hora Início : ' || vp_data_hora_ini;
            v_txt_email :=
                   v_txt_email
                || CHR ( 13 )
                || ' - Hora Término : '
                || TO_CHAR ( SYSDATE
                           , 'DD/MM/YYYY HH24:MI.SS' );
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Tempo Execução	: ' || v_tempo_exec;
            v_txt_email := v_txt_email || CHR ( 13 ) || '<< ERRO >> ' || vp_msg_oracle;
            v_assunto := 'Mastersaf - Credito dos Cartoes apresentou ERRO';
            notifica ( ''
                     , 'S'
                     , v_assunto
                     , v_txt_email
                     , 'DPSP_CARTOES_CPROC' );
        ELSE
            v_txt_email := 'Processo Credito dos Cartoes finalizado com SUCESSO.';
            v_txt_email := v_txt_email || CHR ( 13 ) || '>> Parâmetros: ';
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Empresa : ' || vp_cod_empresa;
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Data Início : ' || vp_data_ini;
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Data Fim : ' || vp_data_fim;
            v_txt_email := v_txt_email || CHR ( 13 ) || '>> LOG: ';
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Executado por : ' || mnm_usuario;
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Hora Início : ' || vp_data_hora_ini;
            v_txt_email :=
                   v_txt_email
                || CHR ( 13 )
                || ' - Hora Término : '
                || TO_CHAR ( SYSDATE
                           , 'DD/MM/YYYY HH24:MI.SS' );
            v_txt_email := v_txt_email || CHR ( 13 ) || ' - Tempo Execução : ' || v_tempo_exec;
            v_assunto := 'Mastersaf - Credito dos Cartoes Concluído';
            notifica ( 'S'
                     , ''
                     , v_assunto
                     , v_txt_email
                     , 'DPSP_CARTOES_CPROC' );
        END IF;
    END;

    PROCEDURE create_tab_cartoes ( vp_proc_instance IN VARCHAR2
                                 , vp_tabela_cartoes   OUT VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 3000 );
    BEGIN
        vp_tabela_cartoes := 'DPSP_MSAF_P_' || vp_proc_instance;

        v_sql := 'CREATE TABLE ' || vp_tabela_cartoes || ' ( ';
        v_sql := v_sql || 'PROC_ID             NUMBER(30), ';
        v_sql := v_sql || 'COD_EMPRESA         VARCHAR2(3), ';
        v_sql := v_sql || 'COD_ESTAB           VARCHAR2(6), ';
        v_sql := v_sql || 'UF_ESTAB            VARCHAR2(2), ';
        v_sql := v_sql || 'DOCTO               VARCHAR2(5), ';
        v_sql := v_sql || 'COD_PRODUTO         VARCHAR2(35), ';
        v_sql := v_sql || 'NUM_ITEM            NUMBER(5), ';
        v_sql := v_sql || 'DESCR_ITEM          VARCHAR2(50), ';
        v_sql := v_sql || 'NUM_DOCFIS          VARCHAR2(12), ';
        v_sql := v_sql || 'DATA_FISCAL         DATE, ';
        v_sql := v_sql || 'SERIE_DOCFIS        VARCHAR2(3), ';
        v_sql := v_sql || 'QUANTIDADE          NUMBER(12,4), ';
        v_sql := v_sql || 'COD_NBM             VARCHAR2(10), ';
        v_sql := v_sql || 'COD_CFO             VARCHAR2(4), ';
        v_sql := v_sql || 'GRUPO_PRODUTO       VARCHAR2(30), ';
        v_sql := v_sql || 'VLR_DESCONTO        NUMBER(17,2), ';
        v_sql := v_sql || 'VLR_CONTABIL        NUMBER(17,2), ';
        v_sql := v_sql || 'NUM_AUTENTIC_NFE    VARCHAR2(80), ';
        v_sql := v_sql || 'VLR_BASE_ICMS       NUMBER(17,2), ';
        v_sql := v_sql || 'VLR_ALIQ_ICMS       NUMBER(5,2), ';
        v_sql := v_sql || 'VLR_ICMS            NUMBER(17,2), ';
        v_sql := v_sql || 'DESCR_TOT           VARCHAR2(6), ';
        v_sql := v_sql || 'AUTORIZADORA        VARCHAR2(30), ';
        v_sql := v_sql || 'NOME_VAN            VARCHAR2(20), ';
        v_sql := v_sql || 'VLR_PAGO_CARTAO     NUMBER(17,2), ';
        v_sql := v_sql || 'FORMA_PAGTO         VARCHAR2(7), ';
        v_sql := v_sql || 'NUM_PARCELAS        NUMBER(2), ';
        v_sql := v_sql || 'CODIGO_APROVACAO    VARCHAR2(30), ';
        ---
        v_sql := v_sql || 'COD_ESTAB_E           VARCHAR2(6), ';
        v_sql := v_sql || 'DATA_FISCAL_E         DATE, ';
        v_sql := v_sql || 'MOVTO_E_S_E           VARCHAR2(1), ';
        v_sql := v_sql || 'NORM_DEV_E            VARCHAR2(1), ';
        v_sql := v_sql || 'IDENT_DOCTO_E         VARCHAR2(12), ';
        v_sql := v_sql || 'IDENT_FIS_JUR_E       VARCHAR2(12), ';
        v_sql := v_sql || 'SUB_SERIE_DOCFIS_E    VARCHAR2(2), ';
        v_sql := v_sql || 'DISCRI_ITEM_E         VARCHAR2(46), ';
        v_sql := v_sql || 'DATA_EMISSAO_E        DATE, ';
        v_sql := v_sql || 'NUM_DOCFIS_E          VARCHAR2(12), ';
        v_sql := v_sql || 'SERIE_DOCFIS_E        VARCHAR2(3), ';
        v_sql := v_sql || 'NUM_ITEM_E            NUMBER(5), ';
        v_sql := v_sql || 'COD_FIS_JUR_E         VARCHAR2(14), ';
        v_sql := v_sql || 'CPF_CGC_E             VARCHAR2(14), ';
        v_sql := v_sql || 'COD_NBM_E             VARCHAR2(10), ';
        v_sql := v_sql || 'COD_CFO_E             VARCHAR2(4), ';
        v_sql := v_sql || 'COD_NATUREZA_OP_E     VARCHAR2(3), ';
        v_sql := v_sql || 'COD_PRODUTO_E         VARCHAR2(35), ';
        v_sql := v_sql || 'VLR_CONTAB_ITEM_E     NUMBER(17,2), ';
        v_sql := v_sql || 'QUANTIDADE_E          NUMBER(12,4), ';
        v_sql := v_sql || 'VLR_UNIT_E            NUMBER(17,2), ';
        v_sql := v_sql || 'COD_SITUACAO_B_E      VARCHAR2(2), ';
        v_sql := v_sql || 'COD_ESTADO_E          VARCHAR2(2), ';
        v_sql := v_sql || 'NUM_CONTROLE_DOCTO_E  VARCHAR2(12), ';
        v_sql := v_sql || 'NUM_AUTENTIC_NFE_E    VARCHAR2(80), ';
        ---
        v_sql := v_sql || 'BASE_ICMS_UNIT_E      NUMBER(17,4), ';
        v_sql := v_sql || 'VLR_ICMS_UNIT_E       NUMBER(17,4), ';
        v_sql := v_sql || 'ALIQ_ICMS_E           NUMBER(7,2), ';
        v_sql := v_sql || 'BASE_ST_UNIT_E        NUMBER(17,4), ';
        v_sql := v_sql || 'VLR_ICMS_ST_UNIT_E    NUMBER(17,4), ';
        v_sql := v_sql || 'VLR_ICMS_ST_UNIT_AUX  NUMBER(17,4), ';
        v_sql := v_sql || 'STAT_LIBER_CNTR       VARCHAR2(10)) ';
        v_sql := v_sql || 'PCTFREE     10 ';
        v_sql := v_sql || ' TABLESPACE ' || v_tablespace_table;

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE  INDEX PK_DPSP_P_' || vp_proc_instance || ' ON ' || vp_tabela_cartoes || ' ';
        v_sql := v_sql || '  (';
        v_sql := v_sql || '  PROC_ID      ASC, ';
        v_sql := v_sql || '  COD_EMPRESA  ASC, ';
        v_sql := v_sql || '  COD_ESTAB    ASC, ';
        v_sql := v_sql || '  UF_ESTAB     ASC, ';
        v_sql := v_sql || '  DOCTO        ASC, ';
        v_sql := v_sql || '  COD_PRODUTO  ASC, ';
        v_sql := v_sql || '  NUM_ITEM     ASC, ';
        v_sql := v_sql || '  NUM_DOCFIS   ASC, ';
        v_sql := v_sql || '  DATA_FISCAL  ASC, ';
        v_sql := v_sql || '  SERIE_DOCFIS ASC, ';
        v_sql := v_sql || '  CODIGO_APROVACAO ASC ';
        v_sql := v_sql || '  )';
        v_sql := v_sql || '  PCTFREE     10 ';
        v_sql := v_sql || ' TABLESPACE ' || v_tablespace_index;

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX1_DPSP_P_' || vp_proc_instance || ' ON ' || vp_tabela_cartoes || ' ';
        v_sql := v_sql || '  ( ';
        v_sql := v_sql || '    PROC_ID        ASC ';
        v_sql := v_sql || '  ) ';
        v_sql := v_sql || '  PCTFREE     10 ';
        v_sql := v_sql || ' TABLESPACE ' || v_tablespace_index;

        EXECUTE IMMEDIATE v_sql;

        ---
        save_tmp_control ( vp_proc_instance
                         , vp_tabela_cartoes );
    END;

    PROCEDURE create_tab_saida ( vp_proc_instance IN VARCHAR2
                               , vp_tabela_saida   OUT VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 4000 );
    BEGIN
        vp_tabela_saida := 'DPSP_MSAF_S_' || vp_proc_instance;

        v_sql := 'CREATE TABLE ' || vp_tabela_saida || ' ( ';
        v_sql := v_sql || 'PROC_ID             NUMBER(30), ';
        v_sql := v_sql || 'COD_EMPRESA         VARCHAR2(3), ';
        v_sql := v_sql || 'COD_ESTAB           VARCHAR2(6), ';
        v_sql := v_sql || 'UF_ESTAB            VARCHAR2(2), ';
        v_sql := v_sql || 'DOCTO               VARCHAR2(5), ';
        v_sql := v_sql || 'COD_PRODUTO         VARCHAR2(35), ';
        v_sql := v_sql || 'NUM_ITEM            NUMBER(5), ';
        v_sql := v_sql || 'DESCR_ITEM          VARCHAR2(50), ';
        v_sql := v_sql || 'NUM_DOCFIS          VARCHAR2(12), ';
        v_sql := v_sql || 'DATA_FISCAL         DATE, ';
        v_sql := v_sql || 'SERIE_DOCFIS        VARCHAR2(3), ';
        v_sql := v_sql || 'QUANTIDADE          NUMBER(12,4), ';
        v_sql := v_sql || 'COD_NBM             VARCHAR2(10), ';
        v_sql := v_sql || 'COD_CFO             VARCHAR2(4), ';
        v_sql := v_sql || 'GRUPO_PRODUTO       VARCHAR2(30), ';
        v_sql := v_sql || 'VLR_DESCONTO        NUMBER(17,2), ';
        v_sql := v_sql || 'VLR_CONTABIL        NUMBER(17,2), ';
        v_sql := v_sql || 'NUM_AUTENTIC_NFE    VARCHAR2(80), ';
        v_sql := v_sql || 'VLR_BASE_ICMS       NUMBER(17,2), ';
        v_sql := v_sql || 'VLR_ALIQ_ICMS       NUMBER(5,2), ';
        v_sql := v_sql || 'VLR_ICMS            NUMBER(17,2), ';
        v_sql := v_sql || 'DESCR_TOT           VARCHAR2(6), ';
        v_sql := v_sql || 'AUTORIZADORA        VARCHAR2(30), ';
        v_sql := v_sql || 'NOME_VAN            VARCHAR2(20), ';
        v_sql := v_sql || 'VLR_PAGO_CARTAO     NUMBER(17,2), ';
        v_sql := v_sql || 'FORMA_PAGTO         VARCHAR2(7), ';
        v_sql := v_sql || 'NUM_PARCELAS        NUMBER(2), ';
        v_sql := v_sql || 'CODIGO_APROVACAO    VARCHAR(30)) ';

        v_sql := v_sql || 'PCTFREE     10 ';
        v_sql := v_sql || ' TABLESPACE ' || v_tablespace_table;

        EXECUTE IMMEDIATE v_sql;
    END;

    PROCEDURE create_tab_prod_saida ( vp_proc_instance IN VARCHAR2
                                    , vp_tabela_prod_saida   OUT VARCHAR2
                                    , vp_pnr_particao IN VARCHAR2 DEFAULT NULL )
    IS
        v_sql VARCHAR2 ( 10000 );
        v_existe_tabela INTEGER;
    BEGIN
        vp_tabela_prod_saida := 'DPSP_P_S_' || vp_pnr_particao || vp_proc_instance;

        SELECT NVL ( MAX ( 1 ), 0 )
          INTO v_existe_tabela
          FROM all_tables
         WHERE table_name = UPPER ( vp_tabela_prod_saida );

        IF v_existe_tabela = 0 THEN
            v_sql := 'CREATE TABLE ' || vp_tabela_prod_saida || ' ( ';
            v_sql := v_sql || 'PROC_ID             NUMBER(30), ';
            v_sql := v_sql || 'COD_EMPRESA         VARCHAR2(3), ';
            v_sql := v_sql || 'COD_ESTAB           VARCHAR2(6), ';
            v_sql := v_sql || 'DATA_FISCAL         DATE, ';
            -- v_sql := v_sql || 'IDENT_PRODUTO       INTEGER, ';
            v_sql := v_sql || 'COD_PRODUTO         VARCHAR2(35) ) ';
            v_sql := v_sql || 'PCTFREE     10 ';
            v_sql := v_sql || ' TABLESPACE ' || v_tablespace_table;

            EXECUTE IMMEDIATE v_sql;
        END IF;
    END;

    PROCEDURE create_tab_prod_saida_idx ( vp_proc_instance IN VARCHAR2
                                        , vp_tabela_prod_saida IN VARCHAR2
                                        , vp_pnr_particao IN VARCHAR2 DEFAULT NULL )
    IS
        v_sql VARCHAR2 ( 1000 );
        v_existe_index INTEGER;
    BEGIN
        SELECT NVL ( MAX ( 1 ), 0 )
          INTO v_existe_index
          FROM all_indexes
         WHERE index_name = UPPER ( 'PK_DPSP_P_S_' || vp_pnr_particao || vp_proc_instance );

        IF v_existe_index = 0 THEN
            v_sql :=
                   'CREATE INDEX PK_DPSP_P_S_'
                || vp_pnr_particao
                || vp_proc_instance
                || ' ON '
                || vp_tabela_prod_saida
                || ' ';
            v_sql := v_sql || '( ';
            v_sql := v_sql || '  COD_PRODUTO  ASC ';
            v_sql := v_sql || ') ';
            v_sql := v_sql || 'PCTFREE     10 ';
            v_sql := v_sql || ' TABLESPACE ' || v_tablespace_index;


            BEGIN
                EXECUTE IMMEDIATE v_sql;
            EXCEPTION
                WHEN OTHERS THEN
                    raise_application_error ( -20005
                                            , '!ERRO CRIACAO UNIQUE IDX SAIDA!' );
            END;
        END IF;
    -- dbms_stats.gather_table_stats('MSAF', vp_tabela_saida);
    -- loga(' - ' || vp_tabela_saida || ' CRIADA', FALSE);

    END;

    PROCEDURE create_tab_entrada_cd ( vp_proc_instance IN NUMBER
                                    , vp_tab_entrada_c   OUT VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 2000 );
    BEGIN
        ---CRIAR TEMP DE ENTRADA EM CD
        vp_tab_entrada_c := 'DPSP_MSAF_E_C_' || vp_proc_instance;

        v_sql := 'CREATE TABLE ' || vp_tab_entrada_c || ' ( ';
        v_sql := v_sql || ' PROC_ID             NUMBER(30), ';
        v_sql := v_sql || ' COD_EMPRESA         VARCHAR2(3), ';
        v_sql := v_sql || ' COD_ESTAB           VARCHAR2(6), ';
        v_sql := v_sql || ' DATA_FISCAL         DATE, ';
        v_sql := v_sql || ' MOVTO_E_S           VARCHAR2(1), ';
        v_sql := v_sql || ' NORM_DEV            VARCHAR2(1), ';
        v_sql := v_sql || ' IDENT_DOCTO         VARCHAR2(12), ';
        v_sql := v_sql || ' IDENT_FIS_JUR       VARCHAR2(12), ';
        v_sql := v_sql || ' NUM_DOCFIS          VARCHAR2(12), ';
        v_sql := v_sql || ' SERIE_DOCFIS        VARCHAR2(3), ';
        v_sql := v_sql || ' SUB_SERIE_DOCFIS    VARCHAR2(2), ';
        v_sql := v_sql || ' DISCRI_ITEM         VARCHAR2(46), ';
        v_sql := v_sql || ' NUM_ITEM            NUMBER(5), ';
        v_sql := v_sql || ' COD_FIS_JUR         VARCHAR2(14), ';
        v_sql := v_sql || ' CPF_CGC             VARCHAR2(14), ';
        v_sql := v_sql || ' COD_NBM             VARCHAR2(10), ';
        v_sql := v_sql || ' COD_CFO             VARCHAR2(4), ';
        v_sql := v_sql || ' COD_NATUREZA_OP     VARCHAR2(3), ';
        v_sql := v_sql || ' COD_PRODUTO         VARCHAR2(35), ';
        v_sql := v_sql || ' VLR_CONTAB_ITEM     NUMBER(17,2), ';
        v_sql := v_sql || ' QUANTIDADE          NUMBER(12,4), ';
        v_sql := v_sql || ' VLR_UNIT            NUMBER(17,2), ';
        v_sql := v_sql || ' COD_SITUACAO_B      VARCHAR2(2), ';
        v_sql := v_sql || ' DATA_EMISSAO        DATE, ';
        v_sql := v_sql || ' COD_ESTADO          VARCHAR2(2), ';
        v_sql := v_sql || ' NUM_CONTROLE_DOCTO  VARCHAR2(12), ';
        v_sql := v_sql || ' NUM_AUTENTIC_NFE    VARCHAR2(80)) ';
        v_sql := v_sql || ' PCTFREE     10 ';
        v_sql := v_sql || ' TABLESPACE ' || v_tablespace_table;

        EXECUTE IMMEDIATE v_sql;

        save_tmp_control ( vp_proc_instance
                         , vp_tab_entrada_c );
    END;

    PROCEDURE create_tab_entrada_cd_idx ( vp_proc_instance IN NUMBER
                                        , vp_tab_entrada_cd IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 1000 );
    BEGIN
        v_sql := 'CREATE UNIQUE INDEX PK_DPSP_E_C_' || vp_proc_instance || ' ON ' || vp_tab_entrada_cd || ' ';
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || '    PROC_ID             ASC, ';
        v_sql := v_sql || '    COD_EMPRESA         ASC, ';
        v_sql := v_sql || '    COD_ESTAB           ASC, ';
        v_sql := v_sql || '    DATA_FISCAL         ASC, ';
        v_sql := v_sql || '    MOVTO_E_S           ASC, ';
        v_sql := v_sql || '    NORM_DEV            ASC, ';
        v_sql := v_sql || '    IDENT_DOCTO         ASC, ';
        v_sql := v_sql || '    IDENT_FIS_JUR       ASC, ';
        v_sql := v_sql || '    NUM_DOCFIS          ASC, ';
        v_sql := v_sql || '    SERIE_DOCFIS        ASC, ';
        v_sql := v_sql || '    SUB_SERIE_DOCFIS    ASC, ';
        v_sql := v_sql || '    DISCRI_ITEM         ASC ';
        v_sql := v_sql || '  ) ';
        v_sql := v_sql || '  PCTFREE     10 ';
        v_sql := v_sql || ' TABLESPACE ' || v_tablespace_index;


        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX1_DPSP_E_C_' || vp_proc_instance || ' ON ' || vp_tab_entrada_cd || ' ';
        v_sql := v_sql || '   ( ';
        v_sql := v_sql || '     PROC_ID     ASC, ';
        v_sql := v_sql || '     COD_EMPRESA ASC, ';
        v_sql := v_sql || '     COD_ESTAB   ASC, ';
        v_sql := v_sql || '     COD_PRODUTO ASC ';
        v_sql := v_sql || '   ) ';
        v_sql := v_sql || '   PCTFREE     10 ';
        v_sql := v_sql || ' TABLESPACE ' || v_tablespace_index;

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX2_DPSP_E_C_' || vp_proc_instance || ' ON ' || vp_tab_entrada_cd || ' ';
        v_sql := v_sql || '   ( ';
        v_sql := v_sql || '     PROC_ID     ASC, ';
        v_sql := v_sql || '     COD_EMPRESA ASC, ';
        v_sql := v_sql || '     COD_ESTAB   ASC, ';
        v_sql := v_sql || '     COD_PRODUTO ASC, ';
        v_sql := v_sql || '     NUM_CONTROLE_DOCTO ASC, ';
        v_sql := v_sql || '     NUM_ITEM ASC ';
        v_sql := v_sql || '   ) ';
        v_sql := v_sql || '   PCTFREE     10 ';
        v_sql := v_sql || ' TABLESPACE ' || v_tablespace_index;

        EXECUTE IMMEDIATE v_sql;

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_tab_entrada_cd );
        loga ( '>>' || vp_tab_entrada_cd || ' CRIADA'
             , FALSE );
    END;

    PROCEDURE create_tab_entrada_f ( vp_proc_instance IN NUMBER
                                   , vp_tab_entrada_f   OUT VARCHAR2
                                   , vp_tab_entrada_f_aux   OUT VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 2000 );
    BEGIN
        ---CRIAR TEMP DE ENTRADA EM FILIAIS
        vp_tab_entrada_f := 'DPSP_MSAF_E_F_' || vp_proc_instance;

        v_sql := 'CREATE TABLE ' || vp_tab_entrada_f || ' ( ';
        v_sql := v_sql || ' PROC_ID             NUMBER(30), ';
        v_sql := v_sql || ' COD_EMPRESA         VARCHAR2(3), ';
        v_sql := v_sql || ' COD_ESTAB           VARCHAR2(6), ';
        v_sql := v_sql || ' DATA_FISCAL         DATE, ';
        v_sql := v_sql || ' MOVTO_E_S           VARCHAR2(1), ';
        v_sql := v_sql || ' NORM_DEV            VARCHAR2(1), ';
        v_sql := v_sql || ' IDENT_DOCTO         VARCHAR2(12), ';
        v_sql := v_sql || ' IDENT_FIS_JUR       VARCHAR2(12), ';
        v_sql := v_sql || ' NUM_DOCFIS          VARCHAR2(12), ';
        v_sql := v_sql || ' SERIE_DOCFIS        VARCHAR2(3), ';
        v_sql := v_sql || ' SUB_SERIE_DOCFIS    VARCHAR2(2), ';
        v_sql := v_sql || ' DISCRI_ITEM         VARCHAR2(46), ';
        v_sql := v_sql || ' NUM_ITEM            NUMBER(5), ';
        v_sql := v_sql || ' COD_FIS_JUR         VARCHAR2(14), ';
        v_sql := v_sql || ' CPF_CGC             VARCHAR2(14), ';
        v_sql := v_sql || ' COD_NBM             VARCHAR2(10), ';
        v_sql := v_sql || ' COD_CFO             VARCHAR2(4), ';
        v_sql := v_sql || ' COD_NATUREZA_OP     VARCHAR2(3), ';
        v_sql := v_sql || ' COD_PRODUTO         VARCHAR2(35), ';
        v_sql := v_sql || ' VLR_CONTAB_ITEM     NUMBER(17,2), ';
        v_sql := v_sql || ' QUANTIDADE          NUMBER(12,4), ';
        v_sql := v_sql || ' VLR_UNIT            NUMBER(17,2), ';
        v_sql := v_sql || ' COD_SITUACAO_B      VARCHAR2(2), ';
        v_sql := v_sql || ' DATA_EMISSAO        DATE, ';
        v_sql := v_sql || ' COD_ESTADO          VARCHAR2(2), ';
        v_sql := v_sql || ' NUM_CONTROLE_DOCTO  VARCHAR2(12), ';
        v_sql := v_sql || ' NUM_AUTENTIC_NFE    VARCHAR2(80)) ';
        v_sql := v_sql || ' PCTFREE     10 ';
        v_sql := v_sql || ' TABLESPACE ' || v_tablespace_table;

        EXECUTE IMMEDIATE v_sql;

        save_tmp_control ( vp_proc_instance
                         , vp_tab_entrada_f );


        ---CRIAR TEMP DE ENTRADA EM FILIAIS
        vp_tab_entrada_f_aux := 'DPSP_MSAF_E_A1_' || vp_proc_instance;

        v_sql := 'CREATE TABLE ' || vp_tab_entrada_f_aux || ' ( ';
        v_sql := v_sql || ' PROC_ID             NUMBER(30), ';
        v_sql := v_sql || ' COD_EMPRESA         VARCHAR2(3), ';
        v_sql := v_sql || ' COD_ESTAB           VARCHAR2(6), ';
        v_sql := v_sql || ' DATA_FISCAL         DATE, ';
        v_sql := v_sql || ' MOVTO_E_S           VARCHAR2(1), ';
        v_sql := v_sql || ' NORM_DEV            VARCHAR2(1), ';
        v_sql := v_sql || ' IDENT_DOCTO         VARCHAR2(12), ';
        v_sql := v_sql || ' IDENT_FIS_JUR       VARCHAR2(12), ';
        v_sql := v_sql || ' NUM_DOCFIS          VARCHAR2(12), ';
        v_sql := v_sql || ' SERIE_DOCFIS        VARCHAR2(3), ';
        v_sql := v_sql || ' SUB_SERIE_DOCFIS    VARCHAR2(2), ';
        v_sql := v_sql || ' DISCRI_ITEM         VARCHAR2(46), ';
        v_sql := v_sql || ' NUM_ITEM            NUMBER(5), ';
        v_sql := v_sql || ' COD_FIS_JUR         VARCHAR2(14), ';
        v_sql := v_sql || ' CPF_CGC             VARCHAR2(14), ';
        v_sql := v_sql || ' COD_NBM             VARCHAR2(10), ';
        v_sql := v_sql || ' COD_CFO             VARCHAR2(4), ';
        v_sql := v_sql || ' COD_NATUREZA_OP     VARCHAR2(3), ';
        v_sql := v_sql || ' COD_PRODUTO         VARCHAR2(35), ';
        v_sql := v_sql || ' VLR_CONTAB_ITEM     NUMBER(17,2), ';
        v_sql := v_sql || ' QUANTIDADE          NUMBER(12,4), ';
        v_sql := v_sql || ' VLR_UNIT            NUMBER(17,2), ';
        v_sql := v_sql || ' COD_SITUACAO_B      VARCHAR2(2), ';
        v_sql := v_sql || ' DATA_EMISSAO        DATE, ';
        v_sql := v_sql || ' COD_ESTADO          VARCHAR2(2), ';
        v_sql := v_sql || ' NUM_CONTROLE_DOCTO  VARCHAR2(12), ';
        v_sql := v_sql || ' NUM_AUTENTIC_NFE    VARCHAR2(80), ';
        v_sql := v_sql || ' DATA_FISCAL_SAIDA   DATE) ';
        v_sql := v_sql || ' PCTFREE     10 ';
        v_sql := v_sql || ' TABLESPACE ' || v_tablespace_table;

        EXECUTE IMMEDIATE v_sql;

        save_tmp_control ( vp_proc_instance
                         , vp_tab_entrada_f_aux );
    END;

    PROCEDURE create_tab_entrada_f_idx ( vp_proc_instance IN NUMBER
                                       , vp_tab_entrada_f IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 1000 );
    BEGIN
        v_sql := 'CREATE UNIQUE INDEX PK_DPSP_E_F_' || vp_proc_instance || ' ON ' || vp_tab_entrada_f || ' ';
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || '    PROC_ID             ASC, ';
        v_sql := v_sql || '    COD_EMPRESA         ASC, ';
        v_sql := v_sql || '    COD_ESTAB           ASC, ';
        v_sql := v_sql || '    DATA_FISCAL         ASC, ';
        v_sql := v_sql || '    MOVTO_E_S           ASC, ';
        v_sql := v_sql || '    NORM_DEV            ASC, ';
        v_sql := v_sql || '    IDENT_DOCTO         ASC, ';
        v_sql := v_sql || '    IDENT_FIS_JUR       ASC, ';
        v_sql := v_sql || '    NUM_DOCFIS          ASC, ';
        v_sql := v_sql || '    SERIE_DOCFIS        ASC, ';
        v_sql := v_sql || '    SUB_SERIE_DOCFIS    ASC, ';
        v_sql := v_sql || '    DISCRI_ITEM         ASC ';
        v_sql := v_sql || '  ) ';
        v_sql := v_sql || '  PCTFREE     10 ';
        v_sql := v_sql || ' TABLESPACE ' || v_tablespace_index;

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX1_DPSP_E_F_' || vp_proc_instance || ' ON ' || vp_tab_entrada_f || ' ';
        v_sql := v_sql || '   ( ';
        v_sql := v_sql || '     PROC_ID      ASC, ';
        v_sql := v_sql || '     COD_EMPRESA  ASC, ';
        v_sql := v_sql || '     COD_ESTAB    ASC, ';
        v_sql := v_sql || '     COD_PRODUTO  ASC, ';
        v_sql := v_sql || '     COD_FIS_JUR  ASC ';
        v_sql := v_sql || '   ) ';
        v_sql := v_sql || '   PCTFREE     10 ';
        v_sql := v_sql || ' TABLESPACE ' || v_tablespace_index;

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX2_DPSP_E_F_' || vp_proc_instance || ' ON ' || vp_tab_entrada_f || ' ';
        v_sql := v_sql || '   ( ';
        v_sql := v_sql || '     PROC_ID      ASC, ';
        v_sql := v_sql || '     COD_EMPRESA  ASC, ';
        v_sql := v_sql || '     COD_ESTAB    ASC, ';
        v_sql := v_sql || '     COD_PRODUTO  ASC, ';
        v_sql := v_sql || '     COD_FIS_JUR  ASC, ';
        v_sql := v_sql || '     NUM_CONTROLE_DOCTO ASC, ';
        v_sql := v_sql || '     NUM_ITEM ASC ';
        v_sql := v_sql || '   ) ';
        v_sql := v_sql || '   PCTFREE     10 ';
        v_sql := v_sql || ' TABLESPACE ' || v_tablespace_index;

        EXECUTE IMMEDIATE v_sql;

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_tab_entrada_f );
        loga ( '>>' || vp_tab_entrada_f || ' CRIADA'
             , FALSE );
    END;

    PROCEDURE create_tab_entrada_a1_idx ( vp_proc_instance IN NUMBER
                                        , vp_tab_entrada_a1 IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 1000 );
    BEGIN
        v_sql := 'CREATE INDEX IDX1_DPSP_E_A1_' || vp_proc_instance || ' ON ' || vp_tab_entrada_a1 || ' ';
        v_sql := v_sql || '   ( ';
        v_sql := v_sql || '     PROC_ID      ASC, ';
        v_sql := v_sql || '     COD_EMPRESA  ASC, ';
        v_sql := v_sql || '     COD_ESTAB    ASC, ';
        v_sql := v_sql || '     COD_PRODUTO  ASC, ';
        v_sql := v_sql || '     DATA_FISCAL_SAIDA  ASC, ';
        v_sql := v_sql || '     COD_FIS_JUR  ASC ,';
        v_sql := v_sql || '     DATA_FISCAL  DESC ,';
        v_sql := v_sql || '     DATA_EMISSAO  DESC ,';
        v_sql := v_sql || '     NUM_DOCFIS  ASC ,';
        v_sql := v_sql || '     DISCRI_ITEM  ASC ';
        v_sql := v_sql || '   ) ';
        v_sql := v_sql || '   PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_tab_entrada_a1 );
        loga ( ' - ' || vp_tab_entrada_a1 || ' CRIADA'
             , FALSE );
    END;

    PROCEDURE load_dados_cartoes ( vp_cod_estab IN VARCHAR2
                                 , vp_data_inicial IN DATE
                                 , vp_data_final IN DATE
                                 , vp_data_hora_ini IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 2000 );
        v_existe VARCHAR2 ( 1 );

        --CURSOR AUXILIAR
        CURSOR c_data_saida ( p_i_data_inicial IN DATE
                            , p_i_data_final IN DATE )
        IS
            SELECT   b.data_fiscal AS data_normal
                FROM (SELECT p_i_data_inicial + ( ROWNUM - 1 ) AS data_fiscal
                        FROM all_objects
                       WHERE ROWNUM <= (p_i_data_final - p_i_data_inicial + 1)) b
            ORDER BY b.data_fiscal;
    --

    BEGIN
        loga ( 'LOAD_PAGTO_CARTOES-INI-' || vp_cod_estab
             , FALSE );

        FOR cd IN c_data_saida ( vp_data_inicial
                               , vp_data_final ) LOOP
            --ARMAZENAR DADOS DE PAGTO DE CARTAO, POIS O DH UTILIZA APENAS OS ULTIMOS 60 DIAS EM PRD
            BEGIN
                SELECT DISTINCT 'Y'
                  INTO v_existe
                  FROM msafi.dpsp_msaf_pagto_cartoes_jj
                 WHERE cod_empresa = msafi.dpsp.empresa
                   AND cod_estab = vp_cod_estab
                   AND data_transacao = cd.data_normal
                   AND ROWNUM < 2;
            EXCEPTION
                WHEN OTHERS THEN
                    v_existe := 'N';
            END;

            IF ( v_existe <> 'Y' ) THEN
                v_sql := '';
                v_sql := v_sql || ' BEGIN';
                v_sql := v_sql || ' FOR C IN (';

                v_sql := v_sql || ' SELECT ';
                v_sql := v_sql || ' ''' || msafi.dpsp.empresa || ''' cod_empresa, ';
                v_sql := v_sql || ' ''' || vp_cod_estab || ''' cod_estab, ';
                v_sql := v_sql || ' CF.NUMERO_CUPOM, ';
                v_sql := v_sql || ' CT.NUMERO_COMPONENTE, ';
                v_sql := v_sql || ' TO_DATE(CT.DATA_TRANSACAO,''YYYYMMDD'') data_transacao, ';
                v_sql := v_sql || ' CT.NOME_AUTORIZADORA, ';
                v_sql := v_sql || ' CT.NOME_VAN, ';
                v_sql := v_sql || ' CC.CODIGO_FORMA, ';
                v_sql := v_sql || ' CT.NUMERO_PARCELAS, ';
                v_sql := v_sql || ' CT.VALOR_TOTAL, ';
                v_sql :=
                    v_sql || ' SUBSTR(TRIM(NVL(CT.CODIGO_APROVACAO, 0)) || ''|'' || CT.ROWID, 1, 30) codigo_aprovacao ';
                --
                v_sql := v_sql || ' FROM ';
                v_sql := v_sql || ' MSAFI.P2K_CAB_TRANSACAO CF, ';
                v_sql := v_sql || ' MSAFI.P2K_RECB_CARTAO   CT, ';
                v_sql := v_sql || ' MSAFI.P2K_RECB_TRANSACAO CC ';
                ---
                v_sql := v_sql || ' WHERE 1=1 ';
                v_sql := v_sql || ' AND CF.CODIGO_LOJA = CT.CODIGO_LOJA ';
                v_sql := v_sql || ' AND CF.DATA_TRANSACAO = CT.DATA_TRANSACAO ';
                v_sql := v_sql || ' AND CF.NUMERO_COMPONENTE = CT.NUMERO_COMPONENTE ';
                v_sql := v_sql || ' AND CF.NSU_TRANSACAO = CT.NSU_TRANSACAO ';
                v_sql := v_sql || ' AND CC.CODIGO_LOJA = CT.CODIGO_LOJA ';
                v_sql := v_sql || ' AND CC.DATA_TRANSACAO = CT.DATA_TRANSACAO ';
                v_sql := v_sql || ' AND CC.NUMERO_COMPONENTE = CT.NUMERO_COMPONENTE ';
                v_sql := v_sql || ' AND CC.NSU_TRANSACAO = CT.NSU_TRANSACAO ';
                v_sql := v_sql || ' AND CC.NUM_SEQ_FORMA = CT.NUM_SEQ_FORMA ';
                v_sql :=
                       v_sql
                    || ' AND CF.CODIGO_LOJA = TO_NUMBER(REGEXP_REPLACE('''
                    || vp_cod_estab
                    || ''',''A|B|C|D|E|F|G|H|I|J|K|L|M|N|O|P|Q|R|S|T|U|V|W|X|Y|Z'','''')) ';
                v_sql :=
                       v_sql
                    || ' AND CT.DATA_TRANSACAO = '''
                    || TO_CHAR ( cd.data_normal
                               , 'YYYYMMDD' )
                    || ''' ';
                --  V_SQL := V_SQL || ' ) ';


                v_sql := v_sql || '  )';
                v_sql := v_sql || ' LOOP';


                v_sql := v_sql || ' INSERT /*+APPEND*/ INTO MSAFI.DPSP_MSAF_PAGTO_CARTOES_jj  ';
                v_sql := v_sql || ' VALUES ( ';
                v_sql := v_sql || ' C.COD_EMPRESA, ';
                v_sql := v_sql || ' C.COD_ESTAB, ';
                v_sql := v_sql || ' C.NUMERO_CUPOM, ';
                v_sql := v_sql || ' C.NUMERO_COMPONENTE,';
                v_sql := v_sql || ' C.DATA_TRANSACAO, ';
                v_sql := v_sql || ' C.NOME_AUTORIZADORA,';
                v_sql := v_sql || ' C.NOME_VAN, ';
                v_sql := v_sql || ' C.CODIGO_FORMA, ';
                v_sql := v_sql || ' C.NUMERO_PARCELAS, ';
                v_sql := v_sql || ' C.VALOR_TOTAL, ';
                v_sql := v_sql || ' C.CODIGO_APROVACAO';
                v_sql := v_sql || '); ';

                v_sql := v_sql || ' COMMIT; ';

                v_sql := v_sql || ' END LOOP; ';

                v_sql := v_sql || ' END; ';


                BEGIN
                    EXECUTE IMMEDIATE v_sql;

                    COMMIT;
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
                        --ENVIAR EMAIL DE ERRO-------------------------------------------
                        envia_email ( mcod_empresa
                                    , vp_data_inicial
                                    , vp_data_final
                                    , SQLERRM
                                    , 'E'
                                    , vp_data_hora_ini );
                        -----------------------------------------------------------------
                        raise_application_error ( -20004
                                                , '!ERRO INSERT LOAD PAGTO CARTOES!' );
                END;
            END IF;
        END LOOP;

        loga ( 'LOAD_PAGTO_CARTOES-FIM-' || vp_cod_estab
             , FALSE );
    END;

    PROCEDURE load_saidas ( vp_proc_instance IN VARCHAR2
                          , vp_cod_estab IN VARCHAR2
                          , vp_data_ini IN DATE
                          , vp_data_fim IN DATE
                          , vp_tabela_saida IN VARCHAR2
                          , vp_data_hora_ini IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 10000 );

        v_data_inicial DATE := vp_data_ini; -- DATA INICIAL
        v_data_final DATE := vp_data_fim; -- DATA FINAL
    BEGIN
        loga ( 'LOAD_SAIDAS-INI-' || vp_cod_estab
             , FALSE );

        --=========================================
        --CARREGAR INFORMACOES DE VENDAS: NFs
        --=========================================
        v_sql := 'INSERT /*+APPEND*/ INTO ' || vp_tabela_saida || ' ';

        v_sql := v_sql || ' SELECT ''' || vp_proc_instance || ''', ';
        v_sql := v_sql || ' ''' || mcod_empresa || ''', ';
        v_sql := v_sql || ' DOC.COD_ESTAB, ';
        v_sql := v_sql || ' UFEST.COD_ESTADO, ';
        v_sql := v_sql || ' TIP.COD_DOCTO, ';
        v_sql := v_sql || ' PRD.COD_PRODUTO, ';
        v_sql := v_sql || ' ITEM.NUM_ITEM, ';
        v_sql := v_sql || ' PRD.DESCRICAO, ';
        v_sql := v_sql || ' DOC.NUM_DOCFIS, ';
        v_sql := v_sql || ' DOC.DATA_FISCAL, ';
        v_sql := v_sql || ' DOC.SERIE_DOCFIS, ';
        v_sql := v_sql || ' SUM(ITEM.QUANTIDADE), ';
        v_sql := v_sql || ' NCM.COD_NBM, ';
        v_sql := v_sql || ' CFOP.COD_CFO, ';
        v_sql := v_sql || ' GRP.DESCRICAO, ';
        v_sql := v_sql || ' SUM(ITEM.VLR_DESCONTO), ';
        v_sql := v_sql || ' SUM(ITEM.VLR_CONTAB_ITEM), ';
        v_sql := v_sql || ' '''' || DOC.NUM_AUTENTIC_NFE, ';
        v_sql := v_sql || ' SUM(NVL(BSE.VLR_BASE,0)), ';
        v_sql := v_sql || ' TRIB.ALIQ_TRIBUTO, ';
        v_sql := v_sql || ' SUM(TRIB.VLR_TRIBUTO), ';
        v_sql := v_sql || ' DECODE(CFOP.COD_CFO,''5405'',''ST'',''NORMAL''), ';
        v_sql := v_sql || ' DH.NOME_AUTORIZADORA, ';
        v_sql := v_sql || ' DH.NOME_VAN, ';
        v_sql := v_sql || ' SUM(DH.VALOR_TOTAL), ';
        v_sql := v_sql || ' DECODE(DH.CODIGO_FORMA,''9'',''DEBITO'',''11'',''CREDITO'',''-''), ';
        v_sql := v_sql || ' DH.NUMERO_PARCELAS, ';
        v_sql := v_sql || ' DH.CODIGO_APROVACAO ';
        ---
        v_sql := v_sql || ' FROM ';
        v_sql :=
               v_sql
            || ' MSAF.X08_ITENS_MERC PARTITION FOR (TO_DATE('''
            || TO_CHAR ( v_data_inicial
                       , 'DD/MM/YYYY' )
            || ''',''DD/MM/YYYY'') )ITEM, ';
        v_sql :=
               v_sql
            || ' MSAF.X07_DOCTO_FISCAL  PARTITION  FOR (TO_DATE('''
            || TO_CHAR ( v_data_inicial
                       , 'DD/MM/YYYY' )
            || ''',''DD/MM/YYYY'') )DOC, ';

        --V_SQL := V_SQL || ' FROM MSAF.X08_ITENS_MERC ITEM, ';
        --V_SQL := V_SQL || ' MSAF.X07_DOCTO_FISCAL  DOC, ';
        v_sql := v_sql || ' MSAF.X2013_PRODUTO     PRD, ';
        v_sql := v_sql || ' MSAF.ESTABELECIMENTO   EST, ';
        v_sql := v_sql || ' MSAF.ESTADO            UFEST, ';
        v_sql := v_sql || ' MSAF.X2043_COD_NBM     NCM, ';
        v_sql := v_sql || ' MSAF.X2012_COD_FISCAL  CFOP, ';
        v_sql := v_sql || ' MSAF.GRUPO_PRODUTO     GRP, ';
        v_sql := v_sql || ' MSAF.X2005_TIPO_DOCTO  TIP, ';
        v_sql := v_sql || ' MSAFI.DPSP_MSAF_PAGTO_CARTOES_jj DH, ';
        --V_SQL := V_SQL || ' MSAF.X08_BASE_MERC BSE, ';
        --V_SQL := V_SQL || ' MSAF.X08_TRIB_MERC TRIB ';

        v_sql :=
               v_sql
            || ' MSAF.X08_BASE_MERC PARTITION FOR (TO_DATE('''
            || TO_CHAR ( v_data_inicial
                       , 'DD/MM/YYYY' )
            || ''',''DD/MM/YYYY'') )BSE, ';
        v_sql :=
               v_sql
            || ' MSAF.X08_TRIB_MERC  PARTITION  FOR (TO_DATE('''
            || TO_CHAR ( v_data_inicial
                       , 'DD/MM/YYYY' )
            || ''',''DD/MM/YYYY'') )TRIB ';

        v_sql := v_sql || ' WHERE 1=1 ';

        v_sql := v_sql || ' AND ITEM.COD_EMPRESA = ''' || mcod_empresa || ''' ';
        v_sql := v_sql || ' AND ITEM.COD_ESTAB = ''' || vp_cod_estab || ''' ';
        v_sql :=
               v_sql
            || ' AND ITEM.DATA_FISCAL BETWEEN TO_DATE('''
            || TO_CHAR ( v_data_inicial
                       , 'YYYYMMDD' )
            || ''',''YYYYMMDD'') AND TO_DATE('''
            || TO_CHAR ( v_data_final
                       , 'YYYYMMDD' )
            || ''',''YYYYMMDD'') ';

        v_sql := v_sql || ' AND ITEM.COD_EMPRESA = DOC.COD_EMPRESA ';
        v_sql := v_sql || ' AND ITEM.COD_ESTAB = DOC.COD_ESTAB ';
        v_sql := v_sql || ' AND ITEM.DATA_FISCAL = DOC.DATA_FISCAL ';
        v_sql := v_sql || ' AND ITEM.MOVTO_E_S = DOC.MOVTO_E_S ';
        v_sql := v_sql || ' AND ITEM.NORM_DEV = DOC.NORM_DEV ';
        v_sql := v_sql || ' AND ITEM.IDENT_DOCTO = DOC.IDENT_DOCTO ';
        v_sql := v_sql || ' AND ITEM.IDENT_FIS_JUR = DOC.IDENT_FIS_JUR ';
        v_sql := v_sql || ' AND ITEM.NUM_DOCFIS = DOC.NUM_DOCFIS ';
        v_sql := v_sql || ' AND ITEM.SERIE_DOCFIS = DOC.SERIE_DOCFIS ';
        v_sql := v_sql || ' AND ITEM.SUB_SERIE_DOCFIS = DOC.SUB_SERIE_DOCFIS ';

        v_sql := v_sql || ' AND DOC.IDENT_DOCTO = TIP.IDENT_DOCTO ';
        v_sql := v_sql || ' AND TIP.COD_DOCTO IN (''CF-E'',''SAT'') ';
        v_sql := v_sql || ' AND DOC.COD_EMPRESA = EST.COD_EMPRESA ';
        v_sql := v_sql || ' AND DOC.COD_ESTAB = EST.COD_ESTAB ';
        v_sql := v_sql || ' AND EST.IDENT_ESTADO = UFEST.IDENT_ESTADO ';
        v_sql := v_sql || ' AND ITEM.IDENT_PRODUTO = PRD.IDENT_PRODUTO ';
        v_sql := v_sql || ' AND PRD.IDENT_NBM = NCM.IDENT_NBM ';
        v_sql := v_sql || ' AND ITEM.IDENT_CFO = CFOP.IDENT_CFO ';
        v_sql := v_sql || ' AND PRD.IDENT_GRUPO_PROD  = GRP.IDENT_GRUPO_PROD ';
        v_sql := v_sql || ' AND DOC.SITUACAO  <> ''S'' ';

        v_sql := v_sql || ' AND DOC.COD_EMPRESA = DH.COD_EMPRESA ';
        v_sql := v_sql || ' AND DOC.COD_ESTAB = DH.COD_ESTAB ';
        v_sql := v_sql || ' AND DOC.DATA_FISCAL  = DH.DATA_TRANSACAO ';
        v_sql := v_sql || ' AND DOC.SERIE_DOCFIS = DH.NUMERO_COMPONENTE ';
        v_sql := v_sql || ' AND LTRIM(DOC.NUM_DOCFIS,''0'') = DH.NUMERO_CUPOM ';

        v_sql := v_sql || ' AND BSE.COD_EMPRESA (+) = ITEM.COD_EMPRESA ';
        v_sql := v_sql || ' AND BSE.COD_ESTAB (+) = ITEM.COD_ESTAB ';
        v_sql := v_sql || ' AND BSE.DATA_FISCAL (+) = ITEM.DATA_FISCAL ';
        v_sql := v_sql || ' AND BSE.MOVTO_E_S (+) = ITEM.MOVTO_E_S ';
        v_sql := v_sql || ' AND BSE.NORM_DEV (+) = ITEM.NORM_DEV ';
        v_sql := v_sql || ' AND BSE.IDENT_DOCTO (+) = ITEM.IDENT_DOCTO ';
        v_sql := v_sql || ' AND BSE.IDENT_FIS_JUR (+)= ITEM.IDENT_FIS_JUR ';
        v_sql := v_sql || ' AND BSE.NUM_DOCFIS (+) = ITEM.NUM_DOCFIS ';
        v_sql := v_sql || ' AND BSE.SERIE_DOCFIS (+) = ITEM.SERIE_DOCFIS ';
        v_sql := v_sql || '  AND BSE.SUB_SERIE_DOCFIS (+) = ITEM.SUB_SERIE_DOCFIS ';
        v_sql := v_sql || ' AND BSE.DISCRI_ITEM (+) = ITEM.DISCRI_ITEM ';
        v_sql := v_sql || ' AND BSE.COD_TRIBUTO (+) = ''ICMS'' ';
        v_sql := v_sql || ' AND BSE.COD_TRIBUTACAO (+)  = ''1'' ';

        v_sql := v_sql || ' AND TRIB.COD_EMPRESA (+) = ITEM.COD_EMPRESA ';
        v_sql := v_sql || ' AND TRIB.COD_ESTAB (+)  = ITEM.COD_ESTAB ';
        v_sql := v_sql || ' AND TRIB.DATA_FISCAL (+) = ITEM.DATA_FISCAL ';
        v_sql := v_sql || ' AND TRIB.MOVTO_E_S (+) = ITEM.MOVTO_E_S ';
        v_sql := v_sql || ' AND TRIB.NORM_DEV (+) = ITEM.NORM_DEV ';
        v_sql := v_sql || ' AND TRIB.IDENT_DOCTO (+) = ITEM.IDENT_DOCTO ';
        v_sql := v_sql || ' AND TRIB.IDENT_FIS_JUR (+)= ITEM.IDENT_FIS_JUR ';
        v_sql := v_sql || ' AND TRIB.NUM_DOCFIS (+) = ITEM.NUM_DOCFIS ';
        v_sql := v_sql || ' AND TRIB.SERIE_DOCFIS (+) = ITEM.SERIE_DOCFIS ';
        v_sql := v_sql || ' AND TRIB.SUB_SERIE_DOCFIS (+) = ITEM.SUB_SERIE_DOCFIS ';
        v_sql := v_sql || ' AND TRIB.DISCRI_ITEM (+) = ITEM.DISCRI_ITEM ';
        v_sql := v_sql || ' AND TRIB.COD_TRIBUTO (+) = ''ICMS'' ';

        v_sql := v_sql || ' GROUP BY DOC.COD_ESTAB , ';
        v_sql := v_sql || ' UFEST.COD_ESTADO , ';
        v_sql := v_sql || ' PRD.COD_PRODUTO , ';
        v_sql := v_sql || ' ITEM.NUM_ITEM  , ';
        v_sql := v_sql || ' PRD.DESCRICAO  , ';
        v_sql := v_sql || ' DOC.NUM_DOCFIS  , ';
        v_sql := v_sql || ' DOC.DATA_FISCAL , ';
        v_sql := v_sql || ' DOC.SERIE_DOCFIS , ';
        v_sql := v_sql || ' NCM.COD_NBM , ';
        v_sql := v_sql || ' CFOP.COD_CFO   , ';
        v_sql := v_sql || ' GRP.DESCRICAO  , ';
        v_sql := v_sql || ' TIP.COD_DOCTO  , ';
        v_sql := v_sql || ' DOC.NUM_AUTENTIC_NFE, ';
        v_sql := v_sql || ' TRIB.ALIQ_TRIBUTO, ';
        v_sql := v_sql || '	NOME_AUTORIZADORA, ';
        v_sql := v_sql || ' NOME_VAN, ';
        v_sql := v_sql || ' DECODE(DH.CODIGO_FORMA,''9'',''DEBITO'',''11'',''CREDITO'',''-''), ';
        v_sql := v_sql || ' DH.NUMERO_PARCELAS, ';
        v_sql := v_sql || ' DH.CODIGO_APROVACAO ';

        BEGIN
            EXECUTE IMMEDIATE v_sql;

            COMMIT;
        --AUDITORIA DO V_SQL

        /*LOGA('----NF-----', FALSE);
        LOGA(SUBSTR(V_SQL, 1, 1024), FALSE);
        LOGA(SUBSTR(V_SQL, 1024, 1024), FALSE);
        LOGA(SUBSTR(V_SQL, 2048, 1024), FALSE);
        LOGA(SUBSTR(V_SQL, 3072), FALSE);
        LOGA('----NF-----', FALSE);*/

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
                              , 3072 )
                     , FALSE );
                --ENVIAR EMAIL DE ERRO-------------------------------------------
                envia_email ( mcod_empresa
                            , v_data_inicial
                            , v_data_final
                            , SQLERRM
                            , 'E'
                            , vp_data_hora_ini );
                -----------------------------------------------------------------
                raise_application_error ( -20022
                                        , '!ERRO INSERT LOAD_SAIDAS![1]' );
        END;

        --=========================================
        --CARREGAR INFORMACOES DE VENDAS: CUPONS
        --=========================================
        v_sql := 'INSERT /*+APPEND*/ INTO ' || vp_tabela_saida || ' ';

        v_sql := v_sql || ' SELECT ''' || vp_proc_instance || ''', ';
        v_sql := v_sql || '  ''' || mcod_empresa || ''', ';
        v_sql := v_sql || '  X993.COD_ESTAB           NUMERO_ESTAB, ';
        v_sql := v_sql || '  UF_EST.COD_ESTADO        UF_ESTAB, ';
        v_sql := v_sql || '  ''ECF''                  DOCTO, ';
        v_sql := v_sql || '  X2013.COD_PRODUTO        COD_ITEM, ';
        v_sql := v_sql || '  X994.NUM_ITEM            NUM_ITEM, ';
        v_sql := v_sql || '  X2013.DESCRICAO          DESCR_ITEM, ';
        v_sql := v_sql || '  X993.NUM_COO             NUMERO_CF, ';
        v_sql := v_sql || '  X993.DATA_EMISSAO        DATA_FISCAL_CF, ';
        v_sql := v_sql || '  X2087.COD_CAIXA_ECF      EQUIPAMENTO, ';
        v_sql := v_sql || '  SUM(X994.QTDE)           QTD_VENDIDA, ';
        v_sql := v_sql || '  NCM.COD_NBM              NCM, ';
        v_sql := v_sql || '  X2012.COD_CFO            CFOP, ';
        v_sql := v_sql || '  GRP.DESCRICAO            GRUPO_PRD, ';
        v_sql := v_sql || '  SUM(X994.VLR_DESC)       VLR_DESCONTO, ';
        v_sql := v_sql || '  SUM(X994.VLR_LIQ_ITEM)   VALOR_CONTAB, ';
        v_sql := v_sql || '  ''-''                    CHAVE_ACESSO, ';
        v_sql := v_sql || '  SUM(X994.VLR_BASE)       VLR_BASE_ICMS, ';
        v_sql := v_sql || '  X996.VLR_ALIQ ALIQ_ICMS, ';
        v_sql := v_sql || '  SUM(X994.VLR_TRIBUTO)    VLR_ICMS, ';
        v_sql := v_sql || '  DECODE(SUBSTR(X996.DSC_TOTALIZADOR_ECF,1,2),''ST'',''ST'',''NORMAL'') DESCR_TOT, ';
        v_sql := v_sql || '  DH.NOME_AUTORIZADORA        NOME_AUTORIZADORA, ';
        v_sql := v_sql || '  DH.NOME_VAN                 NOME_VAN, ';
        v_sql := v_sql || '  SUM(DH.VALOR_TOTAL)         VALOR_PAGTO_CARTAO, ';
        v_sql := v_sql || '  DECODE(DH.CODIGO_FORMA,''9'',''DEBITO'',''11'',''CREDITO'',''-'') FORMA_PAGTO, ';
        v_sql := v_sql || '  DH.NUMERO_PARCELAS, ';
        v_sql := v_sql || '  DH.CODIGO_APROVACAO ';
        ---
        v_sql := v_sql || 'FROM ';
        v_sql := v_sql || '  MSAF.X993_CAPA_CUPOM_ECF   X993 ';
        v_sql := v_sql || '  ,MSAF.X994_ITEM_CUPOM_ECF   X994 ';
        v_sql := v_sql || '  ,MSAF.X996_TOTALIZADOR_PARCIAL_ECF X996 ';
        v_sql := v_sql || '  ,MSAF.X2087_EQUIPAMENTO_ECF X2087 ';
        v_sql := v_sql || '  ,MSAF.ESTABELECIMENTO       EST ';
        v_sql := v_sql || '  ,MSAF.ESTADO                UF_EST ';
        v_sql := v_sql || '  ,MSAF.X2013_PRODUTO         X2013 ';
        v_sql := v_sql || '  ,MSAF.X2012_COD_FISCAL      X2012 ';
        v_sql := v_sql || '  ,MSAF.X2043_COD_NBM         NCM ';
        v_sql := v_sql || '  ,MSAF.GRUPO_PRODUTO         GRP ';
        v_sql := v_sql || '  ,MSAFI.DPSP_MSAF_PAGTO_CARTOES_jj DH ';

        v_sql := v_sql || 'WHERE 1=1 ';

        v_sql := v_sql || ' AND X993.COD_EMPRESA = ''' || mcod_empresa || ''' ';
        v_sql := v_sql || ' AND X993.COD_ESTAB   = ''' || vp_cod_estab || ''' ';
        ---
        v_sql :=
               v_sql
            || '  AND X993.DATA_EMISSAO BETWEEN TO_DATE('''
            || TO_CHAR ( v_data_inicial
                       , 'YYYYMMDD' )
            || ''',''YYYYMMDD'') AND TO_DATE('''
            || TO_CHAR ( v_data_final
                       , 'YYYYMMDD' )
            || ''',''YYYYMMDD'') ';
        v_sql := v_sql || '  AND X993.IND_SITUACAO_CUPOM = ''1'' ';
        ----

        v_sql := v_sql || ' AND X994.COD_EMPRESA = X996.COD_EMPRESA ';
        v_sql := v_sql || ' AND X994.COD_ESTAB = X996.COD_ESTAB ';
        v_sql := v_sql || ' AND X994.IDENT_TOTALIZADOR_ECF = X996.IDENT_TOTALIZADOR_ECF ';

        v_sql := v_sql || ' AND X2087.COD_EMPRESA  = X993.COD_EMPRESA ';
        v_sql := v_sql || ' AND X2087.COD_ESTAB = X993.COD_ESTAB ';
        v_sql := v_sql || ' AND X2087.IDENT_CAIXA_ECF = X993.IDENT_CAIXA_ECF ';

        v_sql := v_sql || ' AND X994.COD_EMPRESA = X993.COD_EMPRESA ';
        v_sql := v_sql || ' AND X994.COD_ESTAB = X993.COD_ESTAB ';
        v_sql := v_sql || ' AND X994.IDENT_CAIXA_ECF = X993.IDENT_CAIXA_ECF ';
        v_sql := v_sql || ' AND X994.NUM_COO  = X993.NUM_COO ';
        v_sql := v_sql || ' AND X994.DATA_EMISSAO  = X993.DATA_EMISSAO ';

        v_sql := v_sql || ' AND X2013.IDENT_PRODUTO  = X994.IDENT_PRODUTO ';
        v_sql := v_sql || ' AND X2012.IDENT_CFO = X994.IDENT_CFO ';
        v_sql := v_sql || ' AND EST.COD_EMPRESA = X993.COD_EMPRESA ';
        v_sql := v_sql || ' AND EST.COD_ESTAB = X993.COD_ESTAB ';
        v_sql := v_sql || ' AND X2013.IDENT_NBM = NCM.IDENT_NBM ';
        v_sql := v_sql || ' AND X2013.IDENT_GRUPO_PROD = GRP.IDENT_GRUPO_PROD ';
        v_sql := v_sql || ' AND EST.IDENT_ESTADO = UF_EST.IDENT_ESTADO ';

        v_sql := v_sql || ' AND X993.COD_EMPRESA = DH.COD_EMPRESA ';
        v_sql := v_sql || ' AND X993.COD_ESTAB = DH.COD_ESTAB ';
        v_sql := v_sql || ' AND X993.DATA_EMISSAO = DH.DATA_TRANSACAO ';
        v_sql := v_sql || ' AND X2087.COD_CAIXA_ECF = DH.NUMERO_COMPONENTE ';
        v_sql := v_sql || ' AND LTRIM(X993.NUM_COO,''0'') = DH.NUMERO_CUPOM ';

        v_sql := v_sql || ' AND X994.IND_SITUACAO_ITEM = ''1'' ';

        v_sql := v_sql || ' GROUP BY ';
        v_sql := v_sql || ' X993.COD_ESTAB , ';
        v_sql := v_sql || ' UF_EST.COD_ESTADO , ';
        v_sql := v_sql || ' X2013.COD_PRODUTO , ';
        v_sql := v_sql || ' X994.NUM_ITEM  , ';
        v_sql := v_sql || ' X2013.DESCRICAO  , ';
        v_sql := v_sql || ' X993.NUM_COO , ';
        v_sql := v_sql || ' X993.DATA_EMISSAO , ';
        v_sql := v_sql || ' X2087.COD_CAIXA_ECF , ';
        v_sql := v_sql || ' NCM.COD_NBM , ';
        v_sql := v_sql || ' X2012.COD_CFO  , ';
        v_sql := v_sql || ' GRP.DESCRICAO  , ';
        v_sql := v_sql || ' ''ECF'' , ';
        v_sql := v_sql || ' NOME_AUTORIZADORA , ';
        v_sql := v_sql || ' NOME_VAN, ';
        v_sql := v_sql || ' X996.VLR_ALIQ , ';
        v_sql := v_sql || ' X996.DSC_TOTALIZADOR_ECF, ';
        v_sql := v_sql || '	DECODE(DH.CODIGO_FORMA,''9'',''DEBITO'',''11'',''CREDITO'',''-''), ';
        v_sql := v_sql || ' DH.NUMERO_PARCELAS, ';
        v_sql := v_sql || ' DH.CODIGO_APROVACAO ';
        v_sql := v_sql || ' ';

        BEGIN
            EXECUTE IMMEDIATE v_sql;

            COMMIT;
        /*
          LOGA('----CUPOM-----', FALSE);
          LOGA(SUBSTR(V_SQL, 1, 1024), FALSE);
          LOGA(SUBSTR(V_SQL, 1024, 1024), FALSE);
          LOGA(SUBSTR(V_SQL, 2048, 1024), FALSE);
          LOGA(SUBSTR(V_SQL, 3072), FALSE);
          LOGA('----CUPOM-----', FALSE);*/

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
                              , 3072 )
                     , FALSE );
                --ENVIAR EMAIL DE ERRO-------------------------------------------
                envia_email ( mcod_empresa
                            , v_data_inicial
                            , v_data_final
                            , SQLERRM
                            , 'E'
                            , vp_data_hora_ini );
                -----------------------------------------------------------------
                raise_application_error ( -20022
                                        , '!ERRO INSERT LOAD_SAIDAS![2]' );
        END;

        loga ( 'LOAD_SAIDAS-FIM-' || vp_cod_estab
             , FALSE );
    END;

    PROCEDURE create_tab_saida_idx ( vp_proc_instance IN VARCHAR2
                                   , vp_tabela_saida IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 1000 );
    BEGIN
        v_sql := 'CREATE UNIQUE INDEX PK_DPSP_S_' || vp_proc_instance || ' ON ' || vp_tabela_saida || ' ';
        v_sql := v_sql || '( ';
        v_sql := v_sql || '  PROC_ID      ASC, ';
        v_sql := v_sql || '  COD_EMPRESA  ASC, ';
        v_sql := v_sql || '  COD_ESTAB    ASC, ';
        v_sql := v_sql || '  UF_ESTAB     ASC, ';
        v_sql := v_sql || '  DOCTO        ASC, ';
        v_sql := v_sql || '  COD_PRODUTO  ASC, ';
        v_sql := v_sql || '  NUM_ITEM     ASC, ';
        v_sql := v_sql || '  NUM_DOCFIS   ASC, ';
        v_sql := v_sql || '  DATA_FISCAL  ASC, ';
        v_sql := v_sql || '  SERIE_DOCFIS ASC, ';
        v_sql := v_sql || '  CODIGO_APROVACAO ASC ';
        v_sql := v_sql || ') ';
        v_sql := v_sql || 'PCTFREE     10 ';
        v_sql := v_sql || ' TABLESPACE ' || v_tablespace_index;

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX1_DPSP_S_' || vp_proc_instance || ' ON ' || vp_tabela_saida || ' ';
        v_sql := v_sql || '  ( ';
        v_sql := v_sql || '    PROC_ID      ASC ';
        v_sql := v_sql || '  ) ';
        v_sql := v_sql || '  PCTFREE     10 ';
        v_sql := v_sql || ' TABLESPACE ' || v_tablespace_index;

        EXECUTE IMMEDIATE v_sql;

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_tabela_saida );
        loga ( '>>' || vp_tabela_saida || ' CRIADA'
             , FALSE );
    END;

    PROCEDURE load_entradas_cd ( vp_proc_instance IN VARCHAR2
                               , vp_cod_estab IN VARCHAR2
                               , vp_origem IN VARCHAR2
                               , vp_tabela_entrada IN VARCHAR2
                               , vp_tabela_saida IN VARCHAR2
                               , vp_tabela_prod_saida IN VARCHAR2
                               , vp_data_inicio IN VARCHAR2
                               , vp_data_fim IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 10000 );
        c_entrada SYS_REFCURSOR;
        vn_count_new INTEGER := 0;

        TYPE cur_tab_entrada IS RECORD
        (
            proc_id NUMBER ( 30 )
          , cod_empresa VARCHAR2 ( 3 )
          , cod_estab VARCHAR2 ( 6 )
          , data_fiscal DATE
          , movto_e_s VARCHAR2 ( 1 )
          , norm_dev VARCHAR2 ( 1 )
          , ident_docto VARCHAR2 ( 12 )
          , ident_fis_jur VARCHAR2 ( 12 )
          , num_docfis VARCHAR2 ( 12 )
          , serie_docfis VARCHAR2 ( 3 )
          , sub_serie_docfis VARCHAR2 ( 2 )
          , discri_item VARCHAR2 ( 46 )
          , num_item NUMBER ( 5 )
          , cod_fis_jur VARCHAR2 ( 14 )
          , cpf_cgc VARCHAR2 ( 14 )
          , cod_nbm VARCHAR2 ( 10 )
          , cod_cfo VARCHAR2 ( 4 )
          , cod_natureza_op VARCHAR2 ( 3 )
          , cod_produto VARCHAR2 ( 35 )
          , vlr_contab_item NUMBER ( 17, 2 )
          , quantidade NUMBER ( 12, 4 )
          , vlr_unit NUMBER ( 17, 2 )
          , vlr_icmss_n_escrit NUMBER ( 17, 2 )
          , cod_situacao_b VARCHAR2 ( 2 )
          , data_emissao DATE
          , cod_estado VARCHAR2 ( 2 )
          , num_controle_docto VARCHAR2 ( 12 )
          , num_autentic_nfe VARCHAR2 ( 80 )
          , vlr_item NUMBER ( 17, 2 )
          , vlr_outras NUMBER ( 17, 2 )
          , vlr_desconto NUMBER ( 17, 2 )
          , cst_pis VARCHAR2 ( 2 )
          , vlr_base_pis NUMBER ( 17, 2 )
          , vlr_aliq_pis NUMBER ( 5, 2 )
          , vlr_pis NUMBER ( 17, 2 )
          , cst_cofins VARCHAR2 ( 2 )
          , vlr_base_cofins NUMBER ( 17, 2 )
          , vlr_aliq_cofins NUMBER ( 5, 2 )
          , vlr_cofins NUMBER ( 17, 2 )
          , vlr_base_icms NUMBER ( 17, 2 )
          , vlr_icms NUMBER ( 17, 2 )
          , vlr_base_icmss NUMBER ( 17, 2 )
          , vlr_icmss NUMBER ( 17, 2 )
        );

        TYPE c_tab_entrada IS TABLE OF cur_tab_entrada;

        tab_e c_tab_entrada;
        errors NUMBER;
        dml_errors EXCEPTION;

        qtd_busca INTEGER := 0;
    BEGIN
        dbms_application_info.set_client_info ( vp_cod_estab || '-' || vp_origem );

        qtd_busca := 0;

        FOR d IN ( SELECT     DISTINCT TRUNC (   TO_DATE ( vp_data_inicio
                                                         , 'ddmmyyyy' )
                                               + ( ROWNUM - 1 )
                                             , 'MM' )
                                           dt_inicial
                                     , LAST_DAY (   TO_DATE ( vp_data_inicio
                                                            , 'ddmmyyyy' )
                                                  + ( ROWNUM - 1 ) )
                                           dt_final
                         FROM DUAL
                   CONNECT BY ROWNUM <= (  TO_DATE ( vp_data_fim
                                                   , 'ddmmyyyy' )
                                         - TO_DATE ( vp_data_inicio
                                                   , 'ddmmyyyy' )
                                         + 1)
                     ORDER BY 1 DESC ) LOOP
            qtd_busca := qtd_busca + 1;

            v_sql := '';
            v_sql := v_sql || 'delete from ' || vp_tabela_prod_saida;

            EXECUTE IMMEDIATE ( v_sql );

            COMMIT;

            v_sql := '';
            v_sql := v_sql || 'insert into ' || vp_tabela_prod_saida;

            IF qtd_busca = 1 THEN
                v_sql :=
                       v_sql
                    || '     (SELECT  DISTINCT NULL, NULL, NULL, TMP.DATA_FISCAL AS DATA_FISCAL, TMP.COD_PRODUTO ';
            ELSE
                v_sql := v_sql || '     (SELECT DISTINCT NULL, NULL, NULL, null AS DATA_FISCAL, TMP.COD_PRODUTO ';
            END IF;

            v_sql := v_sql || '   FROM ' || vp_tabela_saida || ' TMP ';
            v_sql := v_sql || ' where 1=1 ';
            v_sql := v_sql || ' and not exists (select 1 from ' || vp_tabela_entrada || ' e where e.data_fiscal < ';
            v_sql := v_sql || ' trunc(to_date(''' || vp_data_fim || ''',''ddmmyyyy''),''MM'') ';
            v_sql := v_sql || ' and e.cod_produto = tmp.COD_PRODUTO ) ';
            v_sql := v_sql || '   and TMP.PROC_ID   = ''' || vp_proc_instance || ''' )  ';

            EXECUTE IMMEDIATE ( v_sql );

            vn_count_new := SQL%ROWCOUNT;


            IF vn_count_new > 0 THEN
                dbms_application_info.set_module (
                                                   'DPSP_CARTOES_CPROC'
                                                 ,    'Entrada CD Part['
                                                   || qtd_busca
                                                   || '] - '
                                                   || vp_cod_estab
                                                   || '-'
                                                   || vp_origem
                );

                dbms_stats.gather_table_stats ( 'MSAF'
                                              , vp_tabela_prod_saida );


                v_sql := '';
                v_sql := v_sql || 'SELECT  /* 2 */ DISTINCT ''' || vp_proc_instance || ''', ';
                v_sql := v_sql || ' A.COD_EMPRESA, ';
                v_sql := v_sql || ' A.COD_ESTAB, ';
                v_sql := v_sql || ' A.DATA_FISCAL, ';
                v_sql := v_sql || ' A.MOVTO_E_S, ';
                v_sql := v_sql || ' A.NORM_DEV, ';
                v_sql := v_sql || ' A.IDENT_DOCTO, ';
                v_sql := v_sql || ' A.IDENT_FIS_JUR, ';
                v_sql := v_sql || ' A.NUM_DOCFIS, ';
                v_sql := v_sql || ' A.SERIE_DOCFIS, ';
                v_sql := v_sql || ' A.SUB_SERIE_DOCFIS, ';
                v_sql := v_sql || ' A.DISCRI_ITEM, ';
                v_sql := v_sql || ' A.NUM_ITEM, ';
                v_sql := v_sql || ' A.COD_FIS_JUR, ';
                v_sql := v_sql || ' A.CPF_CGC, ';
                v_sql := v_sql || ' A.COD_NBM, ';
                v_sql := v_sql || ' A.COD_CFO, ';
                v_sql := v_sql || ' A.COD_NATUREZA_OP, ';
                v_sql := v_sql || ' A.COD_PRODUTO, ';
                v_sql := v_sql || ' A.VLR_CONTAB_ITEM, ';
                v_sql := v_sql || ' A.QUANTIDADE, ';
                v_sql := v_sql || ' A.VLR_UNIT, ';
                v_sql := v_sql || ' A.VLR_ICMSS_N_ESCRIT, ';
                v_sql := v_sql || ' A.COD_SITUACAO_B, ';
                v_sql := v_sql || ' A.DATA_EMISSAO, ';
                v_sql := v_sql || ' A.COD_ESTADO, ';
                v_sql := v_sql || ' A.NUM_CONTROLE_DOCTO, ';
                v_sql := v_sql || ' A.NUM_AUTENTIC_NFE ';

                v_sql := v_sql || ' , ';
                v_sql := v_sql || ' A.VLR_ITEM        , ';
                v_sql := v_sql || ' A.VLR_OUTRAS      , ';
                v_sql := v_sql || ' A.VLR_DESCONTO    , ';
                v_sql := v_sql || ' A.CST_PIS         , ';
                v_sql := v_sql || ' A.VLR_BASE_PIS    , ';
                v_sql := v_sql || ' A.VLR_ALIQ_PIS    , ';
                v_sql := v_sql || ' A.VLR_PIS         , ';
                v_sql := v_sql || ' A.CST_COFINS      , ';
                v_sql := v_sql || ' A.VLR_BASE_COFINS , ';
                v_sql := v_sql || ' A.VLR_ALIQ_COFINS , ';
                v_sql := v_sql || ' A.VLR_COFINS      , ';

                v_sql := v_sql || ' A.VLR_BASE_ICMS, ';
                v_sql := v_sql || ' A.VLR_ICMS, ';
                v_sql := v_sql || ' A.VLR_BASE_ICMSS, ';
                v_sql := v_sql || ' A.VLR_ICMSS ';

                v_sql := v_sql || ' FROM ( ';
                v_sql := v_sql || '   SELECT   ';
                v_sql := v_sql || ' NF.COD_EMPRESA, ';
                v_sql := v_sql || ' NF.COD_ESTAB, ';
                v_sql := v_sql || ' NF.DATA_FISCAL, ';
                v_sql := v_sql || ' NF.MOVTO_E_S, ';
                v_sql := v_sql || ' NF.NORM_DEV, ';
                v_sql := v_sql || ' NF.IDENT_DOCTO, ';
                v_sql := v_sql || ' NF.IDENT_FIS_JUR, ';
                v_sql := v_sql || ' NF.NUM_DOCFIS, ';
                v_sql := v_sql || ' NF.SERIE_DOCFIS, ';
                v_sql := v_sql || ' NF.SUB_SERIE_DOCFIS, ';
                v_sql := v_sql || ' NF.DISCRI_ITEM, ';
                v_sql := v_sql || ' NF.NUM_ITEM, ';
                v_sql := v_sql || ' NF.COD_FIS_JUR, ';
                v_sql := v_sql || ' NF.CPF_CGC,  ';
                v_sql := v_sql || ' NF.COD_NBM, ';
                v_sql := v_sql || ' NF.COD_CFO, ';
                v_sql := v_sql || ' NF.COD_NATUREZA_OP, ';
                v_sql := v_sql || ' NF.COD_PRODUTO, ';
                v_sql := v_sql || ' NF.VLR_CONTAB_ITEM, ';
                v_sql := v_sql || ' NF.QUANTIDADE, ';
                v_sql := v_sql || ' NF.VLR_UNIT, ';
                v_sql := v_sql || ' NF.VLR_ICMSS_N_ESCRIT, ';
                v_sql := v_sql || ' NF.COD_SITUACAO_B, ';
                v_sql := v_sql || ' NF.DATA_EMISSAO, ';
                v_sql := v_sql || ' NF.COD_ESTADO, ';
                v_sql := v_sql || ' NF.NUM_CONTROLE_DOCTO, ';
                v_sql := v_sql || ' NF.NUM_AUTENTIC_NFE, ';
                v_sql := v_sql || ' NF.VLR_BASE_ICMS, ';
                v_sql := v_sql || ' NF.VLR_ICMS, ';
                v_sql := v_sql || ' NF.VLR_BASE_ICMSS, ';
                v_sql := v_sql || ' NF.VLR_ICMSS, ';
                v_sql := v_sql || ' NF.VLR_ITEM        , ';
                v_sql := v_sql || ' NF.VLR_OUTRAS      , ';
                v_sql := v_sql || ' NF.VLR_DESCONTO    , ';
                v_sql := v_sql || ' NF.CST_PIS         , ';
                v_sql := v_sql || ' NF.VLR_BASE_PIS    , ';
                v_sql := v_sql || ' NF.VLR_ALIQ_PIS    , ';
                v_sql := v_sql || ' NF.VLR_PIS         , ';
                v_sql := v_sql || ' NF.CST_COFINS      , ';
                v_sql := v_sql || ' NF.VLR_BASE_COFINS , ';
                v_sql := v_sql || ' NF.VLR_ALIQ_COFINS , ';
                v_sql := v_sql || ' NF.VLR_COFINS      , ';
                v_sql := v_sql || '              RANK() OVER( ';
                v_sql :=
                       v_sql
                    || '                   PARTITION BY NF.COD_ESTAB, P.DATA_FISCAL, NF.COD_PRODUTO, SIGN(NF.VLR_ICMSS_N_ESCRIT) ';
                v_sql :=
                       v_sql
                    || '                   ORDER BY NF.DATA_FISCAL DESC, NF.DATA_EMISSAO DESC, NF.NUM_DOCFIS, NF.DISCRI_ITEM) RANK ';
                v_sql := v_sql || ' FROM MSAFI.DPSP_NF_ENTRADA partition for (TO_DATE(''';
                v_sql :=
                       v_sql
                    || TO_CHAR ( d.dt_final
                               , 'DD/MM/YYYY' )
                    || ''',''DD/MM/YYYY'') ) NF, ';
                v_sql := v_sql || '     (SELECT DISTINCT TMP.COD_PRODUTO, TMP.DATA_FISCAL AS DATA_FISCAL ';
                v_sql := v_sql || '              FROM ' || vp_tabela_prod_saida || ' TMP ';
                v_sql := v_sql || ' ) P ';
                v_sql := v_sql || ' WHERE 1=1 ';
                v_sql := v_sql || '  AND NF.NORM_DEV = ''1'' ';
                v_sql := v_sql || '  AND NF.SITUACAO = ''N'' ';
                v_sql := v_sql || '  AND NF.VLR_ITEM       <> 0 ';
                v_sql := v_sql || '  AND NF.COD_EMPRESA        = ''' || mcod_empresa || ''' ';
                v_sql := v_sql || '  AND NF.COD_ESTAB          = ''' || vp_cod_estab || ''' ';
                v_sql := v_sql || '  AND NF.COD_PRODUTO          = P.COD_PRODUTO ';

                IF qtd_busca = 1 THEN
                    v_sql := v_sql || '  AND NF.DATA_FISCAL        < P.DATA_FISCAL ';
                END IF;

                v_sql := v_sql || '  AND NF.DATA_FISCAL       >= to_date(''' || d.dt_inicial || ''',''DD/MM/YYYY'') '; --ULTIMOS 2 ANOS
                v_sql := v_sql || '  AND NF.DATA_FISCAL       <= to_date(''' || d.dt_final || ''',''DD/MM/YYYY'') '; --ULTIMOS 2 ANOS
                v_sql := v_sql || '       ) A ';
                v_sql := v_sql || ' WHERE A.RANK = 1 ';



                -- END IF;

                BEGIN
                    OPEN c_entrada FOR v_sql;
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
                                      , 3072 )
                             , FALSE );
                        raise_application_error ( -20004
                                                , '!ERRO SELECT ENTRADA ' || vp_origem );
                END;

                LOOP
                    FETCH c_entrada
                        BULK COLLECT INTO tab_e
                        LIMIT 100;

                    BEGIN
                        FORALL i IN tab_e.FIRST .. tab_e.LAST SAVE EXCEPTIONS
                            EXECUTE IMMEDIATE
                                   'INSERT /*+APPEND*/ INTO '
                                || vp_tabela_entrada
                                || ' VALUES (:1, :2, :3, :4, :5, :6, :7, :8, :9, '
                                || ' :10, :11, :12, :13, :14, :15, :16, :17, :18, :19, :20, :21, :22, :23, :24, :25, '
                                || ' :26, :27 '
                                || --', :28, :29, :30, :31, :32, :33, :34, :35, :36, :37, :38, :39, :40, :41, :42, :43 ' ||
                                   ' ) '
                                USING tab_e ( i ).proc_id
                                    , --
                                     tab_e ( i ).cod_empresa
                                    , --
                                     tab_e ( i ).cod_estab
                                    , --
                                     tab_e ( i ).data_fiscal
                                    , --
                                     tab_e ( i ).movto_e_s
                                    , --
                                     tab_e ( i ).norm_dev
                                    , --
                                     tab_e ( i ).ident_docto
                                    , --
                                     tab_e ( i ).ident_fis_jur
                                    , --
                                     tab_e ( i ).num_docfis
                                    , --
                                     tab_e ( i ).serie_docfis
                                    , --
                                     tab_e ( i ).sub_serie_docfis
                                    , --
                                     tab_e ( i ).discri_item
                                    , --
                                     tab_e ( i ).num_item
                                    , --
                                     tab_e ( i ).cod_fis_jur
                                    , --
                                     tab_e ( i ).cpf_cgc
                                    , --
                                     tab_e ( i ).cod_nbm
                                    , --
                                     tab_e ( i ).cod_cfo
                                    , --
                                     tab_e ( i ).cod_natureza_op
                                    , --
                                     tab_e ( i ).cod_produto
                                    , --
                                     tab_e ( i ).vlr_contab_item
                                    , --
                                     tab_e ( i ).quantidade
                                    , --
                                     tab_e ( i ).vlr_unit
                                    , --
                                      -- tab_e(i).vlr_icmss_n_escrit, --
                                      tab_e ( i ).cod_situacao_b
                                    , --
                                     tab_e ( i ).data_emissao
                                    , --
                                     tab_e ( i ).cod_estado
                                    , --
                                     tab_e ( i ).num_controle_docto
                                    , --
                                     tab_e ( i ).num_autentic_nfe --
                                                                 /*, tab_e(i)
                                                                .vlr_item, tab_e(i).vlr_outras,
                                                                 tab_e(i).vlr_desconto, tab_e(i)
                                                                .cst_pis, tab_e(i).vlr_base_pis,
                                                                 tab_e(i).vlr_aliq_pis, tab_e(i)
                                                                .vlr_pis, tab_e(i).cst_cofins,
                                                                 tab_e(i).vlr_base_cofins, tab_e(i)
                                                                .vlr_aliq_cofins, tab_e(i).vlr_cofins,
                                                                 tab_e(i).vlr_base_icms, tab_e(i)
                                                                .vlr_icms, tab_e(i).vlr_base_icmss,
                                                                 tab_e(i).vlr_icmss*/
                                                                 ;
                    EXCEPTION
                        WHEN OTHERS THEN
                            errors := SQL%BULK_EXCEPTIONS.COUNT;

                            FOR i IN 1 .. errors LOOP
                                loga ( 'ERRO #' || i || ' LINHA #' || SQL%BULK_EXCEPTIONS ( i ).ERROR_INDEX
                                     , FALSE );
                                loga ( 'MSG: ' || SQLERRM ( -SQL%BULK_EXCEPTIONS ( i ).ERROR_CODE )
                                     , FALSE );
                            END LOOP;

                            raise_application_error ( -20004
                                                    , '!ERRO INSERT ENTRADA ' || vp_origem );
                    END;

                    COMMIT;
                    tab_e.delete;

                    EXIT WHEN c_entrada%NOTFOUND;
                END LOOP;

                COMMIT;

                CLOSE c_entrada;
            END IF;
        END LOOP;

        loga ( 'LOAD_ENTRADA-FIM-' || vp_cod_estab || '-' || vp_origem
             , FALSE );
    END;

    PROCEDURE load_entradas ( pnr_particao INTEGER
                            , pnr_particao2 INTEGER
                            , vp_proc_instance IN VARCHAR2
                            , vp_origem IN VARCHAR2
                            , vp_cod_cd IN VARCHAR2
                            , vp_tabela_entrada IN VARCHAR2
                            , vp_tabela_saida IN VARCHAR2
                            , vp_data_inicio IN VARCHAR2
                            , vp_data_fim IN VARCHAR2
                            , vp_proc_id INTEGER
                            , pcod_empresa VARCHAR2
                            , pcod_estab VARCHAR2
                            , p_uf VARCHAR2
                            , pnm_usuario usuario_estab.cod_usuario%TYPE )
    IS
        vp_cod_estab VARCHAR2 ( 6 );
        v_sql VARCHAR2 ( 12000 );
        c_entrada SYS_REFCURSOR;
        vn_count_new INTEGER;

        TYPE cur_tab_entrada IS RECORD
        (
            proc_id NUMBER ( 30 )
          , cod_empresa VARCHAR2 ( 3 )
          , cod_estab VARCHAR2 ( 6 )
          , data_fiscal DATE
          , movto_e_s VARCHAR2 ( 1 )
          , norm_dev VARCHAR2 ( 1 )
          , ident_docto VARCHAR2 ( 12 )
          , ident_fis_jur VARCHAR2 ( 12 )
          , num_docfis VARCHAR2 ( 12 )
          , serie_docfis VARCHAR2 ( 3 )
          , sub_serie_docfis VARCHAR2 ( 2 )
          , discri_item VARCHAR2 ( 46 )
          , num_item NUMBER ( 5 )
          , cod_fis_jur VARCHAR2 ( 14 )
          , cpf_cgc VARCHAR2 ( 14 )
          , cod_nbm VARCHAR2 ( 10 )
          , cod_cfo VARCHAR2 ( 4 )
          , cod_natureza_op VARCHAR2 ( 3 )
          , cod_produto VARCHAR2 ( 35 )
          , vlr_contab_item NUMBER ( 17, 2 )
          , quantidade NUMBER ( 12, 4 )
          , vlr_unit NUMBER ( 17, 2 )
          , vlr_icmss_n_escrit NUMBER ( 17, 2 )
          , cod_situacao_b VARCHAR2 ( 2 )
          , data_emissao DATE
          , cod_estado VARCHAR2 ( 2 )
          , num_controle_docto VARCHAR2 ( 12 )
          , num_autentic_nfe VARCHAR2 ( 80 )
          , vlr_item NUMBER ( 17, 2 )
          , vlr_outras NUMBER ( 17, 2 )
          , vlr_desconto NUMBER ( 17, 2 )
          , cst_pis VARCHAR2 ( 2 )
          , vlr_base_pis NUMBER ( 17, 2 )
          , vlr_aliq_pis NUMBER ( 5, 2 )
          , vlr_pis NUMBER ( 17, 2 )
          , cst_cofins VARCHAR2 ( 2 )
          , vlr_base_cofins NUMBER ( 17, 2 )
          , vlr_aliq_cofins NUMBER ( 5, 2 )
          , vlr_cofins NUMBER ( 17, 2 )
          , vlr_base_icms NUMBER ( 17, 2 )
          , vlr_icms NUMBER ( 17, 2 )
          , vlr_base_icmss NUMBER ( 17, 2 )
          , vlr_icmss NUMBER ( 17, 2 )
          , data_fiscal_saida DATE
        );

        TYPE c_tab_entrada IS TABLE OF cur_tab_entrada;

        tab_e c_tab_entrada;
        errors NUMBER;
        dml_errors EXCEPTION;

        qtd_busca INTEGER := 0;

        vp_tabela_prod_saida VARCHAR2 ( 30 );
    BEGIN
        lib_proc.set_mproc_id ( vp_proc_id );

        lib_parametros.salvar ( 'EMPRESA'
                              , pcod_empresa );

        mcod_empresa := pcod_empresa;

        create_tab_prod_saida ( vp_proc_instance
                              , vp_tabela_prod_saida
                              , pnr_particao || '_' );
        save_tmp_control ( vp_proc_instance
                         , vp_tabela_prod_saida );

        create_tab_prod_saida_idx ( vp_proc_instance
                                  , vp_tabela_prod_saida
                                  , pnr_particao || '_' );


        vp_cod_estab := pcod_estab;

        qtd_busca := 0;

        FOR d IN ( SELECT     DISTINCT TRUNC (   TO_DATE ( vp_data_inicio
                                                         , 'ddmmyyyy' )
                                               + ( ROWNUM - 1 )
                                             , 'MM' )
                                           dt_inicial
                                     , LAST_DAY (   TO_DATE ( vp_data_inicio
                                                            , 'ddmmyyyy' )
                                                  + ( ROWNUM - 1 ) )
                                           dt_final
                         FROM DUAL
                   CONNECT BY ROWNUM <= (  TO_DATE ( vp_data_fim
                                                   , 'ddmmyyyy' )
                                         - TO_DATE ( vp_data_inicio
                                                   , 'ddmmyyyy' )
                                         + 1)
                     ORDER BY 1 DESC ) LOOP
            qtd_busca := qtd_busca + 1;

            v_sql := '';
            v_sql := v_sql || 'delete from ' || vp_tabela_prod_saida;

            EXECUTE IMMEDIATE ( v_sql );

            COMMIT;

            v_sql := '';
            v_sql := v_sql || 'insert into ' || vp_tabela_prod_saida;

            IF qtd_busca = 1 THEN
                v_sql :=
                    v_sql || '     (SELECT DISTINCT NULL, NULL, NULL, TMP.DATA_FISCAL AS DATA_FISCAL, TMP.COD_PRODUTO ';
            ELSE
                v_sql := v_sql || '     (SELECT DISTINCT NULL, NULL, NULL, null AS DATA_FISCAL, TMP.COD_PRODUTO ';
            END IF;

            v_sql := v_sql || '   FROM ' || vp_tabela_saida || ' TMP ';
            v_sql := v_sql || ' where 1=1 ';
            v_sql := v_sql || ' and TMP.DESCR_TOT = ''ST'' ';
            v_sql := v_sql || ' and not exists (select 1 from ' || vp_tabela_entrada || ' e where e.data_fiscal < ';
            v_sql := v_sql || ' trunc(to_date(''' || vp_data_fim || ''',''ddmmyyyy''),''MM'') ';
            v_sql := v_sql || ' AND E.COD_ESTAB = ''' || vp_cod_estab || '''';

            IF vp_cod_cd IS NOT NULL THEN
                v_sql := v_sql || ' AND E.cod_fis_jur = ''' || vp_cod_cd || '''';
            END IF;

            v_sql := v_sql || ' and e.cod_produto = tmp.COD_PRODUTO ) ';
            v_sql := v_sql || '   and TMP.PROC_ID   = ''' || vp_proc_instance || ''' )  ';

            EXECUTE IMMEDIATE ( v_sql );

            vn_count_new := SQL%ROWCOUNT;


            IF vn_count_new > 0 THEN
                dbms_application_info.set_module (
                                                   'DPSP_CARTOES_CPROC'
                                                 ,    'Entrada CD Part['
                                                   || qtd_busca
                                                   || '] - '
                                                   || vp_cod_estab
                                                   || '-'
                                                   || vp_origem
                );

                dbms_stats.gather_table_stats ( 'MSAF'
                                              , vp_tabela_prod_saida );

                IF ( vp_origem = 'F' ) THEN
                    v_sql := '';
                    v_sql := v_sql || 'SELECT  /* 3 */ DISTINCT ''' || vp_proc_instance || ''', ';
                    v_sql := v_sql || ' A.COD_EMPRESA, ';
                    v_sql := v_sql || ' A.COD_ESTAB, ';
                    v_sql := v_sql || ' A.DATA_FISCAL, ';
                    v_sql := v_sql || ' A.MOVTO_E_S, ';
                    v_sql := v_sql || ' A.NORM_DEV, ';
                    v_sql := v_sql || ' A.IDENT_DOCTO, ';
                    v_sql := v_sql || ' A.IDENT_FIS_JUR, ';
                    v_sql := v_sql || ' A.NUM_DOCFIS, ';
                    v_sql := v_sql || ' A.SERIE_DOCFIS, ';
                    v_sql := v_sql || ' A.SUB_SERIE_DOCFIS, ';
                    v_sql := v_sql || ' A.DISCRI_ITEM, ';
                    v_sql := v_sql || ' A.NUM_ITEM, ';
                    v_sql := v_sql || ' A.COD_FIS_JUR, ';
                    v_sql := v_sql || ' A.CPF_CGC, ';
                    v_sql := v_sql || ' A.COD_NBM, ';
                    v_sql := v_sql || ' A.COD_CFO, ';
                    v_sql := v_sql || ' A.COD_NATUREZA_OP, ';
                    v_sql := v_sql || ' A.COD_PRODUTO, ';
                    v_sql := v_sql || ' A.VLR_CONTAB_ITEM, ';
                    v_sql := v_sql || ' A.QUANTIDADE, ';
                    v_sql := v_sql || ' A.VLR_UNIT, ';
                    v_sql := v_sql || ' A.VLR_ICMSS_N_ESCRIT, ';
                    v_sql := v_sql || ' A.COD_SITUACAO_B, ';
                    v_sql := v_sql || ' A.DATA_EMISSAO, ';
                    v_sql := v_sql || ' A.COD_ESTADO, ';
                    v_sql := v_sql || ' A.NUM_CONTROLE_DOCTO, ';
                    v_sql := v_sql || ' A.NUM_AUTENTIC_NFE ';
                    v_sql := v_sql || ' , ';
                    v_sql := v_sql || ' A.VLR_ITEM        , ';
                    v_sql := v_sql || ' A.VLR_OUTRAS      , ';
                    v_sql := v_sql || ' A.VLR_DESCONTO    , ';
                    v_sql := v_sql || ' A.CST_PIS         , ';
                    v_sql := v_sql || ' A.VLR_BASE_PIS    , ';
                    v_sql := v_sql || ' A.VLR_ALIQ_PIS    , ';
                    v_sql := v_sql || ' A.VLR_PIS         , ';
                    v_sql := v_sql || ' A.CST_COFINS      , ';
                    v_sql := v_sql || ' A.VLR_BASE_COFINS , ';
                    v_sql := v_sql || ' A.VLR_ALIQ_COFINS , ';
                    v_sql := v_sql || ' A.VLR_COFINS      , ';

                    v_sql := v_sql || ' A.VLR_BASE_ICMS, ';
                    v_sql := v_sql || ' A.VLR_ICMS, ';
                    v_sql := v_sql || ' A.VLR_BASE_ICMSS, ';
                    v_sql := v_sql || ' A.VLR_ICMSS ';
                    v_sql := v_sql || ', A.DATA_FISCAL_SAIDA';
                    v_sql := v_sql || ' FROM ( ';
                    v_sql := v_sql || '     SELECT    ';
                    v_sql := v_sql || '              DISTINCT NF.COD_EMPRESA, ';
                    v_sql := v_sql || '               NF.COD_ESTAB, ';
                    v_sql := v_sql || '               NF.DATA_FISCAL, ';
                    v_sql := v_sql || '               NF.MOVTO_E_S, ';
                    v_sql := v_sql || '               NF.NORM_DEV, ';
                    v_sql := v_sql || '               NF.IDENT_DOCTO, ';
                    v_sql := v_sql || '               NF.IDENT_FIS_JUR, ';
                    v_sql := v_sql || '               NF.NUM_DOCFIS, ';
                    v_sql := v_sql || '               NF.SERIE_DOCFIS, ';
                    v_sql := v_sql || '               NF.SUB_SERIE_DOCFIS, ';
                    v_sql := v_sql || '               NF.DISCRI_ITEM, ';
                    v_sql := v_sql || '               NF.NUM_ITEM, ';
                    v_sql := v_sql || '               NF.COD_FIS_JUR, ';
                    v_sql := v_sql || '               NF.CPF_CGC, ';
                    v_sql := v_sql || '               NF.COD_NBM, ';
                    v_sql := v_sql || '               NF.COD_CFO, ';
                    v_sql := v_sql || '               NF.COD_NATUREZA_OP, ';
                    v_sql := v_sql || '               NF.COD_PRODUTO, ';
                    v_sql := v_sql || '               NF.VLR_CONTAB_ITEM, ';
                    v_sql := v_sql || '               NF.QUANTIDADE, ';
                    v_sql := v_sql || '               NF.VLR_UNIT, ';
                    v_sql := v_sql || '               NF.VLR_ICMSS_N_ESCRIT, ';
                    v_sql := v_sql || '               NF.COD_SITUACAO_B, ';
                    v_sql := v_sql || '               NF.DATA_EMISSAO, ';
                    v_sql := v_sql || '               NF.COD_ESTADO, ';
                    v_sql := v_sql || '               NF.NUM_CONTROLE_DOCTO, ';
                    v_sql := v_sql || '               NF.NUM_AUTENTIC_NFE ';
                    v_sql := v_sql || '               , ';
                    v_sql := v_sql || '               NF.VLR_BASE_ICMS, ';
                    v_sql := v_sql || '               NF.VLR_ICMS, ';
                    v_sql := v_sql || '               NF.VLR_BASE_ICMSS, ';
                    v_sql := v_sql || '               NF.VLR_ICMSS, ';
                    v_sql := v_sql || ' NF.VLR_ITEM        , ';
                    v_sql := v_sql || ' NF.VLR_OUTRAS      , ';
                    v_sql := v_sql || ' NF.VLR_DESCONTO    , ';
                    v_sql := v_sql || ' NF.CST_PIS         , ';
                    v_sql := v_sql || ' NF.VLR_BASE_PIS    , ';
                    v_sql := v_sql || ' NF.VLR_ALIQ_PIS    , ';
                    v_sql := v_sql || ' NF.VLR_PIS         , ';
                    v_sql := v_sql || ' NF.CST_COFINS      , ';
                    v_sql := v_sql || ' NF.VLR_BASE_COFINS , ';
                    v_sql := v_sql || ' NF.VLR_ALIQ_COFINS , ';
                    v_sql := v_sql || ' NF.VLR_COFINS      , ';
                    v_sql := v_sql || ' P.DATA_FISCAL  DATA_FISCAL_SAIDA     ';
                    v_sql := v_sql || '        FROM  ';
                    v_sql := v_sql || '     (SELECT DISTINCT TMP.COD_PRODUTO, TMP.DATA_FISCAL AS DATA_FISCAL ';
                    v_sql := v_sql || '              FROM ' || vp_tabela_prod_saida || ' TMP ';
                    v_sql := v_sql || ' ) P, ';
                    v_sql := v_sql || '  MSAFI.DPSP_NF_ENTRADA partition for (TO_DATE(''';
                    v_sql :=
                           v_sql
                        || TO_CHAR ( d.dt_final
                                   , 'DD/MM/YYYY' )
                        || ''',''DD/MM/YYYY'') ) NF ';
                    v_sql := v_sql || '        WHERE 1=1 ';
                    v_sql := v_sql || '          AND NF.COD_EMPRESA        = ''' || mcod_empresa || ''' ';
                    v_sql := v_sql || '          AND NF.COD_ESTAB          = ''' || vp_cod_estab || ''' ';
                    v_sql := v_sql || '  AND NF.NORM_DEV = ''1'' ';
                    v_sql := v_sql || '  AND NF.SITUACAO = ''N'' ';
                    v_sql := v_sql || '  AND NF.VLR_ITEM  <> 0 ';
                    v_sql := v_sql || '  AND NF.cod_fis_jur     = ''' || vp_cod_cd || '''';
                    v_sql := v_sql || '  AND NF.COD_PRODUTO        = P.COD_PRODUTO ';

                    IF qtd_busca = 1 THEN
                        v_sql := v_sql || '  AND NF.DATA_FISCAL        < P.DATA_FISCAL ';
                    END IF;

                    v_sql :=
                           v_sql
                        || '  AND NF.DATA_FISCAL       >= to_date('''
                        || TO_CHAR ( d.dt_inicial
                                   , 'ddmmyyyy' )
                        || ''',''ddmmyyyy'') '; --ULTIMOS 2 ANOS
                    v_sql :=
                           v_sql
                        || '  AND NF.DATA_FISCAL       <= to_date('''
                        || TO_CHAR ( d.dt_final
                                   , 'ddmmyyyy' )
                        || ''',''ddmmyyyy'') '; --ULTIMOS 2 ANOS
                    v_sql := v_sql || '       ) A ';
                ELSIF ( vp_origem = 'CO' ) THEN
                    --COMPRA DIRETA

                    /*       v_sql := '';
                            v_sql := v_sql || 'SELECT DISTINCT ''' || vp_proc_instance ||
                                     ''', ';
                            v_sql := v_sql || ' A.COD_EMPRESA, ';
                            v_sql := v_sql || ' A.COD_ESTAB, ';
                            v_sql := v_sql || ' A.DATA_FISCAL, ';
                            v_sql := v_sql || ' A.MOVTO_E_S, ';
                            v_sql := v_sql || ' A.NORM_DEV, ';
                            v_sql := v_sql || ' A.IDENT_DOCTO, ';
                            v_sql := v_sql || ' A.IDENT_FIS_JUR, ';
                            v_sql := v_sql || ' A.NUM_DOCFIS, ';
                            v_sql := v_sql || ' A.SERIE_DOCFIS, ';
                            v_sql := v_sql || ' A.SUB_SERIE_DOCFIS, ';
                            v_sql := v_sql || ' A.DISCRI_ITEM, ';
                            v_sql := v_sql || ' A.NUM_ITEM, ';
                            v_sql := v_sql || ' A.COD_FIS_JUR, ';
                            v_sql := v_sql || ' A.CPF_CGC, ';
                            v_sql := v_sql || ' A.COD_NBM, ';
                            v_sql := v_sql || ' A.COD_CFO, ';
                            v_sql := v_sql || ' A.COD_NATUREZA_OP, ';
                            v_sql := v_sql || ' A.COD_PRODUTO, ';
                            v_sql := v_sql || ' A.VLR_CONTAB_ITEM, ';
                            v_sql := v_sql || ' A.QUANTIDADE, ';
                            v_sql := v_sql || ' A.VLR_UNIT, ';
                            v_sql := v_sql || ' A.VLR_ICMSS_N_ESCRIT, ';
                            v_sql := v_sql || ' A.COD_SITUACAO_B, ';
                            v_sql := v_sql || ' A.DATA_EMISSAO, ';
                            v_sql := v_sql || ' A.COD_ESTADO, ';
                            v_sql := v_sql || ' A.NUM_CONTROLE_DOCTO, ';
                            v_sql := v_sql || ' A.NUM_AUTENTIC_NFE, ';

                            v_sql := v_sql || ' A.VLR_ITEM        , ';
                            v_sql := v_sql || ' A.VLR_OUTRAS      , ';
                            v_sql := v_sql || ' A.VLR_DESCONTO    , ';
                            v_sql := v_sql || ' A.CST_PIS         , ';
                            v_sql := v_sql || ' A.VLR_BASE_PIS    , ';
                            v_sql := v_sql || ' A.VLR_ALIQ_PIS    , ';
                            v_sql := v_sql || ' A.VLR_PIS         , ';
                            v_sql := v_sql || ' A.CST_COFINS      , ';
                            v_sql := v_sql || ' A.VLR_BASE_COFINS , ';
                            v_sql := v_sql || ' A.VLR_ALIQ_COFINS , ';
                            v_sql := v_sql || ' A.VLR_COFINS      , ';

                            v_sql := v_sql || ' A.VLR_BASE_ICMS, ';
                            v_sql := v_sql || ' A.VLR_ICMS, ';
                            v_sql := v_sql || ' A.VLR_BASE_ICMSS, ';
                            v_sql := v_sql || ' A.VLR_ICMSS ';
                            v_sql := v_sql || ', A.DATA_FISCAL_SAIDA ';
                            v_sql := v_sql || ' FROM ( ';
                            v_sql := v_sql ||
                           --          '     SELECT  \*+INDEX(D PK_X2013_PRODUTO) INDEX(A PK_X2043_COD_NBM) INDEX(G PK_X04_PESSOA_FIS_JUR) *\ ';
                                     '     SELECT    ';
                            v_sql := v_sql || '               X08.COD_EMPRESA, ';
                            v_sql := v_sql || '               X08.COD_ESTAB, ';
                            v_sql := v_sql || '               X08.DATA_FISCAL, ';
                            v_sql := v_sql || '               X08.MOVTO_E_S, ';
                            v_sql := v_sql || '               X08.NORM_DEV, ';
                            v_sql := v_sql || '               X08.IDENT_DOCTO, ';
                            v_sql := v_sql || '               X08.IDENT_FIS_JUR, ';
                            v_sql := v_sql || '               X08.NUM_DOCFIS, ';
                            v_sql := v_sql || '               X08.SERIE_DOCFIS, ';
                            v_sql := v_sql || '               X08.SUB_SERIE_DOCFIS, ';
                            v_sql := v_sql || '               X08.DISCRI_ITEM, ';
                            v_sql := v_sql || '               X08.NUM_ITEM, ';
                            v_sql := v_sql || '               G.COD_FIS_JUR, ';
                            v_sql := v_sql || '               G.CPF_CGC, ';
                            v_sql := v_sql || '               A.COD_NBM, ';
                            v_sql := v_sql || '               B.COD_CFO, ';
                            v_sql := v_sql || '               C.COD_NATUREZA_OP, ';
                            v_sql := v_sql || '               D.COD_PRODUTO, ';
                            v_sql := v_sql || '               X08.VLR_CONTAB_ITEM, ';
                            v_sql := v_sql || '               X08.QUANTIDADE, ';
                            v_sql := v_sql || '               X08.VLR_UNIT, ';
                            v_sql := v_sql || '               X08.VLR_ICMSS_N_ESCRIT, ';
                            v_sql := v_sql || '               E.COD_SITUACAO_B, ';
                            v_sql := v_sql || '               X07.DATA_EMISSAO, ';
                            v_sql := v_sql || '               H.COD_ESTADO, ';
                            v_sql := v_sql || '               X07.NUM_CONTROLE_DOCTO, ';
                            v_sql := v_sql ||
                                     '       '''' || X07.NUM_AUTENTIC_NFE AS NUM_AUTENTIC_NFE, ';
                            v_sql := v_sql || 'NVL((SELECT VLR_BASE ';
                            v_sql := v_sql || '          FROM X08_BASE_MERC IT ';
                            v_sql := v_sql ||
                                     '         WHERE X08.COD_EMPRESA = IT.COD_EMPRESA ';
                            v_sql := v_sql || '             AND X08.COD_ESTAB = IT.COD_ESTAB ';
                            v_sql := v_sql ||
                                     '             AND X08.DATA_FISCAL = IT.DATA_FISCAL ';
                            v_sql := v_sql || '             AND X08.MOVTO_E_S = IT.MOVTO_E_S ';
                            v_sql := v_sql || '             AND X08.NORM_DEV = IT.NORM_DEV ';
                            v_sql := v_sql ||
                                     '             AND X08.IDENT_DOCTO = IT.IDENT_DOCTO ';
                            v_sql := v_sql ||
                                     '             AND X08.IDENT_FIS_JUR = IT.IDENT_FIS_JUR ';
                            v_sql := v_sql ||
                                     '             AND X08.NUM_DOCFIS = IT.NUM_DOCFIS ';
                            v_sql := v_sql ||
                                     '             AND X08.SERIE_DOCFIS = IT.SERIE_DOCFIS ';
                            v_sql := v_sql ||
                                     '             AND X08.SUB_SERIE_DOCFIS = IT.SUB_SERIE_DOCFIS ';
                            v_sql := v_sql ||
                                     '             AND X08.DISCRI_ITEM = IT.DISCRI_ITEM ';
                            v_sql := v_sql || '             AND IT.COD_TRIBUTO = ''ICMS'' ';
                            v_sql := v_sql || '             AND IT.COD_TRIBUTACAO = ''1''), ';
                            v_sql := v_sql || '      0) VLR_BASE_ICMS, ';
                            v_sql := v_sql || ' (SELECT VLR_TRIBUTO ';
                            v_sql := v_sql || '     FROM X08_TRIB_MERC IT ';
                            v_sql := v_sql || '  WHERE X08.COD_EMPRESA = IT.COD_EMPRESA ';
                            v_sql := v_sql || '      AND X08.COD_ESTAB = IT.COD_ESTAB ';
                            v_sql := v_sql || '      AND X08.DATA_FISCAL = IT.DATA_FISCAL ';
                            v_sql := v_sql || '      AND X08.MOVTO_E_S = IT.MOVTO_E_S ';
                            v_sql := v_sql || '      AND X08.NORM_DEV = IT.NORM_DEV ';
                            v_sql := v_sql || '      AND X08.IDENT_DOCTO = IT.IDENT_DOCTO ';
                            v_sql := v_sql || '      AND X08.IDENT_FIS_JUR = IT.IDENT_FIS_JUR ';
                            v_sql := v_sql || '      AND X08.NUM_DOCFIS = IT.NUM_DOCFIS ';
                            v_sql := v_sql || '      AND X08.SERIE_DOCFIS = IT.SERIE_DOCFIS ';
                            v_sql := v_sql ||
                                     '      AND X08.SUB_SERIE_DOCFIS = IT.SUB_SERIE_DOCFIS ';
                            v_sql := v_sql || '      AND X08.DISCRI_ITEM = IT.DISCRI_ITEM ';
                            v_sql := v_sql || '      AND IT.COD_TRIBUTO = ''ICMS'') VLR_ICMS, ';
                            v_sql := v_sql || 'NVL((SELECT VLR_BASE ';
                            v_sql := v_sql || '          FROM X08_BASE_MERC IT ';
                            v_sql := v_sql ||
                                     '         WHERE X08.COD_EMPRESA = IT.COD_EMPRESA ';
                            v_sql := v_sql || '             AND X08.COD_ESTAB = IT.COD_ESTAB ';
                            v_sql := v_sql ||
                                     '             AND X08.DATA_FISCAL = IT.DATA_FISCAL ';
                            v_sql := v_sql || '             AND X08.MOVTO_E_S = IT.MOVTO_E_S ';
                            v_sql := v_sql || '             AND X08.NORM_DEV = IT.NORM_DEV ';
                            v_sql := v_sql ||
                                     '             AND X08.IDENT_DOCTO = IT.IDENT_DOCTO ';
                            v_sql := v_sql ||
                                     '             AND X08.IDENT_FIS_JUR = IT.IDENT_FIS_JUR ';
                            v_sql := v_sql ||
                                     '             AND X08.NUM_DOCFIS = IT.NUM_DOCFIS ';
                            v_sql := v_sql ||
                                     '             AND X08.SERIE_DOCFIS = IT.SERIE_DOCFIS ';
                            v_sql := v_sql ||
                                     '             AND X08.SUB_SERIE_DOCFIS = IT.SUB_SERIE_DOCFIS ';
                            v_sql := v_sql ||
                                     '             AND X08.DISCRI_ITEM = IT.DISCRI_ITEM ';
                            v_sql := v_sql || '             AND IT.COD_TRIBUTO = ''ICMS-S'' ';
                            v_sql := v_sql || '             AND IT.COD_TRIBUTACAO = ''1''), ';
                            v_sql := v_sql || '      0) VLR_BASE_ICMSS, ';
                            v_sql := v_sql || ' (SELECT VLR_TRIBUTO ';
                            v_sql := v_sql || '     FROM X08_TRIB_MERC IT ';
                            v_sql := v_sql || '  WHERE X08.COD_EMPRESA = IT.COD_EMPRESA ';
                            v_sql := v_sql || '      AND X08.COD_ESTAB = IT.COD_ESTAB ';
                            v_sql := v_sql || '      AND X08.DATA_FISCAL = IT.DATA_FISCAL ';
                            v_sql := v_sql || '      AND X08.MOVTO_E_S = IT.MOVTO_E_S ';
                            v_sql := v_sql || '      AND X08.NORM_DEV = IT.NORM_DEV ';
                            v_sql := v_sql || '      AND X08.IDENT_DOCTO = IT.IDENT_DOCTO ';
                            v_sql := v_sql || '      AND X08.IDENT_FIS_JUR = IT.IDENT_FIS_JUR ';
                            v_sql := v_sql || '      AND X08.NUM_DOCFIS = IT.NUM_DOCFIS ';
                            v_sql := v_sql || '      AND X08.SERIE_DOCFIS = IT.SERIE_DOCFIS ';
                            v_sql := v_sql ||
                                     '      AND X08.SUB_SERIE_DOCFIS = IT.SUB_SERIE_DOCFIS ';
                            v_sql := v_sql || '      AND X08.DISCRI_ITEM = IT.DISCRI_ITEM ';
                            v_sql := v_sql ||
                                     '      AND IT.COD_TRIBUTO = ''ICMS-S'') VLR_ICMSS, ';

                            v_sql := v_sql || ' X08.VLR_ITEM        , ';
                            v_sql := v_sql || ' X08.VLR_OUTRAS      , ';
                            v_sql := v_sql || ' X08.VLR_DESCONTO    , ';
                            v_sql := v_sql || ' X08.COD_SITUACAO_PIS CST_PIS         , ';
                            v_sql := v_sql || ' X08.VLR_BASE_PIS    , ';
                            v_sql := v_sql || ' X08.VLR_ALIQ_PIS    , ';
                            v_sql := v_sql || ' X08.VLR_PIS         , ';
                            v_sql := v_sql || ' X08.COD_SITUACAO_COFINS CST_COFINS      , ';
                            v_sql := v_sql || ' X08.VLR_BASE_COFINS , ';
                            v_sql := v_sql || ' X08.VLR_ALIQ_COFINS , ';
                            v_sql := v_sql || ' X08.VLR_COFINS      , ';
                            v_sql := v_sql || ' P.DATA_FISCAL   DATA_FISCAL_SAIDA    ';

                    --        v_sql := v_sql || '               RANK() OVER( ';
                    --        v_sql := v_sql ||
                    --                 '            PARTITION BY X08.COD_ESTAB, D.COD_PRODUTO, P.DATA_FISCAL, G.COD_FIS_JUR ';
                    --        v_sql := v_sql ||
                    --                 '            ORDER BY X08.DATA_FISCAL DESC, X07.DATA_EMISSAO DESC, X08.NUM_DOCFIS, X08.DISCRI_ITEM) RANK ';
                            v_sql := v_sql || '        FROM  ';


                          v_sql := v_sql ||
                                   '     (SELECT DISTINCT TMP.COD_PRODUTO, TMP.DATA_FISCAL AS DATA_FISCAL ';
                          v_sql := v_sql || '              FROM ' || vp_tabela_prod_saida || ' TMP ';
                    --      v_sql := v_sql || '              WHERE TMP.PROC_ID   = ''' ||
                    --               vp_proc_instance || '''';
                          v_sql := v_sql || ' ) P, ';



                    --        v_sql := v_sql ||
                    --                 '     (SELECT DISTINCT tmp_p.IDENT_PRODUTO,TMP.COD_PRODUTO, TMP.DATA_FISCAL AS DATA_FISCAL ';
                    --        v_sql := v_sql || '              FROM ' || vp_tabela_saida ||
                    --                 ' TMP, X2013_PRODUTO tmp_p where tmp.cod_produto = tmp_p.cod_produto ';
                    --        v_sql := v_sql || '              and TMP.PROC_ID   = ''' ||
                    --                 vp_proc_instance || ''' ) P, ';

                            v_sql := v_sql || ' MSAF.X08_ITENS_MERC partition for (TO_DATE(''' ||
                                     to_char(D.DT_FINAL,'DD/MM/YYYY') || ''',''DD/MM/YYYY'') )X08, ';
                            v_sql := v_sql || ' MSAF.X07_DOCTO_FISCAL  partition  for (TO_DATE(''' ||
                                     to_char(D.DT_FINAL,'DD/MM/YYYY') || ''',''DD/MM/YYYY'') )X07, ';


                    --        v_sql := v_sql || '         X08_ITENS_MERC partition for (to_date(''' ||
                    --                 --vp_data_fim
                    --                 to_char(D.DT_FINAL,'ddmmyyyy')
                    --                 || ''',''ddmmyyyy'') ) X08, ';
                    --        v_sql := v_sql || '             X07_DOCTO_FISCAL partition  for (to_date(''' ||
                    --                 --vp_data_fim
                    --                 to_char(D.DT_FINAL,'ddmmyyyy')
                    --                 || ''',''ddmmyyyy'') ) X07, ';

                            v_sql := v_sql || '             X2013_PRODUTO D, ';
                            v_sql := v_sql || '             X04_PESSOA_FIS_JUR G, ';
                            v_sql := v_sql || '             X2043_COD_NBM A, ';
                            v_sql := v_sql || '             X2012_COD_FISCAL B, ';
                            v_sql := v_sql || '             X2006_NATUREZA_OP C, ';
                            v_sql := v_sql || '             Y2026_SIT_TRB_UF_B E, ';
                            v_sql := v_sql || '             ESTADO H  ';
                            v_sql := v_sql || '        WHERE X07.MOVTO_E_S         <> ''9'' ';
                            v_sql := v_sql || '          AND X07.NORM_DEV           = ''1'' ';
                            v_sql := v_sql || '          AND X07.COD_EMPRESA        = ''' ||
                                     mcod_empresa || ''' ';
                            v_sql := v_sql || '          AND X07.COD_ESTAB          = ''' ||
                                     vp_cod_estab || ''' ';

                            v_sql := v_sql ||
                                     '          AND B.COD_CFO IN (''1102'',''2102'',''1403'',''2403'',''1910'',''2910'') ';
                            IF (mcod_empresa = 'DSP')
                            THEN
                              v_sql := v_sql || '      AND G.CPF_CGC NOT LIKE ''61412110%'' '; --DSP
                            ELSE
                              v_sql := v_sql || '      AND G.CPF_CGC NOT LIKE ''334382500%'' '; --DP
                            END IF;
                            v_sql := v_sql ||
                                     '          AND X07.NUM_CONTROLE_DOCTO  NOT LIKE ''C%'' ';

                            v_sql := v_sql || '  AND X08.IDENT_NBM          = A.IDENT_NBM ';
                            v_sql := v_sql || '  AND X08.IDENT_CFO          = B.IDENT_CFO ';
                            v_sql := v_sql ||
                                     '  AND X08.IDENT_NATUREZA_OP  = C.IDENT_NATUREZA_OP ';
                            v_sql := v_sql ||
                                     '  AND X08.IDENT_SITUACAO_B   = E.IDENT_SITUACAO_B ';
                            v_sql := v_sql || '          AND X07.VLR_PRODUTO       <> 0 ';
                            v_sql := v_sql || '  AND D.IDENT_PRODUTO      = X08.IDENT_PRODUTO ';
                            v_sql := v_sql || '  AND X07.IDENT_FIS_JUR    = G.IDENT_FIS_JUR  ';
                            v_sql := v_sql || '  AND G.IDENT_ESTADO       = H.IDENT_ESTADO ';
                            ---
                            v_sql := v_sql || '  AND X07.COD_EMPRESA      = X08.COD_EMPRESA ';
                            v_sql := v_sql || '  AND X07.COD_ESTAB        = X08.COD_ESTAB ';
                            v_sql := v_sql || '  AND X07.DATA_FISCAL      = X08.DATA_FISCAL ';
                            v_sql := v_sql || '  AND X07.MOVTO_E_S        = X08.MOVTO_E_S ';
                            v_sql := v_sql || '  AND X07.NORM_DEV         = X08.NORM_DEV ';
                            v_sql := v_sql || '  AND X07.IDENT_DOCTO      = X08.IDENT_DOCTO ';
                            v_sql := v_sql || '  AND X07.IDENT_FIS_JUR    = X08.IDENT_FIS_JUR ';
                            v_sql := v_sql || '  AND X07.NUM_DOCFIS       = X08.NUM_DOCFIS ';
                            v_sql := v_sql || '  AND X07.SERIE_DOCFIS     = X08.SERIE_DOCFIS ';
                            v_sql := v_sql ||
                                     '  AND X07.SUB_SERIE_DOCFIS = X08.SUB_SERIE_DOCFIS ';

                     --       v_sql := v_sql || '  AND x08.IDENT_PRODUTO        = P.IDENT_PRODUTO ';

                            v_sql := v_sql || '  AND D.COD_PRODUTO        = P.COD_PRODUTO ';


                        if QTD_BUSCA = 1 then
                          v_sql := v_sql || '  AND X07.DATA_FISCAL        < P.DATA_FISCAL ';
                        end if;

                     --       v_sql := v_sql || '  AND X07.DATA_FISCAL      < P.DATA_FISCAL ';

                            v_sql := v_sql || '  AND X07.DATA_FISCAL       >= to_date(''' ||
                                     to_char(D.DT_INICIAL,'ddmmyyyy')
                                     || ''',''ddmmyyyy'') '; --ULTIMOS 2 ANOS
                            v_sql := v_sql || '  AND X07.DATA_FISCAL       <= to_date(''' ||
                                     --vp_data_fim
                                     to_char(D.DT_FINAL,'ddmmyyyy')
                                     || ''',''ddmmyyyy'') '; --ULTIMOS 2 ANOS

                    --        v_sql := v_sql || '  AND X08.MOVTO_E_S         <> ''9'' ';
                    --        v_sql := v_sql || '  AND X08.NORM_DEV           = ''1'' ';
                    --        v_sql := v_sql || '          AND X08.COD_EMPRESA        = ''' ||
                    --                 mcod_empresa || ''' ';
                    --        v_sql := v_sql || '          AND X08.COD_ESTAB          = ''' ||
                    --                 vp_cod_estab || ''' ';
                    --        v_sql := v_sql || '  AND X08.DATA_FISCAL      < P.DATA_FISCAL ';
                    --        v_sql := v_sql || '  AND X08.DATA_FISCAL       >= to_date(''' ||
                    --                 vp_data_fim || ''',''ddmmyyyy'') '; --ULTIMOS 2 ANOS

                            v_sql := v_sql || '       ) A ';
                    --        v_sql := v_sql || ' WHERE A.RANK = 1 ';
                    */

                    v_sql := '';
                    v_sql := v_sql || 'SELECT  /* 4 */ DISTINCT ''' || vp_proc_instance || ''', ';
                    v_sql := v_sql || ' A.COD_EMPRESA, ';
                    v_sql := v_sql || ' A.COD_ESTAB, ';
                    v_sql := v_sql || ' A.DATA_FISCAL, ';
                    v_sql := v_sql || ' A.MOVTO_E_S, ';
                    v_sql := v_sql || ' A.NORM_DEV, ';
                    v_sql := v_sql || ' A.IDENT_DOCTO, ';
                    v_sql := v_sql || ' A.IDENT_FIS_JUR, ';
                    v_sql := v_sql || ' A.NUM_DOCFIS, ';
                    v_sql := v_sql || ' A.SERIE_DOCFIS, ';
                    v_sql := v_sql || ' A.SUB_SERIE_DOCFIS, ';
                    v_sql := v_sql || ' A.DISCRI_ITEM, ';
                    v_sql := v_sql || ' A.NUM_ITEM, ';
                    v_sql := v_sql || ' A.COD_FIS_JUR, ';
                    v_sql := v_sql || ' A.CPF_CGC, ';
                    v_sql := v_sql || ' A.COD_NBM, ';
                    v_sql := v_sql || ' A.COD_CFO, ';
                    v_sql := v_sql || ' A.COD_NATUREZA_OP, ';
                    v_sql := v_sql || ' A.COD_PRODUTO, ';
                    v_sql := v_sql || ' A.VLR_CONTAB_ITEM, ';
                    v_sql := v_sql || ' A.QUANTIDADE, ';
                    v_sql := v_sql || ' A.VLR_UNIT, ';
                    v_sql := v_sql || ' A.VLR_ICMSS_N_ESCRIT, ';
                    v_sql := v_sql || ' A.COD_SITUACAO_B, ';
                    v_sql := v_sql || ' A.DATA_EMISSAO, ';
                    v_sql := v_sql || ' A.COD_ESTADO, ';
                    v_sql := v_sql || ' A.NUM_CONTROLE_DOCTO, ';
                    v_sql := v_sql || ' A.NUM_AUTENTIC_NFE, ';
                    v_sql := v_sql || ' A.VLR_ITEM        , ';
                    v_sql := v_sql || ' A.VLR_OUTRAS      , ';
                    v_sql := v_sql || ' A.VLR_DESCONTO    , ';
                    v_sql := v_sql || ' A.CST_PIS         , ';
                    v_sql := v_sql || ' A.VLR_BASE_PIS    , ';
                    v_sql := v_sql || ' A.VLR_ALIQ_PIS    , ';
                    v_sql := v_sql || ' A.VLR_PIS         , ';
                    v_sql := v_sql || ' A.CST_COFINS      , ';
                    v_sql := v_sql || ' A.VLR_BASE_COFINS , ';
                    v_sql := v_sql || ' A.VLR_ALIQ_COFINS , ';
                    v_sql := v_sql || ' A.VLR_COFINS      , ';
                    v_sql := v_sql || ' A.VLR_BASE_ICMS, ';
                    v_sql := v_sql || ' A.VLR_ICMS, ';
                    v_sql := v_sql || ' A.VLR_BASE_ICMSS, ';
                    v_sql := v_sql || ' A.VLR_ICMSS ';
                    v_sql := v_sql || ', A.DATA_FISCAL_SAIDA ';
                    v_sql := v_sql || ' FROM ( ';
                    v_sql := v_sql || '     SELECT    ';
                    v_sql := v_sql || '               NF.COD_EMPRESA, ';
                    v_sql := v_sql || '               NF.COD_ESTAB, ';
                    v_sql := v_sql || '               NF.DATA_FISCAL, ';
                    v_sql := v_sql || '               NF.MOVTO_E_S, ';
                    v_sql := v_sql || '               NF.NORM_DEV, ';
                    v_sql := v_sql || '               NF.IDENT_DOCTO, ';
                    v_sql := v_sql || '               NF.IDENT_FIS_JUR, ';
                    v_sql := v_sql || '               NF.NUM_DOCFIS, ';
                    v_sql := v_sql || '               NF.SERIE_DOCFIS, ';
                    v_sql := v_sql || '               NF.SUB_SERIE_DOCFIS, ';
                    v_sql := v_sql || '               NF.DISCRI_ITEM, ';
                    v_sql := v_sql || '               NF.NUM_ITEM, ';
                    v_sql := v_sql || '               NF.COD_FIS_JUR, ';
                    v_sql := v_sql || '               NF.CPF_CGC, ';
                    v_sql := v_sql || '               NF.COD_NBM, ';
                    v_sql := v_sql || '               NF.COD_CFO, ';
                    v_sql := v_sql || '               NF.COD_NATUREZA_OP, ';
                    v_sql := v_sql || '               NF.COD_PRODUTO, ';
                    v_sql := v_sql || '               NF.VLR_CONTAB_ITEM, ';
                    v_sql := v_sql || '               NF.QUANTIDADE, ';
                    v_sql := v_sql || '               NF.VLR_UNIT, ';
                    v_sql := v_sql || '               NF.VLR_ICMSS_N_ESCRIT, ';
                    v_sql := v_sql || '               NF.COD_SITUACAO_B, ';
                    v_sql := v_sql || '               NF.DATA_EMISSAO, ';
                    v_sql := v_sql || '               NF.COD_ESTADO, ';
                    v_sql := v_sql || '               NF.NUM_CONTROLE_DOCTO, ';
                    v_sql := v_sql || '               NF.NUM_AUTENTIC_NFE, ';
                    v_sql := v_sql || '               NF.VLR_BASE_ICMS, ';
                    v_sql := v_sql || '               NF.VLR_ICMS, ';
                    v_sql := v_sql || '               NF.VLR_BASE_ICMSS, ';
                    v_sql := v_sql || '               NF.VLR_ICMSS, ';
                    v_sql := v_sql || ' NF.VLR_ITEM        , ';
                    v_sql := v_sql || ' NF.VLR_OUTRAS      , ';
                    v_sql := v_sql || ' NF.VLR_DESCONTO    , ';
                    v_sql := v_sql || ' NF.CST_PIS         , ';
                    v_sql := v_sql || ' NF.VLR_BASE_PIS    , ';
                    v_sql := v_sql || ' NF.VLR_ALIQ_PIS    , ';
                    v_sql := v_sql || ' NF.VLR_PIS         , ';
                    v_sql := v_sql || ' NF.CST_COFINS      , ';
                    v_sql := v_sql || ' NF.VLR_BASE_COFINS , ';
                    v_sql := v_sql || ' NF.VLR_ALIQ_COFINS , ';
                    v_sql := v_sql || ' NF.VLR_COFINS      , ';
                    v_sql := v_sql || ' P.DATA_FISCAL   DATA_FISCAL_SAIDA    ';
                    v_sql := v_sql || '        FROM  ';
                    v_sql := v_sql || '     (SELECT DISTINCT TMP.COD_PRODUTO, TMP.DATA_FISCAL AS DATA_FISCAL ';
                    v_sql := v_sql || '              FROM ' || vp_tabela_prod_saida || ' TMP ';
                    v_sql := v_sql || ' ) P, ';
                    v_sql := v_sql || '  MSAFI.DPSP_NF_ENTRADA partition for (TO_DATE(''';
                    v_sql :=
                           v_sql
                        || TO_CHAR ( d.dt_final
                                   , 'DD/MM/YYYY' )
                        || ''',''DD/MM/YYYY'') ) NF ';
                    v_sql := v_sql || '        WHERE 1=1 ';
                    v_sql := v_sql || '  AND NF.COD_EMPRESA   = ''' || mcod_empresa || ''' ';
                    v_sql := v_sql || '          AND NF.COD_ESTAB          = ''' || vp_cod_estab || ''' ';
                    v_sql :=
                        v_sql || '          AND NF.COD_CFO IN (''1102'',''2102'',''1403'',''2403'',''1910'',''2910'') ';

                    IF ( mcod_empresa = 'DSP' ) THEN
                        v_sql := v_sql || '      AND NF.CPF_CGC NOT LIKE ''61412110%'' '; --DSP
                    ELSE
                        v_sql := v_sql || '      AND NF.CPF_CGC NOT LIKE ''334382500%'' '; --DP
                    END IF;

                    v_sql := v_sql || '          AND NF.NUM_CONTROLE_DOCTO  NOT LIKE ''C%'' ';
                    v_sql := v_sql || '  AND NF.NORM_DEV = ''1'' ';
                    v_sql := v_sql || '  AND NF.SITUACAO = ''N'' ';
                    v_sql := v_sql || '  AND NF.VLR_item       <> 0 ';
                    v_sql := v_sql || '  AND NF.COD_PRODUTO        = P.COD_PRODUTO ';

                    IF qtd_busca = 1 THEN
                        v_sql := v_sql || '  AND NF.DATA_FISCAL        < P.DATA_FISCAL ';
                    END IF;

                    v_sql :=
                           v_sql
                        || '  AND NF.DATA_FISCAL       >= to_date('''
                        || TO_CHAR ( d.dt_inicial
                                   , 'ddmmyyyy' )
                        || ''',''ddmmyyyy'') '; --ULTIMOS 2 ANOS
                    v_sql :=
                           v_sql
                        || '  AND NF.DATA_FISCAL       <= to_date('''
                        || TO_CHAR ( d.dt_final
                                   , 'ddmmyyyy' )
                        || ''',''ddmmyyyy'') '; --ULTIMOS 2 ANOS
                    v_sql := v_sql || '       ) A ';
                /*       loga(substr(v_sql, 1, 1024), FALSE);
                loga(substr(v_sql, 1024, 1024), FALSE);
                loga(substr(v_sql, 2048, 1024), FALSE);
                loga(substr(v_sql, 3072, 1024), FALSE);
                loga(substr(v_sql, 4096, 1024), FALSE);
                loga(substr(v_sql, 5120, 1024), FALSE);
                loga(substr(v_sql, 6144, 1024), FALSE);
                loga(substr(v_sql, 7168, 1024), FALSE);
                loga(substr(v_sql, 8192), FALSE);*/

                END IF;

                BEGIN
                    OPEN c_entrada FOR v_sql;
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
                        loga ( SUBSTR ( v_sql
                                      , 5120
                                      , 1024 )
                             , FALSE );
                        loga ( SUBSTR ( v_sql
                                      , 6144
                                      , 1024 )
                             , FALSE );
                        loga ( SUBSTR ( v_sql
                                      , 7168
                                      , 1024 )
                             , FALSE );
                        loga ( SUBSTR ( v_sql
                                      , 8192
                                      , 1024 )
                             , FALSE );
                        loga ( SUBSTR ( v_sql
                                      , 9218 )
                             , FALSE );
                        raise_application_error ( -20004
                                                , '!ERRO SELECT ENTRADA ' || vp_origem );
                END;

                LOOP
                    FETCH c_entrada
                        BULK COLLECT INTO tab_e
                        LIMIT 100;

                    BEGIN
                        FORALL i IN tab_e.FIRST .. tab_e.LAST SAVE EXCEPTIONS
                            EXECUTE IMMEDIATE
                                   'INSERT /*+APPEND*/ INTO '
                                || vp_tabela_entrada
                                || ' VALUES (:1, :2, :3, :4, :5, :6, :7, :8, :9, '
                                || ' :10, :11, :12, :13, :14, :15, :16, :17, :18, :19, :20, :21, :22, :23, :24, :25, '
                                || ' :26, :27, :28 '
                                || --', :28, :29, :30, :31, :32, :33, :34, :35, :36, :37, :38, :39, :40, :41, :42, :43 ' ||
                                   ' ) '
                                USING tab_e ( i ).proc_id
                                    , tab_e ( i ).cod_empresa
                                    , tab_e ( i ).cod_estab
                                    , tab_e ( i ).data_fiscal
                                    , tab_e ( i ).movto_e_s
                                    , tab_e ( i ).norm_dev
                                    , tab_e ( i ).ident_docto
                                    , tab_e ( i ).ident_fis_jur
                                    , tab_e ( i ).num_docfis
                                    , tab_e ( i ).serie_docfis
                                    , tab_e ( i ).sub_serie_docfis
                                    , tab_e ( i ).discri_item
                                    , tab_e ( i ).num_item
                                    , tab_e ( i ).cod_fis_jur
                                    , tab_e ( i ).cpf_cgc
                                    , tab_e ( i ).cod_nbm
                                    , tab_e ( i ).cod_cfo
                                    , tab_e ( i ).cod_natureza_op
                                    , tab_e ( i ).cod_produto
                                    , tab_e ( i ).vlr_contab_item
                                    , tab_e ( i ).quantidade
                                    , tab_e ( i ).vlr_unit
                                    , --  tab_e(i).vlr_icmss_n_escrit,
                                      tab_e ( i ).cod_situacao_b
                                    , tab_e ( i ).data_emissao
                                    , tab_e ( i ).cod_estado
                                    , tab_e ( i ).num_controle_docto
                                    , tab_e ( i ).num_autentic_nfe /*,
                                          tab_e(i).vlr_item, tab_e(i)
                                         .vlr_outras, tab_e(i).vlr_desconto,
                                          tab_e(i).cst_pis, tab_e(i)
                                         .vlr_base_pis, tab_e(i)
                                         .vlr_aliq_pis, tab_e(i).vlr_pis,
                                          tab_e(i).cst_cofins, tab_e(i)
                                         .vlr_base_cofins, tab_e(i)
                                         .vlr_aliq_cofins, tab_e(i)
                                         .vlr_cofins, tab_e(i).vlr_base_icms,
                                          tab_e(i).vlr_icms, tab_e(i)
                                         .vlr_base_icmss, tab_e(i).vlr_icmss*/
                                    , tab_e ( i ).data_fiscal_saida;
                    EXCEPTION
                        WHEN OTHERS THEN
                            errors := SQL%BULK_EXCEPTIONS.COUNT;

                            FOR i IN 1 .. errors LOOP
                                loga ( 'ERRO #' || i || ' LINHA #' || SQL%BULK_EXCEPTIONS ( i ).ERROR_INDEX
                                     , FALSE );
                                loga ( 'MSG: ' || SQLERRM ( -SQL%BULK_EXCEPTIONS ( i ).ERROR_CODE )
                                     , FALSE );
                            END LOOP;

                            raise_application_error ( -20004
                                                    , '!ERRO INSERT ENTRADA ' || vp_origem );
                    END;

                    COMMIT;
                    tab_e.delete;

                    EXIT WHEN c_entrada%NOTFOUND;
                END LOOP;

                COMMIT;

                CLOSE c_entrada;
            END IF;
        END LOOP;

        loga ( 'LOAD_ENTRADA-FIM-' || vp_cod_estab || '-' || vp_origem || '-' || qtd_busca
             , FALSE );
    --    delete_temp_tbl_gen(vp_proc_instance, vp_tabela_prod_saida);

    EXCEPTION
        WHEN OTHERS THEN
            loga ( 'Erro não tratado: ' || dbms_utility.format_error_backtrace || SQLERRM
                 , FALSE );
    END;

    /*PROCEDURE LOAD_ENTRADAS(VP_PROC_INSTANCE  IN VARCHAR2,
                            VP_COD_ESTAB      IN VARCHAR2,
                            VP_DT_FINAL       IN DATE,
                            VP_ORIGEM         IN VARCHAR2,
                            VP_TABELA_ENTRADA IN VARCHAR2,
                            VP_TABELA_SAIDA   IN VARCHAR2,
                            VP_DATA_HORA_INI  IN VARCHAR2,
                            VP_DT_INICIAL     IN DATE) IS

      V_SQL VARCHAR2(4000);

    BEGIN

      IF (VP_ORIGEM = 'C') THEN
        --CD

        V_SQL := 'INSERT \*+APPEND*\ INTO ' || VP_TABELA_ENTRADA || ' ( ';
        V_SQL := V_SQL || 'SELECT ''' || VP_PROC_INSTANCE || ''', ';
        V_SQL := V_SQL || ' A.COD_EMPRESA, ';
        V_SQL := V_SQL || ' A.COD_ESTAB, ';
        V_SQL := V_SQL || ' A.DATA_FISCAL, ';
        V_SQL := V_SQL || ' A.MOVTO_E_S, ';
        V_SQL := V_SQL || ' A.NORM_DEV, ';
        V_SQL := V_SQL || ' A.IDENT_DOCTO, ';
        V_SQL := V_SQL || ' A.IDENT_FIS_JUR, ';
        V_SQL := V_SQL || ' A.NUM_DOCFIS, ';
        V_SQL := V_SQL || ' A.SERIE_DOCFIS, ';
        V_SQL := V_SQL || ' A.SUB_SERIE_DOCFIS, ';
        V_SQL := V_SQL || ' A.DISCRI_ITEM, ';
        V_SQL := V_SQL || ' A.NUM_ITEM, ';
        V_SQL := V_SQL || ' A.COD_FIS_JUR, ';
        V_SQL := V_SQL || ' A.CPF_CGC, ';
        V_SQL := V_SQL || ' A.COD_NBM, ';
        V_SQL := V_SQL || ' A.COD_CFO, ';
        V_SQL := V_SQL || ' A.COD_NATUREZA_OP, ';
        V_SQL := V_SQL || ' A.COD_PRODUTO, ';
        V_SQL := V_SQL || ' A.VLR_CONTAB_ITEM, ';
        V_SQL := V_SQL || ' A.QUANTIDADE, ';
        V_SQL := V_SQL || ' A.VLR_UNIT, ';
        V_SQL := V_SQL || ' A.COD_SITUACAO_B, ';
        V_SQL := V_SQL || ' A.DATA_EMISSAO, ';
        V_SQL := V_SQL || ' A.COD_ESTADO, ';
        V_SQL := V_SQL || ' A.NUM_CONTROLE_DOCTO, ';
        V_SQL := V_SQL || ' A.NUM_AUTENTIC_NFE ';
        V_SQL := V_SQL || ' FROM ( ';
        V_SQL := V_SQL || '   SELECT  \*+ORDERED ';
        V_SQL := V_SQL || '      STAR(X08) ';
        V_SQL := V_SQL || '      PARALLEL(X08, 6)*\ ';
        V_SQL := V_SQL || '        X08.COD_EMPRESA, ';
        V_SQL := V_SQL || '        X08.COD_ESTAB, ';
        V_SQL := V_SQL || '        X08.DATA_FISCAL, ';
        V_SQL := V_SQL || '        X08.MOVTO_E_S, ';
        V_SQL := V_SQL || '        X08.NORM_DEV, ';
        V_SQL := V_SQL || '        X08.IDENT_DOCTO, ';
        V_SQL := V_SQL || '        X08.IDENT_FIS_JUR, ';
        V_SQL := V_SQL || '        X08.NUM_DOCFIS, ';
        V_SQL := V_SQL || '        X08.SERIE_DOCFIS, ';
        V_SQL := V_SQL || '        X08.SUB_SERIE_DOCFIS, ';
        V_SQL := V_SQL || '        X08.DISCRI_ITEM, ';
        V_SQL := V_SQL || '        X08.NUM_ITEM, ';
        V_SQL := V_SQL || '        G.COD_FIS_JUR, ';
        V_SQL := V_SQL || '        G.CPF_CGC,  ';
        V_SQL := V_SQL || '        A.COD_NBM, ';
        V_SQL := V_SQL || '        B.COD_CFO, ';
        V_SQL := V_SQL || '        C.COD_NATUREZA_OP, ';
        V_SQL := V_SQL || '        D.COD_PRODUTO, ';
        V_SQL := V_SQL || '        X08.VLR_CONTAB_ITEM, ';
        V_SQL := V_SQL || '        X08.QUANTIDADE, ';
        V_SQL := V_SQL || '        X08.VLR_UNIT, ';
        V_SQL := V_SQL || '        E.COD_SITUACAO_B, ';
        V_SQL := V_SQL || '        X07.DATA_EMISSAO, ';
        V_SQL := V_SQL || '        H.COD_ESTADO, ';
        V_SQL := V_SQL || '        X07.NUM_CONTROLE_DOCTO, ';
        V_SQL := V_SQL || '        X07.NUM_AUTENTIC_NFE, ';
        --
        V_SQL := V_SQL || ' RANK() OVER( ';
        V_SQL := V_SQL || ' PARTITION BY X08.COD_ESTAB, D.COD_PRODUTO ';
        V_SQL := V_SQL || ' ORDER BY X08.DATA_FISCAL DESC, ';
        V_SQL := V_SQL || ' X07.DATA_EMISSAO DESC, ';
        V_SQL := V_SQL || ' X08.NUM_DOCFIS DESC, X08.DISCRI_ITEM DESC) RANK ';
        --
        V_SQL := V_SQL || ' FROM X08_ITENS_MERC X08, ';
        V_SQL := V_SQL || ' X07_DOCTO_FISCAL X07, ';
        V_SQL := V_SQL || ' X2013_PRODUTO D, ';
        V_SQL := V_SQL || ' X04_PESSOA_FIS_JUR G, ';
        V_SQL := V_SQL || ' (SELECT TMP.COD_PRODUTO, ';
        V_SQL := V_SQL || ' MIN(TMP.DATA_FISCAL) AS DATA_FISCAL ';
        V_SQL := V_SQL || ' FROM ' || VP_TABELA_SAIDA || ' TMP ';
        V_SQL := V_SQL || ' WHERE TMP.PROC_ID = ''' || VP_PROC_INSTANCE ||
                 ''' ';
        V_SQL := V_SQL || ' AND TMP.DESCR_TOT = ''ST'' ';
        V_SQL := V_SQL || '  GROUP BY TMP.COD_PRODUTO ) P, ';
        --
        V_SQL := V_SQL || ' X2043_COD_NBM A, ';
        V_SQL := V_SQL || ' X2012_COD_FISCAL B, ';
        V_SQL := V_SQL || ' X2006_NATUREZA_OP C, ';
        V_SQL := V_SQL || ' Y2026_SIT_TRB_UF_B E, ';
        V_SQL := V_SQL || ' ESTADO H  ';
        ---
        V_SQL := V_SQL || ' WHERE 1=1 ';
        V_SQL := V_SQL || ' AND X08.IDENT_NBM = A.IDENT_NBM ';
        V_SQL := V_SQL || ' AND X08.IDENT_CFO = B.IDENT_CFO ';
        V_SQL := V_SQL || ' AND X07.NORM_DEV  = 1 ';
        ---V_SQL := V_SQL || ' AND B.COD_CFO    IN (''1102'',''2102'',''1403'',''2403'',''1910'',''2910'') ';
        V_SQL := V_SQL || ' AND X08.IDENT_NATUREZA_OP = C.IDENT_NATUREZA_OP ';
        V_SQL := V_SQL || ' AND X08.IDENT_SITUACAO_B   = E.IDENT_SITUACAO_B ';
        V_SQL := V_SQL || ' AND X07.VLR_PRODUTO <> 0 ';
        V_SQL := V_SQL || ' AND X08.IDENT_PRODUTO = D.IDENT_PRODUTO ';
        V_SQL := V_SQL || ' AND X07.IDENT_FIS_JUR = G.IDENT_FIS_JUR ';
        V_SQL := V_SQL || ' AND G.IDENT_ESTADO = H.IDENT_ESTADO ';
        ---
        V_SQL := V_SQL || ' AND X07.COD_EMPRESA  = X08.COD_EMPRESA ';
        V_SQL := V_SQL || ' AND X07.COD_ESTAB = X08.COD_ESTAB ';
        V_SQL := V_SQL || ' AND X07.DATA_FISCAL  = X08.DATA_FISCAL ';
        V_SQL := V_SQL || ' AND X07.MOVTO_E_S = X08.MOVTO_E_S ';
        V_SQL := V_SQL || ' AND X07.NORM_DEV = X08.NORM_DEV ';
        V_SQL := V_SQL || ' AND X07.IDENT_DOCTO  = X08.IDENT_DOCTO ';
        V_SQL := V_SQL || ' AND X07.IDENT_FIS_JUR = X08.IDENT_FIS_JUR ';
        V_SQL := V_SQL || ' AND X07.NUM_DOCFIS = X08.NUM_DOCFIS ';
        V_SQL := V_SQL || ' AND X07.SERIE_DOCFIS = X08.SERIE_DOCFIS ';
        V_SQL := V_SQL || ' AND X07.SUB_SERIE_DOCFIS = X08.SUB_SERIE_DOCFIS ';
        ---
        V_SQL := V_SQL || ' AND X08.MOVTO_E_S <> ''9'' ';
        V_SQL := V_SQL || ' AND X08.COD_EMPRESA = ''' || MCOD_EMPRESA ||
                 ''' ';
        V_SQL := V_SQL || ' AND X08.COD_ESTAB = ''' || VP_COD_ESTAB || ''' ';

        V_SQL := V_SQL || ' AND D.COD_PRODUTO = P.COD_PRODUTO ';
        V_SQL := V_SQL || ' AND X08.DATA_FISCAL < P.DATA_FISCAL ';
        V_SQL := V_SQL || ' AND X08.DATA_FISCAL >= TO_DATE(''' ||
                 TO_CHAR(VP_DT_FINAL, 'DD/MM/YYYY') ||
                 ''',''DD/MM/YYYY'') - (365*2) '; --ULTIMOS 2 ANOS

        V_SQL := V_SQL || '       ) A ';
        V_SQL := V_SQL || ' WHERE A.RANK = 1 ) ';

        BEGIN
          EXECUTE IMMEDIATE V_SQL;
          COMMIT;

        EXCEPTION
          WHEN OTHERS THEN
            LOGA('SQLERRM: ' || SQLERRM, FALSE);
            LOGA(SUBSTR(V_SQL, 1, 1024), FALSE);
            LOGA(SUBSTR(V_SQL, 1024, 1024), FALSE);
            LOGA(SUBSTR(V_SQL, 2048, 1024), FALSE);
            LOGA(SUBSTR(V_SQL, 3072), FALSE);

            --ENVIAR EMAIL DE ERRO-------------------------------------------
            ENVIA_EMAIL(MCOD_EMPRESA,
                        VP_DT_INICIAL,
                        VP_DT_FINAL,
                        SQLERRM,
                        'E',
                        VP_DATA_HORA_INI);
            -----------------------------------------------------------------
            RAISE_APPLICATION_ERROR(-20003, '!ERRO INSERT LOAD ENTRADAS CD!');
        END;

      ELSIF (VP_ORIGEM = 'F') THEN
        --FILIAL

        V_SQL := 'INSERT \*+APPEND*\ INTO ' || VP_TABELA_ENTRADA || ' ( ';
        V_SQL := V_SQL || 'SELECT ''' || VP_PROC_INSTANCE || ''', ';
        V_SQL := V_SQL || ' A.COD_EMPRESA, ';
        V_SQL := V_SQL || ' A.COD_ESTAB, ';
        V_SQL := V_SQL || ' A.DATA_FISCAL, ';
        V_SQL := V_SQL || ' A.MOVTO_E_S, ';
        V_SQL := V_SQL || ' A.NORM_DEV, ';
        V_SQL := V_SQL || ' A.IDENT_DOCTO, ';
        V_SQL := V_SQL || ' A.IDENT_FIS_JUR, ';
        V_SQL := V_SQL || ' A.NUM_DOCFIS, ';
        V_SQL := V_SQL || ' A.SERIE_DOCFIS, ';
        V_SQL := V_SQL || ' A.SUB_SERIE_DOCFIS, ';
        V_SQL := V_SQL || ' A.DISCRI_ITEM, ';
        V_SQL := V_SQL || ' A.NUM_ITEM, ';
        V_SQL := V_SQL || ' A.COD_FIS_JUR, ';
        V_SQL := V_SQL || ' A.CPF_CGC, ';
        V_SQL := V_SQL || ' A.COD_NBM, ';
        V_SQL := V_SQL || ' A.COD_CFO, ';
        V_SQL := V_SQL || ' A.COD_NATUREZA_OP, ';
        V_SQL := V_SQL || ' A.COD_PRODUTO, ';
        V_SQL := V_SQL || ' A.VLR_CONTAB_ITEM, ';
        V_SQL := V_SQL || ' A.QUANTIDADE, ';
        V_SQL := V_SQL || ' A.VLR_UNIT, ';
        V_SQL := V_SQL || ' A.COD_SITUACAO_B, ';
        V_SQL := V_SQL || ' A.DATA_EMISSAO, ';
        V_SQL := V_SQL || ' A.COD_ESTADO, ';
        V_SQL := V_SQL || ' A.NUM_CONTROLE_DOCTO, ';
        V_SQL := V_SQL || ' A.NUM_AUTENTIC_NFE ';
        V_SQL := V_SQL || ' FROM ( ';
        V_SQL := V_SQL ||
                 '     SELECT  \*+PARALLEL(X08, 8) INDEX(G PK_X04_PESSOA_FIS_JUR) ';
        V_SQL := V_SQL ||
                 '       INDEX(A PK_X2043_COD_NBM) INDEX(D PK_X2013_PRODUTO) ';
        V_SQL := V_SQL ||
                 '       INDEX(E PK_Y2026_SIT_TRB_UF_B) INDEX(C PK_X2006_NATUREZA_OP) ';
        V_SQL := V_SQL || '        INDEX(B PK_X2012_COD_FISCAL)*\ ';
        V_SQL := V_SQL || '               X08.COD_EMPRESA, ';
        V_SQL := V_SQL || '               X08.COD_ESTAB, ';
        V_SQL := V_SQL || '               X08.DATA_FISCAL, ';
        V_SQL := V_SQL || '               X08.MOVTO_E_S, ';
        V_SQL := V_SQL || '               X08.NORM_DEV, ';
        V_SQL := V_SQL || '               X08.IDENT_DOCTO, ';
        V_SQL := V_SQL || '               X08.IDENT_FIS_JUR, ';
        V_SQL := V_SQL || '               X08.NUM_DOCFIS, ';
        V_SQL := V_SQL || '               X08.SERIE_DOCFIS, ';
        V_SQL := V_SQL || '               X08.SUB_SERIE_DOCFIS, ';
        V_SQL := V_SQL || '               X08.DISCRI_ITEM, ';
        V_SQL := V_SQL || '               X08.NUM_ITEM, ';
        V_SQL := V_SQL || '               G.COD_FIS_JUR, ';
        V_SQL := V_SQL || '               G.CPF_CGC, ';
        V_SQL := V_SQL || '               A.COD_NBM, ';
        V_SQL := V_SQL || '               B.COD_CFO, ';
        V_SQL := V_SQL || '               C.COD_NATUREZA_OP, ';
        V_SQL := V_SQL || '               D.COD_PRODUTO, ';
        V_SQL := V_SQL || '               X08.VLR_CONTAB_ITEM, ';
        V_SQL := V_SQL || '               X08.QUANTIDADE, ';
        V_SQL := V_SQL || '               X08.VLR_UNIT, ';
        V_SQL := V_SQL || '               E.COD_SITUACAO_B, ';
        V_SQL := V_SQL || '               X07.DATA_EMISSAO, ';
        V_SQL := V_SQL || '               H.COD_ESTADO, ';
        V_SQL := V_SQL || '               X07.NUM_CONTROLE_DOCTO, ';
        V_SQL := V_SQL || '               X07.NUM_AUTENTIC_NFE AS NUM_AUTENTIC_NFE, ';
        V_SQL := V_SQL || '               RANK() OVER( ';
        V_SQL := V_SQL ||
                 '                    PARTITION BY X08.COD_ESTAB, D.COD_PRODUTO, G.COD_FIS_JUR ';
        V_SQL := V_SQL ||
                 '                    ORDER BY X08.DATA_FISCAL DESC, X07.DATA_EMISSAO DESC, X08.NUM_DOCFIS DESC, X08.DISCRI_ITEM DESC) RANK ';
        V_SQL := V_SQL || '        FROM X08_ITENS_MERC X08, ';
        V_SQL := V_SQL || '             X07_DOCTO_FISCAL X07, ';
        V_SQL := V_SQL || '             X2013_PRODUTO D, ';
        V_SQL := V_SQL || '             X04_PESSOA_FIS_JUR G, ';
        V_SQL := V_SQL ||
                 ' (SELECT TMP.COD_PRODUTO, MIN(TMP.DATA_FISCAL) AS DATA_FISCAL ';
        V_SQL := V_SQL || ' FROM ' || VP_TABELA_SAIDA || ' TMP ';
        V_SQL := V_SQL || ' WHERE TMP.PROC_ID = ''' || VP_PROC_INSTANCE ||
                 ''' ';
        V_SQL := V_SQL || ' AND TMP.DESCR_TOT = ''ST'' ';
        V_SQL := V_SQL || ' GROUP BY TMP.COD_PRODUTO) P, ';
        V_SQL := V_SQL || '             X2043_COD_NBM A, ';
        V_SQL := V_SQL || '             X2012_COD_FISCAL B, ';
        V_SQL := V_SQL || '             X2006_NATUREZA_OP C, ';
        V_SQL := V_SQL || '             Y2026_SIT_TRB_UF_B E, ';
        V_SQL := V_SQL || '             ESTADO H  ';
        V_SQL := V_SQL || ' WHERE 1=1 ';
        V_SQL := V_SQL || ' AND X08.MOVTO_E_S <> ''9'' ';
        V_SQL := V_SQL || ' AND X08.COD_EMPRESA    = ''' || MCOD_EMPRESA ||
                 ''' ';
        V_SQL := V_SQL || ' AND X08.COD_ESTAB = ''' || VP_COD_ESTAB || ''' ';
        V_SQL := V_SQL || ' AND X08.IDENT_NBM = A.IDENT_NBM ';
        V_SQL := V_SQL || ' AND X08.IDENT_CFO = B.IDENT_CFO ';
        V_SQL := V_SQL || ' AND X07.NORM_DEV  = 1 ';
        ---V_SQL := V_SQL || ' AND B.COD_CFO   IN (''1152'',''2152'',''1409'',''2409'') ';
        V_SQL := V_SQL || ' AND X08.IDENT_NATUREZA_OP = C.IDENT_NATUREZA_OP ';
        V_SQL := V_SQL || ' AND X08.IDENT_SITUACAO_B  = E.IDENT_SITUACAO_B ';
        V_SQL := V_SQL || ' AND X07.VLR_PRODUTO    <> 0 ';
        V_SQL := V_SQL || ' AND D.IDENT_PRODUTO   = X08.IDENT_PRODUTO ';
        V_SQL := V_SQL || ' AND X07.IDENT_FIS_JUR  = G.IDENT_FIS_JUR ';
        V_SQL := V_SQL || ' AND G.IDENT_ESTADO    = H.IDENT_ESTADO ';
        ---
        V_SQL := V_SQL || ' AND X07.COD_EMPRESA   = X08.COD_EMPRESA ';
        V_SQL := V_SQL || ' AND X07.COD_ESTAB    = X08.COD_ESTAB ';
        V_SQL := V_SQL || ' AND X07.DATA_FISCAL   = X08.DATA_FISCAL ';
        V_SQL := V_SQL || ' AND X07.MOVTO_E_S    = X08.MOVTO_E_S ';
        V_SQL := V_SQL || ' AND X07.NORM_DEV = X08.NORM_DEV ';
        V_SQL := V_SQL || ' AND X07.IDENT_DOCTO   = X08.IDENT_DOCTO ';
        V_SQL := V_SQL || ' AND X07.IDENT_FIS_JUR  = X08.IDENT_FIS_JUR ';
        V_SQL := V_SQL || ' AND X07.NUM_DOCFIS    = X08.NUM_DOCFIS ';
        V_SQL := V_SQL || ' AND X07.SERIE_DOCFIS   = X08.SERIE_DOCFIS ';
        V_SQL := V_SQL || ' AND X07.SUB_SERIE_DOCFIS = X08.SUB_SERIE_DOCFIS ';

        V_SQL := V_SQL || ' AND D.COD_PRODUTO    = P.COD_PRODUTO ';
        V_SQL := V_SQL || ' AND X08.DATA_FISCAL   < P.DATA_FISCAL ';
        V_SQL := V_SQL || ' AND X08.DATA_FISCAL   >= TO_DATE(''' ||
                 TO_CHAR(VP_DT_FINAL, 'DD/MM/YYYY') ||
                 ''',''DD/MM/YYYY'') - (365*2) '; --ULTIMOS 2 ANOS

        V_SQL := V_SQL || '    ) A ';
        V_SQL := V_SQL || ' WHERE A.RANK = 1 ) ';

        BEGIN
          EXECUTE IMMEDIATE V_SQL;
          COMMIT;
        EXCEPTION
          WHEN OTHERS THEN
            LOGA('SQLERRM: ' || SQLERRM, FALSE);
            LOGA(SUBSTR(V_SQL, 1, 1024), FALSE);
            LOGA(SUBSTR(V_SQL, 1024, 1024), FALSE);
            LOGA(SUBSTR(V_SQL, 2048, 1024), FALSE);
            LOGA(SUBSTR(V_SQL, 3072), FALSE);
            --ENVIAR EMAIL DE ERRO-------------------------------------------
            ENVIA_EMAIL(MCOD_EMPRESA,
                        VP_DT_INICIAL,
                        VP_DT_FINAL,
                        SQLERRM,
                        'E',
                        VP_DATA_HORA_INI);
            -----------------------------------------------------------------
            RAISE_APPLICATION_ERROR(-20004,
                                    '!ERRO INSERT LOAD ENTRADAS FILIAL!');
        END;

      END IF;

    END;*/
    --PROCEDURE LOAD_ENTRADAS

    --PROCEDURE PARA CRIAR TABELAS TEMP DE ALIQ E PMC
    PROCEDURE load_aliq_pmc ( vp_proc_id IN NUMBER
                            , vp_nome_tabela_aliq   OUT VARCHAR2
                            , vp_tabela_saida IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 2000 );
        c_aliq_st SYS_REFCURSOR;

        TYPE cur_tab_aliq IS RECORD
        (
            proc_id NUMBER ( 30 )
          , cod_produto VARCHAR2 ( 25 )
          , aliq_st VARCHAR2 ( 4 )
        );

        TYPE c_tab_aliq IS TABLE OF cur_tab_aliq;

        tab_aliq c_tab_aliq;
    BEGIN
        vp_nome_tabela_aliq := 'DPSP_MSAF_ALIQ_' || vp_proc_id;

        v_sql := 'CREATE TABLE ' || vp_nome_tabela_aliq;
        v_sql := v_sql || ' (';
        v_sql := v_sql || 'PROC_ID     NUMBER(30),';
        v_sql := v_sql || 'COD_PRODUTO VARCHAR2(25),';
        v_sql := v_sql || 'ALIQ_ST     VARCHAR2(4)';
        v_sql := v_sql || ' )';
        v_sql := v_sql || ' TABLESPACE ' || v_tablespace_table;

        EXECUTE IMMEDIATE v_sql;

        ---
        save_tmp_control ( vp_proc_id
                         , vp_nome_tabela_aliq );

        v_sql := 'SELECT DISTINCT ' || vp_proc_id || ' AS PROC_ID, A.COD_PRODUTO AS COD_PRODUTO, A.ALIQ_ST AS ALIQ_ST ';
        v_sql := v_sql || 'FROM (SELECT A.COD_PRODUTO AS COD_PRODUTO, B.XLATLONGNAME AS ALIQ_ST ';
        v_sql := v_sql || '       FROM ' || vp_tabela_saida || ' A, ';
        v_sql := v_sql || '       MSAFI.PS_MSAF_PERDAS_VW  B, ';
        v_sql := v_sql || '       MSAFI.DSP_ESTABELECIMENTO D ';
        v_sql := v_sql || '       WHERE A.PROC_ID     = ' || vp_proc_id || ' ';
        v_sql := v_sql || '         AND B.SETID       = ''GERAL'' ';
        v_sql := v_sql || '         AND B.INV_ITEM_ID = A.COD_PRODUTO ';
        v_sql := v_sql || '         AND D.COD_EMPRESA = MSAFI.DPSP.EMPRESA ';
        v_sql := v_sql || '         AND D.COD_ESTAB   = A.COD_ESTAB ';
        v_sql := v_sql || '         AND B.CRIT_STATE_TO_PBL = D.COD_ESTADO ';
        v_sql := v_sql || '         AND B.CRIT_STATE_FR_PBL = D.COD_ESTADO) A ';

        OPEN c_aliq_st FOR v_sql;

        LOOP
            FETCH c_aliq_st
                BULK COLLECT INTO tab_aliq
                LIMIT 100;

            FOR i IN 1 .. tab_aliq.COUNT LOOP
                EXECUTE IMMEDIATE
                       'INSERT /*+APPEND*/ INTO '
                    || vp_nome_tabela_aliq
                    || ' VALUES ('
                    || tab_aliq ( i ).proc_id
                    || ','''
                    || tab_aliq ( i ).cod_produto
                    || ''','''
                    || tab_aliq ( i ).aliq_st
                    || ''')';
            END LOOP;

            tab_aliq.delete;

            EXIT WHEN c_aliq_st%NOTFOUND;
        END LOOP;

        COMMIT;

        CLOSE c_aliq_st;

        v_sql := 'CREATE INDEX PK_ALIQ_' || vp_proc_id || ' ON ' || vp_nome_tabela_aliq;
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || '   PROC_ID     ASC,';
        v_sql := v_sql || '   COD_PRODUTO ASC ';
        v_sql := v_sql || ' ) ';
        v_sql := v_sql || ' PCTFREE 10 ';
        v_sql := v_sql || ' TABLESPACE ' || v_tablespace_index;

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX1_ALIQ_' || vp_proc_id || ' ON ' || vp_nome_tabela_aliq;
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || '   PROC_ID     ASC,';
        v_sql := v_sql || '   COD_PRODUTO ASC, ';
        v_sql := v_sql || '   ALIQ_ST     ASC ';
        v_sql := v_sql || ' ) ';
        v_sql := v_sql || ' PCTFREE 10 ';
        v_sql := v_sql || ' TABLESPACE ' || v_tablespace_index;

        EXECUTE IMMEDIATE v_sql;

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_nome_tabela_aliq );
        loga ( '>>' || vp_nome_tabela_aliq || ' CRIADA'
             , FALSE );
    END;

    PROCEDURE get_entradas_cd ( vp_proc_id IN NUMBER
                              , vp_filial IN VARCHAR2
                              , vp_cd IN VARCHAR2
                              , vp_data_ini IN VARCHAR2
                              , vp_data_fim IN VARCHAR2
                              , vp_tab_entrada_c IN VARCHAR2
                              , vp_tabela_saida IN VARCHAR2
                              , vp_tabela_nf IN VARCHAR2
                              , vp_tabela_cartoes IN VARCHAR2
                              , vp_data_hora_ini IN VARCHAR2
                              , vp_tab_item IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 10000 );
    BEGIN
        v_sql := 'INSERT /*+APPEND*/ INTO ' || vp_tabela_cartoes || ' ( ';

        --
        v_sql := v_sql || 'SELECT proc_id, ';
        v_sql := v_sql || ' cod_empresa, ';
        v_sql := v_sql || ' COD_ESTAB        , ';
        v_sql := v_sql || ' UF_ESTAB         , ';
        v_sql := v_sql || ' DOCTO            , ';
        v_sql := v_sql || ' COD_PRODUTO      , ';
        v_sql := v_sql || ' NUM_ITEM         , ';
        v_sql := v_sql || ' DESCR_ITEM       , ';
        v_sql := v_sql || ' NUM_DOCFIS       , ';
        v_sql := v_sql || ' DATA_FISCAL      , ';
        v_sql := v_sql || ' SERIE_DOCFIS     , ';
        v_sql := v_sql || ' QUANTIDADE       , ';
        v_sql := v_sql || ' COD_NBM          , ';
        v_sql := v_sql || ' COD_CFO          , ';
        v_sql := v_sql || ' GRUPO_PRODUTO    , ';
        v_sql := v_sql || ' VLR_DESCONTO     , ';
        v_sql := v_sql || ' VLR_CONTABIL     , ';
        v_sql := v_sql || ' NUM_AUTENTIC_NFE , ';
        v_sql := v_sql || ' VLR_BASE_ICMS    , ';
        v_sql := v_sql || ' VLR_ALIQ_ICMS    , ';
        v_sql := v_sql || ' VLR_ICMS         , ';
        v_sql := v_sql || ' DESCR_TOT        , ';
        v_sql := v_sql || ' AUTORIZADORA     , ';
        v_sql := v_sql || ' NOME_VAN         , ';
        v_sql := v_sql || ' VLR_PAGO_CARTAO  , ';
        v_sql := v_sql || ' FORMA_PAGTO      , ';
        v_sql := v_sql || ' NUM_PARCELAS     , ';
        v_sql := v_sql || ' CODIGO_APROVACAO , ';
        ---
        v_sql := v_sql || ' COD_ESTAB_E, ';
        v_sql := v_sql || ' DATA_FISCAL_E, ';
        v_sql := v_sql || ' MOVTO_E_S_E, ';
        v_sql := v_sql || ' NORM_DEV_E, ';
        v_sql := v_sql || ' IDENT_DOCTO_E, ';
        v_sql := v_sql || ' IDENT_FIS_JUR_E, ';
        v_sql := v_sql || ' SUB_SERIE_DOCFIS_E, ';
        v_sql := v_sql || ' DISCRI_ITEM_E, ';
        v_sql := v_sql || ' DATA_EMISSAO_E, ';
        v_sql := v_sql || ' NUM_DOCFIS_E, ';
        v_sql := v_sql || ' SERIE_DOCFIS_E, ';
        v_sql := v_sql || ' NUM_ITEM_E, ';
        v_sql := v_sql || ' COD_FIS_JUR_E, ';
        v_sql := v_sql || ' CPF_CGC_E, ';
        v_sql := v_sql || ' COD_NBM_E, ';
        v_sql := v_sql || ' COD_CFO_E, ';
        v_sql := v_sql || ' COD_NATUREZA_OP_E, ';
        v_sql := v_sql || ' COD_PRODUTO_E, ';
        v_sql := v_sql || ' VLR_CONTAB_ITEM, ';
        v_sql := v_sql || ' QUANTIDADE_E, ';
        v_sql := v_sql || ' VLR_UNIT, ';
        v_sql := v_sql || ' COD_SITUACAO_B, ';
        v_sql := v_sql || ' COD_ESTADO, ';
        v_sql := v_sql || ' NUM_CONTROLE_DOCTO, ';
        v_sql := v_sql || ' NUM_AUTENTIC_NFE_E, ';
        ---
        v_sql := v_sql || ' BASE_ICMS_UNIT, ';
        v_sql := v_sql || ' VLR_ICMS_UNIT, ';
        v_sql := v_sql || ' ALIQ_ICMS, ';
        v_sql := v_sql || ' BASE_ST_UNIT, ';
        v_sql := v_sql || ' VLR_ICMS_ST_UNIT, ';
        v_sql := v_sql || ' VLR_ICMS_ST_UNIT_AUX, ';
        ---
        v_sql := v_sql || ' STAT_LIBER_CNTR ';
        --
        v_sql := v_sql || 'FROM ( ';
        v_sql := v_sql || 'SELECT ''' || vp_proc_id || ''' proc_id, ';
        v_sql := v_sql || ' ''' || mcod_empresa || ''' cod_empresa, ';
        v_sql := v_sql || ' A.COD_ESTAB        , ';
        v_sql := v_sql || ' A.UF_ESTAB         , ';
        v_sql := v_sql || ' A.DOCTO            , ';
        v_sql := v_sql || ' A.COD_PRODUTO      , ';
        v_sql := v_sql || ' A.NUM_ITEM         , ';
        v_sql := v_sql || ' A.DESCR_ITEM       , ';
        v_sql := v_sql || ' A.NUM_DOCFIS       , ';
        v_sql := v_sql || ' A.DATA_FISCAL      , ';
        v_sql := v_sql || ' A.SERIE_DOCFIS     , ';
        v_sql := v_sql || ' A.QUANTIDADE       , ';
        v_sql := v_sql || ' A.COD_NBM          , ';
        v_sql := v_sql || ' A.COD_CFO          , ';
        v_sql := v_sql || ' A.GRUPO_PRODUTO    , ';
        v_sql := v_sql || ' A.VLR_DESCONTO     , ';
        v_sql := v_sql || ' A.VLR_CONTABIL     , ';
        v_sql := v_sql || ' A.NUM_AUTENTIC_NFE , ';
        v_sql := v_sql || ' A.VLR_BASE_ICMS    , ';
        v_sql := v_sql || ' A.VLR_ALIQ_ICMS    , ';
        v_sql := v_sql || ' A.VLR_ICMS         , ';
        v_sql := v_sql || ' A.DESCR_TOT        , ';
        v_sql := v_sql || ' A.AUTORIZADORA     , ';
        v_sql := v_sql || ' A.NOME_VAN         , ';
        v_sql := v_sql || ' A.VLR_PAGO_CARTAO  , ';
        v_sql := v_sql || ' A.FORMA_PAGTO      , ';
        v_sql := v_sql || ' A.NUM_PARCELAS     , ';
        v_sql := v_sql || ' A.CODIGO_APROVACAO , ';
        ---
        v_sql := v_sql || ' B.COD_ESTAB COD_ESTAB_E, ';
        v_sql := v_sql || ' B.DATA_FISCAL DATA_FISCAL_E, ';
        v_sql := v_sql || ' B.MOVTO_E_S MOVTO_E_S_E, ';
        v_sql := v_sql || ' B.NORM_DEV NORM_DEV_E, ';
        v_sql := v_sql || ' B.IDENT_DOCTO IDENT_DOCTO_E, ';
        v_sql := v_sql || ' B.IDENT_FIS_JUR IDENT_FIS_JUR_E, ';
        v_sql := v_sql || ' B.SUB_SERIE_DOCFIS SUB_SERIE_DOCFIS_E, ';
        v_sql := v_sql || ' B.DISCRI_ITEM DISCRI_ITEM_E, ';
        v_sql := v_sql || ' B.DATA_EMISSAO DATA_EMISSAO_E, ';
        v_sql := v_sql || ' B.NUM_DOCFIS NUM_DOCFIS_E, ';
        v_sql := v_sql || ' B.SERIE_DOCFIS SERIE_DOCFIS_E, ';
        v_sql := v_sql || ' B.NUM_ITEM NUM_ITEM_E, ';
        v_sql := v_sql || ' B.COD_FIS_JUR COD_FIS_JUR_E, ';
        v_sql := v_sql || ' B.CPF_CGC CPF_CGC_E, ';
        v_sql := v_sql || ' B.COD_NBM COD_NBM_E, ';
        v_sql := v_sql || ' B.COD_CFO COD_CFO_E, ';
        v_sql := v_sql || ' B.COD_NATUREZA_OP COD_NATUREZA_OP_E, ';
        v_sql := v_sql || ' B.COD_PRODUTO COD_PRODUTO_E, ';
        v_sql := v_sql || ' B.VLR_CONTAB_ITEM, ';
        v_sql := v_sql || ' B.QUANTIDADE QUANTIDADE_E, ';
        v_sql := v_sql || ' B.VLR_UNIT, ';
        v_sql := v_sql || ' B.COD_SITUACAO_B, ';
        v_sql := v_sql || ' B.COD_ESTADO, ';
        v_sql := v_sql || ' B.NUM_CONTROLE_DOCTO, ';
        v_sql := v_sql || ' B.NUM_AUTENTIC_NFE NUM_AUTENTIC_NFE_E, ';
        ---
        v_sql := v_sql || ' C.BASE_ICMS_UNIT, ';
        v_sql := v_sql || ' C.VLR_ICMS_UNIT, ';
        v_sql := v_sql || ' C.ALIQ_ICMS, ';
        v_sql := v_sql || ' C.BASE_ST_UNIT, ';
        v_sql := v_sql || ' C.VLR_ICMS_ST_UNIT, ';
        v_sql := v_sql || ' C.VLR_ICMS_ST_UNIT_AUX, ';
        ---
        v_sql :=
            v_sql || ' DECODE(E.FLAG_CONTROLADO,''C'',''CONTROLADO'',''L'',''LIBERADO'',''OUTRO'') STAT_LIBER_CNTR ,';

        v_sql := v_sql || '              RANK() OVER( ';
        v_sql := v_sql || '                   PARTITION BY A.COD_ESTAB, A.DATA_FISCAL, A.COD_PRODUTO ';
        v_sql :=
               v_sql
            || '                   ORDER BY B.DATA_FISCAL DESC, B.DATA_EMISSAO DESC, B.NUM_DOCFIS, B.DISCRI_ITEM, B.NUM_DOCFIS) V_RANK ';

        ---
        v_sql := v_sql || ' FROM ' || vp_tabela_saida || ' A, ';
        v_sql := v_sql || '  ' || vp_tab_entrada_c || ' B, ';
        v_sql := v_sql || '  ' || vp_tabela_nf || ' C, ';
        v_sql := v_sql || '  MSAFI.DSP_INTERFACE_SETUP D, ';
        v_sql := v_sql || '  ' || vp_tab_item || ' E ';
        --
        v_sql := v_sql || ' WHERE A.PROC_ID = ''' || vp_proc_id || ''' ';
        v_sql := v_sql || ' AND A.COD_ESTAB = ''' || vp_filial || ''' ';
        v_sql := v_sql || ' AND A.DESCR_TOT = ''ST'' ';
        ---
        v_sql := v_sql || ' AND A.DATA_FISCAL > B.DATA_FISCAL ';
        ---
        v_sql := v_sql || ' AND B.PROC_ID = A.PROC_ID ';
        v_sql := v_sql || ' AND B.COD_EMPRESA = A.COD_EMPRESA ';
        v_sql := v_sql || ' AND B.COD_ESTAB = ''' || vp_cd || ''' ';
        v_sql := v_sql || ' AND B.COD_PRODUTO = A.COD_PRODUTO ';
        ---
        v_sql := v_sql || ' AND D.COD_EMPRESA  = ''' || mcod_empresa || ''' ';
        v_sql := v_sql || ' AND A.PROC_ID = C.PROC_ID ';
        v_sql := v_sql || ' AND D.BU_PO1 = C.BUSINESS_UNIT ';
        v_sql := v_sql || ' AND B.NUM_CONTROLE_DOCTO = C.NF_BRL_ID ';
        v_sql := v_sql || ' AND B.NUM_ITEM = C.NF_BRL_LINE_NUM ';
        ---
        v_sql := v_sql || ' AND E.COD_PRODUTO = A.COD_PRODUTO ';
        ---
        v_sql := v_sql || ' AND NOT EXISTS (SELECT  ''Y'' ';
        v_sql := v_sql || '   FROM ' || vp_tabela_cartoes || ' C ';
        v_sql := v_sql || '   WHERE C.PROC_ID  = A.PROC_ID';
        v_sql := v_sql || '  AND C.COD_EMPRESA  = A.COD_EMPRESA';
        v_sql := v_sql || '  AND C.COD_ESTAB  = A.COD_ESTAB';
        v_sql := v_sql || '  AND C.UF_ESTAB   = A.UF_ESTAB';
        v_sql := v_sql || '  AND C.DOCTO    = A.DOCTO';
        v_sql := v_sql || '  AND C.COD_PRODUTO  = A.COD_PRODUTO';
        v_sql := v_sql || '  AND C.NUM_ITEM   = A.NUM_ITEM';
        v_sql := v_sql || '  AND C.NUM_DOCFIS = A.NUM_DOCFIS';
        v_sql := v_sql || '  AND C.DATA_FISCAL  = A.DATA_FISCAL';
        v_sql := v_sql || '  AND C.SERIE_DOCFIS = A.SERIE_DOCFIS)) ';
        v_sql := v_sql || '   WHERE V_RANK = 1) ';



        BEGIN
            EXECUTE IMMEDIATE v_sql;

            COMMIT;
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
                              , 3072 )
                     , FALSE );
                --ENVIAR EMAIL DE ERRO-------------------------------------------
                envia_email ( mcod_empresa
                            , vp_data_ini
                            , vp_data_fim
                            , SQLERRM
                            , 'E'
                            , vp_data_hora_ini );
                -----------------------------------------------------------------
                raise_application_error ( -20007
                                        , '!ERRO INSERT GET_ENTRADAS_CD!' );
        END;

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_tabela_cartoes );
    --LOGA('C_ENTR_CD-FIM-' || VP_CD || '-' || VP_FILIAL, FALSE);

    END; --GET_ENTRADAS_CD

    PROCEDURE get_entradas_filial ( vp_proc_id IN NUMBER
                                  , vp_filial IN VARCHAR2
                                  , vp_cd IN VARCHAR2
                                  , vp_data_ini IN VARCHAR2
                                  , vp_data_fim IN VARCHAR2
                                  , vp_tabela_entrada IN VARCHAR2
                                  , vp_tabela_saida IN VARCHAR2
                                  , vp_tabela_nf IN VARCHAR2
                                  , vp_tabela_cartoes IN VARCHAR2
                                  , vp_data_hora_ini IN VARCHAR2
                                  , vp_tab_item IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 10000 );
    BEGIN
        v_sql := 'INSERT /*+APPEND*/ INTO ' || vp_tabela_cartoes || ' ( ';

        v_sql := v_sql || 'SELECT proc_id, ';
        v_sql := v_sql || ' cod_empresa, ';
        v_sql := v_sql || ' COD_ESTAB        , ';
        v_sql := v_sql || ' UF_ESTAB         , ';
        v_sql := v_sql || ' DOCTO            , ';
        v_sql := v_sql || ' COD_PRODUTO      , ';
        v_sql := v_sql || ' NUM_ITEM         , ';
        v_sql := v_sql || ' DESCR_ITEM       , ';
        v_sql := v_sql || ' NUM_DOCFIS       , ';
        v_sql := v_sql || ' DATA_FISCAL      , ';
        v_sql := v_sql || ' SERIE_DOCFIS     , ';
        v_sql := v_sql || ' QUANTIDADE       , ';
        v_sql := v_sql || ' COD_NBM          , ';
        v_sql := v_sql || ' COD_CFO          , ';
        v_sql := v_sql || ' GRUPO_PRODUTO    , ';
        v_sql := v_sql || ' VLR_DESCONTO     , ';
        v_sql := v_sql || ' VLR_CONTABIL     , ';
        v_sql := v_sql || ' NUM_AUTENTIC_NFE , ';
        v_sql := v_sql || ' VLR_BASE_ICMS    , ';
        v_sql := v_sql || ' VLR_ALIQ_ICMS    , ';
        v_sql := v_sql || ' VLR_ICMS         , ';
        v_sql := v_sql || ' DESCR_TOT        , ';
        v_sql := v_sql || ' AUTORIZADORA     , ';
        v_sql := v_sql || ' NOME_VAN         , ';
        v_sql := v_sql || ' VLR_PAGO_CARTAO  , ';
        v_sql := v_sql || ' FORMA_PAGTO      , ';
        v_sql := v_sql || ' NUM_PARCELAS     , ';
        v_sql := v_sql || ' CODIGO_APROVACAO , ';
        ---
        v_sql := v_sql || ' COD_ESTAB_E, ';
        v_sql := v_sql || ' DATA_FISCAL_E, ';
        v_sql := v_sql || ' MOVTO_E_S_E, ';
        v_sql := v_sql || ' NORM_DEV_E, ';
        v_sql := v_sql || ' IDENT_DOCTO_E, ';
        v_sql := v_sql || ' IDENT_FIS_JUR_E, ';
        v_sql := v_sql || ' SUB_SERIE_DOCFIS_E, ';
        v_sql := v_sql || ' DISCRI_ITEM_E, ';
        v_sql := v_sql || ' DATA_EMISSAO_E, ';
        v_sql := v_sql || ' NUM_DOCFIS_E, ';
        v_sql := v_sql || ' SERIE_DOCFIS_E, ';
        v_sql := v_sql || ' NUM_ITEM_E, ';
        v_sql := v_sql || ' COD_FIS_JUR_E, ';
        v_sql := v_sql || ' CPF_CGC_E, ';
        v_sql := v_sql || ' COD_NBM_E, ';
        v_sql := v_sql || ' COD_CFO_E, ';
        v_sql := v_sql || ' COD_NATUREZA_OP_E, ';
        v_sql := v_sql || ' COD_PRODUTO_E, ';
        v_sql := v_sql || ' VLR_CONTAB_ITEM, ';
        v_sql := v_sql || ' QUANTIDADE_E, ';
        v_sql := v_sql || ' VLR_UNIT, ';
        v_sql := v_sql || ' COD_SITUACAO_B, ';
        v_sql := v_sql || ' COD_ESTADO, ';
        v_sql := v_sql || ' NUM_CONTROLE_DOCTO, ';
        v_sql := v_sql || ' NUM_AUTENTIC_NFE_E, ';
        ---
        v_sql := v_sql || ' BASE_ICMS_UNIT, ';
        v_sql := v_sql || ' VLR_ICMS_UNIT, ';
        v_sql := v_sql || ' ALIQ_ICMS, ';
        v_sql := v_sql || ' BASE_ST_UNIT, ';
        v_sql := v_sql || ' VLR_ICMS_ST_UNIT, ';
        v_sql := v_sql || ' VLR_ICMS_ST_UNIT_AUX, ';
        ---
        v_sql := v_sql || ' STAT_LIBER_CNTR ';
        --
        v_sql := v_sql || 'FROM ( ';
        v_sql := v_sql || ' SELECT ';
        v_sql := v_sql || ' ''' || vp_proc_id || ''' PROC_ID, ';
        v_sql := v_sql || ' ''' || mcod_empresa || ''' COD_EMPRESA, ';
        v_sql := v_sql || ' A.COD_ESTAB        , ';
        v_sql := v_sql || ' A.UF_ESTAB         , ';
        v_sql := v_sql || ' A.DOCTO            , ';
        v_sql := v_sql || ' A.COD_PRODUTO      , ';
        v_sql := v_sql || ' A.NUM_ITEM         , ';
        v_sql := v_sql || ' A.DESCR_ITEM       , ';
        v_sql := v_sql || ' A.NUM_DOCFIS       , ';
        v_sql := v_sql || ' A.DATA_FISCAL      , ';
        v_sql := v_sql || ' A.SERIE_DOCFIS     , ';
        v_sql := v_sql || ' A.QUANTIDADE       , ';
        v_sql := v_sql || ' A.COD_NBM          , ';
        v_sql := v_sql || ' A.COD_CFO          , ';
        v_sql := v_sql || ' A.GRUPO_PRODUTO    , ';
        v_sql := v_sql || ' A.VLR_DESCONTO     , ';
        v_sql := v_sql || ' A.VLR_CONTABIL     , ';
        v_sql := v_sql || ' A.NUM_AUTENTIC_NFE , ';
        v_sql := v_sql || ' A.VLR_BASE_ICMS    , ';
        v_sql := v_sql || ' A.VLR_ALIQ_ICMS    , ';
        v_sql := v_sql || ' A.VLR_ICMS         , ';
        v_sql := v_sql || ' A.DESCR_TOT        , ';
        v_sql := v_sql || ' A.AUTORIZADORA     , ';
        v_sql := v_sql || ' A.NOME_VAN         , ';
        v_sql := v_sql || ' A.VLR_PAGO_CARTAO  , ';
        v_sql := v_sql || ' A.FORMA_PAGTO      , ';
        v_sql := v_sql || ' A.NUM_PARCELAS     , ';
        v_sql := v_sql || ' A.CODIGO_APROVACAO , ';
        ---
        v_sql := v_sql || ' B.COD_ESTAB COD_ESTAB_E, ';
        v_sql := v_sql || ' B.DATA_FISCAL DATA_FISCAL_E, ';
        v_sql := v_sql || ' B.MOVTO_E_S MOVTO_E_S_E, ';
        v_sql := v_sql || ' B.NORM_DEV NORM_DEV_E, ';
        v_sql := v_sql || ' B.IDENT_DOCTO IDENT_DOCTO_E, ';
        v_sql := v_sql || ' B.IDENT_FIS_JUR IDENT_FIS_JUR_E, ';
        v_sql := v_sql || ' B.SUB_SERIE_DOCFIS SUB_SERIE_DOCFIS_E, ';
        v_sql := v_sql || ' B.DISCRI_ITEM DISCRI_ITEM_E, ';
        v_sql := v_sql || ' B.DATA_EMISSAO DATA_EMISSAO_E, ';
        v_sql := v_sql || ' B.NUM_DOCFIS NUM_DOCFIS_E, ';
        v_sql := v_sql || ' B.SERIE_DOCFIS SERIE_DOCFIS_E, ';
        v_sql := v_sql || ' B.NUM_ITEM NUM_ITEM_E, ';
        v_sql := v_sql || ' B.COD_FIS_JUR COD_FIS_JUR_E, ';
        v_sql := v_sql || ' B.CPF_CGC CPF_CGC_E, ';
        v_sql := v_sql || ' B.COD_NBM COD_NBM_E, ';
        v_sql := v_sql || ' B.COD_CFO COD_CFO_E, ';
        v_sql := v_sql || ' B.COD_NATUREZA_OP COD_NATUREZA_OP_E, ';
        v_sql := v_sql || ' B.COD_PRODUTO COD_PRODUTO_E, ';
        v_sql := v_sql || ' B.VLR_CONTAB_ITEM, ';
        v_sql := v_sql || ' B.QUANTIDADE QUANTIDADE_E, ';
        v_sql := v_sql || ' B.VLR_UNIT, ';
        v_sql := v_sql || ' B.COD_SITUACAO_B, ';
        v_sql := v_sql || ' B.COD_ESTADO, ';
        v_sql := v_sql || ' B.NUM_CONTROLE_DOCTO, ';
        v_sql := v_sql || ' B.NUM_AUTENTIC_NFE NUM_AUTENTIC_NFE_E, ';
        ---
        v_sql := v_sql || ' C.BASE_ICMS_UNIT, ';
        v_sql := v_sql || ' C.VLR_ICMS_UNIT, ';
        v_sql := v_sql || ' C.ALIQ_ICMS, ';
        v_sql := v_sql || ' C.BASE_ST_UNIT, ';
        v_sql := v_sql || ' C.VLR_ICMS_ST_UNIT, ';
        v_sql := v_sql || ' C.VLR_ICMS_ST_UNIT_AUX, ';
        ---
        v_sql :=
            v_sql || ' DECODE(E.FLAG_CONTROLADO,''C'',''CONTROLADO'',''L'',''LIBERADO'',''OUTRO'') STAT_LIBER_CNTR ,';
        v_sql := v_sql || '              RANK() OVER( ';
        v_sql := v_sql || '                   PARTITION BY A.COD_ESTAB, A.DATA_FISCAL, A.COD_PRODUTO ';
        v_sql :=
               v_sql
            || '                   ORDER BY B.DATA_FISCAL DESC, B.DATA_EMISSAO DESC, B.NUM_DOCFIS, B.DISCRI_ITEM, B.NUM_DOCFIS) V_RANK ';


        ---
        v_sql := v_sql || ' FROM ' || vp_tabela_saida || ' A, ';
        v_sql := v_sql || '      ' || vp_tabela_entrada || ' B, ';
        v_sql := v_sql || '      ' || vp_tabela_nf || ' C, ';
        v_sql := v_sql || '      MSAFI.DSP_INTERFACE_SETUP D, ';
        v_sql := v_sql || '      ' || vp_tab_item || ' E ';
        v_sql := v_sql || ' WHERE A.PROC_ID     = ''' || vp_proc_id || ''' ';
        v_sql := v_sql || '   AND A.COD_EMPRESA = ''' || mcod_empresa || ''' ';
        v_sql := v_sql || '   AND A.COD_ESTAB   = ''' || vp_filial || ''' ';
        v_sql :=
               v_sql
            || '   AND A.DATA_FISCAL BETWEEN TO_DATE('''
            || vp_data_ini
            || ''',''DD/MM/YYYY'') AND TO_DATE('''
            || vp_data_fim
            || ''',''DD/MM/YYYY'') ';
        v_sql := v_sql || '   AND A.DESCR_TOT   = ''ST'' ';
        ---
        v_sql := v_sql || ' AND A.DATA_FISCAL > B.DATA_FISCAL ';
        ---
        v_sql := v_sql || '   AND B.PROC_ID     = A.PROC_ID ';
        v_sql := v_sql || '   AND B.COD_EMPRESA = A.COD_EMPRESA ';
        v_sql := v_sql || '   AND B.COD_ESTAB   = A.COD_ESTAB ';
        v_sql := v_sql || '   AND B.COD_PRODUTO = A.COD_PRODUTO ';
        v_sql := v_sql || '   AND B.COD_FIS_JUR = ''' || vp_cd || ''' ';
        ---
        v_sql := v_sql || '   AND D.COD_EMPRESA         = ''' || mcod_empresa || ''' ';
        v_sql := v_sql || '   AND A.PROC_ID             = C.PROC_ID ';
        v_sql := v_sql || '   AND D.BU_PO1              = C.BUSINESS_UNIT ';
        v_sql := v_sql || '   AND B.NUM_CONTROLE_DOCTO  = C.NF_BRL_ID ';
        v_sql := v_sql || '   AND B.NUM_ITEM            = C.NF_BRL_LINE_NUM ';
        ---
        v_sql := v_sql || '   AND E.COD_PRODUTO = A.COD_PRODUTO ';
        ---
        v_sql := v_sql || '   AND NOT EXISTS (SELECT  ''Y'' ';
        v_sql := v_sql || ' FROM ' || vp_tabela_cartoes || ' C ';
        v_sql := v_sql || ' WHERE C.PROC_ID      = A.PROC_ID';
        v_sql := v_sql || '   AND C.COD_EMPRESA  = A.COD_EMPRESA';
        v_sql := v_sql || '   AND C.COD_ESTAB    = A.COD_ESTAB';
        v_sql := v_sql || '   AND C.UF_ESTAB     = A.UF_ESTAB';
        v_sql := v_sql || '   AND C.DOCTO        = A.DOCTO';
        v_sql := v_sql || '   AND C.COD_PRODUTO  = A.COD_PRODUTO';
        v_sql := v_sql || '   AND C.NUM_ITEM     = A.NUM_ITEM';
        v_sql := v_sql || '   AND C.NUM_DOCFIS   = A.NUM_DOCFIS';
        v_sql := v_sql || '   AND C.DATA_FISCAL  = A.DATA_FISCAL';
        v_sql := v_sql || '   AND C.SERIE_DOCFIS = A.SERIE_DOCFIS)) ';
        v_sql := v_sql || '   WHERE V_RANK = 1 ) ';


        BEGIN
            EXECUTE IMMEDIATE v_sql;

            COMMIT;
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
                              , 3072 )
                     , FALSE );
                --ENVIAR EMAIL DE ERRO-------------------------------------------
                envia_email ( mcod_empresa
                            , vp_data_ini
                            , vp_data_fim
                            , SQLERRM
                            , 'E'
                            , vp_data_hora_ini );
                -----------------------------------------------------------------
                raise_application_error ( -20006
                                        , '!ERRO INSERT GET_ENTRADAS_FILIAL!' );
        END;

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_tabela_cartoes );
    --LOGA('C_ENTR_FILIAL-FIM-' || VP_CD || '->' || VP_FILIAL, FALSE);

    END; --GET_ENTRADAS_FILIAL

    PROCEDURE get_sem_entrada ( vp_proc_id IN NUMBER
                              , vp_filial IN VARCHAR2
                              , vp_data_ini IN VARCHAR2
                              , vp_data_fim IN VARCHAR2
                              , vp_tabela_saida IN VARCHAR2
                              , vp_tabela_cartoes IN VARCHAR2
                              , vp_data_hora_ini IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 4000 );
    BEGIN
        v_sql := 'INSERT /*+APPEND*/ INTO ' || vp_tabela_cartoes || ' ( ';
        v_sql := v_sql || ' SELECT  ''' || vp_proc_id || ''', ';
        v_sql := v_sql || '  ''' || mcod_empresa || ''', ';
        v_sql := v_sql || '  A.COD_ESTAB        , ';
        v_sql := v_sql || '  A.UF_ESTAB         , ';
        v_sql := v_sql || '  A.DOCTO            , ';
        v_sql := v_sql || '  A.COD_PRODUTO      , ';
        v_sql := v_sql || '  A.NUM_ITEM         , ';
        v_sql := v_sql || '  A.DESCR_ITEM       , ';
        v_sql := v_sql || '  A.NUM_DOCFIS       , ';
        v_sql := v_sql || '  A.DATA_FISCAL      , ';
        v_sql := v_sql || '  A.SERIE_DOCFIS     , ';
        v_sql := v_sql || '  A.QUANTIDADE       , ';
        v_sql := v_sql || '  A.COD_NBM          , ';
        v_sql := v_sql || '  A.COD_CFO          , ';
        v_sql := v_sql || '  A.GRUPO_PRODUTO    , ';
        v_sql := v_sql || '  A.VLR_DESCONTO     , ';
        v_sql := v_sql || '  A.VLR_CONTABIL     , ';
        v_sql := v_sql || '  A.NUM_AUTENTIC_NFE , ';
        v_sql := v_sql || '  A.VLR_BASE_ICMS    , ';
        v_sql := v_sql || '  A.VLR_ALIQ_ICMS    , ';
        v_sql := v_sql || '  A.VLR_ICMS         , ';
        v_sql := v_sql || '  A.DESCR_TOT        , ';
        v_sql := v_sql || '  A.AUTORIZADORA     , ';
        v_sql := v_sql || '  A.NOME_VAN         , ';
        v_sql := v_sql || '  A.VLR_PAGO_CARTAO  , ';
        v_sql := v_sql || '  A.FORMA_PAGTO      , ';
        v_sql := v_sql || '  A.NUM_PARCELAS     , ';
        v_sql := v_sql || '  A.CODIGO_APROVACAO , ';
        ----
        v_sql := v_sql || '  '''','; --B.COD_ESTAB,
        v_sql := v_sql || '  NULL,'; --B.DATA_FISCAL,
        v_sql := v_sql || '  '''','; --B.MOVTO_E_S,
        v_sql := v_sql || '  '''','; --B.NORM_DEV,
        v_sql := v_sql || '  '''','; --B.IDENT_DOCTO,
        v_sql := v_sql || '  '''','; --B.IDENT_FIS_JUR,
        v_sql := v_sql || '  '''','; --B.SUB_SERIE_DOCFIS,
        v_sql := v_sql || '  '''','; --B.DISCRI_ITEM,
        v_sql := v_sql || '  NULL,'; --B.DATA_EMISSAO,
        v_sql := v_sql || '  '''','; --B.NUM_DOCFIS,
        v_sql := v_sql || '  '''','; --B.SERIE_DOCFIS,
        v_sql := v_sql || '  0,   '; --B.NUM_ITEM,
        v_sql := v_sql || '  '''','; --B.COD_FIS_JUR,
        v_sql := v_sql || '  '''','; --B.CPF_CGC,
        v_sql := v_sql || '  '''','; --B.COD_NBM,
        v_sql := v_sql || '  '''','; --B.COD_CFO,
        v_sql := v_sql || '  '''','; --B.COD_NATUREZA_OP,
        v_sql := v_sql || '  '''','; --B.COD_PRODUTO,
        v_sql := v_sql || '  0,   '; --B.VLR_CONTAB_ITEM,
        v_sql := v_sql || '  0,   '; --B.QUANTIDADE,
        v_sql := v_sql || '  0,   '; --B.VLR_UNIT,
        v_sql := v_sql || '  '''','; --B.COD_SITUACAO_B,
        v_sql := v_sql || '  '''','; --B.COD_ESTADO,
        v_sql := v_sql || '  '''','; --B.NUM_CONTROLE_DOCTO,
        v_sql := v_sql || '  '''','; --B.NUM_AUTENTIC_NFE,
        v_sql := v_sql || '  0,   '; --BASE_ICMS_UNIT,
        v_sql := v_sql || '  0,   '; --VLR_ICMS_UNIT,
        v_sql := v_sql || '  0,   '; --ALIQ_ICMS,
        v_sql := v_sql || '  0,   '; --BASE_ST_UNIT,
        v_sql := v_sql || '  0,   '; --VLR_ICMS_ST_UNIT
        v_sql := v_sql || '  0,   '; --VLR_ICMS_ST_UNIT_AUX
        v_sql := v_sql || '  '''' '; --STAT_LIBER_CNTR
        v_sql := v_sql || ' FROM ' || vp_tabela_saida || ' A ';
        v_sql := v_sql || ' WHERE A.PROC_ID        = ''' || vp_proc_id || ''' ';
        v_sql := v_sql || '   AND A.COD_EMPRESA = ''' || mcod_empresa || ''' ';
        v_sql := v_sql || '   AND A.COD_ESTAB   = ''' || vp_filial || ''' ';
        v_sql :=
               v_sql
            || '   AND A.DATA_FISCAL BETWEEN TO_DATE('''
            || vp_data_ini
            || ''',''DD/MM/YYYY'') AND TO_DATE('''
            || vp_data_fim
            || ''',''DD/MM/YYYY'') ';
        ---
        v_sql := v_sql || '   AND NOT EXISTS (SELECT  ''Y'' ';
        v_sql := v_sql || ' FROM ' || vp_tabela_cartoes || ' C ';
        v_sql := v_sql || ' WHERE C.PROC_ID      = A.PROC_ID';
        v_sql := v_sql || '   AND C.COD_EMPRESA  = A.COD_EMPRESA';
        v_sql := v_sql || '   AND C.COD_ESTAB    = A.COD_ESTAB';
        v_sql := v_sql || '   AND C.UF_ESTAB     = A.UF_ESTAB';
        v_sql := v_sql || '   AND C.DOCTO        = A.DOCTO';
        v_sql := v_sql || '   AND C.COD_PRODUTO  = A.COD_PRODUTO';
        v_sql := v_sql || '   AND C.NUM_ITEM     = A.NUM_ITEM';
        v_sql := v_sql || '   AND C.NUM_DOCFIS   = A.NUM_DOCFIS';
        v_sql := v_sql || '   AND C.DATA_FISCAL  = A.DATA_FISCAL';
        v_sql := v_sql || '   AND C.SERIE_DOCFIS = A.SERIE_DOCFIS)) ';

        BEGIN
            EXECUTE IMMEDIATE v_sql;

            COMMIT;
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
                              , 3072 )
                     , FALSE );
                --ENVIAR EMAIL DE ERRO-------------------------------------------
                envia_email ( mcod_empresa
                            , vp_data_ini
                            , vp_data_fim
                            , SQLERRM
                            , 'E'
                            , vp_data_hora_ini );
                -----------------------------------------------------------------
                raise_application_error ( -20007
                                        , '!ERRO INSERT GET_SEM_ENTRADA!' );
        END;

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_tabela_cartoes );
    --LOGA('C_SEM_ENTRADA-FIM-' || VP_FILIAL, FALSE);

    END; --GET_SEM_ENTRADA

    PROCEDURE load_nf_people ( vp_proc_id IN VARCHAR2
                             , vp_cod_empresa IN VARCHAR2
                             , vp_tab_entrada_c IN VARCHAR2
                             , vp_tab_entrada_f IN VARCHAR2
                             , vp_tab_entrada_co IN VARCHAR2
                             , vp_tabela_nf   OUT VARCHAR2
                             , vp_tabela_saida IN VARCHAR2
                             , vp_tab_item   OUT VARCHAR2
                             , vp_data_inicial IN VARCHAR2
                             , vp_data_final IN VARCHAR2
                             , vp_data_hora_ini IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 4000 );
        v_ins VARCHAR2 ( 500 );
        c_nf SYS_REFCURSOR;

        TYPE cur_tab_nf IS RECORD
        (
            proc_id NUMBER ( 30 )
          , business_unit VARCHAR2 ( 6 )
          , nf_brl_id VARCHAR2 ( 12 )
          , nf_brl_line_num NUMBER ( 3 )
          , base_icms_unit NUMBER ( 17, 2 )
          , vlr_icms_unit NUMBER ( 17, 2 )
          , aliq_icms NUMBER ( 17, 2 )
          , base_st_unit NUMBER ( 17, 2 )
          , vlr_icms_st_unit NUMBER ( 17, 2 )
          , vlr_icms_st_unit_aux NUMBER ( 17, 2 )
        );

        TYPE c_tab_nf IS TABLE OF cur_tab_nf;

        tab_nf c_tab_nf;
    BEGIN
        loga ( 'NF PEOPLE-INI'
             , FALSE );

        vp_tabela_nf := 'DPSP_MSAF_NF_' || vp_proc_id;

        v_sql := 'CREATE TABLE ' || vp_tabela_nf || ' ( ';
        v_sql := v_sql || ' PROC_ID              NUMBER(30), ';
        v_sql := v_sql || ' BUSINESS_UNIT        VARCHAR2(6), ';
        v_sql := v_sql || ' NF_BRL_ID            VARCHAR2(12), ';
        v_sql := v_sql || ' NF_BRL_LINE_NUM      NUMBER(3), ';
        v_sql := v_sql || ' BASE_ICMS_UNIT       NUMBER(17,4), ';
        v_sql := v_sql || ' VLR_ICMS_UNIT        NUMBER(17,4), ';
        v_sql := v_sql || ' ALIQ_ICMS            NUMBER(7,2), ';
        v_sql := v_sql || ' BASE_ST_UNIT         NUMBER(17,4), ';
        v_sql := v_sql || ' VLR_ICMS_ST_UNIT     NUMBER(17,4), ';
        v_sql := v_sql || ' VLR_ICMS_ST_UNIT_AUX NUMBER(17,4)) ';
        v_sql := v_sql || ' PCTFREE     10 ';
        v_sql := v_sql || ' TABLESPACE ' || v_tablespace_table;

        EXECUTE IMMEDIATE v_sql;

        IF ( vp_tab_entrada_c IS NOT NULL ) THEN
            v_sql := ' SELECT DISTINCT ';
            v_sql := v_sql || '  ' || vp_proc_id || ', ';
            v_sql := v_sql || '  A.BUSINESS_UNIT, ';
            v_sql := v_sql || '  A.NF_BRL_ID, ';
            v_sql := v_sql || '  A.NF_BRL_LINE_NUM, ';
            v_sql := v_sql || '  A.BASE_ICMS_UNIT, ';
            v_sql := v_sql || '  A.VLR_ICMS_UNIT, ';
            v_sql := v_sql || '  A.ALIQ_ICMS, ';
            v_sql := v_sql || '  A.BASE_ST_UNIT, ';
            v_sql := v_sql || '  A.VLR_ICMS_ST_UNIT, ';
            v_sql := v_sql || '  A.VLR_ICMS_ST_UNIT_AUX ';
            v_sql := v_sql || ' FROM ( ';
            v_sql := v_sql || ' SELECT /*+DRIVING_SITE(C)*/ ';
            v_sql := v_sql || '        C.BUSINESS_UNIT, ';
            v_sql := v_sql || '        C.NF_BRL_ID, ';
            v_sql := v_sql || '        C.NF_BRL_LINE_NUM, ';
            v_sql := v_sql || '        C.BASE_ICMS_UNIT, ';
            v_sql := v_sql || '        C.VLR_ICMS_UNIT, ';
            v_sql := v_sql || '        C.ALIQ_ICMS,  ';
            v_sql := v_sql || '        C.BASE_ST_UNIT, ';
            v_sql := v_sql || '        C.VLR_ICMS_ST_UNIT, ';
            v_sql := v_sql || '        C.VLR_ICMS_ST_UNIT_AUX ';
            v_sql := v_sql || ' FROM ' || vp_tab_entrada_c || ' A, ';
            v_sql := v_sql || '      MSAFI.DSP_INTERFACE_SETUP B, ';
            v_sql := v_sql || '     (SELECT C.BUSINESS_UNIT, ';
            v_sql := v_sql || '             C.NF_BRL_ID, ';
            v_sql := v_sql || '             C.NF_BRL_LINE_NUM, ';
            v_sql := v_sql || '             NVL(ROUND(C.ICMSTAX_BRL_BSS/C.QTY_NF_BRL, 4), 0) AS BASE_ICMS_UNIT, ';
            v_sql := v_sql || '             NVL(ROUND(C.ICMSTAX_BRL_AMT/C.QTY_NF_BRL, 4), 0) AS VLR_ICMS_UNIT, ';
            v_sql := v_sql || '             NVL(C.ICMSTAX_BRL_PCT, 0) AS ALIQ_ICMS,  ';
            v_sql :=
                   v_sql
                || '             ROUND(DECODE(NVL(C.DSP_ICMS_BSS_ST, 0), 0, NVL(C.DSP_ICMSSUBBRL_BSS, 0), NVL(C.DSP_ICMS_BSS_ST, 0))/C.QTY_NF_BRL, 4) AS BASE_ST_UNIT, ';
            v_sql :=
                   v_sql
                || '             ROUND(DECODE(NVL(C.DSP_ICMS_AMT_ST, 0), 0, NVL(C.DSP_ICMSSUBBRL_AMT, 0), NVL(C.DSP_ICMS_AMT_ST, 0))/C.QTY_NF_BRL, 4) AS VLR_ICMS_ST_UNIT, ';
            v_sql := v_sql || '             ROUND(NVL(C.ICMSSUB_BRL_AMT,0)/C.QTY_NF_BRL, 4) AS VLR_ICMS_ST_UNIT_AUX ';
            v_sql := v_sql || '      FROM MSAFI.PS_NF_LN_BRL C ) C ';
            v_sql := v_sql || ' WHERE A.PROC_ID             = ''' || vp_proc_id || ''' ';
            v_sql := v_sql || '   AND A.COD_EMPRESA         = ''' || vp_cod_empresa || ''' ';
            v_sql := v_sql || '   AND B.COD_EMPRESA         = A.COD_EMPRESA ';
            v_sql := v_sql || '   AND C.BUSINESS_UNIT       = B.BU_PO1 ';
            v_sql := v_sql || '   AND C.NF_BRL_ID           = A.NUM_CONTROLE_DOCTO ';
            v_sql := v_sql || '   AND C.NF_BRL_LINE_NUM     = A.NUM_ITEM ';
            v_sql := v_sql || '     ) A ';

            OPEN c_nf FOR v_sql;

            LOOP
                FETCH c_nf
                    BULK COLLECT INTO tab_nf
                    LIMIT 100;

                FOR i IN 1 .. tab_nf.COUNT LOOP
                    v_ins :=
                           'INSERT /*+APPEND*/ INTO '
                        || vp_tabela_nf
                        || ' VALUES ('
                        || tab_nf ( i ).proc_id
                        || ','''
                        || tab_nf ( i ).business_unit
                        || ''','''
                        || tab_nf ( i ).nf_brl_id
                        || ''','
                        || tab_nf ( i ).nf_brl_line_num
                        || ',TO_NUMBER('''
                        || tab_nf ( i ).base_icms_unit
                        || '''),TO_NUMBER('''
                        || tab_nf ( i ).vlr_icms_unit
                        || '''),TO_NUMBER('''
                        || tab_nf ( i ).aliq_icms
                        || '''),TO_NUMBER('''
                        || tab_nf ( i ).base_st_unit
                        || '''),TO_NUMBER('''
                        || tab_nf ( i ).vlr_icms_st_unit
                        || '''),TO_NUMBER('''
                        || tab_nf ( i ).vlr_icms_st_unit_aux
                        || '''))';

                    EXECUTE IMMEDIATE v_ins;
                END LOOP;

                tab_nf.delete;

                EXIT WHEN c_nf%NOTFOUND;
            END LOOP;

            COMMIT;

            CLOSE c_nf;
        END IF; --IF (VP_TAB_ENTRADA_C IS NOT NULL) THEN

        IF ( vp_tab_entrada_f IS NOT NULL ) THEN
            v_sql := ' SELECT  DISTINCT ';
            v_sql := v_sql || '         ' || vp_proc_id || ', ';
            v_sql := v_sql || '         A.BUSINESS_UNIT, ';
            v_sql := v_sql || '         A.NF_BRL_ID, ';
            v_sql := v_sql || '         A.NF_BRL_LINE_NUM, ';
            v_sql := v_sql || '         A.BASE_ICMS_UNIT, ';
            v_sql := v_sql || '         A.VLR_ICMS_UNIT, ';
            v_sql := v_sql || '         A.ALIQ_ICMS, ';
            v_sql := v_sql || '         A.BASE_ST_UNIT, ';
            v_sql := v_sql || '         A.VLR_ICMS_ST_UNIT, ';
            v_sql := v_sql || '         A.VLR_ICMS_ST_UNIT_AUX ';
            v_sql := v_sql || ' FROM ( ';
            v_sql := v_sql || '         SELECT /*+DRIVING_SITE(C)*/ ';
            v_sql := v_sql || '                C.BUSINESS_UNIT, ';
            v_sql := v_sql || '                C.NF_BRL_ID, ';
            v_sql := v_sql || '                C.NF_BRL_LINE_NUM, ';
            v_sql := v_sql || '                C.BASE_ICMS_UNIT, ';
            v_sql := v_sql || '                C.VLR_ICMS_UNIT, ';
            v_sql := v_sql || '                C.ALIQ_ICMS,  ';
            v_sql := v_sql || '                C.BASE_ST_UNIT, ';
            v_sql := v_sql || '                C.VLR_ICMS_ST_UNIT, ';
            v_sql := v_sql || '                C.VLR_ICMS_ST_UNIT_AUX ';
            v_sql := v_sql || '         FROM ' || vp_tab_entrada_f || ' A, ';
            v_sql := v_sql || '              MSAFI.DSP_INTERFACE_SETUP B, ';
            v_sql := v_sql || '             (SELECT C.BUSINESS_UNIT, ';
            v_sql := v_sql || '                     C.NF_BRL_ID, ';
            v_sql := v_sql || '                     C.NF_BRL_LINE_NUM, ';
            v_sql :=
                v_sql || '                     NVL(ROUND(C.ICMSTAX_BRL_BSS/C.QTY_NF_BRL, 4), 0) AS BASE_ICMS_UNIT, ';
            v_sql :=
                v_sql || '                     NVL(ROUND(C.ICMSTAX_BRL_AMT/C.QTY_NF_BRL, 4), 0) AS VLR_ICMS_UNIT, ';
            v_sql := v_sql || '                     NVL(C.ICMSTAX_BRL_PCT, 0) AS ALIQ_ICMS,  ';
            v_sql :=
                   v_sql
                || '                     ROUND(DECODE(NVL(C.DSP_ICMS_BSS_ST, 0), 0, NVL(C.DSP_ICMSSUBBRL_BSS, 0), NVL(C.DSP_ICMS_BSS_ST, 0))/C.QTY_NF_BRL, 4) AS BASE_ST_UNIT, ';
            v_sql :=
                   v_sql
                || '                     ROUND(DECODE(NVL(C.DSP_ICMS_AMT_ST, 0), 0, NVL(C.DSP_ICMSSUBBRL_AMT, 0), NVL(C.DSP_ICMS_AMT_ST, 0))/C.QTY_NF_BRL, 4) AS VLR_ICMS_ST_UNIT, ';
            v_sql :=
                   v_sql
                || '                     ROUND(NVL(C.ICMSSUB_BRL_AMT,0)/C.QTY_NF_BRL, 4) AS VLR_ICMS_ST_UNIT_AUX ';
            v_sql := v_sql || '              FROM MSAFI.PS_NF_LN_BRL C ) C ';
            v_sql := v_sql || '         WHERE A.PROC_ID             = ''' || vp_proc_id || ''' ';
            v_sql := v_sql || ' AND A.COD_EMPRESA         = ''' || vp_cod_empresa || ''' ';
            v_sql := v_sql || ' AND B.COD_EMPRESA         = A.COD_EMPRESA ';
            v_sql := v_sql || ' AND C.BUSINESS_UNIT       = B.BU_PO1 ';
            v_sql := v_sql || ' AND C.NF_BRL_ID = A.NUM_CONTROLE_DOCTO ';
            v_sql := v_sql || ' AND C.NF_BRL_LINE_NUM     = A.NUM_ITEM ';
            v_sql := v_sql || '     ) A ';
            v_sql := v_sql || ' WHERE NOT EXISTS (SELECT ''Y'' FROM ' || vp_tabela_nf || ' NF ';
            v_sql := v_sql || ' WHERE NF.PROC_ID = ' || vp_proc_id || ' ';
            v_sql := v_sql || ' AND NF.BUSINESS_UNIT = A.BUSINESS_UNIT ';
            v_sql := v_sql || ' AND NF.NF_BRL_ID = A.NF_BRL_ID ';
            v_sql := v_sql || ' AND NF.NF_BRL_LINE_NUM = A.NF_BRL_LINE_NUM ) ';

            OPEN c_nf FOR v_sql;

            LOOP
                FETCH c_nf
                    BULK COLLECT INTO tab_nf
                    LIMIT 100;

                BEGIN
                    FORALL i IN tab_nf.FIRST .. tab_nf.LAST
                        EXECUTE IMMEDIATE
                               'INSERT /*+APPEND_VALUES*/ INTO '
                            || vp_tabela_nf
                            || ' VALUES (:1, :2, :3, :4, :5, '
                            || ' :6, :7, :8, :9, :10) '
                            USING tab_nf ( i ).proc_id
                                , tab_nf ( i ).business_unit
                                , tab_nf ( i ).nf_brl_id
                                , tab_nf ( i ).nf_brl_line_num
                                , tab_nf ( i ).base_icms_unit
                                , tab_nf ( i ).vlr_icms_unit
                                , tab_nf ( i ).aliq_icms
                                , tab_nf ( i ).base_st_unit
                                , tab_nf ( i ).vlr_icms_st_unit
                                , tab_nf ( i ).vlr_icms_st_unit_aux;
                EXCEPTION
                    WHEN OTHERS THEN
                        loga ( 'SQLERRM: ' || SQLERRM
                             , FALSE );
                        --ENVIAR EMAIL DE ERRO-------------------------------------------
                        envia_email ( mcod_empresa
                                    , vp_data_inicial
                                    , vp_data_final
                                    , SQLERRM
                                    , 'E'
                                    , vp_data_hora_ini );
                        -----------------------------------------------------------------
                        raise_application_error ( -20004
                                                , '!ERRO INSERT NF PEOPLE F!' );
                END;

                COMMIT;
                tab_nf.delete;

                EXIT WHEN c_nf%NOTFOUND;
            END LOOP;

            COMMIT;

            CLOSE c_nf;
        END IF; --IF (VP_TAB_ENTRADA_F IS NOT NULL) THEN

        save_tmp_control ( vp_proc_id
                         , vp_tabela_nf );

        v_sql := 'CREATE UNIQUE INDEX PK_DPSP_NF_' || vp_proc_id || ' ON ' || vp_tabela_nf || ' ';
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || ' PROC_ID         ASC, ';
        v_sql := v_sql || ' BUSINESS_UNIT   ASC, ';
        v_sql := v_sql || ' NF_BRL_ID       ASC, ';
        v_sql := v_sql || ' NF_BRL_LINE_NUM ASC ';
        v_sql := v_sql || ' ) ';
        v_sql := v_sql || ' PCTFREE 10';
        v_sql := v_sql || ' TABLESPACE ' || v_tablespace_index;

        EXECUTE IMMEDIATE v_sql;

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_tabela_nf );

        ---TABELA DE ITEM - CONTROLADO OU NAO------------------
        vp_tab_item := 'DPSP_ITEM_' || vp_proc_id;

        v_sql := 'CREATE TABLE ' || vp_tab_item || ' ( ';
        v_sql := v_sql || ' COD_PRODUTO      VARCHAR2(25), ';
        v_sql := v_sql || ' FLAG_CONTROLADO  VARCHAR2(6)) ';
        v_sql := v_sql || ' PCTFREE     10 ';
        v_sql := v_sql || ' TABLESPACE ' || v_tablespace_table;


        EXECUTE IMMEDIATE v_sql;

        v_sql := 'INSERT /*+APPEND*/ INTO ' || vp_tab_item || ' ( ';
        v_sql := v_sql || ' SELECT /*+DRIVING_SITE(ITEM)*/ DISTINCT ';
        v_sql := v_sql || ' ITEM.INV_ITEM_ID, ITEM.LIBER_CNTR_DSP ';
        v_sql := v_sql || ' FROM (SELECT INV_ITEM_ID, LIBER_CNTR_DSP FROM MSAFI.PS_ATRB_OPER_DSP) ITEM, ';
        v_sql := v_sql || ' ' || vp_tabela_saida || ' S ';
        v_sql := v_sql || ' WHERE S.COD_PRODUTO = ITEM.INV_ITEM_ID ';
        v_sql := v_sql || ' ) ';

        EXECUTE IMMEDIATE v_sql;

        COMMIT;

        save_tmp_control ( vp_proc_id
                         , vp_tab_item );

        v_sql := 'CREATE UNIQUE INDEX PK_DPSP_IT' || vp_proc_id || ' ON ' || vp_tab_item || ' ';
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || ' COD_PRODUTO ASC ';
        v_sql := v_sql || ' ) ';
        v_sql := v_sql || ' PCTFREE 10';
        v_sql := v_sql || ' TABLESPACE ' || v_tablespace_index;

        EXECUTE IMMEDIATE v_sql;

        ------------------------------------------------------

        loga ( 'NF PEOPLE-FIM'
             , FALSE );
    END;

    PROCEDURE delete_tbl ( p_i_cod_estab IN VARCHAR2
                         , p_i_data_ini IN DATE
                         , p_i_data_fim IN DATE )
    IS
    BEGIN
        DELETE msafi.dpsp_msaf_cartoes
         WHERE cod_empresa = mcod_empresa
           AND cod_estab = p_i_cod_estab
           AND data_fiscal BETWEEN p_i_data_ini AND p_i_data_fim;

        COMMIT;
    END;

    PROCEDURE get_id_param ( vp_id_param   OUT NUMBER
                           , vp_data_final IN DATE )
    IS
    BEGIN
        -- 1 - CHECAR SE EXISTE PERFIL NO MES PARA AS TAXAS DE CARTAO
        BEGIN
            SELECT id_parametros
              INTO vp_id_param
              FROM msaf.fpar_parametros
             WHERE nome_framework = 'DPSP_CARTOES_CPAR' --NOME DO FRAMEWORK
               AND descricao = TO_CHAR ( vp_data_final
                                       , 'YYYY/MM' );
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                INSERT INTO msaf.fpar_parametros ( nome_framework
                                                 , descricao )
                     VALUES ( 'DPSP_CARTOES_CPAR'
                            , TO_CHAR ( vp_data_final
                                      , 'YYYY/MM' ) );

                COMMIT;

                ---
                SELECT MAX ( id_parametros )
                  INTO vp_id_param
                  FROM msaf.fpar_parametros
                 WHERE nome_framework = 'DPSP_CARTOES_CPAR' --NOME DO FRAMEWORK
                   AND descricao = TO_CHAR ( vp_data_final
                                           , 'YYYY/MM' );
            WHEN OTHERS THEN
                SELECT MAX ( id_parametros )
                  INTO vp_id_param
                  FROM msaf.fpar_parametros
                 WHERE nome_framework = 'DPSP_CARTOES_CPAR' --NOME DO FRAMEWORK
                   AND descricao = TO_CHAR ( vp_data_final
                                           , 'YYYY/MM' );
        END;
    END;

    PROCEDURE update_cartao_params ( vp_id_param IN NUMBER
                                   , vp_cod_empresa IN VARCHAR2
                                   , vp_cod_estab IN VARCHAR2
                                   , vp_data_inicial IN DATE
                                   , vp_data_final IN DATE
                                   , vp_data_hora_ini IN VARCHAR2 )
    IS
        v_last_periodo VARCHAR2 ( 7 );
        v_existe_zero VARCHAR2 ( 1 );
        v_ins VARCHAR2 ( 3000 );
    BEGIN
        loga ( 'UPDATE_CARTAO_PARAMS-INI-' || vp_cod_estab
             , FALSE );

        ---CARREGAR RELACIONAMENTOS ENTRE AUTORIZADORAs X VANs
        v_ins := 'INSERT /*+APPEND*/ INTO MSAFI.DPSP_MSAF_CARTOES_FPAR ( ';
        v_ins := v_ins || 'SELECT DISTINCT ''' || vp_cod_empresa || ''', TRIM(A.NOME_VAN), ';
        v_ins := v_ins || '       CASE WHEN CODIGO_FORMA = ''11'' THEN ';
        v_ins :=
               v_ins
            || '       	DECODE(A.NUMERO_PARCELAS,''0'',TRIM(A.NOME_AUTORIZADORA) || ''(V)'', TRIM(A.NOME_AUTORIZADORA) || ''(P)'') ';
        v_ins := v_ins || '       ELSE ';
        v_ins := v_ins || '       	TRIM(A.NOME_AUTORIZADORA) ';
        v_ins := v_ins || '       END AS NOME_AUTORIZADORA ';
        v_ins := v_ins || 'FROM MSAFI.DPSP_MSAF_PAGTO_CARTOES_jj A ';
        v_ins := v_ins || 'WHERE A.COD_EMPRESA = ''' || vp_cod_empresa || ''' ';
        v_ins := v_ins || '  AND A.COD_ESTAB   = ''' || vp_cod_estab || ''' ';
        v_ins :=
               v_ins
            || '  AND A.DATA_TRANSACAO BETWEEN TO_DATE('''
            || TO_CHAR ( vp_data_inicial
                       , 'DDMMYYYY' )
            || ''',''DDMMYYYY'') AND TO_DATE('''
            || TO_CHAR ( vp_data_final
                       , 'DDMMYYYY' )
            || ''',''DDMMYYYY'') ';
        v_ins := v_ins || '  AND NOT EXISTS (SELECT ''Y'' ';
        v_ins := v_ins || '                  FROM MSAFI.DPSP_MSAF_CARTOES_FPAR B ';
        v_ins := v_ins || ' 				   WHERE B.COD_EMPRESA 		   = TRIM(A.COD_EMPRESA) ';
        v_ins := v_ins || ' 				     AND NVL(B.NOME_VAN,''-'') = NVL(TRIM(A.NOME_VAN),''-'') ';
        v_ins := v_ins || '					 AND NVL(B.NOME_AUTORIZADORA,''-1'')   = CASE WHEN CODIGO_FORMA = ''11'' THEN ';
        v_ins :=
               v_ins
            || '													DECODE(A.NUMERO_PARCELAS,''0'',TRIM(A.NOME_AUTORIZADORA) || ''(V)'', TRIM(A.NOME_AUTORIZADORA) || ''(P)'') ';
        v_ins := v_ins || '											     ELSE ';
        v_ins := v_ins || '													NVL(TRIM(A.NOME_AUTORIZADORA),''-1'') ';
        v_ins := v_ins || '											     END)) ';

        BEGIN
            EXECUTE IMMEDIATE v_ins;

            COMMIT;
        EXCEPTION
            WHEN OTHERS THEN
                loga ( 'SQLERRM: ' || SQLERRM
                     , FALSE );
                loga ( SUBSTR ( v_ins
                              , 1
                              , 1024 )
                     , FALSE );
                loga ( SUBSTR ( v_ins
                              , 1024
                              , 1024 )
                     , FALSE );
                --ENVIAR EMAIL DE ERRO-------------------------------------------
                envia_email ( mcod_empresa
                            , vp_data_inicial
                            , vp_data_final
                            , SQLERRM
                            , 'E'
                            , vp_data_hora_ini );
                -----------------------------------------------------------------
                raise_application_error ( -20004
                                        , 'ERRO INSERT FPAR CARTOES' );
        END;

        ---
        INSERT INTO msaf.fpar_param_det ( id_parametro
                                        , nome_param
                                        , conteudo
                                        , valor
                                        , descricao )
            ( SELECT vp_id_param
                   , 'INTERF'
                   , SUBSTR ( TRIM ( a.nome_autorizadora ) || '-' || TRIM ( a.nome_van )
                            , 1
                            , 50 )
                   , '0'
                   , CASE
                         WHEN INSTR ( TRIM ( a.nome_autorizadora )
                                    , '(P)' ) > 0 THEN
                             'PRAZO'
                         WHEN INSTR ( TRIM ( a.nome_autorizadora )
                                    , '(V)' ) > 0 THEN
                             'À VISTA'
                         ELSE
                             'DÉBITO'
                     END
                FROM msafi.dpsp_msaf_cartoes_fpar a
               WHERE NOT EXISTS
                         (SELECT 'Y'
                            FROM msaf.fpar_param_det b
                           WHERE b.id_parametro = vp_id_param
                             AND b.conteudo = SUBSTR ( TRIM ( a.nome_autorizadora ) || '-' || TRIM ( a.nome_van )
                                                     , 1
                                                     , 50 )
                             AND b.descricao = CASE
                                                   WHEN INSTR ( TRIM ( a.nome_autorizadora )
                                                              , '(P)' ) > 0 THEN
                                                       'PRAZO'
                                                   WHEN INSTR ( TRIM ( a.nome_autorizadora )
                                                              , '(V)' ) > 0 THEN
                                                       'À VISTA'
                                                   ELSE
                                                       'DÉBITO'
                                               END) );

        COMMIT;

        ---CHECAR PERIODO MAIS RECENTE CARREGADO DAS TAXAS NO MESMO ANO DO PROCESSAMENTO
        BEGIN
            SELECT MAX ( descricao )
              INTO v_last_periodo
              FROM msaf.fpar_parametros
             WHERE nome_framework = 'DPSP_CARTOES_CPAR'
               AND descricao <> TO_CHAR ( vp_data_final
                                        , 'YYYY/MM' )
               AND TRIM ( SUBSTR ( descricao
                                 , 1
                                 , 4 ) ) = TO_CHAR ( vp_data_final
                                                   , 'YYYY' );
        EXCEPTION
            WHEN OTHERS THEN
                v_last_periodo := 'NONE';
                loga (
                       'NAO FOI ENCONTRADO PERIODO PARA TAXAS DE CARTAO NO MESMO ANO DO PROCESSAMENTO, CHECAR NO HISTORICO!'
                     , FALSE
                );
        END;

        IF ( v_last_periodo = 'NONE' ) THEN
            ---CHECAR PERIODO MAIS RECENTE CARREGADO DAS TAXAS
            BEGIN
                SELECT MAX ( descricao )
                  INTO v_last_periodo
                  FROM msaf.fpar_parametros
                 WHERE nome_framework = 'DPSP_CARTOES_CPAR'
                   AND descricao <> TO_CHAR ( vp_data_final
                                            , 'YYYY/MM' );
            EXCEPTION
                WHEN OTHERS THEN
                    v_last_periodo := 'NONE';
                    loga ( 'NAO FOI ENCONTRADO PERIODO PARA TAXAS DE CARTAO NO HISTORICO!'
                         , FALSE );
            END;
        END IF;

        ---PREENCHER TAXAS ZERADAS COM VALOR PADRAO DO ULTIMO CADASTRO
        IF ( v_last_periodo <> 'NONE' ) THEN
            UPDATE msaf.fpar_param_det a
               SET a.valor =
                       NVL ( ( SELECT b.valor
                                 FROM msaf.fpar_param_det b
                                    , msaf.fpar_parametros c
                                WHERE c.id_parametros = b.id_parametro
                                  AND c.nome_framework = 'DPSP_CARTOES_CPAR'
                                  AND c.descricao = v_last_periodo
                                  AND b.nome_param = 'INTERF'
                                  AND b.conteudo = a.conteudo )
                           , 0 )
             WHERE a.id_parametro = vp_id_param
               AND a.valor = 0
               AND a.nome_param = 'INTERF';

            COMMIT;

            ---
            --CHECAR SE EXISTE AINDA TAXA ZERADA -> SE EXISTIR, ENCERRAR PROGRAMA
            BEGIN
                SELECT 'Y'
                  INTO v_existe_zero
                  FROM msaf.fpar_param_det b
                     , msaf.fpar_parametros c
                 WHERE c.id_parametros = b.id_parametro
                   AND c.nome_framework = 'DPSP_CARTOES_CPAR'
                   AND c.descricao = TO_CHAR ( vp_data_final
                                             , 'YYYY/MM' )
                   AND b.nome_param = 'INTERF'
                   AND b.valor = 0
                   AND b.id_parametro = vp_id_param;
            EXCEPTION
                WHEN OTHERS THEN
                    v_existe_zero := 'N';
            END;

            ---
            IF ( v_existe_zero = 'Y' ) THEN
                lib_proc.add_log ( 'TAXA DE CARTAO IGUAL A ZERO, VERIFIQUE O SETUP ANTES DE CONTINUAR'
                                 , 0 );
                lib_proc.add ( 'ERRO' );
                lib_proc.add ( 'TAXA DE CARTAO IGUAL A ZERO, VERIFIQUE O SETUP ANTES DE CONTINUAR' );
                raise_application_error (
                                          -20001
                                        , '!ERRO - TAXA DE CARTAO IGUAL A ZERO, VERIFIQUE O SETUP ANTES DE CONTINUAR!'
                );
            END IF;
        END IF;

        loga ( 'UPDATE_CARTAO_PARAMS-FIM-' || vp_cod_estab
             , FALSE );
    END;

    PROCEDURE delete_temp_tbl ( p_i_proc_instance IN VARCHAR2
                              , vp_nome_tabela_aliq IN VARCHAR2
                              , vp_nome_tabela_pmc IN VARCHAR2
                              , vp_tab_entrada_c IN VARCHAR2
                              , vp_tab_entrada_f IN VARCHAR2
                              , vp_tab_entrada_co IN VARCHAR2
                              , vp_tabela_saida IN VARCHAR2
                              , vp_tabela_nf IN VARCHAR2
                              , vp_tabela_pmc_mva IN VARCHAR2
                              , vp_tab_item IN VARCHAR2 )
    IS
    BEGIN
        BEGIN
            EXECUTE IMMEDIATE 'DROP TABLE ' || vp_nome_tabela_aliq;
        EXCEPTION
            WHEN OTHERS THEN
                loga ( 'LIMPA TEMP1 ' || vp_nome_tabela_aliq
                     , FALSE );
        END;

        ---
        BEGIN
            EXECUTE IMMEDIATE 'DROP TABLE ' || vp_tab_entrada_c;
        EXCEPTION
            WHEN OTHERS THEN
                loga ( 'LIMPA TEMP2 ' || vp_tab_entrada_c
                     , FALSE );
        END;

        ---
        BEGIN
            EXECUTE IMMEDIATE 'DROP TABLE ' || vp_tab_entrada_f;
        EXCEPTION
            WHEN OTHERS THEN
                loga ( 'LIMPA TEMP3 ' || vp_tab_entrada_f
                     , FALSE );
        END;

        ---
        BEGIN
            EXECUTE IMMEDIATE 'DROP TABLE ' || vp_tabela_saida;
        EXCEPTION
            WHEN OTHERS THEN
                loga ( 'LIMPA TEMP4 ' || vp_tabela_saida
                     , FALSE );
        END;

        ---
        BEGIN
            EXECUTE IMMEDIATE 'DROP TABLE ' || vp_tabela_nf;
        EXCEPTION
            WHEN OTHERS THEN
                loga ( 'LIMPA TEMP5 ' || vp_tabela_nf
                     , FALSE );
        END;

        ---
        BEGIN
            EXECUTE IMMEDIATE 'DROP TABLE ' || vp_tabela_pmc_mva;
        EXCEPTION
            WHEN OTHERS THEN
                loga ( 'LIMPA TEMP6 ' || vp_tabela_pmc_mva
                     , FALSE );
        END;

        ---
        BEGIN
            EXECUTE IMMEDIATE 'DROP TABLE ' || vp_tab_item;
        EXCEPTION
            WHEN OTHERS THEN
                loga ( 'LIMPA TEMP7 ' || vp_tab_item
                     , FALSE );
        END;

        --- REMOVER NOME DA TMP DO CONTROLE
        del_tmp_control ( p_i_proc_instance
                        , vp_nome_tabela_aliq );
        del_tmp_control ( p_i_proc_instance
                        , vp_tab_entrada_c );
        del_tmp_control ( p_i_proc_instance
                        , vp_tab_entrada_f );
        del_tmp_control ( p_i_proc_instance
                        , vp_tabela_saida );
        del_tmp_control ( p_i_proc_instance
                        , vp_tabela_nf );
        del_tmp_control ( p_i_proc_instance
                        , vp_tabela_pmc_mva );
        del_tmp_control ( p_i_proc_instance
                        , vp_tab_item );

        --- CHECAR TMPS DE PROCESSOS INTERROMPIDOS E DROPAR
        drop_old_tmp ( p_i_proc_instance );
    END; --PROCEDURE DELETE_TEMP_TBL

    PROCEDURE executar_lote ( p_data_ini DATE
                            , p_data_fim DATE
                            , p_origem1 VARCHAR2
                            , p_cd1 VARCHAR2
                            , p_origem2 VARCHAR2
                            , p_cd2 VARCHAR2
                            , p_origem3 VARCHAR2
                            , p_cd3 VARCHAR2
                            , p_origem4 VARCHAR2
                            , p_cd4 VARCHAR2
                            , p_uf VARCHAR2
                            , p_empresa VARCHAR2
                            , p_usuario VARCHAR2
                            , p_procorig VARCHAR2
                            , p_lojas lib_proc.vartab )
    IS
        mproc_id INTEGER;
    BEGIN
        lib_parametros.salvar ( 'EMPRESA'
                              , p_empresa );
        lib_parametros.salvar ( 'USUARIO'
                              , p_usuario );
        lib_parametros.salvar ( 'PROCORIG'
                              , p_procorig );
        lib_parametros.salvar ( 'PDESC'
                              , 'Processamento em LOTE' || CHR ( 10 ) );

        mproc_id :=
            executar ( p_data_ini
                     , p_data_fim
                     , p_origem1
                     , p_cd1
                     , p_origem2
                     , p_cd2
                     , p_origem3
                     , p_cd3
                     , p_origem4
                     , p_cd4
                     , p_uf
                     , p_lojas );
    END;

    FUNCTION executar ( p_data_ini DATE
                      , p_data_fim DATE
                      , p_origem1 VARCHAR2
                      , p_cd1 VARCHAR2
                      , p_origem2 VARCHAR2
                      , p_cd2 VARCHAR2
                      , p_origem3 VARCHAR2
                      , p_cd3 VARCHAR2
                      , p_origem4 VARCHAR2
                      , p_cd4 VARCHAR2
                      , p_uf VARCHAR2
                      , p_lojas lib_proc.vartab )
        RETURN INTEGER
    IS
        v_sql VARCHAR2 ( 12000 );
        mproc_id INTEGER;
        i1 INTEGER;
        v_proc_status NUMBER := 0;
        v_s_proc_status VARCHAR2 ( 16 );

        v_txt_temp VARCHAR2 ( 1024 ) := '';
        v_txt_basico VARCHAR2 ( 256 ) := '';

        TYPE a_estabs_t IS TABLE OF VARCHAR2 ( 6 );

        a_estabs a_estabs_t := a_estabs_t ( );

        --Variaveis genericas
        v_text01 VARCHAR2 ( 6000 );
        v_sep VARCHAR2 ( 1 ) := CHR ( 9 );
        p_proc_instance VARCHAR2 ( 30 );

        --
        TYPE cur_typ IS REF CURSOR;

        cr_cup cur_typ;

        --TABELAS TEMP
        v_nome_tabela_aliq VARCHAR2 ( 30 );
        v_tab_entrada_c VARCHAR2 ( 30 );
        v_tab_entrada_f VARCHAR2 ( 30 );
        v_tab_entrada_f_aux VARCHAR2 ( 30 );
        v_tabela_saida VARCHAR2 ( 30 );
        v_tabela_prod_saida VARCHAR2 ( 30 );
        v_tabela_nf VARCHAR2 ( 30 );
        v_tabela_cartoes VARCHAR2 ( 30 );
        v_tab_item VARCHAR2 ( 30 );
        ---
        v_result VARCHAR2 ( 10000 );
        v_id_param NUMBER;
        v_data_hora_ini VARCHAR2 ( 20 );

        ------------------------------------------------------------------------------------------------------------------------------------------------------
        --RANGE DE DATAS PARA BUSCAR VENDAS
        v_data_inicial DATE := p_data_ini; -- DATA INICIAL
        v_data_final DATE := p_data_fim; -- DATA FINAL

        ------------------------------------------------------------------------------------------------------------------------------------------------------

        --CURSOR AUXILIAR
        CURSOR c_datas ( p_i_data_inicial IN DATE
                       , p_i_data_final IN DATE )
        IS
            SELECT   b.data_fiscal AS data_normal
                FROM (SELECT p_i_data_inicial + ( ROWNUM - 1 ) AS data_fiscal
                        FROM all_objects
                       WHERE ROWNUM <= (p_i_data_final - p_i_data_inicial + 1)) b
            ORDER BY b.data_fiscal;

        --
        t_idx NUMBER := 0;

        mproc_id_orig INTEGER := 0;

        mdesc VARCHAR2 ( 100 );
    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS='',.'' ';

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING = FORCE';

        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        mnm_usuario := lib_parametros.recuperar ( 'USUARIO' );
        mproc_id_orig := lib_parametros.recuperar ( 'PROCORIG' );
        mdesc := lib_parametros.recuperar ( 'PDESC' );

        mdesc :=
               mdesc
            || 'Data Inicial: '
            || v_data_inicial
            || CHR ( 10 )
            || 'Data Final: '
            || v_data_final
            || CHR ( 10 )
            || 'UF: '
            || p_uf
            || ( CASE WHEN mdesc IS NOT NULL THEN CHR ( 10 ) || 'Estabelecimento: ' || p_lojas ( p_lojas.FIRST ) END );

        mproc_id_o :=
            lib_proc.new ( psp_nome => $$plsql_unit
                         , pdescricao => mdesc );
        lib_parametros.salvar ( 'MPROC_ID'
                              , mproc_id_o );
        mproc_id := lib_parametros.recuperar ( 'MPROC_ID' );



        --====================================================
        -- PROC_ID ORIGEM
        --====================================================
        dbms_application_info.set_module ( $$plsql_unit
                                         , 'PROC_ID_ORIG: ' || mproc_id_o || ' ' || mcod_empresa );

        --MARCAR INCIO DA EXECUCAO
        v_data_hora_ini :=
            TO_CHAR ( SYSDATE
                    , 'DD/MM/YYYY HH24:MI.SS' );


        --====================================================

        lib_proc.add_tipo ( mproc_id
                          , 1
                          ,    TO_CHAR ( SYSDATE
                                       , 'YYYYMMDDHH24MISS' )
                            || '_RESSARCIMENTO_CARTOES'
                          , 1 );

        lib_proc.add_header ( 'Executar processamento do credito de Cartoes'
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



        --GERAR CHAVE PROC_ID
        SELECT ROUND ( dbms_random.VALUE ( 10000000000000
                                         , 999999999999999 ) )
          INTO p_proc_instance
          FROM DUAL;

        ---------------------



        /*MSAFI.DSP_CONTROL.CREATEPROCESS(P_PROC_INSTANCE --P_I_PROCID            IN VARCHAR2             , --VARCHAR2(16)
                                       ,
                                        $$PLSQL_UNIT --P_I_PROC_DESCR        IN VARCHAR2             , --VARCHAR2(64)
                                       ,
                                        NULL --P_I_DATA_INI          IN DATE     DEFAULT NULL,
                                       ,
                                        NULL --P_I_DATA_FIM          IN DATE     DEFAULT NULL,
                                       ,
                                        P_ORIGEM1 --P_I_DETALHES1         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                       ,
                                        V_DATA_INICIAL --P_I_DETALHES2         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                       ,
                                        V_DATA_FINAL --P_I_DETALHES3         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                       ,
                                        NULL --P_I_DETALHES4         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                       ,
                                        MNM_USUARIO --P_I_USER              IN VARCHAR2 DEFAULT NULL  --VARCHAR2(64)
                                        );
        */
        v_proc_status := 1; --EM PROCESSO


        loga ( '>>> INICIO DO PROCESSAMENTO...' || p_proc_instance
             , FALSE );
        loga ( '>> DT INICIAL: ' || v_data_inicial
             , FALSE );
        loga ( '>> DT FINAL: ' || v_data_final
             , FALSE );
        loga ( '>> UF: ' || p_uf
             , FALSE );
        loga ( '>> Origem1: ' || p_origem1
             , FALSE );
        loga ( '>> CD1: ' || p_cd1
             , FALSE );
        loga ( '>> Origem2: ' || p_origem2
             , FALSE );
        loga ( '>> CD2: ' || p_cd2
             , FALSE );
        loga ( '>> Origem3: ' || p_origem3
             , FALSE );
        loga ( '>> CD3: ' || p_cd3
             , FALSE );
        loga ( '>> Origem4: ' || p_origem4
             , FALSE );
        loga ( '>> CD4: ' || p_cd4
             , FALSE );

        --====================================================
        -- PROC_ID ORIGEM
        --====================================================
        dbms_application_info.set_module ( $$plsql_unit
                                         , 'PROC_ID: ' || mproc_id );

        IF msafi.get_trava_info ( 'CARTOES'
                                , TO_CHAR ( v_data_inicial
                                          , 'YYYY/MM' ) ) = 'S' THEN
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

        --BUSCAR ID PARAMETRO DO PERFIL
        get_id_param ( v_id_param
                     , v_data_final );

        --==================================
        --PREPARAR LOJAS SP
        --================================
        IF ( p_lojas.COUNT > 0 ) THEN
            i1 := p_lojas.FIRST;

            WHILE i1 IS NOT NULL LOOP
                a_estabs.EXTEND ( );
                a_estabs ( a_estabs.LAST ) := p_lojas ( i1 );
                i1 := p_lojas.NEXT ( i1 );
            END LOOP;
        ELSE
            FOR c1 IN ( SELECT cod_estab
                          FROM msafi.dsp_estabelecimento
                         WHERE cod_empresa = mcod_empresa
                           AND tipo = 'L'
                           AND cod_estado = 'SP' ) LOOP
                a_estabs.EXTEND ( );
                a_estabs ( a_estabs.LAST ) := c1.cod_estab;
            END LOOP;
        END IF;

        --CRIAR TABELA DE SAIDA TMP
        create_tab_saida ( p_proc_instance
                         , v_tabela_saida );
        save_tmp_control ( p_proc_instance
                         , v_tabela_saida );


        create_tab_prod_saida ( p_proc_instance
                              , v_tabela_prod_saida );
        save_tmp_control ( p_proc_instance
                         , v_tabela_prod_saida );
        create_tab_prod_saida_idx ( p_proc_instance
                                  , v_tabela_prod_saida );


        loga ( '-----------------------------------'
             , FALSE );



        --==================================
        --INICIO LOOP POR ESTAB - CARREGAR SAIDAS
        --==================================
        FOR i IN 1 .. a_estabs.COUNT LOOP
            loga ( '>> ESTAB: ' || a_estabs ( i )
                 , FALSE );

            load_dados_cartoes ( a_estabs ( i )
                               , v_data_inicial
                               , v_data_final
                               , v_data_hora_ini );

            load_saidas ( p_proc_instance
                        , a_estabs ( i )
                        , v_data_inicial
                        , v_data_final
                        , v_tabela_saida
                        , v_data_hora_ini );

            update_cartao_params ( v_id_param
                                 , mcod_empresa
                                 , a_estabs ( i )
                                 , v_data_inicial
                                 , v_data_final
                                 , v_data_hora_ini );
        END LOOP;

        --==================================
        --FIM LOOP POR ESTAB - CARREGAR SAIDAS
        --==================================



        --================================================
        --CRIAR INDICES DA TEMP DE SAIDA
        --================================================
        create_tab_saida_idx ( p_proc_instance
                             , v_tabela_saida );

        --================================================
        --CRIAR E CARREGAR TABELAS TEMP DE ALIQ ST
        --================================================

        load_aliq_pmc ( p_proc_instance
                      , v_nome_tabela_aliq
                      , v_tabela_saida );

        --================================================
        --CARREGAR DADOS DE ORIGEM CD
        --================================================


        IF ( p_origem1 = '2'
        AND p_cd1 IS NOT NULL )
        OR ( p_origem2 = '2'
        AND p_cd2 IS NOT NULL )
        OR ( p_origem3 = '2'
        AND p_cd3 IS NOT NULL )
        OR ( p_origem4 = '2'
        AND p_cd4 IS NOT NULL ) THEN
            loga ( '> CARGA TEMP ENTRADAs CD-INI'
                 , FALSE );

            --CRIAR TABELA TMP DE ENTRADA CD
            create_tab_entrada_cd ( p_proc_instance
                                  , v_tab_entrada_c );

            --================================================
            --INICIO - ENTRADAS CDs
            --================================================

            IF ( p_origem1 = '2' ) THEN
                --CARREGAR TEMPORARIAS ENTRADA NOS CDs
                load_entradas_cd ( p_proc_instance
                                 , p_cd1
                                 , --V_DATA_FINAL,
                                   'C'
                                 , v_tab_entrada_c
                                 , v_tabela_saida
                                 , v_tabela_prod_saida
                                 , TO_CHAR ( ADD_MONTHS ( v_data_inicial
                                                        , -24 )
                                           , 'ddmmyyyy' )
                                 , TO_CHAR ( v_data_final
                                           , 'ddmmyyyy' ) );
            END IF;

            IF ( p_origem2 = '2'
            AND p_cd2 <> p_cd1 ) THEN
                --CARREGAR TEMPORARIAS ENTRADA NOS CDs
                load_entradas_cd ( p_proc_instance
                                 , p_cd2
                                 , --V_DATA_FINAL,
                                   'C'
                                 , v_tab_entrada_c
                                 , v_tabela_saida
                                 , v_tabela_prod_saida
                                 , TO_CHAR ( ADD_MONTHS ( v_data_inicial
                                                        , -24 )
                                           , 'ddmmyyyy' )
                                 , TO_CHAR ( v_data_final
                                           , 'ddmmyyyy' ) );
            END IF;

            IF ( p_origem3 = '2'
            AND p_cd3 <> p_cd2
            AND p_cd3 <> p_cd1 ) THEN
                --CARREGAR TEMPORARIAS ENTRADA NOS CDs
                load_entradas_cd ( p_proc_instance
                                 , p_cd3
                                 , --V_DATA_FINAL,
                                   'C'
                                 , v_tab_entrada_c
                                 , v_tabela_saida
                                 , v_tabela_prod_saida
                                 , TO_CHAR ( ADD_MONTHS ( v_data_inicial
                                                        , -24 )
                                           , 'ddmmyyyy' )
                                 , TO_CHAR ( v_data_final
                                           , 'ddmmyyyy' ) );
            END IF;

            IF ( p_origem4 = '2'
            AND p_cd4 <> p_cd3
            AND p_cd4 <> p_cd2
            AND p_cd4 <> p_cd1 ) THEN
                --CARREGAR TEMPORARIAS ENTRADA NOS CDs
                load_entradas_cd ( p_proc_instance
                                 , p_cd4
                                 , --V_DATA_FINAL,
                                   'C'
                                 , v_tab_entrada_c
                                 , v_tabela_saida
                                 , v_tabela_prod_saida
                                 , TO_CHAR ( ADD_MONTHS ( v_data_inicial
                                                        , -24 )
                                           , 'ddmmyyyy' )
                                 , TO_CHAR ( v_data_final
                                           , 'ddmmyyyy' ) );
            END IF;

            --CRIAR INDICES DA TEMP DE ENTRADA CD
            create_tab_entrada_cd_idx ( p_proc_instance
                                      , v_tab_entrada_c );

            loga ( '> CARGA TEMP ENTRADAs CD-FIM'
                 , FALSE );
        END IF;

        --================================================
        --FIM - ENTRADAS CDs
        --================================================

        --================================================
        --INICIO - ENTRADAS FILIAS
        --================================================
        --CARREGAR DADOS ENTRADA EM FILIAIS - TRANSFERENCIA
        IF ( p_origem1 = '1' )
        OR ( p_origem2 = '1' )
        OR ( p_origem3 = '1' )
        OR ( p_origem4 = '1' ) THEN
            loga ( '> CARGA TEMP ENTRADAs FILIAL-INI'
                 , FALSE );
            --CRIAR TABELA TMP DE ENTRADA EM FILIAIS
            create_tab_entrada_f ( p_proc_instance
                                 , v_tab_entrada_f
                                 , v_tab_entrada_f_aux );


            FOR i IN 1 .. a_estabs.COUNT LOOP
                /*--CARREGAR TEMPORARIAS ENTRADA NAS FILIAIS
                LOAD_ENTRADAS(P_PROC_INSTANCE,
                              A_ESTABS(i),
                              V_DATA_FINAL,
                              'F',
                              V_TAB_ENTRADA_F,
                              V_TABELA_SAIDA,
                              V_DATA_HORA_INI,
                              V_DATA_INICIAL);*/

                FOR y IN ( SELECT DISTINCT cod_cd
                                         , origem
                             FROM (SELECT 1 num_ordem
                                        , p_origem1 origem
                                        , p_cd1 cod_cd
                                     FROM DUAL
                                   UNION ALL
                                   SELECT 2 num_ordem
                                        , p_origem2 origem
                                        , p_cd2 cod_cd
                                     FROM DUAL
                                   UNION ALL
                                   SELECT 3 num_ordem
                                        , p_origem3 origem
                                        , p_cd3 cod_cd
                                     FROM DUAL
                                   UNION ALL
                                   SELECT 4 num_ordem
                                        , p_origem4 origem
                                        , p_cd4 cod_cd
                                     FROM DUAL)
                            WHERE cod_cd IS NOT NULL
                              AND origem = '1' ) LOOP
                    load_entradas ( pnr_particao => 1
                                  , pnr_particao2 => 1
                                  , vp_proc_instance => p_proc_instance
                                  , vp_origem => 'F'
                                  , vp_cod_cd => y.cod_cd
                                  , vp_tabela_entrada => v_tab_entrada_f_aux
                                  , vp_tabela_saida => v_tabela_saida
                                  , vp_data_inicio => TO_CHAR ( ADD_MONTHS ( v_data_inicial
                                                                           , -24 )
                                                              , 'DDMMYYYY' )
                                  , vp_data_fim => TO_CHAR ( v_data_final
                                                           , 'DDMMYYYY' )
                                  , vp_proc_id => mproc_id
                                  , pcod_empresa => mcod_empresa
                                  , pcod_estab => a_estabs ( i )
                                  , p_uf => p_uf
                                  , pnm_usuario => mnm_usuario );
                END LOOP;
            END LOOP; --FOR i IN 1..A_ESTABS.COUNT

            create_tab_entrada_a1_idx ( p_proc_instance
                                      , v_tab_entrada_f_aux );

            dbms_application_info.set_module ( 'DPSP_CARTOES_CPROC'
                                             , ' V_TAB_ENTRADA_F' );

            -----

            v_sql := '';
            v_sql := v_sql || 'INSERT /*+ APPEND */INTO  ' || v_tab_entrada_f;
            v_sql := v_sql || '(  ';
            v_sql := v_sql || 'SELECT  /* 12 */ DISTINCT PROC_ID, ';
            v_sql := v_sql || ' A.COD_EMPRESA, ';
            v_sql := v_sql || ' A.COD_ESTAB, ';
            v_sql := v_sql || ' A.DATA_FISCAL, ';
            v_sql := v_sql || ' A.MOVTO_E_S, ';
            v_sql := v_sql || ' A.NORM_DEV, ';
            v_sql := v_sql || ' A.IDENT_DOCTO, ';
            v_sql := v_sql || ' A.IDENT_FIS_JUR, ';
            v_sql := v_sql || ' A.NUM_DOCFIS, ';
            v_sql := v_sql || ' A.SERIE_DOCFIS, ';
            v_sql := v_sql || ' A.SUB_SERIE_DOCFIS, ';
            v_sql := v_sql || ' A.DISCRI_ITEM, ';
            v_sql := v_sql || ' A.NUM_ITEM, ';
            v_sql := v_sql || ' A.COD_FIS_JUR, ';
            v_sql := v_sql || ' A.CPF_CGC, ';
            v_sql := v_sql || ' A.COD_NBM, ';
            v_sql := v_sql || ' A.COD_CFO, ';
            v_sql := v_sql || ' A.COD_NATUREZA_OP, ';
            v_sql := v_sql || ' A.COD_PRODUTO, ';
            v_sql := v_sql || ' A.VLR_CONTAB_ITEM, ';
            v_sql := v_sql || ' A.QUANTIDADE, ';
            v_sql := v_sql || ' A.VLR_UNIT, ';
            -- V_SQL := V_SQL || ' A.VLR_ICMSS_N_ESCRIT, ';
            v_sql := v_sql || ' A.COD_SITUACAO_B, ';
            v_sql := v_sql || ' A.DATA_EMISSAO, ';
            v_sql := v_sql || ' A.COD_ESTADO, ';
            v_sql := v_sql || ' A.NUM_CONTROLE_DOCTO, ';
            v_sql := v_sql || ' A.NUM_AUTENTIC_NFE ';
            /*             V_SQL := V_SQL || ' , ';
                         V_SQL := V_SQL || ' A.VLR_ITEM        , ';
                         V_SQL := V_SQL || ' A.VLR_OUTRAS      , ';
                         V_SQL := V_SQL || ' A.VLR_DESCONTO    , ';
                         V_SQL := V_SQL || ' A.CST_PIS         , ';
                         V_SQL := V_SQL || ' A.VLR_BASE_PIS    , ';
                         V_SQL := V_SQL || ' A.VLR_ALIQ_PIS    , ';
                         V_SQL := V_SQL || ' A.VLR_PIS         , ';
                         V_SQL := V_SQL || ' A.CST_COFINS      , ';
                         V_SQL := V_SQL || ' A.VLR_BASE_COFINS , ';
                         V_SQL := V_SQL || ' A.VLR_ALIQ_COFINS , ';
                         V_SQL := V_SQL || ' A.VLR_COFINS      , ';
                         V_SQL := V_SQL || ' A.VLR_BASE_ICMS, ';
                         V_SQL := V_SQL || ' A.VLR_ICMS, ';
                         V_SQL := V_SQL || ' A.VLR_BASE_ICMSS, ';
                         V_SQL := V_SQL || ' A.VLR_ICMSS ';*/
            v_sql := v_sql || ' FROM ( ';
            v_sql := v_sql || 'SELECT PROC_ID, ';
            v_sql := v_sql || ' COD_EMPRESA, ';
            v_sql := v_sql || ' COD_ESTAB, ';
            v_sql := v_sql || ' DATA_FISCAL, ';
            v_sql := v_sql || ' MOVTO_E_S, ';
            v_sql := v_sql || ' NORM_DEV, ';
            v_sql := v_sql || ' IDENT_DOCTO, ';
            v_sql := v_sql || ' IDENT_FIS_JUR, ';
            v_sql := v_sql || ' NUM_DOCFIS, ';
            v_sql := v_sql || ' SERIE_DOCFIS, ';
            v_sql := v_sql || ' SUB_SERIE_DOCFIS, ';
            v_sql := v_sql || ' DISCRI_ITEM, ';
            v_sql := v_sql || ' NUM_ITEM, ';
            v_sql := v_sql || ' COD_FIS_JUR, ';
            v_sql := v_sql || ' CPF_CGC, ';
            v_sql := v_sql || ' COD_NBM, ';
            v_sql := v_sql || ' COD_CFO, ';
            v_sql := v_sql || ' COD_NATUREZA_OP, ';
            v_sql := v_sql || ' COD_PRODUTO, ';
            v_sql := v_sql || ' VLR_CONTAB_ITEM, ';
            v_sql := v_sql || ' QUANTIDADE, ';
            v_sql := v_sql || ' VLR_UNIT, ';
            --  V_SQL := V_SQL || ' VLR_ICMSS_N_ESCRIT, ';
            v_sql := v_sql || ' COD_SITUACAO_B, ';
            v_sql := v_sql || ' DATA_EMISSAO, ';
            v_sql := v_sql || ' COD_ESTADO, ';
            v_sql := v_sql || ' NUM_CONTROLE_DOCTO, ';
            v_sql := v_sql || ' NUM_AUTENTIC_NFE ,';
            /*              V_SQL := V_SQL || ' VLR_ITEM        , ';
                          V_SQL := V_SQL || ' VLR_OUTRAS      , ';
                          V_SQL := V_SQL || ' VLR_DESCONTO    , ';
                          V_SQL := V_SQL || ' CST_PIS         , ';
                          V_SQL := V_SQL || ' VLR_BASE_PIS    , ';
                          V_SQL := V_SQL || ' VLR_ALIQ_PIS    , ';
                          V_SQL := V_SQL || ' VLR_PIS         , ';
                          V_SQL := V_SQL || ' CST_COFINS      , ';
                          V_SQL := V_SQL || ' VLR_BASE_COFINS , ';
                          V_SQL := V_SQL || ' VLR_ALIQ_COFINS , ';
                          V_SQL := V_SQL || ' VLR_COFINS      , ';
                          V_SQL := V_SQL || ' VLR_BASE_ICMS, ';
                          V_SQL := V_SQL || ' VLR_ICMS, ';
                          V_SQL := V_SQL || ' VLR_BASE_ICMSS, ';
                          V_SQL := V_SQL || ' VLR_ICMSS ,';*/
            v_sql := v_sql || ' RANK() OVER( ';
            v_sql := v_sql || '  PARTITION BY COD_ESTAB, COD_PRODUTO, DATA_FISCAL_SAIDA, COD_FIS_JUR ';
            v_sql := v_sql || '   ORDER BY DATA_FISCAL DESC, DATA_EMISSAO DESC, NUM_DOCFIS, DISCRI_ITEM) RANK ';
            v_sql := v_sql || '              FROM ' || v_tab_entrada_f_aux;
            v_sql := v_sql || '       ) A ';
            v_sql := v_sql || ' WHERE A.RANK = 1 )';


            EXECUTE IMMEDIATE ( v_sql );

            COMMIT;

            --INDEX
            create_tab_entrada_f_idx ( p_proc_instance
                                     , v_tab_entrada_f );

            loga ( '> CARGA TEMP ENTRADAs FILIAL-FIM'
                 , FALSE );
        END IF;

        --IF (P_ORIGEM1 = '1') OR (P_ORIGEM2 = '1') OR (P_ORIGEM3 = '1') OR (P_ORIGEM4 = '1') THEN
        --================================================
        --FIM - ENTRADAS FILIAS
        --================================================

        --================================================
        --CARREGAR NFs DO PEOPLE
        --================================================

        load_nf_people ( p_proc_instance
                       , mcod_empresa
                       , v_tab_entrada_c
                       , v_tab_entrada_f
                       , ''
                       , v_tabela_nf
                       , v_tabela_saida
                       , v_tab_item
                       , v_data_inicial
                       , v_data_final
                       , v_data_hora_ini );

        --CRIAR TABELA RESULTADO TMP
        create_tab_cartoes ( p_proc_instance
                           , v_tabela_cartoes );

        --================================================
        --LOOP PARA CADA FILIAL-INI
        --================================================

        FOR i IN 1 .. a_estabs.COUNT LOOP
            --ASSOCIAR SAIDAS COM SUAS ULTIMAS ENTRADAS
            IF ( p_cd1 IS NOT NULL ) THEN
                IF ( p_origem1 = '1' ) THEN
                    --ENTRADA NAS FILIAIS
                    get_entradas_filial ( p_proc_instance
                                        , a_estabs ( i )
                                        , p_cd1
                                        , v_data_inicial
                                        , v_data_final
                                        , v_tab_entrada_f
                                        , v_tabela_saida
                                        , v_tabela_nf
                                        , v_tabela_cartoes
                                        , v_data_hora_ini
                                        , v_tab_item );
                ELSIF ( p_origem1 = '2' ) THEN
                    --ENTRADA NOS CDs
                    get_entradas_cd ( p_proc_instance
                                    , a_estabs ( i )
                                    , p_cd1
                                    , v_data_inicial
                                    , v_data_final
                                    , v_tab_entrada_c
                                    , v_tabela_saida
                                    , v_tabela_nf
                                    , v_tabela_cartoes
                                    , v_data_hora_ini
                                    , v_tab_item );
                END IF;
            END IF;

            IF ( p_cd2 IS NOT NULL ) THEN
                IF ( p_origem2 = '1' ) THEN
                    --ENTRADA NAS FILIAIS
                    get_entradas_filial ( p_proc_instance
                                        , a_estabs ( i )
                                        , p_cd2
                                        , v_data_inicial
                                        , v_data_final
                                        , v_tab_entrada_f
                                        , v_tabela_saida
                                        , v_tabela_nf
                                        , v_tabela_cartoes
                                        , v_data_hora_ini
                                        , v_tab_item );
                ELSIF ( p_origem2 = '2' ) THEN
                    --ENTRADA NOS CDs
                    get_entradas_cd ( p_proc_instance
                                    , a_estabs ( i )
                                    , p_cd2
                                    , v_data_inicial
                                    , v_data_final
                                    , v_tab_entrada_c
                                    , v_tabela_saida
                                    , v_tabela_nf
                                    , v_tabela_cartoes
                                    , v_data_hora_ini
                                    , v_tab_item );
                END IF;
            END IF;

            IF ( p_cd3 IS NOT NULL ) THEN
                IF ( p_origem3 = '1' ) THEN
                    --ENTRADA NAS FILIAIS
                    get_entradas_filial ( p_proc_instance
                                        , a_estabs ( i )
                                        , p_cd3
                                        , v_data_inicial
                                        , v_data_final
                                        , v_tab_entrada_f
                                        , v_tabela_saida
                                        , v_tabela_nf
                                        , v_tabela_cartoes
                                        , v_data_hora_ini
                                        , v_tab_item );
                ELSIF ( p_origem3 = '2' ) THEN
                    --ENTRADA NOS CDs
                    get_entradas_cd ( p_proc_instance
                                    , a_estabs ( i )
                                    , p_cd3
                                    , v_data_inicial
                                    , v_data_final
                                    , v_tab_entrada_c
                                    , v_tabela_saida
                                    , v_tabela_nf
                                    , v_tabela_cartoes
                                    , v_data_hora_ini
                                    , v_tab_item );
                END IF;
            END IF;

            IF ( p_cd4 IS NOT NULL ) THEN
                IF ( p_origem4 = '1' ) THEN
                    --ENTRADA NAS FILIAIS
                    get_entradas_filial ( p_proc_instance
                                        , a_estabs ( i )
                                        , p_cd4
                                        , v_data_inicial
                                        , v_data_final
                                        , v_tab_entrada_f
                                        , v_tabela_saida
                                        , v_tabela_nf
                                        , v_tabela_cartoes
                                        , v_data_hora_ini
                                        , v_tab_item );
                ELSIF ( p_origem4 = '2' ) THEN
                    --ENTRADA NOS CDs
                    get_entradas_cd ( p_proc_instance
                                    , a_estabs ( i )
                                    , p_cd4
                                    , v_data_inicial
                                    , v_data_final
                                    , v_tab_entrada_c
                                    , v_tabela_saida
                                    , v_tabela_nf
                                    , v_tabela_cartoes
                                    , v_data_hora_ini
                                    , v_tab_item );
                END IF;
            END IF;

            --SE NAO ACHOU ENTRADA, GRAVAR NA TABELA RESULTADO APENAS A SAIDA
            get_sem_entrada ( p_proc_instance
                            , a_estabs ( i )
                            , v_data_inicial
                            , v_data_final
                            , v_tabela_saida
                            , v_tabela_cartoes
                            , v_data_hora_ini );

            loga ( 'GET_ENTRADAS-FIM-' || a_estabs ( i )
                 , FALSE );

            --EXCLUIR LINHAS DA TABELA FINAL
            delete_tbl ( a_estabs ( i )
                       , v_data_inicial
                       , v_data_final );
        END LOOP; --FOR i IN 1..A_ESTABS.COUNT

        --================================================
        --LOOP PARA CADA FILIAL-FIM
        --================================================

        --================================================
        --INSERIR DADOS-INI
        --================================================

        loga ( 'INSERINDO RESULTADO... - INI' );

        ---INSERIR RESULTADO
        /*    V_RESULT := 'INSERT \*+APPEND*\ INTO MSAFI.DPSP_MSAF_CARTOES ( ';
            V_RESULT := V_RESULT || 'SELECT DISTINCT ';
            V_RESULT := V_RESULT || 'A.COD_EMPRESA, ';
            V_RESULT := V_RESULT || 'A.COD_ESTAB, ';
            V_RESULT := V_RESULT || 'A.UF_ESTAB, ';
            V_RESULT := V_RESULT || 'A.DOCTO, ';
            V_RESULT := V_RESULT || 'A.COD_PRODUTO, ';
            V_RESULT := V_RESULT || 'A.NUM_ITEM, ';
            V_RESULT := V_RESULT || 'A.DESCR_ITEM, ';
            V_RESULT := V_RESULT || 'A.NUM_DOCFIS, ';
            V_RESULT := V_RESULT || 'A.DATA_FISCAL, ';
            V_RESULT := V_RESULT || 'A.SERIE_DOCFIS, ';
            V_RESULT := V_RESULT || 'A.QUANTIDADE, ';
            V_RESULT := V_RESULT || 'A.COD_NBM, ';
            V_RESULT := V_RESULT || 'A.COD_CFO, ';
            V_RESULT := V_RESULT || 'A.GRUPO_PRODUTO, ';
            V_RESULT := V_RESULT || 'A.VLR_DESCONTO, ';
            V_RESULT := V_RESULT || 'A.VLR_CONTABIL, ';
            V_RESULT := V_RESULT || 'A.NUM_AUTENTIC_NFE, ';
            V_RESULT := V_RESULT || 'A.VLR_BASE_ICMS, ';
            V_RESULT := V_RESULT || 'A.VLR_ALIQ_ICMS, ';
            V_RESULT := V_RESULT || 'A.VLR_ICMS, ';
            V_RESULT := V_RESULT || 'A.DESCR_TOT, ';
            V_RESULT := V_RESULT || 'A.AUTORIZADORA, ';
            V_RESULT := V_RESULT || 'A.NOME_VAN, ';
            V_RESULT := V_RESULT || 'A.VLR_PAGO_CARTAO, ';
            V_RESULT := V_RESULT || 'A.FORMA_PAGTO, ';
            V_RESULT := V_RESULT || 'A.NUM_PARCELAS, ';
            V_RESULT := V_RESULT ||
                        'CASE WHEN LENGTH(TRIM(A.CODIGO_APROVACAO)) > 6 THEN SUBSTR(A.CODIGO_APROVACAO, -20, 20) ELSE SUBSTR(A.CODIGO_APROVACAO, 1, 20) END, '; --EVITAR FALTA DE CODIGO DE APROVACAO NO DATAHUB
            ---
            V_RESULT := V_RESULT || 'A.COD_ESTAB_E, ';
            V_RESULT := V_RESULT || 'A.DATA_FISCAL_E, ';
            V_RESULT := V_RESULT || 'A.MOVTO_E_S_E, ';
            V_RESULT := V_RESULT || 'A.NORM_DEV_E, ';
            V_RESULT := V_RESULT || 'A.IDENT_DOCTO_E, ';
            V_RESULT := V_RESULT || 'A.IDENT_FIS_JUR_E, ';
            V_RESULT := V_RESULT || 'A.SUB_SERIE_DOCFIS_E, ';
            V_RESULT := V_RESULT || 'A.DISCRI_ITEM_E, ';
            V_RESULT := V_RESULT || 'A.DATA_EMISSAO_E, ';
            V_RESULT := V_RESULT || 'A.NUM_DOCFIS_E, ';
            V_RESULT := V_RESULT || 'A.SERIE_DOCFIS_E, ';
            V_RESULT := V_RESULT || 'A.NUM_ITEM_E, ';
            V_RESULT := V_RESULT || 'A.COD_FIS_JUR_E, ';
            V_RESULT := V_RESULT || 'A.CPF_CGC_E, ';
            V_RESULT := V_RESULT || 'A.COD_NBM_E, ';
            V_RESULT := V_RESULT || 'A.COD_CFO_E, ';
            V_RESULT := V_RESULT || 'A.COD_NATUREZA_OP_E, ';
            V_RESULT := V_RESULT || 'A.COD_PRODUTO_E, ';
            V_RESULT := V_RESULT || 'A.VLR_CONTAB_ITEM_E, ';
            V_RESULT := V_RESULT || 'A.QUANTIDADE_E, ';
            V_RESULT := V_RESULT || 'A.VLR_UNIT_E, ';
            V_RESULT := V_RESULT || 'A.COD_SITUACAO_B_E, ';
            V_RESULT := V_RESULT || 'A.COD_ESTADO_E, ';
            V_RESULT := V_RESULT || 'A.NUM_CONTROLE_DOCTO_E, ';
            V_RESULT := V_RESULT || 'A.NUM_AUTENTIC_NFE_E, ';
            ---
            V_RESULT := V_RESULT || 'A.BASE_ICMS_UNIT_E, ';
            V_RESULT := V_RESULT || 'A.VLR_ICMS_UNIT_E, ';
            V_RESULT := V_RESULT || 'A.ALIQ_ICMS_E, ';
            V_RESULT := V_RESULT || 'A.BASE_ST_UNIT_E, ';
            V_RESULT := V_RESULT || 'A.VLR_ICMS_ST_UNIT_E, ';
            V_RESULT := V_RESULT || 'C.ALIQ_ST, ';
            V_RESULT := V_RESULT || 'A.VLR_ICMS_ST_UNIT_AUX, ';
            V_RESULT := V_RESULT || 'A.STAT_LIBER_CNTR, ';
            V_RESULT := V_RESULT || 'TO_NUMBER(NVL(DET.VALOR,''0'')), ';
            V_RESULT := V_RESULT ||
                        '(A.VLR_CONTABIL*(TO_NUMBER(NVL(DET.VALOR,''0''))/100))/A.QUANTIDADE, ';
            ---
            V_RESULT := V_RESULT || ' ''' || MNM_USUARIO || ''', ';
            V_RESULT := V_RESULT || 'SYSDATE ';
            ---
            V_RESULT := V_RESULT || 'FROM ' || V_TABELA_CARTOES || ' A, ';
            V_RESULT := V_RESULT || V_NOME_TABELA_ALIQ || ' C, ';
            V_RESULT := V_RESULT || '          MSAF.FPAR_PARAM_DET DET, ';
            V_RESULT := V_RESULT || '          MSAF.FPAR_PARAMETROS PAR ';
            V_RESULT := V_RESULT || 'WHERE A.PROC_ID            = ' ||
                        P_PROC_INSTANCE;
            V_RESULT := V_RESULT || '  AND A.PROC_ID            = C.PROC_ID (+) ';
            V_RESULT := V_RESULT ||
                        '  AND A.COD_PRODUTO        = C.COD_PRODUTO (+) ';
            V_RESULT := V_RESULT ||
                        '  AND CASE WHEN A.FORMA_PAGTO = ''CREDITO'' THEN ';
            V_RESULT := V_RESULT ||
                        '        DECODE(A.NUM_PARCELAS,''0'',TRIM(A.AUTORIZADORA) || ''(V)'', TRIM(A.AUTORIZADORA) || ''(P)'') ';
            V_RESULT := V_RESULT || '     ELSE ';
            V_RESULT := V_RESULT || '      TRIM(A.AUTORIZADORA) ';
            V_RESULT := V_RESULT ||
                        '     END || ''-'' || TRIM(A.NOME_VAN) = DET.CONTEUDO ';
            V_RESULT := V_RESULT || '  AND DET.NOME_PARAM     = ''INTERF'' ';
            V_RESULT := V_RESULT || '  AND DET.ID_PARAMETRO   = PAR.ID_PARAMETROS ';
            V_RESULT := V_RESULT ||
                        '  AND PAR.NOME_FRAMEWORK = ''DPSP_CARTOES_CPAR'' ';
            V_RESULT := V_RESULT || '  AND PAR.DESCRICAO      = ''' ||
                        TO_CHAR(V_DATA_FINAL, 'YYYY/MM') || ''' ';

            V_RESULT := V_RESULT || ' ) ';
        */

        v_result := 'BEGIN ';
        v_result := v_result || 'for c in ( ';

        v_result := v_result || ' SELECT DISTINCT ';
        v_result := v_result || 'A.COD_EMPRESA, ';
        v_result := v_result || 'A.COD_ESTAB, ';
        v_result := v_result || 'A.UF_ESTAB, ';
        v_result := v_result || 'A.DOCTO, ';
        v_result := v_result || 'A.COD_PRODUTO, ';
        v_result := v_result || 'A.NUM_ITEM, ';
        v_result := v_result || 'A.DESCR_ITEM, ';
        v_result := v_result || 'A.NUM_DOCFIS, ';
        v_result := v_result || 'A.DATA_FISCAL, ';
        v_result := v_result || 'A.SERIE_DOCFIS, ';
        v_result := v_result || 'A.QUANTIDADE, ';
        v_result := v_result || 'A.COD_NBM, ';
        v_result := v_result || 'A.COD_CFO, ';
        v_result := v_result || 'A.GRUPO_PRODUTO, ';
        v_result := v_result || 'A.VLR_DESCONTO, ';
        v_result := v_result || 'A.VLR_CONTABIL, ';
        v_result := v_result || 'A.NUM_AUTENTIC_NFE, ';
        v_result := v_result || 'A.VLR_BASE_ICMS, ';
        v_result := v_result || 'A.VLR_ALIQ_ICMS, ';
        v_result := v_result || 'A.VLR_ICMS, ';
        v_result := v_result || 'A.DESCR_TOT, ';
        v_result := v_result || 'A.AUTORIZADORA, ';
        v_result := v_result || 'A.NOME_VAN, ';
        v_result := v_result || 'A.VLR_PAGO_CARTAO, ';
        v_result := v_result || 'A.FORMA_PAGTO, ';
        v_result := v_result || 'A.NUM_PARCELAS, ';
        v_result :=
               v_result
            || 'CASE WHEN LENGTH(TRIM(A.CODIGO_APROVACAO)) > 6 THEN SUBSTR(A.CODIGO_APROVACAO, -20, 20) ELSE SUBSTR(A.CODIGO_APROVACAO, 1, 20) END CODIGO_APROVACAO, '; --EVITAR FALTA DE CODIGO DE APROVACAO NO DATAHUB
        ---
        v_result := v_result || 'A.COD_ESTAB_E, ';
        v_result := v_result || 'A.DATA_FISCAL_E, ';
        v_result := v_result || 'A.MOVTO_E_S_E, ';
        v_result := v_result || 'A.NORM_DEV_E, ';
        v_result := v_result || 'A.IDENT_DOCTO_E, ';
        v_result := v_result || 'A.IDENT_FIS_JUR_E, ';
        v_result := v_result || 'A.SUB_SERIE_DOCFIS_E, ';
        v_result := v_result || 'A.DISCRI_ITEM_E, ';
        v_result := v_result || 'A.DATA_EMISSAO_E, ';
        v_result := v_result || 'A.NUM_DOCFIS_E, ';
        v_result := v_result || 'A.SERIE_DOCFIS_E, ';
        v_result := v_result || 'A.NUM_ITEM_E, ';
        v_result := v_result || 'A.COD_FIS_JUR_E, ';
        v_result := v_result || 'A.CPF_CGC_E, ';
        v_result := v_result || 'A.COD_NBM_E, ';
        v_result := v_result || 'A.COD_CFO_E, ';
        v_result := v_result || 'A.COD_NATUREZA_OP_E, ';
        v_result := v_result || 'A.COD_PRODUTO_E, ';
        v_result := v_result || 'A.VLR_CONTAB_ITEM_E, ';
        v_result := v_result || 'A.QUANTIDADE_E, ';
        v_result := v_result || 'A.VLR_UNIT_E, ';
        v_result := v_result || 'A.COD_SITUACAO_B_E, ';
        v_result := v_result || 'A.COD_ESTADO_E, ';
        v_result := v_result || 'A.NUM_CONTROLE_DOCTO_E, ';
        v_result := v_result || 'A.NUM_AUTENTIC_NFE_E, ';
        ---
        v_result := v_result || 'A.BASE_ICMS_UNIT_E, ';
        v_result := v_result || 'A.VLR_ICMS_UNIT_E, ';
        v_result := v_result || 'A.ALIQ_ICMS_E, ';
        v_result := v_result || 'A.BASE_ST_UNIT_E, ';
        v_result := v_result || 'A.VLR_ICMS_ST_UNIT_E, ';
        v_result := v_result || 'C.ALIQ_ST, ';
        v_result := v_result || 'A.VLR_ICMS_ST_UNIT_AUX, ';
        v_result := v_result || 'A.STAT_LIBER_CNTR, ';
        v_result := v_result || 'TO_NUMBER(NVL(DET.VALOR,''0'')) TAXA_CARTAO, ';
        v_result :=
            v_result || '(A.VLR_CONTABIL*(TO_NUMBER(NVL(DET.VALOR,''0''))/100))/A.QUANTIDADE VLR_PAGTO_TARIFA, ';
        ---
        v_result := v_result || ' ''' || mnm_usuario || ''' USUARIO, ';
        v_result := v_result || ' SYSDATE DAT_OPERACAO';
        ---
        v_result := v_result || ' FROM ' || v_tabela_cartoes || ' A, ';
        v_result := v_result || v_nome_tabela_aliq || ' C, ';
        v_result := v_result || '          MSAF.FPAR_PARAM_DET DET, ';
        v_result := v_result || '          MSAF.FPAR_PARAMETROS PAR ';
        v_result := v_result || 'WHERE A.PROC_ID            = ' || p_proc_instance;
        v_result := v_result || '  AND A.PROC_ID            = C.PROC_ID (+) ';
        v_result := v_result || '  AND A.COD_PRODUTO        = C.COD_PRODUTO (+) ';
        v_result := v_result || '  AND (CASE WHEN A.FORMA_PAGTO = ''CREDITO'' THEN ';
        v_result :=
               v_result
            || '			     DECODE(A.NUM_PARCELAS,''0'',TRIM(A.AUTORIZADORA) || ''(V)'', TRIM(A.AUTORIZADORA) || ''(P)'') ';
        v_result := v_result || '			  ELSE ';
        v_result := v_result || '			 	 TRIM(A.AUTORIZADORA) ';
        v_result := v_result || '			  END) || ''-'' || TRIM(A.NOME_VAN) = DET.CONTEUDO ';
        v_result := v_result || '  AND DET.NOME_PARAM     = ''INTERF'' ';
        v_result := v_result || '  AND DET.ID_PARAMETRO   = PAR.ID_PARAMETROS ';
        v_result := v_result || '  AND PAR.NOME_FRAMEWORK = ''DPSP_CARTOES_CPAR'' ';
        v_result :=
               v_result
            || '  AND PAR.DESCRICAO      = '''
            || TO_CHAR ( v_data_final
                       , 'YYYY/MM' )
            || ''' ';

        v_result := v_result || ' ) ';

        v_result := v_result || 'loop';
        v_result := v_result || '';
        v_result := v_result || ' INSERT /*+APPEND*/ INTO MSAFI.DPSP_MSAF_CARTOES ';
        v_result := v_result || ' values(';
        v_result := v_result || '	 c.cod_empresa,                 ';
        v_result := v_result || '    c.cod_estab,                   ';
        v_result := v_result || '    c.uf_estab,                    ';
        v_result := v_result || '    c.docto,                       ';
        v_result := v_result || '    c.cod_produto,                 ';
        v_result := v_result || '    c.num_item,                    ';
        v_result := v_result || '    c.descr_item,                  ';
        v_result := v_result || '    c.num_docfis,                  ';
        v_result := v_result || '    c.data_fiscal,                 ';
        v_result := v_result || '    c.serie_docfis,                ';
        v_result := v_result || '    c.quantidade,                  ';
        v_result := v_result || '    c.cod_nbm,                     ';
        v_result := v_result || '    c.cod_cfo,                     ';
        v_result := v_result || '    c.grupo_produto,               ';
        v_result := v_result || '    c.vlr_desconto,                ';
        v_result := v_result || '    c.vlr_contabil,                ';
        v_result := v_result || '    c.num_autentic_nfe,            ';
        v_result := v_result || '    c.vlr_base_icms,               ';
        v_result := v_result || '    c.vlr_aliq_icms,               ';
        v_result := v_result || '    c.vlr_icms,                    ';
        v_result := v_result || '    c.descr_tot,                   ';
        v_result := v_result || '    c.autorizadora,                ';
        v_result := v_result || '    c.nome_van,                    ';
        v_result := v_result || '    c.vlr_pago_cartao,             ';
        v_result := v_result || '    c.forma_pagto,                 ';
        v_result := v_result || '    c.num_parcelas,                ';
        v_result := v_result || '    c.CODIGO_APROVACAO,            ';
        v_result := v_result || '    c.cod_estab_e,                 ';
        v_result := v_result || '    c.data_fiscal_e,               ';
        v_result := v_result || '    c.movto_e_s_e,                 ';
        v_result := v_result || '    c.norm_dev_e,                  ';
        v_result := v_result || '    c.ident_docto_e,               ';
        v_result := v_result || '    c.ident_fis_jur_e,             ';
        v_result := v_result || '    c.sub_serie_docfis_e,          ';
        v_result := v_result || '    c.discri_item_e,               ';
        v_result := v_result || '    c.data_emissao_e,              ';
        v_result := v_result || '    c.num_docfis_e,                ';
        v_result := v_result || '    c.serie_docfis_e,              ';
        v_result := v_result || '    c.num_item_e,                  ';
        v_result := v_result || '    c.cod_fis_jur_e,               ';
        v_result := v_result || '    c.cpf_cgc_e,                   ';
        v_result := v_result || '    c.cod_nbm_e,                   ';
        v_result := v_result || '    c.cod_cfo_e,                   ';
        v_result := v_result || '    c.cod_natureza_op_e,           ';
        v_result := v_result || '    c.cod_produto_e,               ';
        v_result := v_result || '    c.vlr_contab_item_e,           ';
        v_result := v_result || '    c.quantidade_e,                ';
        v_result := v_result || '    c.vlr_unit_e,                  ';
        v_result := v_result || '    c.cod_situacao_b_e,            ';
        v_result := v_result || '    c.cod_estado_e,                ';
        v_result := v_result || '    c.num_controle_docto_e,        ';
        v_result := v_result || '    c.num_autentic_nfe_e,          ';
        v_result := v_result || '    c.base_icms_unit_e,            ';
        v_result := v_result || '    c.vlr_icms_unit_e,             ';
        v_result := v_result || '    c.aliq_icms_e,                 ';
        v_result := v_result || '    c.base_st_unit_e,              ';
        v_result := v_result || '    c.vlr_icms_st_unit_e,          ';
        v_result := v_result || '    c.aliq_st,                     ';
        v_result := v_result || '    c.vlr_icms_st_unit_aux,        ';
        v_result := v_result || '    c.stat_liber_cntr,             ';
        v_result := v_result || '    c.TAXA_CARTAO,                 ';
        v_result := v_result || '    c.VLR_PAGTO_TARIFA,            ';
        v_result := v_result || '    c.USUARIO,                     ';
        v_result := v_result || '    c.DAT_OPERACAO                 ';
        v_result := v_result || ' ); ';
        v_result := v_result || ' commit; ';
        v_result := v_result || ' end loop;';
        v_result := v_result || ' end;';

        BEGIN
            EXECUTE IMMEDIATE v_result;

            COMMIT;
        EXCEPTION
            WHEN OTHERS THEN
                loga ( 'SQLERRM: ' || SQLERRM
                     , FALSE );
                loga ( SUBSTR ( v_result
                              , 1
                              , 1024 )
                     , FALSE );
                loga ( SUBSTR ( v_result
                              , 1024
                              , 1024 )
                     , FALSE );
                loga ( SUBSTR ( v_result
                              , 2048
                              , 1024 )
                     , FALSE );
                loga ( SUBSTR ( v_result
                              , 3072 )
                     , FALSE );
                --ENVIAR EMAIL DE ERRO-------------------------------------------
                envia_email ( mcod_empresa
                            , v_data_inicial
                            , v_data_final
                            , SQLERRM
                            , 'E'
                            , v_data_hora_ini );
                -----------------------------------------------------------------
                raise_application_error ( -20001
                                        , '!ERRO INSERINDO RESULTADO!' );
        END;

        loga ( 'RESULTADO INSERIDO - FIM' );
        --================================================
        --INSERIR DADOS-FIM
        --================================================

        loga ( '<< LIMPAR TEMPs >>'
             , FALSE );
        /*DELETE_TEMP_TBL(P_PROC_INSTANCE,
                        V_NOME_TABELA_ALIQ,
                        '',
                        V_TAB_ENTRADA_C,
                        V_TAB_ENTRADA_F,
                        '',
                        V_TABELA_SAIDA,
                        V_TABELA_NF,
                        V_TABELA_CARTOES,
                        V_TAB_ITEM);*/
        --
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

        --DISPONIBILIZAR PERIODO PROCESSADO PARA TRAVA DE REPROCESSAMENTO
        msafi.add_trava_info ( 'CARTOES'
                             , TO_CHAR ( v_data_inicial
                                       , 'YYYY/MM' ) );

        loga ( 'FIM DO PROCESSAMENTO, STATUS FINAL: [' || v_s_proc_status || ']'
             , FALSE );

        --LIB_PROC.ADD('FIM DO PROCESSAMENTO, STATUS FINAL: [' ||
        --             V_S_PROC_STATUS || ']');
        --LIB_PROC.ADD('Favor verificar LOG para detalhes.');
        --MSAFI.DSP_CONTROL.UPDATEPROCESS(V_S_PROC_STATUS);

        --ENVIAR EMAIL DE SUCESSO----------------------------------------
        /*    ENVIA_EMAIL(MCOD_EMPRESA,
                        V_DATA_INICIAL,
                        V_DATA_FINAL,
                        '',
                        'S',
                        V_DATA_HORA_INI);
        */
        -----------------------------------------------------------------

        --===============================================
        --AJUSTE PROD ID DE ORIGEM COM O EM EXECUÇÃO
        --===============================================
        lib_proc.close;

        -- UPDATE LIB_PROC_LOG O
        --   SET O.PROC_ID = MPROC_ID_ORIG
        -- WHERE O.PROC_ID = MPROC_ID_O;
        --COMMIT;

        --LIB_PROC.DELETE(MPROC_ID_O);
        RETURN mproc_id_o;
    EXCEPTION
        WHEN OTHERS THEN
            --MSAFI.DSP_CONTROL.LOG_CHECKPOINT(SQLERRM,
            --                                 'Erro não tratado, executador de interfaces');
            --MSAFI.DSP_CONTROL.UPDATEPROCESS(4);
            loga ( 'SQLERRM: ' || SQLERRM
                 , FALSE );

            lib_proc.add_log ( 'Erro não tratado: ' || dbms_utility.format_error_backtrace
                             , 1 );
            lib_proc.add_log ( 'SQLERRM: ' || SQLERRM
                             , 1 );
            lib_proc.add ( 'ERRO!' );
            lib_proc.add ( dbms_utility.format_error_backtrace );
            COMMIT;
            --ENVIAR EMAIL DE ERRO-------------------------------------------
            envia_email ( mcod_empresa
                        , v_data_inicial
                        , v_data_final
                        , SQLERRM
                        , 'E'
                        , v_data_hora_ini );
            -----------------------------------------------------------------
            lib_proc.close;
            COMMIT;
            RETURN mproc_id;
    END;
END dpsp_cartoes_cproc;
/
SHOW ERRORS;
