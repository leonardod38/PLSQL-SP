Prompt Package DSP_LOGS_DSP_CPROC;
--
-- DSP_LOGS_DSP_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dsp_logs_dsp_cproc
IS
    -- AUTOR    : DSP - LFM
    -- DATA     : 24/JUL/2012
    -- DESCRIÇÃO: Executador de relatórios

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

    PROCEDURE loga ( p_i_texto IN VARCHAR2
                   , p_i_dttm IN BOOLEAN DEFAULT TRUE );

    FUNCTION executar ( p_acao VARCHAR2
                      , p_proc lib_proc.vartab )
        RETURN INTEGER;

    CURSOR c_log_01 ( p_i_proc_inst NUMBER )
    IS
        SELECT 'B'
             , log_seq
             , log_dttm
             , log_type
             , log_text
             , TRIM ( log_data1 ) log_data1
             , TRIM ( log_data2 ) log_data2
             , TRIM ( log_data3 ) log_data3
             , TRIM ( log_data4 ) log_data4
             , TRIM ( log_data5 ) log_data5
             , TRIM ( log_data6 ) log_data6
             , TRIM ( log_data7 ) log_data7
             , TRIM ( log_data8 ) log_data8
             , TRIM ( log_data9 ) log_data9
             , TRIM ( log_dataa ) log_dataa
             , TRIM ( log_datab ) log_datab
             , TRIM ( log_datac ) log_datac
             , TRIM ( log_datad ) log_datad
             , TRIM ( log_datae ) log_datae
             , TRIM ( log_dataf ) log_dataf
          FROM msafi.dsp_log
         WHERE process_instance = p_i_proc_inst
        UNION /*CHECKPOINT:*/
        SELECT 'A'
             , 0
             , log_dttm
             , 'CHKPOINT'
             , log_text
             , log_data1
             , log_data2
             , log_data3
             , log_data4
             , log_data5
             , log_data6
             , log_data7
             , log_data8
             , log_data9
             , log_dataa
             , log_datab
             , log_datac
             , log_datad
             , log_datae
             , log_dataf
          FROM msafi.dsp_checkpoint
         WHERE process_instance = p_i_proc_inst
        ORDER BY 1
               , 2;
END dsp_logs_dsp_cproc;
/
SHOW ERRORS;
