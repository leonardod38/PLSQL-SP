Prompt Package Body DPSP_CONF_MSAF_SAP_CPROC;
--
-- DPSP_CONF_MSAF_SAP_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_conf_msaf_sap_cproc
IS
    /*
    CREATE GLOBAL TEMPORARY TABLE MSAFI.DPSP_MSAF_ARQUIVO_NF_SAP
    ( linha integer,
      registro VARCHAR2(2000)
    )
    ON COMMIT PRESERVE ROWS;
    */

    vs_mcod_usuario usuario_estab.cod_usuario%TYPE;
    vs_mproc_id NUMBER;

    --TIPO, NOME E DESCRIÇÃO DO CUSTOMIZADO
    mnm_tipo VARCHAR2 ( 100 ) := 'Equalização';
    mnm_cproc VARCHAR2 ( 100 ) := 'Conciliacao SAPXMSAF';
    mds_cproc VARCHAR2 ( 100 ) := 'Conciliacao SAPXMSAF origem arquivo TXT';

    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );

        v_sel_data_fim VARCHAR2 ( 260 )
            := ' SELECT TRUNC( TO_DATE( :3 ,''DD/MM/YYYY'') + ROWNUM - 1) AS DATA_FIM, TRUNC( TO_DATE( :3 ,''DD/MM/YYYY'') + ROWNUM - 1) AS DATA_FIM FROM DUAL CONNECT BY ROWNUM <= LAST_DAY( TO_DATE( :3 ,''DD/MM/YYYY'') ) - TO_DATE( :3 ,''DD/MM/YYYY'') + 1 ORDER BY 1 DESC ';
    BEGIN
        vs_mcod_usuario := lib_parametros.recuperar ( 'USUARIO' );

        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS= '',.'' ';

        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT="DD/MM/YYYY"';

        lib_proc.add_param (
                             pparam => pstr
                           , ptitulo => 'Diretório'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'COMBOBOX'
                           , pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => NULL
                           , pvalores =>    'SELECT DISTINCT directory_path ,'
                                         || '       directory_name||'' - ''||directory_path directory_name from'
                                         || ' (SELECT directory_path ,'
                                         || '       directory_name ,'
                                         || '       msaf.get_dir_list_f(a.directory_path) tem_arquivo'
                                         || '  FROM all_directories a)'
                                         || ' where tem_arquivo = 1 order by directory_name'
                           , phabilita => NULL
        );

        --P_DIR
        lib_proc.add_param ( pparam => pstr
                           , ptitulo => 'Pasta'
                           , ptipo => 'VARCHAR2'
                           , pcontrole => 'COMBOBOX'
                           , pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => NULL
                           , pvalores => 'select distinct filename, filename from DIR_LIST where pathname = :1 '
                           , phabilita => NULL );

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

        --P_COD_ESTAB
        lib_proc.add_param (
                             pparam => pstr
                           , ptitulo => 'Filiais'
                           , --P_LOJAS
                            ptipo => 'VARCHAR2'
                           , pcontrole => 'MULTISELECT'
                           , pmandatorio => 'S'
                           , pdefault => NULL
                           , pmascara => NULL
                           , pvalores => 'SELECT A.COD_ESTAB, A.COD_ESTAB || '' - '' || B.COD_ESTADO || '' - '' || A.CGC || '' - '' || INITCAP(A.BAIRRO) || '' / '' || INITCAP(A.CIDADE) FROM ESTABELECIMENTO A, ESTADO B, MSAFI.DSP_ESTABELECIMENTO C WHERE A.COD_EMPRESA  = MSAFI.DPSP.EMPRESA AND B.IDENT_ESTADO = A.IDENT_ESTADO AND A.COD_EMPRESA = C.COD_EMPRESA AND A.COD_ESTAB = C.COD_ESTAB AND C.TIPO = ''L'' AND C.COD_ESTADO = ''SP'' ORDER BY B.COD_ESTADO, A.COD_ESTAB'
                           , phabilita => NULL
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
        RETURN '1.0';
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

    FUNCTION recupera_campo ( v_texto VARCHAR2
                            , v_campo_desejado INTEGER )
        RETURN VARCHAR2
    IS
        --  v_texto VARCHAR2(4000) := '|0000026234||SE|1|12.07.2018|03.08.2018|03.08.2018|BDOROTHEIA |00.00.0000|         |    |01|   |           000000| | |5105615014|2018|2000|0714             |LF|1000042046|         |00.00.0000|0000000000|CIF  |CIF                 |                  |            2.900,00 |BRL  |X                          |000002048                       |X                 |000010|SERV.MANUT. DE VIDRO                   |0000000000|000000|2933/AA|SERV1401    | |  |00000| | |LI|51056150142018|000001|        1 |UA |UA | 2.900,000000 |    2.900,00 |BRL  |   |   |X|             0,00 |BRL  |              0,00 |BRL  |            0,00 |BRL  |Z4|               0,00 |BRL  |0714| 2.900,000000 | 2.900,00 |BRL  |  0,00 |BRL  | 0,00 |BRL  |  0,00 |BRL  |   0,00 |BRL  | 2.900,00 |BRL  | 2.900,00 |BRL  |IS0    |07             |          |                      |                  |                  |IPSW|      2.900,00 |BRL  |  0,65 |      18,85 |BRL  |             0,00 |BRL  |            0,00 |BRL  |        |';
        v_result VARCHAR2 ( 4000 );

        -- v_campo_desejado  INTEGER := 5;
        v_campo_atual INTEGER := 0;
        v_posicao_atual_1 INTEGER := 1;
        v_posicao_atual_2 INTEGER := 1;
    BEGIN
        WHILE v_campo_desejado > v_campo_atual LOOP
            v_posicao_atual_1 := v_posicao_atual_2;
            v_posicao_atual_2 :=
                INSTR ( v_texto
                      , '|'
                      , v_posicao_atual_1 + 1 );
            v_campo_atual := v_campo_atual + 1;
        END LOOP;

        v_result :=
            SUBSTR ( v_texto
                   , ( v_posicao_atual_1 + 1 )
                   , ( v_posicao_atual_2 - 1 ) - ( v_posicao_atual_1 + 1 ) + 1 );

        RETURN v_result;
    --dbms_output.put_line(v_result);

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

    PROCEDURE load_archive ( vp_dir VARCHAR2
                           , vp_file VARCHAR2 )
    IS
        l_vdir VARCHAR2 ( 10000 );
        l_farquivo utl_file.file_type;
        l_vline VARCHAR2 ( 32767 );
        v_count NUMBER := 0;
        v_sqlerrm VARCHAR2 ( 256 );
        v_file_name VARCHAR2 ( 500 ) := vp_file;
    ---

    BEGIN
        /*
          SELECT LTRIM(RTRIM(substr(registro, 2, 10)))N_DOC1,
        LTRIM(RTRIM(substr(registro, 13, 2)))CN,
        LTRIM(RTRIM(substr(registro, 16, 1)))M1,
        LTRIM(RTRIM(substr(registro, 18, 10)))DATA_DOC,
        LTRIM(RTRIM(substr(registro, 29, 10)))DT_LCTO,
        LTRIM(RTRIM(substr(registro, 40, 10)))CRIADO_EM,
        LTRIM(RTRIM(substr(registro, 51, 11)))CRIADO_POR,
        LTRIM(RTRIM(substr(registro, 63, 10)))MODIF_EM,
        LTRIM(RTRIM(substr(registro, 74, 9)))MODIF_POR,
        LTRIM(RTRIM(substr(registro, 84, 4)))FORM,
        LTRIM(RTRIM(substr(registro, 89, 2)))M2,
        LTRIM(RTRIM(substr(registro, 92, 3)))SER,
        LTRIM(RTRIM(substr(registro, 96, 17)))N_DA_NOTA_FISCAL,
        LTRIM(RTRIM(substr(registro, 114, 1)))I1,
        LTRIM(RTRIM(substr(registro, 116, 1)))M3,
        LTRIM(RTRIM(substr(registro, 118, 10)))N_DOC2,
        LTRIM(RTRIM(substr(registro, 129, 4)))ANO,
        LTRIM(RTRIM(substr(registro, 134, 4)))EMPR,
        LTRIM(RTRIM(substr(registro, 139, 17)))LOCAL_DE_NEGOCIOS,
        LTRIM(RTRIM(substr(registro, 157, 2)))FP,
        LTRIM(RTRIM(substr(registro, 160, 10)))ID_PARC,
        LTRIM(RTRIM(substr(registro, 171, 9)))ESTORNADO,
        LTRIM(RTRIM(substr(registro, 181, 10)))DT_ESTORNO,
        LTRIM(RTRIM(substr(registro, 192, 10)))DOC_ORIG1,
        LTRIM(RTRIM(substr(registro, 203, 5)))INCTM,
        LTRIM(RTRIM(substr(registro, 209, 20)))INCOTM_2,
        LTRIM(RTRIM(substr(registro, 230, 18)))OBS,
        LTRIM(RTRIM(substr(registro, 249, 21)))VALOR_TOTAL_INCL_IMP,
        LTRIM(RTRIM(substr(registro, 271, 5)))MOEDA1,
        LTRIM(RTRIM(substr(registro, 277, 27)))DOCUMENTO_FISCAL_ELETRONICO,
        LTRIM(RTRIM(substr(registro, 305, 32)))NUM_DE_NOTA_FISCAL_ELETRONICA,
        LTRIM(RTRIM(substr(registro, 338, 18)))NF_NF_E_DO_SERVICO,
        LTRIM(RTRIM(substr(registro, 357, 6)))N_IT,
        LTRIM(RTRIM(substr(registro, 364, 39)))TEXTO_BREVE_DE_MATERIAL,
        LTRIM(RTRIM(substr(registro, 404, 10)))DOC_ORIG2,
        LTRIM(RTRIM(substr(registro, 415, 6)))ITNF,
        LTRIM(RTRIM(substr(registro, 422, 7)))CFOP,
        LTRIM(RTRIM(substr(registro, 430, 12)))CÓD_CONTROLE,
        LTRIM(RTRIM(substr(registro, 443, 1)))O,
        LTRIM(RTRIM(substr(registro, 445, 2)))S,
        LTRIM(RTRIM(substr(registro, 448, 5)))SITTR,
        LTRIM(RTRIM(substr(registro, 454, 1)))P,
        LTRIM(RTRIM(substr(registro, 456, 1)))U,
        LTRIM(RTRIM(substr(registro, 458, 2)))TR,
        LTRIM(RTRIM(substr(registro, 461, 14)))REF_DOC_ORIGEM,
        LTRIM(RTRIM(substr(registro, 476, 6)))ITRFDC,
        LTRIM(RTRIM(substr(registro, 483, 10)))QUANTIDADE,
        LTRIM(RTRIM(substr(registro, 494, 3)))UM1,
        LTRIM(RTRIM(substr(registro, 498, 3)))UM2,
        LTRIM(RTRIM(substr(registro, 502, 14)))PRECO_LÍQ,
        LTRIM(RTRIM(substr(registro, 517, 13)))VALOR_LÍQUIDO,
        LTRIM(RTRIM(substr(registro, 531, 5)))MOEDA2,
        LTRIM(RTRIM(substr(registro, 537, 3)))TXT1,
        LTRIM(RTRIM(substr(registro, 541, 3)))TXT2,
        LTRIM(RTRIM(substr(registro, 545, 1)))I2,
        LTRIM(RTRIM(substr(registro, 547, 18)))MONT_LIQUIDO_FRETE,
        LTRIM(RTRIM(substr(registro, 566, 5)))MOEDA3,
        LTRIM(RTRIM(substr(registro, 572, 19)))MONT_LIQUIDO_SEGURO,
        LTRIM(RTRIM(substr(registro, 592, 5)))MOEDA4,
        LTRIM(RTRIM(substr(registro, 598, 17)))DESPESAS_LÍQUIDAS,
        LTRIM(RTRIM(substr(registro, 616, 5)))MOEDA5,
        LTRIM(RTRIM(substr(registro, 622, 2)))TI,
        LTRIM(RTRIM(substr(registro, 625, 20)))MONT_LIQUIDO_REDUCAO,
        LTRIM(RTRIM(substr(registro, 646, 5)))MOEDA6,
        LTRIM(RTRIM(substr(registro, 652, 4)))CEN,
        LTRIM(RTRIM(substr(registro, 657, 14)))LIQUIDO,
        LTRIM(RTRIM(substr(registro, 672, 10)))VALOR,
        LTRIM(RTRIM(substr(registro, 683, 5)))MOEDA7,
        LTRIM(RTRIM(substr(registro, 689, 7)))REDUÇCAO,
        LTRIM(RTRIM(substr(registro, 697, 5)))MOEDA8,
        LTRIM(RTRIM(substr(registro, 703, 6)))FRETE,
        LTRIM(RTRIM(substr(registro, 710, 5)))MOEDA9,
        LTRIM(RTRIM(substr(registro, 716, 7)))SEGUROS,
        LTRIM(RTRIM(substr(registro, 724, 5)))MOEDA10,
        LTRIM(RTRIM(substr(registro, 730, 8)))DESPESAS,
        LTRIM(RTRIM(substr(registro, 739, 5)))MOEDA11,
        LTRIM(RTRIM(substr(registro, 745, 10)))TOTAL1,
        LTRIM(RTRIM(substr(registro, 756, 5)))MOEDA12,
        LTRIM(RTRIM(substr(registro, 762, 10)))TOTAL2,
        LTRIM(RTRIM(substr(registro, 773, 5)))MOEDA13,
        LTRIM(RTRIM(substr(registro, 779, 7)))LEI_ISS,
        LTRIM(RTRIM(substr(registro, 787, 15)))SITUACAO_FISCAL,
        LTRIM(RTRIM(substr(registro, 803, 10)))LEI_COFINS,
        LTRIM(RTRIM(substr(registro, 814, 22)))SITUACAO_FISCAL_COFINS,
        LTRIM(RTRIM(substr(registro, 837, 18)))LEI_TRIBUTARIA_PIS,
        LTRIM(RTRIM(substr(registro, 856, 18)))SITUACAO_FISCAL_PI,
        LTRIM(RTRIM(substr(registro, 875, 4)))TPIM,
        LTRIM(RTRIM(substr(registro, 880, 15)))MONTANTE_BASICO,
        LTRIM(RTRIM(substr(registro, 896, 5)))MOEDA14,
        LTRIM(RTRIM(substr(registro, 902, 7)))TX_IMP,
        LTRIM(RTRIM(substr(registro, 910, 12)))VALOR_FISCAL,
        LTRIM(RTRIM(substr(registro, 923, 5)))MOEDA15,
        LTRIM(RTRIM(substr(registro, 929, 18)))MONT_BASE_EXCLUÍDO,
        LTRIM(RTRIM(substr(registro, 948, 5)))MOEDA16,
        LTRIM(RTRIM(substr(registro, 954, 17)))OUTRO_MONT_BASICO,
        LTRIM(RTRIM(substr(registro, 972, 5)))MOEDA17,
        LTRIM(RTRIM(substr(registro, 978, 8)))N_NFS_E,
        REGEXP_COUNT(replace(registro,'|','##'),'##',1,'i')
          FROM msafi.dpsp_msaf_arquivo_nf_sap
         WHERE substr(registro, 18, 1) IN ('0', '1', '2', '3')
        ;

        create table msafi.dpsp_carga_arq_nf_sap
        (
        N_doc1 varchar2(45),
        CN varchar2(45),
        M1 varchar2(45),
        Data_doc varchar2(45),
        Dt_lcto varchar2(45),
        Criado_em varchar2(45),
        Criado_por varchar2(45),
        Modif_em varchar2(45),
        Modif_por varchar2(45),
        Form varchar2(45),
        M2 varchar2(45),
        Ser varchar2(45),
        N_da_nota_fiscal varchar2(45),
        I1 varchar2(45),
        M3 varchar2(45),
        N_doc2 varchar2(45),
        Ano varchar2(45),
        Empr varchar2(45),
        Local_de_negocios varchar2(45),
        FP varchar2(45),
        ID_parc varchar2(45),
        Estornado varchar2(45),
        Dt_estorno varchar2(45),
        Doc_orig1 varchar2(45),
        IncTm varchar2(45),
        Incotm_2 varchar2(45),
        Obs varchar2(45),
        Valor_total_incl_imp varchar2(45),
        Moeda1 varchar2(45),
        Documento_fiscal_eletronico varchar2(45),
        Num_de_nota_fiscal_eletronica varchar2(45),
        NF_NF_e_do_servico varchar2(45),
        N_It varchar2(45),
        Texto_breve_de_material varchar2(45),
        Doc_orig2 varchar2(45),
        ItNF varchar2(45),
        CFOP varchar2(45),
        Cód_controle varchar2(45),
        O varchar2(45),
        S varchar2(45),
        SitTr varchar2(45),
        P varchar2(45),
        U varchar2(45),
        TR varchar2(45),
        Ref_doc_origem varchar2(45),
        ItRfDc varchar2(45),
        Quantidade varchar2(45),
        UM1 varchar2(45),
        UM2 varchar2(45),
        Preco_líq  varchar2(45),
        Valor_líquido  varchar2(45),
        Moeda2 varchar2(45),
        TXT1 varchar2(45),
        TXT2 varchar2(45),
        I2 varchar2(45),
        Mont_liquido_frete varchar2(45),
        Moeda3 varchar2(45),
        Mont_liquido_seguro varchar2(45),
        Moeda4 varchar2(45),
        Despesas_líquidas varchar2(45),
        Moeda5 varchar2(45),
        TI varchar2(45),
        Mont_liquido_reducao varchar2(45),
        Moeda6 varchar2(45),
        Cen varchar2(45),
        Liquido varchar2(45),
        Valor varchar2(45),
        Moeda7 varchar2(45),
        Reduçcao varchar2(45),
        Moeda8 varchar2(45),
        Frete varchar2(45),
        Moeda9 varchar2(45),
        Seguros varchar2(45),
        Moeda10 varchar2(45),
        Despesas varchar2(45),
        Moeda11 varchar2(45),
        Total1 varchar2(45),
        Moeda12 varchar2(45),
        Total2 varchar2(45),
        Moeda13 varchar2(45),
        Lei_ISS varchar2(45),
        Situacao_fiscal varchar2(45),
        Lei_COFINS varchar2(45),
        Situacao_fiscal_COFINS varchar2(45),
        Lei_tributaria_PIS varchar2(45),
        Situacao_fiscal_PI varchar2(45),
        TpIm varchar2(45),
        Montante_basico varchar2(45),
        Moeda14 varchar2(45),
        Tx_imp varchar2(45),
        Valor_fiscal varchar2(45),
        Moeda15 varchar2(45),
        Mont_base_excluído varchar2(45),
        Moeda16 varchar2(45),
        Outro_mont_basico varchar2(45),
        Moeda17 varchar2(45),
        N_NFS_e varchar2(45)
        )

          */

        l_vdir := vp_dir;
        l_vline := '';

        BEGIN
            --ABRIR ARQUIVO
            l_farquivo :=
                utl_file.fopen ( l_vdir
                               , v_file_name
                               , 'R'
                               , 32767 );

            --LER ARQUIVO
            LOOP
                utl_file.get_line ( l_farquivo
                                  , l_vline );

                v_count := v_count + 1;

                INSERT INTO msafi.dpsp_msaf_arquivo_nf_sap
                     VALUES ( v_count
                            , l_vline );
            END LOOP;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                utl_file.fclose ( l_farquivo );

                loga ( v_file_name || ' [TTL LINHAS]: ' || v_count
                     , FALSE );
            WHEN OTHERS THEN
                v_sqlerrm := SQLERRM;

                IF ( v_sqlerrm NOT LIKE '%ORA-29283%' ) THEN
                    loga ( '<!> NAO FOI POSSIVEL ABRIR ARQUIVO: ' || v_file_name || ' ' || SQLERRM
                         , FALSE );
                ELSE
                    loga ( '<!> NAO FOI POSSIVEL ABRIR ARQUIVO: ' || v_file_name
                         , FALSE );
                END IF;
        END;

        -------------------------------------------------

        INSERT INTO msafi.dpsp_carga_arq_nf_sap
            ( SELECT n_doc1
                   , cn
                   , m1
                   , data_doc
                   , dt_lcto
                   , criado_em
                   , criado_por
                   , modif_em
                   , modif_por
                   , form
                   , m2
                   , ser
                   , n_da_nota_fiscal
                   , i1
                   , m3
                   , n_doc2
                   , ano
                   , empr
                   , local_de_negocios
                   , fp
                   , id_parc
                   , estornado
                   , dt_estorno
                   , doc_orig1
                   , inctm
                   , incotm_2
                   , obs
                   , valor_total_incl_imp
                   , moeda1
                   , documento_fiscal_eletronico
                   , num_de_nota_fiscal_eletronica
                   , nf_nf_e_do_servico
                   , n_it
                   , texto_breve_de_material
                   , doc_orig2
                   , itnf
                   , cfop
                   , cód_controle
                   , o
                   , s
                   , sittr
                   , p
                   , u
                   , tr
                   , ref_doc_origem
                   , itrfdc
                   , quantidade
                   , um1
                   , um2
                   , preco_líq
                   , valor_líquido
                   , moeda2
                   , txt1
                   , txt2
                   , i2
                   , mont_liquido_frete
                   , moeda3
                   , mont_liquido_seguro
                   , moeda4
                   , despesas_líquidas
                   , moeda5
                   , ti
                   , mont_liquido_reducao
                   , moeda6
                   , cen
                   , liquido
                   , valor
                   , moeda7
                   , reduçcao
                   , moeda8
                   , frete
                   , moeda9
                   , seguros
                   , moeda10
                   , despesas
                   , moeda11
                   , total1
                   , moeda12
                   , total2
                   , moeda13
                   , lei_iss
                   , situacao_fiscal
                   , lei_cofins
                   , situacao_fiscal_cofins
                   , lei_tributaria_pis
                   , situacao_fiscal_pi
                   , tpim
                   , montante_basico
                   , moeda14
                   , tx_imp
                   , valor_fiscal
                   , moeda15
                   , mont_base_excluído
                   , moeda16
                   , outro_mont_basico
                   , moeda17
                   , n_nfs_e
                FROM (SELECT LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 1 ) ) )
                                 n_doc1
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 2 ) ) )
                                 cn
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 3 ) ) )
                                 m1
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 4 ) ) )
                                 data_doc
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 5 ) ) )
                                 dt_lcto
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 6 ) ) )
                                 criado_em
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 7 ) ) )
                                 criado_por
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 8 ) ) )
                                 modif_em
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 9 ) ) )
                                 modif_por
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 10 ) ) )
                                 form
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 11 ) ) )
                                 m2
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 12 ) ) )
                                 ser
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 13 ) ) )
                                 n_da_nota_fiscal
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 14 ) ) )
                                 i1
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 15 ) ) )
                                 m3
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 16 ) ) )
                                 n_doc2
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 17 ) ) )
                                 ano
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 18 ) ) )
                                 empr
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 19 ) ) )
                                 local_de_negocios
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 20 ) ) )
                                 fp
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 21 ) ) )
                                 id_parc
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 22 ) ) )
                                 estornado
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 23 ) ) )
                                 dt_estorno
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 24 ) ) )
                                 doc_orig1
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 25 ) ) )
                                 inctm
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 26 ) ) )
                                 incotm_2
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 27 ) ) )
                                 obs
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 28 ) ) )
                                 valor_total_incl_imp
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 29 ) ) )
                                 moeda1
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 30 ) ) )
                                 documento_fiscal_eletronico
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 31 ) ) )
                                 num_de_nota_fiscal_eletronica
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 32 ) ) )
                                 nf_nf_e_do_servico
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 33 ) ) )
                                 n_it
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 34 ) ) )
                                 texto_breve_de_material
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 35 ) ) )
                                 doc_orig2
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 36 ) ) )
                                 itnf
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 37 ) ) )
                                 cfop
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 38 ) ) )
                                 cód_controle
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 39 ) ) )
                                 o
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 40 ) ) )
                                 s
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 41 ) ) )
                                 sittr
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 42 ) ) )
                                 p
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 43 ) ) )
                                 u
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 44 ) ) )
                                 tr
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 45 ) ) )
                                 ref_doc_origem
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 46 ) ) )
                                 itrfdc
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 47 ) ) )
                                 quantidade
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 48 ) ) )
                                 um1
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 49 ) ) )
                                 um2
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 50 ) ) )
                                 preco_líq
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 51 ) ) )
                                 valor_líquido
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 52 ) ) )
                                 moeda2
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 53 ) ) )
                                 txt1
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 54 ) ) )
                                 txt2
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 55 ) ) )
                                 i2
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 56 ) ) )
                                 mont_liquido_frete
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 57 ) ) )
                                 moeda3
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 58 ) ) )
                                 mont_liquido_seguro
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 59 ) ) )
                                 moeda4
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 60 ) ) )
                                 despesas_líquidas
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 61 ) ) )
                                 moeda5
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 62 ) ) )
                                 ti
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 63 ) ) )
                                 mont_liquido_reducao
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 64 ) ) )
                                 moeda6
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 65 ) ) )
                                 cen
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 66 ) ) )
                                 liquido
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 67 ) ) )
                                 valor
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 68 ) ) )
                                 moeda7
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 69 ) ) )
                                 reduçcao
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 70 ) ) )
                                 moeda8
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 71 ) ) )
                                 frete
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 72 ) ) )
                                 moeda9
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 73 ) ) )
                                 seguros
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 74 ) ) )
                                 moeda10
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 75 ) ) )
                                 despesas
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 76 ) ) )
                                 moeda11
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 77 ) ) )
                                 total1
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 78 ) ) )
                                 moeda12
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 79 ) ) )
                                 total2
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 80 ) ) )
                                 moeda13
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 81 ) ) )
                                 lei_iss
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 82 ) ) )
                                 situacao_fiscal
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 83 ) ) )
                                 lei_cofins
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 84 ) ) )
                                 situacao_fiscal_cofins
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 85 ) ) )
                                 lei_tributaria_pis
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 86 ) ) )
                                 situacao_fiscal_pi
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 87 ) ) )
                                 tpim
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 88 ) ) )
                                 montante_basico
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 89 ) ) )
                                 moeda14
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 90 ) ) )
                                 tx_imp
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 91 ) ) )
                                 valor_fiscal
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 92 ) ) )
                                 moeda15
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 93 ) ) )
                                 mont_base_excluído
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 94 ) ) )
                                 moeda16
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 95 ) ) )
                                 outro_mont_basico
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 96 ) ) )
                                 moeda17
                           , LTRIM ( RTRIM ( dpsp_conf_msaf_sap_cproc.recupera_campo ( registro
                                                                                     , 97 ) ) )
                                 n_nfs_e
                           , REGEXP_COUNT ( REPLACE ( registro
                                                    , '|'
                                                    , '##' )
                                          , '##'
                                          , 1
                                          , 'i' )
                        FROM msafi.dpsp_msaf_arquivo_nf_sap
                       WHERE SUBSTR ( registro
                                    , 18
                                    , 1 ) IN ( '0'
                                             , '1'
                                             , '2'
                                             , '3' )) );

        COMMIT;
    END;

    PROCEDURE compara ( vp_data_inicio DATE
                      , vp_data_fim DATE
                      , vp_cod_estab lib_proc.vartab )
    IS
        v_cnpj VARCHAR2 ( 14 );
        v_ver_data_arquivo INTEGER;
    ---

    BEGIN
        --------------------------------------------------
        FOR i IN vp_cod_estab.FIRST .. vp_cod_estab.LAST LOOP
            --OBTER CNPJ DA FILIAL
            SELECT cgc
              INTO v_cnpj
              FROM msaf.estabelecimento
             WHERE cod_empresa = msafi.dpsp.empresa
               AND cod_estab = vp_cod_estab ( i );

            /* SELECT nvl(MAX(1), 0)
             INTO v_ver_data_arquivo
             FROM (SELECT linha,
                          REPLACE(REPLACE(substr(registro, 18, 10), '.', ''),
                                  '/',
                                  ''),
                          substr(registro, 18, 1) data_fiscal
                     FROM msafi.dpsp_msaf_arquivo_nf_sap
                    WHERE substr(registro, 18, 1) IN ('0', '1', '2', '3'))
            WHERE to_date(data_fiscal, 'ddmmyyyy') BETWEEN vp_data_inicio AND
                  vp_data_fim;*/

            IF v_ver_data_arquivo < 1 THEN
                loga ( 'Arquivo não possui registro no período escolhido'
                     , FALSE );
                EXIT;
            END IF;

            FOR c IN ( SELECT REPLACE ( REPLACE ( SUBSTR ( registro
                                                         , 18
                                                         , 10 )
                                                , '.'
                                                , '' )
                                      , '/'
                                      , '' )
                            , SUBSTR ( registro
                                     , 18
                                     , 1 )
                                  data_fiscal
                         FROM msafi.dpsp_msaf_arquivo_nf_sap
                        WHERE 1 = 2 ) LOOP
                NULL;
            END LOOP;
        END LOOP;
    -------------------------------------------------

    END;

    FUNCTION executar ( p_dir VARCHAR2
                      , p_file VARCHAR2
                      , p_data_inicio DATE
                      , p_data_fim DATE
                      , p_cod_estab lib_proc.vartab )
        RETURN INTEGER
    IS
    BEGIN
        vs_mcod_usuario := lib_parametros.recuperar ( 'USUARIO' );

        DELETE FROM dir_list;

        COMMIT;

        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT="DD/MM/YYYY"';

        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS='',.'' ';

        -- CRIAÇÃO: PROCESSO
        vs_mproc_id :=
            lib_proc.new ( psp_nome => $$plsql_unit
                         , prows => 48
                         , pcols => 200 );
        COMMIT;

        loga ( '---INICIO DO PROCESSAMENTO---'
             , FALSE );

        dbms_application_info.set_module ( $$plsql_unit
                                         , 'INICIO' );

        --=================================================
        loga ( '>> STEP 1: LENDO ARQUIVO'
             , FALSE );

        load_archive ( p_dir
                     , p_file );

        loga ( '<< FIM DO STEP 1: LENDO ARQUIVO'
             , FALSE );
        --=================================================

        --=================================================
        loga ( '>> STEP 2: COMPARA'
             , FALSE );

        compara ( p_data_inicio
                , p_data_fim
                , p_cod_estab );

        loga ( '<< FIM DO STEP 2: COMPARA'
             , FALSE );
        --=================================================

        loga ( '---FIM DO PROCESSAMENTO---'
             , FALSE );

        COMMIT;
        lib_proc.close ( );
        RETURN vs_mproc_id;
    END;
END dpsp_conf_msaf_sap_cproc;
/
SHOW ERRORS;
