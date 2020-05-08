CREATE OR REPLACE function fws001_getprodname(
   P_Produto    IN INTEGER
) return VARCHAR2
IS
BEGIN
  if P_Produto = 10 then
     RETURN 'PASSEIO';
  ELSif P_Produto = 42 then
     RETURN 'CLASSICO';
  ELSE
     RETURN 'DESCONHECIDO';
  END IF;
END;
/


CREATE OR REPLACE function fws002_getvigencia(
   P_Produto     IN INTEGER,
   P_DtVigencia  IN DATE
) return INTEGER
IS
  V_Vigencia INTEGER;
  V_IniVigencia  DATE;
begin
  begin
    SELECT InicioVigencia INTO V_IniVigencia
    FROM MULT_PRODUTOS
    WHERE Produto = P_Produto;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     RETURN 0;
  END;
  if (P_DtVigencia < V_IniVigencia) then
     RETURN 2;
  end if;
  RETURN 1;
END;
/


CREATE OR REPLACE function fws003_canalvendas(
   P_Corretor    IN INTEGER
) return INTEGER
IS
begin
 if (( 43501 <= P_Corretor) and (P_Corretor <=  43599)) or
    ((999151 <= P_Corretor) and (P_Corretor <= 999199)) then
    RETURN 1;
 ELSIF (P_Corretor = 83501) then
    RETURN 4;
 ELSE
    RETURN 2;
 END IF;
END;
/


CREATE OR REPLACE function fws004_checkuser(
   P_Corretor IN INTEGER,
   P_Usuario  IN VARCHAR2,
   P_Produto  IN INTEGER
) return VARCHAR2
IS
   V_Conta Integer;
   V_Cota  VARCHAR2(10);
   V_Erro01   VARCHAR(100)  := '<Erros><Mensagem>';
   V_Erro02   VARCHAR(100)  := '</Mensagem></Erros>';
   V_Invalido VARCHAR(100)  := '" inválido!';
   V_ErroUser VARCHAR2(200) := 'Código do usuário informado "';
   V_ErroCorr VARCHAR2(200) := 'Código do corretor informado "';
   V_ErroDisp VARCHAR2(200) := 'Usuário ou corretor não autorizado a utilizar esta ferramenta!';
begin


  -- Verifica se Usuario existe
  IF (TRIM(P_Usuario) IS NULL) THEN
     RETURN V_Erro01 || 'Código do usuário inválido!' || V_Erro02;
  END IF;
  select count(cod_usuario) into V_Conta from real_usuarios where cod_usuario = P_Usuario;
  IF (V_Conta = 0) THEN
     RETURN V_Erro01 || V_ErroUser || P_Usuario || V_Invalido || V_Erro02;
  END IF;

  -- Verifica se Corretor existe
  IF (P_Corretor = 0) THEN
     RETURN V_Erro01 || 'Código do corretor inválido!' || V_Erro02;
  END IF;
  select count(corretor) into V_Conta from real_corretores where corretor = P_Corretor;
  IF (V_Conta = 0) THEN
     RETURN V_Erro01 || V_ErroCorr || TO_Char(P_Corretor) || V_Invalido || V_Erro02;
  END IF;

  -- Verifica se pproduto e permitido
  IF (P_Produto = 0) THEN
     RETURN V_Erro01 || 'Produto inválido!' || V_Erro02;
  END IF;
  IF (P_Produto <> 10) and (P_Produto <> 42) THEN
     RETURN V_Erro01 || 'Produto "' || TO_Char(P_Produto) || '" não disponivel!' || V_Erro02;
  END IF;

  -- Verifica se corretor + usuario pode executar
  begin
    IF (P_Produto = 10) THEN
       select COTA_AUTOPASSEIO into V_Cota  from ws_config_chamadas where corretor = P_Corretor;
    ELSIF (P_Produto = 42 ) THEN
       select COTA_AUTOCLASSICO INTO V_Cota from ws_config_chamadas where corretor = P_Corretor;
    END IF;
    IF (V_Cota <> 'S') THEN
      RETURN V_Erro01 || V_ErroDisp || V_Erro02;
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN V_ErroDisp;
  END;

  RETURN 'OK';

end;
/


CREATE OR REPLACE function fws004_checkuser2(
   P_Corretor IN INTEGER,
   P_Usuario  IN VARCHAR2,
   P_Produto  IN INTEGER,
   P_WSConfig OUT WS_CONFIG_CHAMADAS%ROWTYPE,
   P_Erros    IN OUT TWS001_MSGS
) return BOOLEAN
IS
   V_Conta Integer;
   V_Size  Integer;
   -- V_Cota  VARCHAR2(10);
   V_Invalido VARCHAR(100)  := '" inválido!';
   V_ErroUser VARCHAR2(200) := 'Código do usuário informado "';
   V_ErroCorr VARCHAR2(200) := 'Código do corretor informado "';
   V_ErroDisp VARCHAR2(200) := 'Corretor não autorizado a cotar este produto.';

   procedure AddErro(P_Codigo IN INTEGER, P_MSG IN VARCHAR2) IS
     V_MSG   RWS005_MSG;
   BEGIN
     V_MSG := RWS005_MSG(NULL,NULL);
     V_MSG.Codigo    := P_Codigo;
     V_MSG.Descricao := P_Msg;
     P_Erros.extend;
     P_Erros(P_Erros.count) := V_MSG;
   END;
begin

  -- Verifica se Corretor existe
  IF (P_Corretor = 0) or  (P_Corretor IS NULL) THEN
     AddErro(4001, 'Código do corretor vazio ou inválido!');
     RETURN FALSE;
  END IF;

  -- Verifica se Produto valido
  IF (P_Produto = 0) or (P_Produto IS NULL) THEN
     AddErro(4002, 'Código do produto vazio ou inválido!');
     RETURN FALSE;
  END IF;

  -- Verifica se Usuario vazio
  V_Size := Length(P_USUARIO);
  IF (V_Size = 0) or (V_Size IS NULL) THEN
     AddErro(4003, 'Código do usuário vazio ou inválido!');
     RETURN FALSE;
  END IF;


  -- Verifica se Usuario existe
  select count(cod_usuario) into V_Conta from real_usuarios where cod_usuario = P_Usuario;
  IF (V_Conta = 0) THEN
     AddErro(4004, V_ErroUser || P_Usuario || V_Invalido);
     RETURN FALSE;
  END IF;

  -- Verifica se Corretor existe
  select count(corretor) into V_Conta from real_corretores where corretor = P_Corretor;
  IF (V_Conta = 0) THEN
     AddErro(4005, V_ErroCorr || TO_Char(P_Corretor) || V_Invalido);
     RETURN FALSE;
  END IF;


  -- Verifica se pproduto e permitido
  IF ((P_Produto <> 1 and P_Produto <> 10) and P_Produto <> 42) THEN
     AddErro(4006, 'Produto "' || TO_Char(P_Produto) || '" não disponivel!');
     RETURN FALSE;
  END IF;

  -- Verifica se corretor + usuario pode executar
  begin
    select* into P_WSConfig  from ws_config_chamadas where corretor = P_Corretor;

    IF (P_Produto = 10 AND P_WSConfig.Cota_Autopasseio <> 'S') THEN
      AddErro(4007, V_ErroDisp || ' (Auto Passeio)');
      RETURN FALSE;
    ELSIF (P_Produto = 42 AND P_WSConfig.COTA_AUTOCLASSICO <> 'S') THEN
      AddErro(4008, V_ErroDisp || ' (Auto Clássico)');
      RETURN FALSE;
    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      AddErro(4008, V_ErroDisp);
      RETURN FALSE;
  END;

  RETURN TRUE;

end;
/


CREATE OR REPLACE function fws005_getdispositivos(
   P_PRODUTO IN INTEGER,
   P_VIGENCIA IN INTEGER,
   P_DTVIGENCIA IN DATE
) return CLOB
IS
  type TDispSeg_REC  is record (
        Resposta         MULT_PRODUTOSQBRDISPSEG.Resposta%type,
        indgerenciadora  MULT_PRODUTOSQBRDISPSEG.indgerenciadora%type,
        DESCRICAO        MULT_PRODUTOSQBRDISPSEG.DESCRICAO%type
     );

  type TDispGer_REC  is record (
        GERENCIADORA     MULT_PRODUTOSQBRGERENCIADORAS.GERENCIADORA%type,
        DESCRICAO        MULT_PRODUTOSQBRGERENCIADORAS.DESCRICAO%type
     );

  type TDispSeg_TAB  is table of TDispSeg_REC;
  type TDispGer_TAB  is table of TDispGer_REC;
  V_DispSeg TDispSeg_TAB;
  V_DispGer TDispGer_TAB;

  V_XML CLOB;
  V_RET01 VARCHAR(20);
  V_RET02 VARCHAR(20);
  V_RET03 VARCHAR(20);
begin

  V_RET01 := '<Mensagem>';
  V_RET02 := '</Mensagem>';

  -- Lista Dipositivos Aceitos
  BEGIN
    	SELECT 	Dispositivo,
		indgerenciadora,
                DESCRICAO
        BULK COLLECT INTO V_DispSeg
	FROM MULT_PRODUTOSQBRDISPSEG
	WHERE PRODUTO  = P_PRODUTO
          AND VIGENCIA = P_VIGENCIA
          AND P_DTVIGENCIA  BETWEEN DT_INICO_VIGEN AND DT_FIM_VIGEN;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      V_RET03 := 'Dispositivos';
      -- V_Return :=  V_RET01 || 'Dispositivos de seguranca nao encontrado.' || V_RET02;
      -- RETURN V_Return;
  END;

  -- Lista Gerenciadoras Aceitas
  BEGIN
  SELECT   GERENCIADORA,
                DESCRICAO
        BULK COLLECT INTO V_DispGer
  FROM MULT_PRODUTOSQBRGERENCIADORAS
  WHERE PRODUTO  = P_PRODUTO
          AND VIGENCIA = P_VIGENCIA
          AND P_DTVIGENCIA  BETWEEN DT_INICO_VIGEN AND DT_FIM_VIGEN;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      V_RET03 := 'Gerenciadoras';
      -- V_Return :=  V_RET01 || 'Gerenciadoras de seguranca nao encontrada.' || V_RET02;
      -- RETURN V_Return;
  END;

  -- Dispositivo e incluido como uma pergunta no QBR
  -- Estes Valores sao  constantes.
  V_XML   := '<Questao><CodigoPergunta>243</CodigoPergunta>'
             || '<Descricao>O veículo possui dispositivo de segurança reconhecido:</Descricao><DescricaoLonga/>'
             || '<Respostas><Resposta><CodigoResposta>582</CodigoResposta><Descricao>A. Não Possui</Descricao></Resposta>'
             || '<Resposta><CodigoResposta>586</CodigoResposta><Descricao>B. Dispositivo Próprio</Descricao>' ;


  -- Verifica se existem Dispositivos de Seguranca
  IF (V_DispSeg.Count > 0) THEN
    -- Inclui Tag Inicial
    V_XML  := V_XML || '<SubRespostas>';
    -- Para Cada Dispositivo
    FOR I IN 1 .. V_DispSeg.count LOOP
       V_XML  := V_XML || '<SubResposta><CodigoSubResposta>' || TO_CHAR(V_DispSeg(I).Resposta)
                       || '</CodigoSubResposta><Descricao>'  || V_DispSeg(I).DESCRICAO
                       || '</Descricao><EmpresaGerenciadora>';

       -- Verifica se o dispositivo usa gerenciadora.
       IF (V_DispSeg(I).indgerenciadora = 0) THEN
          V_XML  := V_XML || 'N</EmpresaGerenciadora></SubResposta>';
       ELSE
          V_XML  := V_XML || 'S</EmpresaGerenciadora></SubResposta>';
      END IF;
    END LOOP;
    -- Inclui Tag Final
    V_XML  := V_XML || '</SubRespostas>';
  END IF;


  -- Verifica se existem Gerenciadoras
  IF (V_DispGer.COunt > 0) then
    -- Inclui Tag Inicial
    V_XML  := V_XML || '<SubRespostas2>';
    -- Para Cada Gerenciadora
    FOR I IN 1 .. V_DispGer.count LOOP
       V_XML  := V_XML || '<SubResposta><CodigoSubResposta>' || TO_CHAR(V_DispGer(I).Gerenciadora)
                       || '</CodigoSubResposta><Descricao>'  || V_DispGer(I).DESCRICAO
                       || '</Descricao></SubResposta>';
    END LOOP;
    -- Inclui Tag Final
    V_XML  := V_XML || '</SubRespostas2>';
  END IF;

    -- Termina a estrutura
  V_XML  := V_XML || '</Resposta></Respostas></Questao>';


  RETURN  V_XML;

end;
/


CREATE OR REPLACE function fws006_getqbrxml(
   P_PRODUTO IN INTEGER,
   P_VIGENCIA IN INTEGER,
   P_VERSAO IN INTEGER,
   P_AGRUPAMENTO IN INTEGER,
   P_COBERTURA IN INTEGER,
   P_QBRID IN VARCHAR2,
   P_DTVIGENCIA IN DATE
) return CLOB
IS

  type TQBR_REC  is record (
        Nivel            INTEGER,
        Usado            Integer,
        Questao          MULT_PRODUTOSQBRNIVEL1.QUESTAO%type,
        Resposta         MULT_PRODUTOSQBRRESPOSTAS.Resposta%type,
        Ordem            MULT_PRODUTOSQBRNIVEL1.Ordem%type,
        Questao2         MULT_PRODUTOSQBRNIVEL1.QUESTAO%type,
        Descricao        MULT_PRODUTOSQBRRESPOSTAS.DESCRICAO%type,
        Descricao2       MULT_PRODUTOSQBRRESPOSTAS.DESCRICAO%type
     );

  type TQbrNivel_REC  is record (
        Resposta         MULT_PRODUTOSQBRNIVEL2.RESPOSTANIVEL1%type,
        Questao          MULT_PRODUTOSQBRNIVEL2.QUESTAONIVEL2%type
     );

  type TQbrOrdem_REC  is record (
        Questao          MULT_PRODUTOSQBRNIVEL2.QUESTAONIVEL2%type
     );


  type TQBR_TAB       is table of TQBR_REC;
  type TQbrNivel_TAB  is table of TQbrNivel_REC;
  type TQbrOrdem_TAB  is table of TQbrOrdem_REC;

  V_Qbr20  TQbrNivel_TAB;
  V_Qbr30  TQbrNivel_TAB;
  V_Qbr10  TQbrOrdem_TAB;
  V_Qbr21  TQbrOrdem_TAB;
  V_Qbr31  TQbrOrdem_TAB;
  V_Ordem  TQbrOrdem_REC;
  V_QbrAll TQBR_TAB;
  V_RETURN VARCHAR2(5000);
  V_XML VARCHAR2(32000);
  V_0     INTEGER  := 0;
  V_1     INTEGER  := 1;
  V_2     INTEGER  := 2;
  V_3     INTEGER  := 3;
  V_VAZIO VARCHAr2(2)  := '';
  V_RET01 VARCHAR2(20) := '<QBR/><Erros>';
  V_RET02 VARCHAR2(20) := '</Erros>';
  V_RET03 VARCHAR2(20) := '<Mensagem>';
  V_RET04 VARCHAR2(20) := '</Mensagem>';
  V_COUNT INTEGER;

  procedure GeraXmlQuestao(P_Idx IN Integer)
  IS
  BEGIN
      V_QbrAll(P_Idx).Usado := 1;
      -- Inclui pergunta
      V_XML  := V_XML || '<Questao><CodigoPergunta>'    || TO_CHAR(V_QbrAll(P_Idx).QUESTAO)
                      || '</CodigoPergunta><Descricao>' || V_QbrAll(P_Idx).DESCRICAO
                      || '</Descricao><Respostas>';

      V_Qbr10 := TQbrOrdem_TAB();
      -- Pesquisa em toda a lista
      FOR J IN 1 .. V_QbrAll.count LOOP
         -- Verifica que a questao e a mesma e se e uma resposta
         IF (V_QbrAll(P_Idx).Questao = V_QbrAll(j).Questao) AND (V_QbrAll(j).Resposta <> 0) THEN

             V_XML  := V_XML || '<Resposta><CodigoResposta>'    || TO_CHAR(V_QbrAll(j).RESPOSTA)
                             || '</CodigoResposta><Descricao>'  || V_QbrAll(j).DESCRICAO
                             || '</Descricao>';
             IF (V_QbrAll(j).DESCRICAO2 IS NULL) THEN
                V_XML  := V_XML || '<DescricaoLonga/>';
             ELSE
                V_XML  := V_XML || '<DescricaoLonga>' || V_QbrAll(j).DESCRICAO2 || '</DescricaoLonga>';
             END IF;

             -- Verifica se a resposta tem uma sub-questao
             IF (V_QbrAll(j).QUESTAO2 <> 0) then
                 V_XML  := V_XML || '<SubQuestoes><CodigoSubQuestao>' || TO_CHAR(V_QbrAll(j).QUESTAO2)
                                 || '</CodigoSubQuestao></SubQuestoes>';
                 V_Qbr10.extend;
                 V_Ordem.Questao := V_QbrAll(j).QUESTAO2;
                 V_Qbr10(V_Qbr10.Count) := V_Ordem;
             END IF;

             V_XML  := V_XML || '</Resposta>';

         END IF;
      END LOOP;
      -- Fecha os Tags em Abeto
      V_XML  := V_XML || '</Respostas></Questao>';
  END;
begin

  -- Seleciona Perguntas e Resposta do QBR Nivel 1, 2 e 3

  SELECT T9.NIVEL AS NIVEL,
         T9.Usado AS Usado,
         T9.QUESTAO AS Questao,
         T9. RESPOSTA AS Resposta,
         T9.ORDEM  AS Ordem,
         T9.Q2 AS Questao2,
         T9.DESCRICAO  AS Descricao,
         T9.DESCRICAO2 AS Descricao2
  BULK COLLECT INTO V_QbrAll
  FROM
  (

        -- Seleciona Perguntas QBR Nivel 1
  SELECT   V_1 as nivel,
    T1.QUESTAO AS QUESTAO,
    V_0 AS Usado,
    V_0 AS RESPOSTA,
    T1.ORDEM AS ORDEM,
    V_0 AS Q2,
    T2.DESCRICAO AS DESCRICAO,
    V_VAZIO AS DESCRICAO2
  FROM MULT_PRODUTOSQBRNIVEL1 T1
  LEFT JOIN MULT_PRODUTOSQBRQUESTOES  T2
  ON    T2.PRODUTO   = T1.PRODUTO
    AND T2.QUESTAO   = T1.QUESTAO
    AND T2.VIGENCIA  = T1.VIGENCIA
    AND T2.COBERTURA = P_COBERTURA
  WHERE T1.PRODUTO   = P_PRODUTO
    AND T1.VIGENCIA  = P_VIGENCIA
    AND T1.VERSAO    = P_VERSAO
    AND T1.CODIGO    = P_QBRID
    AND P_DTVIGENCIA  BETWEEN T2.DT_INICO_VIGEN AND T2.DT_FIM_VIGEN
  UNION
        -- Seleciona Respostas do QBR Nivel 1
  SELECT   V_1 as nivel,
    T1.QUESTAO AS QUESTAO,
    V_0 AS Usado,
    T2.RESPOSTA AS RESPOSTA,
    T1.ORDEM AS ORDEM,
    V_0 AS Q2,
    T2.DESCRICAO  AS DESCRICAO,
    T2.DESCRICAO2 AS DESCRICAO2
  FROM MULT_PRODUTOSQBRNIVEL1 T1
  LEFT JOIN MULT_PRODUTOSQBRRESPOSTAS  T2
  ON    T2.PRODUTO     = T1.PRODUTO
    AND T2.QUESTAO     = T1.QUESTAO
    AND T2.VIGENCIA    = T1.VIGENCIA
    AND T2.COBERTURA   = P_COBERTURA
    AND T2.AGRUPAMENTO = P_AGRUPAMENTO
    AND T2.MOSTRA      = V_1
  WHERE T1.PRODUTO  = P_PRODUTO
    AND T1.VIGENCIA = P_VIGENCIA
    AND T1.VERSAO   = P_VERSAO
    AND T1.CODIGO   = P_QBRID
    AND P_DTVIGENCIA  BETWEEN T2.DT_INICO_VIGEN AND T2.DT_FIM_VIGEN

  UNION

        -- Seleciona Perguntas QBR Nivel 2
  SELECT   V_2 as nivel,
    QUESTAONIVEL2 AS QUESTAO,
    V_0 AS Usado,
    V_0 AS RESPOSTA,
    V_0 AS ordem,
    V_0 AS Q2,
    T2.DESCRICAO AS DESCRICAO,
    V_VAZIO AS DESCRICAO2
  FROM MULT_PRODUTOSQBRNIVEL2 T1
  LEFT JOIN MULT_PRODUTOSQBRQUESTOES  T2
  ON    T2.PRODUTO   = T1.PRODUTO
    AND T2.QUESTAO   = T1.QUESTAONIVEL2
    AND T2.VIGENCIA  = T1.VIGENCIA
    AND T2.COBERTURA = P_COBERTURA
  WHERE T1.PRODUTO   = P_PRODUTO
    AND T1.VIGENCIA  = P_VIGENCIA
    AND T1.VERSAO    = P_VERSAO
    AND T1.CODIGO    = P_QBRID
    AND P_DTVIGENCIA  BETWEEN T2.DT_INICO_VIGEN AND T2.DT_FIM_VIGEN

  UNION

        -- Seleciona Respostas do QBR Nivel 2
  SELECT   V_2 as nivel,
    QUESTAONIVEL2 AS QUESTAO,
    V_0 AS Usado,
    T2.RESPOSTA AS RESPOSTA,
    V_0 AS ordem,
    V_0 AS Q2,
    T2.DESCRICAO  AS DESCRICAO,
    T2.DESCRICAO2 AS DESCRICAO2
  FROM MULT_PRODUTOSQBRNIVEL2 T1
  LEFT JOIN MULT_PRODUTOSQBRRESPOSTAS  T2
  ON    T2.PRODUTO     = T1.PRODUTO
    AND T2.QUESTAO     = T1.QUESTAONIVEL2
    AND T2.VIGENCIA    = T1.VIGENCIA
    AND T2.COBERTURA   = P_COBERTURA
    AND T2.AGRUPAMENTO = P_AGRUPAMENTO
    AND T2.MOSTRA      = V_1
  WHERE T1.PRODUTO   = P_PRODUTO
    AND T1.VIGENCIA  = P_VIGENCIA
    AND T1.VERSAO    = P_VERSAO
    AND T1.CODIGO    = P_QBRID
    AND P_DTVIGENCIA  BETWEEN T2.DT_INICO_VIGEN AND T2.DT_FIM_VIGEN

  UNION

        -- Seleciona Perguntas QBR Nivel 3
  SELECT   distinct V_3 as nivel,
    QUESTAONIVEL3 AS QUESTAO,
    V_0 AS Usado,
    V_0 AS RESPOSTA,
    V_0 AS ordem, V_0 AS Q2,
    T2.DESCRICAO AS DESCRICAO,
    V_VAZIO AS DESCRICAO2
  FROM MULT_PRODUTOSQBRNIVEL3 T1
  LEFT JOIN MULT_PRODUTOSQBRQUESTOES  T2
  ON    T2.PRODUTO   = T1.PRODUTO
    AND T2.QUESTAO   = T1.QUESTAONIVEL3
    AND T2.VIGENCIA  = T1.VIGENCIA
    AND T2.COBERTURA = P_COBERTURA
  WHERE T1.PRODUTO   = P_PRODUTO
    AND T1.VIGENCIA  = P_VIGENCIA
    AND T1.VERSAO    = P_VERSAO
    AND T1.CODIGO    = P_QBRID
    AND P_DTVIGENCIA  BETWEEN T2.DT_INICO_VIGEN AND T2.DT_FIM_VIGEN

  UNION

        -- Seleciona Respostas do QBR Nivel 3
  SELECT   distinct V_3 as nivel,
    QUESTAONIVEL3 AS QUESTAO,
    V_0 AS Usado,
    T2.RESPOSTA AS RESPOSTA,
    V_0 AS ordem, V_0 AS Q2,
    T2.DESCRICAO  AS DESCRICAO,
    T2.DESCRICAO2 AS DESCRICAO2
  FROM MULT_PRODUTOSQBRNIVEL3 T1
  LEFT JOIN MULT_PRODUTOSQBRRESPOSTAS  T2
  ON    T2.PRODUTO     = T1.PRODUTO
    AND T2.QUESTAO     = T1.QUESTAONIVEL3
    AND T2.VIGENCIA    = T1.VIGENCIA
    AND T2.COBERTURA   = P_COBERTURA
    AND T2.AGRUPAMENTO = P_AGRUPAMENTO
    AND T2.MOSTRA      = V_1
  WHERE T1.PRODUTO   = P_PRODUTO
    AND T1.VIGENCIA  = P_VIGENCIA
    AND T1.VERSAO    = P_VERSAO
    AND T1.CODIGO    = P_QBRID
    AND P_DTVIGENCIA  BETWEEN T2.DT_INICO_VIGEN AND T2.DT_FIM_VIGEN
  ORDER BY nivel, ordem, questao, resposta
  ) T9;

  -- Verifica se existem perguntas nivel 2
  V_Count := 0;
  FOR i IN 1 .. V_QbrAll.COUNT LOOP
    IF (V_QbrAll(i).NIVEL = 2) THEN
       V_Count := 1;
    END IF;
  END LOOP;


  if (V_COUNT > 0 ) then

    -- Verificando Resposta X Pergunta Nivel 2
    BEGIN
      SELECT T9.RESPOSTA, T9.QUESTAO
      BULK COLLECT INTO V_QBR20
      FROM (  SELECT
           RESPOSTANIVEL1 AS Resposta,
        QUESTAONIVEL2  AS Questao
        FROM MULT_PRODUTOSQBRNIVEL2
        WHERE PRODUTO  = P_PRODUTO
          AND QUESTAONIVEL2  > V_0
          AND VIGENCIA = P_VIGENCIA
          AND VERSAO   = P_VERSAO
          AND CODIGO   = P_QBRID
           ) T9;

      FOR i IN 1 .. V_QBR20.COUNT LOOP
        FOR j IN 1 .. V_QbrAll.COUNT LOOP
          IF ((V_QbrAll(j).NIVEL = 1) and (V_QbrAll(j).RESPOSTA = V_QBR20(i).RESPOSTA)) THEN
             V_QbrAll(j).QUESTAO2 := V_QBR20(i).QUESTAO;
          END IF;
        END LOOP;
      END LOOP;


      -- Verifica se existem perguntas nivel 3
      V_Count := 0;
      FOR i IN 1 .. V_QbrAll.COUNT LOOP
        IF (V_QbrAll(i).NIVEL = 3) THEN
           V_Count := 1;
        END IF;
      END LOOP;


      if (V_COUNT > 0 ) then

        -- Verificando Resposta X Pergunta Nivel 3
        BEGIN

          SELECT T9.RESPOSTA, T9.QUESTAO
          BULK COLLECT INTO V_QBR30
          FROM (  SELECT RESPOSTANIVEL2 AS resposta,
                         QUESTAONIVEL3 AS QUESTAO
                  FROM MULT_PRODUTOSQBRNIVEL3
                  WHERE PRODUTO  = P_PRODUTO
                    AND QUESTAONIVEL3  > 0
                    AND VIGENCIA = P_VIGENCIA
                    AND VERSAO   = P_VERSAO
                    AND CODIGO   = P_QBRID
               ) T9;

          FOR i IN 1 .. V_QBR30.COUNT LOOP
            FOR j IN 1 .. V_QbrAll.COUNT LOOP
              IF ((V_QbrAll(j).NIVEL = 2) and (V_QbrAll(j).RESPOSTA = V_QBR30(i).RESPOSTA)) THEN
                V_QbrAll(j).QUESTAO2 := V_QBR30(i).QUESTAO;
              END IF;
            END LOOP;
          END LOOP;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
          V_Return :=  V_RET01 || V_RET03 ||'QBR Nivel 3 nao encontrado' || V_RET04 ||V_RET02;
          RETURN V_Return;
        END;

   end if;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
      V_Return :=  V_RET01 || V_RET03 ||'QBR Nivel 2 nao encontrado' || V_RET04 ||V_RET02;
      RETURN V_Return;
    END;

  end if;


  V_XML   := '<QBR>';

  -- Pesquisa em toda a lista
  FOR I IN 1 .. V_QbrAll.count LOOP
    -- Verifica se e uma pergunta
    IF (V_QbrAll(i).Resposta = 0) and (V_QbrAll(I).Nivel = 1) and (V_QbrAll(I).QUESTAO <> 87)  THEN
      -- Gera XML Questao Nivel 1
      GeraXmlQuestao(I);

      -- Verifica se ha Questos de Nivel 2
      IF (V_Qbr10.count > 0) THEN
         -- Gera uma Copia das questoes de nivel 2
         V_Qbr21 := TQbrOrdem_TAB();
         FOR j IN 1 .. V_Qbr10.count LOOP
             V_Qbr21.extend;
             V_Qbr21(j) := V_Qbr10(j);
         END LOOP;
         -- Para Cada Questao de nivel 2
         FOR K1 IN 1 .. V_Qbr21.count LOOP
            -- Pesquisa em toda a Lista de Questoes
            FOR K2 IN 1 .. V_QbrAll.count LOOP
               -- Identifica a Lista de Pergutas
               IF (V_QbrAll(K2).Resposta = 0) and (V_QbrAll(K2).Nivel = 2) and
                  (V_QbrAll(k2).QUESTAO = V_Qbr21(K1).Questao) and (V_QbrAll(k2).Usado = 0)  THEN

                  -- Gera XML Questao Nivel 2
                  GeraXmlQuestao(K2);

                  -- Verifica se ha Questos de Nivel 3
                  IF (V_Qbr10.count > 0) THEN
                     -- Gera uma Copia das questoes de nivel 3
                     V_Qbr31 := TQbrOrdem_TAB();
                     FOR j IN 1 .. V_Qbr10.count LOOP
                        V_Qbr31.extend;
                        V_Qbr31(j) := V_Qbr10(j);
                     END LOOP;

                     -- Para Cada Questao de nivel 3
                     FOR L1 IN 1 .. V_Qbr31.count LOOP
                       -- Pesquisa em toda a Lista de Questoes
                        FOR L2 IN 1 .. V_QbrAll.count LOOP
                           -- Identifica a Lista de Pergutas
                           IF (V_QbrAll(L2).Resposta = 0) and (V_QbrAll(L2).Nivel = 3) and
                              (V_QbrAll(L2).QUESTAO = V_Qbr31(L1).Questao) and (V_QbrAll(L2).Usado = 0)  THEN

                              -- Gera XML Questao Nivel 3
                              GeraXmlQuestao(L2);

                           END IF; -- XML Pergunta Nivel 3
                        END LOOP; -- Lista de Perguntas 3
                     END LOOP; -- Perguntas Nivel 3
                  END IF; -- Pergunta Nivel 3
               END IF; -- XML Pergunta Nivel 2
            END LOOP; -- Lista de Perguntas 2
         END LOOP; -- Perguntas Nivel 2
      END IF; -- Pergunta Nivel 2
    END IF; -- XML Pergunta Nivel 1
  END LOOP;

  V_XML  := V_XML || FWS005_GetDispositivos(P_PRODUTO, P_Vigencia, P_DtVigencia ) || '</QBR>';

  RETURN  V_XML;

END;
/


CREATE OR REPLACE FUNCTION fws007_isnumber( P_Number IN VARCHAR2 ) RETURN NUMBER IS
V_Number NUMBER(18,0);
V_TEXT   VARCHAR2(30);
BEGIN
  V_TEXT := TRIM(P_Number);
  IF  (V_TEXT IS NULL) then
     RETURN 0;
  ELSE
     V_Number :=  TO_NUMBER(V_TEXT);
  END IF;
  RETURN V_Number;
EXCEPTION
  WHEN OTHERS THEN RETURN 0;
END;
/


CREATE OR REPLACE function fws008_isdate( P_Date IN VARCHAR2)
  RETURN DATE
IS
  V_TEXT  VARCHAR(20);
  V_Date  DATE;
  V_Erro  VARCHAR2(20) := '01-01-0001';
  V_DtFrm VARCHAR2(20) := 'DD-MM-YYYY';
  v_posicao_branco      NUMBER;
  v_date_temp   VARCHAR2(100);
BEGIN
  v_posicao_branco      :=      InStr(P_Date,' ');
  IF    v_posicao_branco        >       0       THEN
        --
        v_date_temp        :=      SubStr(p_date,1,v_posicao_branco);
        --
  ELSE
        --
        v_date_temp     :=      p_date;
        --
  END   IF;
  --
  V_TEXT := Trim(v_date_temp);
  --
  IF (V_TEXT IS NULL) THEN
    --
    RETURN to_date( V_Erro, V_DtFrm );
    --
  END IF;
  --
  V_Date :=  to_date( V_TEXT,  V_DtFrm);
  --
  RETURN V_Date;
  --
EXCEPTION
--
  WHEN others THEN
  --
    V_Date :=  to_date( V_Erro, V_DtFrm );
    --
    RETURN V_Date;
    --
END;
/


CREATE OR REPLACE FUNCTION fws009_iscep( P_CEP IN VARCHAR2 ) RETURN NUMBER IS
BEGIN
  RETURN TO_NUMBER(TRIM(Replace(P_CEP, '-')));
EXCEPTION
  WHEN OTHERS THEN RETURN 0;
END;
/


CREATE OR REPLACE function FWS010_CheckDivisoes(
   P_CORRETOR    IN     INTEGER,
   P_CAPTADORA   IN OUT INTEGER,
   P_COBRADORA   IN OUT INTEGER,
   P_ESTIPULANTE IN     INTEGER,
   P_Divisao     OUT    INTEGER,
   P_Erros       IN OUT TWS001_MSGS -- Retorna os erros
) return BOOLEAN
IS

  type TDIVISAO_REC  is record (
        Nivel            INTEGER,
        DIVISAO          Tabela_Divisoes.DIVISAO%type
     );

  type TDIVISAO_TAB is table of TDIVISAO_REC;

  V_DIVISAO TDIVISAO_TAB;
  V_HASERRO BOOLEAN;
  V_FOUND   BOOLEAN;
  V_A       VARCHAR2(1)    := 'A';
  V_B       VARCHAR2(1)    := 'B';
  V_C       VARCHAR2(1)    := 'C';
  V_E       VARCHAR2(1)    := 'E';
  V_ERR1    VARCHAR(20)    := 'Corretor ';
  V_ERR2    VARCHAR(20)    := 'Agencia Captadora ';
  V_ERR3    VARCHAR(20)    := 'Agencia Cobradora ';
  V_ERR4    VARCHAR(20)    := 'Estipulante ';
  V_ERR5    VARCHAR(20)    := ' não encontrado.';
  V_ERR6    VARCHAR(20)    := ' não encontrada.';
  V_1       INTEGER        := 1;
  V_2       INTEGER        := 2;
  V_3       INTEGER        := 3;
  V_4       INTEGER        := 4;
  V_COBRADORA   INTEGER;
  V_CAPTADORA   INTEGER;

   procedure AddErro(P_Codigo IN INTEGER, P_MSG VARCHAR2) IS
      V_MSG      RWS005_MSG;
   BEGIN
     V_MSG := RWS005_MSG(NULL,NULL);
     V_MSG.Codigo    := P_CODIGO;
     V_MSG.Descricao := P_MSG;
     P_Erros.extend;
     P_Erros(P_Erros.count) := V_MSG;
   END;



begin
  V_HASERRO := FALSE;

  -- Se Agencia Cobradora nao foi definida obtem a primeira ativa
  IF (P_COBRADORA = 0) or  (P_COBRADORA IS NULL) THEN
     BEGIN
         SELECT Divisao into V_Cobradora from Tabela_Divisoes
         WHERE  tipo_divisao = V_C -- Agencia Cobradora
         AND    situacao = V_A
         AND    ROWNUM = V_1;
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
        BEGIN
           V_COBRADORA := 0;
        END;
     END;
  ELSE
     V_COBRADORA := P_COBRADORA;
  END IF;

  -- Se Agencia Captadora nao foi definida obtem da tabela de corretores
  IF (P_CAPTADORA = 0) or  (P_CAPTADORA IS NULL) THEN
     BEGIN
        SELECT USR.Agencia INTO V_CAPTADORA FROM Tabela_Divisoes  DIV
        INNER  JOIN REAL_USUARIOS USR
        ON     USR.Corretor = DIV.Divisao
        WHERE  DIV.Divisao_Superior = P_CORRETOR
        AND    DIV.tipo_divisao = V_E
        AND    ROWNUM = V_1;
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
        BEGIN
           V_CAPTADORA := 0;
        END;
     END;
  ELSE
     V_CAPTADORA := P_CAPTADORA;
  END IF;

  -- Seleciona as linhas da divisao
  BEGIN

    SELECT T9.NIVEL AS NIVEL,
           T9.Divisao AS Divisao
    BULK COLLECT INTO V_DIVISAO
    FROM
    (
       -- Corretor, Agencia Cobradora, Agencia Captadora, Estipulante
       Select V_1 as Nivel, Divisao from Tabela_Divisoes
       where   Divisao_Superior = P_Corretor    and  tipo_divisao = V_E -- Corretor
     UNION
       Select V_2 as Nivel, Divisao from Tabela_Divisoes
       where   Divisao_Superior = V_Captadora   and  tipo_divisao = V_A -- Agencia Captadora
     UNION
       Select V_3 as Nivel, Divisao from Tabela_Divisoes
       where   Divisao_Superior = V_Cobradora   and  tipo_divisao = V_C -- Agencia Cobradora
     UNION
       Select V_4 as Nivel, Divisao from Tabela_Divisoes
       where   Divisao_Superior = P_Estipulante and  tipo_divisao = V_B -- Estipulante
    ) T9;

  EXCEPTION
      WHEN NO_DATA_FOUND THEN
      BEGIN
        V_HASERRO := TRUE;
        AddErro(1101, V_ERR2 || TO_CHAR(P_CAPTADORA)   || V_ERR5);
        IF (P_Captadora > 0) THEN
           AddErro(1102, V_ERR2 || TO_CHAR(V_CAPTADORA)   || V_ERR6);
        END IF;
        IF (P_Cobradora > 0) THEN
           AddErro(1103, V_ERR3 || TO_CHAR(V_Cobradora)   || V_ERR6);
        END IF;
        IF (P_Estipulante > 0) THEN
           AddErro(1104, V_ERR4 || TO_CHAR(P_Estipulante) || V_ERR5);
        END IF;
        RETURN NOT V_HASERRO;
      END;
  END;

  -- Verifica se existe Divisao para o Corretor Informado
  P_Divisao := 0;
  V_FOUND := FALSE;
  FOR i IN 1 .. V_DIVISAO.COUNT LOOP
     IF (V_DIVISAO(i).NIVEL = 1) THEN
        V_FOUND   := TRUE;
        P_Divisao := V_DIVISAO(i).Divisao;
     END IF;
  END LOOP;
  IF (NOT V_FOUND) THEN
     V_HASERRO := TRUE;
     AddErro(1105, V_ERR1 || TO_CHAR(P_CORRETOR) || V_ERR5);
  END IF;

  -- Verifica se existe Divisao para a Agencia Captadora Informado
  V_FOUND := FALSE;
  IF (P_Captadora > 0) THEN
     FOR i IN 1 .. V_DIVISAO.COUNT LOOP
        IF (V_DIVISAO(i).NIVEL = 2) THEN
           V_FOUND := TRUE;
        END IF;
     END LOOP;
     IF (NOT V_FOUND) THEN
        V_HASERRO := TRUE;
        AddErro(1106, V_ERR2 || TO_CHAR(V_CAPTADORA) || V_ERR6);
     END IF;
  END IF;

  -- Verifica se existe Divisao para a Agencia Cobradora Informado
  V_FOUND := FALSE;
  IF (P_Cobradora > 0) THEN
     FOR i IN 1 .. V_DIVISAO.COUNT LOOP
        IF (V_DIVISAO(i).NIVEL = 3) THEN
           V_FOUND := TRUE;
        END IF;
     END LOOP;
     IF (NOT V_FOUND) THEN
        V_HASERRO := TRUE;
        AddErro(1107, V_ERR3 || TO_CHAR(V_Cobradora) || V_ERR6);
     END IF;
  END IF;

  -- Verifica se existe Divisao para o Estipulante Informado
  V_FOUND := FALSE;
  IF (P_Estipulante > 0) THEN
     FOR i IN 1 .. V_DIVISAO.COUNT LOOP
        IF (V_DIVISAO(i).NIVEL = 4) THEN
           V_FOUND := TRUE;
        END IF;
     END LOOP;
     IF (NOT V_FOUND) THEN
        V_HASERRO := TRUE;
        AddErro(1108, V_ERR4 || TO_CHAR(P_Estipulante) || V_ERR5);
     END IF;
  END IF;

  P_CAPTADORA := V_CAPTADORA;
  P_COBRADORA := V_COBRADORA;
  RETURN NOT V_HASERRO;

