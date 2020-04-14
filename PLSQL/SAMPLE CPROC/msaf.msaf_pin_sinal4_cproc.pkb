Prompt Package Body MSAF_PIN_SINAL4_CPROC;
--
-- MSAF_PIN_SINAL4_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY msaf_pin_sinal4_cproc
IS
    ---------------------------------------------------------------------------------------------------------
    -- Autor         : Valdir Stropa - DW Consulting - MasterSaf
    -- Created       : 11/04/2008
    -- Purpose       : Controle do Pin-Sinal. Permite ao usuario efetuar manutencao
    --                 dos codigos PIN para cada um dos lotes.
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
        mcod_estab := NVL ( lib_parametros.recuperar ( 'ESTABELECIMENTO' ), '' );
        musuario := lib_parametros.recuperar ( 'Usuario' );

        /*    LIB_PROC.add_param(pstr, 'Pesquisar Lote', 'Varchar2', 'Textbox', 'S', NULL, null,
                                     null);
        */
        lib_proc.add_param ( pstr
                           , 'Pesquisa por Lote'
                           , 'Varchar2'
                           , 'Textbox'
                           , 'S'
                           , NULL
                           , NULL
                           , 'select distinct num_lote, num_lote from TB_MSAF_LOTE' );
        lib_proc.add_param ( pstr
                           , 'Código PIN'
                           , 'Varchar2'
                           , 'Textbox'
                           , 'N'
                           , NULL
                           , NULL
                           , NULL );

        lib_proc.add_param (
                             pstr
                           , 'Documentos do Lote:'
                           , 'Varchar2'
                           , 'MULTISELECT'
                           , 'S'
                           , 'S'
                           , NULL
                           , 'Select num_docfis, num_docfis from TB_MSAF_NF_LOTE WHERE num_lote = :1 and cod_pin is null'
        );


        RETURN pstr;
    END;

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN '4 - Controle de Lote Pin - Sinal';
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
        RETURN 'Controle de Lote/PIN';
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

    FUNCTION executar ( plotee VARCHAR2
                      , ppin VARCHAR2
                      , pnf lib_proc.vartab )
        RETURN INTEGER
    IS
        /* Variaveis de Trabalho */
        mproc_id INTEGER;
        mlinha VARCHAR2 ( 160 );
        v_linha NUMBER := 0;
        v_folha NUMBER := 0;

        v_conta NUMBER := 0;
        v_tot_deb NUMBER := 0;
        v_tot_cre NUMBER := 0;
        v_cod_div VARCHAR2 ( 10 ) := '';

        i INTEGER;
    BEGIN
        -- Cria Processo
        mproc_id :=
            lib_proc.new ( 'MSAF_PIN_SINAL4_CPROC'
                         , 48
                         , 160 );

        lib_proc.add_tipo ( mproc_id
                          , 1
                          , 'Controle Lote Pin - Sinal '
                          , 1 ); --2 arquivo

        DECLARE
        BEGIN
            DECLARE
                v_razao VARCHAR2 ( 50 ) := '';
                v_cnpj VARCHAR2 ( 20 ) := '';
                v_insc VARCHAR2 ( 20 ) := '';
                v_chave VARCHAR2 ( 40 ) := '';
                v_estab VARCHAR2 ( 200 ) := '';
                v_uf VARCHAR2 ( 2 ) := '';
                v_status INTEGER := 0;
                v_nota VARCHAR2 ( 20 ) := '';
                v_lote VARCHAR2 ( 20 ) := '';
            BEGIN
                FOR cnf IN pnf.FIRST .. pnf.LAST LOOP
                    --Efetua a gravação do PIN para o lote selecionado
                    IF TRIM ( plotee ) IS NOT NULL
                   AND TRIM ( ppin ) IS NOT NULL THEN
                        BEGIN
                            UPDATE tb_msaf_lote a
                               SET a.cod_pin = ppin
                             WHERE a.num_lote = plotee;

                            UPDATE tb_msaf_nf_lote a
                               SET a.cod_pin = ppin
                             WHERE a.num_lote = plotee
                               AND a.num_docfis = pnf ( cnf );


                            mlinha :=
                                lib_str.w ( ''
                                          , ' '
                                          , 1 );
                            mlinha :=
                                lib_str.w ( mlinha
                                          , 'CONTROLE DE LOTE/PIN'
                                          , 10 );
                            lib_proc.add ( mlinha );
                            mlinha :=
                                lib_str.w ( ''
                                          , ' '
                                          , 1 );
                            lib_proc.add ( mlinha );
                            mlinha :=
                                lib_str.w ( mlinha
                                          , 'LOTE                     PIN'
                                          , 10 );
                            lib_proc.add ( mlinha );
                            mlinha :=
                                lib_str.w ( mlinha
                                          , '============================================'
                                          , 10 );
                            lib_proc.add ( mlinha );
                            mlinha :=
                                lib_str.w ( mlinha
                                          , plotee || '           ' || ppin
                                          , 10 );
                            lib_proc.add ( mlinha );
                            mlinha :=
                                lib_str.w ( mlinha
                                          , '============================================'
                                          , 10 );
                            lib_proc.add ( mlinha );
                            mlinha :=
                                lib_str.w ( ''
                                          , ' '
                                          , 1 );
                            lib_proc.add ( mlinha );
                            mlinha :=
                                lib_str.w ( ''
                                          , ' '
                                          , 1 );
                            lib_proc.add ( mlinha );
                            mlinha :=
                                lib_str.w ( mlinha
                                          , 'Atribuido o codigo PIN ao lote'
                                          , 10 );
                            lib_proc.add ( mlinha );
                        EXCEPTION
                            WHEN OTHERS THEN
                                NULL;
                        END;

                        COMMIT;
                    ELSE
                        mlinha :=
                            lib_str.w ( ''
                                      , ' '
                                      , 1 );
                        mlinha :=
                            lib_str.w ( mlinha
                                      , 'CONTROLE DE LOTE/PIN'
                                      , 10 );
                        lib_proc.add ( mlinha );
                        mlinha :=
                            lib_str.w ( ''
                                      , ' '
                                      , 1 );
                        lib_proc.add ( mlinha );
                        mlinha :=
                            lib_str.w ( mlinha
                                      , 'LOTE                     PIN'
                                      , 10 );
                        lib_proc.add ( mlinha );
                        mlinha :=
                            lib_str.w ( mlinha
                                      , '============================================'
                                      , 10 );
                        lib_proc.add ( mlinha );
                        mlinha :=
                            lib_str.w ( mlinha
                                      , plotee || '           ' || ppin
                                      , 10 );
                        lib_proc.add ( mlinha );
                        mlinha :=
                            lib_str.w ( mlinha
                                      , '============================================'
                                      , 10 );
                        lib_proc.add ( mlinha );
                        mlinha :=
                            lib_str.w ( ''
                                      , ' '
                                      , 1 );
                        lib_proc.add ( mlinha );
                        mlinha :=
                            lib_str.w ( ''
                                      , ' '
                                      , 1 );
                        lib_proc.add ( mlinha );
                        mlinha :=
                            lib_str.w ( mlinha
                                      , 'Nao foi atribuido o codigo PIN ao lote'
                                      , 10 );
                        lib_proc.add ( mlinha );
                    END IF;
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

END msaf_pin_sinal4_cproc;
/
SHOW ERRORS;
