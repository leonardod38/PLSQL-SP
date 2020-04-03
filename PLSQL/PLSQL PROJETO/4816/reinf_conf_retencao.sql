PROCEDURE reinf_conf_retencao(P_COD_EMPRESA IN VARCHAR2,
                                                     P_COD_ESTAB IN VARCHAR2,
                                                     P_TIPO_SELEC IN VARCHAR2,
                                                     P_DATA_INICIAL IN DATE,
                                                     P_DATA_FINAL   IN DATE,
                                                     P_COD_USUARIO  IN VARCHAR2,
                                                     P_ENTRADA_SAIDA IN VARCHAR2,
                                                     P_STATUS     OUT NUMBER) IS
   
   
    COD_EMPRESA_W  ESTABELECIMENTO.COD_EMPRESA%TYPE;
    COD_ESTAB_W    ESTABELECIMENTO.COD_ESTAB%TYPE;
    DATA_INI_W     DATE;
    DATA_FIM_W     DATE; 
      
     
     CURSOR C_CONF_RET_PREV (P_COD_EMPRESA VARCHAR2, 
                             P_COD_ESTAB VARCHAR2,
                             P_DATA_INICIAL  DATE,
                             P_DATA_FINAL  DATE) IS
            
   22           SELECT DOC_FIS.DATA_EMISSAO
   23                 ,DOC_FIS.DATA_FISCAL
   24                 ,DOC_FIS.IDENT_FIS_JUR
   25                 ,DOC_FIS.IDENT_DOCTO
   26                 ,DOC_FIS.NUM_DOCFIS
   27                 ,DOC_FIS.SERIE_DOCFIS
   28                 ,DOC_FIS.SUB_SERIE_DOCFIS
   29                 ,TIPO_SERV.IDENT_TIPO_SERV_ESOCIAL
   30                 ,DOC_FIS.COD_CLASS_DOC_FIS
   31                 ,DOC_FIS.VLR_TOT_NOTA
   32                 ,DOC_FIS.VLR_CONTAB_COMPL
   33                 ,DWT_ITENS.VLR_BASE_INSS
   34                 ,DWT_ITENS.VLR_ALIQ_INSS
   35                 ,DWT_ITENS.VLR_INSS_RETIDO
   36                 ,X2058.IND_TP_PROC_ADJ
   37                 ,X2058.NUM_PROC_ADJ
   38                 ,DWT_ITENS.NUM_ITEM
   39                 ,DWT_ITENS.VLR_SERVICO
   40                 ,X2058_ADIC.IND_TP_PROC_ADJ
   41                 ,X2058_ADIC.NUM_PROC_ADJ
   42                 ,DWT_ITENS.IDENT_SERVICO
   43                 , NULL 
   44                 , NULL 
   45           FROM   DWT_DOCTO_FISCAL         DOC_FIS
   46                 ,DWT_ITENS_SERV           DWT_ITENS
   47                 ,X2018_SERVICOS           X2018
   48                 ,PRT_ID_TIPO_SERV_ESOCIAL ID_TIPO_SERV
   49                 ,PRT_TIPO_SERV_ESOCIAL    TIPO_SERV
   50                 ,X2058_PROC_ADJ           X2058
   51                 ,X2058_PROC_ADJ           X2058_ADIC
   52           WHERE  DOC_FIS.COD_EMPRESA                =  DWT_ITENS.COD_EMPRESA
   53           AND    DOC_FIS.COD_ESTAB                  =  DWT_ITENS.COD_ESTAB
   54           AND    DOC_FIS.DATA_FISCAL                =  DWT_ITENS.DATA_FISCAL
   55           AND    DOC_FIS.IDENT_FIS_JUR              =  DWT_ITENS.IDENT_FIS_JUR
   56           AND    DOC_FIS.IDENT_DOCTO                =  DWT_ITENS.IDENT_DOCTO
   57           AND    DOC_FIS.NUM_DOCFIS                 =  DWT_ITENS.NUM_DOCFIS
   58           AND    DOC_FIS.SERIE_DOCFIS               =  DWT_ITENS.SERIE_DOCFIS
   59           AND    DOC_FIS.SUB_SERIE_DOCFIS           =  DWT_ITENS.SUB_SERIE_DOCFIS
   60           AND    DWT_ITENS.IDENT_PROC_ADJ_PRINC     =  X2058.IDENT_PROC_ADJ(+)
   61           AND    DWT_ITENS.IDENT_PROC_ADJ_ADIC      =  X2058_ADIC.IDENT_PROC_ADJ(+)
   62           AND    ID_TIPO_SERV.COD_EMPRESA           =  DOC_FIS.COD_EMPRESA
   63           AND    ID_TIPO_SERV.COD_ESTAB             =  DOC_FIS.COD_ESTAB
   64           AND    DWT_ITENS.IDENT_SERVICO            =  X2018.IDENT_SERVICO
   65           AND    X2018.GRUPO_SERVICO                =  ID_TIPO_SERV.GRUPO_SERVICO
   66           AND    X2018.COD_SERVICO                  =  ID_TIPO_SERV.COD_SERVICO
   67           AND    ID_TIPO_SERV.COD_TIPO_SERV_ESOCIAL =  TIPO_SERV.COD_TIPO_SERV_ESOCIAL
   68           AND    TIPO_SERV.DATA_INI_VIGENCIA        =  (SELECT MAX(A.DATA_INI_VIGENCIA)
   69                                                         FROM   PRT_TIPO_SERV_ESOCIAL A
   70                                                         WHERE  A.COD_TIPO_SERV_ESOCIAL  = TIPO_SERV.COD_TIPO_SERV_ESOCIAL
   71                                                         AND    A.DATA_INI_VIGENCIA     <= P_DATA_FINAL)
   72           AND    DOC_FIS.DAT_CANCELAMENTO           IS NULL
   73           AND    DOC_FIS.COD_CLASS_DOC_FIS          IN ('2', '3')
   74           AND    DOC_FIS.NORM_DEV                    =  '1'
   75         
   76           AND  ((DOC_FIS.MOVTO_E_S < '9' AND P_ENTRADA_SAIDA = 'E') OR (DOC_FIS.MOVTO_E_S = '9' AND P_ENTRADA_SAIDA = 'S'))         
   77           AND    NVL(DWT_ITENS.VLR_INSS_RETIDO, 0)   >  0
   78           AND    DOC_FIS.SITUACAO = 'N'
   79           AND    DOC_FIS.COD_EMPRESA                 =  P_COD_EMPRESA
   80           AND    DOC_FIS.COD_ESTAB                   =  P_COD_ESTAB
   81           AND    DOC_FIS.DATA_EMISSAO               >= P_DATA_INICIAL
   82           AND    DOC_FIS.DATA_EMISSAO               <= P_DATA_FINAL
   83           
   84           
   85           UNION ALL
   86           SELECT DOC_FIS.DATA_EMISSAO
   87                 ,DOC_FIS.DATA_FISCAL
   88                 ,DOC_FIS.IDENT_FIS_JUR
   89                 ,DOC_FIS.IDENT_DOCTO
   90                 ,DOC_FIS.NUM_DOCFIS
   91                 ,DOC_FIS.SERIE_DOCFIS
   92                 ,DOC_FIS.SUB_SERIE_DOCFIS
   93                 ,NULL 
   94                 ,DOC_FIS.COD_CLASS_DOC_FIS
   95                 ,DOC_FIS.VLR_TOT_NOTA
   96                 ,DOC_FIS.VLR_CONTAB_COMPL
   97                 ,DWT_ITENS.VLR_BASE_INSS
   98                 ,DWT_ITENS.VLR_ALIQ_INSS
   99                 ,DWT_ITENS.VLR_INSS_RETIDO
  100                 ,X2058.IND_TP_PROC_ADJ
  101                 ,X2058.NUM_PROC_ADJ
  102                 ,DWT_ITENS.NUM_ITEM
  103                 ,DWT_ITENS.VLR_SERVICO
  104                 ,X2058_ADIC.IND_TP_PROC_ADJ
  105                 ,X2058_ADIC.NUM_PROC_ADJ
  106                 ,DWT_ITENS.IDENT_SERVICO
  107                 , NULL 
  108                 , PRT_PAR2_MSAF.COD_PARAM 
  109           FROM   DWT_DOCTO_FISCAL         DOC_FIS
  110                 ,DWT_ITENS_SERV           DWT_ITENS
  111                 ,X2018_SERVICOS           X2018
  112                 ,PRT_SERV_MSAF
  113                 ,PRT_PAR2_MSAF
  114                 ,X2058_PROC_ADJ           X2058
  115                 ,X2058_PROC_ADJ           X2058_ADIC
  116           WHERE  DOC_FIS.COD_EMPRESA                =  DWT_ITENS.COD_EMPRESA
  117           AND    DOC_FIS.COD_ESTAB                  =  DWT_ITENS.COD_ESTAB
  118           AND    DOC_FIS.DATA_FISCAL                =  DWT_ITENS.DATA_FISCAL
  119           AND    DOC_FIS.IDENT_FIS_JUR              =  DWT_ITENS.IDENT_FIS_JUR
  120           AND    DOC_FIS.IDENT_DOCTO                =  DWT_ITENS.IDENT_DOCTO
  121           AND    DOC_FIS.NUM_DOCFIS                 =  DWT_ITENS.NUM_DOCFIS
  122           AND    DOC_FIS.SERIE_DOCFIS               =  DWT_ITENS.SERIE_DOCFIS
  123           AND    DOC_FIS.SUB_SERIE_DOCFIS           =  DWT_ITENS.SUB_SERIE_DOCFIS
  124           AND    DWT_ITENS.IDENT_PROC_ADJ_PRINC     =  X2058.IDENT_PROC_ADJ(+)
  125           AND    DWT_ITENS.IDENT_PROC_ADJ_ADIC      =  X2058_ADIC.IDENT_PROC_ADJ(+)
  126           
  127           AND    PRT_SERV_MSAF.COD_EMPRESA           =  DOC_FIS.COD_EMPRESA
  128           AND    PRT_SERV_MSAF.COD_ESTAB             =  DOC_FIS.COD_ESTAB
  129           AND    DWT_ITENS.IDENT_SERVICO            =  X2018.IDENT_SERVICO
  130           AND    X2018.GRUPO_SERVICO                =  PRT_SERV_MSAF.GRUPO_SERVICO
  131           AND    X2018.COD_SERVICO                  =  PRT_SERV_MSAF.COD_SERVICO
  132           AND    PRT_SERV_MSAF.COD_PARAM            =  PRT_PAR2_MSAF.COD_PARAM
  133           AND    PRT_SERV_MSAF.COD_PARAM IN (683,684,685,686,690)
  134           
  135           AND    DOC_FIS.DAT_CANCELAMENTO           IS NULL
  136           AND    DOC_FIS.COD_CLASS_DOC_FIS          IN ('2', '3')
  137           AND    DOC_FIS.NORM_DEV                    =  '1'
  138         
  139           AND  ((DOC_FIS.MOVTO_E_S < '9' AND P_ENTRADA_SAIDA = 'E') OR (DOC_FIS.MOVTO_E_S = '9' AND P_ENTRADA_SAIDA = 'S'))         
  140           AND    NVL(DWT_ITENS.VLR_INSS_RETIDO, 0)   >  0
  141           AND    DOC_FIS.SITUACAO = 'N'
  142           AND    DOC_FIS.COD_EMPRESA                 = P_COD_EMPRESA
  143           AND    DOC_FIS.COD_ESTAB                   = P_COD_ESTAB
  144           AND    DOC_FIS.DATA_EMISSAO               >= P_DATA_INICIAL
  145           AND    DOC_FIS.DATA_EMISSAO               <= P_DATA_FINAL 
  146         
  147         
  148         
  149          
  150           UNION  ALL 
  151           SELECT DOC_FIS.DATA_EMISSAO
  152                 ,DOC_FIS.DATA_FISCAL
  153                 ,DOC_FIS.IDENT_FIS_JUR
  154                 ,DOC_FIS.IDENT_DOCTO
  155                 ,DOC_FIS.NUM_DOCFIS
  156                 ,DOC_FIS.SERIE_DOCFIS
  157                 ,DOC_FIS.SUB_SERIE_DOCFIS
  158                 ,TIPO_SERV.IDENT_TIPO_SERV_ESOCIAL
  159                 ,DOC_FIS.COD_CLASS_DOC_FIS
  160                 ,DOC_FIS.VLR_TOT_NOTA
  161                 ,DOC_FIS.VLR_CONTAB_COMPL
  162                 ,DWT_MERC.VLR_BASE_INSS
  163                 ,DWT_MERC.VLR_ALIQ_INSS
  164                 ,DWT_MERC.VLR_INSS_RETIDO
  165                 ,X2058.IND_TP_PROC_ADJ
  166                 ,X2058.NUM_PROC_ADJ
  167                 ,DWT_MERC.NUM_ITEM
  168                 ,DWT_MERC.VLR_ITEM
  169                 ,X2058_ADIC.IND_TP_PROC_ADJ
  170                 ,X2058_ADIC.NUM_PROC_ADJ
  171                 ,NULL 
  172                 ,DWT_MERC.IDENT_PRODUTO
  173                 ,NULL 
  174           FROM   DWT_DOCTO_FISCAL      DOC_FIS
  175                 ,DWT_ITENS_MERC        DWT_MERC
  176                 ,X2013_PRODUTO         X2013
  177                 ,PRT_ID_TIPO_SERV_PROD ID_TIPO_SERV
  178                 ,PRT_TIPO_SERV_ESOCIAL TIPO_SERV
  179                 ,X2058_PROC_ADJ        X2058
  180                 ,X2058_PROC_ADJ        X2058_ADIC
  181                 ,X2024_MODELO_DOCTO    X2024
  182           WHERE  DOC_FIS.COD_EMPRESA                 = DWT_MERC.COD_EMPRESA
  183           AND    DOC_FIS.COD_ESTAB                   = DWT_MERC.COD_ESTAB
  184           AND    DOC_FIS.DATA_FISCAL                 = DWT_MERC.DATA_FISCAL
  185           AND    DOC_FIS.IDENT_FIS_JUR               = DWT_MERC.IDENT_FIS_JUR
  186           AND    DOC_FIS.IDENT_DOCTO                 = DWT_MERC.IDENT_DOCTO
  187           AND    DOC_FIS.NUM_DOCFIS                  = DWT_MERC.NUM_DOCFIS
  188           AND    DOC_FIS.SERIE_DOCFIS                = DWT_MERC.SERIE_DOCFIS
  189           AND    DOC_FIS.SUB_SERIE_DOCFIS            = DWT_MERC.SUB_SERIE_DOCFIS
  190           AND    DOC_FIS.IDENT_MODELO                = X2024.IDENT_MODELO
  191           AND    X2024.COD_MODELO                   IN ('07', '67')
  192           AND    DWT_MERC.IDENT_PROC_ADJ_PRINC       = X2058.IDENT_PROC_ADJ(+)
  193           AND    DWT_MERC.IDENT_PROC_ADJ_ADIC        = X2058_ADIC.IDENT_PROC_ADJ(+)
  194           AND    ID_TIPO_SERV.COD_EMPRESA            = DOC_FIS.COD_EMPRESA
  195           AND    ID_TIPO_SERV.COD_ESTAB              = DOC_FIS.COD_ESTAB
  196        
  197           AND    DWT_MERC.IDENT_PRODUTO              = X2013.IDENT_PRODUTO                
  198           AND    ID_TIPO_SERV.GRUPO_PRODUTO          = X2013.GRUPO_PRODUTO
  199           AND    ID_TIPO_SERV.COD_PRODUTO            = X2013.COD_PRODUTO
  200           AND    ID_TIPO_SERV.IND_PRODUTO            = X2013.IND_PRODUTO                
  201           AND    ID_TIPO_SERV.COD_TIPO_SERV_ESOCIAL  = TIPO_SERV.COD_TIPO_SERV_ESOCIAL
  202           AND    TIPO_SERV.DATA_INI_VIGENCIA         = (SELECT MAX(A.DATA_INI_VIGENCIA)
  203                                                         FROM   PRT_TIPO_SERV_ESOCIAL A
  204                                                         WHERE  A.COD_TIPO_SERV_ESOCIAL =
  205                                                                TIPO_SERV.COD_TIPO_SERV_ESOCIAL 
  206                                                         AND    A.DATA_INI_VIGENCIA <= P_DATA_FINAL)                
  207           AND    DOC_FIS.DAT_CANCELAMENTO           IS NULL
  208           AND    DOC_FIS.COD_CLASS_DOC_FIS          IN ('1', '3')
  209           AND    DOC_FIS.NORM_DEV                    = '1'
  210         
  211           AND  ((DOC_FIS.MOVTO_E_S < '9' AND P_ENTRADA_SAIDA = 'E') OR (DOC_FIS.MOVTO_E_S = '9' AND P_ENTRADA_SAIDA = 'S'))  
  212           AND    NVL(DWT_MERC.VLR_INSS_RETIDO, 0)    > 0
  213           AND    DOC_FIS.SITUACAO = 'N'
  214           AND    DOC_FIS.COD_EMPRESA                 = P_COD_EMPRESA
  215           AND    DOC_FIS.COD_ESTAB                   = P_COD_ESTAB
  216           AND    DOC_FIS.DATA_EMISSAO               >= P_DATA_INICIAL
  217           AND    DOC_FIS.DATA_EMISSAO               <= P_DATA_FINAL;
  218           
  219       
  220       
  221       
  222        
  223   
  224   CURSOR C_CONF_SEM_TIPO_SERV ( P_COD_EMPRESA VARCHAR2, 
  225                           P_COD_ESTAB VARCHAR2,
  226                           P_DATA_INICIAL  DATE,
  227                           P_DATA_FINAL  DATE) IS   
  228                     
  229           SELECT DOC_FIS.DATA_EMISSAO,
  230                  DOC_FIS.DATA_FISCAL,
  231                  DOC_FIS.IDENT_FIS_JUR,
  232                  DOC_FIS.IDENT_DOCTO,
  233                  DOC_FIS.NUM_DOCFIS,
  234                  DOC_FIS.SERIE_DOCFIS,
  235                  DOC_FIS.SUB_SERIE_DOCFIS,
  236                  NULL ,
  237                  DOC_FIS.COD_CLASS_DOC_FIS,
  238                  DOC_FIS.VLR_TOT_NOTA,
  239                  DOC_FIS.VLR_CONTAB_COMPL,
  240                  DWT_ITENS.VLR_BASE_INSS,
  241                  DWT_ITENS.VLR_ALIQ_INSS,
  242                  DWT_ITENS.VLR_INSS_RETIDO,
  243                  X2058.IND_TP_PROC_ADJ,
  244                  X2058.NUM_PROC_ADJ,
  245                  DWT_ITENS.NUM_ITEM,
  246                  DWT_ITENS.VLR_SERVICO, 
  247                  X2058_ADIC.IND_TP_PROC_ADJ,
  248                  X2058_ADIC.NUM_PROC_ADJ,
  249                  DWT_ITENS.IDENT_SERVICO,
  250                  NULL, 
  251                  NULL 
  252             FROM DWT_DOCTO_FISCAL DOC_FIS,
  253                  DWT_ITENS_SERV   DWT_ITENS,
  254                  X2058_PROC_ADJ X2058,
  255                  X2058_PROC_ADJ X2058_ADIC
  256            WHERE DOC_FIS.COD_EMPRESA            = DWT_ITENS.COD_EMPRESA
  257              AND DOC_FIS.COD_ESTAB              = DWT_ITENS.COD_ESTAB
  258              AND DOC_FIS.DATA_FISCAL            = DWT_ITENS.DATA_FISCAL
  259              AND DOC_FIS.IDENT_FIS_JUR          = DWT_ITENS.IDENT_FIS_JUR
  260              AND DOC_FIS.IDENT_DOCTO            = DWT_ITENS.IDENT_DOCTO
  261              AND DOC_FIS.NUM_DOCFIS             = DWT_ITENS.NUM_DOCFIS
  262              AND DOC_FIS.SERIE_DOCFIS           = DWT_ITENS.SERIE_DOCFIS
  263              AND DOC_FIS.SUB_SERIE_DOCFIS       = DWT_ITENS.SUB_SERIE_DOCFIS
  264              AND DWT_ITENS.IDENT_PROC_ADJ_PRINC = X2058.IDENT_PROC_ADJ (+)
  265              AND DWT_ITENS.IDENT_PROC_ADJ_ADIC  = X2058_ADIC.IDENT_PROC_ADJ (+)
  266              
  267              AND NOT EXISTS ( SELECT 1 
  268                                 FROM PRT_ID_TIPO_SERV_ESOCIAL A,
  269                                      X2018_SERVICOS X2018
  270                                WHERE A.COD_EMPRESA       = DWT_ITENS.COD_EMPRESA
  271                                  AND A.COD_ESTAB         = DWT_ITENS.COD_ESTAB
  272                                  AND X2018.IDENT_SERVICO = DWT_ITENS.IDENT_SERVICO 
  273                                  AND A.GRUPO_SERVICO     = X2018.GRUPO_SERVICO
  274                                  AND A.COD_SERVICO       = X2018.COD_SERVICO )
  275               
  276               AND NOT EXISTS ( SELECT 1 
  277                                 FROM PRT_SERV_MSAF A,
  278                                      X2018_SERVICOS X2018
  279                                WHERE A.COD_EMPRESA       = DWT_ITENS.COD_EMPRESA
  280                                  AND A.COD_ESTAB         = DWT_ITENS.COD_ESTAB
  281                                  AND X2018.IDENT_SERVICO = DWT_ITENS.IDENT_SERVICO 
  282                                  AND A.GRUPO_SERVICO     = X2018.GRUPO_SERVICO
  283                                  AND A.COD_SERVICO       = X2018.COD_SERVICO
  284                                  AND A.COD_PARAM IN (683,684,685,686,690) )                 
  285                                  
  286              AND DOC_FIS.DAT_CANCELAMENTO  IS NULL
  287              AND DOC_FIS.COD_CLASS_DOC_FIS IN ('2','3')
  288              AND DOC_FIS.NORM_DEV  = '1'
  289            
  290              AND ((DOC_FIS.MOVTO_E_S < '9' AND P_ENTRADA_SAIDA = 'E') OR (DOC_FIS.MOVTO_E_S = '9' AND P_ENTRADA_SAIDA = 'S'))  
  291              AND NVL(DWT_ITENS.VLR_INSS_RETIDO,0) > 0 
  292              AND DOC_FIS.SITUACAO = 'N'
  293              AND DOC_FIS.COD_EMPRESA  = P_COD_EMPRESA
  294              AND DOC_FIS.COD_ESTAB    = P_COD_ESTAB
  295              AND DOC_FIS.DATA_EMISSAO >= P_DATA_INICIAL
  296              AND DOC_FIS.DATA_EMISSAO <= P_DATA_FINAL
  297              
  298          UNION ALL SELECT DOC_FIS.DATA_EMISSAO,
  299                  DOC_FIS.DATA_FISCAL,
  300                  DOC_FIS.IDENT_FIS_JUR,
  301                  DOC_FIS.IDENT_DOCTO,
  302                  DOC_FIS.NUM_DOCFIS,
  303                  DOC_FIS.SERIE_DOCFIS,
  304                  DOC_FIS.SUB_SERIE_DOCFIS,
  305                  NULL,
  306                  DOC_FIS.COD_CLASS_DOC_FIS,
  307                  DOC_FIS.VLR_TOT_NOTA,
  308                  DOC_FIS.VLR_CONTAB_COMPL,
  309                  DWT_MERC.VLR_BASE_INSS,
  310                  DWT_MERC.VLR_ALIQ_INSS,
  311                  DWT_MERC.VLR_INSS_RETIDO,
  312                  X2058.IND_TP_PROC_ADJ,
  313                  X2058.NUM_PROC_ADJ,
  314                  DWT_MERC.NUM_ITEM, 
  315                  DWT_MERC.VLR_ITEM,
  316                  X2058_ADIC.IND_TP_PROC_ADJ,
  317                  X2058_ADIC.NUM_PROC_ADJ,
  318                  NULL, 
  319                  DWT_MERC.IDENT_PRODUTO,
  320                  NULL 
  321             FROM DWT_DOCTO_FISCAL DOC_FIS,
  322                  DWT_ITENS_MERC   DWT_MERC,
  323                  X2058_PROC_ADJ X2058,
  324                  X2058_PROC_ADJ X2058_ADIC,
  325                  X2024_MODELO_DOCTO X2024
  326            WHERE DOC_FIS.COD_EMPRESA        = DWT_MERC.COD_EMPRESA
  327              AND DOC_FIS.COD_ESTAB          = DWT_MERC.COD_ESTAB
  328              AND DOC_FIS.DATA_FISCAL        = DWT_MERC.DATA_FISCAL
  329              AND DOC_FIS.IDENT_FIS_JUR      = DWT_MERC.IDENT_FIS_JUR
  330              AND DOC_FIS.IDENT_DOCTO        = DWT_MERC.IDENT_DOCTO
  331              AND DOC_FIS.NUM_DOCFIS         = DWT_MERC.NUM_DOCFIS
  332              AND DOC_FIS.SERIE_DOCFIS       = DWT_MERC.SERIE_DOCFIS
  333              AND DOC_FIS.SUB_SERIE_DOCFIS   = DWT_MERC.SUB_SERIE_DOCFIS
  334              AND DOC_FIS.IDENT_MODELO       = X2024.IDENT_MODELO
  335              AND X2024.COD_MODELO IN ('07','67')
  336              AND DWT_MERC.IDENT_PROC_ADJ_PRINC = X2058.IDENT_PROC_ADJ (+)
  337              AND DWT_MERC.IDENT_PROC_ADJ_ADIC  = X2058_ADIC.IDENT_PROC_ADJ (+)
  338              AND NOT EXISTS ( SELECT 1 
  339                                 FROM PRT_ID_TIPO_SERV_PROD P,
  340                                      X2013_PRODUTO X2013
  341                                WHERE P.COD_EMPRESA       = DWT_MERC.COD_EMPRESA
  342                                  AND P.COD_ESTAB         = DWT_MERC.COD_ESTAB
  343                                  AND X2013.IDENT_PRODUTO = DWT_MERC.IDENT_PRODUTO
  344                                  AND P.GRUPO_PRODUTO     = X2013.GRUPO_PRODUTO
  345                                  AND P.COD_PRODUTO       = X2013.COD_PRODUTO
  346                                  AND P.IND_PRODUTO       = X2013.IND_PRODUTO )
  347              AND DOC_FIS.DAT_CANCELAMENTO  IS NULL
  348              AND DOC_FIS.COD_CLASS_DOC_FIS IN ('1','3')
  349              AND DOC_FIS.NORM_DEV  = '1'
  350            
  351              AND ((DOC_FIS.MOVTO_E_S < '9' AND P_ENTRADA_SAIDA = 'E') OR (DOC_FIS.MOVTO_E_S = '9' AND P_ENTRADA_SAIDA = 'S'))  
  352              AND NVL(DWT_MERC.VLR_INSS_RETIDO,0) > 0 
  353              AND DOC_FIS.SITUACAO = 'N'
  354              AND DOC_FIS.COD_EMPRESA = P_COD_EMPRESA
  355              AND DOC_FIS.COD_ESTAB   = P_COD_ESTAB
  356              AND DOC_FIS.DATA_EMISSAO >= P_DATA_INICIAL
  357              AND DOC_FIS.DATA_EMISSAO <= P_DATA_FINAL;     
  358              
  359 
  360 
  361   CURSOR C_CONF_RET_PREV_PROC ( P_COD_EMPRESA VARCHAR2, 
  362                                 P_COD_ESTAB VARCHAR2,
  363                                 P_DATA_INICIAL  DATE,
  364                                 P_DATA_FINAL  DATE) IS   
  365                     
  366           SELECT DISTINCT DOC_FIS.DATA_EMISSAO,
  367                  DOC_FIS.DATA_FISCAL,
  368                  DOC_FIS.IDENT_FIS_JUR,
  369                  DOC_FIS.IDENT_DOCTO,
  370                  DOC_FIS.NUM_DOCFIS,
  371                  DOC_FIS.SERIE_DOCFIS,
  372                  DOC_FIS.SUB_SERIE_DOCFIS,
  373                  NULL, 
  374                  DOC_FIS.COD_CLASS_DOC_FIS,
  375                  DOC_FIS.VLR_TOT_NOTA,
  376                  DOC_FIS.VLR_CONTAB_COMPL,
  377                  DWT_ITENS.VLR_BASE_INSS,
  378                  DWT_ITENS.VLR_ALIQ_INSS,
  379                  DWT_ITENS.VLR_INSS_RETIDO,
  380                  X2058.IND_TP_PROC_ADJ,
  381                  X2058.NUM_PROC_ADJ,
  382                  DWT_ITENS.NUM_ITEM,
  383                  DWT_ITENS.VLR_SERVICO,
  384                  X2058_ADIC.IND_TP_PROC_ADJ,
  385                  X2058_ADIC.NUM_PROC_ADJ,
  386                  DWT_ITENS.IDENT_SERVICO,
  387                  NULL, 
  388                  NULL 
  389             FROM DWT_DOCTO_FISCAL DOC_FIS,
  390                  DWT_ITENS_SERV   DWT_ITENS,
  391                  X2018_SERVICOS   X2018,
  392                  X2018_SERVICOS   X2018_ADIC,
  393                  
  394                  X2058_PROC_ADJ X2058,
  395                  X2058_PROC_ADJ X2058_ADIC
  396            WHERE DOC_FIS.COD_EMPRESA        = DWT_ITENS.COD_EMPRESA
  397              AND DOC_FIS.COD_ESTAB          = DWT_ITENS.COD_ESTAB
  398              AND DOC_FIS.DATA_FISCAL        = DWT_ITENS.DATA_FISCAL
  399              AND DOC_FIS.IDENT_FIS_JUR      = DWT_ITENS.IDENT_FIS_JUR
  400              AND DOC_FIS.IDENT_DOCTO        = DWT_ITENS.IDENT_DOCTO
  401              AND DOC_FIS.NUM_DOCFIS         = DWT_ITENS.NUM_DOCFIS
  402              AND DOC_FIS.SERIE_DOCFIS       = DWT_ITENS.SERIE_DOCFIS
  403              AND DOC_FIS.SUB_SERIE_DOCFIS   = DWT_ITENS.SUB_SERIE_DOCFIS
  404              AND DWT_ITENS.IDENT_PROC_ADJ_PRINC = X2058.IDENT_PROC_ADJ (+)
  405              AND DWT_ITENS.IDENT_PROC_ADJ_ADIC  = X2058_ADIC.IDENT_PROC_ADJ (+)
  406              
  407            
  408 
  409              AND DWT_ITENS.IDENT_SERVICO    = X2018.IDENT_SERVICO
  410             
  411 
  412              
  413              AND DOC_FIS.DAT_CANCELAMENTO  IS NULL
  414              AND DOC_FIS.COD_CLASS_DOC_FIS IN ('2','3')
  415              AND DOC_FIS.NORM_DEV  = '1'
  416            
  417              AND ((DOC_FIS.MOVTO_E_S < '9' AND P_ENTRADA_SAIDA = 'E') OR (DOC_FIS.MOVTO_E_S = '9' AND P_ENTRADA_SAIDA = 'S'))  
  418              
  419              AND (X2058.NUM_PROC_ADJ IS NOT NULL OR  X2058_ADIC.NUM_PROC_ADJ IS NOT NULL)
  420              AND NVL(DWT_ITENS.VLR_INSS_RETIDO, 0) > 0 
  421              AND DOC_FIS.SITUACAO = 'N'
  422              AND DOC_FIS.COD_EMPRESA = P_COD_EMPRESA
  423              AND DOC_FIS.COD_ESTAB   = P_COD_ESTAB
  424              AND DOC_FIS.DATA_EMISSAO >= P_DATA_INICIAL
  425              AND DOC_FIS.DATA_EMISSAO <= P_DATA_FINAL     
  426              
  427      UNION ALL SELECT DOC_FIS.DATA_EMISSAO,
  428                  DOC_FIS.DATA_FISCAL,
  429                  DOC_FIS.IDENT_FIS_JUR,
  430                  DOC_FIS.IDENT_DOCTO,
  431                  DOC_FIS.NUM_DOCFIS,
  432                  DOC_FIS.SERIE_DOCFIS,
  433                  DOC_FIS.SUB_SERIE_DOCFIS,
  434                  NULL, 
  435                  DOC_FIS.COD_CLASS_DOC_FIS,
  436                  DOC_FIS.VLR_TOT_NOTA,
  437                  DOC_FIS.VLR_CONTAB_COMPL,
  438                  DWT_MERC.VLR_BASE_INSS,
  439                  DWT_MERC.VLR_ALIQ_INSS,
  440                  DWT_MERC.VLR_INSS_RETIDO,
  441                  X2058.IND_TP_PROC_ADJ,
  442                  X2058.NUM_PROC_ADJ,
  443                  DWT_MERC.NUM_ITEM, 
  444                  DWT_MERC.VLR_ITEM,
  445                  X2058_ADIC.IND_TP_PROC_ADJ,
  446                  X2058_ADIC.NUM_PROC_ADJ,
  447                  NULL,
  448                  DWT_MERC.IDENT_PRODUTO,
  449                  NULL 
  450             FROM DWT_DOCTO_FISCAL DOC_FIS,
  451                  DWT_ITENS_MERC   DWT_MERC,
  452                  X2013_PRODUTO   X2013,
  453                 
  454                  X2058_PROC_ADJ X2058,
  455                  X2058_PROC_ADJ X2058_ADIC,
  456                  X2024_MODELO_DOCTO X2024
  457            WHERE DOC_FIS.COD_EMPRESA        = DWT_MERC.COD_EMPRESA
  458              AND DOC_FIS.COD_ESTAB          = DWT_MERC.COD_ESTAB
  459              AND DOC_FIS.DATA_FISCAL        = DWT_MERC.DATA_FISCAL
  460              AND DOC_FIS.IDENT_FIS_JUR      = DWT_MERC.IDENT_FIS_JUR
  461              AND DOC_FIS.IDENT_DOCTO        = DWT_MERC.IDENT_DOCTO
  462              AND DOC_FIS.NUM_DOCFIS         = DWT_MERC.NUM_DOCFIS
  463              AND DOC_FIS.SERIE_DOCFIS       = DWT_MERC.SERIE_DOCFIS
  464              AND DOC_FIS.SUB_SERIE_DOCFIS   = DWT_MERC.SUB_SERIE_DOCFIS
  465              AND DOC_FIS.IDENT_MODELO       = X2024.IDENT_MODELO
  466              AND X2024.COD_MODELO IN ('07','67')
  467              AND DWT_MERC.IDENT_PROC_ADJ_PRINC = X2058.IDENT_PROC_ADJ (+)
  468              AND  DWT_MERC.IDENT_PROC_ADJ_ADIC  = X2058_ADIC.IDENT_PROC_ADJ (+)
  469              AND DWT_MERC.IDENT_PRODUTO    = X2013.IDENT_PRODUTO
  470             
  471 
  472 
  473 
  474 
  475              AND DOC_FIS.DAT_CANCELAMENTO  IS NULL
  476              AND DOC_FIS.COD_CLASS_DOC_FIS IN ('1','3')
  477              AND DOC_FIS.NORM_DEV  = '1'
  478            
  479              AND ((DOC_FIS.MOVTO_E_S < '9' AND P_ENTRADA_SAIDA = 'E') OR (DOC_FIS.MOVTO_E_S = '9' AND P_ENTRADA_SAIDA = 'S'))  
  480              AND (X2058.NUM_PROC_ADJ IS NOT NULL OR  X2058_ADIC.NUM_PROC_ADJ IS NOT NULL)
  481              AND NVL(DWT_MERC.VLR_INSS_RETIDO,0) > 0 
  482              AND DOC_FIS.SITUACAO = 'N'
  483              AND DOC_FIS.COD_EMPRESA = P_COD_EMPRESA
  484              AND DOC_FIS.COD_ESTAB   = P_COD_ESTAB
  485              AND DOC_FIS.DATA_EMISSAO >= P_DATA_INICIAL
  486              AND DOC_FIS.DATA_EMISSAO <= P_DATA_FINAL; 
  487              
  488              
  489                        
  490 
  491   CURSOR C_CONF_RET_PREV_SEM_PROC ( P_COD_EMPRESA VARCHAR2, 
  492                                     P_COD_ESTAB VARCHAR2,
  493                                     P_DATA_INICIAL  DATE,
  494                                     P_DATA_FINAL  DATE) IS   
  495                     
  496           SELECT DOC_FIS.DATA_EMISSAO,
  497                  DOC_FIS.DATA_FISCAL,
  498                  DOC_FIS.IDENT_FIS_JUR,
  499                  DOC_FIS.IDENT_DOCTO,
  500                  DOC_FIS.NUM_DOCFIS,
  501                  DOC_FIS.SERIE_DOCFIS,
  502                  DOC_FIS.SUB_SERIE_DOCFIS,
  503                  NULL, 
  504                  DOC_FIS.COD_CLASS_DOC_FIS,
  505                  DOC_FIS.VLR_TOT_NOTA,
  506                  DOC_FIS.VLR_CONTAB_COMPL,
  507                  DWT_ITENS.VLR_BASE_INSS,
  508                  DWT_ITENS.VLR_ALIQ_INSS,
  509                  DWT_ITENS.VLR_INSS_RETIDO,
  510                  DWT_ITENS.IND_TP_PROC_ADJ_PRINC,
  511                  NULL, 
  512                  DWT_ITENS.NUM_ITEM,
  513                  DWT_ITENS.VLR_SERVICO,
  514                  DWT_ITENS.IND_TP_PROC_ADJ_PRINC,
  515                  NULL, 
  516                  DWT_ITENS.IDENT_SERVICO,
  517                  NULL,  
  518                  NULL 
  519             FROM DWT_DOCTO_FISCAL DOC_FIS,
  520                  DWT_ITENS_SERV   DWT_ITENS,
  521                  X2018_SERVICOS   X2018
  522 
  523                  
  524            WHERE DOC_FIS.COD_EMPRESA        = DWT_ITENS.COD_EMPRESA
  525              AND DOC_FIS.COD_ESTAB          = DWT_ITENS.COD_ESTAB
  526              AND DOC_FIS.DATA_FISCAL        = DWT_ITENS.DATA_FISCAL
  527              AND DOC_FIS.IDENT_FIS_JUR      = DWT_ITENS.IDENT_FIS_JUR
  528              AND DOC_FIS.IDENT_DOCTO        = DWT_ITENS.IDENT_DOCTO
  529              AND DOC_FIS.NUM_DOCFIS         = DWT_ITENS.NUM_DOCFIS
  530              AND DOC_FIS.SERIE_DOCFIS       = DWT_ITENS.SERIE_DOCFIS
  531              AND DOC_FIS.SUB_SERIE_DOCFIS   = DWT_ITENS.SUB_SERIE_DOCFIS
  532              
  533             
  534 
  535              AND DWT_ITENS.IDENT_SERVICO    = X2018.IDENT_SERVICO
  536              
  537 
  538            
  539              AND DOC_FIS.DAT_CANCELAMENTO  IS NULL
  540              AND DOC_FIS.COD_CLASS_DOC_FIS IN ('2','3')
  541              AND DOC_FIS.NORM_DEV  = '1'
  542            
  543              AND ((DOC_FIS.MOVTO_E_S < '9' AND P_ENTRADA_SAIDA = 'E') OR (DOC_FIS.MOVTO_E_S = '9' AND P_ENTRADA_SAIDA = 'S'))  
  544              
  545              AND DWT_ITENS.IDENT_PROC_ADJ_PRINC IS NULL
  546              AND NVL(DWT_ITENS.VLR_INSS_RETIDO,0) = 0 
  547              AND DOC_FIS.SITUACAO = 'N'
  548              AND DOC_FIS.COD_EMPRESA = P_COD_EMPRESA
  549              AND DOC_FIS.COD_ESTAB   = P_COD_ESTAB
  550              AND DOC_FIS.DATA_EMISSAO >= P_DATA_INICIAL
  551              AND DOC_FIS.DATA_EMISSAO <= P_DATA_FINAL 
  552       
  553 UNION ALL SELECT DOC_FIS.DATA_EMISSAO,
  554                  DOC_FIS.DATA_FISCAL,
  555                  DOC_FIS.IDENT_FIS_JUR,
  556                  DOC_FIS.IDENT_DOCTO,
  557                  DOC_FIS.NUM_DOCFIS,
  558                  DOC_FIS.SERIE_DOCFIS,
  559                  DOC_FIS.SUB_SERIE_DOCFIS,
  560                  NULL, 
  561                  DOC_FIS.COD_CLASS_DOC_FIS,
  562                  DOC_FIS.VLR_TOT_NOTA,
  563                  DOC_FIS.VLR_CONTAB_COMPL,
  564                  DWT_MERC.VLR_BASE_INSS,
  565                  DWT_MERC.VLR_ALIQ_INSS,
  566                  DWT_MERC.VLR_INSS_RETIDO,
  567                  DWT_MERC.IND_TP_PROC_ADJ_PRINC,
  568                  NULL, 
  569                  DWT_MERC.NUM_ITEM, 
  570                  DWT_MERC.VLR_ITEM,
  571                  DWT_MERC.IND_TP_PROC_ADJ_PRINC,
  572                  NULL, 
  573                  NULL, 
  574                  DWT_MERC.IDENT_PRODUTO,
  575                  NULL 
  576             FROM DWT_DOCTO_FISCAL DOC_FIS,
  577                  DWT_ITENS_MERC   DWT_MERC,
  578                  X2013_PRODUTO   X2013,
  579                 
  580                  X2024_MODELO_DOCTO X2024
  581                  
  582            WHERE DOC_FIS.COD_EMPRESA        = DWT_MERC.COD_EMPRESA
  583              AND DOC_FIS.COD_ESTAB          = DWT_MERC.COD_ESTAB
  584              AND DOC_FIS.DATA_FISCAL        = DWT_MERC.DATA_FISCAL
  585              AND DOC_FIS.IDENT_FIS_JUR      = DWT_MERC.IDENT_FIS_JUR
  586              AND DOC_FIS.IDENT_DOCTO        = DWT_MERC.IDENT_DOCTO
  587              AND DOC_FIS.NUM_DOCFIS         = DWT_MERC.NUM_DOCFIS
  588              AND DOC_FIS.SERIE_DOCFIS       = DWT_MERC.SERIE_DOCFIS
  589              AND DOC_FIS.SUB_SERIE_DOCFIS   = DWT_MERC.SUB_SERIE_DOCFIS
  590              AND DOC_FIS.IDENT_MODELO       = X2024.IDENT_MODELO
  591              AND X2024.COD_MODELO IN ('07','67')
  592              
  593    
  594 
  595              AND DWT_MERC.IDENT_PRODUTO    = X2013.IDENT_PRODUTO
  596          
  597 
  598 
  599              
  600              
  601 
  602 
  603 
  604 
  605              
  606              
  607              AND DOC_FIS.DAT_CANCELAMENTO  IS NULL
  608              AND DOC_FIS.COD_CLASS_DOC_FIS IN ('1','3')
  609              AND DOC_FIS.NORM_DEV  = '1'
  610            
  611              AND ((DOC_FIS.MOVTO_E_S < '9' AND P_ENTRADA_SAIDA = 'E') OR (DOC_FIS.MOVTO_E_S = '9' AND P_ENTRADA_SAIDA = 'S'))  
  612              AND DWT_MERC.IDENT_PROC_ADJ_PRINC IS NULL
  613              AND NVL(DWT_MERC.VLR_INSS_RETIDO,0) = 0 
  614              AND DOC_FIS.SITUACAO = 'N'
  615              AND DOC_FIS.COD_EMPRESA = P_COD_EMPRESA
  616              AND DOC_FIS.COD_ESTAB   = P_COD_ESTAB
  617              AND DOC_FIS.DATA_EMISSAO >= P_DATA_INICIAL
  618              AND DOC_FIS.DATA_EMISSAO <= P_DATA_FINAL;             
  619              
  620    
  621    
  622    CURSOR C_CONF_INSS_MAIOR_BRUTO (P_COD_EMPRESA VARCHAR2, 
  623                            P_COD_ESTAB VARCHAR2,
  624                            P_DATA_INICIAL  DATE,
  625                            P_DATA_FINAL  DATE) IS
  626           
  627           SELECT DOC_FIS.DATA_EMISSAO
  628                 ,DOC_FIS.DATA_FISCAL
  629                 ,DOC_FIS.IDENT_FIS_JUR
  630                 ,DOC_FIS.IDENT_DOCTO
  631                 ,DOC_FIS.NUM_DOCFIS
  632                 ,DOC_FIS.SERIE_DOCFIS
  633                 ,DOC_FIS.SUB_SERIE_DOCFIS
  634                 ,TIPO_SERV.IDENT_TIPO_SERV_ESOCIAL
  635                 ,DOC_FIS.COD_CLASS_DOC_FIS
  636                 ,DOC_FIS.VLR_TOT_NOTA
  637                 ,DOC_FIS.VLR_CONTAB_COMPL
  638                 ,DWT_ITENS.VLR_BASE_INSS
  639                 ,DWT_ITENS.VLR_ALIQ_INSS
  640                 ,DWT_ITENS.VLR_INSS_RETIDO
  641                 ,X2058.IND_TP_PROC_ADJ
  642                 ,X2058.NUM_PROC_ADJ
  643                 ,DWT_ITENS.NUM_ITEM
  644                 ,DWT_ITENS.VLR_SERVICO
  645                 ,X2058_ADIC.IND_TP_PROC_ADJ
  646                 ,X2058_ADIC.NUM_PROC_ADJ
  647                 ,DWT_ITENS.IDENT_SERVICO
  648                 , NULL 
  649                 , NULL 
  650           FROM   DWT_DOCTO_FISCAL         DOC_FIS
  651                 ,DWT_ITENS_SERV           DWT_ITENS
  652                 ,X2018_SERVICOS           X2018
  653                 ,PRT_ID_TIPO_SERV_ESOCIAL ID_TIPO_SERV
  654                 ,PRT_TIPO_SERV_ESOCIAL    TIPO_SERV
  655                 ,X2058_PROC_ADJ           X2058
  656                 ,X2058_PROC_ADJ           X2058_ADIC
  657           WHERE  DOC_FIS.COD_EMPRESA                =  DWT_ITENS.COD_EMPRESA
  658           AND    DOC_FIS.COD_ESTAB                  =  DWT_ITENS.COD_ESTAB
  659           AND    DOC_FIS.DATA_FISCAL                =  DWT_ITENS.DATA_FISCAL
  660           AND    DOC_FIS.IDENT_FIS_JUR              =  DWT_ITENS.IDENT_FIS_JUR
  661           AND    DOC_FIS.IDENT_DOCTO                =  DWT_ITENS.IDENT_DOCTO
  662           AND    DOC_FIS.NUM_DOCFIS                 =  DWT_ITENS.NUM_DOCFIS
  663           AND    DOC_FIS.SERIE_DOCFIS               =  DWT_ITENS.SERIE_DOCFIS
  664           AND    DOC_FIS.SUB_SERIE_DOCFIS           =  DWT_ITENS.SUB_SERIE_DOCFIS
  665           AND    DWT_ITENS.IDENT_PROC_ADJ_PRINC     =  X2058.IDENT_PROC_ADJ(+)
  666           AND    DWT_ITENS.IDENT_PROC_ADJ_ADIC      =  X2058_ADIC.IDENT_PROC_ADJ(+)
  667           AND    ID_TIPO_SERV.COD_EMPRESA           =  DOC_FIS.COD_EMPRESA
  668           AND    ID_TIPO_SERV.COD_ESTAB             =  DOC_FIS.COD_ESTAB
  669           AND    DWT_ITENS.IDENT_SERVICO            =  X2018.IDENT_SERVICO
  670           AND    X2018.GRUPO_SERVICO                =  ID_TIPO_SERV.GRUPO_SERVICO
  671           AND    X2018.COD_SERVICO                  =  ID_TIPO_SERV.COD_SERVICO
  672           AND    ID_TIPO_SERV.COD_TIPO_SERV_ESOCIAL =  TIPO_SERV.COD_TIPO_SERV_ESOCIAL
  673           AND    TIPO_SERV.DATA_INI_VIGENCIA        =  (SELECT MAX(A.DATA_INI_VIGENCIA)
  674                                                         FROM   PRT_TIPO_SERV_ESOCIAL A
  675                                                         WHERE  A.COD_TIPO_SERV_ESOCIAL  = TIPO_SERV.COD_TIPO_SERV_ESOCIAL
  676                                                         AND    A.DATA_INI_VIGENCIA     <= P_DATA_FINAL)
  677           AND    DOC_FIS.DAT_CANCELAMENTO           IS NULL
  678           AND    DOC_FIS.COD_CLASS_DOC_FIS          IN ('2', '3')
  679           AND    DOC_FIS.NORM_DEV                    =  '1'
  680         
  681           AND  ((DOC_FIS.MOVTO_E_S < '9' AND P_ENTRADA_SAIDA = 'E') OR (DOC_FIS.MOVTO_E_S = '9' AND P_ENTRADA_SAIDA = 'S'))         
  682           AND    NVL(DWT_ITENS.VLR_INSS_RETIDO, 0)   >  0
  683           AND    DOC_FIS.SITUACAO = 'N'          
  684           AND    DWT_ITENS.VLR_BASE_INSS >  DOC_FIS.VLR_TOT_NOTA  
  685           AND    DOC_FIS.COD_EMPRESA                 =  P_COD_EMPRESA
  686           AND    DOC_FIS.COD_ESTAB                   =  P_COD_ESTAB
  687           AND    DOC_FIS.DATA_EMISSAO               >= P_DATA_INICIAL
  688           AND    DOC_FIS.DATA_EMISSAO               <= P_DATA_FINAL
  689           
  690           UNION ALL
  691           SELECT DOC_FIS.DATA_EMISSAO
  692                 ,DOC_FIS.DATA_FISCAL
  693                 ,DOC_FIS.IDENT_FIS_JUR
  694                 ,DOC_FIS.IDENT_DOCTO
  695                 ,DOC_FIS.NUM_DOCFIS
  696                 ,DOC_FIS.SERIE_DOCFIS
  697                 ,DOC_FIS.SUB_SERIE_DOCFIS
  698                 ,NULL 
  699                 ,DOC_FIS.COD_CLASS_DOC_FIS
  700                 ,DOC_FIS.VLR_TOT_NOTA
  701                 ,DOC_FIS.VLR_CONTAB_COMPL
  702                 ,DWT_ITENS.VLR_BASE_INSS
  703                 ,DWT_ITENS.VLR_ALIQ_INSS
  704                 ,DWT_ITENS.VLR_INSS_RETIDO
  705                 ,X2058.IND_TP_PROC_ADJ
  706                 ,X2058.NUM_PROC_ADJ
  707                 ,DWT_ITENS.NUM_ITEM
  708                 ,DWT_ITENS.VLR_SERVICO
  709                 ,X2058_ADIC.IND_TP_PROC_ADJ
  710                 ,X2058_ADIC.NUM_PROC_ADJ
  711                 ,DWT_ITENS.IDENT_SERVICO
  712                 ,NULL 
  713                 ,PRT_PAR2_MSAF.COD_PARAM 
  714           FROM   DWT_DOCTO_FISCAL         DOC_FIS
  715                 ,DWT_ITENS_SERV           DWT_ITENS
  716                 ,X2018_SERVICOS           X2018
  717                 ,PRT_SERV_MSAF
  718                 ,PRT_PAR2_MSAF
  719                 ,X2058_PROC_ADJ           X2058
  720                 ,X2058_PROC_ADJ           X2058_ADIC
  721           WHERE  DOC_FIS.COD_EMPRESA                =  DWT_ITENS.COD_EMPRESA
  722           AND    DOC_FIS.COD_ESTAB                  =  DWT_ITENS.COD_ESTAB
  723           AND    DOC_FIS.DATA_FISCAL                =  DWT_ITENS.DATA_FISCAL
  724           AND    DOC_FIS.IDENT_FIS_JUR              =  DWT_ITENS.IDENT_FIS_JUR
  725           AND    DOC_FIS.IDENT_DOCTO                =  DWT_ITENS.IDENT_DOCTO
  726           AND    DOC_FIS.NUM_DOCFIS                 =  DWT_ITENS.NUM_DOCFIS
  727           AND    DOC_FIS.SERIE_DOCFIS               =  DWT_ITENS.SERIE_DOCFIS
  728           AND    DOC_FIS.SUB_SERIE_DOCFIS           =  DWT_ITENS.SUB_SERIE_DOCFIS
  729           AND    DWT_ITENS.IDENT_PROC_ADJ_PRINC     =  X2058.IDENT_PROC_ADJ(+)
  730           AND    DWT_ITENS.IDENT_PROC_ADJ_ADIC      =  X2058_ADIC.IDENT_PROC_ADJ(+)
  731           
  732           
  733           AND    PRT_SERV_MSAF.COD_EMPRESA           =  DOC_FIS.COD_EMPRESA
  734           AND    PRT_SERV_MSAF.COD_ESTAB             =  DOC_FIS.COD_ESTAB
  735           AND    DWT_ITENS.IDENT_SERVICO            =  X2018.IDENT_SERVICO
  736           AND    X2018.GRUPO_SERVICO                =  PRT_SERV_MSAF.GRUPO_SERVICO
  737           AND    X2018.COD_SERVICO                  =  PRT_SERV_MSAF.COD_SERVICO
  738           AND    PRT_SERV_MSAF.COD_PARAM            =  PRT_PAR2_MSAF.COD_PARAM
  739           AND    PRT_SERV_MSAF.COD_PARAM IN (683,684,685,686,690)
  740           
  741                                                         
  742           AND    DOC_FIS.DAT_CANCELAMENTO           IS NULL
  743           AND    DOC_FIS.COD_CLASS_DOC_FIS          IN ('2', '3')
  744           AND    DOC_FIS.NORM_DEV                    =  '1'
  745         
  746           AND  ((DOC_FIS.MOVTO_E_S < '9' AND P_ENTRADA_SAIDA = 'E') OR (DOC_FIS.MOVTO_E_S = '9' AND P_ENTRADA_SAIDA = 'S'))         
  747           AND    NVL(DWT_ITENS.VLR_INSS_RETIDO, 0)   >  0
  748           AND    DOC_FIS.SITUACAO = 'N'          
  749           AND    DWT_ITENS.VLR_BASE_INSS >  DOC_FIS.VLR_TOT_NOTA  
  750           AND    DOC_FIS.COD_EMPRESA                 =  P_COD_EMPRESA
  751           AND    DOC_FIS.COD_ESTAB                   =  P_COD_ESTAB
  752           AND    DOC_FIS.DATA_EMISSAO               >= P_DATA_INICIAL
  753           AND    DOC_FIS.DATA_EMISSAO               <= P_DATA_FINAL
  754           
  755           UNION  ALL 
  756           SELECT DOC_FIS.DATA_EMISSAO
  757                 ,DOC_FIS.DATA_FISCAL
  758                 ,DOC_FIS.IDENT_FIS_JUR
  759                 ,DOC_FIS.IDENT_DOCTO
  760                 ,DOC_FIS.NUM_DOCFIS
  761                 ,DOC_FIS.SERIE_DOCFIS
  762                 ,DOC_FIS.SUB_SERIE_DOCFIS
  763                 ,TIPO_SERV.IDENT_TIPO_SERV_ESOCIAL
  764                 ,DOC_FIS.COD_CLASS_DOC_FIS
  765                 ,DOC_FIS.VLR_TOT_NOTA
  766                 ,DOC_FIS.VLR_CONTAB_COMPL
  767                 ,DWT_MERC.VLR_BASE_INSS
  768                 ,DWT_MERC.VLR_ALIQ_INSS
  769                 ,DWT_MERC.VLR_INSS_RETIDO
  770                 ,X2058.IND_TP_PROC_ADJ
  771                 ,X2058.NUM_PROC_ADJ
  772                 ,DWT_MERC.NUM_ITEM
  773                 ,DWT_MERC.VLR_ITEM
  774                 ,X2058_ADIC.IND_TP_PROC_ADJ
  775                 ,X2058_ADIC.NUM_PROC_ADJ
  776                 ,NULL 
  777                 ,DWT_MERC.IDENT_PRODUTO
  778                 ,NULL 
  779           FROM   DWT_DOCTO_FISCAL      DOC_FIS
  780                 ,DWT_ITENS_MERC        DWT_MERC
  781                 ,X2013_PRODUTO         X2013
  782                 ,PRT_ID_TIPO_SERV_PROD ID_TIPO_SERV
  783                 ,PRT_TIPO_SERV_ESOCIAL TIPO_SERV
  784                 ,X2058_PROC_ADJ        X2058
  785                 ,X2058_PROC_ADJ        X2058_ADIC
  786                 ,X2024_MODELO_DOCTO    X2024
  787           WHERE  DOC_FIS.COD_EMPRESA                 = DWT_MERC.COD_EMPRESA
  788           AND    DOC_FIS.COD_ESTAB                   = DWT_MERC.COD_ESTAB
  789           AND    DOC_FIS.DATA_FISCAL                 = DWT_MERC.DATA_FISCAL
  790           AND    DOC_FIS.IDENT_FIS_JUR               = DWT_MERC.IDENT_FIS_JUR
  791           AND    DOC_FIS.IDENT_DOCTO                 = DWT_MERC.IDENT_DOCTO
  792           AND    DOC_FIS.NUM_DOCFIS                  = DWT_MERC.NUM_DOCFIS
  793           AND    DOC_FIS.SERIE_DOCFIS                = DWT_MERC.SERIE_DOCFIS
  794           AND    DOC_FIS.SUB_SERIE_DOCFIS            = DWT_MERC.SUB_SERIE_DOCFIS
  795           AND    DOC_FIS.IDENT_MODELO                = X2024.IDENT_MODELO
  796           AND    X2024.COD_MODELO                   IN ('07', '67')
  797           AND    DWT_MERC.IDENT_PROC_ADJ_PRINC       = X2058.IDENT_PROC_ADJ(+)
  798           AND    DWT_MERC.IDENT_PROC_ADJ_ADIC        = X2058_ADIC.IDENT_PROC_ADJ(+)
  799           AND    ID_TIPO_SERV.COD_EMPRESA            = DOC_FIS.COD_EMPRESA
  800           AND    ID_TIPO_SERV.COD_ESTAB              = DOC_FIS.COD_ESTAB
  801           AND    DWT_MERC.IDENT_PRODUTO              = X2013.IDENT_PRODUTO                
  802           AND    ID_TIPO_SERV.GRUPO_PRODUTO          = X2013.GRUPO_PRODUTO
  803           AND    ID_TIPO_SERV.COD_PRODUTO            = X2013.COD_PRODUTO
  804           AND    ID_TIPO_SERV.IND_PRODUTO            = X2013.IND_PRODUTO                
  805           AND    ID_TIPO_SERV.COD_TIPO_SERV_ESOCIAL  = TIPO_SERV.COD_TIPO_SERV_ESOCIAL
  806           AND    TIPO_SERV.DATA_INI_VIGENCIA         = (SELECT MAX(A.DATA_INI_VIGENCIA)
  807                                                         FROM   PRT_TIPO_SERV_ESOCIAL A
  808                                                         WHERE  A.COD_TIPO_SERV_ESOCIAL =
  809                                                                TIPO_SERV.COD_TIPO_SERV_ESOCIAL 
  810                                                         AND    A.DATA_INI_VIGENCIA <= P_DATA_FINAL)                
  811           AND    DOC_FIS.DAT_CANCELAMENTO           IS NULL
  812           AND    DOC_FIS.COD_CLASS_DOC_FIS          IN ('1', '3')
  813           AND    DOC_FIS.NORM_DEV                    = '1'
  814         
  815           AND  ((DOC_FIS.MOVTO_E_S < '9' AND P_ENTRADA_SAIDA = 'E') OR (DOC_FIS.MOVTO_E_S = '9' AND P_ENTRADA_SAIDA = 'S'))  
  816           AND    NVL(DWT_MERC.VLR_INSS_RETIDO, 0)    > 0
  817           AND    DOC_FIS.SITUACAO = 'N'
  818           AND    DWT_MERC.VLR_BASE_INSS >  DOC_FIS.VLR_TOT_NOTA  
  819           AND    DOC_FIS.COD_EMPRESA                 = P_COD_EMPRESA
  820           AND    DOC_FIS.COD_ESTAB                   = P_COD_ESTAB
  821           AND    DOC_FIS.DATA_EMISSAO               >= P_DATA_INICIAL
  822           AND    DOC_FIS.DATA_EMISSAO               <= P_DATA_FINAL;
  823           
  824           
  825           
  826           
  827    
  828    CURSOR C_CONF_INSS_ALIQ_DIF_INFORMADO (P_COD_EMPRESA VARCHAR2, 
  829                            P_COD_ESTAB VARCHAR2,
  830                            P_DATA_INICIAL  DATE,
  831                            P_DATA_FINAL  DATE) IS
  832           SELECT DOC_FIS.DATA_EMISSAO
  833                 ,DOC_FIS.DATA_FISCAL
  834                 ,DOC_FIS.IDENT_FIS_JUR
  835                 ,DOC_FIS.IDENT_DOCTO
  836                 ,DOC_FIS.NUM_DOCFIS
  837                 ,DOC_FIS.SERIE_DOCFIS
  838                 ,DOC_FIS.SUB_SERIE_DOCFIS
  839                 ,TIPO_SERV.IDENT_TIPO_SERV_ESOCIAL
  840                 ,DOC_FIS.COD_CLASS_DOC_FIS
  841                 ,DOC_FIS.VLR_TOT_NOTA
  842                 ,DOC_FIS.VLR_CONTAB_COMPL
  843                 ,DWT_ITENS.VLR_BASE_INSS
  844                 ,DWT_ITENS.VLR_ALIQ_INSS
  845                 ,DWT_ITENS.VLR_INSS_RETIDO
  846                 ,X2058.IND_TP_PROC_ADJ
  847                 ,X2058.NUM_PROC_ADJ
  848                 ,DWT_ITENS.NUM_ITEM
  849                 ,DWT_ITENS.VLR_SERVICO
  850                 ,X2058_ADIC.IND_TP_PROC_ADJ
  851                 ,X2058_ADIC.NUM_PROC_ADJ
  852                 ,DWT_ITENS.IDENT_SERVICO
  853                 , NULL 
  854                 , NULL 
  855           FROM   DWT_DOCTO_FISCAL         DOC_FIS
  856                 ,DWT_ITENS_SERV           DWT_ITENS
  857                 ,X2018_SERVICOS           X2018
  858                 ,PRT_ID_TIPO_SERV_ESOCIAL ID_TIPO_SERV
  859                 ,PRT_TIPO_SERV_ESOCIAL    TIPO_SERV
  860                 ,X2058_PROC_ADJ           X2058
  861                 ,X2058_PROC_ADJ           X2058_ADIC
  862           WHERE  DOC_FIS.COD_EMPRESA                =  DWT_ITENS.COD_EMPRESA
  863           AND    DOC_FIS.COD_ESTAB                  =  DWT_ITENS.COD_ESTAB
  864           AND    DOC_FIS.DATA_FISCAL                =  DWT_ITENS.DATA_FISCAL
  865           AND    DOC_FIS.IDENT_FIS_JUR              =  DWT_ITENS.IDENT_FIS_JUR
  866           AND    DOC_FIS.IDENT_DOCTO                =  DWT_ITENS.IDENT_DOCTO
  867           AND    DOC_FIS.NUM_DOCFIS                 =  DWT_ITENS.NUM_DOCFIS
  868           AND    DOC_FIS.SERIE_DOCFIS               =  DWT_ITENS.SERIE_DOCFIS
  869           AND    DOC_FIS.SUB_SERIE_DOCFIS           =  DWT_ITENS.SUB_SERIE_DOCFIS
  870           AND    DWT_ITENS.IDENT_PROC_ADJ_PRINC     =  X2058.IDENT_PROC_ADJ(+)
  871           AND    DWT_ITENS.IDENT_PROC_ADJ_ADIC      =  X2058_ADIC.IDENT_PROC_ADJ(+)
  872           AND    ID_TIPO_SERV.COD_EMPRESA           =  DOC_FIS.COD_EMPRESA
  873           AND    ID_TIPO_SERV.COD_ESTAB             =  DOC_FIS.COD_ESTAB
  874           AND    DWT_ITENS.IDENT_SERVICO            =  X2018.IDENT_SERVICO
  875           AND    X2018.GRUPO_SERVICO                =  ID_TIPO_SERV.GRUPO_SERVICO
  876           AND    X2018.COD_SERVICO                  =  ID_TIPO_SERV.COD_SERVICO
  877           AND    ID_TIPO_SERV.COD_TIPO_SERV_ESOCIAL =  TIPO_SERV.COD_TIPO_SERV_ESOCIAL
  878           AND    TIPO_SERV.DATA_INI_VIGENCIA        =  (SELECT MAX(A.DATA_INI_VIGENCIA)
  879                                                         FROM   PRT_TIPO_SERV_ESOCIAL A
  880                                                         WHERE  A.COD_TIPO_SERV_ESOCIAL  = TIPO_SERV.COD_TIPO_SERV_ESOCIAL
  881                                                         AND    A.DATA_INI_VIGENCIA     <= P_DATA_FINAL)
  882           AND    DOC_FIS.DAT_CANCELAMENTO           IS NULL
  883           AND    DOC_FIS.COD_CLASS_DOC_FIS          IN ('2', '3')
  884           AND    DOC_FIS.NORM_DEV                    =  '1'
  885         
  886           AND  ((DOC_FIS.MOVTO_E_S < '9' AND P_ENTRADA_SAIDA = 'E') OR (DOC_FIS.MOVTO_E_S = '9' AND P_ENTRADA_SAIDA = 'S'))         
  887           AND    NVL(DWT_ITENS.VLR_INSS_RETIDO, 0)   >  0
  888           AND    DOC_FIS.SITUACAO = 'N'
  889           AND    ROUND((DWT_ITENS.VLR_BASE_INSS * DWT_ITENS.VLR_ALIQ_INSS)/100,2) <> DWT_ITENS.VLR_INSS_RETIDO  
  890           AND    DOC_FIS.COD_EMPRESA                 =  P_COD_EMPRESA
  891           AND    DOC_FIS.COD_ESTAB                   =  P_COD_ESTAB
  892           AND    DOC_FIS.DATA_EMISSAO               >= P_DATA_INICIAL
  893           AND    DOC_FIS.DATA_EMISSAO               <= P_DATA_FINAL
  894           
  895           
  896           UNION ALL
  897           SELECT DOC_FIS.DATA_EMISSAO
  898                 ,DOC_FIS.DATA_FISCAL
  899                 ,DOC_FIS.IDENT_FIS_JUR
  900                 ,DOC_FIS.IDENT_DOCTO
  901                 ,DOC_FIS.NUM_DOCFIS
  902                 ,DOC_FIS.SERIE_DOCFIS
  903                 ,DOC_FIS.SUB_SERIE_DOCFIS
  904                 ,NULL 
  905                 ,DOC_FIS.COD_CLASS_DOC_FIS
  906                 ,DOC_FIS.VLR_TOT_NOTA
  907                 ,DOC_FIS.VLR_CONTAB_COMPL
  908                 ,DWT_ITENS.VLR_BASE_INSS
  909                 ,DWT_ITENS.VLR_ALIQ_INSS
  910                 ,DWT_ITENS.VLR_INSS_RETIDO
  911                 ,X2058.IND_TP_PROC_ADJ
  912                 ,X2058.NUM_PROC_ADJ
  913                 ,DWT_ITENS.NUM_ITEM
  914                 ,DWT_ITENS.VLR_SERVICO
  915                 ,X2058_ADIC.IND_TP_PROC_ADJ
  916                 ,X2058_ADIC.NUM_PROC_ADJ
  917                 ,DWT_ITENS.IDENT_SERVICO
  918                 , NULL 
  919                 , PRT_PAR2_MSAF.COD_PARAM
  920           FROM   DWT_DOCTO_FISCAL         DOC_FIS
  921                 ,DWT_ITENS_SERV           DWT_ITENS
  922                 ,X2018_SERVICOS           X2018
  923                 ,PRT_SERV_MSAF
  924                 ,PRT_PAR2_MSAF
  925                 ,X2058_PROC_ADJ           X2058
  926                 ,X2058_PROC_ADJ           X2058_ADIC
  927           WHERE  DOC_FIS.COD_EMPRESA                =  DWT_ITENS.COD_EMPRESA
  928           AND    DOC_FIS.COD_ESTAB                  =  DWT_ITENS.COD_ESTAB
  929           AND    DOC_FIS.DATA_FISCAL                =  DWT_ITENS.DATA_FISCAL
  930           AND    DOC_FIS.IDENT_FIS_JUR              =  DWT_ITENS.IDENT_FIS_JUR
  931           AND    DOC_FIS.IDENT_DOCTO                =  DWT_ITENS.IDENT_DOCTO
  932           AND    DOC_FIS.NUM_DOCFIS                 =  DWT_ITENS.NUM_DOCFIS
  933           AND    DOC_FIS.SERIE_DOCFIS               =  DWT_ITENS.SERIE_DOCFIS
  934           AND    DOC_FIS.SUB_SERIE_DOCFIS           =  DWT_ITENS.SUB_SERIE_DOCFIS
  935           AND    DWT_ITENS.IDENT_PROC_ADJ_PRINC     =  X2058.IDENT_PROC_ADJ(+)
  936           AND    DWT_ITENS.IDENT_PROC_ADJ_ADIC      =  X2058_ADIC.IDENT_PROC_ADJ(+)
  937           
  938           
  939           AND    PRT_SERV_MSAF.COD_EMPRESA           =  DOC_FIS.COD_EMPRESA
  940           AND    PRT_SERV_MSAF.COD_ESTAB             =  DOC_FIS.COD_ESTAB
  941           AND    DWT_ITENS.IDENT_SERVICO            =  X2018.IDENT_SERVICO
  942           AND    X2018.GRUPO_SERVICO                =  PRT_SERV_MSAF.GRUPO_SERVICO
  943           AND    X2018.COD_SERVICO                  =  PRT_SERV_MSAF.COD_SERVICO
  944           AND    PRT_SERV_MSAF.COD_PARAM            =  PRT_PAR2_MSAF.COD_PARAM
  945           AND    PRT_SERV_MSAF.COD_PARAM IN (683,684,685,686,690)
  946           
  947           
  948           AND    DOC_FIS.DAT_CANCELAMENTO           IS NULL
  949           AND    DOC_FIS.COD_CLASS_DOC_FIS          IN ('2', '3')
  950           AND    DOC_FIS.NORM_DEV                    =  '1'
  951         
  952           AND  ((DOC_FIS.MOVTO_E_S < '9' AND P_ENTRADA_SAIDA = 'E') OR (DOC_FIS.MOVTO_E_S = '9' AND P_ENTRADA_SAIDA = 'S'))         
  953           AND    NVL(DWT_ITENS.VLR_INSS_RETIDO, 0)   >  0
  954           AND    DOC_FIS.SITUACAO = 'N'
  955           AND    ROUND((DWT_ITENS.VLR_BASE_INSS * DWT_ITENS.VLR_ALIQ_INSS)/100,2) <> DWT_ITENS.VLR_INSS_RETIDO  
  956           AND    DOC_FIS.COD_EMPRESA                 =  P_COD_EMPRESA
  957           AND    DOC_FIS.COD_ESTAB                   =  P_COD_ESTAB
  958           AND    DOC_FIS.DATA_EMISSAO               >= P_DATA_INICIAL
  959           AND    DOC_FIS.DATA_EMISSAO               <= P_DATA_FINAL
  960           
  961           
  962           
  963           UNION  ALL 
  964           SELECT DOC_FIS.DATA_EMISSAO
  965                 ,DOC_FIS.DATA_FISCAL
  966                 ,DOC_FIS.IDENT_FIS_JUR
  967                 ,DOC_FIS.IDENT_DOCTO
  968                 ,DOC_FIS.NUM_DOCFIS
  969                 ,DOC_FIS.SERIE_DOCFIS
  970                 ,DOC_FIS.SUB_SERIE_DOCFIS
  971                 ,TIPO_SERV.IDENT_TIPO_SERV_ESOCIAL
  972                 ,DOC_FIS.COD_CLASS_DOC_FIS
  973                 ,DOC_FIS.VLR_TOT_NOTA
  974                 ,DOC_FIS.VLR_CONTAB_COMPL
  975                 ,DWT_MERC.VLR_BASE_INSS
  976                 ,DWT_MERC.VLR_ALIQ_INSS
  977                 ,DWT_MERC.VLR_INSS_RETIDO
  978                 ,X2058.IND_TP_PROC_ADJ
  979                 ,X2058.NUM_PROC_ADJ
  980                 ,DWT_MERC.NUM_ITEM
  981                 ,DWT_MERC.VLR_ITEM
  982                 ,X2058_ADIC.IND_TP_PROC_ADJ
  983                 ,X2058_ADIC.NUM_PROC_ADJ
  984                 ,NULL 
  985                 ,DWT_MERC.IDENT_PRODUTO
  986                 ,NULL 
  987           FROM   DWT_DOCTO_FISCAL      DOC_FIS
  988                 ,DWT_ITENS_MERC        DWT_MERC
  989                 ,X2013_PRODUTO         X2013
  990                 ,PRT_ID_TIPO_SERV_PROD ID_TIPO_SERV
  991                 ,PRT_TIPO_SERV_ESOCIAL TIPO_SERV
  992                 ,X2058_PROC_ADJ        X2058
  993                 ,X2058_PROC_ADJ        X2058_ADIC
  994                 ,X2024_MODELO_DOCTO    X2024
  995           WHERE  DOC_FIS.COD_EMPRESA                 = DWT_MERC.COD_EMPRESA
  996           AND    DOC_FIS.COD_ESTAB                   = DWT_MERC.COD_ESTAB
  997           AND    DOC_FIS.DATA_FISCAL                 = DWT_MERC.DATA_FISCAL
  998           AND    DOC_FIS.IDENT_FIS_JUR               = DWT_MERC.IDENT_FIS_JUR
  999           AND    DOC_FIS.IDENT_DOCTO                 = DWT_MERC.IDENT_DOCTO
 1000           AND    DOC_FIS.NUM_DOCFIS                  = DWT_MERC.NUM_DOCFIS
 1001           AND    DOC_FIS.SERIE_DOCFIS                = DWT_MERC.SERIE_DOCFIS
 1002           AND    DOC_FIS.SUB_SERIE_DOCFIS            = DWT_MERC.SUB_SERIE_DOCFIS
 1003           AND    DOC_FIS.IDENT_MODELO                = X2024.IDENT_MODELO
 1004           AND    X2024.COD_MODELO                   IN ('07', '67')
 1005           AND    DWT_MERC.IDENT_PROC_ADJ_PRINC       = X2058.IDENT_PROC_ADJ(+)
 1006           AND    DWT_MERC.IDENT_PROC_ADJ_ADIC        = X2058_ADIC.IDENT_PROC_ADJ(+)
 1007           AND    ID_TIPO_SERV.COD_EMPRESA            = DOC_FIS.COD_EMPRESA
 1008           AND    ID_TIPO_SERV.COD_ESTAB              = DOC_FIS.COD_ESTAB
 1009           AND    DWT_MERC.IDENT_PRODUTO              = X2013.IDENT_PRODUTO                
 1010           AND    ID_TIPO_SERV.GRUPO_PRODUTO          = X2013.GRUPO_PRODUTO
 1011           AND    ID_TIPO_SERV.COD_PRODUTO            = X2013.COD_PRODUTO
 1012           AND    ID_TIPO_SERV.IND_PRODUTO            = X2013.IND_PRODUTO                
 1013           AND    ID_TIPO_SERV.COD_TIPO_SERV_ESOCIAL  = TIPO_SERV.COD_TIPO_SERV_ESOCIAL
 1014           AND    TIPO_SERV.DATA_INI_VIGENCIA         = (SELECT MAX(A.DATA_INI_VIGENCIA)
 1015                                                         FROM   PRT_TIPO_SERV_ESOCIAL A
 1016                                                         WHERE  A.COD_TIPO_SERV_ESOCIAL =
 1017                                                                TIPO_SERV.COD_TIPO_SERV_ESOCIAL 
 1018                                                         AND    A.DATA_INI_VIGENCIA <= P_DATA_FINAL)                
 1019           AND    DOC_FIS.DAT_CANCELAMENTO           IS NULL
 1020           AND    DOC_FIS.COD_CLASS_DOC_FIS          IN ('1', '3')
 1021           AND    DOC_FIS.NORM_DEV                    = '1'
 1022         
 1023           AND  ((DOC_FIS.MOVTO_E_S < '9' AND P_ENTRADA_SAIDA = 'E') OR (DOC_FIS.MOVTO_E_S = '9' AND P_ENTRADA_SAIDA = 'S'))  
 1024           AND    NVL(DWT_MERC.VLR_INSS_RETIDO, 0)    > 0
 1025           AND    DOC_FIS.SITUACAO = 'N'
 1026           AND    ROUND((DWT_MERC.VLR_BASE_INSS * DWT_MERC.VLR_ALIQ_INSS)/100,2) <> DWT_MERC.VLR_INSS_RETIDO  
 1027           AND    DOC_FIS.COD_EMPRESA                 = P_COD_EMPRESA
 1028           AND    DOC_FIS.COD_ESTAB                   = P_COD_ESTAB
 1029           AND    DOC_FIS.DATA_EMISSAO               >= P_DATA_INICIAL
 1030           AND    DOC_FIS.DATA_EMISSAO               <= P_DATA_FINAL;
 1031           
 1032           
 1033           
 1034           
 1035           
 1036    
 1037    CURSOR C_CONF_ALIQ_INSS_INVALIDA (P_COD_EMPRESA VARCHAR2, 
 1038                            P_COD_ESTAB VARCHAR2,
 1039                            P_DATA_INICIAL  DATE,
 1040                            P_DATA_FINAL  DATE) IS
 1041          
 1042           SELECT DOC_FIS.DATA_EMISSAO
 1043                 ,DOC_FIS.DATA_FISCAL
 1044                 ,DOC_FIS.IDENT_FIS_JUR
 1045                 ,DOC_FIS.IDENT_DOCTO
 1046                 ,DOC_FIS.NUM_DOCFIS
 1047                 ,DOC_FIS.SERIE_DOCFIS
 1048                 ,DOC_FIS.SUB_SERIE_DOCFIS
 1049                 ,TIPO_SERV.IDENT_TIPO_SERV_ESOCIAL
 1050                 ,DOC_FIS.COD_CLASS_DOC_FIS
 1051                 ,DOC_FIS.VLR_TOT_NOTA
 1052                 ,DOC_FIS.VLR_CONTAB_COMPL
 1053                 ,DWT_ITENS.VLR_BASE_INSS
 1054                 ,DWT_ITENS.VLR_ALIQ_INSS
 1055                 ,DWT_ITENS.VLR_INSS_RETIDO
 1056                 ,X2058.IND_TP_PROC_ADJ
 1057                 ,X2058.NUM_PROC_ADJ
 1058                 ,DWT_ITENS.NUM_ITEM
 1059                 ,DWT_ITENS.VLR_SERVICO
 1060                 ,X2058_ADIC.IND_TP_PROC_ADJ
 1061                 ,X2058_ADIC.NUM_PROC_ADJ
 1062                 ,DWT_ITENS.IDENT_SERVICO
 1063                 , NULL 
 1064                 , NULL 
 1065           FROM   DWT_DOCTO_FISCAL         DOC_FIS
 1066                 ,DWT_ITENS_SERV           DWT_ITENS
 1067                 ,X2018_SERVICOS           X2018
 1068                 ,PRT_ID_TIPO_SERV_ESOCIAL ID_TIPO_SERV
 1069                 ,PRT_TIPO_SERV_ESOCIAL    TIPO_SERV
 1070                 ,X2058_PROC_ADJ           X2058
 1071                 ,X2058_PROC_ADJ           X2058_ADIC
 1072           WHERE  DOC_FIS.COD_EMPRESA                =  DWT_ITENS.COD_EMPRESA
 1073           AND    DOC_FIS.COD_ESTAB                  =  DWT_ITENS.COD_ESTAB
 1074           AND    DOC_FIS.DATA_FISCAL                =  DWT_ITENS.DATA_FISCAL
 1075           AND    DOC_FIS.IDENT_FIS_JUR              =  DWT_ITENS.IDENT_FIS_JUR
 1076           AND    DOC_FIS.IDENT_DOCTO                =  DWT_ITENS.IDENT_DOCTO
 1077           AND    DOC_FIS.NUM_DOCFIS                 =  DWT_ITENS.NUM_DOCFIS
 1078           AND    DOC_FIS.SERIE_DOCFIS               =  DWT_ITENS.SERIE_DOCFIS
 1079           AND    DOC_FIS.SUB_SERIE_DOCFIS           =  DWT_ITENS.SUB_SERIE_DOCFIS
 1080           AND    DWT_ITENS.IDENT_PROC_ADJ_PRINC     =  X2058.IDENT_PROC_ADJ(+)
 1081           AND    DWT_ITENS.IDENT_PROC_ADJ_ADIC      =  X2058_ADIC.IDENT_PROC_ADJ(+)
 1082           AND    ID_TIPO_SERV.COD_EMPRESA           =  DOC_FIS.COD_EMPRESA
 1083           AND    ID_TIPO_SERV.COD_ESTAB             =  DOC_FIS.COD_ESTAB
 1084           AND    DWT_ITENS.IDENT_SERVICO            =  X2018.IDENT_SERVICO
 1085           AND    X2018.GRUPO_SERVICO                =  ID_TIPO_SERV.GRUPO_SERVICO
 1086           AND    X2018.COD_SERVICO                  =  ID_TIPO_SERV.COD_SERVICO
 1087           AND    ID_TIPO_SERV.COD_TIPO_SERV_ESOCIAL =  TIPO_SERV.COD_TIPO_SERV_ESOCIAL
 1088           AND    TIPO_SERV.DATA_INI_VIGENCIA        =  (SELECT MAX(A.DATA_INI_VIGENCIA)
 1089                                                         FROM   PRT_TIPO_SERV_ESOCIAL A
 1090                                                         WHERE  A.COD_TIPO_SERV_ESOCIAL  = TIPO_SERV.COD_TIPO_SERV_ESOCIAL
 1091                                                         AND    A.DATA_INI_VIGENCIA     <= P_DATA_FINAL)
 1092           AND    DOC_FIS.DAT_CANCELAMENTO           IS NULL
 1093           AND    DOC_FIS.COD_CLASS_DOC_FIS          IN ('2', '3')
 1094           AND    DOC_FIS.NORM_DEV                    =  '1'
 1095         
 1096           AND  ((DOC_FIS.MOVTO_E_S < '9' AND P_ENTRADA_SAIDA = 'E') OR (DOC_FIS.MOVTO_E_S = '9' AND P_ENTRADA_SAIDA = 'S'))         
 1097           AND    NVL(DWT_ITENS.VLR_INSS_RETIDO, 0)   >  0
 1098           AND    DOC_FIS.SITUACAO = 'N'
 1099           AND    DWT_ITENS.VLR_ALIQ_INSS <> 11 AND DWT_ITENS.VLR_ALIQ_INSS <> 3.5  
 1100           AND    DOC_FIS.COD_EMPRESA                 =  P_COD_EMPRESA
 1101           AND    DOC_FIS.COD_ESTAB                   =  P_COD_ESTAB
 1102           AND    DOC_FIS.DATA_EMISSAO               >= P_DATA_INICIAL
 1103           AND    DOC_FIS.DATA_EMISSAO               <= P_DATA_FINAL
 1104           
 1105           
 1106           UNION ALL
 1107           SELECT DOC_FIS.DATA_EMISSAO
 1108                 ,DOC_FIS.DATA_FISCAL
 1109                 ,DOC_FIS.IDENT_FIS_JUR
 1110                 ,DOC_FIS.IDENT_DOCTO
 1111                 ,DOC_FIS.NUM_DOCFIS
 1112                 ,DOC_FIS.SERIE_DOCFIS
 1113                 ,DOC_FIS.SUB_SERIE_DOCFIS
 1114                 ,NULL 
 1115                 ,DOC_FIS.COD_CLASS_DOC_FIS
 1116                 ,DOC_FIS.VLR_TOT_NOTA
 1117                 ,DOC_FIS.VLR_CONTAB_COMPL
 1118                 ,DWT_ITENS.VLR_BASE_INSS
 1119                 ,DWT_ITENS.VLR_ALIQ_INSS
 1120                 ,DWT_ITENS.VLR_INSS_RETIDO
 1121                 ,X2058.IND_TP_PROC_ADJ
 1122                 ,X2058.NUM_PROC_ADJ
 1123                 ,DWT_ITENS.NUM_ITEM
 1124                 ,DWT_ITENS.VLR_SERVICO
 1125                 ,X2058_ADIC.IND_TP_PROC_ADJ
 1126                 ,X2058_ADIC.NUM_PROC_ADJ
 1127                 ,DWT_ITENS.IDENT_SERVICO
 1128                 ,NULL 
 1129                 ,PRT_PAR2_MSAF.COD_PARAM
 1130           FROM   DWT_DOCTO_FISCAL         DOC_FIS
 1131                 ,DWT_ITENS_SERV           DWT_ITENS
 1132                 ,X2018_SERVICOS           X2018
 1133                 ,PRT_SERV_MSAF
 1134                 ,PRT_PAR2_MSAF
 1135                 ,X2058_PROC_ADJ           X2058
 1136                 ,X2058_PROC_ADJ           X2058_ADIC
 1137           WHERE  DOC_FIS.COD_EMPRESA                =  DWT_ITENS.COD_EMPRESA
 1138           AND    DOC_FIS.COD_ESTAB                  =  DWT_ITENS.COD_ESTAB
 1139           AND    DOC_FIS.DATA_FISCAL                =  DWT_ITENS.DATA_FISCAL
 1140           AND    DOC_FIS.IDENT_FIS_JUR              =  DWT_ITENS.IDENT_FIS_JUR
 1141           AND    DOC_FIS.IDENT_DOCTO                =  DWT_ITENS.IDENT_DOCTO
 1142           AND    DOC_FIS.NUM_DOCFIS                 =  DWT_ITENS.NUM_DOCFIS
 1143           AND    DOC_FIS.SERIE_DOCFIS               =  DWT_ITENS.SERIE_DOCFIS
 1144           AND    DOC_FIS.SUB_SERIE_DOCFIS           =  DWT_ITENS.SUB_SERIE_DOCFIS
 1145           AND    DWT_ITENS.IDENT_PROC_ADJ_PRINC     =  X2058.IDENT_PROC_ADJ(+)
 1146           AND    DWT_ITENS.IDENT_PROC_ADJ_ADIC      =  X2058_ADIC.IDENT_PROC_ADJ(+)
 1147           
 1148           AND    PRT_SERV_MSAF.COD_EMPRESA           =  DOC_FIS.COD_EMPRESA
 1149           AND    PRT_SERV_MSAF.COD_ESTAB             =  DOC_FIS.COD_ESTAB
 1150           AND    DWT_ITENS.IDENT_SERVICO            =  X2018.IDENT_SERVICO
 1151           AND    X2018.GRUPO_SERVICO                =  PRT_SERV_MSAF.GRUPO_SERVICO
 1152           AND    X2018.COD_SERVICO                  =  PRT_SERV_MSAF.COD_SERVICO
 1153           AND    PRT_SERV_MSAF.COD_PARAM            =  PRT_PAR2_MSAF.COD_PARAM
 1154           AND    PRT_SERV_MSAF.COD_PARAM IN (683,684,685,686,690)
 1155           
 1156           AND    DOC_FIS.DAT_CANCELAMENTO           IS NULL
 1157           AND    DOC_FIS.COD_CLASS_DOC_FIS          IN ('2', '3')
 1158           AND    DOC_FIS.NORM_DEV                    =  '1'
 1159         
 1160           AND  ((DOC_FIS.MOVTO_E_S < '9' AND P_ENTRADA_SAIDA = 'E') OR (DOC_FIS.MOVTO_E_S = '9' AND P_ENTRADA_SAIDA = 'S'))         
 1161           AND    NVL(DWT_ITENS.VLR_INSS_RETIDO, 0)   >  0
 1162           AND    DOC_FIS.SITUACAO = 'N'
 1163           AND    DWT_ITENS.VLR_ALIQ_INSS <> 11 AND DWT_ITENS.VLR_ALIQ_INSS <> 3.5  
 1164           AND    DOC_FIS.COD_EMPRESA                 =  P_COD_EMPRESA
 1165           AND    DOC_FIS.COD_ESTAB                   =  P_COD_ESTAB
 1166           AND    DOC_FIS.DATA_EMISSAO               >= P_DATA_INICIAL
 1167           AND    DOC_FIS.DATA_EMISSAO               <= P_DATA_FINAL
 1168           
 1169           
 1170           UNION  ALL 
 1171           SELECT DOC_FIS.DATA_EMISSAO
 1172                 ,DOC_FIS.DATA_FISCAL
 1173                 ,DOC_FIS.IDENT_FIS_JUR
 1174                 ,DOC_FIS.IDENT_DOCTO
 1175                 ,DOC_FIS.NUM_DOCFIS
 1176                 ,DOC_FIS.SERIE_DOCFIS
 1177                 ,DOC_FIS.SUB_SERIE_DOCFIS
 1178                 ,TIPO_SERV.IDENT_TIPO_SERV_ESOCIAL
 1179                 ,DOC_FIS.COD_CLASS_DOC_FIS
 1180                 ,DOC_FIS.VLR_TOT_NOTA
 1181                 ,DOC_FIS.VLR_CONTAB_COMPL
 1182                 ,DWT_MERC.VLR_BASE_INSS
 1183                 ,DWT_MERC.VLR_ALIQ_INSS
 1184                 ,DWT_MERC.VLR_INSS_RETIDO
 1185                 ,X2058.IND_TP_PROC_ADJ
 1186                 ,X2058.NUM_PROC_ADJ
 1187                 ,DWT_MERC.NUM_ITEM
 1188                 ,DWT_MERC.VLR_ITEM
 1189                 ,X2058_ADIC.IND_TP_PROC_ADJ
 1190                 ,X2058_ADIC.NUM_PROC_ADJ
 1191                 ,NULL 
 1192                 ,DWT_MERC.IDENT_PRODUTO
 1193                 ,NULL 
 1194           FROM   DWT_DOCTO_FISCAL      DOC_FIS
 1195                 ,DWT_ITENS_MERC        DWT_MERC
 1196                 ,X2013_PRODUTO         X2013
 1197                 ,PRT_ID_TIPO_SERV_PROD ID_TIPO_SERV
 1198                 ,PRT_TIPO_SERV_ESOCIAL TIPO_SERV
 1199                 ,X2058_PROC_ADJ        X2058
 1200                 ,X2058_PROC_ADJ        X2058_ADIC
 1201                 ,X2024_MODELO_DOCTO    X2024
 1202           WHERE  DOC_FIS.COD_EMPRESA                 = DWT_MERC.COD_EMPRESA
 1203           AND    DOC_FIS.COD_ESTAB                   = DWT_MERC.COD_ESTAB
 1204           AND    DOC_FIS.DATA_FISCAL                 = DWT_MERC.DATA_FISCAL
 1205           AND    DOC_FIS.IDENT_FIS_JUR               = DWT_MERC.IDENT_FIS_JUR
 1206           AND    DOC_FIS.IDENT_DOCTO                 = DWT_MERC.IDENT_DOCTO
 1207           AND    DOC_FIS.NUM_DOCFIS                  = DWT_MERC.NUM_DOCFIS
 1208           AND    DOC_FIS.SERIE_DOCFIS                = DWT_MERC.SERIE_DOCFIS
 1209           AND    DOC_FIS.SUB_SERIE_DOCFIS            = DWT_MERC.SUB_SERIE_DOCFIS
 1210           AND    DOC_FIS.IDENT_MODELO                = X2024.IDENT_MODELO
 1211           AND    X2024.COD_MODELO                   IN ('07', '67')
 1212           AND    DWT_MERC.IDENT_PROC_ADJ_PRINC       = X2058.IDENT_PROC_ADJ(+)
 1213           AND    DWT_MERC.IDENT_PROC_ADJ_ADIC        = X2058_ADIC.IDENT_PROC_ADJ(+)
 1214           AND    ID_TIPO_SERV.COD_EMPRESA            = DOC_FIS.COD_EMPRESA
 1215           AND    ID_TIPO_SERV.COD_ESTAB              = DOC_FIS.COD_ESTAB
 1216           AND    DWT_MERC.IDENT_PRODUTO              = X2013.IDENT_PRODUTO                
 1217           AND    ID_TIPO_SERV.GRUPO_PRODUTO          = X2013.GRUPO_PRODUTO
 1218           AND    ID_TIPO_SERV.COD_PRODUTO            = X2013.COD_PRODUTO
 1219           AND    ID_TIPO_SERV.IND_PRODUTO            = X2013.IND_PRODUTO                
 1220           AND    ID_TIPO_SERV.COD_TIPO_SERV_ESOCIAL  = TIPO_SERV.COD_TIPO_SERV_ESOCIAL
 1221           AND    TIPO_SERV.DATA_INI_VIGENCIA         = (SELECT MAX(A.DATA_INI_VIGENCIA)
 1222                                                         FROM   PRT_TIPO_SERV_ESOCIAL A
 1223                                                         WHERE  A.COD_TIPO_SERV_ESOCIAL =
 1224                                                                TIPO_SERV.COD_TIPO_SERV_ESOCIAL 
 1225                                                         AND    A.DATA_INI_VIGENCIA <= P_DATA_FINAL)                
 1226           AND    DOC_FIS.DAT_CANCELAMENTO           IS NULL
 1227           AND    DOC_FIS.COD_CLASS_DOC_FIS          IN ('1', '3')
 1228           AND    DOC_FIS.NORM_DEV                    = '1'
 1229         
 1230           AND  ((DOC_FIS.MOVTO_E_S < '9' AND P_ENTRADA_SAIDA = 'E') OR (DOC_FIS.MOVTO_E_S = '9' AND P_ENTRADA_SAIDA = 'S'))  
 1231           AND    NVL(DWT_MERC.VLR_INSS_RETIDO, 0)    > 0
 1232           AND    DOC_FIS.SITUACAO = 'N'
 1233           AND    DWT_MERC.VLR_ALIQ_INSS <> 11 AND DWT_MERC.VLR_ALIQ_INSS  <> 3.5  
 1234           AND    DOC_FIS.COD_EMPRESA                 = P_COD_EMPRESA
 1235           AND    DOC_FIS.COD_ESTAB                   = P_COD_ESTAB
 1236           AND    DOC_FIS.DATA_EMISSAO               >= P_DATA_INICIAL
 1237           AND    DOC_FIS.DATA_EMISSAO               <= P_DATA_FINAL;
 1238           
 1239           
 1240           
 1241 
 1242 
 1243 
 1244 
 1245 
 1246 
 1247 
 1248 
 1249 
 1250 
 1251 
 1252 
 1253 
 1254 
 1255 
 1256 
 1257 
 1258 
 1259 
 1260 
 1261 
 1262 
 1263 
 1264 
 1265 
 1266 
 1267 
 1268 
 1269 
 1270 
 1271 
 1272 
 1273 
 1274 
 1275 
 1276 
 1277 
 1278 
 1279 
 1280 
 1281 
 1282 
 1283 
 1284 
 1285 
 1286 
 1287 
 1288 
 1289                                                                                
 1290 
 1291    TYPE TREG_DATA_EMISSAO              IS TABLE OF REINF_CONF_PREVIDENCIARIA.DATA_EMISSAO%TYPE INDEX BY BINARY_INTEGER;
 1292    TYPE TREG_DATA_FISCAL               IS TABLE OF REINF_CONF_PREVIDENCIARIA.DATA_FISCAL%TYPE INDEX BY BINARY_INTEGER;
 1293    TYPE TREG_IDENT_FIS_JUR             IS TABLE OF REINF_CONF_PREVIDENCIARIA.IDENT_FIS_JUR%TYPE INDEX BY BINARY_INTEGER;
 1294    TYPE TREG_IDENT_DOCTO               IS TABLE OF REINF_CONF_PREVIDENCIARIA.IDENT_DOCTO%TYPE INDEX BY BINARY_INTEGER;
 1295    TYPE TREG_NUM_DOCFIS                IS TABLE OF REINF_CONF_PREVIDENCIARIA.NUM_DOCFIS%TYPE INDEX BY BINARY_INTEGER;
 1296    TYPE TREG_SERIE_DOCFIS              IS TABLE OF REINF_CONF_PREVIDENCIARIA.SERIE_DOCFIS%TYPE INDEX BY BINARY_INTEGER;
 1297    TYPE TREG_SUB_SERIE_DOCFIS          IS TABLE OF REINF_CONF_PREVIDENCIARIA.SUB_SERIE_DOCFIS%TYPE INDEX BY BINARY_INTEGER;
 1298    TYPE TREG_IDENT_TIPO_SERV_ESOCIAL   IS TABLE OF REINF_CONF_PREVIDENCIARIA.IDENT_TIPO_SERV_ESOCIAL%TYPE INDEX BY BINARY_INTEGER;
 1299    TYPE TREG_COD_CLASS_DOC_FIS         IS TABLE OF REINF_CONF_PREVIDENCIARIA.COD_CLASS_DOC_FIS%TYPE  INDEX BY BINARY_INTEGER;
 1300    TYPE TREG_VLR_TOT_NOTA              IS TABLE OF REINF_CONF_PREVIDENCIARIA.VLR_TOT_NOTA%TYPE  INDEX BY BINARY_INTEGER;
 1301    TYPE TREG_VLR_CONTAB_COMPL          IS TABLE OF REINF_CONF_PREVIDENCIARIA.VLR_CONTAB_COMPL%TYPE  INDEX BY BINARY_INTEGER;    
 1302    TYPE TREG_VLR_BASE_INSS             IS TABLE OF REINF_CONF_PREVIDENCIARIA.VLR_BASE_INSS%TYPE  INDEX BY BINARY_INTEGER;
 1303    TYPE TREG_VLR_ALIQ_INSS             IS TABLE OF REINF_CONF_PREVIDENCIARIA.VLR_ALIQ_INSS%TYPE  INDEX BY BINARY_INTEGER;  
 1304    TYPE TREG_VLR_INSS_RETIDO           IS TABLE OF REINF_CONF_PREVIDENCIARIA.VLR_INSS_RETIDO%TYPE  INDEX BY BINARY_INTEGER;  
 1305    TYPE TREG_IND_TIPO_PROC             IS TABLE OF REINF_CONF_PREVIDENCIARIA.IND_TIPO_PROC%TYPE  INDEX BY BINARY_INTEGER;  
 1306    TYPE TREG_NUM_PROC_JUR              IS TABLE OF REINF_CONF_PREVIDENCIARIA.NUM_PROC_JUR%TYPE  INDEX BY BINARY_INTEGER;  
 1307    TYPE TREG_NUM_ITEM                  IS TABLE OF DWT_ITENS_SERV.NUM_ITEM%TYPE  INDEX BY BINARY_INTEGER;
 1308    TYPE TREG_VLR_SERVICO               IS TABLE OF REINF_CONF_PREVIDENCIARIA.VLR_SERVICO%TYPE  INDEX BY BINARY_INTEGER;
 1309    TYPE TREG_IND_TP_PROC_ADJ_ADIC      IS TABLE OF REINF_CONF_PREVIDENCIARIA.IND_TP_PROC_ADJ_ADIC%TYPE  INDEX BY BINARY_INTEGER;  
 1310    TYPE TREG_NUM_PROC_ADJ_ADIC         IS TABLE OF REINF_CONF_PREVIDENCIARIA.NUM_PROC_ADJ_ADIC%TYPE  INDEX BY BINARY_INTEGER;  
 1311    TYPE TREG_IDENT_SERVICO             IS TABLE OF DWT_ITENS_SERV.IDENT_SERVICO%TYPE  INDEX BY BINARY_INTEGER;    
 1312    TYPE TREG_IDENT_PRODUTO             IS TABLE OF DWT_ITENS_MERC.IDENT_PRODUTO%TYPE  INDEX BY BINARY_INTEGER;
 1313    TYPE TREG_COD_PARAM                 IS TABLE OF REINF_CONF_PREVIDENCIARIA.COD_PARAM%TYPE  INDEX BY BINARY_INTEGER; 
 1314 
 1315    RREG_DATA_EMISSAO             TREG_DATA_EMISSAO;           
 1316    RREG_DATA_FISCAL              TREG_DATA_FISCAL;            
 1317    RREG_IDENT_FIS_JUR            TREG_IDENT_FIS_JUR;          
 1318    RREG_IDENT_DOCTO              TREG_IDENT_DOCTO;            
 1319    RREG_NUM_DOCFIS               TREG_NUM_DOCFIS;             
 1320    RREG_SERIE_DOCFIS             TREG_SERIE_DOCFIS;             
 1321    RREG_SUB_SERIE_DOCFIS         TREG_SUB_SERIE_DOCFIS;       
 1322    RREG_IDENT_TIPO_SERV_ESOCIAL  TREG_IDENT_TIPO_SERV_ESOCIAL;
 1323    RREG_COD_CLASS_DOC_FIS        TREG_COD_CLASS_DOC_FIS;      
 1324    RREG_VLR_TOT_NOTA             TREG_VLR_TOT_NOTA;           
 1325    RREG_VLR_CONTAB_COMPL         TREG_VLR_CONTAB_COMPL;          
 1326    RREG_VLR_BASE_INSS            TREG_VLR_BASE_INSS;             
 1327    RREG_VLR_ALIQ_INSS            TREG_VLR_ALIQ_INSS;            
 1328    RREG_VLR_INSS_RETIDO          TREG_VLR_INSS_RETIDO;
 1329    RREG_IND_TIPO_PROC            TREG_IND_TIPO_PROC;
 1330    RREG_NUM_PROC_JUR             TREG_NUM_PROC_JUR;
 1331    RREG_NUM_ITEM                 TREG_NUM_ITEM;
 1332    RREG_VLR_SERVICO              TREG_VLR_SERVICO;
 1333    RREG_IND_TP_PROC_ADJ_ADIC     TREG_IND_TP_PROC_ADJ_ADIC;
 1334    RREG_NUM_PROC_ADJ_ADIC        TREG_NUM_PROC_ADJ_ADIC;
 1335    RREG_IDENT_SERVICO            TREG_IDENT_SERVICO;
 1336    RREG_IDENT_PRODUTO            TREG_IDENT_PRODUTO;
 1337    RREG_COD_PARAM                TREG_COD_PARAM;
 1338   
 1339   RTABSAIDA REINF_CONF_PREVIDENCIARIA%ROWTYPE; 
 1340   
 1341   
 1342   PROCEDURE INICIALIZAR IS 
 1343     BEGIN
 1344       
 1345       RREG_DATA_EMISSAO.DELETE;           
 1346       RREG_DATA_FISCAL.DELETE;            
 1347       RREG_IDENT_FIS_JUR.DELETE;          
 1348       RREG_IDENT_DOCTO.DELETE;            
 1349       RREG_NUM_DOCFIS.DELETE;             
 1350       RREG_SERIE_DOCFIS.DELETE;           
 1351       RREG_SUB_SERIE_DOCFIS.DELETE;       
 1352       RREG_IDENT_TIPO_SERV_ESOCIAL.DELETE;
 1353       RREG_COD_CLASS_DOC_FIS.DELETE;      
 1354       RREG_VLR_TOT_NOTA.DELETE;           
 1355       RREG_VLR_CONTAB_COMPL.DELETE;       
 1356       RREG_VLR_BASE_INSS.DELETE;          
 1357       RREG_VLR_ALIQ_INSS.DELETE;          
 1358       RREG_VLR_INSS_RETIDO.DELETE;        
 1359       RREG_IND_TIPO_PROC.DELETE;          
 1360       RREG_NUM_PROC_JUR.DELETE;           
 1361       RREG_NUM_ITEM.DELETE;
 1362       RREG_VLR_SERVICO.DELETE;             
 1363       RREG_IND_TP_PROC_ADJ_ADIC.DELETE;          
 1364       RREG_NUM_PROC_ADJ_ADIC.DELETE;
 1365       RREG_COD_PARAM.DELETE;           
 1366     
 1367   END INICIALIZAR;
 1368   
 1369 
 1370   PROCEDURE GRAVAREGISTRO(PREG IN REINF_CONF_PREVIDENCIARIA%ROWTYPE) IS
 1371   BEGIN
 1372     BEGIN 
 1373       INSERT INTO REINF_CONF_PREVIDENCIARIA
 1374         (COD_EMPRESA,
 1375          COD_ESTAB,
 1376          DATA_EMISSAO,
 1377          DATA_FISCAL,
 1378          IDENT_FIS_JUR,
 1379          IDENT_DOCTO,
 1380          NUM_DOCFIS,
 1381          SERIE_DOCFIS,
 1382          SUB_SERIE_DOCFIS,
 1383          COD_USUARIO,
 1384          IDENT_TIPO_SERV_ESOCIAL,
 1385          COD_CLASS_DOC_FIS,
 1386          VLR_TOT_NOTA,
 1387          VLR_CONTAB_COMPL,
 1388          VLR_BASE_INSS,
 1389          VLR_ALIQ_INSS, 
 1390          VLR_INSS_RETIDO, 
 1391          IND_TIPO_PROC, 
 1392          NUM_PROC_JUR,
 1393          NUM_ITEM,
 1394          VLR_SERVICO,
 1395          IND_TP_PROC_ADJ_ADIC, 
 1396          NUM_PROC_ADJ_ADIC,
 1397          IDENT_SERVICO,
 1398          IDENT_PRODUTO,
 1399          COD_PARAM
 1400          )
 1401       VALUES
 1402         (PREG.COD_EMPRESA,
 1403          PREG.COD_ESTAB,
 1404          PREG.DATA_EMISSAO,
 1405          PREG.DATA_FISCAL,
 1406          PREG.IDENT_FIS_JUR,
 1407          PREG.IDENT_DOCTO,
 1408          PREG.NUM_DOCFIS,
 1409          PREG.SERIE_DOCFIS,
 1410          PREG.SUB_SERIE_DOCFIS,
 1411          PREG.COD_USUARIO,
 1412          PREG.IDENT_TIPO_SERV_ESOCIAL,
 1413          PREG.COD_CLASS_DOC_FIS,
 1414          PREG.VLR_TOT_NOTA,
 1415          PREG.VLR_CONTAB_COMPL,
 1416          PREG.VLR_BASE_INSS,
 1417          PREG.VLR_ALIQ_INSS,
 1418          PREG.VLR_INSS_RETIDO,
 1419          PREG.IND_TIPO_PROC,
 1420          PREG.NUM_PROC_JUR,
 1421          PREG.NUM_ITEM,
 1422          PREG.VLR_SERVICO,
 1423          PREG.IND_TP_PROC_ADJ_ADIC,
 1424          PREG.NUM_PROC_ADJ_ADIC,
 1425          PREG.IDENT_SERVICO,
 1426          PREG.IDENT_PRODUTO,
 1427          PREG.COD_PARAM
 1428          )  ;
 1429      EXCEPTION 
 1430        WHEN DUP_VAL_ON_INDEX THEN
 1431          NULL;
 1432        WHEN OTHERS THEN
 1433          P_STATUS := -1;
 1434      
 1435      END;
 1436   
 1437   END GRAVAREGISTRO;
 1438   
 1439   
 1440   PROCEDURE MONTAREGISTROS IS
 1441     BEGIN 
 1442       
 1443        FOR I IN 1..RREG_DATA_EMISSAO.COUNT LOOP
 1444          BEGIN    
 1445            
 1446            P_STATUS := 1; 
 1447            RTABSAIDA.COD_EMPRESA              := COD_EMPRESA_W;
 1448            RTABSAIDA.COD_ESTAB                := COD_ESTAB_W;
 1449            RTABSAIDA.DATA_EMISSAO             := RREG_DATA_EMISSAO(I);
 1450            RTABSAIDA.DATA_FISCAL              := RREG_DATA_FISCAL(I);
 1451            RTABSAIDA.IDENT_FIS_JUR            := RREG_IDENT_FIS_JUR(I); 
 1452            RTABSAIDA.IDENT_DOCTO              := RREG_IDENT_DOCTO(I);
 1453            RTABSAIDA.NUM_DOCFIS               := RREG_NUM_DOCFIS(I);
 1454            RTABSAIDA.SERIE_DOCFIS             := RREG_SERIE_DOCFIS(I);                 
 1455            RTABSAIDA.SUB_SERIE_DOCFIS         := RREG_SUB_SERIE_DOCFIS(I);
 1456            RTABSAIDA.COD_USUARIO              := P_COD_USUARIO;
 1457            RTABSAIDA.IDENT_TIPO_SERV_ESOCIAL  := RREG_IDENT_TIPO_SERV_ESOCIAL(I);
 1458            RTABSAIDA.COD_CLASS_DOC_FIS        := RREG_COD_CLASS_DOC_FIS(I);
 1459            RTABSAIDA.VLR_TOT_NOTA             := RREG_VLR_TOT_NOTA(I);
 1460            RTABSAIDA.VLR_CONTAB_COMPL         := RREG_VLR_CONTAB_COMPL(I);
 1461            RTABSAIDA.VLR_BASE_INSS            := RREG_VLR_BASE_INSS(I);
 1462            RTABSAIDA.VLR_ALIQ_INSS            := RREG_VLR_ALIQ_INSS(I);
 1463            RTABSAIDA.VLR_INSS_RETIDO          := RREG_VLR_INSS_RETIDO(I);
 1464            RTABSAIDA.IND_TIPO_PROC            := RREG_IND_TIPO_PROC(I);
 1465            RTABSAIDA.NUM_PROC_JUR             := RREG_NUM_PROC_JUR(I);
 1466            RTABSAIDA.NUM_ITEM                 := RREG_NUM_ITEM(I);
 1467            RTABSAIDA.VLR_SERVICO              := RREG_VLR_SERVICO(I);
 1468            RTABSAIDA.IND_TP_PROC_ADJ_ADIC     := RREG_IND_TP_PROC_ADJ_ADIC(I);
 1469            RTABSAIDA.NUM_PROC_ADJ_ADIC        := RREG_NUM_PROC_ADJ_ADIC(I);
 1470            RTABSAIDA.IDENT_SERVICO            := RREG_IDENT_SERVICO(I);
 1471            RTABSAIDA.IDENT_PRODUTO            := RREG_IDENT_PRODUTO(I);
 1472            RTABSAIDA.COD_PARAM                := RREG_COD_PARAM(I);
 1473                       
 1474            GRAVAREGISTRO(RTABSAIDA);
 1475          END; 
 1476        END LOOP;
 1477     
 1478   END MONTAREGISTROS;   
 1479 
 1480   PROCEDURE MONTAREGISTROSSEMTIPOSERV IS
 1481     BEGIN 
 1482       
 1483        FOR I IN 1..RREG_DATA_EMISSAO.COUNT LOOP
 1484          BEGIN    
 1485            
 1486            P_STATUS := 1; 
 1487            RTABSAIDA.COD_EMPRESA              := COD_EMPRESA_W;
 1488            RTABSAIDA.COD_ESTAB                := COD_ESTAB_W;
 1489            RTABSAIDA.DATA_EMISSAO             := RREG_DATA_EMISSAO(I);
 1490            RTABSAIDA.DATA_FISCAL              := RREG_DATA_FISCAL(I);
 1491            RTABSAIDA.IDENT_FIS_JUR            := RREG_IDENT_FIS_JUR(I); 
 1492            RTABSAIDA.IDENT_DOCTO              := RREG_IDENT_DOCTO(I);
 1493            RTABSAIDA.NUM_DOCFIS               := RREG_NUM_DOCFIS(I);
 1494            RTABSAIDA.SERIE_DOCFIS             := RREG_SERIE_DOCFIS(I);                 
 1495            RTABSAIDA.SUB_SERIE_DOCFIS         := RREG_SUB_SERIE_DOCFIS(I);
 1496            RTABSAIDA.COD_USUARIO              := P_COD_USUARIO;
 1497            RTABSAIDA.IDENT_TIPO_SERV_ESOCIAL  := NULL;
 1498            RTABSAIDA.COD_CLASS_DOC_FIS        := RREG_COD_CLASS_DOC_FIS(I);
 1499            RTABSAIDA.VLR_TOT_NOTA             := RREG_VLR_TOT_NOTA(I);
 1500            RTABSAIDA.VLR_CONTAB_COMPL         := RREG_VLR_CONTAB_COMPL(I);
 1501            RTABSAIDA.VLR_BASE_INSS            := RREG_VLR_BASE_INSS(I);
 1502            RTABSAIDA.VLR_ALIQ_INSS            := RREG_VLR_ALIQ_INSS(I);
 1503            RTABSAIDA.VLR_INSS_RETIDO          := RREG_VLR_INSS_RETIDO(I);
 1504            RTABSAIDA.IND_TIPO_PROC            := RREG_IND_TIPO_PROC(I);
 1505            RTABSAIDA.NUM_PROC_JUR             := RREG_NUM_PROC_JUR(I);
 1506            RTABSAIDA.NUM_ITEM                 := RREG_NUM_ITEM(I);
 1507            RTABSAIDA.IND_TP_PROC_ADJ_ADIC     := RREG_IND_TP_PROC_ADJ_ADIC(I);
 1508            RTABSAIDA.NUM_PROC_ADJ_ADIC        := RREG_NUM_PROC_ADJ_ADIC(I);
 1509            RTABSAIDA.IDENT_SERVICO            := RREG_IDENT_SERVICO(I);
 1510            RTABSAIDA.IDENT_PRODUTO            := RREG_IDENT_PRODUTO(I);
 1511            RTABSAIDA.COD_PARAM                := RREG_COD_PARAM(I);
 1512            
 1513            GRAVAREGISTRO(RTABSAIDA);
 1514          END; 
 1515        END LOOP;
 1516     
 1517   END MONTAREGISTROSSEMTIPOSERV;   
 1518   
 1519   
 1520   
 1521   
 1522   
 1523   
 1524   
 1525   
 1526   
 1527   
 1528   PROCEDURE RECREGISTROSSERVRETPREV IS
 1529     BEGIN
 1530     
 1531       OPEN C_CONF_RET_PREV(COD_EMPRESA_W, 
 1532                            COD_ESTAB_W,
 1533                            DATA_INI_W,
 1534                            DATA_FIM_W);
 1535       
 1536       LOOP
 1537         FETCH C_CONF_RET_PREV BULK COLLECT INTO RREG_DATA_EMISSAO,       
 1538                                                RREG_DATA_FISCAL,     
 1539                                                RREG_IDENT_FIS_JUR,      
 1540                                                RREG_IDENT_DOCTO,       
 1541                                                RREG_NUM_DOCFIS,     
 1542                                                RREG_SERIE_DOCFIS, 
 1543                                                RREG_SUB_SERIE_DOCFIS,   
 1544                                                RREG_IDENT_TIPO_SERV_ESOCIAL,       
 1545                                                RREG_COD_CLASS_DOC_FIS,                                                   
 1546                                                RREG_VLR_TOT_NOTA,                                                   
 1547                                                RREG_VLR_CONTAB_COMPL,                                                   
 1548                                                RREG_VLR_BASE_INSS,                                                   
 1549                                                RREG_VLR_ALIQ_INSS,                                                   
 1550                                                RREG_VLR_INSS_RETIDO,                                                   
 1551                                                RREG_IND_TIPO_PROC,                                                   
 1552                                                RREG_NUM_PROC_JUR,
 1553                                                RREG_NUM_ITEM,
 1554                                                RREG_VLR_SERVICO,                                                   
 1555                                                RREG_IND_TP_PROC_ADJ_ADIC,                                                   
 1556                                                RREG_NUM_PROC_ADJ_ADIC,
 1557                                                RREG_IDENT_SERVICO,
 1558                                                RREG_IDENT_PRODUTO,
 1559                                                RREG_COD_PARAM LIMIT 1000;  
 1560                                                           
 1561         MONTAREGISTROS;
 1562         EXIT WHEN C_CONF_RET_PREV%NOTFOUND;
 1563      END LOOP;
 1564      COMMIT;
 1565      CLOSE C_CONF_RET_PREV;    
 1566     
 1567   END RECREGISTROSSERVRETPREV;
 1568 
 1569  
 1570 
 1571  PROCEDURE RECREGISTROSSEMTIPOSERV IS
 1572     BEGIN
 1573 
 1574       OPEN C_CONF_SEM_TIPO_SERV(COD_EMPRESA_W, 
 1575                                  COD_ESTAB_W,
 1576                                  DATA_INI_W,
 1577                                  DATA_FIM_W);
 1578       
 1579       LOOP
 1580         FETCH C_CONF_SEM_TIPO_SERV BULK COLLECT INTO RREG_DATA_EMISSAO,       
 1581                                                RREG_DATA_FISCAL,     
 1582                                                RREG_IDENT_FIS_JUR,      
 1583                                                RREG_IDENT_DOCTO,       
 1584                                                RREG_NUM_DOCFIS,     
 1585                                                RREG_SERIE_DOCFIS, 
 1586                                                RREG_SUB_SERIE_DOCFIS,   
 1587                                                RREG_IDENT_TIPO_SERV_ESOCIAL,
 1588                                                RREG_COD_CLASS_DOC_FIS,                                                   
 1589                                                RREG_VLR_TOT_NOTA,                                                   
 1590                                                RREG_VLR_CONTAB_COMPL,                                                   
 1591                                                RREG_VLR_BASE_INSS,                                                   
 1592                                                RREG_VLR_ALIQ_INSS,                                                   
 1593                                                RREG_VLR_INSS_RETIDO,                                                   
 1594                                                RREG_IND_TIPO_PROC,                                                   
 1595                                                RREG_NUM_PROC_JUR,
 1596                                                RREG_NUM_ITEM,
 1597                                                RREG_VLR_SERVICO,                                                   
 1598                                                RREG_IND_TP_PROC_ADJ_ADIC,                                                   
 1599                                                RREG_NUM_PROC_ADJ_ADIC,
 1600                                                RREG_IDENT_SERVICO,
 1601                                                RREG_IDENT_PRODUTO,
 1602                                                RREG_COD_PARAM LIMIT 1000;  
 1603                                                           
 1604         MONTAREGISTROS;
 1605         EXIT WHEN C_CONF_SEM_TIPO_SERV%NOTFOUND;
 1606      END LOOP;
 1607      COMMIT;
 1608      CLOSE C_CONF_SEM_TIPO_SERV;    
 1609     
 1610   END RECREGISTROSSEMTIPOSERV;
 1611   
 1612  
 1613   PROCEDURE RECREGISTROSRETPREVPROC IS
 1614     BEGIN
 1615 
 1616       OPEN C_CONF_RET_PREV_PROC(COD_EMPRESA_W, 
 1617                            COD_ESTAB_W,
 1618                            DATA_INI_W,
 1619                            DATA_FIM_W);
 1620       
 1621       LOOP
 1622         FETCH C_CONF_RET_PREV_PROC BULK COLLECT INTO RREG_DATA_EMISSAO,       
 1623                                                RREG_DATA_FISCAL,     
 1624                                                RREG_IDENT_FIS_JUR,      
 1625                                                RREG_IDENT_DOCTO,       
 1626                                                RREG_NUM_DOCFIS,     
 1627                                                RREG_SERIE_DOCFIS, 
 1628                                                RREG_SUB_SERIE_DOCFIS,   
 1629                                                RREG_IDENT_TIPO_SERV_ESOCIAL,       
 1630                                                RREG_COD_CLASS_DOC_FIS,                                                   
 1631                                                RREG_VLR_TOT_NOTA,                                                   
 1632                                                RREG_VLR_CONTAB_COMPL,                                                   
 1633                                                RREG_VLR_BASE_INSS,                                                   
 1634                                                RREG_VLR_ALIQ_INSS,                                                   
 1635                                                RREG_VLR_INSS_RETIDO,                                                   
 1636                                                RREG_IND_TIPO_PROC,                                                   
 1637                                                RREG_NUM_PROC_JUR,
 1638                                                RREG_NUM_ITEM,
 1639                                                RREG_VLR_SERVICO,                                                   
 1640                                                RREG_IND_TP_PROC_ADJ_ADIC,                                                   
 1641                                                RREG_NUM_PROC_ADJ_ADIC,
 1642                                                RREG_IDENT_SERVICO,
 1643                                                RREG_IDENT_PRODUTO,
 1644                                                RREG_COD_PARAM LIMIT 1000;  
 1645                                                           
 1646         MONTAREGISTROS; 
 1647         EXIT WHEN C_CONF_RET_PREV_PROC%NOTFOUND;
 1648      END LOOP;
 1649      COMMIT;
 1650      CLOSE C_CONF_RET_PREV_PROC;    
 1651     
 1652   END RECREGISTROSRETPREVPROC;
 1653   
 1654   
 1655   PROCEDURE RECREGISTROSRETPREVSEMPROC IS
 1656     BEGIN
 1657 
 1658       OPEN C_CONF_RET_PREV_SEM_PROC(COD_EMPRESA_W, 
 1659                            COD_ESTAB_W,
 1660                            DATA_INI_W,
 1661                            DATA_FIM_W);
 1662       
 1663       LOOP
 1664         FETCH C_CONF_RET_PREV_SEM_PROC BULK COLLECT INTO RREG_DATA_EMISSAO,       
 1665                                                RREG_DATA_FISCAL,     
 1666                                                RREG_IDENT_FIS_JUR,      
 1667                                                RREG_IDENT_DOCTO,       
 1668                                                RREG_NUM_DOCFIS,     
 1669                                                RREG_SERIE_DOCFIS, 
 1670                                                RREG_SUB_SERIE_DOCFIS,   
 1671                                                RREG_IDENT_TIPO_SERV_ESOCIAL,       
 1672                                                RREG_COD_CLASS_DOC_FIS,                                                   
 1673                                                RREG_VLR_TOT_NOTA,                                                   
 1674                                                RREG_VLR_CONTAB_COMPL,                                                   
 1675                                                RREG_VLR_BASE_INSS,                                                   
 1676                                                RREG_VLR_ALIQ_INSS,                                                   
 1677                                                RREG_VLR_INSS_RETIDO,                                                   
 1678                                                RREG_IND_TIPO_PROC,                                                   
 1679                                                RREG_NUM_PROC_JUR,
 1680                                                RREG_NUM_ITEM,
 1681                                                RREG_VLR_SERVICO,                                                   
 1682                                                RREG_IND_TP_PROC_ADJ_ADIC,                                                   
 1683                                                RREG_NUM_PROC_ADJ_ADIC,
 1684                                                RREG_IDENT_SERVICO,
 1685                                                RREG_IDENT_PRODUTO,
 1686                                                RREG_COD_PARAM LIMIT 1000;  
 1687                                                           
 1688         MONTAREGISTROS; 
 1689         EXIT WHEN C_CONF_RET_PREV_SEM_PROC%NOTFOUND;
 1690      END LOOP;
 1691      COMMIT;
 1692      CLOSE C_CONF_RET_PREV_SEM_PROC;    
 1693     
 1694   END RECREGISTROSRETPREVSEMPROC;
 1695   
 1696   
 1697   
 1698   PROCEDURE RECREGISTROSINSSMAIORBRUTO IS
 1699     BEGIN
 1700 
 1701       OPEN C_CONF_INSS_MAIOR_BRUTO(COD_EMPRESA_W, 
 1702                            COD_ESTAB_W,
 1703                            DATA_INI_W,
 1704                            DATA_FIM_W);
 1705       
 1706       LOOP
 1707         FETCH C_CONF_INSS_MAIOR_BRUTO BULK COLLECT INTO RREG_DATA_EMISSAO,       
 1708                                                RREG_DATA_FISCAL,     
 1709                                                RREG_IDENT_FIS_JUR,      
 1710                                                RREG_IDENT_DOCTO,       
 1711                                                RREG_NUM_DOCFIS,     
 1712                                                RREG_SERIE_DOCFIS, 
 1713                                                RREG_SUB_SERIE_DOCFIS,   
 1714                                                RREG_IDENT_TIPO_SERV_ESOCIAL,       
 1715                                                RREG_COD_CLASS_DOC_FIS,                                                   
 1716                                                RREG_VLR_TOT_NOTA,                                                   
 1717                                                RREG_VLR_CONTAB_COMPL,                                                   
 1718                                                RREG_VLR_BASE_INSS,                                                   
 1719                                                RREG_VLR_ALIQ_INSS,                                                   
 1720                                                RREG_VLR_INSS_RETIDO,                                                   
 1721                                                RREG_IND_TIPO_PROC,                                                   
 1722                                                RREG_NUM_PROC_JUR,
 1723                                                RREG_NUM_ITEM,
 1724                                                RREG_VLR_SERVICO,                                                   
 1725                                                RREG_IND_TP_PROC_ADJ_ADIC,                                                   
 1726                                                RREG_NUM_PROC_ADJ_ADIC,
 1727                                                RREG_IDENT_SERVICO,
 1728                                                RREG_IDENT_PRODUTO,
 1729                                                RREG_COD_PARAM LIMIT 1000;  
 1730                                                           
 1731         MONTAREGISTROS; 
 1732         EXIT WHEN C_CONF_INSS_MAIOR_BRUTO%NOTFOUND;
 1733      END LOOP;
 1734      COMMIT;
 1735      CLOSE C_CONF_INSS_MAIOR_BRUTO;    
 1736     
 1737   END RECREGISTROSINSSMAIORBRUTO;
 1738   
 1739   
 1740   PROCEDURE RECREGISTROSINSSALIQDIFINFORM IS
 1741     BEGIN
 1742 
 1743       OPEN C_CONF_INSS_ALIQ_DIF_INFORMADO(COD_EMPRESA_W, 
 1744                            COD_ESTAB_W,
 1745                            DATA_INI_W,
 1746                            DATA_FIM_W);
 1747       
 1748       LOOP
 1749         FETCH C_CONF_INSS_ALIQ_DIF_INFORMADO BULK COLLECT INTO RREG_DATA_EMISSAO,       
 1750                                                RREG_DATA_FISCAL,     
 1751                                                RREG_IDENT_FIS_JUR,      
 1752                                                RREG_IDENT_DOCTO,       
 1753                                                RREG_NUM_DOCFIS,     
 1754                                                RREG_SERIE_DOCFIS, 
 1755                                                RREG_SUB_SERIE_DOCFIS,   
 1756                                                RREG_IDENT_TIPO_SERV_ESOCIAL,       
 1757                                                RREG_COD_CLASS_DOC_FIS,                                                   
 1758                                                RREG_VLR_TOT_NOTA,                                                   
 1759                                                RREG_VLR_CONTAB_COMPL,                                                   
 1760                                                RREG_VLR_BASE_INSS,                                                   
 1761                                                RREG_VLR_ALIQ_INSS,                                                   
 1762                                                RREG_VLR_INSS_RETIDO,                                                   
 1763                                                RREG_IND_TIPO_PROC,                                                   
 1764                                                RREG_NUM_PROC_JUR,
 1765                                                RREG_NUM_ITEM,
 1766                                                RREG_VLR_SERVICO,                                                   
 1767                                                RREG_IND_TP_PROC_ADJ_ADIC,                                                   
 1768                                                RREG_NUM_PROC_ADJ_ADIC,
 1769                                                RREG_IDENT_SERVICO,
 1770                                                RREG_IDENT_PRODUTO,
 1771                                                RREG_COD_PARAM LIMIT 1000;  
 1772                                                           
 1773         MONTAREGISTROS; 
 1774         EXIT WHEN C_CONF_INSS_ALIQ_DIF_INFORMADO%NOTFOUND;
 1775      END LOOP;
 1776      COMMIT;
 1777      CLOSE C_CONF_INSS_ALIQ_DIF_INFORMADO;    
 1778     
 1779   END RECREGISTROSINSSALIQDIFINFORM;
 1780   
 1781  
 1782   PROCEDURE RECREGISTROSALIQINSSINVALIDA IS
 1783     BEGIN
 1784 
 1785       OPEN C_CONF_ALIQ_INSS_INVALIDA(COD_EMPRESA_W, 
 1786                            COD_ESTAB_W,
 1787                            DATA_INI_W,
 1788                            DATA_FIM_W);
 1789       
 1790       LOOP
 1791         FETCH C_CONF_ALIQ_INSS_INVALIDA BULK COLLECT INTO RREG_DATA_EMISSAO,       
 1792                                                RREG_DATA_FISCAL,     
 1793                                                RREG_IDENT_FIS_JUR,      
 1794                                                RREG_IDENT_DOCTO,       
 1795                                                RREG_NUM_DOCFIS,     
 1796                                                RREG_SERIE_DOCFIS, 
 1797                                                RREG_SUB_SERIE_DOCFIS,   
 1798                                                RREG_IDENT_TIPO_SERV_ESOCIAL,       
 1799                                                RREG_COD_CLASS_DOC_FIS,                                                   
 1800                                                RREG_VLR_TOT_NOTA,                                                   
 1801                                                RREG_VLR_CONTAB_COMPL,                                                   
 1802                                                RREG_VLR_BASE_INSS,                                                   
 1803                                                RREG_VLR_ALIQ_INSS,                                                   
 1804                                                RREG_VLR_INSS_RETIDO,                                                   
 1805                                                RREG_IND_TIPO_PROC,                                                   
 1806                                                RREG_NUM_PROC_JUR,
 1807                                                RREG_NUM_ITEM,
 1808                                                RREG_VLR_SERVICO,                                                   
 1809                                                RREG_IND_TP_PROC_ADJ_ADIC,                                                   
 1810                                                RREG_NUM_PROC_ADJ_ADIC,
 1811                                                RREG_IDENT_SERVICO,
 1812                                                RREG_IDENT_PRODUTO,
 1813                                                RREG_COD_PARAM LIMIT 1000;  
 1814                                                           
 1815         MONTAREGISTROS; 
 1816         EXIT WHEN C_CONF_ALIQ_INSS_INVALIDA%NOTFOUND;
 1817      END LOOP;
 1818      COMMIT;
 1819      CLOSE C_CONF_ALIQ_INSS_INVALIDA;    
 1820     
 1821   END RECREGISTROSALIQINSSINVALIDA;      
 1822  
 1823   
 1824 BEGIN
 1825   
 1826    P_STATUS := 0;
 1827     
 1828    COD_EMPRESA_W  := P_COD_EMPRESA;
 1829    COD_ESTAB_W    := P_COD_ESTAB;
 1830    DATA_INI_W     := P_DATA_INICIAL;
 1831    DATA_FIM_W     := P_DATA_FINAL;   
 1832    
 1833    
 1834    
 1835     
 1836    IF P_TIPO_SELEC = '1' THEN   
 1837      RECREGISTROSSERVRETPREV;
 1838      
 1839    ELSIF P_TIPO_SELEC = '2' THEN 
 1840      RECREGISTROSSEMTIPOSERV;
 1841 
 1842    ELSIF P_TIPO_SELEC = '3' THEN 
 1843      RECREGISTROSRETPREVPROC;
 1844      
 1845    ELSIF P_TIPO_SELEC = '4' THEN 
 1846      RECREGISTROSRETPREVSEMPROC;
 1847      
 1848    ELSIF P_TIPO_SELEC = '5' THEN 
 1849      RECREGISTROSINSSMAIORBRUTO;
 1850      
 1851    ELSIF P_TIPO_SELEC = '6' THEN 
 1852      RECREGISTROSINSSALIQDIFINFORM;
 1853      
 1854    ELSIF P_TIPO_SELEC = '7' THEN 
 1855      RECREGISTROSALIQINSSINVALIDA;               
 1856      
 1857    END IF; 
 1858 
 1859 EXCEPTION
 1860    WHEN NO_DATA_FOUND THEN  
 1861      P_STATUS := 0;
 1862       RETURN;
 1863    WHEN OTHERS THEN
 1864       P_STATUS := -1;
 1865       RETURN;
 1866 
 1867 END REINF_CONF_RETENCAO;