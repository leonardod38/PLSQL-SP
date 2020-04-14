Prompt Package Body CONF_NF_ENTR_CPROC;
--
-- CONF_NF_ENTR_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY conf_nf_entr_cproc
IS
    mcod_empresa empresa.cod_empresa%TYPE;

    ----------------------------------------------------------------------------------------------------

    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );
        vvalores VARCHAR2 ( 512 );
    BEGIN
        vvalores :=
               ' SELECT estab.cod_estab, razao_social '
            || ' FROM estabelecimento estab, estado uf, ict_par_incent ict '
            || ' WHERE estab.ident_estado = uf.ident_estado '
            || ' AND estab.cod_empresa = ict.cod_empresa '
            || ' AND estab.cod_estab = ict.cod_estab '
            || ' AND estab.cod_empresa = '''
            || mcod_empresa
            || ''' AND uf.cod_estado = ''PE'' '
            || ' ORDER BY 1';

        -- :1
        lib_proc.add_param ( pstr
                           , 'Estabelecimento:'
                           , 'Varchar2'
                           , 'Textbox'
                           , 'S'
                           , NULL
                           , '      '
                           , vvalores
                           , 'S' );

        -- :2
        lib_proc.add_param ( pstr
                           , 'Data Inicial:'
                           , 'Date'
                           , 'Textbox'
                           , 'S'
                           , TO_DATE (    '01'
                                       || TO_CHAR ( SYSDATE
                                                  , 'MM/YYYY' )
                                     , 'dd/mm/yyyy' )
                           , 'DD/MM/YYYY'
                           , NULL
                           , 'S' );

        -- :3
        lib_proc.add_param ( pstr
                           , 'Data Final:'
                           , 'Date'
                           , 'Textbox'
                           , 'S'
                           , LAST_DAY ( SYSDATE )
                           , 'DD/MM/YYYY'
                           , NULL
                           , 'S' );

        -- :4
        lib_proc.add_param ( pstr
                           , 'Tipo de Livro'
                           , 'Varchar2'
                           , 'RadioButton'
                           , 'S'
                           , 1
                           , NULL
                           , '1=Incentivados,2=Não Incentivado' );

        vvalores :=
               ' SELECT cod_grp_incent,cod_grp_incent || '' - '' || dsc_grp_incent '
            || ' FROM ict_grp_incent '
            || ' WHERE cod_empresa = '''
            || mcod_empresa
            || ''' AND cod_estab = :1 '
            || ' ORDER BY 1 ';

        -- :5
        lib_proc.add_param ( pstr
                           , 'Grupo de Incentivo: '
                           , 'Varchar2'
                           , 'Combobox'
                           , 'N'
                           , NULL
                           , NULL
                           , vvalores
                           , 'S'
                           , phabilita => ':4 NOT IN (2)' );

        RETURN pstr;
    END;

    ----------------------------------------------------------------------------------------------------
    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Relatório de Conferência das Notas Fiscais de Entrada';
    END;

    ----------------------------------------------------------------------------------------------------
    FUNCTION tipo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Relatório';
    END;

    ----------------------------------------------------------------------------------------------------
    FUNCTION versao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN '1.0';
    END;

    ----------------------------------------------------------------------------------------------------
    FUNCTION descricao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Relatório de Conferência das Notas Fiscais de Entrada';
    END;

    ----------------------------------------------------------------------------------------------------
    FUNCTION modulo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'PRODEPE';
    END;

    ----------------------------------------------------------------------------------------------------
    FUNCTION classificacao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'ESTADUAL - PRODEPE';
    END;

    ----------------------------------------------------------------------------------------------------
    FUNCTION executar ( p_cod_estab VARCHAR2
                      , p_periodo_ini DATE
                      , p_periodo_fim DATE
                      , p_tipo_rel VARCHAR2
                      , p_cod_grp_incent VARCHAR2 )
        RETURN INTEGER
    IS
        /* cursores */

        CURSOR cnotas ( p_cod_empresa VARCHAR2
                      , p_cod_estab VARCHAR2
                      , p_cod_grp_incent VARCHAR2
                      , p_data_ini DATE
                      , p_data_fim DATE )
        IS
            -- Documentos com itens
            SELECT guia.cod_grp_incent
                 , docto.data_fiscal
                 , docto.serie_docfis
                 , docto.sub_serie_docfis
                 , docto.num_docfis
                 , TO_CHAR ( item.num_item ) item
                 , cfo.cod_cfo
                 , nat.cod_natureza_op
                 , prod.descricao produto
                 , pfj.razao_social emitente
                 , item.vlr_contab_item vlr_contab_item
                 , item.vlr_tributo_icms vlr_tributo_icms
                 , item.vlr_fecp_icms vlr_fecp_icms
                 , guia.ind_incent
              FROM dwt_docto_fiscal docto
                 , dwt_itens_merc item
                 , ict_guia_incent guia
                 , x2012_cod_fiscal cfo
                 , x2006_natureza_op nat
                 , x2013_produto prod
                 , x04_pessoa_fis_jur pfj
             WHERE docto.cod_empresa = p_cod_empresa
               AND docto.cod_estab = p_cod_estab
               AND docto.data_fiscal BETWEEN p_data_ini AND p_data_fim
               AND docto.cod_class_doc_fis IN ( '1'
                                              , '3' )
               AND docto.movto_e_s <> '9'
               AND docto.situacao <> 'S'
               AND docto.ind_transf_cred = '0'
               AND NVL ( docto.ind_situacao_esp, ' ' ) NOT IN ( '1'
                                                              , '2'
                                                              , '8' )
               AND item.ident_docto_fiscal = docto.ident_docto_fiscal
               AND cfo.ident_cfo(+) = item.ident_cfo
               AND nat.ident_natureza_op(+) = item.ident_natureza_op
               AND prod.ident_produto = item.ident_produto
               AND pfj.ident_fis_jur = docto.ident_fis_jur
               AND guia.cod_empresa(+) = p_cod_empresa
               AND guia.cod_estab(+) = p_cod_estab
               AND guia.ident_docto_fiscal(+) = item.ident_docto_fiscal
               AND guia.ident_itens_merc(+) = item.ident_item_merc
               AND ( ( guia.cod_grp_incent IS NULL
                  AND p_cod_grp_incent IS NULL )
                 OR ( guia.cod_grp_incent = p_cod_grp_incent ) )
            UNION ALL
            -- Documentos sem itens
            SELECT guia.cod_grp_incent
                 , -- 1
                  docto.data_fiscal
                 , -- 2
                  docto.serie_docfis
                 , -- 3
                  docto.sub_serie_docfis
                 , -- 4
                  docto.num_docfis
                 , -- 5
                  's/item' item
                 , -- 6
                  cfo.cod_cfo
                 , nat.cod_natureza_op
                 , ' ' produto
                 , pfj.razao_social emitente
                 , docto.vlr_tot_nota vlr_contab_item
                 , -- 10
                  docto.vlr_tributo_icms vlr_tributo_icms
                 , -- 11
                  0 vlr_fecp_icms
                 , guia.ind_incent
              FROM dwt_docto_fiscal docto
                 , ict_guia_incent guia
                 , x2012_cod_fiscal cfo
                 , x2006_natureza_op nat
                 , x04_pessoa_fis_jur pfj
             WHERE docto.cod_empresa = p_cod_empresa
               AND docto.cod_estab = p_cod_estab
               AND docto.data_fiscal BETWEEN p_data_ini AND p_data_fim
               AND docto.cod_class_doc_fis IN ( '1'
                                              , '3' )
               AND docto.movto_e_s <> '9'
               AND docto.situacao <> 'S'
               AND docto.ind_transf_cred = '0'
               AND NVL ( docto.ind_situacao_esp, ' ' ) NOT IN ( '1'
                                                              , '2'
                                                              , '8' )
               AND cfo.ident_cfo(+) = docto.ident_cfo
               AND nat.ident_natureza_op(+) = docto.ident_natureza_op
               AND pfj.ident_fis_jur = docto.ident_fis_jur
               AND guia.cod_empresa(+) = p_cod_empresa
               AND guia.cod_estab(+) = p_cod_estab
               AND guia.ident_docto_fiscal(+) = docto.ident_docto_fiscal
               AND ( ( guia.cod_grp_incent IS NULL
                  AND p_cod_grp_incent IS NULL )
                 OR ( guia.cod_grp_incent = p_cod_grp_incent ) )
               AND NOT EXISTS
                       (SELECT 1
                          FROM dwt_itens_merc it
                         WHERE it.ident_docto_fiscal = docto.ident_docto_fiscal)
            ORDER BY 1
                   , 2
                   , 5
                   , 3
                   , 4
                   , 6;

        rnotas cnotas%ROWTYPE;

        /* Variáveis locais */

        vstatus INTEGER;
        vrazao_social_est estabelecimento.razao_social%TYPE;
        vproc_id NUMBER;

        vtotvlr_contab_item_incent NUMBER;
        vtotvlr_tributo_icms_incent NUMBER;
        vtotvlr_fecp_icms_incent NUMBER;
        vtotvlr_contab_item_nincent NUMBER;
        vtotvlr_tributo_icms_nincent NUMBER;
        vtotvlr_fecp_icms_nincent NUMBER;


        vfimnotas BOOLEAN;
        vcod_grp_incent ict_grp_incent.cod_grp_incent%TYPE;
        vdsc_grp_incent ict_grp_incent.dsc_grp_incent%TYPE;

        vtitrel VARCHAR2 ( 170 );

        /* Subrotinas */

        FUNCTION centra ( pdado IN VARCHAR2
                        , ptamcol IN INTEGER )
            RETURN VARCHAR2
        IS
            vesqdir INTEGER; -- Espaço entre as margens das colunas
            vtamdado INTEGER; -- Tamanho do campo
            vdado VARCHAR2 ( 170 );
            dif INTEGER := 0;
        BEGIN
            vtamdado := LENGTH ( pdado );

            IF vtamdado > ptamcol THEN
                vdado :=
                    SUBSTR ( pdado
                           , 1
                           , ptamcol );
            ELSE
                vesqdir := TRUNC ( ( ptamcol - vtamdado ) / 2 );
                vdado :=
                       RPAD ( ' '
                            , vesqdir
                            , ' ' )
                    || pdado
                    || RPAD ( ' '
                            , vesqdir
                            , ' ' );
            END IF;

            dif := ptamcol - LENGTH ( vdado );

            IF dif > 0 THEN
                vdado :=
                       vdado
                    || RPAD ( ' '
                            , dif
                            , ' ' );
            END IF;

            RETURN vdado;
        END;

        -----------------------

        PROCEDURE headergrupo
        IS
            vlinha1 VARCHAR2 ( 170 );
            vlinha2 VARCHAR2 ( 170 );
        BEGIN
            IF p_tipo_rel = 1 THEN -- Livros Incentivados
                vtitrel := 'Conferência das Notas Fiscais de Entrada - Grupo de Incentivo: ' || vcod_grp_incent;
                vlinha1 :=
                       '  Data    '
                    || '|'
                    || '      N.           '
                    || '|'
                    || ' Item  '
                    || '|'
                    || centra ( 'Emitente'
                              , 18 )
                    || '|'
                    || 'CFOP'
                    || '|'
                    || 'Nat'
                    || '|'
                    || centra ( 'Produto'
                              , 20 )
                    || '|'
                    || ' Valor          '
                    || '|'
                    || ' ICMS           '
                    || '|'
                    || ' ICMS           '
                    || '|'
                    || ' Incentivo ';
                vlinha2 :=
                       '  Fiscal  '
                    || '|'
                    || '      Docto        '
                    || '|'
                    || '       '
                    || '|'
                    || RPAD ( ' '
                            , 18
                            , ' ' )
                    || '|'
                    || '    '
                    || '|'
                    || 'Op '
                    || '|'
                    || RPAD ( ' '
                            , 20
                            , ' ' )
                    || '|'
                    || ' Contábil       '
                    || '|'
                    || RPAD ( ' '
                            , 16
                            , ' ' )
                    || '|'
                    || ' FECP           '
                    || '|'
                    || '           ';
            ELSE -- Livro não incentivado
                vtitrel := 'Conferência das Notas Fiscais de Entrada - Livro Não Incentivado';
                vlinha1 :=
                       '  Data    '
                    || '|'
                    || '      N.           '
                    || '|'
                    || ' Item  '
                    || '|'
                    || centra ( 'Emitente'
                              , 18 )
                    || '|'
                    || 'CFOP'
                    || '|'
                    || 'Nat'
                    || '|'
                    || centra ( 'Produto'
                              , 20 )
                    || '|'
                    || ' Valor          '
                    || '|'
                    || ' ICMS           '
                    || '|'
                    || ' ICMS           ';
                vlinha2 :=
                       '  Fiscal  '
                    || '|'
                    || '      Docto        '
                    || '|'
                    || '       '
                    || '|'
                    || RPAD ( ' '
                            , 18
                            , ' ' )
                    || '|'
                    || '    '
                    || '|'
                    || 'Op '
                    || '|'
                    || RPAD ( ' '
                            , 20
                            , ' ' )
                    || '|'
                    || ' Contábil       '
                    || '|'
                    || RPAD ( ' '
                            , 16
                            , ' ' )
                    || '|'
                    || ' FECP           ';
            END IF;

            lib_proc.add ( centra ( vtitrel
                                  , 170 ) );
            lib_proc.add ( ' ' );
            lib_proc.add ( centra ( 'Estabelecimento: ' || vrazao_social_est
                                  , 170 ) );
            lib_proc.add ( centra (    'Período: '
                                    || TO_CHAR ( p_periodo_ini
                                               , 'DD/MM/YYYY' )
                                    || ' a '
                                    || TO_CHAR ( p_periodo_fim
                                               , 'DD/MM/YYYY' )
                                  , 170 ) );
            lib_proc.add ( LPAD ( '-'
                                , 170
                                , '-' ) );

            lib_proc.add ( vlinha1 );
            lib_proc.add ( vlinha2 );
            lib_proc.add ( LPAD ( '-'
                                , 170
                                , '-' ) );
        END headergrupo;

        -----------------------

        PROCEDURE grava_e_verifica ( ptexto VARCHAR2 )
        IS
        BEGIN
            lib_proc.add ( ptexto );

            -- Se houve mudança de página, coloca o header do grupo
            IF lib_proc.get_currentrow ( 1 ) = 1 THEN
                headergrupo;
            END IF;
        END grava_e_verifica;

        -----------------------

        PROCEDURE grava_e_acumula ( reg    cnotas%ROWTYPE
                                  , ptotvlr_contab_item_incent IN OUT NUMBER
                                  , ptotvlr_tributo_icms_incent IN OUT NUMBER
                                  , ptotvlr_fecp_icms_incent IN OUT NUMBER
                                  , ptotvlr_contab_item_nincent IN OUT NUMBER
                                  , ptotvlr_tributo_icms_nincent IN OUT NUMBER
                                  , ptotvlr_fecp_icms_nincent IN OUT NUMBER
                                  , p_tipo_rel VARCHAR2 )
        IS
            vlinha lib_proc_saida.texto%TYPE;
            vdoc_fis VARCHAR2 ( 19 );
            vvlr_fecp_icms dwt_itens_merc.vlr_fecp_icms%TYPE;
        BEGIN
            SELECT    reg.num_docfis
                   || DECODE ( LTRIM ( reg.serie_docfis ), NULL, NULL, '/' || reg.serie_docfis )
                   || DECODE ( LTRIM ( reg.sub_serie_docfis ), NULL, NULL, '/' || reg.sub_serie_docfis )
              INTO vdoc_fis
              FROM DUAL;

            SELECT DECODE ( reg.vlr_fecp_icms, 0, NULL, reg.vlr_fecp_icms )
              INTO vvlr_fecp_icms
              FROM DUAL;


            IF p_tipo_rel = 1 THEN -- Livros Incentivados
                vlinha :=
                       RPAD ( TO_CHAR ( reg.data_fiscal
                                      , 'dd/mm/yyyy' )
                            , 10 )
                    || '|'
                    || LPAD ( vdoc_fis
                            , 19 )
                    || '|'
                    || LPAD ( reg.item
                            , 7 )
                    || '|'
                    || RPAD ( reg.emitente
                            , 18 )
                    || '|'
                    || LPAD ( NVL ( reg.cod_cfo, ' ' )
                            , 4 )
                    || '|'
                    || LPAD ( NVL ( reg.cod_natureza_op, ' ' )
                            , 3 )
                    || '|'
                    || RPAD ( reg.produto
                            , 20 )
                    || '|'
                    || LPAD ( TO_CHAR ( reg.vlr_contab_item
                                      , '9g999g999g990d99'
                                      , 'NLS_NUMERIC_CHARACTERS='',.'' ' )
                            , 16 )
                    || '|'
                    || LPAD ( TO_CHAR ( reg.vlr_tributo_icms
                                      , '9g999g999g990d99'
                                      , 'NLS_NUMERIC_CHARACTERS='',.'' ' )
                            , 16 )
                    || '|'
                    || LPAD ( NVL ( TO_CHAR ( vvlr_fecp_icms
                                            , '9g999g999g990d99'
                                            , 'NLS_NUMERIC_CHARACTERS='',.'' ' )
                                  , ' ' )
                            , 16 )
                    || '| '
                    || RPAD ( centra ( reg.ind_incent
                                     , 3 )
                            , 3 );
            ELSE -- Livro Não Incentivado
                vlinha :=
                       RPAD ( TO_CHAR ( reg.data_fiscal
                                      , 'dd/mm/yyyy' )
                            , 10 )
                    || '|'
                    || LPAD ( vdoc_fis
                            , 19 )
                    || '|'
                    || LPAD ( reg.item
                            , 7 )
                    || '|'
                    || RPAD ( reg.emitente
                            , 18 )
                    || '|'
                    || LPAD ( NVL ( reg.cod_cfo, ' ' )
                            , 4 )
                    || '|'
                    || LPAD ( NVL ( reg.cod_natureza_op, ' ' )
                            , 3 )
                    || '|'
                    || RPAD ( reg.produto
                            , 20 )
                    || '|'
                    || LPAD ( TO_CHAR ( reg.vlr_contab_item
                                      , '9g999g999g990d99'
                                      , 'NLS_NUMERIC_CHARACTERS='',.'' ' )
                            , 16 )
                    || '|'
                    || LPAD ( TO_CHAR ( reg.vlr_tributo_icms
                                      , '9g999g999g990d99'
                                      , 'NLS_NUMERIC_CHARACTERS='',.'' ' )
                            , 16 )
                    || '|'
                    || LPAD ( NVL ( TO_CHAR ( vvlr_fecp_icms
                                            , '9g999g999g990d99'
                                            , 'NLS_NUMERIC_CHARACTERS='',.'' ' )
                                  , ' ' )
                            , 16 );
            END IF;

            grava_e_verifica ( vlinha );

            -- acumula valores
            IF p_tipo_rel = '1'
           AND reg.ind_incent = 'I' THEN
                ptotvlr_contab_item_incent := ptotvlr_contab_item_incent + NVL ( reg.vlr_contab_item, 0 );
                ptotvlr_tributo_icms_incent := ptotvlr_tributo_icms_incent + NVL ( reg.vlr_tributo_icms, 0 );
                ptotvlr_fecp_icms_incent := ptotvlr_fecp_icms_incent + NVL ( vvlr_fecp_icms, 0 );
            ELSE
                ptotvlr_contab_item_nincent := ptotvlr_contab_item_nincent + NVL ( reg.vlr_contab_item, 0 );
                ptotvlr_tributo_icms_nincent := ptotvlr_tributo_icms_nincent + NVL ( reg.vlr_tributo_icms, 0 );
                ptotvlr_fecp_icms_nincent := ptotvlr_fecp_icms_nincent + NVL ( vvlr_fecp_icms, 0 );
            END IF;
        END grava_e_acumula;

        -----------------------

        PROCEDURE total ( pvlr_contab_item_incent NUMBER
                        , pvlr_tributo_icms_incent NUMBER
                        , pvlr_fecp_icms_incent NUMBER
                        , pvlr_contab_item_nincent NUMBER
                        , pvlr_tributo_icms_nincent NUMBER
                        , pvlr_fecp_icms_nincent NUMBER )
        IS
        BEGIN
            grava_e_verifica ( ( LPAD ( '-'
                                      , 170
                                      , '-' ) ) );

            IF p_tipo_rel = 1 THEN
                grava_e_verifica (    '   Total das Operações com Incentivo  '
                                   || RPAD ( ' '
                                           , 49
                                           , ' ' )
                                   || '|'
                                   || LPAD ( TO_CHAR ( pvlr_contab_item_incent
                                                     , '9g999g999g990d99'
                                                     , 'NLS_NUMERIC_CHARACTERS='',.'' ' )
                                           , 16 )
                                   || '|'
                                   || LPAD ( TO_CHAR ( pvlr_tributo_icms_incent
                                                     , '9g999g999g990d99'
                                                     , 'NLS_NUMERIC_CHARACTERS='',.'' ' )
                                           , 16 )
                                   || '|'
                                   || LPAD ( TO_CHAR ( pvlr_fecp_icms_incent
                                                     , '9g999g999g990d99'
                                                     , 'NLS_NUMERIC_CHARACTERS='',.'' ' )
                                           , 16 )
                                   || '|' );

                grava_e_verifica (    '   Total das Operações sem Incentivo  '
                                   || RPAD ( ' '
                                           , 49
                                           , ' ' )
                                   || '|'
                                   || LPAD ( TO_CHAR ( pvlr_contab_item_nincent
                                                     , '9g999g999g990d99'
                                                     , 'NLS_NUMERIC_CHARACTERS='',.'' ' )
                                           , 16 )
                                   || '|'
                                   || LPAD ( TO_CHAR ( pvlr_tributo_icms_nincent
                                                     , '9g999g999g990d99'
                                                     , 'NLS_NUMERIC_CHARACTERS='',.'' ' )
                                           , 16 )
                                   || '|'
                                   || LPAD ( TO_CHAR ( pvlr_fecp_icms_nincent
                                                     , '9g999g999g990d99'
                                                     , 'NLS_NUMERIC_CHARACTERS='',.'' ' )
                                           , 16 )
                                   || '|' );

                grava_e_verifica ( ( LPAD ( '-'
                                          , 170
                                          , '-' ) ) );

                grava_e_verifica (    '   Total Geral                        '
                                   || RPAD ( ' '
                                           , 49
                                           , ' ' )
                                   || '|'
                                   || LPAD ( TO_CHAR ( pvlr_contab_item_incent + pvlr_contab_item_nincent
                                                     , '9g999g999g990d99'
                                                     , 'NLS_NUMERIC_CHARACTERS='',.'' ' )
                                           , 16 )
                                   || '|'
                                   || LPAD ( TO_CHAR ( pvlr_tributo_icms_incent + pvlr_tributo_icms_nincent
                                                     , '9g999g999g990d99'
                                                     , 'NLS_NUMERIC_CHARACTERS='',.'' ' )
                                           , 16 )
                                   || '|'
                                   || LPAD ( TO_CHAR ( pvlr_fecp_icms_incent + pvlr_fecp_icms_nincent
                                                     , '9g999g999g990d99'
                                                     , 'NLS_NUMERIC_CHARACTERS='',.'' ' )
                                           , 16 )
                                   || '|' );
            ELSE
                grava_e_verifica (    '   Total Geral                        '
                                   || RPAD ( ' '
                                           , 49
                                           , ' ' )
                                   || '|'
                                   || LPAD ( TO_CHAR ( pvlr_contab_item_nincent
                                                     , '9g999g999g990d99'
                                                     , 'NLS_NUMERIC_CHARACTERS='',.'' ' )
                                           , 16 )
                                   || '|'
                                   || LPAD ( TO_CHAR ( pvlr_tributo_icms_nincent
                                                     , '9g999g999g990d99'
                                                     , 'NLS_NUMERIC_CHARACTERS='',.'' ' )
                                           , 16 )
                                   || '|'
                                   || LPAD ( TO_CHAR ( pvlr_fecp_icms_nincent
                                                     , '9g999g999g990d99'
                                                     , 'NLS_NUMERIC_CHARACTERS='',.'' ' )
                                           , 16 ) );
            END IF;
        END total;
    ----------------------- CORPO DA PROCEDURE EXECUTA  ------------------------------------------------------

    BEGIN
        vstatus := 0;

        -- Cria Número de Processo Novo
        vproc_id :=
            lib_proc.new ( 'CONF_NF_ENTR_CPROC'
                         , 48
                         , 170 );

        -- recupera a descrição do estabelecimento

        BEGIN
            SELECT razao_social
              INTO vrazao_social_est
              FROM estabelecimento
             WHERE cod_empresa = mcod_empresa
               AND cod_estab = p_cod_estab;
        EXCEPTION
            WHEN OTHERS THEN
                vrazao_social_est := NULL;
        END;

        -- Inclui Header/Footer do Log de Processo
        lib_proc.add_log ( LPAD ( '-'
                                , 170
                                , '-' )
                         , 0 );
        lib_proc.add_log ( vrazao_social_est
                         , 0 );
        lib_proc.add_log ( 'Relatório de Conferência das Notas Fiscais de Entrada'
                         , 0 );
        lib_proc.add_log ( 'Data : ' || TO_CHAR ( SYSDATE )
                         , 0 );
        lib_proc.add_log ( LPAD ( '-'
                                , 170
                                , '-' )
                         , 0 );
        lib_proc.add_log ( ' '
                         , 0 );

        IF mcod_empresa IS NULL THEN
            lib_proc.add_log ( 'Código da Empresa deve ser informado no login.'
                             , 0 );
            lib_proc.add_log ( ' '
                             , 0 );
            lib_proc.close;
            RETURN vproc_id;
        END IF;

        -- tipo: relatorio
        lib_proc.add_tipo ( vproc_id
                          , 1
                          , 'Conferência das Notas de Entrada'
                          , 1
                          , 48
                          , 170 );



        OPEN cnotas ( mcod_empresa
                    , p_cod_estab
                    , p_cod_grp_incent
                    , p_periodo_ini
                    , p_periodo_fim );

        FETCH cnotas
            INTO rnotas;

        vfimnotas := cnotas%NOTFOUND;

        IF vfimnotas THEN
            lib_proc.add_log ( 'Aviso - Não existe movimento para o período'
                             , '1' );
            vstatus := 1;
        END IF;

        -- para cada nota
        WHILE NOT vfimnotas LOOP
            -- para cada grupo de incentivo
            vcod_grp_incent := rnotas.cod_grp_incent;

            -- Inicializa variáveis
            vtotvlr_contab_item_incent := 0;
            vtotvlr_tributo_icms_incent := 0;
            vtotvlr_fecp_icms_incent := 0;
            vtotvlr_contab_item_nincent := 0;
            vtotvlr_tributo_icms_nincent := 0;
            vtotvlr_fecp_icms_nincent := 0;

            -- Recupera a descrição do grupo
            IF vcod_grp_incent IS NOT NULL THEN
                BEGIN
                    SELECT dsc_grp_incent
                      INTO vdsc_grp_incent
                      FROM ict_grp_incent
                     WHERE cod_empresa = mcod_empresa
                       AND cod_estab = p_cod_estab
                       AND cod_grp_incent = vcod_grp_incent;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        vdsc_grp_incent := 'Grupo não cadastrado';
                        lib_proc.add_log ( 'Erro - Grupo de incentivo ' || rnotas.cod_grp_incent || ' não cadastrado'
                                         , '1' );
                        vstatus := -1;
                END;
            END IF;

            -- coloca o header do grupo
            headergrupo;

            WHILE NOT vfimnotas
              AND NVL ( vcod_grp_incent, ' ' ) = NVL ( rnotas.cod_grp_incent, ' ' ) LOOP
                grava_e_acumula ( rnotas
                                , vtotvlr_contab_item_incent
                                , vtotvlr_tributo_icms_incent
                                , vtotvlr_fecp_icms_incent
                                , vtotvlr_contab_item_nincent
                                , vtotvlr_tributo_icms_nincent
                                , vtotvlr_fecp_icms_nincent
                                , p_tipo_rel );


                FETCH cnotas
                    INTO rnotas;

                vfimnotas := cnotas%NOTFOUND;
            END LOOP; -- Grupo

            -- total do grupo
            total ( vtotvlr_contab_item_incent
                  , vtotvlr_tributo_icms_incent
                  , vtotvlr_fecp_icms_incent
                  , vtotvlr_contab_item_nincent
                  , vtotvlr_tributo_icms_nincent
                  , vtotvlr_fecp_icms_nincent );

            -- Quebra a página na mudança de grupo
            IF NOT vfimnotas
           AND lib_proc.get_currentrow ( 1 ) <> 1 THEN
                lib_proc.new_page;
            END IF;
        END LOOP; -- notas

        CLOSE cnotas;

        IF vstatus = 0 THEN
            lib_proc.add_log ( 'Relatório de Conferência das Notas Fiscais de Entrada finalizado com sucesso.'
                             , '1' );
        ELSIF vstatus = 1 THEN
            lib_proc.add_log ( 'Relatório de Conferência das Notas Fiscais de Entrada finalizado com avisos.'
                             , '1' );
        ELSIF vstatus = -1 THEN
            lib_proc.add_log ( 'Relatório de Conferência das Notas Fiscais de Entrada finalizado com erros.'
                             , '1' );
        END IF;

        lib_proc.close;
        COMMIT;

        RETURN vproc_id;
    EXCEPTION
        WHEN OTHERS THEN
            lib_proc.add_log (
                                  'Relatório de Conferência das Notas Fiscais de Entrada finalizado com erros:'
                               || SQLERRM
                             , '1'
            );
            lib_proc.close;
            RETURN vproc_id;
    END;
BEGIN
    mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
END conf_nf_entr_cproc;
/
SHOW ERRORS;
