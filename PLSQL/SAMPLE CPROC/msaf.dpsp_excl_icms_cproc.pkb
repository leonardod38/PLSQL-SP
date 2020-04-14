Prompt Package Body DPSP_EXCL_ICMS_CPROC;
--
-- DPSP_EXCL_ICMS_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_excl_icms_cproc
IS
    v_proc_id lib_processo.proc_id%TYPE;
    v_cod_empresa empresa.cod_empresa%TYPE;
    v_cod_estab estabelecimento.cod_estab%TYPE;

    FUNCTION parametros
        RETURN VARCHAR2
    IS
        v_param VARCHAR2 ( 4000 );
    BEGIN
        lib_proc.add_param ( pparam => v_param
                           , ptitulo => 'Período'
                           , ptipo => 'DATE'
                           , pcontrole => 'TEXTBOX'
                           , pmandatorio => 'S'
                           , pdefault => ADD_MONTHS ( TRUNC ( SYSDATE
                                                            , 'MONTH' )
                                                    , -1 )
                           , pmascara => 'MM/YYYY'
                           , --Pvalores    =>,
                             papresenta => 'S'
                           , phabilita => 'S'--
                                              );

        lib_proc.add_param (
                             pparam => v_param
                           , ptitulo => 'Estabelecimento'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'MULTISELECT'
                           , pmandatorio => 'S'
                           , --Pdefault    =>,
                             --Pmascara    =>,
                             pvalores => 'SELECT A.COD_ESTAB,A.COD_ESTAB || '' - '' || B.COD_ESTADO || '' - '' || A.CGC || '' - '' || INITCAP(A.BAIRRO) || '' / '' || INITCAP(A.CIDADE)
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
        RETURN 'Relatórios NF Saída à desconsiderar ICMS na base de PIS/Cofins';
    END;

    FUNCTION descricao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'CFOPs Considerados: 5102, 6102, 5403, 6403, 5405';
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
                                        dsp_planilha.campo ( 'COD_EMPRESA' )
                                     || --
                                       dsp_planilha.campo ( 'COD_ESTAB' )
                                     || --
                                       dsp_planilha.campo ( 'DATA_FISCAL' )
                                     || --
                                       dsp_planilha.campo ( 'COD_DOCTO' )
                                     || --
                                       dsp_planilha.campo ( 'COD_FIS_JUR' )
                                     || --
                                       dsp_planilha.campo ( 'NUM_DOCFIS' )
                                     || --
                                       dsp_planilha.campo ( 'SERIE_DOCFIS' )
                                     || --
                                       dsp_planilha.campo ( 'NUM_CONTROLE_DOCTO' )
                                     || --
                                       dsp_planilha.campo ( 'NUM_AUTENTIC_NFE' )
                                     || --
                                       dsp_planilha.campo ( 'COD_PRODUTO' )
                                     || --
                                       dsp_planilha.campo ( 'NUM_ITEM' )
                                     || --
                                       dsp_planilha.campo ( 'COD_CFO' )
                                     || --
                                       dsp_planilha.campo ( 'COD_SITUACAO_B' )
                                     || --
                                       dsp_planilha.campo ( 'COD_NATUREZA_OP' )
                                     || --
                                       dsp_planilha.campo ( 'LISTA' )
                                     || --
                                       dsp_planilha.campo ( 'QUANTIDADE' )
                                     || --
                                       dsp_planilha.campo ( 'VLR_ITEM' )
                                     || --
                                       dsp_planilha.campo ( 'VLR_CONTAB_ITEM' )
                                     || --
                                       dsp_planilha.campo ( 'VLR_OUTRAS' )
                                     || --
                                       dsp_planilha.campo ( 'VLR_DESCONTO' )
                                     || --
                                       dsp_planilha.campo ( 'BASE_ICMS_TRIB' )
                                     || --
                                       dsp_planilha.campo ( 'ALIQ_ICMS' )
                                     || --
                                       dsp_planilha.campo ( 'VLR_ICMS' )
                                     || --
                                       dsp_planilha.campo ( 'BASE_ICMS_ISENTA' )
                                     || --
                                       dsp_planilha.campo ( 'BASE_ICMS_OUTRAS' ) --
                                   , p_class => 'h'
                )
              , p_tipo );
    END;

    PROCEDURE grava_linha ( p_rs_saidas crs_saidas%ROWTYPE
                          , p_tipo VARCHAR2 DEFAULT '1' )
    IS
    BEGIN
        grava (
                dsp_planilha.linha (
                                        dsp_planilha.campo ( p_rs_saidas.cod_empresa )
                                     || --
                                       dsp_planilha.campo ( p_rs_saidas.cod_estab )
                                     || --
                                       dsp_planilha.campo ( p_rs_saidas.data_fiscal )
                                     || --
                                       dsp_planilha.campo ( p_rs_saidas.cod_docto )
                                     || --
                                       dsp_planilha.campo ( dsp_planilha.texto ( p_rs_saidas.cod_fis_jur ) )
                                     || --
                                       dsp_planilha.campo ( dsp_planilha.texto ( p_rs_saidas.num_docfis ) )
                                     || --
                                       dsp_planilha.campo ( p_rs_saidas.serie_docfis )
                                     || --
                                       dsp_planilha.campo ( dsp_planilha.texto ( p_rs_saidas.num_controle_docto ) )
                                     || --
                                       dsp_planilha.campo ( dsp_planilha.texto ( p_rs_saidas.num_autentic_nfe ) )
                                     || --
                                       dsp_planilha.campo ( dsp_planilha.texto ( p_rs_saidas.cod_produto ) )
                                     || --
                                       dsp_planilha.campo ( p_rs_saidas.num_item )
                                     || --
                                       dsp_planilha.campo ( p_rs_saidas.cod_cfo )
                                     || --
                                       dsp_planilha.campo ( p_rs_saidas.cod_situacao_b )
                                     || --
                                       dsp_planilha.campo ( p_rs_saidas.cod_natureza_op )
                                     || --
                                       dsp_planilha.campo ( p_rs_saidas.lista )
                                     || --
                                       dsp_planilha.campo ( p_rs_saidas.quantidade )
                                     || --
                                       dsp_planilha.campo ( p_rs_saidas.vlr_item )
                                     || --
                                       dsp_planilha.campo ( p_rs_saidas.vlr_contab_item )
                                     || --
                                       dsp_planilha.campo ( p_rs_saidas.vlr_outras )
                                     || --
                                       dsp_planilha.campo ( p_rs_saidas.vlr_desconto )
                                     || --
                                       dsp_planilha.campo ( p_rs_saidas.base_icms_trib )
                                     || --
                                       dsp_planilha.campo ( p_rs_saidas.aliq_icms )
                                     || --
                                       dsp_planilha.campo ( p_rs_saidas.vlr_icms )
                                     || --
                                       dsp_planilha.campo ( p_rs_saidas.base_icms_isenta )
                                     || --
                                       dsp_planilha.campo ( p_rs_saidas.base_icms_outras ) --
                )
              , p_tipo
        );
    END;

    PROCEDURE nlog ( p_log VARCHAR2 )
    IS
    BEGIN
        lib_proc.add_log ( p_log
                         , 1 );
    END;

    PROCEDURE insere_nfsaidas ( l_cod_empresa VARCHAR2
                              , l_cod_estab VARCHAR2
                              , l_periodo IN DATE
                              , id INTEGER )
    IS
        TYPE row_ult_entrada IS TABLE OF dpsp_nfs_ult_entrada%ROWTYPE
            INDEX BY BINARY_INTEGER;

        rs_ulte row_ult_entrada;
    BEGIN
        --Nlog(p_Periodo);
        /*
        Open Crs_Saidas(l_Cod_Empresa, l_Cod_Estab, l_Periodo + Id - 1);
        Loop
          Fetch Crs_Saidas Bulk Collect
            Into Rs_Ulte Limit 1000;
          Exit When Crs_Saidas%Notfound;
        End Loop;
        Close Crs_Saidas;

        If Rs_Ulte.First Is Not Null Then
          Forall i In Rs_Ulte.First .. Rs_Ulte.Last
            Insert Into Dpsp_Nfs_Ult_Entrada Values Rs_Ulte (i);
        End If;
        Commit;*/
        FOR nf_said IN crs_saidas ( l_cod_empresa
                                  , l_cod_estab
                                  , l_periodo + id - 1 ) LOOP
            --Grava_Linha(Nf_Said, 1);
            INSERT INTO dpsp_nfs_ult_entrada ( cod_empresa
                                             , cod_estab
                                             , data_fiscal
                                             , cod_docto
                                             , cod_fis_jur
                                             , num_docfis
                                             , serie_docfis
                                             , num_controle_docto
                                             , num_autentic_nfe
                                             , cod_produto
                                             , num_item
                                             , cod_cfo
                                             , cod_situacao_b
                                             , cod_natureza_op
                                             , lista
                                             , quantidade
                                             , vlr_item
                                             , vlr_contab_item
                                             , vlr_outras
                                             , vlr_desconto
                                             , base_icms_trib
                                             , aliq_icms
                                             , vlr_icms
                                             , base_icms_isenta
                                             , base_icms_outras
                                             , vlr_base_pis
                                             , vlr_aliq_pis
                                             , vlr_pis
                                             , vlr_base_cofins
                                             , vlr_aliq_cofins
                                             , vlr_cofins )
                 VALUES ( nf_said.cod_empresa
                        , nf_said.cod_estab
                        , nf_said.data_fiscal
                        , nf_said.cod_docto
                        , nf_said.cod_fis_jur
                        , nf_said.num_docfis
                        , nf_said.serie_docfis
                        , nf_said.num_controle_docto
                        , nf_said.num_autentic_nfe
                        , nf_said.cod_produto
                        , nf_said.num_item
                        , nf_said.cod_cfo
                        , nf_said.cod_situacao_b
                        , nf_said.cod_natureza_op
                        , nf_said.lista
                        , nf_said.quantidade
                        , nf_said.vlr_item
                        , nf_said.vlr_contab_item
                        , nf_said.vlr_outras
                        , nf_said.vlr_desconto
                        , nf_said.base_icms_trib
                        , nf_said.aliq_icms
                        , nf_said.vlr_icms
                        , nf_said.base_icms_isenta
                        , nf_said.base_icms_outras
                        , nf_said.vlr_base_pis
                        , nf_said.vlr_aliq_pis
                        , nf_said.vlr_pis
                        , nf_said.vlr_base_cofins
                        , nf_said.vlr_aliq_cofins
                        , nf_said.vlr_cofins );
        END LOOP;

        COMMIT;
    END insere_nfsaidas;

    PROCEDURE processa_cfe_paralelo ( p_periodo IN DATE )
    IS
        v_id_task VARCHAR2 ( 100 ) := v_proc_id || '_' || v_cod_estab || '_NF_ULTE';
    BEGIN
        dbms_parallel_execute.create_task ( task_name => v_id_task );
        dbms_parallel_execute.create_chunks_by_sql ( task_name => v_id_task
                                                   , sql_stmt =>    'Select Level, 0 From dual Connect By Level <= '
                                                                 || TO_CHAR ( LAST_DAY ( p_periodo )
                                                                            , 'DD' )
                                                   , by_rowid => FALSE );
        --Nlog(v_Cod_Empresa || '|' || v_Cod_Estab || '|' || p_Periodo || '');
        nlog ( v_id_task );

        dbms_parallel_execute.run_task ( v_id_task
                                       ,    'Begin DPSP_EXCL_ICMS_CPROC.Insere_Nfsaidas('''
                                         || v_cod_empresa
                                         || ''','''
                                         || v_cod_estab
                                         || ''','''
                                         || TO_CHAR ( p_periodo
                                                    , 'DDMMYYYY' )
                                         || ''' , :start_id + :end_id); END;'
                                       , dbms_sql.native
                                       , parallel_level => 12 );

        DECLARE
            l_try NUMBER;
            l_status NUMBER;
        BEGIN
            l_try := 0;
            l_status := dbms_parallel_execute.task_status ( v_id_task );

            WHILE ( l_try < 2
               AND l_status != dbms_parallel_execute.finished ) LOOP
                l_try := l_try + 1;
                dbms_parallel_execute.resume_task ( v_id_task );
                l_status := dbms_parallel_execute.task_status ( v_id_task );
            END LOOP;
        END;

        dbms_parallel_execute.drop_task ( v_id_task );
    END processa_cfe_paralelo;

    PROCEDURE processa_cf ( p_periodo DATE )
    IS
    BEGIN
        INSERT /*+ APPEND*/
              INTO  dpsp_nfs_ult_entrada ( cod_empresa
                                         , cod_estab
                                         , data_fiscal
                                         , cod_docto
                                         , cod_fis_jur
                                         , num_docfis
                                         , serie_docfis
                                         , num_controle_docto
                                         , num_autentic_nfe
                                         , cod_produto
                                         , num_item
                                         , cod_cfo
                                         , cod_situacao_b
                                         , cod_natureza_op
                                         , lista
                                         , quantidade
                                         , vlr_item
                                         , vlr_contab_item
                                         , vlr_outras
                                         , vlr_desconto
                                         , base_icms_trib
                                         , aliq_icms
                                         , vlr_icms
                                         , base_icms_isenta
                                         , base_icms_outras
                                         , vlr_base_pis
                                         , vlr_aliq_pis
                                         , vlr_pis
                                         , vlr_base_cofins
                                         , vlr_aliq_cofins
                                         , vlr_cofins )
            ( SELECT /*+ parallel(12)*/
                    capa.cod_empresa
                   , capa.cod_estab
                   , capa.data_emissao data_fiscal
                   , 'CF' cod_docto
                   , capa.cpf_cnpj_cliente cod_fis_jur
                   , capa.num_coo num_docfis
                   , eqpt.cod_caixa_ecf serie_docfis
                   , NULL num_controle_docto
                   , NULL num_autentic_nfe
                   , prod.cod_produto
                   , item.num_item
                   , cfop.cod_cfo
                   , sitb.cod_situacao_b
                   , NULL cod_natureza_op
                   , lst.lista
                   , item.qtde quantidade
                   , item.vlr_item
                   , item.vlr_item vlr_contab_item
                   , 0 vlr_outras
                   , item.vlr_desc vlr_desconto
                   , item.vlr_base base_icms_trib
                   , 0 aliq_icms
                   , item.vlr_tributo vlr_icms
                   , 0 base_icms_isenta
                   , 0 base_icms_outras
                   , vlr_base_pis
                   , vlr_aliq_pis
                   , vlr_pis
                   , vlr_base_cofins
                   , vlr_aliq_cofins
                   , vlr_cofins
                FROM x993_capa_cupom_ecf capa --DATA_EMISSAO, COD_ESTAB, IDENT_CAIXA_ECF, COD_EMPRESA, NUM_COO
                     INNER JOIN x994_item_cupom_ecf item
                         ON capa.cod_empresa = item.cod_empresa
                        AND capa.cod_estab = item.cod_estab
                        AND capa.data_emissao = item.data_emissao
                        AND capa.num_coo = item.num_coo
                        AND capa.ident_caixa_ecf = item.ident_caixa_ecf
                     INNER JOIN x2012_cod_fiscal cfop ON item.ident_cfo = cfop.ident_cfo
                     INNER JOIN x2087_equipamento_ecf eqpt ON eqpt.ident_caixa_ecf = capa.ident_caixa_ecf
                     INNER JOIN x2013_produto prod ON prod.ident_produto = item.ident_produto
                     INNER JOIN y2026_sit_trb_uf_b sitb ON item.ident_situacao_b = sitb.ident_situacao_b
                     LEFT JOIN (SELECT *
                                  FROM dpsp_ps_lista l
                                 WHERE l.effdt = (SELECT MAX ( a.effdt )
                                                    FROM dpsp_ps_lista a
                                                   WHERE a.cod_produto = l.cod_produto
                                                     AND a.effdt <= p_periodo)) lst
                         ON prod.cod_produto = lst.cod_produto
               WHERE capa.cod_empresa = v_cod_empresa
                 AND capa.cod_estab = v_cod_estab
                 AND capa.data_emissao BETWEEN p_periodo AND LAST_DAY ( p_periodo )
                 AND cfop.cod_cfo IN ( '5102'
                                     , '6102'
                                     , '5403'
                                     , '6403'
                                     , '5405' ) );

        COMMIT;
    END;

    PROCEDURE atualiza_lista
    IS
    BEGIN
        BEGIN
            MERGE INTO dpsp_ps_lista l
                 USING (SELECT a.inv_item_id cod_produto
                             , a.class_pis_dsp lista
                             , a.effdt
                          FROM msafi.ps_atrb_op_eff_dsp a
                         WHERE a.setid = 'GERAL'
                           AND a.class_pis_dsp IN ( 'N'
                                                  , 'P'
                                                  , 'O' )
                           AND ( a.inv_item_id
                               , a.effdt ) NOT IN ( SELECT cod_produto
                                                         , effdt
                                                      FROM dpsp_ps_lista )) c
                    ON ( l.cod_produto = c.cod_produto
                    AND l.effdt = l.effdt )
            WHEN MATCHED THEN
                UPDATE SET l.lista = c.lista
            WHEN NOT MATCHED THEN
                INSERT     VALUES ( c.cod_produto
                                  , c.lista
                                  , c.effdt );

            COMMIT;
        END;
    END atualiza_lista;

    PROCEDURE inicializa_saidas ( p_periodo IN DATE )
    IS
    BEGIN
        DELETE FROM dpsp_nfs_ult_entrada
              WHERE cod_empresa = v_cod_empresa
                AND cod_estab = v_cod_estab
                AND data_fiscal BETWEEN p_periodo AND LAST_DAY ( p_periodo );

        COMMIT;
    END inicializa_saidas;

    FUNCTION executar ( p_periodo DATE
                      , p_estabs lib_proc.vartab )
        RETURN NUMBER
    IS
    BEGIN
        v_proc_id := lib_proc.new ( 'DPSP_EXCL_ICMS_CPROC' );
        v_cod_empresa := lib_parametros.recuperar ( 'EMPRESA' );

        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS='',.''';

        atualiza_lista;

        FOR est IN 1 .. p_estabs.COUNT LOOP
            v_cod_estab := p_estabs ( est );

            inicializa_saidas ( p_periodo );

            lib_proc.add_tipo ( v_proc_id
                              , est
                              ,    'NF_EXCL_'
                                || v_cod_empresa
                                || '_'
                                || v_cod_estab
                                || '_'
                                || TO_CHAR ( p_periodo
                                           , 'yyyymm' )
                                || '.xls'
                              , 2 );

            grava ( dsp_planilha.header
                  , est );
            grava ( dsp_planilha.tabela_inicio
                  , est );
            cabecalho ( est );

            processa_cfe_paralelo ( p_periodo );
            processa_cf ( p_periodo );

            grava ( dsp_planilha.tabela_fim
                  , est );
        END LOOP;

        lib_proc.close;

        RETURN v_proc_id;
    END executar;

    PROCEDURE teste
    IS
        v_estab lib_proc.vartab;
    BEGIN
        lib_parametros.salvar ( 'EMPRESA'
                              , 'DSP' );
        v_estab ( 1 ) := 'DSP003';
        v_estab ( 2 ) := 'DSP004';
        v_estab ( 3 ) := 'DSP008';
        v_estab ( 4 ) := 'DSP012';
        v_estab ( 5 ) := 'DSP015';
        v_estab ( 6 ) := 'DSP016';
        v_estab ( 7 ) := 'DSP018';
        v_estab ( 8 ) := 'DSP019';
        v_estab ( 9 ) := 'ST910';
        dbms_output.put_line ( dpsp_excl_icms_cproc.executar ( '01052017'
                                                             , v_estab ) );
    END;

    PROCEDURE teste1
    IS
        v_estab lib_proc.vartab;
    BEGIN
        lib_parametros.salvar ( 'EMPRESA'
                              , 'DSP' );
        v_estab ( 1 ) := 'DSP004';
        dbms_output.put_line ( dpsp_excl_icms_cproc.executar ( '01052017'
                                                             , v_estab ) );
    END;
END dpsp_excl_icms_cproc;
/
SHOW ERRORS;
