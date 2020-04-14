Prompt Package Body DPSP_MONITORA_CPROC;
--
-- DPSP_MONITORA_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_monitora_cproc
IS
    mproc_id NUMBER;
    vn_linha NUMBER := 0;
    vn_pagina NUMBER := 0;
    mnm_usuario usuario_estab.cod_usuario%TYPE;
    mcod_empresa estabelecimento.cod_empresa%TYPE;

    --Tipo, Nome e Descrição do Customizado
    mnm_tipo VARCHAR2 ( 100 ) := 'Monitora';
    mnm_cproc VARCHAR2 ( 100 ) := 'Executa monitoramento de objetos';
    mds_cproc VARCHAR2 ( 100 ) := 'Relatório monitoramento de objetos';

    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );
    BEGIN
        mnm_usuario := lib_parametros.recuperar ( UPPER ( 'USUARIO' ) );
        mcod_empresa := lib_parametros.recuperar ( UPPER ( 'EMPRESA' ) );

        RETURN pstr;
    END;

    FUNCTION tipo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN mnm_tipo;
    END;

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN mnm_cproc;
    END;

    FUNCTION descricao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN mds_cproc;
    END;

    FUNCTION versao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN '1.0';
    END;

    FUNCTION modulo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Customizados';
    END;

    FUNCTION classificacao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Customizados';
    END;

    FUNCTION orientacao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'PORTRAIT';
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

    FUNCTION executar
        RETURN INTEGER
    IS
        qtde_indices_invalidos INTEGER;

        p_dt_inicio DATE := SYSDATE;
        p_dt_fim DATE := SYSDATE;
    BEGIN
        -- Criação: Processo
        mproc_id := lib_proc.new ( psp_nome => $$plsql_unit );
        COMMIT;

        vn_pagina := 1;
        vn_linha := 48;

        --EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT="DD/MM/YYYY"';
        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT="YYYYMMDD"';

        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS= '',.'' ';

        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        mnm_usuario := lib_parametros.recuperar ( 'USUARIO' );

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

        lib_proc.close;
        RETURN mproc_id;

        SELECT SUM ( qtde ) qtde
          INTO qtde_indices_invalidos
          FROM (SELECT COUNT ( 1 ) qtde
                  FROM all_ind_partitions
                 WHERE index_owner IN ( 'MSAF'
                                      , 'MSAFI' )
                   AND status NOT IN ( 'USABLE'
                                     , 'N/A' )
                UNION ALL
                SELECT COUNT ( 1 ) qtde
                  FROM all_indexes
                 WHERE owner IN ( 'MSAF'
                                , 'MSAFI' )
                   AND status NOT IN ( 'VALID'
                                     , 'N/A' ));

        IF qtde_indices_invalidos > 0 THEN
            loga ( 'Existem indices inválidos no banco de dados da empresa' || mcod_empresa
                 , FALSE );

            dpsp_envia_email ( mcod_empresa
                             , p_dt_inicio
                             , p_dt_fim
                             , 'ORA-20001'
                             , 'E'
                             , TO_CHAR ( SYSDATE
                                       , 'dd/mm/yyyy hh24:mi>:ss' )
                             , 'Existem indices inválidos no banco de dados da empresa ' || mcod_empresa
                             , mnm_usuario
                             , $$plsql_unit );
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            loga ( 'SQLERRM: ' || SQLERRM
                 , FALSE );
            lib_proc.add_log ( 'Erro não tratado: ' || dbms_utility.format_error_backtrace
                             , 1 );
            lib_proc.add_log ( 'SQLERRM: ' || SQLERRM
                             , 1 );
            lib_proc.add ( 'ERRO!'
                         , 1 );
            lib_proc.add ( ' '
                         , 1 );
            lib_proc.add ( dbms_utility.format_error_backtrace
                         , 1 );

            --ENVIAR EMAIL DE ERRO-------------------------------------------

            dpsp_envia_email ( mcod_empresa
                             , p_dt_inicio
                             , p_dt_fim
                             , SQLERRM
                             , 'E'
                             , TO_CHAR ( SYSDATE
                                       , 'dd/mm/yyyy hh24:mi>:ss' )
                             , dbms_utility.format_error_backtrace
                             , mnm_usuario
                             , $$plsql_unit );

            lib_proc.close;
            COMMIT;
            RETURN mproc_id;
    END;

    PROCEDURE executar_job
    IS
        -- Non-scalar parameters require additional processing
        pcod_estab lib_proc.vartab;
        i INTEGER := 0;
        pperiodo DATE := TRUNC ( SYSDATE );
        pcod_estado VARCHAR2 ( 10 ) := '%';
        mproc_id INTEGER;
    BEGIN
        lib_parametros.salvar ( UPPER ( 'USUARIO' )
                              , 'AUTOMATICO' );
        lib_parametros.salvar ( UPPER ( 'EMPRESA' )
                              , msafi.dpsp.v_empresa );

        mproc_id :=
            dpsp_nf_entrada_cproc.executar ( pperiodo => pperiodo
                                           , pcod_estado => pcod_estado
                                           , pcod_estab => pcod_estab );

        -- Atualiza mes atual
        pperiodo :=
            TRUNC ( ADD_MONTHS ( SYSDATE
                               , -1 )
                  , 'MM' );

        mproc_id := dpsp_monitora_cproc.executar;
    END;
END dpsp_monitora_cproc;
/
SHOW ERRORS;
