Prompt Package Body DPSP_REL_VALIDA_CPROC;
--
-- DPSP_REL_VALIDA_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_rel_valida_cproc
IS
    mcod_empresa empresa.cod_empresa%TYPE;
    mcod_estab estabelecimento.cod_estab%TYPE;
    musuario usuario_empresa.cod_usuario%TYPE;

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
                           , 'DATA DO FECHAMENTO'
                           , --P_DATA_FECHAMENTO
                            'VARCHAR2'
                           , 'COMBOBOX'
                           , 'S'
                           , NULL
                           , NULL
                           , '
                            SELECT DISTINCT DATA_FECHAMENTO, DATA_FECHAMENTO 
                            FROM MSAFI.DSP_VALIDA_HDR
                            ORDER BY 1 DESC
                           '  );

        lib_proc.add_param ( pstr
                           , 'NOME DA PLANILHA'
                           , --P_NOME_PLANILHA
                            'VARCHAR2'
                           , 'TEXTBOX'
                           , 'S' );

        lib_proc.add_param ( pstr
                           , 'CONCATENAÇÃO (COLUNA U)'
                           , --P_CONCATENA_ID
                            'VARCHAR2'
                           , 'TEXTBOX'
                           , 'S' );

        RETURN pstr;
    END; --FUNCTION PARAMETROS RETURN VARCHAR2 IS

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Relatório de Notas Fiscais do VALIDA';
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
        RETURN 'Relatório para Análise de Notas Fiscais a partir do VALIDA';
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
        msafi.dsp_control.writelog ( 'INFO'
                                   , p_i_texto );
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

    FUNCTION executar ( p_data_fechamento VARCHAR2
                      , p_nome_planilha VARCHAR2
                      , p_concatena_id VARCHAR2 )
        RETURN INTEGER
    IS
        mproc_id INTEGER;
        i1 INTEGER;

        v_proc_status NUMBER := 0;
        v_s_proc_status VARCHAR2 ( 16 );

        v_txt_temp VARCHAR2 ( 1024 ) := '';
        v_txt_basico VARCHAR2 ( 256 ) := '';

        --Variaveis genericas
        v_text01 VARCHAR2 ( 512 );
        v_sep VARCHAR2 ( 1 ) := '|';
        v_saida_entrada VARCHAR2 ( 1 );
        v_size NUMBER := 0;
        v_count NUMBER := 0;
    BEGIN
        mproc_id :=
            lib_proc.new ( 'DPSP_REL_VALIDA_CPROC'
                         , 48
                         , 150 );
        lib_proc.add_tipo ( mproc_id
                          , 1
                          , 'Processo'
                          , 1 );
        lib_proc.add_header ( 'Executar relatório de NFs do VALIDA'
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

        msafi.dsp_control.createprocess ( 'DPSP_REL_VALIDA' --P_I_PROCID            IN VARCHAR2             , --VARCHAR2(16)
                                        , 'EXEC REL VALIDA' --P_I_PROC_DESCR        IN VARCHAR2             , --VARCHAR2(64)
                                        , NULL --P_I_DATA_INI          IN DATE     DEFAULT NULL,
                                        , NULL --P_I_DATA_FIM          IN DATE     DEFAULT NULL,
                                        , p_data_fechamento --P_I_DETALHES1         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , SUBSTR ( p_nome_planilha
                                                 , 1
                                                 , 32 ) --P_I_DETALHES2         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , p_concatena_id --P_I_DETALHES3         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , NULL --P_I_DETALHES4         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , musuario --P_I_USER              IN VARCHAR2 DEFAULT NULL  --VARCHAR2(64)
                                                   );
        v_proc_status := 1; --EM PROCESSO

        loga ( 'Imprimindo relatório' );
        loga ( ' ' );

        lib_proc.add_header ( 'Relatório de Notas Fiscais do VALIDA'
                            , 1
                            , 1 );
        lib_proc.add_header ( ' ' );
        lib_proc.add (
                       'ESTAB |UF|DT FISCAL |ID PEOPLE |NF    |LINHA|CFOP|FIN|CST|VLR CONTAB |VLR ITEM   |BASE TRIB  |BASE ISENTA|BASE OUTRAS|BS REDUCAO |VLR ICMS ST| VLR OUTRAS|'
        );
        lib_proc.add (
                       '------|--|----------|----------|------|-----|----|---|---|-----------|-----------|-----------|-----------|-----------|-----------|-----------|-----------|'
        );

        --            DSP001|SP|26/10/2016|1234567890|123456|12345|2101|CON|123|12345678.90|12345678.90|12345678.90|12345678.90|12345678.90|12345678.90|12345678.90|12345678.90|

        BEGIN
            SELECT b.saida_entrada
                 , LENGTH ( b.cod_uf_estab )
              INTO v_saida_entrada
                 , v_size
              FROM msafi.dsp_valida_hdr a
                 , msafi.dsp_valida_ln b
             WHERE a.controle_id = b.controle_id
               AND a.data_fechamento = p_data_fechamento
               AND b.concatenacao = p_concatena_id
               AND REPLACE ( REPLACE ( UPPER ( a.nome_arquivo )
                                     , '.XLSX'
                                     , '' )
                           , '.XLS'
                           , '' ) = REPLACE ( REPLACE ( UPPER ( p_nome_planilha )
                                                      , '.XLSX'
                                                      , '' )
                                            , '.XLS'
                                            , '' );
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                v_size := 0;
        END;

        IF ( v_size = 0
         OR v_size IS NULL ) THEN
            lib_proc.add ( 'Não foram encontrados dados para os paramêtros informados! (0)' );
        END IF;

        --ENTRADA CD ---------------------------------
        IF ( v_saida_entrada = 'E'
        AND v_size > 2 ) THEN
            loga ( 'Abrindo cursor C_VALIDA_ENTRADA_CD' );

            FOR cr_vecd IN c_valida_entrada_cd ( mcod_empresa
                                               , p_data_fechamento
                                               , p_nome_planilha
                                               , p_concatena_id ) LOOP
                v_text01 :=
                    fazcampo ( cr_vecd.cod_estab
                             , ' '
                             , 6 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_vecd.cod_estado
                                , ' '
                                , 2 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_vecd.data_fiscal
                                , 'DD/MM/YYYY'
                                , ' '
                                , 10 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_vecd.num_controle_docto
                                , ' '
                                , 10 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_vecd.num_docfis
                                , ' '
                                , 6 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_vecd.num_item
                                , ' '
                                , 5 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_vecd.cod_cfo
                                , ' '
                                , 4 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_vecd.cod_natureza_op
                                , ' '
                                , 3 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_vecd.cod_situacao_b
                                , ' '
                                , 3 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_vecd.vlr_contab_item
                                , ' '
                                , 11 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_vecd.vlr_item
                                , ' '
                                , 11 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_vecd.vlr_base_icms_1
                                , ' '
                                , 11 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_vecd.vlr_base_icms_2
                                , ' '
                                , 11 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_vecd.vlr_base_icms_3
                                , ' '
                                , 11 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_vecd.vlr_base_icms_4
                                , ' '
                                , 11 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_vecd.vlr_tributo_icmss
                                , ' '
                                , 11 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_vecd.vlr_outras
                                , ' '
                                , 11 );
                v_text01 := v_text01 || v_sep;
                lib_proc.add ( v_text01 );
                v_count := v_count + 1;
            END LOOP;

            lib_proc.add (
                           '------|--|----------|----------|------|-----|----|---|---|-----------|-----------|-----------|-----------|-----------|-----------|-----------|-----------|'
            );
            lib_proc.add ( 'TOTAL DE LINHAS: ' || v_count );
        END IF;

        --ENTRADA LOJAS ------------------------------
        IF ( v_saida_entrada = 'E'
        AND v_size = 2 ) THEN
            loga ( 'Abrindo cursor C_VALIDA_ENTRADA_LOJA' );

            FOR cr_veloja IN c_valida_entrada_loja ( mcod_empresa
                                                   , p_data_fechamento
                                                   , p_nome_planilha
                                                   , p_concatena_id ) LOOP
                v_text01 :=
                    fazcampo ( cr_veloja.cod_estab
                             , ' '
                             , 6 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_veloja.cod_estado
                                , ' '
                                , 2 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_veloja.data_fiscal
                                , 'DD/MM/YYYY'
                                , ' '
                                , 10 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_veloja.num_controle_docto
                                , ' '
                                , 10 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_veloja.num_docfis
                                , ' '
                                , 6 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_veloja.num_item
                                , ' '
                                , 5 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_veloja.cod_cfo
                                , ' '
                                , 4 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_veloja.cod_natureza_op
                                , ' '
                                , 3 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_veloja.cod_situacao_b
                                , ' '
                                , 3 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_veloja.vlr_contab_item
                                , ' '
                                , 11 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_veloja.vlr_item
                                , ' '
                                , 11 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_veloja.vlr_base_icms_1
                                , ' '
                                , 11 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_veloja.vlr_base_icms_2
                                , ' '
                                , 11 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_veloja.vlr_base_icms_3
                                , ' '
                                , 11 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_veloja.vlr_base_icms_4
                                , ' '
                                , 11 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_veloja.vlr_tributo_icmss
                                , ' '
                                , 11 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_veloja.vlr_outras
                                , ' '
                                , 11 );
                v_text01 := v_text01 || v_sep;
                lib_proc.add ( v_text01 );
                v_count := v_count + 1;
            END LOOP;

            lib_proc.add (
                           '------|--|----------|----------|------|-----|----|---|---|-----------|-----------|-----------|-----------|-----------|-----------|-----------|-----------|'
            );
            lib_proc.add ( 'TOTAL DE LINHAS: ' || v_count );
        END IF;

        --SAIDA CD -----------------------------------
        IF ( v_saida_entrada = 'S'
        AND v_size > 2 ) THEN
            loga ( 'Abrindo cursor C_VALIDA_SAIDA_CD' );

            FOR cr_vscd IN c_valida_saida_cd ( mcod_empresa
                                             , p_data_fechamento
                                             , p_nome_planilha
                                             , p_concatena_id ) LOOP
                v_text01 :=
                    fazcampo ( cr_vscd.cod_estab
                             , ' '
                             , 6 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_vscd.cod_estado
                                , ' '
                                , 2 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_vscd.data_fiscal
                                , 'DD/MM/YYYY'
                                , ' '
                                , 10 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_vscd.num_controle_docto
                                , ' '
                                , 10 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_vscd.num_docfis
                                , ' '
                                , 6 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_vscd.num_item
                                , ' '
                                , 5 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_vscd.cod_cfo
                                , ' '
                                , 4 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_vscd.cod_natureza_op
                                , ' '
                                , 3 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_vscd.cod_situacao_b
                                , ' '
                                , 3 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_vscd.vlr_contab_item
                                , ' '
                                , 11 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_vscd.vlr_item
                                , ' '
                                , 11 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_vscd.vlr_base_icms_1
                                , ' '
                                , 11 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_vscd.vlr_base_icms_2
                                , ' '
                                , 11 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_vscd.vlr_base_icms_3
                                , ' '
                                , 11 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_vscd.vlr_base_icms_4
                                , ' '
                                , 11 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_vscd.vlr_tributo_icmss
                                , ' '
                                , 11 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_vscd.vlr_outras
                                , ' '
                                , 11 );
                v_text01 := v_text01 || v_sep;
                lib_proc.add ( v_text01 );
                v_count := v_count + 1;
            END LOOP;

            lib_proc.add (
                           '------|--|----------|----------|------|-----|----|---|---|-----------|-----------|-----------|-----------|-----------|-----------|-----------|-----------|'
            );
            lib_proc.add ( 'TOTAL DE LINHAS: ' || v_count );
        END IF;

        --SAIDA LOJAS --------------------------------
        IF ( v_saida_entrada = 'S'
        AND v_size = 2 ) THEN
            loga ( 'Abrindo cursor C_VALIDA_SAIDA_LOJA' );

            FOR cr_vsloja IN c_valida_saida_loja ( mcod_empresa
                                                 , p_data_fechamento
                                                 , p_nome_planilha
                                                 , p_concatena_id ) LOOP
                v_text01 :=
                    fazcampo ( cr_vsloja.cod_estab
                             , ' '
                             , 6 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_vsloja.cod_estado
                                , ' '
                                , 2 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_vsloja.data_fiscal
                                , 'DD/MM/YYYY'
                                , ' '
                                , 10 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_vsloja.num_controle_docto
                                , ' '
                                , 10 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_vsloja.num_docfis
                                , ' '
                                , 6 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_vsloja.num_item
                                , ' '
                                , 5 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_vsloja.cod_cfo
                                , ' '
                                , 4 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_vsloja.cod_natureza_op
                                , ' '
                                , 3 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_vsloja.cod_situacao_b
                                , ' '
                                , 3 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_vsloja.vlr_contab_item
                                , ' '
                                , 11 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_vsloja.vlr_item
                                , ' '
                                , 11 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_vsloja.vlr_base_icms_1
                                , ' '
                                , 11 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_vsloja.vlr_base_icms_2
                                , ' '
                                , 11 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_vsloja.vlr_base_icms_3
                                , ' '
                                , 11 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_vsloja.vlr_base_icms_4
                                , ' '
                                , 11 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_vsloja.vlr_tributo_icmss
                                , ' '
                                , 11 );
                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_vsloja.vlr_outras
                                , ' '
                                , 11 );
                v_text01 := v_text01 || v_sep;
                lib_proc.add ( v_text01 );
                v_count := v_count + 1;
            END LOOP;

            lib_proc.add (
                           '------|--|----------|----------|------|-----|----|---|---|-----------|-----------|-----------|-----------|-----------|-----------|-----------|-----------|'
            );
            lib_proc.add ( 'TOTAL DE LINHAS: ' || v_count );
        END IF;

        lib_proc.add (
                       '------|--|----------|----------|------|-----|----|---|---|-----------|-----------|-----------|-----------|-----------|-----------|-----------|-----------|'
        );
        lib_proc.add ( ' ' );
        loga ( 'Fim do relatório!' );
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

        loga ( 'FIM DO PROCESSAMENTO, STATUS FINAL: [' || v_s_proc_status || ']' );
        lib_proc.add ( 'FIM DO PROCESSAMENTO, STATUS FINAL: [' || v_s_proc_status || ']' );
        lib_proc.add ( 'Favor verificar LOG para detalhes.' );
        msafi.dsp_control.updateprocess ( v_s_proc_status );

        lib_proc.close ( );

        COMMIT;
        RETURN mproc_id;
    EXCEPTION
        WHEN OTHERS THEN
            msafi.dsp_control.log_checkpoint ( SQLERRM
                                             , 'Erro não tratado, executador de interfaces' );
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
END dpsp_rel_valida_cproc;
/
SHOW ERRORS;
