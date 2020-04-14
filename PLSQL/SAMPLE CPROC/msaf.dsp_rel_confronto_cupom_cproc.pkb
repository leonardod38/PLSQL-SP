Prompt Package Body DSP_REL_CONFRONTO_CUPOM_CPROC;
--
-- DSP_REL_CONFRONTO_CUPOM_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dsp_rel_confronto_cupom_cproc
IS
    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    -- AJ0001 - Ajuste para geração de relatório em arquivo
    -- Rodolfo Carvalhal - 2017/06/09
    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    -- AJ0002 - Ajuste ordem de execução do delete
    -- Rodolfo Carvalhal - 2017/06/27
    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    -- AJ0003 - Cria JOB de importacão
    -- Rodolfo Carvalhal - 2017/06/29
    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    -- AJ0004 - Formata relatorio gerado
    -- Rodolfo Carvalhal - 2017/06/29
    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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
                           , '> ATENÇÃO! As opções de execução de carga abaixo são de uso exclusivo do Suporte Mastersaf'
                           , 'VARCHAR2'
                           , 'TEXT'
                           , 'N'
                           , '1'
                           , NULL
                           , ''
                           , 'N'
        );

        lib_proc.add_param ( pstr
                           , 'Executar Carga Automática de Cupons Fiscais'
                           , --P_CARGA_CUPOM
                            'VARCHAR2'
                           , 'CHECKBOX'
                           , 'N'
                           , 'N'
                           , NULL );

        lib_proc.add_param ( pstr
                           , 'Executar Carga Automática para Quaisquer Diferenças'
                           , --P_DIFERENCA
                            'VARCHAR2'
                           , 'CHECKBOX'
                           , 'N'
                           , 'N'
                           , NULL );

        lib_proc.add_param ( pstr
                           , 'Excluir Cupons Fiscais Antes da Carga'
                           , --P_DELETE
                            'VARCHAR2'
                           , 'CHECKBOX'
                           , 'N'
                           , 'N'
                           , NULL );

        lib_proc.add_param ( pstr
                           , 'Ativar LOG de Exclusão de Cupons Fiscais'
                           , --P_DELETE_LOG
                            'VARCHAR2'
                           , 'CHECKBOX'
                           , 'N'
                           , 'N'
                           , NULL );

        lib_proc.add_param (
                             pstr
                           , 'Estabelecimento'
                           , --P_CODESTAB
                            'VARCHAR2'
                           , 'MULTISELECT'
                           , 'S'
                           , 'S'
                           , NULL
                           ,    '
                            SELECT A.COD_ESTAB,A.COD_ESTAB || '' - '' || B.COD_ESTADO || '' - '' || A.CGC || '' - '' || INITCAP(A.BAIRRO) || '' / '' || INITCAP(A.CIDADE)
                            FROM ESTABELECIMENTO A, ESTADO B, MSAFI.DSP_ESTABELECIMENTO C
                            WHERE A.COD_EMPRESA  = '''
                             || mcod_empresa
                             || '''
                              AND B.IDENT_ESTADO = A.IDENT_ESTADO
                              AND A.COD_EMPRESA  = C.COD_EMPRESA
                              AND A.COD_ESTAB    = C.COD_ESTAB
                              AND C.TIPO         = ''L''
                            ORDER BY A.COD_ESTAB
                           '
        );

        RETURN pstr;
    END; --FUNCTION PARAMETROS RETURN VARCHAR2 IS

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Relatório / Carga Confronto MSAF x MCD x GL';
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
        RETURN 'Relatório para Confronto MSAF x MCD x GL e Carga de Cupons Faltantes no MSAF';
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

    PROCEDURE exec_cupom_e ( p_i_data_ini IN DATE
                           , p_i_data_fim IN DATE
                           , p_i_cod_empresa IN VARCHAR2
                           , p_i_cod_estab IN VARCHAR2 )
    IS
        v_txt_basico VARCHAR2 ( 256 ) := '';
    BEGIN
        v_txt_basico :=
               'BEGIN MSAFI.PRC_MSAF_CUPOM_E('''
            || TO_CHAR ( p_i_data_ini
                       , 'YYYYMMDD' )
            || ''','''
            || TO_CHAR ( p_i_data_fim
                       , 'YYYYMMDD' )
            || ''',P_COD_EMPRESA=>'''
            || p_i_cod_empresa
            || ''',P_COD_ESTAB=>'''
            || p_i_cod_estab
            || '''); END;';

        EXECUTE IMMEDIATE v_txt_basico;
    END;

    PROCEDURE exec_cupom ( p_i_data_ini IN DATE
                         , p_i_data_fim IN DATE
                         , p_i_cod_empresa IN VARCHAR2
                         , p_i_cod_estab IN VARCHAR2
                         , p_i_calc IN VARCHAR2 )
    IS
        v_txt_nf VARCHAR2 ( 1024 ) := '';
        v_txt_basico VARCHAR2 ( 256 ) := '';
    BEGIN
        v_txt_basico :=
               '('''
            || TO_CHAR ( p_i_data_ini
                       , 'YYYYMMDD' )
            || ''','''
            || TO_CHAR ( p_i_data_fim
                       , 'YYYYMMDD' )
            || ''','''
            || p_i_cod_empresa
            || ''',''';
        --X07
        v_txt_nf := 'BEGIN MSAFI.PRC_MSAF_CSI_SAFX07' || v_txt_basico || p_i_cod_estab || '''); END;';

        EXECUTE IMMEDIATE v_txt_nf;

        --X08
        v_txt_nf :=
            'BEGIN MSAFI.PRC_MSAF_CSI_SAFX08' || v_txt_basico || p_i_cod_estab || ''',''' || p_i_calc || '''); END;';

        EXECUTE IMMEDIATE v_txt_nf;

        --X2087
        v_txt_nf := 'BEGIN MSAFI.PRC_MSAF_CSI_SAFX2087' || v_txt_basico || p_i_cod_estab || '''); END;';

        EXECUTE IMMEDIATE v_txt_nf;

        --X2099
        v_txt_nf := 'BEGIN MSAFI.PRC_MSAF_CSI_SAFX2099' || v_txt_basico || p_i_cod_estab || '''); END;';

        EXECUTE IMMEDIATE v_txt_nf;

        --X28
        v_txt_nf :=
            'BEGIN MSAFI.PRC_MSAF_CSI_SAFX28' || v_txt_basico || p_i_cod_estab || ''',''' || p_i_calc || '''); END;';

        EXECUTE IMMEDIATE v_txt_nf;

        --X29
        v_txt_nf :=
            'BEGIN MSAFI.PRC_MSAF_CSI_SAFX29' || v_txt_basico || p_i_cod_estab || ''',''' || p_i_calc || '''); END;';

        EXECUTE IMMEDIATE v_txt_nf;

        --X991
        v_txt_nf :=
            'BEGIN MSAFI.PRC_MSAF_CSI_SAFX991' || v_txt_basico || p_i_cod_estab || ''',''' || p_i_calc || '''); END;';

        EXECUTE IMMEDIATE v_txt_nf;

        --X992
        v_txt_nf :=
            'BEGIN MSAFI.PRC_MSAF_CSI_SAFX992' || v_txt_basico || p_i_cod_estab || ''',''' || p_i_calc || '''); END;';

        EXECUTE IMMEDIATE v_txt_nf;

        --x993 x994 x281
        v_txt_basico :=
               'BEGIN MSAFI.PRC_MSAF_DH_CUPOM('''
            || TO_CHAR ( p_i_data_ini
                       , 'YYYYMMDD' )
            || ''','''
            || TO_CHAR ( p_i_data_fim
                       , 'YYYYMMDD' )
            || ''',P_COD_EMPRESA=>'''
            || p_i_cod_empresa
            || ''',P_COD_ESTAB=>'''
            || p_i_cod_estab
            || ''',P_CALC=>'''
            || p_i_calc
            || '''); END;';

        EXECUTE IMMEDIATE v_txt_basico;
    END;

    --EXCLUIR CUPONS-INI
    PROCEDURE delete_cupom ( p_i_data_ini IN DATE
                           , p_i_data_fim IN DATE
                           , p_i_cod_empresa IN VARCHAR2
                           , p_i_cod_estab IN VARCHAR2
                           , p_i_delete_log IN VARCHAR2 )
    IS
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

    BEGIN
        IF ( p_i_delete_log = 'S' ) THEN
            loga ( '<DELETE> Iniciando exclusão de cupons...' );
        END IF;

        --GERAR CURSOR PARA EXCLUIR CUPONS POR DIA - MELHOR PERFORMANCE
        FOR cd IN c_datas ( p_i_data_ini
                          , p_i_data_fim ) LOOP
            IF ( p_i_delete_log = 'S' ) THEN
                loga ( '<DELETE> Data: ' || cd.data_normal );
            END IF;

            -- AJ0002 >>
            DELETE FROM msaf.dwt_itens_merc
                  WHERE cod_empresa = p_i_cod_empresa
                    AND cod_estab = p_i_cod_estab
                    AND data_fiscal = cd.data_normal
                    AND ident_docto IN ( SELECT ident_docto
                                           FROM msaf.x2005_tipo_docto
                                          WHERE cod_docto IN ( 'CF'
                                                             , 'CF-E'
                                                             , 'SAT' ) );

            IF ( p_i_delete_log = 'S' ) THEN
                loga (    '-> DWT_ITENS_MERC: '
                       || TO_CHAR ( SQL%ROWCOUNT
                                  , '9999999999' ) );
            END IF;

            DELETE FROM msaf.dwt_docto_fiscal
                  WHERE cod_empresa = p_i_cod_empresa
                    AND cod_estab = p_i_cod_estab
                    AND data_fiscal = cd.data_normal
                    AND ident_docto IN ( SELECT ident_docto
                                           FROM msaf.x2005_tipo_docto
                                          WHERE cod_docto IN ( 'CF'
                                                             , 'CF-E'
                                                             , 'SAT' ) );

            IF ( p_i_delete_log = 'S' ) THEN
                loga (    '-> DWT_DOCTO_FISCAL: '
                       || TO_CHAR ( SQL%ROWCOUNT
                                  , '9999999999' ) );
            END IF;

            COMMIT;

            DELETE FROM msaf.x08_base_merc
                  WHERE cod_empresa = p_i_cod_empresa
                    AND cod_estab = p_i_cod_estab
                    AND data_fiscal = cd.data_normal
                    AND ident_docto IN ( SELECT ident_docto
                                           FROM msaf.x2005_tipo_docto
                                          WHERE cod_docto IN ( 'CF'
                                                             , 'CF-E'
                                                             , 'SAT' ) );

            IF ( p_i_delete_log = 'S' ) THEN
                loga (    '-> X08_BASE_MERC: '
                       || TO_CHAR ( SQL%ROWCOUNT
                                  , '9999999999' ) );
            END IF;

            COMMIT;

            DELETE FROM msaf.x08_trib_merc
                  WHERE cod_empresa = p_i_cod_empresa
                    AND cod_estab = p_i_cod_estab
                    AND data_fiscal = cd.data_normal
                    AND ident_docto IN ( SELECT ident_docto
                                           FROM msaf.x2005_tipo_docto
                                          WHERE cod_docto IN ( 'CF'
                                                             , 'CF-E'
                                                             , 'SAT' ) );

            IF ( p_i_delete_log = 'S' ) THEN
                loga (    '-> X08_TRIB_MERC: '
                       || TO_CHAR ( SQL%ROWCOUNT
                                  , '9999999999' ) );
            END IF;

            DELETE FROM msaf.x08_itens_merc
                  WHERE cod_empresa = p_i_cod_empresa
                    AND cod_estab = p_i_cod_estab
                    AND data_fiscal = cd.data_normal
                    AND ident_docto IN ( SELECT ident_docto
                                           FROM msaf.x2005_tipo_docto
                                          WHERE cod_docto IN ( 'CF'
                                                             , 'CF-E'
                                                             , 'SAT' ) );

            IF ( p_i_delete_log = 'S' ) THEN
                loga (    '-> X08_ITENS_MERC: '
                       || TO_CHAR ( SQL%ROWCOUNT
                                  , '9999999999' ) );
            END IF;

            COMMIT;

            DELETE FROM msaf.x07_cupom_fiscal
                  WHERE cod_empresa = p_i_cod_empresa
                    AND cod_estab = p_i_cod_estab
                    AND data_fiscal = cd.data_normal
                    AND ident_docto IN ( SELECT ident_docto
                                           FROM msaf.x2005_tipo_docto
                                          WHERE cod_docto IN ( 'CF'
                                                             , 'CF-E'
                                                             , 'SAT' ) );

            IF ( p_i_delete_log = 'S' ) THEN
                loga (    '-> X07_CUPOM_FISCAL: '
                       || TO_CHAR ( SQL%ROWCOUNT
                                  , '9999999999' ) );
            END IF;

            DELETE FROM msaf.x07_base_docfis
                  WHERE cod_empresa = p_i_cod_empresa
                    AND cod_estab = p_i_cod_estab
                    AND data_fiscal = cd.data_normal
                    AND ident_docto IN ( SELECT ident_docto
                                           FROM msaf.x2005_tipo_docto
                                          WHERE cod_docto IN ( 'CF'
                                                             , 'CF-E'
                                                             , 'SAT' ) );

            IF ( p_i_delete_log = 'S' ) THEN
                loga (    '-> X07_BASE_DOCFIS: '
                       || TO_CHAR ( SQL%ROWCOUNT
                                  , '9999999999' ) );
            END IF;

            DELETE FROM msaf.x07_trib_docfis
                  WHERE cod_empresa = p_i_cod_empresa
                    AND cod_estab = p_i_cod_estab
                    AND data_fiscal = cd.data_normal
                    AND ident_docto IN ( SELECT ident_docto
                                           FROM msaf.x2005_tipo_docto
                                          WHERE cod_docto IN ( 'CF'
                                                             , 'CF-E'
                                                             , 'SAT' ) );

            IF ( p_i_delete_log = 'S' ) THEN
                loga (    '-> X07_TRIB_DOCFIS: '
                       || TO_CHAR ( SQL%ROWCOUNT
                                  , '9999999999' ) );
            END IF;

            DELETE FROM msaf.x07_docto_fiscal
                  WHERE cod_empresa = p_i_cod_empresa
                    AND cod_estab = p_i_cod_estab
                    AND data_fiscal = cd.data_normal
                    AND ident_docto IN ( SELECT ident_docto
                                           FROM msaf.x2005_tipo_docto
                                          WHERE cod_docto IN ( 'CF'
                                                             , 'CF-E'
                                                             , 'SAT' ) );

            IF ( p_i_delete_log = 'S' ) THEN
                loga (    '-> X07_DOCTO_FISCAL: '
                       || TO_CHAR ( SQL%ROWCOUNT
                                  , '9999999999' ) );
            END IF;

            -- AJ0002 <<<
            COMMIT;

            DELETE FROM msaf.x29_item_ecf
                  WHERE cod_empresa = p_i_cod_empresa
                    AND cod_estab = p_i_cod_estab
                    AND data_fiscal = cd.data_normal;

            IF ( p_i_delete_log = 'S' ) THEN
                loga (    '-> X29_ITEM_ECF: '
                       || TO_CHAR ( SQL%ROWCOUNT
                                  , '9999999999' ) );
            END IF;

            DELETE FROM msaf.x992_item_reducao_ecf
                  WHERE cod_empresa = p_i_cod_empresa
                    AND cod_estab = p_i_cod_estab
                    AND data_fiscal = cd.data_normal;

            IF ( p_i_delete_log = 'S' ) THEN
                loga (    '-> X992_ITEM_REDUCAO_ECF: '
                       || TO_CHAR ( SQL%ROWCOUNT
                                  , '9999999999' ) );
            END IF;

            DELETE FROM msaf.x991_capa_reducao_ecf
                  WHERE cod_empresa = p_i_cod_empresa
                    AND cod_estab = p_i_cod_estab
                    AND data_fiscal = cd.data_normal;

            IF ( p_i_delete_log = 'S' ) THEN
                loga (    '-> X991_CAPA_REDUCAO_ECF: '
                       || TO_CHAR ( SQL%ROWCOUNT
                                  , '9999999999' ) );
            END IF;

            COMMIT;

            DELETE FROM msaf.x281_item_nota_ecf
                  WHERE cod_empresa = p_i_cod_empresa
                    AND cod_estab = p_i_cod_estab
                    AND data_emissao = cd.data_normal;

            IF ( p_i_delete_log = 'S' ) THEN
                loga (    '-> X281_ITEM_NOTA_ECF: '
                       || TO_CHAR ( SQL%ROWCOUNT
                                  , '9999999999' ) );
            END IF;

            DELETE FROM msaf.x28_capa_ecf
                  WHERE cod_empresa = p_i_cod_empresa
                    AND cod_estab = p_i_cod_estab
                    AND data_emissao = cd.data_normal;

            IF ( p_i_delete_log = 'S' ) THEN
                loga (    '-> X28_CAPA_ECF: '
                       || TO_CHAR ( SQL%ROWCOUNT
                                  , '9999999999' ) );
            END IF;

            COMMIT;

            DELETE FROM msaf.x994_item_cupom_ecf
                  WHERE cod_empresa = p_i_cod_empresa
                    AND cod_estab = p_i_cod_estab
                    AND data_emissao = cd.data_normal;

            IF ( p_i_delete_log = 'S' ) THEN
                loga (    '-> X994_ITEM_CUPOM_ECF: '
                       || TO_CHAR ( SQL%ROWCOUNT
                                  , '9999999999' ) );
            END IF;

            DELETE FROM msaf.x993_capa_cupom_ecf
                  WHERE cod_empresa = p_i_cod_empresa
                    AND cod_estab = p_i_cod_estab
                    AND data_emissao = cd.data_normal;

            IF ( p_i_delete_log = 'S' ) THEN
                loga (    '-> X993_CAPA_CUPOM_ECF: '
                       || TO_CHAR ( SQL%ROWCOUNT
                                  , '9999999999' ) );
            END IF;

            COMMIT;

            DELETE FROM msaf.x202_item_cupom_cfe
                  WHERE cod_empresa = p_i_cod_empresa
                    AND cod_estab = p_i_cod_estab
                    AND data_emissao = cd.data_normal;

            IF ( p_i_delete_log = 'S' ) THEN
                loga (    '-> X202_ITEM_CUPOM_CFE: '
                       || TO_CHAR ( SQL%ROWCOUNT
                                  , '9999999999' ) );
            END IF;

            DELETE FROM msaf.x201_capa_cupom_cfe
                  WHERE cod_empresa = p_i_cod_empresa
                    AND cod_estab = p_i_cod_estab
                    AND data_emissao = cd.data_normal;

            IF ( p_i_delete_log = 'S' ) THEN
                loga (    '-> X201_CAPA_CUPOM_CFE: '
                       || TO_CHAR ( SQL%ROWCOUNT
                                  , '9999999999' ) );
            END IF;

            COMMIT;
        END LOOP;

        IF ( p_i_delete_log = 'S' ) THEN
            loga ( '<DELETE> Exclusão de cupons finalizada' );
        END IF;
    --CLOSE C_DATAS; -- AJ0002

    END;

    --EXCLUIR CUPONS-FIM

    -- CRIA JOBS DE IMPORTACAO    -- AJ0003
    PROCEDURE cria_job_import ( p_data_ini DATE
                              , p_data_fim DATE )
    IS
        v_estab_grupo msafi.dsp_interface_setup.estab_grupo%TYPE;
        v_job_num msaf.job_importacao.num_job%TYPE;
    BEGIN
        SELECT estab_grupo
          INTO v_estab_grupo
          FROM msafi.dsp_interface_setup
         WHERE cod_empresa = mcod_empresa;

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
                 , a.grupo_arquivo --GRUPO_ARQUIVO
                 , a.numero_arquivo --NUMERO_ARQUIVO
                 , mcod_empresa --COD_EMPRESA
                 , CASE WHEN a.grupo_arquivo = 1 THEN v_estab_grupo ELSE NULL END --COD_ESTAB
                 , CASE
                       WHEN a.grupo_arquivo = 1 THEN
                           TO_DATE ( '01011900'
                                   , 'DDMMYYYY' )
                       ELSE
                           p_data_ini
                   END --DATA_INI
                 , p_data_fim --DATA_FIM
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
                 , 'S' --ind_valid_cep_x04
              FROM cat_prior_imp a
             WHERE a.nom_tab_work IN ( 'SAFX07'
                                     , 'SAFX08'
                                     --
                                     , 'SAFX201'
                                     , 'SAFX202'
                                     --
                                     , 'SAFX2087'
                                     , 'SAFX2099'
                                     , 'SAFX28'
                                     , 'SAFX29'
                                     , 'SAFX991'
                                     , 'SAFX992'
                                     , 'SAFX993'
                                     , 'SAFX994'
                                     , 'SAFX281' );

        COMMIT;

        loga ( 'Job de importação criado: [' || v_job_num || ']' );
    END cria_job_import;

    --
    FUNCTION numero ( p_valor NUMBER )
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN TRIM ( TO_CHAR ( p_valor
                              , '9g999g999g990d00' ) );
    END;

    --
    FUNCTION executar ( p_data_ini DATE
                      , p_data_fim DATE
                      , p_carga_cupom VARCHAR2
                      , p_diferenca VARCHAR2
                      , p_delete VARCHAR2
                      , p_delete_log VARCHAR2
                      , p_codestab lib_proc.vartab )
        RETURN INTEGER
    IS
        trace VARCHAR2 ( 4000 );

        mproc_id INTEGER;
        i1 INTEGER;

        v_sep VARCHAR2 ( 1 );

        v_proc_status NUMBER := 0;
        v_s_proc_status VARCHAR2 ( 16 );

        --Variaveis genericas
        v_text01 VARCHAR2 ( 768 );
        v_text02 VARCHAR2 ( 256 );
        --
        v_estab_ant VARCHAR2 ( 6 );
        v_009_total NUMBER := 0;

        TYPE a_estabs_t IS TABLE OF VARCHAR2 ( 6 );

        a_estabs a_estabs_t := a_estabs_t ( );

        v_class CHAR ( 1 ) := 'b';
    BEGIN
        msafi.dsp_aux.truncatabela_msafi ( 'DSP_PROC_ESTABS' );

        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );

        EXECUTE IMMEDIATE 'alter session set nls_numeric_characters='',.'' ';

        --V_SEP := '|';
        v_sep := CHR ( 9 );

        mproc_id :=
            lib_proc.new ( 'DSP_REL_CONFRONTO_CUPOM_CPROC'
                         , 48
                         , 150 );
        --LIB_PROC.add_tipo(mproc_id, 1, 'Processo', 1, pmaxcols=>150); -- AJ0001
        lib_proc.add_tipo ( mproc_id
                          , 1
                          ,    mcod_empresa
                            || '_'
                            || 'CONFRONTO_MSAF_MCD_GL_'
                            || TO_CHAR ( p_data_fim
                                       , 'yyyymm' )
                            || '.xls'
                          , 2 ); --AJ0001


        IF mcod_empresa IS NULL THEN
            lib_proc.add_log ( 'Código da empresa deve ser informado como parâmetro global.'
                             , 0 );
            lib_proc.close;
            RETURN mproc_id;
        END IF;

        msafi.dsp_control.createprocess ( 'REL_CONFR_CUPOM' --P_I_PROCID            IN VARCHAR2             , --VARCHAR2(16)
                                        , 'CUSTOMIZADO MASTERSAF: RELATORIO CONFRONTO' --P_I_PROC_DESCR        IN VARCHAR2             , --VARCHAR2(64)
                                        , p_data_ini --P_I_DATA_INI          IN DATE     DEFAULT NULL,
                                        , p_data_fim --P_I_DATA_FIM          IN DATE     DEFAULT NULL,
                                        , NULL --P_I_DETALHES1         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , NULL --P_I_DETALHES2         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , NULL --P_I_DETALHES3         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , NULL --P_I_DETALHES4         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , musuario --P_I_USER              IN VARCHAR2 DEFAULT NULL  --VARCHAR2(64)
                                                   );
        v_proc_status := 1; --EM PROCESSO

        ---ESTABELECIMENTOS
        IF ( p_codestab.COUNT > 0 ) THEN
            i1 := p_codestab.FIRST;

            WHILE i1 IS NOT NULL LOOP
                a_estabs.EXTEND ( );
                a_estabs ( a_estabs.LAST ) := p_codestab ( i1 );
                i1 := p_codestab.NEXT ( i1 );
            END LOOP;
        ELSE
            FOR c1 IN ( SELECT cod_estab
                          FROM estabelecimento
                         WHERE cod_empresa = mcod_empresa ) LOOP
                a_estabs.EXTEND ( );
                a_estabs ( a_estabs.LAST ) := c1.cod_estab;
            END LOOP;
        END IF;

        -- RELATORIO: UNION SELECT ''010'',''010 - Relatório Confronto MSAF x MCD x GL'' FROM DUAL
        loga ( 'Imprimindo relatório' );
        loga ( ' ' );

        -- AJ0001>>
        --LIB_PROC.add_header('Relatório Confronto MSAF x MCD x GL e Carga de Cupons',1,1);
        --lib_proc.add_header(' ');
        --lib_proc.add('                    |----  DH   ---|--|---- MSAF ----|----  MCD  ---|-|----- GL  ----|');
        --lib_proc.add(' ESTAB|UF|DT TRANSAC|VENDA LIQ DH  |  |VENDA LIQ MSAF|VENDA LIQ MCD | |VENDA LIQ GL  |DIFERENÇA?|');
        --lib_proc.add('------|--|----------|--------------|--|--------------|--------------|-|--------------|----------|');

        --lib_proc.add('ESTAB'||chr(9)||'UF'||chr(9)||'DT TRANSAC'||chr(9)||'VENDA LIQ DH  '||chr(9)||'  '||chr(9)||
        --'VENDA LIQ MSAF'||chr(9)||'VENDA LIQ MCD '||chr(9)||' '||chr(9)||'VENDA LIQ GL  '||chr(9)||'DIFERENÇA?');
        BEGIN
            -- AJ0004
            lib_proc.add ( dsp_planilha.header );
            lib_proc.add ( dsp_planilha.tabela_inicio );
            lib_proc.add ( dsp_planilha.linha (
                                                p_conteudo =>    dsp_planilha.campo ( 'ESTAB' )
                                                              || dsp_planilha.campo ( 'UF' )
                                                              || dsp_planilha.campo ( 'DT TRANSAC' )
                                                              || dsp_planilha.campo ( ' ' )
                                                              || dsp_planilha.campo ( 'DT STATUS' )
                                                              || dsp_planilha.campo ( 'VENDA LIQ DH' )
                                                              || dsp_planilha.campo ( 'VENDA LIQ MSAF' )
                                                              || dsp_planilha.campo ( 'VENDA LIQ MCD' )
                                                              || dsp_planilha.campo ( ' ' )
                                                              || dsp_planilha.campo ( 'VENDA LIQ GL' )
                                                              || dsp_planilha.campo ( 'DIFERENÇA?' )
                                                              || dsp_planilha.campo ( 'DIF DH x MSAF?' )
                                              , p_class => 'h'
                           ) );
        END;

        --                    DSP344|SP|02/12/2015|   12345678.90|PR|   12345678.90|   12345678.90|V|   12345678.90|
        -- AJ0001 <<

        loga ( 'Abrindo cursor' );
        v_estab_ant := '';

        FOR c10_data IN c_datas ( p_data_ini
                                , p_data_fim ) LOOP
            FOR i IN 1 .. a_estabs.COUNT LOOP
                --LOGA('Inicia cursor relatórios: '||A_ESTABS(i)||' - '||C10_DATA.DATA_NORMAL); -- AJ0002
                FOR cr_010 IN c_relatorio_010 ( c10_data.data_normal
                                              , a_estabs ( i ) ) LOOP
                    /*IF (V_ESTAB_ANT <> CR_010.COD_ESTAB) THEN
                        lib_proc.add('------|--|----------|--------------|--|--------------|--------------|-|--------------|----------|');
                    END IF;*/
                    -- AJ0001
                    v_estab_ant := cr_010.cod_estab;

                    ---EXCLUIR CUPONS
                    IF ( p_delete = 'S' ) THEN
                        delete_cupom ( cr_010.data_transacao
                                     , cr_010.data_transacao
                                     , mcod_empresa
                                     , cr_010.cod_estab
                                     , p_delete_log );
                    END IF;

                    ---
                    IF p_diferenca = 'S'
                   AND cr_010.diferenca = '  *SIM*   '
                   AND cr_010.status_dh = 'PR' THEN
                        loga (
                                  '>> Diferença encontrada em '
                               || cr_010.cod_estab
                               || ' dia '
                               || cr_010.data_transacao
                               || ' - CARGA CUPONS'
                        );
                        --EXECUTAR CARGA DE CUPONS
                        exec_cupom ( cr_010.data_transacao
                                   , cr_010.data_transacao
                                   , mcod_empresa
                                   , cr_010.cod_estab
                                   , 'N' );
                        exec_cupom_e ( cr_010.data_transacao
                                     , cr_010.data_transacao
                                     , mcod_empresa
                                     , cr_010.cod_estab );
                    ELSIF ( cr_010.venda_liq_dh <> cr_010.venda_liq_msaf )
                      AND p_carga_cupom = 'S'
                      AND cr_010.status_dh = 'PR' THEN
                        loga (
                                  '>> Diferença encontrada em '
                               || cr_010.cod_estab
                               || ' dia '
                               || cr_010.data_transacao
                               || ' - CARGA CUPONS'
                        );
                        --EXECUTAR CARGA DE CUPONS
                        exec_cupom ( cr_010.data_transacao
                                   , cr_010.data_transacao
                                   , mcod_empresa
                                   , cr_010.cod_estab
                                   , 'N' );
                        exec_cupom_e ( cr_010.data_transacao
                                     , cr_010.data_transacao
                                     , mcod_empresa
                                     , cr_010.cod_estab );
                    END IF;

                    ---
                    /* -- AJ0004
                    V_TEXT01 :=                      FazCampo(CR_010.COD_ESTAB                                 ,' ', 6);
                    V_TEXT01 := V_TEXT01 || V_SEP || FazCampo(CR_010.UF                                        ,' ', 2);
                    V_TEXT01 := V_TEXT01 || V_SEP || FazCampo(CR_010.DATA_TRANSACAO            ,'DD/MM/YYYY'   ,' ',10);
                    V_TEXT01 := V_TEXT01 || V_SEP || FazCampo(CR_010.VENDA_LIQ_DH                              ,' ',14);
                    V_TEXT01 := V_TEXT01 || V_SEP || FazCampo(CR_010.STATUS_DH                                 ,' ', 2);
                    V_TEXT01 := V_TEXT01 || V_SEP || FazCampo(CR_010.VENDA_LIQ_MSAF                            ,' ',14);
                    V_TEXT01 := V_TEXT01 || V_SEP || FazCampo(CR_010.VENDA_LIQ_MCD                             ,' ',14);
                    V_TEXT01 := V_TEXT01 || V_SEP || FazCampo(CR_010.STATUS_MCD                                ,' ', 1);
                    V_TEXT01 := V_TEXT01 || V_SEP || FazCampo(CR_010.VENDA_LIQ_GL                              ,' ',14);
                    V_TEXT01 := V_TEXT01 || V_SEP || FazCampo(CR_010.DIFERENCA                                 ,' ',10);
                    V_TEXT01 := V_TEXT01 || V_SEP;
                    */
                    BEGIN -- AJ0004
                        v_text01 := dsp_planilha.campo ( cr_010.cod_estab );
                        v_text01 := v_text01 || dsp_planilha.campo ( cr_010.uf );
                        v_text01 := v_text01 || dsp_planilha.campo ( cr_010.data_transacao );
                        v_text01 := v_text01 || dsp_planilha.campo ( cr_010.status_dh );
                        v_text01 := v_text01 || dsp_planilha.campo ( cr_010.data_alt_status );
                        v_text01 := v_text01 || dsp_planilha.campo ( numero ( cr_010.venda_liq_dh ) );
                        v_text01 := v_text01 || dsp_planilha.campo ( numero ( cr_010.venda_liq_msaf ) );
                        v_text01 := v_text01 || dsp_planilha.campo ( numero ( cr_010.venda_liq_mcd ) );
                        v_text01 := v_text01 || dsp_planilha.campo ( cr_010.status_mcd );
                        v_text01 := v_text01 || dsp_planilha.campo ( numero ( cr_010.venda_liq_gl ) );
                        v_text01 := v_text01 || dsp_planilha.campo ( cr_010.diferenca );
                        v_text01 := v_text01 || dsp_planilha.campo ( cr_010.diferenca_msaf );

                        v_text01 :=
                            dsp_planilha.linha ( v_text01
                                               , v_class );

                        IF v_class = 'a' THEN
                            v_class := 'b';
                        ELSE
                            v_class := 'a';
                        END IF;
                    END;

                    lib_proc.add ( v_text01 );
                END LOOP; --FOR CR_010 IN C_RELATORIO_010(C10_DATA.DATA_NORMAL)
            END LOOP; --FOR i IN 1..A_ESTABS.COUNT
        END LOOP; --FOR C10_DATA IN C_DATAS(P_DATA_INI, P_DATA_FIM)

        lib_proc.add ( dsp_planilha.tabela_fim );
        --lib_proc.add('------|--|----------|--------------|--|--------------|--------------|-|--------------|----------|'); -- AJ0001
        loga ( 'Fim do relatório!' );

        IF ( p_carga_cupom = 'S'
         OR p_diferenca = 'S' ) THEN -- AJ0003 >>
            cria_job_import ( p_data_ini
                            , p_data_fim );
        END IF; -- AJ0003 <<

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

            trace := dbms_utility.format_error_backtrace;
            loga ( trace );

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
END dsp_rel_confronto_cupom_cproc;
/
SHOW ERRORS;
