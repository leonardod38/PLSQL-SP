Prompt Package Body DSP_REL_CONF_NF_SAIDA_CPROC;
--
-- DSP_REL_CONF_NF_SAIDA_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dsp_rel_conf_nf_saida_cproc
IS
    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );
        vcfop VARCHAR2 ( 1000 );
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
                           , 'DATA INICIAL'
                           , --P_DATA_INI
                            'DATE'
                           , 'TEXTBOX'
                           , 'S'
                           , NULL
                           , 'DD/MM/YYYY' );

        lib_proc.add_param ( pstr
                           , 'DATA FINAL'
                           , --P_DATA_FIM
                            'DATE'
                           , 'TEXTBOX'
                           , 'S'
                           , NULL
                           , 'DD/MM/YYYY' );

        vcfop :=
               ' SELECT A.COD_CFO, A.DESCRICAO '
            || ' FROM X2012_COD_FISCAL A '
            || ' WHERE A.VALID_CFO = (SELECT MAX(B.VALID_CFO) '
            || '                      FROM X2012_COD_FISCAL B '
            || '                      WHERE B.COD_CFO = A.COD_CFO '
            || '                        AND B.VALID_CFO <= SYSDATE) '
            || '   AND (   A.COD_CFO LIKE ''4%'' '
            || '        OR A.COD_CFO LIKE ''5%'' '
            || '        OR A.COD_CFO LIKE ''6%'') '
            || ' ORDER BY 1';

        lib_proc.add_param ( pstr
                           , 'CFOP (1):'
                           , --P_CFOP1
                            'VARCHAR2'
                           , 'TEXTBOX'
                           , 'S'
                           , NULL
                           , '      '
                           , vcfop
                           , 'S' );

        lib_proc.add_param ( pstr
                           , 'CFOP (2):'
                           , --P_CFOP2
                            'VARCHAR2'
                           , 'TEXTBOX'
                           , 'N'
                           , NULL
                           , '      '
                           , vcfop
                           , 'S' );

        lib_proc.add_param ( pstr
                           , 'CFOP (3):'
                           , --P_CFOP3
                            'VARCHAR2'
                           , 'TEXTBOX'
                           , 'N'
                           , NULL
                           , '      '
                           , vcfop
                           , 'S' );

        lib_proc.add_param ( pstr
                           , 'CFOP (4):'
                           , --P_CFOP4
                            'VARCHAR2'
                           , 'TEXTBOX'
                           , 'N'
                           , NULL
                           , '      '
                           , vcfop
                           , 'S' );

        lib_proc.add_param (
                             pstr
                           , 'ESTABELECIMENTO'
                           , --P_CODESTAB
                            'VARCHAR2'
                           , 'MULTISELECT'
                           , 'N'
                           , 'S'
                           , NULL
                           ,    '
                            SELECT A.COD_ESTAB, A.COD_ESTAB || '' - '' || B.COD_ESTADO || '' - '' || A.CGC || '' - '' || INITCAP(A.BAIRRO) || '' / '' || INITCAP(A.CIDADE)
                            FROM ESTABELECIMENTO A, ESTADO B
                            WHERE A.COD_EMPRESA  = '''
                             || mcod_empresa
                             || '''
                            AND   B.IDENT_ESTADO = A.IDENT_ESTADO
                            ORDER BY B.COD_ESTADO, A.COD_ESTAB
                           '
        );

        RETURN pstr;
    END; --FUNCTION PARAMETROS RETURN VARCHAR2 IS

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'RELATÓRIO CONFERÊNCIA NOTAS FISCAIS DE SAÍDA';
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
        RETURN 'VERSAO 1.2';
    END;

    FUNCTION descricao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Pesquisa por Período, CFOP e Estabelecimento';
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

    FUNCTION executar ( p_data_ini DATE
                      , p_data_fim DATE
                      , p_cfop1 VARCHAR2
                      , p_cfop2 VARCHAR2
                      , p_cfop3 VARCHAR2
                      , p_cfop4 VARCHAR2
                      , p_codestab lib_proc.vartab )
        RETURN INTEGER
    IS
        mproc_id INTEGER;
        i1 INTEGER;

        v_sep VARCHAR2 ( 1 );

        v_proc_status NUMBER := 0;
        v_s_proc_status VARCHAR2 ( 16 );

        --Variaveis genericas
        v_text01 VARCHAR2 ( 512 );
        v_text02 VARCHAR2 ( 256 );
    --

    BEGIN
        msafi.dsp_aux.truncatabela_msafi ( 'DSP_PROC_ESTABS' );

        v_sep := '|';

        mproc_id :=
            lib_proc.new ( 'DSP_REL_CONF_NF_SAIDA_CPROC'
                         , 48
                         , 150 );
        lib_proc.add_tipo ( mproc_id
                          , 1
                          , 'Processo'
                          , 1
                          , pmaxcols => 150 );

        IF mcod_empresa IS NULL THEN
            lib_proc.add_log ( 'Código da empresa deve ser informado como parâmetro global.'
                             , 0 );
            lib_proc.close;
            RETURN mproc_id;
        END IF;

        msafi.dsp_control.createprocess ( 'CUST_RELNFSAIDA' --P_I_PROCID            IN VARCHAR2             , --VARCHAR2(16)
                                        , 'CUSTOMIZADO MASTERSAF: RELATORIO CONF NF SAIDA' --P_I_PROC_DESCR        IN VARCHAR2             , --VARCHAR2(64)
                                        , p_data_ini --P_I_DATA_INI          IN DATE     DEFAULT NULL,
                                        , p_data_fim --P_I_DATA_FIM          IN DATE     DEFAULT NULL,
                                        , p_codestab.COUNT --P_I_DETALHES1         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , NULL --P_I_DETALHES2         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , NULL --P_I_DETALHES3         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , NULL --P_I_DETALHES4         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , musuario --P_I_USER              IN VARCHAR2 DEFAULT NULL  --VARCHAR2(64)
                                                   );
        v_proc_status := 1; --EM PROCESSO

        IF ( p_codestab.COUNT > 0 ) THEN
            i1 := p_codestab.FIRST;

            WHILE i1 IS NOT NULL LOOP
                loga ( p_codestab ( i1 ) );

                INSERT INTO msafi.dsp_proc_estabs
                     VALUES ( p_codestab ( i1 ) );

                i1 := p_codestab.NEXT ( i1 );
            END LOOP;

            COMMIT;
        ELSE
            lib_proc.add_log ( 'ATENÇÃO - Informe ao menos 1 (um) Estabelecimento para a execução do relatório.'
                             , 0 );
            lib_proc.close;
            RETURN mproc_id;
        END IF;

        ----------------------------------------------------------------------------------------------------------
        loga ( 'Imprimindo relatório' );
        lib_proc.add_header ( 'DPSP - Conferência de Notas Fiscais de Saída'
                            , 1
                            , 1 );
        lib_proc.add_header ( ' ' );
        lib_proc.add (
                       ' ESTAB| DT FISCAL|    NF   |SERIE| ID PEOPLE|   COD FIS JUR|CFOP|FIN|CST| BASE TRIB|   ALIQ|  VLR ICMS|VLR ISENTA|VLR OUTRAS|   REDUCAO|CHAVE DE ACESSO                               |'
        );
        lib_proc.add (
                       '------|----------|---------|-----|----------|--------------|----|---|---|----------|-------|----------|----------|----------|----------|----------------------------------------------|'
        );
        --DSP029|07/06/2013|000003444|    1|0000000001|        DSP910|5209|IST|060|1234567,89|  12,20|1234567,89|1234567,89|1234567,89|1234567,89|'35160161412110000155550010000063121585046894'|

        loga ( 'Abrindo cursor' );

        FOR cr_rel IN c_relatorio_nf_saida ( p_data_ini
                                           , p_data_fim
                                           , p_cfop1
                                           , p_cfop2
                                           , p_cfop3
                                           , p_cfop4 ) LOOP
            v_text01 :=
                fazcampo ( cr_rel.emitente
                         , ' '
                         , 6 );
            v_text01 :=
                   v_text01
                || v_sep
                || fazcampo ( cr_rel.data_fiscal
                            , 'DD/MM/YYYY'
                            , ' '
                            , 10 );
            ---V_TEXT01 := V_TEXT01 || V_SEP || FazCampo(CR_REL.EMISSAO               ,'DD/MM/YYYY',' ',10);
            ---V_TEXT01 := V_TEXT01 || V_SEP || FazCampo(CR_REL.MOVTO                              ,' ', 3);
            v_text01 :=
                   v_text01
                || v_sep
                || fazcampo ( cr_rel.nf
                            , ' '
                            , 9 );
            v_text01 :=
                   v_text01
                || v_sep
                || fazcampo ( cr_rel.serie
                            , ' '
                            , 5 );
            v_text01 :=
                   v_text01
                || v_sep
                || fazcampo ( cr_rel.id_people
                            , ' '
                            , 10 );
            v_text01 :=
                   v_text01
                || v_sep
                || fazcampo ( cr_rel.cod_fis_jur
                            , ' '
                            , 14 );
            ---V_TEXT01 := V_TEXT01 || V_SEP || FazCampo(CR_REL.RAZAO_SOCIAL                       ,' ',22);
            v_text01 :=
                   v_text01
                || v_sep
                || fazcampo ( cr_rel.cfop
                            , ' '
                            , 4 );
            v_text01 :=
                   v_text01
                || v_sep
                || fazcampo ( cr_rel.fin
                            , ' '
                            , 3 );
            v_text01 :=
                   v_text01
                || v_sep
                || fazcampo ( cr_rel.cst
                            , ' '
                            , 3 );
            v_text01 :=
                   v_text01
                || v_sep
                || fazcampo ( cr_rel.tributada
                            , 'FM9999990D00'
                            , ' '
                            , 10 );
            v_text01 :=
                   v_text01
                || v_sep
                || fazcampo ( cr_rel.aliq
                            , ' '
                            , 7 );
            v_text01 :=
                   v_text01
                || v_sep
                || fazcampo ( cr_rel.icms
                            , 'FM9999990D00'
                            , ' '
                            , 10 );
            v_text01 :=
                   v_text01
                || v_sep
                || fazcampo ( cr_rel.isenta
                            , 'FM9999990D00'
                            , ' '
                            , 10 );
            v_text01 :=
                   v_text01
                || v_sep
                || fazcampo ( cr_rel.outras
                            , 'FM9999990D00'
                            , ' '
                            , 10 );
            v_text01 :=
                   v_text01
                || v_sep
                || fazcampo ( cr_rel.reducao
                            , 'FM9999990D00'
                            , ' '
                            , 10 );
            v_text01 :=
                   v_text01
                || v_sep
                || fazcampo ( cr_rel.chave_de_acesso
                            , ' '
                            , 46 );
            v_text01 := v_text01 || v_sep;
            lib_proc.add ( v_text01 );
        END LOOP;

        --
        v_proc_status := 2; --SUCESSO
        ----------------------------------------------------------------------------------------------------------

        loga ( 'Fim do processo, limpando temporária de estabelecimentos' );
        msafi.dsp_aux.truncatabela_msafi ( 'DSP_PROC_ESTABS' );
        COMMIT;

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
    c_proc_9xx := '^' || mcod_empresa || '9[0-9]{2}$';
    c_proc_dep := '^' || mcod_empresa || '9[0-9][1-9]$';
    c_proc_loj :=
           '^'
        || mcod_empresa
        || '[0-8][0-9]{'
        || TO_CHAR ( 5 - LENGTH ( mcod_empresa )
                   , 'FM9' )
        || '}$';
    c_proc_est :=
           '^'
        || mcod_empresa
        || '[0-9]{3,'
        || TO_CHAR ( 6 - LENGTH ( mcod_empresa )
                   , 'FM9' )
        || '}$';
    c_proc_estvd :=
           '^VD[0-9]{3,'
        || TO_CHAR ( 6 - LENGTH ( mcod_empresa )
                   , 'FM9' )
        || '}$';
END dsp_rel_conf_nf_saida_cproc;
/
SHOW ERRORS;
