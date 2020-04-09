CREATE OR REPLACE PACKAGE BODY MSAF.DPSP_FIN048_RET_SAIDA_CPROC IS
  MPROC_ID     NUMBER;
  VN_LINHA     NUMBER := 0;
  VN_PAGINA    NUMBER := 0;
  MNM_USUARIO  USUARIO_ESTAB.COD_USUARIO%TYPE;
  MCOD_EMPRESA ESTABELECIMENTO.COD_EMPRESA%TYPE;
  VS_MLINHA    VARCHAR2(4000);
  VP_TAB_ALIQ VARCHAR2(30);
  VP_TAB_AUX VARCHAR2(30);
  VP_TAB_PROD VARCHAR2(30);
  
  V_SQL VARCHAR2(32767);
  V_QTDE NUMBER := 0;
  v_valor  VARCHAR2(30);
  v_valor_2  VARCHAR2(30);
  v_valor_3  VARCHAR2(30);
  --

  --Tipo, Nome e Descrição do Customizado
  --Melhoria FIN048
  MNM_TIPO  VARCHAR2(100) := 'Retificação ICMS ES';
  MNM_CPROC VARCHAR2(100) := '2. Relatório de Notas Fiscais de Saída para retificacao apuração ICMS (ES)';
  MDS_CPROC VARCHAR2(100) := 'Processo para ajuste de Notas de Saída';
  
  V_SEL_DATA_FIM  VARCHAR2(260) := 'SELECT TRUNC( TO_DATE( :1 ,''DD/MM/YYYY'') + ROWNUM - 1) AS DATA_FIM, TRUNC( TO_DATE( :1 ,''DD/MM/YYYY'') + ROWNUM - 1) AS DATA_FIM FROM DUAL CONNECT BY ROWNUM <= LAST_DAY( TO_DATE( :1 ,''DD/MM/YYYY'') ) - TO_DATE( :1 ,''DD/MM/YYYY'') + 1 ORDER BY 1 DESC '; 

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
  
  
  LIB_PROC.ADD_PARAM(PSTR,
                           'Data Final', --P_DATA_FIM
                           'VARCHAR2',
                           'COMBOBOX',
                           'S',
                           NULL,
                           '##########',
                           V_SEL_DATA_FIM
                           );               
  
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
  
    lib_proc.add_param(pparam      => pstr,
                       ptitulo     => LPAD('-', 60, '-') || 'Notas de Saída' ||
                                      LPAD('-', 60, '-'),
                       ptipo       => 'Varchar2',
                       pcontrole   => 'Text',
                       pmandatorio => 'N',
                       pdefault    => 'N',
                       pmascara    => null,
                       pvalores    => null,
                       papresenta  => 'N');
