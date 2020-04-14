Prompt Package Body DPSP_REL_CONF_CUPOM_CPROC;
--
-- DPSP_REL_CONF_CUPOM_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_rel_conf_cupom_cproc
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

    mcod_empresa empresa.cod_empresa%TYPE;
    mcod_estab estabelecimento.cod_estab%TYPE;
    mcod_usuario usuario_empresa.cod_usuario%TYPE;
    macesso_full VARCHAR2 ( 5 );
    mproc_id NUMBER;

    v_sel_data_fim VARCHAR2 ( 260 )
        := ' SELECT TRUNC( TO_DATE( :1 ,''DD/MM/YYYY'') + ROWNUM - 1) AS DATA_FIM, TRUNC( TO_DATE( :1 ,''DD/MM/YYYY'') + ROWNUM - 1) AS DATA_FIM FROM DUAL CONNECT BY ROWNUM <= LAST_DAY( TO_DATE( :1 ,''DD/MM/YYYY'') ) - TO_DATE( :1 ,''DD/MM/YYYY'') + 1 ORDER BY 1 DESC ';

    --Tipo, Nome e Descrição do Customizado
    mnm_tipo VARCHAR2 ( 100 ) := 'Automatização';
    mnm_cproc VARCHAR2 ( 100 ) := 'Relatório / Carga Confronto MSAF x MCD x GL';
    mds_cproc VARCHAR2 ( 100 ) := 'Relatório para Confronto MSAF x MCD x GL e Carga de Cupons Faltantes no MSAF';

    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );
    BEGIN
        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        mcod_estab := lib_parametros.recuperar ( 'ESTABELECIMENTO' );
        mcod_usuario := lib_parametros.recuperar ( 'USUARIO' );

        --VALIDAR ACESSO DO USUÁRIO
        SELECT ( CASE WHEN qtd = 0 THEN 'N' ELSE 'S' END )
          INTO macesso_full
          FROM (SELECT COUNT ( 1 ) qtd
                  FROM pl_grp_usr rol
                     , pl_grp grp
                     , pl_usr usr
                 WHERE 1 = 1
                   AND rol.grp_key = grp.grp_key
                   AND rol.usr_key = usr.usr_key
                   AND grp_name IN ( 'DEVELOPER'
                                   , 'DEVELOPER_DP' )
                   AND TRIM ( UPPER ( usr.usr_login ) ) = TRIM ( UPPER ( mcod_usuario ) ));

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
                            'VARCHAR2'
                           , 'COMBOBOX'
                           , 'S'
                           , NULL
                           , '##########'
                           , v_sel_data_fim );

        lib_proc.add_param (
                             pstr
                           , 'UF'
                           , --P_COD_ESTADO
                            'VARCHAR2'
                           , 'COMBOBOX'
                           , 'S'
                           , '%'
                           , '##########'
                           , 'SELECT A.COD_ESTADO, A.COD_ESTADO FROM ESTADO A UNION ALL SELECT ''%'', ''Todas as UFs'' FROM DUAL ORDER BY 1'
        );

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

        lib_proc.add_param ( pstr
                           ,    LPAD ( ' '
                                     , 62
                                     , ' ' )
                             || '[ Configurar layout do Relatório ] '
                           , 'VARCHAR2'
                           , 'TEXT'
                           , 'N'
                           , '1'
                           , NULL
                           , ''
                           , 'N' );

        lib_proc.add_param ( pparam => pstr
                           , ptitulo => 'Extrair com scripts de recarga'
                           , --P_EXT_CARGA
                            ptipo => 'VARCHAR2'
                           , pcontrole => 'CHECKBOX'
                           , pmandatorio => 'N'
                           , pdefault => NULL
                           , pmascara => NULL
                           , pvalores => NULL );

        lib_proc.add_param ( pstr
                           , 'Extrair com script do Mapa Resumo (CSI)'
                           , --P_EXT_CSI
                            'VARCHAR2'
                           , 'CHECKBOX'
                           , 'N'
                           , 'N'
                           , NULL );

        lib_proc.add_param ( pstr
                           , 'Extrair somente diferenças DH x MSAF'
                           , --P_EXT_DIF
                            'VARCHAR2'
                           , 'CHECKBOX'
                           , 'N'
                           , 'N'
                           , NULL );

        lib_proc.add_param ( pstr
                           , 'Informar ocorrência de Extemporâneos'
                           , --P_IND_EXT
                            'VARCHAR2'
                           , 'CHECKBOX'
                           , 'N'
                           , 'N'
                           , NULL );

        lib_proc.add_param (
                             pstr
                           , 'Estabelecimento'
                           , --P_COD_ESTAB
                            'VARCHAR2'
                           , 'MULTISELECT'
                           , 'S'
                           , 'S'
                           , NULL
                           ,    'SELECT A.COD_ESTAB,A.COD_ESTAB || '' - '' || B.COD_ESTADO || '' - '' || A.CGC || '' - '' || INITCAP(A.BAIRRO) || '' / '' || INITCAP(A.CIDADE)
                            FROM ESTABELECIMENTO A, ESTADO B, MSAFI.DSP_ESTABELECIMENTO C
                            WHERE A.COD_EMPRESA  = '''
                             || mcod_empresa
                             || '''
                              AND B.IDENT_ESTADO = A.IDENT_ESTADO
                              AND A.COD_EMPRESA  = C.COD_EMPRESA
                              AND A.COD_ESTAB    = C.COD_ESTAB
                              AND B.COD_ESTADO LIKE :3  
                              AND C.TIPO = ''L''
                            ORDER BY A.COD_ESTAB
                           '
        );

        RETURN pstr;
    END; --FUNCTION PARAMETROS RETURN VARCHAR2 IS

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN mnm_cproc;
    END;

    FUNCTION tipo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN mnm_tipo;
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
        RETURN mds_cproc;
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
        COMMIT;
    END;

    PROCEDURE envia_email ( vp_cod_empresa IN VARCHAR2
                          , vp_data_ini IN DATE
                          , vp_data_fim IN DATE
                          , vp_msg_oracle IN VARCHAR2
                          , vp_tipo IN VARCHAR2
                          , vp_data_hora_ini IN DATE )
    IS
        vp_data_hora_fim DATE;
        v_diferenca_exec VARCHAR2 ( 50 );
        v_tempo_exec VARCHAR2 ( 50 );

        v_txt_email VARCHAR2 ( 2000 ) := '';
        v_assunto VARCHAR2 ( 100 ) := '';

        v_nm_tipo VARCHAR2 ( 100 );
        v_nm_cproc VARCHAR2 ( 100 );
    BEGIN
        loga ( '>> Envia Email'
             , FALSE );

        SELECT TRANSLATE (
                           mnm_tipo
                         , 'ÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÜÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÜáçéíóúàèìòùâêîôûãõëüáçéíóúàèìòùâêîôûãõëü'
                         , 'ACEIOUAEIOUAEIOUAOEUACEIOUAEIOUAEIOUAOEUaceiouaeiouaeiouaoeuaceiouaeiouaeiouaoeu'
               )
          INTO v_nm_tipo
          FROM DUAL;

        SELECT TRANSLATE (
                           mnm_cproc
                         , 'ÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÜÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÜáçéíóúàèìòùâêîôûãõëüáçéíóúàèìòùâêîôûãõëü'
                         , 'ACEIOUAEIOUAEIOUAOEUACEIOUAEIOUAEIOUAOEUaceiouaeiouaeiouaoeuaceiouaeiouaeiouaoeu'
               )
          INTO v_nm_cproc
          FROM DUAL;

        vp_data_hora_fim := SYSDATE;

        ---------------------------------------------------------------------
        --CALCULAR TEMPO DE EXECUCAO DO RELATORIO
        SELECT b.diferenca
             ,    TRUNC ( MOD ( b.diferenca * 24
                              , 60 ) )
               || ':'
               || TRUNC ( MOD ( b.diferenca * 24 * 60
                              , 60 ) )
               || ':'
               || TRUNC ( MOD ( b.diferenca * 24 * 60 * 60
                              , 60 ) )
                   tempo
          INTO v_diferenca_exec
             , v_tempo_exec
          FROM (SELECT a.data_final - a.data_inicial AS diferenca
                  FROM (SELECT vp_data_hora_ini AS data_inicial
                             , vp_data_hora_fim AS data_final
                          FROM DUAL) a) b;

        ---------------------------------------------------------------------

        IF ( vp_tipo = 'E' ) THEN
            v_txt_email := v_txt_email || CHR ( 13 ) || '[ERRO] ';
        ELSE
            v_txt_email := 'Processo ' || v_nm_cproc || ' finalizado com SUCESSO.';
        END IF;

        v_txt_email :=
               v_txt_email
            || CHR ( 13 )
            || LPAD ( '-'
                    , 50
                    , '-' );
        v_txt_email := v_txt_email || CHR ( 13 ) || ' - Assunto: ' || v_nm_tipo;
        v_txt_email := v_txt_email || CHR ( 13 ) || ' - Processo: ' || v_nm_cproc;

        v_txt_email := v_txt_email || CHR ( 13 ) || ' - Num Processo: ' || mproc_id;
        v_txt_email := v_txt_email || CHR ( 13 ) || ' - Package: ' || $$plsql_unit;

        v_txt_email :=
               v_txt_email
            || CHR ( 13 )
            || LPAD ( '-'
                    , 50
                    , '-' );
        v_txt_email := v_txt_email || CHR ( 13 ) || ' ';

        v_txt_email := v_txt_email || CHR ( 13 ) || '>> Parâmetros: ';
        v_txt_email := v_txt_email || CHR ( 13 ) || ' - Empresa: ' || vp_cod_empresa;
        v_txt_email :=
               v_txt_email
            || CHR ( 13 )
            || ' - Data Início: '
            || TO_CHAR ( vp_data_ini
                       , 'DD/MM/YYYY' );
        v_txt_email :=
               v_txt_email
            || CHR ( 13 )
            || ' - Data Fim: '
            || TO_CHAR ( vp_data_fim
                       , 'DD/MM/YYYY' );
        v_txt_email := v_txt_email || CHR ( 13 ) || ' ';
        v_txt_email := v_txt_email || CHR ( 13 ) || '>> LOG: ';
        v_txt_email := v_txt_email || CHR ( 13 ) || ' - Executado por: ' || mcod_usuario;
        v_txt_email :=
               v_txt_email
            || CHR ( 13 )
            || ' - Hora Início: '
            || TO_CHAR ( vp_data_hora_ini
                       , 'DD/MM/YYYY HH24:MI.SS' );
        v_txt_email :=
               v_txt_email
            || CHR ( 13 )
            || ' - Hora Término: '
            || TO_CHAR ( SYSDATE
                       , 'DD/MM/YYYY HH24:MI.SS' );
        v_txt_email := v_txt_email || CHR ( 13 ) || ' - Tempo Execução: ' || TRIM ( v_tempo_exec );

        IF ( vp_tipo = 'E' ) THEN
            v_txt_email := v_txt_email || CHR ( 13 ) || ' ';
            v_txt_email := v_txt_email || CHR ( 13 ) || '<< ERRO >> ' || CHR ( 13 ) || vp_msg_oracle;
        END IF;

        --TIRAR ACENTOS
        SELECT TRANSLATE (
                           v_txt_email
                         , 'ÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÜÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÜáçéíóúàèìòùâêîôûãõëüáçéíóúàèìòùâêîôûãõëü'
                         , 'ACEIOUAEIOUAEIOUAOEUACEIOUAEIOUAEIOUAOEUaceiouaeiouaeiouaoeuaceiouaeiouaeiouaoeu'
               )
          INTO v_txt_email
          FROM DUAL;

        SELECT TRANSLATE (
                           v_assunto
                         , 'ÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÜÁÇÉÍÓÚÀÈÌÒÙÂÊÎÔÛÃÕËÜáçéíóúàèìòùâêîôûãõëüáçéíóúàèìòùâêîôûãõëü'
                         , 'ACEIOUAEIOUAEIOUAOEUACEIOUAEIOUAEIOUAOEUaceiouaeiouaeiouaoeuaceiouaeiouaeiouaoeu'
               )
          INTO v_assunto
          FROM DUAL;

        IF ( vp_tipo = 'E' ) THEN
            v_assunto := 'Mastersaf - ' || v_nm_tipo || ' - ' || v_nm_cproc || ' apresentou ERRO';
            notifica ( ''
                     , 'S'
                     , v_assunto
                     , v_txt_email
                     , $$plsql_unit );
        ELSE
            v_assunto := 'Mastersaf - ' || v_nm_tipo || ' - ' || v_nm_cproc || ' Concluido';
            notifica ( 'S'
                     , ''
                     , v_assunto
                     , v_txt_email
                     , $$plsql_unit );
        END IF;
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
                      , p_cod_estado VARCHAR2
                      , p_carga_cupom VARCHAR2
                      , p_diferenca VARCHAR2
                      , p_delete VARCHAR2
                      , p_delete_log VARCHAR2
                      , p_ext_carga VARCHAR2
                      , p_ext_csi VARCHAR2
                      , p_ext_dif VARCHAR2
                      , p_ind_ext VARCHAR2
                      , p_cod_estab lib_proc.vartab )
        RETURN INTEGER
    IS
        trace VARCHAR2 ( 4000 );

        mdesc VARCHAR2 ( 4000 );
        i1 INTEGER;
        v_data_exec DATE;
        v_count NUMBER;
        v_valor_ext NUMBER;
        v_extemporaneo VARCHAR2 ( 100 );

        v_msg_sim VARCHAR2 ( 100 ) := '  *SIM*   ';
        v_msg_nao VARCHAR2 ( 100 ) := '  *NÃO*   ';

        v_sep VARCHAR2 ( 1 );

        v_proc_status NUMBER := 0;
        v_s_proc_status VARCHAR2 ( 16 );

        --Variaveis genericas
        v_text01 VARCHAR2 ( 4000 );
        v_text02 VARCHAR2 ( 4000 );
        --
        v_estab_ant VARCHAR2 ( 6 );
        v_009_total NUMBER := 0;

        TYPE a_estabs_t IS TABLE OF VARCHAR2 ( 6 );

        a_estabs a_estabs_t := a_estabs_t ( );

        v_class CHAR ( 1 ) := 'b';

        CURSOR c_datas ( p_data_ini DATE
                       , p_data_fim DATE )
        IS
            SELECT     p_data_ini + ROWNUM - 1 AS data_normal
                     , TO_CHAR ( ( p_data_ini + ROWNUM - 1 )
                               , 'YYYYMMDD' )
                           AS data_safx
                  FROM DUAL
            CONNECT BY LEVEL <= ( p_data_fim - p_data_ini ) + 1
              ORDER BY 1;

        --------------------------------------------------------------------------------------------------------------
        -- RELATORIO: Relatório Confronto MSAF x MCD x GL
        CURSOR c_relatorio_010 (
            p_i_data_fiscal IN DATE
          , p_i_cod_estab IN VARCHAR2
          , p_i_ext_dif VARCHAR2
        )
        IS
            SELECT   x.*
                FROM ( SELECT a.cod_empresa
                            , a.cod_estab
                            , a.uf
                            , a.data_transacao
                            , a.venda_liq_dh
                            , a.status_dh
                            , TO_CHAR ( a.data_alt_status
                                      , 'DD/MM/YYYY HH24:MI:SS' )
                                  AS data_alt_status
                            , a.venda_liq_msaf
                            , a.venda_liq_mcd
                            , a.status_mcd
                            , a.venda_liq_gl
                            , a.diferenca
                            , a.diferenca_msaf
                            , --
                              CASE
                                  WHEN NVL ( a.venda_liq_msaf, 0 ) > NVL ( a.venda_liq_dh, 0 ) THEN v_msg_sim
                                  ELSE v_msg_nao
                              END
                                  AS dif_msaf_maior
                            , --
                              ROUND ( a.venda_liq_msaf - a.venda_liq_dh
                                    , 2 )
                                  AS valor_dif_dh_msaf
                            , --
                               ( CASE
                                    WHEN a.diferenca_msaf = v_msg_sim
                                     AND a.status_dh = 'PR' THEN
                                           ' EXEC MSAF.DPSP_REL_CONF_CUPOM_CPROC.DELETE_CUPOM( '
                                        || --
                                          ' P_I_DATA_INI => '''
                                        || a.data_transacao
                                        || ''' '
                                        || --
                                          ' ,P_I_DATA_FIM => '''
                                        || a.data_transacao
                                        || ''' '
                                        || --
                                          ' ,P_I_COD_EMPRESA => '''
                                        || a.cod_empresa
                                        || ''' '
                                        || --
                                          ' ,P_I_COD_ESTAB => '''
                                        || a.cod_estab
                                        || ''' '
                                        || --
                                          ' ,P_I_DELETE_LOG => ''N'' '
                                        || --
                                          ' ); ' --
                                    ELSE
                                        ''
                                END )
                                  AS script_delete
                            , --
                               ( CASE
                                    WHEN a.diferenca_msaf = v_msg_sim
                                     AND a.status_dh = 'PR' THEN
                                           ' EXEC MSAFI.PRC_MSAF_CUPOM_E( '
                                        || ' P_COD_EMPRESA    => '''
                                        || a.cod_empresa
                                        || ''' '
                                        || --
                                          ' ,P_DATA_INI => '''
                                        || TO_CHAR ( a.data_transacao
                                                   , 'YYYYMMDD' )
                                        || ''' '
                                        || --
                                          ' ,P_DATA_FIM => '''
                                        || TO_CHAR ( a.data_transacao
                                                   , 'YYYYMMDD' )
                                        || ''' '
                                        || --
                                          ' ,P_COD_ESTAB => '''
                                        || a.cod_estab
                                        || ''' '
                                        || --
                                          ' ); ' --
                                    ELSE
                                        ''
                                END )
                                  AS script_cfe
                            , --
                               ( CASE
                                    WHEN a.diferenca_msaf = v_msg_sim
                                     AND a.status_dh = 'PR' THEN
                                           ' EXEC MSAFI.PRC_MSAF_DH_CUPOM( '
                                        || --
                                          ' P_COD_EMPRESA => '''
                                        || a.cod_empresa
                                        || ''' '
                                        || --
                                          ' ,P_DATA_INI => '''
                                        || TO_CHAR ( a.data_transacao
                                                   , 'YYYYMMDD' )
                                        || ''' '
                                        || --
                                          ' ,P_DATA_FIM => '''
                                        || TO_CHAR ( a.data_transacao
                                                   , 'YYYYMMDD' )
                                        || ''' '
                                        || --
                                          ' ,P_COD_ESTAB => '''
                                        || a.cod_estab
                                        || ''' '
                                        || --
                                          ' ); ' --
                                    ELSE
                                        ''
                                END )
                                  AS script_cf
                            , ( CASE
                                   WHEN a.diferenca_msaf = v_msg_sim
                                    AND a.status_dh = 'PR' THEN
                                          ' EXEC MSAFI.PRC_DPSP_CARGA_DH_CSI( '
                                       || --
                                         ' P_COD_EMPRESA => '''
                                       || a.cod_empresa
                                       || ''' '
                                       || --
                                         ' ,P_DATA_INI => '''
                                       || TO_CHAR ( a.data_transacao
                                                  , 'YYYYMMDD' )
                                       || ''' '
                                       || --
                                         ' ,P_DATA_FIM => '''
                                       || TO_CHAR ( a.data_transacao
                                                  , 'YYYYMMDD' )
                                       || ''' '
                                       || --
                                         ' ,P_COD_ESTAB => '''
                                       || a.cod_estab
                                       || ''' '
                                       || --
                                         ' ); ' --
                                   ELSE
                                       ''
                               END )
                                  AS script_csi
                         FROM ( SELECT mcod_empresa AS cod_empresa
                                     , est.cod_estab AS cod_estab
                                     , est.cod_estado AS uf
                                     , COALESCE ( dh.data_transacao
                                                , cf.data_transacao
                                                , mcd.data_transacao )
                                           AS data_transacao
                                     , NVL ( dh.val_liquido, 0 ) AS venda_liq_dh
                                     , dh.status_dh AS status_dh
                                     , dh.data_alt_status AS data_alt_status
                                     , NVL ( cf.venda_liq, 0 ) AS venda_liq_msaf
                                     , NVL ( mcd.venda_liq, 0 ) AS venda_liq_mcd
                                     , mcd.status_mcd AS status_mcd
                                     , NVL ( gl.venda_liq, 0 ) AS venda_liq_gl
                                     , CASE
                                           WHEN ( NVL ( dh.val_liquido, 0 ) <> NVL ( cf.venda_liq, 0 ) )
                                             OR ( NVL ( dh.val_liquido, 0 ) <> NVL ( mcd.venda_liq, 0 ) )
                                             OR ( NVL ( dh.val_liquido, 0 ) <> NVL ( gl.venda_liq, 0 ) )
                                             OR ( NVL ( cf.venda_liq, 0 ) <> NVL ( mcd.venda_liq, 0 ) )
                                             OR ( NVL ( cf.venda_liq, 0 ) <> NVL ( gl.venda_liq, 0 ) )
                                             OR ( NVL ( mcd.venda_liq, 0 ) <> NVL ( gl.venda_liq, 0 ) ) THEN
                                               v_msg_sim
                                           ELSE
                                               v_msg_nao
                                       END
                                           AS diferenca
                                     , CASE
                                           WHEN ( NVL ( dh.val_liquido, 0 ) <> NVL ( cf.venda_liq, 0 ) ) THEN v_msg_sim
                                           ELSE v_msg_nao
                                       END
                                           AS diferenca_msaf
                                  FROM -- Inicio da Atualização - 22/01/2019 - Douglas Oliveira - chamado: 2000892
                                       ( SELECT TO_NUMBER ( REGEXP_REPLACE ( cod_estab
                                                                           , 'D|S|P|V|L'
                                                                           , '' ) )
                                                    loja
                                              , TO_DATE ( TO_CHAR ( data_lancto
                                                                  , 'YYYYMMDD' )
                                                        , 'YYYYMMDD' )
                                                    data_transacao
                                              , valor_lancto venda_liq
                                           FROM msafi.dpsp_conf_contab_vw
                                          WHERE cod_empresa = mcod_empresa
                                            AND TO_CHAR ( REGEXP_REPLACE ( cod_estab
                                                                         , 'D|S|P|V|L'
                                                                         , '' ) ) =
                                                    TO_CHAR ( REGEXP_REPLACE ( p_i_cod_estab
                                                                             , 'D|S|P|V|L'
                                                                             , '' ) )
                                            AND data_lancto = p_i_data_fiscal ) gl
                                     , -- Fim da Atualização - 22/01/2019 - Douglas Oliveira

                                       (SELECT   ptf.codigo_loja loja
                                               , TO_DATE ( ptf.data_transacao
                                                         , 'YYYYMMDD' )
                                                     data_transacao
                                               , pfe.status_proc_1 status_dh
                                               , MAX ( pfe.data_proc_1 ) data_alt_status
                                               , SUM ( ptf.val_liquido ) val_liquido
                                            FROM msafi.p2k_trib_fech ptf
                                               , msafi.p2k_fechamento pfe
                                           WHERE ptf.codigo_loja = TO_NUMBER ( REGEXP_REPLACE ( p_i_cod_estab
                                                                                              , 'D|S|P|V|L'
                                                                                              , '' ) )
                                             AND ptf.data_transacao = TO_CHAR ( p_i_data_fiscal
                                                                              , 'YYYYMMDD' )
                                             AND ptf.codigo_loja = pfe.codigo_loja
                                             AND ptf.data_transacao = pfe.data_transacao
                                             AND ptf.numero_componente = pfe.numero_componente
                                             AND ptf.nsu_transacao = pfe.nsu_transacao
                                        GROUP BY ptf.codigo_loja
                                               , ptf.data_transacao
                                               , pfe.status_proc_1) dh
                                     , (SELECT   est.codigo_loja loja
                                               , data_fiscal data_transacao
                                               , SUM ( cfe.vlr_contab_item ) venda_liq
                                            FROM msaf.dwt_itens_merc cfe
                                               , msafi.dsp_estabelecimento est
                                           WHERE cfe.cod_empresa = mcod_empresa
                                             AND cfe.cod_estab = p_i_cod_estab
                                             AND data_fiscal = p_i_data_fiscal
                                             AND cfe.ident_docto IN ( SELECT ident_docto
                                                                        FROM msaf.x2005_tipo_docto
                                                                       WHERE cod_docto IN ( 'CF'
                                                                                          , 'CF-E'
                                                                                          , 'SAT' ) )
                                             AND cfe.cod_empresa = est.cod_empresa
                                             AND cfe.cod_estab = est.cod_estab
                                        GROUP BY est.codigo_loja
                                               , data_fiscal) cf
                                     , ( SELECT   TO_NUMBER ( REGEXP_REPLACE ( pdv.business_unit
                                                                             , 'D|S|P|V|L'
                                                                             , '' ) )
                                                      loja
                                                , pdv.dsp_dt_mov data_transacao
                                                , SUM ( pdv.dsp_venda_liq_1 ) venda_liq
                                                , apur.dsp_status_mcd status_mcd
                                             FROM msafi.ps_dsp_pdv_mcd pdv
                                                , msafi.ps_dsp_apur_mcd apur
                                            WHERE pdv.dsp_dt_mov = p_i_data_fiscal
                                              AND TO_NUMBER ( REGEXP_REPLACE ( pdv.business_unit
                                                                             , 'D|S|P|V|L'
                                                                             , '' ) ) =
                                                      TO_NUMBER ( REGEXP_REPLACE ( p_i_cod_estab
                                                                                 , 'D|S|P|V|L'
                                                                                 , '' ) )
                                              AND pdv.business_unit = apur.business_unit
                                              AND pdv.dsp_dt_mov = apur.dsp_dt_mov
                                              AND ( pdv.business_unit LIKE 'VD%'
                                                OR pdv.business_unit LIKE 'L%' )
                                              AND apur.dsp_status_mcd IN ( 'C'
                                                                         , 'V'
                                                                         , 'F' ) --- CONCLUIDO = C/ CONFERIDO = V/ FECHADO = F
                                         GROUP BY TO_NUMBER ( REGEXP_REPLACE ( pdv.business_unit
                                                                             , 'D|S|P|V|L'
                                                                             , '' ) )
                                                , pdv.dsp_dt_mov
                                                , apur.dsp_status_mcd ) mcd
                                     , (SELECT *
                                          FROM msafi.dsp_estabelecimento est
                                         WHERE est.cod_empresa = mcod_empresa
                                           AND est.cod_estab = p_i_cod_estab) est
                                 WHERE est.codigo_loja = cf.loja(+)
                                   AND est.codigo_loja = mcd.loja(+)
                                   AND est.codigo_loja = dh.loja(+)
                                   AND est.codigo_loja = gl.loja(+)
                                   AND est.cod_estab = p_i_cod_estab
                                   AND est.cod_empresa = mcod_empresa ) a
                        WHERE a.venda_liq_dh <> 0
                           OR a.venda_liq_msaf <> 0
                           OR a.venda_liq_mcd <> 0
                           OR a.venda_liq_gl <> 0 ) x
            ORDER BY x.data_transacao
                   , x.cod_estab;
    --------------------------------------------------------------------------------------------------------------

    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS= '',.'' ';

        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_LANGUAGE = ''Portuguese'' ';

        --Performar em caso de códigos repetitivos no mesmo plano de execução
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING = FORCE';

        --Recuperar a empresa para o plano de execução caso não esteja sendo executado pelo diretamente na tela do Mastersaf
        lib_parametros.salvar ( 'EMPRESA'
                              , NVL ( mcod_empresa, msafi.dpsp.v_empresa ) );

        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        mcod_usuario := lib_parametros.recuperar ( 'USUARIO' );
        mdesc := lib_parametros.recuperar ( 'PDESC' );

        IF mcod_usuario IS NULL THEN
            lib_parametros.salvar ( 'USUARIO'
                                  , 'AUTOMATICO' );
            mcod_usuario := lib_parametros.recuperar ( 'USUARIO' );
            macesso_full := 'S';
        END IF;

        v_count := p_cod_estab.COUNT;

        --Informações as execuções que foram feitas via job Scheduler, PROC ou Bloco Anônimo do PLSQL
        IF mcod_usuario = 'AUTOMATICO' THEN
            mdesc :=
                   '<< Execução via Job Scheduler / PL SQL Block >>'
                || CHR ( 10 )
                || --
                  'Empresa: '
                || mcod_empresa
                || CHR ( 10 )
                || --
                  'Data Inicial: '
                || TO_CHAR ( p_data_ini
                           , 'DD/MM/YYYY' )
                || CHR ( 10 )
                || --
                  'Data Final: '
                || TO_CHAR ( p_data_fim
                           , 'DD/MM/YYYY' )
                || CHR ( 10 )
                || --
                  'UF: '
                || ( CASE WHEN p_cod_estado = '%' THEN 'Todas as UFs' ELSE p_cod_estado END )
                || CHR ( 10 )
                || --
                  'Qtde de Estabelecimentos: '
                || v_count
                || --
                  '';
        END IF; -- VS_MCOD_USUARIO = PCOD_USUARIO

        -- Criação: Processo
        mproc_id :=
            lib_proc.new ( psp_nome => $$plsql_unit
                         , pdescricao => mdesc );
        COMMIT;
        v_data_exec := SYSDATE;

        loga ( '<<' || mnm_cproc || '>>'
             , FALSE );
        loga ( '---INICIO DO PROCESSAMENTO---'
             , FALSE );

        dbms_application_info.set_module ( $$plsql_unit
                                         , 'PROC_ID: ' || mproc_id );

        loga (    'Data execução: '
               || TO_CHAR ( v_data_exec
                          , 'DD/MM/YYYY HH24:MI:SS' )
             , FALSE );

        loga ( LPAD ( '-'
                    , 62
                    , '-' )
             , FALSE );
        loga ( 'Usuário: ' || mcod_usuario
             , FALSE );
        loga ( 'Empresa: ' || mcod_empresa
             , FALSE );
        loga (    'Período: '
               || TO_CHAR ( p_data_ini
                          , 'DD/MM/YYYY' )
               || ' - '
               || TO_CHAR ( p_data_fim
                          , 'DD/MM/YYYY' )
             , FALSE );
        loga ( 'UF: ' || ( CASE WHEN p_cod_estado = '%' THEN 'Todas as UFs' ELSE p_cod_estado END )
             , FALSE );
        loga ( 'Executar Carga Automática de Cupons: ' || ( CASE WHEN p_carga_cupom = 'S' THEN 'SIM' ELSE 'NÃO' END )
             , FALSE );
        loga (
                  'Executar Carga Automática para Quaisquer Diferenças: '
               || ( CASE WHEN p_diferenca = 'S' THEN 'SIM' ELSE 'NÃO' END )
             , FALSE
        );
        loga ( 'Excluir Cupons Fiscais Antes da Carga: ' || ( CASE WHEN p_delete = 'S' THEN 'SIM' ELSE 'NÃO' END )
             , FALSE );
        loga ( 'Ativar LOG de Exclusão de Cupons: ' || ( CASE WHEN p_delete_log = 'S' THEN 'SIM' ELSE 'NÃO' END )
             , FALSE );
        loga ( 'Extrair com scripts de recarga: ' || ( CASE WHEN p_ext_carga = 'S' THEN 'SIM' ELSE 'NÃO' END )
             , FALSE );
        loga ( 'Extrair com scripts do Mapa Resumo (CSI): ' || ( CASE WHEN p_ext_csi = 'S' THEN 'SIM' ELSE 'NÃO' END )
             , FALSE );
        loga ( 'Informar ocorrência de Extemporâneos: ' || ( CASE WHEN p_ind_ext = 'S' THEN 'SIM' ELSE 'NÃO' END )
             , FALSE );
        loga ( 'Extrair somente diferenças DH x MSAF: ' || ( CASE WHEN p_ext_dif = 'S' THEN 'SIM' ELSE 'NÃO' END )
             , FALSE );
        loga ( 'Qtde Estabs: ' || v_count
             , FALSE );
        loga ( LPAD ( '-'
                    , 62
                    , '-' )
             , FALSE );

        IF macesso_full = 'N'
       AND ( p_carga_cupom = 'S'
         OR p_diferenca = 'S'
         OR p_delete = 'S'
         OR p_delete_log = 'S'
         OR p_ext_carga = 'S'
         OR p_ext_csi = 'S'
         OR p_ext_dif = 'S' ) THEN
            loga ( LPAD ( '-'
                        , 62
                        , '-' )
                 , FALSE );
            loga ( 'ATENÇÃO! As opções de execução de carga são de uso exclusivo do Suporte Mastersaf!'
                 , FALSE );
            loga ( 'Não são permitidas as opções selecionados no relatório para o usuário atual:'
                 , FALSE );
            loga ( mcod_usuario
                 , FALSE );
            loga ( LPAD ( '-'
                        , 62
                        , '-' )
                 , FALSE );
            loga ( 'STATUS FINAL: [ERRO]' );
            loga ( '---FIM DO PROCESSAMENTO---'
                 , FALSE );

            --ENVIAR EMAIL DE ERRO-------------------------------------------
            envia_email (
                          mcod_empresa
                        , p_data_ini
                        , p_data_fim
                        ,    'A execução deste customizado é de uso exclusivo do Suporte Mastersaf!'
                          || CHR ( 10 )
                          || 'O usuário '
                          || mcod_usuario
                          || ' não apresenta as permissões necessárias.'
                        , 'E'
                        , v_data_exec
            );
            -----------------------------------------------------------------

            lib_proc.close ( );
            COMMIT;
            RETURN mproc_id;
        END IF;

        IF TO_NUMBER ( TO_CHAR ( p_data_ini
                               , 'YYYY' ) ) = '1900' THEN
            loga ( LPAD ( '-'
                        , 62
                        , '-' )
                 , FALSE );
            loga ( 'Não é possível prosseguir com o período informado.'
                 , FALSE );
            loga ( LPAD ( '-'
                        , 62
                        , '-' )
                 , FALSE );
            loga ( '---FIM DO PROCESSAMENTO---'
                 , FALSE );
            lib_proc.close ( );
            COMMIT;
            RETURN mproc_id;
        END IF;

        msafi.dsp_aux.truncatabela_msafi ( 'DSP_PROC_ESTABS' );
        v_sep := CHR ( 9 );

        lib_proc.add_tipo ( mproc_id
                          , 1
                          ,    mcod_empresa
                            || '_'
                            || TO_CHAR ( p_data_ini
                                       , 'MMYYYY' )
                            || '_REL_CONFRONTO_MSAF_MCD_GL.XLS'
                          , 2 ); --AJ0001

        IF mcod_empresa IS NULL THEN
            lib_proc.add_log ( 'Código da empresa deve ser informado como parâmetro global.'
                             , 0 );
            lib_proc.close;
            RETURN mproc_id;
        END IF;

        msafi.dsp_control.createprocess ( 'REL_CONFR_CUPOM'
                                        , --P_I_PROCID            IN VARCHAR2              --VARCHAR2(16)
                                         'CUSTOMIZADO MASTERSAF: RELATORIO CONFRONTO'
                                        , --P_I_PROC_DESCR        IN VARCHAR2              --VARCHAR2(64)
                                         p_data_ini
                                        , --P_I_DATA_INI          IN DATE     DEFAULT NULL
                                         p_data_fim
                                        , --P_I_DATA_FIM          IN DATE     DEFAULT NULL
                                         NULL
                                        , --P_I_DETALHES1         IN VARCHAR2 DEFAULT NULL --VARCHAR2(32)
                                         NULL
                                        , --P_I_DETALHES2         IN VARCHAR2 DEFAULT NULL --VARCHAR2(32)
                                         NULL
                                        , --P_I_DETALHES3         IN VARCHAR2 DEFAULT NULL --VARCHAR2(32)
                                         NULL
                                        , --P_I_DETALHES4         IN VARCHAR2 DEFAULT NULL --VARCHAR2(32)
                                         mcod_usuario --P_I_USER              IN VARCHAR2 DEFAULT NULL  --VARCHAR2(64)
                                                      );
        v_proc_status := 1; --EM PROCESSO

        ---ESTABELECIMENTOS
        IF ( p_cod_estab.COUNT > 0 ) THEN
            i1 := p_cod_estab.FIRST;

            WHILE i1 IS NOT NULL LOOP
                a_estabs.EXTEND ( );
                a_estabs ( a_estabs.LAST ) := p_cod_estab ( i1 );
                i1 := p_cod_estab.NEXT ( i1 );
            END LOOP;
        ELSE
            FOR c1 IN ( SELECT cod_estab
                          FROM estabelecimento
                         WHERE cod_empresa = mcod_empresa ) LOOP
                a_estabs.EXTEND ( );
                a_estabs ( a_estabs.LAST ) := c1.cod_estab;
            END LOOP;
        END IF;

        loga ( 'Imprimindo relatório' );
        loga ( ' ' );

        BEGIN
            lib_proc.add ( dsp_planilha.header );
            lib_proc.add ( dsp_planilha.tabela_inicio );
            lib_proc.add ( dsp_planilha.linha (
                                                p_conteudo =>    dsp_planilha.campo ( 'ESTAB' )
                                                              || --
                                                                dsp_planilha.campo ( 'UF' )
                                                              || --
                                                                dsp_planilha.campo ( 'DT TRANSACAO' )
                                                              || --
                                                                dsp_planilha.campo ( 'STATUS' )
                                                              || --
                                                                dsp_planilha.campo ( 'DT STATUS' )
                                                              || --
                                                                dsp_planilha.campo ( 'VENDA LIQ DH' )
                                                              || --
                                                                dsp_planilha.campo ( 'VENDA LIQ MSAF' )
                                                              || --
                                                                 ( CASE
                                                                      WHEN p_ext_dif = 'N' THEN --
                                                                             dsp_planilha.campo ( 'VENDA LIQ MCD' )
                                                                          || --
                                                                            dsp_planilha.campo ( ' ' )
                                                                          || --
                                                                            dsp_planilha.campo ( 'VENDA LIQ GL' )
                                                                          || --
                                                                            dsp_planilha.campo ( 'DIFERENÇA?' ) --
                                                                  END )
                                                              || --
                                                                dsp_planilha.campo ( 'DIF DH x MSAF?' )
                                                              || ( CASE
                                                                      WHEN p_ind_ext = 'S' THEN --
                                                                             dsp_planilha.campo (
                                                                                                  'EXTEMPORÂNEO?'
                                                                                                , p_custom => 'BGCOLOR=red'
                                                                             )
                                                                          || --
                                                                            dsp_planilha.campo (
                                                                                                 'VLR DIF DH x MSAF'
                                                                                               , p_custom => 'BGCOLOR=red'
                                                                             )
                                                                          || --
                                                                            dsp_planilha.campo (
                                                                                                 'DIF EXTEMPORÂNEO'
                                                                                               , p_custom => 'BGCOLOR=red'
                                                                             )
                                                                          || --
                                                                            ''
                                                                  END )
                                                              || --
                                                                 ( CASE
                                                                      WHEN p_ext_carga = 'S' THEN --
                                                                             dsp_planilha.campo (
                                                                                                  'DIF MSAF MAIOR?'
                                                                                                , p_custom => 'BGCOLOR=red'
                                                                             )
                                                                          || --
                                                                            dsp_planilha.campo (
                                                                                                 'EXCLUIR CUPOM'
                                                                                               , p_custom => 'BGCOLOR=green'
                                                                             )
                                                                          || --
                                                                            dsp_planilha.campo (
                                                                                                 'CARREGAR CUPOM ELETRÔNICO'
                                                                                               , p_custom => 'BGCOLOR=green'
                                                                             )
                                                                          || --
                                                                            dsp_planilha.campo (
                                                                                                 'CARREGAR CUPOM'
                                                                                               , p_custom => 'BGCOLOR=green'
                                                                             )
                                                                  END )
                                                              || --
                                                                 ( CASE
                                                                      WHEN p_ext_csi = 'S' THEN --
                                                                          dsp_planilha.campo (
                                                                                               'CARREGAR MAPA RESUMO (CSI)'
                                                                                             , p_custom => 'BGCOLOR=green'
                                                                          )
                                                                  END )
                                                              || --
                                                                 ( CASE
                                                                      WHEN p_ext_carga = 'S'
                                                                        OR p_ext_csi = 'S' THEN --
                                                                          dsp_planilha.campo (
                                                                                               '-'
                                                                                             , p_custom => 'BGCOLOR=green'
                                                                          )
                                                                  END )
                                                              || --
                                                                ''
                                              , p_class => 'h'
                           ) );
        END;

        loga ( 'Abrindo cursor' );
        v_estab_ant := '';

        FOR c10_data IN c_datas ( p_data_ini
                                , p_data_fim ) LOOP
            loga ( '>> DIA: ' || c10_data.data_normal );

            FOR i IN 1 .. a_estabs.COUNT LOOP
                FOR cr_010 IN c_relatorio_010 ( c10_data.data_normal
                                              , a_estabs ( i )
                                              , p_ext_dif ) LOOP
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
                   AND cr_010.diferenca = v_msg_sim
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

                    --====================================================================
                    --VERIFICAR EXISTÊNCIA DE CUPONS EXTEMPORANEOS PARA A LOJA
                    v_valor_ext := 0;

                    IF p_ind_ext = 'S'
                   AND TO_CHAR ( cr_010.data_transacao
                               , 'DD' ) = '01' THEN
                        --CASO EXISTAM INFORMAÇÕES DE CUPONS DESTA LOJA NO PERIODO ATUAL, ESTES CUPONS FORAM
                        --IMPORTADOS NO PRIMEIRO DIA DO PERIODO SEGUINTE
                        SELECT SUM ( e.valor_tot_capa )
                          INTO v_valor_ext
                          FROM msaf_cupons_exteporaneo e
                         WHERE 1 = 1
                           AND e.cod_empresa = mcod_empresa
                           AND e.cod_estab = cr_010.cod_estab
                           AND e.data_fiscal = cr_010.data_transacao - 1
                           AND e.ident_docto IN ( SELECT ident_docto f
                                                    FROM msaf.x2005_tipo_docto f
                                                   WHERE f.cod_docto IN ( 'CF'
                                                                        , 'CF-E'
                                                                        , 'SAT' ) );

                        IF v_valor_ext <> 0 THEN
                            v_extemporaneo := v_msg_sim;
                        ELSE
                            v_extemporaneo := v_msg_nao;
                        END IF;
                    END IF;

                    --====================================================================

                    IF p_ext_dif = 'N'
                    OR ( p_ext_dif = 'S'
                    AND TRIM ( cr_010.diferenca_msaf ) = TRIM ( v_msg_sim ) ) THEN
                        BEGIN
                            v_text01 := dsp_planilha.campo ( cr_010.cod_estab );
                            v_text01 := v_text01 || dsp_planilha.campo ( cr_010.uf );
                            v_text01 := v_text01 || dsp_planilha.campo ( cr_010.data_transacao );
                            v_text01 := v_text01 || dsp_planilha.campo ( cr_010.status_dh );
                            v_text01 := v_text01 || dsp_planilha.campo ( cr_010.data_alt_status );
                            v_text01 := v_text01 || dsp_planilha.campo ( numero ( cr_010.venda_liq_dh ) );
                            v_text01 := v_text01 || dsp_planilha.campo ( numero ( cr_010.venda_liq_msaf ) );

                            --
                            IF p_ext_dif = 'N' THEN
                                v_text01 := v_text01 || dsp_planilha.campo ( numero ( cr_010.venda_liq_mcd ) );
                                v_text01 := v_text01 || dsp_planilha.campo ( cr_010.status_mcd );
                                v_text01 := v_text01 || dsp_planilha.campo ( numero ( cr_010.venda_liq_gl ) );
                                v_text01 := v_text01 || dsp_planilha.campo ( cr_010.diferenca );
                            END IF;

                            --
                            v_text01 := v_text01 || dsp_planilha.campo ( cr_010.diferenca_msaf );

                            --
                            IF p_ind_ext = 'S' THEN
                                v_text01 := v_text01 || dsp_planilha.campo ( NVL ( v_extemporaneo, v_msg_nao ) );
                                v_text01 := v_text01 || dsp_planilha.campo ( NVL ( cr_010.valor_dif_dh_msaf, 0 ) );
                                v_text01 := v_text01 || dsp_planilha.campo ( NVL ( v_valor_ext, 0 ) );
                            END IF;

                            --
                            IF p_ext_carga = 'S' THEN
                                v_text01 := v_text01 || dsp_planilha.campo ( cr_010.dif_msaf_maior );

                                --NÃO PREENCHER O DELETE QUANDO O DIA TIVER CUPONS EXTEMPORANEOS
                                IF p_ind_ext = 'S'
                               AND TRIM ( v_extemporaneo ) = TRIM ( v_msg_sim ) THEN
                                    v_text01 := v_text01 || dsp_planilha.campo ( '-' );
                                ELSE
                                    v_text01 := v_text01 || dsp_planilha.campo ( cr_010.script_delete );
                                END IF;

                                --
                                v_text01 := v_text01 || dsp_planilha.campo ( cr_010.script_cfe );
                                v_text01 := v_text01 || dsp_planilha.campo ( cr_010.script_cf );
                            END IF;

                            IF p_ext_csi = 'S' THEN
                                v_text01 := v_text01 || dsp_planilha.campo ( cr_010.script_csi );
                            END IF;

                            IF p_ext_carga = 'S'
                            OR p_ext_csi = 'S' THEN
                                v_text01 := v_text01 || dsp_planilha.campo ( '-' );
                            END IF;

                            --
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
                    END IF; -- P_EXT_DIF
                END LOOP; --FOR CR_010 IN C_RELATORIO_010(C10_DATA.DATA_NORMAL)
            END LOOP; --FOR i IN 1..A_ESTABS.COUNT
        END LOOP; --FOR C10_DATA IN C_DATAS(P_DATA_INI, P_DATA_FIM)

        lib_proc.add ( dsp_planilha.tabela_fim );

        loga ( 'Fim do relatório!' );

        IF ( p_carga_cupom = 'S'
         OR p_diferenca = 'S' ) THEN
            cria_job_import ( p_data_ini
                            , p_data_fim );
        END IF;

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

        loga ( 'STATUS FINAL: [' || v_s_proc_status || ']' );

        msafi.dsp_control.updateprocess ( v_s_proc_status );

        loga ( '---FIM DO PROCESSAMENTO---'
             , FALSE );

        lib_proc.close ( );
        COMMIT;
        RETURN mproc_id;
    EXCEPTION
        WHEN OTHERS THEN
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
    --CONFIGURA AS VARIÁVEIS PARA FUNÇÕES REGEXP
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
END dpsp_rel_conf_cupom_cproc;
/
SHOW ERRORS;
