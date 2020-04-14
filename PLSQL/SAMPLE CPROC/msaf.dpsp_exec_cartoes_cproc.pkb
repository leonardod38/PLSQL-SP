Prompt Package Body DPSP_EXEC_CARTOES_CPROC;
--
-- DPSP_EXEC_CARTOES_CPROC  (Package Body) 
--
CREATE OR REPLACE PACKAGE BODY dpsp_exec_cartoes_cproc
IS
    FUNCTION parametros
        RETURN VARCHAR2
    IS
        pstr VARCHAR2 ( 1000 );
    BEGIN
        lib_proc.add_param ( pstr
                           , 'Data Inicial'
                           , --P_DATA_INI
                            'DATE'
                           , 'TEXTBOX'
                           , 'S'
                           , NULL
                           , 'DD/MM/YYYY' );

        lib_proc.add_param ( pstr
                           , 'Data Final'
                           , --P_DATA_FIM
                            'DATE'
                           , 'TEXTBOX'
                           , 'S'
                           , NULL
                           , 'DD/MM/YYYY' );

        lib_proc.add_param ( pstr
                           , 'Número de Filiais por Lote'
                           , --P_LOTE
                            'NUMBER'
                           , 'TEXTBOX'
                           , 'S'
                           , NULL
                           , '##' );

        RETURN pstr;
    END;

    FUNCTION nome
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Processar Dados Crédito dos Cartões em LOTE';
    END;

    FUNCTION tipo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Ressarcimento';
    END;

    FUNCTION versao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'VERSAO 1.0';
    END;

    FUNCTION descricao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'Processar em LOTE a Carga de Dados para informação de crédito dos Cartões';
    END;

    FUNCTION modulo
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'PROCESSOS CUSTOMIZADOS';
    END;

    FUNCTION classificacao
        RETURN VARCHAR2
    IS
    BEGIN
        RETURN 'PROCESSOS CUSTOMIZADOS';
    END;

    PROCEDURE loga ( p_i_texto IN VARCHAR2
                   , p_i_dttm IN BOOLEAN DEFAULT TRUE )
    IS
        vtexto VARCHAR2 ( 1024 );
    BEGIN
        IF p_i_dttm THEN
            vtexto :=
                SUBSTR (    TO_CHAR ( SYSDATE
                                    , 'DD/MM/YYYY HH24:MI:SS' )
                         || ' - '
                         || p_i_texto
                       , 1
                       , 1024 );
        ELSE
            vtexto :=
                SUBSTR ( p_i_texto
                       , 1
                       , 1024 );
        END IF;

        msafi.dsp_control.writelog ( 'CARTOES_EXEC'
                                   , p_i_texto );
        COMMIT;
    END;

    FUNCTION executar ( p_data_ini DATE
                      , p_data_fim DATE
                      , p_lote NUMBER )
        RETURN INTEGER
    IS
        v_estab msaf.lib_proc.vartab;
        v_cont INTEGER := 0;
        v_cod_estado VARCHAR2 ( 2 ) := 'SP';
        v_proc INTEGER;
        v_lote NUMBER := 0;
    BEGIN
        v_estab.delete;
        msaf.lib_parametros.salvar ( 'EMPRESA'
                                   , 'DSP' );

        IF ( p_lote = 0 ) THEN
            v_lote := 1;
        ELSE
            v_lote := p_lote;
        END IF;

        FOR c IN ( SELECT   cod_estab
                       FROM msaf.dsp_estabelecimento_v
                      WHERE cod_estado = v_cod_estado
                   ORDER BY cod_estab ) LOOP
            v_estab ( v_cont ) := c.cod_estab;

            v_cont := v_cont + 1;

            IF v_cont = v_lote THEN
                loga ( 'CONT SP: ' || v_cont
                     , FALSE );

                dbms_output.put_line ( ' EXECUTA ' || v_estab.COUNT );
                v_proc :=
                    msaf.dpsp_cartoes_cproc.executar ( TO_CHAR ( p_data_ini
                                                               , 'DD/MM/YYYY' ) --P_DATA_INI       DATE
                                                     , TO_CHAR ( p_data_fim
                                                               , 'DD/MM/YYYY' ) --P_DATA_FIM       DATE
                                                     , '1' --P_ORIGEM1        VARCHAR2
                                                     , 'ST910' --P_CD1            VARCHAR2
                                                     , '2' --P_ORIGEM2        VARCHAR2
                                                     , 'DSP910' --P_CD2            VARCHAR2
                                                     , '2' --P_ORIGEM3        VARCHAR2
                                                     , 'DSP901' --P_CD3            VARCHAR2
                                                     , '2' --P_ORIGEM4        VARCHAR2
                                                     , 'DSP902' --P_CD4            VARCHAR2
                                                     , v_estab --P_LOJAS          LIB_PROC.VARTAB
                                                               );

                --- V_PROC := MSAF.DPSP_CARTOES_CPROC.EXECUTAR('15/02/2018' --P_DATA_INI       DATE
                ---                                             ,
                ---                                             '28/02/2018' --P_DATA_FIM       DATE
                ---                                             ,
                ---                                              '1' --P_ORIGEM1        VARCHAR2
                ---                                             ,
                ---                                              'ST910' --P_CD1            VARCHAR2
                ---                                             ,
                ---                                              '2' --P_ORIGEM2        VARCHAR2
                ---                                             ,
                ---                                              'DSP910' --P_CD2            VARCHAR2
                ---                                             ,
                ---                                              '2' --P_ORIGEM3        VARCHAR2
                ---                                             ,
                ---                                              'DSP901' --P_CD3            VARCHAR2
                ---                                             ,
                ---                                              '2' --P_ORIGEM4        VARCHAR2
                ---                                             ,
                ---                                              'DSP902' --P_CD4            VARCHAR2
                ---                                             ,
                ---                                              V_ESTAB --P_LOJAS          LIB_PROC.VARTAB
                ---                                              );

                v_cont := 1;
                v_estab.delete;
            END IF;
        END LOOP;

        dbms_output.put_line ( ' EXECUTA ' || v_estab.COUNT );
        v_proc :=
            msaf.dpsp_cartoes_cproc.executar ( TO_CHAR ( p_data_ini
                                                       , 'DD/MM/YYYY' ) --P_DATA_INI       DATE
                                             , TO_CHAR ( p_data_fim
                                                       , 'DD/MM/YYYY' ) --P_DATA_FIM       DATE
                                             , '1' --P_ORIGEM1        VARCHAR2
                                             , 'ST910' --P_CD1            VARCHAR2
                                             , '2' --P_ORIGEM2        VARCHAR2
                                             , 'DSP910' --P_CD2            VARCHAR2
                                             , '2' --P_ORIGEM3        VARCHAR2
                                             , 'DSP901' --P_CD3            VARCHAR2
                                             , '2' --P_ORIGEM4        VARCHAR2
                                             , 'DSP902' --P_CD4            VARCHAR2
                                             , v_estab --P_LOJAS          LIB_PROC.VARTAB
                                                       );

        ----V_PROC := MSAF.DPSP_CARTOES_CPROC.EXECUTAR('15/02/2018' --P_DATA_INI       DATE
        ----                                            ,
        ----                                            '28/02/2018' --P_DATA_FIM       DATE
        ----                                            ,
        ----                                             '1' --P_ORIGEM1        VARCHAR2
        ----                                            ,
        ----                                             'ST910' --P_CD1            VARCHAR2
        ----                                            ,
        ----                                             '2' --P_ORIGEM2        VARCHAR2
        ----                                            ,
        ----                                             'DSP910' --P_CD2            VARCHAR2
        ----                                            ,
        ----                                             '2' --P_ORIGEM3        VARCHAR2
        ----                                            ,
        ----                                             'DSP901' --P_CD3            VARCHAR2
        ----                                            ,
        ----                                             '2' --P_ORIGEM4        VARCHAR2
        ----                                            ,
        ----                                             'DSP902' --P_CD4            VARCHAR2
        ----                                            ,
        ----                                             V_ESTAB --P_LOJAS          LIB_PROC.VARTAB
        ----                                             );

        v_cont := 1;
        v_estab.delete;
        ---------------------------------------------------------------------------------------------

        RETURN v_proc;
    END;
END;
/
SHOW ERRORS;
