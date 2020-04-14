Prompt Package DPSP_SUPORTE_CPROC_PROCESS;
--
-- DPSP_SUPORTE_CPROC_PROCESS  (Package) 
--
CREATE OR REPLACE PACKAGE dpsp_suporte_cproc_process
IS
    -- Author  : Lucas Manarte - Accenture
    -- Created : 26/09/2018
    -- Purpose : Pacote para emcapsulamento de Procs e Functions
    -- utilizadas para as melhorias de DPSP

    FUNCTION validar_status_rel ( pcod_empresa VARCHAR2
                                , pcod_estab VARCHAR2
                                , pdt_periodo INTEGER
                                , pcd_cproc VARCHAR2 )
        RETURN INTEGER;

    PROCEDURE inserir_status_rel ( pcod_empresa VARCHAR2
                                 , pcod_estab VARCHAR2
                                 , pdt_periodo INTEGER
                                 , pcd_cproc VARCHAR2
                                 , pnm_cproc VARCHAR2
                                 , pnm_tipo VARCHAR2
                                 , pstatus CHAR
                                 , pcd_cproc_resp VARCHAR2
                                 , pproc_id INTEGER
                                 , pnm_usuario VARCHAR2
                                 , pdt_manutencao VARCHAR2 );

    FUNCTION retornar_status_rel ( pcod_empresa VARCHAR2
                                 , pcod_estab VARCHAR2
                                 , pdt_periodo INTEGER
                                 , pcd_cproc VARCHAR2 )
        RETURN VARCHAR2;
END dpsp_suporte_cproc_process;
/
SHOW ERRORS;
