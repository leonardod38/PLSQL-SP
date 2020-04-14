Prompt Package Body DSP_VALIDA_CPROC;
--
-- DSP_VALIDA_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dsp_valida_cproc
IS
    mcod_empresa empresa.cod_empresa%TYPE;
    musuario usuario_empresa.cod_usuario%TYPE;

    /* Create Global Temporary Table dsp_valida_estab(tip varchar2(10), cod_filtro Varchar2(6)) on commit preserve rows ; */
    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );
        v_curs_estab VARCHAR2 ( 1000 )
            :=    'Select Distinct ''UF''||Cod_Estado , '' Lojas ''||Cod_Estado txt'
               || ' From dsp_estabelecimento_v Where Tipo = ''L'' union'
               || ' Select TIPO||COD_ESTAB , ''(''|| TIPO || '') ''||Cod_Estado||'' - ''||COD_ESTAB||'' - ''||Initcap(ENDER)'
               || ' From dsp_estabelecimento_v ORDER BY 2';
    BEGIN
        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        musuario := lib_parametros.recuperar ( 'USUARIO' );

        lib_proc.add_param ( pstr
                           , ' '
                           , 'VARCHAR2'
                           , 'Text' );

        lib_proc.add_param ( pstr
                           , 'Data Inicial'
                           , 'DATE'
                           , 'TEXTBOX'
                           , 'S'
                           , NULL
                           , 'MM/YYYY' );

        lib_proc.add_param ( pstr
                           , ' '
                           , 'VARCHAR2'
                           , 'Text' );
        lib_proc.add_param ( pstr
                           , '___________________________________________________________________________________'
                           , 'VARCHAR2'
                           , 'Text' );
        lib_proc.add_param (
                             pstr
                           , '* Grupo/Estabelecimento: Os registros serão agrupados em arquivos por Lojas UF e CD, para cada'
                           , 'VARCHAR2'
                           , 'Text'
        );
        lib_proc.add_param (
                             pstr
                           ,    '                                          '
                             || 'estabelecimento iniciado com (L) marcado será gerado um arquivo individual.'
                           , 'VARCHAR2'
                           , 'Text'
        );

        lib_proc.add_param ( pstr
                           , 'Grupo/Estabelecimentos'
                           , 'VARCHAR2'
                           , 'MULTISELECT'
                           , 'S'
                           , NULL
                           , NULL
                           , v_curs_estab );

        RETURN pstr;
    END; --FUNCTION PARAMETROS RETURN VARCHAR2 IS

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Relatório de análise por perfil de Documento Fiscal (Valida)';
    END;

    FUNCTION tipo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Fechamento';
    END;

    FUNCTION versao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'VERSAO 1.0';
    END;

    FUNCTION descricao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN '';
    END;

    FUNCTION modulo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'PROCESSOS CUSTOMIZADOS';
    END;

    FUNCTION classificacao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'PROCESSOS CUSTOMIZADOS';
    END;

    FUNCTION executar ( p_periodo DATE
                      , p_estabelecimento lib_proc.vartab )
        RETURN INTEGER
    IS
        mproc_id INTEGER;
        v_lojas_uf lib_proc.vartab;
        v_cd_uf lib_proc.vartab;
        v_lojas lib_proc.vartab;
        v_criterios VARCHAR2 ( 4000 );
        v_cods VARCHAR2 ( 20 );
        v_tipo INTEGER;
    BEGIN
        -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        mproc_id := lib_proc.new ( 'DSP_VALIDA_CPROC' );

        COMMIT;

        dbms_application_info.set_module ( $$plsql_unit
                                         , 'PASSO 1' );

        -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        -- Verifica o tipo de execução Lojas por UF, Por COD_ESTAB ou CDs
        FOR i IN 1 .. p_estabelecimento.COUNT LOOP
            IF ( p_estabelecimento ( i ) LIKE 'UF%' ) THEN
                v_lojas_uf ( v_lojas_uf.COUNT + 1 ) :=
                    SUBSTR ( p_estabelecimento ( i )
                           , 3 );
            ELSIF ( p_estabelecimento ( i ) LIKE 'C%' ) THEN
                v_cd_uf ( v_cd_uf.COUNT + 1 ) :=
                    SUBSTR ( p_estabelecimento ( i )
                           , 2 );
            ELSIF ( p_estabelecimento ( i ) LIKE 'L%' ) THEN
                BEGIN
                    SELECT cod_estab
                      INTO v_lojas ( v_lojas.COUNT + 1 )
                      FROM dsp_estabelecimento_v
                     WHERE cod_estab = SUBSTR ( p_estabelecimento ( i )
                                              , 2 )
                       AND cod_estado NOT IN ( SELECT COLUMN_VALUE
                                                 FROM TABLE ( v_lojas_uf ) );
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        NULL;
                END;
            END IF;
        END LOOP;

        COMMIT;
        dbms_application_info.set_module ( $$plsql_unit
                                         , 'PASSO 2 lojas UF' );

        -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        -- RELATÓRIO DE LOJAS POR UF
        IF v_lojas_uf.COUNT > 0 THEN
            v_cods := '';
            lib_proc.add_log ( 'Inicia Processamento de Lojas por UF:'
                             , 1 );

            DELETE FROM dsp_valida_estab;

            FOR c IN ( SELECT COLUMN_VALUE
                         FROM TABLE ( v_lojas_uf ) ) LOOP
                lib_proc.add_log ( '           ' || c.COLUMN_VALUE
                                 , 1 );
                v_cods := v_cods || '_' || c.COLUMN_VALUE;

                INSERT INTO dsp_valida_estab
                     VALUES ( 'Lojas_Uf'
                            , c.COLUMN_VALUE );
            END LOOP;

            COMMIT;
            lib_proc.add_tipo ( mproc_id
                              , 1
                              ,    'VALIDA_LOJ_UF'
                                || v_cods
                                || '_'
                                || TO_CHAR ( p_periodo
                                           , 'YYYYMM' )
                                || '.xls'
                              , 2 );
            lib_proc.add ( dsp_planilha.header ( )
                         , ptipo => 1 );
            lib_proc.add ( dsp_planilha.tabela_inicio ( )
                         , ptipo => 1 );
            lib_proc.add ( dsp_planilha.linha (    dsp_planilha.campo ( 'COD_EMPRESA' )
                                                || dsp_planilha.campo ( 'UF_ESTAB' )
                                                || dsp_planilha.campo ( 'SAIDA_ENTRADA' )
                                                || dsp_planilha.campo ( 'FINALIDADE' )
                                                || dsp_planilha.campo ( 'CFOP' )
                                                || dsp_planilha.campo ( 'CST' )
                                                || dsp_planilha.campo ( 'VLR_CONTAB_ITEM' )
                                                || dsp_planilha.campo ( 'BASE_TRIB' )
                                                || dsp_planilha.campo ( 'VLR_ICMS' )
                                                || dsp_planilha.campo ( 'ALIQ' )
                                                || dsp_planilha.campo ( 'ISENTA' )
                                                || dsp_planilha.campo ( 'OUTRAS' )
                                                || dsp_planilha.campo ( 'REDUCAO' )
                                                || dsp_planilha.campo ( 'ICMS_ST' )
                                                || dsp_planilha.campo ( 'IPI_N_DESTAC' )
                                                || dsp_planilha.campo ( 'VLR_DESPESA' )
                                                || dsp_planilha.campo ( 'BATE_VLR_ITEM_COM_BASES' )
                                                || dsp_planilha.campo ( 'LINHAS' )
                                                || dsp_planilha.campo ( 'REGRAS_VALIDACAO' )
                                                || dsp_planilha.campo ( 'ACAO'
                                                                      , p_custom => 'bgcolor="RED"' )
                                                || dsp_planilha.campo ( 'CONCATENACAO' )
                                                || dsp_planilha.campo ( 'MIN_IDENT_DOCTO_FISCAL' )
                                                || dsp_planilha.campo ( 'MAX_IDENT_DOCTO_FISCAL' )
                                                || dsp_planilha.campo ( 'CRITERIOS_BASICOS'
                                                                      , p_custom => 'bgcolor="777777"' )
                                                || --
                                                   dsp_planilha.campo ( 'COD_ESTAB'
                                                                      , p_custom => 'bgcolor="777777"' )
                                                || dsp_planilha.campo ( 'DATA_FISCAL'
                                                                      , p_custom => 'bgcolor="777777"' )
                                                || dsp_planilha.campo ( 'MOVTO_E_S'
                                                                      , p_custom => 'bgcolor="777777"' )
                                                || dsp_planilha.campo ( 'NORM_DEV'
                                                                      , p_custom => 'bgcolor="777777"' )
                                                || dsp_planilha.campo ( 'IDENT_DOCTO'
                                                                      , p_custom => 'bgcolor="777777"' )
                                                || dsp_planilha.campo ( 'IDENT_FIS_JUR'
                                                                      , p_custom => 'bgcolor="777777"' )
                                                || dsp_planilha.campo ( 'NUM_DOCFIS'
                                                                      , p_custom => 'bgcolor="777777"' )
                                                || dsp_planilha.campo ( 'SERIE_DOCFIS'
                                                                      , p_custom => 'bgcolor="777777"' )
                                                || dsp_planilha.campo ( 'SUB_SERIE_DOCFIS'
                                                                      , p_custom => 'bgcolor="777777"' )
                                                || dsp_planilha.campo ( 'CHAVE_ACESSO'
                                                                      , p_custom => 'bgcolor="777777"' )
                                                || --
                                                   dsp_planilha.campo ( 'COD_ESTAB'
                                                                      , p_custom => 'bgcolor="777777"' )
                                                || dsp_planilha.campo ( 'DATA_FISCAL'
                                                                      , p_custom => 'bgcolor="777777"' )
                                                || dsp_planilha.campo ( 'MOVTO_E_S'
                                                                      , p_custom => 'bgcolor="777777"' )
                                                || dsp_planilha.campo ( 'NORM_DEV'
                                                                      , p_custom => 'bgcolor="777777"' )
                                                || dsp_planilha.campo ( 'IDENT_DOCTO'
                                                                      , p_custom => 'bgcolor="777777"' )
                                                || dsp_planilha.campo ( 'IDENT_FIS_JUR'
                                                                      , p_custom => 'bgcolor="777777"' )
                                                || dsp_planilha.campo ( 'NUM_DOCFIS'
                                                                      , p_custom => 'bgcolor="777777"' )
                                                || dsp_planilha.campo ( 'SERIE_DOCFIS'
                                                                      , p_custom => 'bgcolor="777777"' )
                                                || dsp_planilha.campo ( 'SUB_SERIE_DOCFIS'
                                                                      , p_custom => 'bgcolor="777777"' )
                                                || dsp_planilha.campo ( 'CHAVE_ACESSO'
                                                                      , p_custom => 'bgcolor="777777"' )
                                              , --
                                                'h' )
                         , ptipo => 1 );
            COMMIT;

            -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            FOR a IN crs_lojas_uf ( mcod_empresa
                                  , p_periodo ) LOOP
                dbms_application_info.set_module ( $$plsql_unit
                                                 , 'PASSO 2 lojas UF ' || a.uf_estab );

                SELECT    '    || '' OR (DSP.COD_ESTADO = '''''''''
                       || a.uf_estab
                       || ''''''''' AND DDF.MOVTO_E_S'
                       || DECODE ( a.saida_entrada, 'S', '=', '<>' )
                       || '''''''''9'''''''''
                       || ' AND XNO.COD_NATUREZA_OP'
                       || CASE
                              WHEN a.finalidade IS NULL THEN ' IS NULL'
                              ELSE '=''''''''' || a.finalidade || ''''''''''
                          END
                       || ' AND XCF.COD_CFO'
                       || CASE WHEN a.cfop IS NULL THEN ' IS NULL' ELSE '=''''''''' || a.cfop || '''''''''' END
                       || ' AND STB.COD_SITUACAO_B'
                       || CASE WHEN a.cst IS NULL THEN ' IS NULL' ELSE '=''''''''' || a.cst || '''''''''' END
                       || ' AND SIGN(DIM.VLR_BASE_ICMS_1) = '
                       || a.base_trib
                       || ' AND SIGN(DIM.VLR_TRIBUTO_ICMS) = '
                       || a.vlr_icms
                       || ' AND SIGN(DIM.ALIQ_TRIBUTO_ICMS) = '
                       || a.aliq
                       || ' AND SIGN(DIM.VLR_BASE_ICMS_2) = '
                       || a.isenta
                       || ' AND SIGN(DIM.VLR_BASE_ICMS_3) = '
                       || a.outras
                       || ' AND SIGN(DIM.VLR_BASE_ICMS_4) = '
                       || a.reducao
                       || ' AND SIGN(DIM.VLR_CONTAB_ITEM) = '
                       || a.vlr_contab_item
                       || ' AND SIGN(DIM.VLR_TRIBUTO_ICMSS) = '
                       || a.icms_st
                       || ' AND SIGN(DIM.VLR_IPI_NDESTAC) = '
                       || a.ipi_n_destac
                       || ' AND DIM.VLR_CONTAB_ITEM - DIM.VLR_BASE_ICMS_1 - DIM.VLR_BASE_ICMS_2 - DIM.VLR_BASE_ICMS_3 - DIM.VLR_BASE_ICMS_4 - DIM.VLR_TRIBUTO_ICMSS - DIM.VLR_OUTRAS - DIM.VLR_IPI_NDESTAC '
                       || CASE WHEN a.bate_vlr_item_com_bases = 'SIM' THEN '=' ELSE '<>' END
                       || ' 0) '''
                  INTO v_criterios
                  FROM DUAL;

                lib_proc.add ( dsp_planilha.linha (
                                                       dsp_planilha.campo ( a.cod_empresa )
                                                    || dsp_planilha.campo ( a.uf_estab )
                                                    || dsp_planilha.campo ( a.saida_entrada )
                                                    || dsp_planilha.campo ( a.finalidade )
                                                    || dsp_planilha.campo ( a.cfop )
                                                    || dsp_planilha.campo ( dsp_planilha.texto ( a.cst ) )
                                                    || dsp_planilha.campo ( a.vlr_contab_item )
                                                    || dsp_planilha.campo ( a.base_trib )
                                                    || dsp_planilha.campo ( a.vlr_icms )
                                                    || dsp_planilha.campo ( a.aliq )
                                                    || dsp_planilha.campo ( a.isenta )
                                                    || dsp_planilha.campo ( a.outras )
                                                    || dsp_planilha.campo ( a.reducao )
                                                    || dsp_planilha.campo ( a.icms_st )
                                                    || dsp_planilha.campo ( a.ipi_n_destac )
                                                    || dsp_planilha.campo ( a.vlr_despesa )
                                                    || dsp_planilha.campo ( a.bate_vlr_item_com_bases )
                                                    || dsp_planilha.campo ( a.linhas )
                                                    || dsp_planilha.campo ( a.regras_validacao )
                                                    || dsp_planilha.campo ( a.acao )
                                                    || dsp_planilha.campo ( a.concatenacao )
                                                    || dsp_planilha.campo ( a.min_ident_docto_fiscal )
                                                    || dsp_planilha.campo ( a.max_ident_docto_fiscal )
                                                    || dsp_planilha.campo ( v_criterios )
                                                    || --
                                                       dsp_planilha.campo ( a.cod_estab )
                                                    || dsp_planilha.campo ( a.data_fiscal )
                                                    || dsp_planilha.campo ( a.movto_e_s )
                                                    || dsp_planilha.campo ( a.norm_dev )
                                                    || dsp_planilha.campo ( a.ident_docto )
                                                    || dsp_planilha.campo ( a.ident_fis_jur )
                                                    || dsp_planilha.campo ( a.num_docfis )
                                                    || dsp_planilha.campo ( a.serie_docfis )
                                                    || dsp_planilha.campo ( a.sub_serie_docfis )
                                                    || dsp_planilha.campo ( dsp_planilha.texto ( a.identif_docfis ) )
                                                    || --
                                                       dsp_planilha.campo ( a.cod_estab2 )
                                                    || dsp_planilha.campo ( a.data_fiscal2 )
                                                    || dsp_planilha.campo ( a.movto_e_s2 )
                                                    || dsp_planilha.campo ( a.norm_dev2 )
                                                    || dsp_planilha.campo ( a.ident_docto2 )
                                                    || dsp_planilha.campo ( a.ident_fis_jur2 )
                                                    || dsp_planilha.campo ( a.num_docfis2 )
                                                    || dsp_planilha.campo ( a.serie_docfis2 )
                                                    || dsp_planilha.campo ( a.sub_serie_docfis2 )
                                                    || dsp_planilha.campo ( dsp_planilha.texto ( a.identif_docfis2 ) )
                                                  , p_custom => 'height="17"'
                               )
                             , ptipo => 1 );
                COMMIT;
            END LOOP;

            lib_proc.add ( dsp_planilha.tabela_fim ( )
                         , ptipo => 1 );

            COMMIT;
        END IF;

        dbms_application_info.set_module ( $$plsql_unit
                                         , 'PASSO 3' );

        -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        -- RELATÓRIO DE CD POR UF
        IF v_cd_uf.COUNT > 0 THEN
            v_cods := '';
            lib_proc.add_log ( 'Inicia Processamento de CD por UF:'
                             , 1 );

            DELETE FROM msaf.dsp_valida_estab;

            FOR c IN ( SELECT COLUMN_VALUE
                         FROM TABLE ( v_cd_uf ) ) LOOP
                lib_proc.add_log ( '           ' || c.COLUMN_VALUE
                                 , 1 );
                v_cods := v_cods || '_' || c.COLUMN_VALUE;

                INSERT INTO dsp_valida_estab
                     VALUES ( 'CD_Uf'
                            , c.COLUMN_VALUE );
            END LOOP;

            COMMIT;

            lib_proc.add_tipo ( mproc_id
                              , 2
                              ,    'VALIDA_CD'
                                || v_cods
                                || '_'
                                || TO_CHAR ( p_periodo
                                           , 'YYYYMM' )
                                || '.xls'
                              , 2 );
            lib_proc.add ( dsp_planilha.header ( )
                         , ptipo => 2 );
            lib_proc.add ( dsp_planilha.tabela_inicio ( )
                         , ptipo => 2 );
            lib_proc.add ( dsp_planilha.linha (    dsp_planilha.campo ( 'COD_EMPRESA' )
                                                || dsp_planilha.campo ( 'UF_ESTAB' )
                                                || dsp_planilha.campo ( 'SAIDA_ENTRADA' )
                                                || dsp_planilha.campo ( 'FINALIDADE' )
                                                || dsp_planilha.campo ( 'CFOP' )
                                                || dsp_planilha.campo ( 'CST' )
                                                || dsp_planilha.campo ( 'VLR_CONTAB_ITEM' )
                                                || dsp_planilha.campo ( 'BASE_TRIB' )
                                                || dsp_planilha.campo ( 'VLR_ICMS' )
                                                || dsp_planilha.campo ( 'ALIQ' )
                                                || dsp_planilha.campo ( 'ISENTA' )
                                                || dsp_planilha.campo ( 'OUTRAS' )
                                                || dsp_planilha.campo ( 'REDUCAO' )
                                                || dsp_planilha.campo ( 'ICMS_ST' )
                                                || dsp_planilha.campo ( 'IPI_N_DESTAC' )
                                                || dsp_planilha.campo ( 'VLR_DESPESA' )
                                                || dsp_planilha.campo ( 'BATE_VLR_ITEM_COM_BASES' )
                                                || dsp_planilha.campo ( 'LINHAS' )
                                                || dsp_planilha.campo ( 'REGRAS_VALIDACAO' )
                                                || dsp_planilha.campo ( 'ACAO'
                                                                      , p_custom => 'bgcolor="RED"' )
                                                || dsp_planilha.campo ( 'CONCATENACAO' )
                                                || dsp_planilha.campo ( 'MIN_IDENT_DOCTO_FISCAL' )
                                                || dsp_planilha.campo ( 'MAX_IDENT_DOCTO_FISCAL' )
                                                || dsp_planilha.campo ( 'CRITERIOS_BASICOS'
                                                                      , p_custom => 'bgcolor="777777"' )
                                                || --
                                                   dsp_planilha.campo ( 'COD_ESTAB'
                                                                      , p_custom => 'bgcolor="777777"' )
                                                || dsp_planilha.campo ( 'DATA_FISCAL'
                                                                      , p_custom => 'bgcolor="777777"' )
                                                || dsp_planilha.campo ( 'MOVTO_E_S'
                                                                      , p_custom => 'bgcolor="777777"' )
                                                || dsp_planilha.campo ( 'NORM_DEV'
                                                                      , p_custom => 'bgcolor="777777"' )
                                                || dsp_planilha.campo ( 'IDENT_DOCTO'
                                                                      , p_custom => 'bgcolor="777777"' )
                                                || dsp_planilha.campo ( 'IDENT_FIS_JUR'
                                                                      , p_custom => 'bgcolor="777777"' )
                                                || dsp_planilha.campo ( 'NUM_DOCFIS'
                                                                      , p_custom => 'bgcolor="777777"' )
                                                || dsp_planilha.campo ( 'SERIE_DOCFIS'
                                                                      , p_custom => 'bgcolor="777777"' )
                                                || dsp_planilha.campo ( 'SUB_SERIE_DOCFIS'
                                                                      , p_custom => 'bgcolor="777777"' )
                                                || dsp_planilha.campo ( 'CHAVE_ACESSO'
                                                                      , p_custom => 'bgcolor="777777"' )
                                                || --
                                                   dsp_planilha.campo ( 'COD_ESTAB'
                                                                      , p_custom => 'bgcolor="777777"' )
                                                || dsp_planilha.campo ( 'DATA_FISCAL'
                                                                      , p_custom => 'bgcolor="777777"' )
                                                || dsp_planilha.campo ( 'MOVTO_E_S'
                                                                      , p_custom => 'bgcolor="777777"' )
                                                || dsp_planilha.campo ( 'NORM_DEV'
                                                                      , p_custom => 'bgcolor="777777"' )
                                                || dsp_planilha.campo ( 'IDENT_DOCTO'
                                                                      , p_custom => 'bgcolor="777777"' )
                                                || dsp_planilha.campo ( 'IDENT_FIS_JUR'
                                                                      , p_custom => 'bgcolor="777777"' )
                                                || dsp_planilha.campo ( 'NUM_DOCFIS'
                                                                      , p_custom => 'bgcolor="777777"' )
                                                || dsp_planilha.campo ( 'SERIE_DOCFIS'
                                                                      , p_custom => 'bgcolor="777777"' )
                                                || dsp_planilha.campo ( 'SUB_SERIE_DOCFIS'
                                                                      , p_custom => 'bgcolor="777777"' )
                                                || dsp_planilha.campo ( 'CHAVE_ACESSO'
                                                                      , p_custom => 'bgcolor="777777"' )
                                              , --
                                                'h' )
                         , ptipo => 2 );
            COMMIT;

            -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            FOR a IN crs_cd ( mcod_empresa
                            , p_periodo ) LOOP
                lib_proc.add ( dsp_planilha.linha (
                                                       dsp_planilha.campo ( a.cod_empresa )
                                                    || dsp_planilha.campo ( a.cod_estab )
                                                    || dsp_planilha.campo ( a.saida_entrada )
                                                    || dsp_planilha.campo ( a.finalidade )
                                                    || dsp_planilha.campo ( a.cfop )
                                                    || dsp_planilha.campo ( dsp_planilha.texto ( a.cst ) )
                                                    || dsp_planilha.campo ( a.vlr_contab_item )
                                                    || dsp_planilha.campo ( a.base_trib )
                                                    || dsp_planilha.campo ( a.vlr_icms )
                                                    || dsp_planilha.campo ( a.aliq )
                                                    || dsp_planilha.campo ( a.isenta )
                                                    || dsp_planilha.campo ( a.outras )
                                                    || dsp_planilha.campo ( a.reducao )
                                                    || dsp_planilha.campo ( a.icms_st )
                                                    || dsp_planilha.campo ( a.ipi_n_destac )
                                                    || dsp_planilha.campo ( a.vlr_despesa )
                                                    || dsp_planilha.campo ( a.bate_vlr_item_com_bases )
                                                    || dsp_planilha.campo ( a.linhas )
                                                    || dsp_planilha.campo ( a.regras_validacao )
                                                    || dsp_planilha.campo ( a.acao )
                                                    || dsp_planilha.campo ( a.concatenacao )
                                                    || dsp_planilha.campo ( a.min_ident_docto_fiscal )
                                                    || dsp_planilha.campo ( a.max_ident_docto_fiscal )
                                                    || dsp_planilha.campo ( a.criterios_basicos )
                                                    || --
                                                       dsp_planilha.campo ( a.cod_estab1 )
                                                    || dsp_planilha.campo ( a.data_fiscal )
                                                    || dsp_planilha.campo ( a.movto_e_s )
                                                    || dsp_planilha.campo ( a.norm_dev )
                                                    || dsp_planilha.campo ( a.ident_docto )
                                                    || dsp_planilha.campo ( a.ident_fis_jur )
                                                    || dsp_planilha.campo ( a.num_docfis )
                                                    || dsp_planilha.campo ( a.serie_docfis )
                                                    || dsp_planilha.campo ( a.sub_serie_docfis )
                                                    || dsp_planilha.campo ( dsp_planilha.texto ( a.identif_docfis ) )
                                                    || --
                                                       dsp_planilha.campo ( a.cod_estab2 )
                                                    || dsp_planilha.campo ( a.data_fiscal2 )
                                                    || dsp_planilha.campo ( a.movto_e_s2 )
                                                    || dsp_planilha.campo ( a.norm_dev2 )
                                                    || dsp_planilha.campo ( a.ident_docto2 )
                                                    || dsp_planilha.campo ( a.ident_fis_jur2 )
                                                    || dsp_planilha.campo ( a.num_docfis2 )
                                                    || dsp_planilha.campo ( a.serie_docfis2 )
                                                    || dsp_planilha.campo ( a.sub_serie_docfis2 )
                                                    || dsp_planilha.campo ( dsp_planilha.texto ( a.identif_docfis2 ) )
                                                  , p_custom => 'height="17"'
                               )
                             , ptipo => 2 );

                COMMIT;
            END LOOP;

            lib_proc.add ( dsp_planilha.tabela_fim ( )
                         , ptipo => 2 );

            COMMIT;
        END IF;

        dbms_application_info.set_module ( $$plsql_unit
                                         , 'PASSO 4 - lojas' );

        -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        -- RELATÓRIO DE LOJAS ESPECÍFICAS
        IF v_lojas.COUNT > 0 THEN
            lib_proc.add_log ( 'Inicia Processamento de Lojas:'
                             , 1 );
            v_tipo := 3;
            COMMIT;

            FOR c IN ( SELECT COLUMN_VALUE
                         FROM TABLE ( v_lojas ) ) LOOP
                dbms_application_info.set_module ( $$plsql_unit
                                                 , 'PASSO 4 lojas - ' || c.COLUMN_VALUE );

                lib_proc.add_log ( '           ' || c.COLUMN_VALUE
                                 , 1 );
                v_cods := '_' || c.COLUMN_VALUE;

                lib_proc.add_tipo ( mproc_id
                                  , v_tipo
                                  ,    'VALIDA_LOJA'
                                    || v_cods
                                    || '_'
                                    || TO_CHAR ( p_periodo
                                               , 'YYYYMM' )
                                    || '.xls'
                                  , 2 );
                lib_proc.add ( dsp_planilha.header ( )
                             , ptipo => v_tipo );
                lib_proc.add ( dsp_planilha.tabela_inicio ( )
                             , ptipo => v_tipo );
                lib_proc.add ( dsp_planilha.linha (    dsp_planilha.campo ( 'COD_EMPRESA' )
                                                    || dsp_planilha.campo ( 'UF_ESTAB' )
                                                    || dsp_planilha.campo ( 'SAIDA_ENTRADA' )
                                                    || dsp_planilha.campo ( 'FINALIDADE' )
                                                    || dsp_planilha.campo ( 'CFOP' )
                                                    || dsp_planilha.campo ( 'CST' )
                                                    || dsp_planilha.campo ( 'VLR_CONTAB_ITEM' )
                                                    || dsp_planilha.campo ( 'BASE_TRIB' )
                                                    || dsp_planilha.campo ( 'VLR_ICMS' )
                                                    || dsp_planilha.campo ( 'ALIQ' )
                                                    || dsp_planilha.campo ( 'ISENTA' )
                                                    || dsp_planilha.campo ( 'OUTRAS' )
                                                    || dsp_planilha.campo ( 'REDUCAO' )
                                                    || dsp_planilha.campo ( 'ICMS_ST' )
                                                    || dsp_planilha.campo ( 'IPI_N_DESTAC' )
                                                    || dsp_planilha.campo ( 'VLR_DESPESA' )
                                                    || dsp_planilha.campo ( 'BATE_VLR_ITEM_COM_BASES' )
                                                    || dsp_planilha.campo ( 'LINHAS' )
                                                    || dsp_planilha.campo ( 'REGRAS_VALIDACAO' )
                                                    || dsp_planilha.campo ( 'ACAO'
                                                                          , p_custom => 'bgcolor="RED"' )
                                                    || dsp_planilha.campo ( 'CONCATENACAO' )
                                                    || dsp_planilha.campo ( 'MIN_IDENT_DOCTO_FISCAL' )
                                                    || dsp_planilha.campo ( 'MAX_IDENT_DOCTO_FISCAL' )
                                                    || dsp_planilha.campo ( 'CRITERIOS_BASICOS'
                                                                          , p_custom => 'bgcolor="777777"' )
                                                    || --
                                                       dsp_planilha.campo ( 'COD_ESTAB'
                                                                          , p_custom => 'bgcolor="777777"' )
                                                    || dsp_planilha.campo ( 'DATA_FISCAL'
                                                                          , p_custom => 'bgcolor="777777"' )
                                                    || dsp_planilha.campo ( 'MOVTO_E_S'
                                                                          , p_custom => 'bgcolor="777777"' )
                                                    || dsp_planilha.campo ( 'NORM_DEV'
                                                                          , p_custom => 'bgcolor="777777"' )
                                                    || dsp_planilha.campo ( 'IDENT_DOCTO'
                                                                          , p_custom => 'bgcolor="777777"' )
                                                    || dsp_planilha.campo ( 'IDENT_FIS_JUR'
                                                                          , p_custom => 'bgcolor="777777"' )
                                                    || dsp_planilha.campo ( 'NUM_DOCFIS'
                                                                          , p_custom => 'bgcolor="777777"' )
                                                    || dsp_planilha.campo ( 'SERIE_DOCFIS'
                                                                          , p_custom => 'bgcolor="777777"' )
                                                    || dsp_planilha.campo ( 'SUB_SERIE_DOCFIS'
                                                                          , p_custom => 'bgcolor="777777"' )
                                                    || dsp_planilha.campo ( 'CHAVE_ACESSO'
                                                                          , p_custom => 'bgcolor="777777"' )
                                                    || --
                                                       dsp_planilha.campo ( 'COD_ESTAB'
                                                                          , p_custom => 'bgcolor="777777"' )
                                                    || dsp_planilha.campo ( 'DATA_FISCAL'
                                                                          , p_custom => 'bgcolor="777777"' )
                                                    || dsp_planilha.campo ( 'MOVTO_E_S'
                                                                          , p_custom => 'bgcolor="777777"' )
                                                    || dsp_planilha.campo ( 'NORM_DEV'
                                                                          , p_custom => 'bgcolor="777777"' )
                                                    || dsp_planilha.campo ( 'IDENT_DOCTO'
                                                                          , p_custom => 'bgcolor="777777"' )
                                                    || dsp_planilha.campo ( 'IDENT_FIS_JUR'
                                                                          , p_custom => 'bgcolor="777777"' )
                                                    || dsp_planilha.campo ( 'NUM_DOCFIS'
                                                                          , p_custom => 'bgcolor="777777"' )
                                                    || dsp_planilha.campo ( 'SERIE_DOCFIS'
                                                                          , p_custom => 'bgcolor="777777"' )
                                                    || dsp_planilha.campo ( 'SUB_SERIE_DOCFIS'
                                                                          , p_custom => 'bgcolor="777777"' )
                                                    || dsp_planilha.campo ( 'CHAVE_ACESSO'
                                                                          , p_custom => 'bgcolor="777777"' )
                                                  , --
                                                    'h' )
                             , ptipo => v_tipo );
                COMMIT;

                -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                FOR a IN crs_lojas ( mcod_empresa
                                   , p_periodo
                                   , c.COLUMN_VALUE ) LOOP
                    SELECT    '    || '' OR (DSP.COD_ESTADO = '''''''''
                           || a.uf_estab
                           || ''''''''' AND DDF.MOVTO_E_S'
                           || DECODE ( a.saida_entrada, 'S', '=', '<>' )
                           || '''''''''9'''''''''
                           || ' AND XNO.COD_NATUREZA_OP'
                           || CASE
                                  WHEN a.finalidade IS NULL THEN ' IS NULL'
                                  ELSE '=''''''''' || a.finalidade || ''''''''''
                              END
                           || ' AND XCF.COD_CFO'
                           || CASE WHEN a.cfop IS NULL THEN ' IS NULL' ELSE '=''''''''' || a.cfop || '''''''''' END
                           || ' AND STB.COD_SITUACAO_B'
                           || CASE WHEN a.cst IS NULL THEN ' IS NULL' ELSE '=''''''''' || a.cst || '''''''''' END
                           || ' AND SIGN(DIM.VLR_BASE_ICMS_1) = '
                           || a.base_trib
                           || ' AND SIGN(DIM.VLR_TRIBUTO_ICMS) = '
                           || a.vlr_icms
                           || ' AND SIGN(DIM.ALIQ_TRIBUTO_ICMS) = '
                           || a.aliq
                           || ' AND SIGN(DIM.VLR_BASE_ICMS_2) = '
                           || a.isenta
                           || ' AND SIGN(DIM.VLR_BASE_ICMS_3) = '
                           || a.outras
                           || ' AND SIGN(DIM.VLR_BASE_ICMS_4) = '
                           || a.reducao
                           || ' AND SIGN(DIM.VLR_CONTAB_ITEM) = '
                           || a.vlr_contab_item
                           || ' AND SIGN(DIM.VLR_TRIBUTO_ICMSS) = '
                           || a.icms_st
                           || ' AND SIGN(DIM.VLR_IPI_NDESTAC) = '
                           || a.ipi_n_destac
                           || ' AND DIM.VLR_CONTAB_ITEM - DIM.VLR_BASE_ICMS_1 - DIM.VLR_BASE_ICMS_2 - DIM.VLR_BASE_ICMS_3 - DIM.VLR_BASE_ICMS_4 - DIM.VLR_TRIBUTO_ICMSS - DIM.VLR_OUTRAS - DIM.VLR_IPI_NDESTAC '
                           || CASE WHEN a.bate_vlr_item_com_bases = 'SIM' THEN '=' ELSE '<>' END
                           || ' 0) '''
                      INTO v_criterios
                      FROM DUAL;

                    lib_proc.add ( dsp_planilha.linha (
                                                           dsp_planilha.campo ( a.cod_empresa )
                                                        || dsp_planilha.campo ( a.uf_estab )
                                                        || dsp_planilha.campo ( a.saida_entrada )
                                                        || dsp_planilha.campo ( a.finalidade )
                                                        || dsp_planilha.campo ( a.cfop )
                                                        || dsp_planilha.campo ( dsp_planilha.texto ( a.cst ) )
                                                        || dsp_planilha.campo ( a.vlr_contab_item )
                                                        || dsp_planilha.campo ( a.base_trib )
                                                        || dsp_planilha.campo ( a.vlr_icms )
                                                        || dsp_planilha.campo ( a.aliq )
                                                        || dsp_planilha.campo ( a.isenta )
                                                        || dsp_planilha.campo ( a.outras )
                                                        || dsp_planilha.campo ( a.reducao )
                                                        || dsp_planilha.campo ( a.icms_st )
                                                        || dsp_planilha.campo ( a.ipi_n_destac )
                                                        || dsp_planilha.campo ( a.vlr_despesa )
                                                        || dsp_planilha.campo ( a.bate_vlr_item_com_bases )
                                                        || dsp_planilha.campo ( a.linhas )
                                                        || dsp_planilha.campo ( a.regras_validacao )
                                                        || dsp_planilha.campo ( a.acao )
                                                        || dsp_planilha.campo ( a.concatenacao )
                                                        || dsp_planilha.campo ( a.min_ident_docto_fiscal )
                                                        || dsp_planilha.campo ( a.max_ident_docto_fiscal )
                                                        || dsp_planilha.campo ( v_criterios )
                                                        || --
                                                           dsp_planilha.campo ( a.cod_estab )
                                                        || dsp_planilha.campo ( a.data_fiscal )
                                                        || dsp_planilha.campo ( a.movto_e_s )
                                                        || dsp_planilha.campo ( a.norm_dev )
                                                        || dsp_planilha.campo ( a.ident_docto )
                                                        || dsp_planilha.campo ( a.ident_fis_jur )
                                                        || dsp_planilha.campo ( a.num_docfis )
                                                        || dsp_planilha.campo ( a.serie_docfis )
                                                        || dsp_planilha.campo ( a.sub_serie_docfis )
                                                        || dsp_planilha.campo (
                                                                                dsp_planilha.texto ( a.identif_docfis )
                                                           )
                                                        || --
                                                           dsp_planilha.campo ( a.cod_estab2 )
                                                        || dsp_planilha.campo ( a.data_fiscal2 )
                                                        || dsp_planilha.campo ( a.movto_e_s2 )
                                                        || dsp_planilha.campo ( a.norm_dev2 )
                                                        || dsp_planilha.campo ( a.ident_docto2 )
                                                        || dsp_planilha.campo ( a.ident_fis_jur2 )
                                                        || dsp_planilha.campo ( a.num_docfis2 )
                                                        || dsp_planilha.campo ( a.serie_docfis2 )
                                                        || dsp_planilha.campo ( a.sub_serie_docfis2 )
                                                        || dsp_planilha.campo (
                                                                                dsp_planilha.texto (
                                                                                                     a.identif_docfis2
                                                                                )
                                                           )
                                                      , p_custom => 'height="17"'
                                   )
                                 , ptipo => v_tipo );

                    COMMIT;
                END LOOP;

                lib_proc.add ( dsp_planilha.tabela_fim ( )
                             , ptipo => v_tipo );

                v_tipo := v_tipo + 1;

                COMMIT;
            END LOOP;

            COMMIT;
        END IF;

        dbms_application_info.set_module ( $$plsql_unit
                                         , 'FIM' );

        lib_proc.close ( );

        COMMIT;
        RETURN mproc_id;
    EXCEPTION
        WHEN OTHERS THEN
            lib_proc.add_log ( 'Erro não tratado: ' || dbms_utility.format_error_backtrace
                             , 1 );
            lib_proc.add_log ( 'SQLERRM: ' || SQLERRM
                             , 1 );
            lib_proc.add ( 'ERRO!' );
            lib_proc.add ( dbms_utility.format_error_backtrace );
            lib_proc.close;
            COMMIT;
            RETURN mproc_id;
    END;
END dsp_valida_cproc;
/
SHOW ERRORS;
