Prompt Package Body MSAF_DSP_REL_FAT_ALIQ_CPROC;
--
-- MSAF_DSP_REL_FAT_ALIQ_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY "MSAF_DSP_REL_FAT_ALIQ_CPROC"
IS
    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );
    BEGIN
        mcod_empresa := ( 'EMPRESA' );
        mcod_estab := ( 'ESTABELECIMENTO' );
        --MUSUARIO     := LIB_PARAMETROS.RECUPERAR('USUARIO');

        lib_proc.add_param ( pstr
                           , 'PERÍODO INICIAL'
                           , 'DATE'
                           , 'TEXTBOX'
                           , 'S'
                           , NULL
                           , 'DD/MM/YYYY' );

        lib_proc.add_param ( pstr
                           , 'PERÍODO FINAL'
                           , 'DATE'
                           , 'TEXTBOX'
                           , 'S'
                           , NULL
                           , 'DD/MM/YYYY' );

        lib_proc.add_param (
                             pstr
                           , 'ESTABELECIMENTO'
                           , 'VARCHAR2'
                           , 'COMBOBOX'
                           , 'N'
                           , NULL
                           , NULL
                           ,    'SELECT DISTINCT E.COD_ESTAB, E.COD_ESTAB||'' - ''||E.RAZAO_SOCIAL FROM ESTABELECIMENTO E WHERE E.COD_EMPRESA   = '''
                             || mcod_empresa
                             || ''''
        );
        RETURN pstr;
    END;

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'FISCAL - RELATÓRIO DE FATURAMENTO ANALITICO POR ALIQUOTA';
    END;

    FUNCTION tipo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'PROCESSOS - FISCAL';
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
        RETURN 'GERA O RELATÓRIO ANALITICO POR ALIQUOTAS';
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

    FUNCTION executar ( p_data_ini DATE
                      , p_data_fim DATE
                      , p_cod_estab VARCHAR2 )
        RETURN INTEGER
    IS
        x NUMBER ( 7 ) := 0;

        CURSOR cur_x01 ( p_data_ini DATE
                       , p_data_fim DATE
                       , p_cod_estab VARCHAR2 )
        IS
            -- MARÇO/2014
            SELECT   cod_estab
                   , data_fiscal
                   , num_cupom
                   , cod_cfo
                   , cod_produto
                   , a.tipo_doc
                   , ps.aliq
                   , SUM ( a.vlr_liq ) AS vlr_liq
                   , SUM ( a.vlr_liq * ( ps.aliq / 100 ) ) AS vlr_imposto
                FROM (SELECT   i.cod_estab
                             , i.data_fiscal
                             , i.num_docfis num_cupom
                             , d.cod_docto tipo_doc
                             , c.cod_cfo
                             , p.cod_produto
                             , SUM ( i.vlr_contab_item ) vlr_liq
                          FROM msaf.x08_itens_merc i
                             , msaf.x2013_produto p
                             , msaf.x2012_cod_fiscal c
                             , msaf.x2005_tipo_docto d
                         WHERE i.cod_empresa = msafi.dpsp.empresa
                           AND i.cod_estab = p_cod_estab
                           AND i.data_fiscal BETWEEN TO_DATE ( p_data_ini
                                                             , 'DD/MM/YYYY' )
                                                 AND TO_DATE ( p_data_fim
                                                             , 'DD/MM/YYYY' )
                           AND i.movto_e_s = '9'
                           AND i.norm_dev = '1'
                           AND i.ident_docto = d.ident_docto
                           AND d.cod_docto IN ( 'CF-E'
                                              , 'SAT' )
                           AND i.ident_produto = p.ident_produto
                           AND i.ident_cfo = c.ident_cfo
                      GROUP BY cod_estab
                             , data_fiscal
                             , num_docfis
                             , c.cod_cfo
                             , p.cod_produto
                      UNION ALL
                      SELECT   cod_estab
                             , data_emissao data_fiscal
                             , num_coo num_cupom
                             , 'CF' tipo_doc
                             , c.cod_cfo
                             , p.cod_produto
                             , SUM ( i.vlr_liq_item ) vlr_liq
                          FROM msaf.x994_item_cupom_ecf i
                             , msaf.x2013_produto p
                             , msaf.x2012_cod_fiscal c
                         WHERE i.cod_empresa = msafi.dpsp.empresa
                           AND i.cod_estab = p_cod_estab
                           AND i.data_emissao BETWEEN TO_DATE ( p_data_ini
                                                              , 'DD/MM/YYYY' )
                                                  AND TO_DATE ( p_data_fim
                                                              , 'DD/MM/YYYY' )
                           AND i.ident_produto = p.ident_produto
                           AND i.ident_cfo = c.ident_cfo
                      GROUP BY cod_estab
                             , num_coo
                             , data_emissao
                             , c.cod_cfo
                             , p.cod_produto) a
                   , (SELECT   DISTINCT /*+DRIVING_SITE(PS)*/
                                       a.inv_item_id
                                      , a.mrank
                                      , MAX ( a.aliq ) AS aliq
                          FROM (SELECT inv_item_id
                                     , b.dpsp_carga_tribut aliq
                                     , RANK ( )
                                           OVER ( PARTITION BY b.inv_item_id
                                                  ORDER BY
                                                      b.inv_item_id ASC
                                                    , b.effdt DESC )
                                           mrank
                                  FROM fdspprd.ps_dsp_ln_mva_his@dblink_dbpsprod b
                                 WHERE crit_state_to_pbl <> crit_state_fr_pbl
                                   AND crit_state_fr_pbl = 'SP'
                                   AND b.effdt <= TO_DATE ( p_data_fim
                                                          , 'DD/MM/YYYY' )) a
                         WHERE a.mrank = 1
                      GROUP BY a.inv_item_id
                             , a.mrank) ps
               WHERE a.cod_produto = ps.inv_item_id(+)
            GROUP BY cod_estab
                   , data_fiscal
                   , num_cupom
                   , cod_cfo
                   , cod_produto
                   , a.tipo_doc
                   , ps.aliq;
    BEGIN
        -- CRIA PROCESSO
        mproc_id :=
            lib_proc.new ( 'MSAF_DSP_REL_FAT_ALIQ_CPROC'
                         , 48
                         , 150 );

        BEGIN
            FOR reg IN cur_x01 ( p_data_ini
                               , p_data_fim
                               , p_cod_estab ) LOOP
                /* BEGIN
                   NULL;
                   UPDATE MSAFGEPD.X01_CONTABIL B
                      SET B.TXT_HISTCOMPL = REG.TXT_NOVO
                    WHERE B.ROWID = REG.ROWID;
                   --EXCEPTION WHEN OTHERS THEN
                   --LIB_PROC.ADD_LOG('NAO FOI POSSIVEL AJUSTAR A X01'||'-'||REG.DATA_LANCTO||'-'||REG.ARQUIVAMENTO,1);

                 END;*/

                x := x + 1;

                IF x >= 200 THEN
                    x := 0;
                    COMMIT;
                END IF;
            END LOOP;

            COMMIT;
            lib_proc.add_log ( 'PROCESSO FINALIZADO COM SUCESSO.'
                             , 1 );
        END;

        lib_proc.close ( );
        RETURN mproc_id;
    END;
END msaf_dsp_rel_fat_aliq_cproc;
/
SHOW ERRORS;
