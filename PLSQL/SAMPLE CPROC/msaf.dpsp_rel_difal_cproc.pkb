Prompt Package Body DPSP_REL_DIFAL_CPROC;
--
-- DPSP_REL_DIFAL_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_rel_difal_cproc
IS
    v_proc_id lib_processo.proc_id%TYPE;
    v_cod_empresa empresa.cod_empresa%TYPE;
    v_cod_estab estabelecimento.cod_estab%TYPE;

    FUNCTION parametros
        RETURN VARCHAR2
    IS
        v_param VARCHAR2 ( 4000 );
    BEGIN
        v_cod_empresa := lib_parametros.recuperar ( UPPER ( 'EMPRESA' ) );

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
                             v_param
                           , 'UF'
                           , --P_UF
                            'VARCHAR2'
                           , 'COMBOBOX'
                           , 'S'
                           , '%'
                           , '#########'
                           , 'SELECT A.COD_ESTADO, A.COD_ESTADO FROM ESTADO A UNION ALL SELECT ''%'', ''Todas as UFs'' FROM DUAL ORDER BY 1'
        );

        lib_proc.add_param (
                             v_param
                           , 'Filiais'
                           , --P_ESTABS
                            'VARCHAR2'
                           , 'MULTISELECT'
                           , 'S'
                           , NULL
                           , NULL
                           ,    'SELECT A.COD_ESTAB, A.COD_ESTAB || '' - '' || B.COD_ESTADO || '' - '' || A.CGC || '' - '' || INITCAP(A.BAIRRO) || '' / '' || INITCAP(A.CIDADE) FROM ESTABELECIMENTO A, ESTADO B, MSAFI.DSP_ESTABELECIMENTO C WHERE A.COD_EMPRESA  = '''
                             || v_cod_empresa
                             || ''' AND B.IDENT_ESTADO = A.IDENT_ESTADO AND A.COD_EMPRESA = C.COD_EMPRESA AND A.COD_ESTAB = C.COD_ESTAB AND B.COD_ESTADO LIKE :3 ORDER BY A.COD_ESTAB'
        );
        RETURN v_param;
    END;

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Relatório Difal';
    END;

    FUNCTION descricao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Relatório Difal por UF';
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

    PROCEDURE nlog ( p_log VARCHAR2 )
    IS
    BEGIN
        lib_proc.add_log ( p_log
                         , 1 );
    END;

    FUNCTION executar ( p_data_ini DATE
                      , p_data_fim DATE
                      , p_uf VARCHAR2
                      , p_estabs lib_proc.vartab )
        RETURN NUMBER
    IS
        --Variaveis genericas
        v_class VARCHAR2 ( 1 ) := 'a';
    /*    TYPE A_ESTABS_T IS TABLE OF VARCHAR2(6);
        A_ESTABS A_ESTABS_T := A_ESTABS_T();*/


    BEGIN
        v_proc_id := lib_proc.new ( 'DPSP_REL_DIFAL_CPROC' );
        v_cod_empresa := lib_parametros.recuperar ( 'EMPRESA' );

        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS='',.''';

        lib_proc.add_tipo ( v_proc_id
                          , 1
                          ,    'REL_DIFAL_'
                            || v_cod_empresa
                            || '_'
                            || TO_CHAR ( p_data_ini
                                       , 'DDMMYYYY' )
                            || TO_CHAR ( p_data_fim
                                       , 'DDMMYYYY' )
                            || '.XLS'
                          , 2 );


        lib_proc.add ( dsp_planilha.header
                     , ptipo => 1 );
        lib_proc.add ( dsp_planilha.tabela_inicio
                     , ptipo => 1 );

        lib_proc.add ( dsp_planilha.linha (    dsp_planilha.campo ( 'NUMERO NF' )
                                            || --
                                              dsp_planilha.campo ( 'ESTABELECIMENTO' )
                                            || --
                                              dsp_planilha.campo ( 'DATA FISCAL' )
                                            || --
                                              dsp_planilha.campo ( 'DATA EMISSÃO' )
                                            || --
                                              dsp_planilha.campo ( 'NUM CONTROLE' )
                                            || --
                                              dsp_planilha.campo ( 'MOD DOCUMENTO' )
                                            || --
                                              dsp_planilha.campo ( 'CHAVE ACESSO NFE'
                                                                 , p_width => 280 )
                                            || --
                                              dsp_planilha.campo ( 'RAZÃO SOCIAL'
                                                                 , p_width => 200 )
                                            || --
                                              dsp_planilha.campo ( 'CPF CNPJ'
                                                                 , p_width => 160 )
                                            || --
                                              dsp_planilha.campo ( 'INSC ESTADUAL' )
                                            || --
                                              dsp_planilha.campo ( 'UF' )
                                            || --
                                              dsp_planilha.campo ( 'COD DESTINATARIO' )
                                            || --
                                              dsp_planilha.campo ( 'RAZAO SOCIAL DESTINATARIO'
                                                                 , p_width => 280 )
                                            || --
                                              dsp_planilha.campo ( 'CNPJ DESTINATARIO' )
                                            || --
                                              dsp_planilha.campo ( 'IE DESTINATARIO' )
                                            || --
                                              dsp_planilha.campo ( 'UF DESTINATARIO' )
                                            || --
                                              dsp_planilha.campo ( 'NUM ITEM NF' )
                                            || --
                                              dsp_planilha.campo ( 'COD PRODUTO' )
                                            || --
                                              dsp_planilha.campo ( 'DESCRIÇÃO'
                                                                 , p_width => 280 )
                                            || --,
                                              dsp_planilha.campo ( 'NCM'
                                                                 , p_width => 200 )
                                            || --
                                              dsp_planilha.campo ( 'CFOP' )
                                            || --
                                              dsp_planilha.campo ( 'NAT OPERACAO' )
                                            || --
                                              dsp_planilha.campo ( 'CST A B' )
                                            || --
                                              dsp_planilha.campo ( 'VALOR_UNITARIO' )
                                            || --
                                              dsp_planilha.campo ( 'QUANTIDADE' )
                                            || --
                                              dsp_planilha.campo ( 'VALOR TOTAL' )
                                            || --
                                              dsp_planilha.campo ( 'VALOR CONTÁBIL' )
                                            || --
                                              dsp_planilha.campo ( 'BASE ICMSS' )
                                            || --
                                              dsp_planilha.campo ( 'VLR ICMS NDESTAC,' )
                                            || --
                                              dsp_planilha.campo ( 'VALOR ISENTAS' )
                                            || --
                                              dsp_planilha.campo ( 'VALOR OUTRAS' ) --
                                          , p_class => 'H' )
                     , ptipo => 1 );

        FOR est IN 1 .. p_estabs.COUNT LOOP
            v_cod_estab := p_estabs ( est );

            --V_COD_EMPRESA := P_COD_EMPRESA;

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
                                                    p_conteudo =>    dsp_planilha.campo (
                                                                                          dsp_planilha.texto (
                                                                                                               c_saida.n_nf
                                                                                          )
                                                                     )
                                                                  || dsp_planilha.campo (
                                                                                             dsp_planilha.texto (
                                                                                                                  c_saida.estabelecimento
                                                                                             )
                                                                                          || dsp_planilha.campo (
                                                                                                                  dsp_planilha.texto (
                                                                                                                                       c_saida.data_fiscal
                                                                                                                  )
                                                                                             )
                                                                                          || dsp_planilha.campo (
                                                                                                                  dsp_planilha.texto (
                                                                                                                                       c_saida.data_emissÃo
                                                                                                                  )
                                                                                             )
                                                                                          || --
                                                                                            dsp_planilha.campo (
                                                                                                                 dsp_planilha.texto (
                                                                                                                                      c_saida.num_controle
                                                                                                                 )
                                                                                             )
                                                                                          || --
                                                                                            dsp_planilha.campo (
                                                                                                                 dsp_planilha.texto (
                                                                                                                                      c_saida.mod_documento
                                                                                                                 )
                                                                                             )
                                                                                          || --
                                                                                            dsp_planilha.campo (
                                                                                                                 dsp_planilha.texto (
                                                                                                                                      c_saida.chave_acesso_nfe
                                                                                                                 )
                                                                                             )
                                                                                          || --
                                                                                            dsp_planilha.campo (
                                                                                                                 dsp_planilha.texto (
                                                                                                                                      c_saida.razÃo_social
                                                                                                                 )
                                                                                             )
                                                                                          || --
                                                                                            dsp_planilha.campo (
                                                                                                                 dsp_planilha.texto (
                                                                                                                                      c_saida.cpf_cnpj
                                                                                                                 )
                                                                                             )
                                                                                          || --
                                                                                            dsp_planilha.campo (
                                                                                                                 dsp_planilha.texto (
                                                                                                                                      c_saida.insc_estadual
                                                                                                                 )
                                                                                             )
                                                                                          || --
                                                                                            dsp_planilha.campo (
                                                                                                                 dsp_planilha.texto (
                                                                                                                                      c_saida.uf
                                                                                                                 )
                                                                                             )
                                                                                          || --
                                                                                            dsp_planilha.campo (
                                                                                                                 dsp_planilha.texto (
                                                                                                                                      c_saida.cod_destinatario
                                                                                                                 )
                                                                                             )
                                                                                          || --
                                                                                            dsp_planilha.campo (
                                                                                                                 dsp_planilha.texto (
                                                                                                                                      c_saida.razao_social_destinatario
                                                                                                                 )
                                                                                             )
                                                                                          || --
                                                                                            dsp_planilha.campo (
                                                                                                                 dsp_planilha.texto (
                                                                                                                                      c_saida.cnpj_destinatario
                                                                                                                 )
                                                                                             )
                                                                                          || --
                                                                                            dsp_planilha.campo (
                                                                                                                 dsp_planilha.texto (
                                                                                                                                      c_saida.ie_destinatario
                                                                                                                 )
                                                                                             )
                                                                                          || --
                                                                                            dsp_planilha.campo (
                                                                                                                 dsp_planilha.texto (
                                                                                                                                      c_saida.uf_destinatario
                                                                                                                 )
                                                                                             )
                                                                                          || --
                                                                                            dsp_planilha.campo (
                                                                                                                 dsp_planilha.texto (
                                                                                                                                      c_saida.num_item_nf
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
                                                                                                                                      c_saida.descriÇÃo
                                                                                                                 )
                                                                                             )
                                                                                          || --
                                                                                            dsp_planilha.campo (
                                                                                                                 dsp_planilha.texto (
                                                                                                                                      c_saida.ncm
                                                                                                                 )
                                                                                             )
                                                                                          || --
                                                                                            dsp_planilha.campo (
                                                                                                                 dsp_planilha.texto (
                                                                                                                                      c_saida.cfop
                                                                                                                 )
                                                                                             )
                                                                                          || --
                                                                                            dsp_planilha.campo (
                                                                                                                 dsp_planilha.texto (
                                                                                                                                      c_saida.nat_operacao
                                                                                                                 )
                                                                                             )
                                                                                          || --
                                                                                            dsp_planilha.campo (
                                                                                                                 dsp_planilha.texto (
                                                                                                                                      c_saida.cst_a_b
                                                                                                                 )
                                                                                             )
                                                                                          || --
                                                                                            dsp_planilha.campo (
                                                                                                                 dsp_planilha.texto (
                                                                                                                                      c_saida.valor_unitario
                                                                                                                 )
                                                                                             )
                                                                                          || --
                                                                                            dsp_planilha.campo (
                                                                                                                 dsp_planilha.texto (
                                                                                                                                      c_saida.quantidade
                                                                                                                 )
                                                                                             )
                                                                                          || --
                                                                                            dsp_planilha.campo (
                                                                                                                 c_saida.valor_total
                                                                                             )
                                                                                          || --
                                                                                            dsp_planilha.campo (
                                                                                                                 c_saida.valor_contÁbil
                                                                                             )
                                                                                          || --
                                                                                            dsp_planilha.campo (
                                                                                                                 c_saida.base_icmss
                                                                                             )
                                                                                          || --
                                                                                            dsp_planilha.campo (
                                                                                                                 c_saida.vlr_icms_ndestac
                                                                                             )
                                                                                          || --
                                                                                            dsp_planilha.campo (
                                                                                                                 c_saida.valor_isentas
                                                                                             )
                                                                                          || --
                                                                                            dsp_planilha.campo (
                                                                                                                 c_saida.valor_outras
                                                                                             )
                                                                     )
                                                  , --
                                                   p_class => v_class
                               )
                             , ptipo => 1 );
            END LOOP;
        END LOOP;

        lib_proc.add ( dsp_planilha.tabela_fim
                     , ptipo => 1 );

        lib_proc.close;

        RETURN v_proc_id;
    END executar;
END dpsp_rel_difal_cproc;
/
SHOW ERRORS;