END;
/


CREATE OR REPLACE function FWS011_CALCMILESEC(
   P_DT_FIM    IN TIMESTAMP,
   P_DT_INI    IN TIMESTAMP
) return INTEGER
IS
  W_MILE Integer;
begin
select extract( day from diff )*24*60*60*1000 +
       extract( hour from diff )*60*60*1000 +
       extract( minute from diff )*60*1000 +
       round(extract( second from diff )*1000) total_milliseconds
       into W_MILE
       from (select (P_DT_FIM - P_DT_INI) diff from DUAL);

  return W_MILE;
end;
/


CREATE OR REPLACE FUNCTION fws012_checkqbr(
   P_DADOS              IN OUT RWS001_Dados,       -- Dados de Validacao
   P_QbrCalculo         IN OUT TWS009_CALCULOQBR,  -- Lista com as questoes e respostas
   P_Erros              IN OUT TWS001_MSGS,        -- Retorna os erros
   P_Avisos             IN OUT TWS001_MSGS         -- Retorna os avisos
) return BOOLEAN
IS

  type TQBRDpl_Rec is record (
        Questao          MULT_PRODUTOSQBRNIVEL1.QUESTAO%type,
        Conta            Integer
     );

  type TQBR_REC  is record (
        Nivel            INTEGER,
        Usado            Integer,
        Questao          MULT_PRODUTOSQBRNIVEL1.QUESTAO%type,
        Resposta         MULT_PRODUTOSQBRRESPOSTAS.Resposta%type,
        Ordem            MULT_PRODUTOSQBRNIVEL1.Ordem%type,
        Questao2         MULT_PRODUTOSQBRNIVEL1.QUESTAO%type,
        Descricao        MULT_PRODUTOSQBRRESPOSTAS.DESCRICAO%type,
        Descricao2       MULT_PRODUTOSQBRRESPOSTAS.DESCRICAO%TYPE,
        MapaDados        MULT_PRODUTOSQBRNIVEL1.MAPADADOS%type,
        Agrupamento      MULT_PRODUTOSQBRAGRUPREG.AGRUPAMENTO%type,
        Vigencia         MULT_PRODUTOSQBRAGRUPREG.VIGENCIA%type
     );

  type TQbrNivel_REC  is record (
        Resposta         MULT_PRODUTOSQBRNIVEL2.RESPOSTANIVEL1%type,
        Questao          MULT_PRODUTOSQBRNIVEL2.QUESTAONIVEL2%type
     );

  type TQbrCheck_REC is record (
        Questao          INTEGER,
        Resposta         INTEGER,
        SubQuestao       Integer,
        Nivel            Integer
     );

  type TQBRDpl_TAB    is table of TQBRDpl_REC;
  type TQBR_TAB       is table of TQBR_REC;
  type TQbrNivel_TAB  is table of TQbrNivel_REC;
  type TQbrCheck_TAB  is table of TQbrCheck_REC;

  V_QbrDpl   TQbrDpl_TAB;
  V_Qbr20    TQbrNivel_TAB;
  V_Qbr30    TQbrNivel_TAB;
  V_QbrCheck TQBRCheck_TAB;
  V_QbrAll   TQBR_TAB;
  V_QBR      TWS002_QBR;
  V_CalcQbr  RWS009_CALCULOQBR;

  V_Check    TQbrCheck_REC;
  V_DplRec   TQBRDpl_REC;
  V_QbrRec   RWS002_QBR;

  C_250      INTEGER  := 250; -- QBR O principal condutor e o segurado
  C_662      INTEGER  := 662; -- QBR Sim, o principal condutor e o segurado
  C_243      INTEGER  := 243; -- QBR Necessario Dispositovo de Rastreamento


  V_CEP      Integer;
  V_Checked  BOOLEAN;
  V_Found    BOOLEAN;


  C_0            INTEGER  := 0;
  C_1            INTEGER  := 1;
  C_2            INTEGER  := 2;
  C_3            INTEGER  := 3;
  C_10           INTEGER  := 10;
  C_24           INTEGER  := 24;
  C_25           INTEGER  := 25;
  C_50           INTEGER  := 50;
  V_VAZIO        VARCHAr2(2)  := '';

  V_LAST             INTEGER;
  V_COUNT            INTEGER;
  V_CONTA            INTEGER;
  V_REGIAO           INTEGER;
  V_VIGENCIA         INTEGER;
  V_Agrupamento      INTEGER;
  V_CanalVenda       INTEGER;
  V_Cobertura        INTEGER;
  V_QbrId            VARCHAR2(10);
  V_Versao           INTEGER;
  V_Aux1             INTEGER;
  V_Aux2             INTEGER;
  V_CondutorSegurado BOOLEAN;
  V_TemQbr250        BOOLEAN;
  V_TemComodato      BOOLEAN;
  V_ComodatoRanking  Integer;
  V_VeiculoRanking   Integer;
  V_CodComodato      VARCHAR2(10);
  V_RespComodato     INTEGER;
  V_NomeComodato     VARCHAR2(100);
  V_MsgComodato      VARCHAR2(300);
  V_NomeDispositivo    VARCHAR2(350);
  V_NomeGerenciadora   VARCHAR2(350);

   procedure AddErro(P_Codigo IN INTEGER, P_MSG VARCHAR2) IS
      V_MSG      RWS005_MSG;
   BEGIN
     V_MSG := RWS005_MSG(NULL,NULL);
     V_MSG.Codigo    := P_CODIGO;
     V_MSG.Descricao := P_MSG;
     P_Erros.extend;
     P_Erros(P_Erros.count) := V_MSG;
   END;

   procedure AddAviso(P_Codigo IN INTEGER, P_MSG VARCHAR2) IS
      V_MSG      RWS005_MSG;
   BEGIN
     V_MSG := RWS005_MSG(NULL,NULL);
     V_MSG.Codigo := P_CODIGO;
     V_MSG.Descricao := P_MSG;
     P_Avisos.extend;
     P_Avisos(P_Avisos.count) := V_MSG;
   END;

  procedure VerificaNivel(P_Nivel IN Integer) is
  begin
    IF V_Qbr.Count > 0 THEN
    FOR I IN 1 .. V_Qbr.Count LOOP
      FOR J IN 1 .. V_QbrAll.count LOOP
        IF  (V_QbrAll(J).Nivel = P_Nivel) and
            (V_QbrAll(J).Questao  = V_Qbr(I).CodigoPergunta) and
            (V_QbrAll(J).Resposta = 0) THEN
            -- Incluir Descricao da Pergunta no QBR que esta sendo analisado
            V_Qbr(I).DescrPergunta := V_QbrAll(J).Descricao;
            V_Qbr(I).Nivel         := V_QbrAll(J).Nivel;
            V_Qbr(I).MapaDados     := V_QbrAll(J).MapaDados;
            V_Qbr(I).Ordem         := V_QbrAll(J).Ordem;
            V_Qbr(I).Agrupamento   := V_QbrAll(J).Agrupamento;
            V_Qbr(I).Vigencia      := V_QbrAll(J).Vigencia;
        ELSIF  (V_QbrAll(J).Nivel = P_Nivel) and
            (V_QbrAll(J).Questao  = V_Qbr(I).CodigoPergunta) and
            (V_QbrAll(J).Resposta = V_Qbr(I).CodigoResposta) THEN
            -- Incluir Descricao da Resposta no QBR que esta sendo analisado
            if (V_QbrAll(J).Descricao2 is NOT NULL) then
               V_Qbr(I).DescrResposta := V_QbrAll(J).Descricao;
            else
               V_Qbr(I).DescrResposta := V_QbrAll(J).Descricao;
            end if;
            -- Incluir Descricao da Resposta no QBR que esta sendo analisado
            V_Qbr(I).CodigoSubPergunta := V_QbrAll(J).Questao2;
            -- Atualizar Tabela de verificacao do QBR
            for k in 1 .. V_QbrCheck.count loop
              if (V_QbrCheck(k).Questao = V_QbrAll(J).Questao) then
                 V_QbrCheck(k).Resposta   := V_QbrAll(J).Resposta;
                 V_QbrCheck(k).SubQuestao := V_QbrAll(J).Questao2;
                 exit;
              end if;
            end loop;
            -- Se existe sub pergunta para a resposta incluir a pergunta
            if (V_QbrAll(J).Questao2 > 0) then
               -- Verifica se a SubQuestao ja esta cadastrada na tabela de controle
               V_Found := FALSE;
               for k in 1 .. V_QbrCheck.count loop
                  IF (V_QbrCheck(k).Questao = V_QbrAll(J).Questao2) then
                     V_FOUND := TRUE;
                     exit;
                  END IF;
               END LOOP;
               -- Se SubQuestao nao encontrada, Incluir.
               if (NOT V_FOUND) THEN
                  V_Check.Questao      := V_QbrAll(J).Questao2;
                  V_Check.Nivel        := P_Nivel+1;
                  V_Check.Resposta     := 0;
                  V_Check.SubQuestao   := 0;
                  V_QbrCheck.extend;
                  V_QbrCheck(V_QbrCheck.count) := V_Check;
               END IF;
            end if;
        END IF;
      END LOOP;
    END LOOP;
    END IF;
  end;

