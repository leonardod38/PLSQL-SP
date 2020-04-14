Prompt Package Body DPSP_PERDAS_CPROC;
--
-- DPSP_PERDAS_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_perdas_cproc
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
                           , 'Selecione o Arquivo'
                           , --P_ID_UPLOADER
                            'VARCHAR2'
                           , 'COMBOBOX'
                           , 'S'
                           , NULL
                           , NULL
                           ,    '
                            SELECT A.ID_UPLOAD, A.ID_UPLOAD || '' - '' || A.DAT_OPERACAO || '' - '' || A.OSUSER || '' - '' || A.FILENAME || '' - '' || A.STATUS
                            FROM MSAFI.DPSP_MSAF_UPLOADER A
                            WHERE A.COD_EMPRESA  = '''
                             || mcod_empresa
                             || '''
                            ORDER BY A.DAT_OPERACAO DESC
                           '
        );

        lib_proc.add_param ( pstr
                           , 'Utilizar Ajustes'
                           , --P_TIPO_AJUSTE
                            'VARCHAR2'
                           , 'RADIOBUTTON'
                           , 'N'
                           , '1'
                           , NULL
                           , '1=Negativos,2=Positivos' );

        lib_proc.add_param ( pstr
                           , 'Período'
                           , --P_PERIODO
                            'DATE'
                           , 'TEXTBOX'
                           , 'S'
                           , ADD_MONTHS ( SYSDATE
                                        , -1 )
                           , 'MM/YYYY' );

        lib_proc.add_param ( pstr
                           , 'Origem Entrada CD1'
                           , --P_ORIGEM1
                            'VARCHAR2'
                           , 'RADIOBUTTON'
                           , 'N'
                           , NULL
                           , NULL
                           , '1=Filial (Transferência),2=CD (Compra)' );

        lib_proc.add_param (
                             pstr
                           , 'Checar Entradas CD1'
                           , --P_CD1
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
                           , 'Filiais'
                           , --P_LOJAS
                            'VARCHAR2'
                           , 'MULTISELECT'
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
                              AND C.TIPO         = ''L''
                            ORDER BY B.COD_ESTADO, A.COD_ESTAB
                           '
        );

        RETURN pstr;
    END; --FUNCTION PARAMETROS RETURN VARCHAR2 IS

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Processar Dados de PERDAS';
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
        RETURN 'Processar Carga de Dados para Relatorio de Perdas';
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
        msafi.dsp_control.writelog ( 'PERDAS'
                                   , p_i_texto );
        COMMIT;
    ---> Para acompanhar processamento usar SELECT abaixo
    --SELECT * FROM DSP_LOG
    --WHERE LOG_TYPE = 'PMCxMVA'
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

    PROCEDURE open_file_inv ( p_i_id_upload IN NUMBER )
    IS
        v_nome_arquivo VARCHAR2 ( 100 );
        v_arquivo_status VARCHAR2 ( 1 );
        v_arquivo utl_file.file_type;
        v_linha VARCHAR2 ( 400 );
        v_1sep NUMBER;
        v_2sep NUMBER;
        v_3sep NUMBER;
        v_4sep NUMBER;
        v_5sep NUMBER;
        v_6sep NUMBER;
        v_sql VARCHAR2 ( 1000 );
        v_count_commit NUMBER;
        v_pertence_empresa VARCHAR2 ( 1 );
        ---CAMPOS
        v_cod_estab VARCHAR2 ( 6 );
        v_cod_produto VARCHAR2 ( 25 );
        v_data_inv VARCHAR2 ( 10 );
        v_saldo VARCHAR2 ( 10 );
        v_contagem VARCHAR2 ( 10 );
        v_ajuste VARCHAR2 ( 10 );
        v_custo VARCHAR2 ( 15 );
        v_tp_ajuste VARCHAR2 ( 1 );
    BEGIN
        SELECT filename
             , status
          INTO v_nome_arquivo
             , v_arquivo_status
          FROM msafi.dpsp_msaf_uploader
         WHERE id_upload = p_i_id_upload;

        IF ( v_arquivo_status = 'N' ) THEN
            --ARQUIVO NAO CARREGADO NO BD

            loga ( '[OPEN FILE...]'
                 , FALSE );

            BEGIN
                v_arquivo :=
                    utl_file.fopen ( 'MSAFIMP'
                                   , v_nome_arquivo
                                   , 'R' );
            EXCEPTION
                WHEN utl_file.invalid_path THEN
                    loga ( '> FILE NAME: ' || v_nome_arquivo || ' ID UPLOAD: ' || p_i_id_upload
                         , FALSE );
                    raise_application_error ( -20333
                                            , '!DIRETÓRIO OU NOME DE ARQUIVO INVÁLIDO!' );
                WHEN utl_file.invalid_mode THEN
                    loga ( '> FILE NAME: ' || v_nome_arquivo || ' ID UPLOAD: ' || p_i_id_upload
                         , FALSE );
                    raise_application_error ( -20334
                                            , '!PARÂMETRO DE MODO DE ABERTURA É INVÁLIDO!' );
                WHEN utl_file.invalid_filehandle THEN
                    loga ( '> FILE NAME: ' || v_nome_arquivo || ' ID UPLOAD: ' || p_i_id_upload
                         , FALSE );
                    raise_application_error ( -20335
                                            , '!ESPECIFICADOR DE ARQUIVO INVÁLIDO!' );
                WHEN utl_file.invalid_operation THEN
                    loga ( '> FILE NAME: ' || v_nome_arquivo || ' ID UPLOAD: ' || p_i_id_upload
                         , FALSE );
                    raise_application_error ( -20336
                                            , '!O ARQUIVO NÃO PODE SER ABERTO OU A OPERAÇÃO É INVÁLIDA!' );
                WHEN utl_file.read_error THEN
                    loga ( '> FILE NAME: ' || v_nome_arquivo || ' ID UPLOAD: ' || p_i_id_upload
                         , FALSE );
                    raise_application_error (
                                              -20337
                                            , '!OCORREU UM ERRO DO SISTEMA OPERACIONAL DURANTE A LEITURA DE UM ARQUIVO!'
                    );
                WHEN utl_file.internal_error THEN
                    loga ( '> FILE NAME: ' || v_nome_arquivo || ' ID UPLOAD: ' || p_i_id_upload
                         , FALSE );
                    raise_application_error ( -20338
                                            , '!ERRO NÃO ESPECIFICADO NO PL/SQL!' );
                WHEN OTHERS THEN
                    loga ( '> FILE NAME: ' || v_nome_arquivo || ' ID UPLOAD: ' || p_i_id_upload
                         , FALSE );
                    raise_application_error ( -20339
                                            , '!ERRO DESCONHECIDO AO ABRIR ARQUIVO!' );
            END;

            v_count_commit := 0;

            loga ( '[FILE]:[GET LN]'
                 , FALSE );

            LOOP --(1)
                BEGIN
                    utl_file.get_line ( v_arquivo
                                      , v_linha );
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        EXIT;
                END;

                --LOGA('[LN]:[' || V_LINHA || ']',FALSE);
                v_count_commit := v_count_commit + 1;
                v_linha :=
                    REPLACE ( v_linha
                            , ''''
                            , '' ); ---retirar aspas simples se houver

                v_1sep :=
                    INSTR ( v_linha
                          , ';'
                          , 1
                          , 1 );
                v_2sep :=
                    INSTR ( v_linha
                          , ';'
                          , 1
                          , 2 );
                v_3sep :=
                    INSTR ( v_linha
                          , ';'
                          , 1
                          , 3 );
                v_4sep :=
                    INSTR ( v_linha
                          , ';'
                          , 1
                          , 4 );
                v_5sep :=
                    INSTR ( v_linha
                          , ';'
                          , 1
                          , 5 );
                --V_6SEP := INSTR(V_LINHA, ';', 1, 6);
                ---
                v_cod_estab :=
                    SUBSTR ( v_linha
                           , 1
                           , v_1sep - 1 );

                IF ( UPPER ( v_cod_estab ) <> 'LOJA' ) THEN --(2)
                    v_cod_estab :=
                        REPLACE ( REPLACE ( v_cod_estab
                                          , 'L'
                                          , 'DP' )
                                , 'VD'
                                , 'DSP' );

                    BEGIN
                        SELECT 'Y'
                          INTO v_pertence_empresa
                          FROM estabelecimento
                         WHERE cod_empresa = mcod_empresa
                           AND cod_estab = v_cod_estab;
                    EXCEPTION
                        WHEN OTHERS THEN
                            loga ( '<E> ERRO: ' || v_linha || ' - ESTAB: ' || v_cod_estab || '<E>'
                                 , FALSE );
                            raise_application_error ( -20343
                                                    , '!ERRO VALIDANDO ESTABELECIMENTO!' );
                    END;

                    IF ( v_pertence_empresa = 'Y' ) THEN --(3)
                        v_cod_produto :=
                            SUBSTR ( v_linha
                                   , v_1sep + 1
                                   , v_2sep - v_1sep - 1 );
                        v_data_inv :=
                            SUBSTR ( v_linha
                                   , v_2sep + 1
                                   , v_3sep - v_2sep - 1 );
                        v_saldo :=
                            SUBSTR ( v_linha
                                   , v_3sep + 1
                                   , v_4sep - v_3sep - 1 );
                        --V_CONTAGEM    := SUBSTR(V_LINHA, V_4SEP+1, V_5SEP-V_4SEP-1);
                        v_contagem := 0;
                        v_ajuste :=
                            SUBSTR ( v_linha
                                   , v_4sep + 1
                                   , v_5sep - v_4sep - 1 );
                        v_custo :=
                            SUBSTR ( v_linha
                                   , v_5sep + 1 );

                        IF ( v_ajuste >= 0 ) THEN
                            v_tp_ajuste := 'P';
                        ELSE
                            v_tp_ajuste := 'N';
                        END IF;

                        v_sql :=
                               'INSERT /*+APPEND*/ INTO MSAFI.DPSP_MSAF_PERDAS_INV VALUES ('
                            || p_i_id_upload
                            || ','''
                            || v_cod_estab
                            || ''','''
                            || v_cod_produto
                            || ''',TO_DATE('''
                            || v_data_inv
                            || ''',''DD/MM/YYYY''),'
                            || v_saldo
                            || ','
                            || v_contagem
                            || ','
                            || v_ajuste
                            || ','
                            || REPLACE ( v_custo
                                       , ','
                                       , '.' )
                            || ','''
                            || v_tp_ajuste
                            || ''')';

                        BEGIN
                            EXECUTE IMMEDIATE v_sql;
                        EXCEPTION
                            WHEN OTHERS THEN
                                loga ( 'SQLERRM: ' || SQLERRM
                                     , FALSE );
                                loga (
                                          '<E> ERRO: '
                                       || v_cod_estab
                                       || ' - '
                                       || v_cod_produto
                                       || ' - '
                                       || v_data_inv
                                       || ' <E>'
                                     , FALSE
                                );
                                loga ( v_sql );

                                DELETE msafi.dpsp_msaf_perdas_inv
                                 WHERE id_upload = p_i_id_upload;

                                COMMIT;
                                raise_application_error ( -20344
                                                        , '!ERRO INSERINDO DADOS DO ARQUIVO!' );
                        END;

                        IF ( v_count_commit = 100 ) THEN
                            v_count_commit := 0;
                            COMMIT;
                        END IF;
                    END IF; --(3)
                END IF; --(2)
            END LOOP; --(1)

            utl_file.fclose ( v_arquivo );

            UPDATE msafi.dpsp_msaf_uploader
               SET status = 'C'
             WHERE id_upload = p_i_id_upload;

            COMMIT;

            loga ( '<< CARGA DE ARQUIVO OK >>'
                 , FALSE );
        ELSE
            --ARQUIVO JA CARREGADO
            loga ( '<< ARQUIVO JA CARREGADO >>'
                 , FALSE );
        END IF;
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

    PROCEDURE create_perdas_inv_tmp ( vp_proc_instance IN VARCHAR2
                                    , vp_tab_perdas_inv   OUT VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 1000 );
    BEGIN
        vp_tab_perdas_inv := 'DPSP_P_INV_' || vp_proc_instance;

        v_sql := 'CREATE TABLE ' || vp_tab_perdas_inv || ' ';
        v_sql := v_sql || '( ';
        v_sql := v_sql || '  PROC_ID         NUMBER(30), ';
        v_sql := v_sql || '  ID_UPLOAD      NUMBER(10), ';
        v_sql := v_sql || '  COD_ESTAB     VARCHAR2(6), ';
        v_sql := v_sql || '  COD_PRODUTO    VARCHAR2(25), ';
        v_sql := v_sql || '  DATA_INV    DATE, ';
        v_sql := v_sql || '  QTD_SALDO    NUMBER(15,2), ';
        v_sql := v_sql || '  QTD_CONTAGEM  NUMBER(15,2), ';
        v_sql := v_sql || '  QTD_AJUSTE    NUMBER(15,2), ';
        v_sql := v_sql || '  VLR_CUSTO    NUMBER(15,2), ';
        v_sql := v_sql || '  TIPO_AJUSTE    VARCHAR2(1) ';
        v_sql := v_sql || ') ';
        v_sql := v_sql || 'PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        ---
        save_tmp_control ( vp_proc_instance
                         , vp_tab_perdas_inv );
    END;

    PROCEDURE load_inv_dados ( vp_id_upload IN VARCHAR2
                             , vp_proc_instance IN VARCHAR2
                             , vp_cod_estab IN VARCHAR2
                             , vp_data_ini IN DATE
                             , vp_data_fim IN DATE
                             , vp_tipo_ajuste IN VARCHAR2
                             , vp_tab_perdas_inv IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 4000 );
    BEGIN
        v_sql := 'INSERT /*+APPEND*/ INTO ' || vp_tab_perdas_inv || ' ';
        v_sql :=
               v_sql
            || ' (SELECT '
            || vp_proc_instance
            || ', ID_UPLOAD, COD_ESTAB, COD_PRODUTO, DATA_INV, QTD_SALDO, QTD_CONTAGEM, QTD_AJUSTE, VLR_CUSTO, TIPO_AJUSTE ';
        v_sql := v_sql || '  FROM MSAFI.DPSP_MSAF_PERDAS_INV ';
        v_sql := v_sql || '  WHERE ID_UPLOAD = ' || vp_id_upload;
        v_sql := v_sql || '    AND COD_ESTAB = ''' || vp_cod_estab || ''' ';
        v_sql :=
               v_sql
            || '    AND DATA_INV BETWEEN TO_DATE('''
            || TO_CHAR ( vp_data_ini
                       , 'DDMMYYYY' )
            || ''',''DDMMYYYY'') AND TO_DATE('''
            || TO_CHAR ( vp_data_fim
                       , 'DDMMYYYY' )
            || ''',''DDMMYYYY'') ';

        IF ( vp_tipo_ajuste = '1' ) THEN --NEGATIVO
            v_sql := v_sql || ' AND QTD_AJUSTE < 0 ';
        ELSIF ( vp_tipo_ajuste = '2' ) THEN --POSITIVO
            v_sql := v_sql || ' AND QTD_AJUSTE > 0 ';
        END IF;

        v_sql := v_sql || ')';

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
                raise_application_error ( -20003
                                        , '!ERRO LOAD_INV_DADOS!' );
        END;
    END;

    PROCEDURE create_perdas_inv_tmp_idx ( vp_proc_instance IN VARCHAR2
                                        , vp_tab_perdas_inv IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 2000 );
    BEGIN
        v_sql := 'CREATE UNIQUE INDEX PK_PINV_' || vp_proc_instance || ' ON ' || vp_tab_perdas_inv || ' ';
        v_sql := v_sql || '( ';
        v_sql := v_sql || ' PROC_ID    ASC, ';
        v_sql := v_sql || '  ID_UPLOAD   ASC, ';
        v_sql := v_sql || '  COD_ESTAB   ASC, ';
        v_sql := v_sql || '  COD_PRODUTO  ASC, ';
        v_sql := v_sql || '  DATA_INV    ASC, ';
        v_sql := v_sql || '  TIPO_AJUSTE ASC ';
        v_sql := v_sql || ') ';
        v_sql := v_sql || '  PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX1_PINV_' || vp_proc_instance || ' ON ' || vp_tab_perdas_inv || ' ';
        v_sql := v_sql || '( ';
        v_sql := v_sql || ' PROC_ID    ASC, ';
        v_sql := v_sql || '  ID_UPLOAD   ASC ';
        v_sql := v_sql || ') ';
        v_sql := v_sql || '  PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX2_PINV_' || vp_proc_instance || ' ON ' || vp_tab_perdas_inv || ' ';
        v_sql := v_sql || '( ';
        v_sql := v_sql || '  ID_UPLOAD   ASC, ';
        v_sql := v_sql || '  PROC_ID    ASC, ';
        v_sql := v_sql || '  COD_ESTAB   ASC ';
        v_sql := v_sql || ') ';
        v_sql := v_sql || ' PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_tab_perdas_inv );
        loga ( '>>' || vp_tab_perdas_inv || ' CRIADA'
             , FALSE );
    END;

    PROCEDURE create_tab_entrada_cd ( vp_proc_instance IN NUMBER
                                    , vp_tab_entrada_c   OUT VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 6000 );
    BEGIN
        ---CRIAR TEMP DE ENTRADA EM CD
        vp_tab_entrada_c := 'DPSP_MSF_P_E_C_' || vp_proc_instance;

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
        v_sql := v_sql || ' COD_FIS_JUR      VARCHAR2(14), ';
        v_sql := v_sql || ' CPF_CGC        VARCHAR2(14), ';
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
        v_sql VARCHAR2 ( 2000 );
    BEGIN
        v_sql := 'CREATE UNIQUE INDEX PK_P_E_C_' || vp_proc_instance || ' ON ' || vp_tab_entrada_cd || ' ';
        v_sql := v_sql || '( ';
        v_sql := v_sql || ' PROC_ID             ASC, ';
        v_sql := v_sql || ' COD_EMPRESA         ASC, ';
        v_sql := v_sql || ' COD_ESTAB           ASC, ';
        v_sql := v_sql || ' DATA_FISCAL         ASC, ';
        v_sql := v_sql || ' MOVTO_E_S           ASC, ';
        v_sql := v_sql || ' NORM_DEV            ASC, ';
        v_sql := v_sql || ' IDENT_DOCTO         ASC, ';
        v_sql := v_sql || ' IDENT_FIS_JUR       ASC, ';
        v_sql := v_sql || ' NUM_DOCFIS          ASC, ';
        v_sql := v_sql || ' SERIE_DOCFIS        ASC, ';
        v_sql := v_sql || ' SUB_SERIE_DOCFIS    ASC, ';
        v_sql := v_sql || ' DISCRI_ITEM         ASC ';
        v_sql := v_sql || ') ';
        v_sql := v_sql || ' PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX1_P_E_C_' || vp_proc_instance || ' ON ' || vp_tab_entrada_cd || ' ';
        v_sql := v_sql || '( ';
        v_sql := v_sql || ' PROC_ID       ASC, ';
        v_sql := v_sql || ' COD_EMPRESA   ASC, ';
        v_sql := v_sql || ' COD_ESTAB     ASC, ';
        v_sql := v_sql || ' COD_PRODUTO   ASC, ';
        v_sql := v_sql || ' DATA_FISCAL   ASC ';
        v_sql := v_sql || ') ';
        v_sql := v_sql || 'PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX2_P_E_C_' || vp_proc_instance || ' ON ' || vp_tab_entrada_cd || ' ';
        v_sql := v_sql || '( ';
        v_sql := v_sql || ' PROC_ID       ASC, ';
        v_sql := v_sql || ' COD_EMPRESA   ASC, ';
        v_sql := v_sql || ' COD_ESTAB     ASC, ';
        v_sql := v_sql || ' COD_PRODUTO   ASC, ';
        v_sql := v_sql || ' COD_FIS_JUR    ASC, ';
        v_sql := v_sql || ' DATA_FISCAL   ASC ';
        v_sql := v_sql || ') ';
        v_sql := v_sql || 'PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_tab_entrada_cd );
        loga ( '>>' || vp_tab_entrada_cd || ' CRIADA'
             , FALSE );
    END;

    PROCEDURE create_tab_entrada_filial ( vp_proc_instance IN NUMBER
                                        , vp_tab_entrada_f   OUT VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 6000 );
    BEGIN
        ---CRIAR TEMP DE ENTRADA EM FILIAL
        vp_tab_entrada_f := 'DPSP_MSF_P_E_F_' || vp_proc_instance;

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
        v_sql := v_sql || ' COD_FIS_JUR      VARCHAR2(14), ';
        v_sql := v_sql || ' CPF_CGC        VARCHAR2(14), ';
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

    PROCEDURE create_tab_ent_filial_idx ( vp_proc_instance IN NUMBER
                                        , vp_tab_entrada_f IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 1000 );
    BEGIN
        v_sql := 'CREATE UNIQUE INDEX PK_P_E_F_' || vp_proc_instance || ' ON ' || vp_tab_entrada_f || ' ';
        v_sql := v_sql || '( ';
        v_sql := v_sql || ' PROC_ID             ASC, ';
        v_sql := v_sql || ' COD_EMPRESA         ASC, ';
        v_sql := v_sql || ' COD_ESTAB           ASC, ';
        v_sql := v_sql || ' DATA_FISCAL         ASC, ';
        v_sql := v_sql || ' MOVTO_E_S           ASC, ';
        v_sql := v_sql || ' NORM_DEV            ASC, ';
        v_sql := v_sql || ' IDENT_DOCTO         ASC, ';
        v_sql := v_sql || ' IDENT_FIS_JUR       ASC, ';
        v_sql := v_sql || ' NUM_DOCFIS          ASC, ';
        v_sql := v_sql || ' SERIE_DOCFIS        ASC, ';
        v_sql := v_sql || ' SUB_SERIE_DOCFIS    ASC, ';
        v_sql := v_sql || ' DISCRI_ITEM         ASC ';
        v_sql := v_sql || ') ';
        v_sql := v_sql || ' PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX1_P_E_F_' || vp_proc_instance || ' ON ' || vp_tab_entrada_f || ' ';
        v_sql := v_sql || '( ';
        v_sql := v_sql || ' PROC_ID       ASC, ';
        v_sql := v_sql || ' COD_EMPRESA   ASC, ';
        v_sql := v_sql || ' COD_ESTAB     ASC, ';
        v_sql := v_sql || ' COD_PRODUTO   ASC, ';
        v_sql := v_sql || ' DATA_FISCAL   ASC ';
        v_sql := v_sql || ') ';
        v_sql := v_sql || 'PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX2_P_E_F_' || vp_proc_instance || ' ON ' || vp_tab_entrada_f || ' ';
        v_sql := v_sql || '( ';
        v_sql := v_sql || ' PROC_ID       ASC, ';
        v_sql := v_sql || ' COD_EMPRESA   ASC, ';
        v_sql := v_sql || ' COD_ESTAB     ASC, ';
        v_sql := v_sql || ' COD_PRODUTO   ASC, ';
        v_sql := v_sql || ' COD_FIS_JUR    ASC, ';
        v_sql := v_sql || ' DATA_FISCAL   ASC ';
        v_sql := v_sql || ') ';
        v_sql := v_sql || 'PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_tab_entrada_f );
        loga ( '>>' || vp_tab_entrada_f || ' CRIADA'
             , FALSE );
    END;

    PROCEDURE create_tab_entrada_cdireta ( vp_proc_instance IN NUMBER
                                         , vp_tab_entrada_d   OUT VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 6000 );
    BEGIN
        ---CRIAR TEMP DE ENTRADA COMPRA DIRETA
        vp_tab_entrada_d := 'DPSP_MSF_P_E_D_' || vp_proc_instance;

        v_sql := 'CREATE TABLE ' || vp_tab_entrada_d || ' ( ';
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
        v_sql := v_sql || ' COD_FIS_JUR      VARCHAR2(14), ';
        v_sql := v_sql || ' CPF_CGC        VARCHAR2(14), ';
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
                         , vp_tab_entrada_d );
    END;

    PROCEDURE create_tab_ent_cdireta_idx ( vp_proc_instance IN NUMBER
                                         , vp_tab_entrada_d IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 1000 );
    BEGIN
        v_sql := 'CREATE UNIQUE INDEX PK_P_E_D_' || vp_proc_instance || ' ON ' || vp_tab_entrada_d || ' ';
        v_sql := v_sql || '( ';
        v_sql := v_sql || ' PROC_ID             ASC, ';
        v_sql := v_sql || ' COD_EMPRESA         ASC, ';
        v_sql := v_sql || ' COD_ESTAB           ASC, ';
        v_sql := v_sql || ' DATA_FISCAL         ASC, ';
        v_sql := v_sql || ' MOVTO_E_S           ASC, ';
        v_sql := v_sql || ' NORM_DEV            ASC, ';
        v_sql := v_sql || ' IDENT_DOCTO         ASC, ';
        v_sql := v_sql || ' IDENT_FIS_JUR       ASC, ';
        v_sql := v_sql || ' NUM_DOCFIS          ASC, ';
        v_sql := v_sql || ' SERIE_DOCFIS        ASC, ';
        v_sql := v_sql || ' SUB_SERIE_DOCFIS    ASC, ';
        v_sql := v_sql || ' DISCRI_ITEM         ASC ';
        v_sql := v_sql || ') ';
        v_sql := v_sql || ' PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX1_P_E_D_' || vp_proc_instance || ' ON ' || vp_tab_entrada_d || ' ';
        v_sql := v_sql || '( ';
        v_sql := v_sql || ' PROC_ID       ASC, ';
        v_sql := v_sql || ' COD_EMPRESA   ASC, ';
        v_sql := v_sql || ' COD_ESTAB     ASC, ';
        v_sql := v_sql || ' COD_PRODUTO   ASC, ';
        v_sql := v_sql || ' DATA_FISCAL   ASC ';
        v_sql := v_sql || ') ';
        v_sql := v_sql || 'PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE INDEX IDX2_P_E_D_' || vp_proc_instance || ' ON ' || vp_tab_entrada_d || ' ';
        v_sql := v_sql || '( ';
        v_sql := v_sql || ' PROC_ID       ASC, ';
        v_sql := v_sql || ' COD_EMPRESA   ASC, ';
        v_sql := v_sql || ' COD_ESTAB     ASC, ';
        v_sql := v_sql || ' COD_PRODUTO   ASC, ';
        v_sql := v_sql || ' COD_FIS_JUR    ASC, ';
        v_sql := v_sql || ' DATA_FISCAL   ASC ';
        v_sql := v_sql || ') ';
        v_sql := v_sql || 'PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_tab_entrada_d );
        loga ( '>>' || vp_tab_entrada_d || ' CRIADA'
             , FALSE );
    END;

    PROCEDURE load_entradas ( vp_id_upload IN VARCHAR2
                            , vp_proc_instance IN VARCHAR2
                            , vp_cod_estab IN VARCHAR2
                            , vp_dt_inicial IN DATE
                            , vp_dt_final IN DATE
                            , vp_origem IN VARCHAR2
                            , vp_tabela_entrada IN VARCHAR2
                            , vp_tab_perdas_inv IN VARCHAR2
                            , vp_tipo_ajuste VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 8000 );
    BEGIN
        IF ( vp_origem = 'C' ) THEN --CD
            v_sql := 'INSERT /*+APPEND*/ INTO ' || vp_tabela_entrada || ' ( ';
            v_sql := v_sql || 'SELECT DISTINCT ';
            v_sql := v_sql || '    ' || vp_proc_instance || ', ';
            v_sql := v_sql || '    A.COD_EMPRESA, ';
            v_sql := v_sql || '    A.COD_ESTAB, ';
            v_sql := v_sql || '    A.DATA_FISCAL, ';
            v_sql := v_sql || '    A.MOVTO_E_S, ';
            v_sql := v_sql || '    A.NORM_DEV, ';
            v_sql := v_sql || '    A.IDENT_DOCTO, ';
            v_sql := v_sql || '    A.IDENT_FIS_JUR, ';
            v_sql := v_sql || '    A.NUM_DOCFIS, ';
            v_sql := v_sql || '    A.SERIE_DOCFIS, ';
            v_sql := v_sql || '    A.SUB_SERIE_DOCFIS, ';
            v_sql := v_sql || '    A.DISCRI_ITEM, ';
            v_sql := v_sql || '    A.NUM_ITEM, ';
            v_sql := v_sql || '    A.COD_FIS_JUR, ';
            v_sql := v_sql || '    A.CPF_CGC, ';
            v_sql := v_sql || '    A.COD_NBM, ';
            v_sql := v_sql || '    A.COD_CFO, ';
            v_sql := v_sql || '    A.COD_NATUREZA_OP, ';
            v_sql := v_sql || '    A.COD_PRODUTO, ';
            v_sql := v_sql || '    A.VLR_CONTAB_ITEM, ';
            v_sql := v_sql || '    A.QUANTIDADE, ';
            v_sql := v_sql || '    A.VLR_UNIT, ';
            v_sql := v_sql || '    A.COD_SITUACAO_B, ';
            v_sql := v_sql || '    A.DATA_EMISSAO, ';
            v_sql := v_sql || '    A.COD_ESTADO, ';
            v_sql := v_sql || '    A.NUM_CONTROLE_DOCTO, ';
            v_sql := v_sql || '    A.NUM_AUTENTIC_NFE ';
            v_sql := v_sql || 'FROM ( ';
            v_sql := v_sql || '      SELECT /*+PARALLEL(12) INDEX(D PK_X2013_PRODUTO) ';
            v_sql := v_sql || '                INDEX(A PK_X2043_COD_NBM) ';
            v_sql := v_sql || '                INDEX(G PK_X04_PESSOA_FIS_JUR)*/ ';
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
            v_sql := v_sql || '            RANK() OVER( ';
            v_sql := v_sql || '                PARTITION BY X08.COD_ESTAB, D.COD_PRODUTO ';
            v_sql :=
                   v_sql
                || '                ORDER BY X08.DATA_FISCAL DESC, X07.DATA_EMISSAO DESC, X08.NUM_DOCFIS DESC, X08.DISCRI_ITEM DESC) RANK ';
            v_sql := v_sql || '    FROM X08_ITENS_MERC X08, ';
            v_sql := v_sql || '       X07_DOCTO_FISCAL X07, ';
            v_sql := v_sql || '         X2013_PRODUTO D, ';
            v_sql := v_sql || '         X04_PESSOA_FIS_JUR G, ';
            --V_SQL := V_SQL || '         ( SELECT  /*+PARALLEL_INDEX(A IDX1_PINV_' || VP_PROC_INSTANCE || ', 6)*/ ';
            v_sql := v_sql || '           (SELECT DISTINCT ';
            v_sql := v_sql || '               A.COD_PRODUTO, ';
            v_sql := v_sql || '               A.DATA_INV ';
            v_sql := v_sql || '           FROM ' || vp_tab_perdas_inv || ' A ';
            v_sql := v_sql || '           WHERE A.ID_UPLOAD = ' || vp_id_upload || ' ';
            v_sql := v_sql || '             AND A.PROC_ID   = ' || vp_proc_instance || ' ';

            IF ( vp_tipo_ajuste = '1' ) THEN --negativo
                v_sql := v_sql || '             AND A.TIPO_AJUSTE = ''N'' ) P,';
            ELSIF ( vp_tipo_ajuste = '2' ) THEN --positivo
                v_sql := v_sql || '             AND A.TIPO_AJUSTE = ''P'' ) P,';
            END IF;

            v_sql := v_sql || '       X2043_COD_NBM A, ';
            v_sql := v_sql || '         X2012_COD_FISCAL B, ';
            v_sql := v_sql || '         X2006_NATUREZA_OP C, ';
            v_sql := v_sql || '         Y2026_SIT_TRB_UF_B E, ';
            v_sql := v_sql || '         ESTADO H  ';
            v_sql := v_sql || '    WHERE X08.MOVTO_E_S           <> ''9'' ';
            v_sql := v_sql || '      AND X08.SERIE_DOCFIS       <> ''GNR'' ';
            v_sql := v_sql || '      AND X08.COD_EMPRESA       = ''' || mcod_empresa || ''' ';
            v_sql := v_sql || '      AND X08.COD_ESTAB         = ''' || vp_cod_estab || ''' ';
            ---
            v_sql := v_sql || '      AND X08.IDENT_NBM         = A.IDENT_NBM ';
            v_sql := v_sql || '      AND X08.IDENT_CFO           = B.IDENT_CFO ';
            v_sql :=
                v_sql || '      AND B.COD_CFO             IN (''1102'',''2102'',''1403'',''2403'',''1910'',''2910'') ';
            v_sql := v_sql || '      AND X08.IDENT_NATUREZA_OP   = C.IDENT_NATUREZA_OP ';
            v_sql := v_sql || '      AND X08.IDENT_SITUACAO_B    = E.IDENT_SITUACAO_B ';
            v_sql := v_sql || '      AND X07.VLR_PRODUTO        > 0.01 ';
            v_sql := v_sql || '      AND X08.IDENT_PRODUTO       = D.IDENT_PRODUTO ';
            ---
            v_sql := v_sql || '      AND P.COD_PRODUTO        = D.COD_PRODUTO ';
            v_sql := v_sql || '      AND P.DATA_INV           > X08.DATA_FISCAL ';
            v_sql := v_sql || '      AND X08.DATA_FISCAL     >= SYSDATE - (365*2) '; --ULTIMOS 2 ANOS
            ---
            v_sql := v_sql || '      AND X07.IDENT_FIS_JUR      = G.IDENT_FIS_JUR ';
            v_sql := v_sql || '      AND G.IDENT_ESTADO        = H.IDENT_ESTADO ';
            ---
            v_sql := v_sql || '      AND X07.COD_EMPRESA         = X08.COD_EMPRESA ';
            v_sql := v_sql || '      AND X07.COD_ESTAB           = X08.COD_ESTAB ';
            v_sql := v_sql || '      AND X07.DATA_FISCAL         = X08.DATA_FISCAL ';
            v_sql := v_sql || '      AND X07.MOVTO_E_S           = X08.MOVTO_E_S ';
            v_sql := v_sql || '      AND X07.NORM_DEV            = X08.NORM_DEV ';
            v_sql := v_sql || '      AND X07.IDENT_DOCTO         = X08.IDENT_DOCTO ';
            v_sql := v_sql || '      AND X07.IDENT_FIS_JUR       = X08.IDENT_FIS_JUR ';
            v_sql := v_sql || '      AND X07.NUM_DOCFIS          = X08.NUM_DOCFIS ';
            v_sql := v_sql || '      AND X07.SERIE_DOCFIS        = X08.SERIE_DOCFIS ';
            v_sql := v_sql || '      AND X07.SUB_SERIE_DOCFIS    = X08.SUB_SERIE_DOCFIS ';
            v_sql := v_sql || '     ) A ';
            v_sql := v_sql || 'WHERE A.RANK = 1 )';

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
                    raise_application_error ( -20003
                                            , '!ERRO INSERT LOAD ENTRADAS CD!' );
            END;
        ELSIF ( vp_origem = 'F' ) THEN --FILIAL
            v_sql := 'INSERT /*+APPEND*/ INTO ' || vp_tabela_entrada || ' ( ';
            v_sql := v_sql || 'SELECT DISTINCT ';
            v_sql := v_sql || ' ' || vp_proc_instance || ', ';
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
            v_sql := v_sql || ' A.COD_SITUACAO_B, ';
            v_sql := v_sql || ' A.DATA_EMISSAO, ';
            v_sql := v_sql || ' A.COD_ESTADO, ';
            v_sql := v_sql || ' A.NUM_CONTROLE_DOCTO, ';
            v_sql := v_sql || ' A.NUM_AUTENTIC_NFE ';
            v_sql := v_sql || 'FROM ( ';
            v_sql := v_sql || '      SELECT /*+PARALLEL(12) INDEX(D PK_X2013_PRODUTO) ';
            v_sql := v_sql || '                INDEX(A PK_X2043_COD_NBM) ';
            v_sql := v_sql || '                INDEX(G PK_X04_PESSOA_FIS_JUR)*/ ';
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
            v_sql := v_sql || '        X08.NUM_ITEM, ';
            v_sql := v_sql || '        G.COD_FIS_JUR, ';
            v_sql := v_sql || '        G.CPF_CGC,  ';
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
            v_sql := v_sql || '            RANK() OVER( ';
            v_sql := v_sql || '                PARTITION BY X08.COD_ESTAB, D.COD_PRODUTO, G.COD_FIS_JUR ';
            v_sql :=
                   v_sql
                || '                ORDER BY X08.DATA_FISCAL DESC, X07.DATA_EMISSAO DESC, X08.NUM_DOCFIS DESC, X08.DISCRI_ITEM DESC) RANK ';
            v_sql := v_sql || '    FROM X08_ITENS_MERC X08, ';
            v_sql := v_sql || '       X07_DOCTO_FISCAL X07, ';
            v_sql := v_sql || '         X2013_PRODUTO D, ';
            v_sql := v_sql || '         X04_PESSOA_FIS_JUR G, ';
            v_sql := v_sql || '         ' || vp_tab_perdas_inv || ' P, ';
            v_sql := v_sql || '       X2043_COD_NBM A, ';
            v_sql := v_sql || '         X2012_COD_FISCAL B, ';
            v_sql := v_sql || '         X2006_NATUREZA_OP C, ';
            v_sql := v_sql || '         Y2026_SIT_TRB_UF_B E, ';
            v_sql := v_sql || '         ESTADO H ';
            v_sql := v_sql || '    WHERE X08.MOVTO_E_S           <> ''9'' ';
            v_sql := v_sql || '      AND X08.COD_EMPRESA       = ''' || mcod_empresa || ''' ';
            v_sql := v_sql || '      AND X08.COD_ESTAB         = ''' || vp_cod_estab || ''' ';
            ---
            v_sql := v_sql || '      AND X08.IDENT_NBM         = A.IDENT_NBM ';
            v_sql := v_sql || '      AND X08.IDENT_CFO           = B.IDENT_CFO ';
            v_sql := v_sql || '      AND B.COD_CFO             IN (''1152'',''2152'',''1409'',''2409'') ';
            v_sql := v_sql || '      AND X08.IDENT_NATUREZA_OP   = C.IDENT_NATUREZA_OP ';
            v_sql := v_sql || '      AND X08.IDENT_SITUACAO_B    = E.IDENT_SITUACAO_B ';
            v_sql := v_sql || '      AND X07.VLR_PRODUTO        <> 0 ';
            v_sql := v_sql || '      AND X08.IDENT_PRODUTO       = D.IDENT_PRODUTO ';
            ---
            v_sql := v_sql || '      AND P.ID_UPLOAD        = ' || vp_id_upload || ' ';
            v_sql := v_sql || '      AND P.PROC_ID          = ' || vp_proc_instance || ' ';

            IF ( vp_tipo_ajuste = '1' ) THEN --negativo
                v_sql := v_sql || '             AND P.TIPO_AJUSTE = ''N'' ';
            ELSIF ( vp_tipo_ajuste = '2' ) THEN --positivo
                v_sql := v_sql || '             AND P.TIPO_AJUSTE = ''P'' ';
            END IF;

            v_sql := v_sql || '      AND P.COD_ESTAB          = X08.COD_ESTAB ';
            v_sql := v_sql || '      AND P.COD_PRODUTO        = D.COD_PRODUTO ';
            v_sql := v_sql || '      AND P.DATA_INV           > X08.DATA_FISCAL ';
            v_sql := v_sql || '      AND X08.DATA_FISCAL     >= SYSDATE - (365*2) '; --ULTIMOS 2 ANOS
            ---
            v_sql := v_sql || '      AND X07.IDENT_FIS_JUR      = G.IDENT_FIS_JUR ';
            v_sql := v_sql || '      AND G.IDENT_ESTADO        = H.IDENT_ESTADO ';
            ---
            v_sql := v_sql || '      AND X07.COD_EMPRESA         = X08.COD_EMPRESA ';
            v_sql := v_sql || '      AND X07.COD_ESTAB           = X08.COD_ESTAB ';
            v_sql := v_sql || '      AND X07.DATA_FISCAL         = X08.DATA_FISCAL ';
            v_sql := v_sql || '      AND X07.MOVTO_E_S           = X08.MOVTO_E_S ';
            v_sql := v_sql || '      AND X07.NORM_DEV            = X08.NORM_DEV ';
            v_sql := v_sql || '      AND X07.IDENT_DOCTO         = X08.IDENT_DOCTO ';
            v_sql := v_sql || '      AND X07.IDENT_FIS_JUR       = X08.IDENT_FIS_JUR ';
            v_sql := v_sql || '      AND X07.NUM_DOCFIS          = X08.NUM_DOCFIS ';
            v_sql := v_sql || '      AND X07.SERIE_DOCFIS        = X08.SERIE_DOCFIS ';
            v_sql := v_sql || '      AND X07.SUB_SERIE_DOCFIS    = X08.SUB_SERIE_DOCFIS ';
            v_sql := v_sql || '     ) A ';
            v_sql := v_sql || 'WHERE A.RANK = 1 ) ';

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
                    raise_application_error ( -20004
                                            , '!ERRO INSERT LOAD ENTRADAS FILIAL!' );
            END;
        ELSIF ( vp_origem = 'CO' ) THEN --COMPRA DIRETA
            v_sql := 'INSERT /*+APPEND*/ INTO ' || vp_tabela_entrada || ' ( ';
            v_sql := v_sql || 'SELECT DISTINCT ';
            v_sql := v_sql || '    ' || vp_proc_instance || ', ';
            v_sql := v_sql || '    A.COD_EMPRESA, ';
            v_sql := v_sql || '    A.COD_ESTAB, ';
            v_sql := v_sql || '    A.DATA_FISCAL, ';
            v_sql := v_sql || '    A.MOVTO_E_S, ';
            v_sql := v_sql || '    A.NORM_DEV, ';
            v_sql := v_sql || '    A.IDENT_DOCTO, ';
            v_sql := v_sql || '    A.IDENT_FIS_JUR, ';
            v_sql := v_sql || '    A.NUM_DOCFIS, ';
            v_sql := v_sql || '    A.SERIE_DOCFIS, ';
            v_sql := v_sql || '    A.SUB_SERIE_DOCFIS, ';
            v_sql := v_sql || '    A.DISCRI_ITEM, ';
            v_sql := v_sql || '    A.NUM_ITEM, ';
            v_sql := v_sql || '    A.COD_FIS_JUR, ';
            v_sql := v_sql || '    A.CPF_CGC, ';
            v_sql := v_sql || '    A.COD_NBM, ';
            v_sql := v_sql || '    A.COD_CFO, ';
            v_sql := v_sql || '    A.COD_NATUREZA_OP, ';
            v_sql := v_sql || '    A.COD_PRODUTO, ';
            v_sql := v_sql || '    A.VLR_CONTAB_ITEM, ';
            v_sql := v_sql || '    A.QUANTIDADE, ';
            v_sql := v_sql || '    A.VLR_UNIT, ';
            v_sql := v_sql || '    A.COD_SITUACAO_B, ';
            v_sql := v_sql || '    A.DATA_EMISSAO, ';
            v_sql := v_sql || '    A.COD_ESTADO, ';
            v_sql := v_sql || '    A.NUM_CONTROLE_DOCTO, ';
            v_sql := v_sql || '    A.NUM_AUTENTIC_NFE ';
            v_sql := v_sql || 'FROM ( ';
            v_sql := v_sql || '      SELECT /*+PARALLEL(12) INDEX(D PK_X2013_PRODUTO) ';
            v_sql := v_sql || '                INDEX(A PK_X2043_COD_NBM) ';
            v_sql := v_sql || '                INDEX(G PK_X04_PESSOA_FIS_JUR)*/ ';
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
            v_sql := v_sql || '            RANK() OVER( ';
            v_sql := v_sql || '                PARTITION BY X08.COD_ESTAB, D.COD_PRODUTO ';
            v_sql :=
                   v_sql
                || '                ORDER BY X08.DATA_FISCAL DESC, X07.DATA_EMISSAO DESC, X08.NUM_DOCFIS DESC, X08.DISCRI_ITEM DESC) RANK ';
            v_sql := v_sql || '    FROM X08_ITENS_MERC X08, ';
            v_sql := v_sql || '       X07_DOCTO_FISCAL X07, ';
            v_sql := v_sql || '         X2013_PRODUTO D, ';
            v_sql := v_sql || '         X04_PESSOA_FIS_JUR G, ';
            v_sql := v_sql || '         ' || vp_tab_perdas_inv || ' P, ';
            v_sql := v_sql || '       X2043_COD_NBM A, ';
            v_sql := v_sql || '         X2012_COD_FISCAL B, ';
            v_sql := v_sql || '         X2006_NATUREZA_OP C, ';
            v_sql := v_sql || '         Y2026_SIT_TRB_UF_B E, ';
            v_sql := v_sql || '         ESTADO H  ';
            v_sql := v_sql || '    WHERE X08.MOVTO_E_S           <> ''9'' ';
            v_sql := v_sql || '      AND X08.COD_EMPRESA       = ''' || mcod_empresa || ''' ';
            v_sql := v_sql || '      AND X08.COD_ESTAB         = ''' || vp_cod_estab || ''' ';
            ---
            v_sql := v_sql || '      AND X08.IDENT_NBM         = A.IDENT_NBM ';
            v_sql := v_sql || '      AND X08.IDENT_CFO           = B.IDENT_CFO ';
            v_sql :=
                v_sql || '      AND B.COD_CFO              IN (''1102'',''2102'',''1403'',''2403'',''1910'',''2910'') ';
            v_sql := v_sql || '       AND ((G.CPF_CGC NOT LIKE ''61412110%'' AND X08.COD_EMPRESA = ''DSP'') ';
            v_sql := v_sql || '            OR  (G.CPF_CGC NOT LIKE ''334382500%'' AND X08.COD_EMPRESA = ''DP'')) ';
            v_sql := v_sql || '          AND X07.NUM_CONTROLE_DOCTO  NOT LIKE ''C%''  ';
            v_sql := v_sql || '      AND X08.IDENT_NATUREZA_OP   = C.IDENT_NATUREZA_OP ';
            v_sql := v_sql || '      AND X08.IDENT_SITUACAO_B    = E.IDENT_SITUACAO_B ';
            v_sql := v_sql || '      AND X07.VLR_PRODUTO        <> 0 ';
            v_sql := v_sql || '      AND X08.IDENT_PRODUTO       = D.IDENT_PRODUTO ';
            ---
            v_sql := v_sql || '      AND P.ID_UPLOAD        = ' || vp_id_upload || ' ';
            v_sql := v_sql || '      AND P.PROC_ID          = ' || vp_proc_instance || ' ';

            IF ( vp_tipo_ajuste = '1' ) THEN --negativo
                v_sql := v_sql || '             AND P.TIPO_AJUSTE = ''N'' ';
            ELSIF ( vp_tipo_ajuste = '2' ) THEN --positivo
                v_sql := v_sql || '             AND P.TIPO_AJUSTE = ''P'' ';
            END IF;

            v_sql := v_sql || '      AND P.COD_ESTAB      = X08.COD_ESTAB ';
            v_sql := v_sql || '      AND P.COD_PRODUTO    = D.COD_PRODUTO ';
            v_sql := v_sql || '      AND P.DATA_INV       > X08.DATA_FISCAL ';
            v_sql := v_sql || '      AND X08.DATA_FISCAL >= SYSDATE - (365*2) '; --ULTIMOS 2 ANOS
            ---
            v_sql := v_sql || '      AND X07.IDENT_FIS_JUR      = G.IDENT_FIS_JUR ';
            v_sql := v_sql || '      AND G.IDENT_ESTADO        = H.IDENT_ESTADO ';
            ---
            v_sql := v_sql || '      AND X07.COD_EMPRESA         = X08.COD_EMPRESA ';
            v_sql := v_sql || '      AND X07.COD_ESTAB           = X08.COD_ESTAB ';
            v_sql := v_sql || '      AND X07.DATA_FISCAL         = X08.DATA_FISCAL ';
            v_sql := v_sql || '      AND X07.MOVTO_E_S           = X08.MOVTO_E_S ';
            v_sql := v_sql || '      AND X07.NORM_DEV            = X08.NORM_DEV ';
            v_sql := v_sql || '      AND X07.IDENT_DOCTO         = X08.IDENT_DOCTO ';
            v_sql := v_sql || '      AND X07.IDENT_FIS_JUR       = X08.IDENT_FIS_JUR ';
            v_sql := v_sql || '      AND X07.NUM_DOCFIS          = X08.NUM_DOCFIS ';
            v_sql := v_sql || '      AND X07.SERIE_DOCFIS        = X08.SERIE_DOCFIS ';
            v_sql := v_sql || '      AND X07.SUB_SERIE_DOCFIS    = X08.SUB_SERIE_DOCFIS ';
            v_sql := v_sql || '     ) A ';
            v_sql := v_sql || 'WHERE A.RANK = 1 ) ';

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
                    raise_application_error ( -20005
                                            , '!ERRO INSERT LOAD ENTRADAS CDIRETA!' );
            END;
        END IF;
    END; --PROCEDURE LOAD_ENTRADAS

    --PROCEDURE PARA CRIAR TABELAS TEMP DE ALIQ E PMC
    PROCEDURE load_aliq_pmc ( vp_proc_id IN NUMBER
                            , vp_nome_tabela_aliq   OUT VARCHAR2
                            , vp_nome_tabela_pmc   OUT VARCHAR2
                            , vp_tab_perdas_inv IN VARCHAR2 )
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
        v_sql := v_sql || '       FROM ' || vp_tab_perdas_inv || ' A, ';
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

    PROCEDURE create_perdas_tmp_tbl ( vp_proc_instance IN NUMBER
                                    , vp_tab_perdas_tmp   OUT VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 4000 );
    BEGIN
        vp_tab_perdas_tmp := 'DPSP_PERDAS_' || vp_proc_instance;

        v_sql := 'CREATE TABLE ' || vp_tab_perdas_tmp || ' ( ';
        v_sql := v_sql || 'PROC_ID      NUMBER(30), ';
        v_sql := v_sql || 'COD_EMPRESA  VARCHAR2(3), ';
        v_sql := v_sql || 'COD_ESTAB    VARCHAR2(6), ';
        v_sql := v_sql || 'COD_PRODUTO  VARCHAR2(35), ';
        v_sql := v_sql || 'DATA_INV      DATE, ';
        v_sql := v_sql || 'QTD_SALDO  NUMBER(15,2), ';
        v_sql := v_sql || 'QTD_CONTAGEM  NUMBER(15,2), ';
        v_sql := v_sql || 'QTD_AJUSTE  NUMBER(15,2), ';
        v_sql := v_sql || 'VLR_CUSTO  NUMBER(15,2), ';
        ---
        v_sql := v_sql || 'COD_ESTAB_E           VARCHAR2(6), ';
        v_sql := v_sql || 'DATA_FISCAL_E         DATE, ';
        v_sql := v_sql || 'MOVTO_E_S_E           VARCHAR2(1), ';
        v_sql := v_sql || 'NORM_DEV_E            VARCHAR2(1), ';
        v_sql := v_sql || 'IDENT_DOCTO_E         VARCHAR2(12), ';
        v_sql := v_sql || 'IDENT_FIS_JUR_E       VARCHAR2(12), ';
        v_sql := v_sql || 'SUB_SERIE_DOCFIS_E    VARCHAR2(2), ';
        v_sql := v_sql || 'DISCRI_ITEM_E         VARCHAR2(46), ';
        v_sql := v_sql || 'DATA_EMISSAO_E     DATE, ';
        v_sql := v_sql || 'NUM_DOCFIS_E          VARCHAR2(12), ';
        v_sql := v_sql || 'SERIE_DOCFIS_E        VARCHAR2(3), ';
        v_sql := v_sql || 'NUM_ITEM_E            NUMBER(5), ';
        v_sql := v_sql || 'COD_FIS_JUR_E     VARCHAR2(14), ';
        v_sql := v_sql || 'CPF_CGC_E       VARCHAR2(14), ';
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
        v_sql := v_sql || 'VLR_ICMS_UNIT_E     NUMBER(17,2), ';
        v_sql := v_sql || 'ALIQ_ICMS_E       NUMBER(17,2), ';
        v_sql := v_sql || 'BASE_ST_UNIT_E     NUMBER(17,2), ';
        v_sql := v_sql || 'VLR_ICMS_ST_UNIT_E    NUMBER(17,2), ';
        v_sql := v_sql || 'VLR_ICMS_ST_UNIT_AUX  NUMBER(17,2), ';
        v_sql := v_sql || 'STAT_LIBER_CNTR       VARCHAR2(10), ';
        ---
        v_sql := v_sql || 'TIPO_AJUSTE           VARCHAR2(1)) ';
        v_sql := v_sql || 'PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        v_sql := 'CREATE UNIQUE INDEX PK_PERDAS_' || vp_proc_instance || ' ON ' || vp_tab_perdas_tmp || ' ';
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || ' PROC_ID      ASC, ';
        v_sql := v_sql || ' COD_EMPRESA  ASC, ';
        v_sql := v_sql || '  COD_ESTAB    ASC, ';
        v_sql := v_sql || '  COD_PRODUTO  ASC, ';
        v_sql := v_sql || '  DATA_INV   ASC, ';
        v_sql := v_sql || '  TIPO_AJUSTE   ASC ';
        v_sql := v_sql || ' ) ';
        v_sql := v_sql || 'PCTFREE     10 ';

        EXECUTE IMMEDIATE v_sql;

        ---
        save_tmp_control ( vp_proc_instance
                         , vp_tab_perdas_tmp );
    END;

    PROCEDURE get_entradas_cd ( vp_id_upload IN VARCHAR2
                              , vp_proc_id IN NUMBER
                              , vp_filial IN VARCHAR2
                              , vp_cd IN VARCHAR2
                              , vp_data_ini IN DATE
                              , vp_data_fim IN DATE
                              , vp_tab_perdas_ent_c IN VARCHAR2
                              , vp_tab_perdas_inv IN VARCHAR2
                              , vp_tab_perdas_nf IN VARCHAR2
                              , vp_tab_perdas_tmp IN VARCHAR2 )
    IS
        v_sql VARCHAR ( 4000 );
    BEGIN
        v_sql := 'INSERT /*+APPEND*/ INTO ' || vp_tab_perdas_tmp || ' ( ';
        --V_SQL := V_SQL || '  SELECT  /*+PARALLEL(6)*/ ';
        v_sql := v_sql || '  SELECT DISTINCT ';
        v_sql := v_sql || '  ' || vp_proc_id || ', ';
        v_sql := v_sql || '  ''' || mcod_empresa || ''', ';
        v_sql := v_sql || ' A.COD_ESTAB, ';
        v_sql := v_sql || ' A.COD_PRODUTO, ';
        v_sql := v_sql || ' A.DATA_INV, ';
        v_sql := v_sql || ' A.QTD_SALDO, ';
        v_sql := v_sql || ' A.QTD_CONTAGEM, ';
        v_sql := v_sql || ' A.QTD_AJUSTE, ';
        v_sql := v_sql || ' A.VLR_CUSTO, ';
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
        v_sql := v_sql || '  C.VLR_ICMS_UNIT, ';
        v_sql := v_sql || '  C.ALIQ_ICMS, ';
        v_sql := v_sql || '  C.BASE_ST_UNIT, ';
        v_sql := v_sql || '  C.VLR_ICMS_ST_UNIT, ';
        v_sql := v_sql || '  C.VLR_ICMS_ST_UNIT_AUX, ';
        ---
        v_sql :=
            v_sql || '  DECODE(E.LIBER_CNTR_DSP,''C'',''CONTROLADO'',''L'',''LIBERADO'',''OUTRO'') STAT_LIBER_CNTR, ';
        v_sql := v_sql || '  A.TIPO_AJUSTE ';
        ---
        v_sql := v_sql || '  FROM ' || vp_tab_perdas_inv || ' A, ';
        v_sql := v_sql || '     ' || vp_tab_perdas_ent_c || ' B, ';
        v_sql := v_sql || '     ' || vp_tab_perdas_nf || ' C, ';
        v_sql := v_sql || '         MSAFI.DSP_INTERFACE_SETUP D, ';
        v_sql := v_sql || '         MSAFI.PS_ATRB_OPER_DSP E ';
        v_sql := v_sql || '  WHERE A.ID_UPLOAD     = ''' || vp_id_upload || ''' ';
        v_sql := v_sql || '    AND A.PROC_ID      = ''' || vp_proc_id || ''' ';
        v_sql := v_sql || '    AND A.COD_ESTAB     = ''' || vp_filial || ''' ';
        ---
        v_sql := v_sql || '    AND B.PROC_ID       = A.PROC_ID ';
        v_sql := v_sql || '    AND B.COD_EMPRESA   = ''' || mcod_empresa || ''' ';
        v_sql := v_sql || '    AND B.COD_ESTAB     = ''' || vp_cd || ''' ';
        v_sql := v_sql || '    AND B.COD_PRODUTO   = A.COD_PRODUTO ';
        --V_SQL := V_SQL || '    AND B.DATA_FISCAL   = (SELECT /*+PARALLEL_INDEX(BB IDX1_P_E_C_' || VP_PROC_ID || ', 6)*/ MAX(BB.DATA_FISCAL) ';
        v_sql := v_sql || '    AND B.DATA_FISCAL   = (SELECT MAX(BB.DATA_FISCAL) ';
        v_sql := v_sql || '                   FROM ' || vp_tab_perdas_ent_c || ' BB ';
        v_sql := v_sql || '                  WHERE BB.PROC_ID       = B.PROC_ID ';
        v_sql := v_sql || '                    AND BB.COD_EMPRESA   = B.COD_EMPRESA ';
        v_sql := v_sql || '                    AND BB.COD_ESTAB     = B.COD_ESTAB ';
        v_sql := v_sql || '                    AND BB.COD_PRODUTO   = B.COD_PRODUTO ';
        v_sql := v_sql || '                    AND BB.DATA_FISCAL   < A.DATA_INV) ';
        ---
        --V_SQL := V_SQL || '   AND NOT EXISTS (SELECT /*+PARALLEL_INDEX(C PK_PERDAS_' || VP_PROC_ID || ', 6)*/ ''Y'' ';
        v_sql := v_sql || '    AND NOT EXISTS (SELECT ''Y'' ';
        v_sql := v_sql || '            FROM ' || vp_tab_perdas_tmp || ' C ';
        v_sql := v_sql || '              WHERE C.PROC_ID      = ' || vp_proc_id || ' ';
        v_sql := v_sql || '              AND C.COD_EMPRESA  = ''' || mcod_empresa || ''' ';
        v_sql := v_sql || '              AND C.COD_ESTAB    = A.COD_ESTAB ';
        v_sql := v_sql || '              AND C.COD_PRODUTO  = A.COD_PRODUTO ';
        v_sql := v_sql || '              AND C.DATA_INV     = A.DATA_INV) ';
        v_sql := v_sql || '    AND D.COD_EMPRESA        = ''' || mcod_empresa || ''' ';
        v_sql := v_sql || '    AND A.PROC_ID        = C.PROC_ID ';
        v_sql := v_sql || '    AND D.BU_PO1          = C.BUSINESS_UNIT ';
        v_sql := v_sql || '    AND B.NUM_CONTROLE_DOCTO = C.NF_BRL_ID ';
        v_sql := v_sql || '    AND B.NUM_ITEM        = C.NF_BRL_LINE_NUM ';
        ---
        v_sql := v_sql || '    AND E.SETID          = ''GERAL'' ';
        v_sql := v_sql || '    AND E.INV_ITEM_ID      = A.COD_PRODUTO ) ';

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
                                      , vp_tab_perdas_tmp );
        loga ( 'C_ENTR_CD-FIM-' || vp_cd || '-' || vp_filial
             , FALSE );
    END; --GET_ENTRADAS_CD

    PROCEDURE get_entradas_filial ( vp_id_upload IN VARCHAR2
                                  , vp_proc_id IN NUMBER
                                  , vp_filial IN VARCHAR2
                                  , vp_cd IN VARCHAR2
                                  , vp_data_ini IN DATE
                                  , vp_data_fim IN DATE
                                  , vp_tab_perdas_ent_f IN VARCHAR2
                                  , vp_tab_perdas_inv IN VARCHAR2
                                  , vp_tab_perdas_nf IN VARCHAR2
                                  , vp_tab_perdas_tmp IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 4000 );
    BEGIN
        v_sql := 'INSERT /*+APPEND*/ INTO ' || vp_tab_perdas_tmp || ' ( ';
        --V_SQL := V_SQL || '  SELECT  /*+PARALLEL(6)*/ ';
        v_sql := v_sql || '  SELECT  DISTINCT  ';
        v_sql := v_sql || '      ' || vp_proc_id || ', ';
        v_sql := v_sql || '      ''' || mcod_empresa || ''', ';
        v_sql := v_sql || '        A.COD_ESTAB, ';
        v_sql := v_sql || '          A.COD_PRODUTO, ';
        v_sql := v_sql || '          A.DATA_INV, ';
        v_sql := v_sql || '          A.QTD_SALDO, ';
        v_sql := v_sql || '          A.QTD_CONTAGEM, ';
        v_sql := v_sql || '          A.QTD_AJUSTE, ';
        v_sql := v_sql || '          A.VLR_CUSTO, ';
        ---
        v_sql := v_sql || '          B.COD_ESTAB, ';
        v_sql := v_sql || '          B.DATA_FISCAL, ';
        v_sql := v_sql || '          B.MOVTO_E_S, ';
        v_sql := v_sql || '          B.NORM_DEV, ';
        v_sql := v_sql || '          B.IDENT_DOCTO, ';
        v_sql := v_sql || '          B.IDENT_FIS_JUR, ';
        v_sql := v_sql || '          B.SUB_SERIE_DOCFIS, ';
        v_sql := v_sql || '          B.DISCRI_ITEM, ';
        v_sql := v_sql || '          B.DATA_EMISSAO, ';
        v_sql := v_sql || '          B.NUM_DOCFIS, ';
        v_sql := v_sql || '          B.SERIE_DOCFIS, ';
        v_sql := v_sql || '      B.NUM_ITEM, ';
        v_sql := v_sql || '      B.COD_FIS_JUR, ';
        v_sql := v_sql || '      B.CPF_CGC, ';
        v_sql := v_sql || '          B.COD_NBM, ';
        v_sql := v_sql || '          B.COD_CFO, ';
        v_sql := v_sql || '          B.COD_NATUREZA_OP, ';
        v_sql := v_sql || '          B.COD_PRODUTO, ';
        v_sql := v_sql || '          B.VLR_CONTAB_ITEM, ';
        v_sql := v_sql || '          B.QUANTIDADE, ';
        v_sql := v_sql || '          B.VLR_UNIT, ';
        v_sql := v_sql || '          B.COD_SITUACAO_B, ';
        v_sql := v_sql || '          B.COD_ESTADO, ';
        v_sql := v_sql || '          B.NUM_CONTROLE_DOCTO, ';
        v_sql := v_sql || '          B.NUM_AUTENTIC_NFE, ';
        ---
        v_sql := v_sql || '          C.BASE_ICMS_UNIT, ';
        v_sql := v_sql || '         C.VLR_ICMS_UNIT, ';
        v_sql := v_sql || '         C.ALIQ_ICMS, ';
        v_sql := v_sql || '         C.BASE_ST_UNIT, ';
        v_sql := v_sql || '         C.VLR_ICMS_ST_UNIT, ';
        v_sql := v_sql || '         C.VLR_ICMS_ST_UNIT_AUX, ';
        ---
        v_sql :=
               v_sql
            || '         DECODE(E.LIBER_CNTR_DSP,''C'',''CONTROLADO'',''L'',''LIBERADO'',''OUTRO'') STAT_LIBER_CNTR, ';
        v_sql := v_sql || '         A.TIPO_AJUSTE ';
        ---
        v_sql := v_sql || '  FROM ' || vp_tab_perdas_inv || ' A, ';
        v_sql := v_sql || '     ' || vp_tab_perdas_ent_f || ' B, ';
        v_sql := v_sql || '     ' || vp_tab_perdas_nf || ' C, ';
        v_sql := v_sql || '      MSAFI.DSP_INTERFACE_SETUP D, ';
        v_sql := v_sql || '      MSAFI.PS_ATRB_OPER_DSP E ';
        v_sql := v_sql || '  WHERE A.COD_ESTAB     = ''' || vp_filial || ''' ';
        v_sql := v_sql || '    AND A.PROC_ID       = ''' || vp_proc_id || ''' ';
        v_sql := v_sql || '    AND A.ID_UPLOAD    = ''' || vp_id_upload || ''' ';
        ---
        v_sql := v_sql || '    AND B.PROC_ID       = A.PROC_ID ';
        v_sql := v_sql || '   AND B.COD_EMPRESA   = ''' || mcod_empresa || ''' ';
        v_sql := v_sql || '   AND B.COD_ESTAB    = A.COD_ESTAB ';
        v_sql := v_sql || '    AND B.COD_PRODUTO    = A.COD_PRODUTO ';
        v_sql := v_sql || '   AND B.COD_FIS_JUR   = ''' || vp_cd || ''' ';
        --V_SQL := V_SQL || '    AND B.DATA_FISCAL   = (SELECT /*+PARALLEL_INDEX(BB IDX1_P_E_F_' || VP_PROC_ID || ', 12)*/ MAX(BB.DATA_FISCAL) ';
        v_sql := v_sql || '    AND B.DATA_FISCAL   = (SELECT MAX(BB.DATA_FISCAL) ';
        v_sql := v_sql || '                 FROM ' || vp_tab_perdas_ent_f || ' BB ';
        v_sql := v_sql || '                 WHERE BB.PROC_ID       = B.PROC_ID ';
        v_sql := v_sql || '                   AND BB.COD_EMPRESA   = B.COD_EMPRESA ';
        v_sql := v_sql || '                   AND BB.COD_ESTAB     = B.COD_ESTAB ';
        v_sql := v_sql || '                   AND BB.COD_PRODUTO   = B.COD_PRODUTO ';
        v_sql := v_sql || '                   AND BB.DATA_FISCAL   < A.DATA_INV) ';
        ---
        --V_SQL := V_SQL || '   AND NOT EXISTS (SELECT /*+PARALLEL_INDEX(C PK_PERDAS_' || VP_PROC_ID || ', 12)*/ ''Y''  ';
        v_sql := v_sql || '   AND NOT EXISTS (SELECT ''Y''  ';
        v_sql := v_sql || '            FROM ' || vp_tab_perdas_tmp || ' C ';
        v_sql := v_sql || '            WHERE C.PROC_ID      = ''' || vp_proc_id || ''' ';
        v_sql := v_sql || '              AND C.COD_EMPRESA  = ''' || mcod_empresa || ''' ';
        v_sql := v_sql || '              AND C.COD_ESTAB    = A.COD_ESTAB ';
        v_sql := v_sql || '              AND C.COD_PRODUTO  = A.COD_PRODUTO ';
        v_sql := v_sql || '              AND C.DATA_INV     = A.DATA_INV) ';
        ---
        v_sql := v_sql || '    AND D.COD_EMPRESA        = ''' || mcod_empresa || ''' ';
        v_sql := v_sql || '   AND A.PROC_ID         = C.PROC_ID ';
        v_sql := v_sql || '   AND D.BU_PO1         = C.BUSINESS_UNIT ';
        v_sql := v_sql || '   AND B.NUM_CONTROLE_DOCTO = C.NF_BRL_ID ';
        v_sql := v_sql || '   AND B.NUM_ITEM       = C.NF_BRL_LINE_NUM ';
        ---
        v_sql := v_sql || '   AND E.SETID       = ''GERAL'' ';
        v_sql := v_sql || '   AND E.INV_ITEM_ID = A.COD_PRODUTO ) ';

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
                                      , vp_tab_perdas_tmp );
        loga ( 'C_ENTR_FILIAL-FIM-' || vp_cd || '->' || vp_filial
             , FALSE );
    END; --GET_ENTRADAS_FILIAL

    PROCEDURE get_compra_direta ( vp_id_upload IN VARCHAR2
                                , vp_proc_id IN NUMBER
                                , vp_filial IN VARCHAR2
                                , vp_data_ini IN DATE
                                , vp_data_fim IN DATE
                                , vp_tab_perdas_ent_d IN VARCHAR2
                                , vp_tab_perdas_inv IN VARCHAR
                                , vp_tab_perdas_nf IN VARCHAR2
                                , vp_tab_perdas_tmp IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 4000 );
    BEGIN
        v_sql := 'INSERT /*+APPEND*/ INTO ' || vp_tab_perdas_tmp || ' ( ';
        --V_SQL := V_SQL || '  SELECT  /*+PARALLEL(6)*/ ';
        v_sql := v_sql || '  SELECT  DISTINCT ';
        v_sql := v_sql || '      ' || vp_proc_id || ', ';
        v_sql := v_sql || '      ''' || mcod_empresa || ''', ';
        v_sql := v_sql || '        A.COD_ESTAB, ';
        v_sql := v_sql || '          A.COD_PRODUTO, ';
        v_sql := v_sql || '          A.DATA_INV, ';
        v_sql := v_sql || '          A.QTD_SALDO, ';
        v_sql := v_sql || '          A.QTD_CONTAGEM, ';
        v_sql := v_sql || '          A.QTD_AJUSTE, ';
        v_sql := v_sql || '          A.VLR_CUSTO, ';
        ---
        v_sql := v_sql || '          B.COD_ESTAB, ';
        v_sql := v_sql || '          B.DATA_FISCAL, ';
        v_sql := v_sql || '          B.MOVTO_E_S, ';
        v_sql := v_sql || '          B.NORM_DEV, ';
        v_sql := v_sql || '          B.IDENT_DOCTO, ';
        v_sql := v_sql || '          B.IDENT_FIS_JUR, ';
        v_sql := v_sql || '          B.SUB_SERIE_DOCFIS, ';
        v_sql := v_sql || '          B.DISCRI_ITEM, ';
        v_sql := v_sql || '          B.DATA_EMISSAO, ';
        v_sql := v_sql || '          B.NUM_DOCFIS, ';
        v_sql := v_sql || '          B.SERIE_DOCFIS, ';
        v_sql := v_sql || '      B.NUM_ITEM, ';
        v_sql := v_sql || '      B.COD_FIS_JUR, ';
        v_sql := v_sql || '      B.CPF_CGC, ';
        v_sql := v_sql || '          B.COD_NBM, ';
        v_sql := v_sql || '          B.COD_CFO, ';
        v_sql := v_sql || '          B.COD_NATUREZA_OP, ';
        v_sql := v_sql || '          B.COD_PRODUTO, ';
        v_sql := v_sql || '          B.VLR_CONTAB_ITEM, ';
        v_sql := v_sql || '          B.QUANTIDADE, ';
        v_sql := v_sql || '          B.VLR_UNIT, ';
        v_sql := v_sql || '          B.COD_SITUACAO_B, ';
        v_sql := v_sql || '          B.COD_ESTADO, ';
        v_sql := v_sql || '          B.NUM_CONTROLE_DOCTO, ';
        v_sql := v_sql || '          B.NUM_AUTENTIC_NFE, ';
        ---
        v_sql := v_sql || '          C.BASE_ICMS_UNIT, ';
        v_sql := v_sql || '         C.VLR_ICMS_UNIT, ';
        v_sql := v_sql || '         C.ALIQ_ICMS, ';
        v_sql := v_sql || '         C.BASE_ST_UNIT, ';
        v_sql := v_sql || '         C.VLR_ICMS_ST_UNIT, ';
        v_sql := v_sql || '         C.VLR_ICMS_ST_UNIT_AUX, ';
        ---
        v_sql :=
               v_sql
            || '         DECODE(E.LIBER_CNTR_DSP,''C'',''CONTROLADO'',''L'',''LIBERADO'',''OUTRO'') STAT_LIBER_CNTR, ';
        v_sql := v_sql || '         A.TIPO_AJUSTE ';
        ---
        v_sql := v_sql || '  FROM ' || vp_tab_perdas_inv || ' A, ';
        v_sql := v_sql || '     ' || vp_tab_perdas_ent_d || ' B, ';
        v_sql := v_sql || '     ' || vp_tab_perdas_nf || ' C, ';
        v_sql := v_sql || '      MSAFI.DSP_INTERFACE_SETUP D, ';
        v_sql := v_sql || '      MSAFI.PS_ATRB_OPER_DSP E ';
        v_sql := v_sql || '  WHERE A.ID_UPLOAD     = ''' || vp_id_upload || ''' ';
        v_sql := v_sql || '   AND A.COD_ESTAB     = ''' || vp_filial || ''' ';
        v_sql := v_sql || '   AND A.PROC_ID       = ''' || vp_proc_id || ''' ';
        ---
        v_sql := v_sql || '   AND B.PROC_ID       = A.PROC_ID ';
        v_sql := v_sql || '   AND B.COD_EMPRESA   = ''' || mcod_empresa || ''' ';
        v_sql := v_sql || '   AND B.COD_ESTAB     = A.COD_ESTAB ';
        v_sql := v_sql || '   AND B.COD_PRODUTO   = A.COD_PRODUTO ';
        --V_SQL := V_SQL || '    AND B.DATA_FISCAL   = (SELECT /*+PARALLEL_INDEX(BB IDX1_P_E_D_' || VP_PROC_ID || ', 12)*/ MAX(BB.DATA_FISCAL) ';
        v_sql := v_sql || '    AND B.DATA_FISCAL   = (SELECT MAX(BB.DATA_FISCAL) ';
        v_sql := v_sql || '                   FROM ' || vp_tab_perdas_ent_d || ' BB ';
        v_sql := v_sql || '                  WHERE BB.PROC_ID       = B.PROC_ID ';
        v_sql := v_sql || '                    AND BB.COD_EMPRESA   = B.COD_EMPRESA ';
        v_sql := v_sql || '                    AND BB.COD_ESTAB     = B.COD_ESTAB ';
        v_sql := v_sql || '                    AND BB.COD_PRODUTO   = B.COD_PRODUTO ';
        v_sql := v_sql || '                    AND BB.DATA_FISCAL   < A.DATA_INV) ';
        ---
        --V_SQL := V_SQL || '   AND NOT EXISTS (SELECT /*+PARALLEL_INDEX(C PK_PERDAS_' || VP_PROC_ID || ', 12)*/ ''Y'' ';
        v_sql := v_sql || '   AND NOT EXISTS (SELECT ''Y'' ';
        v_sql := v_sql || '            FROM ' || vp_tab_perdas_tmp || ' C ';
        v_sql := v_sql || '            WHERE C.PROC_ID      = ''' || vp_proc_id || ''' ';
        v_sql := v_sql || '              AND C.COD_EMPRESA  = ''' || mcod_empresa || ''' ';
        v_sql := v_sql || '              AND C.COD_ESTAB    = A.COD_ESTAB ';
        v_sql := v_sql || '              AND C.COD_PRODUTO  = A.COD_PRODUTO ';
        v_sql := v_sql || '              AND C.DATA_INV     = A.DATA_INV) ';
        ---
        v_sql := v_sql || '    AND D.COD_EMPRESA        = ''' || mcod_empresa || ''' ';
        v_sql := v_sql || '   AND A.PROC_ID         = C.PROC_ID ';
        v_sql := v_sql || '   AND D.BU_PO1         = C.BUSINESS_UNIT ';
        v_sql := v_sql || '   AND B.NUM_CONTROLE_DOCTO = C.NF_BRL_ID ';
        v_sql := v_sql || '   AND B.NUM_ITEM       = C.NF_BRL_LINE_NUM ';
        ---
        v_sql := v_sql || '   AND E.SETID          = ''GERAL'' ';
        v_sql := v_sql || '   AND E.INV_ITEM_ID      = A.COD_PRODUTO ) ';

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
                                        , '!ERRO INSERT GET_COMPRA_DIRETA!' );
        END;

        dbms_stats.gather_table_stats ( 'MSAF'
                                      , vp_tab_perdas_tmp );
        loga ( 'C_COMPRA_DIRETA-FIM-' || vp_filial
             , FALSE );
    END; --GET_COMPRA_DIRETA

    PROCEDURE get_sem_entrada ( vp_id_upload IN VARCHAR2
                              , vp_proc_id IN NUMBER
                              , vp_filial IN VARCHAR2
                              , vp_data_ini IN DATE
                              , vp_data_fim IN DATE
                              , vp_tab_perdas_inv IN VARCHAR2
                              , vp_tab_perdas_tmp IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 4000 );
    BEGIN
        v_sql := 'INSERT /*+APPEND*/ INTO ' || vp_tab_perdas_tmp || ' ( ';
        --V_SQL := V_SQL || '  SELECT  /*+PARALLEL(6)*/ ';
        v_sql := v_sql || '  SELECT  ' || vp_proc_id || ', ';
        v_sql := v_sql || '      ''' || mcod_empresa || ''', ';
        v_sql := v_sql || '        A.COD_ESTAB, ';
        v_sql := v_sql || '          A.COD_PRODUTO, ';
        v_sql := v_sql || '          A.DATA_INV, ';
        v_sql := v_sql || '          A.QTD_SALDO, ';
        v_sql := v_sql || '          A.QTD_CONTAGEM, ';
        v_sql := v_sql || '          A.QTD_AJUSTE, ';
        v_sql := v_sql || '          A.VLR_CUSTO, ';
        ---
        v_sql := v_sql || '          '''','; --B.COD_ESTAB,
        v_sql := v_sql || '          NULL,'; --B.DATA_FISCAL,
        v_sql := v_sql || '          '''','; --B.MOVTO_E_S,
        v_sql := v_sql || '          '''','; --B.NORM_DEV,
        v_sql := v_sql || '          '''','; --B.IDENT_DOCTO,
        v_sql := v_sql || '          '''','; --B.IDENT_FIS_JUR,
        v_sql := v_sql || '          '''','; --B.SUB_SERIE_DOCFIS,
        v_sql := v_sql || '          '''','; --B.DISCRI_ITEM,
        v_sql := v_sql || '          NULL,'; --B.DATA_EMISSAO,
        v_sql := v_sql || '          '''','; --B.NUM_DOCFIS,
        v_sql := v_sql || '          '''','; --B.SERIE_DOCFIS,
        v_sql := v_sql || '      0,   '; --B.NUM_ITEM,
        v_sql := v_sql || '      '''','; --B.COD_FIS_JUR,
        v_sql := v_sql || '      '''','; --B.CPF_CGC,
        v_sql := v_sql || '          '''','; --B.COD_NBM,
        v_sql := v_sql || '          '''','; --B.COD_CFO,
        v_sql := v_sql || '          '''','; --B.COD_NATUREZA_OP,
        v_sql := v_sql || '          '''','; --B.COD_PRODUTO,
        v_sql := v_sql || '          0,   '; --B.VLR_CONTAB_ITEM,
        v_sql := v_sql || '          0,   '; --B.QUANTIDADE,
        v_sql := v_sql || '          0,   '; --B.VLR_UNIT,
        v_sql := v_sql || '          '''','; --B.COD_SITUACAO_B,
        v_sql := v_sql || '          '''','; --B.COD_ESTADO,
        v_sql := v_sql || '          '''','; --B.NUM_CONTROLE_DOCTO,
        v_sql := v_sql || '          '''','; --B.NUM_AUTENTIC_NFE,
        v_sql := v_sql || '      0,   '; --BASE_ICMS_UNIT,
        v_sql := v_sql || '         0,   '; --VLR_ICMS_UNIT,
        v_sql := v_sql || '         0,   '; --ALIQ_ICMS,
        v_sql := v_sql || '         0,   '; --BASE_ST_UNIT,
        v_sql := v_sql || '         0,    '; --VLR_ICMS_ST_UNIT,
        v_sql := v_sql || '         0,   '; --VLR_ICMS_ST_UNIT_AUX
        v_sql := v_sql || '         '''','; --STAT_LIBER_CNTR
        v_sql := v_sql || '         A.TIPO_AJUSTE '; --VLR_ICMS_ST_UNIT_AUX
        v_sql := v_sql || '  FROM ' || vp_tab_perdas_inv || ' A ';
        v_sql := v_sql || '  WHERE A.ID_UPLOAD     = ''' || vp_id_upload || ''' ';
        v_sql := v_sql || '   AND A.COD_ESTAB     = ''' || vp_filial || ''' ';
        v_sql := v_sql || '   AND A.PROC_ID       = ''' || vp_proc_id || ''' ';
        ---
        --V_SQL := V_SQL || '   AND NOT EXISTS (SELECT /*+PARALLEL_INDEX(C PK_PERDAS_' || VP_PROC_ID || ', 12)*/ ''Y'' ';
        v_sql := v_sql || '   AND NOT EXISTS (SELECT ''Y'' ';
        v_sql := v_sql || '            FROM ' || vp_tab_perdas_tmp || ' C ';
        v_sql := v_sql || '            WHERE C.PROC_ID      = ''' || vp_proc_id || ''' ';
        v_sql := v_sql || '              AND C.COD_EMPRESA  = ''' || mcod_empresa || ''' ';
        v_sql := v_sql || '              AND C.COD_ESTAB    = A.COD_ESTAB ';
        v_sql := v_sql || '              AND C.COD_PRODUTO  = A.COD_PRODUTO ';
        v_sql := v_sql || '              AND C.DATA_INV     = A.DATA_INV)) ';

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
                                      , vp_tab_perdas_tmp );
        loga ( 'C_SEM_ENTRADA-FIM-' || vp_filial
             , FALSE );
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

        vp_tabela_nf := 'DPSP_MSAF_P_NF_' || vp_proc_id;

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
            v_sql := ' SELECT   DISTINCT ';
            v_sql := v_sql || '        ' || vp_proc_id || ', ';
            v_sql := v_sql || '        A.BUSINESS_UNIT, ';
            v_sql := v_sql || '        A.NF_BRL_ID, ';
            v_sql := v_sql || '        A.NF_BRL_LINE_NUM, ';
            v_sql := v_sql || '        A.BASE_ICMS_UNIT, ';
            v_sql := v_sql || '        A.VLR_ICMS_UNIT, ';
            v_sql := v_sql || '        A.ALIQ_ICMS, ';
            v_sql := v_sql || '        A.BASE_ST_UNIT, ';
            v_sql := v_sql || '        A.VLR_ICMS_ST_UNIT, ';
            v_sql := v_sql || '        A.VLR_ICMS_ST_UNIT_AUX ';
            v_sql := v_sql || '  FROM ( ';
            v_sql := v_sql || '        SELECT /*+DRIVING_SITE(C)*/ ';
            v_sql := v_sql || '               C.BUSINESS_UNIT, ';
            v_sql := v_sql || '               C.NF_BRL_ID, ';
            v_sql := v_sql || '               C.NF_BRL_LINE_NUM, ';
            v_sql := v_sql || '               C.BASE_ICMS_UNIT, ';
            v_sql := v_sql || '               C.VLR_ICMS_UNIT, ';
            v_sql := v_sql || '               C.ALIQ_ICMS,  ';
            v_sql := v_sql || '               C.BASE_ST_UNIT, ';
            v_sql := v_sql || '               C.VLR_ICMS_ST_UNIT, ';
            v_sql := v_sql || '               C.VLR_ICMS_ST_UNIT_AUX ';
            v_sql := v_sql || '        FROM ' || vp_tab_entrada_c || ' A, ';
            v_sql := v_sql || '             MSAFI.DSP_INTERFACE_SETUP B, ';
            v_sql := v_sql || '            (SELECT C.BUSINESS_UNIT, ';
            v_sql := v_sql || '                    C.NF_BRL_ID, ';
            v_sql := v_sql || '                    C.NF_BRL_LINE_NUM, ';
            v_sql :=
                v_sql || '                    NVL(TRUNC(C.ICMSTAX_BRL_BSS/C.QTY_NF_BRL, 2), 0) AS BASE_ICMS_UNIT, ';
            v_sql := v_sql || '                    NVL(TRUNC(C.ICMSTAX_BRL_AMT/C.QTY_NF_BRL, 2), 0) AS VLR_ICMS_UNIT, ';
            v_sql := v_sql || '                    NVL(C.ICMSTAX_BRL_PCT, 0) AS ALIQ_ICMS,  ';
            v_sql :=
                   v_sql
                || '                    TRUNC(DECODE(NVL(C.DSP_ICMS_BSS_ST, 0), 0, NVL(C.DSP_ICMSSUBBRL_BSS, 0), NVL(C.DSP_ICMS_BSS_ST, 0))/C.QTY_NF_BRL, 2) AS BASE_ST_UNIT, ';
            v_sql :=
                   v_sql
                || '                    TRUNC(DECODE(NVL(C.DSP_ICMS_AMT_ST, 0), 0, NVL(C.DSP_ICMSSUBBRL_AMT, 0), NVL(C.DSP_ICMS_AMT_ST, 0))/C.QTY_NF_BRL, 2) AS VLR_ICMS_ST_UNIT, ';
            v_sql :=
                v_sql || '                    TRUNC(NVL(C.ICMSSUB_BRL_AMT,0)/C.QTY_NF_BRL, 2) AS VLR_ICMS_ST_UNIT_AUX ';
            v_sql := v_sql || '             FROM MSAFI.PS_NF_LN_BRL C ) C ';
            v_sql := v_sql || '        WHERE A.PROC_ID       = ''' || vp_proc_id || ''' ';
            v_sql := v_sql || '          AND A.COD_EMPRESA     = ''' || vp_cod_empresa || ''' ';
            v_sql := v_sql || '          AND B.COD_EMPRESA         = A.COD_EMPRESA ';
            v_sql := v_sql || '          AND C.BUSINESS_UNIT       = B.BU_PO1 ';
            v_sql := v_sql || '          AND C.NF_BRL_ID           = A.NUM_CONTROLE_DOCTO ';
            v_sql := v_sql || '          AND C.NF_BRL_LINE_NUM     = A.NUM_ITEM ';
            v_sql := v_sql || '    ) A ';

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
            v_sql := ' SELECT   DISTINCT ';
            v_sql := v_sql || '        ' || vp_proc_id || ', ';
            v_sql := v_sql || '        A.BUSINESS_UNIT, ';
            v_sql := v_sql || '        A.NF_BRL_ID, ';
            v_sql := v_sql || '        A.NF_BRL_LINE_NUM, ';
            v_sql := v_sql || '        A.BASE_ICMS_UNIT, ';
            v_sql := v_sql || '        A.VLR_ICMS_UNIT, ';
            v_sql := v_sql || '        A.ALIQ_ICMS, ';
            v_sql := v_sql || '        A.BASE_ST_UNIT, ';
            v_sql := v_sql || '        A.VLR_ICMS_ST_UNIT, ';
            v_sql := v_sql || '        A.VLR_ICMS_ST_UNIT_AUX ';
            v_sql := v_sql || '  FROM ( ';
            v_sql := v_sql || '        SELECT /*+DRIVING_SITE(C)*/ ';
            v_sql := v_sql || '               C.BUSINESS_UNIT, ';
            v_sql := v_sql || '               C.NF_BRL_ID, ';
            v_sql := v_sql || '               C.NF_BRL_LINE_NUM, ';
            v_sql := v_sql || '               C.BASE_ICMS_UNIT, ';
            v_sql := v_sql || '               C.VLR_ICMS_UNIT, ';
            v_sql := v_sql || '               C.ALIQ_ICMS,  ';
            v_sql := v_sql || '               C.BASE_ST_UNIT, ';
            v_sql := v_sql || '               C.VLR_ICMS_ST_UNIT, ';
            v_sql := v_sql || '               C.VLR_ICMS_ST_UNIT_AUX ';
            v_sql := v_sql || '        FROM ' || vp_tab_entrada_f || ' A, ';
            v_sql := v_sql || '             MSAFI.DSP_INTERFACE_SETUP B, ';
            v_sql := v_sql || '            (SELECT C.BUSINESS_UNIT, ';
            v_sql := v_sql || '                    C.NF_BRL_ID, ';
            v_sql := v_sql || '                    C.NF_BRL_LINE_NUM, ';
            v_sql :=
                v_sql || '                    NVL(TRUNC(C.ICMSTAX_BRL_BSS/C.QTY_NF_BRL, 2), 0) AS BASE_ICMS_UNIT, ';
            v_sql := v_sql || '                    NVL(TRUNC(C.ICMSTAX_BRL_AMT/C.QTY_NF_BRL, 2), 0) AS VLR_ICMS_UNIT, ';
            v_sql := v_sql || '                    NVL(C.ICMSTAX_BRL_PCT, 0) AS ALIQ_ICMS,  ';
            v_sql :=
                   v_sql
                || '                    TRUNC(DECODE(NVL(C.DSP_ICMS_BSS_ST, 0), 0, NVL(C.DSP_ICMSSUBBRL_BSS, 0), NVL(C.DSP_ICMS_BSS_ST, 0))/C.QTY_NF_BRL, 2) AS BASE_ST_UNIT, ';
            v_sql :=
                   v_sql
                || '                    TRUNC(DECODE(NVL(C.DSP_ICMS_AMT_ST, 0), 0, NVL(C.DSP_ICMSSUBBRL_AMT, 0), NVL(C.DSP_ICMS_AMT_ST, 0))/C.QTY_NF_BRL, 2) AS VLR_ICMS_ST_UNIT, ';
            v_sql :=
                v_sql || '                    TRUNC(NVL(C.ICMSSUB_BRL_AMT,0)/C.QTY_NF_BRL, 2) AS VLR_ICMS_ST_UNIT_AUX ';
            v_sql := v_sql || '             FROM MSAFI.PS_NF_LN_BRL C ) C ';
            v_sql := v_sql || '        WHERE A.PROC_ID       = ''' || vp_proc_id || ''' ';
            v_sql := v_sql || '          AND A.COD_EMPRESA     = ''' || vp_cod_empresa || ''' ';
            v_sql := v_sql || '          AND B.COD_EMPRESA         = A.COD_EMPRESA ';
            v_sql := v_sql || '          AND C.BUSINESS_UNIT       = B.BU_PO1 ';
            v_sql := v_sql || '          AND C.NF_BRL_ID           = A.NUM_CONTROLE_DOCTO ';
            v_sql := v_sql || '          AND C.NF_BRL_LINE_NUM     = A.NUM_ITEM ';
            v_sql := v_sql || '    ) A ';

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
            v_sql := ' SELECT   DISTINCT ';
            v_sql := v_sql || '        ' || vp_proc_id || ', ';
            v_sql := v_sql || '        A.BUSINESS_UNIT, ';
            v_sql := v_sql || '        A.NF_BRL_ID, ';
            v_sql := v_sql || '        A.NF_BRL_LINE_NUM, ';
            v_sql := v_sql || '        A.BASE_ICMS_UNIT, ';
            v_sql := v_sql || '        A.VLR_ICMS_UNIT, ';
            v_sql := v_sql || '        A.ALIQ_ICMS, ';
            v_sql := v_sql || '        A.BASE_ST_UNIT, ';
            v_sql := v_sql || '        A.VLR_ICMS_ST_UNIT, ';
            v_sql := v_sql || '        A.VLR_ICMS_ST_UNIT_AUX ';
            v_sql := v_sql || '  FROM ( ';
            v_sql := v_sql || '        SELECT /*+DRIVING_SITE(C)*/ ';
            v_sql := v_sql || '               C.BUSINESS_UNIT, ';
            v_sql := v_sql || '               C.NF_BRL_ID, ';
            v_sql := v_sql || '               C.NF_BRL_LINE_NUM, ';
            v_sql := v_sql || '               C.BASE_ICMS_UNIT, ';
            v_sql := v_sql || '               C.VLR_ICMS_UNIT, ';
            v_sql := v_sql || '               C.ALIQ_ICMS,  ';
            v_sql := v_sql || '               C.BASE_ST_UNIT, ';
            v_sql := v_sql || '               C.VLR_ICMS_ST_UNIT, ';
            v_sql := v_sql || '               C.VLR_ICMS_ST_UNIT_AUX ';
            v_sql := v_sql || '        FROM ' || vp_tab_entrada_co || ' A, ';
            v_sql := v_sql || '             MSAFI.DSP_INTERFACE_SETUP B, ';
            v_sql := v_sql || '            (SELECT C.BUSINESS_UNIT, ';
            v_sql := v_sql || '                    C.NF_BRL_ID, ';
            v_sql := v_sql || '                    C.NF_BRL_LINE_NUM, ';
            v_sql :=
                v_sql || '                    NVL(TRUNC(C.ICMSTAX_BRL_BSS/C.QTY_NF_BRL, 2), 0) AS BASE_ICMS_UNIT, ';
            v_sql := v_sql || '                    NVL(TRUNC(C.ICMSTAX_BRL_AMT/C.QTY_NF_BRL, 2), 0) AS VLR_ICMS_UNIT, ';
            v_sql := v_sql || '                    NVL(C.ICMSTAX_BRL_PCT, 0) AS ALIQ_ICMS,  ';
            v_sql :=
                   v_sql
                || '                    TRUNC(DECODE(NVL(C.DSP_ICMS_BSS_ST, 0), 0, NVL(C.DSP_ICMSSUBBRL_BSS, 0), NVL(C.DSP_ICMS_BSS_ST, 0))/C.QTY_NF_BRL, 2) AS BASE_ST_UNIT, ';
            v_sql :=
                   v_sql
                || '                    TRUNC(DECODE(NVL(C.DSP_ICMS_AMT_ST, 0), 0, NVL(C.DSP_ICMSSUBBRL_AMT, 0), NVL(C.DSP_ICMS_AMT_ST, 0))/C.QTY_NF_BRL, 2) AS VLR_ICMS_ST_UNIT, ';
            v_sql :=
                v_sql || '                    TRUNC(NVL(C.ICMSSUB_BRL_AMT,0)/C.QTY_NF_BRL, 2) AS VLR_ICMS_ST_UNIT_AUX ';
            v_sql := v_sql || '             FROM MSAFI.PS_NF_LN_BRL C ) C ';
            v_sql := v_sql || '        WHERE A.PROC_ID       = ''' || vp_proc_id || ''' ';
            v_sql := v_sql || '          AND A.COD_EMPRESA     = ''' || vp_cod_empresa || ''' ';
            v_sql := v_sql || '          AND B.COD_EMPRESA         = A.COD_EMPRESA ';
            v_sql := v_sql || '          AND C.BUSINESS_UNIT       = B.BU_PO1 ';
            v_sql := v_sql || '          AND C.NF_BRL_ID           = A.NUM_CONTROLE_DOCTO ';
            v_sql := v_sql || '          AND C.NF_BRL_LINE_NUM     = A.NUM_ITEM ';
            v_sql := v_sql || '    ) A ';

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

        v_sql := 'CREATE UNIQUE INDEX PK_P_NF_' || vp_proc_id || ' ON ' || vp_tabela_nf || ' ';
        v_sql := v_sql || ' ( ';
        v_sql := v_sql || '  PROC_ID         ASC, ';
        v_sql := v_sql || '  BUSINESS_UNIT   ASC, ';
        v_sql := v_sql || '  NF_BRL_ID       ASC, ';
        v_sql := v_sql || '  NF_BRL_LINE_NUM ASC ';
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
                         , p_i_data_fim IN DATE
                         , p_i_tipo_ajuste IN VARCHAR2 )
    IS
        v_sql VARCHAR2 ( 1000 );
    BEGIN
        loga ( 'DELETAR DADOS ATUAIS - INI - ' || p_i_cod_estab
             , FALSE );

        v_sql := 'DELETE MSAFI.DPSP_MSAF_PERDAS ';
        v_sql := v_sql || 'WHERE COD_EMPRESA  = ''' || mcod_empresa || ''' ';
        v_sql := v_sql || '  AND COD_ESTAB    = ''' || p_i_cod_estab || ''' ';
        v_sql :=
               v_sql
            || '  AND DATA_INV     BETWEEN TO_DATE('''
            || TO_CHAR ( p_i_data_ini
                       , 'DDMMYYYY' )
            || ''',''DDMMYYYY'') AND TO_DATE('''
            || TO_CHAR ( p_i_data_fim
                       , 'DDMMYYYY' )
            || ''',''DDMMYYYY'') ';

        IF ( p_i_tipo_ajuste = '1' ) THEN --negativo
            v_sql := v_sql || '  AND TIPO_AJUSTE = ''N'' ';
        ELSIF ( p_i_tipo_ajuste = '2' ) THEN --positivo
            v_sql := v_sql || '  AND TIPO_AJUSTE = ''P'' ';
        END IF;

        EXECUTE IMMEDIATE v_sql;

        COMMIT;

        loga ( 'DELETAR DADOS ATUAIS - FIM'
             , FALSE );
    END;

    PROCEDURE delete_temp_tbl ( p_i_proc_instance IN VARCHAR2
                              , vp_nome_tabela_aliq IN VARCHAR2
                              , vp_nome_tabela_pmc IN VARCHAR2
                              , vp_tab_perdas_tmp IN VARCHAR2
                              , vp_tab_perdas_inv IN VARCHAR2
                              , vp_tab_perdas_ent_c IN VARCHAR2
                              , vp_tab_perdas_ent_f IN VARCHAR2
                              , vp_tab_perdas_ent_d IN VARCHAR2
                              , vp_tab_perdas_nf IN VARCHAR2 )
    IS
    BEGIN
        BEGIN
            EXECUTE IMMEDIATE 'DROP TABLE ' || vp_nome_tabela_aliq;
        EXCEPTION
            WHEN OTHERS THEN
                loga ( 'ERRO NO DROP ' || vp_nome_tabela_aliq
                     , FALSE );
        END;

        BEGIN
            EXECUTE IMMEDIATE 'DROP TABLE ' || vp_nome_tabela_pmc;
        EXCEPTION
            WHEN OTHERS THEN
                loga ( 'ERRO NO DROP ' || vp_nome_tabela_pmc
                     , FALSE );
        END;

        BEGIN
            EXECUTE IMMEDIATE 'DROP TABLE ' || vp_tab_perdas_tmp;
        EXCEPTION
            WHEN OTHERS THEN
                loga ( 'ERRO NO DROP ' || vp_tab_perdas_tmp
                     , FALSE );
        END;

        BEGIN
            EXECUTE IMMEDIATE 'DROP TABLE ' || vp_tab_perdas_inv;
        EXCEPTION
            WHEN OTHERS THEN
                loga ( 'ERRO NO DROP ' || vp_tab_perdas_inv
                     , FALSE );
        END;

        BEGIN
            EXECUTE IMMEDIATE 'DROP TABLE ' || vp_tab_perdas_ent_c;
        EXCEPTION
            WHEN OTHERS THEN
                loga ( 'ERRO NO DROP ' || vp_tab_perdas_ent_c
                     , FALSE );
        END;

        BEGIN
            EXECUTE IMMEDIATE 'DROP TABLE ' || vp_tab_perdas_ent_f;
        EXCEPTION
            WHEN OTHERS THEN
                loga ( 'ERRO NO DROP ' || vp_tab_perdas_ent_f
                     , FALSE );
        END;

        BEGIN
            EXECUTE IMMEDIATE 'DROP TABLE ' || vp_tab_perdas_ent_d;
        EXCEPTION
            WHEN OTHERS THEN
                loga ( 'ERRO NO DROP ' || vp_tab_perdas_ent_d
                     , FALSE );
        END;

        BEGIN
            EXECUTE IMMEDIATE 'DROP TABLE ' || vp_tab_perdas_nf;
        EXCEPTION
            WHEN OTHERS THEN
                loga ( 'ERRO NO DROP ' || vp_tab_perdas_nf
                     , FALSE );
        END;

        --- remover nome da TMP do controle
        del_tmp_control ( p_i_proc_instance
                        , vp_nome_tabela_aliq );
        del_tmp_control ( p_i_proc_instance
                        , vp_nome_tabela_pmc );
        --
        del_tmp_control ( p_i_proc_instance
                        , vp_tab_perdas_ent_c );
        del_tmp_control ( p_i_proc_instance
                        , vp_tab_perdas_ent_f );
        del_tmp_control ( p_i_proc_instance
                        , vp_tab_perdas_ent_d );
        --
        del_tmp_control ( p_i_proc_instance
                        , vp_tab_perdas_tmp );
        del_tmp_control ( p_i_proc_instance
                        , vp_tab_perdas_nf );
        del_tmp_control ( p_i_proc_instance
                        , vp_tab_perdas_inv );
        --- checar TMPs de processos interrompidos e dropar
        drop_old_tmp ( p_i_proc_instance );
    END; --PROCEDURE DELETE_TEMP_TBL

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

    FUNCTION executar ( p_id_uploader VARCHAR2
                      , p_tipo_ajuste VARCHAR2
                      , p_periodo DATE
                      , p_origem1 VARCHAR2
                      , p_cd1 VARCHAR2
                      , p_origem2 VARCHAR2
                      , p_cd2 VARCHAR2
                      , p_origem3 VARCHAR2
                      , p_cd3 VARCHAR2
                      , p_origem4 VARCHAR2
                      , p_cd4 VARCHAR2
                      , p_compra_direta VARCHAR2
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

        --Variaveis genericas
        v_text01 VARCHAR2 ( 6000 );
        v_sep VARCHAR2 ( 1 ) := CHR ( 9 );
        p_proc_instance VARCHAR2 ( 30 );

        --
        TYPE cur_typ IS REF CURSOR;

        cr_cup cur_typ;
        --
        v_aliq_st VARCHAR2 ( 5 ) := '';
        v_pmc NUMBER := 0;
        --TABELAS TEMP
        v_nome_tabela_aliq VARCHAR2 ( 30 );
        v_nome_tabela_pmc VARCHAR2 ( 30 );
        v_tab_perdas_inv VARCHAR2 ( 30 );
        v_tab_perdas_ent_c VARCHAR2 ( 30 );
        v_tab_perdas_ent_f VARCHAR2 ( 30 );
        v_tab_perdas_ent_d VARCHAR2 ( 30 );
        v_tab_perdas_nf VARCHAR2 ( 30 );
        v_tab_perdas_tmp VARCHAR2 ( 30 );
        ---
        v_sql_resultado VARCHAR2 ( 2000 );

        ------------------------------------------------------------------------------------------------------------------------------------------------------
        --RANGE DE DATAS PARA BUSCAR VENDAS
        v_data_inicial DATE
            := TO_DATE (    '01'
                         || TO_CHAR ( p_periodo
                                    , 'MMYYYY' )
                       , 'DDMMYYYY' ); -- DATA INICIAL
        v_data_final DATE := LAST_DAY ( p_periodo ); -- DATA FINAL

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
    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS='',.'' ';

        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        musuario := lib_parametros.recuperar ( 'USUARIO' );

        mproc_id :=
            lib_proc.new ( 'DPSP_PERDAS_CPROC'
                         , 48
                         , 150 );
        lib_proc.add_tipo ( mproc_id
                          , 1
                          ,    TO_CHAR ( SYSDATE
                                       , 'YYYYMMDDHH24MISS' )
                            || '_CPROC_PERDAS'
                          , 1 );
        lib_proc.add_header ( 'Executar processamento do relatorio de Perdas'
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

        msafi.dsp_control.createprocess ( 'DPSP_PERDAS' --P_I_PROCID            IN VARCHAR2             , --VARCHAR2(16)
                                        , 'DPSP_PROC_PERDAS' --P_I_PROC_DESCR        IN VARCHAR2             , --VARCHAR2(64)
                                        , NULL --P_I_DATA_INI          IN DATE     DEFAULT NULL,
                                        , NULL --P_I_DATA_FIM          IN DATE     DEFAULT NULL,
                                        , p_origem1 --P_I_DETALHES1         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , p_periodo --P_I_DETALHES2         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , p_tipo_ajuste --P_I_DETALHES3         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , NULL --P_I_DETALHES4         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , musuario --P_I_USER              IN VARCHAR2 DEFAULT NULL  --VARCHAR2(64)
                                                   );
        v_proc_status := 1; --EM PROCESSO

        --GERAR CHAVE PROC_ID
        SELECT ROUND ( dbms_random.VALUE ( 10000000000000
                                         , 999999999999999 ) )
          INTO p_proc_instance
          FROM DUAL;

        ---------------------

        loga ( '>>> Inicio do processamento...' || p_proc_instance
             , FALSE );
        loga ( '>> DT INICIAL: ' || v_data_inicial
             , FALSE );
        loga ( '>> DT FINAL: ' || v_data_final
             , FALSE );

        ---
        IF msafi.get_trava_info ( 'PERDAS'
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
            RETURN mproc_id;
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

        --ABRIR ARQUIVO COM DADOS DO INVENTARIO
        open_file_inv ( p_id_uploader );

        --CRIAR TABELA TEMP DO INVENTARIO
        create_perdas_inv_tmp ( p_proc_instance
                              , v_tab_perdas_inv );

        --EXCLUIR DADOS EXISTENTES
        FOR i IN 1 .. a_estabs.COUNT LOOP
            load_inv_dados ( p_id_uploader
                           , p_proc_instance
                           , a_estabs ( i )
                           , v_data_inicial
                           , v_data_final
                           , p_tipo_ajuste
                           , v_tab_perdas_inv );
            delete_tbl ( a_estabs ( i )
                       , v_data_inicial
                       , v_data_final
                       , p_tipo_ajuste );
        END LOOP;

        --

        --CRIAR INDICES DA TEMP DO INVENTARIO
        create_perdas_inv_tmp_idx ( p_proc_instance
                                  , v_tab_perdas_inv );

        --CRIAR E CARREGAR TABELAS TEMP DE ALIQ E PMC DO PEOPLESOFT
        load_aliq_pmc ( p_proc_instance
                      , v_nome_tabela_aliq
                      , v_nome_tabela_pmc
                      , v_tab_perdas_inv );

        --CARREGAR DADOS DE ORIGEM CD
        IF ( p_origem1 = '2'
        AND p_cd1 IS NOT NULL )
        OR ( p_origem2 = '2'
        AND p_cd2 IS NOT NULL )
        OR ( p_origem3 = '2'
        AND p_cd3 IS NOT NULL )
        OR ( p_origem4 = '2'
        AND p_cd4 IS NOT NULL ) THEN
            loga ( '> ENTRADAs CD-INI'
                 , FALSE );

            --CRIAR TABELA TMP DE ENTRADA CD
            create_tab_entrada_cd ( p_proc_instance
                                  , v_tab_perdas_ent_c );

            IF ( p_origem1 = '2' ) THEN
                --CARREGAR TEMPORARIAS ENTRADA NOS CDs
                load_entradas ( p_id_uploader
                              , p_proc_instance
                              , p_cd1
                              , v_data_inicial
                              , v_data_final
                              , 'C'
                              , v_tab_perdas_ent_c
                              , v_tab_perdas_inv
                              , p_tipo_ajuste );
            END IF;

            IF ( p_origem2 = '2'
            AND p_cd2 <> p_cd1 ) THEN
                --CARREGAR TEMPORARIAS ENTRADA NOS CDs
                load_entradas ( p_id_uploader
                              , p_proc_instance
                              , p_cd2
                              , v_data_inicial
                              , v_data_final
                              , 'C'
                              , v_tab_perdas_ent_c
                              , v_tab_perdas_inv
                              , p_tipo_ajuste );
            END IF;

            IF ( p_origem3 = '2'
            AND p_cd3 <> p_cd2
            AND p_cd3 <> p_cd1 ) THEN
                --CARREGAR TEMPORARIAS ENTRADA NOS CDs
                load_entradas ( p_id_uploader
                              , p_proc_instance
                              , p_cd3
                              , v_data_inicial
                              , v_data_final
                              , 'C'
                              , v_tab_perdas_ent_c
                              , v_tab_perdas_inv
                              , p_tipo_ajuste );
            END IF;

            IF ( p_origem4 = '2'
            AND p_cd4 <> p_cd3
            AND p_cd4 <> p_cd2
            AND p_cd4 <> p_cd1 ) THEN
                --CARREGAR TEMPORARIAS ENTRADA NOS CDs
                load_entradas ( p_id_uploader
                              , p_proc_instance
                              , p_cd4
                              , v_data_inicial
                              , v_data_final
                              , 'C'
                              , v_tab_perdas_ent_c
                              , v_tab_perdas_inv
                              , p_tipo_ajuste );
            END IF;

            --CRIAR INDICES DA TEMP DE ENTRADA CD
            create_tab_entrada_cd_idx ( p_proc_instance
                                      , v_tab_perdas_ent_c );

            loga ( '> ENTRADAs CD-FIM'
                 , FALSE );
        END IF;

        --CARREGAR DADOS ENTRADA EM FILIAIS - TRANSFERENCIA
        IF ( p_origem1 = '1' )
        OR ( p_origem2 = '1' )
        OR ( p_origem3 = '1' )
        OR ( p_origem4 = '1' ) THEN
            loga ( '> ENTRADAs FILIAL-INI'
                 , FALSE );
            create_tab_entrada_filial ( p_proc_instance
                                      , v_tab_perdas_ent_f );

            FOR i IN 1 .. a_estabs.COUNT LOOP
                --CARREGAR TEMPORARIAS ENTRADA NAS FILIAIS
                load_entradas ( p_id_uploader
                              , p_proc_instance
                              , a_estabs ( i )
                              , v_data_inicial
                              , v_data_final
                              , 'F'
                              , v_tab_perdas_ent_f
                              , v_tab_perdas_inv
                              , p_tipo_ajuste );
            END LOOP; --FOR i IN 1..A_ESTABS.COUNT

            create_tab_ent_filial_idx ( p_proc_instance
                                      , v_tab_perdas_ent_f );
            loga ( '> ENTRADAs FILIAL-FIM'
                 , FALSE );
        END IF; --IF (P_ORIGEM1 = '1') OR (P_ORIGEM2 = '1') OR (P_ORIGEM3 = '1') OR (P_ORIGEM4 = '1') THEN

        --CARREGAR DADOS ENTRADA COMPRA DIRETA
        IF ( p_compra_direta = 'S' ) THEN
            loga ( '> ENTRADAs CDIRETA-INI'
                 , FALSE );
            create_tab_entrada_cdireta ( p_proc_instance
                                       , v_tab_perdas_ent_d );

            FOR i IN 1 .. a_estabs.COUNT LOOP
                --CARREGAR TEMPORARIAS ENTRADA NAS FILIAIS COMPRA DIRETA
                load_entradas ( p_id_uploader
                              , p_proc_instance
                              , a_estabs ( i )
                              , v_data_inicial
                              , v_data_final
                              , 'CO'
                              , v_tab_perdas_ent_d
                              , v_tab_perdas_inv
                              , p_tipo_ajuste );
            END LOOP; --FOR i IN 1..A_ESTABS.COUNT

            create_tab_ent_cdireta_idx ( p_proc_instance
                                       , v_tab_perdas_ent_d );
            loga ( '> ENTRADAs CDIRETA-FIM'
                 , FALSE );
        END IF;

        --

        --CARREGAR NFs DO PEOPLE
        load_nf_people ( p_proc_instance
                       , mcod_empresa
                       , v_tab_perdas_ent_c
                       , v_tab_perdas_ent_f
                       , v_tab_perdas_ent_d
                       , v_tab_perdas_nf );

        --CRIAR TABELA TEMPORARIA COM O RESULTADO
        create_perdas_tmp_tbl ( p_proc_instance
                              , v_tab_perdas_tmp );

        --LOOP PARA CADA FILIAL-INI--------------------------------------------------------------------------------------
        FOR i IN 1 .. a_estabs.COUNT LOOP
            --ASSOCIAR SAIDAS COM SUAS ULTIMAS ENTRADAS
            IF ( p_cd1 IS NOT NULL ) THEN
                IF ( p_origem1 = '1' ) THEN
                    --ENTRADA NAS FILIAIS
                    get_entradas_filial ( p_id_uploader
                                        , p_proc_instance
                                        , a_estabs ( i )
                                        , p_cd1
                                        , v_data_inicial
                                        , v_data_final
                                        , v_tab_perdas_ent_f
                                        , v_tab_perdas_inv
                                        , v_tab_perdas_nf
                                        , v_tab_perdas_tmp );
                ELSIF ( p_origem1 = '2' ) THEN
                    --ENTRADA NOS CDs
                    get_entradas_cd ( p_id_uploader
                                    , p_proc_instance
                                    , a_estabs ( i )
                                    , p_cd1
                                    , v_data_inicial
                                    , v_data_final
                                    , v_tab_perdas_ent_c
                                    , v_tab_perdas_inv
                                    , v_tab_perdas_nf
                                    , v_tab_perdas_tmp );
                END IF;
            END IF;

            IF ( p_cd2 IS NOT NULL ) THEN
                IF ( p_origem2 = '1' ) THEN
                    --ENTRADA NAS FILIAIS
                    get_entradas_filial ( p_id_uploader
                                        , p_proc_instance
                                        , a_estabs ( i )
                                        , p_cd2
                                        , v_data_inicial
                                        , v_data_final
                                        , v_tab_perdas_ent_f
                                        , v_tab_perdas_inv
                                        , v_tab_perdas_nf
                                        , v_tab_perdas_tmp );
                ELSIF ( p_origem2 = '2' ) THEN
                    --ENTRADA NOS CDs
                    get_entradas_cd ( p_id_uploader
                                    , p_proc_instance
                                    , a_estabs ( i )
                                    , p_cd2
                                    , v_data_inicial
                                    , v_data_final
                                    , v_tab_perdas_ent_c
                                    , v_tab_perdas_inv
                                    , v_tab_perdas_nf
                                    , v_tab_perdas_tmp );
                END IF;
            END IF;

            IF ( p_cd3 IS NOT NULL ) THEN
                IF ( p_origem3 = '1' ) THEN
                    --ENTRADA NAS FILIAIS
                    get_entradas_filial ( p_id_uploader
                                        , p_proc_instance
                                        , a_estabs ( i )
                                        , p_cd3
                                        , v_data_inicial
                                        , v_data_final
                                        , v_tab_perdas_ent_f
                                        , v_tab_perdas_inv
                                        , v_tab_perdas_nf
                                        , v_tab_perdas_tmp );
                ELSIF ( p_origem3 = '2' ) THEN
                    --ENTRADA NOS CDs
                    get_entradas_cd ( p_id_uploader
                                    , p_proc_instance
                                    , a_estabs ( i )
                                    , p_cd3
                                    , v_data_inicial
                                    , v_data_final
                                    , v_tab_perdas_ent_c
                                    , v_tab_perdas_inv
                                    , v_tab_perdas_nf
                                    , v_tab_perdas_tmp );
                END IF;
            END IF;

            IF ( p_cd4 IS NOT NULL ) THEN
                IF ( p_origem4 = '1' ) THEN
                    --ENTRADA NAS FILIAIS
                    get_entradas_filial ( p_id_uploader
                                        , p_proc_instance
                                        , a_estabs ( i )
                                        , p_cd4
                                        , v_data_inicial
                                        , v_data_final
                                        , v_tab_perdas_ent_f
                                        , v_tab_perdas_inv
                                        , v_tab_perdas_nf
                                        , v_tab_perdas_tmp );
                ELSIF ( p_origem4 = '2' ) THEN
                    --ENTRADA NOS CDs
                    get_entradas_cd ( p_id_uploader
                                    , p_proc_instance
                                    , a_estabs ( i )
                                    , p_cd4
                                    , v_data_inicial
                                    , v_data_final
                                    , v_tab_perdas_ent_c
                                    , v_tab_perdas_inv
                                    , v_tab_perdas_nf
                                    , v_tab_perdas_tmp );
                END IF;
            END IF;

            IF ( p_compra_direta = 'S' ) THEN
                get_compra_direta ( p_id_uploader
                                  , p_proc_instance
                                  , a_estabs ( i )
                                  , v_data_inicial
                                  , v_data_final
                                  , v_tab_perdas_ent_d
                                  , v_tab_perdas_inv
                                  , v_tab_perdas_nf
                                  , v_tab_perdas_tmp );
            END IF;

            --SE NAO ACHOU ENTRADA, GRAVAR NA TABELA RESULTADO APENAS A SAIDA
            get_sem_entrada ( p_id_uploader
                            , p_proc_instance
                            , a_estabs ( i )
                            , v_data_inicial
                            , v_data_final
                            , v_tab_perdas_inv
                            , v_tab_perdas_tmp );
        END LOOP; --FOR i IN 1..A_ESTABS.COUNT

        --LOOP PARA CADA FILIAL-FIM--------------------------------------------------------------------------------------

        --INSERIR DADOS-INI-------------------------------------------------------------------------------------------
        loga ( 'INSERINDO RESULTADO... - INI' );

        ---INSERIR RESULTADO
        v_sql_resultado := 'INSERT /*+APPEND*/ INTO MSAFI.DPSP_MSAF_PERDAS ( ';
        v_sql_resultado := v_sql_resultado || 'SELECT ';
        v_sql_resultado := v_sql_resultado || ' A.COD_EMPRESA ';
        v_sql_resultado := v_sql_resultado || ',A.COD_ESTAB ';
        v_sql_resultado := v_sql_resultado || ',A.COD_PRODUTO ';
        v_sql_resultado := v_sql_resultado || ',A.DATA_INV ';
        v_sql_resultado := v_sql_resultado || ',A.QTD_SALDO ';
        v_sql_resultado := v_sql_resultado || ',A.QTD_CONTAGEM ';
        v_sql_resultado := v_sql_resultado || ',A.QTD_AJUSTE ';
        v_sql_resultado := v_sql_resultado || ',A.VLR_CUSTO ';
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
            v_sql_resultado || ',DECODE(A.VLR_ICMS_ST_UNIT_E, 0, A.VLR_ICMS_ST_UNIT_AUX, A.VLR_ICMS_ST_UNIT_E) '; --VLR_ICMS_ST_UNIT_E
        v_sql_resultado := v_sql_resultado || ',A.STAT_LIBER_CNTR ';
        v_sql_resultado := v_sql_resultado || ',C.ALIQ_ST ';
        v_sql_resultado := v_sql_resultado || ',NVL(D.VLR_PMC, 0) ';
        v_sql_resultado :=
               v_sql_resultado
            || ',TRUNC((A.BASE_ST_UNIT_E*(TO_NUMBER(REPLACE(C.ALIQ_ST,''%'',''''))/100))-DECODE(A.VLR_ICMS_ST_UNIT_E, 0, A.VLR_ICMS_ST_UNIT_AUX, A.VLR_ICMS_ST_UNIT_E), 2) AS VLR_ICMS_AUX ';
        v_sql_resultado := v_sql_resultado || ',0 VLR_ICMS_BRUTO ';
        v_sql_resultado := v_sql_resultado || ',0 VLR_ICMS_S_VENDA ';
        v_sql_resultado :=
               v_sql_resultado
            || ',TRUNC(A.QTD_AJUSTE*DECODE(A.VLR_ICMS_ST_UNIT_E, 0, A.VLR_ICMS_ST_UNIT_AUX, A.VLR_ICMS_ST_UNIT_E), 2) '; --VLR_DIF_QTDE
        v_sql_resultado :=
               v_sql_resultado
            || ',CASE WHEN TRUNC(A.QTD_AJUSTE*DECODE(A.VLR_ICMS_ST_UNIT_E, 0, A.VLR_ICMS_ST_UNIT_AUX, A.VLR_ICMS_ST_UNIT_E), 2) > 0 THEN ''CRÉDITO'' ELSE ''DÉBITO'' END '; --DEB_CRED
        v_sql_resultado := v_sql_resultado || ',''' || musuario || ''' ';
        v_sql_resultado := v_sql_resultado || ',SYSDATE ';
        v_sql_resultado := v_sql_resultado || ',NULL ';
        v_sql_resultado := v_sql_resultado || ',A.VLR_ICMS_ST_UNIT_AUX ';
        v_sql_resultado := v_sql_resultado || ',A.TIPO_AJUSTE '; --- N = negativo / P = positivo
        v_sql_resultado := v_sql_resultado || 'FROM ' || v_tab_perdas_tmp || ' A, ';
        v_sql_resultado := v_sql_resultado || '     MSAFI.DSP_ESTABELECIMENTO B, ';
        v_sql_resultado := v_sql_resultado || v_nome_tabela_aliq || ' C, ';
        v_sql_resultado := v_sql_resultado || v_nome_tabela_pmc || ' D ';
        v_sql_resultado := v_sql_resultado || 'WHERE A.PROC_ID     = ' || p_proc_instance;
        v_sql_resultado := v_sql_resultado || '  AND A.COD_EMPRESA = B.COD_EMPRESA ';
        v_sql_resultado := v_sql_resultado || '  AND A.COD_ESTAB   = B.COD_ESTAB ';
        v_sql_resultado := v_sql_resultado || '  AND A.PROC_ID     = C.PROC_ID (+) ';
        v_sql_resultado := v_sql_resultado || '  AND A.COD_PRODUTO = C.COD_PRODUTO (+) ';
        v_sql_resultado := v_sql_resultado || '  AND A.PROC_ID     = D.PROC_ID (+) ';
        v_sql_resultado := v_sql_resultado || '  AND A.COD_PRODUTO = D.COD_PRODUTO (+) ';
        v_sql_resultado := v_sql_resultado || ' ) ';

        EXECUTE IMMEDIATE v_sql_resultado;

        COMMIT;

        loga ( 'RESULTADO INSERIDO - FIM' );
        --INSERIR DADOS-FIM-------------------------------------------------------------------------------------------

        loga ( '<< Limpar Tabelas Temporárias >>'
             , FALSE );
        delete_temp_tbl ( p_proc_instance
                        , v_nome_tabela_aliq
                        , v_nome_tabela_pmc
                        , v_tab_perdas_tmp
                        , v_tab_perdas_inv
                        , v_tab_perdas_ent_c
                        , v_tab_perdas_ent_f
                        , v_tab_perdas_ent_d
                        , v_tab_perdas_nf );
        loga ( '<< Tabelas Temporárias Limpas >>'
             , FALSE );

        loga ( '>>> Fim do processamento!'
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

        --DISPONIBILIZAR PERIODO PROCESSADO PARA TRAVA DE REPROCESSAMENTO
        msafi.add_trava_info ( 'PERDAS'
                             , TO_CHAR ( v_data_inicial
                                       , 'YYYY/MM' ) );

        loga ( 'FIM DO PROCESSAMENTO, STATUS FINAL: [' || v_s_proc_status || ']'
             , FALSE );
        lib_proc.add ( 'FIM DO PROCESSAMENTO, STATUS FINAL: [' || v_s_proc_status || ']' );
        lib_proc.add ( 'Favor verificar LOG para detalhes.' );
        msafi.dsp_control.updateprocess ( v_s_proc_status );

        lib_proc.close ( );

        COMMIT;
        RETURN mproc_id;
    EXCEPTION
        WHEN OTHERS THEN
            --LOGA('<< ERRO - Limpar Tabelas Temporárias >>', FALSE);
            --DELETE_TEMP_TBL(P_PROC_INSTANCE, V_NOME_TABELA_ALIQ, V_NOME_TABELA_PMC, V_TAB_PERDAS_TMP, V_TAB_PERDAS_INV, V_TAB_PERDAS_ENT_C, V_TAB_PERDAS_ENT_F, V_TAB_PERDAS_ENT_D, V_TAB_PERDAS_NF);
            dbms_stats.gather_table_stats ( 'MSAFI'
                                          , 'DPSP_MSAF_PERDAS' );
            --LOGA('<< ERRO - Tabelas Temporárias Limpas >>', FALSE);

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
END dpsp_perdas_cproc;
/
SHOW ERRORS;