--  
    lib_proc.add_param(pparam      => pstr,
                       ptitulo     => 'Saídas internas no CFOP 5.409',
                       ptipo       => 'Varchar2',
                       pcontrole   => 'Text',
                       pmandatorio => 'N',
                       pdefault    => 'N',
                       pmascara    => null,
                       pvalores    => null,
                       papresenta  => 'N');
  
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
  
   FUNCTION carregar_NF_saida(PDT_INI         DATE,
                             PDT_FIM         DATE,
                             PCOD_ESTAB      VARCHAR2,
                             V_DATA_HORA_INI VARCHAR2) RETURN INTEGER IS
  
    CC_LIMIT      NUMBER(7) := 1000;
    V_COUNT_NEW   INTEGER := 0;
    V_PEOPLE_DE   VARCHAR2(5) := (CASE WHEN SUBSTR(PCOD_ESTAB, 1, 2) = 'ST' THEN 'ST' ELSE 'VD' END);
    V_PEOPLE_PARA VARCHAR2(5) := MCOD_EMPRESA; -- DP ou DSP
   -- MSAFI.DPSP_FIN048_RET_NF_SAI
    
     TYPE  FIN048_RET_NF_SAI_TYP IS TABLE OF  MSAFI.DPSP_FIN048_RET_NF_SAI%ROWTYPE;
     L_TB_FIN048_RET_NF_SAI       FIN048_RET_NF_SAI_TYP := FIN048_RET_NF_SAI_TYP();
    
   forall_failed           EXCEPTION;
    PRAGMA EXCEPTION_INIT (forall_failed, -24381);
    
  --  CURSOR CR_FIN48_SAIDA IS
  
  l_errors number;
    l_errno    number;
    l_msg    varchar2(4000);
    l_idx    number;
    
    --    
    V_COUNT INTEGER DEFAULT 0;
    C_AUX SYS_REFCURSOR;
  
   -- V_SQL VARCHAR2(8000);
   
 -- ;
 
 PROCEDURE PROC_UPD_SAIDA ( PDT_INI DATE, PDT_FIM DATE, PCOD_ESTAB VARCHAR2)
  IS 
 
    V_COUNT_NEW  NUMBER;    
    V_SQL VARCHAR2(5000);
    ICMS_ST_S NUMBER(17,6);

    BEGIN
      
     -- ATUALIZA TRANSALATE
     MSAFI.UPD_PS_TRANSLATE('DSP_ALIQ_ICMS');
     MSAFI.UPD_PS_TRANSLATE('DSP_ST_TRIBUT_ICMS');
     MSAFI.UPD_PS_TRANSLATE('DSP_TP_CALC_ST');
   
     -- EXECUTE IMMEDIATE  'TRUNCATE TABLE PS_DSP_ITEM_LN_GTT';

      IF   TO_CHAR (PDT_INI, 'YYYY')  = '2016'   AND  TO_CHAR (PDT_FIM, 'YYYY')  = '2016'
        THEN 
        

        FOR i
            IN (
                   SELECT F48.ROWID AS F48_ROWID , F48.*
                   FROM MSAFI.DPSP_FIN048_RET_NF_SAI  F48
                   WHERE COD_EMPRESA = 'DP'
                   AND   COD_ESTAB   = PCOD_ESTAB
                   AND   DATA_FISCAL BETWEEN PDT_INI  AND  PDT_FIM
               )
        LOOP
        
        
        FOR j
            IN (
                   SELECT   i.F48_ROWID
                             ---  ICMS_ST  
                      ,      (
                                SELECT ROUND ( (CASE WHEN (BC_ICMS_ST * (ALIQUOTA_INTERNA / 100)) - ICMS_PROPRIO < 0 THEN 0 
                                  ELSE
                                      (BC_ICMS_ST * (ALIQUOTA_INTERNA / 100)) - ICMS_PROPRIO END), 2)
                                    FROM (SELECT /*+DRIVING_SITE(TAB)*/
                                           (CASE
                                             WHEN NVL (PMC.PMC_PAUTA, 0) > 0   THEN  (  PMC.PMC_PAUTA  * i.QUANTIDADE) * (1 - TAB.DSP_PCT_RED_ICMSST/100)  
                                             WHEN NVL (PMC.PMC_PAUTA , 0) = 0  THEN  (  i.VLR_ITEM  * (1 + MVA_PCT_BBL/100)  * (1 - DSP_PCT_RED_ICMSST/100))   END)                AS BC_ICMS_ST
                                          , (   i.VLR_ITEM  * REPLACE(REPLACE (MSAFI.PS_TRANSLATE('DSP_ALIQ_ICMS',NVL(TRIM(DSP_ALIQ_ICMS),0)), '%', ''),'<VLR INVALIDO>',''/100)  * (1 - DSP_PCT_RED_ICMSST/100))  AS ICMS_PROPRIO                                                              
                                              ,REPLACE(REPLACE (MSAFI.PS_TRANSLATE('DSP_ALIQ_ICMS',NVL(TRIM(DSP_ALIQ_ICMS),0)), '%', ''),'<VLR INVALIDO>','')                                         AS ALIQUOTA_INTERNA
                                         , RANK ()  OVER (  PARTITION BY TAB.SETID , TAB.INV_ITEM_ID ORDER BY TAB.EFFDT DESC)                                             AS RANK
                                      FROM MSAFI.PS_DSP_LN_MVA_HIS TAB
                                       ,   MSAFI.DSP_ESTABELECIMENTO EST,
                                       ( SELECT  PMC_PAUTA , INV_ITEM_ID, DSP_ALIQ_ICMS_ID
                                                 FROM ( 
                                                 SELECT /*+DRIVING_SITE(TAB)*/ 
                                                        TAB.DSP_PMC  PMC_PAUTA, 
                                                        TAB.INV_ITEM_ID,
                                                        TAB.DSP_ALIQ_ICMS_ID,
                                               RANK() OVER (PARTITION BY TAB.SETID, TAB.INV_ITEM_ID ORDER BY TAB.EFFDT DESC) AS RANK   
                                                 FROM MSAFI.PS_DSP_PRECO_ITEM     TAB                                                   
                                                 WHERE TAB.SETID             = 'GERAL'   
                                                  AND TAB.INV_ITEM_ID       = i.COD_PRODUTO   
                                                  AND TAB.EFFDT             <= i.DATA_FISCAL
                                                  AND TAB.UNIT_OF_MEASURE = 'UN'
                                                 )  WHERE RANK = 1 )  PMC                                        
                                                                                 WHERE TAB.SETID                 = 'GERAL'
                                        AND   TAB.INV_ITEM_ID           = i.COD_PRODUTO
                                        AND   EST.COD_EMPRESA           = i.COD_EMPRESA
                                        AND   EST.COD_ESTAB             = i.COD_ESTAB
                                        AND   PMC.INV_ITEM_ID(+)      = i.COD_PRODUTO
                                        AND   PMC.DSP_ALIQ_ICMS_ID(+)      = REPLACE(REPLACE(MSAFI.PS_TRANSLATE('DSP_ALIQ_ICMS',NVL(TRIM(DSP_ALIQ_ICMS),0)), ' ', ''),'<VLR INVALIDO>','')                                        
                                        AND   TAB.CRIT_STATE_TO_PBL     = 'ES'
                                        AND   TAB.CRIT_STATE_FR_PBL     = 'ES'
                                        AND   TAB.EFFDT <= i.DATA_FISCAL)   
                                            WHERE RANK = 1         )                                    AS ICMS_ST
                                     --
                                    
                                  ,  ( SELECT  ROUND(BC_ICMS_ST,2)
                                           FROM (  
                                          SELECT /*+DRIVING_SITE(TAB)*/ 
                                             ( CASE WHEN  nvl(PMC.PMC_PAUTA, 0) > 0 THEN  (  PMC.PMC_PAUTA*i.QUANTIDADE ) *(  1- TAB.DSP_PCT_RED_ICMSST /100)
                                                    WHEN  nvl(PMC.PMC_PAUTA,0)  = 0 THEN  ( i.VLR_ITEM * ( 1 + MVA_PCT_BBL /100) * (1 - DSP_PCT_RED_ICMSST/100) ) END) BC_ICMS_ST
                                                                                           
                                         , RANK() OVER (PARTITION BY TAB.SETID, TAB.INV_ITEM_ID ORDER BY TAB.EFFDT DESC) AS RANK   
                                         FROM MSAFI.PS_DSP_LN_MVA_HIS      TAB
                                        ,     MSAFI.DSP_ESTABELECIMENTO    EST,
                                       ( SELECT  PMC_PAUTA , INV_ITEM_ID, DSP_ALIQ_ICMS_ID
        FROM ( 
        SELECT /*+DRIVING_SITE(TAB)*/ 
               TAB.DSP_PMC  PMC_PAUTA, 
               TAB.INV_ITEM_ID,
               TAB.DSP_ALIQ_ICMS_ID,
      RANK() OVER (PARTITION BY TAB.SETID, TAB.INV_ITEM_ID ORDER BY TAB.EFFDT DESC) AS RANK   
        FROM MSAFI.PS_DSP_PRECO_ITEM   TAB        
        WHERE TAB.SETID             = 'GERAL'   
         AND TAB.INV_ITEM_ID       = i.COD_PRODUTO   
         AND TAB.EFFDT             <= i.DATA_FISCAL
         AND TAB.UNIT_OF_MEASURE = 'UN'
        )  WHERE RANK = 1 )  PMC                                                                                                 
                                        WHERE TAB.SETID             = 'GERAL'   
                                         AND  TAB.INV_ITEM_ID       = i.COD_PRODUTO   
                                         AND  EST.COD_EMPRESA       = i.COD_EMPRESA                                                      
                                         AND  EST.COD_ESTAB         = i.COD_ESTAB 
                                         AND  PMC.INV_ITEM_ID(+)      = i.COD_PRODUTO
                                         AND  PMC.DSP_ALIQ_ICMS_ID(+)      = REPLACE(REPLACE (MSAFI.PS_TRANSLATE('DSP_ALIQ_ICMS',NVL(TRIM(DSP_ALIQ_ICMS),0)), ' ', ''),'<VLR INVALIDO>','')                                        
                                         AND  TAB.CRIT_STATE_TO_PBL = EST.COD_ESTADO   
                                         AND  TAB.CRIT_STATE_FR_PBL = EST.COD_ESTADO   
                                         AND TAB.EFFDT             <= i.DATA_FISCAL   
                                        )  WHERE RANK = 1 )         AS    BC_ICMS_ST   --39 
                    
                        ,         ( SELECT  ICMS_PROPRIO/100
                                     FROM (  
                                    SELECT /*+DRIVING_SITE(TAB)*/ 
                                   ((i.VLR_ITEM *  REPLACE(REPLACE (MSAFI.PS_TRANSLATE('DSP_ALIQ_ICMS',NVL(TRIM(DSP_ALIQ_ICMS),0)), '%', ''),'<VLR INVALIDO>',''/100)  * (1 - DSP_PCT_RED_ICMSST /100 )) )      AS  ICMS_PROPRIO
                                     --   TAB.DSP_ALIQ_ICMS       AS  ICMS_PROPRIO
                                       , RANK() OVER (PARTITION BY TAB.SETID, TAB.INV_ITEM_ID ORDER BY TAB.EFFDT DESC)                   AS  RANK   
                                    FROM MSAFI.PS_DSP_LN_MVA_HIS     TAB                                                                               
                                    WHERE TAB.SETID             = 'GERAL'   
                                     AND  TAB.INV_ITEM_ID       = i.COD_PRODUTO                                       
                                     AND  TAB.CRIT_STATE_TO_PBL = 'ES'  
                                     AND  TAB.CRIT_STATE_FR_PBL = 'ES'   
                                     AND TAB.EFFDT             <= i.DATA_FISCAL
                                    )  WHERE RANK = 1 )     AS    ICMS_PROPRIO  --38
                                    
                                    
                    
                              ,          (SELECT ALIQ_INTERNA
                                                   FROM (
                                                SELECT    /*+DRIVING_SITE(A)*/ 
                                                   RANK() OVER (PARTITION BY SETID, INV_ITEM_ID ORDER BY EFFDT DESC) RANK,
                                                NVL((REPLACE(REPLACE (MSAFI.PS_TRANSLATE('DSP_ALIQ_ICMS',NVL(TRIM(DSP_ALIQ_ICMS),0)), '%', ''),'<VLR INVALIDO>','')), 0)        AS ALIQ_INTERNA
                                                FROM MSAFI.PS_DSP_LN_MVA_HIS A
                                                 WHERE INV_ITEM_ID       =  i.COD_PRODUTO
                                                 AND    CRIT_STATE_TO_PBL = 'ES'
                                                 AND    CRIT_STATE_FR_PBL = 'ES'
                                                 AND    SETID             = 'GERAL'
                                                 AND    EFFDT            <= i.DATA_FISCAL)     
                                                 WHERE RANK = 1   )                                                                     AS ALIQ_INTERNA  --36 
                       
,    ( SELECT  FINALIDADE  
        FROM ( 
        SELECT /*+DRIVING_SITE(TAB)*/ 
               TAB.PURCH_PROP_BRL  FINALIDADE 
      , RANK() OVER (PARTITION BY TAB.SETID, TAB.INV_ITEM_ID ORDER BY TAB.EFFDT DESC) AS RANK   
        FROM MSAFI.PS_DSP_LN_MVA_HIS     TAB
         ,    MSAFI.DSP_ESTABELECIMENTO  EST                                                         
        WHERE TAB.SETID             = 'GERAL'   
         AND  TAB.INV_ITEM_ID       = i.COD_PRODUTO   
         AND  EST.COD_EMPRESA       = i.COD_EMPRESA                                                      
         AND  EST.COD_ESTAB         = i.COD_ESTAB 
         AND  TAB.CRIT_STATE_TO_PBL = EST.COD_ESTADO   
         AND  TAB.CRIT_STATE_FR_PBL = EST.COD_ESTADO   
         AND TAB.EFFDT             <= i.DATA_FISCAL
        )  WHERE RANK = 1 )                                                         AS    FINALIDADE     -- 35 
                                                 
          
  ,    ( SELECT  PERC_RED_BSST  
        FROM ( 
        SELECT /*+DRIVING_SITE(TAB)*/ 
               TAB.DSP_PCT_RED_ICMSST  PERC_RED_BSST 
      , RANK() OVER (PARTITION BY TAB.SETID, TAB.INV_ITEM_ID ORDER BY TAB.EFFDT DESC) AS RANK   
        FROM MSAFI.PS_DSP_LN_MVA_HIS     TAB
        ,    MSAFI.DSP_ESTABELECIMENTO    EST                                                         
        WHERE TAB.SETID             = 'GERAL'   
         AND  TAB.INV_ITEM_ID       = i.COD_PRODUTO   
         AND  EST.COD_EMPRESA       = i.COD_EMPRESA                                                      
         AND  EST.COD_ESTAB         = i.COD_ESTAB 
         AND  TAB.CRIT_STATE_TO_PBL = EST.COD_ESTADO   
         AND  TAB.CRIT_STATE_FR_PBL = EST.COD_ESTADO   
         AND TAB.EFFDT             <= i.DATA_FISCAL
        )  WHERE RANK = 1 )                                                         AS    PERC_RED_BSST     --34                                  
 --
          ,( SELECT  MVA_PCT_BBL  
            FROM ( 
           SELECT /*+DRIVING_SITE(TAB)*/ 
              TAB.MVA_PCT_BBL 
         , RANK() OVER (PARTITION BY TAB.SETID, TAB.INV_ITEM_ID ORDER BY TAB.EFFDT DESC) AS RANK   
           FROM MSAFI.PS_DSP_LN_MVA_HIS     TAB
        ,    MSAFI.DSP_ESTABELECIMENTO    EST                                                         
            WHERE TAB.SETID             = 'GERAL'   
             AND  TAB.INV_ITEM_ID       = i.COD_PRODUTO   
             AND  EST.COD_EMPRESA       = i.COD_EMPRESA                                                      
             AND  EST.COD_ESTAB         = i.COD_ESTAB 
             AND  TAB.CRIT_STATE_TO_PBL = EST.COD_ESTADO   
             AND  TAB.CRIT_STATE_FR_PBL = EST.COD_ESTADO   
             AND TAB.EFFDT             <= i.DATA_FISCAL
            )  WHERE RANK = 1 )                                                          AS    MVA      -- 30
        ---    
        -- PMC_PAUTA
        ---  
    , ( SELECT  NVL((PMC_PAUTA), 0) PMC_PAUTA  
        FROM ( 
        SELECT /*+DRIVING_SITE(TAB)*/ 
               PMC.PMC_PAUTA  PMC_PAUTA
      , RANK() OVER (PARTITION BY TAB.SETID, TAB.INV_ITEM_ID ORDER BY TAB.EFFDT DESC) AS RANK   
        FROM MSAFI.PS_DSP_LN_MVA_HIS     TAB
        ,    MSAFI.DSP_ESTABELECIMENTO    EST,
         ( SELECT  PMC_PAUTA , INV_ITEM_ID, DSP_ALIQ_ICMS_ID
        FROM ( 
        SELECT /*+DRIVING_SITE(TAB)*/ 
               NVL((TAB.DSP_PMC),0)  PMC_PAUTA, 
               TAB.INV_ITEM_ID,
               TAB.DSP_ALIQ_ICMS_ID,
      RANK() OVER (PARTITION BY TAB.SETID, TAB.INV_ITEM_ID ORDER BY TAB.EFFDT DESC) AS RANK   
        FROM MSAFI.PS_DSP_PRECO_ITEM     TAB        
        WHERE TAB.SETID             = 'GERAL'   
         AND TAB.INV_ITEM_ID       = i.COD_PRODUTO   
         AND TAB.EFFDT             <= i.DATA_FISCAL
         AND TAB.UNIT_OF_MEASURE = 'UN'
        )  WHERE RANK = 1 )  PMC                                                                                                     
        WHERE TAB.SETID             = 'GERAL'   
         AND  TAB.INV_ITEM_ID       = i.COD_PRODUTO   
         AND  EST.COD_EMPRESA       = i.COD_EMPRESA                                                      
         AND  EST.COD_ESTAB         = i.COD_ESTAB
         AND  PMC.INV_ITEM_ID(+)      = i.COD_PRODUTO
         AND  PMC.DSP_ALIQ_ICMS_ID(+)      = REPLACE (MSAFI.PS_TRANSLATE('DSP_ALIQ_ICMS',NVL(TRIM(DSP_ALIQ_ICMS),0)), ' ', '')
         AND  TAB.CRIT_STATE_TO_PBL = EST.COD_ESTADO   
         AND  TAB.CRIT_STATE_FR_PBL = EST.COD_ESTADO   
         AND TAB.EFFDT             <= i.DATA_FISCAL
        )  WHERE RANK = 1 )                                                             AS    PMC_PAUTA        --- 31 
      ---  
      -- TP_CALC
      --- 
 ,    ( SELECT  TP_CALC 
        FROM ( 
        SELECT /*+DRIVING_SITE(TAB)*/ 
               REPLACE(REPLACE(MSAFI.PS_TRANSLATE('DSP_TP_CALC_ST',NVL(TRIM(TAB.DSP_TP_CALC_ST),0)), ' ', ''),'<VLR INVALIDO>','')   TP_CALC
      , RANK() OVER (PARTITION BY TAB.SETID, TAB.INV_ITEM_ID ORDER BY TAB.EFFDT DESC) AS RANK   
        FROM MSAFI.PS_DSP_LN_MVA_HIS     TAB
        ,    MSAFI.DSP_ESTABELECIMENTO    EST                                                         
        WHERE TAB.SETID             = 'GERAL'   
         AND  TAB.INV_ITEM_ID       = i.COD_PRODUTO   
         AND  EST.COD_EMPRESA       = i.COD_EMPRESA                                                      
         AND  EST.COD_ESTAB         = i.COD_ESTAB 
         AND  TAB.CRIT_STATE_TO_PBL = EST.COD_ESTADO   
         AND  TAB.CRIT_STATE_FR_PBL = EST.COD_ESTADO   
         AND TAB.EFFDT             <= i.DATA_FISCAL
        )  WHERE RANK = 1 )                                                              AS    TP_CALC    -- 32 
      --  
      -- SIT_TRIB
      --  
    ,( SELECT  SIT_TRIB 
        FROM ( 
        SELECT /*+DRIVING_SITE(TAB)*/ 
              REPLACE(REPLACE(MSAFI.PS_TRANSLATE('DSP_ST_TRIBUT_ICMS',NVL(TRIM(TAB.DSP_ST_TRIBUT_ICMS),0)), ' ', ''),'<VLR INVALIDO>','')    SIT_TRIB  
      , RANK() OVER (PARTITION BY TAB.SETID, TAB.INV_ITEM_ID ORDER BY TAB.EFFDT DESC) AS RANK   
        FROM MSAFI.PS_DSP_LN_MVA_HIS     TAB
        ,    MSAFI.DSP_ESTABELECIMENTO    EST                                                         
        WHERE TAB.SETID             = 'GERAL'   
         AND  TAB.INV_ITEM_ID       = i.COD_PRODUTO   
         AND  EST.COD_EMPRESA       = i.COD_EMPRESA                                                      
         AND  EST.COD_ESTAB         = i.COD_ESTAB 
         AND  TAB.CRIT_STATE_TO_PBL = EST.COD_ESTADO   
         AND  TAB.CRIT_STATE_FR_PBL = EST.COD_ESTADO   
         AND TAB.EFFDT             <= i.DATA_FISCAL
        )  WHERE RANK = 1 )                                                             AS    SIT_TRIB    --  33                               
                          
                                    
                   FROM DUAL
               )
        LOOP                         
                     BEGIN
                        
                     ICMS_ST_S :=   (j.BC_ICMS_ST * (j.ALIQ_INTERNA/100)) - j.ICMS_PROPRIO;
                     
                     IF ICMS_ST_S > 0 THEN
                     ICMS_ST_S := ICMS_ST_S;
                     ELSE
                     ICMS_ST_S := 0;
                     END IF;
                     
                     
                         UPDATE MSAFI.DPSP_FIN048_RET_NF_SAI
                           SET MVA                = j.MVA,
                               PMC_PAUTA          = j.PMC_PAUTA,
                               TP_CALC            = j.TP_CALC,
                               SIT_TRIB           = j.SIT_TRIB,
                               PERC_RED_BSST      = j.PERC_RED_BSST,
                               FINALIDADE         = j.FINALIDADE,
                               ALIQUOTA_INTERNA   = j.ALIQ_INTERNA,
                               ICMS_PROPRIO       = j.ICMS_PROPRIO,
                               BC_ICMS_ST         = j.BC_ICMS_ST,
                               --ICMS_ST            = (j.BC_ICMS_ST * (j.ALIQ_INTERNA/100)) - j.ICMS_PROPRIO,
                               ICMS_ST            = ICMS_ST_S,
                               COD_ESTADO_TO      = 'ES',
                               COD_ESTADO_FROM    = 'ES'
                             WHERE ROWID          = j.F48_ROWID ;                                                         
                                                         
                                V_COUNT_NEW := V_COUNT_NEW + 1;
                         
                                commit;
                    DBMS_APPLICATION_INFO.SET_MODULE ('ATUALIZANDO - > ', V_COUNT_NEW);
                    -- Rastreio
                    /*INSERT  INTO  MSAFI.LOG_GERAL
                                   (ora_err_number1, ora_err_mesg1, ora_err_optyp1) 
                                   
                                   VALUES ( j.PMC_PAUTA
                                   , j.ALIQ_INTERNA
                                   , j.BC_ICMS_ST);
                    COMMIT;*/
                    
                    EXCEPTION 
                    WHEN OTHERS THEN
                      dbms_output.put_line('Backtrace => '||dbms_utility.format_error_backtrace);
                    
                    loga(j.F48_ROWID, FALSE) ;
                       
                   END ;
      
         
        END LOOP;
        
    END LOOP;
    COMMIT ; 
    
    END IF ;
    
    
    
END    PROC_UPD_SAIDA;



