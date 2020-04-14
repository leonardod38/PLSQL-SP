Prompt Package Body DPSP_PMC_X_MVA_NEW_CPROC;
--
-- DPSP_PMC_X_MVA_NEW_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_pmc_x_mva_new_cproc
IS
    mproc_id INTEGER;
    mproc_id_o INTEGER;
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
                           ,    '
                            SELECT A.COD_ESTAB, A.COD_ESTAB || '' - '' || B.COD_ESTADO || '' - '' || A.CGC || '' - '' || INITCAP(A.BAIRRO) || '' / '' || INITCAP(A.CIDADE)
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
                           ,    '
                            SELECT A.COD_ESTAB, A.COD_ESTAB || '' - '' || B.COD_ESTADO || '' - '' || A.CGC || '' - '' || INITCAP(A.BAIRRO) || '' / '' || INITCAP(A.CIDADE)
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
                           ,    '
                            SELECT A.COD_ESTAB, A.COD_ESTAB || '' - '' || B.COD_ESTADO || '' - '' || A.CGC || '' - '' || INITCAP(A.BAIRRO) || '' / '' || INITCAP(A.CIDADE)
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

        lib_proc.add_param ( pstr
                           , 'Procurar por Compra Direta'
                           , --P_COMPRA_DIRETA
                            'VARCHAR2'
                           , 'CHECKBOX'
                           , 'N'
                           , 'N'
                           , NULL );

        lib_proc.add_param (
                             pstr
                           , 'UF'
                           , --P_UF
                            'VARCHAR2'
                           , 'COMBOBOX'
                           , 'S'
                           , '%'
                           , '#########'
                           , 'SELECT A.COD_ESTADO, A.COD_ESTADO FROM ESTADO A UNION ALL SELECT ''%'', ''--TODAS--'' FROM DUAL ORDER BY 1'
        );

        lib_proc.add_param (
                             pstr
                           , 'Filiais'
                           , --P_LOJAS
                            'VARCHAR2'
                           , 'MULTISELECT'
                           , 'S'
                           , NULL
                           , NULL
                           ,    'SELECT A.COD_ESTAB, A.COD_ESTAB || '' - '' || B.COD_ESTADO || '' - '' || A.CGC || '' - '' || INITCAP(A.BAIRRO) || '' / '' || INITCAP(A.CIDADE) FROM ESTABELECIMENTO A, ESTADO B, MSAFI.DSP_ESTABELECIMENTO C WHERE A.COD_EMPRESA  = '''
                             || mcod_empresa
                             || ''' AND B.IDENT_ESTADO = A.IDENT_ESTADO AND A.COD_EMPRESA = C.COD_EMPRESA AND A.COD_ESTAB = C.COD_ESTAB AND B.COD_ESTADO LIKE :12 AND C.TIPO = ''L'' ORDER BY B.COD_ESTADO, A.COD_ESTAB'
        );

        RETURN pstr;
    END; --FUNCTION PARAMETROS RETURN VARCHAR2 IS

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Processar Dados PMC x MVA ACCENTURE';
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
        RETURN 'Processar Carga de Dados para Ressarcimento PMC x MVA';
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
                    , musuario
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

        IF ( vp_tipo = 'E' ) THEN --VP_TIPO = 'E' (ERRO) OU 'S' (SUCESSO)
            v_txt_email := 'ERRO no Processo PMC x MVA!';
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
            v_assunto := 'Mastersaf - Relatorio PMC x MVA apresentou ERRO';
        ---NOTIFICA('', 'S', V_ASSUNTO, V_TXT_EMAIL, 'DPSP_RES_INTER_CPROC');

        ELSE
            v_txt_email := 'Processo PMC x MVA finalizado com SUCESSO.';
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
            v_assunto := 'Mastersaf - Relatorio PMC x MVA Concluido';
        ---NOTIFICA('S', '', V_ASSUNTO, V_TXT_EMAIL, 'DPSP_RES_INTER_CPROC');

        END IF;
    END;

    PROCEDURE create_tab_pmc_mva ( vp_proc_instance IN VARCHAR2
                                 , vp_tabela_pmc_mva   OUT VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 2000 );
    BEGIN
        vp_tabela_pmc_mva := 'DPSP_MSAF_P_' || vp_proc_instance;

        v_sql := 'CREATE TABLE ' || vp_tabela_pmc_mva || ' ( ';
        v_sql := v_sql || 'PROC_ID             NUMBER(30), ';
        v_sql := v_sql || 'COD_EMPRESA         VARCHAR2(3), ';
        v_sql := v_sql || 'COD_ESTAB           VARCHAR2(6), ';
        v_sql := v_sql || 'NUM_DOCFIS          VARCHAR2(12), ';
        v_sql := v_sql || 'DATA_FISCAL         DATE, ';
        v_sql := v_sql || 'SERIE_DOCFIS        VARCHAR2(3), ';
        v_sql := v_sql || 'COD_PRODUTO         VARCHAR2(35), ';
        v_sql := v_sql || 'COD_ESTADO          VARCHAR2(2), ';
        v_sql := v_sql || 'DOCTO               VARCHAR2(5), ';
        v_sql := v_sql || 'NUM_ITEM            NUMBER(5), ';
        v_sql := v_sql || 'DESCR_ITEM          VARCHAR2(50), ';
        v_sql := v_sql || 'QUANTIDADE          NUMBER(12,4), ';
        v_sql := v_sql || 'COD_NBM             VARCHAR2(10), ';
        v_sql := v_sql || 'COD_CFO             VARCHAR2(4), ';
        v_sql := v_sql || 'GRUPO_PRODUTO       VARCHAR2(30), ';
        v_sql := v_sql || 'VLR_DESCONTO        NUMBER(17,2), ';
        v_sql := v_sql || 'VLR_CONTABIL        NUMBER(17,2), ';
        v_sql := v_sql || 'BASE_UNIT_S_VENDA   NUMBER(17,2), ';
        v_sql := v_sql || 'NUM_AUTENTIC_NFE    VARCHAR2(80), ';
        v_sql := v_sql || 'LISTA               VARCHAR2(1), ';
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
        v_sql := v_sql || 'BASE_ICMS_UNIT_E      NUMBER(17,2), ';
        v_sql := v_sql || 'VLR_ICMS_UNIT_E       NUMBER(17,2), ';
        v_sql := v_sql || 'ALIQ_ICMS_E           NUMBER(17,2), ';
        v_sql := v_sql || 'BASE_ST_UNIT_E        NUMBER(17,2), ';
        v_sql := v_sql || 'VLR_ICMS_ST_UNIT_E    NUMBER(17,2), ';
        v_sql := v_sql || 'VLR_ICMS_ST_UNIT_AUX  NUMBER(17,2), ';
        v_sql := v_sql || 'STAT_LIBER_CNTR       VARCHAR2(10)) ';
        v_sql := v_sql || 'PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE UNIQUE INDEX PK_DPSP_P_' || vp_proc_instance || ' ON ' || vp_tabela_pmc_mva || ' ';
        v_sql := v_sql || '  (';
        v_sql := v_sql || '    PROC_ID        ASC,';
        v_sql := v_sql || '    COD_EMPRESA    ASC,';
        v_sql := v_sql || '    COD_ESTAB      ASC,';
        v_sql := v_sql || '    NUM_DOCFIS     ASC,';
        v_sql := v_sql || '    DATA_FISCAL    ASC,';
        v_sql := v_sql || '    SERIE_DOCFIS   ASC,';
        v_sql := v_sql || '    COD_PRODUTO    ASC,';
        v_sql := v_sql || '    COD_ESTADO     ASC,';
        v_sql := v_sql || '    DOCTO          ASC,';
        v_sql := v_sql || '    NUM_ITEM       ASC';
        v_sql := v_sql || '  )';
        v_sql := v_sql || '  PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX1_DPSP_P_' || vp_proc_instance || ' ON ' || vp_tabela_pmc_mva || ' ';
        v_sql := v_sql || '  ( ';
        v_sql := v_sql || '    PROC_ID        ASC ';
        v_sql := v_sql || '  ) ';
        v_sql := v_sql || '  PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        ---
        save_tmp_control ( vp_proc_instance
                         , vp_tabela_pmc_mva );
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
        v_sql := v_sql || 'NUM_DOCFIS          VARCHAR2(12), ';
        v_sql := v_sql || 'DATA_FISCAL         DATE, ';
        v_sql := v_sql || 'SERIE_DOCFIS        VARCHAR2(3), ';
        v_sql := v_sql || 'COD_PRODUTO         VARCHAR2(35), ';
        v_sql := v_sql || 'COD_ESTADO          VARCHAR2(2), ';
        v_sql := v_sql || 'DOCTO               VARCHAR2(5), ';
        v_sql := v_sql || 'NUM_ITEM            NUMBER(5), ';
        v_sql := v_sql || 'DESCR_ITEM          VARCHAR2(50), ';
        v_sql := v_sql || 'QUANTIDADE          NUMBER(12,4), ';
        v_sql := v_sql || 'COD_NBM             VARCHAR2(10), ';
        v_sql := v_sql || 'COD_CFO             VARCHAR2(4), ';
        v_sql := v_sql || 'GRUPO_PRODUTO       VARCHAR2(30), ';
        v_sql := v_sql || 'VLR_DESCONTO        NUMBER(17,2), ';
        v_sql := v_sql || 'VLR_CONTABIL        NUMBER(17,2), ';
        v_sql := v_sql || 'BASE_UNIT_S_VENDA   NUMBER(17,2), ';
        v_sql := v_sql || 'NUM_AUTENTIC_NFE    VARCHAR2(80), ';
        v_sql := v_sql || 'LISTA		       VARCHAR2(1)) ';
        v_sql := v_sql || 'PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;
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
        v_sql := v_sql || ' DATA_FISCAL_S       DATE, ';
        ---
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
        v_qtde NUMBER := 0;
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
        v_sql := v_sql || '    DISCRI_ITEM         ASC, ';
        v_sql := v_sql || '    DATA_FISCAL_S       ASC ';
        v_sql := v_sql || '  ) ';
        v_sql := v_sql || '  PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX1_DPSP_E_C_' || vp_proc_instance || ' ON ' || vp_tab_entrada_cd || ' ';
        v_sql := v_sql || '   ( ';
        v_sql := v_sql || '     PROC_ID     ASC, ';
        v_sql := v_sql || '     COD_EMPRESA ASC, ';
        v_sql := v_sql || '     COD_ESTAB   ASC, ';
        v_sql := v_sql || '     COD_PRODUTO ASC ';
        v_sql := v_sql || '   ) ';
        v_sql := v_sql || '   PCTFREE     10 ';

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

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX3_DPSP_E_C_' || vp_proc_instance || ' ON ' || vp_tab_entrada_cd || ' ';
        v_sql := v_sql || '   ( ';
        v_sql := v_sql || '     PROC_ID     ASC, ';
        v_sql := v_sql || '     COD_EMPRESA ASC, ';
        v_sql := v_sql || '     COD_ESTAB   ASC, ';
        v_sql := v_sql || '     COD_PRODUTO ASC, ';
        v_sql := v_sql || '     DATA_FISCAL_S ASC, ';
        v_sql := v_sql || '     DATA_FISCAL ASC, ';
        v_sql := v_sql || '     NUM_CONTROLE_DOCTO ASC, ';
        v_sql := v_sql || '     NUM_ITEM ASC ';
        v_sql := v_sql || '   ) ';
        v_sql := v_sql || '   PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_tab_entrada_cd );

        EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || vp_tab_entrada_cd            INTO v_qtde;

        loga ( '>>' || vp_tab_entrada_cd || ' CRIADA: ' || v_qtde || ' LINHAS'
             , FALSE );
    END;

    PROCEDURE create_tab_entrada_f ( vp_proc_instance IN NUMBER
                                   , vp_tab_entrada_f   OUT VARCHAR2 )
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
        v_sql := v_sql || ' DATA_FISCAL_S       DATE, ';
        ---
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
                         , vp_tab_entrada_f );
    END;

    PROCEDURE create_tab_entrada_f_idx ( vp_proc_instance IN NUMBER
                                       , vp_tab_entrada_f IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 1000 );
        v_qtde NUMBER := 0;
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
        v_sql := v_sql || '    DISCRI_ITEM         ASC, ';
        v_sql := v_sql || '    DATA_FISCAL_S       ASC ';
        v_sql := v_sql || '  ) ';
        v_sql := v_sql || '  PCTFREE     10 ';

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

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX3_DPSP_E_F_' || vp_proc_instance || ' ON ' || vp_tab_entrada_f || ' ';
        v_sql := v_sql || '   ( ';
        v_sql := v_sql || '     PROC_ID     ASC, ';
        v_sql := v_sql || '     COD_EMPRESA ASC, ';
        v_sql := v_sql || '     COD_ESTAB   ASC, ';
        v_sql := v_sql || '     COD_PRODUTO ASC, ';
        v_sql := v_sql || '     COD_FIS_JUR ASC, ';
        v_sql := v_sql || '     DATA_FISCAL_S ASC, ';
        v_sql := v_sql || '     DATA_FISCAL ASC, ';
        v_sql := v_sql || '     NUM_CONTROLE_DOCTO ASC, ';
        v_sql := v_sql || '     NUM_ITEM ASC ';
        v_sql := v_sql || '   ) ';
        v_sql := v_sql || '   PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX4_DPSP_E_F_' || vp_proc_instance || ' ON ' || vp_tab_entrada_f || ' ';
        v_sql := v_sql || '   ( ';
        v_sql := v_sql || '     COD_ESTAB   ASC, ';
        v_sql := v_sql || '     COD_PRODUTO ASC, ';
        v_sql := v_sql || '     DATA_FISCAL_S ASC ';
        v_sql := v_sql || '   ) ';
        v_sql := v_sql || '   PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_tab_entrada_f );

        EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || vp_tab_entrada_f            INTO v_qtde;

        loga ( '>>' || vp_tab_entrada_f || ' CRIADA: ' || v_qtde || ' LINHAS'
             , FALSE );
    END;

    PROCEDURE create_tab_entrada_co ( vp_proc_instance IN NUMBER
                                    , vp_tab_entrada_co   OUT VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 2000 );
    BEGIN
        ---CRIAR TEMP DE ENTRADA COMPRA DIRETA
        vp_tab_entrada_co := 'DPSP_MSAF_E_CO_' || vp_proc_instance;

        v_sql := 'CREATE TABLE ' || vp_tab_entrada_co || ' ( ';
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
        v_sql := v_sql || ' DATA_FISCAL_S       DATE, ';
        ---
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
                         , vp_tab_entrada_co );
    END;

    PROCEDURE create_tab_entrada_co_idx ( vp_proc_instance IN NUMBER
                                        , vp_tab_entrada_co IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 1000 );
        v_qtde NUMBER;
    BEGIN
        v_sql := 'CREATE UNIQUE INDEX PK_DPSP_E_CO_' || vp_proc_instance || ' ON ' || vp_tab_entrada_co || ' ';
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || '    PROC_ID          ASC, ';
        v_sql := v_sql || '    COD_EMPRESA      ASC, ';
        v_sql := v_sql || '    COD_ESTAB        ASC, ';
        v_sql := v_sql || '    DATA_FISCAL      ASC, ';
        v_sql := v_sql || '    MOVTO_E_S        ASC, ';
        v_sql := v_sql || '    NORM_DEV         ASC, ';
        v_sql := v_sql || '    IDENT_DOCTO      ASC, ';
        v_sql := v_sql || '    IDENT_FIS_JUR    ASC, ';
        v_sql := v_sql || '    NUM_DOCFIS       ASC, ';
        v_sql := v_sql || '    SERIE_DOCFIS     ASC, ';
        v_sql := v_sql || '    SUB_SERIE_DOCFIS ASC, ';
        v_sql := v_sql || '    DISCRI_ITEM      ASC, ';
        v_sql := v_sql || '    DATA_FISCAL_S    ASC ';
        v_sql := v_sql || '  ) ';
        v_sql := v_sql || '  PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX1_DPSP_E_CO_' || vp_proc_instance || ' ON ' || vp_tab_entrada_co || ' ';
        v_sql := v_sql || '   ( ';
        v_sql := v_sql || '     PROC_ID      ASC, ';
        v_sql := v_sql || '     COD_EMPRESA  ASC, ';
        v_sql := v_sql || '     COD_ESTAB    ASC, ';
        v_sql := v_sql || '     COD_CFO ASC, ';
        v_sql := v_sql || '     CPF_CGC ASC, ';
        v_sql := v_sql || '     NUM_CONTROLE_DOCTO ASC ';
        v_sql := v_sql || '   ) ';
        v_sql := v_sql || '   PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX2_DPSP_E_CO_' || vp_proc_instance || ' ON ' || vp_tab_entrada_co || ' ';
        v_sql := v_sql || '   ( ';
        v_sql := v_sql || '     PROC_ID     ASC, ';
        v_sql := v_sql || '     COD_EMPRESA ASC, ';
        v_sql := v_sql || '     COD_ESTAB   ASC, ';
        v_sql := v_sql || '     COD_PRODUTO ASC ';
        v_sql := v_sql || '   ) ';
        v_sql := v_sql || '   PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX3_DPSP_E_CO_' || vp_proc_instance || ' ON ' || vp_tab_entrada_co || ' ';
        v_sql := v_sql || '   ( ';
        v_sql := v_sql || '     PROC_ID     ASC, ';
        v_sql := v_sql || '     COD_EMPRESA ASC, ';
        v_sql := v_sql || '     COD_ESTAB   ASC, ';
        v_sql := v_sql || '     COD_PRODUTO ASC, ';
        v_sql := v_sql || '     NUM_CONTROLE_DOCTO ASC, ';
        v_sql := v_sql || '     NUM_ITEM ASC ';
        v_sql := v_sql || '   ) ';
        v_sql := v_sql || '   PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_tab_entrada_co );

        EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || vp_tab_entrada_co            INTO v_qtde;

        loga ( '>>' || vp_tab_entrada_co || ' CRIADA: ' || v_qtde || ' LINHAS'
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
            --CARREGAR INFORMACOES DE VENDAS
            v_sql := 'INSERT /*+APPEND*/ INTO ' || vp_tabela_saida || ' ( ';
            v_sql := v_sql || ' SELECT  ''' || vp_proc_instance || ''', ';
            v_sql := v_sql || ' ''' || mcod_empresa || ''', ';
            v_sql := v_sql || ' A.NUMERO_ESTAB, ';
            v_sql := v_sql || ' A.NUMERO_CF, ';
            v_sql := v_sql || ' A.DATA_FISCAL_CF, ';
            v_sql := v_sql || ' A.EQUIPAMENTO, ';
            v_sql := v_sql || ' A.COD_ITEM, ';
            v_sql := v_sql || ' A.UF_ESTAB, ';
            v_sql := v_sql || ' A.DOCTO, ';
            v_sql := v_sql || ' A.NUM_ITEM, ';
            v_sql := v_sql || ' A.DESCR_ITEM, ';
            v_sql := v_sql || ' A.QTD_VENDIDA, ';
            v_sql := v_sql || ' A.NCM, ';
            v_sql := v_sql || ' A.CFOP, ';
            v_sql := v_sql || ' A.GRUPO_PRD, ';
            v_sql := v_sql || ' A.VLR_DESCONTO, ';
            v_sql := v_sql || ' A.VALOR_CONTAB, ';
            v_sql := v_sql || ' TRUNC(A.VALOR_CONTAB/A.QTD_VENDIDA, 2) AS BASE_UNIT_S_VENDA, ';
            v_sql := v_sql || ' A.CHAVE_ACESSO, ';
            v_sql := v_sql || ' A.LISTA ';
            v_sql := v_sql || ' FROM (  ';
            v_sql := v_sql || '     SELECT /*+ORDERED ';
            v_sql := v_sql || '               STAR(ITEM) ';
            v_sql := v_sql || '               PARALLEL(ITEM, 6)*/ ';
            v_sql := v_sql || '            DOC.COD_ESTAB            NUMERO_ESTAB,  ';
            v_sql := v_sql || '            UFEST.COD_ESTADO         UF_ESTAB,  ';
            v_sql := v_sql || '            TIP.COD_DOCTO            DOCTO, ';
            v_sql := v_sql || '            PRD.COD_PRODUTO          COD_ITEM, ';
            v_sql := v_sql || '            ITEM.NUM_ITEM            NUM_ITEM, ';
            v_sql := v_sql || '            PRD.DESCRICAO            DESCR_ITEM, ';
            v_sql := v_sql || '            DOC.NUM_DOCFIS           NUMERO_CF, ';
            v_sql := v_sql || '            DOC.DATA_FISCAL          DATA_FISCAL_CF, ';
            v_sql := v_sql || '            DOC.SERIE_DOCFIS         EQUIPAMENTO, ';
            v_sql := v_sql || '            SUM(ITEM.QUANTIDADE)     QTD_VENDIDA, ';
            v_sql := v_sql || '            NCM.COD_NBM              NCM, ';
            v_sql := v_sql || '            CFOP.COD_CFO             CFOP, ';
            v_sql := v_sql || '            GRP.DESCRICAO            GRUPO_PRD, ';
            v_sql := v_sql || '            SUM(ITEM.VLR_DESCONTO)    VLR_DESCONTO, ';
            v_sql := v_sql || '            SUM(ITEM.VLR_CONTAB_ITEM) VALOR_CONTAB, ';
            v_sql := v_sql || '            '''' || DOC.NUM_AUTENTIC_NFE CHAVE_ACESSO, ';
            v_sql := v_sql || '            '' ''				LISTA ';
            v_sql := v_sql || '     FROM MSAF.X08_ITENS_MERC    ITEM, ';
            v_sql := v_sql || '          MSAF.X07_DOCTO_FISCAL  DOC, ';
            v_sql := v_sql || '          MSAF.X2013_PRODUTO     PRD, ';
            v_sql := v_sql || '          MSAF.ESTABELECIMENTO   EST, ';
            v_sql := v_sql || '          MSAF.ESTADO            UFEST, ';
            v_sql := v_sql || '          MSAF.X2043_COD_NBM     NCM, ';
            v_sql := v_sql || '          MSAF.X2012_COD_FISCAL  CFOP, ';
            v_sql := v_sql || '          MSAF.GRUPO_PRODUTO     GRP, ';
            v_sql := v_sql || '          MSAF.X2005_TIPO_DOCTO  TIP ';
            v_sql := v_sql || '     WHERE   ITEM.COD_EMPRESA        = ''' || mcod_empresa || ''' ';
            v_sql := v_sql || '       AND   ITEM.COD_ESTAB          = ''' || vp_cod_estab || ''' ';
            v_sql :=
                v_sql || '       AND   ITEM.DATA_FISCAL        = TO_DATE(''' || cd.data_normal || ''',''DD/MM/YYYY'') ';
            v_sql :=
                   v_sql
                || '       AND   ITEM.IDENT_DOCTO IN (SELECT IDENT_DOCTO FROM MSAF.X2005_TIPO_DOCTO WHERE COD_DOCTO IN (''CF-E'',''SAT'')) ';
            --
            v_sql := v_sql || '       AND   DOC.COD_EMPRESA         = EST.COD_EMPRESA ';
            v_sql := v_sql || '       AND   DOC.COD_ESTAB           = EST.COD_ESTAB ';
            v_sql := v_sql || '       AND   EST.IDENT_ESTADO        = UFEST.IDENT_ESTADO ';
            v_sql := v_sql || '       AND   ITEM.IDENT_PRODUTO      = PRD.IDENT_PRODUTO ';
            v_sql := v_sql || '       AND   PRD.IDENT_NBM           = NCM.IDENT_NBM ';
            v_sql := v_sql || '       AND   ITEM.IDENT_CFO          = CFOP.IDENT_CFO ';
            v_sql := v_sql || '       AND   PRD.IDENT_GRUPO_PROD    = GRP.IDENT_GRUPO_PROD ';
            v_sql := v_sql || '       AND   DOC.IDENT_DOCTO         = TIP.IDENT_DOCTO ';
            v_sql := v_sql || '       AND   CFOP.COD_CFO            = ''5405'' ';
            v_sql := v_sql || '       AND   DOC.SITUACAO           <> ''S'' ';
            --
            v_sql := v_sql || '       AND   ITEM.COD_EMPRESA       = DOC.COD_EMPRESA ';
            v_sql := v_sql || '       AND   ITEM.COD_ESTAB         = DOC.COD_ESTAB ';
            v_sql := v_sql || '       AND   ITEM.DATA_FISCAL       = DOC.DATA_FISCAL ';
            v_sql := v_sql || '       AND   ITEM.MOVTO_E_S         = DOC.MOVTO_E_S ';
            v_sql := v_sql || '       AND   ITEM.NORM_DEV          = DOC.NORM_DEV ';
            v_sql := v_sql || '       AND   ITEM.IDENT_DOCTO       = DOC.IDENT_DOCTO ';
            v_sql := v_sql || '       AND   ITEM.IDENT_FIS_JUR     = DOC.IDENT_FIS_JUR ';
            v_sql := v_sql || '       AND   ITEM.NUM_DOCFIS        = DOC.NUM_DOCFIS ';
            v_sql := v_sql || '       AND   ITEM.SERIE_DOCFIS      = DOC.SERIE_DOCFIS ';
            v_sql := v_sql || '       AND   ITEM.SUB_SERIE_DOCFIS  = DOC.SUB_SERIE_DOCFIS ';
            ---
            v_sql := v_sql || '     GROUP BY DOC.COD_ESTAB , ';
            v_sql := v_sql || '           UFEST.COD_ESTADO , ';
            v_sql := v_sql || '           PRD.COD_PRODUTO  , ';
            v_sql := v_sql || '           ITEM.NUM_ITEM    , ';
            v_sql := v_sql || '           PRD.DESCRICAO    , ';
            v_sql := v_sql || '           DOC.NUM_DOCFIS   , ';
            v_sql := v_sql || '           DOC.DATA_FISCAL  , ';
            v_sql := v_sql || '           DOC.SERIE_DOCFIS , ';
            v_sql := v_sql || '           NCM.COD_NBM      , ';
            v_sql := v_sql || '           CFOP.COD_CFO     , ';
            v_sql := v_sql || '           GRP.DESCRICAO    , ';
            v_sql := v_sql || '           TIP.COD_DOCTO    , ';
            v_sql := v_sql || '           '''' || DOC.NUM_AUTENTIC_NFE ';
            v_sql := v_sql || '     UNION ALL ';
            v_sql := v_sql || '     SELECT X993.COD_ESTAB           NUMERO_ESTAB, ';
            v_sql := v_sql || '            UF_EST.COD_ESTADO        UF_ESTAB, ';
            v_sql := v_sql || '            ''ECF''                  DOCTO, ';
            v_sql := v_sql || '            X2013.COD_PRODUTO        COD_ITEM, ';
            v_sql := v_sql || '            X994.NUM_ITEM            NUM_ITEM, ';
            v_sql := v_sql || '            X2013.DESCRICAO          DESCR_ITEM, ';
            v_sql := v_sql || '            X993.NUM_COO             NUMERO_CF, ';
            v_sql := v_sql || '            X993.DATA_EMISSAO        DATA_FISCAL_CF, ';
            v_sql := v_sql || '            X2087.COD_CAIXA_ECF      EQUIPAMENTO, ';
            v_sql := v_sql || '            SUM(X994.QTDE)           QTD_VENDIDA, ';
            v_sql := v_sql || '            NCM.COD_NBM              NCM, ';
            v_sql := v_sql || '            X2012.COD_CFO            CFOP, ';
            v_sql := v_sql || '            GRP.DESCRICAO            GRUPO_PRD, ';
            v_sql := v_sql || '            SUM(X994.VLR_DESC)       VLR_DESCONTO, ';
            v_sql := v_sql || '            SUM(X994.VLR_LIQ_ITEM)   VALOR_CONTAB, ';
            v_sql := v_sql || '            ''-''                    CHAVE_ACESSO, ';
            v_sql := v_sql || '            '' ''                    LISTA ';
            v_sql := v_sql || '     FROM MSAF.X993_CAPA_CUPOM_ECF   X993 ';
            v_sql := v_sql || '         ,MSAF.X994_ITEM_CUPOM_ECF   X994 ';
            v_sql := v_sql || '         ,MSAF.X2087_EQUIPAMENTO_ECF X2087 ';
            v_sql := v_sql || '         ,MSAF.ESTABELECIMENTO       EST ';
            v_sql := v_sql || '         ,MSAF.ESTADO                UF_EST ';
            v_sql := v_sql || '         ,MSAF.X2013_PRODUTO         X2013 ';
            v_sql := v_sql || '         ,MSAF.X2012_COD_FISCAL      X2012 ';
            v_sql := v_sql || '         ,MSAF.X2043_COD_NBM         NCM ';
            v_sql := v_sql || '         ,MSAF.GRUPO_PRODUTO         GRP ';
            v_sql := v_sql || '     WHERE   X993.COD_EMPRESA        = ''' || mcod_empresa || ''' ';
            v_sql := v_sql || '       AND   X993.COD_ESTAB          = ''' || vp_cod_estab || ''' ';
            v_sql :=
                v_sql || '       AND   X993.DATA_EMISSAO       = TO_DATE(''' || cd.data_normal || ''',''DD/MM/YYYY'') ';
            v_sql := v_sql || '       AND   X993.IND_SITUACAO_CUPOM = ''1'' ';
            v_sql := v_sql || '       AND   X2087.COD_EMPRESA       = X993.COD_EMPRESA ';
            v_sql := v_sql || '       AND   X2087.COD_ESTAB         = X993.COD_ESTAB ';
            v_sql := v_sql || '       AND   X2087.IDENT_CAIXA_ECF   = X993.IDENT_CAIXA_ECF ';
            v_sql := v_sql || '       AND   X994.COD_EMPRESA        = X993.COD_EMPRESA ';
            v_sql := v_sql || '       AND   X994.COD_ESTAB          = X993.COD_ESTAB ';
            v_sql := v_sql || '       AND   X994.IDENT_CAIXA_ECF    = X993.IDENT_CAIXA_ECF ';
            v_sql := v_sql || '       AND   X994.NUM_COO            = X993.NUM_COO ';
            v_sql := v_sql || '       AND   X994.DATA_EMISSAO       = X993.DATA_EMISSAO ';
            v_sql := v_sql || '       AND   X2013.IDENT_PRODUTO     = X994.IDENT_PRODUTO ';
            v_sql := v_sql || '       AND   X2012.IDENT_CFO         = X994.IDENT_CFO ';
            v_sql := v_sql || '       AND   EST.COD_EMPRESA         = X993.COD_EMPRESA ';
            v_sql := v_sql || '       AND   EST.COD_ESTAB           = X993.COD_ESTAB ';
            v_sql := v_sql || '       AND   X2013.IDENT_NBM         = NCM.IDENT_NBM ';
            v_sql := v_sql || '       AND   X2013.IDENT_GRUPO_PROD  = GRP.IDENT_GRUPO_PROD ';
            v_sql := v_sql || '       AND   EST.IDENT_ESTADO        = UF_EST.IDENT_ESTADO ';
            v_sql := v_sql || '       AND   X994.IND_SITUACAO_ITEM  = ''1'' ';
            v_sql := v_sql || '       AND   X2012.COD_CFO           = ''5405'' ';
            v_sql := v_sql || '     GROUP BY  ';
            v_sql := v_sql || '         X993.COD_ESTAB      , ';
            v_sql := v_sql || '         UF_EST.COD_ESTADO   , ';
            v_sql := v_sql || '         X2013.COD_PRODUTO   , ';
            v_sql := v_sql || '         X994.NUM_ITEM       , ';
            v_sql := v_sql || '         X2013.DESCRICAO     , ';
            v_sql := v_sql || '         X993.NUM_COO        , ';
            v_sql := v_sql || '         X993.DATA_EMISSAO   , ';
            v_sql := v_sql || '         X2087.COD_CAIXA_ECF , ';
            v_sql := v_sql || '         NCM.COD_NBM         , ';
            v_sql := v_sql || '         X2012.COD_CFO       , ';
            v_sql := v_sql || '         GRP.DESCRICAO       , ';
            v_sql := v_sql || '         ''ECF''         ) A ) ';

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
                                   , vp_tabela_saida_s1   OUT VARCHAR2
                                   , vp_tabela_saida_s2   OUT VARCHAR2
                                   , vp_qtde_saida_s1   OUT NUMBER
                                   , vp_qtde_saida_s2   OUT NUMBER )
    IS
        v_sql VARCHAR2 ( 1000 );
        vp_count_saida NUMBER := 0;
    BEGIN
        v_sql := 'CREATE UNIQUE INDEX PK_DPSP_S_' || vp_proc_instance || ' ON ' || vp_tabela_saida || ' ';
        v_sql := v_sql || '( ';
        v_sql := v_sql || '  PROC_ID        ASC, ';
        v_sql := v_sql || '  COD_EMPRESA    ASC, ';
        v_sql := v_sql || '  COD_ESTAB      ASC, ';
        v_sql := v_sql || '  NUM_DOCFIS     ASC, ';
        v_sql := v_sql || '  DATA_FISCAL    ASC, ';
        v_sql := v_sql || '  SERIE_DOCFIS   ASC, ';
        v_sql := v_sql || '  COD_PRODUTO    ASC, ';
        v_sql := v_sql || '  COD_ESTADO     ASC, ';
        v_sql := v_sql || '  DOCTO          ASC, ';
        v_sql := v_sql || '  NUM_ITEM       ASC ';
        v_sql := v_sql || ') ';
        v_sql := v_sql || 'PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX1_DPSP_S_' || vp_proc_instance || ' ON ' || vp_tabela_saida || ' ';
        v_sql := v_sql || '  ( ';
        v_sql := v_sql || '    PROC_ID      ASC ';
        v_sql := v_sql || '  ) ';
        v_sql := v_sql || '  PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX2_DPSP_S_' || vp_proc_instance || ' ON ' || vp_tabela_saida || ' ';
        v_sql := v_sql || '  ( ';
        v_sql := v_sql || '    PROC_ID      ASC, ';
        v_sql := v_sql || '    DATA_FISCAL ASC ';
        v_sql := v_sql || '  ) ';
        v_sql := v_sql || '  PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX3_DPSP_S_' || vp_proc_instance || ' ON ' || vp_tabela_saida || ' ';
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || '    PROC_ID      ASC, ';
        v_sql := v_sql || '    COD_ESTAB   ASC, ';
        v_sql := v_sql || '    COD_PRODUTO ASC ';
        v_sql := v_sql || '  ) ';
        v_sql := v_sql || '  PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX4_DPSP_S_' || vp_proc_instance || ' ON ' || vp_tabela_saida || ' ';
        v_sql := v_sql || '  ( ';
        v_sql := v_sql || '    PROC_ID      ASC, ';
        v_sql := v_sql || '    COD_ESTAB   ASC ';
        v_sql := v_sql || '  ) ';
        v_sql := v_sql || '  PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX5_DPSP_S_' || vp_proc_instance || ' ON ' || vp_tabela_saida || ' ';
        v_sql := v_sql || '  ( ';
        v_sql := v_sql || '    PROC_ID      ASC, ';
        v_sql := v_sql || '    DATA_FISCAL ASC, ';
        v_sql := v_sql || '    COD_ESTAB   ASC ';
        v_sql := v_sql || '  ) ';
        v_sql := v_sql || '  PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX6_DPSP_S_' || vp_proc_instance || ' ON ' || vp_tabela_saida || ' ';
        v_sql := v_sql || '  ( ';
        v_sql := v_sql || '    PROC_ID      ASC, ';
        v_sql := v_sql || '    COD_PRODUTO ASC ';
        v_sql := v_sql || '  ) ';
        v_sql := v_sql || '  PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX7_DPSP_S_' || vp_proc_instance || ' ON ' || vp_tabela_saida || ' ';
        v_sql := v_sql || '  ( ';
        v_sql := v_sql || '    PROC_ID      ASC, ';
        v_sql := v_sql || '    COD_EMPRESA ASC, ';
        v_sql := v_sql || '    COD_ESTAB   ASC, ';
        v_sql := v_sql || '    DATA_FISCAL ASC, ';
        v_sql := v_sql || '    COD_PRODUTO ASC ';
        v_sql := v_sql || '  ) ';
        v_sql := v_sql || '  PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX8_DPSP_S_' || vp_proc_instance || ' ON ' || vp_tabela_saida || ' ';
        v_sql := v_sql || '  ( ';
        v_sql := v_sql || '    PROC_ID      ASC, ';
        v_sql := v_sql || '    COD_EMPRESA ASC, ';
        v_sql := v_sql || '    COD_ESTAB   ASC, ';
        v_sql := v_sql || '    DATA_FISCAL ASC ';
        v_sql := v_sql || '  ) ';
        v_sql := v_sql || '  PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_tabela_saida );

        v_sql := 'SELECT COUNT(*) QTDE_SAIDA ';
        v_sql := v_sql || 'FROM ' || vp_tabela_saida || ' ';
        vp_count_saida := 0;

        EXECUTE IMMEDIATE v_sql            INTO vp_count_saida;

        loga ( '>>' || vp_tabela_saida || ' CRIADA: ' || vp_count_saida || ' LINHAS'
             , FALSE );

        -------------------------------------------------------------------------
        ---CRIAR TABELA SINTETICA DA SAIDA SEM COD_ESTAB-------------------------
        ---USAR PARA ULTIMA ENTRADA NO CD----------------------------------------
        -------------------------------------------------------------------------

        vp_tabela_saida_s1 := 'DPSP_SAIDA1_' || vp_proc_instance;

        v_sql := 'CREATE TABLE ' || vp_tabela_saida_s1 || ' ( ';
        v_sql := v_sql || ' COD_PRODUTO   VARCHAR2(35), ';
        v_sql := v_sql || ' DATA_FISCAL_S DATE ) ';
        v_sql := v_sql || ' PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        save_tmp_control ( vp_proc_instance
                         , vp_tabela_saida_s1 );

        EXECUTE IMMEDIATE
               'INSERT /*+APPEND*/ INTO '
            || vp_tabela_saida_s1
            || ' SELECT DISTINCT COD_PRODUTO, DATA_FISCAL FROM '
            || vp_tabela_saida;

        COMMIT;

        v_sql := 'CREATE UNIQUE INDEX PK_INTERSS_' || vp_proc_instance || ' ON ' || vp_tabela_saida_s1 || ' ';
        v_sql := v_sql || '( ';
        v_sql := v_sql || '  COD_PRODUTO   ASC, ';
        v_sql := v_sql || '  DATA_FISCAL_S ASC ) ';
        v_sql := v_sql || 'PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_tabela_saida_s1 );

        v_sql := 'SELECT COUNT(*) QTDE_SAIDA ';
        v_sql := v_sql || 'FROM ' || vp_tabela_saida_s1 || ' ';
        vp_count_saida := 0;

        EXECUTE IMMEDIATE v_sql            INTO vp_qtde_saida_s1;

        loga ( vp_tabela_saida_s1 || ' CRIADA ' || vp_qtde_saida_s1 || ' LINHAS'
             , FALSE );

        -------------------------------------------------------------------------
        ---CRIAR TABELA SINTETICA DA SAIDA COM COD_ESTAB-------------------------
        ---USAR PARA ULTIMA ENTRADA NA FILIAL E COMPRA DIRETA--------------------
        -------------------------------------------------------------------------

        vp_tabela_saida_s2 := 'DPSP_SAIDA2_' || vp_proc_instance;

        v_sql := 'CREATE TABLE ' || vp_tabela_saida_s2 || ' ( ';
        v_sql := v_sql || ' COD_ESTAB     VARCHAR2(6), ';
        v_sql := v_sql || ' COD_PRODUTO   VARCHAR2(35), ';
        v_sql := v_sql || ' DATA_FISCAL_S DATE ) ';
        v_sql := v_sql || ' PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        save_tmp_control ( vp_proc_instance
                         , vp_tabela_saida_s2 );

        EXECUTE IMMEDIATE
               'INSERT /*+APPEND*/ INTO '
            || vp_tabela_saida_s2
            || ' SELECT DISTINCT COD_ESTAB, COD_PRODUTO, DATA_FISCAL FROM '
            || vp_tabela_saida;

        COMMIT;

        v_sql := 'CREATE UNIQUE INDEX PK_INTERSS2_' || vp_proc_instance || ' ON ' || vp_tabela_saida_s2 || ' ';
        v_sql := v_sql || '( ';
        v_sql := v_sql || '  COD_ESTAB   ASC, ';
        v_sql := v_sql || '  COD_PRODUTO ASC, ';
        v_sql := v_sql || '  DATA_FISCAL_S ASC ) ';
        v_sql := v_sql || 'PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_tabela_saida_s2 );

        v_sql := 'SELECT COUNT(*) QTDE_SAIDA ';
        v_sql := v_sql || 'FROM ' || vp_tabela_saida_s2 || ' ';
        vp_count_saida := 0;

        EXECUTE IMMEDIATE v_sql            INTO vp_qtde_saida_s2;

        loga ( vp_tabela_saida_s2 || ' CRIADA ' || vp_qtde_saida_s2 || ' LINHAS'
             , FALSE );
    END;

    PROCEDURE load_entradas ( vp_proc_instance IN VARCHAR2
                            , vp_cod_estab IN VARCHAR2
                            , vp_dt_final IN DATE
                            , vp_origem IN VARCHAR2
                            , vp_tabela_entrada IN VARCHAR2
                            , vp_tabela_saida IN VARCHAR2
                            , vp_data_hora_ini IN VARCHAR2
                            , vp_dt_ini IN DATE
                            , vp_cd IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 6000 );
        c_entrada SYS_REFCURSOR;
        v_insert VARCHAR2 ( 3000 );

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
          , data_fiscal_s DATE
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
        errors NUMBER;
        dml_errors EXCEPTION;
        vp_maior_data_fiscal_s DATE;
        vp_dt_final_calculado DATE; -- incluido
    BEGIN
        -- incluido inicio
        v_sql := 'SELECT MAX(DATA_FISCAL_S) DATA_FISCAL_S ';
        v_sql := v_sql || 'FROM ' || vp_tabela_saida || ' ';
        vp_maior_data_fiscal_s := NULL;

        EXECUTE IMMEDIATE v_sql            INTO vp_maior_data_fiscal_s;

        vp_dt_final_calculado := TRUNC ( vp_dt_final ) - ( 365 * 2 );

        -- incluido fim

        IF ( vp_origem = 'C' ) THEN --CD
            v_sql := v_sql || 'SELECT /*+PARALLEL(8)*/ DISTINCT ''' || vp_proc_instance || ''', ';
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
            v_sql := v_sql || ' A.DATA_FISCAL_S, ';
            ---
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
            v_sql := v_sql || '     SELECT  /*+INDEX(D PK_X2013_PRODUTO) ';
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
            v_sql := v_sql || '              P.DATA_FISCAL_S, ';
            ---
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
            v_sql := v_sql || '              RANK() OVER( ';
            v_sql := v_sql || '                           PARTITION BY X08.COD_ESTAB, D.COD_PRODUTO, P.DATA_FISCAL_S ';
            v_sql :=
                   v_sql
                || '                           ORDER BY X08.DATA_FISCAL DESC, X07.DATA_EMISSAO DESC, X08.NUM_DOCFIS DESC, X08.DISCRI_ITEM DESC) RANK ';
            v_sql := v_sql || '        FROM X08_ITENS_MERC X08, ';
            v_sql := v_sql || '             X07_DOCTO_FISCAL X07, ';
            v_sql := v_sql || '             X2013_PRODUTO D, ';
            v_sql := v_sql || '             X04_PESSOA_FIS_JUR G, ';
            v_sql := v_sql || '             ' || vp_tabela_saida || ' P, ';
            v_sql := v_sql || '             X2043_COD_NBM A, ';
            v_sql := v_sql || '             X2012_COD_FISCAL B, ';
            v_sql := v_sql || '             X2006_NATUREZA_OP C, ';
            v_sql := v_sql || '             Y2026_SIT_TRB_UF_B E, ';
            v_sql := v_sql || '             ESTADO H  ';

            v_sql := v_sql || '        WHERE X08.IDENT_NBM          = A.IDENT_NBM ';
            v_sql := v_sql || '          AND X08.IDENT_CFO          = B.IDENT_CFO ';
            v_sql :=
                   v_sql
                || '          AND B.COD_CFO             IN (''1102'',''2102'',''1403'',''2403'',''1910'',''2910'') ';
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
            v_sql := v_sql || '          AND D.COD_PRODUTO          = P.COD_PRODUTO ';
            -- alterado
            --V_SQL := V_SQL || '          AND X08.DATA_FISCAL        >= TO_DATE(''' || TO_CHAR(VP_DT_FINAL,'DD/MM/YYYY') || ''',''DD/MM/YYYY'') - (365*2) '; --ULTIMOS 2 ANOS
            v_sql :=
                   v_sql
                || '          AND X08.DATA_FISCAL        >= TO_DATE('''
                || TO_CHAR ( vp_dt_final_calculado
                           , 'DD/MM/YYYY' )
                || ''',''DD/MM/YYYY'') '; --ULTIMOS 2 ANOS
            v_sql := v_sql || '          AND X08.DATA_FISCAL        < P.DATA_FISCAL_S ';
            -- incluido inicio
            v_sql :=
                   v_sql
                || '          AND X08.DATA_FISCAL        < '
                || ' TO_DATE('''
                || TO_CHAR ( vp_maior_data_fiscal_s
                           , 'YYYYMMDD' )
                || ''',''YYYYMMDD'')';
            v_sql :=
                   v_sql
                || '          AND X07.DATA_FISCAL        < '
                || ' TO_DATE('''
                || TO_CHAR ( vp_maior_data_fiscal_s
                           , 'YYYYMMDD' )
                || ''',''YYYYMMDD'')';
            v_sql :=
                   v_sql
                || '          AND X07.DATA_FISCAL        >= TO_DATE('''
                || TO_CHAR ( vp_dt_final_calculado
                           , 'DD/MM/YYYY' )
                || ''',''DD/MM/YYYY'')  '; --ULTIMOS 2 ANOS
            v_sql := v_sql || '          AND X07.DATA_FISCAL        < P.DATA_FISCAL_S ';
            -- incluido fim
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
                                , vp_dt_ini
                                , vp_dt_final
                                , SQLERRM
                                , 'E'
                                , vp_data_hora_ini );
                    -----------------------------------------------------------------
                    raise_application_error ( -20004
                                            , '!ERRO SELECT ENTRADA CD!' );
            END;

            LOOP
                FETCH c_entrada
                    BULK COLLECT INTO tab_e
                    LIMIT 100;

                BEGIN
                    FORALL i IN tab_e.FIRST .. tab_e.LAST
                        EXECUTE IMMEDIATE
                               'INSERT /*+APPEND_VALUES*/ INTO '
                            || vp_tabela_entrada
                            || ' VALUES (:1, :2, :3, :4, :5, :6, :7, :8, :9, '
                            || ' :10, :11, :12, :13, :14, :15, :16, :17, :18, :19, :20, :21, :22, :23, :24, :25, '
                            || ' :26, :27, :28) '
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
                                , tab_e ( i ).data_fiscal_s
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
                                , tab_e ( i ).cod_situacao_b
                                , tab_e ( i ).data_emissao
                                , tab_e ( i ).cod_estado
                                , tab_e ( i ).num_controle_docto
                                , tab_e ( i ).num_autentic_nfe;
                EXCEPTION
                    WHEN OTHERS THEN
                        loga ( 'SQLERRM: ' || SQLERRM
                             , FALSE );
                        --ENVIAR EMAIL DE ERRO-------------------------------------------
                        envia_email ( mcod_empresa
                                    , vp_dt_ini
                                    , vp_dt_final
                                    , SQLERRM
                                    , 'E'
                                    , vp_data_hora_ini );
                        -----------------------------------------------------------------
                        raise_application_error ( -20004
                                                , '!ERRO INSERT ENTRADA CD!' );
                END;

                COMMIT;
                tab_e.delete;

                EXIT WHEN c_entrada%NOTFOUND;
            END LOOP;

            COMMIT;

            CLOSE c_entrada;
        ELSIF ( vp_origem = 'F' ) THEN --FILIAL
            v_sql := v_sql || 'SELECT /*+PARALLEL(8)*/ DISTINCT ''' || vp_proc_instance || ''', ';
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
            v_sql := v_sql || ' A.DATA_FISCAL_S, ';
            ---
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
            v_sql := v_sql || '     SELECT  /*+INDEX(D PK_X2013_PRODUTO) ';
            v_sql := v_sql || '		           INDEX(A PK_X2043_COD_NBM) ';
            v_sql := v_sql || '				   INDEX(G PK_X04_PESSOA_FIS_JUR)*/ ';
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
            v_sql := v_sql || '               P.DATA_FISCAL_S, ';
            ---
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
            v_sql := v_sql || '               E.COD_SITUACAO_B, ';
            v_sql := v_sql || '               X07.DATA_EMISSAO, ';
            v_sql := v_sql || '               H.COD_ESTADO, ';
            v_sql := v_sql || '               X07.NUM_CONTROLE_DOCTO, ';
            v_sql := v_sql || '               '''' || X07.NUM_AUTENTIC_NFE AS NUM_AUTENTIC_NFE, ';
            v_sql := v_sql || '               RANK() OVER( ';
            v_sql :=
                   v_sql
                || '                    PARTITION BY X08.COD_ESTAB, D.COD_PRODUTO, G.COD_FIS_JUR, P.DATA_FISCAL_S ';
            v_sql :=
                   v_sql
                || '                    ORDER BY X08.DATA_FISCAL DESC, X07.DATA_EMISSAO DESC, X08.NUM_DOCFIS DESC, X08.DISCRI_ITEM DESC) RANK ';
            v_sql := v_sql || '        FROM X08_ITENS_MERC X08, ';
            v_sql := v_sql || '             X07_DOCTO_FISCAL X07, ';
            v_sql := v_sql || '             X2013_PRODUTO D, ';
            v_sql := v_sql || '             X04_PESSOA_FIS_JUR G, ';
            v_sql := v_sql || '             ' || vp_tabela_saida || ' P, ';
            v_sql := v_sql || '             X2043_COD_NBM A, ';
            v_sql := v_sql || '             X2012_COD_FISCAL B, ';
            v_sql := v_sql || '             X2006_NATUREZA_OP C, ';
            v_sql := v_sql || '             Y2026_SIT_TRB_UF_B E, ';
            v_sql := v_sql || '             ESTADO H  ';
            v_sql := v_sql || '        WHERE X08.MOVTO_E_S         <> ''9'' ';
            v_sql := v_sql || '          AND X08.COD_EMPRESA        = ''' || mcod_empresa || ''' ';
            v_sql := v_sql || '          AND X08.COD_ESTAB          = ''' || vp_cod_estab || ''' ';
            v_sql := v_sql || '          AND G.COD_FIS_JUR          = ''' || vp_cd || ''' ';
            v_sql := v_sql || '          AND X08.IDENT_NBM          = A.IDENT_NBM ';
            v_sql := v_sql || '          AND X08.IDENT_CFO          = B.IDENT_CFO ';
            v_sql := v_sql || '          AND B.COD_CFO             IN (''1152'',''2152'',''1409'',''2409'') ';
            v_sql := v_sql || '          AND X08.IDENT_NATUREZA_OP  = C.IDENT_NATUREZA_OP ';
            v_sql := v_sql || '          AND X08.IDENT_SITUACAO_B   = E.IDENT_SITUACAO_B ';
            v_sql := v_sql || '          AND D.IDENT_PRODUTO      = X08.IDENT_PRODUTO ';
            ---
            v_sql := v_sql || '          AND D.COD_PRODUTO        = P.COD_PRODUTO ';
            v_sql := v_sql || '          AND X08.COD_ESTAB        = P.COD_ESTAB ';
            v_sql := v_sql || '          AND X08.DATA_FISCAL      < P.DATA_FISCAL_S ';
            -- alterado
            --V_SQL := V_SQL || '          AND X08.DATA_FISCAL        >= TO_DATE(''' || TO_CHAR(VP_DT_FINAL,'DD/MM/YYYY') || ''',''DD/MM/YYYY'') - (365*2) '; --ULTIMOS 2 ANOS
            v_sql :=
                   v_sql
                || '          AND X08.DATA_FISCAL        >= TO_DATE('''
                || TO_CHAR ( vp_dt_final_calculado
                           , 'DD/MM/YYYY' )
                || ''',''DD/MM/YYYY'') '; --ULTIMOS 2 ANOS
            -- incluido inicio
            v_sql :=
                   v_sql
                || '          AND X08.DATA_FISCAL        < '
                || ' TO_DATE('''
                || TO_CHAR ( vp_maior_data_fiscal_s
                           , 'YYYYMMDD' )
                || ''',''YYYYMMDD'')';
            v_sql :=
                   v_sql
                || '          AND X07.DATA_FISCAL        < '
                || ' TO_DATE('''
                || TO_CHAR ( vp_maior_data_fiscal_s
                           , 'YYYYMMDD' )
                || ''',''YYYYMMDD'')';
            v_sql :=
                   v_sql
                || '          AND X07.DATA_FISCAL        >= TO_DATE('''
                || TO_CHAR ( vp_dt_final_calculado
                           , 'DD/MM/YYYY' )
                || ''',''DD/MM/YYYY'')  '; --ULTIMOS 2 ANOS
            v_sql := v_sql || '          AND X07.DATA_FISCAL        < P.DATA_FISCAL_S ';
            -- incluido fim

            ---
            v_sql := v_sql || '          AND X07.VLR_PRODUTO     <> 0 ';
            v_sql := v_sql || '          AND X07.IDENT_FIS_JUR    = G.IDENT_FIS_JUR  ';
            v_sql := v_sql || '          AND G.IDENT_ESTADO       = H.IDENT_ESTADO ';
            ---
            v_sql := v_sql || '          AND X07.COD_EMPRESA      = X08.COD_EMPRESA ';
            v_sql := v_sql || '          AND X07.COD_ESTAB        = X08.COD_ESTAB ';
            v_sql := v_sql || '          AND X07.DATA_FISCAL      = X08.DATA_FISCAL ';
            v_sql := v_sql || '          AND X07.MOVTO_E_S        = X08.MOVTO_E_S ';
            v_sql := v_sql || '          AND X07.NORM_DEV         = X08.NORM_DEV ';
            v_sql := v_sql || '          AND X07.IDENT_DOCTO      = X08.IDENT_DOCTO ';
            v_sql := v_sql || '          AND X07.IDENT_FIS_JUR    = X08.IDENT_FIS_JUR ';
            v_sql := v_sql || '          AND X07.NUM_DOCFIS       = X08.NUM_DOCFIS ';
            v_sql := v_sql || '          AND X07.SERIE_DOCFIS     = X08.SERIE_DOCFIS ';
            v_sql := v_sql || '          AND X07.SUB_SERIE_DOCFIS = X08.SUB_SERIE_DOCFIS ';
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
                                , vp_dt_ini
                                , vp_dt_final
                                , SQLERRM
                                , 'E'
                                , vp_data_hora_ini );
                    -----------------------------------------------------------------
                    raise_application_error ( -20004
                                            , '!ERRO SELECT ENTRADA FILIAL!' );
            END;

            LOOP
                FETCH c_entrada
                    BULK COLLECT INTO tab_e
                    LIMIT 100;

                BEGIN
                    FORALL i IN tab_e.FIRST .. tab_e.LAST
                        EXECUTE IMMEDIATE
                               'INSERT /*+APPEND_VALUES*/ INTO '
                            || vp_tabela_entrada
                            || ' VALUES (:1, :2, :3, :4, :5, :6, :7, :8, :9, '
                            || ' :10, :11, :12, :13, :14, :15, :16, :17, :18, :19, :20, :21, :22, :23, :24, :25, '
                            || ' :26, :27, :28) '
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
                                , tab_e ( i ).data_fiscal_s
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
                                , tab_e ( i ).cod_situacao_b
                                , tab_e ( i ).data_emissao
                                , tab_e ( i ).cod_estado
                                , tab_e ( i ).num_controle_docto
                                , tab_e ( i ).num_autentic_nfe;
                EXCEPTION
                    WHEN OTHERS THEN
                        loga ( 'SQLERRM: ' || SQLERRM
                             , FALSE );
                        --ENVIAR EMAIL DE ERRO-------------------------------------------
                        envia_email ( mcod_empresa
                                    , vp_dt_ini
                                    , vp_dt_final
                                    , SQLERRM
                                    , 'E'
                                    , vp_data_hora_ini );
                        -----------------------------------------------------------------
                        raise_application_error ( -20004
                                                , '!ERRO INSERT ENTRADA FILIAL!' );
                END;

                COMMIT;
                tab_e.delete;

                EXIT WHEN c_entrada%NOTFOUND;
            END LOOP;

            COMMIT;

            CLOSE c_entrada;
        ELSIF ( vp_origem = 'CO' ) THEN --COMPRA DIRETA
            v_sql := v_sql || 'SELECT /*+PARALLEL(4)*/ DISTINCT ''' || vp_proc_instance || ''', ';
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
            v_sql := v_sql || ' A.DATA_FISCAL_S, ';
            ---
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
            v_sql := v_sql || '     SELECT  /*+INDEX(D PK_X2013_PRODUTO) ';
            v_sql := v_sql || '		           INDEX(A PK_X2043_COD_NBM) ';
            v_sql := v_sql || '				   INDEX(G PK_X04_PESSOA_FIS_JUR)*/ ';
            v_sql := v_sql || '        X08.COD_EMPRESA, ';
            v_sql := v_sql || '        X08.COD_ESTAB, ';
            v_sql := v_sql || '        X08.DATA_FISCAL, ';
            v_sql := v_sql || '        X08.MOVTO_E_S, ';
            v_sql := v_sql || '        X08.NORM_DEV, ';
            v_sql := v_sql || '        X08.IDENT_DOCTO, ';
            v_sql := v_sql || '        X08.IDENT_FIS_JUR, ';
            v_sql := v_sql || '        X08.NUM_DOCFIS, ';
            v_sql := v_sql || '        X08.SERIE_DOCFIS, ';
            v_sql := v_sql || '        X08.SUB_SERIE_DOCFIS, ';
            v_sql := v_sql || '        X08.DISCRI_ITEM, ';
            v_sql := v_sql || '        P.DATA_FISCAL_S, ';
            ---
            v_sql := v_sql || '        X08.NUM_ITEM, ';
            v_sql := v_sql || '        G.COD_FIS_JUR, ';
            v_sql := v_sql || '        G.CPF_CGC, ';
            v_sql := v_sql || '        A.COD_NBM, ';
            v_sql := v_sql || '        B.COD_CFO, ';
            v_sql := v_sql || '        C.COD_NATUREZA_OP, ';
            v_sql := v_sql || '        D.COD_PRODUTO, ';
            v_sql := v_sql || '        X08.VLR_CONTAB_ITEM, ';
            v_sql := v_sql || '        X08.QUANTIDADE, ';
            v_sql := v_sql || '        X08.VLR_UNIT, ';
            v_sql := v_sql || '        E.COD_SITUACAO_B, ';
            v_sql := v_sql || '        X07.DATA_EMISSAO, ';
            v_sql := v_sql || '        H.COD_ESTADO, ';
            v_sql := v_sql || '        X07.NUM_CONTROLE_DOCTO, ';
            v_sql := v_sql || '        '''' || X07.NUM_AUTENTIC_NFE AS NUM_AUTENTIC_NFE, ';
            v_sql := v_sql || '        RANK() OVER( ';
            v_sql := v_sql || '                    PARTITION BY X08.COD_ESTAB, D.COD_PRODUTO, P.DATA_FISCAL_S ';
            v_sql :=
                   v_sql
                || '                    ORDER BY X08.DATA_FISCAL DESC, X07.DATA_EMISSAO DESC, X08.NUM_DOCFIS DESC, X08.DISCRI_ITEM DESC) RANK ';
            v_sql := v_sql || '        FROM X08_ITENS_MERC X08, ';
            v_sql := v_sql || '             X07_DOCTO_FISCAL X07, ';
            v_sql := v_sql || '             X2013_PRODUTO D, ';
            v_sql := v_sql || '             X04_PESSOA_FIS_JUR G, ';
            v_sql := v_sql || '             ' || vp_tabela_saida || ' P, ';
            v_sql := v_sql || '             X2043_COD_NBM A, ';
            v_sql := v_sql || '             X2012_COD_FISCAL B, ';
            v_sql := v_sql || '             X2006_NATUREZA_OP C, ';
            v_sql := v_sql || '             Y2026_SIT_TRB_UF_B E, ';
            v_sql := v_sql || '             ESTADO H  ';
            v_sql := v_sql || '        WHERE X08.MOVTO_E_S       <> ''9'' ';
            v_sql := v_sql || '          AND X08.COD_EMPRESA      = ''' || mcod_empresa || ''' ';
            v_sql := v_sql || '          AND X08.COD_ESTAB        = ''' || vp_cod_estab || ''' ';
            v_sql := v_sql || '          AND X08.IDENT_NBM        = A.IDENT_NBM ';
            v_sql := v_sql || '          AND X08.IDENT_CFO        = B.IDENT_CFO ';
            v_sql :=
                   v_sql
                || '          AND B.COD_CFO            IN (''1102'',''2102'',''1403'',''2403'',''1910'',''2910'') ';
            v_sql := v_sql || '          AND ((G.CPF_CGC NOT LIKE ''61412110%'' AND X08.COD_EMPRESA = ''DSP'') '; --FORNECEDOR DSP
            v_sql := v_sql || '           OR  (G.CPF_CGC NOT LIKE ''334382500%'' AND X08.COD_EMPRESA = ''DP'')) '; --FORNECEDOR DP
            v_sql := v_sql || '          AND X07.NUM_CONTROLE_DOCTO  NOT LIKE ''C%'' '; --RETIRAR CELULA
            v_sql := v_sql || '          AND X08.IDENT_NATUREZA_OP = C.IDENT_NATUREZA_OP ';
            v_sql := v_sql || '          AND X08.IDENT_SITUACAO_B  = E.IDENT_SITUACAO_B ';
            v_sql := v_sql || '          AND X08.IDENT_PRODUTO     = D.IDENT_PRODUTO ';
            ---
            v_sql := v_sql || '          AND D.COD_PRODUTO         = P.COD_PRODUTO ';
            v_sql := v_sql || '          AND X08.COD_ESTAB         = P.COD_ESTAB ';
            v_sql := v_sql || '          AND X08.DATA_FISCAL       < P.DATA_FISCAL_S ';
            -- alterado
            --V_SQL := V_SQL || '          AND X08.DATA_FISCAL        >= TO_DATE(''' || TO_CHAR(VP_DT_FINAL,'DD/MM/YYYY') || ''',''DD/MM/YYYY'') - (365*2) '; --ULTIMOS 2 ANOS
            v_sql :=
                   v_sql
                || '          AND X08.DATA_FISCAL        >= TO_DATE('''
                || TO_CHAR ( vp_dt_final_calculado
                           , 'DD/MM/YYYY' )
                || ''',''DD/MM/YYYY'') '; --ULTIMOS 2 ANOS
            -- incluido inicio
            v_sql :=
                   v_sql
                || '          AND X08.DATA_FISCAL        < '
                || ' TO_DATE('''
                || TO_CHAR ( vp_maior_data_fiscal_s
                           , 'YYYYMMDD' )
                || ''',''YYYYMMDD'')';
            v_sql :=
                   v_sql
                || '          AND X07.DATA_FISCAL        < '
                || ' TO_DATE('''
                || TO_CHAR ( vp_maior_data_fiscal_s
                           , 'YYYYMMDD' )
                || ''',''YYYYMMDD'')';
            v_sql :=
                   v_sql
                || '          AND X07.DATA_FISCAL        >= TO_DATE('''
                || TO_CHAR ( vp_dt_final_calculado
                           , 'DD/MM/YYYY' )
                || ''',''DD/MM/YYYY'')  '; --ULTIMOS 2 ANOS
            v_sql := v_sql || '          AND X07.DATA_FISCAL        < P.DATA_FISCAL_S ';
            -- incluido fim


            ---
            v_sql := v_sql || '          AND X07.VLR_PRODUTO      <> 0 ';
            v_sql := v_sql || '          AND X07.IDENT_FIS_JUR     = G.IDENT_FIS_JUR ';
            v_sql := v_sql || '          AND G.IDENT_ESTADO        = H.IDENT_ESTADO ';
            ---
            v_sql := v_sql || '          AND X07.COD_EMPRESA       = X08.COD_EMPRESA ';
            v_sql := v_sql || '          AND X07.COD_ESTAB         = X08.COD_ESTAB ';
            v_sql := v_sql || '          AND X07.DATA_FISCAL       = X08.DATA_FISCAL ';
            v_sql := v_sql || '          AND X07.MOVTO_E_S         = X08.MOVTO_E_S ';
            v_sql := v_sql || '          AND X07.NORM_DEV          = X08.NORM_DEV ';
            v_sql := v_sql || '          AND X07.IDENT_DOCTO       = X08.IDENT_DOCTO ';
            v_sql := v_sql || '          AND X07.IDENT_FIS_JUR     = X08.IDENT_FIS_JUR ';
            v_sql := v_sql || '          AND X07.NUM_DOCFIS        = X08.NUM_DOCFIS ';
            v_sql := v_sql || '          AND X07.SERIE_DOCFIS      = X08.SERIE_DOCFIS ';
            v_sql := v_sql || '          AND X07.SUB_SERIE_DOCFIS  = X08.SUB_SERIE_DOCFIS ';
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
                                , vp_dt_ini
                                , vp_dt_final
                                , SQLERRM
                                , 'E'
                                , vp_data_hora_ini );
                    -----------------------------------------------------------------
                    raise_application_error ( -20005
                                            , '!ERRO SELECT ENTRADA CDIRETA!' );
            END;

            LOOP
                FETCH c_entrada
                    BULK COLLECT INTO tab_e
                    LIMIT 100;

                BEGIN
                    FORALL i IN tab_e.FIRST .. tab_e.LAST
                        EXECUTE IMMEDIATE
                               'INSERT /*+APPEND_VALUES*/ INTO '
                            || vp_tabela_entrada
                            || ' VALUES (:1, :2, :3, :4, :5, :6, :7, :8, :9, '
                            || ' :10, :11, :12, :13, :14, :15, :16, :17, :18, :19, :20, :21, :22, :23, :24, :25, '
                            || ' :26, :27, :28) '
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
                                , tab_e ( i ).data_fiscal_s
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
                                , tab_e ( i ).cod_situacao_b
                                , tab_e ( i ).data_emissao
                                , tab_e ( i ).cod_estado
                                , tab_e ( i ).num_controle_docto
                                , tab_e ( i ).num_autentic_nfe;
                EXCEPTION
                    WHEN OTHERS THEN
                        loga ( 'SQLERRM: ' || SQLERRM
                             , FALSE );
                        --ENVIAR EMAIL DE ERRO-------------------------------------------
                        envia_email ( mcod_empresa
                                    , vp_dt_ini
                                    , vp_dt_final
                                    , SQLERRM
                                    , 'E'
                                    , vp_data_hora_ini );
                        -----------------------------------------------------------------
                        raise_application_error ( -20004
                                                , '!ERRO INSERT ENTRADA CDIRETA!' );
                END;

                COMMIT;
                tab_e.delete;

                EXIT WHEN c_entrada%NOTFOUND;
            END LOOP;

            COMMIT;

            CLOSE c_entrada;
        END IF;
    END; --PROCEDURE LOAD_ENTRADAS

    --PROCEDURE PARA CRIAR TABELAS TEMP DE ALIQ E PMC
    PROCEDURE load_aliq_pmc ( vp_proc_id IN NUMBER
                            , vp_nome_tabela_aliq   OUT VARCHAR2
                            , vp_nome_tabela_pmc   OUT VARCHAR2
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

        EXECUTE IMMEDIATE v_sql;

        ---
        save_tmp_control ( vp_proc_id
                         , vp_nome_tabela_aliq );

        v_sql := ' SELECT DISTINCT ';
        v_sql := v_sql || '        ' || vp_proc_id || ', ';
        v_sql := v_sql || '        A.COD_PRODUTO, ';
        v_sql := v_sql || '        A.ALIQ_ST ';
        v_sql := v_sql || ' FROM ( ';
        v_sql := v_sql || '   SELECT /*+DRIVING_SITE(B)*/ A.COD_PRODUTO AS COD_PRODUTO, ';
        v_sql := v_sql || '          B.XLATLONGNAME AS ALIQ_ST ';
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

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX1_ALIQ_' || vp_proc_id || ' ON ' || vp_nome_tabela_aliq;
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || '   PROC_ID     ASC,';
        v_sql := v_sql || '   COD_PRODUTO ASC, ';
        v_sql := v_sql || '   ALIQ_ST     ASC ';
        v_sql := v_sql || ' ) ';
        v_sql := v_sql || ' PCTFREE 10 ';

        EXECUTE IMMEDIATE v_sql;

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_nome_tabela_aliq );
        loga ( '>>' || vp_nome_tabela_aliq || ' CRIADA'
             , FALSE );

        -------------------------------------------------------------------------------------
        vp_nome_tabela_pmc := 'DPSP_MSAF_PMC_' || vp_proc_id;

        v_sql := 'CREATE TABLE ' || vp_nome_tabela_pmc || ' AS ';
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || 'SELECT  /*+DRIVING_SITE(A)*/ ';
        v_sql := v_sql || '        B.PROC_ID, A.INV_ITEM_ID AS COD_PRODUTO, A.DSP_PMC AS VLR_PMC ';
        v_sql :=
            v_sql || 'FROM (SELECT A.SETID, A.INV_ITEM_ID, A.DSP_ALIQ_ICMS_ID, A.UNIT_OF_MEASURE, A.EFFDT, A.DSP_PMC ';
        v_sql := v_sql || '      FROM (';
        v_sql :=
               v_sql
            || '             SELECT A.SETID, A.INV_ITEM_ID, A.DSP_ALIQ_ICMS_ID, A.UNIT_OF_MEASURE, A.EFFDT, A.DSP_PMC, ';
        v_sql :=
               v_sql
            || '                    RANK() OVER( PARTITION BY A.SETID, A.INV_ITEM_ID, A.DSP_ALIQ_ICMS_ID, A.UNIT_OF_MEASURE ';
        v_sql := v_sql || '                                 ORDER BY A.EFFDT DESC) RANK ';
        v_sql := v_sql || '             FROM MSAFI.PS_DSP_PRECO_ITEM A ';
        v_sql := v_sql || '            ) A ';
        v_sql := v_sql || '      WHERE A.RANK = 1) A, ';
        v_sql := v_sql || vp_nome_tabela_aliq || ' B ';
        v_sql := v_sql || ' WHERE A.SETID            = ''GERAL'' ';
        v_sql := v_sql || '   AND B.PROC_ID          = ' || vp_proc_id;
        v_sql := v_sql || '   AND A.INV_ITEM_ID      = B.COD_PRODUTO ';
        v_sql := v_sql || '   AND A.DSP_ALIQ_ICMS_ID = B.ALIQ_ST ';
        v_sql := v_sql || '   AND A.UNIT_OF_MEASURE  = ''UN'' ) ';

        EXECUTE IMMEDIATE v_sql;

        COMMIT;

        v_sql := 'CREATE INDEX PK_PMC_' || vp_proc_id || ' ON ' || vp_nome_tabela_pmc;
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || '   PROC_ID     ASC, ';
        v_sql := v_sql || '   COD_PRODUTO ASC ';
        v_sql := v_sql || ' ) ';
        v_sql := v_sql || ' PCTFREE 10 ';

        EXECUTE IMMEDIATE v_sql;

        COMMIT;

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_nome_tabela_pmc );
        save_tmp_control ( vp_proc_id
                         , vp_nome_tabela_pmc );
        loga ( '>>' || vp_nome_tabela_pmc || ' CRIADA'
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
                              , vp_tabela_pmc_mva IN VARCHAR2
                              , vp_data_hora_ini IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 6000 );
    BEGIN
        v_sql := 'INSERT /*+APPEND*/ INTO ' || vp_tabela_pmc_mva || ' ( ';

        v_sql := v_sql || 'SELECT               ';
        v_sql := v_sql || 'A.PROC_ID,           ';
        v_sql := v_sql || 'A.COD_EMPRESA,       ';
        v_sql := v_sql || 'A.COD_ESTAB,         ';
        v_sql := v_sql || 'A.NUM_DOCFIS,        ';
        v_sql := v_sql || 'A.DATA_FISCAL,       ';
        v_sql := v_sql || 'A.SERIE_DOCFIS,      ';
        v_sql := v_sql || 'A.COD_PRODUTO,       ';
        v_sql := v_sql || 'A.COD_ESTADO,        ';
        v_sql := v_sql || 'A.DOCTO,             ';
        v_sql := v_sql || 'A.NUM_ITEM,          ';
        v_sql := v_sql || 'A.DESCR_ITEM,        ';
        v_sql := v_sql || 'A.QUANTIDADE,        ';
        v_sql := v_sql || 'A.COD_NBM,           ';
        v_sql := v_sql || 'A.COD_CFO,           ';
        v_sql := v_sql || 'A.GRUPO_PRODUTO,     ';
        v_sql := v_sql || 'A.VLR_DESCONTO,      ';
        v_sql := v_sql || 'A.VLR_CONTABIL,      ';
        v_sql := v_sql || 'A.BASE_UNIT_S_VENDA, ';
        v_sql := v_sql || 'A.NUM_AUTENTIC_NFE,  ';
        v_sql := v_sql || 'A.LISTA,             ';

        v_sql := v_sql || 'A.COD_ESTAB_E,         ';
        v_sql := v_sql || 'A.DATA_FISCAL_E,       ';
        v_sql := v_sql || 'A.MOVTO_E_S_E,         ';
        v_sql := v_sql || 'A.NORM_DEV_E,          ';
        v_sql := v_sql || 'A.IDENT_DOCTO_E,       ';
        v_sql := v_sql || 'A.IDENT_FIS_JUR_E,     ';
        v_sql := v_sql || 'A.SUB_SERIE_DOCFIS_E,  ';
        v_sql := v_sql || 'A.DISCRI_ITEM_E,       ';
        v_sql := v_sql || 'A.DATA_EMISSAO_E,      ';
        v_sql := v_sql || 'A.NUM_DOCFIS_E,        ';
        v_sql := v_sql || 'A.SERIE_DOCFIS_E,      ';
        v_sql := v_sql || 'A.NUM_ITEM_E,          ';
        v_sql := v_sql || 'A.COD_FIS_JUR_E,       ';
        v_sql := v_sql || 'A.CPF_CGC_E,           ';
        v_sql := v_sql || 'A.COD_NBM_E,           ';
        v_sql := v_sql || 'A.COD_CFO_E,           ';
        v_sql := v_sql || 'A.COD_NATUREZA_OP_E,   ';
        v_sql := v_sql || 'A.COD_PRODUTO_E,       ';
        v_sql := v_sql || 'A.VLR_CONTAB_ITEM_E,   ';
        v_sql := v_sql || 'A.QUANTIDADE_E,        ';
        v_sql := v_sql || 'A.VLR_UNIT_E,          ';
        v_sql := v_sql || 'A.COD_SITUACAO_B_E,    ';
        v_sql := v_sql || 'A.COD_ESTADO_E,        ';
        v_sql := v_sql || 'A.NUM_CONTROLE_DOCTO_E, ';
        v_sql := v_sql || 'A.NUM_AUTENTIC_NFE_E,  ';

        v_sql := v_sql || 'A.BASE_ICMS_UNIT,      ';
        v_sql := v_sql || 'A.VLR_ICMS_UNIT,       ';
        v_sql := v_sql || 'A.ALIQ_ICMS,           ';
        v_sql := v_sql || 'A.BASE_ST_UNIT,        ';
        v_sql := v_sql || 'A.VLR_ICMS_ST_UNIT,    ';
        v_sql := v_sql || 'A.VLR_ICMS_ST_UNIT_AUX, ';

        v_sql := v_sql || 'A.STAT_LIBER_CNTR 	  ';

        v_sql := v_sql || 'FROM ( ';

        v_sql := v_sql || ' SELECT ';
        v_sql := v_sql || ' ''' || vp_proc_id || ''' AS PROC_ID, ';
        v_sql := v_sql || ' ''' || mcod_empresa || ''' AS COD_EMPRESA, ';
        v_sql := v_sql || ' A.COD_ESTAB, ';
        v_sql := v_sql || ' A.NUM_DOCFIS, ';
        v_sql := v_sql || ' A.DATA_FISCAL, ';
        v_sql := v_sql || ' A.SERIE_DOCFIS, ';
        v_sql := v_sql || ' A.COD_PRODUTO, ';
        v_sql := v_sql || ' A.COD_ESTADO, ';
        v_sql := v_sql || ' A.DOCTO, ';
        v_sql := v_sql || ' A.NUM_ITEM, ';
        v_sql := v_sql || ' A.DESCR_ITEM, ';
        v_sql := v_sql || ' A.QUANTIDADE, ';
        v_sql := v_sql || ' A.COD_NBM, ';
        v_sql := v_sql || ' A.COD_CFO, ';
        v_sql := v_sql || ' A.GRUPO_PRODUTO, ';
        v_sql := v_sql || ' A.VLR_DESCONTO, ';
        v_sql := v_sql || ' A.VLR_CONTABIL, ';
        v_sql := v_sql || ' A.BASE_UNIT_S_VENDA, ';
        v_sql := v_sql || ' A.NUM_AUTENTIC_NFE, ';
        v_sql := v_sql || ' A.LISTA, ';
        ---
        v_sql := v_sql || ' B.COD_ESTAB AS COD_ESTAB_E, ';
        v_sql := v_sql || ' B.DATA_FISCAL AS DATA_FISCAL_E, ';
        v_sql := v_sql || ' B.MOVTO_E_S AS MOVTO_E_S_E, ';
        v_sql := v_sql || ' B.NORM_DEV AS NORM_DEV_E, ';
        v_sql := v_sql || ' B.IDENT_DOCTO AS IDENT_DOCTO_E, ';
        v_sql := v_sql || ' B.IDENT_FIS_JUR AS IDENT_FIS_JUR_E, ';
        v_sql := v_sql || ' B.SUB_SERIE_DOCFIS AS SUB_SERIE_DOCFIS_E, ';
        v_sql := v_sql || ' B.DISCRI_ITEM AS DISCRI_ITEM_E, ';
        v_sql := v_sql || ' B.DATA_EMISSAO AS DATA_EMISSAO_E, ';
        v_sql := v_sql || ' B.NUM_DOCFIS AS NUM_DOCFIS_E, ';
        v_sql := v_sql || ' B.SERIE_DOCFIS AS SERIE_DOCFIS_E, ';
        v_sql := v_sql || ' B.NUM_ITEM AS NUM_ITEM_E, ';
        v_sql := v_sql || ' B.COD_FIS_JUR AS COD_FIS_JUR_E, ';
        v_sql := v_sql || ' B.CPF_CGC AS CPF_CGC_E, ';
        v_sql := v_sql || ' B.COD_NBM AS COD_NBM_E, ';
        v_sql := v_sql || ' B.COD_CFO AS COD_CFO_E, ';
        v_sql := v_sql || ' B.COD_NATUREZA_OP AS COD_NATUREZA_OP_E, ';
        v_sql := v_sql || ' B.COD_PRODUTO AS COD_PRODUTO_E, ';
        v_sql := v_sql || ' B.VLR_CONTAB_ITEM AS VLR_CONTAB_ITEM_E, ';
        v_sql := v_sql || ' B.QUANTIDADE AS QUANTIDADE_E, ';
        v_sql := v_sql || ' B.VLR_UNIT AS VLR_UNIT_E, ';
        v_sql := v_sql || ' B.COD_SITUACAO_B AS COD_SITUACAO_B_E, ';
        v_sql := v_sql || ' B.COD_ESTADO AS COD_ESTADO_E, ';
        v_sql := v_sql || ' B.NUM_CONTROLE_DOCTO AS NUM_CONTROLE_DOCTO_E, ';
        v_sql := v_sql || ' B.NUM_AUTENTIC_NFE AS NUM_AUTENTIC_NFE_E, ';
        ---
        v_sql := v_sql || ' C.BASE_ICMS_UNIT, ';
        v_sql := v_sql || ' C.VLR_ICMS_UNIT, ';
        v_sql := v_sql || ' C.ALIQ_ICMS, ';
        v_sql := v_sql || ' C.BASE_ST_UNIT, ';
        v_sql := v_sql || ' C.VLR_ICMS_ST_UNIT, ';
        v_sql := v_sql || ' C.VLR_ICMS_ST_UNIT_AUX, ';
        ---
        v_sql :=
            v_sql || ' DECODE(E.LIBER_CNTR_DSP,''C'',''CONTROLADO'',''L'',''LIBERADO'',''OUTRO'') STAT_LIBER_CNTR ';
        ---
        v_sql := v_sql || ' FROM ' || vp_tabela_saida || ' A, ';
        v_sql := v_sql || '      ' || vp_tab_entrada_c || ' B, ';
        v_sql := v_sql || '      ' || vp_tabela_nf || ' C, ';
        v_sql := v_sql || '      MSAFI.DSP_INTERFACE_SETUP D, ';
        v_sql := v_sql || '      MSAFI.PS_ATRB_OPER_DSP E ';
        v_sql := v_sql || ' WHERE A.PROC_ID       = ''' || vp_proc_id || ''' ';
        v_sql := v_sql || '   AND A.COD_ESTAB     = ''' || vp_filial || ''' ';
        ---
        v_sql := v_sql || '   AND B.PROC_ID       = A.PROC_ID ';
        v_sql := v_sql || '   AND B.COD_EMPRESA   = A.COD_EMPRESA ';
        v_sql := v_sql || '   AND B.DATA_FISCAL_S = A.DATA_FISCAL ';
        v_sql := v_sql || '   AND B.COD_ESTAB     = ''' || vp_cd || ''' ';
        v_sql := v_sql || '   AND B.COD_PRODUTO   = A.COD_PRODUTO ';
        ---
        v_sql := v_sql || '   AND D.COD_EMPRESA        = ''' || mcod_empresa || ''' ';
        v_sql := v_sql || '   AND A.PROC_ID            = C.PROC_ID ';
        v_sql := v_sql || '   AND D.BU_PO1             = C.BUSINESS_UNIT ';
        v_sql := v_sql || '   AND B.NUM_CONTROLE_DOCTO = C.NF_BRL_ID ';
        v_sql := v_sql || '   AND B.NUM_ITEM           = C.NF_BRL_LINE_NUM ';
        ---
        v_sql := v_sql || '   AND E.SETID              = ''GERAL'' ';
        v_sql := v_sql || '   AND E.INV_ITEM_ID        = A.COD_PRODUTO ';
        ---
        v_sql := v_sql || '   AND NOT EXISTS (SELECT /*+PARALLEL_INDEX(C PK_DPSP_P_' || vp_proc_id || ', 6)*/ ''Y'' ';
        v_sql := v_sql || '                   FROM ' || vp_tabela_pmc_mva || ' C ';
        v_sql := v_sql || '                   WHERE C.PROC_ID      = A.PROC_ID ';
        v_sql := v_sql || '                     AND C.COD_EMPRESA  = A.COD_EMPRESA ';
        v_sql := v_sql || '                     AND C.COD_ESTAB    = A.COD_ESTAB ';
        v_sql := v_sql || '                     AND C.NUM_DOCFIS   = A.NUM_DOCFIS ';
        v_sql := v_sql || '                     AND C.DATA_FISCAL  = A.DATA_FISCAL ';
        v_sql := v_sql || '                     AND C.SERIE_DOCFIS = A.SERIE_DOCFIS ';
        v_sql := v_sql || '                     AND C.COD_PRODUTO  = A.COD_PRODUTO ';
        v_sql := v_sql || '                     AND C.COD_ESTADO   = A.COD_ESTADO ';
        v_sql := v_sql || '                     AND C.DOCTO        = A.DOCTO ';
        v_sql := v_sql || '                     AND C.NUM_ITEM     = A.NUM_ITEM) ';
        v_sql := v_sql || '   AND A.DATA_FISCAL > B.DATA_FISCAL ';
        v_sql := v_sql || '   ) A ) ';

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
                                      , vp_tabela_pmc_mva );
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
                                  , vp_tabela_pmc_mva IN VARCHAR2
                                  , vp_data_hora_ini IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 6000 );
    BEGIN
        v_sql := 'INSERT /*+APPEND*/ INTO ' || vp_tabela_pmc_mva || ' ( ';

        v_sql := v_sql || 'SELECT               ';
        v_sql := v_sql || 'A.PROC_ID,           ';
        v_sql := v_sql || 'A.COD_EMPRESA,       ';
        v_sql := v_sql || 'A.COD_ESTAB,         ';
        v_sql := v_sql || 'A.NUM_DOCFIS,        ';
        v_sql := v_sql || 'A.DATA_FISCAL,       ';
        v_sql := v_sql || 'A.SERIE_DOCFIS,      ';
        v_sql := v_sql || 'A.COD_PRODUTO,       ';
        v_sql := v_sql || 'A.COD_ESTADO,        ';
        v_sql := v_sql || 'A.DOCTO,             ';
        v_sql := v_sql || 'A.NUM_ITEM,          ';
        v_sql := v_sql || 'A.DESCR_ITEM,        ';
        v_sql := v_sql || 'A.QUANTIDADE,        ';
        v_sql := v_sql || 'A.COD_NBM,           ';
        v_sql := v_sql || 'A.COD_CFO,           ';
        v_sql := v_sql || 'A.GRUPO_PRODUTO,     ';
        v_sql := v_sql || 'A.VLR_DESCONTO,      ';
        v_sql := v_sql || 'A.VLR_CONTABIL,      ';
        v_sql := v_sql || 'A.BASE_UNIT_S_VENDA, ';
        v_sql := v_sql || 'A.NUM_AUTENTIC_NFE,  ';
        v_sql := v_sql || 'A.LISTA,             ';

        v_sql := v_sql || 'A.COD_ESTAB_E,         ';
        v_sql := v_sql || 'A.DATA_FISCAL_E,       ';
        v_sql := v_sql || 'A.MOVTO_E_S_E,         ';
        v_sql := v_sql || 'A.NORM_DEV_E,          ';
        v_sql := v_sql || 'A.IDENT_DOCTO_E,       ';
        v_sql := v_sql || 'A.IDENT_FIS_JUR_E,     ';
        v_sql := v_sql || 'A.SUB_SERIE_DOCFIS_E,  ';
        v_sql := v_sql || 'A.DISCRI_ITEM_E,       ';
        v_sql := v_sql || 'A.DATA_EMISSAO_E,      ';
        v_sql := v_sql || 'A.NUM_DOCFIS_E,        ';
        v_sql := v_sql || 'A.SERIE_DOCFIS_E,      ';
        v_sql := v_sql || 'A.NUM_ITEM_E,          ';
        v_sql := v_sql || 'A.COD_FIS_JUR_E,       ';
        v_sql := v_sql || 'A.CPF_CGC_E,           ';
        v_sql := v_sql || 'A.COD_NBM_E,           ';
        v_sql := v_sql || 'A.COD_CFO_E,           ';
        v_sql := v_sql || 'A.COD_NATUREZA_OP_E,   ';
        v_sql := v_sql || 'A.COD_PRODUTO_E,       ';
        v_sql := v_sql || 'A.VLR_CONTAB_ITEM_E,   ';
        v_sql := v_sql || 'A.QUANTIDADE_E,        ';
        v_sql := v_sql || 'A.VLR_UNIT_E,          ';
        v_sql := v_sql || 'A.COD_SITUACAO_B_E,    ';
        v_sql := v_sql || 'A.COD_ESTADO_E,        ';
        v_sql := v_sql || 'A.NUM_CONTROLE_DOCTO_E,';
        v_sql := v_sql || 'A.NUM_AUTENTIC_NFE_E,  ';

        v_sql := v_sql || 'A.BASE_ICMS_UNIT,      ';
        v_sql := v_sql || 'A.VLR_ICMS_UNIT,       ';
        v_sql := v_sql || 'A.ALIQ_ICMS,           ';
        v_sql := v_sql || 'A.BASE_ST_UNIT,        ';
        v_sql := v_sql || 'A.VLR_ICMS_ST_UNIT,    ';
        v_sql := v_sql || 'A.VLR_ICMS_ST_UNIT_AUX,';

        v_sql := v_sql || 'A.STAT_LIBER_CNTR 	  ';

        v_sql := v_sql || 'FROM ( ';

        v_sql := v_sql || ' SELECT ';
        v_sql := v_sql || ' ''' || vp_proc_id || ''' AS PROC_ID, ';
        v_sql := v_sql || ' ''' || mcod_empresa || ''' AS COD_EMPRESA, ';
        v_sql := v_sql || ' A.COD_ESTAB, ';
        v_sql := v_sql || ' A.NUM_DOCFIS, ';
        v_sql := v_sql || ' A.DATA_FISCAL, ';
        v_sql := v_sql || ' A.SERIE_DOCFIS, ';
        v_sql := v_sql || ' A.COD_PRODUTO, ';
        v_sql := v_sql || ' A.COD_ESTADO, ';
        v_sql := v_sql || ' A.DOCTO, ';
        v_sql := v_sql || ' A.NUM_ITEM, ';
        v_sql := v_sql || ' A.DESCR_ITEM, ';
        v_sql := v_sql || ' A.QUANTIDADE, ';
        v_sql := v_sql || ' A.COD_NBM, ';
        v_sql := v_sql || ' A.COD_CFO, ';
        v_sql := v_sql || ' A.GRUPO_PRODUTO, ';
        v_sql := v_sql || ' A.VLR_DESCONTO, ';
        v_sql := v_sql || ' A.VLR_CONTABIL, ';
        v_sql := v_sql || ' A.BASE_UNIT_S_VENDA, ';
        v_sql := v_sql || ' A.NUM_AUTENTIC_NFE, ';
        v_sql := v_sql || ' A.LISTA, ';
        ---
        v_sql := v_sql || ' B.COD_ESTAB AS COD_ESTAB_E, ';
        v_sql := v_sql || ' B.DATA_FISCAL AS DATA_FISCAL_E, ';
        v_sql := v_sql || ' B.MOVTO_E_S AS MOVTO_E_S_E, ';
        v_sql := v_sql || ' B.NORM_DEV AS NORM_DEV_E, ';
        v_sql := v_sql || ' B.IDENT_DOCTO AS IDENT_DOCTO_E, ';
        v_sql := v_sql || ' B.IDENT_FIS_JUR AS IDENT_FIS_JUR_E, ';
        v_sql := v_sql || ' B.SUB_SERIE_DOCFIS AS SUB_SERIE_DOCFIS_E, ';
        v_sql := v_sql || ' B.DISCRI_ITEM AS DISCRI_ITEM_E, ';
        v_sql := v_sql || ' B.DATA_EMISSAO AS DATA_EMISSAO_E, ';
        v_sql := v_sql || ' B.NUM_DOCFIS AS NUM_DOCFIS_E, ';
        v_sql := v_sql || ' B.SERIE_DOCFIS AS SERIE_DOCFIS_E, ';
        v_sql := v_sql || ' B.NUM_ITEM AS NUM_ITEM_E, ';
        v_sql := v_sql || ' B.COD_FIS_JUR AS COD_FIS_JUR_E, ';
        v_sql := v_sql || ' B.CPF_CGC AS CPF_CGC_E, ';
        v_sql := v_sql || ' B.COD_NBM AS COD_NBM_E, ';
        v_sql := v_sql || ' B.COD_CFO AS COD_CFO_E, ';
        v_sql := v_sql || ' B.COD_NATUREZA_OP AS COD_NATUREZA_OP_E, ';
        v_sql := v_sql || ' B.COD_PRODUTO AS COD_PRODUTO_E, ';
        v_sql := v_sql || ' B.VLR_CONTAB_ITEM AS VLR_CONTAB_ITEM_E, ';
        v_sql := v_sql || ' B.QUANTIDADE AS QUANTIDADE_E, ';
        v_sql := v_sql || ' B.VLR_UNIT AS VLR_UNIT_E, ';
        v_sql := v_sql || ' B.COD_SITUACAO_B AS COD_SITUACAO_B_E, ';
        v_sql := v_sql || ' B.COD_ESTADO AS COD_ESTADO_E, ';
        v_sql := v_sql || ' B.NUM_CONTROLE_DOCTO AS NUM_CONTROLE_DOCTO_E, ';
        v_sql := v_sql || ' B.NUM_AUTENTIC_NFE AS NUM_AUTENTIC_NFE_E, ';
        ---
        v_sql := v_sql || ' C.BASE_ICMS_UNIT, ';
        v_sql := v_sql || ' C.VLR_ICMS_UNIT, ';
        v_sql := v_sql || ' C.ALIQ_ICMS, ';
        v_sql := v_sql || ' C.BASE_ST_UNIT, ';
        v_sql := v_sql || ' C.VLR_ICMS_ST_UNIT, ';
        v_sql := v_sql || ' C.VLR_ICMS_ST_UNIT_AUX, ';
        ---
        v_sql :=
            v_sql || ' DECODE(E.LIBER_CNTR_DSP,''C'',''CONTROLADO'',''L'',''LIBERADO'',''OUTRO'') STAT_LIBER_CNTR ';
        ---
        v_sql := v_sql || ' FROM ' || vp_tabela_saida || ' A, ';
        v_sql := v_sql || '      ' || vp_tabela_entrada || ' B, ';
        v_sql := v_sql || '      ' || vp_tabela_nf || ' C, ';
        v_sql := v_sql || '      MSAFI.DSP_INTERFACE_SETUP D, ';
        v_sql := v_sql || '      MSAFI.PS_ATRB_OPER_DSP E ';
        v_sql := v_sql || ' WHERE A.PROC_ID       = ''' || vp_proc_id || ''' ';
        v_sql := v_sql || '   AND A.COD_EMPRESA   = ''' || mcod_empresa || ''' ';
        v_sql := v_sql || '   AND A.COD_ESTAB     = ''' || vp_filial || ''' ';
        v_sql :=
               v_sql
            || '   AND A.DATA_FISCAL   BETWEEN TO_DATE('''
            || vp_data_ini
            || ''',''DD/MM/YYYY'') AND TO_DATE('''
            || vp_data_fim
            || ''',''DD/MM/YYYY'') ';
        ---
        v_sql := v_sql || '   AND B.PROC_ID             = A.PROC_ID ';
        v_sql := v_sql || '   AND B.COD_EMPRESA         = A.COD_EMPRESA ';
        v_sql := v_sql || '   AND B.COD_ESTAB           = A.COD_ESTAB ';
        v_sql := v_sql || '   AND B.COD_PRODUTO         = A.COD_PRODUTO ';
        v_sql := v_sql || '   AND B.DATA_FISCAL_S       = A.DATA_FISCAL ';
        v_sql := v_sql || '   AND B.COD_FIS_JUR         = ''' || vp_cd || ''' ';
        ---
        v_sql := v_sql || '   AND D.COD_EMPRESA         = ''' || mcod_empresa || ''' ';
        v_sql := v_sql || '   AND A.PROC_ID             = C.PROC_ID ';
        v_sql := v_sql || '   AND D.BU_PO1              = C.BUSINESS_UNIT ';
        v_sql := v_sql || '   AND B.NUM_CONTROLE_DOCTO  = C.NF_BRL_ID ';
        v_sql := v_sql || '   AND B.NUM_ITEM            = C.NF_BRL_LINE_NUM ';
        ---
        v_sql := v_sql || '   AND E.SETID               = ''GERAL'' ';
        v_sql := v_sql || '   AND E.INV_ITEM_ID         = A.COD_PRODUTO ';
        ---
        v_sql := v_sql || '   AND NOT EXISTS (SELECT /*+PARALLEL_INDEX(C PK_DPSP_P_' || vp_proc_id || ', 6)*/ ''Y'' ';
        v_sql := v_sql || '                   FROM ' || vp_tabela_pmc_mva || ' C ';
        v_sql := v_sql || '                   WHERE C.PROC_ID      = A.PROC_ID ';
        v_sql := v_sql || '                     AND C.COD_EMPRESA  = A.COD_EMPRESA ';
        v_sql := v_sql || '                     AND C.COD_ESTAB    = A.COD_ESTAB ';
        v_sql := v_sql || '                     AND C.NUM_DOCFIS   = A.NUM_DOCFIS ';
        v_sql := v_sql || '                     AND C.DATA_FISCAL  = A.DATA_FISCAL ';
        v_sql := v_sql || '                     AND C.SERIE_DOCFIS = A.SERIE_DOCFIS ';
        v_sql := v_sql || '                     AND C.COD_PRODUTO  = A.COD_PRODUTO ';
        v_sql := v_sql || '                     AND C.COD_ESTADO   = A.COD_ESTADO ';
        v_sql := v_sql || '                     AND C.DOCTO        = A.DOCTO ';
        v_sql := v_sql || '                     AND C.NUM_ITEM     = A.NUM_ITEM) ';
        v_sql := v_sql || '   AND A.DATA_FISCAL > B.DATA_FISCAL ';
        v_sql := v_sql || '   ) A ) ';

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
                                      , vp_tabela_pmc_mva );
    --LOGA('C_ENTR_FILIAL-FIM-' || VP_CD || '->' || VP_FILIAL, FALSE);

    END; --GET_ENTRADAS_FILIAL

    PROCEDURE get_compra_direta ( vp_proc_id IN NUMBER
                                , vp_filial IN VARCHAR2
                                , vp_data_ini IN VARCHAR2
                                , vp_data_fim IN VARCHAR2
                                , vp_tabela_entrada IN VARCHAR2
                                , vp_tabela_saida IN VARCHAR2
                                , vp_tabela_nf IN VARCHAR2
                                , vp_tabela_pmc_mva IN VARCHAR2
                                , vp_data_hora_ini IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 6000 );
    BEGIN
        v_sql := 'INSERT /*+APPEND*/ INTO ' || vp_tabela_pmc_mva || ' (  ';
        --V_SQL := V_SQL || '   SELECT  /*+PARALLEL(12) ';
        v_sql := v_sql || ' SELECT  /*+INDEX(A, IDX8_DPSP_S_' || vp_proc_id || ')*/ ';
        v_sql := v_sql || ' ''' || vp_proc_id || ''' AS PROC_ID, ';
        v_sql := v_sql || ' ''' || mcod_empresa || ''' AS COD_EMPRESA, ';
        v_sql := v_sql || ' A.COD_ESTAB, ';
        v_sql := v_sql || ' A.NUM_DOCFIS, ';
        v_sql := v_sql || ' A.DATA_FISCAL, ';
        v_sql := v_sql || ' A.SERIE_DOCFIS, ';
        v_sql := v_sql || ' A.COD_PRODUTO, ';
        v_sql := v_sql || ' A.COD_ESTADO, ';
        v_sql := v_sql || ' A.DOCTO, ';
        v_sql := v_sql || ' A.NUM_ITEM, ';
        v_sql := v_sql || ' A.DESCR_ITEM, ';
        v_sql := v_sql || ' A.QUANTIDADE, ';
        v_sql := v_sql || ' A.COD_NBM, ';
        v_sql := v_sql || ' A.COD_CFO, ';
        v_sql := v_sql || ' A.GRUPO_PRODUTO, ';
        v_sql := v_sql || ' A.VLR_DESCONTO, ';
        v_sql := v_sql || ' A.VLR_CONTABIL, ';
        v_sql := v_sql || ' A.BASE_UNIT_S_VENDA, ';
        v_sql := v_sql || ' A.NUM_AUTENTIC_NFE, ';
        v_sql := v_sql || ' A.LISTA, ';
        ---
        v_sql := v_sql || ' B.COD_ESTAB, ';
        v_sql := v_sql || ' B.DATA_FISCAL, ';
        v_sql := v_sql || ' B.MOVTO_E_S, ';
        v_sql := v_sql || ' B.NORM_DEV, ';
        v_sql := v_sql || ' B.IDENT_DOCTO, ';
        v_sql := v_sql || ' B.IDENT_FIS_JUR, ';
        v_sql := v_sql || ' B.SUB_SERIE_DOCFIS, ';
        v_sql := v_sql || ' B.DISCRI_ITEM, ';
        v_sql := v_sql || ' B.DATA_EMISSAO, ';
        v_sql := v_sql || ' B.NUM_DOCFIS, ';
        v_sql := v_sql || ' B.SERIE_DOCFIS, ';
        v_sql := v_sql || ' B.NUM_ITEM, ';
        v_sql := v_sql || ' B.COD_FIS_JUR, ';
        v_sql := v_sql || ' B.CPF_CGC, ';
        v_sql := v_sql || ' B.COD_NBM, ';
        v_sql := v_sql || ' B.COD_CFO, ';
        v_sql := v_sql || ' B.COD_NATUREZA_OP, ';
        v_sql := v_sql || ' B.COD_PRODUTO, ';
        v_sql := v_sql || ' B.VLR_CONTAB_ITEM, ';
        v_sql := v_sql || ' B.QUANTIDADE, ';
        v_sql := v_sql || ' B.VLR_UNIT, ';
        v_sql := v_sql || ' B.COD_SITUACAO_B, ';
        v_sql := v_sql || ' B.COD_ESTADO, ';
        v_sql := v_sql || ' B.NUM_CONTROLE_DOCTO, ';
        v_sql := v_sql || ' B.NUM_AUTENTIC_NFE, ';
        ---
        v_sql := v_sql || ' C.BASE_ICMS_UNIT, ';
        v_sql := v_sql || ' C.VLR_ICMS_UNIT, ';
        v_sql := v_sql || ' C.ALIQ_ICMS, ';
        v_sql := v_sql || ' C.BASE_ST_UNIT, ';
        v_sql := v_sql || ' C.VLR_ICMS_ST_UNIT, ';
        v_sql := v_sql || ' C.VLR_ICMS_ST_UNIT_AUX, ';
        ---
        v_sql :=
            v_sql || ' DECODE(E.LIBER_CNTR_DSP,''C'',''CONTROLADO'',''L'',''LIBERADO'',''OUTRO'') STAT_LIBER_CNTR ';
        ---
        v_sql := v_sql || ' FROM ' || vp_tabela_saida || ' A, ';
        v_sql := v_sql || ' (   SELECT RANK() OVER(PARTITION BY COD_PRODUTO ';
        v_sql :=
               v_sql
            || '                        ORDER BY DATA_FISCAL DESC, DATA_EMISSAO DESC, NUM_DOCFIS DESC, DISCRI_ITEM DESC) RANK, ';
        v_sql := v_sql || '     A.COD_EMPRESA, ';
        v_sql := v_sql || '     A.PROC_ID, ';
        v_sql := v_sql || '     A.COD_ESTAB, ';
        v_sql := v_sql || '     A.DATA_FISCAL, ';
        v_sql := v_sql || '     A.MOVTO_E_S, ';
        v_sql := v_sql || '     A.NORM_DEV, ';
        v_sql := v_sql || '     A.IDENT_DOCTO, ';
        v_sql := v_sql || '     A.IDENT_FIS_JUR, ';
        v_sql := v_sql || '     A.SUB_SERIE_DOCFIS, ';
        v_sql := v_sql || '     A.DISCRI_ITEM, ';
        v_sql := v_sql || '     A.DATA_FISCAL_S, ';
        v_sql := v_sql || '     A.COD_PRODUTO, ';
        v_sql := v_sql || '     A.DATA_EMISSAO, ';
        v_sql := v_sql || '     A.NUM_DOCFIS, ';
        v_sql := v_sql || '     A.SERIE_DOCFIS, ';
        v_sql := v_sql || '     A.COD_FIS_JUR, ';
        v_sql := v_sql || '     A.CPF_CGC, ';
        v_sql := v_sql || '     A.COD_NBM, ';
        v_sql := v_sql || '     A.COD_CFO, ';
        v_sql := v_sql || '     A.COD_NATUREZA_OP, ';
        v_sql := v_sql || '     A.VLR_CONTAB_ITEM, ';
        v_sql := v_sql || '     A.QUANTIDADE, ';
        v_sql := v_sql || '     A.VLR_UNIT, ';
        v_sql := v_sql || '     A.COD_SITUACAO_B, ';
        v_sql := v_sql || '     A.COD_ESTADO, ';
        v_sql := v_sql || '     A.NUM_ITEM, ';
        v_sql := v_sql || '     A.NUM_CONTROLE_DOCTO, ';
        v_sql := v_sql || '     A.NUM_AUTENTIC_NFE ';
        v_sql := v_sql || '     FROM ' || vp_tabela_entrada || ' A ';
        v_sql := v_sql || '     WHERE A.PROC_ID       = ''' || vp_proc_id || ''' ';
        v_sql := v_sql || '       AND A.COD_ESTAB     = ''' || vp_filial || ''' ';
        v_sql := v_sql || '       AND A.COD_CFO       IN    (''1102'',''2102'',''1403'',''2403'',''1910'',''2910'') ';
        v_sql := v_sql || '       AND ((A.CPF_CGC NOT LIKE ''61412110%'' AND A.COD_EMPRESA = ''DSP'') '; --FORNECEDOR DSP
        v_sql := v_sql || '        OR  (A.CPF_CGC NOT LIKE ''334382500%'' AND A.COD_EMPRESA = ''DP'')) '; --FORNECEDOR DP
        v_sql := v_sql || '       AND A.NUM_CONTROLE_DOCTO NOT LIKE ''C%'') B, '; --RETIRAR CELULA
        v_sql := v_sql || ' ' || vp_tabela_nf || ' C, ';
        v_sql := v_sql || ' MSAFI.DSP_INTERFACE_SETUP D, ';
        v_sql := v_sql || ' MSAFI.PS_ATRB_OPER_DSP E ';
        v_sql := v_sql || ' WHERE A.PROC_ID       = ''' || vp_proc_id || ''' ';
        v_sql := v_sql || '   AND A.COD_EMPRESA   = ''' || mcod_empresa || ''' ';
        v_sql := v_sql || '   AND A.COD_ESTAB     = ''' || vp_filial || ''' ';
        v_sql :=
               v_sql
            || '   AND A.DATA_FISCAL   BETWEEN TO_DATE('''
            || vp_data_ini
            || ''',''DD/MM/YYYY'') AND TO_DATE('''
            || vp_data_fim
            || ''',''DD/MM/YYYY'') ';
        ---
        v_sql := v_sql || '   AND A.PROC_ID       = B.PROC_ID ';
        v_sql := v_sql || '   AND A.COD_EMPRESA   = B.COD_EMPRESA ';
        v_sql := v_sql || '   AND A.COD_ESTAB     = B.COD_ESTAB ';
        v_sql := v_sql || '   AND A.COD_PRODUTO   = B.COD_PRODUTO ';
        v_sql := v_sql || '   AND A.DATA_FISCAL   > B.DATA_FISCAL ';
        v_sql := v_sql || '   AND B.DATA_FISCAL_S = A.DATA_FISCAL ';
        v_sql := v_sql || '   AND B.RANK = 1 ';
        ---
        v_sql := v_sql || '   AND D.COD_EMPRESA        = ''' || mcod_empresa || ''' ';
        v_sql := v_sql || '   AND A.PROC_ID            = C.PROC_ID ';
        v_sql := v_sql || '   AND D.BU_PO1             = C.BUSINESS_UNIT ';
        v_sql := v_sql || '   AND B.NUM_CONTROLE_DOCTO = C.NF_BRL_ID ';
        v_sql := v_sql || '   AND B.NUM_ITEM           = C.NF_BRL_LINE_NUM ';
        ---
        v_sql := v_sql || '   AND E.SETID              = ''GERAL'' ';
        v_sql := v_sql || '   AND E.INV_ITEM_ID        = A.COD_PRODUTO ';
        ---
        v_sql := v_sql || '   AND NOT EXISTS (SELECT /*+PARALLEL_INDEX(C PK_DPSP_P_' || vp_proc_id || ', 6)*/ ''Y'' ';
        v_sql := v_sql || '                     FROM ' || vp_tabela_pmc_mva || ' C ';
        v_sql := v_sql || '                    WHERE C.PROC_ID      = A.PROC_ID ';
        v_sql := v_sql || '                      AND C.COD_EMPRESA  = A.COD_EMPRESA ';
        v_sql := v_sql || '                      AND C.COD_ESTAB    = A.COD_ESTAB ';
        v_sql := v_sql || '                      AND C.NUM_DOCFIS   = A.NUM_DOCFIS ';
        v_sql := v_sql || '                      AND C.DATA_FISCAL  = A.DATA_FISCAL ';
        v_sql := v_sql || '                      AND C.SERIE_DOCFIS = A.SERIE_DOCFIS ';
        v_sql := v_sql || '                      AND C.COD_PRODUTO  = A.COD_PRODUTO ';
        v_sql := v_sql || '                      AND C.COD_ESTADO   = A.COD_ESTADO ';
        v_sql := v_sql || '                      AND C.DOCTO        = A.DOCTO ';
        v_sql := v_sql || '                      AND C.NUM_ITEM     = A.NUM_ITEM)) ';

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
                                        , '!ERRO INSERT GET_COMPRA_DIRETA!' );
        END;

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_tabela_pmc_mva );
    --LOGA('C_COMPRA_DIRETA-FIM-' || VP_FILIAL, FALSE);

    END; --GET_COMPRA_DIRETA

    PROCEDURE get_sem_entrada ( vp_proc_id IN NUMBER
                              , vp_filial IN VARCHAR2
                              , vp_data_ini IN VARCHAR2
                              , vp_data_fim IN VARCHAR2
                              , vp_tabela_saida IN VARCHAR2
                              , vp_tabela_pmc_mva IN VARCHAR2
                              , vp_data_hora_ini IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 4000 );
    BEGIN
        v_sql := 'INSERT /*+APPEND*/ INTO ' || vp_tabela_pmc_mva || ' ( ';
        --V_SQL := V_SQL || '   SELECT  /*+PARALLEL(12) ';
        v_sql := v_sql || ' SELECT  /*+INDEX(A, IDX8_DPSP_S_' || vp_proc_id || ')*/ ';
        v_sql := v_sql || '         ''' || vp_proc_id || ''', ';
        v_sql := v_sql || '         ''' || mcod_empresa || ''', ';
        v_sql := v_sql || '         A.COD_ESTAB,';
        v_sql := v_sql || '         A.NUM_DOCFIS,';
        v_sql := v_sql || '         A.DATA_FISCAL,';
        v_sql := v_sql || '         A.SERIE_DOCFIS,';
        v_sql := v_sql || '         A.COD_PRODUTO,';
        v_sql := v_sql || '         A.COD_ESTADO,';
        v_sql := v_sql || '         A.DOCTO,';
        v_sql := v_sql || '         A.NUM_ITEM,';
        v_sql := v_sql || '         A.DESCR_ITEM,';
        v_sql := v_sql || '         A.QUANTIDADE,';
        v_sql := v_sql || '         A.COD_NBM,';
        v_sql := v_sql || '         A.COD_CFO,';
        v_sql := v_sql || '         A.GRUPO_PRODUTO,';
        v_sql := v_sql || '         A.VLR_DESCONTO,';
        v_sql := v_sql || '         A.VLR_CONTABIL,';
        v_sql := v_sql || '         A.BASE_UNIT_S_VENDA,';
        v_sql := v_sql || '         A.NUM_AUTENTIC_NFE,';
        v_sql := v_sql || '         A.LISTA,';
        v_sql := v_sql || '         '''','; --B.COD_ESTAB,
        v_sql := v_sql || '         NULL,'; --B.DATA_FISCAL,
        v_sql := v_sql || '         '''','; --B.MOVTO_E_S,
        v_sql := v_sql || '         '''','; --B.NORM_DEV,
        v_sql := v_sql || '         '''','; --B.IDENT_DOCTO,
        v_sql := v_sql || '         '''','; --B.IDENT_FIS_JUR,
        v_sql := v_sql || '         '''','; --B.SUB_SERIE_DOCFIS,
        v_sql := v_sql || '         '''','; --B.DISCRI_ITEM,
        v_sql := v_sql || '         NULL,'; --B.DATA_EMISSAO,
        v_sql := v_sql || '         '''','; --B.NUM_DOCFIS,
        v_sql := v_sql || '         '''','; --B.SERIE_DOCFIS,
        v_sql := v_sql || '         0,   '; --B.NUM_ITEM,
        v_sql := v_sql || '         '''','; --B.COD_FIS_JUR,
        v_sql := v_sql || '         '''','; --B.CPF_CGC,
        v_sql := v_sql || '         '''','; --B.COD_NBM,
        v_sql := v_sql || '         '''','; --B.COD_CFO,
        v_sql := v_sql || '         '''','; --B.COD_NATUREZA_OP,
        v_sql := v_sql || '         '''','; --B.COD_PRODUTO,
        v_sql := v_sql || '         0,   '; --B.VLR_CONTAB_ITEM,
        v_sql := v_sql || '         0,   '; --B.QUANTIDADE,
        v_sql := v_sql || '         0,   '; --B.VLR_UNIT,
        v_sql := v_sql || '         '''','; --B.COD_SITUACAO_B,
        v_sql := v_sql || '         '''','; --B.COD_ESTADO,
        v_sql := v_sql || '         '''','; --B.NUM_CONTROLE_DOCTO,
        v_sql := v_sql || '         '''','; --B.NUM_AUTENTIC_NFE,
        v_sql := v_sql || '         0,   '; --BASE_ICMS_UNIT,
        v_sql := v_sql || '         0,   '; --VLR_ICMS_UNIT,
        v_sql := v_sql || '         0,   '; --ALIQ_ICMS,
        v_sql := v_sql || '         0,   '; --BASE_ST_UNIT,
        v_sql := v_sql || '         0,   '; --VLR_ICMS_ST_UNIT
        v_sql := v_sql || '         0,   '; --VLR_ICMS_ST_UNIT_AUX
        v_sql := v_sql || '         '''' '; --STAT_LIBER_CNTR
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
        v_sql := v_sql || '   AND NOT EXISTS (SELECT /*+PARALLEL_INDEX(C PK_DPSP_P_' || vp_proc_id || ', 6)*/ ''Y'' ';
        v_sql := v_sql || '                 FROM ' || vp_tabela_pmc_mva || ' C ';
        v_sql := v_sql || '                 WHERE C.PROC_ID      = A.PROC_ID';
        v_sql := v_sql || '                   AND C.COD_EMPRESA  = A.COD_EMPRESA';
        v_sql := v_sql || '                   AND C.COD_ESTAB    = A.COD_ESTAB';
        v_sql := v_sql || '                   AND C.NUM_DOCFIS   = A.NUM_DOCFIS';
        v_sql := v_sql || '                   AND C.DATA_FISCAL  = A.DATA_FISCAL';
        v_sql := v_sql || '                   AND C.SERIE_DOCFIS = A.SERIE_DOCFIS';
        v_sql := v_sql || '                   AND C.COD_PRODUTO  = A.COD_PRODUTO';
        v_sql := v_sql || '                   AND C.COD_ESTADO   = A.COD_ESTADO';
        v_sql := v_sql || '                   AND C.DOCTO        = A.DOCTO';
        v_sql := v_sql || '                   AND C.NUM_ITEM     = A.NUM_ITEM)) ';

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
                                      , vp_tabela_pmc_mva );
    --LOGA('C_SEM_ENTRADA-FIM-' || VP_FILIAL, FALSE);

    END; --GET_SEM_ENTRADA

    PROCEDURE load_nf_people ( vp_proc_id IN VARCHAR2
                             , vp_cod_empresa IN VARCHAR2
                             , vp_tab_entrada_c IN VARCHAR2
                             , vp_tab_entrada_f IN VARCHAR2
                             , vp_tab_entrada_co IN VARCHAR2
                             , vp_tabela_nf   OUT VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 4000 );
        v_insert VARCHAR2 ( 500 );
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
        v_sql := v_sql || ' BASE_ICMS_UNIT       NUMBER(17,2), ';
        v_sql := v_sql || ' VLR_ICMS_UNIT        NUMBER(17,2), ';
        v_sql := v_sql || ' ALIQ_ICMS            NUMBER(17,2), ';
        v_sql := v_sql || ' BASE_ST_UNIT         NUMBER(17,2), ';
        v_sql := v_sql || ' VLR_ICMS_ST_UNIT     NUMBER(17,2), ';
        v_sql := v_sql || ' VLR_ICMS_ST_UNIT_AUX NUMBER(17,2)) ';
        v_sql := v_sql || ' PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        IF ( vp_tab_entrada_c IS NOT NULL ) THEN
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
            v_sql := v_sql || '         FROM ' || vp_tab_entrada_c || ' A, ';
            v_sql := v_sql || '              MSAFI.DSP_INTERFACE_SETUP B, ';
            v_sql := v_sql || '             (SELECT C.BUSINESS_UNIT, ';
            v_sql := v_sql || '                     C.NF_BRL_ID, ';
            v_sql := v_sql || '                     C.NF_BRL_LINE_NUM, ';
            v_sql :=
                v_sql || '                     NVL(TRUNC(C.ICMSTAX_BRL_BSS/C.QTY_NF_BRL, 2), 0) AS BASE_ICMS_UNIT, ';
            v_sql :=
                v_sql || '                     NVL(TRUNC(C.ICMSTAX_BRL_AMT/C.QTY_NF_BRL, 2), 0) AS VLR_ICMS_UNIT, ';
            v_sql := v_sql || '                     NVL(C.ICMSTAX_BRL_PCT, 0) AS ALIQ_ICMS,  ';
            v_sql :=
                   v_sql
                || '                     TRUNC(DECODE(NVL(C.DSP_ICMS_BSS_ST, 0), 0, NVL(C.DSP_ICMSSUBBRL_BSS, 0), NVL(C.DSP_ICMS_BSS_ST, 0))/C.QTY_NF_BRL, 2) AS BASE_ST_UNIT, ';
            v_sql :=
                   v_sql
                || '                     TRUNC(DECODE(NVL(C.DSP_ICMS_AMT_ST, 0), 0, NVL(C.DSP_ICMSSUBBRL_AMT, 0), NVL(C.DSP_ICMS_AMT_ST, 0))/C.QTY_NF_BRL, 2) AS VLR_ICMS_ST_UNIT, ';
            v_sql :=
                   v_sql
                || '                     TRUNC(NVL(C.ICMSSUB_BRL_AMT,0)/C.QTY_NF_BRL, 2) AS VLR_ICMS_ST_UNIT_AUX ';
            v_sql := v_sql || '              FROM MSAFI.PS_NF_LN_BRL C ) C ';
            v_sql := v_sql || '         WHERE A.PROC_ID             = ''' || vp_proc_id || ''' ';
            v_sql := v_sql || '           AND A.COD_EMPRESA         = ''' || vp_cod_empresa || ''' ';
            v_sql := v_sql || '           AND B.COD_EMPRESA         = A.COD_EMPRESA ';
            v_sql := v_sql || '           AND C.BUSINESS_UNIT       = B.BU_PO1 ';
            v_sql := v_sql || '           AND C.NF_BRL_ID           = A.NUM_CONTROLE_DOCTO ';
            v_sql := v_sql || '           AND C.NF_BRL_LINE_NUM     = A.NUM_ITEM ';
            v_sql := v_sql || '     ) A ';

            OPEN c_nf FOR v_sql;

            LOOP
                FETCH c_nf
                    BULK COLLECT INTO tab_nf
                    LIMIT 100;

                FOR i IN 1 .. tab_nf.COUNT LOOP
                    v_insert :=
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

                    EXECUTE IMMEDIATE v_insert;
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
                v_sql || '                     NVL(TRUNC(C.ICMSTAX_BRL_BSS/C.QTY_NF_BRL, 2), 0) AS BASE_ICMS_UNIT, ';
            v_sql :=
                v_sql || '                     NVL(TRUNC(C.ICMSTAX_BRL_AMT/C.QTY_NF_BRL, 2), 0) AS VLR_ICMS_UNIT, ';
            v_sql := v_sql || '                     NVL(C.ICMSTAX_BRL_PCT, 0) AS ALIQ_ICMS,  ';
            v_sql :=
                   v_sql
                || '                     TRUNC(DECODE(NVL(C.DSP_ICMS_BSS_ST, 0), 0, NVL(C.DSP_ICMSSUBBRL_BSS, 0), NVL(C.DSP_ICMS_BSS_ST, 0))/C.QTY_NF_BRL, 2) AS BASE_ST_UNIT, ';
            v_sql :=
                   v_sql
                || '                     TRUNC(DECODE(NVL(C.DSP_ICMS_AMT_ST, 0), 0, NVL(C.DSP_ICMSSUBBRL_AMT, 0), NVL(C.DSP_ICMS_AMT_ST, 0))/C.QTY_NF_BRL, 2) AS VLR_ICMS_ST_UNIT, ';
            v_sql :=
                   v_sql
                || '                     TRUNC(NVL(C.ICMSSUB_BRL_AMT,0)/C.QTY_NF_BRL, 2) AS VLR_ICMS_ST_UNIT_AUX ';
            v_sql := v_sql || '              FROM MSAFI.PS_NF_LN_BRL C ) C ';
            v_sql := v_sql || '         WHERE A.PROC_ID             = ''' || vp_proc_id || ''' ';
            v_sql := v_sql || '           AND A.COD_EMPRESA         = ''' || vp_cod_empresa || ''' ';
            v_sql := v_sql || '           AND B.COD_EMPRESA         = A.COD_EMPRESA ';
            v_sql := v_sql || '           AND C.BUSINESS_UNIT       = B.BU_PO1 ';
            v_sql := v_sql || '           AND C.NF_BRL_ID           = A.NUM_CONTROLE_DOCTO ';
            v_sql := v_sql || '           AND C.NF_BRL_LINE_NUM     = A.NUM_ITEM ';
            v_sql := v_sql || '     ) A ';

            OPEN c_nf FOR v_sql;

            LOOP
                FETCH c_nf
                    BULK COLLECT INTO tab_nf
                    LIMIT 100;

                FOR i IN 1 .. tab_nf.COUNT LOOP
                    v_insert :=
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

                    EXECUTE IMMEDIATE v_insert;
                END LOOP;

                tab_nf.delete;

                EXIT WHEN c_nf%NOTFOUND;
            END LOOP;

            COMMIT;

            CLOSE c_nf;
        END IF; --IF (VP_TAB_ENTRADA_F IS NOT NULL) THEN

        IF ( vp_tab_entrada_co IS NOT NULL ) THEN
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
            v_sql := v_sql || '         FROM ' || vp_tab_entrada_co || ' A, ';
            v_sql := v_sql || '              MSAFI.DSP_INTERFACE_SETUP B, ';
            v_sql := v_sql || '             (SELECT C.BUSINESS_UNIT, ';
            v_sql := v_sql || '                     C.NF_BRL_ID, ';
            v_sql := v_sql || '                     C.NF_BRL_LINE_NUM, ';
            v_sql :=
                v_sql || '                     NVL(TRUNC(C.ICMSTAX_BRL_BSS/C.QTY_NF_BRL, 2), 0) AS BASE_ICMS_UNIT, ';
            v_sql :=
                v_sql || '                     NVL(TRUNC(C.ICMSTAX_BRL_AMT/C.QTY_NF_BRL, 2), 0) AS VLR_ICMS_UNIT, ';
            v_sql := v_sql || '                     NVL(C.ICMSTAX_BRL_PCT, 0) AS ALIQ_ICMS,  ';
            v_sql :=
                   v_sql
                || '                     TRUNC(DECODE(NVL(C.DSP_ICMS_BSS_ST, 0), 0, NVL(C.DSP_ICMSSUBBRL_BSS, 0), NVL(C.DSP_ICMS_BSS_ST, 0))/C.QTY_NF_BRL, 2) AS BASE_ST_UNIT, ';
            v_sql :=
                   v_sql
                || '                     TRUNC(DECODE(NVL(C.DSP_ICMS_AMT_ST, 0), 0, NVL(C.DSP_ICMSSUBBRL_AMT, 0), NVL(C.DSP_ICMS_AMT_ST, 0))/C.QTY_NF_BRL, 2) AS VLR_ICMS_ST_UNIT, ';
            v_sql :=
                   v_sql
                || '                     TRUNC(NVL(C.ICMSSUB_BRL_AMT,0)/C.QTY_NF_BRL, 2) AS VLR_ICMS_ST_UNIT_AUX ';
            v_sql := v_sql || '              FROM MSAFI.PS_NF_LN_BRL C ) C ';
            v_sql := v_sql || '         WHERE A.PROC_ID             = ''' || vp_proc_id || ''' ';
            v_sql := v_sql || '           AND A.COD_EMPRESA         = ''' || vp_cod_empresa || ''' ';
            v_sql := v_sql || '           AND B.COD_EMPRESA         = A.COD_EMPRESA ';
            v_sql := v_sql || '           AND C.BUSINESS_UNIT       = B.BU_PO1 ';
            v_sql := v_sql || '           AND C.NF_BRL_ID           = A.NUM_CONTROLE_DOCTO ';
            v_sql := v_sql || '           AND C.NF_BRL_LINE_NUM     = A.NUM_ITEM ';
            v_sql := v_sql || '     ) A ';

            OPEN c_nf FOR v_sql;

            LOOP
                FETCH c_nf
                    BULK COLLECT INTO tab_nf
                    LIMIT 100;

                FOR i IN 1 .. tab_nf.COUNT LOOP
                    v_insert :=
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

                    EXECUTE IMMEDIATE v_insert;
                END LOOP;

                tab_nf.delete;

                EXIT WHEN c_nf%NOTFOUND;
            END LOOP;

            COMMIT;

            CLOSE c_nf;
        END IF; --IF (VP_TAB_ENTRADA_CO IS NOT NULL) THEN

        v_sql := 'CREATE UNIQUE INDEX PK_DPSP_NF_' || vp_proc_id || ' ON ' || vp_tabela_nf || ' ';
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || ' PROC_ID         ASC, ';
        v_sql := v_sql || ' BUSINESS_UNIT   ASC, ';
        v_sql := v_sql || ' NF_BRL_ID       ASC, ';
        v_sql := v_sql || ' NF_BRL_LINE_NUM ASC ';
        v_sql := v_sql || ' ) ';
        v_sql := v_sql || ' PCTFREE 10';

        EXECUTE IMMEDIATE v_sql;

        save_tmp_control ( vp_proc_id
                         , vp_tabela_nf );
        ---
        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_tabela_nf );
        loga ( 'NF PEOPLE-FIM'
             , FALSE );
    END;

    PROCEDURE delete_tbl ( p_i_cod_estab IN VARCHAR2
                         , p_i_data_ini IN DATE
                         , p_i_data_fim IN DATE )
    IS
    BEGIN
        DELETE msafi.dpsp_msaf_pmc_mva
         WHERE cod_empresa = mcod_empresa
           AND cod_estab = p_i_cod_estab
           AND data_fiscal BETWEEN p_i_data_ini AND p_i_data_fim;

        COMMIT;
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

    ---ATUALIZAR LISTA DE MEDICAMENTO
    PROCEDURE atualiza_lista
    IS
    BEGIN
        MERGE INTO dpsp_ps_lista l
             USING (SELECT a.inv_item_id cod_produto
                         , a.class_pis_dsp lista
                         , a.effdt
                      FROM msafi.ps_atrb_op_eff_dsp a
                     WHERE a.setid = 'GERAL'
                       AND a.class_pis_dsp IN ( 'N'
                                              , 'P'
                                              , 'O' )
                       AND ( a.inv_item_id
                           , a.effdt ) NOT IN ( SELECT cod_produto
                                                     , effdt
                                                  FROM dpsp_ps_lista )) c
                ON ( l.cod_produto = c.cod_produto
                AND l.effdt = l.effdt )
        WHEN MATCHED THEN
            UPDATE SET l.lista = c.lista
        WHEN NOT MATCHED THEN
            INSERT     VALUES ( c.cod_produto
                              , c.lista
                              , c.effdt );

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            NULL;
    END atualiza_lista;

    --PROC PARA DIMINUIR O VOLUME DE PESQUISA DE ULTIMA ENTRADA
    PROCEDURE limpa_tab_saida_sintetico_cd ( vp_cd IN VARCHAR2
                                           , vp_tab_entrada_cd IN VARCHAR2
                                           , vp_qtde_saida_s1 IN OUT NUMBER
                                           , vp_tabela_saida_s1 IN VARCHAR2 )
    IS
        v_qtde_ini1 NUMBER := 0;
    BEGIN
        IF ( vp_tab_entrada_cd <> ' ' ) THEN
            EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || vp_tabela_saida_s1            INTO v_qtde_ini1;

            EXECUTE IMMEDIATE
                   'DELETE '
                || vp_tabela_saida_s1
                || ' S WHERE EXISTS (SELECT ''Y'' '
                || ' FROM '
                || vp_tab_entrada_cd
                || ' E '
                || ' WHERE E.COD_PRODUTO 	 = S.COD_PRODUTO '
                || '   AND E.DATA_FISCAL_S = S.DATA_FISCAL_S '
                || '   AND E.COD_ESTAB     = '''
                || vp_cd
                || ''') ';

            COMMIT;

            dbms_stats.gather_table_stats ( 'MSAF'
                                          , vp_tabela_saida_s1 );

            EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || vp_tabela_saida_s1            INTO vp_qtde_saida_s1;

            ----
            loga ( 'S1 INI: ' || v_qtde_ini1 || ' FIM: ' || vp_qtde_saida_s1
                 , FALSE );
        END IF;
    END;

    --PROC PARA DIMINUIR O VOLUME DE PESQUISA DE ULTIMA ENTRADA
    PROCEDURE limpa_tab_saida_sintetico_fil ( vp_cod_estab IN VARCHAR2
                                            , vp_tab_entrada_f IN VARCHAR2
                                            , vp_tabela_saida_s2 IN VARCHAR2 )
    IS
    BEGIN
        IF ( vp_tab_entrada_f <> ' ' ) THEN
            EXECUTE IMMEDIATE
                   'DELETE '
                || vp_tabela_saida_s2
                || ' S WHERE S.COD_ESTAB = '''
                || vp_cod_estab
                || ''' AND EXISTS (SELECT ''Y'' '
                || ' FROM '
                || vp_tab_entrada_f
                || ' E '
                || ' WHERE E.COD_PRODUTO   = S.COD_PRODUTO '
                || '   AND E.DATA_FISCAL_S = S.DATA_FISCAL_S '
                || '   AND E.COD_ESTAB     = S.COD_ESTAB) ';

            COMMIT;

            dbms_stats.gather_table_stats ( 'MSAF'
                                          , vp_tabela_saida_s2 );
        END IF;
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
                      , p_compra_direta VARCHAR2
                      , p_uf VARCHAR2
                      , p_lojas lib_proc.vartab )
        RETURN INTEGER
    IS
        mproc_id INTEGER;
        i1 INTEGER;

        v_proc_status NUMBER := 0;
        v_s_proc_status VARCHAR2 ( 16 );

        v_txt_temp VARCHAR2 ( 1024 ) := '';
        v_txt_basico VARCHAR2 ( 256 ) := '';

        TYPE a_estabs_t IS TABLE OF VARCHAR2 ( 6 );

        a_estabs a_estabs_t := a_estabs_t ( );
        a_estab_part a_estabs_t := a_estabs_t ( );

        --Variaveis genericas
        v_text01 VARCHAR2 ( 6000 );
        v_sep VARCHAR2 ( 1 ) := CHR ( 9 );
        p_proc_instance VARCHAR2 ( 30 );

        --
        TYPE cur_typ IS REF CURSOR;

        cr_cup cur_typ;
        --
        v_icms_auxiliar NUMBER;
        v_st_cod_tributo VARCHAR2 ( 6 );
        v_st_cod_tributacao NUMBER ( 1 );
        v_st_vlr_base NUMBER ( 20 );
        --
        v_aliq_st VARCHAR2 ( 5 ) := '';
        v_pmc NUMBER := 0;
        v_liber_cntr VARCHAR2 ( 10 ) := '';
        --TABELAS TEMP
        v_nome_tabela_aliq VARCHAR2 ( 30 );
        v_nome_tabela_pmc VARCHAR2 ( 30 );
        v_tab_entrada_c VARCHAR2 ( 30 ) := '';
        v_tab_entrada_f VARCHAR2 ( 30 ) := '';
        v_tab_entrada_co VARCHAR2 ( 30 ) := '';
        v_tabela_saida VARCHAR2 ( 30 );
        v_tabela_saida_s1 VARCHAR2 ( 30 ); --SINTETICO SEM COD_ESTAB
        v_tabela_saida_s2 VARCHAR2 ( 30 ); --SINTETICO COM COD_ESTAB
        v_tabela_nf VARCHAR2 ( 30 );
        v_tabela_pmc_mva VARCHAR2 ( 30 );
        ---
        v_sql_resultado VARCHAR2 ( 4000 );
        v_sql VARCHAR2 ( 4000 );
        v_insert VARCHAR2 ( 5000 );
        v_data_hora_ini VARCHAR2 ( 20 );
        v_qtde_saida_s1 NUMBER := 0;
        v_qtde_saida_s2 NUMBER := 0;
        errors NUMBER;
        dml_errors EXCEPTION;

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

        c_pmc_mva SYS_REFCURSOR;

        TYPE cur_tab_pmc_mva IS RECORD
        (
            cod_empresa VARCHAR2 ( 3 )
          , cod_estab VARCHAR2 ( 6 )
          , num_docfis VARCHAR2 ( 12 )
          , data_fiscal DATE
          , cod_produto VARCHAR2 ( 35 )
          , cod_estado VARCHAR2 ( 2 )
          , docto VARCHAR2 ( 5 )
          , num_item NUMBER ( 5 )
          , descr_item VARCHAR2 ( 50 )
          , quantidade NUMBER ( 12, 4 )
          , cod_nbm VARCHAR2 ( 10 )
          , cod_cfo VARCHAR2 ( 4 )
          , grupo_produto VARCHAR2 ( 30 )
          , vlr_desconto NUMBER ( 17, 2 )
          , vlr_contabil NUMBER ( 17, 2 )
          , base_unit_s_venda NUMBER ( 17, 2 )
          , num_autentic_nfe VARCHAR2 ( 80 )
          , ---
            cod_estab_e VARCHAR2 ( 6 )
          , data_fiscal_e DATE
          , movto_e_s_e VARCHAR2 ( 1 )
          , norm_dev_e VARCHAR2 ( 1 )
          , ident_docto_e VARCHAR2 ( 12 )
          , ident_fis_jur_e VARCHAR2 ( 12 )
          , sub_serie_docfis_e VARCHAR2 ( 2 )
          , discri_item_e VARCHAR2 ( 46 )
          , data_emissao_e DATE
          , num_docfis_e VARCHAR2 ( 12 )
          , serie_docfis_e VARCHAR2 ( 3 )
          , num_item_e NUMBER ( 5 )
          , cod_fis_jur_e VARCHAR2 ( 14 )
          , cpf_cgc_e VARCHAR2 ( 14 )
          , cod_nbm_e VARCHAR2 ( 10 )
          , cod_cfo_e VARCHAR2 ( 4 )
          , cod_natureza_op_e VARCHAR2 ( 3 )
          , cod_produto_e VARCHAR2 ( 35 )
          , vlr_contab_item_e NUMBER ( 17, 2 )
          , quantidade_e NUMBER ( 12, 4 )
          , vlr_unit_e NUMBER ( 17, 2 )
          , cod_situacao_b_e VARCHAR2 ( 2 )
          , cod_estado_e VARCHAR2 ( 2 )
          , num_controle_docto_e VARCHAR2 ( 12 )
          , num_autentic_nfe_e VARCHAR2 ( 80 )
          , base_icms_unit_e NUMBER ( 17, 2 )
          , vlr_icms_unit_e NUMBER ( 17, 2 )
          , aliq_icms_e NUMBER ( 17, 2 )
          , base_st_unit_e NUMBER ( 17, 2 )
          , vlr_icms_st_unit_e NUMBER ( 17, 2 )
          , stat_liber_cntr VARCHAR2 ( 10 )
          , id_aliq_st VARCHAR2 ( 10 )
          , vlr_pmc NUMBER ( 17, 2 )
          , vlr_icms_aux NUMBER ( 17, 2 )
          , vlr_icms_bruto NUMBER ( 17, 2 )
          , vlr_icms_s_venda NUMBER ( 17, 2 )
          , vlr_dif_qtde NUMBER ( 17, 2 )
          , deb_cred VARCHAR2 ( 8 )
          , usuario VARCHAR2 ( 40 )
          , dat_operacao DATE
          , serie_docfis VARCHAR2 ( 3 )
          , vlr_icms_st_unit_aux NUMBER ( 17, 2 )
          , lista VARCHAR2 ( 1 )
        );

        TYPE c_tab_pmc_mva IS TABLE OF cur_tab_pmc_mva;

        tab_pmc_mva c_tab_pmc_mva;
    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS='',.'' ';

        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        musuario := lib_parametros.recuperar ( 'USUARIO' );

        mproc_id_o :=
            lib_proc.new ( 'DPSP_PMC_X_MVA_CPROC'
                         , 48
                         , 150 );
        lib_proc.add_tipo ( mproc_id_o
                          , 1
                          ,    TO_CHAR ( SYSDATE
                                       , 'YYYYMMDDHH24MISS' )
                            || '_RESSARCIMENTO_PMC_x_MVA'
                          , 1 );

        --MARCAR INCIO DA EXECUCAO
        v_data_hora_ini :=
            TO_CHAR ( SYSDATE
                    , 'DD/MM/YYYY HH24:MI.SS' );

        lib_proc.add_header ( 'Executar processamento do ressarcimento PMC x MVA'
                            , 1
                            , 1 );
        lib_proc.add ( ' ' );

        IF mcod_empresa IS NULL THEN
            lib_proc.add_log ( 'Código da empresa deve ser informado como parâmetro global.'
                             , 0 );
            lib_proc.add ( 'ERRO' );
            lib_proc.add ( 'CÓDIGO DA EMPRESA DEVE SER INFORMADO COMO PARÂMETRO GLOBAL.' );
            lib_proc.close;
            RETURN mproc_id_o;
        END IF;

        loga ( '>>> DT INICIAL: ' || v_data_inicial
             , FALSE );
        loga ( '>>> DT FINAL: ' || v_data_final
             , FALSE );

        ---
        IF msafi.get_trava_info ( 'PMC_MVA'
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
            RETURN mproc_id_o;
        END IF;

        --PREPARAR LOJAS
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
                           AND tipo = 'L' ) LOOP
                a_estabs.EXTEND ( );
                a_estabs ( a_estabs.LAST ) := c1.cod_estab;
            END LOOP;
        END IF;

        --ATUALIZAR LISTA DE MEDICAMENTOS
        atualiza_lista;

        --EXECUTAR FILIAIS POR QUEBRA
        i1 := 0;

        FOR est IN a_estabs.FIRST .. a_estabs.COUNT --(99)
                                                   LOOP
            i1 := i1 + 1;
            a_estab_part.EXTEND ( );
            a_estab_part ( i1 ) := a_estabs ( est );

            IF MOD ( a_estab_part.COUNT
                   , v_quant_empresas ) = 0
            OR ( est = a_estabs.COUNT ) --(88)
                                       THEN
                i1 := 0;

                --GERAR CHAVE PROC_ID
                SELECT ROUND ( dbms_random.VALUE ( 10000000000000
                                                 , 999999999999999 ) )
                  INTO p_proc_instance
                  FROM DUAL;

                ---------------------
                loga ( '>> INICIO DO PROCESSAMENTO...' || p_proc_instance
                     , FALSE );

                --CRIAR TABELA DE SAIDA TMP
                create_tab_saida ( p_proc_instance
                                 , v_tabela_saida );
                save_tmp_control ( p_proc_instance
                                 , v_tabela_saida );

                --CARREGAR SAIDAS
                FOR i IN 1 .. a_estab_part.COUNT LOOP
                    load_saidas ( p_proc_instance
                                , a_estab_part ( i )
                                , p_data_ini
                                , p_data_fim
                                , v_tabela_saida
                                , v_data_hora_ini );
                END LOOP;

                --CRIAR INDICES DA TEMP DE SAIDA
                create_tab_saida_idx ( p_proc_instance
                                     , v_tabela_saida
                                     , v_tabela_saida_s1
                                     , v_tabela_saida_s2
                                     , v_qtde_saida_s1
                                     , v_qtde_saida_s2 );
                --CRIAR E CARREGAR TABELAS TEMP DE ALIQ E PMC DO PEOPLESOFT
                load_aliq_pmc ( p_proc_instance
                              , v_nome_tabela_aliq
                              , v_nome_tabela_pmc
                              , v_tabela_saida );

                --CRIAR TABELA TMP DE ENTRADA CD
                IF ( p_origem1 = '2' )
                OR ( p_origem2 = '2' )
                OR ( p_origem3 = '2' )
                OR ( p_origem4 = '2' ) THEN
                    create_tab_entrada_cd ( p_proc_instance
                                          , v_tab_entrada_c );
                END IF;

                --CRIAR TABELA TMP DE ENTRADA EM FILIAIS
                IF ( p_origem1 = '1' )
                OR ( p_origem2 = '1' )
                OR ( p_origem3 = '1' )
                OR ( p_origem4 = '1' ) THEN
                    create_tab_entrada_f ( p_proc_instance
                                         , v_tab_entrada_f );
                END IF;

                --CRIAR TABELA TMP DE ENTRADA COMPRA DIRETA
                IF ( p_compra_direta = 'S' ) THEN
                    create_tab_entrada_co ( p_proc_instance
                                          , v_tab_entrada_co );
                END IF;

                --CARREGAR DADOS DE ENTRADA NA SEQUENCIA DOS PARAMETROS
                --CD1--------------------------------------------------
                IF ( p_origem1 = '2' ) THEN
                    IF ( p_cd1 IS NOT NULL ) THEN
                        load_entradas ( p_proc_instance
                                      , p_cd1
                                      , v_data_final
                                      , 'C'
                                      , v_tab_entrada_c
                                      , v_tabela_saida_s1
                                      , v_data_hora_ini
                                      , v_data_inicial
                                      , '' );
                        limpa_tab_saida_sintetico_cd ( p_cd1
                                                     , v_tab_entrada_c
                                                     , v_qtde_saida_s1
                                                     , v_tabela_saida_s1 );
                        loga ( '> ENTRADA CD1-FIM'
                             , FALSE );
                    ELSE
                        loga ( '::PARAMETRO CD1 NAO INFORMADO::'
                             , FALSE );
                    END IF;
                ELSIF ( p_origem1 = '1' ) THEN
                    --CARREGAR TEMPORARIAS ENTRADA NAS FILIAIS
                    EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || v_tabela_saida_s2            INTO v_qtde_saida_s2;

                    loga ( 'S2 INI :' || v_qtde_saida_s2
                         , FALSE );

                    FOR i IN 1 .. a_estab_part.COUNT LOOP
                        load_entradas ( p_proc_instance
                                      , a_estab_part ( i )
                                      , v_data_final
                                      , 'F'
                                      , v_tab_entrada_f
                                      , v_tabela_saida_s2
                                      , v_data_hora_ini
                                      , v_data_inicial
                                      , p_cd1 );
                        limpa_tab_saida_sintetico_fil ( a_estab_part ( i )
                                                      , v_tab_entrada_f
                                                      , v_tabela_saida_s2 );
                    END LOOP; --FOR i IN 1..A_ESTABS_PART.COUNT

                    EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || v_tabela_saida_s2            INTO v_qtde_saida_s2;

                    loga ( 'S2 FIM :' || v_qtde_saida_s2
                         , FALSE );

                    loga ( '> ENTRADA FILIAL1-FIM'
                         , FALSE );
                END IF;

                IF ( v_qtde_saida_s1 > 0 )
                OR ( v_qtde_saida_s2 > 0 ) THEN
                    --CD2--------------------------------------------------
                    IF ( p_origem2 = '2' ) THEN
                        IF ( p_cd2 IS NOT NULL
                        AND v_qtde_saida_s1 > 0 ) THEN
                            load_entradas ( p_proc_instance
                                          , p_cd2
                                          , v_data_final
                                          , 'C'
                                          , v_tab_entrada_c
                                          , v_tabela_saida_s1
                                          , v_data_hora_ini
                                          , v_data_inicial
                                          , '' );
                            limpa_tab_saida_sintetico_cd ( p_cd2
                                                         , v_tab_entrada_c
                                                         , v_qtde_saida_s1
                                                         , v_tabela_saida_s1 );
                            loga ( '> ENTRADA CD2-FIM'
                                 , FALSE );
                        ELSE
                            loga ( '::PARAMETRO CD2 NAO INFORMADO OU INSUFICIENTE::'
                                 , FALSE );
                        END IF;
                    ELSIF ( p_origem2 = '1'
                       AND v_qtde_saida_s2 > 0 ) THEN
                        --CARREGAR TEMPORARIAS ENTRADA NAS FILIAIS
                        EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || v_tabela_saida_s2            INTO v_qtde_saida_s2;

                        loga ( 'S2 INI :' || v_qtde_saida_s2
                             , FALSE );

                        FOR i IN 1 .. a_estab_part.COUNT LOOP
                            load_entradas ( p_proc_instance
                                          , a_estab_part ( i )
                                          , v_data_final
                                          , 'F'
                                          , v_tab_entrada_f
                                          , v_tabela_saida_s2
                                          , v_data_hora_ini
                                          , v_data_inicial
                                          , p_cd2 );
                            limpa_tab_saida_sintetico_fil ( a_estab_part ( i )
                                                          , v_tab_entrada_f
                                                          , v_tabela_saida_s2 );
                        END LOOP; --FOR i IN 1..A_ESTABS_PART.COUNT

                        EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || v_tabela_saida_s2            INTO v_qtde_saida_s2;

                        loga ( 'S2 FIM :' || v_qtde_saida_s2
                             , FALSE );

                        loga ( '> ENTRADA FILIAL2-FIM'
                             , FALSE );
                    END IF;
                END IF;

                IF ( v_qtde_saida_s1 > 0 )
                OR ( v_qtde_saida_s2 > 0 ) THEN
                    --CD3--------------------------------------------------
                    IF ( p_origem3 = '2' ) THEN
                        IF ( p_cd3 IS NOT NULL
                        AND v_qtde_saida_s1 > 0 ) THEN
                            load_entradas ( p_proc_instance
                                          , p_cd3
                                          , v_data_final
                                          , 'C'
                                          , v_tab_entrada_c
                                          , v_tabela_saida_s1
                                          , v_data_hora_ini
                                          , v_data_inicial
                                          , '' );
                            limpa_tab_saida_sintetico_cd ( p_cd3
                                                         , v_tab_entrada_c
                                                         , v_qtde_saida_s1
                                                         , v_tabela_saida_s1 );
                            loga ( '> ENTRADA CD3-FIM'
                                 , FALSE );
                        ELSE
                            loga ( '::PARAMETRO CD3 NAO INFORMADO OU INSUFICIENTE::'
                                 , FALSE );
                        END IF;
                    ELSIF ( p_origem3 = '1'
                       AND v_qtde_saida_s2 > 0 ) THEN
                        --CARREGAR TEMPORARIAS ENTRADA NAS FILIAIS
                        EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || v_tabela_saida_s2            INTO v_qtde_saida_s2;

                        loga ( 'S2 INI :' || v_qtde_saida_s2
                             , FALSE );

                        FOR i IN 1 .. a_estab_part.COUNT LOOP
                            load_entradas ( p_proc_instance
                                          , a_estab_part ( i )
                                          , v_data_final
                                          , 'F'
                                          , v_tab_entrada_f
                                          , v_tabela_saida_s2
                                          , v_data_hora_ini
                                          , v_data_inicial
                                          , p_cd3 );
                            limpa_tab_saida_sintetico_fil ( a_estab_part ( i )
                                                          , v_tab_entrada_f
                                                          , v_tabela_saida_s2 );
                        END LOOP; --FOR i IN 1..A_ESTABS_PART.COUNT

                        EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || v_tabela_saida_s2            INTO v_qtde_saida_s2;

                        loga ( 'S2 FIM :' || v_qtde_saida_s2
                             , FALSE );

                        loga ( '> ENTRADA FILIAL3-FIM'
                             , FALSE );
                    END IF;
                END IF;

                IF ( v_qtde_saida_s1 > 0 )
                OR ( v_qtde_saida_s2 > 0 ) THEN
                    --CD4--------------------------------------------------
                    IF ( p_origem4 = '2' ) THEN
                        IF ( p_cd4 IS NOT NULL
                        AND v_qtde_saida_s1 > 0 ) THEN
                            load_entradas ( p_proc_instance
                                          , p_cd4
                                          , v_data_final
                                          , 'C'
                                          , v_tab_entrada_c
                                          , v_tabela_saida_s1
                                          , v_data_hora_ini
                                          , v_data_inicial
                                          , '' );
                            limpa_tab_saida_sintetico_cd ( p_cd4
                                                         , v_tab_entrada_c
                                                         , v_qtde_saida_s1
                                                         , v_tabela_saida_s1 );
                            loga ( '> ENTRADA CD4-FIM'
                                 , FALSE );
                        ELSE
                            loga ( '::PARAMETRO CD4 NAO INFORMADO OU INSUFICIENTE::'
                                 , FALSE );
                        END IF;
                    ELSIF ( p_origem4 = '1'
                       AND v_qtde_saida_s2 > 0 ) THEN
                        --CARREGAR TEMPORARIAS ENTRADA NAS FILIAIS
                        EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || v_tabela_saida_s2            INTO v_qtde_saida_s2;

                        loga ( 'S2 INI :' || v_qtde_saida_s2
                             , FALSE );

                        FOR i IN 1 .. a_estab_part.COUNT LOOP
                            load_entradas ( p_proc_instance
                                          , a_estab_part ( i )
                                          , v_data_final
                                          , 'F'
                                          , v_tab_entrada_f
                                          , v_tabela_saida_s2
                                          , v_data_hora_ini
                                          , v_data_inicial
                                          , p_cd4 );
                            limpa_tab_saida_sintetico_fil ( a_estab_part ( i )
                                                          , v_tab_entrada_f
                                                          , v_tabela_saida_s2 );
                        END LOOP; --FOR i IN 1..A_ESTABS_PART.COUNT

                        EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || v_tabela_saida_s2            INTO v_qtde_saida_s2;

                        loga ( 'S2 FIM :' || v_qtde_saida_s2
                             , FALSE );

                        loga ( '> ENTRADA FILIAL4-FIM'
                             , FALSE );
                    END IF;
                END IF;

                IF ( v_qtde_saida_s2 > 0 ) THEN
                    --COMPRA DIRETA--------------------------------------------------
                    IF ( p_compra_direta = 'S' ) THEN
                        FOR i IN 1 .. a_estab_part.COUNT LOOP
                            load_entradas ( p_proc_instance
                                          , a_estab_part ( i )
                                          , v_data_final
                                          , 'CO'
                                          , v_tab_entrada_co
                                          , v_tabela_saida_s2
                                          , v_data_hora_ini
                                          , v_data_inicial
                                          , '' );
                        END LOOP;
                    END IF;
                END IF;

                --CRIAR INDICES DA TEMP DE ENTRADA CD
                IF ( p_origem1 = '2' )
                OR ( p_origem2 = '2' )
                OR ( p_origem3 = '2' )
                OR ( p_origem4 = '2' ) THEN
                    create_tab_entrada_cd_idx ( p_proc_instance
                                              , v_tab_entrada_c );
                END IF;

                --CRIAR INDICES DA TEMP DE ENTRADA FILIAL
                IF ( p_origem1 = '1' )
                OR ( p_origem2 = '1' )
                OR ( p_origem3 = '1' )
                OR ( p_origem4 = '1' ) THEN
                    create_tab_entrada_f_idx ( p_proc_instance
                                             , v_tab_entrada_f );
                END IF;

                --CRIAR INDICES DA TEMP DE ENTRADA CDIRETA
                IF ( p_compra_direta = 'S' ) THEN
                    create_tab_entrada_co_idx ( p_proc_instance
                                              , v_tab_entrada_co );
                END IF;

                --CARREGAR NFs DO PEOPLE
                load_nf_people ( p_proc_instance
                               , mcod_empresa
                               , v_tab_entrada_c
                               , v_tab_entrada_f
                               , v_tab_entrada_co
                               , v_tabela_nf );

                --CRIAR TABELA RESULTADO TMP
                create_tab_pmc_mva ( p_proc_instance
                                   , v_tabela_pmc_mva );

                --LOOP PARA CADA FILIAL-INI--------------------------------------------------------------------------------------
                FOR i IN 1 .. a_estab_part.COUNT LOOP
                    --ASSOCIAR SAIDAS COM SUAS ULTIMAS ENTRADAS
                    IF ( p_cd1 IS NOT NULL ) THEN
                        IF ( p_origem1 = '1' ) THEN
                            --ENTRADA NAS FILIAIS
                            get_entradas_filial ( p_proc_instance
                                                , a_estab_part ( i )
                                                , p_cd1
                                                , v_data_inicial
                                                , v_data_final
                                                , v_tab_entrada_f
                                                , v_tabela_saida
                                                , v_tabela_nf
                                                , v_tabela_pmc_mva
                                                , v_data_hora_ini );
                        ELSIF ( p_origem1 = '2' ) THEN
                            --ENTRADA NOS CDs
                            get_entradas_cd ( p_proc_instance
                                            , a_estab_part ( i )
                                            , p_cd1
                                            , v_data_inicial
                                            , v_data_final
                                            , v_tab_entrada_c
                                            , v_tabela_saida
                                            , v_tabela_nf
                                            , v_tabela_pmc_mva
                                            , v_data_hora_ini );
                        END IF;
                    END IF;

                    IF ( p_cd2 IS NOT NULL ) THEN
                        IF ( p_origem2 = '1' ) THEN
                            --ENTRADA NAS FILIAIS
                            get_entradas_filial ( p_proc_instance
                                                , a_estab_part ( i )
                                                , p_cd2
                                                , v_data_inicial
                                                , v_data_final
                                                , v_tab_entrada_f
                                                , v_tabela_saida
                                                , v_tabela_nf
                                                , v_tabela_pmc_mva
                                                , v_data_hora_ini );
                        ELSIF ( p_origem2 = '2' ) THEN
                            --ENTRADA NOS CDs
                            get_entradas_cd ( p_proc_instance
                                            , a_estab_part ( i )
                                            , p_cd2
                                            , v_data_inicial
                                            , v_data_final
                                            , v_tab_entrada_c
                                            , v_tabela_saida
                                            , v_tabela_nf
                                            , v_tabela_pmc_mva
                                            , v_data_hora_ini );
                        END IF;
                    END IF;

                    IF ( p_cd3 IS NOT NULL ) THEN
                        IF ( p_origem3 = '1' ) THEN
                            --ENTRADA NAS FILIAIS
                            get_entradas_filial ( p_proc_instance
                                                , a_estab_part ( i )
                                                , p_cd3
                                                , v_data_inicial
                                                , v_data_final
                                                , v_tab_entrada_f
                                                , v_tabela_saida
                                                , v_tabela_nf
                                                , v_tabela_pmc_mva
                                                , v_data_hora_ini );
                        ELSIF ( p_origem3 = '2' ) THEN
                            --ENTRADA NOS CDs
                            get_entradas_cd ( p_proc_instance
                                            , a_estab_part ( i )
                                            , p_cd3
                                            , v_data_inicial
                                            , v_data_final
                                            , v_tab_entrada_c
                                            , v_tabela_saida
                                            , v_tabela_nf
                                            , v_tabela_pmc_mva
                                            , v_data_hora_ini );
                        END IF;
                    END IF;

                    IF ( p_cd4 IS NOT NULL ) THEN
                        IF ( p_origem4 = '1' ) THEN
                            --ENTRADA NAS FILIAIS
                            get_entradas_filial ( p_proc_instance
                                                , a_estab_part ( i )
                                                , p_cd4
                                                , v_data_inicial
                                                , v_data_final
                                                , v_tab_entrada_f
                                                , v_tabela_saida
                                                , v_tabela_nf
                                                , v_tabela_pmc_mva
                                                , v_data_hora_ini );
                        ELSIF ( p_origem4 = '2' ) THEN
                            --ENTRADA NOS CDs
                            get_entradas_cd ( p_proc_instance
                                            , a_estab_part ( i )
                                            , p_cd4
                                            , v_data_inicial
                                            , v_data_final
                                            , v_tab_entrada_c
                                            , v_tabela_saida
                                            , v_tabela_nf
                                            , v_tabela_pmc_mva
                                            , v_data_hora_ini );
                        END IF;
                    END IF;

                    IF ( p_compra_direta = 'S' ) THEN
                        get_compra_direta ( p_proc_instance
                                          , a_estab_part ( i )
                                          , v_data_inicial
                                          , v_data_final
                                          , v_tab_entrada_co
                                          , v_tabela_saida
                                          , v_tabela_nf
                                          , v_tabela_pmc_mva
                                          , v_data_hora_ini );
                    END IF;

                    --SE NAO ACHOU ENTRADA, GRAVAR NA TABELA RESULTADO APENAS A SAIDA
                    get_sem_entrada ( p_proc_instance
                                    , a_estab_part ( i )
                                    , v_data_inicial
                                    , v_data_final
                                    , v_tabela_saida
                                    , v_tabela_pmc_mva
                                    , v_data_hora_ini );

                    loga ( 'GET_ENTRADAS-FIM-' || a_estab_part ( i )
                         , FALSE );

                    --LIMPAR DADOS DA TABELA FINAL DO PMC
                    delete_tbl ( a_estab_part ( i )
                               , v_data_inicial
                               , v_data_final );
                END LOOP; --FOR i IN 1..A_ESTABS_PART.COUNT

                --LOOP PARA CADA FILIAL-FIM--------------------------------------------------------------------------------------

                --INSERIR DADOS-INI-------------------------------------------------------------------------------------------
                loga ( 'INSERINDO RESULTADO... - INI' );

                ---INSERIR RESULTADO
                v_sql_resultado := 'SELECT DISTINCT ';
                v_sql_resultado := v_sql_resultado || ' A.COD_EMPRESA ';
                v_sql_resultado := v_sql_resultado || ',A.COD_ESTAB ';
                v_sql_resultado := v_sql_resultado || ',A.NUM_DOCFIS ';
                v_sql_resultado := v_sql_resultado || ',A.DATA_FISCAL ';
                v_sql_resultado := v_sql_resultado || ',A.COD_PRODUTO ';
                v_sql_resultado := v_sql_resultado || ',A.COD_ESTADO ';
                v_sql_resultado := v_sql_resultado || ',A.DOCTO ';
                v_sql_resultado := v_sql_resultado || ',A.NUM_ITEM ';
                v_sql_resultado := v_sql_resultado || ',A.DESCR_ITEM ';
                v_sql_resultado := v_sql_resultado || ',A.QUANTIDADE ';
                v_sql_resultado := v_sql_resultado || ',A.COD_NBM ';
                v_sql_resultado := v_sql_resultado || ',A.COD_CFO ';
                v_sql_resultado := v_sql_resultado || ',A.GRUPO_PRODUTO ';
                v_sql_resultado := v_sql_resultado || ',A.VLR_DESCONTO ';
                v_sql_resultado := v_sql_resultado || ',A.VLR_CONTABIL ';
                v_sql_resultado := v_sql_resultado || ',A.BASE_UNIT_S_VENDA ';
                v_sql_resultado := v_sql_resultado || ',A.NUM_AUTENTIC_NFE ';
                ---
                v_sql_resultado := v_sql_resultado || ',A.COD_ESTAB_E ';
                v_sql_resultado := v_sql_resultado || ',A.DATA_FISCAL_E ';
                v_sql_resultado := v_sql_resultado || ',A.MOVTO_E_S_E ';
                v_sql_resultado := v_sql_resultado || ',A.NORM_DEV_E ';
                v_sql_resultado := v_sql_resultado || ',A.IDENT_DOCTO_E ';
                v_sql_resultado := v_sql_resultado || ',A.IDENT_FIS_JUR_E ';
                v_sql_resultado := v_sql_resultado || ',A.SUB_SERIE_DOCFIS_E ';
                v_sql_resultado := v_sql_resultado || ',A.DISCRI_ITEM_E ';
                v_sql_resultado := v_sql_resultado || ',A.DATA_EMISSAO_E ';
                v_sql_resultado := v_sql_resultado || ',A.NUM_DOCFIS_E ';
                v_sql_resultado := v_sql_resultado || ',A.SERIE_DOCFIS_E ';
                v_sql_resultado := v_sql_resultado || ',A.NUM_ITEM_E ';
                v_sql_resultado := v_sql_resultado || ',A.COD_FIS_JUR_E ';
                v_sql_resultado := v_sql_resultado || ',A.CPF_CGC_E ';
                v_sql_resultado := v_sql_resultado || ',A.COD_NBM_E ';
                v_sql_resultado := v_sql_resultado || ',A.COD_CFO_E ';
                v_sql_resultado := v_sql_resultado || ',A.COD_NATUREZA_OP_E ';
                v_sql_resultado := v_sql_resultado || ',A.COD_PRODUTO_E ';
                v_sql_resultado := v_sql_resultado || ',A.VLR_CONTAB_ITEM_E ';
                v_sql_resultado := v_sql_resultado || ',A.QUANTIDADE_E ';
                v_sql_resultado := v_sql_resultado || ',A.VLR_UNIT_E ';
                v_sql_resultado := v_sql_resultado || ',A.COD_SITUACAO_B_E ';
                v_sql_resultado := v_sql_resultado || ',A.COD_ESTADO_E ';
                v_sql_resultado := v_sql_resultado || ',A.NUM_CONTROLE_DOCTO_E ';
                v_sql_resultado := v_sql_resultado || ',A.NUM_AUTENTIC_NFE_E ';
                v_sql_resultado := v_sql_resultado || ',A.BASE_ICMS_UNIT_E ';
                v_sql_resultado := v_sql_resultado || ',A.VLR_ICMS_UNIT_E ';
                v_sql_resultado := v_sql_resultado || ',A.ALIQ_ICMS_E ';
                v_sql_resultado := v_sql_resultado || ',A.BASE_ST_UNIT_E ';
                v_sql_resultado :=
                       v_sql_resultado
                    || ',DECODE(A.VLR_ICMS_ST_UNIT_E, 0, A.VLR_ICMS_ST_UNIT_AUX, A.VLR_ICMS_ST_UNIT_E) '; --VLR_ICMS_ST_UNIT_E
                v_sql_resultado := v_sql_resultado || ',A.STAT_LIBER_CNTR ';
                v_sql_resultado := v_sql_resultado || ',C.ALIQ_ST ';
                v_sql_resultado := v_sql_resultado || ',D.VLR_PMC ';
                v_sql_resultado :=
                       v_sql_resultado
                    || ',TRUNC((A.BASE_ST_UNIT_E*(TO_NUMBER(REPLACE(C.ALIQ_ST,''%'',''''))/100))-DECODE(A.VLR_ICMS_ST_UNIT_E, 0, A.VLR_ICMS_ST_UNIT_AUX, A.VLR_ICMS_ST_UNIT_E), 2) '; --VLR_ICMS_AUX
                v_sql_resultado :=
                    v_sql_resultado || ',TRUNC(A.BASE_UNIT_S_VENDA*(TO_NUMBER(REPLACE(C.ALIQ_ST,''%'',''''))/100), 2) '; --VLR_ICMS_BRUTO
                v_sql_resultado :=
                       v_sql_resultado
                    || ',CASE WHEN (A.VLR_ICMS_UNIT_E = 0 OR A.VLR_ICMS_UNIT_E IS NULL) THEN TRUNC(TRUNC(A.BASE_UNIT_S_VENDA*(TO_NUMBER(REPLACE(C.ALIQ_ST,''%'',''''))/100), 2)-TRUNC((A.BASE_ST_UNIT_E*(TO_NUMBER(REPLACE(C.ALIQ_ST,''%'',''''))/100))-DECODE(A.VLR_ICMS_ST_UNIT_E, 0, A.VLR_ICMS_ST_UNIT_AUX, A.VLR_ICMS_ST_UNIT_E), 2), 2) ELSE TRUNC(TRUNC(A.BASE_UNIT_S_VENDA*(TO_NUMBER(REPLACE(C.ALIQ_ST,''%'',''''))/100), 2)-A.VLR_ICMS_UNIT_E, 2) END '; --VLR_ICMS_S_VENDA
                v_sql_resultado :=
                       v_sql_resultado
                    || ',TRUNC((A.VLR_ICMS_ST_UNIT_E-CASE WHEN (A.VLR_ICMS_UNIT_E = 0 OR A.VLR_ICMS_UNIT_E IS NULL) THEN TRUNC(TRUNC(A.BASE_UNIT_S_VENDA*(TO_NUMBER(REPLACE(C.ALIQ_ST,''%'',''''))/100), 2)-TRUNC((A.BASE_ST_UNIT_E*(TO_NUMBER(REPLACE(C.ALIQ_ST,''%'',''''))/100))-DECODE(A.VLR_ICMS_ST_UNIT_E, 0, A.VLR_ICMS_ST_UNIT_AUX, A.VLR_ICMS_ST_UNIT_E), 2), 2) ELSE TRUNC(TRUNC(A.BASE_UNIT_S_VENDA*(TO_NUMBER(REPLACE(C.ALIQ_ST,''%'',''''))/100), 2)-A.VLR_ICMS_UNIT_E, 2) END)*A.QUANTIDADE, 2) '; --VLR_DIF_QTDE
                v_sql_resultado := v_sql_resultado || ',CASE ';
                v_sql_resultado := v_sql_resultado || '    WHEN ( ';
                v_sql_resultado := v_sql_resultado || '          TRUNC((A.VLR_ICMS_ST_UNIT_E- ';
                v_sql_resultado :=
                       v_sql_resultado
                    || '          CASE WHEN (A.VLR_ICMS_UNIT_E = 0 OR A.VLR_ICMS_UNIT_E IS NULL) THEN TRUNC(TRUNC(A.BASE_UNIT_S_VENDA*(TO_NUMBER(REPLACE(C.ALIQ_ST,''%'',''''))/100), 2)-TRUNC((A.BASE_ST_UNIT_E*(TO_NUMBER(REPLACE(C.ALIQ_ST,''%'',''''))/100))-DECODE(A.VLR_ICMS_ST_UNIT_E, 0, A.VLR_ICMS_ST_UNIT_AUX, A.VLR_ICMS_ST_UNIT_E), 2), 2) ';
                v_sql_resultado :=
                       v_sql_resultado
                    || '          ELSE TRUNC(TRUNC(A.BASE_UNIT_S_VENDA*(TO_NUMBER(REPLACE(C.ALIQ_ST,''%'',''''))/100), 2)-A.VLR_ICMS_UNIT_E, 2) ';
                v_sql_resultado := v_sql_resultado || '          END)*A.QUANTIDADE, 2) ';
                v_sql_resultado := v_sql_resultado || '          ) > 0 THEN ''CRÉDITO'' ';
                v_sql_resultado := v_sql_resultado || '    WHEN ( ';
                v_sql_resultado := v_sql_resultado || '          TRUNC((A.VLR_ICMS_ST_UNIT_E- ';
                v_sql_resultado :=
                       v_sql_resultado
                    || '          CASE WHEN (A.VLR_ICMS_UNIT_E = 0 OR A.VLR_ICMS_UNIT_E IS NULL) THEN TRUNC(TRUNC(A.BASE_UNIT_S_VENDA*(TO_NUMBER(REPLACE(C.ALIQ_ST,''%'',''''))/100), 2)-TRUNC((A.BASE_ST_UNIT_E*(TO_NUMBER(REPLACE(C.ALIQ_ST,''%'',''''))/100))-DECODE(A.VLR_ICMS_ST_UNIT_E,0,A.VLR_ICMS_ST_UNIT_AUX, A.VLR_ICMS_ST_UNIT_E), 2), 2) ';
                v_sql_resultado :=
                       v_sql_resultado
                    || '          ELSE TRUNC(TRUNC(A.BASE_UNIT_S_VENDA*(TO_NUMBER(REPLACE(C.ALIQ_ST,''%'',''''))/100), 2)-A.VLR_ICMS_UNIT_E, 2) ';
                v_sql_resultado := v_sql_resultado || '          END)*A.QUANTIDADE, 2) ';
                v_sql_resultado := v_sql_resultado || '         ) < 0 THEN ''DÉBITO'' ';
                v_sql_resultado := v_sql_resultado || '    ELSE ''-'' END ';
                v_sql_resultado := v_sql_resultado || ',''' || musuario || ''' ';
                v_sql_resultado := v_sql_resultado || ',SYSDATE ';
                v_sql_resultado := v_sql_resultado || ',A.SERIE_DOCFIS ';
                v_sql_resultado := v_sql_resultado || ',A.VLR_ICMS_ST_UNIT_AUX ';
                v_sql_resultado := v_sql_resultado || ',LIS.LISTA ';
                ---
                v_sql_resultado := v_sql_resultado || 'FROM ' || v_tabela_pmc_mva || ' A, ';
                v_sql_resultado := v_sql_resultado || v_nome_tabela_aliq || ' C, ';
                v_sql_resultado := v_sql_resultado || v_nome_tabela_pmc || ' D, ';
                v_sql_resultado := v_sql_resultado || '    (SELECT A.COD_PRODUTO, A.LISTA, A.EFFDT ';
                v_sql_resultado :=
                       v_sql_resultado
                    || '     FROM (SELECT COD_PRODUTO, LISTA, EFFDT, RANK() OVER (PARTITION BY COD_PRODUTO ORDER BY EFFDT DESC) RANK ';
                v_sql_resultado := v_sql_resultado || '           FROM MSAF.DPSP_PS_LISTA ) A ';
                v_sql_resultado := v_sql_resultado || '     WHERE A.RANK = 1 ) LIS ';
                ---
                v_sql_resultado := v_sql_resultado || 'WHERE A.PROC_ID     = ' || p_proc_instance;
                v_sql_resultado := v_sql_resultado || '  AND A.COD_PRODUTO = LIS.COD_PRODUTO ';
                v_sql_resultado := v_sql_resultado || '  AND A.PROC_ID     = C.PROC_ID (+) ';
                v_sql_resultado := v_sql_resultado || '  AND A.COD_PRODUTO = C.COD_PRODUTO (+) ';
                v_sql_resultado := v_sql_resultado || '  AND A.PROC_ID     = D.PROC_ID (+) ';
                v_sql_resultado := v_sql_resultado || '  AND A.COD_PRODUTO = D.COD_PRODUTO (+) ';

                BEGIN
                    OPEN c_pmc_mva FOR v_sql_resultado;
                EXCEPTION
                    WHEN OTHERS THEN
                        loga ( 'SQLERRM: ' || SQLERRM
                             , FALSE );
                        loga ( SUBSTR ( v_sql_resultado
                                      , 1
                                      , 1024 )
                             , FALSE );
                        loga ( SUBSTR ( v_sql_resultado
                                      , 1024
                                      , 1024 )
                             , FALSE );
                        loga ( SUBSTR ( v_sql_resultado
                                      , 2048
                                      , 1024 )
                             , FALSE );
                        loga ( SUBSTR ( v_sql_resultado
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
                        raise_application_error ( -20004
                                                , '!ERRO SELECT RESULTADO!' );
                END;

                LOOP
                    FETCH c_pmc_mva
                        BULK COLLECT INTO tab_pmc_mva
                        LIMIT 100;

                    BEGIN
                        FORALL i IN tab_pmc_mva.FIRST .. tab_pmc_mva.LAST
                            EXECUTE IMMEDIATE
                                   'INSERT /*+APPEND_VALUES*/ INTO MSAFI.DPSP_MSAF_PMC_MVA VALUES (:1, :2, :3, :4, :5, :6, :7, :8, :9, '
                                || ' :10, :11, :12, :13, :14, :15, :16, :17, :18, :19, :20, :21, :22, :23, :24, :25, '
                                || ' :26, :27, :28, :29, :30, :31, :32, :33, :34, :35, :36, :37, :38, :39, :40, :41, :42, :43, '
                                || ' :44, :45, :46, :47, :48, :49, :50, :51, :52, :53, :54, :55, :56, :57, '
                                || ' :58, :59, :60) '
                                USING tab_pmc_mva ( i ).cod_empresa
                                    , tab_pmc_mva ( i ).cod_estab
                                    , tab_pmc_mva ( i ).num_docfis
                                    , tab_pmc_mva ( i ).data_fiscal
                                    , tab_pmc_mva ( i ).cod_produto
                                    , tab_pmc_mva ( i ).cod_estado
                                    , tab_pmc_mva ( i ).docto
                                    , tab_pmc_mva ( i ).num_item
                                    , tab_pmc_mva ( i ).descr_item
                                    , tab_pmc_mva ( i ).quantidade
                                    , tab_pmc_mva ( i ).cod_nbm
                                    , tab_pmc_mva ( i ).cod_cfo
                                    , tab_pmc_mva ( i ).grupo_produto
                                    , tab_pmc_mva ( i ).vlr_desconto
                                    , tab_pmc_mva ( i ).vlr_contabil
                                    , tab_pmc_mva ( i ).base_unit_s_venda
                                    , tab_pmc_mva ( i ).num_autentic_nfe
                                    , tab_pmc_mva ( i ).cod_estab_e
                                    , tab_pmc_mva ( i ).data_fiscal_e
                                    , tab_pmc_mva ( i ).movto_e_s_e
                                    , tab_pmc_mva ( i ).norm_dev_e
                                    , tab_pmc_mva ( i ).ident_docto_e
                                    , tab_pmc_mva ( i ).ident_fis_jur_e
                                    , tab_pmc_mva ( i ).sub_serie_docfis_e
                                    , tab_pmc_mva ( i ).discri_item_e
                                    , tab_pmc_mva ( i ).data_emissao_e
                                    , tab_pmc_mva ( i ).num_docfis_e
                                    , tab_pmc_mva ( i ).serie_docfis_e
                                    , tab_pmc_mva ( i ).num_item_e
                                    , tab_pmc_mva ( i ).cod_fis_jur_e
                                    , tab_pmc_mva ( i ).cpf_cgc_e
                                    , tab_pmc_mva ( i ).cod_nbm_e
                                    , tab_pmc_mva ( i ).cod_cfo_e
                                    , tab_pmc_mva ( i ).cod_natureza_op_e
                                    , tab_pmc_mva ( i ).cod_produto_e
                                    , tab_pmc_mva ( i ).vlr_contab_item_e
                                    , tab_pmc_mva ( i ).quantidade_e
                                    , tab_pmc_mva ( i ).vlr_unit_e
                                    , tab_pmc_mva ( i ).cod_situacao_b_e
                                    , tab_pmc_mva ( i ).cod_estado_e
                                    , tab_pmc_mva ( i ).num_controle_docto_e
                                    , tab_pmc_mva ( i ).num_autentic_nfe_e
                                    , tab_pmc_mva ( i ).base_icms_unit_e
                                    , tab_pmc_mva ( i ).vlr_icms_unit_e
                                    , tab_pmc_mva ( i ).aliq_icms_e
                                    , tab_pmc_mva ( i ).base_st_unit_e
                                    , tab_pmc_mva ( i ).vlr_icms_st_unit_e
                                    , tab_pmc_mva ( i ).stat_liber_cntr
                                    , tab_pmc_mva ( i ).id_aliq_st
                                    , tab_pmc_mva ( i ).vlr_pmc
                                    , tab_pmc_mva ( i ).vlr_icms_aux
                                    , tab_pmc_mva ( i ).vlr_icms_bruto
                                    , tab_pmc_mva ( i ).vlr_icms_s_venda
                                    , tab_pmc_mva ( i ).vlr_dif_qtde
                                    , tab_pmc_mva ( i ).deb_cred
                                    , tab_pmc_mva ( i ).usuario
                                    , tab_pmc_mva ( i ).dat_operacao
                                    , tab_pmc_mva ( i ).serie_docfis
                                    , tab_pmc_mva ( i ).vlr_icms_st_unit_aux
                                    , tab_pmc_mva ( i ).lista;
                    EXCEPTION
                        WHEN OTHERS THEN
                            loga ( 'SQLERRM: ' || SQLERRM
                                 , FALSE );
                            --ENVIAR EMAIL DE ERRO-------------------------------------------
                            envia_email ( mcod_empresa
                                        , v_data_inicial
                                        , v_data_final
                                        , SQLERRM
                                        , 'E'
                                        , v_data_hora_ini );
                            -----------------------------------------------------------------
                            raise_application_error ( -20004
                                                    , '!ERRO INSERT RESULTADO!' );
                    END;

                    COMMIT;
                    tab_pmc_mva.delete;

                    EXIT WHEN c_pmc_mva%NOTFOUND;
                END LOOP;

                COMMIT;

                CLOSE c_pmc_mva;

                loga ( 'RESULTADO-FIM' );
                --INSERIR DADOS-FIM-------------------------------------------------------------------------------------------

                --APAGAR TABELAS TEMPORARIAS
                delete_temp_tbl ( p_proc_instance );
                loga ( '<< LIMPAR TEMPs FIM >>'
                     , FALSE );
                --
                loga ( '--FIM PARCIAL--'
                     , FALSE );

                a_estab_part := a_estabs_t ( );
            END IF; --(88)
        END LOOP; --(99)

        --DISPONIBILIZAR PERIODO PROCESSADO PARA TRAVA DE REPROCESSAMENTO
        msafi.add_trava_info ( 'PMC_MVA'
                             , TO_CHAR ( v_data_inicial
                                       , 'YYYY/MM' ) );

        loga ( '---FIM DO PROCESSAMENTO---'
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

        lib_proc.close;
        RETURN mproc_id_o;
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
            RETURN mproc_id_o;
    END; /* FUNCTION EXECUTAR */
END dpsp_pmc_x_mva_new_cproc;
/
SHOW ERRORS;
