Prompt Package Body DSP_EXECUTA_SCRIPTS_CPROC;
--
-- DSP_EXECUTA_SCRIPTS_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dsp_executa_scripts_cproc
IS
    mcod_empresa empresa.cod_empresa%TYPE;
    mcod_estab estabelecimento.cod_estab%TYPE;
    musuario usuario_estab.cod_usuario%TYPE;

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
                           , '*SENHA DO DIA'
                           , --P_SENHA
                            'VARCHAR2'
                           , 'TEXTBOX'
                           , 'S'
                           , NULL
                           , NULL
                           , NULL );

        lib_proc.add_param ( pstr
                           , '*CONFIRMAÇÃO'
                           , --P_CONFIRMA
                            'VARCHAR2'
                           , 'TEXTBOX'
                           , 'S'
                           , 'Digite a primeira palavra do script' );

        lib_proc.add_param ( pstr
                           , '*SCRIPT'
                           , --P_SCRIPT
                            'VARCHAR2'
                           , 'COMBOBOX'
                           , 'S'
                           , NULL
                           , NULL
                           , '
--                            SELECT ''001'',''001. LIBERA TRAVA INTERDADOS (N/N/N/N)'' FROM DUAL
                      /*UNION SELECT ''002'',''002. LIMPA APURAÇÃO EFD PIS/COFINS (DESABILITADO)'' FROM DUAL*/
                      /*UNION SELECT ''003'',''003. SCRIPTS POS CARGA (ANTES DA IMPORTAÇÃO)'' FROM DUAL*/
                            SELECT ''004'',''004. TRUNCAR TABELA (N/N/S/N)'' FROM DUAL
                      UNION SELECT ''005'',''005. CORRIGIR SAFX2087 (N/N/N/N)'' FROM DUAL
                      UNION SELECT ''006'',''006. REPLICAR CADASTROS PARA CUPOM FISCAL (N/N/N/N)'' FROM DUAL
                      UNION SELECT ''007'',''007. TRUNCAR TABELAS MEIO MAGNETICO CAT17 (N/N/N/N)'' FROM DUAL
                      /*UNION SELECT ''008'',''008. MIGRAR SAFX07 e 08 DO MSAFI PARA MSAF (S/S/N/O)'' FROM DUAL*/
                      /*UNION SELECT ''009'',''009. TRUNCAR E TROCAR MSAFI.SAFX07 e SAFX08 (N/N/N/N)'' FROM DUAL*/
                      UNION SELECT ''010'',''010. LIBERAR TABELAS DO DATAMART (N/N/O/O)'' FROM DUAL
                      UNION SELECT ''011'',''011. EXCLUIR NFs EXISTENTES NA SAFX07 (N/N/N/N)'' FROM DUAL
                      UNION SELECT ''012'',''012. RECALCULAR ICMS DE CUPOM (S/N/N/S)'' FROM DUAL
                      UNION SELECT ''013'',''013. Carregar Interface de Fornecedor (S/S/O/N)'' FROM DUAL
                      ---UNION SELECT ''014'',''014. Estorno de Credito/Debito Cesta Basica (S/S/N/N)'' FROM DUAL
                      UNION SELECT ''050'',''050. LIMPA LOGS MEIO MAGNETICO e SPED (O/O/S/N)'' FROM DUAL
                           '  );

        lib_proc.add_param ( pstr
                           , 'DATA 1'
                           , --P_DATA1
                            'DATE'
                           , 'TEXTBOX'
                           , 'N'
                           , NULL
                           , 'DD/MM/YYYY' );

        lib_proc.add_param ( pstr
                           , 'DATA 2'
                           , --P_DATA2
                            'DATE'
                           , 'TEXTBOX'
                           , 'N'
                           , NULL
                           , 'DD/MM/YYYY' );

        lib_proc.add_param ( pstr
                           , 'PARAMETRO 1'
                           , --P_PARAMETRO1
                            'VARCHAR2'
                           , 'TEXTBOX'
                           , 'N' );

        lib_proc.add_param (
                             pstr
                           , 'ESTABELECIMENTO '
                           , --P_CODESTAB
                            'VARCHAR2'
                           , 'MULTISELECT'
                           , 'N'
                           , NULL
                           , NULL
                           ,    '
                            SELECT A.COD_ESTAB,A.COD_ESTAB || '' - '' || B.COD_ESTADO || '' - '' || A.CGC || '' - '' || INITCAP(A.BAIRRO) || '' / '' || INITCAP(A.CIDADE)
                            FROM ESTABELECIMENTO A, ESTADO B
                            WHERE A.COD_EMPRESA = '''
                             || mcod_empresa
                             || '''
                            AND   B.IDENT_ESTADO = A.IDENT_ESTADO
                            ORDER BY CASE WHEN A.COD_ESTAB LIKE '''
                             || mcod_empresa
                             || '9%'' THEN ''0'' || A.COD_ESTAB ELSE ''1'' || B.COD_ESTADO || A.COD_ESTAB END
                           '
        );

        RETURN pstr;
    END; --FUNCTION PARAMETROS RETURN VARCHAR2 IS

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'EXECUTADOR DE SCRIPTS';
    END;

    FUNCTION tipo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Processo';
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
        RETURN 'PROCESSO QUE EXECUTA SCRIPTS SEM NECESSIDADE DE ACIONAR DBA. APENAS PARA USO TÉCNICO!';
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

    PROCEDURE loga ( p_texto VARCHAR2 )
    IS
        vtexto VARCHAR2 ( 1024 );
    BEGIN
        vtexto :=
            SUBSTR (    TO_CHAR ( SYSDATE
                                , 'DD/MM/YYYY HH24:MI:SS' )
                     || ' - '
                     || p_texto
                   , 1
                   , 1024 );
        lib_proc.add_log ( vtexto
                         , 1 );
        msafi.dsp_control.writelog ( 'INFO'
                                   , p_texto );
    END;

    FUNCTION executar ( p_senha VARCHAR2
                      , p_confirma VARCHAR2
                      , p_script VARCHAR2
                      , p_data1 DATE
                      , p_data2 DATE
                      , p_parametro1 VARCHAR2
                      , p_codestab lib_proc.vartab )
        RETURN INTEGER
    IS
        mproc_id INTEGER;
        iestab INTEGER;

        v_proc_status NUMBER := 0;
        v_s_proc_status VARCHAR2 ( 16 );
        v_date1 DATE;
        v_date2 DATE;
        v_char1_30 VARCHAR2 ( 30 );
        v_num01 NUMBER;
        v_bool01 BOOLEAN;
        v_cod_estab estabelecimento.cod_estab%TYPE;
        v_trace VARCHAR2 ( 50 );

        v_tabela VARCHAR2 ( 30 );
        v_calc_stats VARCHAR2 ( 1 );
        v_valid NUMBER;
        v_valid_hash NUMBER;
        v_valid_zero NUMBER;

        v_dbg VARCHAR2 ( 80 );

        v_text01 VARCHAR2 ( 100 );
        v_job_num NUMBER;
    BEGIN
        v_dbg := '01.' || $$plsql_unit || ' L.' || $$plsql_line;

        mcod_empresa := lib_parametros.recuperar ( 'EMPRESA' );

        IF mcod_empresa IS NULL THEN
            lib_proc.add_log ( 'Código da empresa deve ser informado como parâmetro global.'
                             , 0 );
            lib_proc.close;
            RETURN mproc_id;
        END IF;

        v_dbg := '02.' || $$plsql_unit || ' L.' || $$plsql_line;

        v_proc_status := 1; --EM PROCESSO
        -- CRIA PROCESSO
        mproc_id := lib_proc.new ( 'DSP_EXECUTA_SCRIPTS_CPROC' );

        --A SENHA SERVE SÓ PARA BLOQUEAR ACESSO PARA QUEM NÃO SABE O QUE ESTÁ FAZENDO...
        -- POR ISSO É FÁCIL DE DECIFRAR DE CABEÇA
        -- É O DIA ATUAL VEZES 2 MAIS 10  (EX. DIA 14 -> 14*2=28 + 10 = 38; A SENHA É "38"
        v_dbg := '03.' || $$plsql_unit || ' L.' || $$plsql_line;

        IF TRIM ( p_senha ) = TO_CHAR (     TO_NUMBER ( TO_CHAR ( SYSDATE
                                                                , 'DD' ) )
                                          * 2
                                        + 10
                                      , 'FM00' ) THEN
            v_dbg := '04.' || $$plsql_unit || ' L.' || $$plsql_line;
            msafi.dsp_control.createprocess ( 'CUST_EXECUTADOR' --P_I_PROCID            IN VARCHAR2             , --VARCHAR2(16)
                                            , 'CUSTOMIZADO MASTERSAF: EXECUTADOR DE SCRIPTS' --P_I_PROC_DESCR        IN VARCHAR2             , --VARCHAR2(64)
                                            , p_data1 --P_I_DATA_INI          IN DATE     DEFAULT NULL,
                                            , p_data2 --P_I_DATA_FIM          IN DATE     DEFAULT NULL,
                                            , p_script --P_I_DETALHES1         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                            , p_parametro1 --P_I_DETALHES2         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                            , p_codestab.COUNT --P_I_DETALHES3         IN VARCHAR2 DEFAULT NULL, --VARCHAR2(32)
                                            , NULL --P_I_DETALHES4         IN VARCHAR2 DEFAULT NULL  --VARCHAR2(32)
                                            , musuario --P_I_USER              IN VARCHAR2 DEFAULT NULL  --VARCHAR2(64)
                                                       );
            --------------------------------------------------------------------------------------------------------------
            v_dbg := '05.' || $$plsql_unit || ' L.' || $$plsql_line;

            --            IF P_SCRIPT = '001' THEN
            --                V_DBG := '06.' || $$plsql_unit || ' L.' || $$plsql_line;
            --                IF UPPER(NVL(P_CONFIRMA,'!@#$')) <> 'LIBERA' THEN
            --                    LOGA('PALAVRA DE CONFIRMAÇÃO ERRADA!');
            --                    LOGA('Você deve digitar a primeira palavra do script (por exemplo: "LIBERA" OU "TRUNCAR")');
            --                    V_PROC_STATUS := 4; --ERRO
            --                ELSE
            --                    LOGA('001. LIBERA TRAVA INTERDADOS (N/N/N/N)');
            --                    LOGA(' ');
            --                    LOGA('Data inicial     (Não utilizado)');
            --                    LOGA('Data final       (Não utilizado)');
            --                    LOGA('Parametro 1      (Não utilizado)');
            --                    LOGA('Estabelecimentos (Não utilizado)');
            --                    LOGA(' ');
            --
            --                    V_NUM01:=0; --PARA ESTE SCRIPT, V_NUM01 TEM FUNÇÃO DE VERIFICAR SE A MS_TRAVA TEM LINHAS
            --                    SELECT COUNT(1) INTO V_NUM01 FROM MSAFI.MS_TRAVA;
            --
            --                    IF V_NUM01 > 0 THEN
            --                        DELETE FROM MSAFI.MS_TRAVA;
            --                        LOGA('FIM DO SCRIPT; MS_TRAVA LIBERADA!');
            --                        V_PROC_STATUS := 2; --SUCESSO
            --                    ELSE
            --                        LOGA('FIM DO SCRIPT; MS_TRAVA JÁ ESTAVA LIBERADA. NADA FOI FEITO!');
            --                        V_PROC_STATUS := 3; --AVISOS
            --                    END IF;
            --                END IF; --IF UPPER(NVL(P_CONFIRMA,'!@#$')) <> 'LIBERA' THEN
            --------------------------------------------------------------------------------------------------------------
            IF p_script = '002' THEN
                v_dbg := '07.' || $$plsql_unit || ' L.' || $$plsql_line;
                loga ( 'INICIO DO PROCESSAMENTO; SCRIPT: LIMPA APURAÇÃO EFD PIS/COFINS' );
                loga (
                       'ESTE SCRIPT ESTÁ DESABILITADO! Favor seguir o procedimento correto para limpar refazer a apuração do PIS/COFINS'
                );
                loga ( 'FIM DO SCRIPT; NADA FOI FEITO!' );
            /*
                            V_NUM01:=0; --PARA ESTE SCRIPT, V_NUM01 TEM FUNÇÃO DE CONTAR QUANTOS ESTABELECIMENTOS FORAM ATUALIZADOS
                            IESTAB := P_CODESTAB.FIRST;
                            WHILE IESTAB IS NOT NULL LOOP
                                V_BOOL01:=FALSE; --PARA ESTE SCRIPT V_BOOL01 TEM FUNÇÃO DE CONFIRMAR QUE O UPDATE OCORREU COM SUCESSO
                                V_COD_ESTAB := P_CODESTAB(IESTAB);
                                BEGIN
                                    --- PARA NÃO EXCLUIR DE VEZ A LINHA, E PARA EVITAR ERRO DE DUPLICATE KEY; ALTERAMOS O NOME DA EMPRESA PARA O ID DA LINHA
                                    UPDATE EPC_APURACAO
                                    SET COD_EMPRESA=ID_REG
                                    WHERE COD_EMPRESA       = MCOD_EMPRESA
                                    AND   COD_ESTAB         = V_COD_ESTAB
                                    AND   IND_SITUACAO_APUR = 1
                                    AND   DAT_APUR_INI      = P_DATA1;
                                    V_BOOL01 := TRUE;
                                EXCEPTION WHEN OTHERS THEN
                                    V_BOOL01 := FALSE;
                                END;

                                IF NOT V_BOOL01 THEN
                                    LOGA('ERRO #1105241547 [' || MCOD_EMPRESA || '|' || V_COD_ESTAB || '|' || TO_CHAR(P_DATA1,'DD/MM/YYYY') || ']:' || SQLCODE || '-' || SUBSTR(SQLERRM,1,100));
                                    V_PROC_STATUS := 4; --ERRO
                                ELSE
                                    IF (SQL%ROWCOUNT)>0 THEN
                                        LOGA('OK! [' || MCOD_EMPRESA || '|' || V_COD_ESTAB || '|' || TO_CHAR(P_DATA1,'DD/MM/YYYY') || ']: [' || SQL%ROWCOUNT || ']');
                                        V_NUM01:=V_NUM01+1;
                                    ELSE
                                        LOGA('NENHUMA LINHA ALTERADA! [' || MCOD_EMPRESA || '|' || V_COD_ESTAB || '|' || TO_CHAR(P_DATA1,'DD/MM/YYYY') || ']');
                                        V_PROC_STATUS := 3; --AVISOS
                                    END IF;
                                END IF; --IF NOT V_BOOL01 THEN ... ELSE ...

                                --PRÓXIMO ESTABELECIMENTO
                                IESTAB := P_CODESTAB.NEXT(IESTAB);
                            END LOOP;

                            IF V_NUM01 > 0 THEN
                                LOGA('FIM DO SCRIPT; APURAÇÃO LIMPA PARA [' || V_NUM01 || '] ESTABELECIMENTOS. SUCESSO!');
                                IF V_PROC_STATUS = 1 THEN
                                    V_PROC_STATUS := 2; --SUCESSO
                                END IF;
                            ELSE
                                LOGA('FIM DO SCRIPT; NADA FOI FEITO!');
                                IF V_PROC_STATUS = 1 THEN
                                    V_PROC_STATUS := 3; --AVISOS
                                END IF;
                            END IF; --*/
            --------------------------------------------------------------------------------------------------------------
            ELSIF p_script = '003' THEN
                v_dbg := '08.' || $$plsql_unit || ' L.' || $$plsql_line;
                loga ( 'INICIO DO PROCESSAMENTO; SCRIPT: SCRIPTS POS CARGA (ANTES DA IMPORTAÇÃO)' );
                loga ( 'Data 1: [' || p_data1 || ']' );
                loga ( 'Data 2: [' || p_data2 || ']' );
                loga ( 'ESTE SCRIPT ESTÁ DESABILITADO!' );
                loga ( 'Este foi criado para correções temporárias na homologação do EFD PIS/COFINS' );
                loga ( 'FIM DO SCRIPT; NADA FOI FEITO!' );
            /*

            IESTAB := P_CODESTAB.FIRST;
            WHILE IESTAB IS NOT NULL LOOP
                V_COD_ESTAB := P_CODESTAB(IESTAB);
                V_TRACE := '-';
                BEGIN
                    IF V_COD_ESTAB IN ('DSP901','DSP902','DSP903') then
                        V_TRACE := V_TRACE || '1';
                        UPDATE SAFX08
                        SET COD_CFO             = '1209',
                            COD_SITUACAO_PIS    = '98',
                            COD_SITUACAO_COFINS = '98'
                        WHERE COD_EMPRESA = MCOD_EMPRESA
                        and COD_ESTAB = V_COD_ESTAB
                        AND COD_FIS_JUR IN ('DSP901-1','DSP902-1','DSP903-1')
                        AND COD_ESTAB <> SUBSTR(COD_FIS_JUR,1,6)
                        AND DATA_FISCAL BETWEEN TO_CHAR(P_DATA1,'YYYYMMDD') AND TO_CHAR(P_DATA2,'YYYYMMDD')
                        AND TRIM(REPLACE(COD_CFO,'@','')) IS NULL;
                        commit;
                    END IF;

                    V_TRACE := V_TRACE || '2';
                    update safx08
                    set cod_cfo='1910'
                    WHERE COD_EMPRESA = MCOD_EMPRESA
                    and COD_ESTAB = V_COD_ESTAB
                    and movto_e_s='1'
                    AND DATA_FISCAL BETWEEN TO_CHAR(P_DATA1,'YYYYMMDD') AND TO_CHAR(P_DATA2,'YYYYMMDD')
                    and cod_cfo='5910';
                    commit;

                    V_TRACE := V_TRACE || '3';
                    update safx08
                    set cod_cfo='1949'
                    WHERE COD_EMPRESA = MCOD_EMPRESA
                    and COD_ESTAB = V_COD_ESTAB
                    and movto_e_s='1'
                    AND DATA_FISCAL BETWEEN TO_CHAR(P_DATA1,'YYYYMMDD') AND TO_CHAR(P_DATA2,'YYYYMMDD')
                    and cod_cfo='5949';
                    commit;

                    V_TRACE := V_TRACE || '4';
                    update safx08
                    set VLR_PIS_TRIB =     replace(to_char((to_number(vlr_contab_item)/100/100) * 1.65,'fm00000000000000D00','NLS_NUMERIC_CHARACTERS=.,'),'.','')  ,
                        VLR_COFINS_TRIB =  replace(to_char((to_number(vlr_contab_item)/100/100) * 7.6 ,'fm00000000000000D00','NLS_NUMERIC_CHARACTERS=.,'),'.','')  ,
                        VLR_PIS =          replace(to_char((to_number(vlr_contab_item)/100/100) * 1.65,'fm00000000000000D00','NLS_NUMERIC_CHARACTERS=.,'),'.','')  ,
                        VLR_COFINS =       replace(to_char((to_number(vlr_contab_item)/100/100) * 7.6 ,'fm00000000000000D00','NLS_NUMERIC_CHARACTERS=.,'),'.','')  ,
                        VLR_ALIQ_PIS =     '016500'                                    ,
                        VLR_ALIQ_COFINS =  '076000'                                    ,
                        VLR_BASE_PIS =     vlr_contab_item                             ,
                        VLR_BASE_COFINS =  vlr_contab_item
                    --select * from safx08
                    WHERE COD_EMPRESA = MCOD_EMPRESA
                    and COD_ESTAB = V_COD_ESTAB
                    AND DATA_FISCAL BETWEEN TO_CHAR(P_DATA1,'YYYYMMDD') AND TO_CHAR(P_DATA2,'YYYYMMDD')
                    and cod_situacao_pis = '50'
                    and trim(replace(replace(vlr_aliq_cofins,'@',''),'0','')) is null
                    and cod_cfo <> '1949';
                    commit;

                    V_TRACE := V_TRACE || '5';
                    IF V_COD_ESTAB IN ('DSP901','DSP902','DSP903') then
                        V_TRACE := V_TRACE || '6';
                    ---Script 1 (Carlos) - Alteração de itens (aparelhos de barbear) que foram transferidos após entrada errada estao tributando ICMS-ST; mas são revenda.
                        UPDATE SAFX08
                        SET COD_SITUACAO_B = '00',
                            VLR_CONTAB_ITEM = VLR_ITEM,
                            VLR_SUBST_ICMS = '0000000000000000',
                            TRIB_ICMS = 1
                        WHERE COD_EMPRESA = MCOD_EMPRESA
                        and COD_ESTAB = V_COD_ESTAB
                        AND MOVTO_E_S = '9'
                        AND DATA_FISCAL BETWEEN TO_CHAR(P_DATA1,'YYYYMMDD') AND TO_CHAR(P_DATA2,'YYYYMMDD')
                        AND COD_CFO IN ('5152','5102')
                        AND COD_SITUACAO_B = '60';
                        commit;

                        V_TRACE := V_TRACE || '7';
                        ---Script 2 (Carlos) - ND010 Correção de itens com protocolo especifico de um estado que o People gera para todos os estados
                        IF V_COD_ESTAB ='DSP902' THEN
                            V_TRACE := V_TRACE || '8';
                            UPDATE SAFX08
                            SET COD_CFO = '6409'
                            WHERE COD_EMPRESA = MCOD_EMPRESA
                            AND COD_ESTAB = V_COD_ESTAB
                            AND MOVTO_E_S = '9'
                            AND DATA_FISCAL BETWEEN TO_CHAR(P_DATA1,'YYYYMMDD') AND TO_CHAR(P_DATA2,'YYYYMMDD')
                            AND COD_CFO = '6152'
                            AND COD_SITUACAO_B = '10';
                            commit;

                            V_TRACE := V_TRACE || '9';

                            UPDATE SAFX08
                            SET COD_CFO = '6152'
                            WHERE COD_EMPRESA = MCOD_EMPRESA
                            AND COD_ESTAB = V_COD_ESTAB
                            AND MOVTO_E_S = '9'
                            AND DATA_FISCAL BETWEEN TO_CHAR(P_DATA1,'YYYYMMDD') AND TO_CHAR(P_DATA2,'YYYYMMDD')
                            AND COD_CFO = '6409'
                            AND COD_SITUACAO_B = '00';
                            commit;

                            V_TRACE := V_TRACE || 'A';
                        END IF;

                        V_TRACE := V_TRACE || 'B';
                        ---Script 3 (Carlos) - Correção de NFs com CFOP 5409 e situação 41. Alteramos o CST para 60 e movemos a base do ICMS de isenta para outras.
                        IF V_COD_ESTAB ='DSP903' THEN
                            V_TRACE := V_TRACE || 'C';
                            UPDATE SAFX08
                            SET COD_SITUACAO_B = '60',
                                TRIB_ICMS = 3
                            WHERE COD_EMPRESA = MCOD_EMPRESA
                            AND COD_ESTAB = V_COD_ESTAB
                            AND MOVTO_E_S = '9'
                            AND DATA_FISCAL BETWEEN TO_CHAR(P_DATA1,'YYYYMMDD') AND TO_CHAR(P_DATA2,'YYYYMMDD')
                            AND COD_CFO = '5409'
                            AND TRIB_ICMS = 2
                            AND COD_SITUACAO_B = '41';
                            commit;

                            V_TRACE := V_TRACE || 'D';
                        END IF;

                        V_TRACE := V_TRACE || 'E';
                    END IF; -- IF V_COD_ESTAB IN ('DSP901','DSP902','DSP903') then
                    ---Script 4 (EFD-PIS/COFINS) - Correção das linhas com natureza da operação inválida para CST04 (erro introduzido propositalmente na interface
                    ------------------------------ para pegar erros de cadastro)
                    V_TRACE := V_TRACE || 'F';
                    V_BOOL01 := FALSE;
                    FOR C2 IN (SELECT COD_PRODUTO , COD_NBM, COUNT(0) AS NUM_ERROS
                               FROM SAFX08
                               WHERE COD_EMPRESA = MCOD_EMPRESA
                               AND   COD_ESTAB   = V_COD_ESTAB
                               AND DATA_FISCAL BETWEEN TO_CHAR(P_DATA1,'YYYYMMDD') AND TO_CHAR(P_DATA2,'YYYYMMDD')
                               AND   COD_NAT_REC = 'ER2'
                               GROUP BY COD_PRODUTO , COD_NBM)
                    LOOP
                        IF NOT V_BOOL01 THEN
                            V_BOOL01:=TRUE;
                            LOGA('Inconsistencias corrigidas de CST 04 com natureza de operação);
                            LOGA('[COD_PRODUTO]    [COD_NBM]   [NUM_ERROS]);
                        END IF;
                        LOGA('[' || C2.COD_PRODUTO || ']   [' || C2.COD_NBM || ']  [' || C2.NUM_ERROS || ']);
                    END LOOP;
                    V_TRACE := V_TRACE || 'G';
                    if V_BOOL01 then
                        V_TRACE := V_TRACE || 'H';
                        UPDATE SAFX08
                        SET COD_NAT_REC = ''
                        WHERE COD_EMPRESA = MCOD_EMPRESA
                        AND   COD_ESTAB   = V_COD_ESTAB
                        AND DATA_FISCAL BETWEEN TO_CHAR(P_DATA1,'YYYYMMDD') AND TO_CHAR(P_DATA2,'YYYYMMDD')
                        AND   COD_NAT_REC = 'ER2'
                        ;
                        commit;
                        V_TRACE := V_TRACE || 'I';
                    end if;
                    V_TRACE := V_TRACE || 'J';
                exception
                when others then
                        LOGA('ERRO! [' || V_TRACE || ']-[' || MCOD_EMPRESA || '|' || V_COD_ESTAB || '|' || TO_CHAR(P_DATA1,'DD/MM/YYYY') || '|' || TO_CHAR(P_DATA2,'DD/MM/YYYY') || '] - [' ||SQLCODE || '][' || substr(SQLERRM, 1, 50)||']');
                        V_PROC_STATUS := 4; --ERRO
                end;

                --PRÓXIMO ESTABELECIMENTO
                IESTAB := P_CODESTAB.NEXT(IESTAB);
            END LOOP;

            LOGA('FIM DO SCRIPT; EXECUTADO PARA OS ESTABELECIMENTOS. SUCESSO!');
            IF V_PROC_STATUS = 1 THEN
                V_PROC_STATUS := 2; --SUCESSO
            END IF;
            */
            --------------------------------------------------------------------------------------------------------------
            ELSIF p_script = '004' THEN
                v_dbg := '09.' || $$plsql_unit || ' L.' || $$plsql_line;

                IF UPPER ( NVL ( p_confirma, '!@#$' ) ) <> 'TRUNCAR' THEN
                    loga ( 'PALAVRA DE CONFIRMAÇÃO ERRADA!' );
                    loga ( 'Você deve digitar a primeira palavra do script (por exemplo: "LIBERA" OU "TRUNCAR")' );
                    v_proc_status := 4; --ERRO
                ELSE
                    loga ( '004. TRUNCAR TABELA (N/N/S/N)' );
                    loga ( ' ' );
                    loga ( 'Data inicial     (Não utilizado)' );
                    loga ( 'Data final       (Não utilizado)' );
                    loga ( 'Parametro 1      (Sim, obrigatório): ' || p_parametro1 );
                    loga ( 'Estabelecimentos (Não utilizado)' );
                    loga ( ' ' );

                    BEGIN
                        SELECT a.tabela
                             , a.calc_stats
                             , a.valid
                             , dbms_utility.get_hash_value ( a.tabela || '+SAL'
                                                           , 2
                                                           , 134217728 )
                                   AS valid_hash
                             ,   a.valid
                               - dbms_utility.get_hash_value ( a.tabela || '+SAL'
                                                             , 2
                                                             , 134217728 )
                                   AS valid_zero
                          INTO v_tabela
                             , v_calc_stats
                             , v_valid
                             , v_valid_hash
                             , v_valid_zero
                          FROM msafi.dsp_tabelas_truncaveis a
                         WHERE a.tabela = p_parametro1;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            v_tabela := NULL;
                    END;

                    --SE NAO É UMA TABELA X, ESTÁ NA TABELA DE TABELAS TRUNCAVEIS E FOI INSERIDA CORRETAMENTE (VALIDAÇÃO DO HASH, POR SEGURANÇA, SÓ QUEM SABE PODE INSERIR)
                    IF ( ( p_parametro1 NOT LIKE 'X%' )
                    AND ( v_tabela IS NOT NULL )
                    AND ( v_valid_zero = 0 ) ) THEN
                        loga ( 'Iniciando processo [' || p_parametro1 || ']' );

                        IF ( v_calc_stats = 'Y' ) THEN
                            BEGIN
                                loga ( 'Iniciando STATISTICAS: OWNER: MSAF, Tabela: [' || p_parametro1 || ']' );
                                dbms_stats.gather_table_stats ( 'MSAF'
                                                              , p_parametro1 );
                            EXCEPTION
                                WHEN OTHERS THEN
                                    loga (    'ERRO NA EXECUÇÃO DAS ESTATÍSTICAS, ['
                                           || p_parametro1
                                           || '] ['
                                           || SQLCODE
                                           || '-'
                                           || SUBSTR ( SQLERRM
                                                     , 1
                                                     , 50 )
                                           || ']' );
                                    v_proc_status := 4;
                            END;
                        END IF; --IF (V_CALC_STATS = 'Y') THEN

                        IF ( v_proc_status <> 4 ) THEN
                            BEGIN
                                loga ( 'Iniciando TRUNCATE: [' || p_parametro1 || ']' );

                                EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || p_parametro1 || ' REUSE STORAGE';

                                v_proc_status := 2; --SUCESSO
                                loga ( 'Fim do script' );
                            EXCEPTION
                                WHEN OTHERS THEN
                                    loga (    'ERRO NA EXECUÇÃO DO TRUNCATE, ['
                                           || p_parametro1
                                           || '] ['
                                           || SQLCODE
                                           || '-'
                                           || SUBSTR ( SQLERRM
                                                     , 1
                                                     , 50 )
                                           || ']' );
                                    v_proc_status := 4;
                            END;
                        END IF; --IF (V_PROC_STATUS <> 4) THEN
                    ELSE
                        loga (
                                  'ERRO NO PARAMETRO 1, NAO É PERMITIDO TRUNCAR ESTA TABELA, VERIFIQUE O NOME ['
                               || p_parametro1
                               || ']'
                        );
                    END IF;
                END IF; --IF UPPER(NVL(P_CONFIRMA,'!@#$')) <> 'TRUNCAR' THEN
            --------------------------------------------------------------------------------------------------------------
            ELSIF p_script = '005' THEN
                v_dbg := '10.' || $$plsql_unit || ' L.' || $$plsql_line;

                IF UPPER ( NVL ( p_confirma, '!@#$' ) ) <> 'CORRIGIR' THEN
                    loga ( 'PALAVRA DE CONFIRMAÇÃO ERRADA!' );
                    loga ( 'Você deve digitar a primeira palavra do script (por exemplo: "LIBERA" OU "TRUNCAR")' );
                    v_proc_status := 4; --ERRO
                ELSE
                    loga ( '005. CORRIGIR SAFX2087 (N/N/N/N)' );
                    loga ( ' ' );
                    loga ( 'Data inicial     (Não utilizado)' );
                    loga ( 'Data final       (Não utilizado)' );
                    loga ( 'Parametro 1      (Não utilizado)' );
                    loga ( 'Estabelecimentos (Não utilizado)' );
                    loga ( ' ' );

                    UPDATE safx2087
                       SET cod_tipo_ecf = '@'
                     WHERE cod_tipo_ecf = '6000';

                    loga ( '01 - [COD_TIPO_ECF=6000 -> @] [' || SQL%ROWCOUNT || ']' );
                    COMMIT;


                    UPDATE safx2087
                       SET cod_marca_ecf = 'ZPM'
                     WHERE cod_modelo_ecf LIKE 'ZP%'
                       AND TRIM ( REPLACE ( cod_marca_ecf
                                          , '@'
                                          , '' ) )
                               IS NULL;

                    loga ( '02 - [COD_MODELO_ECF=@ -> ZPM] [' || SQL%ROWCOUNT || ']' );
                    COMMIT;

                    UPDATE safx2087
                       SET cod_marca_ecf = 'ITAUTEC'
                     WHERE TRIM ( cod_modelo_ecf ) = 'QW PRINTER'
                       AND TRIM ( REPLACE ( cod_marca_ecf
                                          , '@'
                                          , '' ) )
                               IS NULL;

                    loga ( '03 - [COD_MARCA_ECF=@ -> ITAUTEC] [' || SQL%ROWCOUNT || ']' );
                    COMMIT;

                    UPDATE safx2087
                       SET cod_modelo_ecf = 'ZPM-400'
                     WHERE TRIM ( cod_modelo_ecf ) LIKE 'ZPM%ZPM-400';

                    loga ( '04 - [COD_MODELO_ECF like ZPM%ZPM-400 -> ZPM-400] [' || SQL%ROWCOUNT || ']' );
                    COMMIT;

                    -- Não precisamos mais deste script
                    --UPDATE SAFX2087
                    --SET COD_MARCA_ECF=TRIM(COD_MARCA_ECF),
                    --    COD_MODELO_ECF = TRIM(COD_MODELO_ECF);
                    --LOGA('05 - [TRIM(COD_MARCA_ECF) TRIM(COD_MODELO_ECF)] [' || SQL%ROWCOUNT || ']');
                    --COMMIT;

                    UPDATE safx2087
                       SET cod_marca_ecf = 'ITAUTEC'
                     WHERE TRIM ( cod_marca_ecf ) LIKE '%ITAUTEC%'
                       AND cod_marca_ecf <> 'ITAUTEC';

                    loga ( '05 - [COD_MARCA_ECF like %ITAUTEC% -> ITAUTEC] [' || SQL%ROWCOUNT || ']' );
                    COMMIT;

                    UPDATE safx2087
                       SET cod_marca_ecf = 'SWEDA'
                     WHERE TRIM ( cod_modelo_ecf ) = 'IF ST2500'
                       AND TRIM ( REPLACE ( cod_marca_ecf
                                          , '@'
                                          , '' ) )
                               IS NULL;

                    loga ( '06 - [COD_MARCA_ECF=@ -> SWEDA] [' || SQL%ROWCOUNT || ']' );
                    COMMIT;

                    UPDATE safx2087
                       SET cod_marca_ecf = 'ZPM'
                         , cod_modelo_ecf = 'ZPM-300'
                     WHERE cod_fabricacao_ecf LIKE 'ZP%'
                       AND ( TRIM ( REPLACE ( cod_marca_ecf
                                            , '@'
                                            , '' ) )
                                IS NULL
                         OR TRIM ( REPLACE ( cod_modelo_ecf
                                           , '@'
                                           , '' ) )
                                IS NULL );

                    loga ( '07 - [COD_MARCA_ECF e COD_MODELO em branco -> ZPM] [' || SQL%ROWCOUNT || ']' );
                    COMMIT;

                    UPDATE safx2087
                       SET cod_marca_ecf = 'SWEDA'
                         , cod_modelo_ecf = 'IF ST2500'
                     WHERE cod_fabricacao_ecf LIKE 'SW%'
                       AND ( TRIM ( REPLACE ( cod_marca_ecf
                                            , '@'
                                            , '' ) )
                                IS NULL
                         OR TRIM ( REPLACE ( cod_modelo_ecf
                                           , '@'
                                           , '' ) )
                                IS NULL );

                    loga ( '08 - [COD_MARCA_ECF e COD_MODELO em branco -> SWEDA] [' || SQL%ROWCOUNT || ']' );
                    COMMIT;

                    UPDATE safx2087
                       SET cod_marca_ecf = 'ITAUTEC'
                         , cod_modelo_ecf = 'QW PRINTER'
                     WHERE cod_fabricacao_ecf LIKE 'IP%'
                       AND ( TRIM ( REPLACE ( cod_marca_ecf
                                            , '@'
                                            , '' ) )
                                IS NULL
                         OR TRIM ( REPLACE ( cod_modelo_ecf
                                           , '@'
                                           , '' ) )
                                IS NULL );

                    loga ( '09 - [COD_MARCA_ECF e COD_MODELO em branco -> ITAU] [' || SQL%ROWCOUNT || ']' );
                    COMMIT;

                    v_proc_status := 2; --SUCESSO
                    loga ( 'Fim do script' );
                END IF; --IF UPPER(NVL(P_CONFIRMA,'!@#$')) <> 'CORRIGIR' THEN
            --------------------------------------------------------------------------------------------------------------
            ELSIF p_script = '006' THEN
                v_dbg := '11.' || $$plsql_unit || ' L.' || $$plsql_line;

                IF UPPER ( NVL ( p_confirma, '!@#$' ) ) <> 'REPLICAR' THEN
                    loga ( 'PALAVRA DE CONFIRMAÇÃO ERRADA!' );
                    loga ( 'Você deve digitar a primeira palavra do script (por exemplo: "LIBERA" OU "TRUNCAR")' );
                    v_proc_status := 4; --ERRO
                ELSE
                    loga ( '006. REPLICAR CADASTROS PARA CUPOM FISCAL (N/N/N/N)' );
                    loga ( ' ' );
                    loga ( 'Data inicial     (Não utilizado)' );
                    loga ( 'Data final       (Não utilizado)' );
                    loga ( 'Parametro 1      (Não utilizado)' );
                    loga ( 'Estabelecimentos (Não utilizado)' );
                    loga ( ' ' );

                    --REPLICA_CADASTRO_TIPO_DOC_CST_F100
                    INSERT INTO epc_tp_doc_cstopnat
                        SELECT DISTINCT a.cod_empresa
                                      , b.cod_estab
                                      , a.data_valid
                                      , a.ident_docto
                                      , a.tp_operacao
                                      , a.ind_trib_pis
                                      , a.cod_trib_pis
                                      , a.ind_trib_cofins
                                      , a.cod_trib_cofins
                                      , a.nat_base_cred
                                      , a.dt_valid_pis
                                      , a.dt_valid_cofins
                          FROM epc_tp_doc_cstopnat a
                             , estabelecimento b
                         WHERE NOT EXISTS
                                   (SELECT 1
                                      FROM epc_tp_doc_cstopnat sa
                                     WHERE sa.cod_empresa = a.cod_empresa
                                       AND sa.cod_estab = b.cod_estab
                                       AND sa.data_valid = a.data_valid
                                       AND sa.ident_docto = a.ident_docto);

                    loga ( '01 - [REPLICA_CADASTRO_TIPO_DOC_CST_F100] [' || SQL%ROWCOUNT || ']' );
                    COMMIT;

                    --REPLICA CADASTRO TOTALIZADOR_PARCIAL_ECF (X996_TOTALIZADOR_PARCIAL_ECF)
                    INSERT INTO x996_totalizador_parcial_ecf ( ident_totalizador_ecf
                                                             , cod_empresa
                                                             , cod_estab
                                                             , grupo_modelo
                                                             , cod_modelo
                                                             , cod_caixa_ecf
                                                             , cod_totalizador_ecf
                                                             , valid_totalizador_ecf
                                                             , dsc_totalizador_ecf
                                                             , num_seq_totalizador
                                                             , dsc_sit_tributaria
                                                             , vlr_aliq
                                                             , ident_situacao_a
                                                             , ident_situacao_b
                                                             , ident_cfo
                                                             , cod_cfps
                                                             , cod_trib_iss
                                                             , num_processo
                                                             , ind_gravacao )
                        SELECT   ROWNUM
                               + ( SELECT MAX ( ident_totalizador_ecf )
                                     FROM x996_totalizador_parcial_ecf )
                             , a.cod_empresa
                             , b.cod_estab
                             , a.grupo_modelo
                             , a.cod_modelo
                             , b.cod_caixa_ecf
                             , a.cod_totalizador_ecf
                             , b.valid_caixa_ecf
                             , a.dsc_totalizador_ecf
                             , a.num_seq_totalizador
                             , a.dsc_sit_tributaria
                             , a.vlr_aliq
                             , a.ident_situacao_a
                             , a.ident_situacao_b
                             , a.ident_cfo
                             , a.cod_cfps
                             , a.cod_trib_iss
                             , 123
                             , 7
                          FROM (SELECT DISTINCT cod_empresa
                                              , grupo_modelo
                                              , cod_modelo
                                              , cod_totalizador_ecf
                                              , dsc_totalizador_ecf
                                              , num_seq_totalizador
                                              , dsc_sit_tributaria
                                              , vlr_aliq
                                              , ident_situacao_a
                                              , ident_situacao_b
                                              , ident_cfo
                                              , cod_cfps
                                              , cod_trib_iss
                                  FROM x996_totalizador_parcial_ecf
                                 WHERE cod_empresa <> 'DSP' --Replicaremos qualquer cadastro feito na Pacheco, mas na DSP só do caixa 1 da loja 4, porque tem sujeira em outros cadastros
                                    OR ( cod_empresa = 'DSP'
                                    AND cod_estab = 'DSP004'
                                    AND grupo_modelo = '1900'
                                    AND cod_modelo = '2D'
                                    AND cod_caixa_ecf = '4' )) a
                             , (SELECT   cod_empresa
                                       , cod_estab
                                       , grupo_modelo
                                       , cod_modelo
                                       , cod_caixa_ecf
                                       , MIN ( valid_caixa_ecf ) AS valid_caixa_ecf
                                    FROM x2087_equipamento_ecf
                                GROUP BY cod_empresa
                                       , cod_estab
                                       , grupo_modelo
                                       , cod_modelo
                                       , cod_caixa_ecf) b
                         WHERE ( a.cod_empresa
                               , b.cod_estab
                               , a.grupo_modelo
                               , a.cod_modelo
                               , b.cod_caixa_ecf
                               , a.cod_totalizador_ecf ) NOT IN ( SELECT cod_empresa
                                                                       , cod_estab
                                                                       , grupo_modelo
                                                                       , cod_modelo
                                                                       , cod_caixa_ecf
                                                                       , cod_totalizador_ecf
                                                                    FROM x996_totalizador_parcial_ecf );

                    loga ( '02 - [REPLICA_CADASTRO_TOTALIZADOR_PARCIAL_ECF.01] [' || SQL%ROWCOUNT || ']' );
                    COMMIT;


                    UPDATE ident_substituto
                       SET prox_ident_subst =
                               ( SELECT MAX ( ident_totalizador_ecf ) + 1
                                   FROM x996_totalizador_parcial_ecf )
                     WHERE nome_coluna = 'IDENT_TOTALIZADOR_ECF'
                       AND nome_tabela = 'X996_TOTALIZADOR_PARCIAL_ECF';

                    loga ( '03 - [REPLICA_CADASTRO_TOTALIZADOR_PARCIAL_ECF.02] [' || SQL%ROWCOUNT || ']' );
                    COMMIT;

                    FOR c1 IN rel_006 LOOP
                        loga ( '04 - [INSERT SELECT] [' || c1.cod_empresa || ' - ' || c1.cod_estab || ']' );

                        INSERT INTO x99_totalizador_ecf ( cod_empresa
                                                        , cod_estab
                                                        , grupo_modelo
                                                        , cod_modelo
                                                        , cod_caixa_ecf
                                                        , ind_tipo_obrig
                                                        , cod_totalizador_ecf
                                                        , valid_x99_tot_ecf
                                                        , cod_totalizador_obrig
                                                        , num_processo
                                                        , ind_gravacao )
                            SELECT DISTINCT cod_empresa
                                          , cod_estab
                                          , grupo_modelo
                                          , cod_modelo
                                          , cod_caixa_ecf
                                          , '2'
                                          , cod_totalizador_ecf
                                          , valid_totalizador_ecf
                                          , CASE
                                                WHEN SUBSTR ( cod_totalizador_ecf
                                                            , 1
                                                            , 1 ) IN ( 'F'
                                                                     , 'I'
                                                                     , 'N'
                                                                     , 'T' ) THEN
                                                    SUBSTR ( cod_totalizador_ecf
                                                           , 1
                                                           , 1 )
                                                ELSE
                                                    cod_totalizador_ecf
                                            END
                                                AS cod_totalizador_obrig
                                          , 0
                                          , 1
                              FROM x996_totalizador_parcial_ecf a
                             WHERE NOT EXISTS
                                       (SELECT 1
                                          FROM x99_totalizador_ecf b
                                         WHERE b.cod_empresa = a.cod_empresa
                                           AND b.cod_estab = a.cod_estab
                                           AND b.grupo_modelo = a.grupo_modelo
                                           AND b.cod_modelo = a.cod_modelo
                                           AND b.cod_caixa_ecf = a.cod_caixa_ecf
                                           AND b.cod_totalizador_ecf = a.cod_totalizador_ecf)
                               AND a.cod_empresa = c1.cod_empresa
                               AND a.cod_estab = c1.cod_estab
                               AND a.cod_totalizador_ecf <> '1';
                    END LOOP;

                    loga ( '05 - [REPLICA_CADASTRO_TOTALIZADOR_PARCIAL_ECF.04] [' || SQL%ROWCOUNT || ']' );
                    COMMIT;

                    /* A tabela DWT_GRUPO_BENS_ATIVO não existe mais
                    --REPLICA_GRUPO_BENS_ATIVO
                    INSERT INTO dwt_grupo_bens_ativo
                    SELECT dwt_grupo_bens_ativo_seq.nextval,
                    a.cod_empresa,
                    a.cod_estab,
                    b.cod_grupo_bem,
                    b.data_valid_grupo,
                    b.ind_ident_grupo,
                    b.desc_compl_grupo
                    FROM estabelecimento a,
                      (select distinct cod_grupo_bem, data_valid_grupo,
                                       ind_ident_grupo, desc_compl_grupo
                       from dwt_grupo_bens_ativo) b
                    where not exists (select 1
                                      from dwt_grupo_bens_ativo sb
                                      where sb.cod_empresa=a.cod_empresa
                                      and   sb.cod_estab=a.cod_estab);
                    LOGA('06 - [REPLICA_GRUPO_BENS_ATIVO] [' || SQL%ROWCOUNT || ']');
                    COMMIT;
                    */

                    v_proc_status := 2; --SUCESSO
                    loga ( 'Fim do script' );
                END IF; --IF UPPER(NVL(P_CONFIRMA,'!@#$')) <> 'REPLICAR' THEN
            --------------------------------------------------------------------------------------------------------------
            ELSIF p_script = '007' THEN
                v_dbg := '12.' || $$plsql_unit || ' L.' || $$plsql_line;

                IF UPPER ( NVL ( p_confirma, '!@#$' ) ) <> 'TRUNCAR' THEN
                    loga ( 'PALAVRA DE CONFIRMAÇÃO ERRADA!' );
                    loga ( 'Você deve digitar a primeira palavra do script (por exemplo: "LIBERA" OU "TRUNCAR")' );
                    v_proc_status := 4; --ERRO
                ELSE
                    loga ( '007. TRUNCAR TABELAS MEIO MAGNETICO CAT17 (N/N/N/N)' );
                    loga ( ' ' );
                    loga ( 'Data inicial     (Não utilizado)' );
                    loga ( 'Data final       (Não utilizado)' );
                    loga ( 'Parametro 1      (Não utilizado)' );
                    loga ( 'Estabelecimentos (Não utilizado)' );
                    loga ( ' ' );

                    EXECUTE IMMEDIATE 'TRUNCATE TABLE EST_SP_CAT17_MM2';

                    EXECUTE IMMEDIATE 'TRUNCATE TABLE EST_SP_CAT17_MM3B';

                    EXECUTE IMMEDIATE 'TRUNCATE TABLE EST_SP_CAT17_MM3C';

                    EXECUTE IMMEDIATE 'ALTER TABLE EST_SP_CAT17_MM3B DISABLE CONSTRAINT FK_SAF_1186';

                    EXECUTE IMMEDIATE 'ALTER TABLE EST_SP_CAT17_MM3C DISABLE CONSTRAINT FK_SAF_1187';

                    EXECUTE IMMEDIATE 'TRUNCATE TABLE EST_SP_CAT17_MM3A';

                    EXECUTE IMMEDIATE 'ALTER TABLE EST_SP_CAT17_MM3B ENABLE CONSTRAINT FK_SAF_1186';

                    EXECUTE IMMEDIATE 'ALTER TABLE EST_SP_CAT17_MM3C ENABLE CONSTRAINT FK_SAF_1187';

                    EXECUTE IMMEDIATE 'TRUNCATE TABLE EST_SP_CAT17_MM5';

                    EXECUTE IMMEDIATE 'ALTER TABLE EST_SP_CAT17_MM5 DISABLE CONSTRAINT FK_SAF_1188';

                    EXECUTE IMMEDIATE 'TRUNCATE TABLE EST_SP_CAT17_MM4';

                    EXECUTE IMMEDIATE 'ALTER TABLE EST_SP_CAT17_MM5 ENABLE CONSTRAINT FK_SAF_1188';

                    EXECUTE IMMEDIATE 'TRUNCATE TABLE EST_SP_CAT17_MM6';

                    v_proc_status := 2; --SUCESSO
                    loga ( 'Fim do script, SUCESSO' );
                END IF; --IF UPPER(NVL(P_CONFIRMA,'!@#$')) <> 'TRUNCAR' THEN
            --------------------------------------------------------------------------------------------------------------
            /*            ELSIF P_SCRIPT = '008' THEN
                            V_DBG := '13.' || $$plsql_unit || ' L.' || $$plsql_line;
                            IF UPPER(NVL(P_CONFIRMA,'!@#$')) <> 'MIGRAR' THEN
                                LOGA('PALAVRA DE CONFIRMAÇÃO ERRADA!');
                                LOGA('Você deve digitar a primeira palavra do script (por exemplo: "LIBERA" OU "TRUNCAR")');
                                V_PROC_STATUS := 4; --ERRO
                            ELSE
                                LOGA('008. MIGRAR SAFX07 e 08 DO MSAFI PARA MSAF (S/S/N/O)');
                                LOGA(' ');
                                LOGA('Data inicial     (Sim, obrigatório): ' || TO_CHAR(P_DATA1,'DD/MM/YYYY'));
                                LOGA('Data final       (Sim, obrigatório): ' || TO_CHAR(P_DATA2,'DD/MM/YYYY'));
                                LOGA('Parametro 1      (Não utilizado)');
                                LOGA('Estabelecimentos (Opcional)');
                                LOGA(' ');

                                IF (P_CODESTAB.COUNT = 0) THEN
                                    LOGA('Estabelecimentos: [todos (sem critério)]');
                                ELSE
                                    LOGA('Estabelecimentos: [' || P_CODESTAB.COUNT || ']');
                                END IF;

                                IF (P_DATA1 IS NULL) OR (P_DATA2 IS NULL) THEN
                                    LOGA('Data 1 (inicio) e data 2 (fim) são obrigatórias');
                                    V_PROC_STATUS := 4; --ERRO
                                elsif P_DATA1 > P_DATA2  THEN
                                    LOGA('Data inicial deve ser menor ou igual a data final');
                                    V_PROC_STATUS := 4; --ERRO
                                end if;

                                IF V_PROC_STATUS <> 4 THEN
                                    FOR C1 IN (SELECT TO_CHAR(P_DATA1 + ROWNUM-1,'YYYYMMDD') AS DATA_SAFX
                                               FROM ALL_OBJECTS WHERE ROWNUM <= (P_DATA2 - P_DATA1)+1
                                              )
                                    LOOP
                                        MSAFI.DSP_CONTROL.LOG_CHECKPOINT('INFO','Loop',C1.DATA_SAFX);
                                        IF (P_CODESTAB.COUNT)=0 THEN
                                            INSERT INTO SAFX07 SELECT * FROM MSAFI.SAFX07
                                            WHERE (MOVTO_E_S<>'9' AND DATA_SAIDA_REC = C1.DATA_SAFX) OR (MOVTO_E_S='9' AND DATA_EMISSAO = C1.DATA_SAFX);

                                            DELETE FROM MSAFI.SAFX07
                                            WHERE (MOVTO_E_S<>'9' AND DATA_SAIDA_REC = C1.DATA_SAFX) OR (MOVTO_E_S='9' AND DATA_EMISSAO = C1.DATA_SAFX);

                                            INSERT INTO SAFX08 SELECT * FROM MSAFI.SAFX08
                                            WHERE DATA_FISCAL = C1.DATA_SAFX;

                                            DELETE FROM MSAFI.SAFX08
                                            WHERE DATA_FISCAL = C1.DATA_SAFX;
                                        ELSE
                                            IESTAB := P_CODESTAB.FIRST;
                                            WHILE IESTAB IS NOT NULL LOOP
                                                V_COD_ESTAB := P_CODESTAB(IESTAB);
                                                INSERT INTO SAFX07 SELECT * FROM MSAFI.SAFX07
                                                WHERE COD_ESTAB = V_COD_ESTAB
                                                AND   ((MOVTO_E_S<>'9' AND DATA_SAIDA_REC = C1.DATA_SAFX) OR (MOVTO_E_S='9' AND DATA_EMISSAO = C1.DATA_SAFX));

                                                DELETE FROM MSAFI.SAFX07
                                                WHERE COD_ESTAB = V_COD_ESTAB
                                                AND   ((MOVTO_E_S<>'9' AND DATA_SAIDA_REC = C1.DATA_SAFX) OR (MOVTO_E_S='9' AND DATA_EMISSAO = C1.DATA_SAFX));

                                                INSERT INTO SAFX08 SELECT * FROM MSAFI.SAFX08
                                                WHERE COD_ESTAB = V_COD_ESTAB
                                                AND   DATA_FISCAL = C1.DATA_SAFX;

                                                DELETE FROM MSAFI.SAFX08
                                                WHERE COD_ESTAB = V_COD_ESTAB
                                                AND   DATA_FISCAL = C1.DATA_SAFX;

                                                IESTAB := P_CODESTAB.NEXT(IESTAB);
                                            END LOOP;
                                        END IF;
                                        COMMIT;
                                    END LOOP;

                                    V_PROC_STATUS := 2; --SUCESSO
                                    LOGA('Fim do script, SUCESSO');
                                END IF; --IF V_PROC_STATUS <> 4 THEN
                            END IF; --IF UPPER(NVL(P_CONFIRMA,'!@#$')) <> 'MIGRAR' THEN
            */
            --------------------------------------------------------------------------------------------------------------
            /*            ELSIF P_SCRIPT = '009' THEN
                            V_DBG := '14.' || $$plsql_unit || ' L.' || $$plsql_line;
                            IF UPPER(NVL(P_CONFIRMA,'!@#$')) <> 'TRUNCAR' THEN
                                LOGA('PALAVRA DE CONFIRMAÇÃO ERRADA!');
                                LOGA('Você deve digitar a primeira palavra do script (por exemplo: "LIBERA" OU "TRUNCAR")');
                                V_PROC_STATUS := 4; --ERRO
                            ELSE
                                LOGA('009. TRUNCAR E TROCAR MSAFI.SAFX07 e SAFX08 (N/N/N/N)');
                                LOGA(' ');
                                LOGA('Data inicial     (Não utilizado)');
                                LOGA('Data final       (Não utilizado)');
                                LOGA('Parametro 1      (Não utilizado)');
                                LOGA('Estabelecimentos (Não utilizado)');
                                LOGA(' ');

                                LOGA('EXECUTANDO MSAFI.DSP_TROCA_TRUNCA_SAFX0708');
                                MSAFI.DSP_TROCA_TRUNCA_SAFX0708;

                                V_PROC_STATUS := 2; --SUCESSO
                                LOGA('Fim do script, SUCESSO');
                            END IF; --IF UPPER(NVL(P_CONFIRMA,'!@#$')) <> 'TRUNCAR' THEN
            */
            --------------------------------------------------------------------------------------------------------------
            ELSIF p_script = '010' THEN
                v_dbg := '15.' || $$plsql_unit || ' L.' || $$plsql_line;

                IF UPPER ( NVL ( p_confirma, '!@#$' ) ) <> 'LIBERAR' THEN
                    loga ( 'PALAVRA DE CONFIRMAÇÃO ERRADA!' );
                    loga ( 'Você deve digitar a primeira palavra do script (por exemplo: "LIBERA" OU "TRUNCAR")' );
                    v_proc_status := 4; --ERRO
                ELSE
                    loga ( '010. LIBERAR TABELAS DO DATAMART (N/N/O/O)' );
                    loga ( ' ' );
                    loga ( 'Data inicial     (Não utilizado)' );
                    loga ( 'Data final       (Não utilizado)' );
                    loga ( 'Parametro 1      (Opcional): ' || p_parametro1 );
                    loga ( 'Estabelecimentos (Opcional)' );
                    loga ( ' ' );

                    loga ( 'Usuários com DataMart travado:' );
                    loga ( 'USUARIO - Número de linhas' );

                    FOR c1 IN cursor_script_010 LOOP
                        loga ( c1.usuario || ' - ' || c1.cont );
                    END LOOP;

                    loga ( '---------Fim da lista---------' );

                    IF ( p_codestab.COUNT > 0 ) THEN
                        iestab := p_codestab.FIRST;

                        WHILE iestab IS NOT NULL LOOP
                            v_cod_estab := p_codestab ( iestab );

                            UPDATE prt_ident_dmart
                               SET ind_utilizacao = 'N'
                             WHERE cod_estab = v_cod_estab
                               AND ind_utilizacao = 'S'
                               AND UPPER ( TRIM ( usuario ) ) =
                                       UPPER ( NVL ( TRIM ( p_parametro1 ), TRIM ( usuario ) ) );

                            iestab := p_codestab.NEXT ( iestab );
                        END LOOP;
                    ELSE --IF (P_CODESTAB.COUNT > 0) THEN ...
                        UPDATE prt_ident_dmart
                           SET ind_utilizacao = 'N'
                         WHERE ind_utilizacao = 'S'
                           AND UPPER ( TRIM ( usuario ) ) = UPPER ( NVL ( TRIM ( p_parametro1 ), TRIM ( usuario ) ) );
                    END IF; --IF (P_CODESTAB.COUNT > 0) THEN ... ELSE ...

                    COMMIT;

                    v_proc_status := 2; --SUCESSO
                    loga ( 'Fim do script, SUCESSO' );
                END IF; --IF UPPER(NVL(P_CONFIRMA,'!@#$')) <> 'LIBERAR' THEN
            --------------------------------------------------------------------------------------------------------------
            ELSIF p_script = '011' THEN
                v_dbg := '21.' || $$plsql_unit || ' L.' || $$plsql_line;

                IF UPPER ( NVL ( p_confirma, '!@#$' ) ) <> 'EXCLUIR' THEN
                    loga ( 'PALAVRA DE CONFIRMAÇÃO ERRADA!' );
                    loga ( 'Você deve digitar a primeira palavra do script (por exemplo: "LIBERA" OU "TRUNCAR")' );
                    v_proc_status := 4; --ERRO
                ELSE
                    loga ( '011. EXCLUIR NFs EXISTENTES NA SAFX07 (N/N/N/N)' );
                    loga ( ' ' );
                    loga ( 'Data inicial     (Não utilizado)' );
                    loga ( 'Data final       (Não utilizado)' );
                    loga ( 'Parametro 1      (Não utilizado)' );
                    loga ( 'Estabelecimentos (Não utilizado)' );
                    loga ( ' ' );

                    dsp_exclui_nfs_dup_safx07;

                    v_proc_status := 2; --SUCESSO
                    loga ( 'Fim do script, SUCESSO' );
                END IF; --IF UPPER(NVL(P_CONFIRMA,'!@#$')) <> 'LIBERAR' THEN
            --------------------------------------------------------------------------------------------------------------
            ELSIF p_script = '012' THEN --UNION SELECT ''012'',''012. RECALCULAR ICMS DE CUPOM (N/N/N/N)'' FROM DUAL
                v_dbg := '22.' || $$plsql_unit || ' L.' || $$plsql_line;

                IF UPPER ( NVL ( p_confirma, '!@#$' ) ) <> 'RECALCULAR' THEN
                    loga ( 'PALAVRA DE CONFIRMAÇÃO ERRADA!' );
                    loga ( 'Você deve digitar a primeira palavra do script (por exemplo: "LIBERA" OU "TRUNCAR")' );
                    v_proc_status := 4; --ERRO
                ELSE
                    loga ( '012. RECALCULAR ICMS DE CUPOM (S/N/N/S)' );
                    loga ( ' ' );
                    loga (    'Data inicial     (Sim, obrigatório): '
                           || TO_CHAR ( p_data1
                                      , 'DD/MM/YYYY' ) );
                    loga ( 'Data final       (Não utilizado)' );
                    loga ( 'Parametro 1      (Não utilizado)' );
                    loga ( 'Estabelecimentos (Obrigatório)' );
                    loga ( ' ' );
                    loga ( 'Data 1 será utilizada como referência para o mês de execução' );
                    loga ( 'Ex: Data1 = 13/12/2011; o processo é executado de 01/12/2011 a 31/12/2011' );
                    loga ( 'Independentemente do dia da Data 1 e também da Data 2; que é ignorada' );

                    IF ( p_codestab.COUNT = 0 ) THEN
                        loga ( 'Lista de estabelecimentos é obrigatória!' );
                        v_proc_status := 4; --ERRO
                    ELSIF ( p_data1 IS NULL ) THEN
                        loga ( 'Data 1 (inicio) é obrigatória' );
                        v_proc_status := 4; --ERRO
                    END IF;

                    IF v_proc_status <> 4 THEN
                        loga ( 'Estabelecimentos: [' || p_codestab.COUNT || ']' );

                        iestab := p_codestab.FIRST;

                        WHILE iestab IS NOT NULL LOOP
                            v_cod_estab := p_codestab ( iestab );

                            loga ( 'Executando estabelecimento: [' || mcod_empresa || '/' || v_cod_estab || ']' );
                            msafi.dsp_resoma_icms_cupom ( mcod_empresa
                                                        , v_cod_estab
                                                        , TO_NUMBER ( TO_CHAR ( p_data1
                                                                              , 'MM' ) )
                                                        , TO_NUMBER ( TO_CHAR ( p_data1
                                                                              , 'YYYY' ) ) );

                            iestab := p_codestab.NEXT ( iestab );
                        END LOOP;

                        v_proc_status := 2; --SUCESSO
                        loga ( 'Fim do script, SUCESSO' );
                    END IF; --IF V_PROC_STATUS <> 4 THEN
                END IF; --IF UPPER(NVL(P_CONFIRMA,'!@#$')) <> 'LIBERAR' THEN
            --------------------------------------------------------------------------------------------------------------
            ELSIF p_script = '013' THEN --UNION SELECT ''013'',''013. Carregar Interface de Fornecedor (S/S/O/N)'' FROM DUAL
                v_dbg := '23.' || $$plsql_unit || ' L.' || $$plsql_line;

                IF UPPER ( NVL ( p_confirma, '!@#$' ) ) <> 'CARREGAR' THEN
                    loga ( 'PALAVRA DE CONFIRMAÇÃO ERRADA!' );
                    loga ( 'Você deve digitar a primeira palavra do script (por exemplo: "LIBERA" OU "TRUNCAR")' );
                    v_proc_status := 4; --ERRO
                ELSE
                    loga ( '013. Carregar Interface de Fornecedor (S/S/O/N)' );
                    loga ( ' ' );
                    loga (    'Data inicial     (Sim, obrigatório): '
                           || TO_CHAR ( p_data1
                                      , 'DD/MM/YYYY' ) );
                    loga (    'Data final       (Sim, obrigatório): '
                           || TO_CHAR ( p_data2
                                      , 'DD/MM/YYYY' ) );
                    loga ( 'Parametro 1      (Opcional): ' || p_parametro1 );
                    loga ( 'Estabelecimentos (Não utilizado)' );
                    loga ( ' ' );
                    loga ( 'Para carregar um único fornecedor, preencha as datas deste 01/01/1900 até hoje' );
                    loga ( 'e preencha o ID do fornecedor EXATAMENTE como está no People no campo Parâmetro 1' );
                    loga ( 'Nota: O ID do fornecedor tem que ter os ZEROs a esquerda para ser igual ao do People!' );
                    loga ( ' ' );

                    IF ( p_codestab.COUNT <> 0 ) THEN
                        loga ( 'Lista de estabelecimentos não é relevante e não deve ser preenchida!' );
                        v_proc_status := 4; --ERRO
                    ELSIF ( p_data1 IS NULL ) THEN
                        loga ( 'Data 1 (início) é obrigatória' );
                        v_proc_status := 4; --ERRO
                    ELSIF ( p_data2 IS NULL ) THEN
                        loga ( 'Data 2 (fim) é obrigatória' );
                        v_proc_status := 4; --ERRO
                    END IF;

                    IF v_proc_status <> 4 THEN
                        loga ( 'Executando interface de fornecedores:' );
                        loga (
                                  'BEGIN MSAFI.PRC_MSAF_PS_SAFX04_FOR('''
                               || TO_CHAR ( p_data1
                                          , 'YYYYMMDD' )
                               || ''','''
                               || TO_CHAR ( p_data2
                                          , 'YYYYMMDD' )
                               || ''''
                               || CASE
                                      WHEN TRIM ( p_parametro1 ) IS NULL THEN NULL
                                      ELSE ',''' || TRIM ( p_parametro1 ) || ''''
                                  END
                               || '); END;'
                        );

                        EXECUTE IMMEDIATE
                               'BEGIN MSAFI.PRC_MSAF_PS_SAFX04_FOR('''
                            || TO_CHAR ( p_data1
                                       , 'YYYYMMDD' )
                            || ''','''
                            || TO_CHAR ( p_data2
                                       , 'YYYYMMDD' )
                            || ''''
                            || CASE
                                   WHEN TRIM ( p_parametro1 ) IS NULL THEN NULL
                                   ELSE ',''' || TRIM ( p_parametro1 ) || ''''
                               END
                            || '); END;';

                        v_proc_status := 2; --SUCESSO
                        loga ( 'Fim do script, SUCESSO' );
                    END IF; --IF V_PROC_STATUS <> 4 THEN
                END IF; --IF UPPER(NVL(P_CONFIRMA,'!@#$')) <> 'LIBERAR' THEN
            --------------------------------------------------------------------------------------------------------------
            /*ELSIF P_SCRIPT = '014' THEN --UNION SELECT ''014'',''014. Estorno de Credito/Debito Cesta Basica (S/S/N/N)'' FROM DUAL
                V_DBG := '24.' || $$plsql_unit || ' L.' || $$plsql_line;
                IF UPPER(NVL(P_CONFIRMA,'!@#$')) <> 'ESTORNO' THEN
                    LOGA('PALAVRA DE CONFIRMAÇÃO ERRADA!');
                    LOGA('Você deve digitar a primeira palavra do script (por exemplo: "LIBERA" OU "TRUNCAR")');
                    V_PROC_STATUS := 4; --ERRO
                ELSE
                    LOGA('014. Estorno de Credito/Debito Cesta Basica (S/S/N/N)');
                    LOGA(' ');
                    LOGA('Data inicial     (Sim, obrigatório): ' || TO_CHAR(P_DATA1,'DD/MM/YYYY'));
                    LOGA('Data final       (Sim, obrigatório): ' || TO_CHAR(P_DATA2,'DD/MM/YYYY'));
                    LOGA('Parametro 1      (Não utilizado)');
                    LOGA('Estabelecimentos (Não utilizado)');
                    LOGA(' ');

                    IF (P_CODESTAB.COUNT <> 0) THEN
                        LOGA('Lista de estabelecimentos não é relevante e não deve ser preenchida!');
                        V_PROC_STATUS := 4; --ERRO
                    ELSIF (P_DATA1 IS NULL) THEN
                            LOGA('Data 1 (início) é obrigatória');
                            V_PROC_STATUS := 4; --ERRO
                    ELSIF (P_DATA2 IS NULL) THEN
                            LOGA('Data 2 (fim) é obrigatória');
                            V_PROC_STATUS := 4; --ERRO
                    end if;
                    IF V_PROC_STATUS <> 4 THEN
                        LOGA('Executando processo');

                        LOGA('Excluindo valores existentes no livro');
                        DELETE FROM MSAF.ITEM_APURAC_DISCR IAD
                        WHERE IAD.COD_EMPRESA = MCOD_EMPRESA
                        AND IAD.COD_ESTAB NOT LIKE MCOD_EMPRESA || '9%'
                        AND IAD.DAT_APURACAO BETWEEN P_DATA1 AND P_DATA2
                        AND IAD.COD_OPER_APUR IN ('003','007')
                        AND IAD.VAL_ITEM_DISCRIM = 0
                        AND NVL(IAD.COD_AMPARO_LEGAL,'N030005') = 'N030005'
                        AND (IAD.COD_EMPRESA,IAD.COD_ESTAB,IAD.COD_TIPO_LIVRO,IAD.DAT_APURACAO,IAD.COD_OPER_APUR) IN (
                            SELECT DDF.COD_EMPRESA,DDF.COD_ESTAB,'108',LAST_DAY(P_DATA2),DECODE(DDF.MOVTO_E_S,'9','007','003')
                            FROM MSAF.DWT_DOCTO_FISCAL DDF, MSAF.DWT_ITENS_MERC DIM
                            WHERE DDF.IDENT_DOCTO_FISCAL = DIM.IDENT_DOCTO_FISCAL
                            AND DDF.COD_EMPRESA = MCOD_EMPRESA
                            AND DDF.COD_ESTAB NOT LIKE MCOD_EMPRESA || '9%'
                            AND DDF.DATA_FISCAL BETWEEN P_DATA1 AND P_DATA2
                            AND DIM.ALIQ_TRIBUTO_ICMS = '7'
                            GROUP BY DDF.COD_EMPRESA,DDF.COD_ESTAB,DDF.MOVTO_E_S
                            )
                        ;
                        LOGA('Valores excluídos do livro: ['|| SQL%ROWCOUNT ||']');
                        LOGA('Inserindo valores no livro');
                        INSERT INTO MSAF.ITEM_APURAC_DISCR
                        SELECT DDF.COD_EMPRESA,DDF.COD_ESTAB,'108',LAST_DAY(P_DATA2),DECODE(DDF.MOVTO_E_S,'9','007','003'),
                              NVL((SELECT MAX(NUM_DISCRIMINACAO)+1
                                   FROM MSAF.ITEM_APURAC_DISCR SIAD
                                   WHERE SIAD.COD_EMPRESA = DDF.COD_EMPRESA
                                   AND SIAD.COD_ESTAB = DDF.COD_ESTAB
                                   AND SIAD.COD_TIPO_LIVRO = '108'
                                   AND SIAD.DAT_APURACAO = LAST_DAY(P_DATA2)
                                   AND SIAD.COD_OPER_APUR = DECODE(DDF.MOVTO_E_S,'9','007','003')
                                  ),1) AS NUM_DISCRIMINACAO
                              ,SUM(DIM.VLR_TRIBUTO_ICMS),NULL AS IND_TIPO_DEDUCAO,'PRODUTOS DE CESTA BÁSICA CONFORME DECRETO 32.161/2002'
                              ,'1',NULL,'N030005',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
                              ,DECODE(DDF.MOVTO_E_S,'9','RJ030005','RJ010005'),NULL,NULL,NULL,'N',NULL,NULL,NULL,NULL
                        FROM MSAF.DWT_DOCTO_FISCAL DDF, MSAF.DWT_ITENS_MERC DIM
                        WHERE DDF.IDENT_DOCTO_FISCAL = DIM.IDENT_DOCTO_FISCAL
                        AND DDF.COD_EMPRESA = MCOD_EMPRESA
                        AND DDF.COD_ESTAB NOT LIKE MCOD_EMPRESA || '9%'
                        AND DDF.DATA_FISCAL BETWEEN P_DATA1 AND P_DATA2
                        AND DIM.ALIQ_TRIBUTO_ICMS = '7'
                        AND NOT EXISTS (SELECT 1 FROM MSAF.ITEM_APURAC_DISCR SIAD
                                        WHERE SIAD.COD_EMPRESA = DDF.COD_EMPRESA
                                        AND SIAD.COD_ESTAB = DDF.COD_ESTAB
                                        AND SIAD.COD_TIPO_LIVRO = '108'
                                        AND SIAD.DAT_APURACAO = LAST_DAY(P_DATA2)
                                        AND SIAD.COD_OPER_APUR = DECODE(DDF.MOVTO_E_S,'9','007','003')
                                        AND SIAD.COD_AMPARO_LEGAL = 'N030005'
                                       )
                        GROUP BY DDF.COD_EMPRESA,DDF.COD_ESTAB,DDF.MOVTO_E_S
                        ;
                        LOGA('Valores inseridos no livro: ['|| SQL%ROWCOUNT ||']');
                        COMMIT;

                        V_PROC_STATUS := 2; --SUCESSO
                        LOGA('Fim do script, SUCESSO');
                    END IF; --IF V_PROC_STATUS <> 4 THEN
                END IF; --IF UPPER(NVL(P_CONFIRMA,'!@#$')) <> 'LIBERAR' THEN*/
            --------------------------------------------------------------------------------------------------------------
            ELSIF p_script = '050' THEN
                v_dbg := '20.' || $$plsql_unit || ' L.' || $$plsql_line;

                IF UPPER ( NVL ( p_confirma, '!@#$' ) ) <> 'LIMPA' THEN
                    loga ( 'PALAVRA DE CONFIRMAÇÃO ERRADA!' );
                    loga ( 'Você deve digitar a primeira palavra do script (por exemplo: "LIBERA" OU "TRUNCAR")' );
                    v_proc_status := 4; --ERRO
                ELSE
                    loga ( '050. LIMPA LOGS MEIO MAGNETICO e SPED (O/O/S/N)' );
                    loga ( ' ' );
                    loga (    'Data inicial     (Opcional)             : '
                           || NVL ( TO_CHAR ( p_data1
                                            , 'DD/MM/YYYY' )
                                  , '*' ) );
                    loga (    'Data final       (Opcional)             : '
                           || NVL ( TO_CHAR ( p_data2
                                            , 'DD/MM/YYYY' )
                                  , '*' ) );
                    loga ( 'Parametro 1 - usuário (Sim, Obrigatório): ' || p_parametro1 );
                    loga ( 'Estabelecimentos (Não utilizado)' );
                    loga ( ' ' );

                    IF ( p_parametro1 IS NULL ) THEN
                        loga (
                               'ERRO! Parametro 1 (usuário) é obrigatório; para executar para todos os usuários, digite "todos"'
                        );
                        v_proc_status := 4; --ERRO
                    ELSE
                        v_date1 := p_data1;
                        v_date2 := NVL ( p_data2, SYSDATE - 3 );

                        IF UPPER ( p_parametro1 ) = 'TODOS' THEN
                            v_char1_30 := NULL;
                        ELSE
                            v_char1_30 := p_parametro1;
                        END IF;

                        v_num01 := 0;

                        FOR c_emm IN ( SELECT   *
                                           FROM lib_processo
                                          WHERE aplicacao IN ( 'SAFUFMM.EXE'
                                                             , 'SAFSEFD.EXE' )
                                            AND UPPER ( cod_usuario ) = UPPER ( NVL ( v_char1_30, cod_usuario ) )
                                            AND ( data_fim IS NOT NULL
                                              OR ( data_fim IS NULL
                                              AND data_inicio < SYSDATE - 5 ) )
                                            --AND   NVL(DATA_FIM,DATA_INICIO) < SYSDATE-1 --não excluir nada das últimas 24h, não importa o parâmetro de data final
                                            AND NVL ( data_fim, data_inicio ) BETWEEN NVL ( v_date1
                                                                                          , TO_DATE ( '01011900'
                                                                                                    , 'DDMMYYYY' ) )
                                                                                  AND v_date2
                                       ORDER BY data_inicio DESC ) LOOP
                            --LOGA(C_EMM.COD_USUARIO || ' | ' || C_EMM.PROC_ID);
                            lib_proc.delete ( c_emm.proc_id );
                            v_num01 := v_num01 + 1;
                            COMMIT;
                        END LOOP;

                        loga ( 'Logs limpos: [' || v_num01 || ']' );
                        v_proc_status := 2; --SUCESSO
                    END IF; -- IF (P_PARAMETRO1 IS NULL) THEN ... ELSE ...


                    loga ( 'Fim do script' );
                END IF; --IF UPPER(NVL(P_CONFIRMA,'!@#$')) <> 'LIMPA' THEN ... ELSE ...
            --------------------------------------------------------------------------------------------------------------
            ELSE
                v_dbg := '17.' || $$plsql_unit || ' L.' || $$plsql_line;
                v_proc_status := 4; --ERRO
                loga ( 'ERRO INTERNO SCRIPT DESCONHECIDO! [' || p_script || ']' );
            END IF; --IF P_SCRIPT = '1' THEN ... ELSIF ...
        ELSE
            v_dbg := '18.' || $$plsql_unit || ' L.' || $$plsql_line;
            v_proc_status := 4; --ERRO
            loga ( 'SENHA DO DIA INCORRETA PEÇA A SENHA PARA UM TÉCNICO! [' || p_senha || ']' );
        END IF;

        v_dbg := '19.' || $$plsql_unit || ' L.' || $$plsql_line;
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
            loga ( 'EXCEPTION [' || v_dbg || '] [' || SQLERRM || ']' );
            loga ( '[' || dbms_utility.format_error_backtrace || ']' );
            msafi.dsp_control.updateprocess ( 'ERRO' );
            RAISE;
    END; --FUNCTION EXECUTAR
END dsp_executa_scripts_cproc;
/
SHOW ERRORS;
