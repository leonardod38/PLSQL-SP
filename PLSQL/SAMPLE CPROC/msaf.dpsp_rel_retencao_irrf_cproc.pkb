Prompt Package Body DPSP_REL_RETENCAO_IRRF_CPROC;
--
-- DPSP_REL_RETENCAO_IRRF_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_rel_retencao_irrf_cproc
IS
    v_proc_id lib_processo.proc_id%TYPE;

    FUNCTION parametros
        RETURN VARCHAR2
    IS
        v_param VARCHAR2 ( 4000 );
    BEGIN
        -- :1
        lib_proc.add_param (
                             pparam => v_param
                           , ptitulo => 'Empresa'
                           , ptipo => 'varchar2'
                           , pcontrole => 'combobox'
                           , pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => NULL
                           , pvalores =>    'select cod_empresa, rs from ( select ''000'' as cod_empresa , ''Todas as Empresas'' as rs, 1 ordem From dual union all '
                                         || ' select cod_empresa, cod_empresa || '' - '' || razao_social as rs , 2 ordem '
                                         || ' from empresa) order by ordem ,cod_empresa '
        );


        -- :2
        lib_proc.add_param ( v_param
                           , 'Data Inicial'
                           , --P_DATA_INI
                            'DATE'
                           , 'TEXTBOX'
                           , 'S'
                           , NULL
                           , 'DD/MM/YYYY' );


        -- :13
        lib_proc.add_param ( v_param
                           , 'Data Final'
                           , --P_DATA_FIM
                            'DATE'
                           , 'TEXTBOX'
                           , 'S'
                           , NULL
                           , 'DD/MM/YYYY' );


        -- :4
        lib_proc.add_param ( pparam => v_param
                           , ptitulo => 'Ref.Razao Social ou Codigo Pessoa'
                           , ptipo => 'varchar2'
                           , pcontrole => 'textbox'
                           , pmandatorio => 'N'
                           , -- pmascara    => '##############################',
                             phabilita => 'S' );



        --:5
        lib_proc.add_param (
                             pparam => v_param
                           , ptitulo => 'Pessoa Física:'
                           , ptipo => 'Varchar2'
                           , pcontrole => 'Textbox'
                           , pmandatorio => ' :4 IS NOT NULL '
                           , pdefault => NULL
                           , pmascara => NULL
                           , pvalores =>    'SELECT X04.COD_FIS_JUR,  ''  ''||rpad(CPF_CGC,14,'' '')||'' - ''||X04.RAZAO_SOCIAL  '
                                         || '   FROM X04_PESSOA_FIS_JUR X04 '
                                         || ' WHERE X04.COD_FIS_JUR  LIKE ''%''|| :4 ||''%'' '
                                         || ' OR TRIM(UPPER(X04.RAZAO_SOCIAL))  LIKE ''%''||TRIM(UPPER( :4 ))||''%'' order by CPF_CGC, RAZAO_SOCIAL '
                           , papresenta => 'S'
                           , phabilita => ' :4 IS NOT NULL '
        );



        -- :6
        lib_proc.add_param (
                             pparam => v_param
                           , ptitulo => 'Codigo Darf: '
                           , ptipo => 'varchar2'
                           , pcontrole => 'combobox'
                           , pmandatorio => 'N'
                           , pdefault => NULL
                           , pmascara => NULL
                           , pvalores => 'SELECT DISTINCT COD_DARF ,COD_DARF|| '' - '' ||  INITCAP(DESCRICAO) DESCRICAO  FROM X2019_COD_DARF ORDER BY 1 '
        );



        v_cod_empresa := lib_parametros.recuperar ( 'EMPRESA' );

        /*    LIB_PROC.ADD_PARAM(PPARAM      => V_PARAM,
                               PTITULO     => 'EMPRESA',
                               PTIPO       => 'VARCHAR2',
                               PCONTROLE   => 'MULTISELECT',
                               PMANDATORIO => 'S',
                               PVALORES    => 'SELECT A.COD_EMPRESA,
                                                       A.COD_EMPRESA || '' - '' || A.RAZAO_SOCIAL || '' - '' || A.CNPJ
                                                  FROM EMPRESA A, MSAFI.DSP_ESTABELECIMENTO C
                                                 WHERE A.COD_EMPRESA = MSAFI.DPSP.EMPRESA
                                                 GROUP BY A.COD_EMPRESA,
                                                       A.COD_EMPRESA || '' - '' || A.RAZAO_SOCIAL || '' - '' || A.CNPJ
                                                 ORDER BY A.COD_EMPRESA
                                                 ',
                               PAPRESENTA  => 'S',
                               PHABILITA   => 'S'
                               --
                               );
        */
        RETURN v_param;
    END;

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Relatorio Retencao IRRF ';
    END;

    FUNCTION descricao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Relatorio Retencao IRRF';
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
                                       dsp_planilha.campo ( 'DATA MOVIMENTO' )
                                     || --
                                       dsp_planilha.campo ( 'NUM NOTA' )
                                     || --
                                       dsp_planilha.campo ( 'SERIE NOTA' )
                                     || --
                                       dsp_planilha.campo ( 'SUB SERIE NOTA' )
                                     || --
                                       dsp_planilha.campo ( 'TIPO BENEFICIARIO' )
                                     || --
                                       dsp_planilha.campo ( 'CODIGO DARF' )
                                     || --
                                       dsp_planilha.campo ( 'DESCRICAO DARF' )
                                     || --
                                       dsp_planilha.campo ( 'ANO COMPETENCIA' )
                                     || --
                                       dsp_planilha.campo ( 'MES COMPETENCIA' )
                                     || --
                                       dsp_planilha.campo ( 'VLR BRUTO' )
                                     || --
                                       dsp_planilha.campo ( 'VLR DEDUCAO' )
                                     || --
                                       dsp_planilha.campo ( 'VLR IR RETIDO' )
                                     || --
                                       dsp_planilha.campo ( 'ALIQUOTA' )
                                     || --
                                       dsp_planilha.campo ( 'COD_TRIBUTO' )
                                     || --
                                       dsp_planilha.campo ( 'ESP_TRIBUTO' )
                                     || --
                                       dsp_planilha.campo ( 'CODIGO RECEITA' )
                                     || --
                                       dsp_planilha.campo ( 'DATA INI COMPETENCIA' )
                                     || --
                                       dsp_planilha.campo ( 'DATA FIM COMPETENCIA' )
                                     || --,
                                       dsp_planilha.campo ( 'DATA FATO GERADOR' )
                                     || --
                                       dsp_planilha.campo ( 'DATA VENCIMENTO' )
                                     || --
                                       dsp_planilha.campo ( 'NUM VOUCHER' )
                                     || --
                                       dsp_planilha.campo ( 'COD_FIS_JUR' )
                                     || --
                                       dsp_planilha.campo ( 'CPF_CGC' )
                                     || --
                                       dsp_planilha.campo ( 'RAZAO SOCIAL' ) --
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

    PROCEDURE loga ( p_i_texto IN VARCHAR2
                   , p_i_dttm IN BOOLEAN DEFAULT TRUE )
    IS
        vtexto VARCHAR2 ( 1024 );
    BEGIN
        dbms_output.put_line ( p_i_texto );

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
    ---
    END;


    FUNCTION executar ( pcod_empresa VARCHAR2
                      , p_data_ini DATE
                      , p_data_fim DATE
                      , p_razaosocial VARCHAR2
                      , pcodfisjur VARCHAR2
                      , pdarf VARCHAR2 )
        RETURN NUMBER
    IS
        --Variaveis genericas
        v_class VARCHAR2 ( 1 ) := 'a';
        emp NUMBER := 1;
    -- DPSP_EXCL_REL_COMPRAS_2_CPROC
    BEGIN
        v_proc_id := lib_proc.new ( 'DPSP_REL_RETENCAO_IRRF_CPROC' );
        v_cod_empresa := lib_parametros.recuperar ( 'EMPRESA' );

        v_cod_empresa := NVL ( v_cod_empresa, msafi.dpsp.v_empresa );

        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS='',.''';

        --FOR EMP IN 1 .. V_COD_EMPRESA.COUNT LOOP
        --V_COD_EMPRESA   := P_COD_EMPRESA(EMP);

        lib_proc.add_tipo ( v_proc_id
                          , emp
                          ,    'REL_IRRF_'
                            || v_cod_empresa
                            || '_'
                            || TO_CHAR ( SYSDATE
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

        FOR crs_rel_irrf IN rel_irrf ( v_cod_empresa
                                     , p_data_ini
                                     , p_data_fim
                                     , pcodfisjur
                                     , pdarf ) LOOP
            IF v_class = 'a' THEN
                v_class := 'b';
            ELSE
                v_class := 'a';
            END IF;

            lib_proc.add ( dsp_planilha.linha (
                                                p_conteudo =>    dsp_planilha.campo ( crs_rel_irrf.cod_empresa )
                                                              || dsp_planilha.campo (
                                                                                         dsp_planilha.texto (
                                                                                                              crs_rel_irrf.cod_estab
                                                                                         )
                                                                                      || dsp_planilha.campo (
                                                                                                              dsp_planilha.texto (
                                                                                                                                   crs_rel_irrf.data_movto
                                                                                                              )
                                                                                         )
                                                                                      || dsp_planilha.campo (
                                                                                                              dsp_planilha.texto (
                                                                                                                                   crs_rel_irrf.num_docfis
                                                                                                              )
                                                                                         )
                                                                                      || --
                                                                                        dsp_planilha.campo (
                                                                                                             dsp_planilha.texto (
                                                                                                                                  crs_rel_irrf.serie_docfis
                                                                                                             )
                                                                                         )
                                                                                      || --
                                                                                        dsp_planilha.campo (
                                                                                                             dsp_planilha.texto (
                                                                                                                                  crs_rel_irrf.sub_serie_docfis
                                                                                                             )
                                                                                         )
                                                                                      || --
                                                                                        dsp_planilha.campo (
                                                                                                             dsp_planilha.texto (
                                                                                                                                  crs_rel_irrf.tipo_beneficiario
                                                                                                             )
                                                                                         )
                                                                                      || dsp_planilha.campo (
                                                                                                              dsp_planilha.texto (
                                                                                                                                   crs_rel_irrf.cod_darf
                                                                                                              )
                                                                                         )
                                                                                      || --
                                                                                        dsp_planilha.campo (
                                                                                                             dsp_planilha.texto (
                                                                                                                                  crs_rel_irrf.descri_cod_darf
                                                                                                             )
                                                                                         )
                                                                                      || --
                                                                                        dsp_planilha.campo (
                                                                                                             dsp_planilha.texto (
                                                                                                                                  crs_rel_irrf.ano_competencia
                                                                                                             )
                                                                                         )
                                                                                      || --
                                                                                        dsp_planilha.campo (
                                                                                                             crs_rel_irrf.mes_competencia
                                                                                         )
                                                                                      || --
                                                                                        dsp_planilha.campo (
                                                                                                             crs_rel_irrf.vlr_bruto
                                                                                         )
                                                                                      || --
                                                                                        dsp_planilha.campo (
                                                                                                             crs_rel_irrf.vlr_deducao
                                                                                         )
                                                                                      || --
                                                                                        dsp_planilha.campo (
                                                                                                             crs_rel_irrf.vlr_ir_retido
                                                                                         )
                                                                                      || --
                                                                                        dsp_planilha.campo (
                                                                                                             crs_rel_irrf.aliquota
                                                                                         )
                                                                                      || --
                                                                                        dsp_planilha.campo (
                                                                                                             crs_rel_irrf.cod_tributo
                                                                                         )
                                                                                      || --
                                                                                        dsp_planilha.campo (
                                                                                                             crs_rel_irrf.esp_tributo
                                                                                         )
                                                                                      || --
                                                                                        dsp_planilha.campo (
                                                                                                             crs_rel_irrf.cod_receita
                                                                                         )
                                                                                      || --
                                                                                        dsp_planilha.campo (
                                                                                                             crs_rel_irrf.data_ini_compet
                                                                                         )
                                                                                      || --
                                                                                        dsp_planilha.campo (
                                                                                                             crs_rel_irrf.data_fim_compet
                                                                                         )
                                                                                      || --
                                                                                        dsp_planilha.campo (
                                                                                                             crs_rel_irrf.data_fator_gerador
                                                                                         )
                                                                                      || --
                                                                                        dsp_planilha.campo (
                                                                                                             crs_rel_irrf.data_vencto
                                                                                         )
                                                                                      || --
                                                                                        dsp_planilha.campo (
                                                                                                             crs_rel_irrf.num_voucher
                                                                                         )
                                                                                      || --
                                                                                        dsp_planilha.campo (
                                                                                                             crs_rel_irrf.cod_fis_jur
                                                                                         )
                                                                                      || --
                                                                                        dsp_planilha.campo (
                                                                                                             crs_rel_irrf.cpf_cgc
                                                                                         )
                                                                                      || --
                                                                                        dsp_planilha.campo (
                                                                                                             crs_rel_irrf.razao_social
                                                                                         )
                                                                 )
                                              , --
                                               p_class => v_class
                           )
                         , ptipo => emp );
        END LOOP;

        lib_proc.add ( dsp_planilha.tabela_fim
                     , ptipo => emp );

        --END LOOP;

        lib_proc.close;

        RETURN v_proc_id;
    EXCEPTION
        WHEN OTHERS THEN
            loga ( 'ERRO - Favor verificar'
                 , FALSE );

            loga ( 'SQLERRM: ' || SQLERRM
                 , FALSE );

            lib_proc.add_log ( 'ERRO N?O TRATADO: ' || dbms_utility.format_error_backtrace
                             , 1 );
            lib_proc.add_log ( 'SQLERRM: ' || SQLERRM
                             , 1 );

            --ENVIAR EMAIL DE ERRO-------------------------------------------
            -- ENVIA_EMAIL(MCOD_EMPRESA, V_DATA_INICIAL, V_DATA_FINAL, SQLERRM, 'E', V_DATA_HORA_INI);
            -----------------------------------------------------------------
            lib_proc.close ( );

            msafi.dpsp_lib_proc_error ( v_proc_id
                                      , $$plsql_unit );

            COMMIT;
            RETURN v_proc_id;
    END executar;
END dpsp_rel_retencao_irrf_cproc;
/
SHOW ERRORS;
