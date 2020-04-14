Prompt Package Body DPSP_EXCL_REL_COMPRAS_2_CPROC;
--
-- DPSP_EXCL_REL_COMPRAS_2_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_excl_rel_compras_2_cproc
IS
    v_proc_id lib_processo.proc_id%TYPE;
    v_cod_empresa empresa.cod_empresa%TYPE;

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

        lib_proc.add_param ( pparam => v_param
                           , ptitulo => 'EMPRESA'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'MULTISELECT'
                           , pmandatorio => 'S'
                           , pvalores => 'SELECT A.COD_EMPRESA,
                                               A.COD_EMPRESA || '' - '' || A.RAZAO_SOCIAL || '' - '' || A.CNPJ
                                          FROM EMPRESA A, MSAFI.DSP_ESTABELECIMENTO C
                                         WHERE A.COD_EMPRESA = MSAFI.DPSP.EMPRESA
                                         GROUP BY A.COD_EMPRESA,
                                               A.COD_EMPRESA || '' - '' || A.RAZAO_SOCIAL || '' - '' || A.CNPJ  
                                         ORDER BY A.COD_EMPRESA
                                         '
                           , papresenta => 'S'
                           , phabilita => 'S'--
                                              );

        RETURN v_param;
    END;

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Relatório de Compras por Empresa';
    END;

    FUNCTION descricao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'CFOPS Considerados: 1102, 2102, 1403, 2403';
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
                                        dsp_planilha.campo ( 'FILIAL' )
                                     || --
                                       dsp_planilha.campo ( 'DAT_LANC_PIS_COFINS' )
                                     || --
                                       dsp_planilha.campo ( 'NUM NOTA' )
                                     || --
                                       dsp_planilha.campo ( 'CHAVE DE ACESSO' )
                                     || --
                                       dsp_planilha.campo ( 'NBM' )
                                     || --
                                       dsp_planilha.campo ( 'COD_PRODUTO' )
                                     || --
                                       dsp_planilha.campo ( 'DESCRICAO' )
                                     || --
                                       dsp_planilha.campo ( 'NUM ITEM' )
                                     || --
                                       dsp_planilha.campo ( 'CFOP' )
                                     || --
                                       dsp_planilha.campo ( 'VLR CONTABIL' )
                                     || --
                                       dsp_planilha.campo ( 'BASE PIS' )
                                     || --
                                       dsp_planilha.campo ( 'ALIQ PIS' )
                                     || --
                                       dsp_planilha.campo ( 'VALOR PIS' )
                                     || --
                                       dsp_planilha.campo ( 'BASE COFINS' )
                                     || --
                                       dsp_planilha.campo ( 'ALIQ COFINS' )
                                     || --
                                       dsp_planilha.campo ( 'VALOR COFINS' )
                                     || --
                                       dsp_planilha.campo ( 'CST PIS' )
                                     || --
                                       dsp_planilha.campo ( 'CST COFINS' )
                                     || --
                                       dsp_planilha.campo ( 'CLASSIFICAÇÃO PIS DSP' ) --
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
                      , p_cod_empresa lib_proc.vartab )
        RETURN NUMBER
    IS
        --Variaveis genericas
        v_class VARCHAR2 ( 1 ) := 'a';
    BEGIN
        v_proc_id := lib_proc.new ( 'DPSP_EXCL_REL_COMPRAS_2_CPROC' );
        v_cod_empresa := lib_parametros.recuperar ( 'EMPRESA' );

        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS='',.''';

        FOR emp IN 1 .. p_cod_empresa.COUNT LOOP
            v_cod_empresa := p_cod_empresa ( emp );

            lib_proc.add_tipo ( v_proc_id
                              , emp
                              ,    'NF_EXCL_'
                                || v_cod_empresa
                                || '_'
                                || TO_CHAR ( p_data_ini
                                           , 'DDMMYYYY' )
                                || TO_CHAR ( p_data_fim
                                           , 'DDMMYYYY' )
                                || '.XLS'
                              , 2 );


            lib_proc.add ( dsp_planilha.header
                         , ptipo => emp );
            lib_proc.add ( dsp_planilha.tabela_inicio
                         , ptipo => emp );

            cabecalho ( emp );

            FOR c_saida IN crs_saidas ( v_cod_empresa
                                      , p_data_ini
                                      , p_data_fim ) LOOP
                IF v_class = 'a' THEN
                    v_class := 'b';
                ELSE
                    v_class := 'a';
                END IF;

                lib_proc.add ( dsp_planilha.linha (
                                                    p_conteudo =>    dsp_planilha.campo ( c_saida.empresa )
                                                                  || dsp_planilha.campo (
                                                                                             dsp_planilha.texto (
                                                                                                                  c_saida.filial
                                                                                             )
                                                                                          || dsp_planilha.campo (
                                                                                                                  dsp_planilha.texto (
                                                                                                                                       c_saida.dat_lanc_pis_cofins
                                                                                                                  )
                                                                                             )
                                                                                          || dsp_planilha.campo (
                                                                                                                  dsp_planilha.texto (
                                                                                                                                       c_saida.num_nota
                                                                                                                  )
                                                                                             )
                                                                                          || --
                                                                                            dsp_planilha.campo (
                                                                                                                 dsp_planilha.texto (
                                                                                                                                      c_saida.chave_nfe
                                                                                                                 )
                                                                                             )
                                                                                          || --
                                                                                            dsp_planilha.campo (
                                                                                                                 dsp_planilha.texto (
                                                                                                                                      c_saida.nbm
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
                                                                                                                 c_saida.num_item
                                                                                             )
                                                                                          || --
                                                                                            dsp_planilha.campo (
                                                                                                                 c_saida.cfop
                                                                                             )
                                                                                          || --
                                                                                            dsp_planilha.campo (
                                                                                                                 c_saida.vlr_contab_item
                                                                                             )
                                                                                          || --
                                                                                            dsp_planilha.campo (
                                                                                                                 c_saida.vlr_base_pis
                                                                                             )
                                                                                          || --
                                                                                            dsp_planilha.campo (
                                                                                                                 c_saida.aliq_pis
                                                                                             )
                                                                                          || --
                                                                                            dsp_planilha.campo (
                                                                                                                 c_saida.vlr_pis
                                                                                             )
                                                                                          || --
                                                                                            dsp_planilha.campo (
                                                                                                                 c_saida.vlr_base_cofins
                                                                                             )
                                                                                          || --
                                                                                            dsp_planilha.campo (
                                                                                                                 c_saida.aliq_cofins
                                                                                             )
                                                                                          || --
                                                                                            dsp_planilha.campo (
                                                                                                                 c_saida.vlr_cofins
                                                                                             )
                                                                                          || --
                                                                                            dsp_planilha.campo (
                                                                                                                 c_saida.cst_pis
                                                                                             )
                                                                                          || --
                                                                                            dsp_planilha.campo (
                                                                                                                 c_saida.cst_cofins
                                                                                             )
                                                                                          || --
                                                                                            dsp_planilha.campo (
                                                                                                                 c_saida.class_pis_dsp
                                                                                             )
                                                                     )
                                                  , --
                                                   p_class => v_class
                               )
                             , ptipo => emp );
            END LOOP;

            lib_proc.add ( dsp_planilha.tabela_fim
                         , ptipo => emp );
        END LOOP;

        lib_proc.close;

        RETURN v_proc_id;
    END executar;
END dpsp_excl_rel_compras_2_cproc;
/
SHOW ERRORS;
