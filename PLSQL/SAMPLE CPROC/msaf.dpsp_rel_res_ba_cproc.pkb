Prompt Package Body DPSP_REL_RES_BA_CPROC;
--
-- DPSP_REL_RES_BA_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_rel_res_ba_cproc
IS
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

        lib_proc.add_param (
                             pstr
                           , 'Usuário Peoplesoft'
                           , --P_OPRID
                            'VARCHAR2'
                           , 'COMBOBOX'
                           , 'S'
                           , NULL
                           , ''
                           , 'SELECT DISTINCT A.OPRID, A.OPRID || '' - '' || B.OPRDEFNDESC FROM MSAFI.PS_DSP_RUN_APUR_ST A, MSAFI.PSOPRDEFN B WHERE A.OPRID = B.OPRID ORDER BY 1 '
        );

        lib_proc.add_param (
                             pstr
                           , 'Controle de Execução'
                           , --P_RUN_CNTL_ID
                            'VARCHAR2'
                           , 'COMBOBOX'
                           , 'S'
                           , NULL
                           , ''
                           , 'SELECT RUN_CNTL_ID, RUN_CNTL_ID FROM MSAFI.PS_DSP_RUN_APUR_ST WHERE OPRID = :1 ORDER BY 1 '
        );

        lib_proc.add_param (
                             pstr
                           , '> ATENÇÃO! Execute primeiramente este processamento no ERP Peoplesoft. Dúvidas contate o suporte DPSP Mastersaf.'
                           , 'VARCHAR2'
                           , 'TEXT'
                           , 'N'
                           , '1'
                           , NULL
                           , ''
                           , 'N'
        );

        RETURN pstr;
    END; --FUNCTION PARAMETROS RETURN VARCHAR2 IS

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Relatório de Ressarcimento BA - Peoplesoft';
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
        RETURN 'Emitir relatório de ressarcimento da BA processado no Peoplesoft';
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
        msafi.dsp_control.writelog ( 'RRESBA'
                                   , p_i_texto );
    ---> Para acompanhar processamento usar SELECT abaixo
    --SELECT * FROM DSP_LOG
    --WHERE LOG_TYPE = 'RRESBA'
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

    FUNCTION executar ( p_oprid VARCHAR2
                      , p_run_cntl_id VARCHAR2 )
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

        --Variaveis genericas
        v_text01 VARCHAR2 ( 6000 );
        v_sep VARCHAR2 ( 1 ) := CHR ( 9 );
        p_proc_instance VARCHAR2 ( 30 );

        --
        TYPE cur_typ IS REF CURSOR;

        cr_cup cur_typ;
        --
        v_trib_cod_tributo VARCHAR2 ( 6 );
        v_trib_vlr NUMBER ( 20 );
        v_trib_aliq NUMBER ( 20 );
        --
        v_st_cod_tributo VARCHAR2 ( 6 );
        v_st_cod_tributacao NUMBER ( 1 );
        v_st_vlr_base NUMBER ( 20 );
        --
        v_class VARCHAR2 ( 1 ) := 'a';
    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS='',.'' ';

        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        mproc_id :=
            lib_proc.new ( 'DPSP_REL_RES_BA_CPROC'
                         , 48
                         , 150 );

        IF mcod_empresa IS NULL THEN
            lib_proc.add_log ( 'Código da empresa deve ser informado como parâmetro global.'
                             , 0 );
            lib_proc.add ( 'ERRO' );
            lib_proc.add ( 'CÓDIGO DA EMPRESA DEVE SER INFORMADO COMO PARÂMETRO GLOBAL.' );
            lib_proc.close ( );
            RETURN mproc_id;
        END IF;

        msafi.dsp_control.createprocess ( 'DPSP_R_RES_BA' --P_I_PROCID            IN VARCHAR2             , --VARCHAR2(16)
                                        , 'DPSP_REL_RES_BA_CPROC' --P_I_PROC_DESCR        IN VARCHAR2             , --VARCHAR2(64)
                                        , NULL --P_I_DATA_INI          IN DATE     DEFAULT NULL,
                                        , NULL --P_I_DATA_FIM          IN DATE     DEFAULT NULL,
                                        , p_oprid --P_I_DETALHES1         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , p_run_cntl_id --P_I_DETALHES2         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , NULL --P_I_DETALHES3         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , NULL --P_I_DETALHES4         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , musuario --P_I_USER              IN VARCHAR2 DEFAULT NULL  --VARCHAR2(64)
                                                   );
        v_proc_status := 1; --EM PROCESSO

        loga ( '>>> Inicio do relatório...' || p_proc_instance
             , FALSE );

        ---MONTAR RELATORIO ANALITICO-INI--------------------------------------------------------------------------------

        lib_proc.add_tipo ( mproc_id
                          , 1
                          , mcod_empresa || '_VD915_REL_RESSARC_BA.XLS'
                          , 2 );

        lib_proc.add ( dsp_planilha.header
                     , ptipo => 1 );
        lib_proc.add ( dsp_planilha.tabela_inicio
                     , ptipo => 1 );

        lib_proc.add ( dsp_planilha.linha (
                                            p_conteudo =>    dsp_planilha.campo ( 'ENTRADA' )
                                                          || -- ,BUSINESS_UNIT_EXT
                                                            dsp_planilha.campo ( '' )
                                                          || --      ,NF_BRL_EXT
                                                            dsp_planilha.campo ( '' )
                                                          || --      ,NF_BRL_ID_EXT
                                                            dsp_planilha.campo ( '' )
                                                          || --      ,ENTERED_DT
                                                            dsp_planilha.campo ( '' )
                                                          || --      ,VENDOR_ID
                                                            dsp_planilha.campo ( '' )
                                                          || --      ,INV_ITEM_ID
                                                            dsp_planilha.campo ( '' )
                                                          || --      ,DESCR
                                                            dsp_planilha.campo ( '' )
                                                          || --      ,TAX_TYPE_BRL
                                                            dsp_planilha.campo ( '' )
                                                          || --      ,TAX_CLASS_BRL
                                                            dsp_planilha.campo ( '' )
                                                          || --      ,PURCH_PROP_BRL
                                                            dsp_planilha.campo ( '' )
                                                          || --      ,CFO_BRL_CD
                                                            dsp_planilha.campo ( '' )
                                                          || --      ,CFOP_INCOM_PBL
                                                            dsp_planilha.campo ( '' )
                                                          || --      ,DSP_TOTAL_LIQ
                                                            dsp_planilha.campo ( '' )
                                                          || --      ,QTY
                                                            dsp_planilha.campo ( '' )
                                                          || --      ,ICMSTAX_BRL_BSS
                                                            dsp_planilha.campo ( '' )
                                                          || --      ,ICMSTAX_BRL_AMT
                                                            dsp_planilha.campo ( '' )
                                                          || --      ,ICMSTAX_BRL_PCT
                                                            dsp_planilha.campo ( '' )
                                                          || --      ,BASE_ICMS_UNIT
                                                            dsp_planilha.campo ( '' )
                                                          || --      ,VLR_ICMS_UNIT
                                                            dsp_planilha.campo ( '' )
                                                          || --      ,BASE_CALC_RET
                                                            dsp_planilha.campo ( '' )
                                                          || --      ,BASE_CALC_RET_TTL
                                                            dsp_planilha.campo ( '' )
                                                          || --      ,ICMS_ST_UNIT
                                                            dsp_planilha.campo ( '' )
                                                          || --      ,ICMS_ST_TTL
                                                            dsp_planilha.campo ( '' )
                                                          || --      ,NFE_VERIF_CODE_PBL
                                                             ---
                                                             dsp_planilha.campo ( 'SAÍDA' )
                                                          || -- ,DESTIN_BU
                                                            dsp_planilha.campo ( '' )
                                                          || --      ,SHIP_TO_CUST_ID
                                                            dsp_planilha.campo ( '' )
                                                          || --      ,NF_BRL
                                                            dsp_planilha.campo ( '' )
                                                          || --      ,NF_BRL_SERIES
                                                            dsp_planilha.campo ( '' )
                                                          || --      ,TP_PAGTO_DPSP
                                                            dsp_planilha.campo ( '' )
                                                          || --      ,NF_BRL_DATE
                                                            dsp_planilha.campo ( '' )
                                                          || --      ,DPSP_CFO_BRL_CD
                                                            dsp_planilha.campo ( '' )
                                                          || --      ,TXN_NAT_BBL
                                                            dsp_planilha.campo ( '' )
                                                          || --      ,QTY_ALLOCATED
                                                            dsp_planilha.campo ( '' )
                                                          || --      ,VLR_RESSARC
                                                            dsp_planilha.campo ( '' )
                                                          || --      ,SHIP_TO_STATE
                                                            dsp_planilha.campo ( '' )
                                                          || --      ,MERCH_AMT_BSE
                                                            dsp_planilha.campo ( '' )
                                                          || --      ,DSP_NF_BRL_SERIES
                                                            dsp_planilha.campo ( '' ) --        ,NFEE_KEY_BBL
                                          , p_class => 'h'
                       )
                     , ptipo => 1 );

        lib_proc.add ( dsp_planilha.linha (
                                            p_conteudo =>    dsp_planilha.campo ( 'UN' )
                                                          || --  - ,BUSINESS_UNIT_EXT
                                                            dsp_planilha.campo ( 'DOC FISCAL ENTRADA' )
                                                          || --  ,NF_BRL_EXT
                                                            dsp_planilha.campo ( 'ID PEOPLESOFT' )
                                                          || --  ,NF_BRL_ID_EXT
                                                            dsp_planilha.campo ( 'DATA CONTABIL' )
                                                          || --  ,ENTERED_DT
                                                            dsp_planilha.campo ( 'FORNECEDOR' )
                                                          || --  ,VENDOR_ID
                                                            dsp_planilha.campo ( 'PRODUTO' )
                                                          || --  ,INV_ITEM_ID
                                                            dsp_planilha.campo ( 'DESCRICAO' )
                                                          || --  ,DESCR
                                                            dsp_planilha.campo ( 'CST' )
                                                          || --  ,TAX_TYPE_BRL
                                                            dsp_planilha.campo ( 'NCM' )
                                                          || --  ,TAX_CLASS_BRL
                                                            dsp_planilha.campo ( 'FINALIDADE' )
                                                          || --  ,PURCH_PROP_BRL
                                                            dsp_planilha.campo ( 'CFOP SAIDA FORN' )
                                                          || --  ,CFO_BRL_CD
                                                            dsp_planilha.campo ( 'CFOP' )
                                                          || --  ,CFOP_INCOM_PBL
                                                            dsp_planilha.campo ( 'VLR TOTAL LIQ' )
                                                          || --  ,DSP_TOTAL_LIQ
                                                            dsp_planilha.campo ( 'QUANTIDADE' )
                                                          || --  ,QTY
                                                            dsp_planilha.campo ( 'BASE ICMS' )
                                                          || --  ,ICMSTAX_BRL_BSS
                                                            dsp_planilha.campo ( 'VLR ICMS' )
                                                          || --  ,ICMSTAX_BRL_AMT
                                                            dsp_planilha.campo ( '% ICMS' )
                                                          || --  ,ICMSTAX_BRL_PCT
                                                            dsp_planilha.campo ( 'BASE ICMS UNIT' )
                                                          || --  ,BASE_ICMS_UNIT
                                                            dsp_planilha.campo ( 'VLR ICMS UNIT' )
                                                          || --  ,VLR_ICMS_UNIT
                                                            dsp_planilha.campo ( 'BASE CALC RETENCAO' )
                                                          || --  ,BASE_CALC_RET
                                                            dsp_planilha.campo ( 'BASE CALC RET TTL' )
                                                          || --  ,BASE_CALC_RET_TTL
                                                            dsp_planilha.campo ( 'ICMS ST' )
                                                          || --  ,ICMS_ST_UNIT
                                                            dsp_planilha.campo ( 'ICMS ST TTL' )
                                                          || --  ,ICMS_ST_TTL
                                                            dsp_planilha.campo ( 'CHAVE DE ACESSO' )
                                                          || --  ,NFE_VERIF_CODE_PBL
                                                             ---
                                                             dsp_planilha.campo ( 'LOJA' )
                                                          || --  ,DESTIN_BU
                                                            dsp_planilha.campo ( 'ID FORNECEDOR' )
                                                          || --  ,SHIP_TO_CUST_ID
                                                            dsp_planilha.campo ( 'DOC FISCAL' )
                                                          || --  ,NF_BRL
                                                            dsp_planilha.campo ( 'SERIE' )
                                                          || --  ,NF_BRL_SERIES
                                                            dsp_planilha.campo ( 'TIPO PAGTO' )
                                                          || --  ,TP_PAGTO_DPSP
                                                            dsp_planilha.campo ( 'DATA EMISSAO' )
                                                          || -- ,NF_BRL_DATE
                                                            dsp_planilha.campo ( 'CFOP' )
                                                          || -- ,DPSP_CFO_BRL_CD
                                                            dsp_planilha.campo ( 'NAT OPERACAO' )
                                                          || -- ,TXN_NAT_BBL
                                                            dsp_planilha.campo ( 'QTDE TRANSF' )
                                                          || -- ,QTY_ALLOCATED
                                                            dsp_planilha.campo ( 'VLR A RESSARCIR' )
                                                          || -- ,VLR_RESSARC
                                                            dsp_planilha.campo ( 'UF DESTINO' )
                                                          || -- ,SHIP_TO_STATE
                                                            dsp_planilha.campo ( 'VLR TOTAL ITEM' )
                                                          || -- ,MERCH_AMT_BSE
                                                            dsp_planilha.campo ( 'SERIE' )
                                                          || -- ,DSP_NF_BRL_SERIES
                                                            dsp_planilha.campo ( 'CHAVE DE ACESSO' ) -- ,NFEE_KEY_BBL
                                          , p_class => 'h'
                       )
                     , ptipo => 1 );

        FOR cr_r IN load_analitico ( p_oprid
                                   , p_run_cntl_id ) LOOP
            IF v_class = 'a' THEN
                v_class := 'b';
            ELSE
                v_class := 'a';
            END IF;

            v_text01 :=
                dsp_planilha.linha (
                                     p_conteudo =>    dsp_planilha.campo ( cr_r.business_unit_ext )
                                                   || dsp_planilha.campo ( dsp_planilha.texto ( cr_r.nf_brl_ext ) )
                                                   || dsp_planilha.campo ( dsp_planilha.texto ( cr_r.nf_brl_id_ext ) )
                                                   || dsp_planilha.campo ( cr_r.entered_dt )
                                                   || dsp_planilha.campo ( dsp_planilha.texto ( cr_r.vendor_id ) )
                                                   || dsp_planilha.campo ( cr_r.inv_item_id )
                                                   || dsp_planilha.campo ( cr_r.descr )
                                                   || dsp_planilha.campo ( cr_r.tax_type_brl )
                                                   || dsp_planilha.campo ( cr_r.tax_class_brl )
                                                   || dsp_planilha.campo ( cr_r.purch_prop_brl )
                                                   || dsp_planilha.campo ( cr_r.cfo_brl_cd )
                                                   || dsp_planilha.campo ( cr_r.cfop_incom_pbl )
                                                   || dsp_planilha.campo ( cr_r.dsp_total_liq )
                                                   || dsp_planilha.campo ( cr_r.qty )
                                                   || dsp_planilha.campo ( cr_r.icmstax_brl_bss )
                                                   || dsp_planilha.campo ( cr_r.icmstax_brl_amt )
                                                   || dsp_planilha.campo ( cr_r.icmstax_brl_pct )
                                                   || dsp_planilha.campo ( cr_r.base_icms_unit )
                                                   || dsp_planilha.campo ( cr_r.vlr_icms_unit )
                                                   || dsp_planilha.campo ( cr_r.base_calc_ret )
                                                   || dsp_planilha.campo ( cr_r.base_calc_ret_ttl )
                                                   || dsp_planilha.campo ( cr_r.icms_st_unit )
                                                   || dsp_planilha.campo ( cr_r.icms_st_ttl )
                                                   || dsp_planilha.campo (
                                                                           dsp_planilha.texto (
                                                                                                cr_r.nfe_verif_code_pbl
                                                                           )
                                                      )
                                                   || ---
                                                      dsp_planilha.campo ( cr_r.destin_bu )
                                                   || dsp_planilha.campo (
                                                                           dsp_planilha.texto ( cr_r.ship_to_cust_id )
                                                      )
                                                   || dsp_planilha.campo ( dsp_planilha.texto ( cr_r.nf_brl ) )
                                                   || dsp_planilha.campo ( cr_r.nf_brl_series )
                                                   || dsp_planilha.campo ( cr_r.tp_pagto_dpsp )
                                                   || dsp_planilha.campo ( cr_r.nf_brl_date )
                                                   || dsp_planilha.campo ( cr_r.dpsp_cfo_brl_cd )
                                                   || dsp_planilha.campo ( cr_r.txn_nat_bbl )
                                                   || dsp_planilha.campo ( cr_r.qty_allocated )
                                                   || dsp_planilha.campo ( cr_r.vlr_ressarc )
                                                   || dsp_planilha.campo ( cr_r.ship_to_state )
                                                   || dsp_planilha.campo ( cr_r.merch_amt_bse )
                                                   || dsp_planilha.campo ( cr_r.dsp_nf_brl_series )
                                                   || dsp_planilha.campo ( dsp_planilha.texto ( cr_r.nfee_key_bbl ) )
                                   , p_class => v_class
                );
            lib_proc.add ( v_text01
                         , ptipo => 1 );
        END LOOP; --FOR CR_R IN LOAD_ANALITICO(A_ESTABS(i), V_DATA_INICIAL, V_DATA_FINAL)

        lib_proc.add ( dsp_planilha.tabela_fim
                     , ptipo => 1 );

        ---MONTAR RELATORIO ANALITICO-FIM--------------------------------------------------------------------------------

        loga ( '>>> Fim do relatório!'
             , FALSE );
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

        loga ( 'FIM DO PROCESSAMENTO, STATUS FINAL: [' || v_s_proc_status || ']'
             , FALSE );
        msafi.dsp_control.updateprocess ( v_s_proc_status );

        lib_proc.close ( );

        COMMIT;
        RETURN mproc_id;
    EXCEPTION
        WHEN OTHERS THEN
            msafi.dsp_control.log_checkpoint ( SQLERRM
                                             , 'Erro não tratado, executador de interfaces' );
            loga ( 'SQLERRM: ' || SQLERRM
                 , FALSE );

            lib_proc.add_log ( 'Erro não tratado: ' || dbms_utility.format_error_backtrace
                             , 1 );
            lib_proc.add_log ( 'SQLERRM: ' || SQLERRM
                             , 1 );
            lib_proc.add ( 'ERRO!' );
            lib_proc.add ( dbms_utility.format_error_backtrace );
            lib_proc.close;
            COMMIT;
            RETURN mproc_id;
    END; /* FUNCTION EXECUTAR */
END dpsp_rel_res_ba_cproc;
/
SHOW ERRORS;
