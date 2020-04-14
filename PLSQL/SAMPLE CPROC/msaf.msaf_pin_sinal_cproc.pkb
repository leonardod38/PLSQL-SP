Prompt Package Body MSAF_PIN_SINAL_CPROC;
--
-- MSAF_PIN_SINAL_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY msaf_pin_sinal_cproc
IS
    ---------------------------------------------------------------------------------------------------------
    -- Autor         : Valdir Stropa - DW Consulting - MasterSaf
    -- Created       : 09/04/2008
    -- Purpose       : Geracao das informacoes para compor o xml Pin-Sinal
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

        lib_proc.add_param ( pstr
                           , 'Tipo de Documento Fiscal'
                           , 'VARCHAR2'
                           , 'listbox'
                           , 'S'
                           , 'A'
                           , NULL
                           , 'E=E - Nota Fiscal Eletronica ,C=C - Nota Fiscal Convencional ,A=A - Ambas' );

        lib_proc.add_param ( pstr
                           , 'Data Inicial'
                           , 'Date'
                           , 'Textbox'
                           , 'S'
                           , NULL
                           , 'dd/mm/yyyy' );

        lib_proc.add_param ( pstr
                           , 'Data Final'
                           , 'Date'
                           , 'Textbox'
                           , 'S'
                           , NULL
                           , 'dd/mm/yyyy' );


        lib_proc.add_param (
                             pstr
                           , 'UF'
                           , 'Varchar2'
                           , 'MULTISELECT'
                           , 'S'
                           , NULL
                           , NULL
                           ,    'Select distinct cod_estado, cod_estado||'' - ''||descricao '
                             || 'from estado where cod_estado in(''AC'',''AP'',''AM'',''RO'',''RR'')'
        );

        lib_proc.add_param (
                             pstr
                           , 'Estabelecimento'
                           , 'Varchar2'
                           , 'COMBOBOX'
                           , 'S'
                           , NULL
                           , NULL
                           ,    'select ''0'',''Todos os Estabelecimentos'' from dual union Select distinct cod_estab, cod_estab||'' - ''||razao_social '
                             || 'from estabelecimento where cod_empresa = '''
                             || mcod_empresa
                             || ''''
        );

        RETURN pstr;
    END;

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN '1 - Geracao Pin - Sinal';
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
        RETURN 'Geracao de Registros';
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

    FUNCTION executar ( ptipo_docto VARCHAR2
                      , pdata_ini DATE
                      , pdata_fim DATE
                      , puf lib_proc.vartab
                      , pestab VARCHAR2 )
        RETURN INTEGER
    IS
        /* Variaveis de Trabalho */
        v_limpa_tab VARCHAR2 ( 1 );
        v_status_rec VARCHAR2 ( 1 );
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
            lib_proc.new ( 'MSAF_PIN_SINAL_CPROC'
                         , 48
                         , 160 );

        lib_proc.add_tipo ( mproc_id
                          , 1
                          , 'Relatório Pin - Sinal '
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
            BEGIN
                --Busca os estabelecimentos
                FOR c2 IN ( SELECT e.cod_estab
                              FROM estabelecimento e
                             WHERE e.cod_empresa = mcod_empresa
                               AND ( pestab = '0'
                                 OR e.cod_estab = pestab ) ) LOOP
                    v_estab := c2.cod_estab;
                    v_uf := '';
                    --Busca as UF's
                    i := puf.FIRST;

                    WHILE i IS NOT NULL LOOP
                        v_uf := puf ( i );
                        --chama a procedure de geracao para a uf
                        saf_pin_sinal ( mcod_empresa
                                      , ptipo_docto
                                      , TO_CHAR ( pdata_ini
                                                , 'dd/mm/yyyy' )
                                      , TO_CHAR ( pdata_fim
                                                , 'dd/mm/yyyy' )
                                      , pestab
                                      , v_uf
                                      , v_status );
                        i := puf.NEXT ( i );
                    END LOOP;
                END LOOP;

                --Cabecalho - criar rotina para chamada do cabecalho no corpo do relatorio
                mlinha :=
                    lib_str.w ( ''
                              , ' '
                              , 1 );
                mlinha :=
                    lib_str.w ( mlinha
                              , 'EMPRESA'
                              , 2 );
                mlinha :=
                    lib_str.w ( mlinha
                              , 'ESTAB.'
                              , 10 );
                mlinha :=
                    lib_str.w ( mlinha
                              , 'DATA'
                              , 18 );
                mlinha :=
                    lib_str.w ( mlinha
                              , 'DOCTO'
                              , 33 );
                mlinha :=
                    lib_str.w ( mlinha
                              , 'SERIE'
                              , 45 );
                mlinha :=
                    lib_str.w ( mlinha
                              , 'LOTE'
                              , 52 );
                mlinha :=
                    lib_str.w ( mlinha
                              , 'CLIENTE'
                              , 63 );
                mlinha :=
                    lib_str.w ( mlinha
                              , 'RAZAO SOCIAL'
                              , 75 );
                lib_proc.add ( mlinha );

                mlinha :=
                    lib_str.w ( ''
                              , ' '
                              , 1 );
                mlinha :=
                    lib_str.w ( mlinha
                              , LPAD ( '='
                                     , 110
                                     , '=' )
                              , 1 );
                lib_proc.add ( mlinha );

                --Gera o relatorio
                --Busca os estabelecimentos
                FOR c2 IN ( SELECT e.cod_estab
                              FROM estabelecimento e
                             WHERE e.cod_empresa = mcod_empresa
                               AND ( pestab = '0'
                                 OR e.cod_estab = pestab ) ) LOOP
                    v_estab := c2.cod_estab;
                    v_uf := '';

                    --Monta o relatorio das nf selecionadas
                    FOR c3 IN ( SELECT   t.cod_empresa
                                       , t.cod_estab
                                       , t.data_fiscal
                                       , t.num_docfis
                                       , t.serie_docfis
                                       , t.status
                                       , t.num_lote
                                       , p.cod_fis_jur
                                       , SUBSTR ( p.razao_social
                                                , 1
                                                , 25 )
                                             nome
                                    FROM tb_msaf_nf_lote t
                                       , x04_pessoa_fis_jur p
                                   WHERE t.ident_fis_jur = p.ident_fis_jur
                                     AND t.cod_empresa = mcod_empresa
                                     AND t.cod_estab = v_estab
                                     AND t.data_fiscal BETWEEN TO_CHAR ( pdata_ini
                                                                       , 'dd/mm/yyyy' )
                                                           AND TO_CHAR ( pdata_fim
                                                                       , 'dd/mm/yyyy' )
                                     AND ( ptipo_docto = 'A'
                                       OR t.tipo_nota = ptipo_docto )
                                GROUP BY t.cod_empresa
                                       , t.cod_estab
                                       , t.data_fiscal
                                       , t.num_docfis
                                       , t.serie_docfis
                                       , t.status
                                       , t.num_lote
                                       , p.cod_fis_jur
                                       , p.razao_social ) LOOP
                        mlinha :=
                            lib_str.w ( ''
                                      , ' '
                                      , 1 );
                        mlinha :=
                            lib_str.w ( mlinha
                                      , c3.cod_empresa
                                      , 2 );
                        mlinha :=
                            lib_str.w ( mlinha
                                      , c3.cod_estab
                                      , 10 );
                        mlinha :=
                            lib_str.w ( mlinha
                                      , c3.data_fiscal
                                      , 18 );
                        mlinha :=
                            lib_str.w ( mlinha
                                      , c3.num_docfis
                                      , 33 );
                        mlinha :=
                            lib_str.w ( mlinha
                                      , c3.serie_docfis
                                      , 45 );
                        mlinha :=
                            lib_str.w ( mlinha
                                      , c3.num_lote
                                      , 50 );
                        mlinha :=
                            lib_str.w ( mlinha
                                      , c3.cod_fis_jur
                                      , 63 );
                        mlinha :=
                            lib_str.w ( mlinha
                                      , c3.nome
                                      , 75 );
                        lib_proc.add ( mlinha );


                        v_status_rec := c3.status;
                    END LOOP;
                END LOOP;

                IF v_status_rec = 'C' THEN
                    lib_proc.add_log (
                                       '----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------'
                                     , 0
                    );
                    lib_proc.add_log ( 'ATENÇÃO: Já foram gerados arquivos de LOTES para as notas deste período!
                                 Para associar essas Notas para um novo LOTE, marcar a opção "Limpar Lotes Gerados"'
                                     , 5 );
                    lib_proc.add_log (
                                       '----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------'
                                     , 0
                    );
                ELSE
                    lib_proc.add_log (
                                       '----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------'
                                     , 0
                    );
                    lib_proc.add_log ( 'Geração de Dados Finalizada com sucesso '
                                     , 5 );
                    lib_proc.add_log (
                                       '----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------'
                                     , 0
                    );
                    lib_proc.add_log (    'FINAL DO PROCESSO:  '
                                       || TO_CHAR ( SYSDATE
                                                  , 'DD/MM/YYYY HH24:MI:SS' )
                                     , 1 );
                END IF;
            END;
        END;

        lib_proc.close ( );

        RETURN mproc_id;
    END;
---

END msaf_pin_sinal_cproc;
/
SHOW ERRORS;
