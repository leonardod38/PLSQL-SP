Prompt Package Body MSAF_VETORIT_REL_CFO_CPROC;
--
-- MSAF_VETORIT_REL_CFO_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY msaf_vetorit_rel_cfo_cproc
IS
    ------------------------------------------------------------------------------
    -- Modifications:
    --  Who            When         What
    --  -------------- ------------ ----------------------------------------------
    ------------------------------------------------------------------------------

    mcod_empresa empresa.cod_empresa%TYPE;
    mcod_estab estabelecimento.cod_estab%TYPE;

    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );
    BEGIN
        EXECUTE IMMEDIATE 'alter session set nls_numeric_characters = '',.''';

        -- Titulo..........: Caption a ser mostrado na tela
        -- Tipo da Variavel: Conforme definido no Oracle
        -- Tipo de Controle: Textbox, Listbox, Combobox, Radiobutton ou Checkbox
        -- Mandatorio......: S ou N
        -- Dafault.........: Valor Default para o Campo
        -- Máscara.........: dd/mm/yyyy
        -- Valores.........: Comando SQL para a lista (Código, Descrição)

        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        mcod_estab := NVL ( lib_parametros.recuperar ( 'ESTABELECIMENTO' ), '' );

        lib_proc.add_param ( pstr
                           ,    LPAD ( ' '
                                     , 54
                                     , ' ' )
                             || '***  Notas Fiscais por CFOP - Padrão  ***'
                           , 'varchar2'
                           , 'text'
                           , 'N'
                           , NULL
                           , NULL );

        -- :1 UF
        lib_proc.add_param ( pstr
                           , 'UF'
                           , 'Varchar2'
                           , 'Combobox'
                           , 'N'
                           , ' '
                           , NULL
                           , 'SELECT cod_estado, cod_estado||'' - ''||descricao FROM estado ORDER BY 1'
                           , 'N' );
        -- 2) Estabelecimento
        lib_proc.add_param (
                             pstr
                           , 'Estabelecimento'
                           , 'Varchar2'
                           , 'Combobox'
                           , 'N'
                           , ''
                           , NULL
                           ,    'SELECT e.cod_estab, e.cod_estab||'' - ''||e.razao_social '
                             || 'FROM estabelecimento e , estado est '
                             || 'WHERE est.ident_estado = e.ident_estado '
                             || 'AND   est.cod_estado = :2 '
                             || 'AND   e.cod_empresa = '''
                             || mcod_empresa
                             || ''' UNION SELECT ''0'', ''* Todos *'' FROM dual '
                           , 'N'
        );
        -- :3 Periodo inicial
        lib_proc.add_param ( pstr
                           , 'Data Inicial'
                           , 'Date'
                           , 'Textbox'
                           , 'N'
                           , NULL
                           , 'DD/MM/YYYY' );
        -- :4 Periodo Final
        lib_proc.add_param ( pstr
                           , 'Data Final'
                           , 'Date'
                           , 'Textbox'
                           , 'N'
                           , NULL
                           , 'DD/MM/YYYY' );
        -- :5
        lib_proc.add_param ( pstr
                           , 'Considerar Notas de Serviço com CFOPs do Ajuste Sinief 03/04'
                           , 'Varchar2'
                           , 'Checkbox'
                           , 'N'
                           , 'N'
                           , NULL
                           , NULL
                           , 'N' );
        -- :6
        lib_proc.add_param ( pstr
                           , 'Inscrição Estadual Única'
                           , 'Varchar2'
                           , 'Checkbox'
                           , 'N'
                           , 'N'
                           , NULL
                           , NULL
                           , 'N' );
        -- :7
        lib_proc.add_param (
                             pstr
                           , 'Seleção de CFOPs'
                           , 'Varchar2'
                           , 'multiselect'
                           , 'S'
                           , NULL
                           , NULL
                           ,    'SELECT DISTINCT X2012_COD_FISCAL.COD_CFO, MAX(X2012_COD_FISCAL.COD_CFO||'' - ''||X2012_COD_FISCAL.DESCRICAO) '
                             || 'FROM X2012_COD_FISCAL '
                             || 'GROUP BY X2012_COD_FISCAL.COD_CFO ORDER BY 2 '
        );
        RETURN pstr;
    END;

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        -- Nome da janela
        RETURN 'Relatório de Notas Fiscais por CFOP';
    END;

    FUNCTION tipo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Relatório Fiscal';
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
        RETURN 'Relatório de Notas Fiscais por CFOP Padrão';
    END;

    FUNCTION modulo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Processos Customizados';
    END;

    FUNCTION classificacao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Processos Customizados';
    END;

    FUNCTION orientacao
        RETURN VARCHAR2
    IS
    BEGIN
        -- Orientação do Papel
        RETURN ' LANDSCAPE ';
    END;

    FUNCTION executar ( puf VARCHAR2
                      , pestab VARCHAR2
                      , pdataini DATE
                      , pdatafim DATE
                      , psinief VARCHAR2
                      , pinscrestunica VARCHAR2
                      , pcfop lib_proc.vartab )
        RETURN INTEGER
    IS
        -- Variaveis de Trabalho
        mproc_id INTEGER;

        /* VARIAVEL PARA RECUPERACAO DO NUMERO DE OPERACOES POR COMMIT */
        cont_w NUMBER := 0;

        linha_w VARCHAR2 ( 10000 );
        vtab VARCHAR2 ( 1 ) := CHR ( 9 );
        cont_cfop NUMBER ( 4 );
        num_processo_ini_w log_processo.num_processo%TYPE;
        num_processo_w log_processo.num_processo%TYPE;
        status_w NUMBER;
        usuario_w log_processo.cod_usuario%TYPE;
        compute_32_w VARCHAR2 ( 1000 );
        cpf_cnpj_w VARCHAR2 ( 18 );
        estabw estabelecimento.cod_estab%TYPE;
        establogw estabelecimento.cod_estab%TYPE;
    BEGIN
        -- Crio um novo processo
        IF mcod_empresa IS NULL THEN
            mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        END IF;

        mproc_id :=
            lib_proc.new ( 'MSAF_VETORIT_REL_CFO_CPROC'
                         , 48
                         , 150 );

        lib_proc.add_log ( LPAD ( '-'
                                , 150
                                , '-' )
                         , 0 );
        lib_proc.add_log (    'Geração iniciada:'
                           || TO_CHAR ( SYSDATE
                                      , 'dd/mm/yyyy hh:mi:ss' )
                         , 0 );

        lib_proc.add_tipo ( mproc_id
                          , 2
                          , 'RELATORIO_DE_NOTAS_POR_CFO_PADRAO.xls'
                          , 2 ); --2 arquivo

        lib_proc.add_log ( LPAD ( '-'
                                , 150
                                , '-' )
                         , 0 );

        usuario_w := lib_parametros.recuperar ( 'USUARIO' );

        estabw := pestab;

        IF estabw = '0' THEN
            estabw := '%';
            establogw := 'Todos';
        ELSE
            establogw := estabw;
        END IF;

        lib_proc.add_log ( 'Data Inicial: ' || pdataini
                         , 0 );
        lib_proc.add_log ( 'Data Final: ' || pdatafim
                         , 0 );

        --log por estabelecimento
        lib_proc.add_log ( 'Empresa: ' || mcod_empresa
                         , 0 );
        lib_proc.add_log ( 'Estabelecimento(s): ' || establogw
                         , 0 );

        linha_w := 'Empresa' || vtab;
        linha_w := linha_w || 'Razao Social Empresa' || vtab;
        linha_w := linha_w || 'Estabelecimento' || vtab;
        linha_w := linha_w || 'Razao Social Estabelecimento' || vtab;
        linha_w := linha_w || 'UF' || vtab;
        linha_w := linha_w || 'IE' || vtab;
        --- Linha_w := Linha_w || 'Pessoa Fisica Juridica'         || vTab;
        linha_w := linha_w || 'Razao Social' || vtab;
        linha_w := linha_w || 'CNPJ CPF' || vtab;
        linha_w := linha_w || 'NF' || vtab;
        linha_w := linha_w || 'Serie NF' || vtab;
        linha_w := linha_w || 'Data Fiscal' || vtab;
        linha_w := linha_w || 'NF AR' || vtab;
        linha_w := linha_w || 'CFOP' || vtab;
        linha_w := linha_w || 'Num Item NF' || vtab;
        linha_w := linha_w || 'Valor Contab Item' || vtab;
        linha_w := linha_w || 'Vlr_Base_ICMS ' || vtab;
        linha_w := linha_w || 'Vlr_Tributo_ICMS' || vtab;
        linha_w := linha_w || 'Vlr_Isentas_ICMS' || vtab;
        linha_w := linha_w || 'Vlr_Outras_ICMS' || vtab;
        linha_w := linha_w || 'Vlr_Tributo_IPI ' || vtab;
        linha_w := linha_w || 'Vlr_Base_IPI' || vtab;
        linha_w := linha_w || 'Vlr_Isentas_IPI' || vtab;
        linha_w := linha_w || 'Vlr_Outras_IPI' || vtab;
        linha_w := linha_w || 'Vlr_Contab_compl.' || vtab;

        lib_proc.add ( plinha => linha_w
                     , ppag => NULL
                     , plin => NULL
                     , ptipo => 2
                     , pchaveordenacao => 0 );

        FOR cont_cfop IN 1 .. pcfop.COUNT LOOP
            BEGIN
                FOR cur IN ( WITH dwt_w
                                  AS (SELECT dwt_docto_fiscal.cod_empresa
                                           , dwt_docto_fiscal.cod_estab
                                           , data_fiscal
                                           , movto_e_s
                                           , norm_dev
                                           , ident_docto
                                           , ident_fis_jur
                                           , num_docfis
                                           , serie_docfis
                                           , sub_serie_docfis
                                           , ind_situacao_esp
                                           , ident_modelo
                                           , num_autentic_nfe
                                           , num_controle_docto
                                           , cod_class_doc_fis
                                           , --cod_cfo,
                                             ident_docto_fiscal
                                           , /* vlr_contab_item,
                                              vlr_tributo_icms,
                                              vlr_base_icms_1,
                                              vlr_base_icms_2,
                                              vlr_base_icms_3,
                                              vlr_base_icms_4,
                                              vlr_tributo_ipi,
                                              vlr_base_ipi_1,
                                              vlr_base_ipi_2,
                                              vlr_base_ipi_3,
                                              vlr_base_ipi_4,*/
                                             --vlr_contab_compl,
                                              ( SELECT razao_social
                                                  FROM empresa
                                                 WHERE empresa.cod_empresa = dwt_docto_fiscal.cod_empresa )
                                                 razao_social_emp
                                           , estab.razao_social razao_social_estab
                                           , estab.cgc
                                           , --uf_fornec,
                                             estab.ident_estado
                                        FROM dwt_docto_fiscal
                                           , estabelecimento estab
                                       WHERE dwt_docto_fiscal.cod_empresa = mcod_empresa
                                         AND ( dwt_docto_fiscal.cod_estab ) IN ( SELECT icp.cod_estab cod_estab
                                                                                   FROM icp_insc_est_centr icp
                                                                                  WHERE icp.cod_empresa = mcod_empresa
                                                                                    AND icp.cod_estab_centr LIKE estabw
                                                                                    AND pinscrestunica = 'S'
                                                                                UNION ALL
                                                                                SELECT e.cod_estab cod_estab
                                                                                  FROM estabelecimento e
                                                                                 WHERE pinscrestunica = 'N'
                                                                                   AND e.cod_empresa = mcod_empresa
                                                                                   AND e.cod_estab LIKE estabw )
                                         AND v_data_trab BETWEEN pdataini AND pdatafim
                                         AND situacao <> 'S'
                                         AND dwt_docto_fiscal.cod_empresa = estab.cod_empresa
                                         AND dwt_docto_fiscal.cod_estab = estab.cod_estab
                                         AND EXISTS
                                                 (SELECT 1
                                                    FROM estado
                                                   WHERE cod_estado LIKE puf
                                                     AND estado.ident_estado = estab.ident_estado))
                            SELECT dwt_doc.cod_empresa
                                 , dwt_doc.razao_social_emp razao_social_emp
                                 , dwt_doc.cod_estab
                                 , dwt_doc.razao_social_estab
                                 , dwt_doc.cgc
                                 , dwt_doc.num_docfis
                                 , dwt_doc.serie_docfis
                                 , dwt_doc.sub_serie_docfis
                                 , dwt_doc.data_fiscal
                                 , dwt_itm.ident_produto
                                 , dwt_itm.ident_nbm
                                 , dwt_itm.ident_fis_jur
                                 , dwt_itm.num_item
                                 , x2012_cod_fiscal.cod_cfo
                                 , dwt_itm.vlr_unit
                                 , NVL ( dwt_itm.quantidade, 0 ) quantidade
                                 , dwt_itm.vlr_tributo_icms
                                 , ( SELECT cod_produto
                                       FROM x2013_produto
                                      WHERE ident_produto = dwt_itm.ident_produto )
                                       cod_produto
                                 , ( SELECT descricao
                                       FROM x2013_produto
                                      WHERE ident_produto = dwt_itm.ident_produto )
                                       descricao
                                 , ( SELECT cod_nbm
                                       FROM x2043_cod_nbm
                                      WHERE ident_nbm = dwt_itm.ident_nbm )
                                       cod_nbm
                                 , ( SELECT cod_fis_jur
                                       FROM x04_pessoa_fis_jur
                                      WHERE ident_fis_jur = dwt_doc.ident_fis_jur )
                                       cod_fis_jur
                                 , ( SELECT razao_social
                                       FROM x04_pessoa_fis_jur
                                      WHERE ident_fis_jur = dwt_doc.ident_fis_jur )
                                       razao_social_x04
                                 , ( SELECT cpf_cgc
                                       FROM x04_pessoa_fis_jur
                                      WHERE ident_fis_jur = dwt_doc.ident_fis_jur )
                                       cpf_cgc
                                 , dwt_itm.vlr_contab_item
                                 , dwt_doc.ind_situacao_esp
                                 , ( SELECT compl_cfop
                                       FROM x2081_extensao_cfo
                                      WHERE ident_natureza_op = dwt_itm.ident_natureza_op
                                        AND ident_cfo = dwt_itm.ident_cfo )
                                       compl_cfop
                                 , ( SELECT cod_natureza_op
                                       FROM x2006_natureza_op
                                      WHERE ident_natureza_op = dwt_itm.ident_natureza_op )
                                       cod_natureza_op
                                 , '' inscricao_estadual
                                 , dwt_itm.descricao_compl
                                 , ( SELECT cod_modelo
                                       FROM x2024_modelo_docto
                                      WHERE ident_modelo = dwt_doc.ident_modelo )
                                       cod_modelo
                                 , dwt_doc.num_autentic_nfe
                                 , ( SELECT est.cod_estado
                                       FROM estado est
                                          , x04_pessoa_fis_jur x04
                                      WHERE est.ident_estado = x04.ident_estado
                                        AND x04.ident_fis_jur = dwt_doc.ident_fis_jur )
                                       uf_fornec
                                 , ( SELECT insc_estadual
                                       FROM x04_pessoa_fis_jur
                                      WHERE ident_fis_jur = dwt_doc.ident_fis_jur )
                                       insc_estadual
                                 , dwt_doc.num_controle_docto
                                 , dwt_itm.vlr_contab_compl
                                 , dwt_itm.vlr_base_icms_1
                                 , dwt_itm.vlr_base_icms_2
                                 , dwt_itm.vlr_base_icms_3
                                 , dwt_itm.vlr_base_icms_4
                                 , dwt_itm.aliq_tributo_icms
                                 , dwt_itm.vlr_tributo_icmss
                                 , dwt_itm.vlr_icms_ndestac
                                 , dwt_itm.vlr_ipi_ndestac
                                 , ( SELECT NVL ( cod_situacao_a, '' )
                                       FROM y2025_sit_trb_uf_a
                                      WHERE ident_situacao_a = dwt_itm.ident_situacao_a )
                                       AS cod_situacao_a
                                 , ( SELECT NVL ( cod_situacao_b, '' )
                                       FROM y2026_sit_trb_uf_b
                                      WHERE ident_situacao_b = dwt_itm.ident_situacao_b )
                                       AS cod_situacao_b
                                 , x2007_medida.cod_medida
                                 , dwt_itm.vlr_base_ipi_1
                                 , dwt_itm.vlr_base_ipi_2
                                 , dwt_itm.vlr_base_ipi_3
                                 , dwt_itm.vlr_base_ipi_4
                                 , dwt_itm.aliq_tributo_ipi
                                 , dwt_itm.vlr_tributo_ipi
                              FROM dwt_itens_merc dwt_itm
                                 , dwt_w dwt_doc
                                 , x2012_cod_fiscal
                                 , x2007_medida
                             WHERE dwt_itm.ident_cfo = x2012_cod_fiscal.ident_cfo
                               AND dwt_doc.cod_empresa = dwt_itm.cod_empresa
                               AND dwt_doc.cod_estab = dwt_itm.cod_estab
                               AND dwt_doc.data_fiscal = dwt_itm.data_fiscal
                               AND dwt_doc.movto_e_s = dwt_itm.movto_e_s
                               AND dwt_doc.norm_dev = dwt_itm.norm_dev
                               AND dwt_doc.ident_docto = dwt_itm.ident_docto
                               AND dwt_doc.ident_fis_jur = dwt_itm.ident_fis_jur
                               AND dwt_doc.num_docfis = dwt_itm.num_docfis
                               AND dwt_doc.serie_docfis = dwt_itm.serie_docfis
                               AND dwt_doc.sub_serie_docfis = dwt_itm.sub_serie_docfis
                               AND ( dwt_itm.ident_medida = x2007_medida.ident_medida )
                               AND ( UPPER ( x2012_cod_fiscal.cod_cfo ) IN pcfop ( cont_cfop ) )
                               AND ( ( SUBSTR ( x2012_cod_fiscal.cod_cfo
                                              , 1
                                              , 1 ) IN ( '1'
                                                       , '2'
                                                       , '3' )
                                  AND dwt_doc.cod_class_doc_fis IN ( '1'
                                                                   , '3' ) )
                                 OR ( SUBSTR ( x2012_cod_fiscal.cod_cfo
                                             , 1
                                             , 1 ) IN ( '5'
                                                      , '6'
                                                      , '7' )
                                 AND dwt_doc.cod_class_doc_fis IN ( '1'
                                                                  , '3'
                                                                  , '4' ) ) )
                            UNION ALL
                            SELECT dwt_doc.cod_empresa
                                 , dwt_doc.razao_social_emp razao_social_emp
                                 , dwt_doc.cod_estab
                                 , dwt_doc.razao_social_estab
                                 , dwt_doc.cgc
                                 , dwt_doc.num_docfis
                                 , dwt_doc.serie_docfis
                                 , dwt_doc.sub_serie_docfis
                                 , dwt_doc.data_fiscal
                                 , dwt_its.ident_produto
                                 , 0
                                 , dwt_doc.ident_fis_jur
                                 , 0
                                 , x2012_cod_fiscal.cod_cfo
                                 , dwt_its.vlr_unit
                                 , NVL ( dwt_its.quantidade, 0 ) quantidade
                                 , dwt_its.vlr_tributo_icms
                                 , ''
                                 , '** Item de servico **'
                                 , '' cod_nbm
                                 , ( SELECT cod_fis_jur
                                       FROM x04_pessoa_fis_jur
                                      WHERE ident_fis_jur = dwt_doc.ident_fis_jur )
                                       cod_fis_jur
                                 , ( SELECT razao_social
                                       FROM x04_pessoa_fis_jur
                                      WHERE ident_fis_jur = dwt_doc.ident_fis_jur )
                                       razao_social_x04
                                 , ( SELECT cpf_cgc
                                       FROM x04_pessoa_fis_jur
                                      WHERE ident_fis_jur = dwt_doc.ident_fis_jur )
                                       cpf_cgc
                                 , dwt_its.vlr_tot vlr_contab_item
                                 , dwt_doc.ind_situacao_esp
                                 , ( SELECT compl_cfop
                                       FROM x2081_extensao_cfo
                                      WHERE ident_natureza_op = dwt_its.ident_natureza_op
                                        AND ident_cfo = dwt_its.ident_cfo )
                                       compl_cfop
                                 , ( SELECT cod_natureza_op
                                       FROM x2006_natureza_op
                                      WHERE ident_natureza_op = dwt_its.ident_natureza_op )
                                       cod_natureza_op
                                 , '' inscricao_estadual
                                 , dwt_its.descricao_compl
                                 , ( SELECT cod_modelo
                                       FROM x2024_modelo_docto
                                      WHERE ident_modelo = dwt_doc.ident_modelo )
                                       cod_modelo
                                 , dwt_doc.num_autentic_nfe
                                 , ( SELECT est.cod_estado
                                       FROM estado est
                                          , x04_pessoa_fis_jur x04
                                      WHERE est.ident_estado = x04.ident_estado
                                        AND x04.ident_fis_jur = dwt_doc.ident_fis_jur )
                                       uf_fornec
                                 , ( SELECT insc_estadual
                                       FROM x04_pessoa_fis_jur
                                      WHERE ident_fis_jur = dwt_doc.ident_fis_jur )
                                       insc_estadual
                                 , dwt_doc.num_controle_docto
                                 , 0.00 vlr_contab_compl
                                 , 0.00 vlr_base_icms_1
                                 , 0.00 vlr_base_icms_2
                                 , 0.00 vlr_base_icms_3
                                 , 0.00 vlr_base_icms_4
                                 , 0.0000 aliq_tributo_icms
                                 , 0.00 vlr_tributo_icmss
                                 , 0.00 vlr_icms_ndestac
                                 , 0.00 vlr_ipi_ndestac
                                 , '' AS cod_situacao_a
                                 , '' AS cod_situacao_b
                                 , '' AS cod_medida
                                 , 0.00 vlr_base_ipi_1
                                 , 0.00 vlr_base_ipi_2
                                 , 0.00 vlr_base_ipi_3
                                 , 0.00 vlr_base_ipi_4
                                 , 0.0000 aliq_tributo_ipi
                                 , 0 vlr_tributo_ipi
                              FROM dwt_itens_serv dwt_its
                                 , dwt_w dwt_doc
                                 , x2012_cod_fiscal
                             WHERE ( dwt_its.ident_cfo = x2012_cod_fiscal.ident_cfo )
                               AND dwt_doc.cod_empresa = dwt_its.cod_empresa
                               AND dwt_doc.cod_estab = dwt_its.cod_estab
                               AND dwt_doc.data_fiscal = dwt_its.data_fiscal
                               AND dwt_doc.movto_e_s = dwt_its.movto_e_s
                               AND dwt_doc.norm_dev = dwt_its.norm_dev
                               AND dwt_doc.ident_docto = dwt_its.ident_docto
                               AND dwt_doc.ident_fis_jur = dwt_its.ident_fis_jur
                               AND dwt_doc.num_docfis = dwt_its.num_docfis
                               AND dwt_doc.serie_docfis = dwt_its.serie_docfis
                               AND dwt_doc.sub_serie_docfis = dwt_its.sub_serie_docfis
                               AND ( UPPER ( x2012_cod_fiscal.cod_cfo ) IN pcfop ( cont_cfop ) )
                               AND ( ( x2012_cod_fiscal.cod_cfo IN ( SELECT cfop.cod_cfo
                                                                       FROM prt_cfo_uf_msaf cfop
                                                                      WHERE cfop.cod_empresa = dwt_doc.cod_empresa
                                                                        AND cfop.ident_estado = dwt_doc.ident_estado
                                                                        AND cfop.cod_param = 415 )
                                  AND dwt_doc.cod_class_doc_fis = '2'
                                  AND psinief = 'S' )
                                 OR ( ( SUBSTR ( x2012_cod_fiscal.cod_cfo
                                               , 1
                                               , 1 ) IN ( '1'
                                                        , '2'
                                                        , '3' )
                                   AND dwt_doc.cod_class_doc_fis IN ( '3' ) )
                                  OR ( SUBSTR ( x2012_cod_fiscal.cod_cfo
                                              , 1
                                              , 1 ) IN ( '5'
                                                       , '6'
                                                       , '7' )
                                  AND dwt_doc.cod_class_doc_fis IN ( '3'
                                                                   , '4' ) ) ) )
                            ORDER BY 1
                                   , 4
                                   , 14
                                   , 10
                                   , 7
                                   , 8
                                   , 9
                                   , 40 ) LOOP
                    IF cur.ind_situacao_esp = '1' THEN
                        cur.vlr_contab_item := 0;
                        cur.vlr_tributo_icms := 0;
                        cur.vlr_unit := 0;
                    END IF;

                    IF cur.cod_situacao_a = ''
                    OR cur.cod_situacao_b = '' THEN
                        compute_32_w := '';
                    ELSE
                        compute_32_w := cur.cod_situacao_a || ' - ' || cur.cod_situacao_b;
                    END IF;

                    IF LENGTH ( cur.cpf_cgc ) <= 11 THEN
                        cpf_cnpj_w :=
                            RPAD ( NVL ( lib_format.formata_campo ( cur.cpf_cgc
                                                                  , '000.000.000-00'
                                                                  , 0 )
                                       , ' ' )
                                 , 18
                                 , ' ' );
                    ELSE
                        cpf_cnpj_w :=
                            RPAD ( NVL ( lib_format.formata_campo ( cur.cpf_cgc
                                                                  , '00.000.000/0000-00'
                                                                  , 0 )
                                       , ' ' )
                                 , 18
                                 , ' ' );
                    END IF;

                    linha_w :=
                           cur.cod_empresa
                        || CHR ( 9 )
                        || cur.razao_social_emp
                        || CHR ( 9 )
                        || cur.cod_estab
                        || CHR ( 9 )
                        || cur.razao_social_estab
                        || CHR ( 9 )
                        || cur.uf_fornec
                        || CHR ( 9 )
                        || cur.insc_estadual
                        || --CHR(9) || Cur.cod_fis_jur               ||
                           CHR ( 9 )
                        || cur.razao_social_x04
                        || CHR ( 9 )
                        || cpf_cnpj_w
                        || CHR ( 9 )
                        || cur.num_docfis
                        || CHR ( 9 )
                        || cur.serie_docfis
                        || CHR ( 9 )
                        || cur.data_fiscal
                        || CHR ( 9 )
                        || cur.num_controle_docto
                        || CHR ( 9 )
                        || cur.cod_cfo
                        || CHR ( 9 )
                        || cur.num_item
                        || CHR ( 9 )
                        || lib_format.r2 ( COALESCE ( cur.vlr_contab_item
                                                    , 0 )
                                         , 18 )
                        || CHR ( 9 )
                        || lib_format.r2 ( COALESCE ( cur.vlr_base_icms_1
                                                    , 0 )
                                         , 18 )
                        || CHR ( 9 )
                        || lib_format.r2 ( COALESCE ( cur.vlr_tributo_icms
                                                    , 0 )
                                         , 18 )
                        || CHR ( 9 )
                        || lib_format.r2 ( COALESCE ( cur.vlr_base_icms_2
                                                    , 0 )
                                         , 18 )
                        || CHR ( 9 )
                        || lib_format.r2 ( COALESCE ( cur.vlr_base_icms_3
                                                    , 0 )
                                         , 18 )
                        || CHR ( 9 )
                        || lib_format.r2 ( COALESCE ( cur.vlr_tributo_ipi
                                                    , 0 )
                                         , 18 )
                        || CHR ( 9 )
                        || lib_format.r2 ( COALESCE ( cur.vlr_base_ipi_1
                                                    , 0 )
                                         , 18 )
                        || CHR ( 9 )
                        || lib_format.r2 ( COALESCE ( cur.vlr_base_ipi_2
                                                    , 0 )
                                         , 18 )
                        || CHR ( 9 )
                        || lib_format.r2 ( COALESCE ( cur.vlr_base_ipi_3
                                                    , 0 )
                                         , 18 )
                        || CHR ( 9 )
                        || lib_format.r2 ( COALESCE ( cur.vlr_contab_compl
                                                    , 0 )
                                         , 18 );
                    cont_w := cont_w + 1;
                    lib_proc.add ( plinha => linha_w
                                 , ppag => NULL
                                 , plin => NULL
                                 , ptipo => 2
                                 , pchaveordenacao => cont_w );
                END LOOP;
            END;
        END LOOP;

        lib_proc.add_log ( LPAD ( '-'
                                , 150
                                , '-' )
                         , 0 );
        lib_proc.add_log ( 'Log de Processo - MSAF_VETORIT_REL_CFO_CPROC'
                         , 0 );

        lib_proc.add_log ( LPAD ( '-'
                                , 150
                                , '-' )
                         , 0 );
        lib_proc.add_log (    'Geração finalizada:'
                           || TO_CHAR ( SYSDATE
                                      , 'dd/mm/yyyy hh:mi:ss' )
                         , 0 );
        lib_proc.add_log ( LPAD ( '-'
                                , 150
                                , '-' )
                         , 0 );

        lib_proc.close;
        RETURN mproc_id;
    EXCEPTION
        WHEN OTHERS THEN
            lib_proc.add_log ( 'Erro não previsto pelo sistema (MSAF_VETORIT_REL_CFO_CPROC). ' || SQLERRM
                             , 0 );
            lib_proc.add_log ( dbms_utility.format_error_stack
                             , 0 );
            lib_proc.add_log ( dbms_utility.format_error_backtrace
                             , 0 );
            lib_proc.add_log ( ''
                             , 1 );
            lib_proc.close ( );
            RETURN mproc_id;
    END;
END msaf_vetorit_rel_cfo_cproc;
/
SHOW ERRORS;
