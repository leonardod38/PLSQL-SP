Prompt Package Body COPY_DATA2_CPROC;
--
-- COPY_DATA2_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY copy_data2_cproc
IS
    mcod_empresa empresa.cod_empresa%TYPE;

    mcod_estab estabelecimento.cod_estab%TYPE;

    musuario usuario_empresa.cod_usuario%TYPE;


    PROCEDURE w ( texto VARCHAR2
                , col INTEGER )
    IS
    BEGIN
        lib_xml_arqmag.w ( texto
                         , col );
    END;

    PROCEDURE defcol ( indice INTEGER
                     , titulo VARCHAR2
                     , tamanho INTEGER
                     , formato VARCHAR2 DEFAULT 't' )
    IS
    BEGIN
        lib_xml_arqmag.defcol ( indice
                              , titulo
                              , tamanho
                              , formato );
    END;

    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );
    BEGIN
        --a implementar:


        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        mcod_estab := lib_parametros.recuperar ( 'ESTABELECIMENTO' );
        musuario := lib_parametros.recuperar ( 'USUARIO' );



        lib_proc.add_param ( pstr
                           , 'Data Inicial Origem'
                           , 'Date'
                           , 'Textbox'
                           , 'S'
                           , NULL
                           , 'DD/MM/YYYY' );
        lib_proc.add_param ( pstr
                           , 'Data Final Origem'
                           , 'Date'
                           , 'Textbox'
                           , 'S'
                           , NULL
                           , 'DD/MM/YYYY' );
        lib_proc.add_param (
                             pstr
                           , 'Movimento'
                           , 'Varchar2'
                           , 'listbox'
                           , 'S'
                           , ''
                           , ''
                           , 'M=Doc. Fiscal de Mercadoria,S=Doc. Fiscal de Serviço,E=Estoque,L=Diário Geral - Lanç. Contábeis,C=Contas a Pagar,R=Contas a Receber,I1=Invent. Class. Fiscal,I2=Invent. Produto,DU=Doc. Utilities - Telecom '
                           , 'M'
        );

        lib_proc.add_param ( pstr
                           , 'Num. Documento'
                           , 'Varchar2'
                           , 'Textbox'
                           , 'N'
                           , pmascara => '############' );

        lib_proc.add_param (
                             pstr
                           , 'Estabelecimento Origem'
                           , 'Varchar2'
                           , 'Combobox'
                           , 'S'
                           , NULL
                           , NULL
                           ,    'SELECT a.cod_estab, a.cod_estab||'' - ''||a.razao_social FROM estabelecimento a WHERE a.cod_empresa = '''
                             || mcod_empresa
                             || ''' ORDER BY a.cod_estab'
        );

        --LIB_PROC.add_param(pstr, 'Data Inicial Destino', 'Date', 'Textbox', 'S',NULL,'DD/MM/YYYY') ;
        --LIB_PROC.add_param(pstr, 'Data Final Destino', 'Date', 'Textbox', 'S',NULL,'DD/MM/YYYY') ;
        lib_proc.add_param (
                             pstr
                           , 'Mês Destino'
                           , 'Varchar2'
                           , 'listbox'
                           , 'S'
                           , ''
                           , ''
                           , '01=Janeiro,02=Fevereiro,03=Março,04=Abril,05=Maio,06=Junho,07=Julho,08=Agosto,09=Setembro,10=Outubro,11=Novembro,12=Dezembro'
                           , ''
        );

        lib_proc.add_param ( pstr
                           , 'Ano Destino'
                           , 'Varchar2'
                           , 'listbox'
                           , 'S'
                           , '2003'
                           , ''
                           , '2003=2003,2004=2004,2005=2005,2006=2006,2007=2007'
                           , '' );

        lib_proc.add_param (
                             pstr
                           , 'Empresa Destino'
                           , 'Varchar2'
                           , 'combobox'
                           , 'S'
                           , NULL
                           , NULL
                           , 'SELECT a.cod_empresa, a.cod_empresa||'' - ''||a.razao_social FROM empresa a ORDER BY a.cod_empresa'
        );


        lib_proc.add_param (
                             pstr
                           , 'Estabelecimento Destino'
                           , 'Varchar2'
                           , 'Combobox'
                           , 'S'
                           , NULL
                           , NULL
                           ,    'SELECT a.cod_estab, a.cod_estab||'' - ''||a.razao_social FROM estabelecimento a WHERE '
                             || '  a.cod_empresa = :8 ORDER BY a.cod_estab'
        );



        RETURN pstr;
    END;



    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Copy Data';
    END;

    FUNCTION tipo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Processo';
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
        RETURN 'Copia de Dados entre Empresas';
    END;

    FUNCTION modulo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN '';
    END;

    FUNCTION classificacao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Utilitarios';
    END;

    FUNCTION orientacaopapel
        RETURN VARCHAR2
    IS
    BEGIN
        -- orientação do papel
        RETURN 'landscape';
    END;

    FUNCTION executar ( pdtiniorig DATE
                      , pdtfimorig DATE
                      , ptipomiov VARCHAR2
                      , pnumdocfis VARCHAR2
                      , pcodestaborig VARCHAR2
                      , pmesdest VARCHAR2
                      , panodest VARCHAR2
                      , pcodempdest VARCHAR2
                      , pcodestabdest VARCHAR2 )
        RETURN INTEGER
    IS
        mproc_id INTEGER;

        w_query VARCHAR2 ( 5000 );
        w_query_aux VARCHAR2 ( 5000 );
        w_expressao VARCHAR2 ( 5000 );
        w_nome_coluna VARCHAR2 ( 50 );
        w_nome_coluna2 VARCHAR2 ( 50 );


        w_rownum NUMBER;

        TYPE t_reg_tabela IS TABLE OF VARCHAR2 ( 200 )
            INDEX BY BINARY_INTEGER;

        w_reg_tabela t_reg_tabela;
    BEGIN
        mcod_empresa := lib_parametros.recuperar ( 'empresa' );

        -- Cria Processo
        mproc_id :=
            lib_proc.new ( 'COPY_DATA_CPROC'
                         , 48
                         , 150 );
        lib_proc.add_tipo ( mproc_id
                          , 1
                          , 'Processo'
                          , 1 );


        IF mcod_empresa IS NULL THEN
            lib_proc.add_log ( 'código da empresa deve ser informado como parâmetro global.'
                             , 0 );
            lib_proc.close;
            RETURN mproc_id;
        END IF;


        /* IF PDTINIORIG <'01/06/2003' AND PDTFIMORIG <'01/06/2003'  THEN
        LIB_PROC.ADD_LOG('Periodo Invalido - Grupo Estabelecimento deve ser respeitado.',
               0);
        LIB_PROC.CLOSE;
        RETURN MPROC_ID;
       END IF;*/

        IF pdtiniorig < '01/06/2003'
       AND pdtfimorig >= '01/06/2003' THEN
            lib_proc.add_log ( 'Periodo Invalido - Grupo Estabelecimento deve ser respeitado.'
                             , 0 );
            lib_proc.close;
            RETURN mproc_id;
        END IF;



        IF pdtiniorig < '01/06/2003'
       AND ( pmesdest > '06'
        AND panodest > '2003' ) THEN
            lib_proc.add_log ( 'Periodo Invalido - Grupo Estabelecimento deve ser respeitado.'
                             , 0 );
            lib_proc.close;
            RETURN mproc_id;
        END IF;


        ------------------------------------------------------------------------------
        -- ALIMENTA VETOR DE TABELAS
        -----------------------------------------------------------------------------
        IF ptipomiov = 'M' THEN
            w_reg_tabela ( 1 ) := 'X07_DOCTO_FISCAL';
            w_reg_tabela ( 2 ) := 'X07_TRIB_DOCFIS';
            w_reg_tabela ( 3 ) := 'X07_BASE_DOCFIS';
            w_reg_tabela ( 4 ) := 'X07_CUPOM_FISCAL';
            w_reg_tabela ( 5 ) := 'X08_ITENS_MERC';
            w_reg_tabela ( 6 ) := 'X08_TRIB_MERC';
            w_reg_tabela ( 7 ) := 'X08_BASE_MERC';
            w_nome_coluna := 'DATA_FISCAL';
            w_nome_coluna2 := 'NUM_DOCFIS';
        ELSIF ptipomiov = 'S' THEN
            w_reg_tabela ( 1 ) := 'X07_DOCTO_FISCAL';
            w_reg_tabela ( 2 ) := 'X07_TRIB_DOCFIS';
            w_reg_tabela ( 3 ) := 'X07_BASE_DOCFIS';
            w_reg_tabela ( 4 ) := 'X07_CUPOM_FISCAL';
            w_reg_tabela ( 5 ) := 'X09_ITENS_SERV';
            w_reg_tabela ( 6 ) := 'X09_TRIB_SERV';
            w_reg_tabela ( 7 ) := 'X09_BASE_SERV';
            w_nome_coluna := 'DATA_FISCAL';
            w_nome_coluna2 := 'NUM_DOCFIS';
        ELSIF ptipomiov = 'E' THEN
            w_reg_tabela ( 1 ) := 'X10_ESTOQUE';
            w_nome_coluna := 'DATA_MOVTO';
            w_nome_coluna2 := 'NUM_DOCTO';
        ELSIF ptipomiov = 'C' THEN
            w_reg_tabela ( 1 ) := 'X03_TIT_PAGAR';
            w_nome_coluna := 'DATA_MOVTO';
            w_nome_coluna2 := 'NUM_DOCFIS';
        ELSIF ptipomiov = 'R' THEN
            w_reg_tabela ( 1 ) := 'X05_TIT_RECEBER';
            w_nome_coluna := 'DATA_MOVTO';
            w_nome_coluna2 := 'NUM_DOCFIS';
        ELSIF ptipomiov = 'L' THEN
            w_reg_tabela ( 1 ) := 'X01_CONTABIL'; -- DIARIO GERAL - LANC. CONTABEIS
            w_nome_coluna := 'DATA_LANCTO';
        ELSIF ptipomiov = 'I1' THEN -- INVENTARIO POR CLASS. FISCAL
            w_reg_tabela ( 1 ) := 'X62_INVENTARIO_NBM';
            w_nome_coluna := 'DATA_INVENTARIO';
        ELSIF ptipomiov = 'I2' THEN -- INVENTARIO POR PRODUTO
            w_reg_tabela ( 1 ) := 'X52_INVENT_PRODUTO';
            w_nome_coluna := 'DATA_INVENTARIO';
        ELSIF ptipomiov = 'DU' THEN -- DOC. TELECOM
            w_reg_tabela ( 1 ) := 'X42_CAPA_TELECOM';
            w_reg_tabela ( 2 ) := 'X43_ITEM_TELECOM';
            w_nome_coluna := 'DAT_FISCAL';
            w_nome_coluna2 := 'NUM_DOCFIS';
        END IF;


        FOR i IN 1 .. w_reg_tabela.COUNT ( ) LOOP
            ------------------------------------------------------------------------------
            -- SELECAO DE REGISTROS PARA COPIA
            ------------------------------------------------------------------------------

            w_query := 'SELECT ';

            ---------------------------------------------------------------------------------
            -- MONTA COLUNAS DO SELECT  --
            ---------------------------------------------------------------------------------

            FOR c1 IN ( SELECT   all_tab_columns.column_name
                            FROM all_tab_columns
                           WHERE all_tab_columns.table_name = w_reg_tabela ( i )
                             AND all_tab_columns.owner = 'VALID_REQ'
                        ORDER BY column_id ) LOOP
                IF c1.column_name = 'COD_EMPRESA' THEN
                    w_query := w_query || '''' || pcodempdest || ''' , ';
                ELSIF c1.column_name = 'COD_ESTAB' THEN
                    w_query := w_query || '''' || pcodestabdest || ''' , ';
                ELSIF c1.column_name IN ( 'DATA_FISCAL'
                                        , 'DATA_MOVTO'
                                        , 'DATA_LANCTO'
                                        , 'DATA_INVENTARIO'
                                        , 'DATA_EMISSAO'
                                        , 'DATA_SAIDA_REC'
                                        , 'DATA_VENCTO' ) THEN
                    IF pmesdest IN ( '04'
                                   , '06'
                                   , '09'
                                   , '11' ) THEN
                        w_expressao :=
                               'TO_DATE( DECODE(SUBSTR('
                            || c1.column_name
                            || ',1,2 ),31,30, SUBSTR('
                            || c1.column_name
                            || ',1,2 )) || '''
                            || pmesdest
                            || panodest
                            || ''')';
                    --   lib_proc.add_log(c1.COLUMN_NAME ||'-'|| W_EXPRESSAO,2) ;
                    ELSIF pmesdest = '02' THEN
                        w_expressao :=
                               'TO_DATE( DECODE(SUBSTR('
                            || c1.column_name
                            || ',1,2 ),29,28,30,28,31,28,SUBSTR('
                            || c1.column_name
                            || ',1,2 )) || '''
                            || pmesdest
                            || panodest
                            || ''')';
                    --  lib_proc.add_log(c1.COLUMN_NAME ||'-'|| W_EXPRESSAO,2) ;
                    ELSE
                        w_expressao :=
                            'TO_DATE( SUBSTR(' || c1.column_name || ',1,2 ) || ''' || pmesdest || panodest || ''')';
                    --  lib_proc.add_log(c1.COLUMN_NAME ||'-'|| W_EXPRESSAO,2) ;
                    END IF;



                    w_query := w_query || w_expressao || ' , ';
                -- bloco nao utilçizado para parametro de entrada mes/ano
                -- se for utilizado datra inicial e data final bloco deve ser usado para
                -- distribuicao de registros dentro do periodo

                /*ELSE
                   W_DATA := PDTINIDEST ;

                   -- EXPRESSAO DO DECODE --
                   W_EXPRESSAO:= ' DECODE(ROWNUM ,' ;

                   FOR I IN 1..W_ROWNUM LOOP
                     W_EXPRESSAO := W_EXPRESSAO || TO_CHAR (I) ||','''|| W_DATA ||''',' ;
                     IF W_DATA < PDTFIMDEST THEN
                       W_DATA := W_DATA + 1;
                     ELSIF W_DATA = PDTFIMDEST THEN
                       W_DATA := PDTINIDEST ;
                     END IF ;
                   END LOOP ;

                   -- RETIRA A ULTIMA VIRGULA --
                   W_EXPRESSAO := SUBSTR(W_EXPRESSAO , 1 , LENGTH(W_EXPRESSAO) - 1 ) ;
                   -- INSERE PARENTESSIS --
                   W_EXPRESSAO := W_EXPRESSAO || ' ) ' ;

                   -- INSERE EXPRESSAO DO DECODE NA QUERY  --
                   W_QUERY := W_QUERY || W_EXPRESSAO ||' , ' ;*\

                END IF ;
             */
                ELSE
                    w_query := w_query || c1.column_name || ' , ';
                END IF;
            END LOOP;



            -- RETIRA A ULTIMA VIRGULA --
            w_query :=
                SUBSTR ( w_query
                       , 1
                       , LENGTH ( w_query ) - 2 );

            w_query := 'INSERT INTO ' || w_reg_tabela ( i ) || ' (' || w_query;

            w_query_aux :=
                   'FROM '
                || w_reg_tabela ( i )
                || ' WHERE COD_EMPRESA = '''
                || mcod_empresa
                || ''' AND  COD_ESTAB = '''
                || pcodestaborig;


            IF NVL ( TRIM ( pnumdocfis ), 'X' ) <> 'X'
           AND ptipomiov IN ( 'M'
                            , 'S'
                            , 'E'
                            , 'C'
                            , 'R'
                            , 'DU' ) THEN
                w_query_aux := w_query_aux || ''' AND ' || w_nome_coluna2 || ' = ''' || pnumdocfis;
            ELSIF NVL ( TRIM ( pnumdocfis ), 'X' ) <> 'X'
              AND ptipomiov IN ( 'I1'
                               , 'I2'
                               , 'L' ) THEN
                lib_proc.add_log (
                                      'Esta Opção de Movimento não pode fazer filtro por Numero de Documento - Todos os Registros do Período foram selecionados. '
                                   || TO_CHAR ( SYSDATE
                                              , 'DD/MM/YYYY HH24:MI:SS' )
                                 , 2
                );
            END IF;


            w_query_aux :=
                   w_query_aux
                || ''' AND '
                || w_nome_coluna
                || ' BETWEEN '''
                || pdtiniorig
                || ''' AND '''
                || pdtfimorig
                || ''')';


            ------------------------------------------------------------------------------
            -- PROCESSA O INSERT DO REGISTRO PARA CADA TABELA
            ------------------------------------------------------------------------------

            BEGIN
                w_rownum :=
                    count_reg ( w_reg_tabela ( i )
                              , mcod_empresa
                              , pcodestaborig
                              , ptipomiov
                              , pnumdocfis
                              , w_nome_coluna
                              , w_nome_coluna2
                              , pdtiniorig
                              , pdtfimorig );

                EXECUTE IMMEDIATE ( w_query || w_query_aux );

                COMMIT;

                IF SQL%NOTFOUND THEN
                    lib_proc.add_log (
                                          'Não Existem Registros para Cópia com os Parâmetros Informados - '
                                       || w_reg_tabela ( i )
                                       || ' - '
                                       || SQLERRM
                                     , 2
                    );
                    lib_proc.add_log ( ' '
                                     , 2 );
                END IF;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    lib_proc.add_log (
                                          'Não Existem Registros para Cópia com os Parâmetros Informados - '
                                       || w_reg_tabela ( i )
                                       || ' - '
                                       || SQLERRM
                                     , 2
                    );
                    lib_proc.add_log ( ' '
                                     , 2 );
                WHEN DUP_VAL_ON_INDEX THEN
                    lib_proc.add_log (    'Processo de Copia dos Registros Finalizado com Avisos: '
                                       || TO_CHAR ( SYSDATE
                                                  , 'DD/MM/YYYY HH24:MI:SS' )
                                     , 2 );
                    lib_proc.add_log (
                                          'Registro não foi Copiado, Duplicação de Chaves Primarias '
                                       || w_reg_tabela ( i )
                                       || ' - '
                                       || SQLERRM
                                     , 2
                    );
                    lib_proc.add_log ( ' '
                                     , 2 );
                WHEN OTHERS THEN
                    lib_proc.add_log (    'Processo de Copia dos Registros Finalizado com Erros: '
                                       || TO_CHAR ( SYSDATE
                                                  , 'DD/MM/YYYY HH24:MI:SS' )
                                     , 2 );
                    lib_proc.add_log ( 'Erro na Copia dos Registros - ' || w_reg_tabela ( i ) || ' - ' || SQLERRM
                                     , 2 );
                    lib_proc.add_log ( ' '
                                     , 2 );
            END;
        END LOOP;


        lib_proc.add_log (    'Termino da Geração de Copia dos Registros: '
                           || w_rownum
                           || ' Registros Processados - '
                           || TO_CHAR ( SYSDATE
                                      , 'DD/MM/YYYY HH24:MI:SS' )
                         , 2 );


        --fecho o processo
        lib_proc.close;

        COMMIT;
        RETURN mproc_id;
    EXCEPTION
        WHEN OTHERS THEN
            lib_proc.add_log ( 'Erro não tratado: ' || SQLERRM
                             , 1 );
            lib_proc.close;
            COMMIT;
            RETURN mproc_id;
    END;

    ----------------------------------------------------
    --  FUNÇÃO PARA CONTAGEM DOS REGISTROS
    ----------------------------------------------------

    FUNCTION count_reg ( p_tabela VARCHAR2
                       , p_cod_empresa VARCHAR2
                       , p_cod_estab VARCHAR2
                       , p_tp_mov VARCHAR2
                       , p_num_docfis VARCHAR2
                       , p_nome_col VARCHAR2
                       , p_nome_col2 VARCHAR2
                       , p_dt_iniorig DATE
                       , p_dt_fimorig DATE )
        RETURN NUMBER
    IS
        w_query_count VARCHAR2 ( 1000 );
        w_count NUMBER;
    BEGIN
        w_query_count :=
               'SELECT COUNT(*) FROM '
            || p_tabela
            || ' WHERE COD_EMPRESA = '''
            || p_cod_empresa
            || ''' AND  COD_ESTAB = '''
            || p_cod_estab;

        IF NVL ( TRIM ( p_num_docfis ), 'X' ) <> 'X'
       AND p_tp_mov IN ( 'M'
                       , 'S'
                       , 'E'
                       , 'C'
                       , 'R'
                       , 'DU' ) THEN
            w_query_count := w_query_count || ''' AND ' || p_nome_col2 || ' = ''' || p_num_docfis;
        END IF;

        w_query_count :=
               w_query_count
            || ''' AND '
            || p_nome_col
            || ' BETWEEN '''
            || p_dt_iniorig
            || ''' AND '''
            || p_dt_fimorig
            || '''';


        EXECUTE IMMEDIATE w_query_count            INTO w_count;

        RETURN w_count;
    END;



    PROCEDURE teste
    IS
        mproc_id INTEGER;
    BEGIN
        lib_parametros.salvar ( 'empresa'
                              , '076' );
        mproc_id :=
            executar ( '28/01/2003'
                     , '28/01/2003'
                     , 'M'
                     , '000319'
                     , '01'
                     , '01'
                     , '2003'
                     , '002'
                     , 'SP002' );
        lib_proc.list_output ( mproc_id
                             , 1 );
        dbms_output.put_line ( '' );
        dbms_output.put_line ( '---arquivo magnetico----' );
        dbms_output.put_line ( '' );
        lib_proc.list_output ( mproc_id
                             , 2 );
    END;
END;
/
SHOW ERRORS;