BEGIN

   -- v_valor  VARCHAR2(30);
    
      --- Cria tabela de produtos 
      VP_TAB_PROD := MSAF.DPSP_CREATE_TAB_TMP(MPROC_ID, MPROC_ID, 'TAB_PROD', MNM_USUARIO);
      IF (VP_TAB_PROD = 'ERRO') THEN
        RAISE_APPLICATION_ERROR (-20001, '!ERRO CREATE_PROD_TABLE!');
      END IF;
        LOGA(VP_TAB_PROD);
      ---- Carrega Tabela de produtos
      BEGIN
          
        V_SQL := '   INSERT INTO '|| VP_TAB_PROD ||' ';
        V_SQL := V_SQL || ' SELECT DISTINCT COD_PRODUTO, X07.DATA_FISCAL';
        V_SQL := V_SQL || ' FROM MSAF.X07_DOCTO_FISCAL        X07, ';
        V_SQL := V_SQL || '     MSAF.X08_ITENS_MERC          X08, ';
        V_SQL := V_SQL || '     MSAF.X04_PESSOA_FIS_JUR      X04, ';
        V_SQL := V_SQL || '        MSAF.ESTADO                  ESTADO, ';   
        V_SQL := V_SQL || '        MSAF.X2005_TIPO_DOCTO        X2005, '; 
        V_SQL := V_SQL || '        MSAF.X2024_MODELO_DOCTO      X2024, ';
        V_SQL := V_SQL || '        MSAF.X2012_COD_FISCAL        X2012, ';
        V_SQL := V_SQL || '        MSAF.X2013_PRODUTO           X2013, ';
        V_SQL := V_SQL || '        MSAF.X2043_COD_NBM           X2043, ';
        V_SQL := V_SQL || '        MSAF.Y2025_SIT_TRB_UF_A      Y2025, ';
        V_SQL := V_SQL || '        MSAF.Y2026_SIT_TRB_UF_B      Y2026, ';
        V_SQL := V_SQL || '        MSAF.X2006_NATUREZA_OP       X2006  ';      
        V_SQL := V_SQL || '  WHERE  X07.COD_EMPRESA         = X08.COD_EMPRESA ';
        V_SQL := V_SQL || '      AND X07.COD_ESTAB          = X08.COD_ESTAB   ';
        V_SQL := V_SQL || '      AND X07.DATA_FISCAL        = X08.DATA_FISCAL ';
        V_SQL := V_SQL || '      AND X07.MOVTO_E_S          = X08.MOVTO_E_S   ';
        V_SQL := V_SQL || '      AND X07.NORM_DEV           = X08.NORM_DEV    ';
        V_SQL := V_SQL || '      AND X07.IDENT_DOCTO        = X08.IDENT_DOCTO ';
        V_SQL := V_SQL || '      AND X07.IDENT_FIS_JUR      = X08.IDENT_FIS_JUR ';
        V_SQL := V_SQL || '      AND X07.NUM_DOCFIS         = X08.NUM_DOCFIS    ';
        V_SQL := V_SQL || '      AND X07.SERIE_DOCFIS       = X08.SERIE_DOCFIS  ';
        V_SQL := V_SQL || '      AND X07.SUB_SERIE_DOCFIS   = X08.SUB_SERIE_DOCFIS  ';
        V_SQL := V_SQL || '      AND X07.IDENT_MODELO       = X2024.IDENT_MODELO    ';
        V_SQL := V_SQL || '      AND X07.IDENT_FIS_JUR      = X04.IDENT_FIS_JUR     ';
        V_SQL := V_SQL || '      AND X07.IDENT_DOCTO        = X2005.IDENT_DOCTO     ';
        V_SQL := V_SQL || '      AND X04.IDENT_ESTADO       = ESTADO.IDENT_ESTADO   ';
        V_SQL := V_SQL || '      AND X08.IDENT_CFO          = X2012.IDENT_CFO       ';
        V_SQL := V_SQL || '      AND X08.IDENT_PRODUTO      = X2013.IDENT_PRODUTO   ';
        V_SQL := V_SQL || '      AND X2013.IDENT_NBM        = X2043.IDENT_NBM       ';
        V_SQL := V_SQL || '      AND Y2025.IDENT_SITUACAO_A = X08.IDENT_SITUACAO_A  ';
        V_SQL := V_SQL || '      AND X08.IDENT_SITUACAO_B   = Y2026.IDENT_SITUACAO_B   ';
        V_SQL := V_SQL || '      AND X08.IDENT_NATUREZA_OP  = X2006.IDENT_NATUREZA_OP  '; 
        V_SQL := V_SQL || '      AND X07.MOVTO_E_S                  = ''9''              ';
        V_SQL := V_SQL || '      AND X07.SITUACAO                   = ''N''              ';
        V_SQL := V_SQL || '      AND X07.COD_EMPRESA                = '''|| MCOD_EMPRESA ||'''     ';
        V_SQL := V_SQL || '      AND X07.COD_ESTAB                  = '''|| PCOD_ESTAB ||'''      ';
        V_SQL := V_SQL || '      AND  X2012.COD_CFO                 =  ''5409''         ';
        V_SQL := V_SQL || '      AND X07.DATA_FISCAL BETWEEN '''|| PDT_INI||'''   AND  '''|| PDT_FIM ||'''     ';                                    
        
       DBMS_OUTPUT.PUT_LINE('[PRD]:' || SQL%ROWCOUNT); 
        
      EXECUTE IMMEDIATE V_SQL;
             
             COMMIT;
      END;
      -------
      --- Cria tabela de Aliq
      VP_TAB_ALIQ := MSAF.DPSP_CREATE_TAB_TMP(MPROC_ID, MPROC_ID, 'TAB_ALIQ_M', MNM_USUARIO);
      IF (VP_TAB_ALIQ = 'ERRO') THEN
        RAISE_APPLICATION_ERROR (-20001, '!ERRO CREATE_ALIQ_TABLE!');
      END IF;
      ---
      LOGA(VP_TAB_ALIQ);
      --- Carrega Tabela de Aliq
      
      BEGIN
      
        V_SQL := 'INSERT INTO '||VP_TAB_ALIQ||' ';
        V_SQL := V_SQL || 'SELECT /*+DRIVING_SITE(PS)*/ PS.INV_ITEM_ID AS COD_PRODUTO, PS.DATA_FISCAL, PS.ALIQ_INTERNA ';
        V_SQL := V_SQL || 'FROM ( ';
        V_SQL := V_SQL || '                 SELECT T.INV_ITEM_ID, T.EFFDT, REPLACE(MSAFI.PS_TRANSLATE(''DSP_ALIQ_ICMS'',T.DSP_ALIQ_ICMS),''<VLR INVALIDO>'','''')  AS ALIQ_INTERNA, S.DATA_FISCAL, ';
        V_SQL := V_SQL || '                     RANK() OVER (PARTITION BY T.SETID, T.INV_ITEM_ID ORDER BY T.EFFDT DESC) RANK ';
        IF (PDT_INI < TO_DATE('01012017','DDMMYYYY')) THEN --PERIODOS ANTERIORES ESTAO EM OUTRA TABELA
            V_SQL := V_SQL || '             FROM MSAFI.PS_DSP_LN_MVA_HIS T, ';
        ELSE                                
            V_SQL := V_SQL || '             FROM msafi.PS_DSP_ITEM_LN_MVA T, ';
        END IF;
        V_SQL := V_SQL || '                 '|| VP_TAB_PROD ||' S ';
        V_SQL := V_SQL || '                 WHERE T.SETID = ''GERAL'' ';
        V_SQL := V_SQL || '                 AND T.INV_ITEM_ID = S.COD_PRODUTO ';
        V_SQL := V_SQL || '                 AND T.CRIT_STATE_TO_PBL = T.CRIT_STATE_FR_PBL ';
        V_SQL := V_SQL || '                 AND T.CRIT_STATE_TO_PBL = ''ES'' ';
        V_SQL := V_SQL || '                 AND T.EFFDT <= S.DATA_FISCAL ';
        V_SQL := V_SQL || '      ) PS ';
        V_SQL := V_SQL || 'WHERE PS.RANK = 1 ';
    
    EXECUTE IMMEDIATE V_SQL;
    
     EXCEPTION
                    WHEN OTHERS THEN
                      LOGA('SQLERRM: ' || SQLERRM, FALSE);
                      LOGA(SUBSTR(V_SQL, 1, 1024), FALSE);
                      LOGA(SUBSTR(V_SQL, 1024, 1024), FALSE);
                      LOGA(SUBSTR(V_SQL, 2048, 1024), FALSE);
                      LOGA(SUBSTR(V_SQL, 3072, 1024), FALSE);
                      LOGA(SUBSTR(V_SQL, 4096, 1024), FALSE);
                      LOGA(SUBSTR(V_SQL, 5120), FALSE);
                      ---
                      RAISE_APPLICATION_ERROR (-20003, '!ERRO INSERT !');
                      
                      lib_proc.add(dbms_utility.format_error_backtrace, 1);
     
    
      COMMIT;
  
      END;
      --- Tabela Auxiliar DSP_PRECO_ITEM
      
       BEGIN
       
       EXECUTE IMMEDIATE 'TRUNCATE TABLE MSAFI.DPSP_PRECO_ITEM_GTT'; --GTT

        V_SQL := 'INSERT INTO MSAFI.DPSP_PRECO_ITEM_GTT ';
        V_SQL := V_SQL || 'SELECT /*+DRIVING_SITE(PS)*/ DISTINCT A.* ';
        V_SQL := V_SQL || ' FROM MSAFI.PS_DSP_PRECO_ITEM A, '|| VP_TAB_PROD ||' B';
        V_SQL := V_SQL || ' WHERE A.INV_ITEM_ID = B.COD_PRODUTO AND A.EFFDT <= B.DATA_FISCAL';        
    
       DBMS_OUTPUT.PUT_LINE('[AUX]:' || SQL%ROWCOUNT);
       
       EXECUTE IMMEDIATE V_SQL;
       
       SELECT COUNT(*) INTO V_QTDE FROM MSAFI.DPSP_PRECO_ITEM_GTT;        
       LOGA('[TABLE GTT][LINHAS][' || V_QTDE || ']', FALSE);    
    
    
      COMMIT;
  
      END;
BEGIN
      --- Tabela Auxiliar DSP_PRECO_ITEM
      ---
