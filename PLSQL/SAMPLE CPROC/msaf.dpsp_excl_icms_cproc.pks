Prompt Package DPSP_EXCL_ICMS_CPROC;
--
-- DPSP_EXCL_ICMS_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dpsp_excl_icms_cproc
IS
    /*
    CREATE TABLE DPSP_PS_LISTA(COD_PRODUTO VARCHAR2(100), LISTA CHAR(1), EFFDT DATE) ;
    ALTER TABLE DPSP_PS_LISTA INMEMORY;

    CREATE TABLE DPSP_NFS_ULT_ENTRADA
    (
    COD_EMPRESA        VARCHAR2(3),
    COD_ESTAB          VARCHAR2(6),
    DATA_FISCAL        DATE,
    COD_DOCTO          VARCHAR2(5),
    COD_FIS_JUR        VARCHAR2(14),
    NUM_DOCFIS         VARCHAR2(12),
    SERIE_DOCFIS       VARCHAR2(3),
    NUM_CONTROLE_DOCTO VARCHAR2(12),
    NUM_AUTENTIC_NFE   VARCHAR2(80),
    COD_PRODUTO        VARCHAR2(35),
    NUM_ITEM           NUMBER(5),
    COD_CFO            VARCHAR2(4),
    COD_SITUACAO_B     VARCHAR2(2),
    COD_NATUREZA_OP    VARCHAR2(3),
    LISTA              CHAR(1),
    QUANTIDADE         NUMBER(17,6),
    VLR_ITEM           NUMBER(17,2),
    VLR_CONTAB_ITEM    NUMBER(17,2),
    VLR_OUTRAS         NUMBER(17,2),
    VLR_DESCONTO       NUMBER(17,2),
    BASE_ICMS_TRIB     NUMBER,
    ALIQ_ICMS          NUMBER,
    VLR_ICMS           NUMBER,
    BASE_ICMS_ISENTA   NUMBER,
    BASE_ICMS_OUTRAS   NUMBER,
    BASE_ICMSS         NUMBER,
    ALIQ_ICMSS         NUMBER,
    VLR_ICMSS          NUMBER,
    VLR_BASE_PIS       NUMBER(17,2),
    VLR_ALIQ_PIS       NUMBER(7,4),
    VLR_PIS            NUMBER(17,2),
    VLR_BASE_COFINS    NUMBER(17,2),
    VLR_ALIQ_COFINS    NUMBER(7,4),
    VLR_COFINS         NUMBER(17,2),
    E_COD_ESTAB          VARCHAR2(6),
    E_DATA_FISCAL        DATE,
    E_COD_DOCTO          VARCHAR2(5),
    E_COD_FIS_JUR        VARCHAR2(14),
    E_NUM_DOCFIS         VARCHAR2(12),
    E_SERIE_DOCFIS       VARCHAR2(3),
    E_NUM_CONTROLE_DOCTO VARCHAR2(12),
    E_NUM_AUTENTIC_NFE   VARCHAR2(80),
    E_COD_PRODUTO        VARCHAR2(35),
    E_NUM_ITEM           NUMBER(5),
    E_COD_CFO            VARCHAR2(4),
    E_COD_SITUACAO_B     VARCHAR2(2),
    E_COD_NATUREZA_OP    VARCHAR2(3),
    E_QUANTIDADE         NUMBER(17,6),
    E_VLR_ITEM           NUMBER(17,2),
    E_VLR_CONTAB_ITEM    NUMBER(17,2),
    E_VLR_OUTRAS         NUMBER(17,2),
    E_VLR_DESCONTO       NUMBER(17,2),
    E_BASE_ICMS_TRIB     NUMBER,
    E_ALIQ_ICMS          NUMBER,
    E_VLR_ICMS           NUMBER,
    E_BASE_ICMS_ISENTA   NUMBER,
    E_BASE_ICMS_OUTRAS   NUMBER,
    E_BASE_ICMSS         NUMBER,
    E_ALIQ_ICMSS         NUMBER,
    E_VLR_ICMSS          NUMBER,
    E_VLR_BASE_PIS       NUMBER(17,2),
    E_VLR_ALIQ_PIS       NUMBER(7,4),
    E_VLR_PIS            NUMBER(17,2),
    E_VLR_BASE_COFINS    NUMBER(17,2),
    E_VLR_ALIQ_COFINS    NUMBER(7,4),
    E_VLR_COFINS         NUMBER(17,2),
    UE_COD_ESTAB          VARCHAR2(6),
    UE_DATA_FISCAL        DATE,
    UE_COD_DOCTO          VARCHAR2(5),
    UE_COD_FIS_JUR        VARCHAR2(14),
    UE_NUM_DOCFIS         VARCHAR2(12),
    UE_SERIE_DOCFIS       VARCHAR2(3),
    UE_NUM_CONTROLE_DOCTO VARCHAR2(12),
    UE_NUM_AUTENTIC_NFE   VARCHAR2(80),
    UE_COD_PRODUTO        VARCHAR2(35),
    UE_NUM_ITEM           NUMBER(5),
    UE_COD_CFO            VARCHAR2(4),
    UE_COD_SITUACAO_B     VARCHAR2(2),
    UE_COD_NATUREZA_OP    VARCHAR2(3),
    UE_QUANTIDADE         NUMBER(17,6),
    UE_VLR_ITEM           NUMBER(17,2),
    UE_VLR_CONTAB_ITEM    NUMBER(17,2),
    UE_VLR_OUTRAS         NUMBER(17,2),
    UE_VLR_DESCONTO       NUMBER(17,2),
    UE_BASE_ICMS_TRIB     NUMBER,
    UE_ALIQ_ICMS          NUMBER,
    UE_VLR_ICMS           NUMBER,
    UE_BASE_ICMS_ISENTA   NUMBER,
    UE_BASE_ICMS_OUTRAS   NUMBER,
    UE_BASE_ICMSS         NUMBER,
    UE_ALIQ_ICMSS         NUMBER,
    UE_VLR_ICMSS          NUMBER,
    UE_VLR_BASE_PIS       NUMBER(17,2),
    UE_VLR_ALIQ_PIS       NUMBER(7,4),
    UE_VLR_PIS            NUMBER(17,2),
    UE_VLR_BASE_COFINS    NUMBER(17,2),
    UE_VLR_ALIQ_COFINS    NUMBER(7,4),
    UE_VLR_COFINS         NUMBER(17,2)
    ) partition by range (DATA_FISCAL) INTERVAL (NUMTOYMINTERVAL(1,'MONTH')) SUBPARTITION BY Range (COD_ESTAB)
    (PARTITION DPSP_NFS_ULT_ENTRADA_P201701 VALUES LESS THAN (TO_DATE('01022017', 'DDMMYYYY')),
    PARTITION DPSP_NFS_ULT_ENTRADA_P201702 VALUES LESS THAN (TO_DATE('01032017', 'DDMMYYYY')),
    PARTITION DPSP_NFS_ULT_ENTRADA_P201703 VALUES LESS THAN (TO_DATE('01042017', 'DDMMYYYY')),
    PARTITION DPSP_NFS_ULT_ENTRADA_P201704 VALUES LESS THAN (TO_DATE('01052017', 'DDMMYYYY')),
    PARTITION DPSP_NFS_ULT_ENTRADA_P201705 VALUES LESS THAN (TO_DATE('01062017', 'DDMMYYYY')),
    PARTITION DPSP_NFS_ULT_ENTRADA_P201706 VALUES LESS THAN (TO_DATE('01072017', 'DDMMYYYY')),
    PARTITION DPSP_NFS_ULT_ENTRADA_P201707 VALUES LESS THAN (TO_DATE('01082017', 'DDMMYYYY')));


    CREATE INDEX IX_DPSP_NFSULTE_PROD ON DPSP_NFS_ULT_ENTRADA (COD_ESTAB, DATA_FISCAL, COD_PRODUTO) Local;
    CREATE Unique INDEX IX_PK_DPSP_NFSULTE_PROD ON DPSP_NFS_ULT_ENTRADA (COD_EMPRESA, COD_ESTAB, DATA_FISCAL, NUM_DOCFIS, SERIE_DOCFIS, NUM_ITEM) Local;
    ALTER TABLE DPSP_NFS_ULT_ENTRADA ADD CONSTRAINT PK_DPSP_NFS_ULT_ENTRADA PRIMARY KEY (COD_EMPRESA, COD_ESTAB, DATA_FISCAL, NUM_DOCFIS, SERIE_DOCFIS, NUM_ITEM)
    Using Index;
    */
    FUNCTION executar ( p_periodo DATE
                      , p_estabs lib_proc.vartab )
        RETURN NUMBER;

    --
    FUNCTION parametros
        RETURN VARCHAR2;

    FUNCTION nome
        RETURN VARCHAR2;

    FUNCTION descricao
        RETURN VARCHAR2;

    FUNCTION versao
        RETURN VARCHAR2;

    FUNCTION tipo
        RETURN VARCHAR2;

    PROCEDURE insere_nfsaidas ( l_cod_empresa VARCHAR2
                              , l_cod_estab VARCHAR2
                              , l_periodo IN DATE
                              , id INTEGER );

    --
    PROCEDURE teste;

    PROCEDURE teste1;

    --
    CURSOR crs_saidas ( p_cod_empresa VARCHAR2
                      , p_cod_estab VARCHAR2
                      , p_periodo DATE )
    IS
        SELECT capa.cod_empresa
             , capa.cod_estab
             , capa.data_fiscal
             , dcto.cod_docto
             , dest.cod_fis_jur
             , capa.num_docfis
             , capa.serie_docfis
             , capa.num_controle_docto
             , capa.num_autentic_nfe
             , prod.cod_produto
             , item.num_item
             , cfop.cod_cfo
             , sitb.cod_situacao_b
             , nat.cod_natureza_op
             , lst.lista
             , item.quantidade
             , item.vlr_item
             , item.vlr_contab_item
             , item.vlr_outras
             , item.vlr_desconto
             , NVL ( ( SELECT itmb.vlr_base
                         FROM x08_base_merc itmb
                        WHERE item.cod_empresa = itmb.cod_empresa
                          AND item.cod_estab = itmb.cod_estab
                          AND item.data_fiscal = itmb.data_fiscal
                          AND item.movto_e_s = itmb.movto_e_s
                          AND item.norm_dev = itmb.norm_dev
                          AND item.ident_docto = itmb.ident_docto
                          AND item.ident_fis_jur = itmb.ident_fis_jur
                          AND item.num_docfis = itmb.num_docfis
                          AND item.serie_docfis = itmb.serie_docfis
                          AND item.sub_serie_docfis = itmb.sub_serie_docfis
                          AND item.discri_item = itmb.discri_item
                          AND itmb.cod_tributo = 'ICMS'
                          AND itmb.cod_tributacao = '1' )
                   , 0 )
                   base_icms_trib
             , NVL ( ( SELECT aliq_tributo
                         FROM x08_trib_merc itmt
                        WHERE item.cod_empresa = itmt.cod_empresa
                          AND item.cod_estab = itmt.cod_estab
                          AND item.data_fiscal = itmt.data_fiscal
                          AND item.movto_e_s = itmt.movto_e_s
                          AND item.norm_dev = itmt.norm_dev
                          AND item.ident_docto = itmt.ident_docto
                          AND item.ident_fis_jur = itmt.ident_fis_jur
                          AND item.num_docfis = itmt.num_docfis
                          AND item.serie_docfis = itmt.serie_docfis
                          AND item.sub_serie_docfis = itmt.sub_serie_docfis
                          AND item.discri_item = itmt.discri_item
                          AND itmt.cod_tributo = 'ICMS' )
                   , 0 )
                   aliq_icms
             , NVL ( ( SELECT vlr_tributo
                         FROM x08_trib_merc itmt
                        WHERE item.cod_empresa = itmt.cod_empresa
                          AND item.cod_estab = itmt.cod_estab
                          AND item.data_fiscal = itmt.data_fiscal
                          AND item.movto_e_s = itmt.movto_e_s
                          AND item.norm_dev = itmt.norm_dev
                          AND item.ident_docto = itmt.ident_docto
                          AND item.ident_fis_jur = itmt.ident_fis_jur
                          AND item.num_docfis = itmt.num_docfis
                          AND item.serie_docfis = itmt.serie_docfis
                          AND item.sub_serie_docfis = itmt.sub_serie_docfis
                          AND item.discri_item = itmt.discri_item
                          AND itmt.cod_tributo = 'ICMS' )
                   , 0 )
                   vlr_icms
             , NVL ( ( SELECT itmb.vlr_base
                         FROM x08_base_merc itmb
                        WHERE item.cod_empresa = itmb.cod_empresa
                          AND item.cod_estab = itmb.cod_estab
                          AND item.data_fiscal = itmb.data_fiscal
                          AND item.movto_e_s = itmb.movto_e_s
                          AND item.norm_dev = itmb.norm_dev
                          AND item.ident_docto = itmb.ident_docto
                          AND item.ident_fis_jur = itmb.ident_fis_jur
                          AND item.num_docfis = itmb.num_docfis
                          AND item.serie_docfis = itmb.serie_docfis
                          AND item.sub_serie_docfis = itmb.sub_serie_docfis
                          AND item.discri_item = itmb.discri_item
                          AND itmb.cod_tributo = 'ICMS'
                          AND itmb.cod_tributacao = '2' )
                   , 0 )
                   base_icms_isenta
             , NVL ( ( SELECT itmb.vlr_base
                         FROM x08_base_merc itmb
                        WHERE item.cod_empresa = itmb.cod_empresa
                          AND item.cod_estab = itmb.cod_estab
                          AND item.data_fiscal = itmb.data_fiscal
                          AND item.movto_e_s = itmb.movto_e_s
                          AND item.norm_dev = itmb.norm_dev
                          AND item.ident_docto = itmb.ident_docto
                          AND item.ident_fis_jur = itmb.ident_fis_jur
                          AND item.num_docfis = itmb.num_docfis
                          AND item.serie_docfis = itmb.serie_docfis
                          AND item.sub_serie_docfis = itmb.sub_serie_docfis
                          AND item.discri_item = itmb.discri_item
                          AND itmb.cod_tributo = 'ICMS'
                          AND itmb.cod_tributacao = '3' )
                   , 0 )
                   base_icms_outras
             , item.vlr_base_pis
             , item.vlr_aliq_pis
             , item.vlr_pis
             , item.vlr_base_cofins
             , item.vlr_aliq_cofins
             , item.vlr_cofins
          FROM x07_docto_fiscal capa
               INNER JOIN x08_itens_merc item
                   ON capa.cod_empresa = item.cod_empresa
                  AND capa.cod_estab = item.cod_estab
                  AND capa.data_fiscal = item.data_fiscal
                  AND capa.movto_e_s = item.movto_e_s
                  AND capa.norm_dev = item.norm_dev
                  AND capa.ident_docto = item.ident_docto
                  AND capa.ident_fis_jur = item.ident_fis_jur
                  AND capa.num_docfis = item.num_docfis
                  AND capa.serie_docfis = item.serie_docfis
                  AND capa.sub_serie_docfis = item.sub_serie_docfis
               INNER JOIN x2012_cod_fiscal cfop ON item.ident_cfo = cfop.ident_cfo
               INNER JOIN x2013_produto prod ON item.ident_produto = prod.ident_produto
               LEFT JOIN (SELECT *
                            FROM dpsp_ps_lista l
                           WHERE l.effdt = (SELECT MAX ( a.effdt )
                                              FROM dpsp_ps_lista a
                                             WHERE a.cod_produto = l.cod_produto
                                               AND a.effdt <= p_periodo)) lst
                   ON prod.cod_produto = lst.cod_produto
               INNER JOIN x04_pessoa_fis_jur dest ON dest.ident_fis_jur = capa.ident_fis_jur
               LEFT JOIN x2006_natureza_op nat ON nat.ident_natureza_op = item.ident_natureza_op
               INNER JOIN x2005_tipo_docto dcto ON dcto.ident_docto = capa.ident_docto
               INNER JOIN y2026_sit_trb_uf_b sitb ON item.ident_situacao_b = sitb.ident_situacao_b
         WHERE capa.cod_empresa = p_cod_empresa
           AND capa.cod_estab = p_cod_estab
           AND capa.movto_e_s = '9'
           AND capa.situacao <> 'S'
           AND capa.data_fiscal = p_periodo
           AND cfop.cod_cfo IN ( '5102'
                               , '6102'
                               , '5403'
                               , '6403'
                               , '5405' );
END dpsp_excl_icms_cproc;
/
SHOW ERRORS;
