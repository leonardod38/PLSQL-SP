Prompt Package Body CST_REL_CONF_SAP_CPROC;
--
-- CST_REL_CONF_SAP_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY cst_rel_conf_sap_cproc
IS
    mcod_empresa empresa.cod_empresa%TYPE;
    mproc_id INTEGER;

    v_class VARCHAR2 ( 1 ) := 'A';
    v_text01 VARCHAR2 ( 10000 );

    v_sel_data_fim VARCHAR2 ( 260 )
        := ' SELECT TRUNC( TO_DATE( :1 ,''DD/MM/YYYY'') + ROWNUM - 1) AS DATA_FIM, TRUNC( TO_DATE( :1 ,''DD/MM/YYYY'') + ROWNUM - 1) AS DATA_FIM FROM DUAL CONNECT BY ROWNUM <= LAST_DAY( TO_DATE( :1 ,''DD/MM/YYYY'') ) - TO_DATE( :1 ,''DD/MM/YYYY'') + 1 ORDER BY 1 DESC ';

    --Tipo, Nome e Descrição do Customizado
    mnm_tipo VARCHAR2 ( 100 ) := 'Conferência';
    mnm_cproc VARCHAR2 ( 100 ) := '02-Relatorio de Confronto SAP x MSAF';
    mds_cproc VARCHAR2 ( 100 ) := 'Relatorio Arquivo para Emitir relatório de confronto de NFs SAP x Mastersaf';

    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );
    BEGIN
        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        --1
        lib_proc.add_param ( pstr
                           , 'Data Inicial'
                           , --P_DATA_INI
                            'DATE'
                           , 'TEXTBOX'
                           , 'S'
                           , NULL
                           , 'DD/MM/YYYY' );

        --2
        lib_proc.add_param ( pparam => pstr
                           , ptitulo => 'Data Final'
                           , --P_DT_FIM
                            ptipo => 'VARCHAR2'
                           , pcontrole => 'COMBOBOX'
                           , pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => '##########'
                           , pvalores => v_sel_data_fim );

        --3
        lib_proc.add_param (
                             pparam => pstr
                           , ptitulo => 'ID Processo'
                           , -- P_UF
                            ptipo => 'VARCHAR2'
                           , pcontrole => 'COMBOBOX'
                           , pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => '####################'
                           , pvalores =>    'SELECT DISTINCT ZZCHAVE cod_chave,  ZZCHAVE||'' - ''||ZZUSEREXEC descricao  FROM MSAFI.CST_DOCTOFIS_SAP_MSAF '
                                         || '  ORDER BY 1'
                           , phabilita => 'S'
        );

        RETURN pstr;
    END; --FUNCTION PARAMETROS RETURN VARCHAR2 IS

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN mnm_cproc;
    END;

    FUNCTION tipo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN mnm_tipo;
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
        RETURN mds_cproc;
    END;

    FUNCTION modulo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'CONFERENCIA';
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

    --PROCEDURE DELETE_TEMP_TBL

    PROCEDURE grava ( p_texto VARCHAR2
                    , p_tipo VARCHAR2 DEFAULT '1' )
    IS
    BEGIN
        lib_proc.add ( p_texto
                     , ptipo => p_tipo );
    END;

    PROCEDURE cabecalho_analitico ( p_tipo VARCHAR2 DEFAULT '1' )
    IS
        v_cl_02 VARCHAR2 ( 6 ) := '5555aa';
    BEGIN
        grava ( acc_planilha.linha (    acc_planilha.campo ( 'NUM_CONTROLE_DOCTO'
                                                           , p_custom => 'BGCOLOR="#' || v_cl_02 || '"' )
                                     || --
                                       acc_planilha.campo ( 'NUM_DOCFIS'
                                                          , p_custom => 'BGCOLOR="#' || v_cl_02 || '"' )
                                     || --
                                       acc_planilha.campo ( 'NUM_ITEM'
                                                          , p_custom => 'BGCOLOR="#' || v_cl_02 || '"' )
                                     || --
                                       acc_planilha.campo ( 'COD_OBSERVCAO'
                                                          , p_custom => 'BGCOLOR="#' || v_cl_02 || '"' )
                                     || --
                                       acc_planilha.campo ( 'OBSERVACAO'
                                                          , p_custom => 'BGCOLOR="#' || v_cl_02 || '"' )
                                     || --
                                       acc_planilha.campo ( 'VALOR MSAF'
                                                          , p_custom => 'BGCOLOR="#' || v_cl_02 || '"' )
                                     || --
                                       acc_planilha.campo ( 'VALOR SAP'
                                                          , p_custom => 'BGCOLOR="#' || v_cl_02 || '"' )
                                     || --
                                       ''
                                   , p_class => 'H' )
              , p_tipo );
    END;

    PROCEDURE grava_analitico ( vp_data_ini DATE
                              , vp_data_fim DATE
                              , p_id_processo VARCHAR2
                              , p_tipo VARCHAR2 DEFAULT '1' )
    IS
        v_cod_observacao VARCHAR2 ( 100 );
        v_dsc_observacao VARCHAR2 ( 100 );

        v_vlr_msaf VARCHAR2 ( 100 );
        v_vlr_sap VARCHAR2 ( 100 );
    BEGIN
        lib_proc.add_tipo ( mproc_id
                          , p_tipo
                          ,    'REL_CONFERENCIA_'
                            || TO_CHAR ( vp_data_ini
                                       , 'YYYYMM' )
                            || '.XLS'
                          , 2 );

        grava ( acc_planilha.header
              , p_tipo );
        grava ( acc_planilha.tabela_inicio
              , p_tipo );
        cabecalho_analitico ( p_tipo );

        --=========================================================
        loga ( '>> Montando relatorio'
             , FALSE );

        --=========================================================

        FOR c IN ( SELECT DISTINCT sap.zzdocnum num_controle_docto
                                 , sap.zznfenum num_docfis
                                 , NULL num_item
                                 , '1000' cod_observacao
                                 , 'NF não existe no MSAF' dsc_observacao
                                 , NULL vlr_msaf
                                 , sap.zzdocnum vlr_sap
                     FROM msafi.cst_doctofis_sap_msaf sap
                        , msaf.x07_docto_fiscal x07
                    WHERE 1 = 1
                      AND zzpstdat BETWEEN TO_CHAR ( vp_data_ini
                                                   , 'yyyymmdd' )
                                       AND TO_CHAR ( vp_data_fim
                                                   , 'yyyymmdd' )
                      AND zzchave = p_id_processo
                      AND sap.zzdocnum = x07.num_controle_docto(+)
                      AND x07.data_fiscal(+) BETWEEN vp_data_ini AND vp_data_fim
                      AND x07.cod_sistema_orig(+) = 'SAP'
                      AND x07.ROWID IS NULL ) LOOP
            IF v_class = 'A' THEN
                v_class := 'B';
            ELSE
                v_class := 'A';
            END IF;

            v_text01 :=
                acc_planilha.linha (
                                     p_conteudo =>    acc_planilha.campo ( c.num_controle_docto )
                                                   || --
                                                     acc_planilha.campo ( c.num_docfis )
                                                   || --
                                                     acc_planilha.campo ( c.num_item )
                                                   || --
                                                     acc_planilha.campo ( c.cod_observacao )
                                                   || --
                                                     acc_planilha.campo ( c.dsc_observacao )
                                                   || --
                                                     acc_planilha.campo ( c.vlr_msaf )
                                                   || --
                                                     acc_planilha.campo ( c.vlr_sap )
                                                   || --
                                                     ''
                                   , p_class => v_class
                );

            lib_proc.add ( v_text01
                         , ptipo => p_tipo );

            COMMIT;
        END LOOP;

        FOR c IN ( SELECT DISTINCT num_controle_docto
                                 , num_docfis
                                 , NULL num_item
                                 , '1001' cod_observacao
                                 , 'NF não existe no SAP' dsc_observacao
                                 , num_controle_docto vlr_msaf
                                 , NULL vlr_sap
                     FROM msafi.cst_doctofis_sap_msaf sap
                        , msaf.x07_docto_fiscal x07
                    WHERE 1 = 1
                      AND sap.zzpstdat(+) BETWEEN TO_CHAR ( vp_data_ini
                                                          , 'yyyymmdd' )
                                              AND TO_CHAR ( vp_data_fim
                                                          , 'yyyymmdd' )
                      AND sap.zzchave(+) = p_id_processo
                      AND sap.zzdocnum(+) = x07.num_controle_docto
                      AND x07.data_fiscal BETWEEN vp_data_ini AND vp_data_fim
                      AND x07.cod_sistema_orig(+) = 'SAP'
                      AND sap.ROWID IS NULL ) LOOP
            IF v_class = 'A' THEN
                v_class := 'B';
            ELSE
                v_class := 'A';
            END IF;

            v_text01 :=
                acc_planilha.linha (
                                     p_conteudo =>    acc_planilha.campo ( c.num_controle_docto )
                                                   || --
                                                     acc_planilha.campo ( c.num_docfis )
                                                   || --
                                                     acc_planilha.campo ( c.num_item )
                                                   || --
                                                     acc_planilha.campo ( c.cod_observacao )
                                                   || --
                                                     acc_planilha.campo ( c.dsc_observacao )
                                                   || --
                                                     acc_planilha.campo ( c.vlr_msaf )
                                                   || --
                                                     acc_planilha.campo ( c.vlr_sap )
                                                   || --
                                                     ''
                                   , p_class => v_class
                );

            lib_proc.add ( v_text01
                         , ptipo => p_tipo );

            COMMIT;
        END LOOP;

        FOR c IN ( SELECT x07.num_controle_docto
                        , NULL num_item
                        , x07.data_fiscal
                        , TO_DATE ( sap.zzpstdat
                                  , 'yyyymmdd' )
                              data_fiscal_sap
                        , x07.cod_empresa
                        , sap.zzcodemp cod_empresa_sap
                        , x07.cod_estab
                        , sap.zzcodfil cod_estab_sap
                        , x07.movto_e_s
                        , sap.zzmovtoes movto_e_s_sap
                        , x04.ind_fis_jur
                        , sap.zzindfisjur ind_fis_jur_sap
                        , x04.cod_fis_jur
                        , sap.zzparid cod_fis_jur_sap
                        , x07.num_docfis
                        , sap.zznfenum num_docfis_sap
                        , x07.serie_docfis
                        , sap.zzseries serie_docfis_sap
                        , x07.situacao
                        , DECODE ( sap.zzcancel, 'X', 2, 1 ) situacao_sap
                     FROM msafi.cst_doctofis_sap_msaf sap
                        , msaf.x07_docto_fiscal x07
                        , msaf.x04_pessoa_fis_jur x04
                    WHERE 1 = 1
                      AND sap.zzpstdat BETWEEN TO_CHAR ( vp_data_ini
                                                       , 'yyyymmdd' )
                                           AND TO_CHAR ( vp_data_fim
                                                       , 'yyyymmdd' )
                      AND sap.zzchave = p_id_processo
                      AND sap.zzdocnum = x07.num_controle_docto
                      AND x07.data_fiscal BETWEEN vp_data_ini AND vp_data_fim
                      AND x07.cod_sistema_orig(+) = 'SAP'
                      AND x07.ident_fis_jur = x04.ident_fis_jur
                      AND ( NVL ( x07.cod_empresa, '-1' ) <> NVL ( sap.zzcodemp, '-1' ) --
                        OR NVL ( x07.cod_estab, '-1' ) <> NVL ( sap.zzcodfil, '-1' ) --
                        OR NVL ( x07.movto_e_s, '-1' ) <> NVL ( sap.zzmovtoes, '-1' ) --
                        OR NVL ( x04.ind_fis_jur, '-1' ) <> NVL ( sap.zzindfisjur, '-1' ) --
                        OR NVL ( x04.cod_fis_jur, '-1' ) <> NVL ( sap.zzparid, '-1' ) --
                        OR NVL ( x07.num_docfis, '-1' ) <> NVL ( sap.zznfenum, '-1' ) --
                        OR NVL ( x07.serie_docfis, '-1' ) <> NVL ( sap.zzseries, '-1' ) --
                        OR NVL ( x07.situacao, '-1' ) <> NVL ( DECODE ( sap.zzcancel, 'X', 2, 1 ), '-1' ) ) ) LOOP
            IF NVL ( c.cod_empresa, '-1' ) <> NVL ( c.cod_empresa_sap, '-1' ) THEN
                v_cod_observacao := '1002';
                v_dsc_observacao := 'Dif Cod Empresa';
                v_vlr_msaf := c.cod_empresa;
                v_vlr_sap := c.cod_empresa_sap;

                IF v_class = 'A' THEN
                    v_class := 'B';
                ELSE
                    v_class := 'A';
                END IF;

                v_text01 :=
                    acc_planilha.linha (
                                         p_conteudo =>    acc_planilha.campo ( c.num_controle_docto )
                                                       || --
                                                         acc_planilha.campo ( c.num_docfis )
                                                       || --
                                                         acc_planilha.campo ( c.num_item )
                                                       || --
                                                         acc_planilha.campo ( v_cod_observacao )
                                                       || --
                                                         acc_planilha.campo ( v_dsc_observacao )
                                                       || --
                                                         acc_planilha.campo ( v_vlr_msaf )
                                                       || --
                                                         acc_planilha.campo ( v_vlr_sap )
                                                       || --
                                                         ''
                                       , p_class => v_class
                    );

                lib_proc.add ( v_text01
                             , ptipo => p_tipo );

                COMMIT;
            END IF;

            IF NVL ( c.cod_estab, '-1' ) <> NVL ( c.cod_estab_sap, '-1' ) THEN
                v_cod_observacao := '1003';
                v_dsc_observacao := 'Dif Cod Estabelecimento';
                v_vlr_msaf := c.cod_estab;
                v_vlr_sap := c.cod_estab_sap;

                IF v_class = 'A' THEN
                    v_class := 'B';
                ELSE
                    v_class := 'A';
                END IF;

                v_text01 :=
                    acc_planilha.linha (
                                         p_conteudo =>    acc_planilha.campo ( c.num_controle_docto )
                                                       || --
                                                         acc_planilha.campo ( c.num_docfis )
                                                       || --
                                                         acc_planilha.campo ( c.num_item )
                                                       || --
                                                         acc_planilha.campo ( v_cod_observacao )
                                                       || --
                                                         acc_planilha.campo ( v_dsc_observacao )
                                                       || --
                                                         acc_planilha.campo ( v_vlr_msaf )
                                                       || --
                                                         acc_planilha.campo ( v_vlr_sap )
                                                       || --
                                                         ''
                                       , p_class => v_class
                    );

                lib_proc.add ( v_text01
                             , ptipo => p_tipo );

                COMMIT;
            END IF;

            IF NVL ( c.movto_e_s, '-1' ) <> NVL ( c.movto_e_s, '-1' ) THEN
                v_cod_observacao := '1004';
                v_dsc_observacao := 'Dif Movimentacao E/S';
                v_vlr_msaf := c.movto_e_s;
                v_vlr_sap := c.movto_e_s_sap;

                IF v_class = 'A' THEN
                    v_class := 'B';
                ELSE
                    v_class := 'A';
                END IF;

                v_text01 :=
                    acc_planilha.linha (
                                         p_conteudo =>    acc_planilha.campo ( c.num_controle_docto )
                                                       || --
                                                         acc_planilha.campo ( c.num_docfis )
                                                       || --
                                                         acc_planilha.campo ( c.num_item )
                                                       || --
                                                         acc_planilha.campo ( v_cod_observacao )
                                                       || --
                                                         acc_planilha.campo ( v_dsc_observacao )
                                                       || --
                                                         acc_planilha.campo ( v_vlr_msaf )
                                                       || --
                                                         acc_planilha.campo ( v_vlr_sap )
                                                       || --
                                                         ''
                                       , p_class => v_class
                    );

                lib_proc.add ( v_text01
                             , ptipo => p_tipo );

                COMMIT;
            END IF;

            IF NVL ( c.ind_fis_jur, '-1' ) <> NVL ( c.ind_fis_jur_sap, '-1' ) --
            OR NVL ( c.cod_fis_jur, '-1' ) <> NVL ( c.cod_fis_jur_sap, '-1' ) THEN
                v_cod_observacao := '1005';
                v_dsc_observacao := 'Dif Cliente/Fornecedor';
                v_vlr_msaf := c.ind_fis_jur || '-' || c.cod_fis_jur;
                v_vlr_sap := c.ind_fis_jur_sap || '-' || c.cod_fis_jur_sap;

                IF v_class = 'A' THEN
                    v_class := 'B';
                ELSE
                    v_class := 'A';
                END IF;

                v_text01 :=
                    acc_planilha.linha (
                                         p_conteudo =>    acc_planilha.campo ( c.num_controle_docto )
                                                       || --
                                                         acc_planilha.campo ( c.num_docfis )
                                                       || --
                                                         acc_planilha.campo ( c.num_item )
                                                       || --
                                                         acc_planilha.campo ( v_cod_observacao )
                                                       || --
                                                         acc_planilha.campo ( v_dsc_observacao )
                                                       || --
                                                         acc_planilha.campo ( v_vlr_msaf )
                                                       || --
                                                         acc_planilha.campo ( v_vlr_sap )
                                                       || --
                                                         ''
                                       , p_class => v_class
                    );

                lib_proc.add ( v_text01
                             , ptipo => p_tipo );

                COMMIT;
            END IF;

            IF NVL ( c.num_docfis, '-1' ) <> NVL ( c.num_docfis_sap, '-1' ) THEN
                v_cod_observacao := '1006';
                v_dsc_observacao := 'Dif Num NF';
                v_vlr_msaf := c.num_docfis;
                v_vlr_sap := c.num_docfis_sap;

                IF v_class = 'A' THEN
                    v_class := 'B';
                ELSE
                    v_class := 'A';
                END IF;

                v_text01 :=
                    acc_planilha.linha (
                                         p_conteudo =>    acc_planilha.campo ( c.num_controle_docto )
                                                       || --
                                                         acc_planilha.campo ( c.num_docfis )
                                                       || --
                                                         acc_planilha.campo ( c.num_item )
                                                       || --
                                                         acc_planilha.campo ( v_cod_observacao )
                                                       || --
                                                         acc_planilha.campo ( v_dsc_observacao )
                                                       || --
                                                         acc_planilha.campo ( v_vlr_msaf )
                                                       || --
                                                         acc_planilha.campo ( v_vlr_sap )
                                                       || --
                                                         ''
                                       , p_class => v_class
                    );

                lib_proc.add ( v_text01
                             , ptipo => p_tipo );

                COMMIT;
            END IF;

            IF NVL ( c.serie_docfis, '-1' ) <> NVL ( c.serie_docfis_sap, '-1' ) THEN
                v_cod_observacao := '1007';
                v_dsc_observacao := 'Dif Serie NF';
                v_vlr_msaf := c.serie_docfis;
                v_vlr_sap := c.serie_docfis_sap;

                IF v_class = 'A' THEN
                    v_class := 'B';
                ELSE
                    v_class := 'A';
                END IF;

                v_text01 :=
                    acc_planilha.linha (
                                         p_conteudo =>    acc_planilha.campo ( c.num_controle_docto )
                                                       || --
                                                         acc_planilha.campo ( c.num_docfis )
                                                       || --
                                                         acc_planilha.campo ( c.num_item )
                                                       || --
                                                         acc_planilha.campo ( v_cod_observacao )
                                                       || --
                                                         acc_planilha.campo ( v_dsc_observacao )
                                                       || --
                                                         acc_planilha.campo ( v_vlr_msaf )
                                                       || --
                                                         acc_planilha.campo ( v_vlr_sap )
                                                       || --
                                                         ''
                                       , p_class => v_class
                    );

                lib_proc.add ( v_text01
                             , ptipo => p_tipo );

                COMMIT;
            END IF;

            IF NVL ( c.situacao, '-1' ) <> NVL ( CASE WHEN c.situacao_sap = 'X' THEN 2 ELSE 1 END, '-1' ) THEN
                v_cod_observacao := '1008';
                v_dsc_observacao := 'Dif Situação';
                v_vlr_msaf := c.situacao;
                v_vlr_sap := c.situacao_sap;

                IF v_class = 'A' THEN
                    v_class := 'B';
                ELSE
                    v_class := 'A';
                END IF;

                v_text01 :=
                    acc_planilha.linha (
                                         p_conteudo =>    acc_planilha.campo ( c.num_controle_docto )
                                                       || --
                                                         acc_planilha.campo ( c.num_docfis )
                                                       || --
                                                         acc_planilha.campo ( c.num_item )
                                                       || --
                                                         acc_planilha.campo ( v_cod_observacao )
                                                       || --
                                                         acc_planilha.campo ( v_dsc_observacao )
                                                       || --
                                                         acc_planilha.campo ( v_vlr_msaf )
                                                       || --
                                                         acc_planilha.campo ( v_vlr_sap )
                                                       || --
                                                         ''
                                       , p_class => v_class
                    );

                lib_proc.add ( v_text01
                             , ptipo => p_tipo );

                COMMIT;
            END IF;
        END LOOP;

        FOR c IN ( SELECT sap.zzdocnum num_controle_docto
                        , sap.zznfenum num_docfis
                        , TO_NUMBER ( sap.zzitmnum ) num_item
                        , '2000' cod_observacao
                        , 'Item merc não existe no MSAF' dsc_observacao
                        , NULL vlr_msaf
                        , sap.zzitmnum vlr_sap
                     FROM msafi.cst_doctofis_sap_msaf sap
                    WHERE 1 = 1
                      AND sap.zzpstdat BETWEEN TO_CHAR ( vp_data_ini
                                                       , 'yyyymmdd' )
                                           AND TO_CHAR ( vp_data_fim
                                                       , 'yyyymmdd' )
                      AND sap.zzchave = p_id_processo
                      AND sap.zznfesrv IS NULL -- mercadoria
                      AND NOT EXISTS
                              (SELECT 1
                                 FROM msaf.x07_docto_fiscal x07
                                    , msaf.x08_itens_merc x08
                                WHERE 1 = 1
                                  AND x07.data_fiscal(+) BETWEEN vp_data_ini AND vp_data_fim
                                  AND x07.cod_sistema_orig = 'SAP'
                                  AND x07.cod_empresa = x08.cod_empresa
                                  AND x07.cod_estab = x08.cod_estab
                                  AND x07.data_fiscal = x08.data_fiscal
                                  AND x07.movto_e_s = x08.movto_e_s
                                  AND x07.norm_dev = x08.norm_dev
                                  AND x07.ident_docto = x08.ident_docto
                                  AND x07.ident_fis_jur = x08.ident_fis_jur
                                  AND x07.num_docfis = x08.num_docfis
                                  AND x07.serie_docfis = x08.serie_docfis
                                  AND x07.sub_serie_docfis = x08.sub_serie_docfis
                                  AND sap.zzdocnum = x07.num_controle_docto
                                  AND TO_NUMBER ( sap.zzitmnum ) = x08.num_item)
                      AND EXISTS
                              (SELECT 1
                                 FROM msaf.x07_docto_fiscal x07
                                WHERE 1 = 1
                                  AND x07.data_fiscal(+) BETWEEN vp_data_ini AND vp_data_fim
                                  AND x07.cod_sistema_orig = 'SAP'
                                  AND sap.zzdocnum = x07.num_controle_docto) ) LOOP
            IF v_class = 'A' THEN
                v_class := 'B';
            ELSE
                v_class := 'A';
            END IF;

            v_text01 :=
                acc_planilha.linha (
                                     p_conteudo =>    acc_planilha.campo ( c.num_controle_docto )
                                                   || --
                                                     acc_planilha.campo ( c.num_docfis )
                                                   || --
                                                     acc_planilha.campo ( c.num_item )
                                                   || --
                                                     acc_planilha.campo ( c.cod_observacao )
                                                   || --
                                                     acc_planilha.campo ( c.dsc_observacao )
                                                   || --
                                                     acc_planilha.campo ( c.vlr_msaf )
                                                   || --
                                                     acc_planilha.campo ( c.vlr_sap )
                                                   || --
                                                     ''
                                   , p_class => v_class
                );

            lib_proc.add ( v_text01
                         , ptipo => p_tipo );

            COMMIT;
        END LOOP;

        FOR c IN ( SELECT x07.num_controle_docto
                        , x07.num_docfis
                        , x08.num_item num_item
                        , '2001' cod_observacao
                        , 'Item merc não existe no SAP' dsc_observacao
                        , x08.num_item vlr_msaf
                        , NULL vlr_sap
                     FROM msaf.x07_docto_fiscal x07
                        , msaf.x08_itens_merc x08
                    WHERE 1 = 1
                      AND x07.data_fiscal BETWEEN vp_data_ini AND vp_data_fim
                      AND x07.cod_sistema_orig = 'SAP'
                      AND x07.cod_empresa = x08.cod_empresa
                      AND x07.cod_estab = x08.cod_estab
                      AND x07.data_fiscal = x08.data_fiscal
                      AND x07.movto_e_s = x08.movto_e_s
                      AND x07.norm_dev = x08.norm_dev
                      AND x07.ident_docto = x08.ident_docto
                      AND x07.ident_fis_jur = x08.ident_fis_jur
                      AND x07.num_docfis = x08.num_docfis
                      AND x07.serie_docfis = x08.serie_docfis
                      AND x07.sub_serie_docfis = x08.sub_serie_docfis
                      AND NOT EXISTS
                              (SELECT 1
                                 FROM msafi.cst_doctofis_sap_msaf sap
                                WHERE 1 = 1
                                  AND sap.zzpstdat BETWEEN TO_CHAR ( vp_data_ini
                                                                   , 'yyyymmdd' )
                                                       AND TO_CHAR ( vp_data_fim
                                                                   , 'yyyymmdd' )
                                  AND sap.zzchave = p_id_processo
                                  AND sap.zzdocnum = x07.num_controle_docto
                                  AND TO_NUMBER ( sap.zzitmnum ) = x08.num_item) ) LOOP
            IF v_class = 'A' THEN
                v_class := 'B';
            ELSE
                v_class := 'A';
            END IF;

            v_text01 :=
                acc_planilha.linha (
                                     p_conteudo =>    acc_planilha.campo ( c.num_controle_docto )
                                                   || --
                                                     acc_planilha.campo ( c.num_docfis )
                                                   || --
                                                     acc_planilha.campo ( c.num_item )
                                                   || --
                                                     acc_planilha.campo ( c.cod_observacao )
                                                   || --
                                                     acc_planilha.campo ( c.dsc_observacao )
                                                   || --
                                                     acc_planilha.campo ( c.vlr_msaf )
                                                   || --
                                                     acc_planilha.campo ( c.vlr_sap )
                                                   || --
                                                     ''
                                   , p_class => v_class
                );

            lib_proc.add ( v_text01
                         , ptipo => p_tipo );

            COMMIT;
        END LOOP;

        FOR c IN ( SELECT x07.num_controle_docto
                        , x07.num_docfis
                        , x08.num_item
                        , x2013.ind_produto
                        , x2013.cod_produto
                        , x2012.cod_cfo
                        , x08.quantidade
                        , x08.vlr_item
                        , x08.vlr_unit
                        , TO_NUMBER ( sap.zzitmnum ) num_item_sap
                        , sap.zzcodmat cod_produto_sap
                        , sap.zzindprod ind_produto_sap
                        , SUBSTR ( sap.zzcfop
                                 , 1
                                 ,   INSTR ( sap.zzcfop
                                           , '/' )
                                   - 1 )
                              cod_cfo_sap
                        , sap.zzquantity / 1000000 quantidade_sap
                        , sap.zztotalval / 100 vlr_item_sap
                        , sap.zzvalitem / 10000 vlr_unit_sap
                     FROM msaf.x07_docto_fiscal x07
                        , msaf.x08_itens_merc x08
                        , msaf.x2013_produto x2013
                        , msaf.x2012_cod_fiscal x2012
                        , msafi.cst_doctofis_sap_msaf sap
                    WHERE 1 = 1
                      AND sap.zzpstdat BETWEEN TO_CHAR ( vp_data_ini
                                                       , 'yyyymmdd' )
                                           AND TO_CHAR ( vp_data_fim
                                                       , 'yyyymmdd' )
                      AND sap.zzchave = p_id_processo
                      AND sap.zznfesrv IS NULL -- mercadoria
                      AND sap.zzdocnum = x07.num_controle_docto
                      AND TO_NUMBER ( sap.zzitmnum ) = x08.num_item
                      AND x07.data_fiscal BETWEEN vp_data_ini AND vp_data_fim
                      AND x07.cod_sistema_orig = 'SAP'
                      AND x07.cod_empresa = x08.cod_empresa
                      AND x07.cod_estab = x08.cod_estab
                      AND x07.data_fiscal = x08.data_fiscal
                      AND x07.movto_e_s = x08.movto_e_s
                      AND x07.norm_dev = x08.norm_dev
                      AND x07.ident_docto = x08.ident_docto
                      AND x07.ident_fis_jur = x08.ident_fis_jur
                      AND x07.num_docfis = x08.num_docfis
                      AND x07.serie_docfis = x08.serie_docfis
                      AND x07.sub_serie_docfis = x08.sub_serie_docfis
                      AND x08.ident_produto = x2013.ident_produto(+)
                      AND x08.ident_cfo = x2012.ident_cfo(+)
                      --
                      AND ( NVL ( x2013.ind_produto, '-1' ) <> NVL ( sap.zzindprod, '-1' )
                        OR NVL ( x2013.cod_produto, '-1' ) <> NVL ( sap.zzcodmat, '-1' )
                        OR NVL ( x2012.cod_cfo, '-1' ) <> NVL ( SUBSTR ( sap.zzcfop
                                                                       , 1
                                                                       ,   INSTR ( sap.zzcfop
                                                                                 , '/' )
                                                                         - 1 )
                                                              , '-1' )
                        OR NVL ( x08.quantidade, -1 ) <> NVL ( ( sap.zzquantity / 1000000 ), -1 )
                        OR NVL ( x08.vlr_item, -1 ) <> NVL ( ( sap.zztotalval / 100 ), -1 )
                        OR NVL ( x08.vlr_unit, -1 ) <> NVL ( ( sap.zzvalitem / 10000 ), -1 ) ) ) LOOP
            IF NVL ( c.ind_produto, '-1' ) <> NVL ( c.ind_produto_sap, '-1' )
            OR NVL ( c.cod_produto, '-1' ) <> NVL ( c.cod_produto_sap, '-1' ) THEN
                v_cod_observacao := '2002';
                v_dsc_observacao := 'Dif produto';
                v_vlr_msaf := c.ind_produto || '-' || c.cod_produto;
                v_vlr_sap := c.ind_produto_sap || '-' || c.cod_produto_sap;

                IF v_class = 'A' THEN
                    v_class := 'B';
                ELSE
                    v_class := 'A';
                END IF;

                v_text01 :=
                    acc_planilha.linha (
                                         p_conteudo =>    acc_planilha.campo ( c.num_controle_docto )
                                                       || --
                                                         acc_planilha.campo ( c.num_docfis )
                                                       || --
                                                         acc_planilha.campo ( c.num_item )
                                                       || --
                                                         acc_planilha.campo ( v_cod_observacao )
                                                       || --
                                                         acc_planilha.campo ( v_dsc_observacao )
                                                       || --
                                                         acc_planilha.campo ( v_vlr_msaf )
                                                       || --
                                                         acc_planilha.campo ( v_vlr_sap )
                                                       || --
                                                         ''
                                       , p_class => v_class
                    );

                lib_proc.add ( v_text01
                             , ptipo => p_tipo );

                COMMIT;
            END IF;

            IF NVL ( c.cod_cfo, '-1' ) <> NVL ( c.cod_cfo_sap, '-1' ) THEN
                v_cod_observacao := '2003';
                v_dsc_observacao := 'Dif Cod CFO';
                v_vlr_msaf := c.cod_cfo;
                v_vlr_sap := c.cod_cfo_sap;

                IF v_class = 'A' THEN
                    v_class := 'B';
                ELSE
                    v_class := 'A';
                END IF;

                v_text01 :=
                    acc_planilha.linha (
                                         p_conteudo =>    acc_planilha.campo ( c.num_controle_docto )
                                                       || --
                                                         acc_planilha.campo ( c.num_docfis )
                                                       || --
                                                         acc_planilha.campo ( c.num_item )
                                                       || --
                                                         acc_planilha.campo ( v_cod_observacao )
                                                       || --
                                                         acc_planilha.campo ( v_dsc_observacao )
                                                       || --
                                                         acc_planilha.campo ( v_vlr_msaf )
                                                       || --
                                                         acc_planilha.campo ( v_vlr_sap )
                                                       || --
                                                         ''
                                       , p_class => v_class
                    );

                lib_proc.add ( v_text01
                             , ptipo => p_tipo );

                COMMIT;
            END IF;

            IF NVL ( c.quantidade, -1 ) <> NVL ( c.quantidade, -1 ) THEN
                v_cod_observacao := '2004';
                v_dsc_observacao := 'Dif Quantidade';
                v_vlr_msaf := c.quantidade;
                v_vlr_sap := c.quantidade_sap;

                IF v_class = 'A' THEN
                    v_class := 'B';
                ELSE
                    v_class := 'A';
                END IF;

                v_text01 :=
                    acc_planilha.linha (
                                         p_conteudo =>    acc_planilha.campo ( c.num_controle_docto )
                                                       || --
                                                         acc_planilha.campo ( c.num_docfis )
                                                       || --
                                                         acc_planilha.campo ( c.num_item )
                                                       || --
                                                         acc_planilha.campo ( v_cod_observacao )
                                                       || --
                                                         acc_planilha.campo ( v_dsc_observacao )
                                                       || --
                                                         acc_planilha.campo ( v_vlr_msaf )
                                                       || --
                                                         acc_planilha.campo ( v_vlr_sap )
                                                       || --
                                                         ''
                                       , p_class => v_class
                    );

                lib_proc.add ( v_text01
                             , ptipo => p_tipo );

                COMMIT;
            END IF;

            IF NVL ( c.vlr_item, -1 ) <> NVL ( c.vlr_item_sap, -1 ) THEN
                v_cod_observacao := '2005';
                v_dsc_observacao := 'Dif Valor Item';
                v_vlr_msaf := c.vlr_item;
                v_vlr_sap := c.vlr_item_sap;

                IF v_class = 'A' THEN
                    v_class := 'B';
                ELSE
                    v_class := 'A';
                END IF;

                v_text01 :=
                    acc_planilha.linha (
                                         p_conteudo =>    acc_planilha.campo ( c.num_controle_docto )
                                                       || --
                                                         acc_planilha.campo ( c.num_docfis )
                                                       || --
                                                         acc_planilha.campo ( c.num_item )
                                                       || --
                                                         acc_planilha.campo ( v_cod_observacao )
                                                       || --
                                                         acc_planilha.campo ( v_dsc_observacao )
                                                       || --
                                                         acc_planilha.campo ( v_vlr_msaf )
                                                       || --
                                                         acc_planilha.campo ( v_vlr_sap )
                                                       || --
                                                         ''
                                       , p_class => v_class
                    );

                lib_proc.add ( v_text01
                             , ptipo => p_tipo );

                COMMIT;
            END IF;

            IF NVL ( c.vlr_unit, '-1' ) <> NVL ( c.vlr_unit_sap, '-1' ) THEN
                v_cod_observacao := '2006';
                v_dsc_observacao := 'Dif Valor Unit';
                v_vlr_msaf := c.vlr_unit;
                v_vlr_sap := c.vlr_unit_sap;

                IF v_class = 'A' THEN
                    v_class := 'B';
                ELSE
                    v_class := 'A';
                END IF;

                v_text01 :=
                    acc_planilha.linha (
                                         p_conteudo =>    acc_planilha.campo ( c.num_controle_docto )
                                                       || --
                                                         acc_planilha.campo ( c.num_docfis )
                                                       || --
                                                         acc_planilha.campo ( c.num_item )
                                                       || --
                                                         acc_planilha.campo ( v_cod_observacao )
                                                       || --
                                                         acc_planilha.campo ( v_dsc_observacao )
                                                       || --
                                                         acc_planilha.campo ( v_vlr_msaf )
                                                       || --
                                                         acc_planilha.campo ( v_vlr_sap )
                                                       || --
                                                         ''
                                       , p_class => v_class
                    );

                lib_proc.add ( v_text01
                             , ptipo => p_tipo );

                COMMIT;
            END IF;
        END LOOP;

        FOR c IN ( SELECT sap.zzdocnum num_controle_docto
                        , sap.zznfenum num_docfis
                        , TO_NUMBER ( sap.zzitmnum ) num_item
                        , '3000' cod_observacao
                        , 'Item merc não existe no MSAF' dsc_observacao
                        , NULL vlr_msaf
                        , sap.zzitmnum vlr_sap
                     FROM msafi.cst_doctofis_sap_msaf sap
                    WHERE 1 = 1
                      AND sap.zzpstdat BETWEEN TO_CHAR ( vp_data_ini
                                                       , 'yyyymmdd' )
                                           AND TO_CHAR ( vp_data_fim
                                                       , 'yyyymmdd' )
                      AND sap.zzchave = p_id_processo
                      AND sap.zznfesrv IS NOT NULL -- servico
                      AND NOT EXISTS
                              (SELECT 1
                                 FROM msaf.x07_docto_fiscal x07
                                    , msaf.x09_itens_serv x09
                                WHERE 1 = 1
                                  AND x07.data_fiscal(+) BETWEEN vp_data_ini AND vp_data_fim
                                  AND x07.cod_sistema_orig = 'SAP'
                                  AND x07.cod_empresa = x09.cod_empresa
                                  AND x07.cod_estab = x09.cod_estab
                                  AND x07.data_fiscal = x09.data_fiscal
                                  AND x07.movto_e_s = x09.movto_e_s
                                  AND x07.norm_dev = x09.norm_dev
                                  AND x07.ident_docto = x09.ident_docto
                                  AND x07.ident_fis_jur = x09.ident_fis_jur
                                  AND x07.num_docfis = x09.num_docfis
                                  AND x07.serie_docfis = x09.serie_docfis
                                  AND x07.sub_serie_docfis = x09.sub_serie_docfis
                                  AND sap.zzdocnum = x07.num_controle_docto
                                  AND TO_NUMBER ( sap.zzitmnum ) = x09.num_item) ) LOOP
            IF v_class = 'A' THEN
                v_class := 'B';
            ELSE
                v_class := 'A';
            END IF;

            v_text01 :=
                acc_planilha.linha (
                                     p_conteudo =>    acc_planilha.campo ( c.num_controle_docto )
                                                   || --
                                                     acc_planilha.campo ( c.num_docfis )
                                                   || --
                                                     acc_planilha.campo ( c.num_item )
                                                   || --
                                                     acc_planilha.campo ( c.cod_observacao )
                                                   || --
                                                     acc_planilha.campo ( c.dsc_observacao )
                                                   || --
                                                     acc_planilha.campo ( c.vlr_msaf )
                                                   || --
                                                     acc_planilha.campo ( c.vlr_sap )
                                                   || --
                                                     ''
                                   , p_class => v_class
                );

            lib_proc.add ( v_text01
                         , ptipo => p_tipo );

            COMMIT;
        END LOOP;

        FOR c IN ( SELECT x07.num_controle_docto
                        , x07.num_docfis
                        , x09.num_item num_item
                        , '3001' cod_observacao
                        , 'Item merc não existe no SAP' dsc_observacao
                        , x09.num_item vlr_msaf
                        , NULL vlr_sap
                     FROM msaf.x07_docto_fiscal x07
                        , msaf.x09_itens_serv x09
                    WHERE 1 = 1
                      AND x07.data_fiscal BETWEEN vp_data_ini AND vp_data_fim
                      AND x07.cod_sistema_orig = 'SAP'
                      AND x07.cod_empresa = x09.cod_empresa
                      AND x07.cod_estab = x09.cod_estab
                      AND x07.data_fiscal = x09.data_fiscal
                      AND x07.movto_e_s = x09.movto_e_s
                      AND x07.norm_dev = x09.norm_dev
                      AND x07.ident_docto = x09.ident_docto
                      AND x07.ident_fis_jur = x09.ident_fis_jur
                      AND x07.num_docfis = x09.num_docfis
                      AND x07.serie_docfis = x09.serie_docfis
                      AND x07.sub_serie_docfis = x09.sub_serie_docfis
                      AND NOT EXISTS
                              (SELECT 1
                                 FROM msafi.cst_doctofis_sap_msaf sap
                                WHERE 1 = 1
                                  AND sap.zzpstdat BETWEEN TO_CHAR ( vp_data_ini
                                                                   , 'yyyymmdd' )
                                                       AND TO_CHAR ( vp_data_fim
                                                                   , 'yyyymmdd' )
                                  AND sap.zzchave = p_id_processo
                                  AND sap.zzdocnum = x07.num_controle_docto
                                  AND TO_NUMBER ( sap.zzitmnum ) = x09.num_item) ) LOOP
            IF v_class = 'A' THEN
                v_class := 'B';
            ELSE
                v_class := 'A';
            END IF;

            v_text01 :=
                acc_planilha.linha (
                                     p_conteudo =>    acc_planilha.campo ( c.num_controle_docto )
                                                   || --
                                                     acc_planilha.campo ( c.num_docfis )
                                                   || --
                                                     acc_planilha.campo ( c.num_item )
                                                   || --
                                                     acc_planilha.campo ( c.cod_observacao )
                                                   || --
                                                     acc_planilha.campo ( c.dsc_observacao )
                                                   || --
                                                     acc_planilha.campo ( c.vlr_msaf )
                                                   || --
                                                     acc_planilha.campo ( c.vlr_sap )
                                                   || --
                                                     ''
                                   , p_class => v_class
                );

            lib_proc.add ( v_text01
                         , ptipo => p_tipo );

            COMMIT;
        END LOOP;

        FOR c IN ( SELECT x07.num_controle_docto
                        , x07.num_docfis
                        , x09.num_item
                        , x2018.cod_servico
                        , x2012.cod_cfo
                        , x09.quantidade
                        , x09.vlr_servico
                        , x09.vlr_unit
                        , TO_NUMBER ( sap.zzitmnum ) num_item_sap
                        , sap.zzcodmat cod_servico_sap
                        , sap.zzindprod ind_servico_sap
                        , SUBSTR ( sap.zzcfop
                                 , 1
                                 ,   INSTR ( sap.zzcfop
                                           , '/' )
                                   - 1 )
                              cod_cfo_sap
                        , sap.zzquantity / 1000000 quantidade_sap
                        , sap.zztotalval / 100 vlr_servico_sap
                        , sap.zzvalitem / 10000 vlr_unit_sap
                     FROM msaf.x07_docto_fiscal x07
                        , msaf.x09_itens_serv x09
                        , msaf.x2018_servicos x2018
                        , msaf.x2012_cod_fiscal x2012
                        , msafi.cst_doctofis_sap_msaf sap
                    WHERE 1 = 1
                      AND sap.zzpstdat BETWEEN TO_CHAR ( vp_data_ini
                                                       , 'yyyymmdd' )
                                           AND TO_CHAR ( vp_data_fim
                                                       , 'yyyymmdd' )
                      AND sap.zzchave = p_id_processo
                      AND sap.zznfesrv IS NOT NULL -- servico
                      AND sap.zzdocnum = x07.num_controle_docto
                      AND TO_NUMBER ( sap.zzitmnum ) = x09.num_item
                      AND x07.data_fiscal BETWEEN vp_data_ini AND vp_data_fim
                      AND x07.cod_sistema_orig = 'SAP'
                      AND x07.cod_empresa = x09.cod_empresa
                      AND x07.cod_estab = x09.cod_estab
                      AND x07.data_fiscal = x09.data_fiscal
                      AND x07.movto_e_s = x09.movto_e_s
                      AND x07.norm_dev = x09.norm_dev
                      AND x07.ident_docto = x09.ident_docto
                      AND x07.ident_fis_jur = x09.ident_fis_jur
                      AND x07.num_docfis = x09.num_docfis
                      AND x07.serie_docfis = x09.serie_docfis
                      AND x07.sub_serie_docfis = x09.sub_serie_docfis
                      AND x09.ident_servico = x2018.ident_servico(+)
                      AND x09.ident_cfo = x2012.ident_cfo(+)
                      --
                      AND ( NVL ( x2018.cod_servico, '-1' ) <> NVL ( sap.zzcodmat, '-1' ) --
                        OR NVL ( x2012.cod_cfo, '-1' ) <> NVL ( SUBSTR ( sap.zzcfop
                                                                       , 1
                                                                       ,   INSTR ( sap.zzcfop
                                                                                 , '/' )
                                                                         - 1 )
                                                              , '-1' ) --
                        OR NVL ( x09.quantidade, -1 ) <> NVL ( ( sap.zzquantity / 1000000 ), -1 ) --
                        OR NVL ( x09.vlr_servico, -1 ) <> NVL ( ( sap.zztotalval / 100 ), -1 ) --
                        OR NVL ( x09.vlr_unit, -1 ) <> NVL ( ( sap.zzvalitem / 10000 ), -1 ) ) ) LOOP
            IF NVL ( c.cod_servico, '-1' ) <> NVL ( c.cod_servico_sap, '-1' ) THEN
                v_cod_observacao := '3002';
                v_dsc_observacao := 'Dif servico';
                v_vlr_msaf := c.cod_servico;
                v_vlr_sap := c.cod_servico_sap;

                IF v_class = 'A' THEN
                    v_class := 'B';
                ELSE
                    v_class := 'A';
                END IF;

                v_text01 :=
                    acc_planilha.linha (
                                         p_conteudo =>    acc_planilha.campo ( c.num_controle_docto )
                                                       || --
                                                         acc_planilha.campo ( c.num_docfis )
                                                       || --
                                                         acc_planilha.campo ( c.num_item )
                                                       || --
                                                         acc_planilha.campo ( v_cod_observacao )
                                                       || --
                                                         acc_planilha.campo ( v_dsc_observacao )
                                                       || --
                                                         acc_planilha.campo ( v_vlr_msaf )
                                                       || --
                                                         acc_planilha.campo ( v_vlr_sap )
                                                       || --
                                                         ''
                                       , p_class => v_class
                    );

                lib_proc.add ( v_text01
                             , ptipo => p_tipo );

                COMMIT;
            END IF;

            IF NVL ( c.cod_cfo, '-1' ) <> NVL ( c.cod_cfo_sap, '-1' ) THEN
                v_cod_observacao := '3003';
                v_dsc_observacao := 'Dif Cod CFO';
                v_vlr_msaf := c.cod_cfo;
                v_vlr_sap := c.cod_cfo_sap;

                IF v_class = 'A' THEN
                    v_class := 'B';
                ELSE
                    v_class := 'A';
                END IF;

                v_text01 :=
                    acc_planilha.linha (
                                         p_conteudo =>    acc_planilha.campo ( c.num_controle_docto )
                                                       || --
                                                         acc_planilha.campo ( c.num_docfis )
                                                       || --
                                                         acc_planilha.campo ( c.num_item )
                                                       || --
                                                         acc_planilha.campo ( v_cod_observacao )
                                                       || --
                                                         acc_planilha.campo ( v_dsc_observacao )
                                                       || --
                                                         acc_planilha.campo ( v_vlr_msaf )
                                                       || --
                                                         acc_planilha.campo ( v_vlr_sap )
                                                       || --
                                                         ''
                                       , p_class => v_class
                    );

                lib_proc.add ( v_text01
                             , ptipo => p_tipo );

                COMMIT;
            END IF;

            IF NVL ( c.quantidade, -1 ) <> NVL ( c.quantidade, -1 ) THEN
                v_cod_observacao := '3004';
                v_dsc_observacao := 'Dif Quantidade';
                v_vlr_msaf := c.quantidade;
                v_vlr_sap := c.quantidade_sap;

                IF v_class = 'A' THEN
                    v_class := 'B';
                ELSE
                    v_class := 'A';
                END IF;

                v_text01 :=
                    acc_planilha.linha (
                                         p_conteudo =>    acc_planilha.campo ( c.num_controle_docto )
                                                       || --
                                                         acc_planilha.campo ( c.num_docfis )
                                                       || --
                                                         acc_planilha.campo ( c.num_item )
                                                       || --
                                                         acc_planilha.campo ( v_cod_observacao )
                                                       || --
                                                         acc_planilha.campo ( v_dsc_observacao )
                                                       || --
                                                         acc_planilha.campo ( v_vlr_msaf )
                                                       || --
                                                         acc_planilha.campo ( v_vlr_sap )
                                                       || --
                                                         ''
                                       , p_class => v_class
                    );

                lib_proc.add ( v_text01
                             , ptipo => p_tipo );

                COMMIT;
            END IF;

            IF NVL ( c.vlr_servico, -1 ) <> NVL ( c.vlr_servico_sap, -1 ) THEN
                v_cod_observacao := '3005';
                v_dsc_observacao := 'Dif Valor Item';
                v_vlr_msaf := c.vlr_servico;
                v_vlr_sap := c.vlr_servico_sap;

                IF v_class = 'A' THEN
                    v_class := 'B';
                ELSE
                    v_class := 'A';
                END IF;

                v_text01 :=
                    acc_planilha.linha (
                                         p_conteudo =>    acc_planilha.campo ( c.num_controle_docto )
                                                       || --
                                                         acc_planilha.campo ( c.num_docfis )
                                                       || --
                                                         acc_planilha.campo ( c.num_item )
                                                       || --
                                                         acc_planilha.campo ( v_cod_observacao )
                                                       || --
                                                         acc_planilha.campo ( v_dsc_observacao )
                                                       || --
                                                         acc_planilha.campo ( v_vlr_msaf )
                                                       || --
                                                         acc_planilha.campo ( v_vlr_sap )
                                                       || --
                                                         ''
                                       , p_class => v_class
                    );

                lib_proc.add ( v_text01
                             , ptipo => p_tipo );

                COMMIT;
            END IF;

            IF NVL ( c.vlr_unit, '-1' ) <> NVL ( c.vlr_unit_sap, '-1' ) THEN
                v_cod_observacao := '3006';
                v_dsc_observacao := 'Dif Valor Unit';
                v_vlr_msaf := c.vlr_unit;
                v_vlr_sap := c.vlr_unit_sap;

                IF v_class = 'A' THEN
                    v_class := 'B';
                ELSE
                    v_class := 'A';
                END IF;

                v_text01 :=
                    acc_planilha.linha (
                                         p_conteudo =>    acc_planilha.campo ( c.num_controle_docto )
                                                       || --
                                                         acc_planilha.campo ( c.num_docfis )
                                                       || --
                                                         acc_planilha.campo ( c.num_item )
                                                       || --
                                                         acc_planilha.campo ( v_cod_observacao )
                                                       || --
                                                         acc_planilha.campo ( v_dsc_observacao )
                                                       || --
                                                         acc_planilha.campo ( v_vlr_msaf )
                                                       || --
                                                         acc_planilha.campo ( v_vlr_sap )
                                                       || --
                                                         ''
                                       , p_class => v_class
                    );

                lib_proc.add ( v_text01
                             , ptipo => p_tipo );

                COMMIT;
            END IF;
        END LOOP;

        grava ( acc_planilha.tabela_fim
              , p_tipo );
    END;

    FUNCTION executar ( p_data_ini DATE
                      , p_data_fim DATE
                      , p_id_processo VARCHAR2 )
        RETURN INTEGER
    IS
        p_tipo INTEGER := 1;
    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS='',.'' ';

        EXECUTE IMMEDIATE 'ALTER SESSION SET CURSOR_SHARING = FORCE';

        mproc_id := lib_proc.new ( psp_nome => $$plsql_unit );

        dbms_application_info.set_module ( $$plsql_unit
                                         , 'PROC_ID: ' || mproc_id );

        loga (    'Data execução: '
               || TO_CHAR ( SYSDATE
                          , 'dd/mm/yyyy hh24:mi:ss' )
             , FALSE );
        loga ( 'Usuário: ' || musuario
             , FALSE );
        loga ( 'Empresa: ' || mcod_empresa
             , FALSE );
        loga ( 'Período: ' || p_data_ini || ' a ' || p_data_fim
             , FALSE );
        loga ( '----------------------------------------'
             , FALSE );

        grava_analitico ( p_data_ini
                        , p_data_fim
                        , p_id_processo
                        , p_tipo );

        lib_proc.close;
        COMMIT;
        RETURN mproc_id;
    EXCEPTION
        WHEN OTHERS THEN
            loga ( 'SQLERRM: ' || SQLERRM
                 , FALSE );

            lib_proc.add_log ( 'ERRO NÃO TRATADO: ' || dbms_utility.format_error_backtrace
                             , 1 );
            lib_proc.add_log ( 'SQLERRM: ' || SQLERRM
                             , 1 );
            COMMIT;

            lib_proc.close ( );

            RETURN mproc_id;
    END; /* FUNCTION EXECUTAR */
END cst_rel_conf_sap_cproc;
/
SHOW ERRORS;
