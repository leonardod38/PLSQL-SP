CREATE OR REPLACE PACKAGE MSAF.DPSP_FIN2662_PAR_RELAT_CPROC IS

  -- AUTOR    : Accenture - Guilherme Silva
  -- DATA     : V4 CRIADA EM 11/DEZEMBRO/2019
  -- DESCRIÇÃO: Projeto FIN 1952 - Relatório 

  mcod_empresa empresa.cod_empresa%TYPE;
  mcod_usuario usuario_empresa.cod_usuario%TYPE;

  FUNCTION parametros RETURN VARCHAR2;
  FUNCTION nome RETURN VARCHAR2;
  FUNCTION tipo RETURN VARCHAR2;
  FUNCTION versao RETURN VARCHAR2;
  FUNCTION descricao RETURN VARCHAR2;
  FUNCTION modulo RETURN VARCHAR2;
  FUNCTION classificacao RETURN VARCHAR2;

  FUNCTION executar(p_ano      VARCHAR2,
                    p_semestre VARCHAR2,
                    p_tipo     VARCHAR2,
                    p_lojas    lib_proc.vartab) RETURN INTEGER;

END dpsp_fin2662_par_relat_cproc;

/