Prompt Package Body DSP_GIA_CPROC;
--
-- DSP_GIA_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dsp_gia_cproc
IS
    mcod_empresa empresa.cod_empresa%TYPE;
    mcod_estab estabelecimento.cod_estab%TYPE;
    musuario usuario_empresa.cod_usuario%TYPE;

    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );
    BEGIN
        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        mcod_estab := lib_parametros.recuperar ( 'ESTABELECIMENTO' );
        musuario := lib_parametros.recuperar ( 'USUARIO' );

        -- PPARAM:      STRING PASSADA POR REFERÊNCIA;
        -- PTITULO:     TÍTULO DO PARÂMETRO MOSTRADO NA JANELA;
        -- PTIPO:       VARCHAR2, DATE, INTEGER;
        -- PCONTROLE:   MULTIPROC, TEXT, TEXTBOX, COMBOBOX, LISTBOX OU RADIOBUTTON;
        -- PMANDATORIO: S OU N, INDICANDO SE A INFORMAÇÃO DO PARÂMETRO É OBRIGATÓRIA;
        -- PDEFAULT:    VALOR PREENCHIDO AUTOMATICAMENTE NA ABERTURA DA JANELA;
        -- PMASCARA:    MÁSCARA PARA DIGITAÇÃO (EX: DD/MM/YYYY, 999999 OU ######);
        -- PVALORES:    SELECT (COMBOBOX OU MULTIPROC) OU COD1=DESC1,COD2=DESC2...
        -- PAPRESENTA:  S OU N, INDICANDO SE O PARÂMETRO DEVE SER MOSTRADO NA LISTAGEM DOS PROCESSOS;

        lib_proc.add_param ( pstr
                           , -- R001
                            ' '
                           , --
                            'VARCHAR2'
                           , 'TEXT' );
        lib_proc.add_param (
                             pstr
                           , 'PASSO'
                           , --P_PASSO
                            'VARCHAR2'
                           , 'COMBOBOX'
                           , 'S'
                           , NULL
                           , NULL
                           , '
                            SELECT ''0A'',''LOJAS 0A - CÁLCULO DO ESTORNO DE PRODUTO DETERIORADO (APÓS 16H) - DEMORA!'' FROM DUAL
                      UNION SELECT ''0B'',''LOJAS 0B - RELATÓRIO DO ESTORNO DE PRODUTO DETERIORADO'' FROM DUAL
                      UNION SELECT ''01'',''LOJAS 1 - CARGA DE ESTORNO DE PRODUTO DETERIORADO'' FROM DUAL
                      UNION SELECT ''02'',''LOJAS 2 - LIMPAR TRANSF DO SALDO DEVEDOR - ART.98 E 99 RICMS/SP'' FROM DUAL
                      UNION SELECT ''03'',''LOJAS 3 - INSERT TRANSF DO SALDO DEVEDOR - ART.98 E 99 RICMS/SP'' FROM DUAL
                      UNION SELECT ''04'',''LOJAS 4 - REGISTRO 25'' FROM DUAL
                      UNION SELECT ''05'',''DEPÓSITO 902 -  REGISTRO 25'' FROM DUAL
                      UNION SELECT ''06'',''LOJAS 5 - PREENCHIMENTO DADOS INICIAIS GIA-BA'' FROM DUAL
                      UNION SELECT ''07'',''LOJAS 6 - AJUSTE VALOR OUTRAS DAPI-MG'' FROM DUAL
                      UNION SELECT ''08'',''LOJAS 7 - REGISTRO 0200 GIA-RJ'' FROM DUAL
                      UNION SELECT ''09'',''LOJAS 8 - ESTORNO DE CESTA BÁSICA RJ'' FROM DUAL
                      UNION SELECT ''10'',''LOJAS 9 - (SP) ESTORNO DE DÉBITO REF. DEV. COM ICMS-ST'' FROM DUAL
                      UNION SELECT ''11'',''LOJAS 10 - (RJ) ESTORNO DE DÉBITO CONFORME RESOLUÇÃO 889 SEFAZ/RJ DE 12/05/2015'' FROM DUAL
                      ORDER BY 1,2
                           '
        );

        /* -- R001
                LIB_PROC.ADD_PARAM(PSTR,
                                   'MÊS', --P_MES
                                   'NUMBER',
                                   'TEXTBOX',
                                   'S',
                                   TO_NUMBER(TO_CHAR(TRUNC(SYSDATE,'MM')-1,'MM')),
                                   '##');

                LIB_PROC.ADD_PARAM(PSTR,
                                   'ANO', --P_ANO
                                   'NUMBER',
                                   'TEXTBOX',
                                   'S',
                                   TO_NUMBER(TO_CHAR(TRUNC(SYSDATE,'MM')-1,'YYYY')),
                                   '####');*/

        lib_proc.add_param ( pstr
                           , 'PERÍODO'
                           , --P_PERIODO
                            'DATE'
                           , 'TEXTBOX'
                           , 'S'
                           ,   TRUNC ( SYSDATE
                                     , 'MM' )
                             - 1
                           , 'MM/YYYY' ); -- R001

        /* LIB_PROC.ADD_PARAM(PSTR, -- R001
                            'VERIFICOU O PASSO?', --P_VERIFICOU
                            'VARCHAR2',
                            'TEXTBOX',
                            'S',
                            NULL,
                            NULL);*/
        lib_proc.add_param ( pstr
                           , -- R001
                            ' '
                           , --
                            'VARCHAR2'
                           , 'TEXT' );
        lib_proc.add_param ( pstr
                           , -- R001
                            '                         __________________________________'
                           , --
                            'VARCHAR2'
                           , 'TEXT' );
        lib_proc.add_param ( pstr
                           , -- R001
                            'VERIFICOU O PASSO?'
                           , --P_VERIFICOU
                            'VARCHAR2'
                           , 'RADIOBUTTON'
                           , 'S'
                           , 'NAO'
                           , NULL
                           , 'NAO=NÃO,SIM=SIM' );
        lib_proc.add_param ( pstr
                           , -- R001
                            '                         __________________________________'
                           , --
                            'VARCHAR2'
                           , 'TEXT' );

        RETURN pstr;
    END; --FUNCTION PARAMETROS RETURN VARCHAR2 IS

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'AUTO-GIA';
    END;

    FUNCTION tipo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Processos - Fiscal';
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
        RETURN 'Preenchimento automático de registros da GIA';
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
        msafi.dsp_control.writelog ( 'INFO'
                                   , p_i_texto );
    END;

    FUNCTION moeda ( v_conteudo NUMBER )
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN TRIM ( TO_CHAR ( v_conteudo
                              , '9g999g999g990d00' ) );
    END;

    -- REFACTORED PROCEDURE RELATORIO_ITENS_CESTA
    ------------------------------------------------Relatório sintético--------------------------------------------------------

    PROCEDURE relatorio_itens_cesta ( mproc_id IN OUT INTEGER
                                    , p_data1 IN OUT DATE
                                    , p_data2 IN OUT DATE )
    IS
        v_class CHAR ( 1 ) := 'B';

        -- CURSOR - BUSCA ITENS DE CESTA BASICA ERP
        CURSOR crs_produtos
        IS
            SELECT   TO_CHAR ( b.data_fiscal
                             , 'MM/YYYY' )
                         periodo
                   , b.cod_estab
                   , SUM ( CASE WHEN b.estorno_credito_debito = 'C' THEN b.valor_estorno ELSE 0 END ) AS estorno_credito
                   , SUM ( CASE WHEN b.estorno_credito_debito = 'D' THEN b.valor_estorno ELSE 0 END ) AS estorno_debito
                FROM ( SELECT   a.cod_estab
                              , a.data_fiscal
                              , a.base_icms
                              , ( a.aliq_tributo_icms - 7 ) AS perc_estorno
                              , CASE
                                    WHEN a.base_reduz > 0 THEN 0
                                    ELSE ( a.base_icms * ( ( a.aliq_tributo_icms - 7 ) / 100 ) )
                                END
                                    AS valor_estorno
                              --,(A.BASE_ICMS * ((A.ALIQ_TRIBUTO_ICMS - 7)/100)) AS VALOR_ESTORNO
                              , DECODE ( a.movto_e_s, '9', 'D', 'C' ) AS estorno_credito_debito
                              , NVL ( ( SELECT DISTINCT 'S'
                                          FROM msaf.apuracao ap
                                         WHERE ap.cod_empresa = a.cod_empresa
                                           AND ap.cod_estab = a.cod_estab
                                           AND ap.cod_tipo_livro = '108'
                                           AND ap.dat_apuracao = LAST_DAY ( p_data2 ) )
                                    , 'N' )
                                    apuracao
                           FROM (SELECT x07.cod_empresa
                                      , x07.cod_estab
                                      , x07.data_fiscal
                                      , x07.num_docfis
                                      , x07.num_controle_docto
                                      , x2012.cod_cfo
                                      , x07.movto_e_s
                                      , x2013.cod_produto
                                      , x2013.descricao
                                      , x2006.cod_natureza_op
                                      , y2026.cod_situacao_b
                                      , x2043.cod_nbm
                                      , x08.quantidade
                                      , x08.vlr_unit
                                      , x08.vlr_item
                                      , x08.vlr_contab_item
                                      , NVL ( ( SELECT vlr_base
                                                  FROM msaf.x08_base_merc g
                                                 WHERE g.cod_empresa = x08.cod_empresa
                                                   AND g.cod_estab = x08.cod_estab
                                                   AND g.data_fiscal = x08.data_fiscal
                                                   AND g.movto_e_s = x08.movto_e_s
                                                   AND g.norm_dev = x08.norm_dev
                                                   AND g.ident_docto = x08.ident_docto
                                                   AND g.ident_fis_jur = x08.ident_fis_jur
                                                   AND g.num_docfis = x08.num_docfis
                                                   AND g.serie_docfis = x08.serie_docfis
                                                   AND g.sub_serie_docfis = x08.sub_serie_docfis
                                                   AND g.discri_item = x08.discri_item
                                                   AND g.cod_tributacao = '1'
                                                   AND g.cod_tributo = 'ICMS' )
                                            , 0 )
                                            AS base_icms
                                      , NVL ( ( SELECT g.aliq_tributo
                                                  FROM msaf.x08_trib_merc g
                                                 WHERE g.cod_empresa = x08.cod_empresa
                                                   AND g.cod_estab = x08.cod_estab
                                                   AND g.data_fiscal = x08.data_fiscal
                                                   AND g.movto_e_s = x08.movto_e_s
                                                   AND g.norm_dev = x08.norm_dev
                                                   AND g.ident_docto = x08.ident_docto
                                                   AND g.ident_fis_jur = x08.ident_fis_jur
                                                   AND g.num_docfis = x08.num_docfis
                                                   AND g.serie_docfis = x08.serie_docfis
                                                   AND g.sub_serie_docfis = x08.sub_serie_docfis
                                                   AND g.discri_item = x08.discri_item
                                                   AND g.cod_tributo = 'ICMS' )
                                            , 0 )
                                            AS aliq_tributo_icms
                                      , NVL ( ( SELECT g.vlr_tributo
                                                  FROM msaf.x08_trib_merc g
                                                 WHERE g.cod_empresa = x08.cod_empresa
                                                   AND g.cod_estab = x08.cod_estab
                                                   AND g.data_fiscal = x08.data_fiscal
                                                   AND g.movto_e_s = x08.movto_e_s
                                                   AND g.norm_dev = x08.norm_dev
                                                   AND g.ident_docto = x08.ident_docto
                                                   AND g.ident_fis_jur = x08.ident_fis_jur
                                                   AND g.num_docfis = x08.num_docfis
                                                   AND g.serie_docfis = x08.serie_docfis
                                                   AND g.sub_serie_docfis = x08.sub_serie_docfis
                                                   AND g.discri_item = x08.discri_item
                                                   AND g.cod_tributo = 'ICMS' )
                                            , 0 )
                                            AS icms
                                      , NVL ( ( SELECT vlr_base
                                                  FROM msaf.x08_base_merc g
                                                 WHERE g.cod_empresa = x08.cod_empresa
                                                   AND g.cod_estab = x08.cod_estab
                                                   AND g.data_fiscal = x08.data_fiscal
                                                   AND g.movto_e_s = x08.movto_e_s
                                                   AND g.norm_dev = x08.norm_dev
                                                   AND g.ident_docto = x08.ident_docto
                                                   AND g.ident_fis_jur = x08.ident_fis_jur
                                                   AND g.num_docfis = x08.num_docfis
                                                   AND g.serie_docfis = x08.serie_docfis
                                                   AND g.sub_serie_docfis = x08.sub_serie_docfis
                                                   AND g.discri_item = x08.discri_item
                                                   AND g.cod_tributacao = '2'
                                                   AND g.cod_tributo = 'ICMS' )
                                            , 0 )
                                            AS base_isento
                                      , x08.vlr_outras base_outras
                                      , NVL ( ( SELECT vlr_base
                                                  FROM msaf.x08_base_merc g
                                                 WHERE g.cod_empresa = x08.cod_empresa
                                                   AND g.cod_estab = x08.cod_estab
                                                   AND g.data_fiscal = x08.data_fiscal
                                                   AND g.movto_e_s = x08.movto_e_s
                                                   AND g.norm_dev = x08.norm_dev
                                                   AND g.ident_docto = x08.ident_docto
                                                   AND g.ident_fis_jur = x08.ident_fis_jur
                                                   AND g.num_docfis = x08.num_docfis
                                                   AND g.serie_docfis = x08.serie_docfis
                                                   AND g.sub_serie_docfis = x08.sub_serie_docfis
                                                   AND g.discri_item = x08.discri_item
                                                   AND g.cod_tributacao = '4'
                                                   AND g.cod_tributo = 'ICMS' )
                                            , 0 )
                                            base_reduz
                                      , NVL ( ( SELECT vlr_base
                                                  FROM msaf.x08_base_merc g
                                                 WHERE g.cod_empresa = x08.cod_empresa
                                                   AND g.cod_estab = x08.cod_estab
                                                   AND g.data_fiscal = x08.data_fiscal
                                                   AND g.movto_e_s = x08.movto_e_s
                                                   AND g.norm_dev = x08.norm_dev
                                                   AND g.ident_docto = x08.ident_docto
                                                   AND g.ident_fis_jur = x08.ident_fis_jur
                                                   AND g.num_docfis = x08.num_docfis
                                                   AND g.serie_docfis = x08.serie_docfis
                                                   AND g.sub_serie_docfis = x08.sub_serie_docfis
                                                   AND g.discri_item = x08.discri_item
                                                   AND g.cod_tributacao = '1'
                                                   AND g.cod_tributo = 'IPI' )
                                            , 0 )
                                            base_ipi
                                      , NVL ( ( SELECT g.vlr_tributo
                                                  FROM msaf.x08_trib_merc g
                                                 WHERE g.cod_empresa = x08.cod_empresa
                                                   AND g.cod_estab = x08.cod_estab
                                                   AND g.data_fiscal = x08.data_fiscal
                                                   AND g.movto_e_s = x08.movto_e_s
                                                   AND g.norm_dev = x08.norm_dev
                                                   AND g.ident_docto = x08.ident_docto
                                                   AND g.ident_fis_jur = x08.ident_fis_jur
                                                   AND g.num_docfis = x08.num_docfis
                                                   AND g.serie_docfis = x08.serie_docfis
                                                   AND g.sub_serie_docfis = x08.sub_serie_docfis
                                                   AND g.discri_item = x08.discri_item
                                                   AND g.cod_tributo = 'IPI' )
                                            , 0 )
                                            AS valor_ipi
                                      , NVL ( ( SELECT vlr_base
                                                  FROM msaf.x08_base_merc g
                                                 WHERE g.cod_empresa = x08.cod_empresa
                                                   AND g.cod_estab = x08.cod_estab
                                                   AND g.data_fiscal = x08.data_fiscal
                                                   AND g.movto_e_s = x08.movto_e_s
                                                   AND g.norm_dev = x08.norm_dev
                                                   AND g.ident_docto = x08.ident_docto
                                                   AND g.ident_fis_jur = x08.ident_fis_jur
                                                   AND g.num_docfis = x08.num_docfis
                                                   AND g.serie_docfis = x08.serie_docfis
                                                   AND g.sub_serie_docfis = x08.sub_serie_docfis
                                                   AND g.discri_item = x08.discri_item
                                                   AND g.cod_tributacao = '1'
                                                   AND g.cod_tributo = 'ICMS-S' )
                                            , 0 )
                                            base_icmss
                                      , NVL ( ( SELECT g.vlr_tributo
                                                  FROM msaf.x08_trib_merc g
                                                 WHERE g.cod_empresa = x08.cod_empresa
                                                   AND g.cod_estab = x08.cod_estab
                                                   AND g.data_fiscal = x08.data_fiscal
                                                   AND g.movto_e_s = x08.movto_e_s
                                                   AND g.norm_dev = x08.norm_dev
                                                   AND g.ident_docto = x08.ident_docto
                                                   AND g.ident_fis_jur = x08.ident_fis_jur
                                                   AND g.num_docfis = x08.num_docfis
                                                   AND g.serie_docfis = x08.serie_docfis
                                                   AND g.sub_serie_docfis = x08.sub_serie_docfis
                                                   AND g.discri_item = x08.discri_item
                                                   AND g.cod_tributo = 'ICMS-S' )
                                            , 0 )
                                            AS vlr_icmss
                                      , x08.vlr_frete AS frete
                                      , x08.vlr_outras AS despesas
                                   FROM msaf.x07_docto_fiscal x07
                                      , msaf.x08_itens_merc x08
                                      , msaf.x2013_produto x2013
                                      , msaf.x2006_natureza_op x2006
                                      , msaf.y2026_sit_trb_uf_b y2026
                                      , msaf.x2012_cod_fiscal x2012
                                      , msaf.x2043_cod_nbm x2043
                                      , (SELECT cod_estab
                                           FROM msafi.dsp_estabelecimento
                                          WHERE cod_estado = 'RJ') est
                                  WHERE 1 = 1
                                    AND x08.data_fiscal BETWEEN p_data1 AND p_data2
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
                                    AND x2013.ident_produto = x08.ident_produto
                                    AND x07.cod_estab = est.cod_estab
                                    AND x2012.ident_cfo = x08.ident_cfo
                                    AND x2043.ident_nbm = x08.ident_nbm
                                    AND x2006.ident_natureza_op = x08.ident_natureza_op
                                    AND y2026.ident_situacao_b = x08.ident_situacao_b) a
                          WHERE a.aliq_tributo_icms > 7
                       --     AND EXISTS (SELECT 'X'
                       --                         FROM MSAF.APURACAO AP
                       --                        WHERE AP.COD_EMPRESA = A.COD_EMPRESA
                       --                          AND AP.COD_ESTAB = A.COD_ESTAB
                       --                          AND AP.COD_TIPO_LIVRO = '108'
                       --                          AND AP.DAT_APURACAO = LAST_DAY(P_DATA2))
                       ORDER BY a.cod_estab
                              , a.movto_e_s
                              , a.data_fiscal ) b
            GROUP BY TO_CHAR ( b.data_fiscal
                             , 'MM/YYYY' )
                   , b.cod_estab;
    --FIM SELECT
    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS='',.'' ';

        -- CRIA RELATORIO ITENS_CESTA_BASICA
        lib_proc.add_tipo ( mproc_id
                          , 2
                          ,    'RELATÓRIO_SINTÉTICO_CESTA_BASICA_'
                            || TO_CHAR ( p_data2
                                       , 'YYYYMM' )
                            || '.XLS'
                          , 2 );

        -- INICIA PLANILHA
        lib_proc.add ( dsp_planilha.header
                     , ptipo => 2 );
        lib_proc.add ( dsp_planilha.tabela_inicio
                     , ptipo => 2 );
        --
        lib_proc.add ( dsp_planilha.linha (
                                               dsp_planilha.campo ( 'PERIODO' )
                                            || dsp_planilha.campo ( 'COD_ESTAB' )
                                            || dsp_planilha.campo ( 'ESTORNO_CREDITO' )
                                            || dsp_planilha.campo ( 'ESTORNO_DEBITO' )
                                          , p_class => 'H'
                       )
                     , ptipo => 2 );

        --EXECUTE IMMEDIATE 'TRUNCATE TABLE DSP_GIA_CESTB';
        --
        FOR c IN crs_produtos LOOP
            -- ADICIONA LINHA RELATORIO
            lib_proc.add ( dsp_planilha.linha (
                                                   dsp_planilha.campo ( c.periodo )
                                                || dsp_planilha.campo ( c.cod_estab )
                                                || dsp_planilha.campo ( moeda ( c.estorno_credito ) )
                                                || dsp_planilha.campo ( moeda ( c.estorno_debito ) )
                                              , p_class => v_class
                           )
                         , ptipo => 2 );

            IF v_class = 'A' THEN
                v_class := 'B';
            ELSE
                v_class := 'A';
            END IF;
        --

        END LOOP;

        lib_proc.add ( dsp_planilha.tabela_fim
                     , ptipo => 2 );
    END relatorio_itens_cesta;

    -- REFACTORED PROCEDURE INICIA_PLANILHA
    PROCEDURE inicia_planilha ( p_tipo INTEGER )
    IS
        c_cabecalho CONSTANT VARCHAR2 ( 1510 )
            :=    dsp_planilha.campo ( 'COD_ESTAB' )
               || --
                 dsp_planilha.campo ( 'DATA_FISCAL' )
               || --
                 dsp_planilha.campo ( 'NUM_DOCFIS' )
               || --
                 dsp_planilha.campo ( 'NUM_CONTROLE_DOCTO' )
               || --
                 dsp_planilha.campo ( 'COD_CFO' )
               || --
                 dsp_planilha.campo ( 'COD_PRODUTO' )
               || --
                 dsp_planilha.campo ( 'DESCRICAO' )
               || --
                 dsp_planilha.campo ( 'COD_NATUREZA_OP' )
               || --
                 dsp_planilha.campo ( 'COD_SITUACAO_B' )
               || --
                 dsp_planilha.campo ( 'COD_NBM' )
               || --
                 dsp_planilha.campo ( 'QUANTIDADE' )
               || --
                 dsp_planilha.campo ( 'VLR_UNIT' )
               || --
                 dsp_planilha.campo ( 'VLR_ITEM' )
               || --
                 dsp_planilha.campo ( 'VLR_CONTAB_ITEM' )
               || --
                 dsp_planilha.campo ( 'BASE_ICMS' )
               || --
                 dsp_planilha.campo ( 'ALIQ_TRIBUTO_ICMS' )
               || --
                 dsp_planilha.campo ( 'ICMS' )
               || --
                 dsp_planilha.campo ( 'BASE_ISENTO' )
               || --
                 dsp_planilha.campo ( 'BASE_OUTRAS' )
               || --
                 dsp_planilha.campo ( 'BASE_REDUZ' )
               || --
                 dsp_planilha.campo ( 'BASE_IPI' )
               || --
                 dsp_planilha.campo ( 'VALOR_IPI' )
               || --
                 dsp_planilha.campo ( 'BASE_ICMSS' )
               || --
                 dsp_planilha.campo ( 'VLR_ICMSS' )
               || --
                 dsp_planilha.campo ( 'FRETE' )
               || --
                 dsp_planilha.campo ( 'DESPESAS' )
               || dsp_planilha.campo ( 'PERC_ESTORNO' )
               || --
                 dsp_planilha.campo ( 'VALOR_ESTORNO' )
               || --
                 dsp_planilha.campo ( 'ESTORNO_CREDITO_DEBITO' ) ;
    BEGIN
        lib_proc.add ( dsp_planilha.header
                     , ptipo => p_tipo );
        lib_proc.add ( dsp_planilha.tabela_inicio
                     , ptipo => p_tipo );
        --
        lib_proc.add ( dsp_planilha.linha ( c_cabecalho
                                          , p_class => 'H' )
                     , ptipo => p_tipo );
    END inicia_planilha;

    -- REFACTORED PROCEDURE INSERE_LINHA
    PROCEDURE insere_linha ( v_class IN OUT CHAR
                           , rs_itens IN OUT crs_itens%ROWTYPE
                           , p_tipo INTEGER )
    IS
    BEGIN
        lib_proc.add ( dsp_planilha.linha (
                                               dsp_planilha.campo ( rs_itens.cod_estab )
                                            || --
                                              dsp_planilha.campo ( rs_itens.data_fiscal )
                                            || --
                                               --DSP_PLANILHA.CAMPO(RS_ITENS.NUM_DOCFIS) || --
                                               dsp_planilha.campo ( dsp_planilha.texto ( rs_itens.num_docfis ) )
                                            || dsp_planilha.campo (
                                                                    dsp_planilha.texto ( rs_itens.num_controle_docto )
                                               )
                                            || --DSP_PLANILHA.CAMPO(RS_ITENS.NUM_CONTROLE_DOCTO) || --
                                               dsp_planilha.campo ( rs_itens.cod_cfo )
                                            || --
                                              dsp_planilha.campo ( rs_itens.cod_produto )
                                            || --
                                              dsp_planilha.campo ( rs_itens.descricao )
                                            || --
                                              dsp_planilha.campo ( rs_itens.cod_natureza_op )
                                            || --
                                               --DSP_PLANILHA.CAMPO(RS_ITENS.COD_SITUACAO_B) || --
                                               dsp_planilha.campo ( dsp_planilha.texto ( rs_itens.cod_situacao_b ) )
                                            || dsp_planilha.campo ( rs_itens.cod_nbm )
                                            || --
                                              dsp_planilha.campo ( rs_itens.quantidade )
                                            || --
                                              dsp_planilha.campo ( rs_itens.vlr_unit )
                                            || --
                                              dsp_planilha.campo ( rs_itens.vlr_item )
                                            || --
                                              dsp_planilha.campo ( rs_itens.vlr_contab_item )
                                            || --
                                              dsp_planilha.campo ( rs_itens.base_icms )
                                            || --
                                              dsp_planilha.campo ( rs_itens.aliq_tributo_icms )
                                            || --
                                              dsp_planilha.campo ( rs_itens.icms )
                                            || --
                                              dsp_planilha.campo ( rs_itens.base_isento )
                                            || --
                                              dsp_planilha.campo ( rs_itens.base_outras )
                                            || --
                                              dsp_planilha.campo ( rs_itens.base_reduz )
                                            || --
                                              dsp_planilha.campo ( rs_itens.base_ipi )
                                            || --
                                              dsp_planilha.campo ( rs_itens.valor_ipi )
                                            || --
                                              dsp_planilha.campo ( rs_itens.base_icmss )
                                            || --
                                              dsp_planilha.campo ( rs_itens.vlr_icmss )
                                            || --
                                              dsp_planilha.campo ( rs_itens.frete )
                                            || --
                                              dsp_planilha.campo ( rs_itens.despesas )
                                            || dsp_planilha.campo ( rs_itens.perc_estorno )
                                            || --
                                              dsp_planilha.campo ( moeda ( rs_itens.valor_estorno ) )
                                            || --
                                              dsp_planilha.campo ( rs_itens.estorno_credito_debito )
                                          , p_class => v_class
                       )
                     , ptipo => p_tipo );
    END insere_linha;

    -- REFACTORED PROCEDURE CREDITO_CESTA_BASICA
    FUNCTION credito_cesta_basica ( mproc_id IN OUT INTEGER
                                  , p_data1 IN OUT DATE
                                  , p_data2 IN OUT DATE )
        RETURN NUMBER
    IS
        v_chave VARCHAR2 ( 100 ) := NULL;
        v_class CHAR ( 1 ) := 'A';
        v_item_apurac item_apurac_discr%ROWTYPE;
        v_cont NUMBER;

        rs_itens crs_itens%ROWTYPE;
    BEGIN
        -- BUSCA ITENS CESTA BASICA
        relatorio_itens_cesta ( mproc_id
                              , p_data1
                              , p_data2 );

        v_cont := 0;
        v_chave := NULL;

        -- CRIA RELATORIO ITENS_CESTA_BASICA
        lib_proc.add_tipo ( mproc_id
                          , 3
                          ,    'RELATÓRIO_ANALITICO_CESTA_BASICA_'
                            || TO_CHAR ( p_data2
                                       , 'YYYYMM' )
                            || '.XLS'
                          , 2 );
        -- INICIA PLANILHA
        inicia_planilha ( 3 );

        FOR est IN crs_estab ( mcod_empresa ) LOOP
            OPEN crs_itens ( mcod_empresa
                           , est.cod_estab
                           , p_data1
                           , p_data2 );

            v_item_apurac.cod_empresa := mcod_empresa;
            v_item_apurac.cod_estab := est.cod_estab;
            v_item_apurac.cod_tipo_livro := '108';
            v_item_apurac.dat_apuracao := p_data2;
            v_item_apurac.dsc_item_apuracao :=
                   'Estorno de Débito - VR. REF. PROD. CESTA BASICA CONFORME DECRETO 46.543/2018  REF. '
                || TO_CHAR ( p_data2
                           , 'MM/YYYY' )
                || ' ';
            v_item_apurac.ind_dig_calculado := '1';
            v_item_apurac.ind_est_deb_conv := 'N';
            v_item_apurac.val_item_discrim := 0;

            LOOP
                FETCH crs_itens
                    INTO rs_itens;

                EXIT WHEN crs_itens%NOTFOUND;

                IF NVL ( v_chave, ' ' ) <>
                       rs_itens.cod_empresa || '|' || rs_itens.cod_estab || '|' || rs_itens.movto_e_s THEN
                    IF v_item_apurac.val_item_discrim > 0 THEN
                        IF rs_itens.movto_e_s = '9' THEN
                            v_item_apurac.cod_oper_apur := '007';
                            v_item_apurac.cod_amparo_legal := 'N089999';
                            v_item_apurac.cod_sub_item_ocorr := '01';
                            v_item_apurac.cod_ajuste_icms := 'RJ039999';
                        ELSE
                            v_item_apurac.cod_oper_apur := '003';
                            v_item_apurac.cod_amparo_legal := 'N030005';
                            v_item_apurac.cod_sub_item_ocorr := '';
                            v_item_apurac.cod_ajuste_icms := 'RJ010005';
                        END IF;


                        --LOGA(RS_ITENS.APURACAO ||'--APura--' ||V_ITEM_APURAC.COD_ESTAB ||'-ESTAB-'|| V_ITEM_APURAC.DAT_APURACAO ||'-DAT_APURACAO-' || V_ITEM_APURAC.COD_OPER_APUR );

                        IF rs_itens.apuracao = 'N' THEN
                            lib_proc.add ( 'ERRO: NÃO FOI POSSÍVEL INSERIR REGISTROS, VERIFIQUE APURAÇÃO:' );
                            lib_proc.add (
                                              ' - ESTABELECIMENTO: '
                                           || v_item_apurac.cod_estab
                                           || '    | LIVRO: '
                                           || v_item_apurac.cod_tipo_livro
                                           || '    | DATA APURAÇÃO: '
                                           || v_item_apurac.dat_apuracao
                                           || '    | COD_OPER_APUR: '
                                           || v_item_apurac.cod_oper_apur
                            );
                        ELSE
                            INSERT INTO item_apurac_discr
                            VALUES v_item_apurac;

                            v_cont := v_cont + 1;
                        END IF;
                    END IF;

                    IF rs_itens.movto_e_s = '9' THEN
                        v_item_apurac.cod_oper_apur := '007';
                        v_item_apurac.cod_amparo_legal := 'N089999';
                        v_item_apurac.cod_sub_item_ocorr := '01';
                        v_item_apurac.cod_ajuste_icms := 'RJ039999';
                    ELSE
                        v_item_apurac.cod_oper_apur := '003';
                        v_item_apurac.cod_amparo_legal := 'N030005';
                        v_item_apurac.cod_sub_item_ocorr := '';
                        v_item_apurac.cod_ajuste_icms := 'RJ010005';
                    END IF;

                    SELECT NVL ( ( SELECT MAX ( num_discriminacao ) + 1
                                     FROM msaf.item_apurac_discr siad
                                    WHERE siad.cod_empresa = rs_itens.cod_empresa
                                      AND siad.cod_estab = v_item_apurac.cod_estab
                                      AND siad.cod_tipo_livro = v_item_apurac.cod_tipo_livro
                                      AND siad.dat_apuracao = v_item_apurac.dat_apuracao
                                      AND siad.cod_oper_apur = v_item_apurac.cod_oper_apur )
                               , 1 )
                      INTO v_item_apurac.num_discriminacao -- NUM_DISCRIMINACAO
                      FROM DUAL;

                    v_item_apurac.val_item_discrim := 0; --  VAL_ITEM_DISCRIM

                    v_chave := rs_itens.cod_empresa || '|' || rs_itens.cod_estab || '|' || rs_itens.movto_e_s;
                END IF;

                v_item_apurac.val_item_discrim := rs_itens.valor_estorno;

                insere_linha ( v_class
                             , rs_itens
                             , 3 );

                IF v_class = 'A' THEN
                    v_class := 'B';
                ELSE
                    v_class := 'A';
                END IF;
            --
            END LOOP;

            IF rs_itens.apuracao = 'N' THEN
                lib_proc.add ( 'ERRO: NÃO FOI POSSÍVEL INSERIR REGISTROS, VERIFIQUE APURAÇÃO:' );
                lib_proc.add (
                                  ' - ESTABELECIMENTO: '
                               || v_item_apurac.cod_estab
                               || '    | LIVRO: '
                               || v_item_apurac.cod_tipo_livro
                               || '    | DATA APURAÇÃO: '
                               || v_item_apurac.dat_apuracao
                               || '    | COD_OPER_APUR: '
                               || v_item_apurac.cod_oper_apur
                );
            ELSE
                IF v_item_apurac.val_item_discrim > 0 THEN
                    INSERT INTO item_apurac_discr
                    VALUES v_item_apurac;

                    v_cont := v_cont + 1;
                END IF;
            END IF;

            CLOSE crs_itens;
        END LOOP;

        lib_proc.add ( dsp_planilha.tabela_fim
                     , ptipo => 3 );

        RETURN v_cont;
    END credito_cesta_basica;

    -- REFACTORED PROCEDURE LIMPA_ITEM_APURAC
    PROCEDURE limpa_item_apurac ( v_data_ini IN OUT DATE
                                , v_data_fim IN OUT DATE )
    IS
    BEGIN
        --FOR EST IN CRS_ESTAB(MCOD_EMPRESA) LOOP
        DELETE FROM msaf.item_apurac_discr iad
              WHERE iad.cod_empresa = mcod_empresa
                --AND IAD.COD_ESTAB = EST.COD_ESTAB
                AND iad.dat_apuracao BETWEEN v_data_ini AND v_data_fim
                AND iad.cod_oper_apur IN ( '003'
                                         , '007' )
                AND ( iad.val_item_discrim = 0
                  OR iad.dsc_item_apuracao =
                            'Estorno de Débito - VR. REF. PROD. CESTA BASICA CONFORME DECRETO 46.543/2018  REF. '
                         || TO_CHAR ( v_data_fim
                                    , 'MM/YYYY' )
                         || ' ' )
                AND EXISTS
                        (SELECT 'Y'
                           FROM msafi.dsp_estabelecimento est1
                          WHERE est1.cod_empresa = iad.cod_empresa
                            AND est1.cod_estab = iad.cod_estab);

        COMMIT;

        loga ( 'DELETE MSAF.ITEM_APURAC_DISCR' );
    --END LOOP;
    --COMMIT;
    END limpa_item_apurac;

    FUNCTION executar ( p_passo VARCHAR2
                      /*, P_MES       NUMBER -- R001
                      , P_ANO       NUMBER*/
                      , p_periodo DATE -- R001
                      , p_verificou VARCHAR2 )
        RETURN INTEGER
    IS
        mproc_id INTEGER;

        v_proc_status NUMBER := 0;
        v_s_proc_status VARCHAR2 ( 16 );

        v_dat_apuracao DATE;
        v_temp1 INTEGER;
        v_temp2 VARCHAR2 ( 128 );
        v_existe VARCHAR2 ( 1 );

        dbg_line_error NUMBER ( 9, 0 );
        ln_upd VARCHAR ( 50 );
        p_data1 DATE;
        p_data2 DATE;
        --- VARIAVEL PARA DETALHE DOS ERROS NO LOG
        v_info VARCHAR2 ( 128 ) := '<NENHUM>';

        p_mes NUMBER; -- R001
        p_ano NUMBER; -- R001
    BEGIN
        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' ); -- R001
        p_mes :=
            TO_NUMBER ( TO_CHAR ( p_periodo
                                , 'MM' ) ); -- R001
        p_ano :=
            TO_NUMBER ( TO_CHAR ( p_periodo
                                , 'YYYY' ) ); -- R001

        dbg_line_error := $$plsql_line;
        mproc_id :=
            lib_proc.new ( 'DSP_GIA_CPROC'
                         , 48
                         , 150 );
        lib_proc.add_tipo ( mproc_id
                          , 1
                          , 'PROCESSO'
                          , 1 );
        lib_proc.add_header ( 'CUSTOMIZADO DA GIA'
                            , 1
                            , 1 );
        lib_proc.add ( ' ' );

        /*IF (P_MES NOT BETWEEN 1 AND 12) THEN -- R001
            LOGA('MÊS INVÁLIDO');
            V_S_PROC_STATUS := 4;
            LIB_PROC.ADD('ERRO! VERIFIQUE O LOG!');
            LIB_PROC.CLOSE;
            RETURN MPROC_ID;
        END IF;
        IF (P_ANO NOT BETWEEN 2012 AND 2017) THEN
            LOGA('ANO INVÁLIDO');
            V_S_PROC_STATUS := 4;
            LIB_PROC.ADD('ERRO! VERIFIQUE O LOG!');
            LIB_PROC.CLOSE;
            RETURN MPROC_ID;
        END IF;*/
        IF ( UPPER ( p_verificou ) <> 'SIM' ) THEN
            loga ( 'VOCÊ DEVE VERIFICAR O PASSO! (RESPONDA SIM NA PERGUNTA "VERIFICOU O PASSO?")' );
            v_s_proc_status := 4;
            lib_proc.add ( 'ERRO! VERIFIQUE O LOG!' );
            lib_proc.close;
            RETURN mproc_id;
        END IF;

        dbg_line_error := $$plsql_line;

        v_dat_apuracao :=
            LAST_DAY ( TO_DATE (    '01'
                                 || TO_CHAR ( p_mes
                                            , 'FM00' )
                                 || TO_CHAR ( p_ano
                                            , 'FM0000' )
                               , 'DDMMYYYY' ) );

        dbg_line_error := $$plsql_line;

        CASE p_passo
            WHEN '0A' THEN --LOJAS 0A - CÁLCULO DO ESTORNO DE PRODUTO DETERIORADO (APÓS 16H)
                dbg_line_error := $$plsql_line;
                loga ( 'PASSO: LOJAS 0A - CÁLCULO DO ESTORNO DE PRODUTO DETERIORADO (APÓS 16H)' );
                loga ( ' ' );

                SELECT TO_NUMBER ( TO_CHAR ( SYSDATE
                                           , 'HH24' ) )
                  INTO v_temp1
                  FROM DUAL;

                IF v_temp1 < 16 THEN
                    dbg_line_error := $$plsql_line;
                    loga (
                           'ESTE PASSO CAUSA LENTIDÃO NO PEOPLESOFT, POR ISTO SÓ PODE SER EXECUTADO APÓS AS 16 HORAS'
                    );
                    v_s_proc_status := 4;
                    lib_proc.add ( 'ERRO! VERIFIQUE O LOG!' );
                ELSE
                    dbg_line_error := $$plsql_line;
                    loga ( 'INICIANDO PROCESSAMENTO!' );
                    loga ( 'ATENÇÃO!!! SE ESTE PROCESSO FOR INTERROMPIDO, VOCÊ DEVE ACIONAR O TÉCNICO MASTERSAF!' );

                    FOR c1 IN c_passo_0a ( p_ano
                                         , p_mes ) LOOP
                        dbg_line_error := $$plsql_line;
                        v_temp2 :=
                               'BEGIN MSAFI.DSP_GIA_DETERIORADOS('''
                            || c1.business_unit
                            || ''','''
                            || TO_CHAR ( v_dat_apuracao
                                       , 'YYYYMMDD' )
                            || '''); END;';
                        loga ( 'EXECUTANDO: |' || v_temp2 || ';' );

                        EXECUTE IMMEDIATE v_temp2;
                    END LOOP;

                    dbg_line_error := $$plsql_line;
                    loga ( 'FIM DO PROCESSO!' );
                    v_proc_status := 2;
                END IF;
            WHEN '0B' THEN --LOJAS 0B - RELATÓRIO DO ESTORNO DE PRODUTO DETERIORADO
                dbg_line_error := $$plsql_line;
                loga ( 'PASSO: LOJAS 0B - RELATÓRIO DO ESTORNO DE PRODUTO DETERIORADO' );
                loga ( ' ' );
                loga ( 'IMPRIMINDO RELATÓRIO' );
                lib_proc.add ( ' LOJA | DEP  | DATA APUR | BASE ICMS |  VLR ICMS  ' );
                lib_proc.add ( '------|------|-----------|-----------|----------- ' );
                --                             VD004| VD901|12/12/2012 |12345678,01|12345678,01

                dbg_line_error := $$plsql_line;

                FOR c1 IN c_passo_0b ( v_dat_apuracao ) LOOP
                    dbg_line_error := $$plsql_line;
                    v_temp2 :=
                        NVL ( LPAD ( c1.loja
                                   , 6
                                   , ' ' )
                            , '      ' );
                    v_temp2 :=
                           v_temp2
                        || '|'
                        || NVL ( LPAD ( c1.dep
                                      , 6
                                      , ' ' )
                               , '      ' );
                    v_temp2 :=
                           v_temp2
                        || '|'
                        || NVL ( LPAD ( TO_CHAR ( c1.proc_date
                                                , 'DD/MM/YYYY' )
                                      , 11
                                      , ' ' )
                               , '           ' );
                    v_temp2 :=
                           v_temp2
                        || '|'
                        || NVL ( LPAD ( c1.soma__dsp_icmstax_bss
                                      , 11
                                      , ' ' )
                               , '           ' );
                    v_temp2 :=
                           v_temp2
                        || '|'
                        || NVL ( LPAD ( c1.soma__dsp_icmstax_amt
                                      , 11
                                      , ' ' )
                               , '           ' );
                    lib_proc.add ( v_temp2 );
                END LOOP;

                dbg_line_error := $$plsql_line;

                lib_proc.add ( ' ' );
                loga ( ' ' );
                loga ( 'FIM' );
                v_proc_status := 2;
            WHEN '01' THEN --LOJAS 1 - CARGA DE ESTORNO DE PRODUTO DETERIORADO
                dbg_line_error := $$plsql_line;

                DELETE FROM item_apurac_discr
                      WHERE dat_apuracao = v_dat_apuracao
                        AND cod_tipo_livro = '108'
                        AND val_item_discrim = 0
                        AND cod_oper_apur IN ( '006'
                                             , '002'
                                             , '003' )
                        AND cod_estab IN ( SELECT cod_estab
                                             FROM estabelecimento ea
                                                , estado eb
                                            WHERE ea.ident_estado = eb.ident_estado
                                              AND cod_estado = 'SP'
                                              AND cod_estab <> 'DSP902' );

                dbg_line_error := $$plsql_line;

                ------ ESTORNO DE PRODUTO DETERIORADO
                INSERT INTO item_apurac_discr ( cod_empresa
                                              , cod_estab
                                              , cod_tipo_livro
                                              , dat_apuracao
                                              , cod_oper_apur
                                              , num_discriminacao
                                              , val_item_discrim
                                              , dsc_item_apuracao
                                              , ind_dig_calculado
                                              , ind_est_deb_conv
                                              , cod_ajuste_icms )
                    SELECT   mcod_empresa AS cod_empresa
                           ,    mcod_empresa
                             || REPLACE ( estab
                                        , 'VD'
                                        , '' )
                                 AS cod_estab
                           , '108' AS cod_tipo_livro
                           , proc_date AS dat_apuracao
                           , '003' AS cod_oper_apur
                           , 1 AS num_discriminacao
                           , ABS ( SUM ( dsp_icmstax_amt ) ) AS soma__dsp_icmstax_amt
                           , 'ESTORNO DE PRODUTO DETERIORADO' AS dsc_item_apuracao
                           , 1 AS ind_dig_calculado
                           , 'N' AS ind_est_deb_conv
                           , 'SP010301' AS cod_ajuste_icms
                        FROM msafi.dsp_est_gia_tmp
                       WHERE proc_date = LAST_DAY ( v_dat_apuracao )
                         AND    mcod_empresa
                             || REPLACE ( estab
                                        , 'VD'
                                        , '' ) = ANY (SELECT cod_estab
                                                        FROM estabelecimento ea
                                                           , estado eb
                                                       WHERE ea.ident_estado = eb.ident_estado
                                                         AND cod_estado = 'SP'
                                                         AND cod_estab <> 'DSP902')
                    GROUP BY REPLACE ( estab
                                     , 'VD'
                                     , '' )
                           , proc_date--ORDER BY PROC_DATE DESC, ESTAB
                                      ;

                dbg_line_error := $$plsql_line;
                v_proc_status := 2;
            WHEN '02' THEN --UNION SELECT 2,''LOJAS 2 - LIMPAR TRANSF DO SALDO DEVEDOR - ART.98 E 99 RICMS/SP'' FROM DUAL
                ---------SO RODAR ESTES APÓS A GERAÇÃO DA APURAÇÃO

                dbg_line_error := $$plsql_line;

                DELETE FROM item_apurac_discr
                      WHERE dat_apuracao = v_dat_apuracao
                        AND cod_tipo_livro = '108'
                        AND val_item_discrim = 0
                        --AND COD_OPER_APUR IN ('006','002')
                        AND cod_oper_apur = '006'
                        AND cod_estab IN ( SELECT cod_estab
                                             FROM estabelecimento ea
                                                , estado eb
                                            WHERE ea.ident_estado = eb.ident_estado
                                              AND cod_estado = 'SP'
                                              AND cod_estab <> 'DSP902' );

                dbg_line_error := $$plsql_line;

                DELETE FROM item_apurac_discr
                      WHERE dat_apuracao = v_dat_apuracao
                        AND cod_tipo_livro = '108'
                        --AND COD_OPER_APUR IN ('006','002')
                        AND cod_oper_apur = '006'
                        AND dsc_item_apuracao = ANY ('TRANSFERENCIA DO SALDO DEVEDOR - ART.98 E 99 - RICMS/SP')
                        --                            ,'TRANSFERENCIA DO SALDO CREDOR - ART.98 E 99 - RICMS/SP')
                        AND cod_estab IN ( SELECT cod_estab
                                             FROM estabelecimento ea
                                                , estado eb
                                            WHERE ea.ident_estado = eb.ident_estado
                                              AND cod_estado = 'SP'
                                              AND cod_estab <> 'DSP902' );

                dbg_line_error := $$plsql_line;
                v_proc_status := 2;
            WHEN '03' THEN --UNION SELECT 3,''LOJAS 3 - INSERT TRANSF DO SALDO DEVEDOR - ART.98 E 99 RICMS/SP'' FROM DUAL
                --TRANSFERENCIA DO SALDO DEVEDOR OU CREDOR - ART.98 E 99 - RICMS/SP
                dbg_line_error := $$plsql_line;

                INSERT INTO item_apurac_discr ( cod_empresa
                                              , cod_estab
                                              , cod_tipo_livro
                                              , dat_apuracao
                                              , cod_oper_apur
                                              , num_discriminacao
                                              , val_item_discrim
                                              , dsc_item_apuracao
                                              , ind_dig_calculado
                                              , ind_est_deb_conv
                                              , cod_amparo_legal
                                              , cod_ajuste_icms )
                    SELECT cod_empresa AS cod_empresa
                         , cod_estab
                         , cod_tipo_livro
                         , dat_apuracao
                         , DECODE ( cod_oper_apur,  '013', '006',  '014', '002' ) AS cod_oper_apur
                         ,   NVL (
                                   ( SELECT MAX ( num_discriminacao )
                                       FROM item_apurac_discr si
                                      WHERE si.cod_empresa = a.cod_empresa
                                        AND si.cod_estab = a.cod_estab
                                        AND si.cod_tipo_livro = a.cod_tipo_livro
                                        AND si.dat_apuracao = a.dat_apuracao
                                        AND si.cod_oper_apur = DECODE ( a.cod_oper_apur,  '013', '006',  '014', '002' ) )
                                 , 0
                             )
                           + 1
                               AS num_discriminacao
                         --       ,SUM(AUXN5)   AS SOMA__ICMSTAX_BRL_BSS
                         --       ,SUM(AUXN6)   AS SOMA__ICMSTAX_BRL_AMT
                         --       ,SUM(AUXN8)   AS SOMA__DSP_ICMSTAX_BSS
                         , ABS ( val_apuracao ) AS soma__dsp_icmstax_amt
                         , DECODE ( cod_oper_apur
                                  , '013', 'TRANSFERENCIA DO SALDO DEVEDOR - ART.98 E 99 - RICMS/SP'
                                  , '014', 'TRANSFERENCIA DO SALDO CREDOR - ART.98 E 99 - RICMS/SP' )
                               AS dsc_item_apuracao
                         , 1 AS ind_dig_calculado
                         , 'N' AS ind_est_deb_conv
                         , DECODE ( cod_oper_apur,  '013', '000729',  '014', '000218' ) AS cod_amparo_legal
                         , DECODE ( cod_oper_apur,  '013', 'SP020729',  '014', 'SP009999' ) AS cod_ajuste_icms
                      --*/
                      --SELECT *
                      FROM item_apurac_calc a
                     WHERE cod_tipo_livro = '108'
                       --AND   COD_OPER_APUR IN ('013','014')
                       AND cod_oper_apur = '013'
                       AND dat_apuracao = v_dat_apuracao
                       AND val_apuracao <> 0
                       AND cod_estab IN ( SELECT cod_estab
                                            FROM estabelecimento ea
                                               , estado eb
                                           WHERE ea.ident_estado = eb.ident_estado
                                             AND cod_estado = 'SP'
                                             AND cod_estab <> 'DSP902' )
                       AND NOT EXISTS
                               (SELECT 1
                                  FROM item_apurac_discr b
                                 WHERE b.cod_empresa = a.cod_empresa
                                   AND b.cod_estab = a.cod_estab
                                   AND b.cod_tipo_livro = '108'
                                   AND b.dat_apuracao = a.dat_apuracao
                                   --AND   B.COD_OPER_APUR = DECODE(A.COD_OPER_APUR,'013','006','014','002')
                                   AND b.cod_oper_apur = DECODE ( a.cod_oper_apur, '013', '006' )
                                   AND b.dsc_item_apuracao =
                                           DECODE ( a.cod_oper_apur
                                                  , '013', 'TRANSFERENCIA DO SALDO DEVEDOR - ART.98 E 99 - RICMS/SP'--                                                  ,'014','TRANSFERENCIA DO SALDO CREDOR - ART.98 E 99 - RICMS/SP'
                                                                                                                     ));

                dbg_line_error := $$plsql_line;

                UPDATE item_apurac_discr
                   SET cod_amparo_legal = '000301'
                 WHERE cod_empresa = 'DSP'
                   AND cod_estab <> 'DSP902'
                   AND dat_apuracao = v_dat_apuracao
                   AND UPPER ( dsc_item_apuracao ) LIKE '%ESTORNO DE PRODUTO DETERIORADO%'
                   AND cod_oper_apur IN ( '003' ) --- PRODUTO DETERIORADO
                   AND val_item_discrim <> 0;

                dbg_line_error := $$plsql_line;

                UPDATE item_apurac_discr
                   SET cod_amparo_legal = '000218'
                 WHERE cod_empresa = 'DSP'
                   AND cod_estab <> 'DSP902'
                   AND dat_apuracao = v_dat_apuracao
                   AND cod_oper_apur IN ( '007' ) --- SALDO CREDOR
                   AND val_item_discrim <> 0;

                dbg_line_error := $$plsql_line;
                v_proc_status := 2;
            WHEN '04' THEN --UNION SELECT 4,''LOJAS 4 - REGISTRO 25'' FROM DUAL
                ---------ESTE PROXIMO SO RODA APÓS A GERAÇÃO DO REGISTRO 20
                dbg_line_error := $$plsql_line;

                DELETE FROM est_sp_gia_reg25 a
                      WHERE cod_empresa = 'DSP'
                        AND cod_estab <> 'DSP902'
                        AND dat_apuracao = v_dat_apuracao
                        AND cod_amparo_legal IN ( '000729'
                                                , '000218' )
                        AND EXISTS
                                (SELECT 1
                                   FROM est_sp_gia_reg20 b
                                  WHERE b.cod_empresa = a.cod_empresa
                                    AND b.cod_estab = a.cod_estab
                                    AND b.dat_apuracao = a.dat_apuracao
                                    AND b.cod_amparo_legal = a.cod_amparo_legal
                                    AND b.sequencia = a.sequencia)
                        AND vlr_operacao = 0;

                dbg_line_error := $$plsql_line;
                loga ( 'DELETE FROM EST_SP_GIA_REG25 4-A [' || SQL%ROWCOUNT || ']' );

                INSERT INTO est_sp_gia_reg25 ( cod_empresa
                                             , cod_estab
                                             , dat_apuracao
                                             , cod_amparo_legal
                                             , sequencia
                                             , grupo_fis_jur
                                             , ind_fis_jur
                                             , cod_fis_jur
                                             , vlr_operacao
                                             , usuario
                                             , num_processo
                                             , ind_dig_calc )
                    SELECT 'DSP'
                         , cod_estab
                         , dat_apuracao
                         , cod_amparo_legal
                         , sequencia
                         , '1900'
                         , '3'
                         , 'DSP902'
                         , vlr_operacao
                         , musuario || '-AUTOGIA'
                         , NULL
                         , '1'
                      FROM est_sp_gia_reg20 a
                     WHERE cod_empresa = 'DSP'
                       AND cod_estab <> 'DSP902'
                       AND dat_apuracao = v_dat_apuracao
                       AND cod_amparo_legal IN ( '000729'
                                               , '000218' )
                       AND NOT EXISTS
                               (SELECT 1
                                  FROM est_sp_gia_reg25 b
                                 WHERE b.cod_empresa = a.cod_empresa
                                   AND b.cod_estab = a.cod_estab
                                   AND b.dat_apuracao = a.dat_apuracao
                                   AND b.cod_amparo_legal = a.cod_amparo_legal
                                   AND b.sequencia = a.sequencia);

                dbg_line_error := $$plsql_line;
                loga ( 'INSERT INTO EST_SP_GIA_REG25 4-B [' || SQL%ROWCOUNT || ']' );
                v_proc_status := 2;
            WHEN '05' THEN --UNION SELECT 5,''DEPÓSITO 902 -  REGISTRO 25'' FROM DUAL
                --LFME-0059-2 THIAGO / ADEVAÍ PREENCHIMENTO DO REGISTRO 25 DA GIA DO DEPÓSITO DSP902  15/MAI  15/MAI  SCRIPT INSERT SUPORTE
                -- REGISTRO 25 DA GIA PARA DEPOSITO DSP902
                dbg_line_error := $$plsql_line;
                v_info := 'CHECAR OPÇÃO AMPARO/TEXTO/OCORRÊNCIA - REG. TIPO 20 -> EST_SP_GIA_REG20';

                INSERT INTO est_sp_gia_reg25 ( cod_empresa
                                             , cod_estab
                                             , dat_apuracao
                                             , cod_amparo_legal
                                             , sequencia
                                             , grupo_fis_jur
                                             , ind_fis_jur
                                             , cod_fis_jur
                                             , vlr_operacao
                                             , usuario
                                             , num_processo
                                             , ind_dig_calc )
                    SELECT a.cod_empresa
                         , 'DSP902'
                         , a.dat_apuracao
                         , '000219'
                         , 1
                         , '1900'
                         , 3
                         , a.cod_estab
                         , val_item_discrim
                         , musuario || '-AUTOGIA'
                         , NULL
                         , 1
                      FROM item_apurac_discr a
                         , estabelecimento b
                     WHERE dat_apuracao = v_dat_apuracao
                       AND a.cod_estab <> 'DSP902'
                       AND cod_oper_apur = '006'
                       AND dsc_item_apuracao = 'TRANSFERENCIA DO SALDO DEVEDOR - ART.98 E 99 - RICMS/SP'
                       AND a.cod_estab = b.cod_estab
                       AND b.ident_estado = '76'
                       AND val_item_discrim <> 0;

                dbg_line_error := $$plsql_line;
                loga ( 'INSERT INTO EST_SP_GIA_REG25 5-A [' || SQL%ROWCOUNT || ']' );

                INSERT INTO est_sp_gia_reg25 ( cod_empresa
                                             , cod_estab
                                             , dat_apuracao
                                             , cod_amparo_legal
                                             , sequencia
                                             , grupo_fis_jur
                                             , ind_fis_jur
                                             , cod_fis_jur
                                             , vlr_operacao
                                             , usuario
                                             , num_processo
                                             , ind_dig_calc )
                    SELECT   a.cod_empresa
                           , 'DSP902'
                           , a.dat_apuracao
                           , '000730'
                           , 1
                           , '1900'
                           , 3
                           , a.cod_estab
                           , SUM ( val_item_discrim )
                           , musuario || '-AUTOGIA'
                           , NULL
                           , 1
                        FROM item_apurac_discr a
                           , estabelecimento b
                       WHERE dat_apuracao = v_dat_apuracao
                         AND a.cod_estab <> 'DSP902'
                         --AND   COD_OPER_APUR IN ('002','003')
                         AND cod_oper_apur = '002'
                         AND dsc_item_apuracao = 'TRANSFERENCIA DO SALDO CREDOR - ART.98 E 99 - RICMS/SP'
                         AND a.cod_estab = b.cod_estab
                         AND b.ident_estado = '76'
                    GROUP BY a.cod_empresa
                           , a.dat_apuracao
                           , a.cod_estab
                      HAVING SUM ( val_item_discrim ) <> 0;

                dbg_line_error := $$plsql_line;
                loga ( 'INSERT INTO EST_SP_GIA_REG25 5-B [' || SQL%ROWCOUNT || ']' );

                v_proc_status := 2;
            WHEN '06' THEN --UNION SELECT 6,''LOJAS 5 - PREENCHIMENTO DADOS INICIAIS GIA-BA'' FROM DUAL
                dbg_line_error := $$plsql_line;
                v_dat_apuracao :=
                    LAST_DAY ( TO_DATE (    '01'
                                         || TO_CHAR ( p_mes
                                                    , 'FM00' )
                                         || TO_CHAR ( p_ano
                                                    , 'FM0000' )
                                       , 'DDMMYYYY' ) );
                loga ( 'INICIO EST_BA_DMA_GERAL [' || v_dat_apuracao || ']' );

                FOR c1 IN c_passo_6 LOOP
                    v_existe := 'N';

                    --- CHECAR DADOS
                    BEGIN
                        SELECT DISTINCT 'Y'
                          INTO v_existe
                          FROM msaf.est_ba_dma_geral
                         WHERE cod_empresa = 'DSP'
                           AND cod_estab = c1.cod_estab
                           AND mes_ref = TO_CHAR ( p_mes
                                                 , 'FM00' )
                           AND ano_ref = TO_CHAR ( p_ano
                                                 , 'FM0000' );
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            v_existe := 'N';
                    END;

                    ---
                    IF v_existe = 'Y' THEN
                        loga ( '>> DADOS JA INSERIDOS [' || c1.cod_estab || ' - ' || v_dat_apuracao || ']' );
                    ELSE
                        --- INSERIR DADOS
                        INSERT INTO msaf.est_ba_dma_geral
                             VALUES ( 'DSP'
                                    , c1.cod_estab
                                    , TO_CHAR ( p_mes
                                              , 'FM00' )
                                    , TO_CHAR ( p_ano
                                              , 'FM0000' )
                                    , 'N'
                                    , 'N'
                                    , 'N'
                                    , 'N'
                                    , v_dat_apuracao
                                    , 27400
                                    , 4771701
                                    , '00'
                                    , 'N'
                                    , 0
                                    , 0
                                    , 0.00
                                    , 'I'
                                    , 'DROGARIA SAO PAULO S/A'
                                    , 'AUTO.GIA'
                                    , 0
                                    , '1'
                                    , NULL
                                    , NULL
                                    , p_ano
                                    , NULL );

                        loga ( '>> INSERT EST_BA_DMA_GERAL [' || c1.cod_estab || ' - ' || v_dat_apuracao || ']' );
                        COMMIT;
                    END IF;
                END LOOP;

                v_proc_status := 2;
            WHEN '07' THEN --UNION SELECT ''07'',''LOJAS 6 - AJUSTE VALOR OUTRAS DAPI-MG'' FROM DUAL
                dbg_line_error := $$plsql_line;
                v_dat_apuracao :=
                    LAST_DAY ( TO_DATE (    '01'
                                         || TO_CHAR ( p_mes
                                                    , 'FM00' )
                                         || TO_CHAR ( p_ano
                                                    , 'FM0000' )
                                       , 'DDMMYYYY' ) );
                loga ( 'INICIO DAPI-MG AJUSTE [' || v_dat_apuracao || ']' );

                --- PASSO 1
                UPDATE msaf.est_mg_gia_lin10
                   SET vlr_outros = vlr_outros + vlr_tributo_icmss
                     , vlr_tributo_icmss = 0
                     , vlr_icms_ndestac = 0
                 WHERE cod_estab IN ( SELECT cod_estab
                                        FROM msaf.estabelecimento est
                                           , msaf.estado uf
                                       WHERE est.ident_estado = uf.ident_estado
                                         AND uf.cod_estado = 'MG' )
                   AND mes_ref = TO_CHAR ( p_mes
                                         , 'FM00' )
                   AND ano_ref = TO_CHAR ( p_ano
                                         , 'FM0000' )
                   AND ( vlr_tributo_icmss > 0
                     OR vlr_icms_ndestac > 0 );

                ln_upd := SQL%ROWCOUNT;
                loga ( '>> QUANTIDADE DE LINHAS ATUALIZADAS PASSO 1 [' || ln_upd || ']' );
                COMMIT;

                --- PASSO 2
                UPDATE msaf.est_mg_gia_lin10
                   SET vlr_outros =
                             vlr_tot_nota
                           - vlr_base_icms_1
                           - vlr_icms_ndestac
                           - vlr_base_icms_2
                           - vlr_base_icms_3
                           - vlr_base_icms_ntrib
                           - vlr_parc_calc_reduc
                           - vlr_diferido
                           - vlr_tributo_icmss
                 WHERE cod_estab IN ( SELECT cod_estab
                                        FROM msaf.estabelecimento est
                                           , msaf.estado uf
                                       WHERE est.ident_estado = uf.ident_estado
                                         AND uf.cod_estado = 'MG' )
                   AND mes_ref = TO_CHAR ( p_mes
                                         , 'FM00' )
                   AND ano_ref = TO_CHAR ( p_ano
                                         , 'FM0000' )
                   AND   vlr_tot_nota
                       - vlr_base_icms_1
                       - vlr_icms_ndestac
                       - vlr_base_icms_2
                       - vlr_base_icms_3
                       - vlr_base_icms_ntrib
                       - vlr_parc_calc_reduc
                       - vlr_diferido
                       - vlr_tributo_icmss
                       - vlr_outros <> 0;

                ln_upd := SQL%ROWCOUNT;
                loga ( '>> QUANTIDADE DE LINHAS ATUALIZADAS PASSO 2 [' || ln_upd || ']' );
                COMMIT;

                v_proc_status := 2; -- SUCESSO
            -------------------------------------------------------------------------------------------------------------
            WHEN '08' THEN --UNION SELECT ''08'',''LOJAS 7 - REGISTRO 0200 GIA-RJ'' FROM DUAL
                dbg_line_error := $$plsql_line;

                v_dat_apuracao :=
                    LAST_DAY ( TO_DATE (    '01'
                                         || TO_CHAR ( p_mes
                                                    , 'FM00' )
                                         || TO_CHAR ( p_ano
                                                    , 'FM0000' )
                                       , 'DDMMYYYY' ) );
                loga ( 'INICIO EST_RJ_GIA_R140_2 [' || v_dat_apuracao || ']' );

                DELETE msaf.est_rj_gia_r140_2
                 WHERE cod_empresa = mcod_empresa
                   AND cod_estab IN ( SELECT cod_estab
                                        FROM msaf.estabelecimento est
                                           , msaf.estado uf
                                       WHERE est.ident_estado = uf.ident_estado
                                         AND uf.cod_estado = 'RJ' )
                   AND mes_apuracao = p_mes
                   AND ano_apuracao = p_ano
                   AND usuario = 'CARGA.MANUAL'
                   AND num_processo = '99999'
                   AND num_sequencial = '0'
                   AND cod_amparo_legal IN ( 'O350001'
                                           , 'O350002'
                                           , 'O350005'
                                           , ' ' );

                ln_upd := SQL%ROWCOUNT;
                loga ( 'LINHAS EXCLUIDAS [' || ln_upd || ']' );
                COMMIT;

                INSERT INTO msaf.est_rj_gia_r140_2
                    ( SELECT   a.cod_empresa
                             , a.cod_estab
                             , TO_NUMBER ( TO_CHAR ( a.data_fiscal
                                                   , 'MM' ) )
                             , TO_NUMBER ( TO_CHAR ( a.data_fiscal
                                                   , 'YYYY' ) )
                             , CASE
                                   WHEN c.cod_cfo = '2556' THEN 'O350001'
                                   WHEN c.cod_cfo = '2551' THEN 'O350002'
                                   WHEN c.cod_cfo = '2353' THEN 'O350005'
                                   ELSE ' '
                               END
                             , '@'
                             , '0200'
                             , '@'
                             , '@'
                             , '@'
                             , '@'
                             , '@'
                             , '@'
                             , SUM ( vlr_contab_item * 6 ) / 100
                             , '1'
                             , '99999'
                             , 'CARGA.MANUAL'
                             , '0'
                          FROM msaf.dwt_docto_fiscal a
                             , msaf.dwt_itens_merc b
                             , msaf.x2012_cod_fiscal c
                             , msafi.dsp_estabelecimento d
                         WHERE a.ident_docto_fiscal = b.ident_docto_fiscal
                           AND b.ident_cfo = c.ident_cfo
                           AND a.cod_empresa = mcod_empresa
                           AND a.cod_empresa = d.cod_empresa
                           AND a.cod_estab = d.cod_estab
                           AND d.tipo = 'L'
                           AND a.cod_estab IN ( SELECT cod_estab
                                                  FROM msaf.estabelecimento est
                                                     , msaf.estado uf
                                                 WHERE est.ident_estado = uf.ident_estado
                                                   AND uf.cod_estado = 'RJ' )
                           AND a.data_fiscal BETWEEN TO_DATE (    '01'
                                                               || TO_CHAR ( p_mes
                                                                          , 'FM00' )
                                                               || TO_CHAR ( p_ano
                                                                          , 'FM0000' )
                                                             , 'DDMMYYYY' )
                                                 AND v_dat_apuracao
                           AND c.cod_cfo IN ( '2556'
                                            , '2551'
                                            , '2353' )
                      GROUP BY a.cod_empresa
                             , a.cod_estab
                             , TO_NUMBER ( TO_CHAR ( a.data_fiscal
                                                   , 'MM' ) )
                             , TO_NUMBER ( TO_CHAR ( a.data_fiscal
                                                   , 'YYYY' ) )
                             , CASE
                                   WHEN c.cod_cfo = '2556' THEN 'O350001'
                                   WHEN c.cod_cfo = '2551' THEN 'O350002'
                                   WHEN c.cod_cfo = '2353' THEN 'O350005'
                                   ELSE ' '
                               END );

                ln_upd := SQL%ROWCOUNT;
                loga ( 'LINHAS ATUALIZADAS [' || ln_upd || ']' );
                COMMIT;

                DELETE msaf.est_rj_gia_r140_2
                 WHERE cod_empresa = mcod_empresa
                   AND cod_estab IN ( SELECT cod_estab
                                        FROM msaf.estabelecimento est
                                           , msaf.estado uf
                                       WHERE est.ident_estado = uf.ident_estado
                                         AND uf.cod_estado = 'RJ' )
                   AND mes_apuracao = p_mes
                   AND ano_apuracao = p_ano
                   AND usuario = 'CARGA.MANUAL'
                   AND num_processo = '99999'
                   AND num_sequencial = '0'
                   AND cod_amparo_legal = 'O350010';

                ln_upd := SQL%ROWCOUNT;
                loga ( 'LINHAS EXCLUIDAS [' || ln_upd || ']' );
                COMMIT;

                ---INSERT NO AMPARO TOTALIZADOR
                INSERT INTO msaf.est_rj_gia_r140_2
                    ( SELECT   a.cod_empresa
                             , a.cod_estab
                             , TO_NUMBER ( TO_CHAR ( a.data_fiscal
                                                   , 'MM' ) )
                             , TO_NUMBER ( TO_CHAR ( a.data_fiscal
                                                   , 'YYYY' ) )
                             , 'O350010'
                             , '@'
                             , '0200'
                             , '@'
                             , '@'
                             , '@'
                             , '@'
                             , '@'
                             , '@'
                             , SUM ( vlr_contab_item * 2 ) / 100
                             , '1'
                             , '99999'
                             , 'CARGA.MANUAL'
                             , '0'
                          FROM msaf.dwt_docto_fiscal a
                             , msaf.dwt_itens_merc b
                             , msaf.x2012_cod_fiscal c
                             , msafi.dsp_estabelecimento d
                         WHERE a.ident_docto_fiscal = b.ident_docto_fiscal
                           AND b.ident_cfo = c.ident_cfo
                           AND a.cod_empresa = mcod_empresa
                           AND a.cod_empresa = d.cod_empresa
                           AND a.cod_estab = d.cod_estab
                           AND d.tipo = 'L'
                           AND a.cod_estab IN ( SELECT cod_estab
                                                  FROM msaf.estabelecimento est
                                                     , msaf.estado uf
                                                 WHERE est.ident_estado = uf.ident_estado
                                                   AND uf.cod_estado = 'RJ' )
                           AND a.data_fiscal BETWEEN TO_DATE (    '01'
                                                               || TO_CHAR ( p_mes
                                                                          , 'FM00' )
                                                               || TO_CHAR ( p_ano
                                                                          , 'FM0000' )
                                                             , 'DDMMYYYY' )
                                                 AND v_dat_apuracao
                           AND c.cod_cfo IN ( '2556'
                                            , '2551'
                                            , '2353' )
                      GROUP BY a.cod_empresa
                             , a.cod_estab
                             , TO_NUMBER ( TO_CHAR ( a.data_fiscal
                                                   , 'MM' ) )
                             , TO_NUMBER ( TO_CHAR ( a.data_fiscal
                                                   , 'YYYY' ) ) );

                ln_upd := SQL%ROWCOUNT;
                loga ( 'LINHAS ATUALIZADAS TOTALIZADOR [' || ln_upd || ']' );
                COMMIT;

                v_proc_status := 2;
            -------------------------------------------------------------------------------------------------------------
            --FIN4405 - GUILHERME SILVA -----INICIO--------
            WHEN '09' THEN --UNION SELECT ''09'',''LOJAS 8 - ESTORNO DE CESTA BÁSICA RJ'' FROM DUAL
                dbg_line_error := $$plsql_line;
                p_data2 :=
                    LAST_DAY ( TO_DATE (    '01'
                                         || TO_CHAR ( p_mes
                                                    , 'FM00' )
                                         || TO_CHAR ( p_ano
                                                    , 'FM0000' )
                                       , 'DDMMYYYY' ) );
                p_data1 :=
                    TO_DATE (    '01'
                              || TO_CHAR ( p_mes
                                         , 'FM00' )
                              || TO_CHAR ( p_ano
                                         , 'FM0000' )
                            , 'DDMMYYYY' );

                loga ( '014. ESTORNO DE CREDITO/DEBITO CESTA BASICA (S/S/N/N)' );
                loga ( ' ' );
                loga (    'DATA INICIAL     (SIM, OBRIGATÓRIO): '
                       || TO_CHAR ( p_data1
                                  , 'DD/MM/YYYY' ) );
                loga (    'DATA FINAL       (SIM, OBRIGATÓRIO): '
                       || TO_CHAR ( p_data2
                                  , 'DD/MM/YYYY' ) );
                loga ( 'PARAMETRO 1      (NÃO UTILIZADO)' );
                loga ( 'ESTABELECIMENTOS (NÃO UTILIZADO)' );
                loga ( ' ' );

                loga ( 'EXECUTANDO PROCESSO' );

                loga ( 'EXCLUINDO VALORES EXISTENTES NO LIVRO' );
                /* -- R001
                DELETE FROM MSAF.ITEM_APURAC_DISCR IAD
                WHERE IAD.COD_EMPRESA = MCOD_EMPRESA
                  AND EXISTS (SELECT 'Y'
                              FROM MSAFI.DSP_ESTABELECIMENTO EST1
                              WHERE EST1.COD_EMPRESA = IAD.COD_EMPRESA
                                AND EST1.COD_ESTAB   = IAD.COD_ESTAB
                                AND EST1.TIPO        = 'L')
                  AND IAD.DAT_APURACAO BETWEEN P_DATA1 AND P_DATA2
                  AND IAD.COD_OPER_APUR IN ('003','007')
                  AND (IAD.VAL_ITEM_DISCRIM = 0
                   OR  IAD.DSC_ITEM_APURACAO = 'VR. REF. PROD. CESTA BASICA DECRETO 32161/02')
                  ---AND NVL(IAD.COD_AMPARO_LEGAL,'N030005') = 'N030005'
                  AND (IAD.COD_EMPRESA,IAD.COD_ESTAB,IAD.COD_TIPO_LIVRO,IAD.DAT_APURACAO,IAD.COD_OPER_APUR) IN (
                      SELECT DDF.COD_EMPRESA,DDF.COD_ESTAB,'108',LAST_DAY(P_DATA2),DECODE(DDF.MOVTO_E_S,'9','007','003')
                      FROM MSAF.DWT_DOCTO_FISCAL DDF, MSAF.DWT_ITENS_MERC DIM
                      WHERE DDF.IDENT_DOCTO_FISCAL = DIM.IDENT_DOCTO_FISCAL
                        AND DDF.COD_EMPRESA = MCOD_EMPRESA
                        AND EXISTS (SELECT 'Y'
                                    FROM MSAFI.DSP_ESTABELECIMENTO EST2
                                    WHERE EST2.COD_EMPRESA = DDF.COD_EMPRESA
                                      AND EST2.COD_ESTAB   = DDF.COD_ESTAB
                                      AND EST2.TIPO        = 'L')
                        AND DDF.DATA_FISCAL BETWEEN P_DATA1 AND P_DATA2
                        AND DIM.ALIQ_TRIBUTO_ICMS = '7'
                      GROUP BY DDF.COD_EMPRESA,DDF.COD_ESTAB,DDF.MOVTO_E_S
                      )
                ;*/
                limpa_item_apurac ( p_data1
                                  , p_data2 );

                loga ( 'VALORES EXCLUÍDOS DO LIVRO: [' || SQL%ROWCOUNT || ']' );

                loga ( 'INSERINDO VALORES NO LIVRO' );

                /*INSERT FIN4405 - CESTA BÁSICA*/
                -- R001
                /*INSERT INTO MSAF.ITEM_APURAC_DISCR
                SELECT DDF.COD_EMPRESA
                      ,DDF.COD_ESTAB
                      ,'108' --- LIVRO DE APURACAO
                      ,P_DATA2
                      ,DECODE(DDF.MOVTO_E_S,'9','007','003')
                      ,NVL((SELECT MAX(NUM_DISCRIMINACAO)+1
                            FROM MSAF.ITEM_APURAC_DISCR SIAD
                            WHERE SIAD.COD_EMPRESA    = DDF.COD_EMPRESA
                              AND SIAD.COD_ESTAB      = DDF.COD_ESTAB
                              AND SIAD.COD_TIPO_LIVRO = '108'
                              AND SIAD.DAT_APURACAO   = P_DATA2
                              AND SIAD.COD_OPER_APUR  = DECODE(DDF.MOVTO_E_S,'9','007','003')
                          ),1)
                      ,SUM(DIM.VLR_TRIBUTO_ICMS)
                      ,NULL
                      ,'VR. REF. PROD. CESTA BASICA DECRETO 32161/02'
                      ,'1' ---IND_DIG_CALCULADO
                      ,NULL
                      ,DECODE(DECODE(DDF.MOVTO_E_S,'9','007','003'),'003','N030005','N089999')
                      ,DECODE(DECODE(DDF.MOVTO_E_S,'9','007','003'),'003','','01')
                      ,NULL
                      ,NULL
                      ,NULL
                      ,NULL
                      ,NULL
                      ,NULL
                      ,NULL
                      ,NULL
                      ,NULL
                      ,DECODE(DDF.MOVTO_E_S,'9','RJ039999','RJ010005')
                      ,NULL
                      ,NULL
                      ,NULL
                      ,'N'
                      ,NULL
                      ,NULL
                      ,NULL
                      ,NULL
                      ,NULL
                      ,NULL
                FROM MSAF.DWT_DOCTO_FISCAL DDF,
                     MSAF.DWT_ITENS_MERC DIM
                WHERE DDF.IDENT_DOCTO_FISCAL = DIM.IDENT_DOCTO_FISCAL
                  AND DDF.COD_EMPRESA        = MCOD_EMPRESA
                  AND EXISTS (SELECT 'Y'
                              FROM MSAFI.DSP_ESTABELECIMENTO EST1
                              WHERE EST1.COD_EMPRESA = DDF.COD_EMPRESA
                                AND EST1.COD_ESTAB   = DDF.COD_ESTAB
                                AND EST1.TIPO        = 'L')
                  AND DDF.COD_ESTAB IN (SELECT COD_ESTAB FROM MSAF.ESTABELECIMENTO EST, MSAF.ESTADO UF
                                                         WHERE EST.IDENT_ESTADO = UF.IDENT_ESTADO
                                                           AND UF.COD_ESTADO    = 'RJ')
                  AND DDF.DATA_FISCAL BETWEEN P_DATA1 AND P_DATA2
                  AND DIM.ALIQ_TRIBUTO_ICMS = '7'
                  AND NOT EXISTS (SELECT 1
                                  FROM MSAF.ITEM_APURAC_DISCR SIAD
                                  WHERE SIAD.COD_EMPRESA       = DDF.COD_EMPRESA
                                    AND SIAD.COD_ESTAB         = DDF.COD_ESTAB
                                    AND SIAD.COD_TIPO_LIVRO    = '108'
                                    AND SIAD.DAT_APURACAO      = P_DATA2
                                    AND SIAD.COD_OPER_APUR     = DECODE(DDF.MOVTO_E_S,'9','007','003')
                                    AND SIAD.COD_AMPARO_LEGAL  = 'N030005'
                                    AND SIAD.IND_DIG_CALCULADO = '1'
                                    AND SIAD.DSC_ITEM_APURACAO ='VR. REF. PROD. CESTA BASICA DECRETO 32161/02'
                                 )
                GROUP BY DDF.COD_EMPRESA,DDF.COD_ESTAB,DDF.MOVTO_E_S
                ;*/

                loga (    'VALORES INSERIDOS NO LIVRO: ['
                       || credito_cesta_basica ( mproc_id
                                               , p_data1
                                               , p_data2 )
                       || ']' );
                -- R001 <<

                --LOGA('VALORES INSERIDOS NO LIVRO: ['|| SQL%ROWCOUNT ||']');
                COMMIT;

                v_proc_status := 2; --SUCESSO
                loga ( 'FIM DO SCRIPT, SUCESSO' );
            -------------------------------------------------------------------------------------------------------------
            WHEN '10' THEN --UNION SELECT ''10'',''LOJAS 9 - (SP) NOTAS FISCAIS DEVOLUÇÃO COM FINALIDADE IST'' FROM DUAL
                DECLARE
                    v_class CHAR ( 1 ) := 'B';
                BEGIN
                    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS='',.''';

                    -- CRIA RELATORIO ITENS_CESTA_BASICA
                    lib_proc.add_tipo ( mproc_id
                                      , 4
                                      ,    'DEV_FIN_IST_'
                                        || TO_CHAR ( p_periodo
                                                   , 'YYYYMM' )
                                        || '.XLS'
                                      , 2 );

                    lib_proc.add ( dsp_planilha.header
                                 , ptipo => 4 );
                    lib_proc.add ( dsp_planilha.tabela_inicio
                                 , ptipo => 4 );
                    lib_proc.add ( dsp_planilha.linha (
                                                           dsp_planilha.campo ( 'COD_ESTAB' )
                                                        || dsp_planilha.campo ( 'PERIODO' )
                                                        || dsp_planilha.campo ( 'CFOP' )
                                                        || dsp_planilha.campo ( 'FIN' )
                                                        || dsp_planilha.campo ( 'CST' )
                                                        || dsp_planilha.campo ( 'VALOR_ICMS' )
                                                        || dsp_planilha.campo ( 'VALOR_ICMSS' )
                                                      , p_class => 'H'
                                   )
                                 , ptipo => 4 );

                    loga ( 'EXECUTANDO PROCESSO' );

                    loga ( 'EXCLUINDO VALORES EXISTENTES NO LIVRO' );

                    DELETE FROM msaf.item_apurac_discr a
                          WHERE cod_empresa = mcod_empresa
                            AND cod_tipo_livro = '108'
                            AND dat_apuracao = LAST_DAY ( p_periodo )
                            AND cod_oper_apur = '007'
                            AND dsc_item_apuracao = 'ESTORNO DE DÉBITO REF. DEV. COM ICMS-ST';

                    loga ( 'VALORES EXCLUÍDOS DO LIVRO: [' || SQL%ROWCOUNT || ']' );

                    COMMIT;

                    --LIB_PROC.ADD_LOG(MCOD_EMPRESA||'|'||P_PERIODO,1);
                    v_proc_status := 1;

                    FOR c IN ( SELECT /*+ PARALLEL(12)*/
                                     a  .cod_estab AS cod_estab
                                      , TO_CHAR ( a.data_fiscal
                                                , 'MM/YYYY' )
                                            periodo
                                      , c.cod_cfo AS cfop
                                      , d.cod_natureza_op AS fin
                                      , f.cod_situacao_b AS cst
                                      , SUM ( b.vlr_tributo_icms ) AS valor_icms
                                      , SUM ( b.vlr_tributo_icmss ) AS valor_icmss
                                      , NVL ( ( SELECT 'S'
                                                  FROM msaf.apuracao
                                                 WHERE cod_empresa = a.cod_empresa
                                                   AND cod_estab = a.cod_estab
                                                   AND cod_tipo_livro = '108'
                                                   AND dat_apuracao = LAST_DAY ( p_periodo ) )
                                            , 'N' )
                                            apuracao
                                   FROM msaf.dwt_docto_fiscal a
                                      , msaf.dwt_itens_merc b
                                      , msaf.x2012_cod_fiscal c
                                      , msaf.x2006_natureza_op d
                                      , msafi.dsp_estabelecimento e
                                      , msaf.y2026_sit_trb_uf_b f
                                  WHERE a.ident_docto_fiscal = b.ident_docto_fiscal
                                    AND b.ident_cfo = c.ident_cfo
                                    AND b.ident_natureza_op = d.ident_natureza_op
                                    AND a.cod_empresa = e.cod_empresa
                                    AND a.cod_estab = e.cod_estab
                                    AND b.ident_situacao_b = f.ident_situacao_b
                                    AND a.cod_empresa = mcod_empresa
                                    -- AND A.COD_ESTAB = 'DSP003'
                                    AND e.tipo = 'L'
                                    AND a.data_fiscal BETWEEN p_periodo AND LAST_DAY ( p_periodo )
                                    AND a.movto_e_s = '9'
                                    AND c.cod_cfo IN ( '5209'
                                                     , '6209' )
                                    AND d.cod_natureza_op = 'IST'
                                    AND f.cod_situacao_b = '90'
                                    AND e.cod_estado = 'SP'
                                    AND b.vlr_tributo_icmss > 0
                               GROUP BY a.cod_empresa
                                      , a.cod_estab
                                      , TO_CHAR ( a.data_fiscal
                                                , 'MM/YYYY' )
                                      , c.cod_cfo
                                      , d.cod_natureza_op
                                      , f.cod_situacao_b ) LOOP
                        IF c.apuracao = 'S' THEN
                            lib_proc.add ( dsp_planilha.linha (
                                                                   dsp_planilha.campo ( c.cod_estab )
                                                                || dsp_planilha.campo ( c.periodo )
                                                                || dsp_planilha.campo ( c.cfop )
                                                                || dsp_planilha.campo ( c.fin )
                                                                || dsp_planilha.campo ( c.cst )
                                                                || dsp_planilha.campo ( c.valor_icms )
                                                                || dsp_planilha.campo ( c.valor_icmss )
                                                              , p_class => v_class
                                           )
                                         , ptipo => 4 );

                            IF v_class = 'A' THEN
                                v_class := 'B';
                            ELSE
                                v_class := 'A';
                            END IF;

                            INSERT INTO msaf.item_apurac_discr a ( cod_empresa
                                                                 , cod_estab
                                                                 , cod_tipo_livro
                                                                 , dat_apuracao
                                                                 , cod_oper_apur
                                                                 , num_discriminacao
                                                                 , val_item_discrim
                                                                 , dsc_item_apuracao
                                                                 , ind_dig_calculado
                                                                 , cod_amparo_legal
                                                                 , cod_sub_item_ocorr
                                                                 , cod_ajuste_icms
                                                                 , ind_est_deb_conv )
                                 VALUES ( mcod_empresa
                                        , c.cod_estab
                                        , '108'
                                        , LAST_DAY ( p_periodo )
                                        , '007'
                                        , ( SELECT MAX ( num_discriminacao ) + 1
                                              FROM msaf.item_apurac_discr b
                                             WHERE b.cod_empresa = mcod_empresa
                                               AND b.cod_estab = c.cod_estab
                                               AND b.cod_tipo_livro = '108'
                                               AND b.dat_apuracao = LAST_DAY ( p_periodo )
                                               AND b.cod_oper_apur = '007' )
                                        , c.valor_icms
                                        , 'ESTORNO DE DÉBITO REF. DEV. COM ICMS-ST'
                                        , 1
                                        , '000799'
                                        , '03'
                                        , 'SP030899'
                                        , 'N' );
                        ELSE
                            lib_proc.add ( 'ERRO: APURAÇÃO NÃO LOCALIZADA PARA O ESTABELECIMENTO ' || c.cod_estab );
                        END IF;
                    END LOOP;

                    COMMIT;

                    lib_proc.add ( dsp_planilha.tabela_fim
                                 , ptipo => 4 );
                    v_proc_status := 2;
                END;
            -------------------------------------------------------------------------------------------------------------
            WHEN '11' THEN --UNION SELECT ''11'',''LOJAS 9 - (RJ) NOTAS FISCAIS DEVOLUÇÃO COM FINALIDADE IST'' FROM DUAL
                DECLARE
                    v_class CHAR ( 1 ) := 'B';
                BEGIN
                    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS='',.''';

                    -- CRIA RELATORIO ITENS_CESTA_BASICA
                    lib_proc.add_tipo ( mproc_id
                                      , 4
                                      ,    'DEV_FIN_IST_'
                                        || TO_CHAR ( p_periodo
                                                   , 'YYYYMM' )
                                        || '.XLS'
                                      , 2 );

                    lib_proc.add ( dsp_planilha.header
                                 , ptipo => 4 );
                    lib_proc.add ( dsp_planilha.tabela_inicio
                                 , ptipo => 4 );
                    lib_proc.add ( dsp_planilha.linha (
                                                           dsp_planilha.campo ( 'COD_ESTAB' )
                                                        || dsp_planilha.campo ( 'PERIODO' )
                                                        || dsp_planilha.campo ( 'CFOP' )
                                                        || dsp_planilha.campo ( 'FIN' )
                                                        || dsp_planilha.campo ( 'CST' )
                                                        || dsp_planilha.campo ( 'VALOR_ICMS' )
                                                        || dsp_planilha.campo ( 'VALOR_ICMSS' )
                                                      , p_class => 'H'
                                   )
                                 , ptipo => 4 );

                    loga ( 'EXECUTANDO PROCESSO' );

                    loga ( 'EXCLUINDO VALORES EXISTENTES NO LIVRO' );

                    DELETE FROM msaf.item_apurac_discr a
                          WHERE cod_empresa = mcod_empresa
                            AND cod_tipo_livro = '108'
                            AND dat_apuracao = LAST_DAY ( p_periodo )
                            AND cod_oper_apur = '007'
                            AND dsc_item_apuracao =
                                    'ESTORNO DE DÉBITO CONFORME RESOLUÇÃO 889 SEFAZ/RJ DE 12/05/2015';

                    loga ( 'VALORES EXCLUÍDOS DO LIVRO: [' || SQL%ROWCOUNT || ']' );

                    COMMIT;

                    --LIB_PROC.ADD_LOG(MCOD_EMPRESA||'|'||P_PERIODO,1);
                    v_proc_status := 1;

                    FOR c IN ( SELECT /*+ PARALLEL(12)*/
                                     a  .cod_estab AS cod_estab
                                      , TO_CHAR ( a.data_fiscal
                                                , 'MM/YYYY' )
                                            periodo
                                      , c.cod_cfo AS cfop
                                      , d.cod_natureza_op AS fin
                                      , f.cod_situacao_b AS cst
                                      , SUM ( b.vlr_tributo_icms ) AS valor_icms
                                      , SUM ( b.vlr_tributo_icmss ) AS valor_icmss
                                      , NVL ( ( SELECT 'S'
                                                  FROM msaf.apuracao
                                                 WHERE cod_empresa = a.cod_empresa
                                                   AND cod_estab = a.cod_estab
                                                   AND cod_tipo_livro = '108'
                                                   AND dat_apuracao = LAST_DAY ( p_periodo ) )
                                            , 'N' )
                                            apuracao
                                   FROM msaf.dwt_docto_fiscal a
                                      , msaf.dwt_itens_merc b
                                      , msaf.x2012_cod_fiscal c
                                      , msaf.x2006_natureza_op d
                                      , msafi.dsp_estabelecimento e
                                      , msaf.y2026_sit_trb_uf_b f
                                  WHERE a.ident_docto_fiscal = b.ident_docto_fiscal
                                    AND b.ident_cfo = c.ident_cfo
                                    AND b.ident_natureza_op = d.ident_natureza_op
                                    AND a.cod_empresa = e.cod_empresa
                                    AND a.cod_estab = e.cod_estab
                                    AND b.ident_situacao_b = f.ident_situacao_b
                                    AND a.cod_empresa = mcod_empresa
                                    -- AND A.COD_ESTAB = 'DSP003'
                                    AND e.tipo = 'L'
                                    AND a.data_fiscal BETWEEN p_periodo AND LAST_DAY ( p_periodo )
                                    AND a.movto_e_s = '9'
                                    AND c.cod_cfo IN ( '5209'
                                                     , '6209' )
                                    AND d.cod_natureza_op = 'IST'
                                    AND f.cod_situacao_b = '90'
                                    AND e.cod_estado = 'RJ'
                                    AND b.vlr_tributo_icmss > 0
                               GROUP BY a.cod_empresa
                                      , a.cod_estab
                                      , TO_CHAR ( a.data_fiscal
                                                , 'MM/YYYY' )
                                      , c.cod_cfo
                                      , d.cod_natureza_op
                                      , f.cod_situacao_b ) LOOP
                        IF c.apuracao = 'S' THEN
                            lib_proc.add ( dsp_planilha.linha (
                                                                   dsp_planilha.campo ( c.cod_estab )
                                                                || dsp_planilha.campo ( c.periodo )
                                                                || dsp_planilha.campo ( c.cfop )
                                                                || dsp_planilha.campo ( c.fin )
                                                                || dsp_planilha.campo ( c.cst )
                                                                || dsp_planilha.campo ( c.valor_icms )
                                                                || dsp_planilha.campo ( c.valor_icmss )
                                                              , p_class => v_class
                                           )
                                         , ptipo => 4 );

                            IF v_class = 'A' THEN
                                v_class := 'B';
                            ELSE
                                v_class := 'A';
                            END IF;

                            INSERT INTO msaf.item_apurac_discr a ( cod_empresa
                                                                 , cod_estab
                                                                 , cod_tipo_livro
                                                                 , dat_apuracao
                                                                 , cod_oper_apur
                                                                 , num_discriminacao
                                                                 , val_item_discrim
                                                                 , dsc_item_apuracao
                                                                 , ind_dig_calculado
                                                                 , cod_amparo_legal
                                                                 , cod_sub_item_ocorr
                                                                 , cod_ajuste_icms
                                                                 , ind_est_deb_conv )
                                 VALUES ( mcod_empresa
                                        , c.cod_estab
                                        , '108'
                                        , LAST_DAY ( p_periodo )
                                        , '007'
                                        , ( SELECT MAX ( num_discriminacao ) + 1
                                              FROM msaf.item_apurac_discr b
                                             WHERE b.cod_empresa = mcod_empresa
                                               AND b.cod_estab = c.cod_estab
                                               AND b.cod_tipo_livro = '108'
                                               AND b.dat_apuracao = LAST_DAY ( p_periodo )
                                               AND b.cod_oper_apur = '007' )
                                        , c.valor_icms
                                        , 'ESTORNO DE DÉBITO CONFORME RESOLUÇÃO 889 SEFAZ/RJ DE 12/05/2015'
                                        , 1
                                        , 'N089999'
                                        , '02'
                                        , 'RJ030006'
                                        , 'N' );
                        ELSE
                            lib_proc.add ( 'ERRO: APURAÇÃO NÃO LOCALIZADA PARA O ESTABELECIMENTO ' || c.cod_estab );
                        END IF;
                    END LOOP;

                    COMMIT;

                    lib_proc.add ( dsp_planilha.tabela_fim
                                 , ptipo => 4 );
                    v_proc_status := 2;
                END;
            ELSE --PASSO DESCONHECIDO!??!?
                v_proc_status := 6451;
                loga ( 'ERRO INTERNO #6541: [' || p_passo || ']' ); -- PASSO DESCONHECIDO!!
                lib_proc.add ( 'ERRO INTERNO #6541: [' || p_passo || ']' );
        END CASE; --CASE P_PASSO

        v_s_proc_status :=
            CASE v_proc_status
                WHEN 0 THEN 'ERROI#0' --NUNCA DEVE SER 0, POIS JÁ VIRA 1 NO INÍCIO!
                WHEN 1 THEN 'ERROI#1' --AINDA ESTÁ EM PROCESSO!??!? ERRO NO PROCESSO!
                WHEN 2 THEN 'SUCESSO'
                WHEN 3 THEN 'AVISOS'
                WHEN 4 THEN 'ERRO'
                ELSE 'ERROI#' || v_proc_status
            END;

        loga ( 'FIM DO PROCESSAMENTO, STATUS FINAL: [' || v_s_proc_status || '] [' || dbg_line_error || ']' );
        lib_proc.add ( 'FIM DO PROCESSAMENTO, STATUS FINAL: [' || v_s_proc_status || ']' );
        lib_proc.add ( 'FAVOR VERIFICAR LOG PARA DETALHES.' );
        msafi.dsp_control.updateprocess ( v_s_proc_status );
        lib_proc.close ( );

        COMMIT;
        RETURN mproc_id;
    EXCEPTION
        WHEN OTHERS THEN
            msafi.dsp_control.log_checkpoint (
                                               SQLERRM
                                             , 'ERRO NÃO TRATADO, EXECUTADOR DE INTERFACES [' || dbg_line_error || ']'
            );
            lib_proc.add_log ( 'ERRO NÃO TRATADO:  [' || dbg_line_error || ']' || dbms_utility.format_error_backtrace
                             , 1 );
            lib_proc.add_log ( 'SQLERRM: ' || SQLERRM
                             , 1 );
            lib_proc.add_log ( 'INFO: ' || v_info
                             , 1 );
            lib_proc.add ( 'ERRO!' );
            lib_proc.add ( dbms_utility.format_error_backtrace );
            lib_proc.close;
            COMMIT;
            RETURN mproc_id;
    END; /* FUNCTION EXECUTAR */
END dsp_gia_cproc;
/
SHOW ERRORS;
