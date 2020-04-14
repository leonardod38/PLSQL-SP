Prompt Package Body DSP_VALIDA_LISTA_CPROC;
--
-- DSP_VALIDA_LISTA_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dsp_valida_lista_cproc
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
        RETURN '02 -Relatório de análise por perfil de Documento Fiscal (Valida)';
    END;

    FUNCTION tipo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Valida';
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
        RETURN 'Relatório de análise por perfil de Documento Fiscal (Valida)';
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

    PROCEDURE loga ( p_i_texto IN VARCHAR2
                   , p_i_dttm IN BOOLEAN DEFAULT TRUE )
    IS
        vtexto VARCHAR2 ( 1024 );
    BEGIN
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

    FUNCTION executar ( p_periodo DATE
                      , p_estabelecimento lib_proc.vartab )
        RETURN INTEGER
    IS
        mproc_id INTEGER;
        v_count INTEGER;
    BEGIN
        -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        mproc_id := lib_proc.new ( $$plsql_unit );

        COMMIT;

        dbms_application_info.set_module ( $$plsql_unit
                                         , 'PASSO 1' );

        -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        -- Carrega tabela temporaria para selecionar os estabelecimentos

        DELETE FROM dsp_valida_estab;

        COMMIT;

        FOR i IN 1 .. p_estabelecimento.COUNT LOOP
            INSERT INTO msaf.dsp_valida_estab
                SELECT 'Lojas'
                     , cod_estab
                  FROM msaf.dsp_estabelecimento_v
                 WHERE ( cod_estab = SUBSTR ( p_estabelecimento ( i )
                                            , 2 )
                     OR cod_estado = SUBSTR ( p_estabelecimento ( i )
                                            , 3 ) )
                   AND cod_estab NOT IN ( SELECT cod_filtro
                                            FROM msaf.dsp_valida_estab );
        END LOOP;

        COMMIT;
        dbms_application_info.set_module ( $$plsql_unit
                                         , 'PASSO 2 lojas UF' );

        SELECT COUNT ( 1 )
          INTO v_count
          FROM msaf.dsp_valida_estab;

        loga ( 'dsp_valida_estab ' || v_count );

        v_count := 0;

        -- gravação dos perfis GTT
        FOR c
            IN ( SELECT dim.ident_docto_fiscal
                      , dim.ident_item_merc
                      , dim.cod_empresa
                      , dim.cod_estab
                      , dim.data_fiscal
                      , dim.movto_e_s
                      , dim.norm_dev
                      , dim.ident_docto
                      , dim.ident_fis_jur
                      , dim.num_docfis
                      , dim.serie_docfis
                      , dim.sub_serie_docfis
                      , dim.discri_item
                      , dim.ident_produto
                      , esd.cod_estado uf_estab
                      , DECODE ( ddf.movto_e_s, '9', 'S', 'E' ) saida_entrada
                      , xno.cod_natureza_op finalidade
                      , xcf.cod_cfo cfop
                      , stb.cod_situacao_b cst
                      , SIGN ( dim.vlr_contab_item ) vlr_contab_item
                      , SIGN ( dim.vlr_base_icms_1 ) base_trib
                      , SIGN ( dim.vlr_tributo_icms ) vlr_icms
                      , SIGN ( dim.aliq_tributo_icms ) aliq
                      , SIGN ( dim.vlr_base_icms_2 ) isenta
                      , SIGN ( dim.vlr_base_icms_3 ) outras
                      , SIGN ( dim.vlr_base_icms_4 ) reducao
                      , SIGN ( dim.vlr_tributo_icmss ) icms_st
                      , SIGN ( dim.vlr_ipi_ndestac ) ipi_n_destac
                      , SIGN ( dim.vlr_outras ) vlr_despesa
                      , CASE
                            WHEN SIGN (
                                          dim.vlr_contab_item
                                        - dim.vlr_base_icms_1
                                        - dim.vlr_base_icms_2
                                        - dim.vlr_base_icms_3
                                        - dim.vlr_base_icms_4
                                        - dim.vlr_tributo_icmss
                                        - dim.vlr_ipi_ndestac
                                 ) = 0 THEN
                                'SIM'
                            ELSE
                                'NAO'
                        END
                            bate_vlr_item_com_bases
                   FROM msaf.dwt_docto_fiscal ddf
                      , msaf.dwt_itens_merc dim
                      , msaf.x04_pessoa_fis_jur pfj
                      , msaf.y2026_sit_trb_uf_b stb
                      , msaf.x2012_cod_fiscal xcf
                      , msaf.x2006_natureza_op xno
                      , msaf.estabelecimento esb
                      , msafi.dsp_estabelecimento dspe
                      , msaf.estado esd
                  WHERE ddf.cod_empresa = msafi.dpsp.v_empresa
                    AND ddf.cod_empresa = dspe.cod_empresa
                    AND ddf.cod_estab = dspe.cod_estab
                    AND ddf.data_fiscal BETWEEN p_periodo AND LAST_DAY ( p_periodo )
                    AND ddf.serie_docfis <> 'ECF'
                    AND ddf.situacao = 'N'
                    -- filtra estabelecimentos
                    AND ddf.cod_estab IN ( SELECT cod_filtro
                                             FROM dsp_valida_estab )
                    /*         AND (CASE
                                 -- por UF
                                  WHEN substr(v_cod_estab, 1, 2) = 'UF' AND dspe.tipo = 'L' AND
                                  substr(v_cod_estab, 3, 2) = esd.cod_estado THEN 1
                                 -- por estabelecimento
                                  WHEN substr(v_cod_estab, 1, 2) <> 'UF' AND
                                  v_cod_estab = dspe.cod_estab THEN 1
                                 -- nao se encaixam no filtro
                                  ELSE 0 END) = 1
                    */
                    AND dim.ident_docto_fiscal = ddf.ident_docto_fiscal
                    AND pfj.ident_fis_jur = dim.ident_fis_jur
                    AND stb.ident_situacao_b(+) = dim.ident_situacao_b
                    AND xcf.ident_cfo(+) = dim.ident_cfo
                    AND xno.ident_natureza_op(+) = dim.ident_natureza_op
                    AND esb.cod_empresa = ddf.cod_empresa
                    AND esb.cod_estab = ddf.cod_estab
                    AND esd.ident_estado = esb.ident_estado
                    AND NOT EXISTS
                            (SELECT 1
                               FROM msafi.dsp_auto_valida dav
                              WHERE dav.cod_empresa = 'DSP'
                                AND DECODE ( dav.cod_estab, 'LOJ', dav.cod_estab, dspe.cod_estab ) = dav.cod_estab
                                AND DECODE ( dav.cod_estado, 'XX', esd.cod_estado, dav.cod_estado ) = esd.cod_estado
                                AND dav.entrada_saida = DECODE ( ddf.movto_e_s, '9', 'S', 'E' )
                                AND dav.cod_natureza_op = xno.cod_natureza_op
                                AND dav.cod_cfo = xcf.cod_cfo
                                AND dav.cod_situacao_b = stb.cod_situacao_b
                                AND dav.icms = SIGN ( dim.vlr_tributo_icms )
                                AND dav.aliq_icms = SIGN ( dim.aliq_tributo_icms )
                                AND dav.bc_icms = SIGN ( dim.vlr_base_icms_1 )
                                AND dav.isentas = SIGN ( dim.vlr_base_icms_2 )
                                AND dav.outras = SIGN ( dim.vlr_base_icms_3 )
                                AND dav.reducao = SIGN ( dim.vlr_base_icms_4 )
                                AND   dim.vlr_contab_item
                                    - dim.vlr_base_icms_1
                                    - dim.vlr_base_icms_2
                                    - dim.vlr_base_icms_3
                                    - dim.vlr_base_icms_4
                                    - dim.vlr_tributo_icmss
                                    - dim.vlr_ipi_ndestac = 0) ) LOOP
            INSERT INTO msafi.dpsp_valida_filtro_gtt ( ident_docto_fiscal
                                                     , ident_item_merc
                                                     , cod_empresa
                                                     , cod_estab
                                                     , data_fiscal
                                                     , movto_e_s
                                                     , norm_dev
                                                     , ident_docto
                                                     , ident_fis_jur
                                                     , num_docfis
                                                     , serie_docfis
                                                     , sub_serie_docfis
                                                     , discri_item
                                                     , ident_produto
                                                     , uf_estab
                                                     , saida_entrada
                                                     , finalidade
                                                     , cfop
                                                     , cst
                                                     , vlr_contab_item
                                                     , base_trib
                                                     , vlr_icms
                                                     , aliq
                                                     , isenta
                                                     , outras
                                                     , reducao
                                                     , icms_st
                                                     , ipi_n_destac
                                                     , vlr_despesa
                                                     , bate_vlr_item_com_bases )
                 VALUES ( c.ident_docto_fiscal
                        , c.ident_item_merc
                        , c.cod_empresa
                        , c.cod_estab
                        , c.data_fiscal
                        , c.movto_e_s
                        , c.norm_dev
                        , c.ident_docto
                        , c.ident_fis_jur
                        , c.num_docfis
                        , c.serie_docfis
                        , c.sub_serie_docfis
                        , c.discri_item
                        , c.ident_produto
                        , c.uf_estab
                        , c.saida_entrada
                        , c.finalidade
                        , c.cfop
                        , c.cst
                        , c.vlr_contab_item
                        , c.base_trib
                        , c.vlr_icms
                        , c.aliq
                        , c.isenta
                        , c.outras
                        , c.reducao
                        , c.icms_st
                        , c.ipi_n_destac
                        , c.vlr_despesa
                        , c.bate_vlr_item_com_bases );

            COMMIT;
        END LOOP;

        SELECT COUNT ( 1 )
          INTO v_count
          FROM msafi.dpsp_valida_filtro_gtt;

        loga ( 'dpsp_valida_filtro_gtt ' || v_count );

        v_count := 0;

        -- gravação dos perfis definitiva
        FOR c IN ( SELECT mproc_id proc_id
                        , DENSE_RANK ( )
                              OVER ( ORDER BY
                                         uf_estab
                                       , saida_entrada
                                       , finalidade
                                       , cfop
                                       , cst
                                       , vlr_contab_item
                                       , base_trib
                                       , vlr_icms
                                       , aliq
                                       , isenta
                                       , outras
                                       , reducao
                                       , icms_st
                                       , ipi_n_destac
                                       , vlr_despesa
                                       , bate_vlr_item_com_bases )
                              seq_lista
                        , ident_docto_fiscal
                        , ident_item_merc
                        , cod_empresa
                        , cod_estab
                        , data_fiscal
                        , movto_e_s
                        , norm_dev
                        , ident_docto
                        , ident_fis_jur
                        , num_docfis
                        , serie_docfis
                        , sub_serie_docfis
                        , discri_item
                        , ident_produto
                        , uf_estab
                        , saida_entrada
                        , finalidade
                        , cfop
                        , cst
                        , vlr_contab_item
                        , base_trib
                        , vlr_icms
                        , aliq
                        , isenta
                        , outras
                        , reducao
                        , icms_st
                        , ipi_n_destac
                        , vlr_despesa
                        , bate_vlr_item_com_bases
                        , SYSDATE data_criacao
                        , musuario cod_usuario
                     FROM msafi.dpsp_valida_filtro_gtt ) LOOP
            INSERT INTO msafi.dpsp_valida_filtro ( proc_id
                                                 , seq_lista
                                                 , ident_docto_fiscal
                                                 , ident_item_merc
                                                 , cod_empresa
                                                 , cod_estab
                                                 , data_fiscal
                                                 , movto_e_s
                                                 , norm_dev
                                                 , ident_docto
                                                 , ident_fis_jur
                                                 , num_docfis
                                                 , serie_docfis
                                                 , sub_serie_docfis
                                                 , discri_item
                                                 , ident_produto
                                                 , uf_estab
                                                 , saida_entrada
                                                 , finalidade
                                                 , cfop
                                                 , cst
                                                 , vlr_contab_item
                                                 , base_trib
                                                 , vlr_icms
                                                 , aliq
                                                 , isenta
                                                 , outras
                                                 , reducao
                                                 , icms_st
                                                 , ipi_n_destac
                                                 , vlr_despesa
                                                 , bate_vlr_item_com_bases
                                                 , data_criacao
                                                 , cod_usuario )
                 VALUES ( c.proc_id
                        , c.seq_lista
                        , c.ident_docto_fiscal
                        , c.ident_item_merc
                        , c.cod_empresa
                        , c.cod_estab
                        , c.data_fiscal
                        , c.movto_e_s
                        , c.norm_dev
                        , c.ident_docto
                        , c.ident_fis_jur
                        , c.num_docfis
                        , c.serie_docfis
                        , c.sub_serie_docfis
                        , c.discri_item
                        , c.ident_produto
                        , c.uf_estab
                        , c.saida_entrada
                        , c.finalidade
                        , c.cfop
                        , c.cst
                        , c.vlr_contab_item
                        , c.base_trib
                        , c.vlr_icms
                        , c.aliq
                        , c.isenta
                        , c.outras
                        , c.reducao
                        , c.icms_st
                        , c.ipi_n_destac
                        , c.vlr_despesa
                        , c.bate_vlr_item_com_bases
                        , c.data_criacao
                        , c.cod_usuario );

            COMMIT;
        END LOOP;

        SELECT COUNT ( 1 )
          INTO v_count
          FROM msafi.dpsp_valida_filtro;

        loga ( 'dpsp_valida_filtro ' || v_count );

        v_count := 0;


        /*
        SELECT seq_lista,
               uf_estab,
               saida_entrada,
               finalidade,
               cfop,
               cst,
               vlr_contab_item,
               base_trib,
               vlr_icms,
               aliq,
               isenta,
               outras,
               reducao,
               icms_st,
               ipi_n_destac,
               vlr_despesa,
               bate_vlr_item_com_bases,
               COUNT(1)
          FROM msafi.dpsp_valida_filtro
         GROUP BY seq_lista,
                  uf_estab,
                  saida_entrada,
                  finalidade,
                  cfop,
                  cst,
                  vlr_contab_item,
                  base_trib,
                  vlr_icms,
                  aliq,
                  isenta,
                  outras,
                  reducao,
                  icms_st,
                  ipi_n_destac,
                  vlr_despesa,
                  bate_vlr_item_com_bases
        */


        /*lib_proc.add_tipo(mproc_id,
                              1,
                              'VALIDA_LOJ_UF' || v_cods || '_' ||
                              to_char(p_periodo, 'YYYYMM') || '.xls',
                              2);
            lib_proc.add(dsp_planilha.header(), ptipo => 1);
            lib_proc.add(dsp_planilha.tabela_inicio(), ptipo => 1);
            lib_proc.add(dsp_planilha.linha(dsp_planilha.campo('COD_EMPRESA') ||
                                            dsp_planilha.campo('UF_ESTAB') ||
                                            dsp_planilha.campo('SAIDA_ENTRADA') ||
                                            dsp_planilha.campo('FINALIDADE') ||
                                            dsp_planilha.campo('CFOP') ||
                                            dsp_planilha.campo('CST') ||
                                            dsp_planilha.campo('VLR_CONTAB_ITEM') ||
                                            dsp_planilha.campo('BASE_TRIB') ||
                                            dsp_planilha.campo('VLR_ICMS') ||
                                            dsp_planilha.campo('ALIQ') ||
                                            dsp_planilha.campo('ISENTA') ||
                                            dsp_planilha.campo('OUTRAS') ||
                                            dsp_planilha.campo('REDUCAO') ||
                                            dsp_planilha.campo('ICMS_ST') ||
                                            dsp_planilha.campo('IPI_N_DESTAC') ||
                                            dsp_planilha.campo('VLR_DESPESA') ||
                                            dsp_planilha.campo('BATE_VLR_ITEM_COM_BASES') ||
                                            dsp_planilha.campo('LINHAS') ||
                                            dsp_planilha.campo('REGRAS_VALIDACAO') ||
                                            dsp_planilha.campo('ACAO',
                                                               p_custom => 'bgcolor="RED"') ||
                                            dsp_planilha.campo('CONCATENACAO') ||
                                            dsp_planilha.campo('MIN_IDENT_DOCTO_FISCAL') ||
                                            dsp_planilha.campo('MAX_IDENT_DOCTO_FISCAL') ||
                                            dsp_planilha.campo('CRITERIOS_BASICOS',
                                                               p_custom => 'bgcolor="777777"') ||
                                            --
                                            dsp_planilha.campo('COD_ESTAB',
                                                               p_custom => 'bgcolor="777777"') ||
                                            dsp_planilha.campo('DATA_FISCAL',
                                                               p_custom => 'bgcolor="777777"') ||
                                            dsp_planilha.campo('MOVTO_E_S',
                                                               p_custom => 'bgcolor="777777"') ||
                                            dsp_planilha.campo('NORM_DEV',
                                                               p_custom => 'bgcolor="777777"') ||
                                            dsp_planilha.campo('IDENT_DOCTO',
                                                               p_custom => 'bgcolor="777777"') ||
                                            dsp_planilha.campo('IDENT_FIS_JUR',
                                                               p_custom => 'bgcolor="777777"') ||
                                            dsp_planilha.campo('NUM_DOCFIS',
                                                               p_custom => 'bgcolor="777777"') ||
                                            dsp_planilha.campo('SERIE_DOCFIS',
                                                               p_custom => 'bgcolor="777777"') ||
                                            dsp_planilha.campo('SUB_SERIE_DOCFIS',
                                                               p_custom => 'bgcolor="777777"') ||
                                            dsp_planilha.campo('IDENTIF_DOCFIS',
                                                               p_custom => 'bgcolor="777777"') ||
                                            --
                                            dsp_planilha.campo('COD_ESTAB',
                                                               p_custom => 'bgcolor="777777"') ||
                                            dsp_planilha.campo('DATA_FISCAL',
                                                               p_custom => 'bgcolor="777777"') ||
                                            dsp_planilha.campo('MOVTO_E_S',
                                                               p_custom => 'bgcolor="777777"') ||
                                            dsp_planilha.campo('NORM_DEV',
                                                               p_custom => 'bgcolor="777777"') ||
                                            dsp_planilha.campo('IDENT_DOCTO',
                                                               p_custom => 'bgcolor="777777"') ||
                                            dsp_planilha.campo('IDENT_FIS_JUR',
                                                               p_custom => 'bgcolor="777777"') ||
                                            dsp_planilha.campo('NUM_DOCFIS',
                                                               p_custom => 'bgcolor="777777"') ||
                                            dsp_planilha.campo('SERIE_DOCFIS',
                                                               p_custom => 'bgcolor="777777"') ||
                                            dsp_planilha.campo('SUB_SERIE_DOCFIS',
                                                               p_custom => 'bgcolor="777777"') ||
                                            dsp_planilha.campo('IDENTIF_DOCFIS',
                                                               p_custom => 'bgcolor="777777"'),
                                            --
                                            'h'),
                         ptipo => 1);
            COMMIT;
            -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            FOR a IN crs_lojas_uf(mcod_empresa, p_periodo) LOOP

              dbms_application_info.set_module($$PLSQL_UNIT,
                                               'PASSO 2 lojas UF ' || a.uf_estab);

              SELECT '    || '' OR (DSP.COD_ESTADO = ''''''''' || a.uf_estab ||
                     ''''''''' AND DDF.MOVTO_E_S' ||
                     decode(a.saida_entrada, 'S', '=', '<>') || '''''''''9''''''''' ||
                     ' AND XNO.COD_NATUREZA_OP' || CASE
                       WHEN a.finalidade IS NULL THEN
                        ' IS NULL'
                       ELSE
                        '=''''''''' || a.finalidade || ''''''''''
                     END || ' AND XCF.COD_CFO' || CASE
                       WHEN a.cfop IS NULL THEN
                        ' IS NULL'
                       ELSE
                        '=''''''''' || a.cfop || ''''''''''
                     END || ' AND STB.COD_SITUACAO_B' || CASE
                       WHEN a.cst IS NULL THEN
                        ' IS NULL'
                       ELSE
                        '=''''''''' || a.cst || ''''''''''
                     END || ' AND SIGN(DIM.VLR_BASE_ICMS_1) = ' || a.base_trib ||
                     ' AND SIGN(DIM.VLR_TRIBUTO_ICMS) = ' || a.vlr_icms ||
                     ' AND SIGN(DIM.ALIQ_TRIBUTO_ICMS) = ' || a.aliq ||
                     ' AND SIGN(DIM.VLR_BASE_ICMS_2) = ' || a.isenta ||
                     ' AND SIGN(DIM.VLR_BASE_ICMS_3) = ' || a.outras ||
                     ' AND SIGN(DIM.VLR_BASE_ICMS_4) = ' || a.reducao ||
                     ' AND SIGN(DIM.VLR_CONTAB_ITEM) = ' || a.vlr_contab_item ||
                     ' AND SIGN(DIM.VLR_TRIBUTO_ICMSS) = ' || a.icms_st ||
                     ' AND SIGN(DIM.VLR_IPI_NDESTAC) = ' || a.ipi_n_destac ||
                     ' AND DIM.VLR_CONTAB_ITEM - DIM.VLR_BASE_ICMS_1 - DIM.VLR_BASE_ICMS_2 - DIM.VLR_BASE_ICMS_3 - DIM.VLR_BASE_ICMS_4 - DIM.VLR_TRIBUTO_ICMSS - DIM.VLR_IPI_NDESTAC ' || CASE
                       WHEN a.bate_vlr_item_com_bases = 'SIM' THEN
                        '='
                       ELSE
                        '<>'
                     END || ' 0) '''
                INTO v_criterios
                FROM dual;

              lib_proc.add(dsp_planilha.linha(dsp_planilha.campo(a.cod_empresa) ||
                                              dsp_planilha.campo(a.uf_estab) ||
                                              dsp_planilha.campo(a.saida_entrada) ||
                                              dsp_planilha.campo(a.finalidade) ||
                                              dsp_planilha.campo(a.cfop) ||
                                              dsp_planilha.campo(dsp_planilha.texto(a.cst)) ||
                                              dsp_planilha.campo(a.vlr_contab_item) ||
                                              dsp_planilha.campo(a.base_trib) ||
                                              dsp_planilha.campo(a.vlr_icms) ||
                                              dsp_planilha.campo(a.aliq) ||
                                              dsp_planilha.campo(a.isenta) ||
                                              dsp_planilha.campo(a.outras) ||
                                              dsp_planilha.campo(a.reducao) ||
                                              dsp_planilha.campo(a.icms_st) ||
                                              dsp_planilha.campo(a.ipi_n_destac) ||
                                              dsp_planilha.campo(a.vlr_despesa) ||
                                              dsp_planilha.campo(a.bate_vlr_item_com_bases) ||
                                              dsp_planilha.campo(a.linhas) ||
                                              dsp_planilha.campo(a.regras_validacao) ||
                                              dsp_planilha.campo(a.acao) ||
                                              dsp_planilha.campo(a.concatenacao) ||
                                              dsp_planilha.campo(a.min_ident_docto_fiscal) ||
                                              dsp_planilha.campo(a.max_ident_docto_fiscal) ||
                                              dsp_planilha.campo(v_criterios) ||
                                              --
                                              dsp_planilha.campo(a.cod_estab) ||
                                              dsp_planilha.campo(a.data_fiscal) ||
                                              dsp_planilha.campo(a.movto_e_s) ||
                                              dsp_planilha.campo(a.norm_dev) ||
                                              dsp_planilha.campo(a.ident_docto) ||
                                              dsp_planilha.campo(a.ident_fis_jur) ||
                                              dsp_planilha.campo(a.num_docfis) ||
                                              dsp_planilha.campo(a.serie_docfis) ||
                                              dsp_planilha.campo(a.sub_serie_docfis) ||
                                              dsp_planilha.campo(a.identif_docfis) ||
                                              --
                                              dsp_planilha.campo(a.cod_estab2) ||
                                              dsp_planilha.campo(a.data_fiscal2) ||
                                              dsp_planilha.campo(a.movto_e_s2) ||
                                              dsp_planilha.campo(a.norm_dev2) ||
                                              dsp_planilha.campo(a.ident_docto2) ||
                                              dsp_planilha.campo(a.ident_fis_jur2) ||
                                              dsp_planilha.campo(a.num_docfis2) ||
                                              dsp_planilha.campo(a.serie_docfis2) ||
                                              dsp_planilha.campo(a.sub_serie_docfis2) ||
                                              dsp_planilha.campo(a.identif_docfis2),
                                              p_custom => 'height="17"'),
                           ptipo => 1);
              COMMIT;
            END LOOP;

            lib_proc.add(dsp_planilha.tabela_fim(), ptipo => 1);

            COMMIT;

            dbms_application_info.set_module($$PLSQL_UNIT, 'FIM');
        */
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
END dsp_valida_lista_cproc;
/
SHOW ERRORS;
