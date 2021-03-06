Prompt Table X08_ITENS_MERC_GTT;
--
-- X08_ITENS_MERC_GTT  (Table) 
--
CREATE GLOBAL TEMPORARY TABLE MSAFI.X08_ITENS_MERC_GTT
(
  COD_EMPRESA              VARCHAR2(3 BYTE),
  COD_ESTAB                VARCHAR2(6 BYTE),
  DATA_FISCAL              DATE,
  MOVTO_E_S                CHAR(1 BYTE),
  NORM_DEV                 CHAR(1 BYTE),
  IDENT_DOCTO              NUMBER(12),
  IDENT_FIS_JUR            NUMBER(12),
  NUM_DOCFIS               VARCHAR2(12 BYTE),
  SERIE_DOCFIS             VARCHAR2(3 BYTE),
  SUB_SERIE_DOCFIS         VARCHAR2(2 BYTE),
  DISCRI_ITEM              VARCHAR2(46 BYTE),
  IDENT_PRODUTO            NUMBER(12),
  IDENT_UND_PADRAO         NUMBER(12),
  COD_BEM                  VARCHAR2(30 BYTE),
  COD_INC_BEM              VARCHAR2(6 BYTE),
  VALID_BEM                DATE,
  NUM_ITEM                 NUMBER(5),
  IDENT_ALMOX              NUMBER(12),
  IDENT_CUSTO              NUMBER(12),
  DESCRICAO_COMPL          VARCHAR2(50 BYTE),
  IDENT_CFO                NUMBER(12),
  IDENT_NATUREZA_OP        NUMBER(12),
  IDENT_NBM                NUMBER(12),
  QUANTIDADE               NUMBER(17,6),
  IDENT_MEDIDA             NUMBER(12),
  VLR_UNIT                 NUMBER(19,4),
  VLR_ITEM                 NUMBER(17,2),
  VLR_DESCONTO             NUMBER(17,2),
  VLR_FRETE                NUMBER(17,2),
  VLR_SEGURO               NUMBER(17,2),
  VLR_OUTRAS               NUMBER(17,2),
  IDENT_SITUACAO_A         NUMBER(12),
  IDENT_SITUACAO_B         NUMBER(12),
  IDENT_FEDERAL            NUMBER(12),
  IND_IPI_INCLUSO          CHAR(1 BYTE),
  NUM_ROMANEIO             VARCHAR2(12 BYTE),
  DATA_ROMANEIO            DATE,
  PESO_LIQUIDO             NUMBER(14,3),
  COD_INDICE               VARCHAR2(10 BYTE),
  VLR_ITEM_CONVER          NUMBER(17,2),
  NUM_PROCESSO             NUMBER(12),
  IND_GRAVACAO             CHAR(1 BYTE),
  VLR_CONTAB_COMPL         NUMBER(17,2),
  VLR_ALIQ_DESTINO         NUMBER(7,4),
  VLR_OUTROS1              NUMBER(17,2),
  VLR_OUTROS2              NUMBER(17,2),
  VLR_OUTROS3              NUMBER(17,2),
  VLR_OUTROS4              NUMBER(17,2),
  VLR_OUTROS5              NUMBER(17,2),
  VLR_ALIQ_OUTROS1         NUMBER(7,4),
  VLR_ALIQ_OUTROS2         NUMBER(7,4),
  VLR_CONTAB_ITEM          NUMBER(17,2),
  COD_OBS_VCONT_COMP       VARCHAR2(10 BYTE),
  COD_OBS_VCONT_ITEM       VARCHAR2(10 BYTE),
  VLR_OUTROS_ICMS          NUMBER(17,2),
  VLR_OUTROS_IPI           NUMBER(17,2),
  IND_RESP_VCONT_ITM       CHAR(1 BYTE),
  NUM_ATO_CONCES           VARCHAR2(15 BYTE),
  DAT_EMBARQUE             DATE,
  NUM_REG_EXP              VARCHAR2(12 BYTE),
  NUM_DESP_EXP             VARCHAR2(11 BYTE),
  VLR_TOM_SERVICO          NUMBER(17,2),
  VLR_DESP_MOEDA_EXP       NUMBER(17,2),
  COD_MOEDA_NEGOC          VARCHAR2(10 BYTE),
  COD_PAIS_DEST_ORIG       VARCHAR2(3 BYTE),
  COD_TRIB_INT             NUMBER(5),
  VLR_ICMS_NDESTAC         NUMBER(17,2),
  VLR_IPI_NDESTAC          NUMBER(17,2),
  VLR_BASE_PIS             NUMBER(17,2),
  VLR_PIS                  NUMBER(17,2),
  VLR_BASE_COFINS          NUMBER(17,2),
  VLR_COFINS               NUMBER(17,2),
  BASE_ICMS_ORIGDEST       NUMBER(17,2),
  VLR_ICMS_ORIGDEST        NUMBER(17,2),
  ALIQ_ICMS_ORIGDEST       NUMBER(7,4),
  VLR_DESC_CONDIC          NUMBER(17,2),
  VLR_CUSTO_TRANSF         NUMBER(17,6),
  PERC_RED_BASE_ICMS       NUMBER(7,4),
  QTD_EMBARCADA            NUMBER(17,6),
  DAT_REGISTRO_EXP         DATE,
  DAT_DESPACHO             DATE,
  DAT_AVERBACAO            DATE,
  DAT_DI                   DATE,
  NUM_DEC_IMP_REF          VARCHAR2(12 BYTE),
  DSC_MOT_OCOR             VARCHAR2(45 BYTE),
  IDENT_CONTA              NUMBER(12),
  VLR_BASE_ICMS_ORIG       NUMBER(17,2),
  VLR_TRIB_ICMS_ORIG       NUMBER(17,2),
  VLR_BASE_ICMS_DEST       NUMBER(17,2),
  VLR_TRIB_ICMS_DEST       NUMBER(17,2),
  VLR_PERC_PRES_ICMS       NUMBER(7,4),
  VLR_PRECO_BASE_ST        NUMBER(17,2),
  IDENT_OPER_OIL           NUMBER(12),
  COD_DCR                  VARCHAR2(15 BYTE),
  IDENT_PROJETO            NUMBER(12),
  DAT_OPERACAO             DATE,
  USUARIO                  VARCHAR2(40 BYTE),
  IND_MOV_FIS              CHAR(1 BYTE),
  CHASSI                   VARCHAR2(17 BYTE),
  NUM_DOCFIS_REF           VARCHAR2(12 BYTE),
  SERIE_DOCFIS_REF         VARCHAR2(3 BYTE),
  SSERIE_DOCFIS_REF        VARCHAR2(2 BYTE),
  VLR_BASE_PIS_ST          NUMBER(17,2),
  VLR_ALIQ_PIS_ST          NUMBER(7,4),
  VLR_PIS_ST               NUMBER(17,2),
  VLR_BASE_COFINS_ST       NUMBER(17,2),
  VLR_ALIQ_COFINS_ST       NUMBER(7,4),
  VLR_COFINS_ST            NUMBER(17,2),
  VLR_BASE_CSLL            NUMBER(17,2),
  VLR_ALIQ_CSLL            NUMBER(7,4),
  VLR_CSLL                 NUMBER(17,2),
  VLR_ALIQ_PIS             NUMBER(7,4),
  VLR_ALIQ_COFINS          NUMBER(7,4),
  IND_SITUACAO_ESP_ST      CHAR(1 BYTE),
  VLR_ICMSS_NDESTAC        NUMBER(17,2),
  IND_DOCTO_REC            CHAR(1 BYTE),
  DAT_PGTO_GNRE_DARJ       DATE,
  VLR_CUSTO_UNIT           NUMBER(17,2),
  VLR_FATOR_CONV           NUMBER(17,6),
  QUANTIDADE_CONV          NUMBER(17,6),
  VLR_FECP_ICMS            NUMBER(17,2),
  VLR_FECP_DIFALIQ         NUMBER(17,2),
  VLR_FECP_ICMS_ST         NUMBER(17,2),
  VLR_FECP_FONTE           NUMBER(17,2),
  VLR_BASE_ICMSS_N_ESCRIT  NUMBER(17,2),
  VLR_ICMSS_N_ESCRIT       NUMBER(17,2),
  VLR_AJUSTE_COND_PG       NUMBER(17,2),
  COD_TRIB_IPI             VARCHAR2(2 BYTE),
  LOTE_MEDICAMENTO         VARCHAR2(50 BYTE),
  VALID_MEDICAMENTO        DATE,
  IND_BASE_MEDICAMENTO     CHAR(1 BYTE),
  VLR_PRECO_MEDICAMENTO    NUMBER(17,2),
  IND_TIPO_ARMA            CHAR(1 BYTE),
  NUM_SERIE_ARMA           VARCHAR2(50 BYTE),
  NUM_CANO_ARMA            VARCHAR2(50 BYTE),
  DSC_ARMA                 VARCHAR2(100 BYTE),
  IDENT_OBSERVACAO         NUMBER(12),
  COD_EX_NCM               VARCHAR2(2 BYTE),
  COD_EX_IMP               VARCHAR2(2 BYTE),
  CNPJ_OPERADORA           VARCHAR2(14 BYTE),
  CPF_OPERADORA            VARCHAR2(14 BYTE),
  IDENT_UF_OPERADORA       NUMBER(12),
  INS_EST_OPERADORA        VARCHAR2(14 BYTE),
  IND_ESPECIF_RECEITA      CHAR(1 BYTE),
  COD_CLASS_ITEM           VARCHAR2(4 BYTE),
  VLR_TERCEIROS            NUMBER(17,2),
  VLR_PRECO_SUGER          NUMBER(17,2),
  VLR_BASE_CIDE            NUMBER(17,2),
  VLR_ALIQ_CIDE            NUMBER(7,4),
  VLR_CIDE                 NUMBER(17,2),
  COD_OPER_ESP_ST          CHAR(1 BYTE),
  VLR_COMISSAO             NUMBER(17,2),
  VLR_ICMS_FRETE           NUMBER(17,2),
  VLR_DIFAL_FRETE          NUMBER(17,2),
  IND_VLR_PIS_COFINS       CHAR(1 BYTE)         DEFAULT 'N',
  COD_ENQUAD_IPI           VARCHAR2(3 BYTE),
  COD_SITUACAO_PIS         NUMBER(2),
  QTD_BASE_PIS             NUMBER(18,3),
  VLR_ALIQ_PIS_R           NUMBER(19,4),
  COD_SITUACAO_COFINS      NUMBER(2),
  QTD_BASE_COFINS          NUMBER(18,3),
  VLR_ALIQ_COFINS_R        NUMBER(19,4),
  ITEM_PORT_TARE           VARCHAR2(2 BYTE),
  VLR_FUNRURAL             NUMBER(17,2),
  IND_TP_PROD_MEDIC        CHAR(1 BYTE),
  VLR_CUSTO_DCA            NUMBER(21,6),
  COD_TP_LANCTO            NUMBER(6),
  VLR_PERC_CRED_OUT        NUMBER(7,4),
  VLR_CRED_OUT             NUMBER(17,2),
  VLR_ICMS_DCA             NUMBER(21,6),
  VLR_PIS_EXP              NUMBER(17,2),
  VLR_PIS_TRIB             NUMBER(17,2),
  VLR_PIS_N_TRIB           NUMBER(17,2),
  VLR_COFINS_EXP           NUMBER(17,2),
  VLR_COFINS_TRIB          NUMBER(17,2),
  VLR_COFINS_N_TRIB        NUMBER(17,2),
  COD_ENQ_LEGAL            NUMBER(4),
  IND_GRAVACAO_SAICS       CHAR(1 BYTE),
  DAT_LANC_PIS_COFINS      DATE,
  IND_PIS_COFINS_EXTEMP    CHAR(1 BYTE),
  IND_NATUREZA_FRETE       CHAR(1 BYTE),
  COD_NAT_REC              NUMBER(3),
  IND_NAT_BASE_CRED        VARCHAR2(2 BYTE),
  VLR_ACRESCIMO            NUMBER(17,2),
  DSC_RESERVADO1           VARCHAR2(50 BYTE),
  DSC_RESERVADO2           VARCHAR2(50 BYTE),
  DSC_RESERVADO3           VARCHAR2(50 BYTE),
  COD_TRIB_PROD            VARCHAR2(4 BYTE),
  DSC_RESERVADO4           VARCHAR2(50 BYTE),
  DSC_RESERVADO5           VARCHAR2(50 BYTE),
  DSC_RESERVADO6           NUMBER(17,2),
  DSC_RESERVADO7           NUMBER(17,2),
  DSC_RESERVADO8           NUMBER(17,2),
  INDICE_PROD_ACAB         VARCHAR2(3 BYTE),
  VLR_BASE_DIA_AM          NUMBER(17,2),
  VLR_ALIQ_DIA_AM          NUMBER(7,4),
  VLR_ICMS_DIA_AM          NUMBER(17,2),
  VLR_ADUANEIRO            NUMBER(17,2),
  COD_SITUACAO_PIS_ST      NUMBER(2),
  COD_SITUACAO_COFINS_ST   NUMBER(2),
  VLR_ALIQ_DCIP            NUMBER(7,4),
  NUM_LI                   VARCHAR2(10 BYTE),
  VLR_FCP_UF_DEST          NUMBER(17,2),
  VLR_ICMS_UF_DEST         NUMBER(17,2),
  VLR_ICMS_UF_ORIG         NUMBER(17,2),
  VLR_DIF_DUB              NUMBER(17,2),
  VLR_ICMS_NAO_DEST        NUMBER(17,2),
  VLR_BASE_ICMS_NAO_DEST   NUMBER(17,2),
  VLR_ALIQ_ICMS_NAO_DEST   NUMBER(7,4),
  IND_MOTIVO_RES           CHAR(1 BYTE),
  NUM_DOCFIS_RET           VARCHAR2(12 BYTE),
  SERIE_DOCFIS_RET         VARCHAR2(3 BYTE),
  NUM_AUTENTIC_NFE_RET     VARCHAR2(80 BYTE),
  NUM_ITEM_RET             NUMBER(5),
  IDENT_FIS_JUR_RET        NUMBER(12),
  IND_TP_DOC_ARREC         CHAR(1 BYTE),
  NUM_DOC_ARREC            VARCHAR2(50 BYTE),
  IDENT_CFO_DCIP           NUMBER(12),
  VLR_BASE_INSS            NUMBER(17,2),
  VLR_INSS_RETIDO          NUMBER(17,2),
  VLR_TOT_ADIC             NUMBER(17,2),
  VLR_N_RET_PRINC          NUMBER(17,2),
  VLR_N_RET_ADIC           NUMBER(17,2),
  VLR_ALIQ_INSS            NUMBER(7,4),
  VLR_RET_SERV             NUMBER(17,2),
  VLR_SERV_15              NUMBER(17,2),
  VLR_SERV_20              NUMBER(17,2),
  VLR_SERV_25              NUMBER(17,2),
  IND_TP_PROC_ADJ_PRINC    CHAR(1 BYTE),
  IDENT_PROC_ADJ_PRINC     NUMBER(12),
  IDENT_SUSP_TBT_PRINC     NUMBER(12),
  NUM_PROC_ADJ_PRINC       VARCHAR2(21 BYTE),
  IND_TP_PROC_ADJ_ADIC     CHAR(1 BYTE),
  IDENT_PROC_ADJ_ADIC      NUMBER(12),
  IDENT_SUSP_TBT_ADIC      NUMBER(12),
  NUM_PROC_ADJ_ADIC        VARCHAR2(21 BYTE),
  VLR_IPI_DEV              NUMBER(17,2),
  COD_BENEFICIO            VARCHAR2(10 BYTE),
  VLR_ABAT_NTRIBUTADO      NUMBER(17,2)
)
ON COMMIT PRESERVE ROWS
NOCACHE
/


Prompt Index IDX_00002;
--
-- IDX_00002  (Index) 
--
CREATE UNIQUE INDEX IDX_00002 ON MSAFI.X08_ITENS_MERC_GTT
(COD_EMPRESA, COD_ESTAB, DATA_FISCAL, MOVTO_E_S, NORM_DEV, 
IDENT_DOCTO, IDENT_FIS_JUR, NUM_DOCFIS, SERIE_DOCFIS, SUB_SERIE_DOCFIS, 
DISCRI_ITEM)
/
