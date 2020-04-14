Prompt Package Body DPSP_RES_INTER_CPROC;
--
-- DPSP_RES_INTER_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_res_inter_cproc
IS
    mproc_id INTEGER;
    v_quant_empresas INTEGER := 50;

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

        lib_proc.add_param (
                             pstr
                           , 'CDs'
                           , --P_CDS
                            'VARCHAR2'
                           , 'MULTISELECT'
                           , 'S'
                           , NULL
                           , NULL
                           ,    'SELECT A.COD_ESTAB, A.COD_ESTAB || '' - '' || B.COD_ESTADO || '' - '' || A.CGC || '' - '' || INITCAP(A.BAIRRO) || '' / '' || INITCAP(A.CIDADE) FROM ESTABELECIMENTO A, ESTADO B, MSAFI.DSP_ESTABELECIMENTO C WHERE A.COD_EMPRESA  = '''
                             || mcod_empresa
                             || ''' AND B.IDENT_ESTADO = A.IDENT_ESTADO AND A.COD_EMPRESA = C.COD_EMPRESA AND A.COD_ESTAB = C.COD_ESTAB AND C.TIPO = ''C'' ORDER BY B.COD_ESTADO, A.COD_ESTAB'
        );

        RETURN pstr;
    END; --FUNCTION PARAMETROS RETURN VARCHAR2 IS

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Processar Dados Ressarcimento INTERESTADUAL';
    END;

    FUNCTION tipo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Ressarcimento';
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
        RETURN 'Processar Carga de Dados para Ressarcimento INTERESTADUAL';
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
        COMMIT;
    ---> Para acompanhar processamento usar SELECT abaixo
    --SELECT * FROM DSP_LOG
    --WHERE LOG_TYPE = 'INTER'
    --ORDER BY 3 DESC, 2 DESC
    ---
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
        INSERT INTO msafi.dpsp_msaf_tmp_control
             VALUES ( vp_proc_instance
                    , vp_table_name
                    , SYSDATE
                    , musuario
                    , v_sid );

        COMMIT;
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
                    loga ( 'TAB OLD ' || l_table_name || '<'
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

        IF ( vp_tipo = 'E' ) THEN --VP_TIPO = 'E' (ERRO) OU 'S' (SUCESSO)
            v_txt_email := 'ERRO no Processo Ressarcimento Interestadual!';
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
            v_assunto := 'Mastersaf - Ressarcimento Interestadual apresentou ERRO';
        ---NOTIFICA('', 'S', V_ASSUNTO, V_TXT_EMAIL, 'DPSP_RES_INTER_CPROC');

        ELSE
            v_txt_email := 'Processo Ressarcimento Interestadual finalizado com SUCESSO.';
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
            v_assunto := 'Mastersaf - Ressarcimento Interestadual Concluído';
        ---NOTIFICA('S', '', V_ASSUNTO, V_TXT_EMAIL, 'DPSP_RES_INTER_CPROC');

        END IF;
    END;

    PROCEDURE create_tab_saida ( vp_proc_instance IN VARCHAR2
                               , vp_tabela_saida   OUT VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 4000 );
    BEGIN
        vp_tabela_saida := 'DPSP_INTERS_' || vp_proc_instance;

        v_sql := 'CREATE TABLE ' || vp_tabela_saida || ' ( ';
        v_sql := v_sql || 'PROC_ID             NUMBER(30), ';
        v_sql := v_sql || 'COD_EMPRESA         VARCHAR2(3), ';
        v_sql := v_sql || 'COD_ESTAB           VARCHAR2(6), ';
        v_sql := v_sql || 'NUM_DOCFIS          VARCHAR2(12), ';
        v_sql := v_sql || 'NUM_CONTROLE_DOCTO  VARCHAR2(12), ';
        v_sql := v_sql || 'NUM_ITEM            NUMBER(5), ';
        v_sql := v_sql || 'COD_PRODUTO         VARCHAR2(35), ';
        v_sql := v_sql || 'DESCR_ITEM          VARCHAR2(50), ';
        v_sql := v_sql || 'DATA_FISCAL         DATE, ';
        v_sql := v_sql || 'UF_ORIGEM           VARCHAR2(2), ';
        v_sql := v_sql || 'UF_DESTINO          VARCHAR2(2), ';
        v_sql := v_sql || 'COD_FIS_JUR 		   VARCHAR2(14), ';
        v_sql := v_sql || 'CNPJ                VARCHAR2(14), ';
        v_sql := v_sql || 'RAZAO_SOCIAL        VARCHAR2(70), ';
        v_sql := v_sql || 'SERIE_DOCFIS        VARCHAR2(3), ';
        v_sql := v_sql || 'CFOP                VARCHAR2(5), ';
        v_sql := v_sql || 'FINALIDADE          VARCHAR2(3), ';
        v_sql := v_sql || 'NBM                 VARCHAR2(10), ';
        v_sql := v_sql || 'NUM_AUTENTIC_NFE    VARCHAR2(80), ';
        v_sql := v_sql || 'QUANTIDADE          NUMBER(17,6), ';
        v_sql := v_sql || 'VLR_UNIT			   NUMBER(19,4), ';
        v_sql := v_sql || 'VLR_ITEM            NUMBER(17,2), ';
        v_sql := v_sql || 'VLR_BASE_ICMS	   NUMBER(17,2), ';
        v_sql := v_sql || 'VLR_ICMS			   NUMBER(17,2), ';
        v_sql := v_sql || 'ALIQ_ICMS		   NUMBER(5,2)) ';
        v_sql := v_sql || 'PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;
    END;

    PROCEDURE create_tab_entrada_cd ( vp_proc_instance IN NUMBER
                                    , vp_tab_entrada_c   OUT VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 2000 );
    BEGIN
        ---CRIAR TEMP DE ENTRADA EM CD
        vp_tab_entrada_c := 'DPSP_INTER_E_' || vp_proc_instance;

        v_sql := 'CREATE TABLE ' || vp_tab_entrada_c || ' ( ';
        v_sql := v_sql || ' PROC_ID             NUMBER(30), ';
        v_sql := v_sql || ' DATA_FISCAL_S       DATE, '; --DATA FISCAL DA SAIDA
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

        EXECUTE IMMEDIATE v_sql;

        save_tmp_control ( vp_proc_instance
                         , vp_tab_entrada_c );
    END;

    PROCEDURE create_tab_entrada_cd_idx ( vp_proc_instance IN NUMBER
                                        , vp_tab_entrada_cd IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 1000 );
        v_qtde_e NUMBER := 0;
    BEGIN
        v_sql := 'CREATE UNIQUE INDEX PK_INTER_E_' || vp_proc_instance || ' ON ' || vp_tab_entrada_cd || ' ';
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || '    PROC_ID             ASC, ';
        v_sql := v_sql || '    DATA_FISCAL_S	   ASC, ';
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

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX1_INTERE' || vp_proc_instance || ' ON ' || vp_tab_entrada_cd || ' ';
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || '    PROC_ID			  ASC, ';
        v_sql := v_sql || '    NUM_CONTROLE_DOCTO ASC, ';
        v_sql := v_sql || '    NUM_AUTENTIC_NFE   ASC, ';
        v_sql := v_sql || '    NUM_ITEM           ASC, ';
        v_sql := v_sql || '    COD_PRODUTO        ASC ) ';
        v_sql := v_sql || '  PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX2_INTERE' || vp_proc_instance || ' ON ' || vp_tab_entrada_cd || ' ';
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || '    PROC_ID ASC ) ';
        v_sql := v_sql || '  PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX3_INTERE' || vp_proc_instance || ' ON ' || vp_tab_entrada_cd || ' ';
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || '    NUM_AUTENTIC_NFE ASC, ';
        v_sql := v_sql || '    COD_PRODUTO ASC, ';
        v_sql := v_sql || '    NUM_ITEM ASC ) ';
        v_sql := v_sql || '  PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX4_INTERE' || vp_proc_instance || ' ON ' || vp_tab_entrada_cd || ' ';
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || '    NUM_AUTENTIC_NFE ASC, ';
        v_sql := v_sql || '    COD_PRODUTO ASC, ';
        v_sql := v_sql || '    QUANTIDADE ASC ) ';
        v_sql := v_sql || '  PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX5_INTERE' || vp_proc_instance || ' ON ' || vp_tab_entrada_cd || ' ';
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || '    COD_EMPRESA ASC, ';
        v_sql := v_sql || '    COD_FIS_JUR ASC, ';
        v_sql := v_sql || '    NUM_AUTENTIC_NFE ASC, ';
        v_sql := v_sql || '    NUM_ITEM ASC ) ';
        v_sql := v_sql || '  PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX6_INTERE' || vp_proc_instance || ' ON ' || vp_tab_entrada_cd || ' ';
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || '    COD_EMPRESA ASC, ';
        v_sql := v_sql || '    COD_FIS_JUR ASC ) ';
        v_sql := v_sql || '  PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX7_INTERE' || vp_proc_instance || ' ON ' || vp_tab_entrada_cd || ' ';
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || '    NUM_AUTENTIC_NFE ASC, ';
        v_sql := v_sql || '    COD_PRODUTO ASC, ';
        v_sql := v_sql || '    QUANTIDADE ASC, ';
        v_sql := v_sql || '    COD_EMPRESA ASC, ';
        v_sql := v_sql || '    COD_FIS_JUR ASC ) ';
        v_sql := v_sql || '  PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_tab_entrada_cd );

        v_sql := 'SELECT COUNT(*) QTDE_ENTRADA ';
        v_sql := v_sql || 'FROM ' || vp_tab_entrada_cd || ' ';
        v_sql := v_sql || 'WHERE PROC_ID = ' || vp_proc_instance;

        EXECUTE IMMEDIATE v_sql            INTO v_qtde_e;

        loga ( vp_tab_entrada_cd || ' CRIADA ' || v_qtde_e || ' LINHAS'
             , FALSE );
    END;

    PROCEDURE load_saidas ( vp_proc_instance IN VARCHAR2
                          , vp_cod_estab IN VARCHAR2
                          , vp_data_ini IN DATE
                          , vp_data_fim IN DATE
                          , vp_tabela_saida IN VARCHAR2
                          , vp_data_hora_ini IN VARCHAR2 )
    IS
        --RANGE DE DATAS PARA BUSCAR VENDAS
        v_data_inicial DATE := vp_data_ini; -- DATA INICIAL
        v_data_final DATE := vp_data_fim; -- DATA FINAL

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

        v_sql VARCHAR2 ( 10000 );
    BEGIN
        FOR cd IN c_data_saida ( v_data_inicial
                               , v_data_final ) LOOP
            --CARREGAR INFORMACOES DE SAIDAS
            v_sql := 'INSERT /*+APPEND*/ INTO ' || vp_tabela_saida || ' ( ';
            v_sql := v_sql || ' SELECT /*+STAR(B)*/ ' || vp_proc_instance || ', ';
            v_sql := v_sql || ' A.COD_EMPRESA, ';
            v_sql := v_sql || ' A.COD_ESTAB AS CD, ';
            v_sql := v_sql || ' A.NUM_DOCFIS AS NF, ';
            v_sql := v_sql || ' A.NUM_CONTROLE_DOCTO AS ID_PEOPLESOFT, ';
            v_sql := v_sql || ' B.NUM_ITEM AS LINHA_NF, ';
            v_sql := v_sql || ' H.COD_PRODUTO AS COD_PRODUTO, ';
            v_sql := v_sql || ' H.DESCRICAO AS DESCR_PRODUTO, ';
            v_sql := v_sql || ' A.DATA_FISCAL AS DATA_FISCAL, ';
            v_sql := v_sql || ' E.COD_ESTADO AS UF_ORIGEM, ';
            v_sql := v_sql || ' I.COD_ESTADO AS UF_DESTINO, ';
            v_sql := v_sql || ' C.COD_FIS_JUR AS DESTINO, ';
            v_sql := v_sql || ' C.CPF_CGC AS CNPJ_DESTINO, ';
            v_sql := v_sql || ' C.RAZAO_SOCIAL AS RAZAO_SOCIAL_DESTINO, ';
            v_sql := v_sql || ' A.SERIE_DOCFIS AS SERIE_NF, ';
            v_sql := v_sql || ' F.COD_CFO AS CFOP, ';
            v_sql := v_sql || ' J.COD_NATUREZA_OP AS FINALIDADE, ';
            v_sql := v_sql || ' K.COD_NBM AS NBM, ';
            v_sql := v_sql || ' A.NUM_AUTENTIC_NFE AS CHAVE_ACESSO, ';
            v_sql := v_sql || ' B.QUANTIDADE AS QTDE_SAIDA, ';
            v_sql := v_sql || ' B.VLR_UNIT AS VLR_UNIT, ';
            v_sql := v_sql || ' B.VLR_CONTAB_ITEM AS VLR_TOTAL_PRODUTO, ';
            v_sql := v_sql || ' NVL((SELECT VLR_BASE ';
            v_sql := v_sql || '      FROM MSAF.X08_BASE_MERC G ';
            v_sql := v_sql || '      WHERE G.COD_EMPRESA = B.COD_EMPRESA ';
            v_sql := v_sql || '        AND G.COD_ESTAB = B.COD_ESTAB ';
            v_sql := v_sql || '        AND G.DATA_FISCAL = B.DATA_FISCAL ';
            v_sql := v_sql || '        AND G.MOVTO_E_S = B.MOVTO_E_S ';
            v_sql := v_sql || '        AND G.NORM_DEV = B.NORM_DEV ';
            v_sql := v_sql || '        AND G.IDENT_DOCTO = B.IDENT_DOCTO ';
            v_sql := v_sql || '        AND G.IDENT_FIS_JUR = B.IDENT_FIS_JUR ';
            v_sql := v_sql || '        AND G.NUM_DOCFIS = B.NUM_DOCFIS ';
            v_sql := v_sql || '        AND G.SERIE_DOCFIS = B.SERIE_DOCFIS ';
            v_sql := v_sql || '        AND G.SUB_SERIE_DOCFIS = B.SUB_SERIE_DOCFIS ';
            v_sql := v_sql || '        AND G.DISCRI_ITEM = B.DISCRI_ITEM ';
            v_sql := v_sql || '        AND G.COD_TRIBUTACAO = ''1'' ';
            v_sql := v_sql || '        AND G.COD_TRIBUTO = ''ICMS''),0) AS VLR_BASE_ICMS, ';
            v_sql := v_sql || ' NVL((SELECT VLR_TRIBUTO ';
            v_sql := v_sql || '      FROM MSAF.X08_TRIB_MERC IT ';
            v_sql := v_sql || '      WHERE B.COD_EMPRESA = IT.COD_EMPRESA ';
            v_sql := v_sql || '        AND B.COD_ESTAB = IT.COD_ESTAB ';
            v_sql := v_sql || '        AND B.DATA_FISCAL = IT.DATA_FISCAL ';
            v_sql := v_sql || '        AND B.MOVTO_E_S = IT.MOVTO_E_S ';
            v_sql := v_sql || '        AND B.NORM_DEV = IT.NORM_DEV ';
            v_sql := v_sql || '        AND B.IDENT_DOCTO = IT.IDENT_DOCTO ';
            v_sql := v_sql || '        AND B.IDENT_FIS_JUR = IT.IDENT_FIS_JUR ';
            v_sql := v_sql || '        AND B.NUM_DOCFIS = IT.NUM_DOCFIS ';
            v_sql := v_sql || '        AND B.SERIE_DOCFIS = IT.SERIE_DOCFIS ';
            v_sql := v_sql || '        AND B.SUB_SERIE_DOCFIS = IT.SUB_SERIE_DOCFIS ';
            v_sql := v_sql || '        AND B.DISCRI_ITEM = IT.DISCRI_ITEM ';
            v_sql := v_sql || '        AND IT.COD_TRIBUTO = ''ICMS''),0) AS VLR_ICMS, ';
            v_sql := v_sql || ' NVL((SELECT ALIQ_TRIBUTO ';
            v_sql := v_sql || '      FROM MSAF.X08_TRIB_MERC IT ';
            v_sql := v_sql || '      WHERE B.COD_EMPRESA = IT.COD_EMPRESA ';
            v_sql := v_sql || '        AND B.COD_ESTAB = IT.COD_ESTAB ';
            v_sql := v_sql || '        AND B.DATA_FISCAL = IT.DATA_FISCAL  ';
            v_sql := v_sql || '        AND B.MOVTO_E_S = IT.MOVTO_E_S ';
            v_sql := v_sql || '        AND B.NORM_DEV = IT.NORM_DEV ';
            v_sql := v_sql || '        AND B.IDENT_DOCTO = IT.IDENT_DOCTO ';
            v_sql := v_sql || '        AND B.IDENT_FIS_JUR = IT.IDENT_FIS_JUR ';
            v_sql := v_sql || '        AND B.NUM_DOCFIS = IT.NUM_DOCFIS ';
            v_sql := v_sql || '        AND B.SERIE_DOCFIS = IT.SERIE_DOCFIS ';
            v_sql := v_sql || '        AND B.SUB_SERIE_DOCFIS = IT.SUB_SERIE_DOCFIS ';
            v_sql := v_sql || '        AND B.DISCRI_ITEM = IT.DISCRI_ITEM ';
            v_sql := v_sql || '        AND IT.COD_TRIBUTO = ''ICMS''),0) AS ALIQ_ICMS ';

            v_sql := v_sql || ' FROM MSAF.X07_DOCTO_FISCAL A, ';
            v_sql := v_sql || '      MSAF.X08_ITENS_MERC B, ';
            v_sql := v_sql || '      MSAF.X04_PESSOA_FIS_JUR C, ';
            v_sql := v_sql || '      MSAF.ESTABELECIMENTO D, ';
            v_sql := v_sql || '      MSAF.ESTADO E, ';
            v_sql := v_sql || '      MSAF.X2012_COD_FISCAL F, ';
            v_sql := v_sql || '      MSAF.X2013_PRODUTO H, ';
            v_sql := v_sql || '      MSAF.ESTADO I, ';
            v_sql := v_sql || '      MSAF.X2006_NATUREZA_OP J, ';
            v_sql := v_sql || '      MSAF.X2043_COD_NBM K ';

            v_sql := v_sql || ' WHERE B.COD_EMPRESA = MSAFI.DPSP.EMPRESA';
            v_sql := v_sql || '   AND B.MOVTO_E_S = ''9'' ';
            v_sql := v_sql || '   AND B.COD_ESTAB = ''' || vp_cod_estab || ''' ';
            v_sql := v_sql || '   AND B.DATA_FISCAL = TO_DATE(''' || cd.data_normal || ''',''DD/MM/YYYY'') ';

            IF ( vp_cod_estab = 'DSP910' ) THEN
                v_sql := v_sql || '   AND F.COD_CFO IN (''6102'',''6152'',''6409'',''6403'') ';
            ELSE
                v_sql := v_sql || '   AND F.COD_CFO IN (''6102'',''6152'',''6409'') ';
            END IF;

            v_sql := v_sql || '   AND A.SITUACAO  = ''N'' ';

            v_sql := v_sql || '   AND A.COD_EMPRESA = B.COD_EMPRESA ';
            v_sql := v_sql || '   AND A.COD_ESTAB   = B.COD_ESTAB ';
            v_sql := v_sql || '   AND A.DATA_FISCAL = B.DATA_FISCAL ';
            v_sql := v_sql || '   AND A.MOVTO_E_S   = B.MOVTO_E_S ';
            v_sql := v_sql || '   AND A.NORM_DEV    = B.NORM_DEV ';
            v_sql := v_sql || '   AND A.IDENT_DOCTO = B.IDENT_DOCTO ';
            v_sql := v_sql || '   AND A.IDENT_FIS_JUR = B.IDENT_FIS_JUR ';
            v_sql := v_sql || '   AND A.NUM_DOCFIS    = B.NUM_DOCFIS ';
            v_sql := v_sql || '   AND A.SERIE_DOCFIS  = B.SERIE_DOCFIS ';
            v_sql := v_sql || '   AND A.SUB_SERIE_DOCFIS = B.SUB_SERIE_DOCFIS ';

            v_sql := v_sql || '   AND A.IDENT_FIS_JUR = C.IDENT_FIS_JUR ';

            v_sql := v_sql || '   AND A.COD_EMPRESA = D.COD_EMPRESA ';
            v_sql := v_sql || '   AND A.COD_ESTAB   = D.COD_ESTAB ';

            v_sql := v_sql || '   AND D.IDENT_ESTADO = E.IDENT_ESTADO ';

            v_sql := v_sql || '   AND B.IDENT_CFO = F.IDENT_CFO ';

            v_sql := v_sql || '   AND B.IDENT_PRODUTO = H.IDENT_PRODUTO ';

            v_sql := v_sql || '   AND C.IDENT_ESTADO = I.IDENT_ESTADO ';

            v_sql := v_sql || '   AND B.IDENT_NATUREZA_OP = J.IDENT_NATUREZA_OP ';

            v_sql := v_sql || '   AND B.IDENT_NBM = K.IDENT_NBM ) ';

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
                                , v_data_inicial
                                , v_data_final
                                , SQLERRM
                                , 'E'
                                , vp_data_hora_ini );
                    -----------------------------------------------------------------
                    raise_application_error ( -20022
                                            , '!ERRO INSERT LOAD_SAIDAS!' );
            END;
        END LOOP;

        loga ( 'LOAD_SAIDAS-FIM-' || vp_cod_estab
             , FALSE );
    END;

    PROCEDURE create_tab_saida_idx ( vp_proc_instance IN VARCHAR2
                                   , vp_tabela_saida IN VARCHAR2
                                   , vp_count_saida   OUT NUMBER
                                   , vp_tabela_saida_s   OUT VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 1000 );
    BEGIN
        v_sql := 'CREATE UNIQUE INDEX PK_INTERS_' || vp_proc_instance || ' ON ' || vp_tabela_saida || ' ';
        v_sql := v_sql || '( ';
        v_sql := v_sql || '  PROC_ID        ASC, ';
        v_sql := v_sql || '  COD_EMPRESA    ASC, ';
        v_sql := v_sql || '  COD_ESTAB      ASC, ';
        v_sql := v_sql || '  NUM_DOCFIS     ASC, ';
        v_sql := v_sql || '  NUM_CONTROLE_DOCTO ASC, ';
        v_sql := v_sql || '  DATA_FISCAL    ASC, ';
        v_sql := v_sql || '  SERIE_DOCFIS   ASC, ';
        v_sql := v_sql || '  COD_PRODUTO    ASC, ';
        v_sql := v_sql || '  UF_ORIGEM      ASC, ';
        v_sql := v_sql || '  NUM_ITEM       ASC ';
        v_sql := v_sql || ') ';
        v_sql := v_sql || 'PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX1_INTERS_' || vp_proc_instance || ' ON ' || vp_tabela_saida || ' ';
        v_sql := v_sql || '   ( ';
        v_sql := v_sql || '     PROC_ID      ASC ';
        v_sql := v_sql || '   ) ';
        v_sql := v_sql || '   PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX2_INTERS_' || vp_proc_instance || ' ON ' || vp_tabela_saida || ' ';
        v_sql := v_sql || '   ( ';
        v_sql := v_sql || '     PROC_ID     ASC, ';
        v_sql := v_sql || '     COD_PRODUTO ASC, ';
        v_sql := v_sql || '     DATA_FISCAL ASC ';
        v_sql := v_sql || '   ) ';
        v_sql := v_sql || '   PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_tabela_saida );

        v_sql := 'SELECT COUNT(*) QTDE_SAIDA ';
        v_sql := v_sql || 'FROM ' || vp_tabela_saida || ' ';
        v_sql := v_sql || 'WHERE PROC_ID = ' || vp_proc_instance;
        vp_count_saida := 0;

        EXECUTE IMMEDIATE v_sql            INTO vp_count_saida;

        loga ( vp_tabela_saida || ' CRIADA ' || vp_count_saida || ' LINHAS'
             , FALSE );

        -------------------------------------------------------------------------
        ---CRIAR TABELA SINTETICA DA SAIDA---------------------------------------
        -------------------------------------------------------------------------

        vp_tabela_saida_s := 'DPSP_INTERS_S_' || vp_proc_instance;

        v_sql := 'CREATE TABLE ' || vp_tabela_saida_s || ' ( ';
        v_sql := v_sql || ' COD_PRODUTO  VARCHAR2(35), ';
        v_sql := v_sql || ' DATA_FISCAL_S DATE ) ';
        v_sql := v_sql || ' PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        save_tmp_control ( vp_proc_instance
                         , vp_tabela_saida_s );

        EXECUTE IMMEDIATE
               'INSERT /*+APPEND*/ INTO '
            || vp_tabela_saida_s
            || ' SELECT DISTINCT COD_PRODUTO, DATA_FISCAL FROM '
            || vp_tabela_saida;

        COMMIT;

        v_sql := 'CREATE UNIQUE INDEX PK_INTERSS_' || vp_proc_instance || ' ON ' || vp_tabela_saida_s || ' ';
        v_sql := v_sql || '( ';
        v_sql := v_sql || '  COD_PRODUTO   ASC, ';
        v_sql := v_sql || '  DATA_FISCAL_S ASC ) ';
        v_sql := v_sql || 'PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_tabela_saida_s );

        v_sql := 'SELECT COUNT(*) QTDE_SAIDA ';
        v_sql := v_sql || 'FROM ' || vp_tabela_saida_s || ' ';
        vp_count_saida := 0;

        EXECUTE IMMEDIATE v_sql            INTO vp_count_saida;

        loga ( vp_tabela_saida_s || ' CRIADA ' || vp_count_saida || ' LINHAS'
             , FALSE );
    END;

    PROCEDURE load_entradas ( vp_proc_instance IN VARCHAR2
                            , vp_cod_estab IN VARCHAR2
                            , vp_tabela_entrada IN VARCHAR2
                            , vp_tabela_saida_s IN VARCHAR2
                            , vp_tempo_entrada IN NUMBER
                            , vp_data_inicial IN DATE
                            , vp_data_final IN DATE
                            , vp_data_hora_ini IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 4000 );
        v_insert VARCHAR2 ( 2000 );
        c_entrada SYS_REFCURSOR;

        TYPE cur_tab_entrada IS RECORD
        (
            proc_id NUMBER ( 30 )
          , data_fiscal_s DATE
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
          , cod_situacao_b VARCHAR2 ( 2 )
          , data_emissao DATE
          , cod_estado VARCHAR2 ( 2 )
          , num_controle_docto VARCHAR2 ( 12 )
          , num_autentic_nfe VARCHAR2 ( 80 )
        );

        TYPE c_tab_entrada IS TABLE OF cur_tab_entrada;

        tab_e c_tab_entrada;
    BEGIN
        v_sql := 'SELECT DISTINCT ''' || vp_proc_instance || ''', ';
        v_sql := v_sql || ' A.DATA_FISCAL_S, ';
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
        v_sql := v_sql || ' A.COD_SITUACAO_B, ';
        v_sql := v_sql || ' A.DATA_EMISSAO, ';
        v_sql := v_sql || ' A.COD_ESTADO, ';
        v_sql := v_sql || ' A.NUM_CONTROLE_DOCTO, ';
        v_sql := v_sql || ' A.NUM_AUTENTIC_NFE ';
        v_sql := v_sql || ' FROM ( ';
        v_sql := v_sql || '     SELECT  /*+PARALLEL(8) ';
        v_sql := v_sql || '            	   INDEX(D PK_X2013_PRODUTO) ';
        v_sql := v_sql || '		           INDEX(A PK_X2043_COD_NBM) ';
        v_sql := v_sql || '				   INDEX(G PK_X04_PESSOA_FIS_JUR)*/ ';
        v_sql := v_sql || '              X08.COD_EMPRESA, ';
        v_sql := v_sql || '              X08.COD_ESTAB, ';
        v_sql := v_sql || '              X08.DATA_FISCAL, ';
        v_sql := v_sql || '              X08.MOVTO_E_S, ';
        v_sql := v_sql || '              X08.NORM_DEV, ';
        v_sql := v_sql || '              X08.IDENT_DOCTO, ';
        v_sql := v_sql || '              X08.IDENT_FIS_JUR, ';
        v_sql := v_sql || '              X08.NUM_DOCFIS, ';
        v_sql := v_sql || '              X08.SERIE_DOCFIS, ';
        v_sql := v_sql || '              X08.SUB_SERIE_DOCFIS, ';
        v_sql := v_sql || '              X08.DISCRI_ITEM, ';
        v_sql := v_sql || '              X08.NUM_ITEM, ';
        v_sql := v_sql || '              G.COD_FIS_JUR, ';
        v_sql := v_sql || '              G.CPF_CGC,  ';
        v_sql := v_sql || '              A.COD_NBM, ';
        v_sql := v_sql || '              B.COD_CFO, ';
        v_sql := v_sql || '              C.COD_NATUREZA_OP, ';
        v_sql := v_sql || '              D.COD_PRODUTO, ';
        v_sql := v_sql || '              X08.VLR_CONTAB_ITEM, ';
        v_sql := v_sql || '              X08.QUANTIDADE, ';
        v_sql := v_sql || '              X08.VLR_UNIT, ';
        v_sql := v_sql || '              E.COD_SITUACAO_B, ';
        v_sql := v_sql || '              X07.DATA_EMISSAO, ';
        v_sql := v_sql || '              H.COD_ESTADO, ';
        v_sql := v_sql || '              X07.NUM_CONTROLE_DOCTO, ';
        v_sql := v_sql || '              '''' || X07.NUM_AUTENTIC_NFE AS NUM_AUTENTIC_NFE, ';
        v_sql := v_sql || '              P.DATA_FISCAL_S, ';
        v_sql := v_sql || '              RANK() OVER( ';
        v_sql := v_sql || '                           PARTITION BY X08.COD_ESTAB, D.COD_PRODUTO, P.DATA_FISCAL_S ';
        v_sql :=
               v_sql
            || '                           ORDER BY X08.DATA_FISCAL DESC, X07.DATA_EMISSAO DESC, X08.NUM_DOCFIS DESC, X08.DISCRI_ITEM DESC) RANK ';
        v_sql := v_sql || '        FROM X08_ITENS_MERC X08, ';
        v_sql := v_sql || '             X07_DOCTO_FISCAL X07, ';
        v_sql := v_sql || '             X2013_PRODUTO D, ';
        v_sql := v_sql || '             X04_PESSOA_FIS_JUR G, ';
        v_sql := v_sql || '             ' || vp_tabela_saida_s || ' P, ';
        v_sql := v_sql || '             X2043_COD_NBM A, ';
        v_sql := v_sql || '             X2012_COD_FISCAL B, ';
        v_sql := v_sql || '             X2006_NATUREZA_OP C, ';
        v_sql := v_sql || '             Y2026_SIT_TRB_UF_B E, ';
        v_sql := v_sql || '             ESTADO H  ';

        v_sql := v_sql || '        WHERE X08.IDENT_NBM          = A.IDENT_NBM ';
        v_sql := v_sql || '          AND X08.IDENT_CFO          = B.IDENT_CFO ';
        v_sql :=
               v_sql
            || '          AND B.COD_CFO             IN (''1102'',''2102'',''1403'',''2403'',''1910'',''2910'',''1917'',''2917'',''1152'',''2152'',''1409'',''2409'') ';
        v_sql := v_sql || '          AND X07.SITUACAO           = ''N'' ';
        v_sql := v_sql || '          AND X08.IDENT_NATUREZA_OP  = C.IDENT_NATUREZA_OP ';
        v_sql := v_sql || '          AND X08.IDENT_SITUACAO_B   = E.IDENT_SITUACAO_B ';
        v_sql := v_sql || '          AND X07.VLR_PRODUTO       <> 0 ';
        v_sql := v_sql || '          AND X08.IDENT_PRODUTO      = D.IDENT_PRODUTO ';
        v_sql := v_sql || '          AND X07.IDENT_FIS_JUR      = G.IDENT_FIS_JUR ';
        v_sql := v_sql || '          AND G.IDENT_ESTADO         = H.IDENT_ESTADO ';
        ---
        v_sql := v_sql || '          AND X07.COD_EMPRESA        = X08.COD_EMPRESA ';
        v_sql := v_sql || '          AND X07.COD_ESTAB          = X08.COD_ESTAB ';
        v_sql := v_sql || '          AND X07.DATA_FISCAL        = X08.DATA_FISCAL ';
        v_sql := v_sql || '          AND X07.MOVTO_E_S          = X08.MOVTO_E_S ';
        v_sql := v_sql || '          AND X07.NORM_DEV           = X08.NORM_DEV ';
        v_sql := v_sql || '          AND X07.IDENT_DOCTO        = X08.IDENT_DOCTO ';
        v_sql := v_sql || '          AND X07.IDENT_FIS_JUR      = X08.IDENT_FIS_JUR ';
        v_sql := v_sql || '          AND X07.NUM_DOCFIS         = X08.NUM_DOCFIS ';
        v_sql := v_sql || '          AND X07.SERIE_DOCFIS       = X08.SERIE_DOCFIS ';
        v_sql := v_sql || '          AND X07.SUB_SERIE_DOCFIS   = X08.SUB_SERIE_DOCFIS ';
        ---
        v_sql := v_sql || '          AND X08.MOVTO_E_S         <> ''9'' ';
        v_sql := v_sql || '          AND X08.COD_EMPRESA        = ''' || mcod_empresa || ''' ';
        v_sql := v_sql || '          AND X08.COD_ESTAB          = ''' || vp_cod_estab || ''' ';
        v_sql :=
               v_sql
            || '          AND NOT EXISTS (SELECT ''Y'' FROM MSAFI.DSP_ESTABELECIMENTO EST WHERE EST.TIPO = ''L'' AND EST.COD_EMPRESA = X08.COD_EMPRESA AND EST.COD_ESTAB = X08.COD_ESTAB ) ';
        v_sql := v_sql || '          AND D.COD_PRODUTO          = P.COD_PRODUTO ';
        v_sql :=
               v_sql
            || '          AND X08.DATA_FISCAL       >= TO_DATE('''
            || TO_CHAR ( vp_data_final
                       , 'DD/MM/YYYY' )
            || ''',''DD/MM/YYYY'') - (365*'
            || vp_tempo_entrada
            || ') '; --SETUP
        v_sql := v_sql || '          AND X08.DATA_FISCAL        < P.DATA_FISCAL_S ';
        v_sql := v_sql || '       ) A ';
        v_sql := v_sql || ' WHERE A.RANK = 1 ';

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
                --ENVIAR EMAIL DE ERRO-------------------------------------------
                envia_email ( mcod_empresa
                            , vp_data_inicial
                            , vp_data_final
                            , SQLERRM
                            , 'E'
                            , vp_data_hora_ini );
                -----------------------------------------------------------------
                raise_application_error ( -20007
                                        , '!ERRO SELECT DADOS ENTRADAS!' );
        END;

        LOOP
            FETCH c_entrada
                BULK COLLECT INTO tab_e
                LIMIT 100;

            FOR i IN 1 .. tab_e.COUNT LOOP
                v_insert :=
                       'INSERT /*+APPEND_VALUES*/ INTO '
                    || vp_tabela_entrada
                    || ' VALUES ('
                    || tab_e ( i ).proc_id
                    || ','
                    || 'TO_DATE('''
                    || tab_e ( i ).data_fiscal_s
                    || ''',''DD/MM/YYYY''),'''
                    || tab_e ( i ).cod_empresa
                    || ''','''
                    || tab_e ( i ).cod_estab
                    || ''','
                    || 'TO_DATE('''
                    || tab_e ( i ).data_fiscal
                    || ''',''DD/MM/YYYY''),'''
                    || tab_e ( i ).movto_e_s
                    || ''','''
                    || tab_e ( i ).norm_dev
                    || ''','''
                    || tab_e ( i ).ident_docto
                    || ''','''
                    || tab_e ( i ).ident_fis_jur
                    || ''','''
                    || tab_e ( i ).num_docfis
                    || ''','''
                    || tab_e ( i ).serie_docfis
                    || ''','''
                    || tab_e ( i ).sub_serie_docfis
                    || ''','''
                    || tab_e ( i ).discri_item
                    || ''','''
                    || tab_e ( i ).num_item
                    || ''','''
                    || tab_e ( i ).cod_fis_jur
                    || ''','''
                    || tab_e ( i ).cpf_cgc
                    || ''','''
                    || tab_e ( i ).cod_nbm
                    || ''','''
                    || tab_e ( i ).cod_cfo
                    || ''','''
                    || tab_e ( i ).cod_natureza_op
                    || ''','''
                    || tab_e ( i ).cod_produto
                    || ''','
                    || 'TO_NUMBER('''
                    || tab_e ( i ).vlr_contab_item
                    || '''),TO_NUMBER('''
                    || tab_e ( i ).quantidade
                    || '''),TO_NUMBER('''
                    || tab_e ( i ).vlr_unit
                    || '''),'''
                    || tab_e ( i ).cod_situacao_b
                    || ''','
                    || 'TO_DATE('''
                    || tab_e ( i ).data_emissao
                    || ''',''DD/MM/YYYY''),'''
                    || tab_e ( i ).cod_estado
                    || ''','''
                    || tab_e ( i ).num_controle_docto
                    || ''','''
                    || tab_e ( i ).num_autentic_nfe
                    || ''') ';

                BEGIN
                    EXECUTE IMMEDIATE v_insert;

                    COMMIT;
                EXCEPTION
                    WHEN OTHERS THEN
                        loga ( 'SQLERRM: ' || SQLERRM
                             , FALSE );
                        loga ( SUBSTR ( v_insert
                                      , 1
                                      , 1024 )
                             , FALSE );
                        loga ( SUBSTR ( v_insert
                                      , 1024
                                      , 1024 )
                             , FALSE );
                        loga ( SUBSTR ( v_insert
                                      , 2048
                                      , 1024 )
                             , FALSE );
                        loga ( SUBSTR ( v_insert
                                      , 3072 )
                             , FALSE );
                        --ENVIAR EMAIL DE ERRO-------------------------------------------
                        envia_email ( mcod_empresa
                                    , vp_data_inicial
                                    , vp_data_final
                                    , SQLERRM
                                    , 'E'
                                    , vp_data_hora_ini );
                        -----------------------------------------------------------------
                        raise_application_error ( -20007
                                                , '!ERRO INSERT DADOS ENTRADA!' );
                END;
            END LOOP;

            tab_e.delete;

            EXIT WHEN c_entrada%NOTFOUND;
        END LOOP;

        COMMIT;

        CLOSE c_entrada;
    END; --PROCEDURE LOAD_ENTRADAS

    --PROCEDURE PARA CRIAR TABELAS TEMP DE ALIQ E PMC
    PROCEDURE load_aliq_interna ( vp_proc_id IN NUMBER
                                , vp_nome_tabela_aliq   OUT VARCHAR2
                                , vp_tabela_saida IN VARCHAR2
                                , vp_data_inicial IN DATE
                                , vp_data_final IN DATE
                                , vp_data_hora_ini IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 2000 );
        c_aliq_interna SYS_REFCURSOR;

        TYPE cur_tab_aliq IS RECORD
        (
            proc_id NUMBER ( 30 )
          , cod_produto VARCHAR2 ( 25 )
          , aliq_interna VARCHAR2 ( 4 )
        );

        TYPE c_tab_aliq IS TABLE OF cur_tab_aliq;

        tab_aliq c_tab_aliq;

        errors NUMBER;
        dml_errors EXCEPTION;
    BEGIN
        vp_nome_tabela_aliq := 'DPSP_INTERALIQ_' || vp_proc_id;

        v_sql := 'CREATE TABLE ' || vp_nome_tabela_aliq;
        v_sql := v_sql || ' (';
        v_sql := v_sql || 'PROC_ID      NUMBER(30),';
        v_sql := v_sql || 'COD_PRODUTO  VARCHAR2(25),';
        v_sql := v_sql || 'ALIQ_INTERNA VARCHAR2(4)';
        v_sql := v_sql || ' )';

        EXECUTE IMMEDIATE v_sql;

        ---
        save_tmp_control ( vp_proc_id
                         , vp_nome_tabela_aliq );

        v_sql := ' SELECT DISTINCT ';
        v_sql := v_sql || '        ' || vp_proc_id || ', ';
        v_sql := v_sql || '        A.COD_PRODUTO, ';
        v_sql := v_sql || '        A.ALIQ_INTERNA ';
        v_sql := v_sql || ' FROM ( ';
        v_sql := v_sql || '   SELECT /*+DRIVING_SITE(B)*/ A.COD_PRODUTO AS COD_PRODUTO, ';
        v_sql := v_sql || '          REPLACE(B.XLATLONGNAME,''%'','''') AS ALIQ_INTERNA ';
        v_sql := v_sql || '    FROM ' || vp_tabela_saida || ' A, ';
        v_sql :=
               v_sql
            || '         (SELECT B.SETID, B.INV_ITEM_ID, B.CRIT_STATE_TO_PBL, B.CRIT_STATE_FR_PBL, B.EFFDT, B.XLATLONGNAME ';
        v_sql := v_sql || '          FROM ( ';
        v_sql :=
               v_sql
            || '          SELECT B.SETID, B.INV_ITEM_ID, B.CRIT_STATE_TO_PBL, B.CRIT_STATE_FR_PBL, B.EFFDT, C.XLATLONGNAME, ';
        v_sql :=
               v_sql
            || '                 RANK() OVER( PARTITION BY B.SETID, B.INV_ITEM_ID, B.CRIT_STATE_TO_PBL, B.CRIT_STATE_FR_PBL ';
        v_sql := v_sql || '                              ORDER BY B.EFFDT DESC) RANK ';
        v_sql := v_sql || '          FROM MSAFI.PS_DSP_ITEM_LN_MVA B, ';
        v_sql := v_sql || '               MSAFI.PSXLATITEM C ';
        v_sql := v_sql || '          WHERE C.FIELDNAME  = ''DSP_ALIQ_ICMS'' ';
        v_sql := v_sql || '            AND C.FIELDVALUE = B.DSP_ALIQ_ICMS ';
        v_sql := v_sql || '            AND C.EFFDT = (SELECT MAX(CC.EFFDT) ';
        v_sql := v_sql || '                           FROM MSAFI.PSXLATITEM CC ';
        v_sql := v_sql || '                           WHERE CC.FIELDNAME  = C.FIELDNAME ';
        v_sql := v_sql || '                           AND CC.FIELDVALUE = C.FIELDVALUE ';
        v_sql := v_sql || '                           AND CC.EFFDT     <= SYSDATE) ';
        v_sql := v_sql || '               ) B ';
        v_sql := v_sql || '           WHERE B.RANK = 1 ';
        v_sql := v_sql || '          ) B, ';
        v_sql := v_sql || '         MSAFI.DSP_ESTABELECIMENTO D ';
        v_sql := v_sql || '    WHERE A.PROC_ID     = ' || vp_proc_id || ' ';
        v_sql := v_sql || '      AND B.SETID       = ''GERAL'' ';
        v_sql := v_sql || '      AND B.INV_ITEM_ID = A.COD_PRODUTO ';
        v_sql := v_sql || '      AND D.COD_EMPRESA = ''' || mcod_empresa || ''' ';
        v_sql := v_sql || '      AND D.COD_ESTAB   = A.COD_ESTAB ';
        v_sql := v_sql || '      AND B.CRIT_STATE_TO_PBL = D.COD_ESTADO ';
        v_sql := v_sql || '      AND B.CRIT_STATE_FR_PBL = D.COD_ESTADO ) A ';

        OPEN c_aliq_interna FOR v_sql;

        LOOP
            FETCH c_aliq_interna
                BULK COLLECT INTO tab_aliq
                LIMIT 100;

            BEGIN
                FORALL i IN tab_aliq.FIRST .. tab_aliq.LAST
                    EXECUTE IMMEDIATE
                        'INSERT /*+APPEND_VALUES*/ INTO ' || vp_nome_tabela_aliq || ' VALUES (:1, :2, :3) '
                        USING tab_aliq ( i ).proc_id
                            , tab_aliq ( i ).cod_produto
                            , tab_aliq ( i ).aliq_interna;
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
                                            , '!ERRO INSERT ALIQ!' );
            END;

            COMMIT;
            tab_aliq.delete;

            EXIT WHEN c_aliq_interna%NOTFOUND;
        END LOOP;

        COMMIT;

        CLOSE c_aliq_interna;

        v_sql := 'CREATE INDEX PK_ALIQ_' || vp_proc_id || ' ON ' || vp_nome_tabela_aliq;
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || '   PROC_ID     ASC,';
        v_sql := v_sql || '   COD_PRODUTO ASC ';
        v_sql := v_sql || ' ) ';
        v_sql := v_sql || ' PCTFREE 10 ';

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX1_ALIQ_' || vp_proc_id || ' ON ' || vp_nome_tabela_aliq;
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || '   PROC_ID     ASC,';
        v_sql := v_sql || '   COD_PRODUTO ASC, ';
        v_sql := v_sql || '   ALIQ_INTERNA ASC ';
        v_sql := v_sql || ' ) ';
        v_sql := v_sql || ' PCTFREE 10 ';

        EXECUTE IMMEDIATE v_sql;

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_nome_tabela_aliq );
        loga ( vp_nome_tabela_aliq || ' CRIADA'
             , FALSE );
    END;

    PROCEDURE load_dados_xml_dpsp ( vp_proc_id IN VARCHAR2
                                  , vp_tabela_xml_dpsp   OUT VARCHAR2
                                  , vp_tab_entrada_c IN VARCHAR2
                                  , vp_data_ini IN DATE
                                  , vp_data_fim IN DATE
                                  , vp_data_hora_ini IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 4000 );
        v_insert VARCHAR2 ( 500 );
        c_xml SYS_REFCURSOR;
        v_qtde_xml NUMBER := 0;

        TYPE cur_tab_xml IS RECORD
        (
            proc_id NUMBER ( 30 )
          , nf_brl_id VARCHAR2 ( 12 )
          , chave_acesso VARCHAR2 ( 80 )
          , nf_brl_line_num NUMBER ( 5 )
          , inv_item_id VARCHAR2 ( 35 )
          , ---
            cfop_saida VARCHAR2 ( 5 )
          , quantidade NUMBER ( 13, 4 )
          , vlr_base_icms NUMBER ( 17, 2 )
          , vlr_icms NUMBER ( 17, 2 )
          , aliq_reducao NUMBER ( 5, 2 )
          , vlr_base_icms_st NUMBER ( 17, 2 )
          , vlr_icms_st NUMBER ( 17, 2 )
          , vlr_base_icmsst_ret NUMBER ( 17, 2 )
          , vlr_icmsst_ret NUMBER ( 17, 2 )
        );

        TYPE c_tab_xml IS TABLE OF cur_tab_xml;

        tab_xml c_tab_xml;
    BEGIN
        vp_tabela_xml_dpsp := 'DPSP_INTERXMLD_' || vp_proc_id;

        v_sql := 'CREATE TABLE ' || vp_tabela_xml_dpsp || ' ( ';
        v_sql := v_sql || ' PROC_ID      	NUMBER(30), ';
        v_sql := v_sql || ' NF_BRL_ID	 	VARCHAR2(12), ';
        v_sql := v_sql || ' CHAVE_ACESSO 	VARCHAR2(80), ';
        v_sql := v_sql || ' NF_BRL_LINE_NUM NUMBER(5), ';
        v_sql := v_sql || ' INV_ITEM_ID  	VARCHAR2(35), ';
        ---
        v_sql := v_sql || ' CFOP_SAIDA 		   VARCHAR2(5), ';
        v_sql := v_sql || ' QUANTIDADE 		   NUMBER(13,4), ';
        v_sql := v_sql || ' VLR_BASE_ICMS 	   NUMBER(17,2), ';
        v_sql := v_sql || ' VLR_ICMS 		   NUMBER(17,2), ';
        v_sql := v_sql || ' ALIQ_REDUCAO 	   NUMBER(5,2), ';
        v_sql := v_sql || ' VLR_BASE_ICMS_ST   NUMBER(17,2), ';
        v_sql := v_sql || ' VLR_ICMS_ST 	   NUMBER(17,2), ';
        v_sql := v_sql || ' VLR_BASE_ICMSST_RET NUMBER(17,2), ';
        v_sql := v_sql || ' VLR_ICMSST_RET 	    NUMBER(17,2)) ';
        v_sql := v_sql || ' PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        ---
        save_tmp_control ( vp_proc_id
                         , vp_tabela_xml_dpsp );

        loga ( 'XML TEMP DPSP-INI'
             , FALSE );

        v_sql :=
               'SELECT /*+DRIVING_SITE(X)*/ '
            || vp_proc_id
            || ' AS PROC_ID, X.NF_BRL_ID, X.CHAVE_ACESSO, X.NF_BRL_LINE_NUM, X.INV_ITEM_ID, X.CFOP_SAIDA, ';
        v_sql := v_sql || 'X.QUANTIDADE, X.VLR_BASE_ICMS, X.VLR_ICMS, X.ALIQ_REDUCAO, X.VLR_BASE_ICMS_ST, ';
        v_sql := v_sql || 'X.VLR_ICMS_ST, X.VLR_BASE_ICMSST_RET, X.VLR_ICMSST_RET ';
        v_sql := v_sql || 'FROM ( ';
        v_sql := v_sql || '		SELECT LN.NF_BRL_ID, ';
        v_sql := v_sql || '			  CHAVE.NFEE_KEY_BBL AS CHAVE_ACESSO, ';
        v_sql := v_sql || '			  LN.NF_BRL_LINE_NUM, ';
        v_sql := v_sql || '			  LN.INV_ITEM_ID, ';
        v_sql := v_sql || '			  LN.QTY_NF_BRL AS QUANTIDADE, ';
        v_sql := v_sql || '			  LN.CFO_BRL_CD AS CFOP_SAIDA, ';
        v_sql := v_sql || '			  NVL((SELECT IMP.TAX_BRL_BSE ';
        v_sql := v_sql || '		           FROM MSAFI.PS_AR_IMP_BBL IMP ';
        v_sql := v_sql || '		           WHERE IMP.BUSINESS_UNIT = LN.BUSINESS_UNIT ';
        v_sql := v_sql || '		             AND IMP.NF_BRL_ID = LN.NF_BRL_ID ';
        v_sql := v_sql || '		             AND IMP.NF_BRL_LINE_NUM = LN.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '		             AND IMP.TAX_ID_BBL = ''ICMS''),0) AS VLR_BASE_ICMS, ';
        v_sql := v_sql || '		      NVL((SELECT IMP.TAX_BRL_AMT ';
        v_sql := v_sql || '		       	  FROM MSAFI.PS_AR_IMP_BBL IMP ';
        v_sql := v_sql || '		           WHERE IMP.BUSINESS_UNIT = LN.BUSINESS_UNIT ';
        v_sql := v_sql || '		             AND IMP.NF_BRL_ID = LN.NF_BRL_ID ';
        v_sql := v_sql || '		             AND IMP.NF_BRL_LINE_NUM = LN.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '		             AND IMP.TAX_ID_BBL = ''ICMS''),0) AS VLR_ICMS, ';
        v_sql := v_sql || '		      0 AS ALIQ_REDUCAO, ';
        v_sql := v_sql || '		      NVL((SELECT IMP.TAX_BRL_BSE ';
        v_sql := v_sql || '		      	  FROM MSAFI.PS_AR_IMP_BBL IMP ';
        v_sql := v_sql || '		           WHERE IMP.BUSINESS_UNIT = LN.BUSINESS_UNIT ';
        v_sql := v_sql || '		             AND IMP.NF_BRL_ID = LN.NF_BRL_ID ';
        v_sql := v_sql || '		             AND IMP.NF_BRL_LINE_NUM = LN.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '		             AND IMP.TAX_ID_BBL = ''ICMST''),0) AS VLR_BASE_ICMS_ST, ';
        v_sql := v_sql || '		      NVL((SELECT IMP.TAX_BRL_AMT ';
        v_sql := v_sql || '		      	  FROM MSAFI.PS_AR_IMP_BBL IMP ';
        v_sql := v_sql || '		           WHERE IMP.BUSINESS_UNIT = LN.BUSINESS_UNIT ';
        v_sql := v_sql || '		             AND IMP.NF_BRL_ID = LN.NF_BRL_ID ';
        v_sql := v_sql || '		             AND IMP.NF_BRL_LINE_NUM = LN.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '		             AND IMP.TAX_ID_BBL = ''ICMST''),0) AS VLR_ICMS_ST, ';
        v_sql := v_sql || '		      0 AS VLR_BASE_ICMSST_RET, ';
        v_sql := v_sql || '		      0 AS VLR_ICMSST_RET ';
        v_sql := v_sql || '		FROM MSAFI.PS_AR_NFRET_BBL CHAVE, ';
        v_sql := v_sql || '		     MSAFI.PS_AR_ITENS_NF_BBL LN ';
        v_sql := v_sql || '		WHERE CHAVE.BUSINESS_UNIT = LN.BUSINESS_UNIT ';
        v_sql := v_sql || '		  AND CHAVE.NF_BRL_ID = LN.NF_BRL_ID ) X ';
        v_sql := v_sql || 'WHERE EXISTS (SELECT ''Y'' FROM ' || vp_tab_entrada_c || ' E ';
        v_sql := v_sql || '                WHERE E.NUM_AUTENTIC_NFE = X.CHAVE_ACESSO) ';

        BEGIN
            OPEN c_xml FOR v_sql;
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
                                        , '!ERRO SELECT DADOS XML DPSP!' );
        END;

        LOOP
            FETCH c_xml
                BULK COLLECT INTO tab_xml
                LIMIT 100;

            FOR i IN 1 .. tab_xml.COUNT LOOP
                v_insert :=
                       'INSERT /*+APPEND_VALUES*/ INTO '
                    || vp_tabela_xml_dpsp
                    || ' VALUES ('
                    || tab_xml ( i ).proc_id
                    || ','''
                    || tab_xml ( i ).nf_brl_id
                    || ''','''
                    || tab_xml ( i ).chave_acesso
                    || ''','
                    || tab_xml ( i ).nf_brl_line_num
                    || ','''
                    || tab_xml ( i ).inv_item_id
                    || ''','''
                    || tab_xml ( i ).cfop_saida
                    || ''','
                    || 'TO_NUMBER('''
                    || tab_xml ( i ).quantidade
                    || '''),TO_NUMBER('''
                    || tab_xml ( i ).vlr_base_icms
                    || '''),TO_NUMBER('''
                    || tab_xml ( i ).vlr_icms
                    || '''),TO_NUMBER('''
                    || tab_xml ( i ).aliq_reducao
                    || '''),TO_NUMBER('''
                    || tab_xml ( i ).vlr_base_icms_st
                    || '''),TO_NUMBER('''
                    || tab_xml ( i ).vlr_icms_st
                    || '''),TO_NUMBER('''
                    || tab_xml ( i ).vlr_base_icmsst_ret
                    || '''),TO_NUMBER('''
                    || tab_xml ( i ).vlr_icmsst_ret
                    || '''))';

                BEGIN
                    EXECUTE IMMEDIATE v_insert;

                    COMMIT;
                EXCEPTION
                    WHEN OTHERS THEN
                        loga ( 'SQLERRM: ' || SQLERRM
                             , FALSE );
                        loga ( SUBSTR ( v_insert
                                      , 1
                                      , 1024 )
                             , FALSE );
                        loga ( SUBSTR ( v_insert
                                      , 1024
                                      , 1024 )
                             , FALSE );
                        loga ( SUBSTR ( v_insert
                                      , 2048
                                      , 1024 )
                             , FALSE );
                        loga ( SUBSTR ( v_insert
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
                                                , '!ERRO INSERT DADOS XML DPSP!' );
                END;
            END LOOP;

            tab_xml.delete;

            EXIT WHEN c_xml%NOTFOUND;
        END LOOP;

        COMMIT;

        CLOSE c_xml;

        v_sql := 'CREATE UNIQUE INDEX PK_IXMLDPSP' || vp_proc_id || ' ON ' || vp_tabela_xml_dpsp || ' ';
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || '    PROC_ID         ASC, ';
        v_sql := v_sql || '    NF_BRL_ID	   ASC, ';
        v_sql := v_sql || '    CHAVE_ACESSO    ASC, ';
        v_sql := v_sql || '    NF_BRL_LINE_NUM ASC, ';
        v_sql := v_sql || '    INV_ITEM_ID     ASC ';
        v_sql := v_sql || '  ) ';
        v_sql := v_sql || '  PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX1_IXMLDPSP' || vp_proc_id || ' ON ' || vp_tabela_xml_dpsp || ' ';
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || '    CHAVE_ACESSO    ASC, ';
        v_sql := v_sql || '    NF_BRL_LINE_NUM ASC, ';
        v_sql := v_sql || '    INV_ITEM_ID     ASC ';
        v_sql := v_sql || '  ) ';
        v_sql := v_sql || '  PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_tabela_xml_dpsp );

        v_sql := 'SELECT COUNT(*) QTDE_XML ';
        v_sql := v_sql || 'FROM ' || vp_tabela_xml_dpsp || ' ';
        v_sql := v_sql || 'WHERE PROC_ID = ' || vp_proc_id;

        EXECUTE IMMEDIATE v_sql            INTO v_qtde_xml;

        loga ( 'XML TEMP DPSP-FIM ' || v_qtde_xml
             , FALSE );
    END; --LOAD_DADOS_XML_DPSP

    PROCEDURE load_dados_xml ( vp_proc_id IN VARCHAR2
                             , vp_cod_empresa IN VARCHAR2
                             , vp_tab_entrada_c IN VARCHAR2
                             , vp_tabela_xml   OUT VARCHAR2
                             , vp_tabela_xml_dpsp IN VARCHAR2
                             , vp_data_inicial IN DATE
                             , vp_data_final IN DATE
                             , vp_data_hora_ini IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 4000 );
        v_insert VARCHAR2 ( 500 );
        c_xml SYS_REFCURSOR;
        v_qtde_xml NUMBER := 0;

        TYPE cur_tab_xml IS RECORD
        (
            proc_id NUMBER ( 30 )
          , num_controle_docto VARCHAR2 ( 12 )
          , num_autentic_nfe VARCHAR2 ( 80 )
          , num_item NUMBER ( 5 )
          , cod_produto VARCHAR2 ( 35 )
          , ---
            cfop_forn VARCHAR2 ( 5 )
          , vlr_base_icms NUMBER ( 17, 2 )
          , vlr_icms NUMBER ( 17, 2 )
          , aliq_reducao NUMBER ( 5, 2 )
          , vlr_base_icms_st NUMBER ( 17, 2 )
          , vlr_icms_st NUMBER ( 17, 2 )
          , vlr_base_icmsst_ret NUMBER ( 17, 2 )
          , vlr_icmsst_ret NUMBER ( 17, 2 )
        );

        TYPE c_tab_xml IS TABLE OF cur_tab_xml;

        tab_xml c_tab_xml;
    BEGIN
        vp_tabela_xml := 'DPSP_INTERXML' || vp_proc_id;

        v_sql := 'CREATE TABLE ' || vp_tabela_xml || ' ( ';
        v_sql := v_sql || ' PROC_ID             NUMBER(30), ';
        v_sql := v_sql || ' NUM_CONTROLE_DOCTO  VARCHAR2(12), ';
        v_sql := v_sql || ' NUM_AUTENTIC_NFE    VARCHAR2(80), ';
        v_sql := v_sql || ' NUM_ITEM            NUMBER(5), ';
        v_sql := v_sql || ' COD_PRODUTO         VARCHAR2(35), ';
        ---
        v_sql := v_sql || ' CFOP_FORN 		   VARCHAR2(5), ';
        v_sql := v_sql || ' VLR_BASE_ICMS 	   NUMBER(17,2), ';
        v_sql := v_sql || ' VLR_ICMS 		   NUMBER(17,2), ';
        v_sql := v_sql || ' ALIQ_REDUCAO 	   NUMBER(5,2), ';
        v_sql := v_sql || ' VLR_BASE_ICMS_ST   NUMBER(17,2), ';
        v_sql := v_sql || ' VLR_ICMS_ST 	   NUMBER(17,2), ';
        v_sql := v_sql || ' VLR_BASE_ICMSST_RET NUMBER(17,2), ';
        v_sql := v_sql || ' VLR_ICMSST_RET 	    NUMBER(17,2)) ';
        v_sql := v_sql || ' PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        ---
        save_tmp_control ( vp_proc_id
                         , vp_tabela_xml );

        loga ( 'XML1-INI'
             , FALSE );

        ---XML DE FORNECEDORES
        v_sql := ' SELECT DISTINCT ';
        v_sql := v_sql || '  E.PROC_ID, ';
        v_sql := v_sql || '  E.NUM_CONTROLE_DOCTO, ';
        v_sql := v_sql || '  E.NUM_AUTENTIC_NFE, ';
        v_sql := v_sql || '  E.NUM_ITEM, ';
        v_sql := v_sql || '  E.COD_PRODUTO, ';
        ---
        v_sql := v_sql || '	 REPLACE(D.CFOP_FORN,''.'','''') AS CFOP_FORN, ';
        v_sql := v_sql || '	 D.VLR_BASE_ICMS, ';
        v_sql := v_sql || '	 D.VLR_ICMS, ';
        v_sql := v_sql || '	 D.ALIQ_REDUCAO, ';
        v_sql := v_sql || '	 D.VLR_BASE_ICMS_ST, ';
        v_sql := v_sql || '	 D.VLR_ICMS_ST, ';
        v_sql := v_sql || '	 D.VLR_BASE_ICMSST_RET, ';
        v_sql := v_sql || '	 D.VLR_ICMSST_RET ';
        v_sql := v_sql || ' FROM MSAFI.PS_XML_FORN D, '; --VIEW MATERIALIZADA
        v_sql := v_sql || ' ' || vp_tab_entrada_c || ' E ';
        v_sql := v_sql || ' WHERE E.NUM_AUTENTIC_NFE = D.NFE_VERIF_CODE_PBL ';
        v_sql := v_sql || '   AND E.COD_PRODUTO      = D.INV_ITEM_ID ';
        v_sql := v_sql || '   AND E.NUM_ITEM         = D.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '   AND NOT EXISTS (SELECT ''Y'' FROM MSAFI.DSP_ESTABELECIMENTO EST ';
        v_sql := v_sql || '                   WHERE EST.COD_EMPRESA = E.COD_EMPRESA ';
        v_sql := v_sql || '                     AND EST.COD_ESTAB   = E.COD_FIS_JUR) ';

        BEGIN
            OPEN c_xml FOR v_sql;
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
                            , vp_data_inicial
                            , vp_data_final
                            , SQLERRM
                            , 'E'
                            , vp_data_hora_ini );
                -----------------------------------------------------------------
                raise_application_error ( -20007
                                        , '!ERRO SELECT DADOS XML!' );
        END;

        LOOP
            FETCH c_xml
                BULK COLLECT INTO tab_xml
                LIMIT 100;

            FOR i IN 1 .. tab_xml.COUNT LOOP
                v_insert :=
                       'INSERT /*+APPEND_VALUES*/ INTO '
                    || vp_tabela_xml
                    || ' VALUES ('
                    || tab_xml ( i ).proc_id
                    || ','''
                    || tab_xml ( i ).num_controle_docto
                    || ''','''
                    || tab_xml ( i ).num_autentic_nfe
                    || ''','
                    || tab_xml ( i ).num_item
                    || ','''
                    || tab_xml ( i ).cod_produto
                    || ''','''
                    || tab_xml ( i ).cfop_forn
                    || ''','
                    || 'TO_NUMBER('''
                    || tab_xml ( i ).vlr_base_icms
                    || '''),TO_NUMBER('''
                    || tab_xml ( i ).vlr_icms
                    || '''),TO_NUMBER('''
                    || tab_xml ( i ).aliq_reducao
                    || '''),TO_NUMBER('''
                    || tab_xml ( i ).vlr_base_icms_st
                    || '''),TO_NUMBER('''
                    || tab_xml ( i ).vlr_icms_st
                    || '''),TO_NUMBER('''
                    || tab_xml ( i ).vlr_base_icmsst_ret
                    || '''),TO_NUMBER('''
                    || tab_xml ( i ).vlr_icmsst_ret
                    || '''))';

                BEGIN
                    EXECUTE IMMEDIATE v_insert;

                    COMMIT;
                EXCEPTION
                    WHEN OTHERS THEN
                        loga ( 'SQLERRM: ' || SQLERRM
                             , FALSE );
                        loga ( SUBSTR ( v_insert
                                      , 1
                                      , 1024 )
                             , FALSE );
                        loga ( SUBSTR ( v_insert
                                      , 1024
                                      , 1024 )
                             , FALSE );
                        loga ( SUBSTR ( v_insert
                                      , 2048
                                      , 1024 )
                             , FALSE );
                        loga ( SUBSTR ( v_insert
                                      , 3072 )
                             , FALSE );
                        --ENVIAR EMAIL DE ERRO-------------------------------------------
                        envia_email ( mcod_empresa
                                    , vp_data_inicial
                                    , vp_data_final
                                    , SQLERRM
                                    , 'E'
                                    , vp_data_hora_ini );
                        -----------------------------------------------------------------
                        raise_application_error ( -20007
                                                , '!ERRO INSERT DADOS XML!' );
                END;
            END LOOP;

            tab_xml.delete;

            EXIT WHEN c_xml%NOTFOUND;
        END LOOP;

        COMMIT;

        CLOSE c_xml;

        loga ( 'XML1-FIM'
             , FALSE );
        loga ( 'XML2-INI'
             , FALSE );

        ---XML DE ESTABELECIMENTOS DSP e DPA
        v_sql := ' SELECT DISTINCT ';
        v_sql := v_sql || '  E.PROC_ID, ';
        v_sql := v_sql || '  E.NUM_CONTROLE_DOCTO, ';
        v_sql := v_sql || '  E.NUM_AUTENTIC_NFE, ';
        v_sql := v_sql || '  E.NUM_ITEM, ';
        v_sql := v_sql || '  E.COD_PRODUTO, ';
        ---
        v_sql := v_sql || '	 REPLACE(D.CFOP_SAIDA,''.'','''') AS CFOP_SAIDA, ';
        v_sql := v_sql || '	 D.VLR_BASE_ICMS, ';
        v_sql := v_sql || '	 D.VLR_ICMS, ';
        v_sql := v_sql || '	 D.ALIQ_REDUCAO, ';
        v_sql := v_sql || '	 D.VLR_BASE_ICMS_ST, ';
        v_sql := v_sql || '	 D.VLR_ICMS_ST, ';
        v_sql := v_sql || '	 D.VLR_BASE_ICMSST_RET, ';
        v_sql := v_sql || '	 D.VLR_ICMSST_RET ';
        v_sql := v_sql || 'FROM ' || vp_tabela_xml_dpsp || ' D, ';
        v_sql := v_sql || ' ' || vp_tab_entrada_c || ' E, ';
        v_sql := v_sql || '		MSAFI.DSP_ESTABELECIMENTO EST ';
        v_sql := v_sql || 'WHERE E.NUM_AUTENTIC_NFE = D.CHAVE_ACESSO ';
        v_sql := v_sql || '  AND E.COD_PRODUTO 	 = D.INV_ITEM_ID ';
        v_sql := v_sql || '  AND E.NUM_ITEM      = D.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '  AND EST.COD_EMPRESA = E.COD_EMPRESA ';
        v_sql := v_sql || '  AND EST.COD_ESTAB   = E.COD_FIS_JUR ';

        BEGIN
            OPEN c_xml FOR v_sql;
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
                            , vp_data_inicial
                            , vp_data_final
                            , SQLERRM
                            , 'E'
                            , vp_data_hora_ini );
                -----------------------------------------------------------------
                raise_application_error ( -20007
                                        , '!ERRO SELECT DADOS XML 2!' );
        END;

        LOOP
            FETCH c_xml
                BULK COLLECT INTO tab_xml
                LIMIT 100;

            FOR i IN 1 .. tab_xml.COUNT LOOP
                v_insert :=
                       'INSERT /*+APPEND_VALUES*/ INTO '
                    || vp_tabela_xml
                    || ' VALUES ('
                    || tab_xml ( i ).proc_id
                    || ','''
                    || tab_xml ( i ).num_controle_docto
                    || ''','''
                    || tab_xml ( i ).num_autentic_nfe
                    || ''','
                    || tab_xml ( i ).num_item
                    || ','''
                    || tab_xml ( i ).cod_produto
                    || ''','''
                    || tab_xml ( i ).cfop_forn
                    || ''','
                    || 'TO_NUMBER('''
                    || tab_xml ( i ).vlr_base_icms
                    || '''),TO_NUMBER('''
                    || tab_xml ( i ).vlr_icms
                    || '''),TO_NUMBER('''
                    || tab_xml ( i ).aliq_reducao
                    || '''),TO_NUMBER('''
                    || tab_xml ( i ).vlr_base_icms_st
                    || '''),TO_NUMBER('''
                    || tab_xml ( i ).vlr_icms_st
                    || '''),TO_NUMBER('''
                    || tab_xml ( i ).vlr_base_icmsst_ret
                    || '''),TO_NUMBER('''
                    || tab_xml ( i ).vlr_icmsst_ret
                    || '''))';

                BEGIN
                    EXECUTE IMMEDIATE v_insert;

                    COMMIT;
                EXCEPTION
                    WHEN OTHERS THEN
                        loga ( 'SQLERRM: ' || SQLERRM
                             , FALSE );
                        loga ( SUBSTR ( v_insert
                                      , 1
                                      , 1024 )
                             , FALSE );
                        loga ( SUBSTR ( v_insert
                                      , 1024
                                      , 1024 )
                             , FALSE );
                        loga ( SUBSTR ( v_insert
                                      , 2048
                                      , 1024 )
                             , FALSE );
                        loga ( SUBSTR ( v_insert
                                      , 3072 )
                             , FALSE );
                        --ENVIAR EMAIL DE ERRO-------------------------------------------
                        envia_email ( mcod_empresa
                                    , vp_data_inicial
                                    , vp_data_final
                                    , SQLERRM
                                    , 'E'
                                    , vp_data_hora_ini );
                        -----------------------------------------------------------------
                        raise_application_error ( -20007
                                                , '!ERRO INSERT DADOS XML 2!' );
                END;
            END LOOP;

            tab_xml.delete;

            EXIT WHEN c_xml%NOTFOUND;
        END LOOP;

        COMMIT;

        CLOSE c_xml;

        loga ( 'XML2-FIM'
             , FALSE );

        v_sql := 'CREATE UNIQUE INDEX PK_INTERXML' || vp_proc_id || ' ON ' || vp_tabela_xml || ' ';
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || '    PROC_ID             ASC, ';
        v_sql := v_sql || '    NUM_CONTROLE_DOCTO  ASC, ';
        v_sql := v_sql || '    NUM_AUTENTIC_NFE    ASC, ';
        v_sql := v_sql || '    NUM_ITEM            ASC, ';
        v_sql := v_sql || '    COD_PRODUTO         ASC ';
        v_sql := v_sql || '  ) ';
        v_sql := v_sql || '  PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX1_INTERX' || vp_proc_id || ' ON ' || vp_tabela_xml || ' ';
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || '    PROC_ID ASC ) ';
        v_sql := v_sql || '  PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX2_INTERX' || vp_proc_id || ' ON ' || vp_tabela_xml || ' ';
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || '    PROC_ID             ASC, ';
        v_sql := v_sql || '    NUM_CONTROLE_DOCTO  ASC, ';
        v_sql := v_sql || '    NUM_AUTENTIC_NFE    ASC, ';
        v_sql := v_sql || '    NUM_ITEM            ASC ';
        v_sql := v_sql || '  ) ';
        v_sql := v_sql || '  PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_tabela_xml );

        v_sql := 'SELECT COUNT(*) QTDE_XML ';
        v_sql := v_sql || 'FROM ' || vp_tabela_xml || ' ';
        v_sql := v_sql || 'WHERE PROC_ID = ' || vp_proc_id;

        EXECUTE IMMEDIATE v_sql            INTO v_qtde_xml;

        loga ( 'XML-FIM ' || v_qtde_xml || ' LINHAS'
             , FALSE );
    END; --LOAD_DADOS_XML

    PROCEDURE load_dados_xml_refugo ( vp_proc_id IN VARCHAR2
                                    , vp_cod_empresa IN VARCHAR2
                                    , vp_tab_entrada_c IN VARCHAR2
                                    , vp_tabela_xml IN VARCHAR2
                                    , vp_tabela_xml_dpsp IN VARCHAR2
                                    , vp_data_inicial IN DATE
                                    , vp_data_final IN DATE
                                    , vp_data_hora_ini IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 4000 );
        v_insert VARCHAR2 ( 500 );
        c_xml SYS_REFCURSOR;
        v_qtde_xml NUMBER := 0;

        TYPE cur_tab_xml IS RECORD
        (
            proc_id NUMBER ( 30 )
          , num_controle_docto VARCHAR2 ( 12 )
          , num_autentic_nfe VARCHAR2 ( 80 )
          , num_item NUMBER ( 5 )
          , cod_produto VARCHAR2 ( 35 )
          , ---
            cfop_forn VARCHAR2 ( 5 )
          , vlr_base_icms NUMBER ( 17, 2 )
          , vlr_icms NUMBER ( 17, 2 )
          , aliq_reducao NUMBER ( 5, 2 )
          , vlr_base_icms_st NUMBER ( 17, 2 )
          , vlr_icms_st NUMBER ( 17, 2 )
          , vlr_base_icmsst_ret NUMBER ( 17, 2 )
          , vlr_icmsst_ret NUMBER ( 17, 2 )
        );

        TYPE c_tab_xml IS TABLE OF cur_tab_xml;

        tab_xml c_tab_xml;
    BEGIN
        loga ( 'XML REFUGO 1-INI'
             , FALSE );

        --TRAZER LINHAS PELO CODIGO DO PRODUTO + QTDE, POIS O PSFT AGREGA LINHAS COM O MESMO COD_PRODUTO
        v_sql := ' SELECT DISTINCT ';
        v_sql := v_sql || '  E.PROC_ID, ';
        v_sql := v_sql || '  E.NUM_CONTROLE_DOCTO, ';
        v_sql := v_sql || '  E.NUM_AUTENTIC_NFE, ';
        v_sql := v_sql || '  E.NUM_ITEM, ';
        v_sql := v_sql || '  E.COD_PRODUTO, ';
        ---
        v_sql := v_sql || '	 ''A'' || REPLACE(D.CFOP_FORN,''.'','''') AS CFOP_FORN, ';
        v_sql := v_sql || '	 D.VLR_BASE_ICMS, ';
        v_sql := v_sql || '	 D.VLR_ICMS, ';
        v_sql := v_sql || '	 D.ALIQ_REDUCAO, ';
        v_sql := v_sql || '	 D.VLR_BASE_ICMS_ST, ';
        v_sql := v_sql || '	 D.VLR_ICMS_ST, ';
        v_sql := v_sql || '	 D.VLR_BASE_ICMSST_RET, ';
        v_sql := v_sql || '	 D.VLR_ICMSST_RET ';
        v_sql := v_sql || ' FROM ( ';
        v_sql :=
               v_sql
            || '	  SELECT '''' AS NF_BRL_LINE_NUM, S.INV_ITEM_ID, S.NFE_VERIF_CODE_PBL, S.CFOP_FORN, S.DESCR, SUM(S.QTY_NF_BRL) AS QTY_NF_BRL, ';
        v_sql :=
               v_sql
            || '	        SUM(S.VLR_BASE_ICMS) AS VLR_BASE_ICMS, SUM(S.VLR_ICMS) AS VLR_ICMS, S.ALIQ_REDUCAO, SUM(S.VLR_BASE_ICMS_ST) AS VLR_BASE_ICMS_ST, ';
        v_sql :=
               v_sql
            || '	        SUM(S.VLR_ICMS_ST) AS VLR_ICMS_ST, SUM(S.VLR_BASE_ICMSST_RET) AS VLR_BASE_ICMSST_RET, SUM(S.VLR_ICMSST_RET) AS VLR_ICMSST_RET ';
        v_sql :=
               v_sql
            || '   FROM MSAFI.PS_XML_FORN S GROUP BY S.INV_ITEM_ID, S.NFE_VERIF_CODE_PBL, S.CFOP_FORN, S.DESCR, S.ALIQ_REDUCAO ) D, ';
        v_sql := v_sql || ' ' || vp_tab_entrada_c || ' E ';
        v_sql := v_sql || ' WHERE E.NUM_AUTENTIC_NFE = D.NFE_VERIF_CODE_PBL ';
        v_sql := v_sql || '   AND E.COD_PRODUTO      = D.INV_ITEM_ID ';
        v_sql := v_sql || '   AND E.QUANTIDADE       = D.QTY_NF_BRL ';
        v_sql := v_sql || '   AND NOT EXISTS (SELECT ''Y'' ';
        v_sql := v_sql || '                   FROM ' || vp_tabela_xml || ' X ';
        v_sql := v_sql || '                   WHERE X.PROC_ID            = E.PROC_ID ';
        v_sql := v_sql || '                     AND X.NUM_CONTROLE_DOCTO = E.NUM_CONTROLE_DOCTO ';
        v_sql := v_sql || '    					AND X.NUM_AUTENTIC_NFE   = E.NUM_AUTENTIC_NFE ';
        v_sql := v_sql || '   					AND X.NUM_ITEM           = E.NUM_ITEM ) ';
        v_sql := v_sql || '   AND NOT EXISTS (SELECT ''Y'' FROM MSAFI.DSP_ESTABELECIMENTO EST ';
        v_sql := v_sql || '                   WHERE EST.COD_EMPRESA = E.COD_EMPRESA ';
        v_sql := v_sql || '                     AND EST.COD_ESTAB   = E.COD_FIS_JUR) ';

        BEGIN
            OPEN c_xml FOR v_sql;
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
                            , vp_data_inicial
                            , vp_data_final
                            , SQLERRM
                            , 'E'
                            , vp_data_hora_ini );
                -----------------------------------------------------------------
                raise_application_error ( -20007
                                        , '!ERRO SELECT DADOS XML REFUGO!' );
        END;

        LOOP
            FETCH c_xml
                BULK COLLECT INTO tab_xml
                LIMIT 100;

            FOR i IN 1 .. tab_xml.COUNT LOOP
                v_insert :=
                       'INSERT /*+APPEND_VALUES*/ INTO '
                    || vp_tabela_xml
                    || ' VALUES ('
                    || tab_xml ( i ).proc_id
                    || ','''
                    || tab_xml ( i ).num_controle_docto
                    || ''','''
                    || tab_xml ( i ).num_autentic_nfe
                    || ''','
                    || tab_xml ( i ).num_item
                    || ','''
                    || tab_xml ( i ).cod_produto
                    || ''','''
                    || tab_xml ( i ).cfop_forn
                    || ''','
                    || 'TO_NUMBER('''
                    || tab_xml ( i ).vlr_base_icms
                    || '''),TO_NUMBER('''
                    || tab_xml ( i ).vlr_icms
                    || '''),TO_NUMBER('''
                    || tab_xml ( i ).aliq_reducao
                    || '''),TO_NUMBER('''
                    || tab_xml ( i ).vlr_base_icms_st
                    || '''),TO_NUMBER('''
                    || tab_xml ( i ).vlr_icms_st
                    || '''),TO_NUMBER('''
                    || tab_xml ( i ).vlr_base_icmsst_ret
                    || '''),TO_NUMBER('''
                    || tab_xml ( i ).vlr_icmsst_ret
                    || '''))';

                BEGIN
                    EXECUTE IMMEDIATE v_insert;

                    COMMIT;
                EXCEPTION
                    WHEN OTHERS THEN
                        loga ( 'SQLERRM: ' || SQLERRM
                             , FALSE );
                        loga ( SUBSTR ( v_insert
                                      , 1
                                      , 1024 )
                             , FALSE );
                        loga ( SUBSTR ( v_insert
                                      , 1024
                                      , 1024 )
                             , FALSE );
                        loga ( SUBSTR ( v_insert
                                      , 2048
                                      , 1024 )
                             , FALSE );
                        loga ( SUBSTR ( v_insert
                                      , 3072 )
                             , FALSE );
                        --ENVIAR EMAIL DE ERRO-------------------------------------------
                        envia_email ( mcod_empresa
                                    , vp_data_inicial
                                    , vp_data_final
                                    , SQLERRM
                                    , 'E'
                                    , vp_data_hora_ini );
                        -----------------------------------------------------------------
                        raise_application_error ( -20007
                                                , '!ERRO INSERT DADOS XML REFUGO!' );
                END;
            END LOOP;

            tab_xml.delete;

            EXIT WHEN c_xml%NOTFOUND;
        END LOOP;

        COMMIT;

        CLOSE c_xml;

        loga ( 'XML REFUGO 2-INI'
             , FALSE );

        --TRAZER LINHAS PELO ID DA LINHA, POIS XML NAO TEM COD_PRODUTO EM ALGUNS CASOS
        v_sql := ' SELECT DISTINCT ';
        v_sql := v_sql || '  E.PROC_ID, ';
        v_sql := v_sql || '  E.NUM_CONTROLE_DOCTO, ';
        v_sql := v_sql || '  E.NUM_AUTENTIC_NFE, ';
        v_sql := v_sql || '  E.NUM_ITEM, ';
        v_sql := v_sql || '  E.COD_PRODUTO, ';
        ---
        v_sql := v_sql || '	 ''B'' || REPLACE(D.CFOP_FORN,''.'','''') AS CFOP_FORN, ';
        v_sql := v_sql || '	 D.VLR_BASE_ICMS, ';
        v_sql := v_sql || '	 D.VLR_ICMS, ';
        v_sql := v_sql || '	 D.ALIQ_REDUCAO, ';
        v_sql := v_sql || '	 D.VLR_BASE_ICMS_ST, ';
        v_sql := v_sql || '	 D.VLR_ICMS_ST, ';
        v_sql := v_sql || '	 D.VLR_BASE_ICMSST_RET, ';
        v_sql := v_sql || '	 D.VLR_ICMSST_RET ';
        v_sql := v_sql || ' FROM MSAFI.PS_XML_FORN D, ';
        v_sql := v_sql || ' ' || vp_tab_entrada_c || ' E ';
        v_sql := v_sql || ' WHERE E.NUM_AUTENTIC_NFE = D.NFE_VERIF_CODE_PBL ';
        v_sql := v_sql || '   AND E.NUM_ITEM    = D.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '   AND E.QUANTIDADE  = D.QTY_NF_BRL ';
        v_sql := v_sql || '   AND D.INV_ITEM_ID = '' '' ';
        v_sql := v_sql || '   AND NOT EXISTS (SELECT ''Y'' ';
        v_sql := v_sql || '                   FROM ' || vp_tabela_xml || ' X ';
        v_sql := v_sql || '                   WHERE X.PROC_ID            = E.PROC_ID ';
        v_sql := v_sql || '                     AND X.NUM_CONTROLE_DOCTO = E.NUM_CONTROLE_DOCTO ';
        v_sql := v_sql || '    					AND X.NUM_AUTENTIC_NFE   = E.NUM_AUTENTIC_NFE ';
        v_sql := v_sql || '   					AND X.NUM_ITEM           = E.NUM_ITEM ) ';
        v_sql := v_sql || '   AND NOT EXISTS (SELECT ''Y'' FROM MSAFI.DSP_ESTABELECIMENTO EST ';
        v_sql := v_sql || '                   WHERE EST.COD_EMPRESA = E.COD_EMPRESA ';
        v_sql := v_sql || '                     AND EST.COD_ESTAB   = E.COD_FIS_JUR) ';

        BEGIN
            OPEN c_xml FOR v_sql;
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
                            , vp_data_inicial
                            , vp_data_final
                            , SQLERRM
                            , 'E'
                            , vp_data_hora_ini );
                -----------------------------------------------------------------
                raise_application_error ( -20007
                                        , '!ERRO SELECT DADOS XML REFUGO 2!' );
        END;

        LOOP
            FETCH c_xml
                BULK COLLECT INTO tab_xml
                LIMIT 100;

            FOR i IN 1 .. tab_xml.COUNT LOOP
                v_insert :=
                       'INSERT /*+APPEND_VALUES*/ INTO '
                    || vp_tabela_xml
                    || ' VALUES ('
                    || tab_xml ( i ).proc_id
                    || ','''
                    || tab_xml ( i ).num_controle_docto
                    || ''','''
                    || tab_xml ( i ).num_autentic_nfe
                    || ''','
                    || tab_xml ( i ).num_item
                    || ','''
                    || tab_xml ( i ).cod_produto
                    || ''','''
                    || tab_xml ( i ).cfop_forn
                    || ''','
                    || 'TO_NUMBER('''
                    || tab_xml ( i ).vlr_base_icms
                    || '''),TO_NUMBER('''
                    || tab_xml ( i ).vlr_icms
                    || '''),TO_NUMBER('''
                    || tab_xml ( i ).aliq_reducao
                    || '''),TO_NUMBER('''
                    || tab_xml ( i ).vlr_base_icms_st
                    || '''),TO_NUMBER('''
                    || tab_xml ( i ).vlr_icms_st
                    || '''),TO_NUMBER('''
                    || tab_xml ( i ).vlr_base_icmsst_ret
                    || '''),TO_NUMBER('''
                    || tab_xml ( i ).vlr_icmsst_ret
                    || '''))';

                BEGIN
                    EXECUTE IMMEDIATE v_insert;

                    COMMIT;
                EXCEPTION
                    WHEN OTHERS THEN
                        loga ( 'SQLERRM: ' || SQLERRM
                             , FALSE );
                        loga ( SUBSTR ( v_insert
                                      , 1
                                      , 1024 )
                             , FALSE );
                        loga ( SUBSTR ( v_insert
                                      , 1024
                                      , 1024 )
                             , FALSE );
                        loga ( SUBSTR ( v_insert
                                      , 2048
                                      , 1024 )
                             , FALSE );
                        loga ( SUBSTR ( v_insert
                                      , 3072 )
                             , FALSE );
                        --ENVIAR EMAIL DE ERRO-------------------------------------------
                        envia_email ( mcod_empresa
                                    , vp_data_inicial
                                    , vp_data_final
                                    , SQLERRM
                                    , 'E'
                                    , vp_data_hora_ini );
                        -----------------------------------------------------------------
                        raise_application_error ( -20007
                                                , '!ERRO INSERT DADOS XML REFUGO 2!' );
                END;
            END LOOP;

            tab_xml.delete;

            EXIT WHEN c_xml%NOTFOUND;
        END LOOP;

        COMMIT;

        CLOSE c_xml;

        loga ( 'XML REFUGO 3-INI'
             , FALSE );

        ---XML DE ESTABELECIMENTOS DSP e DPA
        v_sql := ' SELECT DISTINCT ';
        v_sql := v_sql || '  E.PROC_ID, ';
        v_sql := v_sql || '  E.NUM_CONTROLE_DOCTO, ';
        v_sql := v_sql || '  E.NUM_AUTENTIC_NFE, ';
        v_sql := v_sql || '  E.NUM_ITEM, ';
        v_sql := v_sql || '  E.COD_PRODUTO, ';
        ---
        v_sql := v_sql || '	 ''C'' || REPLACE(D.CFOP_SAIDA,''.'','''') AS CFOP_FORN, ';
        v_sql := v_sql || '	 D.VLR_BASE_ICMS, ';
        v_sql := v_sql || '	 D.VLR_ICMS, ';
        v_sql := v_sql || '	 D.ALIQ_REDUCAO, ';
        v_sql := v_sql || '	 D.VLR_BASE_ICMS_ST, ';
        v_sql := v_sql || '	 D.VLR_ICMS_ST, ';
        v_sql := v_sql || '	 D.VLR_BASE_ICMSST_RET, ';
        v_sql := v_sql || '	 D.VLR_ICMSST_RET ';
        v_sql := v_sql || ' FROM ' || vp_tabela_xml_dpsp || ' D, ';
        v_sql := v_sql || ' ' || vp_tab_entrada_c || ' E, ';
        v_sql := v_sql || '      MSAFI.DSP_ESTABELECIMENTO EST ';
        v_sql := v_sql || ' WHERE E.NUM_AUTENTIC_NFE = D.CHAVE_ACESSO ';
        v_sql := v_sql || '   AND E.NUM_ITEM         = D.NF_BRL_LINE_NUM ';
        v_sql := v_sql || '   AND D.INV_ITEM_ID      = '' '' ';
        v_sql := v_sql || '   AND EST.COD_EMPRESA    = E.COD_EMPRESA ';
        v_sql := v_sql || '   AND EST.COD_ESTAB      = E.COD_FIS_JUR ';
        v_sql := v_sql || '   AND NOT EXISTS (SELECT ''Y'' ';
        v_sql := v_sql || '                   FROM ' || vp_tabela_xml || ' X ';
        v_sql := v_sql || '                   WHERE X.PROC_ID            = E.PROC_ID ';
        v_sql := v_sql || '                     AND X.NUM_CONTROLE_DOCTO = E.NUM_CONTROLE_DOCTO ';
        v_sql := v_sql || '    					AND X.NUM_AUTENTIC_NFE   = E.NUM_AUTENTIC_NFE ';
        v_sql := v_sql || '   					AND X.NUM_ITEM           = E.NUM_ITEM ) ';

        BEGIN
            OPEN c_xml FOR v_sql;
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
                            , vp_data_inicial
                            , vp_data_final
                            , SQLERRM
                            , 'E'
                            , vp_data_hora_ini );
                -----------------------------------------------------------------
                raise_application_error ( -20007
                                        , '!ERRO SELECT DADOS XML REFUGO 3!' );
        END;

        LOOP
            FETCH c_xml
                BULK COLLECT INTO tab_xml
                LIMIT 100;

            FOR i IN 1 .. tab_xml.COUNT LOOP
                v_insert :=
                       'INSERT /*+APPEND_VALUES*/ INTO '
                    || vp_tabela_xml
                    || ' VALUES ('
                    || tab_xml ( i ).proc_id
                    || ','''
                    || tab_xml ( i ).num_controle_docto
                    || ''','''
                    || tab_xml ( i ).num_autentic_nfe
                    || ''','
                    || tab_xml ( i ).num_item
                    || ','''
                    || tab_xml ( i ).cod_produto
                    || ''','''
                    || tab_xml ( i ).cfop_forn
                    || ''','
                    || 'TO_NUMBER('''
                    || tab_xml ( i ).vlr_base_icms
                    || '''),TO_NUMBER('''
                    || tab_xml ( i ).vlr_icms
                    || '''),TO_NUMBER('''
                    || tab_xml ( i ).aliq_reducao
                    || '''),TO_NUMBER('''
                    || tab_xml ( i ).vlr_base_icms_st
                    || '''),TO_NUMBER('''
                    || tab_xml ( i ).vlr_icms_st
                    || '''),TO_NUMBER('''
                    || tab_xml ( i ).vlr_base_icmsst_ret
                    || '''),TO_NUMBER('''
                    || tab_xml ( i ).vlr_icmsst_ret
                    || '''))';

                BEGIN
                    EXECUTE IMMEDIATE v_insert;

                    COMMIT;
                EXCEPTION
                    WHEN OTHERS THEN
                        loga ( 'SQLERRM: ' || SQLERRM
                             , FALSE );
                        loga ( SUBSTR ( v_insert
                                      , 1
                                      , 1024 )
                             , FALSE );
                        loga ( SUBSTR ( v_insert
                                      , 1024
                                      , 1024 )
                             , FALSE );
                        loga ( SUBSTR ( v_insert
                                      , 2048
                                      , 1024 )
                             , FALSE );
                        loga ( SUBSTR ( v_insert
                                      , 3072 )
                             , FALSE );
                        --ENVIAR EMAIL DE ERRO-------------------------------------------
                        envia_email ( mcod_empresa
                                    , vp_data_inicial
                                    , vp_data_final
                                    , SQLERRM
                                    , 'E'
                                    , vp_data_hora_ini );
                        -----------------------------------------------------------------
                        raise_application_error ( -20007
                                                , '!ERRO INSERT DADOS XML REFUGO 3!' );
                END;
            END LOOP;

            tab_xml.delete;

            EXIT WHEN c_xml%NOTFOUND;
        END LOOP;

        COMMIT;

        CLOSE c_xml;

        loga ( 'XML REFUGO 4-INI'
             , FALSE ); ---XML DE TRANSFERENCIAS DSP E DP

        ---XML DE ESTABELECIMENTOS DSP e DPA
        v_sql := ' SELECT DISTINCT ';
        v_sql := v_sql || '  E.PROC_ID, ';
        v_sql := v_sql || '  E.NUM_CONTROLE_DOCTO, ';
        v_sql := v_sql || '  E.NUM_AUTENTIC_NFE, ';
        v_sql := v_sql || '  E.NUM_ITEM, ';
        v_sql := v_sql || '  E.COD_PRODUTO, ';
        ---
        v_sql := v_sql || '	 ''D'' || REPLACE(D.CFOP_SAIDA,''.'','''') AS CFOP_FORN, ';
        v_sql := v_sql || '	 D.VLR_BASE_ICMS, ';
        v_sql := v_sql || '	 D.VLR_ICMS, ';
        v_sql := v_sql || '	 0 AS ALIQ_REDUCAO, ';
        v_sql := v_sql || '	 D.VLR_BASE_ICMS_ST, ';
        v_sql := v_sql || '	 D.VLR_ICMS_ST, ';
        v_sql := v_sql || '	 0 AS VLR_BASE_ICMSST_RET, ';
        v_sql := v_sql || '	 0 AS VLR_ICMSST_RET ';
        v_sql := v_sql || ' FROM ( ';
        v_sql :=
               v_sql
            || '   SELECT S.NF_BRL_ID, S.CHAVE_ACESSO, '''' AS NF_BRL_LINE_NUM, S.INV_ITEM_ID, S.CFOP_SAIDA, SUM(S.QUANTIDADE) AS QUANTIDADE, SUM(S.VLR_BASE_ICMS) AS VLR_BASE_ICMS, ';
        v_sql :=
               v_sql
            || '          SUM(S.VLR_ICMS) AS VLR_ICMS, SUM(S.VLR_BASE_ICMS_ST) AS VLR_BASE_ICMS_ST, SUM(S.VLR_ICMS_ST) AS VLR_ICMS_ST ';
        v_sql :=
               v_sql
            || '   FROM '
            || vp_tabela_xml_dpsp
            || ' S GROUP BY S.NF_BRL_ID, S.CHAVE_ACESSO, S.INV_ITEM_ID, S.CFOP_SAIDA ) D, ';
        v_sql := v_sql || ' ' || vp_tab_entrada_c || ' E, ';
        v_sql := v_sql || '      MSAFI.DSP_ESTABELECIMENTO EST ';
        v_sql := v_sql || ' WHERE E.NUM_AUTENTIC_NFE = D.CHAVE_ACESSO ';
        v_sql := v_sql || '   AND E.COD_PRODUTO      = D.INV_ITEM_ID ';
        v_sql := v_sql || '   AND E.QUANTIDADE       = D.QUANTIDADE ';
        v_sql := v_sql || '   AND EST.COD_EMPRESA    = E.COD_EMPRESA ';
        v_sql := v_sql || '   AND EST.COD_ESTAB      = E.COD_FIS_JUR ';
        v_sql := v_sql || '   AND NOT EXISTS (SELECT ''Y'' ';
        v_sql := v_sql || '                   FROM ' || vp_tabela_xml || ' X ';
        v_sql := v_sql || '                   WHERE X.PROC_ID            = E.PROC_ID ';
        v_sql := v_sql || '                     AND X.NUM_CONTROLE_DOCTO = E.NUM_CONTROLE_DOCTO ';
        v_sql := v_sql || '    					AND X.NUM_AUTENTIC_NFE   = E.NUM_AUTENTIC_NFE ';
        v_sql := v_sql || '    					AND X.COD_PRODUTO        = E.COD_PRODUTO ';
        v_sql := v_sql || '   					AND X.NUM_ITEM           = E.NUM_ITEM ) ';

        BEGIN
            OPEN c_xml FOR v_sql;
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
                            , vp_data_inicial
                            , vp_data_final
                            , SQLERRM
                            , 'E'
                            , vp_data_hora_ini );
                -----------------------------------------------------------------
                raise_application_error ( -20007
                                        , '!ERRO SELECT DADOS XML REFUGO 4!' );
        END;

        LOOP
            FETCH c_xml
                BULK COLLECT INTO tab_xml
                LIMIT 100;

            FOR i IN 1 .. tab_xml.COUNT LOOP
                v_insert :=
                       'INSERT /*+APPEND_VALUES*/ INTO '
                    || vp_tabela_xml
                    || ' VALUES ('
                    || tab_xml ( i ).proc_id
                    || ','''
                    || tab_xml ( i ).num_controle_docto
                    || ''','''
                    || tab_xml ( i ).num_autentic_nfe
                    || ''','
                    || tab_xml ( i ).num_item
                    || ','''
                    || tab_xml ( i ).cod_produto
                    || ''','''
                    || tab_xml ( i ).cfop_forn
                    || ''','
                    || 'TO_NUMBER('''
                    || tab_xml ( i ).vlr_base_icms
                    || '''),TO_NUMBER('''
                    || tab_xml ( i ).vlr_icms
                    || '''),TO_NUMBER('''
                    || tab_xml ( i ).aliq_reducao
                    || '''),TO_NUMBER('''
                    || tab_xml ( i ).vlr_base_icms_st
                    || '''),TO_NUMBER('''
                    || tab_xml ( i ).vlr_icms_st
                    || '''),TO_NUMBER('''
                    || tab_xml ( i ).vlr_base_icmsst_ret
                    || '''),TO_NUMBER('''
                    || tab_xml ( i ).vlr_icmsst_ret
                    || '''))';

                BEGIN
                    EXECUTE IMMEDIATE v_insert;

                    COMMIT;
                EXCEPTION
                    WHEN OTHERS THEN
                        loga ( 'SQLERRM: ' || SQLERRM
                             , FALSE );
                        loga ( SUBSTR ( v_insert
                                      , 1
                                      , 1024 )
                             , FALSE );
                        loga ( SUBSTR ( v_insert
                                      , 1024
                                      , 1024 )
                             , FALSE );
                        loga ( SUBSTR ( v_insert
                                      , 2048
                                      , 1024 )
                             , FALSE );
                        loga ( SUBSTR ( v_insert
                                      , 3072 )
                             , FALSE );
                        --ENVIAR EMAIL DE ERRO-------------------------------------------
                        envia_email ( mcod_empresa
                                    , vp_data_inicial
                                    , vp_data_final
                                    , SQLERRM
                                    , 'E'
                                    , vp_data_hora_ini );
                        -----------------------------------------------------------------
                        raise_application_error ( -20007
                                                , '!ERRO INSERT DADOS XML REFUGO 4!' );
                END;
            END LOOP;

            tab_xml.delete;

            EXIT WHEN c_xml%NOTFOUND;
        END LOOP;

        COMMIT;

        CLOSE c_xml;

        v_sql := 'SELECT COUNT(*) QTDE_XML ';
        v_sql := v_sql || 'FROM ' || vp_tabela_xml || ' ';
        v_sql := v_sql || 'WHERE PROC_ID = ' || vp_proc_id;
        v_sql := v_sql || '  AND CFOP_FORN LIKE ''*%'' ';

        EXECUTE IMMEDIATE v_sql            INTO v_qtde_xml;

        loga ( 'XML REFUGO-FIM ' || v_qtde_xml || ' LINHAS'
             , FALSE );
    END; --LOAD_DADOS_XML_REFUGO

    PROCEDURE load_tab_class ( vp_proc_id IN VARCHAR2
                             , vp_tab_entrada_c IN VARCHAR2
                             , vp_tabela_xml IN VARCHAR2
                             , vp_tabela_class   OUT VARCHAR2
                             , vp_data_inicial IN DATE
                             , vp_data_final IN DATE
                             , vp_data_hora_ini IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 4000 );
        v_insert VARCHAR2 ( 2000 );
        c_class SYS_REFCURSOR;
        v_qtde_class NUMBER := 0;

        TYPE cur_tab_class IS RECORD
        (
            proc_id NUMBER ( 30 )
          , data_fiscal_s DATE
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
          , cod_situacao_b VARCHAR2 ( 2 )
          , data_emissao DATE
          , cod_estado VARCHAR2 ( 2 )
          , num_controle_docto VARCHAR2 ( 12 )
          , num_autentic_nfe VARCHAR2 ( 80 )
          , ---
            cfop_forn VARCHAR2 ( 5 )
          , vlr_base_icms NUMBER ( 17, 2 )
          , vlr_icms NUMBER ( 17, 2 )
          , aliq_reducao NUMBER ( 5, 2 )
          , vlr_base_icms_st NUMBER ( 17, 2 )
          , vlr_icms_st NUMBER ( 17, 2 )
          , vlr_base_icmsst_ret NUMBER ( 17, 2 )
          , vlr_icmsst_ret NUMBER ( 17, 2 )
          , classificacao NUMBER ( 1 )
        );

        TYPE c_tab_class IS TABLE OF cur_tab_class;

        tab_class c_tab_class;
    BEGIN
        vp_tabela_class := 'DPSP_INTERCLASS' || vp_proc_id;

        v_sql := 'CREATE TABLE ' || vp_tabela_class || ' ( ';
        v_sql := v_sql || ' PROC_ID             NUMBER(30), ';
        v_sql := v_sql || ' DATA_FISCAL_S       DATE, ';
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
        ---
        v_sql := v_sql || ' CFOP_FORN 		    VARCHAR2(5), ';
        v_sql := v_sql || ' VLR_BASE_ICMS 	    NUMBER(17,2), ';
        v_sql := v_sql || ' VLR_ICMS 		    NUMBER(17,2), ';
        v_sql := v_sql || ' ALIQ_REDUCAO 	    NUMBER(5,2), ';
        v_sql := v_sql || ' VLR_BASE_ICMS_ST    NUMBER(17,2), ';
        v_sql := v_sql || ' VLR_ICMS_ST 	    NUMBER(17,2), ';
        v_sql := v_sql || ' VLR_BASE_ICMSST_RET NUMBER(17,2), ';
        v_sql := v_sql || ' VLR_ICMSST_RET 	    NUMBER(17,2), ';
        v_sql := v_sql || ' CLASSIFICACAO 	    NUMBER(1)) ';
        v_sql := v_sql || ' PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        loga ( 'CLASS-INI'
             , FALSE );

        v_sql := ' SELECT /*+DRIVING_SITE(D)*/ ';
        v_sql := v_sql || '  E.PROC_ID           ,';
        v_sql := v_sql || '  E.DATA_FISCAL_S     ,';
        v_sql := v_sql || '  E.COD_EMPRESA       ,';
        v_sql := v_sql || '  E.COD_ESTAB         ,';
        v_sql := v_sql || '  E.DATA_FISCAL       ,';
        v_sql := v_sql || '  E.MOVTO_E_S         ,';
        v_sql := v_sql || '  E.NORM_DEV          ,';
        v_sql := v_sql || '  E.IDENT_DOCTO       ,';
        v_sql := v_sql || '  E.IDENT_FIS_JUR     ,';
        v_sql := v_sql || '  E.NUM_DOCFIS        ,';
        v_sql := v_sql || '  E.SERIE_DOCFIS      ,';
        v_sql := v_sql || '  E.SUB_SERIE_DOCFIS  ,';
        v_sql := v_sql || '  E.DISCRI_ITEM       ,';
        v_sql := v_sql || '  E.NUM_ITEM          ,';
        v_sql := v_sql || '  E.COD_FIS_JUR       ,';
        v_sql := v_sql || '  E.CPF_CGC           ,';
        v_sql := v_sql || '  E.COD_NBM           ,';
        v_sql := v_sql || '  E.COD_CFO           ,';
        v_sql := v_sql || '  E.COD_NATUREZA_OP   ,';
        v_sql := v_sql || '  E.COD_PRODUTO       ,';
        v_sql := v_sql || '  E.VLR_CONTAB_ITEM   ,';
        v_sql := v_sql || '  E.QUANTIDADE        ,';
        v_sql := v_sql || '  E.VLR_UNIT          ,';
        v_sql := v_sql || '  E.COD_SITUACAO_B    ,';
        v_sql := v_sql || '  E.DATA_EMISSAO      ,';
        v_sql := v_sql || '  E.COD_ESTADO        ,';
        v_sql := v_sql || '  E.NUM_CONTROLE_DOCTO,';
        v_sql := v_sql || '  E.NUM_AUTENTIC_NFE  ,';
        ---
        v_sql := v_sql || '	 D.CFOP_FORN		, ';
        v_sql := v_sql || '	 D.VLR_BASE_ICMS	, ';
        v_sql := v_sql || '	 D.VLR_ICMS			, ';
        v_sql := v_sql || '	 D.ALIQ_REDUCAO		, ';
        v_sql := v_sql || '	 D.VLR_BASE_ICMS_ST	, ';
        v_sql := v_sql || '	 D.VLR_ICMS_ST		, ';
        v_sql := v_sql || '	 D.VLR_BASE_ICMSST_RET, ';
        v_sql := v_sql || '	 D.VLR_ICMSST_RET	, ';
        v_sql := v_sql || '	 0 AS CLASSIFICACAO ';
        v_sql := v_sql || ' FROM ' || vp_tab_entrada_c || ' E, ';
        v_sql := v_sql || '      ' || vp_tabela_xml || ' D ';
        v_sql := v_sql || ' WHERE E.PROC_ID 		   = D.PROC_ID (+) ';
        v_sql := v_sql || '   AND E.NUM_CONTROLE_DOCTO = D.NUM_CONTROLE_DOCTO (+) ';
        v_sql := v_sql || '   AND E.NUM_AUTENTIC_NFE   = D.NUM_AUTENTIC_NFE (+) ';
        v_sql := v_sql || '   AND E.NUM_ITEM           = D.NUM_ITEM (+) ';
        v_sql := v_sql || '   AND E.COD_PRODUTO        = D.COD_PRODUTO (+) ';

        BEGIN
            OPEN c_class FOR v_sql;
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
                            , vp_data_inicial
                            , vp_data_final
                            , SQLERRM
                            , 'E'
                            , vp_data_hora_ini );
                -----------------------------------------------------------------
                raise_application_error ( -20007
                                        , '!ERRO SELECT DADOS CLASS!' );
        END;

        LOOP
            FETCH c_class
                BULK COLLECT INTO tab_class
                LIMIT 100;

            FOR i IN 1 .. tab_class.COUNT LOOP
                v_insert :=
                       'INSERT /*+APPEND_VALUES*/ INTO '
                    || vp_tabela_class
                    || ' VALUES ('
                    || tab_class ( i ).proc_id
                    || ','
                    || 'TO_DATE('''
                    || tab_class ( i ).data_fiscal_s
                    || ''',''DD/MM/YYYY''),'''
                    || tab_class ( i ).cod_empresa
                    || ''','''
                    || tab_class ( i ).cod_estab
                    || ''','
                    || 'TO_DATE('''
                    || tab_class ( i ).data_fiscal
                    || ''',''DD/MM/YYYY''),'''
                    || tab_class ( i ).movto_e_s
                    || ''','''
                    || tab_class ( i ).norm_dev
                    || ''','''
                    || tab_class ( i ).ident_docto
                    || ''','''
                    || tab_class ( i ).ident_fis_jur
                    || ''','''
                    || tab_class ( i ).num_docfis
                    || ''','''
                    || tab_class ( i ).serie_docfis
                    || ''','''
                    || tab_class ( i ).sub_serie_docfis
                    || ''','''
                    || tab_class ( i ).discri_item
                    || ''','''
                    || tab_class ( i ).num_item
                    || ''','''
                    || tab_class ( i ).cod_fis_jur
                    || ''','''
                    || tab_class ( i ).cpf_cgc
                    || ''','''
                    || tab_class ( i ).cod_nbm
                    || ''','''
                    || tab_class ( i ).cod_cfo
                    || ''','''
                    || tab_class ( i ).cod_natureza_op
                    || ''','''
                    || tab_class ( i ).cod_produto
                    || ''','
                    || 'TO_NUMBER('''
                    || tab_class ( i ).vlr_contab_item
                    || '''),TO_NUMBER('''
                    || tab_class ( i ).quantidade
                    || '''),TO_NUMBER('''
                    || tab_class ( i ).vlr_unit
                    || '''),'''
                    || tab_class ( i ).cod_situacao_b
                    || ''','
                    || 'TO_DATE('''
                    || tab_class ( i ).data_emissao
                    || ''',''DD/MM/YYYY''),'''
                    || tab_class ( i ).cod_estado
                    || ''','''
                    || tab_class ( i ).num_controle_docto
                    || ''','''
                    || tab_class ( i ).num_autentic_nfe
                    || ''','''
                    || tab_class ( i ).cfop_forn
                    || ''','
                    || 'TO_NUMBER('''
                    || tab_class ( i ).vlr_base_icms
                    || '''),TO_NUMBER('''
                    || tab_class ( i ).vlr_icms
                    || '''),TO_NUMBER('''
                    || tab_class ( i ).aliq_reducao
                    || '''),TO_NUMBER('''
                    || tab_class ( i ).vlr_base_icms_st
                    || '''),TO_NUMBER('''
                    || tab_class ( i ).vlr_icms_st
                    || '''),TO_NUMBER('''
                    || tab_class ( i ).vlr_base_icmsst_ret
                    || '''),TO_NUMBER('''
                    || tab_class ( i ).vlr_icmsst_ret
                    || '''),'
                    || tab_class ( i ).classificacao
                    || ') ';

                BEGIN
                    EXECUTE IMMEDIATE v_insert;

                    COMMIT;
                EXCEPTION
                    WHEN OTHERS THEN
                        loga ( 'SQLERRM: ' || SQLERRM
                             , FALSE );
                        loga ( SUBSTR ( v_insert
                                      , 1
                                      , 1024 )
                             , FALSE );
                        loga ( SUBSTR ( v_insert
                                      , 1024
                                      , 1024 )
                             , FALSE );
                        loga ( SUBSTR ( v_insert
                                      , 2048
                                      , 1024 )
                             , FALSE );
                        loga ( SUBSTR ( v_insert
                                      , 3072 )
                             , FALSE );
                        --ENVIAR EMAIL DE ERRO-------------------------------------------
                        envia_email ( mcod_empresa
                                    , vp_data_inicial
                                    , vp_data_final
                                    , SQLERRM
                                    , 'E'
                                    , vp_data_hora_ini );
                        -----------------------------------------------------------------
                        raise_application_error ( -20007
                                                , '!ERRO INSERT DADOS CLASS!' );
                END;
            END LOOP;

            tab_class.delete;

            EXIT WHEN c_class%NOTFOUND;
        END LOOP;

        COMMIT;

        CLOSE c_class;

        v_sql := 'CREATE UNIQUE INDEX PK_INTERCLASS' || vp_proc_id || ' ON ' || vp_tabela_class || ' ';
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || '    PROC_ID             ASC, ';
        v_sql := v_sql || '    DATA_FISCAL_S	   ASC, ';
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

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX1_INTERCLASS' || vp_proc_id || ' ON ' || vp_tabela_class || ' ';
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || '    PROC_ID ASC ) ';
        v_sql := v_sql || '  PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX2_INTERCLASS' || vp_proc_id || ' ON ' || vp_tabela_class || ' ';
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || '    PROC_ID   ASC,  ';
        v_sql := v_sql || '    CFOP_FORN ASC ) ';
        v_sql := v_sql || '  PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX3_INTERCLASS' || vp_proc_id || ' ON ' || vp_tabela_class || ' ';
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || '    PROC_ID   ASC,  ';
        v_sql := v_sql || '    CFOP_FORN ASC,  ';
        v_sql := v_sql || '    VLR_BASE_ICMS_ST ASC,  ';
        v_sql := v_sql || '    VLR_ICMS_ST ASC ) ';
        v_sql := v_sql || '  PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX4_INTERCLASS' || vp_proc_id || ' ON ' || vp_tabela_class || ' ';
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || '    PROC_ID   ASC,  ';
        v_sql := v_sql || '    CFOP_FORN ASC,  ';
        v_sql := v_sql || '    VLR_BASE_ICMSST_RET ASC,  ';
        v_sql := v_sql || '    VLR_ICMSST_RET ASC ) ';
        v_sql := v_sql || '  PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX5_INTERCLASS' || vp_proc_id || ' ON ' || vp_tabela_class || ' ';
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || '    PROC_ID   ASC,  ';
        v_sql := v_sql || '    COD_PRODUTO ASC,  ';
        v_sql := v_sql || '    DATA_FISCAL_S ASC ) ';
        v_sql := v_sql || '  PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX6_INTERCLASS' || vp_proc_id || ' ON ' || vp_tabela_class || ' ';
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || '    CLASSIFICACAO ASC,  ';
        v_sql := v_sql || '    NUM_CONTROLE_DOCTO ASC,  ';
        v_sql := v_sql || '    NUM_ITEM ASC ) ';
        v_sql := v_sql || '  PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        save_tmp_control ( vp_proc_id
                         , vp_tabela_class );
        ---
        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_tabela_class );

        v_sql := 'SELECT COUNT(*) QTDE_CLASS ';
        v_sql := v_sql || 'FROM ' || vp_tabela_class || ' ';
        v_sql := v_sql || 'WHERE PROC_ID = ' || vp_proc_id;

        EXECUTE IMMEDIATE v_sql            INTO v_qtde_class;

        loga ( 'TAB CLASSIFICACAO CRIADA ' || v_qtde_class || ' LINHAS'
             , FALSE );
    END; --LOAD_TAB_CLASS

    PROCEDURE classif_entradas ( vp_proc_id IN VARCHAR2
                               , vp_tabela_class IN VARCHAR2 )
    IS
    BEGIN
        --CENARIO 2 - TAG ICRT e campos BASE ST RET E VLR ST RET <> 0
        EXECUTE IMMEDIATE
               'UPDATE '
            || vp_tabela_class
            || ' SET CLASSIFICACAO = 2 '
            || 'WHERE CFOP_FORN IN (''5405'',''5409'',''5403'',''A5405'',''A5409'',''A5403'',''B5405'',''B5409'',''B5403'',''C5405'',''C5409'',''C5403'',''D5405'',''D5409'',''D5403'') '
            || '  AND VLR_BASE_ICMSST_RET <> 0 AND VLR_ICMSST_RET <> 0 '
            || '  AND CLASSIFICACAO = 0 '
            || '  AND PROC_ID = '
            || vp_proc_id;

        COMMIT;

        --CENARIO 3 - TAG ICRT e campo BASE ST RET <> 0 E VLR ST RET = 0
        EXECUTE IMMEDIATE
               'UPDATE '
            || vp_tabela_class
            || ' SET CLASSIFICACAO = 3 '
            || 'WHERE CFOP_FORN IN (''5405'',''5409'',''5403'',''A5405'',''A5409'',''A5403'',''B5405'',''B5409'',''B5403'',''C5405'',''C5409'',''C5403'',''D5405'',''D5409'',''D5403'') '
            || '  AND VLR_BASE_ICMSST_RET <> 0 AND VLR_ICMSST_RET = 0 '
            || '  AND CLASSIFICACAO = 0 '
            || '  AND PROC_ID = '
            || vp_proc_id;

        COMMIT;

        --CENARIO 4 - TAG ICRT e campo BASE ST RET = 0 E VLR ST RET <> 0
        EXECUTE IMMEDIATE
               'UPDATE '
            || vp_tabela_class
            || ' SET CLASSIFICACAO = 4 '
            || 'WHERE CFOP_FORN IN (''5405'',''5409'',''5403'',''A5405'',''A5409'',''A5403'',''B5405'',''B5409'',''B5403'',''C5405'',''C5409'',''C5403'',''D5405'',''D5409'',''D5403'') '
            || '  AND VLR_BASE_ICMSST_RET = 0 AND VLR_ICMSST_RET <> 0 '
            || '  AND CLASSIFICACAO = 0 '
            || '  AND PROC_ID = '
            || vp_proc_id;

        COMMIT;

        --CENARIO 6 - TAG ICMS, ICST e ICRET serao iguais a zero
        EXECUTE IMMEDIATE
               'UPDATE '
            || vp_tabela_class
            || ' SET CLASSIFICACAO = 6 '
            || 'WHERE CFOP_FORN IN (''5405'',''5409'',''5403'',''A5405'',''A5409'',''A5403'',''B5405'',''B5409'',''B5403'',''C5405'',''C5409'',''C5403'',''D5405'',''D5409'',''D5403'') '
            || '  AND VLR_BASE_ICMSST_RET = 0 AND VLR_ICMSST_RET = 0 AND VLR_BASE_ICMS_ST = 0 AND VLR_ICMS_ST = 0 AND VLR_BASE_ICMS = 0 AND VLR_ICMS = 0 '
            || '  AND CLASSIFICACAO = 0 '
            || '  AND PROC_ID = '
            || vp_proc_id;

        COMMIT;

        --CENARIO 5 - GARE no PEOPLESOFT - ANTECIPAÇÃO
        EXECUTE IMMEDIATE
               'UPDATE '
            || vp_tabela_class
            || ' SET CLASSIFICACAO = 5 '
            || 'WHERE CFOP_FORN IN (''6152'',''5101'',''6101'',''5102'',''6102'',''6105'',''6106'',''5910'',''6910'',''6917'',''5401'',''5403'',''6401'',''6403'',''6409'',''6404'',''5917'', '
            || ' ''A6152'',''A5101'',''A6101'',''A5102'',''A6102'',''A6105'',''A6106'',''A5910'',''A6910'',''A6917'',''A5401'',''A5403'',''A6401'',''A6403'',''A6409'',''A6404'',''A5917'', '
            || ' ''B6152'',''B5101'',''B6101'',''B5102'',''B6102'',''B6105'',''B6106'',''B5910'',''B6910'',''B6917'',''B5401'',''B5403'',''B6401'',''B6403'',''B6409'',''B6404'',''B5917'', '
            || ' ''C6152'',''C5101'',''C6101'',''C5102'',''C6102'',''C6105'',''C6106'',''C5910'',''C6910'',''C6917'',''C5401'',''C5403'',''C6401'',''C6403'',''C6409'',''C6404'',''C5917'', '
            || ' ''D6152'',''D5101'',''D6101'',''D5102'',''D6102'',''D6105'',''D6106'',''D5910'',''D6910'',''D6917'',''D5401'',''D5403'',''D6401'',''D6403'',''D6409'',''D6404'',''D5917'') '
            || '  AND VLR_BASE_ICMS_ST = 0 AND VLR_ICMS_ST = 0 '
            || '  AND CLASSIFICACAO = 0 '
            || '  AND PROC_ID = '
            || vp_proc_id;

        COMMIT;

        --CENARIO 1 - TAGs ICMS e ICST do VERO IT
        EXECUTE IMMEDIATE
               'UPDATE '
            || vp_tabela_class
            || ' SET CLASSIFICACAO = 1 '
            || 'WHERE CFOP_FORN IN (''5401'',''5403'',''6401'',''6403'',''5910'',''6910'',''6409'',''6404'',''6106'',''6101'',''6102'',''5101'',''5105'',''5102'', '
            || ' ''A5401'',''A5403'',''A6401'',''A6403'',''A5910'',''A6910'',''A6409'',''A6404'',''A6106'',''A6101'',''A6102'',''A5101'',''A5105'',''A5102'', '
            || ' ''B5401'',''B5403'',''B6401'',''B6403'',''B5910'',''B6910'',''B6409'',''B6404'',''B6106'',''B6101'',''B6102'',''B5101'',''B5105'',''B5102'', '
            || ' ''C5401'',''C5403'',''C6401'',''C6403'',''C5910'',''C6910'',''C6409'',''C6404'',''C6106'',''C6101'',''C6102'',''C5101'',''C5105'',''C5102'', '
            || ' ''D5401'',''D5403'',''D6401'',''D6403'',''D5910'',''D6910'',''D6409'',''D6404'',''D6106'',''D6101'',''D6102'',''D5101'',''D5105'',''D5102'') '
            || '  AND VLR_BASE_ICMS_ST <> 0 AND VLR_ICMS_ST <> 0 '
            || '  AND CLASSIFICACAO = 0 '
            || '  AND PROC_ID = '
            || vp_proc_id;

        COMMIT;

        loga ( 'CLASSIFICACAO OK'
             , FALSE );
    END; --CLASSIF_ENTRADAS

    PROCEDURE load_gare ( vp_proc_id IN VARCHAR2
                        , vp_tabela_class IN VARCHAR2
                        , vp_tabela_gare   OUT VARCHAR2
                        , vp_data_inicial IN DATE
                        , vp_data_final IN DATE
                        , vp_cod_estab IN VARCHAR2
                        , vp_data_hora_ini IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 4000 );
        v_insert VARCHAR2 ( 500 );
        c_gare SYS_REFCURSOR;

        TYPE cur_tab_gare IS RECORD
        (
            proc_id NUMBER ( 30 )
          , data_fiscal_s DATE
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
          , business_unit VARCHAR2 ( 6 )
          , nf_brl_id VARCHAR2 ( 12 )
          , nf_brl_line_num VARCHAR2 ( 5 )
          , vlr_antecip_ist NUMBER ( 17, 2 )
          , vlr_antecip_rev NUMBER ( 17, 2 )
        );

        TYPE c_tab_gare IS TABLE OF cur_tab_gare;

        tab_gare c_tab_gare;
    BEGIN
        vp_tabela_gare := 'DPSP_INTERGARE' || vp_proc_id;

        v_sql := 'CREATE TABLE ' || vp_tabela_gare || ' ( ';
        v_sql := v_sql || ' PROC_ID             NUMBER(30),  ';
        v_sql := v_sql || ' DATA_FISCAL_S       DATE, 		 ';
        v_sql := v_sql || ' COD_EMPRESA         VARCHAR2(3), ';
        v_sql := v_sql || ' COD_ESTAB           VARCHAR2(6), ';
        v_sql := v_sql || ' DATA_FISCAL         DATE, 		 ';
        v_sql := v_sql || ' MOVTO_E_S           VARCHAR2(1), ';
        v_sql := v_sql || ' NORM_DEV            VARCHAR2(1), ';
        v_sql := v_sql || ' IDENT_DOCTO         VARCHAR2(12), ';
        v_sql := v_sql || ' IDENT_FIS_JUR       VARCHAR2(12), ';
        v_sql := v_sql || ' NUM_DOCFIS          VARCHAR2(12), ';
        v_sql := v_sql || ' SERIE_DOCFIS        VARCHAR2(3),  ';
        v_sql := v_sql || ' SUB_SERIE_DOCFIS    VARCHAR2(2),  ';
        v_sql := v_sql || ' DISCRI_ITEM         VARCHAR2(46), ';
        ---
        v_sql := v_sql || ' BUSINESS_UNIT	   VARCHAR2(6),   ';
        v_sql := v_sql || ' NF_BRL_ID    	   VARCHAR2(12),  ';
        v_sql := v_sql || ' NF_BRL_LINE_NUM	   VARCHAR2(5),   ';
        v_sql := v_sql || ' VLR_ANTECIP_IST    NUMBER(17,2),  ';
        v_sql := v_sql || ' VLR_ANTECIP_REV    NUMBER(17,2))  ';
        v_sql := v_sql || ' PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        loga ( 'GARE-INI'
             , FALSE );

        IF ( vp_cod_estab = 'DP906' ) THEN
            --REGRA ESPECIAL PARA RJ - O VLR ST DA ANTECIPACAO VEM DE PROCESSO NO PSFT
            --FINALIDADE DE SAIDA REV NAO TEM RESSARCIMENTO, ENTAO FICA FIXADO IST
            v_sql := ' SELECT /*+DRIVING_SITE(A)*/ ';
            v_sql := v_sql || '	  E.PROC_ID          ,';
            v_sql := v_sql || '   E.DATA_FISCAL_S    ,';
            v_sql := v_sql || '	  E.COD_EMPRESA      ,';
            v_sql := v_sql || '	  E.COD_ESTAB        ,';
            v_sql := v_sql || '	  E.DATA_FISCAL      ,';
            v_sql := v_sql || '	  E.MOVTO_E_S        ,';
            v_sql := v_sql || '	  E.NORM_DEV         ,';
            v_sql := v_sql || '	  E.IDENT_DOCTO      ,';
            v_sql := v_sql || '	  E.IDENT_FIS_JUR    ,';
            v_sql := v_sql || '	  E.NUM_DOCFIS       ,';
            v_sql := v_sql || '	  E.SERIE_DOCFIS     ,';
            v_sql := v_sql || '	  E.SUB_SERIE_DOCFIS ,';
            v_sql := v_sql || '	  E.DISCRI_ITEM      ,';
            ---
            v_sql := v_sql || '	  A.BUSINESS_UNIT	 , ';
            v_sql := v_sql || '	  A.NF_BRL_ID		 , ';
            v_sql := v_sql || '	  A.NF_BRL_LINE_NUM	 , ';
            v_sql := v_sql || '	  A.VLR_ANTECIP_IST  , ';
            v_sql := v_sql || '	  A.VLR_ANTECIP_REV	   ';
            v_sql := v_sql || ' FROM ( ';
            v_sql :=
                   v_sql
                || ' 	SELECT DISTINCT D.BUSINESS_UNIT, D.NF_BRL_ID, D.NF_BRL_LINE_NUM, D.ACCOUNTING_DT AS DATA_FISCAL, D.DSP_ICMS_AMT_ST AS VLR_ANTECIP_IST, 0 AS VLR_ANTECIP_REV ';
            v_sql := v_sql || '	 	FROM MSAFI.PS_DSP_OBR_PO_ST_T D ';
            v_sql := v_sql || '     WHERE D.BUSINESS_UNIT = ''VD906'' ) A, ';
            v_sql := v_sql || ' ' || vp_tabela_class || ' E ';
            v_sql := v_sql || ' WHERE E.CLASSIFICACAO   = 5 ';
            v_sql := v_sql || '   AND A.DATA_FISCAL     = E.DATA_FISCAL ';
            v_sql := v_sql || '   AND A.NF_BRL_ID       = E.NUM_CONTROLE_DOCTO ';
            v_sql := v_sql || '   AND A.NF_BRL_LINE_NUM = E.NUM_ITEM ';
        ELSE
            v_sql := ' SELECT /*+DRIVING_SITE(A)*/ ';
            v_sql := v_sql || '	  E.PROC_ID          ,';
            v_sql := v_sql || '   E.DATA_FISCAL_S    ,';
            v_sql := v_sql || '	  E.COD_EMPRESA      ,';
            v_sql := v_sql || '	  E.COD_ESTAB        ,';
            v_sql := v_sql || '	  E.DATA_FISCAL      ,';
            v_sql := v_sql || '	  E.MOVTO_E_S        ,';
            v_sql := v_sql || '	  E.NORM_DEV         ,';
            v_sql := v_sql || '	  E.IDENT_DOCTO      ,';
            v_sql := v_sql || '	  E.IDENT_FIS_JUR    ,';
            v_sql := v_sql || '	  E.NUM_DOCFIS       ,';
            v_sql := v_sql || '	  E.SERIE_DOCFIS     ,';
            v_sql := v_sql || '	  E.SUB_SERIE_DOCFIS ,';
            v_sql := v_sql || '	  E.DISCRI_ITEM      ,';
            ---
            v_sql := v_sql || '	  A.BUSINESS_UNIT	 , ';
            v_sql := v_sql || '	  A.NF_BRL_ID		 , ';
            v_sql := v_sql || '	  A.NF_BRL_LINE_NUM	 , ';
            v_sql := v_sql || '	  A.VLR_ANTECIP_IST  , ';
            v_sql := v_sql || '	  A.VLR_ANTECIP_REV	   ';
            v_sql := v_sql || ' FROM ( ';
            v_sql :=
                   v_sql
                || ' 	SELECT D.BUSINESS_UNIT, D.NF_BRL_ID, D.NF_BRL_LINE_NUM, DSP_ICMS_AMT_ST AS VLR_ANTECIP_IST, DSP_ANTECIP_BSE AS VLR_ANTECIP_REV ';
            v_sql := v_sql || '	 	FROM MSAFI.PS_NF_LN_BRL D ) A, ';
            v_sql := v_sql || ' ' || vp_tabela_class || ' E, ';
            v_sql := v_sql || '     MSAFI.DSP_INTERFACE_SETUP P ';
            v_sql := v_sql || ' WHERE E.CLASSIFICACAO   = 5 ';
            v_sql := v_sql || '   AND A.BUSINESS_UNIT   IN (P.BU_PO1, P.BU_PO2, P.BU_PO3, P.BU_PO4, P.BU_PO5) ';
            v_sql := v_sql || '   AND A.NF_BRL_ID       = E.NUM_CONTROLE_DOCTO ';
            v_sql := v_sql || '   AND A.NF_BRL_LINE_NUM = E.NUM_ITEM ';
            v_sql := v_sql || '   AND P.COD_EMPRESA     = MSAFI.DPSP.EMPRESA ';
        END IF;

        BEGIN
            OPEN c_gare FOR v_sql;
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
                            , vp_data_inicial
                            , vp_data_final
                            , SQLERRM
                            , 'E'
                            , vp_data_hora_ini );
                -----------------------------------------------------------------
                raise_application_error ( -20007
                                        , '!ERRO SELECT DADOS GARE!' );
        END;

        LOOP
            FETCH c_gare
                BULK COLLECT INTO tab_gare
                LIMIT 100;

            FOR i IN 1 .. tab_gare.COUNT LOOP
                v_insert :=
                       'INSERT /*+APPEND_VALUES*/ INTO '
                    || vp_tabela_gare
                    || ' VALUES ('
                    || tab_gare ( i ).proc_id
                    || ','
                    || 'TO_DATE('''
                    || tab_gare ( i ).data_fiscal_s
                    || ''',''DD/MM/YYYY''),'''
                    || tab_gare ( i ).cod_empresa
                    || ''','''
                    || tab_gare ( i ).cod_estab
                    || ''','
                    || 'TO_DATE('''
                    || tab_gare ( i ).data_fiscal
                    || ''',''DD/MM/YYYY''),'''
                    || tab_gare ( i ).movto_e_s
                    || ''','''
                    || tab_gare ( i ).norm_dev
                    || ''','''
                    || tab_gare ( i ).ident_docto
                    || ''','''
                    || tab_gare ( i ).ident_fis_jur
                    || ''','''
                    || tab_gare ( i ).num_docfis
                    || ''','''
                    || tab_gare ( i ).serie_docfis
                    || ''','''
                    || tab_gare ( i ).sub_serie_docfis
                    || ''','''
                    || tab_gare ( i ).discri_item
                    || ''','''
                    || tab_gare ( i ).business_unit
                    || ''','''
                    || tab_gare ( i ).nf_brl_id
                    || ''','''
                    || tab_gare ( i ).nf_brl_line_num
                    || ''','
                    || 'TO_NUMBER('''
                    || tab_gare ( i ).vlr_antecip_ist
                    || '''),'
                    || 'TO_NUMBER('''
                    || tab_gare ( i ).vlr_antecip_rev
                    || ''') ) ';

                BEGIN
                    EXECUTE IMMEDIATE v_insert;

                    COMMIT;
                EXCEPTION
                    WHEN OTHERS THEN
                        loga ( 'SQLERRM: ' || SQLERRM
                             , FALSE );
                        loga ( SUBSTR ( v_insert
                                      , 1
                                      , 1024 )
                             , FALSE );
                        loga ( SUBSTR ( v_insert
                                      , 1024
                                      , 1024 )
                             , FALSE );
                        loga ( SUBSTR ( v_insert
                                      , 2048
                                      , 1024 )
                             , FALSE );
                        loga ( SUBSTR ( v_insert
                                      , 3072 )
                             , FALSE );
                        --ENVIAR EMAIL DE ERRO-------------------------------------------
                        envia_email ( mcod_empresa
                                    , vp_data_inicial
                                    , vp_data_final
                                    , SQLERRM
                                    , 'E'
                                    , vp_data_hora_ini );
                        -----------------------------------------------------------------
                        raise_application_error ( -20007
                                                , '!ERRO INSERT DADOS GARE!' );
                END;
            END LOOP;

            tab_gare.delete;

            EXIT WHEN c_gare%NOTFOUND;
        END LOOP;

        COMMIT;

        CLOSE c_gare;

        v_sql := 'CREATE UNIQUE INDEX PK_INTERGARE' || vp_proc_id || ' ON ' || vp_tabela_gare || ' ';
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || '    PROC_ID           ASC, ';
        v_sql := v_sql || '    DATA_FISCAL_S     ASC, ';
        v_sql := v_sql || '    COD_EMPRESA       ASC, ';
        v_sql := v_sql || '    COD_ESTAB         ASC, ';
        v_sql := v_sql || '    DATA_FISCAL       ASC, ';
        v_sql := v_sql || '    MOVTO_E_S         ASC, ';
        v_sql := v_sql || '    NORM_DEV          ASC, ';
        v_sql := v_sql || '    IDENT_DOCTO       ASC, ';
        v_sql := v_sql || '    IDENT_FIS_JUR     ASC, ';
        v_sql := v_sql || '    NUM_DOCFIS        ASC, ';
        v_sql := v_sql || '    SERIE_DOCFIS      ASC, ';
        v_sql := v_sql || '    SUB_SERIE_DOCFIS  ASC, ';
        v_sql := v_sql || '    DISCRI_ITEM       ASC ) ';
        v_sql := v_sql || '  PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        save_tmp_control ( vp_proc_id
                         , vp_tabela_gare );
        ---
        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_tabela_gare );

        loga ( 'GARE-FIM '
             , FALSE );
    END; --LOAD_DADOS_XML

    PROCEDURE load_gare_refugo ( vp_proc_id IN VARCHAR2
                               , vp_tabela_class IN VARCHAR2
                               , vp_tabela_gare IN VARCHAR2
                               , vp_data_inicial IN DATE
                               , vp_data_final IN DATE
                               , vp_cod_estab IN VARCHAR2
                               , vp_data_hora_ini IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 4000 );
        v_insert VARCHAR2 ( 500 );
        c_gare SYS_REFCURSOR;

        TYPE cur_tab_gare IS RECORD
        (
            proc_id NUMBER ( 30 )
          , data_fiscal_s DATE
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
          , business_unit VARCHAR2 ( 6 )
          , nf_brl_id VARCHAR2 ( 12 )
          , nf_brl_line_num VARCHAR2 ( 5 )
          , vlr_antecip_ist NUMBER ( 17, 2 )
          , vlr_antecip_rev NUMBER ( 17, 2 )
          , vlr_icms NUMBER ( 17, 2 )
        );

        TYPE c_tab_gare IS TABLE OF cur_tab_gare;

        tab_gare c_tab_gare;

        errors NUMBER;
        dml_errors EXCEPTION;
    BEGIN
        loga ( 'GARE_R-INI'
             , FALSE );

        IF ( vp_cod_estab <> 'DP906' ) THEN
            v_sql := ' SELECT /*+DRIVING_SITE(A)*/ ';
            v_sql := v_sql || '	  E.PROC_ID          ,';
            v_sql := v_sql || '   E.DATA_FISCAL_S    ,';
            v_sql := v_sql || '	  E.COD_EMPRESA      ,';
            v_sql := v_sql || '	  E.COD_ESTAB        ,';
            v_sql := v_sql || '	  E.DATA_FISCAL      ,';
            v_sql := v_sql || '	  E.MOVTO_E_S        ,';
            v_sql := v_sql || '	  E.NORM_DEV         ,';
            v_sql := v_sql || '	  E.IDENT_DOCTO      ,';
            v_sql := v_sql || '	  E.IDENT_FIS_JUR    ,';
            v_sql := v_sql || '	  E.NUM_DOCFIS       ,';
            v_sql := v_sql || '	  E.SERIE_DOCFIS     ,';
            v_sql := v_sql || '	  E.SUB_SERIE_DOCFIS ,';
            v_sql := v_sql || '	  E.DISCRI_ITEM      ,';
            ---
            v_sql := v_sql || '	  A.BUSINESS_UNIT	 , ';
            v_sql := v_sql || '	  A.NF_BRL_ID		 , ';
            v_sql := v_sql || '	  A.NF_BRL_LINE_NUM	 , ';
            v_sql := v_sql || '	  A.VLR_ANTECIP_IST  , ';
            v_sql := v_sql || '	  A.VLR_ANTECIP_REV	 , ';
            v_sql := v_sql || '	  A.VLR_ICMS		   ';
            v_sql := v_sql || ' FROM ( ';
            v_sql :=
                   v_sql
                || ' 	SELECT D.BUSINESS_UNIT, D.NF_BRL_ID, D.NF_BRL_LINE_NUM, D.DSP_ICMS_AMT_ST AS VLR_ANTECIP_IST, D.DSP_ANTECIP_BSE AS VLR_ANTECIP_REV, D.ICMSTAX_BRL_AMT AS VLR_ICMS ';
            v_sql := v_sql || '	 	FROM MSAFI.PS_NF_LN_BRL D WHERE DSP_ICMS_AMT_ST > 0 OR DSP_ANTECIP_BSE > 0 ) A, ';
            v_sql := v_sql || ' ' || vp_tabela_class || ' E, ';
            v_sql := v_sql || '     MSAFI.DSP_INTERFACE_SETUP P ';
            v_sql := v_sql || ' WHERE E.CLASSIFICACAO   = 0 '; --SEM CLASSIFICACAO
            v_sql := v_sql || '   AND A.BUSINESS_UNIT   IN (P.BU_PO1, P.BU_PO2, P.BU_PO3, P.BU_PO4, P.BU_PO5) ';
            v_sql := v_sql || '   AND A.NF_BRL_ID       = E.NUM_CONTROLE_DOCTO ';
            v_sql := v_sql || '   AND A.NF_BRL_LINE_NUM = E.NUM_ITEM ';
            v_sql := v_sql || '   AND P.COD_EMPRESA     = MSAFI.DPSP.EMPRESA ';

            BEGIN
                OPEN c_gare FOR v_sql;
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
                                , vp_data_inicial
                                , vp_data_final
                                , SQLERRM
                                , 'E'
                                , vp_data_hora_ini );
                    -----------------------------------------------------------------
                    raise_application_error ( -20007
                                            , '!ERRO SELECT DADOS GARE_R!' );
            END;

            LOOP
                FETCH c_gare
                    BULK COLLECT INTO tab_gare
                    LIMIT 100;

                --INSERT NA TABELA TEMP DE GARE / ANTECIPACAO---------------------------------
                BEGIN
                    FORALL i IN tab_gare.FIRST .. tab_gare.LAST
                        EXECUTE IMMEDIATE
                               'INSERT /*+APPEND_VALUES*/ INTO '
                            || vp_tabela_gare
                            || ' VALUES (:1, :2, :3, :4, :5, :6, :7, :8, :9, '
                            || ' :10, :11, :12, :13, :14, :15, :16, :17, :18) '
                            USING tab_gare ( i ).proc_id
                                , tab_gare ( i ).data_fiscal_s
                                , tab_gare ( i ).cod_empresa
                                , tab_gare ( i ).cod_estab
                                , tab_gare ( i ).data_fiscal
                                , tab_gare ( i ).movto_e_s
                                , tab_gare ( i ).norm_dev
                                , tab_gare ( i ).ident_docto
                                , tab_gare ( i ).ident_fis_jur
                                , tab_gare ( i ).num_docfis
                                , tab_gare ( i ).serie_docfis
                                , tab_gare ( i ).sub_serie_docfis
                                , tab_gare ( i ).discri_item
                                , tab_gare ( i ).business_unit
                                , tab_gare ( i ).nf_brl_id
                                , tab_gare ( i ).nf_brl_line_num
                                , tab_gare ( i ).vlr_antecip_ist
                                , tab_gare ( i ).vlr_antecip_rev;
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
                                                , '!ERRO INSERT DADOS GARE_R!' );
                END;

                ---------------------------------------------------------------------------------
                --UPDATE NA TABELA TEMP ENTRADAS / CLASSIFICACAO---------------------------------
                BEGIN
                    FORALL i IN tab_gare.FIRST .. tab_gare.LAST SAVE EXCEPTIONS
                        EXECUTE IMMEDIATE
                               'UPDATE '
                            || vp_tabela_class
                            || ' SET CFOP_FORN = ''ANT'', VLR_ICMS = :1, CLASSIFICACAO = 5 '
                            || 'WHERE PROC_ID = :2 AND DATA_FISCAL_S = :3 AND COD_EMPRESA = :4 AND COD_ESTAB = :5 AND DATA_FISCAL = :6 AND MOVTO_E_S = :7 AND '
                            || '      NORM_DEV = :8 AND IDENT_DOCTO = :9 AND IDENT_FIS_JUR = :10 AND NUM_DOCFIS = :11 AND SERIE_DOCFIS = :12 AND SUB_SERIE_DOCFIS = :13 AND '
                            || '      DISCRI_ITEM = :14 '
                            USING tab_gare ( i ).vlr_icms
                                , tab_gare ( i ).proc_id
                                , tab_gare ( i ).data_fiscal_s
                                , tab_gare ( i ).cod_empresa
                                , tab_gare ( i ).cod_estab
                                , tab_gare ( i ).data_fiscal
                                , tab_gare ( i ).movto_e_s
                                , tab_gare ( i ).norm_dev
                                , tab_gare ( i ).ident_docto
                                , tab_gare ( i ).ident_fis_jur
                                , tab_gare ( i ).num_docfis
                                , tab_gare ( i ).serie_docfis
                                , tab_gare ( i ).sub_serie_docfis
                                , tab_gare ( i ).discri_item;
                EXCEPTION
                    WHEN OTHERS THEN
                        errors := SQL%BULK_EXCEPTIONS.COUNT;

                        FOR i IN 1 .. errors LOOP
                            loga ( 'ERRO #' || i || ' LINHA #' || SQL%BULK_EXCEPTIONS ( i ).ERROR_INDEX
                                 , FALSE );
                            loga ( 'MSG: ' || SQLERRM ( -SQL%BULK_EXCEPTIONS ( i ).ERROR_CODE )
                                 , FALSE );
                        END LOOP;

                        --ENVIAR EMAIL DE ERRO-------------------------------------------
                        envia_email ( mcod_empresa
                                    , vp_data_inicial
                                    , vp_data_final
                                    , SQLERRM
                                    , 'E'
                                    , vp_data_hora_ini );
                        -----------------------------------------------------------------
                        raise_application_error ( -20004
                                                , '!ERRO UPDATE GARE_R!' );
                END;

                COMMIT;
                tab_gare.delete;

                EXIT WHEN c_gare%NOTFOUND;
            END LOOP;

            COMMIT;

            CLOSE c_gare;

            ---
            dbms_stats.gather_table_stats ( 'MSAF'
                                          , vp_tabela_gare );
        END IF;

        loga ( 'GARE_R-FIM '
             , FALSE );
    END; --LOAD_GARE_REFUGO

    PROCEDURE create_tab_tmp_inter ( vp_proc_id IN NUMBER
                                   , vp_tabela_saida IN VARCHAR2
                                   , vp_tabela_class IN VARCHAR2
                                   , vp_nome_tabela_aliq IN VARCHAR2
                                   , vp_tabela_gare IN VARCHAR2
                                   , vp_tabela_inter_tmp   OUT VARCHAR2
                                   , vp_data_inicial IN DATE
                                   , vp_data_final IN DATE
                                   , vp_data_hora_ini IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 5000 );
    BEGIN
        vp_tabela_inter_tmp := 'DPSP_INTER_TMP' || vp_proc_id;

        v_sql := 'CREATE TABLE ' || vp_tabela_inter_tmp || ' ( ';
        v_sql := v_sql || 'COD_EMPRESA         VARCHAR2(3),  ';
        v_sql := v_sql || 'COD_ESTAB           VARCHAR2(6),  ';
        v_sql := v_sql || 'NUM_DOCFIS          VARCHAR2(12), ';
        v_sql := v_sql || 'NUM_CONTROLE_DOCTO  VARCHAR2(12), ';
        v_sql := v_sql || 'NUM_ITEM            NUMBER(5), 	 ';
        v_sql := v_sql || 'COD_PRODUTO         VARCHAR2(35), ';
        v_sql := v_sql || 'DESCR_ITEM          VARCHAR2(50), ';
        v_sql := v_sql || 'DATA_FISCAL         DATE, 		 ';
        v_sql := v_sql || 'UF_ORIGEM           VARCHAR2(2),  ';
        v_sql := v_sql || 'UF_DESTINO          VARCHAR2(2),  ';
        v_sql := v_sql || 'COD_FIS_JUR 		   VARCHAR2(14), ';
        v_sql := v_sql || 'CNPJ                VARCHAR2(14), ';
        v_sql := v_sql || 'RAZAO_SOCIAL        VARCHAR2(70), ';
        v_sql := v_sql || 'SERIE_DOCFIS        VARCHAR2(3),  ';
        v_sql := v_sql || 'CFOP                VARCHAR2(5),  ';
        v_sql := v_sql || 'FINALIDADE          VARCHAR2(3),  ';
        v_sql := v_sql || 'NBM                 VARCHAR2(10), ';
        v_sql := v_sql || 'NUM_AUTENTIC_NFE    VARCHAR2(80), ';
        v_sql := v_sql || 'QUANTIDADE          NUMBER(17,6), ';
        v_sql := v_sql || 'VLR_UNIT			   NUMBER(19,4), ';
        v_sql := v_sql || 'VLR_ITEM            NUMBER(17,2), ';
        v_sql := v_sql || 'VLR_BASE_ICMS	   NUMBER(17,2), ';
        v_sql := v_sql || 'VLR_ICMS			   NUMBER(17,2), ';
        v_sql := v_sql || 'ALIQ_ICMS		   NUMBER(5,2),  ';
        ---
        v_sql := v_sql || 'COD_ESTAB_E         VARCHAR2(6),  ';
        v_sql := v_sql || 'DATA_FISCAL_E       DATE, 		 ';
        v_sql := v_sql || 'MOVTO_E_S           VARCHAR2(1),  ';
        v_sql := v_sql || 'NORM_DEV            VARCHAR2(1),  ';
        v_sql := v_sql || 'IDENT_DOCTO         VARCHAR2(12), ';
        v_sql := v_sql || 'IDENT_FIS_JUR       VARCHAR2(12), ';
        v_sql := v_sql || 'NUM_DOCFIS_E        VARCHAR2(12), ';
        v_sql := v_sql || 'SERIE_DOCFIS_E      VARCHAR2(3),  ';
        v_sql := v_sql || 'SUB_SERIE_DOCFIS    VARCHAR2(2),  ';
        v_sql := v_sql || 'DISCRI_ITEM         VARCHAR2(46), ';
        v_sql := v_sql || 'NUM_ITEM_E        	NUMBER(5),   ';
        v_sql := v_sql || 'COD_FIS_JUR_E       	VARCHAR2(14), ';
        v_sql := v_sql || 'CPF_CGC             	VARCHAR2(14), ';
        v_sql := v_sql || 'COD_NBM             	VARCHAR2(10), ';
        v_sql := v_sql || 'COD_CFO             	VARCHAR2(4),  ';
        v_sql := v_sql || 'COD_NATUREZA_OP     	VARCHAR2(3),  ';
        v_sql := v_sql || 'VLR_CONTAB_ITEM     	NUMBER(17,2), ';
        v_sql := v_sql || 'QUANTIDADE_E        	NUMBER(12,4), ';
        v_sql := v_sql || 'VLR_UNIT_E          	NUMBER(17,2), ';
        v_sql := v_sql || 'COD_SITUACAO_B      	VARCHAR2(2),  ';
        v_sql := v_sql || 'DATA_EMISSAO        	DATE, 		  ';
        v_sql := v_sql || 'COD_ESTADO          	VARCHAR2(2),  ';
        v_sql := v_sql || 'NUM_CONTROLE_DOCTO_E	VARCHAR2(12), ';
        v_sql := v_sql || 'NUM_AUTENTIC_NFE_E  	VARCHAR2(80), ';
        v_sql := v_sql || 'CFOP_FORN 		    VARCHAR2(5),  ';
        v_sql := v_sql || 'VLR_BASE_ICMS_E 	    NUMBER(17,2), ';
        v_sql := v_sql || 'VLR_ICMS_E 		    NUMBER(17,2), ';
        v_sql := v_sql || 'ALIQ_REDUCAO 	    NUMBER(5,2),  ';
        v_sql := v_sql || 'VLR_BASE_ICMS_ST    	NUMBER(17,2), ';
        v_sql := v_sql || 'VLR_ICMS_ST 	    	NUMBER(17,2), ';
        v_sql := v_sql || 'VLR_BASE_ICMSST_RET 	NUMBER(17,2), ';
        v_sql := v_sql || 'VLR_ICMSST_RET 	    NUMBER(17,2), ';
        v_sql := v_sql || 'CLASSIFICACAO 	    NUMBER(1), 	  ';
        ---
        v_sql := v_sql || 'ALIQ_INTERNA 		NUMBER(5,2),  ';
        v_sql := v_sql || 'BUSINESS_UNIT 		VARCHAR2(6),  ';
        v_sql := v_sql || 'ID_PEOPLE_GARE       VARCHAR2(12), ';
        v_sql := v_sql || 'VLR_ANTECIP_IST 		NUMBER(17,2), ';
        v_sql := v_sql || 'VLR_ANTECIP_REV 		NUMBER(17,2), ';
        ---
        v_sql := v_sql || 'VLR_ICMS_CALCULADO	NUMBER(17,2), ';
        v_sql := v_sql || 'VLR_ICMS_RESSARC     NUMBER(17,4), ';
        v_sql := v_sql || 'VLR_ICMSST_RESSARC   NUMBER(17,4), ';
        v_sql := v_sql || 'VLR_ICMS_ANT_RES     NUMBER(17,4), ';
        v_sql := v_sql || 'USUARIO		        VARCHAR2(40), ';
        v_sql := v_sql || 'DTTM_CRIACAO	        DATE ) ';
        v_sql := v_sql || ' PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'INSERT /*+APPEND*/ INTO ' || vp_tabela_inter_tmp || ' ( ';
        v_sql := v_sql || 'SELECT ';
        v_sql := v_sql || ' S.COD_EMPRESA 		 ';
        v_sql := v_sql || ',S.COD_ESTAB  		 ';
        v_sql := v_sql || ',S.NUM_DOCFIS         ';
        v_sql := v_sql || ',S.NUM_CONTROLE_DOCTO ';
        v_sql := v_sql || ',S.NUM_ITEM           ';
        v_sql := v_sql || ',S.COD_PRODUTO        ';
        v_sql := v_sql || ',S.DESCR_ITEM         ';
        v_sql := v_sql || ',S.DATA_FISCAL        ';
        v_sql := v_sql || ',S.UF_ORIGEM          ';
        v_sql := v_sql || ',S.UF_DESTINO         ';
        v_sql := v_sql || ',S.COD_FIS_JUR 		 ';
        v_sql := v_sql || ',S.CNPJ				 ';
        v_sql := v_sql || ',S.RAZAO_SOCIAL       ';
        v_sql := v_sql || ',S.SERIE_DOCFIS       ';
        v_sql := v_sql || ',S.CFOP               ';
        v_sql := v_sql || ',S.FINALIDADE         ';
        v_sql := v_sql || ',S.NBM                ';
        v_sql := v_sql || ',S.NUM_AUTENTIC_NFE   ';
        v_sql := v_sql || ',S.QUANTIDADE         ';
        v_sql := v_sql || ',S.VLR_UNIT           ';
        v_sql := v_sql || ',S.VLR_ITEM           ';
        v_sql := v_sql || ',S.VLR_BASE_ICMS      ';
        v_sql := v_sql || ',S.VLR_ICMS           ';
        v_sql := v_sql || ',S.ALIQ_ICMS          ';
        ---
        v_sql := v_sql || ',E.COD_ESTAB          ';
        v_sql := v_sql || ',E.DATA_FISCAL        ';
        v_sql := v_sql || ',E.MOVTO_E_S          ';
        v_sql := v_sql || ',E.NORM_DEV           ';
        v_sql := v_sql || ',E.IDENT_DOCTO        ';
        v_sql := v_sql || ',E.IDENT_FIS_JUR      ';
        v_sql := v_sql || ',E.NUM_DOCFIS         ';
        v_sql := v_sql || ',E.SERIE_DOCFIS       ';
        v_sql := v_sql || ',E.SUB_SERIE_DOCFIS   ';
        v_sql := v_sql || ',E.DISCRI_ITEM        ';
        v_sql := v_sql || ',E.NUM_ITEM           ';
        v_sql := v_sql || ',E.COD_FIS_JUR        ';
        v_sql := v_sql || ',E.CPF_CGC            ';
        v_sql := v_sql || ',E.COD_NBM            ';
        v_sql := v_sql || ',E.COD_CFO            ';
        v_sql := v_sql || ',E.COD_NATUREZA_OP    ';
        v_sql := v_sql || ',E.VLR_CONTAB_ITEM    ';
        v_sql := v_sql || ',E.QUANTIDADE         ';
        v_sql := v_sql || ',E.VLR_UNIT           ';
        v_sql := v_sql || ',E.COD_SITUACAO_B     ';
        v_sql := v_sql || ',E.DATA_EMISSAO       ';
        v_sql := v_sql || ',E.COD_ESTADO         ';
        v_sql := v_sql || ',E.NUM_CONTROLE_DOCTO ';
        v_sql := v_sql || ',E.NUM_AUTENTIC_NFE   ';
        ---XML
        v_sql := v_sql || ',E.CFOP_FORN          ';
        v_sql := v_sql || ',E.VLR_BASE_ICMS      ';
        v_sql := v_sql || ',E.VLR_ICMS           ';
        v_sql := v_sql || ',E.ALIQ_REDUCAO       ';
        v_sql := v_sql || ',E.VLR_BASE_ICMS_ST   ';
        v_sql := v_sql || ',E.VLR_ICMS_ST        ';
        v_sql := v_sql || ',E.VLR_BASE_ICMSST_RET'; --RETIDO
        v_sql := v_sql || ',E.VLR_ICMSST_RET     '; --RETIDO
        v_sql := v_sql || ',E.CLASSIFICACAO      ';
        ---PSFT
        v_sql := v_sql || ',NVL(A.ALIQ_INTERNA, 0) AS ALIQ_INTERNA ';
        v_sql := v_sql || ',G.BUSINESS_UNIT ';
        v_sql := v_sql || ',G.NF_BRL_ID ';
        v_sql := v_sql || ',NVL(G.VLR_ANTECIP_IST, 0) AS  VLR_ANTECIP_IST ';
        v_sql := v_sql || ',NVL(G.VLR_ANTECIP_REV, 0) AS  VLR_ANTECIP_REV ';
        ---CALCULOS
        v_sql :=
               v_sql
            || ',CASE WHEN E.CLASSIFICACAO = 2 THEN ((E.VLR_BASE_ICMSST_RET*(NVL(A.ALIQ_INTERNA, 0)/100))-E.VLR_ICMSST_RET) '; --OK
        v_sql := v_sql || '      ELSE 0 END AS VLR_ICMS_CALCULADO ';

        v_sql := v_sql || ',CASE WHEN E.CLASSIFICACAO = 1 THEN (E.VLR_ICMS/E.QUANTIDADE)*S.QUANTIDADE '; --OK
        v_sql :=
               v_sql
            || '      WHEN E.CLASSIFICACAO = 2 THEN (((E.VLR_BASE_ICMSST_RET*(NVL(A.ALIQ_INTERNA, 0)/100))-E.VLR_ICMSST_RET)/E.QUANTIDADE)*S.QUANTIDADE '; --OK
        v_sql :=
            v_sql || '      WHEN E.CLASSIFICACAO = 5 AND E.VLR_ICMS > 0 THEN (E.VLR_ICMS/E.QUANTIDADE)*S.QUANTIDADE '; --OK
        v_sql :=
               v_sql
            || '      WHEN E.CLASSIFICACAO = 6 AND S.UF_ORIGEM <> ''MG'' THEN ((E.VLR_CONTAB_ITEM * (NVL(A.ALIQ_INTERNA, 0)/100))/E.QUANTIDADE)*S.QUANTIDADE '; --OK
        v_sql := v_sql || ' ELSE 0 END AS ICMS_RESSARC ';

        v_sql := v_sql || ',CASE WHEN E.CLASSIFICACAO = 1 THEN (E.VLR_ICMS_ST/E.QUANTIDADE)*S.QUANTIDADE '; --OK
        v_sql := v_sql || '      WHEN E.CLASSIFICACAO = 2 THEN (E.VLR_ICMSST_RET/E.QUANTIDADE)*S.QUANTIDADE '; --OK
        v_sql :=
               v_sql
            || '      WHEN E.CLASSIFICACAO = 3 THEN ((E.VLR_BASE_ICMSST_RET*(NVL(A.ALIQ_INTERNA, 0)/100))/E.QUANTIDADE)*S.QUANTIDADE '; --OK
        v_sql := v_sql || '      WHEN E.CLASSIFICACAO = 4 THEN (E.VLR_ICMSST_RET/E.QUANTIDADE)*S.QUANTIDADE '; --OK
        v_sql := v_sql || ' ELSE 0 END AS ICMSST_RESSARC ';

        v_sql :=
               v_sql
            || ',CASE WHEN E.CLASSIFICACAO = 5 AND G.VLR_ANTECIP_REV > 0 THEN (NVL(G.VLR_ANTECIP_REV, 0)/E.QUANTIDADE)*S.QUANTIDADE ';
        v_sql :=
               v_sql
            || '      WHEN E.CLASSIFICACAO = 5 AND G.VLR_ANTECIP_IST > 0 THEN (NVL(G.VLR_ANTECIP_IST, 0)/E.QUANTIDADE)*S.QUANTIDADE ';
        v_sql := v_sql || ' ELSE 0 END AS ICMS_ANTECIP_RESSAC '; --OK

        v_sql := v_sql || ',''' || musuario || ''' ';
        v_sql := v_sql || ',SYSDATE ';
        v_sql := v_sql || 'FROM ' || vp_tabela_saida || ' S, ';
        v_sql := v_sql || '     ' || vp_tabela_class || ' E, ';
        v_sql := v_sql || '     ' || vp_nome_tabela_aliq || ' A, ';
        v_sql := v_sql || '     ' || vp_tabela_gare || ' G ';
        v_sql := v_sql || 'WHERE S.COD_PRODUTO 	= E.COD_PRODUTO              ';
        v_sql := v_sql || '  AND S.DATA_FISCAL 	= E.DATA_FISCAL_S            ';
        v_sql := v_sql || '  AND S.PROC_ID     	= E.PROC_ID                  ';
        v_sql := v_sql || '  AND E.PROC_ID 	   	= A.PROC_ID (+)              ';
        v_sql := v_sql || '  AND E.COD_PRODUTO 	= A.COD_PRODUTO (+)          ';
        v_sql := v_sql || '  AND E.PROC_ID 		= G.PROC_ID (+)              ';
        v_sql := v_sql || '  AND E.DATA_FISCAL_S = G.DATA_FISCAL_S (+) 		 ';
        v_sql := v_sql || '  AND E.COD_EMPRESA 	= G.COD_EMPRESA (+)          ';
        v_sql := v_sql || '  AND E.COD_ESTAB 	= G.COD_ESTAB (+)            ';
        v_sql := v_sql || '  AND E.DATA_FISCAL 	= G.DATA_FISCAL (+)          ';
        v_sql := v_sql || '  AND E.MOVTO_E_S 	= G.MOVTO_E_S (+)            ';
        v_sql := v_sql || '  AND E.NORM_DEV 	= G.NORM_DEV (+)             ';
        v_sql := v_sql || '  AND E.IDENT_DOCTO 	= G.IDENT_DOCTO (+)          ';
        v_sql := v_sql || '  AND E.IDENT_FIS_JUR = G.IDENT_FIS_JUR (+)       ';
        v_sql := v_sql || '  AND E.NUM_DOCFIS 	= G.NUM_DOCFIS (+)           ';
        v_sql := v_sql || '  AND E.SERIE_DOCFIS = G.SERIE_DOCFIS (+)         ';
        v_sql := v_sql || '  AND E.SUB_SERIE_DOCFIS = G.SUB_SERIE_DOCFIS (+) ';
        v_sql := v_sql || '  AND E.DISCRI_ITEM 	= G.DISCRI_ITEM (+) )        ';

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
                            , vp_data_inicial
                            , vp_data_final
                            , SQLERRM
                            , 'E'
                            , vp_data_hora_ini );
                -----------------------------------------------------------------
                raise_application_error ( -20007
                                        , '!ERRO INSERT DADOS TMP!' );
        END;

        v_sql := 'CREATE UNIQUE INDEX PK_INTERTMP' || vp_proc_id || ' ON ' || vp_tabela_inter_tmp || ' ';
        v_sql := v_sql || '( ';
        v_sql := v_sql || '  COD_EMPRESA    ASC, ';
        v_sql := v_sql || '  COD_ESTAB      ASC, ';
        v_sql := v_sql || '  NUM_DOCFIS     ASC, ';
        v_sql := v_sql || '  NUM_CONTROLE_DOCTO ASC, ';
        v_sql := v_sql || '  DATA_FISCAL    ASC, ';
        v_sql := v_sql || '  SERIE_DOCFIS   ASC, ';
        v_sql := v_sql || '  COD_PRODUTO    ASC, ';
        v_sql := v_sql || '  UF_ORIGEM      ASC, ';
        v_sql := v_sql || '  NUM_ITEM       ASC ';
        v_sql := v_sql || ') ';
        v_sql := v_sql || 'PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX1_INTTMP' || vp_proc_id || ' ON ' || vp_tabela_inter_tmp || ' ';
        v_sql := v_sql || '( ';
        v_sql := v_sql || '  CLASSIFICACAO    ASC, ';
        v_sql := v_sql || '  VLR_ICMS_ANT_RES ASC, ';
        v_sql := v_sql || '  VLR_ICMSST_RET   ASC ) ';
        v_sql := v_sql || 'PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        save_tmp_control ( vp_proc_id
                         , vp_tabela_inter_tmp );
        ---
        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_tabela_inter_tmp );

        loga ( 'TMP REGRAS-INI '
             , FALSE );

        --UPDATE COM REGRAS ESPECIAIS PARA CENARIO 5 ANTECIPAÇÃO-VALIDAÇÃO DE 18/03/2018-INI
        EXECUTE IMMEDIATE
               'UPDATE '
            || vp_tabela_inter_tmp
            || ' SET VLR_ICMSST_RESSARC = (VLR_ICMSST_RET/QUANTIDADE_E)*QUANTIDADE, '
            || ' VLR_ICMS_CALCULADO = ((VLR_BASE_ICMSST_RET*(NVL(ALIQ_INTERNA, 0)/100))-VLR_ICMSST_RET), '
            || ' VLR_ICMS_RESSARC = (((VLR_BASE_ICMSST_RET*(NVL(ALIQ_INTERNA, 0)/100))-VLR_ICMSST_RET)/QUANTIDADE_E)*QUANTIDADE '
            || 'WHERE CLASSIFICACAO = 5 AND VLR_ICMS_ANT_RES = 0 AND VLR_ICMSST_RET <> 0 ';

        COMMIT;

        EXECUTE IMMEDIATE
               'UPDATE '
            || vp_tabela_inter_tmp
            || ' SET VLR_ICMS_RESSARC = 0 '
            || 'WHERE CLASSIFICACAO = 5 AND VLR_ICMS_RESSARC <> 0 AND VLR_ICMSST_RESSARC = 0 AND VLR_ICMS_ANT_RES = 0 AND VLR_ICMSST_RET = 0 AND VLR_BASE_ICMSST_RET = 0 ';

        COMMIT;

        --UPDATE COM REGRAS ESPECIAIS PARA CENARIO 5 ANTECIPAÇÃO-VALIDAÇÃO DE 18/03/2018-FIM

        --UPDATE COM REGRAS ESPECIAIS VALIDAÇÃO DE 16/04/2018-INI
        EXECUTE IMMEDIATE
            'UPDATE ' || vp_tabela_inter_tmp || ' SET VLR_ICMS_CALCULADO = 0 WHERE VLR_ICMS_CALCULADO < 0 ';

        COMMIT;

        EXECUTE IMMEDIATE 'UPDATE ' || vp_tabela_inter_tmp || ' SET VLR_ICMS_RESSARC = 0 WHERE VLR_ICMS_RESSARC < 0 ';

        COMMIT;

        EXECUTE IMMEDIATE
            'UPDATE ' || vp_tabela_inter_tmp || ' SET VLR_ICMSST_RESSARC = 0 WHERE VLR_ICMSST_RESSARC < 0 ';

        COMMIT;

        EXECUTE IMMEDIATE 'UPDATE ' || vp_tabela_inter_tmp || ' SET VLR_ICMS_ANT_RES = 0 WHERE VLR_ICMS_ANT_RES < 0 ';

        COMMIT;

        EXECUTE IMMEDIATE
               'UPDATE '
            || vp_tabela_inter_tmp
            || ' SET VLR_ICMSST_RESSARC = (VLR_ICMS_ST/QUANTIDADE_E)*QUANTIDADE '
            || 'WHERE CLASSIFICACAO = 5 AND VLR_ICMS_ANT_RES = 0 AND VLR_ICMS_ST <> 0 AND VLR_ICMSST_RESSARC = 0 AND VLR_ICMS_ANT_RES = 0 ';

        COMMIT;

        EXECUTE IMMEDIATE
               'UPDATE '
            || vp_tabela_inter_tmp
            || ' SET CLASSIFICACAO = 0 '
            || 'WHERE CLASSIFICACAO = 5 AND VLR_ICMS_RESSARC = 0 AND VLR_ICMSST_RESSARC = 0 AND VLR_ICMS_ANT_RES = 0 ';

        COMMIT;
        --UPDATE COM REGRAS ESPECIAIS VALIDAÇÃO DE 16/04/2018-FIM

        loga ( 'TMP-FIM '
             , FALSE );
    END;

    PROCEDURE insert_res_inter ( vp_proc_id IN NUMBER
                               , vp_tabela_saida IN VARCHAR2
                               , vp_tabela_inter_tmp IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 1000 );
    BEGIN
        --INSERIR LINHAS QUE POSSUEM ULTIMA ENTRADA
        EXECUTE IMMEDIATE
            'INSERT /*+APPEND*/ INTO MSAFI.DPSP_MSAF_RES_INTER (SELECT * FROM ' || vp_tabela_inter_tmp || ' )';

        COMMIT;
        loga ( 'INS-FIM '
             , FALSE );

        --INSERIR SAIDAS QUE NAO ENCONTRARAM ULTIMA ENTRADA
        EXECUTE IMMEDIATE
               'INSERT /*+APPEND*/ INTO MSAFI.DPSP_MSAF_RES_INTER ( '
            || 'SELECT COD_EMPRESA, COD_ESTAB, NUM_DOCFIS, NUM_CONTROLE_DOCTO, NUM_ITEM, COD_PRODUTO, DESCR_ITEM, DATA_FISCAL, UF_ORIGEM, '
            || '       UF_DESTINO, COD_FIS_JUR, CNPJ, RAZAO_SOCIAL, SERIE_DOCFIS, CFOP, FINALIDADE, NBM, NUM_AUTENTIC_NFE, QUANTIDADE, '
            || '       VLR_UNIT, VLR_ITEM, VLR_BASE_ICMS, VLR_ICMS, ALIQ_ICMS, '
            || '       '''', NULL, '''', '''', '''', '''', '''', '''', '''', '''', 0, '''', '''',	'''', '''', '''', 0, 0, 0, '''', NULL, '
            || '       '''', '''', '''', '''', 0, 0, 0, 0, 0, 0, 0, 0, 0, '''', '''', 0, 0, 0, 0, 0, 0, '''
            || musuario
            || ''', SYSDATE '
            || 'FROM '
            || vp_tabela_saida
            || ' S '
            || 'WHERE NOT EXISTS (SELECT ''Y'' '
            || '					FROM '
            || vp_tabela_inter_tmp
            || ' F '
            || '					WHERE S.COD_EMPRESA = F.COD_EMPRESA '
            || '					  AND S.COD_ESTAB = F.COD_ESTAB '
            || '					  AND S.NUM_DOCFIS = F.NUM_DOCFIS '
            || '					  AND S.NUM_CONTROLE_DOCTO = F.NUM_CONTROLE_DOCTO '
            || '					  AND S.DATA_FISCAL = F.DATA_FISCAL '
            || '					  AND S.SERIE_DOCFIS = F.SERIE_DOCFIS '
            || '					  AND S.COD_PRODUTO = F.COD_PRODUTO '
            || '					  AND S.UF_ORIGEM = F.UF_ORIGEM  '
            || '					  AND S.NUM_ITEM = F.NUM_ITEM )) ';

        COMMIT;
        loga ( 'INS2-FIM '
             , FALSE );
    ---DBMS_STATS.GATHER_TABLE_STATS('MSAFI', 'DPSP_MSAF_RES_INTER');

    END;

    PROCEDURE delete_res_inter ( p_i_cod_estab IN VARCHAR2
                               , p_i_data_ini IN DATE
                               , p_i_data_fim IN DATE )
    IS
    BEGIN
        DELETE msafi.dpsp_msaf_res_inter
         WHERE cod_empresa = mcod_empresa
           AND cod_estab = p_i_cod_estab
           AND data_fiscal BETWEEN p_i_data_ini AND p_i_data_fim;

        COMMIT;
        loga ( 'DEL-FIM '
             , FALSE );
    END;

    PROCEDURE delete_temp_tbl ( vp_proc_id IN NUMBER )
    IS
    BEGIN
        FOR temp_table IN ( SELECT table_name
                              FROM msafi.dpsp_msaf_tmp_control
                             WHERE proc_id = vp_proc_id ) LOOP
            BEGIN
                EXECUTE IMMEDIATE 'DROP TABLE ' || temp_table.table_name;
            EXCEPTION
                WHEN OTHERS THEN
                    loga ( temp_table.table_name || ' <'
                         , FALSE );
            END;

            DELETE msafi.dpsp_msaf_tmp_control
             WHERE proc_id = vp_proc_id
               AND table_name = temp_table.table_name;

            COMMIT;
        END LOOP;

        --- checar TMPs de processos interrompidos e dropar
        drop_old_tmp ( vp_proc_id );
    END; --PROCEDURE DELETE_TEMP_TBL

    FUNCTION executar ( p_data_ini DATE
                      , p_data_fim DATE
                      , p_cds lib_proc.vartab )
        RETURN INTEGER
    IS
        mproc_id INTEGER;
        i1 INTEGER;

        v_proc_status NUMBER := 0;

        TYPE a_estabs_t IS TABLE OF VARCHAR2 ( 6 );

        a_estabs a_estabs_t := a_estabs_t ( );

        --TABELAS TEMP
        v_nome_tabela_aliq VARCHAR2 ( 30 );
        v_tab_entrada_c VARCHAR2 ( 30 );
        v_tabela_saida VARCHAR2 ( 30 );
        v_tabela_saida_s VARCHAR2 ( 30 ); ---SINTETICO DA SAIDA PARA GANHO DE PERFORMANCE NAS ULTIMAS ENTRADAS
        v_tabela_xml VARCHAR2 ( 30 );
        v_tabela_class VARCHAR2 ( 30 );
        v_tabela_gare VARCHAR2 ( 30 );
        v_tabela_inter_tmp VARCHAR2 ( 30 );
        v_tabela_xml_dpsp VARCHAR2 ( 30 );
        ---
        v_sql_resultado VARCHAR2 ( 4000 );
        v_sql VARCHAR2 ( 4000 );
        v_insert VARCHAR2 ( 5000 );
        p_proc_instance VARCHAR2 ( 30 );
        v_count_saida NUMBER;
        v_qtde_tmp NUMBER := 0;
        v_data_hora_ini VARCHAR2 ( 20 );

        ------------------------------------------------------------------------------------------------------------------------------------------------------
        --RANGE DE DATAS PARA BUSCAR VENDAS
        v_data_inicial DATE := p_data_ini; -- DATA INICIAL
        v_data_final DATE := p_data_fim; -- DATA FINAL
    ------------------------------------------------------------------------------------------------------------------------------------------------------

    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS='',.'' ';

        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        musuario := lib_parametros.recuperar ( 'USUARIO' );

        mproc_id :=
            lib_proc.new ( 'DPSP_RES_INTER_CPROC'
                         , 48
                         , 150 );
        lib_proc.add_tipo ( mproc_id
                          , 1
                          ,    TO_CHAR ( SYSDATE
                                       , 'YYYYMMDDHH24MISS' )
                            || '_RESSARC_INTER'
                          , 1 );

        --MARCAR INCIO DA EXECUCAO
        v_data_hora_ini :=
            TO_CHAR ( SYSDATE
                    , 'DD/MM/YYYY HH24:MI.SS' );

        lib_proc.add_header ( 'Executar processamento do Ressarcimento INTERESTADUAL'
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

        loga ( '---INI DO PROCESSAMENTO---'
             , FALSE );
        loga ( '<< PERIODO DE: ' || v_data_inicial || ' A ' || v_data_final || ' >>'
             , FALSE );

        ---CHECK TRAVA DE REPROCESSAMENTO
        IF msafi.get_trava_info ( 'INTER'
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

        --PREPARAR CDs
        IF ( p_cds.COUNT > 0 ) THEN
            i1 := p_cds.FIRST;

            WHILE i1 IS NOT NULL LOOP
                a_estabs.EXTEND ( );
                a_estabs ( a_estabs.LAST ) := p_cds ( i1 );
                i1 := p_cds.NEXT ( i1 );
            END LOOP;
        ELSE
            FOR c1 IN ( SELECT cod_estab
                          FROM msafi.dsp_estabelecimento
                         WHERE cod_empresa = mcod_empresa
                           AND tipo = 'C' ) LOOP
                a_estabs.EXTEND ( );
                a_estabs ( a_estabs.LAST ) := c1.cod_estab;
            END LOOP;
        END IF;

        --EXECUTAR UM CD POR VEZ
        FOR est IN a_estabs.FIRST .. a_estabs.COUNT --(1)
                                                   LOOP
            --GERAR CHAVE PROC_ID
            SELECT ROUND ( dbms_random.VALUE ( 10000000000000
                                             , 999999999999999 ) )
              INTO p_proc_instance
              FROM DUAL;

            ---------------------
            loga ( '>> INICIO CD: ' || a_estabs ( est ) || ' PROC INST: ' || p_proc_instance
                 , FALSE );

            --CRIAR TABELA DE SAIDA TMP
            create_tab_saida ( p_proc_instance
                             , v_tabela_saida );
            save_tmp_control ( p_proc_instance
                             , v_tabela_saida );

            --CARREGAR SAIDAS
            load_saidas ( p_proc_instance
                        , a_estabs ( est )
                        , p_data_ini
                        , p_data_fim
                        , v_tabela_saida
                        , v_data_hora_ini );

            --CRIAR INDICES DA TEMP DE SAIDA
            create_tab_saida_idx ( p_proc_instance
                                 , v_tabela_saida
                                 , v_count_saida
                                 , v_tabela_saida_s );

            --CONTINUA APENAS SE ACHAR SAIDAS
            IF ( v_count_saida > 0 ) THEN --(2)
                --CRIAR E CARREGAR TABELAS TEMP PARA ALIQ INTERNA
                load_aliq_interna ( p_proc_instance
                                  , v_nome_tabela_aliq
                                  , v_tabela_saida
                                  , p_data_ini
                                  , p_data_fim
                                  , v_data_hora_ini );

                --CARREGAR DADOS DE ULTIMA ENTRADA--------------------------------------------------
                --CRIAR TABELA TMP DE ENTRADA
                create_tab_entrada_cd ( p_proc_instance
                                      , v_tab_entrada_c );

                --CARREGAR TEMPORARIAS ENTRADA NOS CDs
                load_entradas ( p_proc_instance
                              , a_estabs ( est )
                              , v_tab_entrada_c
                              , v_tabela_saida_s
                              , 2
                              , p_data_ini
                              , p_data_fim
                              , v_data_hora_ini );

                --CRIAR INDICES DA TEMP DE ENTRADA CD
                create_tab_entrada_cd_idx ( p_proc_instance
                                          , v_tab_entrada_c );
                ------------------------------------------------------------------------------------

                -- XML -----------------------------------------------------------------------------
                --CARREGAR TEMP COM XML DA DPSP
                load_dados_xml_dpsp ( p_proc_instance
                                    , v_tabela_xml_dpsp
                                    , v_tab_entrada_c
                                    , p_data_ini
                                    , p_data_fim
                                    , v_data_hora_ini );
                --CARREGAR DADOS DO XML
                load_dados_xml ( p_proc_instance
                               , mcod_empresa
                               , v_tab_entrada_c
                               , v_tabela_xml
                               , v_tabela_xml_dpsp
                               , p_data_ini
                               , p_data_fim
                               , v_data_hora_ini );
                --CARREGAR DADOS DO XML NFs NAO LOCALIZADAS NA ROTINA ANTERIOR
                load_dados_xml_refugo ( p_proc_instance
                                      , mcod_empresa
                                      , v_tab_entrada_c
                                      , v_tabela_xml
                                      , v_tabela_xml_dpsp
                                      , p_data_ini
                                      , p_data_fim
                                      , v_data_hora_ini );
                ------------------------------------------------------------------------------------

                --CARREGAR TABELA PARA CLASSIFICACAO DAS ENTRADAS
                load_tab_class ( p_proc_instance
                               , v_tab_entrada_c
                               , v_tabela_xml
                               , v_tabela_class
                               , p_data_ini
                               , p_data_fim
                               , v_data_hora_ini );

                --CLASSIFICAR LINHAS DAS ENTRADAS
                classif_entradas ( p_proc_instance
                                 , v_tabela_class );

                --BUSCAR NFs GARE DO PEOPLESOFT PARA CENARIO 5
                load_gare ( p_proc_instance
                          , v_tabela_class
                          , v_tabela_gare
                          , p_data_ini
                          , p_data_fim
                          , a_estabs ( est )
                          , v_data_hora_ini );

                --BUSCAR NFs GARE DO PEOPLESOFT PARA CENARIO 0 (ZERO)
                load_gare_refugo ( p_proc_instance
                                 , v_tabela_class
                                 , v_tabela_gare
                                 , p_data_ini
                                 , p_data_fim
                                 , a_estabs ( est )
                                 , v_data_hora_ini );

                --ASSOCIAR SAIDAS COM ENTRADAS
                create_tab_tmp_inter ( p_proc_instance
                                     , v_tabela_saida
                                     , v_tabela_class
                                     , v_nome_tabela_aliq
                                     , v_tabela_gare
                                     , v_tabela_inter_tmp
                                     , p_data_ini
                                     , p_data_fim
                                     , v_data_hora_ini );

                --LIMPAR / INSERIR DADOS NA TABELA DEFINITIVA
                delete_res_inter ( a_estabs ( est )
                                 , p_data_ini
                                 , p_data_fim );
                insert_res_inter ( p_proc_instance
                                 , v_tabela_saida
                                 , v_tabela_inter_tmp );

                SELECT COUNT ( * )
                  INTO v_qtde_tmp
                  FROM msafi.dpsp_msaf_res_inter
                 WHERE cod_empresa = msafi.dpsp.empresa
                   AND cod_estab = a_estabs ( est )
                   AND data_fiscal BETWEEN p_data_ini AND p_data_fim;

                loga ( '::INSERT NA TABELA RES_INTER OK:: LINHAS ' || v_qtde_tmp
                     , FALSE );

                --APAGAR TABELAS TEMPORARIAS
                delete_temp_tbl ( p_proc_instance );
            END IF; --(2)
        END LOOP; --(1)

        --DISPONIBILIZAR PERIODO PROCESSADO PARA TRAVA DE REPROCESSAMENTO
        msafi.add_trava_info ( 'INTER'
                             , TO_CHAR ( v_data_inicial
                                       , 'YYYY/MM' ) );

        loga ( '---FIM DO PROCESSAMENTO [SUCESSO]---'
             , FALSE );
        COMMIT;

        --ENVIAR EMAIL DE SUCESSO----------------------------------------
        envia_email ( mcod_empresa
                    , v_data_inicial
                    , v_data_final
                    , ''
                    , 'S'
                    , v_data_hora_ini );
        -----------------------------------------------------------------

        lib_proc.add ( 'FIM DO PROCESSAMENTO [SUCESSO]' );
        lib_proc.add ( 'Favor verificar LOG para detalhes.' );
        lib_proc.close;
        RETURN mproc_id;
    EXCEPTION
        WHEN OTHERS THEN
            loga ( 'SQLERRM: ' || SQLERRM
                 , FALSE );
            lib_proc.add_log ( 'Erro não tratado: ' || dbms_utility.format_error_backtrace
                             , 1 );
            lib_proc.add_log ( 'SQLERRM: ' || SQLERRM
                             , 1 );
            lib_proc.add ( 'ERRO!' );
            lib_proc.add ( dbms_utility.format_error_backtrace );

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
    END; /* FUNCTION EXECUTAR */
END dpsp_res_inter_cproc;
/
SHOW ERRORS;
