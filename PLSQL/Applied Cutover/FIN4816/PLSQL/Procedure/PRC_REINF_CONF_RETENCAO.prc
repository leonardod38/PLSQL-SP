CREATE OR REPLACE drop PROCEDURE prc_reinf_conf_retencao(
                                                   P_COD_EMPRESA IN VARCHAR2,
                                                   P_COD_ESTAB IN VARCHAR2,
                                                   P_TIPO_SELEC IN VARCHAR2,
                                                   P_DATA_INICIAL IN DATE,
                                                   P_DATA_FINAL   IN DATE,
                                                   P_COD_USUARIO  IN VARCHAR2,
                                                   P_ENTRADA_SAIDA IN VARCHAR2,
                                                   P_STATUS     OUT NUMBER,
                                                   P_PROCID IN NUMBER ) IS


  COD_EMPRESA_W  ESTABELECIMENTO.COD_EMPRESA%TYPE;
  COD_ESTAB_W    ESTABELECIMENTO.COD_ESTAB%TYPE;
  DATA_INI_W     DATE;
  DATA_FIM_W     DATE; 
    
   
   CURSOR C_CONF_RET_PREV (P_COD_EMPRESA VARCHAR2, 
                           P_COD_ESTAB VARCHAR2,
                           P_DATA_INICIAL  DATE,
                           P_DATA_FINAL  DATE) IS
          
          SELECT DOC_FIS.DATA_EMISSAO
                ,DOC_FIS.DATA_FISCAL
                ,DOC_FIS.IDENT_FIS_JUR
                ,DOC_FIS.IDENT_DOCTO
                ,DOC_FIS.NUM_DOCFIS
                ,DOC_FIS.SERIE_DOCFIS
                ,DOC_FIS.SUB_SERIE_DOCFIS
                ,TIPO_SERV.IDENT_TIPO_SERV_ESOCIAL
                ,DOC_FIS.COD_CLASS_DOC_FIS
                ,DOC_FIS.VLR_TOT_NOTA
                ,DOC_FIS.VLR_CONTAB_COMPL
                ,DWT_ITENS.VLR_BASE_INSS
                ,DWT_ITENS.VLR_ALIQ_INSS
                ,DWT_ITENS.VLR_INSS_RETIDO
                ,X2058.IND_TP_PROC_ADJ
                ,X2058.NUM_PROC_ADJ
                ,DWT_ITENS.NUM_ITEM
                ,DWT_ITENS.VLR_SERVICO
                ,X2058_ADIC.IND_TP_PROC_ADJ
                ,X2058_ADIC.NUM_PROC_ADJ
                ,DWT_ITENS.IDENT_SERVICO
                , NULL 
                , NULL 
          FROM   DWT_DOCTO_FISCAL         DOC_FIS
                ,DWT_ITENS_SERV           DWT_ITENS
                ,X2018_SERVICOS           X2018
                ,PRT_ID_TIPO_SERV_ESOCIAL ID_TIPO_SERV
                ,PRT_TIPO_SERV_ESOCIAL    TIPO_SERV
                ,X2058_PROC_ADJ           X2058
                ,X2058_PROC_ADJ           X2058_ADIC
          WHERE  DOC_FIS.COD_EMPRESA                =  DWT_ITENS.COD_EMPRESA
          AND    DOC_FIS.COD_ESTAB                  =  DWT_ITENS.COD_ESTAB
          AND    DOC_FIS.DATA_FISCAL                =  DWT_ITENS.DATA_FISCAL
          AND    DOC_FIS.IDENT_FIS_JUR              =  DWT_ITENS.IDENT_FIS_JUR
          AND    DOC_FIS.IDENT_DOCTO                =  DWT_ITENS.IDENT_DOCTO
          AND    DOC_FIS.NUM_DOCFIS                 =  DWT_ITENS.NUM_DOCFIS
          AND    DOC_FIS.SERIE_DOCFIS               =  DWT_ITENS.SERIE_DOCFIS
          AND    DOC_FIS.SUB_SERIE_DOCFIS           =  DWT_ITENS.SUB_SERIE_DOCFIS
          AND    DWT_ITENS.IDENT_PROC_ADJ_PRINC     =  X2058.IDENT_PROC_ADJ(+)
          AND    DWT_ITENS.IDENT_PROC_ADJ_ADIC      =  X2058_ADIC.IDENT_PROC_ADJ(+)
          AND    ID_TIPO_SERV.COD_EMPRESA           =  DOC_FIS.COD_EMPRESA
          AND    ID_TIPO_SERV.COD_ESTAB             =  DOC_FIS.COD_ESTAB
          AND    DWT_ITENS.IDENT_SERVICO            =  X2018.IDENT_SERVICO
          AND    X2018.GRUPO_SERVICO                =  ID_TIPO_SERV.GRUPO_SERVICO
          AND    X2018.COD_SERVICO                  =  ID_TIPO_SERV.COD_SERVICO
          AND    ID_TIPO_SERV.COD_TIPO_SERV_ESOCIAL =  TIPO_SERV.COD_TIPO_SERV_ESOCIAL
          AND    TIPO_SERV.DATA_INI_VIGENCIA        =  (SELECT MAX(A.DATA_INI_VIGENCIA)
                                                        FROM   PRT_TIPO_SERV_ESOCIAL A
                                                        WHERE  A.COD_TIPO_SERV_ESOCIAL  = TIPO_SERV.COD_TIPO_SERV_ESOCIAL
                                                        AND    A.DATA_INI_VIGENCIA     <= P_DATA_FINAL)
          AND    DOC_FIS.DAT_CANCELAMENTO           IS NULL
          AND    DOC_FIS.COD_CLASS_DOC_FIS          IN ('2', '3')
          AND    DOC_FIS.NORM_DEV                    =  '1'
        
          AND  ((DOC_FIS.MOVTO_E_S < '9' AND P_ENTRADA_SAIDA = 'E') OR (DOC_FIS.MOVTO_E_S = '9' AND P_ENTRADA_SAIDA = 'S'))         
          AND    NVL(DWT_ITENS.VLR_INSS_RETIDO, 0)   >  0
          AND    DOC_FIS.SITUACAO = 'N'
          AND    DOC_FIS.COD_EMPRESA                 =  P_COD_EMPRESA
          AND    DOC_FIS.COD_ESTAB                   =  P_COD_ESTAB
          AND    DOC_FIS.DATA_EMISSAO               >= P_DATA_INICIAL
          AND    DOC_FIS.DATA_EMISSAO               <= P_DATA_FINAL
          
          
          UNION ALL
          SELECT DOC_FIS.DATA_EMISSAO
                ,DOC_FIS.DATA_FISCAL
                ,DOC_FIS.IDENT_FIS_JUR
                ,DOC_FIS.IDENT_DOCTO
                ,DOC_FIS.NUM_DOCFIS
                ,DOC_FIS.SERIE_DOCFIS
                ,DOC_FIS.SUB_SERIE_DOCFIS
                ,NULL 
                ,DOC_FIS.COD_CLASS_DOC_FIS
                ,DOC_FIS.VLR_TOT_NOTA
                ,DOC_FIS.VLR_CONTAB_COMPL
                ,DWT_ITENS.VLR_BASE_INSS
                ,DWT_ITENS.VLR_ALIQ_INSS
                ,DWT_ITENS.VLR_INSS_RETIDO
                ,X2058.IND_TP_PROC_ADJ
                ,X2058.NUM_PROC_ADJ
                ,DWT_ITENS.NUM_ITEM
                ,DWT_ITENS.VLR_SERVICO
                ,X2058_ADIC.IND_TP_PROC_ADJ
                ,X2058_ADIC.NUM_PROC_ADJ
                ,DWT_ITENS.IDENT_SERVICO
                , NULL 
                , PRT_PAR2_MSAF.COD_PARAM 
          FROM   DWT_DOCTO_FISCAL         DOC_FIS
                ,DWT_ITENS_SERV           DWT_ITENS
                ,X2018_SERVICOS           X2018
                ,PRT_SERV_MSAF
                ,PRT_PAR2_MSAF
                ,X2058_PROC_ADJ           X2058
                ,X2058_PROC_ADJ           X2058_ADIC
          WHERE  DOC_FIS.COD_EMPRESA                =  DWT_ITENS.COD_EMPRESA
          AND    DOC_FIS.COD_ESTAB                  =  DWT_ITENS.COD_ESTAB
          AND    DOC_FIS.DATA_FISCAL                =  DWT_ITENS.DATA_FISCAL
          AND    DOC_FIS.IDENT_FIS_JUR              =  DWT_ITENS.IDENT_FIS_JUR
          AND    DOC_FIS.IDENT_DOCTO                =  DWT_ITENS.IDENT_DOCTO
          AND    DOC_FIS.NUM_DOCFIS                 =  DWT_ITENS.NUM_DOCFIS
          AND    DOC_FIS.SERIE_DOCFIS               =  DWT_ITENS.SERIE_DOCFIS
          AND    DOC_FIS.SUB_SERIE_DOCFIS           =  DWT_ITENS.SUB_SERIE_DOCFIS
          AND    DWT_ITENS.IDENT_PROC_ADJ_PRINC     =  X2058.IDENT_PROC_ADJ(+)
          AND    DWT_ITENS.IDENT_PROC_ADJ_ADIC      =  X2058_ADIC.IDENT_PROC_ADJ(+)
          
          AND    PRT_SERV_MSAF.COD_EMPRESA           =  DOC_FIS.COD_EMPRESA
          AND    PRT_SERV_MSAF.COD_ESTAB             =  DOC_FIS.COD_ESTAB
          AND    DWT_ITENS.IDENT_SERVICO            =  X2018.IDENT_SERVICO
          AND    X2018.GRUPO_SERVICO                =  PRT_SERV_MSAF.GRUPO_SERVICO
          AND    X2018.COD_SERVICO                  =  PRT_SERV_MSAF.COD_SERVICO
          AND    PRT_SERV_MSAF.COD_PARAM            =  PRT_PAR2_MSAF.COD_PARAM
          AND    PRT_SERV_MSAF.COD_PARAM IN (683,684,685,686,690)
          
          AND    DOC_FIS.DAT_CANCELAMENTO           IS NULL
          AND    DOC_FIS.COD_CLASS_DOC_FIS          IN ('2', '3')
          AND    DOC_FIS.NORM_DEV                    =  '1'
        
          AND  ((DOC_FIS.MOVTO_E_S < '9' AND P_ENTRADA_SAIDA = 'E') OR (DOC_FIS.MOVTO_E_S = '9' AND P_ENTRADA_SAIDA = 'S'))         
          AND    NVL(DWT_ITENS.VLR_INSS_RETIDO, 0)   >  0
          AND    DOC_FIS.SITUACAO = 'N'
          AND    DOC_FIS.COD_EMPRESA                 =  P_COD_EMPRESA
          AND    DOC_FIS.COD_ESTAB                   =  P_COD_ESTAB
          AND    DOC_FIS.DATA_EMISSAO               >= P_DATA_INICIAL
          AND    DOC_FIS.DATA_EMISSAO               <= P_DATA_FINAL 
        
        
        
         
          UNION  ALL 
          SELECT DOC_FIS.DATA_EMISSAO
                ,DOC_FIS.DATA_FISCAL
                ,DOC_FIS.IDENT_FIS_JUR
                ,DOC_FIS.IDENT_DOCTO
                ,DOC_FIS.NUM_DOCFIS
                ,DOC_FIS.SERIE_DOCFIS
                ,DOC_FIS.SUB_SERIE_DOCFIS
                ,TIPO_SERV.IDENT_TIPO_SERV_ESOCIAL
                ,DOC_FIS.COD_CLASS_DOC_FIS
                ,DOC_FIS.VLR_TOT_NOTA
                ,DOC_FIS.VLR_CONTAB_COMPL
                ,DWT_MERC.VLR_BASE_INSS
                ,DWT_MERC.VLR_ALIQ_INSS
                ,DWT_MERC.VLR_INSS_RETIDO
                ,X2058.IND_TP_PROC_ADJ
                ,X2058.NUM_PROC_ADJ
                ,DWT_MERC.NUM_ITEM
                ,DWT_MERC.VLR_ITEM
                ,X2058_ADIC.IND_TP_PROC_ADJ
                ,X2058_ADIC.NUM_PROC_ADJ
                ,NULL 
                ,DWT_MERC.IDENT_PRODUTO
                ,NULL 
          FROM   DWT_DOCTO_FISCAL      DOC_FIS
                ,DWT_ITENS_MERC        DWT_MERC
                ,X2013_PRODUTO         X2013
                ,PRT_ID_TIPO_SERV_PROD ID_TIPO_SERV
                ,PRT_TIPO_SERV_ESOCIAL TIPO_SERV
                ,X2058_PROC_ADJ        X2058
                ,X2058_PROC_ADJ        X2058_ADIC
                ,X2024_MODELO_DOCTO    X2024
          WHERE  DOC_FIS.COD_EMPRESA                 = DWT_MERC.COD_EMPRESA
          AND    DOC_FIS.COD_ESTAB                   = DWT_MERC.COD_ESTAB
          AND    DOC_FIS.DATA_FISCAL                 = DWT_MERC.DATA_FISCAL
          AND    DOC_FIS.IDENT_FIS_JUR               = DWT_MERC.IDENT_FIS_JUR
          AND    DOC_FIS.IDENT_DOCTO                 = DWT_MERC.IDENT_DOCTO
          AND    DOC_FIS.NUM_DOCFIS                  = DWT_MERC.NUM_DOCFIS
          AND    DOC_FIS.SERIE_DOCFIS                = DWT_MERC.SERIE_DOCFIS
          AND    DOC_FIS.SUB_SERIE_DOCFIS            = DWT_MERC.SUB_SERIE_DOCFIS
          AND    DOC_FIS.IDENT_MODELO                = X2024.IDENT_MODELO
          AND    X2024.COD_MODELO                   IN ('07', '67')
          AND    DWT_MERC.IDENT_PROC_ADJ_PRINC       = X2058.IDENT_PROC_ADJ(+)
          AND    DWT_MERC.IDENT_PROC_ADJ_ADIC        = X2058_ADIC.IDENT_PROC_ADJ(+)
          AND    ID_TIPO_SERV.COD_EMPRESA            = DOC_FIS.COD_EMPRESA
          AND    ID_TIPO_SERV.COD_ESTAB              = DOC_FIS.COD_ESTAB
       
          AND    DWT_MERC.IDENT_PRODUTO              = X2013.IDENT_PRODUTO                
          AND    ID_TIPO_SERV.GRUPO_PRODUTO          = X2013.GRUPO_PRODUTO
          AND    ID_TIPO_SERV.COD_PRODUTO            = X2013.COD_PRODUTO
          AND    ID_TIPO_SERV.IND_PRODUTO            = X2013.IND_PRODUTO                
          AND    ID_TIPO_SERV.COD_TIPO_SERV_ESOCIAL  = TIPO_SERV.COD_TIPO_SERV_ESOCIAL
          AND    TIPO_SERV.DATA_INI_VIGENCIA         = (SELECT MAX(A.DATA_INI_VIGENCIA)
                                                        FROM   PRT_TIPO_SERV_ESOCIAL A
                                                        WHERE  A.COD_TIPO_SERV_ESOCIAL =
                                                               TIPO_SERV.COD_TIPO_SERV_ESOCIAL 
                                                        AND    A.DATA_INI_VIGENCIA <= P_DATA_FINAL)                
          AND    DOC_FIS.DAT_CANCELAMENTO           IS NULL
          AND    DOC_FIS.COD_CLASS_DOC_FIS          IN ('1', '3')
          AND    DOC_FIS.NORM_DEV                    = '1'
        
          AND  ((DOC_FIS.MOVTO_E_S < '9' AND P_ENTRADA_SAIDA = 'E') OR (DOC_FIS.MOVTO_E_S = '9' AND P_ENTRADA_SAIDA = 'S'))  
          AND    NVL(DWT_MERC.VLR_INSS_RETIDO, 0)    > 0
          AND    DOC_FIS.SITUACAO = 'N'
          AND    DOC_FIS.COD_EMPRESA                 = P_COD_EMPRESA
          AND    DOC_FIS.COD_ESTAB                   = P_COD_ESTAB
          AND    DOC_FIS.DATA_EMISSAO               >= P_DATA_INICIAL
          AND    DOC_FIS.DATA_EMISSAO               <= P_DATA_FINAL;
          
      
      
      
       
  
  CURSOR C_CONF_SEM_TIPO_SERV ( P_COD_EMPRESA VARCHAR2, 
                          P_COD_ESTAB VARCHAR2,
                          P_DATA_INICIAL  DATE,
                          P_DATA_FINAL  DATE) IS   
                    
          SELECT DOC_FIS.DATA_EMISSAO,
                 DOC_FIS.DATA_FISCAL,
                 DOC_FIS.IDENT_FIS_JUR,
                 DOC_FIS.IDENT_DOCTO,
                 DOC_FIS.NUM_DOCFIS,
                 DOC_FIS.SERIE_DOCFIS,
                 DOC_FIS.SUB_SERIE_DOCFIS,
                 NULL ,
                 DOC_FIS.COD_CLASS_DOC_FIS,
                 DOC_FIS.VLR_TOT_NOTA,
                 DOC_FIS.VLR_CONTAB_COMPL,
                 DWT_ITENS.VLR_BASE_INSS,
                 DWT_ITENS.VLR_ALIQ_INSS,
                 DWT_ITENS.VLR_INSS_RETIDO,
                 X2058.IND_TP_PROC_ADJ,
                 X2058.NUM_PROC_ADJ,
                 DWT_ITENS.NUM_ITEM,
                 DWT_ITENS.VLR_SERVICO, 
                 X2058_ADIC.IND_TP_PROC_ADJ,
                 X2058_ADIC.NUM_PROC_ADJ,
                 DWT_ITENS.IDENT_SERVICO,
                 NULL, 
                 NULL 
            FROM DWT_DOCTO_FISCAL DOC_FIS,
                 DWT_ITENS_SERV   DWT_ITENS,
                 X2058_PROC_ADJ X2058,
                 X2058_PROC_ADJ X2058_ADIC
           WHERE DOC_FIS.COD_EMPRESA            = DWT_ITENS.COD_EMPRESA
             AND DOC_FIS.COD_ESTAB              = DWT_ITENS.COD_ESTAB
             AND DOC_FIS.DATA_FISCAL            = DWT_ITENS.DATA_FISCAL
             AND DOC_FIS.IDENT_FIS_JUR          = DWT_ITENS.IDENT_FIS_JUR
             AND DOC_FIS.IDENT_DOCTO            = DWT_ITENS.IDENT_DOCTO
             AND DOC_FIS.NUM_DOCFIS             = DWT_ITENS.NUM_DOCFIS
             AND DOC_FIS.SERIE_DOCFIS           = DWT_ITENS.SERIE_DOCFIS
             AND DOC_FIS.SUB_SERIE_DOCFIS       = DWT_ITENS.SUB_SERIE_DOCFIS
             AND DWT_ITENS.IDENT_PROC_ADJ_PRINC = X2058.IDENT_PROC_ADJ (+)
             AND DWT_ITENS.IDENT_PROC_ADJ_ADIC  = X2058_ADIC.IDENT_PROC_ADJ (+)
             
             AND NOT EXISTS ( SELECT 1 
                                FROM PRT_ID_TIPO_SERV_ESOCIAL A,
                                     X2018_SERVICOS X2018
                               WHERE A.COD_EMPRESA       = DWT_ITENS.COD_EMPRESA
                                 AND A.COD_ESTAB         = DWT_ITENS.COD_ESTAB
                                 AND X2018.IDENT_SERVICO = DWT_ITENS.IDENT_SERVICO 
                                 AND A.GRUPO_SERVICO     = X2018.GRUPO_SERVICO
                                 AND A.COD_SERVICO       = X2018.COD_SERVICO )
              
              AND NOT EXISTS ( SELECT 1 
                                FROM PRT_SERV_MSAF A,
                                     X2018_SERVICOS X2018
                               WHERE A.COD_EMPRESA       = DWT_ITENS.COD_EMPRESA
                                 AND A.COD_ESTAB         = DWT_ITENS.COD_ESTAB
                                 AND X2018.IDENT_SERVICO = DWT_ITENS.IDENT_SERVICO 
                                 AND A.GRUPO_SERVICO     = X2018.GRUPO_SERVICO
                                 AND A.COD_SERVICO       = X2018.COD_SERVICO
                                 AND A.COD_PARAM IN (683,684,685,686,690) )                 
                                 
             AND DOC_FIS.DAT_CANCELAMENTO  IS NULL
             AND DOC_FIS.COD_CLASS_DOC_FIS IN ('2','3')
             AND DOC_FIS.NORM_DEV  = '1'
           
             AND ((DOC_FIS.MOVTO_E_S < '9' AND P_ENTRADA_SAIDA = 'E') OR (DOC_FIS.MOVTO_E_S = '9' AND P_ENTRADA_SAIDA = 'S'))  
             AND NVL(DWT_ITENS.VLR_INSS_RETIDO,0) > 0 
             AND DOC_FIS.SITUACAO = 'N'
             AND DOC_FIS.COD_EMPRESA  = P_COD_EMPRESA
             AND DOC_FIS.COD_ESTAB    = P_COD_ESTAB
             AND DOC_FIS.DATA_EMISSAO >= P_DATA_INICIAL
             AND DOC_FIS.DATA_EMISSAO <= P_DATA_FINAL
             
         UNION ALL SELECT DOC_FIS.DATA_EMISSAO,
                 DOC_FIS.DATA_FISCAL,
                 DOC_FIS.IDENT_FIS_JUR,
                 DOC_FIS.IDENT_DOCTO,
                 DOC_FIS.NUM_DOCFIS,
                 DOC_FIS.SERIE_DOCFIS,
                 DOC_FIS.SUB_SERIE_DOCFIS,
                 NULL,
                 DOC_FIS.COD_CLASS_DOC_FIS,
                 DOC_FIS.VLR_TOT_NOTA,
                 DOC_FIS.VLR_CONTAB_COMPL,
                 DWT_MERC.VLR_BASE_INSS,
                 DWT_MERC.VLR_ALIQ_INSS,
                 DWT_MERC.VLR_INSS_RETIDO,
                 X2058.IND_TP_PROC_ADJ,
                 X2058.NUM_PROC_ADJ,
                 DWT_MERC.NUM_ITEM, 
                 DWT_MERC.VLR_ITEM,
                 X2058_ADIC.IND_TP_PROC_ADJ,
                 X2058_ADIC.NUM_PROC_ADJ,
                 NULL, 
                 DWT_MERC.IDENT_PRODUTO,
                 NULL 
            FROM DWT_DOCTO_FISCAL DOC_FIS,
                 DWT_ITENS_MERC   DWT_MERC,
                 X2058_PROC_ADJ X2058,
                 X2058_PROC_ADJ X2058_ADIC,
                 X2024_MODELO_DOCTO X2024
           WHERE DOC_FIS.COD_EMPRESA        = DWT_MERC.COD_EMPRESA
             AND DOC_FIS.COD_ESTAB          = DWT_MERC.COD_ESTAB
             AND DOC_FIS.DATA_FISCAL        = DWT_MERC.DATA_FISCAL
             AND DOC_FIS.IDENT_FIS_JUR      = DWT_MERC.IDENT_FIS_JUR
             AND DOC_FIS.IDENT_DOCTO        = DWT_MERC.IDENT_DOCTO
             AND DOC_FIS.NUM_DOCFIS         = DWT_MERC.NUM_DOCFIS
             AND DOC_FIS.SERIE_DOCFIS       = DWT_MERC.SERIE_DOCFIS
             AND DOC_FIS.SUB_SERIE_DOCFIS   = DWT_MERC.SUB_SERIE_DOCFIS
             AND DOC_FIS.IDENT_MODELO       = X2024.IDENT_MODELO
             AND X2024.COD_MODELO IN ('07','67')
             AND DWT_MERC.IDENT_PROC_ADJ_PRINC = X2058.IDENT_PROC_ADJ (+)
             AND DWT_MERC.IDENT_PROC_ADJ_ADIC  = X2058_ADIC.IDENT_PROC_ADJ (+)
             AND NOT EXISTS ( SELECT 1 
                                FROM PRT_ID_TIPO_SERV_PROD P,
                                     X2013_PRODUTO X2013
                               WHERE P.COD_EMPRESA       = DWT_MERC.COD_EMPRESA
                                 AND P.COD_ESTAB         = DWT_MERC.COD_ESTAB
                                 AND X2013.IDENT_PRODUTO = DWT_MERC.IDENT_PRODUTO
                                 AND P.GRUPO_PRODUTO     = X2013.GRUPO_PRODUTO
                                 AND P.COD_PRODUTO       = X2013.COD_PRODUTO
                                 AND P.IND_PRODUTO       = X2013.IND_PRODUTO )
             AND DOC_FIS.DAT_CANCELAMENTO  IS NULL
             AND DOC_FIS.COD_CLASS_DOC_FIS IN ('1','3')
             AND DOC_FIS.NORM_DEV  = '1'
           
             AND ((DOC_FIS.MOVTO_E_S < '9' AND P_ENTRADA_SAIDA = 'E') OR (DOC_FIS.MOVTO_E_S = '9' AND P_ENTRADA_SAIDA = 'S'))  
             AND NVL(DWT_MERC.VLR_INSS_RETIDO,0) > 0 
             AND DOC_FIS.SITUACAO = 'N'
             AND DOC_FIS.COD_EMPRESA = P_COD_EMPRESA
             AND DOC_FIS.COD_ESTAB   = P_COD_ESTAB
             AND DOC_FIS.DATA_EMISSAO >= P_DATA_INICIAL
             AND DOC_FIS.DATA_EMISSAO <= P_DATA_FINAL;     
             


  CURSOR C_CONF_RET_PREV_PROC ( P_COD_EMPRESA VARCHAR2, 
                                P_COD_ESTAB VARCHAR2,
                                P_DATA_INICIAL  DATE,
                                P_DATA_FINAL  DATE) IS   
                    
          SELECT DISTINCT DOC_FIS.DATA_EMISSAO,
                 DOC_FIS.DATA_FISCAL,
                 DOC_FIS.IDENT_FIS_JUR,
                 DOC_FIS.IDENT_DOCTO,
                 DOC_FIS.NUM_DOCFIS,
                 DOC_FIS.SERIE_DOCFIS,
                 DOC_FIS.SUB_SERIE_DOCFIS,
                 NULL, 
                 DOC_FIS.COD_CLASS_DOC_FIS,
                 DOC_FIS.VLR_TOT_NOTA,
                 DOC_FIS.VLR_CONTAB_COMPL,
                 DWT_ITENS.VLR_BASE_INSS,
                 DWT_ITENS.VLR_ALIQ_INSS,
                 DWT_ITENS.VLR_INSS_RETIDO,
                 X2058.IND_TP_PROC_ADJ,
                 X2058.NUM_PROC_ADJ,
                 DWT_ITENS.NUM_ITEM,
                 DWT_ITENS.VLR_SERVICO,
                 X2058_ADIC.IND_TP_PROC_ADJ,
                 X2058_ADIC.NUM_PROC_ADJ,
                 DWT_ITENS.IDENT_SERVICO,
                 NULL, 
                 NULL 
            FROM DWT_DOCTO_FISCAL DOC_FIS,
                 DWT_ITENS_SERV   DWT_ITENS,
                 X2018_SERVICOS   X2018,
                 X2018_SERVICOS   X2018_ADIC,
                 
                 X2058_PROC_ADJ X2058,
                 X2058_PROC_ADJ X2058_ADIC
           WHERE DOC_FIS.COD_EMPRESA        = DWT_ITENS.COD_EMPRESA
             AND DOC_FIS.COD_ESTAB          = DWT_ITENS.COD_ESTAB
             AND DOC_FIS.DATA_FISCAL        = DWT_ITENS.DATA_FISCAL
             AND DOC_FIS.IDENT_FIS_JUR      = DWT_ITENS.IDENT_FIS_JUR
             AND DOC_FIS.IDENT_DOCTO        = DWT_ITENS.IDENT_DOCTO
             AND DOC_FIS.NUM_DOCFIS         = DWT_ITENS.NUM_DOCFIS
             AND DOC_FIS.SERIE_DOCFIS       = DWT_ITENS.SERIE_DOCFIS
             AND DOC_FIS.SUB_SERIE_DOCFIS   = DWT_ITENS.SUB_SERIE_DOCFIS
             AND DWT_ITENS.IDENT_PROC_ADJ_PRINC = X2058.IDENT_PROC_ADJ (+)
             AND DWT_ITENS.IDENT_PROC_ADJ_ADIC  = X2058_ADIC.IDENT_PROC_ADJ (+)
             
           

             AND DWT_ITENS.IDENT_SERVICO    = X2018.IDENT_SERVICO
            

             
             AND DOC_FIS.DAT_CANCELAMENTO  IS NULL
             AND DOC_FIS.COD_CLASS_DOC_FIS IN ('2','3')
             AND DOC_FIS.NORM_DEV  = '1'
           
             AND ((DOC_FIS.MOVTO_E_S < '9' AND P_ENTRADA_SAIDA = 'E') OR (DOC_FIS.MOVTO_E_S = '9' AND P_ENTRADA_SAIDA = 'S'))  
             
             AND (X2058.NUM_PROC_ADJ IS NOT NULL OR  X2058_ADIC.NUM_PROC_ADJ IS NOT NULL)
             AND NVL(DWT_ITENS.VLR_INSS_RETIDO, 0) > 0 
             AND DOC_FIS.SITUACAO = 'N'
             AND DOC_FIS.COD_EMPRESA = P_COD_EMPRESA
             AND DOC_FIS.COD_ESTAB   = P_COD_ESTAB
             AND DOC_FIS.DATA_EMISSAO >= P_DATA_INICIAL
             AND DOC_FIS.DATA_EMISSAO <= P_DATA_FINAL     
             
     UNION ALL SELECT DOC_FIS.DATA_EMISSAO,
                 DOC_FIS.DATA_FISCAL,
                 DOC_FIS.IDENT_FIS_JUR,
                 DOC_FIS.IDENT_DOCTO,
                 DOC_FIS.NUM_DOCFIS,
                 DOC_FIS.SERIE_DOCFIS,
                 DOC_FIS.SUB_SERIE_DOCFIS,
                 NULL, 
                 DOC_FIS.COD_CLASS_DOC_FIS,
                 DOC_FIS.VLR_TOT_NOTA,
                 DOC_FIS.VLR_CONTAB_COMPL,
                 DWT_MERC.VLR_BASE_INSS,
                 DWT_MERC.VLR_ALIQ_INSS,
                 DWT_MERC.VLR_INSS_RETIDO,
                 X2058.IND_TP_PROC_ADJ,
                 X2058.NUM_PROC_ADJ,
                 DWT_MERC.NUM_ITEM, 
                 DWT_MERC.VLR_ITEM,
                 X2058_ADIC.IND_TP_PROC_ADJ,
                 X2058_ADIC.NUM_PROC_ADJ,
                 NULL,
                 DWT_MERC.IDENT_PRODUTO,
                 NULL 
            FROM DWT_DOCTO_FISCAL DOC_FIS,
                 DWT_ITENS_MERC   DWT_MERC,
                 X2013_PRODUTO   X2013,
                
                 X2058_PROC_ADJ X2058,
                 X2058_PROC_ADJ X2058_ADIC,
                 X2024_MODELO_DOCTO X2024
           WHERE DOC_FIS.COD_EMPRESA        = DWT_MERC.COD_EMPRESA
             AND DOC_FIS.COD_ESTAB          = DWT_MERC.COD_ESTAB
             AND DOC_FIS.DATA_FISCAL        = DWT_MERC.DATA_FISCAL
             AND DOC_FIS.IDENT_FIS_JUR      = DWT_MERC.IDENT_FIS_JUR
             AND DOC_FIS.IDENT_DOCTO        = DWT_MERC.IDENT_DOCTO
             AND DOC_FIS.NUM_DOCFIS         = DWT_MERC.NUM_DOCFIS
             AND DOC_FIS.SERIE_DOCFIS       = DWT_MERC.SERIE_DOCFIS
             AND DOC_FIS.SUB_SERIE_DOCFIS   = DWT_MERC.SUB_SERIE_DOCFIS
             AND DOC_FIS.IDENT_MODELO       = X2024.IDENT_MODELO
             AND X2024.COD_MODELO IN ('07','67')
             AND DWT_MERC.IDENT_PROC_ADJ_PRINC = X2058.IDENT_PROC_ADJ (+)
             AND  DWT_MERC.IDENT_PROC_ADJ_ADIC  = X2058_ADIC.IDENT_PROC_ADJ (+)
             AND DWT_MERC.IDENT_PRODUTO    = X2013.IDENT_PRODUTO
            




             AND DOC_FIS.DAT_CANCELAMENTO  IS NULL
             AND DOC_FIS.COD_CLASS_DOC_FIS IN ('1','3')
             AND DOC_FIS.NORM_DEV  = '1'
           
             AND ((DOC_FIS.MOVTO_E_S < '9' AND P_ENTRADA_SAIDA = 'E') OR (DOC_FIS.MOVTO_E_S = '9' AND P_ENTRADA_SAIDA = 'S'))  
             AND (X2058.NUM_PROC_ADJ IS NOT NULL OR  X2058_ADIC.NUM_PROC_ADJ IS NOT NULL)
             AND NVL(DWT_MERC.VLR_INSS_RETIDO,0) > 0 
             AND DOC_FIS.SITUACAO = 'N'
             AND DOC_FIS.COD_EMPRESA = P_COD_EMPRESA
             AND DOC_FIS.COD_ESTAB   = P_COD_ESTAB
             AND DOC_FIS.DATA_EMISSAO >= P_DATA_INICIAL
             AND DOC_FIS.DATA_EMISSAO <= P_DATA_FINAL; 
             
             
                       

  CURSOR C_CONF_RET_PREV_SEM_PROC ( P_COD_EMPRESA VARCHAR2, 
                                    P_COD_ESTAB VARCHAR2,
                                    P_DATA_INICIAL  DATE,
                                    P_DATA_FINAL  DATE) IS   
                    
          SELECT DOC_FIS.DATA_EMISSAO,
                 DOC_FIS.DATA_FISCAL,
                 DOC_FIS.IDENT_FIS_JUR,
                 DOC_FIS.IDENT_DOCTO,
                 DOC_FIS.NUM_DOCFIS,
                 DOC_FIS.SERIE_DOCFIS,
                 DOC_FIS.SUB_SERIE_DOCFIS,
                 NULL, 
                 DOC_FIS.COD_CLASS_DOC_FIS,
                 DOC_FIS.VLR_TOT_NOTA,
                 DOC_FIS.VLR_CONTAB_COMPL,
                 DWT_ITENS.VLR_BASE_INSS,
                 DWT_ITENS.VLR_ALIQ_INSS,
                 DWT_ITENS.VLR_INSS_RETIDO,
                 DWT_ITENS.IND_TP_PROC_ADJ_PRINC,
                 NULL, 
                 DWT_ITENS.NUM_ITEM,
                 DWT_ITENS.VLR_SERVICO,
                 DWT_ITENS.IND_TP_PROC_ADJ_PRINC,
                 NULL, 
                 DWT_ITENS.IDENT_SERVICO,
                 NULL,  
                 NULL 
            FROM DWT_DOCTO_FISCAL DOC_FIS,
                 DWT_ITENS_SERV   DWT_ITENS,
                 X2018_SERVICOS   X2018

                 
           WHERE DOC_FIS.COD_EMPRESA        = DWT_ITENS.COD_EMPRESA
             AND DOC_FIS.COD_ESTAB          = DWT_ITENS.COD_ESTAB
             AND DOC_FIS.DATA_FISCAL        = DWT_ITENS.DATA_FISCAL
             AND DOC_FIS.IDENT_FIS_JUR      = DWT_ITENS.IDENT_FIS_JUR
             AND DOC_FIS.IDENT_DOCTO        = DWT_ITENS.IDENT_DOCTO
             AND DOC_FIS.NUM_DOCFIS         = DWT_ITENS.NUM_DOCFIS
             AND DOC_FIS.SERIE_DOCFIS       = DWT_ITENS.SERIE_DOCFIS
             AND DOC_FIS.SUB_SERIE_DOCFIS   = DWT_ITENS.SUB_SERIE_DOCFIS
             
            

             AND DWT_ITENS.IDENT_SERVICO    = X2018.IDENT_SERVICO
             

           
             AND DOC_FIS.DAT_CANCELAMENTO  IS NULL
             AND DOC_FIS.COD_CLASS_DOC_FIS IN ('2','3')
             AND DOC_FIS.NORM_DEV  = '1'
           
             AND ((DOC_FIS.MOVTO_E_S < '9' AND P_ENTRADA_SAIDA = 'E') OR (DOC_FIS.MOVTO_E_S = '9' AND P_ENTRADA_SAIDA = 'S'))  
             
             AND DWT_ITENS.IDENT_PROC_ADJ_PRINC IS NULL
             AND NVL(DWT_ITENS.VLR_INSS_RETIDO,0) = 0 
             AND DOC_FIS.SITUACAO = 'N'
             AND DOC_FIS.COD_EMPRESA = P_COD_EMPRESA
             AND DOC_FIS.COD_ESTAB   = P_COD_ESTAB
             AND DOC_FIS.DATA_EMISSAO >= P_DATA_INICIAL
             AND DOC_FIS.DATA_EMISSAO <= P_DATA_FINAL 
      
