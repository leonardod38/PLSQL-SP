Prompt Package Body DPSP_EX_PIS_COFINS_635_CPROC;
--
-- DPSP_EX_PIS_COFINS_635_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_ex_pis_cofins_635_cproc
IS
    mcod_empresa empresa.cod_empresa%TYPE;
    mproc_id INTEGER;
    mproc_id_o INTEGER;
    v_quant_empresas INTEGER := 50;

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
                            'DATE'
                           , 'TEXTBOX'
                           , 'S'
                           , NULL
                           , 'DD/MM/YYYY' );

        lib_proc.add_param (
                             pstr
                           ,    '                                   '
                             || '____________________________________________________'
                           , 'VARCHAR2'
                           , 'TEXT'
        );
        lib_proc.add_param (
                             pparam => pstr
                           , ptitulo => 'Processo'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'RADIOBUTTON'
                           , pmandatorio => 'S'
                           , pdefault => '2'
                           , pvalores =>    '1=Processar registros,'
                                         || --
                                           '2=Relatório analítico,'
                                         || --
                                           '3=Relatório sintético'
        );
        lib_proc.add_param (
                             pparam => pstr
                           , ptitulo => 'UF'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'COMBOBOX'
                           , pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => '####################'
                           , pvalores =>    'SELECT COD_ESTADO, COD_ESTADO || '' - '' || DESCRICAO TXT FROM ESTADO '
                                         || ' WHERE COD_ESTADO IN (SELECT COD_ESTADO FROM DSP_ESTABELECIMENTO_V) '
                                         || '  ORDER BY 1'
        );
        lib_proc.add_param (
                             pstr
                           , 'Estabelecimentos'
                           , --P_LOJAS
                            'VARCHAR2'
                           , 'MULTISELECT'
                           , 'S'
                           , NULL
                           , NULL
                           ,    ' Select COD_ESTAB cod , Cod_Estado||'' - ''||COD_ESTAB||'' - ''||Initcap(ENDER) ||'' ''||(case when Tipo = ''C'' then ''(CD)'' end) loja'
                             || --
                               ' From dsp_estabelecimento_v Where 1=1 '
                             || ' and cod_empresa = '''
                             || mcod_empresa
                             || ''' and cod_estado like :5  ORDER BY Tipo, 2'
        );

        RETURN pstr;
    END; --FUNCTION PARAMETROS RETURN VARCHAR2 IS

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Processar Dados Exclusão de ICMS da BC PIS/Cofins - Vendas';
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
        RETURN '';
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

    PROCEDURE save_tmp_control ( vp_proc_instance IN NUMBER
                               , vp_table_name IN VARCHAR2 )
    IS
    BEGIN
        ---> Rotina para armazenar tabelas TEMP criadas, caso programa seja
        ---  interrompido, elas serao excluidas em outros processamentos
        INSERT /*+APPEND*/
              INTO  msafi.dpsp_msaf_tmp_control
             VALUES ( vp_proc_instance
                    , vp_table_name
                    , SYSDATE
                    , lib_parametros.recuperar ( 'USUARIO' )
                    , USERENV ( 'sid' ) );

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

    PROCEDURE drop_old_tmp
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
                    loga ( 'TAB OLD NAO ENCONTRADA ' || l_table_name
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
                     , 'DPSP_EX_PIS_COFINS_635_CPROC' );
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
                     , 'DPSP_EX_PIS_COFINS_635_CPROC' );
        END IF;
    END;

    PROCEDURE create_tab_ult_entradas ( vp_proc_instance IN VARCHAR2
                                      , vp_tabela_ult_entradas   OUT VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 10000 );
    BEGIN
        vp_tabela_ult_entradas := 'DPSP_MSAF_UE_' || vp_proc_instance;

        v_sql := 'CREATE TABLE ' || vp_tabela_ult_entradas || ' ( ';
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
        v_sql := v_sql || 'VLR_ITEM            NUMBER(17,2), '; --
        v_sql := v_sql || 'VLR_OUTRAS          NUMBER(17,2), '; --
        v_sql := v_sql || 'NUM_AUTENTIC_NFE    VARCHAR2(80), ';
        v_sql := v_sql || 'VLR_BASE_ICMS       NUMBER(17,2), ';
        v_sql := v_sql || 'VLR_ALIQ_ICMS       NUMBER(5,2), ';
        v_sql := v_sql || 'VLR_ICMS            NUMBER(17,2), ';
        v_sql := v_sql || 'CST_PIS             VARCHAR2(2), '; --
        v_sql := v_sql || 'VLR_BASE_PIS        NUMBER(17,2), '; --
        v_sql := v_sql || 'VLR_ALIQ_PIS        NUMBER(5,2), '; --
        v_sql := v_sql || 'VLR_PIS             NUMBER(17,2), '; --
        v_sql := v_sql || 'CST_COFINS          VARCHAR2(2), '; --
        v_sql := v_sql || 'VLR_BASE_COFINS     NUMBER(17,2), '; --
        v_sql := v_sql || 'VLR_ALIQ_COFINS     NUMBER(5,2), '; --
        v_sql := v_sql || 'VLR_COFINS          NUMBER(17,2), '; --
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

        v_sql := v_sql || 'VLR_ITEM_E            NUMBER(17,2), '; --
        v_sql := v_sql || 'VLR_OUTRAS_E          NUMBER(17,2), '; --
        v_sql := v_sql || 'VLR_DESCONTO_E        NUMBER(17,2), '; --

        v_sql := v_sql || 'CST_PIS_E             VARCHAR2(2), '; --
        v_sql := v_sql || 'VLR_BASE_PIS_E        NUMBER(17,2), '; --
        v_sql := v_sql || 'VLR_ALIQ_PIS_E        NUMBER(5,2), '; --
        v_sql := v_sql || 'VLR_PIS_E             NUMBER(17,2), '; --
        v_sql := v_sql || 'CST_COFINS_E          VARCHAR2(2), '; --
        v_sql := v_sql || 'VLR_BASE_COFINS_E     NUMBER(17,2), '; --
        v_sql := v_sql || 'VLR_ALIQ_COFINS_E     NUMBER(5,2), '; --
        v_sql := v_sql || 'VLR_COFINS_E          NUMBER(17,2), '; --

        v_sql := v_sql || 'VLR_ICMSS_N_ESCRIT    NUMBER(17,2), '; --

        v_sql := v_sql || 'COD_SITUACAO_B_E      VARCHAR2(2), ';
        v_sql := v_sql || 'COD_ESTADO_E          VARCHAR2(2), ';
        v_sql := v_sql || 'NUM_CONTROLE_DOCTO_E  VARCHAR2(12), ';
        v_sql := v_sql || 'NUM_AUTENTIC_NFE_E    VARCHAR2(80), ';
        v_sql := v_sql || 'VLR_BASE_ICMS_E       NUMBER(17,2), ';
        v_sql := v_sql || 'VLR_ICMS_E            NUMBER(17,2), ';
        v_sql := v_sql || 'VLR_BASE_ICMSS_E      NUMBER(17,2), ';
        v_sql := v_sql || 'VLR_ICMSS_E           NUMBER(17,2), ';
        ---
        v_sql := v_sql || 'BASE_ICMS_UNIT_E      NUMBER(17,2), ';
        v_sql := v_sql || 'VLR_ICMS_UNIT_E       NUMBER(17,2), ';
        v_sql := v_sql || 'ALIQ_ICMS_E           NUMBER(17,2), ';
        v_sql := v_sql || 'BASE_ST_UNIT_E        NUMBER(17,2), ';
        v_sql := v_sql || 'VLR_ICMS_ST_UNIT_E    NUMBER(17,2), ';
        v_sql := v_sql || 'VLR_ICMS_ST_UNIT_AUX  NUMBER(17,2), ';
        v_sql := v_sql || 'STAT_LIBER_CNTR       VARCHAR2(10)) ';
        v_sql := v_sql || 'PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE UNIQUE INDEX PK_DPSP_UE_' || vp_proc_instance || ' ON ' || vp_tabela_ult_entradas || ' ';
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
        v_sql := v_sql || '  SERIE_DOCFIS ASC  ';
        v_sql := v_sql || '  )';
        v_sql := v_sql || '  PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX1_DPSP_UE_' || vp_proc_instance || ' ON ' || vp_tabela_ult_entradas || ' ';
        v_sql := v_sql || '  ( ';
        v_sql := v_sql || '    PROC_ID        ASC ';
        v_sql := v_sql || '  ) ';
        v_sql := v_sql || '  PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        ---
        save_tmp_control ( vp_proc_instance
                         , vp_tabela_ult_entradas );
    END;

    PROCEDURE create_tab_saida ( vp_proc_instance IN VARCHAR2
                               , vp_tabela_saida   OUT VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 10000 );
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
        v_sql := v_sql || 'VLR_ITEM            NUMBER(17,2), '; --
        v_sql := v_sql || 'VLR_OUTRAS          NUMBER(17,2), '; --
        v_sql := v_sql || 'NUM_AUTENTIC_NFE    VARCHAR2(80), ';
        v_sql := v_sql || 'CST_PIS             VARCHAR2(2), '; --
        v_sql := v_sql || 'VLR_BASE_PIS        NUMBER(17,2), '; --
        v_sql := v_sql || 'VLR_ALIQ_PIS        NUMBER(5,2), '; --
        v_sql := v_sql || 'VLR_PIS             NUMBER(17,2), '; --
        v_sql := v_sql || 'CST_COFINS          VARCHAR2(2), '; --
        v_sql := v_sql || 'VLR_BASE_COFINS     NUMBER(17,2), '; --
        v_sql := v_sql || 'VLR_ALIQ_COFINS     NUMBER(5,2), '; --
        v_sql := v_sql || 'VLR_COFINS          NUMBER(17,2), '; --
        v_sql := v_sql || 'VLR_BASE_ICMS       NUMBER(17,2), ';
        v_sql := v_sql || 'VLR_ALIQ_ICMS       NUMBER(5,2), ';
        v_sql := v_sql || 'VLR_ICMS            NUMBER(17,2)) ';

        v_sql := v_sql || 'PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;
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
        v_sql := v_sql || '  SERIE_DOCFIS ASC ';
        v_sql := v_sql || ') ';
        v_sql := v_sql || 'PCTFREE     10 ';

        BEGIN
            EXECUTE IMMEDIATE v_sql;
        EXCEPTION
            WHEN OTHERS THEN
                raise_application_error ( -20005
                                        , '!ERRO CRIACAO UNIQUE IDX SAIDA!' );
        END;

        v_sql := 'CREATE INDEX IDX1_DPSP_S_' || vp_proc_instance || ' ON ' || vp_tabela_saida || ' ';
        v_sql := v_sql || '  ( ';
        v_sql := v_sql || '    PROC_ID      ASC ';
        v_sql := v_sql || '  ) ';
        v_sql := v_sql || '  PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX2_DPSP_S_' || vp_proc_instance || ' ON ' || vp_tabela_saida || ' ';
        v_sql := v_sql || '  ( ';
        v_sql := v_sql || '    COD_PRODUTO      ASC, ';
        v_sql := v_sql || '    DATA_FISCAL      ASC ';
        v_sql := v_sql || '  ) ';
        v_sql := v_sql || '  PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_tabela_saida );
        loga ( ' - ' || vp_tabela_saida || ' CRIADA'
             , FALSE );
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
        v_sql := v_sql || ' VLR_ICMSS_N_ESCRIT  NUMBER(17,2), ';
        v_sql := v_sql || ' COD_SITUACAO_B      VARCHAR2(2), ';
        v_sql := v_sql || ' DATA_EMISSAO        DATE, ';
        v_sql := v_sql || ' COD_ESTADO          VARCHAR2(2), ';
        v_sql := v_sql || ' NUM_CONTROLE_DOCTO  VARCHAR2(12), ';
        v_sql := v_sql || ' NUM_AUTENTIC_NFE    VARCHAR2(80), ';
        v_sql := v_sql || ' VLR_ITEM            NUMBER(17,2), '; --
        v_sql := v_sql || ' VLR_OUTRAS          NUMBER(17,2), '; --
        v_sql := v_sql || ' VLR_DESCONTO        NUMBER(17,2), '; --
        v_sql := v_sql || ' CST_PIS             VARCHAR2(2), '; --
        v_sql := v_sql || ' VLR_BASE_PIS        NUMBER(17,2), '; --
        v_sql := v_sql || ' VLR_ALIQ_PIS        NUMBER(5,2), '; --
        v_sql := v_sql || ' VLR_PIS             NUMBER(17,2), '; --
        v_sql := v_sql || ' CST_COFINS          VARCHAR2(2), '; --
        v_sql := v_sql || ' VLR_BASE_COFINS     NUMBER(17,2), '; --
        v_sql := v_sql || ' VLR_ALIQ_COFINS     NUMBER(5,2), '; --
        v_sql := v_sql || ' VLR_COFINS          NUMBER(17,2), '; --
        v_sql := v_sql || ' VLR_BASE_ICMS       NUMBER(17,2), ';
        v_sql := v_sql || ' VLR_ICMS            NUMBER(17,2), ';
        v_sql := v_sql || ' VLR_BASE_ICMSS      NUMBER(17,2), ';
        v_sql := v_sql || ' VLR_ICMSS           NUMBER(17,2)) ';
        v_sql := v_sql || ' PCTFREE     10 ';

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

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_tab_entrada_cd );
        loga ( ' - ' || vp_tab_entrada_cd || ' CRIADA'
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
        v_sql := v_sql || ' VLR_ICMSS_N_ESCRIT  NUMBER(17,2), ';
        v_sql := v_sql || ' COD_SITUACAO_B      VARCHAR2(2), ';
        v_sql := v_sql || ' DATA_EMISSAO        DATE, ';
        v_sql := v_sql || ' COD_ESTADO          VARCHAR2(2), ';
        v_sql := v_sql || ' NUM_CONTROLE_DOCTO  VARCHAR2(12), ';
        v_sql := v_sql || ' NUM_AUTENTIC_NFE    VARCHAR2(80), ';
        v_sql := v_sql || ' VLR_ITEM            NUMBER(17,2), '; --
        v_sql := v_sql || ' VLR_OUTRAS          NUMBER(17,2), '; --
        v_sql := v_sql || ' VLR_DESCONTO        NUMBER(17,2), '; --
        v_sql := v_sql || ' CST_PIS             VARCHAR2(2), '; --
        v_sql := v_sql || ' VLR_BASE_PIS        NUMBER(17,2), '; --
        v_sql := v_sql || ' VLR_ALIQ_PIS        NUMBER(5,2), '; --
        v_sql := v_sql || ' VLR_PIS             NUMBER(17,2), '; --
        v_sql := v_sql || ' CST_COFINS          VARCHAR2(2), '; --
        v_sql := v_sql || ' VLR_BASE_COFINS     NUMBER(17,2), '; --
        v_sql := v_sql || ' VLR_ALIQ_COFINS     NUMBER(5,2), '; --
        v_sql := v_sql || ' VLR_COFINS          NUMBER(17,2), '; --
        v_sql := v_sql || ' VLR_BASE_ICMS       NUMBER(17,2), ';
        v_sql := v_sql || ' VLR_ICMS            NUMBER(17,2), ';
        v_sql := v_sql || ' VLR_BASE_ICMSS      NUMBER(17,2), ';
        v_sql := v_sql || ' VLR_ICMSS           NUMBER(17,2)) ';
        v_sql := v_sql || ' PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        save_tmp_control ( vp_proc_instance
                         , vp_tab_entrada_f );
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

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_tab_entrada_f );
        loga ( ' - ' || vp_tab_entrada_f || ' CRIADA'
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
        v_sql := v_sql || ' VLR_ICMSS_N_ESCRIT  NUMBER(17,2), ';
        v_sql := v_sql || ' COD_SITUACAO_B      VARCHAR2(2), ';
        v_sql := v_sql || ' DATA_EMISSAO        DATE, ';
        v_sql := v_sql || ' COD_ESTADO          VARCHAR2(2), ';
        v_sql := v_sql || ' NUM_CONTROLE_DOCTO  VARCHAR2(12), ';
        v_sql := v_sql || ' NUM_AUTENTIC_NFE    VARCHAR2(80), ';
        v_sql := v_sql || ' VLR_ITEM            NUMBER(17,2), '; --
        v_sql := v_sql || ' VLR_OUTRAS          NUMBER(17,2), '; --
        v_sql := v_sql || ' VLR_DESCONTO        NUMBER(17,2), '; --
        v_sql := v_sql || ' CST_PIS             VARCHAR2(2), '; --
        v_sql := v_sql || ' VLR_BASE_PIS        NUMBER(17,2), '; --
        v_sql := v_sql || ' VLR_ALIQ_PIS        NUMBER(5,2), '; --
        v_sql := v_sql || ' VLR_PIS             NUMBER(17,2), '; --
        v_sql := v_sql || ' CST_COFINS          VARCHAR2(2), '; --
        v_sql := v_sql || ' VLR_BASE_COFINS     NUMBER(17,2), '; --
        v_sql := v_sql || ' VLR_ALIQ_COFINS     NUMBER(5,2), '; --
        v_sql := v_sql || ' VLR_COFINS          NUMBER(17,2), '; --
        v_sql := v_sql || ' VLR_BASE_ICMS       NUMBER(17,2), ';
        v_sql := v_sql || ' VLR_ICMS            NUMBER(17,2), ';
        v_sql := v_sql || ' VLR_BASE_ICMSS      NUMBER(17,2), ';
        v_sql := v_sql || ' VLR_ICMSS           NUMBER(17,2)) ';
        v_sql := v_sql || ' PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        save_tmp_control ( vp_proc_instance
                         , vp_tab_entrada_co );
    END;

    PROCEDURE create_tab_entrada_co_idx ( vp_proc_instance IN NUMBER
                                        , vp_tab_entrada_co IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 1000 );
    BEGIN
        v_sql := 'CREATE UNIQUE INDEX PK_DPSP_E_CO_' || vp_proc_instance || ' ON ' || vp_tab_entrada_co || ' ';
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
        loga ( ' - ' || vp_tab_entrada_co || ' CRIADA'
             , FALSE );
    END;

    PROCEDURE load_saidas ( vp_proc_instance IN VARCHAR2
                          , vp_cod_estab IN VARCHAR2
                          , vp_data_ini IN DATE
                          , vp_data_fim IN DATE
                          , p_uf IN VARCHAR2
                          , vp_tabela_saida IN VARCHAR2 )
    IS
        --RANGE DE DATAS PARA BUSCAR VENDAS
        v_data_inicial DATE := vp_data_ini; -- DATA INICIAL
        v_data_final DATE := vp_data_fim; -- DATA FINAL
        --
        v_sql VARCHAR2 ( 10000 );
        tipo VARCHAR2 ( 1 );

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
        FOR cd IN c_data_saida ( v_data_inicial
                               , v_data_final ) LOOP
            SELECT tipo
              INTO tipo
              FROM msafi.dsp_estabelecimento
             WHERE cod_empresa = msafi.dpsp.empresa
               AND cod_estado = p_uf
               AND cod_estab = vp_cod_estab;

            --CARREGAR INFORMACOES DE VENDAS
            v_sql :=
                ' INSERT /*+APPEND*/ INTO ' || vp_tabela_saida || ' (SELECT DISTINCT ''' || vp_proc_instance || ''', ';
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
            v_sql := v_sql || ' ITEM.QUANTIDADE, ';
            v_sql := v_sql || ' NCM.COD_NBM, ';
            v_sql := v_sql || ' CFOP.COD_CFO, ';
            v_sql := v_sql || ' GRP.DESCRICAO, ';
            v_sql := v_sql || ' ITEM.VLR_DESCONTO, ';
            v_sql := v_sql || ' ITEM.VLR_CONTAB_ITEM, ';

            v_sql := v_sql || ' ITEM.VLR_ITEM, '; --
            v_sql := v_sql || ' ITEM.VLR_OUTRAS, '; --

            v_sql := v_sql || ' '''' || DOC.NUM_AUTENTIC_NFE, ';

            v_sql := v_sql || ' ITEM.COD_SITUACAO_PIS CST_PIS, '; --
            v_sql := v_sql || ' ITEM.VLR_BASE_PIS    , '; --
            v_sql := v_sql || ' ITEM.VLR_ALIQ_PIS    , '; --
            v_sql := v_sql || ' ITEM.VLR_PIS         , '; --
            v_sql := v_sql || ' ITEM.COD_SITUACAO_COFINS CST_COFINS      , '; --
            v_sql := v_sql || ' ITEM.VLR_BASE_COFINS , '; --
            v_sql := v_sql || ' ITEM.VLR_ALIQ_COFINS , '; --
            v_sql := v_sql || ' ITEM.VLR_COFINS      , '; --

            v_sql := v_sql || ' NVL((SELECT VLR_BASE ';
            v_sql := v_sql || '      FROM MSAF.X08_BASE_MERC G ';
            v_sql := v_sql || '      WHERE G.COD_EMPRESA = ITEM.COD_EMPRESA ';
            v_sql := v_sql || '        AND G.COD_ESTAB = ITEM.COD_ESTAB ';
            v_sql := v_sql || '        AND G.DATA_FISCAL = ITEM.DATA_FISCAL ';
            v_sql := v_sql || '        AND G.MOVTO_E_S = ITEM.MOVTO_E_S ';
            v_sql := v_sql || '        AND G.NORM_DEV = ITEM.NORM_DEV ';
            v_sql := v_sql || '        AND G.IDENT_DOCTO = ITEM.IDENT_DOCTO ';
            v_sql := v_sql || '        AND G.IDENT_FIS_JUR = ITEM.IDENT_FIS_JUR ';
            v_sql := v_sql || '        AND G.NUM_DOCFIS = ITEM.NUM_DOCFIS ';
            v_sql := v_sql || '        AND G.SERIE_DOCFIS = ITEM.SERIE_DOCFIS ';
            v_sql := v_sql || '        AND G.SUB_SERIE_DOCFIS = ITEM.SUB_SERIE_DOCFIS ';
            v_sql := v_sql || '        AND G.DISCRI_ITEM = ITEM.DISCRI_ITEM ';
            v_sql := v_sql || '        AND G.COD_TRIBUTACAO = ''1'' ';
            v_sql := v_sql || '        AND G.COD_TRIBUTO = ''ICMS''),0) VLR_BASE_ICMS, ';
            v_sql := v_sql || ' NVL((SELECT ALIQ_TRIBUTO ';
            v_sql := v_sql || '      FROM MSAF.X08_TRIB_MERC IT  ';
            v_sql := v_sql || '      WHERE   ITEM.COD_EMPRESA = IT.COD_EMPRESA  ';
            v_sql := v_sql || '          AND ITEM.COD_ESTAB = IT.COD_ESTAB  ';
            v_sql := v_sql || '          AND ITEM.DATA_FISCAL = IT.DATA_FISCAL ';
            v_sql := v_sql || '          AND ITEM.MOVTO_E_S = IT.MOVTO_E_S  ';
            v_sql := v_sql || '          AND ITEM.NORM_DEV = IT.NORM_DEV  ';
            v_sql := v_sql || '          AND ITEM.IDENT_DOCTO = IT.IDENT_DOCTO  ';
            v_sql := v_sql || '          AND ITEM.IDENT_FIS_JUR = IT.IDENT_FIS_JUR ';
            v_sql := v_sql || '          AND ITEM.NUM_DOCFIS = IT.NUM_DOCFIS  ';
            v_sql := v_sql || '          AND ITEM.SERIE_DOCFIS = IT.SERIE_DOCFIS ';
            v_sql := v_sql || '          AND ITEM.SUB_SERIE_DOCFIS = IT.SUB_SERIE_DOCFIS ';
            v_sql := v_sql || '          AND ITEM.DISCRI_ITEM = IT.DISCRI_ITEM ';
            v_sql := v_sql || '          AND IT.COD_TRIBUTO = ''ICMS''),0) ALIQ_ICMS, ';
            v_sql := v_sql || ' NVL((SELECT VLR_TRIBUTO  ';
            v_sql := v_sql || '		 FROM MSAF.X08_TRIB_MERC IT  ';
            v_sql := v_sql || '		 WHERE   ITEM.COD_EMPRESA = IT.COD_EMPRESA  ';
            v_sql := v_sql || '		     AND ITEM.COD_ESTAB = IT.COD_ESTAB  ';
            v_sql := v_sql || '		     AND ITEM.DATA_FISCAL = IT.DATA_FISCAL ';
            v_sql := v_sql || '		     AND ITEM.MOVTO_E_S = IT.MOVTO_E_S  ';
            v_sql := v_sql || '		     AND ITEM.NORM_DEV = IT.NORM_DEV  ';
            v_sql := v_sql || '		     AND ITEM.IDENT_DOCTO = IT.IDENT_DOCTO  ';
            v_sql := v_sql || '		     AND ITEM.IDENT_FIS_JUR = IT.IDENT_FIS_JUR  ';
            v_sql := v_sql || '		     AND ITEM.NUM_DOCFIS = IT.NUM_DOCFIS  ';
            v_sql := v_sql || '		     AND ITEM.SERIE_DOCFIS = IT.SERIE_DOCFIS ';
            v_sql := v_sql || '		     AND ITEM.SUB_SERIE_DOCFIS = IT.SUB_SERIE_DOCFIS ';
            v_sql := v_sql || '		     AND ITEM.DISCRI_ITEM = IT.DISCRI_ITEM ';
            v_sql := v_sql || '		     AND IT.COD_TRIBUTO = ''ICMS''),0) VLR_ICMS ';
            ---
            v_sql := v_sql || ' FROM MSAF.X08_ITENS_MERC ITEM, ';
            v_sql := v_sql || ' MSAF.X07_DOCTO_FISCAL  DOC, ';
            v_sql := v_sql || ' MSAF.X2013_PRODUTO     PRD, ';
            v_sql := v_sql || ' MSAF.ESTABELECIMENTO   EST, ';
            v_sql := v_sql || ' MSAF.ESTADO            UFEST, ';
            v_sql := v_sql || ' MSAF.X2043_COD_NBM     NCM, ';
            v_sql := v_sql || ' MSAF.X2012_COD_FISCAL  CFOP, ';
            v_sql := v_sql || ' MSAF.GRUPO_PRODUTO     GRP, ';
            v_sql := v_sql || ' MSAF.X2005_TIPO_DOCTO  TIP ';

            v_sql := v_sql || ' WHERE ITEM.COD_EMPRESA = ''' || mcod_empresa || ''' ';
            v_sql := v_sql || '   AND ITEM.COD_ESTAB   = ''' || vp_cod_estab || ''' ';
            v_sql := v_sql || '   AND ITEM.DATA_FISCAL = TO_DATE(''' || cd.data_normal || ''',''DD/MM/YYYY'') ';

            IF tipo = 'L' THEN
                v_sql :=
                       v_sql
                    || '   AND ITEM.IDENT_DOCTO IN (SELECT IDENT_DOCTO FROM MSAF.X2005_TIPO_DOCTO WHERE COD_DOCTO IN (''CF-E'',''SAT'')) ';
            ELSE
                v_sql :=
                       v_sql
                    || '   AND ITEM.IDENT_DOCTO NOT IN (SELECT IDENT_DOCTO FROM MSAF.X2005_TIPO_DOCTO WHERE COD_DOCTO IN (''CF-E'',''SAT'')) ';
            END IF;

            v_sql := v_sql || '   AND CFOP.COD_CFO IN (''5102'', ''6102'', ''5403'', ''6403'', ''5405'') ';

            v_sql := v_sql || '   AND DOC.COD_EMPRESA         = EST.COD_EMPRESA ';
            v_sql := v_sql || '   AND DOC.COD_ESTAB           = EST.COD_ESTAB ';
            v_sql := v_sql || '   AND EST.IDENT_ESTADO        = UFEST.IDENT_ESTADO ';
            v_sql := v_sql || '   AND ITEM.IDENT_PRODUTO      = PRD.IDENT_PRODUTO ';
            v_sql := v_sql || '   AND PRD.IDENT_NBM           = NCM.IDENT_NBM ';
            v_sql := v_sql || '   AND ITEM.IDENT_CFO          = CFOP.IDENT_CFO ';
            v_sql := v_sql || '   AND PRD.IDENT_GRUPO_PROD    = GRP.IDENT_GRUPO_PROD ';
            v_sql := v_sql || '   AND DOC.IDENT_DOCTO         = TIP.IDENT_DOCTO ';
            v_sql := v_sql || '   AND DOC.SITUACAO           <> ''S'' ';

            v_sql := v_sql || '   AND ITEM.COD_EMPRESA       = DOC.COD_EMPRESA ';
            v_sql := v_sql || '   AND ITEM.COD_ESTAB         = DOC.COD_ESTAB ';
            v_sql := v_sql || '   AND ITEM.DATA_FISCAL       = DOC.DATA_FISCAL ';
            v_sql := v_sql || '   AND ITEM.MOVTO_E_S         = DOC.MOVTO_E_S ';
            v_sql := v_sql || '   AND ITEM.NORM_DEV          = DOC.NORM_DEV ';
            v_sql := v_sql || '   AND ITEM.IDENT_DOCTO       = DOC.IDENT_DOCTO ';
            v_sql := v_sql || '   AND ITEM.IDENT_FIS_JUR     = DOC.IDENT_FIS_JUR ';
            v_sql := v_sql || '   AND ITEM.NUM_DOCFIS        = DOC.NUM_DOCFIS ';
            v_sql := v_sql || '   AND ITEM.SERIE_DOCFIS      = DOC.SERIE_DOCFIS ';
            v_sql := v_sql || '   AND ITEM.SUB_SERIE_DOCFIS  = DOC.SUB_SERIE_DOCFIS ';

            v_sql := v_sql || 'UNION ALL ';

            v_sql := v_sql || ' SELECT /*+STAR(X994)*/ ''' || vp_proc_instance || ''', ';
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
            v_sql := v_sql || '  X994.QTDE                QTD_VENDIDA, ';
            v_sql := v_sql || '  NCM.COD_NBM              NCM, ';
            v_sql := v_sql || '  X2012.COD_CFO            CFOP, ';
            v_sql := v_sql || '  GRP.DESCRICAO            GRUPO_PRD, ';
            v_sql := v_sql || '  X994.VLR_DESC            VLR_DESCONTO, ';
            v_sql := v_sql || '  X994.VLR_LIQ_ITEM        VALOR_CONTAB, ';

            v_sql := v_sql || '  X994.VLR_ITEM            VLR_ITEM, '; --
            v_sql := v_sql || '  X994.VLR_ACRES           VALOR_OUTRAS, '; --

            v_sql := v_sql || '  ''-''                    CHAVE_ACESSO, ';

            v_sql := v_sql || '  X994.COD_SIT_TRIB_PIS,    '; --
            v_sql := v_sql || '  X994.VLR_BASE_PIS,        '; --
            v_sql := v_sql || '  X994.VLR_ALIQ_PIS,        '; --
            v_sql := v_sql || '  X994.VLR_PIS,             '; --
            v_sql := v_sql || '  X994.COD_SIT_TRIB_COFINS, '; --
            v_sql := v_sql || '  X994.VLR_BASE_COFINS,     '; --
            v_sql := v_sql || '  X994.VLR_ALIQ_COFINS,     '; --
            v_sql := v_sql || '  X994.VLR_COFINS,          '; --

            v_sql := v_sql || '  X994.VLR_BASE       VLR_BASE_ICMS, ';
            v_sql := v_sql || '  X996.VLR_ALIQ ALIQ_ICMS, ';
            v_sql := v_sql || '  X994.VLR_TRIBUTO    VLR_ICMS ';
            ---
            v_sql := v_sql || 'FROM MSAF.X993_CAPA_CUPOM_ECF   X993 ';
            v_sql := v_sql || '    ,MSAF.X994_ITEM_CUPOM_ECF   X994 ';
            v_sql := v_sql || '    ,MSAF.X996_TOTALIZADOR_PARCIAL_ECF X996 ';
            v_sql := v_sql || '    ,MSAF.X2087_EQUIPAMENTO_ECF X2087 ';
            v_sql := v_sql || '    ,MSAF.ESTABELECIMENTO       EST ';
            v_sql := v_sql || '    ,MSAF.ESTADO                UF_EST ';
            v_sql := v_sql || '    ,MSAF.X2013_PRODUTO         X2013 ';
            v_sql := v_sql || '    ,MSAF.X2012_COD_FISCAL      X2012 ';
            v_sql := v_sql || '    ,MSAF.X2043_COD_NBM         NCM ';
            v_sql := v_sql || '    ,MSAF.GRUPO_PRODUTO         GRP ';

            v_sql := v_sql || 'WHERE X994.COD_EMPRESA  = ''' || mcod_empresa || ''' ';
            v_sql := v_sql || '  AND X994.COD_ESTAB    = ''' || vp_cod_estab || ''' ';
            v_sql := v_sql || '  AND X994.DATA_EMISSAO = TO_DATE(''' || cd.data_normal || ''',''DD/MM/YYYY'') ';
            v_sql := v_sql || '  AND X993.IND_SITUACAO_CUPOM = ''1'' ';

            v_sql := v_sql || '   AND X2012.COD_CFO IN (''5102'', ''6102'', ''5403'', ''6403'', ''5405'') ';

            v_sql := v_sql || '  AND X994.COD_EMPRESA           = X996.COD_EMPRESA ';
            v_sql := v_sql || '  AND X994.COD_ESTAB             = X996.COD_ESTAB ';
            v_sql := v_sql || '  AND X994.IDENT_TOTALIZADOR_ECF = X996.IDENT_TOTALIZADOR_ECF ';

            v_sql := v_sql || '  AND X2087.COD_EMPRESA       = X993.COD_EMPRESA ';
            v_sql := v_sql || '  AND X2087.COD_ESTAB         = X993.COD_ESTAB ';
            v_sql := v_sql || '  AND X2087.IDENT_CAIXA_ECF   = X993.IDENT_CAIXA_ECF ';

            v_sql := v_sql || '  AND X994.COD_EMPRESA        = X993.COD_EMPRESA ';
            v_sql := v_sql || '  AND X994.COD_ESTAB          = X993.COD_ESTAB ';
            v_sql := v_sql || '  AND X994.IDENT_CAIXA_ECF    = X993.IDENT_CAIXA_ECF ';
            v_sql := v_sql || '  AND X994.NUM_COO            = X993.NUM_COO ';
            v_sql := v_sql || '  AND X994.DATA_EMISSAO       = X993.DATA_EMISSAO ';

            v_sql := v_sql || '  AND X2013.IDENT_PRODUTO     = X994.IDENT_PRODUTO ';
            v_sql := v_sql || '  AND X2012.IDENT_CFO         = X994.IDENT_CFO ';
            v_sql := v_sql || '  AND EST.COD_EMPRESA         = X993.COD_EMPRESA ';
            v_sql := v_sql || '  AND EST.COD_ESTAB           = X993.COD_ESTAB ';
            v_sql := v_sql || '  AND X2013.IDENT_NBM         = NCM.IDENT_NBM ';
            v_sql := v_sql || '  AND X2013.IDENT_GRUPO_PROD  = GRP.IDENT_GRUPO_PROD ';
            v_sql := v_sql || '  AND EST.IDENT_ESTADO        = UF_EST.IDENT_ESTADO ';

            v_sql := v_sql || '  AND X994.IND_SITUACAO_ITEM  = ''1'') ';

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
                    ---
                    raise_application_error ( -20022
                                            , '!ERRO INSERT LOAD_SAIDAS!' );
            END;

            COMMIT;
        END LOOP;

        loga ( 'LOAD_SAIDAS-FIM-' || vp_cod_estab
             , FALSE );
    END;

    PROCEDURE load_entradas ( vp_proc_instance IN VARCHAR2
                            , vp_cod_estab IN VARCHAR2
                            , vp_origem IN VARCHAR2
                            , vp_tabela_entrada IN VARCHAR2
                            , vp_tabela_saida IN VARCHAR2
                            , vp_data_fim IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 10000 );
        c_entrada SYS_REFCURSOR;

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
    BEGIN
        IF ( vp_origem = 'C' ) THEN
            --CD

            v_sql := v_sql || 'SELECT DISTINCT ''' || vp_proc_instance || ''', ';
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
            v_sql := v_sql || ' FROM ( ';
            v_sql :=
                   v_sql
                || '     SELECT  /*+INDEX(D PK_X2013_PRODUTO) INDEX(A PK_X2043_COD_NBM) INDEX(G PK_X04_PESSOA_FIS_JUR) */ ';
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
            v_sql := v_sql || '              X08.VLR_ICMSS_N_ESCRIT, ';
            v_sql := v_sql || '              E.COD_SITUACAO_B, ';
            v_sql := v_sql || '              X07.DATA_EMISSAO, ';
            v_sql := v_sql || '              H.COD_ESTADO, ';
            v_sql := v_sql || '              X07.NUM_CONTROLE_DOCTO, ';
            v_sql := v_sql || '      '''' || X07.NUM_AUTENTIC_NFE AS NUM_AUTENTIC_NFE, ';
            v_sql := v_sql || 'NVL((SELECT VLR_BASE ';
            v_sql := v_sql || '          FROM X08_BASE_MERC IT ';
            v_sql := v_sql || '         WHERE X08.COD_EMPRESA = IT.COD_EMPRESA ';
            v_sql := v_sql || '             AND X08.COD_ESTAB = IT.COD_ESTAB ';
            v_sql := v_sql || '             AND X08.DATA_FISCAL = IT.DATA_FISCAL ';
            v_sql := v_sql || '             AND X08.MOVTO_E_S = IT.MOVTO_E_S ';
            v_sql := v_sql || '             AND X08.NORM_DEV = IT.NORM_DEV ';
            v_sql := v_sql || '             AND X08.IDENT_DOCTO = IT.IDENT_DOCTO ';
            v_sql := v_sql || '             AND X08.IDENT_FIS_JUR = IT.IDENT_FIS_JUR ';
            v_sql := v_sql || '             AND X08.NUM_DOCFIS = IT.NUM_DOCFIS ';
            v_sql := v_sql || '             AND X08.SERIE_DOCFIS = IT.SERIE_DOCFIS ';
            v_sql := v_sql || '             AND X08.SUB_SERIE_DOCFIS = IT.SUB_SERIE_DOCFIS ';
            v_sql := v_sql || '             AND X08.DISCRI_ITEM = IT.DISCRI_ITEM ';
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
            v_sql := v_sql || '      AND X08.SUB_SERIE_DOCFIS = IT.SUB_SERIE_DOCFIS ';
            v_sql := v_sql || '      AND X08.DISCRI_ITEM = IT.DISCRI_ITEM ';
            v_sql := v_sql || '      AND IT.COD_TRIBUTO = ''ICMS'') VLR_ICMS, ';
            v_sql := v_sql || 'NVL((SELECT VLR_BASE ';
            v_sql := v_sql || '          FROM X08_BASE_MERC IT ';
            v_sql := v_sql || '         WHERE X08.COD_EMPRESA = IT.COD_EMPRESA ';
            v_sql := v_sql || '             AND X08.COD_ESTAB = IT.COD_ESTAB ';
            v_sql := v_sql || '             AND X08.DATA_FISCAL = IT.DATA_FISCAL ';
            v_sql := v_sql || '             AND X08.MOVTO_E_S = IT.MOVTO_E_S ';
            v_sql := v_sql || '             AND X08.NORM_DEV = IT.NORM_DEV ';
            v_sql := v_sql || '             AND X08.IDENT_DOCTO = IT.IDENT_DOCTO ';
            v_sql := v_sql || '             AND X08.IDENT_FIS_JUR = IT.IDENT_FIS_JUR ';
            v_sql := v_sql || '             AND X08.NUM_DOCFIS = IT.NUM_DOCFIS ';
            v_sql := v_sql || '             AND X08.SERIE_DOCFIS = IT.SERIE_DOCFIS ';
            v_sql := v_sql || '             AND X08.SUB_SERIE_DOCFIS = IT.SUB_SERIE_DOCFIS ';
            v_sql := v_sql || '             AND X08.DISCRI_ITEM = IT.DISCRI_ITEM ';
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
            v_sql := v_sql || '      AND X08.SUB_SERIE_DOCFIS = IT.SUB_SERIE_DOCFIS ';
            v_sql := v_sql || '      AND X08.DISCRI_ITEM = IT.DISCRI_ITEM ';
            v_sql := v_sql || '      AND IT.COD_TRIBUTO = ''ICMS-S'') VLR_ICMSS, ';

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

            v_sql := v_sql || '              RANK() OVER( ';
            v_sql :=
                   v_sql
                || '                   PARTITION BY X08.COD_ESTAB, P.DATA_FISCAL, D.COD_PRODUTO, SIGN(X08.VLR_ICMSS_N_ESCRIT) ';
            v_sql :=
                   v_sql
                || '                   ORDER BY X08.DATA_FISCAL DESC, X07.DATA_EMISSAO DESC, X08.NUM_DOCFIS, X08.DISCRI_ITEM) RANK ';
            v_sql := v_sql || '        FROM X08_ITENS_MERC X08, ';
            v_sql := v_sql || '             X07_DOCTO_FISCAL X07, ';
            v_sql := v_sql || '             X2013_PRODUTO D, ';
            v_sql := v_sql || '             X04_PESSOA_FIS_JUR G, ';
            v_sql := v_sql || '     (SELECT DISTINCT TMP.COD_PRODUTO, TMP.DATA_FISCAL AS DATA_FISCAL ';
            v_sql := v_sql || '              FROM ' || vp_tabela_saida || ' TMP ';
            v_sql := v_sql || '              WHERE TMP.PROC_ID   = ''' || vp_proc_instance || ''' ) P, ';
            v_sql := v_sql || '             X2043_COD_NBM A, ';
            v_sql := v_sql || '             X2012_COD_FISCAL B, ';
            v_sql := v_sql || '             X2006_NATUREZA_OP C, ';
            v_sql := v_sql || '             Y2026_SIT_TRB_UF_B E, ';
            v_sql := v_sql || '             ESTADO H  ';
            ---
            v_sql := v_sql || ' WHERE X08.IDENT_NBM          = A.IDENT_NBM ';
            v_sql := v_sql || '  AND X08.IDENT_CFO          = B.IDENT_CFO ';
            v_sql := v_sql || '  AND X08.IDENT_NATUREZA_OP  = C.IDENT_NATUREZA_OP ';
            v_sql := v_sql || '  AND X08.IDENT_SITUACAO_B   = E.IDENT_SITUACAO_B ';
            v_sql := v_sql || '  AND X07.VLR_PRODUTO       <> 0 ';
            v_sql := v_sql || '  AND X08.IDENT_PRODUTO      = D.IDENT_PRODUTO ';
            v_sql := v_sql || '  AND X07.IDENT_FIS_JUR      = G.IDENT_FIS_JUR ';
            v_sql := v_sql || '  AND G.IDENT_ESTADO         = H.IDENT_ESTADO ';
            ---
            v_sql := v_sql || '  AND X07.COD_EMPRESA        = X08.COD_EMPRESA ';
            v_sql := v_sql || '  AND X07.COD_ESTAB          = X08.COD_ESTAB ';
            v_sql := v_sql || '  AND X07.DATA_FISCAL        = X08.DATA_FISCAL ';
            v_sql := v_sql || '  AND X07.MOVTO_E_S          = X08.MOVTO_E_S ';
            v_sql := v_sql || '  AND X07.NORM_DEV           = X08.NORM_DEV ';
            v_sql := v_sql || '  AND X07.IDENT_DOCTO        = X08.IDENT_DOCTO ';
            v_sql := v_sql || '  AND X07.IDENT_FIS_JUR      = X08.IDENT_FIS_JUR ';
            v_sql := v_sql || '  AND X07.NUM_DOCFIS         = X08.NUM_DOCFIS ';
            v_sql := v_sql || '  AND X07.SERIE_DOCFIS       = X08.SERIE_DOCFIS ';
            v_sql := v_sql || '  AND X07.SUB_SERIE_DOCFIS   = X08.SUB_SERIE_DOCFIS ';
            ---
            v_sql := v_sql || '  AND X08.MOVTO_E_S         <> ''9'' ';
            v_sql := v_sql || '  AND X08.NORM_DEV           = ''1'' ';
            v_sql := v_sql || '  AND X08.COD_EMPRESA        = ''' || mcod_empresa || ''' ';
            v_sql := v_sql || '  AND X08.COD_ESTAB          = ''' || vp_cod_estab || ''' ';

            v_sql := v_sql || '  AND D.COD_PRODUTO          = P.COD_PRODUTO ';
            v_sql := v_sql || '  AND X08.DATA_FISCAL        < P.DATA_FISCAL ';
            v_sql := v_sql || '  AND X08.DATA_FISCAL       >= ''' || vp_data_fim || ''' '; --ULTIMOS 2 ANOS

            v_sql := v_sql || '       ) A ';
            v_sql := v_sql || ' WHERE A.RANK = 1 ';
        ELSIF ( vp_origem = 'F' ) THEN
            --FILIAL

            v_sql := v_sql || 'SELECT ''' || vp_proc_instance || ''', ';
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
            v_sql := v_sql || ' FROM ( ';
            v_sql :=
                   v_sql
                || '     SELECT  /*+INDEX(D PK_X2013_PRODUTO) INDEX(A PK_X2043_COD_NBM) INDEX(G PK_X04_PESSOA_FIS_JUR) */ ';
            v_sql := v_sql || '              DISTINCT X08.COD_EMPRESA, ';
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
            v_sql := v_sql || '       '''' || X07.NUM_AUTENTIC_NFE AS NUM_AUTENTIC_NFE, ';
            v_sql := v_sql || 'NVL((SELECT VLR_BASE ';
            v_sql := v_sql || '          FROM X08_BASE_MERC IT ';
            v_sql := v_sql || '         WHERE X08.COD_EMPRESA = IT.COD_EMPRESA ';
            v_sql := v_sql || '             AND X08.COD_ESTAB = IT.COD_ESTAB ';
            v_sql := v_sql || '             AND X08.DATA_FISCAL = IT.DATA_FISCAL ';
            v_sql := v_sql || '             AND X08.MOVTO_E_S = IT.MOVTO_E_S ';
            v_sql := v_sql || '             AND X08.NORM_DEV = IT.NORM_DEV ';
            v_sql := v_sql || '             AND X08.IDENT_DOCTO = IT.IDENT_DOCTO ';
            v_sql := v_sql || '             AND X08.IDENT_FIS_JUR = IT.IDENT_FIS_JUR ';
            v_sql := v_sql || '             AND X08.NUM_DOCFIS = IT.NUM_DOCFIS ';
            v_sql := v_sql || '             AND X08.SERIE_DOCFIS = IT.SERIE_DOCFIS ';
            v_sql := v_sql || '             AND X08.SUB_SERIE_DOCFIS = IT.SUB_SERIE_DOCFIS ';
            v_sql := v_sql || '             AND X08.DISCRI_ITEM = IT.DISCRI_ITEM ';
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
            v_sql := v_sql || '      AND X08.SUB_SERIE_DOCFIS = IT.SUB_SERIE_DOCFIS ';
            v_sql := v_sql || '      AND X08.DISCRI_ITEM = IT.DISCRI_ITEM ';
            v_sql := v_sql || '      AND IT.COD_TRIBUTO = ''ICMS'') VLR_ICMS, ';
            v_sql := v_sql || 'NVL((SELECT VLR_BASE ';
            v_sql := v_sql || '          FROM X08_BASE_MERC IT ';
            v_sql := v_sql || '         WHERE X08.COD_EMPRESA = IT.COD_EMPRESA ';
            v_sql := v_sql || '             AND X08.COD_ESTAB = IT.COD_ESTAB ';
            v_sql := v_sql || '             AND X08.DATA_FISCAL = IT.DATA_FISCAL ';
            v_sql := v_sql || '             AND X08.MOVTO_E_S = IT.MOVTO_E_S ';
            v_sql := v_sql || '             AND X08.NORM_DEV = IT.NORM_DEV ';
            v_sql := v_sql || '             AND X08.IDENT_DOCTO = IT.IDENT_DOCTO ';
            v_sql := v_sql || '             AND X08.IDENT_FIS_JUR = IT.IDENT_FIS_JUR ';
            v_sql := v_sql || '             AND X08.NUM_DOCFIS = IT.NUM_DOCFIS ';
            v_sql := v_sql || '             AND X08.SERIE_DOCFIS = IT.SERIE_DOCFIS ';
            v_sql := v_sql || '             AND X08.SUB_SERIE_DOCFIS = IT.SUB_SERIE_DOCFIS ';
            v_sql := v_sql || '             AND X08.DISCRI_ITEM = IT.DISCRI_ITEM ';
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
            v_sql := v_sql || '      AND X08.SUB_SERIE_DOCFIS = IT.SUB_SERIE_DOCFIS ';
            v_sql := v_sql || '      AND X08.DISCRI_ITEM = IT.DISCRI_ITEM ';
            v_sql := v_sql || '      AND IT.COD_TRIBUTO = ''ICMS-S'') VLR_ICMSS, ';

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

            v_sql := v_sql || '               RANK() OVER( ';
            v_sql := v_sql || '            PARTITION BY X08.COD_ESTAB, D.COD_PRODUTO, P.DATA_FISCAL, G.COD_FIS_JUR ';
            v_sql :=
                   v_sql
                || '            ORDER BY X08.DATA_FISCAL DESC, X07.DATA_EMISSAO DESC, X08.NUM_DOCFIS, X08.DISCRI_ITEM) RANK ';
            v_sql := v_sql || '        FROM X08_ITENS_MERC X08, ';
            v_sql := v_sql || '             X07_DOCTO_FISCAL X07, ';
            v_sql := v_sql || '             X2013_PRODUTO D, ';
            v_sql := v_sql || '             X04_PESSOA_FIS_JUR G, ';
            v_sql := v_sql || '     (SELECT DISTINCT TMP.COD_PRODUTO, TMP.DATA_FISCAL AS DATA_FISCAL ';
            v_sql := v_sql || '              FROM ' || vp_tabela_saida || ' TMP ';
            v_sql := v_sql || '              WHERE TMP.PROC_ID   = ''' || vp_proc_instance || ''' ) P, ';
            v_sql := v_sql || '             X2043_COD_NBM A, ';
            v_sql := v_sql || '             X2012_COD_FISCAL B, ';
            v_sql := v_sql || '             X2006_NATUREZA_OP C, ';
            v_sql := v_sql || '             Y2026_SIT_TRB_UF_B E, ';
            v_sql := v_sql || '             ESTADO H  ';
            v_sql := v_sql || '        WHERE X08.MOVTO_E_S         <> ''9'' ';
            v_sql := v_sql || '          AND X08.NORM_DEV           = ''1'' ';
            v_sql := v_sql || '          AND X08.COD_EMPRESA        = ''' || mcod_empresa || ''' ';
            v_sql := v_sql || '          AND X08.COD_ESTAB          = ''' || vp_cod_estab || ''' ';
            v_sql := v_sql || '  AND X08.IDENT_NBM          = A.IDENT_NBM ';
            v_sql := v_sql || '  AND X08.IDENT_CFO          = B.IDENT_CFO ';
            v_sql := v_sql || '  AND X08.IDENT_NATUREZA_OP  = C.IDENT_NATUREZA_OP ';
            v_sql := v_sql || '  AND X08.IDENT_SITUACAO_B   = E.IDENT_SITUACAO_B ';
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
            v_sql := v_sql || '  AND X07.SUB_SERIE_DOCFIS = X08.SUB_SERIE_DOCFIS ';

            v_sql := v_sql || '  AND D.COD_PRODUTO        = P.COD_PRODUTO ';
            v_sql := v_sql || '  AND X08.DATA_FISCAL      < P.DATA_FISCAL ';
            v_sql := v_sql || '  AND X08.DATA_FISCAL       >= ''' || vp_data_fim || ''' '; --ULTIMOS 2 ANOS

            v_sql := v_sql || '       ) A ';
            v_sql := v_sql || ' WHERE A.RANK = 1 ';
        ELSIF ( vp_origem = 'CO' ) THEN
            --COMPRA DIRETA

            v_sql := v_sql || 'SELECT DISTINCT ''' || vp_proc_instance || ''', ';
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
            v_sql := v_sql || ' FROM ( ';
            v_sql :=
                   v_sql
                || '     SELECT  /*+INDEX(D PK_X2013_PRODUTO) INDEX(A PK_X2043_COD_NBM) INDEX(G PK_X04_PESSOA_FIS_JUR) */ ';
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
            v_sql := v_sql || '       '''' || X07.NUM_AUTENTIC_NFE AS NUM_AUTENTIC_NFE, ';
            v_sql := v_sql || 'NVL((SELECT VLR_BASE ';
            v_sql := v_sql || '          FROM X08_BASE_MERC IT ';
            v_sql := v_sql || '         WHERE X08.COD_EMPRESA = IT.COD_EMPRESA ';
            v_sql := v_sql || '             AND X08.COD_ESTAB = IT.COD_ESTAB ';
            v_sql := v_sql || '             AND X08.DATA_FISCAL = IT.DATA_FISCAL ';
            v_sql := v_sql || '             AND X08.MOVTO_E_S = IT.MOVTO_E_S ';
            v_sql := v_sql || '             AND X08.NORM_DEV = IT.NORM_DEV ';
            v_sql := v_sql || '             AND X08.IDENT_DOCTO = IT.IDENT_DOCTO ';
            v_sql := v_sql || '             AND X08.IDENT_FIS_JUR = IT.IDENT_FIS_JUR ';
            v_sql := v_sql || '             AND X08.NUM_DOCFIS = IT.NUM_DOCFIS ';
            v_sql := v_sql || '             AND X08.SERIE_DOCFIS = IT.SERIE_DOCFIS ';
            v_sql := v_sql || '             AND X08.SUB_SERIE_DOCFIS = IT.SUB_SERIE_DOCFIS ';
            v_sql := v_sql || '             AND X08.DISCRI_ITEM = IT.DISCRI_ITEM ';
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
            v_sql := v_sql || '      AND X08.SUB_SERIE_DOCFIS = IT.SUB_SERIE_DOCFIS ';
            v_sql := v_sql || '      AND X08.DISCRI_ITEM = IT.DISCRI_ITEM ';
            v_sql := v_sql || '      AND IT.COD_TRIBUTO = ''ICMS'') VLR_ICMS, ';
            v_sql := v_sql || 'NVL((SELECT VLR_BASE ';
            v_sql := v_sql || '          FROM X08_BASE_MERC IT ';
            v_sql := v_sql || '         WHERE X08.COD_EMPRESA = IT.COD_EMPRESA ';
            v_sql := v_sql || '             AND X08.COD_ESTAB = IT.COD_ESTAB ';
            v_sql := v_sql || '             AND X08.DATA_FISCAL = IT.DATA_FISCAL ';
            v_sql := v_sql || '             AND X08.MOVTO_E_S = IT.MOVTO_E_S ';
            v_sql := v_sql || '             AND X08.NORM_DEV = IT.NORM_DEV ';
            v_sql := v_sql || '             AND X08.IDENT_DOCTO = IT.IDENT_DOCTO ';
            v_sql := v_sql || '             AND X08.IDENT_FIS_JUR = IT.IDENT_FIS_JUR ';
            v_sql := v_sql || '             AND X08.NUM_DOCFIS = IT.NUM_DOCFIS ';
            v_sql := v_sql || '             AND X08.SERIE_DOCFIS = IT.SERIE_DOCFIS ';
            v_sql := v_sql || '             AND X08.SUB_SERIE_DOCFIS = IT.SUB_SERIE_DOCFIS ';
            v_sql := v_sql || '             AND X08.DISCRI_ITEM = IT.DISCRI_ITEM ';
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
            v_sql := v_sql || '      AND X08.SUB_SERIE_DOCFIS = IT.SUB_SERIE_DOCFIS ';
            v_sql := v_sql || '      AND X08.DISCRI_ITEM = IT.DISCRI_ITEM ';
            v_sql := v_sql || '      AND IT.COD_TRIBUTO = ''ICMS-S'') VLR_ICMSS, ';

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

            v_sql := v_sql || '               RANK() OVER( ';
            v_sql := v_sql || '            PARTITION BY X08.COD_ESTAB, D.COD_PRODUTO, P.DATA_FISCAL, G.COD_FIS_JUR ';
            v_sql :=
                   v_sql
                || '            ORDER BY X08.DATA_FISCAL DESC, X07.DATA_EMISSAO DESC, X08.NUM_DOCFIS, X08.DISCRI_ITEM) RANK ';
            v_sql := v_sql || '        FROM X08_ITENS_MERC X08, ';
            v_sql := v_sql || '             X07_DOCTO_FISCAL X07, ';
            v_sql := v_sql || '             X2013_PRODUTO D, ';
            v_sql := v_sql || '             X04_PESSOA_FIS_JUR G, ';
            v_sql := v_sql || '     (SELECT DISTINCT TMP.COD_PRODUTO, TMP.DATA_FISCAL AS DATA_FISCAL ';
            v_sql := v_sql || '              FROM ' || vp_tabela_saida || ' TMP ';
            v_sql := v_sql || '              WHERE TMP.PROC_ID   = ''' || vp_proc_instance || ''' ) P, ';
            v_sql := v_sql || '             X2043_COD_NBM A, ';
            v_sql := v_sql || '             X2012_COD_FISCAL B, ';
            v_sql := v_sql || '             X2006_NATUREZA_OP C, ';
            v_sql := v_sql || '             Y2026_SIT_TRB_UF_B E, ';
            v_sql := v_sql || '             ESTADO H  ';
            v_sql := v_sql || '        WHERE X08.MOVTO_E_S         <> ''9'' ';
            v_sql := v_sql || '          AND X08.NORM_DEV           = ''1'' ';
            v_sql := v_sql || '          AND X08.COD_EMPRESA        = ''' || mcod_empresa || ''' ';
            v_sql := v_sql || '          AND X08.COD_ESTAB          = ''' || vp_cod_estab || ''' ';

            v_sql := v_sql || '          AND B.COD_CFO IN (''1102'',''2102'',''1403'',''2403'',''1910'',''2910'') ';

            IF ( mcod_empresa = 'DSP' ) THEN
                v_sql := v_sql || '      AND G.CPF_CGC NOT LIKE ''61412110%'' '; --DSP
            ELSE
                v_sql := v_sql || '      AND G.CPF_CGC NOT LIKE ''334382500%'' '; --DP
            END IF;

            v_sql := v_sql || '          AND X07.NUM_CONTROLE_DOCTO  NOT LIKE ''C%'' ';

            v_sql := v_sql || '  AND X08.IDENT_NBM          = A.IDENT_NBM ';
            v_sql := v_sql || '  AND X08.IDENT_CFO          = B.IDENT_CFO ';
            v_sql := v_sql || '  AND X08.IDENT_NATUREZA_OP  = C.IDENT_NATUREZA_OP ';
            v_sql := v_sql || '  AND X08.IDENT_SITUACAO_B   = E.IDENT_SITUACAO_B ';
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
            v_sql := v_sql || '  AND X07.SUB_SERIE_DOCFIS = X08.SUB_SERIE_DOCFIS ';

            v_sql := v_sql || '  AND D.COD_PRODUTO        = P.COD_PRODUTO ';
            v_sql := v_sql || '  AND X08.DATA_FISCAL      < P.DATA_FISCAL ';
            v_sql := v_sql || '  AND X08.DATA_FISCAL       >= ''' || vp_data_fim || ''' '; --ULTIMOS 2 ANOS

            v_sql := v_sql || '       ) A ';
            v_sql := v_sql || ' WHERE A.RANK = 1 ';
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
                        || ' :26, :27, :28, :29, :30, :31, :32, :33, :34, :35, :36, :37, :38, :39, :40, :41, :42, :43 ) '
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
                            , tab_e ( i ).vlr_icmss_n_escrit
                            , tab_e ( i ).cod_situacao_b
                            , tab_e ( i ).data_emissao
                            , tab_e ( i ).cod_estado
                            , tab_e ( i ).num_controle_docto
                            , tab_e ( i ).num_autentic_nfe
                            , tab_e ( i ).vlr_item
                            , tab_e ( i ).vlr_outras
                            , tab_e ( i ).vlr_desconto
                            , tab_e ( i ).cst_pis
                            , tab_e ( i ).vlr_base_pis
                            , tab_e ( i ).vlr_aliq_pis
                            , tab_e ( i ).vlr_pis
                            , tab_e ( i ).cst_cofins
                            , tab_e ( i ).vlr_base_cofins
                            , tab_e ( i ).vlr_aliq_cofins
                            , tab_e ( i ).vlr_cofins
                            , tab_e ( i ).vlr_base_icms
                            , tab_e ( i ).vlr_icms
                            , tab_e ( i ).vlr_base_icmss
                            , tab_e ( i ).vlr_icmss;
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
    END; --PROCEDURE LOAD_ENTRADAS

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
        loga ( ' - ' || vp_nome_tabela_aliq || ' CRIADA'
             , FALSE );
    END;

    PROCEDURE get_entradas_cd ( vp_proc_id IN NUMBER
                              , vp_filial IN VARCHAR2
                              , vp_cd IN VARCHAR2
                              , vp_tab_entrada_c IN VARCHAR2
                              , vp_tabela_saida IN VARCHAR2
                              , vp_tabela_nf IN VARCHAR2
                              , vp_tabela_ult_ent IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 10000 );
    BEGIN
        v_sql := 'INSERT /*+APPEND*/ INTO ' || vp_tabela_ult_ent || ' ( ';
        v_sql := v_sql || 'SELECT ID_PROC ,';
        v_sql := v_sql || 'COD_EMPRESA ,';
        v_sql := v_sql || 'COD_ESTAB ,';
        v_sql := v_sql || 'UF_ESTAB ,';
        v_sql := v_sql || 'DOCTO ,';
        v_sql := v_sql || 'COD_PRODUTO ,';
        v_sql := v_sql || 'NUM_ITEM ,';
        v_sql := v_sql || 'DESCR_ITEM ,';
        v_sql := v_sql || 'NUM_DOCFIS ,';
        v_sql := v_sql || 'DATA_FISCAL ,';
        v_sql := v_sql || 'SERIE_DOCFIS ,';
        v_sql := v_sql || 'QUANTIDADE ,';
        v_sql := v_sql || 'COD_NBM ,';
        v_sql := v_sql || 'COD_CFO ,';
        v_sql := v_sql || 'GRUPO_PRODUTO ,';
        v_sql := v_sql || 'VLR_DESCONTO ,';
        v_sql := v_sql || 'VLR_CONTABIL ,';

        v_sql := v_sql || 'VLR_ITEM ,'; --
        v_sql := v_sql || 'VLR_OUTRAS ,'; --

        v_sql := v_sql || 'NUM_AUTENTIC_NFE ,';
        v_sql := v_sql || 'VLR_BASE_ICMS ,';
        v_sql := v_sql || 'VLR_ALIQ_ICMS ,';
        v_sql := v_sql || 'VLR_ICMS ,';

        v_sql := v_sql || 'CST_PIS        ,'; --
        v_sql := v_sql || 'VLR_BASE_PIS   ,'; --
        v_sql := v_sql || 'VLR_ALIQ_PIS   ,'; --
        v_sql := v_sql || 'VLR_PIS        ,'; --
        v_sql := v_sql || 'CST_COFINS     ,'; --
        v_sql := v_sql || 'VLR_BASE_COFINS,'; --
        v_sql := v_sql || 'VLR_ALIQ_COFINS,'; --
        v_sql := v_sql || 'VLR_COFINS     ,'; --

        v_sql := v_sql || 'E_COD_ESTAB ,';
        v_sql := v_sql || 'E_DATA_FISCAL ,';
        v_sql := v_sql || 'E_MOVTO_E_S ,';
        v_sql := v_sql || 'E_NORM_DEV ,';
        v_sql := v_sql || 'E_IDENT_DOCTO ,';
        v_sql := v_sql || 'E_IDENT_FIS_JUR ,';
        v_sql := v_sql || 'E_SUB_SERIE_DOCFIS ,';
        v_sql := v_sql || 'E_DISCRI_ITEM ,';
        v_sql := v_sql || 'E_DATA_EMISSAO ,';
        v_sql := v_sql || 'E_NUM_DOCFIS ,';
        v_sql := v_sql || 'E_SERIE_DOCFIS ,';
        v_sql := v_sql || 'E_NUM_ITEM ,';
        v_sql := v_sql || 'E_COD_FIS_JUR ,';
        v_sql := v_sql || 'E_CPF_CGC ,';
        v_sql := v_sql || 'E_COD_NBM ,';
        v_sql := v_sql || 'E_COD_CFO ,';
        v_sql := v_sql || 'E_COD_NATUREZA_OP ,';
        v_sql := v_sql || 'E_COD_PRODUTO ,';
        v_sql := v_sql || 'E_VLR_CONTAB_ITEM ,';
        v_sql := v_sql || 'E_QUANTIDADE ,';
        v_sql := v_sql || 'E_VLR_UNIT ,';

        v_sql := v_sql || 'E_VLR_ITEM, '; --
        v_sql := v_sql || 'E_VLR_OUTRAS, '; --
        v_sql := v_sql || 'E_VLR_DESCONTO, '; --

        v_sql := v_sql || 'E_CST_PIS, '; --
        v_sql := v_sql || 'E_VLR_BASE_PIS, '; --
        v_sql := v_sql || 'E_VLR_ALIQ_PIS, '; --
        v_sql := v_sql || 'E_VLR_PIS, '; --
        v_sql := v_sql || 'E_CST_COFINS, '; --
        v_sql := v_sql || 'E_VLR_BASE_COFINS, '; --
        v_sql := v_sql || 'E_VLR_ALIQ_COFINS, '; --
        v_sql := v_sql || 'E_VLR_COFINS, '; --

        v_sql := v_sql || 'VLR_ICMSS_N_ESCRIT, '; --

        v_sql := v_sql || 'E_COD_SITUACAO_B ,';
        v_sql := v_sql || 'E_COD_ESTADO ,';
        v_sql := v_sql || 'E_NUM_CONTROLE_DOCTO ,';
        v_sql := v_sql || 'E_NUM_AUTENTIC_NFE ,';
        v_sql := v_sql || 'E_VLR_BASE_ICMS ,';
        v_sql := v_sql || 'E_VLR_ICMS ,';
        v_sql := v_sql || 'E_VLR_BASE_ICMSS ,';
        v_sql := v_sql || 'E_VLR_ICMSS ,';
        v_sql := v_sql || 'BASE_ICMS_UNIT ,';
        v_sql := v_sql || 'VLR_ICMS_UNIT ,';
        v_sql := v_sql || 'ALIQ_ICMS ,';
        v_sql := v_sql || 'BASE_ST_UNIT ,';
        v_sql := v_sql || 'VLR_ICMS_ST_UNIT ,';
        v_sql := v_sql || 'VLR_ICMS_ST_UNIT_AUX ,';
        v_sql := v_sql || 'STAT_LIBER_CNTR ';
        v_sql := v_sql || ' FROM (';

        v_sql := v_sql || 'SELECT /*+DRIVING_SITE(E)*/ ''' || vp_proc_id || ''' ID_PROC, ';
        v_sql := v_sql || ' ''' || mcod_empresa || ''' COD_EMPRESA, ';
        v_sql := v_sql || ' A.COD_ESTAB , ';
        v_sql := v_sql || ' A.UF_ESTAB , ';
        v_sql := v_sql || ' A.DOCTO , ';
        v_sql := v_sql || ' A.COD_PRODUTO , ';
        v_sql := v_sql || ' A.NUM_ITEM , ';
        v_sql := v_sql || ' A.DESCR_ITEM , ';
        v_sql := v_sql || ' A.NUM_DOCFIS , ';
        v_sql := v_sql || ' A.DATA_FISCAL , ';
        v_sql := v_sql || ' A.SERIE_DOCFIS , ';
        v_sql := v_sql || ' A.QUANTIDADE , ';
        v_sql := v_sql || ' A.COD_NBM , ';
        v_sql := v_sql || ' A.COD_CFO , ';
        v_sql := v_sql || ' A.GRUPO_PRODUTO , ';
        v_sql := v_sql || ' A.VLR_DESCONTO , ';
        v_sql := v_sql || ' A.VLR_CONTABIL , ';
        --
        v_sql := v_sql || ' A.VLR_ITEM , '; --
        v_sql := v_sql || ' A.VLR_OUTRAS , '; --
        --
        v_sql := v_sql || ' A.NUM_AUTENTIC_NFE , ';
        v_sql := v_sql || ' A.VLR_BASE_ICMS , ';
        v_sql := v_sql || ' A.VLR_ALIQ_ICMS , ';
        v_sql := v_sql || ' A.VLR_ICMS , ';
        --
        v_sql := v_sql || ' A.CST_PIS        , '; --
        v_sql := v_sql || ' A.VLR_BASE_PIS   , '; --
        v_sql := v_sql || ' A.VLR_ALIQ_PIS   , '; --
        v_sql := v_sql || ' A.VLR_PIS        , '; --
        v_sql := v_sql || ' A.CST_COFINS     , '; --
        v_sql := v_sql || ' A.VLR_BASE_COFINS, '; --
        v_sql := v_sql || ' A.VLR_ALIQ_COFINS, '; --
        v_sql := v_sql || ' A.VLR_COFINS     , '; --
        ---
        v_sql := v_sql || 'B.COD_ESTAB        E_COD_ESTAB ,';
        v_sql := v_sql || 'B.DATA_FISCAL      E_DATA_FISCAL ,';
        v_sql := v_sql || 'B.MOVTO_E_S        E_MOVTO_E_S ,';
        v_sql := v_sql || 'B.NORM_DEV         E_NORM_DEV ,';
        v_sql := v_sql || 'B.IDENT_DOCTO      E_IDENT_DOCTO ,';
        v_sql := v_sql || 'B.IDENT_FIS_JUR    E_IDENT_FIS_JUR ,';
        v_sql := v_sql || 'B.SUB_SERIE_DOCFIS E_SUB_SERIE_DOCFIS ,';
        v_sql := v_sql || 'B.DISCRI_ITEM      E_DISCRI_ITEM ,';
        v_sql := v_sql || 'B.DATA_EMISSAO     E_DATA_EMISSAO ,';
        v_sql := v_sql || 'B.NUM_DOCFIS       E_NUM_DOCFIS ,';
        v_sql := v_sql || 'B.SERIE_DOCFIS     E_SERIE_DOCFIS ,';
        v_sql := v_sql || 'B.NUM_ITEM         E_NUM_ITEM ,';
        v_sql := v_sql || 'B.COD_FIS_JUR      E_COD_FIS_JUR ,';
        v_sql := v_sql || 'B.CPF_CGC          E_CPF_CGC ,';
        v_sql := v_sql || 'B.COD_NBM          E_COD_NBM ,';
        v_sql := v_sql || 'B.COD_CFO          E_COD_CFO ,';
        v_sql := v_sql || 'B.COD_NATUREZA_OP  E_COD_NATUREZA_OP ,';
        v_sql := v_sql || 'B.COD_PRODUTO      E_COD_PRODUTO ,';
        v_sql := v_sql || 'B.VLR_CONTAB_ITEM  E_VLR_CONTAB_ITEM ,';
        v_sql := v_sql || 'B.QUANTIDADE       E_QUANTIDADE ,';
        v_sql := v_sql || 'B.VLR_UNIT         E_VLR_UNIT ,';

        v_sql := v_sql || 'B.VLR_ITEM         AS E_VLR_ITEM       ,'; --
        v_sql := v_sql || 'B.VLR_OUTRAS       AS E_VLR_OUTRAS     ,'; --
        v_sql := v_sql || 'B.VLR_DESCONTO     AS E_VLR_DESCONTO   ,'; --

        v_sql := v_sql || 'B.CST_PIS          AS E_CST_PIS        ,'; --
        v_sql := v_sql || 'B.VLR_BASE_PIS     AS E_VLR_BASE_PIS   ,'; --
        v_sql := v_sql || 'B.VLR_ALIQ_PIS     AS E_VLR_ALIQ_PIS   ,'; --
        v_sql := v_sql || 'B.VLR_PIS          AS E_VLR_PIS        ,'; --
        v_sql := v_sql || 'B.CST_COFINS       AS E_CST_COFINS     ,'; --
        v_sql := v_sql || 'B.VLR_BASE_COFINS  AS E_VLR_BASE_COFINS,'; --
        v_sql := v_sql || 'B.VLR_ALIQ_COFINS  AS E_VLR_ALIQ_COFINS,'; --
        v_sql := v_sql || 'B.VLR_COFINS       AS E_VLR_COFINS     ,'; --

        v_sql := v_sql || 'B.VLR_ICMSS_N_ESCRIT, '; --

        v_sql := v_sql || 'B.COD_SITUACAO_B      E_COD_SITUACAO_B ,';
        v_sql := v_sql || 'B.COD_ESTADO          E_COD_ESTADO ,';
        v_sql := v_sql || 'B.NUM_CONTROLE_DOCTO  E_NUM_CONTROLE_DOCTO ,';
        v_sql := v_sql || 'B.NUM_AUTENTIC_NFE    E_NUM_AUTENTIC_NFE ,';

        v_sql := v_sql || ' B.VLR_BASE_ICMS      AS E_VLR_BASE_ICMS, ';
        v_sql := v_sql || ' B.VLR_ICMS           AS E_VLR_ICMS, ';
        v_sql := v_sql || ' B.VLR_BASE_ICMSS     AS E_VLR_BASE_ICMSS, ';
        v_sql := v_sql || ' B.VLR_ICMSS          AS E_VLR_ICMSS, ';
        ---
        v_sql := v_sql || ' C.BASE_ICMS_UNIT, ';
        v_sql := v_sql || ' C.VLR_ICMS_UNIT, ';
        v_sql := v_sql || ' C.ALIQ_ICMS, ';
        v_sql := v_sql || ' C.BASE_ST_UNIT, ';
        v_sql := v_sql || ' C.VLR_ICMS_ST_UNIT, ';
        v_sql := v_sql || ' C.VLR_ICMS_ST_UNIT_AUX, ';
        v_sql := v_sql || ' RANK() OVER(PARTITION BY A.COD_PRODUTO, A.DATA_FISCAL ';
        v_sql :=
            v_sql || ' ORDER BY B.DATA_FISCAL DESC, SIGN(B.VLR_ICMSS) DESC, SIGN(B.VLR_ICMSS_N_ESCRIT) DESC) DTRANK, ';
        ---
        v_sql :=
            v_sql || ' DECODE(E.LIBER_CNTR_DSP,''C'',''CONTROLADO'',''L'',''LIBERADO'',''OUTRO'') STAT_LIBER_CNTR ';
        ---
        v_sql := v_sql || ' FROM ' || vp_tabela_saida || ' A, ';
        v_sql := v_sql || '      ' || vp_tab_entrada_c || ' B, ';
        v_sql := v_sql || '      ' || vp_tabela_nf || ' C, ';
        v_sql := v_sql || '      MSAFI.DSP_INTERFACE_SETUP D, ';
        v_sql := v_sql || '      (SELECT SETID, INV_ITEM_ID, LIBER_CNTR_DSP ';
        v_sql := v_sql || '       FROM MSAFI.PS_ATRB_OPER_DSP ) E ';
        v_sql := v_sql || ' WHERE A.PROC_ID       = ''' || vp_proc_id || ''' ';
        v_sql := v_sql || '   AND A.COD_ESTAB     = ''' || vp_filial || ''' ';
        v_sql := v_sql || '   AND A.COD_CFO  NOT IN (''5102'',''6102'') ';
        ---
        v_sql := v_sql || '   AND B.PROC_ID       = A.PROC_ID ';
        v_sql := v_sql || '   AND B.COD_EMPRESA   = A.COD_EMPRESA ';
        v_sql := v_sql || '   AND B.COD_ESTAB     = ''' || vp_cd || ''' ';
        v_sql := v_sql || '   AND B.COD_PRODUTO   = A.COD_PRODUTO ';
        v_sql := v_sql || '   AND B.DATA_FISCAL   <= A.DATA_FISCAL ';
        ---
        v_sql := v_sql || '   AND D.COD_EMPRESA        = ''' || mcod_empresa || ''' ';
        v_sql := v_sql || '   AND A.PROC_ID            = C.PROC_ID ';
        v_sql := v_sql || '   AND D.BU_PO1             = C.BUSINESS_UNIT ';
        v_sql := v_sql || '   AND B.NUM_CONTROLE_DOCTO = C.NF_BRL_ID ';
        v_sql := v_sql || '   AND B.NUM_ITEM           = C.NF_BRL_LINE_NUM ';
        ---
        v_sql := v_sql || '   AND E.SETID              = ''GERAL'' ';
        v_sql := v_sql || '   AND E.INV_ITEM_ID        = A.COD_PRODUTO ';
        --
        v_sql := v_sql || '   AND C.VLR_ICMS_UNIT      > 0 ';
        ---
        v_sql := v_sql || '   AND NOT EXISTS (SELECT /*+PARALLEL_INDEX(C PK_DPSP_P_' || vp_proc_id || ', 6)*/ ''Y'' ';
        v_sql := v_sql || '                   FROM ' || vp_tabela_ult_ent || ' C ';
        v_sql := v_sql || '                   WHERE C.PROC_ID      = A.PROC_ID';
        v_sql := v_sql || '                     AND C.COD_EMPRESA  = A.COD_EMPRESA';
        v_sql := v_sql || '                     AND C.COD_ESTAB    = A.COD_ESTAB';
        v_sql := v_sql || '                     AND C.UF_ESTAB     = A.UF_ESTAB';
        v_sql := v_sql || '                     AND C.DOCTO        = A.DOCTO';
        v_sql := v_sql || '                     AND C.COD_PRODUTO  = A.COD_PRODUTO';
        v_sql := v_sql || '                     AND C.NUM_ITEM     = A.NUM_ITEM';
        v_sql := v_sql || '                     AND C.NUM_DOCFIS   = A.NUM_DOCFIS';
        v_sql := v_sql || '                     AND C.DATA_FISCAL  = A.DATA_FISCAL';
        v_sql := v_sql || '                     AND C.SERIE_DOCFIS = A.SERIE_DOCFIS)) A ';
        v_sql := v_sql || ' WHERE DTRANK = 1) ';

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
                ---
                raise_application_error ( -20007
                                        , '!ERRO INSERT GET_ENTRADAS_CD!' );
        END;

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_tabela_ult_ent );
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
                                  , vp_tabela_ult_ent IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 10000 );
    BEGIN
        v_sql := 'INSERT /*+APPEND*/ INTO ' || vp_tabela_ult_ent || ' ( ';
        v_sql := v_sql || 'SELECT PROC_ID,';
        v_sql := v_sql || 'COD_EMPRESA,';
        v_sql := v_sql || 'COD_ESTAB,';
        v_sql := v_sql || 'UF_ESTAB,';
        v_sql := v_sql || 'DOCTO,';
        v_sql := v_sql || 'COD_PRODUTO,';
        v_sql := v_sql || 'NUM_ITEM,';
        v_sql := v_sql || 'DESCR_ITEM,';
        v_sql := v_sql || 'NUM_DOCFIS,';
        v_sql := v_sql || 'DATA_FISCAL,';
        v_sql := v_sql || 'SERIE_DOCFIS,';
        v_sql := v_sql || 'QUANTIDADE,';
        v_sql := v_sql || 'COD_NBM,';
        v_sql := v_sql || 'COD_CFO,';
        v_sql := v_sql || 'GRUPO_PRODUTO,';
        v_sql := v_sql || 'VLR_DESCONTO,';
        v_sql := v_sql || 'VLR_CONTABIL,';

        v_sql := v_sql || 'VLR_ITEM ,'; --
        v_sql := v_sql || 'VLR_OUTRAS ,'; --

        v_sql := v_sql || 'NUM_AUTENTIC_NFE ,';
        v_sql := v_sql || 'VLR_BASE_ICMS ,';
        v_sql := v_sql || 'VLR_ALIQ_ICMS ,';
        v_sql := v_sql || 'VLR_ICMS ,';

        v_sql := v_sql || 'CST_PIS        ,'; --
        v_sql := v_sql || 'VLR_BASE_PIS   ,'; --
        v_sql := v_sql || 'VLR_ALIQ_PIS   ,'; --
        v_sql := v_sql || 'VLR_PIS        ,'; --
        v_sql := v_sql || 'CST_COFINS     ,'; --
        v_sql := v_sql || 'VLR_BASE_COFINS,'; --
        v_sql := v_sql || 'VLR_ALIQ_COFINS,'; --
        v_sql := v_sql || 'VLR_COFINS     ,'; --

        v_sql := v_sql || 'E_COD_ESTAB,';
        v_sql := v_sql || 'E_DATA_FISCAL,';
        v_sql := v_sql || 'E_MOVTO_E_S,';
        v_sql := v_sql || 'E_NORM_DEV,';
        v_sql := v_sql || 'E_IDENT_DOCTO,';
        v_sql := v_sql || 'E_IDENT_FIS_JUR,';
        v_sql := v_sql || 'E_SUB_SERIE_DOCFIS,';
        v_sql := v_sql || 'E_DISCRI_ITEM,';
        v_sql := v_sql || 'E_DATA_EMISSAO,';
        v_sql := v_sql || 'E_NUM_DOCFIS,';
        v_sql := v_sql || 'E_SERIE_DOCFIS,';
        v_sql := v_sql || 'E_NUM_ITEM,';
        v_sql := v_sql || 'E_COD_FIS_JUR,';
        v_sql := v_sql || 'E_CPF_CGC,';
        v_sql := v_sql || 'E_COD_NBM,';
        v_sql := v_sql || 'E_COD_CFO,';
        v_sql := v_sql || 'E_COD_NATUREZA_OP,';
        v_sql := v_sql || 'E_COD_PRODUTO,';
        v_sql := v_sql || 'E_VLR_CONTAB_ITEM,';
        v_sql := v_sql || 'E_QUANTIDADE,';
        v_sql := v_sql || 'E_VLR_UNIT,';

        v_sql := v_sql || 'E_VLR_ITEM, '; --
        v_sql := v_sql || 'E_VLR_OUTRAS, '; --
        v_sql := v_sql || 'E_VLR_DESCONTO, '; --

        v_sql := v_sql || 'E_CST_PIS, '; --
        v_sql := v_sql || 'E_VLR_BASE_PIS, '; --
        v_sql := v_sql || 'E_VLR_ALIQ_PIS, '; --
        v_sql := v_sql || 'E_VLR_PIS, '; --
        v_sql := v_sql || 'E_CST_COFINS, '; --
        v_sql := v_sql || 'E_VLR_BASE_COFINS, '; --
        v_sql := v_sql || 'E_VLR_ALIQ_COFINS, '; --
        v_sql := v_sql || 'E_VLR_COFINS, '; --

        v_sql := v_sql || 'VLR_ICMSS_N_ESCRIT, '; --

        v_sql := v_sql || 'E_COD_SITUACAO_B,';
        v_sql := v_sql || 'E_COD_ESTADO,';
        v_sql := v_sql || 'E_NUM_CONTROLE_DOCTO,';
        v_sql := v_sql || 'E_NUM_AUTENTIC_NFE,';

        v_sql := v_sql || 'E_VLR_BASE_ICMS ,';
        v_sql := v_sql || 'E_VLR_ICMS ,';
        v_sql := v_sql || 'E_VLR_BASE_ICMSS ,';
        v_sql := v_sql || 'E_VLR_ICMSS ,';

        v_sql := v_sql || 'BASE_ICMS_UNIT,';
        v_sql := v_sql || 'VLR_ICMS_UNIT,';
        v_sql := v_sql || 'ALIQ_ICMS,';
        v_sql := v_sql || 'BASE_ST_UNIT,';
        v_sql := v_sql || 'VLR_ICMS_ST_UNIT,';
        v_sql := v_sql || 'VLR_ICMS_ST_UNIT_AUX,';
        v_sql := v_sql || 'STAT_LIBER_CNTR';
        --
        v_sql := v_sql || ' FROM ( SELECT /*+DRIVING_SITE(E)*/ ';
        v_sql := v_sql || ' ''' || vp_proc_id || ''' PROC_ID, ';
        v_sql := v_sql || ' ''' || mcod_empresa || ''' COD_EMPRESA, ';
        v_sql := v_sql || ' A.COD_ESTAB , ';
        v_sql := v_sql || ' A.UF_ESTAB , ';
        v_sql := v_sql || ' A.DOCTO , ';
        v_sql := v_sql || ' A.COD_PRODUTO , ';
        v_sql := v_sql || ' A.NUM_ITEM , ';
        v_sql := v_sql || ' A.DESCR_ITEM , ';
        v_sql := v_sql || ' A.NUM_DOCFIS , ';
        v_sql := v_sql || ' A.DATA_FISCAL , ';
        v_sql := v_sql || ' A.SERIE_DOCFIS , ';
        v_sql := v_sql || ' A.QUANTIDADE , ';
        v_sql := v_sql || ' A.COD_NBM , ';
        v_sql := v_sql || ' A.COD_CFO , ';
        v_sql := v_sql || ' A.GRUPO_PRODUTO , ';
        v_sql := v_sql || ' A.VLR_DESCONTO , ';
        v_sql := v_sql || ' A.VLR_CONTABIL , ';
        --
        v_sql := v_sql || ' A.VLR_ITEM , '; --
        v_sql := v_sql || ' A.VLR_OUTRAS , '; --
        --
        v_sql := v_sql || ' A.NUM_AUTENTIC_NFE , ';
        v_sql := v_sql || ' A.VLR_BASE_ICMS , ';
        v_sql := v_sql || ' A.VLR_ALIQ_ICMS , ';
        v_sql := v_sql || ' A.VLR_ICMS , ';
        --
        v_sql := v_sql || ' A.CST_PIS        , '; --
        v_sql := v_sql || ' A.VLR_BASE_PIS   , '; --
        v_sql := v_sql || ' A.VLR_ALIQ_PIS   , '; --
        v_sql := v_sql || ' A.VLR_PIS        , '; --
        v_sql := v_sql || ' A.CST_COFINS     , '; --
        v_sql := v_sql || ' A.VLR_BASE_COFINS, '; --
        v_sql := v_sql || ' A.VLR_ALIQ_COFINS, '; --
        v_sql := v_sql || ' A.VLR_COFINS     , '; --
        ---
        v_sql := v_sql || ' B.COD_ESTAB            AS E_COD_ESTAB,';
        v_sql := v_sql || ' B.DATA_FISCAL          AS E_DATA_FISCAL,';
        v_sql := v_sql || ' B.MOVTO_E_S            AS E_MOVTO_E_S,';
        v_sql := v_sql || ' B.NORM_DEV             AS E_NORM_DEV,';
        v_sql := v_sql || ' B.IDENT_DOCTO          AS E_IDENT_DOCTO,';
        v_sql := v_sql || ' B.IDENT_FIS_JUR        AS E_IDENT_FIS_JUR,';
        v_sql := v_sql || ' B.SUB_SERIE_DOCFIS     AS E_SUB_SERIE_DOCFIS,';
        v_sql := v_sql || ' B.DISCRI_ITEM          AS E_DISCRI_ITEM,';
        v_sql := v_sql || ' B.DATA_EMISSAO         AS E_DATA_EMISSAO,';
        v_sql := v_sql || ' B.NUM_DOCFIS           AS E_NUM_DOCFIS,';
        v_sql := v_sql || ' B.SERIE_DOCFIS         AS E_SERIE_DOCFIS,';
        v_sql := v_sql || ' B.NUM_ITEM             AS E_NUM_ITEM,';
        v_sql := v_sql || ' B.COD_FIS_JUR          AS E_COD_FIS_JUR,';
        v_sql := v_sql || ' B.CPF_CGC              AS E_CPF_CGC,';
        v_sql := v_sql || ' B.COD_NBM              AS E_COD_NBM,';
        v_sql := v_sql || ' B.COD_CFO              AS E_COD_CFO,';
        v_sql := v_sql || ' B.COD_NATUREZA_OP      AS E_COD_NATUREZA_OP,';
        v_sql := v_sql || ' B.COD_PRODUTO          AS E_COD_PRODUTO,';
        v_sql := v_sql || ' B.VLR_CONTAB_ITEM      AS E_VLR_CONTAB_ITEM,';
        v_sql := v_sql || ' B.QUANTIDADE           AS E_QUANTIDADE,';
        v_sql := v_sql || ' B.VLR_UNIT             AS E_VLR_UNIT,';

        v_sql := v_sql || 'B.VLR_ITEM              AS E_VLR_ITEM       ,'; --
        v_sql := v_sql || 'B.VLR_OUTRAS            AS E_VLR_OUTRAS     ,'; --
        v_sql := v_sql || 'B.VLR_DESCONTO          AS E_VLR_DESCONTO   ,'; --

        v_sql := v_sql || 'B.CST_PIS               AS E_CST_PIS        ,'; --
        v_sql := v_sql || 'B.VLR_BASE_PIS          AS E_VLR_BASE_PIS   ,'; --
        v_sql := v_sql || 'B.VLR_ALIQ_PIS          AS E_VLR_ALIQ_PIS   ,'; --
        v_sql := v_sql || 'B.VLR_PIS               AS E_VLR_PIS        ,'; --
        v_sql := v_sql || 'B.CST_COFINS            AS E_CST_COFINS     ,'; --
        v_sql := v_sql || 'B.VLR_BASE_COFINS       AS E_VLR_BASE_COFINS,'; --
        v_sql := v_sql || 'B.VLR_ALIQ_COFINS       AS E_VLR_ALIQ_COFINS,'; --
        v_sql := v_sql || 'B.VLR_COFINS            AS E_VLR_COFINS     ,'; --

        v_sql := v_sql || 'B.VLR_ICMSS_N_ESCRIT, '; --

        v_sql := v_sql || ' B.COD_SITUACAO_B       AS E_COD_SITUACAO_B,';
        v_sql := v_sql || ' B.COD_ESTADO           AS E_COD_ESTADO,';
        v_sql := v_sql || ' B.NUM_CONTROLE_DOCTO   AS E_NUM_CONTROLE_DOCTO,';
        v_sql := v_sql || ' B.NUM_AUTENTIC_NFE     AS E_NUM_AUTENTIC_NFE,';
        v_sql := v_sql || ' B.VLR_BASE_ICMS        AS E_VLR_BASE_ICMS, ';
        v_sql := v_sql || ' B.VLR_ICMS             AS E_VLR_ICMS, ';
        v_sql := v_sql || ' B.VLR_BASE_ICMSS       AS E_VLR_BASE_ICMSS, ';
        v_sql := v_sql || ' B.VLR_ICMSS            AS E_VLR_ICMSS, ';
        ---
        v_sql := v_sql || ' C.BASE_ICMS_UNIT, ';
        v_sql := v_sql || ' C.VLR_ICMS_UNIT, ';
        v_sql := v_sql || ' C.ALIQ_ICMS, ';
        v_sql := v_sql || ' C.BASE_ST_UNIT, ';
        v_sql := v_sql || ' C.VLR_ICMS_ST_UNIT, ';
        v_sql := v_sql || ' C.VLR_ICMS_ST_UNIT_AUX, ';
        ---
        v_sql :=
            v_sql || ' DECODE(E.LIBER_CNTR_DSP,''C'',''CONTROLADO'',''L'',''LIBERADO'',''OUTRO'') STAT_LIBER_CNTR, ';
        v_sql := v_sql || ' RANK() OVER(PARTITION BY A.COD_ESTAB, A.COD_PRODUTO, A.DATA_FISCAL ';
        v_sql := v_sql || ' ORDER BY B.DATA_FISCAL DESC, SIGN(B.VLR_ICMSS) + SIGN(B.VLR_ICMSS_N_ESCRIT) DESC) MRANK ';
        ---
        v_sql := v_sql || ' FROM ' || vp_tabela_saida || ' A, ';
        v_sql := v_sql || ' ' || vp_tabela_entrada || ' B, ';
        v_sql := v_sql || ' ' || vp_tabela_nf || ' C, ';
        v_sql := v_sql || ' MSAFI.DSP_INTERFACE_SETUP D, ';
        v_sql := v_sql || ' (SELECT E.SETID, E.INV_ITEM_ID, E.LIBER_CNTR_DSP ';
        v_sql := v_sql || ' FROM MSAFI.PS_ATRB_OPER_DSP E ) E ';
        v_sql := v_sql || ' WHERE A.PROC_ID = ''' || vp_proc_id || ''' ';
        v_sql := v_sql || ' AND A.COD_EMPRESA = ''' || mcod_empresa || ''' ';
        v_sql := v_sql || ' AND A.COD_ESTAB = ''' || vp_filial || ''' ';
        v_sql :=
               v_sql
            || ' AND A.DATA_FISCAL BETWEEN TO_DATE('''
            || vp_data_ini
            || ''',''DD/MM/YYYY'') AND TO_DATE('''
            || vp_data_fim
            || ''',''DD/MM/YYYY'') ';
        v_sql := v_sql || ' AND A.COD_CFO  NOT IN (''5102'',''6102'') ';
        ---
        v_sql := v_sql || ' AND B.PROC_ID = A.PROC_ID ';
        v_sql := v_sql || ' AND B.COD_EMPRESA = A.COD_EMPRESA ';
        v_sql := v_sql || ' AND B.COD_ESTAB = A.COD_ESTAB ';
        v_sql := v_sql || ' AND B.COD_PRODUTO = A.COD_PRODUTO ';
        v_sql := v_sql || ' AND B.DATA_FISCAL <= A.DATA_FISCAL ';
        v_sql := v_sql || ' AND B.COD_FIS_JUR = ''' || vp_cd || ''' ';
        ---
        v_sql := v_sql || ' AND D.COD_EMPRESA = ''' || mcod_empresa || ''' ';
        v_sql := v_sql || ' AND A.PROC_ID = C.PROC_ID ';
        v_sql := v_sql || ' AND D.BU_PO1 = C.BUSINESS_UNIT ';
        v_sql := v_sql || ' AND B.NUM_CONTROLE_DOCTO = C.NF_BRL_ID ';
        v_sql := v_sql || ' AND B.NUM_ITEM = C.NF_BRL_LINE_NUM ';
        ---
        v_sql := v_sql || ' AND E.SETID       = ''GERAL'' ';
        v_sql := v_sql || ' AND E.INV_ITEM_ID = A.COD_PRODUTO ';
        --
        v_sql := v_sql || ' AND C.VLR_ICMS_UNIT      > 0 ';
        ---
        v_sql := v_sql || ' AND NOT EXISTS (SELECT /*+PARALLEL_INDEX(C PK_DPSP_P_' || vp_proc_id || ', 6)*/ ''Y'' ';
        v_sql := v_sql || ' FROM ' || vp_tabela_ult_ent || ' C ';
        v_sql := v_sql || ' WHERE C.PROC_ID = A.PROC_ID';
        v_sql := v_sql || ' AND C.COD_EMPRESA = A.COD_EMPRESA';
        v_sql := v_sql || ' AND C.COD_ESTAB = A.COD_ESTAB';
        v_sql := v_sql || ' AND C.UF_ESTAB = A.UF_ESTAB';
        v_sql := v_sql || ' AND C.DOCTO = A.DOCTO';
        v_sql := v_sql || ' AND C.COD_PRODUTO = A.COD_PRODUTO';
        v_sql := v_sql || ' AND C.NUM_ITEM = A.NUM_ITEM';
        v_sql := v_sql || ' AND C.NUM_DOCFIS = A.NUM_DOCFIS';
        v_sql := v_sql || ' AND C.DATA_FISCAL = A.DATA_FISCAL';
        v_sql := v_sql || ' AND C.SERIE_DOCFIS = A.SERIE_DOCFIS)) ';
        v_sql := v_sql || ' WHERE MRANK = 1) ';

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
                ---
                raise_application_error ( -20006
                                        , '!ERRO INSERT GET_ENTRADAS_FILIAL!' );
        END;

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_tabela_ult_ent );
    --LOGA('C_ENTR_FILIAL-FIM-' || VP_CD || '->' || VP_FILIAL, FALSE);

    END; --GET_ENTRADAS_FILIAL

    PROCEDURE get_compra_direta ( vp_proc_id IN NUMBER
                                , vp_filial IN VARCHAR2
                                , vp_data_ini IN VARCHAR2
                                , vp_data_fim IN VARCHAR2
                                , vp_tabela_entrada IN VARCHAR2
                                , vp_tabela_saida IN VARCHAR2
                                , vp_tabela_nf IN VARCHAR2
                                , vp_tabela_ult_entrada IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 10000 );
    BEGIN
        v_sql := 'INSERT /*+APPEND*/ INTO ' || vp_tabela_ult_entrada || ' (  ';
        --V_SQL := V_SQL || '   SELECT  /*+PARALLEL(12) ';
        v_sql := v_sql || ' SELECT  /*+INDEX(A, IDX8_DPSP_S_' || vp_proc_id || ')*/ ';
        v_sql := v_sql || ' ''' || vp_proc_id || ''', ';
        v_sql := v_sql || ' ''' || mcod_empresa || ''', ';
        v_sql := v_sql || ' A.COD_ESTAB, ';
        v_sql := v_sql || ' A.UF_ESTAB, ';
        v_sql := v_sql || ' A.DOCTO, ';
        v_sql := v_sql || ' A.COD_PRODUTO, ';
        v_sql := v_sql || ' A.NUM_ITEM, ';
        v_sql := v_sql || ' A.DESCR_ITEM, ';
        v_sql := v_sql || ' A.NUM_DOCFIS, ';
        v_sql := v_sql || ' A.DATA_FISCAL, ';
        v_sql := v_sql || ' A.SERIE_DOCFIS, ';
        v_sql := v_sql || ' A.QUANTIDADE, ';
        v_sql := v_sql || ' A.COD_NBM, ';
        v_sql := v_sql || ' A.COD_CFO, ';
        v_sql := v_sql || ' A.GRUPO_PRODUTO, ';
        v_sql := v_sql || ' A.VLR_DESCONTO, ';
        v_sql := v_sql || ' A.VLR_CONTABIL, ';

        v_sql := v_sql || ' A.VLR_ITEM ,'; --
        v_sql := v_sql || ' A.VLR_OUTRAS ,'; --

        v_sql := v_sql || ' A.NUM_AUTENTIC_NFE, ';
        v_sql := v_sql || ' A.VLR_BASE_ICMS , ';
        v_sql := v_sql || ' A.VLR_ALIQ_ICMS , ';
        v_sql := v_sql || ' A.VLR_ICMS , ';

        v_sql := v_sql || ' A.CST_PIS        , '; --
        v_sql := v_sql || ' A.VLR_BASE_PIS   , '; --
        v_sql := v_sql || ' A.VLR_ALIQ_PIS   , '; --
        v_sql := v_sql || ' A.VLR_PIS        , '; --
        v_sql := v_sql || ' A.CST_COFINS     , '; --
        v_sql := v_sql || ' A.VLR_BASE_COFINS, '; --
        v_sql := v_sql || ' A.VLR_ALIQ_COFINS, '; --
        v_sql := v_sql || ' A.VLR_COFINS     , '; --
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

        v_sql := v_sql || ' B.VLR_ITEM        ,'; --
        v_sql := v_sql || ' B.VLR_OUTRAS      ,'; --
        v_sql := v_sql || ' B.VLR_DESCONTO    ,'; --

        v_sql := v_sql || ' B.CST_PIS         ,'; --
        v_sql := v_sql || ' B.VLR_BASE_PIS    ,'; --
        v_sql := v_sql || ' B.VLR_ALIQ_PIS    ,'; --
        v_sql := v_sql || ' B.VLR_PIS         ,'; --
        v_sql := v_sql || ' B.CST_COFINS      ,'; --
        v_sql := v_sql || ' B.VLR_BASE_COFINS ,'; --
        v_sql := v_sql || ' B.VLR_ALIQ_COFINS ,'; --
        v_sql := v_sql || ' B.VLR_COFINS      ,'; --

        v_sql := v_sql || ' B.VLR_ICMSS_N_ESCRIT, '; --

        v_sql := v_sql || ' B.COD_SITUACAO_B, ';
        v_sql := v_sql || ' B.COD_ESTADO, ';
        v_sql := v_sql || ' B.NUM_CONTROLE_DOCTO, ';
        v_sql := v_sql || ' B.NUM_AUTENTIC_NFE, ';
        v_sql := v_sql || ' B.VLR_BASE_ICMS , ';
        v_sql := v_sql || ' B.VLR_ICMS , ';
        v_sql := v_sql || ' B.VLR_BASE_ICMSS , ';
        v_sql := v_sql || ' B.VLR_ICMSS , ';
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
            || '                        ORDER BY A.DATA_FISCAL DESC, A.DATA_EMISSAO DESC, A.NUM_DOCFIS DESC, A.DISCRI_ITEM DESC) RANK, ';
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
        v_sql := v_sql || '     A.NUM_AUTENTIC_NFE ,';

        v_sql := v_sql || '     A.VLR_ITEM        ,'; --
        v_sql := v_sql || '     A.VLR_OUTRAS      ,'; --
        v_sql := v_sql || '     A.VLR_DESCONTO    ,'; --

        v_sql := v_sql || '     A.CST_PIS         ,'; --
        v_sql := v_sql || '     A.VLR_BASE_PIS    ,'; --
        v_sql := v_sql || '     A.VLR_ALIQ_PIS    ,'; --
        v_sql := v_sql || '     A.VLR_PIS         ,'; --
        v_sql := v_sql || '     A.CST_COFINS      ,'; --
        v_sql := v_sql || '     A.VLR_BASE_COFINS ,'; --
        v_sql := v_sql || '     A.VLR_ALIQ_COFINS ,'; --
        v_sql := v_sql || '     A.VLR_COFINS      ,'; --

        v_sql := v_sql || '     A.VLR_ICMSS_N_ESCRIT, '; --

        v_sql := v_sql || '     A.VLR_BASE_ICMS , ';
        v_sql := v_sql || '     A.VLR_ICMS , ';
        v_sql := v_sql || '     A.VLR_BASE_ICMSS , ';
        v_sql := v_sql || '     A.VLR_ICMSS  ';

        v_sql := v_sql || '     FROM ' || vp_tabela_entrada || ' A ';
        v_sql := v_sql || '     WHERE A.PROC_ID       = ''' || vp_proc_id || ''' ';
        v_sql := v_sql || '       AND A.COD_ESTAB     = ''' || vp_filial || ''' ';

        IF ( mcod_empresa = 'DSP' ) THEN
            v_sql := v_sql || '   AND A.CPF_CGC NOT LIKE ''61412110%'' '; --FORNECEDOR DSP
        ELSE
            v_sql := v_sql || '   AND A.CPF_CGC NOT LIKE ''334382500%'' '; --FORNECEDOR DP
        END IF;

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
        v_sql := v_sql || '   AND A.DATA_FISCAL  <= B.DATA_FISCAL ';
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
        v_sql := v_sql || '                     FROM ' || vp_tabela_ult_entrada || ' C ';
        v_sql := v_sql || '                    WHERE C.PROC_ID      = A.PROC_ID ';
        v_sql := v_sql || '                      AND C.COD_EMPRESA  = A.COD_EMPRESA ';
        v_sql := v_sql || '                      AND C.COD_ESTAB    = A.COD_ESTAB ';
        v_sql := v_sql || '                      AND C.NUM_DOCFIS   = A.NUM_DOCFIS ';
        v_sql := v_sql || '                      AND C.DATA_FISCAL  = A.DATA_FISCAL ';
        v_sql := v_sql || '                      AND C.SERIE_DOCFIS = A.SERIE_DOCFIS ';
        v_sql := v_sql || '                      AND C.COD_PRODUTO  = A.COD_PRODUTO ';
        v_sql := v_sql || '                      AND C.UF_ESTAB   = A.UF_ESTAB ';
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
                              , 3072
                              , 1024 )
                     , FALSE );
                loga ( SUBSTR ( v_sql
                              , 4096 )
                     , FALSE );
                ---
                raise_application_error ( -20007
                                        , '!ERRO INSERT GET_COMPRA_DIRETA!' );
        END;

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_tabela_ult_entrada );
    --LOGA('C_COMPRA_DIRETA-FIM-' || VP_FILIAL, FALSE);

    END; --GET_COMPRA_DIRETA

    PROCEDURE get_sem_entrada ( vp_proc_id IN NUMBER
                              , vp_filial IN VARCHAR2
                              , vp_data_ini IN VARCHAR2
                              , vp_data_fim IN VARCHAR2
                              , vp_tabela_saida IN VARCHAR2
                              , vp_tabela_ult_ent IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 10000 );
    BEGIN
        v_sql := 'INSERT /*+APPEND*/ INTO ' || vp_tabela_ult_ent || ' ( ';
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
        --
        v_sql := v_sql || ' A.VLR_ITEM , '; --
        v_sql := v_sql || ' A.VLR_OUTRAS , '; --
        --
        v_sql := v_sql || '  A.NUM_AUTENTIC_NFE , ';
        v_sql := v_sql || '  A.VLR_BASE_ICMS    , ';
        v_sql := v_sql || '  A.VLR_ALIQ_ICMS    , ';
        v_sql := v_sql || '  A.VLR_ICMS         , ';
        --
        v_sql := v_sql || ' A.CST_PIS        , '; --
        v_sql := v_sql || ' A.VLR_BASE_PIS   , '; --
        v_sql := v_sql || ' A.VLR_ALIQ_PIS   , '; --
        v_sql := v_sql || ' A.VLR_PIS        , '; --
        v_sql := v_sql || ' A.CST_COFINS     , '; --
        v_sql := v_sql || ' A.VLR_BASE_COFINS, '; --
        v_sql := v_sql || ' A.VLR_ALIQ_COFINS, '; --
        v_sql := v_sql || ' A.VLR_COFINS     , '; --
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

        v_sql := v_sql || ' 0,'; -- VLR_ITEM
        v_sql := v_sql || ' 0,'; -- VLR_OUTRAS
        v_sql := v_sql || ' 0,'; -- VLR_DESCONTO

        v_sql := v_sql || ' '''','; -- CST_PIS
        v_sql := v_sql || ' 0,'; -- VLR_BASE_PIS
        v_sql := v_sql || ' 0,'; -- VLR_ALIQ_PIS
        v_sql := v_sql || ' 0,'; -- VLR_PIS
        v_sql := v_sql || ' '''','; -- CST_COFINS
        v_sql := v_sql || ' 0,'; -- VLR_BASE_COFINS
        v_sql := v_sql || ' 0,'; -- VLR_ALIQ_COFINS
        v_sql := v_sql || ' 0,'; -- VLR_COFINS

        v_sql := v_sql || ' 0,'; --  VLR_ICMSS_N_ESCRIT

        v_sql := v_sql || '  '''','; --B.COD_SITUACAO_B,
        v_sql := v_sql || '  '''','; --B.COD_ESTADO,
        v_sql := v_sql || '  '''','; --B.NUM_CONTROLE_DOCTO,
        v_sql := v_sql || '  '''','; --B.NUM_AUTENTIC_NFE,
        v_sql := v_sql || '  0,   '; --B.VLR_BASE_ICMS,
        v_sql := v_sql || '  0,   '; --B.VLR_ICMS,
        v_sql := v_sql || '  0,   '; --B.VLR_BASE_ICMSS,
        v_sql := v_sql || '  0,   '; --B.VLR_ICMSS,
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
        v_sql := v_sql || '   AND NOT EXISTS (SELECT /*+PARALLEL_INDEX(C PK_DPSP_UE_' || vp_proc_id || ', 6)*/ ''Y'' ';
        v_sql := v_sql || '                   FROM ' || vp_tabela_ult_ent || ' C ';
        v_sql := v_sql || '                   WHERE C.COD_EMPRESA  = A.COD_EMPRESA';
        v_sql := v_sql || '                     AND C.COD_ESTAB    = A.COD_ESTAB';
        v_sql := v_sql || '                     AND C.UF_ESTAB     = A.UF_ESTAB';
        v_sql := v_sql || '                     AND C.DOCTO        = A.DOCTO';
        v_sql := v_sql || '                     AND C.COD_PRODUTO  = A.COD_PRODUTO';
        v_sql := v_sql || '                     AND C.NUM_ITEM     = A.NUM_ITEM';
        v_sql := v_sql || '                     AND C.NUM_DOCFIS   = A.NUM_DOCFIS';
        v_sql := v_sql || '                     AND C.DATA_FISCAL  = A.DATA_FISCAL';
        v_sql := v_sql || '                     AND C.SERIE_DOCFIS = A.SERIE_DOCFIS)) ';

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
                ---
                raise_application_error ( -20007
                                        , '!ERRO INSERT GET_SEM_ENTRADA!' );
        END;

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_tabela_ult_ent );
    --LOGA('C_SEM_ENTRADA-FIM-' || VP_FILIAL, FALSE);

    END; --GET_SEM_ENTRADA

    PROCEDURE load_nf_people ( vp_proc_id IN VARCHAR2
                             , vp_cod_empresa IN VARCHAR2
                             , vp_tab_entrada_c IN VARCHAR2
                             , vp_tab_entrada_f IN VARCHAR2
                             , vp_tabela_nf   OUT VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 10000 );
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
            v_sql := v_sql || '             NVL(TRUNC(C.ICMSTAX_BRL_BSS/C.QTY_NF_BRL, 2), 0) AS BASE_ICMS_UNIT, ';
            v_sql := v_sql || '             NVL(TRUNC(C.ICMSTAX_BRL_AMT/C.QTY_NF_BRL, 2), 0) AS VLR_ICMS_UNIT, ';
            v_sql := v_sql || '             NVL(C.ICMSTAX_BRL_PCT, 0) AS ALIQ_ICMS,  ';
            v_sql :=
                   v_sql
                || '             TRUNC(DECODE(NVL(C.DSP_ICMS_BSS_ST, 0), 0, NVL(C.DSP_ICMSSUBBRL_BSS, 0), NVL(C.DSP_ICMS_BSS_ST, 0))/C.QTY_NF_BRL, 2) AS BASE_ST_UNIT, ';
            v_sql :=
                   v_sql
                || '             TRUNC(DECODE(NVL(C.DSP_ICMS_AMT_ST, 0), 0, NVL(C.DSP_ICMSSUBBRL_AMT, 0), NVL(C.DSP_ICMS_AMT_ST, 0))/C.QTY_NF_BRL, 2) AS VLR_ICMS_ST_UNIT, ';
            v_sql := v_sql || '             TRUNC(NVL(C.ICMSSUB_BRL_AMT,0)/C.QTY_NF_BRL, 2) AS VLR_ICMS_ST_UNIT_AUX ';
            v_sql := v_sql || '              FROM MSAFI.PS_NF_LN_BRL C ) C ';
            v_sql := v_sql || '         WHERE A.PROC_ID             = ''' || vp_proc_id || ''' ';
            v_sql := v_sql || '           AND A.COD_EMPRESA         = ''' || vp_cod_empresa || ''' ';
            v_sql := v_sql || '   AND B.COD_EMPRESA         = A.COD_EMPRESA ';
            v_sql := v_sql || '           AND C.BUSINESS_UNIT       = B.BU_PO1 ';
            v_sql := v_sql || '   AND C.NF_BRL_ID           = A.NUM_CONTROLE_DOCTO ';
            v_sql := v_sql || '   AND C.NF_BRL_LINE_NUM     = A.NUM_ITEM ';
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
            v_sql := v_sql || '             NVL(TRUNC(C.ICMSTAX_BRL_BSS/C.QTY_NF_BRL, 2), 0) AS BASE_ICMS_UNIT, ';
            v_sql := v_sql || '             NVL(TRUNC(C.ICMSTAX_BRL_AMT/C.QTY_NF_BRL, 2), 0) AS VLR_ICMS_UNIT, ';
            v_sql := v_sql || '             NVL(C.ICMSTAX_BRL_PCT, 0) AS ALIQ_ICMS,  ';
            v_sql :=
                   v_sql
                || '             TRUNC(DECODE(NVL(C.DSP_ICMS_BSS_ST, 0), 0, NVL(C.DSP_ICMSSUBBRL_BSS, 0), NVL(C.DSP_ICMS_BSS_ST, 0))/C.QTY_NF_BRL, 2) AS BASE_ST_UNIT, ';
            v_sql :=
                   v_sql
                || '             TRUNC(DECODE(NVL(C.DSP_ICMS_AMT_ST, 0), 0, NVL(C.DSP_ICMSSUBBRL_AMT, 0), NVL(C.DSP_ICMS_AMT_ST, 0))/C.QTY_NF_BRL, 2) AS VLR_ICMS_ST_UNIT, ';
            v_sql := v_sql || '             TRUNC(NVL(C.ICMSSUB_BRL_AMT,0)/C.QTY_NF_BRL, 2) AS VLR_ICMS_ST_UNIT_AUX ';
            v_sql := v_sql || '              FROM MSAFI.PS_NF_LN_BRL C ) C ';
            v_sql := v_sql || '         WHERE A.PROC_ID             = ''' || vp_proc_id || ''' ';
            v_sql := v_sql || '           AND A.COD_EMPRESA         = ''' || vp_cod_empresa || ''' ';
            v_sql := v_sql || '   AND B.COD_EMPRESA         = A.COD_EMPRESA ';
            v_sql := v_sql || '           AND C.BUSINESS_UNIT       = B.BU_PO1 ';
            v_sql := v_sql || '   AND C.NF_BRL_ID           = A.NUM_CONTROLE_DOCTO ';
            v_sql := v_sql || '   AND C.NF_BRL_LINE_NUM     = A.NUM_ITEM ';
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
        DELETE dpsp_ex_bpc_uentr_jj
         WHERE cod_empresa = mcod_empresa
           AND cod_estab = p_i_cod_estab
           AND data_fiscal BETWEEN p_i_data_ini AND p_i_data_fim;

        COMMIT;
    END;

    PROCEDURE delete_temp_tbl ( p_i_proc_instance IN VARCHAR2
                              , vp_nome_tabela_aliq IN VARCHAR2
                              , vp_tab_entrada_c IN VARCHAR2
                              , vp_tab_entrada_f IN VARCHAR2
                              , vp_tab_entrada_co IN VARCHAR2
                              , vp_tabela_saida IN VARCHAR2
                              , vp_tabela_nf IN VARCHAR2
                              , vp_tabela_pmc_mva IN VARCHAR2 )
    IS
    BEGIN
        BEGIN
            EXECUTE IMMEDIATE 'DROP TABLE ' || vp_nome_tabela_aliq;
        EXCEPTION
            WHEN OTHERS THEN
                loga ( '[ERRO] DROP ALIQ ' || vp_nome_tabela_aliq
                     , FALSE );
        END;

        ---
        BEGIN
            EXECUTE IMMEDIATE 'DROP TABLE ' || vp_tab_entrada_c;
        EXCEPTION
            WHEN OTHERS THEN
                loga ( '[ERRO] DROP ENT CD ' || vp_tab_entrada_c
                     , FALSE );
        END;

        ---
        BEGIN
            EXECUTE IMMEDIATE 'DROP TABLE ' || vp_tab_entrada_f;
        EXCEPTION
            WHEN OTHERS THEN
                loga ( '[ERRO] DROP ENT F ' || vp_tab_entrada_f
                     , FALSE );
        END;

        ---
        BEGIN
            EXECUTE IMMEDIATE 'DROP TABLE ' || vp_tab_entrada_co;
        EXCEPTION
            WHEN OTHERS THEN
                loga ( '[ERRO] DROP ENT CDIRETA ' || vp_tab_entrada_co
                     , FALSE );
        END;

        ---
        BEGIN
            EXECUTE IMMEDIATE 'DROP TABLE ' || vp_tabela_saida;
        EXCEPTION
            WHEN OTHERS THEN
                loga ( '[ERRO] DROP SAIDA ' || vp_tabela_saida
                     , FALSE );
        END;

        ---
        BEGIN
            EXECUTE IMMEDIATE 'DROP TABLE ' || vp_tabela_nf;
        EXCEPTION
            WHEN OTHERS THEN
                loga ( '[ERRO] DROP NF ' || vp_tabela_nf
                     , FALSE );
        END;

        ---
        BEGIN
            EXECUTE IMMEDIATE 'DROP TABLE ' || vp_tabela_pmc_mva;
        EXCEPTION
            WHEN OTHERS THEN
                loga ( '[ERRO] DROP PMC ' || vp_tabela_pmc_mva
                     , FALSE );
        END;

        --- remover nome da TMP do controle
        del_tmp_control ( p_i_proc_instance
                        , vp_nome_tabela_aliq );
        --
        del_tmp_control ( p_i_proc_instance
                        , vp_tab_entrada_c );
        del_tmp_control ( p_i_proc_instance
                        , vp_tab_entrada_f );
        del_tmp_control ( p_i_proc_instance
                        , vp_tab_entrada_co );
        --
        del_tmp_control ( p_i_proc_instance
                        , vp_tabela_saida );
        del_tmp_control ( p_i_proc_instance
                        , vp_tabela_nf );
        del_tmp_control ( p_i_proc_instance
                        , vp_tabela_pmc_mva );
        --- checar TMPs de processos interrompidos e dropar
        drop_old_tmp;
    END; --PROCEDURE DELETE_TEMP_TBL

    PROCEDURE grava ( p_texto VARCHAR2
                    , p_tipo VARCHAR2 DEFAULT '1' )
    IS
    BEGIN
        lib_proc.add ( p_texto
                     , ptipo => p_tipo );
    END;

    PROCEDURE cabecalho ( p_cod_estab VARCHAR2
                        , p_tipo VARCHAR2 DEFAULT '1' )
    IS
        v_cl_01 VARCHAR2 ( 6 ) := 'AAAAAA';
        v_cl_02 VARCHAR2 ( 6 ) := '55AA55';
    BEGIN
        grava ( dsp_planilha.linha (    dsp_planilha.campo ( 'SAIDAS ' || p_cod_estab
                                                           , p_custom => 'COLSPAN=29' )
                                     || --
                                       dsp_planilha.campo ( 'ENTRADAS'
                                                          , p_custom => 'COLSPAN=30 bgcolor="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'CÁLCULO'
                                                          , p_custom => ' bgcolor="#' || v_cl_02 || '"' )
                                   , --
                                    p_class => 'h' )
              , p_tipo );
        grava ( dsp_planilha.linha (    dsp_planilha.campo ( 'COD_EMPRESA' )
                                     || --
                                       dsp_planilha.campo ( 'COD_ESTAB' )
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
                                        --Dsp_Planilha.Campo('CST_TAB') || --
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
                                                           , p_custom => 'bgcolor="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'DATA_FISCAL'
                                                          , p_custom => 'bgcolor="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'NUM_DOCFIS'
                                                          , p_custom => 'bgcolor="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'SERIE_DOCFIS'
                                                          , p_custom => 'bgcolor="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'NUM_CONTROLE_DOCTO'
                                                          , p_custom => 'bgcolor="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'NUM_AUTENTIC_NFE'
                                                          , p_custom => 'bgcolor="#' || v_cl_01 || '"'
                                                          , p_width => 280 )
                                     || --
                                       dsp_planilha.campo ( 'NUM_ITEM'
                                                          , p_custom => 'bgcolor="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'COD_CFO'
                                                          , p_custom => 'bgcolor="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'COD_CFO_SAIDA'
                                                          , p_custom => 'bgcolor="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'QUANTIDADE'
                                                          , p_custom => 'bgcolor="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'VLR_ITEM'
                                                          , p_custom => 'bgcolor="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'VLR_CONTAB_ITEM'
                                                          , p_custom => 'bgcolor="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'VLR_OUTRAS'
                                                          , p_custom => 'bgcolor="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'VLR_DESCONTO'
                                                          , p_custom => 'bgcolor="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'VLR_BASE_ICMS'
                                                          , p_custom => 'bgcolor="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'VLR_ICMS'
                                                          , p_custom => 'bgcolor="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'VLR_BASE_ICMS_ST'
                                                          , p_custom => 'bgcolor="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'VLR_ICMS_ST'
                                                          , p_custom => 'bgcolor="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'COD_SITUACAO_PIS'
                                                          , p_custom => 'bgcolor="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'VLR_BASE_PIS'
                                                          , p_custom => 'bgcolor="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'VLR_ALIQ_PIS'
                                                          , p_custom => 'bgcolor="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'VLR_PIS'
                                                          , p_custom => 'bgcolor="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'COD_SITUACAO_COFINS'
                                                          , p_custom => 'bgcolor="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'VLR_BASE_COFINS'
                                                          , p_custom => 'bgcolor="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'VLR_ALIQ_COFINS'
                                                          , p_custom => 'bgcolor="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'VLR_COFINS'
                                                          , p_custom => 'bgcolor="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'VLR_ICMSS_N_ESCRIT'
                                                          , p_custom => 'bgcolor="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'VLR_ICMS_UNIT'
                                                          , p_custom => 'bgcolor="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'VLR_ICMS_ST_UNIT'
                                                          , p_custom => 'bgcolor="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'VLR_ICMS_ST_UNIT_AUX'
                                                          , p_custom => 'bgcolor="#' || v_cl_01 || '"' )
                                     || --
                                       dsp_planilha.campo ( 'VALOR'
                                                          , p_custom => 'bgcolor="#' || v_cl_02 || '"' ) --
                                   , p_class => 'h' )
              , p_tipo );
    END;

    PROCEDURE cabecalho_sintetico ( p_cod_estab VARCHAR2
                                  , p_tipo VARCHAR2 DEFAULT '1' )
    IS
        v_cl_01 VARCHAR2 ( 6 ) := 'AAAAAA';
        v_cl_02 VARCHAR2 ( 6 ) := '55AA55';
    BEGIN
        grava ( dsp_planilha.linha ( dsp_planilha.campo ( 'RELATORIO SINTETICO'
                                                        , p_custom => 'COLSPAN=9' )
                                   , p_class => 'h' )
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
                                       dsp_planilha.campo ( 'VLR ICMS UNIT' )
                                     || --
                                       dsp_planilha.campo ( 'VLR ICMS ST UNIT' )
                                     || --
                                       dsp_planilha.campo ( 'VLR ICMS ST UNIT AUX' )
                                     || --
                                       dsp_planilha.campo ( 'VLR CALCULADO' )
                                   , p_class => 'h'
                )
              , p_tipo );
    END;

    PROCEDURE grava_relatorio ( p_cod_estab VARCHAR2
                              , vp_data_ini DATE
                              , vp_data_fim DATE
                              , p_tipo VARCHAR2 DEFAULT '1' )
    IS
        v_class_linha CHAR ( 1 ) := 'a';
        v_vlr_calculado NUMBER;
    BEGIN
        lib_proc.add_tipo ( mproc_id
                          , p_tipo
                          ,    'NF_EXCL_'
                            || mcod_empresa
                            || '_'
                            || p_cod_estab
                            || '_'
                            || TO_CHAR ( vp_data_ini
                                       , 'yyyymm' )
                            || '.xls'
                          , 2 );

        grava ( dsp_planilha.header
              , p_tipo );
        grava ( dsp_planilha.tabela_inicio
              , p_tipo );
        cabecalho ( p_cod_estab
                  , p_tipo );

        FOR p_rs_relatorio IN crs_relatorio ( p_cod_estab
                                            , vp_data_ini
                                            , vp_data_fim ) LOOP
            IF v_class_linha = 'b' THEN
                v_class_linha := 'a';
            ELSE
                v_class_linha := 'b';
            END IF;

            v_vlr_calculado := 0;

            IF p_rs_relatorio.cod_cfo = '5405' THEN
                IF ( p_rs_relatorio.vlr_icmss_e > 0
                 OR p_rs_relatorio.vlr_icmss_n_escrit > 0 )
                OR ( p_rs_relatorio.uf_estab = 'SP'
                AND p_rs_relatorio.cod_cfo_e = '1409'
                AND p_rs_relatorio.vlr_icms_unit > 0 ) THEN
                    IF p_rs_relatorio.vlr_icms_st_unit > 0 THEN
                        v_vlr_calculado :=
                              ( p_rs_relatorio.vlr_icms_unit + p_rs_relatorio.vlr_icms_st_unit )
                            * p_rs_relatorio.quantidade;
                    ELSE
                        v_vlr_calculado :=
                              ( p_rs_relatorio.vlr_icms_unit + p_rs_relatorio.vlr_icms_st_unit_aux )
                            * p_rs_relatorio.quantidade;
                    END IF;
                END IF;
            ELSIF p_rs_relatorio.cod_cfo = '5102' THEN
                v_vlr_calculado := p_rs_relatorio.vlr_icms;
            END IF;

            grava ( dsp_planilha.linha (
                                            dsp_planilha.campo ( p_rs_relatorio.cod_empresa )
                                         || --
                                           dsp_planilha.campo ( p_rs_relatorio.cod_estab )
                                         || --
                                           dsp_planilha.campo ( p_rs_relatorio.data_fiscal )
                                         || --
                                           dsp_planilha.campo ( p_rs_relatorio.cod_docto )
                                         || --
                                           dsp_planilha.campo ( dsp_planilha.texto ( p_rs_relatorio.num_docfis ) )
                                         || --
                                           dsp_planilha.campo ( p_rs_relatorio.serie_docfis )
                                         || --
                                           dsp_planilha.campo (
                                                                dsp_planilha.texto ( p_rs_relatorio.num_autentic_nfe )
                                            )
                                         || --
                                           dsp_planilha.campo ( dsp_planilha.texto ( p_rs_relatorio.cod_produto ) )
                                         || --
                                           dsp_planilha.campo ( p_rs_relatorio.descricao )
                                         || --
                                           dsp_planilha.campo ( p_rs_relatorio.num_item )
                                         || --
                                           dsp_planilha.campo ( p_rs_relatorio.cod_cfo )
                                         || --
                                           dsp_planilha.campo ( dsp_planilha.texto ( p_rs_relatorio.cod_nbm ) )
                                         || --
                                           dsp_planilha.campo ( p_rs_relatorio.lista )
                                         || --
                                            --Dsp_Planilha.Campo(p_Rs_Relatorio.Cst_Pc) || --
                                            dsp_planilha.campo ( p_rs_relatorio.quantidade )
                                         || --
                                           dsp_planilha.campo ( p_rs_relatorio.vlr_item )
                                         || --
                                           dsp_planilha.campo ( p_rs_relatorio.vlr_contab_item )
                                         || --
                                           dsp_planilha.campo ( p_rs_relatorio.vlr_outras )
                                         || --
                                           dsp_planilha.campo ( p_rs_relatorio.vlr_desconto )
                                         || --
                                           dsp_planilha.campo ( p_rs_relatorio.vlr_base_icms )
                                         || --
                                           dsp_planilha.campo ( p_rs_relatorio.aliq_icms )
                                         || --
                                           dsp_planilha.campo ( p_rs_relatorio.vlr_icms )
                                         || --
                                           dsp_planilha.campo (
                                                                dsp_planilha.texto ( p_rs_relatorio.cod_situacao_pis )
                                            )
                                         || --
                                           dsp_planilha.campo ( p_rs_relatorio.vlr_base_pis )
                                         || --
                                           dsp_planilha.campo ( p_rs_relatorio.vlr_aliq_pis )
                                         || --
                                           dsp_planilha.campo ( p_rs_relatorio.vlr_pis )
                                         || --
                                           dsp_planilha.campo (
                                                                dsp_planilha.texto (
                                                                                     p_rs_relatorio.cod_situacao_cofins
                                                                )
                                            )
                                         || --
                                           dsp_planilha.campo ( p_rs_relatorio.vlr_base_cofins )
                                         || --
                                           dsp_planilha.campo ( p_rs_relatorio.vlr_aliq_cofins )
                                         || --
                                           dsp_planilha.campo ( p_rs_relatorio.vlr_cofins )
                                         || --
                                            --
                                            dsp_planilha.campo ( p_rs_relatorio.cod_estab_e )
                                         || --
                                           dsp_planilha.campo ( p_rs_relatorio.data_fiscal_e )
                                         || --
                                           dsp_planilha.campo ( dsp_planilha.texto ( p_rs_relatorio.num_docfis_e ) )
                                         || --
                                           dsp_planilha.campo ( p_rs_relatorio.serie_docfis_e )
                                         || --
                                           dsp_planilha.campo (
                                                                dsp_planilha.texto (
                                                                                     p_rs_relatorio.num_controle_docto_e
                                                                )
                                            )
                                         || --
                                           dsp_planilha.campo (
                                                                dsp_planilha.texto (
                                                                                     p_rs_relatorio.num_autentic_nfe_e
                                                                )
                                            )
                                         || --
                                           dsp_planilha.campo ( p_rs_relatorio.num_item_e )
                                         || --
                                           dsp_planilha.campo ( p_rs_relatorio.cod_cfo_e )
                                         || --
                                           dsp_planilha.campo ( p_rs_relatorio.cod_cfo_saida )
                                         || --
                                           dsp_planilha.campo ( p_rs_relatorio.quantidade_e )
                                         || --
                                           dsp_planilha.campo ( p_rs_relatorio.vlr_item_e )
                                         || --
                                           dsp_planilha.campo ( p_rs_relatorio.vlr_contab_item_e )
                                         || --
                                           dsp_planilha.campo ( p_rs_relatorio.vlr_outras_e )
                                         || --
                                           dsp_planilha.campo ( p_rs_relatorio.vlr_desconto_e )
                                         || --
                                           dsp_planilha.campo ( p_rs_relatorio.vlr_base_icms_e )
                                         || --
                                           dsp_planilha.campo ( p_rs_relatorio.vlr_icms_e )
                                         || --
                                           dsp_planilha.campo ( p_rs_relatorio.vlr_base_icmss_e )
                                         || --
                                           dsp_planilha.campo ( p_rs_relatorio.vlr_icmss_e )
                                         || --
                                           dsp_planilha.campo (
                                                                dsp_planilha.texto (
                                                                                     p_rs_relatorio.cod_situacao_pis_e
                                                                )
                                            )
                                         || --
                                           dsp_planilha.campo ( p_rs_relatorio.vlr_base_pis_e )
                                         || --
                                           dsp_planilha.campo ( p_rs_relatorio.vlr_aliq_pis_e )
                                         || --
                                           dsp_planilha.campo ( p_rs_relatorio.vlr_pis_e )
                                         || --
                                           dsp_planilha.campo (
                                                                dsp_planilha.texto (
                                                                                     p_rs_relatorio.cod_situacao_cofins_e
                                                                )
                                            )
                                         || --
                                           dsp_planilha.campo ( p_rs_relatorio.vlr_base_cofins_e )
                                         || --
                                           dsp_planilha.campo ( p_rs_relatorio.vlr_aliq_cofins_e )
                                         || --
                                           dsp_planilha.campo ( p_rs_relatorio.vlr_cofins_e )
                                         || --
                                           dsp_planilha.campo ( p_rs_relatorio.vlr_icmss_n_escrit )
                                         || --
                                           dsp_planilha.campo ( p_rs_relatorio.vlr_icms_unit )
                                         || --
                                           dsp_planilha.campo ( p_rs_relatorio.vlr_icms_st_unit )
                                         || --
                                           dsp_planilha.campo ( p_rs_relatorio.vlr_icms_st_unit_aux )
                                         || --
                                           dsp_planilha.campo ( v_vlr_calculado )
                                       , --
                                         --
                                         p_class => v_class_linha
                    )
                  , p_tipo );
        END LOOP;

        grava ( dsp_planilha.tabela_fim
              , p_tipo );
    END;

    PROCEDURE grava_sintetico ( p_cod_estab VARCHAR2
                              , vp_data_ini DATE
                              , vp_data_fim DATE
                              , p_tipo VARCHAR2 DEFAULT '1' )
    IS
        v_class_linha CHAR ( 1 ) := 'a';
    BEGIN
        FOR c_si IN c_sintetico ( p_cod_estab
                                , vp_data_ini
                                , vp_data_fim ) LOOP
            IF v_class_linha = 'b' THEN
                v_class_linha := 'a';
            ELSE
                v_class_linha := 'b';
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
                                           dsp_planilha.campo ( c_si.vlr_icms_unit )
                                         || --
                                           dsp_planilha.campo ( c_si.vlr_icms_st_unit )
                                         || --
                                           dsp_planilha.campo ( c_si.vlr_icms_st_unit_aux )
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
                      , p_lojas lib_proc.vartab )
        RETURN INTEGER
    IS
        p_origem1 VARCHAR2 ( 6 );
        p_cd1 VARCHAR2 ( 6 );
        p_origem2 VARCHAR2 ( 6 );
        p_cd2 VARCHAR2 ( 6 );
        p_origem3 VARCHAR2 ( 6 );
        p_cd3 VARCHAR2 ( 6 );
        p_origem4 VARCHAR2 ( 6 );
        p_cd4 VARCHAR2 ( 6 );
        p_origem5 VARCHAR2 ( 6 );
        p_cd5 VARCHAR2 ( 6 );
        p_direta VARCHAR2 ( 6 );
        v_uf VARCHAR2 ( 6 );

        v_data_limite VARCHAR2 ( 8 );

        i1 INTEGER;

        TYPE a_estabs_t IS TABLE OF VARCHAR2 ( 6 );

        a_estabs a_estabs_t := a_estabs_t ( );
        a_estab_part a_estabs_t := a_estabs_t ( );

        --Variaveis genericas
        p_proc_instance VARCHAR2 ( 30 );
        --
        --TABELAS TEMP
        v_nome_tabela_aliq VARCHAR2 ( 30 );
        v_tab_entrada_c VARCHAR2 ( 30 );
        v_tab_entrada_f VARCHAR2 ( 30 );
        v_tab_entrada_co VARCHAR2 ( 30 );
        v_tabela_saida VARCHAR2 ( 30 );
        v_tabela_nf VARCHAR2 ( 30 );
        v_tabela_ult_entrada VARCHAR2 ( 30 );
        ---
        v_sql_resultado VARCHAR2 ( 10000 );
        p_tipo VARCHAR2 ( 8 );
        ---
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

        mproc_id_o := lib_proc.new ( 'DPSP_EX_PIS_COFINS_635_CPROC' );

        --MARCAR INCIO DA EXECUCAO
        v_data_hora_ini :=
            TO_CHAR ( SYSDATE
                    , 'DD/MM/YYYY HH24:MI.SS' );

        ---
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

        msafi.atualiza_lista;

        --PREPARAR LOJAS SP
        IF ( p_lojas.COUNT > 0 ) THEN
            i1 := p_lojas.FIRST;

            IF SUBSTR ( p_lojas ( i1 )
                      , 1
                      , 2 ) = 'UF' THEN
                --v_Lojas_uf
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
                   AND e.cod_estab = p_lojas ( 1 );

                WHILE i1 IS NOT NULL LOOP
                    a_estabs.EXTEND ( );
                    a_estabs ( a_estabs.LAST ) := p_lojas ( i1 );
                    i1 := p_lojas.NEXT ( i1 );
                END LOOP;
            END IF;
        END IF;

        v_data_limite :=
            TO_CHAR ( v_data_inicial - ( 365 * 2 )
                    , 'DDMMYYYY' ); ---DATA LIMITE PARA ULTIMAS ENTRADAS

        IF p_rel <> '3' THEN --(1)
            i1 := 0;

            FOR est IN a_estabs.FIRST .. a_estabs.COUNT LOOP
                i1 := i1 + 1;
                a_estab_part.EXTEND ( );
                a_estab_part ( i1 ) := a_estabs ( est );

                /*If Then

                End If;*/

                IF MOD ( a_estab_part.COUNT
                       , v_quant_empresas ) = 0
                OR est = a_estabs.COUNT THEN
                    i1 := 0;

                    mproc_id := lib_proc.new ( 'DPSP_EX_PIS_COFINS_635_CPROC' );

                    --GERAR CHAVE PROC_ID
                    SELECT ROUND ( dbms_random.VALUE ( 10000000000000
                                                     , 999999999999999 ) )
                      INTO p_proc_instance
                      FROM DUAL;

                    ---------------------

                    loga ( '<< INICIO DO PROCESSAMENTO... >>' || p_proc_instance );

                    dpsp_entradas_ressarc_cpar.busca_parametros ( v_uf
                                                                , p_origem1
                                                                , p_cd1
                                                                , p_origem2
                                                                , p_cd2
                                                                , p_origem3
                                                                , p_cd3
                                                                , p_origem4
                                                                , p_cd4
                                                                , p_origem5
                                                                , p_cd5
                                                                , p_direta );

                    loga (
                              v_uf
                           || ' - '
                           || p_origem1
                           || ' - '
                           || p_cd1
                           || ' - '
                           || p_origem2
                           || ' - '
                           || p_cd2
                           || ' - '
                           || p_origem3
                           || ' - '
                           || p_cd3
                           || ' - '
                           || p_origem4
                           || ' - '
                           || p_cd4
                           || ' - '
                           || p_origem5
                           || ' - '
                           || p_cd5
                           || ' - '
                           || p_direta
                           || ' - '
                           || v_data_inicial
                           || ' - '
                           || v_data_final
                    );

                    IF p_rel = '1' --PROCESSAMENTO
                                  THEN
                        --CRIAR TABELA DE SAIDA TMP
                        create_tab_saida ( p_proc_instance
                                         , v_tabela_saida );
                        save_tmp_control ( p_proc_instance
                                         , v_tabela_saida );

                        --CARREGAR SAIDAS
                        FOR i IN 1 .. a_estab_part.COUNT LOOP
                            load_saidas ( p_proc_instance
                                        , a_estab_part ( i )
                                        , v_data_inicial
                                        , v_data_final
                                        , p_uf
                                        , v_tabela_saida );
                        END LOOP;

                        --CRIAR INDICES DA TEMP DE SAIDA
                        create_tab_saida_idx ( p_proc_instance
                                             , v_tabela_saida );
                        --CRIAR E CARREGAR TABELAS TEMP DE ALIQ ST
                        load_aliq_pmc ( p_proc_instance
                                      , v_nome_tabela_aliq
                                      , v_tabela_saida );

                        --CARREGAR DADOS DE ORIGEM CD
                        IF ( p_origem1 = 'C'
                        AND p_cd1 IS NOT NULL )
                        OR ( p_origem2 = 'C'
                        AND p_cd2 IS NOT NULL )
                        OR ( p_origem3 = 'C'
                        AND p_cd3 IS NOT NULL )
                        OR ( p_origem4 = 'C'
                        AND p_cd4 IS NOT NULL )
                        OR ( p_origem4 = 'C'
                        AND p_cd5 IS NOT NULL ) THEN
                            loga ( '> CARGA TEMP ENTRADAs CD-INI'
                                 , FALSE );

                            --CRIAR TABELA TMP DE ENTRADA CD
                            create_tab_entrada_cd ( p_proc_instance
                                                  , v_tab_entrada_c );

                            IF ( p_origem1 = 'C' ) THEN
                                --CARREGAR TEMPORARIAS ENTRADA NOS CDs
                                load_entradas ( p_proc_instance
                                              , p_cd1
                                              , 'C'
                                              , v_tab_entrada_c
                                              , v_tabela_saida
                                              , v_data_limite );
                            END IF;

                            IF ( p_origem2 = 'C'
                            AND p_cd2 <> p_cd1 ) THEN
                                --CARREGAR TEMPORARIAS ENTRADA NOS CDs
                                load_entradas ( p_proc_instance
                                              , p_cd2
                                              , 'C'
                                              , v_tab_entrada_c
                                              , v_tabela_saida
                                              , v_data_limite );
                            END IF;

                            IF ( p_origem3 = 'C'
                            AND p_cd3 <> p_cd2
                            AND p_cd3 <> p_cd1 ) THEN
                                --CARREGAR TEMPORARIAS ENTRADA NOS CDs
                                load_entradas ( p_proc_instance
                                              , p_cd3
                                              , 'C'
                                              , v_tab_entrada_c
                                              , v_tabela_saida
                                              , v_data_limite );
                            END IF;

                            IF ( p_origem4 = 'C'
                            AND p_cd4 <> p_cd3
                            AND p_cd4 <> p_cd2
                            AND p_cd4 <> p_cd1 ) THEN
                                --CARREGAR TEMPORARIAS ENTRADA NOS CDs
                                load_entradas ( p_proc_instance
                                              , p_cd4
                                              , 'C'
                                              , v_tab_entrada_c
                                              , v_tabela_saida
                                              , v_data_limite );
                            END IF;

                            IF ( p_origem5 = 'C'
                            AND p_cd5 <> p_cd4
                            AND p_cd5 <> p_cd3
                            AND p_cd5 <> p_cd2
                            AND p_cd5 <> p_cd1 ) THEN
                                --CARREGAR TEMPORARIAS ENTRADA NOS CDs
                                load_entradas ( p_proc_instance
                                              , p_cd5
                                              , 'C'
                                              , v_tab_entrada_c
                                              , v_tabela_saida
                                              , v_data_limite );
                            END IF;

                            --CRIAR INDICES DA TEMP DE ENTRADA CD
                            create_tab_entrada_cd_idx ( p_proc_instance
                                                      , v_tab_entrada_c );

                            loga ( '> CARGA TEMP ENTRADAs CD-FIM'
                                 , FALSE );
                        END IF;

                        --CARREGAR DADOS ENTRADA EM FILIAIS - TRANSFERENCIA
                        IF ( p_origem1 = 'L' )
                        OR ( p_origem2 = 'L' )
                        OR ( p_origem3 = 'L' )
                        OR ( p_origem4 = 'L' )
                        OR ( p_origem5 = 'L' ) THEN
                            loga ( '> CARGA TEMP ENTRADAs FILIAL-INI'
                                 , FALSE );
                            --CRIAR TABELA TMP DE ENTRADA EM FILIAIS
                            create_tab_entrada_f ( p_proc_instance
                                                 , v_tab_entrada_f );

                            FOR i IN 1 .. a_estab_part.COUNT LOOP
                                --CARREGAR TEMPORARIAS ENTRADA NAS FILIAIS
                                load_entradas ( p_proc_instance
                                              , a_estab_part ( i )
                                              , 'F'
                                              , v_tab_entrada_f
                                              , v_tabela_saida
                                              , v_data_limite );
                            END LOOP; --FOR i IN 1..A_ESTABS.COUNT

                            create_tab_entrada_f_idx ( p_proc_instance
                                                     , v_tab_entrada_f );

                            loga ( '> CARGA TEMP ENTRADAs FILIAL-FIM'
                                 , FALSE );
                        END IF; --IF (P_ORIGEM1 = '1') OR (P_ORIGEM2 = '1') OR (P_ORIGEM3 = '1') OR (P_ORIGEM4 = '1') THEN

                        --CARREGAR DADOS ENTRADA COMPRA DIRETA
                        IF ( p_direta = 'S' ) THEN
                            loga ( '> ENTRADAs CDIRETA-INI'
                                 , FALSE );

                            --CRIAR TABELA TMP DE ENTRADA COMPRA DIRETA
                            create_tab_entrada_co ( p_proc_instance
                                                  , v_tab_entrada_co );

                            FOR i IN 1 .. a_estab_part.COUNT LOOP
                                --CARREGAR TEMPORARIAS ENTRADA NAS FILIAIS COMPRA DIRETA
                                load_entradas ( p_proc_instance
                                              , a_estab_part ( i )
                                              , 'CO'
                                              , v_tab_entrada_co
                                              , v_tabela_saida
                                              , v_data_limite );
                            END LOOP; --FOR i IN 1..A_ESTABS.COUNT

                            create_tab_entrada_co_idx ( p_proc_instance
                                                      , v_tab_entrada_co );

                            loga ( '> ENTRADAs CDIRETA-FIM'
                                 , FALSE );
                        END IF;

                        --CARREGAR NFs DO PEOPLE
                        load_nf_people ( p_proc_instance
                                       , mcod_empresa
                                       , v_tab_entrada_c
                                       , v_tab_entrada_f
                                       , v_tabela_nf );

                        --CRIAR TABELA RESULTADO TMP
                        create_tab_ult_entradas ( p_proc_instance
                                                , v_tabela_ult_entrada );

                        --LOOP PARA CADA FILIAL-INI--------------------------------------------------------------------------------------
                        FOR i IN 1 .. a_estab_part.COUNT LOOP
                            --ASSOCIAR SAIDAS COM SUAS ULTIMAS ENTRADAS
                            IF ( p_cd1 IS NOT NULL ) THEN
                                IF ( p_origem1 = 'L' ) THEN
                                    --ENTRADA NAS FILIAIS
                                    get_entradas_filial ( p_proc_instance
                                                        , a_estab_part ( i )
                                                        , p_cd1
                                                        , v_data_inicial
                                                        , v_data_final
                                                        , v_tab_entrada_f
                                                        , v_tabela_saida
                                                        , v_tabela_nf
                                                        , v_tabela_ult_entrada );
                                ELSIF ( p_origem1 = 'C' ) THEN
                                    --ENTRADA NOS CDs
                                    get_entradas_cd ( p_proc_instance
                                                    , a_estab_part ( i )
                                                    , p_cd1
                                                    , v_tab_entrada_c
                                                    , v_tabela_saida
                                                    , v_tabela_nf
                                                    , v_tabela_ult_entrada );
                                END IF;
                            END IF;

                            IF ( p_cd2 IS NOT NULL ) THEN
                                IF ( p_origem2 = 'L' ) THEN
                                    --ENTRADA NAS FILIAIS
                                    get_entradas_filial ( p_proc_instance
                                                        , a_estab_part ( i )
                                                        , p_cd2
                                                        , v_data_inicial
                                                        , v_data_final
                                                        , v_tab_entrada_f
                                                        , v_tabela_saida
                                                        , v_tabela_nf
                                                        , v_tabela_ult_entrada );
                                ELSIF ( p_origem2 = 'C' ) THEN
                                    --ENTRADA NOS CDs
                                    get_entradas_cd ( p_proc_instance
                                                    , a_estab_part ( i )
                                                    , p_cd2
                                                    , v_tab_entrada_c
                                                    , v_tabela_saida
                                                    , v_tabela_nf
                                                    , v_tabela_ult_entrada );
                                END IF;
                            END IF;

                            IF ( p_cd3 IS NOT NULL ) THEN
                                IF ( p_origem3 = 'L' ) THEN
                                    --ENTRADA NAS FILIAIS
                                    get_entradas_filial ( p_proc_instance
                                                        , a_estab_part ( i )
                                                        , p_cd3
                                                        , v_data_inicial
                                                        , v_data_final
                                                        , v_tab_entrada_f
                                                        , v_tabela_saida
                                                        , v_tabela_nf
                                                        , v_tabela_ult_entrada );
                                ELSIF ( p_origem3 = 'C' ) THEN
                                    --ENTRADA NOS CDs
                                    get_entradas_cd ( p_proc_instance
                                                    , a_estab_part ( i )
                                                    , p_cd3
                                                    , v_tab_entrada_c
                                                    , v_tabela_saida
                                                    , v_tabela_nf
                                                    , v_tabela_ult_entrada );
                                END IF;
                            END IF;

                            IF ( p_cd4 IS NOT NULL ) THEN
                                IF ( p_origem4 = 'L' ) THEN
                                    --ENTRADA NAS FILIAIS
                                    get_entradas_filial ( p_proc_instance
                                                        , a_estab_part ( i )
                                                        , p_cd4
                                                        , v_data_inicial
                                                        , v_data_final
                                                        , v_tab_entrada_f
                                                        , v_tabela_saida
                                                        , v_tabela_nf
                                                        , v_tabela_ult_entrada );
                                ELSIF ( p_origem4 = 'C' ) THEN
                                    --ENTRADA NOS CDs
                                    get_entradas_cd ( p_proc_instance
                                                    , a_estab_part ( i )
                                                    , p_cd4
                                                    , v_tab_entrada_c
                                                    , v_tabela_saida
                                                    , v_tabela_nf
                                                    , v_tabela_ult_entrada );
                                END IF;
                            END IF;

                            IF ( p_cd5 IS NOT NULL ) THEN
                                IF ( p_origem5 = 'L' ) THEN
                                    --ENTRADA NAS FILIAIS
                                    get_entradas_filial ( p_proc_instance
                                                        , a_estab_part ( i )
                                                        , p_cd5
                                                        , v_data_inicial
                                                        , v_data_final
                                                        , v_tab_entrada_f
                                                        , v_tabela_saida
                                                        , v_tabela_nf
                                                        , v_tabela_ult_entrada );
                                ELSIF ( p_origem5 = 'C' ) THEN
                                    --ENTRADA NOS CDs
                                    get_entradas_cd ( p_proc_instance
                                                    , a_estab_part ( i )
                                                    , p_cd5
                                                    , v_tab_entrada_c
                                                    , v_tabela_saida
                                                    , v_tabela_nf
                                                    , v_tabela_ult_entrada );
                                END IF;
                            END IF;

                            IF ( p_direta = 'S' ) THEN
                                get_compra_direta ( p_proc_instance
                                                  , a_estab_part ( i )
                                                  , v_data_inicial
                                                  , v_data_final
                                                  , v_tab_entrada_co
                                                  , v_tabela_saida
                                                  , v_tabela_nf
                                                  , v_tabela_ult_entrada );
                            END IF;

                            --SE NAO ACHOU ENTRADA, GRAVAR NA TABELA RESULTADO APENAS A SAIDA
                            get_sem_entrada ( p_proc_instance
                                            , a_estab_part ( i )
                                            , v_data_inicial
                                            , v_data_final
                                            , v_tabela_saida
                                            , v_tabela_ult_entrada );

                            loga ( 'GET_ENTRADAS-FIM-' || a_estab_part ( i )
                                 , FALSE );

                            --EXCLUIR LINHAS DA TABELA FINAL
                            delete_tbl ( a_estab_part ( i )
                                       , v_data_inicial
                                       , v_data_final );
                        END LOOP; --FOR i IN 1..A_ESTABS.COUNT

                        --LOOP PARA CADA FILIAL-FIM--------------------------------------------------------------------------------------

                        --INSERIR DADOS-INI-------------------------------------------------------------------------------------------
                        loga ( 'INSERINDO RESULTADO... - INI' );

                        ---INSERIR RESULTADO
                        v_sql_resultado := 'INSERT /*+APPEND*/ INTO DPSP_EX_BPC_UENTR_JJ ( ';
                        v_sql_resultado := v_sql_resultado || 'SELECT ';
                        v_sql_resultado := v_sql_resultado || 'A.COD_EMPRESA, ';
                        v_sql_resultado := v_sql_resultado || 'A.COD_ESTAB, ';
                        v_sql_resultado := v_sql_resultado || 'A.UF_ESTAB, ';
                        v_sql_resultado := v_sql_resultado || 'A.DOCTO, ';
                        v_sql_resultado := v_sql_resultado || 'A.COD_PRODUTO, ';
                        v_sql_resultado := v_sql_resultado || 'A.NUM_ITEM, ';
                        v_sql_resultado := v_sql_resultado || 'A.DESCR_ITEM, ';
                        v_sql_resultado := v_sql_resultado || 'A.NUM_DOCFIS, ';
                        v_sql_resultado := v_sql_resultado || 'A.DATA_FISCAL, ';
                        v_sql_resultado := v_sql_resultado || 'A.SERIE_DOCFIS, ';
                        v_sql_resultado := v_sql_resultado || 'A.QUANTIDADE, ';
                        v_sql_resultado := v_sql_resultado || 'A.COD_NBM, ';
                        v_sql_resultado := v_sql_resultado || 'A.COD_CFO, ';
                        v_sql_resultado := v_sql_resultado || 'A.GRUPO_PRODUTO, ';
                        v_sql_resultado := v_sql_resultado || 'A.VLR_DESCONTO, ';
                        v_sql_resultado := v_sql_resultado || 'A.VLR_CONTABIL, ';

                        v_sql_resultado := v_sql_resultado || 'A.VLR_ITEM, ';
                        v_sql_resultado := v_sql_resultado || 'A.VLR_OUTRAS, ';

                        v_sql_resultado := v_sql_resultado || 'A.NUM_AUTENTIC_NFE, ';

                        v_sql_resultado := v_sql_resultado || 'A.VLR_BASE_ICMS, ';
                        v_sql_resultado := v_sql_resultado || 'A.VLR_ALIQ_ICMS, ';
                        v_sql_resultado := v_sql_resultado || 'A.VLR_ICMS, ';

                        v_sql_resultado := v_sql_resultado || 'A.CST_PIS, ';
                        v_sql_resultado := v_sql_resultado || 'A.VLR_BASE_PIS   , ';
                        v_sql_resultado := v_sql_resultado || 'A.VLR_ALIQ_PIS   , ';
                        v_sql_resultado := v_sql_resultado || 'A.VLR_PIS        , ';
                        v_sql_resultado := v_sql_resultado || 'A.CST_COFINS     , ';
                        v_sql_resultado := v_sql_resultado || 'A.VLR_BASE_COFINS, ';
                        v_sql_resultado := v_sql_resultado || 'A.VLR_ALIQ_COFINS, ';
                        v_sql_resultado := v_sql_resultado || 'A.VLR_COFINS     , ';
                        ---
                        v_sql_resultado := v_sql_resultado || 'A.COD_ESTAB_E, ';
                        v_sql_resultado := v_sql_resultado || 'A.DATA_FISCAL_E, ';
                        v_sql_resultado := v_sql_resultado || 'A.MOVTO_E_S_E, ';
                        v_sql_resultado := v_sql_resultado || 'A.NORM_DEV_E, ';
                        v_sql_resultado := v_sql_resultado || 'A.IDENT_DOCTO_E, ';
                        v_sql_resultado := v_sql_resultado || 'A.IDENT_FIS_JUR_E, ';
                        v_sql_resultado := v_sql_resultado || 'A.SUB_SERIE_DOCFIS_E, ';
                        v_sql_resultado := v_sql_resultado || 'A.DISCRI_ITEM_E, ';
                        v_sql_resultado := v_sql_resultado || 'A.DATA_EMISSAO_E, ';
                        v_sql_resultado := v_sql_resultado || 'A.NUM_DOCFIS_E, ';
                        v_sql_resultado := v_sql_resultado || 'A.SERIE_DOCFIS_E, ';
                        v_sql_resultado := v_sql_resultado || 'A.NUM_ITEM_E, ';
                        v_sql_resultado := v_sql_resultado || 'A.COD_FIS_JUR_E, ';
                        v_sql_resultado := v_sql_resultado || 'A.CPF_CGC_E, ';
                        v_sql_resultado := v_sql_resultado || 'A.COD_NBM_E, ';
                        v_sql_resultado := v_sql_resultado || 'A.COD_CFO_E, ';
                        v_sql_resultado := v_sql_resultado || 'A.COD_NATUREZA_OP_E, ';
                        v_sql_resultado := v_sql_resultado || 'A.COD_PRODUTO_E, ';
                        v_sql_resultado := v_sql_resultado || 'A.VLR_CONTAB_ITEM_E, ';
                        v_sql_resultado := v_sql_resultado || 'A.QUANTIDADE_E, ';
                        v_sql_resultado := v_sql_resultado || 'A.VLR_UNIT_E, ';

                        v_sql_resultado := v_sql_resultado || 'A.VLR_ITEM_E    , ';
                        v_sql_resultado := v_sql_resultado || 'A.VLR_OUTRAS_E  , ';
                        v_sql_resultado := v_sql_resultado || 'A.VLR_DESCONTO_E, ';

                        v_sql_resultado := v_sql_resultado || 'A.CST_PIS_E        , ';
                        v_sql_resultado := v_sql_resultado || 'A.VLR_BASE_PIS_E   , ';
                        v_sql_resultado := v_sql_resultado || 'A.VLR_ALIQ_PIS_E   , ';
                        v_sql_resultado := v_sql_resultado || 'A.VLR_PIS_E        , ';
                        v_sql_resultado := v_sql_resultado || 'A.CST_COFINS_E     , ';
                        v_sql_resultado := v_sql_resultado || 'A.VLR_BASE_COFINS_E, ';
                        v_sql_resultado := v_sql_resultado || 'A.VLR_ALIQ_COFINS_E, ';
                        v_sql_resultado := v_sql_resultado || 'A.VLR_COFINS_E     , ';

                        v_sql_resultado := v_sql_resultado || 'A.VLR_ICMSS_N_ESCRIT, ';

                        v_sql_resultado := v_sql_resultado || 'A.COD_SITUACAO_B_E, ';
                        v_sql_resultado := v_sql_resultado || 'A.COD_ESTADO_E, ';
                        v_sql_resultado := v_sql_resultado || 'A.NUM_CONTROLE_DOCTO_E, ';
                        v_sql_resultado := v_sql_resultado || 'A.NUM_AUTENTIC_NFE_E, ';
                        v_sql_resultado := v_sql_resultado || 'A.VLR_BASE_ICMS_E, ';
                        v_sql_resultado := v_sql_resultado || 'A.VLR_ICMS_E, ';
                        v_sql_resultado := v_sql_resultado || 'A.VLR_BASE_ICMSS_E, ';
                        v_sql_resultado := v_sql_resultado || 'A.VLR_ICMSS_E, ';
                        ---
                        v_sql_resultado := v_sql_resultado || 'A.BASE_ICMS_UNIT_E, ';
                        v_sql_resultado := v_sql_resultado || 'A.VLR_ICMS_UNIT_E, ';
                        v_sql_resultado := v_sql_resultado || 'A.ALIQ_ICMS_E, ';
                        v_sql_resultado := v_sql_resultado || 'A.BASE_ST_UNIT_E, ';
                        v_sql_resultado := v_sql_resultado || 'A.VLR_ICMS_ST_UNIT_E, ';
                        v_sql_resultado := v_sql_resultado || 'C.ALIQ_ST, ';
                        v_sql_resultado := v_sql_resultado || 'A.VLR_ICMS_ST_UNIT_AUX, ';
                        v_sql_resultado := v_sql_resultado || 'A.STAT_LIBER_CNTR, ';
                        ---
                        v_sql_resultado := v_sql_resultado || ' ''' || lib_parametros.recuperar ( 'USUARIO' ) || ''', ';
                        v_sql_resultado := v_sql_resultado || 'SYSDATE ';
                        ---
                        v_sql_resultado := v_sql_resultado || 'FROM ' || v_tabela_ult_entrada || ' A, ';
                        v_sql_resultado := v_sql_resultado || v_nome_tabela_aliq || ' C ';
                        v_sql_resultado := v_sql_resultado || 'WHERE A.PROC_ID     = ' || p_proc_instance;
                        v_sql_resultado := v_sql_resultado || '  AND A.PROC_ID     = C.PROC_ID (+) ';
                        v_sql_resultado := v_sql_resultado || '  AND A.COD_PRODUTO = C.COD_PRODUTO (+) ';
                        v_sql_resultado := v_sql_resultado || ' ) ';

                        BEGIN
                            EXECUTE IMMEDIATE v_sql_resultado;

                            COMMIT;
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
                                ---
                                raise_application_error ( -20001
                                                        , '!ERRO INSERINDO RESULTADO!' );
                        END;

                        loga ( 'RESULTADO INSERIDO - FIM' );
                        --INSERIR DADOS-FIM-------------------------------------------------------------------------------------------

                        loga ( 'Limpar Tabelas Temporárias '
                             , FALSE );
                        delete_temp_tbl ( p_proc_instance
                                        , v_nome_tabela_aliq
                                        , v_tab_entrada_c
                                        , v_tab_entrada_f
                                        , v_tab_entrada_co
                                        , v_tabela_saida
                                        , v_tabela_nf
                                        , v_tabela_ult_entrada );
                        --
                        loga ( '<< FIM DO PROCESSAMENTO PARCIAL >>'
                             , FALSE );
                    ELSIF p_rel = '2' THEN --ANALITICO
                        FOR est IN 1 .. a_estab_part.COUNT LOOP
                            grava_relatorio ( a_estab_part ( est )
                                            , v_data_inicial
                                            , v_data_final
                                            , est + 1 );
                        END LOOP;
                    END IF;

                    lib_proc.close ( );

                    a_estab_part := a_estabs_t ( );
                END IF;
            END LOOP;

            --DISPONIBILIZAR PERIODO PROCESSADO PARA TRAVA DE REPROCESSAMENTO
            msafi.add_trava_info ( 'EXCLUSAO'
                                 , TO_CHAR ( v_data_inicial
                                           , 'YYYY/MM' ) );

            loga ( '<< FIM DO PROCESSAMENTO TOTAL! >>'
                 , FALSE );
            COMMIT;
        ELSE --(1)
            --SINTETICO
            p_tipo := 9999;
            mproc_id := lib_proc.new ( 'DPSP_EX_PIS_COFINS_635_CPROC' );
            lib_proc.add_tipo ( mproc_id
                              , p_tipo
                              ,    'REL_EXCLUSAO_'
                                || mcod_empresa
                                || '_SINTETICO_'
                                || TO_CHAR ( v_data_inicial
                                           , 'yyyymm' )
                                || '.xls'
                              , 2 );

            grava ( dsp_planilha.header
                  , p_tipo );
            grava ( dsp_planilha.tabela_inicio
                  , p_tipo );
            cabecalho_sintetico ( 'SINTETICO'
                                , p_tipo );

            FOR est IN 1 .. a_estabs.COUNT LOOP
                grava_sintetico ( a_estabs ( est )
                                , v_data_inicial
                                , v_data_final
                                , p_tipo );
            END LOOP;

            grava ( dsp_planilha.tabela_fim
                  , p_tipo );
            lib_proc.close ( );
        END IF; --(1)

        --ENVIAR EMAIL DE SUCESSO----------------------------------------
        envia_email ( mcod_empresa
                    , v_data_inicial
                    , v_data_final
                    , ''
                    , 'S'
                    , v_data_hora_ini );
        -----------------------------------------------------------------

        lib_proc.delete ( mproc_id_o );
        RETURN mproc_id_o;
    EXCEPTION
        WHEN OTHERS THEN
            loga ( 'ERRO - Limpar Tabelas Temporárias'
                 , FALSE );
            --DELETE_TEMP_TBL(P_PROC_INSTANCE, V_NOME_TABELA_ALIQ, V_TAB_ENTRADA_C, V_TAB_ENTRADA_F, V_TAB_ENTRADA_CO, V_TABELA_SAIDA, V_TABELA_NF, V_TABELA_ULT_ENTRADA);
            loga ( 'ERRO - Tabelas Temporárias Limpas'
                 , FALSE );

            loga ( 'SQLERRM: ' || SQLERRM
                 , FALSE );

            lib_proc.add_log ( 'Erro não tratado: ' || dbms_utility.format_error_backtrace
                             , 1 );
            lib_proc.add_log ( 'SQLERRM: ' || SQLERRM
                             , 1 );

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
END dpsp_ex_pis_cofins_635_cproc;
/
SHOW ERRORS;
