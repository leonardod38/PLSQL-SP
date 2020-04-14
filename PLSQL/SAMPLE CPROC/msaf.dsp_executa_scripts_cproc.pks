Prompt Package DSP_EXECUTA_SCRIPTS_CPROC;
--
-- DSP_EXECUTA_SCRIPTS_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dsp_executa_scripts_cproc
IS
    -- AUTOR    : DSP - LFM
    -- DATA     : 19/11/2011
    -- DESCRIÇÃO: PROCESSO QUE EXECUTA SCRIPTS COM SEGURANÇA SEM NECESSIDADE DE ACIONAR DBA. APENAS PARA USO TÉCNICO!

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

    PROCEDURE loga ( p_texto VARCHAR2 );

    FUNCTION executar ( p_senha VARCHAR2
                      , p_confirma VARCHAR2
                      , p_script VARCHAR2
                      , p_data1 DATE
                      , p_data2 DATE
                      , p_parametro1 VARCHAR2
                      , p_codestab lib_proc.vartab )
        RETURN INTEGER;

    CURSOR cursor_script_010
    IS
        SELECT   usuario
               , COUNT ( 0 ) AS cont
            FROM prt_ident_dmart
           WHERE ind_utilizacao = 'S'
        GROUP BY usuario;

    CURSOR rel_006
    IS
        SELECT DISTINCT cod_empresa
                      , cod_estab
          FROM x996_totalizador_parcial_ecf;
END dsp_executa_scripts_cproc;
/
SHOW ERRORS;