UNION ALL SELECT DOC_FIS.DATA_EMISSAO,
                 DOC_FIS.DATA_FISCAL,
                 DOC_FIS.IDENT_FIS_JUR,
                 DOC_FIS.IDENT_DOCTO,
                 DOC_FIS.NUM_DOCFIS,
                 DOC_FIS.SERIE_DOCFIS,
                 DOC_FIS.SUB_SERIE_DOCFIS,
                 NULL, 
                 DOC_FIS.COD_CLASS_DOC_FIS,
                 DOC_FIS.VLR_TOT_NOTA,
                 DOC_FIS.VLR_CONTAB_COMPL,
                 DWT_MERC.VLR_BASE_INSS,
                 DWT_MERC.VLR_ALIQ_INSS,
                 DWT_MERC.VLR_INSS_RETIDO,
                 DWT_MERC.IND_TP_PROC_ADJ_PRINC,
                 NULL, 
                 DWT_MERC.NUM_ITEM, 
                 DWT_MERC.VLR_ITEM,
                 DWT_MERC.IND_TP_PROC_ADJ_PRINC,
                 NULL, 
                 NULL, 
                 DWT_MERC.IDENT_PRODUTO,
                 NULL 
            FROM DWT_DOCTO_FISCAL DOC_FIS,
                 DWT_ITENS_MERC   DWT_MERC,
                 X2013_PRODUTO   X2013,
                
                 X2024_MODELO_DOCTO X2024
                 
           WHERE DOC_FIS.COD_EMPRESA        = DWT_MERC.COD_EMPRESA
             AND DOC_FIS.COD_ESTAB          = DWT_MERC.COD_ESTAB
             AND DOC_FIS.DATA_FISCAL        = DWT_MERC.DATA_FISCAL
             AND DOC_FIS.IDENT_FIS_JUR      = DWT_MERC.IDENT_FIS_JUR
             AND DOC_FIS.IDENT_DOCTO        = DWT_MERC.IDENT_DOCTO
             AND DOC_FIS.NUM_DOCFIS         = DWT_MERC.NUM_DOCFIS
             AND DOC_FIS.SERIE_DOCFIS       = DWT_MERC.SERIE_DOCFIS
             AND DOC_FIS.SUB_SERIE_DOCFIS   = DWT_MERC.SUB_SERIE_DOCFIS
             AND DOC_FIS.IDENT_MODELO       = X2024.IDENT_MODELO
             AND X2024.COD_MODELO IN ('07','67')
             
   

             AND DWT_MERC.IDENT_PRODUTO    = X2013.IDENT_PRODUTO
         


             
             




             
             
             AND DOC_FIS.DAT_CANCELAMENTO  IS NULL
             AND DOC_FIS.COD_CLASS_DOC_FIS IN ('1','3')
             AND DOC_FIS.NORM_DEV  = '1'
           
             AND ((DOC_FIS.MOVTO_E_S < '9' AND P_ENTRADA_SAIDA = 'E') OR (DOC_FIS.MOVTO_E_S = '9' AND P_ENTRADA_SAIDA = 'S'))  
             AND DWT_MERC.IDENT_PROC_ADJ_PRINC IS NULL
             AND NVL(DWT_MERC.VLR_INSS_RETIDO,0) = 0 
             AND DOC_FIS.SITUACAO = 'N'
             AND DOC_FIS.COD_EMPRESA = P_COD_EMPRESA
             AND DOC_FIS.COD_ESTAB   = P_COD_ESTAB
             AND DOC_FIS.DATA_EMISSAO >= P_DATA_INICIAL
             AND DOC_FIS.DATA_EMISSAO <= P_DATA_FINAL;             
             
   
   
   CURSOR C_CONF_INSS_MAIOR_BRUTO (P_COD_EMPRESA VARCHAR2, 
                           P_COD_ESTAB VARCHAR2,
                           P_DATA_INICIAL  DATE,
                           P_DATA_FINAL  DATE) IS
          
          SELECT DOC_FIS.DATA_EMISSAO
                ,DOC_FIS.DATA_FISCAL
                ,DOC_FIS.IDENT_FIS_JUR
                ,DOC_FIS.IDENT_DOCTO
                ,DOC_FIS.NUM_DOCFIS
                ,DOC_FIS.SERIE_DOCFIS
                ,DOC_FIS.SUB_SERIE_DOCFIS
                ,TIPO_SERV.IDENT_TIPO_SERV_ESOCIAL
                ,DOC_FIS.COD_CLASS_DOC_FIS
                ,DOC_FIS.VLR_TOT_NOTA
                ,DOC_FIS.VLR_CONTAB_COMPL
                ,DWT_ITENS.VLR_BASE_INSS
                ,DWT_ITENS.VLR_ALIQ_INSS
                ,DWT_ITENS.VLR_INSS_RETIDO
                ,X2058.IND_TP_PROC_ADJ
                ,X2058.NUM_PROC_ADJ
                ,DWT_ITENS.NUM_ITEM
                ,DWT_ITENS.VLR_SERVICO
                ,X2058_ADIC.IND_TP_PROC_ADJ
                ,X2058_ADIC.NUM_PROC_ADJ
                ,DWT_ITENS.IDENT_SERVICO
                , NULL 
                , NULL 
          FROM   DWT_DOCTO_FISCAL         DOC_FIS
                ,DWT_ITENS_SERV           DWT_ITENS
                ,X2018_SERVICOS           X2018
                ,PRT_ID_TIPO_SERV_ESOCIAL ID_TIPO_SERV
                ,PRT_TIPO_SERV_ESOCIAL    TIPO_SERV
                ,X2058_PROC_ADJ           X2058
                ,X2058_PROC_ADJ           X2058_ADIC
          WHERE  DOC_FIS.COD_EMPRESA                =  DWT_ITENS.COD_EMPRESA
          AND    DOC_FIS.COD_ESTAB                  =  DWT_ITENS.COD_ESTAB
          AND    DOC_FIS.DATA_FISCAL                =  DWT_ITENS.DATA_FISCAL
          AND    DOC_FIS.IDENT_FIS_JUR              =  DWT_ITENS.IDENT_FIS_JUR
          AND    DOC_FIS.IDENT_DOCTO                =  DWT_ITENS.IDENT_DOCTO
          AND    DOC_FIS.NUM_DOCFIS                 =  DWT_ITENS.NUM_DOCFIS
          AND    DOC_FIS.SERIE_DOCFIS               =  DWT_ITENS.SERIE_DOCFIS
          AND    DOC_FIS.SUB_SERIE_DOCFIS           =  DWT_ITENS.SUB_SERIE_DOCFIS
          AND    DWT_ITENS.IDENT_PROC_ADJ_PRINC     =  X2058.IDENT_PROC_ADJ(+)
          AND    DWT_ITENS.IDENT_PROC_ADJ_ADIC      =  X2058_ADIC.IDENT_PROC_ADJ(+)
          AND    ID_TIPO_SERV.COD_EMPRESA           =  DOC_FIS.COD_EMPRESA
          AND    ID_TIPO_SERV.COD_ESTAB             =  DOC_FIS.COD_ESTAB
          AND    DWT_ITENS.IDENT_SERVICO            =  X2018.IDENT_SERVICO
          AND    X2018.GRUPO_SERVICO                =  ID_TIPO_SERV.GRUPO_SERVICO
          AND    X2018.COD_SERVICO                  =  ID_TIPO_SERV.COD_SERVICO
          AND    ID_TIPO_SERV.COD_TIPO_SERV_ESOCIAL =  TIPO_SERV.COD_TIPO_SERV_ESOCIAL
          AND    TIPO_SERV.DATA_INI_VIGENCIA        =  (SELECT MAX(A.DATA_INI_VIGENCIA)
                                                        FROM   PRT_TIPO_SERV_ESOCIAL A
                                                        WHERE  A.COD_TIPO_SERV_ESOCIAL  = TIPO_SERV.COD_TIPO_SERV_ESOCIAL
                                                        AND    A.DATA_INI_VIGENCIA     <= P_DATA_FINAL)
          AND    DOC_FIS.DAT_CANCELAMENTO           IS NULL
          AND    DOC_FIS.COD_CLASS_DOC_FIS          IN ('2', '3')
          AND    DOC_FIS.NORM_DEV                    =  '1'
        
          AND  ((DOC_FIS.MOVTO_E_S < '9' AND P_ENTRADA_SAIDA = 'E') OR (DOC_FIS.MOVTO_E_S = '9' AND P_ENTRADA_SAIDA = 'S'))         
          AND    NVL(DWT_ITENS.VLR_INSS_RETIDO, 0)   >  0
          AND    DOC_FIS.SITUACAO = 'N'          
          AND    DWT_ITENS.VLR_BASE_INSS >  DOC_FIS.VLR_TOT_NOTA  
          AND    DOC_FIS.COD_EMPRESA                 =  P_COD_EMPRESA
          AND    DOC_FIS.COD_ESTAB                   =  P_COD_ESTAB
          AND    DOC_FIS.DATA_EMISSAO               >= P_DATA_INICIAL
          AND    DOC_FIS.DATA_EMISSAO               <= P_DATA_FINAL
          
          UNION ALL
          SELECT DOC_FIS.DATA_EMISSAO
                ,DOC_FIS.DATA_FISCAL
                ,DOC_FIS.IDENT_FIS_JUR
                ,DOC_FIS.IDENT_DOCTO
                ,DOC_FIS.NUM_DOCFIS
                ,DOC_FIS.SERIE_DOCFIS
                ,DOC_FIS.SUB_SERIE_DOCFIS
                ,NULL 
                ,DOC_FIS.COD_CLASS_DOC_FIS
                ,DOC_FIS.VLR_TOT_NOTA
                ,DOC_FIS.VLR_CONTAB_COMPL
                ,DWT_ITENS.VLR_BASE_INSS
                ,DWT_ITENS.VLR_ALIQ_INSS
                ,DWT_ITENS.VLR_INSS_RETIDO
                ,X2058.IND_TP_PROC_ADJ
                ,X2058.NUM_PROC_ADJ
                ,DWT_ITENS.NUM_ITEM
                ,DWT_ITENS.VLR_SERVICO
                ,X2058_ADIC.IND_TP_PROC_ADJ
                ,X2058_ADIC.NUM_PROC_ADJ
                ,DWT_ITENS.IDENT_SERVICO
                ,NULL 
                ,PRT_PAR2_MSAF.COD_PARAM 
          FROM   DWT_DOCTO_FISCAL         DOC_FIS
                ,DWT_ITENS_SERV           DWT_ITENS
                ,X2018_SERVICOS           X2018
                ,PRT_SERV_MSAF
                ,PRT_PAR2_MSAF
                ,X2058_PROC_ADJ           X2058
                ,X2058_PROC_ADJ           X2058_ADIC
          WHERE  DOC_FIS.COD_EMPRESA                =  DWT_ITENS.COD_EMPRESA
          AND    DOC_FIS.COD_ESTAB                  =  DWT_ITENS.COD_ESTAB
          AND    DOC_FIS.DATA_FISCAL                =  DWT_ITENS.DATA_FISCAL
          AND    DOC_FIS.IDENT_FIS_JUR              =  DWT_ITENS.IDENT_FIS_JUR
          AND    DOC_FIS.IDENT_DOCTO                =  DWT_ITENS.IDENT_DOCTO
          AND    DOC_FIS.NUM_DOCFIS                 =  DWT_ITENS.NUM_DOCFIS
          AND    DOC_FIS.SERIE_DOCFIS               =  DWT_ITENS.SERIE_DOCFIS
          AND    DOC_FIS.SUB_SERIE_DOCFIS           =  DWT_ITENS.SUB_SERIE_DOCFIS
          AND    DWT_ITENS.IDENT_PROC_ADJ_PRINC     =  X2058.IDENT_PROC_ADJ(+)
          AND    DWT_ITENS.IDENT_PROC_ADJ_ADIC      =  X2058_ADIC.IDENT_PROC_ADJ(+)
          
          
          AND    PRT_SERV_MSAF.COD_EMPRESA           =  DOC_FIS.COD_EMPRESA
          AND    PRT_SERV_MSAF.COD_ESTAB             =  DOC_FIS.COD_ESTAB
          AND    DWT_ITENS.IDENT_SERVICO            =  X2018.IDENT_SERVICO
          AND    X2018.GRUPO_SERVICO                =  PRT_SERV_MSAF.GRUPO_SERVICO
          AND    X2018.COD_SERVICO                  =  PRT_SERV_MSAF.COD_SERVICO
          AND    PRT_SERV_MSAF.COD_PARAM            =  PRT_PAR2_MSAF.COD_PARAM
          AND    PRT_SERV_MSAF.COD_PARAM IN (683,684,685,686,690)
          
                                                        
          AND    DOC_FIS.DAT_CANCELAMENTO           IS NULL
          AND    DOC_FIS.COD_CLASS_DOC_FIS          IN ('2', '3')
          AND    DOC_FIS.NORM_DEV                    =  '1'
        
          AND  ((DOC_FIS.MOVTO_E_S < '9' AND P_ENTRADA_SAIDA = 'E') OR (DOC_FIS.MOVTO_E_S = '9' AND P_ENTRADA_SAIDA = 'S'))         
          AND    NVL(DWT_ITENS.VLR_INSS_RETIDO, 0)   >  0
          AND    DOC_FIS.SITUACAO = 'N'          
          AND    DWT_ITENS.VLR_BASE_INSS >  DOC_FIS.VLR_TOT_NOTA  
          AND    DOC_FIS.COD_EMPRESA                 =  P_COD_EMPRESA
          AND    DOC_FIS.COD_ESTAB                   =  P_COD_ESTAB
          AND    DOC_FIS.DATA_EMISSAO               >= P_DATA_INICIAL
          AND    DOC_FIS.DATA_EMISSAO               <= P_DATA_FINAL
          
          UNION  ALL 
          SELECT DOC_FIS.DATA_EMISSAO
                ,DOC_FIS.DATA_FISCAL
                ,DOC_FIS.IDENT_FIS_JUR
                ,DOC_FIS.IDENT_DOCTO
                ,DOC_FIS.NUM_DOCFIS
                ,DOC_FIS.SERIE_DOCFIS
                ,DOC_FIS.SUB_SERIE_DOCFIS
                ,TIPO_SERV.IDENT_TIPO_SERV_ESOCIAL
                ,DOC_FIS.COD_CLASS_DOC_FIS
                ,DOC_FIS.VLR_TOT_NOTA
                ,DOC_FIS.VLR_CONTAB_COMPL
                ,DWT_MERC.VLR_BASE_INSS
                ,DWT_MERC.VLR_ALIQ_INSS
                ,DWT_MERC.VLR_INSS_RETIDO
                ,X2058.IND_TP_PROC_ADJ
                ,X2058.NUM_PROC_ADJ
                ,DWT_MERC.NUM_ITEM
                ,DWT_MERC.VLR_ITEM
                ,X2058_ADIC.IND_TP_PROC_ADJ
                ,X2058_ADIC.NUM_PROC_ADJ
                ,NULL 
                ,DWT_MERC.IDENT_PRODUTO
                ,NULL 
          FROM   DWT_DOCTO_FISCAL      DOC_FIS
                ,DWT_ITENS_MERC        DWT_MERC
                ,X2013_PRODUTO         X2013
                ,PRT_ID_TIPO_SERV_PROD ID_TIPO_SERV
                ,PRT_TIPO_SERV_ESOCIAL TIPO_SERV
                ,X2058_PROC_ADJ        X2058
                ,X2058_PROC_ADJ        X2058_ADIC
                ,X2024_MODELO_DOCTO    X2024
          WHERE  DOC_FIS.COD_EMPRESA                 = DWT_MERC.COD_EMPRESA
          AND    DOC_FIS.COD_ESTAB                   = DWT_MERC.COD_ESTAB
          AND    DOC_FIS.DATA_FISCAL                 = DWT_MERC.DATA_FISCAL
          AND    DOC_FIS.IDENT_FIS_JUR               = DWT_MERC.IDENT_FIS_JUR
          AND    DOC_FIS.IDENT_DOCTO                 = DWT_MERC.IDENT_DOCTO
          AND    DOC_FIS.NUM_DOCFIS                  = DWT_MERC.NUM_DOCFIS
          AND    DOC_FIS.SERIE_DOCFIS                = DWT_MERC.SERIE_DOCFIS
          AND    DOC_FIS.SUB_SERIE_DOCFIS            = DWT_MERC.SUB_SERIE_DOCFIS
          AND    DOC_FIS.IDENT_MODELO                = X2024.IDENT_MODELO
          AND    X2024.COD_MODELO                   IN ('07', '67')
          AND    DWT_MERC.IDENT_PROC_ADJ_PRINC       = X2058.IDENT_PROC_ADJ(+)
          AND    DWT_MERC.IDENT_PROC_ADJ_ADIC        = X2058_ADIC.IDENT_PROC_ADJ(+)
          AND    ID_TIPO_SERV.COD_EMPRESA            = DOC_FIS.COD_EMPRESA
          AND    ID_TIPO_SERV.COD_ESTAB              = DOC_FIS.COD_ESTAB
          AND    DWT_MERC.IDENT_PRODUTO              = X2013.IDENT_PRODUTO                
          AND    ID_TIPO_SERV.GRUPO_PRODUTO          = X2013.GRUPO_PRODUTO
          AND    ID_TIPO_SERV.COD_PRODUTO            = X2013.COD_PRODUTO
          AND    ID_TIPO_SERV.IND_PRODUTO            = X2013.IND_PRODUTO                
          AND    ID_TIPO_SERV.COD_TIPO_SERV_ESOCIAL  = TIPO_SERV.COD_TIPO_SERV_ESOCIAL
          AND    TIPO_SERV.DATA_INI_VIGENCIA         = (SELECT MAX(A.DATA_INI_VIGENCIA)
                                                        FROM   PRT_TIPO_SERV_ESOCIAL A
                                                        WHERE  A.COD_TIPO_SERV_ESOCIAL =
                                                               TIPO_SERV.COD_TIPO_SERV_ESOCIAL 
                                                        AND    A.DATA_INI_VIGENCIA <= P_DATA_FINAL)                
          AND    DOC_FIS.DAT_CANCELAMENTO           IS NULL
          AND    DOC_FIS.COD_CLASS_DOC_FIS          IN ('1', '3')
          AND    DOC_FIS.NORM_DEV                    = '1'
        
          AND  ((DOC_FIS.MOVTO_E_S < '9' AND P_ENTRADA_SAIDA = 'E') OR (DOC_FIS.MOVTO_E_S = '9' AND P_ENTRADA_SAIDA = 'S'))  
          AND    NVL(DWT_MERC.VLR_INSS_RETIDO, 0)    > 0
          AND    DOC_FIS.SITUACAO = 'N'
          AND    DWT_MERC.VLR_BASE_INSS >  DOC_FIS.VLR_TOT_NOTA  
          AND    DOC_FIS.COD_EMPRESA                 = P_COD_EMPRESA
          AND    DOC_FIS.COD_ESTAB                   = P_COD_ESTAB
          AND    DOC_FIS.DATA_EMISSAO               >= P_DATA_INICIAL
          AND    DOC_FIS.DATA_EMISSAO               <= P_DATA_FINAL;
          
          
          
          
   
   CURSOR C_CONF_INSS_ALIQ_DIF_INFORMADO (P_COD_EMPRESA VARCHAR2, 
                           P_COD_ESTAB VARCHAR2,
                           P_DATA_INICIAL  DATE,
                           P_DATA_FINAL  DATE) IS
          SELECT DOC_FIS.DATA_EMISSAO
                ,DOC_FIS.DATA_FISCAL
                ,DOC_FIS.IDENT_FIS_JUR
                ,DOC_FIS.IDENT_DOCTO
                ,DOC_FIS.NUM_DOCFIS
                ,DOC_FIS.SERIE_DOCFIS
                ,DOC_FIS.SUB_SERIE_DOCFIS
                ,TIPO_SERV.IDENT_TIPO_SERV_ESOCIAL
                ,DOC_FIS.COD_CLASS_DOC_FIS
                ,DOC_FIS.VLR_TOT_NOTA
                ,DOC_FIS.VLR_CONTAB_COMPL
                ,DWT_ITENS.VLR_BASE_INSS
                ,DWT_ITENS.VLR_ALIQ_INSS
                ,DWT_ITENS.VLR_INSS_RETIDO
                ,X2058.IND_TP_PROC_ADJ
                ,X2058.NUM_PROC_ADJ
                ,DWT_ITENS.NUM_ITEM
                ,DWT_ITENS.VLR_SERVICO
                ,X2058_ADIC.IND_TP_PROC_ADJ
                ,X2058_ADIC.NUM_PROC_ADJ
                ,DWT_ITENS.IDENT_SERVICO
                , NULL 
                , NULL 
          FROM   DWT_DOCTO_FISCAL         DOC_FIS
                ,DWT_ITENS_SERV           DWT_ITENS
                ,X2018_SERVICOS           X2018
                ,PRT_ID_TIPO_SERV_ESOCIAL ID_TIPO_SERV
                ,PRT_TIPO_SERV_ESOCIAL    TIPO_SERV
                ,X2058_PROC_ADJ           X2058
                ,X2058_PROC_ADJ           X2058_ADIC
          WHERE  DOC_FIS.COD_EMPRESA                =  DWT_ITENS.COD_EMPRESA
          AND    DOC_FIS.COD_ESTAB                  =  DWT_ITENS.COD_ESTAB
          AND    DOC_FIS.DATA_FISCAL                =  DWT_ITENS.DATA_FISCAL
          AND    DOC_FIS.IDENT_FIS_JUR              =  DWT_ITENS.IDENT_FIS_JUR
          AND    DOC_FIS.IDENT_DOCTO                =  DWT_ITENS.IDENT_DOCTO
          AND    DOC_FIS.NUM_DOCFIS                 =  DWT_ITENS.NUM_DOCFIS
          AND    DOC_FIS.SERIE_DOCFIS               =  DWT_ITENS.SERIE_DOCFIS
          AND    DOC_FIS.SUB_SERIE_DOCFIS           =  DWT_ITENS.SUB_SERIE_DOCFIS
          AND    DWT_ITENS.IDENT_PROC_ADJ_PRINC     =  X2058.IDENT_PROC_ADJ(+)
          AND    DWT_ITENS.IDENT_PROC_ADJ_ADIC      =  X2058_ADIC.IDENT_PROC_ADJ(+)
          AND    ID_TIPO_SERV.COD_EMPRESA           =  DOC_FIS.COD_EMPRESA
          AND    ID_TIPO_SERV.COD_ESTAB             =  DOC_FIS.COD_ESTAB
          AND    DWT_ITENS.IDENT_SERVICO            =  X2018.IDENT_SERVICO
          AND    X2018.GRUPO_SERVICO                =  ID_TIPO_SERV.GRUPO_SERVICO
          AND    X2018.COD_SERVICO                  =  ID_TIPO_SERV.COD_SERVICO
          AND    ID_TIPO_SERV.COD_TIPO_SERV_ESOCIAL =  TIPO_SERV.COD_TIPO_SERV_ESOCIAL
          AND    TIPO_SERV.DATA_INI_VIGENCIA        =  (SELECT MAX(A.DATA_INI_VIGENCIA)
                                                        FROM   PRT_TIPO_SERV_ESOCIAL A
                                                        WHERE  A.COD_TIPO_SERV_ESOCIAL  = TIPO_SERV.COD_TIPO_SERV_ESOCIAL
                                                        AND    A.DATA_INI_VIGENCIA     <= P_DATA_FINAL)
          AND    DOC_FIS.DAT_CANCELAMENTO           IS NULL
          AND    DOC_FIS.COD_CLASS_DOC_FIS          IN ('2', '3')
          AND    DOC_FIS.NORM_DEV                    =  '1'
        
          AND  ((DOC_FIS.MOVTO_E_S < '9' AND P_ENTRADA_SAIDA = 'E') OR (DOC_FIS.MOVTO_E_S = '9' AND P_ENTRADA_SAIDA = 'S'))         
          AND    NVL(DWT_ITENS.VLR_INSS_RETIDO, 0)   >  0
          AND    DOC_FIS.SITUACAO = 'N'
          AND    ROUND((DWT_ITENS.VLR_BASE_INSS * DWT_ITENS.VLR_ALIQ_INSS)/100,2) <> DWT_ITENS.VLR_INSS_RETIDO  
          AND    DOC_FIS.COD_EMPRESA                 =  P_COD_EMPRESA
          AND    DOC_FIS.COD_ESTAB                   =  P_COD_ESTAB
          AND    DOC_FIS.DATA_EMISSAO               >= P_DATA_INICIAL
          AND    DOC_FIS.DATA_EMISSAO               <= P_DATA_FINAL
          
          
          UNION ALL
          SELECT DOC_FIS.DATA_EMISSAO
                ,DOC_FIS.DATA_FISCAL
                ,DOC_FIS.IDENT_FIS_JUR
                ,DOC_FIS.IDENT_DOCTO
                ,DOC_FIS.NUM_DOCFIS
                ,DOC_FIS.SERIE_DOCFIS
                ,DOC_FIS.SUB_SERIE_DOCFIS
                ,NULL 
                ,DOC_FIS.COD_CLASS_DOC_FIS
                ,DOC_FIS.VLR_TOT_NOTA
                ,DOC_FIS.VLR_CONTAB_COMPL
                ,DWT_ITENS.VLR_BASE_INSS
                ,DWT_ITENS.VLR_ALIQ_INSS
                ,DWT_ITENS.VLR_INSS_RETIDO
                ,X2058.IND_TP_PROC_ADJ
                ,X2058.NUM_PROC_ADJ
                ,DWT_ITENS.NUM_ITEM
                ,DWT_ITENS.VLR_SERVICO
                ,X2058_ADIC.IND_TP_PROC_ADJ
                ,X2058_ADIC.NUM_PROC_ADJ
                ,DWT_ITENS.IDENT_SERVICO
                , NULL 
                , PRT_PAR2_MSAF.COD_PARAM
          FROM   DWT_DOCTO_FISCAL         DOC_FIS
                ,DWT_ITENS_SERV           DWT_ITENS
                ,X2018_SERVICOS           X2018
                ,PRT_SERV_MSAF
                ,PRT_PAR2_MSAF
                ,X2058_PROC_ADJ           X2058
                ,X2058_PROC_ADJ           X2058_ADIC
          WHERE  DOC_FIS.COD_EMPRESA                =  DWT_ITENS.COD_EMPRESA
          AND    DOC_FIS.COD_ESTAB                  =  DWT_ITENS.COD_ESTAB
          AND    DOC_FIS.DATA_FISCAL                =  DWT_ITENS.DATA_FISCAL
          AND    DOC_FIS.IDENT_FIS_JUR              =  DWT_ITENS.IDENT_FIS_JUR
          AND    DOC_FIS.IDENT_DOCTO                =  DWT_ITENS.IDENT_DOCTO
          AND    DOC_FIS.NUM_DOCFIS                 =  DWT_ITENS.NUM_DOCFIS
          AND    DOC_FIS.SERIE_DOCFIS               =  DWT_ITENS.SERIE_DOCFIS
          AND    DOC_FIS.SUB_SERIE_DOCFIS           =  DWT_ITENS.SUB_SERIE_DOCFIS
          AND    DWT_ITENS.IDENT_PROC_ADJ_PRINC     =  X2058.IDENT_PROC_ADJ(+)
          AND    DWT_ITENS.IDENT_PROC_ADJ_ADIC      =  X2058_ADIC.IDENT_PROC_ADJ(+)
          
          
          AND    PRT_SERV_MSAF.COD_EMPRESA           =  DOC_FIS.COD_EMPRESA
          AND    PRT_SERV_MSAF.COD_ESTAB             =  DOC_FIS.COD_ESTAB
          AND    DWT_ITENS.IDENT_SERVICO            =  X2018.IDENT_SERVICO
          AND    X2018.GRUPO_SERVICO                =  PRT_SERV_MSAF.GRUPO_SERVICO
          AND    X2018.COD_SERVICO                  =  PRT_SERV_MSAF.COD_SERVICO
          AND    PRT_SERV_MSAF.COD_PARAM            =  PRT_PAR2_MSAF.COD_PARAM
          AND    PRT_SERV_MSAF.COD_PARAM IN (683,684,685,686,690)
          
          
          AND    DOC_FIS.DAT_CANCELAMENTO           IS NULL
          AND    DOC_FIS.COD_CLASS_DOC_FIS          IN ('2', '3')
          AND    DOC_FIS.NORM_DEV                    =  '1'
        
          AND  ((DOC_FIS.MOVTO_E_S < '9' AND P_ENTRADA_SAIDA = 'E') OR (DOC_FIS.MOVTO_E_S = '9' AND P_ENTRADA_SAIDA = 'S'))         
          AND    NVL(DWT_ITENS.VLR_INSS_RETIDO, 0)   >  0
          AND    DOC_FIS.SITUACAO = 'N'
          AND    ROUND((DWT_ITENS.VLR_BASE_INSS * DWT_ITENS.VLR_ALIQ_INSS)/100,2) <> DWT_ITENS.VLR_INSS_RETIDO  
          AND    DOC_FIS.COD_EMPRESA                 =  P_COD_EMPRESA
          AND    DOC_FIS.COD_ESTAB                   =  P_COD_ESTAB
          AND    DOC_FIS.DATA_EMISSAO               >= P_DATA_INICIAL
          AND    DOC_FIS.DATA_EMISSAO               <= P_DATA_FINAL
          
          
          
          UNION  ALL 
          SELECT DOC_FIS.DATA_EMISSAO
                ,DOC_FIS.DATA_FISCAL
                ,DOC_FIS.IDENT_FIS_JUR
                ,DOC_FIS.IDENT_DOCTO
                ,DOC_FIS.NUM_DOCFIS
                ,DOC_FIS.SERIE_DOCFIS
                ,DOC_FIS.SUB_SERIE_DOCFIS
                ,TIPO_SERV.IDENT_TIPO_SERV_ESOCIAL
                ,DOC_FIS.COD_CLASS_DOC_FIS
                ,DOC_FIS.VLR_TOT_NOTA
                ,DOC_FIS.VLR_CONTAB_COMPL
                ,DWT_MERC.VLR_BASE_INSS
                ,DWT_MERC.VLR_ALIQ_INSS
                ,DWT_MERC.VLR_INSS_RETIDO
                ,X2058.IND_TP_PROC_ADJ
                ,X2058.NUM_PROC_ADJ
                ,DWT_MERC.NUM_ITEM
                ,DWT_MERC.VLR_ITEM
                ,X2058_ADIC.IND_TP_PROC_ADJ
                ,X2058_ADIC.NUM_PROC_ADJ
                ,NULL 
                ,DWT_MERC.IDENT_PRODUTO
                ,NULL 
          FROM   DWT_DOCTO_FISCAL      DOC_FIS
                ,DWT_ITENS_MERC        DWT_MERC
                ,X2013_PRODUTO         X2013
                ,PRT_ID_TIPO_SERV_PROD ID_TIPO_SERV
                ,PRT_TIPO_SERV_ESOCIAL TIPO_SERV
                ,X2058_PROC_ADJ        X2058
                ,X2058_PROC_ADJ        X2058_ADIC
                ,X2024_MODELO_DOCTO    X2024
          WHERE  DOC_FIS.COD_EMPRESA                 = DWT_MERC.COD_EMPRESA
          AND    DOC_FIS.COD_ESTAB                   = DWT_MERC.COD_ESTAB
          AND    DOC_FIS.DATA_FISCAL                 = DWT_MERC.DATA_FISCAL
          AND    DOC_FIS.IDENT_FIS_JUR               = DWT_MERC.IDENT_FIS_JUR
          AND    DOC_FIS.IDENT_DOCTO                 = DWT_MERC.IDENT_DOCTO
          AND    DOC_FIS.NUM_DOCFIS                  = DWT_MERC.NUM_DOCFIS
          AND    DOC_FIS.SERIE_DOCFIS                = DWT_MERC.SERIE_DOCFIS
          AND    DOC_FIS.SUB_SERIE_DOCFIS            = DWT_MERC.SUB_SERIE_DOCFIS
          AND    DOC_FIS.IDENT_MODELO                = X2024.IDENT_MODELO
          AND    X2024.COD_MODELO                   IN ('07', '67')
          AND    DWT_MERC.IDENT_PROC_ADJ_PRINC       = X2058.IDENT_PROC_ADJ(+)
          AND    DWT_MERC.IDENT_PROC_ADJ_ADIC        = X2058_ADIC.IDENT_PROC_ADJ(+)
          AND    ID_TIPO_SERV.COD_EMPRESA            = DOC_FIS.COD_EMPRESA
          AND    ID_TIPO_SERV.COD_ESTAB              = DOC_FIS.COD_ESTAB
          AND    DWT_MERC.IDENT_PRODUTO              = X2013.IDENT_PRODUTO                
          AND    ID_TIPO_SERV.GRUPO_PRODUTO          = X2013.GRUPO_PRODUTO
          AND    ID_TIPO_SERV.COD_PRODUTO            = X2013.COD_PRODUTO
          AND    ID_TIPO_SERV.IND_PRODUTO            = X2013.IND_PRODUTO                
          AND    ID_TIPO_SERV.COD_TIPO_SERV_ESOCIAL  = TIPO_SERV.COD_TIPO_SERV_ESOCIAL
          AND    TIPO_SERV.DATA_INI_VIGENCIA         = (SELECT MAX(A.DATA_INI_VIGENCIA)
                                                        FROM   PRT_TIPO_SERV_ESOCIAL A
                                                        WHERE  A.COD_TIPO_SERV_ESOCIAL =
                                                               TIPO_SERV.COD_TIPO_SERV_ESOCIAL 
                                                        AND    A.DATA_INI_VIGENCIA <= P_DATA_FINAL)                
          AND    DOC_FIS.DAT_CANCELAMENTO           IS NULL
          AND    DOC_FIS.COD_CLASS_DOC_FIS          IN ('1', '3')
          AND    DOC_FIS.NORM_DEV                    = '1'
        
          AND  ((DOC_FIS.MOVTO_E_S < '9' AND P_ENTRADA_SAIDA = 'E') OR (DOC_FIS.MOVTO_E_S = '9' AND P_ENTRADA_SAIDA = 'S'))  
          AND    NVL(DWT_MERC.VLR_INSS_RETIDO, 0)    > 0
          AND    DOC_FIS.SITUACAO = 'N'
          AND    ROUND((DWT_MERC.VLR_BASE_INSS * DWT_MERC.VLR_ALIQ_INSS)/100,2) <> DWT_MERC.VLR_INSS_RETIDO  
          AND    DOC_FIS.COD_EMPRESA                 = P_COD_EMPRESA
          AND    DOC_FIS.COD_ESTAB                   = P_COD_ESTAB
          AND    DOC_FIS.DATA_EMISSAO               >= P_DATA_INICIAL
          AND    DOC_FIS.DATA_EMISSAO               <= P_DATA_FINAL;
          
          
          
          
          
   
   CURSOR C_CONF_ALIQ_INSS_INVALIDA (P_COD_EMPRESA VARCHAR2, 
                           P_COD_ESTAB VARCHAR2,
                           P_DATA_INICIAL  DATE,
                           P_DATA_FINAL  DATE) IS
         
          SELECT DOC_FIS.DATA_EMISSAO
                ,DOC_FIS.DATA_FISCAL
                ,DOC_FIS.IDENT_FIS_JUR
                ,DOC_FIS.IDENT_DOCTO
                ,DOC_FIS.NUM_DOCFIS
                ,DOC_FIS.SERIE_DOCFIS
                ,DOC_FIS.SUB_SERIE_DOCFIS
                ,TIPO_SERV.IDENT_TIPO_SERV_ESOCIAL
                ,DOC_FIS.COD_CLASS_DOC_FIS
                ,DOC_FIS.VLR_TOT_NOTA
                ,DOC_FIS.VLR_CONTAB_COMPL
                ,DWT_ITENS.VLR_BASE_INSS
                ,DWT_ITENS.VLR_ALIQ_INSS
                ,DWT_ITENS.VLR_INSS_RETIDO
                ,X2058.IND_TP_PROC_ADJ
                ,X2058.NUM_PROC_ADJ
                ,DWT_ITENS.NUM_ITEM
                ,DWT_ITENS.VLR_SERVICO
                ,X2058_ADIC.IND_TP_PROC_ADJ
                ,X2058_ADIC.NUM_PROC_ADJ
                ,DWT_ITENS.IDENT_SERVICO
                , NULL 
                , NULL 
          FROM   DWT_DOCTO_FISCAL         DOC_FIS
                ,DWT_ITENS_SERV           DWT_ITENS
                ,X2018_SERVICOS           X2018
                ,PRT_ID_TIPO_SERV_ESOCIAL ID_TIPO_SERV
                ,PRT_TIPO_SERV_ESOCIAL    TIPO_SERV
                ,X2058_PROC_ADJ           X2058
                ,X2058_PROC_ADJ           X2058_ADIC
          WHERE  DOC_FIS.COD_EMPRESA                =  DWT_ITENS.COD_EMPRESA
          AND    DOC_FIS.COD_ESTAB                  =  DWT_ITENS.COD_ESTAB
          AND    DOC_FIS.DATA_FISCAL                =  DWT_ITENS.DATA_FISCAL
          AND    DOC_FIS.IDENT_FIS_JUR              =  DWT_ITENS.IDENT_FIS_JUR
          AND    DOC_FIS.IDENT_DOCTO                =  DWT_ITENS.IDENT_DOCTO
          AND    DOC_FIS.NUM_DOCFIS                 =  DWT_ITENS.NUM_DOCFIS
          AND    DOC_FIS.SERIE_DOCFIS               =  DWT_ITENS.SERIE_DOCFIS
          AND    DOC_FIS.SUB_SERIE_DOCFIS           =  DWT_ITENS.SUB_SERIE_DOCFIS
          AND    DWT_ITENS.IDENT_PROC_ADJ_PRINC     =  X2058.IDENT_PROC_ADJ(+)
          AND    DWT_ITENS.IDENT_PROC_ADJ_ADIC      =  X2058_ADIC.IDENT_PROC_ADJ(+)
          AND    ID_TIPO_SERV.COD_EMPRESA           =  DOC_FIS.COD_EMPRESA
          AND    ID_TIPO_SERV.COD_ESTAB             =  DOC_FIS.COD_ESTAB
          AND    DWT_ITENS.IDENT_SERVICO            =  X2018.IDENT_SERVICO
          AND    X2018.GRUPO_SERVICO                =  ID_TIPO_SERV.GRUPO_SERVICO
          AND    X2018.COD_SERVICO                  =  ID_TIPO_SERV.COD_SERVICO
          AND    ID_TIPO_SERV.COD_TIPO_SERV_ESOCIAL =  TIPO_SERV.COD_TIPO_SERV_ESOCIAL
          AND    TIPO_SERV.DATA_INI_VIGENCIA        =  (SELECT MAX(A.DATA_INI_VIGENCIA)
                                                        FROM   PRT_TIPO_SERV_ESOCIAL A
                                                        WHERE  A.COD_TIPO_SERV_ESOCIAL  = TIPO_SERV.COD_TIPO_SERV_ESOCIAL
                                                        AND    A.DATA_INI_VIGENCIA     <= P_DATA_FINAL)
          AND    DOC_FIS.DAT_CANCELAMENTO           IS NULL
          AND    DOC_FIS.COD_CLASS_DOC_FIS          IN ('2', '3')
          AND    DOC_FIS.NORM_DEV                    =  '1'
        
          AND  ((DOC_FIS.MOVTO_E_S < '9' AND P_ENTRADA_SAIDA = 'E') OR (DOC_FIS.MOVTO_E_S = '9' AND P_ENTRADA_SAIDA = 'S'))         
          AND    NVL(DWT_ITENS.VLR_INSS_RETIDO, 0)   >  0
          AND    DOC_FIS.SITUACAO = 'N'
          AND    DWT_ITENS.VLR_ALIQ_INSS <> 11 AND DWT_ITENS.VLR_ALIQ_INSS <> 3.5  
          AND    DOC_FIS.COD_EMPRESA                 =  P_COD_EMPRESA
          AND    DOC_FIS.COD_ESTAB                   =  P_COD_ESTAB
          AND    DOC_FIS.DATA_EMISSAO               >= P_DATA_INICIAL
          AND    DOC_FIS.DATA_EMISSAO               <= P_DATA_FINAL
          
          
          UNION ALL
          SELECT DOC_FIS.DATA_EMISSAO
                ,DOC_FIS.DATA_FISCAL
                ,DOC_FIS.IDENT_FIS_JUR
                ,DOC_FIS.IDENT_DOCTO
                ,DOC_FIS.NUM_DOCFIS
                ,DOC_FIS.SERIE_DOCFIS
                ,DOC_FIS.SUB_SERIE_DOCFIS
                ,NULL 
                ,DOC_FIS.COD_CLASS_DOC_FIS
                ,DOC_FIS.VLR_TOT_NOTA
                ,DOC_FIS.VLR_CONTAB_COMPL
                ,DWT_ITENS.VLR_BASE_INSS
                ,DWT_ITENS.VLR_ALIQ_INSS
                ,DWT_ITENS.VLR_INSS_RETIDO
                ,X2058.IND_TP_PROC_ADJ
                ,X2058.NUM_PROC_ADJ
                ,DWT_ITENS.NUM_ITEM
                ,DWT_ITENS.VLR_SERVICO
                ,X2058_ADIC.IND_TP_PROC_ADJ
                ,X2058_ADIC.NUM_PROC_ADJ
                ,DWT_ITENS.IDENT_SERVICO
                ,NULL 
                ,PRT_PAR2_MSAF.COD_PARAM
          FROM   DWT_DOCTO_FISCAL         DOC_FIS
                ,DWT_ITENS_SERV           DWT_ITENS
                ,X2018_SERVICOS           X2018
                ,PRT_SERV_MSAF
                ,PRT_PAR2_MSAF
                ,X2058_PROC_ADJ           X2058
                ,X2058_PROC_ADJ           X2058_ADIC
          WHERE  DOC_FIS.COD_EMPRESA                =  DWT_ITENS.COD_EMPRESA
          AND    DOC_FIS.COD_ESTAB                  =  DWT_ITENS.COD_ESTAB
          AND    DOC_FIS.DATA_FISCAL                =  DWT_ITENS.DATA_FISCAL
          AND    DOC_FIS.IDENT_FIS_JUR              =  DWT_ITENS.IDENT_FIS_JUR
          AND    DOC_FIS.IDENT_DOCTO                =  DWT_ITENS.IDENT_DOCTO
          AND    DOC_FIS.NUM_DOCFIS                 =  DWT_ITENS.NUM_DOCFIS
          AND    DOC_FIS.SERIE_DOCFIS               =  DWT_ITENS.SERIE_DOCFIS
          AND    DOC_FIS.SUB_SERIE_DOCFIS           =  DWT_ITENS.SUB_SERIE_DOCFIS
          AND    DWT_ITENS.IDENT_PROC_ADJ_PRINC     =  X2058.IDENT_PROC_ADJ(+)
          AND    DWT_ITENS.IDENT_PROC_ADJ_ADIC      =  X2058_ADIC.IDENT_PROC_ADJ(+)
          
          AND    PRT_SERV_MSAF.COD_EMPRESA           =  DOC_FIS.COD_EMPRESA
          AND    PRT_SERV_MSAF.COD_ESTAB             =  DOC_FIS.COD_ESTAB
          AND    DWT_ITENS.IDENT_SERVICO            =  X2018.IDENT_SERVICO
          AND    X2018.GRUPO_SERVICO                =  PRT_SERV_MSAF.GRUPO_SERVICO
          AND    X2018.COD_SERVICO                  =  PRT_SERV_MSAF.COD_SERVICO
          AND    PRT_SERV_MSAF.COD_PARAM            =  PRT_PAR2_MSAF.COD_PARAM
          AND    PRT_SERV_MSAF.COD_PARAM IN (683,684,685,686,690)
          
          AND    DOC_FIS.DAT_CANCELAMENTO           IS NULL
          AND    DOC_FIS.COD_CLASS_DOC_FIS          IN ('2', '3')
          AND    DOC_FIS.NORM_DEV                    =  '1'
        
          AND  ((DOC_FIS.MOVTO_E_S < '9' AND P_ENTRADA_SAIDA = 'E') OR (DOC_FIS.MOVTO_E_S = '9' AND P_ENTRADA_SAIDA = 'S'))         
          AND    NVL(DWT_ITENS.VLR_INSS_RETIDO, 0)   >  0
          AND    DOC_FIS.SITUACAO = 'N'
          AND    DWT_ITENS.VLR_ALIQ_INSS <> 11 AND DWT_ITENS.VLR_ALIQ_INSS <> 3.5  
          AND    DOC_FIS.COD_EMPRESA                 =  P_COD_EMPRESA
          AND    DOC_FIS.COD_ESTAB                   =  P_COD_ESTAB
          AND    DOC_FIS.DATA_EMISSAO               >= P_DATA_INICIAL
          AND    DOC_FIS.DATA_EMISSAO               <= P_DATA_FINAL
          
          
          UNION  ALL 
          SELECT DOC_FIS.DATA_EMISSAO
                ,DOC_FIS.DATA_FISCAL
                ,DOC_FIS.IDENT_FIS_JUR
                ,DOC_FIS.IDENT_DOCTO
                ,DOC_FIS.NUM_DOCFIS
                ,DOC_FIS.SERIE_DOCFIS
                ,DOC_FIS.SUB_SERIE_DOCFIS
                ,TIPO_SERV.IDENT_TIPO_SERV_ESOCIAL
                ,DOC_FIS.COD_CLASS_DOC_FIS
                ,DOC_FIS.VLR_TOT_NOTA
                ,DOC_FIS.VLR_CONTAB_COMPL
                ,DWT_MERC.VLR_BASE_INSS
                ,DWT_MERC.VLR_ALIQ_INSS
                ,DWT_MERC.VLR_INSS_RETIDO
                ,X2058.IND_TP_PROC_ADJ
                ,X2058.NUM_PROC_ADJ
                ,DWT_MERC.NUM_ITEM
                ,DWT_MERC.VLR_ITEM
                ,X2058_ADIC.IND_TP_PROC_ADJ
                ,X2058_ADIC.NUM_PROC_ADJ
                ,NULL 
                ,DWT_MERC.IDENT_PRODUTO
                ,NULL 
          FROM   DWT_DOCTO_FISCAL      DOC_FIS
                ,DWT_ITENS_MERC        DWT_MERC
                ,X2013_PRODUTO         X2013
                ,PRT_ID_TIPO_SERV_PROD ID_TIPO_SERV
                ,PRT_TIPO_SERV_ESOCIAL TIPO_SERV
                ,X2058_PROC_ADJ        X2058
                ,X2058_PROC_ADJ        X2058_ADIC
                ,X2024_MODELO_DOCTO    X2024
          WHERE  DOC_FIS.COD_EMPRESA                 = DWT_MERC.COD_EMPRESA
          AND    DOC_FIS.COD_ESTAB                   = DWT_MERC.COD_ESTAB
          AND    DOC_FIS.DATA_FISCAL                 = DWT_MERC.DATA_FISCAL
          AND    DOC_FIS.IDENT_FIS_JUR               = DWT_MERC.IDENT_FIS_JUR
          AND    DOC_FIS.IDENT_DOCTO                 = DWT_MERC.IDENT_DOCTO
          AND    DOC_FIS.NUM_DOCFIS                  = DWT_MERC.NUM_DOCFIS
          AND    DOC_FIS.SERIE_DOCFIS                = DWT_MERC.SERIE_DOCFIS
          AND    DOC_FIS.SUB_SERIE_DOCFIS            = DWT_MERC.SUB_SERIE_DOCFIS
          AND    DOC_FIS.IDENT_MODELO                = X2024.IDENT_MODELO
          AND    X2024.COD_MODELO                   IN ('07', '67')
          AND    DWT_MERC.IDENT_PROC_ADJ_PRINC       = X2058.IDENT_PROC_ADJ(+)
          AND    DWT_MERC.IDENT_PROC_ADJ_ADIC        = X2058_ADIC.IDENT_PROC_ADJ(+)
          AND    ID_TIPO_SERV.COD_EMPRESA            = DOC_FIS.COD_EMPRESA
          AND    ID_TIPO_SERV.COD_ESTAB              = DOC_FIS.COD_ESTAB
          AND    DWT_MERC.IDENT_PRODUTO              = X2013.IDENT_PRODUTO                
          AND    ID_TIPO_SERV.GRUPO_PRODUTO          = X2013.GRUPO_PRODUTO
          AND    ID_TIPO_SERV.COD_PRODUTO            = X2013.COD_PRODUTO
          AND    ID_TIPO_SERV.IND_PRODUTO            = X2013.IND_PRODUTO                
          AND    ID_TIPO_SERV.COD_TIPO_SERV_ESOCIAL  = TIPO_SERV.COD_TIPO_SERV_ESOCIAL
          AND    TIPO_SERV.DATA_INI_VIGENCIA         = (SELECT MAX(A.DATA_INI_VIGENCIA)
                                                        FROM   PRT_TIPO_SERV_ESOCIAL A
                                                        WHERE  A.COD_TIPO_SERV_ESOCIAL =
                                                               TIPO_SERV.COD_TIPO_SERV_ESOCIAL 
                                                        AND    A.DATA_INI_VIGENCIA <= P_DATA_FINAL)                
          AND    DOC_FIS.DAT_CANCELAMENTO           IS NULL
          AND    DOC_FIS.COD_CLASS_DOC_FIS          IN ('1', '3')
          AND    DOC_FIS.NORM_DEV                    = '1'
        
          AND  ((DOC_FIS.MOVTO_E_S < '9' AND P_ENTRADA_SAIDA = 'E') OR (DOC_FIS.MOVTO_E_S = '9' AND P_ENTRADA_SAIDA = 'S'))  
          AND    NVL(DWT_MERC.VLR_INSS_RETIDO, 0)    > 0
          AND    DOC_FIS.SITUACAO = 'N'
          AND    DWT_MERC.VLR_ALIQ_INSS <> 11 AND DWT_MERC.VLR_ALIQ_INSS  <> 3.5  
          AND    DOC_FIS.COD_EMPRESA                 = P_COD_EMPRESA
          AND    DOC_FIS.COD_ESTAB                   = P_COD_ESTAB
          AND    DOC_FIS.DATA_EMISSAO               >= P_DATA_INICIAL
          AND    DOC_FIS.DATA_EMISSAO               <= P_DATA_FINAL;
          
          
          
















































                                                                               

   TYPE TREG_DATA_EMISSAO              IS TABLE OF REINF_CONF_PREVIDENCIARIA.DATA_EMISSAO%TYPE INDEX BY BINARY_INTEGER;
   TYPE TREG_DATA_FISCAL               IS TABLE OF REINF_CONF_PREVIDENCIARIA.DATA_FISCAL%TYPE INDEX BY BINARY_INTEGER;
   TYPE TREG_IDENT_FIS_JUR             IS TABLE OF REINF_CONF_PREVIDENCIARIA.IDENT_FIS_JUR%TYPE INDEX BY BINARY_INTEGER;
   TYPE TREG_IDENT_DOCTO               IS TABLE OF REINF_CONF_PREVIDENCIARIA.IDENT_DOCTO%TYPE INDEX BY BINARY_INTEGER;
   TYPE TREG_NUM_DOCFIS                IS TABLE OF REINF_CONF_PREVIDENCIARIA.NUM_DOCFIS%TYPE INDEX BY BINARY_INTEGER;
   TYPE TREG_SERIE_DOCFIS              IS TABLE OF REINF_CONF_PREVIDENCIARIA.SERIE_DOCFIS%TYPE INDEX BY BINARY_INTEGER;
   TYPE TREG_SUB_SERIE_DOCFIS          IS TABLE OF REINF_CONF_PREVIDENCIARIA.SUB_SERIE_DOCFIS%TYPE INDEX BY BINARY_INTEGER;
   TYPE TREG_IDENT_TIPO_SERV_ESOCIAL   IS TABLE OF REINF_CONF_PREVIDENCIARIA.IDENT_TIPO_SERV_ESOCIAL%TYPE INDEX BY BINARY_INTEGER;
   TYPE TREG_COD_CLASS_DOC_FIS         IS TABLE OF REINF_CONF_PREVIDENCIARIA.COD_CLASS_DOC_FIS%TYPE  INDEX BY BINARY_INTEGER;
   TYPE TREG_VLR_TOT_NOTA              IS TABLE OF REINF_CONF_PREVIDENCIARIA.VLR_TOT_NOTA%TYPE  INDEX BY BINARY_INTEGER;
   TYPE TREG_VLR_CONTAB_COMPL          IS TABLE OF REINF_CONF_PREVIDENCIARIA.VLR_CONTAB_COMPL%TYPE  INDEX BY BINARY_INTEGER;    
   TYPE TREG_VLR_BASE_INSS             IS TABLE OF REINF_CONF_PREVIDENCIARIA.VLR_BASE_INSS%TYPE  INDEX BY BINARY_INTEGER;
   TYPE TREG_VLR_ALIQ_INSS             IS TABLE OF REINF_CONF_PREVIDENCIARIA.VLR_ALIQ_INSS%TYPE  INDEX BY BINARY_INTEGER;  
   TYPE TREG_VLR_INSS_RETIDO           IS TABLE OF REINF_CONF_PREVIDENCIARIA.VLR_INSS_RETIDO%TYPE  INDEX BY BINARY_INTEGER;  
   TYPE TREG_IND_TIPO_PROC             IS TABLE OF REINF_CONF_PREVIDENCIARIA.IND_TIPO_PROC%TYPE  INDEX BY BINARY_INTEGER;  
   TYPE TREG_NUM_PROC_JUR              IS TABLE OF REINF_CONF_PREVIDENCIARIA.NUM_PROC_JUR%TYPE  INDEX BY BINARY_INTEGER;  
   TYPE TREG_NUM_ITEM                  IS TABLE OF DWT_ITENS_SERV.NUM_ITEM%TYPE  INDEX BY BINARY_INTEGER;
   TYPE TREG_VLR_SERVICO               IS TABLE OF REINF_CONF_PREVIDENCIARIA.VLR_SERVICO%TYPE  INDEX BY BINARY_INTEGER;
   TYPE TREG_IND_TP_PROC_ADJ_ADIC      IS TABLE OF REINF_CONF_PREVIDENCIARIA.IND_TP_PROC_ADJ_ADIC%TYPE  INDEX BY BINARY_INTEGER;  
   TYPE TREG_NUM_PROC_ADJ_ADIC         IS TABLE OF REINF_CONF_PREVIDENCIARIA.NUM_PROC_ADJ_ADIC%TYPE  INDEX BY BINARY_INTEGER;  
   TYPE TREG_IDENT_SERVICO             IS TABLE OF DWT_ITENS_SERV.IDENT_SERVICO%TYPE  INDEX BY BINARY_INTEGER;    
   TYPE TREG_IDENT_PRODUTO             IS TABLE OF DWT_ITENS_MERC.IDENT_PRODUTO%TYPE  INDEX BY BINARY_INTEGER;
   TYPE TREG_COD_PARAM                 IS TABLE OF REINF_CONF_PREVIDENCIARIA.COD_PARAM%TYPE  INDEX BY BINARY_INTEGER; 

   RREG_DATA_EMISSAO             TREG_DATA_EMISSAO;           
   RREG_DATA_FISCAL              TREG_DATA_FISCAL;            
   RREG_IDENT_FIS_JUR            TREG_IDENT_FIS_JUR;          
   RREG_IDENT_DOCTO              TREG_IDENT_DOCTO;            
   RREG_NUM_DOCFIS               TREG_NUM_DOCFIS;             
   RREG_SERIE_DOCFIS             TREG_SERIE_DOCFIS;             
   RREG_SUB_SERIE_DOCFIS         TREG_SUB_SERIE_DOCFIS;       
   RREG_IDENT_TIPO_SERV_ESOCIAL  TREG_IDENT_TIPO_SERV_ESOCIAL;
   RREG_COD_CLASS_DOC_FIS        TREG_COD_CLASS_DOC_FIS;      
   RREG_VLR_TOT_NOTA             TREG_VLR_TOT_NOTA;           
   RREG_VLR_CONTAB_COMPL         TREG_VLR_CONTAB_COMPL;          
   RREG_VLR_BASE_INSS            TREG_VLR_BASE_INSS;             
   RREG_VLR_ALIQ_INSS            TREG_VLR_ALIQ_INSS;            
   RREG_VLR_INSS_RETIDO          TREG_VLR_INSS_RETIDO;
   RREG_IND_TIPO_PROC            TREG_IND_TIPO_PROC;
   RREG_NUM_PROC_JUR             TREG_NUM_PROC_JUR;
   RREG_NUM_ITEM                 TREG_NUM_ITEM;
   RREG_VLR_SERVICO              TREG_VLR_SERVICO;
   RREG_IND_TP_PROC_ADJ_ADIC     TREG_IND_TP_PROC_ADJ_ADIC;
   RREG_NUM_PROC_ADJ_ADIC        TREG_NUM_PROC_ADJ_ADIC;
   RREG_IDENT_SERVICO            TREG_IDENT_SERVICO;
   RREG_IDENT_PRODUTO            TREG_IDENT_PRODUTO;
   RREG_COD_PARAM                TREG_COD_PARAM;
  
  RTABSAIDA REINF_CONF_PREVIDENCIARIA%ROWTYPE; 
  
  
  PROCEDURE INICIALIZAR IS 
    BEGIN
      
      RREG_DATA_EMISSAO.DELETE;           
      RREG_DATA_FISCAL.DELETE;            
      RREG_IDENT_FIS_JUR.DELETE;          
      RREG_IDENT_DOCTO.DELETE;            
      RREG_NUM_DOCFIS.DELETE;             
      RREG_SERIE_DOCFIS.DELETE;           
      RREG_SUB_SERIE_DOCFIS.DELETE;       
      RREG_IDENT_TIPO_SERV_ESOCIAL.DELETE;
      RREG_COD_CLASS_DOC_FIS.DELETE;      
      RREG_VLR_TOT_NOTA.DELETE;           
      RREG_VLR_CONTAB_COMPL.DELETE;       
      RREG_VLR_BASE_INSS.DELETE;          
      RREG_VLR_ALIQ_INSS.DELETE;          
      RREG_VLR_INSS_RETIDO.DELETE;        
      RREG_IND_TIPO_PROC.DELETE;          
      RREG_NUM_PROC_JUR.DELETE;           
      RREG_NUM_ITEM.DELETE;
      RREG_VLR_SERVICO.DELETE;             
      RREG_IND_TP_PROC_ADJ_ADIC.DELETE;          
      RREG_NUM_PROC_ADJ_ADIC.DELETE;
      RREG_COD_PARAM.DELETE;           
    
  END INICIALIZAR;
  

  PROCEDURE GRAVAREGISTRO(PREG IN REINF_CONF_PREVIDENCIARIA%ROWTYPE) IS
  BEGIN
    BEGIN 
      INSERT INTO  msafi.tb_fin4816_reinf_conf_prev_tmp
        (COD_EMPRESA,
         COD_ESTAB,
         DATA_EMISSAO,
         DATA_FISCAL,
         IDENT_FIS_JUR,
         IDENT_DOCTO,
         NUM_DOCFIS,
         SERIE_DOCFIS,
         SUB_SERIE_DOCFIS,
         COD_USUARIO,
         IDENT_TIPO_SERV_ESOCIAL,
         COD_CLASS_DOC_FIS,
         VLR_TOT_NOTA,
         VLR_CONTAB_COMPL,
         VLR_BASE_INSS,
         VLR_ALIQ_INSS, 
         VLR_INSS_RETIDO, 
         IND_TIPO_PROC, 
         NUM_PROC_JUR,
         NUM_ITEM,
         VLR_SERVICO,
         IND_TP_PROC_ADJ_ADIC, 
         NUM_PROC_ADJ_ADIC,
         IDENT_SERVICO,
         IDENT_PRODUTO,
         COD_PARAM , 
         PROC_ID 
         )
      VALUES
        (PREG.COD_EMPRESA,
         PREG.COD_ESTAB,
         PREG.DATA_EMISSAO,
         PREG.DATA_FISCAL,
         PREG.IDENT_FIS_JUR,
         PREG.IDENT_DOCTO,
         PREG.NUM_DOCFIS,
         PREG.SERIE_DOCFIS,
         PREG.SUB_SERIE_DOCFIS,
         PREG.COD_USUARIO,
         PREG.IDENT_TIPO_SERV_ESOCIAL,
         PREG.COD_CLASS_DOC_FIS,
         PREG.VLR_TOT_NOTA,
         PREG.VLR_CONTAB_COMPL,
         PREG.VLR_BASE_INSS,
         PREG.VLR_ALIQ_INSS,
         PREG.VLR_INSS_RETIDO,
         PREG.IND_TIPO_PROC,
         PREG.NUM_PROC_JUR,
         PREG.NUM_ITEM,
         PREG.VLR_SERVICO,
         PREG.IND_TP_PROC_ADJ_ADIC,
         PREG.NUM_PROC_ADJ_ADIC,
         PREG.IDENT_SERVICO,
         PREG.IDENT_PRODUTO,
         PREG.COD_PARAM,
         P_PROCID
         )  ;
     EXCEPTION 
       WHEN DUP_VAL_ON_INDEX THEN
         NULL;
       WHEN OTHERS THEN
         P_STATUS := -1;
     
     END;
  
  END GRAVAREGISTRO;
  
  
  PROCEDURE MONTAREGISTROS IS
    BEGIN 
      
       FOR I IN 1..RREG_DATA_EMISSAO.COUNT LOOP
         BEGIN    
           
           P_STATUS := 1; 
           RTABSAIDA.COD_EMPRESA              := COD_EMPRESA_W;
           RTABSAIDA.COD_ESTAB                := COD_ESTAB_W;
           RTABSAIDA.DATA_EMISSAO             := RREG_DATA_EMISSAO(I);
           RTABSAIDA.DATA_FISCAL              := RREG_DATA_FISCAL(I);
           RTABSAIDA.IDENT_FIS_JUR            := RREG_IDENT_FIS_JUR(I); 
           RTABSAIDA.IDENT_DOCTO              := RREG_IDENT_DOCTO(I);
           RTABSAIDA.NUM_DOCFIS               := RREG_NUM_DOCFIS(I);
           RTABSAIDA.SERIE_DOCFIS             := RREG_SERIE_DOCFIS(I);                 
           RTABSAIDA.SUB_SERIE_DOCFIS         := RREG_SUB_SERIE_DOCFIS(I);
           RTABSAIDA.COD_USUARIO              := P_COD_USUARIO;
           RTABSAIDA.IDENT_TIPO_SERV_ESOCIAL  := RREG_IDENT_TIPO_SERV_ESOCIAL(I);
           RTABSAIDA.COD_CLASS_DOC_FIS        := RREG_COD_CLASS_DOC_FIS(I);
           RTABSAIDA.VLR_TOT_NOTA             := RREG_VLR_TOT_NOTA(I);
           RTABSAIDA.VLR_CONTAB_COMPL         := RREG_VLR_CONTAB_COMPL(I);
           RTABSAIDA.VLR_BASE_INSS            := RREG_VLR_BASE_INSS(I);
           RTABSAIDA.VLR_ALIQ_INSS            := RREG_VLR_ALIQ_INSS(I);
           RTABSAIDA.VLR_INSS_RETIDO          := RREG_VLR_INSS_RETIDO(I);
           RTABSAIDA.IND_TIPO_PROC            := RREG_IND_TIPO_PROC(I);
           RTABSAIDA.NUM_PROC_JUR             := RREG_NUM_PROC_JUR(I);
           RTABSAIDA.NUM_ITEM                 := RREG_NUM_ITEM(I);
           RTABSAIDA.VLR_SERVICO              := RREG_VLR_SERVICO(I);
           RTABSAIDA.IND_TP_PROC_ADJ_ADIC     := RREG_IND_TP_PROC_ADJ_ADIC(I);
           RTABSAIDA.NUM_PROC_ADJ_ADIC        := RREG_NUM_PROC_ADJ_ADIC(I);
           RTABSAIDA.IDENT_SERVICO            := RREG_IDENT_SERVICO(I);
           RTABSAIDA.IDENT_PRODUTO            := RREG_IDENT_PRODUTO(I);
           RTABSAIDA.COD_PARAM                := RREG_COD_PARAM(I);
                      
           GRAVAREGISTRO(RTABSAIDA);
         END; 
       END LOOP;
    
  END MONTAREGISTROS;   

  PROCEDURE MONTAREGISTROSSEMTIPOSERV IS
    BEGIN 
      
       FOR I IN 1..RREG_DATA_EMISSAO.COUNT LOOP
         BEGIN    
           
           P_STATUS := 1; 
           RTABSAIDA.COD_EMPRESA              := COD_EMPRESA_W;
           RTABSAIDA.COD_ESTAB                := COD_ESTAB_W;
           RTABSAIDA.DATA_EMISSAO             := RREG_DATA_EMISSAO(I);
           RTABSAIDA.DATA_FISCAL              := RREG_DATA_FISCAL(I);
           RTABSAIDA.IDENT_FIS_JUR            := RREG_IDENT_FIS_JUR(I); 
           RTABSAIDA.IDENT_DOCTO              := RREG_IDENT_DOCTO(I);
           RTABSAIDA.NUM_DOCFIS               := RREG_NUM_DOCFIS(I);
           RTABSAIDA.SERIE_DOCFIS             := RREG_SERIE_DOCFIS(I);                 
           RTABSAIDA.SUB_SERIE_DOCFIS         := RREG_SUB_SERIE_DOCFIS(I);
           RTABSAIDA.COD_USUARIO              := P_COD_USUARIO;
           RTABSAIDA.IDENT_TIPO_SERV_ESOCIAL  := NULL;
           RTABSAIDA.COD_CLASS_DOC_FIS        := RREG_COD_CLASS_DOC_FIS(I);
           RTABSAIDA.VLR_TOT_NOTA             := RREG_VLR_TOT_NOTA(I);
           RTABSAIDA.VLR_CONTAB_COMPL         := RREG_VLR_CONTAB_COMPL(I);
           RTABSAIDA.VLR_BASE_INSS            := RREG_VLR_BASE_INSS(I);
           RTABSAIDA.VLR_ALIQ_INSS            := RREG_VLR_ALIQ_INSS(I);
           RTABSAIDA.VLR_INSS_RETIDO          := RREG_VLR_INSS_RETIDO(I);
           RTABSAIDA.IND_TIPO_PROC            := RREG_IND_TIPO_PROC(I);
           RTABSAIDA.NUM_PROC_JUR             := RREG_NUM_PROC_JUR(I);
           RTABSAIDA.NUM_ITEM                 := RREG_NUM_ITEM(I);
           RTABSAIDA.IND_TP_PROC_ADJ_ADIC     := RREG_IND_TP_PROC_ADJ_ADIC(I);
           RTABSAIDA.NUM_PROC_ADJ_ADIC        := RREG_NUM_PROC_ADJ_ADIC(I);
           RTABSAIDA.IDENT_SERVICO            := RREG_IDENT_SERVICO(I);
           RTABSAIDA.IDENT_PRODUTO            := RREG_IDENT_PRODUTO(I);
           RTABSAIDA.COD_PARAM                := RREG_COD_PARAM(I);
           
           GRAVAREGISTRO(RTABSAIDA);
         END; 
       END LOOP;
    
  END MONTAREGISTROSSEMTIPOSERV;   
  
  
  
  
  
  
  
  
  
  
  PROCEDURE RECREGISTROSSERVRETPREV IS
    BEGIN
    
      OPEN C_CONF_RET_PREV(COD_EMPRESA_W, 
                           COD_ESTAB_W,
                           DATA_INI_W,
                           DATA_FIM_W);
      
      LOOP
        FETCH C_CONF_RET_PREV BULK COLLECT INTO RREG_DATA_EMISSAO,       
                                               RREG_DATA_FISCAL,     
                                               RREG_IDENT_FIS_JUR,      
                                               RREG_IDENT_DOCTO,       
                                               RREG_NUM_DOCFIS,     
                                               RREG_SERIE_DOCFIS, 
                                               RREG_SUB_SERIE_DOCFIS,   
                                               RREG_IDENT_TIPO_SERV_ESOCIAL,       
                                               RREG_COD_CLASS_DOC_FIS,                                                   
                                               RREG_VLR_TOT_NOTA,                                                   
                                               RREG_VLR_CONTAB_COMPL,                                                   
                                               RREG_VLR_BASE_INSS,                                                   
                                               RREG_VLR_ALIQ_INSS,                                                   
                                               RREG_VLR_INSS_RETIDO,                                                   
                                               RREG_IND_TIPO_PROC,                                                   
                                               RREG_NUM_PROC_JUR,
                                               RREG_NUM_ITEM,
                                               RREG_VLR_SERVICO,                                                   
                                               RREG_IND_TP_PROC_ADJ_ADIC,                                                   
                                               RREG_NUM_PROC_ADJ_ADIC,
                                               RREG_IDENT_SERVICO,
                                               RREG_IDENT_PRODUTO,
                                               RREG_COD_PARAM LIMIT 1000;  
                                                          
        MONTAREGISTROS;
        EXIT WHEN C_CONF_RET_PREV%NOTFOUND;
     END LOOP;
     COMMIT;
     CLOSE C_CONF_RET_PREV;    
    
  END RECREGISTROSSERVRETPREV;

 

 PROCEDURE RECREGISTROSSEMTIPOSERV IS
    BEGIN

      OPEN C_CONF_SEM_TIPO_SERV(COD_EMPRESA_W, 
                                 COD_ESTAB_W,
                                 DATA_INI_W,
                                 DATA_FIM_W);
      
      LOOP
        FETCH C_CONF_SEM_TIPO_SERV BULK COLLECT INTO RREG_DATA_EMISSAO,       
                                               RREG_DATA_FISCAL,     
                                               RREG_IDENT_FIS_JUR,      
                                               RREG_IDENT_DOCTO,       
                                               RREG_NUM_DOCFIS,     
                                               RREG_SERIE_DOCFIS, 
                                               RREG_SUB_SERIE_DOCFIS,   
                                               RREG_IDENT_TIPO_SERV_ESOCIAL,
                                               RREG_COD_CLASS_DOC_FIS,                                                   
                                               RREG_VLR_TOT_NOTA,                                                   
                                               RREG_VLR_CONTAB_COMPL,                                                   
                                               RREG_VLR_BASE_INSS,                                                   
                                               RREG_VLR_ALIQ_INSS,                                                   
                                               RREG_VLR_INSS_RETIDO,                                                   
                                               RREG_IND_TIPO_PROC,                                                   
                                               RREG_NUM_PROC_JUR,
                                               RREG_NUM_ITEM,
                                               RREG_VLR_SERVICO,                                                   
                                               RREG_IND_TP_PROC_ADJ_ADIC,                                                   
                                               RREG_NUM_PROC_ADJ_ADIC,
                                               RREG_IDENT_SERVICO,
                                               RREG_IDENT_PRODUTO,
                                               RREG_COD_PARAM LIMIT 1000;  
                                                          
        MONTAREGISTROS;
        EXIT WHEN C_CONF_SEM_TIPO_SERV%NOTFOUND;
     END LOOP;
     COMMIT;
     CLOSE C_CONF_SEM_TIPO_SERV;    
    
  END RECREGISTROSSEMTIPOSERV;
  
 
  PROCEDURE RECREGISTROSRETPREVPROC IS
    BEGIN

      OPEN C_CONF_RET_PREV_PROC(COD_EMPRESA_W, 
                           COD_ESTAB_W,
                           DATA_INI_W,
                           DATA_FIM_W);
      
      LOOP
        FETCH C_CONF_RET_PREV_PROC BULK COLLECT INTO RREG_DATA_EMISSAO,       
                                               RREG_DATA_FISCAL,     
                                               RREG_IDENT_FIS_JUR,      
                                               RREG_IDENT_DOCTO,       
                                               RREG_NUM_DOCFIS,     
                                               RREG_SERIE_DOCFIS, 
                                               RREG_SUB_SERIE_DOCFIS,   
                                               RREG_IDENT_TIPO_SERV_ESOCIAL,       
                                               RREG_COD_CLASS_DOC_FIS,                                                   
                                               RREG_VLR_TOT_NOTA,                                                   
                                               RREG_VLR_CONTAB_COMPL,                                                   
                                               RREG_VLR_BASE_INSS,                                                   
                                               RREG_VLR_ALIQ_INSS,                                                   
                                               RREG_VLR_INSS_RETIDO,                                                   
                                               RREG_IND_TIPO_PROC,                                                   
                                               RREG_NUM_PROC_JUR,
                                               RREG_NUM_ITEM,
                                               RREG_VLR_SERVICO,                                                   
                                               RREG_IND_TP_PROC_ADJ_ADIC,                                                   
                                               RREG_NUM_PROC_ADJ_ADIC,
                                               RREG_IDENT_SERVICO,
                                               RREG_IDENT_PRODUTO,
                                               RREG_COD_PARAM LIMIT 1000;  
                                                          
        MONTAREGISTROS; 
        EXIT WHEN C_CONF_RET_PREV_PROC%NOTFOUND;
     END LOOP;
     COMMIT;
     CLOSE C_CONF_RET_PREV_PROC;    
    
  END RECREGISTROSRETPREVPROC;
  
  
  PROCEDURE RECREGISTROSRETPREVSEMPROC IS
    BEGIN

      OPEN C_CONF_RET_PREV_SEM_PROC(COD_EMPRESA_W, 
                           COD_ESTAB_W,
                           DATA_INI_W,
                           DATA_FIM_W);
      
      LOOP
        FETCH C_CONF_RET_PREV_SEM_PROC BULK COLLECT INTO RREG_DATA_EMISSAO,       
                                               RREG_DATA_FISCAL,     
                                               RREG_IDENT_FIS_JUR,      
                                               RREG_IDENT_DOCTO,       
                                               RREG_NUM_DOCFIS,     
                                               RREG_SERIE_DOCFIS, 
                                               RREG_SUB_SERIE_DOCFIS,   
                                               RREG_IDENT_TIPO_SERV_ESOCIAL,       
                                               RREG_COD_CLASS_DOC_FIS,                                                   
                                               RREG_VLR_TOT_NOTA,                                                   
                                               RREG_VLR_CONTAB_COMPL,                                                   
                                               RREG_VLR_BASE_INSS,                                                   
                                               RREG_VLR_ALIQ_INSS,                                                   
                                               RREG_VLR_INSS_RETIDO,                                                   
                                               RREG_IND_TIPO_PROC,                                                   
                                               RREG_NUM_PROC_JUR,
                                               RREG_NUM_ITEM,
                                               RREG_VLR_SERVICO,                                                   
                                               RREG_IND_TP_PROC_ADJ_ADIC,                                                   
                                               RREG_NUM_PROC_ADJ_ADIC,
                                               RREG_IDENT_SERVICO,
                                               RREG_IDENT_PRODUTO,
                                               RREG_COD_PARAM LIMIT 1000;  
                                                          
        MONTAREGISTROS; 
        EXIT WHEN C_CONF_RET_PREV_SEM_PROC%NOTFOUND;
     END LOOP;
     COMMIT;
     CLOSE C_CONF_RET_PREV_SEM_PROC;    
    
  END RECREGISTROSRETPREVSEMPROC;
  
  
  
  PROCEDURE RECREGISTROSINSSMAIORBRUTO IS
    BEGIN

      OPEN C_CONF_INSS_MAIOR_BRUTO(COD_EMPRESA_W, 
                           COD_ESTAB_W,
                           DATA_INI_W,
                           DATA_FIM_W);
      
      LOOP
        FETCH C_CONF_INSS_MAIOR_BRUTO BULK COLLECT INTO RREG_DATA_EMISSAO,       
                                               RREG_DATA_FISCAL,     
                                               RREG_IDENT_FIS_JUR,      
                                               RREG_IDENT_DOCTO,       
                                               RREG_NUM_DOCFIS,     
                                               RREG_SERIE_DOCFIS, 
                                               RREG_SUB_SERIE_DOCFIS,   
                                               RREG_IDENT_TIPO_SERV_ESOCIAL,       
                                               RREG_COD_CLASS_DOC_FIS,                                                   
                                               RREG_VLR_TOT_NOTA,                                                   
                                               RREG_VLR_CONTAB_COMPL,                                                   
                                               RREG_VLR_BASE_INSS,                                                   
                                               RREG_VLR_ALIQ_INSS,                                                   
                                               RREG_VLR_INSS_RETIDO,                                                   
                                               RREG_IND_TIPO_PROC,                                                   
                                               RREG_NUM_PROC_JUR,
                                               RREG_NUM_ITEM,
                                               RREG_VLR_SERVICO,                                                   
                                               RREG_IND_TP_PROC_ADJ_ADIC,                                                   
                                               RREG_NUM_PROC_ADJ_ADIC,
                                               RREG_IDENT_SERVICO,
                                               RREG_IDENT_PRODUTO,
                                               RREG_COD_PARAM LIMIT 1000;  
                                                          
        MONTAREGISTROS; 
        EXIT WHEN C_CONF_INSS_MAIOR_BRUTO%NOTFOUND;
     END LOOP;
     COMMIT;
     CLOSE C_CONF_INSS_MAIOR_BRUTO;    
    
  END RECREGISTROSINSSMAIORBRUTO;
  
  
  PROCEDURE RECREGISTROSINSSALIQDIFINFORM IS
    BEGIN

      OPEN C_CONF_INSS_ALIQ_DIF_INFORMADO(COD_EMPRESA_W, 
                           COD_ESTAB_W,
                           DATA_INI_W,
                           DATA_FIM_W);
      
      LOOP
        FETCH C_CONF_INSS_ALIQ_DIF_INFORMADO BULK COLLECT INTO RREG_DATA_EMISSAO,       
                                               RREG_DATA_FISCAL,     
                                               RREG_IDENT_FIS_JUR,      
                                               RREG_IDENT_DOCTO,       
                                               RREG_NUM_DOCFIS,     
                                               RREG_SERIE_DOCFIS, 
                                               RREG_SUB_SERIE_DOCFIS,   
                                               RREG_IDENT_TIPO_SERV_ESOCIAL,       
                                               RREG_COD_CLASS_DOC_FIS,                                                   
                                               RREG_VLR_TOT_NOTA,                                                   
                                               RREG_VLR_CONTAB_COMPL,                                                   
                                               RREG_VLR_BASE_INSS,                                                   
                                               RREG_VLR_ALIQ_INSS,                                                   
                                               RREG_VLR_INSS_RETIDO,                                                   
                                               RREG_IND_TIPO_PROC,                                                   
                                               RREG_NUM_PROC_JUR,
                                               RREG_NUM_ITEM,
                                               RREG_VLR_SERVICO,                                                   
                                               RREG_IND_TP_PROC_ADJ_ADIC,                                                   
                                               RREG_NUM_PROC_ADJ_ADIC,
                                               RREG_IDENT_SERVICO,
                                               RREG_IDENT_PRODUTO,
                                               RREG_COD_PARAM LIMIT 1000;  
                                                          
        MONTAREGISTROS; 
        EXIT WHEN C_CONF_INSS_ALIQ_DIF_INFORMADO%NOTFOUND;
     END LOOP;
     COMMIT;
     CLOSE C_CONF_INSS_ALIQ_DIF_INFORMADO;    
    
  END RECREGISTROSINSSALIQDIFINFORM;
  
 
  PROCEDURE RECREGISTROSALIQINSSINVALIDA IS
    BEGIN

      OPEN C_CONF_ALIQ_INSS_INVALIDA(COD_EMPRESA_W, 
                           COD_ESTAB_W,
                           DATA_INI_W,
                           DATA_FIM_W);
      
      LOOP
        FETCH C_CONF_ALIQ_INSS_INVALIDA BULK COLLECT INTO RREG_DATA_EMISSAO,       
                                               RREG_DATA_FISCAL,     
                                               RREG_IDENT_FIS_JUR,      
                                               RREG_IDENT_DOCTO,       
                                               RREG_NUM_DOCFIS,     
                                               RREG_SERIE_DOCFIS, 
                                               RREG_SUB_SERIE_DOCFIS,   
                                               RREG_IDENT_TIPO_SERV_ESOCIAL,       
                                               RREG_COD_CLASS_DOC_FIS,                                                   
                                               RREG_VLR_TOT_NOTA,                                                   
                                               RREG_VLR_CONTAB_COMPL,                                                   
                                               RREG_VLR_BASE_INSS,                                                   
                                               RREG_VLR_ALIQ_INSS,                                                   
                                               RREG_VLR_INSS_RETIDO,                                                   
                                               RREG_IND_TIPO_PROC,                                                   
                                               RREG_NUM_PROC_JUR,
                                               RREG_NUM_ITEM,
                                               RREG_VLR_SERVICO,                                                   
                                               RREG_IND_TP_PROC_ADJ_ADIC,                                                   
                                               RREG_NUM_PROC_ADJ_ADIC,
                                               RREG_IDENT_SERVICO,
                                               RREG_IDENT_PRODUTO,
                                               RREG_COD_PARAM LIMIT 1000;  
                                                          
        MONTAREGISTROS; 
        EXIT WHEN C_CONF_ALIQ_INSS_INVALIDA%NOTFOUND;
     END LOOP;
     COMMIT;
     CLOSE C_CONF_ALIQ_INSS_INVALIDA;    
    
  END RECREGISTROSALIQINSSINVALIDA;      
 
  
