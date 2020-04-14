Prompt Package DPSP_REL_RETENCAO_IRRF_CPROC;
--
-- DPSP_REL_RETENCAO_IRRF_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dpsp_rel_retencao_irrf_cproc
IS
    -- AUTOR    : DSP - CLECIO CARMO
    -- DATA     : CRIADO EM 10/JUN/2019
    -- DESCRIC?O: RELATORIO X53_RETENCAO_IRRF

    --MCOD_EMPRESA EMPRESA.COD_EMPRESA%TYPE;
    --MCOD_ESTAB   ESTABELECIMENTO.COD_ESTAB%TYPE;
    --MUSUARIO     USUARIO_EMPRESA.COD_USUARIO%TYPE;

    v_cod_empresa empresa.cod_empresa%TYPE;

    FUNCTION executar ( pcod_empresa VARCHAR2
                      , p_data_ini DATE
                      , p_data_fim DATE
                      , p_razaosocial VARCHAR2
                      , pcodfisjur VARCHAR2
                      , pdarf VARCHAR2 )
        RETURN NUMBER;

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

    CURSOR rel_irrf ( ppcod_empresa VARCHAR2
                    , ppdatainicial DATE
                    , ppdatafinal DATE
                    , ppcodfisjur VARCHAR2
                    , ppdarf VARCHAR2 )
    IS
        SELECT a.cod_empresa
             , a.cod_estab
             , a.data_movto
             , a.num_docfis
             , a.serie_docfis
             , a.sub_serie_docfis
             , ( CASE WHEN LENGTH ( b.cpf_cgc ) <= 11 THEN '1' ELSE '2' END ) tipo_beneficiario
             , c.cod_darf
             , c.descricao descri_cod_darf
             , a.ano_competencia
             , a.mes_competencia
             , a.vlr_bruto
             , a.vlr_deducao
             , a.vlr_ir_retido
             , a.aliquota
             , a.cod_tributo
             , a.esp_tributo
             , a.cod_receita
             , a.data_ini_compet
             , a.data_fim_compet
             , a.data_fator_gerador
             , a.data_vencto
             , a.num_voucher
             , b.cod_fis_jur
             , b.cpf_cgc
             , b.razao_social
          FROM msaf.x53_retencao_irrf a
             , x04_pessoa_fis_jur b
             , x2019_cod_darf c
         WHERE 1 = 1
           --           AND A.COD_EMPRESA    = V_COD_EMPRESA
           --           AND A.DATA_MOVTO BETWEEN P_DATA_INI AND P_DATA_FIM
           --           AND A.IDENT_FIS_JUR  = B.IDENT_FIS_JUR
           --           AND A.IDENT_DARF     = C.IDENT_DARF
           --
           AND a.data_movto BETWEEN ppdatainicial AND ppdatafinal
           AND cod_empresa = NVL ( DECODE ( ppcod_empresa, '000', cod_empresa, ppcod_empresa ), msafi.dpsp.v_empresa )
           AND c.cod_darf = NVL ( TRIM ( ppdarf ), c.cod_darf )
           AND a.ident_fis_jur = b.ident_fis_jur
           AND a.ident_darf = c.ident_darf
           AND b.cod_fis_jur = NVL ( TRIM ( ppcodfisjur ), b.cod_fis_jur );
END dpsp_rel_retencao_irrf_cproc;
/
SHOW ERRORS;
