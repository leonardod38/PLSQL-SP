Prompt Package Body DSP_REL_APUR_108_CPROC;
--
-- DSP_REL_APUR_108_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dsp_rel_apur_108_cproc
IS
    -- ##########################################################
    --   GERAÇÃO EM PASSA DOS RELATÓRIOS DE APURAÇÃO RAICMS
    --
    -- Solicitante: Jeferson Soares                    2016-06-08
    -- Técnico: Rodolfo Carvalhal
    -- ##########################################################
    FUNCTION executar ( v_cod_estab lib_proc.vartab
                      , v_periodo DATE )
        RETURN INTEGER
    IS
    BEGIN
        FOR ix IN 1 .. v_cod_estab.COUNT LOOP
            NULL;
        END LOOP;
    END;
END dsp_rel_apur_108_cproc;
/
SHOW ERRORS;