BEGIN
  
   P_STATUS := 0;
    
   COD_EMPRESA_W  := P_COD_EMPRESA;
   COD_ESTAB_W    := P_COD_ESTAB;
   DATA_INI_W     := P_DATA_INICIAL;
   DATA_FIM_W     := P_DATA_FINAL;   
   
   
   
    
   IF P_TIPO_SELEC = '1' THEN   
     RECREGISTROSSERVRETPREV;
     
   ELSIF P_TIPO_SELEC = '2' THEN 
     RECREGISTROSSEMTIPOSERV;

   ELSIF P_TIPO_SELEC = '3' THEN 
     RECREGISTROSRETPREVPROC;
     
   ELSIF P_TIPO_SELEC = '4' THEN 
     RECREGISTROSRETPREVSEMPROC;
     
   ELSIF P_TIPO_SELEC = '5' THEN 
     RECREGISTROSINSSMAIORBRUTO;
     
   ELSIF P_TIPO_SELEC = '6' THEN 
     RECREGISTROSINSSALIQDIFINFORM;
     
   ELSIF P_TIPO_SELEC = '7' THEN 
     RECREGISTROSALIQINSSINVALIDA;               
     
   END IF; 

EXCEPTION
   WHEN NO_DATA_FOUND THEN  
     P_STATUS := 0;
      RETURN;
   WHEN OTHERS THEN
      P_STATUS := -1;
      RETURN;

