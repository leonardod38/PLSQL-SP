Prompt Package Body DSP_INTERFACES_CPROC;
--
-- DSP_INTERFACES_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dsp_interfaces_cproc
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
                           , 'Grupo de interfaces'
                           , --P_GRUPO
                            'VARCHAR2'
                           , 'COMBOBOX'
                           , 'S'
                           , NULL
                           , NULL
                           , '
                            SELECT ID_GRUPO,DESCRICAO
                            FROM MSAFI.DSP_GRUPOS
                            ORDER BY SEQ_EXIBICAO
                           '  );

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

        lib_proc.add_param ( pstr
                           , 'Cria job de importação'
                           , --P_CRIA_JOB
                            'VARCHAR2'
                           , 'CHECKBOX'
                           , 'N'
                           , NULL
                           , NULL );

        lib_proc.add_param ( pstr
                           , 'Fixo todos estabs (ALL)'
                           , --P_EXEC_ALL
                            'VARCHAR2'
                           , 'CHECKBOX'
                           , 'N'
                           , NULL
                           , NULL );

        lib_proc.add_param (
                             pstr
                           , 'ESTABELECIMENTO '
                           , --P_CODESTAB
                            'VARCHAR2'
                           , 'MULTISELECT'
                           , 'N'
                           , NULL
                           , NULL
                           ,    '
                            SELECT A.COD_ESTAB,A.COD_ESTAB || '' - '' || B.COD_ESTADO || '' - '' || A.CGC || '' - '' || INITCAP(A.BAIRRO) || '' / '' || INITCAP(A.CIDADE)
                            FROM ESTABELECIMENTO A, ESTADO B
                            WHERE A.COD_EMPRESA = '''
                             || mcod_empresa
                             || '''
                            AND   B.IDENT_ESTADO = A.IDENT_ESTADO
                            ORDER BY CASE WHEN A.COD_ESTAB LIKE '''
                             || mcod_empresa
                             || '9%'' THEN ''0'' || A.COD_ESTAB ELSE ''1'' || B.COD_ESTADO || A.COD_ESTAB END
                           '
        );

        RETURN pstr;
    END; --FUNCTION PARAMETROS RETURN VARCHAR2 IS

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Executar interfaces';
    END;

    FUNCTION tipo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Interfaces';
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
        RETURN 'Execução de interfaces PeopleSoft e DataHub';
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

    FUNCTION executar ( p_grupo VARCHAR2
                      , p_data_ini DATE
                      , p_data_fim DATE
                      , p_cria_job VARCHAR2
                      , p_exec_all VARCHAR2
                      , p_codestab lib_proc.vartab )
        RETURN INTEGER
    IS
        mproc_id INTEGER;
        iestab INTEGER;

        v_proc_status NUMBER := 0;
        v_s_proc_status VARCHAR2 ( 16 );

        --Variaveis genericas
        v_text01 VARCHAR2 ( 512 );
        v_requer_estab VARCHAR2 ( 1 );
        v_suporta_all VARCHAR2 ( 1 );
        v_data_ini VARCHAR2 ( 8 );
        v_data_fim VARCHAR2 ( 8 );
        v_cod_estab VARCHAR2 ( 6 );
        v_job_num NUMBER;
        v_estab_grupo VARCHAR2 ( 6 );
    BEGIN
        msafi.dsp_aux.truncatabela_msafi ( 'DSP_PROC_ESTABS' );

        mproc_id :=
            lib_proc.new ( 'DSP_INTERFACES_CPROC'
                         , 48
                         , 150 );
        lib_proc.add_tipo ( mproc_id
                          , 1
                          , 'Processo'
                          , 1 );
        lib_proc.add_header ( 'Execução de interfaces'
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
        ELSIF TRIM ( p_grupo ) IS NULL THEN
            lib_proc.add_log ( 'Grupo de interfaces é requerido.'
                             , 0 );
            lib_proc.add ( 'ERRO' );
            lib_proc.add ( 'Grupo de interfaces é requerido.' );
            lib_proc.close;
            RETURN mproc_id;
        ELSIF p_exec_all <> 'N'
          AND p_codestab.COUNT > 0 THEN
            lib_proc.add_log (
                               'Não pode marcar a opção "Fixo todos estabs" e escolher estabelecimentos ao mesmo tempo'
                             , 0
            );
            lib_proc.add_log ( 'Desmarque a opção "Fixo todos estabs" ou os estabelecimentos escolhidos'
                             , 0 );
            lib_proc.add ( 'ERRO' );
            lib_proc.add (
                           'Não pode marcar a opção "Fixo todos estabs" e escolher estabelecimentos ao mesmo tempo'
            );
            lib_proc.add ( 'Desmarque a opção "Fixo todos estabs" ou os estabelecimentos escolhidos' );
            lib_proc.close;
            RETURN mproc_id;
        ELSE
            SELECT descricao
                 , requer_estab
                 , suporta_all
              INTO v_text01
                 , v_requer_estab
                 , v_suporta_all
              FROM msafi.dsp_grupos
             WHERE id_grupo = p_grupo;

            IF v_suporta_all = 'N'
           AND p_exec_all <> 'N' THEN
                lib_proc.add_log ( 'Para este grupo, a opção "Fixo todos estabs" não é suportada. Desmarque.'
                                 , 0 );
                lib_proc.add ( 'ERRO' );
                lib_proc.add ( 'Para este grupo, a opção "Fixo todos estabs" não é suportada. Desmarque.' );
                lib_proc.close;
                RETURN mproc_id;
            ELSIF ( ( v_requer_estab = 'S' )
               AND ( p_exec_all = 'N'
                 OR p_codestab.COUNT <= 0 ) ) THEN
                lib_proc.add_log ( 'Para este grupo, estabelecimento é campo obrigatório.'
                                 , 0 );
                lib_proc.add ( 'ERRO' );
                lib_proc.add ( 'Para este grupo, estabelecimento é campo obrigatório.' );
                lib_proc.close;
                RETURN mproc_id;
            END IF;
        END IF;

        SELECT estab_grupo
          INTO v_estab_grupo
          FROM msafi.dsp_interface_setup
         WHERE cod_empresa = mcod_empresa; --NOVO PARAMETRO

        msafi.dsp_control.createprocess ( 'DSP_INTERFACE' --P_I_PROCID            IN VARCHAR2             , --VARCHAR2(16)
                                        , 'EXEC INTERFACES' --P_I_PROC_DESCR        IN VARCHAR2             , --VARCHAR2(64)
                                        , p_data_ini --P_I_DATA_INI          IN DATE     DEFAULT NULL,
                                        , p_data_fim --P_I_DATA_FIM          IN DATE     DEFAULT NULL,
                                        , p_grupo --P_I_DETALHES1         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , p_exec_all --P_I_DETALHES2         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , p_codestab.COUNT --P_I_DETALHES3         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , NULL --P_I_DETALHES4         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , musuario --P_I_USER              IN VARCHAR2 DEFAULT NULL  --VARCHAR2(64)
                                                   );
        v_proc_status := 1; --EM PROCESSO

        IF ( p_codestab.COUNT > 0 ) THEN
            iestab := p_codestab.FIRST;

            WHILE iestab IS NOT NULL LOOP
                INSERT INTO msafi.dsp_proc_estabs
                     VALUES ( p_codestab ( iestab ) );

                iestab := p_codestab.NEXT ( iestab );
            END LOOP;

            COMMIT;
        ELSIF p_exec_all = 'S' THEN
            INSERT INTO msafi.dsp_proc_estabs
                SELECT cod_estab
                  FROM estabelecimento
                 WHERE cod_empresa = mcod_empresa;
        END IF; --IF (P_CODESTAB.COUNT > 0) THEN

        ----------------------------------------------------------------------------------------------------------
        loga ( 'Inicio do processo' );

        -----------CREATE TABLE DSP_GRP_INTERFACES
        -----------(ID_GRUPO NUMBER(3)
        -----------,SEQ_EXECUCAO NUMBER(6)
        -----------,ID_INTERFACE NUMBER(3)
        -----------,TIPO_DATA_INICIAL NUMBER(1) --0 ou NULL=parametro 1=primeiro dia do mes da data inicial informada 2=01/01/1900 3=N dias antes da data inicial
        -----------,N_DIAS_DATA_INICIAL NUMBER(3) --Somente utilizado quando TIPO_DATA_INICIAL = 3
        -----------,TIPO_ESTAB NUMBER(1) --0 ou NULL=parametro 1=DSP900 fixo  2=ALL fixo
        -----------,TIPO_DATA_FINAL NUMBER(1) --0 ou NULL = parametro 1=ultimo dia do mes da data final 2=01/01/1900  3=data fixa
        -----------,DATA_FINAL_FIXA DATE --Somente utilizado quanto TIPO_DATA_FINAL = 3
        -----------);
        -----------CREATE TABLE DSP_INTERFACES
        -----------(ID_INTERFACE NUMBER
        -----------,NOME_PROC VARCHAR2(30)
        -----------,DESCRICAO VARCHAR2(64)
        -----------,NUM_PARAMETROS NUMBER(1) --0=sem parametros | 2=data inicial e final | 3=data ini, fim e empresa | 4=data_ini,data_fim,empresa,estab
        -----------,SUPORTA_ALL VARCHAR2(1)
        -----------,NOME_SAFX VARCHAR2(30)
        -----------);
        -----------    CURSOR EXEC_INTERFACES(P_I_ID_GRUPO IN NUMBER) IS
        -----------    SELECT DGI.TIPO_DATA_INICIAL,DGI.N_DIAS_DATA_INICIAL,DGI.TIPO_ESTAB,DGI.TIPO_DATA_FINAL,DGI.DATA_FINAL_FIXA
        -----------           DIF.NOME_PROC,DIF.DESCRICAO,DIF.NUM_PARAMETROS,DIF.SUPORTA_ALL,DIF.NOME_SAFX
        -----------    FROM  MSAFI.DSP_GRP_INTERFACES DGI, MSAFI.DSP_INTERFACES DIF
        -----------    WHERE DGI.ID_GRUPO = P_I_ID_GRUPO
        -----------    AND   DIF.ID_INTERFACE = DGI.ID_INTERFACE
        -----------    ORDER BY DGI.SEQ_EXECUCAO;
        FOR c1 IN exec_interfaces ( p_grupo ) LOOP
            ---Executar cada interface de acordo com o número de parametros definido na procedure
            CASE
                WHEN c1.num_parametros = 0 THEN
                    --Se não tem nenhum parametro, simplesmente executa
                    v_text01 := 'BEGIN MSAFI.' || c1.nome_proc || '(); END;';
                    loga ( 'Executando: ' || v_text01 );

                    EXECUTE IMMEDIATE v_text01;
                WHEN c1.num_parametros = 2 THEN
                    --Se tem dois parametros, são data inicial e data final
                    --Configurar data inicial de acordo com setup
                    CASE NVL ( c1.tipo_data_inicial, 0 )
                        WHEN 0 THEN
                            v_data_ini :=
                                TO_CHAR ( p_data_ini
                                        , 'YYYYMMDD' ); --0 ou NULL=parametro
                        WHEN 1 THEN
                            v_data_ini :=
                                   TO_CHAR ( p_data_ini
                                           , 'YYYYMM' )
                                || '01'; --1=primeiro dia do mes da data inicial informada
                        WHEN 2 THEN
                            v_data_ini := '19000101'; --2=01/01/1900
                        WHEN 3 THEN
                            v_data_ini :=
                                TO_CHAR ( p_data_ini - c1.n_dias_data_inicial
                                        , 'YYYYMMDD' ); --3=N dias antes da data inicial
                    END CASE;

                    --Configurar data final de acordo com setup
                    CASE NVL ( c1.tipo_data_final, 0 )
                        WHEN 0 THEN
                            v_data_fim :=
                                TO_CHAR ( p_data_fim
                                        , 'YYYYMMDD' ); --0 ou NULL=parametro
                        WHEN 1 THEN
                            v_data_fim :=
                                TO_CHAR ( LAST_DAY ( p_data_fim )
                                        , 'YYYYMMDD' ); --1=ultimo dia do mes da data final
                        WHEN 2 THEN
                            v_data_fim := '19000101'; --2=01/01/1900
                        WHEN 3 THEN
                            v_data_fim :=
                                TO_CHAR ( c1.data_final_fixa
                                        , 'YYYYMMDD' ); --3=data fixa
                    END CASE;

                    v_text01 :=
                        'BEGIN MSAFI.' || c1.nome_proc || '(''' || v_data_ini || ''',''' || v_data_fim || '''); END;';
                    loga ( 'Executando: ' || v_text01 );

                    EXECUTE IMMEDIATE v_text01;
                WHEN c1.num_parametros = 3 THEN
                    --Se tem dois parametros, são data inicial e data final
                    --Configurar data inicial de acordo com setup
                    CASE NVL ( c1.tipo_data_inicial, 0 )
                        WHEN 0 THEN
                            v_data_ini :=
                                TO_CHAR ( p_data_ini
                                        , 'YYYYMMDD' ); --0 ou NULL=parametro
                        WHEN 1 THEN
                            v_data_ini :=
                                   TO_CHAR ( p_data_ini
                                           , 'YYYYMM' )
                                || '01'; --1=primeiro dia do mes da data inicial informada
                        WHEN 2 THEN
                            v_data_ini := '19000101'; --2=01/01/1900
                        WHEN 3 THEN
                            v_data_ini :=
                                TO_CHAR ( p_data_ini - c1.n_dias_data_inicial
                                        , 'YYYYMMDD' ); --3=N dias antes da data inicial
                    END CASE;

                    --Configurar data final de acordo com setup
                    CASE NVL ( c1.tipo_data_final, 0 )
                        WHEN 0 THEN
                            v_data_fim :=
                                TO_CHAR ( p_data_fim
                                        , 'YYYYMMDD' ); --0 ou NULL=parametro
                        WHEN 1 THEN
                            v_data_fim :=
                                TO_CHAR ( LAST_DAY ( p_data_fim )
                                        , 'YYYYMMDD' ); --1=ultimo dia do mes da data final
                        WHEN 2 THEN
                            v_data_fim := '19000101'; --2=01/01/1900
                        WHEN 3 THEN
                            v_data_fim :=
                                TO_CHAR ( c1.data_final_fixa
                                        , 'YYYYMMDD' ); --3=data fixa
                    END CASE;

                    v_text01 :=
                           'BEGIN MSAFI.'
                        || c1.nome_proc
                        || '('''
                        || v_data_ini
                        || ''','''
                        || v_data_fim
                        || ''','''
                        || mcod_empresa
                        || '''); END;';
                    loga ( 'Executando: ' || v_text01 );

                    EXECUTE IMMEDIATE v_text01;
                WHEN c1.num_parametros = 4 THEN
                    --Se tem quatri parametros, são data inicial, data final, empresa e estabelecimento
                    --Configurar data inicial de acordo com setup
                    CASE NVL ( c1.tipo_data_inicial, 0 )
                        WHEN 0 THEN
                            v_data_ini :=
                                TO_CHAR ( p_data_ini
                                        , 'YYYYMMDD' ); --0 ou NULL=parametro
                        WHEN 1 THEN
                            v_data_ini :=
                                   TO_CHAR ( p_data_ini
                                           , 'YYYYMM' )
                                || '01'; --1=primeiro dia do mes da data inicial informada
                        WHEN 2 THEN
                            v_data_ini := '19000101'; --2=01/01/1900
                        WHEN 3 THEN
                            v_data_ini :=
                                TO_CHAR ( p_data_ini - c1.n_dias_data_inicial
                                        , 'YYYYMMDD' ); --3=N dias antes da data inicial
                    END CASE;

                    --Configurar data final de acordo com setup
                    CASE NVL ( c1.tipo_data_final, 0 )
                        WHEN 0 THEN
                            v_data_fim :=
                                TO_CHAR ( p_data_fim
                                        , 'YYYYMMDD' ); --0 ou NULL=parametro
                        WHEN 1 THEN
                            v_data_fim :=
                                TO_CHAR ( LAST_DAY ( p_data_fim )
                                        , 'YYYYMMDD' ); --1=ultimo dia do mes da data final
                        WHEN 2 THEN
                            v_data_fim := '19000101'; --2=01/01/1900
                        WHEN 3 THEN
                            v_data_fim :=
                                TO_CHAR ( c1.data_final_fixa
                                        , 'YYYYMMDD' ); --3=data fixa
                    END CASE;

                    IF ( ( c1.suporta_all = 'S'
                      AND p_exec_all = 'S' )
                     OR ( c1.tipo_estab = 2 ) ) THEN
                        v_text01 :=
                               'BEGIN MSAFI.'
                            || c1.nome_proc
                            || '('''
                            || v_data_ini
                            || ''','''
                            || v_data_fim
                            || ''','''
                            || mcod_empresa
                            || ''',''ALL''); END;';
                        loga ( 'Executando: ' || v_text01 );

                        EXECUTE IMMEDIATE v_text01;
                    ELSE
                        --Executar de acordo com o setup de estabelecimento
                        CASE NVL ( c1.tipo_estab, 0 )
                            WHEN 0 THEN --0 ou NULL=parametro
                                BEGIN
                                    ----                            loop na DSP_PROC_ESTABS where process_instance = MSAFI.DSP_CONTROL.PROCESS_INSTANCE
                                    FOR c2 IN ( SELECT cod_estab
                                                  FROM msafi.dsp_proc_estabs ) LOOP
                                        v_text01 :=
                                               'BEGIN MSAFI.'
                                            || c1.nome_proc
                                            || '('''
                                            || v_data_ini
                                            || ''','''
                                            || v_data_fim
                                            || ''','''
                                            || mcod_empresa
                                            || ''','''
                                            || c2.cod_estab
                                            || '''); END;';
                                        loga ( 'Executando: ' || v_text01 );

                                        EXECUTE IMMEDIATE v_text01;
                                    END LOOP; --FOR C2 IN (SELECT COD_ESTAB FROM MSAFI.DSP_PROC_ESTABS)
                                END;
                            WHEN 1 THEN --1=DSP900 fixo
                                BEGIN
                                    v_text01 :=
                                           'BEGIN MSAFI.'
                                        || c1.nome_proc
                                        || '('''
                                        || v_data_ini
                                        || ''','''
                                        || v_data_fim
                                        || ''','''
                                        || mcod_empresa
                                        || ''','''
                                        || v_estab_grupo
                                        || '''); END;';
                                    loga ( 'Executando: ' || v_text01 );

                                    EXECUTE IMMEDIATE v_text01;
                                END;
                        END CASE;
                    END IF; --IF (C1.SUPORTA_ALL = 'S' AND P_EXEC_ALL = 'S') THEN
            END CASE; --C1.NUM_PARAMETROS

            --Criar linha na tabela temporaria para criação do job
            IF ( p_cria_job = 'S'
            AND ( TRIM ( c1.nome_safx ) IS NOT NULL ) ) THEN
                CASE NVL ( c1.tipo_data_inicial, 0 )
                    WHEN 0 THEN
                        v_data_ini :=
                            TO_CHAR ( p_data_ini
                                    , 'YYYYMMDD' ); --0 ou NULL=parametro
                    WHEN 1 THEN
                        v_data_ini :=
                               TO_CHAR ( p_data_ini
                                       , 'YYYYMM' )
                            || '01'; --1=primeiro dia do mes da data inicial informada
                    WHEN 2 THEN
                        v_data_ini := '19000101'; --2=01/01/1900
                    WHEN 3 THEN
                        v_data_ini :=
                            TO_CHAR ( p_data_ini - c1.n_dias_data_inicial
                                    , 'YYYYMMDD' ); --3=N dias antes da data inicial
                END CASE;

                --Configurar data final de acordo com setup
                CASE NVL ( c1.tipo_data_final, 0 )
                    WHEN 0 THEN
                        v_data_fim :=
                            TO_CHAR ( p_data_fim
                                    , 'YYYYMMDD' ); --0 ou NULL=parametro
                    WHEN 1 THEN
                        v_data_fim :=
                            TO_CHAR ( LAST_DAY ( p_data_fim )
                                    , 'YYYYMMDD' ); --1=ultimo dia do mes da data final
                    WHEN 2 THEN
                        v_data_fim := '19000101'; --2=01/01/1900
                    WHEN 3 THEN
                        v_data_fim :=
                            TO_CHAR ( c1.data_final_fixa
                                    , 'YYYYMMDD' ); --3=data fixa
                END CASE;

                --Configurar estabelecimento de acordo com setup
                IF ( ( c1.suporta_all = 'S'
                  AND p_exec_all = 'S' )
                 OR ( c1.tipo_estab = 2 ) ) THEN
                    v_cod_estab := 'ALL';
                ELSE
                    CASE NVL ( c1.tipo_estab, 0 )
                        WHEN 0 THEN --0 ou NULL=parametro
                            BEGIN
                                SELECT COUNT ( cod_estab )
                                  INTO v_job_num
                                  FROM msafi.dsp_proc_estabs;

                                IF ( v_job_num = 1 ) THEN
                                    SELECT cod_estab
                                      INTO v_cod_estab
                                      FROM msafi.dsp_proc_estabs;
                                ELSE
                                    v_cod_estab := NULL;
                                END IF; --IF (V_COD_ESTAB = '1') THEN
                            END;
                        WHEN 1 THEN
                            v_cod_estab := v_estab_grupo; --1=DSP900 fixo
                    END CASE;
                END IF;

                INSERT INTO msafi.dsp_interfaces_temp ( process_instance
                                                      , parte
                                                      , safx
                                                      , estab
                                                      , data_inicial
                                                      , data_fim )
                     VALUES ( msafi.dsp_control.process_instance
                            , '1'
                            , c1.nome_safx
                            , v_cod_estab
                            , TO_DATE ( v_data_ini
                                      , 'YYYYMMDD' )
                            , TO_DATE ( v_data_fim
                                      , 'YYYYMMDD' ) );

                COMMIT;
            END IF; --IF (TRIM(C1.NOME_SAFX) IS NOT NULL) THEN

            v_proc_status := 2;
        END LOOP; --FOR C1 IN EXEC_INTERFACES(P_GRUPO)

        IF ( p_cria_job = 'S' ) THEN
            v_proc_status := 10;

            INSERT INTO msafi.dsp_interfaces_temp ( process_instance
                                                  , parte
                                                  , safx
                                                  , estab
                                                  , data_inicial
                                                  , data_fim )
                SELECT   process_instance
                       , '2'
                       , safx
                       , NULL
                       , MIN ( data_inicial )
                       , MAX ( data_fim )
                    FROM msafi.dsp_interfaces_temp
                   WHERE process_instance = msafi.dsp_control.process_instance
                GROUP BY process_instance
                       , safx;

            UPDATE msafi.dsp_interfaces_temp a
               SET estab =
                       ( SELECT estab
                           FROM msafi.dsp_interfaces_temp b
                          WHERE b.process_instance = a.process_instance
                            AND b.parte = '1'
                            AND b.safx = a.safx )
             WHERE process_instance = msafi.dsp_control.process_instance
               AND parte = '2'
               AND EXISTS
                       (SELECT   estab
                            FROM msafi.dsp_interfaces_temp b
                           WHERE b.process_instance = a.process_instance
                             AND b.parte = '1'
                             AND b.safx = a.safx
                        GROUP BY estab
                          HAVING COUNT ( 0 ) = 1)
               AND NVL ( ( SELECT   estab
                               FROM msafi.dsp_interfaces_temp b
                              WHERE b.process_instance = a.process_instance
                                AND b.parte = '1'
                                AND b.safx = a.safx
                           GROUP BY estab
                             HAVING COUNT ( 0 ) = 1 )
                       , 'ALL' ) <> 'ALL';

            COMMIT;

            --Cria o job de importação
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
                     , b.grupo_arquivo --GRUPO_ARQUIVO
                     , b.numero_arquivo --NUMERO_ARQUIVO
                     , mcod_empresa --COD_EMPRESA
                     , CASE
                           WHEN b.grupo_arquivo = 1
                            AND a.estab IS NULL THEN
                               v_estab_grupo
                           ELSE
                               a.estab
                       END --COD_ESTAB
                     , a.data_inicial --DATA_INI
                     , a.data_fim --DATA_FIM
                     , CASE WHEN a.safx = 'SAFX08' THEN 2 ELSE 10 END --PERC_ERRO
                     , 'S' --IND_ABORTA_JOB
                     , 'P' --STATUS
                     , 'S' --IND_DROP_TAB
                     , NULL --DAT_INI_EXEC
                     , NULL --DAT_FIM_EXEC
                     , CASE WHEN b.grupo_arquivo = 1 THEN 'N' ELSE 'S' END --IND_PERIODO
                     , 'S' --IND_SOBREPOR_REG
                     , 'N' --IND_LOG_X2013
                     , CASE WHEN a.safx = 'SAFX2013' THEN 'S' ELSE 'N' END --IND_VALID_X2013
                     , 'N' --IND_DATA_AVERB_X48
                     , 'N' --IND_GERA_X530
                     , 'N' --IND_GERA_X751
                     , 'S' --ind_valid_cep_x04
                  FROM msafi.dsp_interfaces_temp a
                     , cat_prior_imp b
                 WHERE a.process_instance = msafi.dsp_control.process_instance
                   AND a.parte = '2'
                   AND b.nom_tab_work = a.safx;

            COMMIT;

            loga ( 'Job de importação criado: [' || v_job_num || ']' );
            lib_proc.add ( 'Job de importação criado: [' || v_job_num || ']' );
            v_proc_status := 2;
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
        lib_proc.add ( 'FIM DO PROCESSAMENTO, STATUS FINAL: [' || v_s_proc_status || ']' );
        lib_proc.add ( 'Favor verificar LOG para detalhes.' );
        msafi.dsp_control.updateprocess ( v_s_proc_status );
        lib_proc.close ( );

        msafi.dsp_aux.truncatabela_msafi ( 'DSP_PROC_ESTABS' );
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
END dsp_interfaces_cproc;
/
SHOW ERRORS;