begin
  -- Valida se a Lista existe.
  IF P_QbrCalculo IS NULL THEN
     AddErro(1200, 'QBR nao informado.');
     RETURN FALSE;
  END IF;

  -- Copia A lista para uma tabela interna.
  V_QBR      := TWS002_QBR();
  FOR I IN 1 .. P_QbrCalculo.Count LOOP
     V_QbrRec := RWS002_QBR(NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
     V_QbrRec.CodigoPergunta := P_QbrCalculo(I).Questao;
     V_QbrRec.CodigoResposta := P_QbrCalculo(I).Resposta;
     V_Qbr.Extend;
     V_Qbr(V_Qbr.Count) := V_QbrRec;
  END LOOP;
  -- Zera a Tabelas de Dados de Entrada e saida.
  P_QbrCalculo := TWS009_CALCULOQBR();

  V_CondutorSegurado := FALSE;
  V_QbrDpl   := TQbrDpl_TAB();

  IF V_QBR IS NOT NULL AND V_Qbr.Count > 0 THEN
  FOR i IN 1 .. V_Qbr.Count LOOP
    V_Found := False;
    FOR J IN 1 .. V_QbrDpl.Count LOOP
       IF ( V_Qbr(i).CodigoPergunta = V_QbrDpl(j).Questao) THEN
         V_QbrDpl(j).Conta := V_QbrDpl(j).Conta + 1;
         V_Found := True;
         exit;
       END IF;
    END LOOP;
    IF NOT V_Found THEN
      V_DplRec.Questao := V_Qbr(i).CodigoPergunta;
      V_DplRec.Conta   := 1;
      V_QbrDpl.extend;
      V_QbrDpl(V_QbrDpl.Count) := V_DplRec;
    END IF;
  END LOOP;
  END IF;

  FOR J IN 1 .. V_QbrDpl.Count LOOP
       IF ( V_QbrDpl(j).Conta> 1) THEN
         AddErro(1201, 'Codigo da Pergunta ' || To_Char(V_QbrDpl(j).Questao)
                      || ' foi informado mais de uma vez ('
                      || To_Char(V_QbrDpl(j).Conta) || ').');
       END IF;
  END LOOP;

  IF (P_Erros.count > 0) THEN
     RETURN FALSE;
  END IF;

  V_CEP :=fws009_iscep(P_Dados.XI_CEP);

  IF (V_CEP = 0) THEN
     AddErro(1202, 'CEP "' || P_Dados.XI_CEP || ' "invalido.');
     RETURN FALSE;
  END IF;

  V_Checked := TRUE;

  IF P_Dados.XI_CodigoProduto in (10, 42) THEN
     V_COBERTURA := 17; -- Auot e Auto Classico
  ELSIF P_Dados.XI_CodigoProduto = 24 THEN
     V_COBERTURA := 63; -- Carga
  ELSE
     V_COBERTURA := 0;
  END IF;


  -- Verifica Tipo de Veiculo
  SELECT COUNT(VALOR)
  INTO   V_CONTA
  FROM   MULT_PRODUTOSTABRG
  WHERE  PRODUTO = C_10
    AND  TABELA  = C_24
    AND  chave1  = P_Dados.XI_TipoVeiculo;

  IF (V_CONTA = 0) then
     V_Checked := FALSE;
     AddErro(1202,  'Tipo de Veiculo Invalido');
  end if;

  -- Obtem Regiao para respostas
  BEGIN
    SELECT T2.VALOR4 INTO V_REGIAO FROM MULT_PRODUTOSTABRG T1
    LEFT JOIN MULT_PRODUTOSTABRG T2
      ON T2.PRODUTO = P_Dados.XI_CodigoProduto
     AND T2.TABELA = C_25
     AND T2.valor5 = T1.VALOR
    WHERE T1.PRODUTO = P_Dados.XI_CodigoProduto
      AND T1.TABELA = C_50
      AND T1.chave1 = C_1
      AND P_Dados.W_DataVersao between T1.DT_INICO_VIGEN and T1.DT_FIM_VIGEN
      AND P_Dados.W_DataVersao between T2.DT_INICO_VIGEN and T2.DT_FIM_VIGEN
      AND T1.chave2 <= V_CEP
      AND T1.chave3 >= V_CEP
      AND ROWNUM = 1;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     V_Checked := FALSE;
     AddErro(1203,  'CEP Invalido');
  END;

  -- Busca o Codigo da Regiao
  BEGIN
     SELECT CHAVE1
     INTO   P_Dados.W_CodigoRegiao
     FROM   MULT_PRODUTOSTABRG T1
     WHERE  Tabela  = C_25
      AND   produto = C_10
      AND   VALOR4  = V_REGIAO
      AND   ROWNUM  = 1;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     P_Dados.W_CodigoRegiao := 0;
  END;

  -- Obtem Vigencia (1 - Corrente 2 - Anterior)
  V_VIGENCIA := FWS002_GetVigencia(P_Dados.XI_CodigoProduto, P_Dados.W_DataVersao);
  if (V_Vigencia  = 0) then
     V_Checked := FALSE;
     AddErro(1204,  'Data de Inicio de Vigencia invalida.');
  end if;

  -- Obtem Agrupamento
  BEGIN
    select agrupamento
    into   V_Agrupamento
    from   MULT_PRODUTOSQBRAGRUPREG
    where  produto   = P_Dados.XI_CodigoProduto
      and  vigencia  = V_VIGENCIA
      and  regiao    = V_REGIAO
      and  P_Dados.W_DataVersao between DT_INICO_VIGEN and DT_FIM_VIGEN;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     V_Checked := FALSE;
     AddErro(1205,  'Agrupamento nao encontrado.');
  END;

  -- Obtem Canal de Venda
  V_CanalVenda := FWS003_CanalVendas(P_Dados.XI_CodigoCorretor);

  BEGIN
    SELECT CODIGO, VERSAO, CD_TIPO_VEICU, CATEGVEIC
    INTO V_QbrId, V_Versao, V_Aux1, V_Aux2
    FROM MULT_PRODUTOSQBRGRUPOS T1
    WHERE  T1.PRODUTO    = P_Dados.XI_CodigoProduto
      AND  T1.VIGENCIA   = V_Vigencia
      AND  T1.CANALVENDA = V_CanalVenda
      AND  T1.TIPOPROD   = 'T' -- Constante
      AND  T1.TIPOPESSOA = P_Dados.XI_TipoPessoa
      AND  (
              (
                         (T1.CATEGVEIC = C_0 AND CD_TIPO_VEICU = C_0)
                     OR  (T1.CATEGVEIC = C_0 AND CD_TIPO_VEICU = P_Dados.XI_TipoVeiculo)
               ) OR (
                        (T1.CATEGVEIC = P_Dados.W_Agrupamento AND T1.CD_TIPO_VEICU = C_0)
                     OR (T1.CATEGVEIC = C_0 AND T1.CD_TIPO_VEICU = C_0)
               )
           )
      AND  T1.TIPOUSOVEIC = P_Dados.XI_TipoUsoVeiculo
      AND  P_Dados.W_DataVersao  BETWEEN T1.DT_INICO_VIGEN AND T1.DT_FIM_VIGEN
      AND  ROWNUM = 1
      order by CD_TIPO_VEICU, CATEGVEIC;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     V_Checked := FALSE;
     AddErro(1206,  'QBR nao encontrado.');
  END;

  IF (NOT V_Checked) then
     return FALSE;
  END IF;
  --
  P_Dados.W_QbrCodigo := V_QbrId;
  --
  -- Seleciona Perguntas e Resposta do QBR Nivel 1, 2 e 3

  SELECT T9.NIVEL AS NIVEL,
         T9.Usado AS Usado,
         T9.QUESTAO AS Questao,
         T9. RESPOSTA AS Resposta,
         T9.ORDEM  AS Ordem,
         T9.Q2 AS Questao2,
         T9.DESCRICAO   AS Descricao,
         T9.DESCRICAO2  AS Descricao2,
         T9.MAPADADOS   AS MapaDados,
         T9.Agrupamento AS Agrupamento,
         T9.Vigencia    AS Vigencia
  BULK COLLECT INTO V_QbrAll
  FROM
  (

        -- Seleciona Perguntas QBR Nivel 1
  SELECT   C_1 as nivel,
    T1.QUESTAO AS QUESTAO,
    C_0 AS Usado,
    C_0 AS RESPOSTA,
    T1.ORDEM AS ORDEM,
    C_0 AS Q2,
    T2.DESCRICAO AS DESCRICAO,
    V_VAZIO AS DESCRICAO2,
    T1.MapaDados  AS MapaDados,
    V_Agrupamento AS Agrupamento,
    V_VIGENCIA    AS Vigencia
  FROM MULT_PRODUTOSQBRNIVEL1 T1
  LEFT JOIN MULT_PRODUTOSQBRQUESTOES  T2
  ON    T2.PRODUTO   = T1.PRODUTO
    AND T2.QUESTAO   = T1.QUESTAO
    AND T2.VIGENCIA  = T1.VIGENCIA
    AND T2.COBERTURA = V_COBERTURA
  WHERE T1.PRODUTO   = P_Dados.XI_CodigoProduto
    AND T1.VIGENCIA  = V_VIGENCIA
    AND T1.VERSAO    = V_VERSAO
    AND T1.CODIGO    = V_QBRID
    AND P_Dados.W_DataVersao  BETWEEN T2.DT_INICO_VIGEN AND T2.DT_FIM_VIGEN
  UNION
        -- Seleciona Respostas do QBR Nivel 1
  SELECT   C_1 as nivel,
    T1.QUESTAO AS QUESTAO,
    C_0 AS Usado,
    T2.RESPOSTA AS RESPOSTA,
    T1.ORDEM AS ORDEM,
    C_0 AS Q2,
    T2.DESCRICAO  AS DESCRICAO,
    T2.DESCRICAO2 AS DESCRICAO2,
    T1.MapaDados  AS MapaDados,
    V_Agrupamento AS Agrupamento,
    V_VIGENCIA    AS Vigencia
  FROM MULT_PRODUTOSQBRNIVEL1 T1
  LEFT JOIN MULT_PRODUTOSQBRRESPOSTAS  T2
  ON    --T2.PRODUTO     = T1.PRODUTO AND
    T2.QUESTAO     = T1.QUESTAO
    AND T2.VIGENCIA    = T1.VIGENCIA
    AND T2.COBERTURA   = V_COBERTURA
    AND T2.AGRUPAMENTO = V_AGRUPAMENTO
    AND T2.MOSTRA      = C_1
  WHERE T1.PRODUTO  = P_Dados.XI_CodigoProduto
    AND T1.VIGENCIA = V_VIGENCIA
    AND T1.VERSAO   = V_VERSAO
    AND T1.CODIGO   = V_QBRID
    AND P_Dados.W_DataVersao  BETWEEN T2.DT_INICO_VIGEN AND T2.DT_FIM_VIGEN

  UNION

        -- Seleciona Perguntas QBR Nivel 2
  SELECT   C_2 as nivel,
    QUESTAONIVEL2 AS QUESTAO,
    C_0 AS Usado,
    C_0 AS RESPOSTA,
    C_0 AS ordem,
    C_0 AS Q2,
    T2.DESCRICAO AS DESCRICAO,
    V_VAZIO AS DESCRICAO2,
    T1.MapaDados  AS MapaDados,
    V_Agrupamento AS Agrupamento,
    V_VIGENCIA    AS Vigencia
  FROM MULT_PRODUTOSQBRNIVEL2 T1
  LEFT JOIN MULT_PRODUTOSQBRQUESTOES  T2
  ON    T2.PRODUTO   = T1.PRODUTO
    AND T2.QUESTAO   = T1.QUESTAONIVEL2
    AND T2.VIGENCIA  = T1.VIGENCIA
    AND T2.COBERTURA = V_COBERTURA
  WHERE T1.PRODUTO   = P_Dados.XI_CodigoProduto
    AND T1.VIGENCIA  = V_VIGENCIA
    AND T1.VERSAO    = V_VERSAO
    AND T1.CODIGO    = V_QBRID
    AND P_Dados.W_DataVersao  BETWEEN T2.DT_INICO_VIGEN AND T2.DT_FIM_VIGEN

  UNION

        -- Seleciona Respostas do QBR Nivel 2
  SELECT   C_2 as nivel,
    QUESTAONIVEL2 AS QUESTAO,
    C_0 AS Usado,
    T2.RESPOSTA AS RESPOSTA,
    C_0 AS ordem,
    C_0 AS Q2,
    T2.DESCRICAO  AS DESCRICAO,
    T2.DESCRICAO2 AS DESCRICAO2,
    T1.MapaDados  AS MapaDados,
    V_Agrupamento AS Agrupamento,
    V_VIGENCIA    AS Vigencia
  FROM MULT_PRODUTOSQBRNIVEL2 T1
  LEFT JOIN MULT_PRODUTOSQBRRESPOSTAS  T2
  ON    --T2.PRODUTO     = T1.PRODUTO AND
    T2.QUESTAO     = T1.QUESTAONIVEL2
    AND T2.VIGENCIA    = T1.VIGENCIA
    AND T2.COBERTURA   = V_COBERTURA
    AND T2.AGRUPAMENTO = V_AGRUPAMENTO
    AND T2.MOSTRA      = C_1
  WHERE T1.PRODUTO   = P_Dados.XI_CodigoProduto
    AND T1.VIGENCIA  = V_VIGENCIA
    AND T1.VERSAO    = V_VERSAO
    AND T1.CODIGO    = V_QBRID
    AND P_Dados.W_DataVersao  BETWEEN T2.DT_INICO_VIGEN AND T2.DT_FIM_VIGEN

  UNION

        -- Seleciona Perguntas QBR Nivel 3
  SELECT   distinct C_3 as nivel,
    QUESTAONIVEL3 AS QUESTAO,
    C_0 AS Usado,
    C_0 AS RESPOSTA,
    C_0 AS ordem, C_0 AS Q2,
    T2.DESCRICAO AS DESCRICAO,
    V_VAZIO AS DESCRICAO2,
    T1.MapaDados  AS MapaDados,
    V_Agrupamento AS Agrupamento,
    V_VIGENCIA    AS Vigencia
  FROM MULT_PRODUTOSQBRNIVEL3 T1
  LEFT JOIN MULT_PRODUTOSQBRQUESTOES  T2
  ON    T2.PRODUTO   = T1.PRODUTO
    AND T2.QUESTAO   = T1.QUESTAONIVEL3
    AND T2.VIGENCIA  = T1.VIGENCIA
    AND T2.COBERTURA = V_COBERTURA
  WHERE T1.PRODUTO   = P_Dados.XI_CodigoProduto
    AND T1.VIGENCIA  = V_VIGENCIA
    AND T1.VERSAO    = V_VERSAO
    AND T1.CODIGO    = V_QBRID
    AND P_Dados.W_DataVersao  BETWEEN T2.DT_INICO_VIGEN AND T2.DT_FIM_VIGEN

  UNION

        -- Seleciona Respostas do QBR Nivel 3
  SELECT   distinct C_3 as nivel,
    QUESTAONIVEL3 AS QUESTAO,
    C_0 AS Usado,
    T2.RESPOSTA AS RESPOSTA,
    C_0 AS ordem, C_0 AS Q2,
    T2.DESCRICAO  AS DESCRICAO,
    T2.DESCRICAO2 AS DESCRICAO2,
    T1.MapaDados  AS MapaDados,
    V_Agrupamento AS Agrupamento,
    V_VIGENCIA    AS Vigencia
  FROM MULT_PRODUTOSQBRNIVEL3 T1
  LEFT JOIN MULT_PRODUTOSQBRRESPOSTAS  T2
  ON    --T2.PRODUTO     = T1.PRODUTO AND
    T2.QUESTAO     = T1.QUESTAONIVEL3
    AND T2.VIGENCIA    = T1.VIGENCIA
    AND T2.COBERTURA   = V_COBERTURA
    AND T2.AGRUPAMENTO = V_AGRUPAMENTO
    AND T2.MOSTRA      = C_1
  WHERE T1.PRODUTO     = P_Dados.XI_CodigoProduto
    AND T1.VIGENCIA    = V_VIGENCIA
    AND T1.VERSAO      = V_VERSAO
    AND T1.CODIGO      = V_QBRID
    AND P_Dados.W_DataVersao   BETWEEN T2.DT_INICO_VIGEN AND T2.DT_FIM_VIGEN
  ORDER BY nivel, ordem, questao, resposta
  ) T9;

  -- Verifica se existem perguntas nivel 2
  V_Count := 0;
  FOR i IN 1 .. V_QbrAll.COUNT LOOP
    IF (V_QbrAll(i).NIVEL = 2) THEN
       V_Count := 1;
    END IF;
  END LOOP;


  if (V_COUNT > 0 ) then

    -- Verificando Resposta X Pergunta Nivel 2
    BEGIN
      SELECT T9.RESPOSTA, T9.QUESTAO
      BULK COLLECT INTO V_QBR20
      FROM (  SELECT
           RESPOSTANIVEL1 AS Resposta,
        QUESTAONIVEL2  AS Questao
        FROM MULT_PRODUTOSQBRNIVEL2
        WHERE PRODUTO  = P_Dados.XI_CodigoProduto
          AND QUESTAONIVEL2  > C_0
          AND VIGENCIA = V_VIGENCIA
          AND VERSAO   = V_VERSAO
          AND CODIGO   = V_QBRID
           ) T9;

      FOR i IN 1 .. V_QBR20.COUNT LOOP
        FOR j IN 1 .. V_QbrAll.COUNT LOOP
          IF ((V_QbrAll(j).NIVEL = 1) and (V_QbrAll(j).RESPOSTA = V_QBR20(i).RESPOSTA)) THEN
             V_QbrAll(j).QUESTAO2 := V_QBR20(i).QUESTAO;
          END IF;
        END LOOP;
      END LOOP;


      -- Verifica se existem perguntas nivel 3
      V_Count := 0;
      FOR i IN 1 .. V_QbrAll.COUNT LOOP
        IF (V_QbrAll(i).NIVEL = 3) THEN
           V_Count := 1;
        END IF;
      END LOOP;


      if (V_COUNT > 0 ) then

        -- Verificando Resposta X Pergunta Nivel 3
        BEGIN

          SELECT T9.RESPOSTA, T9.QUESTAO
          BULK COLLECT INTO V_QBR30
          FROM (  SELECT RESPOSTANIVEL2 AS resposta,
                         QUESTAONIVEL3 AS QUESTAO
                  FROM MULT_PRODUTOSQBRNIVEL3
                  WHERE PRODUTO  = P_Dados.XI_CodigoProduto
                    AND QUESTAONIVEL3  > 0
                    AND VIGENCIA = V_VIGENCIA
                    AND VERSAO   = V_VERSAO
                    AND CODIGO   = V_QBRID
               ) T9;

          FOR i IN 1 .. V_QBR30.COUNT LOOP
            FOR j IN 1 .. V_QbrAll.COUNT LOOP
              IF ((V_QbrAll(j).NIVEL = 2) and (V_QbrAll(j).RESPOSTA = V_QBR30(i).RESPOSTA)) THEN
                V_QbrAll(j).QUESTAO2 := V_QBR30(i).QUESTAO;
              END IF;
            END LOOP;
          END LOOP;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
          AddErro(1207,  'QBR Nivel 3 nao encontrado.');
          RETURN FALSE;
        END;
      END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
      AddErro(1208,  'QBR Nivel 2 nao encontrado.');
      RETURN FALSE;
    END;
  END IF;

  V_QbrCheck := TQBRCheck_TAB();

  -- Pesquisa em toda a lista
  FOR I IN 1 .. V_QbrAll.count LOOP
    IF (V_QbrAll(i).Resposta = 0) and (V_QbrAll(I).Nivel = 1) and (V_QbrAll(I).QUESTAO <> 87)  THEN
      V_Check.Questao      := V_QbrAll(I).QUESTAO;
      V_Check.Nivel        := 1;
      V_Check.Resposta     := 0;
      V_Check.SubQuestao   := 0;
      V_QbrCheck.extend;
      V_QbrCheck(V_QbrCheck.count) := V_Check;
    END IF;
  END LOOP;

  VerificaNivel(1);
  VerificaNivel(2);
  VerificaNivel(3);

  V_Checked  := TRUE;

  -- Verifica se todas as perguntas do QBR foram respondidas
  for i in 1 .. V_QbrCheck.count loop
    if (V_QbrCheck(i).Resposta = 0) then
       V_Checked := False;
       AddErro(1209,  'Questao (' || TO_CHAR(V_QbrCheck(i).Questao) || ') nao respondida!');
    end if;
  end loop;

  -- Verifica todas as Questoes e Resposta do Qbr em analise
  V_TemQbr250 := FALSE;
  IF V_Qbr IS NOT NULL AND V_Qbr.Count > 0 THEN
     FOR I IN 1 .. V_Qbr.Count LOOP
      -- Verifica se o segurado e o proprio condutor
      IF (V_Qbr(i).CodigoPergunta = C_250) THEN
         V_CondutorSegurado := V_Qbr(i).CodigoResposta = C_662;
         V_TemQbr250        := TRUE;
      END IF;
      -- Se nao ha descricao de pergunta
      if (V_Qbr(i).DescrPergunta IS NULL) then
         FOR J IN 1 .. V_QbrCheck.Count LOOP
           IF (V_QbrCheck(j).Questao = V_Qbr(i).CodigoPergunta) THEN
              -- Pergunta nao encontrada no Qbr
              V_Checked := False;
              AddErro(1210,  'Questao (' || TO_CHAR(V_Qbr(i).CodigoPergunta) || ') nao pertence ao QBR!');
           END IF;
         END LOOP;
      END IF;
      -- Se nao ha descricao da resposta
      if (V_Qbr(i).DescrResposta IS NULL) then
         FOR J IN 1 .. V_QbrCheck.Count LOOP
           IF (V_QbrCheck(j).Questao = V_Qbr(i).CodigoPergunta) THEN
              -- Resposta nao pertence a pergunta
              V_Checked := False;
              AddErro(1211,  'Codigo da Resposta (' || TO_CHAR(V_Qbr(i).CodigoResposta)
                             || ') nao pertence a Questao (' || TO_CHAR(V_Qbr(i).CodigoPergunta)
                             || ')!');
           END IF;
         END LOOP;
      END IF;
    END LOOP;
  END IF;

  -- Incluir Mapa de Dados nas perguntas do nivel 1
  FOR I IN 1 .. V_QbrAll.Count LOOP
     IF (V_QbrAll(I).MapaDados IS NOT NULL) THEN
         FOR J IN 1 .. V_QbrAll.Count LOOP
            IF (V_QbrAll(I).Questao = V_QbrAll(J).Questao2) THEN
               FOR k IN 1 .. V_Qbr.Count LOOP
                  IF (V_QbrAll(J).Questao = V_Qbr(K).CodigoPergunta) THEN
                     V_Qbr(K).MapaDados := V_QbrAll(i).MapaDados;
                  END IF;
               END LOOP;
            END IF;
         END LOOP;
     END IF;
  END LOOP;

  IF V_Checked THEN
     -- Se a Questao 205 Existe
     IF V_TemQbr250 THEN
        -- Se Tag <flagCondutorSegurado> nao exitse
        IF (P_Dados.XI_CondutorSegurado IS NULL) THEN
           IF V_CondutorSegurado THEN
              P_Dados.XI_CondutorSegurado := 'S';
           ELSE
              P_Dados.XI_CondutorSegurado := 'N';
           END IF;
        END IF;
        ----------------------------------------------------------------------------------------
        -- Gambiarra do Edimilson
        -- Fazer igual ao WS da Sistema que nao valida
        -- Usar a resposta do QBR
        ----------------------------------------------------------------------------------------
        IF (V_CondutorSegurado AND (P_Dados.XI_CondutorSegurado = 'N')) THEN
           P_Dados.XI_CondutorSegurado := 'S';
           /*
           V_Checked := False;
           AddErro(1212,  'A resposta (662) da questao (250) diverge do valor "N" da TAG <flagCondutorSegurado>!');
           */
        ELSIF ( (NOT V_CondutorSegurado) AND (P_Dados.XI_CondutorSegurado = 'S')) THEN
           P_Dados.XI_CondutorSegurado := 'N';
           /*
           V_Checked := False;
           AddErro(1213, 'A resposta (663) da questao (250) diverge do valor "S" da TAG <flagCondutorSegurado>!');
           */
       END IF;
     ELSE
       -- Se Tag <flagCondutorSegurado> nao exitse
       IF (P_Dados.XI_CondutorSegurado IS NULL) THEN
           -- Se for Empresa Con
           IF (P_Dados.XI_TipoPessoa = 'J') THEN
              P_Dados.XI_CondutorSegurado := 'N';
           ELSE
              P_Dados.XI_CondutorSegurado := 'S';
           END IF;
       END IF;
     END IF;
     IF (P_Dados.XI_TipoPessoa = 'J') AND (P_Dados.XI_CondutorSegurado = 'S') THEN
        V_Checked := False;
        AddErro(1214, 'Para empresas e necessario informar o condutor!');
     END IF;
  END IF;

  -- VALIDA Dispositivos de Rastreamento
  V_VeiculoRanking     := 0;
  V_NomeDispositivo    := '';
  V_NomeGerenciadora   := '';
  IF V_Checked  THEN
     IF (P_Dados.XI_Dispositivo = 'S') THEN
        V_Checked := fws014_CheckDispositivo( P_Dados.XI_CodigoProduto,
                                              V_Vigencia,
                                              P_Dados.W_DataVersao,
                                              P_Dados.XI_CodigoDispositivo,
                                              P_Dados.XI_CodigoGerenciadora,
                                              V_VeiculoRanking,
                                              V_NomeDispositivo,
                                              V_NomeGerenciadora,
                                              P_Erros
                                            );
    END IF;
  END IF;


  V_CodComodato  := NULL;
  V_RespComodato := 0;

  -- Validar necessidade de Dispositivo de Rastreamento
  IF V_Checked  THEN
     V_TemComodato := FALSE;
     BEGIN
        SELECT T2.Ranking, T3.DESCRICAO, T1.Codcomodato, t1.respcomodato
        INTO   V_ComodatoRanking, V_NomeComodato, V_CodComodato, V_RespComodato
        FROM   mult_produtosqbrofertacomodato T1
        INNER  JOIN Mult_Produtosqbrtiposdisp T2
           ON  T2.Tipo = T1.TIPODISP
        INNER  JOIN MULT_PRODUTOSQBRDISPSEG T3
           ON  T3.DISPOSITIVO = T1.CODCOMODATO
        WHERE  T1.PRODUTO     = P_Dados.XI_CodigoProduto
          AND  T1.QUESTAO     = C_243
          AND  T1.AGRUPVEIC   = V_AGRUPAMENTO
          AND  T1.AGRUPREGIAO = P_Dados.XI_ANOMODELO
          AND  P_Dados.W_DataVersao BETWEEN T1.DT_INICO_VIGEN AND T1.DT_FIM_VIGEN;
       V_TemComodato := TRUE;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         V_TemComodato := FALSE;
     END;
     -- Se veiculo requer dispositivo de ratreamento
     IF V_TemComodato THEN
        V_MsgComodato := 'O cálculo do seguro será efetuado considerando a aceitação do'
                         || ' dispositivo de segurança ' || V_NomeComodato
                         || ' em comodato. Sem essa condição o seguro não será aceito'
                         || ' pela Tokio Marine Seguradora.';
        -- Se Segurado nao possui informar a necessidade;
        IF P_Dados.XI_Dispositivo = 'N' THEN
           AddAviso(12001, V_MsgComodato);
        ELSE
           IF V_VeiculoRanking < V_ComodatoRanking THEN
              AddAviso(12002, V_MsgComodato);
           END IF;
        END IF;
     END IF;
  END IF;

  IF  NOT V_Checked THEN
      RETURN FALSE;
  END IF;

  V_Last     := 0;
  V_CalcQbr  := RWS009_CALCULOQBR(
                          NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                          NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                          NULL);

  -- Inclui Todas as Perguntas do QBR
  FOR I IN 1 .. V_QbrAll.Count LOOP
     IF (V_QbrAll(I).NIVEL = 1) and (V_QbrAll(I).Resposta = 0) THEN
         IF V_QbrAll(I).Ordem > V_Last THEN
            V_Last := V_QbrAll(I).Ordem;
         END IF;
         V_CalcQbr.Questao      := V_QbrAll(I).Questao;
         V_CalcQbr.Ordem        := V_QbrAll(I).Ordem * 1000000;
         V_CalcQbr.Descricao    := V_QbrAll(I).Descricao;
         V_CalcQbr.Valida       := 'N';
         V_CalcQbr.Vigencia     := V_Vigencia;
         V_CalcQbr.Agrupamento  := V_Agrupamento;
         V_CalcQbr.Grupo        := V_QBRID;
         V_CalcQbr.SubResposta  := NULL;
         V_CalcQbr.SubResposta2 := NULL;
         V_CalcQbr.Impressao    := 0;
         IF V_QbrAll(I).Questao = 87 THEN
            V_CalcQbr.Valida    := 'S';
            IF P_Dados.XI_TipoSeguro in (4,5) THEN
               V_CalcQbr.Resposta           := 191;
               V_CalcQbr.DescricaoResposta  := 'Sim';
            ELSE
               V_CalcQbr.Resposta           := 192;
               V_CalcQbr.DescricaoResposta  := 'Não';
            END IF;
         ELSE
            V_CalcQbr.Resposta           := 0;
            V_CalcQbr.DescricaoResposta  := '';
         END IF;
         P_QbrCalculo.Extend;
         P_QbrCalculo(P_QbrCalculo.Count) := V_CalcQbr;
     END IF;
  END LOOP;

  -- Buscando Resposta do Nivel 1
  FOR I IN 1 .. P_QbrCalculo.Count LOOP
    FOR J IN 1 .. V_QBR.Count LOOP
       IF (P_QbrCalculo(I).Questao = V_QBR(j).CodigoPergunta) THEN
          P_QbrCalculo(I).Resposta            := V_QBR(j).CodigoResposta;
          P_QbrCalculo(I).MapaDados           := V_QBR(j).MapaDados;
          P_QbrCalculo(I).DescricaoResposta   := V_QBR(j).DescrResposta;
          P_QbrCalculo(I).SubQuestao          := V_QBR(j).CodigoSubPergunta;
          P_QbrCalculo(I).Valida              := 'S';
       END IF;
    END LOOP;
  END LOOP;

  -- Buscando Resposta do Nivel 2
  FOR I IN 1 .. P_QbrCalculo.Count LOOP
    IF P_QbrCalculo(I).SubQuestao > 0 THEN
       FOR J IN 1 .. V_QBR.Count LOOP
          IF (P_QbrCalculo(I).SubQuestao = V_QBR(j).CodigoPergunta) THEN
             P_QbrCalculo(I).SubResposta          := V_QBR(j).CodigoResposta;
             P_QbrCalculo(I).DescricaoSubResposta := V_QBR(j).DescrResposta;
             P_QbrCalculo(I).SubQuestao2          := V_QBR(j).CodigoSubPergunta;
          END IF;
       END LOOP;
    END IF;
  END LOOP;

  -- Buscando Resposta do Nivel 3
  FOR I IN 1 .. P_QbrCalculo.Count LOOP
    IF P_QbrCalculo(I).SubQuestao2 > 0 THEN
       FOR J IN 1 .. V_QBR.Count LOOP
          IF (P_QbrCalculo(I).SubQuestao2 = V_QBR(j).CodigoPergunta) THEN
             P_QbrCalculo(I).SubResposta2          := V_QBR(j).CodigoResposta;
             P_QbrCalculo(I).DescricaoSubResposta2 := V_QBR(j).DescrResposta;
          END IF;
       END LOOP;
    END IF;
  END LOOP;

  -- Incluir a Pergunta 243 Referente a Dispositivos
  V_CalcQbr.Questao            := 243;
  V_CalcQbr.Ordem              := 0;
  V_CalcQbr.Descricao          := 'O veículo possui dispositivo de segurança?';
  V_CalcQbr.Valida             := 'S';
  V_CalcQbr.Vigencia           := V_Vigencia;
  V_CalcQbr.Agrupamento        := V_Agrupamento;
  V_CalcQbr.Grupo              := V_QBRID;
  V_CalcQbr.MapaDados          := '';
  V_CalcQbr.Resposta2          := V_RespComodato;
  V_CalcQbr.DescricaoResposta2 := V_CodComodato;
  V_CalcQbr.Impressao          := 0;


  IF (P_Dados.XI_Dispositivo = 'S') THEN
     V_CalcQbr.Resposta              := 586;
     V_CalcQbr.DescricaoResposta     := 'B. Dispositivo Próprio';
     V_CalcQbr.SubResposta           := P_Dados.XI_CodigoDispositivo;
     V_CalcQbr.DescricaoSubResposta  := V_NomeDispositivo;
     V_CalcQbr.SubResposta2          := P_Dados.XI_CodigoGerenciadora;
     V_CalcQbr.DescricaoSubResposta2 := V_NomeGerenciadora;
  ELSE
     V_CalcQbr.Resposta := 582;
     V_CalcQbr.DescricaoResposta  := 'A. Não Possui';
     V_CalcQbr.SubResposta           := 0;
     V_CalcQbr.DescricaoSubResposta  := NULL;
     V_CalcQbr.SubResposta2          := 0;
     V_CalcQbr.DescricaoSubResposta2 := NULL;
  END IF;
  P_QbrCalculo.Extend;
  P_QbrCalculo(P_QbrCalculo.Count) := V_CalcQbr;

  RETURN  TRUE;

END;
/


CREATE OR REPLACE function fws013_CheckVeiculo(
       P_Veiculo         IN  Integer,
       P_Fabricante      IN  Integer,
       P_Combustivel     IN  VARCHAR2,
       P_ZeroKm          IN  VARCHAR2,
       P_AnoModelo       IN  Integer,
       P_AnoFabrica      IN  Integer,
       P_DtIniVigencia   IN  DATE,
       P_CodigoCobertura IN  Integer, -- Se 3 RCF-V Nao valida Valor
       P_Valor           OUT Number,
       P_Categoria       OUT Integer,
       P_Erros           IN OUT TWS001_MSGS
) return Boolean
is
   V_F           VarChar2(1) := 'F';
   V_Conta       Integer;
   V_Fabricante  Integer;
   V_Categoria   Integer;
   V_Combustivel VarChar2(1);
   V_ValorMedio  Real_CotasAuto.Valor_Medio%type;

  procedure AddErro(P_Codigo IN INTEGER, P_MSG VARCHAR2) IS
      V_MSG      RWS005_MSG;
   BEGIN
     V_MSG := RWS005_MSG(NULL,NULL);
     V_MSG.Codigo    := P_CODIGO;
     V_MSG.Descricao := P_MSG;
     P_Erros.extend;
     P_Erros(P_Erros.count) := V_MSG;
   END;

begin
  begin
      SELECT Fabricante, Tipo_Combustivel, Categ_Tar1
      into V_Fabricante, V_Combustivel, V_Categoria
      from tabela_veiculomodelo
      where MODELO = P_Veiculo;
    exception
        WHEN NO_DATA_FOUND THEN
        BEGIN
           AddErro(1301, 'Codigo de Veiculo ' || to_char(P_Veiculo) || ' invalido.' );
           return FALSE;
        END;
  end;

  if (V_Fabricante <> P_Fabricante) then
     AddErro(1302, 'Codigo do Fabricante ' || to_char(P_Fabricante) || ' nao pertence a este modelo.' );
     return FALSE;
  end if;

  if (V_Combustivel <> P_Combustivel) then
     AddErro(1303, 'Tipo de Combustivel ' || P_Combustivel || ' invalido.' );
     return FALSE;
  end if;

  if (P_AnoFabrica > P_AnoModelo) then
     AddErro(1304, 'Ano Modelo ' || To_Char(P_AnoModelo) ||
                   ' deve maior ou igual ao Ano de Fabricacao ' || To_Char(P_AnoFabrica) );
     return FALSE;
  end if;

  select Count(T1.Modelo) INTO V_Conta
  FROM  Tabela_VeiculoModelo T1
  INNER JOIN REAL_ANOSAUTO T2
      ON T2.MODELO =  T1.Modelo
     And T2.ANOATE >= P_AnoModelo
     And T2.ANODE  <= P_AnoFabrica
  where T1.modelo = P_Veiculo;

  IF (V_Conta = 0) or (V_Conta is NULL) then
     AddErro(1305, 'Codigo de Veiculo ' || to_char(P_Veiculo) ||
                   ' nao foi fabricado no ano  ' || To_Char(P_AnoFabrica) ||
                   ' ou no ano modelo ' || To_Char(P_AnoModelo) || '.');
     return FALSE;
  end if;

  BEGIN
    SELECT T2.valor_medio
    INTO  V_ValorMedio
    FROM  Real_CotasAuto  T2
    where  T2.TIPO_TABELA = V_F
      AND  T2.COD_MODELO  = P_Veiculo
      AND  T2.COD_FABRIC  = P_Fabricante
      AND  T2.ANO_MODELO  = P_AnoModelo
      AND  T2.IC_ZERO_KM  = P_ZeroKm
      AND  T2.combustivel = P_Combustivel
      AND  P_DtIniVigencia BETWEEN T2.dt_inico_vigen AND T2.dt_fim_vigen;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     -- Se Cobertura for diferente de RCF-V
     IF (P_CodigoCobertura <> 3 ) THEN
        AddErro(1306, 'Para o Codigo de Veiculo ' || to_char(P_Veiculo) ||
                      ' nao foi encontrado o valor de mercado.'
                      || V_F || ' '
                      || To_Char(P_Veiculo) || ' '
                      || To_Char(P_Fabricante) || ' '
                      || To_Char(P_AnoModelo) || ' '
                      || P_ZeroKm || ' '
                      || P_Combustivel || ' '
                      || To_Char(P_DtIniVigencia, 'DD/MM/YYYY') || ' '
                      );
        RETURN FALSE;
     ELSE
        V_ValorMedio := 0;
     END IF;
  END;

  P_Valor     := NVL(V_ValorMedio, 0);
  P_Categoria := V_Categoria;

  -- Se Cobertura for diferente de RCF-V e Valor for Zero
  IF (P_CodigoCobertura <> 3 ) AND (P_VALOR = 0) THEN
     AddErro(1306, 'Valor FIPE para o codigo de Veiculo ' || to_char(P_Veiculo) ||
                   ' fabricado no ano  ' || To_Char(P_AnoFabrica) ||
                   ' ano modelo ' || To_Char(P_AnoModelo) ||
                   ' nao encontrado.');
     RETURN FALSE;
  END IF;

  RETURN TRUE;

end;
/


CREATE OR REPLACE function fws014_CheckDispositivo(
     P_Produto        in Integer,
     P_Vigencia       in Integer,
     P_DtIniVigencia  in Date,
     P_Dispositivo    in Integer,
     P_Gerenciadora   in Integer,
     P_DispRanking    IN OUT Integer,
     P_NomeDipositivo IN OUT VARCHAR2,
     P_NomeGerencia   IN OUT VARCHAR2,
     P_Erros          in out TWS001_MSGS
) return Boolean
is

  V_Conta Integer;
  V_HasGerenciadora INTEGER;
  V_Descricao       MULT_PRODUTOSQBRDISPSEG.Descricao%type;
  V_Gerenciadora    MULT_PRODUTOSQBRGERENCIADORAS.Descricao%type;

   procedure AddErro(P_Codigo IN INTEGER, P_MSG VARCHAR2) IS
      V_MSG      RWS005_MSG;
   BEGIN
     V_MSG := RWS005_MSG(NULL,NULL);
     V_MSG.Codigo    := P_CODIGO;
     V_MSG.Descricao := P_MSG;
     P_Erros.extend;
     P_Erros(P_Erros.count) := V_MSG;
   END;
begin
  P_NomeDipositivo := NULL;
  P_NomeGerencia   := NULL;
  P_DispRanking    := 0;
  IF (P_Dispositivo = 0) THEN
     AddErro(1401, 'Dispositivo de seguranca nao informado.');
     RETURN FALSE;
  END IF;
  -- Lista Dipositivos Aceitos
  BEGIN
      SELECT 	T1.indgerenciadora, T2.Ranking, T2.Descricao
      INTO    V_HasGerenciadora, P_DispRanking, V_Descricao
	    FROM MULT_PRODUTOSQBRDISPSEG T1
        INNER  JOIN Mult_Produtosqbrtiposdisp T2
           ON  T2.Tipo = T1.TIPO
	    WHERE T1.Dispositivo = P_Dispositivo
        and T1.PRODUTO     = P_PRODUTO
        AND T1.VIGENCIA    = P_VIGENCIA
        AND P_DtIniVigencia  BETWEEN T1.DT_INICO_VIGEN AND T1.DT_FIM_VIGEN;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      AddErro(1402, 'Dispositivos de seguranca ' || To_Char(P_Dispositivo) || ' nao encontrado.');
      RETURN FALSE;
  END;

  IF (V_HasGerenciadora = 0) AND ((P_Gerenciadora <> 0)) THEN
       AddErro(1403, 'Para o Dispositivo ' || TO_Char(P_Dispositivo) || ' nao e necessario informar a Gerenciadora de risco.');
       RETURN FALSE;
  END IF;

  IF (V_HasGerenciadora <> 0) THEN
    IF (P_Gerenciadora = 0) THEN
       AddErro(1404, 'Para o Dispositivo ' || TO_Char(P_Dispositivo) || ' e necessario informar a Gerenciadora de risco.');
       RETURN FALSE;
    END IF;
	  SELECT 	Count(*)
    INTO    V_Conta
	  FROM MULT_PRODUTOSQBRGERENCIADORAS
	  WHERE Gerenciadora = P_Gerenciadora
      AND PRODUTO      = P_PRODUTO
      AND VIGENCIA     = P_VIGENCIA
      AND P_DtIniVigencia  BETWEEN DT_INICO_VIGEN AND DT_FIM_VIGEN;
    IF (V_Conta = 0) THEN
         AddErro(1405, 'Gerenciadoras de risco ' || To_Char(P_Gerenciadora) || ' nao encontrada.');
         RETURN FALSE;
    END IF;
	  SELECT 	Descricao
    INTO    V_Gerenciadora
	  FROM MULT_PRODUTOSQBRGERENCIADORAS
	  WHERE Gerenciadora = P_Gerenciadora
      AND PRODUTO      = P_PRODUTO
      AND VIGENCIA     = P_VIGENCIA
      AND P_DtIniVigencia  BETWEEN DT_INICO_VIGEN AND DT_FIM_VIGEN;
  ELSE
    V_Gerenciadora := '';
  END IF;

  P_NomeDipositivo := V_Descricao;
  P_NomeGerencia   := V_Gerenciadora;

  RETURN TRUE;

end;
/


CREATE OR REPLACE function fws015_CheckCobAdicionais(
     P_Produto         IN Integer,
     P_CobAdcional     IN TWS003_COBAD,
     P_CodigoCobertura IN Integer,
     P_TipoAssistencia IN VARCHAR2,
     P_Erros           IN OUT TWS001_MSGS
) return Boolean
is
  type TCobDpl_Rec     IS Record (  Cobertura Mult_ProdutosCobPer.cobertura%type,
                                    Conta Integer
                                 );


  type TCobChk_REC     IS record (  Cobertura Mult_ProdutosCobPer.cobertura%type,
                                    Opcao     Mult_ProdutosCobPerOpc.Opcao%type,
                                    CobFound  Integer,
                                    CobDescr  Mult_ProdutosCobPer.Descricao%type,
                                    OpcDescr  Mult_ProdutosCobPer.Descricao%type
                                  );
  type TCobPer_REC     is record (  cobertura Mult_ProdutosCobPer.cobertura%type,
                                    descricao Mult_ProdutosCobPer.Descricao%type);
  type TCobPerOpc_REC  is record (  cobertura Mult_ProdutosCobPer.cobertura%type,
                                    opcao     Mult_ProdutosCobPerOpc.Opcao%type,
                                    descricao Mult_ProdutosCobPer.Descricao%type);

  type TCobDpl_TAB     is table of TCobDpl_Rec;
  type TCobChk_TAB     is table of TCobChk_REC;
  type TCobPer_TAB     is table of TCobPer_REC;
  type TCobPerOpc_TAB  is table of TCobPerOpc_REC;

  C_946 INTEGER := 946; -- Codigo de KM Adicional de Reboque
  C_1   INTEGER := 1;   -- Nao Possui

  V_CobChkRec  TCobChk_REC;
  V_CobDplRec  TCobDpl_Rec;
  V_CobDpl     TCobDpl_TAB;
  V_CobChk     TCobChk_TAB;
  V_CobPer     TCobPer_TAB;
  V_CobPerOpc  TCobPerOpc_TAB;
  V_Found      Boolean;

   procedure AddErro(P_Codigo IN INTEGER, P_MSG VARCHAR2) IS
      V_MSG      RWS005_MSG;
   BEGIN
     V_MSG := RWS005_MSG(NULL,NULL);
     V_MSG.Codigo    := P_CODIGO;
     V_MSG.Descricao := P_MSG;
     P_Erros.extend;
     P_Erros(P_Erros.count) := V_MSG;
   END;

begin

  V_CobDpl  :=   TCobDpl_TAB();
  FOR I in 1 .. P_CobAdcional.Count LOOP
    V_Found := False;
    FOR J in 1 .. V_CobDpl.Count LOOP
      IF (P_CobAdcional(i).CodigoAcessorio = V_CobDpl(j).Cobertura ) THEN
         V_CobDpl(j).Conta := V_CobDpl(j).Conta + 1;
         V_Found := True;
         exit;
      END IF;
    END LOOP;
    IF NOT V_Found THEN
      V_CobDplRec.Cobertura := P_CobAdcional(i).CodigoAcessorio;
      V_CobDplRec.Conta     := 1;
      V_CobDpl.extend;
      V_CobDpl(V_CobDpl.Count) := V_CobDplRec;
    END IF;
  END LOOP;

  FOR J in 1 .. V_CobDpl.Count LOOP
      IF (V_CobDpl(j).Conta > 1) THEN
        AddErro(1501, 'Cobertura Adcional ' || To_Char(V_CobDpl(j).Cobertura)
                      || ' foi informada mais de uma vez ('
                      || To_Char(V_CobDpl(j).Conta) || ').');
      END IF;
  END LOOP;

  IF P_Erros.Count > 0 then
     RETURN FALSE;
  END IF;

  BEGIN
    SELECT  COBERTURA, DESCRICAO
    BULK COLLECT INTO V_CobPer
    FROM Mult_ProdutosCobPer
    WHERE   PRODUTO   =   P_PRODUTO
    AND   COBERTURA   in  (40, 54, 946, 947, 945, 994, 997)
    order by cobertura;

    SELECT   cobertura, OPCAO,   DESCRICAO
    BULK COLLECT INTO V_CobPerOpc
    FROM   Mult_ProdutosCobPerOpc
    WHERE   PRODUTO = P_Produto
    AND   COBERTURA in  (40, 54, 946, 947, 945, 994, 997)
    order by cobertura, OPCAO;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     AddErro(1502, 'Coberturas Adicionais nao encontadas para o produto '
                   || To_Char(P_Produto) || '.');
     RETURN FALSE;
  END;

  IF (V_CobPer.Count = 0) or (V_CobPerOpc.Count = 0) THEN
     AddErro(1503, 'Coberturas Adicionais nao encontadas para o produto '
                   || To_Char(P_Produto) || '.');
     RETURN FALSE;
  END IF;

  V_CobChk  := TCobChk_TAB();


  -- V_CobChkRec.CobFound Verifica se a cobertura foi encontrada
  --  0 Cobertura nao encontrada
  --  1 Cobertura encontrada
  -- -1 Cobertura invalida
  -- Criar uma tabela com todas as Coberturas necessarias
  FOR i in 1 .. V_CobPer.Count LOOP
    V_CobChkRec.Cobertura := V_CobPer(i).Cobertura;
    V_CobChkRec.CobFound  := 0;
    V_CobChkRec.Opcao     := 0;
    V_CobChkRec.CobDescr  := V_CobPer(i).Descricao;
    V_CobChkRec.OpcDescr  := NULL;
    V_CobChk.Extend;
    V_CobChk(V_CobChk.Count) := V_CobChkRec;
  END LOOP;

  -- Comparar lista de entrada com a lista de cobertura adicionais
  FOR i IN 1 .. P_CobAdcional.Count LOOP
     V_Found := False;
     FOR j in 1 .. V_CobPer.Count LOOP
       IF (P_CobAdcional(i).CodigoAcessorio = V_CobPer(j).Cobertura) THEN
          V_CobChk(j).CobDescr := V_CobPer(j).descricao;
          V_CobChk(j).CobFound := 1;
          V_Found := True;
          exit;
       END IF;
     END LOOP;
     -- Se a cobertura informada nao foi encontrada incluir na lista de
     -- pesquisa com opcao -1
     IF (NOT V_Found) THEN
        V_CobChkRec.Cobertura := P_CobAdcional(i).CodigoAcessorio;
        V_CobChkRec.Opcao     := 0;
        V_CobChkRec.CobFound  := -1;
        V_CobChkRec.CobDescr  := NULL;
        V_CobChkRec.OpcDescr  := NULL;
        V_CobChk.Extend;
        V_CobChk(V_CobChk.Count) := V_CobChkRec;
     END IF;
  END LOOP;

  FOR i IN 1 .. P_CobAdcional.Count LOOP
     V_Found := False;
     FOR j in 1 .. V_CobPerOpc.Count LOOP
       IF (P_CobAdcional(i).CodigoAcessorio = V_CobPerOpc(j).Cobertura) AND
          (P_CobAdcional(i).CodigoOpcao     = V_CobPerOpc(j).Opcao) THEN
          FOR k in 1 .. V_CobChk.Count LOOP
            IF (P_CobAdcional(i).CodigoAcessorio = V_CobChk(k).Cobertura) THEN
               V_Found := True;
               V_CobChk(k).Opcao    := V_CobPerOpc(j).Opcao;
               V_CobChk(k).OpcDescr := V_CobPerOpc(j).descricao;
               exit;
            END IF;
          END LOOP;
          exit;
       END IF;
     END LOOP;
     IF (NOT V_Found) THEN
        FOR j in 1 .. V_CobChk.Count LOOP
          IF (P_CobAdcional(i).CodigoAcessorio =  V_CobChk(j).Cobertura) THEN
             V_CobChk(j).Opcao := P_CobAdcional(i).CodigoOpcao;
             exit;
          END IF;
         END LOOP;
     END IF;
  END LOOP;

  -- Verificar Se Houve erros
  FOR i in 1 .. V_CobChk.Count LOOP
    -- Se a cobertura nao foi respondida
    IF (V_CobChk(i).CobFound = 0 ) THEN
      AddErro(1504, 'Cobertura adcional ' || To_Char(V_CobChk(i).Cobertura) || ' nao informada.');
    -- Cobertura Encontrada
    ELSIF (V_CobChk(i).CobFound > 0) THEN
      -- Opcao nao encotrado para a cobertura
      IF (V_CobChk(i).OpcDescr IS NULL) THEN
         AddErro(1505, 'Opcao ' || To_Char(V_CobChk(i).Opcao) || ' da cobertura adcional '
                       || To_Char(V_CobChk(i).Cobertura) || ' invalida.');
      END IF;
    -- Cobertura nao foi encontrada
    ELSIF (V_CobChk(i).CobFound < 0) THEN
      AddErro(1506, 'Cobertura adcional ' || To_Char(V_CobChk(i).Cobertura) || ' invalida.');
    END IF;
  END LOOP;
  -- Se nao houve erros
  IF (P_Erros.Count = 0) THEN
     -- Se Cobertura for 3 RCF-V e Nao Tiver Assistencia 24Hs
     IF (P_CodigoCobertura = 3) AND (P_TipoAssistencia = 'N') THEN
        -- Nao pode solicitar KM Adicional de Reboque.
        FOR I IN 1 .. P_CobAdcional.Count LOOP
          IF (P_CobAdcional(i).CodigoAcessorio =  C_946) AND
             (P_CobAdcional(i).CodigoOpcao     <> C_1)   THEN
             AddErro(1507, 'Nao se pode contratar KM adicional de Reboque quando'
                           ||  ' nao foi contratado Assitencia 24Horas.');
          END IF;
        END LOOP;
     END IF;
  END IF;

  RETURN P_Erros.Count = 0;
end;
/


CREATE OR REPLACE function fws016_CheckAcessorios(
    P_Produto     in Integer,
    P_Acessorios  IN     TWS004_ACESSORIO,
    P_Erros       in out TWS001_MSGS
) return Boolean
is

  Type TAcesDpl_REC is record ( Codigo MULT_PRODUTOSTIPOACESSORIOS.TIPO%type,
                                Conta  Integer
                              );

  Type TAcesChk_REC is record ( Codigo    MULT_PRODUTOSTIPOACESSORIOS.TIPO%type,
                                Descricao MULT_PRODUTOSTIPOACESSORIOS.DESCRICAO%Type,
                                Info      MULT_PRODUTOSTIPOACESSORIOS.DESCRICAO%Type,
                                VALOR Number(32)
                              );
  Type TAcesTbl_REC is record ( Codigo    MULT_PRODUTOSTIPOACESSORIOS.TIPO%type,
                                Descricao MULT_PRODUTOSTIPOACESSORIOS.DESCRICAO%Type
                              );

  Type TAcesDpl_Tbl is table of TAcesDpl_REC;
  Type TAcesChk_Tbl is table of TAcesChk_REC;
  Type TAcesTbl_Tbl is table of TAcesTbl_REC;

  V_RecAcesDpl TAcesDpl_Rec;
  V_RecAcesChk TAcesChk_Rec;

  V_TblAcesDpl TAcesDpl_Tbl;
  V_TblAcesChk TAcesChk_Tbl;
  V_TblAcesTbl TAcesTbl_Tbl;

  F_1029   Integer := 1029; -- Acessorios Outros
  V_Found  Boolean;

   procedure AddErro(P_Codigo IN INTEGER, P_MSG VARCHAR2) IS
      V_MSG      RWS005_MSG;
   BEGIN
     V_MSG := RWS005_MSG(NULL,NULL);
     V_MSG.Codigo    := P_CODIGO;
     V_MSG.Descricao := P_MSG;
     P_Erros.extend;
     P_Erros(P_Erros.count) := V_MSG;
   END;
begin

  IF (P_Acessorios.Count = 0) THEN
     RETURN TRUE;
  END IF;

  V_TblAcesDpl := TAcesDpl_Tbl();
  V_TblAcesChk := TAcesChk_Tbl();

  FOR i IN 1 .. P_Acessorios.Count LOOP
    V_Found := False;
    FOR J IN 1 .. V_TblAcesDpl.Count LOOP
       IF ( P_Acessorios(i).Codigo = V_TblAcesDpl(j).Codigo) THEN
         V_TblAcesDpl(j).Conta := V_TblAcesDpl(j).Conta + 1;
         V_Found := True;
         exit;
       END IF;
    END LOOP;
    IF NOT V_Found THEN
      V_RecAcesDpl.Codigo := P_Acessorios(i).Codigo;
      V_RecAcesDpl.Conta  := 1;
      V_TblAcesDpl.extend;
      V_TblAcesDpl(V_TblAcesDpl.Count) := V_RecAcesDpl;
    END IF;
  END LOOP;

  FOR J IN 1 .. V_TblAcesDpl.Count LOOP
       IF ( V_TblAcesDpl(j).Conta> 1) THEN
         AddErro(1601, 'Acessorio codigo  ' || To_Char(V_TblAcesDpl(j).Codigo)
                      || ' foi informado mais de uma vez ('
                      || To_Char(V_TblAcesDpl(j).Conta) || ').');
       END IF;
  END LOOP;

  IF (P_Erros.count > 0) THEN
     RETURN FALSE;
  END IF;

  FOR i IN 1 .. P_Acessorios.Count LOOP
      V_RecAcesChk.Codigo    := P_Acessorios(i).Codigo;
      V_RecAcesChk.Descricao := NULL;
      V_RecAcesChk.Info      := P_Acessorios(i).Descricao;
      V_RecAcesChk.VALOR     := P_Acessorios(i).Valor;
      V_TblAcesChk.extend;
      V_TblAcesChk(V_TblAcesChk.Count) := V_RecAcesChk;
  END LOOP;

  SELECT tipo, descricao
  BULK COLLECT INTO V_TblAcesTbl
  FROM MULT_PRODUTOSTIPOACESSORIOS
  WHERE PRODUTO = P_Produto
    AND TIPO <> F_1029; -- Acessorios Outros nao permitido

  IF (V_TblAcesTbl.Count = 0) THEN
     AddErro(1602, 'Acessorios nao encontrados.');
     RETURN FALSE;
  END IF;

  FOR i IN 1 .. V_TblAcesChk.Count LOOP
    for j in 1 .. V_TblAcesTbl.count LOOP
      IF (V_TblAcesChk(i).Codigo = V_TblAcesTbl(j).Codigo) THEN
         V_TblAcesChk(i).Descricao := V_TblAcesTbl(j).Descricao;
         exit;
      END IF;
    END LOOP;
  END LOOP;

  FOR j in 1 .. V_TblAcesChk.count LOOP
     IF (V_TblAcesChk(j).Descricao is NULL) THEN
        AddErro(1603, 'Acessorio codigo ' || To_Char(V_TblAcesChk(j).Codigo)
                      || ' invalido '     || V_TblAcesChk(j).Info || '.');
     END IF;
  END LOOP;

  RETURN P_Erros.Count = 0;
end;
/


CREATE OR REPLACE function FWS017_Produto_Kcw2SSV(P_Produto_Kcw in integer) return Integer
IS
BEGIN
  RETURN CASE P_Produto_KCW
              WHEN 10 THEN 7   -- Auto Passeio
              WHEN 42 THEN 20  -- Auto Classico
              WHEN 11 THEN 9   -- Carga
              WHEN 1 THEN 14   -- Residencial
              WHEN 2 THEN 12   -- Condominio
              ELSE 0           -- Invalido
         END;
END;
/


CREATE OR REPLACE function FWS018_ValidadeProduto(
    P_Produto       IN integer,  -- Tipo de Produto (10, 11, 42)
    P_TipoSeguro    IN Integer,  -- Tipo de Seguro
                                 --    1-Seguro Novo;
                                 --    2-Renovação de Congênere com sinistro;
                                 --    3-Renovação de Congênere sem sinistro;
                                 --    4-Renovação Tókio com sinistro;
                                 --    5-Renovação Tókio sem sinistro
    P_DtIniVigencia IN Date,     -- Data de Inicio de Vigencia
    P_DataVersao    IN Date,     -- Data base do Calculo
    P_Transacao     IN VarChar2, -- Tipo de transacao
                                 --    C - Calculo
                                 --    E - Efetivacao
                                 --    T - Tansmissao
    P_Validade      OUT Date,    -- Data Validade da Cotacao
    P_Erro          OUT VARCHAR2 -- Descricao do Erro
) return Boolean
IS

  V_Produto          Integer;
  V_TipoSeguro       VARCHAR2(2);
  V_TipoVigencia     VARCHAR2(2);
  V_SysDate          Date;
  V_DtIniVigencia    Date;
  V_DataVersao       Date;
  V_Parametro        VARCHAR2(100);
  V_BaseVigencia     VARCHAR2(20);
  V_DiasValidade     Integer;
  V_DiasPadrao       Integer := 7;          -- Validade de Dias Padrao
  V_BasePadrao       VARCHAR(20)  := 'PSI'; -- Preco Subscricao Insumos

BEGIN

  P_Erro     := NULL;
  P_Validade := NULL;

  -- Valida Produto
  IF NOT (P_Produto IN (10, 11, 42) ) THEN
     P_Erro := 'Produto '  || TO_Char(P_Produto) || ' nao suportado.';
     RETURN FALSE;
  END IF;
  IF P_Produto = 42 THEN
     V_Produto := 10;
  ELSE
     V_Produto := P_Produto;
  END IF;

  -- Valida Tipo de Seguuro
  CASE P_TipoSeguro
    WHEN 1 THEN V_TipoSeguro := 'N';
    WHEN 2 THEN V_TipoSeguro := 'C';
    WHEN 3 THEN V_TipoSeguro := 'C';
    WHEN 4 THEN V_TipoSeguro := 'R';
    WHEN 5 THEN V_TipoSeguro := 'R';
    ELSE
     P_Erro := 'Tipo de Seguro '  || TO_Char(P_TipoSeguro) || ' invalido.';
     RETURN FALSE;
  END CASE;

  V_SysDate       := Trunc(SysDate);
  V_DataVersao    := NVL(P_DataVersao,    V_SysDate);
  V_DtIniVigencia := NVL(P_DtIniVigencia, V_SysDate);

  IF (V_DtIniVigencia >= V_SysDate) THEN
    V_TipoVigencia := 'F';
  ELSE
    V_TipoVigencia := 'R';
  END IF;

  V_Parametro :=  'PROD_'       || V_Produto       ||
                  '_TPSEGURO_'  || V_TipoSeguro    ||
                  '_TPVIGEN_'   || V_TipoVigencia  ||
                  '_TPTRANSAC_' || P_Transacao;

   BEGIN
      SELECT VALOR
      INTO   V_BaseVigencia
      FROM   TABELA_CONFIGURACOES_KCW
      WHERE  PARAMETRO = V_Parametro;
   EXCEPTION WHEN OTHERS THEN
      V_BaseVigencia := V_BasePadrao;
   END;

   -- Seleciona o numero de dias por produto e tipo de seguro
   BEGIN
      SELECT QTD_DIAS_VALD
      INTO   V_DiasValidade
      FROM   TABELA_COTAC_PARAM_DATA
      WHERE  TIPO_SEGURO = P_Produto
        AND  TIPO_COMERZ = V_TipoSeguro
        AND  V_SysDate between DT_INICO_VIGEN and DT_FIM_VIGEN;
   EXCEPTION WHEN OTHERS THEN
      V_DiasValidade := V_DiasPadrao;
   END;

   IF (V_BaseVigencia = 'PSI') THEN
      P_Validade := V_DataVersao    + V_DiasValidade;
   ELSE
      P_Validade := V_DtIniVigencia + V_DiasValidade;
   END IF;

   RETURN True;

END;
/


CREATE OR REPLACE function FWS019_CheckCpfCnpj(
   P_CPF_CNPJ        IN  VARCHAR2,
   P_TipoPessoa      IN  VARCHAR2,
   P_Erro            OUT VARCHAR2
) return BOOLEAN
IS
  V_Numero   VARCHAR2(100);
  V_Dig_01   Integer;
  V_Dig_02   Integer;
begin
  IF (P_CPF_CNPJ IS NULL) THEN
     P_Erro := 'CPF ou CNPJ nao informado.';
     RETURN FALSE;
  END IF;
  V_Numero  := '00000000000000' || REGEXP_REPLACE(P_CPF_CNPJ, '[^0-9]');
  IF    (P_TipoPessoa = 'F') THEN
    V_Numero := SubStr(V_Numero, -11);
    V_Dig_01 := 11 - MOD (TO_NUMBER(SUBSTR(V_Numero, 9,1)) *  2 +
                          TO_NUMBER(SUBSTR(V_Numero, 8,1)) *  3 +
                          TO_NUMBER(SUBSTR(V_Numero, 7,1)) *  4 +
                          TO_NUMBER(SUBSTR(V_Numero, 6,1)) *  5 +
                          TO_NUMBER(SUBSTR(V_Numero, 5,1)) *  6 +
                          TO_NUMBER(SUBSTR(V_Numero, 4,1)) *  7 +
                          TO_NUMBER(SUBSTR(V_Numero, 3,1)) *  8 +
                          TO_NUMBER(SUBSTR(V_Numero, 2,1)) *  9 +
                          TO_NUMBER(SUBSTR(V_Numero, 1,1)) * 10,
                          11);
    IF (V_Dig_01 > 9) THEN
       V_Dig_01 := 0;
    END IF;
    IF (To_Char(V_Dig_01) <> SUBSTR(V_Numero, 10,1)) THEN
       P_Erro := 'CPF invalido.';
       RETURN FALSE;
    END IF;
    V_Dig_02 := 11 - MOD (V_Dig_01 * 2 +
                          TO_NUMBER (SUBSTR(V_Numero, 9,1)) *  3 +
                          TO_NUMBER (SUBSTR(V_Numero, 8,1)) *  4 +
                          TO_NUMBER (SUBSTR(V_Numero, 7,1)) *  5 +
                          TO_NUMBER (SUBSTR(V_Numero, 6,1)) *  6 +
                          TO_NUMBER (SUBSTR(V_Numero, 5,1)) *  7 +
                          TO_NUMBER (SUBSTR(V_Numero, 4,1)) *  8 +
                          TO_NUMBER (SUBSTR(V_Numero, 3,1)) *  9 +
                          TO_NUMBER (SUBSTR(V_Numero, 2,1)) * 10 +
                          TO_NUMBER (SUBSTR(V_Numero, 1,1)) * 11,
                          11);
    IF (V_Dig_02 > 9) THEN
       V_Dig_02 := 0;
    END IF;
    IF (To_Char(V_Dig_02) <> SUBSTR(V_Numero, 11,1)) THEN
       P_Erro := 'CPF invalido.';
       RETURN FALSE;
    END IF;
    RETURN TRUE;
  ELSIF (P_TipoPessoa = 'J') THEN
    V_Numero := SubStr(V_Numero, -14);
    V_Dig_01 := (11 - MOD (TO_NUMBER(SUBSTR(V_Numero,12,1)) * 2 +
                           TO_NUMBER(SUBSTR(V_Numero,11,1)) * 3 +
                           TO_NUMBER(SUBSTR(V_Numero,10,1)) * 4 +
                           TO_NUMBER(SUBSTR(V_Numero, 9,1)) * 5 +
                           TO_NUMBER(SUBSTR(V_Numero, 8,1)) * 6 +
                           TO_NUMBER(SUBSTR(V_Numero, 7,1)) * 7 +
                           TO_NUMBER(SUBSTR(V_Numero, 6,1)) * 8 +
                           TO_NUMBER(SUBSTR(V_Numero, 5,1)) * 9 +
                           TO_NUMBER(SUBSTR(V_Numero, 4,1)) * 2 +
                           TO_NUMBER(SUBSTR(V_Numero, 3,1)) * 3 +
                           TO_NUMBER(SUBSTR(V_Numero, 2,1)) * 4 +
                           TO_NUMBER(SUBSTR(V_Numero, 1,1)) * 5,
                           11));
    IF (V_Dig_01 > 9) then
       V_Dig_01 := 0;
    END IF;
    IF (To_Char(V_Dig_01) <> SUBSTR(V_Numero, 13,1)) THEN
       P_Erro := 'CNPJ invalido.';
       RETURN FALSE;
    END IF;
    V_Dig_02 := (11 - MOD (V_Dig_01 * 2 +
                           TO_NUMBER (SUBSTR(V_Numero,12,1)) * 3 +
                           TO_NUMBER (SUBSTR(V_Numero,11,1)) * 4 +
                           TO_NUMBER (SUBSTR(V_Numero,10,1)) * 5 +
                           TO_NUMBER (SUBSTR(V_Numero, 9,1)) * 6 +
                           TO_NUMBER (SUBSTR(V_Numero, 8,1)) * 7 +
                           TO_NUMBER (SUBSTR(V_Numero, 7,1)) * 8 +
                           TO_NUMBER (SUBSTR(V_Numero, 6,1)) * 9 +
                           TO_NUMBER (SUBSTR(V_Numero, 5,1)) * 2 +
                           TO_NUMBER (SUBSTR(V_Numero, 4,1)) * 3 +
                           TO_NUMBER (SUBSTR(V_Numero, 3,1)) * 4 +
                           TO_NUMBER (SUBSTR(V_Numero, 2,1)) * 5 +
                           TO_NUMBER (SUBSTR(V_Numero, 1,1)) * 6,
                           11));
    IF (V_Dig_02 > 9) then
       V_Dig_02 := 0;
    END IF;
    IF (To_Char(V_Dig_02) <> SUBSTR(V_Numero, 14,1)) THEN
       P_Erro := 'CNPJ invalido.';
       RETURN FALSE;
    END IF;
    RETURN TRUE;
  ELSE
     P_Erro := 'Tipo de Pessoa invalido.';
     RETURN FALSE;
  END IF;
  RETURN FALSE;
end;
/


CREATE OR REPLACE function fws020_ValidaOperadora(
                         P_Operadora in Integer,
                         P_Senha     IN VARCHAR2,
                         P_Erros     IN OUT TWS001_MSGS
) RETURN Boolean
IS
   V_SENHA     VARCHAR2(20);
   V_OPERADORA Integer;


   procedure AddErro(P_Codigo IN INTEGER, P_MSG VARCHAR2) IS
      V_MSG      RWS005_MSG;
   BEGIN
     V_MSG := RWS005_MSG(NULL,NULL);
     V_MSG.Codigo    := P_CODIGO;
     V_MSG.Descricao := P_MSG;
     P_Erros.extend;
     P_Erros(P_Erros.count) := V_MSG;
   END;

BEGIN
  IF P_Senha IS NULL THEN
     AddErro(20001, 'Codigo de Operadora nao informado.');
     RETURN FALSE;
  END IF;
  BEGIN
    SELECT CODIGO
    INTO   V_OPERADORA
    FROM   OPERADORA
    WHERE  CD_SENHA_OPRDR = P_Senha;
    IF P_Operadora = V_Operadora THEN
       RETURN TRUE;
    ELSE
      AddErro(20002, 'Codigo de Operadora invalido.');
       RETURN FALSE;
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      AddErro(20003, 'Codigo de Operadora invalido.');
      RETURN FALSE;
  END;
END;
/


CREATE OR REPLACE function fws021_ValidaSeguradoCondutor(
          P_DADOS     IN OUT RWS001_Dados,
          P_Erros     IN OUT TWS001_MSGS
) RETURN Boolean
IS

   V_Erro       VARCHAR2(200);
   V_Nascimento DATE;

   procedure AddErro(P_Codigo IN INTEGER, P_MSG VARCHAR2) IS
      V_MSG      RWS005_MSG;
   BEGIN
     V_MSG := RWS005_MSG(NULL,NULL);
     V_MSG.Codigo    := P_CODIGO;
     V_MSG.Descricao := P_MSG;
     P_Erros.extend;
     P_Erros(P_Erros.count) := V_MSG;
   END;

BEGIN

  -- Validacao do Nome e do CPF CNPJ do Segurado e Condutor
  IF (P_Dados.XI_CGC_CPF IS NULL) THEN
     AddErro(21001, 'CPF ou CNPJ nao informado.');
     RETURN FALSE;
  END IF;

  IF NOT fws019_checkcpfcnpj(P_Dados.XI_CGC_CPF, P_Dados.XI_TipoPessoa, V_Erro) THEN
     AddErro(21005, 'Segurado ' || V_Erro);
     RETURN FALSE;
  END IF;

  IF (P_Dados.XI_NomeSegurado IS NULL) THEN
     AddErro(21010, 'Nome do Segurado nao informado.');
     RETURN FALSE;
  END IF;

  IF P_Dados.XI_CondutorSegurado = 'S' THEN
     P_Dados.XI_CPFCondutor  := P_Dados.XI_CGC_CPF;
     P_Dados.XI_NomeCondutor := P_Dados.XI_NomeSegurado;
  ELSE
     IF (P_Dados.XI_CPFCondutor IS NULL) THEN
        AddErro(21015, 'CPF do condutor nao informado.');
        RETURN FALSE;
     END IF;

     IF NOT fws019_checkcpfcnpj(P_Dados.XI_CPFCondutor, 'F', V_Erro) THEN
        AddErro(21020, 'CPF do condutor invalido.');
        RETURN FALSE;
     END IF;

     IF (P_Dados.XI_NomeCondutor  IS NULL) THEN
        AddErro(21025, 'Nome do Segurado nao informado.');
        RETURN FALSE;
     END IF;

     IF P_Dados.XI_CPFCondutor = P_Dados.XI_CGC_CPF THEN
        AddErro(21030, 'Condutor deve ser diferente do Segurado .');
        RETURN FALSE;
     END IF;

     IF P_Dados.XI_NomeCondutor = P_Dados.XI_NomeSegurado THEN
        AddErro(21030, 'Condutor deve ser diferente do Segurado .');
        RETURN FALSE;
     END IF;
  END IF;

  IF P_Dados.XI_DataNascimentoCondutor IS NULL THEN
     AddErro(21035, 'Data de nascimento do Condutor nao foi informada.');
     RETURN FALSE;
  END IF;

  V_Nascimento := P_Dados.XI_DataNascimentoCondutor;

  /*
  V_Nascimento := REGEXP_REPLACE(P_Dados.XI_DataNascimentoCondutor, '[^0-9/-]');

  V_Nascimento := fws008_isdate(V_Nascimento);
  IF (V_Nascimento = To_Date('01-01-0001', 'DD-MM-YYYY') ) THEN
     AddErro(21040, 'Data de nascimento do Condutor invalida.');
     RETURN FALSE;
  END IF;
  */

  IF Trunc(SysDate - V_Nascimento) < 18 THEN
     AddErro(21045, 'Condutor deve ser maior de idade.');
     RETURN FALSE;
  END IF;

  IF P_Dados.XI_ClasseBonus IS NULL THEN
     AddErro(21050, 'Classe de bonus nao foi informada.');
     RETURN FALSE;
  END IF;

  IF (P_Dados.XI_ClasseBonus < 0) or (P_Dados.XI_ClasseBonus > 10) THEN
     AddErro(21055, 'Classe de bonus (' || To_Char(P_Dados.XI_ClasseBonus)  || ') invalida.');
     RETURN FALSE;
  END IF;

  IF ((Trunc(SysDate - V_Nascimento) - 18) < P_Dados.XI_ClasseBonus) THEN
     AddErro(21060, 'Classe de bonus (' || To_Char(P_Dados.XI_ClasseBonus)  || ') invalida.');
     RETURN FALSE;
  END IF;

  IF P_Dados.XI_SexoCondutor IS NULL THEN
     AddErro(21065, 'Sexo do condutor nao foi informado.');
     RETURN FALSE;
  END IF;

  P_Dados.XI_SexoCondutor := Upper(P_Dados.XI_SexoCondutor);
  IF NOT( P_Dados.XI_SexoCondutor IN ('F', 'M') ) THEN
     AddErro(21070, 'Sexo do condutor "' || P_Dados.XI_SexoCondutor || '"invalido.');
     RETURN FALSE;
  END IF;

  IF P_Dados.XI_EstadoCivilCondutor IS NULL THEN
     AddErro(21075, 'Estado civil do condutor nao foi informado.');
     RETURN FALSE;
  END IF;

  -- Estado Civil do Condutor
  --    A - Solteiro(a);
  --    B - Casado(a) ou vive em união estável (Companheiro(a));
  --    C - Viúvo;
  --    D - Divorciado(a)/Separado(a)
  P_Dados.XI_EstadoCivilCondutor := Upper(P_Dados.XI_EstadoCivilCondutor);
  IF NOT( P_Dados.XI_EstadoCivilCondutor IN ('A', 'B', 'C', 'D') ) THEN
     AddErro(21080, 'Estado civil do condutor "' || P_Dados.XI_EstadoCivilCondutor || '"invalido.');
     RETURN FALSE;
  END IF;

  /* Campo nao obrigatorio
  IF P_Dados.XI_CNHCondutor IS NULL THEN
     AddErro(21085, 'CNH do condutor nao foi informado.');
     RETURN FALSE;
  END IF;
  */

  P_Dados.XI_DataNascimentoCondutor := V_Nascimento;
  P_Dados.XI_NomeSegurado40         := SubStr(Trim(P_Dados.XI_NomeSegurado), 1, 40);
  P_Dados.XI_NomeCondutor40         := SubStr(Trim(P_Dados.XI_NomeCondutor), 1, 40);

  RETURN TRUE;
END;
/


CREATE OR REPLACE function fws022_ValidaCNH(
                         P_CNH    IN VARCHAR2,
                         P_Erro   IN OUT VARCHAR2
) return Boolean
is
                          --123456789012345678
  V_CNH      VARCHAR2(30);
  V_Soma     Integer;
  V_Digito   Integer;
  V_Controle VARCHAR2(4);
  V_Digitos  VARCHAR2(4);
  V_Mult     Integer;
  V_Mod11    Integer;
  V_Add2     Integer;
  V_Digito01 VARCHAR2(4);
  V_Digito02 VARCHAR2(4);

BEGIN

  IF P_CNH IS NULL THEN
     P_ERRO := 'nao informada';
     RETURN FALSE;
  END IF;


  IF Length(P_CNH) < 10 THEN
     IF Length(P_CNH) <> 9 THEN
        P_ERRO := 'invalida';
        RETURN FALSE;
     END IF;

     V_Digitos  := SubStr(V_CNH, -1);
     V_Soma := 0;
     V_Mult := 2;
     FOR J in 1 .. 8 LOOP
        V_Soma := V_Soma + ( TO_Number(SUBSTR(V_CNH, j, 1) ) * V_Mult);
        V_Mult := V_Mult + 1;
     END LOOP;

     V_Digito := V_Soma Mod 11;
     IF V_Digito > 9 THEN
        V_Digito := 0;
     END IF;

     IF To_Char(V_Digito) = V_Digitos THEN
        P_ERRO := 'OK';
        RETURN TRUE;
     ELSE
        P_ERRO := 'invalido';
        RETURN FALSE;
     END IF;

  ELSE
     -- Valida CNH Nova

     V_CNH := SubStr('00000000000000' || REGEXP_REPLACE(P_CNH, '[^0-9]'), -11);

     IF V_CNH = '00000000000' THEN
        P_ERRO := 'invalida';
        RETURN FALSE;
     END IF;

     V_Digitos  := SubStr(V_CNH, -2);
     V_Soma := 0;
     V_Mult := 9;

     FOR J in 1 .. 9 LOOP
        V_Soma := V_Soma + ( TO_Number(SUBSTR(V_CNH, j, 1) ) * V_Mult);
        V_Mult := V_Mult - 1;
     END LOOP;

     V_Add2   := 0;
     V_Digito := V_Soma Mod 11;
     IF V_Digito > 9 THEN
        IF V_Digito = 10 THEN
           V_Add2   := -2;
        END IF;
        V_Digito := 0;
     END IF;

     V_Digito01 := To_Char(V_Digito);
     V_Soma := 0;
     V_Mult := 1;

     FOR J in 1 .. 9 LOOP
        V_Soma := V_Soma + ( TO_Number(SUBSTR(V_CNH, j, 1) ) * V_Mult);
        V_Mult := V_Mult + 1;
     END LOOP;

     V_Mod11 := MOD(V_Soma, 11);
     IF V_Mod11 + V_Add2 < 0 THEN
        V_Digito := 11 + V_Mod11 + V_Add2;
     END IF;

     IF V_Mod11 + V_Add2 >= 0 then
        V_Digito := V_Mod11 + V_Add2;
     END IF;

     IF V_Digito > 9 then
        V_Digito := 0;
     END IF;

     V_Digito02 := To_Char(V_Digito);
     V_Controle := V_Digito01 || V_Digito02;

     IF V_Controle = V_Digitos THEN
        P_ERRO := 'OK';
        RETURN TRUE;
     ELSE
        P_ERRO := 'invalido';
        RETURN FALSE;
     END IF;

  END IF;

END;
/


CREATE OR REPLACE function fws023_ValidaLimites(
                 P_DADOS  IN OUT RWS001_Dados,
                 P_Erros  IN OUT TWS001_MSGS
) return Boolean
is
  TYPE T_Limites_Rec IS RECORD (
        Codigo    Integer,
        Descricao mult_produtostabrg.texto%type,
        Minimo    NUMBER(20,2),
        Maximo    NUMBER(20,2)
     );

  TYPE T_Limites_TAB  is table of T_Limites_REC;

  C_10           Integer := 10;
  C_6666         Integer := 6666;

  C_FRMT01       VARCHAR2(20) := 'L999G999G990D99';
  C_FRMT02       VARCHAR2(60) := 'NLS_NUMERIC_CHARACTERS = '',.'' NLS_CURRENCY = ''R$'' ';

  V_Limites      T_Limites_TAB;
  V_Corretores   Real_Corretores%rowtype;


   procedure AddErro(P_Codigo IN INTEGER, P_MSG VARCHAR2) IS
      V_MSG      RWS005_MSG;
   BEGIN
     V_MSG := RWS005_MSG(NULL,NULL);
     V_MSG.Codigo    := P_CODIGO;
     V_MSG.Descricao := P_MSG;
     P_Erros.extend;
     P_Erros(P_Erros.count) := V_MSG;
   END;


  procedure ValidaCodigo( P_Codigo IN Integer, P_Valor IN Number ) IS
    V_Valor NUMBER(20,2);
  BEGIN
    FOR I IN 1 .. V_Limites.Count LOOP
      IF (V_Limites(i).Codigo = P_Codigo) THEN
         IF P_Valor IS NULL THEN
            AddErro(23000, 'Valor de ' || V_Limites(i).Descricao || ' nao informado.');
            RETURN;
         END IF;
         V_Valor := Trunc(P_Valor);
         IF (V_Valor < V_Limites(i).Minimo) THEN
            AddErro(23005, 'Valor de ' || V_Limites(i).Descricao || ' '
                           ||  To_Char(V_Valor, C_FRMT01, C_FRMT02)
                           || ' menor que o limite de '
                           ||  To_Char(V_Limites(i).Minimo, C_FRMT01, C_FRMT02) || '.');
         ELSIF (V_Valor > V_Limites(i).Maximo) THEN
            AddErro(23010, 'Valor de ' || V_Limites(i).Descricao || ' '
                           ||  To_Char(V_Valor, C_FRMT01, C_FRMT02)
                           || ' maior que o limite de '
                           ||  To_Char(V_Limites(i).Maximo, C_FRMT01, C_FRMT02) || '.');
         END IF;
         RETURN;
      END IF;
    END LOOP;
  END;


BEGIN

  SELECT T9.Codigo, T9.Descricao, T9.Minimo, T9.Maximo
  BULK COLLECT INTO V_Limites
  FROM (
            SELECT Trunc(Chave2) AS Codigo,
                   Texto AS Descricao,
                   Valor2 AS Minimo,
                   Valor3 AS MAximo
            FROM   mult_produtostabrg T1
            WHERE  T1.produto = C_10
              AND T1.Tabela  = C_6666
            AND P_DADOS.W_DataVersao between T1.DT_INICO_VIGEN and T1.DT_FIM_VIGEN
            ORDER BY Codigo
       ) T9;

  IF P_Dados.XI_CodigoCobertura = 1 THEN          --   1 - Compreensiva
     ValidaCodigo(17,  P_Dados.XI_ValorVeiculo);  --  17 - COLISAO, INCENDIO E ROUBO
  ELSIF P_Dados.XI_CodigoCobertura = 2 THEN          --   2 - Incêndio e Roubo
     ValidaCodigo(18,  P_Dados.XI_ValorVeiculo);  --  18 - INCENDIO E ROUBO
  ELSIF P_Dados.XI_CodigoCobertura = 4 THEN          --   4 - Colisão e Incêndio
     ValidaCodigo(156, P_Dados.XI_ValorVeiculo);  -- 156 - COLISAO/INCENDIO
  END IF;

  IF P_Dados.XI_DanosMateriais > 0 THEN
     ValidaCodigo( 21, P_Dados.XI_DanosMateriais);  --  21	RCF-V - DANOS MATERIAIS
  END IF;
  IF P_Dados.XI_DanosCorporais > 0 THEN
     ValidaCodigo( 57, P_Dados.XI_DanosCorporais);  --  57	RCF-V - DANOS CORPORAIS
  END IF;
  IF P_Dados.XI_DanosMorais > 0 THEN
     ValidaCodigo(243, P_Dados.XI_DanosMorais);     -- 243	RCF-V - DANOS MORAIS
  END IF;
  IF P_Dados.XI_ValorApp > 0 THEN
     ValidaCodigo( 27, P_Dados.XI_ValorApp);        --  57	RCF-V - DANOS CORPORAIS
  END IF;

  IF P_Dados.XI_Blindagem IS NULL THEN
     AddErro(23015, 'Indicador de Blindagem nao informado');
     RETURN FALSE;
  END IF;

  IF P_Dados.XI_Blindagem <> 'S' THEN
     P_Dados.XI_Blindagem := 'N';
  END IF;

  IF P_Dados.XI_Blindagem  = 'S' THEN
     ValidaCodigo(294, P_Dados.XI_LmiBlindagem);  --  294 Bindagem
  END IF;

  IF P_Dados.XI_LmiKitGas IS NULL THEN
     P_Dados.XI_LmiKitGas := 0;
  END IF;

  IF P_Dados.XI_LmiKitGas > 0 THEN
     ValidaCodigo(292, P_Dados.XI_LmiKitGas);    --  292 KIT Gas
  END IF;

  IF P_Dados.XI_Desconto IS NULL THEN
     P_Dados.XI_Desconto := 0;
  END IF;

  IF P_Dados.XI_Agravo IS NULL THEN
     P_Dados.XI_Agravo := 0;
  END IF;

  IF P_Dados.XI_Desconto_CC IS NULL THEN
     P_Dados.XI_Desconto_CC := 0;
  END IF;

  IF P_Dados.XI_Agravo_CC IS NULL THEN
     P_Dados.XI_Agravo_CC := 0;
  END IF;

  IF (P_Dados.XI_Desconto > 100) THEN
     AddErro(23020, 'Valor de desconto invalido.');
     RETURN FALSE;
  END IF;

  IF (P_Dados.XI_Agravo > 100) THEN
     AddErro(23020, 'Valor de agravo invalido.');
     RETURN FALSE;
  END IF;

  IF (P_Dados.XI_Desconto_CC > 100) THEN
     AddErro(23025, 'Valor de desconto de Conta Corrente invalido.');
     RETURN FALSE;
  END IF;

  IF (P_Dados.XI_Agravo_CC > 100) THEN
     AddErro(23030, 'Valor de agravo de Conta Corrente invalido.');
     RETURN FALSE;
  END IF;

  IF (P_Dados.XI_Desconto > 0) and (P_Dados.XI_Agravo > 0) THEN
     AddErro(23035, 'Desconto e Agravo informado similtaneamente.');
     RETURN FALSE;
  END IF;

  IF (P_Dados.XI_Desconto_CC > 0) and (P_Dados.XI_Agravo_CC > 0) THEN
     AddErro(23040, 'Desconto e Agravo de Conta Corrente informado similtaneamente.');
     RETURN FALSE;
  END IF;

  IF ((P_Dados.XI_Desconto_CC > 0) OR (P_Dados.XI_Agravo_CC > 0)) AND
     ((P_Dados.XI_Desconto > 0) OR (P_Dados.XI_Agravo > 0)) THEN
     AddErro(23045, 'Se desconto ou agravo de Conta Corrente informado,'
                    || ' nao pode ser informado desconto ou agravo de negocio.' );
     RETURN FALSE;
  END IF;

  IF (P_Dados.XI_TipoAssistencia IS NULL) THEN
     AddErro(23050, 'Tipo de Assistencia nao informado.');
     RETURN FALSE;
  END IF;

  IF NOT (P_Dados.XI_TipoAssistencia in ('C', 'N', 'V') ) THEN
     AddErro(23055, 'Tipo de Assistencia informada "'
                    || P_Dados.XI_TipoAssistencia || '" invalida.');
     RETURN FALSE;
  END IF;

  BEGIN
     SELECT *
     INTO   V_Corretores
     FROM   Real_Corretores
     WHERE  corretor = P_Dados.XI_CodigoCorretor;
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
     AddErro(23060, 'Corretor nao encontrado.');
     RETURN FALSE;
  END;

  IF P_Dados.XI_CodigoProduto in (10, 42) THEN
     IF    V_Corretores.Comissaomaxpasseio < P_Dados.XI_PercentualComissao THEN
        AddErro(23065, 'Valor do percentual de comissao maior que o limite permitido.');
        RETURN FALSE;
     ELSIF V_Corretores.Comissaominpasseio > P_Dados.XI_PercentualComissao THEN
        AddErro(23070, 'Valor do percentual de comissao menor que o limite permitido.');
        RETURN FALSE;
     END IF;
     P_Dados.W_ComissaoPadrao := V_Corretores.Comissaopadraopasseio;
  ELSE
     P_Dados.W_ComissaoPadrao := 0;
  END IF;

  RETURN P_Erros.Count = 0;

END;
/


CREATE OR REPLACE function fws024_GetQbrId(
       P_CodigoCorretor  IN  INTEGER,
       P_CodigoProduto   IN  INTEGER,
       P_Veiculo         IN  INTEGER,
       P_TipoVeiculo     IN  INTEGER,
       P_TipoUsoVeiculo  IN  VARCHAR2,
       P_TipoPessoa      IN  VARCHAR2,
       P_CEP             IN  VARCHAR2,
       P_DataVersao      IN  DATE,
       P_ErroCode        OUT INTEGER,
       P_ErroMsg         OUT VARCHAR2,
       P_QbrId           OUT VARCHAR2

) return BOOLEAN

IS
  C_0                 INTEGER  := 0;
  C_1                 INTEGER  := 1;
  C_10                INTEGER  := 10;
  C_24                INTEGER  := 24;
  C_25                INTEGER  := 25;
  C_50                INTEGER  := 50;

  V_CONTA             INTEGER;
  V_CEP               INTEGER;
  V_VIGENCIA          INTEGER;
  V_REGIAO            INTEGER;
  V_Agrupamento       INTEGER;
  V_CanalVenda        INTEGER;
  V_Categoria         INTEGER;
  V_QbrId             VARCHAR2(10);

begin

  V_CEP :=fws009_iscep(P_CEP);

  IF (V_CEP = 0) THEN
     P_ErroCode  := 2400;
     P_ErroMsg   := 'CEP "' || P_CEP || ' "invalido.';
     RETURN FALSE;
  END IF;

  begin
      SELECT Categ_Tar1
      into   V_Categoria
      from tabela_veiculomodelo
      where MODELO = P_Veiculo;
    exception
        WHEN NO_DATA_FOUND THEN
        BEGIN
            P_ErroCode  := 2405;
            P_ErroMsg   := 'Codigo de Veiculo ' || to_char(P_Veiculo) || ' invalido.' ;
            RETURN FALSE;
        END;
  end;


  -- Verifica Tipo de Veiculo
  SELECT COUNT(VALOR)
  INTO   V_CONTA
  FROM   MULT_PRODUTOSTABRG
  WHERE  PRODUTO = C_10
    AND  TABELA  = C_24
    AND  chave1  = P_TipoVeiculo;

  IF (V_CONTA = 0) then
     P_ErroCode  := 2410;
     P_ErroMsg   := 'Tipo de Veiculo Invalido';
     RETURN FALSE;
  end if;

  -- Obtem Regiao para respostas
  BEGIN
    SELECT T2.VALOR4 INTO V_REGIAO FROM MULT_PRODUTOSTABRG T1
    LEFT JOIN MULT_PRODUTOSTABRG T2
      ON T2.PRODUTO = P_CodigoProduto
     AND T2.TABELA = C_25
     AND T2.valor5 = T1.VALOR
    WHERE T1.PRODUTO = P_CodigoProduto
      AND T1.TABELA = C_50
      AND T1.chave1 = C_1
      AND P_DataVersao between T1.DT_INICO_VIGEN and T1.DT_FIM_VIGEN
      AND P_DataVersao between T2.DT_INICO_VIGEN and T2.DT_FIM_VIGEN
      AND T1.chave2 <= V_CEP
      AND T1.chave3 >= V_CEP
      AND ROWNUM = 1;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     P_ErroCode  := 2415;
     P_ErroMsg   := 'CEP "' || P_CEP || ' "invalido.';
     RETURN FALSE;
  END;

  -- Obtem Vigencia (1 - Corrente 2 - Anterior)
  V_VIGENCIA := FWS002_GetVigencia(P_CodigoProduto, P_DataVersao);
  if (V_Vigencia  = 0) then
     P_ErroCode  := 2420;
     P_ErroMsg   := 'Data de Inicio de Vigencia invalida.';
     RETURN FALSE;
  end if;

  -- Obtem Agrupamento
  BEGIN
    select agrupamento
    into   V_Agrupamento
    from   MULT_PRODUTOSQBRAGRUPREG
    where  produto   = P_CodigoProduto
      and  vigencia  = V_VIGENCIA
      and  regiao    = V_REGIAO
      and  P_DataVersao between DT_INICO_VIGEN and DT_FIM_VIGEN;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     P_ErroCode  := 2425;
     P_ErroMsg   := 'Agrupamento nao encontrado.';
     RETURN FALSE;
  END;

  -- Obtem Canal de Venda
  V_CanalVenda := FWS003_CanalVendas(P_CodigoCorretor);

  BEGIN
    SELECT CODIGO
    INTO V_QbrId
    FROM MULT_PRODUTOSQBRGRUPOS T1
    WHERE  T1.PRODUTO    = P_CodigoProduto
      AND  T1.VIGENCIA   = V_Vigencia
      AND  T1.CANALVENDA = V_CanalVenda
      AND  T1.TIPOPROD   = 'T' -- Constante
      AND  T1.TIPOPESSOA = P_TipoPessoa
      AND  (
              (
                         (T1.CATEGVEIC = C_0 AND CD_TIPO_VEICU = C_0)
                     OR  (T1.CATEGVEIC = C_0 AND CD_TIPO_VEICU = P_TipoVeiculo)
               ) OR (
                        (T1.CATEGVEIC = V_Categoria AND T1.CD_TIPO_VEICU = C_0)
                     OR (T1.CATEGVEIC = C_0 AND T1.CD_TIPO_VEICU = C_0)
               )
           )
      AND  T1.TIPOUSOVEIC = P_TipoUsoVeiculo
      AND  P_DataVersao  BETWEEN T1.DT_INICO_VIGEN AND T1.DT_FIM_VIGEN
      AND  ROWNUM = 1
      order by CD_TIPO_VEICU, CATEGVEIC;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     P_ErroCode  := 2430;
     P_ErroMsg   := 'QBR nao encontrado.';
     RETURN FALSE;
  END;

  P_QbrId :=  V_QbrId;
  RETURN TRUE;

END;
/


CREATE OR REPLACE function fws101_consultaacessorios(
   P_Corretor        IN VARCHAR2,
   P_Usuario         IN VARCHAR2,
   P_Produto         IN VARCHAR2,
   P_NumeroCotacaoMC IN VARCHAR2
) return VARCHAR2
IS
  type TIPOASS_REC  is record (tipo MULT_PRODUTOSTIPOACESSORIOS.TIPO%type,
                               descricao MULT_PRODUTOSTIPOACESSORIOS.Descricao%type);
  type TIPOASS_TAB  is table of TIPOASS_REC;
  V_TIPOASS TIPOASS_TAB;
  V_1029   INTEGER := 1029;
  V_Ret01  VARCHAR2(100) := '<?xml version="1.0" encoding="ISO-8859-1"?><Retorno>';
  V_Ret02  VARCHAR2(100) := '</Retorno>';
  V_Ret03  VARCHAR2(100) := '<Acessorios/>';
  V_Ret04  VARCHAR2(100) := '<Acessorios/><Erros>';
  V_Ret05  VARCHAR2(100) := '</Erros>';
  V_Ret06  VARCHAR2(20)  := '<Mensagem>';
  V_Ret07  VARCHAR2(20)  := '</Mensagem>';
  V_Prod   VARCHAR(20);
  V_XML    VARCHAR2(2000);
  V_Corretor  Integer;
  V_Produto   Integer;
  --
  PRAGMA AUTONOMOUS_TRANSACTION;
  --
begin

  V_Corretor := FWS007_IsNumber(P_Corretor);
  V_Produto  := FWS007_IsNumber(P_Produto);

  V_XML :=  FWS004_CheckUser(V_Corretor, P_Usuario, V_Produto);

  if V_XML <> 'OK' then
     V_XML :=  V_RET01 || V_Ret03 || V_XML || V_RET02;
     RETURN V_XML;
  end if;

  BEGIN

    SELECT Tipo , Descricao
    BULK COLLECT INTO V_TIPOASS
    FROM MULT_PRODUTOSTIPOACESSORIOS d
    WHERE PRODUTO = V_PRODUTO
      AND TIPO <> V_1029;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     V_XML :=  V_RET01 || V_RET03 || V_Ret06 || 'Acessorios nao Encontados para o produto informado' || V_Ret06 || V_RET05 || V_RET02;
     RETURN V_XML;
  END;

  V_Prod := TO_Char(V_Produto);
  V_XML  := '<Acessorios>';
  FOR i IN 1 .. V_TIPOASS.COUNT LOOP
    V_XML := V_XML || '<Acessorio><CodigoProduto>'             || V_Prod
                   || '</CodigoProduto><CodigoAcessorio>'      || To_Char(V_TIPOASS(i).Tipo)
                   || '</CodigoAcessorio><DescricaoAcessorio>' || V_TIPOASS(i).Descricao
                   || '</DescricaoAcessorio></Acessorio>';

  END LOOP;

  V_XML := V_RET01 || V_XML || '</Acessorios><Erros/>' || V_RET02;

  RETURN V_XML;

END;
/


CREATE OR REPLACE function fws103_consultacobadicionais(
   P_Corretor         IN VARCHAR2,
   P_Usuario          IN VARCHAR2,
   P_Produto          IN VARCHAR2,
   P_NumeroCotacaoMC  IN VARCHAR2
) return CLOB
IS
  -- type TCobertura_REC  is record (cobertura Mult_ProdutosCobPer.cobertura%type);
  type TCobPer_REC     is record (cobertura Mult_ProdutosCobPer.cobertura%type,
                                  descricao Mult_ProdutosCobPer.Descricao%type);
  type TCobPerOpc_REC  is record (cobertura Mult_ProdutosCobPer.cobertura%type,
                                  opcao     Mult_ProdutosCobPerOpc.Opcao%type,
                                  descricao Mult_ProdutosCobPer.Descricao%type);
  -- type TCobertura_TAB  is table of integer;
  type TCobPer_TAB     is table of TCobPer_REC;
  type TCobPerOpc_TAB  is table of TCobPerOpc_REC;
  TYPE  NumList IS VARRAY(7) OF NUMBER;
  V_LST NumList := NumList(40, 54, 945, 994, 997, 947, 946);

  V_CobPer     TCobPer_TAB;
  V_CobPerOpc  TCobPerOpc_TAB;
  -- V_Cobertuara TCobertura_TAB := TCobertura_TAB(7);
  V_1029 INTEGER := 1029;
  V_Ret01  VARCHAR2(100) := '<?xml version="1.0" encoding="ISO-8859-1"?><Retorno>';
  V_Ret02  VARCHAR2(100) := '</Retorno>';
  V_Ret03  VARCHAR2(100) := '<CoberturasAdicionais/>';
  V_Ret04  VARCHAR2(100) := '<CoberturasAdicionais/><Erros>';
  V_Ret05  VARCHAR2(100) := '</Erros>';
  V_Ret06  VARCHAR2(20) := '<Mensagem>';
  V_Ret07  VARCHAR2(20) := '</Mensagem>';
  V_Prod   VARCHAR(20);
  V_XML    VARCHAR2(32000);
  V_Corretor  Integer;
  V_Produto   Integer;
  PRAGMA AUTONOMOUS_TRANSACTION;
begin

  /*
  -- Iniciando Tabela com coberturas Adicionais a serem Selecionadas.
  V_Cobertuara(1) := 40;   -- Vidros
  V_Cobertuara(2) := 54;   -- Desp. Extraordinárias
  V_Cobertuara(3) := 945;  -- Carro Reserva
  V_Cobertuara(4) := 946;  -- Km Adicional de Reboque
  V_Cobertuara(5) := 947;  -- 1º sinistro indenizável sem cobrança de franquia?
  V_Cobertuara(6) := 994;  -- Tipo Oficina
  V_Cobertuara(7) := 997;  -- Tipo Veiculo
  */

  V_Corretor := FWS007_IsNumber(P_Corretor);
  V_Produto  := FWS007_IsNumber(P_Produto);

  V_XML :=  FWS004_CheckUser(V_Corretor, P_Usuario, V_Produto);

  if V_XML <> 'OK' then
     V_XML :=  V_RET01 || V_Ret03 || V_XML || V_RET02;
     RETURN V_XML;
  end if;

  BEGIN
    SELECT  COBERTURA, DESCRICAO
    BULK COLLECT INTO V_CobPer
    FROM Mult_ProdutosCobPer
    WHERE   PRODUTO   =   V_PRODUTO
    AND   COBERTURA   in  (40, 54, 945, 994, 997, 947, 946)
    order by cobertura;

    SELECT   cobertura, OPCAO,   DESCRICAO
    BULK COLLECT INTO V_CobPerOpc
    FROM   Mult_ProdutosCobPerOpc
    WHERE   PRODUTO = V_Produto
    AND   COBERTURA in  (40, 54, 945, 994, 997, 947, 946)
    order by cobertura, OPCAO;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     V_XML :=  V_RET01 || V_RET03  || V_RET06  || 'Coberturas Adicionais nao Encontada para o produto informado' || V_RET07 || V_RET05 || V_RET02;
     RETURN V_XML;
  END;


  V_XML  := '<CoberturasAdicionais>';
  FOR i IN 1 .. V_CobPer.COUNT LOOP
    V_XML := V_XML || '<CoberturaAdicional><CodigoCobertura>'  || To_Char(V_CobPer(i).Cobertura)
                   || '</CodigoCobertura><DescricaoCobertura>' || V_CobPer(i).Descricao
                   || '</DescricaoCobertura><Opcoes>';

    FOR j IN 1 .. V_CobPerOpc.COUNT LOOP
      if (V_CobPer(i).Cobertura = V_CobPerOpc(j).Cobertura) then
        V_XML := V_XML || '<Opcao><CodigoOpcao>'           || To_Char(V_CobPerOpc(j).Opcao)
                       || '</CodigoOpcao><DescricaoOpcao>' || V_CobPerOpc(j).Descricao
                       || '</DescricaoOpcao></Opcao>';
      END IF;
    END LOOP;

    V_XML := V_XML || '</Opcoes></CoberturaAdicional>';


  END LOOP;

  V_XML := V_RET01 || V_XML || '</CoberturasAdicionais><Erros/>' || V_RET02;

  RETURN V_XML;

END;
/


CREATE OR REPLACE function fws104_consultamodelos(
   P_Corretor            IN VARCHAR2,
   P_Usuario             IN VARCHAR2,
   P_AnoModelo           IN VARCHAR2,
   P_TipoCombustivel     IN VARCHAR2,
   P_DescricaoVeiculo    IN VARCHAR2,
   P_DescricaoFabricante IN VARCHAR2,
   P_Produto             IN VARCHAR2,
   P_CodigoFipe          IN VARCHAR2,
   P_NumeroCotacaoMC     IN VARCHAR2
) return CLOB
IS
  type TVEICULO_REC  is record (NumPassageiros tabela_veiculomodelo.NumPassageiros%type,
                                Nome           tabela_veiculofabric.Nome%type,
                                Fabricante     tabela_veiculomodelo.Fabricante%type,
                                Modelo         tabela_veiculomodelo.Modelo%type,
                                Descricao      tabela_veiculomodelo.Descricao%type,
                                Combustivel    REAL_ANOSAUTO.tipo_combustivel%type,
                                Categ_Tar1     tabela_veiculomodelo.Categ_Tar1%type,
                                CD_FIPE        real_deparafipe.CD_FIPE%type);
  type TVEICULO_TAB  is table of TVEICULO_REC;
  V_VEICULOS TVEICULO_TAB;
  v_0 INTEGER      := 0;
  V_Count INTEGER;
  V_P VARCHAR2(2)  := 'P';
  V_Ret01  VARCHAR2(100)   := '<?xml version="1.0" encoding="ISO-8859-1"?><Retorno>';
  V_Ret02  VARCHAR2(100)   := '</Retorno>';
  V_Ret03  VARCHAR2(100)   := '<Veiculos/>';
  V_Ret04  VARCHAR2(100)   := '<Veiculos/><Erros>';
  V_Ret05  VARCHAR2(100)   := '</Erros>';
  V_Ret06  VARCHAR2(100)   := '<Mensagem>';
  V_Ret07  VARCHAR2(100)   := '</Mensagem>';
  V_Erros  VARCHAR(500)    := '';
  V_Prod   VARCHAR2(10)    := '';
  V_ProdNome VARCHAR2(20)  := '';
  V_Fabricante      VARCHAR(50) := '%';
  V_NomeVeiculo     VARCHAR(50) := '%';
  V_TipoCombustivel VARCHAR(10) := '%';
  V_XML    CLOB;
  V_Corretor  Integer;
  V_Produto   Integer;
  V_AnoModelo Integer;
  v_CodigoFipe  VARCHAR2(9);
  v_id_log      NUMBER(38);
  v_gpa         NUMBER;
  --
  PRAGMA AUTONOMOUS_TRANSACTION;
  --
PROCEDURE       Atualiza_erro   (p_id_log       IN      NUMBER
                                ,p_msg_erro     IN      VARCHAR2)       IS
BEGIN
        --
        BEGIN
                --
                UPDATE  KIT0007_LOG_CNSLT_MODEL
                SET     dt_fim_log              =       SYSTIMESTAMP,
                        ds_msg_erro_log         =       p_msg_erro
                WHERE   id_LOG_CNSLT_MODEL      =       p_id_log;
                --
                COMMIT;
                --
        EXCEPTION
                --
                WHEN    OTHERS  THEN
                        --
                        --
                        SELECT  valor
                        INTO    v_gpa
                        FROM    TABELA_CONFIGURACOES_KCW
                        WHERE   PARAMETRO       =       'GPA_LOG_CONSULTA_MODELO';
                        --
                        tms_gpa.erro (v_gpa ,' Erro no Atualiza_erro: ' || SQLERRM);
                        tms_gpa.erro (v_gpa ,'v_id_log: ' || v_id_log);
                        tms_gpa.erro (v_gpa ,'P_Corretor: ' || P_Corretor);

                        --
        END;
        --
END     Atualiza_erro   ;

BEGIN
        --
        -- Grava Log de Chamadas
        --
        BEGIN
                SELECT  kitsq0007_CNSLT_MODEL.NEXTVAL
                INTO    v_id_log
                FROM    dual;
                --
                INSERT  INTO    KIT0007_LOG_CNSLT_MODEL
                                (id_log_cnslt_model
                                ,dt_inico_log
                                ,cd_crtor
                                ,cd_usuro
                                ,Aa_Model
                                ,Tp_Cmbst
                                ,ds_veicu
                                ,Ds_Fabrt
                                ,Cd_prdut
                                ,Cd_Fipe
                                ,Nr_Cotac_MC)
                        VALUES  (v_id_log
                                ,SYSTIMESTAMP
                                ,P_Corretor
                                ,P_Usuario
                                ,P_AnoModelo
                                ,P_TipoCombustivel
                                ,P_DescricaoVeiculo
                                ,P_DescricaoFabricante
                                ,P_Produto
                                ,P_CodigoFipe
                                ,P_NumeroCotacaoMC);
                --
                COMMIT;
                --
        EXCEPTION
                --
                WHEN    OTHERS  THEN
                        --
                        SELECT  valor
                        INTO    v_gpa
                        FROM    TABELA_CONFIGURACOES_KCW
                        WHERE   PARAMETRO       =       'GPA_LOG_CONSULTA_MODELO';
                        --
                        tms_gpa.erro (v_gpa ,' Erro no Insert Log: ' || SQLERRM);
                        tms_gpa.erro (v_gpa ,'v_id_log: ' || v_id_log);
                        tms_gpa.erro (v_gpa ,'P_Corretor: ' || P_Corretor);
                        tms_gpa.erro (v_gpa ,'P_Usuario: ' || P_Usuario);
                        tms_gpa.erro (v_gpa ,'P_AnoModelo: ' || P_AnoModelo);
                        tms_gpa.erro (v_gpa ,'P_TipoCombustivel: ' || P_TipoCombustivel);
                        tms_gpa.erro (v_gpa ,'P_DescricaoVeiculo: ' || P_DescricaoVeiculo);
                        tms_gpa.erro (v_gpa ,'P_DescricaoFabricante: ' || P_DescricaoFabricante);
                        tms_gpa.erro (v_gpa ,'P_Produto: ' || P_Produto);
                        tms_gpa.erro (v_gpa ,'P_CodigoFipe: ' || P_CodigoFipe);
                        tms_gpa.erro (v_gpa ,'P_NumeroCotacaoMC: ' || P_NumeroCotacaoMC);

                --
        END;

  Dbms_Output.Put_Line('inicio');
  V_Corretor := FWS007_IsNumber(P_Corretor);
  V_Produto  := FWS007_IsNumber(P_Produto);

  V_XML :=  FWS004_CheckUser(V_Corretor, P_Usuario, V_Produto);

  if V_XML <> 'OK' then
     V_XML :=  V_RET01 || V_Ret03 || V_XML || V_RET02;
     --
     Atualiza_erro(v_id_log, V_XML);
     --
     RETURN V_XML;
  end if;

  V_AnoModelo := FWS007_IsNumber(P_AnoModelo);

        Dbms_Output.Put_Line('passou do anomodelo number');
  IF V_AnoModelo = 0 then
    V_Erros := V_Erros || V_Ret06 || 'É necessário informar o ano do veículo que deseja consultar.' || V_Ret07;
  END IF;


  IF LENGTH(P_CodigoFipe) = 0 then
    IF LENGTH(P_DescricaoVeiculo) = 0 then
      V_Erros := V_Erros || V_Ret06 || 'É necessário informar a descrição do veículo que deseja consultar.' || V_Ret07;
    END IF;
  END IF;

  -- Se Descricao do fabricante existe....
  IF Length(P_DescricaoFabricante) > 0 then
    V_Fabricante := '%' || UPPER(P_DescricaoFabricante) || '%';

    SELECT COUNT(FABRICANTE) INTO V_COUNT FROM TABELA_VEICULOFABRIC WHERE  SITUACAO = V_P AND NOME LIKE V_Fabricante;

    IF V_Count = 0 THEN
      V_Erros := V_Erros || V_Ret06 || 'O fabricante informado "' || P_DescricaoFabricante
                         || '" não foi encontrado, verifique se o nome está correto ou consulte a seguradora.'
                         || V_Ret07;
    END IF;

  END IF;

  Dbms_Output.Put_Line('passou do select count fabricante');

  IF LENGTH(V_Erros) > 0 THEN
       V_Erros := V_Ret01 || V_RET04  || V_Erros || V_RET05 || V_RET02;
        --
        Atualiza_erro(v_id_log, V_Erros);
        --
    RETURN V_Erros;
  END IF;

        Dbms_Output.Put_Line('passou do V_Erros');
  -- Se Descricao do Veiculo existe....
  IF Length(P_DescricaoVeiculo) > 0 then
    V_NomeVeiculo := '%' || SubStr(UPPER(P_DescricaoVeiculo), 40) || '%';
  END IF;
   Dbms_Output.Put_Line('passou do Length(P_DescricaoVeiculo) ');
  -- Se Descricao do Veiculo existe....
  IF Length(P_TipoCombustivel) > 0 then
    V_TipoCombustivel := UPPER(P_TipoCombustivel);
  END IF;

   Dbms_Output.Put_Line('passou do Length(P_TipoCombustivel)');
  BEGIN

  IF LENGTH(P_CodigoFipe) > 0 THEN
        --
        v_CodigoFipe    :=      REPLACE(P_CodigoFipe,'-','');
        --
   Dbms_Output.Put_Line('dentro do LENGTH(P_CodigoFipe) > 0');

    Dbms_Output.Put_Line('P_CodigoFipe: *' || P_CodigoFipe || '*');

    v_CodigoFipe        :=      LPad(v_CodigoFipe,7,'0');
    --
    Dbms_Output.Put_Line('v_CodigoFipe: *' || v_CodigoFipe || '*');
    v_CodigoFipe        :=      SubStr(v_CodigoFipe,1,6) || '-' || SubStr(v_CodigoFipe,7,1);

    Dbms_Output.Put_Line('v_CodigoFipe: *' || v_CodigoFipe || '*');
    --

    SELECT DISTINCT T1.NumPassageiros, T2.Nome, T1.Fabricante, T1.Modelo, T1.Descricao,
           T4.tipo_combustivel, T1.Categ_Tar1, T3.CD_FIPE BULK COLLECT INTO V_VEICULOS
    FROM  real_deparafipe T3
    LEFT  JOIN tabela_veiculofabric T2
      ON  t2.Fabricante = t3.cd_fab_real
     AND  T2.Situacao   = V_P
    LEFT  JOIN tabela_veiculomodelo T1
      ON  t3.cd_mod_real = t1.modelo
     AND  T1.modelo > v_0
    INNER JOIN REAL_ANOSAUTO T4
      on  t4.Modelo = t3.cd_mod_real
     and  T4.ANOATE >= V_AnoModelo
     and  T4.ANODE <= V_AnoModelo
    INNER JOIN TABELA_VEICULOFABRIC T5
      ON  T5.Fabricante = T3.cd_fab_real
     AND  T2.Situacao = V_P
    where CD_FIPE       = v_CodigoFipe
     --AND  T1.descricao like V_NomeVeiculo
     --AND  T2.Nome like V_Fabricante
     --AND  T4.TIPO_COMBUSTIVEL = Nvl(V_TipoCombustivel,T4.TIPO_COMBUSTIVEL)
    ORDER BY t1.DESCRICAO;
    Dbms_Output.Put_Line('passou do select');
    Dbms_Output.Put_Line('count' || V_VEICULOS.COUNT );
  ELSE

    SELECT DISTINCT T1.NumPassageiros, T2.Nome, T1.Fabricante, T1.Modelo, T1.Descricao,
           T4.tipo_combustivel, T1.Categ_Tar1, T3.CD_FIPE BULK COLLECT INTO V_VEICULOS
    FROM  tabela_veiculomodelo T1
    LEFT  JOIN tabela_veiculofabric T2
      ON  T2.Fabricante = T1.Fabricante
     AND  T2.Situacao   = V_P
    LEFT  JOIN real_deparafipe T3
      ON  t3.cd_mod_real = t1.modelo
    INNER JOIN TABELA_VEICULOFABRIC T5
      ON  T5.Fabricante = T1.Fabricante
     AND  T2.Situacao = V_P
    INNER JOIN REAL_ANOSAUTO t4
      on  t4.Modelo = T1.Modelo
     and  T4.ANOATE >= V_AnoModelo
     and  T4.ANODE <= V_AnoModelo
    where T1.modelo > V_0
     AND  T1.descricao like V_NomeVeiculo
     AND  T2.Nome like V_Fabricante
     AND  T4.TIPO_COMBUSTIVEL LIKE V_TipoCombustivel
    ORDER BY t1.DESCRICAO;


  END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
    Dbms_Output.Put_Line('entrou na exception');
       V_ERROS := V_Ret06 || 'Veículo não encontrado.' || V_Ret07;
       V_Erros := V_Ret01 || V_RET04  || V_Erros || V_RET05 || V_RET02;
       --
       Atualiza_erro(v_id_log, V_Erros);
       --
       RETURN V_Erros;
  END;

  IF (V_VEICULOS.COUNT = 0) THEN
       V_ERROS := V_Ret06 || 'Veículo não encontrado.' || V_Ret07;
       V_Erros := V_Ret01 || V_RET04  || V_Erros || V_RET05 || V_RET02;
       --
       Atualiza_erro(v_id_log, V_Erros);
       --
       RETURN V_Erros;
  END IF;

  V_Prod     := TO_Char(V_Produto);
  V_ProdNome := FWS001_GetProdName(V_Produto);
  V_XML  := '<Veiculos>';
  FOR i IN 1 .. V_VEICULOS.COUNT LOOP
    V_XML := V_XML || '<Veiculo><CodigoFabricante>'                 || To_Char(V_VEICULOS(i).Fabricante)
                   || '</CodigoFabricante><DescricaoFabricante>'    || V_VEICULOS(i).Nome
                   || '</DescricaoFabricante><CodigoVeiculo>'       || To_Char(V_VEICULOS(i).Modelo)
                   || '</CodigoVeiculo><DescricaoVeiculo>'          || V_VEICULOS(i).Descricao
                   || '</DescricaoVeiculo><TipoCombustivel>'        || V_VEICULOS(i).Combustivel
                   || '</TipoCombustivel><CodigoProduto>'           || V_Prod
                   || '</CodigoProduto><NomeProduto>'               || V_ProdNome
                   || '</NomeProduto><CodigoFIPE>'                  || REPLACE(V_VEICULOS(i).CD_FIPE,'-','')
                   || '</CodigoFIPE><NumeroPassageiros>'            || To_Char(V_VEICULOS(i).NumPassageiros)
                   || '</NumeroPassageiros><Categoria>'             || To_Char(V_VEICULOS(i).Categ_Tar1)
                   || '</Categoria></Veiculo>';

  END LOOP;


  V_XML := V_RET01 || V_XML || '</Veiculos><Erros/>' || V_RET02;
        --
        BEGIN
                --
                UPDATE  KIT0007_LOG_CNSLT_MODEL
                SET     dt_fim_log              =       SYSTIMESTAMP
                WHERE   id_LOG_CNSLT_model      =       v_id_log;
                --
                COMMIT;
                --
        EXCEPTION
                --
                WHEN    OTHERS  THEN
                        --
                        tms_gpa.erro (v_gpa ,' Erro no Atualiza Término: ' || SQLERRM);
                        tms_gpa.erro (v_gpa ,'v_id_log: ' || v_id_log);
                        tms_gpa.erro (v_gpa ,'P_Corretor: ' || P_Corretor);
                        --
        END;

  RETURN V_XML;

END;
/


CREATE OR REPLACE function fws105_consultamodelosmolicar(
   P_Corretor            IN VARCHAR2,
   P_Usuario             IN VARCHAR2,
   P_Produto             IN VARCHAR2,
   P_Molicar             IN VARCHAR2,
   P_AnoModelo           IN VARCHAR2,
   P_TipoCombustivel     IN VARCHAR2,
   P_DtVigencia          IN VARCHAR2,
   P_NumeroCotacaoMC     IN VARCHAR2
) return CLOB
IS

  type TVeiculosMolicar_REC  is record (
          NumPassageiros             tabela_veiculomodelo.NumPassageiros%type,
          Nome                       tabela_veiculofabric.Nome%type,
          Fabricante                 tabela_veiculomodelo.Fabricante%type,
          Modelo                     tabela_veiculomodelo.Modelo%type,
          Descricao                  tabela_veiculomodelo.Descricao%type,
          Categoria                  tabela_veiculomodelo.Categ_tar1%type,
          FIPE                       Real_DeParaFIPE.CD_fipe%type,
          Combustivel                REAL_ANOSAUTO.TIPO_COMBUSTIVEL%type
          --AnoAte                     REAL_ANOSAUTO.Anoate%type,
          --AnoDe                      REAL_ANOSAUTO.Anode%type
      );
  type TVeiculosMolicar_TAB  is table of TVeiculosMolicar_REC;
  V_Veiculos  TVeiculosMolicar_TAB;

  V_P VARCHAR2(2)  := 'P';
  V_Ret01  VARCHAR2(100)   := '<?xml version="1.0" encoding="ISO-8859-1"?><Retorno>';
  V_Ret02  VARCHAR2(100)   := '</Retorno>';
  V_Ret03  VARCHAR2(100)   := '<Veiculos/>';
  V_Ret04  VARCHAR2(100)   := '<Veiculos/><Erros>';
  V_Ret05  VARCHAR2(100)   := '</Erros>';
  V_Ret06  VARCHAR2(100)   := '<Mensagem>';
  V_Ret07  VARCHAR2(100)   := '</Mensagem>';
  V_Erros  VARCHAR(500)    := '';
  V_TipoCombustivel VARCHAR(10) := '%';
  V_Prod     VARCHAR(10) := '';
  V_ProdNome VARCHAR(20) := '';
  V_XML      VARCHAR2(4000);
  V_Corretor   Integer;
  V_Produto    Integer;
  V_AnoModelo  Integer;
  V_DtVigencia DATE;
  v_id_log      NUMBER(38);
  PRAGMA AUTONOMOUS_TRANSACTION;
  --
PROCEDURE       Atualiza_erro   (p_id_log       IN      NUMBER
                                ,p_msg_erro     IN      VARCHAR2)       IS
BEGIN
        --
        BEGIN
                --
                UPDATE  KIT0008_LOG_CNSLT_MODEL_MOLIC
                SET     dt_fim_log                      =       SYSTIMESTAMP,
                        ds_msg_erro_log                 =       p_msg_erro
                WHERE   id_LOG_CNSLT_model_molic        =       p_id_log;
                COMMIT;
                --
        EXCEPTION
                --
                WHEN    OTHERS  THEN
                        --
                        NULL;
                        --
        END;
        --
END     Atualiza_erro   ;

BEGIN
        -- Grava Log de Chamadas
        --
        BEGIN
                SELECT  kitsq0008_CNSLT_MODEL_MOLIC.NEXTVAL
                INTO    v_id_log
                FROM    dual;
                --
                INSERT  INTO    KIT0008_LOG_CNSLT_MODEL_MOLIC
                                (id_LOG_CNSLT_MODEL_MOLIC
                                ,dt_inico_log
                                ,cd_crtor
                                ,cd_usuro
                                ,cd_prdut
                                ,cd_molic
                                ,Aa_Model
                                ,Tp_Cmbst
                                ,dt_Inico_Vigen
                                ,Nr_Cotac_MC)
                        VALUES  (v_id_log
                                ,SYSTIMESTAMP
                                ,P_Corretor
                                ,P_Usuario
                                ,P_produto
                                ,p_molicar
                                ,P_AnoModelo
                                ,P_TipoCombustivel
                                ,P_DtVigencia
                                ,P_NumeroCotacaoMC);
                --
                COMMIT;
                --
        EXCEPTION
                --
                WHEN    OTHERS  THEN
                        NULL;
                --
        END;


  V_Corretor := FWS007_IsNumber(P_Corretor);
  V_Produto  := FWS007_IsNumber(P_Produto);

  V_XML :=  FWS004_CheckUser(V_Corretor, P_Usuario, V_Produto);

  if V_XML <> 'OK' then
     V_XML :=  V_RET01 || V_Ret03 || V_XML || V_RET02;
     Atualiza_erro(v_id_log, V_XML);
     RETURN V_XML;
  end if;

  V_AnoModelo  := FWS007_IsNumber(P_AnoModelo);
  V_DtVigencia := FWS008_IsDate(P_DtVigencia);

  IF V_DtVigencia = TO_DATE('01-01-0001', 'DD-MM-YYYY') then
    V_Erros := V_Erros || V_Ret06 || 'Data de inicio de vigencia nao informada ou invalida.' || V_Ret07;
  END IF;

  IF V_AnoModelo = 0 then
    V_Erros := V_Erros || V_Ret06 || 'É necessário informar o ano do veículo que deseja consultar.' || V_Ret07;
  END IF;


  IF (LENGTH(P_Molicar) = 0) or (TRIM(P_Molicar) IS NULL) then
      V_Erros := V_Erros || V_Ret06 || 'É necessário informar código molicar do veículo que deseja consultar.' || V_Ret07;
  END IF;


  IF LENGTH(V_Erros) > 0 THEN
        V_Erros := V_Ret01 || V_RET04  || V_Erros || V_RET05 || V_RET02;
        Atualiza_erro(v_id_log, V_Erros);
        RETURN V_Erros;
  END IF;

  -- Se Descricao do Veiculo existe....
  IF Length(P_TipoCombustivel) > 0 then
    V_TipoCombustivel := UPPER(P_TipoCombustivel);
  END IF;

  -- Consulta Tabela Molicar do SSV
  BEGIN

    SELECT DISTINCT
          T3.NumPassageiros AS NumPassageiros,
          T4.Nome AS Nome,
          T3.Fabricante AS Fabricante,
          T3.Modelo AS Modelo,
          T3.Descricao AS Descricao,
          T3.Categ_tar1 AS Categoria,
          T5.CD_FIPE AS FIPE,
          T6.TIPO_COMBUSTIVEL AS Combustivel
          --T6.ANOATE AS AnoAte,
          --T6.ANODE AS AnoDe
    BULK COLLECT INTO V_Veiculos
    FROM  SSV2203_TABEL_DE_PARA_MOLIC T1
    INNER JOIN SSV2201_VEICU T2
       ON T2.ID_VEICU = T1.ID_VEICU
    INNER JOIN tabela_veiculomodelo T3
       ON T3.modelo = T2.CD_MARCA_MODEL
      and T3.fabricante = T2.CD_FABRT
    INNER JOIN tabela_veiculofabric T4
       ON T4.Situacao = V_P
      AND T4.Fabricante = T3.fabricante
    INNER JOIN Real_DeParaFIPE T5
       ON T5.CD_FAB_REAL = T2.CD_FABRT
      AND T5.CD_MOD_REAL = T2.CD_MARCA_MODEL
    INNER JOIN REAL_ANOSAUTO T6
      ON T6.MODELO = T2.CD_MARCA_MODEL
     And T6.ANOATE >= V_AnoModelo
     And T6.ANODE  <= V_AnoModelo
     AND T6.TIPO_COMBUSTIVEL LIKE V_TipoCombustivel
    WHERE T1.CD_MARCA_MODEL_TABEL_VEICU = P_Molicar
      AND V_DtVigencia BETWEEN T1.DT_INICO_VIGEN AND T1.DT_FIM_VIGEN;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
    V_Erros :=  V_Ret01 || V_RET04  || V_Ret06 || 'Pesquisa de modelo molicar ' || P_Molicar || ', ano modelo ' || V_AnoModelo || ' e combustível ' || V_TipoCombustivel || ' não retornou resultado. Verifique dados informados. ' || V_Ret07 || V_RET05 || V_RET02;
    Atualiza_erro(v_id_log, V_Erros);
    RETURN V_Erros;
  END;

  IF (V_VEICULOS.COUNT = 0) THEN
    V_Erros :=  V_Ret01 || V_RET04  || V_Ret06 || 'Pesquisa de modelo molicar ' || P_Molicar || ', ano modelo ' || V_AnoModelo || ' e combustível ' || V_TipoCombustivel || ' não retornou resultado. Verifique dados informados. ' || V_Ret07 || V_RET05 || V_RET02;
    Atualiza_erro(v_id_log, V_Erros);
    RETURN V_Erros;
  END IF;

  V_Prod     := TO_Char(V_Produto);
  V_ProdNome := FWS001_GetProdName(V_Produto);
  V_XML  := '<Veiculos>';
  FOR i IN 1 .. V_VEICULOS.COUNT LOOP
    V_XML := V_XML || '<Veiculo><CodigoFabricante>'                 || To_Char(V_VEICULOS(i).Fabricante)
                   || '</CodigoFabricante><DescricaoFabricante>'    || V_VEICULOS(i).Nome
                   || '</DescricaoFabricante><CodigoVeiculo>'       || To_Char(V_VEICULOS(i).Modelo)
                   || '</CodigoVeiculo><DescricaoVeiculo>'          || V_VEICULOS(i).Descricao
                   || '</DescricaoVeiculo><TipoCombustivel>'        || V_VEICULOS(i).COMBUSTIVEL
                   || '</TipoCombustivel><CodigoProduto>'           || V_Prod
                   || '</CodigoProduto><NomeProduto>'               || V_ProdNome
                   || '</NomeProduto><CodigoFIPE>'                  || V_VEICULOS(i).FIPE
                   || '</CodigoFIPE><NumeroPassageiros>'            || To_Char(V_VEICULOS(i).NumPassageiros)
                   || '</NumeroPassageiros><CodigoMolicar>'         || P_Molicar
                   || '</CodigoMolicar><Categoria>'                 || To_Char(V_VEICULOS(i).Categoria)
                   || '</Categoria></Veiculo>';

  END LOOP;


  V_XML := V_RET01 || V_XML || '</Veiculos><Erros/>' || V_RET02;
        --
        BEGIN
                --
                UPDATE  KIT0008_LOG_CNSLT_MODEL_MOLIC
                SET     dt_fim_log                      =       SYSTIMESTAMP
                WHERE   id_LOG_CNSLT_model_molic        =       v_id_log;
                --
                COMMIT;
                --
        EXCEPTION
                --
                WHEN    OTHERS  THEN
                        --
                        NULL;
                        --
        END;
        --
  RETURN V_XML;

END;
/


CREATE OR REPLACE function fws106_consultaqbr(
   P_Corretor        IN VARCHAR2,
   P_Usuario         IN VARCHAR2,
   P_Produto         IN VARCHAR2,
   P_DtVigencia      IN VARCHAR2,
   P_TipoVeiculo     IN VARCHAR2,
   P_Categoria       IN VARCHAR2,
   P_TipoPessoa      IN VARCHAR2,
   P_TipoUsoVeiculo  IN VARCHAR2,
   P_CEP             IN VARCHAR2,
   P_NumeroCotacaoMC IN VARCHAR2
) return CLOB
IS
  V_0  INTEGER := 0;
  V_1  INTEGER := 1;
  V_10 INTEGER := 10;
  V_24 INTEGER := 24;
  V_25 INTEGER := 25;
  V_50 INTEGER := 50;
  V_Conta INTEGER;
  V_Regiao INTEGER;
  V_CanalVenda INTEGER;
  V_VIGENCIA INTEGER;
  V_Agrupamento INTEGER;
  V_Versao INTEGER;
  V_Aux1 INTEGER;
  V_Aux2 INTEGER;
  V_COBERTURA INTEGER;
  V_Return VARCHAR2(200);
  V_Ret01  VARCHAR2(100) := '<?xml version="1.0" encoding="ISO-8859-1"?><Retorno>';
  V_Ret02  VARCHAR2(20) := '</Retorno>';
  V_Ret03  VARCHAR2(20) := '<QBR/>';
  V_Ret04  VARCHAR2(20) := '<QBR/><Erros>';
  V_Ret05  VARCHAR2(20) := '</Erros>';
  V_Ret06  VARCHAR2(20) := '<Mensagem>';
  V_Ret07  VARCHAR2(20) := '</Mensagem>';
  V_Erros  VARCHAR(500) := '';
  V_QbrId  VARCHAR2(10);
  V_XML    CLOB;
  V_Corretor    Integer;
  V_Produto     Integer;
  V_DtVigencia  DATE;
  V_TipoVeiculo Integer;
  V_Categoria   Integer;
  V_CEP         Integer;
  v_id_log      NUMBER(38);
  PRAGMA AUTONOMOUS_TRANSACTION;
  --
PROCEDURE       Atualiza_erro   (p_id_log       IN      NUMBER
                                ,p_msg_erro     IN      VARCHAR2)       IS
BEGIN
        --
        BEGIN
                --
                UPDATE  KIT0009_LOG_CNSLT_QBR
                SET     dt_fim_log              =       SYSTIMESTAMP,
                        ds_msg_erro_log         =       p_msg_erro
                WHERE   id_LOG_CNSLT_qbr        =       p_id_log;
                --
                COMMIT;
                --
        EXCEPTION
                --
                WHEN    OTHERS  THEN
                        --
                        NULL;
                        --
        END;
        --
END     Atualiza_erro   ;

begin
        -- Grava Log de Chamadas
        --
        BEGIN
                SELECT  kitsq0009_CNSLT_qbr.NEXTVAL
                INTO    v_id_log
                FROM    dual;
                --
                INSERT  INTO    KIT0009_LOG_CNSLT_QBR
                                (id_log_cnslt_qbr
                                ,dt_inico_log
                                ,cd_crtor
                                ,cd_usuro
                                ,cd_prdut
                                ,dt_Inico_Vigen
                                ,tp_veicu
                                ,cd_catgo
                                ,tp_pesoa
                                ,tp_uso_veicu
                                ,cd_cep
                                ,Nr_Cotac_MC)
                        VALUES  (v_id_log
                                ,SYSTIMESTAMP
                                ,P_Corretor
                                ,P_Usuario
                                ,p_produto
                                ,P_DtVigencia
                                ,P_TipoVeiculo
                                ,P_Categoria
                                ,P_TipoPessoa
                                ,P_TipoUsoVeiculo
                                ,P_CEP
                                ,P_NumeroCotacaoMC);
                --
                COMMIT;
                --
        EXCEPTION
                --
                WHEN    OTHERS  THEN
                        NULL;
                --
        END;
        --
  V_Corretor := FWS007_IsNumber(P_Corretor);
  V_Produto  := FWS007_IsNumber(P_Produto);

  V_XML :=  FWS004_CheckUser(V_Corretor, P_Usuario, V_Produto);

  if V_XML <> 'OK' then
     V_Return :=  V_RET01 || V_Ret03 || V_XML || V_RET02;
     Atualiza_erro(v_id_log, v_return);
     RETURN V_Return;
  end if;

  V_DtVigencia  := FWS008_IsDate(P_DtVigencia);
  V_TipoVeiculo := FWS007_IsNumber(P_TipoVeiculo);
  V_Categoria   := FWS007_IsNumber(P_Categoria);
  V_CEP         := FWS009_IsCEP(P_CEP);

  IF V_DtVigencia = TO_DATE('01-01-0001', 'DD-MM-YYYY') then
    V_Erros := V_Erros || V_Ret06 || 'Data de inicio de vigencia nao informada ou invalida.' || V_Ret07;
  END IF;

  IF V_TipoVeiculo = 0 then
    V_Erros := V_Erros || V_Ret06 || 'É necessário informar o veículo que deseja consultar.' || V_Ret07;
  END IF;

  IF V_Categoria = 0 then
    V_Erros := V_Erros || V_Ret06 || 'É necessário informar a categoria que deseja consultar.' || V_Ret07;
  END IF;

  IF V_CEP = 0 then
    V_Erros := V_Erros || V_Ret06 || 'É necessário informar o CEP que deseja consultar.' || V_Ret07;
  END IF;

  IF LENGTH(V_Erros) > 0 THEN
    V_Erros := V_Ret01 || V_RET04  || V_Erros || V_RET05 || V_RET02;
        Atualiza_erro(v_id_log, V_Erros);
    RETURN V_Erros;
  END IF;


  -- Verifica Tipo de Veiculo
  SELECT COUNT(VALOR) INTO V_CONTA FROM MULT_PRODUTOSTABRG
  WHERE PRODUTO = V_10
  AND TABELA = V_24
  AND chave1 = V_TipoVeiculo;
  IF (V_CONTA = 0) then
     V_Return :=  V_RET01 || V_RET03  || V_Ret06 || 'Tipo de Veiculo Invalido' || V_Ret07 || V_RET05 || V_RET02;
     Atualiza_erro(v_id_log, V_return);
     RETURN V_Return;
  end if;

  -- Obtem Regiao para respostas
  BEGIN
    SELECT T2.VALOR4 INTO V_REGIAO FROM MULT_PRODUTOSTABRG T1
    LEFT JOIN MULT_PRODUTOSTABRG T2
      ON T2.PRODUTO = V_PRODUTO
     AND T2.TABELA = V_25
     AND T2.valor5 = T1.VALOR
    WHERE T1.PRODUTO = V_PRODUTO
      AND T1.TABELA = V_50
      AND T1.chave1 = V_1
      AND V_DtVigencia between T1.DT_INICO_VIGEN and T1.DT_FIM_VIGEN
      AND V_DtVigencia between T2.DT_INICO_VIGEN and T2.DT_FIM_VIGEN
      AND T1.chave2 <= V_CEP
      AND T1.chave3 >= V_CEP
      AND ROWNUM = 1;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     V_Return :=  V_RET01 || V_RET03  || V_Ret06 || 'CEP Invalido' || V_Ret07 || V_RET05 || V_RET02;
     Atualiza_erro(v_id_log, V_return);
     RETURN V_Return;
  END;

  -- Obtem Vigencia (1 - Corrente 2 - Anterior)
  V_VIGENCIA := FWS002_GetVigencia(V_Produto, V_DtVigencia);
  if (V_Vigencia  = 0) then
     V_Return :=  V_RET01 || V_RET03  || V_Ret06 || 'Data de Inicio de Vigencia invalido' || V_Ret07 || V_RET05 || V_RET02;
     Atualiza_erro(v_id_log, V_return);
     RETURN V_Return;
  end if;


  -- Obtem Agrupamento
  BEGIN
    select agrupamento into V_Agrupamento from   MULT_PRODUTOSQBRAGRUPREG
    where produto = V_PRODUTO
    and vigencia  = V_VIGENCIA
    and regiao    = V_REGIAO
    and V_DtVigencia between DT_INICO_VIGEN and DT_FIM_VIGEN;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     V_Return :=  V_RET01 || V_RET03  || V_Ret06 || 'Agrupamento nao encontrado' || V_Ret07 || V_RET05 || V_RET02;
     Atualiza_erro(v_id_log, V_return);
     RETURN V_Return;
  END;

  -- Obtem Canal de Venda
  V_CanalVenda := FWS003_CanalVendas(P_Corretor);

  BEGIN
    SELECT CODIGO, VERSAO, CD_TIPO_VEICU, CATEGVEIC
    INTO V_QbrId, V_Versao, V_Aux1, V_Aux2
    FROM MULT_PRODUTOSQBRGRUPOS T1
    WHERE  T1.PRODUTO    = V_Produto
      AND  T1.VIGENCIA   = V_Vigencia
      AND  T1.CANALVENDA = V_CanalVenda
      AND  T1.TIPOPROD   = 'T' -- Constante
      AND  T1.TIPOPESSOA = P_TipoPessoa
      AND  (
              (
                         (T1.CATEGVEIC = V_0 AND CD_TIPO_VEICU = V_0)
                     OR  (T1.CATEGVEIC = V_0 AND CD_TIPO_VEICU = V_TipoVeiculo)
               ) OR (
                        (T1.CATEGVEIC = V_Categoria AND T1.CD_TIPO_VEICU = V_0)
                     OR (T1.CATEGVEIC = V_0 AND T1.CD_TIPO_VEICU = V_0)
               )
           )
      AND  T1.TIPOUSOVEIC = P_TipoUsoVeiculo
      AND  V_DtVigencia  BETWEEN T1.DT_INICO_VIGEN AND T1.DT_FIM_VIGEN
      AND  ROWNUM = 1
      order by CD_TIPO_VEICU, CATEGVEIC;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     V_Return :=  V_RET01 || V_RET03  || V_Ret06 || 'QBR nao encontrado' || V_Ret07 || V_RET05 || V_RET02;
     Atualiza_erro(v_id_log, V_return);
     RETURN V_Return;
  END;


  -- Para Automovel usar Colizao Incendio e Roubo
  V_COBERTURA := 17;

  V_XML := FWS006_GetQbrXml(V_PRODUTO, V_VIGENCIA, V_VERSAO, V_Agrupamento, V_COBERTURA, V_QbrId, V_DTVIGENCIA );

        BEGIN
                --
                UPDATE  KIT0009_LOG_CNSLT_QBR
                SET     dt_fim_log              =       SYSTIMESTAMP
                WHERE   id_log_cnslt_qbr        =       v_id_log;
                --
                COMMIT;
                --
        EXCEPTION
                --
                WHEN    OTHERS  THEN
                        --
                        NULL;
                        --
        END;

  RETURN V_RET01 || V_XML || V_RET02;

END;
/


CREATE OR REPLACE function fws107_consultatipoveiculo(
   P_Corretor        IN VARCHAR2,
   P_Usuario         IN VARCHAR2,
   P_Produto         IN VARCHAR2,
   P_DtVigencia      IN VARCHAR2,
   P_NumeroCotacaoMC IN VARCHAR2
) return VARCHAR2
IS
  type TABREG_REC  is record ( chave1 MULT_PRODUTOSTABRG.CHAVE1%type,
                               texto  MULT_PRODUTOSTABRG.TEXTO%type);
  type TABREG_TAB  is table of TABREG_REC;
  V_TABREG TABREG_TAB;
  V_10 INTEGER := 10;
  V_24 INTEGER := 24;
  V_Ret01  VARCHAR2(100) := '<?xml version="1.0" encoding="ISO-8859-1"?><Retorno>';
  V_Ret02  VARCHAR2(100) := '</Retorno>';
  V_Ret03  VARCHAR2(100) := '<Tipos/>';
  V_Ret04  VARCHAR2(100) := '<Tipos/><Erros>';
  V_Ret05  VARCHAR2(100) := '</Erros>';
  V_Ret06  VARCHAR2(20)  := '<Mensagem>';
  V_Ret07  VARCHAR2(20)  := '</Mensagem>';
  V_Erros  VARCHAR(500)  := '';
  V_XML    VARCHAR2(2000);
  V_Corretor    Integer;
  V_Produto     Integer;
  V_DtVigencia  DATE;
  v_id_log      NUMBER(38);
  PRAGMA AUTONOMOUS_TRANSACTION;
  --
PROCEDURE       Atualiza_erro   (p_id_log       IN      NUMBER
                                ,p_msg_erro     IN      VARCHAR2)       IS
BEGIN
        --
        BEGIN
                --
                UPDATE  kit0006_log_cnslt_tp_veicu
                SET     dt_fim_log                      =       SYSTIMESTAMP,
                        ds_msg_erro_log                 =       p_msg_erro
                WHERE   id_LOG_CNSLT_tp_veicu           =       p_id_log;
                --
                COMMIT;
                --
        EXCEPTION
                --
                WHEN    OTHERS  THEN
                        --
                        NULL;
                        --
        END;
        --
END     Atualiza_erro   ;

begin
        -- Grava Log de Chamadas
        --
        BEGIN
                SELECT  kitsq0006_CNSLT_tp_veicu        .NEXTVAL
                INTO    v_id_log
                FROM    dual;
                --
                INSERT  INTO    kit0006_log_cnslt_tp_veicu
                                (id_LOG_CNSLT_tp_veicu
                                ,dt_inico_log
                                ,cd_crtor
                                ,cd_usuro
                                ,dt_Inico_Vigen
                                ,cd_prdut
                                ,Nr_Cotac_MC)
                        VALUES  (v_id_log
                                ,SYSTIMESTAMP
                                ,P_Corretor
                                ,P_Usuario
                                ,P_DtVigencia
                                ,p_produto
                                ,P_NumeroCotacaoMC);
                --
                COMMIT;
                --
        EXCEPTION
                --
                WHEN    OTHERS  THEN
                        NULL;
                --
        END;
        --

  V_Corretor := FWS007_IsNumber(P_Corretor);
  V_Produto  := FWS007_IsNumber(P_Produto);

  V_XML :=  FWS004_CheckUser(V_Corretor, P_Usuario, V_Produto);

  if V_XML <> 'OK' then
     V_XML :=  V_RET01 || V_Ret03 || V_XML || V_RET02;
     Atualiza_erro(v_id_log, v_xml);
     RETURN V_XML;
  end if;

  V_DtVigencia  := FWS008_IsDate(P_DtVigencia);

  IF V_DtVigencia = TO_DATE('01-01-0001', 'DD-MM-YYYY') then
    V_Erros := V_RET01 || V_RET04 || V_RET06 || 'Data de inicio de vigencia não informada ou inválida.'|| V_RET07 || V_RET05 || V_RET02;
     Atualiza_erro(v_id_log, V_Erros);
     RETURN V_Erros;
  END IF;


  BEGIN
    SELECT chave1, texto
    BULK COLLECT INTO V_TABREG
    FROM MULT_PRODUTOSTABRG
    WHERE PRODUTO = V_10
      AND TABELA  = V_24
      AND V_DtVigencia between dt_inico_vigen and dt_fim_vigen
    ORDER BY texto;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     V_Erros :=  V_RET01 || V_RET04 || V_RET06 || 'Tipo de veiculo ou Vigencia Inválido' || V_RET07 || V_RET05 || V_RET02;
     Atualiza_erro(v_id_log, V_Erros);
     RETURN V_Erros;
  END;

  IF V_TABREG.COUNT = 0 THEN
     V_Erros :=  V_RET01 || V_RET04 || V_RET06 || 'Tipo de veiculo ou Vigencia Inválido' || V_RET07 || V_RET05 || V_RET02;
     Atualiza_erro(v_id_log, V_Erros);
     RETURN V_Erros;
  END IF;


  V_XML := '<Tipos>';
  FOR i IN 1 .. V_TABREG.COUNT LOOP
    V_XML := V_XML || '<Tipo><Codigo>'       || To_Char(V_TABREG(i).chave1)
                   || '</Codigo><Descricao>' || V_TABREG(i).texto
                   || '</Descricao></Tipo>';

  END LOOP;

  V_XML := V_RET01 || V_XML || '</Tipos><Erros/>' || V_RET02;
        BEGIN
                --
                UPDATE  kit0006_log_cnslt_tp_veicu
                SET     dt_fim_log                      =       SYSTIMESTAMP
                WHERE   id_LOG_CNSLT_tp_veicu           =       v_id_log;
                --
                COMMIT;
                --
        EXCEPTION
                --
                WHEN    OTHERS  THEN
                        --
                        NULL;
                        --
        END;

  RETURN V_XML;

end;
/


CREATE OR REPLACE function fws108_consultavalormercado(
   P_Corretor        IN VARCHAR2,
   P_Usuario         IN VARCHAR2,
   P_Veiculo         IN VARCHAR2,
   P_AnoModelo       IN VARCHAR2,
   P_TipoCombustivel IN VARCHAR2,
   P_Cobertura       IN VARCHAR2,
   P_ZeroKm          IN VARCHAR2,
   P_CEP             IN VARCHAR2,
   P_IniVigencia     IN VARCHAR2,
   P_Fabricante      IN VARCHAR2,
   P_NumeroCotacaoMC IN VARCHAR2
) return VARCHAR2
IS
  V_1  INTEGER := 1;
  V_10 INTEGER := 10;
  -- V_24 INTEGER := 24;
  V_F  VARCHAR2(1) := 'F';
  V_Ret01  VARCHAR2(100) := '<?xml version="1.0" encoding="ISO-8859-1"?><Retorno>';
  V_Ret02  VARCHAR2(100) := '</Retorno>';
  V_Ret03  VARCHAR2(100) := '<ValorMercado><Valor>0</Valor></ValorMercado>';
  V_Ret04  VARCHAR2(100) := '<ValorMercado><Valor>0</Valor></ValorMercado><Erros>';
  V_Ret05  VARCHAR2(100) := '</Erros>';
  V_Ret06  VARCHAR2(100) := '<Mensagem>';
  V_Ret07  VARCHAR2(100) := '</Mensagem>';
  V_Erros  VARCHAR2(500) := '';
  V_ZeroKm VARCHAR2(10)  := '';
  V_Descricao VARCHAR2(100);
  V_CdFabricante INTEGER;
  V_ValorMedio  real_cotasauto.valor_medio%type;
  V_XML          VARCHAR2(2000);
  V_Corretor     Integer;
  V_CalcCorr     Integer;
  V_Veiculo      Integer;
  V_AnoModelo    Integer;
  -- V_Cobertura    Integer; -- Nao mais Utiliado
  V_IniVigencia  Date;
  V_SysDate      Date;
  V_DATACALCULO  Date;
  V_DATAVALIDADE Date;
  V_Fabricante   Integer;
  V_Cotacao      Integer;
  v_id_log       NUMBER(38);
  --
  PRAGMA AUTONOMOUS_TRANSACTION;
  --
PROCEDURE       Atualiza_erro   (p_id_log       IN      NUMBER
                                ,p_msg_erro     IN      VARCHAR2)       IS
BEGIN
        --
        BEGIN
                --
                UPDATE  KIT0005_LOG_CNSLT_VALOR_MRCDO
                SET     dt_fim_log                      =       SYSTIMESTAMP,
                        ds_msg_erro_log                 =       p_msg_erro
                WHERE   id_LOG_CNSLT_VALOR_MRCDO        =       p_id_log;
                --
                COMMIT;
                --
        EXCEPTION
                --
                WHEN    OTHERS  THEN
                        --
                        NULL;
                        --
        END;
        --
END     Atualiza_erro   ;

BEGIN

        --
        -- Grava Log de Chamadas
        --
        BEGIN
                SELECT  kitsq0005_CNSLT_VALOR_MRCDO.NEXTVAL
                INTO    v_id_log
                FROM    dual;
                --
                INSERT  INTO    KIT0005_LOG_CNSLT_VALOR_MRCDO
                                (id_LOG_CNSLT_VALOR_MRCDO
                                ,dt_inico_log
                                ,cd_crtor
                                ,cd_usuro
                                ,Cd_Veicu
                                ,Aa_Model
                                ,Tp_Cmbst
                                ,Cd_Cobtu
                                ,ic_Zero_Km
                                ,cd_CEP
                                ,dt_Inico_Vigen
                                ,Cd_Fabrt
                                ,Nr_Cotac_MC)
                        VALUES  (v_id_log
                                ,SYSTIMESTAMP
                                ,P_Corretor
                                ,P_Usuario
                                ,P_Veiculo
                                ,P_AnoModelo
                                ,P_TipoCombustivel
                                ,P_Cobertura
                                ,P_ZeroKm
                                ,P_CEP
                                ,P_IniVigencia
                                ,P_Fabricante
                                ,P_NumeroCotacaoMC);
                --
                COMMIT;
                --
        EXCEPTION
                --
                WHEN    OTHERS  THEN
                        NULL;
                --
        END;
        --
  V_Corretor := FWS007_IsNumber(P_Corretor);

  V_XML :=  FWS004_CheckUser(V_Corretor, P_Usuario, V_10);

  if V_XML <> 'OK' then
     V_XML :=  V_RET01 || V_Ret03 || V_XML || V_RET02;
     --
     Atualiza_erro(v_id_log, V_XML);
     --
     RETURN V_XML;
  end if;

  V_Veiculo     := FWS007_IsNumber(P_Veiculo);
  V_AnoModelo   := FWS007_IsNumber(P_AnoModelo);
  -- V_Cobertura   := FWS007_IsNumber(P_Cobertura); -- Nao mais Utiliado
  V_IniVigencia := FWS008_IsDate(P_IniVigencia);
  V_Fabricante  := FWS007_IsNumber(P_Fabricante);

  IF V_IniVigencia = TO_DATE('01-01-0001', 'DD-MM-YYYY') then
    V_Erros := V_Erros || V_Ret06 || 'Data de inicio de vigencia nao informada ou invalida.' || V_Ret07;
  END IF;

  V_SysDate := Trunc(SysDate);
  V_Cotacao := FWS007_IsNumber(P_NumeroCotacaoMC);
  -- Verifica se o numero da Cotacao existe
  IF (V_Cotacao > 0) THEN
     BEGIN
        -- Pesquisa na Base da Data de Calculo e a Validade da Proposta
        SELECT T1.DATACALCULO, T1.DATAVALIDADE, T3.Divisao_Superior
        INTO V_DATACALCULO, V_DATAVALIDADE, V_CalcCorr
        FROM MULT_CALCULO T1
        INNER JOIN MULT_CALCULODIVISOES T2
           ON T2.CALCULO = T1.CALCULO
          AND T2.NIVEL   = V_1
        INNER JOIN TABELA_DIVISOES T3
           ON T3.Divisao = T2.Divisao
        WHERE T1.CALCULO =  V_Cotacao;
        -- Verifica se o Corretor do Calculo e o mesmo da Solicitacao
        IF (V_CalcCorr is not NULL) and (V_CalcCorr = V_Corretor) THEN
           --  Se a Cotacao existe e as data de calculo e validade sao validas
           IF (V_DATACALCULO  IS NOT NULL) AND  -- Valida Data de Calculo
              (V_DATAVALIDADE IS NOT NULL) AND  -- Valida Validade da Proposta
              (Trunc(V_DATAVALIDADE) >= V_SysDate) THEN -- Valida Regra
              V_IniVigencia := TRUNC(V_DATACALCULO);
           ELSE
              V_Cotacao := 0;
           END IF;
        ELSE
           V_Cotacao := 0;
        END IF;
     EXCEPTION
          WHEN NO_DATA_FOUND THEN
             V_Cotacao := 0;
     END;
  ELSE
     V_Cotacao := 0;
  END IF;

  -- Se nao foi possivel utilizar a data de calculo da cotacao, usar a data corrente
  IF (V_Cotacao = 0) THEN
     V_IniVigencia := V_SysDate;
  END IF;

  IF (V_Veiculo  = 0) THEN
     V_ERROs :=  V_RET06  || 'Código do veículo não informado.' || V_RET07;
  END IF;

  IF (V_AnoModelo  = 0) THEN
     V_ERROs :=  V_RET06  || 'O ano modelo do veículo não informado.' || V_RET07;
  END IF;

  IF (Length(P_TipoCombustivel) = 0) THEN
     V_ERROs :=  V_RET06  || 'Tipo de combustível não informado.' || V_RET07;
  END IF;

  IF (V_Fabricante = 0) THEN
     V_ERROs :=  V_RET06  || 'Código do fabricante não informado.' || V_RET07;
  END IF;

  IF (Length(P_ZeroKm) = 0) THEN
     V_ERROs :=  V_RET06  || 'Zero Km não informado.' || V_RET07;
  END IF;

  V_ZeroKm := Upper(P_ZeroKm);

  IF (V_ZeroKm <> 'N') AND (V_ZeroKm <> 'S') THEN
     V_ERROs :=  V_RET06  || 'Zero Km informado "' || P_ZeroKm || '" invalido (N/S)' || V_RET07;
  END IF;

  IF (Length(P_CEP) = 0) THEN
     V_ERROs :=  V_RET06  || 'CEP não informado.' || V_RET07;
  END IF;
  --Dbms_Output.Put_Line('antes do select tabela_veiculomodelo: ' || v_veiculo);
  BEGIN
    select Descricao, Fabricante
    INTO V_Descricao, V_CdFabricante
    from tabela_veiculomodelo
    where MODELO = V_Veiculo;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     V_ERROs :=  V_RET06  || 'Código veículo ' || TO_Char(V_Veiculo) || ' invalido.' || V_RET07;
     --Dbms_Output.Put_Line('antes do return' || v_xml);
        --
        V_ERROs := V_Ret01 || V_RET04  || V_Erros || V_RET05 || V_RET02;
        Atualiza_erro(v_id_log, V_ERROs);
        --
        RETURN V_ERROs;
  END;
  --Dbms_Output.Put_Line('antes do length');
  IF LENGTH(V_Erros) > 0 THEN
        V_ERROS := V_Ret01 || V_RET04  || V_Erros || V_RET05 || V_RET02;
        --
        Atualiza_erro(v_id_log, V_ERROS);
        --
        RETURN V_ERROS;
  END IF;

  --Dbms_Output.Put_Line('antes do select principal');
  BEGIN
    SELECT T1.valor_medio
    INTO V_ValorMedio
    FROM real_cotasauto T1
    where  T1.TIPO_TABELA = V_F
      and  T1.COD_MODELO  = V_Veiculo
      and  T1.COD_FABRIC  = V_CdFabricante
      and  T1.ANO_MODELO  = V_AnoModelo
      AND  T1.IC_ZERO_KM  = P_ZeroKm
      and  T1.combustivel = P_TipoCombustivel
      and  V_IniVigencia between T1.dt_inico_vigen and T1.dt_fim_vigen;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     V_ERROS :=  V_RET06  || 'Não existe cotação FIPE nem MOLICAR para o Veículo ' || V_Descricao
                          || ' no ano modelo ' || TO_Char(V_AnoModelo) || '.' || V_RET07;
     V_ERROS :=  V_Ret01 || V_RET04  || V_Erros || V_RET05 || V_RET02;
        --
        Atualiza_erro(v_id_log, V_ERROs);
        --
     RETURN V_ERROS;
  END;

  V_XML := '<ValorMercado><Valor>' || TO_Char(V_ValorMedio) || '</Valor></ValorMercado><Erros/>';

  V_XML := V_RET01 || V_XML || V_RET02;
  --
        BEGIN
                --
                UPDATE  KIT0005_LOG_CNSLT_VALOR_MRCDO
                SET     dt_fim_log                      =       SYSTIMESTAMP,
                        DS_MSG_ERRO_LOG                 =       V_XML
                WHERE   id_LOG_CNSLT_VALOR_MRCDO        =       v_id_log;
                --
                COMMIT;
                --
        EXCEPTION
                --
                WHEN    OTHERS  THEN
                        --
                        NULL;
                        --
        END;

  RETURN V_XML;

end;
/


CREATE OR REPLACE function fws109_Calcular_Entrada(
P_Corretor              IN VARCHAR2,
P_Usuario               IN VARCHAR2,
P_XmlEnvio              IN CLOB,
P_CodigoOperadora       IN VARCHAR2,
p_NomeMaquina           IN VARCHAR2
) return VARCHAR2
IS
        --
        v_id_log      NUMBER(38);
        --
        PRAGMA AUTONOMOUS_TRANSACTION;
        --
        v_gpa         NUMBER;
        --
BEGIN
        --
        -- Grava Log de Chamadas
        --
        -- TO-DO: alterar o nome da sequence e fazer insert na base correta
        --
        BEGIN
                SELECT  kitsq0013_CALCR.NEXTVAL
                INTO    v_id_log
                FROM    dual;
                --
        EXCEPTION
                --
                WHEN    OTHERS  THEN
                        --
                        v_id_log        :=      0;
                        --
                        SELECT  valor
                        INTO    v_gpa
                        FROM    TABELA_CONFIGURACOES_KCW
                        WHERE   PARAMETRO       =       'GPA_LOG_WS';
                        --
                        tms_gpa.erro (v_gpa ,'fws109_Calcular_Entrada Erro na sequence : ' || SQLERRM);
                        tms_gpa.erro (v_gpa ,'v_id_log: ' || v_id_log);
                        tms_gpa.erro (v_gpa ,'P_Corretor: ' || P_Corretor);

                        -- to-do: gravar gpa, enviar e-mail(?)
                --
        END;
        --
        BEGIN
                INSERT  INTO    KIT0013_LOG_CALCR
                                (id_log_calcr
                                ,dt_inico_log
                                ,cd_usuro
                                ,cd_crtor
                                ,cd_senha_opeda
                                ,cd_prdut
                                ,nr_mtcal
                                ,Nr_Cotac_MC
                                ,Nm_MQUNA
                                ,xml_entr)
                        VALUES  (v_id_log
                                ,SYSTIMESTAMP
                                ,P_Usuario
                                ,P_Corretor
                                ,P_CodigoOperadora   -- cd_senha_opeda
                                ,NULL   -- cd_prdut
                                ,NULL   -- nr_mtcal
                                ,NULL   -- nr_cotac_mc
                                ,p_NomeMaquina
                                ,P_XmlEnvio
                                );
                --
        EXCEPTION
                --
                WHEN    OTHERS  THEN
                        --
                        SELECT  valor
                        INTO    v_gpa
                        FROM    TABELA_CONFIGURACOES_KCW
                        WHERE   PARAMETRO       =       'GPA_LOG_WS';
                        --
                        tms_gpa.erro (v_gpa ,'fws109_Calcular_Entrada Erro no Atualiza_erro: ' || SQLERRM);
                        tms_gpa.erro (v_gpa ,'v_id_log: ' || v_id_log);
                        tms_gpa.erro (v_gpa ,'P_Corretor: ' || P_Corretor);

                --
        END;
        --
        COMMIT;
        --

  RETURN To_Char(v_id_log);

end;
/


CREATE OR REPLACE function fws110_Calcular_Saida(
P_Id_log        IN NUMBER,
P_XmlRetorno    IN CLOB
) return VARCHAR2
IS
        --
        v_id_log      NUMBER(38);
        --
        PRAGMA AUTONOMOUS_TRANSACTION;
        --
BEGIN
        --
        -- Grava Log de Chamadas
        -- Grava Log de Chamadas
        --
        -- TO-DO: fazer update na tabela de log
        --        se der certo, retornar 0;
        --        se der erro, retornar codigo diferente de 0.
        --
        BEGIN
                UPDATE  kit0013_log_calcr
                SET     xml_saida       =       P_XmlRetorno,
                        dt_fim_log      =       SYSTIMESTAMP
                WHERE   id_log_calcr    =       P_Id_log;
                --
        EXCEPTION
                --
                WHEN    OTHERS  THEN
                        --
                        RETURN  '1';
                --
        END;
        --
        COMMIT;

  RETURN '0';

end;
/


CREATE OR REPLACE function fws111_Aplicar_CC_Entrada(
P_Corretor              IN VARCHAR2,
P_Usuario               IN VARCHAR2,
P_NumeroCalculo         IN VARCHAR2,
p_CodigoProduto         IN VARCHAR2,
p_CodigoModalidade      IN VARCHAR2,
p_ValorDescontoCC       IN VARCHAR2,
p_valorAgravoCC         IN VARCHAR2,
p_NomeMaquina           IN VARCHAR2
) return VARCHAR2
IS
        --
        v_id_log      NUMBER(38);
        --
        PRAGMA AUTONOMOUS_TRANSACTION;
        --
BEGIN
        --
        -- Grava Log de Chamadas
        --
        -- TO-DO: alterar o nome da sequence e fazer insert na base correta
        --
        BEGIN
                SELECT  kitsq0021_aplic_cc.NEXTVAL
                INTO    v_id_log
                FROM    dual;
                --
        EXCEPTION
                --
                WHEN    OTHERS  THEN
                        --
                        v_id_log        :=      0;
                        -- to-do: gravar gpa, enviar e-mail(?)
                --
        END;
        --
        BEGIN
                INSERT  INTO    KIT0021_LOG_APLIC_CC
                                (id_log_aplic_cc
                                ,dt_inico_log
                                ,cd_usuro
                                ,cd_crtor
                                ,nr_mtcal
                                ,Nm_MQUNA
                                ,cd_prdut
                                ,cd_modal
                                ,vl_desct_cc
                                ,vl_agrav_cc
                                )
                        VALUES  (v_id_log
                                ,SYSTIMESTAMP
                                ,P_Usuario
                                ,P_Corretor
                                ,P_NumeroCalculo        -- nr_mtcal
                                ,p_NomeMaquina
                                ,p_CodigoProduto
                                ,p_CodigoModalidade
                                ,p_ValorDescontoCC
                                ,p_valorAgravoCC
                                );
                --
        EXCEPTION
                --
                WHEN    OTHERS  THEN
                        NULL;
                --
        END;
        --
        COMMIT;

  RETURN To_Char(v_id_log);

end;
/


CREATE OR REPLACE function fws112_Aplicar_CC_Saida(
P_Id_log        IN NUMBER,
P_XmlRetorno    IN CLOB
) return VARCHAR2
IS
        --
        v_id_log      NUMBER(38);
        --
        PRAGMA AUTONOMOUS_TRANSACTION;
        --
BEGIN
        --
        -- Grava Log de Chamadas
        --
        -- TO-DO: fazer update na tabela de log
        --        se der certo, retornar 0;
        --        se der erro, retornar codigo diferente de 0.
        --
        BEGIN
                UPDATE  KIT0021_LOG_APLIC_CC
                SET     xml_saida       =       P_XmlRetorno,
                        dt_fim_log      =       SYSTIMESTAMP
                WHERE   id_log_aplic_cc =       P_Id_log;
                --
        EXCEPTION
                --
                WHEN    OTHERS  THEN
                        --
                        RETURN  '1';
                --
        END;
        --
        COMMIT;

  RETURN '0';

end;
/


CREATE OR REPLACE function fws113_Efetivar_Entrada(
P_Corretor              IN VARCHAR2,
P_Usuario               IN VARCHAR2,
p_XmlEnvio              IN LONG,
P_NumeroCalculo         IN VARCHAR2,
p_NomeMaquina           IN VARCHAR2
) return VARCHAR2
IS
        --
        v_id_log      NUMBER(38);
        --
        PRAGMA AUTONOMOUS_TRANSACTION;
        --
BEGIN
        --
        -- Grava Log de Chamadas
        --
        -- TO-DO: alterar o nome da sequence e fazer insert na base correta
        --
        BEGIN
                SELECT  kitsq0014_EFVAR.NEXTVAL
                INTO    v_id_log
                FROM    dual;
                --
        EXCEPTION
                --
                WHEN    OTHERS  THEN
                        --
                        v_id_log        :=      0;
                        -- to-do: gravar gpa, enviar e-mail(?)
                --
        END;
        --
        BEGIN
                INSERT  INTO    KIT0014_LOG_efvar
                                (id_log_efvar
                                ,dt_inico_log
                                ,cd_usuro
                                ,cd_crtor
                                ,cd_opeda
                                ,cd_prdut
                                ,nr_mtcal
                                ,Nr_Cotac_MC
                                ,Nm_MQUNA
                                ,xml_entr)
                        VALUES  (v_id_log
                                ,SYSTIMESTAMP
                                ,P_Usuario
                                ,P_Corretor
                                ,NULL   -- cd_opeda
                                ,NULL   -- cd_prdut
                                ,NULL   -- nr_mtcal
                                ,NULL   -- nr_cotac_mc
                                ,p_NomeMaquina
                                ,P_XmlEnvio
                                );
                --
        EXCEPTION
                --
                WHEN    OTHERS  THEN
                        NULL;
                --
        END;
        --
        COMMIT;
        --

  RETURN To_Char(v_id_log);

end;
/


CREATE OR REPLACE function fws114_Efetivar_Saida(
P_Id_log        IN NUMBER,
P_XmlRetorno    IN CLOB
) return VARCHAR2
IS
        --
        v_id_log      NUMBER(38);
        --
        PRAGMA AUTONOMOUS_TRANSACTION;
        --
BEGIN
        --
        -- Grava Log de Chamadas
        --
        -- TO-DO: fazer update na tabela de log
        --        se der certo, retornar 0;
        --        se der erro, retornar codigo diferente de 0.
        --
        BEGIN
                UPDATE  KIT0014_LOG_efvar
                SET     xml_saida       =       P_XmlRetorno,
                        dt_fim_log      =       SYSTIMESTAMP
                WHERE   id_log_efvar    =       P_Id_log;
                --
        EXCEPTION
                --
                WHEN    OTHERS  THEN
                        --
                        RETURN  '1';
                --
        END;
        --
        COMMIT;

  RETURN '0';

end;
/


CREATE OR REPLACE function fws115_Transmitir_Entrada(
P_Corretor              IN VARCHAR2,
P_Usuario               IN VARCHAR2,
P_NumeroCalculo         IN VARCHAR2,
p_NomeMaquina           IN VARCHAR2
) return VARCHAR2
IS
        --
        v_id_log      NUMBER(38);
        --
        PRAGMA AUTONOMOUS_TRANSACTION;
        --
BEGIN
        --
        -- Grava Log de Chamadas
        --
        --
        -- TO-DO: alterar o nome da sequence e fazer insert na base correta
        --
        BEGIN
                SELECT  kitsq0015_TRNSM.NEXTVAL
                INTO    v_id_log
                FROM    dual;
                --
        EXCEPTION
                --
                WHEN    OTHERS  THEN
                        --
                        v_id_log        :=      0;
                        -- to-do: gravar gpa, enviar e-mail(?)
                --
        END;
        --
        BEGIN
                INSERT  INTO    KIT0015_LOG_TRNSM
                                (id_log_trnsm
                                ,dt_inico_log
                                ,cd_usuro
                                ,cd_crtor
                                ,nr_mtcal
                                ,Nr_Cotac_MC
                                ,Nm_MQUNA
                                )
                        VALUES  (v_id_log
                                ,SYSTIMESTAMP
                                ,P_Usuario
                                ,P_Corretor
                                ,P_NumeroCalculo        -- nr_mtcal
                                ,NULL   -- nr_cotac_mc
                                ,p_NomeMaquina
                                );
                --
        EXCEPTION
                --
                WHEN    OTHERS  THEN
                        NULL;
                --
        END;
        --
        COMMIT;
        --

  RETURN To_Char(v_id_log);

end;
/


CREATE OR REPLACE function fws116_Transmitir_Saida(
P_Id_log        IN NUMBER,
P_XmlRetorno    IN CLOB
) return VARCHAR2
IS
        --
        v_id_log      NUMBER(38);
        --
        PRAGMA AUTONOMOUS_TRANSACTION;
        --
BEGIN
        --
        -- Grava Log de Chamadas
        --
        -- TO-DO: fazer update na tabela de log
        --        se der certo, retornar 0;
        --        se der erro, retornar codigo diferente de 0.
        --
        BEGIN
                UPDATE  KIT0015_LOG_TRNSM
                SET     xml_saida       =       P_XmlRetorno,
                        dt_fim_log      =       SYSTIMESTAMP
                WHERE   id_log_trnsm    =       P_Id_log;
                --
        EXCEPTION
                --
                WHEN    OTHERS  THEN
                        --
                        RETURN  '1';
                --
        END;
        --
        COMMIT;

  RETURN '0';

end;
/


CREATE OR REPLACE function fws117_Cancelar_Entrada(
P_Corretor              IN VARCHAR2,
P_Usuario               IN VARCHAR2,
P_NumeroCalculo         IN VARCHAR2,
p_NomeMaquina           IN VARCHAR2
) return VARCHAR2
IS
        --
        v_id_log      NUMBER(38);
        --
        PRAGMA AUTONOMOUS_TRANSACTION;
        --
BEGIN
        --
        -- Grava Log de Chamadas
        --
        -- TO-DO: alterar o nome da sequence e fazer insert na base correta
        --
        BEGIN
                SELECT  kitsq0017_CNCLR.NEXTVAL
                INTO    v_id_log
                FROM    dual;
                --
        EXCEPTION
                --
                WHEN    OTHERS  THEN
                        --
                        v_id_log        :=      0;
                        -- to-do: gravar gpa, enviar e-mail(?)
                --
        END;
        --
        BEGIN
                INSERT  INTO    KIT0017_LOG_CNCLR
                                (id_log_cnclr
                                ,dt_inico_log
                                ,cd_usuro
                                ,cd_crtor
                                ,nr_mtcal
                                ,Nr_Cotac_MC
                                ,Nm_MQUNA
                                )
                        VALUES  (v_id_log
                                ,SYSTIMESTAMP
                                ,P_Usuario
                                ,P_Corretor
                                ,P_NumeroCalculo        -- nr_mtcal
                                ,NULL   -- nr_cotac_mc
                                ,p_NomeMaquina
                                );
                --
        EXCEPTION
                --
                WHEN    OTHERS  THEN
                        NULL;
                --
        END;
        --
        COMMIT;

  RETURN To_Char(v_id_log);

end;
/


CREATE OR REPLACE function fws118_Cancelar_Saida(
P_Id_log        IN NUMBER,
P_XmlRetorno    IN CLOB
) return VARCHAR2
IS
        --
        v_id_log      NUMBER(38);
        --
        PRAGMA AUTONOMOUS_TRANSACTION;
        --
BEGIN
        --
        -- Grava Log de Chamadas
        --
        -- TO-DO: fazer update na tabela de log
        --        se der certo, retornar 0;
        --        se der erro, retornar codigo diferente de 0.
        --
        BEGIN
                UPDATE  KIT0017_LOG_CNCLR
                SET     xml_saida       =       P_XmlRetorno,
                        dt_fim_log      =       SYSTIMESTAMP
                WHERE   id_log_cnclr    =       P_Id_log;
                --
        EXCEPTION
                --
                WHEN    OTHERS  THEN
                        --
                        RETURN  '1';
                --
        END;
        --
        COMMIT;

  RETURN '0';

end;
/


CREATE OR REPLACE function fws119_Imp_Cotacao_Entrada(
P_Corretor              IN VARCHAR2,
P_Usuario               IN VARCHAR2,
P_NumeroCalculo         IN VARCHAR2,
p_NomeMaquina           IN VARCHAR2
) return VARCHAR2
IS
        --
        v_id_log      NUMBER(38);
        --
        PRAGMA AUTONOMOUS_TRANSACTION;
        --
BEGIN
        --
        -- Grava Log de Chamadas
        --
        -- TO-DO: alterar o nome da sequence e fazer insert na base correta
        --
        BEGIN
                SELECT  kitsq0018_IMPRS_COTAC.NEXTVAL
                INTO    v_id_log
                FROM    dual;
                --
        EXCEPTION
                --
                WHEN    OTHERS  THEN
                        --
                        v_id_log        :=      0;
                        -- to-do: gravar gpa, enviar e-mail(?)
                --
        END;
        --
        BEGIN
                INSERT  INTO    KIT0018_LOG_IMPRS_COTAC
                                (id_log_imprs_cotac
                                ,dt_inico_log
                                ,cd_usuro
                                ,cd_crtor
                                ,nr_mtcal
                                ,Nm_MQUNA
                                )
                        VALUES  (v_id_log
                                ,SYSTIMESTAMP
                                ,P_Usuario
                                ,P_Corretor
                                ,P_NumeroCalculo        -- nr_mtcal
                                ,p_NomeMaquina
                                );
                --
        EXCEPTION
                --
                WHEN    OTHERS  THEN
                        NULL;
                --
        END;
        --
        COMMIT;

  RETURN To_Char(v_id_log);

end;
/


CREATE OR REPLACE function fws120_Imp_Cotacao_Saida(
P_Id_log        IN NUMBER,
P_XmlRetorno    IN CLOB
) return VARCHAR2
IS
        --
        v_id_log      NUMBER(38);
        --
        PRAGMA AUTONOMOUS_TRANSACTION;
        --
BEGIN
        --
        -- Grava Log de Chamadas
        --
        -- TO-DO: fazer update na tabela de log
        --        se der certo, retornar 0;
        --        se der erro, retornar codigo diferente de 0.
        --
        BEGIN
                UPDATE  KIT0018_LOG_IMPRS_COTAC
                SET     xml_saida               =       P_XmlRetorno,
                        dt_fim_log              =       SYSTIMESTAMP
                WHERE   id_log_imprs_cotac      =       P_Id_log;
                --
        EXCEPTION
                --
                WHEN    OTHERS  THEN
                        --
                        RETURN  '1';
                --
        END;
        --
        COMMIT;

  RETURN '0';

end;
/


CREATE OR REPLACE function fws121_Imp_Proposta_Entrada(
P_Corretor              IN VARCHAR2,
P_Usuario               IN VARCHAR2,
P_NumeroCalculo         IN VARCHAR2,
p_NomeMaquina           IN VARCHAR2
) return VARCHAR2
IS
        --
        v_id_log      NUMBER(38);
        --
        PRAGMA AUTONOMOUS_TRANSACTION;
        --
BEGIN
        --
        -- Grava Log de Chamadas
        --
        -- TO-DO: alterar o nome da sequence e fazer insert na base correta
        --
        BEGIN
                SELECT  kitsq0019_IMPRS_PPOTA.NEXTVAL
                INTO    v_id_log
                FROM    dual;
                --
        EXCEPTION
                --
                WHEN    OTHERS  THEN
                        --
                        v_id_log        :=      0;
                        -- to-do: gravar gpa, enviar e-mail(?)
                --
        END;
        --
        BEGIN
                INSERT  INTO    KIT0019_LOG_IMPRS_PPOTA
                                (id_log_imprs_ppota
                                ,dt_inico_log
                                ,cd_usuro
                                ,cd_crtor
                                ,nr_mtcal
                                ,Nm_MQUNA
                                )
                        VALUES  (v_id_log
                                ,SYSTIMESTAMP
                                ,P_Usuario
                                ,P_Corretor
                                ,P_NumeroCalculo        -- nr_mtcal
                                ,p_NomeMaquina
                                );
                --
        EXCEPTION
                --
                WHEN    OTHERS  THEN
                        NULL;
                --
        END;
        --
        COMMIT;

  RETURN To_Char(v_id_log);

end;
/


CREATE OR REPLACE function fws122_Imp_Proposta_Saida(
P_Id_log        IN NUMBER,
P_XmlRetorno    IN CLOB
) return VARCHAR2
IS
        --
        v_id_log      NUMBER(38);
        --
        PRAGMA AUTONOMOUS_TRANSACTION;
        --
BEGIN
        --
        -- Grava Log de Chamadas
        --
        -- TO-DO: fazer update na tabela de log
        --        se der certo, retornar 0;
        --        se der erro, retornar codigo diferente de 0.
        --
        BEGIN
                UPDATE  KIT0019_LOG_IMPRS_PPOTA
                SET     xml_saida               =       P_XmlRetorno,
                        dt_fim_log              =       SYSTIMESTAMP
                WHERE   id_log_imprs_ppota      =       P_Id_log;
                --
        EXCEPTION
                --
                WHEN    OTHERS  THEN
                        --
                        RETURN  '1';
                --
        END;
        --
        COMMIT;

  RETURN '0';

end;
/


CREATE OR REPLACE function fws123_Imp_Boleto_Entrada(
P_Corretor              IN VARCHAR2,
P_Usuario               IN VARCHAR2,
P_NumeroCalculo         IN VARCHAR2,
p_NomeMaquina           IN VARCHAR2
) return VARCHAR2
IS
        --
        v_id_log      NUMBER(38);
        --
        PRAGMA AUTONOMOUS_TRANSACTION;
        --
BEGIN
        --
        -- Grava Log de Chamadas
        --
        -- TO-DO: alterar o nome da sequence e fazer insert na base correta
        --
        BEGIN
                SELECT  kitsq0020_IMPRS_BOLET.NEXTVAL
                INTO    v_id_log
                FROM    dual;
                --
        EXCEPTION
                --
                WHEN    OTHERS  THEN
                        --
                        v_id_log        :=      0;
                        -- to-do: gravar gpa, enviar e-mail(?)
                --
        END;
        --
        BEGIN
                INSERT  INTO    KIT0020_LOG_IMPRS_BOLET
                                (id_log_imprs_bolet
                                ,dt_inico_log
                                ,cd_usuro
                                ,cd_crtor
                                ,nr_mtcal
                                ,Nm_MQUNA
                                )
                        VALUES  (v_id_log
                                ,SYSTIMESTAMP
                                ,P_Usuario
                                ,P_Corretor
                                ,P_NumeroCalculo        -- nr_mtcal
                                ,p_NomeMaquina
                                );
                --
        EXCEPTION
                --
                WHEN    OTHERS  THEN
                        NULL;
                --
        END;
        --
        COMMIT;

  RETURN To_Char(v_id_log);

end;
/


CREATE OR REPLACE function fws124_Imp_Boleto_Saida(
P_Id_log        IN NUMBER,
P_XmlRetorno    IN CLOB
) return VARCHAR2
IS
        --
        v_id_log      NUMBER(38);
        --
        PRAGMA AUTONOMOUS_TRANSACTION;
        --
BEGIN
        --
        -- Grava Log de Chamadas
        --
        -- TO-DO: fazer update na tabela de log
        --        se der certo, retornar 0;
        --        se der erro, retornar codigo diferente de 0.
        --
        BEGIN
                UPDATE  KIT0020_LOG_IMPRS_BOLET
                SET     xml_saida               =       P_XmlRetorno,
                        dt_fim_log              =       SYSTIMESTAMP
                WHERE   id_log_imprs_bolet      =       P_Id_log;
                --
        EXCEPTION
                --
                WHEN    OTHERS  THEN
                        --
                        RETURN  '1';
                --
        END;
        --
        COMMIT;

  RETURN '0';

end;
/


CREATE OR REPLACE function fws125_Calcular_Stder_Entrada(
P_Corretor              IN VARCHAR2,
P_Usuario               IN VARCHAR2,
P_XmlEnvio              IN CLOB,
p_NomeMaquina           IN VARCHAR2
) return varchar2
IS
        --
        v_id_log      NUMBER(38);
        --
        PRAGMA AUTONOMOUS_TRANSACTION;
        --
BEGIN
        --
        -- Grava Log de Chamadas
        --
        -- TO-DO: alterar o nome da sequence e fazer insert na base correta
        --
        BEGIN
                SELECT  kitsq0016_CALCR_STDER.NEXTVAL
                INTO    v_id_log
                FROM    dual;
                --
        EXCEPTION
                --
                WHEN    OTHERS  THEN
                        --
                        v_id_log        :=      0;
                        -- to-do: gravar gpa, enviar e-mail(?)
                --
        END;
        --
        BEGIN
                INSERT  INTO    KIT0016_LOG_CALCR_STDER
                                (id_log_calcr_stder
                                ,dt_inico_log
                                ,cd_usuro
                                ,cd_crtor
                                ,Nm_MQUNA
                                ,xml_entr)
                        VALUES  (v_id_log
                                ,SYSTIMESTAMP
                                ,P_Usuario
                                ,P_Corretor
                                ,p_NomeMaquina
                                ,P_XmlEnvio
                                );
                --
        EXCEPTION
                --
                WHEN    OTHERS  THEN
                        NULL;
                --
        END;
        --
        COMMIT;
        --

  RETURN To_Char(v_id_log);

end;
/


CREATE OR REPLACE function fws126_Calcular_Stder_Saida(
P_Id_log        IN NUMBER,
P_XmlRetorno    IN CLOB
) return VARCHAR2
IS
        --
        v_id_log      NUMBER(38);
        --
        PRAGMA AUTONOMOUS_TRANSACTION;
        --
BEGIN
        --
        -- Grava Log de Chamadas
        -- Grava Log de Chamadas
        --
        -- TO-DO: fazer update na tabela de log
        --        se der certo, retornar 0;
        --        se der erro, retornar codigo diferente de 0.
        --
        BEGIN
                UPDATE  KIT0016_LOG_CALCR_STDER
                SET     xml_saida               =       P_XmlRetorno,
                        dt_fim_log              =       SYSTIMESTAMP
                WHERE   id_log_calcr_stder      =       P_Id_log;
                --
        EXCEPTION
                --
                WHEN    OTHERS  THEN
                        --
                        RETURN  '1';
                --
        END;
        --
        COMMIT;

  RETURN '0';

end;
/


CREATE OR REPLACE FUNCTION FWS127_OBTER_INDEXERRO       (p_cd_servc     IN      NUMBER
                                                        ,p_ds_erro      IN      VARCHAR2)
RETURN NUMBER IS
--
CURSOR  c_erros (p_cd_servico   IN      NUMBER) IS
        SELECT  id_erro_ws,
                ds_exprs_rglar
        FROM    KIT0024_ERRO_WS
        WHERE   cd_servc_ws     =       p_cd_servico;
BEGIN
        --
        FOR r_erros   IN      c_erros   (p_cd_servc)    LOOP
                --
                BEGIN
                        --
                        IF      (REGEXP_LIKE    (p_ds_erro, r_erros.ds_exprs_rglar))   THEN
                                --
                                RETURN r_erros.id_erro_ws;
                                --
                        END IF;
                        --
                END;
                --
        END     LOOP;
        --
        RETURN 0;
        --
END FWS127_OBTER_INDEXERRO;
/


CREATE OR REPLACE function fws301_validacalculo(
   P_DADOS            IN OUT RWS001_Dados,
   P_QBR              IN OUT TWS009_CALCULOQBR,
   P_CobAdcional      IN  TWS003_COBAD,
   P_Acessorios       IN  TWS004_ACESSORIO,
   P_Erros            OUT TWS001_MSGS,
   P_Avisos           OUT TWS001_MSGS,
   P_CondicaoEspecial OUT TWS008_CondicaoEspecial
) return INTEGER
IS

  type TEspecial_REC  is record (Codigo VARCHAR2(10), Descricao VARCHAR2(4000));
  type TEspecial_TAB  is table of TEspecial_REC;



  C_FRMT01       VARCHAR2(20) := 'L999G999G990D99';
  C_FRMT02       VARCHAR2(60) := 'NLS_NUMERIC_CHARACTERS = '',.'' NLS_CURRENCY = ''R$'' ';
  C_FRMT03       VARCHAR2(20) := 'L999G990D99';
  C_FRMT04       VARCHAR2(60) := 'NLS_NUMERIC_CHARACTERS = '',.'' NLS_CURRENCY = '' '' ';
  C_2            VARCHAR2(10) := '2';
  C_10           INTEGER  := 10;

  C_Captadora    Integer := 853; -- Agencia Captadora padrao.
  C_Cobradora    Integer := 853; -- Agencia CObradora padrao.

  V_ISNEWCALC      BOOLEAN;
  V_WSConfig       WS_CONFIG_CHAMADAS%ROWTYPE;
--  V_COBERTURA      INTEGER;
  V_MULTCALCULO    MULT_CALCULO%ROWTYPE;
  V_DataVersao     DATE;
  V_SYSDATE        DATE;
  V_Integer        Integer;
  V_CorrDivisao    Integer;
  V_Valor          Number;
  V_Valor2         Number;
  V_Categoria      Integer;
  V_Vigencia       Integer;
  V_1              Integer := 1;
--  V_CEP            Integer;
--  V_SeguradoCpf    VARCHAR2(20);
  V_FormaPgto      VARCHAR2(3);
  V_Erro           VARCHAR2(100);
  V_Espacial       TEspecial_TAB;
  V_VersaoCalculo  VARCHAR2(20);
  V_CD_CONGENERE   SSV0022_CONGR.CD_CONGR%TYPE;

   procedure AddErro(P_Codigo IN INTEGER, P_MSG VARCHAR2) IS
      V_MSG      RWS005_MSG;
   BEGIN
     V_MSG := RWS005_MSG(NULL,NULL);
     V_MSG.Codigo := P_CODIGO;
     V_MSG.Descricao := P_MSG;
     P_Erros.extend;
     P_Erros(P_Erros.count) := V_MSG;
   END;

   procedure AddAviso(P_Codigo IN INTEGER, P_MSG VARCHAR2) IS
      V_MSG      RWS005_MSG;
   BEGIN
     V_MSG := RWS005_MSG(NULL,NULL);
     V_MSG.Codigo := P_CODIGO;
     V_MSG.Descricao := P_MSG;
     P_Avisos.extend;
     P_Avisos(P_Avisos.count) := V_MSG;
   END;

  procedure AddEspecial(P_Codigo IN VARCHAR2, P_Descricao IN VARCHAR2) IS
      V_Especial    RWS008_CondicaoEspecial;
   BEGIN
     V_Especial            := RWS008_CondicaoEspecial(NULL, NULL);
     V_Especial.Codigo     := P_Codigo;
     V_Especial.Descricao  := P_Descricao;
     P_CondicaoEspecial.extend;
     P_CondicaoEspecial(P_CondicaoEspecial.count) := V_Especial;
   END;

BEGIN

  P_Erros  := TWS001_MSGS();
  P_Avisos := TWS001_MSGS();
  P_CondicaoEspecial := TWS008_CondicaoEspecial();

  -- Valida Corretor, Usuario, Produto e Retorna Ws_Config
  if  not fws004_checkuser2( P_DADOS.XI_CodigoCorretor,
                             P_DADOS.XI_CodigoUsuario,
                             P_Dados.XI_CodigoProduto,
                             V_WsConfig,
                             P_Erros
                            ) then
    RETURN 1;
  end if;

  if (Length(Trim(P_Dados.XI_CodigoOperadora)) > 0) then
     IF NOT fws020_ValidaOperadora( V_WsConfig.Codigo_Operadora,
                                    P_Dados.XI_CodigoOperadora,
                                    P_Erros
                                  ) THEN
        RETURN 1;
     END IF;
  end if;

  -- REALIZA VALIDAÇÕES DOS DADOS DE INPUT - INICIO
--  FIRE
  IF (NVL(P_Dados.XI_TipoPessoa, '0') = '0'
      OR (P_Dados.XI_TipoPessoa <> 'F' AND P_Dados.XI_TipoPessoa <> 'J')) THEN
    AddErro(100, 'É obrigatório o preenchimento do campo Tipo de Pessoa - F (Física) ou J (Jurídica).');
    RETURN 100;
  END IF;

  IF (P_Dados.XI_CNHCondutor IS NOT NULL
      AND NOT REGEXP_LIKE(P_Dados.XI_CNHCondutor, '^[0-9]+$')) THEN
    AddErro(101, 'É obrigatório o preenchimento do campo CNH Condutor (somente numéricos).');
    RETURN 101;
  END IF;

  -- REALIZA VALIDAÇÕES DOS DADOS DE INPUT - FIM


  -- Se Produto 42 forço para calcular apenas o 42 independente do cota_auto da
  -- base -> isso é uma gambis pois o KCW tem tabela de configuração pra isso
  -- e o COTA_AUTO deveria estar desabilitado ao invés de ficar assumindo lógica
  -- em código
  IF (NVL(P_Dados.XI_CodigoProduto, 0) <> 0 AND P_Dados.XI_CodigoProduto = 42) THEN
     P_Dados.W_COTA_AUTO               := 'N';
  ELSE
     P_Dados.W_COTA_AUTO               := NVL(V_WSConfig.Cota_Autopasseio,       'N');
  END IF;
  P_Dados.W_COTA_AUTO_CLASSICO      := NVL(V_WSConfig.Cota_Autoclassico,      'N');
  P_Dados.W_VerificaApoliceAnterior := NVL(V_WSConfig.TagNumApolice,          'N');
  P_Dados.W_Tipo_Crivo              := NVL(V_WSConfig.Tipo_Crivo,             'N');
  P_Dados.W_ChamaContaCorrente      := NVL(V_WSConfig.Reserva_Numero_Negocio, 'N');
  P_Dados.W_AcessorioCaminhao       := NVL(V_WSConfig.In_Acsro_Cmhao,         'N');
  P_Dados.W_ValidaChassi            := NVL(V_WSConfig.Tipo_Valida_Chassi,     'N');
  P_Dados.W_IsencaoPrimeiraParcela  := 'N';

  BEGIN
      SELECT forma_pgto
      INTO   V_FormaPgto
      FROM   real_corretores
      WHERE  corretor = P_DADOS.XI_CodigoCorretor;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
         AddErro(301002, 'Corretor nao encontrado.');
         RETURN 1;
  END;

  IF (V_FormaPgto = 'V') THEN
     P_Dados.W_VendeAPrazo := 'N';
  ELSE
     P_Dados.W_VendeAPrazo := 'S';
  END IF;

  -- Ed Definiu que agencia Captadora e Cobradora serao Constantes
  P_Dados.XI_CodigoAgenciaCaptadora := C_Captadora;
  P_Dados.XI_CodigoAgenciaCobradora := C_Cobradora;
  -- Valida Estipulante, Agencia Captadora e Agencia Cobradora
  IF NOT FWS010_CheckDivisoes( P_Dados.XI_CodigoCorretor,
                               P_Dados.XI_CodigoAgenciaCaptadora,
                               P_Dados.XI_CodigoAgenciaCobradora,
                               P_Dados.XI_CodigoEstipulante,
                               V_CorrDivisao,
                               P_Erros
                             ) then
     RETURN 1;
  END IF;

  -- Validar o numero da proposta
  IF P_Dados.XI_NumeroCalculo = 0 THEN
     V_ISNEWCALC := TRUE;
  ELSE
     BEGIN
       SELECT * INTO V_MULTCALCULO FROM MULT_CALCULO
       WHERE CALCULO =  P_Dados.XI_NumeroCalculo;
       V_ISNEWCALC := V_MULTCALCULO.CALCULO IS NULL;
       P_Dados.W_DataPrimeiroCalculo := V_MULTCALCULO.Dataprimeirocalculo;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         V_ISNEWCALC := TRUE;
     END;
  END IF;

  BEGIN
     SELECT  VERSAO
     INTO    V_VersaoCalculo
     FROM    mult_produtos
     WHERE   produto = P_Dados.XI_CodigoProduto;
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
        V_VersaoCalculo := NULL;
  END;

  V_SYSDATE      := TRUNC(SYSDATE);
  V_DataVersao   := NULL;

  P_Dados.W_VersaoPrimeiroCalculo := NULL;
  P_Dados.W_VersaoCalculo         := NULL;
  -- Obter a data base do calculo
  -- Se e uma nova cotacao usar data do systema
  IF V_ISNEWCALC THEN
    P_Dados.W_DataPrimeiroCalculo := SysDate;
    P_Dados.W_DataVersao := V_SYSDATE;
    P_Dados.W_VersaoPrimeiroCalculo := V_VersaoCalculo;
    P_Dados.W_VersaoCalculo         := V_VersaoCalculo;
  ELSE
    -- Se
    if V_MULTCALCULO.DATAVALIDADE IS NULL then
       P_Dados.W_DataVersao := V_SYSDATE;
    ELSE
       IF V_SYSDATE > V_MULTCALCULO.DATAVALIDADE THEN
         P_Dados.W_DataVersao        := V_SYSDATE;
         V_MULTCALCULO.DataVersao    := V_SYSDATE;
         V_MULTCALCULO.Versaocalculo :=  V_VersaoCalculo;
         UPDATE MULT_CALCULO SET
            DATACALCULO = V_SYSDATE
         WHERE CALCULO = P_Dados.XI_NumeroCalculo;
         -- Terceiro Parametro - PTRANSACAO
         -- 'C' para Calculo
         -- 'E' para efetivacao
         -- 'T' para transmissao
         V_DataVersao := PKG_KCWUTILS.GETVALIDADE(P_Dados.XI_NumeroCalculo, V_SYSDATE, 'C');
         UPDATE MULT_CALCULO SET
            DATAVALIDADE = V_DataVersao
         WHERE CALCULO = P_Dados.XI_NumeroCalculo;
         AddAviso(100001, 'A Data de calculo desta Cotação foi atualizado para '  ||
                          To_Char(P_Dados.W_DataVersao, 'DD/MM/YYYY') || '.');
       ELSE
         P_Dados.W_DataVersao    := V_MULTCALCULO.Dataversao;
       END IF;
    END IF;
    IF V_MULTCALCULO.Versaoprimeirocalculo IS NULL THEN
       P_Dados.W_VersaoPrimeiroCalculo := V_VersaoCalculo;
    ELSE
       P_Dados.W_VersaoPrimeiroCalculo := V_MULTCALCULO.Versaoprimeirocalculo;
    END IF;
    if V_MULTCALCULO.Versaocalculo IS NULL THEN
       P_Dados.W_VersaoCalculo := V_VersaoCalculo;
    ELSE
       P_Dados.W_VersaoCalculo := V_MULTCALCULO.Versaocalculo;
    END IF;
  END IF;

  -- ==================================================================
  -- Gambiarra do Foguinho para funcionar o motor/acessorios caminhao
  -- ==================================================================
--  P_Dados.W_DataVersao      := To_Date('05/12/2013', 'DD/MM/YYYY');
--  P_Dados.XI_InicioVigencia := P_Dados.W_DataVersao + 5;
  -- AddEspecial(C_10);
  -- AddEspecial(C_20);
  -- ==================================================================

  IF (P_Dados.XI_TipoSeguro IS NULL) THEN
     AddErro(301003, 'Tipo de seguro nao infromado.');
     RETURN 1;
  END IF;

  IF ( NOT ( P_Dados.XI_TipoSeguro in ('1', '2', '3', '4', '5') )) THEN
     AddErro(301004, 'Tipo de seguro infromado (' ||
               To_Char(P_Dados.XI_TipoSeguro) || ') invalido.');
     RETURN 1;
  END IF;

  V_DataVersao       := P_Dados.W_DataVersao;
  IF V_DataVersao IS NULL THEN
      IF NOT fws018_validadeproduto( P_Dados.XI_CodigoProduto,
                                     P_Dados.XI_TipoSeguro,
                                     P_Dados.XI_InicioVigencia,
                                     P_Dados.W_DataVersao,
                                     'C',
                                     V_DataVersao,
                                     V_Erro
                                   ) THEN
         AddErro(301005, V_Erro);
         RETURN 1;
    END IF;
  END IF;
  P_Dados.W_DataValidade := V_DataVersao;

  -- AddAviso(0, 'Data Base de Calculo = ' || To_Char(P_Dados.W_DataVersao));
  AddAviso(0, 'A validade desta cotação expira em: ' || To_Char(P_Dados.W_DataValidade, 'DD/MM/YYYY'));

  -- Validar Origem e Status da Cotacao
  if not V_ISNEWCALC then
     -- Validar Cotacao contra Corretor
     select count(*) into V_Integer from mult_calculodivisoes T1
     where T1.CALCULO = P_DADOS.XI_NumeroCalculo
       AND T1.Divisao = V_CorrDivisao and T1.Nivel = V_1;
     IF (V_Integer = 0) THEN
        AddErro(301006, 'O Cálculo informado não pertence a este corretor.');
        RETURN 1;
     END IF;

     -- Site define a origem do sistema que incluiu o calculo
     -- P Portal
     -- W Web Service
     -- NULL Renovacao
     if  (V_MultCalculo.Site IS NULL) or (V_MultCalculo.Site <> 'W') then
        AddErro(301007, 'O Cálculo informado não esta disponivel para alteracao via WebService');
        RETURN 1;
     end if;
     -- Verificando a Situacao do Calculo
     -- P Pendente
     -- C Calculado
     -- E Efetivado
     -- T Transmitido
     if (V_MultCalculo.Situacao IS NULL) OR (V_MultCalculo.Situacao <> 'C') then
       IF (V_MultCalculo.Situacao = 'E') THEN
          AddErro(301008, 'O Cálculo informado já foi efetivado.');
       ELSIF (V_MultCalculo.Situacao = 'T') THEN
          AddErro(301009, 'O Cálculo informado já foi transmitido.');
       ELSE
          AddErro(301010, 'O Cálculo informado esta indisponível.');
       END IF;
       RETURN 1;
     end if;
     -- Validar Cotacao Contra Codigo do Corretor.
  end if;

  -- Valida Data Base de Calculo contra data de inicio de vigencia
  -- Data de Inicio de vigencia nao pode sr inferior a 7 dias da data base
  -- Data de inicio de vigencia nao pode ser maior que 15 dias da data base
  if P_Dados.XI_InicioVigencia is null then
     AddErro(301011, 'A data Início da Vigência não foi informada.');
     RETURN 1;
  end if;

  V_Integer := Trunc(P_Dados.XI_InicioVigencia - V_DataVersao);
  if V_Integer > 15 then
     AddErro(301012, 'A data Início da Vigência não pode ser superior a 15 dias da Data do Cálculo.');
     RETURN 1;
  end if;

  if V_Integer < -7 then
     AddErro(301013, 'A data Início da Vigência não pode ser anterior a 7 dias da Data do Cálculo.');
     return 1;
  end if;

  -- Se a cotacao tem mais de 30 dias nao pode ser alterada
  if (V_MultCalculo.Dataprimeirocalculo is not null) AND
     (Trunc(V_SYSDATE - V_MultCalculo.Dataprimeirocalculo) > 30)  then
     AddErro(301014, 'Validade da cotação Expirada.');
     RETURN 1;
  end if;

  -- Valida Tipo de Cobertura
  --   1 Compreensiva
  --   2 Incêndio e Roubo
  --   3 RCF-V
  --   4 Colisão e Incêndio
  IF (P_Dados.XI_CodigoCobertura IS NULL) THEN
     AddErro(301015, 'Cobertura nao informada.');
     RETURN 1;
  END IF;
  IF NOT (P_Dados.XI_CodigoCobertura IN (1, 2, 3, 4)) THEN
     AddErro(301016, 'Validade da cotação Expirada.');
     RETURN 1;
  END IF;

  -- Valida Tipo da Franquia na contratacao
  --     1 - Básica;
  --     2 - 1,5 x Franquia;
  --     3 - 2 x Franquia;
  --     4 - Reduzida;
  --     7 - 0,75 x Franquia.
  IF (P_Dados.XI_CodigoFranquia IS NULL) THEN
     AddErro(301017, 'Codigo da franquia nao informada.');
     RETURN 1;
  END IF;

  IF NOT (P_Dados.XI_CodigoCobertura IN (1, 2, 3, 4, 7)) THEN
     AddErro(301018, 'Codigo da franquia nao informada "'
                     || To_Char(P_Dados.XI_CodigoCobertura) || '" invalido.');
     RETURN 1;
  END IF;
  -- XI_CodigoFranquia           INTEGER,       -- Tipo de franquia para contratação. 1-Básica; 2-1,5 x Franquia; 3-2 x Franquia; 4-Reduzida; 7-0,75 x Franquia.

  -- Validar os Dados de Automovel
  --######################################################
  -- Gambiarra Foghino 2
  --######################################################
  IF not fws013_CheckVeiculo( P_Dados.XI_CodigoVeiculo,
                              P_Dados.XI_CodigoFabricante,
                              P_Dados.XI_TipoCombustivel,
                              P_Dados.XI_ZeroKm,
                              P_Dados.XI_AnoModelo,
                              P_Dados.XI_AnoFabricacao,
                              P_Dados.W_DataVersao,  --P_Dados.XI_InicioVigencia, -- P_Dados.W_DataVersao,  -- Para ficar igual ao KCW
                              P_Dados.XI_CodigoCobertura,
                              V_Valor,
                              v_Categoria,
                              P_Erros
                            )  THEN
     RETURN 1;
  END IF;

  -- Validar valor do veiculo
  -- Se a Modalidade do seguro for:
  --   A -> Valor Ajustado, usar o percentual para calcular o valor do veiculo
  --   B -> Valor Determinado, usar o valor informado e calcular o percentual
  -- O Valor de referencia e o valor obtido na funcao fws013_CheckVeiculo
  -- XI_TipoModalidade
  IF ( P_Dados.XI_TipoModalidade IS NULL ) THEN
     AddErro(301019, 'Tipo de Modalidade nao infromada.');
     RETURN 1;
  END IF;

  -- Se a Cobertura for difente de 3 RCF-V
  IF (P_Dados.XI_CodigoCobertura <> 3) THEN
     IF (P_Dados.XI_TipoModalidade = 'A') THEN
       IF (P_Dados.XI_PercentualAjuste IS NULL)  THEN
          AddErro(301051, 'Percentual de ajuste nao informado.');
          RETURN 1;
       END IF;
       IF (P_Dados.XI_PercentualAjuste <= 0) THEN
          AddErro(301052, 'Percentual de ajuste informado (' ||
                  To_Char(P_Dados.XI_PercentualAjuste, C_FRMT03, C_FRMT04) || '%) invalido.');
          RETURN 1;
       END IF;
       V_Valor2 :=  Round(P_Dados.XI_PercentualAjuste * V_Valor  / 100, 2);
       P_Dados.XI_ValorVeiculo := V_Valor2;
     ELSIF (P_Dados.XI_TipoModalidade = 'D') THEN
       IF (P_Dados.XI_ValorVeiculo IS NULL) THEN
          AddErro(301053, 'Valor do veiculo nao infromado.');
          RETURN 1;
       END IF;
       IF (P_Dados.XI_ValorVeiculo <= 0) THEN
          AddErro(301054, 'Valor do veiculo infromado (' ||
               To_Char(P_Dados.XI_ValorVeiculo, C_FRMT01, C_FRMT02) || ') invalido.');
          RETURN 1;
       END IF;
       V_Valor2 :=  Round(P_Dados.XI_ValorVeiculo / V_Valor  * 100, 2);
       P_Dados.XI_PercentualAjuste := V_Valor2;
     ELSE
        AddErro(301050, 'Tipo de Modalidade "' || P_Dados.XI_TipoModalidade || '" invalida.');
        RETURN 1;
     END IF;
  ELSE
     -- Se a Cobertura for 3 RCF-V Zerar Valores
     P_Dados.XI_ValorVeiculo     := 0;
     P_Dados.XI_PercentualAjuste := 0;
  END IF;

  P_Dados.W_Agrupamento := v_Categoria;

  /* Transferido para fws012_checkqbr
  if P_Dados.XI_CodigoProduto in (10, 42) then
     V_COBERTURA := 17; -- Auot e Auto Classico
  elsif P_Dados.XI_CodigoProduto = 24 then
     V_COBERTURA := 63; -- Carga
  else
     V_COBERTURA := 0;
  end if;
  */

  /*
  if P_Dados.XI_CEP is not null and LENGTH(P_Dados.XI_CEP) > 0 then
     V_CEP := REPLACE(P_Dados.XI_CEP, '-', '');
  end if;
  */

  -- Valida Se o Condutor e o proprio segurado
  IF (P_Dados.XI_CondutorSegurado IS NOT NULL) THEN
     IF NOT (P_Dados.XI_CondutorSegurado IN ('N', 'S') ) THEN
        AddErro(301061, 'Flag Condutor e segurado informado "'
                        || P_Dados.XI_CondutorSegurado || '" invalido.');
        RETURN 1;
     END IF;

     -- Se o segurado e uma empresa
     -- Verifica se o condutor foi informado
     IF (P_Dados.XI_TipoPessoa = 'J') AND
        (P_Dados.XI_CondutorSegurado = 'S') THEN
        AddErro(301062, 'Se o segurado é uma empresa, o condutor deve ser informado.');
        RETURN 1;
     END IF;

  END IF;

  -- Valida QBR e Dispositivos de Seguranca
  IF (P_Qbr iS null) THEN
     AddErro(301063, 'QBR nao informado.');
     RETURN 1;
  END IF;

  /* Chamada antiga da QBR
  IF NOT fws012_CheckQbr( P_DADOS.XI_CodigoCorretor,
                          P_Dados.XI_CodigoProduto,
                          P_Dados.XI_TipoVeiculo,
                          V_CEP,
                          P_Dados.W_DataVersao,
                          P_Dados.XI_TipoUsoVeiculo,
                          P_Dados.W_Agrupamento,
                          P_dados.XI_TipoPessoa,
                          V_COBERTURA,
                          P_Dados.XI_AnoModelo,
                          P_Dados.XI_TipoSeguro,
                          P_Dados.XI_Dispositivo,
                          P_Dados.XI_CodigoDispositivo,
                          P_Dados.XI_CodigoGerenciadora,
                          P_Dados.XI_CondutorSegurado,
                          P_Dados.W_QbrCodigo,
                          P_Dados.W_CodigoRegiao,
                          P_Dados.W_NomeDispositivo,
                          P_Dados.W_NomeGerenciadora,
                          P_Qbr,
                          P_Erros,
                          P_Avisos
                        ) then
  */
  IF NOT fws012_CheckQbr( P_DADOS,
                          P_Qbr,
                          P_Erros,
                          P_Avisos
                        ) then
    RETURN 1;
  end if;

  --
  V_Vigencia := fws002_getvigencia( P_Dados.XI_CodigoProduto, P_Dados.W_DataVersao);

  -- Valida Segurado e Condutor
  IF NOT fws021_ValidaSeguradoCondutor( P_Dados, P_Erros) then
     RETURN 1;
  END IF;

  -- Valida Coberturas Adicionais
  IF (P_CobAdcional iS null) THEN
     AddErro(301081, 'Cobertura adicional nao informada.');
     RETURN 1;
  END IF;

  -- Validar Tipo de Assistencia 24 Horas
  --  N - Não; B - Básico (Opcão excluída); C - Completo; V - Vip (Nova opção)
  IF (P_dados.XI_TipoAssistencia IS NULL) THEN
     AddErro(301082, 'Tipo de Assitencia nao informada.');
     RETURN 1;
  END IF;
  IF NOT (P_dados.XI_TipoAssistencia IN ('N', 'C', 'V') ) THEN
     AddErro(301083, 'Tipo de Assitencia informada "'
                     || P_dados.XI_TipoAssistencia || '" invalida.');
     RETURN 1;
  END IF;

  IF NOT  fws015_CheckCobAdicionais( C_10, --P_Dados.XI_CodigoProduto,
                                     P_CobAdcional,
                                     P_Dados.XI_CodigoCobertura,
                                     P_dados.XI_TipoAssistencia,
                                     P_Erros
                                   ) THEN
     RETURN 1;
  END IF;

  -- So vericia Acessorios se nao for nulo
  IF (P_Acessorios IS NOT NULL AND P_Acessorios.Count > 0) THEN
     IF (P_Dados.XI_ValorVeiculo = 0) THEN
        AddErro(301085, 'RCF nao permite acessorios.');
        RETURN 1;
     END IF;

     IF NOT  fws016_checkacessorios( C_10, --P_Dados.XI_CodigoProduto,
                                     P_Acessorios,
                                     P_Erros
                                   ) THEN
        RETURN 1;
     END IF;
  END IF;


  -- Se houver validacao de Chassi
  -- Numero do chassi e placa devem ser informados.
  IF  ( NVL(V_WSConfig.Tipo_Valida_Chassi, 'N') = 'S') THEN

      IF (P_dados.XI_Placa IS NULL) THEN
         AddErro(301090, 'Placa nao informada.');
         RETURN 1;
      END IF;

      IF (P_dados.XI_Chassi IS NULL) THEN
         AddErro(301091, 'Chassi nao informado.');
         RETURN 1;
      END IF;

  END IF;

  -- Verificar Apolice anterior
  -- Se o tipo de seguro for:
  --   4 - Renovação Tókio com sinistro
  --   5 - Renovação Tókio sem sinistro
  IF ( P_Dados.XI_TipoSeguro in (4, 5) ) THEN
    IF P_Dados.W_VerificaApoliceAnterior = 'S' THEN
      IF (P_Dados.XI_NumeroApoliceAnterior IS NULL) THEN
        AddErro(301100, 'Numero da apolice anterior deve ser informado quando e uma renovacao da Tokio Marine.');
        RETURN 1;
      END IF;

     /*
     -- Verifica na tabela se tem desconto na primeira parcela do Mes a Mes.
     -- Processoa a ser definido pelo Edmilson....
     BEGIN
       SELECT cd_isen_1_parc, NR_CPF_CNPJ
       INTO   V_IsencaoPrimeira, V_ApoliceCpf
       FROM   tb_carga_renov_mm
       WHERE  CD_APOLI_SUSEP  = P_Dados.XI_NumeroApoliceAnterior;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
        V_IsencaoPrimeira := 'N';
        V_ApoliceCpf      := 0;
     END IF;

     IF V_IsencaoPrimeira = 'S' THEN
        AddEspecial(C_10);
        AddEspecial(C_20);
     END IF

     V_SeguradoCpf := REGEXP_REPLACE(P_Dados.XI_CGC_CPF, '[^0-9]');
     IF (To_Char(V_ApoliceCPF) <> V_SeguradoCpf) THEN
        AddErro(301023, 'CPF ou CNPJ informado nao confere com a informacao da da apolice anterior.');
        RETURN 1;
     END IF;
     */
    END IF;

/*  ELSIF (P_Dados.XI_TipoSeguro in (2, 3)) THEN -- Tipo de Seguro Congenere
    IF (NVL(V_WSConfig.Obriga_Seguradora_Anterior, 'N') = 'S'
        AND NVL(TRIM(P_Dados.XI_CodigoSeguradoraAnterior), 0) = 0) THEN
      AddErro(301101, 'Código da Seguradora Anterior é obrigatório.');
      RETURN 1;
    ELSE
      BEGIN
        SELECT C.CD_CONGR
        INTO V_CD_CONGENERE
        FROM SSV0022_CONGR C
        WHERE P_DADOS.XI_InicioVigencia BETWEEN C.DT_INICO_VIGEN AND C.DT_FIM_VIGEN
        AND C.CD_CONGR = P_DADOS.XI_CodigoSeguradoraAnterior
        ORDER BY C.CD_CONGR;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          AddErro(301102, 'Código da Seguradora Anterior não encontrado na base de dados.');
          RETURN 1;
        WHEN OTHERS THEN
          AddErro(301103, 'Problemas ao consultar Código da Seguradora Anterior.');
          RETURN 1;
      END;
    END IF;
*/

  END IF;

  -- Seleciona Condicoes Especiais
  SELECT DISTINCT TO_Char(T9.CD_CDESP), T9.DS_CDESP
  BULK COLLECT INTO V_Espacial
  FROM( SELECT PRODUTO AS CD_MDUPR, CHAVE1 AS TP_COMRZ_ITSEG, CHAVE2 AS TP_SEGUR,
               CHAVE3 AS CD_CRTOR_SEGUR, VALOR AS CD_CDESP, TEXTO AS DS_CDESP
        FROM MULT_PRODUTOSTABRG
        WHERE PRODUTO         IN (10,42)
        AND TABELA          = 445
        AND (CHAVE3         = P_DADOS.XI_CodigoCorretor OR CHAVE3 = 0)
        AND (CHAVE2         = P_DADOS.XI_TipoSeguro     OR CHAVE2 = 0)
        AND CHAVE1          = C_2
        AND DT_INICO_VIGEN <= P_DADOS.XI_InicioVigencia
        AND DT_FIM_VIGEN   >= P_DADOS.XI_FinalVigencia
        AND VALOR          <> 30
        ORDER BY CD_MDUPR, TP_COMRZ_ITSEG, TP_SEGUR, CD_CRTOR_SEGUR
      ) T9 order by  DS_CDESP desc;

  IF (V_Espacial.Count > 0) THEN
     FOR I in 1 .. V_Espacial.Count LOOP
        AddEspecial(V_Espacial(i).Codigo, V_Espacial(i).Descricao);
     END LOOP;
  END IF;

  -- Valida Valores e Limites.
  IF NOT fws023_ValidaLimites(P_Dados, P_Erros) THEN
     RETURN 1;
  END IF;


  RETURN 0;

END;
/


CREATE OR REPLACE function fws302_validaconta(
   P_Conta                IN OUT RWS006_ContaCorrente,
   P_ContaAgravoDesconto  OUT TWS007_ContaAgravoDesconto,
   P_Erros                OUT TWS001_MSGS,
   P_Avisos               OUT TWS001_MSGS
) return INTEGER
IS

  TYPE TKIT002_TAB IS TABLE OF KIT0022_MTCAL_CC%ROWTYPE;

  C_1            INTEGER := 1;
  C_FRMT01       VARCHAR2(20) := 'L999G999G990D99';
  C_FRMT02       VARCHAR2(60) := 'NLS_NUMERIC_CHARACTERS = '',.'' NLS_CURRENCY = ''R$'' ';
  C_Chamador     VARCHAR2(3)  := 'KCW';

  V_WSConfig     WS_CONFIG_CHAMADAS%ROWTYPE;
  V_MULTCALCULO  MULT_CALCULO%ROWTYPE;
  V_KIT022       TKIT002_TAB;

  V_SysDate           Date;
  V_ClienteCpf        VARCHAR2(40);
  V_Produto           Integer;
  V_Modalidade        Integer;
  V_CalcCorr          Integer;
  V_ProdSsv           Integer;
  V_CodErro           Integer;
  V_NumApolice        NUMBER;
  V_Erro              VARCHAR(200);
  V_Agravo            Number;
  V_Desconto          Number;
  V_Valor             Number(15,2);
  V_IndAgraDesc       VARCHAR2(3);
  V_NomeCliente       VARCHAR2(200);
  V_FormaPgto         VARCHAR2(3);

  V_ConsultaIn        consulta_saldo_in;
  V_ConsultaOut       consulta_saldo_out;
  V_ValidaIn          valida_valor_in;
  V_ValidaOut         valida_valor_out;



   procedure AddErro(P_Codigo IN INTEGER, P_MSG VARCHAR2) IS
      V_MSG      RWS005_MSG;
   BEGIN
     V_MSG := RWS005_MSG(NULL,NULL);
     V_MSG.Codigo := P_CODIGO;
     V_MSG.Descricao := P_MSG;
     P_Erros.extend;
     P_Erros(P_Erros.count) := V_MSG;
   END;

   procedure AddAviso(P_Codigo IN INTEGER, P_MSG VARCHAR2) IS
      V_MSG      RWS005_MSG;
   BEGIN
     V_MSG := RWS005_MSG(NULL,NULL);
     V_MSG.Codigo := P_CODIGO;
     V_MSG.Descricao := P_MSG;
     P_Avisos.extend;
     P_Avisos(P_Avisos.count) := V_MSG;
   END;

   procedure AddConta( P_Produto    IN NUMBER,   P_Modalidade IN NUMBER,
                       P_Desconto   IN NUMBER,   P_Agravo     IN NUMBER,
                       P_Disponivel IN NUMBER,   P_DescMax    IN NUMBER,
                       P_Indicador  IN VARCHAR2, P_MSG VARCHAR2
                      ) IS
      V_RConta     RWS007_ContaAgravoDesconto;
   BEGIN
     V_RConta := RWS007_ContaAgravoDesconto(NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
     V_RConta.Produto           := P_Produto;
     V_RConta.Modalidade        := P_Modalidade;
     V_RConta.Desconto          := P_Desconto;
     V_RConta.Agravo            := P_Agravo;
     V_RConta.Indicador         := P_Indicador;
     V_RConta.VlSaldoDisponivel := P_Disponivel;
     V_RConta.VlDescontoMaximo  := P_DescMax;
     V_RConta.Mensagem          := P_Msg;
     P_ContaAgravoDesconto.extend;
     P_ContaAgravoDesconto(P_ContaAgravoDesconto.count) := V_RCONTA;
   END;

   procedure AddMesMes( P_Produto IN NUMBER) IS
      V_RConta     RWS007_ContaAgravoDesconto;
   BEGIN
     IF (P_ContaAgravoDesconto.count > 0) THEN
        V_RConta := P_ContaAgravoDesconto(P_ContaAgravoDesconto.count);
        IF ( V_RConta.Modalidade = 1) and (V_RConta.Produto = P_Produto) THEN
          V_RConta.Modalidade        := 3;
          P_ContaAgravoDesconto.extend;
          P_ContaAgravoDesconto(P_ContaAgravoDesconto.count) := V_RCONTA;
        END IF;
     END IF;
   END;


begin

  IF P_Erros IS NULL THEN
    P_Erros  := TWS001_MSGS();
  END IF;
  IF P_Avisos IS NULL THEN
    P_Avisos := TWS001_MSGS();
  END IF;

  P_ContaAgravoDesconto := TWS007_ContaAgravoDesconto();

  -- Valida Usuario
  if  not fws004_checkuser2( P_Conta.I_Corretor,
                             P_Conta.I_Usuario,
                             10,
                             V_WsConfig,
                             P_Erros
                            ) then
    RETURN 1;
  end if;

  -- Valida Flag de Conta Corrente
  IF (NVL(V_WSConfig.Reserva_Numero_Negocio, 'N') = 'N') THEN
    AddErro(302001, 'Corretor código ' || To_Char(P_Conta.I_Corretor) ||  ' não pode aplicar conta corrente.');
    RETURN 1;
  END IF;

  -- Valida Produto
  V_Produto := NVL(P_Conta.I_CodigoProduto, 0 );
  IF ( not ( V_Produto  in (0, 10, 42) ) ) then
    AddErro(302002, 'Produto "' || TO_Char(P_Conta.I_CodigoProduto) || '" não disponivel!');
    RETURN 1;
  END IF;

  -- Valida Modalidade
  V_Modalidade := fws007_isnumber(P_Conta.I_Modalidade);
  IF (V_Produto <> 0) AND  ( NOT ( V_Modalidade IN ( 1, 2, 3) ) ) then
    AddErro(302003, 'Modalidade nao informada para o produto "' || TO_Char(V_Produto) || '".');
    RETURN 1;
  END IF;

  -- Valida Agravo e Desconto
  V_Agravo   := NVL(P_Conta.I_Agravo,0);
  V_Desconto := NVL(P_Conta.I_Desconto,0);

  IF (V_Desconto = 0) AND (V_Agravo = 0) then
    AddErro(302004, 'É preciso informar valor de desconto OU de agravo.');
    RETURN 1;
  END IF;

  IF (V_Desconto > 0) AND (V_Agravo > 0) then
    AddErro(302005, 'Valores de desconto e de agravo não podem ser informados juntos.');
    RETURN 1;
  END IF;

  -- Valida Numero do Calculo
  IF (NVL(P_Conta.I_NumeroCalculo, 0) = 0) THEN
    AddErro(302006, 'Numero do Calculo não informado.');
    RETURN 1;
  END IF;

  BEGIN
    -- Pesquisa se o Numero de Cotacao existe
    SELECT * INTO V_MULTCALCULO FROM MULT_CALCULO
    WHERE CALCULO =  P_Conta.I_NumeroCalculo;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      AddErro(302007, 'O número do calculo ' || TO_Char(P_Conta.I_NumeroCalculo) || ' não foi encontrado.');
      RETURN 1;
  END;

  -- Site define a origem do sistema que incluiu o calculo
  -- P Portal
  -- W Web Service
  -- NULL Renovacao
  if  (V_MULTCALCULO.Site IS NULL) or (V_MULTCALCULO.Site <> 'W') then
    AddErro(302008, 'O Cálculo informado não está disponível para alteração via WebService.');
    RETURN 1;
  end if;
  -- Verificando a Situacao do Calculo
  -- P Pendente
  -- C Calculado
  -- E Efetivado
  -- T Transmitido
  if (V_MULTCALCULO.Situacao IS NULL) OR (V_MULTCALCULO.Situacao <> 'C') then
    IF (V_MULTCALCULO.Situacao = 'E') THEN
       AddErro(302009, 'O Cálculo informado já foi efetivado.');
    ELSIF (V_MULTCALCULO.Situacao = 'T') THEN
       AddErro(302010, 'O Cálculo informado já foi transmitido.');
    ELSE
       AddErro(302011, 'O Cálculo informado está indisponível.');
    END IF;
    RETURN 1;
  end if;

  -- Verifica qual a condicao de pagamento por corretor
  BEGIN
      SELECT forma_pgto
      INTO   V_FormaPgto
      FROM   real_corretores
      WHERE  corretor = P_Conta.I_Corretor;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
         AddErro(302012, 'Corretor nao encontrado.');
         RETURN 1;
  END;

  IF (V_FormaPgto = 'V') THEN
     P_Conta.W_VendeAPrazo := 'N';
  ELSE
     P_Conta.W_VendeAPrazo := 'S';
  END IF;

  -- Atribui ao objeto de retorno os FLAGS necessários da ws_config_chamadas
  P_Conta.W_COTA_AUTO               := NVL(V_WSConfig.Cota_Autopasseio,  'N');
  P_Conta.W_COTA_AUTO_CLASSICO      := NVL(V_WSConfig.Cota_Autoclassico, 'N');
  P_Conta.W_ACESSORIOCAMINHAO       := NVL(V_WSConfig.In_Acsro_Cmhao, 'N');

  -- Verifica se o calculo pertence ao corretor
  BEGIN
    SELECT T3.Divisao_Superior
    INTO V_CalcCorr
    FROM MULT_CALCULO T1
    INNER JOIN MULT_CALCULODIVISOES T2
       ON T2.CALCULO = T1.CALCULO
      AND T2.NIVEL   = C_1
    INNER JOIN TABELA_DIVISOES T3
       ON T3.Divisao = T2.Divisao
    WHERE T1.CALCULO =  P_Conta.I_NumeroCalculo;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      AddErro(302013, 'O numero do calculo ' || TO_Char(P_Conta.I_NumeroCalculo)
                      || ' nao pertence ao corretor ' ||TO_Char(P_Conta.I_Corretor) || '.');
      RETURN 1;
  END;

  IF (NVL(V_CalcCorr,0) <> P_Conta.I_Corretor) THEN
      AddErro(302014, 'O numero do calculo ' || TO_Char(P_Conta.I_NumeroCalculo)
                      || ' nao pertence ao corretor ' ||TO_Char(P_Conta.I_Corretor) || '.');
      RETURN 1;
  END IF;

  -- Valida Data de Validade
  V_SysDate := Trunc(SysDate);
  IF (V_MULTCALCULO.DATAVALIDADE IS NOT NULL AND
     Trunc(V_MULTCALCULO.DATAVALIDADE) < V_SysDate) THEN -- Valida Regra
    AddErro(302015, 'Não é possível aplicar Conta Corrente pois, cotação está expirada. Favor efetuar nova cotação.');
    RETURN 1;

  ELSE
    -- Aviso da validade da cotação
    AddAviso(0, 'A validade desta cotação expira em: ' || To_Char(V_MULTCALCULO.DATAVALIDADE, 'DD/MM/YYYY'));
  END IF;

  -- Obtem Data Base
  V_SysDate := Trunc(SysDate);
  IF (V_MULTCALCULO.DATACALCULO  IS NOT NULL) AND  -- Valida Data de Calculo
     (V_MULTCALCULO.DATAVALIDADE IS NOT NULL) AND  -- Valida Validade da Proposta
     (Trunc(V_MULTCALCULO.DATAVALIDADE) >= V_SysDate) THEN -- Valida Regra
     P_Conta.W_Data_Base_Calculo := TRUNC(V_MULTCALCULO.DATACALCULO);
  ELSE
     P_Conta.W_Data_Base_Calculo := V_SysDate;
  END IF;

  -- Se o Produto nao foi informado adotar Auto Passeio
  IF (V_Produto = 0) THEN
     V_ProdSsv  := 7;
  ELSE
     V_ProdSsv  := FWS017_Produto_Kcw2SSV(P_Conta.I_CodigoProduto);
     IF (V_ProdSsv = 0) THEN
        AddErro(302016, 'Código de Produto ' || To_Char(P_Conta.I_CodigoProduto) || 'desconhecido.');
        RETURN 1;
     END IF;
  END IF;

     -- Buscar o CPF ou CNPJ do Cliente do Calculo
  BEGIN
     SELECT T1.cgc_cpf, T1.Nome
     INTO   V_ClienteCpf, V_NomeCliente
     FROM   Tabela_Clientes T1
     WHERE  T1.Cliente = V_MULTCALCULO.Cliente;
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
        AddErro(302017, 'Cliente não encontrado para o cálculo '
                        || To_Char(P_Conta.I_NumeroCalculo) || '.');
        RETURN 1;
  END;

  -- Remove formatacao do CPF ou CNPJ
  V_ClienteCpf := Replace(V_ClienteCpf, '.');
  V_ClienteCpf := Replace(V_ClienteCpf, '-');
  V_ClienteCpf := Replace(V_ClienteCpf, '/');

  -- Se for uma renovacao Tokio
  IF (V_MULTCALCULO.Tiposeguro in ('4', '5') ) THEN

     -- Verificar  numeroda apolice anterior
     BEGIN
       V_NumApolice := TO_Number(Trim(NVL(V_MULTCALCULO.Campo1,'0')));
     EXCEPTION
       WHEN OTHERS THEN V_NumApolice := 0;
     END;
     IF (V_NumApolice = 0) THEN
        AddErro(302018, 'O numero da apolice nao foi informado no calculo '
                        || TO_Char(P_Conta.I_NumeroCalculo) || '.');
        RETURN 1;
     END IF;

     -- Armazena Numero da Apolice Anterior
     P_Conta.W_NumeroApoliceAnterior := V_NumApolice;

     -- Verificar se houve troca de corretor
     SSVCTPA0200_001.Valida_Troca_Corretor_Auto( 'MUL', V_ProdSsv, P_Conta.I_Corretor, NULL,
                                                 V_NumApolice,
                                                 V_MULTCALCULO.Tipo_Pessoa,
                                                 V_ClienteCpf,
                                                 V_CodErro, V_Erro);
     -- Se reornou erro.
     IF V_CodErro <> 0 THEN
        AddErro(302019, V_Erro);
        RETURN 1;
     END IF;

  END IF;

--  IF (V_Produto = 0) THEN
    SELECT *
    BULK COLLECT INTO V_KIT022
    FROM KIT0022_MTCAL_CC T1
    WHERE T1.NR_CALLO = P_Conta.I_NumeroCalculo
    ORDER BY T1.CD_PRDUT, T1.TP_COTAC;
/*
  ELSE
    SELECT *
    BULK COLLECT INTO V_KIT022
    FROM KIT0022_MTCAL_CC T1
    WHERE T1.NR_CALLO = P_Conta.I_NumeroCalculo
      AND T1.CD_PRDUT = V_Produto
      AND T1.TP_COTAC = V_Modalidade
    ORDER BY T1.CD_PRDUT, T1.TP_COTAC;
  END IF;
*/

  IF (V_KIT022.count = 0) THEN
     AddErro(302020, 'Premio liquido nao encontrado para o calculo '
                     || To_Char(P_Conta.I_NumeroCalculo) || '.');
     RETURN 1;
  END IF;

  -- No caso de Mes a Mes usar premio liquido do ajustado
  -- Se Modalidade = 3 usar Premio Liquido da Modalidade 1
  IF (V_Desconto > 0) THEN
    FOR I IN 1 .. V_KIT022.Count - 1 LOOP
        IF (I < V_KIT022.Count) AND (V_KIT022(i).TP_COTAC = 1) THEN
           FOR J IN I+1 .. V_KIT022.Count LOOP
               IF (V_KIT022(i).CD_PRDUT = V_KIT022(J).CD_PRDUT) AND
                  (V_KIT022(J).TP_COTAC = 3) THEN
                  V_KIT022(j).VL_PRMIO_LIQUI := V_KIT022(i).VL_PRMIO_LIQUI;
                  exit;
               END IF;
           END LOOP;
        END IF;
    END LOOP;
  END IF;

  -- Codigos de Processo apra conta corrente
  -- Consulta Saldo:          22
  -- Valida Valor:            13
  -- Provisiona Valor:         2
  -- Estorna Provisão:         4
  -- Valida Troca Corretor:   15

  V_ConsultaIn  := consulta_saldo_in ( NULL, NULL, NULL, NULL, NULL, NULL,
                                       NULL, NULL, NULL, NULL, NULL, NULL);
  V_ConsultaOut := consulta_saldo_out( NULL, NULL, NULL, NULL);
  V_ValidaIn    := valida_valor_in   ( NULL, NULL, NULL, NULL, NULL, NULL,
                                       NULL, NULL, NULL, NULL, NULL, NULL,
                                       NULL, NULL, NULL);
  V_ValidaOut   := valida_valor_out  ( NULL, NULL);

  -- Verificar para cada valor de preimo liquido calculado
  FOR I in 1 .. V_KIT022.count  LOOP
   IF  V_KIT022(i).TP_COTAC = 3  THEN
       IF (I = 1) OR
          (V_KIT022(i-1).CD_PRDUT <> V_KIT022(i).CD_PRDUT) OR
          (V_KIT022(i-1).TP_COTAC <> 1) THEN
           AddErro(302021, 'Cálculo do Valor do Ajustado não encontrado.');
           RETURN 1;
       END IF;
       AddMesMes(V_KIT022(i).CD_PRDUT);
   ELSE
     -- CONSULTA SALDO DESCONTO
     V_ProdSsv     := FWS017_Produto_Kcw2SSV(V_KIT022(i).CD_PRDUT);
     V_ConsultaIn  := consulta_saldo_in ( C_Chamador,                 -- SistemaChamador  VARCHAR2(03)
                                            To_Char(V_ProdSsv),         -- CdProduto        VARCHAR2(05),
                                            P_Conta.I_Corretor,         -- CdCorretor       NUMBER  (06),
                                            P_Conta.I_NumeroCalculo,    -- CdContrato       NUMBER(15)
                                            0,                          -- CdItemContrato   NUMBER(15)
                                            V_KIT022(i).VL_PRMIO_LIQUI, -- VlPremioLiquido  NUMBER  (15,2)
                                            V_MULTCALCULO.Comissao,     -- Pccomissao       NUMBER  (5,2)
                                            To_Char(V_MULTCALCULO.Iniciovigencia, 'YYYYMMDD'), -- DtInicioVigencia        VARCHAR2(8)
                                            V_MULTCALCULO.Tipo_Pessoa,  -- TpPessoa         VARCHAR2(1)
                                            V_ClienteCpf,               -- CPFCNPJCliente   NUMBER(14)
                                            P_Conta.I_Usuario,          -- CdUsuario        VARCHAR2(30)
                                            22                          -- CdProcesso       NUMBER(2)
                                          );
     V_ConsultaOut := consulta_saldo_out( NULL, NULL, NULL, NULL);

     ctactpa0001_001.Consulta_Saldo_Desconto(V_ConsultaIn, V_ConsultaOut);

     IF (V_ConsultaOut.StRetorno <> 0) THEN
       AddErro(302022, V_ConsultaOut.MsgRetorno);
       RETURN 1;
     END IF;

     -- Se for agravo
     IF (V_Agravo > 0) THEN
       V_IndAgraDesc := 'A';
       -- Valor do Agravo Limitado a R$99.999,00
       V_Valor := 99999;
       -- Valor de Agravo limitado a 99% do Premio Liquido nao vale mais
       -- V_Valor := V_KIT022(i).VL_PRMIO_LIQUI * 0.99;
       IF V_Valor >= V_Agravo THEN
          V_Valor := V_Agravo;
          AddConta(V_KIT022(i).CD_PRDUT, V_KIT022(i).TP_COTAC,
                   0, V_Agravo,
                   V_ConsultaOut.VlSaldoDisponivel,
                   V_ConsultaOut.VlDescontoMaximo, V_IndAgraDesc, '');
       ELSE
          AddConta(V_KIT022(i).CD_PRDUT, V_KIT022(i).TP_COTAC,
                   0, V_Valor,
                   V_ConsultaOut.VlSaldoDisponivel,
                   V_ConsultaOut.VlDescontoMaximo, V_IndAgraDesc,
                   'Limitado a ' || To_Char(V_Valor, C_FRMT01, C_FRMT02) || '.');

       END IF;
     ELSE -- Se for desconto
       V_IndAgraDesc := 'D';

       IF (V_ConsultaOut.VlSaldoDisponivel = 0) THEN
         AddErro(302023, 'Não há Saldo Disponível em conta corrente, para aplicar desconto.');
         RETURN 1;
       END IF;

       IF (V_ConsultaOut.VlDescontoMaximo >= V_Desconto) THEN
         V_Valor := V_Desconto;
         AddConta(V_KIT022(i).CD_PRDUT, V_KIT022(i).TP_COTAC,
                   V_Desconto, 0,
                   V_ConsultaOut.VlSaldoDisponivel,
                   V_ConsultaOut.VlDescontoMaximo, V_IndAgraDesc, '');
       ELSE
         V_Valor := V_ConsultaOut.VlDescontoMaximo;
         AddConta(V_KIT022(i).CD_PRDUT, V_KIT022(i).TP_COTAC,
                   V_ConsultaOut.VlDescontoMaximo, 0,
                   V_ConsultaOut.VlSaldoDisponivel,
                   V_ConsultaOut.VlDescontoMaximo,
                   V_IndAgraDesc, 'Desconto Limitado a '
                   || TO_Char(V_ConsultaOut.VlDescontoMaximo, C_FRMT01, C_FRMT02) || '.');
       END IF;

     END IF;

     V_ValidaOut   := valida_valor_out( NULL, NULL);
     V_ProdSsv     := FWS017_Produto_Kcw2SSV(V_KIT022(i).CD_PRDUT);
     V_ValidaIn    := valida_valor_in( C_Chamador,                 -- SistemaChamador  VARCHAR2(03)
                                       To_Char(V_ProdSsv),         -- CdProduto        VARCHAR2(05)
                                       P_Conta.I_Corretor,         -- CdCorretor       NUMBER  (06)
                                       P_Conta.I_NumeroCalculo,    -- CdContrato       NUMBER  (15)
                                       0,                          -- CdItemContrato   NUMBER  (15)
                                       V_IndAgraDesc,              -- InAgravoDesconto VARCHAR2(01)
                                       V_Valor,                    -- VlAgravoDesconto NUMBER  (15,2)
                                       V_MULTCALCULO.Tipo_Pessoa,  -- TpPessoa         VARCHAR2(01)
                                       V_ClienteCpf,               -- CPFCNPJCliente   NUMBER  (14)
                                       V_NomeCliente,              -- NmCliente        VARCHAR2(40)
                                       V_KIT022(i).VL_PRMIO_LIQUI, -- VlPremioLiquido  NUMBER  (15,2)
                                       V_MULTCALCULO.Comissao,     -- PcComissao       NUMBER  (05,2)
                                       To_Char(V_MULTCALCULO.Iniciovigencia, 'YYYYMMDD'), -- DtInicioVigencia        VARCHAR2(08)
                                       P_Conta.I_Usuario,          -- CdUsuario        VARCHAR2(30)
                                       13                          --
                                     );

     ctactpa0002_001.Valida_Valor(V_ValidaIn, V_ValidaOut);

     IF (V_ValidaOut.StRetorno <> 0) THEN
        AddErro(302024,V_ValidaOut.MsgRetorno);
        RETURN 1;
     END IF;
   END IF;
  END LOOP;

  RETURN 0;
end;
/


CREATE OR REPLACE FUNCTION GETDATAVERSAO_VIGENCIA
(
  DATAVERSAO IN DATE
, INICIOVIGENCIA IN DATE
) RETURN DATE AS
BEGIN
  IF DATAVERSAO >= INICIOVIGENCIA THEN
    RETURN DataVersao;
  ELSE
    RETURN INICIOVIGENCIA;
  end if;
END GETDATAVERSAO_VIGENCIA;
/


CREATE OR REPLACE FUNCTION KIT_CAMPO27
 (
PCalculo In Mult_calculo.Calculo%Type
)
Return Varchar2 As
PCampo Varchar2(6000);
BEGIN
   DECLARE
     PVALOR92 number(16,6);
     PVALOR93 number(16,6);
     PVALOR98 number(16,6);
     PVALOR1026 number(16,6);
     PVALOR1027 number(16,6);
     PVALOR1028 number(16,6);
     PVALOR1029 number(16,6);
     MINVALOR92 number(16,6);
     MINVALOR98 number(16,6);
     MINVALOR1027 number(16,6);
     MINVALOR1028 number(16,6);
     MINVALOR1029 number(16,6);
     MAXVALOR92 number(16,6);
     MAXVALOR98 number(16,6);
     MAXVALOR1027 number(16,6);
     MAXVALOR1028 number(16,6);
     MAXVALOR1029 number(16,6);
     CMINVALOR92 VARCHAR(15);
     CMINVALOR98 VARCHAR(15);
     CMINVALOR1027 VARCHAR(15);
     CMINVALOR1028 VARCHAR(15);
     CMINVALOR1029 VARCHAR(15);
     CMAXVALOR92 VARCHAR(15);
     CMAXVALOR98 VARCHAR(15);
     CMAXVALOR1027 VARCHAR(15);
     CMAXVALOR1028 VARCHAR(15);
     CMAXVALOR1029 VARCHAR(15);
     CVALOR92 VARCHAR(15);
     CVALOR93 VARCHAR(15);
     CVALOR98 VARCHAR(15);
     CVALOR1026 VARCHAR(15);
     CVALOR1027 VARCHAR(15);
     CVALOR1028 VARCHAR(15);
     CVALOR1029 VARCHAR(15);
     VVALOR number(16,6);
     VACESSORIO number(16,6);
	 PNomeCampo Varchar(100);
     Cursor T_Acessorios Is
        SELECT Valor, Acessorio from kit_calculoAces where Calculo = Pcalculo;
   BEGIN
	 PVALOR92 := 0;
	 PVALOR93 := 0;
	 PVALOR98 := 0;
	 PVALOR1026 := 0;
	 PVALOR1027 := 0;
	 PVALOR1028 := 0;
	 PVALOR1029 := 0;
         MINVALOR92 := 0;
         MINVALOR98 := 0;
         MINVALOR1027 := 0;
         MINVALOR1028 := 0;
         MINVALOR1029 := 0;
         MAXVALOR92 := 0;
         MAXVALOR98 := 0;
         MAXVALOR1027 := 0;
         MAXVALOR1028 := 0;
         MAXVALOR1029 := 0;
     Open T_Acessorios;
     Loop
        Fetch T_Acessorios Into VValor, VACESSORIO;
              Exit When T_Acessorios%Notfound;
		if VACESSORIO = 92 then
   	       PVALOR92 := VValor;
		end if;
		if VACESSORIO = 93 then
   	       PVALOR93 := VValor;
		end if;
		if VACESSORIO = 98 then
   	       PVALOR98 := VValor;
		end if;
		if VACESSORIO = 1026 then
   	       PVALOR1026 := VValor;
		end if;
		if VACESSORIO = 1027 then
   	       PVALOR1027 := VValor;
		end if;
		if VACESSORIO = 1028 then
   	       PVALOR1028 := VValor;
		end if;
		if VACESSORIO = 1029 then
   	       PVALOR1029 := VValor;
		end if;
     End Loop;
     Close T_Acessorios;
	 CVALOR92 := trim(TO_CHAR(PVALOR92, '999,999,990.00'));
	 CVALOR93 := trim(TO_CHAR(PVALOR93, '999,999,990.00'));
	 CVALOR98 := trim(TO_CHAR(PVALOR98, '999,999,990.00'));
	 CVALOR1026 := trim(TO_CHAR(PVALOR1026, '999,999,990.00'));
	 CVALOR1027 := trim(TO_CHAR(PVALOR1027, '999,999,990.00'));
	 CVALOR1028 := trim(TO_CHAR(PVALOR1028, '999,999,990.00'));
	 CVALOR1029 := trim(TO_CHAR(PVALOR1029, '999,999,990.00'));
	 CVALOR92 := translate(CVALOR92,',','x');
	 CVALOR92 := translate(CVALOR92,'.',',');
	 CVALOR92 := translate(CVALOR92,'x','.');
	 CVALOR93 := translate(CVALOR93,',','x');
	 CVALOR93 := translate(CVALOR93,'.',',');
	 CVALOR93 := translate(CVALOR93,'x','.');
	 CVALOR98 := translate(CVALOR98,',','x');
	 CVALOR98 := translate(CVALOR98,'.',',');
	 CVALOR98 := translate(CVALOR98,'x','.');
	 CVALOR1026 := translate(CVALOR1026,',','x');
	 CVALOR1026 := translate(CVALOR1026,'.',',');
	 CVALOR1026 := translate(CVALOR1026,'x','.');
	 CVALOR1027 := translate(CVALOR1027,',','x');
	 CVALOR1027 := translate(CVALOR1027,'.',',');
	 CVALOR1027 := translate(CVALOR1027,'x','.');
	 CVALOR1028 := translate(CVALOR1028,',','x');
	 CVALOR1028 := translate(CVALOR1028,'.',',');
	 CVALOR1028 := translate(CVALOR1028,'x','.');
	 CVALOR1029 := translate(CVALOR1029,',','x');
	 CVALOR1029 := translate(CVALOR1029,'.',',');
	 CVALOR1029 := translate(CVALOR1029,'x','.');
	 select Descricao into PNomeCampo from mult_padraoforms where padrao = 10 and sequencia = 27;
         Select Valor2, Valor3 INTO MINVALOR92, MAXVALOR92 from Mult_produtosTabRg where Produto = 10 and tabela = 51 and chave1 = 48 and chave2 = 92;
         Select Valor2, Valor3 INTO MINVALOR98, MAXVALOR98 from Mult_produtosTabRg where Produto = 10 and tabela = 51 and chave1 = 48 and chave2 = 98;
         Select Valor2, Valor3 INTO MINVALOR1027, MAXVALOR1027 from Mult_produtosTabRg where Produto = 10 and tabela = 51 and chave1 = 48 and chave2 = 1027;
         Select Valor2, Valor3 INTO MINVALOR1028, MAXVALOR1028 from Mult_produtosTabRg where Produto = 10 and tabela = 51 and chave1 = 48 and chave2 = 1028;
         Select Valor2, Valor3 INTO MINVALOR1029, MAXVALOR1029 from Mult_produtosTabRg where Produto = 10 and tabela = 51 and chave1 = 48 and chave2 = 1029;
	 CMINVALOR92 := trim(TO_CHAR(MINVALOR92, '999,999,990.00'));
	 CMINVALOR92 := translate(CMINVALOR92,',','x');
	 CMINVALOR92 := translate(CMINVALOR92,'.',',');
	 CMINVALOR92 := translate(CMINVALOR92,'x','.');
	 CMAXVALOR92 := trim(TO_CHAR(MAXVALOR92, '999,999,990.00'));
	 CMAXVALOR92 := translate(CMAXVALOR92,',','x');
	 CMAXVALOR92 := translate(CMAXVALOR92,'.',',');
	 CMAXVALOR92 := translate(CMAXVALOR92,'x','.');

	 CMINVALOR98 := trim(TO_CHAR(MINVALOR98, '999,999,990.00'));
	 CMINVALOR98 := translate(CMINVALOR98,',','x');
	 CMINVALOR98 := translate(CMINVALOR98,'.',',');
	 CMINVALOR98 := translate(CMINVALOR98,'x','.');
	 CMAXVALOR98 := trim(TO_CHAR(MAXVALOR98, '999,999,990.00'));
	 CMAXVALOR98 := translate(CMAXVALOR98,',','x');
	 CMAXVALOR98 := translate(CMAXVALOR98,'.',',');
	 CMAXVALOR98 := translate(CMAXVALOR98,'x','.');

	 CMINVALOR1027 := trim(TO_CHAR(MINVALOR1027, '999,999,990.00'));
	 CMINVALOR1027 := translate(CMINVALOR1027,',','x');
	 CMINVALOR1027 := translate(CMINVALOR1027,'.',',');
	 CMINVALOR1027 := translate(CMINVALOR1027,'x','.');
	 CMAXVALOR1027 := trim(TO_CHAR(MAXVALOR1027, '999,999,990.00'));
	 CMAXVALOR1027 := translate(CMAXVALOR1027,',','x');
	 CMAXVALOR1027 := translate(CMAXVALOR1027,'.',',');
	 CMAXVALOR1027 := translate(CMAXVALOR1027,'x','.');

	 CMINVALOR1028 := trim(TO_CHAR(MINVALOR1028, '999,999,990.00'));
	 CMINVALOR1028 := translate(CMINVALOR1028,',','x');
	 CMINVALOR1028 := translate(CMINVALOR1028,'.',',');
	 CMINVALOR1028 := translate(CMINVALOR1028,'x','.');
	 CMAXVALOR1028 := trim(TO_CHAR(MAXVALOR1028, '999,999,990.00'));
	 CMAXVALOR1028 := translate(CMAXVALOR1028,',','x');
	 CMAXVALOR1028 := translate(CMAXVALOR1028,'.',',');
	 CMAXVALOR1028 := translate(CMAXVALOR1028,'x','.');

	 CMINVALOR1029 := trim(TO_CHAR(MINVALOR1029, '999,999,990.00'));
	 CMINVALOR1029 := translate(CMINVALOR1029,',','x');
	 CMINVALOR1029 := translate(CMINVALOR1029,'.',',');
	 CMINVALOR1029 := translate(CMINVALOR1029,'x','.');
	 CMAXVALOR1029 := trim(TO_CHAR(MAXVALOR1029, '999,999,990.00'));
	 CMAXVALOR1029 := translate(CMAXVALOR1029,',','x');
	 CMAXVALOR1029 := translate(CMAXVALOR1029,'.',',');
	 CMAXVALOR1029 := translate(CMAXVALOR1029,'x','.');

         PCampo := '<tr valign="middle" bgcolor="#FFFFE8">';
         PCampo := PCampo || '<td align="left" class="texto11preto"> RÁDIO: </td>';
         PCampo := PCampo || '<td align="left" class="texto11preto"> R$ ';
         PCampo := PCampo || '<input type="text" size ="10"  onKeyUp="ChkNumber(this, false)" onBlur="Chkvalor(this)" maxlength="10"  ';
         PCampo := PCampo || 'name="SCbVALOR000092" Value="'||CVALOR92||'" class="real11cinzatabela"> <span class="real10vermelho">';
         PCampo := PCampo || 'minimo de R$ '||CMINVALOR92||' e máximo de R$ '||CMAXVALOR92||'</span>';
         PCampo := PCampo || '</td>';
         PCampo := PCampo || '</tr>';
         PCampo := PCampo || '<tr> ';
         PCampo := PCampo || '<td colspan="4" bgcolor="#999999" class="texto11preto"><img src="imagens/spacer.gif" width=1 height=1 border=0></td>';
         PCampo := PCampo || '</tr>';
         PCampo := PCampo || '<tr valign="middle" bgcolor="#FFFFE8"> ';
         PCampo := PCampo || '<td align="left" class="texto11preto"> DISC LASER: </td>';
         PCampo := PCampo || '<td align="left" class="texto11preto"> R$ ';
         PCampo := PCampo || '<input type="text" size ="10"  onKeyUp="ChkNumber(this, false);" onBlur="Chkvalor(this);" maxlength="10"  ';
         PCampo := PCampo || 'name="SCbVALOR000098" Value="'||CVALOR98||'" class="real11cinzatabela"> <span class="real10vermelho">';
         PCampo := PCampo || 'minimo de R$ '||CMINVALOR98||' e máximo de R$ '||CMAXVALOR98||'</span>';
         PCampo := PCampo || '</td>';
         PCampo := PCampo || '</tr>';
         PCampo := PCampo || '<tr> ';
         PCampo := PCampo || '<td colspan="4" bgcolor="#999999" class="texto11preto"><img border="0" src="imagens/spacer.gif" width=1 height=1></td>';
         PCampo := PCampo || '</tr>';
         PCampo := PCampo || '<tr valign="middle" bgcolor="#FFFFE8"> ';
         PCampo := PCampo || '<td align="left" class="texto11preto"> AMPLIFICADOR: </td>';
         PCampo := PCampo || '<td align="left" class="texto11preto"> R$ ';
         PCampo := PCampo || '<input type="text" size ="10"  onKeyUp="ChkNumber(this, false);" onBlur="Chkvalor(this);" maxlength="10"  ';
         PCampo := PCampo || 'name="SCbVALOR001027" Value="'||CVALOR1027||'" class="real11cinzatabela"> <span class="real10vermelho">';
         PCampo := PCampo || 'minimo de R$ '||CMINVALOR1027||' e máximo de R$ '||CMAXVALOR1027||'</span>';
         PCampo := PCampo || '</td>';
         PCampo := PCampo || '<tr> ';
         PCampo := PCampo || '<td colspan="4" bgcolor="#999999" class="texto11preto"><img border="0" src="imagens/spacer.gif" width=1 height=1></td>';
         PCampo := PCampo || '</tr>';
         PCampo := PCampo || '<tr valign="middle" bgcolor="#FFFFE8"> ';
         PCampo := PCampo || '<td align="left" class="texto11preto">ALTO FALANTES:</td>';
         PCampo := PCampo || '<td align="left" class="texto11preto">R$ ';
         PCampo := PCampo || '<input type="text" size ="10"  onKeyUp="ChkNumber(this, false);" onBlur="Chkvalor(this);" maxlength="10"  ';
         PCampo := PCampo || 'name="SCbVALOR001028" value="';
         PCampo := PCampo || CVALOR1028;
         PCampo := PCampo || '" class="real11cinzatabela"> <span class="real10vermelho">';
         PCampo := PCampo || 'minimo de R$ '||CMINVALOR1028||' e máximo de R$ '||CMAXVALOR1028||'</span>';
         PCampo := PCampo || '</td>';
         PCampo := PCampo || '<tr> ';
         PCampo := PCampo || '<td colspan="4" bgcolor="#999999" class="texto11preto"><img border="0" src="imagens/spacer.gif" width=1 height=1></td>';
         PCampo := PCampo || '</tr>';
         PCampo := PCampo || '<tr valign="middle" bgcolor="#FFFFE8">';
         PCampo := PCampo || '<td align="left" class="texto11preto">OUTROS: </td>';
         PCampo := PCampo || '<td align="left" class="texto11preto">R$ ';
         PCampo := PCampo || '<input type="text" size ="10"  onKeyUp="ChkNumber(this, false);" onBlur="Chkvalor(this);" maxlength="10"  ';
         PCampo := PCampo || 'name="SCbVALOR001029" value="'||CVALOR1029||'" class="real11cinzatabela"> <span class="real10vermelho">';
         PCampo := PCampo || 'minimo de R$ '||CMINVALOR1029||' e máximo de R$ '||CMAXVALOR1029||'</span>';
         PCampo := PCampo || '</td>';
         PCampo := PCampo || '</tr>';
     Return PCampo;
   END;
END;
/


CREATE OR REPLACE FUNCTION kitfc0001_banner_resid_facil
(p_corretor     NUMBER,
p_login         VARCHAR2)
-- usuario
RETURN VARCHAR2 AS
--
v_corretores_sem_oferta VARCHAR2(4000);
--
v_url                   VARCHAR2(4000);
--
v_corretor              VARCHAR2(100);
--
v_existe                NUMBER  :=      0;
--
v_parametro_url         VARCHAR2(100)   :=      'URL_BANNER_RESID_FACIL';
--
BEGIN
        --
        v_corretor      :=      ',' || p_corretor || ',';
        --
        BEGIN
                --
                v_corretores_sem_oferta    :=      ',' || tms_param.get_param('COMUNS.EMISSAO.MR','CORRETORES.SEM.OFERTA.RESIDENCIAL.FACIL') || ',';
                --
                v_existe        :=      InStr(v_corretores_sem_oferta,v_corretor);
                --
        EXCEPTION
                --
                WHEN    OTHERS  THEN
                        --
                        NULL;
                --
        END;
        --
        IF      v_existe        =       0       THEN
                --
                BEGIN
                        --
                        SELECT  valor
                        INTO    v_url
                        FROM    tabela_configuracoes_kcw
                        WHERE   parametro       =       v_parametro_url;
                        --
                        v_url   :=      REPLACE(v_url,'{PTM_CODIGO}', p_corretor);
                        v_url   :=      REPLACE(v_url,'{PTM_LOGIN}', p_login);
                        --v_url   :=      v_url   || '&corretor=' || p_corretor;
                        --
                EXCEPTION
                        --
                        WHEN    OTHERS  THEN
                                --
                                v_url   :=      NULL;
                END;
                --
        END     IF;
        --
        RETURN  v_url;
        --
END;
/


CREATE OR REPLACE FUNCTION        kitfc001_get_url_resid_facil (p_calculoorigem NUMBER,
                                                         p_padrao NUMBER,
                                                         p_usuario VARCHAR2,
                                                         p_url_link_resid_facil IN VARCHAR2) RETURN VARCHAR2
IS
    v_0_char       VARCHAR2(1) := '0';
    v_10           NUMBER(2)   := 10;
    v_42           NUMBER(2)   := 42;
    v_cd_retorno  NUMBER;
    v_msg_retorno VARCHAR2(32767);
    v_result       VARCHAR2(32767);

BEGIN
    v_result := p_url_link_resid_facil;

    CASE
    WHEN p_calculoorigem > 0 AND p_padrao IN (v_10, v_42) THEN
        ADMSSV.SSVPA_RESIDENCIAL_FACIL.OFERTA_RESIDENCIAL_FACIL(p_calculoorigem, v_cd_retorno, v_msg_retorno);
        IF v_cd_retorno = v_0_char THEN
            v_result := REPLACE(v_result, 'COD_NEGOCIO_SSV', p_calculoorigem);
            v_result := REPLACE(v_result, 'COD_USUARIO', p_usuario);

        ELSE
            v_result := NULL;

        END IF;

    ELSE
        v_result := NULL;

    END CASE;

    RETURN v_result;
END;
/


CREATE OR REPLACE FUNCTION KITFC002_ESTIP_TABLE (p_estipulante VARCHAR2) RETURN KITTY002_ESTIP_TABLE
AS
    l_tab KITTY002_ESTIP_TABLE := KITTY002_ESTIP_TABLE();
    v_estipulante VARCHAR2(32767);
    i NUMBER;
 
BEGIN
    i := 0;
    LOOP
        i := i + 1;
        IF i > LENGTH(p_estipulante) THEN
            EXIT;
        END IF;
        IF INSTR(p_estipulante,',',i) > 0 THEN
            v_estipulante := SUBSTR(p_estipulante,i);
            v_estipulante := SUBSTR(v_estipulante, 1, INSTR(v_estipulante,',') - 1);
            i             := INSTR(p_estipulante,',',i);
        ELSE
            v_estipulante := SUBSTR(p_estipulante,i);
            i             := LENGTH(p_estipulante);
        END IF;
        l_tab.extend;
        l_tab(l_tab.last) := KITTY001_ESTIP_ROW(v_estipulante);
    END LOOP;
    RETURN l_tab;
END;
/


CREATE OR REPLACE FUNCTION KITFC003_CARRO_RESERVA_RENOV (p_calculo NUMBER) RETURN NUMBER
AS
--
/*
Retornos:
1 - 7 diarias
2 - 15 diarias
3 - 30 diarias
4 - nao possui;
*/
v_codigo_qt_diarias     NUMBER(03);
p_nr_itseg_renov        NUMBER(11);
v_zero_char             VARCHAR2(01)    :=      '0';
v_145                   NUMBER(3)       :=      145;

BEGIN
        BEGIN
                --
                SELECT  itemorigem
                INTO    p_nr_itseg_renov
                FROM    mult_calculo
                WHERE   calculo =       p_calculo;
                --
        EXCEPTION
                --
                WHEN    OTHERS  THEN
                        --
                        RETURN  1;
        END;
        --
        IF      p_nr_itseg_renov        IS      NULL    THEN
                --
                RETURN  1;
                --
        END     IF;
        --
        BEGIN
                --
                SELECT  Decode  (cd_vlcar_itseg
                                ,4615 ,1
                                ,10752,2
                                ,10753,3
                                ,17475,4
                                ,4)
                INTO    v_codigo_qt_diarias
                FROM    ssv0035_descr_itseg
                WHERE   nr_itseg        =       p_nr_itseg_renov
                AND     tp_histo_itseg  =       v_zero_char
                AND     CD_CARAC_ITSEG  =       v_145;
                --
                RETURN  v_codigo_qt_diarias;
                --
        EXCEPTION
                --
                WHEN    OTHERS  THEN
                        --
                        RETURN  1;
        END;
        --

END;
/
