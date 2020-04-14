Prompt Package Body DSP_RELAT_P9_CPROC;
--
-- DSP_RELAT_P9_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dsp_relat_p9_cproc
IS
    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    -- AJ0001 - ADICIONAR DC AOS ESTABELECIEMNTOS              2017-07-21
    -- Rodolfo S Carvalhal
    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    mproc_id INTEGER;
    mcod_empresa empresa.cod_empresa%TYPE;

    FUNCTION parametros
        RETURN VARCHAR2
    IS
        v_tela VARCHAR2 ( 4000 );
    BEGIN
        lib_proc.add_param ( pparam => v_tela
                           , ptitulo => '                                _____________________________'
                           , ptipo => 'Text' );
        lib_proc.add_param ( pparam => v_tela
                           , ptitulo => ' '
                           , ptipo => 'Text' );

        lib_proc.add_param ( pparam => v_tela
                           , ptitulo => '                                Periodo'
                           , ptipo => 'Text' );

        lib_proc.add_param ( pparam => v_tela
                           , ptitulo => '(*) Inicio'
                           , ptipo => 'DATE'
                           , pcontrole => 'TEXTBOX'
                           , pmandatorio => 'S'
                           , pdefault => TRUNC ( ADD_MONTHS ( SYSDATE
                                                            , -1 )
                                               , 'month' )
                           , pmascara => 'mm/yyyy' );

        lib_proc.add_param ( pparam => v_tela
                           , ptitulo => 'Fim'
                           , ptipo => 'DATE'
                           , pcontrole => 'TEXTBOX'
                           , pmandatorio => 'N'
                           , pdefault => NULL
                           , pmascara => 'mm/yyyy' );

        lib_proc.add_param ( pparam => v_tela
                           , ptitulo => '                                _____________________________'
                           , ptipo => 'Text' );
        lib_proc.add_param ( pparam => v_tela
                           , ptitulo => ' '
                           , ptipo => 'Text' );
        lib_proc.add_param ( pparam => v_tela
                           , ptitulo => ' '
                           , ptipo => 'Text' );
        lib_proc.add_param ( pparam => v_tela
                           , ptitulo => ' '
                           , ptipo => 'Text' );

        lib_proc.add_param ( pparam => v_tela
                           , ptitulo => '______________________________________________________'
                           , ptipo => 'Text' );

        lib_proc.add_param ( pparam => v_tela
                           , ptitulo => '(*) Obrigatório'
                           , ptipo => 'Text' );
        lib_proc.add_param (
                             pparam => v_tela
                           , ptitulo => 'Estabelecimentos'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'MULTISELECT'
                           , pmandatorio => 'S'
                           , pvalores =>    'SELECT A.COD_ESTAB,A.COD_ESTAB || '' - '' || B.COD_ESTADO || '' - '' || A.CGC'
                                         || ' || '' - '' || INITCAP(A.BAIRRO) || '' / '' || INITCAP(A.CIDADE)'
                                         || -- ' FROM ESTABELECIMENTO A, ESTADO B, MSAFI.DSP_ESTABELECIMENTO C' || -- AJ0001
                                            ' FROM ESTABELECIMENTO A, ESTADO B'
                                         || -- AJ0001
                                           ' WHERE A.COD_EMPRESA  = '''
                                         || lib_parametros.recuperar ( 'EMPRESA' )
                                         || ''''
                                         || ' AND B.IDENT_ESTADO = A.IDENT_ESTADO'
                                         || -- ' AND A.COD_EMPRESA  = C.COD_EMPRESA' || -- AJ0001
                                            -- ' AND A.COD_ESTAB    = C.COD_ESTAB' || -- AJ0001
                                            -- ' AND C.TIPO         = ''L''' || -- AJ0001
                                            ' ORDER BY A.COD_ESTAB'
        );

        RETURN v_tela;
    END;

    FUNCTION moeda ( v_conteudo NUMBER )
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN TRIM ( TO_CHAR ( v_conteudo
                              , '9g999g999g990d00' ) );
    END;

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Relatórios de Resumo da Apuração';
    END;

    FUNCTION descricao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN ' Execução por Filial';
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
        RETURN 'V1';
    END;

    FUNCTION executar ( p_periodo DATE
                      , p_per_fim DATE DEFAULT NULL
                      , p_cod_estab lib_proc.vartab )
        RETURN INTEGER
    IS
        v_linha VARCHAR2 ( 4000 );
        v_class VARCHAR2 ( 1 ) := 'a';
        v_per_fim DATE;
    BEGIN
        EXECUTE IMMEDIATE 'alter session set nls_numeric_characters='',.''';

        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        mproc_id := lib_proc.new ( 'DSP_RELAT_P9_CPROC' );

        IF NVL ( p_per_fim
               , TO_DATE ( '01/01/1900'
                         , 'dd/mm/yyyy' ) ) > TO_DATE ( '01/01/1943'
                                                      , 'dd/mm/yyyy' ) THEN
            IF p_per_fim >= p_periodo THEN
                v_per_fim := p_per_fim;
            ELSE
                lib_proc.add_log ( 'Quando preenchido período final deve ser maior que o periodo inicial!'
                                 , 1 );
                lib_proc.add_log (    'Inicial: '
                                   || TO_CHAR ( p_periodo
                                              , 'mm/yyyy' )
                                 , 1 );
                lib_proc.add_log (    'Final: '
                                   || TO_CHAR ( p_per_fim
                                              , 'mm/yyyy' )
                                 , 1 );

                lib_proc.close ( );

                RETURN mproc_id;
            END IF;
        ELSE
            v_per_fim := p_periodo;
        END IF;

        lib_proc.add_tipo ( mproc_id
                          , 2
                          ,    mcod_empresa
                            || '_'
                            || 'Rel_Entradas_Saidas_'
                            || TO_CHAR ( p_periodo
                                       , 'yyyymm' )
                            || '_'
                            || TO_CHAR ( v_per_fim
                                       , 'yyyymm' )
                            || '.xls'
                          , 2 );
        lib_proc.add_tipo ( mproc_id
                          , 1
                          ,    mcod_empresa
                            || '_'
                            || 'Resumo_Apur_'
                            || TO_CHAR ( p_periodo
                                       , 'yyyymm' )
                            || '_'
                            || TO_CHAR ( v_per_fim
                                       , 'yyyymm' )
                            || '.xls'
                          , 2 );

        lib_proc.add ( dsp_planilha.header
                     , ptipo => 1 );
        lib_proc.add ( dsp_planilha.tabela_inicio
                     , ptipo => 1 );
        lib_proc.add ( dsp_planilha.header
                     , ptipo => 2 );
        lib_proc.add ( dsp_planilha.tabela_inicio
                     , ptipo => 2 );

        lib_proc.add ( dsp_planilha.linha ( p_conteudo =>    dsp_planilha.campo ( 'EMPRESA' )
                                                          || --
                                                            dsp_planilha.campo ( 'ESTAB.' )
                                                          || --
                                                            dsp_planilha.campo ( 'TIPO LIVRO' )
                                                          || --
                                                            dsp_planilha.campo ( 'DATA APURACAO'
                                                                               , p_width => 80
                                                                               , p_align => 'center' )
                                                          || --
                                                            dsp_planilha.campo ( 'COD. OPER. APURACAO'
                                                                               , p_width => 80
                                                                               , p_align => 'center' )
                                                          || --
                                                            dsp_planilha.campo ( 'DESCRICAO OPER. APURACAO'
                                                                               , p_width => 450 )
                                                          || --
                                                            dsp_planilha.campo ( 'DESCRICAO ITEM APURACAO'
                                                                               , p_width => 450 )
                                                          || --
                                                            dsp_planilha.campo ( 'VALOR APURACAO' ) --
                                          , p_class => 'h' )
                     , ptipo => 1 );

        lib_proc.add ( dsp_planilha.linha (
                                            p_conteudo =>    dsp_planilha.campo ( 'EMPRESA' )
                                                          || --
                                                            dsp_planilha.campo ( 'ESTAB.' )
                                                          || --
                                                            dsp_planilha.campo ( 'TIPO LIVRO' )
                                                          || --
                                                            dsp_planilha.campo ( 'DATA APURACAO' )
                                                          || --
                                                            dsp_planilha.campo ( 'ENTRADA/SAIDA' )
                                                          || --
                                                            dsp_planilha.campo ( 'CFOP' )
                                                          || --
                                                            dsp_planilha.campo ( 'VLR. CONTABIL' )
                                                          || --
                                                            dsp_planilha.campo ( 'VLR. BASE' )
                                                          || --
                                                            dsp_planilha.campo ( 'VLR. TRIBUTO' )
                                                          || --
                                                            dsp_planilha.campo ( 'VLR. NTRIBUTAVEL' )
                                                          || --
                                                            dsp_planilha.campo ( 'VLR. OUTRAS' ) --
                                          , p_class => 'h'
                       )
                     , ptipo => 2 );

        v_class := 'a';

        FOR idx IN 1 .. p_cod_estab.COUNT LOOP
            FOR c IN ( SELECT cod_empresa
                            , cod_estab
                            , cod_tipo_livro
                            , dat_apuracao
                            , cod_oper_apur
                            , dsc_oper_apur
                            , '' dsc_item_apuracao
                            , val_apuracao
                         FROM item_apurac_calc
                              JOIN operacao_apuracao
                                  USING (cod_tipo_livro
                                       , cod_oper_apur)
                        WHERE cod_estab = p_cod_estab ( idx )
                          AND dat_apuracao BETWEEN LAST_DAY ( p_periodo ) AND LAST_DAY ( v_per_fim )
                      UNION
                      SELECT cod_empresa
                           , cod_estab
                           , cod_tipo_livro
                           , dat_apuracao
                           , cod_oper_apur
                           , dsc_oper_apur
                           , dsc_item_apuracao
                           , val_item_discrim
                        FROM item_apurac_discr
                             JOIN operacao_apuracao
                                 USING (cod_tipo_livro
                                      , cod_oper_apur)
                       WHERE cod_estab = p_cod_estab ( idx )
                         AND dat_apuracao BETWEEN LAST_DAY ( p_periodo ) AND LAST_DAY ( v_per_fim )
                      ORDER BY cod_estab
                             , cod_tipo_livro
                             , dat_apuracao
                             , cod_oper_apur ) LOOP
                IF v_class = 'a' THEN
                    v_class := 'b';
                ELSE
                    v_class := 'a';
                END IF;

                v_linha :=
                    dsp_planilha.linha (
                                         p_conteudo =>    dsp_planilha.campo ( c.cod_empresa )
                                                       || --
                                                         dsp_planilha.campo ( c.cod_estab )
                                                       || --
                                                         dsp_planilha.campo ( c.cod_tipo_livro )
                                                       || --
                                                         dsp_planilha.campo ( c.dat_apuracao )
                                                       || --
                                                         dsp_planilha.campo ( dsp_planilha.texto ( c.cod_oper_apur ) )
                                                       || --
                                                         dsp_planilha.campo ( c.dsc_oper_apur )
                                                       || --
                                                         dsp_planilha.campo ( c.dsc_item_apuracao )
                                                       || --
                                                         dsp_planilha.campo ( moeda ( c.val_apuracao ) ) --
                                       , p_class => v_class
                    );
                lib_proc.add ( v_linha
                             , ptipo => 1 );
            END LOOP;

            FOR c IN ( SELECT a.*
                         FROM msaf.att_res_apur a
                        WHERE cod_estab = p_cod_estab ( idx )
                          AND dat_apuracao BETWEEN LAST_DAY ( p_periodo ) AND LAST_DAY ( v_per_fim ) ) LOOP
                IF v_class = 'a' THEN
                    v_class := 'b';
                ELSE
                    v_class := 'a';
                END IF;

                v_linha :=
                    dsp_planilha.linha (
                                         p_conteudo =>    dsp_planilha.campo ( c.cod_empresa )
                                                       || --
                                                         dsp_planilha.campo ( c.cod_estab )
                                                       || --
                                                         dsp_planilha.campo ( c.cod_tipo_livro )
                                                       || --
                                                         dsp_planilha.campo ( c.dat_apuracao )
                                                       || --
                                                         dsp_planilha.campo ( c.ind_entrada_saida )
                                                       || --
                                                         dsp_planilha.campo ( c.cod_cfo )
                                                       || --
                                                         dsp_planilha.campo ( moeda ( c.vlr_contabil ) )
                                                       || --
                                                         dsp_planilha.campo ( moeda ( c.vlr_base ) )
                                                       || --
                                                         dsp_planilha.campo ( moeda ( c.vlr_tributo ) )
                                                       || --
                                                         dsp_planilha.campo ( moeda ( c.vlr_ntributavel ) )
                                                       || --
                                                         dsp_planilha.campo ( moeda ( c.vlr_outras ) ) --
                                       , p_class => v_class
                    );
                lib_proc.add ( v_linha
                             , ptipo => 2 );
            END LOOP;
        END LOOP;

        lib_proc.add ( dsp_planilha.tabela_fim
                     , ptipo => 1 );
        lib_proc.add ( dsp_planilha.tabela_fim
                     , ptipo => 2 );

        lib_proc.close ( );

        RETURN mproc_id;
    END;

    PROCEDURE teste
    IS
        v_cod_estab lib_proc.vartab;
    BEGIN
        lib_parametros.salvar ( 'EMPRESA'
                              , 'DP' );

        v_cod_estab ( 0 ) := 'DP1001';

        dbms_output.put_line ( dsp_relat_p9_cproc.executar ( '01/05/2017'
                                                           , '01/05/2017'
                                                           , v_cod_estab ) );
    END;
END;
/
SHOW ERRORS;