END prc_reinf_conf_retencao;




--  DROP  TABLE MSAFI.TB_FIN4816_REINF_2010_TMP




 select distinct * from msafi.tb_fin4816_rel_apoio_fiscalv5 

SELECT * FROM msafi.tb_fin4816_reinf_conf_prev_tmp



SELECT  X09.COD_ESTAB ,   to_char(REINF.DATA_FISCAL, 'MM/YYYY') DT_FISCAL, COUNT(*)
 FROM REINF_CONF_PREVIDENCIARIA     REINF
 ,   DWT_ITENS_SERV                 X09
 WHERE  X09.COD_EMPRESA = REINF.COD_EMPRESA
 AND   X09.COD_ESTAB    = REINF.COD_ESTAB
 AND   X09.DATA_FISCAL  = REINF.DATA_FISCAL 
 AND   X09.DATA_FISCAL  = REINF.DATA_FISCAL 
 AND   X09.NUM_DOCFIS   = REINF.NUM_DOCFIS 
 AND   X09.NUM_ITEM     = REINF.NUM_ITEM
 AND   X09.DATA_FISCAL BETWEEN  '01/07/2018' AND  '31/07/2018'
 GROUP BY  X09.COD_ESTAB,  to_char(REINF.DATA_FISCAL, 'MM/YYYY')
 
 
 SELECT REINF.*
  FROM REINF_CONF_PREVIDENCIARIA     REINF
 ,   DWT_ITENS_SERV                 X09
 WHERE  X09.COD_EMPRESA = REINF.COD_EMPRESA
 AND   X09.COD_ESTAB    = REINF.COD_ESTAB
 AND   X09.DATA_FISCAL  = REINF.DATA_FISCAL 
 AND   X09.DATA_FISCAL  = REINF.DATA_FISCAL 
 AND   X09.NUM_DOCFIS   = REINF.NUM_DOCFIS 
 AND   X09.NUM_ITEM     = REINF.NUM_ITEM
 AND   X09.DATA_FISCAL BETWEEN  '01/07/2018' AND  '31/07/2018'
 AND  IDENT_TIPO_SERV_ESOCIAL   IS NOT NULL 
 AND   REINF.COD_ESTAB  = 'DSP086'
 
 
 
  SELECT reinf.*
 FROM msafi.tb_fin4816_reinf_2010_tmp     REINF
  WHERE    COD_ESTAB  = 'DSP086'
 
 
 
 
 SELECT * FROM msafi.tb_fin4816_reinf_conf_prev_tmp
 
 
 
 
 SELECT * FROM MSAFI.TB_FIN4816_REINF_2010_TMP
 WHERE    COD_ESTAB  = 'DSP086'
 
 
 SELECT * FROM REINF_CONF_PREVIDENCIARIA     REINF
 WHERE  DATA_FISCAL BETWEEN  '01/01/2018' AND  '31/12/2018'
 
 
 SELECT reinf.*
 FROM msafi.tb_fin4816_reinf_2010_tmp     REINF
 ,   dwt_itens_serv                       X09
 WHERE  X09.COD_EMPRESA = REINF.COD_EMPRESA
