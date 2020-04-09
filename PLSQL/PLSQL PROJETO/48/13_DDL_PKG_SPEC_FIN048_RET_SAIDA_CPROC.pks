CREATE OR REPLACE PACKAGE MSAF.DPSP_FIN048_RET_SAIDA_CPROC IS

  -- Author  : Lucas Manarte - Accenture
  -- Created : 03/10/2018
  -- Purpose : Melhoria FIN048:
  -- Retificação da apuração do ICMS ES
  -- Relatório de Notas Fiscais de Saída para retificacao apuração ICMS (ES)

  FUNCTION PARAMETROS RETURN VARCHAR2;
  FUNCTION NOME RETURN VARCHAR2;
  FUNCTION TIPO RETURN VARCHAR2;
  FUNCTION VERSAO RETURN VARCHAR2;
  FUNCTION DESCRICAO RETURN VARCHAR2;
  FUNCTION MODULO RETURN VARCHAR2;
  FUNCTION CLASSIFICACAO RETURN VARCHAR2;
  FUNCTION ORIENTACAO RETURN VARCHAR2;

  FUNCTION EXECUTAR(
                    PDT_INI DATE
                  , PDT_FIM DATE
                  , PCOD_ESTAB VARCHAR2                  
                  )
    RETURN INTEGER;

  PROCEDURE LOGA(P_I_TEXTO IN VARCHAR2, P_I_DTTM IN BOOLEAN DEFAULT TRUE);

  PROCEDURE ENVIA_EMAIL(VP_COD_EMPRESA   IN VARCHAR2,
                        VP_DATA_INI      IN DATE,
                        VP_DATA_FIM      IN DATE,
                        VP_MSG_ORACLE    IN VARCHAR2,
                        VP_TIPO          IN VARCHAR2,
                        VP_DATA_HORA_INI IN VARCHAR2);



--  FUNCTION CARREGAR_NF_ENTRADA(PDT_INI         DATE,
--                               PDT_FIM         DATE,
--                               PCOD_ESTAB      VARCHAR2,
--                               V_DATA_HORA_INI VARCHAR2) RETURN INTEGER;
  
END DPSP_FIN048_RET_SAIDA_CPROC;
/