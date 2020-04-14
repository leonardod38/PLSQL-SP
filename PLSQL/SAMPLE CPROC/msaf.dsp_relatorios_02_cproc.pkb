Prompt Package Body DSP_RELATORIOS_02_CPROC;
--
-- DSP_RELATORIOS_02_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dsp_relatorios_02_cproc
IS
    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 5000 );
    BEGIN
        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );

        IF mcod_empresa IS NULL THEN
            lib_parametros.salvar ( 'EMPRESA'
                                  , msafi.dpsp.v_empresa );
            mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        END IF;

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

        lib_proc.add_param (
                             pstr
                           , 'RELATORIO'
                           , --P_RELATORIO
                            'VARCHAR2'
                           , 'COMBOBOX'
                           , 'S'
                           , NULL
                           , NULL
                           , '
                            SELECT ''002'',''002 - Quebra Sequencia Entrada Lojas'' FROM DUAL
                      UNION SELECT ''003'',''003 - Conferência NFs da Célula'' FROM DUAL
                      UNION SELECT ''004'',''004 - Notas Fiscais de Entrada Duplicadas'' FROM DUAL
                      UNION SELECT ''005'',''005 - Relação de Itens para PROTEG-GO'' FROM DUAL                     
                      UNION SELECT ''006'',''006 - Conferência de Vendas DSP x DP'' FROM DUAL
                      UNION SELECT ''007'',''007 - Conferência de Vendas DP x DSP'' FROM DUAL
                      UNION SELECT ''008'',''008 - Confronto DH x Mastersaf x MCD'' FROM DUAL                     
                      UNION SELECT ''009'',''009 - Relatório Valor do FECP-RJ'' FROM DUAL
                      UNION SELECT ''010'',''010 - Relatório Confronto MSAF x MCD x GL'' FROM DUAL                     
                           '
        );

        lib_proc.add_param ( pstr
                           , 'DATA INICIAL'
                           , --P_DATA_INI
                            'DATE'
                           , 'TEXTBOX'
                           , 'N'
                           , NULL
                           , 'DD/MM/YYYY' );

        lib_proc.add_param ( pstr
                           , 'DATA FINAL'
                           , --P_DATA_FIM
                            'DATE'
                           , 'TEXTBOX'
                           , 'N'
                           , NULL
                           , 'DD/MM/YYYY' );

        lib_proc.add_param ( pstr
                           , ''
                           , 'VARCHAR2'
                           , 'TEXT'
                           , 'N'
                           , '1'
                           , NULL
                           , ''
                           , 'N' );

        lib_proc.add_param ( pstr
                           , 'Módulo customizado para execução de relatórios diversos, sempre por data.'
                           , 'VARCHAR2'
                           , 'TEXT'
                           , 'N'
                           , '1'
                           , NULL
                           , ''
                           , 'N' );

        RETURN pstr;
    END; --FUNCTION PARAMETROS RETURN VARCHAR2 IS

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'RELATÓRIOS CUSTOMIZADOS 02';
    END;

    FUNCTION tipo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Relatorio';
    END;

    FUNCTION versao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'VERSAO 1.2';
    END;

    FUNCTION descricao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'RELATÓRIOS POR DATA';
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

    FUNCTION orientacaopapel
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'landscape';
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

    FUNCTION fazcampo ( p_i_campo IN VARCHAR2
                      , p_i_fill IN VARCHAR2
                      , p_i_size IN NUMBER )
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN LPAD ( NVL ( p_i_campo, ' ' )
                    , p_i_size
                    , p_i_fill );
    END;

    FUNCTION fazcampo ( p_i_campo IN NUMBER
                      , p_i_format IN VARCHAR2
                      , p_i_fill IN VARCHAR2
                      , p_i_size IN NUMBER )
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN LPAD ( NVL ( TO_CHAR ( p_i_campo
                                    , p_i_format )
                          , ' ' )
                    , p_i_size
                    , p_i_fill );
    END;

    FUNCTION fazcampo ( p_i_campo IN DATE
                      , p_i_format IN VARCHAR2
                      , p_i_fill IN VARCHAR2
                      , p_i_size IN NUMBER )
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN LPAD ( NVL ( TO_CHAR ( p_i_campo
                                    , p_i_format )
                          , ' ' )
                    , p_i_size
                    , p_i_fill );
    END;

    FUNCTION executar ( p_relatorio VARCHAR2
                      , p_data_ini DATE
                      , p_data_fim DATE )
        RETURN INTEGER
    IS
        mproc_id INTEGER;

        v_sep VARCHAR2 ( 1 );

        v_proc_status NUMBER := 0;

        v_s_proc_status VARCHAR2 ( 16 );

        --Variaveis genericas

        v_text01 VARCHAR2 ( 2000 );

        --V_TEXT02 varchar2(256);

        --

        v_estab_ant VARCHAR2 ( 6 );

        v_009_total NUMBER := 0;

        v_class CHAR ( 1 ) := 'a';
    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT="DD/MM/YYYY"';

        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );

        IF mcod_empresa IS NULL THEN
            lib_parametros.salvar ( 'EMPRESA'
                                  , msafi.dpsp.v_empresa );
            mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );
        END IF;

        mcod_estab := lib_parametros.recuperar ( 'ESTABELECIMENTO' );
        musuario := lib_parametros.recuperar ( 'USUARIO' );

        msafi.dsp_aux.truncatabela_msafi ( 'DSP_PROC_ESTABS' );

        v_sep := '|';

        mproc_id :=
            lib_proc.new ( 'DSP_RELATORIOS_02_CPROC'
                         , 48
                         , 150 );

        IF p_relatorio <> '004' THEN
            lib_proc.add_tipo ( mproc_id
                              , 1
                              , 'Processo'
                              , 1
                              , pmaxcols => 150 );
        END IF;

        IF mcod_empresa IS NULL THEN
            lib_proc.add_log ( 'Código da empresa deve ser informado como parâmetro global.'
                             , 0 );
            lib_proc.close;
            COMMIT;
            RETURN mproc_id;
        END IF;

        msafi.dsp_control.createprocess ( 'CUST_RELFIS02' --P_I_PROCID            IN VARCHAR2             , --VARCHAR2(16)
                                        , 'CUSTOMIZADO MASTERSAF: RELATORIO FISCAL 02' --P_I_PROC_DESCR        IN VARCHAR2             , --VARCHAR2(64)
                                        , p_data_ini --P_I_DATA_INI          IN DATE     DEFAULT NULL,
                                        , p_data_fim --P_I_DATA_FIM          IN DATE     DEFAULT NULL,
                                        , p_relatorio --P_I_DETALHES1         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , NULL --P_I_DETALHES2         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , NULL --P_I_DETALHES3         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , NULL --P_I_DETALHES4         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                        , musuario --P_I_USER              IN VARCHAR2 DEFAULT NULL  --VARCHAR2(64)
                                                   );

        v_proc_status := 1; --EM PROCESSO

        INSERT INTO msafi.dsp_proc_estabs
            SELECT cod_estab
              FROM estabelecimento
             WHERE cod_empresa = mcod_empresa;

        ----------------------------------------------------------------------------------------------------------

        IF p_relatorio = '001' THEN
            NULL; --o relatório 1 era de validação de chave de acesso, mas foi movido para o customizado de relatórios 01
        ----------------------------------------------------------------------------------------------------------

        ELSIF p_relatorio = '002' THEN
            --UNION SELECT ''002'',''002 - Quebra Sequencia Entrada Lojas'' FROM DUAL

            loga ( 'Imprimindo relatório' );

            loga ( 'Este relatório exibe as quebras de sequencia nas entradas das lojas' );

            loga ( 'Os campos são:' );

            loga ( 'Estabelecimento' );

            loga ( 'Data da NF' );

            loga ( 'Número da NF' );

            loga ( 'Data da próxima NF (nf emitida logo em seguida)' );

            loga ( 'Numero da próxima NF (nf emitida logo em seguida)' );

            loga ( 'Número da NF "que falta" (esta pode estar em outra data)' );

            loga ( '"NF existe no período" - indica se a "NF Faltante" se encontra no período atual' );

            loga ( ' caso não exista neste período, pode estar em outro mês ou realmente não existir' );

            mproc_id :=
                lib_proc.new ( 'DPSP_QUEBRA_SEQ_ENTRADA'
                             , 48
                             , 150 );

            lib_proc.add_tipo ( mproc_id
                              , 1
                              ,    mcod_empresa
                                || '_'
                                || TO_CHAR ( p_data_fim
                                           , 'YYYYMM' )
                                || '_QUEBRA_DE_SEQUENCIA_ENTRADA.XLS'
                              , 2 );

            lib_proc.add ( dsp_planilha.header
                         , ptipo => 1 );

            lib_proc.add ( dsp_planilha.tabela_inicio
                         , ptipo => 1 );

            lib_proc.add ( dsp_planilha.linha ( p_conteudo => dsp_planilha.campo (
                                                                                   '002 - Quebra de Sequencia nas Entradas de Lojas'
                                                                                 , p_custom => 'COLSPAN=7'
                                                             )
                                              , p_class => 'h' )
                         , ptipo => 1 );

            lib_proc.add ( dsp_planilha.linha (
                                                p_conteudo =>    dsp_planilha.campo ( 'ESTAB' )
                                                              || dsp_planilha.campo ( 'DATA' )
                                                              || dsp_planilha.campo ( 'DOC FIS' )
                                                              || dsp_planilha.campo ( 'DT PROX NF' )
                                                              || dsp_planilha.campo ( 'PROX NF' )
                                                              || dsp_planilha.campo ( 'NF FALTANTE' )
                                                              || dsp_planilha.campo ( 'NF EXISTE NO PERIODO' )
                                              , p_class => 'h'
                           )
                         , ptipo => 1 );

            loga ( 'Abrindo cursor' );

            FOR cr_002 IN c_relatorio_02_002 ( p_data_ini
                                             , p_data_fim ) LOOP
                IF v_class = 'a' THEN
                    v_class := 'b';
                ELSE
                    v_class := 'a';
                END IF;

                ---

                v_text01 :=
                    dsp_planilha.linha (
                                         p_conteudo =>    dsp_planilha.campo ( cr_002.cod_estab )
                                                       || dsp_planilha.campo ( cr_002.data_fiscal )
                                                       || dsp_planilha.campo (
                                                                               dsp_planilha.texto ( cr_002.num_docfis )
                                                          )
                                                       || dsp_planilha.campo ( cr_002.proxima_nf_dt )
                                                       || dsp_planilha.campo (
                                                                               dsp_planilha.texto (
                                                                                                    cr_002.proxima_nf_num
                                                                               )
                                                          )
                                                       || dsp_planilha.campo (
                                                                               dsp_planilha.texto (
                                                                                                    cr_002.nf_faltante
                                                                               )
                                                          )
                                                       || dsp_planilha.campo ( cr_002.existe_nf_no_periodo )
                                       , p_class => v_class
                    );

                lib_proc.add ( v_text01
                             , ptipo => 1 );
            END LOOP; --FOR CR_002 IN C_RELATORIO_02_002(P_DATA_INI,P_DATA_FIM)

            lib_proc.add ( dsp_planilha.tabela_fim
                         , ptipo => 1 );

            loga ( 'Fim do relatório!' );

            v_proc_status := 2; --SUCESSO
        ----------------------------------------------------------------------------------------------------------

        ELSIF p_relatorio = '003' THEN
            --UNION SELECT ''003'',''003 - Conferência NFs da Célula'' FROM DUAL

            loga ( 'Imprimindo relatório' );

            loga ( ' ' );

            loga ( 'Este relatório exibe as NFs de célula' );

            loga ( 'Os valores possíveis para a coluna de VALCHAVE (validação da Chave de Acesso da NFe) são:' );

            loga ( 'OK' );

            loga ( '(BRANCO) - chave de acesso não preenchida' );

            loga ( 'Inv(??) - Chave Inválida(Motivo); motivos:' );

            loga ( 'TM - Tamanho da chave - deve ter 44 dígitos' );

            loga ( 'UF - Estado - código do estado de emissão (código do IBGE)  (posição:  1, tamanho:  2)' );

            loga ( 'DT - Data de emissão                                        (posição:  3, tamanho:  4)' );

            loga ( 'CJ - CNPJ do emitente                                       (posição:  7, tamanho: 14)' );

            loga ( 'MD - Código do modelo da NF                                 (posição: 21, tamanho:  2)' );

            loga ( 'SR - Série da NF                                            (posição: 23, tamanho:  3)' );

            loga ( 'NM - Número da NF                                           (posição: 26, tamanho:  9)' );

            loga ( 'Forma de emissão da NF não é validada                       (posição: 35, tamanho:  1)' );

            loga ( 'Código numérico que compõe a Chave de Acesso não é validada (posição: 36, tamanho:  8)' );

            loga ( 'DV - Dígito verificador da NF                               (posição: 44, tamanho:  1)' );

            mproc_id :=
                lib_proc.new ( 'DPSP_CONFERENCIA_CELULA'
                             , 48
                             , 150 );

            lib_proc.add_tipo ( mproc_id
                              , 1
                              ,    mcod_empresa
                                || '_'
                                || TO_CHAR ( p_data_fim
                                           , 'YYYYMM' )
                                || '_CONFERENCIA_CELULA.XLS'
                              , 2 );

            lib_proc.add ( dsp_planilha.header
                         , ptipo => 1 );

            lib_proc.add ( dsp_planilha.tabela_inicio
                         , ptipo => 1 );

            lib_proc.add ( dsp_planilha.linha ( p_conteudo => dsp_planilha.campo ( '003 - Conferencia celula'
                                                                                 , p_custom => 'COLSPAN=28' )
                                              , p_class => 'h' )
                         , ptipo => 1 );

            lib_proc.add ( dsp_planilha.linha ( p_conteudo =>    dsp_planilha.campo ( 'ESTAB' )
                                                              || dsp_planilha.campo ( 'UF_ESTAB' )
                                                              || dsp_planilha.campo ( 'CNPJ' )
                                                              || dsp_planilha.campo ( 'DATA_FISCAL' )
                                                              || dsp_planilha.campo ( 'DATA_EMISSAO' )
                                                              || dsp_planilha.campo ( 'NUM_CONTROLE_DOCTO' )
                                                              || dsp_planilha.campo ( 'NUM_DOCFIS' )
                                                              || dsp_planilha.campo ( 'SERIE_DOCFIS' )
                                                              || dsp_planilha.campo ( 'SUB_SERIE_DOCFIS' )
                                                              || dsp_planilha.campo ( 'CHAVE_ACESSO_OK'
                                                                                    , p_width => 280 )
                                                              || dsp_planilha.campo ( 'COD_FIS_JUR'
                                                                                    , p_width => 100 )
                                                              || dsp_planilha.campo ( 'UF_X04' )
                                                              || dsp_planilha.campo ( 'CNPJ_X04' )
                                                              || dsp_planilha.campo ( 'MODELO_DOCTO' )
                                                              || dsp_planilha.campo ( 'MODELO_DE_NF' )
                                                              || dsp_planilha.campo ( 'CFOP' )
                                                              || dsp_planilha.campo ( 'CST' )
                                                              || dsp_planilha.campo ( 'COD_NAT_OPERACAO' )
                                                              || dsp_planilha.campo ( 'VALOR_UNITARIO' )
                                                              || dsp_planilha.campo ( 'VALOR_CONTABIL' )
                                                              || dsp_planilha.campo ( 'BASE_TRIBUTADA' )
                                                              || dsp_planilha.campo ( 'ALIQUOTA_ICMS' )
                                                              || dsp_planilha.campo ( 'VALOR_ICMS' )
                                                              || dsp_planilha.campo ( 'BASE_ISENTA' )
                                                              || dsp_planilha.campo ( 'BASE_OUTRAS' )
                                                              || dsp_planilha.campo ( 'BASE_REDUCAO' )
                                                              || dsp_planilha.campo ( 'VALOR_ICMS_ST' )
                                                              || dsp_planilha.campo ( 'VALOR_IPI' )
                                                              || dsp_planilha.campo ( 'USUARIO' )
                                                              || dsp_planilha.campo ( 'USUARIO_PEOPLE'
                                                                                    , p_width => 330 )
                                                              || dsp_planilha.campo ( 'OBS_TRIBUTO_ICMS' )
                                              , p_class => 'h' )
                         , ptipo => 1 );

            loga ( 'Abrindo cursor' );

            FOR cr_003 IN c_relatorio_02_003 ( p_data_ini
                                             , p_data_fim ) LOOP
                IF v_class = 'a' THEN
                    v_class := 'b';
                ELSE
                    v_class := 'a';
                END IF;

                ---

                v_text01 :=
                    dsp_planilha.linha (
                                         p_conteudo =>    dsp_planilha.campo ( cr_003.cod_estab )
                                                       || dsp_planilha.campo ( cr_003.uf_estab )
                                                       || dsp_planilha.campo ( dsp_planilha.texto ( cr_003.cnpj ) )
                                                       || dsp_planilha.campo ( cr_003.data_fiscal )
                                                       || dsp_planilha.campo ( cr_003.data_emissao )
                                                       || dsp_planilha.campo (
                                                                               dsp_planilha.texto (
                                                                                                    cr_003.num_controle_docto
                                                                               )
                                                          )
                                                       || dsp_planilha.campo (
                                                                               dsp_planilha.texto ( cr_003.num_docfis )
                                                          )
                                                       || dsp_planilha.campo (
                                                                               dsp_planilha.texto (
                                                                                                    cr_003.serie_docfis
                                                                               )
                                                          )
                                                       || dsp_planilha.campo (
                                                                               dsp_planilha.texto (
                                                                                                    cr_003.sub_serie_docfis
                                                                               )
                                                          )
                                                       || dsp_planilha.campo (
                                                                               dsp_planilha.texto (
                                                                                                    cr_003.chave_acesso_ok
                                                                               )
                                                          )
                                                       || dsp_planilha.campo ( cr_003.cod_fis_jur )
                                                       || dsp_planilha.campo ( cr_003.uf_x04 )
                                                       || dsp_planilha.campo ( dsp_planilha.texto ( cr_003.cpf_cgc ) )
                                                       || dsp_planilha.campo ( cr_003.modelo_docto )
                                                       || dsp_planilha.campo ( cr_003.modelo_de_nf )
                                                       || dsp_planilha.campo ( cr_003.cfop )
                                                       || dsp_planilha.campo ( cr_003.cst )
                                                       || dsp_planilha.campo ( cr_003.cod_nat_operacao )
                                                       || dsp_planilha.campo ( moeda ( cr_003.valor_unitario ) )
                                                       || dsp_planilha.campo ( moeda ( cr_003.valor_contabil ) )
                                                       || dsp_planilha.campo ( moeda ( cr_003.base_tributada ) )
                                                       || dsp_planilha.campo ( cr_003.aliquota_icms )
                                                       || dsp_planilha.campo ( moeda ( cr_003.valor_icms ) )
                                                       || dsp_planilha.campo ( moeda ( cr_003.base_isenta ) )
                                                       || dsp_planilha.campo ( moeda ( cr_003.base_outras ) )
                                                       || dsp_planilha.campo ( moeda ( cr_003.base_reducao ) )
                                                       || dsp_planilha.campo ( moeda ( cr_003.valor_icms_st ) )
                                                       || dsp_planilha.campo ( moeda ( cr_003.valor_ipi ) )
                                                       || dsp_planilha.campo ( cr_003.usuario )
                                                       || dsp_planilha.campo ( cr_003.usuario_people )
                                                       || dsp_planilha.campo ( cr_003.obs_tributo_icms )
                                       , p_class => v_class
                    );

                lib_proc.add ( v_text01
                             , ptipo => 1 );
            END LOOP; --FOR CR_003 IN C_RELATORIO_02_003(P_DATA_INI,P_DATA_FIM)

            lib_proc.add ( dsp_planilha.tabela_fim
                         , ptipo => 1 );

            loga ( 'Fim do relatório!' );

            v_proc_status := 2; --SUCESSO
        ----------------------------------------------------------------------------------------------------------

        ELSIF p_relatorio = '004' THEN
            --UNION SELECT ''004'',''004 - Notas Fiscais de Entrada Duplicadas'' FROM DUAL

            loga ( 'Imprimindo relatório' );

            loga ( ' ' );

            loga ( 'Este relatório exibe as NFs de entrada duplicadas dentro do período equalizado' );

            loga ( ' ' );

            loga ( 'O relatório utiliza todas as NFs de entrada dentro do período informado e' );

            loga ( 'pesquisa por NFs duplicadas dentro de todo o período equalizado no DataMart' );

            -- MPROC_IDB := LIB_PROC.new('DPSP_NOTAS_DUPLICADAS', 48, 150);

            lib_proc.add_tipo ( mproc_id
                              , 1
                              ,    mcod_empresa
                                || '_'
                                || TO_CHAR ( p_data_fim
                                           , 'YYYYMM' )
                                || '_NOTAS_ENTRADA_DUPLICADAS.XLS'
                              , 2 );

            lib_proc.add ( dsp_planilha.header
                         , ptipo => 1 );

            lib_proc.add ( dsp_planilha.tabela_inicio
                         , ptipo => 1 );

            lib_proc.add ( dsp_planilha.linha ( p_conteudo => dsp_planilha.campo ( '004 - Notas de Entrada Duplicadas'
                                                                                 , p_custom => 'COLSPAN=16' )
                                              , p_class => 'h' )
                         , ptipo => 1 );

            lib_proc.add ( dsp_planilha.linha ( p_conteudo =>    dsp_planilha.campo ( 'COD_ESTAB' )
                                                              || dsp_planilha.campo ( 'COD_ESTAB_B' )
                                                              || dsp_planilha.campo ( 'NUM_DOCFIS' )
                                                              || dsp_planilha.campo ( 'SERIE_DOCFIS' )
                                                              || dsp_planilha.campo ( 'CPF_CGC' )
                                                              || dsp_planilha.campo ( 'DATA_FISCAL_A' )
                                                              || dsp_planilha.campo ( 'COD_FIS_JUR_A' )
                                                              || dsp_planilha.campo ( 'RAZAO_SOCIAL_A' )
                                                              || dsp_planilha.campo ( 'VLR_TOT_NOTA_A' )
                                                              || dsp_planilha.campo ( 'DATA_FISCAL_B' )
                                                              || dsp_planilha.campo ( 'COD_FIS_JUR_B' )
                                                              || dsp_planilha.campo ( 'RAZAO_SOCIAL_B' )
                                                              || dsp_planilha.campo ( 'VLR_TOT_NOTA_B' )
                                                              || dsp_planilha.campo ( 'IDENT_DOCTO_FISCAL_A' )
                                                              || dsp_planilha.campo ( 'IDENT_DOCTO_FISCAL_B' )
                                                              || dsp_planilha.campo ( 'CHAVE_ACESSO_A'
                                                                                    , p_width => 280 )
                                              , p_class => 'h' )
                         , ptipo => 1 );

            loga ( 'Abrindo cursor' );

            FOR cr_004 IN c_relatorio_02_004 ( p_data_ini
                                             , p_data_fim ) LOOP
                IF v_class = 'a' THEN
                    v_class := 'b';
                ELSE
                    v_class := 'a';
                END IF;

                ---

                v_text01 :=
                    dsp_planilha.linha (
                                         p_conteudo =>    dsp_planilha.campo ( cr_004.cod_estab )
                                                       || dsp_planilha.campo ( cr_004.cod_estab_b )
                                                       || dsp_planilha.campo (
                                                                               dsp_planilha.texto ( cr_004.num_docfis )
                                                          )
                                                       || dsp_planilha.campo (
                                                                               dsp_planilha.texto (
                                                                                                    cr_004.serie_docfis
                                                                               )
                                                          )
                                                       || dsp_planilha.campo ( dsp_planilha.texto ( cr_004.cpf_cgc ) )
                                                       || dsp_planilha.campo ( cr_004.data_fiscal_a )
                                                       || dsp_planilha.campo (
                                                                               dsp_planilha.texto (
                                                                                                    cr_004.cod_fis_jur_a
                                                                               )
                                                          )
                                                       || dsp_planilha.campo ( cr_004.razao_social_a )
                                                       || dsp_planilha.campo ( moeda ( cr_004.vlr_tot_nota_a ) )
                                                       || dsp_planilha.campo ( cr_004.data_fiscal_b )
                                                       || dsp_planilha.campo (
                                                                               dsp_planilha.texto (
                                                                                                    cr_004.cod_fis_jur_b
                                                                               )
                                                          )
                                                       || dsp_planilha.campo ( cr_004.razao_social_b )
                                                       || dsp_planilha.campo ( moeda ( cr_004.vlr_tot_nota_b ) )
                                                       || dsp_planilha.campo (
                                                                               dsp_planilha.texto (
                                                                                                    cr_004.ident_docto_fiscal_a
                                                                               )
                                                          )
                                                       || dsp_planilha.campo (
                                                                               dsp_planilha.texto (
                                                                                                    cr_004.ident_docto_fiscal_b
                                                                               )
                                                          )
                                                       || dsp_planilha.campo (
                                                                               dsp_planilha.texto (
                                                                                                    cr_004.chave_acesso_a
                                                                               )
                                                          )
                                       , p_class => v_class
                    );

                lib_proc.add ( v_text01
                             , ptipo => 1 );
            END LOOP; --FOR CR_004 IN C_RELATORIO_02_004(P_DATA_INI,P_DATA_FIM)

            lib_proc.add ( dsp_planilha.tabela_fim
                         , ptipo => 1 );

            loga ( 'Fim do relatório!' );

            v_proc_status := 2; --SUCESSO
        ----------------------------------------------------------------------------------------------------------

        --ELSIF P_RELATORIO = '003' THEN

        ---            lib_proc.add('         1         2         3         4         5         6         7         8        9         10        11        12         13       14        15');

        ---            lib_proc.add('123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890');

        ----------------------------------------------------------------------------------------------------------

        ELSIF p_relatorio = '005' THEN
            -- RELATORIO: UNION SELECT ''005'',''005 - Relação de Itens para PROTEG-GO'' FROM DUAL

            loga ( 'Imprimindo relatório' );

            loga ( ' ' );

            lib_proc.add_header ( '005 - Relação de Itens para PROTEG-GO'
                                , 1
                                , 1 );

            lib_proc.add_header ( ' ' );

            lib_proc.add (
                           ' ESTAB|DATA TRANS|COMPONENTE|NUM CUPOM|  PRODUTO|             DESCRICAO|     NBM|         DESCRICAO NBM|COD TRIB|VLR TOTAL| VLR DESC| VLR ICMS|'
            );

            lib_proc.add (
                           '------|----------|----------|---------|---------|----------------------|--------|----------------------|--------|---------|---------|---------|'
            );

            --                        DSP029|18/09/2015|         1|123456789|123456789|SH+CD.PAN.400/200 REST|33051000|Cremes de beleza e cre|      17|123456.78|123456.78|123456.78|

            loga ( 'Abrindo cursor' );

            FOR cr_005 IN c_relatorio_02_005 ( p_data_ini
                                             , p_data_fim ) LOOP
                v_text01 :=
                    fazcampo ( cr_005.cod_estab
                             , ' '
                             , 6 );

                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_005.data_transacao
                                , 'DD/MM/YYYY'
                                , ' '
                                , 10 );

                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_005.numero_componente
                                , ' '
                                , 10 );

                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_005.numero_cupom
                                , ' '
                                , 9 );

                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_005.codigo_produto
                                , ' '
                                , 9 );

                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_005.descricao_produto
                                , ' '
                                , 22 );

                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_005.cod_nbm
                                , ' '
                                , 8 );

                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_005.descricao_nbm
                                , ' '
                                , 22 );

                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_005.cod_tributacao
                                , ' '
                                , 8 );

                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_005.valor_total_produto
                                , ' '
                                , 9 );

                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_005.valor_desconto
                                , ' '
                                , 9 );

                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_005.valor_icms
                                , ' '
                                , 9 );

                v_text01 := v_text01 || v_sep;

                lib_proc.add ( v_text01 );
            END LOOP; --FOR CR_005 IN C_RELATORIO_02_005(P_DATA_INI,P_DATA_FIM)

            loga ( 'Fim do relatório!' );

            v_proc_status := 2; --SUCESSO
        ----------------------------------------------------------------------------------------------------------

        ELSIF p_relatorio = '006' THEN
            -- RELATORIO: UNION SELECT ''006'',''006 - Conferência de Vendas DSP x DP'' FROM DUAL

            loga ( 'Imprimindo relatório' );

            loga ( ' ' );

            lib_proc.add_header ( '006 - Conferência de Vendas DSP x DP'
                                , 1
                                , 1 );

            lib_proc.add_header ( ' ' );

            lib_proc.add (
                           'EMP| ESTAB|MOV|     NF|SERIE|   ID PEOPLE|DATA FISCAL|SIT|                                   CHAVE NFE| CFOP|CST|NAT| VLR CONTAB|  BASE TRIB| ALIQ|  ICMS| VLR ISENTA| VLR OUTRAS|VLR REDUCAO|'
            );

            lib_proc.add (
                           '---|------|---|-------|-----|------------|-----------|---|--------------------------------------------|-----|---|---|-----------|-----------|-----|------|-----------|-----------|-----------|'
            );

            --                        DSP|DSP001|  1|1234567|  001|000000000001| 01/01/1900|  1|31150861412110024410550010000038701139075519|1.109|000|IST|12345678.90|12345678.90|12.34|123.45|12345678.90|12345678.90|12345678.90|

            loga ( 'Abrindo cursor' );

            FOR cr_006 IN c_relatorio_02_006 ( p_data_ini
                                             , p_data_fim ) LOOP
                v_text01 :=
                    fazcampo ( cr_006.cod_empresa
                             , ' '
                             , 3 );

                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_006.cod_estab
                                , ' '
                                , 6 );

                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_006.movto_e_s
                                , ' '
                                , 3 );

                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_006.num_docfis
                                , ' '
                                , 7 );

                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_006.serie_docfis
                                , ' '
                                , 5 );

                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_006.id_people
                                , ' '
                                , 12 );

                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_006.data_fiscal
                                , 'DD/MM/YYYY'
                                , ' '
                                , 10 );

                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_006.situacao
                                , ' '
                                , 3 );

                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_006.num_autentic_nfe
                                , ' '
                                , 44 );

                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_006.cod_cfo
                                , ' '
                                , 5 );

                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_006.cod_situacao_b
                                , ' '
                                , 3 );

                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_006.cod_natureza_op
                                , ' '
                                , 3 );

                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_006.vlr_contab_item
                                , ' '
                                , 11 );

                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_006.base_tributada
                                , ' '
                                , 11 );

                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_006.aliq_icms
                                , ' '
                                , 5 );

                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_006.valor_icms
                                , ' '
                                , 6 );

                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_006.isenta
                                , ' '
                                , 11 );

                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_006.outras
                                , ' '
                                , 11 );

                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_006.reducao
                                , ' '
                                , 11 );

                v_text01 := v_text01 || v_sep;

                lib_proc.add ( v_text01 );
            END LOOP; --FOR CR_006 IN C_RELATORIO_02_006(P_DATA_INI,P_DATA_FIM)

            loga ( 'Fim do relatório!' );

            v_proc_status := 2; --SUCESSO
        ----------------------------------------------------------------------------------------------------------

        ELSIF p_relatorio = '007' THEN
            -- RELATORIO: UNION SELECT ''007'',''007 - Conferência de Vendas DP x DSP'' FROM DUAL

            loga ( 'Imprimindo relatório' );

            loga ( ' ' );

            lib_proc.add_header ( '007 - Conferência de Vendas DP x DSP'
                                , 1
                                , 1 );

            lib_proc.add_header ( ' ' );

            lib_proc.add (
                           'EMP| ESTAB|MOV|     NF|SERIE|   ID PEOPLE|DATA FISCAL|SIT|                                   CHAVE NFE| CFOP|CST|NAT| VLR CONTAB|  BASE TRIB| ALIQ|  ICMS| VLR ISENTA| VLR OUTRAS|VLR REDUCAO|'
            );

            lib_proc.add (
                           '---|------|---|-------|-----|------------|-----------|---|--------------------------------------------|-----|---|---|-----------|-----------|-----|------|-----------|-----------|-----------|'
            );

            --                        DSP|DSP001|  1|1234567|  001|000000000001| 01/01/1900|  1|31150861412110024410550010000038701139075519|1.109|000|IST|12345678.90|12345678.90|12.34|123.45|12345678.90|12345678.90|12345678.90|

            loga ( 'Abrindo cursor' );

            FOR cr_007 IN c_relatorio_02_007 ( p_data_ini
                                             , p_data_fim ) LOOP
                v_text01 :=
                    fazcampo ( cr_007.cod_empresa
                             , ' '
                             , 3 );

                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_007.cod_estab
                                , ' '
                                , 6 );

                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_007.movto_e_s
                                , ' '
                                , 3 );

                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_007.num_docfis
                                , ' '
                                , 7 );

                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_007.serie_docfis
                                , ' '
                                , 5 );

                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_007.id_people
                                , ' '
                                , 12 );

                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_007.data_fiscal
                                , 'DD/MM/YYYY'
                                , ' '
                                , 10 );

                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_007.situacao
                                , ' '
                                , 3 );

                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_007.num_autentic_nfe
                                , ' '
                                , 44 );

                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_007.cod_cfo
                                , ' '
                                , 5 );

                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_007.cod_situacao_b
                                , ' '
                                , 3 );

                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_007.cod_natureza_op
                                , ' '
                                , 3 );

                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_007.vlr_contab_item
                                , ' '
                                , 11 );

                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_007.base_tributada
                                , ' '
                                , 11 );

                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_007.aliq_icms
                                , ' '
                                , 5 );

                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_007.valor_icms
                                , ' '
                                , 6 );

                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_007.isenta
                                , ' '
                                , 11 );

                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_007.outras
                                , ' '
                                , 11 );

                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_007.reducao
                                , ' '
                                , 11 );

                v_text01 := v_text01 || v_sep;

                lib_proc.add ( v_text01 );
            END LOOP; --FOR CR_007 IN C_RELATORIO_02_007(P_DATA_INI,P_DATA_FIM)

            loga ( 'Fim do relatório!' );

            v_proc_status := 2; --SUCESSO
        ----------------------------------------------------------------------------------------------------------

        ELSIF p_relatorio = '008' THEN
            -- RELATORIO: UNION SELECT ''008'',''008 - Confronto DH x Mastersaf x MCD'' FROM DUAL

            loga ( 'Imprimindo relatório' );

            loga ( ' ' );

            lib_proc.add_header ( '008 - Confronto DH x Mastersaf x MCD'
                                , 1
                                , 1 );

            lib_proc.add_header ( ' ' );

            lib_proc.add ( '                         |---- CUPOM ---|----- MCD ----|----  DH   ---|' );

            lib_proc.add ( ' ESTAB|CX |DT TRANSAC|MOD|VENDA LIQ MSAF|VENDA LIQ MCD |VENDA LIQ DH  |DIFERENÇA?|' );

            lib_proc.add ( '------|---|----------|---|--------------|--------------|--------------|----------|' );

            --                        DSP344| 13|02/12/2015| 2D|   12345678.90|   12345678.90|   12345678.90|

            loga ( 'Abrindo cursor' );

            v_estab_ant := '';

            FOR c8_data IN c_datas ( p_data_ini
                                   , p_data_fim ) LOOP
                FOR cr_008 IN c_relatorio_02_008 ( c8_data.data_normal ) LOOP
                    IF ( v_estab_ant <> cr_008.cod_estab ) THEN
                        lib_proc.add (
                                       '------|---|----------|---|--------------|--------------|--------------|----------|'
                        );
                    END IF;

                    v_estab_ant := cr_008.cod_estab;

                    ---

                    v_text01 :=
                        fazcampo ( cr_008.cod_estab
                                 , ' '
                                 , 6 );

                    v_text01 :=
                           v_text01
                        || v_sep
                        || fazcampo ( cr_008.caixa
                                    , ' '
                                    , 3 );

                    v_text01 :=
                           v_text01
                        || v_sep
                        || fazcampo ( cr_008.data_transacao
                                    , 'DD/MM/YYYY'
                                    , ' '
                                    , 10 );

                    v_text01 :=
                           v_text01
                        || v_sep
                        || fazcampo ( cr_008.modelo
                                    , ' '
                                    , 3 );

                    v_text01 :=
                           v_text01
                        || v_sep
                        || fazcampo ( cr_008.venda_liq_msaf
                                    , ' '
                                    , 14 );

                    v_text01 :=
                           v_text01
                        || v_sep
                        || fazcampo ( cr_008.venda_liq_mcd
                                    , ' '
                                    , 14 );

                    v_text01 :=
                           v_text01
                        || v_sep
                        || fazcampo ( cr_008.venda_liq_dh
                                    , ' '
                                    , 14 );

                    v_text01 :=
                           v_text01
                        || v_sep
                        || fazcampo ( cr_008.diferenca
                                    , ' '
                                    , 10 );

                    v_text01 := v_text01 || v_sep;

                    lib_proc.add ( v_text01 );
                END LOOP; --FOR CR_008 IN C_RELATORIO_02_008(P_DATA_INI,P_DATA_FIM)
            END LOOP; --FOR DATA_TRANSACAO IN C_DATAS(P_DATA_INI, P_DATA_FIM)

            lib_proc.add ( '------|---|----------|---|--------------|--------------|--------------|----------|' );

            loga ( 'Fim do relatório!' );

            v_proc_status := 2; --SUCESSO
        ----------------------------------------------------------------------------------------------------------

        ELSIF p_relatorio = '009' THEN
            -- RELATORIO: UNION SELECT ''009'',''009 - Relatório Valor do FECP-RJ'' FROM DUAL

            loga ( 'Imprimindo relatório' );

            loga ( ' ' );

            lib_proc.add_header ( '009 - Relatório Valor do FECP-RJ'
                                , 1
                                , 1 );

            lib_proc.add_header ( ' ' );

            lib_proc.add ( 'EMPRESA| ESTAB|DT APURACAO|BASE TRIB SAIDA|BASE TRIB ENTRADA|    VALOR FECP|' );

            lib_proc.add ( '-------|------|-----------|---------------|-----------------|--------------|' );

            --                            DSP|DP1001| 02/12/2015| 12345678900.00|   12345678900.00|12345678900.00|

            v_009_total := 0;

            loga ( 'Abrindo cursor' );

            FOR cr_009 IN c_relatorio_009 ( p_data_ini
                                          , p_data_fim ) LOOP
                v_text01 :=
                    fazcampo ( cr_009.cod_empresa
                             , ' '
                             , 7 );

                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_009.cod_estab
                                , ' '
                                , 6 );

                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_009.data_apuracao
                                , 'DD/MM/YYYY'
                                , ' '
                                , 11 );

                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_009.base_tributada_saida
                                , ' '
                                , 15 );

                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_009.base_tributada_entrada
                                , ' '
                                , 17 );

                v_text01 :=
                       v_text01
                    || v_sep
                    || fazcampo ( cr_009.valor_fecp
                                , ' '
                                , 14 );

                v_text01 := v_text01 || v_sep;

                lib_proc.add ( v_text01 );

                v_009_total := v_009_total + cr_009.valor_fecp;
            END LOOP; --FOR CR_009 IN C_RELATORIO_009(P_DATA_INI, P_DATA_FIM)

            lib_proc.add ( '-------|------|-----------|---------------|-----------------|--------------|' );

            lib_proc.add (    '                                                       TOTAL:'
                           || fazcampo ( v_009_total
                                       , ' '
                                       , 14 )
                           || '|' );

            lib_proc.add ( '---------------------------------------------------------------------------|' );

            loga ( 'Fim do relatório!' );

            v_proc_status := 2; --SUCESSO
        ----------------------------------------------------------------------------------------------------------

        ELSIF p_relatorio = '010' THEN
            -- RELATORIO: UNION SELECT ''010'',''010 - Relatório Confronto MSAF x MCD x GL'' FROM DUAL

            loga ( 'Imprimindo relatório' );

            loga ( ' ' );

            lib_proc.add_header ( '010 - Relatório Confronto MSAF x MCD x GL'
                                , 1
                                , 1 );

            lib_proc.add_header ( ' ' );

            lib_proc.add ( '                    |----  DH   ---|--|---- MSAF ----|----  MCD  ---|-|----- GL  ----|' );

            lib_proc.add (
                           ' ESTAB|UF|DT TRANSAC|VENDA LIQ DH  |  |VENDA LIQ MSAF|VENDA LIQ MCD | |VENDA LIQ GL  |DIFERENÇA?|'
            );

            lib_proc.add (
                           '------|--|----------|--------------|--|--------------|--------------|-|--------------|----------|'
            );

            --                        DSP344|SP|02/12/2015|   12345678.90|PR|   12345678.90|   12345678.90|V|   12345678.90|

            loga ( 'Abrindo cursor' );

            v_estab_ant := '';

            FOR c10_data IN c_datas ( p_data_ini
                                    , p_data_fim ) LOOP
                FOR cr_010 IN c_relatorio_010 ( c10_data.data_normal ) LOOP
                    IF ( v_estab_ant <> cr_010.cod_estab ) THEN
                        lib_proc.add (
                                       '------|--|----------|--------------|--|--------------|--------------|-|--------------|----------|'
                        );
                    END IF;

                    v_estab_ant := cr_010.cod_estab;

                    ---

                    v_text01 :=
                        fazcampo ( cr_010.cod_estab
                                 , ' '
                                 , 6 );

                    v_text01 :=
                           v_text01
                        || v_sep
                        || fazcampo ( cr_010.uf
                                    , ' '
                                    , 2 );

                    v_text01 :=
                           v_text01
                        || v_sep
                        || fazcampo ( cr_010.data_transacao
                                    , 'DD/MM/YYYY'
                                    , ' '
                                    , 10 );

                    v_text01 :=
                           v_text01
                        || v_sep
                        || fazcampo ( cr_010.venda_liq_dh
                                    , ' '
                                    , 14 );

                    v_text01 :=
                           v_text01
                        || v_sep
                        || fazcampo ( cr_010.status_dh
                                    , ' '
                                    , 2 );

                    v_text01 :=
                           v_text01
                        || v_sep
                        || fazcampo ( cr_010.venda_liq_msaf
                                    , ' '
                                    , 14 );

                    v_text01 :=
                           v_text01
                        || v_sep
                        || fazcampo ( cr_010.venda_liq_mcd
                                    , ' '
                                    , 14 );

                    v_text01 :=
                           v_text01
                        || v_sep
                        || fazcampo ( cr_010.status_mcd
                                    , ' '
                                    , 1 );

                    v_text01 :=
                           v_text01
                        || v_sep
                        || fazcampo ( cr_010.venda_liq_gl
                                    , ' '
                                    , 14 );

                    v_text01 :=
                           v_text01
                        || v_sep
                        || fazcampo ( cr_010.diferenca
                                    , ' '
                                    , 10 );

                    v_text01 := v_text01 || v_sep;

                    lib_proc.add ( v_text01 );
                END LOOP; --FOR CR_010 IN C_RELATORIO_010(C10_DATA.DATA_NORMAL)
            END LOOP; --FOR C10_DATA IN C_DATAS(P_DATA_INI, P_DATA_FIM)

            lib_proc.add (
                           '------|--|----------|--------------|--|--------------|--------------|-|--------------|----------|'
            );

            loga ( 'Fim do relatório!' );

            v_proc_status := 2; --SUCESSO
        END IF;

        ----------------------------------------------------------------------------------------------------------

        loga ( 'Fim do processo, limpando temporária de estabelecimentos' );

        msafi.dsp_aux.truncatabela_msafi ( 'DSP_PROC_ESTABS' );

        COMMIT;

        v_s_proc_status :=
            CASE v_proc_status
                WHEN 0 THEN 'ERROI#0' --NUNCA DEVE SER 0, POIS JÁ VIRA 1 NO INÍCIO!
                WHEN 1 THEN 'ERROI#1' --AINDA ESTÁ EM PROCESSO!??!? ERRO NO PROCESSO!
                WHEN 2 THEN 'SUCESSO'
                WHEN 3 THEN 'AVISOS'
                WHEN 4 THEN 'ERRO'
                ELSE 'ERROI#' || v_proc_status
            END;

        loga ( 'FIM DO PROCESSAMENTO, STATUS FINAL: [' || v_s_proc_status || ']' );

        msafi.dsp_control.updateprocess ( v_s_proc_status );

        lib_proc.close ( );

        COMMIT;

        RETURN mproc_id;
    EXCEPTION
        WHEN OTHERS THEN
            --MSAFI.DSP_CONTROL.LOG_CHECKPOINT(SQLERRM,'Erro não tratado, relatórios customizados');

            lib_proc.add_log ( 'Erro não tratado: ' || SQLERRM
                             , 1 );

            loga ( 'Abortando execução' );

            lib_proc.close;

            COMMIT;

            RETURN mproc_id;
    END; /* FUNCTION EXECUTAR */
BEGIN
    --configura as variáveis para funções regexp
    c_proc_9xx := '^' || mcod_empresa || '9[0-9]{2}$';
    c_proc_dep := '^' || mcod_empresa || '9[0-9][1-9]$';
    c_proc_loj :=
           '^'
        || mcod_empresa
        || '[0-8][0-9]{'
        || TO_CHAR ( 5 - LENGTH ( mcod_empresa )
                   , 'FM9' )
        || '}$';
    c_proc_est :=
           '^'
        || mcod_empresa
        || '[0-9]{3,'
        || TO_CHAR ( 6 - LENGTH ( mcod_empresa )
                   , 'FM9' )
        || '}$';
    c_proc_estvd :=
           '^VD[0-9]{3,'
        || TO_CHAR ( 6 - LENGTH ( mcod_empresa )
                   , 'FM9' )
        || '}$';
END dsp_relatorios_02_cproc;
/
SHOW ERRORS;
