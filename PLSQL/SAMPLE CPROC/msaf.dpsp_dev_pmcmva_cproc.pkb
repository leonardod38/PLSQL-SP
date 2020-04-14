Prompt Package Body DPSP_DEV_PMCMVA_CPROC;
--
-- DPSP_DEV_PMCMVA_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_dev_pmcmva_cproc
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
                           , 'Estabelecimento'
                           , --P_COD_ESTAB
                            'VARCHAR2'
                           , 'MULTISELECT'
                           , 'S'
                           , NULL
                           , NULL
                           ,    'SELECT A.COD_ESTAB, A.COD_ESTAB || '' - '' || B.COD_ESTADO || '' - '' || A.CGC || '' - '' || INITCAP(A.BAIRRO) || '' / '' || INITCAP(A.CIDADE) FROM ESTABELECIMENTO A, ESTADO B, MSAFI.DSP_ESTABELECIMENTO C WHERE A.COD_EMPRESA  = '''
                             || mcod_empresa
                             || ''' AND B.IDENT_ESTADO = A.IDENT_ESTADO AND A.COD_EMPRESA = C.COD_EMPRESA AND A.COD_ESTAB = C.COD_ESTAB AND B.COD_ESTADO LIKE :3 AND C.TIPO = ''L'' ORDER BY B.COD_ESTADO, A.COD_ESTAB'
        );


        RETURN pstr;
    END; --FUNCTION PARAMETROS RETURN VARCHAR2 IS

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Relatório de Devolução PMC x MVA';
    END;

    FUNCTION tipo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Relatorio';
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
        RETURN 'Emitir Relatório de Devolução PMC x MVA';
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
        msafi.dsp_control.writelog ( 'INTER'
                                   , p_i_texto );
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
        INSERT /*+APPEND*/
              INTO  msafi.dpsp_msaf_tmp_control
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
            v_txt_email := 'ERRO no Processo Devolução PMC x MVA!';
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
            v_assunto := 'Mastersaf - Relatório de Devolução PMC x MVA ERRO';
        -- NOTIFICA('', 'S', V_ASSUNTO, V_TXT_EMAIL, 'DPSP_DEV_PMCMVA_CPROC');

        ELSE
            v_txt_email := 'Processo de Devolução PMC x MVA finalizado com SUCESSO.';
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
            v_assunto := 'Mastersaf - Relatório de Devolução PMC x MVA Concluído';
        --NOTIFICA('S', '', V_ASSUNTO, V_TXT_EMAIL, 'DPSP_DEV_PMCMVA_CPROC');

        END IF;
    END;

    /******************************************************************************INICIO - INSERE TMP**************************************************************************************/
    PROCEDURE create_tab_devol ( vp_proc_instance IN VARCHAR2
                               , vp_tabela_devol   OUT VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 4000 );
    BEGIN
        vp_tabela_devol := 'DPSP_DEVOL_' || vp_proc_instance;

        v_sql := 'CREATE TABLE ' || vp_tabela_devol || ' ( ';
        v_sql := v_sql || 'VP_PROC_INSTANCE    NUMBER(30), ';
        v_sql := v_sql || 'COD_EMPRESA         VARCHAR2(3), ';
        v_sql := v_sql || 'COD_ESTAB           VARCHAR2(6), ';
        v_sql := v_sql || 'COD_DATA_EMISSAO    DATE, ';
        v_sql := v_sql || 'NUM_DOCFIS          VARCHAR2(12), ';
        v_sql := v_sql || 'NUM_AUTENTIC_NFE    VARCHAR2(80), ';
        v_sql := v_sql || 'NUM_ITEM            NUMBER(5), ';
        v_sql := v_sql || 'COD_FIS_JUR 		   VARCHAR2(14), ';
        v_sql := v_sql || 'RAZAO_SOCIAL        VARCHAR2(70), ';
        v_sql := v_sql || 'CPF_CGC             VARCHAR2(14), ';
        v_sql := v_sql || 'NUM_CONTROLE_DOCTO  VARCHAR2(12), ';
        v_sql := v_sql || 'COD_CFO             VARCHAR2(4), ';
        v_sql := v_sql || 'COD_NATUREZA_OP     VARCHAR2(3), ';
        v_sql := v_sql || 'COD_PRODUTO         VARCHAR2(35), ';
        v_sql := v_sql || 'DESCR_ITEM          VARCHAR2(50), ';
        v_sql := v_sql || 'COD_NBM             VARCHAR2(10), ';
        v_sql := v_sql || 'VLR_CONTAB_ITEM     NUMBER(17,2), ';
        v_sql := v_sql || 'VLR_UNIT			   NUMBER(19,4), ';
        v_sql := v_sql || 'QUANTIDADE          NUMBER(17,6), ';
        v_sql := v_sql || 'VLR_ITEM            NUMBER(17,2), ';
        v_sql := v_sql || 'VLR_OUTRAS          NUMBER(17,2), ';
        v_sql := v_sql || 'VLR_DESCONTO        NUMBER(17,2), ';
        v_sql := v_sql || 'VLR_BASE_ICMS	   NUMBER(17,2), ';
        v_sql := v_sql || 'ALIQ_ICMS		   NUMBER(5,2)) ';
        v_sql := v_sql || 'VLR_ICMS			   NUMBER(17,2), ';
        v_sql := v_sql || 'VLR_ICMS_ISENTA     NUMBER(17,2), ';
        v_sql := v_sql || 'VLR_ICMS_OUTRAS     NUMBER(17,2), ';
        v_sql := v_sql || 'BASE_ICMSS		   NUMBER(17,2), ';
        v_sql := v_sql || 'VLR_ICMSS		   NUMBER(17,2), ';
        v_sql := v_sql || 'COD_ESTADO		   VARCHAR2(2), ';

        EXECUTE IMMEDIATE v_sql;

        save_tmp_control ( vp_proc_instance
                         , vp_tabela_devol );
    END;

    PROCEDURE create_tab_devol_idx ( vp_proc_instance IN NUMBER
                                   , vp_tabela_devol IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 2000 );
        v_qtde_e NUMBER := 0;
    BEGIN
        v_sql := 'CREATE UNIQUE INDEX PK_INTER_E_' || vp_proc_instance || ' ON ' || vp_tabela_devol || ' ';
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || '    PROC_ID             ASC, ';
        v_sql := v_sql || '    COD_EMPRESA         ASC, ';
        v_sql := v_sql || '    COD_ESTAB     	   ASC, ';
        v_sql := v_sql || '    COD_DATA_EMISSAO    ASC, ';
        v_sql := v_sql || '    NUM_DOCFIS          ASC, ';
        v_sql := v_sql || '    NUM_AUTENTIC_NFE    ASC, ';
        v_sql := v_sql || '    NUM_ITEM            ASC, ';
        v_sql := v_sql || '  ) ';

        --  V_SQL := V_SQL || '  PCTFREE     10 ';
        EXECUTE IMMEDIATE v_sql;

        loga ( vp_tabela_devol || ' CRIADA ' || v_qtde_e || ' LINHAS'
             , FALSE );
    END;

    PROCEDURE load_devolucao ( vp_proc_instance IN VARCHAR2
                             , p_cod_estab IN VARCHAR2
                             , p_data_ini IN DATE
                             , p_data_fim IN DATE
                             , vp_tabela_devol IN VARCHAR2
                             , vp_data_hora_ini IN VARCHAR2
                             , p_uf IN VARCHAR2 )
    IS
        --RANGE DE DATAS PARA BUSCAR VENDAS
        v_data_inicial DATE := p_data_ini; -- DATA INICIAL
        v_data_final DATE := p_data_fim; -- DATA FINAL

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
            --CARREGAR INFORMACOES DE DEVOLUÇÃO PMX X MVA
            v_sql := 'INSERT /*+APPEND*/ INTO ' || vp_tabela_devol || ' ( ';
            v_sql := v_sql || ' SELECT /*+ parallel(12)*/ ' || vp_proc_instance || ', ';
            v_sql := v_sql || ' Capa.Cod_Empresa, ';
            v_sql := v_sql || ' Capa.Cod_Estab, ';
            v_sql := v_sql || ' Capa.Data_Emissao, ';
            v_sql := v_sql || ' Capa.Num_Docfis, ';
            v_sql := v_sql || ' Capa.Num_Controle_Docto, ';
            v_sql := v_sql || ' Capa.Num_Autentic_Nfe, ';
            v_sql := v_sql || ' Dest.Cod_Fis_Jur, ';
            v_sql := v_sql || ' A.DATA_FISCAL AS DATA_FISCAL, ';
            v_sql := v_sql || ' Dest.Razao_Social, ';
            v_sql := v_sql || ' Dest.Cpf_Cgc, ';
            v_sql := v_sql || ' Item.Num_Item, ';
            v_sql := v_sql || ' Cfop.Cod_Cfo, ';
            v_sql := v_sql || ' Nat.Cod_Natureza_Op, ';
            v_sql := v_sql || ' Prod.Cod_Produto, ';
            v_sql := v_sql || ' Prod.Descricao, ';
            v_sql := v_sql || ' Nbm.Cod_Nbm, ';
            v_sql := v_sql || ' Item.Vlr_Contab_Item, ';
            v_sql := v_sql || ' Item.Vlr_Unit, ';
            v_sql := v_sql || ' Item.Quantidade, ';
            v_sql := v_sql || ' Item.Vlr_Item, ';
            v_sql := v_sql || ' Item.Vlr_Outras, ';
            v_sql := v_sql || ' Item.Vlr_Desconto, ';
            v_sql := v_sql || ' Nvl((SELECT Itmb.Vlr_Base ';
            v_sql := v_sql || '      FROM X08_Base_Merc Itmb ';
            v_sql := v_sql || '      WHERE Item.Cod_Empresa = Itmb.Cod_Empresa ';
            v_sql := v_sql || '        AND Item.Cod_Estab = Itmb.Cod_Estab ';
            v_sql := v_sql || '        AND Item.Data_Fiscal = Itmb.Data_Fiscal ';
            v_sql := v_sql || '        AND Item.Movto_e_s = Itmb.Movto_e_s ';
            v_sql := v_sql || '        AND Item.Norm_Dev = Itmb.Norm_Dev ';
            v_sql := v_sql || '        AND Item.Ident_Docto = Itmb.Ident_Docto ';
            v_sql := v_sql || '        AND Item.Ident_Fis_Jur = Itmb.Ident_Fis_Jur ';
            v_sql := v_sql || '        AND Item.Num_Docfis = Itmb.Num_Docfis ';
            v_sql := v_sql || '        AND Item.Serie_Docfis = Itmb.Serie_Docfis ';
            v_sql := v_sql || '        AND Item.Sub_Serie_Docfis = Itmb.Sub_Serie_Docfis ';
            v_sql := v_sql || '        AND Item.Discri_Item = Itmb.Discri_Item ';
            v_sql := v_sql || '        AND AND Itmb.Cod_Tributo = ''ICMS'' ';
            v_sql := v_sql || '        AND Itmb.Cod_Tributacao = ''1''),0) AS Base_Icms_Trib, ';
            v_sql := v_sql || ' Nvl((SELECT Aliq_Tributo ';
            v_sql := v_sql || '      FROM X08_Trib_Merc Itmt ';
            v_sql := v_sql || '      WHERE Item.Cod_Empresa = Itmt.Cod_Empresa';
            v_sql := v_sql || '        AND Item.Cod_Estab = Itmt.Cod_Estab';
            v_sql := v_sql || '        AND Item.Data_Fiscal = Itmt.Data_Fiscal';
            v_sql := v_sql || '        AND Item.Movto_e_s = Itmt.Movto_e_s';
            v_sql := v_sql || '        AND Item.Norm_Dev = Itmt.Norm_Dev';
            v_sql := v_sql || '        AND Item.Ident_Docto = Itmt.Ident_Docto';
            v_sql := v_sql || '        AND Item.Ident_Fis_Jur = Itmt.Ident_Fis_Jur';
            v_sql := v_sql || '        AND Item.Num_Docfis = Itmt.Num_Docfis ';
            v_sql := v_sql || '        AND Item.Serie_Docfis = Itmt.Serie_Docfis ';
            v_sql := v_sql || '        AND Item.Sub_Serie_Docfis = Itmt.Sub_Serie_Docfis ';
            v_sql := v_sql || '        AND Item.Discri_Item = Itmt.Discri_Item ';
            v_sql := v_sql || '        AND Itmt.Cod_Tributo = ''ICMS''),0) AS Aliq_Icms, ';
            v_sql := v_sql || ' Nvl((SELECT Vlr_Tributo ';
            v_sql := v_sql || '      FROM X08_Trib_Merc Itmt ';
            v_sql := v_sql || '      WHERE Item.Cod_Empresa = Itmt.Cod_Empresa';
            v_sql := v_sql || '        AND Item.Cod_Estab = Itmt.Cod_Estab';
            v_sql := v_sql || '        AND Item.Data_Fiscal = Itmt.Data_Fiscal';
            v_sql := v_sql || '        AND Item.Movto_e_s = Itmt.Movto_e_s';
            v_sql := v_sql || '        AND Item.Norm_Dev = Itmt.Norm_Dev';
            v_sql := v_sql || '        AND Item.Ident_Docto = Itmt.Ident_Docto';
            v_sql := v_sql || '        AND Item.Ident_Fis_Jur = Itmt.Ident_Fis_Jur';
            v_sql := v_sql || '        AND Item.Num_Docfis = Itmt.Num_Docfis ';
            v_sql := v_sql || '        AND Item.Serie_Docfis = Itmt.Serie_Docfis ';
            v_sql := v_sql || '        AND Item.Sub_Serie_Docfis = Itmt.Sub_Serie_Docfis ';
            v_sql := v_sql || '        AND Item.Discri_Item = Itmt.Discri_Item ';
            v_sql := v_sql || '        AND Itmt.Cod_Tributo = ''ICMS''),0) AS Vlr_Icms, ';
            v_sql := v_sql || ' Nvl((SELECT Itmb.Vlr_Base ';
            v_sql := v_sql || '      FROM X08_Base_Merc Itmb ';
            v_sql := v_sql || '      WHERE Item.Cod_Empresa = Itmb.Cod_Empresa';
            v_sql := v_sql || '        AND Item.Cod_Estab = Itmb.Cod_Estab';
            v_sql := v_sql || '        AND Item.Data_Fiscal = Itmb.Data_Fiscal';
            v_sql := v_sql || '        AND Item.Movto_e_s = Itmb.Movto_e_s';
            v_sql := v_sql || '        AND Item.Norm_Dev = Itmb.Norm_Dev';
            v_sql := v_sql || '        AND Item.Ident_Docto = Itmb.Ident_Docto';
            v_sql := v_sql || '        AND Item.Ident_Fis_Jur = Itmb.Ident_Fis_Jur';
            v_sql := v_sql || '        AND Item.Num_Docfis = Itmb.Num_Docfis ';
            v_sql := v_sql || '        AND Item.Serie_Docfis = Itmb.Serie_Docfis ';
            v_sql := v_sql || '        AND Item.Sub_Serie_Docfis = Itmb.Sub_Serie_Docfis ';
            v_sql := v_sql || '        AND Item.Discri_Item = Itmb.Discri_Item ';
            v_sql := v_sql || '        AND Itmb.Cod_Tributo = ''ICMS'' ';
            v_sql := v_sql || '        AND Itmb.Cod_Tributacao = ''2''),0) AS Base_Icms_Isenta, ';
            v_sql := v_sql || ' Nvl((SELECT Itmb.Vlr_Base ';
            v_sql := v_sql || '      FROM X08_Base_Merc Itmb ';
            v_sql := v_sql || '      WHERE Item.Cod_Empresa = Itmb.Cod_Empresa';
            v_sql := v_sql || '        AND Item.Cod_Estab = Itmb.Cod_Estab';
            v_sql := v_sql || '        AND Item.Data_Fiscal = Itmb.Data_Fiscal';
            v_sql := v_sql || '        AND Item.Movto_e_s = Itmb.Movto_e_s';
            v_sql := v_sql || '        AND Item.Norm_Dev = Itmb.Norm_Dev';
            v_sql := v_sql || '        AND Item.Ident_Docto = Itmb.Ident_Docto';
            v_sql := v_sql || '        AND Item.Ident_Fis_Jur = Itmb.Ident_Fis_Jur';
            v_sql := v_sql || '        AND Item.Num_Docfis = Itmb.Num_Docfis ';
            v_sql := v_sql || '        AND Item.Serie_Docfis = Itmb.Serie_Docfis ';
            v_sql := v_sql || '        AND Item.Sub_Serie_Docfis = Itmb.Sub_Serie_Docfis ';
            v_sql := v_sql || '        AND Item.Discri_Item = Itmb.Discri_Item ';
            v_sql := v_sql || '        AND Itmb.Cod_Tributo = ''ICMS'' ';
            v_sql := v_sql || '        AND Itmb.Cod_Tributacao = ''3''),0) AS Base_Icms_Outras, ';
            v_sql := v_sql || '  Nvl((SELECT Itmb.Vlr_Base ';
            v_sql := v_sql || '      FROM X08_Base_Merc Itmb ';
            v_sql := v_sql || '      WHERE Item.Cod_Empresa = Itmb.Cod_Empresa';
            v_sql := v_sql || '        AND Item.Cod_Estab = Itmb.Cod_Estab';
            v_sql := v_sql || '        AND Item.Data_Fiscal = Itmb.Data_Fiscal';
            v_sql := v_sql || '        AND Item.Movto_e_s = Itmb.Movto_e_s';
            v_sql := v_sql || '        AND Item.Norm_Dev = Itmb.Norm_Dev';
            v_sql := v_sql || '        AND Item.Ident_Docto = Itmb.Ident_Docto';
            v_sql := v_sql || '        AND Item.Ident_Fis_Jur = Itmb.Ident_Fis_Jur';
            v_sql := v_sql || '        AND Item.Num_Docfis = Itmb.Num_Docfis ';
            v_sql := v_sql || '        AND Item.Serie_Docfis = Itmb.Serie_Docfis ';
            v_sql := v_sql || '        AND Item.Sub_Serie_Docfis = Itmb.Sub_Serie_Docfis ';
            v_sql := v_sql || '        AND Item.Discri_Item = Itmb.Discri_Item ';
            v_sql := v_sql || '        AND Itmb.Cod_Tributo = ''ICMS-S''),0) AS Base_Icmss, ';
            v_sql := v_sql || '  Nvl((SELECT Vlr_Tributo ';
            v_sql := v_sql || '      FROM X08_Trib_Merc Itmt ';
            v_sql := v_sql || '      WHERE Item.Cod_Empresa = Itmt.Cod_Empresa';
            v_sql := v_sql || '        AND Item.Cod_Estab = Itmt.Cod_Estab';
            v_sql := v_sql || '        AND Item.Data_Fiscal = Itmt.Data_Fiscal';
            v_sql := v_sql || '        AND Item.Movto_e_s = Itmt.Movto_e_s';
            v_sql := v_sql || '        AND Item.Norm_Dev = Itmt.Norm_Dev';
            v_sql := v_sql || '        AND Item.Ident_Docto = Itmt.Ident_Docto';
            v_sql := v_sql || '        AND Item.Ident_Fis_Jur = Itmt.Ident_Fis_Jur';
            v_sql := v_sql || '        AND Item.Num_Docfis = Itmt.Num_Docfis ';
            v_sql := v_sql || '        AND Item.Serie_Docfis = Itmt.Serie_Docfis ';
            v_sql := v_sql || '        AND Item.Sub_Serie_Docfis = Itmt.Sub_Serie_Docfis';
            v_sql := v_sql || '        AND Item.Discri_Item = Itmt.Discri_Item ';
            v_sql := v_sql || '        AND Itmt.Cod_Tributo = ''ICMS-S''),0) AS Vlr_Icmss, ';
            v_sql := v_sql || ' est.COD_ESTADO ';

            v_sql := v_sql || '  FROM X08_Itens_Merc Item ';
            v_sql := v_sql || '      INNER JOIN X07_Docto_Fiscal Capa ';
            v_sql := v_sql || '      ON Capa.Cod_Empresa = Item.Cod_Empresa ';
            v_sql := v_sql || '      AND Capa.Cod_Estab = Item.Cod_Estab ';
            v_sql := v_sql || '      AND Capa.Data_Fiscal = Item.Data_Fiscal ';
            v_sql := v_sql || '      AND Capa.Movto_e_s = Item.Movto_e_s';
            v_sql := v_sql || '      AND Capa.Norm_Dev = Item.Norm_Dev ';
            v_sql := v_sql || '      AND Capa.Ident_Docto = Item.Ident_Docto ';
            v_sql := v_sql || '      AND Capa.Ident_Fis_Jur = Item.Ident_Fis_Jur';
            v_sql := v_sql || '      AND Capa.Num_Docfis = Item.Num_Docfis';
            v_sql := v_sql || '      AND Capa.Serie_Docfis = Item.Serie_Docfis';
            v_sql := v_sql || '      AND Capa.Sub_Serie_Docfis = Item.Sub_Serie_Docfis';
            v_sql := v_sql || '  INNER JOIN X2012_Cod_Fiscal Cfop';
            v_sql := v_sql || '      ON Item.Ident_Cfo = Cfop.Ident_Cfo';
            v_sql := v_sql || '  INNER JOIN X2013_Produto Prod';
            v_sql := v_sql || '      ON Item.Ident_Produto = Prod.Ident_Produto';
            v_sql := v_sql || '  INNER JOIN X2013_Produto Prod';
            v_sql := v_sql || '      ON Item.Ident_Produto = Prod.Ident_Produto';
            v_sql := v_sql || '  INNER JOIN X04_Pessoa_Fis_Jur Dest';
            v_sql := v_sql || '      ON Dest.Ident_Fis_Jur = Capa.Ident_Fis_Jur';
            v_sql := v_sql || '  LEFT JOIN X2006_Natureza_Op Nat';
            v_sql := v_sql || '      ON Nat.Ident_Natureza_Op = Item.Ident_Natureza_Op';
            v_sql := v_sql || '  INNER JOIN X2005_Tipo_Docto Dcto';
            v_sql := v_sql || '      ON Dcto.Ident_Docto = Capa.Ident_Docto';
            v_sql := v_sql || '  INNER JOIN Y2026_Sit_Trb_Uf_b Sitb';
            v_sql := v_sql || '      ON Item.Ident_Situacao_b = Sitb.Ident_Situacao_b';
            v_sql := v_sql || '  INNER JOIN MSAFI.DSP_ESTABELECIMENTO est';
            v_sql := v_sql || '      ON  Capa.Cod_Estab = est.Cod_Estab';
            v_sql := v_sql || '  LEFT JOIN X2043_Cod_Nbm Nbm';
            v_sql := v_sql || '      ON Nbm.Ident_Nbm = Item.Ident_Nbm';
            v_sql := v_sql || '  WHERE Capa.Cod_Empresa = Msafi.Dpsp.Empresa';
            v_sql :=
                v_sql || '   AND Capa.Cod_Estab IN (SELECT Cod_Estab FROM Dsp_Estabelecimento_v WHERE Tipo = ''L'') ';
            v_sql := v_sql || '   AND Capa.Movto_e_s = ''1'' ';
            v_sql := v_sql || '   AND Capa.Situacao <> ''S'' ';
            v_sql := v_sql || '   AND Capa.Data_Fiscal = TO_DATE(''' || cd.data_normal || ''',''DD/MM/YYYY'') ';
            v_sql := v_sql || '   AND Cfop.Cod_Cfo = ' || p_cod_estab || ' ';
            v_sql := v_sql || '   AND est.cod_estado = ' || p_uf || ' ';


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

        loga ( 'LOAD_SAIDAS-FIM-' || p_cod_estab
             , FALSE );
    END;

    PROCEDURE create_tab_saida_idx ( vp_proc_instance IN VARCHAR2
                                   , vp_tabela_devol IN VARCHAR2
                                   , vp_count_saida   OUT NUMBER
                                   , vp_tabela_devol_s   OUT VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 1000 );
    BEGIN
        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_tabela_devol );
    END;

    /******************************************************************************FIM - INSERE TMP*****************************************************************************************/

    /******************************************************************************INICIO - INSERE1 TMP**************************************************************************************/
    PROCEDURE create_tab_final ( vp_proc_instance IN NUMBER
                               , p_cod_estab IN VARCHAR2
                               , vp_tabela_devol IN VARCHAR2
                               , dpsp_msaf_dev_pmc_mva   OUT VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 2000 );
    BEGIN
        ---CRIAR TEMP DE DEVOLUÇÃO ANALITICO
        dpsp_msaf_dev_pmc_mva := 'DPSP_MSAF_DEV_PMC_MVA' || vp_proc_instance;

        v_sql := 'CREATE TABLE ' || dpsp_msaf_dev_pmc_mva || ' ( ';
        v_sql := v_sql || 'VP_PROC_INSTANCE    NUMBER(30), ';
        v_sql := v_sql || 'COD_EMPRESA         VARCHAR2(3), ';
        v_sql := v_sql || 'COD_ESTAB           VARCHAR2(6), ';
        v_sql := v_sql || 'COD_DATA_EMISSAO    DATE, ';
        v_sql := v_sql || 'NUM_DOCFIS          VARCHAR2(12), ';
        v_sql := v_sql || 'NUM_AUTENTIC_NFE    VARCHAR2(80), ';
        v_sql := v_sql || 'NUM_ITEM            NUMBER(5), ';
        v_sql := v_sql || 'COD_FIS_JUR 		   VARCHAR2(14), ';
        v_sql := v_sql || 'RAZAO_SOCIAL        VARCHAR2(70), ';
        v_sql := v_sql || 'CPF_CGC             VARCHAR2(14), ';
        v_sql := v_sql || 'NUM_CONTROLE_DOCTO  VARCHAR2(12), ';
        v_sql := v_sql || 'COD_CFO             VARCHAR2(4), ';
        v_sql := v_sql || 'COD_NATUREZA_OP     VARCHAR2(3), ';
        v_sql := v_sql || 'COD_PRODUTO         VARCHAR2(35), ';
        v_sql := v_sql || 'COD_ESTADO          VARCHAR2(2), ';
        v_sql := v_sql || 'DESCR_ITEM          VARCHAR2(50), ';
        v_sql := v_sql || 'COD_NBM             VARCHAR2(10), ';
        v_sql := v_sql || 'VLR_CONTAB_ITEM     NUMBER(17,2), ';
        v_sql := v_sql || 'VLR_UNIT			   NUMBER(19,4), ';
        v_sql := v_sql || 'QUANTIDADE          NUMBER(17,6), ';
        v_sql := v_sql || 'VLR_ITEM            NUMBER(17,2), ';
        v_sql := v_sql || 'VLR_OUTRAS          NUMBER(17,2), ';
        v_sql := v_sql || 'VLR_DESCONTO        NUMBER(17,2), ';
        v_sql := v_sql || 'VLR_BASE_ICMS	   NUMBER(17,2), ';
        v_sql := v_sql || 'ALIQ_ICMS		   NUMBER(5,2)) ';
        v_sql := v_sql || 'VLR_ICMS			   NUMBER(17,2), ';
        v_sql := v_sql || 'VLR_ICMS_ISENTA     NUMBER(17,2), ';
        v_sql := v_sql || 'VLR_ICMS_OUTRAS     NUMBER(17,2), ';
        v_sql := v_sql || 'BASE_ICMSS		   NUMBER(17,2), ';
        v_sql := v_sql || 'VLR_ICMSS		   NUMBER(17,2), ';
        v_sql := v_sql || 'DATA_FINAL_S        DATE, ';
        v_sql := v_sql || 'NUM_ITEM_S		   NUMBER(19,2), ';
        v_sql := v_sql || 'NUM_AUTENTIC_NFE_S  VARCHAR2(80), ';
        v_sql := v_sql || 'COD_CFO_S		   VARCHAR2(14), ';
        v_sql := v_sql || 'VLR_CONTABIL_S	   NUMBER(19,2), ';
        v_sql := v_sql || 'QUANTIDADE   	   NUMBER(30), ';
        v_sql := v_sql || 'VLR_DIF_QTDE   	   NUMBER(19,2), ';
        v_sql := v_sql || 'CALC        	       NUMBER(19,2), ';


        EXECUTE IMMEDIATE v_sql;

        save_tmp_control ( vp_proc_instance
                         , dpsp_msaf_dev_pmc_mva );
    END;

    PROCEDURE create_tab_entrada_cd_idx ( vp_proc_instance IN NUMBER
                                        , dpsp_msaf_dev_pmc_mva IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 1000 );
        v_qtde_e NUMBER := 0;
    BEGIN
        v_sql := 'CREATE UNIQUE INDEX PK_INTER_E_' || vp_proc_instance || ' ON ' || dpsp_msaf_dev_pmc_mva || ' ';
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || '    VP_PROC_INSTANCE    ASC, ';
        v_sql := v_sql || '    COD_EMPRESA         ASC, ';
        v_sql := v_sql || '    COD_ESTAB     	   ASC, ';
        v_sql := v_sql || '    COD_DATA_EMISSAO    ASC, ';
        v_sql := v_sql || '    NUM_DOCFIS          ASC, ';
        v_sql := v_sql || '    NUM_AUTENTIC_NFE    ASC, ';
        v_sql := v_sql || '    NUM_ITEM            ASC, ';
        v_sql := v_sql || '  ) ';

        EXECUTE IMMEDIATE v_sql;


        dbms_stats.gather_table_stats ( 'MSAF'
                                      , dpsp_msaf_dev_pmc_mva );
    END;

    PROCEDURE load_saidas ( vp_proc_instance IN VARCHAR2
                          , vp_cod_estab IN VARCHAR2
                          , vp_data_ini IN DATE
                          , vp_data_fim IN DATE
                          , dpsp_msaf_dev_pmc_mva IN VARCHAR2
                          , vp_tabela_devol IN VARCHAR2
                          , vp_data_hora_ini IN VARCHAR2
                          , vp_count_saida   OUT NUMBER )
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
        v_sql := 'SELECT VP_PROC_INSTANCE, ';
        v_sql := v_sql || 'COD_EMPRESA,';
        v_sql := v_sql || 'COD_ESTAB,';
        v_sql := v_sql || 'COD_DATA_EMISSAO,';
        v_sql := v_sql || 'NUM_DOCFIS, ';
        v_sql := v_sql || 'NUM_AUTENTIC_NFE, ';
        v_sql := v_sql || 'NUM_ITEM, ';
        v_sql := v_sql || 'COD_FIS_JUR, ';
        v_sql := v_sql || 'RAZAO_SOCIAL, ';
        v_sql := v_sql || 'CPF_CGC, ';
        v_sql := v_sql || 'NUM_CONTROLE_DOCTO, ';
        v_sql := v_sql || 'COD_CFO, ';
        v_sql := v_sql || 'COD_NATUREZA_OP, ';
        v_sql := v_sql || 'COD_PRODUTO, ';
        v_sql := v_sql || 'COD_ESTADO, ';
        v_sql := v_sql || 'DESCR_ITEM, ';
        v_sql := v_sql || 'COD_NBM, ';
        v_sql := v_sql || 'VLR_CONTAB_ITEM, ';
        v_sql := v_sql || 'VLR_UNIT, ';
        v_sql := v_sql || 'VLR_ITEM, ';
        v_sql := v_sql || 'VLR_OUTRAS, ';
        v_sql := v_sql || 'VLR_DESCONTO, ';
        v_sql := v_sql || 'VLR_BASE_ICMS, ';
        v_sql := v_sql || 'ALIQ_ICMS, ';
        v_sql := v_sql || 'VLR_ICMS, ';
        v_sql := v_sql || 'VLR_ICMS_ISENTA, ';
        v_sql := v_sql || 'VLR_ICMS_OUTRAS, ';
        v_sql := v_sql || 'BASE_ICMSS, ';
        v_sql := v_sql || 'VLR_ICMSS ';
        v_sql := v_sql || 'FROM ' || vp_tabela_devol || ' ';
        vp_count_saida := 0;

        EXECUTE IMMEDIATE v_sql            INTO vp_count_saida;

        loga ( vp_tabela_devol || ' CRIADA ' || vp_count_saida || ' LINHAS'
             , FALSE );


        FOR cd IN c_data_saida ( v_data_inicial
                               , v_data_final ) LOOP
            --CARREGAR TEMP DE DEVOLUÇÃO ANALITICO
            v_sql := 'INSERT /*+APPEND*/ INTO ' || dpsp_msaf_dev_pmc_mva || ' ( ';
            v_sql := v_sql || ' SELECT * ';
            v_sql := v_sql || ' FROM (SELECT /*+ PARALLEL(24)*/ ';
            v_sql := v_sql || ' d.*, ';
            v_sql := v_sql || ' Pm.Num_Docfis Num_Docfis_s, ';
            v_sql := v_sql || ' Pm.Data_Fiscal Data_Fiscal_s, ';
            v_sql := v_sql || ' Pm.Num_Item Num_Item_s, ';
            v_sql := v_sql || ' Pm.Num_Autentic_Nfe Num_Autentic_Nfe_s, ';
            v_sql := v_sql || ' Pm.Cod_Cfo Cod_Cfo_s, ';
            v_sql := v_sql || ' Pm.Vlr_Contabil Vlr_Contabil_s, ';
            v_sql := v_sql || ' Pm.Quantidade Quantidade_s, ';
            v_sql := v_sql || ' Pm.Vlr_Dif_Qtde Vlr_Dif_Qtde_s, ';
            v_sql := v_sql || ' CASE ';
            v_sql := v_sql || ' WHEN Pm.Vlr_Dif_Qtde > 0 THEN ';
            v_sql := v_sql || ' Round(d.Quantidade * (Pm.Vlr_Dif_Qtde / Pm.Quantidade), 2) ';
            v_sql := v_sql || ' ELSE ';
            v_sql := v_sql || ' 0 ';
            v_sql := v_sql || ' END Calc, ';
            v_sql := v_sql || ' Rank() Over(PARTITION BY Pm.Cod_Empresa, Pm.Cod_Estab, Pm.Cod_Produto ';
            v_sql :=
                   v_sql
                || ' ORDER BY Pm.Cod_Empresa, Pm.Cod_Estab, Pm.Num_Docfis, Pm.Data_Fiscal DESC, Pm.Cod_Produto, Pm.Num_Item) Mrank ';
            v_sql := v_sql || ' FROM' || vp_tabela_devol || ' d ';
            v_sql := v_sql || ' LEFT JOIN Msafi.Dpsp_Msaf_Pmc_Mva Pm ';
            v_sql := v_sql || ' ON Pm.Cod_Empresa = d.Cod_Empresa ';
            v_sql := v_sql || ' AND Pm.Cod_Estab = d.Cod_Estab ';
            v_sql := v_sql || ' AND Pm.Cod_Produto = d.Cod_Produto ';
            v_sql := v_sql || ' AND Pm.Data_Fiscal <= d.Data_Emissao ';
            v_sql := v_sql || ' WHERE d.Cod_Empresa = Msafi.Dpsp.Empresa ';
            v_sql := v_sql || ' AND d.Data_Emissao = TO_DATE(''' || cd.data_normal || ''',''DD/MM/YYYY'') ';
            v_sql := v_sql || ' WHERE Mrank = 1 ';
            v_sql := v_sql || ' ORDER BY VP_PROC_INSTANCE, ';
            v_sql := v_sql || ' COD_EMPRESA, ';
            v_sql := v_sql || ' Cod_Produto, ';
            v_sql := v_sql || ' 3 ';


            BEGIN
                EXECUTE IMMEDIATE v_sql;

                COMMIT;

                save_tmp_control ( vp_proc_instance
                                 , dpsp_msaf_dev_pmc_mva );
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

    /**********************************************************************************FIM - INSERE TMP*****************************************************************************************/
    /*******************************************************************************INICIO - GERA EXCEL SINTÉTICO*******************************************************************************/

    PROCEDURE create_tab_sintetic ( vp_proc_instance IN VARCHAR2
                                  , dpsp_tbl_sintetic   OUT VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 10000 );
    BEGIN
        v_sql := 'CREATE TABLE ' || dpsp_tbl_sintetic || ' ( ';
        v_sql := v_sql || 'PERIODO             DATE, ';
        v_sql := v_sql || 'COD_ESTAB           VARCHAR2(6), ';
        v_sql := v_sql || 'SOMA_CALC           NUMBER(17,2), ';
        v_sql := v_sql || 'VP_PROC_INSTANCE    NUMBER(30), ';
        v_sql := v_sql || 'COD_EMPRESA         VARCHAR2(3), ';
        v_sql := v_sql || 'COD_ESTAB2           VARCHAR2(6), ';
        v_sql := v_sql || 'COD_DATA_EMISSAO    DATE, ';
        v_sql := v_sql || 'NUM_DOCFIS          VARCHAR2(12), ';
        v_sql := v_sql || 'NUM_AUTENTIC_NFE    VARCHAR2(80), ';
        v_sql := v_sql || 'NUM_ITEM            NUMBER(5), ';
        v_sql := v_sql || 'COD_FIS_JUR 		   VARCHAR2(14), ';
        v_sql := v_sql || 'RAZAO_SOCIAL        VARCHAR2(70), ';
        v_sql := v_sql || 'CPF_CGC             VARCHAR2(14), ';
        v_sql := v_sql || 'NUM_CONTROLE_DOCTO  VARCHAR2(12), ';
        v_sql := v_sql || 'COD_CFO             VARCHAR2(4), ';
        v_sql := v_sql || 'COD_NATUREZA_OP     VARCHAR2(3), ';
        v_sql := v_sql || 'COD_PRODUTO         VARCHAR2(35), ';
        v_sql := v_sql || 'COD_ESTADO          VARCHAR2(2), ';
        v_sql := v_sql || 'DESCR_ITEM          VARCHAR2(50), ';
        v_sql := v_sql || 'COD_NBM             VARCHAR2(10), ';
        v_sql := v_sql || 'VLR_CONTAB_ITEM     NUMBER(17,2), ';
        v_sql := v_sql || 'VLR_UNIT			   NUMBER(19,4), ';
        v_sql := v_sql || 'QUANTIDADE          NUMBER(17,6), ';
        v_sql := v_sql || 'VLR_ITEM            NUMBER(17,2), ';
        v_sql := v_sql || 'VLR_OUTRAS          NUMBER(17,2), ';
        v_sql := v_sql || 'VLR_DESCONTO        NUMBER(17,2), ';
        v_sql := v_sql || 'VLR_BASE_ICMS	   NUMBER(17,2), ';
        v_sql := v_sql || 'ALIQ_ICMS		   NUMBER(5,2)), ';
        v_sql := v_sql || 'VLR_ICMS			   NUMBER(17,2), ';
        v_sql := v_sql || 'VLR_ICMS_ISENTA     NUMBER(17,2), ';
        v_sql := v_sql || 'VLR_ICMS_OUTRAS     NUMBER(17,2), ';
        v_sql := v_sql || 'BASE_ICMSS		   NUMBER(17,2), ';
        v_sql := v_sql || 'VLR_ICMSS		   NUMBER(17,2), ';
        v_sql := v_sql || 'DATA_FINAL_S		   DATE, ';
        v_sql := v_sql || 'NUM_ITEM_S		   NUMBER(17,2), ';
        v_sql := v_sql || 'NUM_AUTENTIC_NFE_S  NUMBER(17,2), ';
        v_sql := v_sql || 'COD_CFO_S		   NUMBER(17,2), ';
        v_sql := v_sql || 'VLR_CONTABIL_S	   NUMBER(17,2), ';
        v_sql := v_sql || 'QUANTIDADE		   NUMBER(17,2), ';
        v_sql := v_sql || 'VLR_DIF_QTDE		   NUMBER(17,2), ';
        v_sql := v_sql || 'CALC     		   NUMBER(17,2) ';

        EXECUTE IMMEDIATE v_sql;

        save_tmp_control ( vp_proc_instance
                         , dpsp_tbl_sintetic );
    END;



    PROCEDURE create_tab_saida_idx ( vp_proc_instance IN VARCHAR2
                                   , dpsp_tbl_sintetic IN VARCHAR2
                                   , vp_count_saida   OUT NUMBER
                                   , vp_tabela_saida_s   OUT VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 1000 );
    BEGIN
        v_sql := 'CREATE UNIQUE INDEX PK_INTERS_' || vp_proc_instance || ' ON ' || dpsp_tbl_sintetic || ' ';
        v_sql := v_sql || '( ';
        v_sql := v_sql || '  PERIODO              ASC, ';
        v_sql := v_sql || '  COD_ESTAB            ASC, ';
        v_sql := v_sql || '  SOMA_CALC            ASC, ';
        v_sql := v_sql || '  VP_PROC_INSTANCE     ASC, ';
        v_sql := v_sql || '  COD_EMPRESA          ASC, ';
        v_sql := v_sql || '  COD_ESTAB2            ASC, ';
        v_sql := v_sql || '  COD_DATA_EMISSAO     ASC, ';
        v_sql := v_sql || '  NUM_DOCFIS           ASC, ';
        v_sql := v_sql || '  NUM_AUTENTIC_NFE     ASC, ';
        v_sql := v_sql || '  NUM_ITEM             ASC, ';
        v_sql := v_sql || '  COD_FIS_JUR          ASC, ';
        v_sql := v_sql || '  RAZAO_SOCIAL         ASC, ';
        v_sql := v_sql || '  CPF_CGC              ASC ';
        v_sql := v_sql || ') ';
        v_sql := v_sql || 'PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;
    END;

    PROCEDURE load_sintetico ( vp_proc_instance IN VARCHAR
                             , p_cod_estab IN VARCHAR2
                             , v_data_inicial IN DATE
                             , v_data_final IN DATE
                             , dpsp_tbl_sintetic IN VARCHAR2
                             , vp_count_saida IN VARCHAR2
                             , dpsp_msaf_dev_pmc_mva IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 1000 );
        v_text01 VARCHAR2 ( 1000 );
        v_class VARCHAR2 ( 1 ) := 'a';
        c_sintetic SYS_REFCURSOR;

        TYPE cur_tab_sintetic IS RECORD
        (
            periodo DATE
          , cod_estab VARCHAR2 ( 6 )
          , soma_calc NUMBER ( 17, 2 )
          , vp_proc_instance NUMBER ( 30 )
          , cod_empresa VARCHAR2 ( 3 )
          , cod_estab2 VARCHAR2 ( 6 )
          , cod_data_emissao DATE
          , num_docfis VARCHAR2 ( 12 )
          , num_autentic_nfe VARCHAR2 ( 80 )
          , num_item NUMBER ( 5 )
          , cod_fis_jur VARCHAR2 ( 14 )
          , razao_social VARCHAR2 ( 70 )
          , cpf_cgc VARCHAR2 ( 14 )
          , num_controle_docto VARCHAR2 ( 12 )
          , cod_cfo VARCHAR2 ( 4 )
          , cod_natureza_op VARCHAR2 ( 3 )
          , cod_produto VARCHAR2 ( 35 )
          , cod_estado VARCHAR2 ( 2 )
          , descr_item VARCHAR2 ( 50 )
          , cod_nbm VARCHAR2 ( 10 )
          , vlr_contab_item NUMBER ( 17, 2 )
          , vlr_unit NUMBER ( 19, 4 )
          , quantidade NUMBER ( 17, 6 )
          , vlr_item NUMBER ( 17, 2 )
          , vlr_outras NUMBER ( 17, 2 )
          , vlr_desconto NUMBER ( 17, 2 )
          , vlr_base_icms NUMBER ( 17, 2 )
          , aliq_icms NUMBER ( 5, 2 )
          , vlr_icms NUMBER ( 17, 2 )
          , vlr_icms_isenta NUMBER ( 17, 2 )
          , vlr_icms_outras NUMBER ( 17, 2 )
          , base_icmss NUMBER ( 17, 2 )
          , vlr_icmss NUMBER ( 17, 2 )
          , data_final_s DATE
          , num_item_s NUMBER ( 17, 2 )
          , num_autentic_nfe_s NUMBER ( 17, 2 )
          , cod_cfo_s NUMBER ( 17, 2 )
          , vlr_contabil_s NUMBER ( 17, 2 )
          , quantidade2 NUMBER ( 17, 2 )
          , vlr_dif_qtde NUMBER ( 17, 2 )
          , calc NUMBER ( 17, 2 )
        );


        TYPE c_tab_sintetic IS TABLE OF cur_tab_sintetic;

        tab_e c_tab_sintetic;
    BEGIN
        v_sql := 'INSERT /*+APPEND*/ INTO ' || dpsp_tbl_sintetic || ' ( ';
        v_sql := v_sql || 'SELECT To_Char(x.Data_Emissao, ''yyyymm'') Periodo,';
        v_sql := v_sql || ' X.Cod_Estab, ';
        v_sql := v_sql || ' SUM(x.Calc) Soma_Calc, ';
        v_sql := v_sql || ' FROM (SELECT /*+ PARALLEL(24)*/,';
        v_sql := v_sql || ' d.*,';
        v_sql := v_sql || ' Pm.Num_Docfis Num_Docfis_s,';
        v_sql := v_sql || ' Pm.Data_Fiscal Data_Fiscal_s,';
        v_sql := v_sql || ' Pm.Num_Item Num_Item_s,';
        v_sql := v_sql || ' Pm.Num_Autentic_Nfe Num_Autentic_Nfe_s,';
        v_sql := v_sql || ' Pm.Cod_Cfo Cod_Cfo_s,';
        v_sql := v_sql || ' Pm.Vlr_Contabil Vlr_Contabil_s,';
        v_sql := v_sql || ' Pm.Quantidade Quantidade_s,';
        v_sql := v_sql || ' Pm.Vlr_Dif_Qtde Vlr_Dif_Qtde_s,';
        v_sql := v_sql || ' CASE';
        v_sql := v_sql || ' WHEN Pm.Vlr_Dif_Qtde > 0 THEN';
        v_sql := v_sql || ' Round(d.Quantidade * (Pm.Vlr_Dif_Qtde / Pm.Quantidade), 2)';
        v_sql := v_sql || ' ELSE';
        v_sql := v_sql || ' 0';
        v_sql := v_sql || ' END Calc,';
        v_sql := v_sql || ' Rank() Over(PARTITION BY Pm.Cod_Empresa, Pm.Cod_Estab, Pm.Cod_Produto';
        v_sql :=
               v_sql
            || ' ORDER BY Pm.Cod_Empresa, Pm.Cod_Estab, Pm.Num_Docfis, Pm.Data_Fiscal DESC, Pm.Cod_Produto, Pm.Num_Item) Mrank';
        v_sql := v_sql || ' FROM' || dpsp_msaf_dev_pmc_mva || ' d';
        v_sql := v_sql || ' LEFT JOIN Msafi.Dpsp_Msaf_Pmc_Mva Pm';
        v_sql := v_sql || ' ON Pm.Cod_Empresa  = d.Cod_Empresa';
        v_sql := v_sql || ' AND Pm.Cod_Estab    = d.Cod_Estab';
        v_sql := v_sql || ' AND Pm.Cod_Produto  = d.Cod_Produto';
        v_sql := v_sql || ' AND Pm.Data_Fiscal <= d.Data_Emissao';
        v_sql := v_sql || ' WHERE d.Cod_Empresa = P_COD_ESTAB';
        v_sql := v_sql || ' AND d.Data_Emissao BETWEEN V_DATA_INICIAL AND V_DATA_FINAL';
        v_sql := v_sql || ' AND d.cod_estab = P_COD_ESTAB';
        v_sql := v_sql || ' ) x';
        v_sql := v_sql || ' WHERE Mrank = 1';
        v_sql := v_sql || ' GROUP BY To_Char(x.Data_Emissao, ''yyyymm''),';
        v_sql := v_sql || ' x.Cod_Estab';
        v_sql := v_sql || ' ORDER BY VP_PROC_INSTANCE,';
        v_sql := v_sql || ' COD_EMPRESA;';

        EXECUTE IMMEDIATE v_sql;

        COMMIT;

        v_sql := 'SELECT PERIODO,';
        v_sql := v_sql || 'COD_ESTAB,';
        v_sql := v_sql || 'SOMA_CALC,';
        v_sql := v_sql || 'VP_PROC_INSTANCE,';
        v_sql := v_sql || 'COD_EMPRESA,';
        v_sql := v_sql || 'COD_ESTAB2,';
        v_sql := v_sql || 'COD_DATA_EMISSAO,';
        v_sql := v_sql || 'NUM_DOCFIS,';
        v_sql := v_sql || 'NUM_AUTENTIC_NFE,';
        v_sql := v_sql || 'NUM_ITEM ,';
        v_sql := v_sql || 'COD_FIS_JUR ,';
        v_sql := v_sql || 'RAZAO_SOCIAL ,';
        v_sql := v_sql || 'CPF_CGC ,';
        v_sql := v_sql || 'NUM_CONTROLE_DOCTO ,';
        v_sql := v_sql || 'COD_CFO,';
        v_sql := v_sql || 'COD_NATUREZA_OP ,';
        v_sql := v_sql || 'COD_PRODUTO,';
        v_sql := v_sql || 'COD_ESTADO,';
        v_sql := v_sql || 'DESCR_ITEM,';
        v_sql := v_sql || 'COD_NBM,';
        v_sql := v_sql || 'VLR_CONTAB_ITEM,';
        v_sql := v_sql || 'VLR_UNIT,';
        v_sql := v_sql || 'QUANTIDADE,';
        v_sql := v_sql || 'VLR_ITEM ,';
        v_sql := v_sql || 'VLR_OUTRAS,';
        v_sql := v_sql || 'VLR_DESCONTO,';
        v_sql := v_sql || 'VLR_BASE_ICMS,';
        v_sql := v_sql || 'ALIQ_ICMS,';
        v_sql := v_sql || 'VLR_ICMS,';
        v_sql := v_sql || 'VLR_ICMS_ISENTA ,';
        v_sql := v_sql || 'VLR_ICMS_OUTRAS ,';
        v_sql := v_sql || 'BASE_ICMSS,';
        v_sql := v_sql || 'VLR_ICMSS,';
        v_sql := v_sql || 'DATA_FINAL_S,';
        v_sql := v_sql || 'NUM_ITEM_S,';
        v_sql := v_sql || 'NUM_AUTENTIC_NFE_S ,';
        v_sql := v_sql || 'COD_CFO_S,';
        v_sql := v_sql || 'VLR_CONTABIL_S,';
        v_sql := v_sql || 'QUANTIDADE2,';
        v_sql := v_sql || 'VLR_DIF_QTDE	,';
        v_sql := v_sql || 'CALC ';
        v_sql := v_sql || ' FROM ' || dpsp_tbl_sintetic;



        loga ( '>>> Inicio do relatório...' || vp_proc_instance
             , FALSE );

        lib_proc.add_tipo ( mproc_id
                          , 1
                          , mcod_empresa || '_REL_DEVOLUCAO_PMCMVA_SINTETIC.XLS'
                          , 2 );

        lib_proc.add ( dsp_planilha.header
                     , ptipo => 1 );
        lib_proc.add ( dsp_planilha.tabela_inicio
                     , ptipo => 1 );

        lib_proc.add ( dsp_planilha.linha (
                                            p_conteudo =>    dsp_planilha.campo ( 'PERIODO' )
                                                          || -- , PERIODO
                                                            dsp_planilha.campo ( 'COD_ESTAB' )
                                                          || -- , COD_ESTAB
                                                            dsp_planilha.campo ( 'SOMA_CALC' )
                                                          || -- , SOMA_CALC
                                                            dsp_planilha.campo ( 'COD_EMPRESA' )
                                                          || -- , COD_EMPRESA
                                                            dsp_planilha.campo ( 'COD_ESTAB2' )
                                                          || -- , COD_ESTAB
                                                            dsp_planilha.campo ( 'COD_DATA_EMISSAO' )
                                                          || -- , COD_DATA_EMISSAO
                                                            dsp_planilha.campo ( 'NUM_DOCFIS' )
                                                          || -- , NUM_DOCFIS
                                                            dsp_planilha.campo ( 'NUM_AUTENTIC_NFE' )
                                                          || -- , NUM_AUTENTIC_NFE
                                                            dsp_planilha.campo ( 'NUM_ITEM' )
                                                          || -- , NUM_ITEM
                                                            dsp_planilha.campo ( 'COD_FIS_JUR' )
                                                          || -- , COD_FIS_JUR
                                                            dsp_planilha.campo ( 'RAZAO_SOCIAL' )
                                                          || -- , RAZAO_SOCIAL
                                                            dsp_planilha.campo ( 'CPF_CGC' )
                                                          || -- , CPF_CGC
                                                            dsp_planilha.campo ( 'NUM_CONTROLE_DOCTO' )
                                                          || -- , NUM_CONTROLE_DOCTO
                                                            dsp_planilha.campo ( 'COD_CFO' )
                                                          || -- , COD_CFO
                                                            dsp_planilha.campo ( 'COD_NATUREZA_OP' )
                                                          || -- , COD_NATUREZA_OP
                                                            dsp_planilha.campo ( 'COD_PRODUTO' )
                                                          || -- , COD_PRODUTO
                                                            dsp_planilha.campo ( 'COD_ESTADO' )
                                                          || -- , COD_ESTADO
                                                            dsp_planilha.campo ( 'DESCR_ITEM' )
                                                          || -- , DESCR_ITEM
                                                            dsp_planilha.campo ( 'COD_NBM' )
                                                          || -- , COD_NBM
                                                            dsp_planilha.campo ( 'VLR_CONTAB_ITEM' )
                                                          || -- , VLR_CONTAB_ITEM
                                                            dsp_planilha.campo ( 'VLR_UNIT' )
                                                          || -- , VLR_UNIT
                                                            dsp_planilha.campo ( 'QUANTIDADE' )
                                                          || -- , QUANTIDADE
                                                            dsp_planilha.campo ( 'VLR_ITEM' )
                                                          || -- , VLR_ITEM
                                                            dsp_planilha.campo ( 'VLR_OUTRAS' )
                                                          || -- , VLR_OUTRAS
                                                            dsp_planilha.campo ( 'VLR_DESCONTO' )
                                                          || -- , VLR_DESCONTO
                                                            dsp_planilha.campo ( 'VLR_BASE_ICMS' )
                                                          || -- , VLR_BASE_ICMS
                                                            dsp_planilha.campo ( 'ALIQ_ICMS' )
                                                          || -- , ALIQ_ICMS
                                                            dsp_planilha.campo ( 'VLR_ICMS' )
                                                          || -- , VLR_ICMS
                                                            dsp_planilha.campo ( 'VLR_ICMS_ISENTA' )
                                                          || -- , VLR_ICMS_ISENTA
                                                            dsp_planilha.campo ( 'VLR_ICMS_OUTRAS' )
                                                          || -- , VLR_ICMS_OUTRAS
                                                            dsp_planilha.campo ( 'BASE_ICMSS' )
                                                          || -- , BASE_ICMSS
                                                            dsp_planilha.campo ( 'VLR_ICMSS' )
                                                          || -- , VLR_ICMSS
                                                            dsp_planilha.campo ( 'DATA_FINAL_S' )
                                                          || -- , DATA_FINAL_S
                                                            dsp_planilha.campo ( 'NUM_ITEM_S' )
                                                          || -- , NUM_ITEM_S
                                                            dsp_planilha.campo ( 'NUM_AUTENTIC_NFE_S' )
                                                          || -- , NUM_AUTENTIC_NFE_S
                                                            dsp_planilha.campo ( 'COD_CFO_S' )
                                                          || -- , COD_CFO_S
                                                            dsp_planilha.campo ( 'VLR_CONTABIL_S' )
                                                          || -- , VLR_CONTABIL_S
                                                            dsp_planilha.campo ( 'QUANTIDADE2' )
                                                          || -- , QUANTIDADE
                                                            dsp_planilha.campo ( 'VLR_DIF_QTDE' )
                                                          || -- , VLR_DIF_QTDE
                                                            dsp_planilha.campo ( 'CALC' ) -- , CALC
                                          , p_class => 'h'
                       )
                     , ptipo => 1 );

        BEGIN
            OPEN c_sintetic FOR v_sql;
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
                raise_application_error ( -20007
                                        , '!ERRO SELECT DADOS ENTRADAS!' );
        END;

        LOOP
            FETCH c_sintetic
                BULK COLLECT INTO tab_e
                LIMIT 100;

            FOR i IN 1 .. tab_e.COUNT LOOP
                IF v_class = 'a' THEN
                    v_class := 'b';
                ELSE
                    v_class := 'a';
                END IF;

                v_text01 :=
                    dsp_planilha.linha (
                                         p_conteudo =>    dsp_planilha.campo ( tab_e ( i ).periodo )
                                                       || dsp_planilha.campo ( tab_e ( i ).cod_estab )
                                                       || dsp_planilha.campo ( tab_e ( i ).soma_calc )
                                                       || dsp_planilha.campo ( tab_e ( i ).cod_empresa )
                                                       || dsp_planilha.campo ( tab_e ( i ).cod_data_emissao )
                                                       || dsp_planilha.campo ( tab_e ( i ).num_docfis )
                                                       || dsp_planilha.campo ( tab_e ( i ).num_autentic_nfe )
                                                       || dsp_planilha.campo ( tab_e ( i ).num_item )
                                                       || dsp_planilha.campo ( tab_e ( i ).cod_fis_jur )
                                                       || dsp_planilha.campo ( tab_e ( i ).razao_social )
                                                       || dsp_planilha.campo ( tab_e ( i ).cpf_cgc )
                                                       || dsp_planilha.campo ( tab_e ( i ).num_controle_docto )
                                                       || dsp_planilha.campo ( tab_e ( i ).cod_cfo )
                                                       || dsp_planilha.campo ( tab_e ( i ).cod_natureza_op )
                                                       || dsp_planilha.campo ( tab_e ( i ).cod_produto )
                                                       || dsp_planilha.campo ( tab_e ( i ).cod_estado )
                                                       || dsp_planilha.campo ( tab_e ( i ).descr_item )
                                                       || dsp_planilha.campo ( tab_e ( i ).cod_nbm )
                                                       || dsp_planilha.campo ( tab_e ( i ).vlr_contab_item )
                                                       || dsp_planilha.campo ( tab_e ( i ).vlr_unit )
                                                       || dsp_planilha.campo ( tab_e ( i ).quantidade )
                                                       || dsp_planilha.campo ( tab_e ( i ).vlr_item )
                                                       || dsp_planilha.campo ( tab_e ( i ).vlr_outras )
                                                       || dsp_planilha.campo ( tab_e ( i ).vlr_desconto )
                                                       || dsp_planilha.campo ( tab_e ( i ).vlr_base_icms )
                                                       || dsp_planilha.campo ( tab_e ( i ).aliq_icms )
                                                       || dsp_planilha.campo ( tab_e ( i ).vlr_icms )
                                                       || dsp_planilha.campo ( tab_e ( i ).vlr_icms_isenta )
                                                       || dsp_planilha.campo ( tab_e ( i ).vlr_icms_outras )
                                                       || dsp_planilha.campo ( tab_e ( i ).base_icmss )
                                                       || dsp_planilha.campo ( tab_e ( i ).vlr_icmss )
                                                       || dsp_planilha.campo ( tab_e ( i ).data_final_s )
                                                       || dsp_planilha.campo ( tab_e ( i ).num_item_s )
                                                       || dsp_planilha.campo ( tab_e ( i ).num_autentic_nfe_s )
                                                       || dsp_planilha.campo ( tab_e ( i ).cod_cfo_s )
                                                       || dsp_planilha.campo ( tab_e ( i ).vlr_contabil_s )
                                                       || dsp_planilha.campo ( tab_e ( i ).quantidade2 )
                                                       || dsp_planilha.campo ( tab_e ( i ).vlr_dif_qtde )
                                                       || dsp_planilha.campo ( tab_e ( i ).calc )
                                       , p_class => v_class
                    );
                lib_proc.add ( v_text01
                             , ptipo => 1 );
            END LOOP;
        END LOOP;

        lib_proc.add ( dsp_planilha.tabela_fim
                     , ptipo => 1 );
    END load_sintetico;

    /******************************************************************************FIM - GERA EXCEL SINTÉTICO***********************************************************************************/
    /*******************************************************************************INICIO - GERA EXCEL ANALITICO*******************************************************************************/
    PROCEDURE load_analitico ( vp_proc_instance IN VARCHAR
                             , p_cod_estab IN VARCHAR2
                             , v_data_inicial IN DATE
                             , v_data_final IN DATE
                             , dpsp_msaf_dev_pmc_mva IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 1000 );
        v_text01 VARCHAR2 ( 1000 );
        v_class VARCHAR2 ( 1 ) := 'a';
        c_analitic SYS_REFCURSOR;

        TYPE cur_tab_analitic IS RECORD
        (
            vp_proc_instance VARCHAR2 ( 20 )
          , cod_empresa VARCHAR2 ( 3 )
          , cod_estab VARCHAR2 ( 6 )
          , cod_data_emissao DATE
          , num_docfis VARCHAR2 ( 12 )
          , num_autentic_nfe VARCHAR2 ( 80 )
          , num_item NUMBER ( 5 )
          , cod_fis_jur VARCHAR2 ( 14 )
          , razao_social VARCHAR2 ( 70 )
          , cpf_cgc VARCHAR2 ( 14 )
          , num_controle_docto VARCHAR2 ( 12 )
          , cod_cfo VARCHAR2 ( 4 )
          , cod_natureza_op VARCHAR2 ( 3 )
          , cod_produto VARCHAR2 ( 35 )
          , cod_estado VARCHAR2 ( 35 )
          , descr_item VARCHAR2 ( 50 )
          , cod_nbm VARCHAR2 ( 10 )
          , vlr_contab_item NUMBER ( 17, 2 )
          , vlr_unit NUMBER ( 19, 4 )
          , quantidade NUMBER ( 17, 6 )
          , vlr_item NUMBER ( 17, 2 )
          , vlr_outras NUMBER ( 17, 2 )
          , vlr_desconto NUMBER ( 17, 2 )
          , vlr_base_icms NUMBER ( 17, 2 )
          , aliq_icms NUMBER ( 5, 2 )
          , vlr_icms NUMBER ( 17, 2 )
          , vlr_icms_isenta NUMBER ( 17, 2 )
          , vlr_icms_outras NUMBER ( 17, 2 )
          , base_icmss NUMBER ( 17, 2 )
          , vlr_icmss NUMBER ( 17, 2 )
          , data_final_s DATE
          , num_item_s NUMBER ( 17, 2 )
          , num_autentic_nfe_s NUMBER ( 17, 2 )
          , cod_cfo_s NUMBER ( 17, 2 )
          , vlr_contabil_s NUMBER ( 17, 2 )
          , quantidade2 NUMBER ( 17, 2 )
          , vlr_dif_qtde NUMBER ( 17, 2 )
          , calc NUMBER ( 17, 2 )
        );


        TYPE c_tab_analitic IS TABLE OF cur_tab_analitic;

        tab_e c_tab_analitic;
    BEGIN
        v_sql := ' SELECT VP_PROC_INSTANCE, ';
        v_sql := v_sql || ' COD_EMPRESA, ';
        v_sql := v_sql || ' COD_ESTAB, ';
        v_sql := v_sql || ' COD_DATA_EMISSAO, ';
        v_sql := v_sql || ' NUM_DOCFIS, ';
        v_sql := v_sql || ' NUM_AUTENTIC_NFE, ';
        v_sql := v_sql || ' NUM_ITEM, ';
        v_sql := v_sql || ' COD_FIS_JUR, ';
        v_sql := v_sql || ' RAZAO_SOCIAL, ';
        v_sql := v_sql || ' CPF_CGC, ';
        v_sql := v_sql || ' NUM_CONTROLE_DOCTO, ';
        v_sql := v_sql || ' COD_CFO, ';
        v_sql := v_sql || ' COD_NATUREZA_OP, ';
        v_sql := v_sql || ' COD_PRODUTO, ';
        v_sql := v_sql || ' COD_ESTADO, ';
        v_sql := v_sql || ' DESCR_ITEM, ';
        v_sql := v_sql || ' COD_NBM, ';
        v_sql := v_sql || ' VLR_CONTAB_ITEM, ';
        v_sql := v_sql || ' VLR_UNIT,	';
        v_sql := v_sql || ' QUANTIDADE,  ';
        v_sql := v_sql || ' VLR_ITEM, ';
        v_sql := v_sql || ' VLR_OUTRAS, ';
        v_sql := v_sql || ' VLR_DESCONTO, ';
        v_sql := v_sql || ' VLR_BASE_ICMS,	 ';
        v_sql := v_sql || ' ALIQ_ICMS,	';
        v_sql := v_sql || ' VLR_ICMS,	';
        v_sql := v_sql || ' VLR_ICMS_ISENTA, ';
        v_sql := v_sql || ' VLR_ICMS_OUTRAS, ';
        v_sql := v_sql || ' BASE_ICMSS,	';
        v_sql := v_sql || ' VLR_ICMSS,	';
        v_sql := v_sql || ' DATA_FINAL_S, ';
        v_sql := v_sql || ' NUM_ITEM_S,	';
        v_sql := v_sql || ' NUM_AUTENTIC_NFE_S, ';
        v_sql := v_sql || ' COD_CFO_S,	';
        v_sql := v_sql || ' VLR_CONTABIL_S,	';
        v_sql := v_sql || ' QUANTIDADE2,  ';
        v_sql := v_sql || ' VLR_DIF_QTDE,  ';
        v_sql := v_sql || ' CALC ';
        v_sql := v_sql || ' FROM ' || dpsp_msaf_dev_pmc_mva;


        loga ( '>>> Inicio do relatório...' || vp_proc_instance
             , FALSE );

        lib_proc.add_tipo ( mproc_id
                          , 1
                          , mcod_empresa || '_REL_DEVOLUCAO_PMCMVA_ANALITIC.XLS'
                          , 2 );

        lib_proc.add ( dsp_planilha.header
                     , ptipo => 1 );
        lib_proc.add ( dsp_planilha.tabela_inicio
                     , ptipo => 1 );

        lib_proc.add ( dsp_planilha.linha (
                                            p_conteudo =>    dsp_planilha.campo ( 'VP_PROC_INSTANCE' )
                                                          || -- , VP_PROC_INSTANCE
                                                            dsp_planilha.campo ( 'COD_EMPRESA' )
                                                          || -- , COD_EMPRESA
                                                            dsp_planilha.campo ( 'COD_ESTAB' )
                                                          || -- , COD_ESTAB
                                                            dsp_planilha.campo ( 'COD_DATA_EMISSAO' )
                                                          || -- , COD_DATA_EMISSAO
                                                            dsp_planilha.campo ( 'NUM_DOCFIS' )
                                                          || -- , NUM_DOCFIS
                                                            dsp_planilha.campo ( 'NUM_AUTENTIC_NFE' )
                                                          || -- , NUM_AUTENTIC_NFE
                                                            dsp_planilha.campo ( 'NUM_ITEM' )
                                                          || -- , NUM_ITEM
                                                            dsp_planilha.campo ( 'COD_FIS_JUR' )
                                                          || -- , COD_FIS_JUR
                                                            dsp_planilha.campo ( 'RAZAO_SOCIAL' )
                                                          || -- , RAZAO_SOCIAL
                                                            dsp_planilha.campo ( 'CPF_CGC' )
                                                          || -- , CPF_CGC
                                                            dsp_planilha.campo ( 'NUM_CONTROLE_DOCTO' )
                                                          || -- , NUM_CONTROLE_DOCTO
                                                            dsp_planilha.campo ( 'COD_CFO' )
                                                          || -- , COD_CFO
                                                            dsp_planilha.campo ( 'COD_NATUREZA_OP' )
                                                          || -- , COD_NATUREZA_OP
                                                            dsp_planilha.campo ( 'COD_PRODUTO' )
                                                          || -- , COD_PRODUTO
                                                            dsp_planilha.campo ( 'COD_ESTADO' )
                                                          || -- , COD_ESTADO
                                                            dsp_planilha.campo ( 'DESCR_ITEM' )
                                                          || -- , DESCR_ITEM
                                                            dsp_planilha.campo ( 'COD_NBM' )
                                                          || -- , COD_NBM
                                                            dsp_planilha.campo ( 'VLR_CONTAB_ITEM' )
                                                          || -- , VLR_CONTAB_ITEM
                                                            dsp_planilha.campo ( 'VLR_UNIT' )
                                                          || -- , VLR_UNIT
                                                            dsp_planilha.campo ( 'QUANTIDADE' )
                                                          || -- , QUANTIDADE
                                                            dsp_planilha.campo ( 'VLR_ITEM' )
                                                          || -- , VLR_ITEM
                                                            dsp_planilha.campo ( 'VLR_OUTRAS' )
                                                          || -- , VLR_OUTRAS
                                                            dsp_planilha.campo ( 'VLR_DESCONTO' )
                                                          || -- , VLR_DESCONTO
                                                            dsp_planilha.campo ( 'VLR_BASE_ICMS' )
                                                          || -- , VLR_BASE_ICMS
                                                            dsp_planilha.campo ( 'ALIQ_ICMS' )
                                                          || -- , ALIQ_ICMS
                                                            dsp_planilha.campo ( 'VLR_ICMS' )
                                                          || -- , VLR_ICMS
                                                            dsp_planilha.campo ( 'VLR_ICMS_ISENTA' )
                                                          || -- , VLR_ICMS_ISENTA
                                                            dsp_planilha.campo ( 'VLR_ICMS_OUTRAS' )
                                                          || -- , VLR_ICMS_OUTRAS
                                                            dsp_planilha.campo ( 'BASE_ICMSS' )
                                                          || -- , BASE_ICMSS
                                                            dsp_planilha.campo ( 'VLR_ICMSS' )
                                                          || -- , VLR_ICMSS
                                                            dsp_planilha.campo ( 'DATA_FINAL_S' )
                                                          || -- , DATA_FINAL_S
                                                            dsp_planilha.campo ( 'NUM_ITEM_S' )
                                                          || -- , NUM_ITEM_S
                                                            dsp_planilha.campo ( 'NUM_AUTENTIC_NFE_S' )
                                                          || -- , NUM_AUTENTIC_NFE_S
                                                            dsp_planilha.campo ( 'COD_CFO_S' )
                                                          || -- , COD_CFO_S
                                                            dsp_planilha.campo ( 'VLR_CONTABIL_S' )
                                                          || -- , VLR_CONTABIL_S
                                                            dsp_planilha.campo ( 'QUANTIDADE2' )
                                                          || -- , QUANTIDADE
                                                            dsp_planilha.campo ( 'VLR_DIF_QTDE' )
                                                          || -- , VLR_DIF_QTDE
                                                            dsp_planilha.campo ( 'CALC' ) -- , CALC
                                          , p_class => 'h'
                       )
                     , ptipo => 1 );

        BEGIN
            OPEN c_analitic FOR v_sql;
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
                raise_application_error ( -20007
                                        , '!ERRO SELECT DADOS ENTRADAS!' );
        END;

        LOOP
            FETCH c_analitic
                BULK COLLECT INTO tab_e
                LIMIT 100;

            FOR i IN 1 .. tab_e.COUNT LOOP
                IF v_class = 'a' THEN
                    v_class := 'b';
                ELSE
                    v_class := 'a';
                END IF;

                v_text01 :=
                    dsp_planilha.linha (
                                         p_conteudo =>    dsp_planilha.campo ( tab_e ( i ).vp_proc_instance )
                                                       || dsp_planilha.campo ( tab_e ( i ).cod_empresa )
                                                       || dsp_planilha.campo ( tab_e ( i ).cod_estab )
                                                       || dsp_planilha.campo ( tab_e ( i ).cod_data_emissao )
                                                       || dsp_planilha.campo ( tab_e ( i ).num_docfis )
                                                       || dsp_planilha.campo ( tab_e ( i ).num_autentic_nfe )
                                                       || dsp_planilha.campo ( tab_e ( i ).num_item )
                                                       || dsp_planilha.campo ( tab_e ( i ).cod_fis_jur )
                                                       || dsp_planilha.campo ( tab_e ( i ).razao_social )
                                                       || dsp_planilha.campo ( tab_e ( i ).cpf_cgc )
                                                       || dsp_planilha.campo ( tab_e ( i ).num_controle_docto )
                                                       || dsp_planilha.campo ( tab_e ( i ).cod_cfo )
                                                       || dsp_planilha.campo ( tab_e ( i ).cod_natureza_op )
                                                       || dsp_planilha.campo ( tab_e ( i ).cod_produto )
                                                       || dsp_planilha.campo ( tab_e ( i ).cod_estado )
                                                       || dsp_planilha.campo ( tab_e ( i ).descr_item )
                                                       || dsp_planilha.campo ( tab_e ( i ).cod_nbm )
                                                       || dsp_planilha.campo ( tab_e ( i ).vlr_contab_item )
                                                       || dsp_planilha.campo ( tab_e ( i ).vlr_unit )
                                                       || dsp_planilha.campo ( tab_e ( i ).quantidade )
                                                       || dsp_planilha.campo ( tab_e ( i ).vlr_item )
                                                       || dsp_planilha.campo ( tab_e ( i ).vlr_outras )
                                                       || dsp_planilha.campo ( tab_e ( i ).vlr_desconto )
                                                       || dsp_planilha.campo ( tab_e ( i ).vlr_base_icms )
                                                       || dsp_planilha.campo ( tab_e ( i ).aliq_icms )
                                                       || dsp_planilha.campo ( tab_e ( i ).vlr_icms )
                                                       || dsp_planilha.campo ( tab_e ( i ).vlr_icms_isenta )
                                                       || dsp_planilha.campo ( tab_e ( i ).vlr_icms_outras )
                                                       || dsp_planilha.campo ( tab_e ( i ).base_icmss )
                                                       || dsp_planilha.campo ( tab_e ( i ).vlr_icmss )
                                                       || dsp_planilha.campo ( tab_e ( i ).data_final_s )
                                                       || dsp_planilha.campo ( tab_e ( i ).num_item_s )
                                                       || dsp_planilha.campo ( tab_e ( i ).num_autentic_nfe_s )
                                                       || dsp_planilha.campo ( tab_e ( i ).cod_cfo_s )
                                                       || dsp_planilha.campo ( tab_e ( i ).vlr_contabil_s )
                                                       || dsp_planilha.campo ( tab_e ( i ).quantidade2 )
                                                       || dsp_planilha.campo ( tab_e ( i ).vlr_dif_qtde )
                                                       || dsp_planilha.campo ( tab_e ( i ).calc )
                                       , p_class => v_class
                    );
                lib_proc.add ( v_text01
                             , ptipo => 1 );
            END LOOP;
        END LOOP;

        lib_proc.add ( dsp_planilha.tabela_fim
                     , ptipo => 1 );
    END load_analitico;

    /******************************************************************************FIM - GERA EXCEL ANALITICO***********************************************************************************/
    FUNCTION executar ( p_data_ini DATE
                      , p_data_fim DATE
                      , p_uf VARCHAR2
                      , p_cod_estab lib_proc.vartab )
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
        vp_tabela_devol VARCHAR2 ( 30 );
        v_tabela_saida_s VARCHAR2 ( 30 ); ---SINTETICO DA SAIDA PARA GANHO DE PERFORMANCE NAS ULTIMAS ENTRADAS
        dpsp_msaf_dev_pmc_mva VARCHAR2 ( 30 );
        dpsp_tbl_sintetic VARCHAR2 ( 30 );
        v_tabela_gare VARCHAR2 ( 30 );
        v_tabela_inter_tmp VARCHAR2 ( 30 );
        ---
        v_sql_resultado VARCHAR2 ( 4000 );
        v_sql VARCHAR2 ( 4000 );
        v_insert VARCHAR2 ( 5000 );
        vp_proc_instance VARCHAR2 ( 30 );
        vp_count_saida NUMBER;
        v_qtde_tmp NUMBER := 0;
        vp_data_hora_ini VARCHAR2 ( 20 );

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
                            || '_DEV_PMCMVA'
                          , 1 );

        --MARCAR INCIO DA EXECUCAO
        vp_data_hora_ini :=
            TO_CHAR ( SYSDATE
                    , 'DD/MM/YYYY HH24:MI.SS' );

        lib_proc.add_header ( 'Executar processamento do Relatório de Devolução PMC x MVA'
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

        --PREPARAR COD_ESTAB
        IF ( p_cod_estab.COUNT > 0 ) THEN
            i1 := p_cod_estab.FIRST;

            WHILE i1 IS NOT NULL LOOP
                a_estabs.EXTEND ( );
                a_estabs ( a_estabs.LAST ) := p_cod_estab ( i1 );
                i1 := p_cod_estab.NEXT ( i1 );
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



        --EXECUTAR UM P_COD_ESTAB POR VEZ
        FOR est IN a_estabs.FIRST .. a_estabs.COUNT --(1)
                                                   LOOP
            --GERAR CHAVE PROC_ID
            SELECT ROUND ( dbms_random.VALUE ( 10000000000000
                                             , 999999999999999 ) )
              INTO vp_proc_instance
              FROM DUAL;

            ---------------------
            loga ( '>> INICIO CD: ' || a_estabs ( est ) || ' PROC INST: ' || vp_proc_instance
                 , FALSE );

            /*************************************************************************EXECUTAR - INICIO***********************************************************************************/

            --CRIAR TABELA DE DEVOLUÇÃO TEMPORÁRIA
            create_tab_devol ( vp_proc_instance
                             , vp_tabela_devol );
            save_tmp_control ( vp_proc_instance
                             , vp_tabela_devol );

            --CARREGAR DEVOLUÇÃO

            load_devolucao ( vp_proc_instance
                           , a_estabs ( est )
                           , p_data_ini
                           , p_data_fim
                           , vp_tabela_devol
                           , vp_data_hora_ini
                           , p_uf );

            --CRIAR INDICE DE DEVOLUÇÃO

            create_tab_devol_idx ( vp_proc_instance
                                 , vp_tabela_devol );

            --CRIAR TABELA TABELA TEMPORÁRIA FINAL

            create_tab_final ( vp_proc_instance
                             , a_estabs ( est )
                             , vp_tabela_devol
                             , dpsp_msaf_dev_pmc_mva );

            --CARREGA TABELA TEMPORÁRIA FINAL

            load_saidas ( vp_proc_instance
                        , a_estabs ( est )
                        , p_data_ini
                        , p_data_fim
                        , dpsp_msaf_dev_pmc_mva
                        , vp_tabela_devol
                        , vp_data_hora_ini
                        , vp_count_saida );

            --CRIAR INDICE TABELA TEMPORÁRIA FINAL

            create_tab_entrada_cd_idx ( vp_proc_instance
                                      , dpsp_msaf_dev_pmc_mva );

            --CRIAR TABELA SINTÉTICO

            create_tab_devol ( vp_proc_instance
                             , dpsp_tbl_sintetic );

            --CARREGA TABELA SINTÉTICO

            load_sintetico ( vp_proc_instance
                           , a_estabs ( est )
                           , v_data_inicial
                           , v_data_final
                           , dpsp_tbl_sintetic
                           , vp_count_saida
                           , dpsp_msaf_dev_pmc_mva );

            --CRIAR TABELA ANALITICO

            load_analitico ( vp_proc_instance
                           , a_estabs ( est )
                           , v_data_inicial
                           , v_data_final
                           , dpsp_msaf_dev_pmc_mva );
        /*************************************************************************EXECUTAR - FIM**************************************************************************************/

        END LOOP; --(1)


        --DISPONIBILIZAR PERIODO PROCESSADO PARA TRAVA DE REPROCESSAMENTO
        msafi.add_trava_info ( 'INTER'
                             , TO_CHAR ( v_data_inicial
                                       , 'YYYY/MM' ) );

        loga ( '---FIM DO PROCESSAMENTO [SUCESSO]---'
             , FALSE );
        COMMIT;

        --ENVIAR EMAIL DE SUCESSO----------------------------------------
        --ENVIA_EMAIL(MCOD_EMPRESA, V_DATA_INICIAL, V_DATA_FINAL, '', 'S', VP_DATA_HORA_INI);
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
            --ENVIA_EMAIL(MCOD_EMPRESA, V_DATA_INICIAL, V_DATA_FINAL, SQLERRM, 'E', VP_DATA_HORA_INI);
            -----------------------------------------------------------------

            lib_proc.close;
            COMMIT;
            RETURN mproc_id;
    END;
END dpsp_dev_pmcmva_cproc;
/
SHOW ERRORS;
