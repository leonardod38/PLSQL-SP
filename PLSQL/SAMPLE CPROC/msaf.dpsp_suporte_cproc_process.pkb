Prompt Package Body DPSP_SUPORTE_CPROC_PROCESS;
--
-- DPSP_SUPORTE_CPROC_PROCESS  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_suporte_cproc_process
IS
    --===================================================================================
    -- Inserir Status no Customizado "Encerramento de Status de Relatórios"
    -- "Processo para bloquear reprocessamento de Relatórios"
    --===================================================================================
    FUNCTION validar_status_rel ( pcod_empresa VARCHAR2
                                , pcod_estab VARCHAR2
                                , pdt_periodo INTEGER
                                , pcd_cproc VARCHAR2 )
        RETURN INTEGER
    IS
        v_encerrado INTEGER;
    BEGIN
        --VERIFICAR SE O MAIOR STATUS ESTÁ ENCERRADO
        SELECT COUNT ( 1 ) enc
          INTO v_encerrado
          FROM msafi.dpsp_msaf_encerr_status_rel a
         WHERE cod_empresa = pcod_empresa
           AND cod_estab = pcod_estab
           AND cd_cproc = pcd_cproc
           AND dt_periodo = pdt_periodo
           AND status = 'Encerrado'
           AND TO_DATE ( dt_manutencao
                       , 'DD/MM/YYYY HH24:MI:SS' ) = (SELECT MAX ( TO_DATE ( b.dt_manutencao
                                                                           , 'DD/MM/YYYY HH24:MI:SS' ) )
                                                        FROM msafi.dpsp_msaf_encerr_status_rel b
                                                       WHERE b.cd_cproc = a.cd_cproc
                                                         AND b.cod_empresa = a.cod_empresa
                                                         AND b.cod_estab = a.cod_estab
                                                         AND b.dt_periodo = a.dt_periodo);

        --CASO O RETORNO SEJA ZERO O PERIODO NÃO ESTÁ ENCERRADO, PERMITINDO O CARREGAMENTO DA TABELA.
        --CASO O CONTRARIO, O CUSTOMIZADO IRÁ SOMENTE CONSULTAR O QUE JÁ FOI CARREGADO.

        RETURN NVL ( v_encerrado, 0 );
    END validar_status_rel;

    --===================================================================================
    -- Inserir Status no Customizado "Encerramento de Status de Relatórios"
    -- "Processo para bloquear reprocessamento de Relatórios"
    --===================================================================================
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
                                 , pdt_manutencao VARCHAR2 )
    IS
        v_existe INTEGER;
    BEGIN
        ----- STATUS -----
        -- 0: Aberto
        -- 1: Encerrado
        ------------------

        --ABERTO
        IF pstatus = 0 THEN
            --CASO O ULTIMO STATUS SEJA IGUAL O STATUS QUE ESTÁ SENDO INSERIDO, NÃO HÁ NECESSIDADE DE INSERI-LO NOVAMENTE.
            SELECT COUNT ( 1 ) enc
              INTO v_existe
              FROM msafi.dpsp_msaf_encerr_status_rel a
             WHERE cod_empresa = pcod_empresa
               AND cod_estab = pcod_estab
               AND cd_cproc = pcd_cproc
               AND dt_periodo = pdt_periodo
               AND status = 'Aberto'
               AND TO_DATE ( dt_manutencao
                           , 'DD/MM/YYYY HH24:MI:SS' ) = (SELECT MAX ( TO_DATE ( b.dt_manutencao
                                                                               , 'DD/MM/YYYY HH24:MI:SS' ) )
                                                            FROM msafi.dpsp_msaf_encerr_status_rel b
                                                           WHERE b.cd_cproc = a.cd_cproc
                                                             AND b.cod_empresa = a.cod_empresa
                                                             AND b.cod_estab = a.cod_estab
                                                             AND b.dt_periodo = a.dt_periodo);

            IF v_existe = 0 THEN
                INSERT INTO msafi.dpsp_msaf_encerr_status_rel ( cod_empresa
                                                              , cod_estab
                                                              , cd_cproc
                                                              , nm_cproc
                                                              , nm_tipo
                                                              , dt_periodo
                                                              , status
                                                              , cd_cproc_resp
                                                              , proc_id
                                                              , nm_usuario
                                                              , dt_manutencao )
                     VALUES ( pcod_empresa
                            , pcod_estab
                            , pcd_cproc
                            , pnm_cproc
                            , pnm_tipo
                            , pdt_periodo
                            , 'Aberto'
                            , pcd_cproc_resp
                            , pproc_id
                            , pnm_usuario
                            , pdt_manutencao );
            END IF;
        --ENCERRADO
        ELSIF pstatus = 1 THEN
            SELECT COUNT ( 1 ) enc
              INTO v_existe
              FROM msafi.dpsp_msaf_encerr_status_rel a
             WHERE cod_empresa = pcod_empresa
               AND cod_estab = pcod_estab
               AND cd_cproc = pcd_cproc
               AND dt_periodo = pdt_periodo
               AND status = 'Encerrado'
               AND TO_DATE ( dt_manutencao
                           , 'DD/MM/YYYY HH24:MI:SS' ) = (SELECT MAX ( TO_DATE ( b.dt_manutencao
                                                                               , 'DD/MM/YYYY HH24:MI:SS' ) )
                                                            FROM msafi.dpsp_msaf_encerr_status_rel b
                                                           WHERE b.cd_cproc = a.cd_cproc
                                                             AND b.cod_empresa = a.cod_empresa
                                                             AND b.cod_estab = a.cod_estab
                                                             AND b.dt_periodo = a.dt_periodo);

            IF v_existe = 0 THEN
                INSERT INTO msafi.dpsp_msaf_encerr_status_rel ( cod_empresa
                                                              , cod_estab
                                                              , cd_cproc
                                                              , nm_cproc
                                                              , nm_tipo
                                                              , dt_periodo
                                                              , status
                                                              , cd_cproc_resp
                                                              , proc_id
                                                              , nm_usuario
                                                              , dt_manutencao )
                     VALUES ( pcod_empresa
                            , pcod_estab
                            , pcd_cproc
                            , pnm_cproc
                            , pnm_tipo
                            , pdt_periodo
                            , 'Encerrado'
                            , pcd_cproc_resp
                            , pproc_id
                            , pnm_usuario
                            , pdt_manutencao );
            END IF;
        END IF;

        COMMIT;
    END inserir_status_rel;

    --===================================================================================
    -- Retornar Status do Customizado "Encerramento de Status de Relatórios"
    -- "Processo para bloquear reprocessamento de Relatórios"
    --===================================================================================
    FUNCTION retornar_status_rel ( pcod_empresa VARCHAR2
                                 , pcod_estab VARCHAR2
                                 , pdt_periodo INTEGER
                                 , pcd_cproc VARCHAR2 )
        RETURN VARCHAR2
    IS
        v_status VARCHAR2 ( 200 ) := ' ';
    BEGIN
        --VERIFICAR SE O MAIOR STATUS ESTÁ ENCERRADO
        SELECT NVL ( MAX ( dt_manutencao || ' - ' || nm_usuario ), 'Periodo Aberto' )
          INTO v_status
          FROM msafi.dpsp_msaf_encerr_status_rel a
         WHERE cod_empresa = pcod_empresa
           AND cod_estab = pcod_estab
           AND cd_cproc = pcd_cproc
           AND dt_periodo = pdt_periodo
           AND status = 'Encerrado'
           AND TO_DATE ( dt_manutencao
                       , 'DD/MM/YYYY HH24:MI:SS' ) = (SELECT MAX ( TO_DATE ( b.dt_manutencao
                                                                           , 'DD/MM/YYYY HH24:MI:SS' ) )
                                                        FROM msafi.dpsp_msaf_encerr_status_rel b
                                                       WHERE b.cd_cproc = a.cd_cproc
                                                         AND b.cod_empresa = a.cod_empresa
                                                         AND b.cod_estab = a.cod_estab
                                                         AND b.dt_periodo = a.dt_periodo);

        RETURN v_status;
    END retornar_status_rel;
END dpsp_suporte_cproc_process;
/
SHOW ERRORS;