V_SQL := ' SELECT COD_EMPRESA           ';
V_SQL := V_SQL||chr(10) || ' ,COD_ESTAB          ';   
V_SQL := V_SQL||chr(10) || ' ,DATA_FISCAL        ';   
V_SQL := V_SQL||chr(10) || ' ,NUM_DOCFIS         '; 
V_SQL := V_SQL||chr(10) || ' ,NUM_CONTROLE_DOCTO  ';
V_SQL := V_SQL||chr(10) || ' ,NUM_AUTENTIC_NFE  ';
V_SQL := V_SQL||chr(10) || ' ,COD_FIS_JUR       ';
V_SQL := V_SQL||chr(10) || ' ,CPF_CGC           ';
V_SQL := V_SQL||chr(10) || ' ,COD_DOCTO         ';
V_SQL := V_SQL||chr(10) || ' ,COD_MODELO        ';
V_SQL := V_SQL||chr(10) || ' ,COD_CFO           ';
V_SQL := V_SQL||chr(10) || ' ,COD_PRODUTO       ';
V_SQL := V_SQL||chr(10) || ' ,DESCRICAO         ';
V_SQL := V_SQL||chr(10) || ' ,NUM_ITEM          ';
V_SQL := V_SQL||chr(10) || ' ,VLR_CONTAB_ITEM   ';
V_SQL := V_SQL||chr(10) || ' ,VLR_ITEM          ';
V_SQL := V_SQL||chr(10) || ' ,VLR_BASE_ICMS_1   ';
V_SQL := V_SQL||chr(10) || ' ,VLR_BASE_ICMS_2   ';
V_SQL := V_SQL||chr(10) || ' ,VLR_BASE_ICMS_3   ';
V_SQL := V_SQL||chr(10) || ' ,VLR_BASE_ICMS_4   ';
V_SQL := V_SQL||chr(10) || ' ,VLR_IPI_NDESTAC   ';
V_SQL := V_SQL||chr(10) || ' ,VLR_DESCONTO      ';
V_SQL := V_SQL||chr(10) || ' ,ALIQ_TRIBUTO_ICMS ';
V_SQL := V_SQL||chr(10) || ' ,VLR_ICMS_ST       ';
V_SQL := V_SQL||chr(10) || ' ,VLR_BASE_ST       ';
V_SQL := V_SQL||chr(10) || ' ,VLR_ICMS_PROPRIO  ';
V_SQL := V_SQL||chr(10) || ' ,CST               ';
V_SQL := V_SQL||chr(10) || ' ,QUANTIDADE        ';
V_SQL := V_SQL||chr(10) || ' ,NCM               ';
V_SQL := V_SQL||chr(10) || ' ,MVA               ';
V_SQL := V_SQL||chr(10) || ' ,PMC_PAUTA         ';
V_SQL := V_SQL||chr(10) || ' ,TP_CALC           ';
V_SQL := V_SQL||chr(10) || ' ,SIT_TRIB          ';
V_SQL := V_SQL||chr(10) || ' ,PERC_RED_BSST     ';
V_SQL := V_SQL||chr(10) || ' ,FINALIDADE        ';
V_SQL := V_SQL||chr(10) || ' ,ALIQ_INTERNA      ';
V_SQL := V_SQL||chr(10) || ' ,VLR_UNIT_ITEM     ';
V_SQL := V_SQL||chr(10) || ' ,ICMS_PROPRIO      ';
V_SQL := V_SQL||chr(10) || ' ,BC_ICMS_ST        ';
V_SQL := V_SQL||chr(10) || ' ,CASE WHEN ((BC_ICMS_ST*(ALIQ_INTERNA/100)) - ICMS_PROPRIO) > 0 THEN ((BC_ICMS_ST*(ALIQ_INTERNA/100)) - ICMS_PROPRIO) ';
V_SQL := V_SQL||chr(10) || ' ELSE 0 END  AS ICMS_ST ';
V_SQL := V_SQL||chr(10) || ' ,COD_ESTADO_TO     ';
V_SQL := V_SQL||chr(10) || ' ,COD_ESTADO_FROM   ';
V_SQL := V_SQL||chr(10) || ' ,PROC_ID           ';
V_SQL := V_SQL||chr(10) || ' ,NM_USUARIO        ';
V_SQL := V_SQL||chr(10) || ' ,DT_CARGA          ';
V_SQL := V_SQL||chr(10) || ' ,SERIE_DOCFIS      ';
V_SQL := V_SQL||chr(10) || ' ,COD_NATUREZA_OP   ';
--V_SQL := V_SQL||chr(10) || '         BULK COLLECT INTO   L_TB_FIN048_RET_NF_SAI  ';
V_SQL := V_SQL||chr(10) || ' FROM (     ';
V_SQL := V_SQL||chr(10) || '  SELECT ';
V_SQL := V_SQL||chr(10) || '             COD_EMPRESA  , COD_ESTAB  , DATA_FISCAL  , NUM_DOCFIS  , NUM_CONTROLE_DOCTO  , NUM_AUTENTIC_NFE  , COD_FIS_JUR  , CPF_CGC  , COD_DOCTO  , COD_MODELO ';
V_SQL := V_SQL||chr(10) || '           , COD_CFO  , COD_PRODUTO  , DESCRICAO  , NUM_ITEM  , VLR_CONTAB_ITEM  , VLR_ITEM  , VLR_BASE_ICMS_1  , VLR_BASE_ICMS_2  , VLR_BASE_ICMS_3  , VLR_BASE_ICMS_4 ';
V_SQL := V_SQL||chr(10) || '           , VLR_IPI_NDESTAC  , VLR_DESCONTO  , ALIQ_TRIBUTO_ICMS  , VLR_ICMS_ST  , VLR_BASE_ST  , VLR_ICMS_PROPRIO  , CST  , QUANTIDADE  , NCM ';
V_SQL := V_SQL||chr(10) || '           -- GRUPO TABELÃO  ';
V_SQL := V_SQL||chr(10) || '           , MVA  , PMC_PAUTA  , TP_CALC  , SIT_TRIB  , PERC_RED_BSST  , FINALIDADE  , ALIQ_INTERNA  ';
V_SQL := V_SQL||chr(10) || '           --  GRUPO CALCULADO ';
V_SQL := V_SQL||chr(10) || '           , (VLR_ITEM/QUANTIDADE)                                                                       AS  VLR_UNIT_ITEM ';
V_SQL := V_SQL||chr(10) || '           , (VLR_ITEM * ALIQ_INTERNA /100) * (1 - PERC_RED_BSST/100)                                  AS  ICMS_PROPRIO      ';  
V_SQL := V_SQL||chr(10) || '       ,  (  CASE ';
V_SQL := V_SQL||chr(10) || '                  WHEN  PMC_PAUTA > 0  THEN ( (PMC_PAUTA * QUANTIDADE) * (1 - PERC_RED_BSST/100))        ';
V_SQL := V_SQL||chr(10) || '                  WHEN  PMC_PAUTA = 0  THEN (VLR_ITEM * (1+ MVA/100) * (1 - PERC_RED_BSST/100)) END )    AS BC_ICMS_ST   ';
V_SQL := V_SQL||chr(10) || ' , ( (  CASE ';
V_SQL := V_SQL||chr(10) || '                  WHEN  PMC_PAUTA > 0  THEN ( (PMC_PAUTA * QUANTIDADE) * (1 - PERC_RED_BSST/100))        ';
V_SQL := V_SQL||chr(10) || '                  WHEN  PMC_PAUTA = 0  THEN (VLR_ITEM * (1+ MVA/100) * (1 - PERC_RED_BSST/100)) END ) * (TO_NUMBER(ALIQ_INTERNA/100)) - ';
V_SQL := V_SQL||chr(10) || '                 (VLR_ITEM * ALIQ_INTERNA/100 ) * (1 - PERC_RED_BSST/100)) ICMS_ST ';
V_SQL := V_SQL||chr(10) || '       , COD_ESTADO_TO ';
V_SQL := V_SQL||chr(10) || '       , COD_ESTADO_FROM ';
V_SQL := V_SQL||chr(10) || '       , PROC_ID ';
V_SQL := V_SQL||chr(10) || '       , NM_USUARIO ';
V_SQL := V_SQL||chr(10) || '       , DT_CARGA   ';
V_SQL := V_SQL||chr(10) || '       , SERIE_DOCFIS ';
V_SQL := V_SQL||chr(10) || '       , COD_NATUREZA_OP ';
V_SQL := V_SQL||chr(10) || '      FROM ( ';
V_SQL := V_SQL||chr(10) || '      SELECT   ';
V_SQL := V_SQL||chr(10) || '         /*+ result_cache */ ';
V_SQL := V_SQL||chr(10) || '           X08.COD_EMPRESA                                                       AS COD_EMPRESA                      --  1 ';
V_SQL := V_SQL||chr(10) || '         , X08.COD_ESTAB                                                         AS COD_ESTAB                        --  2 ';
V_SQL := V_SQL||chr(10) || '         , X08.DATA_FISCAL                                                       AS DATA_FISCAL                      --  3 ';
V_SQL := V_SQL||chr(10) || '         , X08.NUM_DOCFIS                                                        AS NUM_DOCFIS                       --  4 ';
V_SQL := V_SQL||chr(10) || '         , X07.NUM_CONTROLE_DOCTO                                                AS NUM_CONTROLE_DOCTO               --  5 ';
V_SQL := V_SQL||chr(10) || '         , X07.NUM_AUTENTIC_NFE                                                  AS NUM_AUTENTIC_NFE                 --  6 ';
V_SQL := V_SQL||chr(10) || '         , X04.COD_FIS_JUR                                                       AS COD_FIS_JUR                      --  7 ';
V_SQL := V_SQL||chr(10) || '         , X04.CPF_CGC                                                           AS CPF_CGC                          --  8 ';
V_SQL := V_SQL||chr(10) || '         , X2005.COD_DOCTO                                                       AS COD_DOCTO                        --  9 ';
V_SQL := V_SQL||chr(10) || '         , X2024.COD_MODELO                                                      AS COD_MODELO                       --  10';
V_SQL := V_SQL||chr(10) || '         , X2012.COD_CFO                                                         AS COD_CFO                          --  11';    
V_SQL := V_SQL||chr(10) || '         , X2013.COD_PRODUTO                                                     AS COD_PRODUTO                      --  12';
V_SQL := V_SQL||chr(10) || '         , X2013.DESCRICAO                                                       AS DESCRICAO                        --  13';
V_SQL := V_SQL||chr(10) || '         , X08.NUM_ITEM                                                          AS NUM_ITEM                         --  14';
V_SQL := V_SQL||chr(10) || '         , X08.VLR_CONTAB_ITEM                                                   AS VLR_CONTAB_ITEM                  --  15'; 
V_SQL := V_SQL||chr(10) || '         , X08.VLR_ITEM                                                          AS VLR_ITEM                         --  16';
V_SQL := V_SQL||chr(10) || '         --- ';
V_SQL := V_SQL||chr(10) || '         --   base 1 ';
V_SQL := V_SQL||chr(10) || '         --- ';
V_SQL := V_SQL||chr(10) || '        ,( SELECT NVL(X08_BASE.VLR_BASE, 0) ';
V_SQL := V_SQL||chr(10) || '            FROM  MSAF.X08_BASE_MERC  X08_BASE ';
V_SQL := V_SQL||chr(10) || '           WHERE  X08.COD_EMPRESA                = X08_BASE.COD_EMPRESA         ';
V_SQL := V_SQL||chr(10) || '            AND    X08.COD_ESTAB                  = X08_BASE.COD_ESTAB          ';
V_SQL := V_SQL||chr(10) || '            AND    X08.DATA_FISCAL                = X08_BASE.DATA_FISCAL        ';
V_SQL := V_SQL||chr(10) || '            AND    X08.MOVTO_E_S                  = X08_BASE.MOVTO_E_S          ';
V_SQL := V_SQL||chr(10) || '            AND    X08.NORM_DEV                   = X08_BASE.NORM_DEV           ';
V_SQL := V_SQL||chr(10) || '            AND    X08.IDENT_DOCTO                = X08_BASE.IDENT_DOCTO        ';
V_SQL := V_SQL||chr(10) || '            AND    X08.IDENT_FIS_JUR              = X08_BASE.IDENT_FIS_JUR      ';
V_SQL := V_SQL||chr(10) || '            AND    X08.NUM_DOCFIS                 = X08_BASE.NUM_DOCFIS         ';
V_SQL := V_SQL||chr(10) || '            AND    X08.SERIE_DOCFIS               = X08_BASE.SERIE_DOCFIS       ';
V_SQL := V_SQL||chr(10) || '            AND    X08.SUB_SERIE_DOCFIS           = X08_BASE.SUB_SERIE_DOCFIS   ';
V_SQL := V_SQL||chr(10) || '            AND    X08.DISCRI_ITEM                = X08_BASE.DISCRI_ITEM        ';
V_SQL := V_SQL||chr(10) || '            AND    X08_BASE.COD_TRIBUTO           = ''ICMS''                      ';
V_SQL := V_SQL||chr(10) || '            AND    X08_BASE.COD_TRIBUTACAO        = ''1'')                         AS  VLR_BASE_ICMS_1                     -- 17   ';
V_SQL := V_SQL||chr(10) || '          -- ';
V_SQL := V_SQL||chr(10) || '          -- base2  ';
V_SQL := V_SQL||chr(10) || '          --  ';
V_SQL := V_SQL||chr(10) || '        ,( SELECT NVL(X08_BASE.VLR_BASE, 0) ';
V_SQL := V_SQL||chr(10) || '            FROM  MSAF.X08_BASE_MERC  X08_BASE ';
V_SQL := V_SQL||chr(10) || '           WHERE  X08.COD_EMPRESA                 = X08_BASE.COD_EMPRESA      ';
V_SQL := V_SQL||chr(10) || '              AND    X08.COD_ESTAB                  = X08_BASE.COD_ESTAB      ';
V_SQL := V_SQL||chr(10) || '              AND    X08.DATA_FISCAL                = X08_BASE.DATA_FISCAL    ';
V_SQL := V_SQL||chr(10) || '              AND    X08.MOVTO_E_S                  = X08_BASE.MOVTO_E_S      ';
V_SQL := V_SQL||chr(10) || '              AND    X08.NORM_DEV                   = X08_BASE.NORM_DEV       ';
V_SQL := V_SQL||chr(10) || '              AND    X08.IDENT_DOCTO                = X08_BASE.IDENT_DOCTO    ';
V_SQL := V_SQL||chr(10) || '              AND    X08.IDENT_FIS_JUR              = X08_BASE.IDENT_FIS_JUR  ';
V_SQL := V_SQL||chr(10) || '              AND    X08.NUM_DOCFIS                 = X08_BASE.NUM_DOCFIS     ';
V_SQL := V_SQL||chr(10) || '              AND    X08.SERIE_DOCFIS               = X08_BASE.SERIE_DOCFIS   ';
V_SQL := V_SQL||chr(10) || '              AND    X08.SUB_SERIE_DOCFIS           = X08_BASE.SUB_SERIE_DOCFIS ';
V_SQL := V_SQL||chr(10) || '              AND    X08.DISCRI_ITEM                = X08_BASE.DISCRI_ITEM ';
V_SQL := V_SQL||chr(10) || '              AND    X08_BASE.COD_TRIBUTO           = ''ICMS'' ';
V_SQL := V_SQL||chr(10) || '              AND    X08_BASE.COD_TRIBUTACAO        = ''2'' )                       AS  VLR_BASE_ICMS_2                      -- 18   ';
V_SQL := V_SQL||chr(10) || '        ,( SELECT NVL(X08_BASE.VLR_BASE, 0) ';
V_SQL := V_SQL||chr(10) || '            FROM  MSAF.X08_BASE_MERC  X08_BASE ';
V_SQL := V_SQL||chr(10) || '           WHERE  X08.COD_EMPRESA                = X08_BASE.COD_EMPRESA         ';
V_SQL := V_SQL||chr(10) || '             AND    X08.COD_ESTAB                  = X08_BASE.COD_ESTAB         ';
V_SQL := V_SQL||chr(10) || '             AND    X08.DATA_FISCAL                = X08_BASE.DATA_FISCAL       ';
V_SQL := V_SQL||chr(10) || '             AND    X08.MOVTO_E_S                  = X08_BASE.MOVTO_E_S         ';                                                                                                                                                                                                                    
V_SQL := V_SQL||chr(10) || '             AND    X08.NORM_DEV                   = X08_BASE.NORM_DEV          ';
V_SQL := V_SQL||chr(10) || '             AND    X08.IDENT_DOCTO                = X08_BASE.IDENT_DOCTO       ';
V_SQL := V_SQL||chr(10) || '             AND    X08.IDENT_FIS_JUR              = X08_BASE.IDENT_FIS_JUR     ';
V_SQL := V_SQL||chr(10) || '             AND    X08.NUM_DOCFIS                 = X08_BASE.NUM_DOCFIS        ';
V_SQL := V_SQL||chr(10) || '             AND    X08.SERIE_DOCFIS               = X08_BASE.SERIE_DOCFIS      ';
V_SQL := V_SQL||chr(10) || '             AND    X08.SUB_SERIE_DOCFIS           = X08_BASE.SUB_SERIE_DOCFIS  ';
V_SQL := V_SQL||chr(10) || '             AND    X08.DISCRI_ITEM                = X08_BASE.DISCRI_ITEM       ';
V_SQL := V_SQL||chr(10) || '             AND    X08_BASE.COD_TRIBUTO           = ''ICMS''                     ';
V_SQL := V_SQL||chr(10) || '             AND    X08_BASE.COD_TRIBUTACAO        = ''3'')                        AS  VLR_BASE_ICMS_3                     -- 19  ';
V_SQL := V_SQL||chr(10) || '          -- ';
V_SQL := V_SQL||chr(10) || '       ,( SELECT NVL(X08_BASE.VLR_BASE, 0)  ';
V_SQL := V_SQL||chr(10) || '            FROM  MSAF.X08_BASE_MERC  X08_BASE ';
V_SQL := V_SQL||chr(10) || '           WHERE  X08.COD_EMPRESA                = X08_BASE.COD_EMPRESA     ';
V_SQL := V_SQL||chr(10) || '             AND    X08.COD_ESTAB                  = X08_BASE.COD_ESTAB     ';
V_SQL := V_SQL||chr(10) || '             AND    X08.DATA_FISCAL                = X08_BASE.DATA_FISCAL   ';
V_SQL := V_SQL||chr(10) || '             AND    X08.MOVTO_E_S                  = X08_BASE.MOVTO_E_S     ';                                                                                                                                                                                                                        
V_SQL := V_SQL||chr(10) || '             AND    X08.NORM_DEV                   = X08_BASE.NORM_DEV      ';
V_SQL := V_SQL||chr(10) || '             AND    X08.IDENT_DOCTO                = X08_BASE.IDENT_DOCTO   ';
V_SQL := V_SQL||chr(10) || '             AND    X08.IDENT_FIS_JUR              = X08_BASE.IDENT_FIS_JUR ';
V_SQL := V_SQL||chr(10) || '             AND    X08.NUM_DOCFIS                 = X08_BASE.NUM_DOCFIS    ';
V_SQL := V_SQL||chr(10) || '             AND    X08.SERIE_DOCFIS               = X08_BASE.SERIE_DOCFIS  ';
V_SQL := V_SQL||chr(10) || '             AND    X08.SUB_SERIE_DOCFIS           = X08_BASE.SUB_SERIE_DOCFIS ';
V_SQL := V_SQL||chr(10) || '             AND    X08.DISCRI_ITEM                = X08_BASE.DISCRI_ITEM ';
V_SQL := V_SQL||chr(10) || '             AND    X08_BASE.COD_TRIBUTO           = ''ICMS'' ';
V_SQL := V_SQL||chr(10) || '             AND    X08_BASE.COD_TRIBUTACAO        = ''4'')                        AS VLR_BASE_ICMS_4                     -- 20   ';
V_SQL := V_SQL||chr(10) || '          -- ';
V_SQL := V_SQL||chr(10) || '        , X08.VLR_IPI_NDESTAC                                                    AS VLR_IPI_NDESTAC                      -- 21  ';
V_SQL := V_SQL||chr(10) || '        , X08.VLR_DESCONTO                                                      AS VLR_DESCONTO                         -- 22     ';  
V_SQL := V_SQL||chr(10) || '         ,(SELECT    NVL(X08_BASE_TRIB.ALIQ_TRIBUTO, 0) ';
V_SQL := V_SQL||chr(10) || '            FROM MSAF.X08_TRIB_MERC  X08_BASE_TRIB ';
V_SQL := V_SQL||chr(10) || '           WHERE  X08.COD_EMPRESA              = X08_BASE_TRIB.COD_EMPRESA   ';
V_SQL := V_SQL||chr(10) || '            AND X08.COD_ESTAB                  = X08_BASE_TRIB.COD_ESTAB     ';
V_SQL := V_SQL||chr(10) || '            AND X08.DATA_FISCAL                = X08_BASE_TRIB.DATA_FISCAL   ';
V_SQL := V_SQL||chr(10) || '            AND X08.MOVTO_E_S                  = X08_BASE_TRIB.MOVTO_E_S     ';
V_SQL := V_SQL||chr(10) || '            AND X08.NORM_DEV                   = X08_BASE_TRIB.NORM_DEV      ';
V_SQL := V_SQL||chr(10) || '            AND X08.IDENT_DOCTO                = X08_BASE_TRIB.IDENT_DOCTO   ';
V_SQL := V_SQL||chr(10) || '            AND X08.IDENT_FIS_JUR              = X08_BASE_TRIB.IDENT_FIS_JUR ';
V_SQL := V_SQL||chr(10) || '            AND X08.NUM_DOCFIS                 = X08_BASE_TRIB.NUM_DOCFIS    ';
V_SQL := V_SQL||chr(10) || '            AND X08.SERIE_DOCFIS               = X08_BASE_TRIB.SERIE_DOCFIS  ';
V_SQL := V_SQL||chr(10) || '            AND X08.SUB_SERIE_DOCFIS           = X08_BASE_TRIB.SUB_SERIE_DOCFIS ';
V_SQL := V_SQL||chr(10) || '            AND X08.DISCRI_ITEM                = X08_BASE_TRIB.DISCRI_ITEM ';
V_SQL := V_SQL||chr(10) || '            AND X08_BASE_TRIB.COD_TRIBUTO      = ''ICMS''   )                      AS  ALIQ_TRIBUTO_ICMS                   -- 23    ';
V_SQL := V_SQL||chr(10) || '             --  ICMS-ST ';
V_SQL := V_SQL||chr(10) || '         ,(SELECT    NVL(X08_BASE_TRIB.VLR_TRIBUTO, 0) ';
V_SQL := V_SQL||chr(10) || '            FROM MSAF.X08_TRIB_MERC  X08_BASE_TRIB ';
V_SQL := V_SQL||chr(10) || '           WHERE  X08.COD_EMPRESA              = X08_BASE_TRIB.COD_EMPRESA       ';
V_SQL := V_SQL||chr(10) || '            AND X08.COD_ESTAB                  = X08_BASE_TRIB.COD_ESTAB         ';
V_SQL := V_SQL||chr(10) || '            AND X08.DATA_FISCAL                = X08_BASE_TRIB.DATA_FISCAL       ';
V_SQL := V_SQL||chr(10) || '            AND X08.MOVTO_E_S                  = X08_BASE_TRIB.MOVTO_E_S         ';
V_SQL := V_SQL||chr(10) || '            AND X08.NORM_DEV                   = X08_BASE_TRIB.NORM_DEV          ';
V_SQL := V_SQL||chr(10) || '            AND X08.IDENT_DOCTO                = X08_BASE_TRIB.IDENT_DOCTO       ';
V_SQL := V_SQL||chr(10) || '            AND X08.IDENT_FIS_JUR              = X08_BASE_TRIB.IDENT_FIS_JUR     ';
V_SQL := V_SQL||chr(10) || '            AND X08.NUM_DOCFIS                 = X08_BASE_TRIB.NUM_DOCFIS        ';
V_SQL := V_SQL||chr(10) || '            AND X08.SERIE_DOCFIS               = X08_BASE_TRIB.SERIE_DOCFIS      ';
V_SQL := V_SQL||chr(10) || '            AND X08.SUB_SERIE_DOCFIS           = X08_BASE_TRIB.SUB_SERIE_DOCFIS  ';
V_SQL := V_SQL||chr(10) || '            AND X08.DISCRI_ITEM                = X08_BASE_TRIB.DISCRI_ITEM       ';
V_SQL := V_SQL||chr(10) || '            AND X08_BASE_TRIB.COD_TRIBUTO      = ''ICMS-S''   )                    AS  VLR_ICMS_ST                         -- 24   ';
V_SQL := V_SQL||chr(10) || '            -- ';
V_SQL := V_SQL||chr(10) || '        ,( SELECT NVL(X08_BASE.VLR_BASE, 0)  ';
V_SQL := V_SQL||chr(10) || '            FROM  MSAF.X08_BASE_MERC  X08_BASE ';
V_SQL := V_SQL||chr(10) || '           WHERE  X08.COD_EMPRESA                = X08_BASE.COD_EMPRESA         ';
V_SQL := V_SQL||chr(10) || '          AND    X08.COD_ESTAB                  = X08_BASE.COD_ESTAB            ';
V_SQL := V_SQL||chr(10) || '          AND    X08.DATA_FISCAL                = X08_BASE.DATA_FISCAL          ';
V_SQL := V_SQL||chr(10) || '          AND    X08.MOVTO_E_S                  = X08_BASE.MOVTO_E_S            ';                                                                                                                                                                                                                 
V_SQL := V_SQL||chr(10) || '          AND    X08.NORM_DEV                   = X08_BASE.NORM_DEV             ';
V_SQL := V_SQL||chr(10) || '          AND    X08.IDENT_DOCTO                = X08_BASE.IDENT_DOCTO          ';
V_SQL := V_SQL||chr(10) || '          AND    X08.IDENT_FIS_JUR              = X08_BASE.IDENT_FIS_JUR        ';
V_SQL := V_SQL||chr(10) || '          AND    X08.NUM_DOCFIS                 = X08_BASE.NUM_DOCFIS           ';
V_SQL := V_SQL||chr(10) || '          AND    X08.SERIE_DOCFIS               = X08_BASE.SERIE_DOCFIS         ';
V_SQL := V_SQL||chr(10) || '          AND    X08.SUB_SERIE_DOCFIS           = X08_BASE.SUB_SERIE_DOCFIS     ';
V_SQL := V_SQL||chr(10) || '          AND    X08.DISCRI_ITEM                = X08_BASE.DISCRI_ITEM          ';
V_SQL := V_SQL||chr(10) || '          AND    X08_BASE.COD_TRIBUTO           = ''ICMS-S''                      ';
V_SQL := V_SQL||chr(10) || '          AND    X08_BASE.COD_TRIBUTACAO        = ''1'')                           AS  VLR_BASE_ST                         -- 25  ';
V_SQL := V_SQL||chr(10) || '             --        ';
V_SQL := V_SQL||chr(10) || '       ,(SELECT    NVL(X08_BASE_TRIB.VLR_TRIBUTO, 0) ';
V_SQL := V_SQL||chr(10) || '            FROM MSAF.X08_TRIB_MERC  X08_BASE_TRIB ';
V_SQL := V_SQL||chr(10) || '           WHERE  X08.COD_EMPRESA              = X08_BASE_TRIB.COD_EMPRESA        ';
V_SQL := V_SQL||chr(10) || '            AND X08.COD_ESTAB                  = X08_BASE_TRIB.COD_ESTAB          ';
V_SQL := V_SQL||chr(10) || '            AND X08.DATA_FISCAL                = X08_BASE_TRIB.DATA_FISCAL        ';
V_SQL := V_SQL||chr(10) || '            AND X08.MOVTO_E_S                  = X08_BASE_TRIB.MOVTO_E_S          ';
V_SQL := V_SQL||chr(10) || '            AND X08.NORM_DEV                   = X08_BASE_TRIB.NORM_DEV           ';
V_SQL := V_SQL||chr(10) || '            AND X08.IDENT_DOCTO                = X08_BASE_TRIB.IDENT_DOCTO        ';
V_SQL := V_SQL||chr(10) || '            AND X08.IDENT_FIS_JUR              = X08_BASE_TRIB.IDENT_FIS_JUR      ';
V_SQL := V_SQL||chr(10) || '            AND X08.NUM_DOCFIS                 = X08_BASE_TRIB.NUM_DOCFIS         ';
V_SQL := V_SQL||chr(10) || '            AND X08.SERIE_DOCFIS               = X08_BASE_TRIB.SERIE_DOCFIS       ';
V_SQL := V_SQL||chr(10) || '            AND X08.SUB_SERIE_DOCFIS           = X08_BASE_TRIB.SUB_SERIE_DOCFIS   ';
V_SQL := V_SQL||chr(10) || '            AND X08.DISCRI_ITEM                = X08_BASE_TRIB.DISCRI_ITEM        ';
V_SQL := V_SQL||chr(10) || '            AND X08_BASE_TRIB.COD_TRIBUTO      = ''ICMS''   )                      AS  VLR_ICMS_PROPRIO                    --  26 ';
V_SQL := V_SQL||chr(10) || '            -- ';
V_SQL := V_SQL||chr(10) || '         ,   Y2026.COD_SITUACAO_B                                                AS  CST                                 --  27 ';
V_SQL := V_SQL||chr(10) || '         ,   X08.QUANTIDADE                                                      AS  QUANTIDADE                          --  28 ';
V_SQL := V_SQL||chr(10) || '         ,   X2043.COD_NBM                                                       AS  NCM                                 --  29 ';
V_SQL := V_SQL||chr(10) || '         --       ';
V_SQL := V_SQL||chr(10) || '         --   MVA '; 
V_SQL := V_SQL||chr(10) || '         --       ';
V_SQL := V_SQL||chr(10) || '         ,( SELECT  MVA_PCT_BBL  ';
V_SQL := V_SQL||chr(10) || '             FROM ( ';
V_SQL := V_SQL||chr(10) || '            SELECT /*+DRIVING_SITE(TAB)*/ ';
V_SQL := V_SQL||chr(10) || '               TAB.MVA_PCT_BBL ';
V_SQL := V_SQL||chr(10) || '          , RANK() OVER (PARTITION BY TAB.SETID, TAB.INV_ITEM_ID ORDER BY TAB.EFFDT DESC) AS RANK   ';
V_SQL := V_SQL||chr(10) || '            FROM msafi.PS_DSP_ITEM_LN_MVA     TAB ';
V_SQL := V_SQL||chr(10) || '         ,    MSAFI.DSP_ESTABELECIMENTO    EST           ';                                              
V_SQL := V_SQL||chr(10) || '             WHERE TAB.SETID             = ''GERAL''       ';
V_SQL := V_SQL||chr(10) || '              AND  TAB.INV_ITEM_ID       = X2013.COD_PRODUTO  ';   
V_SQL := V_SQL||chr(10) || '              AND  EST.COD_EMPRESA       = X07.COD_EMPRESA    ';                                                  
V_SQL := V_SQL||chr(10) || '              AND  EST.COD_ESTAB         = X07.COD_ESTAB      ';
V_SQL := V_SQL||chr(10) || '              AND  TAB.CRIT_STATE_TO_PBL = EST.COD_ESTADO     ';
V_SQL := V_SQL||chr(10) || '              AND  TAB.CRIT_STATE_FR_PBL = EST.COD_ESTADO     ';
V_SQL := V_SQL||chr(10) || '              AND TAB.EFFDT             <= X07.DATA_FISCAL    ';
V_SQL := V_SQL||chr(10) || '             )  WHERE RANK = 1 )                                                         AS    MVA      -- 30 '; 
V_SQL := V_SQL||chr(10) || '         ---    ';
V_SQL := V_SQL||chr(10) || '         -- PMC_PAUTA '; 
V_SQL := V_SQL||chr(10) || '         ---  '; 
V_SQL := V_SQL||chr(10) || '     , NVL(( SELECT DISTINCT PMC_PAUTA  '; 
V_SQL := V_SQL||chr(10) || '         FROM ( '; 
V_SQL := V_SQL||chr(10) || '          SELECT /*+DRIVING_SITE(TAB)*/ '; 
V_SQL := V_SQL||chr(10) || '                 DISTINCT NVL((PMC.DSP_PMC), 0)  PMC_PAUTA '; 
V_SQL := V_SQL||chr(10) || '        , RANK() OVER (PARTITION BY PMC.SETID, PMC.INV_ITEM_ID, PMC.DSP_ALIQ_ICMS_ID, PMC.UNIT_OF_MEASURE ORDER BY PMC.EFFDT DESC) AS RANK  '; 
V_SQL := V_SQL||chr(10) || '          FROM msafi.PS_DSP_ITEM_LN_MVA     TAB '; 
V_SQL := V_SQL||chr(10) || '          ,    MSAFI.DSP_ESTABELECIMENTO    EST  '; 
V_SQL := V_SQL||chr(10) || '          ,    MSAFI.DPSP_PRECO_ITEM_GTT    PMC  '; 
V_SQL := V_SQL||chr(10) || '          WHERE TAB.SETID             = ''GERAL''  '; 
V_SQL := V_SQL||chr(10) || '           AND TAB.INV_ITEM_ID = PMC.INV_ITEM_ID '; 
V_SQL := V_SQL||chr(10) || '           AND MSAFI.PS_TRANSLATE(''DSP_ALIQ_ICMS'',TAB.DSP_ALIQ_ICMS) = PMC.DSP_ALIQ_ICMS_ID '; 
V_SQL := V_SQL||chr(10) || '           AND  PMC.UNIT_OF_MEASURE = ''UN'' '; 
V_SQL := V_SQL||chr(10) || '           AND  TAB.INV_ITEM_ID       = X2013.COD_PRODUTO   '; 
V_SQL := V_SQL||chr(10) || '           AND  EST.COD_EMPRESA       = X07.COD_EMPRESA     ';                                                 
V_SQL := V_SQL||chr(10) || '           AND  EST.COD_ESTAB         = X07.COD_ESTAB       '; 
V_SQL := V_SQL||chr(10) || '           AND  TAB.CRIT_STATE_TO_PBL = EST.COD_ESTADO      '; 
V_SQL := V_SQL||chr(10) || '           AND  TAB.CRIT_STATE_FR_PBL = EST.COD_ESTADO      '; 
V_SQL := V_SQL||chr(10) || '           AND TAB.EFFDT             <= X07.DATA_FISCAL     '; 
V_SQL := V_SQL||chr(10) || '          )  WHERE RANK = 1 ) ,0)                                                            AS    PMC_PAUTA        --- 31  '; 
V_SQL := V_SQL||chr(10) || '       ---  '; 
V_SQL := V_SQL||chr(10) || '       -- TP_CALC '; 
V_SQL := V_SQL||chr(10) || '       --- '; 
V_SQL := V_SQL||chr(10) || '  ,    ( SELECT  TP_CALC  '; 
V_SQL := V_SQL||chr(10) || '         FROM ( '; 
V_SQL := V_SQL||chr(10) || '         SELECT /*+DRIVING_SITE(TAB)*/ '; 
V_SQL := V_SQL||chr(10) || '                TAB.DSP_TP_CALC_ST  TP_CALC '; 
V_SQL := V_SQL||chr(10) || '       , RANK() OVER (PARTITION BY TAB.SETID, TAB.INV_ITEM_ID ORDER BY TAB.EFFDT DESC) AS RANK   '; 
V_SQL := V_SQL||chr(10) || '         FROM msafi.PS_DSP_ITEM_LN_MVA     TAB '; 
V_SQL := V_SQL||chr(10) || '         ,    MSAFI.DSP_ESTABELECIMENTO    EST     ';                                                     
V_SQL := V_SQL||chr(10) || '         WHERE TAB.SETID             = ''GERAL''   '; 
V_SQL := V_SQL||chr(10) || '          AND  TAB.INV_ITEM_ID       = X2013.COD_PRODUTO    '; 
V_SQL := V_SQL||chr(10) || '          AND  EST.COD_EMPRESA       = X07.COD_EMPRESA       ';                                               
V_SQL := V_SQL||chr(10) || '          AND  EST.COD_ESTAB         = X07.COD_ESTAB         '; 
V_SQL := V_SQL||chr(10) || '          AND  TAB.CRIT_STATE_TO_PBL = EST.COD_ESTADO        '; 
V_SQL := V_SQL||chr(10) || '          AND  TAB.CRIT_STATE_FR_PBL = EST.COD_ESTADO        '; 
V_SQL := V_SQL||chr(10) || '          AND TAB.EFFDT             <= X07.DATA_FISCAL       '; 
V_SQL := V_SQL||chr(10) || '         )  WHERE RANK = 1 )                                                              AS    TP_CALC    -- 32  '; 
V_SQL := V_SQL||chr(10) || '       --  '; 
V_SQL := V_SQL||chr(10) || '       -- SIT_TRIB '; 
V_SQL := V_SQL||chr(10) || '       --  '; 
V_SQL := V_SQL||chr(10) || '       ,( SELECT  SIT_TRIB '; 
V_SQL := V_SQL||chr(10) || '         FROM ( '; 
V_SQL := V_SQL||chr(10) || '         SELECT /*+DRIVING_SITE(TAB)*/  '; 
V_SQL := V_SQL||chr(10) || '                TAB.DSP_ST_TRIBUT_ICMS  SIT_TRIB '; 
V_SQL := V_SQL||chr(10) || '       , RANK() OVER (PARTITION BY TAB.SETID, TAB.INV_ITEM_ID ORDER BY TAB.EFFDT DESC) AS RANK    '; 
V_SQL := V_SQL||chr(10) || '         FROM msafi.PS_DSP_ITEM_LN_MVA     TAB '; 
V_SQL := V_SQL||chr(10) || '         ,    MSAFI.DSP_ESTABELECIMENTO    EST                           ';                               
V_SQL := V_SQL||chr(10) || '         WHERE TAB.SETID             = ''GERAL''                           '; 
V_SQL := V_SQL||chr(10) || '          AND  TAB.INV_ITEM_ID       = X2013.COD_PRODUTO                 '; 
V_SQL := V_SQL||chr(10) || '          AND  EST.COD_EMPRESA       = X07.COD_EMPRESA                   ';                                    
V_SQL := V_SQL||chr(10) || '          AND  EST.COD_ESTAB         = X07.COD_ESTAB                     '; 
V_SQL := V_SQL||chr(10) || '          AND  TAB.CRIT_STATE_TO_PBL = EST.COD_ESTADO                    '; 
V_SQL := V_SQL||chr(10) || '          AND  TAB.CRIT_STATE_FR_PBL = EST.COD_ESTADO                    '; 
V_SQL := V_SQL||chr(10) || '          AND TAB.EFFDT             <= X07.DATA_FISCAL                   '; 
V_SQL := V_SQL||chr(10) || '         )  WHERE RANK = 1 )                                                             AS    SIT_TRIB    --  33 '; 
V_SQL := V_SQL||chr(10) || '          --- '; 
V_SQL := V_SQL||chr(10) || '         -- PERC_RED_BSST '; 
V_SQL := V_SQL||chr(10) || '         --- '; 
V_SQL := V_SQL||chr(10) || '  ,    ( SELECT  PERC_RED_BSST  '; 
V_SQL := V_SQL||chr(10) || '         FROM ( '; 
V_SQL := V_SQL||chr(10) || '         SELECT /*+DRIVING_SITE(TAB)*/ '; 
V_SQL := V_SQL||chr(10) || '                TAB.DSP_PCT_RED_ICMSST  PERC_RED_BSST '; 
V_SQL := V_SQL||chr(10) || '       , RANK() OVER (PARTITION BY TAB.SETID, TAB.INV_ITEM_ID ORDER BY TAB.EFFDT DESC) AS RANK   '; 
V_SQL := V_SQL||chr(10) || '         FROM msafi.PS_DSP_ITEM_LN_MVA     TAB '; 
V_SQL := V_SQL||chr(10) || '         ,    MSAFI.DSP_ESTABELECIMENTO    EST  ';                                                        
V_SQL := V_SQL||chr(10) || '         WHERE TAB.SETID             = ''GERAL''   '; 
V_SQL := V_SQL||chr(10) || '          AND  TAB.INV_ITEM_ID       = X2013.COD_PRODUTO  ';
V_SQL := V_SQL||chr(10) || '          AND  EST.COD_EMPRESA       = X07.COD_EMPRESA    ';                                                 
V_SQL := V_SQL||chr(10) || '          AND  EST.COD_ESTAB         = X07.COD_ESTAB      ';
V_SQL := V_SQL||chr(10) || '          AND  TAB.CRIT_STATE_TO_PBL = EST.COD_ESTADO     ';
V_SQL := V_SQL||chr(10) || '          AND  TAB.CRIT_STATE_FR_PBL = EST.COD_ESTADO     ';
V_SQL := V_SQL||chr(10) || '          AND TAB.EFFDT             <= X07.DATA_FISCAL    ';
V_SQL := V_SQL||chr(10) || '         )  WHERE RANK = 1 )                                                         AS    PERC_RED_BSST     --34  ';
V_SQL := V_SQL||chr(10) || '         --- ';
V_SQL := V_SQL||chr(10) || '         -- FINALIDADE ';
V_SQL := V_SQL||chr(10) || '         ---  ';
V_SQL := V_SQL||chr(10) || '  ,    ( SELECT  trim(FINALIDADE) FINALIDADE   ';
V_SQL := V_SQL||chr(10) || '         FROM ( ';
V_SQL := V_SQL||chr(10) || '         SELECT /*+DRIVING_SITE(TAB)*/  ';
V_SQL := V_SQL||chr(10) || '                TAB.PURCH_PROP_BRL  FINALIDADE  ';
V_SQL := V_SQL||chr(10) || '       , RANK() OVER (PARTITION BY TAB.SETID, TAB.INV_ITEM_ID ORDER BY TAB.EFFDT DESC) AS RANK    ';
V_SQL := V_SQL||chr(10) || '         FROM msafi.PS_DSP_ITEM_LN_MVA     TAB ';
V_SQL := V_SQL||chr(10) || '         ,    MSAFI.DSP_ESTABELECIMENTO    EST                           ';                              
V_SQL := V_SQL||chr(10) || '         WHERE TAB.SETID             = ''GERAL''   ';
V_SQL := V_SQL||chr(10) || '          AND  TAB.INV_ITEM_ID       = X2013.COD_PRODUTO ';   
V_SQL := V_SQL||chr(10) || '          AND  EST.COD_EMPRESA       = X07.COD_EMPRESA    ';                                                  
V_SQL := V_SQL||chr(10) || '          AND  EST.COD_ESTAB         = X07.COD_ESTAB      ';
V_SQL := V_SQL||chr(10) || '          AND  TAB.CRIT_STATE_TO_PBL = EST.COD_ESTADO     ';
V_SQL := V_SQL||chr(10) || '          AND  TAB.CRIT_STATE_FR_PBL = EST.COD_ESTADO     ';
V_SQL := V_SQL||chr(10) || '          AND TAB.EFFDT             <= X07.DATA_FISCAL    ';
V_SQL := V_SQL||chr(10) || '         )  WHERE RANK = 1 )                                                         AS    FINALIDADE     -- 35  ';
V_SQL := V_SQL||chr(10) || '         ---   ';
V_SQL := V_SQL||chr(10) || '         -- ALIQ_INTERNA ';
V_SQL := V_SQL||chr(10) || '        ,         (SELECT trim(ALIQ_INTERNA) ALIQ_INTERNA ';
V_SQL := V_SQL||chr(10) || '                        FROM ( ';
V_SQL := V_SQL||chr(10) || '                     SELECT    /*+DRIVING_SITE(A)*/  ';
V_SQL := V_SQL||chr(10) || '                        RANK() OVER (PARTITION BY SETID, INV_ITEM_ID ORDER BY EFFDT DESC) RANK, ';
V_SQL := V_SQL||chr(10) || '                       TO_NUMBER(REPLACE(REPLACE (MSAFI.PS_TRANSLATE(''DSP_ALIQ_ICMS'',DSP_ALIQ_ICMS), ''%'', ''''), ''<VLR INVALIDO>'', ''0'')) AS ALIQ_INTERNA ';
V_SQL := V_SQL||chr(10) || '                     FROM MSAFI.PS_DSP_LN_MVA_HIS A ';
V_SQL := V_SQL||chr(10) || '                      WHERE INV_ITEM_ID       =  X2013.COD_PRODUTO ';
V_SQL := V_SQL||chr(10) || '                      AND    CRIT_STATE_TO_PBL = ''ES'' ';
V_SQL := V_SQL||chr(10) || '                      AND    CRIT_STATE_FR_PBL = ''ES'' ';
V_SQL := V_SQL||chr(10) || '                      AND    SETID             = ''GERAL'' ';
V_SQL := V_SQL||chr(10) || '                      AND    EFFDT            <= X07.DATA_FISCAL)      ';
V_SQL := V_SQL||chr(10) || '                      WHERE RANK = 1   )         AS ALIQ_INTERNA  --36 ';
V_SQL := V_SQL||chr(10) || '        ,TRUNC( X08.VLR_ITEM/X08.QUANTIDADE,2 )                                     AS VLR_UNIT_ITEM     --37 ';
V_SQL := V_SQL||chr(10) || '         ---  ';
V_SQL := V_SQL||chr(10) || '         -- ICMS_PROPRIO     ';
V_SQL := V_SQL||chr(10) || '         ---';
V_SQL := V_SQL||chr(10) || '    ,  ( SELECT  ICMS_PROPRIO ';
V_SQL := V_SQL||chr(10) || '          FROM (  ';
V_SQL := V_SQL||chr(10) || '         SELECT /*+DRIVING_SITE(TAB)*/  ';
V_SQL := V_SQL||chr(10) || '           ((X08.VLR_ITEM * TAB.DSP_ALIQ_ICMS/100) * (1 - DSP_PCT_RED_ICMSST/100 ) )ICMS_PROPRIO ';
V_SQL := V_SQL||chr(10) || '       , RANK() OVER (PARTITION BY TAB.SETID, TAB.INV_ITEM_ID ORDER BY TAB.EFFDT DESC) AS RANK   ';
V_SQL := V_SQL||chr(10) || '         FROM msafi.PS_DSP_ITEM_LN_MVA     TAB ';
V_SQL := V_SQL||chr(10) || '         ,    MSAFI.DSP_ESTABELECIMENTO    EST                             ';                            
V_SQL := V_SQL||chr(10) || '         WHERE TAB.SETID             = ''GERAL''   ';
V_SQL := V_SQL||chr(10) || '          AND  TAB.INV_ITEM_ID       = X2013.COD_PRODUTO  ';
V_SQL := V_SQL||chr(10) || '          AND  EST.COD_EMPRESA       = X07.COD_EMPRESA    ';                                                 
V_SQL := V_SQL||chr(10) || '          AND  EST.COD_ESTAB         = X07.COD_ESTAB      ';
V_SQL := V_SQL||chr(10) || '          AND  TAB.CRIT_STATE_TO_PBL = EST.COD_ESTADO     ';
V_SQL := V_SQL||chr(10) || '          AND  TAB.CRIT_STATE_FR_PBL = EST.COD_ESTADO     ';
V_SQL := V_SQL||chr(10) || '          AND TAB.EFFDT             <= X07.DATA_FISCAL    ';
V_SQL := V_SQL||chr(10) || '         )  WHERE RANK = 1 )                                                             AS    ICMS_PROPRIO  --38 ';
V_SQL := V_SQL||chr(10) || '          -- ';
V_SQL := V_SQL||chr(10) || '          --  BC_ICMS_ST ';
V_SQL := V_SQL||chr(10) || '          -- ';
V_SQL := V_SQL||chr(10) || '      ,  ( SELECT  ROUND(BC_ICMS_ST,2) ';
V_SQL := V_SQL||chr(10) || '            FROM (  ';
V_SQL := V_SQL||chr(10) || '           SELECT /*+DRIVING_SITE(TAB)*/ ';
V_SQL := V_SQL||chr(10) || '              ( CASE WHEN  nvl(TAB.PRICE_ST_BBL, 0) > 0 THEN  (  TAB.MVA_PCT_BBL*X08.QUANTIDADE ) *(  1- TAB.DSP_PCT_RED_ICMSST )      ';
V_SQL := V_SQL||chr(10) || '                     WHEN  nvl(TAB.PRICE_ST_BBL,0)  = 0 THEN  ( X08.VLR_ITEM * ( 1 + MVA_PCT_BBL /100) * (1 - DSP_PCT_RED_ICMSST ) )   ';              
V_SQL := V_SQL||chr(10) || '           END) BC_ICMS_ST ';
V_SQL := V_SQL||chr(10) || '          , RANK() OVER (PARTITION BY TAB.SETID, TAB.INV_ITEM_ID ORDER BY TAB.EFFDT DESC) AS RANK    ';
V_SQL := V_SQL||chr(10) || '         FROM msafi.PS_DSP_ITEM_LN_MVA     TAB ';
V_SQL := V_SQL||chr(10) || '         ,    MSAFI.DSP_ESTABELECIMENTO    EST                             ';                            
V_SQL := V_SQL||chr(10) || '         WHERE TAB.SETID             = ''GERAL''   ';
V_SQL := V_SQL||chr(10) || '          AND  TAB.INV_ITEM_ID       = X2013.COD_PRODUTO ';
V_SQL := V_SQL||chr(10) || '          AND  EST.COD_EMPRESA       = X07.COD_EMPRESA   ';                                                 
V_SQL := V_SQL||chr(10) || '          AND  EST.COD_ESTAB         = X07.COD_ESTAB     ';
V_SQL := V_SQL||chr(10) || '          AND  TAB.CRIT_STATE_TO_PBL = EST.COD_ESTADO    ';
V_SQL := V_SQL||chr(10) || '          AND  TAB.CRIT_STATE_FR_PBL = EST.COD_ESTADO    ';
V_SQL := V_SQL||chr(10) || '          AND TAB.EFFDT             <= X07.DATA_FISCAL   ';
V_SQL := V_SQL||chr(10) || '         )  WHERE RANK = 1 )                                                                     AS    BC_ICMS_ST   --39  ';
V_SQL := V_SQL||chr(10) || '         -- ';
V_SQL := V_SQL||chr(10) || '         --  ICMS_ST ';
V_SQL := V_SQL||chr(10) || '         --- ';
V_SQL := V_SQL||chr(10) || '       ,  ( SELECT  ';
V_SQL := V_SQL||chr(10) || '           ROUND  ( (CASE  ';
V_SQL := V_SQL||chr(10) || '                 WHEN ( BC_ICMS_ST * (ALIQUOTA_INTERNA/100 )) - ICMS_PROPRIO  < 0 THEN 0 ';
V_SQL := V_SQL||chr(10) || '                  ELSE ( BC_ICMS_ST * (ALIQUOTA_INTERNA/100 )) - ICMS_PROPRIO ';
V_SQL := V_SQL||chr(10) || '                  END  ),2)  ';
V_SQL := V_SQL||chr(10) || '            FROM (  ';
V_SQL := V_SQL||chr(10) || '           SELECT /*+DRIVING_SITE(TAB)*/ ';
V_SQL := V_SQL||chr(10) || '              ( CASE WHEN  nvl(TAB.PRICE_ST_BBL, 0) > 0 THEN  (  TAB.MVA_PCT_BBL*X08.QUANTIDADE ) *( 1- TAB.DSP_PCT_RED_ICMSST ) ';
V_SQL := V_SQL||chr(10) || '                     WHEN  nvl(TAB.PRICE_ST_BBL,0)  = 0 THEN  ( X08.VLR_ITEM * ( 1 + MVA_PCT_BBL ) * (1 -DSP_PCT_RED_ICMSST ) )  ';                
V_SQL := V_SQL||chr(10) || '             END) BC_ICMS_ST ';
V_SQL := V_SQL||chr(10) || '             ,  ((X08.VLR_ITEM * TAB.DSP_ALIQ_ICMS/100) * (1 - DSP_PCT_RED_ICMSST/100  ) ) ICMS_PROPRIO ';
V_SQL := V_SQL||chr(10) || '             ,    (TAB.DSP_ALIQ_ICMS/100)                   AS  ALIQUOTA_INTERNA ';
V_SQL := V_SQL||chr(10) || '             , RANK() OVER (PARTITION BY TAB.SETID, TAB.INV_ITEM_ID ORDER BY TAB.EFFDT DESC) AS RANK   ';
V_SQL := V_SQL||chr(10) || '             FROM msafi.PS_DSP_ITEM_LN_MVA     TAB ';
V_SQL := V_SQL||chr(10) || '             ,    MSAFI.DSP_ESTABELECIMENTO    EST   ';                                                      
V_SQL := V_SQL||chr(10) || '             WHERE TAB.SETID             = ''GERAL''   ';
V_SQL := V_SQL||chr(10) || '              AND  TAB.INV_ITEM_ID       = X2013.COD_PRODUTO  '; 
V_SQL := V_SQL||chr(10) || '              AND  EST.COD_EMPRESA       = X07.COD_EMPRESA    ';                                                  
V_SQL := V_SQL||chr(10) || '              AND  EST.COD_ESTAB         = X07.COD_ESTAB      ';
V_SQL := V_SQL||chr(10) || '              AND  TAB.CRIT_STATE_TO_PBL = EST.COD_ESTADO     ';
V_SQL := V_SQL||chr(10) || '              AND  TAB.CRIT_STATE_FR_PBL = EST.COD_ESTADO     ';
V_SQL := V_SQL||chr(10) || '              AND TAB.EFFDT             <= X07.DATA_FISCAL    ';
V_SQL := V_SQL||chr(10) || '             )  WHERE RANK = 1 )                                                                      AS ICMS_ST             -- 40 ';
V_SQL := V_SQL||chr(10) || '             ,NULL                                                                                    AS COD_ESTADO_TO       -- 41 ';
V_SQL := V_SQL||chr(10) || '             ,NULL                                                                                    AS COD_ESTADO_FROM     -- 42 ';
V_SQL := V_SQL||chr(10) || '            , '''|| MPROC_ID ||'''                                                                               AS PROC_ID             -- 43 ';
V_SQL := V_SQL||chr(10) || '            , '''|| MNM_USUARIO ||'''                                                                             AS NM_USUARIO          -- 44 '; 
V_SQL := V_SQL||chr(10) || '             ,SYSDATE                                                                                 AS DT_CARGA            -- 45 ';
V_SQL := V_SQL||chr(10) || '             , X07.SERIE_DOCFIS ';
V_SQL := V_SQL||chr(10) || '             ,X2006.COD_NATUREZA_OP ';
V_SQL := V_SQL||chr(10) || '           FROM MSAF.X07_DOCTO_FISCAL        X07,      ';
V_SQL := V_SQL||chr(10) || '                MSAF.X08_ITENS_MERC          X08,      ';
V_SQL := V_SQL||chr(10) || '                MSAF.X04_PESSOA_FIS_JUR      X04,      ';
V_SQL := V_SQL||chr(10) || '                MSAF.ESTADO                  ESTADO,   ';
V_SQL := V_SQL||chr(10) || '                MSAF.X2005_TIPO_DOCTO        X2005,    ';
V_SQL := V_SQL||chr(10) || '                MSAF.X2024_MODELO_DOCTO      X2024,    ';
V_SQL := V_SQL||chr(10) || '                MSAF.X2012_COD_FISCAL        X2012,    ';
V_SQL := V_SQL||chr(10) || '                MSAF.X2013_PRODUTO           X2013,    ';
V_SQL := V_SQL||chr(10) || '                MSAF.X2043_COD_NBM           X2043,    ';
V_SQL := V_SQL||chr(10) || '                MSAF.Y2025_SIT_TRB_UF_A      Y2025,    ';
V_SQL := V_SQL||chr(10) || '                MSAF.Y2026_SIT_TRB_UF_B      Y2026,    ';
V_SQL := V_SQL||chr(10) || '                MSAF.X2006_NATUREZA_OP       X2006     ';   
V_SQL := V_SQL||chr(10) || '          WHERE  X07.COD_EMPRESA         = X08.COD_EMPRESA ';
V_SQL := V_SQL||chr(10) || '              AND X07.COD_ESTAB          = X08.COD_ESTAB   ';
V_SQL := V_SQL||chr(10) || '              AND X07.DATA_FISCAL        = X08.DATA_FISCAL ';
V_SQL := V_SQL||chr(10) || '              AND X07.MOVTO_E_S          = X08.MOVTO_E_S   ';
V_SQL := V_SQL||chr(10) || '              AND X07.NORM_DEV           = X08.NORM_DEV    ';
V_SQL := V_SQL||chr(10) || '              AND X07.IDENT_DOCTO        = X08.IDENT_DOCTO ';
V_SQL := V_SQL||chr(10) || '              AND X07.IDENT_FIS_JUR      = X08.IDENT_FIS_JUR    ';
V_SQL := V_SQL||chr(10) || '              AND X07.NUM_DOCFIS         = X08.NUM_DOCFIS       ';
V_SQL := V_SQL||chr(10) || '              AND X07.SERIE_DOCFIS       = X08.SERIE_DOCFIS     ';
V_SQL := V_SQL||chr(10) || '              AND X07.SUB_SERIE_DOCFIS   = X08.SUB_SERIE_DOCFIS ';
V_SQL := V_SQL||chr(10) || '              AND X07.IDENT_MODELO       = X2024.IDENT_MODELO   ';
V_SQL := V_SQL||chr(10) || '              AND X07.IDENT_FIS_JUR      = X04.IDENT_FIS_JUR    ';
V_SQL := V_SQL||chr(10) || '              AND X07.IDENT_DOCTO        = X2005.IDENT_DOCTO    ';
V_SQL := V_SQL||chr(10) || '              AND X04.IDENT_ESTADO       = ESTADO.IDENT_ESTADO  ';
V_SQL := V_SQL||chr(10) || '              AND X08.IDENT_CFO          = X2012.IDENT_CFO      ';
V_SQL := V_SQL||chr(10) || '              AND X08.IDENT_PRODUTO      = X2013.IDENT_PRODUTO  ';
V_SQL := V_SQL||chr(10) || '              AND X2013.IDENT_NBM        = X2043.IDENT_NBM      ';
V_SQL := V_SQL||chr(10) || '              AND Y2025.IDENT_SITUACAO_A = X08.IDENT_SITUACAO_A     ';
V_SQL := V_SQL||chr(10) || '              AND X08.IDENT_SITUACAO_B   = Y2026.IDENT_SITUACAO_B   ';
V_SQL := V_SQL||chr(10) || '              AND X08.IDENT_NATUREZA_OP  = X2006.IDENT_NATUREZA_OP  ';
--
V_SQL := V_SQL||chr(10) || '              AND X07.MOVTO_E_S                  = ''9'' ';
V_SQL := V_SQL||chr(10) || '              AND X07.SITUACAO                   = ''N'' ';
V_SQL := V_SQL||chr(10) || '              AND X07.COD_EMPRESA                = '''|| MCOD_EMPRESA ||'''  ';
V_SQL := V_SQL||chr(10) || '              AND X07.COD_ESTAB                  = '''|| PCOD_ESTAB ||''' ';
V_SQL := V_SQL||chr(10) || '              AND  X2012.COD_CFO                 =  ''5409'' ';
--
V_SQL := V_SQL||chr(10) || '              AND X07.DATA_FISCAL BETWEEN '''|| PDT_INI||'''  AND  '''||PDT_FIM||''' )   )   ';
              
           
                             
 -- EXECUTE IMMEDIATE V_SQL;
     OPEN C_AUX FOR V_SQL;
     LOOP
     FETCH C_AUX BULK COLLECT INTO L_TB_FIN048_RET_NF_SAI LIMIT 100;

     V_COUNT := V_COUNT + 100;
     
      DBMS_APPLICATION_INFO.SET_MODULE('48 - SAIDA', '[' || v_count || ']');     
      BEGIN
       FORALL i IN L_TB_FIN048_RET_NF_SAI.FIRST .. L_TB_FIN048_RET_NF_SAI.LAST SAVE
                                                   EXCEPTIONS
                                                        
      
        INSERT INTO msafi.DPSP_FIN048_RET_NF_SAI
        VALUES L_TB_FIN048_RET_NF_SAI
          (i);       
      v_count_new := v_count_new + SQL%ROWCOUNT;
      COMMIT;                
                                 
                                 
                   
                          EXCEPTION 
                              WHEN forall_failed THEN 
                                 L_ERRORS := SQL%BULK_EXCEPTIONS.COUNT;
                                 
                                 FOR I IN 1 .. L_ERRORS
                                 
                                  LOOP                      
                                  L_ERRNO := SQL%BULK_EXCEPTIONS(I).ERROR_CODE;
                                  L_MSG   := SQLERRM(-L_ERRNO);
                                  L_IDX   := SQL%BULK_EXCEPTIONS(I).ERROR_INDEX;  
                                  
                                    INSERT  INTO  MSAFI.LOG_GERAL
                                   (ora_err_number1, ora_err_mesg1, ora_err_optyp1
                                    ,COD_EMPRESA,  COD_ESTAB ,  DATA_FISCAL ,  NUM_DOCFIS, NUM_ITEM
                                   
                                   )   

                                   VALUES ( dbms_utility.format_error_backtrace()
                                   , L_MSG
                                   , L_IDX
                                   , L_TB_FIN048_RET_NF_SAI(I).COD_EMPRESA 
                                   , L_TB_FIN048_RET_NF_SAI(I).COD_ESTAB 
                                   , L_TB_FIN048_RET_NF_SAI(I).DATA_FISCAL 
                                   , L_TB_FIN048_RET_NF_SAI(I).NUM_DOCFIS 
                                   , L_TB_FIN048_RET_NF_SAI(I).NUM_ITEM);
                                
                                    COMMIT;
                                    
                                  END LOOP;                                                  
                                  
                         END; 
                         
                            EXIT WHEN C_AUX%NOTFOUND;
                            END LOOP;
                            CLOSE C_AUX;
                            
                    BEGIN                 
                    
                      PROC_UPD_SAIDA ( PDT_INI , PDT_FIM , PCOD_ESTAB);
                                          
                   COMMIT;
                   --
                   END ;          
                        
                     
  END;                       
                                                                                             
                   
                  
    RETURN NVL(V_COUNT_NEW, 0);
  
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
  
    EXECUTE IMMEDIATE 'ALTER SESSION SET TEMP_UNDO_ENABLED=FALSE '; --EVITAR PROBLEMAS DE GRAVACAO NAS GTTs
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
          DELETE FROM MSAFI.DPSP_FIN048_RET_NF_SAI
           WHERE COD_EMPRESA = MCOD_EMPRESA
             AND COD_ESTAB = CD.COD_ESTAB
             AND DATA_FISCAL BETWEEN V_DATA_INICIAL AND V_dATA_FINAL;
        
          LOGA('::LIMPEZA DOS REGISTROS ANTERIORES (DPSP_FIN048_RET_NF_SAI), CD: ' ||
               CD.COD_ESTAB || ' - QTDE ' || SQL%ROWCOUNT || '::',
               FALSE);
        
          COMMIT;
        
          --A carga irá executar o periodo inteiro, e depois consultar o periodo informado na tela.
          --Exemplo: Parametrizado do dia 1 ao 10, então será carregado de 1 a 31, mas consultado de 1 a 10
          V_QTD := CARREGAR_NF_SAIDA(V_DATA_INICIAL,
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
        
       ---   PROC_UPD_SAIDA ( V_DATA_INICIAL, V_DATA_FINAL,  CD.COD_ESTAB );
           
          LIB_PROC.ADD('CD ' || CD.COD_ESTAB ||' - Período já processado e encerrado');
        
          V_RETORNO_STATUS := MSAF.DPSP_SUPORTE_CPROC_PROCESS.retornar_status_rel (MCOD_EMPRESA,  CD.COD_ESTAB, TO_NUMBER(TO_CHAR(PDT_INI, 'YYYYMM')),$$PLSQL_UNIT);
          LIB_PROC.ADD('Data de Encerramento: ' || V_RETORNO_STATUS);
        
          LIB_PROC.ADD(' ');
          LOGA('---CD ' || CD.COD_ESTAB ||' - PERIODO JÁ PROCESSADO E ENCERRADO: ' ||V_RETORNO_STATUS || '---',FALSE);
        
        END IF;
      
        --Limpar variaveis para proximo estab
        V_QTD            := 0;
        V_RETORNO_STATUS := '';
        V_SQL            := '';
      
      END LOOP;
    
      DBMS_APPLICATION_INFO.SET_MODULE($$PLSQL_UNIT,
                                       'Estab: ' || PCOD_ESTAB ||
                                       ' gerar arquivos ');
    
      --=================================================================================
      -- GERAR ARQUIVO ANALITICO
      --=================================================================================
      LIB_PROC.add_tipo(MPROC_ID,
                        i,
                        TO_CHAR(pdt_ini, 'YYYYMM') ||
                        '_Ret_ICMS_ES_Saidas.xls',
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
                                                    DSP_PLANILHA.CAMPO('') || --     
                                                    DSP_PLANILHA.CAMPO('') || --     
                                                    DSP_PLANILHA.CAMPO('') || --     
                                                    DSP_PLANILHA.CAMPO('') || --     
                                                    DSP_PLANILHA.CAMPO('') || --     
                                                    DSP_PLANILHA.CAMPO('') || --     
                                                    DSP_PLANILHA.CAMPO('') || --     
                                                    DSP_PLANILHA.CAMPO('') || --     
                                                    DSP_PLANILHA.CAMPO('TABELAO') || --     
                                                    DSP_PLANILHA.CAMPO('') || --     
                                                    DSP_PLANILHA.CAMPO('') || --     
                                                    DSP_PLANILHA.CAMPO('') || --     
                                                    DSP_PLANILHA.CAMPO('') || --     
                                                    DSP_PLANILHA.CAMPO('') || --     
                                                    DSP_PLANILHA.CAMPO('') || --     
                                                    DSP_PLANILHA.CAMPO('CALCULADO') || --     
                                                    DSP_PLANILHA.CAMPO('') || --     
                                                    DSP_PLANILHA.CAMPO('') || --     
                                                    DSP_PLANILHA.CAMPO(''),
                                      P_CLASS    => 'h'),
                   PTIPO => i);
    
      FOR CD IN LISTA_CDs LOOP
      
        LIB_PROC.ADD(DSP_PLANILHA.LINHA(P_CONTEUDO => DSP_PLANILHA.CAMPO('COD_EMPRESA') || --
                                                      DSP_PLANILHA.CAMPO('COD_ESTAB') || --     
                                                      DSP_PLANILHA.CAMPO('DATA_FISCAL') || --     
                                                      DSP_PLANILHA.CAMPO('NUM_DOCFIS') || --     
                                                      DSP_PLANILHA.CAMPO('NUM_CONTROLE_DOCTO') || --     
                                                      DSP_PLANILHA.CAMPO('NUM_AUTENTIC_NFE') || --     
                                                      DSP_PLANILHA.CAMPO('COD_FIS_JUR') || --     
                                                      DSP_PLANILHA.CAMPO('CPF_CGC') || --     
                                                      DSP_PLANILHA.CAMPO('COD_DOCTO') || --     
                                                      DSP_PLANILHA.CAMPO('COD_MODELO') || --     
                                                      DSP_PLANILHA.CAMPO('COD_CFO') || --     
                                                      DSP_PLANILHA.CAMPO('COD_PRODUTO') || --     
                                                      DSP_PLANILHA.CAMPO('DESCRICAO') || --     
                                                      DSP_PLANILHA.CAMPO('NUM_ITEM') || --     
                                                      DSP_PLANILHA.CAMPO('VLR_CONTABIL_ITEM') || --     
                                                      DSP_PLANILHA.CAMPO('VLR_ITEM') || --     
                                                      DSP_PLANILHA.CAMPO('VLR_BASE_ICMS_1') || --     
                                                      DSP_PLANILHA.CAMPO('VLR_BASE_ICMS_2') || --     
                                                      DSP_PLANILHA.CAMPO('VLR_BASE_ICMS_3') || --     
                                                      DSP_PLANILHA.CAMPO('VLR_BASE_ICMS_4') || --     
                                                      DSP_PLANILHA.CAMPO('VLR_IPI_NDESTAC') || --     
                                                      DSP_PLANILHA.CAMPO('VLR_DESCONTO') || --     
                                                      DSP_PLANILHA.CAMPO('ALIQ_TRIBUTO_ICMS') || --     
                                                      DSP_PLANILHA.CAMPO('VLR_ICMS_ST') || --     
                                                      DSP_PLANILHA.CAMPO('VLR_BASE_ST') || --     
                                                      DSP_PLANILHA.CAMPO('VLR_ICMS_PROPRIO') || --     
                                                      DSP_PLANILHA.CAMPO('CST') || --     
                                                      DSP_PLANILHA.CAMPO('QUANTIDADE') || --     
                                                      DSP_PLANILHA.CAMPO('NCM') || --     
                                                      DSP_PLANILHA.CAMPO('MVA') || --     
                                                      DSP_PLANILHA.CAMPO('PMC_PAUTA') || --     
                                                      DSP_PLANILHA.CAMPO('TP_CALC') || --     
                                                      DSP_PLANILHA.CAMPO('SIT_TRIB') || --     
                                                      DSP_PLANILHA.CAMPO('PERC_RED_BSST') || --     
                                                      DSP_PLANILHA.CAMPO('FINALIDADE') || --     
                                                      DSP_PLANILHA.CAMPO('ALIQUOTA_INTERNA') || --     
                                                      DSP_PLANILHA.CAMPO('VLR_UNIT_ITEM') || --     
                                                      DSP_PLANILHA.CAMPO('ICMS_PROPRIO') || --     
                                                      DSP_PLANILHA.CAMPO('BC_ICMS_ST') || --     
                                                      DSP_PLANILHA.CAMPO('ICMS_ST'),
                                        
                                        P_CLASS => 'h'),
                     PTIPO => i);
      
        FOR CR_R IN (SELECT COD_EMPRESA,
                            COD_ESTAB,
                            DATA_FISCAL,
                            NUM_DOCFIS,
                            NUM_CONTROLE_DOCTO,
                            NUM_AUTENTIC_NFE,
                            COD_FIS_JUR,
                            CPF_CGC,
                            COD_DOCTO,
                            COD_MODELO,
                            COD_CFO,
                            COD_PRODUTO,
                            DESCRICAO,
                            NUM_ITEM,
                            VLR_CONTABIL_ITEM,
                            VLR_ITEM,
                            VLR_BASE_ICMS_1,
                            VLR_BASE_ICMS_2,
                            VLR_BASE_ICMS_3,
                            VLR_BASE_ICMS_4,
                            VLR_IPI_NDESTAC,
                            VLR_DESCONTO,
                            ALIQ_TRIBUTO_ICMS,
                            VLR_ICMS_ST,
                            VLR_BASE_ST,
                            VLR_ICMS_PROPRIO,
                            CST,
                            QUANTIDADE,
                            NCM,
                            MVA,
                            PMC_PAUTA,
                            TP_CALC,
                            SIT_TRIB,
                            PERC_RED_BSST,
                            FINALIDADE,
                            ALIQUOTA_INTERNA,
                            VLR_UNIT_ITEM,
                            ICMS_PROPRIO,
                            BC_ICMS_ST,
                            ICMS_ST
                       FROM MSAFI.DPSP_FIN048_RET_NF_SAI
                      WHERE COD_EMPRESA = MCOD_EMPRESA
                        AND COD_ESTAB = CD.COD_ESTAB
                        AND DATA_FISCAL BETWEEN PDT_INI AND PDT_FIM) LOOP
        
          IF V_CLASS = 'a' THEN
            V_CLASS := 'b';
          ELSE
            V_CLASS := 'a';
          END IF;
        
          V_TEXT01 := DSP_PLANILHA.LINHA(P_CONTEUDO => DSP_PLANILHA.CAMPO(CR_R.COD_EMPRESA) || --     
                                                       DSP_PLANILHA.CAMPO(CR_R.COD_ESTAB) || --     
                                                       DSP_PLANILHA.CAMPO(CR_R.DATA_FISCAL) || --     
                                                       DSP_PLANILHA.CAMPO(DSP_PLANILHA.TEXTO(CR_R.NUM_DOCFIS)) || --     
                                                       DSP_PLANILHA.CAMPO(DSP_PLANILHA.TEXTO(CR_R.NUM_CONTROLE_DOCTO)) || --     
                                                       DSP_PLANILHA.CAMPO(DSP_PLANILHA.TEXTO(CR_R.NUM_AUTENTIC_NFE)) || --     
                                                       DSP_PLANILHA.CAMPO(DSP_PLANILHA.TEXTO(CR_R.COD_FIS_JUR)) || --     
                                                       DSP_PLANILHA.CAMPO(DSP_PLANILHA.TEXTO(CR_R.CPF_CGC)) || --     
                                                       DSP_PLANILHA.CAMPO(DSP_PLANILHA.TEXTO(CR_R.COD_DOCTO)) || --     
                                                       DSP_PLANILHA.CAMPO(DSP_PLANILHA.TEXTO(CR_R.COD_MODELO)) || --     
                                                       DSP_PLANILHA.CAMPO(DSP_PLANILHA.TEXTO(CR_R.COD_CFO)) || --     
                                                       DSP_PLANILHA.CAMPO(DSP_PLANILHA.TEXTO(CR_R.COD_PRODUTO)) || --     
                                                       DSP_PLANILHA.CAMPO(DSP_PLANILHA.TEXTO(CR_R.DESCRICAO)) || --     
                                                       DSP_PLANILHA.CAMPO(CR_R.NUM_ITEM) || --     
                                                       DSP_PLANILHA.CAMPO(CR_R.VLR_CONTABIL_ITEM) || --     
                                                       DSP_PLANILHA.CAMPO(CR_R.VLR_ITEM) || --     
                                                       DSP_PLANILHA.CAMPO(CR_R.VLR_BASE_ICMS_1) || --     
                                                       DSP_PLANILHA.CAMPO(CR_R.VLR_BASE_ICMS_2) || --     
                                                       DSP_PLANILHA.CAMPO(CR_R.VLR_BASE_ICMS_3) || --     
                                                       DSP_PLANILHA.CAMPO(CR_R.VLR_BASE_ICMS_4) || --     
                                                       DSP_PLANILHA.CAMPO(CR_R.VLR_IPI_NDESTAC) || --     
                                                       DSP_PLANILHA.CAMPO(CR_R.VLR_DESCONTO) || --     
                                                       DSP_PLANILHA.CAMPO(CR_R.ALIQ_TRIBUTO_ICMS) || --     
                                                       DSP_PLANILHA.CAMPO(CR_R.VLR_ICMS_ST) || --     
                                                       DSP_PLANILHA.CAMPO(CR_R.VLR_BASE_ST) || --     
                                                       DSP_PLANILHA.CAMPO(CR_R.VLR_ICMS_PROPRIO) || --     
                                                       DSP_PLANILHA.CAMPO(DSP_PLANILHA.TEXTO(CR_R.CST)) || --     
                                                       DSP_PLANILHA.CAMPO(CR_R.QUANTIDADE) || --     
                                                       DSP_PLANILHA.CAMPO(DSP_PLANILHA.TEXTO(CR_R.NCM)) || --     
                                                       DSP_PLANILHA.CAMPO(CR_R.MVA) || --     
                                                       DSP_PLANILHA.CAMPO(CR_R.PMC_PAUTA) || --     
                                                       DSP_PLANILHA.CAMPO(CR_R.TP_CALC) || --     
                                                       DSP_PLANILHA.CAMPO(CR_R.SIT_TRIB) || --     
                                                       DSP_PLANILHA.CAMPO(CR_R.PERC_RED_BSST) || --     
                                                       DSP_PLANILHA.CAMPO(CR_R.FINALIDADE) || --     
                                                       DSP_PLANILHA.CAMPO(CR_R.ALIQUOTA_INTERNA) || --     
                                                       DSP_PLANILHA.CAMPO(CR_R.VLR_UNIT_ITEM) || --     
                                                       DSP_PLANILHA.CAMPO(CR_R.ICMS_PROPRIO) || --     
                                                       DSP_PLANILHA.CAMPO(CR_R.BC_ICMS_ST) || --     
                                                       DSP_PLANILHA.CAMPO(CR_R.ICMS_ST),
                                         P_CLASS    => V_CLASS);
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
                        '_Ret_ICMS_ES_Saidas_Sintetico.xls',
                        2);
      LIB_PROC.ADD(DSP_PLANILHA.HEADER, PTIPO => i);
      LIB_PROC.ADD(DSP_PLANILHA.TABELA_INICIO, PTIPO => i);
    
      FOR CD IN LISTA_CDs LOOP
      
        LIB_PROC.ADD(DSP_PLANILHA.LINHA(P_CONTEUDO => DSP_PLANILHA.CAMPO('PERIODO') || --    
                                                      DSP_PLANILHA.CAMPO('VLR_TOTAL_ICMS_PROPRIO') || --    
                                                      DSP_PLANILHA.CAMPO('VLR_TOTAL_ICMS_ST'),
                                        
                                        P_CLASS => 'h'),
                     PTIPO => i);
      
        FOR CR_R IN (    SELECT 
                            TO_CHAR(DATA_FISCAL, 'MM/YYYY')         AS PERIODO,
                            SUM(ICMS_PROPRIO)                       AS VLR_TOTAL_ICMS_PROPRIO,
                            SUM(ICMS_ST)                            AS VLR_TOTAL_ICMS_ST
                       FROM MSAFI.DPSP_FIN048_RET_NF_SAI
                      WHERE COD_EMPRESA         = MCOD_EMPRESA
                        AND COD_ESTAB           = CD.COD_ESTAB
                        AND DATA_FISCAL BETWEEN PDT_INI AND PDT_FIM
                      GROUP BY TO_CHAR(DATA_FISCAL, 'MM/YYYY')
                      ) 
        LOOP
        
          IF V_CLASS = 'a' THEN
            V_CLASS := 'b';
          ELSE
            V_CLASS := 'a';
          END IF;
        
          V_TEXT01 := DSP_PLANILHA.LINHA(P_CONTEUDO => DSP_PLANILHA.CAMPO(CR_R.PERIODO) || --    
                                                       DSP_PLANILHA.CAMPO(CR_R.VLR_TOTAL_ICMS_PROPRIO) || --    
                                                       DSP_PLANILHA.CAMPO(CR_R.VLR_TOTAL_ICMS_ST),
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
  
  exception
    WHEN OTHERS THEN
    
      LOGA('SQLERRM: ' || SQLERRM, FALSE);
      LIB_PROC.add_log('Erro não tratado: ' ||
                       DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                       1);
      LIB_PROC.add_log('SQLERRM: ' || SQLERRM, 1);
      LIB_PROC.ADD('ERRO!');
      LIB_PROC.ADD(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
    

    LIB_PROC.CLOSE;
    COMMIT;
    RETURN MPROC_ID;
  
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
               'DPSP_FIN048_RET_SAIDA_CPROC');
    
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
               'DPSP_FIN048_RET_SAIDA_CPROC');
    
    END IF;
  
  END;
 
END DPSP_FIN048_RET_SAIDA_CPROC;
/