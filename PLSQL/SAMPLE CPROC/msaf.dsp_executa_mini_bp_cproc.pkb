Prompt Package Body DSP_EXECUTA_MINI_BP_CPROC;
--
-- DSP_EXECUTA_MINI_BP_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dsp_executa_mini_bp_cproc
IS
    mcod_empresa empresa.cod_empresa%TYPE;
    mcod_estab estabelecimento.cod_estab%TYPE;
    musuario usuario_estab.cod_usuario%TYPE;
    v_orcl_job BOOLEAN;

    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );
    BEGIN
        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        mcod_estab := lib_parametros.recuperar ( 'ESTABELECIMENTO' );
        musuario := lib_parametros.recuperar ( 'USUARIO' );

        -- PPARAM:      STRING PASSADA POR REFER�NCIA;
        -- PTITULO:     T�TULO DO PAR�METRO MOSTRADO NA JANELA;
        -- PTIPO:       VARCHAR2, DATE, INTEGER;
        -- PCONTROLE:   MULTIPROC, TEXT, TEXTBOX, COMBOBOX, LISTBOX OU RADIOBUTTON;
        -- PMANDATORIO: S OU N, INDICANDO SE A INFORMA��O DO PAR�METRO � OBRIGAT�RIA;
        -- PDEFAULT:    VALOR PREENCHIDO AUTOMATICAMENTE NA ABERTURA DA JANELA;
        -- PMASCARA:    M�SCARA PARA DIGITA��O (EX: DD/MM/YYYY, 999999 OU ######);
        -- PVALORES:    SELECT (COMBOBOX OU MULTIPROC) OU COD1=DESC1,COD2=DESC2...
        -- PAPRESENTA:  S OU N, INDICANDO SE O PAR�METRO DEVE SER MOSTRADO NA LISTAGEM DOS PROCESSOS;


        lib_proc.add_param ( pstr
                           , 'Validar Tabelas das Interfaces'
                           , 'VARCHAR2'
                           , 'CHECKBOX'
                           , 'N'
                           , 'S'
                           , NULL ); --P_VALIDA_TABS
        lib_proc.add_param ( pstr
                           , 'Executa interfaces de cadastros'
                           , 'VARCHAR2'
                           , 'CHECKBOX'
                           , 'N'
                           , 'S'
                           , NULL ); --P_EXEC_CADASTROS
        lib_proc.add_param ( pstr
                           , 'Executa audit NFs automatico'
                           , 'VARCHAR2'
                           , 'CHECKBOX'
                           , 'N'
                           , 'S'
                           , NULL ); --P_EXEC_AUTO_AUDIT_NF
        lib_proc.add_param ( pstr
                           , 'Limpa logs simples'
                           , 'VARCHAR2'
                           , 'CHECKBOX'
                           , 'N'
                           , 'S'
                           , NULL ); --P_LIMPA_LOG_SIMPLES
        lib_proc.add_param ( pstr
                           , 'Limpa logs pesados'
                           , 'VARCHAR2'
                           , 'CHECKBOX'
                           , 'N'
                           , 'S'
                           , NULL ); --P_LIMPA_LOG_PESADO
        lib_proc.add_param ( pstr
                           , 'Listar Data Mart Carregados'
                           , 'VARCHAR2'
                           , 'CHECKBOX'
                           , 'N'
                           , 'S'
                           , NULL ); --P_LISTA_DATA_MART
        lib_proc.add_param ( pstr
                           , 'Listar usu�rios com MM gerados'
                           , 'VARCHAR2'
                           , 'CHECKBOX'
                           , 'N'
                           , 'S'
                           , NULL ); --P_LISTA_USUARIOS_MM
        lib_proc.add_param ( pstr
                           , 'Listar NFs videntes - data futura'
                           , 'VARCHAR2'
                           , 'CHECKBOX'
                           , 'N'
                           , 'S'
                           , NULL ); --P_LISTA_NFS_VIDENTES
        lib_proc.add_param ( pstr
                           , 'Calcular estat�sticas'
                           , 'VARCHAR2'
                           , 'CHECKBOX'
                           , 'N'
                           , 'S'
                           , NULL ); --P_CALC_STATS

        RETURN pstr;
    END; --FUNCTION PARAMETROS RETURN VARCHAR2 IS

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'MINI BOAS PRATICAS';
    END;

    FUNCTION tipo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Processo';
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
        RETURN 'PROCEDIMENTOS DIARIOS PARA MELHORIA DE PERFORMANCE E MANUTENCAO GERAL';
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

    PROCEDURE loga ( p_texto VARCHAR2 )
    IS
        vtexto VARCHAR2 ( 1024 );
    BEGIN
        vtexto :=
            SUBSTR (    TO_CHAR ( SYSDATE
                                , 'DD/MM/YYYY HH24:MI:SS' )
                     || ' - '
                     || p_texto
                   , 1
                   , 1024 );

        IF NOT v_orcl_job THEN
            lib_proc.add_log ( vtexto
                             , 1 );
        END IF;
    --MSAFI.DSP_CONTROL.WRITELOG('INFO',P_TEXTO);
    END;

    PROCEDURE verifica_tabela ( p_nome_tabela IN VARCHAR2 )
    IS
        TYPE tabtestrc IS REF CURSOR;

        c_tabtest tabtestrc;
        nt NUMBER;
        tt VARCHAR2 ( 100 ) := 'SELECT 1 FROM ' || p_nome_tabela || ' WHERE ROWNUM = 1';
    BEGIN
        OPEN c_tabtest FOR tt;

        FETCH c_tabtest
            INTO nt;

        CLOSE c_tabtest;
    EXCEPTION
        WHEN OTHERS THEN
            loga (
                      'ERRO AO TENTAR ACESSAR A TABELA '
                   || p_nome_tabela
                   || '. FAVOR ACIONAR O DBA! <==========['
                   || SQLCODE
                   || ']=========='
            );
    END verifica_tabela;

    FUNCTION executar ( p_valida_tabs VARCHAR2 DEFAULT 'S'
                      , p_exec_cadastros VARCHAR2 DEFAULT 'S'
                      , p_exec_auto_audit_nf VARCHAR2 DEFAULT 'S'
                      , p_limpa_log_simples VARCHAR2 DEFAULT 'S'
                      , p_limpa_log_pesado VARCHAR2 DEFAULT 'S'
                      , p_lista_data_mart VARCHAR2 DEFAULT 'S'
                      , p_lista_usuarios_mm VARCHAR2 DEFAULT 'S'
                      , p_lista_nfs_videntes VARCHAR2 DEFAULT 'S'
                      , p_calc_stats VARCHAR2 DEFAULT 'S'
                      , p_job NUMBER DEFAULT 0 )
        RETURN INTEGER
    IS
        mproc_id INTEGER;
        iestab INTEGER;

        v_proc_status NUMBER := 0;
        v_s_proc_status VARCHAR2 ( 16 );

        v_num01 NUMBER;

        v_ultima_exec_audit_entrada TIMESTAMP;
        v_ultima_exec_audit_saida TIMESTAMP;
        v_intervalo_entre_cargas_e NUMBER ( 2, 0 );
        v_intervalo_entre_cargas_s NUMBER ( 2, 0 );
        v_ult_dia_carga_mes_anterior NUMBER ( 2, 0 );
        v_dias_manter_cargas_e NUMBER ( 3, 0 );
        v_dias_manter_cargas_s NUMBER ( 3, 0 );

        v_dbg VARCHAR2 ( 80 );

        v_text01 VARCHAR2 ( 100 );
        v_job_num NUMBER;
        v_estab_grupo VARCHAR2 ( 6 );
    BEGIN
        mproc_id := lib_proc.new ( 'DSP_EXECUTA_MINI_BP_CPROC' );

        loga ( 'STEP 1' );

        v_orcl_job := CASE WHEN p_job = 1 THEN TRUE ELSE FALSE END;

        IF v_orcl_job THEN
            SELECT cod_empresa
              INTO mcod_empresa
              FROM msafi.dsp_interface_setup
             WHERE cod_empresa = mcod_empresa;

            musuario := 'Jobson';
        END IF;

        loga ( 'STEP 2' );

        IF ( mcod_empresa IS NULL )
       AND ( NOT v_orcl_job ) THEN
            lib_proc.add_log ( 'C�digo da empresa deve ser informado como par�metro global.'
                             , 0 );
            lib_proc.close;
            RETURN mproc_id;
        END IF;

        v_dbg := '02.' || $$plsql_unit || ' L.' || $$plsql_line;

        v_proc_status := 1; --EM PROCESSO

        loga ( 'STEP 3' );

        --ALTERACAO 10/12/2018 -- PROCESSO CRIADO NO INICIO DO EXECUTAR PARA APRESENTAR SEMPRE APRESENTAR LOG

        /*IF NOT V_ORCL_JOB THEN
            -- CRIA PROCESSO
            --MPROC_ID := LIB_PROC.NEW('DSP_EXECUTA_MINI_BP_CPROC');
        NULL;
        END IF;
        */

        loga ( 'STEP 4' );

        v_dbg := '04.' || $$plsql_unit || ' L.' || $$plsql_line;
        /*     MSAFI.DSP_CONTROL.CREATEPROCESS('MINI_BOAS_PRAT'                                --P_I_PROCID            IN VARCHAR2             , --VARCHAR2(16)
                                            ,'CUSTOMIZADO MASTERSAF: MINI BOAS PRATICAS'     --P_I_PROC_DESCR        IN VARCHAR2             , --VARCHAR2(64)
                                            ,NULL                                            --P_I_DATA_INI          IN DATE     DEFAULT NULL,
                                            ,NULL                                            --P_I_DATA_FIM          IN DATE     DEFAULT NULL,
                                            ,P_VALIDA_TABS || P_EXEC_CADASTROS || P_EXEC_AUTO_AUDIT_NF || P_LIMPA_LOG_SIMPLES
                                            || P_LIMPA_LOG_PESADO || P_LISTA_DATA_MART || P_LISTA_USUARIOS_MM --P_I_DETALHES1         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32):
                                            || P_LISTA_NFS_VIDENTES || P_CALC_STATS
                                            ,NULL                                            --P_I_DETALHES2         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                            ,NULL                                            --P_I_DETALHES3         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                            ,NULL                                            --P_I_DETALHES4         IN VARCHAR2 DEFAULT NULL  --VARCHAR2(32)
                                            ,MUSUARIO                                        --P_I_USER              IN VARCHAR2 DEFAULT NULL  --VARCHAR2(64)
                                            );*/
        ----------------------------------------------------------------------------------------------------------
        loga ( 'STEP 5' );

        loga ( 'MINI BOAS PRATICAS' );
        loga ( ' ' );

        ------------------------------------------------------------------------------------------------------------------------------------------

        IF p_valida_tabs = 'S' THEN
            loga ( 'Verificando exist�ncia e acesso das tabeas (sin�nimos) de interface' );
            verifica_tabela ( 'MSAFI.PS_AR_NFRET_BBL' );
            verifica_tabela ( 'MSAFI.PS_ATRB_OP_EFF_DSP' );
            verifica_tabela ( 'MSAFI.PS_ATRB_OPER_DSP' );
            verifica_tabela ( 'MSAFI.PS_BRL_PO_PROP' );
            verifica_tabela ( 'MSAFI.PS_BRL_TAX_CLASS' );
            verifica_tabela ( 'MSAFI.PS_BUS_UNIT_TBL_IN' );
            verifica_tabela ( 'MSAFI.PS_CITY_TBL_BBL' );
            verifica_tabela ( 'MSAFI.PS_CM_PERPAVG_COST' );
            verifica_tabela ( 'MSAFI.PS_COUNTRY_TBL' );
            verifica_tabela ( 'MSAFI.PS_CUST_ADD_IN_BRL' );
            verifica_tabela ( 'MSAFI.PS_CUST_ADDRESS' );
            verifica_tabela ( 'MSAFI.PS_CUSTOMER' );
            verifica_tabela ( 'MSAFI.PS_DSP_AVG_ICMS_ST' );
            verifica_tabela ( 'MSAFI.PS_DSP_BUS_UNIT_IN' );
            verifica_tabela ( 'MSAFI.PS_DSP_CODBAR_UM' );
            verifica_tabela ( 'MSAFI.PS_DSP_CODBAR_VW' );
            verifica_tabela ( 'MSAFI.PS_DSP_ITEM_LN_MVA' );
            verifica_tabela ( 'MSAFI.PS_DSP_LOTCNTL_INV' );
            verifica_tabela ( 'MSAFI.PS_DSP_MONTKIT_HDR' );
            verifica_tabela ( 'MSAFI.PS_DSP_MONTKIT_LIN' );
            verifica_tabela ( 'MSAFI.PS_DSP_MOV_RET_TBL' );
            verifica_tabela ( 'MSAFI.PS_DSP_PRC_REF_FP' );
            verifica_tabela ( 'MSAFI.PS_DSP_PRECO_ITEM' );
            verifica_tabela ( 'MSAFI.PS_DSP_REL_CON_TMP' );
            verifica_tabela ( 'MSAFI.PS_DSP_RL_LOTE_TBL' );
            verifica_tabela ( 'MSAFI.PS_DSP_RL_NFOR_TBL' );
            verifica_tabela ( 'MSAFI.PS_DSP_SAL_ITM_TBL' );
            verifica_tabela ( 'MSAFI.PS_DSP_SOL_NFE_ADR' );
            verifica_tabela ( 'MSAFI.PS_DSP_SOL_NFE_HDR' );
            verifica_tabela ( 'MSAFI.PS_DSP_ULT_ENT_TBL' );
            verifica_tabela ( 'MSAFI.PS_GL_ACCOUNT_TBL' );
            verifica_tabela ( 'MSAFI.PS_INV_DTL_BAL_IBL' );
            verifica_tabela ( 'MSAFI.PS_INV_ITEMS' );
            verifica_tabela ( 'MSAFI.PS_ITEM_MFG' );
            verifica_tabela ( 'MSAFI.PS_ITM_CAT_TBL' );
            verifica_tabela ( 'MSAFI.PS_JRNL_HEADER' );
            verifica_tabela ( 'MSAFI.PS_JRNL_LN' );
            verifica_tabela ( 'MSAFI.PS_LOCATION_TBL' );
            verifica_tabela ( 'MSAFI.PS_LOC_ID_NBRS_BBL' );
            verifica_tabela ( 'MSAFI.PS_MASTER_ITEM_TBL' );
            verifica_tabela ( 'MSAFI.PS_NF_DATES_BBL' );
            verifica_tabela ( 'MSAFI.PS_NF_HDR_BBL_FS' );
            verifica_tabela ( 'MSAFI.PS_NF_HDR_BRL' );
            verifica_tabela ( 'MSAFI.PS_NF_HDR_TXT_PBL' );
            verifica_tabela ( 'MSAFI.PS_NF_H_TXT_BBL_FS' );
            verifica_tabela ( 'MSAFI.PS_NF_LN_BBL_FS' );
            verifica_tabela ( 'MSAFI.PS_NF_LN_BRL' );
            verifica_tabela ( 'MSAFI.PS_NF_LN_NFEE_BBL' );
            verifica_tabela ( 'MSAFI.PS_NF_TYPE_BRL' );
            verifica_tabela ( 'MSAFI.PS_PAYMENT_TBL' );
            verifica_tabela ( 'MSAFI.PS_PURCH_ITEM_ATTR' );
            verifica_tabela ( 'MSAFI.PS_PYMNT_VCHR_WTHD' );
            verifica_tabela ( 'MSAFI.PS_PYMNT_VCHR_XREF' );
            verifica_tabela ( 'MSAFI.PSRECDEFN' );
            verifica_tabela ( 'MSAFI.PSRECFIELD' );
            verifica_tabela ( 'MSAFI.PSRECFIELDDB' );
            verifica_tabela ( 'MSAFI.PS_REC_GROUP_REC' );
            verifica_tabela ( 'MSAFI.PS_RECV_LN_DISTRIB' );
            verifica_tabela ( 'MSAFI.PS_SET_CNTRL_REC' );
            verifica_tabela ( 'MSAFI.PS_TOF_TYPE_PBL' );
            verifica_tabela ( 'MSAFI.PS_TRANSACTION_INV' );
            verifica_tabela ( 'MSAFI.PSTREELEAF' );
            verifica_tabela ( 'MSAFI.PSTREENODE' );
            verifica_tabela ( 'MSAFI.PS_TREE_NODE_TBL' );
            verifica_tabela ( 'MSAFI.PS_TXTTBL_PBL' );
            verifica_tabela ( 'MSAFI.PS_VCHR_ACCTG_LINE' );
            verifica_tabela ( 'MSAFI.PS_VENDOR' );
            verifica_tabela ( 'MSAFI.PS_VENDOR_ADDR' );
            verifica_tabela ( 'MSAFI.PS_VENDOR_LOC' );
            verifica_tabela ( 'MSAFI.PS_VNDR_ADDR_SCROL' );
            verifica_tabela ( 'MSAFI.PS_VNDR_LOC_SCROL' );
            verifica_tabela ( 'MSAFI.PS_VOUCHER' );
            verifica_tabela ( 'MSAFI.PSXLATITEM' );
            verifica_tabela ( 'MSAFI.PSOPRDEFN' );
            verifica_tabela ( 'MSAFI.PS_DSP_CALBAL_LINE' );
            verifica_tabela ( 'MSAFI.PS_DSP_PE_DIAP_TBL' );
            verifica_tabela ( 'MSAFI.PS_NF_FLOW_BBL' );
            verifica_tabela ( 'MSAFI.PS_DSP_ITM_MVA_VW' );
            verifica_tabela ( 'MSAFI.PS_VENDOR_WTHD_JUR' );
        ELSE
            loga ( 'Valida��o de tabelas das interfaces n�o executada' );
        END IF; --IF P_VALIDA_TABS = 'S' THEN

        ------------------------------------------------------------------------------------------------------------------------------------------

        IF p_exec_cadastros = 'S' THEN
            SELECT estab_grupo
              INTO v_estab_grupo
              FROM msafi.dsp_interface_setup
             WHERE cod_empresa = mcod_empresa;

            ------ Execu��o das interfaces de cadastros
            v_text01 :=
                   'BEGIN MSAFI.PRC_MSAF_PS_NF_CADASTROS('''
                || TO_CHAR ( SYSDATE - 120
                           , 'YYYYMMDD' )
                || ''','''
                || TO_CHAR ( SYSDATE
                           , 'YYYYMMDD' )
                || ''', P_COD_EMPRESA=>'''
                || mcod_empresa
                || '''); END;';
            loga ( 'Executando: ' || v_text01 );

            EXECUTE IMMEDIATE v_text01;

            loga ( 'Interface de cadastros executada com sucesso, criando job de importa��o:' );
            --Cria o job de importa��o
            saf_pega_ident ( 'JOB_IMPORTACAO'
                           , 'NUM_JOB'
                           , v_job_num );

            INSERT INTO job_importacao ( num_job
                                       , tipo_job
                                       , status_job
                                       , data_abertura
                                       , data_encerramento
                                       , ind_ato_cotepe )
                 VALUES ( v_job_num
                        , 'I'
                        , 'P'
                        , SYSDATE
                        , SYSDATE
                        , 'N' );

            COMMIT;

            --Cria as linhas do job
            INSERT INTO det_job_import ( num_job
                                       , grupo_arquivo
                                       , numero_arquivo
                                       , cod_empresa
                                       , cod_estab
                                       , data_ini
                                       , data_fim
                                       , perc_erro
                                       , ind_aborta_job
                                       , status
                                       , ind_drop_tab
                                       , dat_ini_exec
                                       , dat_fim_exec
                                       , ind_periodo
                                       , ind_sobrepor_reg
                                       , ind_log_x2013
                                       , ind_valid_x2013
                                       , ind_data_averb_x48
                                       , ind_gera_x530
                                       , ind_gera_x751
                                       , ind_valid_cep_x04 )
                SELECT v_job_num --NUM_JOB
                     , a.grupo_arquivo --GRUPO_ARQUIVO
                     , a.numero_arquivo --NUMERO_ARQUIVO
                     , mcod_empresa --COD_EMPRESA
                     , CASE WHEN a.grupo_arquivo = 1 THEN v_estab_grupo ELSE NULL END --COD_ESTAB
                     , CASE
                           WHEN a.grupo_arquivo = 1 THEN
                               TO_DATE ( '01011900'
                                       , 'DDMMYYYY' )
                           ELSE
                               TO_DATE (    '01'
                                         || TO_CHAR ( SYSDATE
                                                    , 'MMYYYY' )
                                       , 'DDMMYYYY' )
                       END --DATA_INI
                     , TRUNC ( SYSDATE ) --DATA_FIM
                     , CASE WHEN a.nom_tab_work = 'SAFX08' THEN 2 ELSE 10 END --PERC_ERRO
                     , 'S' --IND_ABORTA_JOB
                     , 'P' --STATUS
                     , 'S' --IND_DROP_TAB
                     , NULL --DAT_INI_EXEC
                     , NULL --DAT_FIM_EXEC
                     , CASE WHEN a.grupo_arquivo = 1 THEN 'N' ELSE 'S' END --IND_PERIODO
                     , 'S' --IND_SOBREPOR_REG
                     , 'N' --IND_LOG_X2013
                     , CASE WHEN a.nom_tab_work = 'SAFX2013' THEN 'S' ELSE 'N' END --IND_VALID_X2013
                     , 'N' --IND_DATA_AVERB_X48
                     , 'N' --IND_GERA_X530
                     , 'N' --IND_GERA_X751
                     --- o correto era marcar com "S" o valida cep da 04 abaixo, mas tem muitos ceps errados no People e eles n�o fazem a corre��o
                     , 'N' --ind_valid_cep_x04
                  FROM cat_prior_imp a
                 WHERE a.nom_tab_work IN ( 'SAFX04'
                                         , 'SAFX2013' );

            COMMIT;
            loga ( 'Job de importa��o criado: [' || v_job_num || ']' );
        ELSE
            loga ( 'Interface de cadastros n�o executada' );
        END IF; --IF P_EXEC_CADASTROS = 'S' THEN

        ------------------------------------------------------------------------------------------------------------------------------------------

        IF p_exec_auto_audit_nf = 'S' THEN
            SELECT ultima_exec_audit_entrada
                 , ultima_exec_audit_saida
                 , intervalo_entre_cargas_e
                 , intervalo_entre_cargas_s
                 , ult_dia_carga_mes_anterior
                 , dias_manter_cargas_e
                 , dias_manter_cargas_s
              INTO v_ultima_exec_audit_entrada
                 , v_ultima_exec_audit_saida
                 , v_intervalo_entre_cargas_e
                 , v_intervalo_entre_cargas_s
                 , v_ult_dia_carga_mes_anterior
                 , v_dias_manter_cargas_e
                 , v_dias_manter_cargas_s
              FROM msafi.dsp_nf_audit_auto_control;

            loga ( 'Limpeza auditoria de entradas - INICIO' );

            DELETE FROM msafi.dsp_nf_audit_entrada
                  WHERE datetime_add <= SYSDATE - v_dias_manter_cargas_e;

            COMMIT;
            loga ( 'Limpeza auditoria de entradas - FIM' );

            loga ( 'Limpeza auditoria de saidas - INICIO' );

            DELETE FROM msafi.dsp_nf_audit_saida
                  WHERE datetime_add <= SYSDATE - v_dias_manter_cargas_s;

            COMMIT;
            loga ( 'Limpeza auditoria de saidas - FIM' );


            IF TRUNC ( v_ultima_exec_audit_entrada ) <= SYSDATE - v_intervalo_entre_cargas_e THEN
                loga ( 'Executando carga de auditoria de entradas' );

                IF TO_NUMBER ( TO_CHAR ( SYSDATE
                                       , 'DD' ) ) <= v_ult_dia_carga_mes_anterior THEN
                    msafi.dsp_insert_audit_entrada ( TO_CHAR ( TRUNC (   TRUNC ( SYSDATE
                                                                               , 'MM' )
                                                                       - 1
                                                                     , 'MM' )
                                                             , 'YYYYMMDD' )
                                                   , TO_CHAR (   TRUNC ( SYSDATE
                                                                       , 'MM' )
                                                               - 1
                                                             , 'YYYYMMDD' )
                                                   , 'MBPMAN' --Mini Boas Praticas Mes ANterior
                                                   , mcod_empresa );
                END IF;

                msafi.dsp_insert_audit_entrada ( TO_CHAR ( TRUNC ( SYSDATE
                                                                 , 'MM' )
                                                         , 'YYYYMMDD' )
                                               , TO_CHAR ( SYSDATE
                                                         , 'YYYYMMDD' )
                                               , 'MBPMAT' --Mini Boas Praticas Mes ATual
                                               , mcod_empresa );

                UPDATE msafi.dsp_nf_audit_auto_control
                   SET ultima_exec_audit_entrada = SYSDATE;

                COMMIT;

                loga ( 'Carga de auditoria de entradas - FIM' );

                IF p_calc_stats = 'S' THEN
                    --MSAFI.DSP_CONTROL.CALCSTATS('DSP_NF_AUDIT_ENTRADA');
                    loga ( 'Calculo de estatisticas da auditoria de entradas - FIM' );
                END IF;
            ELSE
                loga ( 'Carga de auditoria de entradas adiada' );
            END IF; --IF TRUNC(V_ULTIMA_EXEC_AUDIT_ENTRADA) <= SYSDATE-V_INTERVALO_ENTRE_CARGAS_E THEN

            IF TRUNC ( v_ultima_exec_audit_saida ) <= SYSDATE - v_intervalo_entre_cargas_s THEN
                loga ( 'Executando carga de auditoria de saidas' );

                IF TO_NUMBER ( TO_CHAR ( SYSDATE
                                       , 'DD' ) ) <= v_ult_dia_carga_mes_anterior THEN
                    msafi.dsp_insert_audit_saida ( TO_CHAR ( TRUNC (   TRUNC ( SYSDATE
                                                                             , 'MM' )
                                                                     - 1
                                                                   , 'MM' )
                                                           , 'YYYYMMDD' )
                                                 , TO_CHAR (   TRUNC ( SYSDATE
                                                                     , 'MM' )
                                                             - 1
                                                           , 'YYYYMMDD' )
                                                 , 'MBPMAN' --Mini Boas Praticas Mes ANterior
                                                 , mcod_empresa );
                END IF;

                msafi.dsp_insert_audit_saida ( TO_CHAR ( TRUNC ( SYSDATE
                                                               , 'MM' )
                                                       , 'YYYYMMDD' )
                                             , TO_CHAR ( SYSDATE
                                                       , 'YYYYMMDD' )
                                             , 'MBPMAT' --Mini Boas Praticas Mes ATual
                                             , mcod_empresa );

                UPDATE msafi.dsp_nf_audit_auto_control
                   SET ultima_exec_audit_saida = SYSDATE;

                COMMIT;

                loga ( 'Carga de auditoria de saidas - FIM' );

                IF p_calc_stats = 'S' THEN
                    --MSAFI.DSP_CONTROL.CALCSTATS('DSP_NF_AUDIT_SAIDA');
                    loga ( 'Calculo de estatisticas da auditoria de saidas - FIM' );
                END IF;
            ELSE
                loga ( 'Carga de auditoria de saidas adiada' );
            END IF; --IF TRUNC(V_ULTIMA_EXEC_AUDIT_SAIDA) <= SYSDATE-V_INTERVALO_ENTRE_CARGAS_S THEN
        ELSE
            loga ( 'Cargas de auditoria de NFs n�o executada' );
        END IF; --IF P_EXEC_AUTO_AUDIT_NF = 'S' THEN

        ------------------------------------------------------------------------------------------------------------------------------------------

        IF p_limpa_log_simples = 'S' THEN
            ------
            loga ( 'Limpando e otimizando tabelas tempor�rias de scripts' );
            msafi.dsp_aux.trunca_tab_aux ( 'S'
                                         , 'S'
                                         , 90 );
            COMMIT;
            ------
            loga ( 'Limpando LOGs mais antigos que 30 dias' );
            --MSAFI.DSP_CONTROL.LIMPALOGS();
            COMMIT;

            ------
            IF p_calc_stats = 'S' THEN
                loga ( 'Calculando estatisticas das tabelas de LOG' );
                --MSAFI.DSP_CONTROL.CALCSTATS();
                COMMIT;
            END IF;

            ------
            loga ( 'Limpando tabelas tempor�rias do Proc Resoma ICMS de cupom' );

            DELETE FROM msafi.dsp_somacupom_hst
                  WHERE dttm < SYSDATE - 65;

            COMMIT;

            DELETE FROM msafi.dsp_somacupom_ajst_994_hst
                  WHERE dttm < SYSDATE - 65;

            COMMIT;
            msafi.dsp_aux.truncatabela_msafi ( 'DSP_SOMACUPOM_DT_TOT' );
            msafi.dsp_aux.truncatabela_msafi ( 'DSP_SOMACUPOM_AJST_994' );
            msafi.dsp_aux.truncatabela_msafi ( 'DSP_SOMACUPOM' );
            COMMIT;
        ELSE
            loga ( 'Limpeza dos logs simples n�o foi executada' );
        END IF; --IF P_LIMPA_LOG_SIMPLES = 'S' THEN

        ------------------------------------------------------------------------------------------------------------------------------------------

        IF p_limpa_log_pesado = 'S' THEN
            ------ Limpar logs do processo customizado para visualizar logs
            loga ( 'Limpando logs de processo do visualizador de logs (mant�m uma hora)' );
            v_num01 := 0;

            FOR c_logs IN ( SELECT   *
                                FROM lib_processo
                               WHERE aplicacao = 'SAFCP.EXE'
                                 AND sp_nome = 'DSP_LOGS_DSP_CPROC'
                                 AND ( NVL ( data_fim, SYSDATE ) < SYSDATE - ( 1 / 24 )
                                   OR ( data_fim IS NULL
                                   AND data_inicio < SYSDATE - 2 ) --nenhum relat�rio demora dois dias pra rodar!
                                                                   )
                            ORDER BY proc_id ) LOOP
                lib_proc.delete ( c_logs.proc_id );
                COMMIT;
                v_num01 := v_num01 + 1;
            END LOOP;

            COMMIT;
            loga ( 'Logs limpos: [' || v_num01 || ']' );

            ------
            loga ( 'Limpando logs de processo dos customizados de 7 dias atr�s' );
            v_num01 := 0;

            FOR c_logs IN ( SELECT   *
                                FROM lib_processo
                               WHERE aplicacao = 'SAFCP.EXE'
                                 AND ( NVL ( data_fim, SYSDATE ) < SYSDATE - 7
                                   OR ( data_fim IS NULL
                                   AND data_inicio < SYSDATE - 2 ) --nenhum customizado demora dois dias pra rodar!
                                                                   )
                            ORDER BY proc_id ) LOOP
                lib_proc.delete ( c_logs.proc_id );
                COMMIT;
                v_num01 := v_num01 + 1;
            END LOOP;

            COMMIT;
            loga ( 'Logs limpos: [' || v_num01 || ']' );

            ------
            loga ( 'Limpando logs gerais de 10 dias atr�s' );
            v_num01 := 0;

            FOR c_logs IN ( SELECT   *
                                FROM lib_processo
                               WHERE ( NVL ( data_fim, SYSDATE ) < SYSDATE - 10
                                   OR ( data_fim IS NULL
                                   AND data_inicio < SYSDATE - 5 ) --nenhum processo demora cinco dias pra rodar! (nem dois, mas por via das d�vidas...)
                                                                   )
                            ORDER BY proc_id ) LOOP
                lib_proc.delete ( c_logs.proc_id );
                COMMIT;
                v_num01 := v_num01 + 1;
            END LOOP;

            COMMIT;
            loga ( 'Logs limpos: [' || v_num01 || ']' );
        ELSE
            loga ( 'Limpeza de logs pesados n�o foi feita' );
        END IF; --IF P_LIMPA_LOG_PESADO = 'S' THEN

        ------------------------------------------------------------------------------------------------------------------------------------------

        ------
        --        LOGA('Limpando tabela DSP_P2K_RES_CONSIS_FECH (mant�m 75 dias)');
        --        DELETE from msafi.DSP_P2K_RES_CONSIS_FECH
        --        where data_exec_safx < sysdate-75;
        --        LOGA('Linhas exclu�das da DSP_P2K_RES_CONSIS_FECH: [' || SQL%ROWCOUNT || ']');
        --        COMMIT;

        IF p_lista_data_mart = 'S' THEN
            ------ Datas carregadas no Data Mart, para indicar se � necess�rio fazer limpeza (devemos manter apenas os �ltimos tr�s meses)
            loga ( '--------------------------------' );
            loga ( '.                                           .' );
            loga ( 'Lista das datas carregadas no Data Mart:' );
            loga ( 'ANO-MES | N�mero de Estabelecimentos | N�mero de NFs' );
            loga ( '.                                           .' );

            FOR c_dwt IN ( SELECT   TO_CHAR ( data_fiscal
                                            , 'YYYY-MM' )
                                        AS ano_mes
                                  , COUNT ( DISTINCT cod_estab ) num_estabs
                                  , COUNT ( 0 ) AS num_nfs
                               FROM dwt_docto_fiscal
                           GROUP BY TO_CHAR ( data_fiscal
                                            , 'YYYY-MM' )
                           ORDER BY 1 ) LOOP
                loga (    c_dwt.ano_mes
                       || ' | '
                       || TO_CHAR ( c_dwt.num_estabs
                                  , 'FM9999999990' )
                       || ' | '
                       || TO_CHAR ( c_dwt.num_nfs
                                  , 'FM9999999990' ) );
            END LOOP;
        ELSE
            loga ( 'Data mart n�o listado' );
        END IF; --IF P_LISTA_DATA_MART = 'S' THEN

        ------------------------------------------------------------------------------------------------------------------------------------------

        IF p_lista_usuarios_mm = 'S' THEN
            ------ Meio magn�ticos ocupam MUITO espa�o no banco e deixam o MasterSaf lento - atrav�s desta lista, podemos solicitar as exclus�es pelos usu�rios
            loga ( '--------------------------------' );
            loga ( '.                                           .' );
            loga (    'Lista dos usu�rio com Meio Magn�ticos gerados (at� 3 dias atr�s, '
                   || TO_CHAR ( SYSDATE - 3
                              , 'DD/MM/YYYY HH24:MI:SS' )
                   || '):' );
            loga ( 'Usu�rio | N�mero de Processos de Meio Magn�tico' );
            loga ( '.                                           .' );

            FOR c_mm IN ( SELECT   cod_usuario
                                 , COUNT ( 0 ) num_mm
                              FROM lib_processo
                             WHERE aplicacao = 'SAFUFMM.EXE'
                               AND ( ( data_inicio < SYSDATE - 5
                                  AND data_fim IS NULL )
                                 OR ( data_fim < SYSDATE - 3
                                 AND data_fim IS NOT NULL ) )
                          GROUP BY cod_usuario
                          ORDER BY 2 DESC ) LOOP
                loga (    c_mm.cod_usuario
                       || ' | '
                       || TO_CHAR ( c_mm.num_mm
                                  , 'FM9999999990' ) );
            END LOOP;

            loga ( '--------------------------------' );
        ELSE
            loga ( 'Usu�rios do meio magn�tico n�o listados' );
        END IF; --IF P_LISTA_USUARIOS_MM = 'S' THEN

        ------------------------------------------------------------------------------------------------------------------------------------------

        IF p_lista_nfs_videntes = 'S' THEN
            ------ Listar NF's criadas no futuro, para solicitar a exclus�o

            loga ( '--------------------------------' );
            loga ( '.                                           .' );
            loga ( 'Lista das NFs videntes; criadas no futuro.... FAVOR EXCLUIR' );
            loga ( 'Usu�rio|Data de Cria��o|Dt.Fiscal| ESTAB|COD_FIS_JUR|MOVTO_E_S|NUM_DOCFIS|SERIE|Dt.Emiss�o' );
            loga ( '.                                           .' );

            FOR c_nff IN ( SELECT   usuario
                                  , dat_operacao
                                  , data_fiscal
                                  , cod_estab
                                  , movto_e_s
                                  , num_docfis
                                  , serie_docfis
                                  , data_emissao
                                  , ( SELECT cod_fis_jur
                                        FROM x04_pessoa_fis_jur x04
                                       WHERE x04.ident_fis_jur = x07.ident_fis_jur )
                                        cod_fis_jur
                               FROM x07_docto_fiscal x07
                              WHERE data_fiscal > SYSDATE
                           ORDER BY data_fiscal
                                  , dat_operacao ) LOOP
                loga (    c_nff.usuario
                       || '|'
                       || TO_CHAR ( c_nff.dat_operacao
                                  , 'DD/MM/YYYY HH24:MI:SS' )
                       || '|'
                       || TO_CHAR ( c_nff.data_fiscal
                                  , 'DD/MM/YYYY' )
                       || '|'
                       || c_nff.cod_estab
                       || '|'
                       || c_nff.cod_fis_jur
                       || '|'
                       || c_nff.movto_e_s
                       || '|'
                       || c_nff.num_docfis
                       || '|'
                       || c_nff.serie_docfis
                       || '|'
                       || TO_CHAR ( c_nff.data_emissao
                                  , 'DD/MM/YYYY' ) );
            END LOOP;

            loga ( '--------------------------------' );
        ELSE
            loga ( 'Notas videntes n�o listadas' );
        END IF; --IF P_LISTA_NFS_VIDENTES = 'S' THEN


        IF p_calc_stats = 'S' THEN
            loga ( 'Iniciando stats da DSP_IDENT_DOCTO' );
            --MSAFI.DSP_CONTROL.CALCSTATS('DSP_IDENT_DOCTO');
            loga ( 'Stats da DSP_IDENT_DOCTO - FIM' );
            loga ( 'Iniciando stats das DWT' );
            dbms_stats.gather_table_stats ( 'MSAF'
                                          , 'DWT_ITENS_MERC' );
            dbms_stats.gather_table_stats ( 'MSAF'
                                          , 'DWT_ITENS_SERV' );
            dbms_stats.gather_table_stats ( 'MSAF'
                                          , 'DWT_DOCTO_FISCAL' );
            loga ( 'Stats das DWT - FIM' );
            COMMIT;
        END IF;

        ------------------------------------------------------------------------------------------------------------------------------------------

        v_proc_status := 2; --SUCESSO
        loga ( 'Fim do script, SUCESSO' );

        v_dbg := '19.' || $$plsql_unit || ' L.' || $$plsql_line;
        v_s_proc_status :=
            CASE v_proc_status
                WHEN 0 THEN 'ERROI#0' --NUNCA DEVE SER 0, POIS J� VIRA 1 NO IN�CIO!
                WHEN 1 THEN 'ERROI#1' --AINDA EST� EM PROCESSO!??!? ERRO NO PROCESSO!
                WHEN 2 THEN 'SUCESSO'
                WHEN 3 THEN 'AVISOS'
                WHEN 4 THEN 'ERRO'
                ELSE 'ERROI#' || v_proc_status
            END;

        loga ( 'FIM DO PROCESSAMENTO, STATUS FINAL: [' || v_s_proc_status || ']' );

        --MSAFI.DSP_CONTROL.UPDATEPROCESS(V_S_PROC_STATUS);

        IF NOT v_orcl_job THEN
            lib_proc.close ( );
        END IF;

        COMMIT;

        IF NOT v_orcl_job THEN
            RETURN mproc_id;
        ELSE
            RETURN 1;
        END IF;
    END; --FUNCTION EXECUTAR

    PROCEDURE execjob
    IS
    BEGIN
        IF executar ( p_job => 1 ) = 1 THEN
            NULL;
        END IF;
    END;
END dsp_executa_mini_bp_cproc;
/
SHOW ERRORS;
