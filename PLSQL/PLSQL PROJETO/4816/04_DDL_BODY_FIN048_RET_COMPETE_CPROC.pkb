CREATE OR REPLACE PACKAGE BODY MSAF.DPSP_FIN048_RET_COMPETE_CPROC IS
  MPROC_ID     NUMBER;
  VN_LINHA     NUMBER := 0;
  VN_PAGINA    NUMBER := 0;
  MNM_USUARIO  USUARIO_ESTAB.COD_USUARIO%TYPE;
  MCOD_EMPRESA ESTABELECIMENTO.COD_EMPRESA%TYPE;
  VS_MLINHA    VARCHAR2(4000);

  --Tipo, Nome e Descrição do Customizado
  --Melhoria FIN048
  MNM_TIPO  VARCHAR2(100) := 'Retificação ICMS ES';
  MNM_CPROC VARCHAR2(100) := '3. Gerar cálculos COMPETE e FEEF';
  MDS_CPROC VARCHAR2(100) := 'Gerar cálculo conforme os Relatórios de Retificação';

  FUNCTION PARAMETROS RETURN VARCHAR2 IS
    PSTR VARCHAR2(5000);
  
  BEGIN
  
    MNM_USUARIO  := lib_parametros.recuperar(upper('USUARIO'));
    MCOD_EMPRESA := lib_parametros.recuperar(upper('EMPRESA'));
  
    LIB_PROC.ADD_PARAM(pparam      => pstr,
                       ptitulo     => 'Data Inicial',
                       ptipo       => 'DATE',
                       pcontrole   => 'textbox',
                       pmandatorio => 'S',
                       pdefault    => NULL,
                       pmascara    => 'DD/MM/YYYY');
  
    LIB_PROC.ADD_PARAM(pparam      => pstr,
                       ptitulo     => 'Data Final',
                       ptipo       => 'DATE',
                       pcontrole   => 'textbox',
                       pmandatorio => 'S',
                       pdefault    => NULL,
                       pmascara    => 'DD/MM/YYYY');
  
    LIB_PROC.ADD_PARAM(PSTR,
                       'CDs',
                       'VARCHAR2',
                       'COMBOBOX',
                       'S',
                       NULL,
                       NULL,
                       ' SELECT ''TODOS'' AS COD_ESTAB, ''Todos os CDs'' FROM DUAL UNION ALL ' ||
                       'SELECT A.COD_ESTAB, A.COD_ESTAB || '' - '' || B.COD_ESTADO || '' - '' || A.CGC || '' - '' || INITCAP(A.BAIRRO) || '' / '' || INITCAP(A.CIDADE) FROM ESTABELECIMENTO A, ESTADO B, MSAFI.DSP_ESTABELECIMENTO C WHERE A.COD_EMPRESA  = ''' ||
                       MCOD_EMPRESA ||
                       ''' AND B.IDENT_ESTADO = A.IDENT_ESTADO AND A.COD_EMPRESA = C.COD_EMPRESA AND A.COD_ESTAB = C.COD_ESTAB AND C.TIPO = ''C'' AND B.COD_ESTADO = ''ES'' ');
  
    return pstr;
  end;
  function tipo return varchar2 is
  begin
    return MNM_TIPO;
  end;
  function nome return varchar2 is
  begin
    return MNM_CPROC;
  end;
  function descricao return varchar2 is
  begin
    return MDS_CPROC;
  end;
  function versao return varchar2 is
  begin
    return '1.0';
  end;
  function modulo return varchar2 is
  begin
    return 'Customizados';
  end;
  function classificacao return varchar2 is
  begin
    return 'Customizados';
  end;
  function orientacao return varchar2 is
  begin
    return 'PORTRAIT';
  end;

  FUNCTION executar(PDT_INI DATE, PDT_FIM DATE, PCOD_ESTAB VARCHAR2)
    RETURN INTEGER IS
  
    V_QTD            INTEGER;
    V_VALIDAR_STATUS INTEGER := 0;
    V_EXISTE_ORIGEM  CHAR := 'S';
  
    V_DATA_INICIAL  DATE := TRUNC(PDT_INI) -
                            (TO_NUMBER(TO_CHAR(PDT_INI, 'DD')) - 1);
    V_DATA_FINAL    DATE := LAST_DAY(PDT_FIM);
    V_DATA_HORA_INI VARCHAR2(20);
    P_PROC_INSTANCE VARCHAR2(30);
  
    --PTAB_ENTRADA     VARCHAR2(50);
    V_SQL            VARCHAR2(4000);
    V_RETORNO_STATUS VARCHAR2(4000);
  
    i INTEGER := 2;
    --Variaveis genericas
    V_TEXT01 VARCHAR2(6000);
    V_CLASS  VARCHAR2(1) := 'a';
  
    CURSOR LISTA_CDs IS
      SELECT A.COD_ESTAB
        FROM ESTABELECIMENTO A, ESTADO B, MSAFI.DSP_ESTABELECIMENTO C
       WHERE B.IDENT_ESTADO = A.IDENT_ESTADO
         AND A.COD_EMPRESA = C.COD_EMPRESA
         AND A.COD_ESTAB = C.COD_ESTAB
         AND C.TIPO = 'C'
         AND A.COD_EMPRESA = MCOD_EMPRESA
         AND A.COD_ESTAB = (CASE WHEN PCOD_ESTAB = 'TODOS' THEN A.COD_ESTAB ELSE
              PCOD_ESTAB END);
  
  begin
  
    -- Criação: Processo
    MPROC_ID := lib_proc.new(psp_nome => $$PLSQL_UNIT, -- Package
                             prows    => 48,
                             pcols    => 200);
  
    --Tela DW                
    LIB_PROC.ADD_TIPO(Pproc_id  => MPROC_ID,
                      ptipo     => 1,
                      ptitulo   => TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS') ||
                                   '_Ret_ICMS_ES_Entradas',
                      ptipo_arq => 1);
  
    vn_pagina := 1;
    vn_linha  := 48;
  
    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT="DD/MM/YYYY"';
    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS= '',.'' ';
  
    MCOD_EMPRESA := LIB_PARAMETROS.RECUPERAR('EMPRESA');
    MNM_USUARIO  := LIB_PARAMETROS.RECUPERAR('USUARIO');
  
    --MARCAR INCIO DA EXECUCAO
    V_DATA_HORA_INI := TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI.SS');
  
    IF MCOD_EMPRESA IS NULL THEN
      LIB_PROC.ADD_LOG('Código da empresa deve ser informado como parâmetro global.',
                       0);
      LIB_PROC.ADD('ERRO');
      LIB_PROC.ADD('CÓDIGO DA EMPRESA DEVE SER INFORMADO COMO PARÂMETRO GLOBAL.');
      LIB_PROC.CLOSE;
      RETURN MPROC_ID;
    END IF;
  
    FOR C_DADOS_EMP IN (SELECT COD_EMPRESA,
                               RAZAO_SOCIAL,
                               DECODE(CNPJ,
                                      NULL,
                                      NULL,
                                      REPLACE(REPLACE(REPLACE(TO_CHAR(LPAD(REPLACE(CNPJ,
                                                                                   ''),
                                                                           14,
                                                                           '0'),
                                                                      '00,000,000,0000,00'),
                                                              ',',
                                                              '.'),
                                                      ' '),
                                              '.' ||
                                              TRIM(TO_CHAR(TRUNC(MOD(LPAD(CNPJ,
                                                                          14,
                                                                          '0'),
                                                                     1000000) / 100),
                                                           '0000')) || '.',
                                              '/' ||
                                              TRIM(TO_CHAR(TRUNC(MOD(LPAD(CNPJ,
                                                                          14,
                                                                          '0'),
                                                                     1000000) / 100),
                                                           '0000')) || '-')) AS CNPJ
                          FROM EMPRESA
                         WHERE COD_EMPRESA = MCOD_EMPRESA) LOOP
    
      CABECALHO(C_DADOS_EMP.RAZAO_SOCIAL,
                C_DADOS_EMP.CNPJ,
                V_DATA_HORA_INI,
                MNM_CPROC,
                PDT_INI,
                PDT_FIM,
                PCOD_ESTAB);
    
    END LOOP;
  
    LOGA('---INI DO PROCESSAMENTO---', FALSE);
    LOGA('<< PERIODO DE: ' || V_DATA_INICIAL || ' A ' || V_DATA_FINAL ||
         ' >>',
         FALSE);
  
    --=================================================================================
    -- INICIO
    --=================================================================================
    --Permitir processo somente para um mês
    IF LAST_DAY(PDT_INI) = LAST_DAY(PDT_FIM) THEN
      --=================================================================================
      -- INICIO
      --=================================================================================
      -- Um CD por Vez
      FOR CD IN LISTA_CDs LOOP
      
        DBMS_APPLICATION_INFO.SET_MODULE($$PLSQL_UNIT,
                                         'Estab: ' || CD.COD_ESTAB);
      
        --GERAR CHAVE PROC_ID
        SELECT ROUND(DBMS_RANDOM.VALUE(10000000000000, 999999999999999))
          INTO P_PROC_INSTANCE
          FROM DUAL;
      
        --=================================================================================
        -- VALIDAR STATUS DE RELATÓRIOS ENCERRADOS
        --=================================================================================
        -- IGUAL À ZERO:      PARA PROCESSOS ABERTOS - AÇÃO: CARREGAR TABELA RETIFICACAO NFS DE ENTRADA
        -- DIFERENTE DE ZERO: PARA PROCESSOS ENCERRADOS - AÇÃO: CONSULTAR TABELA RETIFICACAO NFS DE ENTRADA
        ---------------------
      
        V_VALIDAR_STATUS := MSAF.DPSP_SUPORTE_CPROC_PROCESS.validar_status_rel
                            
                            (MCOD_EMPRESA,
                             CD.COD_ESTAB,
                             TO_NUMBER(TO_CHAR(PDT_INI, 'YYYYMM')),
                             $$PLSQL_UNIT);
      
        --=================================================================================
        -- CARREGAR TABELA DE NOTAS DE ENTRADA
        --=================================================================================
        IF V_VALIDAR_STATUS = 0 THEN
          LOGA('>> INICIO CD: ' || CD.COD_ESTAB || ' PROC INSERT ' ||
               P_PROC_INSTANCE,
               FALSE);
        
          ---------------------
          -- LIMPEZA
          ---------------------
          DELETE FROM MSAFI.DPSP_FIN048_RET_COMPETE
           WHERE 1=1 --COD_EMPRESA = MCOD_EMPRESA
             AND COD_ESTAB = CD.COD_ESTAB
             AND DATA_FISCAL BETWEEN V_DATA_INICIAL AND V_dATA_FINAL;
        
          LOGA('::LIMPEZA DOS REGISTROS ANTERIORES (DPSP_FIN048_RET_NF_ENT), CD: ' ||
               CD.COD_ESTAB || ' - QTDE ' || SQL%ROWCOUNT || '::',
               FALSE);
        
          COMMIT;
        
          --A carga irá executar o periodo inteiro, e depois consultar o periodo informado na tela.
          --Exemplo: Parametrizado do dia 1 ao 10, então será carregado de 1 a 31, mas consultado de 1 a 10
          V_QTD := carregar_NF_entrada(V_DATA_INICIAL,
                                       V_DATA_FINAL,
                                       CD.COD_ESTAB,
                                       V_DATA_HORA_INI);
        
          ---------------------
          -- Informar CDs que retornarem sem dados de origem / select zerado
          ---------------------
          IF V_QTD = 0 then
            --Inserir status como Aberto pois não há origem
            MSAF.DPSP_SUPORTE_CPROC_PROCESS.inserir_status_rel(MCOD_EMPRESA,
                                                               CD.COD_ESTAB,
                                                               TO_NUMBER(TO_CHAR(PDT_INI,
                                                                                 'YYYYMM')),
                                                               $$PLSQL_UNIT,
                                                               MNM_CPROC,
                                                               MNM_TIPO,
                                                               0, --Aberto
                                                               $$PLSQL_UNIT,
                                                               MPROC_ID,
                                                               MNM_USUARIO,
                                                               V_DATA_HORA_INI);
          
            LIB_PROC.ADD('CD ' || CD.COD_ESTAB || ' sem dados na origem.');
          
            LIB_PROC.ADD(' ');
            LOGA('---CD ' || CD.COD_ESTAB || ' - SEM DADOS DE ORIGEM---',
                 FALSE);
            --LOGA('<< SEM DADOS DE ORIGEM >>', FALSE);
          
            V_EXISTE_ORIGEM := 'N';
          
          ELSE
          
            ---------------------
            --Encerrar periodo caso não seja o mês atual e existam registros na origem
            ---------------------
            IF LAST_DAY(PDT_INI) < LAST_DAY(SYSDATE) THEN
            
              MSAF.DPSP_SUPORTE_CPROC_PROCESS.inserir_status_rel(MCOD_EMPRESA,
                                                                 CD.COD_ESTAB,
                                                                 TO_NUMBER(TO_CHAR(PDT_INI,
                                                                                   'YYYYMM')),
                                                                 $$PLSQL_UNIT,
                                                                 MNM_CPROC,
                                                                 MNM_TIPO,
                                                                 1, --Encerrado
                                                                 $$PLSQL_UNIT,
                                                                 MPROC_ID,
                                                                 MNM_USUARIO,
                                                                 V_DATA_HORA_INI);
              LIB_PROC.ADD('CD ' || CD.COD_ESTAB || ' - Período Encerrado');
            
              V_RETORNO_STATUS := MSAF.DPSP_SUPORTE_CPROC_PROCESS.retornar_status_rel
                                  
                                  (MCOD_EMPRESA,
                                   CD.COD_ESTAB,
                                   TO_NUMBER(TO_CHAR(PDT_INI, 'YYYYMM')),
                                   $$PLSQL_UNIT);
              LIB_PROC.ADD('Data de Encerramento: ' || V_RETORNO_STATUS);
            
              LIB_PROC.ADD(' ');
              LOGA('---ESTAB ' || CD.COD_ESTAB || ' - PERIODO ENCERRADO: ' ||
                   V_RETORNO_STATUS || '---',
                   FALSE);
            
            ELSE
            
              MSAF.DPSP_SUPORTE_CPROC_PROCESS.inserir_status_rel(MCOD_EMPRESA,
                                                                 CD.COD_ESTAB,
                                                                 TO_NUMBER(TO_CHAR(PDT_INI,
                                                                                   'YYYYMM')),
                                                                 $$PLSQL_UNIT,
                                                                 MNM_CPROC,
                                                                 MNM_TIPO,
                                                                 0, --Aberto
                                                                 $$PLSQL_UNIT,
                                                                 MPROC_ID,
                                                                 MNM_USUARIO,
                                                                 V_DATA_HORA_INI);
            
              LIB_PROC.ADD('CD ' || CD.COD_ESTAB ||
                           ' - PERIODO EM ABERTO,',
                           1);
              LIB_PROC.ADD('Os registros gerados são temporários.', 1);
            
              LIB_PROC.ADD(' ', 1);
              LOGA('---CD ' || CD.COD_ESTAB || ' - PERIODO EM ABERTO---',
                   FALSE);
            
            END IF;
          END IF;
        
          --PERIODO JÁ ENCERRADO
        ELSE
          LIB_PROC.ADD('CD ' || CD.COD_ESTAB ||
                       ' - Período já processado e encerrado');
        
          V_RETORNO_STATUS := MSAF.DPSP_SUPORTE_CPROC_PROCESS.retornar_status_rel
                              
                              (MCOD_EMPRESA,
                               CD.COD_ESTAB,
                               TO_NUMBER(TO_CHAR(PDT_INI, 'YYYYMM')),
                               $$PLSQL_UNIT);
          LIB_PROC.ADD('Data de Encerramento: ' || V_RETORNO_STATUS);
        
          LIB_PROC.ADD(' ');
          LOGA('---CD ' || CD.COD_ESTAB ||
               ' - PERIODO JÁ PROCESSADO E ENCERRADO: ' ||
               V_RETORNO_STATUS || '---',
               FALSE);
        
        END IF;
      
        --Limpar variaveis para proximo estab
        V_QTD            := 0;
        V_RETORNO_STATUS := '';
        V_SQL            := '';
      
      END LOOP;
    
      --=================================================================================
      -- GERAR ARQUIVO ANALITICO
      --=================================================================================
      LIB_PROC.add_tipo(MPROC_ID,
                        i,
                        TO_CHAR(pdt_ini, 'YYYYMM') ||
                        '_Ret_ICMS_ES_Compete.xls',
                        2);
      LIB_PROC.ADD(DSP_PLANILHA.HEADER, PTIPO => i);
      LIB_PROC.ADD(DSP_PLANILHA.TABELA_INICIO, PTIPO => i);
    
      LIB_PROC.ADD(DSP_PLANILHA.LINHA(P_CONTEUDO => DSP_PLANILHA.CAMPO('SAIDAS') || -- 
                                                    DSP_PLANILHA.CAMPO('') || -- 
                                                    DSP_PLANILHA.CAMPO('') || -- 
                                                    DSP_PLANILHA.CAMPO('') || -- 
                                                    DSP_PLANILHA.CAMPO('') || -- 
                                                    DSP_PLANILHA.CAMPO('') || -- 
                                                    DSP_PLANILHA.CAMPO('') || -- 
                                                    DSP_PLANILHA.CAMPO('') || -- 
                                                    DSP_PLANILHA.CAMPO('') || -- 
                                                    DSP_PLANILHA.CAMPO('') || -- 
                                                    DSP_PLANILHA.CAMPO('') || -- 
                                                    DSP_PLANILHA.CAMPO('') || -- 
                                                    DSP_PLANILHA.CAMPO('') || -- 
                                                    DSP_PLANILHA.CAMPO('') || -- 
                                                    DSP_PLANILHA.CAMPO('') || -- 
                                                    DSP_PLANILHA.CAMPO('') || -- 
                                                    DSP_PLANILHA.CAMPO('') || -- 
                                                    DSP_PLANILHA.CAMPO('') || -- 
                                                    DSP_PLANILHA.CAMPO('') || -- 
                                                    DSP_PLANILHA.CAMPO('') || -- 
                                                    DSP_PLANILHA.CAMPO('') || -- 
                                                    DSP_PLANILHA.CAMPO(''),
                                      P_CLASS    => 'h'),
                   PTIPO => i);
    
      FOR CD IN LISTA_CDs LOOP
      
        LIB_PROC.ADD(DSP_PLANILHA.LINHA(P_CONTEUDO => DSP_PLANILHA.CAMPO('COD_ESTAB') || -- 
                                                      DSP_PLANILHA.CAMPO('UF_ESTAB') || -- 
                                                      DSP_PLANILHA.CAMPO('UF_FORN_CLI') || -- 
                                                      DSP_PLANILHA.CAMPO('DATA_FISCAL') || -- 
                                                      DSP_PLANILHA.CAMPO(DSP_PLANILHA.TEXTO('NUMERO_NF')) || -- 
                                                      DSP_PLANILHA.CAMPO(DSP_PLANILHA.TEXTO('SERIE')) || -- 
                                                      DSP_PLANILHA.CAMPO(DSP_PLANILHA.TEXTO('ID_PEOPLE')) || -- 
                                                      DSP_PLANILHA.CAMPO(DSP_PLANILHA.TEXTO('COD_DOCTO')) || -- 
                                                      DSP_PLANILHA.CAMPO(DSP_PLANILHA.TEXTO('COD_MODELO')) || -- 
                                                      DSP_PLANILHA.CAMPO(DSP_PLANILHA.TEXTO('FIN')) || -- 
                                                      DSP_PLANILHA.CAMPO(DSP_PLANILHA.TEXTO('COD_CFO')) || -- 
                                                      DSP_PLANILHA.CAMPO(DSP_PLANILHA.TEXTO('CST')) || -- 
                                                      DSP_PLANILHA.CAMPO('VLR_CONTABIL') || -- 
                                                      DSP_PLANILHA.CAMPO('BASE_TRIB') || -- 
                                                      DSP_PLANILHA.CAMPO('ALIQ_TRIBUTO_ICMS') || -- 
                                                      DSP_PLANILHA.CAMPO('VLR_ICMS') || -- 
                                                      DSP_PLANILHA.CAMPO('BASE_ISENT') || -- 
                                                      DSP_PLANILHA.CAMPO('BASE_OUTRAS') || -- 
                                                      DSP_PLANILHA.CAMPO('BASE_RED') || -- 
                                                      DSP_PLANILHA.CAMPO('VLR_ICMS_ST') || -- 
                                                      DSP_PLANILHA.CAMPO('VLR_IPI') || -- 
                                                      DSP_PLANILHA.CAMPO('DIF_BASES'),
                                        P_CLASS    => 'h'),
                     PTIPO => i);
      
        FOR CR_R IN (SELECT COD_ESTAB,
                            UF_ESTAB,
                            UF_FORN_CLI,
                            DATA_FISCAL,
                            NUMERO_NF,
                            SERIE,
                            ID_PEOPLE,
                            COD_DOCTO,
                            COD_MODELO,
                            FIN,
                            COD_CFO,
                            CST,
                            VLR_CONTABIL,
                            BASE_TRIB,
                            ALIQ_TRIBUTO_ICMS,
                            VLR_ICMS,
                            BASE_ISENT,
                            BASE_OUTRAS,
                            BASE_RED,
                            VLR_ICMS_ST,
                            VLR_IPI,
                            DIF_BASES
                       FROM MSAFI.DPSP_FIN048_RET_COMPETE
                      WHERE 1 = 1 --UF_ESTAB = MCOD_EMPRESA
                        AND COD_ESTAB = CD.COD_ESTAB
                        AND DATA_FISCAL BETWEEN PDT_INI AND PDT_FIM) LOOP
        
          IF V_CLASS = 'a' THEN
            V_CLASS := 'b';
          ELSE
            V_CLASS := 'a';
          END IF;
        
          V_TEXT01 := DSP_PLANILHA.LINHA(P_CONTEUDO => DSP_PLANILHA.CAMPO(CR_R.COD_ESTAB) || -- 
                                                       DSP_PLANILHA.CAMPO(CR_R.UF_ESTAB) || -- 
                                                       DSP_PLANILHA.CAMPO(CR_R.UF_FORN_CLI) || -- 
                                                       DSP_PLANILHA.CAMPO(CR_R.DATA_FISCAL) || -- 
                                                       DSP_PLANILHA.CAMPO(CR_R.NUMERO_NF) || -- 
                                                       DSP_PLANILHA.CAMPO(CR_R.SERIE) || -- 
                                                       DSP_PLANILHA.CAMPO(CR_R.ID_PEOPLE) || -- 
                                                       DSP_PLANILHA.CAMPO(CR_R.COD_DOCTO) || -- 
                                                       DSP_PLANILHA.CAMPO(CR_R.COD_MODELO) || -- 
                                                       DSP_PLANILHA.CAMPO(CR_R.FIN) || -- 
                                                       DSP_PLANILHA.CAMPO(CR_R.COD_CFO) || -- 
                                                       DSP_PLANILHA.CAMPO(CR_R.CST) || -- 
                                                       DSP_PLANILHA.CAMPO(CR_R.VLR_CONTABIL) || -- 
                                                       DSP_PLANILHA.CAMPO(CR_R.BASE_TRIB) || -- 
                                                       DSP_PLANILHA.CAMPO(CR_R.ALIQ_TRIBUTO_ICMS) || -- 
                                                       DSP_PLANILHA.CAMPO(CR_R.VLR_ICMS) || -- 
                                                       DSP_PLANILHA.CAMPO(CR_R.BASE_ISENT) || -- 
                                                       DSP_PLANILHA.CAMPO(CR_R.BASE_OUTRAS) || -- 
                                                       DSP_PLANILHA.CAMPO(CR_R.BASE_RED) || -- 
                                                       DSP_PLANILHA.CAMPO(CR_R.VLR_ICMS_ST) || -- 
                                                       DSP_PLANILHA.CAMPO(CR_R.VLR_IPI) || -- 
                                                       DSP_PLANILHA.CAMPO(CR_R.DIF_BASES),
                                         
                                         P_CLASS => V_CLASS);
          LIB_PROC.ADD(V_TEXT01, PTIPO => i);
        
        END LOOP;
      END LOOP;
    
      LIB_PROC.ADD(DSP_PLANILHA.TABELA_FIM, PTIPO => i);
    
      i := i + 1;
    
      --=================================================================================
      -- GERAR ARQUIVO SINTETICO
      --=================================================================================
      LIB_PROC.add_tipo(MPROC_ID,
                        i,
                        TO_CHAR(pdt_ini, 'YYYYMM') ||
                        '_Ret_ICMS_ES_Compete_Sintetico.xls',
                        2);
      LIB_PROC.ADD(DSP_PLANILHA.HEADER, PTIPO => i);
      LIB_PROC.ADD(DSP_PLANILHA.TABELA_INICIO, PTIPO => i);
    
      FOR CD IN LISTA_CDs LOOP
      
        LIB_PROC.ADD(DSP_PLANILHA.LINHA(P_CONTEUDO => DSP_PLANILHA.CAMPO('CFO') || --    
                                                      DSP_PLANILHA.CAMPO('VLR_CONTABIL') || --    
                                                      DSP_PLANILHA.CAMPO('BASE_TRIB') || -- 
                                                      DSP_PLANILHA.CAMPO('VLR_ICMS'),
                                        
                                        P_CLASS => 'h'),
                     PTIPO => i);
      
        FOR CR_R IN (   SELECT COD_CFO CFO,
                            SUM(VLR_CONTABIL) VLR_CONTABIL,
                            SUM(BASE_TRIB) AS BASE_TRIB,
                            SUM(VLR_ICMS) AS VLR_ICMS
                       FROM MSAFI.DPSP_FIN048_RET_COMPETE
                      WHERE 1 = 1 --COD_EMPRESA = MCOD_EMPRESA
                        AND COD_ESTAB = CD.COD_ESTAB
                        AND DATA_FISCAL BETWEEN PDT_INI AND PDT_FIM
                      GROUP BY COD_CFO) LOOP
        
          IF V_CLASS = 'a' THEN
            V_CLASS := 'b';
          ELSE
            V_CLASS := 'a';
          END IF;
        
          V_TEXT01 := DSP_PLANILHA.LINHA(P_CONTEUDO => DSP_PLANILHA.CAMPO(CR_R.CFO) || --    
                                                       DSP_PLANILHA.CAMPO(CR_R.VLR_CONTABIL) || --    
                                                       DSP_PLANILHA.CAMPO(CR_R.BASE_TRIB) || --
                                                       DSP_PLANILHA.CAMPO(CR_R.VLR_ICMS),
                                         P_CLASS    => V_CLASS);
          LIB_PROC.ADD(V_TEXT01, PTIPO => i);
        
        END LOOP;
      END LOOP;
    
      LIB_PROC.ADD(DSP_PLANILHA.TABELA_FIM, PTIPO => i);
    
      LOGA('---FIM DO PROCESSAMENTO [SUCESSO]---', FALSE);
    
      --=================================================================================
      -- FIM
      --=================================================================================
      --ENVIAR EMAIL DE SUCESSO----------------------------------------
      ENVIA_EMAIL(MCOD_EMPRESA,
                  V_DATA_INICIAL,
                  V_DATA_FINAL,
                  '',
                  'S',
                  V_DATA_HORA_INI);
      -----------------------------------------------------------------
      IF V_EXISTE_ORIGEM = 'N' THEN
        LIB_PROC.ADD('Há CDs sem dados de origem.');
        LIB_PROC.ADD(' ');
      END IF;
    
      --Em casos de meses diferentes
    ELSE
    
      LIB_PROC.ADD('Processo não permitido:', 1);
      LIB_PROC.ADD('Favor informar somente um único mês entre a Data Inicial e Data Final',
                   1);
      LIB_PROC.ADD(' ', 1);
    
      LOGA(' ', FALSE);
      LOGA('<< PROCESSO NÃO PERMITIDO >>', FALSE);
      LOGA('NÃO É PERMITIDO O PROCESSAMENTO DE MESES DIFERENTES', FALSE);
      LOGA(' ', FALSE);
    
      LOGA('---FIM DO PROCESSAMENTO [ERRO]---', FALSE);
    
    END IF;
  
    LIB_PROC.ADD('Favor verificar LOG para detalhes.');
    LIB_PROC.ADD(' ');
  
    LIB_PROC.CLOSE;
    RETURN MPROC_ID;
  
    /*WHEN OTHERS THEN
    
      LOGA('SQLERRM: ' || SQLERRM, FALSE);
      LIB_PROC.add_log('Erro não tratado: ' ||
                       DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                       1);
      LIB_PROC.add_log('SQLERRM: ' || SQLERRM, 1);
      LIB_PROC.ADD('ERRO!');
      LIB_PROC.ADD(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
    
      --ENVIAR EMAIL DE ERRO-------------------------------------------
      ENVIA_EMAIL(MCOD_EMPRESA,
                  V_DATA_INICIAL,
                  V_DATA_FINAL,
                  SQLERRM,
                  'E',
                  V_DATA_HORA_INI);
      -----------------------------------------------------------------
     
    LIB_PROC.CLOSE;
    COMMIT;
    RETURN MPROC_ID;*/
  
  end;

  PROCEDURE loga(P_I_TEXTO IN VARCHAR2, P_I_DTTM IN BOOLEAN DEFAULT TRUE) IS
    VTEXTO VARCHAR2(1024);
  BEGIN
    IF P_I_DTTM THEN
      VTEXTO := SUBSTR(TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI:SS') || ' - ' ||
                       P_I_TEXTO,
                       1,
                       1024);
    ELSE
      VTEXTO := SUBSTR(P_I_TEXTO, 1, 1024);
    END IF;
    LIB_PROC.ADD_LOG(VTEXTO, 1);
    COMMIT;
  
  END;

  PROCEDURE envia_email(VP_COD_EMPRESA   IN VARCHAR2,
                        VP_DATA_INI      IN DATE,
                        VP_DATA_FIM      IN DATE,
                        VP_MSG_ORACLE    IN VARCHAR2,
                        VP_TIPO          IN VARCHAR2,
                        VP_DATA_HORA_INI IN VARCHAR2) IS
  
    V_TXT_EMAIL  VARCHAR2(2000) := '';
    V_ASSUNTO    VARCHAR2(100) := '';
    V_HORAS      NUMBER;
    V_MINUTOS    NUMBER;
    V_SEGUNDOS   NUMBER;
    V_TEMPO_EXEC VARCHAR2(50);
  
  BEGIN
  
    --CALCULAR TEMPO DE EXECUCAO DO RELATORIO
    SELECT TRUNC(((86400 *
                 (SYSDATE -
                 TO_DATE(VP_DATA_HORA_INI, 'DD/MM/YYYY HH24:MI.SS'))) / 60) / 60) -
           24 *
           (TRUNC((((86400 *
                  (SYSDATE -
                  TO_DATE(VP_DATA_HORA_INI, 'DD/MM/YYYY HH24:MI.SS'))) / 60) / 60) / 24)),
           TRUNC((86400 *
                 (SYSDATE -
                 TO_DATE(VP_DATA_HORA_INI, 'DD/MM/YYYY HH24:MI.SS'))) / 60) -
           60 *
           (TRUNC(((86400 *
                  (SYSDATE -
                  TO_DATE(VP_DATA_HORA_INI, 'DD/MM/YYYY HH24:MI.SS'))) / 60) / 60)),
           TRUNC(86400 *
                 (SYSDATE -
                 TO_DATE(VP_DATA_HORA_INI, 'DD/MM/YYYY HH24:MI.SS'))) -
           60 *
           (TRUNC((86400 *
                  (SYSDATE -
                  TO_DATE(VP_DATA_HORA_INI, 'DD/MM/YYYY HH24:MI.SS'))) / 60))
      INTO V_HORAS, V_MINUTOS, V_SEGUNDOS
      FROM DUAL;
  
    V_TEMPO_EXEC := V_HORAS || ':' || V_MINUTOS || '.' || V_SEGUNDOS;
  
    IF (VP_TIPO = 'E') THEN
      --VP_TIPO = 'E' (ERRO) OU 'S' (SUCESSO)
    
      V_TXT_EMAIL := 'ERRO no Relatório de Devolução de Mercadorias com ICMS-ST!';
      V_TXT_EMAIL := V_TXT_EMAIL || CHR(13) || '>> Parâmetros: ';
      V_TXT_EMAIL := V_TXT_EMAIL || CHR(13) || ' - Empresa : ' ||
                     VP_COD_EMPRESA;
      V_TXT_EMAIL := V_TXT_EMAIL || CHR(13) || ' - Data Início : ' ||
                     VP_DATA_INI;
      V_TXT_EMAIL := V_TXT_EMAIL || CHR(13) || ' - Data Fim : ' ||
                     VP_DATA_FIM;
      V_TXT_EMAIL := V_TXT_EMAIL || CHR(13) || '>> LOG: ';
      V_TXT_EMAIL := V_TXT_EMAIL || CHR(13) || ' - Executado por : ' ||
                     MNM_USUARIO;
      V_TXT_EMAIL := V_TXT_EMAIL || CHR(13) || ' - Hora Início : ' ||
                     VP_DATA_HORA_INI;
      V_TXT_EMAIL := V_TXT_EMAIL || CHR(13) || ' - Hora Término : ' ||
                     TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI.SS');
      V_TXT_EMAIL := V_TXT_EMAIL || CHR(13) || ' - Tempo Execução	: ' ||
                     V_TEMPO_EXEC;
      V_TXT_EMAIL := V_TXT_EMAIL || CHR(13) || '<< ERRO >> ' ||
                     VP_MSG_ORACLE;
      V_ASSUNTO   := 'Mastersaf - Relatório de Devolução de Mercadorias com ICMS-ST apresentou ERRO';
      NOTIFICA('',
               'S',
               V_ASSUNTO,
               V_TXT_EMAIL,
               'DPSP_FIN048_RET_COMPETE_CPROC');
    
    ELSE
    
      V_TXT_EMAIL := 'Processo Relatório de Devolução de Mercadorias com ICMS-ST finalizado com SUCESSO.';
      V_TXT_EMAIL := V_TXT_EMAIL || CHR(13) || '>> Parâmetros: ';
      V_TXT_EMAIL := V_TXT_EMAIL || CHR(13) || ' - Empresa : ' ||
                     VP_COD_EMPRESA;
      V_TXT_EMAIL := V_TXT_EMAIL || CHR(13) || ' - Data Início : ' ||
                     VP_DATA_INI;
      V_TXT_EMAIL := V_TXT_EMAIL || CHR(13) || ' - Data Fim : ' ||
                     VP_DATA_FIM;
      V_TXT_EMAIL := V_TXT_EMAIL || CHR(13) || '>> LOG: ';
      V_TXT_EMAIL := V_TXT_EMAIL || CHR(13) || ' - Executado por : ' ||
                     MNM_USUARIO;
      V_TXT_EMAIL := V_TXT_EMAIL || CHR(13) || ' - Hora Início : ' ||
                     VP_DATA_HORA_INI;
      V_TXT_EMAIL := V_TXT_EMAIL || CHR(13) || ' - Hora Término : ' ||
                     TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI.SS');
      V_TXT_EMAIL := V_TXT_EMAIL || CHR(13) || ' - Tempo Execução : ' ||
                     V_TEMPO_EXEC;
      V_ASSUNTO   := 'Mastersaf - Relatório de Devolução de Mercadorias com ICMS-ST Concluído';
      NOTIFICA('S',
               '',
               V_ASSUNTO,
               V_TXT_EMAIL,
               'DPSP_FIN048_RET_COMPETE_CPROC');
    
    END IF;
  
  END;

  PROCEDURE cabecalho(PNM_EMPRESA     VARCHAR2,
                      PCNPJ           VARCHAR2,
                      V_DATA_HORA_INI VARCHAR2,
                      MNM_CPROC       VARCHAR2,
                      PDT_INI         DATE,
                      PDT_FIM         DATE,
                      PCOD_ESTAB      VARCHAR2) IS
  BEGIN
  
    --=================================================================================
    -- Cabeçalho do DW
    --=================================================================================
    vs_mLinha := null;
    vs_mlinha := lib_str.w(vs_mlinha,
                           'Empresa: ' || MCOD_EMPRESA || ' - ' ||
                           pnm_empresa,
                           1);
    vs_mlinha := lib_str.w(vs_mlinha,
                           'Página : ' || lpad(vn_pagina, 5, '0'),
                           136);
    lib_proc.add(vs_mlinha, null, null, 1);
  
    vs_mlinha := null;
    vs_mlinha := lib_str.w(vs_mlinha, 'CNPJ: ' || pcnpj, 1);
    lib_proc.add(vs_mlinha, null, null, 1);
  
    vs_mlinha := null;
    vs_mlinha := lib_str.w(vs_mlinha,
                           'Data de Processamento : ' || V_DATA_HORA_INI,
                           1);
    lib_proc.add(vs_mlinha, null, null, 1);
  
    vs_mlinha := null;
    vs_mlinha := lib_str.w(vs_mlinha, lpad('-', 150, '-'), 1);
    lib_proc.add(vs_mlinha, null, null, 1);
  
    vs_mlinha := null;
    vs_mlinha := MNM_CPROC;
    lib_proc.add(vs_mlinha, null, null, 1);
  
    vs_mlinha := null;
    vs_mlinha := 'Data Inicial: ' || PDT_INI;
    lib_proc.add(vs_mlinha, null, null, 1);
  
    vs_mlinha := null;
    vs_mlinha := 'Data Final: ' || PDT_FIM;
    lib_proc.add(vs_mlinha, null, null, 1);
  
    vs_mlinha := null;
    vs_mlinha := 'Período para Encerramento: ' ||
                 TO_CHAR(PDT_INI, 'MM/YYYY');
    lib_proc.add(vs_mlinha, null, null, 1);
  
    vs_mlinha := null;
    vs_mlinha := lib_str.w(vs_mlinha, lpad('-', 150, '-'), 1);
    lib_proc.add(vs_mlinha, null, null, 1);
  
    vs_mlinha := null;
    vs_mlinha := lib_str.w(vs_mlinha, lpad('-', 150, '-'), 1);
    lib_proc.add(vs_mlinha, null, null, 1);
  
    vs_mlinha := null;
    vs_mlinha := lib_str.w(vs_mlinha, ' ', 1);
    lib_proc.add(vs_mlinha, null, null, 1);
  
  end cabecalho;

  FUNCTION carregar_NF_entrada(PDT_INI         DATE,
                               PDT_FIM         DATE,
                               PCOD_ESTAB      VARCHAR2,
                               V_DATA_HORA_INI VARCHAR2) RETURN INTEGER IS
  
    CC_LIMIT      NUMBER(7) := 1000;
    V_COUNT_NEW   INTEGER := 0;
    V_PEOPLE_DE   VARCHAR2(5) := (CASE WHEN SUBSTR(PCOD_ESTAB, 1, 2) = 'ST' THEN 'ST' ELSE 'VD' END);
    V_PEOPLE_PARA VARCHAR2(5) := MCOD_EMPRESA; -- DP ou DSP
  
    CURSOR C IS

SELECT *
   FROM (   
      SELECT CAPA.COD_ESTAB,
             EST1.COD_ESTADO UF_ESTAB,
             --X04.COD_FIS_JUR FORN_CLI,
             EST.COD_ESTADO   UF_FORN_CLI,
             CAPA.DATA_FISCAL DATA_FISCAL,
             --CAPA.DATA_EMISSAO DATA_EMISSAO,
             CAPA.NUM_DOCFIS NUMERO_NF,
             CAPA.SERIE_DOCFIS SERIE,
             CAPA.NUM_CONTROLE_DOCTO ID_PEOPLE,
             TIPO.COD_DOCTO COD_DOCTO,
             MODELO.COD_MODELO AS COD_MODELO,
             FIN.COD_NATUREZA_OP FIN,
             CFO.COD_CFO COD_CFO,
             CST.COD_SITUACAO_B CST,
             SUM(ITENS.VLR_CONTAB_ITEM) VLR_CONTABIL,
             SUM(ITENS.VLR_BASE_ICMS_1) BASE_TRIB,
             ITENS.ALIQ_TRIBUTO_ICMS ALIQ_TRIBUTO_ICMS,
             SUM(ITENS.VLR_TRIBUTO_ICMS) VLR_ICMS,
             SUM(ITENS.VLR_BASE_ICMS_2) BASE_ISENT,
             SUM(ITENS.VLR_BASE_ICMS_3) BASE_OUTRAS,
             SUM(ITENS.VLR_BASE_ICMS_4) BASE_RED,
             SUM(ITENS.VLR_TRIBUTO_ICMSS) VLR_ICMS_ST,
             SUM(ITENS.VLR_IPI_NDESTAC) VLR_IPI,
             --
             SUM(ITENS.VLR_CONTAB_ITEM) - SUM(ITENS.VLR_BASE_ICMS_1) -
             SUM(ITENS.VLR_BASE_ICMS_2) - SUM(ITENS.VLR_BASE_ICMS_3) -
             SUM(ITENS.VLR_BASE_ICMS_4) - SUM(ITENS.VLR_TRIBUTO_ICMSS) -
             SUM(ITENS.VLR_IPI_NDESTAC) DIF_BASES,
             MPROC_ID AS PROC_ID,
             MNM_USUARIO AS NM_USUARIO,
             V_DATA_HORA_INI AS DT_CARGA
      
        FROM MSAF.DWT_DOCTO_FISCAL   CAPA,
             MSAF.DWT_ITENS_MERC     ITENS,
             MSAF.X04_PESSOA_FIS_JUR X04,
             MSAF.X2012_COD_FISCAL   CFO,
             MSAF.Y2026_SIT_TRB_UF_B CST,
             MSAF.X2006_NATUREZA_OP  FIN,
             MSAF.ESTADO             EST,
             MSAF.ESTADO             EST1,
             MSAF.ESTABELECIMENTO    ESTAB,
             MSAF.X2005_TIPO_DOCTO   TIPO,
             MSAF.X2024_MODELO_DOCTO MODELO
      
       WHERE 1 = 1
            
         AND CAPA.COD_EMPRESA   = MCOD_EMPRESA
         AND CAPA.COD_ESTAB     = PCOD_ESTAB
         AND CAPA.DATA_FISCAL BETWEEN PDT_INI AND PDT_FIM
            
         AND CAPA.COD_EMPRESA = ITENS.COD_EMPRESA
         AND CAPA.COD_ESTAB = ITENS.COD_ESTAB
         AND CAPA.DATA_FISCAL = ITENS.DATA_FISCAL
         AND CAPA.MOVTO_E_S = ITENS.MOVTO_E_S
         AND CAPA.NORM_DEV = ITENS.NORM_DEV
         AND CAPA.IDENT_DOCTO = ITENS.IDENT_DOCTO
         AND CAPA.IDENT_FIS_JUR = ITENS.IDENT_FIS_JUR
         AND CAPA.NUM_DOCFIS = ITENS.NUM_DOCFIS
         AND CAPA.SERIE_DOCFIS = ITENS.SERIE_DOCFIS
         AND CAPA.SUB_SERIE_DOCFIS = ITENS.SUB_SERIE_DOCFIS
            
         AND CAPA.IDENT_FIS_JUR = X04.IDENT_FIS_JUR
         AND ITENS.IDENT_CFO = CFO.IDENT_CFO
         AND ITENS.IDENT_SITUACAO_B = CST.IDENT_SITUACAO_B
         AND ITENS.IDENT_NATUREZA_OP = FIN.IDENT_NATUREZA_OP
         AND X04.IDENT_ESTADO = EST.IDENT_ESTADO
         AND EST1.IDENT_ESTADO = ESTAB.IDENT_ESTADO
         AND CAPA.IDENT_DOCTO = TIPO.IDENT_DOCTO
         AND CAPA.IDENT_MODELO = MODELO.IDENT_MODELO
         AND CAPA.COD_ESTAB = ESTAB.COD_ESTAB
         AND CAPA.COD_EMPRESA = MSAFI.DPSP.EMPRESA
         AND  CFO.COD_CFO  != '5409'
         AND CAPA.SITUACAO = 'N'
         AND COD_DOCTO NOT IN ('CF', 'CF-E')
      
       GROUP BY CAPA.COD_ESTAB,
                EST1.COD_ESTADO,
                X04.COD_FIS_JUR,
                EST.COD_ESTADO,
                CAPA.DATA_FISCAL,
                CAPA.DATA_EMISSAO,
                CAPA.NUM_DOCFIS,
                CAPA.SERIE_DOCFIS,
                TIPO.COD_DOCTO,
                MODELO.COD_MODELO,
                CFO.COD_CFO,
                CST.COD_SITUACAO_B,
                FIN.COD_NATUREZA_OP,
                ITENS.ALIQ_TRIBUTO_ICMS,
                CAPA.NUM_CONTROLE_DOCTO,
                MPROC_ID,
                MNM_USUARIO,
                V_DATA_HORA_INI  )
                
                
       UNION  ALL 
       
                       
                SELECT 
                      FIN048.COD_ESTAB                  AS COD_ESTAB
                   ,  EST1.COD_ESTADO                   AS UF_ESTAB
                   ,  EST.COD_ESTADO                    AS UF_FORN_CLI
                   ,  FIN048.DATA_FISCAL                AS DATA_FISCAL 
                   ,  FIN048.NUM_DOCFIS                 AS NUMERO_NF
                   ,  FIN048.SERIE_DOCFIS               AS SERIE      --  NOK 
                   ,  FIN048.NUM_CONTROLE_DOCTO         AS ID_PEOPLE
                   ,  FIN048.COD_DOCTO                  AS COD_DOCTO
                   ,  FIN048.COD_MODELO                 AS COD_MODELO
                   ,  FIN048.COD_NATUREZA_OP            AS COD_NATUREZA_OP  -- NOK 
                   ,  FIN048.COD_CFO                    AS COD_CFO
                   ,  FIN048.CST                        AS CST   
                   ,  SUM(NVL(FIN048.VLR_CONTABIL_ITEM,0))     AS VLR_CONTABIL
                   ,  SUM (NVL(FIN048.VLR_BASE_ICMS_3,0))     AS BASE_TRIB
                   ,  FIN048.ALIQ_TRIBUTO_ICMS          AS ALIQ_TRIBUTO_ICMS
                   ,  SUM(FIN048.ICMS_PROPRIO)               AS VLR_ICMS
                   ,  SUM(NVL(FIN048.VLR_BASE_ICMS_2,0))     AS BASE_ISENT
                   ,  SUM(NVL(FIN048.VLR_BASE_ICMS_1,0))     AS BASE_OUTRAS    
                   ,  SUM(NVL(FIN048.VLR_BASE_ICMS_4,0))     AS BASE_RED
                   ,  SUM(NVL(FIN048.VLR_ICMS_ST,0))         AS VLR_TRIBUTO_ICMSS   --OK 
                   ,  SUM(NVL(FIN048.VLR_IPI_NDESTAC,0))     AS VLR_IPI
                   ,   (  SUM(NVL(FIN048.VLR_CONTABIL_ITEM,0))      -
                          SUM(NVL(FIN048.VLR_BASE_ICMS_1,0))      -
                          SUM(NVL(FIN048.VLR_BASE_ICMS_2,0))      -
                          SUM(NVL(FIN048.VLR_BASE_ICMS_3,0))      -
                          SUM(NVL(FIN048.VLR_BASE_ICMS_4,0))      -
                          SUM(NVL(FIN048.VLR_ICMS_ST,0))          -
                          SUM(NVL(FIN048.VLR_IPI_NDESTAC,0))      ) DIF_BASES  ,   
                --
                 MPROC_ID                   AS PROC_ID,
                 MNM_USUARIO                AS NM_USUARIO,
                 V_DATA_HORA_INI            AS DT_CARGA
                FROM  MSAFI.DPSP_FIN048_RET_NF_SAI  FIN048
                ,     ESTABELECIMENTO               ESTAB
                ,     ESTADO                        EST
                ,     ESTADO                        EST1
                ,     X04_PESSOA_FIS_JUR            X04 
                WHERE FIN048.COD_EMPRESA        = MCOD_EMPRESA 
                AND   FIN048.COD_ESTAB          = PCOD_ESTAB
                AND   FIN048.DATA_FISCAL   BETWEEN    PDT_INI AND PDT_FIM
                AND   FIN048.COD_ESTAB          = ESTAB.COD_ESTAB
                AND   X04.IDENT_ESTADO          = EST.IDENT_ESTADO
                AND   EST1.IDENT_ESTADO         = ESTAB.IDENT_ESTADO
                AND   FIN048.COD_FIS_JUR        = X04.COD_FIS_JUR
                 GROUP BY  
                      FIN048.COD_ESTAB              
                   ,  EST1.COD_ESTADO               
                   ,  EST.COD_ESTADO                
                   ,  FIN048.DATA_FISCAL            
                   ,  FIN048.NUM_DOCFIS             
                   ,  FIN048.SERIE_DOCFIS                               -- SERIE      --  NOK 
                   ,  FIN048.NUM_CONTROLE_DOCTO         
                   ,  FIN048.COD_DOCTO                  
                   ,  FIN048.COD_MODELO                 
                   ,  FIN048.COD_NATUREZA_OP                             --  COD_NATUREZA_OP  -- NOK 
                   ,  FIN048.COD_CFO                   
                   ,  FIN048.CST 
                   ,  FIN048.ALIQ_TRIBUTO_ICMS         
        
      
      ;
  
    TYPE TCOD_ESTAB IS TABLE OF MSAFI.DPSP_FIN048_RET_COMPETE.COD_ESTAB%TYPE INDEX BY PLS_INTEGER;
    TYPE TUF_ESTAB IS TABLE OF MSAFI.DPSP_FIN048_RET_COMPETE.UF_ESTAB%TYPE INDEX BY PLS_INTEGER;
    TYPE TUF_FORN_CLI IS TABLE OF MSAFI.DPSP_FIN048_RET_COMPETE.UF_FORN_CLI%TYPE INDEX BY PLS_INTEGER;
    TYPE TDATA_FISCAL IS TABLE OF MSAFI.DPSP_FIN048_RET_COMPETE.DATA_FISCAL%TYPE INDEX BY PLS_INTEGER;
    TYPE TNUMERO_NF IS TABLE OF MSAFI.DPSP_FIN048_RET_COMPETE.NUMERO_NF%TYPE INDEX BY PLS_INTEGER;
    TYPE TSERIE IS TABLE OF MSAFI.DPSP_FIN048_RET_COMPETE.SERIE%TYPE INDEX BY PLS_INTEGER;
    TYPE TID_PEOPLE IS TABLE OF MSAFI.DPSP_FIN048_RET_COMPETE.ID_PEOPLE%TYPE INDEX BY PLS_INTEGER;
    TYPE TCOD_DOCTO IS TABLE OF MSAFI.DPSP_FIN048_RET_COMPETE.COD_DOCTO%TYPE INDEX BY PLS_INTEGER;
    TYPE TCOD_MODELO IS TABLE OF MSAFI.DPSP_FIN048_RET_COMPETE.COD_MODELO%TYPE INDEX BY PLS_INTEGER;
    TYPE TFIN IS TABLE OF MSAFI.DPSP_FIN048_RET_COMPETE.FIN%TYPE INDEX BY PLS_INTEGER;
    TYPE TCOD_CFO IS TABLE OF MSAFI.DPSP_FIN048_RET_COMPETE.COD_CFO%TYPE INDEX BY PLS_INTEGER;
    TYPE TCST IS TABLE OF MSAFI.DPSP_FIN048_RET_COMPETE.CST%TYPE INDEX BY PLS_INTEGER;
    TYPE TVLR_CONTABIL IS TABLE OF MSAFI.DPSP_FIN048_RET_COMPETE.VLR_CONTABIL%TYPE INDEX BY PLS_INTEGER;
    TYPE TBASE_TRIB IS TABLE OF MSAFI.DPSP_FIN048_RET_COMPETE.BASE_TRIB%TYPE INDEX BY PLS_INTEGER;
    TYPE TALIQ_TRIBUTO_ICMS IS TABLE OF MSAFI.DPSP_FIN048_RET_COMPETE.ALIQ_TRIBUTO_ICMS%TYPE INDEX BY PLS_INTEGER;
    TYPE TVLR_ICMS IS TABLE OF MSAFI.DPSP_FIN048_RET_COMPETE.VLR_ICMS%TYPE INDEX BY PLS_INTEGER;
    TYPE TBASE_ISENT IS TABLE OF MSAFI.DPSP_FIN048_RET_COMPETE.BASE_ISENT%TYPE INDEX BY PLS_INTEGER;
    TYPE TBASE_OUTRAS IS TABLE OF MSAFI.DPSP_FIN048_RET_COMPETE.BASE_OUTRAS%TYPE INDEX BY PLS_INTEGER;
    TYPE TBASE_RED IS TABLE OF MSAFI.DPSP_FIN048_RET_COMPETE.BASE_RED%TYPE INDEX BY PLS_INTEGER;
    TYPE TVLR_ICMS_ST IS TABLE OF MSAFI.DPSP_FIN048_RET_COMPETE.VLR_ICMS_ST%TYPE INDEX BY PLS_INTEGER;
    TYPE TVLR_IPI IS TABLE OF MSAFI.DPSP_FIN048_RET_COMPETE.VLR_IPI%TYPE INDEX BY PLS_INTEGER;
    TYPE TDIF_BASES IS TABLE OF MSAFI.DPSP_FIN048_RET_COMPETE.DIF_BASES%TYPE INDEX BY PLS_INTEGER;
    TYPE TPROC_ID IS TABLE OF MSAFI.DPSP_FIN048_RET_COMPETE.PROC_ID%TYPE INDEX BY PLS_INTEGER;
    TYPE TNM_USUARIO IS TABLE OF MSAFI.DPSP_FIN048_RET_COMPETE.NM_USUARIO%TYPE INDEX BY PLS_INTEGER;
    TYPE TDT_CARGA IS TABLE OF MSAFI.DPSP_FIN048_RET_COMPETE.DT_CARGA%TYPE INDEX BY PLS_INTEGER;
  
    V_COD_ESTAB         TCOD_ESTAB;
    V_UF_ESTAB          TUF_ESTAB;
    V_UF_FORN_CLI       TUF_FORN_CLI;
    V_DATA_FISCAL       TDATA_FISCAL;
    V_NUMERO_NF         TNUMERO_NF;
    V_SERIE             TSERIE;
    V_ID_PEOPLE         TID_PEOPLE;
    V_COD_DOCTO         TCOD_DOCTO;
    V_COD_MODELO        TCOD_MODELO;
    V_FIN               TFIN;
    V_COD_CFO           TCOD_CFO;
    V_CST               TCST;
    V_VLR_CONTABIL      TVLR_CONTABIL;
    V_BASE_TRIB         TBASE_TRIB;
    V_ALIQ_TRIBUTO_ICMS TALIQ_TRIBUTO_ICMS;
    V_VLR_ICMS          TVLR_ICMS;
    V_BASE_ISENT        TBASE_ISENT;
    V_BASE_OUTRAS       TBASE_OUTRAS;
    V_BASE_RED          TBASE_RED;
    V_VLR_ICMS_ST       TVLR_ICMS_ST;
    V_VLR_IPI           TVLR_IPI;
    V_DIF_BASES         TDIF_BASES;
    V_PROC_ID           TPROC_ID;
    V_NM_USUARIO        TNM_USUARIO;
    V_DT_CARGA          TDT_CARGA;
  
  BeGIN
  
    OPEN C;
  
    LOOP
      FETCH C BULK COLLECT
        INTO V_COD_ESTAB, V_UF_ESTAB, V_UF_FORN_CLI, V_DATA_FISCAL, V_NUMERO_NF, V_SERIE, V_ID_PEOPLE, V_COD_DOCTO, V_COD_MODELO, V_FIN, V_COD_CFO, V_CST, V_VLR_CONTABIL, V_BASE_TRIB, V_ALIQ_TRIBUTO_ICMS, V_VLR_ICMS, V_BASE_ISENT, V_BASE_OUTRAS, V_BASE_RED, V_VLR_ICMS_ST, V_VLR_IPI, V_DIF_BASES, V_PROC_ID, V_NM_USUARIO, V_DT_CARGA
      
      LIMIT CC_LIMIT;
      FORALL i IN V_COD_ESTAB.FIRST .. V_COD_ESTAB.LAST
      
        INSERT /*+ APPEND */
        INTO MSAFI.DPSP_FIN048_RET_COMPETE
        VALUES
          (V_COD_ESTAB(I),
           V_UF_ESTAB(I),
           V_UF_FORN_CLI(I),
           V_DATA_FISCAL(I),
           V_NUMERO_NF(I),
           V_SERIE(I),
           V_ID_PEOPLE(I),
           V_COD_DOCTO(I),
           V_COD_MODELO(I),
           V_FIN(I),
           V_COD_CFO(I),
           V_CST(I),
           V_VLR_CONTABIL(I),
           V_BASE_TRIB(I),
           V_ALIQ_TRIBUTO_ICMS(I),
           V_VLR_ICMS(I),
           V_BASE_ISENT(I),
           V_BASE_OUTRAS(I),
           V_BASE_RED(I),
           V_VLR_ICMS_ST(I),
           V_VLR_IPI(I),
           V_DIF_BASES(I),
           V_PROC_ID(I),
           V_NM_USUARIO(I),
           V_DT_CARGA(I));
    
      V_COUNT_NEW := V_COUNT_NEW + SQL%ROWCOUNT;
    
      DBMS_APPLICATION_INFO.SET_MODULE($$PLSQL_UNIT,
                                       'Estab: ' || PCOD_ESTAB || ' Qtd ' ||
                                       V_COUNT_NEW);
    
      COMMIT;
    
      V_COD_ESTAB.DELETE;
      V_UF_ESTAB.DELETE;
      V_UF_FORN_CLI.DELETE;
      V_DATA_FISCAL.DELETE;
      V_NUMERO_NF.DELETE;
      V_SERIE.DELETE;
      V_ID_PEOPLE.DELETE;
      V_COD_DOCTO.DELETE;
      V_COD_MODELO.DELETE;
      V_FIN.DELETE;
      V_COD_CFO.DELETE;
      V_CST.DELETE;
      V_VLR_CONTABIL.DELETE;
      V_BASE_TRIB.DELETE;
      V_ALIQ_TRIBUTO_ICMS.DELETE;
      V_VLR_ICMS.DELETE;
      V_BASE_ISENT.DELETE;
      V_BASE_OUTRAS.DELETE;
      V_BASE_RED.DELETE;
      V_VLR_ICMS_ST.DELETE;
      V_VLR_IPI.DELETE;
      V_DIF_BASES.DELETE;
      V_PROC_ID.DELETE;
      V_NM_USUARIO.DELETE;
      V_DT_CARGA.DELETE;
    
      EXIT WHEN C%NOTFOUND;
    
    END LOOP;
    CLOSE C;
  
    COMMIT;
  
    LOGA('::QUANTIDADE DE REGISTROS INSERIDOS (DPSP_FIN048_RET_NF_ENT) , CD: ' ||
         PCOD_ESTAB || ' - QTDE ' || NVL(V_COUNT_NEW, 0) || '::',
         FALSE);
  
    RETURN NVL(V_COUNT_NEW, 0);
  
  END;
END DPSP_FIN048_RET_COMPETE_CPROC;
/

Show errors;
