Prompt Table DPSP_ENTRADA_NF_DP908_GTT;
--
-- DPSP_ENTRADA_NF_DP908_GTT  (Table) 
--
CREATE GLOBAL TEMPORARY TABLE MSAFI.DPSP_ENTRADA_NF_DP908_GTT
(
  COD_EMPRESA       VARCHAR2(3 BYTE),
  COD_ESTAB         VARCHAR2(6 BYTE),
  DATA_FISCAL       DATE,
  MOVTO_E_S         VARCHAR2(1 BYTE),
  NORM_DEV          VARCHAR2(1 BYTE),
  IDENT_DOCTO       NUMBER(12),
  IDENT_FIS_JUR     NUMBER(12),
  NUM_DOCFIS        VARCHAR2(12 BYTE),
  SERIE_DOCFIS      VARCHAR2(3 BYTE),
  SUB_SERIE_DOCFIS  VARCHAR2(2 BYTE),
  DISCRI_ITEM       VARCHAR2(46 BYTE),
  NUM_AUTENTIC_NFE  VARCHAR2(80 BYTE),
  COD_PRODUTO       VARCHAR2(35 BYTE),
  NUM_ITEM          NUMBER(5)
)
ON COMMIT PRESERVE ROWS
NOCACHE
/


Prompt Index GTT_IX;
--
-- GTT_IX  (Index) 
--
CREATE INDEX GTT_IX ON MSAFI.DPSP_ENTRADA_NF_DP908_GTT
(COD_PRODUTO, NUM_AUTENTIC_NFE, NUM_ITEM)
/