AND     X09.COD_ESTAB    = REINF.COD_ESTAB
 --AND   X09.DATA_FISCAL  = REINF."Data de Emissão da NF" 
 AND   X09.NUM_DOCFIS   = REINF."Número da Nota Fiscal" 
 --AND   X09.NUM_ITEM     = REINF.NUM_ITEM
 
 
 SELECT * 
   FROM msafi.tb_fin4816_reinf_2010_tmp
   WHERE "Data de Emissão da NF" BETWEEN  '01/07/2018' AND  '31/07/2018';
 
 
                                                              
                                                                                          

                                            select * from msafi.tb_fin4816_rel_apoio_fiscalv5 
 
                                                             
                                                             DECLARE 
                                                             p_status VARCHAR2(1);
                                                             begin
                                                             prc_reinf_conf_retencao( 
                                                              p_cod_empresa   => 'DSP'
                                                             ,p_cod_estab     => 'DSP086'
                                                             ,p_tipo_selec    => '1'
                                                             ,p_data_inicial  => '01/07/2018'
                                                             ,p_data_final    => '31/07/2018'
                                                             ,p_cod_usuario   => 'leonardo.b.lima'
                                                             ,p_entrada_saida => 'E'
                                                             ,p_status        => p_status 
                                                            -- ,p_proc_id       => 290380
                                                             --
                                                             );
                                                            end ;
                                                            
                                                            
                                                            SELECT * FROM REINF_CONF_PREVIDENCIARIA
                                                            WHERE 1=1
                                                            AND COD_ESTAB = 'DSP062'
                                                            AND  DATA_EMISSAO > '31/01/2018';
                                                            
                                                            
                                                            
                                                            
                                                            
                                                            SELECT * FROM  msafi.tb_fin4816_reinf_2010_tmp b
                                                            WHERE b."Data de Emissão da NF"    BETWEEN '01/05/2018'   AND '31/05/2018'     
  
                                                            
                                                            SELECT * FROM   msafi.tb_fin4816_rel_apoio_fiscalv5   a
                                                             WHERE a."Data Emissão"    BETWEEN '01/05/2018'   AND '31/05/2018'     
                                                            
