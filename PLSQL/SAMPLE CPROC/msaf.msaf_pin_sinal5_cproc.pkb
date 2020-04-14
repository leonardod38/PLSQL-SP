Prompt Package Body MSAF_PIN_SINAL5_CPROC;
--
-- MSAF_PIN_SINAL5_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY msaf_pin_sinal5_cproc
IS
    ---------------------------------------------------------------------------------------------------------
    -- Autor         : Wesley Souza - DW Consulting - MasterSaf
    -- Created       : 11/04/2008
    -- Purpose       : Relatório Pin-Sinal.
    ---------------------------------------------------------------------------------------------------------

    --variáveis de status

    mcod_estab estabelecimento.cod_estab%TYPE;
    mcod_empresa empresa.cod_empresa%TYPE;
    musuario usuario_estab.cod_usuario%TYPE;


    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );
    BEGIN
        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        mcod_estab := lib_parametros.recuperar ( 'ESTABELECIMENTO' );
        musuario := lib_parametros.recuperar ( 'Usuario' );

        lib_proc.add_param ( pstr
                           , 'Data Inicial da Geração do LOTE'
                           , 'Date'
                           , 'textbox'
                           , 'N'
                           , NULL
                           , 'DD/MM/YYYY' );

        lib_proc.add_param ( pstr
                           , 'Data Final da Geração do LOTE'
                           , 'Date'
                           , 'textbox'
                           , 'N'
                           , NULL
                           , 'DD/MM/YYYY' );

        lib_proc.add_param (
                             pstr
                           , 'Estabelecimentos'
                           , 'Varchar2'
                           , 'MULTISELECT'
                           , 'S'
                           , NULL
                           , NULL
                           ,    'SELECT distinct nflote.cod_estab, estab.cod_estab||'' - ''||estab.razao_social from estabelecimento estab, tb_msaf_nf_lote nflote
                              where  estab.cod_estab = nflote.cod_estab
                              and    estab.cod_empresa = nflote.cod_empresa
                              and    nflote.cod_empresa = '''
                             || mcod_empresa
                             || ''''
        );

        RETURN pstr;
    END;

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN '5 - Relatório de Lote Pin - Sinal';
    END;

    FUNCTION tipo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Pin - Sinal';
    END;

    FUNCTION versao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN '1.0';
    END;

    FUNCTION descricao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Relatório de Conferencia';
    END;

    FUNCTION modulo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'ESPECIFICOS';
    END;

    FUNCTION classificacao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'PIN - SINAL';
    END;

    FUNCTION executar ( pd_dt_ini DATE
                      , pd_dt_fim DATE
                      , ps_cod_estab lib_proc.vartab )
        RETURN INTEGER
    IS
        /* Variaveis de Trabalho */
        mproc_id INTEGER;
        mlinha VARCHAR2 ( 250 );
        vn_linha NUMBER := 0;
        i INTEGER;
        vs_razao VARCHAR2 ( 160 );
        vs_cgc VARCHAR2 ( 50 );
        vn_folha NUMBER := 1;
    BEGIN
        -- Cria Processo
        mproc_id :=
            lib_proc.new ( 'MSAF_PIN_SINAL5_CPROC'
                         , 48
                         , 250 );

        lib_proc.add_tipo ( mproc_id
                          , 1
                          , 'Relatório Lote Pin - Sinal '
                          , 1 );


        DECLARE
        BEGIN
            DECLARE
                vs_cod_estab VARCHAR2 ( 20 ) := '';
            BEGIN
                BEGIN
                    SELECT cod_empresa || ' - ' || razao_social
                         ,    SUBSTR ( cnpj
                                     , 1
                                     , 2 )
                           || '.'
                           || SUBSTR ( cnpj
                                     , 3
                                     , 3 )
                           || '.'
                           || SUBSTR ( cnpj
                                     , 6
                                     , 3 )
                           || '/'
                           || SUBSTR ( cnpj
                                     , 9
                                     , 4 )
                           || '-'
                           || SUBSTR ( cnpj
                                     , 13
                                     , 2 )
                               cnpj
                      INTO vs_razao
                         , vs_cgc
                      FROM empresa
                     WHERE cod_empresa = mcod_empresa;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        vs_razao := 'Empresa não Encontrada';
                    WHEN OTHERS THEN
                        vs_razao := 'Erro ao Localizar';
                END;

                cabecalho_ini ( vs_razao
                              , vs_cgc
                              , vn_folha );
                vn_linha := 10;

                i := ps_cod_estab.FIRST;

                --Verifica o Estabelecimento
                WHILE i IS NOT NULL LOOP
                    vs_cod_estab := ps_cod_estab ( i );

                    FOR c3
                        IN ( SELECT   nflote.num_lote
                                    , nflote.num_docfis
                                    , nflote.serie_docfis
                                    , nflote.data_fiscal
                                    , lote.cod_pin
                                    , SUBSTR ( x04.razao_social
                                             , 1
                                             , 25 )
                                          razao
                                 FROM tb_msaf_nf_lote nflote
                                    , tb_msaf_lote lote
                                    , x04_pessoa_fis_jur x04
                                WHERE nflote.num_lote = lote.num_lote
                                  AND nflote.ident_fis_jur = x04.ident_fis_jur
                                  AND nflote.cod_empresa = mcod_empresa
                                  AND nflote.cod_estab = vs_cod_estab
                                  AND lote.data_geracao BETWEEN DECODE ( pd_dt_ini, NULL, lote.data_geracao, pd_dt_ini )
                                                            AND DECODE ( pd_dt_fim, NULL, lote.data_geracao, pd_dt_fim )
                                  AND nflote.status = 'C'
                             ORDER BY lote.num_lote ) LOOP
                        IF vn_linha >= 48 THEN
                            vn_folha := vn_folha + 1;
                            lib_proc.new_page ( );
                            cabecalho_ini ( vs_razao
                                          , vs_cgc
                                          , vn_folha );
                            vn_linha := 8;
                        END IF;

                        mlinha :=
                            lib_str.w ( ''
                                      , ' '
                                      , 1 );
                        mlinha :=
                            lib_str.w ( mlinha
                                      , c3.num_lote
                                      , 2 );
                        mlinha :=
                            lib_str.w ( mlinha
                                      , c3.num_docfis
                                      , 10 );
                        mlinha :=
                            lib_str.w ( mlinha
                                      , c3.serie_docfis
                                      , 32 );
                        mlinha :=
                            lib_str.w ( mlinha
                                      , TO_CHAR ( c3.data_fiscal
                                                , 'dd/mm/yyyy' )
                                      , 40 );
                        mlinha :=
                            lib_str.w ( mlinha
                                      , c3.razao
                                      , 60 );
                        mlinha :=
                            lib_str.w ( mlinha
                                      , c3.cod_pin
                                      , 90 );
                        lib_proc.add ( mlinha );

                        vn_linha := vn_linha + 1;
                    END LOOP;

                    i := ps_cod_estab.NEXT ( i );
                END LOOP;

                lib_proc.add_log (
                                   '----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------'
                                 , 0
                );
                lib_proc.add_log ( ' Finalizado com sucesso '
                                 , 5 );
                lib_proc.add_log (
                                   '----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------'
                                 , 0
                );
                lib_proc.add_log (    'FINAL DO PROCESSO:  '
                                   || TO_CHAR ( SYSDATE
                                              , 'DD/MM/YYYY HH24:MI:SS' )
                                 , 1 );
            EXCEPTION
                WHEN OTHERS THEN
                    lib_proc.add_log (
                                       '----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------'
                                     , 0
                    );
                    lib_proc.add_log ( ' Finalizado com erro cursor ' || SQLERRM
                                     , 1 );
                    lib_proc.add_log (
                                       '----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------'
                                     , 0
                    );
            END;
        END;

        lib_proc.close ( );

        RETURN mproc_id;
    END;

    ---

    PROCEDURE cabecalho_ini ( ps_razao VARCHAR2
                            , ps_cnpj VARCHAR2
                            , pn_folha NUMBER )
    IS
        mlinha VARCHAR2 ( 1000 );
    BEGIN
        mlinha := NULL;
        mlinha :=
            lib_str.w ( mlinha
                      , 'Empresa:'
                      , 2 );
        mlinha :=
            lib_str.w ( mlinha
                      , '' || ps_razao || ''
                      , 10 );
        mlinha :=
            lib_str.w ( mlinha
                      , 'Data de Extração:'
                      , 70 );
        mlinha :=
            lib_str.w ( mlinha
                      , '' || SYSDATE || ''
                      , 87 );
        lib_proc.add ( mlinha );
        mlinha := NULL;
        mlinha :=
            lib_str.w ( mlinha
                      , 'CNPJ:'
                      , 2 );
        mlinha :=
            lib_str.w ( mlinha
                      , '' || ps_cnpj || ''
                      , 10 );
        mlinha :=
            lib_str.w ( mlinha
                      , 'Folha:'
                      , 70 );
        mlinha :=
            lib_str.w ( mlinha
                      , '' || pn_folha || ''
                      , 76 );
        lib_proc.add ( mlinha );
        mlinha := NULL;
        mlinha :=
            lib_str.w ( mlinha
                      , 'Relatório de PIN - SINAL'
                      , 40 );
        lib_proc.add ( mlinha );
        mlinha := NULL;
        mlinha :=
            lib_str.w ( mlinha
                      , RPAD ( '='
                             , 100
                             , '=' )
                      , 1 );
        lib_proc.add ( mlinha );
        mlinha := NULL;
        mlinha :=
            lib_str.w ( mlinha
                      , 'Lote'
                      , 2 );
        mlinha :=
            lib_str.w ( mlinha
                      , 'Nº Nota'
                      , 10 );
        mlinha :=
            lib_str.w ( mlinha
                      , 'Série'
                      , 30 );
        mlinha :=
            lib_str.w ( mlinha
                      , 'Data Fiscal'
                      , 40 );
        mlinha :=
            lib_str.w ( mlinha
                      , 'Razão Social'
                      , 60 );
        mlinha :=
            lib_str.w ( mlinha
                      , 'Cód. Pin'
                      , 90 );

        lib_proc.add ( mlinha );
        mlinha := NULL;
        mlinha :=
            lib_str.w ( mlinha
                      , RPAD ( '='
                             , 100
                             , '=' )
                      , 1 );
        lib_proc.add ( mlinha );
    END;
END msaf_pin_sinal5_cproc;
/
SHOW ERRORS;
