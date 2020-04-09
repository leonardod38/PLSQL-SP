CREATE OR REPLACE PACKAGE MSAF.DPSP_FIN048_RET_COMPETE_CPROC IS

  -- Author  : Lucas Manarte - Accenture
  -- Created : 03/10/2018
  -- Purpose : Melhoria FIN048:
  -- Retificação da apuração do ICMS ES
  -- Gerar os cálculo COMPETE e FEEF

  function parametros return varchar2;
  function nome return varchar2;
  function tipo return varchar2;
  function versao return varchar2;
  function descricao return varchar2;
  function modulo return varchar2;
  function classificacao return varchar2;
  function orientacao return varchar2;

  FUNCTION executar(PDT_INI DATE, PDT_FIM DATE, PCOD_ESTAB VARCHAR2)
    RETURN INTEGER;

  PROCEDURE loga(P_I_TEXTO IN VARCHAR2, P_I_DTTM IN BOOLEAN DEFAULT TRUE);

  PROCEDURE envia_email(VP_COD_EMPRESA   IN VARCHAR2,
                        VP_DATA_INI      IN DATE,
                        VP_DATA_FIM      IN DATE,
                        VP_MSG_ORACLE    IN VARCHAR2,
                        VP_TIPO          IN VARCHAR2,
                        VP_DATA_HORA_INI IN VARCHAR2);

  PROCEDURE cabecalho(PNM_EMPRESA     VARCHAR2,
                      PCNPJ           VARCHAR2,
                      V_DATA_HORA_INI VARCHAR2,
                      MNM_CPROC       VARCHAR2,
                      PDT_INI         DATE,
                      PDT_FIM         DATE,
                      PCOD_ESTAB      VARCHAR2);

  FUNCTION carregar_NF_entrada(PDT_INI         DATE,
                               PDT_FIM         DATE,
                               PCOD_ESTAB      VARCHAR2,
                               V_DATA_HORA_INI VARCHAR2) RETURN INTEGER;

END DPSP_FIN048_RET_COMPETE_CPROC;
/

Show errors;
