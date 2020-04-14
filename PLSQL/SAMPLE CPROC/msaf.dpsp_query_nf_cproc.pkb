Prompt Package Body DPSP_QUERY_NF_CPROC;
--
-- DPSP_QUERY_NF_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_query_nf_cproc
IS
    mnm_usuario usuario_estab.cod_usuario%TYPE;
    mcod_empresa estabelecimento.cod_empresa%TYPE;

    tab_query tab_query_ot := tab_query_ot ( );

    TYPE a_estab_t IS TABLE OF VARCHAR2 ( 6 );

    a_estab a_estab_t := a_estab_t ( );

    mproc_id INTEGER;
    mnm_tipo VARCHAR2 ( 100 ) := 'Fechamento';
    mnm_cproc VARCHAR2 ( 100 ) := '1 - QUERY de Notas Fiscais';
    mds_cproc VARCHAR2 ( 100 ) := 'Consulta de Notas Fiscais utilizando critérios variados';

    v_sel_data_fim VARCHAR2 ( 260 )
        := 'SELECT TRUNC( TO_DATE( :1 ,''DD/MM/YYYY'') + ROWNUM - 1) AS DATA_FIM, TRUNC( TO_DATE( :1 ,''DD/MM/YYYY'') + ROWNUM - 1) AS DATA_FIM FROM DUAL CONNECT BY ROWNUM <= LAST_DAY( TO_DATE( :1 ,''DD/MM/YYYY'') ) - TO_DATE( :1 ,''DD/MM/YYYY'') + 1 ORDER BY 1 DESC ';

    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 2000 );
    BEGIN
        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        mnm_usuario := lib_parametros.recuperar ( 'USUARIO' );

        lib_proc.add_param ( pstr
                           , 'Data Inicial'
                           , --P_DATA_INI
                            'DATE'
                           , 'TEXTBOX'
                           , 'S'
                           , NULL
                           , 'DD/MM/YYYY' );

        lib_proc.add_param ( pstr
                           , 'Data Final'
                           , --P_DATA_FIM
                            'VARCHAR2'
                           , 'COMBOBOX'
                           , 'S'
                           , NULL
                           , '##########'
                           , v_sel_data_fim );

        lib_proc.add_param (
                             pstr
                           , 'NF Movimento'
                           , --p_movto_e_s
                            'VARCHAR2'
                           , 'COMBOBOX'
                           , 'S'
                           , 'A'
                           , '####################'
                           ,    ' SELECT ''A'',''1 - Entrada/Saída'' FROM DUAL '
                             || ' UNION SELECT ''E'',''2 - Entrada'' FROM DUAL '
                             || ' UNION SELECT ''S'',''3 - Saída'' FROM DUAL '
        );

        lib_proc.add_param ( pstr
                           , 'Sumarizar por Capa da NF / CFOP'
                           , --p_capa
                            'VARCHAR2'
                           , 'CHECKBOX'
                           , 'N'
                           , 'N'
                           , NULL );

        lib_proc.add_param ( pstr
                           , 'Separar arquivos por Estabelecimento'
                           , --p_separa
                            'VARCHAR2'
                           , 'CHECKBOX'
                           , 'N'
                           , 'N'
                           , NULL );

        lib_proc.add_param (
                             pstr
                           ,    '                                   '
                             || '____________________________________________________'
                           , 'VARCHAR2'
                           , 'TEXT'
        );

        lib_proc.add_param ( pstr
                           , 'Pesquisa Chave, Alíq ou Origem'
                           , --p_livre
                            'VARCHAR2'
                           , 'TEXTBOX'
                           , 'N'
                           , NULL
                           , '00000000000000000000000000000000000000000000' );

        lib_proc.add_param ( pstr
                           , 'CFOP'
                           , --p_cfop
                            'VARCHAR2'
                           , 'TEXTBOX'
                           , 'N'
                           , '%'
                           , '######' );

        lib_proc.add_param ( pstr
                           , 'Finalidade'
                           , --p_fin
                            'VARCHAR2'
                           , 'TEXTBOX'
                           , 'N'
                           , '%'
                           , '######' );

        lib_proc.add_param ( pstr
                           , 'CST'
                           , --p_cst
                            'VARCHAR2'
                           , 'TEXTBOX'
                           , 'N'
                           , '%'
                           , '######' );

        lib_proc.add_param (
                             pstr
                           , 'UF Destino / Origem'
                           , --p_uf_destino
                            'VARCHAR2'
                           , 'COMBOBOX'
                           , 'N'
                           , '%'
                           , '#########'
                           , 'SELECT DISTINCT A.COD_ESTADO, A.COD_ESTADO FROM MSAFI.DSP_ESTABELECIMENTO A UNION ALL SELECT ''%'', ''--TODAS--'' FROM DUAL ORDER BY 1'
        );

        lib_proc.add_param (
                             pstr
                           ,    '                                   '
                             || '____________________________________________________'
                           , 'VARCHAR2'
                           , 'TEXT'
        );

        lib_proc.add_param (
                             pstr
                           , 'UF'
                           , --P_UF
                            'VARCHAR2'
                           , 'COMBOBOX'
                           , 'S'
                           , '%'
                           , '#########'
                           , 'SELECT DISTINCT A.COD_ESTADO, A.COD_ESTADO FROM MSAFI.DSP_ESTABELECIMENTO A UNION ALL SELECT ''%'', ''--TODAS--'' FROM DUAL ORDER BY 1'
        );

        lib_proc.add_param (
                             pstr
                           , 'Estabelecimentos'
                           , --p_cod_estab
                            'VARCHAR2'
                           , 'MULTISELECT'
                           , 'S'
                           , NULL
                           , NULL
                           ,    'SELECT A.COD_ESTAB, A.COD_ESTAB || '' - '' || B.COD_ESTADO || '' - '' || A.CGC || '' - '' || INITCAP(A.BAIRRO) || '' / '' || INITCAP(A.CIDADE) FROM ESTABELECIMENTO A, ESTADO B, MSAFI.DSP_ESTABELECIMENTO C WHERE A.COD_EMPRESA  = '''
                             || mcod_empresa
                             || ''' AND B.IDENT_ESTADO = A.IDENT_ESTADO AND A.COD_EMPRESA = C.COD_EMPRESA AND A.COD_ESTAB = C.COD_ESTAB AND B.COD_ESTADO LIKE :13 ORDER BY B.COD_ESTADO, A.COD_ESTAB'
        );

        RETURN pstr;
    END;

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
    END;

    FUNCTION moeda ( v_conteudo NUMBER )
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN TRIM ( TO_CHAR ( v_conteudo
                              , '9g999g999g990d00' ) );
    END;

    FUNCTION getpartition ( p_owner IN VARCHAR2
                          , p_table_name IN VARCHAR2
                          , p_data_ref IN DATE )
        RETURN VARCHAR2
    IS
        v_tab_partition VARCHAR2 ( 60 );
        v_dt_ini DATE
            := TO_DATE (    '01'
                         || TO_CHAR ( p_data_ref
                                    , 'mmyyyy' )
                       , 'ddmmyyyy' );
        v_dt_fim DATE := LAST_DAY ( p_data_ref );
    BEGIN
        --OBTER NOME DA PARTICAO
        BEGIN
            SELECT ' partition ( ' || a.partition_name || ') '
              INTO v_tab_partition
              FROM TABLE ( msafi.dpsp_recupera_particao ( UPPER ( p_owner )
                                                        , UPPER ( p_table_name )
                                                        , v_dt_ini
                                                        , v_dt_fim ) ) a;
        EXCEPTION
            WHEN OTHERS THEN
                v_tab_partition := ' ';
        END;

        RETURN v_tab_partition;
    END;

    FUNCTION preparesql ( p_movto_e_s IN VARCHAR2
                        , p_livre IN VARCHAR2
                        , p_cfop IN VARCHAR2
                        , p_fin IN VARCHAR2
                        , p_cst IN VARCHAR2
                        , p_uf_destino IN VARCHAR2
                        , p_data_ini IN DATE
                        , v_tipo_campo IN VARCHAR2 )
        RETURN VARCHAR2
    IS
        v_sql VARCHAR2 ( 8000 );
    BEGIN
        v_sql := 'select ''' || mproc_id || ''' as mprocid, x07.cod_empresa, x07.cod_estab, est.cod_estado, ';
        v_sql := v_sql || '    decode(x07.movto_e_s,''9'',''S'',''E'') as movto_e_s, ';
        v_sql := v_sql || '    x07.data_fiscal, x04.cod_fis_jur, uf_d.cod_estado as uf_fis_jur, ';
        v_sql := v_sql || '    x04.nome_fantasia, x04.cpf_cgc, x04.insc_estadual, ';
        v_sql :=
               v_sql
            || '    x07.num_autentic_nfe, x07.cod_sistema_orig, x2013.cod_produto, x2013.descricao, x08.num_item, ';
        v_sql :=
            v_sql || '    fin.cod_natureza_op, cfop.cod_cfo, cst.cod_situacao_b, x08.vlr_contab_item, x08.quantidade, ';
        v_sql :=
            v_sql || '    x08.vlr_unit, x08.vlr_pis, x08.vlr_cofins, x08.vlr_icmss_n_escrit, x08.vlr_icmss_ndestac, ';
        v_sql := v_sql || '    x08.vlr_outras, x08.vlr_ipi_ndestac, ';
        v_sql := v_sql || '    nvl((select b.vlr_base  ';
        v_sql :=
               v_sql
            || '        from msaf.x08_base_merc '
            || getpartition ( 'MSAF'
                            , 'X08_BASE_MERC'
                            , p_data_ini )
            || ' b ';
        v_sql := v_sql || '        where b.cod_empresa      = x08.cod_empresa  ';
        v_sql := v_sql || '          and b.cod_estab        = x08.cod_estab  ';
        v_sql := v_sql || '          and b.data_fiscal      = x08.data_fiscal  ';
        v_sql := v_sql || '          and b.movto_e_s        = x08.movto_e_s  ';
        v_sql := v_sql || '          and b.norm_dev         = x08.norm_dev  ';
        v_sql := v_sql || '          and b.ident_docto      = x08.ident_docto  ';
        v_sql := v_sql || '          and b.ident_fis_jur    = x08.ident_fis_jur  ';
        v_sql := v_sql || '          and b.num_docfis       = x08.num_docfis  ';
        v_sql := v_sql || '          and b.serie_docfis     = x08.serie_docfis  ';
        v_sql := v_sql || '          and b.sub_serie_docfis = x08.sub_serie_docfis ';
        v_sql := v_sql || '          and b.discri_item      = x08.discri_item  ';
        v_sql := v_sql || '          and b.cod_tributacao   = ''1''  ';
        v_sql := v_sql || '          and b.cod_tributo      = ''ICMS''),0) vlr_base_icms, ';
        v_sql := v_sql || '    nvl((select b.aliq_tributo  ';
        v_sql :=
               v_sql
            || '        from msaf.x08_trib_merc '
            || getpartition ( 'MSAF'
                            , 'X08_TRIB_MERC'
                            , p_data_ini )
            || ' b ';
        v_sql := v_sql || '        where b.cod_empresa      = x08.cod_empresa  ';
        v_sql := v_sql || '          and b.cod_estab        = x08.cod_estab  ';
        v_sql := v_sql || '          and b.data_fiscal      = x08.data_fiscal  ';
        v_sql := v_sql || '          and b.movto_e_s        = x08.movto_e_s  ';
        v_sql := v_sql || '          and b.norm_dev         = x08.norm_dev  ';
        v_sql := v_sql || '          and b.ident_docto      = x08.ident_docto  ';
        v_sql := v_sql || '          and b.ident_fis_jur    = x08.ident_fis_jur  ';
        v_sql := v_sql || '          and b.num_docfis       = x08.num_docfis  ';
        v_sql := v_sql || '          and b.serie_docfis     = x08.serie_docfis  ';
        v_sql := v_sql || '          and b.sub_serie_docfis = x08.sub_serie_docfis ';
        v_sql := v_sql || '          and b.discri_item      = x08.discri_item  ';
        v_sql := v_sql || '          and b.cod_tributo      = ''ICMS''),0) aliq_icms, ';
        v_sql := v_sql || '    nvl((select b.vlr_tributo  ';
        v_sql :=
               v_sql
            || '        from msaf.x08_trib_merc '
            || getpartition ( 'MSAF'
                            , 'X08_TRIB_MERC'
                            , p_data_ini )
            || ' b ';
        v_sql := v_sql || '        where b.cod_empresa      = x08.cod_empresa  ';
        v_sql := v_sql || '          and b.cod_estab        = x08.cod_estab  ';
        v_sql := v_sql || '          and b.data_fiscal      = x08.data_fiscal  ';
        v_sql := v_sql || '          and b.movto_e_s        = x08.movto_e_s  ';
        v_sql := v_sql || '          and b.norm_dev         = x08.norm_dev  ';
        v_sql := v_sql || '          and b.ident_docto      = x08.ident_docto  ';
        v_sql := v_sql || '          and b.ident_fis_jur    = x08.ident_fis_jur  ';
        v_sql := v_sql || '          and b.num_docfis       = x08.num_docfis  ';
        v_sql := v_sql || '          and b.serie_docfis     = x08.serie_docfis  ';
        v_sql := v_sql || '          and b.sub_serie_docfis = x08.sub_serie_docfis ';
        v_sql := v_sql || '          and b.discri_item      = x08.discri_item  ';
        v_sql := v_sql || '          and b.cod_tributo      = ''ICMS''),0) vlr_icms, ';
        v_sql := v_sql || '    nvl((select b.vlr_base  ';
        v_sql :=
               v_sql
            || '        from msaf.x08_base_merc '
            || getpartition ( 'MSAF'
                            , 'X08_BASE_MERC'
                            , p_data_ini )
            || ' b  ';
        v_sql := v_sql || '        where b.cod_empresa      = x08.cod_empresa  ';
        v_sql := v_sql || '          and b.cod_estab        = x08.cod_estab  ';
        v_sql := v_sql || '          and b.data_fiscal      = x08.data_fiscal  ';
        v_sql := v_sql || '          and b.movto_e_s        = x08.movto_e_s  ';
        v_sql := v_sql || '          and b.norm_dev         = x08.norm_dev  ';
        v_sql := v_sql || '          and b.ident_docto      = x08.ident_docto  ';
        v_sql := v_sql || '          and b.ident_fis_jur    = x08.ident_fis_jur  ';
        v_sql := v_sql || '          and b.num_docfis       = x08.num_docfis  ';
        v_sql := v_sql || '          and b.serie_docfis     = x08.serie_docfis  ';
        v_sql := v_sql || '          and b.sub_serie_docfis = x08.sub_serie_docfis ';
        v_sql := v_sql || '          and b.discri_item      = x08.discri_item  ';
        v_sql := v_sql || '          and b.cod_tributacao   = ''1''  ';
        v_sql := v_sql || '          and b.cod_tributo      = ''ICMS-S''),0) vlr_base_icms_st, ';
        v_sql := v_sql || '    nvl((select b.vlr_tributo  ';
        v_sql :=
               v_sql
            || '        from msaf.x08_trib_merc '
            || getpartition ( 'MSAF'
                            , 'X08_TRIB_MERC'
                            , p_data_ini )
            || ' b ';
        v_sql := v_sql || '        where b.cod_empresa      = x08.cod_empresa  ';
        v_sql := v_sql || '          and b.cod_estab        = x08.cod_estab  ';
        v_sql := v_sql || '          and b.data_fiscal      = x08.data_fiscal  ';
        v_sql := v_sql || '          and b.movto_e_s        = x08.movto_e_s  ';
        v_sql := v_sql || '          and b.norm_dev         = x08.norm_dev  ';
        v_sql := v_sql || '          and b.ident_docto      = x08.ident_docto  ';
        v_sql := v_sql || '          and b.ident_fis_jur    = x08.ident_fis_jur  ';
        v_sql := v_sql || '          and b.num_docfis       = x08.num_docfis  ';
        v_sql := v_sql || '          and b.serie_docfis     = x08.serie_docfis  ';
        v_sql := v_sql || '          and b.sub_serie_docfis = x08.sub_serie_docfis ';
        v_sql := v_sql || '          and b.discri_item      = x08.discri_item  ';
        v_sql := v_sql || '          and b.cod_tributo      = ''ICMS-S''),0) vlr_icms_st, ';
        v_sql := v_sql || '    (select decode(lis.lista,''P'',''POSITIVA'',''N'',''NEGATIVA'',''NEUTRA'') ';
        v_sql := v_sql || '     from msaf.dpsp_ps_lista lis ';
        v_sql := v_sql || '     where lis.cod_produto = x2013.cod_produto ';
        v_sql := v_sql || '       and lis.effdt = (select max(ll.effdt)  ';
        v_sql := v_sql || '                        from msaf.dpsp_ps_lista ll  ';
        v_sql := v_sql || '                        where ll.cod_produto = lis.cod_produto ';
        v_sql := v_sql || '                          and ll.effdt <= x07.data_fiscal)) lista_medicamento ';
        v_sql :=
               v_sql
            || 'from msaf.x07_docto_fiscal '
            || getpartition ( 'MSAF'
                            , 'X07_DOCTO_FISCAL'
                            , p_data_ini )
            || ' x07, ';
        v_sql :=
               v_sql
            || '    msaf.x08_itens_merc '
            || getpartition ( 'MSAF'
                            , 'X08_ITENS_MERC'
                            , p_data_ini )
            || ' x08, ';
        v_sql := v_sql || '    msaf.x04_pessoa_fis_jur x04, ';
        v_sql := v_sql || '    msaf.x2013_produto x2013, ';
        v_sql := v_sql || '    msaf.x2006_natureza_op fin, ';
        v_sql := v_sql || '    msaf.x2012_cod_fiscal cfop, ';
        v_sql := v_sql || '    msaf.y2026_sit_trb_uf_b cst, ';
        v_sql := v_sql || '    msafi.dsp_estabelecimento est, ';
        v_sql := v_sql || '    msaf.estado uf_d ';
        v_sql := v_sql || 'where x07.cod_empresa      = x08.cod_empresa ';
        v_sql := v_sql || '  and x07.cod_estab        = x08.cod_estab ';
        v_sql := v_sql || '  and x07.data_fiscal      = x08.data_fiscal ';
        v_sql := v_sql || '  and x07.movto_e_s        = x08.movto_e_s ';
        v_sql := v_sql || '  and x07.norm_dev         = x08.norm_dev ';
        v_sql := v_sql || '  and x07.ident_docto      = x08.ident_docto ';
        v_sql := v_sql || '  and x07.ident_fis_jur    = x08.ident_fis_jur ';
        v_sql := v_sql || '  and x07.num_docfis       = x08.num_docfis ';
        v_sql := v_sql || '  and x07.serie_docfis     = x08.serie_docfis ';
        v_sql := v_sql || '  and x07.sub_serie_docfis = x08.sub_serie_docfis ';
        ---
        v_sql := v_sql || '  and x07.cod_empresa      = msafi.dpsp.empresa ';
        v_sql := v_sql || '  and x07.cod_estab        = :1 ';

        IF ( p_movto_e_s = 'E' ) THEN
            v_sql := v_sql || '  and x07.movto_e_s       <> ''9'' ';
        ELSIF ( p_movto_e_s = 'S' ) THEN
            v_sql := v_sql || '  and x07.movto_e_s        = ''9'' ';
        END IF;

        v_sql := v_sql || '  and x07.situacao         = ''N'' ';

        IF ( v_tipo_campo = 'CHAVE' ) THEN
            v_sql := v_sql || '  and x07.num_autentic_nfe = ''' || p_livre || ''' ';
        END IF;

        IF ( v_tipo_campo = 'ORIGEM' ) THEN
            IF ( UPPER ( p_livre ) = 'SAP' ) THEN
                v_sql := v_sql || '  and x07.cod_sistema_orig = ''SAP'' ';
            ELSE
                v_sql := v_sql || '  and x07.cod_sistema_orig in (''PS-E'',''PS-S'') ';
            END IF;
        END IF;

        v_sql := v_sql || '  and x07.data_fiscal between :2 and :3 ';
        v_sql :=
               v_sql
            || '  and x07.ident_docto in (select ident_docto from msaf.x2005_tipo_docto where cod_docto not in (''CF'',''CF-E'',''SAT'')) ';

        ---
        IF ( p_cfop <> '%'
        AND v_tipo_campo <> 'CHAVE' ) THEN
            v_sql := v_sql || '  and cfop.cod_cfo = ''' || p_cfop || ''' ';
        END IF;

        ---
        IF ( p_fin <> '%'
        AND v_tipo_campo <> 'CHAVE' ) THEN
            v_sql := v_sql || '  and fin.cod_natureza_op = ''' || p_fin || ''' ';
        END IF;

        ---
        IF ( p_cst <> '%'
        AND v_tipo_campo <> 'CHAVE' ) THEN
            v_sql := v_sql || '  and cst.cod_situacao_b = ''' || p_cst || ''' ';
        END IF;

        ---
        IF ( p_uf_destino <> '%'
        AND v_tipo_campo <> 'CHAVE' ) THEN
            v_sql := v_sql || '  and uf_d.cod_estado = ''' || p_uf_destino || ''' ';
        END IF;

        ---
        v_sql := v_sql || '  and x07.ident_fis_jur     = x04.ident_fis_jur ';
        v_sql := v_sql || '  and x2013.ident_produto   = x08.ident_produto ';
        v_sql := v_sql || '  and fin.ident_natureza_op = x08.ident_natureza_op ';
        v_sql := v_sql || '  and cfop.ident_cfo        = x08.ident_cfo ';
        v_sql := v_sql || '  and cst.ident_situacao_b  = x08.ident_situacao_b ';
        v_sql := v_sql || '  and est.cod_empresa       = x07.cod_empresa ';
        v_sql := v_sql || '  and est.cod_estab         = x07.cod_estab ';
        v_sql := v_sql || '  and uf_d.ident_estado     = x04.ident_estado ';
        v_sql := v_sql || 'order by 1, 2, 7, 11 ';

        RETURN v_sql;
    END;

    FUNCTION checkchaveacesso ( p_i_chave_acesso IN VARCHAR2 )
        RETURN BOOLEAN
    IS
        v_soma INTEGER DEFAULT 0;
        v_multiplicador INTEGER DEFAULT 2;
        v_resto INTEGER DEFAULT 0;
        v_digito INTEGER DEFAULT 0;
    BEGIN
        FOR c IN 1 .. 43 LOOP
            v_soma :=
                  v_soma
                + (   SUBSTR ( p_i_chave_acesso
                             , 44 - c
                             , 1 )
                    * v_multiplicador );
            v_multiplicador := v_multiplicador + 1;

            IF ( v_multiplicador > 9 ) THEN
                v_multiplicador := 2;
            END IF;
        END LOOP;

        v_resto :=
            MOD ( v_soma
                , 11 );
        v_digito := 11 - v_resto;

        IF ( v_digito = SUBSTR ( p_i_chave_acesso
                               , 44
                               , 1 ) ) THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN FALSE;
    END;

    PROCEDURE validatecriterios ( p_livre IN VARCHAR2
                                , p_cfop IN VARCHAR2
                                , p_fin IN VARCHAR2
                                , p_cst IN VARCHAR2
                                , p_i_campo_livre   OUT VARCHAR2 )
    IS
        v_check_number FLOAT;
        v_check_values VARCHAR2 ( 20 );

        TYPE array_orig IS TABLE OF VARCHAR2 ( 20 );

        a_origem array_orig
            := array_orig ( 'PS'
                          , 'PSFT'
                          , 'PEOPLESOFT'
                          , 'SAP'
                          , 'PEOPLE' );

        TYPE array_lista IS TABLE OF VARCHAR2 ( 10 );

        a_lista array_lista
            := array_lista ( 'POSITIVA'
                           , 'NEGATIVA'
                           , 'NEUTRA' );
    BEGIN
        --- chave de acesso ou aliquota
        IF ( p_livre IS NOT NULL
         OR TRIM ( p_livre ) <> '' ) THEN
            IF ( LENGTH ( p_livre ) = 44 ) THEN --(i)
                IF checkchaveacesso ( p_livre ) THEN
                    p_i_campo_livre := 'CHAVE';
                ELSE
                    raise_application_error ( -20005
                                            , 'Chave de Acesso inválida! (' || p_livre || ')' );
                END IF;
            ELSE
                IF UPPER ( p_livre ) MEMBER OF a_origem THEN --(ii)
                    p_i_campo_livre := 'ORIGEM';
                ELSE
                    IF UPPER ( p_livre ) MEMBER OF a_lista THEN
                        p_i_campo_livre := 'LISTA';
                    ELSE
                        --- check number
                        BEGIN
                            SELECT TO_NUMBER ( p_livre )
                              INTO v_check_number
                              FROM DUAL;
                        EXCEPTION
                            WHEN OTHERS THEN
                                raise_application_error (
                                                          -20005
                                                        ,    'Critério informado no campo Pesquisa inválido! ('
                                                          || p_livre
                                                          || ')'
                                );
                        END;

                        p_i_campo_livre := 'ALIQ';
                    END IF;
                END IF; --(ii)
            END IF; --(i)
        ELSE
            p_i_campo_livre := 'NONE';
        END IF;

        --- cfop
        IF ( p_cfop <> '%' ) THEN
            BEGIN
                SELECT cod_cfo
                  INTO v_check_values
                  FROM msaf.x2012_cod_fiscal
                 WHERE cod_cfo = p_cfop;
            EXCEPTION
                WHEN OTHERS THEN
                    raise_application_error ( -20005
                                            , 'Critério de CFOP inválido! (' || p_cfop || ')' );
            END;
        END IF;

        --- finalidade
        IF ( p_fin <> '%' ) THEN
            BEGIN
                SELECT cod_natureza_op
                  INTO v_check_values
                  FROM msaf.x2006_natureza_op
                 WHERE cod_natureza_op = p_fin;
            EXCEPTION
                WHEN OTHERS THEN
                    raise_application_error ( -20005
                                            , 'Critério de Finalidade inválido! (' || p_fin || ')' );
            END;
        END IF;

        --- cst
        IF ( p_cst <> '%' ) THEN
            BEGIN
                SELECT cod_situacao_b
                  INTO v_check_values
                  FROM msaf.y2026_sit_trb_uf_b
                 WHERE cod_situacao_b = p_cst;
            EXCEPTION
                WHEN OTHERS THEN
                    raise_application_error ( -20005
                                            , 'Critério de CST inválido! (' || p_cst || ')' );
            END;
        END IF;
    END;

    PROCEDURE execsql ( p_i_stmt_query IN VARCHAR2
                      , p_i_cod_estab IN VARCHAR2
                      , p_i_data_ini IN DATE
                      , p_i_data_fim IN DATE )
    IS
        c_query SYS_REFCURSOR;

        TYPE tab_temp_r IS RECORD
        (
            mprocid VARCHAR2 ( 20 )
          , cod_empresa VARCHAR2 ( 3 )
          , cod_estab VARCHAR2 ( 6 )
          , cod_estado VARCHAR2 ( 2 )
          , movto_e_s VARCHAR2 ( 1 )
          , data_fiscal DATE
          , cod_fis_jur VARCHAR2 ( 40 )
          , uf_fis_jur VARCHAR2 ( 2 )
          , nome_fantasia VARCHAR2 ( 60 )
          , cpf_cgc VARCHAR2 ( 30 )
          , insc_estadual VARCHAR2 ( 20 )
          , num_autentic_nfe VARCHAR2 ( 44 )
          , cod_sistema_orig VARCHAR2 ( 10 )
          , cod_produto VARCHAR2 ( 40 )
          , descricao VARCHAR2 ( 100 )
          , num_item INTEGER
          , cod_natureza_op VARCHAR2 ( 6 )
          , cod_cfo VARCHAR2 ( 8 )
          , cod_situacao_b VARCHAR2 ( 2 )
          , vlr_contab_item NUMBER ( 17, 4 )
          , quantidade NUMBER ( 17, 4 )
          , vlr_unit NUMBER ( 17, 4 )
          , vlr_pis NUMBER ( 17, 4 )
          , vlr_cofins NUMBER ( 17, 4 )
          , vlr_icmss_n_escrit NUMBER ( 17, 4 )
          , vlr_icmss_ndestac NUMBER ( 17, 4 )
          , vlr_outras NUMBER ( 17, 4 )
          , vlr_ipi_ndestac NUMBER ( 17, 4 )
          , vlr_base_icms NUMBER ( 17, 4 )
          , aliq_icms NUMBER ( 7, 2 )
          , vlr_icms NUMBER ( 17, 4 )
          , vlr_base_icms_st NUMBER ( 17, 4 )
          , vlr_icms_st NUMBER ( 17, 4 )
          , lista VARCHAR2 ( 10 )
        );

        TYPE tab_temp_rt IS TABLE OF tab_temp_r;

        tab_temp tab_temp_rt;
        v_count INTEGER DEFAULT 0;
    BEGIN
        BEGIN
            OPEN c_query FOR p_i_stmt_query
                USING p_i_cod_estab
                    , p_i_data_ini
                    , p_i_data_fim;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                raise_application_error ( -20005
                                        , 'Dados NÃO ENCONTRADOS para os critérios informados!' );
            WHEN OTHERS THEN
                raise_application_error ( -20005
                                        , 'Ocorreu um ERRO na execução da QUERY!' );
        END;

        LOOP
            FETCH c_query
                BULK COLLECT INTO tab_temp
                LIMIT 100;

            v_count := v_count + tab_temp.COUNT;
            dbms_application_info.set_module ( 'MSAF_QUERY_NF'
                                             , p_i_cod_estab || ' [' || v_count || ']' );

            IF ( tab_temp.COUNT > 0 ) THEN
                FOR i IN tab_temp.FIRST .. tab_temp.LAST LOOP
                    tab_query.EXTEND;
                    tab_query ( tab_query.COUNT ) :=
                        tab_query_o ( mprocid => tab_temp ( i ).mprocid
                                    , cod_empresa => tab_temp ( i ).cod_empresa
                                    , cod_estab => tab_temp ( i ).cod_estab
                                    , cod_estado => tab_temp ( i ).cod_estado
                                    , movto_e_s => tab_temp ( i ).movto_e_s
                                    , data_fiscal => tab_temp ( i ).data_fiscal
                                    , cod_fis_jur => tab_temp ( i ).cod_fis_jur
                                    , uf_fis_jur => tab_temp ( i ).uf_fis_jur
                                    , nome_fantasia => tab_temp ( i ).nome_fantasia
                                    , cpf_cgc => tab_temp ( i ).cpf_cgc
                                    , insc_estadual => tab_temp ( i ).insc_estadual
                                    , num_autentic_nfe => tab_temp ( i ).num_autentic_nfe
                                    , cod_sistema_orig => tab_temp ( i ).cod_sistema_orig
                                    , cod_produto => tab_temp ( i ).cod_produto
                                    , descricao => tab_temp ( i ).descricao
                                    , num_item => tab_temp ( i ).num_item
                                    , cod_natureza_op => tab_temp ( i ).cod_natureza_op
                                    , cod_cfo => tab_temp ( i ).cod_cfo
                                    , cod_situacao_b => tab_temp ( i ).cod_situacao_b
                                    , vlr_contab_item => tab_temp ( i ).vlr_contab_item
                                    , quantidade => tab_temp ( i ).quantidade
                                    , vlr_unit => tab_temp ( i ).vlr_unit
                                    , vlr_pis => tab_temp ( i ).vlr_pis
                                    , vlr_cofins => tab_temp ( i ).vlr_cofins
                                    , vlr_icmss_n_escrit => tab_temp ( i ).vlr_icmss_n_escrit
                                    , vlr_icmss_ndestac => tab_temp ( i ).vlr_icmss_ndestac
                                    , vlr_outras => tab_temp ( i ).vlr_outras
                                    , vlr_ipi_ndestac => tab_temp ( i ).vlr_ipi_ndestac
                                    , vlr_base_icms => tab_temp ( i ).vlr_base_icms
                                    , aliq_icms => tab_temp ( i ).aliq_icms
                                    , vlr_icms => tab_temp ( i ).vlr_icms
                                    , vlr_base_icms_st => tab_temp ( i ).vlr_base_icms_st
                                    , vlr_icms_st => tab_temp ( i ).vlr_icms_st
                                    , lista => tab_temp ( i ).lista );
                END LOOP;
            ELSE
                IF ( tab_query.COUNT = 0 ) THEN
                    loga (
                              '['
                           || p_i_cod_estab
                           || '] - não foram encontradas linhas de NF para os critérios informados'
                    );
                ELSE
                    loga ( '[' || p_i_cod_estab || '] - ' || v_count || ' linhas de NF encontradas' );
                    a_estab.EXTEND ( );
                    a_estab ( a_estab.LAST ) := p_i_cod_estab;
                END IF;
            END IF;

            EXIT WHEN tab_temp.COUNT = 0;
            tab_temp.delete;
        END LOOP;

        CLOSE c_query;
    END;

    FUNCTION executar ( p_data_ini DATE
                      , p_data_fim DATE
                      , p_movto_e_s VARCHAR2
                      , p_capa VARCHAR2
                      , p_separa VARCHAR2
                      , p_livre VARCHAR2
                      , p_cfop VARCHAR2
                      , p_fin VARCHAR2
                      , p_cst VARCHAR2
                      , p_uf_destino VARCHAR2
                      , p_uf VARCHAR2
                      , p_cod_estab lib_proc.vartab )
        RETURN INTEGER
    IS
        v_tipo_campo VARCHAR2 ( 20 );
        v_stmt_query VARCHAR2 ( 8000 );
        v_id_file INTEGER DEFAULT 0;
        v_class VARCHAR2 ( 1 );
        v_check_aliq VARCHAR2 ( 1 );
        v_chave_ant VARCHAR2 ( 44 );
    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS='',.'' ';

        dbms_application_info.set_module ( 'MSAF_QUERY_NF'
                                         , NULL );

        -- Criação: Processo
        mproc_id := lib_proc.new ( $$plsql_unit );
        mcod_empresa := NVL ( mcod_empresa, msafi.dpsp.empresa );

        -- validar campos de criterios
        validatecriterios ( p_livre
                          , p_cfop
                          , p_fin
                          , p_cst
                          , v_tipo_campo );

        -- preparar SQL
        v_stmt_query :=
            preparesql ( p_movto_e_s
                       , p_livre
                       , p_cfop
                       , p_fin
                       , p_cst
                       , p_uf_destino
                       , p_data_ini
                       , v_tipo_campo );

        --loga(substr(v_stmt_query,4001,5000),false);
        --loga(substr(v_stmt_query,5001,6000),false);
        --loga(substr(v_stmt_query,6001,7000),false);
        --loga(substr(v_stmt_query,7001,8000),false);

        -- executar query
        FOR i IN p_cod_estab.FIRST .. p_cod_estab.LAST LOOP
            execsql ( v_stmt_query
                    , p_cod_estab ( i )
                    , p_data_ini
                    , p_data_fim );
        END LOOP;

        dbms_application_info.set_module ( 'MSAF_QUERY_NF'
                                         , NULL );

        -- escrever saida em XLS
        IF ( tab_query.COUNT > 0 ) THEN
            FOR k IN a_estab.FIRST .. a_estab.LAST LOOP
                IF ( v_tipo_campo = 'ALIQ' ) THEN
                    -- checar aliq com dados na memoria, mais rapido
                    BEGIN
                        SELECT DISTINCT 'S'
                          INTO v_check_aliq
                          FROM TABLE ( CAST ( tab_query AS tab_query_ot ) )
                         WHERE cod_empresa = mcod_empresa
                           AND cod_estab = a_estab ( k )
                           AND aliq_icms = TO_NUMBER ( p_livre );
                    EXCEPTION
                        WHEN OTHERS THEN
                            v_check_aliq := 'N';
                    END;
                ELSE
                    v_check_aliq := 'N';
                END IF;

                IF ( v_tipo_campo = 'ALIQ'
                AND v_check_aliq = 'N' ) THEN --(i)
                    loga (
                              '['
                           || a_estab ( k )
                           || '] - não foram encontradas linhas de NF para os critérios informados (ALIQ '
                           || p_livre
                           || ')'
                    );
                ELSE -- (i)
                    IF ( p_separa = 'S' ) THEN
                        -- separa arquivos por ESTAB
                        v_id_file := k;
                        lib_proc.add_tipo ( mproc_id
                                          , v_id_file
                                          ,    mcod_empresa
                                            || '_'
                                            || a_estab ( k )
                                            || '_QUERY_NF_'
                                            || TO_CHAR ( p_data_ini
                                                       , 'yyyymm' )
                                            || '.xls'
                                          , 2 );
                    ELSE
                        IF ( k = 1 ) THEN
                            v_id_file := 1;
                            lib_proc.add_tipo ( mproc_id
                                              , v_id_file
                                              ,    mcod_empresa
                                                || '_QUERY_NF_'
                                                || TO_CHAR ( p_data_ini
                                                           , 'yyyymm' )
                                                || '.xls'
                                              , 2 );
                        END IF;
                    END IF;

                    IF ( p_capa = 'S' ) THEN --(ii)
                        -- somar por capa de NF
                        IF ( p_separa = 'N'
                        AND k = 1 )
                        OR ( p_separa = 'S' ) THEN
                            lib_proc.add ( dsp_planilha.header
                                         , ptipo => v_id_file );
                            lib_proc.add ( dsp_planilha.tabela_inicio
                                         , ptipo => v_id_file );
                            lib_proc.add ( dsp_planilha.linha (
                                                                p_conteudo =>    dsp_planilha.campo ( 'EMPRESA' )
                                                                              || dsp_planilha.campo ( 'ESTAB' )
                                                                              || dsp_planilha.campo ( 'UF' )
                                                                              || dsp_planilha.campo ( 'MOVTO' )
                                                                              || dsp_planilha.campo ( 'DATA FISCAL' )
                                                                              || dsp_planilha.campo ( 'COD FIS JUR' )
                                                                              || dsp_planilha.campo ( 'UF FIS JUR' )
                                                                              || dsp_planilha.campo ( 'RAZAO SOCIAL' )
                                                                              || dsp_planilha.campo ( 'CNPJ' )
                                                                              || dsp_planilha.campo ( 'INSC ESTADUAL' )
                                                                              || dsp_planilha.campo ( 'CHAVE ACESSO' )
                                                                              || dsp_planilha.campo ( 'ORIGEM' )
                                                                              || dsp_planilha.campo ( 'QTDE LINHAS' )
                                                                              || dsp_planilha.campo ( 'CFOP' )
                                                                              || dsp_planilha.campo (
                                                                                                      'VLR CONTAB ITEM'
                                                                                 )
                                                                              || dsp_planilha.campo ( 'VLR UNIT' )
                                                                              || dsp_planilha.campo ( 'VLR PIS' )
                                                                              || dsp_planilha.campo ( 'VLR COFINS' )
                                                                              || dsp_planilha.campo (
                                                                                                      'VLR ST N ESCRIT'
                                                                                 )
                                                                              || dsp_planilha.campo (
                                                                                                      'VLR ST N DESTAC'
                                                                                 )
                                                                              || dsp_planilha.campo (
                                                                                                      'OUTRAS DESPESAS'
                                                                                 )
                                                                              || dsp_planilha.campo (
                                                                                                      'VLR IPI N DESTAC'
                                                                                 )
                                                                              || dsp_planilha.campo ( 'VLR BASE ICMS' )
                                                                              || dsp_planilha.campo ( 'VLR ICMS' )
                                                                              || dsp_planilha.campo ( 'VLR BASE ST' )
                                                                              || dsp_planilha.campo ( 'VLR ICMS ST' )
                                                              , p_class => 'h'
                                           )
                                         , ptipo => v_id_file );
                        END IF;

                        FOR nf IN ( SELECT   cod_empresa
                                           , cod_estab
                                           , cod_estado
                                           , movto_e_s
                                           , data_fiscal
                                           , cod_fis_jur
                                           , uf_fis_jur
                                           , nome_fantasia
                                           , cpf_cgc
                                           , insc_estadual
                                           , num_autentic_nfe
                                           , cod_sistema_orig
                                           , COUNT ( * ) AS qtde_linhas
                                           , cod_cfo
                                           , SUM ( NVL ( vlr_contab_item, 0 ) ) vlr_contab_item
                                           , SUM ( NVL ( vlr_unit, 0 ) ) vlr_unit
                                           , SUM ( NVL ( vlr_pis, 0 ) ) vlr_pis
                                           , SUM ( NVL ( vlr_cofins, 0 ) ) vlr_cofins
                                           , SUM ( NVL ( vlr_icmss_n_escrit, 0 ) ) vlr_icmss_n_escrit
                                           , SUM ( NVL ( vlr_icmss_ndestac, 0 ) ) vlr_icmss_ndestac
                                           , SUM ( NVL ( vlr_outras, 0 ) ) vlr_outras
                                           , SUM ( NVL ( vlr_ipi_ndestac, 0 ) ) vlr_ipi_ndestac
                                           , SUM ( NVL ( vlr_base_icms, 0 ) ) vlr_base_icms
                                           , SUM ( NVL ( vlr_icms, 0 ) ) vlr_icms
                                           , SUM ( NVL ( vlr_base_icms_st, 0 ) ) vlr_base_icms_st
                                           , SUM ( NVL ( vlr_icms_st, 0 ) ) vlr_icms_st
                                        FROM TABLE ( CAST ( tab_query AS tab_query_ot ) )
                                       WHERE cod_empresa = mcod_empresa
                                         AND cod_estab = a_estab ( k )
                                         AND aliq_icms = DECODE ( v_tipo_campo, 'ALIQ', p_livre, aliq_icms )
                                         AND lista = DECODE ( v_tipo_campo, 'LISTA', UPPER ( p_livre ), lista )
                                         AND mprocid = mproc_id
                                    GROUP BY cod_empresa
                                           , cod_estab
                                           , cod_estado
                                           , movto_e_s
                                           , data_fiscal
                                           , cod_fis_jur
                                           , uf_fis_jur
                                           , nome_fantasia
                                           , cpf_cgc
                                           , insc_estadual
                                           , num_autentic_nfe
                                           , cod_sistema_orig
                                           , cod_cfo
                                    ORDER BY cod_estab
                                           , data_fiscal
                                           , num_autentic_nfe ) LOOP
                            IF v_chave_ant <> nf.num_autentic_nfe THEN
                                IF v_class = 'a' THEN
                                    v_class := 'b';
                                ELSE
                                    v_class := 'a';
                                END IF;
                            END IF;

                            v_chave_ant := nf.num_autentic_nfe;

                            lib_proc.add ( dsp_planilha.linha (
                                                                p_conteudo =>    dsp_planilha.campo ( nf.cod_empresa )
                                                                              || dsp_planilha.campo ( nf.cod_estab )
                                                                              || dsp_planilha.campo ( nf.cod_estado )
                                                                              || dsp_planilha.campo ( nf.movto_e_s )
                                                                              || dsp_planilha.campo ( nf.data_fiscal )
                                                                              || dsp_planilha.campo ( nf.cod_fis_jur )
                                                                              || dsp_planilha.campo ( nf.uf_fis_jur )
                                                                              || dsp_planilha.campo (
                                                                                                      nf.nome_fantasia
                                                                                 )
                                                                              || dsp_planilha.campo (
                                                                                                      dsp_planilha.texto (
                                                                                                                           nf.cpf_cgc
                                                                                                      )
                                                                                 )
                                                                              || dsp_planilha.campo (
                                                                                                      dsp_planilha.texto (
                                                                                                                           nf.insc_estadual
                                                                                                      )
                                                                                 )
                                                                              || dsp_planilha.campo (
                                                                                                      dsp_planilha.texto (
                                                                                                                           nf.num_autentic_nfe
                                                                                                      )
                                                                                 )
                                                                              || dsp_planilha.campo (
                                                                                                      nf.cod_sistema_orig
                                                                                 )
                                                                              || dsp_planilha.campo ( nf.qtde_linhas )
                                                                              || dsp_planilha.campo ( nf.cod_cfo )
                                                                              || dsp_planilha.campo (
                                                                                                      moeda (
                                                                                                              nf.vlr_contab_item
                                                                                                      )
                                                                                 )
                                                                              || dsp_planilha.campo (
                                                                                                      moeda (
                                                                                                              NVL (
                                                                                                                    nf.vlr_unit
                                                                                                                  , 0
                                                                                                              )
                                                                                                      )
                                                                                 )
                                                                              || dsp_planilha.campo (
                                                                                                      moeda (
                                                                                                              NVL (
                                                                                                                    nf.vlr_pis
                                                                                                                  , 0
                                                                                                              )
                                                                                                      )
                                                                                 )
                                                                              || dsp_planilha.campo (
                                                                                                      moeda (
                                                                                                              NVL (
                                                                                                                    nf.vlr_cofins
                                                                                                                  , 0
                                                                                                              )
                                                                                                      )
                                                                                 )
                                                                              || dsp_planilha.campo (
                                                                                                      moeda (
                                                                                                              NVL (
                                                                                                                    nf.vlr_icmss_n_escrit
                                                                                                                  , 0
                                                                                                              )
                                                                                                      )
                                                                                 )
                                                                              || dsp_planilha.campo (
                                                                                                      moeda (
                                                                                                              NVL (
                                                                                                                    nf.vlr_icmss_ndestac
                                                                                                                  , 0
                                                                                                              )
                                                                                                      )
                                                                                 )
                                                                              || dsp_planilha.campo (
                                                                                                      moeda (
                                                                                                              NVL (
                                                                                                                    nf.vlr_outras
                                                                                                                  , 0
                                                                                                              )
                                                                                                      )
                                                                                 )
                                                                              || dsp_planilha.campo (
                                                                                                      moeda (
                                                                                                              NVL (
                                                                                                                    nf.vlr_ipi_ndestac
                                                                                                                  , 0
                                                                                                              )
                                                                                                      )
                                                                                 )
                                                                              || dsp_planilha.campo (
                                                                                                      moeda (
                                                                                                              NVL (
                                                                                                                    nf.vlr_base_icms
                                                                                                                  , 0
                                                                                                              )
                                                                                                      )
                                                                                 )
                                                                              || dsp_planilha.campo (
                                                                                                      moeda (
                                                                                                              NVL (
                                                                                                                    nf.vlr_icms
                                                                                                                  , 0
                                                                                                              )
                                                                                                      )
                                                                                 )
                                                                              || dsp_planilha.campo (
                                                                                                      moeda (
                                                                                                              NVL (
                                                                                                                    nf.vlr_base_icms_st
                                                                                                                  , 0
                                                                                                              )
                                                                                                      )
                                                                                 )
                                                                              || dsp_planilha.campo (
                                                                                                      moeda (
                                                                                                              NVL (
                                                                                                                    nf.vlr_icms_st
                                                                                                                  , 0
                                                                                                              )
                                                                                                      )
                                                                                 )
                                                              , p_class => v_class
                                           )
                                         , ptipo => v_id_file );
                        END LOOP;
                    ELSE --(ii)
                        IF ( p_separa = 'N'
                        AND k = 1 )
                        OR ( p_separa = 'S' ) THEN
                            lib_proc.add ( dsp_planilha.header
                                         , ptipo => v_id_file );
                            lib_proc.add ( dsp_planilha.tabela_inicio
                                         , ptipo => v_id_file );
                            lib_proc.add ( dsp_planilha.linha (
                                                                p_conteudo =>    dsp_planilha.campo ( 'EMPRESA' )
                                                                              || dsp_planilha.campo ( 'ESTAB' )
                                                                              || dsp_planilha.campo ( 'UF' )
                                                                              || dsp_planilha.campo ( 'MOVTO' )
                                                                              || dsp_planilha.campo ( 'DATA FISCAL' )
                                                                              || dsp_planilha.campo ( 'COD FIS JUR' )
                                                                              || dsp_planilha.campo ( 'UF FIS JUR' )
                                                                              || dsp_planilha.campo ( 'RAZAO SOCIAL' )
                                                                              || dsp_planilha.campo ( 'CNPJ' )
                                                                              || dsp_planilha.campo ( 'INSC ESTADUAL' )
                                                                              || dsp_planilha.campo ( 'CHAVE ACESSO' )
                                                                              || dsp_planilha.campo ( 'ORIGEM' )
                                                                              || dsp_planilha.campo ( 'COD PRODUTO' )
                                                                              || dsp_planilha.campo ( 'DESCRICAO' )
                                                                              || dsp_planilha.campo ( 'LINHA' )
                                                                              || dsp_planilha.campo ( 'FINALIDADE' )
                                                                              || dsp_planilha.campo ( 'CFOP' )
                                                                              || dsp_planilha.campo ( 'CST' )
                                                                              || dsp_planilha.campo (
                                                                                                      'VLR CONTAB ITEM'
                                                                                 )
                                                                              || dsp_planilha.campo ( 'QTDE' )
                                                                              || dsp_planilha.campo ( 'VLR UNIT' )
                                                                              || dsp_planilha.campo ( 'VLR PIS' )
                                                                              || dsp_planilha.campo ( 'VLR COFINS' )
                                                                              || dsp_planilha.campo ( 'LISTA' )
                                                                              || dsp_planilha.campo (
                                                                                                      'VLR ST N ESCRIT'
                                                                                 )
                                                                              || dsp_planilha.campo (
                                                                                                      'VLR ST N DESTAC'
                                                                                 )
                                                                              || dsp_planilha.campo (
                                                                                                      'OUTRAS DESPESAS'
                                                                                 )
                                                                              || dsp_planilha.campo (
                                                                                                      'VLR IPI N DESTAC'
                                                                                 )
                                                                              || dsp_planilha.campo ( 'VLR BASE ICMS' )
                                                                              || dsp_planilha.campo ( 'ALIQ ICMS' )
                                                                              || dsp_planilha.campo ( 'VLR ICMS' )
                                                                              || dsp_planilha.campo ( 'VLR BASE ST' )
                                                                              || dsp_planilha.campo ( 'VLR ICMS ST' )
                                                              , p_class => 'h'
                                           )
                                         , ptipo => v_id_file );
                        END IF;

                        FOR nf IN ( SELECT   q.*
                                        FROM TABLE ( CAST ( tab_query AS tab_query_ot ) ) q
                                       WHERE q.cod_empresa = mcod_empresa
                                         AND q.cod_estab = a_estab ( k )
                                         AND q.aliq_icms = DECODE ( v_tipo_campo, 'ALIQ', p_livre, q.aliq_icms )
                                         AND q.lista = DECODE ( v_tipo_campo, 'LISTA', UPPER ( p_livre ), q.lista )
                                         AND q.mprocid = mproc_id
                                    ORDER BY q.cod_estab
                                           , q.data_fiscal
                                           , q.num_autentic_nfe
                                           , q.num_item ) LOOP
                            IF v_class = 'a' THEN
                                v_class := 'b';
                            ELSE
                                v_class := 'a';
                            END IF;

                            lib_proc.add ( dsp_planilha.linha (
                                                                p_conteudo =>    dsp_planilha.campo ( nf.cod_empresa )
                                                                              || dsp_planilha.campo ( nf.cod_estab )
                                                                              || dsp_planilha.campo ( nf.cod_estado )
                                                                              || dsp_planilha.campo ( nf.movto_e_s )
                                                                              || dsp_planilha.campo ( nf.data_fiscal )
                                                                              || dsp_planilha.campo ( nf.cod_fis_jur )
                                                                              || dsp_planilha.campo ( nf.uf_fis_jur )
                                                                              || dsp_planilha.campo (
                                                                                                      nf.nome_fantasia
                                                                                 )
                                                                              || dsp_planilha.campo (
                                                                                                      dsp_planilha.texto (
                                                                                                                           nf.cpf_cgc
                                                                                                      )
                                                                                 )
                                                                              || dsp_planilha.campo (
                                                                                                      dsp_planilha.texto (
                                                                                                                           nf.insc_estadual
                                                                                                      )
                                                                                 )
                                                                              || dsp_planilha.campo (
                                                                                                      dsp_planilha.texto (
                                                                                                                           nf.num_autentic_nfe
                                                                                                      )
                                                                                 )
                                                                              || dsp_planilha.campo (
                                                                                                      nf.cod_sistema_orig
                                                                                 )
                                                                              || dsp_planilha.campo ( nf.cod_produto )
                                                                              || dsp_planilha.campo ( nf.descricao )
                                                                              || dsp_planilha.campo ( nf.num_item )
                                                                              || dsp_planilha.campo (
                                                                                                      nf.cod_natureza_op
                                                                                 )
                                                                              || dsp_planilha.campo ( nf.cod_cfo )
                                                                              || dsp_planilha.campo (
                                                                                                      dsp_planilha.texto (
                                                                                                                           nf.cod_situacao_b
                                                                                                      )
                                                                                 )
                                                                              || dsp_planilha.campo (
                                                                                                      moeda (
                                                                                                              nf.vlr_contab_item
                                                                                                      )
                                                                                 )
                                                                              || dsp_planilha.campo ( nf.quantidade )
                                                                              || dsp_planilha.campo (
                                                                                                      moeda (
                                                                                                              NVL (
                                                                                                                    nf.vlr_unit
                                                                                                                  , 0
                                                                                                              )
                                                                                                      )
                                                                                 )
                                                                              || dsp_planilha.campo (
                                                                                                      moeda (
                                                                                                              NVL (
                                                                                                                    nf.vlr_pis
                                                                                                                  , 0
                                                                                                              )
                                                                                                      )
                                                                                 )
                                                                              || dsp_planilha.campo (
                                                                                                      moeda (
                                                                                                              NVL (
                                                                                                                    nf.vlr_cofins
                                                                                                                  , 0
                                                                                                              )
                                                                                                      )
                                                                                 )
                                                                              || dsp_planilha.campo ( nf.lista )
                                                                              || dsp_planilha.campo (
                                                                                                      moeda (
                                                                                                              NVL (
                                                                                                                    nf.vlr_icmss_n_escrit
                                                                                                                  , 0
                                                                                                              )
                                                                                                      )
                                                                                 )
                                                                              || dsp_planilha.campo (
                                                                                                      moeda (
                                                                                                              NVL (
                                                                                                                    nf.vlr_icmss_ndestac
                                                                                                                  , 0
                                                                                                              )
                                                                                                      )
                                                                                 )
                                                                              || dsp_planilha.campo (
                                                                                                      moeda (
                                                                                                              NVL (
                                                                                                                    nf.vlr_outras
                                                                                                                  , 0
                                                                                                              )
                                                                                                      )
                                                                                 )
                                                                              || dsp_planilha.campo (
                                                                                                      moeda (
                                                                                                              NVL (
                                                                                                                    nf.vlr_ipi_ndestac
                                                                                                                  , 0
                                                                                                              )
                                                                                                      )
                                                                                 )
                                                                              || dsp_planilha.campo (
                                                                                                      moeda (
                                                                                                              NVL (
                                                                                                                    nf.vlr_base_icms
                                                                                                                  , 0
                                                                                                              )
                                                                                                      )
                                                                                 )
                                                                              || dsp_planilha.campo (
                                                                                                      NVL (
                                                                                                            nf.aliq_icms
                                                                                                          , 0
                                                                                                      )
                                                                                 )
                                                                              || dsp_planilha.campo (
                                                                                                      moeda (
                                                                                                              NVL (
                                                                                                                    nf.vlr_icms
                                                                                                                  , 0
                                                                                                              )
                                                                                                      )
                                                                                 )
                                                                              || dsp_planilha.campo (
                                                                                                      moeda (
                                                                                                              NVL (
                                                                                                                    nf.vlr_base_icms_st
                                                                                                                  , 0
                                                                                                              )
                                                                                                      )
                                                                                 )
                                                                              || dsp_planilha.campo (
                                                                                                      moeda (
                                                                                                              NVL (
                                                                                                                    nf.vlr_icms_st
                                                                                                                  , 0
                                                                                                              )
                                                                                                      )
                                                                                 )
                                                              , p_class => v_class
                                           )
                                         , ptipo => v_id_file );
                        END LOOP;
                    END IF; --(ii)

                    IF ( p_separa = 'N'
                    AND k = a_estab.LAST )
                    OR ( p_separa = 'S' ) THEN
                        lib_proc.add ( dsp_planilha.tabela_fim
                                     , ptipo => v_id_file );
                    END IF;
                END IF; --(i)
            END LOOP;
        END IF;

        ---
        lib_proc.close ( );
        RETURN mproc_id;
    EXCEPTION
        WHEN OTHERS THEN
            lib_proc.add_log ( 'Erro não tratado: ' || dbms_utility.format_error_backtrace
                             , 1 );
            lib_proc.add_log ( 'SQLERRM: ' || SQLERRM
                             , 1 );
            lib_proc.close;
            RETURN mproc_id;
    END;
END dpsp_query_nf_cproc;
/
SHOW ERRORS;
