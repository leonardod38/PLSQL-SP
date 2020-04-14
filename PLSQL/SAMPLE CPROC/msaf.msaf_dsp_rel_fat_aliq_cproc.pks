Prompt Package MSAF_DSP_REL_FAT_ALIQ_CPROC;
--
-- MSAF_DSP_REL_FAT_ALIQ_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE "MSAF_DSP_REL_FAT_ALIQ_CPROC"
IS
    -- AUTOR   : TIAGO CERVANTES - ADEJO
    -- CREATED : 27/02/2018
    -- PURPOSE : RELATÓRIO ANALITICO DE FATURAMENTO POR ALIQUOTA

    mcod_estab estabelecimento.cod_estab%TYPE;
    mcod_empresa empresa.cod_empresa%TYPE;
    --MUSUARIO        USUARIO_ESTAB.COD_USUARIO%TYPE;

    /* VARIAVEIS DE TRABALHO */
    mproc_id INTEGER;
    minsereheader BOOLEAN;
    mlinha VARCHAR2 ( 1500 );

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

    FUNCTION executar ( p_data_ini DATE
                      , p_data_fim DATE
                      , p_cod_estab VARCHAR2 )
        RETURN INTEGER;
END msaf_dsp_rel_fat_aliq_cproc;
/
SHOW ERRORS;
