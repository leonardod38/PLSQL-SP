Prompt Package Body DSP_SPED_CONTRIB_REL_CPROC;
--
-- DSP_SPED_CONTRIB_REL_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dsp_sped_contrib_rel_cproc
IS
    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    -- AJ0001 - Rodolfo S Carvalhal                            30/06/2017
    -- Formatação de relatório 009
    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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
                           , 'Relatorio'
                           , --P_RELATORIO
                            'VARCHAR2'
                           , 'COMBOBOX'
                           , 'S'
                           , NULL
                           , NULL
                           , '
                            SELECT ''001'',''001 - Devolução de venda - somente data'' FROM DUAL
                      UNION SELECT ''002'',''002 - Compras - somente data'' FROM DUAL
                      UNION SELECT ''003'',''003 - Energia Elétrica - somente data'' FROM DUAL
                      UNION SELECT ''004'',''004 - Faturamento - somente data'' FROM DUAL
                      UNION SELECT ''005'',''005 - Movimentação por CFOP - data e estabelecimento'' FROM DUAL
                      UNION SELECT ''007'',''007 - Movimentação 147 - somente data'' FROM DUAL
                      UNION SELECT ''008'',''008 - Movimentação 148 - somente data'' FROM DUAL
                           '  );

        lib_proc.add_param ( pstr
                           , 'Data Inicial'
                           , --P_DATA_INI
                            'DATE'
                           , 'TEXTBOX'
                           , 'N'
                           , NULL
                           , 'DD/MM/YYYY' );

        lib_proc.add_param ( pstr
                           , 'Data Final'
                           , --P_DATA_FIM
                            'DATE'
                           , 'TEXTBOX'
                           , 'N'
                           , NULL
                           , 'DD/MM/YYYY' );

        lib_proc.add_param (
                             pstr
                           , 'Estabelecimento Inicial'
                           , --P_ESTAB_INI
                            'VARCHAR2'
                           , 'COMBOBOX'
                           , 'N'
                           , NULL
                           , NULL
                           ,    '
                            SELECT A.COD_ESTAB, A.LOJA
                            FROM (
                                SELECT A.COD_ESTAB, A.COD_ESTAB || '' - '' || B.COD_ESTADO || '' - '' || A.CGC || '' - '' || INITCAP(A.BAIRRO) || '' / '' || INITCAP(A.CIDADE) AS LOJA
                                FROM ESTABELECIMENTO A, ESTADO B
                                WHERE A.COD_EMPRESA = '''
                             || mcod_empresa
                             || '''
                                  AND   B.IDENT_ESTADO = A.IDENT_ESTADO
                                  AND   A.COD_ESTAB LIKE ''DS2%''
                                ORDER BY A.COD_ESTAB ) A
                            UNION ALL
                            SELECT A.COD_ESTAB, A.LOJA
                            FROM (
                                SELECT A.COD_ESTAB, A.COD_ESTAB || '' - '' || B.COD_ESTADO || '' - '' || A.CGC || '' - '' || INITCAP(A.BAIRRO) || '' / '' || INITCAP(A.CIDADE) AS LOJA
                                FROM ESTABELECIMENTO A, ESTADO B
                                WHERE A.COD_EMPRESA = '''
                             || mcod_empresa
                             || '''
                                  AND   B.IDENT_ESTADO = A.IDENT_ESTADO
                                  AND   A.COD_ESTAB NOT LIKE ''DS2%''
                                ORDER BY A.COD_ESTAB ) A
                           '
        );

        lib_proc.add_param (
                             pstr
                           , 'Estabelecimento Final'
                           , --P_ESTAB_FIM
                            'VARCHAR2'
                           , 'COMBOBOX'
                           , 'N'
                           , NULL
                           , NULL
                           ,    '
                            SELECT A.COD_ESTAB, A.LOJA
                            FROM (
                                SELECT A.COD_ESTAB, A.COD_ESTAB || '' - '' || B.COD_ESTADO || '' - '' || A.CGC || '' - '' || INITCAP(A.BAIRRO) || '' / '' || INITCAP(A.CIDADE) AS LOJA
                                FROM ESTABELECIMENTO A, ESTADO B
                                WHERE A.COD_EMPRESA = '''
                             || mcod_empresa
                             || '''
                                  AND   B.IDENT_ESTADO = A.IDENT_ESTADO
                                  AND   A.COD_ESTAB LIKE ''DS2%''
                                ORDER BY A.COD_ESTAB ) A
                            UNION ALL
                            SELECT A.COD_ESTAB, A.LOJA
                            FROM (
                                SELECT A.COD_ESTAB, A.COD_ESTAB || '' - '' || B.COD_ESTADO || '' - '' || A.CGC || '' - '' || INITCAP(A.BAIRRO) || '' / '' || INITCAP(A.CIDADE) AS LOJA
                                FROM ESTABELECIMENTO A, ESTADO B
                                WHERE A.COD_EMPRESA = '''
                             || mcod_empresa
                             || '''
                                  AND   B.IDENT_ESTADO = A.IDENT_ESTADO
                                  AND   A.COD_ESTAB NOT LIKE ''DS2%''
                                ORDER BY A.COD_ESTAB ) A
                           '
        );

        RETURN pstr;
    END; --FUNCTION PARAMETROS RETURN VARCHAR2 IS

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'SPED Contribuições - Relatórios';
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
        RETURN 'Relatórios auxiliares do SPED contribuições';
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
        msafi.dsp_control.writelog ( 'INFO'
                                   , p_i_texto );
    END;

    -- AJ0001
    FUNCTION formata_moeda ( v_valor NUMBER )
        RETURN VARCHAR2
    IS
        v_masc VARCHAR2 ( 16 ) := '9g999g999g990d00';
    BEGIN
        RETURN TRIM ( TO_CHAR ( v_valor
                              , v_masc ) );
    END;

    FUNCTION executar ( p_relatorio VARCHAR2
                      , p_data_ini DATE
                      , p_data_fim DATE
                      , p_estab_ini VARCHAR2
                      , p_estab_fim VARCHAR2 )
        RETURN INTEGER
    IS
        mproc_id INTEGER;

        v_sep VARCHAR2 ( 1 );

        v_proc_status NUMBER := 0;
        v_s_proc_status VARCHAR2 ( 16 );

        --Variaveis genericas
        v_text01 VARCHAR2 ( 256 );
    BEGIN
        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' ); -- AJ0001

        v_sep := '|';

        mproc_id :=
            lib_proc.new ( 'DSP_SPED_CONTRIB_REL_CPROC'
                         , 48
                         , 150 );

        IF p_relatorio NOT IN ( '004' ) THEN
            -- AJ0001
            lib_proc.add_tipo ( mproc_id
                              , 1
                              , 'Processo'
                              , 1
                              , pmaxcols => 150 );
        END IF;

        IF mcod_empresa IS NULL THEN
            lib_proc.add_log ( 'Código da empresa deve ser informado como parâmetro global.'
                             , 0 );
            lib_proc.close;
            RETURN mproc_id;
        END IF;

        msafi.dsp_control.createprocess ( 'CUST_ECFPC_RL_01' --P_I_PROCID            IN VARCHAR2             , --VARCHAR2(16)
                                        , 'CUSTOMIZADO MASTERSAF: RELATORIOS SPED CONTRIBUICOES' --P_I_PROC_DESCR        IN VARCHAR2             , --VARCHAR2(64)
                                        , p_data_ini --P_I_DATA_INI          IN DATE     DEFAULT NULL,
                                        , p_data_fim --P_I_DATA_FIM          IN DATE     DEFAULT NULL,
                                        , p_relatorio --P_I_DETALHES1         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , p_estab_ini --P_I_DETALHES2         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , p_estab_fim --P_I_DETALHES3         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , NULL --P_I_DETALHES4         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , musuario --P_I_USER              IN VARCHAR2 DEFAULT NULL  --VARCHAR2(64)
                                                   );
        v_proc_status := 1; --EM PROCESSO

        ----------------------------------------------------------------------------------------------------------
        IF p_relatorio = '001' THEN
            -- RELATORIO: SELECT ''001'',''001 - Devolução de venda - somente data'' FROM DUAL
            loga ( 'Imprimindo relatório' );
            lib_proc.add_header ( '001 - Devolução de venda - somente data'
                                , 1
                                , 1 );
            lib_proc.add_header ( ' ' );
            lib_proc.add (
                           ' ESTAB| Dt Lç P/C| DOC FIS |#Itm| Vl Contab| Base Pis | Vl. PIS  | Bs COFINS| Vl COFINS|CST COFINS'
            );
            lib_proc.add (
                           '------|----------|---------|----|----------|----------|----------|----------|----------|----------'
            );
            --                        DSP900|01/01/2012|000123456|   1|Mmilcen.00|Mmilcen.00|Mmilcen.00|Mmilcen.00|Mmilcen.00| 90

            loga ( 'Abrindo cursor' );

            FOR cr_001 IN c_contrib_rel_001 ( p_data_ini
                                            , p_data_fim ) LOOP
                v_text01 :=
                    msafi.dsp_aux.fazcampo ( cr_001.cod_estab
                                           , ' '
                                           , 6 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_001.dat_lanc_pis_cofins
                                              , 'DD/MM/YYYY'
                                              , ' '
                                              , 10 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_001.num_docfis
                                              , ' '
                                              , 9 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_001.num_item
                                              , ' '
                                              , 4 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_001.vlr_contab_item
                                              , ' '
                                              , 10 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_001.vlr_base_pis
                                              , ' '
                                              , 10 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_001.vlr_pis
                                              , ' '
                                              , 10 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_001.vlr_base_cofins
                                              , ' '
                                              , 10 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_001.vlr_cofins
                                              , ' '
                                              , 10 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_001.cod_situacao_cofins
                                              , ' '
                                              , 3 );
                v_text01 := v_text01 || v_sep;
                lib_proc.add ( v_text01 );
            END LOOP;

            loga ( 'Fim do relatório!' );
            v_proc_status := 2; --SUCESSO
        ----------------------------------------------------------------------------------------------------------
        ELSIF p_relatorio = '002' THEN
            -- RELATORIO: UNION SELECT ''002'',''002 - Compras - somente data'' FROM DUAL
            loga ( 'Imprimindo relatório' );
            lib_proc.add_header ( '002 - Compras - somente data'
                                , 1
                                , 1 );
            lib_proc.add_header ( ' ' );
            lib_proc.add (
                           ' ESTAB| Dt Lç P/C| DOC FIS |    NCM   | Cod. Prod|   Descrição|#Itm| Vl Contab| Base Pis | Vl. PIS  | Bs COFINS| Vl COFINS|'
            );
            lib_proc.add (
                           '------|----------|---------|----------|----------|------------|----|----------|----------|----------|----------|----------|'
            );
            --                        DSP900|01/01/2012|000123456|1234567890|1234567890|12 Chars Dsc|   1|Mmilcen.00|Mmilcen.00|Mmilcen.00|Mmilcen.00|Mmilcen.00|

            loga ( 'Abrindo cursor' );

            FOR cr_002 IN c_contrib_rel_002 ( p_data_ini
                                            , p_data_fim ) LOOP
                v_text01 :=
                    msafi.dsp_aux.fazcampo ( cr_002.cod_estab
                                           , ' '
                                           , 6 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_002.dat_lanc_pis_cofins
                                              , 'DD/MM/YYYY'
                                              , ' '
                                              , 10 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_002.num_docfis
                                              , ' '
                                              , 9 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_002.nbm
                                              , ' '
                                              , 10 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_002.cod_produto
                                              , ' '
                                              , 10 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_002.descricao
                                              , ' '
                                              , 12 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_002.num_item
                                              , ' '
                                              , 4 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_002.vlr_contab_item
                                              , ' '
                                              , 10 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_002.vlr_base_pis
                                              , ' '
                                              , 10 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_002.vlr_pis
                                              , ' '
                                              , 10 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_002.vlr_base_cofins
                                              , ' '
                                              , 10 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_002.vlr_cofins
                                              , ' '
                                              , 10 );
                v_text01 := v_text01 || v_sep;
                lib_proc.add ( v_text01 );
            END LOOP;

            loga ( 'Fim do relatório!' );
            v_proc_status := 2; --SUCESSO
        ----------------------------------------------------------------------------------------------------------
        ELSIF p_relatorio = '003' THEN
            -- RELATORIO: UNION SELECT ''003'',''003 - Energia Elétrica - somente data'' FROM DUAL
            loga ( 'Imprimindo relatório' );
            lib_proc.add_header ( '003 - Energia Elétrica - somente data'
                                , 1
                                , 1 );
            lib_proc.add_header ( ' ' );
            lib_proc.add (
                           ' ESTAB|cDt Lç P/C|iDt Lç P/C| Data Fisc| DOC FIS |#Itm| Vl Contab| Base Pis | Vl. PIS  | Bs COFINS| Vl COFINS|'
            );
            lib_proc.add (
                           '------|----------|----------|----------|---------|----|----------|----------|----------|----------|----------|'
            );
            --                        DSP900|01/01/2012|01/01/2012|01/01/2012|000123456|   1|Mmilcen.00|Mmilcen.00|Mmilcen.00|Mmilcen.00|Mmilcen.00|

            loga ( 'Abrindo cursor' );

            FOR cr_003 IN c_contrib_rel_003 ( p_data_ini
                                            , p_data_fim ) LOOP
                v_text01 :=
                    msafi.dsp_aux.fazcampo ( cr_003.cod_estab
                                           , ' '
                                           , 6 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_003.capa_dat_lanc_pis_cofins
                                              , 'DD/MM/YYYY'
                                              , ' '
                                              , 10 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_003.item_dat_lanc_pis_cofins
                                              , 'DD/MM/YYYY'
                                              , ' '
                                              , 10 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_003.num_docfis
                                              , ' '
                                              , 9 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_003.data_fiscal
                                              , 'DD/MM/YYYY'
                                              , ' '
                                              , 10 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_003.num_item
                                              , ' '
                                              , 4 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_003.vlr_contab_item
                                              , ' '
                                              , 10 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_003.vlr_base_pis
                                              , ' '
                                              , 10 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_003.vlr_pis
                                              , ' '
                                              , 10 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_003.vlr_base_cofins
                                              , ' '
                                              , 10 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_003.vlr_cofins
                                              , ' '
                                              , 10 );
                v_text01 := v_text01 || v_sep;
                lib_proc.add ( v_text01 );
            END LOOP;

            loga ( 'Fim do relatório!' );
            v_proc_status := 2; --SUCESSO
        ----------------------------------------------------------------------------------------------------------
        ELSIF p_relatorio = '004' THEN
            -- RELATORIO: UNION SELECT ''004'',''004 - Faturamento - somente data'' FROM DUAL
            /*LOGA('Imprimindo relatório');
                        LIB_PROC.add_header('004 - Faturamento - somente data',1,1);
                        lib_proc.add_header(' ');
                        lib_proc.add(' ESTAB| Dt Emisao| Vlr Item |CST P| Base Pis |Alq P| Vl. PIS  |CST C| Bs COFINS|Alq C| Vl COFINS|');
                        lib_proc.add('------|----------|----------|-----|----------|-----|----------|-----|----------|-----|----------|');
            --                        DSP900|01/01/2012|Mmilcen.00|  90 |Mmilcen.00|99,99|Mmilcen.00|  90 |Mmilcen.00|99,99|Mmilcen.00|

                        LOGA('Abrindo cursor');
                        FOR CR_004 IN C_CONTRIB_REL_004(P_ESTAB_INI,P_ESTAB_FIM,P_DATA_INI,P_DATA_FIM)
                        LOOP
                            V_TEXT01 :=                      MSAFI.DSP_AUX.FAZCAMPO(CR_004.COD_ESTAB                                      ,' ', 6);
                            V_TEXT01 := V_TEXT01 || V_SEP || MSAFI.DSP_AUX.FAZCAMPO(CR_004.DATA_EMISSAO                   ,'DD/MM/YYYY'   ,' ',10);
                            V_TEXT01 := V_TEXT01 || V_SEP || MSAFI.DSP_AUX.FAZCAMPO(CR_004.VLR_ITEM                                       ,' ',10);
                            V_TEXT01 := V_TEXT01 || V_SEP || MSAFI.DSP_AUX.FAZCAMPO(CR_004.COD_SIT_TRIB_PIS                               ,' ', 5);
                            V_TEXT01 := V_TEXT01 || V_SEP || MSAFI.DSP_AUX.FAZCAMPO(CR_004.VLR_BASE_PIS                                   ,' ',10);
                            V_TEXT01 := V_TEXT01 || V_SEP || MSAFI.DSP_AUX.FAZCAMPO(CR_004.VLR_ALIQ_PIS                   ,'FM90D00'      ,' ', 5);
                            V_TEXT01 := V_TEXT01 || V_SEP || MSAFI.DSP_AUX.FAZCAMPO(CR_004.VLR_PIS                                        ,' ',10);
                            V_TEXT01 := V_TEXT01 || V_SEP || MSAFI.DSP_AUX.FAZCAMPO(CR_004.COD_SIT_TRIB_COFINS                            ,' ', 5);
                            V_TEXT01 := V_TEXT01 || V_SEP || MSAFI.DSP_AUX.FAZCAMPO(CR_004.VLR_BASE_COFINS                                ,' ',10);
                            V_TEXT01 := V_TEXT01 || V_SEP || MSAFI.DSP_AUX.FAZCAMPO(CR_004.VLR_ALIQ_COFINS                ,'FM90D00'      ,' ', 5);
                            V_TEXT01 := V_TEXT01 || V_SEP || MSAFI.DSP_AUX.FAZCAMPO(CR_004.VLR_COFINS                                     ,' ',10);
                            V_TEXT01 := V_TEXT01 || V_SEP;
                            lib_proc.add(V_TEXT01);
                        END LOOP;

                        LOGA('Fim do relatório!');
                                    */
            DECLARE
                -- AJ0001
                v_class CHAR ( 1 ) := 'b';
            BEGIN
                EXECUTE IMMEDIATE 'alter session set nls_numeric_characters='',.'' ';

                lib_proc.add_tipo ( mproc_id
                                  , 1
                                  , 'Rel_Faturamento_PIS_Cofins.xls'
                                  , 2 );

                lib_proc.add ( dsp_planilha.header );
                lib_proc.add ( dsp_planilha.tabela_inicio );

                lib_proc.add ( dsp_planilha.linha (
                                                       dsp_planilha.campo ( 'ESTAB' )
                                                    || dsp_planilha.campo ( 'Dt Emisao' )
                                                    || dsp_planilha.campo ( 'Vlr Item' )
                                                    || dsp_planilha.campo ( 'CST P' )
                                                    || dsp_planilha.campo ( 'Base Pis' )
                                                    || dsp_planilha.campo ( 'Alq P' )
                                                    || dsp_planilha.campo ( 'Vl. PIS' )
                                                    || dsp_planilha.campo ( 'CST C' )
                                                    || dsp_planilha.campo ( 'Bs COFINS' )
                                                    || dsp_planilha.campo ( 'Alq C' )
                                                    || dsp_planilha.campo ( 'Vl COFINS' )
                                                  , p_class => 'h'
                               ) );

                loga ( 'Abrindo cursor' );

                FOR cr_004 IN c_contrib_rel_004 ( p_estab_ini
                                                , p_estab_fim
                                                , p_data_ini
                                                , p_data_fim ) LOOP
                    v_text01 := dsp_planilha.campo ( cr_004.cod_estab );
                    v_text01 := v_text01 || dsp_planilha.campo ( cr_004.data_emissao );
                    v_text01 := v_text01 || dsp_planilha.campo ( formata_moeda ( cr_004.vlr_item ) );
                    v_text01 := v_text01 || dsp_planilha.campo ( dsp_planilha.texto ( cr_004.cod_sit_trib_pis ) );
                    v_text01 := v_text01 || dsp_planilha.campo ( formata_moeda ( cr_004.vlr_base_pis ) );
                    v_text01 := v_text01 || dsp_planilha.campo ( formata_moeda ( cr_004.vlr_aliq_pis ) );
                    v_text01 := v_text01 || dsp_planilha.campo ( formata_moeda ( cr_004.vlr_pis ) );
                    v_text01 := v_text01 || dsp_planilha.campo ( dsp_planilha.texto ( cr_004.cod_sit_trib_cofins ) );
                    v_text01 := v_text01 || dsp_planilha.campo ( formata_moeda ( cr_004.vlr_base_cofins ) );
                    v_text01 := v_text01 || dsp_planilha.campo ( formata_moeda ( cr_004.vlr_aliq_cofins ) );
                    v_text01 := v_text01 || dsp_planilha.campo ( formata_moeda ( cr_004.vlr_cofins ) );
                    lib_proc.add ( dsp_planilha.linha ( v_text01
                                                      , p_class => v_class ) );

                    IF v_class = 'a' THEN
                        v_class := 'b';
                    ELSE
                        v_class := 'a';
                    END IF;
                END LOOP;

                lib_proc.add ( dsp_planilha.tabela_fim );
            END;

            v_proc_status := 2; --SUCESSO
        ----------------------------------------------------------------------------------------------------------
        ELSIF p_relatorio = '005' THEN
            -- RELATORIO: UNION SELECT ''005'',''005 - Movimentação por CFOP - data e estabelecimento'' FROM DUAL
            loga ( 'Imprimindo relatório' );
            lib_proc.add_header ( '005 - Movimentação por CFOP - data e estabelecimento'
                                , 1
                                , 1 );
            lib_proc.add_header ( ' ' );
            lib_proc.add ( ' ESTAB| Dt Fiscal| DOC FIS |  Cod Fis Jur |CFOP| Vlr Contb| Vlr ICMS |' );
            lib_proc.add ( '------|----------|---------|--------------|----|----------|----------|' );
            --                        DSP900|01/01/2012|000123456|F00000000003-1|1234|Mmilcen.00|Mmilcen.00|

            loga ( 'Abrindo cursor' );

            FOR cr_005 IN c_contrib_rel_005 ( p_estab_ini
                                            , p_estab_fim
                                            , p_data_ini
                                            , p_data_fim ) LOOP
                v_text01 :=
                    msafi.dsp_aux.fazcampo ( cr_005.cod_estab
                                           , ' '
                                           , 6 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_005.data_fiscal
                                              , 'DD/MM/YYYY'
                                              , ' '
                                              , 10 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_005.num_docfis
                                              , ' '
                                              , 9 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_005.cod_fis_jur
                                              , ' '
                                              , 14 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_005.cod_cfo
                                              , ' '
                                              , 4 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_005.vlr_contab_item
                                              , ' '
                                              , 10 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_005.vlr_tributo_icms
                                              , ' '
                                              , 10 );
                v_text01 := v_text01 || v_sep;
                lib_proc.add ( v_text01 );
            END LOOP;

            loga ( 'Fim do relatório!' );
            v_proc_status := 2; --SUCESSO
        ----------------------------------------------------------------------------------------------------------
        ELSIF p_relatorio = '006' THEN
            -- RELATORIO: UNION SELECT ''006'',''006 - Relatório P100 RH - somente data'' FROM DUAL
            loga ( 'Imprimindo relatório' );
            lib_proc.add_header ( '006 - Relatório P100 RH'
                                , 1
                                , 1 );
            lib_proc.add_header ( ' ' );
            lib_proc.add (
                           ' ESTAB|  Data    |Rc Brt Tot| Dem Ativ |Rc Brt Atv|Excl RcBrt|Bs Clc Atv|Cntrb Prev|Vlr Ajuste|'
            );
            lib_proc.add (
                           '------|----------|----------|----------|----------|----------|----------|----------|----------|'
            );
            --                        DSP900|01/01/2012|1234567,89|1234567,89|1234567,89|1234567,89|1234567,89|1234567,89|1234567,89

            loga ( 'Abrindo cursor' );

            FOR cr_006 IN c_contrib_rel_006 ( p_data_ini
                                            , p_data_fim ) LOOP
                v_text01 :=
                    msafi.dsp_aux.fazcampo ( cr_006.cod_estab
                                           , ' '
                                           , 6 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_006.data_fim
                                              , 'DD/MM/YYYY'
                                              , ' '
                                              , 10 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_006.valor_receita_bruta_total
                                              , ' '
                                              , 10 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_006.valor_demais_atividades
                                              , ' '
                                              , 10 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_006.valor_receita_bruta_atividade
                                              , ' '
                                              , 10 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_006.valor_exclusoes_rec_bruta
                                              , ' '
                                              , 10 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_006.base_calculo_ativ
                                              , ' '
                                              , 10 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_006.valor_contribuicao_prev
                                              , ' '
                                              , 10 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_006.valor_ajuste
                                              , ' '
                                              , 10 );
                v_text01 := v_text01 || v_sep;
                lib_proc.add ( v_text01 );
            END LOOP;

            loga ( 'Fim do relatório!' );
            v_proc_status := 2; --SUCESSO
        ----------------------------------------------------------------------------------------------------------
        ELSIF p_relatorio = '007' THEN
            -- RELATORIO: UNION SELECT ''007'',''007 - Movimentação 147 - somente data'' FROM DUAL
            loga ( 'Imprimindo relatório' );
            lib_proc.add_header ( '007 - Movimentação 147'
                                , 1
                                , 1 );
            lib_proc.add_header ( ' ' );
            lib_proc.add ( ' ESTAB| COD_CONTA| Valor Oper|Vlr. Bs PIS| Valor PIS|Valor COFINS|' );
            lib_proc.add ( '------|----------|-----------|-----------|----------|------------|' );
            --                        DSP003|  31210106|   73722,34|   73722,34|   1216,42|     5602,90|

            loga ( 'Abrindo cursor' );

            FOR cr_007 IN c_contrib_rel_007 ( p_data_ini
                                            , p_data_fim ) LOOP
                v_text01 :=
                    msafi.dsp_aux.fazcampo ( cr_007.cod_estab
                                           , ' '
                                           , 6 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_007.cod_conta
                                              , ' '
                                              , 10 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_007.vlr_oper
                                              , ' '
                                              , 11 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_007.vlr_base_pis
                                              , ' '
                                              , 11 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_007.vlr_pis
                                              , ' '
                                              , 10 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_007.vlr_cofins
                                              , ' '
                                              , 12 );
                v_text01 := v_text01 || v_sep;
                lib_proc.add ( v_text01 );
            END LOOP;

            loga ( 'Fim do relatório!' );
            v_proc_status := 2; --SUCESSO
        ----------------------------------------------------------------------------------------------------------
        ELSIF p_relatorio = '008' THEN
            -- RELATORIO: UNION SELECT ''008'',''008 - Movimentação 148 - somente data'' FROM DUAL
            loga ( 'Imprimindo relatório' );
            lib_proc.add_header ( '008 - Movimentação 148'
                                , 1
                                , 1 );
            lib_proc.add_header ( ' ' );
            lib_proc.add ( ' ESTAB| COD_CONTA|Vl Dp Amort|Bs Crd PPas|Vlr. Bs PIS| Valor PIS|Valor COFINS|' );
            lib_proc.add ( '------|----------|-----------|-----------|-----------|----------|------------|' );
            --                        DSP003|  13120210|    1121,42|    1121,42|    1121,42|      18,5|       85,23|

            loga ( 'Abrindo cursor' );

            FOR cr_008 IN c_contrib_rel_008 ( p_data_ini
                                            , p_data_fim ) LOOP
                v_text01 :=
                    msafi.dsp_aux.fazcampo ( cr_008.cod_estab
                                           , ' '
                                           , 6 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_008.cod_conta
                                              , ' '
                                              , 10 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_008.vlr_dep_amort
                                              , ' '
                                              , 11 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_008.vlr_base_cred_pispasep
                                              , ' '
                                              , 11 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_008.vlr_base_pis
                                              , ' '
                                              , 11 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_008.vlr_pis
                                              , ' '
                                              , 10 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_008.vlr_cofins
                                              , ' '
                                              , 12 );
                v_text01 := v_text01 || v_sep;
                lib_proc.add ( v_text01 );
            END LOOP;

            loga ( 'Fim do relatório!' );
            v_proc_status := 2; --SUCESSO
        ----------------------------------------------------------------------------------------------------------
        ELSIF p_relatorio = '009' THEN
            -- RELATORIO: UNION SELECT ''009'',''009 - Relatório de Transferências'' FROM DUAL
            loga ( 'Imprimindo relatório' );
            lib_proc.add_header ( '009 - Relatório de Transferências'
                                , 1
                                , 1 );
            lib_proc.add_header ( ' ' );
            lib_proc.add (
                           ' ESTAB| DATA FISC|DOC FISCAL|PRODUTO|CFOP| VLR CONTAB|  BASE TRIB|   VLR ICMS|BASE ISENTA|BASE OUTRAS|'
            );
            lib_proc.add (
                           '------|----------|----------|-------|----|-----------|-----------|-----------|-----------|-----------|'
            );
            --                        DSP003|21/10/2015| 000003857| 173843|5409| 123.456,78| 123.456,78| 123.456,78| 123.456,78| 123.456,78|

            loga ( 'Abrindo cursor' );

            FOR cr_009 IN c_contrib_rel_009 ( p_estab_ini
                                            , p_estab_fim
                                            , p_data_ini
                                            , p_data_fim ) LOOP
                v_text01 :=
                    msafi.dsp_aux.fazcampo ( cr_009.estabelecimento
                                           , ' '
                                           , 6 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_009.data_fiscal
                                              , 'DD/MM/YYYY'
                                              , ' '
                                              , 10 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_009.documento_fiscal
                                              , ' '
                                              , 10 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_009.codigo_do_item
                                              , ' '
                                              , 7 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_009.cfop
                                              , ' '
                                              , 4 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_009.valor_contabil
                                              , ' '
                                              , 11 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_009.base_tributada
                                              , ' '
                                              , 11 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_009.valor_tributo
                                              , ' '
                                              , 11 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_009.base_isenta
                                              , ' '
                                              , 11 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || msafi.dsp_aux.fazcampo ( cr_009.base_outras
                                              , ' '
                                              , 11 );
                v_text01 := v_text01 || v_sep;
                lib_proc.add ( v_text01 );
            END LOOP;

            loga ( 'Fim do relatório!' );

            v_proc_status := 2; --SUCESSO
        ----------------------------------------------------------------------------------------------------------
        --ELSIF P_RELATORIO = '003' THEN
        ---            lib_proc.add('         1         2         3         4         5         6         7         8        9         10        11        12         13       14        15');
        ---            lib_proc.add('123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890');
        END IF;

        v_s_proc_status :=
            CASE v_proc_status
                WHEN 0 THEN 'ERROI#0' --NUNCA DEVE SER 0, POIS JÁ VIRA 1 NO INÍCIO!
                WHEN 1 THEN 'ERROI#1' --AINDA ESTÁ EM PROCESSO!??!? ERRO NO PROCESSO!
                WHEN 2 THEN 'SUCESSO'
                WHEN 3 THEN 'AVISOS'
                WHEN 4 THEN 'ERRO'
                ELSE 'ERROI#' || v_proc_status
            END;

        loga ( 'FIM DO PROCESSAMENTO, STATUS FINAL: [' || v_s_proc_status || ']' );
        msafi.dsp_control.updateprocess ( v_s_proc_status );
        lib_proc.close ( );

        COMMIT;
        RETURN mproc_id;
    EXCEPTION
        WHEN OTHERS THEN
            --MSAFI.DSP_CONTROL.LOG_CHECKPOINT(SQLERRM,'Erro não tratado, relatórios customizados');
            lib_proc.add_log ( 'Erro não tratado: ' || SQLERRM
                             , 1 );
            loga ( 'Abortando execução' );
            lib_proc.close;
            COMMIT;
            RETURN mproc_id;
    END; /* FUNCTION EXECUTAR */
BEGIN
    --configura as variáveis para funções regexp
    v_proc_9xx := '^' || mcod_empresa || '9[0-9]{2}$';
    v_proc_dep := '^' || mcod_empresa || '9[0-9][1-9]$';
    v_proc_loj :=
           '^'
        || mcod_empresa
        || '[0-8][0-9]{'
        || TO_CHAR ( 5 - LENGTH ( mcod_empresa )
                   , 'FM9' )
        || '}$';
    v_proc_est :=
           '^'
        || mcod_empresa
        || '[0-9]{3,'
        || TO_CHAR ( 6 - LENGTH ( mcod_empresa )
                   , 'FM9' )
        || '}$';
    v_proc_estvd :=
           '^VD[0-9]{3,'
        || TO_CHAR ( 6 - LENGTH ( mcod_empresa )
                   , 'FM9' )
        || '}$';
END dsp_sped_contrib_rel_cproc;
/
SHOW ERRORS;