--                                                            329
--                                                            134911,2
--                                                            2300
                                                            
                                                              select distinct a.*
                                                                from msafi.tb_fin4816_rel_apoio_fiscalv5  a
                                                               ,     msafi.tb_fin4816_reinf_2010_tmp      b
                                                              WHERE 1=1
                                                               and   b.cod_empresa  = a."Codigo da Empresa"         
                                                               AND   b.cod_estab    = a."Codigo do Estabelecimento"
                                                               and   b."Data de Emissão da NF"    BETWEEN '01/05/2018'   AND '31/05/2018'                                             
                                                              --- and   b.num_docfis   = a."Numero da Nota Fiscal" 
                                                              
                                                                
-- 000003610
--000000369
--000004251                                             





                    select * from msafi.tb_fin4816_rel_apoio_fiscalv5 
                    
                    select * from msafi.tb_fin4816_reinf_conf_prev_tmp a



                    SELECT 
                            a.cod_empresa                              AS  "Codigo Empresa"
                          , INITCAP ( empresa.razao_social)            AS  "Razão Social Drogaria."
                          , INITCAP ( x04.razao_social )               AS  "Razão Social Cliente"
                          , a.num_docfis                                 
                          , a.data_emissao
                          , a.data_fiscal 
                          , a.vlr_servico                               AS "Valor do Tributo"
                          , null                                       AS "Observação"
                          ,  prt_tipo.cod_tipo_serv_esocial                                          AS "Tipo de Serviço Esocial"
                          ,a.vlr_base_inss                             AS "Vlr Base Calculo Retenção"  
                          ,a.vlr_inss_retido                           AS "Vlr da Retenção"                   
                     FROM  msafi.tb_fin4816_reinf_conf_prev_tmp a
                          ,     x04_pessoa_fis_jur                   x04
                          ,     empresa 
                          ,     estabelecimento  
                          ,    prt_tipo_serv_esocial      prt_tipo            
                          where 1=1
