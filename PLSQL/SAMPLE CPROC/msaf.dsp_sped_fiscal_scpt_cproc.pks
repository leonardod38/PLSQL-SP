Prompt Package DSP_SPED_FISCAL_SCPT_CPROC;
--
-- DSP_SPED_FISCAL_SCPT_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dsp_sped_fiscal_scpt_cproc
IS
    -- AUTOR    : DSP - LFM
    -- DATA     : Dez/2013
    -- DESCRIÇÃO: Módulo customizado de scripts para o Sped Contribuições (EFD PIS/COFINS)

    mcod_empresa empresa.cod_empresa%TYPE;
    mcod_estab estabelecimento.cod_estab%TYPE;
    musuario usuario_empresa.cod_usuario%TYPE;

    --Variaveis para as funções REGEXP_LIKE encontrarem DSP9xx, Depósitos, Lojas e Estabelecimentos
    v_proc_9xx VARCHAR2 ( 30 ); --V_PROC_9XX   := '^' || MCOD_EMPRESA || '9[0-9]{2}$';
    v_proc_dep VARCHAR2 ( 30 ); --V_PROC_DEP   := '^' || MCOD_EMPRESA || '9[0-9][1-9]$';
    v_proc_loj VARCHAR2 ( 30 ); --V_PROC_LOJ   := '^' || MCOD_EMPRESA || '[0-8][0-9]{' || TO_CHAR(5-LENGTH(MCOD_EMPRESA),'FM9') || '}$';
    v_proc_est VARCHAR2 ( 30 ); --V_PROC_EST   := '^' || MCOD_EMPRESA || '[0-9]{3,' || TO_CHAR(6-LENGTH(MCOD_EMPRESA),'FM9') || '}$';
    v_proc_estvd VARCHAR2 ( 30 ); --V_PROC_ESTVD := '^VD[0-9]{3,' || TO_CHAR(6-LENGTH(MCOD_EMPRESA),'FM9') || '}$';

    FUNCTION parametros
        RETURN VARCHAR2;

    FUNCTION nome
        RETURN VARCHAR2;

    FUNCTION tipo
        RETURN VARCHAR2;

    FUNCTION versao
        RETURN VARCHAR2;

    FUNCTION descricao
        RETURN VARCHAR2;

    FUNCTION modulo
        RETURN VARCHAR2;

    FUNCTION classificacao
        RETURN VARCHAR2;

    FUNCTION executar ( p_script VARCHAR2
                      , p_mes VARCHAR2
                      , p_ano VARCHAR2 )
        RETURN INTEGER;

    --------------------------------------------------------------------------------------------------------------
    -- Cursor: Lista de datas
    CURSOR c_datas ( p_i_data_ini IN DATE
                   , p_i_data_fim IN DATE )
    IS
        SELECT   TO_CHAR ( d.data_fiscal
                         , 'YYYYMMDD' )
                     AS data_safx
               , d.data_fiscal AS data_normal
            FROM (SELECT     p_i_data_ini + ( ROWNUM - 1 ) AS "DATA_FISCAL"
                        FROM DUAL
                  CONNECT BY LEVEL <= (p_i_data_fim - p_i_data_ini + 1)) d
        ORDER BY d.data_fiscal;

    --------------------------------------------------------------------------------------------------------------
    -- Cursor: Lista de estabelecimentos para entrega do C176
    CURSOR c_estabs
    IS
        SELECT   cod_empresa
               , cod_estab
            FROM msafi.dsp_sped_c176_est
           WHERE cod_empresa = mcod_empresa
        ORDER BY 1
               , 2;
--------------------------------------------------------------------------------------------------------------

END dsp_sped_fiscal_scpt_cproc;
/
SHOW ERRORS;
