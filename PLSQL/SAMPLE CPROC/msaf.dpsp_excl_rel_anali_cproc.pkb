Prompt Package Body DPSP_EXCL_REL_ANALI_CPROC;
--
-- DPSP_EXCL_REL_ANALI_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_excl_rel_anali_cproc
IS
    v_proc_id lib_processo.proc_id%TYPE;
    v_cod_empresa empresa.cod_empresa%TYPE;
    v_cod_estab estabelecimento.cod_estab%TYPE;

    FUNCTION parametros
        RETURN VARCHAR2
    IS
        v_param VARCHAR2 ( 4000 );
    BEGIN
        lib_proc.add_param ( v_param
                           , 'Data Inicial'
                           , --P_DATA_INI
                            'DATE'
                           , 'TEXTBOX'
                           , 'S'
                           , NULL
                           , 'DD/MM/YYYY' );

        lib_proc.add_param ( v_param
                           , 'Data Final'
                           , --P_DATA_FIM
                            'DATE'
                           , 'TEXTBOX'
                           , 'S'
                           , NULL
                           , 'DD/MM/YYYY' );

        lib_proc.add_param (
                             pparam => v_param
                           , ptitulo => 'ESTABELECIMENTO'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'MULTISELECT'
                           , pmandatorio => 'S'
                           , pvalores => 'SELECT A.COD_ESTAB,A.COD_ESTAB || '' - '' || B.COD_ESTADO || '' - '' || A.CGC || '' - '' || INITCAP(A.BAIRRO) || '' / '' || INITCAP(A.CIDADE)
                                        FROM ESTABELECIMENTO A, ESTADO B, MSAFI.DSP_ESTABELECIMENTO C
                                      WHERE A.COD_EMPRESA  = MSAFI.DPSP.EMPRESA
                                        AND B.IDENT_ESTADO = A.IDENT_ESTADO
                                        AND A.COD_EMPRESA  = C.COD_EMPRESA
                                        AND A.COD_ESTAB    = C.COD_ESTAB
                                      ORDER BY A.COD_ESTAB'
                           , papresenta => 'S'
                           , phabilita => 'S'
        --
         );

        RETURN v_param;
    END;

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Relatório Análitico - Detalhamento Por Produto (Grandes Volumes)';
    END;

    FUNCTION descricao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'CFOPS Considerados: 5102';
    END;

    FUNCTION versao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'V1';
    END;

    FUNCTION tipo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Relatorio';
    END;

    PROCEDURE grava ( p_texto VARCHAR2
                    , p_tipo VARCHAR2 DEFAULT '1' )
    IS
    BEGIN
        lib_proc.add ( p_texto
                     , ptipo => p_tipo );
    END;

    PROCEDURE cabecalho ( p_tipo VARCHAR2 DEFAULT '1' )
    IS
    BEGIN
        grava ( dsp_planilha.linha (
                                        dsp_planilha.campo ( 'EMPRESA' )
                                     || --
                                       dsp_planilha.campo ( 'FILIAL' )
                                     || --
                                       dsp_planilha.campo ( 'ESTADO' )
                                     || --
                                       dsp_planilha.campo ( 'NUM NOTA' )
                                     || --
                                       dsp_planilha.campo ( 'CHAVE DE ACESSO' )
                                     || --
                                       dsp_planilha.campo ( 'COD_PRODUTO' )
                                     || --
                                       dsp_planilha.campo ( 'DESCRICAO' )
                                     || --
                                       dsp_planilha.campo ( 'CFOP' )
                                     || --
                                       dsp_planilha.campo ( 'CST' )
                                     || --
                                       dsp_planilha.campo ( 'VALOR CONTABIL' )
                                     || --
                                       dsp_planilha.campo ( 'BASE DE CALCULO' )
                                     || --
                                       dsp_planilha.campo ( 'ALIQ DE ICMS' )
                                     || --
                                       dsp_planilha.campo ( 'VALOR ICMS' ) --
                                   , p_class => 'H'
                )
              , p_tipo );
    END;

    PROCEDURE nlog ( p_log VARCHAR2 )
    IS
    BEGIN
        lib_proc.add_log ( p_log
                         , 1 );
    END;

    FUNCTION executar ( p_data_ini DATE
                      , p_data_fim DATE
                      , p_estabs lib_proc.vartab )
        RETURN NUMBER
    IS
        --Variaveis genericas
        v_class VARCHAR2 ( 1 ) := 'a';
        i1 INTEGER;

        TYPE a_estabs_t IS TABLE OF VARCHAR2 ( 6 );

        a_estabs a_estabs_t := a_estabs_t ( );
    BEGIN
        v_proc_id := lib_proc.new ( 'DPSP_EXCL_REL_ANALI_CPROC' );
        v_cod_empresa := lib_parametros.recuperar ( 'EMPRESA' );

        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS='',.''';

        FOR est IN 1 .. p_estabs.COUNT LOOP
            v_cod_estab := p_estabs ( est );

            lib_proc.add_tipo ( v_proc_id
                              , est
                              ,    'NF_EXCL_'
                                || v_cod_empresa
                                || '_'
                                || v_cod_estab
                                || '_'
                                || TO_CHAR ( p_data_ini
                                           , 'DDMMYYYY' )
                                || TO_CHAR ( p_data_fim
                                           , 'DDMMYYYY' )
                                || '.XLS'
                              , 2 );

            lib_proc.add ( dsp_planilha.header
                         , ptipo => est );
            lib_proc.add ( dsp_planilha.tabela_inicio
                         , ptipo => est );

            cabecalho ( est );

            FOR c_saida IN crs_saidas ( v_cod_empresa
                                      , v_cod_estab
                                      , p_data_ini
                                      , p_data_fim ) LOOP
                IF v_class = 'a' THEN
                    v_class := 'b';
                ELSE
                    v_class := 'a';
                END IF;

                lib_proc.add ( dsp_planilha.linha (
                                                    p_conteudo =>    dsp_planilha.campo ( c_saida.cod_empresa )
                                                                  || dsp_planilha.campo (
                                                                                             dsp_planilha.texto (
                                                                                                                  c_saida.cod_estab
                                                                                             )
                                                                                          || dsp_planilha.campo (
                                                                                                                  dsp_planilha.texto (
                                                                                                                                       c_saida.cod_estado
                                                                                                                  )
                                                                                             )
                                                                                          || dsp_planilha.campo (
                                                                                                                  dsp_planilha.texto (
                                                                                                                                       c_saida.num_docfis
                                                                                                                  )
                                                                                             )
                                                                                          || --
                                                                                            dsp_planilha.campo (
                                                                                                                 dsp_planilha.texto (
                                                                                                                                      c_saida.num_autentic_nfe
                                                                                                                 )
                                                                                             )
                                                                                          || --
                                                                                            dsp_planilha.campo (
                                                                                                                 dsp_planilha.texto (
                                                                                                                                      c_saida.cod_produto
                                                                                                                 )
                                                                                             )
                                                                                          || --
                                                                                            dsp_planilha.campo (
                                                                                                                 dsp_planilha.texto (
                                                                                                                                      c_saida.descricao
                                                                                                                 )
                                                                                             )
                                                                                          || --
                                                                                            dsp_planilha.campo (
                                                                                                                 c_saida.cod_cfo
                                                                                             )
                                                                                          || --
                                                                                            dsp_planilha.campo (
                                                                                                                 c_saida.cod_situacao_b
                                                                                             )
                                                                                          || --
                                                                                            dsp_planilha.campo (
                                                                                                                 c_saida.vlr_item
                                                                                             )
                                                                                          || --
                                                                                            dsp_planilha.campo (
                                                                                                                 c_saida.vlr_base
                                                                                             )
                                                                                          || --
                                                                                            dsp_planilha.campo (
                                                                                                                 c_saida.aliq_icms
                                                                                             )
                                                                                          || --
                                                                                            dsp_planilha.campo (
                                                                                                                 c_saida.vlr_icms
                                                                                             )
                                                                     )
                                                  , --
                                                   p_class => v_class
                               )
                             , ptipo => est );
            END LOOP;

            lib_proc.add ( dsp_planilha.tabela_fim
                         , ptipo => est );
        END LOOP;

        lib_proc.close;

        RETURN v_proc_id;
    END executar;
END dpsp_excl_rel_anali_cproc;
/
SHOW ERRORS;