--                          and   a.cod_empresa   = pcod_empresa
--                          and   a.cod_estab     = pcod_estab 
--                          and   a.data_emissao  = p_dtemissao
--                          and   a.ident_fis_jur = pident_fis_jur
--                          and   a.ident_docto   = pident_docto
--                          and   a.num_docfis    = pnum_docfis 
--                          and   a.num_item      = pnum_item
                          --
                          and   a.ident_fis_jur             = x04.ident_fis_jur
                          and   a.cod_empresa               = estabelecimento.cod_empresa
                          and   a.cod_estab                 = estabelecimento.cod_estab
                          and   a.cod_empresa               = empresa.cod_empresa
                          and   empresa.cod_empresa         = estabelecimento.cod_empresa
                          AND   a.ident_tipo_serv_esocial   = prt_tipo.ident_tipo_serv_esocial 
                          
                          
                          
                          select * from reinf_pger_r2010_nf rnf
                          
                          select * from reinf_pger_r2010_tp_serv rserv
                          
                          select * from msafi.tb_fin4816_reinf_conf_prev_tmp a
                          
                           select  a.*
                            from    msafi.tb_fin4816_reinf_conf_prev_tmp a 
                                ,   reinf_pger_r2010_tp_serv             rserv
                                ,   reinf_pger_r2010_nf                  rnf
                           where   rserv.vlr_base_ret   = a.vlr_base_inss 
                           and     rserv.vlr_retencao   = a.vlr_inss_retido
                           AND     rnf.id_r2010_nf      = rserv.id_r2010_nf
                           AND     rnf.data_saida_rec_nf      = a.data_fiscal
                            
                           
             000000101
