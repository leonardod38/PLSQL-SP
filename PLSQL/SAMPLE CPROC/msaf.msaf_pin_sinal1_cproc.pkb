Prompt Package Body MSAF_PIN_SINAL1_CPROC;
--
-- MSAF_PIN_SINAL1_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY msaf_pin_sinal1_cproc
IS
    ---------------------------------------------------------------------------------------------------------
    -- Autor         : Valdir Stropa - DW Consulting - MasterSaf
    -- Created       : 10/04/2008
    -- Purpose       : Manutencao Pin-Sinal. Permite ao usuario efetuar manutencao
    --                 das NF que devem compor os lotes.
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
                           , 'Pesquisa por Nota'
                           , 'Varchar2'
                           , 'Textbox'
                           , 'S'
                           , '%'
                           , NULL
                           , NULL );

        lib_proc.add_param ( pstr
                           , 'Pesquisa por Lote'
                           , 'Varchar2'
                           , 'Combobox'
                           , 'S'
                           , NULL
                           , NULL
                           , 'select distinct num_lote, num_lote from TB_MSAF_NF_LOTE where num_docfis like :1' );

        lib_proc.add_param (
                             pstr
                           , 'Marcar os documentos que NÃO serão considerados no LOTE:'
                           , 'Varchar2'
                           , 'MULTISELECT'
                           , 'S'
                           , 'S'
                           , NULL
                           , 'Select num_docfis, num_docfis || '' '' || data_fiscal || '' lote - '' || num_lote from TB_MSAF_NF_LOTE WHERE num_lote = :2 '
        );
        RETURN pstr;
    END;

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN '2 - Manutencao de Lote Pin - Sinal';
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
        RETURN 'Manutencao de Lote';
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

    FUNCTION executar ( pnf VARCHAR2
                      , plote VARCHAR2
                      , pnnota lib_proc.vartab )
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
            lib_proc.new ( 'MSAF_PIN_SINAL1_CPROC'
                         , 48
                         , 160 );

        lib_proc.add_tipo ( mproc_id
                          , 1
                          , 'Manutencao Lote Pin - Sinal '
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
                i := pnnota.FIRST;

                --Verifica o numero do lote
                BEGIN
                    SELECT DISTINCT r.num_lote
                      INTO v_lote
                      FROM tb_msaf_nf_lote r
                     WHERE r.cod_empresa = mcod_empresa
                       AND plote IN ( SELECT DISTINCT num_lote
                                        FROM tb_msaf_nf_lote
                                       WHERE status != 'P'
                                     UNION
                                     SELECT DISTINCT num_docfis
                                       FROM tb_msaf_nf_lote
                                      WHERE status != 'P' )
                       AND ROWNUM = 1;
                EXCEPTION
                    WHEN OTHERS THEN
                        NULL;
                END;

                /*          WHILE i IS not NULL LOOP
                               v_nota := PNNOTA(i);
                               --Atualiza os registros selecionados
                               begin
                                    update TB_MSAF_NF_LOTE g
                                    set g.status = '1'
                                    where g.num_docfis = v_nota
                                    and   g.num_lote   = v_lote;
                               exception when others then
                                    null;
                               end;
                               i := PNNOTA.NEXT(i);
                          END LOOP;
                */

                WHILE i IS NOT NULL LOOP
                    v_nota := pnnota ( i );

                    --Atualiza os registros selecionados
                    BEGIN
                        DELETE FROM tb_msaf_nf_lote h
                              WHERE h.num_docfis = v_nota
                                AND h.num_lote = v_lote;
                    EXCEPTION
                        WHEN OTHERS THEN
                            NULL;
                    END;

                    i := pnnota.NEXT ( i );
                END LOOP;

                COMMIT;

                /*          --Efetua a exclusao dos registros nao selecionados
                          begin
                               delete from TB_MSAF_NF_LOTE h
                               where (h.status != '1' or trim(h.status) is null)
                               and h.num_lote = v_lote;
                          exception when others then
                               null;
                          end;
                          commit;
                */
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
                --Monta o relatorio das nf selecionadas
                FOR c3 IN ( SELECT t.cod_empresa
                                 , t.cod_estab
                                 , t.data_fiscal
                                 , t.num_docfis
                                 , t.serie_docfis
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
                               AND t.num_lote = v_lote
                               --               and   (t.status != '1' OR t.status IS NULL)
                               AND ( t.status = 'G'
                                 OR t.status IS NULL ) ) LOOP
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

END msaf_pin_sinal1_cproc;
/
SHOW ERRORS;
