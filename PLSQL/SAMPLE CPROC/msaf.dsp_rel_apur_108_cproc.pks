Prompt Package DSP_REL_APUR_108_CPROC;
--
-- DSP_REL_APUR_108_CPROC  (Package) 
--
CREATE OR REPLACE PACKAGE dsp_rel_apur_108_cproc
IS
    -- Author  : RODOLFO.CARVALHAL
    -- Created : 08/06/2017 16:18:59
    -- Purpose :
    FUNCTION executar ( v_cod_estab lib_proc.vartab
                      , v_periodo DATE )
        RETURN INTEGER;
END dsp_rel_apur_108_cproc;
/
SHOW ERRORS;