000008708




      SELECT COUNT(*)
         FROM empresa
             , estabelecimento
             , reinf_pger_apur
             , x04_pessoa_fis_jur
             , reinf_pger_r2010_prest
             , reinf_pger_r2010_tom
             , reinf_pger_r2010_oc
             , reinf_pger_r2010_nf rnf
             , reinf_pger_r2010_tp_serv rserv
             , reinf_pger_r2010_proc_adic radic
             , reinf_pger_r2010_proc_princ rprinc             
             , msafi.tb_fin4816_prev_tmp_estab estab1
            -- select * from msafi.tb_fin4816_prev_tmp_estab estab1
           --,  msafi.tb_fin4816_reinf_conf_prev_tmp a 
         WHERE 1 = 1
           AND reinf_pger_apur.dat_apur BETWEEN    '01/07/2018' AND  '31/07/2018'  -- parametro
           AND estab1.cod_estab                         = estabelecimento.cod_estab
--           AND estab1.proc_id                           = 1185500     
--           AND  estabelecimento.cod_estab               = 'DSP086'     
           AND ( estabelecimento.cod_empresa            = reinf_pger_apur.cod_empresa )
           AND ( estabelecimento.cod_estab              = reinf_pger_apur.cod_estab )
           AND ( estabelecimento.cod_empresa            = empresa.cod_empresa )
           AND ( reinf_pger_r2010_prest.cnpj_prestador  = x04_pessoa_fis_jur.cpf_cgc )
           AND ( reinf_pger_r2010_tom.id_pger_apur      = reinf_pger_apur.id_pger_apur )
           AND ( reinf_pger_r2010_tom.id_r2010_tom      = reinf_pger_r2010_prest.id_r2010_tom )
           AND ( reinf_pger_r2010_prest.id_r2010_prest  = reinf_pger_r2010_oc.id_r2010_prest )
           AND ( reinf_pger_r2010_oc.id_r2010_oc        = rnf.id_r2010_oc )
--           AND ( reinf_pger_r2010_oc.dat_ocorrencia     = max_oc.dat_ocorrencia )
--           AND ( reinf_pger_r2010_prest.id_r2010_prest  = max_oc.id_r2010_prest )
--           AND ( reinf_pger_r2010_tom.id_r2010_tom      = max_oc.id_r2010_tom )
--           AND ( reinf_pger_apur.id_pger_apur           = max_oc.id_pger_apur )
           AND rnf.id_r2010_nf                          = rserv.id_r2010_nf(+)
           AND reinf_pger_r2010_oc.id_r2010_oc          = radic.id_r2010_oc(+)
           AND reinf_pger_r2010_oc.id_r2010_oc          = rprinc.id_r2010_oc(+)
           AND ( reinf_pger_apur.ind_r2010              = 'S' )
         --AND ( reinf_pger_apur.cod_versao = 'v1_04_00' )
           AND reinf_pger_apur.ind_tp_amb               <> '2' 