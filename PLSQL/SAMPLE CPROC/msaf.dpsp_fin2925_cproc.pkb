Prompt Package Body DPSP_FIN2925_CPROC;
--
-- DPSP_FIN2925_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_fin2925_cproc
IS
    mproc_id INTEGER;
    v_quant_empresas INTEGER := 50;

    v_class VARCHAR2 ( 1 ) := 'a';

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
                             || ''' AND B.IDENT_ESTADO = A.IDENT_ESTADO AND A.COD_EMPRESA = C.COD_EMPRESA AND A.COD_ESTAB = C.COD_ESTAB AND B.COD_ESTADO LIKE :3  ORDER BY B.COD_ESTADO, A.COD_ESTAB'
        );

        RETURN pstr;
    END; --FUNCTION PARAMETROS RETURN VARCHAR2 IS

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Geração do Novo bloco 1050 - EFD Contribuições';
    END;

    FUNCTION tipo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'EFD Contribuições';
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
        RETURN 'Carga para SAFX264';
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
        msafi.dsp_control.writelog ( 'INCENE'
                                   , p_i_texto );
        COMMIT;
    ---> Para acompanhar processamento usar SELECT abaixo
    --SELECT * FROM DSP_LOG
    --WHERE LOG_TYPE = 'INCER'
    --ORDER BY 3 DESC, 2 DESC
    END;

    FUNCTION moeda ( v_conteudo NUMBER )
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN TRIM ( TO_CHAR ( v_conteudo
                              , '9g999g999g990d00' ) );
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
            v_txt_email := 'ERRO no Processo de Ressarcimento de ST para NF de Incineração!';
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
            v_assunto := 'Mastersaf - Relatório de Ressarcimento de ST para NF de Incineração ERRO';
        -- NOTIFICA('', 'S', V_ASSUNTO, V_TXT_EMAIL, 'DPSP_OUT_RES_STNF_CPROC');

        ELSE
            v_txt_email := 'Processo de Ressarcimento de ST para NF de Incineração com SUCESSO.';
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
            v_assunto := 'Mastersaf - EFT - FIN - 2529 - Novo bloco 1050 - EFD Contribuições';
        --NOTIFICA('S', '', V_ASSUNTO, V_TXT_EMAIL, 'DPSP_OUT_RES_STNF_CPROC');

        END IF;
    END;

    /*********************************************************************************Inicio - Create Table1***********************************************************************************/



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
        vp_tab_dev_inc VARCHAR2 ( 30 );
        vp_tab_dev_inc2 VARCHAR2 ( 30 );
        vp_tab_dev_inc3 VARCHAR2 ( 30 );
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
        v_text01 VARCHAR2 ( 4000 );
    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS='',.'' ';

        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        musuario := lib_parametros.recuperar ( 'USUARIO' );


        mproc_id :=
            lib_proc.new ( 'DPSP_FIN2925_CPROC'
                         , 48
                         , 150 );
        lib_proc.add_tipo ( mproc_id
                          , 1
                          ,    TO_CHAR ( SYSDATE
                                       , 'YYYYMMDDHH24MISS' )
                            || '_INC_TABLE'
                          , 1 );
        --MARCAR INCIO DA EXECUCAO
        vp_data_hora_ini :=
            TO_CHAR ( SYSDATE
                    , 'DD/MM/YYYY HH24:MI.SS' );

        lib_proc.add_header ( 'Processo de carga da SAFX264 realizado com sucesso!'
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
        loga (    '<< PERIODO DE: '
               || '01/'
               || TO_CHAR ( v_data_inicial
                          , 'MM/YYYY' )
               || ' A '
               || LAST_DAY ( v_data_final )
               || ' >>'
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


        --GERAR CHAVE PROC_ID
        SELECT ROUND ( dbms_random.VALUE ( 10000000000000
                                         , 999999999999999 ) )
          INTO vp_proc_instance
          FROM DUAL;

        --CRIA TABELA 1


        EXECUTE IMMEDIATE 'TRUNCATE TABLE SAFX264 ';



        BEGIN
            loga ( '>>> EFD Contribuições ' || vp_proc_instance
                 , FALSE );

            lib_proc.add_tipo ( mproc_id
                              , 99
                              , mcod_empresa || '_REL_FIN2529.XLS'
                              , 2 );
            lib_proc.add ( dsp_planilha.header
                         , ptipo => 99 );
            lib_proc.add ( dsp_planilha.tabela_inicio
                         , ptipo => 99 );
            lib_proc.add ( dsp_planilha.linha ( p_conteudo => dsp_planilha.campo (
                                                                                   'EFD Contribuições'
                                                                                 , p_custom => 'COLSPAN=25 BGCOLOR=#000086'
                                                             )
                                              , p_class => 'h' )
                         , ptipo => 99 );
            lib_proc.add ( dsp_planilha.linha (
                                                p_conteudo =>    dsp_planilha.campo ( 'COD_EMPRESA' )
                                                              || dsp_planilha.campo ( 'COD_ESTAB' )
                                                              || dsp_planilha.campo ( 'DATA_APUR' )
                                                              || dsp_planilha.campo ( 'DATA_REFER' )
                                                              || dsp_planilha.campo ( 'CNPJ' )
                                                              || dsp_planilha.campo ( 'VLR_TOT_AJUSTE' )
                                              , p_class => 'h'
                           )
                         , ptipo => 99 );
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
                                        , '!ERRO SELECT EFD Contribuições!' );
        END;



        --EXECUTAR UM P_COD_ESTAB POR VEZ
        FOR est IN a_estabs.FIRST .. a_estabs.COUNT --(1)
                                                   LOOP
            loga ( '>> LOJA: ' || a_estabs ( est ) || ' PROC  EFD - 1050: ' || vp_proc_instance
                 , FALSE );

            --  Novo bloco 1050 - EFD Contribuições



            DECLARE
                CURSOR rc_safx264
                IS
                    SELECT *
                      FROM ( SELECT   a.cod_estab AS cod_estab
                                    , a.uf_estab AS uf_estab
                                    , --   LAST_DAY(TRUNC(A.DATA_FISCAL))                                  AS DATA_FISCAL,
                                      c.cgc AS cgc
                                    , -- A.COD_NATUREZA_OP_E                                             AS COD_NATUREZA_OP_E,
                                      DECODE ( b.lista,  'P', 'POSITIVA',  'N', 'NEGATIVA',  'O', 'NEUTRA',  '-' )
                                          AS lista
                                    , SUM ( a.vlr_icms_unit ) AS vlr_icms_unit
                                    , SUM ( a.vlr_icms_st_unit ) AS vlr_icms_st_unit
                                    , SUM ( a.vlr_icms_st_unit_aux ) AS vlr_icms_st_unit_aux
                                    , SUM (
                                            CASE
                                                WHEN a.cod_cfo = '5405' THEN
                                                    CASE
                                                        WHEN ( a.vlr_icmss_e > 0
                                                           OR a.vlr_icmss_n_escrit > 0 )
                                                          OR ( a.uf_estab = 'SP'
                                                          AND a.cod_cfo_e = '1409'
                                                          AND a.vlr_icms_unit > 0 ) THEN
                                                            CASE
                                                                WHEN a.vlr_icms_st_unit > 0 THEN
                                                                      ( a.vlr_icms_unit + a.vlr_icms_st_unit )
                                                                    * a.quantidade
                                                                ELSE
                                                                      ( a.vlr_icms_unit + a.vlr_icms_st_unit_aux )
                                                                    * a.quantidade
                                                            END
                                                        ELSE
                                                            0
                                                    END
                                                ELSE
                                                    CASE WHEN a.cod_cfo = '5102' THEN a.vlr_icms ELSE 0 END
                                            END
                                      )
                                          AS vlr_calculado
                                 FROM msaf.dpsp_ex_bpc_uentr a
                                    , (SELECT cod_produto
                                            , lista
                                            , RANK ( )
                                                  OVER ( PARTITION BY cod_produto
                                                         ORDER BY effdt DESC )
                                                  RANK
                                         FROM msaf.dpsp_ps_lista) b
                                    , estabelecimento c
                                WHERE c.cod_empresa = a.cod_empresa
                                  AND c.cod_estab = a.cod_estab
                                  AND a.cod_produto = b.cod_produto
                                  AND b.RANK = 1
                                  AND a.data_fiscal BETWEEN    '01/'
                                                            || TO_CHAR ( v_data_inicial
                                                                       , 'MM/YYYY' )
                                                        AND LAST_DAY ( v_data_final )
                                  AND a.cod_estab = a_estabs ( est )
                                  AND a.cod_empresa = mcod_empresa
                                  AND a.uf_estab LIKE p_uf
                             GROUP BY a.cod_estab
                                    , a.uf_estab
                                    , c.cgc
                                    , -- A.COD_NATUREZA_OP_E,
                                     DECODE ( b.lista,  'P', 'POSITIVA',  'N', 'NEGATIVA',  'O', 'NEUTRA',  '-' )
                             ORDER BY 2
                                    , 1
                                    , 3
                                    , 4 )
                     WHERE lista = 'NEUTRA';

                safx264_type safx264%ROWTYPE;

                l_vlr_rec DECIMAL;
            BEGIN
                FOR i IN rc_safx264 LOOP
                    safx264_type.cod_empresa := mcod_empresa; --  PARAMETRO
                    safx264_type.cod_estab := a_estabs ( est ); -- PARAMETRO
                    safx264_type.mes_ano_apur :=
                        TO_CHAR ( v_data_final
                                , 'YYYYMM' ); --
                    safx264_type.data_refer :=
                        saf_format_campo ( 'X264_DET_AJ_BC_VAL_EXTRA'
                                         , 'DATA_REFER'
                                         , LAST_DAY ( v_data_final ) );
                    safx264_type.cnpj :=
                        saf_format_campo ( 'X264_DET_AJ_BC_VAL_EXTRA'
                                         , 'CNPJ'
                                         , i.cgc );
                    safx264_type.ind_natureza := '41';
                    safx264_type.ind_aprop_ajuste := '01';
                    safx264_type.vlr_tot_ajuste :=
                        saf_format_campo ( 'X264_DET_AJ_BC_VAL_EXTRA'
                                         , 'VLR_TOT_AJUSTE'
                                         , i.vlr_calculado );
                    safx264_type.vlr_aj_cst01 :=
                        saf_format_campo ( 'X264_DET_AJ_BC_VAL_EXTRA'
                                         , 'VLR_AJ_CST01'
                                         , i.vlr_calculado );
                    safx264_type.vlr_aj_cst02 := 0;
                    safx264_type.vlr_aj_cst03 := 0;
                    safx264_type.vlr_aj_cst04 := 0;
                    safx264_type.vlr_aj_cst05 := 0;
                    safx264_type.vlr_aj_cst06 := 0;
                    safx264_type.vlr_aj_cst07 := 0;
                    safx264_type.vlr_aj_cst08 := 0;
                    safx264_type.vlr_aj_cst09 := 0;
                    safx264_type.vlr_aj_cst49 := 0;
                    safx264_type.vlr_aj_cst99 := 0;
                    safx264_type.num_recibo := '@';
                    safx264_type.dsc_inf_compl := '@';
                    safx264_type.dat_gravacao := TRUNC ( SYSDATE );

                    INSERT INTO safx264
                    VALUES safx264_type;

                    COMMIT;



                    BEGIN
                        IF v_class = 'a' THEN
                            v_class := 'b';
                        ELSE
                            v_class := 'a';
                        END IF;

                        v_text01 :=
                            dsp_planilha.linha (
                                                 p_conteudo =>    dsp_planilha.campo ( safx264_type.cod_empresa )
                                                               || dsp_planilha.campo ( safx264_type.cod_estab )
                                                               || dsp_planilha.campo ( safx264_type.mes_ano_apur )
                                                               || dsp_planilha.campo ( v_data_final )
                                                               || dsp_planilha.campo ( dsp_planilha.texto ( i.cgc ) )
                                                               || dsp_planilha.campo ( i.vlr_calculado )
                                               , p_class => v_class
                            );
                        lib_proc.add ( v_text01
                                     , ptipo => 99 );
                    --
                    END;
                END LOOP;
            END;
        END LOOP; --(1)



        loga ( '---FIM DO PROCESSAMENTO [SUCESSO]---'
             , FALSE );

        --ENVIAR EMAIL DE SUCESSO----------------------------------------
        --ENVIA_EMAIL(MCOD_EMPRESA, V_DATA_INICIAL, V_DATA_FINAL, '', 'S', VP_DATA_HORA_INI);
        -----------------------------------------------------------------

        lib_proc.add ( 'FIM DO PROCESSAMENTO [SUCESSO]' );
        lib_proc.add ( 'Favor verificar LOG para detalhes.' );
        lib_proc.close;
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

            --ENVIAR EMAIL DE ERRO-------------------------------------------
            --ENVIA_EMAIL(MCOD_EMPRESA, V_DATA_INICIAL, V_DATA_FINAL, SQLERRM, 'E', V_DATA_HORA_INI);
            -----------------------------------------------------------------

            lib_proc.close;
            COMMIT;
            RETURN mproc_id;
    END; /* FUNCTION EXECUTAR */
END dpsp_fin2925_cproc;
/
SHOW ERRORS;
