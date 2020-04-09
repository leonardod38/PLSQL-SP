Prompt Table DPSP_PRECO_ITEM_GTT;
--
-- DPSP_PRECO_ITEM_GTT  (Table) 
--
CREATE GLOBAL TEMPORARY TABLE MSAFI.DPSP_PRECO_ITEM_GTT
(
  SETID             VARCHAR2(5 BYTE)            NOT NULL,
  INV_ITEM_ID       VARCHAR2(18 BYTE)           NOT NULL,
  DSP_ALIQ_ICMS_ID  VARCHAR2(10 BYTE)           NOT NULL,
  UNIT_OF_MEASURE   VARCHAR2(3 BYTE)            NOT NULL,
  EFFDT             DATE                        NOT NULL,
  PRICE             NUMBER(14,4)                NOT NULL,
  CURRENCY_CD       VARCHAR2(3 BYTE)            NOT NULL,
  DSP_PMC           NUMBER(15,5)                NOT NULL
)
ON COMMIT PRESERVE ROWS
NOCACHE
/